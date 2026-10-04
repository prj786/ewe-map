---
tags:
  - ewe-map
  - decisions
title: Add-ons — opt-in, not preinstalled
up: "[[Decision Index]]"
---

# Add-ons are opt-in — only the core is preinstalled (D1)

**Decided 2026-10-04** (ewe 0.25.0-beta, in progress). The user's words:
*"only topbar, settings, Komble and the auth app can be preinstalled."*

- **Preinstalled** = the shell core (bar, launcher, Overview, the Quick
  settings basics, notifications, lock, OSD, polkit, Welcome), ewe-settings,
  Komble and ewe-sync.
- **Everything else is an add-on** — a first-party plugin shipped inside the
  ewe payload but **not installed on a fresh machine**: the clipboard
  history, screenshots and the password picker (bundled plugins since
  0.21), and from 0.25 the features that were carved out of the shell —
  [[Insomnia Plugin]], [[System Monitor Plugin]], [[SSH Plugin]],
  [[VPN Plugin]], [[Music Plugin]], [[Places Plugin]], [[Phone Plugin]],
  [[Mail Plugin]], [[Cast Plugin]] and the [[Dock Plugin]].
- A user installs one with **one click** — Komble → Add-ons, the Welcome
  screen's Add-ons step (nothing pre-checked; *Install selected* / *Browse
  in Komble*) — or `ewe-plugin install <id>`.
- Upgraders keep what they had: see [[Add-ons — one-time migration for upgraders]].

## What stays core (do not extract)

`network.vpn` / `network.ssh` ewe-conf sections, the NM backends and the
ewe-settings Network pane · the `google` IPC verbs incl. `syncSoon`, Google
Calendar/Drive, `ewe-auth`/`ewe-mail`/`ewe-drive` and the Agenda (see
[[Gmail Split — core Google, Mail add-on]]) · Cast's system setup (phase 30)
and `ewe-castd` · SharePicker · media keys · the Screensaver's MPRIS
hold-off · the `desktop.dock.*`, `apps.pinned` and `apps.places` ewe.conf
keys (the add-ons read them through `Shell`) · the GOA/EDS bridge
(`Accounts.qml`, dormant).

## Why

A fresh ewe should be the smallest honest desktop; every extra is a choice
the user makes, visibly, from a catalogue that explains it. It also makes
the shell core smaller (fewer places for a QML error to take the desktop
down — [[Plugins Unsandboxed]]) and gives every feature its own repo and
release line ([[One repo per add-on]]).

> **Build guard:** a new shell feature that is not bar/launcher/Overview/
> Quick settings basics/notifications/lock/OSD/polkit/Welcome is an add-on
> (`prj786/ewe-plugin-<name>`, `plugins/bundle.json` `default: false`).
> *Breaks if violated:* a fresh install grows features nobody asked for,
> and the Welcome/Komble catalogue lies about what is installed.

## Related

- [[Decision Index]] · [[Plugin System]] · [[Add-ons — vendored payload and bundle.json]] ·
  [[Plugin API 3]] · [[Komble]]
