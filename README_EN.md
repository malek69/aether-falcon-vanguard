# AETHER FALCON: VANGUARD (v0.0.2)

> [Polski](README.md) · **English**

Bare-metal 3D combat flight simulator for **Amiga 1200 (AGA / M68020+)** and **THEA1200**, written 100% in M68k assembly (`vasmm68k_mot`).

## Engines Used (`refs/`)
- **AURA-3D AGA Engine (`refs/aura3d/`):** 3D heightmap terrain (`terrain_3d.i`), XF-14 fighter (`aura3d_v2.i`), 256-color C2P (`c2p_chunky.i`), Copper sky (`copper_sky.i`), trails (`particle_trail.i`), lens flare (`lens_flare.i`), controls (`input_ctrl.i`), 5x7 font (`hud_fps.i`), and `.MOD` player (`pt_player.i`).
- **Amiga 1200 Vector Engine (`refs/vector/`):** tactical vector screen architecture (*Intro*, *Briefing*, *Debriefing* in `src/af_campaigns.i`) unified into the 256-color AGA framebuffer.

## Build Profiles (`python3 tools/build_game.py --profile all`)
- `standard` (`_020`): Stock Amiga 1200 68EC020 + Fast RAM (`320x128`)
- `thea1200` (`_THEA1200`): THEA1200 / Amiberry / FS-UAE (`320x256 -DFULL_RES`)
- `060` (`_060`): MC68060 accelerators (`320x256 -DFULL_RES -DM68060`)

## Controls
- **Arrows / Joy2:** bank (Roll), turn (Yaw), and altitude (Pitch)
- **Space / Enter / Fire / RMB:** launch mission, Lock-On missile barrage, afterburner
- **ESC / LMB:** exit to AmigaOS
