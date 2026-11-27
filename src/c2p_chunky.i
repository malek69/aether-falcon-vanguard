    include "fast_clear.i"


    ifd FULL_RES
; ============================================================================
; c2p_160x128_to_aga (v1.14.5 - Superskalarny potok MC68060 pOEP/sOEP, 320x256)
; ============================================================================
c2p_160x128_to_aga:
    movem.l d0-d7/a0-a5,-(sp)
    lea     c2p_exp(pc),a5
    move.l  #$0f0f0f0f,a6               ; stala maska w rejestrze adresowym (zero hazardow)

    ; PRZEBIEG 1: Low nibbles (bity 0..3) -> BPL1..BPL4
    lea     chunky_buf,a0
    move.l  draw_bpl1(pc),a1
    move.l  draw_bpl2(pc),a2
    move.l  draw_bpl3(pc),a3
    move.l  draw_bpl4(pc),a4
    move.w  #255,d7
.p1_row_060:
    moveq   #9,d6                       ; 10 blokow po 32 piksele = 320 px
.p1_col_060:
    moveq   #0,d2
    move.l  a6,d0

    ; --- Bajt 0 (px 0..7) -> d1 ---
    and.l   (a0)+,d0                    ; pOEP: fetch + maska 4 pikseli
    move.b  d0,d2                       ; sOEP: indeks px0
    move.l  (a5,d2.w*4),d1              ; px0 -> bity 0
    lsr.w   #8,d0                       ; px1 w dolnym bajcie
    lsl.l   #4,d1                       ; px0 -> bity 4
    move.l  (a5,d0.w*4),d2              ; px1
    swap    d0                          ; px2/px3 do dolnego slowa
    lsl.l   #5,d2                       ; px1 -> bity 5
    or.l    d2,d1
    moveq   #0,d2
    move.b  d0,d2                       ; px2
    lsr.w   #8,d0                       ; px3
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d1
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0                       ; przeladuj maske do nastepnych 4 px
    lsl.l   #7,d2
    or.l    d2,d1

    and.l   (a0)+,d0                    ; px 4..7
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d1              ; px4 -> bity 0
    move.l  (a5,d0.w*4),d2              ; px5
    swap    d0
    lsl.l   #1,d2                       ; px5 -> bity 1
    or.l    d2,d1
    moveq   #0,d2
    move.b  d0,d2                       ; px6
    lsr.w   #8,d0                       ; px7
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d1
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #3,d2
    or.l    d2,d1

    ; --- Bajt 1 (px 8..15) -> d3 ---
    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d3
    lsr.w   #8,d0
    lsl.l   #4,d3
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d3
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d3
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #7,d2
    or.l    d2,d3

    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d3
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d3
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d3
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #3,d2
    or.l    d2,d3

    ; --- Bajt 2 (px 16..23) -> d4 ---
    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d4
    lsr.w   #8,d0
    lsl.l   #4,d4
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d4
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d4
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #7,d2
    or.l    d2,d4

    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d4
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d4
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d4
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #3,d2
    or.l    d2,d4

    ; --- Bajt 3 (px 24..31) -> d5 ---
    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d5
    lsr.w   #8,d0
    lsl.l   #4,d5
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d5
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d5
    move.l  (a5,d0.w*4),d2
    move.l  a6,d0
    lsl.l   #7,d2
    or.l    d2,d5

    and.l   (a0)+,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d5
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d5
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d5
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d5

    ; Zapis 32-bitowy do BPL4..BPL1 z parowaniem ALU
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a4)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a3)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a2)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a1)+

    dbf     d6,.p1_col_060
    dbf     d7,.p1_row_060

    ; PRZEBIEG 2: High nibbles (bity 4..7) -> BPL5..BPL8
    lea     chunky_buf,a0
    move.l  draw_bpl5(pc),a1
    move.l  draw_bpl6(pc),a2
    move.l  draw_bpl7(pc),a3
    move.l  draw_bpl8(pc),a4
    move.w  #255,d7
.p2_row_060:
    moveq   #9,d6
.p2_col_060:
    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d1
    lsr.w   #8,d0
    lsl.l   #4,d1
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d1
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d1
    move.l  (a5,d0.w*4),d2
    lsl.l   #7,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d1
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d1
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d1
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d3
    lsr.w   #8,d0
    lsl.l   #4,d3
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d3
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d3
    move.l  (a5,d0.w*4),d2
    lsl.l   #7,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d3
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d3
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d3
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d4
    lsr.w   #8,d0
    lsl.l   #4,d4
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d4
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d4
    move.l  (a5,d0.w*4),d2
    lsl.l   #7,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d4
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d4
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d4
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    move.l  (a5,d2.w*4),d5
    lsr.w   #8,d0
    lsl.l   #4,d5
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #5,d2
    or.l    d2,d5
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d5
    move.l  (a5,d0.w*4),d2
    lsl.l   #7,d2
    or.l    d2,d5

    move.l  (a0)+,d0
    move.l  a6,d2
    lsr.l   #4,d0
    and.l   d2,d0
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    or.l    (a5,d2.w*4),d5
    move.l  (a5,d0.w*4),d2
    swap    d0
    lsl.l   #1,d2
    or.l    d2,d5
    moveq   #0,d2
    move.b  d0,d2
    lsr.w   #8,d0
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d5
    move.l  (a5,d0.w*4),d2
    lsl.l   #3,d2
    or.l    d2,d5

    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a4)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a3)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a2)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a1)+

    dbf     d6,.p2_col_060
    dbf     d7,.p2_row_060

    movem.l (sp)+,d0-d7/a0-a5
    rts
    else
    ifd FULL_RES
; ============================================================================
; c2p_160x128_to_aga (FULL_RES 320x256 - 2px LUT c2p_exp256 + 32-bit Chip RAM)
; ============================================================================
c2p_160x128_to_aga:
    movem.l d0-d7/a0-a5,-(sp)
    lea     c2p_exp256(pc),a5

    ; PRZEBIEG 1: Low nibbles -> BPL1..BPL4
    lea     chunky_buf,a0
    move.l  draw_bpl1(pc),a1
    move.l  draw_bpl2(pc),a2
    move.l  draw_bpl3(pc),a3
    move.l  draw_bpl4(pc),a4
    move.w  #255,d7
.fr1_row:
    moveq   #9,d6
.fr1_col:
    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d1
    lsl.l   #4,d1
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d1
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d3
    lsl.l   #4,d3
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d3
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d4
    lsl.l   #4,d4
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d4
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d5
    lsl.l   #4,d5
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d5

    move.l  (a0)+,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d5
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d5

    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a4)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a3)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a2)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a1)+

    dbf     d6,.fr1_col
    dbf     d7,.fr1_row

    ; PRZEBIEG 2: High nibbles -> BPL5..BPL8
    lea     chunky_buf,a0
    move.l  draw_bpl5(pc),a1
    move.l  draw_bpl6(pc),a2
    move.l  draw_bpl7(pc),a3
    move.l  draw_bpl8(pc),a4
    move.w  #255,d7
.fr2_row:
    moveq   #9,d6
.fr2_col:
    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d1
    lsl.l   #4,d1
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d1
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d1

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d3
    lsl.l   #4,d3
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d3
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d3

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d4
    lsl.l   #4,d4
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d4
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d4

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d5
    lsl.l   #4,d5
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #6,d2
    or.l    d2,d5

    move.l  (a0)+,d0
    lsr.l   #4,d0
    and.l   #$0f0f0f0f,d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    or.l    (a5,d2.w*4),d5
    swap    d0
    move.w  d0,d2
    lsr.w   #4,d2
    or.b    d0,d2
    and.w   #$00ff,d2
    move.l  (a5,d2.w*4),d2
    lsl.l   #2,d2
    or.l    d2,d5

    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a4)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a3)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a2)+

    lsr.l   #8,d1
    lsr.l   #8,d3
    lsr.l   #8,d4
    lsr.l   #8,d5
    move.b  d1,d0
    lsl.w   #8,d0
    move.b  d3,d0
    swap    d0
    move.b  d4,d0
    lsl.w   #8,d0
    move.b  d5,d0
    move.l  d0,(a1)+

    dbf     d6,.fr2_col
    dbf     d7,.fr2_row

    movem.l (sp)+,d0-d7/a0-a5
    rts
    else
; ============================================================================
; c2p_160x128_to_aga (Single-Pass 2x1 Pixel-Doubled 8-Bitplane 256-Color C2P)
; ============================================================================
c2p_160x128_to_aga:
    movem.l d0-d7/a0-a6,-(sp)
    lea     c2p_2px_8bpl_lut(pc),a5
    lea     chunky_buf,a0
    move.l  draw_bpl1(pc),a1
    move.l  draw_bpl2(pc),a2
    move.l  draw_bpl3(pc),a3
    move.l  draw_bpl4(pc),a4
    move.l  draw_bpl5(pc),d4
    move.l  draw_bpl6(pc),d5
    move.l  draw_bpl7(pc),d6
    move.l  draw_bpl8(pc),a6

    move.w  #127,d7
.sp_row:
    moveq   #39,d3
.sp_col:
    moveq   #0,d0
    move.b  (a0),d0
    addq.l  #2,a0
    lsl.w   #3,d0
    move.l  (a5,d0.w),d1
    move.l  4(a5,d0.w),d2

    moveq   #0,d0
    move.b  (a0),d0
    addq.l  #2,a0
    lsl.w   #3,d0
    move.l  (a5,d0.w),-(sp)
    move.l  (sp)+,d0
    lsr.l   #2,d0
    or.l    d0,d1
    moveq   #0,d0
    move.b  -2(a0),d0
    lsl.w   #3,d0
    move.l  4(a5,d0.w),d0
    lsr.l   #2,d0
    or.l    d0,d2

    moveq   #0,d0
    move.b  (a0),d0
    addq.l  #2,a0
    lsl.w   #3,d0
    move.l  (a5,d0.w),d0
    lsr.l   #4,d0
    or.l    d0,d1
    moveq   #0,d0
    move.b  -2(a0),d0
    lsl.w   #3,d0
    move.l  4(a5,d0.w),d0
    lsr.l   #4,d0
    or.l    d0,d2

    moveq   #0,d0
    move.b  (a0),d0
    addq.l  #2,a0
    lsl.w   #3,d0
    move.l  (a5,d0.w),d0
    lsr.l   #6,d0
    or.l    d0,d1
    moveq   #0,d0
    move.b  -2(a0),d0
    lsl.w   #3,d0
    move.l  4(a5,d0.w),d0
    lsr.l   #6,d0
    or.l    d0,d2

    move.b  d2,(a1)+
    lsr.l   #8,d2
    move.b  d2,(a2)+
    lsr.l   #8,d2
    move.b  d2,(a3)+
    lsr.l   #8,d2
    move.b  d2,(a4)+

    exg     a1,d4
    move.b  d1,(a1)+
    exg     a1,d4
    lsr.l   #8,d1

    exg     a1,d5
    move.b  d1,(a1)+
    exg     a1,d5
    lsr.l   #8,d1

    exg     a1,d6
    move.b  d1,(a1)+
    exg     a1,d6
    lsr.l   #8,d1

    move.b  d1,(a6)+

    dbf     d3,.sp_col
    dbf     d7,.sp_row

    movem.l (sp)+,d0-d7/a0-a6
    rts
    endif
    endif
c2p_2px_8bpl_lut:
    dc.l $00000000,$00000000
    dc.l $00000000,$000000c0
    dc.l $00000000,$0000c000
    dc.l $00000000,$0000c0c0
    dc.l $00000000,$00c00000
    dc.l $00000000,$00c000c0
    dc.l $00000000,$00c0c000
    dc.l $00000000,$00c0c0c0
    dc.l $00000000,$c0000000
    dc.l $00000000,$c00000c0
    dc.l $00000000,$c000c000
    dc.l $00000000,$c000c0c0
    dc.l $00000000,$c0c00000
    dc.l $00000000,$c0c000c0
    dc.l $00000000,$c0c0c000
    dc.l $00000000,$c0c0c0c0
    dc.l $000000c0,$00000000
    dc.l $000000c0,$000000c0
    dc.l $000000c0,$0000c000
    dc.l $000000c0,$0000c0c0
    dc.l $000000c0,$00c00000
    dc.l $000000c0,$00c000c0
    dc.l $000000c0,$00c0c000
    dc.l $000000c0,$00c0c0c0
    dc.l $000000c0,$c0000000
    dc.l $000000c0,$c00000c0
    dc.l $000000c0,$c000c000
    dc.l $000000c0,$c000c0c0
    dc.l $000000c0,$c0c00000
    dc.l $000000c0,$c0c000c0
    dc.l $000000c0,$c0c0c000
    dc.l $000000c0,$c0c0c0c0
    dc.l $0000c000,$00000000
    dc.l $0000c000,$000000c0
    dc.l $0000c000,$0000c000
    dc.l $0000c000,$0000c0c0
    dc.l $0000c000,$00c00000
    dc.l $0000c000,$00c000c0
    dc.l $0000c000,$00c0c000
    dc.l $0000c000,$00c0c0c0
    dc.l $0000c000,$c0000000
    dc.l $0000c000,$c00000c0
    dc.l $0000c000,$c000c000
    dc.l $0000c000,$c000c0c0
    dc.l $0000c000,$c0c00000
    dc.l $0000c000,$c0c000c0
    dc.l $0000c000,$c0c0c000
    dc.l $0000c000,$c0c0c0c0
    dc.l $0000c0c0,$00000000
    dc.l $0000c0c0,$000000c0
    dc.l $0000c0c0,$0000c000
    dc.l $0000c0c0,$0000c0c0
    dc.l $0000c0c0,$00c00000
    dc.l $0000c0c0,$00c000c0
    dc.l $0000c0c0,$00c0c000
    dc.l $0000c0c0,$00c0c0c0
    dc.l $0000c0c0,$c0000000
    dc.l $0000c0c0,$c00000c0
    dc.l $0000c0c0,$c000c000
    dc.l $0000c0c0,$c000c0c0
    dc.l $0000c0c0,$c0c00000
    dc.l $0000c0c0,$c0c000c0
    dc.l $0000c0c0,$c0c0c000
    dc.l $0000c0c0,$c0c0c0c0
    dc.l $00c00000,$00000000
    dc.l $00c00000,$000000c0
    dc.l $00c00000,$0000c000
    dc.l $00c00000,$0000c0c0
    dc.l $00c00000,$00c00000
    dc.l $00c00000,$00c000c0
    dc.l $00c00000,$00c0c000
    dc.l $00c00000,$00c0c0c0
    dc.l $00c00000,$c0000000
    dc.l $00c00000,$c00000c0
    dc.l $00c00000,$c000c000
    dc.l $00c00000,$c000c0c0
    dc.l $00c00000,$c0c00000
    dc.l $00c00000,$c0c000c0
    dc.l $00c00000,$c0c0c000
    dc.l $00c00000,$c0c0c0c0
    dc.l $00c000c0,$00000000
    dc.l $00c000c0,$000000c0
    dc.l $00c000c0,$0000c000
    dc.l $00c000c0,$0000c0c0
    dc.l $00c000c0,$00c00000
    dc.l $00c000c0,$00c000c0
    dc.l $00c000c0,$00c0c000
    dc.l $00c000c0,$00c0c0c0
    dc.l $00c000c0,$c0000000
    dc.l $00c000c0,$c00000c0
    dc.l $00c000c0,$c000c000
    dc.l $00c000c0,$c000c0c0
    dc.l $00c000c0,$c0c00000
    dc.l $00c000c0,$c0c000c0
    dc.l $00c000c0,$c0c0c000
    dc.l $00c000c0,$c0c0c0c0
    dc.l $00c0c000,$00000000
    dc.l $00c0c000,$000000c0
    dc.l $00c0c000,$0000c000
    dc.l $00c0c000,$0000c0c0
    dc.l $00c0c000,$00c00000
    dc.l $00c0c000,$00c000c0
    dc.l $00c0c000,$00c0c000
    dc.l $00c0c000,$00c0c0c0
    dc.l $00c0c000,$c0000000
    dc.l $00c0c000,$c00000c0
    dc.l $00c0c000,$c000c000
    dc.l $00c0c000,$c000c0c0
    dc.l $00c0c000,$c0c00000
    dc.l $00c0c000,$c0c000c0
    dc.l $00c0c000,$c0c0c000
    dc.l $00c0c000,$c0c0c0c0
    dc.l $00c0c0c0,$00000000
    dc.l $00c0c0c0,$000000c0
    dc.l $00c0c0c0,$0000c000
    dc.l $00c0c0c0,$0000c0c0
    dc.l $00c0c0c0,$00c00000
    dc.l $00c0c0c0,$00c000c0
    dc.l $00c0c0c0,$00c0c000
    dc.l $00c0c0c0,$00c0c0c0
    dc.l $00c0c0c0,$c0000000
    dc.l $00c0c0c0,$c00000c0
    dc.l $00c0c0c0,$c000c000
    dc.l $00c0c0c0,$c000c0c0
    dc.l $00c0c0c0,$c0c00000
    dc.l $00c0c0c0,$c0c000c0
    dc.l $00c0c0c0,$c0c0c000
    dc.l $00c0c0c0,$c0c0c0c0
    dc.l $c0000000,$00000000
    dc.l $c0000000,$000000c0
    dc.l $c0000000,$0000c000
    dc.l $c0000000,$0000c0c0
    dc.l $c0000000,$00c00000
    dc.l $c0000000,$00c000c0
    dc.l $c0000000,$00c0c000
    dc.l $c0000000,$00c0c0c0
    dc.l $c0000000,$c0000000
    dc.l $c0000000,$c00000c0
    dc.l $c0000000,$c000c000
    dc.l $c0000000,$c000c0c0
    dc.l $c0000000,$c0c00000
    dc.l $c0000000,$c0c000c0
    dc.l $c0000000,$c0c0c000
    dc.l $c0000000,$c0c0c0c0
    dc.l $c00000c0,$00000000
    dc.l $c00000c0,$000000c0
    dc.l $c00000c0,$0000c000
    dc.l $c00000c0,$0000c0c0
    dc.l $c00000c0,$00c00000
    dc.l $c00000c0,$00c000c0
    dc.l $c00000c0,$00c0c000
    dc.l $c00000c0,$00c0c0c0
    dc.l $c00000c0,$c0000000
    dc.l $c00000c0,$c00000c0
    dc.l $c00000c0,$c000c000
    dc.l $c00000c0,$c000c0c0
    dc.l $c00000c0,$c0c00000
    dc.l $c00000c0,$c0c000c0
    dc.l $c00000c0,$c0c0c000
    dc.l $c00000c0,$c0c0c0c0
    dc.l $c000c000,$00000000
    dc.l $c000c000,$000000c0
    dc.l $c000c000,$0000c000
    dc.l $c000c000,$0000c0c0
    dc.l $c000c000,$00c00000
    dc.l $c000c000,$00c000c0
    dc.l $c000c000,$00c0c000
    dc.l $c000c000,$00c0c0c0
    dc.l $c000c000,$c0000000
    dc.l $c000c000,$c00000c0
    dc.l $c000c000,$c000c000
    dc.l $c000c000,$c000c0c0
    dc.l $c000c000,$c0c00000
    dc.l $c000c000,$c0c000c0
    dc.l $c000c000,$c0c0c000
    dc.l $c000c000,$c0c0c0c0
    dc.l $c000c0c0,$00000000
    dc.l $c000c0c0,$000000c0
    dc.l $c000c0c0,$0000c000
    dc.l $c000c0c0,$0000c0c0
    dc.l $c000c0c0,$00c00000
    dc.l $c000c0c0,$00c000c0
    dc.l $c000c0c0,$00c0c000
    dc.l $c000c0c0,$00c0c0c0
    dc.l $c000c0c0,$c0000000
    dc.l $c000c0c0,$c00000c0
    dc.l $c000c0c0,$c000c000
    dc.l $c000c0c0,$c000c0c0
    dc.l $c000c0c0,$c0c00000
    dc.l $c000c0c0,$c0c000c0
    dc.l $c000c0c0,$c0c0c000
    dc.l $c000c0c0,$c0c0c0c0
    dc.l $c0c00000,$00000000
    dc.l $c0c00000,$000000c0
    dc.l $c0c00000,$0000c000
    dc.l $c0c00000,$0000c0c0
    dc.l $c0c00000,$00c00000
    dc.l $c0c00000,$00c000c0
    dc.l $c0c00000,$00c0c000
    dc.l $c0c00000,$00c0c0c0
    dc.l $c0c00000,$c0000000
    dc.l $c0c00000,$c00000c0
    dc.l $c0c00000,$c000c000
    dc.l $c0c00000,$c000c0c0
    dc.l $c0c00000,$c0c00000
    dc.l $c0c00000,$c0c000c0
    dc.l $c0c00000,$c0c0c000
    dc.l $c0c00000,$c0c0c0c0
    dc.l $c0c000c0,$00000000
    dc.l $c0c000c0,$000000c0
    dc.l $c0c000c0,$0000c000
    dc.l $c0c000c0,$0000c0c0
    dc.l $c0c000c0,$00c00000
    dc.l $c0c000c0,$00c000c0
    dc.l $c0c000c0,$00c0c000
    dc.l $c0c000c0,$00c0c0c0
    dc.l $c0c000c0,$c0000000
    dc.l $c0c000c0,$c00000c0
    dc.l $c0c000c0,$c000c000
    dc.l $c0c000c0,$c000c0c0
    dc.l $c0c000c0,$c0c00000
    dc.l $c0c000c0,$c0c000c0
    dc.l $c0c000c0,$c0c0c000
    dc.l $c0c000c0,$c0c0c0c0
    dc.l $c0c0c000,$00000000
    dc.l $c0c0c000,$000000c0
    dc.l $c0c0c000,$0000c000
    dc.l $c0c0c000,$0000c0c0
    dc.l $c0c0c000,$00c00000
    dc.l $c0c0c000,$00c000c0
    dc.l $c0c0c000,$00c0c000
    dc.l $c0c0c000,$00c0c0c0
    dc.l $c0c0c000,$c0000000
    dc.l $c0c0c000,$c00000c0
    dc.l $c0c0c000,$c000c000
    dc.l $c0c0c000,$c000c0c0
    dc.l $c0c0c000,$c0c00000
    dc.l $c0c0c000,$c0c000c0
    dc.l $c0c0c000,$c0c0c000
    dc.l $c0c0c000,$c0c0c0c0
    dc.l $c0c0c0c0,$00000000
    dc.l $c0c0c0c0,$000000c0
    dc.l $c0c0c0c0,$0000c000
    dc.l $c0c0c0c0,$0000c0c0
    dc.l $c0c0c0c0,$00c00000
    dc.l $c0c0c0c0,$00c000c0
    dc.l $c0c0c0c0,$00c0c000
    dc.l $c0c0c0c0,$00c0c0c0
    dc.l $c0c0c0c0,$c0000000
    dc.l $c0c0c0c0,$c00000c0
    dc.l $c0c0c0c0,$c000c000
    dc.l $c0c0c0c0,$c000c0c0
    dc.l $c0c0c0c0,$c0c00000
    dc.l $c0c0c0c0,$c0c000c0
    dc.l $c0c0c0c0,$c0c0c000
    dc.l $c0c0c0c0,$c0c0c0c0
draw_uv_tri:
    rts
uv_ymin:  dc.w 0
uv_ymax:  dc.w 0
uv_tmp:   dc.w 0
uv_x0:    dc.w 0
uv_y0:    dc.w 0
uv_u0:    dc.w 0
uv_v0:    dc.w 0
uv_x1:    dc.w 0
uv_y1:    dc.w 0
uv_u1:    dc.w 0
uv_v1:    dc.w 0
uv_x2:    dc.w 0
uv_y2:    dc.w 0
uv_u2:    dc.w 0
uv_v2:    dc.w 0
    ifd FULL_RES
uv_edges: ds.b 256*12
    else
uv_edges: ds.b 128*12
    endif
c2p_exp256:
    dc.l $00000000,$01000000,$00010000,$01010000,$00000100,$01000100,$00010100,$01010100,$00000001,$01000001,$00010001,$01010001,$00000101,$01000101,$00010101,$01010101
    dc.l $02000000,$03000000,$02010000,$03010000,$02000100,$03000100,$02010100,$03010100,$02000001,$03000001,$02010001,$03010001,$02000101,$03000101,$02010101,$03010101
    dc.l $00020000,$01020000,$00030000,$01030000,$00020100,$01020100,$00030100,$01030100,$00020001,$01020001,$00030001,$01030001,$00020101,$01020101,$00030101,$01030101
    dc.l $02020000,$03020000,$02030000,$03030000,$02020100,$03020100,$02030100,$03030100,$02020001,$03020001,$02030001,$03030001,$02020101,$03020101,$02030101,$03030101
    dc.l $00000200,$01000200,$00010200,$01010200,$00000300,$01000300,$00010300,$01010300,$00000201,$01000201,$00010201,$01010201,$00000301,$01000301,$00010301,$01010301
    dc.l $02000200,$03000200,$02010200,$03010200,$02000300,$03000300,$02010300,$03010300,$02000201,$03000201,$02010201,$03010201,$02000301,$03000301,$02010301,$03010301
    dc.l $00020200,$01020200,$00030200,$01030200,$00020300,$01020300,$00030300,$01030300,$00020201,$01020201,$00030201,$01030201,$00020301,$01020301,$00030301,$01030301
    dc.l $02020200,$03020200,$02030200,$03030200,$02020300,$03020300,$02030300,$03030300,$02020201,$03020201,$02030201,$03030201,$02020301,$03020301,$02030301,$03030301
    dc.l $00000002,$01000002,$00010002,$01010002,$00000102,$01000102,$00010102,$01010102,$00000003,$01000003,$00010003,$01010003,$00000103,$01000103,$00010103,$01010103
    dc.l $02000002,$03000002,$02010002,$03010002,$02000102,$03000102,$02010102,$03010102,$02000003,$03000003,$02010003,$03010003,$02000103,$03000103,$02010103,$03010103
    dc.l $00020002,$01020002,$00030002,$01030002,$00020102,$01020102,$00030102,$01030102,$00020003,$01020003,$00030003,$01030003,$00020103,$01020103,$00030103,$01030103
    dc.l $02020002,$03020002,$02030002,$03030002,$02020102,$03020102,$02030102,$03030102,$02020003,$03020003,$02030003,$03030003,$02020103,$03020103,$02030103,$03030103
    dc.l $00000202,$01000202,$00010202,$01010202,$00000302,$01000302,$00010302,$01010302,$00000203,$01000203,$00010203,$01010203,$00000303,$01000303,$00010303,$01010303
    dc.l $02000202,$03000202,$02010202,$03010202,$02000302,$03000302,$02010302,$03010302,$02000203,$03000203,$02010203,$03010203,$02000303,$03000303,$02010303,$03010303
    dc.l $00020202,$01020202,$00030202,$01030202,$00020302,$01020302,$00030302,$01030302,$00020203,$01020203,$00030203,$01030203,$00020303,$01020303,$00030303,$01030303
    dc.l $02020202,$03020202,$02030202,$03030202,$02020302,$03020302,$02030302,$03030302,$02020203,$03020203,$02030203,$03030203,$02020303,$03020303,$02030303,$03030303
c2p_exp:
    dc.l $00000000,$01000000,$00010000,$01010000
    dc.l $00000100,$01000100,$00010100,$01010100
    dc.l $00000001,$01000001,$00010001,$01010001
    dc.l $00000101,$01000101,$00010101,$01010101
shade_lut:
    dc.b 1,1,1,2,2,2,3,3, 4,4,4,4,5,5,5,6
    dc.b 1,1,2,2,2,3,3,3, 4,4,5,5,5,6,6,6
    dc.b 1,2,2,3,3,3,10,11, 4,5,5,6,6,6,15,15
    dc.b 8,8,8,9,9,9,9,9, 4,5,5,6,6,15,15,15
    dc.b 2,3,3,10,10,11,11,11, 5,5,6,6,15,15,15,15
    dc.b 10,10,10,11,11,11,11,11, 5,6,6,15,15,15,15,15
    dc.b 4,4,5,5,6,6,15,15, 5,6,6,15,15,15,15,15
    dc.b 12,12,12,13,13,13,14,14, 6,6,15,15,15,15,15,15

