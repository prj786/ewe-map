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

## Dark by default, light mode too (2026-09-01, revised 2026-10-14)

**2026-10-14, the owner: "we need light mode too."** ewe is dark by
default (Ewe Dark), and light mode is supported: the built-in **Ewe Light**
scheme, any imported light scheme, or *From wallpaper (light)*, all in
Settings → Appearance → Scheme. The light path is the scheme's `variant`
(`ewe-theme` writes it into `theme-tokens.json`), and every consumer
follows it: the shell (tokens), the Tauri apps (`lib/theme.js` flips
`color-scheme`), GTK (adw-gtk3 + prefer-light), Qt and KDE (palettes from
tokens), the icons (Reversal light), kitty, Zathura, Zed (appearance and
syntax from the scheme), asyar, mpv, ewe browser (it reads the tokens) and
Helium while installed (`helium-theme.sh light`).
The lock screen stays Ewe Dark over the wallpaper by design.

*History:* on 2026-09-01 light mode was deleted and ewe declared
dark-only (two dark looks, `flock` greys and `blacksheep` black for OLED,
which remain). The v3 scheme system then brought Ewe Light back as a
pickable scheme, and the owner made it official on 2026-10-14.
`colorscheme.sh` still accepts its old mode argument and ignores it; light
or dark comes from the scheme.

> **Build guard:** every surface must work in **both** variants. No raw
> colour anywhere a scheme should reach (Rule 8 in QML; in generated app
> configs, take the colour from the tokens, as `colorscheme.sh` does).
> Check light with `HS_SCHEME=ewe-light` in the nested harness and with
> `tests/ewe-theme-test.sh` (it applies Ewe Light and checks Zed, Zathura,
> Helium and GTK).

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
