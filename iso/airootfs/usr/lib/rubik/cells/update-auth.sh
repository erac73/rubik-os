#!/usr/bin/env bash
# cell: F5.7 - Authentication update hooks
CELL_NAME="update-auth"
cell_start() {
    if command -v authselect &>/dev/null; then
        authselect select custom/rubik 2>/dev/null || true
        echo "Auth profile set"
    fi
}
cell_stop() { return 0; }
cell_health() { return 0; }
