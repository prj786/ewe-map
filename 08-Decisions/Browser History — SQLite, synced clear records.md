---
tags:
  - ewe-map
  - decisions
title: Browser History — SQLite, synced clear records
up: "[[Decision Index]]"
---

# Browser History — SQLite, synced clear records

**Decided 2026-10-15** while building the owner's ask "a browser with real
syncing and history management" (`ewe-safe/docs/TRIO.md` §B2). Built on
ewe-browser's `feat/history`; the owner approved it, merged as
ewe-browser#5 and **released in ewe browser 0.2.0-beta** (2026-10-15). Full
text: ewe-browser's `docs/PLAN.md`, "History and real sync".

## The decisions

| decision | why |
|---|---|
| History lives in **SQLite** (`history.db`, WAL, FTS5 with the trigram tokenizer) through **`node:sqlite`** | built into Electron 44's Node 24: no native module to rebuild (better-sqlite3 was the old plan). Checked in the packaged app (asar). The in-memory map for the palette and the url completion stays, so those did not get slower |
| `history.json` is imported once, then kept as `history.json.bak` | nothing is lost; a broken database is moved aside and rebuilt from the backup |
| **A delete syncs as a clear record** `{id, at, from, to, url?, site?}` in `ewe/browser/history.json`, next to the data | without a record, the three-way merge brings a deleted page back from the other machine. A visit after the delete wins, a visit before it loses |
| **Clear records are stamped with the server's time** (the median of the WebDAV `Date` headers) when this computer's clock is more than 5 s off | deletes compare times from different machines; one timeline makes "before/after" honest. The sync status warns at 5 minutes off |
| Records live 180 days; a page older than that is uploaded only if the server already has it | an expired record must not let a long-away machine bring a deleted page back |
| **Cookies, site data and cached files clear all time only** | Electron 44's `clearData`/`clearStorageData`/`clearCache` take no time range, and a cookie has no creation time in its API. The dialog shows those options disabled for other ranges, with one sentence why |
| **Tabs from other computers:** each machine writes `ewe/browser/tabs-<id>.json`; `<id>` = 16 hex of a salted SHA-256 of `/etc/machine-id` and the profile path | ewe-conf's convention: the raw machine id is never published; two machines with one host name both show |
| `<userData>/sync/status.json` mirrors the browser's sync state | so ewe-sync can show it (rule 6) — see [[Open Questions]] |

## Not decided here

The browser still has its own *Sync now*. Rule 6 says only ewe-sync has
one; ewe-sync cannot start a browser sync yet. The proposal (a Browser row
in ewe-sync + an `ewe-browser sync` verb) is in [[Open Questions]].

## Related

- [[Decision Index]] · [[ewe-browser]] · [[ewe browser replaces Helium]] ·
  [[Sync Conflicts Are About Content]] · [[RFC-006 — ewe-sync App]]
