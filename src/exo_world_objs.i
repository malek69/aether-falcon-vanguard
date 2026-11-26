        section code,code
exo_update_and_draw_world:
        movem.l d0-d7/a0-a5,-(sp)
        lea     exo_bases(pc),a4
        moveq   #7,d7
.b_lp:  move.w  (a4),d0
        move.b  cam_x+2(pc),d1
        ext.w   d1
        sub.w   d1,d0
        ext.w   d0
        move.w  2(a4),d1
        move.b  cam_y+2(pc),d2
        ext.w   d2
        sub.w   d2,d1
        ext.w   d1
        lea     sin_tab,a0
        move.w  cam_yaw(pc),d2
        and.w   #255,d2
        add.w   d2,d2
        move.w  (a0,d2.w),d3
        sub.w   #128,d2
        and.w   #510,d2
        move.w  (a0,d2.w),d4
        move.w  d0,d5
        muls.w  d3,d5
        move.w  d1,d6
        muls.w  d4,d6
        add.l   d6,d5
        asr.l   #8,d5
        cmp.w   #8,d5
        blt.w   .b_nx
        cmp.w   #120,d5
        bgt.w   .b_nx
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        asl.l   #7,d1
        divs.w  d5,d1
        add.w   #160,d1
        cmp.w   #16,d1
        blt.w   .b_nx
        cmp.w   #304,d1
        bgt.w   .b_nx
        tst.b   fire_held
        beq.s   .no_act
        cmp.w   #28,d5
        bgt.s   .no_act
        tst.b   4(a4)
        bne.s   .no_act
        move.b  #1,4(a4)
        add.w   #15,terraform_pct
        lea     chunky_buf+128*320+160,a2
        moveq   #36,d0
.bm_lp: move.b  #158,(a2)
        move.b  #158,1(a2)
        suba.w  #320,a2
        dbf     d0,.bm_lp
        jsr     exo_play_sfx_ping
        jsr     exo_save_game
        cmp.b   #3,player_role
        bne.s   .r_ok
        add.w   #10,terraform_pct
.r_ok:
        lea     chunky_buf+140*320+160,a2
        moveq   #25,d0
.bm_l:  move.b  #158,(a2)
        move.b  #158,1(a2)
        suba.w  #320,a2
        dbf     d0,.bm_l
.no_act:lea     vx_ybuf,a1
        move.w  d1,d2
        add.w   d2,d2
        move.w  (a1,d2.w),d3
        cmp.w   #115,d3
        blt.s   .b_nx
        move.w  #180,d4
        divs.w  d5,d4
        cmp.w   #18,d4
        ble.s   .sz_m
        moveq   #18,d4
.sz_m:
        cmp.w   #3,d4
        bge.s   .sz_ok
        moveq   #3,d4
.sz_ok: move.b  #122,d6
        tst.b   4(a4)
        beq.s   .dr_bm
        move.b  #156,d6
.dr_bm: bsr.s   exo_draw_dome_sprite
.b_nx:  addq.l  #6,a4
        dbf     d7,.b_lp
        bsr.s   exo_draw_hud_and_radar
        movem.l (sp)+,d0-d7/a0-a5
        rts
exo_draw_dome_sprite:
        movem.l d0-d7/a0-a2,-(sp)
        lea     chunky_buf,a0
        sub.w   d4,d3
        move.w  d4,d5
        add.w   d5,d5
.dy_lp: cmp.w   #20,d3
        blt.s   .dy_nx
        cmp.w   #250,d3
        bgt.s   .dy_nx
        move.w  d3,d0
        mulu.w  #320,d0
        lea     (a0,d0.l),a1
        move.w  d1,d2
        sub.w   d4,d2
        move.w  d5,d0
.dx_lp: cmp.w   #4,d2
        blt.s   .dx_nx
        cmp.w   #315,d2
        bgt.s   .dx_nx
        move.b  d6,(a1,d2.w)
.dx_nx: addq.w  #1,d2
        dbf     d0,.dx_lp
.dy_nx: addq.w  #1,d3
        dbf     d4,.dy_lp
        movem.l (sp)+,d0-d7/a0-a2
        rts
exo_draw_hud_and_radar:
        lea     chunky_buf,a0
        move.w  terraform_pct(pc),d4
        lea     10*320+12(a0),a1
        moveq   #119,d5
.pb_lp: move.b  #128,d2
        cmp.w   d4,d5
        bgt.s   .pb_c
        move.b  #156,d2
.pb_c:  move.b  d2,(a1,d5.w)
        move.b  d2,320(a1,d5.w)
        move.b  d2,640(a1,d5.w)
        move.b  d2,960(a1,d5.w)
        dbf     d5,.pb_lp
        move.b  #158,d0
        move.b  d0,124*320+160(a0)
        move.b  d0,128*320+160(a0)
        move.b  d0,126*320+156(a0)
        move.b  d0,126*320+164(a0)
        lea     210*320+274(a0),a1
        moveq   #35,d7
.rd_y:  moveq   #35,d6
.rd_x:  move.b  #128,(a1,d6.w)
        dbf     d6,.rd_x
        adda.w  #320,a1
        dbf     d7,.rd_y
        moveq   #0,d0
        move.b  cam_x+2(pc),d0
        lsr.w   #3,d0
        moveq   #0,d1
        move.b  cam_y+2(pc),d1
        lsr.w   #3,d1
        mulu.w  #320,d1
        lea     212*320+276(a0),a1
        add.l   d1,a1
        move.b  #255,(a1,d0.w)
        lea     exo_bases(pc),a2
        moveq   #7,d7
.rb_lp: move.w  (a2),d0
        and.w   #255,d0
        lsr.w   #3,d0
        move.w  2(a2),d1
        and.w   #255,d1
        lsr.w   #3,d1
        mulu.w  #320,d1
        lea     212*320+276(a0),a1
        add.l   d1,a1
        move.b  #122,d2
        tst.b   4(a2)
        beq.s   .rb_c
        move.b  #156,d2
.rb_c:  move.b  d2,(a1,d0.w)
        addq.l  #6,a2
        dbf     d7,.rb_lp
        rts
        even
terraform_pct: dc.w 0
exo_bases:
        dc.w  40, 40,0,  110, 65,0,  190, 50,0,  220,130,0
        dc.w 175,205,0,   95,215,0,   35,170,0,  130,130,0
