---
tags:
  - ewe-map
  - how-we-work
title: Troubleshooting Knowledge
up: "[[Home]]"
---

# Troubleshooting Knowledge — known failure classes

Distilled from `ewe/docs/TROUBLESHOOTING.md` and the project's history.
**Before debugging anything new, scan this list** — most hard bugs here are
repeats.

## Cast to TV (the 2026-08-21 investigation — in the order it bit)

1. **Frozen picture / TV drops ~10 s after connect.** `xdg-desktop-portal-hyprland`
   1.4.1 screencopy retry bug (`Out of buffers` → `Retrying screencopy` →
   `tried scheduling on already scheduled cb` → never asks again). ewe ships
   a patched build from `packages/patched/`: first **1.4.1-1.1**, then —
   after Arch's stock **`1.4.1-2` replaced it and the freeze came back
   (2026-09)** — **`1.4.1-2.1`**, which is the threshold now (`vercmp` in
   phase 90; ewe-cast 0.12.3). Check: `pacman -Q xdg-desktop-portal-hyprland`
   (must be ≥ 1.4.1-2.1) +
   `journalctl --user -u xdg-desktop-portal-hyprland | grep -c "Out of buffers"`.
   Measured: stock delivered 7 frames then froze; patched ran indefinitely.
2. **Lag/stutter.** Software x264 → install `gst-plugin-va` (`vah264enc`);
   or Wi-Fi Direct sharing a crowded 2.4 GHz channel; or no regulatory
   domain (`iw reg get` → `country 00` makes 5 GHz receive-only) — phase 30
   installs `wireless-regdb` + GeoIP country.
3. **TV drops after ~3.5 min (working stream).** Wi-Fi power saving on the
   group owner — dispatcher `50-ewe-cast-powersave` turns power_save off
   while any `p2p-*` is up. Live check: `iw dev wlan0 get power_save`.
4. **No sound on TV.** The null sink was made but audio wasn't moved —
   `hypr/scripts/cast-audio.sh` makes it default while casting. Check
   `pactl get-default-sink`.
5. **"Connection failed" with nothing else.** Read the journal: the shell
   narrates NM + wpa_supplicant into toasts; raw:
   `journalctl -f -u NetworkManager -u wpa_supplicant`; app trace:
   `~/.local/state/ewe/cast.log`. `supplicant-timeout` with no GO-negotiation
   = the TV wasn't listening (open Source → Screen Mirroring first).

**The preflight checks all of the above and prints the fix for each.** Since
0.25 it lives with the [[Cast Plugin]]: `sh
~/.config/ewe/plugins/ewe.cast/cast-check.sh` (the old
`~/.config/hypr/scripts/cast-check.sh` is gone — `ewe-diag`'s `diag.sh`
must point at the new path). The `cast` IPC target is an alias of
`ewe.cast`; `qs ipc call ewe.cast legacy` is the gnd door.

## Sign-in / keyring

- **No keyring prompt, "keyring not showing up"** — the account credential
  (Nextcloud app password / Google refresh token) lives in the Secret
  Service keyring; a missing gnome-keyring or an unlocked-at-boot problem is
  the usual cause. Boot-race safe probes retry with backoff (the keyring
  may come up after the shell). Keyring playbook: `ewe-auth keyring-reset`.

## Settings

- **"Top bar settings do nothing" (0.12.7)** — prefs the Settings app
  writes MUST be in ewe-conf's `THEME_MAP`, or `absorb` drops them on the
  next write. When adding a setting: add it to `THEME_MAP` in the same
  change.
- **A change vanished** — you edited a `generated/` file; it's a build
  artifact. Change the source (`ewe.conf`), then `apply`.

## Add-ons (0.25)

- **"My dock / clipboard / Cast tile is gone" on a fresh install** — not a
  bug: nothing in the payload is installed on a fresh machine
  ([[Add-ons — opt-in, not preinstalled]]). Komble → Add-ons, the Welcome
  Add-ons step, or `ewe-plugin install <id>`. On an **upgrade** the features
  the user had are installed once by `ewe-plugin migrate`
  (`~/.local/state/ewe/addons-migrated`); the dock is skipped only when
  `[desktop.dock] enabled = false`, and anything in `[plugins].removed` stays
  out.
- **Re-adding a removed first-party plugin with `ewe-plugin add
  https://github.com/prj786/ewe-plugin-<x>.git` failed** (reserved `ewe.`
  id) — since 0.25 that URL/id installs the payload copy; the honest
  command is `ewe-plugin install <id>`.
- **`seed --restore <id>` silently seeded nothing** (pre-0.25) —
  `PAYLOAD_PLUGINS` didn't resolve; now realpath with fallbacks
  (`/usr/share/ewe/plugins`, `~/.local/share/ewe/plugins`).
- **An add-on's legacy IPC target / QS key / layer namespace stopped
  working** — the add-on is not installed or not enabled (`ewe-plugin
  list`); when installed, `cast launcher places player mail` and
  `quicksettings tab ssh|vpn|mobile|mail|cast` behave exactly as before.
  ewe-settings treats a missing `mail` target as "add-on absent", not an
  error.
- **Komble shows no Add-ons group** — the shell's `ewe-plugin list --json`
  has no `available` key = an ewe older than 0.25.
- **A tile won't hide** — hide the host slot (`parent.visible`), never
  `Tile.visible`; the home grid collapses empty slots.
- **A `dock-item` shows nothing** — no dock installed: the item simply has
  no host (by design, not an error). With the dock: check
  `Shell.dockItemShown(id)` (the Music add-on hides its own button).
- **`kdeconnectd` appeared as a new device on the network during a test
  run** — D-Bus **auto-activation starts it on ANY proxy call**. A harness
  needs `EWE_PHONE_NO_DAEMON=1` **and** a private bus (`HS_PRIVATE_BUS=1`).

## Shell / QML

- **Lid-open blinks 3–4× before the password field** (fixed 2026-10-04,
  0.25 — [[Quiet Lid — touch only a disabled panel]]). Four stacked causes:
  an unconditional `after_sleep_cmd` dpms-on (hypridle.conf, the
  Settings.qml generator **and** ewe-settings `hypr.js`), `Lid._open`
  sending `preferred/auto` + dpms to every output, `HyprMon._reassertT`
  re-applying the whole set, and the Lock surface's `sourceSize` bound to
  the surface. Rule: never `hl.monitor` for an output that already matches
  (`verifyOne` per output in `applyMatching`; `force` = Reset only); never an
  unconditional dpms-on except Reset displays.
- **Machine re-sleeps 0.1–0.7 s after a hibernate resume** — a stale
  `HyprMon.lidClosed` plus Qt timers elapsing through the hibernate
  transition. Every sleep decision re-reads
  `/proc/acpi/button/lid/*/state` (`HyprMon.probeLid()`); `Lid` logs `lid:
  going to sleep: <reason>` at WARN — look for that line first.
- **Every lid-close suspend waits the full delay** — the logind bridge
  called `readline()` once per wakeup; buffered `os.read` now
  (`tests/logind-bridge-test.py`, 17 checks).
- **Overview: keys die / the wrong output takes the keyboard** — per-screen
  layer windows must not all request keyboard focus (last-mapped wins):
  `Exclusive` only on the field's window while open, `None` otherwise; keys
  die without an `activeFocusItem` → root `FocusScope` `focus: true` +
  `Keys.onPressed` fallback.
- **A Hyprland `global` shortcut fires twice / never** — Hyprland 0.56
  signal matrix: a *release* bind → `released` only; a *press* bind →
  `pressed` + `released`; a `dispatch` → `pressed` only. Toggle on
  `released`. `ewe:overview` is a release bind on Super.
- **A `Loader` whose `visible` binds to `item.visible`** — effective-
  visibility cycle (the item is invisible because the Loader is, because
  the item is …). Drive visibility from state, not from the child.
- **Reading an attached property (`QsWindow.window`) from another object**
  returns nothing — attached properties live on the attachee; pass the
  window explicitly (`Shell.anchorFor(item, window)`).
- **`AnchoredPopup` opened over the bar** — a top-edge card must clear the
  bar (fixed by B1); a bottom-edge one clears `Shell.bottomInset`.
- **`pgrep -f <pattern>` matches itself** when run inside `sh -c` (the
  wrapper's command line contains the pattern) — use `pgrep -x` or anchor
  the pattern; same family as the clipboard guard bug below. **`pkill -f
  <pattern>` from an agent's Bash tool kills the calling shell** when the
  pattern is in its own command line.
- **`hyprctl` with no `HYPRLAND_INSTANCE_SIGNATURE` errors out** — so
  `env -u HYPRLAND_INSTANCE_SIGNATURE` is a real guard against touching the
  live compositor, not a cosmetic one.
- **The whole shell vanishes at random, Hyprland keeps running** (0.23–0.24,
  fixed 0.24.1-beta). Journal: `wl_display#1: error 0: invalid object N` →
  `The Wayland connection experienced a fatal error: Invalid argument` →
  `ewe.service: … status=255`. Hyprland 0.56 bug: `captureToplevel()` returns
  without creating the frame when the window closed that instant, and qs's
  later `frame.destroy()` names an id the server never had. Trigger = a live
  toplevel `ScreencopyView` (the Overview cards). Fix: cards capture only
  while the Overview is mapped, ✕ drops the capture before closing, and
  `qs-launch.sh` turns "255 after ≥ 15 s with Hyprland still answering" into
  exit 1 so the unit restarts it. Still racy by design while the Overview is
  open → the restart is the safety net. Repro: nested harness, open kitty
  windows, Overview open, `pkill` them → dead in round 1 (`WAYLAND_DEBUG=client`
  shows the id). Never capture toplevels in a hidden surface.
- **`qs` dies on `up`** — read `driver.sh log`; QML errors name file:line.
  Ignore benign "already registered" D-Bus / PolkitAgent /
  "hyprland-guiutils not installed" warnings (nesting artifacts).
- **Surface didn't open** — a ~15 KB driver shot = bar only; a real window
  is ~40–57 KB.
- **`onAccent:` parses as a signal handler** beside a property called
  `accent` — declare the token bare and fill it with a `Binding`.
- **Plugin widget renders nothing** — inside a `Scope` use `Variants`,
  never `Repeater` (needs an Item parent, silently creates nothing).
- **`qs ipc call <t> show` no-ops** — collides with the `qs ipc show`
  subcommand; bind `toggle`.
- **Shell aborts at start with "pure virtual method called"** (2026-09-20)
  — Quickshell 0.3.1's icon loader on its image thread, when a themed icon
  misses (`QIcon::pixmap → QPlatformPixmap::fromFile`). Intermittent (≈1 in
  3) in the driver's sandbox until it linked the live `qt6ct` (icon theme);
  a machine with a broken icon theme would see it too. Not the polkit
  warning that happens to precede it.
- **Never destroy a refused `PolkitAgent`** — a Loader flip on a failed
  registration also crashes 0.3.1; `Auth.qml` parks refused agents and caps
  the retries.
- **"Plugins disabled for this session" after a few manual restarts** —
  the crash guard used to count every start; since 2026-09-20 `ewe-plugin
  list --boot` counts only starts that follow a Quickshell crash report or
  a systemd automatic restart (`NRestarts` resets on `systemctl restart`).
- **Clipboard history records nothing** — the `wl-paste --watch` guard was
  `pgrep -f "wl-paste …"`, which matched its own `sh -c` wrapper; the
  pattern must be anchored (`^wl-paste`). Plugin ewe.clipboard ≥ 1.1.1.
- **Low-battery warnings / hibernate never fire** — Quickshell's
  `UPowerDevice.percentage` is a 0–1 fraction; `Battery.qml` refused every
  reading as "ambiguous" until 2026-09-20.
- **Settings app: Glass / bar opacity / corners / accessibility persist but
  the desktop does not repaint** — `set_conf` wrote with `--no-hooks` and
  never poked the shell; it now sends `settings reload` + `hyprctl reload`.
- **`nmcli` state strings** — device states carry a parenthetical
  (`connecting (getting IP configuration)`, `connected (externally)`): match
  the word, never the whole string. `nmcli -t` escapes `:` and `\` in
  values (SSIDs): unescape after splitting.
- **`Behavior on y` animates the map** — an item whose `y` depends on
  `parent.height` inside a lazily-mapped `PanelWindow` slides across hundreds
  of pixels the first time the window maps. Put the motion on a
  `transform: Translate`, or drop it. Bit `LauncherPanel.qml`, `Places.qml`,
  `AppStore.qml` and `Launcher.qml`.
- **A surface's backdrop image arrives late** — `sourceSize` bound to a
  `PanelWindow`'s `width`/`height` re-keys Qt's pixmap cache on every map and
  re-decodes. Bind it to `screen.width`/`height` and warm it in
  `Wallpaper.qml`.
- **Never put a state-dependent duration (`cond ? a : b`) inside a Behavior's
  animation** — the Behavior fires before the binding re-evaluates and plays
  the other direction's value. Sequence with an explicit flag + Timer.
- **X11 apps (Steam, Java/ProjectLibre) huge on a 1x external** — X11 has
  one scale for all screens. `start-hyprland.sh` decides it at login: it used
  the PRIMARY display of the `lastKey` profile, and `lastKey` only moves when
  Settings → Displays saves, so a docked login sized X11 for the 1.8x laptop.
  Since 2026-10-04 it reads the connected set from `/sys/class/drm`, picks
  that set's profile and takes the SMALLEST lit scale (soft on the laptop,
  right size everywhere). Check with `env | grep -E 'GDK_SCALE|STEAM_FORCE|EWE_X11'`
  and `hyprctl getoption xwayland:force_zero_scaling`. Docking after login still
  needs a re-login. Test: `tests/x11-scale-test.sh`.
- **Java/Swing apps with jagged text** — outside GNOME the JDK gets no font
  hints, so Swing draws un-antialiased. Fix per app with
  `-Dawt.useSystemAAFontSettings=on` (ProjectLibre: `JAVA_OPTS` in
  `~/.projectlibre/run.conf`). Not exported globally on purpose:
  `JDK_JAVA_OPTIONS`/`_JAVA_OPTIONS` print a "Picked up" line on every `java` run.

## The nested harness (`run-ewe/driver.sh`) and agent tooling

- **`ewe-plugin … --no-restart` still touched the LIVE Hyprland** — the
  keybind writer runs `hyprctl reload` against
  `$HYPRLAND_INSTANCE_SIGNATURE`, and `set`/`place` poke `qs ipc plugins
  reload` on `$WAYLAND_DISPLAY`; the driver's install step inherited the
  host's values (2026-10-04: `HS_PLUGINS=1` reloaded the real session — no
  persistent change, but a live touch). The driver now runs every tool call
  as `env -u HYPRLAND_INSTANCE_SIGNATURE -u WAYLAND_DISPLAY ewe-plugin …`.
  **Rule for any wrapper: unset both before calling `ewe-plugin`.**
- **`ewe-plugin set/place` reloads nothing in the harness** — `qs` matches
  `plugins reload` by config path, so the poke never reaches `qs -p
  <checkout>`; use `driver.sh ipc plugins reload`. With the host display
  set it hits the live shell instead.
- **`HS_PLUGIN_DIRS` refuses `ewe.*` ids** (reserved) and the driver forces
  `EWE_PAYLOAD_PLUGINS=$REPO/plugins` — to test a first-party add-on from
  its repo, copy it into a private payload dir and use
  `HS_PAYLOAD=<dir> HS_PLUGINS=1` (or an `EWE_PLUGIN_TOOL` wrapper).
- **Two headless outputs must not share a position** — `HS_HEADLESS` puts
  SHOT at `1920x0`; a second headless output goes to `3840x0` or the shots
  overlap.
- **`wtype` cannot trigger binds in the nested compositor** unless
  `input:resolve_binds_by_sym = true`; a Super *tap* is `wtype -M logo -k
  Super_L -m logo`.
- **Headless screenshots of the Tauri UIs on this box** — Brave
  `--headless=new` hangs; the chrome-devtools MCP wants
  `/opt/google/chrome`. What works: **Helium** `--headless=new
  --ozone-platform=headless --virtual-time-budget=6000`, or a WebKit shot
  under a headless cage: `env -u WAYLAND_DISPLAY -u DISPLAY
  WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 cage -- python3
  webkit-shot.py URL out.png` (WebKit2 GI; broadway is unusable for WebKit).
  ewe-settings' mocks are inline in `dev-mock.html`
  (`?addons=fresh|dock|legacy`, `?komble=0`).

## Installer

- **`sudo /usr/share/ewe/install.sh` exits 2** — on purpose
  (`install.sh:38-50`): under sudo `$HOME` is `/root`, the desktop would
  install into root's home and the session entry would point there, so
  login dies silently. Run `bash /usr/share/ewe/install.sh --no-packages` as
  your user; it escalates itself where root is needed.
- **A single missing package must never abort the run** — installers
  warn-and-skip and return 0 (this was the root cause of a past "no
  greeter" failure). Don't regress `lib/pkg.sh`.
- **Everything through `run()`/`sudo_run()`** — direct `cp`/`ln`/`pacman`/
  `systemctl` in a phase breaks `--dry-run` honesty.
- **Hyprland config silently ignored** — Hyprland < 0.55 ignores Lua
  config (`VERSIONS` documents the floor).
- **Screen sharing / file pickers / app handoff silently fail** — the
  `hyprland-session.target` user unit (`BindsTo=graphical-session.target`)
  is missing or not enabled; it's what activates `xdg-desktop-portal` on a
  non-uwsm session. It is "the single most important step" of the install
  (MANUAL.md).

- **Blue text flashes on tty1 while the greeter loads and again right
  after login** (2026-09-20) — greetd hands the greeter its VT as stdio and
  cage runs wlroots at INFO, whose lines are bold blue on a tty. The
  `ewe-greeter` wrapper (phase 30) now clears the VT and logs to
  `$XDG_CACHE_HOME/greeter.log` (`/tmp/ewe-greeter/`). Before 0.25 a
  packaged install got the new wrapper only when `install.sh` (the system
  side) was re-run; **since 0.25 `pacman -Syu` refreshes the greeter wrapper
  (shipped as `system/greeter/ewe-greeter`), `shell.qml` and
  `theme-tokens.json` via the package's `post_upgrade`** where phase 30 had
  run before. Fonts, greetd `config.toml` and PAM still need `install.sh`
  (as the user, `--no-packages`). `uninstall.sh` never removes
  `/usr/local/bin/ewe-greeter` (open).
- **Anything with the old `#0a84ff` blue is stale** — the v3 default accent
  is `#eeb407`; `colorscheme.sh`'s fallback, `ewe-setup`, phase 60,
  kitty.conf and ewe-os's `os-release ANSI_COLOR` were updated 2026-09-20.

## VPN

- **"Only the VPN works" — no internet on home Wi-Fi without it.** DNS, not
  routing: `/etc/resolv.conf` was a plain file and Tailscale (MagicDNS)
  rewrote it to `nameserver 100.100.100.100`; resolved was disabled. Check
  `ls -l /etc/resolv.conf` (must → `/run/systemd/resolve/stub-resolv.conf`)
  and `resolvectl status`. Phase 30 (0.24.1-beta) enables resolved, drops
  `/etc/NetworkManager/conf.d/10-ewe-dns.conf` (`dns=systemd-resolved`) and
  relinks resolv.conf; phase 90 checks it.
- **Every L2TP profile fails with "The VPN service failed to start"** —
  strongSwan 6.1 (as Arch ships it) no longer speaks IKEv1, and L2TP/IPsec
  *is* IKEv1. The installer ships libreswan with `ikev1-policy=accept`;
  re-run `install.sh` (or `--check-only` to look) to swap the backend.
  See [[Phone and VPN]].

## Theming

- **A colour ignores the accent** — a raw literal in QML; only tokens
  allowed (rule 8).
- **A `control*` got double-grown** — never wrap a `control*` in
  `Theme.grow()`; it has grown already.
- **GTK stays light while the shell is dark** — `colorscheme.sh` is
  `set -u` (not `-e`) on purpose; a stray non-zero line must not abort
  before all files are written. Check the log it prints.

## Related

- [[Testing and QA]] · [[Development Loops]] · [[Rules of the House]] ·
  [[Roadmap — ewe-cast]] · [[Plugin System]] · [[Quiet Lid — touch only a disabled panel]] ·
  [[Overview Takes the Screen]]
