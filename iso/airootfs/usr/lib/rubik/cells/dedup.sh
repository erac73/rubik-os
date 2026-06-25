#!/usr/bin/env bash
# cell: F2.5 - Block-level dedup
CELL_NAME="dedup"
cell_start() {
    if command -v duperemove &>/dev/null; then
        echo "duperemove available"
    else
        echo "dedup tools not installed"
    fi
}
cell_stop() { return 0; }
cell_health() {
    command -v duperemove &>/dev/null && return 0 || return 1
}
