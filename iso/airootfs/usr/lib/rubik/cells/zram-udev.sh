#!/usr/bin/env bash
# ───────────────────────────────────────────────
# ZRAM udev helper — calculates ZRAM size dynamically
# Called by udev rule 99-rubik-zram.rules
# ───────────────────────────────────────────────
set -euo pipefail

ZRAM_DEV="${1:-/dev/zram0}"

if [[ ! -e "$ZRAM_DEV" ]]; then
    exit 0
fi

# Get total RAM in KB
total_ram=$(awk '/MemTotal/{print $2}' /proc/meminfo)

# ZRAM = 75% of total RAM
zram_size=$((total_ram * 75 / 100))

# Set ZRAM size
echo "${zram_size}K" > "/sys/block/$(basename "$ZRAM_DEV")/disksize" 2>/dev/null || true

# Format as swap
mkswap "$ZRAM_DEV" 2>/dev/null || true
swapon -p 100 "$ZRAM_DEV" 2>/dev/null || true
