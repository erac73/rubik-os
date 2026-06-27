#!/usr/bin/env bash
# cell: F1.3 - Scheduler tuning
CELL_NAME="sched-tune"
cell_start() {
    echo 0 > /proc/sys/kernel/sched_child_runs_first 2>/dev/null || true
    echo 10000000 > /proc/sys/kernel/sched_wakeup_granularity_ns 2>/dev/null || true
    echo "Scheduler tuned for throughput"
}
cell_stop() {
    echo 5000000 > /proc/sys/kernel/sched_wakeup_granularity_ns 2>/dev/null || true
}
cell_health() {
    local sg
    sg=$(cat /proc/sys/kernel/sched_wakeup_granularity_ns 2>/dev/null || echo 0)
    [ "$sg" -eq 10000000 ] && return 0 || return 1
}
