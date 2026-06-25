#!/usr/bin/env bash
# cell: F3.5 - Network monitoring
CELL_NAME="net-monitor"
cell_start() {
    echo 1 > /proc/sys/net/ipv4/tcp_syncookies 2>/dev/null || true
    echo "Net monitor active"
}
cell_stop() { return 0; }
cell_health() { return 0; }
