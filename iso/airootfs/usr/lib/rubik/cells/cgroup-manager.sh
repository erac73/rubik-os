#!/usr/bin/env bash
# cell: F1.2 - Cgroup management
CELL_NAME="cgroup-manager"
cell_start() {
    mkdir -p /sys/fs/cgroup/rubik
    echo "Cgroup v2 hierarchy ready"
}
cell_stop() {
    rmdir /sys/fs/cgroup/rubik 2>/dev/null || true
}
cell_health() {
    [ -d /sys/fs/cgroup/rubik ] && return 0 || return 1
}
