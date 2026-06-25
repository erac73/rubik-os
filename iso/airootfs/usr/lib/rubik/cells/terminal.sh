#!/usr/bin/env bash
# cell: F4.3 - Terminal emulator
CELL_NAME="terminal"
TERMINAL_DIR="/run/rubik/terminal"

cell_start() {
    mkdir -p "$TERMINAL_DIR"
    local term_bin=""
    if command -v foot &>/dev/null; then
        term_bin="foot"
    elif command -v alacritty &>/dev/null; then
        term_bin="alacritty"
    elif command -v kitty &>/dev/null; then
        term_bin="kitty"
    elif command -v wezterm &>/dev/null; then
        term_bin="wezterm"
    elif command -v gnome-terminal &>/dev/null; then
        term_bin="gnome-terminal"
    fi
    if [[ -n "$term_bin" ]]; then
        echo "$term_bin" > "$TERMINAL_DIR/current"
        echo "Terminal: $term_bin"
    else
        echo "no terminal found"
    fi
}

cell_stop() { rm -rf "$TERMINAL_DIR"; }

cell_health() {
    [[ -f "$TERMINAL_DIR/current" ]]
}
