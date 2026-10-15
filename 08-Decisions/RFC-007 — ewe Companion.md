---
tags:
  - ewe-map
  - decisions
title: RFC-007 — ewe Companion
up: "[[Home]]"
---

# RFC-007 — ewe-companion, the desktop companion

*Status: **accepted** 2026-10-14 (owner idea 2026-10-13; every proposed
answer taken). P1 done, P2 working, P2.5–P2.8 done, P2.9 (Safe, ewe browser,
the finder) merged 2026-10-15, not released (see [[Roadmap — ewe-companion]]). Full text: `ewe/docs/RFC-007-companion.md`;
build plan: `ewe-companion/docs/PLAN.md`.*

## The idea

A quiet island in the bar's empty centre (like Coucou on macOS, plus the
desktop half only ewe can do):

- Claude Code permission prompts and questions from any terminal, answered in
  the island (**Allow · Deny · Always**).
- Peeks when an agent finishes, a download lands, the disk fills up, or a
  notification has been unread since yesterday.
- Optionally, the island shows notifications itself instead of the stock
  banners.
- A small chat that can use ewe's services through tiered tools.
- Providers: your own API key, a local model, or an agent you are already
  logged in to.

**Division of labour:** the shell draws, the daemon thinks, the existing
tools act. The companion asks, tells and delegates; it never builds a second
pipeline (ewe-conf writes, ewe-sync syncs, Komble installs).

## The shape

| part | where | why |
|---|---|---|
| island, cards, chat UI, notification presenter | plugin `ewe.companion` (`prj786/ewe-plugin-companion`) | layer-shell stays in the shell (rule 3); extras are plugins ([[Add-ons — opt-in, not preinstalled]]) |
| `ewe-companiond` (Rust): event bus, attention engine, watchers, providers, tools, SQLite store | user unit, started on demand by the plugin | state outlives the shell (rule 11); the ewe-castd pattern |
| `ewe-companion` CLI + agent hook relay + MCP server | `prj786/ewe-companion` | JSON out, exit 0 (rule 5); millisecond hook start |
| the window (Tauri), later | same repo | big, rarely-open UI ([[Process Split — Shell vs Apps]]) |

## What the research decided (2026-10-13, re-verify each release)

- **Claude Code hooks.**
  - `PermissionRequest` answers allow or deny; "Always" goes through Claude's
    own `permission_suggestions` → `updatedPermissions`.
  - `AskUserQuestion` is answered from `PreToolUse` with `updatedInput.answers`.
  - A hook that **prints nothing and exits 0** leaves Claude's own prompt,
    which is the fail-safe.
  - Hooks and the MCP server ship as a Claude Code plugin.
- **Subscriptions.**
  - Allowed: API keys, local models, and ChatGPT via Codex or "Sign in with
    ChatGPT" (a preview).
  - Gray: Claude via the user's own unmodified Claude Code, and Google via
    Antigravity.
  - Not allowed: our own Claude.ai OAuth, or reading anyone's credential
    files.
  - Gemini CLI stopped serving consumer accounts on 2026-06-18.
- **ACP v1** (the `agent-client-protocol` crate) is the clean "use your login"
  lane: each agent logs in by itself.
- **ewe today.**
  - No notification takeover hook, no `notifications` IPC; history lost on
    shell restart; DND in memory only. A core change is needed: Plugin API 4
    with a watchdog.
  - ewe-browser toasts downloads only inside its window.

## Proposed rules (C1–C8; promoted to [[Rules of the House]] when it ships)

1. **C1** It never decides for you: no allow without a click.
2. **C2** It fails back to the old way: daemon or shell down, or locked →
   the terminal asks and stock banners show.
3. **C3** Secrets never reach a model; a canary test guards it. (With Safe,
   2026-10-15: values never cross, names stay local — [[RFC-008 — ewe Safe]]
   S8′; `tests/canary.sh` in P2.9.)
4. **C4** Untrusted text (notifications, pages, agent output) cannot trigger
   tools.
5. **C5** It works with no AI configured.
6. **C6** Attention is a budget: log → glance → peek → card; no modal, no
   focus steal.
7. **C7** It holds no subscription credential.
8. **C8** It uses ewe's pipelines only.

## Owner decisions (2026-10-14, all proposals accepted)

1. Face: eyes only, within the motion tokens.
2. Name: "Companion".
3. Notifications: takeover through Plugin API 4 + the watchdog (P3);
   `replace_banners` off by default.
4. Lanes: API keys, local and ChatGPT on; Claude Code and Antigravity
   opt-in.
5. Rust for the daemon, CLI and relay.
6. T1 desktop actions run with an Undo peek; T2/T3 always ask.
7. kitty remote control: yes (`allow_remote_control socket-only`, P2).
8. Claude Code: a Claude Code plugin; the `settings.json` merge is the
   fallback.
9. Package-cache cleaning through a Komble verb (P5).

## Related

- [[Roadmap — ewe-companion]] · [[Decision Index]] · [[Plugin API 3]] ·
  [[Plugins Unsandboxed]] · [[Security Posture]] · [[One Mark — the line-art logo]]
