#!/usr/bin/env bash
# cell: F4.0 - Window manager core
CELL_NAME="wm-core"
cell_start() {
    if command -v sway &>/dev/null; then echo "sway available"
    elif command -v dwm &>/dev/null; then echo "dwm available"
    else echo "no WM found"; fi
}
cell_stop() { return 0; }
cell_health() {
    command -v sway &>/dev/null || command -v dwm &>/dev/null && return 0 || return 1
}
