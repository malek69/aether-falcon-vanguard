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
; af_draw_aw_intro: Lotniskowiec CVS-01 "SOLIS" + Wrota Hangaru + Start XF-14
; ----------------------------------------------------------------------------
        cnop    0,4
af_draw_aw_intro:
        movem.l d0-d7/a0-a1,-(sp)
        move.l  af_state_timer,d7
        cmp.l   #360,d7
        ble.s   .t_ok
        move.w  #360,d7
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

        ; Wrota hangaru rozsuwajace sie na boki
        move.w  d7,d5
        cmp.w   #160,d5
        ble.s   .dr_ok
        move.w  #160,d5
.dr_ok: lsr.w   #2,d5                   ; 0..40 px rozwarcia wrót hangaru
        move.w  #112,d0
        sub.w   d5,d0
        ifd FULL_RES
        move.w  #112,d1
        else
        moveq   #66,d1
        endif
        move.w  #160,d2
        sub.w   d5,d2
        ifd FULL_RES
        move.w  #112,d3
        else
        moveq   #66,d3
        endif
        move.w  #160,d4
        sub.w   d5,d4
        ifd FULL_RES
        move.w  #160,d5
        else
        moveq   #92,d5
        endif
        move.b  #$17,d6
        bsr.w   af_aw_fill_tri

        move.w  d7,d5
        lsr.w   #2,d5
        move.w  #112,d0
        sub.w   d5,d0
        ifd FULL_RES
        move.w  #112,d1
        else
        moveq   #66,d1
        endif
        move.w  #160,d2
        sub.w   d5,d2
        ifd FULL_RES
        move.w  #160,d3
        else
        moveq   #92,d3
        endif
        move.w  #112,d4
        sub.w   d5,d4
        ifd FULL_RES
        move.w  #160,d5
        else
        moveq   #92,d5
        endif
        move.b  #$17,d6
        bsr.w   af_aw_fill_tri

        move.w  d7,d5
        lsr.w   #2,d5
        move.w  #160,d0
        add.w   d5,d0
        ifd FULL_RES
        move.w  #112,d1
        else
        moveq   #66,d1
        endif
        move.w  #208,d2
        add.w   d5,d2
        ifd FULL_RES
        move.w  #112,d3
        else
        moveq   #66,d3
        endif
        move.w  #208,d4
        add.w   d5,d4
        ifd FULL_RES
        move.w  #160,d5
        else
        moveq   #92,d5
        endif
        move.b  #$16,d6
        bsr.w   af_aw_fill_tri

        move.w  d7,d5
        lsr.w   #2,d5
        move.w  #160,d0
        add.w   d5,d0
        ifd FULL_RES
        move.w  #112,d1
        else
        moveq   #66,d1
        endif
        move.w  #208,d2
        add.w   d5,d2
        ifd FULL_RES
        move.w  #160,d3
        else
        moveq   #92,d3
        endif
        move.w  #160,d4
        add.w   d5,d4
        ifd FULL_RES
        move.w  #160,d5
        else
        moveq   #92,d5
        endif
        move.b  #$16,d6
        bsr.w   af_aw_fill_tri

        lea     poly_intro_stripe(pc),a0
        move.b  #$FE,d6
        bsr.w   af_aw_fill_ngon

        ; Startujacy mysliwiec XF-14 "Albatros" (odpala dopalacz po otwarciu wrot)
        move.w  d7,d4
        sub.w   #90,d4
        bge.s   .ln_go
        moveq   #0,d4
.ln_go: asr.w   #1,d4
        addq.w  #6,d4
        move.w  #160,d0
        ifd FULL_RES
        move.w  #150,d1
        else
        moveq   #86,d1
        endif
        move.w  d7,d5
        asr.w   #2,d5
        sub.w   d5,d1

        move.w  #160,d2
        sub.w   d4,d2
        move.w  d1,d3
        add.w   d4,d3
        move.w  #160,d4
        move.w  d1,d5
        add.w   #16,d5
        move.b  #$FF,d6
        bsr.w   af_aw_fill_tri

        move.w  d7,d4
        asr.w   #1,d4
        addq.w  #8,d4
        move.w  #160,d2
        add.w   d4,d2
        move.w  d1,d3
        add.w   d4,d3
        move.w  #160,d4
        move.w  d1,d5
        add.w   #16,d5
        move.b  #$FD,d6
        bsr.w   af_aw_fill_tri

        ; Trojwarstwowy ognisty dopalacz startujacego XF-14
        move.w  #153,d0
        move.w  d5,d1
        move.w  #167,d2
        move.w  d5,d3
        move.w  #160,d4
        add.w   #14,d5
        btst    #1,d7
        beq.s   .fl1
        addq.w  #8,d5
.fl1:   move.b  #$FC,d6
        bsr.w   af_aw_fill_tri

        move.w  #156,d0
        move.w  d3,d1
        move.w  #164,d2
        move.w  #160,d4
        move.w  d3,d5
        add.w   #9,d5
        move.b  #$FE,d6
        bsr.w   af_aw_fill_tri

        ; Migajace swiatla naprowadzajace pasa startowego lotniskowca Solis
        move.w  d7,d0
        and.w   #15,d0
        cmp.w   #8,d0
        bge.s   .no_deck_lights
        move.w  #128,d0
        ifd FULL_RES
        move.w  #184,d1
        else
        moveq   #104,d1
        endif
        moveq   #3,d3
        move.b  #$FC,d6
        jsr     af_fill_chunky_diamond
        move.w  #192,d0
        jsr     af_fill_chunky_diamond
.no_deck_lights:

        ; Obrotowy sygnal radaru na wiezy lotniskowca Solis
        move.w  #38,d0
        ifd FULL_RES
        move.w  #70,d1
        else
        moveq   #40,d1
        endif
        move.w  d7,d3
        lsr.w   #2,d3
        and.w   #7,d3
        addq.w  #2,d3
        move.b  #$FD,d6
        jsr     af_fill_chunky_diamond

        ; Przelot klucza 2 skrzydlowych Vanguard po przekatnej nieba!
        move.l  vbl_tick(pc),d4
        and.w   #255,d4
        move.w  #300,d0
        sub.w   d4,d0                   ; przelot z prawej do lewej (300 -> 45)
        move.w  d4,d1
        lsr.w   #2,d1
        add.w   #24,d1
        move.w  d0,d2
        add.w   #16,d2
        move.w  d1,d3
        subq.w  #4,d3
        move.w  d0,d4
        add.w   #14,d4
        move.w  d1,d5
        addq.w  #5,d5
        move.b  #$FD,d6
        bsr.w   af_aw_fill_tri

        ; Drugi skrzydlowy w szyku
        add.w   #24,d0
        add.w   #12,d1
        add.w   #24,d2
        add.w   #12,d3
        add.w   #24,d4
        add.w   #12,d5
        move.b  #$FF,d6
        bsr.w   af_aw_fill_tri

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
