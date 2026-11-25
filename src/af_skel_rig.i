; ============================================================================
; AETHER FALCON: VANGUARD - Silnik Animacji Szkieletowej 2D & Shaded N-gon
; ============================================================================

; Rysuje cieniowany wielokat (automatyczne skalowanie Y dla 320x128 i 320x256)
af_skel_emit_poly:
        movem.l d0-d1/a0,-(sp)
        ifnd FULL_RES
        lea     af_skel_pbuf(pc),a0
        move.w  (a0)+,d0
        subq.w  #1,d0
.sy_lp: addq.l  #2,a0
        move.w  (a0),d1
        asr.w   #1,d1
        move.w  d1,(a0)+
        dbf     d0,.sy_lp
        endif
        lea     af_skel_pbuf(pc),a0
        bsr.w   af_aw_fill_ngon
        movem.l (sp)+,d0-d1/a0
        rts

; Rysuje segment kosci szkieletu od (d0,d1) do (d2,d3) o grubosci d4, kolor d6
af_skel_draw_bone:
        movem.l d0-d5/a0,-(sp)
        lea     af_skel_pbuf(pc),a0
        move.w  #4,(a0)+
        move.w  d0,d5
        sub.w   d4,d5
        move.w  d5,(a0)+
        move.w  d1,(a0)+
        move.w  d0,d5
        add.w   d4,d5
        move.w  d5,(a0)+
        move.w  d1,(a0)+
        move.w  d2,d5
        add.w   d4,d5
        move.w  d5,(a0)+
        move.w  d3,(a0)+
        move.w  d2,d5
        sub.w   d4,d5
        move.w  d5,(a0)+
        move.w  d3,(a0)+
        bsr.s   af_skel_emit_poly
        movem.l (sp)+,d0-d5/a0
        rts

; Renderuje hierarchiczny szkielet pilota w pozycji bioder (d4,d5), faza cyklu d3 (0..15)
; d2 = tryb: 0 = marsz po pokladzie, 1 = wspinaczka po drabince, 2 = siedzi w kokpicie
af_skel_render_pilot:
        movem.l d0-d7/a0-a1,-(sp)
        move.w  d3,d6
        and.w   #15,d6
        lea     af_skel_sin16(pc),a1
        move.b  (a1,d6.w),d7
        ext.w   d7                      ; d7 = wychylenie wahadla (-12..+12)
        cmp.w   #2,d2
        beq.w   .sk_seated
        cmp.w   #1,d2
        beq.w   .sk_climb

        ; --- TRYB 0: Marsz po pokladzie (naprzemienne udo + lydka + but) ---
        ; Tylna noga (ciemny cien $14)
        move.w  d4,d0
        move.w  d5,d1
        move.w  d4,d2
        sub.w   d7,d2
        move.w  d5,d3
        add.w   #28,d3
        movem.w d2-d3,-(sp)
        moveq   #6,d4
        move.b  #$14,d6
        bsr.s   af_skel_draw_bone
        movem.w (sp)+,d0-d1
        move.w  d0,d2
        subq.w  #4,d2
        move.w  d1,d3
        add.w   #26,d3
        moveq   #5,d4
        move.b  #$13,d6
        bsr.w   af_skel_draw_bone
        ; Przednia noga (jasniejszy odcien $16)
        move.l  8(sp),d4
        move.l  12(sp),d5
        move.w  d4,d0
        move.w  d5,d1
        move.w  d4,d2
        add.w   d7,d2
        move.w  d5,d3
        add.w   #28,d3
        movem.w d2-d3,-(sp)
        moveq   #6,d4
        move.b  #$16,d6
        bsr.w   af_skel_draw_bone
        movem.w (sp)+,d0-d1
        move.w  d0,d2
        addq.w  #2,d2
        move.w  d1,d3
        add.w   #26,d3
        moveq   #5,d4
        move.b  #$15,d6
        bsr.w   af_skel_draw_bone
        bra.w   .sk_upper_body

.sk_climb:
        ; Wspinaczka po drabince: kolana uginaja sie naprzemiennie, rece chwytaja szczeble!
        move.w  d4,d0
        move.w  d5,d1
        move.w  d4,d2
        add.w   #12,d2
        move.w  d5,d3
        add.w   #18,d3
        sub.w   d7,d3
        movem.w d2-d3,-(sp)
        moveq   #5,d4
        move.b  #$15,d6
        bsr.w   af_skel_draw_bone
        movem.w (sp)+,d0-d1
        move.w  d0,d2
        subq.w  #6,d2
        move.w  d1,d3
        add.w   #22,d3
        moveq   #5,d4
        move.b  #$14,d6
        bsr.w   af_skel_draw_bone

.sk_upper_body:
        move.l  8(sp),d4
        move.l  12(sp),d5
        ; Cieniowany 5-katny korpus pilota (lewa strona ciemniejsza $16, prawa oswietlona $FD)
        lea     af_skel_pbuf(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0
        sub.w   #14,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        sub.w   #42,d1
        move.w  d1,(a0)+
        move.w  d4,(a0)+
        move.w  d1,(a0)+
        move.w  d4,(a0)+
        move.w  d5,(a0)+
        move.w  d4,d0
        sub.w   #11,d0
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.b  #$16,d6
        bsr.w   af_skel_emit_poly
        lea     af_skel_pbuf(pc),a0
        move.w  #4,(a0)+
        move.w  d4,(a0)+
        move.w  d5,d1
        sub.w   #42,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #15,d0
        move.w  d0,(a0)+
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #12,d0
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.w  d4,(a0)+
        move.w  d5,(a0)+
        move.b  #$FD,d6
        bsr.w   af_skel_emit_poly
        ; Animowane ramie pilota (wachadlo w marszu lub chwyt szczebla we wspinaczce)
        move.w  d4,d0
        move.w  d5,d1
        sub.w   #36,d1
        move.w  d4,d2
        sub.w   d7,d2
        cmp.w   #1,2(sp)
        bne.s   .arm_ok
        move.w  d4,d2
        add.w   #18,d2
        sub.w   #12,d1
.arm_ok:
        move.w  d1,d3
        add.w   #26,d3
        moveq   #4,d4
        move.b  #$FF,d6
        bsr.w   af_skel_draw_bone

.sk_seated:
        move.l  8(sp),d4
        move.l  12(sp),d5
        ; Jesli siedzi w kokpicie (tryb 2), narysuj gorna czesc kombinezonu nad burta
        cmp.w   #2,2(sp)
        bne.s   .sk_head
        lea     af_skel_pbuf(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0
        sub.w   #14,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        sub.w   #28,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #14,d0
        move.w  d0,(a0)+
        move.w  d1,(a0)+
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.w  d4,d0
        sub.w   #14,d0
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.b  #$FD,d6
        bsr.w   af_skel_emit_poly
        sub.w   #28,d5
        bra.s   .sk_helmet_draw
.sk_head:
        sub.w   #42,d5
.sk_helmet_draw:
        ; Profilowany 6-katny helm lotniczy (cien z tylu + biala skorupa + zloty wizjer)
        lea     af_skel_pbuf(pc),a0
        move.w  #5,(a0)+
        move.w  d4,d0
        sub.w   #11,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        sub.w   #20,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #8,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        sub.w   #24,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #14,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        sub.w   #12,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #10,d0
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.w  d4,d0
        sub.w   #10,d0
        move.w  d0,(a0)+
        move.w  d5,(a0)+
        move.b  #$FF,d6
        bsr.w   af_skel_emit_poly
        ; Zloty refleksyjny wizjer helmu (4-kat)
        lea     af_skel_pbuf(pc),a0
        move.w  #4,(a0)+
        move.w  d4,d0
        addq.w  #1,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        sub.w   #19,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #14,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        sub.w   #15,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        add.w   #12,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        subq.w  #6,d1
        move.w  d1,(a0)+
        move.w  d4,d0
        addq.w  #1,d0
        move.w  d0,(a0)+
        move.w  d5,d1
        subq.w  #8,d1
        move.w  d1,(a0)+
        move.b  #$FE,d6
        bsr.w   af_skel_emit_poly
        movem.l (sp)+,d0-d7/a0-a1
        rts

af_skel_sin16:
        dc.b    0, 5, 9, 11, 12, 11, 9, 5, 0, -5, -9, -11, -12, -11, -9, -5
af_skel_pbuf:
        ds.w    20
