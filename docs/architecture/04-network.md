# Network Architecture

## Stack Overview

Rubik OS uses the thinnest possible network stack:

```
┌─────────────────────────────────────────┐
│           Application Layer             │
│  (browser, git, curl, etc.)             │
├─────────────────────────────────────────┤
│          DNS Resolver                   │
│  systemd-resolved (stub 127.0.0.53)     │
├─────────────────────────────────────────┤
│         Connection Manager              │
│  systemd-networkd (wired)               │
│  iwd (wireless)                         │
├─────────────────────────────────────────┤
│           Firewall                      │
│  nftables (2 rules: drop input, allow   │
│  output, rate-limit ICMP)               │
├─────────────────────────────────────────┤
│           Kernel Network Stack          │
│  TCP/IP, routing, netfilter             │
└─────────────────────────────────────────┘
```

## Default nftables Ruleset

```nft
#!/usr/sbin/nft -f

table inet rubik-filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow established/related
        ct state established,related accept

        # Allow loopback
        iif "lo" accept

        # Rate limit ICMP
        icmp type echo-request limit rate 5/second accept
        icmpv6 type echo-request limit rate 5/second accept

        # Log dropped
        log prefix "nft-drop: " limit rate 1/minute
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

## IPv6 Strategy

- IPv6 enabled by default (dual-stack)
- Privacy extensions (RFC 4941) for temporary addresses
- No SLAAC-only networks (DHCPv6 preferred)
- `net.ipv6.conf.all.use_tempaddr=2`

## DNS Configuration

```
/etc/resolv.conf → symlink → /run/systemd/resolve/stub-resolv.conf
↓
systemd-resolved → cache (1000 entries, max TTL 3600s)
                → fallback servers: 1.1.1.1, 9.9.9.9
                → DNSSEC: allow-downgrade
```
