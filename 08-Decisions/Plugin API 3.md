---
tags:
  - ewe-map
  - decisions
title: Plugin API 3
up: "[[Decision Index]]"
---

# Plugin API 3 — a superset, so plugins can be real shell features (D4)

**Decided 2026-10-04** (ewe 0.25.0-beta). `apiVersion: 3` is a **superset
of 2**; the host loads **both 2 and 3**, and every API 2 plugin still
works. Source of truth for the as-built surface: `ewe/docs/PLUGINS.md`
(release branch), mirrored in [[Plugin Manifest Reference]] and
[[Contracts and Public API]].

## What 3 adds

- **Four kinds:** `quick-tile` (home-grid tile, `span` 1|2), `quick-page`
  (a rail entry + page under `quickPage.key`), `bar-status` (a glyph inside
  the Quick settings pill, reads `item.shown` and gets `ink`), `dock-item`
  (no QML — a static button the dock draws, running
  `Shell.runAction(action, anchor)`).
- **Injected properties** (only when the root declares them): `pluginId`,
  `pluginDir`, `stateDir` (`~/.local/state/ewe/plugins/<id>/`, created on
  demand), `settings`, `screen` + `barWindow` (bar slots), `ink`
  (bar-status), `panelOpen` (= **this** tile/page is on screen).
- **The public `Shell` singleton** — frozen for 3. Read: `apiVersion`,
  `overviewOpen`, `quickSettingsOpen`, `lowPower`, `onBattery`, `locked`,
  `dnd`, `bottomInset`, `bottomReserved`, `dockPresent`, `dockPrefs`,
  `pinnedApps`, `activeCount`, `dockItems`, `primaryScreenName`,
  `popupsClosing`. Call: `toast`, `openQuickSettings(tab)`,
  `closeQuickSettings`, `openSettings(page)`, `openStore(page)`,
  `launch(desktopId)`, `focusApp([classes])`, `registerAction`/`runAction`,
  `setActive`/`isActive`, `setDockItemShown`/`dockItemShown`,
  `setBottomInset(id, px, reserved)`, `setPinned`, `anchorFor(item,
  window)`, `toggleOverview()`, `closePopups(exceptId)` (one plugin popup
  open at a time). Signals: `aboutToSleep()` (from the logind bridge),
  `resumed()` (Resume step 6, ≈3 s after wake).
- **Public components**, promoted out of QuickSettings.qml/Bar.qml into
  files + `qmldir` (the shell uses the promoted files — no duplicates):
  `Tile`, `QsPageHead`, `QsSwitchRow`, `QsButton`, `QsIconButton`, `QsField`
  + `QsFieldInput`, `QsSegmented`, `QsEmpty`, `QsNote`, `QsMsgRow`,
  `TextBody/TextStrong/TextCaption/TextMono`, `Glyph`, `BarModule`,
  `BarSep`, `BarStatusGlyph`, `AnchoredPopup`.
- **Manifest fields:** `quickTile`, `quickPage`, `barStatus`, `dockItem`,
  `requires {packages, commands}` (reported, never installed by the shell),
  `ipcAliases` (**`ewe.` plugins only** — legacy IPC targets), `icon`
  (a Theme glyph *name*, `"icMusic"`) and `category` for the catalogue card.
- **Rules:** a keybind's target must be the plugin's own id or one of its
  `ipcAliases` (`apiVersion ≥ 3`); setting keys match
  `^[a-z][a-z0-9_]{0,31}$` (snake_case — camelCase is refused); a plugin
  may ship a `qmldir` singleton for state shared between its entry points.
- **Layout** reads `Shell.bottomInset` instead of `Theme.dockClearance` /
  `Globals.dockEnabled` — no dock gap when no dock is installed.

## Additive revisions (apiVersion stays 3; feature-detect them)

- **3.1** (0.25.0): `Shell.dockPrefs`, `Shell.pinnedApps`/`setPinned`.
- **3.2** (ewe 0.25.1-beta, 2026-10-10 — [[Plugin Settings Live With the Plugin]],
  [[Desktop Widgets — always movable, pin to a level]]):
  `Shell.setSetting(pluginId, key, value)` (a plugin writes one of its own
  declared settings from its own UI; live, persisted through `ewe-plugin
  set`); manifest `barWidget`/`barStatus` `defaultShown` + `toggle`,
  `desktopWidget.pinLevel` + `locked`, `layer: "overlay"`; setting
  `description`, and `legacy` (first-party only). A plugin using one checks
  for it (`typeof Shell.setSetting === "function"`), as Mail 1.1.0 does.

## Deviations from the plan (as built)

`Shell.anchorFor(item, window)` takes the window (attached properties such
as `QsWindow.window` cannot be read from another object — pass it);
`setBottomInset` has a third `reserved` argument and `bottomReserved`
exists; `setActive/isActive/activeCount` were added so a dock item lights
while its popup is open and an autohide dock stays out.

> **Build guard:** nothing in `Shell`, the public components or the
> manifest schema is renamed, removed or changes meaning without
> `apiVersion` moving; an ADDITION is an optional 3.x member that old
> plugins never notice and new ones feature-detect (listed above).
> `Globals`' API 2 subset stays untouched. *Breaks if violated:* every
> installed plugin (13 first-party ones ship in the payload) and every
> third-party plugin.

## Related

- [[Plugin System]] · [[Plugin Manifest Reference]] · [[Contracts and Public API]] ·
  [[Add-ons — opt-in, not preinstalled]] · [[Plugins Unsandboxed]]
