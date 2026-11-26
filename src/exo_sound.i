        section code,code
exo_play_sfx_ping:
        movem.l d0-d1/a0,-(sp)
        lea     $dff000,a0
        move.w  #$0008,$96(a0)
        move.l  #exo_sfx_wave,$d0(a0)
        move.w  #64,$d4(a0)
        move.w  #190,$d6(a0)
        move.w  #56,$d8(a0)
        move.w  #$8008,$96(a0)
        movem.l (sp)+,d0-d1/a0
        rts
        section sfx_chip,data_c
        even
exo_sfx_wave:
        dc.b 0,24,48,70,90,106,118,124,126,124,118,106,90,70,48,24
        dc.b 0,-24,-48,-70,-90,-106,-118,-124,-126,-124,-118,-106,-90,-70,-48,-24
        dcb.b 96,0
