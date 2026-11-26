        section code,code
exo_draw_ship_and_hud:
        movem.l d0-d7/a0-a4,-(sp)
        lea     zbuf_3d+80000,a0
        move.l  #$7fff7fff,d0
        move.w  #19999,d1
.cz:    move.l  d0,(a0)+
        dbf     d1,.cz
        move.w  #0,cam_ox
        move.w  #0,cam_oy
        move.w  #-150,cam_oz
        clr.w   cam_sin
        move.w  #256,cam_cos
        clr.b   cam_3d_active
        lea     sin_tab,a0
        move.w  ship_bank,d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d1
        sub.w   #128,d0
        and.w   #510,d0
        move.w  (a0,d0.w),d2
        lea     rot_m00,a1
        move.w  d1,(a1)+
        move.w  d2,(a1)+
        clr.w   (a1)+
        neg.w   d2
        move.w  d2,(a1)+
        move.w  d1,(a1)+
        clr.w   (a1)+
        clr.w   (a1)+
        move.w  #-72,(a1)+
        move.w  #246,(a1)+
        moveq   #0,d4
        moveq   #36,d5
        moveq   #48,d6
        lea     exo_ship_verts(pc),a0
        lea     v2_proj_buf,a1
        move.w  #10,d7
        jsr     transform_and_project_verts
        lea     exo_ship_norms(pc),a0
        lea     v2_env_buf,a1
        move.w  #10,d7
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
        move.w  36(a1),d0
        move.w  38(a1),d1
        bsr.s   .flame
        move.w  42(a1),d0
        move.w  44(a1),d1
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
        dc.w   0,-4,62,   0,-18,14, -20,2,10,  20,2,10,  0,8,10
        dc.w   0,-14,-34, -14,2,-36,  14,2,-36, -58,4,-26, 58,4,-26
exo_ship_norms:
        dc.w   0,-60,245, 0,-250,40, -210,-110,90, 210,-110,90, 0,250,50
        dc.w   0,-240,-80,-210,-80,-120,210,-80,-120,-180,-180,-30,180,-180,-30
exo_ship_tris:
        dc.w 36
        dc.w 0,1,2, 0,2,1, 0,3,1, 0,1,3, 0,2,4, 0,4,2, 0,4,3, 0,3,4
        dc.w 1,5,2, 1,2,5, 1,3,5, 1,5,3, 2,5,6, 2,6,5, 5,3,7, 5,7,3
        dc.w 5,6,7, 5,7,6, 4,2,6, 4,6,2, 4,7,3, 4,3,7, 4,6,7, 4,7,6
        dc.w 2,6,8, 2,8,6, 3,9,7, 3,7,9, 3,7,9, 3,9,7, 3,5,9, 3,9,5, 5,7,9, 5,9,7
exo_tex_solid:
        dcb.b 4096,248
