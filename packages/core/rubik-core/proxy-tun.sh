#!/usr/bin/env bash
# cell: F3.4 - Proxy/Tunnel setup
CELL_NAME="proxy-tun"
CONF_FILE="/etc/rubik/proxy-tun.conf"
RUN_DIR="/run/rubik/proxy-tun"

cell_start() {
    mkdir -p "$RUN_DIR"
    if [[ ! -f "$CONF_FILE" ]]; then
        echo "proxy-tun: no config at $CONF_FILE, using defaults"
        cat > "$CONF_FILE" 2>/dev/null <<'CONF'
# proxy-tun configuration
# Set PROXY_ENABLED=true and configure PROXY_HOST/PORT to enable
PROXY_ENABLED=false
PROXY_HOST=127.0.0.1
PROXY_PORT=8080
CONF
    fi
    # shellcheck source=/dev/null
    source "$CONF_FILE"
    if [[ "${PROXY_ENABLED:-false}" == "true" ]]; then
        export http_proxy="http://${PROXY_HOST}:${PROXY_PORT}"
        export https_proxy="http://${PROXY_HOST}:${PROXY_PORT}"
        echo "Proxy configured: $http_proxy"
    else
        unset http_proxy https_proxy
        echo "proxy-tun: disabled"
    fi
}

cell_stop() {
    unset http_proxy https_proxy
    rm -rf "$RUN_DIR"
}

cell_health() {
    [[ -d "$RUN_DIR" ]]
}
