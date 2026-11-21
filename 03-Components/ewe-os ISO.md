---
tags:
  - ewe-map
  - component
title: ewe-os ISO
up: "[[Home]]"
---

# ewe-os — the Distro / ISO

`~/Projects/ewe/ewe-os` · [github.com/prj786/ewe-os](https://github.com/prj786/ewe-os) ·
**0.17.0-beta** released 2026-11-21 (the ISO for ewe 0.47: the installer asks your language first, apps for day one — ewe-os#22, [[Language First — the installer asks in your words]]); before it **0.16.0-beta** 2026-11-19 (the ISO for ewe 0.44, the trim, ewe-os#21) and **0.15.0-beta** 2026-11-01 (the ISO for ewe 0.37: the installer signs you in — *Your ewe account*, ewe-os#19); before it **0.14.0-beta** released 2026-10-23 (the ISO for ewe 0.35: all 16 plugins in the installer, ewe-os#18; before it 0.13.0-beta on 2026-10-04, the ISO for ewe 0.25's plugins, ewe-os#15; distro has its own version line; the DE's `ewe` package has another)

The distro layer: the **archiso profile** that builds the live/install ISO.
The DE, apps and packaging live in their own repos — this one turns them
into a bootable distribution.

## Build

```sh
sudo pacman -S archiso
sudo ./build.sh          # → out/ewe-0.1-alpha-x86_64.iso
./run-iso.sh             # boot it in QEMU/KVM (UEFI)
```

The profile (`iso/`) derives from archiso's **releng v89**: its full rescue
toolbox is kept, networkd/iwd are swapped for NetworkManager (what the DE
uses), and greetd + the live user service are enabled on top.

## What the ISO does

```mermaid
flowchart TB
    BOOT["boot the ISO"] --> LIVE["live session<br/>greetd → autologin → full ewe desktop"]
    LIVE --> TRY["try everything before touching a disk:<br/>desktop, Komble, add-ons (the live user has the dock)"]
    LIVE --> TT3["tty3: root rescue console (Ctrl+Alt+F3)<br/>tty1: the greeter"]
    LIVE --> INSTALL["ewe-install — guided disk install"]

    INSTALL --> AI["archinstall<br/>disks · locale · users · bootloader"]
    AI --> LAYER["wrapper layers on top:<br/>[ewe] repo · ewe package · greeter stack<br/>(greetd → cage → Quickshell greeter)<br/>per-user deploy for every created account"]
    LAYER --> ADDONS["the picked add-ons, per user:<br/>ewe-plugin install id --no-restart (chroot)<br/>best-effort — never fails the install"]
    ADDONS --> REBOOT["reboot → graphical greeter, desktop ready"]

    TRY -.-> INSTALL
```

- **First start** — the DE deploys itself via `ewe-setup` from the
  preinstalled `ewe` package, at boot, under the plymouth splash.
- **Rolling forward** — the ISO pins nothing; the `[ewe]` pacman repo is
  preconfigured, so live and installed systems update with plain
  `pacman -Syu`. See [[Packaging and Updates]].
- **The trim (0.16.0-beta, 2026-11-19 — [[The Package Diet]])**:
  `packages.x86_64` lost `nvidia-open` (it rode along only because
  `nvidia-utils` was being pulled for `zed`'s `vulkan-driver` and blacklists
  nouveau; now `vulkan-swrast` is explicit at the end of the list and
  nouveau / i915 / xe / amdgpu drive the live desktop), `cloud-init` and its
  `cloud-init.target.wants` units, `clonezilla`, `partclone`, `partimage`,
  `fsarchiver`, `irssi`, `lynx`, `mc`, `nmap`, `tcpdump`, `refind`,
  `b43-fwcutter`, `darkhttpd`, `gpm`, `lftp`, `linux-atm`, `ndisc6`,
  `openpgp-card-tools`, `sequoia-sq`, `pptpclient`, `vpnc`, `wvdial`.
  `archinstall`, the VM guest tools, `brltty` and `espeakup` stay. Measured
  package sum **7.5 → 5.4 GB installed, 2.48 → 1.90 GB compressed, the ISO
  3.2 → 2.6 GB (measured: 2,591,948,800 bytes)**.
- **Password sign-in in the installer** (0.16.0-beta): the *Your ewe
  account* step asks *Your Nextcloud · Username or email · Password* and
  runs `ewe-cloud login <server> --user <name> --password-stdin` (the
  password + `\n` on stdin, the buffer zeroed); *Sign in with the browser
  instead* keeps Login Flow v2 for 2FA/SSO (`browser: true` bolds that link)
  — [[Password Sign-in — a reversal]].

## The installer app

`installer/` is a **Tauri GUI (`ewe-installer`)** — the guided install's
face (RFC-003 in `ewe-os/docs/`): **Language** (0.17.0-beta; it replaced
Welcome) · **Keyboard** (0.17.0-beta) · Network · Time & place (with
**Formats**, 0.17.0-beta) · Disk · Your login · **Your ewe account**
(0.15.0-beta) · **Plugins** (0.13.0-beta) · **Apps** (0.17.0-beta) ·
Summary · Install. Nothing privileged runs in the app: every step is a verb
of the pkexec'd `installer/helper/ewe-install-helper` (`partition mkfs
pacstrap hibernate settz setlocale setkeymap sethostname user layer upgrade
language account addons apps bootloader reboot`; `installer/tests/
helper-test.sh` sources it with `EWE_HELPER_LIB=1`);
`layer` and `addons` delegate to `ewe-install --layer-only` /
`--addons-only` — one implementation, two faces.

**The Plugins step** lists every plugin the live payload carries
(`/usr/share/ewe/plugins/bundle.json` + manifests, read by the backend's
`addons` command — no user config needed), grouped by category, with the
manifest's Theme icon name mapped to the bundled Lucide face. **Nothing is
pre-checked** ([[Add-ons — opt-in, not preinstalled]]); the Dock row says
*Recommended if you like a dock*. The picks are installed after
`ewe-setup` (which on a fresh account runs `migrate --fresh` and installs
nothing) as the new user in the chroot — `ewe-plugin install <id>
--no-restart`, Hyprland/Wayland/D-Bus variables dropped — each one
best-effort: `{"addon":id,"ok":false}` is shown on the Done screen and the
install still succeeds. An ISO with an older ewe (no `bundle.json`) has no
such step. TUI: `ewe-install --addons id,id`, a prompt in guided mode.
Signed in with a backup (0.15.0-beta), the backup's first-party plugins are
**pre-checked** (*From your account*) — the owner's call: bring back what
you had, turn on anything else; a skipped account keeps D1 (nothing
pre-checked).

**Your ewe account** (0.15.0-beta, [[Sync — sign in once, everything
follows]]) — sign in or skip. The backend (`installer/src-tauri/src/
account.rs`) drives the live system's `ewe-cloud login` in a private 0700
config under `$XDG_RUNTIME_DIR` with ewe-cloud's file keyring (the live
user's keyring is never involved) and reads the backup with `ewe-conf
pull --out` + `dump`. The `account` verb (after `upgrade`, before
`addons`) takes `<user> <server> <login> <yes|no>` with **both passwords
on stdin**: it creates the new user's **login keyring with the login
password** (`gnome-keyring-daemon --unlock` in a private D-Bus session,
`default` = `login`) and stores the app password there — PAM unlocks the
same keyring at the first login, so the first boot is signed in — writes
`cloud.json`, and with `yes` runs `ewe-conf pull` + `apply --no-hooks` as
the user (recorded as synced; Welcome then skips its restore step). The
TUI has no account step yet.

**Language first, apps for day one** (0.17.0-beta, ewe-os#22 —
[[Language First — the installer asks in your words]]). *Language* lists
every UTF-8 locale glibc supports in its own words and pre-fills region,
keyboards (a non-Latin layout gets `us` first), formats, the spelling
dictionary and typing (fcitx5 + engine for CJK, Vietnamese, Indic). The
helper's `setlocale <locale> [formats]` writes LANG + the five regional
formats and always generates `en_US.UTF-8`; `setkeymap <layouts>
<variants>` writes `/etc/X11/xorg.conf.d/00-keyboard.conf` and the console
keymap (the first layout that types a–z, via systemd's `kbd-model-map`);
`ewe-install` puts `XKB_DEFAULT_*` from that file into the greeter wrapper,
so the login screen types with the chosen keyboards (it was always US).
`language <user> <layouts> <variants> <ime> <dict> <pkgs>` runs one pacman
for fcitx5/engine/hunspell (only `hunspell-*` / `fcitx5*` names pass) and
writes `[desktop.input]`, `[desktop.ime]`, `[desktop.language]` through
`ewe-conf` as the user, then `ewe-ime apply` — before `account`.
`apps <user> <repo,pkgs> [aur:pkg|appimage:pkg …]` installs repo apps
(Steam: `[multilib]` + the GPU's lib32 Vulkan driver) and writes the rest
to `~/.local/state/ewe/install-picks.json` for Komble 0.25's For you.
`pacstrap` adds **`sudo`** (GUI installs up to 0.16 had none) and the Disk
screen hides zram. `release-iso.yml` has a **`test`** input: `gh workflow
run release-iso.yml --ref <branch> -f test=true` keeps the ISO as the
`ewe-test-iso` artifact and touches no release (a dispatch without it still
attaches to the newest release).

**The live session** is the one non-opt-in place: a fresh 0.25 account has
no dock, and the stick pins *Install ewe* in the dock — so
`ewe-live-deploy` installs `ewe.dock` for the live user only (the installer
also autostarts and is first in the launcher). Installed systems get
nothing they did not pick.

## Docs in-repo

- `docs/INSTALL.md` — the install guide
- `docs/TROUBLESHOOTING.md` — problems

## Related

- [[Install Flow]] · [[ewe-repo]] · [[ewe Desktop]] · [[Website]]
