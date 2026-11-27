<p align="center"><img src="docs/logo_vanguard.png" alt="AETHER FALCON: VANGUARD"></p>

<p align="right"><a href="README.md">Polski</a> | <strong>English</strong> | <a href="CHANGELOG_EN.md">Changelog</a> | <a href="docs/archive/">Archive v0.1.x</a></p>

<div align="center">
  <h1>AETHER FALCON: VANGUARD / EXOPLANET FRONTIER — v0.2.1.0</h1>
  <p><strong>Dedicated MC68040 Assembly 3D Engine for THEA1200 (320×256 AGA / 256 Colors)</strong></p>
</div>

---

> **Project Restart Note (`v0.1.x` → `v0.2.1.0`):** The previous `v0.1.x` prototype (tied to legacy `68020` constraints and patched demo code) hit a dead end — we could not push it to the required quality, so we wiped the codebase and **started from scratch** targeting **THEA1200 (MC68040 + Fast RAM + AGA)**. Legacy files and screenshots have been moved to [docs/archive/](docs/archive/).

---

## Downloads (`v0.2.1.0` — THEA1200)

| Profile (`--profile`) | Target Platform | Download Packages |
| :--- | :--- | :--- |
| **THEA1200 (`--profile thea1200`)** | **THEA1200**, **Amiberry**, **FS-UAE** — Full PAL **`320×256` AGA (256 colors)**, **`-m68040`** | [.LHA (WHDLoad)](docs/AetherFalcon_AGA_THEA1200.lha) · [.ZIP (FS-UAE / WinUAE)](docs/AetherFalcon_AGA_THEA1200_FSUAE.zip) |

---

## Gallery `v0.2.1.0` (68040 THEA1200 Engine Skeleton)

| ![1. Title Menu: 3 Roles & Load Colony](docs/screenshots/v020_01_menu.png) | ![2. 360° Voxel Space 3D Flight: Ship, Radar & FPS](docs/screenshots/v020_02_flight.png) |
|:---:|:---:|
| **1. Title Menu: Role Selection (`1–3`) & Load Save (`4`)** | **2. 360° Voxel Space 3D Flight: Ship, 256×256 Radar & HUD** |

---

## Implemented in `v0.2.1.0` (Current Skeleton)
- **360° Voxel Space 3D Terrain Engine (`MC68040`):** full `320×256 AGA` resolution, distance fog (`Z-Fog`), and terrain depth buffer (`vx_ybuf`).
- **Title Menu & Campaign Flow (`src/exo_menu.i`):** New Campaign with 3 roles (**`1: PIONEER`**, **`2: GUARDIAN`**, **`3: ENGINEER`**) or Load Saved Colony (**`4: LOAD SAVED COLONY`**).
- **Persistent Disk Save/Load (`src/exo_save_load.i`):** saves world state to `data/colony.sav` (auto-save on base activation + manual save via `S`).
- **HUD, Radar & Audio (`src/exo_ship_hud.i`, `src/exo_world_objs.i`, `src/exo_sound.i`, `src/exo_victory.i`):** `256×256` minimap, progress bar, live `FPS` counter, clean `.MOD` soundtrack (`data/exo_theme.mod`), and Paula DMA SFX.

---

## Engine Architecture & Modules (`MC68040` / AGA)

The project combines two actively extended **MC68040** assembly engines synced inside `refs/aura3d/engine/`:

| Engine / Module | Source Files | Responsibility |
| :--- | :--- | :--- |
| **Voxel Space 3D Terrain Engine** | `src/aether_falcon.s`, `data/exo_voxel.bin` | Full `320×256 AGA` 360° raycasting, distance fog (`Z-Fog`), and 320-column terrain depth buffer (`vx_ybuf`). |
| **Gouraud / EnvMap & Vector 3D Engine** | `refs/aura3d/engine/aura3d_v2.i`, `vec3d_engine.i`, `src/exo_ship_hud.i` | Renders the player ship with wing banking, metallic shading, and `zbuf_3d` depth testing. |
| **AGA Hardware & Paula Audio Pipeline** | `gfx_engine.i`, `c2p_chunky.i`, `pt_player.i`, `src/exo_sound.i` | Bare-metal AmigaOS takeover, 8 AGA bitplanes (`256` colors), `c2p`, `.MOD` replayer, and Paula DMA SFX. |
| **Gameplay, Role Menu & Disk Save** | `src/exo_menu.i`, `exo_world_objs.i`, `exo_save_load.i`, `exo_victory.i` | Role selection (`1–3`), `256×256` radar, energy beam base activation, and `data/colony.sav` persistence via `dos.library`. |

---

## Build Tools (`tools/`) & THEA1200 Packaging

- **`tools/build_game.py --profile thea1200`:** compiles the game executable and WHDLoad slave (`vasmm68k_mot -m68040 -DFULL_RES -DWIDESCREEN_16_9`), packaging both **WHDLoad (`.lha`)** and **FS-UAE (`.zip`)** releases.
- **Directory Layout:** `src/` (game modules), `refs/aura3d/engine/` (core engines), `data/` (AGA palette, heightmap, `.MOD`, `colony.sav`), `tools/` (build scripts), `docs/archive/` (archived `v0.1.x` builds).

### Controls (`THEA1200` / Keyboard / Joystick)
- **Title Menu:** `1` (`PIONEER`), `2` (`GUARDIAN`), `3` (`ENGINEER`) — New Campaign; `4` — Load Saved Colony (`data/colony.sav`).
- **360° Flight:** `Arrows` / `Joystick` (360° yaw & altitude), `Space` / `Fire` (activate base beam / boost), `S` (save colony to disk), `ESC` / `LMB` (exit to OS).
