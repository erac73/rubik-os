#!/usr/bin/env bash
# cell: F0.7 - CPU governor tuning
CELL_NAME="cpu-gov"
cell_start() {
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "performance" > "$cpu" 2>/dev/null || true
    done
    echo "CPU governors set to performance"
}
cell_stop() {
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "powersave" > "$cpu" 2>/dev/null || true
    done
}
cell_health() {
    local gov
    gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    [ "$gov" = "performance" ] && return 0 || return 1
}
