# Changelog — AETHER FALCON: VANGUARD

## [0.0.2] - 2026-11-25
- **Unified 256-Color AGA Pipeline (`Intro -> Briefing -> 3D Gameplay -> Debriefing`):** unified vector/briefing screens in `chunky_buf` + AGA C2P with high-contrast HUD palette (`$FC..$FF`).
- **5x7 Font & HUD Primitives:** fixed 8-byte stride in `hud_ascii_5x7` and implemented 4-sided Lock-On reticle frames and filled emblem diamonds.
- **XF-14 Albatros & Dual Controls:** elevated fighter above 3D terrain (`Y=12, Z=22`), added keyboard flight/reticle controls (Arrows + Space) alongside Joy2, and enabled `-DM68060`.
- **Chip/Fast RAM & VBR Hardening:** allocated AGA bitplanes (`MEMF_CHIP`) and `fill_lut` (`MEMF_FAST`) via `Exec AllocMem` and read `VBR` via `Exec Supervisor()`.

## [0.0.1] - 2026-11-25
- Initial bare-metal skeleton for Amiga 1200 AGA / THEA1200 (XF-14 mesh, 3 missions, Lock-On, `.MOD` + Paula SFX).
