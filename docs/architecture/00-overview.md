# Visión General de Arquitectura — Rubik OS

## El Modelo del Cubo Rubik

Rubik OS organiza el sistema operativo como un Cubo Rubik:

```
        ┌─────┬─────┬─────┐
        │ F4  │ F4  │ F4  │  ← Face 4: UI / Experiencia
        │ (0) │ (1) │ (2) │
        ├─────┼─────┼─────┤
        │ F4  │ F4  │ F4  │
        │ (3) │ (4) │ (5) │
        ├─────┼─────┼─────┤
        │ F4  │ F4  │ F4  │
        │ (6) │ (7) │ (8) │
┌───────┼─────┼─────┼─────┼───────┬─────┬─────┬─────┐
│ F5(0) │ F5  │ F5  │ F3  │ F3(0) │ F3  │ F3  │ F3  │
│       │ (1) │ (2) │ (0) │       │ (1) │ (2) │ (3) │
├───────┼─────┼─────┼─────┼───────┼─────┼─────┼─────┤
│ F5(3) │ F5  │ F5  │ F3  │ F3(4) │ F3  │ F3  │ F3  │
│       │ (4) │ (5) │ (4) │       │ (5) │ (6) │ (7) │
├───────┼─────┼─────┼─────┼───────┼─────┼─────┼─────┤
│ F5(6) │ F5  │ F5  │ F3  │ F3(8) │ F3  │ F3  │ F3  │
│       │ (7) │ (8) │ (6) │       │ (9) │ (10)│ (11)│
└───────┼─────┼─────┼─────┼───────┴─────┴─────┴─────┘
        │ F2  │ F2  │ F2  │
        │ (0) │ (1) │ (2) │
        ├─────┼─────┼─────┤
        │ F2  │ F2  │ F2  │
        │ (3) │ (4) │ (5) │
        ├─────┼─────┼─────┤
        │ F2  │ F2  │ F2  │
        │ (6) │ (7) │ (8) │
        └─────┴─────┴─────┘
               │ F1  │ F1  │ F1  │
               │ (0) │ (1) │ (2) │
               ├─────┼─────┼─────┤
               │ F1  │ F1  │ F1  │
               │ (3) │ (4) │ (5) │
               ├─────┼─────┼─────┤
               │ F1  │ F1  │ F1  │
               │ (6) │ (7) │ (8) │
               └─────┴─────┴─────┘
                      │ F0  │ F0  │ F0  │
                      │ (0) │ (1) │ (2) │
                      ├─────┼─────┼─────┤
                      │ F0  │ F0  │ F0  │
                      │ (3) │ (4) │ (5) │
                      ├─────┼─────┼─────┤
                      │ F0  │ F0  │ F0  │
                      │ (6) │ (7) │ (8) │
                      └─────┴─────┴─────┘
```

## Principios Arquitectónicos

### 1. Descentralización
Cada celda (componente) es un proceso/servicio independiente. Si una celda falla, las demás continúan funcionando. Las celdas se comunican mediante IPC ligero (D-Bus, sockets Unix, memoria compartida).

### 2. Atomicidad
Cada celda hace exactamente una cosa. Una celda de "gestión de swap" no sabe de redes. Una celda de "firewall" no gestiona archivos.

### 3. Intercambiabilidad (Rotación)
Cada celda puede ser reemplazada en caliente. ¿No te gusta el gestor de paquetes por defecto? Cambia esa celda sin tocar el resto.

### 4. Eficiencia de Memoria
- Uso agresivo de ZRAM (compresión de RAM)
- Kernel configurado para baja latencia y menor uso de memoria
- Servicios bajo demanda (socket-activation, timer-activation)
- Pool de memoria compartida entre celdas de la misma cara

### 5. Jerarquía plana
No hay capas de abstracción innecesarias. Cada celda se comunica directamente con quien necesita.

## El Orquestador Rubik (rubikd)

El orquestador central (`rubikd`) gestiona:
- Inicio/parada de celdas
- Dependencias entre celdas (grafo acíclico)
- Rotación de celdas (actualización en caliente)
- Health checks
- Recogida de métricas de memoria

```bash
rubikctl status          # Estado de todas las celdas
rubikctl rotate face-0   # Reemplazar todas las celdas de una cara
rubikctl cell enable F0.4 memory-compression
rubikctl cell disable F2.2 defrag
```

## Las 54 Celdas (9 por cada una de las 6 caras)

### F0 — Kernel & Memoria
| # | Celda | Función |
|---|-------|---------|
| 0 | Kernel-lts | Kernel Linux LTS con parches Rubik |
| 1 | Memory-compression | ZRAM + zswap gestionado dinámicamente |
| 2 | Swap-manager | Swap inteligente con priorización de páginas |
| 3 | OOM-guard | EarlyOOM + notificaciones antes de matar procesos |
| 4 | Hugepages | Gestión dinámica de hugepages (transparente + reserva) |
| 5 | Cache-tune | Ajuste automático de vfs_cache_pressure, dirty_ratio |
| 6 | IRQ-balance | Balanceo de interrupciones entre cores |
| 7 | CPU-gov | Gobernador de CPU adaptativo (conservative + schedutil) |
| 8 | Mem-forecast | Predictor de uso de memoria (ML ligero) |

### F1 — Procesos & Servicios
| # | Celda | Función |
|---|-------|---------|
| 0 | Rubikd-orchestrator | Orquestador central de celdas |
| 1 | Systemd-minimal | Systemd con sólo lo esencial |
| 2 | Cgroup-manager | Gestión de cgroups v2 para aislamiento |
| 3 | Sched-tune | Ajuste de prioridades y afinidad de CPU |
| 4 | Service-watcher | Monitor de servicios con auto-reinicio |
| 5 | Cron-minimal | Cron ligero (solo tareas esenciales) |
| 6 | Log-forwarder | Forwarder de logs a journald (local, sin rsyslog) |
| 7 | Initramfs | Initramfs mínimo con arranque paralelo |
| 8 | Power-manager | Gestión de estados de sueño y frecuencia |

### F2 — Almacenamiento
| # | Celda | Función |
|---|-------|---------|
| 0 | Fs-layout | Estructura de directorios Rubik |
| 1 | Mount-manager | Sistema de montajes lazy (autofs) |
| 2 | Cache-io | Caché de E/S inteligente (bcache/lvmcache) |
| 3 | Tmpfs-manager | /tmp, /var/tmp en tmpfs con límites |
| 4 | Trim-scheduler | TRIM programado para SSDs |
| 5 | Dedup | Deduplicación a nivel de bloques (vdo) |
| 6 | Fs-notify | Notificaciones de cambios en filesystem (fanotify) |
| 7 | Snapper | Snapshots de recuperación (btrfs/zfs) |
| 8 | Defrag-lite | Desfragmentación ligera en segundo plano |

### F3 — Red & Comunicación
| # | Celda | Función |
|---|-------|---------|
| 0 | Networkd | systemd-networkd minimal |
| 1 | Firewall | nftables con reglas predefinidas |
| 2 | Dns-cache | Resolver DNS local (systemd-resolved o stubby) |
| 3 | Routing | Gestión de rutas estáticas + dinámicas |
| 4 | Proxy-tun | Túnel OPTP/Proxy automático si hay censura |
| 5 | Net-monitor | Monitor de tráfico y conexiones |
| 6 | Wifi-manager | iwd (minimal, sin NetworkManager) |
| 7 | Bandwidth-limiter | Límite de ancho de banda por proceso |
| 8 | Ntp-sync | Sincronización de tiempo (chrony, minimal) |

### F4 — Interfaz & Experiencia
| # | Celda | Función |
|---|-------|---------|
| 0 | Wm-core | Window manager (River o Hyprland) |
| 1 | Bar-status | Barra de estado (waybar minimal) |
| 2 | Launcher | Lanzador de aplicaciones (rofi/fuzzel) |
| 3 | Terminal | Terminal (foot/alacritty) |
| 4 | Compositor | Compositor (picom si es X11) |
| 5 | Notifier | Notificaciones (mako/dunst) |
| 6 | Wallpaper | Gestor de wallpaper (swaybg/hsetroot) |
| 7 | Clipboard | Portapapeles (wl-clipboard/xclip) |
| 8 | Idle-manager | Gestión de idle/lockscreen (swaylock) |

### F5 — Seguridad & Aislamiento
| # | Celda | Función |
|---|-------|---------|
| 0 | Apparmor | Perfiles AppArmor para todas las celdas |
| 1 | Sandbox-exec | Ejecución de comandos en sandbox (bubblewrap) |
| 2 | Audit | Auditoría de eventos del sistema |
| 3 | Crypto | Cifrado LUKS + gestión de claves |
| 4 | Integrity | Verificación de integridad de paquetes |
| 5 | Firejail | Aislamiento adicional de aplicaciones |
| 6 | Hardened-kernel | Parches de seguridad para el kernel |
| 7 | Update-auth | Autenticación para actualizaciones (firmado) |
| 8 | Cell-isolation | Aislamiento entre celdas via namespaces |

## Ciclo de Vida de una Celda

```
REGISTERED → LOADED → ACTIVE → HEALTHY
                          ↓
                     DEGRADED → RETRY → ACTIVE
                          ↓
                      FAILED → NOTIFY → RESTART
```

El orquestador monitorea el estado de cada celda y ejecuta acciones correctivas automáticamente.

## Métricas de Rendimiento Esperadas

| Métrica | Linux estándar | Rubik OS | Mejora |
|---------|---------------|----------|--------|
| RAM idle (sin GUI) | ~300-400 MB | ~80-120 MB | 60-70% |
| RAM idle (con GUI) | ~800-1200 MB | ~250-400 MB | 55-65% |
| Arranque a shell | ~15-30s | ~5-10s | 50-65% |
| Arranque a GUI | ~30-60s | ~10-20s | 55-65% |
| Procesos en idle | ~400-600 | ~80-150 | 60-75% |
| Tamaño ISO | ~2-3 GB | ~500-800 MB | 60-75% |
