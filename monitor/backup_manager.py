"""
مدیریت بکاپ‌های ذخیره‌شده روی سرور: ساخت، ذخیره‌ی دائمی روی دیسک، و
نگهداری تاریخچه (چه دستی از داشبورد، چه زمان‌بندی‌شده‌ی خودکار)، تا کاربر
بتونه از داشبورد وب بکاپ‌های قبلی رو ببینه و دوباره دانلودشون کنه.

هر بکاپ توی backups/<router_id>/<timestamp>_<type>.<ext> ذخیره می‌شه، و
یک ردیف توی backup_history.json ثبت می‌شه.
"""

import json
import threading
import uuid
from datetime import datetime
from pathlib import Path
from typing import List, Optional

from api.client import MikrotikClient, MikrotikConnectionError
from api.backup import download_file_via_ftp, FtpDownloadError

# حداکثر تعداد رکورد تاریخچه که نگه داشته می‌شه (برای همه‌ی روترها روی هم)
MAX_HISTORY_ENTRIES = 2000


class BackupManager:
    """ساخت، ذخیره‌ی دائمی، و نگه‌داری تاریخچه‌ی بکاپ‌های همه‌ی روترها."""

    def __init__(self, backups_dir: str = "backups", history_file: str = "backup_history.json"):
        self.backups_dir = Path(backups_dir)
        self.backups_dir.mkdir(parents=True, exist_ok=True)
        self.history_file = Path(history_file)

        self._lock = threading.Lock()
        self._history: List[dict] = []
        self._load_history()

    def _load_history(self) -> None:
        if not self.history_file.exists():
            return
        try:
            with open(self.history_file, "r", encoding="utf-8") as f:
                self._history = json.load(f)
        except (json.JSONDecodeError, OSError):
            self._history = []

    def _save_history(self) -> None:
        try:
            with open(self.history_file, "w", encoding="utf-8") as f:
                json.dump(self._history, f, indent=2, ensure_ascii=False)
        except OSError:
            pass

    def create_backup(
        self,
        router_id: str,
        router_cfg: dict,
        backup_type: str,
        triggered_by: str = "manual",
    ) -> dict:
        """
        ساخت بکاپ واقعی (اتصال موقت جدا، دستور بکاپ/اکسپورت، دانلود از FTP،
        پاک‌سازی فایل موقت روی روتر)، ذخیره‌ی دائمی محتوا روی دیسک سرور، و
        ثبت یک ردیف در تاریخچه.

        این متد هیچ‌وقت استثنا پرتاب نمی‌کنه — چون هم از مسیر دستی (کلیک
        دکمه در داشبورد) و هم از زمان‌بند خودکار صدا زده می‌شه؛ در صورت
        شکست، یک entry با status='failed' و پیام خطا برمی‌گردونه.

        Args:
            router_id: شناسه‌ی روتر (برای مسیر ذخیره‌سازی و تاریخچه)
            router_cfg: دیکشنری تنظیمات اتصال (host/username/password/...)
            backup_type: "binary" یا "script"
            triggered_by: "manual" یا "scheduled" (برای نمایش در تاریخچه)
        """
        entry_id = uuid.uuid4().hex[:12]
        now = datetime.now()
        created_at = now.strftime("%Y-%m-%d %H:%M:%S")
        timestamp = now.strftime("%Y%m%d_%H%M%S")
        extension = "rsc" if backup_type == "script" else "backup"
        local_filename = f"{timestamp}_{backup_type}.{extension}"

        router_dir = self.backups_dir / router_id
        router_dir.mkdir(parents=True, exist_ok=True)
        local_path = router_dir / local_filename

        entry = {
            "id": entry_id,
            "router_id": router_id,
            "type": backup_type,
            "filename": local_filename,
            "created_at": created_at,
            "triggered_by": triggered_by,
            "status": "success",
            "size_bytes": 0,
            "error": None,
        }

        client = MikrotikClient(
            host=router_cfg["host"],
            username=router_cfg["username"],
            password=router_cfg.get("password", ""),
            port=router_cfg.get("port", 8728),
            use_ssl=router_cfg.get("use_ssl", False),
            ssl_port=router_cfg.get("ssl_port", 8729),
            timeout=router_cfg.get("timeout", 10),
        )

        try:
            client.connect()

            if backup_type == "script":
                remote_filename = client.create_script_export(name=timestamp)
            else:
                remote_filename = client.create_binary_backup(name=timestamp)

            file_bytes = download_file_via_ftp(
                host=router_cfg["host"],
                username=router_cfg["username"],
                password=router_cfg.get("password", ""),
                remote_filename=remote_filename,
                port=router_cfg.get("ftp_port", 25),
            )
            client.remove_file(remote_filename)

            with open(local_path, "wb") as f:
                f.write(file_bytes)

            entry["size_bytes"] = len(file_bytes)

        except (MikrotikConnectionError, FtpDownloadError) as exc:
            entry["status"] = "failed"
            entry["error"] = str(exc)
        except Exception as exc:
            entry["status"] = "failed"
            entry["error"] = f"Unexpected error: {exc}"
        finally:
            client.close()

        with self._lock:
            self._history.insert(0, entry)
            self._history = self._history[:MAX_HISTORY_ENTRIES]
            self._save_history()

        return entry

    def get_history(self, router_id: Optional[str] = None) -> List[dict]:
        """تاریخچه‌ی بکاپ‌ها (جدیدترین اول)، اختیاری فیلتر بر اساس روتر."""
        with self._lock:
            if router_id:
                return [e for e in self._history if e["router_id"] == router_id]
            return list(self._history)

    def get_backup_file_path(self, entry_id: str) -> Optional[Path]:
        """پیدا کردن مسیر فایل ذخیره‌شده روی دیسک برای یک entry مشخص."""
        with self._lock:
            for e in self._history:
                if e["id"] == entry_id:
                    path = self.backups_dir / e["router_id"] / e["filename"]
                    return path if path.exists() else None
        return None
