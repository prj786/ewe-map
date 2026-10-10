---
tags:
  - ewe-map
  - plugin
title: Mail Plugin
up: "[[Plugin System]]"
---

# Mail — `ewe.mail`

`~/Projects/ewe/ewe-plugin-mail` ·
[github.com/prj786/ewe-plugin-mail](https://github.com/prj786/ewe-plugin-mail)
· v1.1.0 (in ewe 0.25.1; 1.0.0 in 0.25.0) · API 3 · **plugin since 0.25** (was `Mail.qml` + the Gmail half of
`Google.qml` — [[Gmail Split — core Google, Mail add-on]]).

Unread mail where you look: an **Inbox** page (latest ten, click opens
one), an envelope + count in the pill while there is unread mail, a
notification per new message (never a storm for mail that was already
there). Two sources, one inbox — **IMAP wins** when both are set up:

- **IMAP** — the account from Settings → Account → Mail; the core `ewe-mail`
  keeps it in `ewe.conf` + keyring; the plugin runs `ewe-mail status` and
  `ewe-mail unseen` only.
- **Gmail** — through the user's own client connected in ewe-sync; the
  plugin asks the core broker `ewe-auth token --json` for a short-lived
  token (refresh token never leaves the keyring, nothing on disk); History
  API tells new arrivals from old unread.

| kind | file |
|---|---|
| the model — singleton **`Inbox`** (never shadows the core `Mail`) | `Inbox.qml` |
| `service` — the two IPC targets + the resume hook | `Service.qml` |
| `quick-page` key **`mail`** (order 80) | `Page.qml` |
| `bar-status` (order 60) | `Status.qml` |

## Facts

- **Install:** Komble → Plugins, or `ewe-plugin install ewe.mail`.
- **IPC:** `qs ipc call ewe.mail status|refresh|fetch|setNotify <bool>` and
  the alias **`mail`** with the same verbs; the `status` field set and
  order are **byte-identical** to pre-0.25 (test-asserted). ewe-settings no
  longer reads it (D10 — its Mail section is gone).
- **Setting (1.1.0):** `notify` (bool, default true) — new-mail
  notifications. Komble → Plugins → Mail → Options, the Inbox page's bell
  and `mail setNotify` all write it (`Shell.setSetting`, API 3.2); 1.0's
  value in `mail-state.json` is carried over once if it was off
  (`notifyCarried`). [[Plugin Settings Live With the Plugin]]
- Polls every 2 min (5 on battery), on a stale Quick settings open, after
  `Shell.resumed()`.
- **State paths kept:** `~/.config/quickshell/mail-state.json` (IMAP),
  `google-mail.json` (Gmail cursor + notified set) — an upgrade re-notifies
  nothing. "Reconnect Google" → ewe-sync.
- Requires `python` / `python3`, `notify-send`, `xdg-open`.

> **Build guard:** the plugin never touches OAuth, Calendar, Drive or sync
> verbs; a missing `mail` target is **not an error** for ewe-settings
> (`ADDON_TARGETS`).

## Related

- [[Plugin System]] · [[Google Extras]] · [[Gmail Split — core Google, Mail add-on]] ·
  [[ewe-settings]]
