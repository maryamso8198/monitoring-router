"""
نقطه‌ی ورود اصلی پروژه‌ی مانیتورینگ روتر میکروتیک — نسخه‌ی ترمینال.

نحوه‌ی اجرا:
    python main.py
    python main.py --config config.json
    python main.py --router branch1

قبل از اجرا:
    1. pip install -r requirements.txt
    2. در روتر میکروتیک، سرویس API را فعال کنید:
         /ip service enable api
       (یا برای اتصال امن: /ip service enable api-ssl)
    3. فایل config.json را با آی‌پی، یوزرنیم و پسورد روتر خودتان تنظیم کنید.
"""

import argparse
import json
import logging
import sys
from pathlib import Path

from api.client import MikrotikClient
from monitor.monitor import RouterMonitor


def load_config(path: str) -> dict:
    """خواندن فایل تنظیمات JSON."""
    config_path = Path(path)
    if not config_path.exists():
        print(f"Config file not found: {path}")
        sys.exit(1)

    with open(config_path, "r", encoding="utf-8") as f:
        return json.load(f)


def setup_logging(logging_config: dict) -> None:
    """پیکربندی سیستم لاگ بر اساس تنظیمات."""
    if not logging_config.get("enabled", False):
        logging.basicConfig(level=logging.CRITICAL)  # لاگ‌ها را عملاً خاموش می‌کند
        return

    level_name = logging_config.get("log_level", "INFO").upper()
    level = getattr(logging, level_name, logging.INFO)
    log_file = logging_config.get("log_file", "monitor.log")

    logging.basicConfig(
        filename=log_file,
        level=level,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Live MikroTik router monitoring tool via RouterOS API"
    )
    parser.add_argument(
        "--config",
        "-c",
        default="config.json",
        help="Path to config file (default: config.json)",
    )
    parser.add_argument(
        "--router",
        "-r",
        default=None,
        help="ID of the router to monitor (from the 'routers' list in config.json). "
             "Defaults to the first router in the list. The terminal version can only "
             "monitor one router at a time; use web_main.py to monitor all routers at once.",
    )
    return parser.parse_args()


def resolve_router_config(config: dict, router_id: str = None) -> dict:
    """
    پیدا کردن تنظیمات یک روتر مشخص از بخش 'routers' در config.json.
    نسخه‌ی ترمینال فقط یک روتر رو هم‌زمان نشون می‌ده؛ برای مانیتورینگ
    هم‌زمان همه‌ی شعبه‌ها از web_main.py استفاده کن.
    """
    routers = config.get("routers")

    # سازگاری با فرمت قدیمی (تک‌روتری) برای کسانی که هنوز config.json قدیمی دارن
    if not routers and "router" in config:
        return config["router"]

    if not routers:
        print("No routers defined in config.json under 'routers'.")
        sys.exit(1)

    if router_id is None:
        return routers[0]

    for router_cfg in routers:
        if router_cfg.get("id") == router_id:
            return router_cfg

    print(f"Router id '{router_id}' not found in config.json. Available: "
          f"{[r.get('id') for r in routers]}")
    sys.exit(1)


def main() -> None:
    args = parse_args()
    config = load_config(args.config)

    setup_logging(config.get("logging", {}))

    router_cfg = resolve_router_config(config, args.router)
    monitor_cfg = config.get("monitor", {})

    client = MikrotikClient(
        host=router_cfg["host"],
        username=router_cfg["username"],
        password=router_cfg.get("password", ""),
        port=router_cfg.get("port", 8728),
        use_ssl=router_cfg.get("use_ssl", False),
        ssl_port=router_cfg.get("ssl_port", 8729),
        timeout=router_cfg.get("timeout", 10),
    )

    interface_filter = None
    if not monitor_cfg.get("monitor_all_interfaces", True):
        interface_filter = monitor_cfg.get("interfaces", [])

    router_id = router_cfg.get("id", "default")
    print(f"Monitoring router: {router_cfg.get('name', router_id)} ({router_cfg['host']})")

    monitor = RouterMonitor(
        client=client,
        refresh_interval=monitor_cfg.get("refresh_interval", 2),
        interface_filter=interface_filter,
        clear_screen_each_refresh=monitor_cfg.get("clear_screen_each_refresh", True),
        traffic_limit_mb=monitor_cfg.get("traffic_limit_mb"),
        interface_limits_mb=monitor_cfg.get("interface_limits_mb", {}),
        comment_limits_mb=monitor_cfg.get("comment_limits_mb", {}),
        traffic_state_file=f"traffic_totals_{router_id}.json",
        tunnel_monitoring_enabled=monitor_cfg.get("tunnel_monitoring_enabled", True),
        tunnel_check_interval=monitor_cfg.get("tunnel_check_interval", 30),
        dhcp_enabled=monitor_cfg.get("dhcp_enabled", True),
    )

    monitor.run()


if __name__ == "__main__":
    main()
