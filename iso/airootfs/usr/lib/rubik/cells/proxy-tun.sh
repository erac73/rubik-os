#!/usr/bin/env bash
# cell: F3.4 - Proxy/Tunnel setup
CELL_NAME="proxy-tun"
cell_start() {
    echo "proxy-tun: no proxy configured"
}
cell_stop() { return 0; }
cell_health() { return 0; }
