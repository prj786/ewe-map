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
| How do I add a bar feature? | A plugin (`ewe-plugin create`), bar-widget or bar-status contract | [[Plugin System]] · [[Plugin Manifest Reference]] |
| How do I add a shell feature at all (0.25)? | If it isn't bar/launcher/Overview/QS basics/notifications/lock/OSD/polkit/Welcome, it's a **first-party plugin**: own repo `ewe-plugin-<name>`, API 3, vendored into `plugins/`, `bundle.json` `default:false` | [[Add-ons — opt-in, not preinstalled]] · [[Plugin API 3]] |
| Where does a plugin's setting go (dock size, mail notifications, …)? | In the plugin's manifest `settings` → Komble → Plugins → Options; **never ewe-settings**. Moving one out: `legacy: "<old.key>"` | [[Plugin Settings Live With the Plugin]] · [[Plugin Manifest Reference]] |
| "Add-on" or "plugin"? | **Plugin**, everywhere user-facing ("first-party plugin" when it matters); contracts like `komble --addons` keep their names | [[One Name — Plugins]] |
| How do I add a Quick settings tile or page? | `quick-tile` / `quick-page` kinds (API 3); the page key must not be `home wifi bt audio cal notifs` | [[Plugin Manifest Reference]] |
| How does a plugin talk to the shell? | The `Shell` singleton (toast, openQuickSettings, actions, bottomInset, anchorFor) — not `Globals` internals | [[Plugin API 3]] · [[Contracts and Public API]] |
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
| How do I ship a plugin fix? | Fix in `ewe-plugin-<name>`, bump its manifest version, re-run `scripts/vendor-plugins.sh` in ewe (updates `bundle.json`), release ewe | [[One repo per add-on]] · [[Add-ons — vendored payload and bundle.json]] |
| How do I install the system side after `pacman -S ewe`? | `bash /usr/share/ewe/install.sh --no-packages` **as your user** — never `sudo` (exit 2) | [[Install Flow]] · [[Packaging and Updates]] |

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
| Cast froze / TV dropped / no sound? | The known classes + `sh ~/.config/ewe/plugins/ewe.cast/cast-check.sh`; portal must be ≥ 1.4.1-2.1 | [[Troubleshooting Knowledge]] · [[Cast Plugin]] |
| **Why did my dock disappear on a fresh install?** | It isn't a bug: since 0.25 the dock is a plugin and a fresh ewe installs none. Komble → Plugins → Dock, or `ewe-plugin install ewe.dock` | [[Dock Plugin]] · [[Add-ons — opt-in, not preinstalled]] |
| **Where are the dock's settings?** | Komble → Plugins → Dock → **Options** (auto-hide, icon size), or `ewe-plugin set ewe.dock icon_size small`; Settings → Layout → "Dock options" opens it. Old `[desktop.dock]` values carry over | [[Dock Plugin]] · [[Plugin Settings Live With the Plugin]] |
| How do I hide a plugin from the bar? | Komble → its Options → *Show in bar*, or `ewe-plugin bar <id> off` (Music/Places: their own "Where the button lives") | [[Plugin Settings Live With the Plugin]] |
| How do I pin a desktop widget above my apps? | Point at it → the pin in its corner; *When pinned* (Options) picks above windows or above everything; drag by the grip or the card; *Lock position* stops dragging | [[Desktop Widgets — always movable, pin to a level]] |
| **Sync: "another machine (named like this one) saved newer settings", Push does nothing?** | A lost upload reply left the record on an old ETag (fixed, D12); once: ewe-sync → This machine → *Push anyway* (or Restore); give each machine its own hostname | [[Sync Conflicts Are About Content]] · [[Troubleshooting Knowledge]] |
| Settings says "the shell isn't running" but it is? | It asked once, at open, during a restart; it now re-asks on focus/every 10 s | [[ewe-settings]] · [[Troubleshooting Knowledge]] |
| Glass looks wrong (Overview faint, dock darker, windows blurred)? | Fixed: the bar opacity slider moves only bar/dock/lock card; no xray; no app blur unless asked | [[Glass — the slider moves the bar only]] |
| **How do I get the dock back** (upgrade lost it / I removed it)? | `ewe-plugin install ewe.dock` (forgets the removal); an upgrade keeps it via `migrate` unless `[desktop.dock] enabled = false` | [[Dock Plugin]] · [[Add-ons — one-time migration for upgraders]] |
| **How do I re-add a removed plugin** (clipboard, screenshot, passwords, …)? | Komble → Plugins, or `ewe-plugin install <id>` — **not** `add <github-url>` (failed for reserved ids before 0.25; an alias of `install` now) | [[Plugin System]] |
| Where did Cast / Mail / Phone / VPN / SSH / Places / music / keep-awake go? | They are plugins (`ewe.cast ewe.mail ewe.phone ewe.vpn ewe.ssh ewe.places ewe.media ewe.insomnia`); legacy IPC targets and QS keys still work once installed | [[Plugin System]] · [[IPC Verb Reference]] |
| Lid-open blinks before the password / machine re-sleeps after hibernate? | Fixed 0.25 (A2): guarded `after_sleep_cmd`, per-output re-assert, `probeLid()` | [[Quiet Lid — touch only a disabled panel]] · [[Troubleshooting Knowledge]] |
| Steam / Java huge on the external monitor? | X11 has one scale; since 0.25 it is the smallest lit scale of the connected set (re-login after docking) | [[X11 Scale — smallest lit scale]] |
| `ewe-plugin` from a test touched my live Hyprland? | Unset `HYPRLAND_INSTANCE_SIGNATURE` and `WAYLAND_DISPLAY` before calling it (`--no-restart` is not enough) | [[Troubleshooting Knowledge]] |
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
