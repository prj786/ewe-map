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
· v1.1.0 · API 3 · **plugin since 0.25** (was `KdeConnect.qml` + the Mobile
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

- **Install:** Komble → Plugins, or `ewe-plugin install ewe.phone`; then
  KDE Connect on the phone, same network.
- **State path kept:** `~/.config/quickshell/kdeconnect-state.json` (seen
  ids, chosen device). No secrets — pairing keys live in kdeconnectd.
- **Requires:** `kdeconnect`, `python-dbus`, `python-gobject` /
  commands `kdeconnectd`, `python3` — declared so Komble can offer a
  missing one. **Since ewe 0.44 `kdeconnect` (and `qt5-wayland`) are no
  longer in `ewe`'s depends**: Komble installs them when the plugin is
  installed ([[The Package Diet]]).
- **Test knob:** `EWE_PHONE_NO_DAEMON=1` stops the plugin and the bridge
  from starting `kdeconnectd`. `./test.sh` runs the bridge's pure functions
  with stub `dbus`/`GLib` — no bus, no phone.

> **Build guard:** D-Bus **auto-activation starts `kdeconnectd` on ANY
> proxy call** — a harness needs `EWE_PHONE_NO_DAEMON=1` **and** a private
> bus (`HS_PRIVATE_BUS=1`), or a test run becomes a new device on your
> network.

Open: `autostart.sh` also started `kdeconnectd` (both guarded) — check the
duplicate is gone after the carve-out.

## 1.1.0 (2026-11-23, ewe-plugin-phone#1 — released in ewe 0.49.2-beta)

Found while building [[ewe Mobile]] against a real phone:

- **Messages never worked against a real phone.** The bridge asked
  `…/devices/<id>/conversations` for the conversations interface — there is
  no such object (`No such object path`, the page stayed on its spinner) —
  and read a message as a dict; the daemon sends a **struct** in a variant.
  Fixed: the interface is on the device object, `norm_message` takes the
  struct (and still the dict), `requestConversations` sends what the daemon
  has cached first (asked a second time it only says "loaded"), and
  `sendToAddress` sends the recipient as the struct `(s)`. Run against the
  owner's phone, read-only: 0 messages and one error before, 53 well-formed
  messages after. `test.sh` holds the real shape (12 checks).
- **The page opens ewe Mobile.** A head button (only where the app's desktop
  entry exists — asked each time the page opens) runs
  `ewe-mobile --page messages|phone` and brings its window forward. The page
  stays the short version; the window has contacts, the player, files, the
  remote.

Vendored into `ewe` 0.49.2-beta (ewe#95, commit `b494f33` in `bundle.json`).
`sshfs` is in `ewe`'s `common.list` from the same release — KDE Connect
mounts the phone's storage with it.

## Related

- [[Plugin System]] · [[Phone and VPN]] · [[ewe Mobile]] · [[Shell Singletons]] · [[Troubleshooting Knowledge]]
