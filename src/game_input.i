        section code,code
        even
input_update_controls:
        movem.l d0-d3/a0,-(sp)

        ; 1. Joystick w Porcie 2 ($DFF00C)
        move.w  $dff00c,d0
        move.w  d0,d1
        lsr.w   #1,d1
        eor.w   d0,d1
        btst    #8,d1
        beq.s   .jn_no_up
        subq.w  #2,user_pitch
.jn_no_up:
        btst    #0,d1
        beq.s   .joy_lr
        addq.w  #2,user_pitch
.joy_lr:
        btst    #9,d0
        beq.s   .j_no_left
        addq.w  #3,user_yaw
.j_no_left:
        btst    #1,d0
        beq.s   .read_kbd
        subq.w  #3,user_yaw

        ; 2. Klawiatura CIA-A ($BFEC01) -> kbd_matrix[128]
.read_kbd:
        moveq   #1,d3
.rk_lp: move.b  $bfec01,d0
        cmp.b   kbd_last_sdr(pc),d0
        beq.w   .rk_nx
        move.b  d0,kbd_last_sdr
        or.b    #$40,$bfee01
        move.b  $dff006,d1
.ack1:  cmp.b   $dff006,d1
        beq.s   .ack1
        move.b  $dff006,d1
.ack2:  cmp.b   $dff006,d1
        beq.s   .ack2
        and.b   #$bf,$bfee01

        not.b   d0
        lsr.b   #1,d0
        lea     kbd_matrix,a0
        and.w   #$007f,d0
        bcs.s   .key_up

        move.b  #1,(a0,d0.w)
        move.b  d0,kbd_held_raw
        move.b  d0,kbd_last_press

        tst.b   cine_active
        bne.s   .rk_nx
        cmp.b   #$12,d0                 ; E = zwieksz ciag
        beq.s   .thr_up
        cmp.b   #$10,d0                 ; Q = zmniejsz ciag
        beq.s   .thr_dn
        cmp.b   #$31,d0                 ; Z = zmniejsz ciag
        beq.s   .thr_dn
        cmp.b   #$33,d0                 ; C = zmniejsz ciag
        beq.s   .thr_dn
        cmp.b   #$32,d0                 ; X = zawis (0)
        bne.s   .rk_nx
        clr.b   ship_throttle
        bra.s   .rk_nx

.thr_up:
        cmp.b   #4,ship_throttle
        bge.s   .rk_nx
        addq.b  #1,ship_throttle
        bra.s   .rk_nx
.thr_dn:
        tst.b   ship_throttle
        beq.w   .rk_nx
        subq.b  #1,ship_throttle
        bra.s   .rk_nx

.key_up:
        clr.b   (a0,d0.w)
        cmp.b   kbd_held_raw(pc),d0
        bne.s   .rk_nx
        move.b  #$ff,kbd_held_raw
.rk_nx: dbf     d3,.rk_lp

.held_keys:
        lea     kbd_matrix,a0
        tst.b   $4f(a0)                 ; Strzalka Lewo
        bne.s   .turn_l
        tst.b   $20(a0)                 ; A
        beq.s   .chk_r
.turn_l:moveq   #3,d2
        cmp.b   #1,player_role
        bne.s   .tl_3
        moveq   #4,d2
.tl_3:  cmp.b   #3,player_role
        bne.s   .tl_ok
        moveq   #2,d2
.tl_ok: add.w   d2,user_yaw
.chk_r: tst.b   $4e(a0)                 ; Strzalka Prawo
        bne.s   .turn_r
        tst.b   $22(a0)                 ; D
        beq.s   .chk_u
.turn_r:moveq   #3,d2
        cmp.b   #1,player_role
        bne.s   .tr_3
        moveq   #4,d2
.tr_3:  cmp.b   #3,player_role
        bne.s   .tr_ok
        moveq   #2,d2
.tr_ok: sub.w   d2,user_yaw
.chk_u: tst.b   $4c(a0)                 ; Strzalka Gora
        bne.s   .pitch_u
        tst.b   $11(a0)                 ; W
        beq.s   .chk_d
.pitch_u:subq.w #2,user_pitch
.chk_d: tst.b   $4d(a0)                 ; Strzalka Dol
        bne.s   .pitch_d
        tst.b   $21(a0)                 ; S
        beq.s   .chk_fh
.pitch_d:addq.w #2,user_pitch

.chk_fh:
        clr.b   boost_held
        tst.b   $40(a0)                 ; Spacja = dopalacz
        bne.s   .do_bst
        tst.b   $64(a0)                 ; LAlt = dopalacz
        bne.s   .do_bst
        tst.b   pad_btn2_held
        beq.s   .chk_tl
.do_bst:move.b  #1,boost_held
.chk_tl:clr.b   fire_held
        tst.b   cine_active
        bne.s   .done
        tst.b   $23(a0)                 ; F = narzedzie robocze
        bne.s   .do_fh
        tst.b   $44(a0)                 ; Enter = narzedzie robocze
        bne.s   .do_fh
        tst.b   mouse_lmb_prev          ; LMB = narzedzie robocze
        bne.s   .do_fh
        btst    #7,$bfe001              ; Fire Port 2
        bne.s   .done
.do_fh: move.b  #1,fire_held

.done:  movem.l (sp)+,d0-d3/a0
        rts

        even
user_yaw:       dc.w 0
user_pitch:     dc.w 0
user_zoom:      dc.w 0
kbd_held_raw:   dc.b $ff
kbd_last_press: dc.b $ff
kbd_last_sdr:   dc.b $ff
fire_held:      dc.b 0
boost_held:     dc.b 0
ship_throttle:  dc.b 1,0
        section fastram_bss,bss
        even
kbd_matrix:     ds.b 128
        section code,code
        even
