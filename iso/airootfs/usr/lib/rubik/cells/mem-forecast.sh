#!/usr/bin/env bash
# cell: F0.8 - Memory pressure forecasting
CELL_NAME="mem-forecast"
cell_start() {
    if command -v earlyoom &>/dev/null; then
        earlyoom -m 5 -s 10 -r 0 -n 2>/dev/null || true
        echo "earlyoom started"
    else
        echo "earlyoom not installed"
    fi
}
cell_stop() {
    pkill -x earlyoom 2>/dev/null || true
}
cell_health() {
    pgrep -x earlyoom &>/dev/null && return 0 || return 1
}
