---
tags:
  - ewe-map
  - overview
title: Glossary
up: "[[Home]]"
---

# Glossary

Terms as the project itself uses them.

| term | meaning |
|---|---|
| **ewe** | the whole OS project; also the DE repo/package. Pronounced "you". |
| **Hyprland** | the Wayland compositor ewe builds on; Lua-configured. |
| **Quickshell** | a QML-based shell toolkit for Wayland; ewe's bar, dock, launcher etc. are Quickshell QML. |
| **layer-shell** | the Wayland protocol (wlr-layer-shell) that lets surfaces be bars/docks/overlays. The shell needs it; Tauri can't do it — that's why the shell and the Tauri apps are separate processes. |
| **the one file** | `~/.config/ewe/ewe.conf` — TOML, the single declarative description of the machine. See [[The One File]]. |
| **ewe-conf** | the only tool that writes the one file; also `apply` (generate artifacts), `push`/`pull` (sync). See [[CLI Tools]]. |
| **ewe-auth** | the auth broker: owns the refresh token in the keyring, hands out access tokens. See [[Auth Broker]]. |
| **keyring** | gnome-keyring via `secret-tool` — where secrets (tokens, app passwords) live. Never in `ewe.conf`. |
| **Komble** | the software manager (repos + AUR + AppImages). See [[Komble]]. |
| **ewe-settings** | the Settings app — a separate process that edits config files and pokes the shell. See [[ewe-settings]]. |
| **ewe-sync** | the account & sync app — Nextcloud account, one-file sync, folder sync, machines. See [[ewe-sync]]. |
| **ewe-castd** | headless casting daemon: portal screencast → encode → Miracast/Chromecast. See [[ewe-cast]]. |
| **`qs ipc`** | the shell's IPC bus; apps and plugins call verbs like `qs ipc call settings reload`. |
| **add-on** | (0.25) a first-party plugin shipped inside the ewe payload (`plugins/<id>/` + `bundle.json`) but **not installed on a fresh machine** — Komble → Add-ons, Welcome or `ewe-plugin install <id>` puts it in. The dock, Cast, mail, phone, VPN, SSH, Places, music, Insomnia, the system monitor, clipboard, screenshot and passwords are add-ons. See [[Plugin System]]. |
| **`Shell`** | (0.25) the shell's public QML singleton for plugins — toast, Quick settings, actions, `bottomInset`, `anchorFor` — frozen behind plugin API 3. See [[Plugin API 3]]. |
| **Insomnia** | the user-facing name for "keep awake" (the idle inhibitor); the `ewe.insomnia` add-on. Namespace stays `quickshell:caffeine`. |
| **`bundle.json`** | `plugins/bundle.json` in the ewe repo — repo, commit, version, `default`, `migrate` for every vendored add-on; written by `scripts/vendor-plugins.sh`. |
| **migrate marker** | `~/.local/state/ewe/addons-migrated` — a local JSON list of add-on ids `ewe-plugin migrate` has already considered. |
| **the Pen** | `special:pen` (Super+Z) — ewe's stashed-windows workspace; the dock add-on shows it while something is stashed. |
| **portal / xdg-desktop-portal** | the sandbox-friendly API for screen capture etc. ewe-cast sources its stream from `ScreenCast`. |
| **PipeWire** | the media plumbing; ewe-cast's screen stream travels over it. |
| **Miracast** | Wi-Fi Direct screen mirroring (Samsung etc.). ewe-castd *listens* on RTSP port 7236 and the TV dials in. |
| **Chromecast** | Google's cast protocol; ewe-cast speaks cast-channel v2 (TLS 8009) and plays an HLS stream. |
| **Nextcloud** | the user's own cloud — the ewe account. WebDAV/CalDAV/IMAP, no gatekeeper. See [[Account and Sync]]. |
| **Login Flow v2** | Nextcloud's sanctioned way for a desktop app to get credentials — yields an app password listed as a device on the server's Security page. |
| **WebDAV `If-Match`** | the server-side conflict guard `ewe-conf push` uses: a racing write is rejected by the server itself. |
| **greetd** | the login manager; ewe runs `greetd → cage → Quickshell greeter`. |
| **Plymouth** | the boot splash; ewe's is silent. |
| **archiso** | the tooling that builds ewe's live/install ISO (profile derives from releng v89). |
| **archinstall** | the guided installer `ewe-install` wraps for disks/locale/users/bootloader. |
| **PKGBUILD** | the Arch package recipe; Komble shows you it before building from AUR. |
| **polkit** | privileged-action policy framework; Komble uses a helper for the one privileged step (`pacman -U`), ewe-settings needs none. |
| **worktree** | git worktrees — ewe's dev sandboxes under `.wt/`. See [[Worktrees and Screenshots]]. |
| **flock / blacksheep** | the two dark themes. Flock: neutral greys. Blacksheep: absolute black for OLED. |
