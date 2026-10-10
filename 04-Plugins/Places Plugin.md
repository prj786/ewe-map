---
tags:
  - ewe-map
  - plugin
title: Places Plugin
up: "[[Plugin System]]"
---

# Places — `ewe.places`

`~/Projects/ewe/ewe-plugin-places` ·
[github.com/prj786/ewe-plugin-places](https://github.com/prj786/ewe-plugin-places)
· v1.0.2 (in ewe 0.25.1; 1.0.1 in 0.25.0) · API 3 · **plugin since 0.25** (was `Places.qml`).

A compact file browser in a popup: home, folders and files (no dotfiles),
a path field with back/home, a **Pinned** strip; click or Up/Down/Enter/
Backspace to browse, open with the default app, **drag any entry out** into
another app, drop a file/folder **onto** the panel to pin it. Esc closes.

| kind | shows |
|---|---|
| `panel` — its **own `PanelWindow`**, namespace **`quickshell:places`** | the panel, above the dock or under the bar |
| `dock-item` (order 10, action `ewe.places.toggle`) | a folder in the [[Dock Plugin]]; `Shell.setActive("ewe.places.toggle")` lights it |
| `bar-widget` (right) | a folder in the bar, per the `button` setting |

## Facts

- **Install:** Komble → Plugins, or `ewe-plugin install ewe.places`.
- **Setting:** `button` (`auto` | `bar` | `dock` | `both`) — it places the
  button, so `barWidget.toggle: false` (no Show in bar switch, D10).
- **Pinned = `apps.places` in `ewe.conf`** (synced; edited by pinning in the panel):
  the panel reads `$XDG_CONFIG_HOME/quickshell/places.json` (ewe-conf's
  mirror) via `FileView` and writes through `ewe-conf set --no-hooks
  apps.places` (tool resolved the way the shell resolves it) — Rule 1.
- **IPC:** `qs ipc call ewe.places toggle|show|hide`; alias **`places`**.
- Requires `xdg-utils` (`xdg-open`) and `findutils` (`find`).
- Why its own window and not `AnchoredPopup`: drag-out needs an input
  `mask: Region { item: box }` so the drop lands on the app behind — which
  is also why a click beside the panel does not close it.

> **Build guard:** keep `quickshell:places`, the `places` alias and the
> `places.json` path; never write `apps.places` by hand.

## Related

- [[Plugin System]] · [[Music Plugin]] · [[Dock Plugin]] · [[The One File]]
