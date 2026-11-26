        section code,code
exo_run_title_menu:
        movem.l d0-d7/a0-a6,-(sp)
.tm_lp: jsr     wait_vbl
        jsr     input_update_controls
        add.l   #64,cam_y
        clr.w   ship_bank
        jsr     render_voxel_3d
        jsr     exo_draw_ship_and_hud
        bsr.s   exo_draw_menu_bars
        clr.w   bbox_x1
        move.w  #319,bbox_x2
        clr.w   bbox_y1
        move.w  #255,bbox_y2
        jsr     c2p_160x128_to_aga
        move.b  kbd_held_raw,d0
        cmp.b   #$01,d0
        bne.s   .c2
        move.b  #1,player_role
        bra.s   .tm_ok
.c2:    cmp.b   #$02,d0
        bne.s   .c3
        move.b  #2,player_role
        bra.s   .tm_ok
.c3:    cmp.b   #$03,d0
        bne.s   .cf
        move.b  #3,player_role
        bra.s   .tm_ok
.c4:    cmp.b   #$04,d0
        bne.s   .cf
        jsr     exo_load_game
        bra.s   .tm_ok
.cf:    tst.b   fire_held
        beq.w   .tm_lp
        move.b  #1,player_role
.tm_ok: movem.l (sp)+,d0-d7/a0-a6
        rts
exo_draw_menu_bars:
        lea     chunky_buf+26*320+64,a0
        moveq   #15,d7
.mb1:   move.w  #191,d6
.mb1x:  move.b  #128,(a0,d6.w)
        dbf     d6,.mb1x
        adda.w  #320,a0
        dbf     d7,.mb1
        lea     chunky_buf+58*320+40,a0
        moveq   #13,d7
.mb2:   move.w  #239,d6
.mb2x:  move.b  #128,(a0,d6.w)
        dbf     d6,.mb2x
        adda.w  #320,a0
        dbf     d7,.mb2
        lea     chunky_buf+76*320+64,a0
        moveq   #13,d7
.mb3:   move.w  #191,d6
.mb3x:  move.b  #128,(a0,d6.w)
        dbf     d6,.mb3x
        adda.w  #320,a0
        dbf     d7,.mb3
        lea     txt_title(pc),a2
        lea     chunky_buf+31*320+106,a3
        bsr.s   .pr_str
        lea     txt_roles(pc),a2
        lea     chunky_buf+62*320+52,a3
        bsr.s   .pr_str
        lea     txt_load(pc),a2
        lea     chunky_buf+80*320+76,a3
        bsr.s   .pr_str
        rts
.pr_str:
        moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .pr_end
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
        bra.s   .pr_str
.pr_end:
        rts
txt_title: dc.b "EXOPLANET FRONTIER",0
txt_roles: dc.b "1:PIONEER  2:GUARDIAN  3:ENGINEER",0
txt_load:  dc.b "4:LOAD SAVED COLONY (S=SAVE)",0
        even
player_role: dc.b 1,0
