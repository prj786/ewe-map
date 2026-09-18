---
tags:
  - ewe-map
  - decisions
title: Foundation Choices
up: "[[Home]]"
---

# Foundation Choices — platform, compositor, look, apps

The bedrock decisions. Reversing any of these means a different project.

## Arch only

Package install assumes `pacman` + the AUR. The project is Arch-only **end
to end** — no Fedora/COPR/`dnf`/GDM paths remain. Arch derivatives
(EndeavourOS, CachyOS, Garuda, Manjaro) should work; Artix is detected and
service phases are skipped.

> **Build guard:** don't add multi-distro branches to the installer. The
> whole value chain ([[ewe-repo]], [[Packaging and Updates]], Komble's
> pacman reality) assumes one target.

## Hyprland + Quickshell

- **Hyprland** — Wayland compositor, configured in **Lua** (`hyprland.lua`
  requires `colors.lua`; **Hyprland ≥ 0.55 required** — that's where Lua
  config landed; older versions silently ignore it).
- **Quickshell** — the QML shell owning bar, dock, launcher, notifications,
  control centre, settings fallback, lock, OSD, greeter.
- `hl.env()` propagation to on-demand-launched apps is unreliable — toolkit
  theming env is exported in `dotfiles/hypr/start-hyprland.sh` **before**
  `exec Hyprland`, never via `hl.env()` in `hyprland.lua`.
- User overrides land in `hypr/generated/user.lua` (sourced last).

## Dark only (2026-09-01)

Two dark schemes — `flock` (neutral greys) and `blacksheep` (absolute black
for OLED). **There is no light mode, deliberately.** `colorscheme.sh` still
accepts a mode argument and ignores it, for caller compatibility.

> **Build guard:** do not "add a light mode back". It was removed by
> decision; a full scheme system exists instead (`ewe-theme`, Ewe Dark /
> Ewe Light *schemes* are token derivations — the light scheme exists as
> tokens for the website toggle, not as a desktop mode).

## Traditional GTK apps (not Qt/KDE, not libadwaita)

Shipped first-party apps are traditional GTK: **Nemo, Engrampa, imv,
Zathura, mpv** (+ kitty, Zed). Why:

1. Traditional GTK apps use a menubar + server-side decorations → under
   Hyprland (no titlebar, just the accent border) they render **borderless**.
   Only **libadwaita** forces an unhideable headerbar — which is exactly why
   GNOME-style apps are avoided.
2. All-GTK makes **one `~/.config/mimeapps.list`** (read natively by GIO)
   the single source for default apps — no KDE `ksycoca` cache.
3. Qt gets a dark Fusion palette via `qt6ct` + a `kdeglobals` fallback —
   as a *fallback for stray Qt apps*, not a target.

> **Build guard:** do not propose reverting to Qt/KDE apps or
> `plasma-integration`. Do not swap in libadwaita apps (they'd break the
> borderless aesthetic).

## The greeter stack

`greetd → cage → Quickshell greeter` — the greeter is another user and reads
no dotfiles, so fonts/branding get installed system-wide (phase 30 copies
Geist into `/usr/share/fonts/ewe/`, `60-ewe-geist.conf` into
`/etc/fonts/conf.d/`). Plymouth is the silent boot splash; no boot text ever
hits the screen.

## The naming

The user-facing name is **ewe** (session entry "Ewe", plymouth theme `ewe`,
sheep line-art logos). The deep rename from `hypr-shell` landed
**2026-08-19**: the user unit is `ewe.service`, state lives in
`~/.local/state/ewe`, every system file is `*ewe*`-named. Old-name
references remaining in phases 20/30/32/35 and deploy/startup scripts are
**MIGRATIONS** — leave them until a release or two has passed.

## Related

- [[Decision Index]] · [[Rules of the House]] · [[Design System]] ·
  [[Desktop Shell]]
