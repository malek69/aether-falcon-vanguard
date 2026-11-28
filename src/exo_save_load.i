        section code,code
exo_save_game:
        movem.l d0-d7/a0-a6,-(sp)
        bsr.w   exo_open_dos
        beq.s   .sv_end
        move.l  #sav_path,d1
        move.l  #1006,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .sv_cls
        bsr.w   exo_pack_buf
        move.l  d4,d1
        move.l  #sav_buf,d2
        moveq   #76,d3
        jsr     -48(a6)
        move.l  d4,d1
        jsr     -36(a6)
.sv_cls:bsr.w   exo_close_dos
.sv_end:movem.l (sp)+,d0-d7/a0-a6
        rts
exo_load_game:
        movem.l d0-d7/a0-a6,-(sp)
        bsr.w   exo_open_dos
        beq.s   .ld_end
        move.l  #sav_path,d1
        move.l  #1005,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .ld_cls
        move.l  d4,d1
        move.l  #sav_buf,d2
        moveq   #76,d3
        jsr     -42(a6)
        move.l  d4,d1
        jsr     -36(a6)
        bsr.w   exo_unpack_buf
.ld_cls:bsr.w   exo_close_dos
.ld_end:movem.l (sp)+,d0-d7/a0-a6
        rts
exo_open_dos:
        move.l  4.w,a6
        jsr     -138(a6)                ; Permit() na czas operacji dyskowej dos.library
        move.w  #$c038,$dff09a          ; Wlacz INTEN + PORTS + EXTER + VERTB dla handlera dysku
        lea     dos_name(pc),a1
        moveq   #0,d0
        jsr     -552(a6)
        move.l  d0,a6
        tst.l   d0
        rts

exo_close_dos:
        move.l  a6,a1
        move.l  4.w,a6
        jsr     -414(a6)
        move.w  #$3fdf,$dff09a          ; Wylacz przerwania systemowe poza VERTB ($0020)
        move.w  #$8020,$dff09a
        jsr     -132(a6)                ; Forbid()
        rts
exo_pack_buf:
        lea     sav_buf,a0
        move.l  #"EXOS",(a0)+
        move.b  player_role,(a0)+
        clr.b   (a0)+
        move.w  terraform_pct,(a0)+
        move.l  cam_x,(a0)+
        move.l  cam_y,(a0)+
        move.w  cam_yaw,(a0)+
        lea     exo_bases,a1
        moveq   #11,d0
.pk_l:  move.l  (a1)+,(a0)+
        dbf     d0,.pk_l
        move.l  colony_credits,(a0)+
        move.w  role_contracts_done,(a0)+
        move.w  story_step_off,(a0)+
        rts
exo_unpack_buf:
        lea     sav_buf,a0
        cmp.l   #"EXOS",(a0)+
        bne.s   .up_no
        move.b  (a0)+,player_role
        addq.l  #1,a0
        move.w  (a0)+,terraform_pct
        move.l  (a0)+,cam_x
        move.l  (a0)+,cam_y
        move.w  (a0)+,cam_yaw
        lea     exo_bases,a1
        moveq   #11,d0
.up_l:  move.l  (a0)+,(a1)+
        dbf     d0,.up_l
        move.l  (a0)+,colony_credits
        move.w  (a0)+,role_contracts_done
        move.w  (a0)+,story_step_off
.up_no: rts
dos_name: dc.b "dos.library",0
sav_path: dc.b "data/colony.sav",0
        even
sav_buf:  ds.b 76
colony_credits:      dc.l 0
role_contracts_done: dc.w 0
story_step_off:      dc.w 0

; Doczytuje z dysku fabule (data/story_pX_pl.bin / _en.bin) oraz muzyke (data/mod_pX.mod) wybranej profesji
exo_load_role_assets:
        movem.l d0-d7/a0-a6,-(sp)
        move.b  player_role(pc),d5
        cmp.b   #2,d5
        bne.s   .rl_c3
        move.b  #"2",mod_role_path+10
        move.b  #"2",story_role_path+12
        bra.s   .rl_go
.rl_c3: cmp.b   #3,d5
        bne.s   .rl_c1
        move.b  #"3",mod_role_path+10
        move.b  #"3",story_role_path+12
        bra.s   .rl_go
.rl_c1: move.b  #"1",mod_role_path+10
        move.b  #"1",story_role_path+12
.rl_go: bsr.w   exo_open_dos
        beq.w   .rl_end

        ; 1. Wczytaj fabule profesji z dysku do story_buf (Fast RAM)
        move.l  #story_role_path,d1
        move.l  #1005,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .ld_md
        move.l  d4,d1
        move.l  #story_buf,d2
        move.l  #2048,d3
        jsr     -42(a6)
        move.l  d4,d1
        jsr     -36(a6)
        bsr.w   exo_apply_story_step

        ; 2. Wczytaj modul .MOD profesji z dysku do mod_data (Chip RAM) i przelacz muzyke!
.ld_md: move.w  #30000,pt_speed
        move.w  #$000f,$dff096
        move.l  #mod_role_path,d1
        move.l  #1005,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .rl_cls
        move.l  d4,d1
        move.l  #mod_data,d2
        move.l  #15000,d3
        jsr     -42(a6)
        move.l  d4,d1
        jsr     -36(a6)
        move.w  #$000f,$dff096
        jsr     pt_init

.rl_cls:bsr.w   exo_close_dos
        jsr     exo_play_sfx_dock
.rl_end:movem.l (sp)+,d0-d7/a0-a6
        rts


; Ustawia cine_line1..3_ptr na podstawie story_step_off i otwiera okno lacznosci
exo_apply_story_step:
        lea     story_buf,a0
        move.w  story_step_off(pc),d1
        and.w   #$003c,d1
        cmp.w   #48,d1
        blt.s   .st_ok
        moveq   #0,d1
        move.w  d1,story_step_off
.st_ok: move.l  (a0,d1.w),d0
        beq.s   .st_end
        add.l   #story_buf,d0
        move.l  d0,cine_line1_ptr
        move.l  4(a0,d1.w),d0
        add.l   #story_buf,d0
        move.l  d0,cine_line2_ptr
        move.l  8(a0,d1.w),d0
        add.l   #story_buf,d0
        move.l  d0,cine_line3_ptr
        move.b  #1,cine_active
        move.w  #1,cine_type_chars
.st_end:rts

exo_advance_role_story:
        add.w   #12,story_step_off
        cmp.w   #48,story_step_off
        blt.s   .ad_go
        clr.w   story_step_off
.ad_go: bsr.s   exo_apply_story_step
        rts

mod_role_path:   dc.b "data/mod_p1.mod",0
        IFD LANG_PL
story_role_path: dc.b "data/story_p1_pl.bin",0
        ELSE
story_role_path: dc.b "data/story_p1_en.bin",0
        ENDC
        even
        section fastram_bss,bss
        even
story_buf:       ds.b 2048
        section code,code
