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
                ; Ultraszybkie 32-bitowe czyszczenie tla ekranu fabularnego
        lea     chunky_buf,a0
        move.l  #16843009,d1
        cmp.w   #STATE_BRIEFING,af_state
        bne.s   .bg_c_ok
        move.l  #33686018,d1
.bg_c_ok:
        ifd FULL_RES
        move.w  #20479,d2
        else
        move.w  #10239,d2
        endif
.bg_f_lp:
        move.l  d1,(a0)+
        dbf     d2,.bg_f_lp
.bg_stars:
        move.w  af_state,d0
        cmp.w   #STATE_BRIEFING,d0
        beq.w   .draw_briefing
        cmp.w   #STATE_DEBRIEF,d0
        beq.w   .draw_debriefing

        ; --- EKRAN 0: INTRO (Zywa scena wektorowa Another World + Tytul) ---
        jsr     af_draw_aw_intro
        cmp.l   #560,af_state_timer
        blo.w   .vec_blit
        jsr     af_draw_vanguard_crest
        ; Napisy tytulowe
        lea     str_game_title(pc),a0
        moveq   #82,d0
        ifd FULL_RES
        moveq   #28,d1
        else
        moveq   #18,d1
        endif
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str

        lea     str_intro_1(pc),a0
        moveq   #55,d0
        ifd FULL_RES
        move.w  #198,d1
        else
        moveq   #92,d1
        endif
        move.b  #$FE,d6
        bsr.w   af_print_chunky_str

        lea     str_intro_2(pc),a0
        moveq   #76,d0
        ifd FULL_RES
        move.w  #224,d1
        else
        moveq   #108,d1
        endif
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str
        bra.w   .vec_blit

.draw_briefing:
        ; --- EKRAN 1: BRIEFING (Tablica Odpraw Taktycznych z Fabula Kampanii) ---
        jsr     af_draw_aw_briefing

        ; Rysuj lewy panel tekstowy odprawy (x=10..185), po prawej portret Dowodcy Eon!
        lea     chunky_buf,a0
        ifd FULL_RES
        adda.l  #14*320+10,a0
        move.w  #202,d7
        else
        adda.l  #6*320+10,a0
        move.w  #96,d7
        endif
        move.l  #269488144,d1
.brd_row:
        move.l  a0,a1
        moveq   #43,d6                  ; 44 * 4 = 176 px szerokosci (x=10..185)
.brd_col:
        move.l  d1,(a1)+
        dbf     d6,.brd_col
        lea     320(a0),a0
        dbf     d7,.brd_row

        ; Gorna i dolna belka ramki tablicy odpraw (x=14..305)
        lea     chunky_buf+14,a0
        move.l  #4261281277,d1          ; $FDFDFDFD (turkus)
        ifd FULL_RES
        adda.l  #14*320,a0
        lea     202*320(a0),a1
        else
        adda.l  #6*320,a0
        lea     96*320(a0),a1
        endif
        moveq   #72,d6
.brd_bar:
        move.l  d1,(a0)+
        move.l  d1,(a1)+
        dbf     d6,.brd_bar

        ; Mini-radar taktyczny w prawym gornym rogu tablicy (x=268)
        move.w  #282,d0
        ifd FULL_RES
        move.w  #66,d1
        moveq   #14,d3
        else
        move.w  #32,d1
        moveq   #11,d3
        endif
        move.b  #254,d6
        jsr     af_draw_chunky_rect
        move.w  #277,d0
        ifd FULL_RES
        move.w  #60,d1
        else
        move.w  #29,d1
        endif
        moveq   #4,d3
        move.b  #252,d6
        jsr     af_fill_chunky_diamond
        move.w  #287,d0
        ifd FULL_RES
        move.w  #73,d1
        else
        move.w  #35,d1
        endif
        moveq   #4,d3
        move.b  #253,d6
        jsr     af_fill_chunky_diamond

        ; Naglowek tablicy odpraw
        lea     str_brd_hdr(pc),a0
        moveq   #14,d0
        ifd FULL_RES
        moveq   #22,d1
        else
        moveq   #10,d1
        endif
        move.b  #254,d6
        bsr.w   af_print_chunky_str

        ; Wybierz tablice 6 wskaznikow tekstowych dla aktualnej misji
        move.w  af_mission,d2
        cmp.w   #1,d2
        beq.s   .b_sel2
        cmp.w   #2,d2
        beq.s   .b_sel3
        lea     brd_m1_ptrs(pc),a4
        bra.s   .b_draw_lines
.b_sel2: lea     brd_m2_ptrs(pc),a4
        bra.s   .b_draw_lines
.b_sel3: lea     brd_m3_ptrs(pc),a4

.b_draw_lines:
        ; 1. Tytul misji (bialy $FF)
        move.l  (a4)+,a0
        moveq   #14,d0
        ifd FULL_RES
        moveq   #38,d1
        else
        moveq   #20,d1
        endif
        move.b  #255,d6
        bsr.w   af_print_chunky_str

        ; 2. Linia fabuly 1 (turkus $FD)
        move.l  (a4)+,a0
        moveq   #14,d0
        ifd FULL_RES
        moveq   #62,d1
        else
        moveq   #33,d1
        endif
        move.b  #253,d6
        bsr.w   af_print_chunky_str

        ; 3. Linia fabuly 2 (bialy $FF)
        move.l  (a4)+,a0
        moveq   #14,d0
        ifd FULL_RES
        moveq   #84,d1
        else
        moveq   #45,d1
        endif
        move.b  #255,d6
        bsr.w   af_print_chunky_str

        ; 4. Linia fabuly 3 (zloto $FE)
        move.l  (a4)+,a0
        moveq   #14,d0
        ifd FULL_RES
        moveq   #112,d1
        else
        moveq   #59,d1
        endif
        move.b  #254,d6
        bsr.w   af_print_chunky_str

        ; 5. Linia fabuly 4 (turkus $FD)
        move.l  (a4)+,a0
        moveq   #14,d0
        ifd FULL_RES
        move.w  #136,d1
        else
        moveq   #71,d1
        endif
        move.b  #253,d6
        bsr.w   af_print_chunky_str

        ; 6. Linia fabuly 5 (czerwony/zloto celu)
        move.l  (a4)+,a0
        moveq   #14,d0
        ifd FULL_RES
        move.w  #160,d1
        else
        moveq   #83,d1
        endif
        move.b  #255,d6
        bsr.w   af_print_chunky_str

.b_keys_hint:
        lea     str_brief_keys1(pc),a0
        moveq   #46,d0
        ifd FULL_RES
        move.w  #226,d1
        else
        moveq   #106,d1
        endif
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str
        lea     str_brief_keys2(pc),a0
        moveq   #36,d0
        ifd FULL_RES
        move.w  #238,d1
        else
        moveq   #116,d1
        endif
        move.b  #$FD,d6
        bsr.w   af_print_chunky_str
        bra.w   .vec_blit

.draw_debriefing:
        jsr     af_draw_aw_debrief
        tst.b   af_game_over
        bne.s   .deb_gameover

        ; --- EKRAN 2A: DEBRIEFING (Misja Zaliczona / Awans Pilota) ---
        lea     str_deb_1(pc),a0
        cmp.w   #2,af_mission
        blo.s   .deb_hdr_ok
        lea     str_deb_win(pc),a0
.deb_hdr_ok:
        moveq   #52,d0
        ifd FULL_RES
        moveq   #28,d1
        else
        moveq   #16,d1
        endif
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str
        bra.s   .deb_rank_eval

.deb_gameover:
        ; --- EKRAN 2B: GAME OVER / DEBRIEFING PO UTRACIE TARCZY ---
        lea     str_go_title(pc),a0
        moveq   #76,d0
        ifd FULL_RES
        moveq   #24,d1
        else
        moveq   #12,d1
        endif
        move.b  #$FC,d6
        bsr.w   af_print_chunky_str

        lea     str_go_sub(pc),a0
        moveq   #64,d0
        ifd FULL_RES
        moveq   #40,d1
        else
        moveq   #24,d1
        endif
        move.b  #$FF,d6
        bsr.w   af_print_chunky_str

        lea     str_go_retry(pc),a0
        moveq   #70,d0
        ifd FULL_RES
        move.w  #222,d1
        else
        moveq   #106,d1
        endif
        move.b  #$FE,d6
        bsr.w   af_print_chunky_str

.deb_rank_eval:

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
        ifd FULL_RES
        move.w  #198,d1
        else
        moveq   #92,d1
        endif
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
        ifd FULL_RES
        dc.w    4, 0,104, 319,104, 319,164, 0,164
        else
        dc.w    4, 0,56, 319,56, 319,96, 0,96
        endif

str_game_title: dc.b    "AETHER FALCON: VANGUARD",0
str_intro_1:    dc.b    "SOLIS CONFEDERATION - VANGUARD WING",0
str_intro_2:    dc.b    "PRESS FIRE OR SPACE TO LAUNCH",0
str_m1_title:   dc.b    "MISSION 01: SARGAS ARCHIPELAGO",0
str_m1_obj:     dc.b    "COLLECT ETHER CORES & LOCK VESPERA SCOUTS",0
str_m2_title:   dc.b    "MISSION 02: KRELL STORM CANYON",0
str_m2_obj:     dc.b    "HIGH SPEED INTERCEPT - MULTI-LOCK BARRAGE",0
str_m3_title:   dc.b    "MISSION 03: LEVIATHAN CITADEL",0
str_m1_desc2:   dc.b    "PATROL OVER VOXEL OCEAN & ISLAND PEAKS",0
str_m1_desc3:   dc.b    "GATHER ETHER CORES (+40 SHIELD ENERGY)",0
str_m2_desc2:   dc.b    "DOUBLE-HELIX 360 VESPERA INTERCEPTORS",0
str_m2_desc3:   dc.b    "USE MULTI-LOCK MISSILES IN STORM CANYON",0
str_m3_obj:     dc.b    "LEVIATHAN 3D FORTRESS IN TUNNEL CENTER",0
str_m3_desc2:   dc.b    "ASSAULT OVER VOLCANIC CITADEL TOWERS",0
str_m3_desc3:   dc.b    "DESTROY ALL 4 ORBITING REACTOR CORES!",0
str_brief_keys1:dc.b    "ARROWS / JOY2 : FLY & AIM LOCK-ON",0
str_brief_keys2:dc.b    "SPACE / FIRE / ALT : CANNON & MISSILES",0
str_deb_1:      dc.b    "MISSION ACCOMPLISHED - SORTIE REPORT",0
str_deb_win:    dc.b    "CAMPAIGN VICTORY - LEVIATHAN DESTROYED",0
str_rank_1:     dc.b    "PILOT RANK: SOLAR CADET",0
str_rank_2:     dc.b    "PILOT RANK: VANGUARD WINGMAN",0
str_rank_3:     dc.b    "PILOT RANK: ACE OF SOLIS",0
        even

str_go_title:   dc.b    "GAME OVER - XF-14 DESTROYED",0
str_go_sub:     dc.b    "SHIELD DEPLETED - MISSION FAILED",0
str_go_retry:   dc.b    "PRESS FIRE OR SPACE TO RESTART",0
        even

        even
brd_m1_ptrs:    dc.l str_m1_title, str_m1_l1, str_m1_l2, str_m1_l3, str_m1_l4, str_m1_l5
brd_m2_ptrs:    dc.l str_m2_title, str_m2_l1, str_m2_l2, str_m2_l3, str_m2_l4, str_m2_l5
brd_m3_ptrs:    dc.l str_m3_title, str_m3_l1, str_m3_l2, str_m3_l3, str_m3_l4, str_m3_l5
str_brd_hdr:    dc.b "SOLIS AIRBASE - VANGUARD BRIEFING",0
str_m1_l1:      dc.b "VESPERA DOMINION INVADES SOLIS!",0
str_m1_l2:      dc.b "LAUNCHED XF-14 FROM SOLIS AIRBASE.",0
str_m1_l3:      dc.b "PATROL SARGAS OCEAN & VOXEL ISLANDS",0
str_m1_l4:      dc.b "COLLECT BLUE ETHER CORES (+40 SHIELD)",0
str_m1_l5:      dc.b "INTERCEPT 360 SPIRAL VESPERA SCOUTS!",0
str_m2_l1:      dc.b "ENEMY FLEET ENTERS KRELL CANYON!",0
str_m2_l2:      dc.b "HIGH-SPEED RUN BETWEEN CANYON PEAKS",0
str_m2_l3:      dc.b "VESPERA ATTACKS IN 360 DOUBLE-HELIX",0
str_m2_l4:      dc.b "FIRE MULTI-LOCK SALVOS TO CLEAR PATH",0
str_m2_l5:      dc.b "EVADE PLASMA BOLTS & GATHER CORES!",0
str_m3_l1:      dc.b "FINAL ASSAULT ON LEVIATHAN CITADEL!",0
str_m3_l2:      dc.b "FLY OVER VOLCANIC CITADEL TOWERS",0
str_m3_l3:      dc.b "3D FLYING FORTRESS IN TUNNEL CENTER",0
str_m3_l4:      dc.b "POWERED BY 4 ORBITING REACTOR CORES",0
str_m3_l5:      dc.b "DESTROY ALL 4 REACTORS (2 HITS EACH)!",0
        even
