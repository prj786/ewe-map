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
in a component.

## Shell targets

`bar cast picker quicksettings launcher lock osd overview places player
preview settings applauncher store updates plugins widgets`

Most expose `toggle` / `show` / `hide`.

## Plugin targets

`ewe.clipboard ewe.screenshot ewe.passwords example.hello …` (any plugin
with an `IpcHandler`).

## The public verbs (contract with installed binaries)

| verb | caller | effect |
|---|---|---|
| `settings reload` | ewe-settings | re-read user-theme.json / pinned lists / display-profiles.json (HyprMon must never re-assert from a stale in-memory copy) |
| `settings ping` / `settings version` | ewe-settings | liveness + version |
| `cloud refresh` | ewe-sync | refresh the shell's account card |
| `cast scan · sinks · start <sink> · stop · status` | Cast card | drive ewe-castd |
| `cast legacy` | Cast card | escape hatch to gnome-network-displays until phase C |
| `widgets` | plugin host / arrange mode | enter/exit widget arrange (`Super+Shift+W`) |
| `plugins reload` | plugin host | re-read placement + settings without a restart; pushes `settings` into every instance declaring the property |
| `ewe.clipboard toggle` | keybind | clipboard history |
| `ewe.screenshot shoot full\|region\|activewindow · pop <path> · dismiss` | keybinds / preview stack | screenshots |
| `ewe.passwords …` | `Super+P` | fill picker |

## Gotchas

- **`qs ipc call <t> show` collides with the `qs ipc show` subcommand and
  no-ops** — bind to `toggle`.
- In-shell toggles flip a `Globals` bool directly (no IPC round-trip) —
  IPC is for *external* callers.
- `ewe-plugin` verbs restart `ewe.service` unless `--no-restart` (no QML
  hot reload; the one-second restart is honest about that; the shell's own
  apps are untouched: `KillMode=process`).

## Related

- [[Desktop Shell]] · [[Contracts and Public API]] · [[Plugin Manifest Reference]]
