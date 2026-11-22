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
| How does a new computer get everything back? | Sign in; ewe-sync's Overview shows **Welcome back** (what comes back) → *Bring everything back*: the one file, the folders (shared list), the browser (follows the account), Safe | [[Sync — sign in once, everything follows]] |
| Which folders are synced, and by what? | `~/.local/state/ewe/sync-folders.json` (or `ewe-sync --status`) — every engine, including the Nextcloud desktop app's folders | [[Contracts and Public API]] |
| Who may sync? | Only ewe-sync (and ewe-conf push/pull underneath) — no other sync buttons | [[RFC-006 — ewe-sync App]] |

## Architecture questions

| question | answer | detail |
|---|---|---|
| Why is Settings a separate process? | Tauri can't do layer-shell; crash isolation for a rarely-open UI | [[ewe-settings]] · [[Process Split — Shell vs Apps]] |
| Why is ewe-castd Python? | Documented RFC-004 deviation; revisit only if profiling demands | [[RFC-004 — ewe-castd, Python not Rust]] |
| Is there a light mode? | Yes, since 2026-10-14: Settings → Appearance → Scheme → Ewe Light (or an imported light scheme, or From wallpaper (light)). Dark is the default; the lock screen stays dark | [[Foundation Choices]] |
| Why Nextcloud and not Google? | No gatekeeper, right audience, owner out of the loop (RFC-005) | [[RFC-005 — Nextcloud Account]] |
| Why don't plugins get sandboxed? | Impossible in one QML engine; honesty instead | [[Plugins Unsandboxed]] |
| Why no per-package upgrades in Komble? | Arch partial upgrades are unsupported | [[Komble — Arch Forced Decisions]] |
| Why does `monitors.lua` not come from ewe.conf? | Runtime-reactive by design (hotplug/battery) | [[RFC-001 — The One File]] |

## Debugging

| question | answer | detail |
|---|---|---|
| Cast froze / TV dropped / no sound? | The known classes + `sh ~/.config/ewe/plugins/ewe.cast/cast-check.sh`; portal must be ≥ 1.4.1-2.1 | [[Troubleshooting Knowledge]] · [[Cast Plugin]] |
| A file dialog looks like GTK, or opens behind the app? | Since 0.48 every app's Open/Save/Open with is ewe's picker on an overlay layer; a GTK one means the shell couldn't answer (one-off fallback), the app draws its own (GIMP, JetBrains, Steam, Wine), or routing is off — `ewe-portal status` (`routing.ewe`) | [[RFC-011 — One File Picker]] · [[Troubleshooting Knowledge]] |
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
| **Super+P says "make sure 1Password CLI is installed"?** | The Passwords plugin's `provider` is still `1password`. `ewe-plugin set ewe.passwords provider ewe` (or `auto`). Since ewe 0.28.0-beta (Passwords 1.3.0) that error row offers **Use Safe** | [[Passwords Plugin]] · [[Troubleshooting Knowledge]] |
| How do I change a plugin setting from a terminal? | `ewe-plugin set <id> <key> <value>` — not `ewe-conf set plugins.settings."<id>".<key>` (wrote a stray table before ewe 0.28.0-beta, ewe#58) | [[EWE-CONF Schema Reference]] |
| Can Safe do passkeys, SSH keys, `op read`? | Yes, since **Safe 0.2.0-beta** (2026-10-15) — passkeys (KeePassXC format, through ewe browser 0.2.0-beta), an SSH agent (`ewe-safe ssh enable`), `ewe-safe read/run/inject/git-credential`. After upgrading: `systemctl --user daemon-reload && systemctl --user restart ewe-safe.socket` | [[ewe-safe]] · [[RFC-008 — ewe Safe]] |
| My 1Password / Bitwarden extension is "off" in ewe browser? Ctrl+Shift+L opens Safe? | By design since **ewe browser 0.4.0-beta**: the browser fills with Safe only, and known password-manager extensions are refused before they load. `Super+P` on the desktop still uses `ewe-pass` | [[Browser Passwords — Safe only]] |
| A site can't use the camera / send notifications in ewe browser? | Since 0.4.0-beta sites ask per site (a card at the page's top left); a decision is changed from the lock in the address field or Settings → Privacy and security. Location never works (no provider in Electron on Linux) | [[Site Permissions — ask per site]] |
| Four fingers do nothing? | They act only while ewe browser is focused (its workspaces; ewe 0.30.0-beta + ewe browser 0.4.0-beta); three fingers are the desktop's | [[Four Fingers — ewe browser's workspaces]] · [[Keymap Reference]] |
| **A video link won't play in ewe Player** (YouTube, a news site …)? | From ewe-apps 0.2 (released 2026-11-21) the Player plays page links through yt-dlp (`ewe-player <url>`, Ctrl+L, ewe Browser's *Play in ewe Player*); its error page names the real cause — not a video page, DRM, yt-dlp's own message, a broken connection — and offers Open in ewe Browser / Open in mpv. Before 0.2 every link failed with a false "install gst-libav" | [[ewe Player Plays Links — yt-dlp]] · [[Troubleshooting Knowledge]] |
| **Stremio doesn't play** anything? | Stremio Enhanced needs Stremio's streaming server and looks for it as a Flatpak; Komble 0.24 (built): its page → *Get the streaming server*, restart it — or install **Stremio** (`stremio-linux-shell`, server inside) from Popular → Media | [[What an Installed App Still Needs]] |
| Subtitles show as gibberish (Cyrillic, Arabic, Chinese …)? | ewe-apps 0.2 (built) guesses the encoding (chardetng); a wrong guess → the subtitle menu's *Subtitle encoding* | [[Every Script Reads Right — encodings, phone pictures, right-to-left]] |
| Settings change did nothing? | Not in `THEME_MAP`, or edited a generated file | [[Troubleshooting Knowledge]] |
| QML surface didn't open? | ~15 KB shot = bar only; read `driver.sh log` | [[Development Loops]] |
| VPN fails to start? | IKEv1 vs strongSwan — libreswan backend | [[Troubleshooting Knowledge]] · [[Phone and VPN]] |
| Screen sharing/file pickers dead? | `hyprland-session.target` missing | [[Security Posture]] |
| Keyring keeps prompting? | `ewe-auth keyring-reset`, then re-login | [[Troubleshooting Knowledge]] |

## Shaun (the companion)

| question | answer | detail |
|---|---|---|
| **What can Shaun do?** | With no AI (0.3.0-beta, ewe 0.47): the desktop's switches with Undo (volume, Wi-Fi, Bluetooth, Do not disturb, game mode), apps and folders, files by name (plocate too), ewe Safe ("copy my GitHub password": Safe copies, Shaun never sees it), ewe Browser, timers and sums, the clock and units, this computer's battery/memory/CPU/disk/network, windows and workspaces, memories, music and links in ewe Player, "why won't this play", keyboard layouts, "what's new", the ArchWiki and manuals offline, answers about ewe from the pack. Settings (dark/light, the dock's displays, the bar's fold, power, the trash) are offered with Run, then Undo. With an AI picked (your own Claude Code/Codex/OpenCode login, an API key, a local model): any question, in your language, after a look-up when it depends on this computer; up to three things per reply; "translate this" | [[Roadmap — ewe-companion]] · [[Shaun 0.3 — faster and wiser]] · [[Knowledge 2.0 — Shaun follows ewe]] |
| **How do I teach Shaun something?** | Put Markdown or text files in `~/Documents/Shaun` (two folders deep), or say "learn this: …" / "remember for later: …" (Undo deletes the note). Shaun searches them like its own pack, offline; a note that fits the question goes to the AI with it. Short facts: "remember that …" (memories, 100 at most, sent with every question; "forget …"). Passwords, PINs, keys and card numbers are refused and left out. For ewe itself, a topic in `ewe-companion/knowledge/*.md` (the coverage test fails until every shipped feature has one) | [[Knowledge 2.0 — Shaun follows ewe]] · [[Storage Map]] |

## Where things live

| question | answer | detail |
|---|---|---|
| Where is this file/what writes it? | The ownership table | [[Contracts and Public API]] · [[Storage Map]] |
| **Which file manager / player / viewer does ewe ship?** (0.44) | ewe's own: ewe Files (`ewe-files-app`), ewe Player (`ewe-player`), ewe Viewer (`ewe-viewer`) from the `ewe-apps` package — Nemo, Engrampa, imv, Zathura and mpv are gone from the lists; after upgrading remove them once (`sudo pacman -Rns nemo engrampa imv zathura zathura-pdf-mupdf mpv-mpris mpv-uosc-git`; mpv stays for mpvpaper) | [[ewe-apps]] · [[ewe's Own Apps — Files, Player, Viewer]] |
| **Why does a fresh install pull `nvidia-utils`?** | It did until 0.44: zed's `vulkan-driver` virtual, claimed by the first provider — now `vulkan-swrast` is pinned first and the publish gate blacklists it | [[The Package Diet]] |
| **Does ewe see my Nextcloud password?** | Since 0.44, once: typed in ewe Sync or the installer, sent over https to the typed server only (OCS `getapppassword`), never kept — the browser flow (Login Flow v2) stays for 2FA/SSO | [[Password Sign-in — a reversal]] |
| **How do I type Chinese, Japanese, Korean, Vietnamese, Hindi …?** | ewe 0.46 + ewe Settings 0.26 (released 2026-11-21): Settings → Keyboard and mouse → **Typing in other languages** → Add (installs fcitx5 + the engine, one password prompt; never shipped by default). **Ctrl+Space** toggles the language, **Super+Space** still switches layouts; the bar shows 拼 あ 한. `ewe-ime status`; `[desktop.ime]` in ewe.conf | [[Typing in Other Languages — fcitx5 on demand]] · [[Keymap Reference]] |
| **Spell checking — where and which languages?** | `hunspell` + US English ship (0.46, built); Settings → Language → **Spell checking** adds dictionaries (AUR-only ones via Komble) and writes `[desktop.language] spellcheck` / `check_spelling`. ewe Browser follows it with Chromium's own dictionaries — Georgian and a few others aren't checked there | [[Spell Checking — hunspell and Chromium]] |
| Where are the display language and the date/number formats? | The machine's locale (LANG, LC_*), never ewe.conf: Settings → Language (display) and Time and place → **Formats** (0.26, built); applies after sign-out | [[Language Lives in Two Places — ewe.conf and the locale]] |
| How does ewe Settings install a dictionary / language pack / input method? | `install_packages` — official-repo packages of a few families only, one polkit prompt; AUR-only → `komble --search=` | [[Language Lives in Two Places — ewe.conf and the locale]] · [[Contracts and Public API]] |
| iPhone (HEIC) photos? | ewe Viewer / Files show them from ewe-apps 0.2 (built): `heif-dec` → a cached JPEG; AVIF and JPEG XL natively | [[Every Script Reads Right — encodings, phone pictures, right-to-left]] |
| What's the keymap? | The full table | [[Keymap Reference]] |
| What version is everything? | The ledger | [[Version Ledger]] |
| What's decided / parked / open? | Three notes, one table each | [[Decision Index]] · [[Parked and Rejected Ideas]] · [[Open Questions]] |

## Related

- [[00 Onboarding]] · [[Home]] · [[Rules of the House]]
