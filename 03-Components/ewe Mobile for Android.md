---
tags:
  - ewe-map
  - component
title: ewe Mobile for Android
up: "[[Home]]"
---

# ewe Mobile for Android — the phone half

`~/Projects/ewe/ewe-connector-android` · `github.com/prj786/ewe-connector-android`
(**private**) · a fork of KDE Connect for Android (`kdeconnect-android`,
tag `v1.37.3`), Kotlin · **GPL-3.0-only** · app **"ewe Mobile"**, id
`io.github.prj786.ewemobile` (debug builds `….debug`) · Track B of
[[RFC-012 — ewe Mobile, both halves]] · **not released** — B1 built
2026-11-26 (PR #1, not merged).

The repo was to be `ewe-mobile-android`; the owner named it
`ewe-connector-android` on 2026-11-26. The app's name and id did not change.

## What it is

On the wire it *is* KDE Connect: the stock `kdeconnectd` pairs with it as
with the stock app, and [[ewe Mobile]] on the desktop needs no change. New
features reach the computer through two doors the stock daemon already has —
its `remotecommands` plugin and a side channel — because `kdeconnectd` takes
no new packet types and no outside plugins.

So far only the name, the launcher icon (the ewe mark) and a test plugin
(the B3 spike) are ours.

## How the fork is kept

Upstream's code stays where it is, with its package names and licence
headers; the namespace stays `org.kde.kdeconnect_tp`. Ours lives beside it:
`src/ewe/java` (package `io.github.prj786.ewemobile`) and `src/ewe/res`
(every name `ewe_…`), both added to the main source set; `art/`, `scripts/`,
`docs/`, `.github/`. The patch on upstream's files is 13 lines in 5 files —
the id, our source folders, five manifest labels and icons, a debug shortcut,
and two ids spelled out by hand in upstream's Kotlin (the FileProvider
authority, "our own notifications"), both worth offering upstream. The list
and the rebase steps are in the repo's `docs/PLAN.md`. Remote `upstream`
has pushing switched off.

- **Builds:** JDK 21 (`jdk21-openjdk`), the SDK in `~/Android/Sdk`
  (platform `android-37.0`, build-tools 36.0.0 — AGP 9.5.1 asks for 36),
  Gradle 9.6.0. `./gradlew assembleDebug lintDebug testDebugUnitTest`; 140
  unit tests, all upstream's. CI (`build.yml`) runs the same and keeps the
  APK as the `ewe-mobile-debug` artifact. Debug signing only, with upstream's
  public `debug.keystore`; **no release key yet** — the owner's to make.
- **Installs:** `adb install`, beside the stock app. Every provider
  authority and the one declared permission come from the id.

## Verified on the owner's phone (2026-11-26)

Pixel 10 Pro XL, Android 17, with the stock KDE Connect 1.37.3 beside it;
the computer runs the stock `kdeconnectd` 26.08.3.

- Installs, pairs, and the computer then shows **two devices with the same
  name** (`ab38d75f…` ours, `be62e5e5…` stock). The desktop's pages read
  through ours: battery, signal, notifications, 53 SMS threads, 38 contacts.
- Android 17 asks for **local network** at first start; until then the app
  does not broadcast at all.
- Permissions granted over adb in one go (`pm grant`, `appops set
  MANAGE_EXTERNAL_STORAGE allow`); **restricted settings did not block** an
  adb install's notification access.
- **The B3 spike** — a plugin that is upstream's RunCommandPlugin turned
  round (announces `kdeconnect.runcommand` out, `kdeconnect.runcommand.request`
  in). Against the stock daemon: `…/devices/<id>/remotecommands` appeared
  for our device only; its `commands` property (`ay`) held our JSON byte for
  byte; `commandsChanged` fired on every resend; `triggerCommand("anything")`
  arrived as `{"key": "anything"}` and `editCommands()` as `{"setup": true}`;
  Georgian, quotes and backslashes came through both ways. Both ends take
  packets up to 32 MiB. **The architecture's one unproven piece holds.**

**Not settled:** with both apps on the phone, ours lost its link three times
at a doze or network change while the stock app's held; the cause is open
(see [[Troubleshooting Knowledge]]). Not tried: B3 itself, the ewe face,
a release build.

## What the desktop can count on

The contract for [[ewe Mobile]]'s pages (written in the repo's
`docs/PLAN.md`, since the phone session does not touch the desktop app):

- **Pick the phone by id, never by name** — two devices for now.
  A device is ours when `…/devices/<id>/remotecommands` exists and its
  `commands` parse as our list.
- **The apps list (proposed for B3):** `commandList` =
  `{"<package>": {"name": "<label>", "command": "<package>"}, …}` plus a
  key `"ewe"` = `{"name": "ewe Mobile", "command": "", "v": 1}`;
  `triggerCommand("<package>")` opens the app on the phone. Icons travel on
  a side channel, never in the list.
- `isReachable` stays `true` for one to two minutes after a link dies.

## Related

- [[RFC-012 — ewe Mobile, both halves]] · [[ewe Mobile]] ·
  [[ewe Mobile — a window over KDE Connect]] · [[Phone Plugin]] ·
  [[Open Questions]] · [[Troubleshooting Knowledge]]
