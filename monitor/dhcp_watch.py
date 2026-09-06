"""
تشخیص لحظه‌ی اتصال یک دستگاه جدید در بین لیزهای DHCP.

DhcpLeaseWatcher لیست لیزها رو هر تیک می‌گیره و اونایی که «فعال» (status=bound)
و «دارای هاست‌نیم» هستن رو دنبال می‌کنه. هر بار که یه لیز تازه وارد این حالت
بشه (قبلاً نبوده، الان هست)، به‌عنوان یک اتصال تازه گزارش می‌شه — دقیقاً مثل
منطق TrafficLimitChecker (نوتیف فقط در لحظه‌ی عبور، نه هر تیک، تا اسپم نشه).
"""

from typing import List, Set

from models.router import DhcpLease


class DhcpLeaseWatcher:
    """تشخیص لحظه‌ی اتصال دستگاه‌های جدید (لیز فعال + دارای هاست‌نیم)."""

    def __init__(self):
        # کلید: mac_address (یا در نبودش، address) لیزهایی که الان می‌دونیم فعالن
        self._known_active: Set[str] = set()

    def check(self, leases: List[DhcpLease]) -> List[DhcpLease]:
        """
        بررسی لیزهای فعلی و بازگرداندن لیست لیزهایی که *در همین فراخوانی*
        تازه به حالت «فعال + دارای هاست‌نیم» رسیدن.
        """
        newly_connected: List[DhcpLease] = []
        current_active: Set[str] = set()

        for lease in leases:
            if lease.status != "bound" or not lease.host_name:
                continue

            key = lease.mac_address or lease.address
            current_active.add(key)

            if key not in self._known_active:
                newly_connected.append(lease)

        self._known_active = current_active
        return newly_connected
