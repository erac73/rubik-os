#!/usr/bin/env bash
# cell: F3.9 - Bluetooth manager
CELL_NAME="bluetooth"
BT_DIR="/run/rubik/bluetooth"

cell_start() {
    mkdir -p "$BT_DIR"
    if ! command -v bluetoothctl &>/dev/null; then
        echo "Bluetooth: bluez not installed"
        return 0
    fi
    # Start bluetoothd if not running
    if ! pidof bluetoothd &>/dev/null; then
        /usr/lib/bluetooth/bluetoothd &>/dev/null &
        echo "$!" > "$BT_DIR/pid"
    fi
    # Enable the adapter
    bluetoothctl power on 2>/dev/null || true
    bluetoothctl agent on 2>/dev/null || true
    bluetoothctl default-agent 2>/dev/null || true
    local adapter
    adapter=$(bluetoothctl list 2>/dev/null | head -1 | awk '{print $2}')
    if [[ -n "$adapter" ]]; then
        echo "$adapter" > "$BT_DIR/adapter"
        echo "Bluetooth: active ($adapter)"
    else
        echo "Bluetooth: no adapter found"
    fi
}

cell_stop() {
    bluetoothctl power off 2>/dev/null || true
    local pid
    pid=$(cat "$BT_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    pkill -x bluetoothd 2>/dev/null || true
    rm -rf "$BT_DIR"
}

cell_health() {
    bluetoothctl show 2>/dev/null | grep -q "Powered: yes"
}
