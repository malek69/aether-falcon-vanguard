; ============================================================================
; AETHER FALCON: VANGUARD - Sceny wektorowe N-gon (wypukle bryly bez artefaktow)
; ============================================================================

        cnop    0,4
af_play_vector_frame:
        movem.l d0-d5/a0-a2,-(sp)
        moveq   #0,d0
        move.w  cur_frame,d0
        lea     af_vec_frame_table,a0
        move.l  (a0,d0.l*4),a0
        addq.l  #2,a0
.poly_loop:
        move.w  (a0)+,d0
        bmi.s   .frame_done
        move.l  a0,a1
        jsr     draw_polygon_mode
        moveq   #0,d1
        move.w  (a0)+,d1
        lsl.l   #2,d1
        add.l   d1,a0
        bra.s   .poly_loop
.frame_done:
        movem.l (sp)+,d0-d5/a0-a2
        rts

        section vector_data,data
        even

af_vec_frame_count:
        dc.w    3

af_vec_frame_table:
        dc.l    af_vec_scene_intro
        dc.l    af_vec_scene_briefing
        dc.l    af_vec_scene_debriefing

; KLATKA 0: INTRO - Emblem Skrzydla Solis (3 wypukle wielokaty)
af_vec_scene_intro:
        dc.w    0
        dc.w    0                       ; Lewe skrzydlo
        dc.w    4
        dc.w    154,50, 154,105, 68,125, 96,75
        dc.w    0
        dc.w    0                       ; Prawe skrzydlo
        dc.w    4
        dc.w    166,50, 224,75, 252,125, 166,105
        dc.w    0
        dc.w    2                       ; Centralny grot (bitplan 2 - inny kolor)
        dc.w    4
        dc.w    160,36, 184,115, 160,185, 136,115
        dc.w    -1

; KLATKA 1: BRIEFING - Mapa sektora i 2 cele taktyczne
af_vec_scene_briefing:
        dc.w    0
        dc.w    0                       ; Wyspa / Kanion (wypukly pieciokat)
        dc.w    5
        dc.w    64,155, 115,105, 215,105, 260,155, 160,182
        dc.w    0
        dc.w    2                       ; Cel taktyczny Alfa
        dc.w    4
        dc.w    120,58, 138,76, 120,94, 102,76
        dc.w    0
        dc.w    2                       ; Cel taktyczny Beta
        dc.w    4
        dc.w    204,52, 222,70, 204,88, 186,70
        dc.w    -1

; KLATKA 2: DEBRIEFING - Odznaka Awansu Pilota
af_vec_scene_debriefing:
        dc.w    0
        dc.w    2
        dc.w    4
        dc.w    160,38, 204,110, 160,182, 116,110
        dc.w    0
        dc.w    0
        dc.w    4
        dc.w    160,68, 186,110, 160,152, 134,110
        dc.w    -1
