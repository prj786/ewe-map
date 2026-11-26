---
tags:
  - ewe-map
  - decisions
title: RFC-012 — ewe Mobile, both halves
up: "[[Home]]"
---

# RFC-012 — ewe Mobile, both halves: the phone on the desktop, and an ewe app for Android

*Status: **accepted 2026-11-26**. The owner asked that day to "make a research
how realistic it is to create new android app using kde backend once again,
but now apk. have similar layout as our ewe-mobile plus new features like
list of installed apps on the mobile, displaying directory in ewe files as
mobile integration. even more if i can make run android installed apps in
ewe, or moreover from ewe mobile display android screen with casting. plan
those", and took **all nine proposed answers** when asked. The full text,
with sources and what was measured, is `ewe/docs/RFC-012-ewe-mobile-android.md`
(ewe#96). Built and released the same day: the Remote page fix
([[ewe Mobile]] 0.1.1-beta) and step A1, the phone in ewe Files
([[ewe-apps]] 0.5.0-beta). **Not started:** the probes with the phone, the
screen and apps pages, the APK.*

*Update, **the same evening**: the rest was built and released as one wave
(ewe 0.50.0-beta, ewe.phone 1.2.0, ewe Mobile 0.2.0-beta, eep 0.4.1-beta, and
the Android app's ewe face on `ewe-connector-android`, PR #2). The §7 probes
were run with the phone; A2–A4 (the adb link, Screen in scrcpy's window, Apps —
open here or on the phone) and B1–B3 (the fork, the ewe face, the apps list
with icons through `remotecommands`) are done, with what the owner added that
day: [[ewe Mobile — one ecosystem]] (decisions 78–81). The plan and its
contracts: `ewe-mobile/docs/ECOSYSTEM.md`. Still open: B4 (not needed — the
link came back after a reboot), B5 (the release key), the screen inside the
window. The repo is `prj786/ewe-connector-android` (the owner named it), not
the `ewe-mobile-android` of answer 1.*

## What was found

- **Four of the five wishes need no Android app.** The phone's folders in ewe
  Files work with the stock KDE Connect app; its screen, its app list and its
  apps as windows go through **scrcpy over Wi-Fi debugging**. Only "our own
  layout on the phone" needs an APK.
- **Running the phone's apps on the desktop is closed to every normal
  Android app, ours included** — only the shell user or a system app may put
  other apps on a virtual display. The debugging link is the one door on a
  stock Pixel.
- **The stock daemon cannot be taught new packet types**: `kdeconnectd` drops
  what no plugin of its own declares, exposes no raw packet over D-Bus, and
  loads no plugin built outside its tree. Two doors are open anyway, with no
  desktop change: its **`remotecommands`** plugin (the phone hands over any
  JSON as a command list; the desktop sends back any string) and the
  **side-channel** pattern `sftp` and `virtualmonitor` already use.
- **The APK from nothing is the wrong size**: the link is 2–3 thousand lines,
  the features that make KDE Connect useful about thirty thousand.

## What was decided (the nine answers)

1. **The APK is a fork of the KDE Connect Android app**, GPL-3.0-only, in a
   new repo `ewe-mobile-android`. Upstream's protocol and plugin code stays
   untouched in place; ours lives beside it. The desktop app stays MIT.
2. **Developer mode on the phone (Wireless debugging) is the accepted price**
   for the screen and for apps as windows — opt-in, the cost said on the page
   before it is asked.
3. **Screen: scrcpy's own window first**; inside ewe Mobile's window only
   after that has been lived with (WebCodecs works in WebKitGTK 2.54.3, but
   crashes with `WEBKIT_DISABLE_DMABUF_RENDERER=1` — VMs and NVIDIA).
4. **`scrcpy` and `android-tools` are optional**, offered through Komble from
   the page ([[The Package Diet]]).
5. **The Android app is "ewe Mobile", id `io.github.prj786.ewemobile`** — id
   and signing key fixed before the first shared build.
6. **Installing: over `adb` from ewe Mobile is the main path** (exempt from
   Google's developer verification, which reaches sideloaded APKs during
   2027); limited distribution for the beta; registering with Google (an ID
   and $25) is decided before going public — the owner's identity, the
   owner's call.
7. **Apps travel through `remotecommands` now**; a real packet is offered
   upstream alongside.
8. **`ewe-mobile` and the Android source go public together**, with the first
   build of the fork (GPL requires the Android source once anyone gets the
   APK).
9. **The phone as the computer's touchpad on Hyprland** is its own item (see
   [[Open Questions]]).

## The order of work

0. Half an hour with the phone and `scrcpy` (the RFC's §7: seven things to
   try) — **before any more code**.
1. A1, the phone in ewe Files — **done** ([[ewe-apps]] 0.5.0-beta).
2. A2–A4 in `ewe-mobile`: the debugging link, a `screen` page, an `apps`
   page (two new public page ids).
3. B1: the fork builds, pairs with the stock daemon, installs from ewe Mobile.
4. B3: apps and icons from the phone. 5. B2: the ewe face.

## Not doing

A daemon of our own on the desktop; a clean-room Android app; a
`kdeconnectd` plugin shipped from `[ewe]`; screen capture by our own app as
the main path (consent every session, stops on every lock); Waydroid (another
Android, not the phone's apps); a Cast or Miracast receiver.

## Related

- [[ewe Mobile]] · [[ewe Mobile — one ecosystem]] · [[ewe Mobile — a window over KDE Connect]] · [[ewe-apps]] ·
  [[Phone Plugin]] · [[Decision Index]] · [[Open Questions]] ·
  [[Troubleshooting Knowledge]]
