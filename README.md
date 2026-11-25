<p align="center"><img src="docs/logo_vanguard.png" alt="AETHER FALCON: VANGUARD"></p>

<p align="right"><strong>Polski</strong> | <a href="README_EN.md">English</a> | <a href="CHANGELOG.md">Changelog</a></p>

<div align="center">
  <h1>AETHER FALCON: VANGUARD v0.1.3.1</h1>
  <p><strong>Bare-metalowy symulator walki powietrznej 3D dla Commodore Amiga 1200 (M68020+ / AGA / 256 Colors) &amp; THEA1200</strong></p>
  <p>
    <a href="docs/">Pobierz .LHA</a> &bull;
    <a href="docs/">Pobierz FS-UAE .ZIP</a> &bull;
    <a href="CHANGELOG.md">Changelog</a>
  </p>
</div>

---

## Pobieranie (v0.1.3.1 — 3 Profile Sprzętowe)

| Obóz / Profil (`--profile`) | Platforma docelowa | Paczki do pobrania |
| :--- | :--- | :--- |
| **1. Standard `020` (`--profile standard`)** | Bazowa **Amiga 1200 (`68EC020`)** + Fast RAM — tryb **`320×128`** | [.LHA](docs/) · [.ZIP (FS-UAE/WinUAE)](docs/) |
| **2. THEA1200 (`--profile thea1200`)** | Konsola **THEA1200**, **Amiberry (PC)**, **FS-UAE** — pełny PAL **`320×256`** **16:9 Widescreen** (`-DFULL_RES -DWIDESCREEN_16_9`) | [.LHA](docs/) · [.ZIP (FS-UAE/WinUAE)](docs/) |
| **3. Turbo 060 (`--profile 060`)** | **Amiga 1200 + Blizzard/Apollo 1260** (`MC68060`) — pełny PAL **320×256** **16:9** (`-m68060 -DM68060`) | [.LHA](https://github.com) · [.ZIP](https://github.com) |

---

## Wideo z Rozgrywki (v0.1.3.1 — Gameplay & Silnik 3D)

https://github.com

## Galeria Animacji Rotoskopowych *Eon* (TBL) — Silnik Wektorowy (v0.1.3.1)

| ![1. Akt I: Salute to the Sky](docs/screenshots/v013_eon_01.png) | ![2. Akt II: Baza Solis (Styl Eon)](docs/screenshots/v013_eon_02.png) | ![3. Akt III: Kokpit XF-14](docs/screenshots/v013_eon_03.png) |
|:---:|:---:|:---:|
| **1. Akt I: Salute to the Sky** | **2. Akt II: Baza Solis (Styl Eon)** | **3. Akt III: Kokpit XF-14** |
| ![4. Akt IV: Start 3D XF-14](docs/screenshots/v013_eon_04.png) | ![5. Briefing: Dowódca Eskadry](docs/screenshots/v013_eon_05.png) | ![6. Debriefing: Portret Pilota 3/4](docs/screenshots/v013_eon_06.png) |
|:---:|:---:|:---:|
| **4. Akt IV: Start 3D XF-14** | **5. Briefing: Dowódca Eskadry** | **6. Debriefing: Portret Pilota 3/4** |

## Galeria v0.1.3.1 — Tablica Odpraw, Chmury 3D i Licznik SCORE w HUD

| ![1. Tablica Odpraw Taktycznych (Briefing)](docs/screenshots/v010_01_briefing_board.png) | ![2. Lot 3D: Chmury 3D, Woksele i SCORE w HUD](docs/screenshots/v010_02_hud_score_clouds.png) |
|:---:|:---:|
| **1. Tablica Odpraw Taktycznych (Briefing)** | **2. Chmury 3D, Teren Wokselowy i SCORE: 002350** |

## Wykorzystane Silniki i Powiązane Repozytoria

| Logo | Silnik i Repozytorium | Rola w projekcie |
| :---: | :--- | :--- |
| <a href="docs//malek69//aura3d-aga-engine"><img src="docs/logo_aura3d.png" alt="AURA-3D AGA Engine" width="180" /></a> | **[AURA-3D AGA Engine](docs//malek69//aura3d-aga-engine)** | Główny potok 3D (`STATE_GAMEPLAY`), teren wysokościowy (`terrain_3d.i`), myśliwiec **XF-14 Albatros** (`aura3d_v2.i`), C2P 256 kolorów (`c2p_chunky.i`), niebo Coppera (`copper_sky.i`), smugi (`particle_trail.i`), flary (`lens_flare.i`), sterowanie (`input_ctrl.i`), czcionka 5x7 (`hud_fps.i`) oraz audio `.MOD` (`pt_player.i`). |
| <a href="docs//malek69//amiga1200-vector-engine"><img src="docs/logo_vector.png" alt="Amiga 1200 Vector Engine" width="180" /></a> | **[Amiga 1200 Vector Engine](docs//malek69//amiga1200-vector-engine)** | Architektura ekranów taktyczno-wektorowych (**Intro**, **Briefing** z mapą sektora i **Debriefing** z oceną pilota w `src/af_campaigns.i`), zintegrowana ze wspólnym buforem 256 kolorów AGA. |
---

## Fabuła i Kampania (3 Misje)

Jako pilot elitarnej eskadry **Vanguard** startujesz myśliwcem przechwytującym **XF-14 Albatros** z pokładu bazy lotniczej (lotniska) **Solis**, aby powstrzymać inwazję **Dominium Vespera** na Konfederację Solis:

1. **Misja 01 — Sargas Archipelago:** Lot patrolowy nad archipelagiem, zbieranie rozproszonych **Rdzeni Eteru** i przechwytywanie eskadr zwiadowczych Vespera lecących w formacji spiralnej 360°.
2. **Misja 02 — Krell Storm Canyon:** Szybki przelot przez burzowy kanion Krell, gdzie przeciwnicy atakują w podwójnej helisie 360° i wymagają salw rakiet *Multi-Lock*.
3. **Misja 03 — Leviathan Citadel:** Ostateczny szturm na flagową **Latającą Fortecę Lewiatan** 3D unoszącą się w centrum tunelu, zasilaną przez **4 wirujące reaktory**.

---

## Obiekty w Przestrzeni 3D — Do Czego Strzelać, a Co Zbierać?

| Obiekt 3D | Wygląd i zachowanie | Zadanie pilota |
| :--- | :--- | :--- |
| **Myśliwce Vespera (*Vespera Interceptors*)** | Ciemne myśliwce 3D lecące dziobem w Twoją stronę; celownik automatycznie nakłada na nie ramkę **Lock-On**. | **Zestrzeliwać** — działkami plazmowymi ze skrzydeł i rakietami samonaprowadzającymi (*Multi-Lock*). |
| **Rdzenie Eteru (*Ether Cores*)** | Wirujące, błękitno-turkusowe kryształy 3D (oktaedry) unoszące się w tunelu. | **Nie strzelać — zbierać!** Przelot blisko kryształu regeneruje **+40 energii tarczy** i dodaje **+250 pkt**. |
| **Ogniste pociski wroga** | Czerwono-białe kule energii lecące z głębi tunelu przez Twoją pozycję aż za krawędź ekranu. | **Unikać** na okręgu 360° — każde trafienie zabiera **25 pkt tarczy** (`SHIELD HIT!`). |
| **Boss Lewiatan i 4 Reaktory (Misja 03)** | Wielobryłowa forteca 3D w centrum tunelu otoczona **4 wirującymi kryształami reaktorów**, strzelająca promieniowo. | **Namierzać i niszczyć 4 reaktory** (każdy wymaga 2 trafień), aby odnieść zwycięstwo w kampanii. |

---

## Sterowanie (Lot po Okręgu 360°)

- **Strzałki Lewo / Prawo** lub **Joystick Port 2:** lot po pełnym okręgu **360°** (dziób myśliwca zawsze w środek ekranu, brzuch na zewnątrz, skrzydła stycznie wzdłuż okręgu)
- **Strzałki Góra / Dół** lub **Joystick Port 2:** przybliżenie do środka tunelu (Góra) lub oddalenie ku krawędzi ekranu (Dół) bez pochylania kadłuba
- **Spacja / Enter / Fire / RMB:** start misji, ogień z podwójnych działek plazmowych, salwa rakiet **Multi-Lock** oraz dopalacz (*Afterburner*)
- **H / L:** panel pomocy (`HELP`) w locie oraz przełącznik języka HUD (`PL` / `EN`)
- **ESC / LMB:** zapis rekordu (`hiscore.dat`) i wyjście do AmigaOS / WHDLoad

---

## Kompilacja ze Źródeł

```bash
python3 tools/build_game.py --profile all
```

Szczegółowy rejestr zmian znajduje się w pliku [CHANGELOG.md](CHANGELOG.md).

## Narzędzia Budowania i Generatory Zasobów (`tools/`)

| Skrypt | Rola w projekcie |
|:---|:---|
| `tools/build_game.py` | Główny skrypt kompilacji (`vasmm68k_mot`) i pakowania archiwów `.LHA` oraz paczek FS-UAE/WinUAE `.ZIP` dla profili `standard` i `thea1200`. |
| `tools/gen_aga_airbase_scenes.py` | Generator pełnoekranowych teł bazy lotniczej 256 kolorów AGA (`data/bg_airbase.bin`, `320×256`) oraz spriteów (`data/spr_moto.bin`) kwantyzowanych do palety `pal256.bin`. |
| `tools/gen_vanguard_mod.py` | Generator autorskiej 4-kanałowej ścieżki dźwiękowej ProTracker `.MOD` (`data/vanguard_anthem.mod`) wolnej od praw autorskich. |

---

## Możliwości Silnika Graficznego (AURA-3D AGA + Vector Engine)

- **Rasteryzacja 3D w czasie rzeczywistym (M68020+):** cieniowanie **Gouraud** oraz **Environment Mapping** z 16-bitowym **Z-Bufferem**, obsługą tekstur i automatycznym przycinaniem brył.
- **Natywny tryb 256 kolorów AGA & C2P:** konwersja *Chunky-to-Planar* (`320×128` dla bazowej Amigi 1200 oraz pełny PAL `320×256` **16:9 Widescreen** dla THEA1200/FS-UAE) z dynamicznym gradientem nieba **Copper**.
- **Teren 3D i efekty cząsteczkowe:** generowany proceduralnie korytarz kanionu 3D, podwójne smugi silników, flary soczewkowe (*Lens Flare*), płaskie cienie (*Planar Shadows*) oraz wielopunktowe eksplozje 3D.
- **Hybrydowy potok wektorowo-poligonowy:** szybki rasteryzer wielokątów N-gon (`16.16` fixed-point) dla ekranów fabularnych (**Intro**, **Briefing**, **Debriefing / Game Over**) współdzielący bufor 256 kolorów AGA oraz 4-kanałowe audio **Paula** (`.MOD` + efekty `SFX`).
- **Wielotonowe sceny rotoskopowe w stylu *Eon* (The Black Lotus) (`src/af_vector_scenes.i`):** bezkonturowy odtwarzacz wielokatow `af_play_eon_scene` dla ekranow **Intro** (sylwetka pilota z uniesiona piescia na srebrnym niebie), **Briefing** (portret dowodcy obok tablicy odpraw) oraz **Debriefing / Game Over** (portret pilota 3/4 z bocznym swiatlem).
- **Chmury 3D, cienie i HUD na zywo (`src/af_voxel_world.i`, `src/af_gameplay_3d.i`):** 16 wielowarstwowych formacji chmur 3D dopasowanych do klimatu misji, aktywne cieniowanie `Phong + Z-Fog`, cien rzucany pod mysliwcem XF-14 oraz licznik **`SCORE: 000000`** i wskaznik **`M1/3`** w lewym gornym rogu HUD.
- **Strumieniowe wczytywanie i zapis danych z dysku (`dos.library` / `src/af_disk_loader.i`):** dynamiczne ładowanie zasobów z katalogu `data/` (`missions.dat`, tła 256-kolorowe `bg_airbase.bin`, `title.chk`/`title.pal`, sprite’y `spr_moto.bin`, moduł muzyczny `vanguard_anthem.mod`, sample `intro.pcm`) bezpośrednio do Fast/Chip RAM przed przejęciem sprzętu AGA, oraz trwały zapis rekordu punktowego (`data/hiscore.dat`) po zakończeniu gry.

## Konwersja Modeli 3D z Plików Wavefront `.OBJ`

Silnik zawiera gotowe konwertery pozwalające zaimportować dowolny model 3D `.OBJ` z internetu do kodu asemblera M68k:

```bash
python3 tools/mesh_conv.py --obj assets_raw/vespera_interceptor.obj --out src/custom_mesh.i --prefix custom --radius 42 --tex 0
```

## Konwerter Wideo / YouTube na PCM i Dane Wektorowe (`tools/`)

W katalogu `tools/` znajduja sie narzedzia obu zintegrowanych silników (**AURA-3D AGA Engine** oraz **Amiga 1200 Vector Stream Engine**), w tym konwerter wideo (np. z YouTube przez `yt-dlp` / `ffmpeg`) na 8-bitowe audio PCM oraz strumien wielokatow wektorowych N-gon:

```bash
python3 tools/build_demo.py --video input.mp4 --fps 50 --threshold 128 --crop-43
```

## Pelny Zestaw Narzedzi Deweloperskich (`tools/` — 16 Skryptow)

| Skrypt | Silnik / Pochodzenie | Rola i mozliwosci |
| :--- | :--- | :--- |
| `tools/build_game.py` | **Aether Falcon** | Glowny potok budowania (`vasmm68k_mot`) paczek `.LHA` i `_FSUAE.zip` dla profili `standard` (`68EC020` `320x128`) oraz `thea1200` (`320x256` 16:9). |
| `tools/build_demo.py` | **Vector Engine** | Uniwersalny konwerter wideo na strumien wektorowy N-gon (`scene_data.i` z wycinaniem otworow XOR LUT) i 8-bit signed PCM audio Paula DMA (`--video`, `--fps`, `--threshold`, `--crop-43`, `--thin-lines`). |
| `tools/build_median.py` | **Vector Engine** | Dedykowany potok przetwarzania wideo (`624x496` -> `320x256` AGA + Blitter AA @ `50 FPS`, separacja 2 warstw kolorow, upraszczanie wielokatow i budowa `.LHA` / `.ZIP`). |
| `tools/profile_patch.py` | **Vector Engine** | Konfigurator trybow AGA Hi-Res (`640x256`) oraz Interlace (`640x512`) dla silnika wektorowego. |
| `tools/mesh_conv.py` | **AURA-3D** | Konwerter modeli 3D Wavefront `.OBJ` na natywne tablice wierzcholkow, normalnych i trojkatow M68k (wrogie mysliwce, Rdzenie Eteru, Boss Lewiatan). |
| `tools/obj2amiga.py` | **AURA-3D** | Alternatywny parser siatek `.OBJ` z normalizacja skali i obsluga wielu materialow. |
| `tools/png_to_aga.py` | **AURA-3D** | Konwerter plikow `.PNG` na tekstury `64x64` chunky (`--mode texture`) lub pelnoekranowe obrazy `320x256` w 8 bitplanach AGA + 24-bitowa paleta (`--mode bitplanes`). |
| `tools/gen_aga_airbase_scenes.py` | **Aether Falcon** | Generator pelnoekranowych tel bazy lotniczej 256 kolorow AGA (`data/bg_airbase.bin`, `320x256`) i przezroczystych spriteow (`data/spr_moto.bin`). |
| `tools/gen_topgun_mod.py` | **Aether Falcon** | Proceduralny generator 4-kanalowej sciezki dzwiekowej ProTracker `.MOD` (`data/vanguard_anthem.mod`) wolnej od praw autorskich. |
| `tools/fetch_mod.py` | **AURA-3D** | Narzedzie pobierajace i weryfikujace zewnetrzne moduly muzyczne ProTracker `.MOD`. |
| `tools/gen_phong_lut.py` | **AURA-3D** | Generator tablicy normalnych `phong_norm_lut.bin` do cieniowania Phonga oraz efektu *Fresnel Rim Glow*. |
| `tools/gen_recip_table.py` | **AURA-3D** | Generator 32-bitowej tablicy odwrotnosci `recip_table_32.bin` (`1/Z` w formacie `16.16` fixed-point bez dzielenia `divs.l`). |
| `tools/pack_scenes.py` | **AURA-3D** | Pakowacz zasobow scen i danych binarnych do wspolnych archiwow `.PAK`. |
| `tools/make_logo.py` | **AURA-3D** | Generator bitplanowych logotypow i naglowkow AGA z obrazow zrodlowych. |
| `tools/make_showcase.py` | **AURA-3D** | Narzedzie skladajace plansze prezentacyjne i podglady zasobow silnika. |
| `tools/build_aura3d_demo.py` | **AURA-3D** | Skrypt budujacy pelne 8-scenowe demo technologiczne **AURA-3D AGA Engine** (`.ADF`, `.LHA`, `_FSUAE.zip`). |

## Pelny Przeglad Modulow Silnikow (`src/` oraz `refs/`)

- **Silnik Wokselowy 3D (`src/af_voxel_world.i`):** raycaster *Voxel Space* (Y-buffer horyzontu) generujacy ocean, wyspy i gory (Misja 01), kanion gorski z rzeka (Misja 02) oraz wulkaniczny lad i bastiony cytadeli (Misja 03).
- **Potok 3D Gouraud / EnvMap (`refs/aura3d/engine/aura3d_v2.i`):** cieniowanie Gourauda + Environment Mapping z optymalizacja `bfextu` na M68020+, 16-bitowy Z-Buffer, blyski lustrzane (*Specular Highlights*), obsluga do 4 tekstur `64x64` na bryle oraz tablica odwrotnosci `1/Z`.
- **Dodatkowe Efekty 3D w `refs/aura3d/engine/`:** cieniowanie Phonga + *Fresnel Rim Glow* (`phong_norm_lut.bin`), falujaca tafla wody (`ground_grid.i`), lustrzane odbicia 3D na wodzie (`mirror_reflect.i`), cienie rzucane (`planar_shadow.i`), rozblyski soczewkowe (`lens_flare.i`), mgla glebi `Z-Fog`, 3D Vertex Morphing (`morph_target.i`) oraz smugi czasteczek (`particle_trail.i`).
- **Strumieniowe Wideo Wektorowe i PCM (`refs/vector/src/`):** dekoder skompresowanych klatek wielokatow N-gon z wycinaniem otworow (`scene_player.i` + `vec3d_engine.i`, 512 KB tablica XOR `fill_lut` w Fast RAM), strumieniowy odtwarzacz 8-bit signed PCM (`audio_player.i`, 4 kanaly Paula DMA IRQ Level 4 z wylaczonym filtrem LED) oraz tryby AGA Hi-Res `640x256` / Interlace `640x512`.
