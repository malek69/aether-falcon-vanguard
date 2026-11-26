        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD - Odtwarzacz Modulowych Scen Fabularnych (AFSC)
; ============================================================================

        cnop    0,4
af_play_scripted_intro:
        movem.l d0-d7/a0-a5,-(sp)
        lea     af_scene_intro_buf,a4
        tst.b   af_has_scene_intro
        bne.s   .sc_hdr
        lea     af_builtin_scene_intro,a4
.sc_hdr:
        cmp.l   #$41465343,(a4)+        ; sprawdz naglowek "AFSC"
        bne.w   .sc_exit
        move.w  (a4)+,d7                ; num_acts

        ; Zaladuj 16 kolorow palety sceny (indeksy 240..255)
        lea     aga_pal256+240*4,a0
        moveq   #15,d0
.sp_lp: move.l  (a4)+,(a0)+
        dbf     d0,.sp_lp
        cmp.b   #4,pal_loaded
        beq.s   .sp_ok
        move.b  #4,pal_loaded
        lea     aga_pal256,a0
        jsr     load_aga_256_palette
.sp_ok:
        ; Wybierz aktualny akt na podstawie af_state_timer (zapetlone co 450 klatek)
        move.l  af_state_timer,d5
.mod_t: cmp.l   #450,d5
        blo.s   .mod_ok
        sub.l   #450,d5
        bra.s   .mod_t
.mod_ok:
.act_lp:
        move.w  (a4)+,d6                ; duration_frames
        move.w  d6,af_scn_cur_dur
        move.b  (a4)+,d2                ; sky_top_idx
        move.b  (a4)+,d3                ; sky_bot_idx
        move.w  (a4)+,d4                ; subtitle_len
        move.l  a4,a3                   ; a3 = wskaznik na napis aktu
        add.w   d4,a4
        move.w  (a4)+,d1                ; num_polys

        cmp.l   d6,d5
        blo.s   .render_act
        sub.l   d6,d5
        ; Przeskocz wielokaty tego aktu
        subq.w  #1,d1
        blt.s   .next_act
.sk_p:  moveq   #0,d0
        move.b  1(a4),d0                ; num_verts
        addq.l  #2,a4
        lsl.w   #3,d0                   ; 2 klatki * 4B na wierzcholek
        add.w   d0,a4
        dbf     d1,.sk_p
.next_act:
        subq.w  #1,d7
        bgt.s   .act_lp
        bra.w   .sc_exit

.render_act:
        ; Rysuj plynny gradient nieba (sky_top_idx -> sky_bot_idx)
        lea     chunky_buf,a0
        ifd FULL_RES
        move.w  #179,d0
        else
        moveq   #89,d0
        endif
.sky_y: move.b  d2,d4
        cmp.w   #90,d0
        bgt.s   .sky_c
        move.b  d3,d4
.sky_c: move.b  d4,d7
        lsl.w   #8,d7
        move.b  d4,d7
        move.w  d7,d4
        swap    d7
        move.w  d4,d7
        moveq   #79,d4
.sky_x: move.l  d7,(a0)+
        dbf     d4,.sky_x
        dbf     d0,.sky_y

        ; Renderuj wielokaty z interpolacja klatek kluczowych A -> B
        subq.w  #1,d1
        blt.w   .draw_sub
.poly_lp:
        move.b  (a4)+,d6                ; color_idx
        moveq   #0,d7
        move.b  (a4)+,d7                ; num_verts
        lea     af_scn_poly_tmp,a0
        move.w  d7,(a0)+
        move.w  d7,d0
        lsl.w   #2,d0
        lea     (a4,d0.w),a2            ; a2 = verts_end
        subq.w  #1,d7
.v_lp:  move.w  (a4)+,d2                ; x0
        move.w  (a2)+,d3                ; x1
        sub.w   d2,d3
        muls.w  d5,d3
        divs.w  af_scn_cur_dur,d3
        add.w   d2,d3
        ifd FULL_RES
        move.w  d3,(a0)+
        else
        move.w  d3,(a0)+
        endif
        move.w  (a4)+,d2                ; y0
        move.w  (a2)+,d3                ; y1
        sub.w   d2,d3
        muls.w  d5,d3
        divs.w  af_scn_cur_dur,d3
        add.w   d2,d3
        ifd FULL_RES
        move.w  d3,(a0)+
        else
        asr.w   #1,d3
        move.w  d3,(a0)+
        endif
        dbf     d7,.v_lp
        move.l  a2,a4
        lea     af_scn_poly_tmp,a0
        jsr     af_aw_fill_ngon
        dbf     d1,.poly_lp

.draw_sub:
        ; Napis fabularny u dolu ekranu
        move.l  a3,a0
        moveq   #14,d0
        ifd FULL_RES
        move.w  #216,d1
        else
        moveq   #104,d1
        endif
        move.b  #254,d6
        jsr     af_print_chunky_str

.sc_exit:
        movem.l (sp)+,d0-d7/a0-a5
        rts


        cnop    0,4
af_aw_fill_ngon:
        movem.l d0-d7/a0-a1,-(sp)
        move.w  (a0)+,d7
        subq.w  #3,d7
        blt.s   .ng_done
        move.w  (a0)+,d0
        move.w  (a0)+,d1
        move.l  a0,a1
.ng_lp: move.w  (a1),d2
        move.w  2(a1),d3
        move.w  4(a1),d4
        move.w  6(a1),d5
        bsr.s   af_aw_fill_tri
        addq.l  #4,a1
        dbf     d7,.ng_lp
.ng_done:
        movem.l (sp)+,d0-d7/a0-a1
        rts

af_aw_fill_tri:
        move.b  d6,af_tri_col
        movem.l d0-d7/a0-a4,-(sp)
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
        sub.w   d1,d7
        ble.w   .tr_end
        ; Prosty i bezpieczny rasteryzer trojkata scanline
        move.w  d1,d6
        ifd FULL_RES
        move.w  #255,a3
        else
        move.w  #127,a3
        endif
.ylp:   cmp.w   d5,d6
        bgt.w   .tr_end
        tst.w   d6
        blt.s   .nxt_y
        cmp.w   a3,d6
        bgt.w   .tr_end
        ; Oblicz x_long na krawedzi (x0,y0)->(x2,y2)
        move.w  d4,d7
        sub.w   d0,d7
        move.w  d6,a0
        sub.w   d1,a0
        move.w  a0,a1
        muls.w  a1,d7
        move.w  d5,a1
        sub.w   d1,a1
        divs.w  a1,d7
        add.w   d0,d7                   ; d7 = xa
        ; Oblicz x_short na gornej lub dolnej polowce
        cmp.w   d3,d6
        bge.s   .bot_h
        move.w  d3,a1
        sub.w   d1,a1
        beq.s   .eq_x
        move.w  d2,a2
        sub.w   d0,a2
        move.w  a2,a4
        move.w  d6,a2
        sub.w   d1,a2
        exg     d0,a4
        muls.w  a2,d0
        divs.w  a1,d0
        exg     d0,a4
        add.w   d0,a4
        move.w  a4,a1
        bra.s   .span
.eq_x:  move.w  d0,a1
        bra.s   .span
.bot_h: move.w  d5,a1
        sub.w   d3,a1
        beq.s   .eq_x2
        move.w  d4,a2
        sub.w   d2,a2
        move.w  a2,a4
        move.w  d6,a2
        sub.w   d3,a2
        exg     d0,a4
        muls.w  a2,d0
        divs.w  a1,d0
        exg     d0,a4
        add.w   d2,a4
        move.w  a4,a1
        bra.s   .span
.eq_x2: move.w  d2,a1
.span:  move.w  a1,a2
        cmp.w   a2,d7
        ble.s   .ord
        exg     d7,a2
.ord:   tst.w   d7
        bge.s   .cl_l
        moveq   #0,d7
.cl_l:  cmp.w   #319,a2
        ble.s   .cl_r
        move.w  #319,a2
.cl_r:  sub.w   d7,a2
        blt.s   .nxt_y
        move.w  d6,a0
        mulu.w  #320,a0
        add.w   d7,a0
        add.l   #chunky_buf,a0
        move.w  a2,d7
.hlp:   move.b  af_tri_col(pc),(a0)+
        dbf     d7,.hlp
.nxt_y: addq.w  #1,d6
        bra.w   .ylp
.tr_end:movem.l (sp)+,d0-d7/a0-a4
        rts

af_tri_col: dc.b 0
        even

        section fastram_bss,bss
        even
af_scn_cur_dur:  ds.w 1
        even
af_scn_poly_tmp: ds.w 40

        section fastram_data,data
        even
af_builtin_scene_intro: incbin "../data/scene_intro.bin"
