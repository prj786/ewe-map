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
| `~/.local/state/ewe/sync.json` | `ewe-conf` | the sync conflict rule — `id`, `remote_modified`, `remote_machine`, `machine_id`, `local_synced_at`, and since D12 `sha256` (bytes last pushed/pulled), `pending` (uploads in flight), `checked`, `adopted` ([[Sync Conflicts Are About Content]]) | no |
| `~/.local/state/ewe/plugin-boots.json` | `ewe-plugin` | crash guard | no |
| `~/.config/ewe/plugins/<id>/` | `ewe-plugin` (`add`, `install`, `migrate`, `seed`) | shell PluginHost | code — never synced, never touched by upgrades |
| `~/.local/state/ewe/addons-migrated` (0.25) | `ewe-plugin migrate` | `migrate` itself | JSON list of first-party plugin ids already considered — local, **never synced** (name kept — [[One Name — Plugins]]) |
| `~/.local/state/ewe/plugins/<id>/` (0.25) | the plugin (`stateDir`, created on demand) | the plugin | never synced |
| `<payload>/plugins/<id>/` + `plugins/bundle.json` (0.25) | `scripts/vendor-plugins.sh` (repo side) | `ewe-plugin install/migrate/seed/list` | yes — vendored; fix the plugin in its repo |
| `~/.config/quickshell/places.json` · `mail-state.json` · `google-mail.json` · `kdeconnect-state.json` · `ssh-browse/` | the plugins that replaced the built-ins (paths **kept**) | ewe-conf mirrors `places.json` ↔ `apps.places` | no |

Sourcing order in `hyprland.lua`: `user.lua` → `input.lua` → `monitors.lua`
→ `windowrules.lua` → `animations.lua` (missing files are a no-op), so
dedicated files win over stale lines in older `user.lua`.

## IPC: `qs ipc call <target> <verb>`

**Core targets** (0.25): `bar picker quicksettings lock osd overview preview
settings applauncher store updates plugins widgets google cloud`.
**Plugin targets** — present only while the plugin is installed and
enabled — with the legacy target each keeps as an **alias** (Rule 4):
`ewe.cast` (`cast`), `ewe.dock` (`launcher`), `ewe.places` (`places`),
`ewe.media` (`player`), `ewe.mail` (`mail`), `ewe.insomnia`,
`ewe.clipboard`, `ewe.screenshot`, `ewe.passwords`; third-party
(`example.hello`…). Quick-settings page keys `ssh vpn mobile mail cast`
(`quicksettings tab <key>`) are served by plugins; the core keeps `home
wifi bt audio cal notifs` and an unknown key falls back to `home`.

Public verbs that installed binaries depend on (in `Settings.qml`):
**`reload` · `ping` · `version`** — plus `cloud refresh` (ewe-sync),
`widgets` / `plugins reload|list|apiVersion|safeMode` (plugin host), `mail
status|setNotify` (the Mail plugin; ewe-settings stopped calling it in
D10 — `setNotify` now writes the plugin's `notify` setting), `google
status|syncSoon` (core), `cloud status` (ewe-settings → User), `ewe.cast legacy` (gnd
escape hatch). The Hyprland **global shortcut `ewe:overview`** is public
too (users bind it in `user.lua`).

> **Gotcha:** `qs ipc call <t> show` collides with the `qs ipc show`
> subcommand and no-ops — bind to **`toggle`**.

## Keyring services (Secret Service)

| service | holds | managed by |
|---|---|---|
| `ewe-cloud` | Nextcloud app password | `ewe-cloud` (Login Flow v2) |
| (Google) | refresh token | `ewe-auth` only |

## The plugin surface (API 2 | 3 — [[Plugin API 3]])

- `manifest.json` schema v1 — fields, kinds, settings types:
  [[Plugin Manifest Reference]]. The host loads **`apiVersion` 2 and 3**
  (1 is refused). Keybind targets must be the plugin's own id or one of its
  `ipcAliases` (API ≥ 3); `ipcAliases` are **`ewe.` plugins only**.
- Public QML (`import qs`), frozen behind `apiVersion`: `Theme` (Ewe v3
  tokens), the `Globals` API 2 subset, `Log`, and since 0.25 the **`Shell`
  singleton** and the **public components** (`Tile`, `Qs*`, `QsFieldInput`,
  `Text*`, `Glyph`, `BarModule`, `BarSep`, `BarStatusGlyph`,
  `AnchoredPopup`, plus `Toggle Slider Meter ListWell ListRow SectionTitle
  Badge Spinner Avatar Elevation`).
- Settings keys in `ewe.conf` under `[plugins.widgets]` /
  `[plugins.settings]`, keyed by **quoted id** (dots!) — always written as
  whole tables; setting keys match `^[a-z][a-z0-9_]{0,31}$`. Widget fields:
  `x y output layer(desktop|top|overlay) visible pin_level(top|overlay)
  locked` ([[Desktop Widgets — always movable, pin to a level]]). Show in
  bar: `desktop.bar.show."plugin:<id>"` (a bool; absent = the manifest's
  `defaultShown`).

### The `Shell` singleton (API 3; additions are 3.x, feature-detected)

| | member |
|---|---|
| read | `apiVersion` (3) · `overviewOpen` `quickSettingsOpen` `lowPower` `onBattery` `locked` `dnd` · `bottomInset` `bottomReserved` `dockPresent` · `dockPrefs {enabled, autohide, iconSize}` · `pinnedApps` · `activeCount` · `dockItems` · `primaryScreenName` · `popupsClosing` |
| call | `toast(text, kind)` · `openQuickSettings(tab)` `closeQuickSettings()` · `openSettings(page)` `openStore(page)` (`komble --<page>`, e.g. `addons`) · `launch(desktopId)` `focusApp([classes])` · `registerAction(name, fn)` `runAction(name, anchor)` · `setActive(name, on)` `isActive(name)` · `setDockItemShown(id, on)` `dockItemShown(id)` · `setBottomInset(id, px, reserved)` · `setPinned(id, on)` · `anchorFor(item, window)` → `{screen, x, y, edge, item}` · `toggleOverview()` · `closePopups(exceptId)` · **3.2:** `setSetting(pluginId, key, value)` (one of the plugin's own declared settings, live, through `ewe-plugin set`) |
| signal | `aboutToSleep()` (logind bridge) · `resumed()` (Resume step 6) |

Injected into entry points when declared: `pluginId`, `pluginDir`,
`stateDir`, `settings`, `screen` + `barWindow` (bar slots), `ink`
(bar-status — reads `item.shown`), `panelOpen` (= this tile/page on
screen).

### `ewe-plugin` verbs that are contracts

`install <id>` and `migrate [--fresh]` (0.25; JSON, `{ok:false}` + exit 1 on
error), `add` accepting a first-party URL / reserved id (→ payload copy),
`list --json` fields **`available[]`**, **`removed[]`**, `plugins[].kinds`,
`plugins[].bar` `{shown, toggle}` and `plugins[].widget` `{x, y, output,
layer, visible, pinned, pin_level, locked}` (ewe-settings, Komble and the
shell parse them), `seed --restore <id>`, `set`/`get`, **`bar <id>
[on|off]`** and **`place <id> [--pinned on|off] [--pin-level top|overlay]
[--locked on|off] [--layer desktop|top|overlay] [--x N --y N --output NAME
--visible on|off --reset]`** (all JSON, live). Environment:
`EWE_PAYLOAD_PLUGINS`, `EWE_PLUGIN_SRC_DIR`; harness `HS_PLUGINS`,
`HS_PAYLOAD`, `HS_PLUGIN_DIRS`.

### Komble's CLI

`komble --updates | --settings | --search[=q] | --addons | --plugins |
--options[=]<id>` — `--addons` is what `Shell.openStore("addons")` and
ewe-settings call; it is public (and stays, though the page is called
Plugins). `--options=<id>` (D10) opens Plugins with that plugin's Options
dialog — ewe-settings' "Dock options".

### `ewe-conf sync-status` (D12)

Adds **`conflict`** (`"remote-newer"` | `"remote-exists"` | null — what a
push would answer now) and **`remote_is_this_machine`** (true/false, null for
a stamp older than machine ids). `error` stays the transport error only. A
push that stored the file but whose meta stamp was refused answers `ok`
with `"warning": "stamp-missing"`. ewe-sync, the shell and ewe-settings read
`conflict`.

## The ewe.conf schema

See [[EWE-CONF Schema Reference]].

## Cloud layout (your Nextcloud)

```
ewe/ewe.conf                 the one file
ewe/ewe.conf.meta.json       {machine, machine_id, saved_at, schema}   machine_id = sha256("ewe-conf:"+/etc/machine-id)[:16]
ewe/machines/<name>.json     per-machine ewe version + app count
```

## Related

- [[Rules of the House]] · [[The One File]] · [[IPC Verb Reference]] ·
  [[Storage Map]]
