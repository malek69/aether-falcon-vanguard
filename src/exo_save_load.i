        section code,code
exo_save_game:
        movem.l d0-d7/a0-a6,-(sp)
        bsr.s   exo_open_dos
        beq.s   .sv_end
        move.l  #sav_path,d1
        move.l  #1006,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .sv_cls
        bsr.s   exo_pack_buf
        move.l  d4,d1
        move.l  #sav_buf,d2
        moveq   #64,d3
        jsr     -48(a6)
        move.l  d4,d1
        jsr     -36(a6)
.sv_cls:move.l  a6,a1
        move.l  4.w,a6
        jsr     -414(a6)
.sv_end:movem.l (sp)+,d0-d7/a0-a6
        rts
exo_load_game:
        movem.l d0-d7/a0-a6,-(sp)
        bsr.s   exo_open_dos
        beq.s   .ld_end
        move.l  #sav_path,d1
        move.l  #1005,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .ld_cls
        move.l  d4,d1
        move.l  #sav_buf,d2
        moveq   #64,d3
        jsr     -42(a6)
        move.l  d4,d1
        jsr     -36(a6)
        bsr.s   exo_unpack_buf
.ld_cls:move.l  a6,a1
        move.l  4.w,a6
        jsr     -414(a6)
.ld_end:movem.l (sp)+,d0-d7/a0-a6
        rts
exo_open_dos:
        move.l  4.w,a6
        lea     dos_name(pc),a1
        moveq   #0,d0
        jsr     -552(a6)
        move.l  d0,a6
        tst.l   d0
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
.up_no: rts
dos_name: dc.b "dos.library",0
sav_path: dc.b "data/colony.sav",0
        even
sav_buf:  ds.b 68
