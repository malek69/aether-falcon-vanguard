<p align="right"><a href="CHANGELOG.md">Polski</a> | <strong>English</strong> | <a href="README_EN.md">README</a></p>

# Changelog — AETHER FALCON: VANGUARD

All notable changes to **AETHER FALCON: VANGUARD** are documented in this file.

---

## [v0.0.3] - 2026-11-25

- **Hard Drive Support (`src/af_disk_loader.i` - `dos.library`):** loads campaign parameters (`missions.dat`), persistent high score (`hiscore.dat` saved automatically on exit), optional AGA title screen (`title.chk` + `title.pal`), and Paula PCM audio (`intro.pcm`) from `data/`, automatically bundled into `.lha` and `_FSUAE.zip` packages.
- ***Another World*-Style N-gon Vector Scene Engine (`src/af_vector_scenes.i`):** independent story AGA palette and backgrounds, fast `16.16` fixed-point N-gon polygon rasterizer with 32-bit `move.l` spans, animated **XF-14 Albatros** carrier launch *Intro*, and reactive *Briefing* / *Debriefing* screens.
- **Mission 03 Boss (*Leviathan Flying Fortress*) & 3D Particle Explosions:** multi-part citadel at the end of Mission 03 featuring **4 independent reactors** targeted via *Multi-Lock*, 3D debris bursts with Paula channel 3 explosion SFX, and full campaign progression (`Missions 01 -> 02 -> 03 -> Finale`).
- **FPS Optimization for Stock Amiga 1200 (`68EC020` 14 MHz):** reduced terrain mesh density from `16x13` to `12x10` with fast 32-bit painter spans bypassing Z-buffer overhead, selective `zbuf_3d` clearing strictly beneath the XF-14 fighter, and full `320x128` HUD/reticle coordinate alignment.

---

## [v0.0.2] - 2026-11-25

- **Unified 256-Color AGA Pipeline (`Intro -> Briefing -> 3D Gameplay -> Debriefing`):** unified vector and mission briefing screens into the shared `chunky_buf` + AGA C2P pipeline with high-contrast HUD palette indices (`$FC..$FF`).
- **Fixed `5×7` Bitmap Font & HUD Primitives:** corrected 8-byte stride decoding in `hud_ascii_5x7` (bits `4..0`), implemented full 4-sided **Lock-On** reticle frames, and added filled Solis Confederation emblem diamonds.
- **XF-14 "Albatros" Elevation & Keyboard Controls:** raised the interceptor mesh cleanly above the scrolling 3D heightmap terrain (`Y=12`, `Z=22`), added full keyboard flight and reticle controls (`Arrows + Space`) alongside Joystick Port 2, and enabled `-DM68060` for the `060` profile.
- **Chip/Fast RAM & VBR Hardening:** allocated AGA bitplanes (`180 KB MEMF_CHIP`) and `fill_lut` (`512 KB MEMF_FAST`) via `Exec AllocMem`, installed the 50 Hz VBL interrupt using `VBR` read via `Exec Supervisor()`, and cached palette uploads on menu screens.

---

## [v0.0.1] - 2026-11-25

- **Initial Bare-Metal M68k Skeleton:** implemented the campaign state machine (`Intro -> Briefing -> Gameplay -> Debriefing`) and 3 sorties (*Sargas Archipelago*, *Krell Storm Canyon*, *Leviathan Citadel*).
- **Original XF-14 "Albatros" 3D Fighter Mesh:** procedurally generated multi-material 3D mesh (`29` vertices, `38` triangles with vertex normals for Gouraud/Specular shading) and twin-nozzle particle trails.
- **Gameplay Loop & Multi-Lock System:** low-altitude 3D heightmap flyover, Ether Core energy harvesting, 2D/3D Lock-On reticle supporting up to 8 simultaneous target locks, and homing missile barrages.
- **ProTracker `.MOD` + Paula SFX Audio:** 4-channel `.MOD` soundtrack paired with a bare-metal Paula channel 3 sound effects driver (`Lock-On` ping, missile launch, Ether Core pickup).
- **3-Profile Release Build System (`tools/build_game.py`):** automated generation of `.lha` (WHDLoad Slave v17 + `.info` icon) and `_FSUAE.zip` archives for `standard` (`020`), `thea1200` (`FULL_RES`), and `060` (`MC68060`).
