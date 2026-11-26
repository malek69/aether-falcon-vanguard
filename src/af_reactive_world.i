        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD v0.2.0 - Reaktywny Swiat i Adaptacyjny .MOD
; ============================================================================

        cnop    0,4
af_update_reactive_world:
        movem.l d0-d3/a0,-(sp)

        ; 1. Oblicz morale kampanii na podstawie trafien i wyniku pilota
        moveq   #0,d0
        tst.b   af_shield_flash
        bne.s   .chk_crit
        cmp.w   #70,af_energy
        ble.s   .chk_crit
        cmp.l   #2500,af_score
        blt.s   .st_mood
        moveq   #1,d0                   ; As Przestworzy (Wysokie morale)
        bra.s   .st_mood
.chk_crit:
        moveq   #2,d0                   ; Kryzys / Trafienie w tarcze!
.st_mood:
        move.w  d0,af_world_mood

        ; 2. Adaptacyjna muzyka ProTracker .MOD reagujaca na stan gry i akcje:
        ; - Pozycja 0: Intro / Briefing (atmosferyczny puls Solis)
        ; - Pozycja 2: Lot bojowy M1/M2 (heroiczny temat Vanguard)
        ; - Pozycja 8: Boss Lewiatan / Kryzys tarcz (szturm 16-tkowy)
        move.w  af_state,d1
        cmp.w   #STATE_GAMEPLAY,d1
        bne.s   .calm_music

        cmp.w   #2,af_mission
        beq.s   .boss_music
        tst.b   af_boss_active
        bne.s   .boss_music
        cmp.w   #2,d0
        beq.s   .boss_music
        moveq   #2,d2
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
        clr.w   pt_pat_row
.rw_done:
        movem.l (sp)+,d0-d3/a0
        rts

        cnop    0,4
af_world_mood:  dc.w    0               ; 0=Normal, 1=Ace/Heroic, 2=Crisis/RedAlert
af_music_zone:  dc.w    -1
