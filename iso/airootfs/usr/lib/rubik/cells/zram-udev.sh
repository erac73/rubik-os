#!/usr/bin/env bash
# ───────────────────────────────────────────────
# ZRAM udev helper — fallback if face-0 hasn't run
# Called by udev rule 99-rubik-zram.rules
# ───────────────────────────────────────────────
set -euo pipefail

CELL_NAME="zram-udev"
ZRAM_DEV="/dev/zram0"

zram_setup() {
    local dev="${1:-$ZRAM_DEV}"
    if [[ ! -e "$dev" ]]; then
        return 1
    fi
    if grep -q "zram0" /proc/swaps 2>/dev/null; then
        return 0
    fi
    local total_ram
    total_ram=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    local zram_size=$((total_ram * 75 / 100))
    echo "${zram_size}K" > "/sys/block/$(basename "$dev")/disksize" 2>/dev/null || true
    mkswap "$dev" 2>/dev/null || true
    swapon -p 100 "$dev" 2>/dev/null || true
}

cell_start() {
    zram_setup "$ZRAM_DEV"
    echo "ZRAM $ZRAM_DEV configured"
}

cell_stop() {
    swapoff "$ZRAM_DEV" 2>/dev/null || true
}

cell_health() {
    grep -q "zram0" /proc/swaps 2>/dev/null && return 0
    return 1
}

cell_deps() { echo "F0.0"; }

# If executed directly (e.g. by udev rule)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    zram_setup "${1:-$ZRAM_DEV}"
fi
