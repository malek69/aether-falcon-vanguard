<p align="center"><img src="docs/logo_vanguard.png" alt="AETHER FALCON: VANGUARD"></p>

<p align="right"><a href="README.md">Polski</a> | <strong>English</strong> | <a href="CHANGELOG_EN.md">Changelog</a> | <a href="docs/archive/">Archive v0.1.x</a></p>

<div align="center">
  <h1>AETHER FALCON: VANGUARD / EXOPLANET FRONTIER — v0.2.0.0</h1>
  <p><strong>Dedicated MC68040 Assembly 3D Engine for THEA1200 (320×256 AGA / 256 Colors)</strong></p>
</div>

---

> **Project Restart Note (`v0.1.x` → `v0.2.0.0`):** The previous `v0.1.x` prototype (tied to legacy `68020` constraints and patched demo code) hit a dead end — we could not push it to the required quality, so we wiped the codebase and **started from scratch** targeting **THEA1200 (MC68040 + Fast RAM + AGA)**. Legacy files and screenshots have been moved to [docs/archive/](docs/archive/).

---

## Downloads (`v0.2.0.0` — THEA1200)

| Profile (`--profile`) | Target Platform | Download Packages |
| :--- | :--- | :--- |
| **THEA1200 (`--profile thea1200`)** | **THEA1200**, **Amiberry**, **FS-UAE** — Full PAL **`320×256` AGA (256 colors)**, **`-m68040`** | [.LHA (WHDLoad)](docs/AetherFalcon_AGA_THEA1200.lha) · [.ZIP (FS-UAE / WinUAE)](docs/AetherFalcon_AGA_THEA1200_FSUAE.zip) |

---

## Gallery `v0.2.0.0` (68040 THEA1200 Engine Skeleton)

| ![1. Title Menu: 3 Roles & Load Colony](docs/screenshots/v020_01_menu.png) | ![2. 360° Voxel Space 3D Flight: Ship, Radar & FPS](docs/screenshots/v020_02_flight.png) |
|:---:|:---:|
| **1. Title Menu: Role Selection (`1–3`) & Load Save (`4`)** | **2. 360° Voxel Space 3D Flight: Ship, 256×256 Radar & HUD** |

---

## Implemented in `v0.2.0.0` (Current Skeleton)
- **360° Voxel Space 3D Terrain Engine (`MC68040`):** full `320×256 AGA` resolution, distance fog (`Z-Fog`), and terrain depth buffer (`vx_ybuf`).
- **Title Menu & Campaign Flow (`src/exo_menu.i`):** New Campaign with 3 roles (**`1: PIONEER`**, **`2: GUARDIAN`**, **`3: ENGINEER`**) or Load Saved Colony (**`4: LOAD SAVED COLONY`**).
- **Persistent Disk Save/Load (`src/exo_save_load.i`):** saves world state to `data/colony.sav` (auto-save on base activation + manual save via `S`).
- **HUD, Radar & Audio (`src/exo_ship_hud.i`, `src/exo_world_objs.i`, `src/exo_sound.i`, `src/exo_victory.i`):** `256×256` minimap, progress bar, live `FPS` counter, clean `.MOD` soundtrack (`data/exo_theme.mod`), and Paula DMA SFX.
