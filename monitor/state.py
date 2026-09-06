"""
نگه‌دارنده‌ی آخرین وضعیت دریافتی از روتر به‌صورت thread-safe.

این کلاس واسط بین ترد پس‌زمینه‌ای که مرتب از روتر داده می‌گیرد (BackgroundMonitor)
و وب‌سرور Flask است که این داده را برای نمایش در مرورگر برمی‌گرداند. چون دو ترد
مختلف (ترد پولینگ و تردهای هندلر Flask) به این داده دسترسی دارند، از یک قفل
(threading.Lock) برای جلوگیری از رقابت داده (race condition) استفاده شده است.

این کلاس همچنین یک صف کوچک از «نوتیفیکیشن‌های اخیر» (مثلاً اتصال دستگاه جدید،
عبور از لیمیت ترافیک) نگه می‌دارد تا داشبورد وب بتواند آن‌ها را به‌صورت toast
نمایش دهد، نه فقط در کنسول سرور.
"""

import threading
from datetime import datetime
from typing import List, Optional

from models.router import (
    RouterIdentity,
    SystemResource,
    InterfaceStats,
    SystemHealth,
    TunnelStatus,
    DhcpServerInfo,
    DhcpLease,
)

MAX_NOTIFICATIONS = 50


class SharedRouterState:
    """محل نگهداری امن (thread-safe) آخرین داده‌ی دریافتی از روتر."""

    def __init__(self):
        self._lock = threading.Lock()
        self._identity: Optional[RouterIdentity] = None
        self._resource: Optional[SystemResource] = None
        self._interfaces: List[InterfaceStats] = []
        self._health: Optional[SystemHealth] = None
        self._tunnels: List[TunnelStatus] = []
        self._dhcp_servers: List[DhcpServerInfo] = []
        self._dhcp_leases: List[DhcpLease] = []
        self._last_updated: Optional[datetime] = None
        self._last_error: Optional[str] = None

        # صف نوتیفیکیشن‌ها برای نمایش toast در داشبورد وب
        self._notifications: List[dict] = []
        self._notification_counter: int = 0

    def update(
        self,
        identity: RouterIdentity,
        resource: SystemResource,
        interfaces: List[InterfaceStats],
        health: Optional[SystemHealth] = None,
        tunnels: Optional[List[TunnelStatus]] = None,
        dhcp_servers: Optional[List[DhcpServerInfo]] = None,
        dhcp_leases: Optional[List[DhcpLease]] = None,
    ) -> None:
        """ذخیره‌ی یک نمونه‌ی تازه از داده (بعد از یک poll موفق)."""
        with self._lock:
            self._identity = identity
            self._resource = resource
            self._interfaces = interfaces
            self._health = health
            self._tunnels = tunnels or []
            self._dhcp_servers = dhcp_servers or []
            self._dhcp_leases = dhcp_leases or []
            self._last_updated = datetime.now()
            self._last_error = None

    def set_error(self, message: str) -> None:
        """ثبت خطای آخرین poll (مثلاً قطعی اتصال به روتر)."""
        with self._lock:
            self._last_error = message

    def add_notification(self, message: str, notif_type: str = "info") -> None:
        """
        افزودن یک نوتیفیکیشن به صف (مثلاً «دستگاه جدید وصل شد» یا «لیمیت
        ترافیک رد شد»)، که داشبورد وب می‌تونه به‌صورت toast نشونش بده.

        فقط آخرین MAX_NOTIFICATIONS مورد نگه داشته می‌شه تا حافظه بی‌نهایت
        بزرگ نشه (چون این پروژه ممکنه هفته‌ها بدون ری‌استارت اجرا بمونه).
        """
        with self._lock:
            self._notification_counter += 1
            self._notifications.append({
                "id": self._notification_counter,
                "type": notif_type,
                "message": message,
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            })
            if len(self._notifications) > MAX_NOTIFICATIONS:
                self._notifications = self._notifications[-MAX_NOTIFICATIONS:]

    def to_dict(self) -> dict:
        """خروجی JSON-friendly از وضعیت فعلی، برای ارسال به فرانت‌اند."""
        with self._lock:
            notifications = list(self._notifications)

            if self._identity is None or self._resource is None:
                return {
                    "connected": False,
                    "error": self._last_error or "No data received yet.",
                    "notifications": notifications,
                }

            return {
                "connected": self._last_error is None,
                "error": self._last_error,
                "last_updated": self._last_updated.strftime("%Y-%m-%d %H:%M:%S")
                if self._last_updated
                else None,
                "identity": {
                    "name": self._identity.name,
                    "board_name": self._resource.board_name,
                    "version": self._resource.version,
                    "uptime": self._resource.uptime,
                },
                "resource": {
                    "cpu_load": self._resource.cpu_load,
                    "memory_usage_percent": self._resource.memory_usage_percent,
                    "disk_usage_percent": self._resource.disk_usage_percent,
                    "free_memory": self._resource.free_memory,
                    "total_memory": self._resource.total_memory,
                    "free_hdd_space": self._resource.free_hdd_space,
                    "total_hdd_space": self._resource.total_hdd_space,
                },
                "interfaces": [
                    {
                        "name": iface.name,
                        "running": iface.running,
                        "disabled": iface.disabled,
                        "rx_bps": iface.rx_bps,
                        "tx_bps": iface.tx_bps,
                        "rx_byte": iface.rx_byte,
                        "tx_byte": iface.tx_byte,
                        "total_rx_bytes": iface.total_rx_bytes,
                        "total_tx_bytes": iface.total_tx_bytes,
                        "total_bytes": iface.total_bytes,
                        "limit_mb": iface.limit_mb,
                        "limit_exceeded": iface.limit_exceeded,
                    }
                    for iface in self._interfaces
                ],
                "health": {
                    "has_data": self._health.has_data if self._health else False,
                    "voltage": self._health.voltage if self._health else None,
                    "temperature": self._health.temperature if self._health else None,
                },
                "tunnels": [
                    {
                        "name": t.name,
                        "interface": t.interface,
                        "ping_target": t.ping_target,
                        "interface_up": t.interface_up,
                        "interface_found": t.interface_found,
                        "reachable": t.reachable,
                        "avg_latency_ms": t.avg_latency_ms,
                        "packet_loss_percent": t.packet_loss_percent,
                        "last_checked": t.last_checked,
                    }
                    for t in self._tunnels
                ],
                "dhcp": {
                    "servers": [
                        {
                            "name": s.name,
                            "interface": s.interface,
                            "disabled": s.disabled,
                            "pool_name": s.pool_name,
                            "pool_size": s.pool_size,
                            "leases_active": s.leases_active,
                            "utilization_percent": s.utilization_percent,
                            "lease_time": s.lease_time,
                        }
                        for s in self._dhcp_servers
                    ],
                    "leases": [
                        {
                            "address": l.address,
                            "mac_address": l.mac_address,
                            "host_name": l.host_name,
                            "status": l.status,
                            "server": l.server,
                        }
                        for l in self._dhcp_leases
                    ],
                },
                "notifications": notifications,
            }
