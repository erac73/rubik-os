# Face 1 — Process & Service Management

Gestión descentralizada de procesos y servicios. Cada celda es un servicio independiente que puede ser iniciado, detenido y reemplazado sin afectar a los demás.

## Celdas

### [F1.0] rubikd-orchestrator
El corazón del sistema Rubik. Escrito en Rust para máximo rendimiento.
- Lee `/etc/rubik/cells.toml` (definición de todas las celdas)
- Mantiene el grafo de dependencias entre celdas
- Expone socket Unix `/run/rubik/rubikd.sock` para comunicación IPC
- Comandos: `rubikctl` (CLI en bash, envuelve llamadas al socket)
- Health check: cada 10s verifica que las celdas críticas respondan

### [F1.1] systemd-minimal
Systemd con solo los componentes necesarios:
- `systemd --user` desactivado (no necesario en un sistema minimal)
- Journald con `SystemMaxUse=50M`, `Compress=yes`
- Sin `systemd-resolved` (se usa celda dedicada F3.2)
- Sin `systemd-networkd` (se usa celda dedicada F3.0)
- Sin `systemd-timesyncd` (se usa celda dedicada F3.8)
- Sin `systemd-logind` (se usa solo si hay GUI)
- `DefaultTimeoutStopSec=5s`
- Servicios esenciales: solo `systemd-journald`, `systemd-udevd`, `systemd-tmpfiles`

### [F1.2] cgroup-manager
Cgroups v2 para todo:
- `/sys/fs/cgroup/unified/` (único hierarchy)
- Límites de memoria para cada celda (basados en `memory.limit_in_bytes`)
- Límites de CPU con weight (no hard limits)
- Límites de I/O (`io.weight`)
- `cgroup.subtree_control` = `+memory +cpu +io +pids`

### [F1.3] sched-tune
Ajuste de scheduler:
- `chrt -f 1` para servicios críticos de sistema
- `chrt -i 0` para tareas batch
- `taskset` para fijar celdas de red a cores específicos
- Nice -5 para el orquestador, nice +5 para tareas de usuario

### [F1.4] service-watcher
Monitor ligero de servicios:
- Poll cada 15s a servicios activos (no a todos)
- Si un servicio falla 3 veces seguidas: notificar, no reiniciar en loop
- Máximo 5 reinicios en 10 minutos (backoff exponencial)
- Logging mínimo: solo errores y cambios de estado

### [F1.5] cron-minimal
Cron con solo lo esencial:
- No cron.hourly/daily/weekly (demasiados scripts)
- Tasks programadas: trim SSD, sync journal, rotación de logs
- Intervalos configurables en `/etc/rubik/timer.toml`

### [F1.6] log-forwarder
Forwarder de logs ultra-ligero:
- Los procesos escriben a stdout/stderr → systemd-journald
- Journald con `ForwardToSyslog=no`
- Sin `rsyslog` ni `syslog-ng`
- `SystemMaxFiles=5`, `MaxRetentionSec=1week`

### [F1.7] initramfs
Initramfs mínimo:
- Solo drivers necesarios para boot (storage + filesystem)
- Arranque paralelo de dispositivos
- Sin hooks innecesarios
- `MODULES=()`, `BINARIES=()`, `FILES=()`
- `HOOKS=(base udev autodetect modconf block filesystems keyboard)`

### [F1.8] power-manager
Gestión de energía:
- Sin `thermald`, sin `tlp` (son muy pesados para lo que hacen)
- Script simple que ajusta gobernador según carga de CPU
- Gestión de suspensión: `mem_sleep_default=deep`
- `power_supply` detection: si no hay batería, asumir desktop (máximo rendimiento)
- Suspensión por inactividad: 30 min sin actividad → suspend
