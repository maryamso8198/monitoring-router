"""
هماهنگ‌کننده‌ی اصلی مانیتورینگ.

کلاس RouterMonitor مسئول اجرای حلقه‌ی دوره‌ای است: در هر تناوب زمانی،
از api.client اطلاعات تازه می‌گیرد، نرخ ترافیک را با کمک TrafficMonitor
محاسبه می‌کند و نتیجه را برای نمایش به utils.display می‌فرستد.
"""

import logging
import time
from typing import Dict, List, Optional

from api.client import MikrotikClient, MikrotikConnectionError
from monitor.traffic import TrafficMonitor
from monitor.limits import TrafficLimitChecker
from monitor.tunnels import TunnelMonitor
from monitor.dhcp_watch import DhcpLeaseWatcher
from utils.display import print_dashboard

logger = logging.getLogger("mikrotik_monitor")


class RouterMonitor:
    """اجراکننده‌ی حلقه‌ی مانیتورینگ زنده‌ی روتر."""

    def __init__(
        self,
        client: MikrotikClient,
        refresh_interval: int = 2,
        interface_filter: Optional[List[str]] = None,
        clear_screen_each_refresh: bool = True,
        traffic_limit_mb: Optional[float] = None,
        interface_limits_mb: Optional[Dict[str, float]] = None,
        comment_limits_mb: Optional[Dict[str, float]] = None,
        traffic_state_file: Optional[str] = "traffic_totals.json",
        tunnel_monitoring_enabled: bool = True,
        tunnel_check_interval: float = 30.0,
        dhcp_enabled: bool = True,
    ):
        self.client = client
        self.refresh_interval = refresh_interval
        self.interface_filter = interface_filter
        self.clear_screen_each_refresh = clear_screen_each_refresh
        self.dhcp_enabled = dhcp_enabled
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
        self._connected = False

    def run(self) -> None:
        """
        اجرای حلقه‌ی بی‌نهایت مانیتورینگ تا زمان Ctrl+C.

        اگه اتصال (چه در ابتدا، چه در وسط کار — مثلاً به‌خاطر ریبوت روتر)
        قطع باشه، خودش دوره‌ای تلاش می‌کنه دوباره وصل بشه، بدون نیاز به
        متوقف و دوباره اجرا کردن دستی برنامه.
        """
        try:
            while True:
                try:
                    if not self._connected:
                        self._try_connect()
                        if not self._connected:
                            time.sleep(self.refresh_interval)
                            continue

                    self._tick()
                except Exception as exc:
                    # لایه‌ی محافظتی نهایی و مطلق: حتی یه باگ کاملاً
                    # پیش‌بینی‌نشده هم نباید کل برنامه رو کرش بده.
                    logger.exception("Unexpected error in monitoring loop: %s", exc)
                    print(f"[ERROR] Unexpected error: {exc} — will attempt to reconnect...")
                    self.client.close()
                    self._connected = False

                time.sleep(self.refresh_interval)
        except KeyboardInterrupt:
            print("\nMonitoring stopped.")
        finally:
            if self._connected:
                self.client.close()

    def _try_connect(self) -> None:
        """تلاش برای برقراری اتصال. در صورت شکست، فقط خطا رو چاپ می‌کنه و ادامه می‌ده."""
        try:
            self.client.connect()
            self._connected = True
            logger.info("Connected to router.")
            print("Connected to router.")
        except MikrotikConnectionError as exc:
            logger.error(str(exc))
            print(f"[ERROR] {exc} — retrying in {self.refresh_interval}s...")
            self._connected = False

    def _tick(self) -> None:
        """
        یک دور نمونه‌برداری و نمایش.

        فقط عملیات هسته‌ای (identity/resource/interfaces) می‌تونن باعث
        قطع اتصال و reconnect بشن. health/dhcp/تانل‌ها اختیاری‌ان و خودِ
        api/client.py تضمین می‌کنه هیچ‌وقت استثنا پرتاب نمی‌کنن.
        """
        try:
            identity = self.client.get_identity()
            resource = self.client.get_system_resource()
            interfaces = self.client.get_interfaces(only_names=self.interface_filter)
        except MikrotikConnectionError as exc:
            logger.error("Error while fetching core data (connection likely lost): %s", exc)
            print(f"[ERROR] Error fetching data from router: {exc} — will attempt to reconnect...")
            # اتصال احتمالاً قطع شده (مثلاً روتر ریبوت شده)؛ کانکشن رو می‌بندیم
            # تا در دور بعدی حلقه، دوباره تلاش برای اتصال انجام بشه.
            self.client.close()
            self._connected = False
            return

        interfaces = self.traffic_monitor.update(interfaces)

        newly_exceeded = self.limit_checker.check(interfaces)
        for iface in newly_exceeded:
            total_mb = iface.total_bytes / (1024 * 1024)
            logger.warning(
                "Interface %s exceeded traffic limit: %.2f MB / %.2f MB limit",
                iface.name, total_mb, iface.limit_mb,
            )
            print(
                f"\n*** ALERT: Interface '{iface.name}' exceeded traffic limit! "
                f"({total_mb:.2f} MB / {iface.limit_mb:.2f} MB limit) ***\n"
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
                        f"New device connected: {lease.host_name} "
                        f"({lease.address}, {lease.mac_address})"
                    )
                    logger.info(msg)
                    print(f"\n*** [NOTIFY] {msg} ***\n")

        print_dashboard(
            identity=identity,
            resource=resource,
            interfaces=interfaces,
            health=health,
            tunnels=tunnels,
            dhcp_servers=dhcp_servers,
            clear=self.clear_screen_each_refresh,
        )
