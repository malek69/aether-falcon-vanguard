        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD - Reaktywny Swiat, Morale Kampanii i Adaptacyjny .MOD
; ============================================================================

        cnop    0,4
af_update_reactive_world:
        movem.l d0-d3/a0,-(sp)

        ; 1. Oblicz morale kampanii na podstawie trafien i wyniku pilota
        moveq   #0,d0
        tst.b   af_shield_flash
        beq.s   .chk_ace
        moveq   #2,d0                   ; Kryzys / Trafienie w tarcze!
        bra.s   .st_mood
.chk_ace:
        cmp.l   #2500,af_score
        blt.s   .st_mood
        moveq   #1,d0                   ; As Przestworzy (Wysokie morale)
.st_mood:
        move.w  d0,af_world_mood

        ; 2. Adaptacyjna muzyka ProTracker .MOD (pt_song_pos) reagujaca na akcje:
        ; - Intro / Briefing: pozycja 0 (Motyw wprowadzajacy)
        ; - Lot bojowy M1/M2: pozycja 2 (Motyw eskadry)
        ; - Boss Lewiatan (M3) lub trafienie w tarcze: pozycja 8 (Szturm)
        move.w  af_state,d1
        cmp.w   #STATE_GAMEPLAY,d1
        bne.s   .calm_music

        cmp.w   #2,af_mission           ; Misja 03 = Boss Lewiatan
        beq.s   .boss_music
        cmp.w   #2,d0                   ; Trafienie w tarcze -> eskalacja muzyki
        beq.s   .boss_music
        moveq   #2,d2                   ; Lot bojowy
        bra.s   .apply_mod_zone

.calm_music:
        moveq   #0,d2
        bra.s   .apply_mod_zone
.boss_music:
        moveq   #8,d2

.apply_mod_zone:
        cmp.w   af_music_zone(pc),d2
        beq.s   .rw_done
        move.w  d2,af_music_zone
        move.w  d2,pt_song_pos
.rw_done:
        movem.l (sp)+,d0-d3/a0
        rts

        cnop    0,4
af_world_mood:  dc.w    0               ; 0=Normal, 1=Ace/Heroic, 2=Crisis/RedAlert
af_music_zone:  dc.w    -1
