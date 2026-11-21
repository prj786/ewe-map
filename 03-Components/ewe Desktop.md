---
tags:
  - ewe-map
  - component
title: ewe Desktop
up: "[[Home]]"
---

# ewe — the Desktop Environment

`~/Projects/ewe/ewe` · [github.com/prj786/ewe](https://github.com/prj786/ewe) ·
**0.30.0-beta** released 2026-10-18 ([[Version Ledger]]) · GPL-2.0-only

The repo you actually look at: **Hyprland** (Wayland compositor,
Lua-configured) with a **Quickshell** QML shell — bar, launcher, Overview,
notifications, Quick settings, lock, OSD, greeter, silent Plymouth boot —
plus **14 plugins** vendored in `plugins/` (none installed on a fresh
machine — [[Add-ons — opt-in, not preinstalled]]), the CLI tools, and the
`ewe` package that installs the lot.

**Since 0.25 the dock (+ pinned-apps popup), Places, the music player,
Insomnia (keep awake), the CPU/memory meters, SSH, VPN, the phone (KDE
Connect), mail (+ the Gmail half of Google.qml) and Cast are NOT shell
components — they are plugins** (`ewe.dock ewe.places ewe.media
ewe.insomnia ewe.sysmon ewe.ssh ewe.vpn ewe.phone ewe.mail ewe.cast`,
repos `prj786/ewe-plugin-<name>`), carved out 2026-10-04 on top of plugin
API 3. Their prefs (`desktop.dock.*`, `apps.pinned`, `apps.places`,
`network.*`, the mail account) stay in `ewe.conf`; the shell exposes what
they need through the `Shell` singleton.

## What's inside the repo

```mermaid
flowchart TB
    EWE["ewe repo"] --> BIN["bin/ — CLI tools<br/>ewe-conf · ewe-plugin · ewe-auth ·<br/>ewe-drive · ewe-setup · ewe-share-picker"]
    EWE --> DOT["dotfiles/ — Hyprland config<br/>(+ SHORTCUTS.md keymap)"]
    EWE --> SYS["system/ — greeter · plymouth · pam ·<br/>dconf · nemo-actions · udev · …"]
    EWE --> PH["phases/ — install scripts<br/>00-preflight … 90-postcheck"]
    EWE --> PACK["packages/ — package lists<br/>common · dev · gaming · aur + patched"]
    EWE --> PACKAGING["packaging/ — PKGBUILD etc."]
    EWE --> DESIGN["design/ — the design system<br/>tokens.css · components · guidelines"]
    EWE --> DOCS["docs/ — RFCs · MANUAL · PLUGINS · …"]
    EWE --> TESTS["tests/"]
```

## The user-facing surface

- **Shell core** — bar, launcher, Overview, Quick settings basics,
  notifications, lock, OSD, polkit, Welcome, greeter. See [[Desktop Shell]].
- **Shell singletons** — Globals, Theme, **Shell** (the plugin-facing API),
  AudioState, HyprMon, BtAgent. See [[Shell Singletons]].
- **Plugins** (in the payload, installed on request — Komble → Plugins,
  Welcome, `ewe-plugin install <id>`) — [[Clipboard Plugin]],
  [[Screenshot Plugin]], [[Passwords Plugin]], [[Insomnia Plugin]],
  [[System Monitor Plugin]], [[SSH Plugin]], [[VPN Plugin]], [[Music Plugin]],
  [[Places Plugin]], [[Phone Plugin]], [[Mail Plugin]], [[Cast Plugin]],
  [[Dock Plugin]]. Model: [[Plugin System]].
- **CLI tools** — every GUI is a front end to one of these. See [[CLI Tools]].
- **Design system** — `design/` (v3): tokens derived from the active scheme
  + accent; the website vendors `tokens.css` from here. See [[Design System]]
  and [[Theming Pipeline]].
- **Extras** — optional [[Google Extras]], [[Phone and VPN]], [[ewe-cast]].

## Languages (0.46.0-beta, released 2026-11-21)

Branch `feat/media-languages` (merged with `feat/languages`); decisions
65–67, 70. **Typing in other languages** — `bin/ewe-ime` + `ImeState.qml`:
fcitx5 on demand, one bar indicator (拼 あ 한), a token-themed candidate
window, `Ctrl+Space` for the engine and `Super+Space` for the layout
([[Typing in Other Languages — fcitx5 on demand]]). **Spelling** —
`hunspell` + `hunspell-en_us` ship; `[desktop.language]` in ewe.conf.
**The clock** follows the region's formats (`Globals.formatTime`, the week
starts where LC_TIME says). **The launcher** shows CRLF `.desktop` apps
(`scripts/desktop-entries.py`) and matches translated entries' English
names. **Right-to-left** titles in the Overview and launcher; Arabic,
Hebrew and Armenian Noto faces after Georgian in every Geist stack. Also in
`common.list`: `webp-pixbuf-loader`, `libdvdcss`.

## Install paths

- **Whole OS** — the ISO (recommended). See [[ewe-os ISO]], [[Install Flow]].
- **Just the DE on Arch** — `sudo pacman -S ewe` from [[ewe-repo]], then
  `ewe-setup` (per-user) and `bash /usr/share/ewe/install.sh --no-packages`
  (system side, **as your user — never sudo**; it exits 2 under sudo).
- **Hacking** — clone, `bash install.sh` (symlink farm, prompts before each
  change), `./update.sh` (pull + converge + restart the shell). Both are
  idempotent and back up every config they touch; `uninstall.sh` restores.

## Keymap (top of `dotfiles/hypr/SHORTCUTS.md`)

`Super+Return` terminal · `Super+D` apps · `Super` (tap, the `ewe:overview`
global shortcut) Overview · `Super+,` Settings · `Super+P` fill a login and
`Super+Shift+C` cast exist only while their plugins are enabled.
Touchpad: three fingers are the desktop's (workspaces, Overview, a new
desktop); since 0.30.0-beta **four fingers left/right switch ewe browser's
own workspaces while it is focused** ([[Four Fingers — ewe browser's workspaces]]).
Full list: [[Keymap Reference]].

> **Build guard:** Hyprland's Lua `hl.gesture` does not validate
> `direction` (any string loads without a `configerrors` line); use only
> the documented words and try a new gesture on a real touchpad. The
> 4-finger action calls `ewe-browser workspace next|prev` only when the
> active window's class is `ewe-browser`. *Breaks if violated:* a gesture
> silently does nothing, or four fingers act on other windows.

> **Build guard (0.46):** fcitx5 never becomes a dependency and its
> variables are exported only while it is installed; the tray delegate for
> fcitx5's item loads no icon (an icon name the theme lacks crashed
> Quickshell 0.3.2); a text field's placeholder checks `preeditText` too;
> CRLF `.desktop` files go through `desktop-entries.py` (Quickshell drops
> them); never hard-code `"hh:mm AP"` — `Globals.formatTime`. *Breaks if
> violated:* dead typing on a synced machine without fcitx5, a shell crash
> in the tray, LinOffice apps missing from the launcher, a 12-hour clock in
> a 24-hour region.

## Related

- [[System Architecture]] · [[Desktop Shell]] · [[CLI Tools]] ·
  [[Repo Layout]] · [[Roadmap and Status]]
