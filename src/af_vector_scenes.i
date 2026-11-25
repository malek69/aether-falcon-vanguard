; ============================================================================
; AETHER FALCON: VANGUARD - Silnik scen wektorowych N-gon (16.16 + move.l)
; Styl: Another World / Delphine Software (Amiga 1200 AGA 256 kolorow)
; ============================================================================
        section code,code

; ----------------------------------------------------------------------------
; af_aw_fill_ngon
; Wypelnia dowolny wielokat wypukly N-gon (3..16 wierzcholkow) wachlarzem
; Wejscie: a0 -> [count.w, x0.w, y0.w, x1.w, y1.w, ...], d6.b = indeks koloru
; ----------------------------------------------------------------------------
        cnop    0,4
af_aw_fill_ngon:
        movem.l d0-d7/a0-a1,-(sp)
        move.w  (a0)+,d7                ; liczba wierzcholkow N
        subq.w  #3,d7                   ; liczba trojkatow = N - 2
        blt.s   .ng_done
        move.w  (a0)+,d0                ; x0 (wierzcholek kotwicy wachlarza)
        move.w  (a0)+,d1                ; y0
        move.l  a0,a1
.ng_lp: move.w  (a1),d2                 ; xi
        move.w  2(a1),d3                ; yi
        move.w  4(a1),d4                ; x(i+1)
        move.w  6(a1),d5                ; y(i+1)
        bsr.s   af_aw_fill_tri
        addq.l  #4,a1
        dbf     d7,.ng_lp
.ng_done:
        movem.l (sp)+,d0-d7/a0-a1
        rts

; ----------------------------------------------------------------------------
; af_aw_fill_tri
; Szybki rasteryzer trojkatow 16.16 fixed-point z zapisem 32-bit move.l
; Wejscie: d0.w=x0, d1.w=y0, d2.w=x1, d3.w=y1, d4.w=x2, d5.w=y2, d6.b=kolor
; ----------------------------------------------------------------------------
        cnop    0,4
af_aw_fill_tri:
        movem.l d0-d7/a0-a4,-(sp)
        ; Sortowanie wierzcholkow wzgledem Y: y0 <= y1 <= y2
        cmp.w   d1,d3
        bge.s   .s01
        exg     d0,d2
        exg     d1,d3
.s01:   cmp.w   d3,d5
        bge.s   .s12
        exg     d2,d4
        exg     d3,d5
        cmp.w   d1,d3
        bge.s   .s12
        exg     d0,d2
        exg     d1,d3
.s12:   move.w  d5,d7
        sub.w   d1,d7                   ; total_dy = y2 - y0
        ble.w   .tri_done

        ; Zapisz posortowane (x0, y0, x1, y1, x2, y2) na stosie:
        ; [sp+0]=x0, [sp+2]=y0, [sp+4]=x1, [sp+6]=y1, [sp+8]=x2, [sp+10]=y2
        move.w  d5,-(sp)
        move.w  d4,-(sp)
        move.w  d3,-(sp)
        move.w  d2,-(sp)
        move.w  d1,-(sp)
        move.w  d0,-(sp)

        ; Rozszerz kolor d6.b na 32 bity (4 piksele naraz)
        and.l   #$ff,d6
        move.l  d6,d0
        lsl.w   #8,d0
        or.w    d0,d6
        move.w  d6,d0
        swap    d6
        move.w  d0,d6
        move.l  d6,a4                   ; a4 = 4x kolor

        lea     recip_table_32,a3
        cmp.w   #512,d7
        ble.s   .dy1
        move.w  #512,d7
.dy1:   move.l  (a3,d7.w*4),d0
        move.w  8(sp),d6
        sub.w   (sp),d6
        ext.l   d6
        muls.l  d0,d6

        move.w  (sp),d4
        swap    d4
        move.w  #$8000,d4               ; cur_x_long (d4.l)

        move.w  2(sp),d1                ; aktualny Y = y0
        lea     chunky_buf,a0
        move.w  d1,d7
        mulu.w  #320,d7
        add.l   d7,a0

        ; --- GORNA POLOWKA: y0 .. y1-1 ---
        move.w  6(sp),d7                ; y1
        sub.w   2(sp),d7                ; - y0
        ble.s   .do_bot

        cmp.w   #512,d7
        ble.s   .dy2
        move.w  #512,d7
.dy2:   move.l  (a3,d7.w*4),d2
        move.w  4(sp),d0
        sub.w   (sp),d0
        ext.l   d0
        muls.l  d2,d0

        move.w  (sp),d2                 ; x0
        swap    d2
        move.w  #$8000,d2               ; cur_x_short (d2.l)
        subq.w  #1,d7
.top_lp:
        bsr.s   .draw_span
        add.l   d6,d4
        add.l   d0,d2
        lea     320(a0),a0
        addq.w  #1,d1
        dbf     d7,.top_lp

.do_bot:
        ; --- DOLNA POLOWKA: y1 .. y2-1 ---
        move.w  10(sp),d7               ; y2
        sub.w   6(sp),d7                ; - y1
        ble.s   .tri_pop

        move.w  8(sp),d0                ; x2
        move.w  4(sp),d2                ; x1
        sub.w   d2,d0                   ; x2 - x1
        swap    d0
        clr.w   d0
        divs.l  d7,d0                   ; step_short_bot (d0.l)

        swap    d2
        move.w  #$8000,d2               ; cur_x_short (d2.l)
        subq.w  #1,d7
.bot_lp:
        bsr.s   .draw_span
        add.l   d6,d4
        add.l   d0,d2
        lea     320(a0),a0
        addq.w  #1,d1
        dbf     d7,.bot_lp

.tri_pop:
        lea     12(sp),sp
.tri_done:
        movem.l (sp)+,d0-d7/a0-a4
        rts

.draw_span:
        tst.w   d1
        blt.s   .sp_ret
        ifd FULL_RES
        cmp.w   #255,d1
        else
        cmp.w   #127,d1
        endif
        bgt.s   .sp_ret

        move.l  d4,d3
        swap    d3                      ; xl
        move.l  d2,d5
        swap    d5                      ; xr
        cmp.w   d3,d5
        bge.s   .sp_ord
        exg     d3,d5
.sp_ord:
        tst.w   d5
        blt.s   .sp_ret
        cmp.w   #319,d3
        bgt.s   .sp_ret
        tst.w   d3
        bge.s   .sp_cl
        moveq   #0,d3
.sp_cl:
        cmp.w   #319,d5
        ble.s   .sp_cr
        move.w  #319,d5
.sp_cr:
        lea     (a0,d3.w),a1
        sub.w   d3,d5                   ; szerokosc - 1
        move.l  a4,d3                   ; 4 bajty koloru
        move.w  d5,a2
        lsr.w   #2,d5
        beq.s   .sp_rem
        subq.w  #1,d5
.sp_l4:
        move.l  d3,(a1)+                ; szybki zapis 4 pikseli naraz
        dbf     d5,.sp_l4
.sp_rem:
        move.w  a2,d5
        and.w   #3,d5
.sp_l1:
        move.b  d3,(a1)+
        dbf     d5,.sp_l1
.sp_ret:
        rts

; ----------------------------------------------------------------------------
; af_draw_aw_intro:
        movem.l d0-d7/a0-a1,-(sp)
        move.l  af_state_timer,d7
        cmp.l   #420,d7
        ble.s   .t_ok
        move.w  #420,d7
.t_ok:
        lea     poly_intro_mountains(pc),a0
        move.b  #$11,d6
        bsr.w   af_aw_fill_ngon
        lea     poly_intro_deck(pc),a0
        move.b  #$13,d6
        bsr.w   af_aw_fill_ngon
        lea     poly_intro_bridge(pc),a0
        move.b  #$15,d6
        bsr.w   af_aw_fill_ngon
        lea     poly_intro_stripe(pc),a0
        move.b  #$FE,d6
        bsr.w   af_aw_fill_ngon
        move.w  #38,d0
        ifd FULL_RES
        move.w  #70,d1
        else
        moveq   #40,d1
        endif
        move.l  vbl_tick(pc),d3
        lsr.l   #2,d3
        and.w   #7,d3
        addq.w  #2,d3
        move.b  #$FD,d6
        jsr     af_fill_chunky_diamond
        cmp.w   #170,d7
        bge.w   .act3_takeoff
        move.w  #160,d0
        ifd FULL_RES
        move.w  #146,d1
        else
        moveq   #82,d1
        endif
        move.w  #134,d2
        move.w  d1,d3
        add.w   #20,d3
        move.w  #160,d4
        move.w  d1,d5
        add.w   #14,d5
        move.b  #$FF,d6
        bsr.w   af_aw_fill_tri
        move.w  #160,d0
        move.w  #186,d2
        move.w  d1,d3
        add.w   #20,d3
        move.w  #160,d4
        move.w  d1,d5
        add.w   #14,d5
        move.b  #$FD,d6
        bsr.w   af_aw_fill_tri
        move.w  d7,d4
        cmp.w   #95,d4
        ble.s   .moto_mv
        moveq   #95,d4
.moto_mv:
        add.w   #14,d4
        ifd FULL_RES
        move.w  #186,d5
        else
        moveq   #104,d5
        endif
        move.w  d4,d0
        subq.w  #8,d0
        move.w  d5,d1
        moveq   #4,d3
        move.b  #$01,d6
        jsr     af_fill_chunky_diamond
        move.w  d4,d0
        addq.w  #8,d0
        jsr     af_fill_chunky_diamond
        move.w  d4,d0
        subq.w  #8,d0
        move.w  d5,d1
        subq.w  #3,d1
        move.w  d4,d2
        addq.w  #8,d2
        move.w  d5,d3
        subq.w  #5,d3
        move.b  #$FC,d6
        bsr.w   af_aw_fill_tri
        cmp.w   #95,d7
        bge.s   .pilot_walk
        move.w  d7,d0
        add.w   #12,d0
        bra.s   .draw_pilot
.pilot_walk:
        move.w  d7,d0
        sub.w   #95,d0
        asr.w   #1,d0
        add.w   #110,d0
.draw_pilot:
        ifd FULL_RES
        move.w  #174,d1
        else
        moveq   #97,d1
        endif
        moveq   #3,d3
        move.b  #$FD,d6
        jsr     af_fill_chunky_diamond
        subq.w  #5,d1
        moveq   #2,d3
        move.b  #$FE,d6
        jsr     af_fill_chunky_diamond
        bra.w   .intro_done
.act3_takeoff:
        move.w  #101,d0
        ifd FULL_RES
        move.w  #186,d1
        else
        moveq   #104,d1
        endif
        moveq   #4,d3
        move.b  #$01,d6
        jsr     af_fill_chunky_diamond
        move.w  #117,d0
        jsr     af_fill_chunky_diamond
        move.w  d7,d4
        sub.w   #170,d4
        move.w  d4,d5
        asr.w   #1,d5
        ifd FULL_RES
        move.w  #146,d1
        sub.w   d5,d1
        cmp.w   #56,d1
        bge.s   .fy_ok
        moveq   #56,d1
        else
        moveq   #82,d1
        asr.w   #1,d5
        sub.w   d5,d1
        cmp.w   #28,d1
        bge.s   .fy_ok
        moveq   #28,d1
        endif
.fy_ok:
        move.w  d4,d3
        lsr.w   #3,d3
        moveq   #26,d2
        sub.w   d3,d2
        cmp.w   #6,d2
        bge.s   .fw_ok
        moveq   #6,d2
.fw_ok:
        move.w  d4,d0
        asr.w   #3,d0
        add.w   #160,d0
        movem.w d0-d2,-(sp)
        move.w  d2,d4
        move.w  d0,d2
        sub.w   d4,d2
        move.w  d1,d3
        add.w   d4,d3
        move.w  d0,d4
        move.w  d1,d5
        addq.w  #6,d5
        move.b  #$FF,d6
        bsr.w   af_aw_fill_tri
        movem.w (sp)+,d0-d2
        movem.w d0-d2,-(sp)
        move.w  d2,d4
        move.w  d0,d2
        add.w   d4,d2
        move.w  d1,d3
        add.w   d4,d3
        move.w  d0,d4
        move.w  d1,d5
        addq.w  #6,d5
        move.b  #$FD,d6
        bsr.w   af_aw_fill_tri
        movem.w (sp)+,d0-d2
        addq.w  #6,d1
        moveq   #3,d3
        btst    #1,d7
        beq.s   .ab_col
        moveq   #5,d3
.ab_col:
        move.b  #$FC,d6
        jsr     af_fill_chunky_diamond
        moveq   #2,d3
        move.b  #$FE,d6
        jsr     af_fill_chunky_diamond
.intro_done:
        movem.l (sp)+,d0-d7/a0-a1
        rts

; ----------------------------------------------------------------------------
; af_draw_aw_briefing: Taktyczna sylwetka celu misji (N-gon)
; ----------------------------------------------------------------------------
        cnop    0,4
af_draw_aw_briefing:
        movem.l d0-d7/a0,-(sp)
        lea     poly_brief_panel(pc),a0
        move.b  #$13,d6
        bsr.w   af_aw_fill_ngon

        move.w  af_mission,d0
        cmp.w   #1,d0
        beq.s   .bm2
        cmp.w   #2,d0
        beq.s   .bm3
        lea     poly_brief_m1(pc),a0
        bra.s   .bdraw
.bm2:   lea     poly_brief_m2(pc),a0
        bra.s   .bdraw
.bm3:   lea     poly_brief_m3(pc),a0
.bdraw: move.b  #$FD,d6
        bsr.w   af_aw_fill_ngon
        movem.l (sp)+,d0-d7/a0
        rts

; ----------------------------------------------------------------------------
; af_draw_aw_debrief: Reakcyjna scena po misji (zalezna od af_energy)
; ----------------------------------------------------------------------------
        cnop    0,4
af_draw_aw_debrief:
        movem.l d0-d7/a0,-(sp)
        lea     poly_intro_deck(pc),a0
        move.b  #$13,d6
        bsr.w   af_aw_fill_ngon

        lea     poly_debrief_ship(pc),a0
        move.b  #$FF,d6
        cmp.w   #60,af_energy
        bge.s   .ship_ok
        move.b  #$FC,d6
.ship_ok:
        bsr.w   af_aw_fill_ngon
        movem.l (sp)+,d0-d7/a0
        rts

        even
        ifd FULL_RES
poly_intro_mountains:
        dc.w    5, 0,160, 65,124, 155,140, 245,118, 319,160
poly_intro_deck:
        dc.w    4, 0,160, 319,160, 319,255, 0,255
poly_intro_bridge:
        dc.w    5, 18,160, 26,76, 58,76, 68,116, 74,160
poly_intro_stripe:
        dc.w    4, 156,160, 164,160, 186,255, 134,255
poly_brief_panel:
        dc.w    4, 40,48, 280,48, 280,176, 40,176
poly_brief_m1:
        dc.w    5, 160,64, 214,108, 190,156, 130,156, 106,108
poly_brief_m2:
        dc.w    4, 92,78, 228,78, 202,152, 118,152
poly_brief_m3:
        dc.w    6, 160,58, 236,92, 222,144, 160,164, 98,144, 84,92
poly_debrief_ship:
        dc.w    5, 160,68, 218,132, 178,152, 142,152, 102,132
        else
poly_intro_mountains:
        dc.w    5, 0,92, 65,74, 155,82, 245,70, 319,92
poly_intro_deck:
        dc.w    4, 0,92, 319,92, 319,127, 0,127
poly_intro_bridge:
        dc.w    5, 18,92, 26,44, 58,44, 68,66, 74,92
poly_intro_stripe:
        dc.w    4, 156,92, 164,92, 178,127, 142,127
poly_brief_panel:
        dc.w    4, 48,26, 272,26, 272,88, 48,88
poly_brief_m1:
        dc.w    5, 160,34, 210,56, 188,80, 132,80, 110,56
poly_brief_m2:
        dc.w    4, 96,42, 224,42, 200,78, 120,78
poly_brief_m3:
        dc.w    6, 160,30, 232,48, 220,74, 160,84, 100,74, 88,48
poly_debrief_ship:
        dc.w    5, 160,36, 212,68, 176,76, 144,76, 108,68
        endif
af_draw_aw_intro:
        movem.l d0-d7/a0-a5,-(sp)
        move.l  af_state_timer,d7
        cmp.w   #115,d7
        blo.w   .cut1_bike
        cmp.w   #230,d7
        blo.w   .cut2_pilot
        bra.w   .cut34_3d_jet

af_emit_dyn_poly:
        movem.l d0-d1/a0,-(sp)
        ifnd FULL_RES
        lea     af_dyn_poly(pc),a0
        move.w  (a0)+,d0
        subq.w  #1,d0
.sc_y:  addq.l  #2,a0
        move.w  (a0),d1
        asr.w   #1,d1
        move.w  d1,(a0)+
        dbf     d0,.sc_y
        endif
        lea     af_dyn_poly(pc),a0
        bsr.w   af_aw_fill_ngon
        movem.l (sp)+,d0-d1/a0
        rts

.cut1_bike:
        lea     poly_intro_mountains(pc),a0
        move.b  #$11,d6
        bsr.w   af_aw_fill_ngon
        lea     poly_intro_deck(pc),a0
        move.b  #$12,d6
        bsr.w   af_aw_fill_ngon
        ; Pedzacy pas na pokladzie (perspektywiczny trapez)
        move.w  d7,d5
        lsl.w   #3,d5
        and.w   #255,d5
        move.w  #310,d0
        sub.w   d5,d0
        lea     af_dyn_poly(pc),a0
        move.w  #4,(a0)+
        move.w  d0,(a0)+ ; move.w #222,(a0)+
        add.w   #55,d0
        move.w  d0,(a0)+ ; move.w #222,(a0)+
        sub.w   #12,d0
        move.w  d0,(a0)+ ; move.w #232,(a0)+
        sub.w   #55,d0
        move.w  d0,(a0)+ ; move.w #232,(a0)+
        move.b  #$FE,d6
        bsr.s   af_emit_dyn_poly
        ; Pozycja motocykla (d4 = srodek X)
        move.w  d7,d4
        asr.w   #1,d4
        add.w   #88,d4
        ; Stozek swiatla reflektora
        lea     af_dyn_poly(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0 ; add.w #62,d0 ; move.w d0,(a0)+ ; move.w #162,(a0)+
        add.w   #115,d0 ; move.w d0,(a0)+ ; move.w #144,(a0)+
        move.w  d0,(a0)+ ; move.w #196,(a0)+
        move.w  d4,d0 ; add.w #62,d0 ; move.w d0,(a0)+ ; move.w #172,(a0)+
        move.b  #$FE,d6
        bsr.w   af_emit_dyn_poly
        ; Tylne kolo (6-kat) + felga
        move.w  d4,d0 ; sub.w #52,d0
        bsr.w   .draw_wheel
        ; Przednie kolo (6-kat) + felga
        move.w  d4,d0 ; add.w #56,d0
        bsr.w   .draw_wheel
        ; Ciemny dolny plug i silnik motocykla (4-kat)
        lea     af_dyn_poly(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0 ; sub.w #34,d0 ; move.w d0,(a0)+ ; move.w #178,(a0)+
        move.w  d4,d0 ; add.w #42,d0 ; move.w d0,(a0)+ ; move.w #178,(a0)+
        move.w  d4,d0 ; add.w #28,d0 ; move.w d0,(a0)+ ; move.w #198,(a0)+
        move.w  d4,d0 ; sub.w #24,d0 ; move.w d0,(a0)+ ; move.w #198,(a0)+
        move.b  #$14,d6
        bsr.w   af_emit_dyn_poly
        ; Glowna czerwona owiewka i ogon motocykla (6-kat)
        lea     af_dyn_poly(pc),a0
        move.w  #6,(a0)+
        move.w  d4,d0 ; sub.w #68,d0 ; move.w d0,(a0)+ ; move.w #156,(a0)+
        move.w  d4,d0 ; sub.w #18,d0 ; move.w d0,(a0)+ ; move.w #162,(a0)+
        move.w  d4,d0 ; add.w #18,d0 ; move.w d0,(a0)+ ; move.w #148,(a0)+
        move.w  d4,d0 ; add.w #66,d0 ; move.w d0,(a0)+ ; move.w #160,(a0)+
        move.w  d4,d0 ; add.w #48,d0 ; move.w d0,(a0)+ ; move.w #180,(a0)+
        move.w  d4,d0 ; sub.w #46,d0 ; move.w d0,(a0)+ ; move.w #176,(a0)+
        move.b  #$FC,d6
        bsr.w   af_emit_dyn_poly
        ; Jasny bialo-blekitny pas na owiewce i szyba
        lea     af_dyn_poly(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0 ; add.w #16,d0 ; move.w d0,(a0)+ ; move.w #148,(a0)+
        move.w  d4,d0 ; add.w #34,d0 ; move.w d0,(a0)+ ; move.w #136,(a0)+
        move.w  d4,d0 ; add.w #54,d0 ; move.w d0,(a0)+ ; move.w #154,(a0)+
        move.w  d4,d0 ; add.w #24,d0 ; move.w d0,(a0)+ ; move.w #158,(a0)+
        move.b  #$FD,d6
        bsr.w   af_emit_dyn_poly
        ; Pochylony kierowca (kurtka + kask + zloty wizjer)
        lea     af_dyn_poly(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0 ; sub.w #24,d0 ; move.w d0,(a0)+ ; move.w #158,(a0)+
        move.w  d4,d0 ; sub.w #6,d0  ; move.w d0,(a0)+ ; move.w #134,(a0)+
        move.w  d4,d0 ; add.w #18,d0 ; move.w d0,(a0)+ ; move.w #142,(a0)+
        move.w  d4,d0 ; add.w #4,d0  ; move.w d0,(a0)+ ; move.w #162,(a0)+
        move.b  #$17,d6
        bsr.w   af_emit_dyn_poly
        lea     af_dyn_poly(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0 ; add.w #2,d0  ; move.w d0,(a0)+ ; move.w #120,(a0)+
        move.w  d4,d0 ; add.w #20,d0 ; move.w d0,(a0)+ ; move.w #120,(a0)+
        move.w  d4,d0 ; add.w #24,d0 ; move.w d0,(a0)+ ; move.w #136,(a0)+
        move.w  d4,d0 ; add.w #2,d0  ; move.w d0,(a0)+ ; move.w #136,(a0)+
        move.b  #$FF,d6
        bsr.w   af_emit_dyn_poly
        bra.w   .intro_done
.draw_wheel:
        lea     af_dyn_poly(pc),a0
        move.w  #6,(a0)+
        move.w  d0,d1 ; sub.w #12,d1 ; move.w d1,(a0)+ ; move.w #174,(a0)+
        move.w  d0,d1 ; add.w #12,d1 ; move.w d1,(a0)+ ; move.w #174,(a0)+
        move.w  d0,d1 ; add.w #22,d1 ; move.w d1,(a0)+ ; move.w #194,(a0)+
        move.w  d0,d1 ; add.w #12,d1 ; move.w d1,(a0)+ ; move.w #214,(a0)+
        move.w  d0,d1 ; sub.w #12,d1 ; move.w d1,(a0)+ ; move.w #214,(a0)+
        move.w  d0,d1 ; sub.w #22,d1 ; move.w d1,(a0)+ ; move.w #194,(a0)+
        move.b  #$01,d6
        bsr.w   af_emit_dyn_poly
        lea     af_dyn_poly(pc),a0
        move.w  #4,(a0)+
        move.w  d0,d1 ; subq.w #8,d1 ; move.w d1,(a0)+ ; move.w #186,(a0)+
        move.w  d0,d1 ; addq.w #8,d1 ; move.w d1,(a0)+ ; move.w #186,(a0)+
        move.w  d0,d1 ; addq.w #8,d1 ; move.w d1,(a0)+ ; move.w #202,(a0)+
        move.w  d0,d1 ; subq.w #8,d1 ; move.w d1,(a0)+ ; move.w #202,(a0)+
        move.b  #$16,d6
        bra.w   af_emit_dyn_poly

.cut34_3d_jet:
        lea     poly_intro_mountains(pc),a0
        move.b  #$11,d6
        bsr.w   af_aw_fill_ngon
        lea     poly_intro_deck(pc),a0
        move.b  #$13,d6
        bsr.w   af_aw_fill_ngon
        lea     poly_intro_stripe(pc),a0
        move.b  #$FE,d6
        bsr.w   af_aw_fill_ngon
        jsr     af_clear_fighter_zbuffer
        move.w  #0,cam_ox
        move.w  #0,cam_oy
        move.w  #-155,cam_oz
        clr.w   cam_sin
        move.w  #256,cam_cos
        move.l  af_state_timer,d3
        sub.l   #230,d3
        cmp.l   #1600,d3
        bge.w   .intro_done
        moveq   #0,d0
        moveq   #-16,d1
        move.w  d3,d2
        asr.w   #2,d2
        cmp.w   #38,d2
        ble.s   .rl_ok
        moveq   #38,d2
.rl_ok: jsr     build_rot_matrix_3d
        ; Pozycja 3D XF-14: wznosi sie w niebo i leci ciagle w glab az do wielkosci kropki!
        move.w  d3,d4
        asr.w   #2,d4
        cmp.w   #110,d4
        ble.s   .jx_ok
        move.w  #110,d4
.jx_ok: move.w  d3,d5
        asr.w   #2,d5
        ifd FULL_RES
        move.w  #28,d1
        sub.w   d5,d1
        cmp.w   #-64,d1
        bge.s   .jy_ok
        move.w  #-64,d1
        else
        moveq   #14,d1
        asr.w   #1,d5
        sub.w   d5,d1
        cmp.w   #-32,d1
        bge.s   .jy_ok
        move.w  #-32,d1
        endif
.jy_ok: move.w  d1,d5
        ; Glebokosc Z (d6): rosnie nieprzerwanie 12 -> 1800, az samolot stanie sie kropka!
        move.w  d3,d6
        lsl.w   #1,d6
        add.w   #12,d6
        movem.w d4-d6,-(sp)
        lea     xf14_verts,a0
        lea     v2_proj_buf,a1
        move.w  #xf14_vert_count,d7
        jsr     transform_and_project_verts
        lea     xf14_norms,a0
        lea     v2_env_buf,a1
        move.w  #xf14_vert_count,d7
        jsr     transform_normals_envmap
        lea     xf14_env_mesh,a0
        lea     v2_proj_buf,a1
        lea     v2_tex_bank,a2
        lea     v2_env_buf,a3
        jsr     draw_gouraud_env_mesh_v2
        movem.w (sp)+,d4-d6
        cmp.w   #260,d6
        bgt.s   .intro_done
        jsr     ptrail_emit_twin_nozzles
        jsr     ptrail_update_and_draw
.intro_done:
        movem.l (sp)+,d0-d7/a0-a5
        rts

af_dyn_poly:
        ds.w    18

af_draw_vanguard_crest:
        movem.l d0-d6,-(sp)
        ifd FULL_RES
        move.w  #112,d1
        else
        moveq   #54,d1
        endif
        move.w  #160,d0
        move.w  #96,d2
        move.w  d1,d3
        sub.w   #18,d3
        move.w  #160,d4
        move.w  d1,d5
        add.w   #12,d5
        move.b  #$FE,d6
        bsr.w   af_aw_fill_tri
        move.w  #160,d0
        move.w  #224,d2
        move.w  d1,d3
        sub.w   #18,d3
        move.w  #160,d4
        move.w  d1,d5
        add.w   #12,d5
        move.b  #$FE,d6
        bsr.w   af_aw_fill_tri
        move.w  #160,d0
        sub.w   #14,d1
        move.w  #140,d2
        move.w  d1,d3
        add.w   #20,d3
        move.w  #180,d4
        move.w  d3,d5
        move.b  #$FD,d6
        bsr.w   af_aw_fill_tri
        movem.l (sp)+,d0-d6
        rts
