#!/usr/bin/env bash
# cell: F4.0 - Window manager core
CELL_NAME="wm-core"
WM_DIR="/run/rubik/wm"

cell_start() {
    mkdir -p "$WM_DIR"
    local wm_bin=""
    if command -v river &>/dev/null; then
        wm_bin="river"
    elif command -v hyprland &>/dev/null; then
        wm_bin="Hyprland"
    elif command -v sway &>/dev/null; then
        wm_bin="sway"
    elif command -v dwm &>/dev/null; then
        wm_bin="dwm"
    fi
    if [[ -n "$wm_bin" ]]; then
        echo "$wm_bin" > "$WM_DIR/current"
        echo "WM: $wm_bin"
    else
        echo "no WM found" > "$WM_DIR/current"
        echo "WM: none available"
    fi
}

cell_stop() {
    local wm
    wm=$(cat "$WM_DIR/current" 2>/dev/null || echo "")
    [[ -n "$wm" ]] && pkill -x "$wm" 2>/dev/null || true
    rm -f "$WM_DIR/current"
}

cell_health() {
    local wm
    wm=$(cat "$WM_DIR/current" 2>/dev/null || echo "")
    [[ -n "$wm" ]] && pidof "$wm" &>/dev/null
}
