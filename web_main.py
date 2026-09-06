"""
نقطه‌ی ورود نسخه‌ی وب پروژه‌ی مانیتورینگ روتر میکروتیک — نسخه‌ی چند-روتری.

برخلاف main.py (که یک داشبورد متنی در ترمینال و فقط یک روتر را نمایش می‌دهد)،
این فایل یک وب‌سرور Flask بالا می‌آورد که همه‌ی روترهای تعریف‌شده در
config.json (بخش "routers") را هم‌زمان و هرکدام در یک ترد جدا مانیتور
می‌کند، و در داشبورد وب با تب/انتخاب‌گر بین آن‌ها سوییچ می‌کنی.

نحوه‌ی اجرا:
    python web_main.py
    python web_main.py --config config.json

بعد از اجرا، در مرورگر برو به:
    http://127.0.0.1:8080

قبل از اجرا:
    1. pip install -r requirements.txt
    2. بخش "routers" در config.json را با اطلاعات هر شعبه (id، name، host،
       username، password) کامل کن. هر روتر باید یک id یکتا داشته باشد.
    3. یوزرنیم/پسورد بخش "web" برای ورود به داشبورد است (جدا از پسورد روترها).
"""

import logging
import sys

from main import load_config, setup_logging
from api.client import MikrotikClient
from monitor.state import SharedRouterState
from monitor.background import BackgroundMonitor
from monitor.backup_manager import BackupManager
from monitor.backup_scheduler import BackupScheduler
from web.app import create_app

logger = logging.getLogger("mikrotik_monitor.web_main")


def build_routers(config: dict) -> tuple:
    """
    ساخت یک BackgroundMonitor مستقل (با ترد پس‌زمینه‌ی خودش) به‌ازای هر روتر
    تعریف‌شده در config["routers"]، و بازگرداندن دیکشنری‌ای که create_app
    برای serve کردن داده‌ی هر روتر لازم دارد.
    """
    monitor_cfg = config.get("monitor", {})
    refresh_interval = monitor_cfg.get("refresh_interval", 2)

    interface_filter = None
    if not monitor_cfg.get("monitor_all_interfaces", True):
        interface_filter = monitor_cfg.get("interfaces", [])

    routers_config = config.get("routers")
    if not routers_config:
        print("No routers defined in config.json under 'routers'.")
        sys.exit(1)

    routers = {}
    backgrounds = []

    seen_ids = set()
    for router_cfg in routers_config:
        router_id = router_cfg.get("id")
        if not router_id:
            print(f"Skipping a router entry without an 'id': {router_cfg}")
            continue
        if router_id in seen_ids:
            print(f"Duplicate router id '{router_id}' in config.json — skipping duplicate.")
            continue
        seen_ids.add(router_id)

        display_name = router_cfg.get("name", router_id)

        client = MikrotikClient(
            host=router_cfg["host"],
            username=router_cfg["username"],
            password=router_cfg.get("password", ""),
            port=router_cfg.get("port", 8728),
            use_ssl=router_cfg.get("use_ssl", False),
            ssl_port=router_cfg.get("ssl_port", 8729),
            timeout=router_cfg.get("timeout", 10),
        )

        state = SharedRouterState()

        # هر روتر فایل ذخیره‌ی ترافیک مخصوص به خودش رو داره (namespaced با
        # router_id)، وگرنه اسم اینترفیس‌های یکسان بین شعبه‌ها قاطی می‌شه.
        # تانل‌ها دیگه نیازی به تعریف دستی ندارن — خودکار از خود روتر کشف می‌شن.
        background = BackgroundMonitor(
            client=client,
            state=state,
            refresh_interval=refresh_interval,
            interface_filter=interface_filter,
            traffic_limit_mb=monitor_cfg.get("traffic_limit_mb"),
            interface_limits_mb=monitor_cfg.get("interface_limits_mb", {}),
            comment_limits_mb=monitor_cfg.get("comment_limits_mb", {}),
            traffic_state_file=f"traffic_totals_{router_id}.json",
            router_id=router_id,
            tunnel_monitoring_enabled=monitor_cfg.get("tunnel_monitoring_enabled", True),
            tunnel_check_interval=monitor_cfg.get("tunnel_check_interval", 30),
            dhcp_enabled=monitor_cfg.get("dhcp_enabled", True),
        )
        background.start()
        backgrounds.append(background)

        routers[router_id] = {
            "name": display_name,
            "state": state,
            "traffic_monitor": background.traffic_monitor,
            "config": router_cfg,
        }

    return routers, backgrounds


def main() -> None:
    config_path = "config.json"
    if len(sys.argv) > 1 and sys.argv[1] in ("--config", "-c"):
        if len(sys.argv) < 3:
            print("Usage: python web_main.py --config path/to/config.json")
            sys.exit(1)
        config_path = sys.argv[2]

    config = load_config(config_path)
    setup_logging(config.get("logging", {}))

    web_cfg = config.get("web", {})
    if not web_cfg.get("enabled", True):
        print("The 'web' section in config.json is disabled (enabled: false).")
        sys.exit(0)

    monitor_cfg = config.get("monitor", {})
    refresh_interval = monitor_cfg.get("refresh_interval", 2)

    routers, backgrounds = build_routers(config)
    print(f"Monitoring {len(routers)} router(s): {', '.join(routers.keys())}")

    # دیکشنری ساده‌ی {router_id: router_cfg} که BackupManager/BackupScheduler لازم دارن
    routers_raw_config = {rid: info["config"] for rid, info in routers.items()}

    backup_manager = BackupManager(backups_dir="backups", history_file="backup_history.json")
    backup_scheduler = BackupScheduler(
        routers_config=routers_raw_config,
        backup_manager=backup_manager,
        schedule_file="backup_schedules.json",
    )
    backup_scheduler.start()

    # اپ Flask که داده‌های هر روتر رو serve می‌کنه
    app = create_app(
        web_cfg,
        routers,
        backup_manager=backup_manager,
        backup_scheduler=backup_scheduler,
        refresh_interval=refresh_interval,
    )

    host = web_cfg.get("host", "0.0.0.0")
    port = web_cfg.get("port", 5000)

    print(f"Web dashboard running at: http://{host}:{port}")
    print("Press Ctrl+C to stop.")

    try:
        app.run(host=host, port=port, debug=False, use_reloader=False)
    finally:
        for background in backgrounds:
            background.stop()
        backup_scheduler.stop()


if __name__ == "__main__":
    main()
