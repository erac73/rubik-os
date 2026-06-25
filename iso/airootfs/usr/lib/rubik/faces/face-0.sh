#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Face 0 — Kernel & Memory Initialization
# Called by rubikd during boot sequence
# ───────────────────────────────────────────────
set -euo pipefail

RUBIK_CONFIG="${RUBIK_CONFIG:-/etc/rubik}"
LOG_TAG="rubik-face0"

log() { echo "[$LOG_TAG] $1"; }

# ── F0.1: ZRAM Setup ──────────────────────────
setup_zram() {
    local total_ram
    total_ram=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    local zram_size=$((total_ram * 75 / 100))  # 75% of RAM for ZRAM

    log "Setting up ZRAM: ${zram_size}KB (${total_ram}KB RAM)"

    # Load module
    modprobe zram num_devices=1 2>/dev/null || true

    # Configure ZRAM device
    echo "zstd" > /sys/block/zram0/comp_algorithm 2>/dev/null || true
    echo "${zram_size}K" > /sys/block/zram0/disksize 2>/dev/null || true

    # Use as swap
    mkswap /dev/zram0 2>/dev/null || true
    swapon -p 100 /dev/zram0 2>/dev/null || true

    log "ZRAM activated: $(zramctl | grep zram0)"
}

# ── F0.2: Dynamic Swap Management ─────────────
setup_swap() {
    # Create swapfile if no swap partition exists
    if ! swapon --show | grep -qv "zram"; then
        local swapfile="/swapfile"
        if [[ ! -f "$swapfile" ]]; then
            log "Creating swapfile: 512MB"
            dd if=/dev/zero of="$swapfile" bs=1M count=512 status=none
            chmod 600 "$swapfile"
            mkswap "$swapfile" >/dev/null
        fi
        swapon -p 50 "$swapfile" 2>/dev/null || true
        log "Swapfile activated"
    fi
}

# ── F0.3: OOM Guard ──────────────────────────
setup_oom() {
    # earlyoom configuration
    if command -v earlyoom &>/dev/null; then
        # Notify at 20% free, kill at 10% free
        # Prefer killing processes with higher OOM score
        earlyoom -m 20,10 -s 30,20 -r 5 -p &
        log "earlyoom started (notify: 20%, kill: 10%)"
    fi
}

# ── F0.4: Hugepages ──────────────────────────
setup_hugepages() {
    # Set THP to madvise (only when applications request it)
    if [[ -f /sys/kernel/mm/transparent_hugepage/enabled ]]; then
        echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
        log "THP set to madvise"
    fi
}

# ── F0.5: Cache Tuning ───────────────────────
setup_cache() {
    local total_ram_kb
    total_ram_kb=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    local min_free=$((total_ram_kb / 100))  # 1% of RAM

    # Set min_free_kbytes dynamically
    echo "$min_free" > /proc/sys/vm/min_free_kbytes 2>/dev/null || true
    log "vm.min_free_kbytes = $min_free"
}

# ── F0.7: CPU Governor ───────────────────────
setup_cpu_gov() {
    local governor="conservative"

    # Check if schedutil is available (modern kernels)
    if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]]; then
        if grep -q "schedutil" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors; then
            governor="schedutil"
        fi
    fi

    # Apply to all CPUs
    for cpu_gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$governor" > "$cpu_gov" 2>/dev/null || true
    done

    log "CPU governor set to: $governor"
}

# ── Main ──────────────────────────────────────
main() {
    log "Initializing Face 0 — Kernel & Memory"

    setup_zram
    setup_swap
    setup_oom
    setup_hugepages
    setup_cache
    setup_cpu_gov

    log "Face 0 initialized"
}

main "$@"
