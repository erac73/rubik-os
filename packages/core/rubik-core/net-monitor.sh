#!/usr/bin/env bash
# cell: F3.5 - Network monitoring
CELL_NAME="net-monitor"
MONITOR_DIR="/run/rubik/net-monitor"
METRICS_FILE="$MONITOR_DIR/metrics"

cell_start() {
    mkdir -p "$MONITOR_DIR"
    # Collect baseline metrics every 60s via a background loop
    (
        while true; do
            {
                echo "# $(date -Iseconds)"
                echo "rx_bytes=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | paste -sd+ | bc)"
                echo "tx_bytes=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | paste -sd+ | bc)"
                echo "rx_packets=$(cat /sys/class/net/*/statistics/rx_packets 2>/dev/null | paste -sd+ | bc)"
                echo "tx_packets=$(cat /sys/class/net/*/statistics/tx_packets 2>/dev/null | paste -sd+ | bc)"
                ss -s 2>/dev/null | head -1
                ip -s link show 2>/dev/null | grep -A2 "RX\|TX"
            } > "$METRICS_FILE" 2>/dev/null
            sleep 60
        done
    ) &
    echo "$!" > "$MONITOR_DIR/pid"
    echo "Net monitor started"
}

cell_stop() {
    local pid
    pid=$(cat "$MONITOR_DIR/pid" 2>/dev/null || echo "")
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
    rm -f "$MONITOR_DIR/pid"
}

cell_health() {
    [[ -f "$METRICS_FILE" ]] && grep -q "rx_bytes" "$METRICS_FILE" 2>/dev/null
}
