#!/usr/bin/env bash
# cell: F2.0 - Filesystem layout verification
CELL_NAME="fs-layout"
cell_start() {
    local dirs=("/var/log" "/var/lib" "/var/cache" "/var/tmp")
    for d in "${dirs[@]}"; do mkdir -p "$d"; done
    echo "FS layout verified"
}
cell_stop() { return 0; }
cell_health() {
    for d in /var/log /var/lib /var/cache; do
        [ -d "$d" ] || return 1
    done
    return 0
}
