#!/usr/bin/env bash
# cell: F4.4 - GPU compositor
CELL_NAME="compositor"
COMP_DIR="/run/rubik/compositor"

cell_start() {
    mkdir -p "$COMP_DIR"
    local comp_bin=""
    local comp_args=""
    if command -v picom &>/dev/null; then
        comp_bin="picom"
        comp_args="-b --config /etc/rubik/picom.conf"
    elif command -v compton &>/dev/null; then
        comp_bin="compton"
    fi
    if [[ -n "$comp_bin" ]]; then
        $comp_bin $comp_args 2>/dev/null &
        echo "$!" > "$COMP_DIR/pid"
        echo "Compositor: $comp_bin"
    else
        echo "no compositor found"
    fi
}

cell_stop() {
    local pid
    pid=$(cat "$COMP_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    pkill -x picom 2>/dev/null || pkill -x compton 2>/dev/null || true
    rm -f "$COMP_DIR/pid"
}

cell_health() {
    local pid
    pid=$(cat "$COMP_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}
