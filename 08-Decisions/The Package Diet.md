---
tags:
  - ewe-map
  - decisions
title: The Package Diet
up: "[[Decision Index]]"
---

# The package diet — what left `ewe`'s depends, and where it comes from now

**Decided 2026-11-19** (owner; decision 57). Built for ewe 0.44.0-beta,
Komble 0.23.0-beta, ewe-repo (`reversal-icon-theme` pkgrel 2, the publish
gate) and the ewe-os 0.16.0-beta ISO. Measured on the ISO's package set:
**7.5 → 5.4 GB installed, 2.48 → 1.90 GB compressed, the ISO 3.2 → 2.6 GB (measured: 2,591,948,800 bytes)**.

## The finding that started it

`nvidia-utils` (1 GB, and it **blacklists nouveau**) was installed on
**every** machine — Intel and AMD included — and the live ISO carried
`nvidia-open` to make up for it. Cause: `zed` depends on the virtual
`vulkan-driver`; the installer runs `pacman -S ewe` *before* phase 40 adds
the real per-vendor driver, and when no provider is installed pacman picks
the first alphabetical one — `nvidia-utils`. Fix in three places, all
needed: **`vulkan-swrast` front-pinned in the `ewe` PKGBUILD's depends**
(the dedupe filter keeps it: `grep -vxF -e pipewire-jack -e vulkan-swrast`),
in `packages/common.list`, and explicit at the end of the ISO's
`packages.x86_64` ("Mesa's CPU Vulkan claims it; nouveau / i915 / xe / amdgpu
drive the live desktop"); and the ewe-repo **fresh-install gate blacklists
`nvidia-utils`** (`grep -xE "jack2|tesseract-data-afr|papirus-icon-theme|iwd|nvidia-utils"`
over `pacman -Sp … gate/ewe`), so a future dependency cannot bring it back
unnoticed.

## What left, and who installs it now

| left `ewe`'s depends / the lists | comes from now |
|---|---|
| `nemo`, `engrampa`, `imv`, `zathura`, `zathura-pdf-mupdf`, `mpv-mpris`, `mpv-uosc-git` (AUR), `mpv` from the lists | **`ewe-apps`** — ewe Files, ewe Player, ewe Viewer ([[ewe's Own Apps — Files, Player, Viewer]]); GStreamer (`gst-plugins-{base,good,ugly}`, `gst-libav`, `ffmpeg`) joins the lists for the player and the thumbnailer. mpv stays only where `mpvpaper` already needs it |
| `ewe-cast`, `gnome-network-displays` (AUR) | the **Cast plugin's `requires`** — Komble installs them when the plugin is installed (decision 22, [[Add-on deps declared, not split]]); `ewe-cast` still rides the tarball (`get.sh`) path |
| `kdeconnect`, `qt5-wayland` | the **Phone plugin's `requires`**, the same way |
| `base-devel` | **Komble's `ensure_build_tools`** right before the first AUR build (pkexec `pacman -S --needed base-devel git`, deps not apps); phase 10 installs it only when it must build `paru` from source |
| `tesseract-data-eng` (the OCR data) | nothing — no shipped feature OCRs |
| `ttf-jetbrains-mono-nerd` | nothing — the design system is Inter + Geist; JetBrains was a manual recipe |
| `reversal-icon-theme` 416 MiB | the same package, **pkgrel 2**: `hardlink -q -c usr/share/icons` — the 24 colour variants differ in ~285 of ~10,660 files, so identical files are hard-linked: **~14 MiB installed**, every icon still a regular file to the loaders (~1.9 GB on a btrfs disk before) |
| ISO only: `nvidia-open`, `cloud-init` (+ its `cloud-init.target.wants` units), `clonezilla`, `partclone`, `partimage`, `fsarchiver`, `irssi`, `lynx`, `mc`, `nmap`, `tcpdump`, `refind`, `b43-fwcutter`, `darkhttpd`, `gpm`, `lftp`, `linux-atm`, `ndisc6`, `openpgp-card-tools`, `sequoia-sq`, `pptpclient`, `vpnc`, `wvdial` | nothing — a live desktop and its installer need none of them; `archinstall`, the VM guest tools, `brltty` and `espeakup` stay |

This is the mechanical half decision 22 promised: a plugin's `requires`
already named these packages; now `ewe` stops carrying them for machines
that never install the plugin.

## Not taken

Splitting `ewe` into `optdepends` groups (Komble + `requires` already give
one place to ask). Removing mpv (mpvpaper). Dropping `zed` (the owner's
editor) to lose the `vulkan-driver` pull — the pin is cheaper.

> **Build guard:** `vulkan-swrast` stays **first** in the `ewe` PKGBUILD's
> depends, in `common.list` and in the ISO list, and the publish gate keeps
> `nvidia-utils` on its blacklist. *Breaks if violated:* every fresh install
> downloads a 1 GB NVIDIA driver and its nouveau blacklist, and the live
> ISO loses its GPU driver on NVIDIA. Also: a package a plugin needs goes in
> the plugin's `requires`, not back into `ewe`'s depends.

## Related

- [[Decision Index]] · [[ewe-apps]] · [[Komble]] · [[ewe-repo]] ·
  [[ewe-os ISO]] · [[Packaging and Updates]] · [[Add-on deps declared, not split]]
  · [[Troubleshooting Knowledge]]
