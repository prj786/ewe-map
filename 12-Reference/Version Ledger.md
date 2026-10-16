---
tags:
  - ewe-map
  - reference
title: Version Ledger
up: "[[Home]]"
---

# Version Ledger

Versions as of **2026-10-15** (from the repos' `VERSION` files). Update
this note on every release (see [[Release Checklist]]).

| component | version | notes |
|---|---|---|
| ewe (DE) | **0.28.0-beta** | canonical in repo-root `VERSION`; mirrored in `Globals.version` (Settings sidebar) — bump both, tag `vX.Y.Z`. 0.28.0-beta released 2026-10-15 (`v0.28.0-beta` on `52bf89a`; vendors `ewe.passwords` 1.3.0 — Super+P offers **Use Safe**; ewe-conf quoted keys keep their dots, ewe#58; `[safe] ssh_agent`/`ssh_confirm`, ewe#59; bump ewe#60); 0.27.0-beta released 2026-10-15 (Safe on the desktop: the `ewe.safe` plugin vendored, `ewe.passwords` 1.2.0 fills from Safe; ewe#55–57); 0.26.1-beta released 2026-10-14 (light mode is official, companion groundwork: the `[companion]` ewe-conf domain, kitty remote control; ewe#52 + the bump ewe#53); 0.26.0-beta released 2026-10-14 (ewe browser replaces Helium; get.sh takes the newest release; ewe#51); 0.25.2-beta released 2026-10-11 (first-party plugins survive a Restore — the payload, not ewe.conf, makes an installed `ewe.` plugin first-party; ewe#50); 0.25.1-beta released 2026-10-10 (sync that heals, Glass, plugin settings with the plugin, movable widgets, one name — D9–D13; ewe#49); 0.25.0-beta released 2026-10-04 (add-ons, quiet lid, snappy Overview, X11 scale); `vault-check` also accepts `versions.<key>_next` for a branch whose `VERSION` is already the next one |
| ewe-os (distro) | **0.13.0-beta** | its own version line, separate from the DE; 0.13.0-beta released 2026-10-04 = the ISO for ewe 0.25 (installer Plugins step, `addons` helper verb, `ewe-install --addons`, live user gets the dock; ewe-os#15). Since then on `main`, untagged: the Plugins name in the installer (#16), the light-mode ROADMAP line (#17). No ISO unless the owner asks |
| ewe-repo | rolling `x86_64` | no version — the release *is* the repository |
| komble-arch | **0.20.2-beta** | 0.20.2 (2026-10-14): ewe browser is a first-party app; Helium's card is an AUR app. 0.20.1 (2026-10-11): Add a plugin is the first group on Plugins; dialogs open in place and the scrim fades its colour (WebKitGTK blink). 0.20.0 (2026-10-10): plugin Options in a dialog, Show in bar, widget pin/lock, `--options=<id>`, the page is called Plugins. 0.19.0: the catalogue (`--addons`, `plugin_install`) |
| ewe-settings | **0.18.0-beta** | 0.18.0 (2026-10-10): plugin settings left (Dock, Mail, bar rows), Glass and transparency, a shell probe that recovers. 0.17.0: plugin-aware panes, Insomnia, guarded hypridle wake; footer shows **ewe's** version, by design |
| ewe-sync | **0.14.4-beta** | 0.14.4 (2026-10-10): the conflict banner/tray read `conflict`. 0.14.3: icon line-glyph release; RFC-006; preinstalled from ISO 0.9-alpha on |
| ewe-browser | **0.2.2-beta** | 0.2.2-beta released 2026-10-16 (`v0.2.2-beta` on `0711ece`, package `ewe-browser-0.2.2beta-1`): a page's `app-region: drag` no longer makes a dead patch (ewe-browser#9, bump #10). 0.2.1-beta released 2026-10-16 (`v0.2.1-beta` on `a43fcb3`): pages see Chrome stable's major, so Gmail stops calling the browser outdated (#7, bump #8). 0.2.0-beta released 2026-10-15 (`v0.2.0-beta` on `1e94143`, package `ewe-browser-0.2.0beta-1`): the command line (ewe-browser#3), Safe built in — suggestions and passkeys (#4), history + real sync (#5); bump #6. First release 2026-10-14 (ewe-browser#1): the package (~120 MB, castlabs runtime), served from `[ewe]`, a dependency of `ewe` ([[ewe browser replaces Helium]]). Tag `vX.Y.Z-beta` → pkgver `X.Y.Zbeta`, like the Tauri apps; version in both `package.json` files |
| ewe-safe | **0.2.0-beta** | 0.2.0-beta released 2026-10-15 (`v0.2.0-beta` on `a3fcc5e` (after #16, a test-race fix, and #17, openssh for the package check; the tag moved twice, before any package was made), package `ewe-safe-0.2.0beta-1`): passkeys (KeePassXC's format), SSH keys + an ssh-agent, `read`/`run`/`inject`/`git-credential`, the window's edit fix — #10–#13 landed through #14 (`integrate/trio`), bump #15. After the upgrade: `systemctl --user daemon-reload && systemctl --user restart ewe-safe.socket` (the socket gained the agent's socket; this locks the safe). First release 2026-10-15 ([[ewe-safe]], RFC-008): `ewe-safed`, `ewe-safe`, `ewe-safe-app`, user units; served from `[ewe]`, **opt-in** (nothing depends on it — `pacman -S ewe-safe`). Tag `vX.Y.Z-beta` → pkgver `X.Y.Zbeta` (`release.yml` rewrites `_tag`/`pkgver`); version in `VERSION`, the root and app `Cargo.toml`, `app/package.json`, `tauri.conf.json`, the PKGBUILD |
| ewe-cast | phases A+B · **0.12.3** | built 2026-08-30; C = field-proven gate; 0.12.3 = the portal 1.4.1-2.1 threshold |
| ewe-companion · ewe.companion | 0.1.0-beta · **0.3.0** | **not released**, not in ewe-repo (the first release is RFC-007's P7). On `main` since 2026-10-15: P2.9 (Safe, ewe browser, the finder; ewe-companion#1) and plugin 0.3.0 (ewe-plugin-companion#1) |
| plugin API | **3** (0.25) · 3.2 in 0.25.1 | host loads 2 and 3; 1 refused. 3.1 = `Shell.dockPrefs`/`pinnedApps`; 3.2 (0.25.1-beta) = `Shell.setSetting`, `defaultShown`/`toggle`, widget `pinLevel`/`locked`/`overlay`, setting `description`/`legacy` — additive, feature-detected |
| first-party plugins (were "add-ons") | in 0.25.1: **dock 1.1.0** (own settings) · **mail 1.1.0** (`notify` setting) · **sysmon 1.1.0** (Show in bar) · **media 1.0.2**, **places 1.0.2** (`toggle: false`) · cast, insomnia, phone, ssh, vpn **1.0.1** (one name) · clipboard **1.1.2** · screenshot **1.1.1** · passwords **1.3.0** (0.27: 1.2.0, provider `ewe`; 0.28: 1.3.0, **Use Safe**, ewe-plugin-passwords#3) · **safe 1.0.0** (new in 0.27, `migrate: false`) | as recorded in `plugins/bundle.json` (`default: false`, `migrate: true` for all); repos `prj786/ewe-plugin-<name>` |

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
- 2026-10-15, one wave: **Safe 0.2.0-beta**, **ewe browser 0.2.0-beta**,
  **ewe 0.28.0-beta** (Passwords 1.3.0 vendored) — "a real safe":
  passkeys, an SSH agent, an `op`-like CLI, Safe inside the browser,
  browser history and sync. Published to `[ewe]` the same day; no ISO.

## Related

- [[Roadmap and Status]] · [[Release Checklist]] · [[Roadmap — Desktop and One File]]
