        section code,code
exo_draw_ship_and_hud:
        movem.l d0-d7/a0-a4,-(sp)
        jsr     vec3d_clear_zbuf_fast
        move.w  #0,cam_ox
        move.w  #0,cam_oy
        move.w  #-150,cam_oz
        clr.w   cam_sin
        move.w  #256,cam_cos
        clr.b   cam_3d_active
        move.w  user_yaw(pc),-(sp)
        move.w  user_pitch(pc),-(sp)
        clr.w   user_yaw
        clr.w   user_pitch
        ; Neutralna orientacja pojazdu: d0=192, d1=198, d2=192
        move.w  #192,d0
        sub.w   ship_bank(pc),d0
        move.w  #198,d1
        move.w  (sp),d2
        asr.w   #1,d2
        add.w   d2,d1
        move.w  #192,d2
        add.w   ship_bank(pc),d2
        jsr     build_rot_matrix_3d
        move.w  (sp)+,user_pitch
        move.w  (sp)+,user_yaw
        move.w  ship_bank(pc),d4
        moveq   #38,d5
        moveq   #60,d6
        moveq   #0,d0
        move.b  ship_throttle(pc),d0
        add.w   d0,d0
        add.w   d0,d6
        tst.b   fire_held
        beq.s   .no_ab
        add.w   #10,d6
.no_ab: lea     exo_ship_verts(pc),a0
        cmp.b   #2,player_role
        bne.s   .vs_c3
        lea     exo_guard_verts(pc),a0
        bra.s   .vs_ok
.vs_c3: cmp.b   #3,player_role
        bne.s   .vs_ok
        lea     exo_eng_verts(pc),a0
.vs_ok:
        lea     v2_proj_buf,a1
        move.w  #34,d7
        jsr     transform_and_project_verts
        lea     exo_ship_norms(pc),a0
        lea     v2_env_buf,a1
        move.w  #34,d7
        jsr     transform_normals_envmap
        move.b  #1,phong_enabled
        clr.b   zfog_enabled
        lea     exo_ship_tris(pc),a0
        cmp.b   #2,player_role
        bne.s   .ts_c3
        lea     exo_guard_tris(pc),a0
        bra.s   .ts_ok
.ts_c3: cmp.b   #3,player_role
        bne.s   .ts_ok
        lea     exo_eng_tris(pc),a0
.ts_ok:
        lea     v2_proj_buf,a1
        lea     exo_tex_solid(pc),a2
        lea     v2_env_buf,a3
        jsr     draw_gouraud_env_mesh_v2
        bsr.s   exo_draw_thrusters
        bsr.w   exo_draw_work_tool
        bsr.w   exo_draw_throttle_hud
        movem.l (sp)+,d0-d7/a0-a4
        rts

exo_draw_thrusters:
        lea     v2_proj_buf,a1
        move.w  168(a1),d0
        move.w  170(a1),d1
        bsr.s   .flame
        move.w  198(a1),d0
        move.w  200(a1),d1
.flame: cmp.w   #8,d0
        blt.w   .fl_no
        cmp.w   #310,d0
        bgt.w   .fl_no
        cmp.w   #8,d1
        blt.w   .fl_no
        cmp.w   #240,d1
        bgt.w   .fl_no
        lea     chunky_buf,a2
        mulu.w  #320,d1
        add.l   d1,a2
        add.w   d0,a2
        move.b  #158,(a2)
        moveq   #0,d2
        move.b  ship_throttle(pc),d2
        tst.b   fire_held
        beq.s   .chk_t0
        addq.w  #3,d2
.chk_t0:
        tst.w   d2
        beq.s   .fl_no
        move.b  #255,-1(a2)
        move.b  #255,(a2)
        move.b  #255,1(a2)
        cmp.w   #2,d2
        blt.w   .fl_no
        move.b  #158,319(a2)
        move.b  #255,320(a2)
        move.b  #158,321(a2)
        cmp.w   #3,d2
        blt.w   .fl_no
        move.b  #156,640(a2)
        cmp.w   #5,d2
        blt.w   .fl_no
        move.b  #158,639(a2)
        move.b  #158,641(a2)
        move.b  #155,960(a2)
        move.b  #153,1280(a2)
.fl_no: rts

exo_draw_work_tool:
        tst.b   tool_held
        beq.s   .wt_no
        lea     v2_proj_buf,a1
        move.w  (a1),d0
        move.w  2(a1),d1
        cmp.w   #20,d0
        blt.s   .wt_no
        cmp.w   #300,d0
        bgt.s   .wt_no
        cmp.w   #40,d1
        blt.s   .wt_no
        cmp.w   #230,d1
        bgt.s   .wt_no
        move.b  #175,d3
        cmp.b   #2,player_role
        bne.s   .chk_eng
        move.b  #158,d3
        bra.s   .draw_bm
.chk_eng:
        cmp.b   #3,player_role
        bne.s   .draw_bm
        move.b  #255,d3
.draw_bm:
        lea     chunky_buf,a2
        mulu.w  #320,d1
        add.l   d1,a2
        add.w   d0,a2
        moveq   #14,d2
.bm_lp: suba.w  #320,a2
        move.b  d3,(a2)
        move.b  d3,-1(a2)
        move.b  d3,1(a2)
        dbf     d2,.bm_lp
.wt_no: rts

exo_draw_throttle_hud:
        lea     chunky_buf,a2
        adda.l  #(220*320)+12,a2
        moveq   #0,d2
        move.b  ship_throttle(pc),d2
        moveq   #1,d3
.th_lp: move.b  #134,d4
        cmp.w   d3,d2
        blt.s   .th_px
        move.b  #255,d4
.th_px: move.b  d4,(a2)
        move.b  d4,1(a2)
        move.b  d4,2(a2)
        move.b  d4,320(a2)
        move.b  d4,321(a2)
        move.b  d4,322(a2)
        addq.l  #5,a2
        addq.w  #1,d3
        cmp.w   #4,d3
        ble.s   .th_lp
        move.b  #134,d4
        tst.b   fire_held
        beq.s   .ab_px
        move.b  #158,d4
.ab_px: move.b  d4,(a2)
        move.b  d4,1(a2)
        move.b  d4,2(a2)
        move.b  d4,320(a2)
        move.b  d4,321(a2)
        move.b  d4,322(a2)
        rts
        even
        include "exo_ship_mesh.i"
