#!/usr/bin/env bash
# cell: F5.7 - Authentication and PAM configuration
CELL_NAME="update-auth"
POLKIT_RULES="/etc/polkit-1/rules.d/10-rubik.rules"
PAM_RUBIK="/etc/pam.d/rubik"

cell_start() {
    mkdir -p /etc/polkit-1/rules.d /etc/pam.d
    cat > "$POLKIT_RULES" << POLKIT
/* Allow rubikctl to manage system services without password */
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.systemd1") === 0 &&
        subject.user === "root") {
        return polkit.Result.YES;
    }
    if (action.id === "org.freedesktop.login1.suspend" ||
        action.id === "org.freedesktop.login1.power-off" ||
        action.id === "org.freedesktop.login1.reboot") {
        if (subject.local && subject.active) {
            return polkit.Result.YES;
        }
    }
});
POLKIT
    cat > "$PAM_RUBIK" << PAM
auth        required    pam_unix.so
account     required    pam_unix.so
password    required    pam_unix.so
session     required    pam_unix.so
PAM
    chmod 644 "$POLKIT_RULES" "$PAM_RUBIK"
    echo "Polkit rules + PAM config installed"
}

cell_stop() {
    rm -f "$POLKIT_RULES" "$PAM_RUBIK" 2>/dev/null || true
}

cell_health() {
    [ -f "$POLKIT_RULES" ] && [ -f "$PAM_RUBIK" ] && return 0
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
