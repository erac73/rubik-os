#!/usr/bin/env bash
# cell: F4.1 - Status bar
CELL_NAME="bar-status"
cell_start() {
    if command -v waybar &>/dev/null; then echo "waybar available"
    elif command -v polybar &>/dev/null; then echo "polybar available"; fi
}
cell_stop() { return 0; }
cell_health() { return 0; }
