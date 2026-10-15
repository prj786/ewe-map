---
tags:
  - ewe-map
  - plugin
title: Safe Plugin
up: "[[Home]]"
---

# Safe — `ewe.safe`

`~/Projects/ewe/ewe-plugin-safe` ·
[github.com/prj786/ewe-plugin-safe](https://github.com/prj786/ewe-plugin-safe)

First-party plugin (API 3, 1.0.0), vendored in the payload since **ewe
0.27.0-beta**, opt-in like every plugin (`default: false`, `migrate:
false`), `requires` the `ewe-safe` package ([[ewe-safe]], RFC-008). It is
Safe's presence on the desktop; the fill picker stays the
[[Passwords Plugin]] (`Super+P`, provider `ewe`).

| kind | what |
|---|---|
| bar-status | a lock in the Quick settings pill — closed / open; a red dot when sync needs attention (error, an older copy from the server, a master password changed elsewhere), an orange dot when Safe isn't running; click → Quick Access |
| panel — **Quick Access** (`Super+Shift+P`) | search every item; Enter copies the password, Ctrl+C the username, Ctrl+O the one-time code (shown with its countdown — the only secret ever shown); Ctrl+Enter opens the item in Safe, Ctrl+N a new login, Ctrl+L locks; locked → Enter runs `ewe-safe unlock --ask` |
| quick-tile | "Safe — Locked / Unlocked"; tap locks or unlocks, the chevron opens the Safe window |

- **No secret enters the shell:** copies go through `ewe-safe copy` (the
  daemon fills and clears the clipboard); the master password is never typed
  here (RFC-008 S4).
- **State** from a bridge running `ewe-safe watch` (NDJSON), restarted by a
  watchdog — a missing binary never emits `exited`, so a plain restart-on-exit
  would stop retrying.
- `Super+Shift+P` because `Ctrl+Shift+Space` is 1Password's Quick Access on
  the owner's machine (through `ewe-globalshortcuts`) and JetBrains' parameter
  hints.

Install / remove (Komble → Plugins, or):

```sh
ewe-plugin install ewe.safe
ewe-plugin remove ewe.safe
```

## Related

- [[ewe-safe]] · [[Passwords Plugin]] · [[Plugin System]] · [[RFC-008 — ewe Safe]]
