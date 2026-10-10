---
tags:
  - ewe-map
  - plugin
title: SSH Plugin
up: "[[Plugin System]]"
---

# SSH — `ewe.ssh`

`~/Projects/ewe/ewe-plugin-ssh` ·
[github.com/prj786/ewe-plugin-ssh](https://github.com/prj786/ewe-plugin-ssh)
· v1.0.0 · API 3 · **plugin since 0.25** (was the SSH tile + page in Quick
settings).

Your `~/.ssh/config` (+ `config.d/*`) hosts in Quick settings: click a host
→ a kitty already ssh'd in; **globe** → a background SOCKS5 tunnel
(`ssh -f -N -D $SOCKS_PORT`, key/agent only) plus the browse script you
saved for that host (paste-once editor; `SSH_HOST`, `SOCKS_PORT` default
1080); pencil edits it; stop mark ends the tunnel.

| kind | file |
|---|---|
| `quick-tile` (order 21) — host count, or "Tunnel on" | `Tile.qml` |
| `quick-page` key **`ssh`** (order 21) | `Page.qml` |
| `bar-status` (order 20) — a square-terminal glyph while a tunnel is up | `Status.qml` |

## Facts

- **Install:** Komble → Plugins, or `ewe-plugin install ewe.ssh`.
- **Stays core:** hosts are *added* in Settings → Network → SSH
  (`ewe-conf` `[network.ssh]` managed block); the plugin only reads them.
- **Files kept where they were:** browse scripts in
  `~/.config/quickshell/ssh-browse/<host>.sh` (not `stateDir`, so nothing a
  user saved is lost; not synced, not in `ewe.conf`).
- No settings, no IPC target of its own: `qs ipc call quicksettings tab
  ssh` / `Shell.openQuickSettings("ssh")`. Requires `ssh`; kitty hard-coded.
- One `qmldir` singleton `Ssh` behind the three entry points.

> **Build guard:** hiding a tile = hide the **host slot**
> (`parent.visible`), never `Tile.visible` — the home grid collapses empty
> slots itself.

## Related

- [[Plugin System]] · [[VPN Plugin]] · [[Phone and VPN]]
