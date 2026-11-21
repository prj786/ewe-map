---
tags:
  - ewe-map
  - decisions
title: Language Lives in Two Places — ewe.conf and the locale
up: "[[Decision Index]]"
---

# Language lives in two places — ewe.conf and the locale

**Decided 2026-11-21** (decision 66; the owner: "go, no translation for
now"). Built for ewe 0.46.0-beta + ewe Settings 0.26.0-beta on
`feat/media-languages` — **released 2026-11-21**. Code: `ewe/bin/ewe-conf`
(`desktop.language`, `desktop.ime`), ewe Settings `backend.rs`
(`install_packages`, `set_locale`) + `language.rs` (`spell_info`,
`formats_info`, `set_formats`, `language_packs`, `komble_search`).

- **What follows you (ewe.conf, synced):** `[desktop.language]`
  `spellcheck` (hunspell names, e.g. `["en_US", "ka_GE"]`, ≤ 16, shape
  `^[a-z]{2,3}(_[A-Z]{2})?(-[A-Za-z0-9]{2,12})?$` because the names reach
  package names and paths; unset = the display language's dictionary when
  installed + `en_US`, decided by each reader) and `check_spelling` (bool,
  default **true** — `ewe-conf get` answers it unset); `[desktop.ime]`
  ([[Typing in Other Languages — fcitx5 on demand]]). Both have their own
  `_domain` (`language`, `ime`): a `set` rebuilds no theme and reloads no
  Hyprland. A name with no dictionary / engine on a machine is skipped
  there — the file syncs to computers that lack the package.
- **What belongs to the machine (the locale, never ewe.conf):** the
  display language `LANG` and the **regional formats** `LC_TIME`,
  `LC_NUMERIC`, `LC_MONETARY`, `LC_MEASUREMENT`, `LC_PAPER` —
  `localectl set-locale` through pkexec (generating the locale when
  needed), always naming LANG and the formats together so one never drops
  the other. Settings → Time and place → **Formats** picks one region for
  the five (an English desktop with German formats); *Same as the display
  language* clears them. Apps read them at start: "Applies after you sign
  out" (whether a sign-out suffices or PID 1 needs a reboot is **open** —
  [[Open Questions]]).
- **The shell's clock follows the formats:** `Globals.clock24` reads the
  region's short time pattern (`Qt.locale()` reads LC_*), and
  `Globals.formatTime` / `timeFormat` are the one answer for every clock
  (bar, lock, screensaver, agenda, notifications, Remote); the calendar
  starts the week where LC_TIME says. Date words stay English — **ewe's
  own interface is not translated** (parked, its own wave —
  [[Parked and Rejected Ideas]]).
- **One on-demand install path** in ewe Settings: `install_packages(names)`
  → `{"ok":true,"installed":[…]}` (or `already`) — official-repo packages
  only, names held to the families `hunspell-*`, `firefox-i18n-*`,
  `thunderbird-i18n-*`, `libreoffice-fresh-*` / `-still-*`, `fcitx5` /
  `fcitx5-*` (≤ 64 chars, ≤ 32 names), checked against the sync databases
  (`pacman -Sp`), already-installed skipped, then `pkexec pacman -S --needed
  --noconfirm` — **one polkit prompt**. A held pacman lock is refused
  before the prompt. A dictionary only the AUR has (Georgian `hunspell-ka`,
  Ukrainian, Portuguese …) opens Komble's search (`komble
  --search=hunspell-ka`) instead — the AUR stays Komble's (decision 9).
- **Also for your apps:** Settings → Language offers the display
  language's packs for Firefox, Thunderbird and LibreOffice — only for the
  ones installed (`language_packs`).

> **Build guard:** LANG and LC_* never enter ewe.conf (a synced file would
> push one machine's locale onto another); a new language pref gets its own
> key under `[desktop.language]` with a `_domain` that applies nothing it
> doesn't need; `install_packages` keeps its family allow-list and
> official-repo check, and never builds from the AUR. *Breaks if
> violated:* a sync changes another computer's locale; a Settings typo
> becomes a root pacman run; a spelling change reloads Hyprland.

## Related

- [[Spell Checking — hunspell and Chromium]] ·
  [[EWE-CONF Schema Reference]] · [[ewe-settings]] · [[Komble]] ·
  [[The One File]] · [[Contracts and Public API]]
