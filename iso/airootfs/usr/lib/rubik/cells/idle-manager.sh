#!/usr/bin/env bash
# cell: F4.8 - Idle/power management
CELL_NAME="idle-manager"
cell_start() {
    if command -v swayidle &>/dev/null; then echo "swayidle available"; fi
}
cell_stop() { pkill -x swayidle 2>/dev/null || true; }
cell_health() { return 0; }
