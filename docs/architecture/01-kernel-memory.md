# Kernel & Memory Architecture

## Kernel Configuration (Rubik variant)

Based on Linux LTS with selective hardening and memory optimizations:

### Essential Options
```
CONFIG_LOW_LATENCY=y
CONFIG_HZ_100=y                # 100Hz timer for low overhead
CONFIG_SCHED_BORE=y            # Burst-Optimized Response Energy
CONFIG_PREEMPT_VOLUNTARY=y     # Balance between throughput and latency
CONFIG_NR_CPUS=64              # Support up to 64 cores
CONFIG_LOCALVERSION="-rubik"
CONFIG_KERNEL_GZIP=y           # Smallest kernel compression
```

### Memory Management
```
CONFIG_ZRAM=y
CONFIG_ZRAM_WRITEBACK=y
CONFIG_ZRAM_MEMORY_TRACKING=y
CONFIG_ZSWAP=y
CONFIG_ZSWAP_ZPOOL_DEFAULT="zstd"
CONFIG_MEMCG=y
CONFIG_MEMCG_KMEM=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_MISC=y
CONFIG_PSI=y                   # Pressure Stall Information
CONFIG_PSI_DEFAULT_DISABLED=n
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
```

### Security Hardening
```
CONFIG_STACKPROTECTOR_STRONG=y
CONFIG_SLAB_FREELIST_RANDOM=y
CONFIG_SLAB_FREELIST_HARDENED=y
CONFIG_RANDOMIZE_KSTACK_OFFSET=y
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_YAMA=y
CONFIG_DEFAULT_SECURITY_APPARMOR=y
```

### Unnecessary (disabled to save size)
```
CONFIG_IPV6=n                  # Optional, can be built as module
CONFIG_WIRELESS=n              # Built as module, loaded by iwd
CONFIG_SOUND=n                 # Built as module
CONFIG_DRM=n                   # Built as module
CONFIG_USB_SUPPORT=n           # Built as module
```

## ZRAM Strategy

Rubik OS uses ZRAM as the primary swap layer:

```
RAM → [zstd compression] → ZRAM device → [fallback] → disk swap

Priority:
  100 — ZRAM (primary, compressed RAM)
  50  — Swapfile (secondary, disk)
```

The ZRAM size is dynamically calculated as 75% of total RAM, with monitoring
that adjusts based on memory pressure (PSI metrics).

## OOM Management

Two-layer approach:
1. **PSI monitoring** (kernel-level) — detects memory pressure before OOM
2. **earlyoom** (userspace) — intervenes when memory < 20%

Processes in cgroup `/sys/fs/cgroup/rubik/critical/` (orchestrator, kernel
services) are protected with `OOMScoreAdjust=-1000`.
