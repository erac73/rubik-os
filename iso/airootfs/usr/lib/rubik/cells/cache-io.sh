#!/usr/bin/env bash
# cell: F2.2 - I/O cache tuning
CELL_NAME="cache-io"
cell_start() {
    echo 50 > /proc/sys/vm/dirty_ratio 2>/dev/null || true
    echo 30 > /proc/sys/vm/dirty_background_ratio 2>/dev/null || true
    echo "I/O cache tuned"
}
cell_stop() {
    echo 20 > /proc/sys/vm/dirty_ratio 2>/dev/null || true
    echo 10 > /proc/sys/vm/dirty_background_ratio 2>/dev/null || true
}
cell_health() {
    local dr
    dr=$(cat /proc/sys/vm/dirty_ratio 2>/dev/null || echo 0)
    [ "$dr" -eq 50 ] && return 0 || return 1
}
