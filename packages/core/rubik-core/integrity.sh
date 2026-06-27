#!/usr/bin/env bash
# cell: F5.4 - Filesystem integrity monitoring
CELL_NAME="integrity"
cell_start() {
    if command -v aide &>/dev/null; then
        aideinit --force 2>/dev/null || true
        echo "AIDE database initialized"
    elif command -v tripwire &>/dev/null; then
        tripwire --init 2>/dev/null || true
        echo "Tripwire database initialized"
    fi
}
cell_stop() { return 0; }
cell_health() {
    [ -f /var/lib/aide/aide.db.gz ] && return 0
    [ -f /var/lib/tripwire/tw.db ] && return 0
    return 1
}
