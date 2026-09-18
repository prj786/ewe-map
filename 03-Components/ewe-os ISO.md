---
tags:
  - ewe-map
  - component
title: ewe-os ISO
up: "[[Home]]"
---

# ewe-os — the Distro / ISO

`~/Projects/ewe/ewe-os` · [github.com/prj786/ewe-os](https://github.com/prj786/ewe-os) ·
**0.12.4-beta** (distro has its own version line; the DE's `ewe` package has another)

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
    LIVE --> TRY["try everything before touching a disk:<br/>desktop, Komble, cast, plugins"]
    LIVE --> TT3["tty3: root rescue console (Ctrl+Alt+F3)<br/>tty1: the greeter"]
    LIVE --> INSTALL["ewe-install — guided disk install"]

    INSTALL --> AI["archinstall<br/>disks · locale · users · bootloader"]
    AI --> LAYER["wrapper layers on top:<br/>[ewe] repo · ewe package · greeter stack<br/>(greetd → cage → Quickshell greeter)<br/>per-user deploy for every created account"]
    LAYER --> REBOOT["reboot → graphical greeter, desktop ready"]

    TRY -.-> INSTALL
```

- **First start** — the DE deploys itself via `ewe-setup` from the
  preinstalled `ewe` package, at boot, under the plymouth splash.
- **Rolling forward** — the ISO pins nothing; the `[ewe]` pacman repo is
  preconfigured, so live and installed systems update with plain
  `pacman -Syu`. See [[Packaging and Updates]].

## The installer app

`installer/` is a **Tauri GUI (`ewe-installer`)** — the guided install's
face. The backend still rides archinstall for disks/locale/users/bootloader
(the README's contract), then layers the `[ewe]` repo, the `ewe` package,
the greeter stack and the per-user deploy.

## Docs in-repo

- `docs/INSTALL.md` — the install guide
- `docs/TROUBLESHOOTING.md` — problems

## Related

- [[Install Flow]] · [[ewe-repo]] · [[ewe Desktop]] · [[Website]]
