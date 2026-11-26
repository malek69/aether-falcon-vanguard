        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD v0.2.0 - Obracany Horyzont 3D + Teksturowany Teren
; Styl: After Burner / Star Fox / T-Zero (68020+ scanline perspective)
; ============================================================================

        ifd FULL_RES
T3D_H           equ     256
T3D_MID_Y       equ     124
        else
T3D_H           equ     128
T3D_MID_Y       equ     62
        endif

        cnop    0,4
render_3d_terrain_flyover:
        movem.l d0-d7/a0-a6,-(sp)

        ; 1. Pobierz sin(roll) z sin_tab (-256..256) na podstawie przechylu XF-14
        lea     sin_tab,a0
        move.w  af_roll,d0
        neg.w   d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d4
        move.w  d4,t3d_sin_roll

        ; 2. Wysokosc srodka horyzontu Y_horiz
        move.w  af_ship_dy,d6
        asr.w   #1,d6
        ifd FULL_RES
        neg.w   d6
        add.w   #T3D_MID_Y,d6
        else
        neg.w   d6
        asr.w   #1,d6
        add.w   #T3D_MID_Y,d6
        endif
        move.w  d6,t3d_y_horiz

        ; 3. Przewijanie terenu wzdluz Z i X
        moveq   #4,d1
        btst    #7,CIAAPRA
        beq.s   .sp_bst
        tst.b   fire_held
        beq.s   .sp_add
.sp_bst:moveq   #9,d1
.sp_add:add.w   d1,t3d_scroll_z
        move.w  af_ship_dx,d1
        asr.w   #2,d1
        add.w   d1,t3d_scroll_x

        ; 4. Wybor palety terenu dla aktualnej misji
        lea     t3d_pal_ocean(pc),a5
        cmp.w   #1,af_mission
        bne.s   .chk_m3
        lea     t3d_pal_canyon(pc),a5
        bra.s   .pal_set
.chk_m3:cmp.w   #2,af_mission
        bne.s   .pal_set
        lea     t3d_pal_citadel(pc),a5
.pal_set:
        lea     chunky_buf,a1
        moveq   #0,d7

.row_loop:
        move.b  4(a5),d0
        cmp.w   #2,af_world_mood
        bne.s   .sky_c
        move.b  #252,d0
.sky_c: move.b  d0,d1
        lsl.w   #8,d1
        move.b  d0,d1
        move.w  d1,d0
        swap    d1
        move.w  d0,d1

        move.w  t3d_sin_roll(pc),d2
        muls.w  #160,d2
        asr.l   #8,d2
        move.w  t3d_y_horiz(pc),d3
        move.w  d3,d5
        sub.w   d2,d3                   ; y_left
        add.w   d2,d5                   ; y_right

        move.w  d3,d0
        cmp.w   d5,d0
        ble.s   .min_ok
        move.w  d5,d0
.min_ok:cmp.w   d0,d7
        blt.w   .full_sky

        ; Glebokosc perspektywiczna Z oraz wspolrzedne tekstury UV
        move.w  d7,d0
        sub.w   t3d_y_horiz(pc),d0
        bge.s   .dy_pos
        neg.w   d0
.dy_pos:addq.w  #6,d0
        move.w  #3072,d2
        divu.w  d0,d2
        move.w  d2,d6
        add.w   t3d_scroll_z(pc),d6     ; V = Z + scroll_z

        move.w  d2,d0
        lsl.w   #3,d0                   ; dU (8.8)
        move.w  t3d_scroll_x(pc),d2
        lsl.w   #8,d2
        move.w  d0,d4
        muls.w  #160,d4
        sub.l   d4,d2                   ; U_start (8.8)

        move.w  d3,a2
        cmp.w   d5,a2
        bge.s   .max_ok
        move.w  d5,a2
.max_ok:cmp.w   a2,d7
        bgt.s   .full_ground

        ; Ukosna linia horyzontu przecina wiersz Y -> oblicz X_split
        move.w  d5,a2
        sub.w   d3,a2
        cmp.w   #0,a2
        beq.s   .full_ground
        move.w  d7,a4
        sub.w   d3,a4
        move.w  a4,d4
        muls.w  #320,d4
        move.w  a2,d0
        divs.w  d0,d4
        tst.w   d4
        bge.s   .xs_min
        moveq   #0,d4
.xs_min:cmp.w   #320,d4
        ble.s   .xs_max
        move.w  #320,d4
.xs_max:move.w  d4,a4

        cmp.w   d5,d3
        bgt.s   .sky_left

        move.w  a4,d3
        bsr.s   .draw_ground_span
        move.w  #320,d3
        sub.w   a4,d3
        bsr.s   .draw_sky_span
        bra.s   .next_row

.sky_left:
        move.w  a4,d3
        bsr.s   .draw_sky_span
        move.w  #320,d3
        sub.w   a4,d3
        bsr.s   .draw_ground_span
        bra.s   .next_row

.full_sky:
        moveq   #79,d0
.fs_lp: move.l  d1,(a1)+
        dbf     d0,.fs_lp
        bra.s   .next_row

.full_ground:
        move.w  #320,d3
        bsr.s   .draw_ground_span

.next_row:
        addq.w  #1,d7
        cmp.w   #T3D_H,d7
        blt.w   .row_loop

        movem.l (sp)+,d0-d7/a0-a6
        rts

.draw_sky_span:
        subq.w  #1,d3
        blt.s   .dss_end
.dss_lp:move.b  d1,(a1)+
        dbf     d3,.dss_lp
.dss_end:rts

.draw_ground_span:
        subq.w  #1,d3
        blt.s   .dgs_end
        ext.l   d0
        move.w  d6,d5
        and.w   #31,d5
.dgs_lp:move.l  d2,d4
        lsr.l   #8,d4
        eor.w   d5,d4
        lsr.w   #4,d4
        and.w   #3,d4
        move.b  (a5,d4.w),(a1)+
        add.l   d0,d2
        dbf     d3,.dgs_lp
.dgs_end:rts

        cnop    0,4
t3d_scroll_z:   dc.w    0
t3d_scroll_x:   dc.w    0
t3d_sin_roll:   dc.w    0
t3d_y_horiz:    dc.w    T3D_MID_Y

t3d_pal_ocean:  dc.b    18,22,26,30, 10
t3d_pal_canyon: dc.b    36,40,44,48, 12
t3d_pal_citadel:dc.b    52,56,60,64, 8
        even
