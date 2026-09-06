"""
بررسی لیمیت ترافیک هر اینترفیس و تشخیص لحظه‌ی عبور از آستانه.

TrafficLimitChecker برای هر اینترفیس یک سقف (به مگابایت) در نظر می‌گیرد،
به این ترتیب اولویت (اول هر کدوم پیدا بشه همون استفاده می‌شه):

  1. interface_limits_mb  -> تطبیق دقیق بر اساس نام اینترفیس (مثلاً "ether1")
  2. comment_limits_mb    -> تطبیق بر اساس وجود یک کلمه‌ی کلیدی در کامنت
                             اینترفیس (case-insensitive)، مثلاً هر اینترفیسی
                             که کامنتش شامل "vpn" باشه
  3. default_limit_mb     -> لیمیت سراسری، اگه هیچ‌کدوم از بالا تطبیق نداشت

اگه هیچ‌کدوم تعریف نشده باشه (None)، اون اینترفیس اصلاً چک نمی‌شه.

نکته‌ی مهم: نوتیفیکیشن فقط در لحظه‌ی «عبور کردن» از لیمیت صادر می‌شود (لبه‌ی
بالارونده)، نه در هر تیک، تا اسپم نشه. اگه یه اینترفیس رد شده از لیمیت مانده،
تا وقتی که برنامه دوباره اجرا نشه یا لیمیتش عوض نشه، دوباره نوتیف نمی‌ده.
"""

from typing import Dict, List, Optional

from models.router import InterfaceStats

BYTES_PER_MB = 1024 * 1024


class TrafficLimitChecker:
    """بررسی لیمیت ترافیک و تشخیص لحظه‌ی عبور از آستانه برای هر اینترفیس."""

    def __init__(
        self,
        default_limit_mb: Optional[float] = None,
        interface_limits_mb: Optional[Dict[str, float]] = None,
        comment_limits_mb: Optional[Dict[str, float]] = None,
    ):
        self.default_limit_mb = default_limit_mb
        self.interface_limits_mb = interface_limits_mb or {}
        # کلید: بخشی از متن کامنت (کوچک‌نویس) -> لیمیت به مگابایت
        self.comment_limits_mb = {
            keyword.lower(): limit for keyword, limit in (comment_limits_mb or {}).items()
        }

        # اسم اینترفیس‌هایی که همین الان در وضعیت "رد شده از لیمیت" هستن
        # (برای جلوگیری از نوتیف تکراری در هر تیک)
        self._already_notified: set = set()

    def get_limit_mb(self, iface: InterfaceStats) -> Optional[float]:
        """
        لیمیت مربوط به یک اینترفیس خاص، با اولویت:
        نام دقیق اینترفیس > کلمه‌ی کلیدی در کامنت > لیمیت سراسری.
        """
        if iface.name in self.interface_limits_mb:
            return self.interface_limits_mb[iface.name]

        comment_lower = (iface.comment or "").lower()
        for keyword, limit in self.comment_limits_mb.items():
            if keyword in comment_lower:
                return limit

        return self.default_limit_mb

    def check(self, interfaces: List[InterfaceStats]) -> List[InterfaceStats]:
        """
        بررسی لیمیت هر اینترفیس، پر کردن iface.limit_mb و iface.limit_exceeded،
        و بازگرداندن لیست اینترفیس‌هایی که *در همین تیک* تازه از لیمیت رد شدن
        (برای صدور نوتیفیکیشن).
        """
        newly_exceeded: List[InterfaceStats] = []

        for iface in interfaces:
            limit_mb = self.get_limit_mb(iface)
            iface.limit_mb = limit_mb

            if limit_mb is None:
                iface.limit_exceeded = False
                self._already_notified.discard(iface.name)
                continue

            total_mb = iface.total_bytes / BYTES_PER_MB
            exceeded = total_mb > limit_mb
            iface.limit_exceeded = exceeded

            if exceeded and iface.name not in self._already_notified:
                self._already_notified.add(iface.name)
                newly_exceeded.append(iface)
            elif not exceeded and iface.name in self._already_notified:
                self._already_notified.discard(iface.name)

        return newly_exceeded
