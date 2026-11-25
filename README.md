# AETHER FALCON: VANGUARD (v0.0.2)

> **Polski** · [English](README_EN.md)

Bare-metalowy symulator walki powietrznej 3D na **Amiga 1200 (AGA / M68020+)** i **THEA1200** w 100% w asemblerze M68k (`vasmm68k_mot`).

## Wykorzystane Silniki (`refs/`)
- **AURA-3D AGA Engine (`refs/aura3d/`):** teren 3D (`terrain_3d.i`), myśliwiec XF-14 (`aura3d_v2.i`), 256-kolorowe C2P (`c2p_chunky.i`), niebo Coppera (`copper_sky.i`), smugi (`particle_trail.i`), flary (`lens_flare.i`), wejścia (`input_ctrl.i`), czcionka 5x7 (`hud_fps.i`) i muzyka `.MOD` (`pt_player.i`).
- **Amiga 1200 Vector Engine (`refs/vector/`):** architektura ekranów taktycznych (*Intro*, *Briefing*, *Debriefing* w `src/af_campaigns.i`) we wspólnym buforze 256 kolorów AGA.

## Profile Wydawnicze (`python3 tools/build_game.py --profile all`)
- `standard` (`_020`): Amiga 1200 68EC020 + Fast RAM (`320x128`)
- `thea1200` (`_THEA1200`): THEA1200 / Amiberry / FS-UAE (`320x256 -DFULL_RES`)
- `060` (`_060`): Karty turbo MC68060 (`320x256 -DFULL_RES -DM68060`)

## Sterowanie
- **Strzałki / Joy2:** przechył (Roll), skręt (Yaw) i wysokość (Pitch)
- **Spacja / Enter / Fire / RMB:** start misji, salwa rakiet Lock-On, dopalacz
- **ESC / LMB:** wyjście do AmigaOS
