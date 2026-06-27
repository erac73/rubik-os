#!/usr/bin/env bash
# cell: F4.9 - Audio server (PipeWire)
CELL_NAME="pipewire"
PW_DIR="/run/rubik/pipewire"

cell_start() {
    mkdir -p "$PW_DIR"
    local errors=0

    # Start WirePlumber session manager first
    if command -v wireplumber &>/dev/null; then
        if ! pidof wireplumber &>/dev/null; then
            wireplumber &>/dev/null &
            echo "$!" > "$PW_DIR/wp-pid"
            echo "WirePlumber: started"
        else
            echo "WirePlumber: already running"
        fi
    else
        echo "WirePlumber: not installed"
        errors=$((errors + 1))
    fi

    # Start PipeWire
    if command -v pipewire &>/dev/null; then
        if ! pidof pipewire &>/dev/null; then
            pipewire &>/dev/null &
            echo "$!" > "$PW_DIR/pw-pid"
            echo "PipeWire: started"
        else
            echo "PipeWire: already running"
        fi
    else
        echo "PipeWire: not installed"
        errors=$((errors + 1))
    fi

    # Start PipeWire-Pulse (PulseAudio compat)
    if command -v pipewire-pulse &>/dev/null; then
        if ! pidof pipewire-pulse &>/dev/null; then
            pipewire-pulse &>/dev/null &
            echo "$!" > "$PW_DIR/pulse-pid"
            echo "PipeWire-Pulse: started"
        else
            echo "PipeWire-Pulse: already running"
        fi
    fi

    if [[ $errors -eq 0 ]]; then
        echo "Audio: PipeWire ready"
    else
        echo "Audio: partial setup"
    fi
}

cell_stop() {
    local pids
    for f in wp-pid pw-pid pulse-pid; do
        local pid
        pid=$(cat "$PW_DIR/$f" 2>/dev/null || echo "")
        [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    done
    pkill -x wireplumber 2>/dev/null || true
    pkill -x pipewire 2>/dev/null || true
    pkill -x pipewire-pulse 2>/dev/null || true
    rm -rf "$PW_DIR"
}

cell_health() {
    pidof pipewire &>/dev/null && pidof wireplumber &>/dev/null
}
