        section code,code
        even
input_update_controls:
        movem.l d0-d3,-(sp)

        ; 1. Joystick w Porcie 2 ($DFF00C = JOY1DAT, Fire = bit 7 $BFE001)
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

        ; 2. Klawiatura CIA-A ($BFED01 ICR bit 3 + $BFEC01 SDR)
.read_kbd:
        move.b  $bfec01,d0
        cmp.b   kbd_last_sdr(pc),d0
        beq.w   .held_keys
        move.b  d0,kbd_last_sdr
        ; Impuls potwierdzenia ACK do klawiatury
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
        bcs.s   .key_up

        move.b  d0,kbd_held_raw
        cmp.b   #$40,d0                 ; Spacja = dopalacz / Fire
        beq.s   .set_fh
        cmp.b   #$64,d0                 ; Lewy Alt
        beq.s   .set_fh
        cmp.b   #$65,d0                 ; Prawy Alt
        beq.s   .set_fh
        cmp.b   #$44,d0                 ; Enter / Return
        bne.s   .held_keys
.set_fh:
        move.b  #1,fire_held
        bra.s   .held_keys

.key_up:
        cmp.b   #$40,d0
        beq.s   .clr_fh
        cmp.b   #$64,d0
        beq.s   .clr_fh
        cmp.b   #$65,d0
        beq.s   .clr_fh
        cmp.b   #$44,d0
        bne.s   .ku_raw
.clr_fh:
        clr.b   fire_held
.ku_raw:
        cmp.b   kbd_held_raw(pc),d0
        bne.s   .held_keys
        move.b  #$ff,kbd_held_raw

.held_keys:
        move.b  kbd_held_raw(pc),d0
        cmp.b   #$4f,d0                 ; Strzalka w lewo
        beq.s   .turn_l
        cmp.b   #$20,d0                 ; Klawisz A
        bne.s   .chk_r
.turn_l:
        addq.w  #3,user_yaw
.chk_r:
        cmp.b   #$4e,d0                 ; Strzalka w prawo
        beq.s   .turn_r
        cmp.b   #$22,d0                 ; Klawisz D
        bne.s   .chk_u
.turn_r:
        subq.w  #3,user_yaw
.chk_u:
        cmp.b   #$4c,d0                 ; Strzalka w gore
        beq.s   .pitch_u
        cmp.b   #$11,d0                 ; Klawisz W
        bne.s   .chk_d
.pitch_u:
        subq.w  #2,user_pitch
.chk_d:
        cmp.b   #$4d,d0                 ; Strzalka w dol
        beq.s   .pitch_d
        cmp.b   #$21,d0                 ; Klawisz S
        bne.s   .done
.pitch_d:
        addq.w  #2,user_pitch

.done:
        movem.l (sp)+,d0-d3
        rts

        even
user_yaw:       dc.w 0
user_pitch:     dc.w 0
user_zoom:      dc.w 0
kbd_held_raw:   dc.b $ff
kbd_last_sdr:   dc.b $ff
fire_held:      dc.b 0,0
