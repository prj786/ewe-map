---
tags:
  - ewe-map
  - decisions
title: Game Mode — one, owned by the desktop
up: "[[Decision Index]]"
---

# Game mode — one game mode, owned by the desktop, Ultra by default

**Decided 2026-11-08** (owner: "i want super optimized gaming on ewe, even when i
have integrated graphics … now i have feeling it does really nothing"). Built for
ewe 0.42.0-beta + ewe Settings 0.23 + Shaun 0.2.4.

**Why "it did nothing" (measured on the owner's Lunar Lake laptop):** Shaun's
game mode held `gamemoded -r`, but GameMode's four root helpers (CPU governor,
GPU clocks, core parking, `split_lock_mitigate`) are allowed by polkit only to the
`gamemode` group, which no installer adds anyone to — `journalctl --user -u
gamemoded` showed "Not authorized" on every start. What ran was DND and
animations off. And once allowed, GameMode's default (`desiredgov=performance`)
would pin the CPU at full speed and starve an integrated GPU of the shared power
budget: its own iGPU logic needs RAPL energy counters, which are root-only.

- **One tool, one state:** `bin/ewe-game` (JSON, exit 0) owns game mode; the
  Quick settings tile, ewe Settings → Power → Gaming, Shaun ("game mode on"),
  `qs ipc call game …` and GameMode's own `[custom]` start/end hooks all go
  through it. State: `$XDG_RUNTIME_DIR/ewe/game.json` (a reboot ends it).
  **Reasons** (`manual`, `window`, `gamemode`): an automatic end only takes its
  own reason away, so a game closing never ends a game mode you turned on.
- **Two levels** (`[desktop.game] level`, default **ultra**):
  *balanced* = banners stay in the list (the shell, without touching DND),
  Hyprland animations/blur/shadows off, GameMode held; *ultra* adds the
  **Performance power profile** (the platform power limit — the one knob that
  feeds an integrated GPU), `render.direct_scanout = 1`, **ewe's own background
  apps closed** (`close_apps`: ewe Sync's service unless its window is open, ewe
  Browser's windowless `--background` process) and reopened after, desktop
  widgets hidden, a video wallpaper frozen. `off` puts everything back; a power
  profile changed meanwhile stays.
- **Automatic** (`auto`, default on): the shell runs `ewe-game scan` when a
  window opens (and on close while a window started it); a window whose process
  (or its parent) carries `SteamAppId` (native and Proton games; the Steam client
  does not), `steam_app_N` or `gamescope` is a game. Plus GameMode's hooks: any
  game run with `gamemoderun` (Lutris, Heroic, Steam launch option).
- **GameMode allowed:** `system/tuning/70-ewe-gamemode.rules` (via
  `apply.sh`) allows the four helpers to `wheel` — no session check, gamemoded
  is a user service outside any session.
- **No pinned CPU on an integrated GPU:** `ewe-game setup` (ewe-setup + phase
  60) writes `~/.config/gamemode.ini` (marked; a user's own file is left alone):
  the hooks, and on an integrated-only machine (Intel at 00:02.0, an amdgpu with
  ≤ 4 GiB set aside) `desiredgov` = the current governor.
- Children `ewe-game` leaves running (the GameMode hold, the reopened browser)
  start in their own `systemd-run --user --scope`: the caller may be
  gamemoded.service or ewe.service.

> **Build guard:** never pin the CPU governor to `performance` on an
> integrated-only machine. *Breaks if violated:* the GPU loses its share of
> the package power and the game gets FEWER frames in "performance" mode.

> **Build guard:** an automatic `off` removes only its own reason. *Breaks if
> violated:* closing a game (or GameMode's end hook for ewe's own hold) ends
> a game mode the user turned on by hand.

## Not taken

Killing arbitrary user processes (Steam's helpers, the user's own apps) — only
ewe's own background apps, which ewe can reopen. Dropping the page cache (it
only makes the game load from disk again). Tearing (`allow_tearing`) — needs a
per-window rule, and tearing is a look the user did not ask for. Raising the
Intel GPU's minimum clock — needs a root helper of ewe's own; the power profile
does the job on a shared-budget chip.

## Related

- [[Decision Index]] · [[Troubleshooting Knowledge]] · [[CLI Tools]] ·
  [[IPC Verb Reference]] · [[Memory Tuning — match zram]]
