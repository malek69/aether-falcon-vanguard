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
        moveq   #0,d0
        move.w  #240,d1
        move.w  ship_bank,d2
        jsr     build_rot_matrix_3d
        move.w  (sp)+,user_pitch
        move.w  (sp)+,user_yaw
        moveq   #0,d4
        moveq   #36,d5
        moveq   #64,d6
        lea     exo_ship_verts(pc),a0
        lea     v2_proj_buf,a1
        move.w  #8,d7
        jsr     transform_and_project_verts
        lea     exo_ship_norms(pc),a0
        lea     v2_env_buf,a1
        move.w  #8,d7
        jsr     transform_normals_envmap
        move.b  #1,phong_enabled
        clr.b   zfog_enabled
        lea     exo_ship_tris(pc),a0
        lea     v2_proj_buf,a1
        lea     exo_tex_solid(pc),a2
        lea     v2_env_buf,a3
        jsr     draw_gouraud_env_mesh_v2
        bsr.s   exo_draw_thrusters
        movem.l (sp)+,d0-d7/a0-a4
        rts
exo_draw_thrusters:
        lea     v2_proj_buf,a1
        move.w  12(a1),d0
        move.w  14(a1),d1
        addq.w  #4,d1
        bsr.s   .flame
        move.w  18(a1),d0
        move.w  20(a1),d1
        addq.w  #4,d1
.flame: cmp.w   #8,d0
        blt.s   .fl_no
        cmp.w   #310,d0
        bgt.s   .fl_no
        cmp.w   #8,d1
        blt.s   .fl_no
        cmp.w   #246,d1
        bgt.s   .fl_no
        lea     chunky_buf,a2
        mulu.w  #320,d1
        add.l   d1,a2
        add.w   d0,a2
        move.b  #158,(a2)
        move.b  #158,1(a2)
        move.b  #154,320(a2)
        move.b  #154,321(a2)
.fl_no: rts
        even
exo_ship_verts:
        dc.w   0, 0, 56,   0,-10, 10, -16, 2,  6,  16, 2,  6
        dc.w   0, 5,  6,   0, -7,-32, -48, 3,-30,  48, 3,-30
exo_ship_norms:
        dc.w   0,-50,250,  0,-250,40, -210,-110,90, 210,-110,90
        dc.w   0,250, 50,  0,-240,-80,-210,-80,-120, 210,-80,-120
exo_ship_tris:
        dc.w 20
        dc.w 0,1,2, 0,2,1, 0,3,1, 0,1,3, 0,2,4, 0,4,2, 0,4,3, 0,3,4
        dc.w 1,5,2, 1,2,5, 1,3,5, 1,5,3, 2,5,6, 2,6,5, 3,7,5, 3,5,7
        dc.w 4,2,6, 4,6,2, 4,7,3, 4,3,7
exo_tex_solid:
        dcb.b 4096,248
