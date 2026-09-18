# ewe — the build guide (an Obsidian vault)

This folder is an **Obsidian vault** that serves as the durable memory and
**build guide for ewe OS**: the map of what exists, the record of every
decision and why, the rules that must not be broken, and the plan for
what's next. Written so a future session (human or AI) picks up the project
**without being mistaken about anything that matters**.

## How to open it

1. Install [Obsidian](https://obsidian.md)
2. **Open folder as vault** → pick `ewe/project-map/`
3. Start at [[Home]] — or `Ctrl+G` for the graph view.

Everything also reads as plain markdown on GitHub; only the double-bracket
wikilinks and Mermaid rendering need Obsidian.

## If you're here to work on ewe

Start at [[00 Onboarding]] — it's written to you. Then:

- [[Rules of the House]] — the invariants; each lists what breaks if violated
- [[Decision Index]] — everything already decided, with rationale
- [[Roadmap and Status]] + `10-Roadmap/` — what's next
- [[Development Loops]] — how to build/test safely

## Tooling around the vault

| tool | what |
|---|---|
| `AGENTS.md` (workspace root) | auto-loaded by AI agents — points every session at the vault and its rules |
| `.vault/vault-check.sh` | one command: wikilinks · tags · fences · orphans · facts · diagrams. `--diagrams` renders every Mermaid block; `--render-svg` also exports them |
| `ewe-facts.json` | machine-readable mirror of the contracts (versions, rules, IPC, schema, repos) — validated against the repos by vault-check |
| `attachments/diagrams/` | committed SVG renders of every diagram (GitHub previews) |
| `quartz-config/` + `.github/workflows/` | CI publishes this vault as a website (Quartz + GitHub Pages → `prj786.github.io/ewe-map/`) |
| Skills (`.opencode/skills/` in the workspace) | `ewe-smoke` (test the desktop), `ewe-release` (the release runbook), `ewe-diag` (gather failure evidence) |

## Layout

| folder | what |
|---|---|
| [[Home]] | the hub — big picture + index of everything |
| [[00 Onboarding]] | **read first** — the 10 rules, reading order, update discipline |
| `01-Overview/` | what ewe is, the repo inventory, roadmap/status, glossary |
| `02-Architecture/` | how the system fits together (one file, sync, packaging, shell) |
| `03-Components/` | one note per repo/app |
| `04-Plugins/` | the plugin system + the shipped plugins |
| `05-Workflows/` | end-to-end flows: install, update, cast, sync, settings |
| `06-Design/` | the design system + mockups, with screenshots |
| `07-Development/` | repo internals, CLI tools, dev worktrees |
| `08-Decisions/` | ADR-style rationale — **why** things are the way they are |
| `09-Rules/` | the contracts: rules of the house, files, IPC, public API |
| `10-Roadmap/` | per-component next steps + open questions |
| `11-How-We-Work/` | dev loops, testing/QA, releases, conventions |
| `12-Reference/` | the sheets: IPC verbs, ewe.conf schema, keymap, manifest, storage, versions |
| `attachments/` | screenshots copied from `.wt/shots/` |

## Conventions

- **Double brackets** → link to another note in this vault.
- **`code`** → a CLI tool, file path, or IPC verb.- **"Build guard"** boxes in notes → the one-line rule that prevents the
  classic mistake for that area.
- Frontmatter carries `tags` + `up:` links so the graph view clusters.

## Source of truth

The repos are the territory; this vault is the map — distilled from
READMEs, RFCs (`ewe/docs/RFC-0NN-*.md`), `CLAUDE.md` and code. When you
change reality, update the vault in the same change (see
[[00 Onboarding]] → update discipline).
