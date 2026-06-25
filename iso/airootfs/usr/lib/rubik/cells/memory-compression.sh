#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Cell: F0.1 — memory-compression
# Dynamic ZRAM management with monitoring
# ───────────────────────────────────────────────
set -euo pipefail

CELL_NAME="memory-compression"
ZRAM_DEV="/dev/zram0"
MONITOR_INTERVAL=60  # seconds
MONITOR_PID_FILE="/run/rubik/${CELL_NAME}.pid"

cell_start() {
    # Ensure ZRAM is active
    if ! grep -q "zram0" /proc/swaps 2>/dev/null; then
        echo "ZRAM not active, activating..."
        /usr/lib/rubik/faces/face-0.sh 2>/dev/null || true
    fi

    # Start monitoring in background with PID tracking
    (
        while true; do
            sleep "$MONITOR_INTERVAL"
            if ! cell_health 2>/dev/null; then
                # Recalculate ZRAM size based on current memory pressure
                local pressure
                pressure=$(cat /proc/pressure/memory 2>/dev/null | grep "avg10" | cut -d' ' -f2 | cut -d'=' -f2)
                if [[ -n "$pressure" ]] && (( $(echo "$pressure > 60" | bc -l 2>/dev/null || echo 0) )); then
                    # Memory pressure high — increase ZRAM (swapoff first to resize)
                    swapoff "$ZRAM_DEV" 2>/dev/null || true
                    local total_ram
                    total_ram=$(awk '/MemTotal/{print $2}' /proc/meminfo)
                    echo "$((total_ram * 85 / 100))K" > /sys/block/zram0/disksize 2>/dev/null || true
                    mkswap "$ZRAM_DEV" 2>/dev/null || true
                    swapon "$ZRAM_DEV" -p 100 2>/dev/null || true
                    echo "Increased ZRAM size due to memory pressure"
                fi
            fi
        done
    ) &
    echo $! > "$MONITOR_PID_FILE"

    echo "$CELL_NAME: started with ${MONITOR_INTERVAL}s monitoring (PID $(cat "$MONITOR_PID_FILE"))"
}

cell_stop() {
    if [[ -f "$MONITOR_PID_FILE" ]]; then
        local pid
        pid=$(cat "$MONITOR_PID_FILE")
        kill "$pid" 2>/dev/null || true
        rm -f "$MONITOR_PID_FILE"
    fi
    echo "$CELL_NAME: stopped"
}

cell_health() {
    # Check ZRAM is active
    if ! grep -q "zram0" /proc/swaps 2>/dev/null; then
        return 1
    fi

    # Check compression ratio — degraded if < 1
    local comp_ratio
    comp_ratio=$(zramctl 2>/dev/null | awk '/zram0/{print $4}' | sed 's/\..*//')
    if [[ -n "$comp_ratio" ]]; then
        [[ "$comp_ratio" -ge "1" ]] && return 0 || return 1
    fi

    return 1
}

cell_deps() {
    echo "F0.0"
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
