<p align="right"><strong>Polski</strong> | <a href="CHANGELOG_EN.md">English</a> | <a href="README.md">README</a></p>

# Changelog — AETHER FALCON: VANGUARD

Wszystkie istotne zmiany w projekcie **AETHER FALCON: VANGUARD** są dokumentowane w tym pliku.

---

## [v0.0.2] - 2026-11-25

- **Ujednolicony potok 256-kolorowy AGA (`Intro -> Briefing -> 3D Gameplay -> Debriefing`):** przeniesiono renderowanie ekranów wektorowych i odpraw misji do wspólnego bufora `chunky_buf` + C2P AGA z kontrastową paletą HUD (`$FC..$FF`).
- **Poprawka czcionki bitmapowej `5×7` i prymitywów HUD:** naprawiono 8-bajtowy krok znaków `hud_ascii_5x7` (bity `4..0`), wdrożono pełne 4-boczne ramki celownika **Lock-On** oraz wypełnione romby emblemu Konfederacji Solis.
- **Pozycja myśliwca XF-14 „Albatros” i sterowanie klawiaturą:** wyniesiono sylwetkę myśliwca wyraźnie ponad przewijany teren 3D (`Y=12`, `Z=22`), dodano pełne sterowanie lotem i celownikiem z klawiatury (`Strzałki + Spacja`) obok portu Joysticka 2 oraz flagę `-DM68060` dla profilu `060`.
- **Utwardzenie alokacji Chip/Fast RAM i wektora VBR:** przeniesiono bitplany AGA (`180 KB MEMF_CHIP`) oraz tablicę `fill_lut` (`512 KB MEMF_FAST`) do dynamicznej alokacji `Exec AllocMem`, dodano odczyt rejestru `VBR` przez `Exec Supervisor()` dla przerwania 50 Hz VBL oraz cache palety na ekranach menu.

---

## [v0.0.1] - 2026-11-25

- **Pierwsze wydanie szkieletu gry (Bare-Metal M68k):** implementacja maszyny stanów kampanii (`Intro -> Briefing -> Gameplay -> Debriefing`) oraz 3 misji (*Sargas Archipelago*, *Krell Storm Canyon*, *Leviathan Citadel*).
- **Autorski model 3D myśliwca XF-14 „Albatros”:** proceduralnie wygenerowana siatka 3D (`29` wierzchołków, `38` trójkątów wielomateriałowych z normalnymi do cieniowania Gouraud/Specular) oraz podwójna smuga spalin z dysz.
- **Mechanika rozgrywki i system Lock-On:** przelot nad terenem wysokościowym 3D, zbieranie Rdzeni Eteru, celownik 2D/3D z jednoczesnym namierzaniem do 8 celów i salwami samonaprowadzających rakiet.
- **Audio ProTracker `.MOD` + Paula SFX:** 4-kanałowy odtwarzacz muzyki połączony ze sprzętowym sterownikiem efektów dźwiękowych na kanale 3 układu Paula (`Lock-On`, salwa rakiet, zebranie Rdzenia Eteru).
- **System budowania 3 profili wydawniczych (`tools/build_game.py`):** automatyczna kompilacja paczek `.lha` (WHDLoad Slave v17 + ikonka `.info`) oraz `_FSUAE.zip` dla profili `standard` (`020`), `thea1200` (`FULL_RES`) i `060` (`MC68060`).
