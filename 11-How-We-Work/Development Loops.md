---
tags:
  - ewe-map
  - how-we-work
title: Development Loops
up: "[[Home]]"
---

# Development Loops — how to iterate safely

The golden rule (from `ewe/CLAUDE.md`):

> **Work in the repo, then push — do not edit the live `~/.config`.** The
> repo is developed on a non-Arch dev host and deployed by pulling +
> re-running `install.sh` inside a throwaway QEMU/KVM Arch VM. Everything
> must work from a clean `git clone`.

Also: **never run `dotfiles/quickshell/scripts/colorscheme.sh` against the
dev host** — it rewrites the real `~/.config` (GTK/Qt/cursor theming).

## The shell loop (no install, no wrecking your session)

The `run-ewe` skill (`.claude/skills/run-ewe/driver.sh`) nests a throwaway
Hyprland on its own Wayland socket and screenshots it with grim:

```bash
.claude/skills/run-ewe/driver.sh check          # luac -p on hyprland.lua + colors.lua
.claude/skills/run-ewe/driver.sh up             # nested compositor + shell; waits for "Configuration Loaded"
.claude/skills/run-ewe/driver.sh open settings  # toggle a surface + screenshot -> /tmp/hs-driver/<name>.png
.claude/skills/run-ewe/driver.sh targets        # list every IpcHandler target + function
.claude/skills/run-ewe/driver.sh log            # tail the shell's qs log (QML errors name file:line)
.claude/skills/run-ewe/driver.sh down
```

- **QML has no live reload** — after editing a `*.qml`: `down && up`, then
  `open <surface>`, then **read the PNG**. A ~15 KB shot = bar only (the
  surface didn't open); a real window is ~40–57 KB.
- A QML error makes `qs` die on `up` — inspect via `log`. Ignore the benign
  "already registered" D-Bus / PolkitAgent / "hyprland-guiutils not
  installed" warnings (artifacts of nesting beside a live session).
- Sandboxing: the driver sandboxes HOME/XDG and generates the tokens itself
  (`HS_SCHEME=ewe-light`, `HS_CONF=<ewe.conf>`), so the live config and
  ewe-conf's sync hooks are never touched. `HS_PLUGINS=1` seeds the bundled
  plugins; `HS_NO_APPS=1` hides Komble/ewe-settings so the in-shell
  fallbacks open.
- `ewe-plugin` verbs restart the host's `ewe.service` unless given
  `--no-restart` — systemctl is not sandboxed; use the driver for plugin
  UI work.

After editing shell scripts: `bash -n <file>`.

## The installer loop

```bash
bash install.sh --dry-run     # print every action, change nothing
bash install.sh --check-only  # only phase 90's green/red checklist
bash install.sh               # full install (prompts before each change)
bash install.sh --yes         # unattended
bash install.sh --gaming      # opt-in gaming stack (multilib + lib32 GPU)
bash install.sh --dev         # opt-in front-end dev toolchain
```

- Full install/greeter/bootsplash testing: **throwaway QEMU/KVM Arch VM**.
  Don't test the installer on a machine you care about.
- Installer invariants: every mutating action through `run()`/`sudo_run()`
  (that's what makes `--dry-run` honest); package failures **warn-and-skip**,
  never abort; the run is re-runnable.

## The Tauri app loops (Komble / ewe-settings / ewe-sync)

```bash
npm install
npm run tauri dev     # dev — note Komble's polkit fallback: pkexec per action
npm run tauri build   # release binary
```

- Komble packaging: `makepkg -si` (the PKGBUILD is the packaging path —
  installs polkit policy + helper).
- `.dev-mock/` folders exist in ewe-settings / ewe-sync / komble-arch for
  mock data during frontend work.

## The ISO loop

```bash
sudo pacman -S archiso
sudo ./build.sh        # → out/ewe-0.1-alpha-x86_64.iso
./run-iso.sh           # boot in QEMU/KVM (UEFI)
```

## Git etiquette

- **Pushing requires the user's 1Password SSH agent (must be unlocked):**
  `SSH_AUTH_SOCK=/home/<user>/.1password/agent.sock git push origin main`
- **Commit/push only when asked.** Branch off if on the default branch
  otherwise.
- Commits: scoped, descriptive (`fix(kitty): …`, `feat(theme): …`), one
  concern per PR; before/after screenshots for anything visible.

## Related

- [[Testing and QA]] · [[Release Checklist]] · [[Worktrees and Screenshots]] ·
  [[Conventions]]
