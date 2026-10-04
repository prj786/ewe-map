---
tags:
  - ewe-map
  - how-we-work
title: Testing and QA
up: "[[Home]]"
---

# Testing and QA

There is **no application source to compile and no test suite** for the
shell — "building" means running the installer; "testing" means the
verification commands. But there is a real QA culture; here is the whole of
it.

## CI (ewe repo)

- `shellcheck` (errors) on the installer scripts
- `luac -p` on the Lua config
- a `qmldir` consistency check

## Local pre-PR checklist

- touched the installer → `bash install.sh --dry-run`
- touched `hyprland.lua` → `.claude/skills/run-ewe/driver.sh check`
- touched `dotfiles/quickshell/` → bring the shell up with **no QML errors**
  (driver `up` + `log`)
- touched a shell script → `bash -n <file>`
- anything visible → before/after screenshots (driver PNGs, or real shots)

## The screenshot discipline

- A ~15 KB driver shot = bar only (surface didn't open); ~40–57 KB = real
  window. Read the file size before the pixels.
- Real shots are captured **inside the real DE** with `docs/capture.sh`
  (screenshots live on the website, not in the repo; `docs/media/` is
  gitignored).

## The test scripts that do exist

| what | where |
|---|---|
| plugin seed/install/migrate/remove/keybinds + widget host (61 checks at the 0.25 pre-carve commit) | `ewe/tests/ewe-plugin-test.sh` |
| global shortcuts (portal; `ewe:*` ignored, 12 checks) | `ewe/tests/ewe-globalshortcuts-test.sh` |
| X11 scale at login (9 checks) | `ewe/tests/x11-scale-test.sh` |
| logind bridge (buffered reads, 17 checks) | `ewe/tests/logind-bridge-test.py` |
| shell suite (17) | `ewe/tests/` |
| add-ons' own logic | `test.sh` in `ewe-plugin-{sysmon,cast,phone,mail,dock,passwords}` (sample.sh contract 18 checks; cast scripts vs fake tools; bridge framing; mail compat contract; dock manifest + Rule 8 sweep) |
| every API 3 kind in the harness | `ewe/tests/fixtures/plugins/acme.v3demo` with `HS_PLUGIN_DIRS` |
| the one file: roundtrip + network sync + conflict guard | `ewe/tests/ewe-conf-roundtrip.sh` · `ewe-conf-network-test.sh` · `ewe-conf-sync-test.sh` (fixtures: `mock-nextcloud.py`) |
| auth broker | `ewe/tests/ewe-auth-test.sh` |
| Nextcloud account tool | `ewe/tests/ewe-cloud-test.sh` |
| CalDAV / IMAP | `ewe/tests/ewe-caldav-test.sh` · `ewe-mail-test.sh` (fixture: `mock-imap.py`) |
| theme generator (schemes, imports, guarantees) | `ewe/tests/ewe-theme-test.sh` |
| passwords plugin | its own `test.sh` in the plugin repo |
| cast daemon vs loopback Samsung | `ewe-cast/test/run.sh` + `wfd_sink_sim.py` |
| design tokens hold to source | `ewe/design/check-spec.sh` |
| contrast rules hold | `ewe/design/check-contrast.sh` |
| icons / components | `ewe/design/check-icons.sh`, `check-tokens.sh` |
| vault honesty | `project-map/.vault/vault-check.sh` — links, tags, fences, orphans, `ewe-facts.json` vs repos, diagram renders (also runs in CI) |

## The accessibility audit trail

Every design phase ships `a11y-*` screenshots and contrast runs in
`.wt/shots/<phase>/` (e.g. `a11y-contrast-130.png`). When changing any
surface: re-shoot the a11y set (lock, OSD, player, quick settings, bar,
settings, app store) in dark and light schemes, and run the contrast
check. See [[Worktrees and Screenshots]].

## Field tests (real hardware, pending/ongoing)

- **Cast**: phase C — real Samsung + real Chromecast (see
  [[Roadmap — ewe-cast]]). `sh ~/.config/ewe/plugins/ewe.cast/cast-check.sh`
  verifies the known failure classes.
- **Quiet lid (0.25, A2)**: the nested harness has no lid — the blink /
  hibernate-resleep fixes need the user's laptop: close the lid, wait for
  suspend, open — expect one wake, no blinks, the password field at once;
  then a hibernate resume that stays awake.
- **Add-ons (0.25)**: Komble's Add-ons catalogue and ewe-settings' add-on
  panes are dev-mock tested only — the first real Tauri run is pending;
  real-device check of every add-on on the carved shell (with and without
  the dock) is pending.
- **Hardware matrix**: tested on a QEMU/KVM VM and Intel Lunar Lake
  hardware; real-TV and multi-GPU reports are the scarce resource.
- **Feedback** genuinely helps, especially from real hardware — the README
  asks for it.

## The install verification checklist

Phase 90 (`90-postcheck.sh`) prints a green/red checklist; `install.sh
--check-only` runs just that. A package that isn't in the repos is warned
and skipped — a missing package never blocks the rest (this was the fix for
a "no greeter" failure).

## Related

- [[Development Loops]] · [[Release Checklist]] · [[Design System]] ·
  [[Roadmap — ewe-cast]]
