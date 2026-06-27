#!/usr/bin/env bash
# cell: F3.7 - Bandwidth limiter
CELL_NAME="bandwidth-limiter"
IFACE="${BANDWIDTH_IFACE:-eth0}"
RATE="${BANDWIDTH_RATE:-1gbit}"
cell_start() {
    tc qdisc add dev "$IFACE" root tbf rate "$RATE" burst 32kbit latency 400ms 2>/dev/null || true
    echo "Bandwidth limit: $RATE on $IFACE"
}
cell_stop() {
    tc qdisc del dev "$IFACE" root 2>/dev/null || true
}
cell_health() {
    tc qdisc show dev "$IFACE" 2>/dev/null | grep -q tbf && return 0 || return 1
}
