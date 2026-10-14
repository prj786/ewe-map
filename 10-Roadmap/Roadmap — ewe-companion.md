---
tags:
  - ewe-map
  - roadmap
title: Roadmap — ewe-companion
up: "[[Home]]"
---

# Roadmap — ewe-companion

Current (2026-10-14): **RFC-007 accepted** (all nine proposals); **P1 done,
P2 working end to end, P2.5 to P2.8 done** against a real Claude Code 2.1.296 session. Both repos
are on GitHub since 2026-10-14 (`prj786/ewe-companion`,
`prj786/ewe-plugin-companion`; not yet released or in ewe-repo). The task lists per
phase live in `ewe-companion/docs/PLAN.md` §20, and what building taught us in
§25.

| # | what | gate |
|---|---|---|
| P0 | ~~owner decisions~~ (done 2026-10-14); `design-mockups/companion.html` on v3 tokens; Island + CompanionCard design cards | the owner signs off the look (screens from the nested harness exist) |
| P1 ✓ | repos, Rust workspace, daemon + socket + SQLite, CLI `status`/`say`; the island idle + peek; a `companion` domain in `ewe-conf` | passed 2026-10-14: peek in the nested smoke; shell restart keeps the waiting card; idle CPU 0 |
| P2 ◐ | Claude Code: relay, plugin install, permission and question cards, finished/idle peeks, jump to terminal, plan-usage pill | relay suite 26/26; a real `PermissionRequest` approved end to end (click stood in by `debug answer`); jump verified. Left: the owner's real click, drop keyboard, settings.json fallback, usage pill |
| P2.5 ✓ | the notch under the bar (owner's pick), the indicator (state, count, activity, plan usage), the contextual home panel, quick actions, now playing, the chat: a 14-command catalog, an offline matcher, provider lanes (own login: claude-code/codex/opencode; keys: anthropic/openai/gemini/openrouter; local: ollama/lmstudio/custom), keys in the keyring | owner's second try, 2026-10-14; `tests/chat.sh` 7/7 |
| P2.6 ✓ | the owner's six fixes: the notch hides when nothing runs, keeps one size (nothing follows the pointer), opens without the stretch blink, has smooth curve-rendered fillets, a short placeholder; and the **knowledge pack** (`ewe-companion/knowledge/*.md`, built into the binary): a primer every question carries, 70 topics found by word match, a live snapshot of this machine, offline answers with an "Open …" button, `open` with Settings/Komble/Quick settings pages | owner's third try, 2026-10-14; `tests/chat.sh` 10/10, knowledge tests in core |
| P2.7 ✓ | apps and folders: `launch_app {app, path?}` / `open_folder {path}`; "open nemo", "open kitty in documents", "open documents in nemo", "open zed in ewe-companion"; folders found by the daemon (XDG names, paths, a folder's name under home), apps by the shell's desktop index; a miss falls through to the knowledge pack and the model | `tests/chat.sh` 12/12; launches checked in the nested harness |
| P2.8 ✓ | the companion runs what it suggests: `run_shell` proposals (a model's, a knowledge topic's `run:`, the user's `$ command`) shown exactly with Run / In terminal, run only on that click; `shell::assess` refuses machine killers and house-rule breaks, warns on risky ones, sends sudo to a terminal | `tests/chat.sh` 21/21; Run and In terminal checked in the nested harness |
| P3 | notifications: ewe Plugin API 4 + `notifications` IPC + the watchdog; presenter; history; digest; the browser download notification | a broken presenter still gives a stock banner within 1.5 s |
| P4 | the brain: chat; Anthropic / OpenAI / OpenAI-compatible (Gemini, OpenRouter, Ollama, LM Studio); keyring; tool tiers with confirm + undo; redaction | accent change with undo; offline on Ollama; the canary passes |
| P5 | watchers (storage, updates, sync, mail, calendar) + `ewe-companion mcp` | a Claude session asks you through the island |
| P6 | ACP agent lane (codex, opencode, gemini; claude/antigravity opt-in) + the Tauri window | chat on a ChatGPT plan, no token read by ewe |
| P7 | ship: PKGBUILD, ewe-repo, Komble, bundle.json `default:false`, website, vault | fresh ISO → Komble → approve a Claude prompt |
| P8 | the password manager's metadata contract (when it exists) | the canary in the vault appears nowhere |

## Gotchas known before the first line

- **An unknown `ewe.conf` section triggers a full apply.** `ewe-conf set
  companion.*` regenerates everything and reloads Hyprland until a
  `companion` `_domain` exists (`bin/ewe-conf` `_domain`). Fix that first.
- **The watchdog must not use a motion token.** `durDim` and the other motion
  tokens fold to 0 when animations are off.
- **Never test hooks against the owner's real `~/.claude`.** Use a scratch
  project (hooks in its `.claude/settings.local.json`).
- **Bypass mode asks nothing.** The owner's `defaultMode` is
  `bypassPermissions`: no `PermissionRequest`, so no permission cards.
- **Hyprland 0.56 focuses by address in Lua** (`hl.dsp.focus`), and kitty's
  remote-control socket must be a file, not an abstract `@` socket.
- **The shell's `InvertedCorner` paints nothing**, and a Canvas fillet looks
  pixelated at fractional scale (1.8 on the owner's laptop): the notch is one
  `Shape` with `CurveRenderer` (ground + rule in one path) since P2.6.
- **A layer surface must not grow while it shows something.** Hyprland
  stretches the old buffer to the new size until the next frame lands: the
  opening blink of P2.5. The notch window takes its full size while empty,
  then the notch comes out; it shrinks only after the notch has gone in.
- **A Hyprland focus grab dies when an exclusive layer takes the keyboard.**
  Start `HyprlandFocusGrab` a beat (durFast) after `keyboardFocus` turns
  Exclusive, or it is cleared at once.
- **Single-instance apps open in the running instance.** `zed <path>`,
  browsers and the like hand the path to an instance that is already up,
  wherever it runs. In the nested harness that means the app may appear in
  no nested window (Zed's app process also dies in the sandbox HOME).
- **A Qt Column skips a child of zero width or height.** An empty
  `TextCaption` is zero wide, so a "fixed" hint slot vanished until a hover
  gave it text, and the notch grew on every hover (owner, 2026-10-14). Give
  reserved slots an explicit width. The nested harness has no pointer, so
  hover never shows there: `ewe-companion/tests/vptr.py` (a
  zwlr_virtual_pointer client, stdlib only) gives it a mouse.
- **A proposed command never runs without its click.** `commands::run`
  refuses `run_shell`; only `confirm.run` (a token, once) runs it. Keep it
  that way: no "auto-run safe commands" shortcut. A timed-out run kills its
  whole process group (`process_group(0)`), not just bash.
- **The knowledge pack is user-facing text about ewe.** When a Settings page,
  a Komble page, a keybind or a label changes, update `ewe-companion/knowledge/`
  in the same change (its tests check every `open:` line). Settings 0.18
  ignores `--page`, so answers name the page to pick.
- **Glass needs blur behind the notch.** ewe blurs only `quickshell:(bar|dock)`;
  the plugin adds a runtime layer rule for `quickshell:companion` (and again
  after every config reload). Without it the notch looked like clear glass.
- **API keys never go in plugin settings** (they sync with `ewe.conf`):
  the notch takes the key and the daemon stores it in the keyring.
- More in [[Troubleshooting Knowledge]] → *The companion*.

## Related

- [[RFC-007 — ewe Companion]] · [[Roadmap and Status]] · [[Open Questions]]
