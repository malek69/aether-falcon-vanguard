<p align="center"><img src="docs/logo_vanguard.png" alt="AETHER FALCON: VANGUARD"></p>

<p align="right"><a href="README.md">Polski</a> | <strong>English</strong> | <a href="CHANGELOG_EN.md">Changelog</a></p>

<div align="center">
  <h1>AETHER FALCON: VANGUARD v0.0.8</h1>
  <p><strong>Bare-metal 3D combat flight simulator for Commodore Amiga 1200 (M68020+ / AGA / 256 Colors) &amp; THEA1200</strong></p>
  <p>
    <a href="docs/">Download .LHA</a> &bull;
    <a href="docs/">Download FS-UAE .ZIP</a> &bull;
    <a href="CHANGELOG_EN.md">Changelog</a>
  </p>
</div>

---

## Downloads (v0.0.8 — 2 Hardware Profiles)

| Profile (`--profile`) | Target Platform | Download Packages |
| :--- | :--- | :--- |
| **1. Standard `020` (`--profile standard`)** | Stock **Amiga 1200 (`68EC020`)** + Fast RAM — **`320×128`** mode | [.LHA](docs/) · [.ZIP (FS-UAE/WinUAE)](docs/) |
| **2. THEA1200 (`--profile thea1200`)** | **THEA1200**, **Amiberry (PC)**, **FS-UAE** — full PAL **`320×256`** **16:9 Widescreen** (`-DFULL_RES -DWIDESCREEN_16_9`) | [.LHA](docs/) · [.ZIP (FS-UAE/WinUAE)](docs/) |

---

## Gallery (v0.0.8 — Amiga 1200 AGA / THEA1200)

| ![1. Intro: 256-col Airbase & Pilot](docs/screenshots/v007_01_gyruss_360_flight.png) | ![2. Intro: Cockpit Boarding](docs/screenshots/v007_02_formations_360.png) | ![3. Briefing & Tactical Notepad](docs/screenshots/v007_03_leviathan_boss_360.png) | ![4. 3D 360° Circular Orbit](docs/screenshots/v007_04_gameover_debrief.png) |
|:---:|:---:|:---:|:---:|
| **1. Intro: 256-col Airbase & Pilot** | **2. Intro: Cockpit Boarding** | **3. Briefing & Tactical Notepad** | **4. 3D 360° Circular Orbit** |

## Engines Used & Related Repositories

| Logo | Engine & Repository | Role in Project |
| :---: | :--- | :--- |
| <a href="docs//malek69//aura3d-aga-engine"><img src="docs/logo_aura3d.png" alt="AURA-3D AGA Engine" width="180" /></a> | **[AURA-3D AGA Engine](docs//malek69//aura3d-aga-engine)** | Core 3D gameplay pipeline (`STATE_GAMEPLAY`), heightmap terrain (`terrain_3d.i`), **XF-14 Albatros** fighter (`aura3d_v2.i`), 256-color C2P (`c2p_chunky.i`), Copper sky (`copper_sky.i`), trails (`particle_trail.i`), lens flare (`lens_flare.i`), controls (`input_ctrl.i`), 5x7 font (`hud_fps.i`), and `.MOD` player (`pt_player.i`). |
| <a href="docs//malek69//amiga1200-vector-engine"><img src="docs/logo_vector.png" alt="Amiga 1200 Vector Engine" width="180" /></a> | **[Amiga 1200 Vector Engine](docs//malek69//amiga1200-vector-engine)** | Tactical vector screen architecture (**Intro**, **Briefing** sector map, and **Debriefing** pilot rank evaluation in `src/af_campaigns.i`), unified into the 256-color AGA framebuffer. |
---

## Story & 3-Mission Campaign

As an ace pilot of the **Vanguard** wing, you launch your **XF-14 Albatros** interceptor from the carrier **Solis** to repel the **Vespera Dominion** invasion:

1. **Mission 01 — Sargas Archipelago:** Patrol over the archipelago, harvesting scattered **Ether Cores** and intercepting Vespera scout squadrons flying in 360° spiral formations.
2. **Mission 02 — Krell Storm Canyon:** High-speed run through Krell Storm Canyon against double-helix 360° enemy waves requiring *Multi-Lock* missile salvos.
3. **Mission 03 — Leviathan Citadel:** Final assault on the **Leviathan Flying Fortress** 3D flagship hovering at the tunnel center, powered by **4 orbiting core reactors**.

---

## 3D Space Objects — Shoot vs. Collect

| 3D Object | Appearance & Behavior | Pilot Action |
| :--- | :--- | :--- |
| **Vespera Interceptors** | Dark angular 3D fighters flying nose-first toward you; automatically targeted by the **Lock-On** reticle. | **Destroy** using twin wingtip plasma cannons and *Multi-Lock* homing missiles. |
| **Ether Cores** | Rotating cyan-turquoise 3D octahedron crystals floating in the corridor. | **Do NOT shoot — collect!** Flying close absorbs the core, restoring **+40 shield energy** and awarding **+250 pts**. |
| **Enemy Plasma Bolts** | Red-white energy bolts fired from deep inside the tunnel past your ship off-screen. | **Evade** around the 360° circle — each hit drains **25 shield energy** (`SHIELD HIT!`). |
| **Leviathan Boss & 4 Reactors (Mission 03)** | Multi-hull 3D citadel at screen center surrounded by **4 orbiting crystal reactors** firing radial barrages. | **Lock onto and destroy all 4 reactors** (2 hits each) to win the campaign. |

---

## Controls (360° Cylindrical Flight)

- **Left / Right Arrows** or **Joystick Port 2:** fly around the full **360°** circle (nose always aimed at screen center, belly outward, wings tangent to the orbit)
- **Up / Down Arrows** or **Joystick Port 2:** move inward toward center (Up) or outward toward screen edge (Down) without pitching the hull
- **Space / Enter / Fire / RMB:** launch mission, fire twin plasma cannons, release **Multi-Lock** missile salvos, and engage afterburner
- **H / L:** toggle in-flight Help overlay (`HELP`) and HUD language (`PL` / `EN`)
- **ESC / LMB:** save high score (`hiscore.dat`) and exit to AmigaOS / WHDLoad

---

## Building from Source

```bash
python3 tools/build_game.py --profile all
```

See [CHANGELOG_EN.md](CHANGELOG_EN.md) for the complete version history.

## Build Tools & Asset Generators (`tools/`)

| Script | Role in the Project |
|:---|:---|
| `tools/build_game.py` | Master build pipeline (`vasmm68k_mot`) packaging `.LHA` and FS-UAE/WinUAE `.ZIP` archives for `standard` and `thea1200` profiles. |
| `tools/gen_aga_airbase_scenes.py` | Generator of full-screen 256-color AGA sunset airbase backdrops (`data/bg_airbase.bin`, `320×256`) and transparent sprites (`data/spr_moto.bin`) quantized to `pal256.bin`. |
| `tools/gen_vanguard_mod.py` | Procedural 4-channel ProTracker `.MOD` soundtrack generator (`data/vanguard_anthem.mod`) with royalty-free synth & drum samples. |
