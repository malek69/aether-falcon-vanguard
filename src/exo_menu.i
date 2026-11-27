        section code,code
exo_run_title_menu:
        movem.l d0-d7/a0-a6,-(sp)
        bsr.w   exo_run_story_prologue
        clr.w   aga_fade_lvl
        move.w  #64,cam_yaw
        move.w  #64,user_yaw
.tm_lp: jsr     wait_vbl
        jsr     input_update_controls
        jsr     thea1200_read_peripherals
        sub.l   #128,cam_y
        clr.w   ship_bank
        jsr     render_voxel_3d
        jsr     exo_draw_ship_and_hud
        bsr.w   exo_draw_menu_bars
        cmp.w   #22,cine_bar_h
        bge.s   .lb_ok
        addq.w  #1,cine_bar_h
.lb_ok: jsr     cine_draw_letterbox
        clr.w   bbox_x1
        move.w  #319,bbox_x2
        clr.w   bbox_y1
        move.w  #255,bbox_y2
        jsr     c2p_160x128_to_aga
        move.b  kbd_held_raw,d0
        cmp.b   #$01,d0
        bne.s   .c2
        move.b  #1,player_role
        bra.w   .tm_ok
.c2:    cmp.b   #$02,d0
        bne.s   .c3
        move.b  #2,player_role
        bra.w   .tm_ok
.c3:    cmp.b   #$03,d0
        bne.s   .c4
        move.b  #3,player_role
        bra.w   .tm_ok
.c4:    cmp.b   #$04,d0
        bne.s   .cf
        jsr     exo_load_game
        bra.w   .tm_ok
.cf:    tst.b   mouse_lmb_click
        beq.s   .cf_key
        move.w  mouse_y(pc),d1
        cmp.w   #56,d1
        blt.s   .cf_key
        cmp.w   #74,d1
        bgt.s   .m_ld
        move.w  mouse_x(pc),d0
        cmp.w   #130,d0
        bge.s   .mr2
        move.b  #1,player_role
        bra.w   .tm_ok
.mr2:   cmp.w   #215,d0
        bge.s   .mr3
        move.b  #2,player_role
        bra.w   .tm_ok
.mr3:   move.b  #3,player_role
        bra.w   .tm_ok
.m_ld:  cmp.w   #92,d1
        bgt.s   .cf_key
        jsr     exo_load_game
        bra.w   .tm_ok
.cf_key:tst.b   fire_held
        beq.w   .tm_lp
        move.b  #1,player_role
.tm_ok: clr.b   fire_held
        clr.b   tool_held
        clr.b   mouse_lmb_click
        move.b  #$ff,kbd_held_raw
        clr.w   ship_bank
        move.w  #96,user_yaw
        move.w  #96,cam_yaw
        move.b  #1,intro_turn_done
        moveq   #1,d0
        jsr     audio_switch_track
        movem.l (sp)+,d0-d7/a0-a6
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
        moveq   #0,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+31*320+106,a3
        bsr.s   .pr_str
        moveq   #1,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+62*320+52,a3
        bsr.s   .pr_str
        moveq   #2,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+80*320+76,a3
        bsr.s   .pr_str
        rts
.pr_str:
        moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .pr_end
        sub.w   #32,d0
        lsl.w   #3,d0
        lea     exo_font_5x7,a4
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
txt_load:  dc.b "4:LOAD SAVED COLONY (F5=SAVE)",0
        even
player_role: dc.b 1,0

; Ekran wprowadzenia fabularnego przed wyborem zawodu
exo_run_story_prologue:
        move.w  #64,cam_yaw
        move.w  #64,user_yaw
        move.b  #$ff,kbd_held_raw
        clr.b   mouse_lmb_click
.pr_lp: jsr     wait_vbl
        jsr     input_update_controls
        jsr     thea1200_read_peripherals
        sub.l   #96,cam_y
        clr.w   ship_bank
        jsr     render_voxel_3d
        jsr     exo_draw_ship_and_hud
        cmp.w   #22,cine_bar_h
        bge.s   .plb
        addq.w  #1,cine_bar_h
.plb:   jsr     cine_draw_letterbox
        ; Panel prologu (Y=44..148, X=28..292)
        lea     chunky_buf+44*320+28,a0
        moveq   #102,d7
.py:    move.w  #263,d6
.px:    move.b  #128,(a0,d6.w)
        dbf     d6,.px
        adda.w  #320,a0
        dbf     d7,.py
        lea     chunky_buf+44*320+28,a0
        move.w  #263,d6
.pbd:   move.b  #156,(a0,d6.w)
        move.b  #156,102*320(a0,d6.w)
        dbf     d6,.pbd

        moveq   #62,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+52*320+40,a3
        jsr     exo_print_str_pl
        moveq   #63,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+68*320+40,a3
        jsr     exo_print_str_pl
        moveq   #64,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+82*320+40,a3
        jsr     exo_print_str_pl
        moveq   #65,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+96*320+40,a3
        jsr     exo_print_str_pl
        moveq   #66,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+110*320+40,a3
        jsr     exo_print_str_pl
        moveq   #67,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+130*320+62,a3
        jsr     exo_print_str_pl

        clr.w   bbox_x1
        move.w  #319,bbox_x2
        clr.w   bbox_y1
        move.w  #255,bbox_y2
        jsr     c2p_160x128_to_aga

        move.b  kbd_held_raw,d0
        cmp.b   #$40,d0                 ; Spacja
        beq.s   .pr_ok
        cmp.b   #$44,d0                 ; Enter
        beq.s   .pr_ok
        tst.b   mouse_lmb_click
        bne.s   .pr_ok
        tst.b   fire_held
        beq.w   .pr_lp
.pr_ok: clr.b   fire_held
        clr.b   mouse_lmb_click
        move.b  #$ff,kbd_held_raw
        rts

; Pelnoekranowy Epilog po finale Aktu III (epilogue_choice: 0..2)
exo_run_story_epilogue:
        movem.l d0-d7/a0-a6,-(sp)
        moveq   #0,d0
        jsr     audio_switch_track
        move.b  #$ff,kbd_held_raw
        clr.b   mouse_lmb_click
.ep_lp: jsr     wait_vbl
        jsr     input_update_controls
        jsr     thea1200_read_peripherals
        sub.l   #64,cam_y
        addq.w  #1,cam_yaw
        jsr     render_voxel_3d
        jsr     exo_draw_ship_and_hud
        jsr     cine_draw_letterbox
        lea     chunky_buf+48*320+28,a0
        moveq   #106,d7
.ey:    move.w  #263,d6
.ex:    move.b  #128,(a0,d6.w)
        dbf     d6,.ex
        adda.w  #320,a0
        dbf     d7,.ey
        lea     chunky_buf+48*320+28,a0
        move.w  #263,d6
.ebd:   move.b  #190,(a0,d6.w)
        move.b  #190,106*320(a0,d6.w)
        dbf     d6,.ebd

        moveq   #68,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+58*320+44,a3
        jsr     exo_print_str_pl

        moveq   #69,d0
        add.b   epilogue_choice(pc),d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+78*320+44,a3
        jsr     exo_print_str_pl

        moveq   #72,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+96*320+44,a3
        jsr     exo_print_str_pl

        moveq   #73,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+112*320+44,a3
        jsr     exo_print_str_pl

        moveq   #74,d0
        jsr     story_get_str
        move.l  a0,a2
        lea     chunky_buf+134*320+64,a3
        jsr     exo_print_str_pl

        clr.w   bbox_x1
        move.w  #319,bbox_x2
        clr.w   bbox_y1
        move.w  #255,bbox_y2
        jsr     c2p_160x128_to_aga

        move.b  kbd_held_raw,d0
        cmp.b   #$40,d0
        beq.s   .ep_ok
        cmp.b   #$44,d0
        beq.s   .ep_ok
        tst.b   mouse_lmb_click
        bne.s   .ep_ok
        tst.b   fire_held
        beq.w   .ep_lp
.ep_ok: clr.b   fire_held
        clr.b   mouse_lmb_click
        move.b  #$ff,kbd_held_raw
        moveq   #1,d0
        jsr     audio_switch_track
        movem.l (sp)+,d0-d7/a0-a6
        rts

epilogue_choice: dc.b 0,0
