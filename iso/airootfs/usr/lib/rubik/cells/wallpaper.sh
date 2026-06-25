#!/usr/bin/env bash
# cell: F4.6 - Wallpaper setter
CELL_NAME="wallpaper"
cell_start() {
    if command -v swaybg &>/dev/null; then
        swaybg -i /usr/share/rubik/wallpaper.png -m fill &>/dev/null &
        echo "wallpaper set"
    fi
}
cell_stop() { pkill -x swaybg 2>/dev/null || true; }
cell_health() { return 0; }
