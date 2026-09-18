---
tags:
  - ewe-map
  - how-we-work
title: Troubleshooting Knowledge
up: "[[Home]]"
---

# Troubleshooting Knowledge — known failure classes

Distilled from `ewe/docs/TROUBLESHOOTING.md` and the project's history.
**Before debugging anything new, scan this list** — most hard bugs here are
repeats.

## Cast to TV (the 2026-08-21 investigation — in the order it bit)

1. **Frozen picture / TV drops ~10 s after connect.** `xdg-desktop-portal-hyprland`
   1.4.1 screencopy retry bug (`Out of buffers` → `Retrying screencopy` →
   `tried scheduling on already scheduled cb` → never asks again). ewe ships
   **patched 1.4.1-1.1** from `packages/patched/`. Check:
   `pacman -Q xdg-desktop-portal-hyprland` +
   `journalctl --user -u xdg-desktop-portal-hyprland | grep -c "Out of buffers"`.
   Measured: stock delivered 7 frames then froze; patched ran indefinitely.
2. **Lag/stutter.** Software x264 → install `gst-plugin-va` (`vah264enc`);
   or Wi-Fi Direct sharing a crowded 2.4 GHz channel; or no regulatory
   domain (`iw reg get` → `country 00` makes 5 GHz receive-only) — phase 30
   installs `wireless-regdb` + GeoIP country.
3. **TV drops after ~3.5 min (working stream).** Wi-Fi power saving on the
   group owner — dispatcher `50-ewe-cast-powersave` turns power_save off
   while any `p2p-*` is up. Live check: `iw dev wlan0 get power_save`.
4. **No sound on TV.** The null sink was made but audio wasn't moved —
   `hypr/scripts/cast-audio.sh` makes it default while casting. Check
   `pactl get-default-sink`.
5. **"Connection failed" with nothing else.** Read the journal: the shell
   narrates NM + wpa_supplicant into toasts; raw:
   `journalctl -f -u NetworkManager -u wpa_supplicant`; app trace:
   `~/.local/state/ewe/cast.log`. `supplicant-timeout` with no GO-negotiation
   = the TV wasn't listening (open Source → Screen Mirroring first).

**`~/.config/hypr/scripts/cast-check.sh` checks all of the above and prints
the fix for each.**

## Sign-in / keyring

- **No keyring prompt, "keyring not showing up"** — the account credential
  (Nextcloud app password / Google refresh token) lives in the Secret
  Service keyring; a missing gnome-keyring or an unlocked-at-boot problem is
  the usual cause. Boot-race safe probes retry with backoff (the keyring
  may come up after the shell). Keyring playbook: `ewe-auth keyring-reset`.

## Settings

- **"Top bar settings do nothing" (0.12.7)** — prefs the Settings app
  writes MUST be in ewe-conf's `THEME_MAP`, or `absorb` drops them on the
  next write. When adding a setting: add it to `THEME_MAP` in the same
  change.
- **A change vanished** — you edited a `generated/` file; it's a build
  artifact. Change the source (`ewe.conf`), then `apply`.

## Shell / QML

- **`qs` dies on `up`** — read `driver.sh log`; QML errors name file:line.
  Ignore benign "already registered" D-Bus / PolkitAgent /
  "hyprland-guiutils not installed" warnings (nesting artifacts).
- **Surface didn't open** — a ~15 KB driver shot = bar only; a real window
  is ~40–57 KB.
- **`onAccent:` parses as a signal handler** beside a property called
  `accent` — declare the token bare and fill it with a `Binding`.
- **Plugin widget renders nothing** — inside a `Scope` use `Variants`,
  never `Repeater` (needs an Item parent, silently creates nothing).
- **`qs ipc call <t> show` no-ops** — collides with the `qs ipc show`
  subcommand; bind `toggle`.

## Installer

- **A single missing package must never abort the run** — installers
  warn-and-skip and return 0 (this was the root cause of a past "no
  greeter" failure). Don't regress `lib/pkg.sh`.
- **Everything through `run()`/`sudo_run()`** — direct `cp`/`ln`/`pacman`/
  `systemctl` in a phase breaks `--dry-run` honesty.
- **Hyprland config silently ignored** — Hyprland < 0.55 ignores Lua
  config (`VERSIONS` documents the floor).
- **Screen sharing / file pickers / app handoff silently fail** — the
  `hyprland-session.target` user unit (`BindsTo=graphical-session.target`)
  is missing or not enabled; it's what activates `xdg-desktop-portal` on a
  non-uwsm session. It is "the single most important step" of the install
  (MANUAL.md).

## VPN

- **Every L2TP profile fails with "The VPN service failed to start"** —
  strongSwan 6.1 (as Arch ships it) no longer speaks IKEv1, and L2TP/IPsec
  *is* IKEv1. The installer ships libreswan with `ikev1-policy=accept`;
  re-run `install.sh` (or `--check-only` to look) to swap the backend.
  See [[Phone and VPN]].

## Theming

- **A colour ignores the accent** — a raw literal in QML; only tokens
  allowed (rule 8).
- **A `control*` got double-grown** — never wrap a `control*` in
  `Theme.grow()`; it has grown already.
- **GTK stays light while the shell is dark** — `colorscheme.sh` is
  `set -u` (not `-e`) on purpose; a stray non-zero line must not abort
  before all files are written. Check the log it prints.

## Related

- [[Testing and QA]] · [[Development Loops]] · [[Rules of the House]] ·
  [[Roadmap — ewe-cast]]
