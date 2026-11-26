---
tags:
  - ewe-map
  - decisions
title: ewe Mobile — one ecosystem
up: "[[Decision Index]]"
---

# ewe Mobile — one ecosystem (decisions 78–81)

**Decided 2026-11-26** (owner), the same day [[RFC-012 — ewe Mobile, both halves]]
was accepted. What the owner asked for: see the phone's screen on the PC and
open the phone's apps in ewe; an Android app with ewe's own look ("minimal,
modern, every feature KDE Connect has"); phone notifications that look like
normal ewe notifications — no initials — marked so you know they came from
the phone; no KDE Connect window anywhere, only ewe Mobile; a dock button
with the phone's files and apps. "Imagine it as one ecosystem." Built and
released that evening as one wave (ewe 0.50.0-beta, ewe.phone 1.2.0, ewe
Mobile 0.2.0-beta, eep 0.4.1-beta, the Android app's ewe face). The plan and
the contracts C1–C6: `ewe-mobile/docs/ECOSYSTEM.md`; the contracts as the
vault keeps them are in [[Contracts and Public API]].

## 78 — A phone's notification is an ewe card

Phone app's own icon and name; the card outlined in the **accent colour**
with a **phone chip** (phone glyph + phone name) in the header; the sender
as title; an inline reply field where the app takes a reply. Never
"KDE Connect", never its logo, never initials.

- The shell's notification server advertises `x-kde-display-appname` and
  inline replies; `kdeconnectd` only sends the sender as the title when it
  is told the server can show the app's name ([[Troubleshooting Knowledge]]).
  KDE Connect's own Qt reply dialog never opens.
- Other things `kdeconnectd` says (pairing request, call, file received, low
  battery) are phone cards named **ewe Mobile**.
- Groups key on phone + app. A click opens `ewe-mobile --page notifications`,
  else the Mobile page. The same marking in Quick settings.
- The picture is the app's **launcher icon**: the Android app now sends it
  instead of the notification's large icon (which is where the "initials"
  came from).

## 79 — KDE Connect is the invisible engine (C6)

`kdeconnectd` stays; every KDE Connect window and launcher entry goes.

- The [[Phone Plugin]] hides `org.kde.kdeconnect.app`, `.sms`, `.nonplasma`,
  `.handler` and the settings module from the launcher, reversibly, behind
  the setting `hide_kdeconnect` (default on). Nothing an ewe surface offers
  opens a KDE Connect window: reply is inline, settings are ewe Mobile.
- On the phone the stock KDE Connect app is **uninstalled** (owner's choice,
  once ewe's build worked; done over adb the same evening) and its old entry
  unpaired on the PC. ewe Mobile for Android hides every upstream screen
  behind its own.

## 80 — The phone's apps live in the dock, ewe Mobile and the launcher

- The phone's apps (real icons) are in three places: the **dock button's
  popup** ([[Phone Plugin]], with the phone's folders into ewe Files), ewe
  Mobile's **Apps** page, and **the launcher** (Super+D), marked as phone
  apps. An app opened here gets its real icon in the dock and Overview.
  "Show the phone's apps in the launcher" is a setting, on by default.
- Open here = its own window through scrcpy (needs Wireless debugging);
  open on the phone = start it there. Click picks here when the debugging
  link is up, else the phone.
- The launcher entries are ewe Mobile's, not eep's: they carry
  **`X-Eep-Skip=true`** so [[eep]] never makes a card of them. eep 0.4.1-beta
  has the rule; ewe-mobile's package **conflicts with `eep<0.4.1beta`**.
  Deploy eep first.

## 81 — The Android app's ewe face is a product flavor over an untouched upstream

`ewe-connector-android` (the fork of kdeconnect-android, tag v1.37.3) gets
its look as an `ewe` **product flavor**: our source set `src/ewe/`
(manifest, Compose theme generated from the design system's `tokens.json`,
Geist, Lucide, kit, screens) merges over upstream's by name, so upstream's
`src/main` carries only a short patch table (id, launcher forwarding, the
theme, three one-line fixes, the launcher icon in notifications) and
rebases onto a newer tag stay cheap. Upstream's protocol and plugin code is
kept as it is. Debug builds only for now: the release key does not exist yet
(the owner's to make before anyone else installs).

Details and the patch table: [[ewe Mobile]] (the Android app) and the repo's
`docs/PLAN.md` and `docs/EWE-UI.md`.

## Related

- [[Decision Index]] · [[RFC-012 — ewe Mobile, both halves]] ·
  [[ewe Mobile — a window over KDE Connect]] · [[ewe Mobile]] ·
  [[Phone Plugin]] · [[eep]] · [[Troubleshooting Knowledge]]
