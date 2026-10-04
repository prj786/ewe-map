---
tags:
  - ewe-map
  - plugin
title: Music Plugin
up: "[[Plugin System]]"
---

# Music — `ewe.media`

`~/Projects/ewe/ewe-plugin-media` ·
[github.com/prj786/ewe-plugin-media](https://github.com/prj786/ewe-plugin-media)
· v1.0.0 · API 3 · **add-on since 0.25** (was `MediaPlayer.qml` + the dock's
music button).

The now-playing card (artwork, source, title/artist, prev · play/pause ·
next, seek bar) for any MPRIS player via `Quickshell.Services.Mpris` — the
playing one wins, else the first controllable player with a track.

| kind | shows |
|---|---|
| `panel` — an `AnchoredPopup`, namespace **`quickshell:mediaplayer`** | the card, above the dock or under the bar |
| `dock-item` (order 20, action `ewe.media.toggle`) | a music note in the [[Dock Plugin]] |
| `bar-widget` (right) | a music note in the bar, shown only while a player exists |

## Facts

- **Install:** Komble → Add-ons, or `ewe-plugin install ewe.media`.
- **Settings:** `button` (`auto` | `bar` | `dock` | `both`, default `auto` =
  bar only while no dock is present) and `always_show` (keep the bar button
  with nothing playing). Hides its dock button via
  `Shell.setDockItemShown`.
- **IPC:** `qs ipc call ewe.media toggle|show|hide`; alias **`player
  toggle|hide`** (the pre-0.25 target). `toggle` with no player → toast
  "Nothing is playing".
- Requires the command `busctl` (sends the spec's `PlayPause`); disabled
  controls use tokens, not opacity (Rule 8). Media keys and the
  Screensaver's MPRIS hold-off stay core.

> **Build guard:** keep `quickshell:mediaplayer` and the `player` alias —
> hyprland.lua layer rules and the Glass blur list match by name.

## Related

- [[Plugin System]] · [[Places Plugin]] · [[Dock Plugin]]
