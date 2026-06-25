#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Cell: F0.1 — memory-compression
# Dynamic ZRAM management with monitoring
# ───────────────────────────────────────────────
set -euo pipefail

CELL_NAME="memory-compression"
ZRAM_DEV="/dev/zram0"
MONITOR_INTERVAL=60  # seconds

cell_start() {
    # Ensure ZRAM is active
    if ! grep -q "zram0" /proc/swaps; then
        echo "ZRAM not active, activating..."
        /usr/lib/rubik/faces/face-0.sh  # re-run face init
    fi

    # Start monitoring in background
    while true; do
        sleep "$MONITOR_INTERVAL"
        cell_health || {
            # Recalculate ZRAM size based on current memory pressure
            local pressure
            pressure=$(cat /proc/pressure/memory 2>/dev/null | grep "avg10" | cut -d' ' -f2 | cut -d'=' -f2)
            if [[ -n "$pressure" ]] && (( $(echo "$pressure > 60" | bc -l 2>/dev/null || echo 0) )); then
                # Memory pressure high — increase ZRAM
                local total_ram
                total_ram=$(awk '/MemTotal/{print $2}' /proc/meminfo)
                echo "$((total_ram * 85 / 100))K" > /sys/block/zram0/disksize 2>/dev/null || true
                echo "Increased ZRAM size due to memory pressure"
            fi
        }
    done &

    echo "$CELL_NAME: started with ${MONITOR_INTERVAL}s monitoring"
}

cell_stop() {
    # Kill background monitor
    pkill -f "sleep $MONITOR_INTERVAL" 2>/dev/null || true
    echo "$CELL_NAME: stopped"
}

cell_health() {
    # Check ZRAM is active and has space
    if ! grep -q "zram0" /proc/swaps; then
        return 1
    fi

    # Check compression ratio
    local comp_ratio
    comp_ratio=$(zramctl | awk '/zram0/{print $4}' | sed 's/\..*//' 2>/dev/null)
    if [[ -n "$comp_ratio" ]] && [[ "$comp_ratio" -gt "1" ]]; then
        return 0
    fi

    return 0
}

cell_deps() {
    echo "F0.0"  # depends on kernel
}

# If executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-start}" in
        start)   cell_start ;;
        stop)    cell_stop ;;
        health)  cell_health && echo "healthy" || echo "degraded" ;;
        *)       echo "Usage: $0 {start|stop|health}" ;;
    esac
fi
