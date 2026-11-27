        section code,code

; Wczytuje data/world_seed.bin przed sys_takeover i aktualizuje pozycje 8 baz
open_world_load_seed:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  4.w,a6
        lea     ow_dos_name(pc),a1
        moveq   #0,d0
        jsr     -552(a6)
        move.l  d0,a6
        tst.l   d0
        beq.s   .ow_end
        move.l  #ow_seed_path,d1
        move.l  #1005,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .ow_cls
        move.l  d4,d1
        move.l  #ow_seed_buf,d2
        moveq   #104,d3
        jsr     -42(a6)
        move.l  d4,d1
        jsr     -36(a6)
.ow_cls:move.l  a6,a1
        move.l  4.w,a6
        jsr     -414(a6)

        lea     ow_seed_buf,a0
        cmp.l   #"AFWD",(a0)+
        bne.s   .ow_end
        move.l  (a0)+,world_seed_val
        lea     exo_bases,a1
        moveq   #11,d0
.cp_b:  move.l  (a0)+,(a1)+
        dbf     d0,.cp_b
        lea     ow_anomalies,a1
        moveq   #11,d0
.cp_a:  move.l  (a0)+,(a1)+
        dbf     d0,.cp_a
.ow_end:
        bsr.w   open_world_roll_contract
        movem.l (sp)+,d0-d7/a0-a6
        rts

; Losuje kolejny kontrakt otwartego swiata na podstawie ziarna i postepow
open_world_roll_contract:
        movem.l d0-d3/a0,-(sp)
        move.w  missions_done(pc),d0
        add.w   world_seed_val+2(pc),d0
        move.w  d0,d1
        and.w   #1,d1
        move.b  d1,contract_type
        move.w  d0,d2
        mulu.w  #5,d2
        addq.w  #3,d2
        and.w   #7,d2
        cmp.w   nearest_sector_id(pc),d2
        bne.s   .tg_ok
        addq.w  #1,d2
        and.w   #7,d2
.tg_ok: move.w  d2,contract_target_idx
        tst.b   d1
        bne.s   .set_an
        lea     exo_bases,a0
        bra.s   .ld_xy
.set_an:lea     ow_anomalies,a0
.ld_xy: mulu.w  #6,d2
        move.w  (a0,d2.w),contract_target_x
        move.w  2(a0,d2.w),contract_target_y
        movem.l (sp)+,d0-d3/a0
        rts

; Aktualizuje skanowanie anomalii w terenie, kompas celu oraz ulepszenia statku
open_world_update_and_hud:
        movem.l d0-d7/a0-a4,-(sp)
        move.l  colony_credits(pc),d0
        lsr.l   #8,d0
        lsr.l   #1,d0
        cmp.w   #3,d0
        ble.s   .up_ok
        moveq   #3,d0
.up_ok: move.b  d0,ship_upgrade_lvl

        cmp.b   #1,contract_type
        bne.w   .chk_dlv
        move.w  contract_target_x(pc),d0
        move.b  cam_x+2(pc),d1
        ext.w   d1
        sub.w   d1,d0
        bpl.s   .ax_p
        neg.w   d0
.ax_p:  move.w  2(a4),d1
        move.b  cam_y+2(pc),d2
        ext.w   d2
        sub.w   d2,d1
        bpl.s   .ay_p
        neg.w   d1
.ay_p:  add.w   d1,d0
        cmp.w   #62,d0
        bgt.w   .draw_nav
        tst.b   tool_held
        bne.s   .an_hit
        tst.b   ship_throttle
        bne.w   .draw_nav
.an_hit:jsr     exo_play_sfx_scan
        add.l   #250,colony_credits
        addq.w  #1,logs_unlocked_cnt
        move.b  #5,cine_portrait_id
        addq.w  #1,missions_done
        jsr     exo_play_sfx_ping
        bsr.w   open_world_roll_contract
        moveq   #45,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #43,d0
        jsr     story_get_str
        move.l  a0,cine_line2_ptr
        moveq   #29,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        move.b  #1,cine_active
        move.w  #1,cine_type_chars
        bra.w   .draw_nav

.chk_dlv:
        move.w  contract_target_x(pc),d0
        move.b  cam_x+2(pc),d1
        ext.w   d1
        sub.w   d1,d0
        bpl.s   .bx_p
        neg.w   d0
.bx_p:  move.w  2(a4),d1
        move.b  cam_y+2(pc),d2
        ext.w   d2
        sub.w   d2,d1
        bpl.s   .by_p
        neg.w   d1
.by_p:  add.w   d1,d0
        cmp.w   #62,d0
        bgt.s   .draw_nav
        tst.b   ship_throttle
        bne.s   .draw_nav
        add.l   #250,colony_credits
        addq.w  #1,missions_done
        jsr     exo_play_sfx_ping
        bsr.w   open_world_roll_contract
        moveq   #43,d0
        jsr     story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #44,d0
        jsr     story_get_str
        move.l  a0,cine_line2_ptr
        moveq   #29,d0
        jsr     story_get_str
        move.l  a0,cine_line3_ptr
        move.b  #1,cine_active
        move.w  #1,cine_type_chars

        bsr.w   ow_draw_3d_anomaly
.draw_nav:
        tst.b   tool_held
        beq.s   .no_bm
        lea     chunky_buf+185*320+160,a0
        moveq   #58,d0
.bm_lp: move.b  #158,(a0)
        move.b  #255,1(a0)
        suba.w  #320,a0
        dbf     d0,.bm_lp
.no_bm: lea     chunky_buf+10*320+112,a0
        moveq   #95,d0
.cm_bg: move.b  #128,(a0,d0.w)
        move.b  #156,320(a0,d0.w)
        dbf     d0,.cm_bg
        move.w  contract_target_x(pc),d0
        move.b  cam_x+2(pc),d1
        ext.w   d1
        sub.w   d1,d0
        move.w  2(a4),d1
        move.b  cam_y+2(pc),d2
        ext.w   d2
        sub.w   d2,d1
        lea     sin_tab,a1
        move.w  cam_yaw(pc),d2
        and.w   #255,d2
        add.w   d2,d2
        move.w  (a1,d2.w),d3
        sub.w   #128,d2
        and.w   #510,d2
        move.w  (a1,d2.w),d4
        move.w  d1,d5
        muls.w  d3,d5
        move.w  d0,d6
        muls.w  d4,d6
        sub.l   d6,d5
        asr.l   #8,d5
        cmp.w   #-44,d5
        bge.s   .c_lo
        move.w  #-44,d5
.c_lo:  cmp.w   #44,d5
        ble.s   .c_hi
        move.w  #44,d5
.c_hi:  add.w   #160,d5
        lea     chunky_buf+16*320,a0
        add.w   d5,a0
        move.b  #190,-3(a0)
        move.b  #190,-2(a0)
        move.b  #190,-1(a0)
        move.b  #255,(a0)
        move.b  #190,1(a0)
        move.b  #190,2(a0)
        move.b  #190,3(a0)
        move.b  #190,320-2(a0)
        move.b  #255,320-1(a0)
        move.b  #255,320(a0)
        move.b  #255,320+1(a0)
        move.b  #190,320+2(a0)
        move.b  #255,640-1(a0)
        move.b  #255,640(a0)
        move.b  #255,640+1(a0)
        move.b  #190,960(a0)

        movem.l (sp)+,d0-d7/a0-a4
        rts

; Rysuje pelna mape topograficzna planety wewnatrz Dziennika Pokladowego (pod J / L)
open_world_draw_topo_map:
        movem.l d0-d7/a0-a4,-(sp)
        lea     exo_voxel_data,a1
        lea     65536(a1),a2
        lea     chunky_buf+128*320+96,a0
        moveq   #0,d7
.my_lp: moveq   #0,d6
        move.w  d7,d4
        lsl.w   #2,d4
        lsl.w   #8,d4
.mx_lp: move.w  d6,d3
        lsl.w   #2,d3
        or.w    d4,d3
        and.l   #$ffff,d3
        move.b  (a2,d3.l),d0
        move.b  d0,(a0,d6.w)
        move.b  d0,1(a0,d6.w)
        addq.w  #1,d6
        cmp.w   #64,d6
        blt.s   .mx_lp
        adda.w  #320,a0
        addq.w  #1,d7
        cmp.w   #64,d7
        blt.s   .my_lp

        lea     exo_bases,a1
        moveq   #7,d7
.mb_lp: move.w  (a1),d0
        lsr.w   #2,d0
        move.w  2(a1),d1
        lsr.w   #2,d1
        mulu.w  #320,d1
        lea     chunky_buf+128*320+96,a0
        add.l   d1,a0
        add.w   d0,a0
        move.b  #158,(a0)
        move.b  #158,1(a0)
        addq.l  #6,a1
        dbf     d7,.mb_lp

        move.w  contract_target_x(pc),d0
        lsr.w   #2,d0
        move.w  contract_target_y(pc),d1
        lsr.w   #2,d1
        mulu.w  #320,d1
        lea     chunky_buf+128*320+96,a0
        add.l   d1,a0
        add.w   d0,a0
        move.b  #190,-1(a0)
        move.b  #255,(a0)
        move.b  #190,1(a0)

        moveq   #0,d0
        move.b  cam_x+2(pc),d0
        lsr.w   #2,d0
        moveq   #0,d1
        move.b  cam_y+2(pc),d1
        lsr.w   #2,d1
        mulu.w  #320,d1
        lea     chunky_buf+128*320+96,a0
        add.l   d1,a0
        add.w   d0,a0
        move.b  #255,(a0)
        move.b  #255,-1(a0)
        move.b  #255,1(a0)
        move.b  #255,-320(a0)
        move.b  #255,320(a0)
        ; Wektor dziobu statku na mapie (3 px w kierunku cam_yaw)
        lea     sin_tab,a1
        move.w  cam_yaw(pc),d2
        and.w   #255,d2
        add.w   d2,d2
        move.w  (a1,d2.w),d3
        sub.w   #128,d2
        and.w   #510,d2
        move.w  (a1,d2.w),d4
        asr.w   #6,d3
        asr.w   #6,d4
        muls.w  #320,d4
        add.l   d4,a0
        add.w   d3,a0
        move.b  #158,(a0)
        move.b  #158,1(a0)

        movem.l (sp)+,d0-d7/a0-a4
        rts

ow_dos_name:        dc.b "dos.library",0
ow_seed_path:       dc.b "data/world_seed.bin",0
        even
world_seed_val:     dc.l 2026
contract_target_x:  dc.w 110
contract_target_y:  dc.w 65
contract_target_idx:dc.w 1
contract_type:      dc.b 0
ship_upgrade_lvl:   dc.b 0
ow_anomalies:       ds.b 48
ow_seed_buf:        ds.b 112

logs_unlocked_cnt: dc.w 0

; Renderuje w 3D obracajacy sie krysztal / sonde anomalii w terenie
ow_draw_3d_anomaly:
        movem.l d0-d7/a0-a4,-(sp)
        lea     ow_anomalies,a4
        moveq   #7,d7
.an_lp: move.w  (a4),d0
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
        cmp.w   #12,d5
        blt.w   .an_nx
        cmp.w   #175,d5
        bgt.w   .an_nx
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        cmp.w   #-110,d1
        blt.w   .an_nx
        cmp.w   #110,d1
        bgt.w   .an_nx
        asl.l   #7,d1
        divs.w  d5,d1
        add.w   #160,d1
        cmp.w   #20,d1
        blt.w   .an_nx
        cmp.w   #300,d1
        bgt.w   .an_nx

        move.w  2(a4),d0
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
        bgt.w   .an_nx

        ; Rysuj zloty celownik namierzenia 2D nad krysztalem na ziemi
        move.w  d0,d2
        sub.w   #14,d2
        cmp.w   #25,d2
        blt.s   .no_mk
        mulu.w  #320,d2
        lea     chunky_buf,a1
        add.l   d2,a1
        add.w   d1,a1
        move.b  #190,-4(a1)
        move.b  #255,4(a1)
        move.b  #255,-4*320(a1)
        move.b  #190,4*320(a1)
.no_mk:
        move.w  d5,d6
        mulu.w  #8,d6
        move.w  d1,d4
        sub.w   #160,d4
        muls.w  d6,d4
        asr.l   #8,d4
        move.w  d0,d5
        sub.w   #134,d5
        muls.w  d6,d5
        asr.l   #8,d5
        move.w  #192,d0
        move.w  vbl_tick+2(pc),d1
        and.w   #255,d1
        move.w  #192,d2
        lea     ow_crystal_v(pc),a0
        lea     ow_crystal_n(pc),a2
        lea     ow_crystal_t(pc),a3
        movem.l d7/a4,-(sp)
        jsr     vec3d_draw_ground_shadow
        jsr     vec3d_draw_mesh_3d
        movem.l (sp)+,d7/a4
.an_nx: addq.l  #6,a4
        dbf     d7,.an_lp
.an_end:movem.l (sp)+,d0-d7/a0-a4
        rts

        even
ow_crystal_v:
        dc.w 6
        dc.w    0, -92,   0
        dc.w   30, -32,   0
        dc.w    0, -32,  30
        dc.w  -30, -32,   0
        dc.w    0, -32, -30
        dc.w    0,   0,   0
ow_crystal_n:
        dc.w    0,-250,   0
        dc.w  250,   0,   0
        dc.w    0,   0, 250
        dc.w -250,   0,   0
        dc.w    0,   0,-250
        dc.w    0, 250,   0
ow_crystal_t:
        dc.w 8
        dc.w  0, 1, 2, 3
        dc.w  0, 2, 3, 3
        dc.w  0, 3, 4, 3
        dc.w  0, 4, 1, 3
        dc.w  5, 2, 1, 1
        dc.w  5, 3, 2, 1
        dc.w  5, 4, 3, 1
        dc.w  5, 1, 4, 1
