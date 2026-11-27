        section code,code

audio_load_tracks_hdd:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  4.w,a6
        lea     snd_dos_name(pc),a1
        moveq   #0,d0
        jsr     -552(a6)
        move.l  d0,a6
        tst.l   d0
        beq.w   .al_end

        lea     mod_path_0(pc),a2
        lea     mod_buf_0,a3
        moveq   #3,d7
.tr_lp: move.l  a2,d1
        move.l  #1005,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .tr_nx
        move.l  d4,d1
        move.l  a3,d2
        move.l  #24576,d3
        jsr     -42(a6)
        move.l  d4,d1
        jsr     -36(a6)
.tr_nx: adda.w  #20,a2
        adda.l  #24576,a3
        dbf     d7,.tr_lp

        move.l  a6,a1
        move.l  4.w,a6
        jsr     -414(a6)
.al_end:movem.l (sp)+,d0-d7/a0-a6
        rts

; d0.w = 0 (Intro/Epilog), 1 (Akt I), 2 (Akt II), 3 (Akt III)
audio_switch_track:
        movem.l d0-d1/a0-a1,-(sp)
        and.w   #3,d0
        cmp.b   current_track_id(pc),d0
        beq.s   .sw_dn
        move.b  d0,current_track_id
        mulu.w  #24576,d0
        lea     mod_buf_0,a0
        add.l   d0,a0
        lea     mod_data,a1
        move.w  #6143,d1
.cp_lp: move.l  (a0)+,(a1)+
        dbf     d1,.cp_lp
        jsr     pt_init
.sw_dn: movem.l (sp)+,d0-d1/a0-a1
        rts

exo_play_sfx_ping:
        movem.l d0-d1/a0,-(sp)
        lea     $dff000,a0
        move.w  #$0008,$96(a0)
        move.l  #exo_sfx_chime,$d0(a0)
        move.w  #128,$d4(a0)
        move.w  #175,$d6(a0)
        move.w  #60,$d8(a0)
        move.w  #$8008,$96(a0)
        movem.l (sp)+,d0-d1/a0
        rts

exo_play_sfx_scan:
        movem.l d0-d1/a0,-(sp)
        lea     $dff000,a0
        move.w  #$0008,$96(a0)
        move.l  #exo_sfx_beam,$d0(a0)
        move.w  #64,$d4(a0)
        move.w  #260,$d6(a0)
        move.w  #44,$d8(a0)
        move.w  #$8008,$96(a0)
        movem.l (sp)+,d0-d1/a0
        rts

snd_dos_name:   dc.b "dos.library",0
        even
mod_path_0:     dc.b "data/exo_intro.mod",0,0
mod_path_1:     dc.b "data/exo_theme.mod",0,0
mod_path_2:     dc.b "data/exo_act2.mod",0,0,0
mod_path_3:     dc.b "data/exo_act3.mod",0,0,0
current_track_id: dc.b 255,0

        section sfx_chip,data_c
        even
exo_sfx_chime:
        dc.b 0,35,68,96,116,126,124,110,86,54,18,-20,-56,-88,-112,-124
        dc.b -126,-116,-96,-68,-35,0,35,68,96,116,126,124,110,86,54,18
        dc.b 0,48,90,118,126,110,72,22,-32,-80,-114,-126,-114,-80,-32,22
        dc.b 72,110,126,118,90,48,0,-48,-90,-118,-126,-110,-72,-22,32,80
        dcb.b 192,0
exo_sfx_beam:
        dc.b 0,60,110,126,95,30,-45,-105,-126,-90,-20,55,115,124,80,10
        dc.b -65,-118,-122,-70,5,75,122,115,55,-20,-90,-126,-105,-45,30,95
        dcb.b 96,0

        section fastram_bss,bss
        even
mod_buf_0:      ds.b 24576
mod_buf_1:      ds.b 24576
mod_buf_2:      ds.b 24576
mod_buf_3:      ds.b 24576
        section code,code
