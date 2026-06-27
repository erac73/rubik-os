#!/usr/bin/env bash
# cell: F4.6 - Wallpaper setter
CELL_NAME="wallpaper"
WALL_DIR="/run/rubik/wallpaper"
WALLPAPER_FILE="/usr/share/rubik/wallpaper.png"

cell_start() {
    mkdir -p "$WALL_DIR"
    local setter=""
    if command -v swaybg &>/dev/null; then
        setter="swaybg"
        swaybg -i "$WALLPAPER_FILE" -m fill &>/dev/null &
        echo "$!" > "$WALL_DIR/pid"
    elif command -v feh &>/dev/null; then
        setter="feh"
        feh --bg-fill "$WALLPAPER_FILE" &
        echo "$!" > "$WALL_DIR/pid"
    elif command -v nitrogen &>/dev/null; then
        setter="nitrogen"
        nitrogen --set-zoom-fill "$WALLPAPER_FILE" &
        echo "$!" > "$WALL_DIR/pid"
    fi
    if [[ -n "$setter" ]]; then
        echo "Wallpaper: $setter"
    else
        echo "no wallpaper setter found"
    fi
}

cell_stop() {
    local pid
    pid=$(cat "$WALL_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    pkill -x swaybg 2>/dev/null || pkill -x feh 2>/dev/null || true
    rm -f "$WALL_DIR/pid"
}

cell_health() {
    local pid
    pid=$(cat "$WALL_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}
