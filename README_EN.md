<p align="right"><a href="README.md">Polski</a> | <strong>English</strong> | <a href="CHANGELOG_EN.md">Changelog</a></p>

<div align="center">
  <h1>AETHER FALCON: VANGUARD v0.0.2</h1>
  <p><strong>Bare-metal 3D combat flight simulator for Commodore Amiga 1200 (M68020+ / AGA / 256 Colors) &amp; THEA1200</strong></p>
  <p>
    <a href="https://github.com">Download .LHA</a> &bull;
    <a href="https://github.com">Download FS-UAE .ZIP</a> &bull;
    <a href="CHANGELOG_EN.md">Changelog</a>
  </p>
</div>

---

## Downloads (v0.0.2 — 3 Release Profiles)

| Profile (`--profile`) | Target Platform | Download Packages |
| :--- | :--- | :--- |
| **1. Standard `020` (`--profile standard`)** | Stock **Amiga 1200 (`68EC020`)** + Fast RAM — **`320×128`** mode | [.LHA](https://github.com) · [.ZIP (FS-UAE/WinUAE)](https://github.com) |
| **2. THEA1200 (`--profile thea1200`)** | **THEA1200**, **Amiberry (PC)**, **FS-UAE** — full PAL **`320×256`** (`-DFULL_RES`) | [.LHA](https://github.com) · [.ZIP (FS-UAE/WinUAE)](https://github.com) |

---

## Gallery (v0.0.2 — Amiga 1200 AGA / THEA1200)

<table>
  <tr>
    <td align="center"><img src="docs/shot_v002_1.png" width="260" /><br/><sub><b>1. Title Screen / Intro</b></sub></td>
    <td align="center"><img src="docs/shot_v002_2.png" width="260" /><br/><sub><b>2. Mission Briefing</b></sub></td>
    <td align="center"><img src="docs/shot_v002_3.png" width="260" /><br/><sub><b>3. 3D Flight XF-14 &amp; Lock-On</b></sub></td>
  </tr>
</table>

---

## Engines Used & Related Repositories

| Logo | Engine & Repository | Role in Project |
| :---: | :--- | :--- |
| <a href="https://github.commalek69/aura3d-aga-engine"><img src="docs/logo_aura3d.png" alt="AURA-3D AGA Engine" width="180" /></a> | **[AURA-3D AGA Engine](https://github.commalek69/aura3d-aga-engine)** | Core 3D gameplay pipeline (`STATE_GAMEPLAY`), heightmap terrain (`terrain_3d.i`), **XF-14 Albatros** fighter (`aura3d_v2.i`), 256-color C2P (`c2p_chunky.i`), Copper sky (`copper_sky.i`), trails (`particle_trail.i`), lens flare (`lens_flare.i`), controls (`input_ctrl.i`), 5x7 font (`hud_fps.i`), and `.MOD` player (`pt_player.i`). |
| <a href="https://github.commalek69/amiga1200-vector-engine"><img src="docs/logo_vector.png" alt="Amiga 1200 Vector Engine" width="180" /></a> | **[Amiga 1200 Vector Engine](https://github.commalek69/amiga1200-vector-engine)** | Tactical vector screen architecture (**Intro**, **Briefing** sector map, and **Debriefing** pilot rank evaluation in `src/af_campaigns.i`), unified into the 256-color AGA framebuffer. |
---

## Controls

- **Left / Right Arrows** or **Joystick Port 2:** bank (`Roll`) and turn (`Yaw`) **XF-14 Albatros**
- **Up / Down Arrows** or **Joystick Port 2:** altitude and **Lock-On** reticle movement (`Pitch`)
- **Space / Enter / Fire / RMB:** launch mission, fire **Lock-On** missile barrage (up to 8 targets), afterburner
- **H / L:** toggle Help overlay (`HELP`) and HUD language (`PL` / `EN`)
- **ESC / LMB:** exit to AmigaOS / WHDLoad

---

## Building from Source

```bash
python3 tools/build_game.py --profile all
```

See [CHANGELOG_EN.md](CHANGELOG_EN.md) for the complete version history.
