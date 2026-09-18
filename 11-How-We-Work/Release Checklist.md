---
tags:
  - ewe-map
  - how-we-work
title: Release Checklist
up: "[[Home]]"
---

# Release Checklist

How a release travels through the repos. The rule of thumb: **the ewe-repo
publish is the last step of every wave.**

## 1. The DE (ewe repo)

- [ ] `VERSION` (semver + `-alpha`/`-beta`) **and** `Globals.version`
      (shown in the Settings sidebar) **bumped together** — this is a
      contract, they drift apart otherwise.
- [ ] `release.sh` builds the artefact:
      `git archive HEAD → dist/ewe-<VERSION>.tar.zst` (zstd -19).
- [ ] `release.sh --publish` creates the GitHub release
      (tag `v<VERSION>`, `--prerelease` for alpha/beta).
- [ ] `get.sh` (the curl one-liner) installs that artefact into
      `~/.local/share/ewe` — the non-git install path.
- [ ] PKGBUILD/binary-release notes if the package changed (Komble,
      ewe-settings ships as GitHub releases installed by phase 20).

## 2. The Tauri apps (komble-arch, ewe-settings, ewe-sync)

- [ ] their own releases (GitHub releases; phase 20 installs from prebuilt
      binaries; the PKGBUILD is Komble's packaging path).
- [ ] remember: ewe-settings' footer shows **ewe's** version, not its own —
      don't "fix" that.

## 3. Cross-repo waves

- [ ] Features touching several repos merge as **one wave** (the RFC-005
      `nextcloud` branch wave set the pattern: ewe, komble-arch,
      ewe-settings, ewe-os, website — then publish).
- [ ] Public API changes (`qs ipc` verbs, ewe.conf schema, manifest
      `apiVersion`, keyring service names) are announced in the wave and
      updated in [[Contracts and Public API]].

## 4. ewe-repo publish

- [ ] Run the `publish` workflow after any ewe / komble-arch /
      ewe-settings / ewe-sync release (triggers: manual `workflow_dispatch`,
      `repository_dispatch` type `publish`, Monday cron).
- [ ] It rebuilds everything from the latest releases + AUR PKGBUILDs and
      recreates the x86_64 release (`ewe.db` + packages).
- [ ] Until signing lands, keep `SigLevel = Optional TrustAll` documented
      honestly (see [[Unsigned Repo — for now]]).

## 5. The ISO (ewe-os)

- [ ] `VERSION` (distro's own line) bumped.
- [ ] `sudo ./build.sh` → `out/ewe-<v>-x86_64.iso`; `./run-iso.sh` smoke
      test in QEMU/KVM (UEFI).
- [ ] Installer path re-tested in a throwaway VM (`ewe-install`).

## 6. The website

- [ ] Pushing to `main` deploys via `.github/workflows/deploy.yml`
      (Pages → Source: GitHub Actions).
- [ ] Screenshots for changed surfaces: `docs/capture.sh` in the real DE
      → `docs/media/` → the site (screenshots live on the website, not in
      the repo).
- [ ] `src/tokens.css` re-vendored from `ewe/design/tokens.css` if the
      design system changed.

## 7. The vault

- [ ] Update `01-Overview/Roadmap and Status.md` + [[Version Ledger]].
- [ ] Any decision/contract change → `08-Decisions/`, `09-Rules/`,
      `12-Reference/`.
- [ ] Any new gotcha → the note's Build guard + [[Troubleshooting Knowledge]] if it exists.

## Related

- [[Packaging and Updates]] · [[Roadmap — Distro and Repo]] ·
  [[Development Loops]] · [[Conventions]]
