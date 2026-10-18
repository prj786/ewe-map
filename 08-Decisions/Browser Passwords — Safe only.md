---
tags:
  - ewe-map
  - decisions
title: Browser Passwords — Safe only
up: "[[Decision Index]]"
---

# ewe browser fills logins with Safe only (#40)

**Decided 2026-10-18** by the owner (wave 2), **released in ewe browser
0.4.0-beta** (ewe-browser#13). The browser's `docs/PLAN.md` records the ask
as "no third-party passwords (only Safe fills inputs)". It narrows the
browser half of [[Safe in the Browser — guards, not a page click]]; the
desktop's `Super+P` picker ([[Passwords Plugin]], `ewe-pass`) is not
touched.

| was (0.2.0-beta – 0.3.0-beta) | now (0.4.0-beta) |
|---|---|
| two fill routes: Safe's inline list, and `Ctrl+Shift+L` → `ewe-pass` (whatever manager the Passwords plugin names: 1Password, Bitwarden, …) through `ewe:passwords` and an overlay picker | one route: Safe. `Ctrl+Shift+L`, the key in the address field and the page's right-click menu all open **Safe's own list** for the focused field (or the page's first login field) |
| any Web Store extension could be added, password managers included | password-manager extensions are **refused**: `installFromStore` refuses them before downloading, `beforeInstall` denies them, and an installed one is refused **before Chromium loads it** (none of its scripts run), with the toast "ewe browser fills passwords with Safe" |

How the refusal finds them: a **best-effort list of 36 Web Store ids**
(`PASSWORD_MANAGER_EXTENSIONS` in `packages/shared/src/input.ts`, each
checked on 2026-10-18), not a capability check. The id comes from
`manifest.key` (sha256, a–p) or the store folder's name. A manager under
another id, or a sideloaded copy without the store key, is not caught; a
turned-off one stays in `<userData>/Extensions` and is not listed in
Settings yet.

## Why

- One place decides what fills a page, and it is the one ewe can hold to
  its guards: Safe's list is drawn by the browser, the main process decides
  the origin, nothing fills without a click ([[RFC-008 — ewe Safe]] S10).
- An extension sees every page it runs on; a password manager's extension
  sees every login field. Refusing it before it loads keeps that out.
- `ewe-pass` typed secrets with `wtype` into whatever had focus: fine for
  native apps (the desktop keeps it), needless inside a browser that has
  Safe built in.

> **Build guard:** the browser has no second fill route: no
> `ewe:passwords` channel, no `ewe-pass` call, no picker of its own;
> `passwords.open`, the `passwords` shortcut and the page menu go through
> `WindowController.openSafeKey` → Safe's ordinary `open {trigger: 'key'}`.
> Keep the id check in `ExtensionHost`'s `loadExtension` wrapper, before
> `installChromeWebStore` scans the folder. *Breaks if violated:* a
> third-party manager fills pages again, or a listed extension's scripts
> run once before it is unloaded.

## Related

- [[Decision Index]] · [[ewe-browser]] · [[ewe-safe]] ·
  [[Safe in the Browser — guards, not a page click]] · [[Passwords Plugin]] ·
  [[Security Posture]]
