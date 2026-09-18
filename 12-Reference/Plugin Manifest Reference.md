---
tags:
  - ewe-map
  - reference
title: Plugin Manifest Reference
up: "[[Home]]"
---

# Plugin manifest reference (schema v1)

A plugin is a git repository with `manifest.json` at its root. Source of
truth: `ewe/docs/PLUGINS.md`.

```json
{
  "schemaVersion": 1,
  "id": "acme.weather",
  "name": "Weather",
  "version": "0.1.0",
  "apiVersion": 1,
  "description": "Current conditions in the bar, forecast in a panel.",
  "homepage": "https://github.com/acme/ewe-weather",
  "author": "acme",
  "kinds": ["bar-widget", "panel"],
  "entryPoints": { "bar-widget": "Widget.qml", "panel": "Panel.qml" },
  "barWidget": { "defaultSection": "right" }
}
```

## Fields

| field | rule |
|---|---|
| `schemaVersion` | `1` |
| `id` | `<namespace>.<name>`, lowercase `[a-z0-9_-]`, at least one dot. `ewe.` reserved (payload or `--first-party` only). Install dir is named after it. |
| `name`, `version` | non-empty strings; `version` is what `list` shows |
| `apiVersion` | shell plugin API the plugin targets (`1`); mismatch refused **at install**, not login |
| `kinds` | one or more of `service`, `panel`, `overlay`, `menu`, `bar-widget`, `desktop-widget` |
| `desktopWidget` | optional: `{ "x", "y", "layer": "desktop" }` default place; user placement in ewe.conf wins |
| `settings` | optional typed schema: `[{ "key", "type", "default", "label", "choices"?, "min"?, "max"? }]`, `type` ∈ `bool, int, string, choice, color`; reaches entry points as `settings`; renders as a form in Komble |
| `entryPoints` | one `.qml` per kind, relative, inside the plugin; **symlinks resolving outside it are rejected** |
| `barWidget.defaultSection` | `left` / `center` / `right` (default `right`) |
| `keybinds` | optional: `[{ "combo": "SUPER + P", "ipc": "acme.weather toggle" }]` → generated into `plugin-keybinds.lua`; `combo` is Hyprland modifier syntax; `ipc` is `<target> <verb>` of `qs ipc call` — **the plugin's own target, nothing else** |
| `description`, `homepage`, `author` | optional, shown by `info` |

## Kinds

| kind | the shell does |
|---|---|
| `service` | headless `QtObject`/`Scope` — timers, processes, D-Bus, an `IpcHandler` |
| `panel` / `overlay` / `menu` | like `service`; plugin owns its `PanelWindow`s + `IpcHandler`s; names describe intent so a future UI can group them |
| `bar-widget` | an `Item` packed into the bar's section, once **per monitor** |
| `desktop-widget` | a sized `Item` (`implicitWidth/Height`) on desktop or sticky layer; moved in arrange mode |

## Public QML (`import qs`) — frozen behind `apiVersion`

- **`Theme`** — Ewe v3 tokens under their QML names (see
  `design/system/guidelines/40-implementation.md`): colour roles
  (`surface*`, `text*`, `border*`, `accent*`, `onAccent`, `focusRing`,
  `success`/`warning`/`danger`/`info` + `*Subtle`, `glass*`, `scrim`), bar
  roles (`barGround`, `barOutline`, `barHoverFill`, `barPressedFill`,
  `barAccentText`, `barTextMuted`, `barModule`, `barIcon`, `barHeight`),
  spacing, radii, widths, sizes (`control*`, `icon*`, `panel*`), type
  (`fontSans/Mono/Icons`, `fontSize*`, `Theme.type.<style>`), motion
  (`durFast/Base/Slow`, `ease*`).
- **`Globals`** — the public subset.
- **`Log`**.

Inside a `Scope` use **`Variants`, never `Repeater`** (Repeater needs an
Item parent — silently creates nothing).

## The bar-widget contract

Root `Item` with implicit size, `Theme.barModule` tall, `Theme.radiusPrimary`
corners, no fill until hover (`Theme.barHoverFill`, pressed → `barPressedFill`),
glyphs `Theme.barIcon` in `Theme.textSecondary` (primary on hover),
`Theme.spaceXs` between modules; text widgets add `Theme.spaceS` side
padding. Read the `bar*` roles (they already follow Glass) instead of plain
surface roles. Widgets append to their section in id order after built-ins;
the centre section yields on a too-narrow output; Settings' Top-bar
show/hide covers plugins under key `plugin:<id>` (absent = shown).

## Related

- [[Plugin System]] · [[Plugins Unsandboxed]] · [[IPC Verb Reference]] ·
  [[Example Plugin]]
