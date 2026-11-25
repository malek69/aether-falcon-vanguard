af_skel_emit_poly:
        movem.l d0-d1/a0,-(sp)
        ifnd FULL_RES
        lea     af_skel_pbuf(pc),a0
        move.w  (a0)+,d0
        subq.w  #1,d0
.sy_lp: addq.l  #2,a0
        move.w  (a0),d1
        asr.w   #1,d1
        move.w  d1,(a0)+
        dbf     d0,.sy_lp
        endif
        lea     af_skel_pbuf(pc),a0
        bsr.w   af_aw_fill_ngon
        movem.l (sp)+,d0-d1/a0
        rts

; Okragle kolo (12-kat): srodek (d0,d1), promien d2, kolor d6
af_skel_draw_circle:
        movem.l d0-d5/a0-a1,-(sp)
        lea     af_skel_pbuf(pc),a0
        move.w  #12,(a0)+
        lea     af_circ12_tbl(pc),a1
        moveq   #11,d5
.c12_lp:move.b  (a1)+,d3
        ext.w   d3
        muls.w  d2,d3
        asr.w   #4,d3
        add.w   d0,d3
        move.w  d3,(a0)+
        move.b  (a1)+,d4
        ext.w   d4
        muls.w  d2,d4
        asr.w   #4,d4
        add.w   d1,d4
        move.w  d4,(a0)+
        dbf     d5,.c12_lp
        bsr.s   af_skel_emit_poly
        movem.l (sp)+,d0-d5/a0-a1
        rts

af_skel_draw_bone:
        movem.l d0-d5/a0,-(sp)
        lea     af_skel_pbuf(pc),a0
        move.w  #4,(a0)+
        move.w  d0,d5
        sub.w   d4,d5
        move.w  d5,(a0)+
        move.w  d1,(a0)+
        move.w  d0,d5
        add.w   d4,d5
        move.w  d5,(a0)+
        move.w  d1,(a0)+
        move.w  d2,d5
        add.w   d4,d5
        move.w  d5,(a0)+
        move.w  d3,(a0)+
        move.w  d2,d5
        sub.w   d4,d5
        move.w  d5,(a0)+
        move.w  d3,(a0)+
        bsr.w   af_skel_emit_poly
        movem.l (sp)+,d0-d5/a0
        rts

af_skel_render_pilot:
        movem.l d0-d7/a0-a1,-(sp)
        move.w  d4,af_pil_x
        move.w  d5,af_pil_y
        move.w  d2,af_pil_mode
        move.w  d3,d6
        and.w   #15,d6
        lea     af_skel_sin16(pc),a1
        move.b  (a1,d6.w),d7
        ext.w   d7
        cmp.w   #2,af_pil_mode
        beq.w   .sk_seated
        cmp.w   #1,af_pil_mode
        beq.w   .sk_climb
        move.w  af_pil_x(pc),d0
        move.w  af_pil_y(pc),d1
        move.w  d0,d2
        sub.w   d7,d2
        move.w  d1,d3
        add.w   #48,d3
        moveq   #6,d4
        move.b  #$14,d6
        bsr.w   af_skel_draw_bone
        move.w  af_pil_x(pc),d0
        move.w  af_pil_y(pc),d1
        move.w  d0,d2
        add.w   d7,d2
        move.w  d1,d3
        add.w   #48,d3
        moveq   #6,d4
        move.b  #$16,d6
        bsr.w   af_skel_draw_bone
        bra.s   .sk_body
.sk_climb:
        move.w  af_pil_x(pc),d0
        move.w  af_pil_y(pc),d1
        move.w  d0,d2
        add.w   #14,d2
        move.w  d1,d3
        add.w   #34,d3
        sub.w   d7,d3
        moveq   #5,d4
        move.b  #$16,d6
        bsr.w   af_skel_draw_bone
.sk_body:
        move.w  af_pil_x(pc),d4
        move.w  af_pil_y(pc),d5
        lea     af_skel_pbuf(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0
        sub.w   #14,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        sub.w   #40,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #14,d0
        move.w  d0,(a0)+
        move.w  d1,(a0)+
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.w  d4,d0
        sub.w   #14,d0
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.b  #$FD,d6
        bsr.w   af_skel_emit_poly
        move.w  af_pil_x(pc),d0
        move.w  af_pil_y(pc),d1
        sub.w   #34,d1
        move.w  d0,d2
        sub.w   d7,d2
        cmp.w   #1,af_pil_mode
        bne.s   .arm_go
        move.w  d0,d2
        add.w   #18,d2
        sub.w   #10,d1
.arm_go:
        move.w  d1,d3
        add.w   #26,d3
        moveq   #4,d4
        move.b  #$FF,d6
        bsr.w   af_skel_draw_bone
        move.w  af_pil_x(pc),d4
        move.w  af_pil_y(pc),d5
        sub.w   #40,d5
        bra.s   .sk_head
.sk_seated:
        move.w  af_pil_x(pc),d4
        move.w  af_pil_y(pc),d5
        lea     af_skel_pbuf(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0
        sub.w   #12,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        sub.w   #14,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #12,d0
        move.w  d0,(a0)+
        move.w  d1,(a0)+
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.w  d4,d0
        sub.w   #12,d0
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.b  #$FD,d6
        bsr.w   af_skel_emit_poly
        sub.w   #14,d5
.sk_head:
        move.w  d4,d0
        move.w  d5,d1
        sub.w   #10,d1
        moveq   #10,d2
        move.b  #$FF,d6
        bsr.w   af_skel_draw_circle
        addq.w  #4,d0
        moveq   #6,d2
        move.b  #$FE,d6
        bsr.w   af_skel_draw_circle
        movem.l (sp)+,d0-d7/a0-a1
        rts

af_pil_x:       dc.w 0
af_pil_y:       dc.w 0
af_pil_mode:    dc.w 0
af_circ12_tbl:  dc.b 16,0, 14,8, 8,14, 0,16, -8,14, -14,8, -16,0, -14,-8, -8,-14, 0,-16, 8,-14, 14,-8
af_skel_sin16:  dc.b 0, 5, 9, 11, 12, 11, 9, 5, 0, -5, -9, -11, -12, -11, -9, -5
af_skel_pbuf:   ds.w 32
