#!/usr/bin/env bash
# cell: F4.8 - Idle/power management
CELL_NAME="idle-manager"
IDLE_DIR="/run/rubik/idle"

cell_start() {
    mkdir -p "$IDLE_DIR"
    local idle_bin=""
    if command -v swayidle &>/dev/null; then
        idle_bin="swayidle"
        swayidle -w timeout 300 'brightnessctl set 10%' resume 'brightnessctl set 100%' \
            timeout 600 'loginctl lock-session' \
            before-sleep 'playerctl -a pause' &
        echo "$!" > "$IDLE_DIR/pid"
    elif command -v xidle &>/dev/null; then
        idle_bin="xidle"
    fi
    if [[ -n "$idle_bin" ]]; then
        echo "Idle: $idle_bin"
    else
        echo "no idle manager found"
    fi
}

cell_stop() {
    local pid
    pid=$(cat "$IDLE_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    pkill -x swayidle 2>/dev/null || true
    rm -f "$IDLE_DIR/pid"
}

cell_health() {
    local pid
    pid=$(cat "$IDLE_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}
