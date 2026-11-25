; ============================================================================
; AETHER FALCON: VANGUARD - 3 Misje Kampanii i Odprawy Tekstowe (5x7 ASCII)
; ============================================================================

        section code,code
        cnop    0,4
af_draw_vector_hud_text:
        movem.l d0-d7/a0-a3,-(sp)
        move.w  af_state,d0
        cmp.w   #STATE_INTRO,d0
        beq.s   .txt_intro
        cmp.w   #STATE_BRIEFING,d0
        beq.s   .txt_brief
        bra.w   .txt_debrief

.txt_intro:
        lea     str_intro_1(pc),a0
        moveq   #56,d0
        move.w  #224,d1
        bsr.w   af_print_bpl_str
        lea     str_intro_2(pc),a0
        moveq   #84,d0
        move.w  #236,d1
        bsr.w   af_print_bpl_str
        bra.w   .txt_done

.txt_brief:
        move.w  af_mission,d2
        cmp.w   #1,d2
        beq.s   .m2_txt
        cmp.w   #2,d2
        beq.s   .m3_txt

        lea     str_m1_title(pc),a0
        moveq   #48,d0
        move.w  #212,d1
        bsr.w   af_print_bpl_str
        lea     str_m1_obj(pc),a0
        moveq   #36,d0
        move.w  #226,d1
        bsr.w   af_print_bpl_str
        bra.w   .txt_done

.m2_txt:
        lea     str_m2_title(pc),a0
        moveq   #44,d0
        move.w  #212,d1
        bsr.w   af_print_bpl_str
        lea     str_m2_obj(pc),a0
        moveq   #36,d0
        move.w  #226,d1
        bsr.w   af_print_bpl_str
        bra.w   .txt_done

.m3_txt:
        lea     str_m3_title(pc),a0
        moveq   #44,d0
        move.w  #212,d1
        bsr.w   af_print_bpl_str
        lea     str_m3_obj(pc),a0
        moveq   #36,d0
        move.w  #226,d1
        bsr.w   af_print_bpl_str
        bra.w   .txt_done

.txt_debrief:
        lea     str_deb_1(pc),a0
        moveq   #68,d0
        move.w  #206,d1
        bsr.w   af_print_bpl_str

        ; Ranga pilota zalezna od zdobytych punktow (af_score)
        move.l  af_score,d2
        cmp.l   #3000,d2
        bge.s   .rank_ace
        cmp.l   #1200,d2
        bge.s   .rank_vng
        lea     str_rank_1(pc),a0
        bra.s   .pr_rank
.rank_vng:
        lea     str_rank_2(pc),a0
        bra.s   .pr_rank
.rank_ace:
        lea     str_rank_3(pc),a0
.pr_rank:
        moveq   #72,d0
        move.w  #222,d1
        bsr.w   af_print_bpl_str

.txt_done:
        movem.l (sp)+,d0-d7/a0-a3
        rts

; Rysowanie lancucha znakow ASCII 5x7 na aktywnym bitplanie draw_bpl1
; Wejscie: a0 = wskaznik na tekst zakonczony 0, d0.w = X (px), d1.w = Y (px)
        cnop    0,4
af_print_bpl_str:
        movem.l d0-d7/a0-a3,-(sp)
        move.l  draw_bpl1,a1
        mulu.w  #40,d1
        add.l   d1,a1                   ; wiersz Y w bitplanie (40 bajtow/linie)
        lea     hud_ascii_5x7,a2

.chr_lp:
        moveq   #0,d2
        move.b  (a0)+,d2
        beq.s   .str_end
        sub.w   #32,d2
        blt.s   .adv_x
        cmp.w   #63,d2
        bgt.s   .adv_x

        mulu.w  #7,d2
        lea     (a2,d2.w),a3            ; 7 bajtow wzorca znaku 5x7
        move.w  d0,d3
        lsr.w   #3,d3                   ; bajt X
        move.w  d0,d4
        and.w   #7,d4                   ; przesuniecie bitowe w bajcie

        moveq   #6,d5                   ; 7 wierszy znaku
        move.l  a1,d6
        add.w   d3,d6
        move.l  d6,a4
.row_lp:
        moveq   #0,d7
        move.b  (a3)+,d7
        lsl.w   #8,d7
        lsr.w   d4,d7
        or.b    d7,1(a4)
        lsr.w   #8,d7
        or.b    d7,(a4)
        lea     40(a4),a4
        dbf     d5,.row_lp

.adv_x: addq.w  #6,d0
        cmp.w   #310,d0
        blt.s   .chr_lp
.str_end:
        movem.l (sp)+,d0-d7/a0-a3
        rts

str_intro_1:    dc.b    "SOLIS CONFEDERATION - VANGUARD WING",0
str_intro_2:    dc.b    "PRESS FIRE OR SPACE TO LAUNCH",0
str_m1_title:   dc.b    "MISSION 01: SARGAS ARCHIPELAGO",0
str_m1_obj:     dc.b    "COLLECT ETHER CORES & LOCK VESPERA SCOUTS",0
str_m2_title:   dc.b    "MISSION 02: KRELL STORM CANYON",0
str_m2_obj:     dc.b    "HIGH SPEED INTERCEPT - MULTI-LOCK BARRAGE",0
str_m3_title:   dc.b    "MISSION 03: LEVIATHAN CITADEL",0
str_m3_obj:     dc.b    "ASSAULT CORE REACTORS - FINAL STRIKE",0
str_deb_1:      dc.b    "MISSION ACCOMPLISHED - SORTIE REPORT",0
str_rank_1:     dc.b    "PILOT RANK: SOLAR CADET",0
str_rank_2:     dc.b    "PILOT RANK: VANGUARD WINGMAN",0
str_rank_3:     dc.b    "PILOT RANK: ACE OF SOLIS",0
        even
