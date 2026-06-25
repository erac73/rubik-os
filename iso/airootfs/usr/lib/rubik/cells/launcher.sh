#!/usr/bin/env bash
# cell: F4.2 - Application launcher
CELL_NAME="launcher"
LAUNCHER_DIR="/run/rubik/launcher"

cell_start() {
    mkdir -p "$LAUNCHER_DIR"
    local launcher_bin=""
    if command -v rofi &>/dev/null; then
        launcher_bin="rofi -show drun"
    elif command -v dmenu &>/dev/null; then
        launcher_bin="dmenu_run"
    elif command -v wofi &>/dev/null; then
        launcher_bin="wofi --show drun"
    fi
    if [[ -n "$launcher_bin" ]]; then
        echo "$launcher_bin" > "$LAUNCHER_DIR/mode"
        echo "Launcher: ${launcher_bin%% *}"
    else
        echo "no launcher found"
    fi
}

cell_stop() {
    pkill -x rofi 2>/dev/null || pkill -x dmenu 2>/dev/null || pkill -x wofi 2>/dev/null || true
    rm -rf "$LAUNCHER_DIR"
}

cell_health() {
    [[ -f "$LAUNCHER_DIR/mode" ]]
}
