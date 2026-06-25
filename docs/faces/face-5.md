# Face 5 — Security & Isolation

Capa de seguridad de Rubik OS. Cada celda ejecuta en su propio espacio aislado. AppArmor, bubblewrap, y aislamiento de cgroups para contener daños.

## Celdas

### [F5.0] apparmor
AppArmor con perfiles para cada celda:
- Perfiles en `/etc/apparmor.d/rubik/`
- Modo `enforce` para celdas críticas (F0, F1)
- Modo `complain` para celdas de usuario (F4)
- Perfil por defecto: solo permite acceder a `/usr/lib/rubik/`, `/run/rubik/`, `/etc/rubik/`

### [F5.1] sandbox-exec
bubblewrap para ejecutar comandos con restricciones:
- `bwrap --unshare-net --proc /proc --dev /dev --ro-root /usr`
- Sin acceso a red, sin acceso a home (ro), sin IPC
- Usado por el orquestador para ejecutar celdas no confiables

### [F5.2] audit (opcional)
Auditoría ligera:
- Solo eventos esenciales: cambios en `/etc/rubik/`, ejecución de celdas
- Log en `/var/log/rubik/audit.log`
- Rotación diaria, retención 7 días

### [F5.3] crypto
Cifrado LUKS:
- `/boot` sin cifrar (necesario para GRUB)
- Root + Home cifrados con LUKS2 (Argon2)
- Gestión de claves vía `systemd-cryptenroll`
- Opcional: TPM2 desbloqueo automático

### [F5.4] integrity
Integridad de paquetes:
- Verificación de firmas GPG en todos los paquetes (pacman `SigLevel=Required`)
- Verificación de sumcheck SHA256 en actualizaciones
- `pacman -Qkk` semanal para verificar integridad de archivos instalados

### [F5.5] firejail (opcional)
Aislamiento adicional de aplicaciones:
- Perfiles predefinidos para navegador, PDF reader, editor
- Sin acceso a red para aplicaciones que no la necesitan
- Sin acceso a home para aplicaciones no confiables

### [F5.6] hardened-kernel
Parches de seguridad para el kernel:
- Kernel-hardening configs: `CONFIG_STACKPROTECTOR_STRONG=y`
- `CONFIG_SLAB_FREELIST_RANDOM=y`
- `CONFIG_SLAB_FREELIST_HARDENED=y`
- `CONFIG_RANDOMIZE_KSTACK_OFFSET=y`
- `CONFIG_SECURITY_DMESG_RESTRICT=y`
- `kernel.dmesg_restrict=1`
- `kernel.kptr_restrict=2`

### [F5.7] update-auth
Autenticación de actualizaciones:
- `sudo` con `NOPASSWD` solo para `pacman -Sy rubik-*`
- Todas las actualizaciones deben estar firmadas
- `Pacman.conf`: `RemoteFileSigLevel=Required`

### [F5.8] cell-isolation
Aislamiento entre celdas:
- Cada celda ejecuta en su propio cgroup (`/sys/fs/cgroup/rubik/<cell>`)
- Memory.max = 256MB por celda (configurable)
- CPU.weight basado en prioridad
- IO.weight = 100 para celdas de sistema, 50 para celdas de usuario
- `TasksMax=32` por celda (evitar fork bombs)

## Perfil AppArmor por Defecto

```
#include <tunables/global>

profile rubik-cell /usr/lib/rubik/cells/*.sh {
    #include <abstractions/base>
    #include <abstractions/bash>

    /usr/lib/rubik/** r,
    /etc/rubik/** r,
    /run/rubik/** rw,
    /var/log/rubik/** w,
    /proc/** r,
    /sys/fs/cgroup/** rw,
    /dev/null rw,

    deny /home/** rw,
    deny /root/** rw,
    deny network,
    deny /etc/shadow r,
}
```
