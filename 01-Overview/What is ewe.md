---
tags:
  - ewe-map
  - overview
title: What is ewe
up: "[[Home]]"
---

# What is ewe

**ewe** *(the sheep, [juː])* is an Arch-based operating system. The project is
split across repos: the one you actually look at is the **desktop
environment** in the `ewe` repo — everything else (ISO, pacman repo, apps,
website) exists to get that desktop onto machines and keep it there.

The DE is **Hyprland** (a Wayland compositor, Lua-configured) with a
**Quickshell** QML shell on top: bar, dock, launcher, notifications, control
centre, lock screen, OSD, a greeter, a silent Plymouth boot — plus three
bundled plugins (clipboard history, screenshots, password fill).

## The promises

- **The whole desktop, not a starting point** — greeter to lock screen,
  themed end to end, working out of the box.
- **Dark by decision** — two dark looks (`flock` neutral greys,
  `blacksheep` absolute black for OLED). There is no light mode, deliberately.
- **One theme, one icon language** — the look carries across the shell, GTK
  apps, Qt strays, icons and cursor; the accent applies live, no relogin.
  See [[Design System]].
- **The machine as one file** — `~/.config/ewe/ewe.conf` describes the
  desktop; every runtime file is generated from it. See [[The One File]].
- **Your account is your own** — the ewe account is a **Nextcloud** account
  (self-hosted or a hosted provider). No gatekeeper. See [[Account and Sync]].
- **Curated GTK app set** — Nemo, Engrampa, imv, Zathura, mpv, kitty, Zed:
  borderless under Hyprland, defaults managed in one `mimeapps.list`.
- **Plugins** — `ewe-plugin add <git-url>` drops third-party bar widgets,
  panels and services into the shell. See [[Plugin System]].
- **Cast to TV** — a control-centre card mirrors the desktop to Miracast or
  Chromecast through ewe's own headless daemon. See [[ewe-cast]].
- **Komble + ewe-settings + ewe-sync** — first-party software manager,
  settings app, and account/sync app. See [[Komble]], [[ewe-settings]],
  [[ewe-sync]].

## Who it's for

> People who choose an Arch-based desktop are the people who do not want
> Google in their login screen. — RFC-005

The design decisions lean on that audience: no Google client ships with ewe
(Google is an optional extra you power with your own OAuth client file),
account sync is WebDAV/CalDAV/IMAP against *your* server, and the whole
desktop installs in about ten minutes from the
[ISO download page](https://prj786.github.io/download/) — see [[ewe-os ISO]].

## Related

- [[Repository Map]] — where each piece lives
- [[Roadmap and Status]] — versions and RFC state
- [[System Architecture]] — how it fits together
