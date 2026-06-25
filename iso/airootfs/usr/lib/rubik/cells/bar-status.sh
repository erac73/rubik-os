#!/usr/bin/env bash
# cell: F4.1 - Status bar
CELL_NAME="bar-status"
BAR_DIR="/run/rubik/bar"

cell_start() {
    mkdir -p "$BAR_DIR"
    local bar_bin=""
    local bar_args=""
    if command -v waybar &>/dev/null; then
        bar_bin="waybar"
        bar_args="-c /etc/rubik/waybar/config.jsonc -s /etc/rubik/waybar/style.css"
    elif command -v polybar &>/dev/null; then
        bar_bin="polybar"
        bar_args="rubik-bar"
    fi
    if [[ -n "$bar_bin" ]]; then
        $bar_bin $bar_args &>/dev/null &
        echo "$!" > "$BAR_DIR/pid"
        echo "Bar: $bar_bin"
    else
        echo "no bar found"
    fi
}

cell_stop() {
    local pid
    pid=$(cat "$BAR_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    pkill -x waybar 2>/dev/null || pkill -x polybar 2>/dev/null || true
    rm -f "$BAR_DIR/pid"
}

cell_health() {
    local pid
    pid=$(cat "$BAR_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}
