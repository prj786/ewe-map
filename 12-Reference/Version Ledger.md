---
tags:
  - ewe-map
  - reference
title: Version Ledger
up: "[[Home]]"
---

# Version Ledger

Versions as of **2026-09-18** (from the repos' `VERSION` files). Update
this note on every release (see [[Release Checklist]]).

| component | version | notes |
|---|---|---|
| ewe (DE) | **0.22.3-beta** | canonical in repo-root `VERSION`; mirrored in `Globals.version` (Settings sidebar) — bump both, tag `vX.Y.Z` |
| ewe-os (distro) | **0.12.4-beta** | its own version line, separate from the DE |
| ewe-repo | rolling `x86_64` | no version — the release *is* the repository |
| komble-arch | early skeleton | "not yet run against a live pacman" |
| ewe-settings | — | footer shows **ewe's** version, by design |
| ewe-sync | shipped | RFC-006; preinstalled from ISO 0.9-alpha on |
| ewe-cast | phases A+B | built 2026-08-30; C = field-proven gate |

## Versioning rules

- **Semver** `MAJOR.MINOR.PATCH` with `-alpha`/`-beta` until the first
  stable cut. Beta = usable, daily-drivable, but expect rough edges and
  breaking changes between versions.
- Named targets: **1.0-beta "Dolly"**; earlier milestones referenced
  `0.4-alpha` (RFC-001 phase 6), `0.5-alpha "connected"` (RFC-002), ISO
  `0.9-alpha` (RFC-006 preinstall).
- `VERSIONS` (plural) is unrelated to the release version — it documents
  **minimum tool floors**: Hyprland ≥ 0.55 (Lua config), Quickshell ≥ 0.2.
  It is documentation, not a lockfile (Arch rolls).

## Rename history (the migrations)

- **2026-08-19 — the deep rename**: `hypr-shell` → **ewe**. User unit
  `ewe.service`, state `~/.local/state/ewe`, every system file `*ewe*`.
  Old-name references remaining in phases 20/30/32/35 + deploy/startup
  scripts are **migrations** — leave them until a release or two has
  passed.
- `ewe-settings` was formerly `hypr-shell-settings`: the package
  `provides`/`replaces` the old name and ships a `hypr-settings`
  compatibility symlink.
- Old URLs redirect; a dev checkout may still sit in a dir called
  `hypr-shell` — that's outside the repo.

## Release history notes

- ewe 0.9.0: RFC-001 phases 1–5 landed.
- ewe 0.9.3 (Komble): For You restores from the manifest.
- ewe 0.9.7: `ewe-conf` generates `input.lua` + `user.lua` too.
- 0.12.7: the "Top bar settings do nothing" bug — prefs not in `THEME_MAP`
  were dropped by `absorb` (now a rule, see [[Rules of the House]]).

## Related

- [[Roadmap and Status]] · [[Release Checklist]] · [[Roadmap — Desktop and One File]]
