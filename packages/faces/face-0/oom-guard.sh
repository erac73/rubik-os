#!/usr/bin/env bash
# cell: F0.3 - OOM guard
CELL_NAME="oom-guard"
cell_start() {
    echo 1 > /proc/sys/vm/panic_on_oom 2>/dev/null || true
    echo 0 > /proc/sys/vm/oom_kill_allocating_task 2>/dev/null || true
    echo "OOM guard activated"
}
cell_stop() {
    echo 0 > /proc/sys/vm/panic_on_oom 2>/dev/null || true
}
cell_health() {
    local oom
    oom=$(cat /proc/sys/vm/panic_on_oom 2>/dev/null || echo 0)
    [ "$oom" -eq 1 ] && return 0 || return 1
}
