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
cine_move_camera_smooth:
        movem.l d0-d1,-(sp)
        move.l  cine_target_x(pc),d0
        sub.l   cam_x(pc),d0
        asr.l   #4,d0
        add.l   d0,cam_x
        move.l  cine_target_y(pc),d0
        sub.l   cam_y(pc),d0
        asr.l   #4,d0
        add.l   d0,cam_y
        move.w  cine_target_alt(pc),d0
        sub.w   cam_alt(pc),d0
        asr.w   #3,d0
        add.w   d0,cam_alt
        move.w  cine_target_pitch(pc),d0
        sub.w   cam_pitch(pc),d0
        asr.w   #3,d0
        add.w   d0,cam_pitch
        movem.l (sp)+,d0-d1
        rts
cine_draw_portrait_anim:
        movem.l d0-d2/a0-a2,-(sp)
        lea     exo_portrait_gfx,a2
        lea     chunky_buf+182*320+22,a1
        moveq   #57,d1
.pr_y:  moveq   #11,d0
        move.l  a1,a0
.pr_x:  move.l  (a2)+,(a0)+
        dbf     d0,.pr_x
        adda.w  #320,a1
        dbf     d1,.pr_y
        tst.w   cine_talking
        beq.s   .pr_dn
        move.w  vbl_tick+2(pc),d0
        and.w   #8,d0
        beq.s   .pr_dn
        lea     chunky_buf+212*320+42,a1
        clr.l   (a1)
        clr.w   4(a1)
.pr_dn: movem.l (sp)+,d0-d2/a0-a2
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
        lea     chunky_buf+178*320+16,a0
        move.w  #287,d6
.bd_x:  move.b  #156,(a0,d6.w)
        move.b  #156,65*320(a0,d6.w)
        dbf     d6,.bd_x
        bsr.w   cine_draw_portrait_anim
        clr.w   cine_talking
        move.w  cine_type_chars(pc),d7
        tst.l   cine_line1_ptr
        beq.s   .dp_no1
        move.l  cine_line1_ptr(pc),a2
        lea     chunky_buf+186*320+78,a3
        bsr.s   cine_print_n_5x7
.dp_no1:tst.l   cine_line2_ptr
        beq.s   .dp_no2
        move.l  cine_line2_ptr(pc),a2
        lea     chunky_buf+198*320+78,a3
        bsr.s   cine_print_n_5x7
.dp_no2:        tst.l   cine_line3_ptr
        beq.s   .dp_no3
        move.l  cine_line3_ptr(pc),a2
        lea     chunky_buf+216*320+78,a3
        move.w  #64,d7
        bsr.s   cine_print_n_5x7
.dp_no3:movem.l (sp)+,d0-d7/a0-a4
        rts
cine_print_n_5x7:
        tst.w   d7
        ble.w   .cp_end
        moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .cp_end
        subq.w  #1,d7
        bne.s   .ch_ok
        move.w  #1,cine_talking
.ch_ok: cmp.b   #10,d0
        bge.s   .cp_asc
        subq.w  #1,d0
        lsl.w   #3,d0
        lea     pl_glyphs_5x7(pc),a4
        add.l   d0,a4
        bra.s   .cp_gl
.cp_asc:sub.w   #32,d0
        lsl.w   #3,d0
        lea     hud_ascii_5x7,a4
        add.l   d0,a4
.cp_gl:
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
        bra.w   cine_print_n_5x7
.cp_end:rts
cine_update_and_draw:
        cmp.b   #$14,kbd_held_raw
        bne.s   .ck_act
        move.b  #1,cine_active
        move.w  #1,cine_type_chars
.ck_act:tst.b   cine_active
        beq.s   .cu_end
        cmp.w   #16,cine_bar_h
        bge.s   .cb_ok
        addq.w  #1,cine_bar_h
.cb_ok: addq.w  #1,cine_type_chars
        bsr.w   cine_draw_dialogue_panel
        jsr     thea1200_draw_mouse_cursor
        cmp.w   #28,cine_type_chars
        blt.s   .cu_end
        bne.s   .ck_key
        clr.b   kbd_held_raw
        clr.b   mouse_lmb_click
.ck_key:
        move.b  kbd_held_raw,d0
        cmp.b   #$01,d0
        beq.s   .cu_cls
        cmp.b   #$02,d0
        beq.s   .cu_cls
        cmp.b   #$44,d0
        beq.s   .cu_cls
        tst.b   mouse_lmb_click
        beq.s   .cu_end
.cu_cls:clr.b   cine_active
.cu_end:rts
cine_bar_h:        dc.w 0
cine_talking:      dc.w 0
cine_type_chars:   dc.w 1
cine_active:       dc.b 1,0
cine_target_x:     dc.l 0
cine_target_y:     dc.l 0
cine_target_alt:   dc.w 115
cine_target_pitch: dc.w 110
cine_line1_ptr:    dc.l cine_demo_l1
cine_line2_ptr:    dc.l cine_demo_l2
cine_line3_ptr:    dc.l cine_demo_l3
        IFD LANG_PL
cine_demo_l1:      dc.b "DOW",6,"DZTWO: WITAJ NA AETHER-IV.",0
cine_demo_l2:      dc.b "BAZY W SEKTORZE CZEKAJ",1," NA SYGNA",4,".",0
cine_demo_l3:      dc.b "[1] PRZYJMUJ",3,"   [2] SKAN SEKTORA",0
        ELSE
cine_demo_l1:      dc.b "ORBITAL CMD: WELCOME TO SECTOR 01.",0
cine_demo_l2:      dc.b "DOMES IN SECTOR 01 AWAIT ORDERS.",0
cine_demo_l3:      dc.b "[1] ACKNOWLEDGE   [2] SCAN SECTOR",0
        ENDC
        even
