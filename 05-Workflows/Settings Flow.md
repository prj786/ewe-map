---
tags:
  - ewe-map
  - workflow
title: Settings Flow
up: "[[Home]]"
---

# Settings Flow — how a change travels

Two-layer model: **live-apply** (instant, in-session) + **persist** (through
the file). The UIs apply instantly; the file is the memory.

```mermaid
sequenceDiagram
    participant U as you
    participant S as ewe-settings (Tauri)
    participant CLI as ewe-conf
    participant F as config files
    participant SH as shell (Quickshell)
    participant HY as Hyprland

    U->>S: change the accent
    S->>F: atomic write (temp + rename), merged
    S->>SH: qs ipc call settings reload
    SH->>F: re-read → apply live (no relogin)
    Note over S,HY: (current contract: S writes the same files<br/>the shell reads — user-theme.json today)

    alt with the one file (RFC-001)
        S->>CLI: ewe-conf set desktop.theme.accent ...
        CLI->>F: regenerate artifacts (ewe-conf apply)
        SH->>F: re-read → apply live
    end

    Note over U,HY: a change survives a shell restart for free —<br/>and it's exactly the file the cloud sync backs up
```

## The contract's three useful properties

1. **One source of truth** — the file (today: `user-theme.json`; the one
   file under RFC-001). The shell and ewe-settings both merge, never
   replace, because both write.
2. **Restart-proof** — writes succeed even if the shell isn't running; they
   take effect at the next login.
3. **Sync-neutral** — those files are exactly what the cloud sync already
   backs up; no new sync path.

## Who writes what (under RFC-001)

| actor | write path |
|---|---|
| ewe-settings / shell panels / Komble | call `ewe-conf set` — the **only writer** |
| `ewe-conf apply` | regenerates runtime artifacts from the file |
| Hyprland/Quickshell | read artifacts at runtime/login |
| cloud | `ewe-conf push` / `pull` move the file itself |

## Related

- [[ewe-settings]] · [[The One File]] · [[Desktop Shell]] ·
  [[System Architecture]]
