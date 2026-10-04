---
tags:
  - ewe-map
  - reference
title: Version Ledger
up: "[[Home]]"
---

# Version Ledger

Versions as of **2026-10-04** (from the repos' `VERSION` files). Update
this note on every release (see [[Release Checklist]]).

| component | version | notes |
|---|---|---|
| ewe (DE) | **0.25.0-beta** | canonical in repo-root `VERSION`; mirrored in `Globals.version` (Settings sidebar) — bump both, tag `vX.Y.Z`. 0.25.0-beta released 2026-10-04 (add-ons, quiet lid, snappy Overview, X11 scale); `vault-check` also accepts `versions.<key>_next` for a branch whose `VERSION` is already the next one |
| ewe-os (distro) | **0.12.4-beta** released · **0.13.0-beta** in progress | its own version line, separate from the DE; 0.13.0-beta = the ISO for ewe 0.25 (installer Add-ons step, `addons` helper verb, `ewe-install --addons`, live user gets the dock) on `feat/addons-installer`, not yet tagged — `ewe_os_next` in `ewe-facts.json` until it merges |
| ewe-repo | rolling `x86_64` | no version — the release *is* the repository |
| komble-arch | **0.19.0-beta** | Add-ons catalogue (`--addons`, `plugin_install`); still not run against a live pacman |
| ewe-settings | **0.17.0-beta** | add-on aware panes, Insomnia, guarded hypridle wake; footer shows **ewe's** version, by design |
| ewe-sync | **0.14.3-beta** | icon line-glyph release; RFC-006; preinstalled from ISO 0.9-alpha on |
| ewe-cast | phases A+B · **0.12.3** | built 2026-08-30; C = field-proven gate; 0.12.3 = the portal 1.4.1-2.1 threshold |
| plugin API | **3** (0.25) | host loads 2 and 3; 1 refused |
| add-ons | clipboard **1.1.1** · screenshot **1.1.0** · passwords **1.1.0** · insomnia, sysmon, ssh, vpn, media, places, phone, mail, cast, dock **1.0.0** | as recorded in `plugins/bundle.json` (`default: false`, `migrate: true` for all); repos `prj786/ewe-plugin-<name>` |

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
- 0.21.0-beta (2026-09-16): clipboard/screenshot/passwords extracted into
  bundled plugins.
- 0.24.1-beta (2026-09-25): shell death = Hyprland toplevel-export race;
  DNS → systemd-resolved.
- 0.25.0-beta (2026-10-04): **add-ons** — plugin API 3, the
  `Shell` singleton, `ewe-plugin install/migrate`, ten features carved out
  of the shell into `ewe.*` add-ons, nothing pre-installed on a fresh
  machine (D1–D8, [[Decision Index]]); quiet lid; one-step Overview; X11
  scale from the DRM-connected set; `post_upgrade` refreshes the greeter.

## Related

- [[Roadmap and Status]] · [[Release Checklist]] · [[Roadmap — Desktop and One File]]
