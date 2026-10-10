---
tags:
  - ewe-map
  - decisions
title: Plugin Settings Live With the Plugin
up: "[[Decision Index]]"
---

# A plugin's settings live with the plugin (D10)

**Decided 2026-10-10** (released in ewe 0.25.1-beta).
The user's words: *"we made dock as an addon, so all settings goes there"*,
and Options must open *"a dialog where i can change settings, not just way
bottom"*.

- **Where:** Komble → Plugins → a plugin → **Options…** — a Dialog with
  *Settings* (the manifest's `settings`), *In the bar* (Show in bar) and *On
  the desktop* (a desktop widget's pin, pin level, lock, visibility,
  position). Changes apply at once; *Done* closes it.
  `komble --options=<id>` opens it directly (ewe-settings' "Dock options").
- **Dock:** auto-hide and icon size are `ewe.dock`'s own settings since Dock
  1.1.0 (`[plugins.settings]."ewe.dock"`). Each declares `legacy:
  "desktop.dock.<key>"`, so the old value stands until set — nobody's dock
  changed. On/off is the plugin's own switch (the soft `enabled` hide is
  gone). Settings → *Layout and dock* became *Layout* with one "Dock options"
  row.
- **Show in bar:** one host switch per plugin with a bar widget or a
  bar-status glyph (`ewe-plugin bar <id> on|off` →
  `desktop.bar.show."plugin:<id>"`, the key the bar always read). The
  per-plugin rows left Settings → Layout. A manifest's `defaultShown` is the
  state before the user picks (System monitor: false — its own 1.0
  `show_in_bar` setting is gone, a stored value still counts); `toggle:
  false` means the plugin's own setting places its button (Music, Places:
  "Where the button lives"), so there is no switch.
- **Mail:** notifications are `ewe.mail`'s `notify` setting (1.1.0); the
  Inbox page's bell and `mail setNotify` write it through `Shell.setSetting`.
  Settings → User lost its Mail section (the account is ewe-sync's).
- **Settings no longer mentions a plugin you do not have:** the Shortcuts
  pane hides rows that name an uninstalled `ewe.*` plugin; the Screensaver
  and Network notes mention Insomnia / the VPN card only when installed.

## Amends D1

[[Add-ons — opt-in, not preinstalled]] listed the `desktop.dock.*` keys as
core. They are now **legacy**: kept in `THEME_MAP` (so `absorb` never drops
a value a plugin still falls back to) but nothing writes them.
`Shell.dockPrefs` stays (API 3) as the Dock's fallback.

> **Build guard:** a setting that only affects one plugin is declared in
> that plugin's manifest, never added to ewe-settings; moving one out uses
> `legacy` so the value carries over. *Breaks if violated:* two switches for
> one thing, or an upgrade that silently resets a user's choice.

## Related

- [[Decision Index]] · [[Dock Plugin]] · [[Plugin Manifest Reference]] ·
  [[Komble]] · [[ewe-settings]] · [[Mail Plugin]] · [[System Monitor Plugin]]
