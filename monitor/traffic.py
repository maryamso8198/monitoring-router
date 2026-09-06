"""
محاسبه‌ی نرخ لحظه‌ای ترافیک (bps) و نگهداری مجموع کل ترافیک رد و بدل شده
(RX/TX) هر اینترفیس، به‌صورتی که در برابر ریست شدن شمارنده‌ی روتر (مثلاً بعد
از خاموش/روشن شدن) و همچنین ری‌استارت شدن خود برنامه‌ی مانیتورینگ مقاوم است.

میکروتیک مقادیر rx-byte و tx-byte را به‌صورت شمارنده‌ی تجمعی از زمان روشن
شدن روتر برمی‌گرداند. اگر روتر خاموش/روشن شود، این شمارنده از صفر شروع
می‌شود و مقدار قبلی از دست می‌رود. برای جلوگیری از این اتفاق، هر بار که
ریست شدن شمارنده تشخیص داده شود، مقدار قبلی به یک offset دائمی اضافه
می‌شود؛ این offset در یک فایل JSON روی دیسک ذخیره می‌شود تا حتی با
بسته و باز شدن مجدد برنامه هم از بین نرود.
"""

import json
import threading
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from models.router import InterfaceStats


class TrafficMonitor:
    """
    نگه‌دارنده‌ی حالت بین نمونه‌برداری‌های متوالی، برای محاسبه‌ی:
      - نرخ لحظه‌ای ترافیک هر اینترفیس (rx_bps / tx_bps)
      - مجموع کل ترافیک رد و بدل شده (total_rx_bytes / total_tx_bytes)،
        که در برابر ریست شدن شمارنده‌ی روتر مقاوم است و در فایل ذخیره می‌شود.

    استفاده:
        tm = TrafficMonitor(state_file="traffic_totals.json")
        interfaces = tm.update(interfaces)
        # اکنون rx_bps/tx_bps و total_rx_bytes/total_tx_bytes پر شده‌اند.
    """

    def __init__(self, state_file: Optional[str] = "traffic_totals.json"):
        # کلید: نام اینترفیس -> (timestamp, rx_byte, tx_byte) — برای محاسبه‌ی نرخ لحظه‌ای
        self._last_sample: Dict[str, Tuple[float, int, int]] = {}

        # کلید: نام اینترفیس -> آخرین مقدار خام rx/tx که از روتر دیده شده
        self._last_raw: Dict[str, Tuple[int, int]] = {}

        # کلید: نام اینترفیس -> (مجموع rx از بوت‌های قبلی روتر, مجموع tx از بوت‌های قبلی روتر)
        # این مقدار همان offset دائمی است که در فایل ذخیره می‌شود.
        self._base_offset: Dict[str, Tuple[int, int]] = {}

        self.state_file = Path(state_file) if state_file else None

        # چون از این پس هم ترد پس‌زمینه‌ی مانیتورینگ (update) و هم درخواست‌های
        # وب (دکمه‌ی ریست، reset_totals) ممکنه هم‌زمان به این داده‌ها دسترسی
        # داشته باشن، از یک قفل برای جلوگیری از رقابت داده استفاده می‌کنیم.
        self._lock = threading.Lock()

        self._load_state()

    def _load_state(self) -> None:
        """بارگذاری offset های ذخیره‌شده از فایل (در صورت وجود)."""
        if not self.state_file or not self.state_file.exists():
            return
        try:
            with open(self.state_file, "r", encoding="utf-8") as f:
                data = json.load(f)
            for name, values in data.items():
                self._base_offset[name] = (
                    int(values.get("base_rx", 0)),
                    int(values.get("base_tx", 0)),
                )
                if "last_rx" in values and "last_tx" in values:
                    self._last_raw[name] = (int(values["last_rx"]), int(values["last_tx"]))
        except (json.JSONDecodeError, OSError, ValueError):
            # فایل خراب یا ناقص بود؛ از صفر شروع می‌کنیم به‌جای کرش کردن برنامه
            pass

    def _save_state(self) -> None:
        """ذخیره‌ی offset های فعلی روی دیسک تا با ری‌استارت برنامه از بین نرود."""
        if not self.state_file:
            return
        data = {}
        for name, (last_rx, last_tx) in self._last_raw.items():
            base_rx, base_tx = self._base_offset.get(name, (0, 0))
            data[name] = {
                "base_rx": base_rx,
                "base_tx": base_tx,
                "last_rx": last_rx,
                "last_tx": last_tx,
            }
        try:
            with open(self.state_file, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
        except OSError:
            # اگه نتونستیم فایل رو بنویسیم (مثلاً مشکل دسترسی)، برنامه رو نگه می‌داریم
            # و فقط داده‌ی این دور رو از دست می‌دیم، نه کل برنامه رو
            pass

    def update(self, interfaces: List[InterfaceStats]) -> List[InterfaceStats]:
        """
        دریافت لیست تازه‌ای از آمار خام اینترفیس‌ها، محاسبه‌ی نرخ لحظه‌ای و
        به‌روزرسانی مجموع کل ترافیک (total_rx_bytes/total_tx_bytes)، سپس
        ذخیره‌ی وضعیت روی دیسک.
        """
        now = time.monotonic()

        with self._lock:
            for iface in interfaces:
                prev_sample = self._last_sample.get(iface.name)
                last_raw = self._last_raw.get(iface.name)
                base_rx, base_tx = self._base_offset.get(iface.name, (0, 0))

                # تشخیص ریست شدن شمارنده‌ی روتر (خاموش/روشن شدن روتر)
                if last_raw is not None:
                    last_rx, last_tx = last_raw
                    if iface.rx_byte < last_rx or iface.tx_byte < last_tx:
                        base_rx += last_rx
                        base_tx += last_tx
                        self._base_offset[iface.name] = (base_rx, base_tx)

                # محاسبه‌ی نرخ لحظه‌ای (bps) بین دو نمونه‌ی متوالی
                if prev_sample is not None:
                    prev_time, prev_rx, prev_tx = prev_sample
                    elapsed = now - prev_time

                    delta_rx = iface.rx_byte - prev_rx
                    delta_tx = iface.tx_byte - prev_tx
                    if delta_rx < 0:
                        delta_rx = iface.rx_byte
                    if delta_tx < 0:
                        delta_tx = iface.tx_byte

                    if elapsed > 0:
                        iface.rx_bps = (delta_rx * 8) / elapsed
                        iface.tx_bps = (delta_tx * 8) / elapsed

                # مجموع کل ترافیک = offset (بوت‌های قبلی + ریست‌های دستی) + شمارنده‌ی خام فعلی روتر
                iface.total_rx_bytes = base_rx + iface.rx_byte
                iface.total_tx_bytes = base_tx + iface.tx_byte

                self._last_raw[iface.name] = (iface.rx_byte, iface.tx_byte)
                self._last_sample[iface.name] = (now, iface.rx_byte, iface.tx_byte)

            self._save_state()

        return interfaces

    def reset_totals(self, interface_name: Optional[str] = None) -> None:
        """
        ریست کردن مجموع کل ترافیک (مثل صفر کردن تریپ‌متر ماشین).

        بعد از فراخوانی، total_rx_bytes/total_tx_bytes از همون تیک بعدی
        تقریباً صفر می‌شن و از اون لحظه دوباره شمارش می‌شن — نه اینکه فقط
        فایل پاک بشه و عدد فعلیِ خامِ روتر (که صفر نیست) نمایش داده بشه.

        این کار با تنظیم offset منفی برابر با آخرین مقدار خام دیده‌شده انجام
        می‌شه، طوری که total = base_offset + rx_byte خام = 0 بشه. این مقاومت
        در برابر ریبوت بعدی روتر رو هم خراب نمی‌کنه، چون منطق تشخیص ریست
        در update() مستقل از این عمل می‌کنه.

        Args:
            interface_name: اگه مشخص بشه، فقط همون اینترفیس ریست می‌شه.
                             اگه None باشه (پیش‌فرض)، همه‌ی اینترفیس‌ها ریست می‌شن.
        """
        with self._lock:
            names = [interface_name] if interface_name else list(self._last_raw.keys())

            for name in names:
                last_raw = self._last_raw.get(name)
                if last_raw is None:
                    continue
                last_rx, last_tx = last_raw
                self._base_offset[name] = (-last_rx, -last_tx)

            self._save_state()
