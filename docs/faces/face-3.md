# Face 3 — Network

Stack de red minimalista. Sin NetworkManager, sin avahi, sin bluetooth por defecto. iwd para WiFi, systemd-networkd para interfaces cableadas.

## Celdas

### [F3.0] networkd
systemd-networkd con perfiles predefinidos:
- DHCP por defecto en interfaces ethernet
- Link-local en IPv6
- Sin avahi (mDNS/Bonjour no necesario en un sistema minimal)
- Sin LLMNR (Link-Local Multicast Name Resolution)

### [F3.1] firewall
nftables con reglas de firewall predefinidas:
- Denegar todo el tráfico entrante
- Permitir tráfico saliente
- Rate limiting en ICMP
- Logging mínimo (solo dropped packets)

### [F3.2] dns-cache
Caché DNS local:
- `systemd-resolved` (parte de systemd, no requiere instalación extra)
- Modo `stub` (escucha en 127.0.0.53)
- Caché de 1000 entradas, TTL máximo 1 hora
- Fallback a Cloudflare (1.1.1.1) y Quad9 (9.9.9.9)

### [F3.3] routing
Gestión de rutas:
- Rutas estáticas por defecto
- `ip route` en lugar de herramientas pesadas
- Soporte para WireGuard si se configura (no instalado por defecto)

### [F3.4] proxy-tun (opcional)
Túnel automático:
- Script que detecta bloqueo de DNS/HTTP
- Activa túnel automáticamente si hay censura
- Soporte: WireGuard, OpenVPN (cliente)

### [F3.5] net-monitor
Monitor de red ultraligero:
- `/proc/net/dev` poll cada 30 segundos
- Alerta si tráfico anómalo (posible malware)
- Estadísticas básicas: bytes TX/RX, paquetes, errores

### [F3.6] wifi-manager
iwd (iNet Wireless Daemon):
- Reemplaza a wpa_supplicant (más ligero: ~2MB vs ~10MB)
- Configuración vía iwctl
- Sin NetworkManager (demasiado pesado)
- Sin bluetooth (instalación opcional)

### [F3.7] bandwidth-limiter (opcional)
Límite de ancho de banda por proceso:
- Usa `tc` (traffic control) + cgroups
- Configuración en `/etc/rubik/bandwidth.toml`
- Límites por celda: F3.6 (WiFi) puede tener prioridad sobre F3.5 (monitor)

### [F3.8] ntp-sync
chrony (más ligero que ntpd):
- Sincronización cada 1 hora
- Pool: `pool.ntp.org`
- Sin servidor NTP (no acepta conexiones entrantes)
- `makestep 0.1 3` (ajuste rápido al inicio)
