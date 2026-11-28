        section code,code
exo_update_and_draw_world:
        movem.l d0-d7/a0-a5,-(sp)
        clr.b   dock_in_zone
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
        ; Tylko INZYNIER (role=3) dokuje i odbudowuje bazy kolonii!
        cmp.b   #3,player_role
        bne.w   .nd_chk
        tst.b   4(a4)
        bne.w   .nd_chk
        move.w  d0,d2
        bpl.s   .dx_p
        neg.w   d2
.dx_p:  cmp.w   #13,d2
        bgt.w   .nd_chk
        move.w  d1,d3
        bpl.s   .dy_p
        neg.w   d3
.dy_p:  cmp.w   #13,d3
        bgt.w   .nd_chk
        cmp.b   #1,ship_throttle
        bgt.w   .nd_chk
        move.b  #1,dock_in_zone
        addq.w  #1,dock_progress
        cmp.w   #48,dock_progress
        blt.s   .nd_chk
        clr.w   dock_progress
        move.b  #1,4(a4)
        addq.w  #1,role_contracts_done
        add.w   #25,terraform_pct
        add.l   #180,colony_credits
        cmp.w   #100,terraform_pct
        ble.s   .dk_ok
        move.w  #100,terraform_pct
.dk_ok: movem.l d0-d1/a4,-(sp)
        jsr     exo_play_sfx_dock
        jsr     exo_advance_role_story
        jsr     exo_save_game
        movem.l (sp)+,d0-d1/a4
.nd_chk:lea     sin_tab,a0
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
        cmp.w   #26,d5
        blt.w   .b_nx
        cmp.w   #120,d5
        bgt.w   .b_nx
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        cmp.w   #-120,d1
        blt.w   .b_nx
        cmp.w   #120,d1
        bgt.w   .b_nx
        asl.l   #7,d1
        divs.w  d5,d1
        add.w   #160,d1
        cmp.w   #16,d1
        blt.w   .b_nx
        cmp.w   #304,d1
        bgt.w   .b_nx
        tst.b   fire_held
        beq.w   .no_act
        cmp.b   #3,player_role
        bne.w   .no_act
        moveq   #42,d2                  ; Wiazka konstrukcyjna Inzyniera odbudowuje kopuly i wieze!
        cmp.w   d2,d5
        bgt.w   .no_act
        tst.b   4(a4)
        bne.w   .no_act
        move.b  #1,4(a4)
        addq.w  #1,role_contracts_done
        add.w   #25,terraform_pct
        add.l   #180,colony_credits
        cmp.w   #100,terraform_pct
        ble.s   .tf_b1
        move.w  #100,terraform_pct
.tf_b1: move.b  #190,d6
.r_ok:  ; Wznies zlota wieze przekaznikowa w wokselach odbudowanej bazy
        move.w  2(a4),d2
        and.w   #255,d2
        lsl.w   #8,d2
        move.w  (a4),d0
        and.w   #255,d0
        or.w    d0,d2
        and.l   #$ffff,d2
        lea     exo_voxel_data,a0
        move.b  #54,(a0,d2.l)
        move.b  #190,65536(a0,d2.l)
        move.w  d1,d0
        moveq   #124,d1
        jsr     vec3d_spawn_particles
        jsr     exo_play_sfx_dock
        jsr     exo_advance_role_story
        jsr     exo_save_game
.no_act:
.b_nx:  addq.l  #6,a4
        dbf     d7,.b_lp
        tst.b   dock_in_zone
        bne.s   .dk_kp
        clr.w   dock_progress
.dk_kp: bsr.w   exo_update_crystals
        bsr.w   exo_update_drones
        bsr.w   exo_draw_hud_and_radar
        movem.l (sp)+,d0-d7/a0-a5
        rts
exo_update_crystals:
        lea     exo_crystals(pc),a4
        moveq   #7,d7
.cr_lp: tst.b   4(a4)
        bne.w   .cr_nx
        move.w  (a4),d0
        move.b  cam_x+2(pc),d1
        ext.w   d1
        sub.w   d1,d0
        move.w  2(a4),d1
        move.b  cam_y+2(pc),d2
        ext.w   d2
        sub.w   d2,d1
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
        cmp.w   #14,d5
        blt.w   .cr_nx
        cmp.w   #90,d5
        bgt.w   .cr_nx
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        cmp.w   #-110,d1
        blt.w   .cr_nx
        cmp.w   #110,d1
        bgt.w   .cr_nx
        asl.l   #7,d1
        divs.w  d5,d1
        add.w   #160,d1
        cmp.w   #20,d1
        blt.w   .cr_nx
        cmp.w   #300,d1
        bgt.w   .cr_nx
        ; Pionier (role=1) skanuje 8 krysztalow Aetheru wiazka F / LMB (jego glowne zadanie 1..8!)
        cmp.b   #1,player_role
        bne.w   .cr_nx
        tst.b   fire_held
        beq.w   .cr_nx
        cmp.w   #54,d5
        bgt.w   .cr_nx
        cmp.w   #120,d1
        blt.w   .cr_nx
        cmp.w   #200,d1
        bgt.w   .cr_nx
        move.b  #1,4(a4)
        addq.w  #1,role_contracts_done
        add.w   #13,terraform_pct
        cmp.w   #100,terraform_pct
        ble.s   .tf_c1
        move.w  #100,terraform_pct
.tf_c1: add.l   #200,colony_credits
        move.w  d1,d0
        moveq   #122,d1
        move.b  #159,d6
        jsr     vec3d_spawn_particles
        jsr     exo_play_sfx_ping
        jsr     exo_advance_role_story
        jsr     exo_save_game
.cr_nx: addq.l  #6,a4
        dbf     d7,.cr_lp
        rts

exo_update_drones:
        tst.b   fire_held
        beq.w   .no_lz
        move.b  #159,d6                 ; Pionier: turkusowy skaner geologiczny
        cmp.b   #2,player_role
        bne.s   .lz_3
        move.b  #188,d6                 ; Straznik: czerwono-zloty impuls dzialka
        bra.s   .lz_c
.lz_3:  cmp.b   #3,player_role
        bne.s   .lz_c
        move.b  #190,d6                 ; Inzynier: bursztynowa wiazka naprawcza
.lz_c:  jsr     vec3d_draw_laser_3d
        lea     chunky_buf+126*320+160,a2
        cmp.b   #1,player_role
        bne.s   .fx_g
        moveq   #-10,d0
.sc_lp: move.b  #159,(a2,d0.w)
        addq.w  #1,d0
        cmp.w   #10,d0
        ble.s   .sc_lp
        bra.s   .no_lz
.fx_g:  cmp.b   #2,player_role
        bne.s   .fx_e
        move.b  #255,-2(a2)
        move.b  #255,2(a2)
        move.b  #188,-322(a2)
        move.b  #188,-318(a2)
        bra.s   .no_lz
.fx_e:  move.b  #190,-321(a2)
        move.b  #190,-319(a2)
        move.b  #190,319(a2)
        move.b  #190,321(a2)
        move.b  #255,(a2)
.no_lz: lea     exo_drones(pc),a4
        moveq   #7,d7
.dl_lp: tst.b   4(a4)
        bne.w   .dl_nx
        addq.b  #1,5(a4)
        cmp.b   #6,5(a4)
        blt.s   .dr_mv
        clr.b   5(a4)
        addq.w  #1,(a4)
        and.w   #255,(a4)
.dr_mv:
        move.w  (a4),d0
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
        cmp.w   #10,d5
        blt.w   .dl_nx
        cmp.w   #110,d5
        bgt.w   .dl_nx
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        cmp.w   #-120,d1
        blt.w   .dl_nx
        cmp.w   #120,d1
        bgt.w   .dl_nx
        asl.l   #7,d1
        divs.w  d5,d1
        add.w   #160,d1
        cmp.w   #20,d1
        blt.w   .dl_nx
        cmp.w   #300,d1
        bgt.w   .dl_nx
        tst.b   fire_held
        beq.s   .dl_dr
        cmp.b   #2,player_role
        bne.s   .dl_dr
        cmp.w   #142,d1
        blt.s   .dl_dr
        cmp.w   #178,d1
        bgt.s   .dl_dr
        move.b  #1,4(a4)
        addq.w  #1,role_contracts_done
        add.w   #13,terraform_pct
        cmp.w   #100,terraform_pct
        ble.s   .tf_d1
        move.w  #100,terraform_pct
.tf_d1: add.l   #250,colony_credits
        move.w  d1,d0
        moveq   #122,d1
        move.b  #188,d6
        jsr     vec3d_spawn_particles
        jsr     exo_play_sfx_ping
        jsr     exo_advance_role_story
        jsr     exo_save_game
        bra.w   .dl_nx
.dl_dr: move.w  #140,d4
        divs.w  d5,d4
        cmp.w   #3,d4
        bge.s   .ds_ok
        moveq   #3,d4
.ds_ok: cmp.w   #14,d4
        ble.s   .ds_m
        moveq   #14,d4
.ds_m:  lea     vx_ybuf,a1
        move.w  d1,d2
        add.w   d2,d2
        move.w  (a1,d2.w),d0
        cmp.w   #96,d0
        blt.w   .dl_nx
        move.w  d1,d4
        sub.w   #160,d4
        move.w  d5,d6
        asl.w   #2,d6
        muls.w  d6,d4
        asr.l   #8,d4
        moveq   #-22,d5
        muls.w  d6,d5
        asr.l   #8,d5
        move.w  d6,d0
        sub.w   #150,d6
        lsl.w   #2,d0
        move.w  d0,d1
        moveq   #18,d2
        lea     exo_drone_mesh_v(pc),a0
        lea     exo_drone_mesh_n(pc),a2
        lea     exo_drone_mesh_t(pc),a3
        jsr     vec3d_draw_ground_shadow
        move.w  d7,-(sp)
        moveq   #6,d7
        jsr     vec3d_draw_mesh_3d
        move.w  (sp)+,d7
.dl_nx: addq.l  #6,a4
        dbf     d7,.dl_lp
        rts
exo_crystals:
        dc.w 246, 46,0,  214, 54,0,   82, 48,0,  168, 92,0
        dc.w 204,178,0,  132,224,0,   52,202,0,   74,118,0
exo_drones:
        dc.w  60, 55,0, 180, 75,0, 150,190,0,  55,185,0
        dc.w 115, 42,0, 215,120,0,  90,145,0, 175,220,0
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
        ; Pasek postepu dokowania na srodku HUD gdy pojazd zawisa nad plyta ladowiska
        move.w  dock_progress(pc),d4
        beq.s   .no_dkb
        lea     196*320+136(a0),a1
        moveq   #47,d5
.dk_bl: move.b  #128,d2
        cmp.w   d4,d5
        bgt.s   .dk_bc
        move.b  #190,d2
.dk_bc: move.b  d2,(a1,d5.w)
        move.b  d2,320(a1,d5.w)
        move.b  d2,640(a1,d5.w)
        dbf     d5,.dk_bl
.no_dkb:
        ; Gorny kompas 360 st. (Y=4, X=112..208) - N / E / S / W
        lea     chunky_buf+3*320+112,a1
        moveq   #95,d6
.cp_bg: move.b  #128,(a1,d6.w)
        move.b  #128,320(a1,d6.w)
        move.b  #128,640(a1,d6.w)
        dbf     d6,.cp_bg
        move.b  #255,chunky_buf+2*320+160
        move.b  #190,chunky_buf+6*320+160
        lea     .cp_dirs(pc),a2
        moveq   #3,d7
.cp_lp: move.w  (a2)+,d0
        sub.w   cam_yaw(pc),d0
        ext.w   d0
        cmp.w   #-128,d0
        bge.s   .cp_w1
        add.w   #256,d0
.cp_w1: cmp.w   #128,d0
        ble.s   .cp_w2
        sub.w   #256,d0
.cp_w2: cmp.w   #-44,d0
        blt.s   .cp_sk
        cmp.w   #44,d0
        bgt.s   .cp_sk
        add.w   #158,d0
        lea     chunky_buf+1*320,a3
        add.w   d0,a3
        move.b  (a2),d0
        bsr.w   exo_hud_chr
        bra.s   .cp_nx
.cp_sk: addq.l  #1,a2
        bra.s   .cp_n2
.cp_nx: addq.l  #1,a2
.cp_n2: dbf     d7,.cp_lp

        ; Obrotowy radar 360 st. w prawym dolnym rogu (centrum 292, 228, promien 17)
        lea     210*320+274(a0),a1
        moveq   #35,d7
.rd_y:  moveq   #35,d6
.rd_x:  move.b  #128,(a1,d6.w)
        dbf     d6,.rd_x
        adda.w  #320,a1
        dbf     d7,.rd_y
        ; Krzyz siatki radarowej i ramka dalekiego zasiegu
        moveq   #33,d6
        lea     228*320+275(a0),a1
.rg_h:  move.b  #134,(a1,d6.w)
        dbf     d6,.rg_h
        moveq   #33,d6
        lea     211*320+292(a0),a1
.rg_v:  move.b  #134,(a1)
        adda.w  #320,a1
        dbf     d6,.rg_v
        ; Ramka i znacznik dziobu (gora radaru = kierunek lotu)
        move.b  #156,210*320+292(a0)
        move.b  #255,211*320+292(a0)
        move.b  #255,228*320+292(a0)
        ; Oblicz sin/cos(-cam_yaw) dla obrotu punktow na radarze
        lea     sin_tab,a1
        move.w  cam_yaw(pc),d2
        and.w   #255,d2
        add.w   d2,d2
        move.w  (a1,d2.w),d3            ; fwd_x
        sub.w   #128,d2
        and.w   #510,d2
        move.w  (a1,d2.w),d4            ; fwd_y
        ; Rysuj 8 baz, 8 krysztalow i 8 dronow na radarze 360 oraz kieruj strzalke na cel PROFESJI!
        move.w  #32000,nearest_base_dist
        clr.w   nearest_base_rx
        clr.w   nearest_base_ry
        lea     exo_bases(pc),a2
        moveq   #7,d7
.rb_lp: move.b  #158,d6
        tst.b   4(a2)
        beq.s   .rb_c
        move.b  #190,d6
.rb_c:  bsr.w   exo_plot_radar_pt
        cmp.b   #3,player_role
        bne.s   .rb_nx
        tst.b   4(a2)
        bne.s   .rb_nx
        bsr.w   exo_upd_nearest
.rb_nx: addq.l  #6,a2
        dbf     d7,.rb_lp
        lea     exo_crystals(pc),a2
        moveq   #7,d7
.rc_lp: tst.b   4(a2)
        bne.s   .rc_nx
        move.b  #159,d6
        bsr.w   exo_plot_radar_pt
        cmp.b   #1,player_role
        bne.s   .rc_nx
        bsr.w   exo_upd_nearest
.rc_nx: addq.l  #6,a2
        dbf     d7,.rc_lp
        lea     exo_drones(pc),a2
        moveq   #7,d7
.rdr_l: tst.b   4(a2)
        bne.s   .rdr_n
        move.b  #188,d6
        bsr.w   exo_plot_radar_pt
        cmp.b   #2,player_role
        bne.s   .rdr_n
        bsr.w   exo_upd_nearest
.rdr_n: addq.l  #6,a2
        dbf     d7,.rdr_l
        ; Strzalka kompasu na krawedzi radaru wskazujaca najblizsza nieaktywna baze
        cmp.w   #32000,nearest_base_dist
        beq.s   .no_arr
        move.w  nearest_base_rx(pc),d0
        move.w  nearest_base_ry(pc),d5
        add.w   #292,d0
        add.w   #228,d5
        cmp.w   #275,d0
        bge.s   .ar_x1
        move.w  #275,d0
.ar_x1: cmp.w   #308,d0
        ble.s   .ar_x2
        move.w  #308,d0
.ar_x2: cmp.w   #211,d5
        bge.s   .ar_y1
        move.w  #211,d5
.ar_y1: cmp.w   #244,d5
        ble.s   .ar_y2
        move.w  #244,d5
.ar_y2: mulu.w  #320,d5
        add.w   d0,d5
        move.b  #255,(a0,d5.l)
        move.b  #190,1(a0,d5.l)
.no_arr:
        ; Pasek statusu kolonisty pod paskiem terraformacji: [KLASA] X/8 CR:XXXX
        lea     chunky_buf+17*320+12,a3
        lea     exo_lbl_pio(pc),a2
        cmp.b   #2,player_role
        bne.s   .hr3
        lea     exo_lbl_grd(pc),a2
        bra.s   .hr_pr
.hr3:   cmp.b   #3,player_role
        bne.s   .hr_pr
        lea     exo_lbl_eng(pc),a2
.hr_pr: bsr.w   exo_hud_str
        addq.l  #4,a3
        move.w  role_contracts_done(pc),d0
        and.w   #$000f,d0
        add.b   #"0",d0
        bsr.w   exo_hud_chr
        move.b  #"/",d0
        bsr.w   exo_hud_chr
        move.b  #"8",d0
        bsr.w   exo_hud_chr
        addq.l  #6,a3
        lea     exo_lbl_cr(pc),a2
        bsr.w   exo_hud_str
        move.l  colony_credits(pc),d2
        cmp.l   #9999,d2
        ble.s   .cr_ok
        move.l  #9999,d2
.cr_ok: divu.w  #1000,d2
        move.b  d2,d0
        add.b   #"0",d0
        bsr.w   exo_hud_chr
        swap    d2
        and.l   #$ffff,d2
        divu.w  #100,d2
        move.b  d2,d0
        add.b   #"0",d0
        bsr.w   exo_hud_chr
        swap    d2
        and.l   #$ffff,d2
        divu.w  #10,d2
        move.b  d2,d0
        add.b   #"0",d0
        bsr.w   exo_hud_chr
        swap    d2
        move.b  d2,d0
        add.b   #"0",d0
        bsr.w   exo_hud_chr
        ; Wspolrzedne sektora X:000 Y:000 na HUD (skala otwartego swiata 256x256)
        addq.l  #6,a3
        lea     .lbl_xy(pc),a2
        bsr.w   exo_hud_str
        moveq   #0,d2
        move.b  cam_x+2(pc),d2
        bsr.s   .hud_3d
        move.b  #"/",d0
        bsr.w   exo_hud_chr
        moveq   #0,d2
        move.b  cam_y+2(pc),d2
        bsr.s   .hud_3d
        rts
.hud_3d:divu.w  #100,d2
        move.b  d2,d0
        add.b   #"0",d0
        bsr.w   exo_hud_chr
        swap    d2
        and.l   #$ffff,d2
        divu.w  #10,d2
        move.b  d2,d0
        add.b   #"0",d0
        bsr.w   exo_hud_chr
        swap    d2
        move.b  d2,d0
        add.b   #"0",d0
        bra.w   exo_hud_chr
.lbl_xy:  dc.b "S:",0
.cp_dirs: dc.w 0
          dc.b "N"
          dc.w 64
          dc.b "W"
          dc.w 128
          dc.b "S"
          dc.w 192
          dc.b "E"
          even
exo_hud_str:
        moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .hs_end
        bsr.s   exo_hud_chr
        bra.s   exo_hud_str
.hs_end:rts
exo_hud_chr:
        and.l   #$000000ff,d0
        sub.w   #32,d0
        lsl.w   #3,d0
        lea     hud_ascii_5x7,a4
        add.l   d0,a4
        move.l  a3,a5
        moveq   #6,d3
.hc_y:  move.b  (a4)+,d4
        btst    #4,d4
        beq.s   .hc3
        move.b  #255,(a5)
.hc3:   btst    #3,d4
        beq.s   .hc2
        move.b  #255,1(a5)
.hc2:   btst    #2,d4
        beq.s   .hc1
        move.b  #255,2(a5)
.hc1:   btst    #1,d4
        beq.s   .hc0
        move.b  #255,3(a5)
.hc0:   btst    #0,d4
        beq.s   .hcnx
        move.b  #255,4(a5)
.hcnx:  adda.w  #320,a5
        dbf     d3,.hc_y
        addq.l  #6,a3
        rts
exo_plot_radar_pt:
        move.w  (a2),d0
        move.b  cam_x+2(pc),d1
        ext.w   d1
        sub.w   d1,d0
        ext.w   d0
        move.w  2(a2),d1
        move.b  cam_y+2(pc),d2
        ext.w   d2
        sub.w   d2,d1
        ext.w   d1
        ; forward = (dx*fwd_x + dy*fwd_y) >> 8, right = (dy*fwd_x - dx*fwd_y) >> 8
        move.w  d0,d5
        muls.w  d3,d5
        move.w  d1,d2
        muls.w  d4,d2
        add.l   d2,d5
        asr.l   #8,d5
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        move.w  d1,d0
        asr.w   #3,d0
        asr.w   #3,d5
        neg.w   d5
        cmp.w   #-16,d0
        bge.s   .pr_x1
        moveq   #-16,d0
.pr_x1: cmp.w   #16,d0
        ble.s   .pr_x2
        moveq   #16,d0
.pr_x2: cmp.w   #-16,d5
        bge.s   .pr_y1
        moveq   #-16,d5
.pr_y1: cmp.w   #16,d5
        ble.s   .pr_y2
        moveq   #16,d5
.pr_y2: move.w  d5,d2
        add.w   #228,d2
        mulu.w  #320,d2
        add.w   d0,d2
        add.w   #292,d2
        move.b  d6,(a0,d2.l)
        rts
exo_upd_nearest:
        move.w  d0,d1
        muls.w  d1,d1
        move.w  d5,d2
        muls.w  d2,d2
        add.l   d2,d1
        cmp.l   #32000,d1
        bge.s   .un_dn
        cmp.w   nearest_base_dist(pc),d1
        bge.s   .un_dn
        move.w  d1,nearest_base_dist
        move.w  d0,nearest_base_rx
        move.w  d5,nearest_base_ry
.un_dn: rts

; Dziennik Pokladowy z mapa taktyczna sektora pod klawiszem J ($26)
exo_draw_logbook_overlay:
        movem.l d0-d7/a0-a5,-(sp)
        cmp.b   #$26,kbd_last_press
        bne.s   .lb_chk
        move.b  #$ff,kbd_last_press
        eor.b   #1,logbook_open
.lb_chk:tst.b   logbook_open
        beq.w   .lb_end
        ; Panel Dziennika (X=36..284, Y=34..172)
        lea     chunky_buf+34*320+36,a0
        move.w  #137,d7
.lb_bg: move.w  #247,d6
.lb_bx: move.b  #128,(a0,d6.w)
        dbf     d6,.lb_bx
        adda.w  #320,a0
        dbf     d7,.lb_bg
        lea     chunky_buf+34*320+36,a0
        move.w  #247,d6
.lb_bd: move.b  #156,(a0,d6.w)
        move.b  #156,137*320(a0,d6.w)
        dbf     d6,.lb_bd
        ; Miniatura prawdziwej mapy terenu 64x64 z exo_voxel_data (X=48..111, Y=54..117)
        lea     chunky_buf+54*320+48,a0
        lea     exo_voxel_data+65536,a1
        moveq   #63,d7
.mp_y:  moveq   #63,d6
.mp_x:  move.w  d6,d0
        lsl.w   #2,d0
        move.b  (a1,d0.w),(a0,d6.w)
        dbf     d6,.mp_x
        adda.w  #1024,a1
        adda.w  #320,a0
        dbf     d7,.mp_y
        lea     chunky_buf,a0
        lea     exo_bases(pc),a2
        moveq   #7,d7
.mb_lp: move.w  (a2),d0
        and.w   #255,d0
        lsr.w   #2,d0
        move.w  2(a2),d1
        and.w   #255,d1
        lsr.w   #2,d1
        add.w   #54,d1
        mulu.w  #320,d1
        add.w   #48,d0
        add.w   d0,d1
        move.b  #158,d2
        tst.b   4(a2)
        beq.s   .mb_c
        move.b  #190,d2
.mb_c:  move.b  d2,(a0,d1.l)
        move.b  d2,1(a0,d1.l)
        addq.l  #6,a2
        dbf     d7,.mb_lp
        ; Pozycja gracza na mapie dziennika
        moveq   #0,d0
        move.b  cam_x+2(pc),d0
        lsr.w   #2,d0
        moveq   #0,d1
        move.b  cam_y+2(pc),d1
        lsr.w   #2,d1
        add.w   #54,d1
        mulu.w  #320,d1
        add.w   #48,d0
        add.w   d0,d1
        move.b  #255,(a0,d1.l)
        move.b  #255,320(a0,d1.l)
        ; Opisy tekstowe po prawej stronie dziennika
        lea     .lb_hdr(pc),a2
        lea     chunky_buf+42*320+48,a3
        bsr.w   exo_hud_str
        lea     .lb_obj1(pc),a2
        cmp.b   #2,player_role
        bne.s   .lo3
        lea     .lb_obj2(pc),a2
        bra.s   .lo_p
.lo3:   cmp.b   #3,player_role
        bne.s   .lo_p
        lea     .lb_obj3(pc),a2
.lo_p:  lea     chunky_buf+60*320+122,a3
        bsr.w   exo_hud_str
        lea     .lb_ctl(pc),a2
        lea     chunky_buf+82*320+122,a3
        bsr.w   exo_hud_str
        lea     .lb_cls(pc),a2
        lea     chunky_buf+154*320+48,a3
        bsr.w   exo_hud_str
.lb_end:movem.l (sp)+,d0-d7/a0-a5
        rts
.lb_hdr:  dc.b "AETHER-IV SECTOR LOGBOOK",0
.lb_obj1: dc.b "PIO: SCAN CRYSTALS / BASES",0
.lb_obj2: dc.b "GRD: CLEAR DRONES / DEFEND",0
.lb_obj3: dc.b "ENG: REPAIR & BUILD DOMES",0
.lb_ctl:  dc.b "E/Q:THR X:HOVER F/LMB:BEAM",0
.lb_cls:  dc.b "[J] CLOSE LOGBOOK   [F5] SAVE",0
exo_lbl_pio: dc.b "PIO",0
exo_lbl_grd: dc.b "GRD",0
exo_lbl_eng: dc.b "ENG",0
exo_lbl_cr:   dc.b "CR:",0
        even

        even
terraform_pct:     dc.w 0
dock_progress:     dc.w 0
nearest_base_dist: dc.w 0
nearest_base_rx:   dc.w 0
nearest_base_ry:   dc.w 0
dock_in_zone:      dc.b 0
logbook_open:      dc.b 0
exo_bases:
        dc.w  40, 40,0,  110, 65,0,  190, 50,0,  220,130,0
        dc.w 175,205,0,   95,215,0,   35,170,0,  130,130,0

        even
exo_drone_mesh_v:
        dc.w 6
        dc.w  0,-6,0,   0,6,0,  -14,0,0,  14,0,0,  0,0,14,  0,0,-14
exo_drone_mesh_n:
        dc.w 6
        dc.w  0,-250,0, 0,250,0, -250,0,0, 250,0,0, 0,0,250, 0,0,-250
exo_drone_mesh_t:
        dc.w 8
        dc.w 0,4,2,0, 0,3,4,0, 0,2,5,0, 0,5,3,0
        dc.w 1,2,4,0, 1,4,3,0, 1,5,2,0, 1,3,5,0

        even
