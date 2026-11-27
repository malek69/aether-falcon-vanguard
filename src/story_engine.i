        section code,code

story_load_from_hdd:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  4.w,a6
        lea     story_dos_name(pc),a1
        moveq   #0,d0
        jsr     -552(a6)
        move.l  d0,a6
        tst.l   d0
        beq.s   .sl_end
        move.l  #story_file_path,d1
        move.l  #1005,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .sl_cls
        move.l  d4,d1
        move.l  #story_buf,d2
        move.l  #8192,d3
        jsr     -42(a6)
        move.l  d4,d1
        jsr     -36(a6)
.sl_cls:move.l  a6,a1
        move.l  4.w,a6
        jsr     -414(a6)
.sl_end:
        bsr.w   story_sync_dynamic_state
        movem.l (sp)+,d0-d7/a0-a6
        rts

story_get_str:
        movem.l d0-d1/a1,-(sp)
        lea     story_buf,a1
        cmp.l   #"AFST",(a1)
        bne.s   .sg_fb
        cmp.w   4(a1),d0
        bge.s   .sg_fb
        add.w   d0,d0
        move.w  8(a1,d0.w),d1
        lea     (a1,d1.w),a0
        movem.l (sp)+,d0-d1/a1
        rts
.sg_fb: lea     story_fallback_str(pc),a0
        movem.l (sp)+,d0-d1/a1
        rts

story_sync_dynamic_state:
        movem.l d0-d5/a0,-(sp)
        lea     exo_bases(pc),a0
        moveq   #0,d0
        moveq   #0,d1
        move.w  #32767,d4
        moveq   #0,d5
.sb_lp: tst.b   4(a0)
        beq.s   .sb_dst
        addq.w  #1,d0
.sb_dst:move.w  (a0),d2
        move.b  cam_x+2(pc),d3
        ext.w   d3
        sub.w   d3,d2
        bpl.s   .dx_p
        neg.w   d2
.dx_p:  move.w  2(a0),d3
        sub.b   cam_y+2(pc),d3
        ext.w   d3
        bpl.s   .dy_p
        neg.w   d3
.dy_p:  add.w   d3,d2
        cmp.w   d4,d2
        bge.s   .sb_nx
        move.w  d2,d4
        move.w  d1,d5
.sb_nx: addq.l  #6,a0
        addq.w  #1,d1
        cmp.w   #8,d1
        blt.s   .sb_lp

        move.w  d0,domes_online_cnt
        move.w  d5,nearest_sector_id

        moveq   #1,d1
        cmp.w   #3,d0
        blt.s   .act_ok
        moveq   #2,d1
        cmp.w   #6,d0
        blt.s   .act_ok
        moveq   #3,d1
.act_ok:move.w  d1,story_act_num
        tst.b   intro_turn_done
        beq.s   .no_msw
        move.w  d1,d0
        jsr     audio_switch_track
.no_msw:

        tst.b   story_intro_shown
        bne.s   .sd_dn
        move.b  #1,story_intro_shown
        moveq   #3,d0
        bsr.w   story_get_str
        move.l  a0,cine_line1_ptr
        moveq   #4,d0
        bsr.w   story_get_str
        move.l  a0,cine_line2_ptr
        moveq   #6,d0
        bsr.w   story_get_str
        move.l  a0,cine_line3_ptr
.sd_dn: movem.l (sp)+,d0-d5/a0
        rts

story_update_logbook:
        lea     kbd_matrix,a0
        tst.b   $42(a0)
        bne.s   .tgl_lb
        tst.b   $26(a0)
        bne.s   .tgl_lb
        tst.b   $28(a0)
        beq.s   .chk_lb
.tgl_lb:clr.b   $42(a0)
        clr.b   $26(a0)
        clr.b   $28(a0)
        move.b  #$ff,kbd_held_raw
        eor.b   #1,logbook_open
        bsr.w   story_sync_dynamic_state
.chk_lb:tst.b   logbook_open
        beq.w   .lb_end
        movem.l d0-d7/a0-a5,-(sp)
        lea     chunky_buf+42*320+24,a0
        move.w  #154,d7
.ly:    move.w  #271,d6
.lx:    move.b  #128,(a0,d6.w)
        dbf     d6,.lx
        adda.w  #320,a0
        dbf     d7,.ly
        lea     chunky_buf+42*320+24,a0
        move.w  #271,d6
.lbd:   move.b  #156,(a0,d6.w)
        move.b  #156,154*320(a0,d6.w)
        dbf     d6,.lbd

        moveq   #11,d0
        add.w   story_act_num(pc),d0
        bsr.w   story_get_str
        move.l  a0,a2
        lea     chunky_buf+50*320+34,a3
        bsr.w   exo_print_str_pl

        moveq   #14,d0
        add.w   story_act_num(pc),d0
        bsr.w   story_get_str
        move.l  a0,a2
        lea     chunky_buf+66*320+34,a3
        bsr.w   exo_print_str_pl

        moveq   #32,d0
        add.w   nearest_sector_id(pc),d0
        bsr.w   story_get_str
        move.l  a0,a2
        lea     chunky_buf+82*320+34,a3
        bsr.w   exo_print_str_pl

        moveq   #40,d0
        add.b   contract_type(pc),d0
        bsr.w   story_get_str
        move.l  a0,a2
        lea     chunky_buf+98*320+34,a3
        bsr.w   exo_print_str_pl
        moveq   #32,d0
        add.w   contract_target_idx(pc),d0
        bsr.w   story_get_str
        move.l  a0,a2
        lea     chunky_buf+112*320+34,a3
        bsr.w   exo_print_str_pl
        move.w  logs_unlocked_cnt(pc),d0
        beq.s   .no_lg
        subq.w  #1,d0
        and.w   #7,d0
        add.w   #48,d0
        bsr.w   story_get_str
        move.l  a0,a2
        lea     chunky_buf+196*320+34,a3
        bsr.w   exo_print_str_pl
.no_lg: jsr     open_world_draw_topo_map

        movem.l (sp)+,d0-d7/a0-a5
.lb_end:rts

exo_print_str_pl:
        movem.l d0/d3-d4/a4-a5,-(sp)
.ps_lp: moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .ps_dn
        sub.w   #32,d0
        blt.s   .ps_sp
        cmp.w   #72,d0
        bgt.s   .ps_sp
        lsl.w   #3,d0
        lea     exo_font_5x7,a4
        add.l   d0,a4
        move.l  a3,a5
        moveq   #6,d3
.py:    move.b  (a4)+,d4
        btst    #4,d4
        beq.s   .b4
        move.b  #255,(a5)
.b4:    btst    #3,d4
        beq.s   .b3
        move.b  #255,1(a5)
.b3:    btst    #2,d4
        beq.s   .b2
        move.b  #255,2(a5)
.b2:    btst    #1,d4
        beq.s   .b1
        move.b  #255,3(a5)
.b1:    btst    #0,d4
        beq.s   .nx
        move.b  #255,4(a5)
.nx:    adda.w  #320,a5
        dbf     d3,.py
.ps_sp: addq.l  #6,a3
        bra.s   .ps_lp
.ps_dn: movem.l (sp)+,d0/d3-d4/a4-a5
        rts

exo_font_5x7:
        dc.b $00,$00,$00,$00,$00,$00,$00,0, $04,$04,$04,$04,$00,$00,$04,0
        dc.b $0a,$0a,$00,$00,$00,$00,$00,0, $0a,$1f,$0a,$0a,$1f,$0a,$00,0
        dc.b $04,$0f,$14,$0e,$05,$1e,$04,0, $19,$19,$02,$04,$08,$13,$13,0
        dc.b $0c,$12,$14,$08,$15,$12,$0d,0, $04,$04,$00,$00,$00,$00,$00,0
        dc.b $02,$04,$08,$08,$08,$04,$02,0, $08,$04,$02,$02,$02,$04,$08,0
        dc.b $00,$04,$15,$0e,$15,$04,$00,0, $00,$04,$04,$1f,$04,$04,$00,0
        dc.b $00,$00,$00,$00,$04,$04,$08,0, $00,$00,$00,$1f,$00,$00,$00,0
        dc.b $00,$00,$00,$00,$00,$0c,$0c,0, $01,$01,$02,$04,$08,$10,$10,0
        dc.b $0e,$11,$13,$15,$19,$11,$0e,0, $04,$0c,$04,$04,$04,$04,$0e,0
        dc.b $0e,$11,$01,$02,$04,$08,$1f,0, $1f,$02,$04,$02,$01,$11,$0e,0
        dc.b $02,$06,$0a,$12,$1f,$02,$02,0, $1f,$10,$1e,$01,$01,$11,$0e,0
        dc.b $06,$08,$10,$1e,$11,$11,$0e,0, $1f,$01,$02,$04,$08,$08,$08,0
        dc.b $0e,$11,$11,$0e,$11,$11,$0e,0, $0e,$11,$11,$0f,$01,$02,$0c,0
        dc.b $00,$0c,$0c,$00,$0c,$0c,$00,0, $00,$04,$04,$00,$04,$04,$08,0
        dc.b $02,$04,$08,$10,$08,$04,$02,0, $00,$00,$1f,$00,$1f,$00,$00,0
        dc.b $08,$04,$02,$01,$02,$04,$08,0, $0e,$11,$01,$02,$04,$00,$04,0
        dc.b $0e,$11,$17,$15,$17,$10,$0e,0, $0e,$11,$11,$1f,$11,$11,$11,0
        dc.b $1e,$11,$11,$1e,$11,$11,$1e,0, $0e,$11,$10,$10,$10,$11,$0e,0
        dc.b $1c,$12,$11,$11,$11,$12,$1c,0, $1f,$10,$10,$1e,$10,$10,$1f,0
        dc.b $1f,$10,$10,$1e,$10,$10,$10,0, $0e,$11,$10,$17,$11,$11,$0f,0
        dc.b $11,$11,$11,$1f,$11,$11,$11,0, $0e,$04,$04,$04,$04,$04,$0e,0
        dc.b $07,$02,$02,$02,$02,$12,$0c,0, $11,$12,$14,$18,$14,$12,$11,0
        dc.b $10,$10,$10,$10,$10,$10,$1f,0, $11,$1b,$15,$15,$11,$11,$11,0
        dc.b $11,$19,$15,$13,$11,$11,$11,0, $0e,$11,$11,$11,$11,$11,$0e,0
        dc.b $1e,$11,$11,$1e,$10,$10,$10,0, $0e,$11,$11,$11,$15,$12,$0d,0
        dc.b $1e,$11,$11,$1e,$14,$12,$11,0, $0f,$10,$10,$0e,$01,$01,$1e,0
        dc.b $1f,$04,$04,$04,$04,$04,$04,0, $11,$11,$11,$11,$11,$11,$0e,0
        dc.b $11,$11,$11,$11,$11,$0a,$04,0, $11,$11,$11,$15,$15,$1b,$11,0
        dc.b $11,$11,$0a,$04,$0a,$11,$11,0, $11,$11,$0a,$04,$04,$04,$04,0
        dc.b $1f,$01,$02,$04,$08,$10,$1f,0, $0e,$08,$08,$08,$08,$08,$0e,0
        dc.b $10,$10,$08,$04,$02,$01,$01,0, $0e,$02,$02,$02,$02,$02,$0e,0
        dc.b $04,$0a,$11,$00,$00,$00,$00,0, $00,$00,$00,$00,$00,$00,$1f,0
        ; 96..104: PL glyphs
        dc.b $0e,$11,$11,$1f,$11,$13,$02,0
        dc.b $02,$0e,$11,$10,$10,$11,$0e,0
        dc.b $1f,$10,$10,$1e,$10,$1f,$02,0
        dc.b $10,$10,$14,$18,$10,$10,$1f,0
        dc.b $02,$15,$19,$15,$13,$11,$11,0
        dc.b $02,$0e,$11,$11,$11,$11,$0e,0
        dc.b $02,$0f,$10,$0e,$01,$01,$1e,0
        dc.b $02,$1f,$01,$02,$04,$08,$1f,0
        dc.b $04,$1f,$01,$02,$04,$08,$1f,0

story_dos_name:     dc.b "dos.library",0
story_file_path:    dc.b "data/story.bin",0
story_fallback_str: dc.b "AETHER-IV SIGNAL...",0
        even
story_act_num:      dc.w 1
domes_online_cnt:   dc.w 0
nearest_sector_id:  dc.w 0
story_intro_shown:  dc.b 0
logbook_open:       dc.b 0

        section fastram_bss,bss
        even
story_buf:          ds.b 8192
        section code,code
