---
tags:
  - ewe-map
  - decisions
title: Sync Conflicts Are About Content
up: "[[Decision Index]]"
---

# A sync conflict is about content, not an ETag (D12)

**Decided 2026-10-10** (released in ewe 0.25.1-beta),
from a live diagnosis on the home laptop (`emoh`): sync had been refused
since 2026-09-13 with *"Another machine ("emoh") saved newer settings"* —
naming the laptop itself.

## What happened

1. An auto-push from the laptop (the display `lastKey` changes on every
   dock/undock → `ewe.conf` changes → push 20 s later) stored `ewe.conf` on
   the server, but the rest of the push never finished — the reply was lost
   (lid closed mid-request) or the `ewe.conf.meta.json` stamp PUT failed.
   The local record (`~/.local/state/ewe/sync.json`) kept the OLD ETag.
2. Every later push: recorded ETag ≠ server ETag → `remote-newer`, forever.
3. ewe-sync never offered *Push anyway / Restore*: its banner keyed on
   `sync-status`'s `error`, which only ever carried transport errors.
4. Both machines may be named `emoh`, so the stamp could not say whose copy
   it was.

## The rules now (ewe-conf)

- **The record follows the bytes.** `sync.json` keeps the `sha256` of what
  this machine last pushed or pulled, and `pending` hashes of uploads in
  flight. When the server's ETag moved but its bytes are ones this machine
  synced or sent, the ETag is **adopted** — no conflict (`_resolve`). A
  same-bytes re-upload (the Nextcloud desktop client syncing
  `~/Nextcloud/ewe`) is covered too. Different bytes are still a conflict.
- **An upload that landed is recorded**, even if the meta stamp is refused
  (`"warning": "stamp-missing"` on an `ok` push; the next push re-stamps).
- **`sync-status` answers `conflict`** (`remote-newer` | `remote-exists` |
  null) and `remote_is_this_machine`. `error` stays the transport error.
- **Machine id:** the stamp (`ewe.conf.meta.json`, Drive appProperties)
  carries `machine_id` = first 16 hex of sha256("ewe-conf:" +
  /etc/machine-id) — never the raw id — so same-named machines are told
  apart.

ewe-sync shows the banner from `conflict` (an older ewe-conf: from
`in_sync`), says "this computer" when `remote_is_this_machine`, and its
tray shows the conflict state. The shell's Cloud.qml reflects a
`remote-newer` from status and clears one the engine healed. ewe-settings →
User shows it with *Resolve in ewe-sync*. Nothing else got a sync button
(rule 6).

> **Build guard:** never decide "someone else saved" from an ETag alone —
> compare the bytes against what this machine sent or saw; record an
> upload the moment the server stored it. *Breaks if violated:* one
> interrupted request locks a machine out of sync for good.

## Related

- [[Decision Index]] · [[Account and Sync]] · [[RFC-005 — Nextcloud Account]] ·
  [[RFC-006 — ewe-sync App]] · [[Troubleshooting Knowledge]]
