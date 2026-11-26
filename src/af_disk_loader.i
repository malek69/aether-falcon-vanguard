        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD v0.2.0 - Clean Disk Loader (dos.library)
; ============================================================================

        cnop    0,4
af_disk_load_all:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  4.w,a6
        lea     dos_name(pc),a1
        moveq   #0,d0
        jsr     -552(a6)                ; OpenLibrary("dos.library", 0)
        move.l  d0,af_dos_base
        beq.w   .dl_done

        lea     fn_hiscore(pc),a0
        lea     af_hiscore_buf,a1
        moveq   #4,d0
        bsr.w   af_read_file_to_buf
        cmp.l   #4,d0
        bne.s   .no_hi
        move.l  af_hiscore_buf,af_hiscore
.no_hi:
        lea     fn_scn_intro(pc),a0
        lea     af_scene_intro_buf,a1
        move.l  #16384,d0
        bsr.w   af_read_file_to_buf
        tst.l   d0
        ble.s   .no_si
        move.b  #1,af_has_scene_intro
.no_si:
        lea     fn_scn_vic(pc),a0
        lea     af_scene_vic_buf,a1
        move.l  #8192,d0
        bsr.w   af_read_file_to_buf
        tst.l   d0
        ble.s   .no_sv
        move.b  #1,af_has_scene_vic
.no_sv:
        lea     fn_scn_cri(pc),a0
        lea     af_scene_cri_buf,a1
        move.l  #8192,d0
        bsr.w   af_read_file_to_buf
        tst.l   d0
        ble.s   .no_sc
        move.b  #1,af_has_scene_cri
.no_sc:
        move.l  4.w,a6
        move.l  af_dos_base(pc),a1
        jsr     -414(a6)                ; CloseLibrary
        clr.l   af_dos_base
.dl_done:
        movem.l (sp)+,d0-d7/a0-a6
        rts

af_disk_save_hiscore:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  4.w,a6
        lea     dos_name(pc),a1
        moveq   #0,d0
        jsr     -552(a6)
        move.l  d0,af_dos_base
        beq.s   .sv_done
        move.l  af_hiscore,af_hiscore_buf
        move.l  af_dos_base(pc),a6
        lea     fn_hiscore(pc),a0
        move.l  a0,d1
        move.l  #1006,d2                ; MODE_NEWFILE
        jsr     -30(a6)                 ; Open
        move.l  d0,d4
        beq.s   .sv_cls
        move.l  d4,d1
        lea     af_hiscore_buf,a0
        move.l  a0,d2
        moveq   #4,d3
        jsr     -48(a6)                 ; Write
        move.l  d4,d1
        jsr     -36(a6)                 ; Close
.sv_cls:move.l  4.w,a6
        move.l  af_dos_base(pc),a1
        jsr     -414(a6)
        clr.l   af_dos_base
.sv_done:
        movem.l (sp)+,d0-d7/a0-a6
        rts

af_read_file_to_buf:
        movem.l d2-d5/a2/a6,-(sp)
        move.l  a1,a2
        move.l  d0,d3
        move.l  af_dos_base(pc),a6
        move.l  a0,d1
        move.l  #1005,d2                ; MODE_OLDFILE
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .rf_fail
        move.l  d4,d1
        move.l  a2,d2
        jsr     -42(a6)                 ; Read
        move.l  d0,d5
        move.l  d4,d1
        jsr     -36(a6)                 ; Close
        move.l  d5,d0
        bra.s   .rf_end
.rf_fail:
        moveq   #-1,d0
.rf_end:movem.l (sp)+,d2-d5/a2/a6
        rts

af_dos_base:        dc.l    0
dos_name:           dc.b    "dos.library",0
fn_hiscore:         dc.b    "data/hiscore.dat",0
fn_scn_intro:       dc.b    "data/scene_intro.bin",0
fn_scn_vic:         dc.b    "data/scene_victory.bin",0
fn_scn_cri:         dc.b    "data/scene_crisis.bin",0
af_has_scene_intro: dc.b    0
af_has_scene_vic:   dc.b    0
af_has_scene_cri:   dc.b    0
        even
af_hiscore_buf:     dc.l    0

        section fastram_bss,bss
        even
af_scene_intro_buf: ds.b    16384
af_scene_vic_buf:   ds.b    8192
af_scene_cri_buf:   ds.b    8192
