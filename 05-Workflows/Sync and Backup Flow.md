---
tags:
  - ewe-map
  - workflow
title: Sync and Backup Flow
up: "[[Home]]"
---

# Sync & Backup Flow — log in, get your machine back

The promise: **log in, get your machine back.** `ewe.conf` describes the
machine; ewe-sync moves it to your Nextcloud and back. Nothing else in ewe
has a sync button.

```mermaid
flowchart TB
    subgraph MACHINES["your machines"]
        A["machine A<br/>ewe.conf · folders"]
        B["machine B (fresh install)<br/>empty ewe.conf"]
    end

    subgraph ACCOUNT["your Nextcloud account"]
        F1["ewe/ewe.conf<br/>(+ .meta.json: who saved it, when)"]
        F2["ewe/machines/<name>.json<br/>ewe version · app count"]
        F3["your synced folders"]
    end

    A -->|"ewe-conf push<br/>WebDAV If-Match"| F1
    F1 -->|"ewe-conf pull"| B
    A --> F2
    B --> F2
    B -->|"restore: apply ewe.conf,<br/>Komble 'For you' offers the missing apps"| B
    A <-->|"nextcloudcmd (two-way)<br/>rclone copy (one-way)"| F3
    B <--> F3
```

## The one-file half

- **Backup** — `ewe-conf push`: WebDAV PUT with `If-Match`. The server
  itself rejects a push that races another machine (412) — no clock or
  hostname guesswork.
- **Restore** — `ewe-conf pull`, then `ewe-conf apply` regenerates the
  runtime files. Installed apps come back through Komble's **For you**,
  which reads `[apps.installed]` from the restored file.

## The folders half

| mode | engine | behaviour |
|---|---|---|
| two-way | `nextcloudcmd` (Nextcloud client's headless engine) | syncs both directions; conflicts in place |
| upload-only / download-only | `rclone copy` | adds and updates, **never deletes** |

Triggers: on change (inotify + 5 quiet seconds) · every N minutes · at
login. Conflicts land as `name (conflicted copy <date>).ext`; *Keep mine* /
*Keep theirs* resolves.

## The machines pane

Every machine that backed up to the account shows up with its ewe version
and app count — the roster of what shares this account.

## Related

- [[Account and Sync]] · [[ewe-sync]] · [[The One File]] · [[Auth Broker]]
