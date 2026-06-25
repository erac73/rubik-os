#!/usr/bin/env bash
# cell: F4.4 - GPU compositor
CELL_NAME="compositor"
cell_start() {
    if command -v picom &>/dev/null; then echo "picom available"; fi
}
cell_stop() { pkill -x picom 2>/dev/null || true; }
cell_health() { return 0; }
