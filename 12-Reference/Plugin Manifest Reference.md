---
tags:
  - ewe-map
  - reference
title: Plugin Manifest Reference
up: "[[Home]]"
---

# Plugin manifest reference (schema v1, API 2 | 3)

A plugin is a git repository with `manifest.json` at its root. Source of
truth: `ewe/docs/PLUGINS.md` (branch `release/0.25.0-beta`). Decision:
[[Plugin API 3]].

```json
{
  "schemaVersion": 1,
  "id": "acme.weather",
  "name": "Weather",
  "version": "0.1.0",
  "apiVersion": 3,
  "description": "Conditions as a tile, the forecast on its page.",
  "homepage": "https://github.com/acme/ewe-weather",
  "author": "acme",
  "icon": "icSun",
  "category": "Utilities",
  "kinds": ["quick-tile", "quick-page", "bar-status", "service"],
  "entryPoints": { "quick-tile": "Tile.qml", "quick-page": "Page.qml",
                   "bar-status": "Status.qml", "service": "Service.qml" },
  "quickTile": { "span": 1, "order": 10 },
  "quickPage": { "key": "weather", "label": "Weather", "icon": "icSun", "order": 10 },
  "barStatus": { "order": 10 },
  "requires": { "packages": ["curl"], "commands": ["curl"] },
  "settings": [{ "key": "city", "type": "string", "default": "", "label": "City" }]
}
```

## Fields

| field | rule |
|---|---|
| `schemaVersion` | `1` |
| `id` | `<namespace>.<name>`, lowercase `[a-z0-9_-]`, at least one dot. `ewe.` reserved (payload or `--first-party` only). Install dir is named after it. |
| `name`, `version` | non-empty strings; `version` is what `list` shows and what a bundled refresh compares |
| `apiVersion` | **`2` or `3`** — the shell loads both; any other value is refused **at install**, not login (`1` = the Fluent-era surface, refused). The `quick-tile`, `quick-page`, `bar-status`, `dock-item` kinds, `ipcAliases` and the keybind target rule need `3` |
| `kinds` | one or more of `service`, `panel`, `overlay`, `menu`, `bar-widget`, `desktop-widget`, `quick-tile`, `quick-page`, `bar-status`, `dock-item` |
| `entryPoints` | one `.qml` per kind (none for `dock-item`), relative, inside the plugin; **symlinks resolving outside it are rejected** |
| `quickTile` | optional: `{ "span": 1 \| 2, "order": int }` — half a row or the whole row of the home grid |
| `quickPage` | required with `quick-page`: `{ "key", "label", "icon", "order" }`. `key` lowercase `[a-z0-9_-]`, unique, not one the shell keeps (**`home wifi bt audio cal notifs`**); it is what `quicksettings tab <key>` and `Shell.openQuickSettings(key)` route to. The extracted first-party plugins keep their legacy keys `ssh vpn mobile mail cast`; an unknown key falls back to `home` (Rule 4) |
| `barStatus` | optional: `{ "order": int }` |
| `dockItem` | required with `dock-item`: `{ "icon", "label", "action", "order" }` — static; the dock runs `action` via `Shell.registerAction`, or `qs ipc call <id> toggle` when none is registered; hide at runtime with `Shell.setDockItemShown(id, false)` |
| `requires` | optional: `{ "packages": [...], "commands": [...] }` — reported by `list --json` (`missing`) and `install`; **never installed by the shell** ([[Add-on deps declared, not split]]) |
| `ipcAliases` | optional, **`ewe.` plugins only**: legacy IPC targets this plugin's QML registers (`["player"]`) so old keybinds and scripts keep working |
| `icon`, `category` | the catalogue card (Komble → Plugins, Welcome). Icons are Theme glyph **names** (`"icMusic"`), resolved by the host as `Theme[icon]`; Komble maps them through its `THEME_ICONS` snapshot (unknown → puzzle) |
| `desktopWidget` | optional: `{ "x", "y", "layer": "desktop" \| "top" \| "overlay", "pinLevel": "top" \| "overlay", "locked": bool }` defaults; user placement in ewe.conf wins. `layer` desktop = under the windows, top = above them, overlay = above everything (fullscreen too); `pinLevel` is where the pin puts it (3.2) |
| `barWidget.defaultSection` | `left` / `center` / `right` (default `right`) |
| `barWidget` / `barStatus` `defaultShown`, `toggle` | optional bools (3.2): `defaultShown` (default true) = Show in bar before the user picks; `toggle: false` = the plugin's own settings place its button, so the host shows no Show in bar switch and `ewe-plugin bar` refuses (Music, Places) |
| `settings` | optional typed schema `[{ "key", "type", "default", "label", "description"?, "choices"?, "min"?, "max"?, "legacy"? }]`, `type` ∈ `bool, int, string, choice, color`. **Keys match `^[a-z][a-z0-9_]{0,31}$`** (snake_case; camelCase refused). Reaches entry points as `settings`; rows in Komble's Options dialog (`description` under the label; a choice of ≤3 is a segmented control). `legacy` (3.2, **`ewe.` only**): a dotted ewe.conf key whose value stands until the user sets this one — how a setting moves out of ewe-settings without resetting anyone ([[Plugin Settings Live With the Plugin]]) |
| `keybinds` | optional: `[{ "combo": "SUPER + SHIFT + C", "ipc": "ewe.cast toggle" }]` → `generated/plugin-keybinds.lua` while enabled; with `apiVersion` 3 the target **must be the plugin's own id or one of its `ipcAliases`** |
| `order` (in the four slot objects) | plugins sort by it, then by id; the shell's own come first |
| `description`, `homepage`, `author` | optional, shown by `info` |

## Kinds and injected properties

See [[Plugin System]] → *The kinds*. Injected only when the root declares
the property: `pluginId` (string), `pluginDir` (url), `stateDir` (path,
`~/.local/state/ewe/plugins/<id>`), `settings` (var, live), `screen` +
`barWindow` (bar-widget, bar-status — hand `barWindow` to
`Shell.anchorFor()`), `ink` (bar-status: the pill's glyph colour),
`panelOpen` (quick-tile, quick-page: **this** slot is on screen).

## Public QML (`import qs`) — frozen behind `apiVersion`

- **`Shell`** (API 3) — the table in [[Plugin API 3]] / [[Contracts and Public API]].
- **Public components** — `Tile`, `QsPageHead`, `QsSwitchRow`, `QsButton`,
  `QsIconButton`, `QsField` + `QsFieldInput`, `QsSegmented`, `QsEmpty`,
  `QsNote`, `QsMsgRow`, `TextBody/TextStrong/TextCaption/TextMono`, `Glyph`,
  `BarModule`, `BarSep`, `BarStatusGlyph`, `AnchoredPopup` (per-screen
  popup card: `openAt/toggleAt(anchor)`, `close()`, `name` = layer
  namespace suffix, `action` reports open state; above the dock for a
  bottom anchor, under the bar for a top one), plus `Toggle`, `Slider`,
  `Meter`, `ListWell`, `ListRow`, `SectionTitle`, `Badge`, `Spinner`,
  `Avatar`, `Elevation`.
- **`Theme`** — Ewe v3 tokens under their QML names (colour roles, bar
  roles, spacing, radii, sizes, type `Theme.type.<style>`, motion
  `durFast/Base/Slow` + `ease*`, a11y modes, `ic*` glyphs). Rule 8 applies
  to plugins too.
- **`Globals`** — the API 2 subset, unchanged: `version`, `accentColor`,
  `dnd`, `onBattery`, `lowPower`, `locked`, `barShows(key)`;
  `openSettings()`, `openStore()`, `launchEntry(entry)`,
  `focusWindowByClass(cls)`, `playSound(name)`. New code prefers `Shell`.
- **`Log`** — `Log.info("acme.weather", …)`; `HS_LOG_MODULES=acme.weather`
  shows debug lines.

Everything else (`Globals`' `*Open` flags, the notification server, the
updater, `_private` plumbing) is internal and may move without notice.

Inside a `Scope` use **`Variants`, never `Repeater`**; a `Loader` must never
bind `visible` to `item.visible` (effective-visibility cycle); attached
properties (`QsWindow.window`) cannot be read from another object — pass
the window.

## The bar-widget contract

Root `Item` with implicit size (simplest: root on `BarModule`),
`Theme.barModule` tall, `Theme.radiusPrimary` corners, no fill until hover
(`Theme.barHoverFill`, pressed/open → `barPressedFill`), glyphs
`Theme.barIcon` in `Theme.textSecondary` (primary on hover), `Theme.spaceXs`
between modules. Read the `bar*` roles (they follow Glass). Widgets append
to their section in id order after built-ins; the centre section yields on
a too-narrow output; Show in bar hides a plugin's bar widget **and** its pill glyph under
`desktop.bar.show."plugin:<id>"` — written by `ewe-plugin bar <id> on|off`
(Komble → Options → In the bar); absent = the manifest's `defaultShown`
(`list --json` → `bar: {shown, toggle}`; the host asks
`PluginHost.barShown(id)`). ewe-settings no longer has per-plugin rows.

## Related

- [[Plugin System]] · [[Plugin API 3]] · [[Plugins Unsandboxed]] ·
  [[IPC Verb Reference]] · [[Example Plugin]]
