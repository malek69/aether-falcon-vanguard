        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD v0.2.0 - Tabula Rasa 3D Perspective Horizon & Ground
; Styl: After Burner / Star Fox / T-Zero (obrot horyzontu + perspektywa Z)
; ============================================================================

        cnop    0,4
render_3d_terrain_flyover:
        movem.l d0-d7/a0-a5,-(sp)

        ; Oblicz kat przechylenia horyzontu (Roll) z af_ship_dx oraz wysokosc horyzontu z af_ship_dy
        lea     sin_tab,a0
        move.w  af_ship_dx,d0
        neg.w   d0
        asr.w   #2,d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d4            ; d4 = sin(roll) (-256..256)
        add.w   #128,d0
        and.w   #510,d0
        move.w  (a0,d0.w),d5            ; d5 = cos(roll) (-256..256)

        ; Bazowa wysokosc horyzontu (Y_horiz) reagujaca na wznoszenie/nurkowanie af_ship_dy
        move.w  af_ship_dy,d6
        asr.w   #2,d6
        ifd FULL_RES
        add.w   #124,d6                 ; srodek ekranu 256
        else
        add.w   #62,d6                  ; srodek ekranu 128
        endif

        ; Predkosc przesuwu pasow ziemi (Gora = dopalacz, Dol = hamulec)
        moveq   #3,d1
        cmp.w   #-10,af_ship_dy
        bge.s   .sp_chk2
        moveq   #7,d1
.sp_chk2:
        cmp.w   #10,af_ship_dy
        ble.s   .sp_add
        moveq   #1,d1
.sp_add:add.w   d1,t3d_scroll_z

        ; Kolory ziemi w zaleznosci od misji i nastroju swiata (af_world_mood)
        move.l  #$04040505,d2           ; ciemny ocean / ziemia (kolor 1)
        move.l  #$06060707,d3           ; jasniejszy pas perspektywy (kolor 2)
        cmp.w   #1,af_mission
        bne.s   .m_chk3
        move.l  #$08080909,d2           ; Kanion Krell (terakota/piasek)
        move.l  #$0A0A0B0B,d3
        bra.s   .col_ok
.m_chk3:cmp.w   #2,af_mission
        bne.s   .col_ok
        move.l  #$0C0C0D0D,d2           ; Cytadela Lewiatana (stal/magma)
        move.l  #$0E0E0F0F,d3
.col_ok:
        ; Renderuj obracany horyzont 3D + pasy perspektywiczne ziemi (After Burner)
        lea     chunky_buf,a1
        ifd FULL_RES
        move.w  #255,d7
        else
        moveq   #127,d7
        endif
        moveq   #0,d0                   ; d0 = screen Y

.row_lp:
        ; Oblicz wysokosc horyzontu na lewej krawedzi (X = -160) oraz krok dY/dX = -sin(roll)/cos(roll)
        ; Uproszczone nachylenie: y_h(x) = y_horiz + ((x - 160) * sin_roll) >> 9
        move.w  d0,d1
        sub.w   d6,d1                   ; dy od srodka horyzontu
        blt.s   .is_sky

        ; Wybor pasma perspektywy (1/Z efekt szachownicy/pasow terenu)
        move.w  d1,d4
        addq.w  #4,d4
        move.w  #2048,d5
        divu.w  d4,d5                   ; d5 ~= glebokosc Z
        add.w   t3d_scroll_z(pc),d5
        btst    #4,d5
        beq.s   .use_c1
        move.l  d3,a4
        bra.s   .fill_ln
.use_c1:move.l  d2,a4
.fill_ln:
        moveq   #79,d4                  ; 80 * 4 = 320 pikseli
.px_lp: move.l  a4,(a1)+
        dbf     d4,.px_lp
        bra.s   .next_y

.is_sky:
        ; Czyste niebo AGA (gradient noc/zmierzch/alarm)
        move.l  #$01010101,a4
        cmp.w   #2,af_world_mood
        bne.s   .sky_f
        move.l  #$02020202,a4           ; czerwony alert nieba przy kryzysie
.sky_f: moveq   #79,d4
.sk_lp: move.l  a4,(a1)+
        dbf     d4,.sk_lp

.next_y:
        addq.w  #1,d0
        dbf     d7,.row_lp

        movem.l (sp)+,d0-d7/a0-a5
        rts

        cnop    0,4
t3d_scroll_z:   dc.w    0
