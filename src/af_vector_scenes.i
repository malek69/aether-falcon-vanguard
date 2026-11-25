; ============================================================================
; AETHER FALCON: VANGUARD - Oryginalne dane wektorowe N-gon (100% autorskie IP)
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

af_vec_scene_intro:
        dc.w    0
        dc.w    0
        dc.w    6
        dc.w    160,40, 250,110, 210,130, 160,95, 110,130, 70,110
        dc.w    0
        dc.w    4
        dc.w    160,105, 195,145, 160,215, 125,145
        dc.w    -1

af_vec_scene_briefing:
        dc.w    0
        dc.w    0
        dc.w    5
        dc.w    50,180, 110,120, 190,135, 265,90, 285,195
        dc.w    0
        dc.w    4
        dc.w    140,70, 155,85, 140,100, 125,85
        dc.w    0
        dc.w    4
        dc.w    210,60, 225,75, 210,90, 195,75
        dc.w    -1

af_vec_scene_debriefing:
        dc.w    0
        dc.w    0
        dc.w    5
        dc.w    160,45, 190,135, 105,85, 215,85, 130,135
        dc.w    -1
