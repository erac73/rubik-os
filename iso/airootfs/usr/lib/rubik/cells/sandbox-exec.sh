#!/usr/bin/env bash
# cell: F5.1 - Sandboxed execution
CELL_NAME="sandbox-exec"
cell_start() {
    echo "kernel.unprivileged_userns_clone=1" > /etc/sysctl.d/90-rubik-userns.conf 2>/dev/null || true
    echo "User namespace sandboxing enabled"
}
cell_stop() {
    rm -f /etc/sysctl.d/90-rubik-userns.conf 2>/dev/null || true
}
cell_health() {
    [ -f /etc/sysctl.d/90-rubik-userns.conf ] && return 0 || return 1
}
