# Face 0 — Kernel & Memory

La cara más crítica de Rubik OS. Define cómo el sistema operativo gestiona el recurso más escaso: la memoria.

## Celdas

### [F0.0] kernel-lts
Kernel Linux LTS con los siguientes parches y configuraciones:
- `CONFIG_LOW_LATENCY=y`
- `CONFIG_SCHED_MUQSS=y` (o `CONFIG_SCHED_BORE` para mejor interactividad en equipos lentos)
- `CONFIG_ZRAM=y`, `CONFIG_ZRAM_WRITEBACK=y`
- `CONFIG_ZSWAP=y`, `CONFIG_ZPOOL=m`
- `CONFIG_CGROUP_MEMORY=y`
- `CONFIG_MEMCG=y`
- `CONFIG_PSI=y` (Pressure Stall Information)
- `CONFIG_BLK_CGROUP=y`
- `CONFIG_CFS_BANDWIDTH=y`
- Tamaño mínimo del kernel: < 8 MB comprimido

### [F0.1] memory-compression
Gestión dinámica de ZRAM:
- Algoritmo: zstd (mejor ratio compresión/velocidad)
- Tamaño: 50-75% de la RAM total (configurable)
- Prioridad: mayor que swap en disco
- Monitoreo continuo: si la compresión supera 3:1, reduce tamaño
- Discos ZRAM separados: swap, /tmp (opcional)

### [F0.2] swap-manager
Swap inteligente:
- Swapfile (no partición) para flexibilidad
- `vm.swappiness = 10` (solo swap cuando es realmente necesario)
- `vm.vfs_cache_pressure = 50` (retención de caché de inodos/dentry)
- Sistema de priorización: desaloja primero páginas anónimas inactivas
- `vm.watermark_boost_factor = 0`, `vm.watermark_scale_factor = 150`

### [F0.3] oom-guard
EarlyOOM con heurística mejorada:
- Activa OOM killer antes de que el sistema se vuelva inmanejable
- Reporta proceso candidato y memoria libre antes de matar
- Modo "notify": primero avisa al usuario, luego mata
- Ignora procesos con `OOMScoreAdjust=-1000` (systemd-core)
- Policy: mata procesos con mayor `OOMScore` primero

### [F0.4] hugepages
Transparent Hugepages (THP) con configuración inteligente:
- `transparent_hugepage=madvise` (solo cuando se solicita)
- Reserva estática para VMs y bases de datos
- `khugepaged` con intervalos largos para reducir CPU

### [F0.5] cache-tune
Autotuning de caché del kernel:
- `vm.dirty_ratio = 10`, `vm.dirty_background_ratio = 3` (menos escritura diferida en sistemas con poca RAM)
- `vm.page-cluster = 0` (no leer páginas adyacentes en swap)
- `vm.min_free_kbytes` calculado como 1% de RAM
- Ajuste dinámico basado en PSI (Pressure Stall Information)

### [F0.6] irq-balance
IRQBalance con reglas específicas para Rubik:
- IRQs de almacenamiento a cores 0-1
- IRQs de red a cores 2-3
- IRQs de GPU a core 4
- Interrupciones del temporizador en core separado
- Configuración de máscaras de afinidad via `/proc/irq/*/smp_affinity`

### [F0.7] cpu-gov
Gobernador de CPU:
- `scaling_governor = conservative` (por defecto)
- En sistemas modernos: `schedutil` (integración con scheduler)
- `intel_pstate=passive` en Intel (para usar gobernadores genéricos)
- Script de monitoreo que sube a `performance` si detecta carga > 80%

### [F0.8] mem-forecast
Predictor de uso de memoria (ML simple):
- Recolecta métricas de PSI, uso de swap, ZRAM cada 30s
- Modelo de regresión lineal simple para predecir OOM en próximos 60s
- Si predicción > 90% de uso: activa compresión agresiva, notifica al usuario

## Archivos de Configuración

```
/etc/rubik/faces/face-0.conf
/etc/sysctl.d/90-rubik-memory.conf
/etc/udev/rules.d/99-rubik-zram.rules
/usr/lib/rubik/faces/face-0.sh
```
