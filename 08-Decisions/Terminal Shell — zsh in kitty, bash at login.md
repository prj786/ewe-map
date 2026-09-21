---
tags:
  - ewe-map
  - decisions
title: Terminal Shell — zsh in kitty, bash at login
up: "[[Decision Index]]"
---

# Terminal Shell — zsh in kitty, bash at login

**Decided 2026-09-21.** The interactive shell of the ewe terminal is **zsh**
with autosuggestions, syntax highlighting, extra completions, history substring
search, fzf, zoxide, eza and bat. The **login shell stays bash**.

## Why

- A machine installed from the package opened a bare bash prompt: only
  `install.sh` (phase 60) ever wrote the prompt into the rc files, the packaged
  path (`ewe-setup`) wrote nothing.
- Every piece is in the **official repos**, so it arrives as a dependency of the
  `ewe` package on both install paths. The prompt (oh-my-posh) is the one AUR
  name, and the [ewe] repo already builds it.
- No `chsh`: the packaged path cannot sudo, and scripts expect bash. kitty's
  `shell` points at `dotfiles/kitty/ewe-shell.sh`.

## What breaks if you undo a part

- **Remove the wrapper's fallback** and a machine without zsh cannot open a
  terminal at all.
- **Remove the wrapper's self-heal** (it runs `shell-setup.sh` when `~/.zshrc`
  has no ewe block) and zsh opens its new-user questionnaire instead of a prompt.
- **Drop `-i` from compinit** and any directory compaudit calls insecure stops
  every new terminal on a yes/no question.
- **Edit rc files anywhere but `dotfiles/shell/shell-setup.sh`** and the two
  install paths drift again. It owns the one marked block per rc file, migrates
  the old phase-60 prompt block, keeps the mise block, backs up once.
- Opt-out is a contract: `~/.config/ewe/shell` containing `bash`, or
  `EWE_SHELL=bash`.

## Testing without installing anything

zsh, its plugins and fastfetch are not on the dev box. `pacman -Sp <pkgs>` prints
the package URLs without root; unpack them into a scratch root and overlay it on
`/usr` with `bwrap --overlay-src /usr --overlay-src <root>/usr --ro-overlay /usr`
and a throwaway HOME (bind the HOME **after** `--tmpfs /tmp`). zsh must get a
pseudo-terminal (`script -qefc`), or it is not interactive and skips `~/.zshrc`.
`tests/ewe-shell-test.sh` covers the wiring and the wrapper (16 checks).

neofetch is gone from the Arch repos; **fastfetch** replaces it (alias kept),
with the logo as a PNG over kitty's graphics protocol and a braille text logo
elsewhere (`dotfiles/fastfetch/`).
