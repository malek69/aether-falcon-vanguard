        section code,code
thea1200_init_hw:
        move.w  #$c000,$dff034
        move.w  #160,mouse_x
        move.w  #128,mouse_y
        move.w  $dff00a,mouse_prev_xy
        move.w  #256,aga_fade_lvl
        rts
thea1200_read_peripherals:
        movem.l d0-d3,-(sp)
        move.w  $dff00a,d0
        move.w  mouse_prev_xy(pc),d1
        move.w  d0,mouse_prev_xy
        move.b  d0,d2
        sub.b   d1,d2
        ext.w   d2
        add.w   d2,mouse_x
        lsr.w   #8,d0
        lsr.w   #8,d1
        sub.b   d1,d0
        ext.w   d0
        add.w   d0,mouse_y
        cmp.w   #4,mouse_x
        bge.s   .mx1
        move.w  #4,mouse_x
.mx1:   cmp.w   #315,mouse_x
        ble.s   .mx2
        move.w  #315,mouse_x
.mx2:   cmp.w   #4,mouse_y
        bge.s   .my1
        move.w  #4,mouse_y
.my1:   cmp.w   #251,mouse_y
        ble.s   .my2
        move.w  #251,mouse_y
.my2:   clr.b   pad_btn2_held
        btst    #6,$dff016
        bne.s   .nb2
        move.b  #1,pad_btn2_held
.nb2:   clr.b   rmb_held
        btst    #2,$dff016
        bne.s   .nrm
        move.b  #1,rmb_held
.nrm:   movem.l (sp)+,d0-d3
        rts
aga_apply_24bit_fade:
        movem.l d0-d7/a0-a2,-(sp)
        lea     $dff000,a1
        move.w  aga_fade_lvl(pc),d6
        moveq   #0,d7
.bk_lp: move.w  d7,d0
        lsl.w   #8,d0
        lsl.w   #5,d0
        move.w  d0,$106(a1)
        lea     $180(a1),a2
        moveq   #31,d5
.cl_lp: move.l  (a0)+,d0
        move.l  d0,d1
        lsr.l   #8,d1
        lsr.l   #8,d1
        and.w   #$ff,d1
        mulu.w  d6,d1
        lsr.w   #8,d1
        move.w  d0,d2
        lsr.w   #8,d2
        and.w   #$ff,d2
        mulu.w  d6,d2
        lsr.w   #8,d2
        move.w  d0,d3
        and.w   #$ff,d3
        mulu.w  d6,d3
        lsr.w   #8,d3
        move.w  d1,d4
        and.w   #$f0,d4
        lsl.w   #4,d4
        move.w  d2,d0
        and.w   #$f0,d0
        or.w    d0,d4
        move.w  d3,d0
        lsr.w   #4,d0
        or.w    d0,d4
        move.w  d4,(a2)+
        dbf     d5,.cl_lp
        move.w  d7,d0
        lsl.w   #8,d0
        lsl.w   #5,d0
        or.w    #$0200,d0
        move.w  d0,$106(a1)
        lea     -1024(a0),a0
        lea     $180(a1),a2
        moveq   #31,d5
.lo_lp: move.l  (a0)+,d0
        move.l  d0,d1
        lsr.l   #8,d1
        lsr.l   #8,d1
        and.w   #$ff,d1
        mulu.w  d6,d1
        lsr.w   #8,d1
        move.w  d0,d2
        lsr.w   #8,d2
        and.w   #$ff,d2
        mulu.w  d6,d2
        lsr.w   #8,d2
        move.w  d0,d3
        and.w   #$ff,d3
        mulu.w  d6,d3
        lsr.w   #8,d3
        move.w  d1,d4
        and.w   #$0f,d4
        lsl.w   #8,d4
        move.w  d2,d0
        and.w   #$0f,d0
        lsl.w   #4,d0
        or.w    d0,d4
        move.w  d3,d0
        and.w   #$0f,d0
        or.w    d0,d4
        move.w  d4,(a2)+
        dbf     d5,.lo_lp
        addq.w  #1,d7
        cmp.w   #8,d7
        blt.w   .bk_lp
        clr.w   $106(a1)
        movem.l (sp)+,d0-d7/a0-a2
        rts
mouse_x:       dc.w 160
mouse_y:       dc.w 128
mouse_prev_xy: dc.w 0
aga_fade_lvl:  dc.w 256
pad_btn2_held: dc.b 0
rmb_held:      dc.b 0
