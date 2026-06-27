#!/usr/bin/env bash
# cell: F0.4 - HugePages configuration
CELL_NAME="hugepages"
cell_start() {
    local size=${HUGEPAGES_SIZE:-256}
    echo "$size" > /proc/sys/vm/nr_hugepages 2>/dev/null || true
    echo "HugePages: ${size} x 2MB configured"
}
cell_stop() {
    echo 0 > /proc/sys/vm/nr_hugepages 2>/dev/null || true
}
cell_health() {
    local current
    current=$(cat /proc/sys/vm/nr_hugepages 2>/dev/null || echo 0)
    [ "$current" -gt 0 ] && return 0 || return 1
}
