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
        cmp.w   #4,d5
        blt.w   .b_nx
        cmp.w   #185,d5
        bgt.w   .b_nx
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        cmp.w   #-175,d1
        blt.w   .b_nx
        cmp.w   #175,d1
        bgt.w   .b_nx
        asl.l   #7,d1
        divs.w  d5,d1
        add.w   #160,d1
        cmp.w   #16,d1
        blt.w   .b_nx
        cmp.w   #304,d1
        bgt.w   .b_nx

        ; Dokowanie / komunikacja przy bazie (zblizenie d5<=36 i zawis throttle==0 lub narzedzie F/R)
        tst.b   cine_active
        bne.s   .no_act
        tst.w   dock_cooldown
        bne.s   .no_act
        cmp.w   #62,d5
        bgt.s   .no_act
        ; Wyrazna ramka celownika przy bazie
        move.b  #190,chunky_buf+118*320+160
        move.b  #190,chunky_buf+134*320+160
        move.b  #190,chunky_buf+126*320+148
        move.b  #190,chunky_buf+126*320+172
        tst.b   ship_throttle
        beq.s   .trig_dlg
        tst.b   tool_held
        beq.s   .no_act
        clr.b   tool_held
.trig_dlg:
        movem.l d0-d7/a0-a4,-(sp)
        jsr     cine_open_base_dialogue
        movem.l (sp)+,d0-d7/a0-a4

.no_act:move.w  2(a4),d0
        and.w   #255,d0
        lsl.w   #8,d0
        move.w  (a4),d2
        and.w   #255,d2
        or.w    d2,d0
        and.l   #$ffff,d0
        lea     exo_voxel_data,a2
        moveq   #0,d2
        move.b  (a2,d0.l),d2
        move.w  cam_alt(pc),d0
        sub.w   d2,d0
        ext.l   d0
        asl.l   #5,d0
        divs.w  d5,d0
        add.w   cam_pitch(pc),d0
        cmp.w   #245,d0
        bgt.w   .b_nx
        ; Osadzenie kopuly 3D dokladnie na linii gruntu (d0) z zawsze dodatnim cam_oz
        move.w  d5,d6
        mulu.w  #8,d6                   ; cam_oz > 0 dla kazdego d5 >= 14
        move.w  d1,d4
        sub.w   #160,d4
        muls.w  d6,d4
        asr.l   #8,d4                   ; cam_ox
        move.w  d0,d5
        sub.w   #134,d5
        muls.w  d6,d5
        asr.l   #8,d5                   ; cam_oy
        move.w  #192,d0                 ; 192 = 0 deg w sin_tab
        move.w  #192,d1
        move.w  #192,d2
        lea     exo_dome_mesh_v(pc),a0
        lea     exo_dome_mesh_n(pc),a2
        lea     exo_dome_mesh_t(pc),a3
        movem.l d0-d1/d7/a4,-(sp)
        jsr     vec3d_draw_mesh_3d
        movem.l (sp)+,d0-d1/d7/a4
        ; Rysuj pionowy promien nawigacyjny dokladnie ze szczytu kopuly (d1=X, d0=Y)
        sub.w   #16,d0
        cmp.w   #26,d0
        blt.s   .b_nx
        cmp.w   #235,d0
        bgt.s   .b_nx
        move.w  d0,d6
        sub.w   #22,d6
        cmp.w   #44,d6
        ble.s   .bc_h
        moveq   #44,d6
.bc_h:  mulu.w  #320,d0
        lea     chunky_buf,a1
        add.l   d0,a1
        add.w   d1,a1
        move.b  #158,d2
        tst.b   4(a4)
        beq.s   .bc_lp
        move.b  #190,d2
.bc_lp: move.b  d2,(a1)
        suba.w  #320,a1
        dbf     d6,.bc_lp
.b_nx:  addq.l  #6,a4
        dbf     d7,.b_lp
        bsr.w   exo_update_drones
        bsr.w   exo_draw_hud_and_radar
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

exo_update_drones:
        lea     exo_drones(pc),a4
        moveq   #3,d7
.dl_lp: tst.b   4(a4)
        bne.w   .dl_nx
        addq.b  #1,5(a4)
        cmp.b   #6,5(a4)
        blt.s   .dr_mv
        clr.b   5(a4)
        addq.w  #1,(a4)
        and.w   #255,(a4)
.dr_mv: move.w  (a4),d0
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
        tst.b   tool_held
        beq.s   .dl_dr
        cmp.w   #142,d1
        blt.s   .dl_dr
        cmp.w   #178,d1
        bgt.s   .dl_dr
        move.b  #1,4(a4)
        add.w   #10,terraform_pct
        addq.w  #1,missions_done
        add.l   #100,colony_credits
        move.w  d1,d0
        move.w  d3,d1
        move.b  #158,d6
        jsr     vec3d_spawn_particles
        jsr     exo_play_sfx_scan
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
        sub.w   #144,d0
        move.w  d0,d5
        muls.w  d6,d5
        asr.l   #8,d5
        move.w  d6,d0
        sub.w   #150,d6
        lsl.w   #2,d0
        move.w  d0,d1
        move.w  #192,d2
        lea     exo_drone_mesh_v(pc),a0
        lea     exo_drone_mesh_n(pc),a2
        lea     exo_drone_mesh_t(pc),a3
        movem.l d7/a4,-(sp)
        jsr     vec3d_draw_ground_shadow
        moveq   #6,d7
        jsr     vec3d_draw_mesh_3d
        movem.l (sp)+,d7/a4
.dl_nx: addq.l  #6,a4
        dbf     d7,.dl_lp
        rts

exo_drones:
        dc.w  60, 55,0, 180, 75,0, 150,190,0,  55,185,0

exo_draw_hud_and_radar:
        lea     chunky_buf,a0
        ; Wskaznik ciagu silników (0=ZAWIS .. 4=MAX) w lewym dolnym rogu (Y=242, X=14)
        lea     230*320+14(a0),a1
        moveq   #3,d4
        moveq   #0,d5
        move.b  ship_throttle(pc),d5
.th_lp: move.b  #128,d2
        cmp.w   d5,d4
        bge.s   .th_c
        move.b  #190,d2
.th_c:  move.b  d2,(a1)
        move.b  d2,1(a1)
        move.b  d2,2(a1)
        move.b  d2,320(a1)
        move.b  d2,321(a1)
        move.b  d2,322(a1)
        addq.l  #5,a1
        subq.w  #1,d4
        bpl.s   .th_lp
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

        ; Wskaznik ukonczonych zlecen / reputacji kolonii (zlote znaczniki obok paska)
        move.w  missions_done(pc),d4
        beq.s   .no_ms
        cmp.w   #16,d4
        ble.s   .ms_ok
        moveq   #16,d4
.ms_ok: subq.w  #1,d4
        lea     10*320+138(a0),a1
.ms_lp: move.b  #255,(a1)
        move.b  #255,1(a1)
        move.b  #255,320(a1)
        move.b  #255,321(a1)
        move.b  #158,640(a1)
        move.b  #158,641(a1)
        addq.l  #4,a1
        dbf     d4,.ms_lp
.no_ms:
        move.b  #158,d0
        move.b  d0,124*320+160(a0)
        move.b  d0,128*320+160(a0)
        move.b  d0,126*320+156(a0)
        move.b  d0,126*320+164(a0)
        ; Obrotowy radar 360° (X=274..310, Y=210..246, srodek=292,228 = gracz, gora = dziob)
        lea     210*320+274(a0),a1
        moveq   #35,d7
.rd_y:  moveq   #35,d6
.rd_x:  move.b  #128,(a1,d6.w)
        dbf     d6,.rd_x
        adda.w  #320,a1
        dbf     d7,.rd_y
        ; Ramka radaru i krzyzyk gracza w srodku (292, 228)
        lea     210*320+274(a0),a1
        moveq   #35,d6
.rdb:   move.b  #156,(a1,d6.w)
        move.b  #156,35*320(a1,d6.w)
        dbf     d6,.rdb
        move.b  #255,228*320+292(a0)
        move.b  #158,226*320+292(a0)    ; dziob statku wskazuje w gore radaru

        lea     sin_tab,a3
        move.w  cam_yaw(pc),d2
        and.w   #255,d2
        add.w   d2,d2
        move.w  (a3,d2.w),d3            ; cos
        sub.w   #128,d2
        and.w   #510,d2
        move.w  (a3,d2.w),d4            ; sin

        ; Rysuj 8 baz w ukladzie obrotowym wokol gracza
        lea     exo_bases(pc),a2
        moveq   #7,d7
.rb_lp: move.w  (a2),d0
        move.b  cam_x+2(pc),d1
        ext.w   d1
        sub.w   d1,d0
        ext.w   d0                      ; dx (-128..127)
        move.w  2(a2),d1
        move.b  cam_y+2(pc),d2
        ext.w   d2
        sub.w   d2,d1
        ext.w   d1                      ; dy (-128..127)
        ; forward = dx*cos + dy*sin (gora radaru = -Y)
        move.w  d0,d5
        muls.w  d3,d5
        move.w  d1,d6
        muls.w  d4,d6
        add.l   d6,d5
        asr.l   #8,d5
        asr.w   #3,d5
        ; right = dy*cos - dx*sin (prawo radaru = +X)
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        asr.w   #3,d1
        cmp.w   #-15,d1
        blt.s   .rb_nx
        cmp.w   #15,d1
        bgt.s   .rb_nx
        cmp.w   #-15,d5
        blt.s   .rb_nx
        cmp.w   #15,d5
        bgt.s   .rb_nx
        neg.w   d5
        add.w   #18,d5
        add.w   #18,d1
        mulu.w  #320,d5
        lea     210*320+274(a0),a1
        add.l   d5,a1
        add.w   d1,a1
        move.b  #158,d2
        tst.b   4(a2)
        beq.s   .rb_c
        move.b  #156,d2
.rb_c:  move.b  d2,(a1)
        move.b  d2,1(a1)
.rb_nx: addq.l  #6,a2
        dbf     d7,.rb_lp

        ; Rysuj zloty pulsujacy cel misji na obrotowym radarze (przyciagany do krawedzi, gdy daleko!)
        move.w  contract_target_x(pc),d0
        move.b  cam_x+2(pc),d1
        ext.w   d1
        sub.w   d1,d0
        ext.w   d0
        move.w  contract_target_y(pc),d1
        move.b  cam_y+2(pc),d2
        ext.w   d2
        sub.w   d2,d1
        ext.w   d1
        move.w  d0,d5
        muls.w  d3,d5
        move.w  d1,d6
        muls.w  d4,d6
        add.l   d6,d5
        asr.l   #8,d5
        asr.w   #3,d5
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        asr.w   #3,d1
        cmp.w   #-15,d1
        bge.s   .tg_x1
        move.w  #-15,d1
.tg_x1: cmp.w   #15,d1
        ble.s   .tg_x2
        move.w  #15,d1
.tg_x2: cmp.w   #-15,d5
        bge.s   .tg_y1
        move.w  #-15,d5
.tg_y1: cmp.w   #15,d5
        ble.s   .tg_y2
        move.w  #15,d5
.tg_y2: neg.w   d5
        add.w   #18,d5
        add.w   #18,d1
        mulu.w  #320,d5
        lea     210*320+274(a0),a1
        add.l   d5,a1
        add.w   d1,a1
        move.b  #190,(a1)
        move.b  #255,1(a1)
        move.b  #255,320(a1)
        move.b  #190,321(a1)
        rts
        even
terraform_pct:  dc.w 0
missions_done:  dc.w 0
colony_credits: dc.l 0
exo_bases:
        dc.w  40, 40,0,  110, 65,0,  190, 50,0,  220,130,0
        dc.w 175,205,0,   95,215,0,   35,170,0,  130,130,0

        even
        even

        even

exo_drone_mesh_v:
        dc.w 12
        dc.w    0,   0,  11
        dc.w    0,  -3,   4
        dc.w    0,   3,   4
        dc.w   -6,  -3,  -3
        dc.w    6,  -3,  -3
        dc.w   -6,   3,  -3
        dc.w    6,   3,  -3
        dc.w    0,   0, -10
        dc.w  -13,  -1,  -1
        dc.w   13,  -1,  -1
        dc.w    0,  -7,  -5
        dc.w    0,   6,  -4

exo_drone_mesh_n:
        dc.w    0, -45, 246
        dc.w    0,-195, 156
        dc.w    0,  61, 243
        dc.w -179,-149, -90
        dc.w  179,-149, -90
        dc.w -221,  37,-111
        dc.w  221,  37,-111
        dc.w    0, -49,-245
        dc.w -243, -56, -19
        dc.w  243, -56, -19
        dc.w    0,-219,-121
        dc.w    0, 177,-177

exo_drone_mesh_t:
        dc.w 20
        dc.w  0, 1, 3, 3
        dc.w  0, 4, 1, 3
        dc.w  0, 3, 2, 2
        dc.w  0, 2, 4, 2
        dc.w  1, 4, 3, 2
        dc.w  2, 3, 4, 2
        dc.w  3, 4, 7, 2
        dc.w  4, 6, 7, 2
        dc.w  6, 5, 7, 2
        dc.w  5, 3, 7, 2
        dc.w  3, 5, 2, 2
        dc.w  4, 2, 6, 2
        dc.w  3, 8, 5, 3
        dc.w  3, 1, 8, 3
        dc.w  5, 8, 7, 2
        dc.w  4, 6, 9, 3
        dc.w  4, 9, 1, 3
        dc.w  6, 7, 9, 2
        dc.w  1, 4,10, 3
        dc.w  1,10, 3, 3

        even

exo_dome_mesh_v:
        dc.w 24
        dc.w   20,   0,   0
        dc.w   14,   0,  14
        dc.w    0,   0,  20
        dc.w  -14,   0,  14
        dc.w  -20,   0,   0
        dc.w  -14,   0, -14
        dc.w    0,   0, -20
        dc.w   14,   0, -14
        dc.w   12, -12,   0
        dc.w    8, -12,   8
        dc.w    0, -12,  12
        dc.w   -8, -12,   8
        dc.w  -12, -12,   0
        dc.w   -8, -12,  -8
        dc.w    0, -12, -12
        dc.w    8, -12,  -8
        dc.w    0, -18,   0
        dc.w   18,  -1, -11
        dc.w   38,  -1, -11
        dc.w   38,  -1,  11
        dc.w   18,  -1,  11
        dc.w  -25,   0,  -4
        dc.w  -19,   0,   4
        dc.w  -22, -28,   0

exo_dome_mesh_n:
        dc.w  214,-129,   0
        dc.w  151,-130, 151
        dc.w    0,-129, 214
        dc.w -151,-130, 151
        dc.w -214,-129,   0
        dc.w -151,-130,-151
        dc.w    0,-129,-214
        dc.w  151,-130,-151
        dc.w  112,-224,   0
        dc.w   75,-226,  75
        dc.w    0,-224, 112
        dc.w  -75,-226,  75
        dc.w -112,-224,   0
        dc.w  -75,-226, -75
        dc.w    0,-224,-112
        dc.w   75,-226, -75
        dc.w    0,-250,   0
        dc.w    0,-250,   0
        dc.w    0,-250,   0
        dc.w    0,-250,   0
        dc.w    0,-250,   0
        dc.w  -79,-212,-106
        dc.w   79,-212, 106
        dc.w    0,-250,   0

exo_dome_mesh_t:
        dc.w 30
        dc.w  0, 1, 9, 1
        dc.w  0, 9, 8, 1
        dc.w  8, 9,16, 1
        dc.w  1, 2,10, 1
        dc.w  1,10, 9, 1
        dc.w  9,10,16, 1
        dc.w  2, 3,11, 1
        dc.w  2,11,10, 1
        dc.w 10,11,16, 1
        dc.w  3, 4,12, 1
        dc.w  3,12,11, 1
        dc.w 11,12,16, 1
        dc.w  4, 5,13, 1
        dc.w  4,13,12, 1
        dc.w 12,13,16, 1
        dc.w  5, 6,14, 1
        dc.w  5,14,13, 1
        dc.w 13,14,16, 1
        dc.w  6, 7,15, 1
        dc.w  6,15,14, 1
        dc.w 14,15,16, 1
        dc.w  7, 0, 8, 1
        dc.w  7, 8,15, 1
        dc.w 15, 8,16, 1
        dc.w 17,18,19, 2
        dc.w 17,19,20, 2
        dc.w 17,19,18, 2
        dc.w 17,20,19, 2
        dc.w 21,22,23, 3
        dc.w 21,23,22, 3

