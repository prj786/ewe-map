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
· v1.2.0 · API 3 · **plugin since 0.25** (was `KdeConnect.qml` + the Mobile
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
| `dock-item` (order 60, action `ewe.phone.toggle`) + `panel` — the phone's popup (1.2.0) | `Popup.qml` |
| the apps cache (C1 → C2) and the KDE Connect hider (1.2.0) | `phone_apps.py`, `hide_kdeconnect.py` |
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

## 1.2.0 (2026-11-26, ewe-plugin-phone#2, `8533299` — released in ewe 0.50.0-beta)

The "one ecosystem" wave ([[ewe Mobile — one ecosystem]], decisions 78–81).

- **A dock button** (`dock-item`, `ewe.phone.toggle`; hidden while no phone is
  paired) with a card: the head (name, battery, in reach; *Mirror screen* and
  *Open ewe Mobile* where ewe Mobile is installed), **Apps** (search, a grid of
  the phone's apps with real icons; a click opens through `ewe-mobile
  --open-app` — here when the adb link is up, else on the phone; right-click
  offers both; a phone that is away shows the last list, dimmed) and **Files**
  (Camera, Screenshots, Downloads, Documents, Music, Movies, internal storage:
  one click mounts the phone and opens the folder in ewe Files). Keys: type to
  search, arrows, Enter (Shift on the phone, Ctrl here), Tab flips Apps / Files.
  A phone on the stock KDE Connect app is told to install ewe Mobile for its apps.
- **The apps cache.** The bridge reads the list ewe Mobile for Android sends
  through `remotecommands` (contract C1: the `"ewe"` marker, `v` ≥ 1), validates
  it (package `[A-Za-z0-9._]{1,255}`, names cut at 200 characters, an icon is a
  square PNG of 16–512 px and ≤ 256 KB — a bad icon costs the app its icon,
  never its place) and writes the C2 cache ([[Storage Map]]). `phone_apps.py`.
- **No KDE Connect window anywhere (C6).** The setting **`hide_kdeconnect`**
  (default on) runs `hide_kdeconnect.py hide`: the entries that open a KDE
  Connect window (`org.kde.kdeconnect.app`, `.sms`, `.nonplasma`, `.handler`,
  the daemon and settings-module entries) become `NoDisplay=true` copies marked
  `X-Ewe-Phone-Hides=1` — or, where eep has a card for the entry, eep's own
  `eep remove sys-…`. Off runs `show`: everything returns as it was. A file
  without one of the two marks is never touched. `kdeconnectd` stays.
- `test.sh` 28/28.

> **Build guard (1.2.0):** the plugin's dock button, the cache and the hider are
> checked in the nested harness only (`HS_PRIVATE_BUS=1`, `EWE_PHONE_NO_DAEMON=1`,
> `ewe-plugin` verbs with `--no-restart` and the Hyprland/Wayland variables
> unset) — never on the live `~/.config`. A phone's notification gets its
> sender as title only because the shell advertises `x-kde-display-appname`
> ([[Troubleshooting Knowledge]]).

## Related

- [[Plugin System]] · [[Phone and VPN]] · [[ewe Mobile]] · [[ewe Mobile — one ecosystem]] · [[Storage Map]] · [[Shell Singletons]] · [[Troubleshooting Knowledge]]
