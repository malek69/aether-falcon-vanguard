        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD v0.2.0 - Tabula Rasa Ekrany Fabularne (AFSC)
; ============================================================================

        cnop    0,4
af_render_vector_screen:
        movem.l d0-d7/a0-a5,-(sp)
        move.w  af_state,d0
        cmp.w   #STATE_BRIEFING,d0
        beq.s   .scr_briefing
        cmp.w   #STATE_DEBRIEF,d0
        beq.w   .scr_debrief

        ; --- EKRAN 0: INTRO (3-aktowa animacja Cel-Shaded scene_intro.bin) ---
        jsr     af_play_scripted_intro
        lea     str_title_hdr(pc),a0
        moveq   #68,d0
        ifd FULL_RES
        moveq   #18,d1
        else
        moveq   #10,d1
        endif
        move.b  #255,d6
        bsr.w   af_print_chunky_str
        bra.s   .scr_prompt

.scr_briefing:
        ; --- EKRAN 1: REAKTYWNA ODPRAWA TAKTYCZNA ---
        jsr     af_play_scripted_intro
        lea     str_brf_hdr(pc),a0
        moveq   #20,d0
        ifd FULL_RES
        moveq   #22,d1
        else
        moveq   #12,d1
        endif
        move.b  #254,d6
        bsr.w   af_print_chunky_str

        ; Meldunek misji + status reaktywnego swiata
        lea     str_m1_brf(pc),a0
        cmp.w   #1,af_mission
        bne.s   .b_m3
        lea     str_m2_brf(pc),a0
        bra.s   .b_pr
.b_m3:  cmp.w   #2,af_mission
        bne.s   .b_pr
        lea     str_m3_brf(pc),a0
.b_pr:  moveq   #20,d0
        ifd FULL_RES
        moveq   #44,d1
        else
        moveq   #24,d1
        endif
        move.b  #255,d6
        bsr.w   af_print_chunky_str

        lea     str_mood_norm(pc),a0
        cmp.w   #1,af_world_mood
        bne.s   .m_c2
        lea     str_mood_ace(pc),a0
        bra.s   .m_pr
.m_c2:  cmp.w   #2,af_world_mood
        bne.s   .m_pr
        lea     str_mood_crit(pc),a0
.m_pr:  moveq   #20,d0
        ifd FULL_RES
        moveq   #66,d1
        else
        moveq   #36,d1
        endif
        move.b  #253,d6
        bsr.w   af_print_chunky_str
        bra.s   .scr_prompt

.scr_debrief:
        ; --- EKRAN 3: REAKTYWNE PODSUMOWANIE MISJI ---
        jsr     af_play_scripted_intro
        lea     str_deb_hdr(pc),a0
        moveq   #20,d0
        ifd FULL_RES
        moveq   #26,d1
        else
        moveq   #14,d1
        endif
        move.b  #254,d6
        bsr.w   af_print_chunky_str

.scr_prompt:
        move.l  vbl_tick(pc),d0
        btst    #4,d0
        bne.s   .scr_blit
        lea     str_press_fire(pc),a0
        moveq   #76,d0
        ifd FULL_RES
        move.w  #238,d1
        else
        moveq   #116,d1
        endif
        move.b  #255,d6
        bsr.w   af_print_chunky_str

.scr_blit:
        jsr     c2p_convert_320x256
        movem.l (sp)+,d0-d7/a0-a5
        rts

        cnop    0,4
af_print_chunky_str:
        movem.l d0-d7/a0-a2,-(sp)
        move.w  d0,d4
        move.w  d1,d5
.ps_lp: moveq   #0,d0
        move.b  (a0)+,d0
        beq.s   .ps_done
        move.w  d4,d1
        move.w  d5,d2
        move.b  d6,d3
        jsr     hud_draw_char_5x7
        addq.w  #6,d4
        bra.s   .ps_lp
.ps_done:
        movem.l (sp)+,d0-d7/a0-a2
        rts

str_title_hdr:  dc.b    "AETHER FALCON: VANGUARD V0.2.0",0
str_brf_hdr:    dc.b    "VANGUARD TACTICAL BRIEFING",0
str_m1_brf:     dc.b    "SECTOR 01: SARGAS OCEAN PATROL",0
str_m2_brf:     dc.b    "SECTOR 02: KRELL CANYON ASSAULT",0
str_m3_brf:     dc.b    "SECTOR 03: LEVIATHAN CITADEL",0
str_deb_hdr:    dc.b    "SORTIE COMPLETE - DEBRIEFING",0
str_press_fire: dc.b    "PRESS FIRE OR SPACE TO LAUNCH",0
str_mood_norm:  dc.b    "STATUS: PERIMETER HOLDING",0
str_mood_ace:   dc.b    "ACE REPORT: HIGH MORALE BONUS!",0
str_mood_crit:  dc.b    "RED ALERT: HULL DAMAGE CRITICAL!",0
        even
