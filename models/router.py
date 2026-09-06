"""
مدل‌های داده (Data Models) پروژه.

این ماژول ساختارهای داده‌ای را تعریف می‌کند که اطلاعات دریافتی از API میکروتیک
(RouterOS API) را به شکل شیء‌های پایتونی با فیلدهای مشخص نگه می‌دارند.
استفاده از dataclass باعث می‌شود بقیه‌ی کد به‌جای کار مستقیم با دیکشنری‌های خام API،
با اشیای تایپ‌دار و خواناتر کار کند.
"""

from dataclasses import dataclass, field
from datetime import datetime
from typing import Dict, Optional


@dataclass
class RouterIdentity:
    """اطلاعات هویتی روتر (نام روتر، مدل، نسخه‌ی RouterOS)."""

    name: str
    board_name: str = ""
    version: str = ""
    uptime: str = ""


@dataclass
class SystemResource:
    """اطلاعات منابع سیستمی روتر (CPU، RAM، دیسک و ...)."""

    cpu_load: int = 0            # درصد مصرف CPU
    free_memory: int = 0         # حافظه‌ی آزاد (بایت)
    total_memory: int = 0        # کل حافظه (بایت)
    free_hdd_space: int = 0      # فضای آزاد دیسک/فلش (بایت)
    total_hdd_space: int = 0     # کل فضای دیسک/فلش (بایت)
    uptime: str = ""
    board_name: str = ""
    version: str = ""

    @property
    def memory_usage_percent(self) -> float:
        """درصد مصرف حافظه."""
        if self.total_memory == 0:
            return 0.0
        used = self.total_memory - self.free_memory
        return round((used / self.total_memory) * 100, 1)

    @property
    def disk_usage_percent(self) -> float:
        """درصد مصرف فضای دیسک."""
        if self.total_hdd_space == 0:
            return 0.0
        used = self.total_hdd_space - self.free_hdd_space
        return round((used / self.total_hdd_space) * 100, 1)


@dataclass
class InterfaceStats:
    """
    آمار لحظه‌ای یک اینترفیس شبکه.

    مقادیر rx_byte و tx_byte مقادیر تجمعی (کل بایت‌های دریافتی/ارسالی از زمان
    روشن شدن روتر) هستند. نرخ لحظه‌ای (bps) در ماژول monitor/traffic.py
    با مقایسه‌ی دو نمونه‌برداری متوالی محاسبه می‌شود.
    """

    name: str
    running: bool = False
    disabled: bool = False
    rx_byte: int = 0
    tx_byte: int = 0
    rx_packet: int = 0
    tx_packet: int = 0
    rx_error: int = 0
    tx_error: int = 0
    rx_drop: int = 0
    tx_drop: int = 0
    mac_address: str = ""
    comment: str = ""

    # نرخ لحظه‌ای، بعد از محاسبه در TrafficMonitor پر می‌شود (بیت بر ثانیه)
    rx_bps: float = 0.0
    tx_bps: float = 0.0

    # مجموع کل ترافیک رد و بدل شده‌ی این اینترفیس از زمان روشن شدن روتر تا الان.
    # این مقدار در برابر ریست شدن شمارنده‌ی روتر (خاموش/روشن شدن) مقاوم است؛
    # چون TrafficMonitor مقدار قبل از ریست را روی دیسک ذخیره و به این عدد اضافه می‌کند.
    total_rx_bytes: int = 0
    total_tx_bytes: int = 0

    @property
    def total_bytes(self) -> int:
        """مجموع کل ترافیک (RX + TX) این اینترفیس."""
        return self.total_rx_bytes + self.total_tx_bytes

    # وضعیت لیمیت ترافیک — در monitor/limits.py محاسبه می‌شود
    limit_mb: Optional[float] = None   # لیمیت تعریف‌شده برای این اینترفیس (مگابایت)، اگه تعریف نشده None
    limit_exceeded: bool = False       # آیا total_bytes از limit_mb رد شده یا نه

    timestamp: datetime = None


@dataclass
class SystemHealth:
    """
    اطلاعات سلامت سخت‌افزاری روتر (ولتاژ و دمای بورد) از /system/health.

    نکته‌ی مهم: این مقادیر فقط روی روترهای فیزیکی با سنسور واقعی پر می‌شوند.
    روی CHR (Cloud Hosted Router) که یک ماشین مجازیه، یا مدل‌هایی که این
    منو را پشتیبانی نمی‌کنند، معمولاً این فیلدها خالی/None باقی می‌مانند.
    """

    voltage: Optional[float] = None            # ولتاژ ورودی برق (ولت)
    temperature: Optional[float] = None         # دمای بورد (سانتی‌گراد)

    # سایر سنسورهایی که مدل نشدن، برای دسترسی خام
    raw: Dict[str, float] = field(default_factory=dict)

    @property
    def has_data(self) -> bool:
        """آیا اصلاً هیچ داده‌ی سلامتی از روتر دریافت شده یا نه."""
        return bool(self.raw)


@dataclass
class TunnelStatus:
    """
    وضعیت یک تانل بین شعبه‌ها (کشف‌شده به‌صورت خودکار از خود روتر).

    دو منبع اطلاعات مستقل با هم ترکیب می‌شن:
      - interface_up: از وضعیت خود اینترفیس تانل (running/disabled) — لحظه‌ای
      - reachable/avg_latency_ms/packet_loss_percent: از یک ping دوره‌ای به
        سمت مقابل تانل — چون گاهی اینترفیس "بالا"ست ولی مسیر واقعی قطعه
        (مخصوصاً روی GRE/EoIP که stateless هستن)
    """

    name: str                  # اسم نمایشی
    interface: str              # اسم اینترفیس تانل روی این روتر
    ping_target: str            # IP سمت مقابل تانل که بهش ping می‌زنیم

    interface_up: bool = False
    interface_found: bool = True

    reachable: Optional[bool] = None
    avg_latency_ms: Optional[float] = None
    packet_loss_percent: Optional[float] = None
    last_checked: Optional[str] = None


@dataclass
class DhcpServerInfo:
    """اطلاعات یک DHCP سرور و وضعیت اشغال pool مرتبط باهاش."""

    name: str
    interface: str = ""
    disabled: bool = False
    pool_name: str = ""
    pool_size: int = 0
    leases_active: int = 0
    lease_time: str = ""

    @property
    def utilization_percent(self) -> float:
        """درصد اشغال pool."""
        if self.pool_size == 0:
            return 0.0
        return round(self.leases_active / self.pool_size * 100, 1)


@dataclass
class DhcpLease:
    """یک لیز DHCP (یک دستگاه متصل)."""

    address: str
    mac_address: str = ""
    host_name: str = ""
    status: str = ""     # "bound", "waiting", ...
    server: str = ""
