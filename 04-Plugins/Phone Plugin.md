---
tags:
  - ewe-map
  - plugin
title: Phone Plugin
up: "[[Plugin System]]"
---

# Phone (KDE Connect) — `ewe.phone`

`~/Projects/ewe/ewe-plugin-phone` ·
[github.com/prj786/ewe-plugin-phone](https://github.com/prj786/ewe-plugin-phone)
· v1.0.0 · API 3 · **add-on since 0.25** (was `KdeConnect.qml` + the Mobile
page; narrative in [[Phone and VPN]]).

Your phone through KDE Connect's daemon (UI all ewe): pairing, battery, its
notifications (read, dismiss, inline reply), SMS conversations with send —
on the **Mobile** page; a phone glyph in the pill while paired and
reachable, battery + an accent dot for unread.

| kind | file |
|---|---|
| `service` — starts `kdeconnectd` once if needed (Hyprland runs no XDG autostart), starts the bridge, re-probes after `Shell.resumed()` | `Service.qml` |
| `quick-page` key **`mobile`** (order 70) | `Page.qml` |
| `bar-status` (order 70) | `Status.qml` |
| the model: a directory singleton owning the bridge process | `Phone.qml` |
| the D-Bus side: dbus-python + GLib, NDJSON over stdio, **runs from `pluginDir`** | `kdeconnect-bridge.py` |

## Facts

- **Install:** Komble → Add-ons, or `ewe-plugin install ewe.phone`; then
  KDE Connect on the phone, same network.
- **State path kept:** `~/.config/quickshell/kdeconnect-state.json` (seen
  ids, chosen device). No secrets — pairing keys live in kdeconnectd.
- **Requires:** `kdeconnect`, `python-dbus`, `python-gobject` /
  commands `kdeconnectd`, `python3` (ewe deps, declared so Komble can
  offer a missing one).
- **Test knob:** `EWE_PHONE_NO_DAEMON=1` stops the add-on and the bridge
  from starting `kdeconnectd`. `./test.sh` runs the bridge's pure functions
  with stub `dbus`/`GLib` — no bus, no phone.

> **Build guard:** D-Bus **auto-activation starts `kdeconnectd` on ANY
> proxy call** — a harness needs `EWE_PHONE_NO_DAEMON=1` **and** a private
> bus (`HS_PRIVATE_BUS=1`), or a test run becomes a new device on your
> network.

Open: `autostart.sh` also started `kdeconnectd` (both guarded) — check the
duplicate is gone after the carve-out.

## Related

- [[Plugin System]] · [[Phone and VPN]] · [[Shell Singletons]] · [[Troubleshooting Knowledge]]
