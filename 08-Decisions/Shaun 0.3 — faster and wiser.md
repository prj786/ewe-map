---
tags:
  - ewe-map
  - decisions
title: Shaun 0.3 — faster and wiser
up: "[[Decision Index]]"
---

# Shaun 0.3 — faster, wiser, and four new groups of functions

**Decided 2026-11-08** (owner: "now work only on shaun. i want it more wise.
smarter and faster. maybe more functions somehow"; the four groups and
"build + PRs, then ask before a release" were the owner's picks). Built in
ewe-companion 0.3 and the plugin `ewe.companion` 0.6.0 (branches
`feat/shaun-wiser`). Decision 54 in [[Decision Index]].

**Measured first, on the owner's laptop** (provider Claude Code, Haiku): "2+2"
took **7.5 s**. `claude -p --system-prompt … --tools ""` still loaded the
owner's own Claude Code setup (plugins, skills, MCP servers: ~94k tokens of
cache creation per question) and spent ~4 s starting. About 30 of 50
everyday phrases missed the offline matcher and went to that call, where the
model guessed the time, memory, CPU and uptime it was never told.

- **Lean:** `--disable-slash-commands --strict-mcp-config --setting-sources ""`
  → ~650 tokens, 5.3 s cold. Not `--bare`: it reads no OAuth, so the user's
  own login (rule C7: the login stays in that app) would stop working.
- **Warm:** one `claude -p --input-format stream-json` waits with its start-up
  done: 1.2 s to the whole answer. It costs ~190 MB, so it starts on the
  **first keystroke** of a question (`chat.warm`) and after an answer — never
  on opening the notch — and is dropped after 3 idle minutes.
- **Streaming:** `chat.reply` `partial` to islands that say they draw it.
- **A stable system prompt** (cached by Anthropic, the key of the warm
  process); the turn's topics, the time, this computer and the memories ride
  with the question in `<notes>`.
- **Wiser:** say the likely cause and the next step; ask one short question
  instead of guessing; facts only from the notes or a **look-up** (reads whose
  results are model-safe, handed back as untrusted, so an ACTION in the
  answer that follows is a button — C4). Up to **three things** per reply,
  one Undo.
- **New functions** (offline, instant): the clock, dates and units; this
  computer's battery, memory, CPU, disk and network; windows and workspaces;
  **memory** — what the user asks Shaun to remember is kept locally
  (`companion.db` `003_memory`, 100 at most) and **sent to the chosen
  provider with each question**: that is its purpose. Anything that looks
  like a secret is refused, and its words stay out of the conversation (C3).
- **Always asks first:** closing a window (a one-time token's button: a
  model can never close one by itself), quitting a program (`pkill`, a
  proposal; never for the desktop's own processes), forgetting everything.

Rejected: warming on every notch open (190 MB for every glance at the
agents); a second "fast" model slot (the warm process made one model fast
enough); currencies and the public IP (both need a website).

Not verified: the window commands on the live Hyprland (close and fullscreen's
Lua arguments come from Hyprland's error strings; tests never touch the live
compositor), a real Claude Code answer streaming in the notch.
