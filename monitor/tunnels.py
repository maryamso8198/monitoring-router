"""
مانیتورینگ وضعیت تانل‌های بین شعبه‌ها — کاملاً خودکار.

TunnelMonitor نیازی به تعریف دستی تانل‌ها در config.json ندارد. مثل
اینترفیس‌ها، لیست تانل‌ها مستقیماً از خود روتر کشف می‌شود (client.get_tunnels()).

دو نوع داده با سرعت‌های متفاوت رفرش می‌شن:
  - وضعیت اینترفیس (up/down): هر تیک عادی، رایگان (از داده‌ای که در همون
    تیک برای بقیه‌ی داشبورد هم گرفته می‌شه)
  - کشف تانل‌ها + ping واقعی: فقط هر check_interval_seconds (پیش‌فرض ۳۰
    ثانیه)، چون این عملیات چند درخواست اضافه به روتر می‌زنه و ping هم کنده
"""

import time
from datetime import datetime
from typing import Dict, List

from api.client import MikrotikClient, MikrotikConnectionError
from models.router import InterfaceStats, TunnelStatus


class TunnelMonitor:
    """کشف خودکار و مانیتورینگ دوره‌ای وضعیت تانل‌ها."""

    def __init__(self, check_interval_seconds: float = 30.0):
        """
        Args:
            check_interval_seconds: فاصله‌ی زمانی بین دو دور کامل کشف تانل +
                ping (به ثانیه). وضعیت اینترفیس مستقل از این، هر تیک آپدیت می‌شه.
        """
        self.check_interval_seconds = check_interval_seconds

        # کلید: اسم اینترفیس تانل -> آخرین وضعیت شناخته‌شده
        self._statuses: Dict[str, TunnelStatus] = {}
        self._last_check_time: float = 0.0

    def update(self, client: MikrotikClient, interfaces: List[InterfaceStats]) -> List[TunnelStatus]:
        """
        به‌روزرسانی وضعیت همه‌ی تانل‌های شناخته‌شده (یا تازه‌کشف‌شده).
        """
        now = time.monotonic()
        interfaces_by_name = {iface.name: iface for iface in interfaces}

        do_full_check = (
            not self._statuses
            or (now - self._last_check_time) >= self.check_interval_seconds
        )

        if do_full_check:
            self._last_check_time = now
            try:
                discovered = client.get_tunnels()
            except Exception:
                # لایه‌ی محافظتی اضافه: حتی اگه get_tunnels به هر دلیل غیرمنتظره‌ای
                # خطا بده، نباید کل TunnelMonitor (و در نتیجه کل تیک مانیتورینگ) رو بخوابونه
                discovered = None

            if discovered is not None:
                discovered_by_iface = {t["interface"]: t for t in discovered}

                # حذف تانل‌هایی که دیگه روی روتر وجود ندارن (مثلاً پاک شدن)
                for iface_name in list(self._statuses.keys()):
                    if iface_name not in discovered_by_iface:
                        del self._statuses[iface_name]

                # افزودن تانل‌های جدید / آپدیت اسم و IP تانل‌های موجود
                for iface_name, t in discovered_by_iface.items():
                    status = self._statuses.get(iface_name)
                    if status is None:
                        self._statuses[iface_name] = TunnelStatus(
                            name=t["name"],
                            interface=iface_name,
                            ping_target=t["ping_target"],
                        )
                    else:
                        status.name = t["name"]
                        status.ping_target = t["ping_target"]

        # وضعیت اینترفیس (up/down) همیشه، هر تیک، رایگان آپدیت می‌شه
        for status in self._statuses.values():
            iface = interfaces_by_name.get(status.interface)
            if iface is not None:
                status.interface_found = True
                status.interface_up = iface.running and not iface.disabled
            else:
                status.interface_found = False
                status.interface_up = False

        # ping واقعی فقط در همون دور کامل (چون کنده)
        if do_full_check:
            for status in self._statuses.values():
                try:
                    result = client.ping(status.ping_target, count=4)
                    status.reachable = result["received"] > 0
                    status.avg_latency_ms = result["avg_latency_ms"]
                    status.packet_loss_percent = result["packet_loss_percent"]
                    status.last_checked = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                except Exception:
                    status.reachable = None

        return list(self._statuses.values())
