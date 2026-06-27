#!/usr/bin/env bash
# cell: F0.5 - Cache tuning
CELL_NAME="cache-tune"
cell_start() {
    echo 10 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null || true
    echo "Cache pressure set to 10"
}
cell_stop() {
    echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null || true
}
cell_health() {
    local cp
    cp=$(cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null || echo 0)
    [ "$cp" -le 20 ] && return 0 || return 1
}
