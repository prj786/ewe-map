---
tags:
  - ewe-map
  - roadmap
title: Roadmap — Komble
up: "[[Home]]"
---

# Roadmap — Komble

Current: **early** — frontend builds, Rust type-checks, but has **not yet
been run against a live pacman**. Treat as a working skeleton.

## The gate: first live-pacman run

Everything else is downstream of this. The checklist for the first real run:

- [ ] fresh Arch VM, install via `PKGBUILD` (`makepkg -si` — the packaging path)
- [ ] repo search/install/remove against a real sync database
- [ ] AUR flow: PKGBUILD shown → `makepkg` as user → `pacman -U` via helper
- [ ] AppImage install + launch + menu integration (`fuse2` present)
- [ ] Updates pane: `checkupdates` path (`pacman-contrib` present)
- [ ] polkit helper: one prompt per session; arity/`--` guards hold
- [ ] `ewe-conf set --no-hooks apps.installed` records source correctly
- [ ] For you: reads another machine's manifest, offers the missing apps
- [ ] fallback `pkexec pacman …` path without the helper

## Then (rough order)

1. **Updates + tray** — background check, tray indicator (half-built).
2. **For you polish** — restore from an ewe-sync restore appears in For you
   on the next look (contract exists; end-to-end untested).
3. **Plugins section** — install/manage `ewe-plugin` repos with a button,
   settings forms from manifest `settings` schemas.
4. **AUR search** — search across the AUR, not just known packages.
5. **Debian-parity features** re-examined for Arch semantics (the old build
   had features this one hasn't re-implemented yet).

## Constraints that never change (see [[Komble — Arch Forced Decisions]])

- No per-package upgrades. No shell. One polkit helper path. PKGBUILD
  visible before any AUR build. AppImages per-user, no root.
- Komble **never syncs** the file — ewe-sync does. If a feature seems to
  need fetching the file, it belongs in ewe-sync (RFC-005/006 boundary).

## Related

- [[Komble]] · [[Roadmap and Status]] · [[Open Questions]]
