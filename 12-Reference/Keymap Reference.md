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
auto-reloads on save). Plugin keybinds (Print keys, `Super+P`) come from
`generated/plugin-keybinds.lua` — **not** from hyprland.lua.

## Launching

| keys | action |
|---|---|
| `Super+Return` | terminal (kitty) |
| `Super+D` | launcher — fuzzy app/file search |
| `Super+E` | file manager (nemo) |
| `Super+B` | browser (Settings → Default Apps) |
| `Super+C` | calendar popup |
| `Super+,` | Settings |
| `Super+N` | toggle Quick Settings |
| `Super+Shift+C` | Cast to TV (same as the QS tile) |
| `Super+P` | password fill picker (plugin) |
| `Print` / `Shift+Print` / `Super+Print` | screen / region / window shot (plugin) |
| `Super+Shift+W` | widget arrange mode (plugin host) |

## Windows

| keys | action |
|---|---|
| `Super+H/J/K/L` or arrows | focus left/down/up/right |
| `Super+Shift+H/J/K/L` or arrows | move window (merges into a group) |
| `Super+G` / `Super+Shift+G` | group / ungroup focused window (tabbed stack) |
| `Super+[` / `]` | prev / next tab in group |
| `Super+Alt+1…9` | jump to tab 1–9 |
| `Super+Ctrl+H/J/K/L` | resize focused window |
| `Super+Shift+N` | reset split ratio |
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

## Related

- [[ewe Desktop]] · [[Contracts and Public API]] · [[Plugin Manifest Reference]]
