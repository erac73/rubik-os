#!/usr/bin/env bash
# cell: F4.3 - Terminal emulator
CELL_NAME="terminal"
cell_start() {
    if command -v foot &>/dev/null; then echo "foot available"
    elif command -v alacritty &>/dev/null; then echo "alacritty available"; fi
}
cell_stop() { return 0; }
cell_health() { return 0; }
