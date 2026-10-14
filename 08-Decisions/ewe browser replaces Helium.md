---
tags:
  - ewe-map
  - decisions
title: ewe browser replaces Helium
up: "[[Decision Index]]"
---

# ewe browser replaces Helium

**Decided 2026-10-14** by the lead. ewe's browser is now **ewe browser**
([[ewe-browser]]), a first-party app shipped like Komble: its own repo and
release, collected by ewe-repo's `publish`, a dependency of the `ewe`
package. Helium (`helium-browser-bin`) left `packages/aur.list` and
`ewe-repo/aur-packages.txt`. Nemo stays the folder handler and Super+E.

## What changed in the desktop

- **Seeding** (phase 60, `ewe-setup`): `ewe-browser.desktop` comes first in
  the default-browser loop and is seeded for `x-scheme-handler/http(s)` and
  `text/html`. Seed-only, as always: a machine whose default is still
  Helium keeps it until the user picks ewe browser in Settings → Default apps.
- **Super+B** still opens the default browser; its fallback is `ewe-browser`.
- **`$BROWSER`** (`start-hyprland.sh`) points at `ewe-browser.desktop`,
  then Helium's for machines that predate the switch.
- **Theming**: ewe browser reads `theme-tokens.json` itself.
  `colorscheme.sh` runs `helium-theme.sh` only while Helium is installed, so
  a machine without it no longer grows a Helium profile; `desktop.browser.layout`
  is documented as Helium-only.
- The dock's default pins name `ewe-browser.desktop` (they named Firefox,
  which ewe never shipped); `warmup.sh` warms ewe browser instead of Firefox.
- Komble: the Helium card is an AUR app now (no "Ships with ewe").

## Why

- One browser that is part of the desktop: it follows the theme tokens
  live, opens folders, PDFs and music in place, fills passwords through
  `ewe-pass`, syncs through the user's Nextcloud — what Helium needed a
  theming script and a profile rewrite to approximate.
- **Electron, not Tauri.** [[Process Split — Shell vs Apps]] assumed every big
  UI is a Tauri app; a browser cannot be. WebKitGTK has neither Chrome
  extensions nor Widevine. Electron's Chromium has both (castlabs' ECS build
  for Widevine), at the price of a ~120 MB package with its own runtime.

## Not changed

- `ewe-auth` / `ewe-cloud` still try `xdg-open` first (which reaches ewe
  browser once it is the default) and keep Helium as a named fallback;
  updating that list waits for the rewrite of both tools in progress.
- Existing machines keep Helium installed (pacman removes nothing on its
  own) and keep it as their default until the user changes it.

## Related

- [[Decision Index]] · [[ewe-browser]] · [[Foundation Choices]] ·
  [[Process Split — Shell vs Apps]]
