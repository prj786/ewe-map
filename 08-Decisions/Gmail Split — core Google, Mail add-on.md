---
tags:
  - ewe-map
  - decisions
title: Gmail Split — core Google, Mail add-on
up: "[[Decision Index]]"
---

# The Gmail split — core Google stays, the mail visuals move to `ewe.mail`

**Decided 2026-10-04** (ewe 0.25.0-beta, B1 + C4). `Google.qml` is split
along one line:

| stays **core** (`Google.qml`, `ewe-auth`) | moves to the [[Mail Plugin]] (`ewe.mail`) |
|---|---|
| OAuth (PKCE loopback), the broker, the keyring refresh token | Gmail unread polling (`labels.get(INBOX)`, `users.history.list` cursor) |
| Google **Calendar** (Agenda, reminders) and **Drive** (`ewe-drive`) | Gmail **notifications** for new arrivals |
| the settings-sync verbs (`google syncSoon` …) and `google status` | the Inbox page, the bar envelope + count, `mail` IPC (+ `ewe.mail`) |
| `ewe-mail` (IMAP tool) and the account in `ewe.conf` / keyring | the IMAP visuals (`Mail.qml` moved entirely) |

- The add-on asks the core broker for a short-lived token — `ewe-auth token
  --json` — exactly as the shell did at pre-carve commit `3fc700d`; the
  refresh token never leaves the keyring and no token touches disk (Rule 2).
- State paths are **kept** (`~/.config/quickshell/mail-state.json`,
  `google-mail.json`) so an upgrade re-notifies nothing. "Reconnect
  Google" still goes to ewe-sync.
- `status` field set and order are **byte-identical** to the old `mail
  status` (test-asserted) because ewe-settings → Account reads them.
- Open: core `google status` still reports `mailUnread`/`mailState`
  (ewe-settings reads them) — drop or proxy later; should ewe-sync poke
  `mail refresh` after sign-in?

> **Build guard:** the add-on never touches OAuth, Calendar, Drive or sync;
> the core never draws mail. *Breaks if violated:* two pollers on one Gmail
> quota, or a signed-out Google taking the Calendar down with the mail.

## Related

- [[Decision Index]] · [[Google Extras]] · [[Mail Plugin]] · [[Auth Broker]] ·
  [[Add-ons — opt-in, not preinstalled]]
