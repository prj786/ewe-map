---
tags:
  - ewe-map
  - rules
title: Rules of the House
up: "[[Home]]"
---

# Rules of the House

The invariants that hold ewe together. Each rule lists **what breaks if you
violate it** — that's the part that stops mistakes.

## 1. `ewe-conf` is the only writer of `ewe.conf`

Not the shell, not ewe-settings, not Komble, not the installer. All persist
*through* it (RFC-001).

- *Breaks:* drift between two writers; the exact failure class RFC-001
  deleted. Prefs not in `THEME_MAP` get dropped by `absorb` (the 0.12.7 bug).

## 2. Secrets never enter `ewe.conf` (or any synced file)

The file syncs to the cloud. It may name an account; never a token,
password, or key. Credentials live in the keyring behind `ewe-auth` /
`ewe-cloud`.

- *Breaks:* credentials in your own cloud folder, plus the whole "restore
  the machine" promise (a restored file would be a leak).
- *Consequence:* if a future feature needs a secret in the file, **the
  feature is designed differently** (that's why Wi-Fi-PSK sync was dropped).

## 3. Layer-shell surfaces stay in the shell

Bar, dock, notifications, OSD, lock: Quickshell only. Tauri cannot create
layer-shell surfaces at all; a separate process couldn't share the
singletons.

- *Breaks:* either impossible at runtime, or crash-coupling the desktop.

## 4. IPC verbs are public API in both directions

`reload`, `ping`, `version` (Settings.qml) and every `qs ipc call <target>
<verb>` are contracts with installed binaries and plugins.

- *Breaks:* renaming one breaks an installed binary. Plugin entry points
  are additionally gated by `apiVersion` — bump it when the surface changes.

## 5. Every CLI tool prints JSON and exits 0

Callers never hang, never parse prose. Scriptable = debuggable.

- *Breaks:* the "anything you can click you can script" promise, and
  ewe-sync/Komble which drive these tools as argv.

## 6. Nothing else has a sync button

ewe-sync owns account + sync (RFC-006). Komble records, ewe-settings edits,
ewe-sync moves.

- *Breaks:* two sync pipelines racing on the same file (the RFC-002-era bug
  class).

## 7. No Google client ships

Google is optional, BYO OAuth client file; `ewe-auth` is the only thing
that touches the refresh token.

- *Breaks:* the RFC-005 promise, plus CASA/unverified-app pain.

## 8. No raw colour, size or duration in QML

Literals live only in `bin/ewe-theme` (and as `Theme.qml` fallbacks). QML
uses design-system tokens, `Theme.type.<style>`, and the motion table
(`durFast/Base/Slow/Dim`, OutCubic + InOutCubic, **no OutBack**).

- *Breaks:* the one-accent-in-whole-system-out promise; a rogue literal
  ignores the accent and every accessibility remap.

## 9. Never edit generated files or deployed `~/.config`

`hypr/generated/*` and `quickshell/*.json` are build artifacts of
`ewe-conf apply`. The repo tree is the single source of truth; the DE must
come up from a clean `git clone && ./install.sh`.

- *Breaks:* your edit vanishes at the next apply, or the repo drifts from
  what machines actually run.

## 10. Arch only, pacman only, no partial upgrades

No multi-distro branches. Installer phases route every mutating action
through `run()`/`sudo_run()` (that's what makes `--dry-run` honest and the
run re-runnable).

- *Breaks:* the all-or-nothing `pacman -S` reality plus the warn-and-skip
  resilience (a single bad package must never abort the run — the root
  cause of a past "no greeter" failure).

## 11. State that outlives the shell lives outside the shell

Casting, auth, and the plugin directory all survive `ewe.service` respawns.

- *Breaks:* a shell crash drops a cast mid-presentation, or a plugin update
  fights the shell's lifecycle.

## 12. The design system is the source of truth for every surface

`design/system/` (v3, 86 components). Read
`design/system/guidelines/40-implementation.md` before UI work. `tokens.css`
is generated; `check-spec.sh` and `check-contrast.sh` hold it to the source.

- *Breaks:* the brand book — principles, contrast guarantees (text 4.5:1,
  borders 3:1), look presets.

## Related

- [[Contracts and Public API]] · [[00 Onboarding]] · [[Decision Index]] ·
  [[The One File]]
