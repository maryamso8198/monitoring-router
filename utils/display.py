"""
توابع نمایش داشبورد مانیتورینگ در ترمینال (کنسول).
"""

import os
from datetime import datetime
from typing import List, Optional

from models.router import (
    RouterIdentity,
    SystemResource,
    InterfaceStats,
    SystemHealth,
    TunnelStatus,
    DhcpServerInfo,
)
from utils.formatter import format_bytes, format_bps, format_percent_bar, format_gigabytes


def clear_screen() -> None:
    """پاک کردن صفحه‌ی ترمینال (سازگار با ویندوز و لینوکس/مک)."""
    os.system("cls" if os.name == "nt" else "clear")


def print_dashboard(
    identity: RouterIdentity,
    resource: SystemResource,
    interfaces: List[InterfaceStats],
    health: Optional[SystemHealth] = None,
    tunnels: Optional[List[TunnelStatus]] = None,
    dhcp_servers: Optional[List[DhcpServerInfo]] = None,
    clear: bool = True,
) -> None:
    """چاپ یک داشبورد متنی از وضعیت روتر در ترمینال."""
    if clear:
        clear_screen()

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    width = 70

    print("=" * width)
    print(f" MikroTik Router Monitor — {now}")
    print("=" * width)
    print(f" Router Name   : {identity.name or '-'}")
    print(f" Board Model   : {resource.board_name or '-'}")
    print(f" RouterOS Ver. : {resource.version or '-'}")
    print(f" Uptime        : {resource.uptime or '-'}")
    print("-" * width)
    print(f" CPU   : {format_percent_bar(resource.cpu_load)}")
    print(f" RAM   : {format_percent_bar(resource.memory_usage_percent)}"
          f"  ({format_bytes(resource.total_memory - resource.free_memory)} /"
          f" {format_bytes(resource.total_memory)})")
    print(f" Disk  : {format_percent_bar(resource.disk_usage_percent)}"
          f"  ({format_bytes(resource.total_hdd_space - resource.free_hdd_space)} /"
          f" {format_bytes(resource.total_hdd_space)})")

    if health is not None:
        print("-" * width)
        if health.has_data:
            voltage_str = f"{health.voltage:.1f} V" if health.voltage is not None else "N/A"
            temp_str = f"{health.temperature:.1f} °C" if health.temperature is not None else "N/A"
            print(f" Voltage        : {voltage_str}")
            print(f" Board Temp.    : {temp_str}")
        else:
            print(" Health sensors : N/A (no physical sensors reported by this router)")

    print("-" * width)
    print(f" {'Interface':<12}{'Status':<10}{'RX':<14}{'TX':<14}{'Total (GB)':<14}")
    print("-" * width)

    for iface in interfaces:
        status = "UP" if iface.running and not iface.disabled else "DOWN"
        rx = format_bps(iface.rx_bps)
        tx = format_bps(iface.tx_bps)
        total = format_gigabytes(iface.total_bytes)
        print(f" {iface.name:<12}{status:<10}{rx:<14}{tx:<14}{total:<14}")

    if tunnels:
        print("-" * width)
        print(f" {'Tunnel':<16}{'Iface':<10}{'Reach':<8}{'Latency':<12}{'Loss':<8}")
        print("-" * width)
        for t in tunnels:
            if not t.interface_found:
                iface_status = "N/A"
            else:
                iface_status = "UP" if t.interface_up else "DOWN"
            reach = "?" if t.reachable is None else ("OK" if t.reachable else "FAIL")
            latency = f"{t.avg_latency_ms:.1f} ms" if t.avg_latency_ms is not None else "-"
            loss = f"{t.packet_loss_percent:.0f}%" if t.packet_loss_percent is not None else "-"
            print(f" {t.name:<16}{iface_status:<10}{reach:<8}{latency:<12}{loss:<8}")

    if dhcp_servers:
        print("-" * width)
        print(f" {'DHCP Server':<14}{'Pool':<12}{'Used/Total':<14}{'Usage':<10}")
        print("-" * width)
        for s in dhcp_servers:
            used_total = f"{s.leases_active}/{s.pool_size}"
            usage = f"{s.utilization_percent:.1f}%"
            print(f" {s.name:<14}{s.pool_name:<12}{used_total:<14}{usage:<10}")

    print("=" * width)
    print(" Press Ctrl+C to exit.")
