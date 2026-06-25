#!/usr/bin/env bash
# cell: F5.5 - Firejail sandboxing
CELL_NAME="firejail"
cell_start() {
    if command -v firejail &>/dev/null; then echo "firejail available"; fi
}
cell_stop() { return 0; }
cell_health() {
    command -v firejail &>/dev/null && return 0 || return 1
}
