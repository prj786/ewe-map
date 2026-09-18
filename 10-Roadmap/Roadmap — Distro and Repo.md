---
tags:
  - ewe-map
  - roadmap
title: Roadmap — Distro and Repo
up: "[[Home]]"
---

# Roadmap — distro & repo

Current: ewe-os **0.12.4-beta**; ewe-repo rolling unsigned.

## The one gate before standalone

**Repo signing** — planned before the standalone-distro release (see
[[Unsigned Repo — for now]]). The `ewe.gpg` key material already exists in
`ewe/system/`; the work is wiring:

- [ ] ewe-repo `publish` workflow signs every package + `ewe.db`
- [ ] `SigLevel = Required DatabaseOptional` (or equivalent) in the docs,
      `install.sh`, and the ISO preconfiguration — all in one wave
- [ ] key distribution story (keyring package or documented `pacman-key`)
- [ ] vault update: flip [[Unsigned Repo — for now]] to shipped

## The ISO

- ISO pins nothing — live + installed roll forward via `pacman -Syu`.
- `ewe-install` wraps archinstall (disks/locale/users/bootloader) then
  layers the `[ewe]` repo, the `ewe` package, the greeter stack, per-user
  deploy.
- **Candidate polish for the standalone release:** installer progress/UX,
  a post-install first-login Welcome (already exists — verify it covers the
  Nextcloud restore offer), TROUBLESHOOTING coverage in `ewe-os/docs/`.

## The publish cadence

The Monday cron + `repository_dispatch` + manual `workflow_dispatch` (see
[[Packaging and Updates]]). Run after any ewe / komble-arch / ewe-settings /
ewe-sync release — the repo is the *last* step of every release wave.

## The one-wave merge pattern

Cross-repo features (the RFC-005 `nextcloud` branch wave) merge as **one
wave across ewe, komble-arch, ewe-settings, ewe-os and the website**, then
the repo publish rebuilds. Never merge half a wave — the apps on one side
and the shell on the other must not expect different contracts.

## Related

- [[ewe-repo]] · [[ewe-os ISO]] · [[Packaging and Updates]] ·
  [[Release Checklist]]
