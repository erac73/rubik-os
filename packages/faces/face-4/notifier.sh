#!/usr/bin/env bash
# cell: F4.5 - Notification daemon
CELL_NAME="notifier"
NOTIFY_DIR="/run/rubik/notifier"

cell_start() {
    mkdir -p "$NOTIFY_DIR"
    local notify_bin=""
    if command -v dunst &>/dev/null; then
        notify_bin="dunst"
    elif command -v mako &>/dev/null; then
        notify_bin="mako"
    elif command -v notification-daemon &>/dev/null; then
        notify_bin="notification-daemon"
    fi
    if [[ -n "$notify_bin" ]]; then
        if [[ "$notify_bin" == "dunst" ]]; then
            dunst -config /etc/rubik/dunstrc &>/dev/null &
        elif [[ "$notify_bin" == "mako" ]]; then
            mako &>/dev/null &
        else
            "$notify_bin" &>/dev/null &
        fi
        echo "$!" > "$NOTIFY_DIR/pid"
        echo "Notifier: $notify_bin"
    else
        echo "no notifier found"
    fi
}

cell_stop() {
    local pid
    pid=$(cat "$NOTIFY_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    pkill -x dunst 2>/dev/null || pkill -x mako 2>/dev/null || true
    rm -f "$NOTIFY_DIR/pid"
}

cell_health() {
    local pid
    pid=$(cat "$NOTIFY_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}
