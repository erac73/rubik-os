#!/usr/bin/env bash
# cell: F1.7 - Early boot initramfs setup
CELL_NAME="initramfs"

cell_start() {
    mkdir -p /run/rubik /var/log/rubik /var/cache/rubik
    dmesg -n 3 2>/dev/null || true
    sysctl -w kernel.printk="3 3 3 3" 2>/dev/null || true
    sysctl -w vm.min_free_kbytes=65536 2>/dev/null || true
    sysctl -w kernel.nmi_watchdog=0 2>/dev/null || true
    echo "Initramfs: runtime dirs, quiet kernel, min_free=64MB"
}

cell_stop() {
    rm -rf /run/rubik 2>/dev/null || true
}

cell_health() {
    [ -d /run/rubik ] && [ -d /var/log/rubik ] && return 0
    return 1
}

cell_deps() { echo "F1.0"; }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-start}" in
        start)   cell_start ;;
        stop)    cell_stop ;;
        health)  cell_health && echo "healthy" || echo "degraded" ;;
        *)       echo "Usage: $0 {start|stop|health}" ;;
    esac
fi
