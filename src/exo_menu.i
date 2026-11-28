        section code,code
exo_run_prologue:
        movem.l d0-d7/a0-a6,-(sp)
        move.w  #64,cam_yaw
        move.w  #64,user_yaw
        move.w  #26,cine_bar_h
        move.w  #320,d7
.pr_lp: jsr     wait_vbl
        jsr     input_update_controls
        jsr     thea1200_read_peripherals
        sub.l   #160,cam_y
        jsr     render_voxel_3d
        jsr     cine_draw_letterbox

        ; Ciemny panel napisow Prologu na srodku ekranu (Y=78..166)
        lea     chunky_buf+78*320+32,a0
        moveq   #87,d6
.pb_y:  move.w  #255,d5
.pb_x:  move.b  #128,(a0,d5.w)
        dbf     d5,.pb_x
        adda.w  #320,a0
        dbf     d6,.pb_y

        lea     pro_l1(pc),a2
        lea     chunky_buf+88*320+44,a3
        bsr.w   .p_str
        lea     pro_l2(pc),a2
        lea     chunky_buf+108*320+44,a3
        bsr.w   .p_str
        lea     pro_l3(pc),a2
        lea     chunky_buf+128*320+44,a3
        bsr.w   .p_str
        lea     pro_l4(pc),a2
        lea     chunky_buf+152*320+76,a3
        bsr.w   .p_str

        clr.w   bbox_x1
        move.w  #319,bbox_x2
        clr.w   bbox_y1
        move.w  #255,bbox_y2
        jsr     c2p_160x128_to_aga

        ; Ignoruj pierwsze 30 klatek (0.6s), zeby resztki klawiszy ze startu nie pominely intra
        cmp.w   #290,d7
        bgt.s   .pr_nx
        cmp.w   #290,d7
        bne.s   .pr_chk
        move.b  #$ff,kbd_last_press
        clr.b   mouse_lmb_click
.pr_chk:move.b  kbd_last_press(pc),d0
        cmp.b   #$40,d0                 ; Spacja
        beq.s   .pr_dn
        cmp.b   #$44,d0                 ; Enter
        beq.s   .pr_dn
        cmp.b   #$45,d0                 ; ESC
        beq.s   .pr_dn
        tst.b   mouse_lmb_click
        bne.s   .pr_dn
.pr_nx: dbf     d7,.pr_lp
.pr_dn: move.b  #$ff,kbd_last_press
        clr.b   mouse_lmb_click
        movem.l (sp)+,d0-d7/a0-a6
        rts
.p_str: moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .p_end
        cmp.b   #10,d0
        bge.s   .p_asc
        subq.w  #1,d0
        lsl.w   #3,d0
        lea     pl_glyphs_5x7(pc),a4
        add.l   d0,a4
        bra.s   .p_gl
.p_asc: sub.w   #32,d0
        lsl.w   #3,d0
        lea     hud_ascii_5x7,a4
        add.l   d0,a4
.p_gl:  move.l  a3,a5
        moveq   #6,d3
.p_ylp: move.b  (a4)+,d4
        btst    #4,d4
        beq.s   .pb3
        move.b  #255,(a5)
.pb3:   btst    #3,d4
        beq.s   .pb2
        move.b  #255,1(a5)
.pb2:   btst    #2,d4
        beq.s   .pb1
        move.b  #255,2(a5)
.pb1:   btst    #1,d4
        beq.s   .pb0
        move.b  #255,3(a5)
.pb0:   btst    #0,d4
        beq.s   .pnx
        move.b  #255,4(a5)
.pnx:   adda.w  #320,a5
        dbf     d3,.p_ylp
        addq.l  #6,a3
        bra.s   .p_str
.p_end: rts
        IFD LANG_PL
pro_l1: dc.b "ROK 2384. ORBITA PLANETY AETHER-IV.",0
pro_l2: dc.b "KOLONIA STRACI",4,"A ",4,"ACZNO",7,2," Z FLOT",1,".",0
pro_l3: dc.b "WYBIERZ PROFESJ",3," I ODBUDUJ SIE",2,".",0
pro_l4: dc.b "[SPACJA / MYSZ = DALEJ]",0
        ELSE
pro_l1: dc.b "YEAR 2384. ORBIT OF PLANET AETHER-IV.",0
pro_l2: dc.b "THE COLONY LOST CONTACT WITH THE FLEET.",0
pro_l3: dc.b "CHOOSE YOUR CLASS AND RESTORE THE GRID.",0
pro_l4: dc.b "[SPACE / MOUSE = CONTINUE]",0
        ENDC
        even

exo_run_title_menu:
        movem.l d0-d7/a0-a6,-(sp)
        clr.w   aga_fade_lvl
        move.w  #64,cam_yaw
        move.w  #64,user_yaw
        move.b  #$ff,kbd_last_press
        clr.b   seed_edit_mode
        move.b  #120,mouse_active
        move.b  #1,in_title_menu
.tm_lp: jsr     wait_vbl
        jsr     input_update_controls
        jsr     thea1200_read_peripherals
        sub.l   #128,cam_y
        clr.w   ship_bank
        jsr     render_voxel_3d
        jsr     exo_draw_ship_and_hud
        ; Podglad na zywo w menu: najechanie myszka nad portret 1/2/3 podmienia statek 3D!
        move.w  mouse_y(pc),d1
        cmp.w   #48,d1
        blt.s   .hv_dn
        cmp.w   #126,d1
        bgt.s   .hv_dn
        move.w  mouse_x(pc),d0
        cmp.w   #120,d0
        bge.s   .hv2
        move.b  #1,player_role
        bra.s   .hv_dn
.hv2:   cmp.w   #200,d0
        bge.s   .hv3
        move.b  #2,player_role
        bra.s   .hv_dn
.hv3:   move.b  #3,player_role
.hv_dn:
        bsr.w   exo_draw_menu_bars
        cmp.w   #22,cine_bar_h
        bge.s   .lb_ok
        addq.w  #1,cine_bar_h
.lb_ok: jsr     cine_draw_letterbox
        move.b  #120,mouse_active
        jsr     thea1200_draw_mouse_cursor
        clr.w   bbox_x1
        move.w  #319,bbox_x2
        clr.w   bbox_y1
        move.w  #255,bbox_y2
        jsr     c2p_160x128_to_aga

        move.b  kbd_last_press(pc),d0
        cmp.b   #$ff,d0
        beq.w   .chk_ms
        move.b  #$ff,kbd_last_press

        tst.b   seed_edit_mode
        bne.w   .in_seed

        cmp.b   #$01,d0                 ; 1 = Pionier
        bne.s   .c2
        move.b  #1,player_role
        bra.w   .tm_ok
.c2:    cmp.b   #$02,d0                 ; 2 = Straznik
        bne.s   .c3
        move.b  #2,player_role
        bra.w   .tm_ok
.c3:    cmp.b   #$03,d0                 ; 3 = Inzynier
        bne.s   .c4
        move.b  #3,player_role
        bra.w   .tm_ok
.c4:    cmp.b   #$04,d0                 ; 4 = Wczytaj zapis
        bne.s   .c_s
        jsr     exo_load_game
        bra.w   .tm_ok
.c_s:   cmp.b   #$21,d0                 ; S = Wpisz wlasne ziarno SEED
        bne.s   .c_r
        move.b  #1,seed_edit_mode
        clr.w   seed_digits_cnt
        clr.l   world_seed_val
        bra.w   .tm_lp
.c_r:   cmp.b   #$13,d0                 ; R = Losuj nowe ziarno SEED i przebuduj swiat
        bne.s   .c_sp
        move.l  vbl_tick(pc),d1
        mulu.w  #31337,d1
        add.l   #12345,d1
        and.l   #$000fffff,d1
        move.l  d1,world_seed_val
        bsr.w   exo_generate_world_from_seed
        bra.w   .tm_lp
.c_sp:  cmp.b   #$40,d0                 ; Spacja = Start kampanii
        beq.w   .tm_ok
        bra.w   .chk_ms

.in_seed:
        cmp.b   #$44,d0                 ; Enter = Zatwierdz SEED i wygeneruj planete!
        beq.s   .sd_done
        cmp.b   #$41,d0                 ; Backspace
        bne.s   .sd_dig
        move.l  world_seed_val(pc),d1
        moveq   #0,d3
        divu.l  #10,d3:d1
        move.l  d1,world_seed_val
        tst.w   seed_digits_cnt
        beq.w   .tm_lp
        subq.w  #1,seed_digits_cnt
        bra.w   .tm_lp
.sd_dig:
        ; Klawisze 1..9 ($01..$09) oraz 0 ($0A)
        cmp.b   #$01,d0
        blt.w   .tm_lp
        cmp.b   #$0a,d0
        bgt.w   .tm_lp
        cmp.w   #6,seed_digits_cnt
        bge.w   .tm_lp
        cmp.b   #$0a,d0
        bne.s   .dg_nz
        moveq   #0,d0
.dg_nz: move.l  world_seed_val(pc),d1
        mulu.w  #10,d1
        and.l   #$ffff,d0
        add.l   d0,d1
        move.l  d1,world_seed_val
        addq.w  #1,seed_digits_cnt
        bra.w   .tm_lp
.sd_done:
        clr.b   seed_edit_mode
        bsr.w   exo_generate_world_from_seed
        bra.w   .tm_lp

.chk_ms:
        tst.b   mouse_lmb_click
        beq.w   .tm_lp
        clr.b   mouse_lmb_click
        move.w  mouse_y(pc),d1
        cmp.w   #44,d1
        blt.w   .tm_lp
        cmp.w   #131,d1
        bgt.s   .m_ld
        move.w  mouse_x(pc),d0
        cmp.w   #120,d0
        bge.s   .mr2
        move.b  #1,player_role
        bra.s   .tm_ok
.mr2:   cmp.w   #200,d0
        bge.s   .mr3
        move.b  #2,player_role
        bra.s   .tm_ok
.mr3:   move.b  #3,player_role
        bra.s   .tm_ok
.m_ld:  cmp.w   #154,d1
        bgt.w   .tm_lp
        jsr     exo_load_game
.tm_ok: clr.b   in_title_menu
        clr.b   kbd_matrix+$45
        jsr     exo_load_role_assets
        clr.b   fire_held
        clr.w   ship_bank
        move.w  #96,user_yaw
        move.w  #96,cam_yaw
        move.b  #1,intro_turn_done
        movem.l (sp)+,d0-d7/a0-a6
        rts

; Generator otwartego swiata na MC68040 z dowolnego ziarna world_seed_val (teren + 8 baz + 8 krysztalow)
exo_generate_world_from_seed:
        movem.l d0-d7/a0-a4,-(sp)
        move.l  world_seed_val(pc),d6
        bne.s   .sd_nz
        move.l  #8842,d6
        move.l  d6,world_seed_val
.sd_nz: lea     exo_voxel_data,a0
        lea     65536(a0),a1
        lea     sin_tab,a2
        moveq   #0,d5                 ; y = 0..255
.gy_lp: moveq   #0,d4                 ; x = 0..255
.gx_lp: move.w  d4,d0
        add.w   d6,d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a2,d0.w),d1
        move.w  d5,d0
        lsr.w   #1,d6
        add.w   d6,d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a2,d0.w),d2
        add.w   d2,d1
        asr.w   #4,d1
        add.w   #34,d1
        cmp.w   #8,d1
        bge.s   .h_lo
        moveq   #8,d1
.h_lo:  cmp.w   #95,d1
        ble.s   .h_hi
        moveq   #95,d1
.h_hi:  move.b  d1,(a0)+
        move.b  #183,d2
        cmp.b   #13,d1
        bgt.s   .c_sh
        move.b  #136,d2
        bra.s   .c_st
.c_sh:  cmp.b   #16,d1
        bgt.s   .c_md
        move.b  #187,d2
        bra.s   .c_st
.c_md:  cmp.b   #46,d1
        ble.s   .c_st
        move.b  #176,d2
.c_st:  move.b  d2,(a1)+
        addq.w  #1,d4
        cmp.w   #256,d4
        blt.s   .gx_lp
        addq.w  #1,d5
        cmp.w   #256,d5
        blt.w   .gy_lp

        ; Wygeneruj 8 baz z ziarna i wypal ladowiska + kopuly w wokselach
        lea     exo_bases,a3
        move.l  world_seed_val(pc),d6
        moveq   #7,d7
.gb_lp: mulu.w  #25173,d6
        add.l   #13849,d6
        move.w  d6,d0
        lsr.w   #8,d0
        and.w   #220,d0
        add.w   #16,d0
        move.w  d0,(a3)
        mulu.w  #25173,d6
        add.l   #13849,d6
        move.w  d6,d1
        lsr.w   #8,d1
        and.w   #220,d1
        add.w   #16,d1
        move.w  d1,2(a3)
        clr.w   4(a3)
        ; Wypal ladowisko 9x9 i kopule w centrum bazy
        moveq   #-4,d3
.by_lp: moveq   #-4,d2
.bx_lp: move.w  d0,d4
        add.w   d2,d4
        and.w   #255,d4
        move.w  d1,d5
        add.w   d3,d5
        and.w   #255,d5
        lsl.w   #8,d5
        or.w    d4,d5
        and.l   #$ffff,d5
        lea     exo_voxel_data,a0
        move.b  #28,(a0,d5.l)
        move.b  #148,65536(a0,d5.l)
        cmp.w   #-1,d2
        blt.s   .bn_dm
        cmp.w   #1,d2
        bgt.s   .bn_dm
        cmp.w   #-1,d3
        blt.s   .bn_dm
        cmp.w   #1,d3
        bgt.s   .bn_dm
        move.b  #40,(a0,d5.l)
        move.b  #158,65536(a0,d5.l)
.bn_dm: addq.w  #1,d2
        cmp.w   #4,d2
        ble.s   .bx_lp
        addq.w  #1,d3
        cmp.w   #4,d3
        ble.s   .by_lp
        addq.l  #6,a3
        dbf     d7,.gb_lp

        ; Wygeneruj 8 formacji krysztalow Aetheru i wypal iglice w wokselach
        lea     exo_crystals,a3
        moveq   #7,d7
.gc_lp: mulu.w  #25173,d6
        add.l   #13849,d6
        move.w  d6,d0
        lsr.w   #8,d0
        and.w   #220,d0
        add.w   #16,d0
        move.w  d0,(a3)
        mulu.w  #25173,d6
        add.l   #13849,d6
        move.w  d6,d1
        lsr.w   #8,d1
        and.w   #220,d1
        add.w   #16,d1
        move.w  d1,2(a3)
        clr.w   4(a3)
        move.w  d1,d5
        lsl.w   #8,d5
        or.w    d0,d5
        and.l   #$ffff,d5
        lea     exo_voxel_data,a0
        moveq   #0,d4
        move.b  (a0,d5.l),d4
        moveq   #-4,d3
.cy_lp: moveq   #-4,d2
.cx_lp: move.w  d2,d5
        bpl.s   .ax_p
        neg.w   d5
.ax_p:  move.w  d3,d1
        bpl.s   .ay_p
        neg.w   d1
.ay_p:  add.w   d1,d5
        cmp.w   #4,d5
        bgt.s   .cn_nx
        move.w  #5,d1
        sub.w   d5,d1
        lsl.w   #2,d1
        add.w   d4,d1
        cmp.w   #122,d1
        ble.s   .ch_ok
        moveq   #122,d1
.ch_ok: move.w  2(a3),d5
        add.w   d3,d5
        and.w   #255,d5
        lsl.w   #8,d5
        move.w  (a3),d0
        add.w   d2,d0
        and.w   #255,d0
        or.w    d0,d5
        and.l   #$ffff,d5
        move.b  d1,(a0,d5.l)
        move.b  #159,65536(a0,d5.l)
.cn_nx: addq.w  #1,d2
        cmp.w   #4,d2
        ble.s   .cx_lp
        addq.w  #1,d3
        cmp.w   #4,d3
        ble.s   .cy_lp
        addq.l  #6,a3
        dbf     d7,.gc_lp

        jsr     exo_play_sfx_ping
        movem.l (sp)+,d0-d7/a0-a4
        rts

exo_draw_menu_bars:
        ; Pasek tytulowy (Y=24..39)
        lea     chunky_buf+24*320+56,a0
        moveq   #15,d7
.mb1:   move.w  #207,d6
.mb1x:  move.b  #128,(a0,d6.w)
        dbf     d6,.mb1x
        adda.w  #320,a0
        dbf     d7,.mb1

        ; 3 osobne naglowki kart postaci (Y=48..61) dokladnie nad portretami!
        lea     chunky_buf+48*320+44,a0
        bsr.w   .card_hdr
        lea     chunky_buf+48*320+126,a0
        bsr.w   .card_hdr
        lea     chunky_buf+48*320+208,a0
        bsr.w   .card_hdr

        ; Pasek wczytywania kolonii (Y=132..145) i pasek ziarna SEED (Y=150..163)
        lea     chunky_buf+132*320+48,a0
        moveq   #13,d7
.mb3:   move.w  #223,d6
.mb3x:  move.b  #128,(a0,d6.w)
        dbf     d6,.mb3x
        adda.w  #320,a0
        dbf     d7,.mb3
        lea     chunky_buf+218*320+48,a0
        moveq   #13,d7
.mb4:   move.w  #223,d6
.mb4x:  move.b  #128,(a0,d6.w)
        dbf     d6,.mb4x
        adda.w  #320,a0
        dbf     d7,.mb4

        lea     txt_title(pc),a2
        lea     chunky_buf+29*320+94,a3
        bsr.w   .pr_str

        ; Nazwy 3 postaci nad kazdym portretem (Y=52)
        lea     txt_role1(pc),a2
        lea     chunky_buf+52*320+48,a3
        bsr.w   .pr_str
        lea     txt_role2(pc),a2
        lea     chunky_buf+52*320+129,a3
        bsr.w   .pr_str
        lea     txt_role3(pc),a2
        lea     chunky_buf+52*320+211,a3
        bsr.w   .pr_str

        ; 3 portrety postaci (48x58) dokladnie pod swoimi nazwami (Y=64..122, X=54, 136, 218)
        lea     exo_role_portraits,a2
        lea     chunky_buf+64*320+54,a3
        bsr.s   .dr_pt
        lea     exo_role_portraits+2784,a2
        lea     chunky_buf+64*320+136,a3
        bsr.s   .dr_pt
        lea     exo_role_portraits+5568,a2
        lea     chunky_buf+64*320+218,a3
        bsr.s   .dr_pt

        lea     txt_load(pc),a2
        lea     chunky_buf+136*320+66,a3
        bsr.w   .pr_str

        ; Sformatuj aktualne 6-cyfrowe ziarno SEED do paska menu
        move.l  world_seed_val(pc),d1
        lea     txt_seed_num+6(pc),a1
        moveq   #5,d2
.sd_f:  moveq   #0,d3
        divu.l  #10,d3:d1
        add.b   #"0",d3
        move.b  d3,-(a1)
        dbf     d2,.sd_f

        lea     txt_seed(pc),a2
        lea     chunky_buf+222*320+60,a3
        bsr.w   .pr_str
        rts
.card_hdr:
        moveq   #13,d7
.ch_y:  moveq   #67,d6
.ch_x:  move.b  #128,(a0,d6.w)
        dbf     d6,.ch_x
        adda.w  #320,a0
        dbf     d7,.ch_y
        rts
.dr_pt: moveq   #57,d7
.dpy:   moveq   #11,d6
        move.l  a3,a0
.dpx:   move.l  (a2)+,(a0)+
        dbf     d6,.dpx
        adda.w  #320,a3
        dbf     d7,.dpy
        rts
.pr_str:
        moveq   #0,d0
        move.b  (a2)+,d0
        beq.s   .pr_end
        ; Obsluga polskich znakow AGA (1=A, 2=C, 3=E, 4=L, 5=N, 6=O, 7=S, 8=Z, 9=Z)
        cmp.b   #10,d0
        bge.s   .asc_ch
        subq.w  #1,d0
        lsl.w   #3,d0
        lea     pl_glyphs_5x7(pc),a4
        add.l   d0,a4
        bra.s   .dr_gl
.asc_ch:sub.w   #32,d0
        lsl.w   #3,d0
        lea     hud_ascii_5x7,a4
        add.l   d0,a4
.dr_gl: move.l  a3,a5
        moveq   #6,d3
.py_lp: move.b  (a4)+,d4
        btst    #4,d4
        beq.s   .b3
        move.b  #255,(a5)
.b3:    btst    #3,d4
        beq.s   .b2
        move.b  #255,1(a5)
.b2:    btst    #2,d4
        beq.s   .b1
        move.b  #255,2(a5)
.b1:    btst    #1,d4
        beq.s   .b0
        move.b  #255,3(a5)
.b0:    btst    #0,d4
        beq.s   .nx
        move.b  #255,4(a5)
.nx:    adda.w  #320,a5
        dbf     d3,.py_lp
        addq.l  #6,a3
        bra.s   .pr_str
.pr_end:
        rts

        even
; 9 polskich znakow 5x7 AGA: 1=A, 2=C, 3=E, 4=L, 5=N, 6=O, 7=S, 8=Z, 9=Z
pl_glyphs_5x7:
        dc.b $0E,$11,$11,$1F,$11,$11,$03,0 ; 1: A ogonek
        dc.b $02,$0E,$11,$10,$10,$11,$0E,0 ; 2: C kreska
        dc.b $1F,$10,$10,$1E,$10,$10,$1F,2 ; 3: E ogonek
        dc.b $10,$10,$14,$18,$10,$10,$1F,0 ; 4: L kreska
        dc.b $02,$11,$19,$15,$13,$11,$11,0 ; 5: N kreska
        dc.b $02,$0E,$11,$11,$11,$11,$0E,0 ; 6: O kreska
        dc.b $02,$0F,$10,$0E,$01,$01,$1E,0 ; 7: S kreska
        dc.b $02,$1F,$01,$02,$04,$08,$1F,0 ; 8: Z kreska
        dc.b $04,$1F,$01,$02,$04,$08,$1F,0 ; 9: Z kropka

        IFD LANG_PL
txt_title: dc.b "AETHER FALCON: VANGUARD",0
txt_role1: dc.b "1:PIONIER",0
txt_role2: dc.b "2:STRA",9,"NIK",0
txt_role3: dc.b "3:IN",9,"YNIER",0
txt_load:  dc.b "4:WCZYTAJ KOLONI",3," (S=ZAPIS)",0
txt_seed:  dc.b "ZIARNO: "
txt_seed_num: dc.b "008842 [S=WPISZ R=LOSUJ]",0
        ELSE
txt_title: dc.b "AETHER FALCON: VANGUARD",0
txt_role1: dc.b "1:PIONEER",0
txt_role2: dc.b "2:GUARDIAN",0
txt_role3: dc.b "3:ENGINEER",0
txt_load:  dc.b "4:LOAD SAVED COLONY (S=SAVE)",0
txt_seed:  dc.b "SEED:   "
txt_seed_num: dc.b "008842 [S=EDIT R=RAND]",0
        ENDC
        even
world_seed_val:  dc.l 8842
seed_digits_cnt: dc.w 0
seed_edit_mode:  dc.b 0
player_role:     dc.b 1
