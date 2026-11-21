---
tags:
  - ewe-map
  - decisions
title: Typing in Other Languages — fcitx5 on demand
up: "[[Decision Index]]"
---

# Typing in other languages — fcitx5, on demand

**Decided 2026-11-21** (owner: "firstly upgrade our tools for good support
for languages and multimedia"; decision 65). Built for ewe 0.46.0-beta +
ewe Settings 0.26.0-beta on `feat/media-languages` — **released 2026-11-21**.
Code: `ewe/bin/ewe-ime`, `dotfiles/quickshell/ImeState.qml`,
`scripts/fcitx5-theme.sh`; ewe Settings `TypingLanguages.svelte`.
Contract: `ewe/docs/SETTINGS-BACKEND.md` "Typing in other languages".

- **fcitx5, never a dependency.** Nothing of it is on a machine until
  someone adds a language in ewe Settings → Keyboard and mouse → *Typing in
  other languages*. The first add installs `fcitx5 fcitx5-gtk fcitx5-qt
  fcitx5-configtool` + the engine package through ewe Settings'
  `install_packages` (one polkit prompt), then `ewe-ime add <id>`. RAM and
  ISO size are why: most people never type a second script.
- **The catalogue** (`ewe-ime catalog`, every package in [extra]): Chinese
  Pinyin (`fcitx5-chinese-addons`, 拼), Japanese Mozc (`fcitx5-mozc`, あ),
  Korean Hangul (`fcitx5-hangul`, 한), Vietnamese Telex (`fcitx5-unikey`),
  and the m17n scripts through `fcitx5-m17n` — Hindi (InScript, ITRANS),
  Bengali, Tamil, Telugu, Marathi, Gujarati, Punjabi, Kannada, Malayalam,
  Odia, Nepali, Sinhala, Thai, Amharic, Tibetan, Khmer, Urdu (22 entries).
  The id is fcitx5's input method name.
- **The pref is its own table**, `[desktop.ime]` {`enabled`, `engines`},
  written through `ewe-conf` (rule 1) — not inside `[desktop.input]`,
  which the Keyboard pane writes whole and `import` rebuilds. It syncs; on
  a computer without fcitx5 it does nothing (no environment, no process;
  `ewe-ime status` lists `missing` packages for the Install button).
- **Two keys, two jobs.** `Super+Space` stays Hyprland's keyboard-layout
  switch (fcitx5's own group keys are cleared); `Ctrl+Space` (+
  Zenkaku_Hankaku, Hangul) toggles the engine — fcitx5's trigger. fcitx5
  gets ONE group on ewe's FIRST keyboard layout (`keyboard-<it>` then the
  engines), so it never converts keys and whatever layout Hyprland shows is
  what you type; under a non-Latin first layout an engine gets `us`.
- **Session wiring** (`ewe-ime apply`): `hypr/generated/ime.env`
  (`XMODIFIERS=@im=fcitx`, `QT_IM_MODULE=fcitx`,
  `QT_IM_MODULES=wayland;fcitx`, `SDL_IM_MODULE=fcitx`) read — never
  sourced, whitelisted names — by `start-hyprland.sh` only with fcitx5
  installed; pushed to the systemd/D-Bus activation env on change. **No
  `GTK_IM_MODULE`**: GTK, kitty and Qt ≥ 6.7 use the compositor's
  text-input protocol. Chromium/Electron get `--enable-wayland-ime
  --wayland-text-input-version=3` in a marked block of their flags files.
  X11 and Qt 5 apps follow after a sign-out (`needs_signout`).
- **One indicator.** The bar's keyboard-layout module shows the engine's
  mark (拼 あ 한) while one is on; fcitx5's own tray item is hidden.
  The candidate window is themed from the design tokens
  (`fcitx5-theme.sh`, re-run by `colorscheme.sh`).
- **Privacy default:** the Pinyin engine's *cloud Pinyin* (what you type
  sent to an online service) is off and its first-run question never
  shows — `conf/pinyin.conf` gets `CloudPinyinEnabled=False` +
  `FirstRun=False`, only where those keys are absent (a later choice of
  the user's stands).
- **Removing the last language turns it off**; the packages stay (Komble
  removes them).

> **Build guard:** fcitx5 and its engines never enter `common.list` or the
> ewe PKGBUILD; `[desktop.ime]` stays its own table; `start-hyprland.sh`
> exports the IM variables only while fcitx5 is installed; never set
> `GTK_IM_MODULE`; stop a running fcitx5 BEFORE writing its profile (it
> rewrites the file on exit). The bar's tray delegate for fcitx5's item
> loads no icon. *Breaks if violated:* every machine pays for an input
> method; a synced file points apps at an IM nobody answers (dead typing in
> X11/Qt apps); Super+Space stops switching layouts; Quickshell 0.3.2
> crashes on an icon name the theme lacks.

## Related

- [[Language Lives in Two Places — ewe.conf and the locale]] ·
  [[EWE-CONF Schema Reference]] · [[CLI Tools]] · [[Keymap Reference]] ·
  [[ewe Desktop]] · [[ewe-settings]] · [[Troubleshooting Knowledge]]
