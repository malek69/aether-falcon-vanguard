        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD v0.2.0 - Uniwersalny Odtwarzacz Scen AFSC v2
; ============================================================================

        ifd FULL_RES
AF_SCN_H        equ     180
        else
AF_SCN_H        equ     90
        endif

        cnop    0,4
af_play_scripted_intro:
        lea     af_scene_intro_buf,a4
        tst.b   af_has_scene_intro
        bne.s   af_play_scene_stream
        lea     af_builtin_scene_intro,a4

        cnop    0,4
af_play_scene_stream:
        movem.l d0-d7/a0-a5,-(sp)
        cmp.l   #$41465343,(a4)+
        bne.w   .sc_exit
        move.w  (a4)+,d7
        ble.w   .sc_exit

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
        move.l  a4,a0
        move.w  d7,d1
        subq.w  #1,d1
        moveq   #0,d3
.sum_lp:
        moveq   #0,d0
        move.w  (a0)+,d0
        add.l   d0,d3
        addq.l  #2,a0
        move.w  (a0)+,d0
        add.w   d0,a0
        move.w  (a0)+,d2
        subq.w  #1,d2
        blt.s   .sum_nx
.sum_p: moveq   #0,d0
        move.b  1(a0),d0
        addq.l  #2,a0
        lsl.w   #3,d0
        add.w   d0,a0
        dbf     d2,.sum_p
.sum_nx:dbf     d1,.sum_lp

        tst.l   d3
        ble.w   .sc_exit

        move.l  af_state_timer,d5
.mod_t: cmp.l   d3,d5
        blo.s   .act_lp
        sub.l   d3,d5
        bra.s   .mod_t

.act_lp:
        moveq   #0,d6
        move.w  (a4)+,d6
        move.w  d6,af_scn_cur_dur
        moveq   #0,d2
        move.b  (a4)+,d2
        moveq   #0,d3
        move.b  (a4)+,d3
        move.w  (a4)+,d4
        move.l  a4,a3
        add.w   d4,a4
        move.w  (a4)+,d1

        cmp.l   d6,d5
        blo.s   .render_act
        sub.l   d6,d5
        subq.w  #1,d1
        blt.s   .next_act
.sk_p:  moveq   #0,d0
        move.b  1(a4),d0
        addq.l  #2,a4
        lsl.w   #3,d0
        add.w   d0,a4
        dbf     d1,.sk_p
.next_act:
        subq.w  #1,d7
        bgt.s   .act_lp
        bra.w   .sc_exit

.render_act:
        lea     chunky_buf,a0
        sub.w   d2,d3
        moveq   #0,d6
        move.w  #AF_SCN_H-1,d0
.sky_y: move.w  d6,d4
        muls.w  d3,d4
        divs.w  #AF_SCN_H,d4
        add.w   d2,d4
        move.b  d4,d7
        lsl.w   #8,d7
        move.b  d4,d7
        move.w  d7,d4
        swap    d7
        move.w  d4,d7
        moveq   #79,d4
.sky_x: move.l  d7,(a0)+
        dbf     d4,.sky_x
        addq.w  #1,d6
        dbf     d0,.sky_y

        subq.w  #1,d1
        blt.w   .draw_sub
.poly_lp:
        move.b  (a4)+,d6
        moveq   #0,d7
        move.b  (a4)+,d7
        lea     af_scn_poly_tmp,a0
        move.w  d7,(a0)+
        move.w  d7,d0
        lsl.w   #2,d0
        lea     (a4,d0.w),a2
        subq.w  #1,d7
.v_lp:  move.w  (a4)+,d2
        move.w  (a2)+,d3
        sub.w   d2,d3
        muls.w  d5,d3
        divs.w  af_scn_cur_dur,d3
        add.w   d2,d3
        move.w  d3,(a0)+

        move.w  (a4)+,d2
        move.w  (a2)+,d3
        sub.w   d2,d3
        muls.w  d5,d3
        divs.w  af_scn_cur_dur,d3
        add.w   d2,d3
        mulu.w  #AF_SCN_H,d3
        lsr.w   #8,d3
        move.w  d3,(a0)+
        dbf     d7,.v_lp
        move.l  a2,a4
        lea     af_scn_poly_tmp,a0
        bsr.s   af_aw_fill_ngon
        dbf     d1,.poly_lp

.draw_sub:
        move.l  a3,a0
        moveq   #14,d0
        ifd FULL_RES
        move.w  #156,d1
        else
        moveq   #74,d1
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

        cnop    0,4
af_aw_fill_tri:
        movem.l d0-d7/a0-a4,-(sp)
        move.b  d6,af_tri_col
        cmp.w   d3,d1
        ble.s   .s1
        exg     d0,d2
        exg     d1,d3
.s1:    cmp.w   d5,d1
        ble.s   .s2
        exg     d0,d4
        exg     d1,d5
.s2:    cmp.w   d5,d3
        ble.s   .s3
        exg     d2,d4
        exg     d3,d5
.s3:
        swap    d0
        move.w  d1,d0
        move.l  d0,a0
        swap    d2
        move.w  d3,d2
        move.l  d2,a1
        swap    d4
        move.w  d5,d4
        move.l  d4,a2

        move.w  a0,d6
        move.w  a2,d7
        cmp.w   d7,d6
        beq.w   .tr_end

        tst.w   d6
        bge.s   .ymin_ok
        moveq   #0,d6
.ymin_ok:
        cmp.w   #AF_SCN_H-1,d7
        ble.s   .ymax_ok
        move.w  #AF_SCN_H-1,d7
.ymax_ok:
        cmp.w   d7,d6
        bgt.w   .tr_end

.ylp:   move.w  a2,d3
        sub.w   a0,d3
        move.l  a0,d0
        swap    d0
        move.l  a2,d4
        swap    d4
        sub.w   d0,d4
        move.w  d6,d2
        sub.w   a0,d2
        muls.w  d2,d4
        divs.w  d3,d4
        add.w   d0,d4

        move.w  a1,d3
        cmp.w   d3,d6
        bge.s   .bot_h

        sub.w   a0,d3
        beq.s   .xb_eq0
        move.l  a1,d5
        swap    d5
        sub.w   d0,d5
        muls.w  d2,d5
        divs.w  d3,d5
        add.w   d0,d5
        bra.s   .span
.xb_eq0:move.w  d0,d5
        bra.s   .span

.bot_h: move.w  a2,d2
        sub.w   d3,d2
        beq.s   .xb_eq1
        move.l  a1,d0
        swap    d0
        move.l  a2,d5
        swap    d5
        sub.w   d0,d5
        move.w  d6,d1
        sub.w   d3,d1
        muls.w  d1,d5
        divs.w  d2,d5
        add.w   d0,d5
        bra.s   .span
.xb_eq1:move.l  a1,d5
        swap    d5

.span:  cmp.w   d5,d4
        ble.s   .ord
        exg     d4,d5
.ord:   tst.w   d4
        bge.s   .cl_l
        moveq   #0,d4
.cl_l:  cmp.w   #319,d5
        ble.s   .cl_r
        move.w  #319,d5
.cl_r:  sub.w   d4,d5
        blt.s   .nxt_y
        move.w  d6,d0
        mulu.w  #320,d0
        add.w   d4,d0
        lea     chunky_buf,a3
        add.l   d0,a3
        move.b  af_tri_col(pc),d0
.hlp:   move.b  d0,(a3)+
        dbf     d5,.hlp
.nxt_y: addq.w  #1,d6
        cmp.w   d7,d6
        ble.w   .ylp
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
