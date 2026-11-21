---
tags:
  - ewe-map
  - decisions
title: Language First — the installer asks in your words
up: "[[Decision Index]]"
---

# Language first — the installer asks in your words, and apps wait in Komble

**Decided 2026-11-21** (owner: "firstly upgrade our tools for good support
for languages and multimedia … finally update installer"; decision 72).
Built for **ewe-os 0.17.0-beta** (ewe-os#22, branch `feat/installer-017`)
and **Komble 0.25.0-beta** (komble-arch#23, `feat/install-picks`). Code:
`ewe-os/installer/src-tauri/src/language.rs`, `installer/src/lib/lang.js`,
`installer/src/lib/steps/{Language,Keyboard,Apps}.svelte`,
`installer/helper/ewe-install-helper` (`setlocale`, `setkeymap`,
`language`, `apps`), `iso/airootfs/usr/local/bin/ewe-install` (greeter
keyboard), `komble-arch/src-tauri/src/picks.rs`,
`src/lib/components/ForYou.svelte`. Contract:
`ewe-os/docs/RFC-003-installer.md` (addendum 0.17).

- **One decision, the rest suggested.** The first screen is **Language**:
  every UTF-8 locale glibc supports, named in its own language and in
  English (`Intl.DisplayNames`, glibc's `lang_name` when WebKit lacks the
  data). Picking it pre-fills — never asks again — the region, the
  keyboards (xkb `<languageList>`), the formats, the spelling dictionary
  (ewe Settings' table; an AUR-only one is said plainly, English checked)
  and, for Chinese, Japanese, Korean, Vietnamese and the Indic languages,
  typing (fcitx5 + its engine from ewe-ime's catalogue).
- **A non-Latin language starts on English (US).** The keyboard list is
  `us,<layout>`, so a username and password type the same on the login
  screen, the console and over SSH; Super+Space switches. The Keyboard
  screen applies the list to the live session at once (`hyprctl eval`), so
  the password chosen on *Your login* is typed the way the new login screen
  reads it; the login screen (cage) takes `XKB_DEFAULT_*` from localectl's
  X11 keymap, the console the first layout that types a–z.
- **The locale is the system's, the rest is ewe.conf** ([[Language Lives in
  Two Places — ewe.conf and the locale]]): `/etc/locale.conf` gets LANG and
  the five regional formats (`LC_TIME`, `LC_NUMERIC`, `LC_MONETARY`,
  `LC_MEASUREMENT`, `LC_PAPER`), `en_US.UTF-8` is always generated beside
  it; `[desktop.input]`, `[desktop.ime]`, `[desktop.language]` are written
  **through `ewe-conf` as the new user, before `account`** — a restore from
  the account brings that computer's keyboard, typing and spelling over
  these. Plain English on a US keyboard skips the `language` verb.
- **Apps for day one, never built by the installer.** The optional **Apps**
  screen shows Komble's curated list (a verbatim copy,
  `scripts/sync-curated.sh`). Repo apps install in the target (`apps`
  verb, one pacman run, one by one if that fails); **Steam turns on
  `[multilib]`** with this GPU's lib32 Vulkan driver (pacman alone would
  pick lib32-nvidia-utils). AUR and AppImage picks — and any repo app that
  did not install — go to `~/.local/state/ewe/install-picks.json`
  (`{"version":1,"at":…,"picked":[{"pkg","source"}]}`, owned by the user);
  **Komble 0.25** shows them on For you as *Apps you picked while
  installing ewe* (Install; Review… = its PKGBUILD gate for the AUR;
  Dismiss), counts them in the sidebar, opens there while any wait, and
  deletes the file when none are left.
- **Best-effort, like the plugins:** `language` and `apps` print
  `{"warn": …}` lines the Done screen shows with where to get the thing
  later (ewe Settings → Keyboard and mouse / Language, Komble); the OS
  install stands.
- **Found by the QEMU pass and fixed in the same release:** GUI installs
  never had `sudo` (base does not carry it; the installer only wrote
  `/etc/sudoers.d/wheel`) — `pacstrap` now adds it; the Disk screen listed
  the live system's zram swap, so nothing was preselected.
- **The owner's calls after the release** (2026-11-21): "add sudo to ewe,
  keep steam" — `sudo` is in ewe's `packages/common.list` (ewe#90, merged,
  ships with the next ewe release), so machines installed with ISO ≤ 0.16
  get it on their next update; picking Steam keeps turning on `[multilib]`.
- **Not done here:** installer translations (the owner: "no translation for
  now"); Steam, AppImage picks, a real AUR build, the Chinese / Korean /
  Vietnamese / Indic paths and a restore after the language step were not
  run in QEMU (Steam stays in the installer — the owner's call); repo apps
  installed by the installer are not recorded in
  `[apps.installed]` (they do not follow the account yet); Mozc's layout
  under `jp` is `us` in ewe-ime (JIS symbol keys may differ).

> **Build guard:** the installer never builds from the AUR and never
> fetches an AppImage — anything it cannot install from a signed repo goes
> to the picks file for Komble's review. ewe.conf is written only through
> `ewe-conf` as the new user (rule 1); the language's keyboard list keeps a
> Latin layout first. *Breaks if violated:* an unreviewed PKGBUILD runs as
> root inside the installer; a password set on a Georgian or Russian layout
> cannot be typed at the console or over SSH.

## Related

- [[ewe-os ISO]] · [[Install Flow]] · [[Komble]] ·
  [[Typing in Other Languages — fcitx5 on demand]] ·
  [[Spell Checking — hunspell and Chromium]] · [[Troubleshooting Knowledge]]
