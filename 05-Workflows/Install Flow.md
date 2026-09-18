---
tags:
  - ewe-map
  - workflow
title: Install Flow
up: "[[Home]]"
---

# Install Flow — from ISO to desktop

The whole thing takes about ten minutes. The live session *is* the desktop,
so you can try everything before touching a disk.

```mermaid
flowchart TB
    DOWN["download the ISO<br/>prj786.github.io/download"] --> WRITE["write to USB<br/>verify the image"]
    WRITE --> BOOT["boot (UEFI)"]
    BOOT --> LIVE["LIVE SESSION<br/>greetd → autologin → full ewe desktop<br/>first start: ewe-setup under plymouth"]
    LIVE --> TRY["try: desktop · Komble · cast · plugins<br/>tty3 = root rescue (Ctrl+Alt+F3)"]
    TRY --> INSTALL["run ewe-install"]

    subgraph INSTALL["ewe-install"]
        A1["archinstall:<br/>disks · locale · users · bootloader"]
        A2["wrapper layers:<br/>[ewe] repo + ewe package<br/>greetd → cage → Quickshell greeter"]
        A3["per-user deploy (ewe-setup)<br/>for every created account"]
        A1 --> A2 --> A3
    end

    INSTALL --> REBOOT["reboot → graphical greeter → desktop ready"]
    REBOOT --> FORWARD["rolling forward: pacman -Syu<br/>session refreshes at login when<br/>a newer payload landed"]
```

## The alternative path — DE only

On Arch you already have:

```sh
# /etc/pacman.conf ← [ewe] (see ewe-repo)
sudo pacman -S ewe        # desktop, Komble, ewe-settings + dependencies
ewe-setup                 # per-user deployment
sudo /usr/share/ewe/install.sh   # system: greeter, plymouth, hibernate
```

## The hacker path

```sh
git clone https://github.com/prj786/ewe ~/ewe && cd ~/ewe
bash install.sh           # symlink farm; prompts before each change
./update.sh               # pull + converge + restart the shell
```

Both are idempotent and back up every config they touch; `uninstall.sh`
restores them. Full details: `ewe/docs/MANUAL.md`.

## Related

- [[ewe-os ISO]] · [[Packaging and Updates]] · [[Update Flow]] ·
  [[ewe Desktop]]
