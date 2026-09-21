---
tags:
  - ewe-map
  - decisions
title: One Mark — the line-art logo
up: "[[Decision Index]]"
---

# One Mark — the line-art logo

**Decided 2026-09-21.** The ringed line-art sheep (boot splash, greeter,
Welcome) is the only brand mark. It replaced the cartoon sheep head
(`sheep.svg`) in the dock, Quick settings, Settings and the side navigation of
Komble, ewe-settings and ewe-sync.

- The logo existed only as a PNG. It is now traced into vectors:
  `design/system/assets/Logos/ewe-mark.svg` (regular, 64px and up) and
  `ewe-mark-bold.svg` (the small placements). **Two weights, not two logos**:
  under 40px the regular weight's hairlines vanish.
- The shell's copy (`dotfiles/quickshell/assets/ewe-mark.svg`) is white and
  tinted by a `MultiEffect`; the apps inline the SVG (`fill="currentColor"`).
  The dock draws it 1.35x the plain glyphs beside it, because it carries inner
  detail.
- **The three launcher icons stay per-app** (gear, shepherd's crook, cloud
  sheep): they identify different apps in the dock and launcher; one shared
  icon would make them indistinguishable.
- Re-tracing: bitmap from the PNG's alpha (`-morphology Close Disk:14` then
  `Dilate Disk:7` for the bold cut), traced with `potracer` (pure Python, a
  virtualenv is enough). potracer fills the FALSE pixels of the mask you hand
  it: pass the inverse.
