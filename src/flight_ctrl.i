        section code,code
flight_update_360:
        movem.l d0-d4/a0,-(sp)
        ; Po wyborze misji mysliwiec wykonuje automatyczny filmowy zwrot w glab doliny
        tst.b   intro_turn_done(pc)
        bne.s   .chk_cine
        move.w  user_yaw(pc),d0
        and.w   #255,d0
        cmp.w   #96,d0
        beq.s   .turn_ok
        addq.w  #3,user_yaw
        bra.s   .skip_m
.turn_ok:
        move.b  #1,intro_turn_done
.chk_cine:
        tst.b   cine_active
        bne.s   .skip_m
        move.w  mouse_dx(pc),d0
        neg.w   d0
        asr.w   #3,d0
        cmp.w   #-6,d0
        bge.s   .mx_lo
        moveq   #-6,d0
.mx_lo: cmp.w   #6,d0
        ble.s   .mx_ok
        moveq   #6,d0
.mx_ok: add.w   d0,user_yaw
        move.w  mouse_dy(pc),d0
        asr.w   #3,d0
        cmp.w   #-4,d0
        bge.s   .my_lo
        moveq   #-4,d0
.my_lo: cmp.w   #4,d0
        ble.s   .my_ok
        moveq   #4,d0
.my_ok: add.w   d0,user_pitch
.skip_m:
        move.w  user_yaw(pc),d0
        and.w   #255,d0
        move.w  d0,user_yaw
        move.w  d0,d1
        sub.w   cam_yaw(pc),d1
        ext.w   d1
        cmp.w   #-128,d1
        bge.s   .dw1
        add.w   #256,d1
.dw1:   cmp.w   #128,d1
        ble.s   .dw2
        sub.w   #256,d1
.dw2:   ; Przechyl skrzydel reaguje plynnie na skret
        move.w  d1,d2
        asl.w   #2,d2
        add.w   ship_bank(pc),d2
        asr.w   #1,d2
        cmp.w   #-18,d2
        bge.s   .bk1
        move.w  #-18,d2
.bk1:   cmp.w   #18,d2
        ble.s   .bk2
        move.w  #18,d2
.bk2:   move.w  d2,ship_bank

        ; Plynne podazanie cam_yaw za user_yaw
        move.w  d0,cam_yaw

        ; DOKLADNIE ten sam wektor osi wzroku (X=160) co w terrain_3d.i
        lea     sin_tab,a0
        move.w  cam_yaw(pc),d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d1            ; vx
        sub.w   #128,d0
        and.w   #510,d0
        move.w  (a0,d0.w),d2            ; vy

        ; Predkosc zalezy od przepustnicy (0=zawis, 1..4=ciag) + dopalacz
        moveq   #0,d3
        move.b  ship_throttle(pc),d3
        cmp.b   #1,player_role
        bne.s   .r_sp
        tst.w   d3
        beq.s   .r_sp                   ; Pioneer w zawisie (0) tez stoi w miejscu
        addq.w  #1,d3                   ; Bonus zwiadowczy Pioneera w locie
.r_sp:  tst.b   fire_held
        beq.s   .sp_ok
        addq.w  #4,d3                   ; Dopalacz (Spacja / Alt / Enter)
        moveq   #0,d0
        move.b  ship_upgrade_lvl(pc),d0
        add.w   d0,d3
.sp_ok: muls.w  d3,d1
        muls.w  d3,d2
        asr.l   #3,d1
        asr.l   #3,d2
        add.l   d1,cam_x
        add.l   d2,cam_y

        ; Fizyka poduszkowca: plynne unoszenie sie na poduszce powietrznej nad terenem i woda
        move.w  user_pitch(pc),d0
        cmp.w   #-24,d0
        bge.s   .pt1
        move.w  #-24,d0
.pt1:   cmp.w   #24,d0
        ble.s   .pt2
        move.w  #24,d0
.pt2:   move.w  d0,user_pitch
        move.w  #112,d1
        sub.w   d0,d1
        move.w  d1,cam_pitch

        move.b  cam_y+2(pc),d2
        and.w   #255,d2
        lsl.w   #8,d2
        move.b  cam_x+2(pc),d0
        and.w   #255,d0
        or.w    d0,d2
        and.l   #$ffff,d2
        lea     exo_voxel_data,a0
        moveq   #0,d0
        move.b  (a0,d2.l),d0
        add.w   #15,d0                  ; poduszka powietrzna 15 jednostek nad terenem/woda
        move.w  cam_alt(pc),d1
        add.w   d0,d1
        asr.w   #1,d1                   ; plynna amortyzacja zawieszenia poduszkowca
        cmp.w   #215,d1
        ble.s   .al_hi
        move.w  #215,d1
.al_hi: move.w  d1,cam_alt
        movem.l (sp)+,d0-d4/a0
        rts

        even
intro_turn_done: dc.b 0,0
