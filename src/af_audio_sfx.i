; ============================================================================
; AETHER FALCON: VANGUARD - Sterownik Audio .MOD + Bare-Metal Paula SFX
; ============================================================================

SFX_LOCKON      equ     1
SFX_MISSILE     equ     2
SFX_EXPLODE     equ     3
SFX_CORE        equ     4

        section code,code
        cnop    0,4
af_audio_init:
        jsr     pt_init
        clr.w   af_sfx_timer
        rts

; Wyzwolenie efektu dzwiekowego na kanale 3 ukladu Paula ($DFF0D0)
; Wejscie: d0.w = typ SFX (SFX_*)
        cnop    0,4
af_trigger_sfx:
        movem.l d0-d2/a0-a1,-(sp)
        lea     $dff000,a1
        move.w  #$0008,$096(a1)         ; Wylacz DMA kanalu 3 na czas konfiguracji

        cmp.w   #SFX_LOCKON,d0
        beq.s   .sfx_lock
        cmp.w   #SFX_MISSILE,d0
        beq.s   .sfx_msl
        cmp.w   #SFX_EXPLODE,d0
        beq.s   .sfx_exp

        ; SFX_CORE: krystaliczny dzwiek zebrania Rdzenia Eteru
        lea     sfx_wave_sine,a0
        move.w  #32,d1                  ; dlugosc w slowach
        move.w  #180,d2                 ; okres (wysoki ton)
        move.w  #10,af_sfx_timer
        bra.s   .play_ch3

.sfx_lock:
        lea     sfx_wave_sine,a0
        move.w  #32,d1
        move.w  #140,d2                 ; ostry pik radaru Lock-On
        move.w  #6,af_sfx_timer
        bra.s   .play_ch3

.sfx_msl:
        lea     sfx_wave_noise,a0
        move.w  #128,d1
        move.w  #260,d2                 ; swist odpalenia salwy rakiet
        move.w  #14,af_sfx_timer
        bra.s   .play_ch3

.sfx_exp:
        lea     sfx_wave_noise,a0
        move.w  #128,d1
        move.w  #440,d2                 ; niski wybuch celu
        move.w  #18,af_sfx_timer

.play_ch3:
        move.l  a0,$0d0(a1)             ; AUD3LCH
        move.w  d1,$0d4(a1)             ; AUD3LEN
        move.w  d2,$0d6(a1)             ; AUD3PER
        move.w  #64,$0d8(a1)            ; AUD3VOL (max)
        move.w  #$8008,$096(a1)         ; Wlacz DMA kanalu 3
        movem.l (sp)+,d0-d2/a0-a1
        rts

        cnop    0,4
af_sfx_tick:
        tst.w   af_sfx_timer
        beq.s   .done
        subq.w  #1,af_sfx_timer
        bne.s   .done
        move.w  #$0008,$dff096          ; Wycisz kanal 3 po zakonczeniu SFX
.done:  rts

        even
af_sfx_timer:   dc.w    0

        section sfx_chip,data_c
        even
sfx_wave_sine:
        dc.b    0,25,49,71,90,106,118,125,127,125,118,106,90,71,49,25
        dc.b    0,-25,-49,-71,-90,-106,-118,-125,-127,-125,-118,-106,-90,-71,-49,-25
        dc.b    0,25,49,71,90,106,118,125,127,125,118,106,90,71,49,25
        dc.b    0,-25,-49,-71,-90,-106,-118,-125,-127,-125,-118,-106,-90,-71,-49,-25

sfx_wave_noise:
        dcb.b   64,95
        dcb.b   64,-95
        dcb.b   64,60
        dcb.b   64,-60
