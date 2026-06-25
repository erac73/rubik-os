# Storage Architecture

## Filesystem Layout

Rubik OS uses Btrfs with subvolumes for atomic snapshots and efficient space management:

```
Device: /dev/sdaX (encrypted LUKS2)
├── swap (optional swap partition, 512MB-2GB)
│
└── Btrfs pool
    ├── @          → /          (root, 15GB min)
    ├── @home      → /home      (remaining space)
    ├── @log       → /var/log   (2GB max, separate subvol)
    ├── @cache     → /var/cache (5GB max, separate subvol)
    └── @snapshots → /.snapshots (snapper managed)
```

### Mount Options
```
/, /home:     noatime,compress=zstd:3,ssd,space_cache=v2,autodefrag
/var/log:     noatime,compress=zstd:1,ssd,noautodefrag
/var/cache:   noatime,compress=zstd:1,ssd,noautodefrag
/tmp:         tmpfs,size=25%,noatime,mode=1777
/var/tmp:     tmpfs,size=10%,noatime,mode=1777
```

## tmpfs Sizing

| Mount | Calculation | Max | Min |
|-------|-----------|-----|-----|
| /tmp | 25% of RAM | 2 GB | 64 MB |
| /var/tmp | 10% of RAM | 1 GB | 32 MB |
| /run | systemd auto | 50% of RAM | 64 MB |

## I/O Optimization by Storage Type

### SSD (rotational=0)
- `fstrim` weekly
- `discard=async` mount option (batched TRIM)
- `vm.dirty_ratio=15` (SSDs handle writeback better)
- `ionice -c 4` (idle) for background tasks

### HDD (rotational=1)
- `vm.dirty_ratio=5` (less write cache = less risk on power loss)
- `vm.dirty_background_ratio=2`
- Elevator: `kyber` or `bfq` (better for rotational)
- `ionice -c 3` (idle) for all non-critical tasks
