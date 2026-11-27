---
tags:
  - ewe-map
  - decisions
title: ewe Mobile — public and opt-in
up: "[[Decision Index]]"
---

# ewe Mobile — public and opt-in (decision 82)

**Decided 2026-11-27** (owner). The desktop app, `prj786/ewe-mobile`, is
**public**, and its package is an **opt-in package in `[ewe]`**, the pattern of
[[ewe-safe]]: `sudo pacman -S ewe-mobile`, not installed until asked for.
The Android app's repository, `prj786/ewe-connector-android`, **stays
private**.

This replaces the "private for now" of
[[ewe Mobile — a window over KDE Connect]] (decision 76), which kept the
package on its own GitHub release, out of `[ewe]` and off the website.

- **In `[ewe]`.** ewe-repo's publish workflow takes the newest
  `prj786/ewe-mobile` release's package the way it takes ewe-safe's and
  ewe-companion's: a missing package is a warning, not a failure. The job's
  token reads only public repos, so if the repo ever goes private again its
  release becomes invisible and the repo stops carrying the package. The
  package depends on `kdeconnect` and `sshfs`; `android-tools` and `scrcpy`
  are optional (Komble offers them). The package says
  `conflicts=('eep<0.4.1beta')` ([[eep]]).
- **On the website.** The docs have an ewe Mobile page and the plugin list
  describes the Phone plugin's part ([[Website]]).
- **The installer.** The next ISO (0.18.0-beta) offers ewe Mobile, unchecked,
  in a "From ewe" group on its Apps screen ([[Install Flow]]). ewe Safe is not
  offered there a second time: the Plugins screen's ewe Safe plugin requires
  the ewe-safe package, so picking that plugin installs the app.
- **The Android app stays private.** It has no public release and no store
  listing. Public copy says it is not released yet and links nothing of it.
  The stock KDE Connect app works for everything except real app icons on the
  Apps page ([[ewe Mobile]]).
- **What stays out of public places.** The owner's decision, the same day: no
  bank names and no exact phone model in anything published, the vault
  included. Generic wording: "some banking apps refuse to run while Developer
  options is on"; "a Pixel on Android 17" or just "the phone".

Related: [[ewe Mobile]] · [[ewe Mobile — one ecosystem]] ·
[[RFC-012 — ewe Mobile, both halves]] · [[Pairing a Phone]]
