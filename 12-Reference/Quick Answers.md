---
tags:
  - ewe-map
  - reference
title: Quick Answers
up: "[[Home]]"
---

# Quick Answers — the 30 most-likely questions

The retrieval entry point: each row is a one-line grounded answer + the
note that has the detail. **If a session answers a question without
checking here, it's probably guessing.**

## Adding / changing things

| question | answer | detail |
|---|---|---|
| How do I add a setting? | Persist through `ewe-conf set`; add the key to `THEME_MAP` or `absorb` drops it | [[The One File]] · [[EWE-CONF Schema Reference]] |
| How do I add a colour/size/duration? | Add a token to the design system first; never a raw literal in QML | [[Theming Pipeline]] · [[Rules of the House]] |
| How do I add a surface to the shell? | Register the component in `qmldir`, instantiate in `ShellRoot`, use Theme/Globals singletons | [[Shell Singletons]] |
| How do I add an app feature UI? | If it's a window, a Tauri app; if it must be layer-shell, the shell | [[Process Split — Shell vs Apps]] |
| How do I add a bar feature? | A plugin (`ewe-plugin create`), bar-widget contract | [[Plugin System]] · [[Plugin Manifest Reference]] |
| How do I add a package to the install? | `packages/common.list` / `aur.list` (short on purpose); phase 20; warn-and-skip | [[Repo Layout]] · [[Development Loops]] |
| How do I add a patched upstream package? | `packages/patched/<name>/` with a header saying why; retires itself | [[Conventions]] |
| How do I add a CLI tool? | `ewe-<noun>`, JSON on stdout, exit 0; website gets `/docs/cli/<tool>` | [[CLI Tools]] · [[Conventions]] |
| How do I add an IPC verb? | `IpcHandler` target; it's public API — don't rename old ones; bind `toggle` not `show` | [[IPC Verb Reference]] |

## Releasing / shipping

| question | answer | detail |
|---|---|---|
| How do I release the DE? | Bump `VERSION` AND `Globals.version` together, `release.sh --publish` | [[Release Checklist]] |
| How do I ship to users? | ewe-repo `publish` workflow LAST, after the app releases | [[Packaging and Updates]] · [[Release Checklist]] |
| How do cross-repo changes merge? | As one wave (the RFC-005 pattern), then publish | [[Roadmap — Distro and Repo]] |
| How does the website update? | Push to main → Pages deploy; re-vendor `tokens.css` if the design changed | [[Website]] · [[Release Checklist]] |

## The one file & sync

| question | answer | detail |
|---|---|---|
| Where does a setting live? | `ewe.conf` — the single source; everything else is generated | [[The One File]] |
| Can I put a secret in ewe.conf? | Never — it syncs to the cloud; keyring only; redesign the feature | [[Rules of the House]] · [[RFC-001 — The One File]] |
| How do sync conflicts resolve? | The server's `If-Match` on the last-seen ETag: 412 = remote newer | [[Account and Sync]] · [[EWE-CONF Schema Reference]] |
| What does the account layout look like remotely? | `ewe/ewe.conf`, `ewe/ewe.conf.meta.json`, `ewe/machines/<name>.json` | [[Contracts and Public API]] |
| Who may sync? | Only ewe-sync (and ewe-conf push/pull underneath) — no other sync buttons | [[RFC-006 — ewe-sync App]] |

## Architecture questions

| question | answer | detail |
|---|---|---|
| Why is Settings a separate process? | Tauri can't do layer-shell; crash isolation for a rarely-open UI | [[ewe-settings]] · [[Process Split — Shell vs Apps]] |
| Why is ewe-castd Python? | Documented RFC-004 deviation; revisit only if profiling demands | [[RFC-004 — ewe-castd, Python not Rust]] |
| Why is there no light mode? | Dark-only by decision; light exists as a scheme for the website | [[Foundation Choices]] · [[Parked and Rejected Ideas]] |
| Why Nextcloud and not Google? | No gatekeeper, right audience, owner out of the loop (RFC-005) | [[RFC-005 — Nextcloud Account]] |
| Why don't plugins get sandboxed? | Impossible in one QML engine; honesty instead | [[Plugins Unsandboxed]] |
| Why no per-package upgrades in Komble? | Arch partial upgrades are unsupported | [[Komble — Arch Forced Decisions]] |
| Why does `monitors.lua` not come from ewe.conf? | Runtime-reactive by design (hotplug/battery) | [[RFC-001 — The One File]] |

## Debugging

| question | answer | detail |
|---|---|---|
| Cast froze / TV dropped / no sound? | The four known classes + `cast-check.sh` | [[Troubleshooting Knowledge]] |
| Settings change did nothing? | Not in `THEME_MAP`, or edited a generated file | [[Troubleshooting Knowledge]] |
| QML surface didn't open? | ~15 KB shot = bar only; read `driver.sh log` | [[Development Loops]] |
| VPN fails to start? | IKEv1 vs strongSwan — libreswan backend | [[Troubleshooting Knowledge]] · [[Phone and VPN]] |
| Screen sharing/file pickers dead? | `hyprland-session.target` missing | [[Security Posture]] |
| Keyring keeps prompting? | `ewe-auth keyring-reset`, then re-login | [[Troubleshooting Knowledge]] |

## Where things live

| question | answer | detail |
|---|---|---|
| Where is this file/what writes it? | The ownership table | [[Contracts and Public API]] · [[Storage Map]] |
| What's the keymap? | The full table | [[Keymap Reference]] |
| What version is everything? | The ledger | [[Version Ledger]] |
| What's decided / parked / open? | Three notes, one table each | [[Decision Index]] · [[Parked and Rejected Ideas]] · [[Open Questions]] |

## Related

- [[00 Onboarding]] · [[Home]] · [[Rules of the House]]
