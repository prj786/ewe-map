---
tags:
  - ewe-map
  - rules
title: Contracts and Public API
up: "[[Home]]"
---

# Contracts and Public API

The machine-readable surfaces of the project — the things other processes,
plugins, and cloud services bind to. Renaming or reshaping any of these is a
**breaking change** and must happen as one wave across all repos.

## Files & who owns them

| file | owner (writer) | readers | never edit by hand? |
|---|---|---|---|
| `~/.config/ewe/ewe.conf` | `ewe-conf` only | everything | hand edits allowed, round-trips; comments regenerated |
| `~/.config/hypr/generated/monitors.lua` | shell `HyprMon.qml` **by design** (runtime-reactive) | Hyprland | yes — generated |
| `~/.config/hypr/generated/input.lua` | ewe-settings / shell (via `ewe-conf set desktop.input`) | Hyprland | yes |
| `~/.config/hypr/generated/user.lua` | `ewe-conf apply` | Hyprland | yes |
| `~/.config/hypr/generated/windowrules.lua` | ewe-settings only | Hyprland | yes |
| `~/.config/hypr/generated/animations.lua` | ewe-settings only | Hyprland | yes |
| `~/.config/hypr/generated/wallpapers.conf` | ewe-settings | `scripts/wallpaper.sh` | yes |
| `~/.config/hypr/generated/hypridle.conf` | shell **by design** (battery-reactive) | hypridle | yes |
| `~/.config/hypr/generated/kb-per-window.disabled` | ewe-settings (flag file) | `autostart.sh` | yes |
| `~/.config/hypr/generated/plugin-keybinds.lua` | `ewe-plugin` verbs | `hyprland.lua` | yes |
| `~/.config/quickshell/user-theme.json` | shell + ewe-settings (atomic, merged) | shell | no — shared, merge both sides |
| `~/.config/quickshell/animations.json` | ewe-settings (source of truth) | shell `Theme.dur*/ease` on reload | no |
| `~/.config/quickshell/window-rules.json` | ewe-settings | shell | no |
| `~/.config/quickshell/display-profiles.json` | ewe-settings | shell `HyprMon` | no |
| `~/.config/quickshell/input-devices.json` | ewe-settings | shell | no |
| `~/.config/quickshell/startup-apps.json` | ewe-settings | `autostart.sh` (jq) | no |
| `~/.config/ewe/cloud.json` | `ewe-cloud` | ewe-sync, shell | no |
| `~/.local/state/ewe/sync.json` | `ewe-conf` | the sync conflict rule | no |
| `~/.local/state/ewe/plugin-boots.json` | `ewe-plugin` | crash guard | no |
| `~/.config/ewe/plugins/<id>/` | `ewe-plugin` | shell PluginHost | code — never synced, never touched by upgrades |

Sourcing order in `hyprland.lua`: `user.lua` → `input.lua` → `monitors.lua`
→ `windowrules.lua` → `animations.lua` (missing files are a no-op), so
dedicated files win over stale lines in older `user.lua`.

## IPC: `qs ipc call <target> <verb>`

Targets: `bar cast picker quicksettings launcher lock osd overview places
player preview settings applauncher store updates plugins widgets` + plugin
targets (`ewe.clipboard`, `ewe.screenshot`, `ewe.passwords`, `example.hello`…).

Public verbs that installed binaries depend on (in `Settings.qml`):
**`reload` · `ping` · `version`** — plus `cloud refresh` (ewe-sync),
`widgets` / `plugins reload` (plugin host), `cast legacy` (gnd escape
hatch).

> **Gotcha:** `qs ipc call <t> show` collides with the `qs ipc show`
> subcommand and no-ops — bind to **`toggle`**.

## Keyring services (Secret Service)

| service | holds | managed by |
|---|---|---|
| `ewe-cloud` | Nextcloud app password | `ewe-cloud` (Login Flow v2) |
| (Google) | refresh token | `ewe-auth` only |

## The plugin surface

- `manifest.json` schema v1 — fields, kinds, settings types:
  [[Plugin Manifest Reference]].
- Public QML (`import qs`): `Theme` (Ewe v3 tokens), public `Globals`
  subset, `Log` — frozen behind **`apiVersion: 1`**.
- Settings keys in `ewe.conf` under `[plugins.widgets]` /
  `[plugins.settings]`, keyed by **quoted id** (dots!) — always written as
  whole tables.

## The ewe.conf schema

See [[EWE-CONF Schema Reference]].

## Cloud layout (your Nextcloud)

```
ewe/ewe.conf                 the one file
ewe/ewe.conf.meta.json       {machine, saved_at, schema}
ewe/machines/<name>.json     per-machine ewe version + app count
```

## Related

- [[Rules of the House]] · [[The One File]] · [[IPC Verb Reference]] ·
  [[Storage Map]]
