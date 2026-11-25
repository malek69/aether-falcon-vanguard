; ============================================================================
; AETHER FALCON: VANGUARD - Silnik Wokselowy 3D (Gory, Woda, Wyspy/Lady, Wieze)
; ============================================================================
        section code,code
        cnop    0,4
terrain_3d_init:
af_voxel_init_mission:
        movem.l d0-d7/a0-a3,-(sp)
        lea     af_vox_hmap,a0
        lea     af_vox_cmap,a1
        lea     sin_tab,a2
        move.w  af_mission,d7
        moveq   #0,d5
.vi_z:  moveq   #0,d4
.vi_x:  move.w  d4,d0
        muls.w  #6,d0
        and.w   #255,d0
        move.w  (a2,d0.w*2),d1
        move.w  d5,d0
        muls.w  #5,d0
        add.w   #64,d0
        and.w   #255,d0
        add.w   (a2,d0.w*2),d1
        move.w  d4,d0
        add.w   d5,d0
        lsl.w   #3,d0
        and.w   #255,d0
        move.w  (a2,d0.w*2),d2
        asr.w   #1,d2
        add.w   d2,d1
        cmp.w   #1,d7
        beq.w   .gen_m2
        cmp.w   #2,d7
        beq.w   .gen_m3
        asr.w   #5,d1
        add.w   #12,d1
        cmp.w   #8,d1
        bgt.s   .m1_l
        move.b  #8,(a0)+
        move.b  #1,(a1)+
        bra.w   .vi_nx
.m1_l:  move.b  d1,(a0)+
        cmp.w   #13,d1
        bgt.s   .m1_g
        move.b  #2,(a1)+
        bra.w   .vi_nx
.m1_g:  cmp.w   #20,d1
        bgt.s   .m1_p
        move.b  #3,(a1)+
        bra.w   .vi_nx
.m1_p:  move.b  #4,(a1)+
        bra.w   .vi_nx
.gen_m2:move.w  d4,d0
        sub.w   #32,d0
        bpl.s   .m2_a
        neg.w   d0
.m2_a:  asr.w   #5,d1
        cmp.w   #6,d0
        bgt.s   .m2_c
        move.b  #6,(a0)+
        move.b  #1,(a1)+
        bra.w   .vi_nx
.m2_c:  move.w  d0,d2
        lsl.w   #1,d2
        add.w   d1,d2
        cmp.w   #32,d2
        ble.s   .m2_h
        moveq   #32,d2
.m2_h:  move.b  d2,(a0)+
        cmp.w   #34,d2
        bgt.s   .m2_t
        move.b  #5,(a1)+
        bra.w   .vi_nx
.m2_t:  move.b  #4,(a1)+
        bra.w   .vi_nx
.gen_m3:asr.w   #5,d1
        add.w   #16,d1
        move.w  d4,d0
        and.w   #15,d0
        cmp.w   #4,d0
        blo.s   .m3_g
        cmp.w   #7,d0
        bhi.s   .m3_g
        move.w  d5,d2
        and.w   #15,d2
        cmp.w   #4,d2
        blo.s   .m3_g
        cmp.w   #7,d2
        bhi.s   .m3_g
        move.b  #30,(a0)+
        move.b  #6,(a1)+
        bra.s   .vi_nx
.m3_g:  cmp.w   #9,d1
        bgt.s   .m3_r
        move.b  #9,(a0)+
        move.b  #7,(a1)+
        bra.s   .vi_nx
.m3_r:  move.b  d1,(a0)+
        move.b  #5,(a1)+
.vi_nx: addq.w  #1,d4
        cmp.w   #64,d4
        blo.w   .vi_x
        addq.w  #1,d5
        cmp.w   #64,d5
        blo.w   .vi_z
        movem.l (sp)+,d0-d7/a0-a3
        rts
render_3d_terrain_flyover:
        movem.l d0-d7/a0-a6,-(sp)
        tst.b   vox_inited(pc)
        bne.s   .vrdy
        move.b  #1,vox_inited
        bsr.w   af_voxel_init_mission
.vrdy:  lea     vox_ybuf(pc),a0
        ifd FULL_RES
        move.w  #255,d0
        else
        moveq   #127,d0
        endif
        moveq   #79,d1
.yb_cl: move.w  d0,(a0)+
        move.w  d0,(a0)+
        dbf     d1,.yb_cl
        move.l  vbl_tick(pc),d0
        lsr.l   #1,d0
        move.w  d0,vox_cam_z
        move.w  af_ship_dx,d0
        asr.w   #3,d0
        add.w   #32,d0
        move.w  d0,vox_cam_x
        lea     af_vox_hmap,a3
        lea     af_vox_cmap,a4
        lea     recip_table_32(pc),a5
        moveq   #28,d7
.vz_lp: move.l  (a5,d7.w*4),d6
        move.w  d7,d0
        lsr.w   #2,d0
        add.w   vox_cam_z(pc),d0
        and.w   #63,d0
        lsl.w   #6,d0
        move.w  d0,vox_row_off
        move.w  vox_cam_x(pc),d0
        swap    d0
        clr.w   d0
        move.w  d7,d1
        ext.l   d1
        ifd FULL_RES
        lsl.l   #7,d1
        move.l  d1,vox_dx_step
        move.l  d1,d2
        muls.l  #80,d2
        else
        lsl.l   #8,d1
        move.l  d1,vox_dx_step
        move.l  d1,d2
        muls.l  #40,d2
        endif
        sub.l   d2,d0
        lea     vox_ybuf(pc),a1
        lea     chunky_buf,a2
        moveq   #0,d5
.vx_lp: move.l  d0,d2
        swap    d2
        and.w   #63,d2
        add.w   vox_row_off(pc),d2
        moveq   #0,d3
        move.b  (a3,d2.w),d3
        move.w  #44,d4
        sub.w   d3,d4
        ext.l   d4
        muls.l  d6,d4
        asr.l   #8,d4
        asr.l   #1,d4
        ifd FULL_RES
        add.l   #134,d4
        cmp.l   #134,d4
        bge.s   .sy_hi
        move.w  #134,d4
.sy_hi: cmp.l   #255,d4
        ble.s   .sy_ok
        move.w  #255,d4
        else
        asr.l   #1,d4
        add.l   #67,d4
        cmp.l   #67,d4
        bge.s   .sy_hi
        moveq   #67,d4
.sy_hi: cmp.l   #127,d4
        ble.s   .sy_ok
        moveq   #127,d4
        endif
.sy_ok: move.w  (a1),d3
        cmp.w   d3,d4
        bge.w   .vx_nx
        move.w  d4,(a1)
        moveq   #0,d1
        move.b  (a4,d2.w),d1
        bsr.s   .vpc
        sub.w   d4,d3
        ble.w   .vx_nx
        subq.w  #1,d3
        mulu.w  #320,d4
        move.l  a2,a6
        add.l   d4,a6
        move.b  d1,d4
        lsl.w   #8,d4
        move.b  d1,d4
        ifd FULL_RES
.vcf:   move.w  d4,(a6)
        lea     320(a6),a6
        dbf     d3,.vcf
.vx_nx: addq.l  #2,a1
        addq.l  #2,a2
        add.l   vox_dx_step(pc),d0
        addq.w  #1,d5
        cmp.w   #160,d5
        blo.w   .vx_lp
        addq.w  #6,d7
        else
        move.w  d4,d1
        swap    d4
        move.w  d1,d4
.vcf:   move.l  d4,(a6)
        lea     320(a6),a6
        dbf     d3,.vcf
.vx_nx: addq.l  #2,a1
        addq.l  #4,a2
        add.l   vox_dx_step(pc),d0
        addq.w  #1,d5
        cmp.w   #80,d5
        blo.w   .vx_lp
        add.w   #12,d7
        endif
        cmp.w   #224,d7
        blo.w   .vz_lp
        movem.l (sp)+,d0-d7/a0-a6
        rts
.vpc:   move.l  d4,-(sp)
        bsr.s   .vpc_in
        move.l  (sp)+,d4
        rts
.vpc_in:cmp.b   #1,d1
        bne.s   .vp2
        move.l  vbl_tick(pc),d1
        lsr.l   #2,d1
        add.w   d2,d1
        and.w   #3,d1
        add.w   #212,d1
        rts
.vp2:   cmp.b   #2,d1
        bne.s   .vp3
        move.w  #122,d1
        bra.s   .vps
.vp3:   cmp.b   #3,d1
        bne.s   .vp4
        move.w  #114,d1
        bra.s   .vps
.vp4:   cmp.b   #4,d1
        bne.s   .vp6
        move.w  #28,d1
        bra.s   .vps
.vp6:   cmp.b   #6,d1
        bne.s   .vp7
        move.b  #253,d1
        btst    #0,d2
        beq.s   .vpr
        move.w  #24,d1
.vpr:   rts
.vp7:   cmp.b   #7,d1
        bne.s   .vp5
        move.b  #252,d1
        rts
.vp5:   move.w  #108,d1
.vps:   move.w  d2,d4
        addq.w  #1,d4
        and.w   #4095,d4
        move.b  (a3,d4.w),d4
        sub.b   (a3,d2.w),d4
        ext.w   d4
        asr.w   #2,d4
        add.w   d4,d1
        cmp.w   #140,d7
        ble.s   .vpc_c
        subq.w  #3,d1
.vpc_c: cmp.w   #16,d1
        bge.s   .vpc_d
        moveq   #16,d1
.vpc_d: rts
        even
vox_inited:     dc.b 0,0
vox_cam_x:      dc.w 32
vox_cam_z:      dc.w 0
vox_row_off:    dc.w 0
vox_dx_step:    dc.l 0
vox_ybuf:       ds.w 160
        section fastram_bss,bss_p
af_vox_hmap:    ds.b 64*64
af_vox_cmap:    ds.b 64*64
        section code,code
