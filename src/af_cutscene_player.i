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

        section fastram_bss,bss
        even
af_scn_cur_dur:  ds.w 1
        even
af_scn_poly_tmp: ds.w 40

        section fastram_data,data
        even
af_builtin_scene_intro: incbin "../data/scene_intro.bin"
