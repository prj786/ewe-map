---
tags:
  - ewe-map
  - roadmap
title: Roadmap — ewe-companion
up: "[[Home]]"
---

# Roadmap — ewe-companion

Current (2026-10-18): **RFC-007 accepted** (all nine proposals); **P1 done,
P2 working end to end, P2.5 to P2.10 done** (P2.9, Safe, ewe browser and the
finder, merged 2026-10-15: ewe-companion#1, ewe-plugin-companion#1; P2.10,
wave 2, released 2026-10-18 as **0.2.0-beta**: `v0.2.0-beta` on `30eb37f`,
ewe-companion#3, with the island **0.5.0** — ewe-plugin-companion#3 — in
**ewe 0.30.0-beta**, ewe#62).
**First release 2026-10-17** (the owner: "just commit and make new
release"): `ewe-companion` **0.1.0-beta** (`v0.1.0-beta` on `0bf5267`,
ewe-companion#2; the package in `[ewe]` through ewe-repo#4, opt-in) and the
island **0.4.0** (ewe-plugin-companion#2) vendored in **ewe 0.29.0-beta**
(ewe#61). The same round named it **Shaun** (decision 39; ids stay
`companion`) and made the notch the bar's material at last: its blur rule
is `xray` and its fill is clipped at the bar's edge. P7 is open where it
was not done: Komble's `DISCOVER` entry, the website pages, the QEMU e2e
gate. The task lists per
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
| P2.9 ◐ | Safe, ewe browser and the finder (owner 2026-10-15; contract `ewe-safe/docs/TRIO.md` §C1, [[RFC-008 — ewe Safe]] S8′): "copy my GitHub password" (Safe copies; values never cross), lock/unlock/count, "log me in to GitHub" (opens the site; the fill stays a click); search/open/play/history/tabs/"what is this page about?" through ewe browser's CLI (`do browser` in the island; page text untrusted); "find my resume" (the finder: `$HOME` by name, 1.5 s); `rows` on the island; names stay local (`Outcome::private`); proposed commands that print a password manager's values are refused; island 0.3.0 | built; `tests/canary.sh` 8, `tests/chat.sh` 53, relay 26, island harness dark + light — all against fakes (`EWE_COMPANION_SAFE`, `EWE_COMPANION_BROWSER`). Merged 2026-10-15, released in 0.1.0-beta (2026-10-17). Not verified: the real Safe and the real browser CLI (both released 2026-10-15) |
| P2.10 ✓ | more powers, wave 2 (owner 2026-10-18; on ewe browser 0.4.0-beta's CLI): **a site's own search** ("search men's shoes on zara" → `web_search {query, site}` → `search --site`; an unknown site or an older browser → a plain search of "X on Y"); **more browser** — bookmark this page, bookmarks, back/forward/reload/reopen, mute/pin a tab, close a tab (always a proposal), workspaces (switching needs the word "browser"), a site in a named workspace, downloads with Open / Show in folder, the browser's own pages; **the desktop** — Wi-Fi (`nmcli`), Bluetooth and paired devices (`ewe-bt`), airplane mode (Shaun's own: Wi-Fi + Bluetooth off, what was on comes back), keep awake (Insomnia), "install X" opens Komble's search; **a calculator** (offline); **timers and reminders** (`companion.db` migration 002, `notify-send` as Shaun, they survive a restart); **proposals only** for dark/light, power (`power.sh`) and emptying the trash (`commands::PROPOSALS`); the knowledge pack **91 → 122 topics** (new `cli.md`: every ewe command-line tool and the `qs ipc` targets; `browser.md` rewritten for 0.4); island row icons (0.5.0) | released 2026-10-18 in 0.2.0-beta; core 81 + daemon 31 unit, `tests/chat.sh` 112, `tests/canary.sh` 9 — every desktop tool a PATH shim in `tests/fakes/`. Not verified: the real browser 0.4 CLI, `ewe-bt` with a paired device, the Insomnia plugin, a real timer banner (the owner's try after `pacman -Syu`) |
| P3 | notifications: ewe Plugin API 4 + `notifications` IPC + the watchdog; presenter; history; digest; the browser download notification | a broken presenter still gives a stock banner within 1.5 s |
| P4 | the brain: chat; Anthropic / OpenAI / OpenAI-compatible (Gemini, OpenRouter, Ollama, LM Studio); keyring; tool tiers with confirm + undo; redaction | accent change with undo; offline on Ollama; the canary passes |
| P5 | watchers (storage, updates, sync, mail, calendar) + `ewe-companion mcp` | a Claude session asks you through the island |
| P6 | ACP agent lane (codex, opencode, gemini; claude/antigravity opt-in) + the Tauri window | chat on a ChatGPT plan, no token read by ewe |
| P7 ◐ | ship: ~~PKGBUILD + release workflow~~, ~~ewe-repo~~, Komble `DISCOVER`, ~~bundle.json `default:false`~~, website, ~~vault~~ — first release 2026-10-17 | fresh ISO → Komble → approve a Claude prompt (not run) |
| P8 | the password manager's metadata contract — Safe, [[RFC-008 — ewe Safe]] (S8: `summary` + events, never a title or value) | the canary in the vault appears nowhere |

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
- **That blur must be xray.** The bar sits on the wallpaper (its exclusive
  zone keeps windows out); the notch hangs over windows. A plain blur showed
  the window under the notch through the translucent ground, so the notch
  never matched the bar (owner, 2026-10-17: worse in light mode). With
  `xray = true` both blur the wallpaper. And the fill is clipped at the
  bar's edge: under xray any half-covered row over the bar is a seam.
- **API keys never go in plugin settings** (they sync with `ewe.conf`):
  the notch takes the key and the daemon stores it in the keyring.
- **The conversation is model context.** Anything that shows Safe's names
  sets `Outcome::private` (the conversation keeps "done" or a count);
  `tests/canary.sh` fails otherwise.
- **An app a daemon starts dies with the daemon's unit.** ewe browser
  started from `ewe-companiond` joins its cgroup: acts go through the island
  (`do browser`); reads stay in the daemon.
- **ewe browser 0.1.0-beta has no command line** — its `ewe-browser` is the
  Electron binary, so a verb opens as a page. `browser::cli()` asks only a
  `#!` script (0.2.0-beta's `/usr/bin/ewe-browser` is one).
- **Tests never reach the real Safe or browser:** `tests/fakes/` through
  `EWE_COMPANION_SAFE` / `EWE_COMPANION_BROWSER`.
- **…nor the real switches** (P2.10): Wi-Fi, Bluetooth, Insomnia, the
  theme, the trash and timer notifications go through tools on `PATH`;
  `tests/chat.sh`, `tests/canary.sh` and `tests/island.sh` put
  `tests/fakes` first and refuse to run otherwise. A daemon started by hand
  has the real ones — never type "wifi off" into it.
- **A store guard lives to the end of its statement.**
  `hub.store().list().into_iter().filter(|t| hub.store().remove(..))`
  locks the store twice on one thread: the timer scheduler deadlocked the
  daemon the first time a timer fired. Take the list into a `let` first.
- **ewe browser 0.4's new acts run by their documented argv**
  (`workspace activate <name>`, `back`, `download show <id>`); `search`'s
  `site` and `open`'s `workspace` are JSON arguments, used only when
  `commands`' schema names them. If the browser's CLI changes, the fake and
  `browser.rs` change together.
- More in [[Troubleshooting Knowledge]] → *The companion*.

> **Build guard:** never call `hub.store()` twice in one statement (bind the
> first result with `let`); `run_shell`, `theme_mode`, `power` and
> `empty_trash` stay in `commands::PROPOSALS` (a reply with `confirm`, run
> only by the click); tab, bookmark, download, workspace and device names
> stay `private`. *Breaks if violated:* the daemon deadlocks when a timer
> fires; the matcher restarts the machine from a sentence; names reach a
> model (`tests/canary.sh` fails).

## Related

- [[RFC-007 — ewe Companion]] · [[Roadmap and Status]] · [[Open Questions]]
