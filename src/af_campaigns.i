; ============================================================================
; AETHER FALCON: VANGUARD - Wektorowe Intro / Briefing / Debriefing w 256 kol.
; ============================================================================

        section code,code
        cnop    0,4
af_render_vector_screen:
        movem.l d0-d7/a0-a5,-(sp)
        cmp.b   #2,pal_loaded
        beq.s   .pal_cached
        move.b  #2,pal_loaded
        lea     aga_pal256,a0
        move.l  #$00FF3040,252*4(a0)
        move.l  #$0020E8FF,253*4(a0)
        move.l  #$00FFD020,254*4(a0)
        move.l  #$00FFFFFF,255*4(a0)
        jsr     load_aga_256_palette
.pal_cached:
        ; Wlasne tlo sceny fabularnej (osobne dla Intro, Briefingu i Debriefingu)
        move.w  af_state,d0
        cmp.w   #STATE_BRIEFING,d0
        beq.s   .bg_brief
        cmp.w   #STATE_DEBRIEF,d0
        beq.s   .bg_deb
        lea     poly_bg_full(pc),a0
        move.b  #$01,d6
        jsr     af_aw_fill_ngon
        lea     poly_bg_horiz(pc),a0
        move.b  #$12,d6
        jsr     af_aw_fill_ngon
        bra.s   .bg_stars
.bg_brief:
        lea     poly_bg_full(pc),a0
        move.b  #$02,d6
        jsr     af_aw_fill_ngon
        bra.s   .bg_stars
.bg_deb:
        lea     poly_bg_full(pc),a0
        move.b  #$01,d6
        jsr     af_aw_fill_ngon
.bg_stars:
        jsr     draw_256_starfield

        move.w  af_state,d0
        cmp.w   #STATE_BRIEFING,d0
        beq.w   .draw_briefing
        cmp.w   #STATE_DEBRIEF,d0
        beq.w   .draw_debriefing

        ; --- EKRAN 0: INTRO (Zywa scena wektorowa Another World + Tytul) ---
        jsr     af_draw_aw_intro




        ; Napisy tytulowe
        lea     str_game_title(pc),a0
        moveq   #82,d0
        moveq   #18,d1
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str

        lea     str_intro_1(pc),a0
        moveq   #55,d0
        moveq   #92,d1
        move.b  #$FE,d6
        bsr.w   af_print_chunky_str

        lea     str_intro_2(pc),a0
        moveq   #76,d0
        moveq   #108,d1
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str
        bra.w   .vec_blit

.draw_briefing:
        ; --- EKRAN 1: BRIEFING (Mapa Taktyczna Sektora) ---
        jsr     af_draw_aw_briefing
        ; Ramka mapy taktycznej
        move.w  #160,d0
        move.w  #54,d1
        moveq   #28,d3
        move.b  #$FD,d6
        jsr     af_draw_chunky_rect

        ; 2 punkty celow misji na mapie
        move.w  #146,d0
        move.w  #48,d1
        moveq   #5,d3
        move.b  #$FC,d6
        jsr     af_fill_chunky_diamond

        move.w  #176,d0
        move.w  #60,d1
        moveq   #5,d3
        move.b  #$FE,d6
        jsr     af_fill_chunky_diamond

        move.w  af_mission,d2
        cmp.w   #1,d2
        beq.s   .b_m2
        cmp.w   #2,d2
        beq.s   .b_m3

        lea     str_m1_title(pc),a0
        moveq   #68,d0
        moveq   #12,d1
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str
        lea     str_m1_obj(pc),a0
        moveq   #36,d0
        moveq   #96,d1
        move.b  #$FE,d6
        bsr.w   af_print_chunky_str
        bra.w   .vec_blit

.b_m2:
        lea     str_m2_title(pc),a0
        moveq   #68,d0
        moveq   #12,d1
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str
        lea     str_m2_obj(pc),a0
        moveq   #36,d0
        moveq   #96,d1
        move.b  #$FE,d6
        bsr.w   af_print_chunky_str
        bra.w   .vec_blit

.b_m3:
        lea     str_m3_title(pc),a0
        moveq   #68,d0
        moveq   #12,d1
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str
        lea     str_m3_obj(pc),a0
        moveq   #44,d0
        moveq   #96,d1
        move.b  #$FE,d6
        bsr.w   af_print_chunky_str
        bra.w   .vec_blit

.draw_debriefing:
        jsr     af_draw_aw_debrief
        ; --- EKRAN 2: DEBRIEFING (Awans Pilota) ---
        move.w  #160,d0
        move.w  #52,d1
        moveq   #20,d3
        move.b  #$FE,d6
        jsr     af_fill_chunky_diamond

        lea     str_deb_1(pc),a0
        cmp.w   #2,af_mission
        blo.s   .deb_hdr_ok
        lea     str_deb_win(pc),a0
.deb_hdr_ok:
        moveq   #52,d0
        moveq   #16,d1
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str

        move.l  af_score,d2
        cmp.l   #2500,d2
        bge.s   .rk3
        cmp.l   #1000,d2
        bge.s   .rk2
        lea     str_rank_1(pc),a0
        bra.s   .rk_pr
.rk2:   lea     str_rank_2(pc),a0
        bra.s   .rk_pr
.rk3:   lea     str_rank_3(pc),a0
.rk_pr: moveq   #78,d0
        moveq   #92,d1
        move.b  #$FE,d6
        bsr.w   af_print_chunky_str

.vec_blit:
        jsr     c2p_160x128_to_aga
        jsr     ground_fill_screen_margins
        jsr     hud_draw_overlay
        movem.l (sp)+,d0-d7/a0-a5
        rts

; Rysowanie tekstu ASCII 5x7 bezposrednio do chunky_buf (320 px szerokosci)
; Wejscie: a0 = tekst, d0.w = X (0..319), d1.w = Y (0..127/255), d6.b = kolor
        cnop    0,4
af_print_chunky_str:
        movem.l d0-d7/a0-a4,-(sp)
        lea     chunky_buf,a1
        mulu.w  #320,d1
        add.l   d1,a1
        lea     hud_ascii_5x7,a2

.c_lp:  moveq   #0,d2
        move.b  (a0)+,d2
        beq.s   .c_done
        sub.w   #32,d2
        blt.s   .c_adv
        cmp.w   #63,d2
        bgt.s   .c_adv

        lsl.w   #3,d2                   ; 8 bajtow na znak w hud_ascii_5x7
        lea     (a2,d2.w),a3
        lea     (a1,d0.w),a4
        moveq   #6,d5
.r_lp:  move.b  (a3)+,d3
        btst    #4,d3
        beq.s   .b3
        move.b  d6,(a4)
.b3:    btst    #3,d3
        beq.s   .b2
        move.b  d6,1(a4)
.b2:    btst    #2,d3
        beq.s   .b1
        move.b  d6,2(a4)
.b1:    btst    #1,d3
        beq.s   .b0
        move.b  d6,3(a4)
.b0:    btst    #0,d3
        beq.s   .nr
        move.b  d6,4(a4)
.nr:    lea     320(a4),a4
        dbf     d5,.r_lp

.c_adv: addq.w  #6,d0
        cmp.w   #312,d0
        blt.s   .c_lp
.c_done:
        movem.l (sp)+,d0-d7/a0-a4
        rts

poly_bg_full:
        ifd FULL_RES
        dc.w    4, 0,0, 319,0, 319,255, 0,255
        else
        dc.w    4, 0,0, 319,0, 319,127, 0,127
        endif
poly_bg_horiz:
        dc.w    4, 0,56, 319,56, 319,96, 0,96

str_game_title: dc.b    "AETHER FALCON: VANGUARD",0
str_intro_1:    dc.b    "SOLIS CONFEDERATION - VANGUARD WING",0
str_intro_2:    dc.b    "PRESS FIRE OR SPACE TO LAUNCH",0
str_m1_title:   dc.b    "MISSION 01: SARGAS ARCHIPELAGO",0
str_m1_obj:     dc.b    "COLLECT ETHER CORES & LOCK VESPERA SCOUTS",0
str_m2_title:   dc.b    "MISSION 02: KRELL STORM CANYON",0
str_m2_obj:     dc.b    "HIGH SPEED INTERCEPT - MULTI-LOCK BARRAGE",0
str_m3_title:   dc.b    "MISSION 03: LEVIATHAN CITADEL",0
str_m3_obj:     dc.b    "ASSAULT CORE REACTORS - FINAL STRIKE",0
str_deb_1:      dc.b    "MISSION ACCOMPLISHED - SORTIE REPORT",0
str_deb_win:    dc.b    "CAMPAIGN VICTORY - LEVIATHAN DESTROYED",0
str_rank_1:     dc.b    "PILOT RANK: SOLAR CADET",0
str_rank_2:     dc.b    "PILOT RANK: VANGUARD WINGMAN",0
str_rank_3:     dc.b    "PILOT RANK: ACE OF SOLIS",0
        even
