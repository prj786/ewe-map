---
tags:
  - ewe-map
  - decisions
title: Spell Checking — hunspell and Chromium
up: "[[Decision Index]]"
---

# Spell checking — system hunspell for the apps, Chromium's own in ewe Browser

**Decided 2026-11-21** (decision 67). Built for ewe 0.46.0-beta, ewe
Settings 0.26.0-beta and ewe Browser 0.9.0-beta — **released 2026-11-21** (ewe
Browser through ewe-browser#24).

- **The system's engine:** `hunspell` + `hunspell-en_us` ship on every
  machine (`packages/common.list` → the ewe PKGBUILD's depends). enchant
  (pulled in by WebKitGTK) finds `/usr/share/hunspell`, so WebKitGTK apps,
  LibreOffice, Firefox and Thunderbird can check spelling — before this,
  no dictionary was installed at all. Other languages are **on demand**
  (Settings → Language → Spell checking → *Add a language…*,
  `install_packages`; AUR-only ones open Komble's search) — never in
  `common.list`.
- **The languages are one pref:** `[desktop.language] spellcheck` +
  `check_spelling` ([[Language Lives in Two Places — ewe.conf and the locale]]).
- **ewe Browser checks with Chromium's own dictionaries**, not hunspell's:
  Chromium reads only `.bdic` files in `<userData>/Dictionaries`.
  `SpellingService` (`main/spelling.ts`) maps each hunspell name to
  Chromium's tag (`en_US` → `en-US`, `de_AT` → `de`) from
  `session.availableSpellCheckerLanguages` and applies them live to every
  web session (a `DirWatch` on ewe.conf). A language Chromium has no
  dictionary for (**Georgian** …) is skipped and shown as *"isn't checked in
  ewe Browser yet"*; none left = the spellchecker off. Outside ewe (no
  `ewe-conf`) it checks the display language + US English and its switch
  reads "Only on the ewe desktop".
- **Network note:** Chromium downloads a `.bdic` from Google's dictionary
  server the first time a language is used (as Chrome does) — ewe Browser
  sets no other download URL. Not a Google *client* (rule 7 is about
  OAuth), but it is a request to Google; see [[Open Questions]].
- **Menu:** suggestions, *Add to dictionary*, *Ignore* (this run only —
  `<userData>/spelling-ignored.json`, ≤ 500 words, removed from every
  session's dictionary at the next start); Settings → Browsing → Spelling
  (switch, languages, *Change in ewe Settings* = `ewe-settings
  --page=language`).
- **Not now:** a hunspell → `.bdic` conversion (Chromium's `convert_dict`)
  or a renderer-side provider for the languages Chromium lacks; Shaun's
  notch field (QML) gets no checker.

> **Build guard:** ship exactly one dictionary (`hunspell-en_us`) with
> ewe; the rest stay on demand. Never assume a hunspell name has a Chromium
> dictionary — map through `availableSpellCheckerLanguages` and say which
> are not checked. *Breaks if violated:* every machine downloads dozens of
> dictionaries; ewe Browser silently claims to check Georgian and doesn't.

## Related

- [[ewe-browser]] · [[ewe-settings]] · [[EWE-CONF Schema Reference]] ·
  [[Troubleshooting Knowledge]]
