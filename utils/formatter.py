"""
توابع کمکی برای فرمت‌دهی خوانا از اعداد خام (بایت، بیت بر ثانیه، آپ‌تایم و ...).
"""


def format_bytes(num_bytes: float) -> str:
    """تبدیل تعداد بایت خام به رشته‌ی خوانا (مثلاً 1.5 GB)."""
    value = float(num_bytes)
    for unit in ["B", "KB", "MB", "GB", "TB"]:
        if value < 1024.0:
            return f"{value:.1f} {unit}"
        value /= 1024.0
    return f"{value:.1f} PB"


def format_megabytes(num_bytes: float, decimals: int = 2) -> str:
    """
    تبدیل تعداد بایت خام به مگابایت با واحد ثابت (بدون تغییر خودکار به KB/GB).
    مثال: format_megabytes(15728640) -> '15.00 MB'
    """
    mb = float(num_bytes) / (1024 * 1024)
    return f"{mb:.{decimals}f} MB"


def format_gigabytes(num_bytes: float, decimals: int = 2) -> str:
    """
    تبدیل تعداد بایت خام به گیگابایت با واحد ثابت (بدون تغییر خودکار به KB/MB).
    مثال: format_gigabytes(1610612736) -> '1.50 GB'
    """
    gb = float(num_bytes) / (1024 * 1024 * 1024)
    return f"{gb:.{decimals}f} GB"


def format_bps(bits_per_second: float) -> str:
    """تبدیل نرخ بیت بر ثانیه به رشته‌ی خوانا (مثلاً 12.3 Mbps)."""
    value = float(bits_per_second)
    for unit in ["bps", "Kbps", "Mbps", "Gbps"]:
        if value < 1000.0:
            return f"{value:.1f} {unit}"
        value /= 1000.0
    return f"{value:.1f} Tbps"


def format_uptime(uptime_str: str) -> str:
    """
    خروجی uptime خام RouterOS معمولاً به شکلی مثل '1w2d3h4m5s' است.
    این تابع فعلاً همان رشته را برمی‌گرداند اما نقطه‌ی مرکزی برای
    تغییر فرمت در آینده است (مثلاً تبدیل به فارسی).
    """
    return uptime_str or "-"


def format_percent_bar(percent: float, width: int = 20) -> str:
    """رسم یک نوار پیشرفت متنی ساده برای نمایش درصد (مثلاً CPU یا RAM)."""
    percent = max(0.0, min(100.0, percent))
    filled = int(width * percent / 100)
    bar = "#" * filled + "-" * (width - filled)
    return f"[{bar}] {percent:5.1f}%"
