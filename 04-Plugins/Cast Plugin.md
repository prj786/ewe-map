---
tags:
  - ewe-map
  - plugin
title: Cast Plugin
up: "[[Plugin System]]"
---

# Cast to TV — `ewe.cast`

`~/Projects/ewe/ewe-plugin-cast` ·
[github.com/prj786/ewe-plugin-cast](https://github.com/prj786/ewe-plugin-cast)
· v1.0.0 · API 3 · **plugin since 0.25** (was `Cast.qml` — the shell's end
of [[ewe-cast]]; the daemon, phase 30's system setup and SharePicker stay
core).

| kind | file | shows |
|---|---|---|
| `quick-page` key **`cast`** (order 30) | `Page.qml` | displays in range → pick → SharePicker → streaming; a switch hangs up |
| `quick-tile` (order 30) | `Tile.qml` | **always present when installed** (installing = wanting the button): idle opens the page, casting is lit (busy until the picture is on the TV), click hangs up |
| `bar-status` (order 30) | `Status.qml` | screencast glyph while a session exists; accent once streaming |
| `service` | `Service.qml` | starts and talks to `ewe-castd`, narrates Wi-Fi Direct from the journal, owns the legacy path |
| manifest `keybinds` | — | **`Super+Shift+C`** → `ewe.cast toggle` (active while enabled) |

## Facts

- **Install:** Komble → Plugins, or `ewe-plugin install ewe.cast`.
- **IPC:** target `ewe.cast` — `toggle · scan · start <sink-id> · stop ·
  status · legacy`; alias **`cast`** with the same verbs (the pre-0.25
  target; `qs ipc call cast legacy` still works).
- **Scripts moved with it:** `cast-check.sh` (preflight) and
  `cast-audio.sh` now live in `~/.config/ewe/plugins/ewe.cast/` — the
  preflight is `sh ~/.config/ewe/plugins/ewe.cast/cast-check.sh`
  (`ewe-diag` must point there). Log unchanged:
  `~/.local/state/ewe/cast.log`. Plugin-local `CastState` singleton.
- **Requires:** `ewe-cast`, `gnome-network-displays`, `avahi`, `iw`,
  `wireless-regdb`, `gst-plugin-va`, `gst-plugins-bad`; dev knob
  `EWE_CASTD=/path/to/ewe-castd`.
- **Portal threshold:** the patched `xdg-desktop-portal-hyprland` must be
  **≥ 1.4.1-2.1** (stock Arch `1.4.1-2` reintroduced the #424 freeze; ewe
  ships `1.4.1-2.1` — phase 90's check and the plugin's README say so).
- `./test.sh` runs the scripts against fake `systemctl`/`iw`/`pacman`/`pactl`.

> **Build guard:** keep the `cast` alias and verbs; the tile is not
> optional; the preflight path is the plugin dir, not
> `~/.config/hypr/scripts/`.

## Related

- [[Plugin System]] · [[ewe-cast]] · [[Cast Flow]] · [[Troubleshooting Knowledge]]
