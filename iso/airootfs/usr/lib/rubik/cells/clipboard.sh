#!/usr/bin/env bash
# cell: F4.7 - Clipboard manager
CELL_NAME="clipboard"
cell_start() {
    if command -v wl-clipboard &>/dev/null; then echo "wl-clipboard available"
    elif command -v xclip &>/dev/null; then echo "xclip available"; fi
}
cell_stop() { return 0; }
cell_health() { return 0; }
