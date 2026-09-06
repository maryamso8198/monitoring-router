"""
اپلیکیشن وب (Flask) برای نمایش داشبورد مانیتورینگ روتر در مرورگر.

نکته‌ی امنیتی مهم: یوزرنیم/پسوردی که اینجا برای لاگین استفاده می‌شود،
کاملاً مجزا از یوزرنیم/پسورد اتصال به روتر است. این‌ها فقط کنترل می‌کنند
چه کسی اجازه دارد داشبورد وب را در مرورگر ببیند.

این اپ به‌صورت مستقیم به روتر وصل نمی‌شود؛ داده را از SharedRouterState هر
روتر می‌خواند که توسط BackgroundMonitor مربوطه (در ترد جدا) به‌روزرسانی می‌شود.

پشتیبانی چند-روتری: پارامتر routers یک دیکشنری است که هر کلیدش شناسه‌ی یک
روتر (مثلاً "branch1") و مقدارش شامل name (اسم نمایشی)، state
(SharedRouterState)، traffic_monitor (برای دکمه‌ی ریست) و config (تنظیمات
خام اتصال، برای ساخت کانکشن موقت بکاپ‌گیری) است.
"""

import functools
import io
from datetime import datetime
from typing import Dict, Optional

from flask import Flask, render_template, request, redirect, url_for, session, jsonify, send_file

from api.client import MikrotikClient, MikrotikConnectionError
from api.backup import download_file_via_ftp, FtpDownloadError
from monitor.state import SharedRouterState
from monitor.traffic import TrafficMonitor
from monitor.backup_manager import BackupManager
from monitor.backup_scheduler import BackupScheduler


def login_required(view_func):
    """دکوریتور برای محافظت از route هایی که نیاز به لاگین دارند."""

    @functools.wraps(view_func)
    def wrapped(*args, **kwargs):
        if not session.get("logged_in"):
            return redirect(url_for("login", next=request.path))
        return view_func(*args, **kwargs)

    return wrapped


def create_app(
    web_config: dict,
    routers: Dict[str, dict],
    backup_manager: BackupManager,
    backup_scheduler: BackupScheduler,
    refresh_interval: int = 2,
) -> Flask:
    """
    ساخت اپلیکیشن Flask با پشتیبانی چند روتر.

    Args:
        web_config: دیکشنری شامل username، password و secret_key برای لاگین وب.
        routers: دیکشنری {router_id: {"name", "state", "traffic_monitor", "config"}}
        backup_manager: مسئول ساخت/ذخیره/تاریخچه‌ی بکاپ‌ها.
        backup_scheduler: مسئول زمان‌بندی خودکار بکاپ‌گیری.
        refresh_interval: فاصله‌ی رفرش خودکار داشبورد در مرورگر (ثانیه).
    """
    app = Flask(__name__)
    app.secret_key = web_config.get("secret_key", "please-change-this-secret-key")

    web_username = web_config.get("username", "admin")
    web_password = web_config.get("password", "admin")

    router_ids_ordered = list(routers.keys())
    default_router_id = router_ids_ordered[0] if router_ids_ordered else None

    def _get_router_id_from_request() -> Optional[str]:
        """اسم روتر رو از query string (GET) یا JSON body (POST) می‌گیره."""
        router_id = request.args.get("router")
        if router_id is None and request.is_json:
            router_id = (request.get_json(silent=True) or {}).get("router")
        return router_id or default_router_id

    @app.route("/", methods=["GET"])
    def index():
        if session.get("logged_in"):
            return redirect(url_for("home"))
        return redirect(url_for("login"))

    @app.route("/home", methods=["GET"])
    @login_required
    def home():
        """صفحه‌ی فرود بعد از لاگین: انتخاب بین «مانیتورینگ» و «بکاپ روتر»."""
        return render_template("home.html", username=session.get("username", ""))

    @app.route("/login", methods=["GET", "POST"])
    def login():
        error: Optional[str] = None

        if request.method == "POST":
            username = request.form.get("username", "")
            password = request.form.get("password", "")

            if username == web_username and password == web_password:
                session["logged_in"] = True
                session["username"] = username
                next_url = request.args.get("next") or url_for("home")
                return redirect(next_url)

            error = "Invalid username or password."

        return render_template("login.html", error=error)

    @app.route("/logout", methods=["POST"])
    def logout():
        session.clear()
        return redirect(url_for("login"))

    @app.route("/dashboard", methods=["GET"])
    @login_required
    def dashboard():
        router_list = [
            {"id": rid, "name": info.get("name", rid)} for rid, info in routers.items()
        ]
        return render_template(
            "dashboard.html",
            username=session.get("username", ""),
            refresh_interval=refresh_interval,
            routers=router_list,
            default_router_id=default_router_id,
        )

    @app.route("/backups", methods=["GET"])
    @login_required
    def backups_page():
        """صفحه‌ی مدیریت بکاپ: دکمه‌های گرفتن بکاپ، تاریخچه، و زمان‌بند خودکار."""
        router_list = [
            {"id": rid, "name": info.get("name", rid)} for rid, info in routers.items()
        ]
        return render_template(
            "backups.html",
            username=session.get("username", ""),
            routers=router_list,
            default_router_id=default_router_id,
        )

    @app.route("/api/routers", methods=["GET"])
    @login_required
    def api_routers():
        return jsonify(
            [{"id": rid, "name": info.get("name", rid)} for rid, info in routers.items()]
        )

    @app.route("/api/data", methods=["GET"])
    @login_required
    def api_data():
        router_id = _get_router_id_from_request()
        info = routers.get(router_id)
        if info is None:
            return jsonify({"connected": False, "error": f"Unknown router: {router_id}"}), 404
        return jsonify(info["state"].to_dict())

    @app.route("/api/reset-traffic", methods=["POST"])
    @login_required
    def reset_traffic():
        router_id = _get_router_id_from_request()
        info = routers.get(router_id)
        if info is None:
            return jsonify({"success": False, "error": f"Unknown router: {router_id}"}), 404

        traffic_monitor: Optional[TrafficMonitor] = info.get("traffic_monitor")
        if traffic_monitor is None:
            return jsonify({"success": False, "error": "Traffic monitor not available."}), 500

        interface_name = None
        if request.is_json:
            interface_name = (request.get_json(silent=True) or {}).get("interface")

        traffic_monitor.reset_totals(interface_name)
        return jsonify({
            "success": True,
            "router": router_id,
            "reset_interface": interface_name or "all",
        })

    @app.route("/api/backup", methods=["POST"])
    @login_required
    def backup():
        """
        ساخت بکاپ روتر (باینری .backup یا اسکریپت .rsc) از طریق BackupManager:
        اتصال موقت جدا، ساخت فایل روی روتر، دانلود از FTP، پاک‌سازی فایل موقت
        روی روتر، **ذخیره‌ی دائمی روی دیسک سرور** (برای تاریخچه)، و در پایان
        همون فایل مستقیماً برای دانلود به مرورگر فرستاده می‌شه.
        """
        body = request.get_json(silent=True) or {}
        router_id = body.get("router") or default_router_id
        backup_type = body.get("type", "binary")  # "binary" یا "script"

        info = routers.get(router_id)
        if info is None:
            return jsonify({"success": False, "error": f"Unknown router: {router_id}"}), 404

        router_cfg = info.get("config")
        if router_cfg is None:
            return jsonify({"success": False, "error": "Router config not available for backup."}), 500

        entry = backup_manager.create_backup(router_id, router_cfg, backup_type, triggered_by="manual")

        if entry["status"] != "success":
            error_msg = entry.get("error") or "Unknown error"
            if "ftp" in error_msg.lower() or "FtpDownloadError" in error_msg:
                error_msg += " (make sure FTP service is enabled on the router: /ip service enable ftp)"
            return jsonify({"success": False, "error": error_msg}), 500

        file_path = backup_manager.get_backup_file_path(entry["id"])
        if file_path is None:
            return jsonify({"success": False, "error": "Backup was created but the file could not be found."}), 500

        mimetype = "text/plain" if backup_type == "script" else "application/octet-stream"
        download_name = f"{router_id}_{entry['filename']}"

        return send_file(
            str(file_path),
            as_attachment=True,
            download_name=download_name,
            mimetype=mimetype,
        )

    @app.route("/api/backup-history", methods=["GET"])
    @login_required
    def api_backup_history():
        router_id = request.args.get("router")
        history = backup_manager.get_history(router_id)
        return jsonify(history)

    @app.route("/api/backup-download/<entry_id>", methods=["GET"])
    @login_required
    def api_backup_download(entry_id):
        file_path = backup_manager.get_backup_file_path(entry_id)
        if file_path is None:
            return jsonify({"error": "Backup file not found (it may have been deleted)."}), 404

        history = backup_manager.get_history()
        entry = next((e for e in history if e["id"] == entry_id), None)
        router_id = entry["router_id"] if entry else "router"
        filename = entry["filename"] if entry else file_path.name

        mimetype = "text/plain" if file_path.suffix == ".rsc" else "application/octet-stream"
        return send_file(
            str(file_path),
            as_attachment=True,
            download_name=f"{router_id}_{filename}",
            mimetype=mimetype,
        )

    @app.route("/api/backup-schedule", methods=["GET"])
    @login_required
    def api_backup_schedule_get():
        router_id = _get_router_id_from_request()
        if router_id is None:
            return jsonify({"error": "No router specified."}), 400
        return jsonify(backup_scheduler.get_schedule(router_id))

    @app.route("/api/backup-schedule", methods=["POST"])
    @login_required
    def api_backup_schedule_set():
        body = request.get_json(silent=True) or {}
        router_id = body.get("router") or default_router_id
        if router_id is None or router_id not in routers:
            return jsonify({"success": False, "error": f"Unknown router: {router_id}"}), 404

        enabled = bool(body.get("enabled", False))
        time_str = body.get("time", "02:00")
        backup_type = body.get("type", "binary")

        if backup_type not in ("binary", "script", "both"):
            return jsonify({"success": False, "error": "Invalid backup type."}), 400

        backup_scheduler.set_schedule(router_id, enabled, time_str, backup_type)
        return jsonify({"success": True, "schedule": backup_scheduler.get_schedule(router_id)})

    return app
