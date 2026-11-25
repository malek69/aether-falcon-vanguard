# Changelog — AETHER FALCON: VANGUARD

## [0.0.2] - 2026-11-25
- **Pełny potok 256-kolorowy AGA (`Intro -> Briefing -> 3D Gameplay -> Debriefing`):** ujednolicono renderowanie ekranów wektorowych i odpraw w `chunky_buf` + C2P AGA z paletą HUD (`$FC..$FF`).
- **Czcionka 5x7 i prymitywy HUD:** poprawiono 8-bajtowy krok `hud_ascii_5x7` oraz 4-boczne ramki celownika *Lock-On* i romby emblemu.
- **Myśliwiec XF-14 Albatros i sterowanie:** podniesiono sylwetkę nad teren (`Y=12, Z=22`), dodano sterowanie z klawiatury (Strzałki + Spacja) obok Joy2 oraz flagę `-DM68060`.
- **Pamięć Chip/Fast RAM i VBR:** alokacja bitplanów AGA (`MEMF_CHIP`) i `fill_lut` (`MEMF_FAST`) przez `Exec AllocMem` oraz odczyt `VBR` przez `Exec Supervisor()`.

## [0.0.1] - 2026-11-25
- Pierwsza wersja szkieletu gry na Amiga 1200 AGA / THEA1200 (model XF-14, 3 misje, Lock-On, `.MOD` + Paula SFX).
