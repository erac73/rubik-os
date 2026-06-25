#!/usr/bin/env bash
# cell: F4.5 - Notification daemon
CELL_NAME="notifier"
cell_start() {
    if command -v dunst &>/dev/null; then echo "dunst available"
    elif command -v mako &>/dev/null; then echo "mako available"; fi
}
cell_stop() { return 0; }
cell_health() { return 0; }
