#!/usr/bin/env bash
# cell: F3.10 - WiFi connection manager
CELL_NAME="wifi-manager"
WIFI_DIR="/run/rubik/wifi"

cell_start() {
    mkdir -p "$WIFI_DIR"
    local backend=""

    if command -v iwd &>/dev/null && pidof iwd &>/dev/null; then
        backend="iwd"
        iwctl device list 2>/dev/null | grep -q "Station" || true
        echo "WiFi: iwd backend"
    elif command -v nmcli &>/dev/null; then
        backend="nmcli"
        nmcli radio wifi on 2>/dev/null || true
        echo "WiFi: NetworkManager backend"
    elif command -v wpa_supplicant &>/dev/null; then
        backend="wpa_supplicant"
        echo "WiFi: wpa_supplicant backend"
    else
        echo "WiFi: no backend found"
        return 0
    fi

    echo "$backend" > "$WIFI_DIR/backend"

    # Scan for networks
    case "$backend" in
        iwd)
            iwctl station wlan0 scan 2>/dev/null || true
            sleep 1
            iwctl station wlan0 get-networks 2>/dev/null | head -10 > "$WIFI_DIR/networks" || true
            ;;
        nmcli)
            nmcli device wifi list 2>/dev/null | head -10 > "$WIFI_DIR/networks" || true
            ;;
    esac

    echo "WiFi: networks scanned"
}

cell_stop() {
    rm -rf "$WIFI_DIR"
}

cell_health() {
    local backend
    backend=$(cat "$WIFI_DIR/backend" 2>/dev/null || echo "")
    if [[ "$backend" == "iwd" ]]; then
        pidof iwd &>/dev/null
    elif [[ "$backend" == "nmcli" ]]; then
        pidof NetworkManager &>/dev/null
    else
        return 1
    fi
}
