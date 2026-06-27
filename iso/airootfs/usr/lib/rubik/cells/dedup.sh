#!/usr/bin/env bash
# cell: F2.5 - Block-level dedup and data reduction
CELL_NAME="dedup"
DEDUP_TIMER="/etc/systemd/system/rubik-dedup.timer"
DEDUP_SERVICE="/etc/systemd/system/rubik-dedup.service"
DEDUP_SCRIPT="/usr/lib/rubik/helpers/dedup-run.sh"

cell_start() {
    mkdir -p /usr/lib/rubik/helpers
    cat > "$DEDUP_SCRIPT" << SCRIPT
#!/usr/bin/env bash
for dir in /home /var /srv; do
    if mountpoint -q "\$dir" 2>/dev/null; then
        if command -v duperemove &>/dev/null; then
            duperemove -dr --hashfile=/var/cache/duperemove-hashes "\$dir" 2>/dev/null || true
        fi
    fi
done
SCRIPT
    chmod 755 "$DEDUP_SCRIPT"
    cat > "$DEDUP_TIMER" << TIMER
[Unit]
Description=Weekly dedup scan
[Timer]
OnCalendar=weekly
Persistent=true
[Install]
WantedBy=timers.target
TIMER
    cat > "$DEDUP_SERVICE" << SERVICE
[Unit]
Description=Rubik OS dedup scan
[Service]
Type=oneshot
ExecStart=$DEDUP_SCRIPT
MemoryMax=256M
SERVICE
    systemctl daemon-reload 2>/dev/null || true
    systemctl enable --now rubik-dedup.timer 2>/dev/null || true
    echo "Dedup timer installed (weekly)"
}

cell_stop() {
    systemctl disable --now rubik-dedup.timer 2>/dev/null || true
    rm -f "$DEDUP_TIMER" "$DEDUP_SERVICE" "$DEDUP_SCRIPT" 2>/dev/null || true
}

cell_health() {
    systemctl is-enabled rubik-dedup.timer &>/dev/null && return 0
    [ -f "$DEDUP_SCRIPT" ] && return 0
    return 1
}

cell_deps() { echo "F2.1"; }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-start}" in
        start)   cell_start ;;
        stop)    cell_stop ;;
        health)  cell_health && echo "healthy" || echo "degraded" ;;
        *)       echo "Usage: $0 {start|stop|health}" ;;
    esac
fi
