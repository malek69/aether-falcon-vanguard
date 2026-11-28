        section code,code
exo_check_victory:
        cmp.w   #100,terraform_pct
        blt.w   .cv_no
        tst.b   victory_shown
        bne.w   .cv_no
        move.b  #1,victory_shown
        jsr     exo_save_game
        jsr     exo_play_sfx_ping
.vc_lp: jsr     wait_vbl
        jsr     input_update_controls
        add.l   #64,cam_y
        jsr     render_voxel_3d
        jsr     exo_draw_ship_and_hud
        lea     chunky_buf+44*320+44,a0
        moveq   #21,d7
.vb_y:  move.w  #231,d6
.vb_x:  move.b  #128,(a0,d6.w)
        dbf     d6,.vb_x
        adda.w  #320,a0
        dbf     d7,.vb_y
        lea     txt_vic1(pc),a2
        lea     chunky_buf+48*320+66,a3
        jsr     exo_hud_str
        lea     txt_vic2(pc),a2
        lea     chunky_buf+58*320+72,a3
        jsr     exo_hud_str
        clr.w   bbox_x1
        move.w  #319,bbox_x2
        clr.w   bbox_y1
        move.w  #255,bbox_y2
        jsr     c2p_160x128_to_aga
        tst.b   fire_held
        beq.s   .vc_lp
.cv_no: rts
victory_shown: dc.b 0,0
txt_vic1: dc.b "TERRAFORMING COMPLETE 100%",0
txt_vic2: dc.b "COLONY ONLINE - PRESS FIRE",0
        even
