        section code,code
exo_play_sfx_ping:
        movem.l a0,-(sp)
        lea     $dff000,a0
        move.w  #$0008,$96(a0)
        move.l  #exo_sfx_wave,$d0(a0)
        move.w  #64,$d4(a0)
        move.w  #175,$d6(a0)
        move.w  #60,$d8(a0)
        move.w  #$8008,$96(a0)
        movem.l (sp)+,a0
        rts

exo_play_sfx_beam:
        movem.l d0/a0,-(sp)
        lea     $dff000,a0
        move.w  #$0008,$96(a0)
        move.l  #exo_sfx_beam_wave,$d0(a0)
        move.w  #64,$d4(a0)
        move.w  vbl_tick+2(pc),d0
        and.w   #63,d0
        add.w   #210,d0
        move.w  d0,$d6(a0)
        move.w  #54,$d8(a0)
        move.w  #$8008,$96(a0)
        movem.l (sp)+,d0/a0
        rts

exo_play_sfx_dock:
        movem.l a0,-(sp)
        lea     $dff000,a0
        move.w  #$0008,$96(a0)
        move.l  #exo_sfx_dock_wave,$d0(a0)
        move.w  #128,$d4(a0)
        move.w  #140,$d6(a0)
        move.w  #64,$d8(a0)
        move.w  #$8008,$96(a0)
        movem.l (sp)+,a0
        rts

        section sfx_chip,data_c
        even
exo_sfx_wave:
        dc.b 0,24,48,70,90,106,118,124,126,124,118,106,90,70,48,24
        dc.b 0,-24,-48,-70,-90,-106,-118,-124,-126,-124,-118,-106,-90,-70,-48,-24
        dcb.b 96,0
exo_sfx_beam_wave:
        dc.b 60,95,120,95,60,0,-60,-95,-120,-95,-60,0,45,80,45,0
        dc.b -45,-80,-45,0,30,60,30,0,-30,-60,-30,0,20,40,20,0
        dcb.b 96,0
exo_sfx_dock_wave:
        dc.b 0,30,60,90,115,126,115,90,60,30,0,-30,-60,-90,-115,-126
        dc.b -115,-90,-60,-30,0,40,80,110,124,110,80,40,0,-40,-80,-110
        dcb.b 224,0
        section code,code
