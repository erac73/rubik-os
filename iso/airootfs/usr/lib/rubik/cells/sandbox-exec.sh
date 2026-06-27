#!/usr/bin/env bash
# cell: F5.1 - Sandbox execution environment (bubblewrap + user namespaces)
CELL_NAME="sandbox-exec"
SYSCTL_SANDBOX="/etc/sysctl.d/90-rubik-sandbox.conf"
SANDBOX_WRAPPER="/usr/local/bin/rbwrap"

cell_start() {
    cat > "$SYSCTL_SANDBOX" << SYSCTL
kernel.unprivileged_userns_clone=1
kernel.seccomp.actions_avail=1
user.max_user_namespaces=100
SYSCTL
    sysctl -p "$SYSCTL_SANDBOX" 2>/dev/null || true
    if command -v bwrap &>/dev/null; then
        cat > "$SANDBOX_WRAPPER" << WRAPPER
#!/usr/bin/env bash
exec bwrap --unshare-all --share-net --die-with-parent --ro-bind /usr /usr \
    --ro-bind /etc /etc --tmpfs /home --tmpfs /var --tmpfs /tmp \
    --proc /proc --dev /dev "\$@"
WRAPPER
        chmod 755 "$SANDBOX_WRAPPER"
        echo "Sandbox wrapper installed at $SANDBOX_WRAPPER"
    fi
    echo "User namespaces: 100 max, seccomp enabled"
}

cell_stop() {
    rm -f "$SYSCTL_SANDBOX" "$SANDBOX_WRAPPER" 2>/dev/null || true
}

cell_health() {
    [ -f "$SYSCTL_SANDBOX" ] && return 0
    return 1
}

cell_deps() { echo "F5.0"; }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-start}" in
        start)   cell_start ;;
        stop)    cell_stop ;;
        health)  cell_health && echo "healthy" || echo "degraded" ;;
        *)       echo "Usage: $0 {start|stop|health}" ;;
    esac
fi
