#!/usr/bin/env bash
# cell: F4.2 - Application launcher
CELL_NAME="launcher"
cell_start() {
    if command -v rofi &>/dev/null; then echo "rofi available"
    elif command -v dmenu &>/dev/null; then echo "dmenu available"; fi
}
cell_stop() { return 0; }
cell_health() { return 0; }
