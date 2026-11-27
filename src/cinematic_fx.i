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
        moveq   #0,d0
        move.b  cine_portrait_id(pc),d0
        cmp.w   #5,d0
        ble.s   .pid_ok
        moveq   #5,d0
.pid_ok:
        mulu.w  #2784,d0
        add.l   d0,a2
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
        nop
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
        move.w  #64,d7
        bsr.s   cine_print_n_5x7
.dp_no1:tst.l   cine_line2_ptr
        beq.s   .dp_no2
        move.l  cine_line2_ptr(pc),a2
        lea     chunky_buf+198*320+78,a3
        move.w  #64,d7
        bsr.s   cine_print_n_5x7
.dp_no2:tst.l   cine_line3_ptr
        beq.s   .dp_no3
        move.l  cine_line3_ptr(pc),a2
        lea     chunky_buf+216*320+78,a3
        move.w  #64,d7
        bsr.s   cine_print_n_5x7
.dp_no3:movem.l (sp)+,d0-d7/a0-a4
        rts
cine_print_n_5x7:
        tst.w   d7
        ble.s   .cp_end
        moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .cp_end
        subq.w  #1,d7
        bne.s   .ch_ok
        move.w  #1,cine_talking
.ch_ok: sub.w   #32,d0
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
        bra.s   cine_print_n_5x7
.cp_end:rts

; Przygotowuje tresc dialogu dla bazy wg wybranej profesji (player_role)
; Wejscie: a4 = wskaznik na wpis bazy w exo_bases
cine_open_base_dialogue:
        move.l  a4,docked_base_ptr
        move.b  #1,cine_active
        move.w  #1,cine_type_chars
        cmp.w   #8,domes_online_cnt
        blt.s   .not_fin
        move.b  #5,cine_portrait_id
        move.b  #1,finale_active
        moveq   #56,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #57,d0
        jsr     story_get_str
        move.l  a0,cine_line2_ptr
        moveq   #58,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        rts
.not_fin:
        clr.b   finale_active
        move.b  #2,cine_portrait_id
        cmp.b   #2,player_role
        bne.s   .p_chk3
        clr.b   cine_portrait_id
        bra.s   .p_set
.p_chk3:cmp.b   #3,player_role
        bne.s   .p_set
        move.b  #1,cine_portrait_id
.p_set: tst.b   4(a4)
        bne.s   .base_online
        moveq   #18,d1
        cmp.b   #2,player_role
        bne.s   .chk_e
        moveq   #21,d1
        bra.s   .set_3
.chk_e: cmp.b   #3,player_role
        bne.s   .set_3
        moveq   #24,d1
.set_3: move.w  d1,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        move.w  d1,d0
        addq.w  #1,d0
        jsr     story_get_str
        move.l  a0,cine_line2_ptr
        move.w  d1,d0
        addq.w  #2,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        rts
.base_online:
        moveq   #27,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #28,d0
        jsr     story_get_str
        move.l  a0,cine_line2_ptr
        moveq   #29,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        rts

cine_update_and_draw:
        tst.w   dock_cooldown
        beq.s   .chk_t
        subq.w  #1,dock_cooldown
.chk_t: cmp.b   #$14,kbd_held_raw
        bne.s   .ck_act
        move.b  #1,cine_active
        move.w  #1,cine_type_chars
.ck_act:tst.b   cine_active
        beq.w   .cu_end
        cmp.w   #16,cine_bar_h
        bge.s   .cb_ok
        addq.w  #1,cine_bar_h
.cb_ok: addq.w  #1,cine_type_chars
        bsr.w   cine_draw_dialogue_panel
        jsr     thea1200_draw_mouse_cursor
        cmp.w   #28,cine_type_chars
        blt.w   .cu_end
        bne.s   .ck_key
        move.b  #$ff,kbd_held_raw
        clr.b   mouse_lmb_click
.ck_key:
        move.b  kbd_held_raw,d0
        cmp.b   #$01,d0                 ; Klawisz 1 = wykonaj zlecenie / raportuj
        beq.w   .do_job
        cmp.b   #$44,d0                 ; Enter = wykonaj zlecenie / raportuj
        beq.w   .do_job
        tst.b   mouse_lmb_click
        beq.s   .no_mck
        clr.b   mouse_lmb_click
        cmp.w   #175,mouse_x
        bgt.w   .opt2
        bra.w   .do_job
.no_mck:
        cmp.b   #$02,d0                 ; Klawisz 2 = raport zwiadu w intro lub odlot
        beq.w   .opt2
        cmp.b   #$03,d0                 ; Klawisz 3 = sygnal anomalii w intro
        beq.w   .opt3
        bra.w   .cu_end
.opt2:  tst.b   finale_active
        beq.s   .o2_n
        moveq   #60,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #29,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        clr.b   finale_active
        clr.b   cine_active
        move.b  #1,epilogue_choice
        jsr     exo_run_story_epilogue
        bra.w   .cu_cls
.o2_n:  tst.l   docked_base_ptr
        bne.w   .cu_cls
        moveq   #9,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #11,d0
        jsr     story_get_str
        move.l  a0,cine_line2_ptr
        moveq   #29,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        move.w  #1,cine_type_chars
        move.b  #$ff,kbd_held_raw
        bra.w   .cu_end
.opt3:  tst.b   finale_active
        beq.s   .o3_n
        moveq   #61,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #29,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        clr.b   finale_active
        clr.b   cine_active
        move.b  #2,epilogue_choice
        jsr     exo_run_story_epilogue
        bra.w   .cu_cls
.o3_n:  tst.l   docked_base_ptr
        bne.w   .cu_cls
        moveq   #10,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #11,d0
        jsr     story_get_str
        move.l  a0,cine_line2_ptr
        moveq   #29,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        move.w  #1,cine_type_chars
        move.b  #$ff,kbd_held_raw
        bra.w   .cu_end
.do_job:
        tst.b   finale_active
        beq.s   .norm_job
        moveq   #59,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #27,d0
        jsr     story_get_str
        move.l  a0,cine_line2_ptr
        moveq   #29,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        clr.b   finale_active
        clr.b   cine_active
        clr.b   epilogue_choice
        jsr     exo_run_story_epilogue
        bra.w   .cu_cls
.norm_job:
        move.l  docked_base_ptr(pc),d1
        beq.w   .cu_cls
        move.l  d1,a4
        tst.b   4(a4)
        bne.w   .cu_cls
        move.b  #1,4(a4)
        addq.w  #1,missions_done
        add.w   #15,terraform_pct
        add.l   #150,colony_credits
        cmp.b   #3,player_role
        bne.s   .jb_sfx
        add.w   #10,terraform_pct
        add.l   #50,colony_credits
.jb_sfx:jsr     exo_play_sfx_ping
        jsr     story_sync_dynamic_state
.cu_cls:clr.b   cine_active
        clr.l   docked_base_ptr
        move.w  #240,dock_cooldown
        move.b  #$ff,kbd_held_raw
        clr.b   mouse_lmb_click
.cu_end:rts

cine_bar_h:        dc.w 0
cine_talking:      dc.w 0
cine_type_chars:   dc.w 1
cine_active:       dc.b 1,0
dock_cooldown:     dc.w 0
docked_base_ptr:   dc.l 0
cine_target_x:     dc.l 0
cine_target_y:     dc.l 0
cine_target_alt:   dc.w 115
cine_target_pitch: dc.w 110
cine_line1_ptr:    dc.l cine_demo_l1
cine_line2_ptr:    dc.l cine_demo_l2
cine_line3_ptr:    dc.l cine_demo_l3
cine_demo_l1:      dc.b "ORBITAL CMD: WELCOME TO SECTOR 01.",0
cine_demo_l2:      dc.b "DOMES IN SECTOR 01 AWAIT ORDERS.",0
cine_demo_l3:      dc.b "[1] ACKNOWLEDGE   [2] SCAN SECTOR",0
cine_pio_l1:       dc.b "SECTOR OFC: PIONEER RECON DATA?",0
cine_pio_l2:       dc.b "UPLOAD GEO-SCAN TO LINK OUTPOST.",0
cine_grd_l1:       dc.b "OUTPOST CMD: PERIMETER SECURED?",0
cine_grd_l2:       dc.b "LOG PATROL REPORT FOR COLONY HQ.",0
cine_eng_l1:       dc.b "CHIEF ENG: DOME REACTOR STANDBY.",0
cine_eng_l2:       dc.b "ENGAGE GRID POWER (+200 CREDITS).",0
cine_act_l3:       dc.b "[1] COMPLETE JOB   [2] DEPART",0
cine_onl_l1:       dc.b "OUTPOST CMD: DOME SYSTEMS ONLINE.",0
cine_onl_l2:       dc.b "ALL LIFE SUPPORT NOMINAL, PILOT.",0
cine_onl_l3:       dc.b "[1/2] RETURN TO PATROL",0
        even

        even
cine_portrait_id: dc.b 0
finale_active:    dc.b 0
        even
