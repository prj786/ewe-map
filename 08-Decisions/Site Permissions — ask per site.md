---
tags:
  - ewe-map
  - decisions
title: Site Permissions — ask per site
up: "[[Decision Index]]"
---

# ewe browser asks per site for camera, microphone and the rest (#42)

**Decided 2026-10-18** by the owner (wave 2, with Settings → Privacy and
security), **released in ewe browser 0.4.0-beta** (ewe-browser#13).

| was (up to 0.3.0-beta) | now (0.4.0-beta) |
|---|---|
| every permission request but a few silent ones was **denied without a word**: video calls had no camera, sites could not send notifications | camera, microphone, location, notifications, clipboard, MIDI, local network, window placement and idle detection **ask** through a prompt card at the page's top left |
| nothing remembered | Allow / Block are stored **per top-level site** in `<userData>/permissions.json` (`{version: 1, sites: [{origin, permissions, updated}]}`, 1000 origins); × (Not now) denies once; two Not now → silent denial for 10 minutes (this run only) |
| — | a **site info** panel from the address field's lock (Ask / Allow / Block per permission, Clear site data, Site settings) and a list in Settings → Privacy and security |

Still allowed silently: fullscreen, pointer and keyboard lock, sanitized
clipboard writes, `mediaKeySystem` (DRM), `screen-wake-lock`. Still denied:
USB, HID, serial, external protocols, Storage Access, file-system writes,
screen sharing (later work). Requests from views that are not tabs (popups,
panels) are denied. **Location** has no provider in Electron on Linux (it
needs a Google API key): an allowed site gets no position, and the prompt,
the site info and Settings say so.

The card guards against clickjacking: it counts Allow / Block only 500 ms
after it appeared or changed and after a pointer move over it, and main
ignores them within 500 ms of showing it. It never takes focus; requests
from the same tab and origin merge (Meet's camera + microphone are one card).

## Why

Silent denial broke ordinary sites (calls, notifications) and told the user
nothing. Asking per site is what every browser does; deciding for the
top-level site matches Chromium's permission delegation (an iframe's
`allow` attribute is checked first).

> **Build guard:** Electron reports **"denied"** for every permission not
> granted, so `navigator.permissions.query` and `Notification.permission`
> would say denied and sites would never ask. The page preload patches
> `Permissions.prototype.query` and `Notification.permission` in the main
> world to answer `prompt` / `default` for the undecided kinds of that
> origin (the `ask` list from `ewe:privacy-frame`, one sync IPC per top
> frame), and the check handler answers the same verdict as the request
> handler. *Breaks if violated:* sites never show their own "allow camera"
> step, and `query` disagrees with what a request gets.

## Related

- [[Decision Index]] · [[ewe-browser]] · [[Security Posture]] ·
  [[Troubleshooting Knowledge]]
