---
tags:
  - ewe-map
  - decisions
title: Knowledge 2.0 — Shaun follows ewe
up: "[[Decision Index]]"
---

# Knowledge 2.0 — Shaun follows ewe, and knows more than ewe

**Decided 2026-11-21** (owner: "make shaun more powerfull. we can add
knowledge."; Phase S of the wave "every format, every language, a wiser
Shaun, a new installer"). Built on `feat/shaun-knowledge` (on top of
`feat/shaun-wiser`) in ewe-companion and the plugin. **Released
2026-11-21** together with 0.3's speed and functions (decision 54,
[[Shaun 0.3 — faster and wiser]]) as **ewe-companion 0.3.0-beta**
(ewe-companion#9) and the island **`ewe.companion` 0.7.0**
(ewe-plugin-companion#7, `d78fa46`), vendored in **ewe 0.47.0-beta**
(ewe#89). Decision 71 in [[Decision Index]]. Code: `ewe-companion`
`knowledge/`, `scripts/coverage.py`, `scripts/news.sh`,
`crates/core/src/{knowledge,wiki,media,lang}.rs`,
`crates/daemon/src/{notes,lookup,media}.rs`; map: ewe-companion
`AGENTS.md`, `docs/PLAN.md` §20 P2.12.

**Why.** The pack had 128 topics, last refreshed around ewe 0.39–0.42. It
knew nothing about ewe Files, Player and Viewer, the bar's fold, the dock's
displays, display workspaces, codecs or Stremio. A pack that someone has to
remember to update goes stale. And with no AI picked, Shaun knew only ewe.

## What was decided

- **A coverage test fails the build.** `knowledge/coverage.json` lists
  everything ewe ships that Shaun must have a topic for: 72 items (19 ewe
  Settings pages, 26 command-line tools, 10 apps, 17 built-in plugins).
  `scripts/coverage.py` writes it from the repos (ewe-settings
  `src/lib/pages.js`; ewe `bin/*`, `packaging/ewe-setup`,
  `plugins/bundle.json` + manifests) and from this vault's `ewe-facts.json`
  (`cli_tools`, `repos`). The unit test `every_shipped_feature_has_a_topic`
  fails `cargo test` (CI and the package's `check()`) until every item has
  a topic whose title or keys name it. The list does not regenerate itself:
  a new Settings page, `ewe-*` tool, app or built-in plugin means re-running
  the script (`--check` says the file is out of date). After that, a missing
  topic is a red build instead of a quiet gap.
- **Release notes in the pack.** `knowledge/news.md` has one topic per minor
  release ("What's new in ewe X.Y", 0.38 to 0.47). The topics are written by
  hand on purpose: release notes are for developers, a news topic is for the
  user. `whats_new` (a look) picks the topic for the installed ewe
  (`/usr/share/ewe/VERSION`) and lists the earlier ones as rows.
  `scripts/news.sh` (`gh`) lists the releases that still need a topic. An ewe
  release needs a news topic in the same wave.
- **The ArchWiki offline, through `arch-wiki-lite`, now a dependency**
  (`depends=('gcc-libs' 'glibc' 'arch-wiki-lite')`, 21 MB). `wiki` (a look)
  runs `wiki-search`. It shows the best page by title and the section that
  fits (700 characters shown, 1,800 sent to a model), with *Open the page*
  (local HTML with the optional `arch-wiki-docs`, else wiki.archlinux.org).
  With no model, a question that is a page's title gets that page. About
  0.7 s per look-up against the real package. Manuals come the same way:
  `man_page` uses `man`, else `<program> --help` unless the program is on
  the `lookup::NO_HELP` deny list (`man-db` is an optdepend). Offline
  answers are rule C5: Shaun works with no AI.
- **The user's notes in `~/Documents/Shaun`** (`EWE_COMPANION_NOTES`
  overrides it). Markdown and text files, two folders deep, at most 200
  files of 64 KiB each, are searched with the same index as the pack. The
  index is rebuilt when a file changes. A note that fits the question goes
  to the model with it, like any topic. A paragraph that `looks_secret`
  (a password, PIN, key or card number) is left out of the index, and
  "learn this: …" refuses to write one. "Learn this: …" and "remember for
  later: …" write a note (`learn`, Undo deletes it while it still holds what
  was written); `notes` lists or searches them. They are plain files the user
  owns. Shaun syncs nothing; syncing that folder is the user's choice in ewe
  Sync. Notes are documents, sent only when they fit the question. Memories
  (decision 54) are short facts in `companion.db`, sent with every question.
- **Settings by text are proposals with Undo.** `dock_display`
  (`ewe-plugin set ewe.dock display primary|all|none`), `bar_fold`
  (`ewe-conf set desktop.bar.collapse true|false`) and dark/light
  (`theme_mode`, `ewe-theme scheme apply …`) are in `commands::PROPOSALS`.
  The reply shows the exact command with Run, and nothing changes before
  that click. After it, the reply offers **Undo**
  (`Outcome::propose_undo` → `Undo::Shell`). The daemon builds the Undo
  from the value it read first, never from a model. Writes go through ewe's
  own writers (rule 1, C8). Settings are tier T2 in the owner's decision 6:
  always ask first.

Shipped with it: BM25F search over keys, title and text (synonyms, typos
from six letters, a key phrase said whole is still a confident match),
answers in the question's language when a model answers, music from the
library and links in ewe Player, "why won't this play" (ffprobe,
`gst-inspect-1.0`, `yt-dlp -J`), keyboard layouts and `ewe-ime`, "translate
this" (a model, the clipboard as untrusted), and plocate in the finder. The
island's **`do app`** (plugin 0.7.0) starts `ewe-player`, `ewe-files-app` or
`ewe-viewer` with arguments, and answers are drawn as plain text. The pack
went from 128 to 174 topics in 11 files. Contracts: [[Contracts and Public API]].

Changed from the wave plan: news topics are written by hand, not generated
from release notes. Night light by text was not built.

Tests: core 128, daemon 67, `tests/chat.sh` 213, `tests/brain.sh` 28,
`tests/canary.sh` 10, relay 26. The island harness was run dark and light
at 1.8. **Not verified:** the real ewe Player playing a link, ewe Files
`--select=` and the real `ewe-ime` on a desktop (only fakes so far); Vimeo
is said to be locked rather than tried.

> **Build guard:** re-run `scripts/coverage.py` when ewe gains a Settings
> page, `ewe-*` tool, app or built-in plugin, and write the topic. Never
> drop an item from `coverage.json` to turn the test green. Keep
> `arch-wiki-lite` in `depends`. Keep `dock_display`, `bar_fold` and
> `theme_mode` in `commands::PROPOSALS`. Notes and memories pass
> `memory::looks_secret`. *Breaks if violated:* the pack goes stale
> without anyone noticing; "wiki …" fails offline; a sentence changes the
> desktop without a click; a PIN in a note reaches a model.

## Related

- [[RFC-007 — ewe Companion]] · [[Roadmap — ewe-companion]] ·
  [[Shaun 0.3 — faster and wiser]] · [[The Bar's Fold]] ·
  [[Dock On Every Display]] · [[ewe Player Plays Links — yt-dlp]] ·
  [[Typing in Other Languages — fcitx5 on demand]]
