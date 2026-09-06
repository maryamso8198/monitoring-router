"""
ماژول اتصال به RouterOS API میکروتیک.

این ماژول یک لایه‌ی انتزاعی (wrapper) روی کتابخانه‌ی librouteros فراهم می‌کند
تا بقیه‌ی پروژه بدون نیاز به دانستن جزئیات پروتکل API میکروتیک، بتواند
اطلاعات هویت، منابع سیستم و اینترفیس‌ها را بگیرد.

فلسفه‌ی مهم طراحی — سازگاری با همه‌ی مدل‌های میکروتیک:
مدل‌ها و نسخه‌های مختلف RouterOS (6.x در برابر 7.x، روترهای فیزیکی قدیمی
در برابر CHR مجازی) API یکسانی ندارند؛ بعضی منوها (مثل WireGuard، بعضی
سنسورهای health، یا حتی DHCP) ممکن است روی یک مدل وجود نداشته باشند یا
نوع خطای متفاوتی برگردانند. برای همین:
  - عملیات «هسته‌ای» (اتصال، هویت، منابع سیستم، لیست اینترفیس‌ها) در صورت
    شکست، MikrotikConnectionError پرتاب می‌کنند — چون این‌ها یعنی خود
    اتصال مشکل دارد و باید به لایه‌ی بالاتر (برای reconnect) اطلاع داده شود.
  - عملیات «اختیاری» (health، DHCP، تانل‌ها) هرگز خطا پرتاب نمی‌کنند؛ در
    صورت هر مشکلی (چه پشتیبانی نشدن روی آن مدل، چه خطای غیرمنتظره)، یک
    مقدار خالی/پیش‌فرض برمی‌گردانند تا بقیه‌ی داشبورد مختل نشود.
"""

import ipaddress
import re
import time
from datetime import datetime
from typing import Dict, List, Optional, Tuple

from librouteros import connect

from models.router import (
    RouterIdentity,
    SystemResource,
    InterfaceStats,
    SystemHealth,
    DhcpServerInfo,
    DhcpLease,
)


class MikrotikConnectionError(Exception):
    """خطای اختصاصی برای مشکلات اتصال یا احراز هویت به روتر."""


class MikrotikClient:
    """
    کلاینتی برای برقراری ارتباط و خواندن اطلاعات از روتر میکروتیک
    از طریق RouterOS API.

    نمونه استفاده:
        client = MikrotikClient(host="192.168.88.1", username="admin", password="1234")
        client.connect()
        identity = client.get_identity()
        client.close()

    یا با استفاده از context manager:
        with MikrotikClient(host="192.168.88.1", username="admin", password="1234") as client:
            resources = client.get_system_resource()
    """

    def __init__(
        self,
        host: str,
        username: str,
        password: str = "",
        port: int = 8728,
        use_ssl: bool = False,
        ssl_port: int = 8729,
        timeout: int = 5,
    ):
        self.host = host
        self.username = username
        self.password = password
        self.port = ssl_port if use_ssl else port
        self.use_ssl = use_ssl
        self.timeout = timeout
        self._api = None

    def connect(self) -> None:
        """اتصال به روتر و برقراری نشست API. در صورت خطا استثنا صادر می‌کند."""
        try:
            kwargs = dict(
                username=self.username,
                password=self.password,
                host=self.host,
                port=self.port,
                timeout=self.timeout,
            )
            if self.use_ssl:
                import ssl as ssl_lib

                ctx = ssl_lib.create_default_context()
                ctx.check_hostname = False
                ctx.verify_mode = ssl_lib.CERT_NONE
                kwargs["ssl_wrapper"] = ctx.wrap_socket

            self._api = connect(**kwargs)
        except Exception as exc:
            # Exception عمومی عمداً گرفته می‌شه (نه فقط انواع خاص librouteros)،
            # چون مدل‌ها/نسخه‌های مختلف ممکنه خطاهای متفاوتی (تایم‌اوت شبکه،
            # SSL، DNS، مشکل احراز هویت) پرتاب کنن که همه باید یکسان مدیریت بشن.
            self._api = None
            raise MikrotikConnectionError(
                f"Could not connect to router {self.host}:{self.port}: {exc}"
            ) from exc

    def close(self) -> None:
        """بستن نشست فعلی API. امن است حتی اگر از قبل بسته باشد."""
        if self._api is not None:
            try:
                self._api.close()
            except Exception:
                pass
            finally:
                self._api = None

    def __enter__(self) -> "MikrotikClient":
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.close()

    def _ensure_connected(self) -> None:
        if self._api is None:
            raise MikrotikConnectionError("Not connected. Call connect() first.")

    # ------------------------------------------------------------------
    # عملیات هسته‌ای — شکست اینها یعنی مشکل اتصال؛ خطا پرتاب می‌کنند
    # ------------------------------------------------------------------

    def get_identity(self) -> RouterIdentity:
        """دریافت اطلاعات هویتی روتر (نام روتر، مدل بورد، نسخه)."""
        self._ensure_connected()
        try:
            identity_rows = list(self._api("/system/identity/print"))
            resource_rows = list(self._api("/system/resource/print"))

            name = identity_rows[0].get("name", "") if identity_rows else ""
            res = resource_rows[0] if resource_rows else {}

            return RouterIdentity(
                name=name,
                board_name=res.get("board-name", ""),
                version=res.get("version", ""),
                uptime=res.get("uptime", ""),
            )
        except MikrotikConnectionError:
            raise
        except Exception as exc:
            raise MikrotikConnectionError(f"Error fetching router identity: {exc}") from exc

    def get_system_resource(self) -> SystemResource:
        """دریافت اطلاعات منابع سیستمی (CPU، RAM، دیسک)."""
        self._ensure_connected()
        try:
            rows = list(self._api("/system/resource/print"))
            if not rows:
                return SystemResource()

            r = rows[0]
            return SystemResource(
                cpu_load=int(r.get("cpu-load", 0)),
                free_memory=int(r.get("free-memory", 0)),
                total_memory=int(r.get("total-memory", 0)),
                free_hdd_space=int(r.get("free-hdd-space", 0)),
                total_hdd_space=int(r.get("total-hdd-space", 0)),
                uptime=r.get("uptime", ""),
                board_name=r.get("board-name", ""),
                version=r.get("version", ""),
            )
        except MikrotikConnectionError:
            raise
        except Exception as exc:
            raise MikrotikConnectionError(f"Error fetching system resources: {exc}") from exc

    def get_interfaces(self, only_names: Optional[List[str]] = None) -> List[InterfaceStats]:
        """
        دریافت لیست اینترفیس‌ها به همراه آمار ترافیک تجمعی هرکدام.

        نکته‌ی مهم: در RouterOS API، حالت stats=True (معادل CLI: print stats)
        فقط خصوصیات آماری (rx-byte، tx-byte، rx-packet و...) را برمی‌گرداند
        و خصوصیات عمومی مثل comment، running، disabled و mac-address در آن
        وجود ندارند. برای همین اینجا دو درخواست جدا می‌گیریم و بر اساس نام
        اینترفیس با هم ادغام می‌کنیم.

        اگر درخواست دوم (stats) به هر دلیلی (مثلاً عدم پشتیبانی روی یک مدل
        خاص) شکست بخورد، حداقل اطلاعات پایه (نام/وضعیت/کامنت) را از دست
        نمی‌دهیم — فقط آمار ترافیک آن اینترفیس صفر می‌ماند.

        Args:
            only_names: در صورت مشخص شدن، فقط اینترفیس‌های با این نام‌ها برگردانده می‌شوند.
        """
        self._ensure_connected()
        try:
            base_rows = list(self._api("/interface/print"))
        except MikrotikConnectionError:
            raise
        except Exception as exc:
            raise MikrotikConnectionError(f"Error fetching interface list: {exc}") from exc

        try:
            stats_rows = list(self._api("/interface/print", stats=True))
        except Exception:
            # آمار ترافیک اختیاریه؛ نبودش نباید کل لیست اینترفیس‌ها رو خراب کنه
            stats_rows = []

        stats_by_name = {row.get("name", ""): row for row in stats_rows}

        interfaces = []
        for r in base_rows:
            name = r.get("name", "")
            if only_names and name not in only_names:
                continue

            stats = stats_by_name.get(name, {})

            interfaces.append(
                InterfaceStats(
                    name=name,
                    running=r.get("running", False),
                    disabled=r.get("disabled", False),
                    rx_byte=int(stats.get("rx-byte", r.get("rx-byte", 0)) or 0),
                    tx_byte=int(stats.get("tx-byte", r.get("tx-byte", 0)) or 0),
                    rx_packet=int(stats.get("rx-packet", r.get("rx-packet", 0)) or 0),
                    tx_packet=int(stats.get("tx-packet", r.get("tx-packet", 0)) or 0),
                    rx_error=int(stats.get("rx-error", r.get("rx-error", 0)) or 0),
                    tx_error=int(stats.get("tx-error", r.get("tx-error", 0)) or 0),
                    rx_drop=int(stats.get("rx-drop", r.get("rx-drop", 0)) or 0),
                    tx_drop=int(stats.get("tx-drop", r.get("tx-drop", 0)) or 0),
                    mac_address=r.get("mac-address", ""),
                    comment=r.get("comment", ""),
                )
            )
        return interfaces

    # ------------------------------------------------------------------
    # عملیات اختیاری — هیچ‌وقت خطا پرتاب نمی‌کنند؛ در صورت مشکل مقدار
    # خالی/پیش‌فرض برمی‌گردانند (مثلاً چون روی یک مدل خاص پشتیبانی نمی‌شه)
    # ------------------------------------------------------------------

    def get_system_health(self) -> SystemHealth:
        """
        دریافت اطلاعات سلامت سخت‌افزاری روتر (ولتاژ و دمای بورد) از
        /system/health.

        در RouterOS 7.x، این دستور یک ردیف جداگانه برای هر سنسور برمی‌گرداند
        (هر ردیف شامل name/value/type است). در RouterOS 6.x قدیمی‌تر، ممکنه
        یک ردیف تکی با کلیدهای مستقیم (مثل voltage/temperature) برگرده. این
        متد هر دو حالت را پشتیبانی می‌کند.

        روی روترهای مجازی (مثل CHR) که سنسور فیزیکی واقعی ندارند، یا مدل‌هایی
        که این منو را اصلاً پشتیبانی نمی‌کنند، یک SystemHealth خالی (بدون
        خطا) برمی‌گرداند — این قابلیت کاملاً اختیاریه.
        """
        self._ensure_connected()
        health = SystemHealth()

        try:
            rows = list(self._api("/system/health/print"))
        except Exception:
            return health

        def _store(name: str, raw_value) -> None:
            if raw_value is None:
                return
            try:
                value = float(raw_value)
            except (TypeError, ValueError):
                return
            health.raw[name] = value
            if name == "voltage":
                health.voltage = value
            elif name == "temperature":
                health.temperature = value

        try:
            for row in rows:
                if "name" in row and "value" in row:
                    # فرمت RouterOS 7.x: هر ردیف یک سنسور جدا
                    _store(row.get("name", ""), row.get("value"))
                else:
                    # فرمت RouterOS 6.x: یک ردیف تکی با کلیدهای مستقیم
                    for key, value in row.items():
                        if key.startswith("."):
                            continue
                        _store(key, value)
        except Exception:
            # پارس کردن پاسخ هم می‌تونه روی فرمت‌های ناشناخته شکست بخوره؛
            # در بدترین حالت health خالی برمی‌گرده، نه خطا
            pass

        return health

    def get_dhcp_status(self) -> Tuple[List[DhcpServerInfo], List[DhcpLease]]:
        """
        دریافت وضعیت کامل DHCP: لیست سرورها (به‌همراه ظرفیت pool و تعداد
        لیزهای فعال) و لیست کامل لیزها.

        اگر DHCP روی این روتر تعریف نشده باشه یا این منو پشتیبانی نشه،
        دو لیست خالی برمی‌گردونه (بدون خطا) — این قابلیت کاملاً اختیاریه.

        Returns:
            تاپل (لیست DhcpServerInfo، لیست DhcpLease)
        """
        self._ensure_connected()
        try:
            servers = list(self._api("/ip/dhcp-server/print"))
            pools = list(self._api("/ip/pool/print"))
            leases = list(self._api("/ip/dhcp-server/lease/print"))
        except Exception:
            return [], []

        try:
            pool_by_name = {p.get("name", ""): p for p in pools}

            bound_count_by_server: Dict[str, int] = {}
            lease_list: List[DhcpLease] = []
            for lease in leases:
                server_name = lease.get("server", "")
                status = lease.get("status", "")
                if status == "bound":
                    bound_count_by_server[server_name] = bound_count_by_server.get(server_name, 0) + 1
                lease_list.append(
                    DhcpLease(
                        address=lease.get("address", ""),
                        mac_address=lease.get("mac-address", ""),
                        host_name=lease.get("host-name", ""),
                        status=status,
                        server=server_name,
                    )
                )

            server_list: List[DhcpServerInfo] = []
            for s in servers:
                name = s.get("name", "")
                pool_name = s.get("address-pool", "")
                pool_info = pool_by_name.get(pool_name, {})
                pool_size = _count_pool_size(pool_info.get("ranges", ""))
                server_list.append(
                    DhcpServerInfo(
                        name=name,
                        interface=s.get("interface", ""),
                        disabled=str(s.get("disabled", False)).lower() == "true",
                        pool_name=pool_name,
                        pool_size=pool_size,
                        leases_active=bound_count_by_server.get(name, 0),
                        lease_time=s.get("lease-time", ""),
                    )
                )

            return server_list, lease_list
        except Exception:
            return [], []

    # نگاشت نوع تانل -> منوی API مخصوصش. این منوها (برخلاف /interface/print
    # عمومی) فیلد remote-address رو دارن که IP سمت مقابل تانله.
    _TUNNEL_ENDPOINTS = {
        "eoip": "/interface/eoip/print",
        "gre": "/interface/gre/print",
        "ipip": "/interface/ipip/print",
    }

    def get_tunnels(self) -> List[dict]:
        """
        کشف خودکار همه‌ی اینترفیس‌های تانلی روی این روتر (EoIP، GRE، IPIP،
        WireGuard) به‌همراه IP سمت مقابلشون، بدون نیاز به تعریف دستی.

        برای EoIP/GRE/IPIP از فیلد remote-address خود اینترفیس استفاده
        می‌شه. برای WireGuard، چون remote-address روی خود اینترفیس نیست
        (تانل چندنقطه‌ای می‌تونه باشه)، از endpoint هر peer استفاده می‌شه.

        اگه روتر از یک نوع خاص پشتیبانی نکنه (منوش اصلاً وجود نداشته باشه)،
        اون نوع به‌سادگی نادیده گرفته می‌شه؛ اگه کل عملیات شکست بخوره، یک
        لیست خالی برمی‌گرده (بدون خطا) — این قابلیت کاملاً اختیاریه.

        Returns:
            لیستی از دیکشنری‌ها: [{"name", "interface", "type", "ping_target"}, ...]
        """
        try:
            self._ensure_connected()
        except MikrotikConnectionError:
            return []

        tunnels: List[dict] = []

        for tunnel_type, endpoint in self._TUNNEL_ENDPOINTS.items():
            try:
                rows = list(self._api(endpoint))
            except Exception:
                # این نوع تانل روی این مدل/نسخه پشتیبانی نمی‌شه، یا خطای
                # موقتی بود. عمداً Exception عمومی می‌گیریم، چون روی مدل‌ها
                # و نسخه‌های مختلف RouterOS ممکنه نوع خطای متفاوتی رخ بده.
                continue

            for row in rows:
                remote = row.get("remote-address", "")
                name = row.get("name", "")
                if not name or not remote:
                    continue
                tunnels.append({
                    "name": row.get("comment") or name,
                    "interface": name,
                    "type": tunnel_type,
                    "ping_target": remote,
                })

        # WireGuard جداست: IP سمت مقابل توی peers است، نه خود اینترفیس
        try:
            peers = list(self._api("/interface/wireguard/peers/print"))
            for peer in peers:
                iface_name = peer.get("interface", "")
                endpoint_address = (
                    peer.get("current-endpoint-address")
                    or peer.get("endpoint-address")
                    or ""
                )
                if not iface_name or not endpoint_address:
                    continue
                tunnels.append({
                    "name": peer.get("comment") or f"{iface_name} (WireGuard)",
                    "interface": iface_name,
                    "type": "wireguard",
                    "ping_target": endpoint_address,
                })
        except Exception:
            # مثلاً روی RouterOS 6.x که اصلاً منوی WireGuard وجود نداره
            pass

        return tunnels

    def ping(self, address: str, count: int = 4) -> dict:
        """
        اجرای ping از خود روتر به یک آدرس مشخص (مثلاً سمت مقابل یک تانل)،
        برای اندازه‌گیری میانگین تأخیر (latency) و درصد بسته‌ی ازدست‌رفته.

        این کار از طریق دستور /ping در RouterOS API انجام می‌شه که چندین
        پاسخ (یکی به‌ازای هر ping) برمی‌گردونه، نه فقط یکی.

        در صورت هر خطایی، به‌جای پرتاب استثنا، نتیجه‌ای با received=0
        برمی‌گردونه (یعنی "غیرقابل‌دسترس")، چون این قابلیت هم اختیاریه.

        Returns:
            دیکشنری شامل: sent، received، packet_loss_percent، avg_latency_ms
        """
        try:
            self._ensure_connected()
            replies = list(self._api("/ping", address=address, count=count))
        except Exception:
            return {
                "sent": 0,
                "received": 0,
                "packet_loss_percent": 100.0,
                "avg_latency_ms": None,
            }

        sent = len(replies)
        times_ms = []
        for r in replies:
            time_val = r.get("time")
            if time_val is not None:
                times_ms.append(_parse_ros_time_to_ms(time_val))

        received = len(times_ms)
        packet_loss_percent = 0.0 if sent == 0 else round((sent - received) / sent * 100, 1)
        avg_latency_ms = round(sum(times_ms) / len(times_ms), 2) if times_ms else None

        return {
            "sent": sent,
            "received": received,
            "packet_loss_percent": packet_loss_percent,
            "avg_latency_ms": avg_latency_ms,
        }

    # ------------------------------------------------------------------
    # بکاپ‌گیری — این‌ها عملیاتی هستن که کاربر مستقیم درخواستشون می‌ده
    # (با کلیک دکمه)، پس اگه شکست بخورن باید خطای واضح پرتاب بشه، نه
    # اینکه بی‌صدا هیچ‌کاری نکنن.
    # ------------------------------------------------------------------

    def create_binary_backup(self, name: Optional[str] = None) -> str:
        """
        ساخت یک فایل بکاپ باینری کامل (.backup) روی خود روتر، با دستور
        /system/backup/save. این فایل شامل تنظیمات کامل روتر (رمزگذاری‌شده و
        قابل بازیابی فقط روی خود RouterOS) است.

        نکته: این فایل فقط روی حافظه‌ی خود روتر ساخته می‌شه؛ برای دانلودش
        باید جداگانه از طریق FTP یا SFTP گرفته بشه (تابع download_file_via_ftp
        در ماژول api/backup.py).

        Returns:
            اسم فایل ساخته‌شده روی روتر (مثلاً "backup_20260801_143000.backup").
        """
        self._ensure_connected()
        if name is None:
            name = f"backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        try:
            list(self._api("/system/backup/save", name=name))
        except MikrotikConnectionError:
            raise
        except Exception as exc:
            raise MikrotikConnectionError(f"Error creating binary backup: {exc}") from exc

        # ساخت فایل روی برخی مدل‌ها لحظه‌ای نیست؛ کمی صبر می‌کنیم تا مطمئن بشیم آماده‌ست
        time.sleep(1)
        return f"{name}.backup"

    def create_script_export(self, name: Optional[str] = None) -> str:
        """
        ساخت یک فایل خروجی متنی از تنظیمات روتر (.rsc) روی خود روتر، با دستور
        /export. برخلاف بکاپ باینری، این فایل متنی و انسان‌خوان است (شبیه
        دستوراتی که برای بازسازی تنظیمات باید اجرا بشن) و بین مدل‌های مختلف
        RouterOS هم قابل استفاده‌ست (چیزی که بکاپ باینری تضمینش نمی‌کنه).

        Returns:
            اسم فایل ساخته‌شده روی روتر (مثلاً "export_20260801_143000.rsc").
        """
        self._ensure_connected()
        if name is None:
            name = f"export_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        try:
            list(self._api("/export", file=name))
        except MikrotikConnectionError:
            raise
        except Exception as exc:
            raise MikrotikConnectionError(f"Error creating script export: {exc}") from exc

        time.sleep(1)
        return f"{name}.rsc"

    def remove_file(self, filename: str) -> None:
        """
        حذف یک فایل از حافظه‌ی روتر (برای پاک‌سازی بعد از دانلود بکاپ، تا
        فضای روتر با فایل‌های بکاپ قدیمی پر نشه).

        نکته: به‌جای فیلتر کردن سمت روتر با سینتکس query (?name=...)، کل
        لیست فایل‌ها رو می‌گیریم و سمت پایتون فیلتر می‌کنیم. سینتکس query
        خام API با نحوه‌ی تبدیل keyword argument های librouteros سازگار
        نیست و باعث خطای "unknown parameter" می‌شه.
        """
        self._ensure_connected()
        try:
            rows = list(self._api("/file/print"))
            for row in rows:
                if row.get("name") == filename:
                    file_id = row.get(".id")
                    if file_id:
                        list(self._api("/file/remove", **{".id": file_id}))
        except MikrotikConnectionError:
            raise
        except Exception as exc:
            raise MikrotikConnectionError(f"Error removing file '{filename}': {exc}") from exc


def _parse_ros_time_to_ms(value) -> float:
    """
    تبدیل مقدار زمان خام برگشتی از RouterOS ping به میلی‌ثانیه.

    این مقدار بسته به نسخه‌ی RouterOS ممکنه به دو شکل باشه:
    - عدد خام (میکروثانیه) مثل "1200"
    - رشته‌ی ترکیبی مثل "1ms200us" یا "500us"
    این تابع هر دو حالت رو پشتیبانی می‌کنه.
    """
    if value is None:
        return 0.0
    s = str(value)
    if s.isdigit():
        return int(s) / 1000.0

    total_us = 0.0
    for match in re.finditer(r"(\d+)(ms|us|s)", s):
        num, unit = match.groups()
        num = float(num)
        if unit == "ms":
            total_us += num * 1000
        elif unit == "us":
            total_us += num
        elif unit == "s":
            total_us += num * 1_000_000
    return total_us / 1000.0


def _count_pool_size(ranges_str: str) -> int:
    """
    محاسبه‌ی تعداد کل IP های موجود در یک pool، از روی رشته‌ی ranges
    (مثلاً "192.168.1.10-192.168.1.200,192.168.1.210-192.168.1.220").
    """
    if not ranges_str:
        return 0

    total = 0
    for part in str(ranges_str).split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            start, _, end = part.partition("-")
            try:
                start_ip = int(ipaddress.IPv4Address(start.strip()))
                end_ip = int(ipaddress.IPv4Address(end.strip()))
                total += max(0, end_ip - start_ip + 1)
            except ValueError:
                continue
        else:
            try:
                ipaddress.IPv4Address(part)
                total += 1
            except ValueError:
                continue
    return total
