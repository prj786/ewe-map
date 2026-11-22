---
tags:
  - ewe-map
  - decisions
title: RFC-010 — eep
up: "[[Home]]"
---

# RFC-010 — eep, apps from the Nix binary cache

*Status: **accepted** 2026-11-22 (owner: "go do it", then "commit and
release"); **released** the same day as eep 0.1.0-beta with ewe
0.48.1-beta, Komble 0.26.0-beta and ewe-apps 0.3.0-beta (decision 74).
[[Rules of the House]] Rule 10 now reads "pacman for the system, eep for
apps". Full text: `ewe/docs/RFC-010-eep.md`; repo
[prj786/eep](https://github.com/prj786/eep) (`PROTOTYPE.md` §13,
`bench/RESULTS.md`); component note [[eep]].*

## The idea

One card per app in `~/Applications`: card there = app in the launcher;
move the card to the Trash = app gone; restore it = app back, nothing to
download. Apps come prebuilt and signed from cache.nixos.org
(nixos-unstable, Arch-current versions); eep's data site
(`https://prj786.github.io/eep`, the repo's `gh-pages`) carries a
precomputed index so the client never evaluates Nix, and **binary patches**
for updates, which Nix still verifies byte for byte. One root step sets up
the Mesa driver for Nix apps and keeps it current.

## How people meet it

- **Komble** (0.26.0-beta) lists eep apps as a source when `eep` is on
  PATH: search, install, update, remove, no password.
- **ewe Files** (ewe-apps 0.3.0-beta) shows **Applications** under Home in
  the sidebar; cards show as their app (name without `.eep`, the embedded
  icon); **Remove app** replaces Move to Trash for cards there.
- **The website** `/apps/` (prj786.github.io#17): a Get button per app
  downloads its card; double-click it or drag it into Applications to
  install.
- eep itself is opt-in: `pacman -S eep` from `[ewe]` (or Komble); nothing
  depends on it, it pulls in `extra/nix`.

## Numbers (ewe VM)

Weekly update 129 MB instead of 542 MB; daily 30 MB instead of 400 MB;
warm launch within 2 % of pacman's; `eep run` 2 ms; delete → launcher in
0.5 s, gc frees 99.7 %. Costs: first install 2.9× pacman's bytes, disk
2.6×, small GTK apps +40 MB RAM, no unfree apps, no mDNS names in Nix apps.

## Build-guard

Gotchas found on the way live in `eep/PROTOTYPE.md` §10 (1–32) and
[[Troubleshooting Knowledge]] ("eep and Applications"): Arch's `nix` has no
`nix-users` group (the package uses a 1777 cache dir instead); a power cut
can leave "valid" store paths with empty files (eep's crash journal); keep
the app's own desktop-file name and mark ownership with `X-Eep-Id`; ewe's
shell leaks Arch's EGL/Vulkan pins to apps; Nix's glibc can't resolve the
hostname without an /etc/hosts line; a watcher must re-exec itself when its
binary is replaced.

## Related

- [[Decision Index]] · [[Rules of the House]] · [[eep]] · [[Komble]] · [[ewe-apps]] · [[Parked and Rejected Ideas]]
