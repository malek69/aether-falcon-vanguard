        section code,code
cine_draw_letterbox:
        movem.l d0-d3/a0,-(sp)
        move.w  cine_bar_h(pc),d2
        ble.s   .lb_end
        cmp.w   #40,d2
        ble.s   .lb_ok
        moveq   #40,d2
.lb_ok: lea     chunky_buf,a0
        move.w  d2,d3
        subq.w  #1,d3
.lb_t:  moveq   #79,d0
.lb_tx: clr.l   (a0)+
        dbf     d0,.lb_tx
        dbf     d3,.lb_t
        lea     chunky_buf+256*320,a0
        move.w  d2,d0
        mulu.w  #320,d0
        suba.l  d0,a0
        move.w  d2,d3
        subq.w  #1,d3
.lb_b:  moveq   #79,d0
.lb_bx: clr.l   (a0)+
        dbf     d0,.lb_bx
        dbf     d3,.lb_b
.lb_end:movem.l (sp)+,d0-d3/a0
        rts
cine_fill_tri_2d:
        movem.l d0-d7/a0-a2,-(sp)
        cmp.w   d1,d3
        bge.s   .s1
        exg     d0,d2
        exg     d1,d3
.s1:    cmp.w   d1,d5
        bge.s   .s2
        exg     d0,d4
        exg     d1,d5
.s2:    cmp.w   d3,d5
        bge.s   .s3
        exg     d2,d4
        exg     d3,d5
.s3:    move.w  d5,d7
        sub.w   d1,d7
        ble.w   .ft_end
        move.w  d1,a2
.ft_lp: move.w  a2,d6
        cmp.w   #0,d6
        blt.w   .ft_nx
        cmp.w   #255,d6
        bgt.w   .ft_end
        sub.w   d1,d6
        move.w  d4,d0
        sub.w   (sp),d0
        muls.w  d6,d0
        divs.w  d7,d0
        add.w   (sp),d0
        move.w  a2,d6
        cmp.w   d3,d6
        bge.s   .seg2
        move.w  d3,a1
        sub.w   d1,a1
        move.w  a1,d6
        beq.s   .seg2
        move.w  a2,d6
        sub.w   d1,d6
        move.w  d2,a0
        sub.w   (sp),a0
        move.w  a0,d1
        muls.w  d6,d1
        move.w  a1,d6
        divs.w  d6,d1
        add.w   (sp),d1
        move.l  4(sp),d6
        bra.s   .span
.seg2:  move.w  d5,a1
        sub.w   d3,a1
        move.w  a1,d6
        beq.w   .ft_nx
        move.w  a2,d6
        sub.w   d3,d6
        move.w  d4,d1
        sub.w   d2,d1
        muls.w  d6,d1
        move.w  a1,d6
        divs.w  d6,d1
        add.w   d2,d1
        move.l  4(sp),d6
.span:  cmp.w   d0,d1
        bge.s   .sp_ok
        exg     d0,d1
.sp_ok: cmp.w   #0,d0
        bge.s   .x0_ok
        moveq   #0,d0
.x0_ok: cmp.w   #319,d1
        ble.s   .x1_ok
        move.w  #319,d1
.x1_ok: sub.w   d0,d1
        blt.s   .ft_nx
        lea     chunky_buf,a0
        move.w  a2,d6
        mulu.w  #320,d6
        add.l   d6,a0
        add.w   d0,a0
        move.l  24(sp),d6
.px_l:  move.b  d6,(a0)+
        dbf     d1,.px_l
.ft_nx: move.l  4(sp),d1
        addq.w  #1,a2
        cmp.w   d5,a2
        ble.w   .ft_lp
.ft_end:movem.l (sp)+,d0-d7/a0-a2
        rts
cine_draw_dialogue_panel:
        movem.l d0-d7/a0-a4,-(sp)
        lea     chunky_buf+178*320+16,a0
        moveq   #65,d7
.dp_y:  move.w  #287,d6
.dp_x:  move.b  #128,(a0,d6.w)
        dbf     d6,.dp_x
        adda.w  #320,a0
        dbf     d7,.dp_y
        lea     chunky_buf+182*320+22,a0
        moveq   #57,d7
.pt_y:  moveq   #47,d6
.pt_x:  move.b  #134,(a0,d6.w)
        dbf     d6,.pt_x
        adda.w  #320,a0
        dbf     d7,.pt_y
        tst.l   cine_line1_ptr
        beq.s   .dp_no1
        move.l  cine_line1_ptr(pc),a2
        lea     chunky_buf+186*320+78,a3
        bsr.s   cine_print_5x7
.dp_no1:tst.l   cine_line2_ptr
        beq.s   .dp_no2
        move.l  cine_line2_ptr(pc),a2
        lea     chunky_buf+198*320+78,a3
        bsr.s   cine_print_5x7
.dp_no2:tst.l   cine_line3_ptr
        beq.s   .dp_no3
        move.l  cine_line3_ptr(pc),a2
        lea     chunky_buf+214*320+78,a3
        bsr.s   cine_print_5x7
.dp_no3:movem.l (sp)+,d0-d7/a0-a4
        rts
cine_print_5x7:
        moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .cp_end
        sub.w   #32,d0
        lsl.w   #3,d0
        lea     hud_ascii_5x7,a4
        add.l   d0,a4
        move.l  a3,a5
        moveq   #6,d3
.py_lp: move.b  (a4)+,d4
        btst    #4,d4
        beq.s   .b3
        move.b  #255,(a5)
.b3:    btst    #3,d4
        beq.s   .b2
        move.b  #255,1(a5)
.b2:    btst    #2,d4
        beq.s   .b1
        move.b  #255,2(a5)
.b1:    btst    #1,d4
        beq.s   .b0
        move.b  #255,3(a5)
.b0:    btst    #0,d4
        beq.s   .nx
        move.b  #255,4(a5)
.nx:    adda.w  #320,a5
        dbf     d3,.py_lp
        addq.l  #6,a3
        bra.s   cine_print_5x7
.cp_end:rts
cine_bar_h:     dc.w 0
cine_line1_ptr: dc.l 0
cine_line2_ptr: dc.l 0
cine_line3_ptr: dc.l 0
