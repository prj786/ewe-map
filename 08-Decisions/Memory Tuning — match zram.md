---
tags:
  - ewe-map
  - decisions
title: Memory Tuning — match zram
up: "[[Decision Index]]"
---

# Memory tuning that matches zram — one script writes it

**Decided 2026-11-08** (ewe 0.41.0-beta, ewe#83). ewe sets up zram on every
chassis (0.38) but left the kernel's defaults beside it. Measured on the owner's
laptop: zswap on in front of zram, swappiness 60, page-cluster 3, THP `always`
(1.3 GB of huge pages), a 3.9 GB journal, plocate scanning at boot.

- **With zram configured** (`/etc/systemd/zram-generator.conf`):
  `vm.swappiness = 180`, `vm.page-cluster = 0` (Arch wiki, zram) and **zswap
  off** — it compressed every page on its way into zram, which compresses it
  again. A machine whose only swap is a disk keeps the kernel's values.
- **Always:** transparent huge pages `madvise`; the journal capped at 1 GB;
  `plocate-updatedb.timer` `Persistent=false` + `OnBootSec=10min`.
- **One writer:** `system/tuning/apply.sh` — phase 60, the package's
  `post_install`/`post_upgrade`, `pre_remove`, `uninstall.sh --purge`. Writes only
  what differs (`/etc/sysctl.d/70-ewe-memory.conf`,
  `/etc/tmpfiles.d/70-ewe-memory.conf`, `journald.conf.d/70-ewe.conf`,
  `plocate-updatedb.timer.d/70-ewe.conf`), applies it live, exits 0; `--remove`
  deletes only files still byte-identical to ewe's. Test:
  `tests/ewe-tuning-test.sh`.
- **Not taken:** systemd-oomd — apps launched from the shell share
  `ewe.service`'s cgroup, so a kill would take the desktop. It needs per-app
  scopes first (parked).

> **Build guard:** zram's values only where zram is. *Breaks if violated:*
> swappiness 180 on a disk-only machine swaps to disk before dropping cache,
> and zswap off there loses its only compression.

## Related

- [[Decision Index]] · [[Troubleshooting Knowledge]] · [[Roadmap and Status]]
