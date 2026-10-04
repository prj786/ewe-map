---
tags:
  - ewe-map
  - reference
title: IPC Verb Reference
up: "[[Home]]"
---

# IPC Verb Reference — `qs ipc`

External control (keybinds, scripts, apps) uses
`qs ipc call <target> <fn>` against an `IpcHandler { target: "<name>" }`
in a component. Every target and verb is public API (Rule 4).

## Core targets (the shell proper, 0.25)

`bar picker quicksettings lock osd overview preview settings applauncher
store updates plugins widgets google cloud`

Most expose `toggle` / `show` / `hide`. (`cloud`, `google` and `mail` were
missing from this sheet before 0.25 — drift, now listed; `mail` moved to an
add-on.)

## Add-on targets — present only while the add-on is installed + enabled

| add-on | target | legacy alias (kept, same verbs) | verbs |
|---|---|---|---|
| [[Cast Plugin]] | `ewe.cast` | `cast` | `toggle · scan · start <sink-id> · stop · status · legacy` |
| [[Dock Plugin]] | `ewe.dock` | `launcher` (`toggle · show · hide`) | `launcher · showLauncher · hideLauncher · isLauncherOpen` |
| [[Places Plugin]] | `ewe.places` | `places` | `toggle · show · hide` |
| [[Music Plugin]] | `ewe.media` | `player` (`toggle · hide`) | `toggle · show · hide` |
| [[Mail Plugin]] | `ewe.mail` | `mail` | `status · refresh · fetch · setNotify <bool>` (`status` field set byte-identical to pre-0.25) |
| [[Insomnia Plugin]] | `ewe.insomnia` | — (new) | `toggle · on · off · status` |
| [[Clipboard Plugin]] | `ewe.clipboard` | — | `toggle` |
| [[Screenshot Plugin]] | `ewe.screenshot` | — | `shoot full\|region\|activewindow · pop <path> · dismiss` |
| [[Passwords Plugin]] | `ewe.passwords` | — | `toggle` … (`Super+P`) |
| third-party | `<ns>.<name>` | — | whatever the plugin registers |

Quick-settings pages served by add-ons: `qs ipc call quicksettings tab
ssh|vpn|mobile|mail|cast` ([[SSH Plugin]], [[VPN Plugin]], [[Phone Plugin]],
[[Mail Plugin]], [[Cast Plugin]]). An unknown key falls back to `home`.

## Not IPC but public: the Hyprland global shortcut `ewe:overview`

The Overview opens from a Hyprland `global` (Super as a *release* bind) —
17 ms instead of a 44–160 ms `qs ipc` round trip. Users may bind
`ewe:overview` in `user.lua`; the 3-finger swipe still uses `overview
toggle`. `ewe-globalshortcuts` ignores `ewe:*` names.

## The public verbs (contract with installed binaries)

| verb | caller | effect |
|---|---|---|
| `settings reload` | ewe-settings | re-read user-theme.json / pinned lists / display-profiles.json (HyprMon must never re-assert from a stale in-memory copy) |
| `settings ping` / `settings version` | ewe-settings | liveness + version |
| `cloud refresh` | ewe-sync | refresh the shell's account card |
| `google status · syncSoon` | ewe-settings, ewe-sync | core Google (OAuth/Calendar/Drive/sync) — stays core after the Gmail split |
| `mail status` | ewe-settings → Account | served by the `ewe.mail` add-on; **a missing target is not an error** for Settings |
| `ewe.cast scan · start <sink> · stop · status` (alias `cast`) | Cast tile/page | drive ewe-castd |
| `ewe.cast legacy` (alias `cast legacy`) | Cast page | escape hatch to gnome-network-displays until phase C |
| `widgets` | plugin host / arrange mode | enter/exit widget arrange (`Super+Shift+W`) |
| `plugins reload · list · apiVersion · safeMode` | plugin host | re-read placement + settings without a restart; what was instantiated; the host's API version; safe-mode flag |
| `ewe.clipboard toggle` | keybind | clipboard history |
| `ewe.screenshot shoot …` | keybinds / preview stack | screenshots |
| `ewe.passwords …` | `Super+P` (manifest keybind) | fill picker |
| `ewe.cast toggle` | `Super+Shift+C` (manifest keybind) | hang up, or open the sink list |

## Gotchas

- **`qs ipc call <t> show` collides with the `qs ipc show` subcommand and
  no-ops** — bind to `toggle`.
- In-shell toggles flip a `Globals` bool directly (no IPC round-trip) —
  IPC is for *external* callers.
- `ewe-plugin` verbs restart `ewe.service` unless `--no-restart`; even then
  `install`/`enable` run `hyprctl reload` and `set`/`place` poke `plugins
  reload` against the **current** `HYPRLAND_INSTANCE_SIGNATURE` /
  `WAYLAND_DISPLAY` — unset both from any harness
  ([[Troubleshooting Knowledge]]).
- `qs` matches `plugins reload` by **config path**: in the nested harness
  the tool's poke never reaches `qs -p <checkout>` — use `driver.sh ipc
  plugins reload`; with the host display it hits the live shell.
- A keybind in a manifest must target the plugin's own id or an
  `ipcAliases` entry (API ≥ 3).

## Related

- [[Desktop Shell]] · [[Contracts and Public API]] · [[Plugin Manifest Reference]] ·
  [[Plugin System]]
