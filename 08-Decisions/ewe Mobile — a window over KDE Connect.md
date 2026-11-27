---
tags:
  - ewe-map
  - decisions
title: ewe Mobile — a window over KDE Connect
up: "[[Decision Index]]"
---

# ewe Mobile — a window over KDE Connect; the shell's surfaces stay the plugin's

**Decided 2026-11-23** (owner: "i want ewe mobile app. based on kde. but i
think beside ewe mobile there will be apk for android. so it will be kde
connect + more staff … for now create new tauri [app] which will use kde
connect backend but will do everything with different ui. so control center
and toolbar indicator will be ewe mobile's ownership not really from kde
connect. we need better ui, contacts, send message and stuff like we have on
kde connect, everything offered from ewe perspective"). Built the same day
as [[ewe Mobile]] 0.1.0-beta and **released that day** (`v0.1.0-beta`), in
a **private** repo: "create new repo … for now private in github".

- **The backend is KDE Connect's daemon, and only the daemon.** ewe Mobile
  owns no link to the phone, no pairing keys and no cache: every action is a
  D-Bus call on `org.kde.kdeconnect`. Nothing of KDE Connect's own UI is used
  (`kdeconnect-app`, `-sms`, `-indicator` come with the package and stay out
  of the way). The phone runs the stock KDE Connect app.
- **The window is a Tauri app; the bar glyph and the Quick settings page are
  the plugin.** A Tauri window cannot be a layer surface (rule 3), so "ewe
  Mobile's indicator and control centre" is the [[Phone Plugin]] — which
  already existed — and it opens the window (`ewe-mobile --page <id>`). One
  feature, two processes, like ewe Sync and its bar glyph.
- **Its own repo, the ewe Sync stack** (Tauri 2 + Svelte 5 + the design
  system's `tokens.css` / `components.css`): a product with an Android half
  to come does not belong inside `ewe-apps` (Files · Player · Viewer, one
  package), and a single app does not need that repo's workspace.
- **Not resident, keeps nothing** ([[Apps Are Not Resident]]): the daemon is
  the source of truth; the window reads it and ends with its last window. No
  `ewe.conf` key.
- **The page ids are public** (`phone messages contacts notifications media
  files remote devices`): the plugin and other apps open them; a label may
  change, an id never.
- **Honest about writes:** a message sent from the window is "Sending…" until
  the phone reports it sent, "not confirmed yet" after 30 s, "Not sent" with
  the reason when the daemon refuses — the daemon itself reports nothing
  back, so the page never claims more than it knows.
- **`sshfs` is installed by default** (owner: "make sshfs installed by
  default"): in `ewe`'s `packages/common.list` since 0.49.2 — a dependency
  of the `ewe` package — and of `ewe-mobile` itself. KDE Connect mounts the
  phone's storage with it and lists it only as optional, so "Browse its
  files" failed on every machine. An owner exception to
  [[The Package Diet]] (90 KB; `fuse3` and `openssh` were already there).
- **Private for now** (superseded 2026-11-27: the repo is public and the
  package is in `[ewe]`, [[ewe Mobile — public and opt-in]]). The repo was private, so the package is on its own
  release only: not in `[ewe]` (ewe-repo's workflow cannot read a private
  repo's release), not on the website. Going public later is a list entry in
  ewe-repo's publish workflow and a page on the site.

**Later, not decided here:** the Android app ("apk"), and whatever protocol
"KDE Connect + more" becomes. The app's seams for it: `kdc.rs` is the only
file that knows the daemon, and the page speaks in its own JSON (`api.js`),
not in D-Bus. **Decided 2026-11-26:** [[RFC-012 — ewe Mobile, both halves]]
— the APK is a fork of the KDE Connect app, and it reaches the unchanged
daemon through its `remotecommands` plugin.

## Related

- [[ewe Mobile]] · [[Phone Plugin]] · [[Phone and VPN]] · [[Process Split — Shell vs Apps]] ·
  [[Apps Are Not Resident]] · [[One Name — Plugins]] · [[The Package Diet]]
