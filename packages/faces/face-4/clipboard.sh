#!/usr/bin/env bash
# cell: F4.7 - Clipboard manager
CELL_NAME="clipboard"
CLIP_DIR="/run/rubik/clipboard"

cell_start() {
    mkdir -p "$CLIP_DIR"
    local clip_bin=""
    if command -v wl-paste &>/dev/null && command -v wl-copy &>/dev/null; then
        clip_bin="wl-clipboard"
        # Start wl-paste as a listener
        wl-paste -t text --watch cat &>/dev/null &
        echo "$!" > "$CLIP_DIR/pid"
    elif command -v xclip &>/dev/null; then
        clip_bin="xclip"
        xclip -selection clipboard -o > /dev/null 2>&1 &
        echo "$!" > "$CLIP_DIR/pid"
    elif command -v copyq &>/dev/null; then
        clip_bin="copyq"
        copyq &>/dev/null &
        echo "$!" > "$CLIP_DIR/pid"
    fi
    if [[ -n "$clip_bin" ]]; then
        echo "Clipboard: $clip_bin"
    else
        echo "no clipboard manager found"
    fi
}

cell_stop() {
    local pid
    pid=$(cat "$CLIP_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    rm -f "$CLIP_DIR/pid"
}

cell_health() {
    local pid
    pid=$(cat "$CLIP_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}
