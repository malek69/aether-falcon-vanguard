        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD - Reaktywny Swiat, Morale Kampanii i Adaptacyjny .MOD
; ============================================================================

        cnop    0,4
af_update_reactive_world:
        movem.l d0-d3/a0,-(sp)

        ; 1. Oblicz wskaznik intensywnosci walki i morale pilota
        ; Wysoki wynik / rdzenie = wysoka reputacja (1), niskie tarcze = kryzys (2)
        moveq   #0,d0
        cmp.w   #35,af_shield
        bge.s   .chk_ace
        moveq   #2,d0                   ; Kryzys / Red Alert!
        bra.s   .st_mood
.chk_ace:
        cmp.l   #2500,af_score
        blt.s   .st_mood
        moveq   #1,d0                   ; As Przestworzy (Wysokie morale)
.st_mood:
        move.w  d0,af_world_mood

        ; 2. Adaptacyjna muzyka ProTracker .MOD reagujaca na akcje w czasie rzeczywistym:
        ; - Intro / Briefing / Spokojny lot: pozycje 0..1
        ; - Walka z eskadrami: pozycje 2..7
        ; - Boss Lewiatan lub Krytyczne Tarcze (<35): pozycje 8..11
        move.w  af_state,d1
        cmp.w   #STATE_GAMEPLAY,d1
        bne.s   .calm_music

        cmp.w   #2,af_mission           ; Misja 03 = Boss Lewiatan
        beq.s   .boss_music
        cmp.w   #2,d0                   ; Red Alert (niskie tarcze)
        beq.s   .boss_music
        cmp.w   #1,af_lock_count        ; Namierzony cel (Lock-On) -> tryb bojowy
        bge.s   .combat_music

.calm_music:
        moveq   #0,d2
        bra.s   .apply_mod_zone
.combat_music:
        moveq   #2,d2
        bra.s   .apply_mod_zone
.boss_music:
        moveq   #8,d2

.apply_mod_zone:
        cmp.w   af_music_zone(pc),d2
        beq.s   .rw_done
        move.w  d2,af_music_zone
        ; Zmien pozycje utworu w odtwarzaczu pt_player (mt_SongPos)
        lea     mt_SongPos,a0
        move.b  d2,(a0)
.rw_done:
        movem.l (sp)+,d0-d3/a0
        rts

        cnop    0,4
af_world_mood:  dc.w    0               ; 0=Normal, 1=Ace/Heroic, 2=Crisis/RedAlert
af_music_zone:  dc.w    -1
