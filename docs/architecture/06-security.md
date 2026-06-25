# Security Architecture

## Defense in Depth

Rubik OS implements a layered security model:

```
Layer 1: Kernel Hardening
├── Stack protector, freelist randomization
├── Restricted dmesg, kptr_restrict=2
└── YAMA LSM (ptrace restrictions)

Layer 2: AppArmor
├── Per-cell profiles in enforce mode
├── Default-deny for all cells
└── System-wide base profile

Layer 3: cgroup Isolation
├── Each cell in its own cgroup
├── Memory, CPU, IO limits enforced
└── No cell can starve another

Layer 4: Namespace Isolation
├── Cells use PrivateTmp, ProtectSystem
├── NoNewPrivileges for all cells
└── network namespace separation (optional)

Layer 5: Sandbox Execution
├── bubblewrap for untrusted processes
├── firejail for applications (optional)
└── seccomp filters for system calls
```

## AppArmor Profiles

Each cell gets an automatically generated AppArmor profile:

```apparmor
# Profile for rubik-cell@F0.1 (memory-compression)
profile rubik-cell-F0.1 {
    #include <abstractions/base>

    /usr/lib/rubik/cells/memory-compression.sh ix,
    /usr/bin/bash ix,
    /dev/zram* rw,
    /sys/block/zram*/** rw,
    /proc/pressure/** r,
    /proc/meminfo r,
    /proc/swaps r,
    /run/rubik/** rw,

    network,
    deny /home/** rw,
    deny /etc/** rw,
}
```

## Threat Model

| Threat | Mitigation |
|--------|-----------|
| Malicious package | Signed packages (SigLevel=Required) |
| Buffer overflow | Kernel hardening, ASLR, stack canaries |
| Privilege escalation | NoNewPrivileges, AppArmor |
| Fork bomb | TasksMax per cgroup (32) |
| Memory exhaustion | MemoryMax per cgroup (256 MB) |
| Rootkit | Kernel module signing, lockdown mode |
| Data at rest | LUKS2 encryption (Argon2) |
| Data in transit | Default-deny firewall |
