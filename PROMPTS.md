# Aether Falcon: Vanguard — Specyfikacja i Prompty dla AI

## 1. Wizja gry i założenia projektowe (GDD Core)
* **Tytuł:** *Aether Falcon: Vanguard* (premiera pod **THEA1200** od Retro Games Ltd. — 15 grudnia 2026)
* **Gatunek:** **Fabularny open-world sci-fi o kolonizacji obcej planety** (widok TPP zza pojazdu + okna dialogowe z 4 portretami postaci + dziennik pokładowy z mapą topograficzną).
* **Rola gracza:** Zwykły człowiek — mały trybik w wielkiej machinie kolonizacyjnej. Wybiera jedną z 3 profesji początkowych (**1: PIONIER / PIONEER**, **2: STRAŻNIK / GUARDIAN**, **3: INŻYNIER / ENGINEER**), wykonuje dynamiczne kontrakty w otwartym świecie, zbiera logi z czarnych skrzynek, rozwija statek za kredyty i decyduje o losie planety w finale Aktu III.
* **Rola pojazdu:** Służbowy pojazd wielozadaniowy do spokojnej eksploracji i pracy w otwartym świecie 360° (zawis pod `X`, przepustnica `Q`/`E`, narzędzie robocze/skaner/wiązka pod `F`).
* **Czystość licencyjna:** Wszystkie zasoby graficzne, siatki 3D, tekstury, portrety i teksty są w 100% autorskie lub generowane proceduralnie przez narzędzia w `tools/`.

## 2. Docelowy sprzęt, wersje językowe i środowisko
* **Platforma docelowa:** **THEA1200** / **Amiga 1200 (AGA)** z procesorem **Motorola 68040**, pamięcią **Fast RAM** (min. 4–8 MB), **Chip RAM** (2 MB) oraz dyskiem twardym (WHDLoad `.lha`).
* **Sterowanie:** Głównie **Klawiatura + Mysz** z automatycznym przełączaniem w locie na **Pad THEA1200** (`input_pad_mode`).
* **Dwie oddzielne wersje językowe (100% odseparowane pakiety HDD):**
  * Polska (`--profile thea1200_pl` oraz domyślne `--profile thea1200`): ładuje `data/story_pl.bin` jako `data/story.bin` z pełnymi polskimi znakami (`Ą Ć Ę Ł Ń Ó Ś Ź Ż`).
  * Angielska (`--profile thea1200_en`): ładuje `data/story_en.bin` jako `data/story.bin` (generowana 1:1 z tego samego źródła w `tools/build_story.py`).
* **Generator otwartego świata:** `python3 tools/gen_open_world.py --seed <liczba>` tworzy `data/exo_voxel.bin` + `data/world_seed.bin` (8 baz, 8 anomalii, biomy pustynne i Morze Aetheru).
* **Lokalny test emulatora:** `~/Pulpit/AetherFalcon_THEA1200.sh` (uruchamiać wyłącznie na wyraźne polecenie użytkownika).

## 3. Krytyczne reguły techniczne silnika (pułapki do uniknięcia)
1. **Dysk twardy (`dos.library`) a `sys_takeover`:** Wszelkie ładowanie plików z dysku (`story_load_from_hdd`, `open_world_load_seed`) MUSI wykonywać się **przed** `sys_takeover`, a po wywołaniu `dos.library` w trakcie gry (`F5`) należy przywrócić `Forbid()`, wyłączyć przerwania systemowe (`move.w #$7fff,$9a(a5)`) oraz odświeżyć `copper_ptr` (`$dff080`).
2. **Tablica `sin_tab` (`src/aether_falcon.s`):** zaczyna się od `cos(0) = 256` (indeks `0`), a `sin(0) = 0` leży pod indeksem **192**. Neutralna orientacja pojazdu gracza to **`d0 = 192, d1 = 198, d2 = 192`**, a obiektów w świecie **`192`**.
3. **Format siatek 3D i tekstur (`aura3d_v2.i`):** każdy trójkąt zajmuje **8 bajtów: `[i0.w, i1.w, i2.w, tex_id.w]`**, gdzie `tex_id` wybiera teksturę `64×64` (`4096 B`) z `data/exo_textures.bin`, a oświetlenie przechodzi przez 4096-bajtową tablicę `data/exo_shadelut.bin`. Z-bufor (`vec3d_clear_zbuf_fast`) czyścimy **przed** `exo_update_and_draw_world`.
4. **Paleta AGA (`data/exo_pal256.bin`):** `0..95` niebo, `96..127` stal/tytan, `128` tło UI, `130..159` błękit/ocean (`136..142`), `160..191` terakota/ochra/piasek lądu (`169..187`).
5. **Klawiatura i rejestr `moveq`:** Odczyt CIA-A oparty na `$BFEC01` + `kbd_last_sdr` + ACK `$BFEE01`. Zapis pod **F5 (`$54`)**, dziennik/mapa pod **`J` (`$26`) / `L` (`$28`) / `Tab` (`$42`)**, przepustnica **`Q`/`E`**, zawis **`X`**, narzędzie/wiązka **`F`**, nastrój AGA **`M` (`$37`)**. Dla pętli `>= 128` używać `move.w` zamiast `moveq`!
6. **Powłoka systemowa:** użytkownik korzysta z **fish** (używać `python3 -c` oraz `and`, nie używać heredoc `EOF` ani `&&`).

---

## Prompt 1: Kontekst bazowy, architektura i twarde reguły silnika (wklejaj na start nowej sesji)

~~~text
Pracujemy nad grą Aether Falcon: Vanguard w repozytorium ~/aether-falcon-vanguard na premierę THEA1200 (15 grudnia 2026).
Najpierw przeczytaj plik PROMPTS.md w katalogu głównym repozytorium i bezwzględnie przestrzegaj zapisanych w nim reguł silnika, licencji (100% autorskie zasoby) oraz składni powłoki FISH.

Aktualna architektura modułów w src/ i tools/:
- src/aether_falcon.s: główna pętla, wczytanie story.bin i world_seed.bin przed sys_takeover, 4096B exo_shadelut.bin.
- src/story_engine.i + tools/build_story.py: dwujęzyczny system fabularny PL/EN (polskie znaki ĄĆĘŁŃÓŚŹŻ w exo_font_5x7), akty I-III, logi czarnych skrzynek i dziennik pod J/L/Tab.
- src/open_world.i + tools/gen_open_world.py: generator otwartego świata (SEED), kontrakty między bazami i anomaliami, kompas nawigacyjny na HUD, ulepszenia napędu za CR i mapa topograficzna 64x64.
- src/exo_ship_hud.i + src/exo_ship_mesh.i: autorski myśliwiec 3D (34v/53t) z teksturami 64x64 (data/exo_textures.bin).
- src/exo_sound.i + tools/gen_soundtrack.py: kompozytor ProTracker .MOD (`data/exo_intro.mod` dla Prologu/Menu/Epilogu oraz `data/exo_theme.mod` dla eksploracji świata) doczytywane na bieżąco z HDD przez `dos.library` prosto do `mod_data` w Chip RAM + efekty SFX Paula.
- src/exo_menu.i: filmowy Prolog fabularny przed menu wyboru zawodu (`exo_run_story_prologue`) oraz pełnoekranowy Epilog po finale Aktu III (`exo_run_story_epilogue`).
- src/exo_world_objs.i + src/cinematic_fx.i: 8 baz 3D na gruncie, drony, 4 portrety AGA (data/exo_portrait.bin), dialogi 3-opcjowe i finał Aktu III.
- Kompilacja: python3 tools/build_game.py --profile thea1200_pl (oraz thea1200_en / thea1200).

Potwierdź odczytanie PROMPTS.md i czekaj na moje zadanie.
~~~
