#!/usr/bin/env bash
# cell: F4.10 - Display manager & graphical session
CELL_NAME="display-manager"
DM_DIR="/run/rubik/display"

cell_start() {
    mkdir -p "$DM_DIR"
    local dm_bin=""
    local dm_args=""

    # Try to detect and start a display manager
    if command -v sddm &>/dev/null; then
        dm_bin="sddm"
    elif command -v lightdm &>/dev/null; then
        dm_bin="lightdm"
    elif command -v gdm &>/dev/null; then
        dm_bin="gdm"
    elif command -v ly &>/dev/null; then
        dm_bin="ly"
    fi

    if [[ -n "$dm_bin" ]]; then
        if ! pidof "$dm_bin" &>/dev/null; then
            "$dm_bin" $dm_args &>/dev/null &
            echo "$!" > "$DM_DIR/pid"
            echo "Display manager: $dm_bin"
        else
            echo "Display manager: $dm_bin (already running)"
        fi
    else
        echo "Display manager: none found (start WM manually)"
        # Set up XDG vars for manual start
        export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        mkdir -p "$XDG_RUNTIME_DIR"
        echo "manual" > "$DM_DIR/mode"
    fi
}

cell_stop() {
    local pid
    pid=$(cat "$DM_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    pkill -x sddm 2>/dev/null || pkill -x lightdm 2>/dev/null || true
    pkill -x gdm 2>/dev/null || pkill -x ly 2>/dev/null || true
    rm -rf "$DM_DIR"
}

cell_health() {
    local pid
    pid=$(cat "$DM_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}
