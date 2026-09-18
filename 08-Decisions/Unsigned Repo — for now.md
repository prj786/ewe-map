---
tags:
  - ewe-map
  - decisions
title: Unsigned Repo — for now
up: "[[Home]]"
---

# The unsigned repo — a temporary, scheduled state

## The state

`[ewe]` packages are currently **unsigned**:

```ini
[ewe]
SigLevel = Optional TrustAll
Server = https://github.com/prj786/ewe-repo/releases/download/x86_64
```

`Optional TrustAll` means: signatures are checked *if present*, and
absent signatures are tolerated.

## Why it is acceptable for now

- The repo is a GitHub release endpoint (`ewe.db` + packages) rebuilt by the
  `publish` workflow — not a random mirror; transport is TLS.
- The project is beta; the audience pulls from a pinned repo URL.
- The `ewe.gpg` key material exists in `ewe/system/` already — the plumbing
  is staged.

## The plan

Repo signing is **planned before the standalone-distro release** (it is on
the list for the "Dolly" 1.0 line — see [[Roadmap — Distro and Repo]]).

## Anti-regression notes

- Don't flip to `SigLevel = Required` before the signing key is actually
  distributed and the repo signs every package — that bricks updates.
- Don't ship the standalone ISO while still `Optional TrustAll`.
- When signing lands: pacman.conf docs in ewe-repo, ewe's `install.sh`, the
  ISO preconfiguration, and this vault all change together.

## Related

- [[Packaging and Updates]] · [[ewe-repo]] · [[Roadmap — Distro and Repo]] ·
  [[Decision Index]]
