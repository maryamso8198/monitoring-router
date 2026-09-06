"""
اجرای زمان‌بندی‌شده‌ی خودکار بکاپ‌گیری (شبیه یک تسک/cron ساده)، به‌صورت یک
ترد پس‌زمینه‌ی مستقل که هر ۶۰ ثانیه چک می‌کنه آیا وقت اجرای بکاپِ خودکار
کدوم روتر رسیده یا نه.

هر روتر یک زمان‌بندی روزانه دارد (ساعت مشخص، هر روز) که در یک فایل JSON
(پیش‌فرض backup_schedules.json) ذخیره می‌شود تا با ری‌استارت برنامه از بین
نرود. برای جلوگیری از اجرای تکراری در همون روز، تاریخ آخرین اجرا هم
ذخیره می‌شه.

نکته: زمان‌بندی بر اساس ساعت محلی سروری است که برنامه رویش اجرا می‌شود.
"""

import json
import threading
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional

from monitor.backup_manager import BackupManager

DEFAULT_SCHEDULE = {
    "enabled": False,
    "time": "02:00",
    "type": "binary",
    "last_run_date": None,
}


class BackupScheduler:
    """اجرای دوره‌ای بکاپ‌گیری خودکار طبق زمان‌بندی هر روتر."""

    def __init__(
        self,
        routers_config: Dict[str, dict],
        backup_manager: BackupManager,
        schedule_file: str = "backup_schedules.json",
        check_interval_seconds: int = 60,
    ):
        self.routers_config = routers_config
        self.backup_manager = backup_manager
        self.schedule_file = Path(schedule_file)
        self.check_interval_seconds = check_interval_seconds

        self._lock = threading.Lock()
        self._schedules: Dict[str, dict] = {}
        self._load_schedules()

        self._thread: Optional[threading.Thread] = None
        self._stop_event = threading.Event()

    def _load_schedules(self) -> None:
        if not self.schedule_file.exists():
            return
        try:
            with open(self.schedule_file, "r", encoding="utf-8") as f:
                self._schedules = json.load(f)
        except (json.JSONDecodeError, OSError):
            self._schedules = {}

    def _save_schedules(self) -> None:
        try:
            with open(self.schedule_file, "w", encoding="utf-8") as f:
                json.dump(self._schedules, f, indent=2, ensure_ascii=False)
        except OSError:
            pass

    def get_schedule(self, router_id: str) -> dict:
        """دریافت زمان‌بندی فعلی یک روتر (یا مقدار پیش‌فرض، اگه هنوز تنظیم نشده)."""
        with self._lock:
            return dict(self._schedules.get(router_id, DEFAULT_SCHEDULE))

    def get_all_schedules(self) -> Dict[str, dict]:
        with self._lock:
            return {rid: dict(s) for rid, s in self._schedules.items()}

    def set_schedule(self, router_id: str, enabled: bool, time_str: str, backup_type: str) -> None:
        """
        تنظیم/به‌روزرسانی زمان‌بندی یک روتر.

        Args:
            time_str: ساعت به فرمت "HH:MM" (۲۴ ساعته)، مثل "02:00"
            backup_type: "binary"، "script"، یا "both" (هر دو نوع)
        """
        with self._lock:
            existing = self._schedules.get(router_id, {})
            self._schedules[router_id] = {
                "enabled": enabled,
                "time": time_str,
                "type": backup_type,
                "last_run_date": existing.get("last_run_date"),
            }
            self._save_schedules()

    def start(self) -> None:
        self._thread = threading.Thread(target=self._run_loop, daemon=True)
        self._thread.start()

    def stop(self) -> None:
        self._stop_event.set()
        if self._thread is not None:
            self._thread.join(timeout=5)

    def _run_loop(self) -> None:
        while not self._stop_event.is_set():
            try:
                self._check_and_run()
            except Exception as exc:
                print(f"[ERROR] Backup scheduler error: {exc}")
            self._stop_event.wait(self.check_interval_seconds)

    def _check_and_run(self) -> None:
        now = datetime.now()
        current_time_str = now.strftime("%H:%M")
        today_str = now.strftime("%Y-%m-%d")

        with self._lock:
            items = list(self._schedules.items())

        for router_id, sched in items:
            if not sched.get("enabled"):
                continue
            if sched.get("time") != current_time_str:
                continue
            if sched.get("last_run_date") == today_str:
                continue  # امروز قبلاً اجرا شده

            router_cfg = self.routers_config.get(router_id)
            if not router_cfg:
                continue

            backup_type = sched.get("type", "binary")
            types_to_run = ["binary", "script"] if backup_type == "both" else [backup_type]

            for t in types_to_run:
                print(f"[SCHEDULE] Running scheduled backup for {router_id} ({t})")
                self.backup_manager.create_backup(router_id, router_cfg, t, triggered_by="scheduled")

            with self._lock:
                if router_id in self._schedules:
                    self._schedules[router_id]["last_run_date"] = today_str
                    self._save_schedules()
