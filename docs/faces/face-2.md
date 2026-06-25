# Face 2 — Storage

Sistema de almacenamiento optimizado para mínima E/S y máxima eficiencia. Montajes lazy, tmpfs para datos volátiles, y TRIM programado para SSDs.

## Celdas

### [F2.0] fs-layout
Estructura de directorios Rubik:
```
/            → btrfs (subvolumes: @, @home, @log, @cache)
/rubik/      → enlace simbólico a /usr/lib/rubik
/var/log/    → subvolume separado (evita que logs llenen root)
/var/cache/  → subvolume separado (se puede limpiar independientemente)
/tmp/        → tmpfs (25% de RAM, noatime)
/var/tmp/    → tmpfs (10% de RAM)
```

### [F2.1] mount-manager
Montajes inteligentes:
- `autofs` para dispositivos externos (no montar al conectarse)
- `noatime` en todas las particiones (a menos que se requiera relatime)
- `nodiratime` (no actualizar atime de directorios)
- `compress=zstd:3` para btrfs (mejor compresión/velocidad)
- `ssd_spread` para SSD (reduce escrituras)

### [F2.2] cache-io
Caché de E/S:
- `vm.dirty_ratio=10` (menos caché de escritura = menos pérdida si crash)
- `vm.dirty_background_ratio=3`
- Para discos giratorios: `ionice -c3` para tareas batch
- Para SSDs: `fstrim` semanal

### [F2.3] tmpfs-manager
- `/tmp`: 25% de RAM, límite duro 512MB en equipos con <2GB RAM
- `/var/tmp`: 10% de RAM
- `/run`: tmpfs automático de systemd (50% de RAM)

### [F2.4] trim-scheduler
- `fstrim.timer` semanal para SSDs
- Desactivado para discos giratorios

### [F2.5] dedup (opcional)
Deduplicación a nivel de bloques con VDO o duperemove:
- Ejecución programada semanal en segundo plano
- Solo modifica archivos con >10% de duplicación esperada

### [F2.6] fs-notify
- `fanotify` para detectar cambios en tiempo real
- Usado por el orquestador para detectar modificaciones de configuración
- Alternativa ligera a incron

### [F2.7] snapper (opcional)
- Snapshots automáticos del sistema (btrfs)
- Retención: 10 hourly, 5 daily, 2 monthly
- Sin snapshots de /home (demasiado grandes)

### [F2.8] defrag-lite
- Desfragmentación mensual en btrfs
- Solo archivos >100MB y con fragmentación >30%
- `btrfs filesystem defragment -r -t 256M /`
