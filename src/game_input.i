        section code,code
        even
input_update_controls:
        movem.l d0-d3/a0,-(sp)

        ; 1. Joystick / Pad w Porcie 2 ($DFF00C)
        move.w  $dff00c,d0
        move.w  d0,d1
        lsr.w   #1,d1
        eor.w   d0,d1

        btst    #8,d1
        beq.s   .jn_no_up
        move.b  #1,input_pad_mode
        clr.b   mouse_active
        subq.w  #2,user_pitch
.jn_no_up:
        btst    #0,d1
        beq.s   .joy_lr
        addq.w  #2,user_pitch

.joy_lr:
        btst    #9,d0
        beq.s   .j_no_left
        move.b  #1,input_pad_mode
        clr.b   mouse_active
        addq.w  #3,user_yaw
.j_no_left:
        btst    #1,d0
        beq.s   .read_kbd
        subq.w  #3,user_yaw

        ; 2. Klawiatura CIA-A ($BFEC01 SDR vs kbd_last_sdr + impuls ACK + 256B kbd_matrix)
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
        bcs.w   .key_up

        ; Klawisz wcisniety (down)
        clr.b   input_pad_mode
        move.b  #1,(a0,d0.w)
        move.b  d0,kbd_held_raw

        cmp.b   #$12,d0                 ; E = zwieksz ciag
        beq.s   .thr_up
        cmp.b   #$0c,d0                 ; +/= = zwieksz ciag
        beq.s   .thr_up
        cmp.b   #$10,d0                 ; Q = zmniejsz ciag
        beq.s   .thr_dn
        cmp.b   #$31,d0                 ; Z = zmniejsz ciag
        beq.s   .thr_dn
        cmp.b   #$33,d0                 ; C = zmniejsz ciag
        beq.s   .thr_dn
        cmp.b   #$0b,d0                 ; - = zmniejsz ciag
        beq.s   .thr_dn
        cmp.b   #$32,d0                 ; X = zawis (Hover)
        bne.w   .rk_nx
        clr.b   ship_throttle
        bra.w   .rk_nx

.thr_up:
        move.b  ship_throttle(pc),d1
        cmp.b   #4,d1
        bge.s   .held_keys
        addq.b  #1,ship_throttle
        bra.w   .rk_nx

.thr_dn:
        move.b  ship_throttle(pc),d1
        beq.s   .held_keys
        subq.b  #1,ship_throttle
        bra.w   .rk_nx

.key_up:
        clr.b   (a0,d0.w)
        cmp.b   kbd_held_raw(pc),d0
        bne.w   .rk_nx
        move.b  #$ff,kbd_held_raw

.rk_nx: dbf     d3,.rk_lp
.held_keys:
        lea     kbd_matrix,a0
        ; Skret w lewo: Strzalka Lewo ($4F) lub A ($20)
        tst.b   $4f(a0)
        bne.s   .turn_l
        tst.b   $20(a0)
        beq.s   .chk_r
.turn_l:
        addq.w  #3,user_yaw
.chk_r:
        ; Skret w prawo: Strzalka Prawo ($4E) lub D ($22)
        tst.b   $4e(a0)
        bne.s   .turn_r
        tst.b   $22(a0)
        beq.s   .chk_u
.turn_r:
        subq.w  #3,user_yaw
.chk_u:
        ; Pochylenie w dol/nurkowanie: Strzalka Gora ($4C) lub W ($11)
        tst.b   $4c(a0)
        bne.s   .pitch_u
        tst.b   $11(a0)
        beq.s   .chk_d
.pitch_u:
        subq.w  #2,user_pitch
.chk_d:
        ; Wznoszenie: Strzalka Dol ($4D) lub S ($21)
        tst.b   $4d(a0)
        bne.s   .pitch_d
        tst.b   $21(a0)
        beq.s   .chk_act
.pitch_d:
        addq.w  #2,user_pitch

.chk_act:

        ; Dopalacz: Spacja ($40), LAlt ($64), RAlt ($65), Enter ($44) lub 2. przycisk pada
        clr.b   fire_held
        tst.b   $40(a0)
        bne.s   .do_fh
        tst.b   $64(a0)
        bne.s   .do_fh
        tst.b   $65(a0)
        bne.s   .do_fh
        tst.b   $44(a0)
        bne.s   .do_fh
        tst.b   pad_btn2_held
        beq.s   .chk_tl
.do_fh: move.b  #1,fire_held

.chk_tl:
        ; Narzedzie robocze / Skaner / Wiazka: F ($23), R ($13), LMB lub Fire Pada
        clr.b   tool_held
        tst.b   $23(a0)
        bne.s   .do_tl
        tst.b   $13(a0)
        bne.s   .do_tl
        tst.b   cine_active
        bne.s   .done
        tst.b   mouse_lmb_prev
        bne.s   .do_tl
        btst    #7,$bfe001
        bne.s   .done
        move.b  #1,input_pad_mode
        clr.b   mouse_active
.do_tl: move.b  #1,tool_held

.done:
        movem.l (sp)+,d0-d3/a0
        rts

        even
user_yaw:       dc.w 0
user_pitch:     dc.w 0
user_zoom:      dc.w 0
kbd_held_raw:   dc.b $ff
kbd_last_sdr:   dc.b $ff
fire_held:      dc.b 0
tool_held:      dc.b 0
ship_throttle:  dc.b 2
input_pad_mode: dc.b 0
        section fastram_bss,bss
        even
kbd_matrix:     ds.b 128
        section code,code
