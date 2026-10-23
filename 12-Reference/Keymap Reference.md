---
tags:
  - ewe-map
  - reference
title: Keymap Reference
up: "[[Home]]"
---

# Keymap Reference

**Mod = Super.** Defined in `~/.config/hypr/hyprland.lua` (source:
`dotfiles/hypr/SHORTCUTS.md`); reload with `Super+Ctrl+R` (Hyprland also
auto-reloads on save). Plugin keybinds (Print keys, `Super+P`,
`Super+Shift+C`) come from `generated/plugin-keybinds.lua` — **not** from
hyprland.lua — and exist only while their plugin is enabled.

## Launching

| keys | action |
|---|---|
| `Super+Return` | terminal (kitty) |
| `Super+D` | launcher — fuzzy app/file search |
| `Super+E` | file manager (nemo) |
| `Super+B` | browser — the default from Settings → Default Apps, else ewe browser |
| `Super+C` | calendar: GNOME Calendar when installed, else this month as a notification (`scripts/calendar.sh`) |
| `Super+,` | Settings |
| `Super+N` | toggle Quick Settings |
| `Super` (tap, release bind) | Overview — the `ewe:overview` Hyprland global shortcut (0.25; bindable in `user.lua`) |
| `Super+Z` | minimize the focused window (`special:minimized`; its own picture tile in the dock, Dock 1.2.1) |
| `Super+Shift+Z` | bring back the window minimized last, onto this workspace |
| `Super+1…8` / `Super+Shift+1…8` | workspace N **of the display you are on** / move the window there (and follow) — every display has its own 1, 2, 3 … ([[Workspaces Per Display]]; shared mode: all displays switch together) |
| `Super+wheel` | the next / previous workspace of this display (scrolling layout: nudge the tape) — decided in Lua, no process per notch |
| `Super+Shift+C` | Cast to TV — the [[Cast Plugin]]'s manifest keybind (`ewe.cast toggle`) |
| `Super+P` | password fill picker ([[Passwords Plugin]] plugin) |
| `Super+Shift+P` | Safe's Quick Access ([[Safe Plugin]] plugin, 0.27) |
| `Super+A` | Shaun, the companion's drop: cards + agent sessions (`ewe.companion toggle`, its manifest keybind; [[RFC-007 — ewe Companion]]) |
| `Print` / `Shift+Print` / `Super+Print` | screen / region / window shot ([[Screenshot Plugin]] plugin) |
| `Super+Shift+W` | widget arrange mode (plugin host) |
| `Super+Shift+R` | display recovery: every output on, the saved profile reapplied (`display reset`; works on a black screen) |

## Windows

| keys | action |
|---|---|
| `Super+H/J/K/L` or arrows | focus left/down/up/right |
| `Super+Shift+H/J/K/L` or arrows | move window (merges into a group) |
| `Super+G` / `Super+Shift+G` | group / ungroup focused window (tabbed stack) |
| `Super+[` / `]` | prev / next tab in group |
| `Super+Alt+1…9` | jump to tab 1–9 |
| `Super+Ctrl+H/J/K/L` | resize focused window |
| `Super+Q` / `Super+F` | close / fullscreen |
| `Super+Shift+F` | maximise (keep bar/gaps) |
| `Super+V` / `Super+Shift+V` | toggle floating / pseudo-tile |
| `Super+T` | toggle split direction (dwindle) |
| `Super+Alt+[`/`]` | scrolling layout: scroll the tape one column |
| `Super+Alt+,`/`.` | swap column with neighbour |
| `Super+Alt+R` / `F` | cycle column width presets / fit columns on screen |
| `Super+Alt+P` / `C` | own column / merge-split column |
| `Super+Tab` / `Super+Shift+Tab` | cycle windows |

## Mouse (hold `Super`)

Drag to move · drag edge/resize (see SHORTCUTS.md for the full set).

## Touchpad (Hyprland gestures, `hyprland.lua`)

| fingers | action |
|---|---|
| 3, left / right | switch the workspaces of the display you are on |
| 3, up | Overview (`qs ipc call overview toggle`) |
| 3, down | a new empty workspace on the display you are on (never piles up empty ones; `workspaces.lua`) |
| 4, left / right | **only while ewe browser is focused:** its next / previous workspace (`ewe-browser workspace next\|prev`; fingers left → next); nothing elsewhere — ewe 0.30.0-beta, [[Four Fingers — ewe browser's workspaces]] |
| 2, sideways | inside ewe browser's pages: back / forward — the browser's own gesture, not Hyprland's (with natural scrolling, fingers right = back) |

## Inside ewe browser (the app's own keys, not Hyprland)

All rebindable in the browser's Settings → Keyboard shortcuts (they sync
with the browser's settings). The defaults since 0.4.0-beta:

| keys | action |
|---|---|
| `Ctrl+Shift+L` | open **Safe's** list for the focused login field (or the page's first one) — Safe only since 0.4.0-beta ([[Browser Passwords — Safe only]]); up to 0.3.0-beta it filled through `ewe-pass` |
| `Ctrl+H` | the History sidebar |
| `Ctrl+Shift+H` | the history page, `app://history` (since 0.2.0-beta) |
| `↑` `↓` `Enter` `Esc` | in a login field with Safe's suggestion list open: move, fill, close — the focus stays in the field (since 0.2.0-beta) |
| `Ctrl+F` | find in page (Files, Music, History and the sidebar keep their own search) |
| `Ctrl+G` / `F3` · `Ctrl+Shift+G` / `Shift+F3` | next / previous match (`Ctrl+G` opens the bar when it is closed) |
| `Alt+Shift+N` · `Alt+Shift+R` | new workspace · rename it |
| `Alt+Shift+←/→` (also `Ctrl+Alt+←/→`, `Ctrl+Shift+PageUp/PageDown`) | previous / next workspace |
| `Ctrl+Alt+Shift+←/→` | move the tab to the previous / next workspace (wraps) |
| `Alt+Shift+H` (also `Alt+Home`) | Home |
| `Ctrl+,` | the browser's settings (reuses an open settings tab) |
| `Ctrl+P` · `Ctrl+U` | print · page source (a `view-source:` tab) |
| `Alt+Shift+D` · `Alt+Shift+P` · `Ctrl+M` | duplicate · pin/unpin · mute/unmute the tab |
| `Alt+Shift+C` | copy the address |
| `Ctrl+Shift+A` | search open tabs (the palette in `t:` mode, as Chrome) |
| `Alt+Shift+M` | Music |
| menu key · `Shift+F10` · right-click | the page menu (links, images, media, selection, fields, the page, Inspect) |
| mouse back / forward buttons | back / forward — on pages (Chromium) and, since 0.4.0-beta, the rail, the bottom bar, the overlay and the sidebar |

**Web pages first:** on http(s) tabs, the keys a web app may use itself
(`Ctrl+F`, `Ctrl+G`, `Ctrl+U`, `Ctrl+P`, `Ctrl+M`, `Ctrl+,`, the
`Alt+Shift` ones …) go to the page; the browser acts only when the page did
not handle the key (Gmail's `Ctrl+U` underlines). Every Hyprland bind uses
`Super`, so none of these clash with ewe's.

## Related

- [[ewe Desktop]] · [[Contracts and Public API]] · [[Plugin Manifest Reference]]
