"""
اجرای نمونه‌برداری دوره‌ای از روتر در یک ترد پس‌زمینه، مستقل از وب‌سرور Flask.

BackgroundMonitor همان منطق RouterMonitor (اتصال، خواندن داده، محاسبه‌ی نرخ
ترافیک) را دارد، با این تفاوت که به‌جای چاپ در ترمینال، نتیجه را در یک
SharedRouterState ذخیره می‌کند تا وب‌سرور بتواند آن را serve کند.

نکته‌ی مهم درباره‌ی سازگاری با مدل‌های مختلف: ویژگی‌های اختیاری (health،
DHCP، تانل‌ها) در خود api/client.py طوری طراحی شده‌اند که هرگز استثنا پرتاب
نمی‌کنند — در صورت عدم پشتیبانی روی یک مدل خاص، فقط مقدار خالی برمی‌گردانند.
بنابراین شکست یکی از این ویژگی‌ها هرگز نباید بقیه‌ی داشبورد (CPU/RAM/اینترفیس‌ها)
را از دست بدهد.

به‌علاوه، پیام‌های وضعیت اتصال همیشه با print() هم چاپ می‌شن (نه فقط لاگ)،
چون logging به‌صورت پیش‌فرض در config.json غیرفعاله و در غیر این صورت هیچ‌کس
این پیام‌ها رو نمی‌بینه.
"""

import logging
import threading
from typing import Dict, List, Optional

from api.client import MikrotikClient, MikrotikConnectionError
from monitor.traffic import TrafficMonitor
from monitor.limits import TrafficLimitChecker
from monitor.tunnels import TunnelMonitor
from monitor.dhcp_watch import DhcpLeaseWatcher
from monitor.state import SharedRouterState

logger = logging.getLogger("mikrotik_monitor.background")


class BackgroundMonitor:
    """اجرای حلقه‌ی پولینگ روتر در یک ترد جدا، برای استفاده در برنامه‌ی وب."""

    def __init__(
        self,
        client: MikrotikClient,
        state: SharedRouterState,
        refresh_interval: int = 2,
        interface_filter: Optional[List[str]] = None,
        traffic_limit_mb: Optional[float] = None,
        interface_limits_mb: Optional[Dict[str, float]] = None,
        comment_limits_mb: Optional[Dict[str, float]] = None,
        traffic_state_file: Optional[str] = "traffic_totals.json",
        router_id: str = "",
        tunnel_monitoring_enabled: bool = True,
        tunnel_check_interval: float = 30.0,
        dhcp_enabled: bool = True,
    ):
        self.client = client
        self.state = state
        self.refresh_interval = refresh_interval
        self.interface_filter = interface_filter
        self.router_id = router_id
        self._log_prefix = f"[{router_id}] " if router_id else ""
        self.dhcp_enabled = dhcp_enabled
        # نکته‌ی مهم برای چند-روتری: هر روتر باید فایل ذخیره‌ی ترافیک مخصوص
        # به خودش رو داشته باشه (مثلاً traffic_totals_branch1.json)، وگرنه
        # اسم اینترفیس‌های یکسان (مثل ether1) بین شعبه‌های مختلف قاطی می‌شه.
        self.traffic_monitor = TrafficMonitor(state_file=traffic_state_file)
        self.limit_checker = TrafficLimitChecker(
            default_limit_mb=traffic_limit_mb,
            interface_limits_mb=interface_limits_mb,
            comment_limits_mb=comment_limits_mb,
        )
        self.tunnel_monitor = (
            TunnelMonitor(check_interval_seconds=tunnel_check_interval)
            if tunnel_monitoring_enabled else None
        )
        self.dhcp_watcher = DhcpLeaseWatcher() if dhcp_enabled else None

        self._thread: Optional[threading.Thread] = None
        self._stop_event = threading.Event()
        self._connected = False

    def start(self) -> None:
        """شروع ترد پس‌زمینه (daemon، یعنی با بسته شدن برنامه‌ی اصلی خودش هم بسته می‌شود)."""
        self._thread = threading.Thread(target=self._run_loop, daemon=True)
        self._thread.start()

    def stop(self) -> None:
        """توقف ترد پس‌زمینه."""
        self._stop_event.set()
        if self._thread is not None:
            self._thread.join(timeout=5)

    def _run_loop(self) -> None:
        """
        حلقه‌ی اصلی. اگه اتصال برقرار نباشه (چه در ابتدای اجرا، چه بعد از
        قطع شدن در وسط کار — مثلاً به‌خاطر ریبوت روتر)، خودش تلاش می‌کنه
        دوباره وصل بشه، بدون نیاز به دخالت دستی.

        این حلقه با یک except Exception در بیرونی‌ترین سطح هم محافظت می‌شه:
        حتی اگه یک باگ کاملاً پیش‌بینی‌نشده هم وجود داشته باشه، ترد
        بی‌صدا نمی‌میره؛ خطا چاپ می‌شه و حلقه ادامه پیدا می‌کنه.
        """
        while not self._stop_event.is_set():
            try:
                if not self._connected:
                    self._try_connect()
                    if not self._connected:
                        self._stop_event.wait(self.refresh_interval)
                        continue

                self._tick()
            except Exception as exc:
                # لایه‌ی محافظتی نهایی و مطلق: حتی اگه _try_connect یا _tick
                # هم (به‌خاطر یه باگ ناشناخته) استثنایی رو از دست بدن، اینجا
                # گرفته می‌شه. بدون این، کل ترد پس‌زمینه بی‌صدا می‌میره و
                # داشبورد برای همیشه "No data received yet." نشون می‌ده.
                msg = f"{self._log_prefix}Unexpected error in monitoring loop: {exc}"
                logger.exception(msg)
                print(f"[ERROR] {msg}")
                self.state.set_error(f"Unexpected error: {exc}")
                self.client.close()
                self._connected = False

            self._stop_event.wait(self.refresh_interval)

        if self._connected:
            self.client.close()

    def _try_connect(self) -> None:
        """تلاش برای برقراری اتصال. در صورت شکست، فقط خطا رو ثبت می‌کنه و ادامه می‌ده."""
        try:
            self.client.connect()
            self._connected = True
            msg = f"{self._log_prefix}Connected to router."
            logger.info(msg)
            print(msg)
        except MikrotikConnectionError as exc:
            msg = f"{self._log_prefix}{exc}"
            logger.error(msg)
            print(f"[ERROR] {msg}")
            self.state.set_error(str(exc))
            self._connected = False

    def _tick(self) -> None:
        """
        یک دور کامل نمونه‌برداری.

        فقط عملیات هسته‌ای (identity/resource/interfaces) می‌تونن باعث
        قطع اتصال و reconnect بشن. health/dhcp/tunnels اختیاری‌ان و خودِ
        api/client.py تضمین می‌کنه که هیچ‌وقت استثنا پرتاب نمی‌کنن (فقط
        مقدار خالی برمی‌گردونن)، پس نیازی به try/except جداگانه براشون اینجا نیست.
        """
        try:
            identity = self.client.get_identity()
            resource = self.client.get_system_resource()
            interfaces = self.client.get_interfaces(only_names=self.interface_filter)
        except MikrotikConnectionError as exc:
            msg = f"{self._log_prefix}Error while fetching core data (connection likely lost): {exc}"
            logger.error(msg)
            print(f"[ERROR] {msg}")
            self.state.set_error(str(exc))
            # اتصال احتمالاً قطع شده (مثلاً روتر ریبوت شده). کانکشن فعلی رو
            # می‌بندیم تا در دور بعدی حلقه، دوباره تلاش برای اتصال انجام بشه.
            self.client.close()
            self._connected = False
            return

        interfaces = self.traffic_monitor.update(interfaces)

        newly_exceeded = self.limit_checker.check(interfaces)
        for iface in newly_exceeded:
            total_mb = iface.total_bytes / (1024 * 1024)
            msg = (
                f"{self._log_prefix}Interface {iface.name} exceeded traffic limit: "
                f"{total_mb:.2f} MB / {iface.limit_mb:.2f} MB limit"
            )
            logger.warning(msg)
            print(f"[ALERT] {msg}")
            self.state.add_notification(
                f"Interface {iface.name} exceeded traffic limit "
                f"({total_mb:.2f} MB / {iface.limit_mb:.2f} MB)",
                notif_type="traffic_limit",
            )

        # health، DHCP و تانل‌ها اختیاری‌ان — هیچ‌کدوم استثنا پرتاب نمی‌کنن
        health = self.client.get_system_health()

        tunnels = []
        if self.tunnel_monitor is not None:
            tunnels = self.tunnel_monitor.update(self.client, interfaces)

        dhcp_servers, dhcp_leases = [], []
        if self.dhcp_enabled:
            dhcp_servers, dhcp_leases = self.client.get_dhcp_status()

            if self.dhcp_watcher is not None:
                newly_connected = self.dhcp_watcher.check(dhcp_leases)
                for lease in newly_connected:
                    msg = (
                        f"{self._log_prefix}New device connected: {lease.host_name} "
                        f"({lease.address}, {lease.mac_address})"
                    )
                    logger.info(msg)
                    print(f"[NOTIFY] {msg}")
                    self.state.add_notification(
                        f"New device connected: {lease.host_name} ({lease.address})",
                        notif_type="dhcp",
                    )

        self.state.update(identity, resource, interfaces, health, tunnels, dhcp_servers, dhcp_leases)
