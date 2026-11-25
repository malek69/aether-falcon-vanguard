        section code,code
; ============================================================================
; AETHER FALCON: VANGUARD - Etap 2: Potok 3D Gameplay, Lock-On i Salwy Rakiet
; ============================================================================

MAX_MISSILES    equ     8

        cnop    0,16
af_render_gameplay_3d:
        movem.l d0-d7/a0-a5,-(sp)

        ; 1. Zaladuj palete 256 kolorow AGA jesli jeszcze nie jest aktywna
        cmp.b   #1,pal_loaded
        beq.s   .pal_ready
        move.b  #1,pal_loaded
        lea     aga_pal256,a0
        jsr     load_aga_256_palette
.pal_ready:

        ; 2. Wyczysc bufor Chunky i 16-bitowy Z-Buffer przed klatka 3D
        jsr     clear_chunky
        jsr     clear_zbuffer_v2
        jsr     render_3d_terrain_flyover

        ; 3. Rzutuj i rysuj wrogie cele (Dominium Vespera) oraz Rdzenie Eteru
        bsr.w   af_draw_world_entities

        ; 4. Aktualizuj i rysuj salwy samonaprowadzajacych rakiet (Panzer Dragoon)
        bsr.w   af_update_and_draw_missiles

        ; 5. Renderuj mysliwiec gracza XF-14 "Albatros" w widoku zza ogona
        tst.b   af_ptrail_init
        bne.s   .pt_ok
        move.b  #1,af_ptrail_init
        jsr     ptrail_reset
.pt_ok:
        moveq   #0,d0                   ; Yaw = 0 (lot w glab ekranu, widok zza ogona)
        move.w  af_pitch,d1
        asr.w   #1,d1
        sub.w   #10,d1                  ; Lekki kat z gory na kadlub i skrzydla
        move.w  af_roll,d2              ; Przechyl skrzydel (bank angle)
        jsr     build_rot_matrix_3d

        ; Pozycja mysliwca na ekranie (dolna czesc kadru, przesuniecie boczne z roll)
        move.w  af_roll,d4
        asr.w   #3,d4                   ; X: lekki dryf przy przechyle
        move.w  #26,d5                  ; Y: w dole kadru (nad terenem)
        moveq   #18,d6                  ; Z: blisko kamery (widok zza ogona)

        lea     xf14_verts,a0
        lea     v2_proj_buf,a1
        move.w  #xf14_vert_count,d7
        jsr     transform_and_project_verts

        lea     xf14_norms,a0
        lea     v2_env_buf,a1
        move.w  #xf14_vert_count,d7
        jsr     transform_normals_envmap

        lea     xf14_env_mesh,a0
        lea     v2_proj_buf,a1
        lea     v2_tex_bank,a2
        lea     v2_env_buf,a3
        jsr     draw_gouraud_env_mesh_v2

        ; Podwojna smuga spalin z dysz mysliwca XF-14
        move.w  af_roll,d4
        asr.w   #3,d4
        move.w  #26,d5
        moveq   #18,d6
        jsr     ptrail_emit_twin_nozzles
        jsr     ptrail_update_and_draw

        ; 6. Rozblysk soczewkowy 3D (Lens Flare) + celownik Lock-On i HUD
        jsr     draw_3d_lens_flare
        bsr.w   af_draw_reticle_and_hud

        ; 7. Konwersja Chunky (160x128) -> 8 bitplanow AGA + obramowanie
        jsr     c2p_160x128_to_aga
        jsr     ground_fill_screen_margins
        jsr     hud_draw_overlay

        movem.l (sp)+,d0-d7/a0-a5
        rts

; ============================================================================
; Rzutowanie 3D -> 2D i rysowanie wrogich dronow / Rdzeni Eteru w chunky_buf
; ============================================================================
        cnop    0,4
af_draw_world_entities:
        lea     af_entities,a4
        move.l  af_pos_x,d4
        swap    d4                      ; Kamera X
        move.l  af_pos_z,d5
        swap    d5                      ; Kamera Z
        moveq   #MAX_ENTITIES-1,d7

.ent_lp:
        tst.b   (a4)
        beq.w   .next_ent

        ; Wzgledne Z obiektu (rel_z = ent_z - cam_z)
        move.l  12(a4),d2
        swap    d2
        sub.w   d5,d2
        cmp.w   #32,d2                  ; Za blisko lub za kamera?
        blt.w   .next_ent
        cmp.w   #3200,d2                ; Za daleko na horyzoncie?
        bgt.w   .next_ent

        ; Wzgledne X i Y (w buforze 160x128: centrum = 80, 56)
        move.l  4(a4),d0
        swap    d0
        sub.w   d4,d0
        ext.l   d0
        asl.l   #7,d0                   ; x * 128
        divs.w  d2,d0
        add.w   #80,d0                  ; scr_x (0..159)

        move.l  8(a4),d1
        swap    d1
        sub.w   #110,d1
        ext.l   d1
        asl.l   #6,d1
        divs.w  d2,d1
        add.w   #56,d1                  ; scr_y (0..127)

        ; Zapisz wspolrzedne ekranowe do tablicy (uzywane przez Lock-On i rakiety)
        move.w  d0,6(a4)                ; nadpisz pomocniczo lub uzyj rejestrow
        cmp.w   #6,d0
        blt.w   .next_ent
        cmp.w   #153,d0
        bgt.w   .next_ent
        cmp.w   #6,d1
        blt.w   .next_ent
        cmp.w   #121,d1
        bgt.w   .next_ent

        ; Oblicz promien obiektu na podstawie glebi Z (2..6 px)
        move.w  #600,d3
        ext.l   d3
        divs.w  d2,d3
        cmp.w   #2,d3
        bge.s   .r_min
        moveq   #2,d3
.r_min: cmp.w   #6,d3
        ble.s   .r_max
        moveq   #6,d3
.r_max:
        ; Wybierz kolor: Rdzen Eteru (type=2) = cyjan/zloto ($EC), Wrog = czerwien ($B8)
        move.b  #$B8,d6
        cmp.b   #2,1(a4)
        bne.s   .draw_box
        move.b  #$EC,d6

.draw_box:
        ; Narysuj wypelniony romb/kapsule 3D w chunky_buf
        bsr.w   af_fill_chunky_diamond

        ; Sprawdz czy celownik gracza (af_reticle_x, af_reticle_y) najechal na obiekt!
        move.w  af_reticle_x,d2
        sub.w   d0,d2
        bpl.s   .dx_ok
        neg.w   d2
.dx_ok: cmp.w   #14,d2
        bgt.s   .chk_locked_box

        move.w  af_reticle_y,d2
        sub.w   d1,d2
        bpl.s   .dy_ok
        neg.w   d2
.dy_ok: cmp.w   #14,d2
        bgt.s   .chk_locked_box

        ; Jesli to wrog (type != 2) -> oznacz Lock-On!
        cmp.b   #2,1(a4)
        beq.s   .chk_locked_box
        tst.b   2(a4)
        bne.s   .chk_locked_box
        cmp.w   #MAX_MISSILES,af_locks
        bge.s   .chk_locked_box
        st      2(a4)
        addq.w  #1,af_locks
        moveq   #SFX_LOCKON,d0
        bsr.w   af_trigger_sfx

.chk_locked_box:
        ; Jesli cel jest namierzony (locked != 0), narysuj ramke Lock-On!
        tst.b   2(a4)
        beq.s   .next_ent
        moveq   #7,d3
        move.b  #$FA,d6                 ; Jasny kolor ramki namierzania
        bsr.w   af_draw_chunky_rect

.next_ent:
        lea     16(a4),a4
        dbf     d7,.ent_lp
        rts

; ============================================================================
; Salwa samonaprowadzajacych rakiet (Panzer Dragoon Multi-Lock Barrage)
; ============================================================================
        cnop    0,4
af_update_and_draw_missiles:
        ; Sprawdz czy gracz wcisnal FIRE (Joy2 bit 7 w CIAAPRA lub Spacja) i ma namierzone cele
        tst.w   af_locks
        beq.w   .move_missiles

        btst    #7,CIAAPRA
        beq.s   .launch_salvo
        cmp.b   #$7F,$bfec01
        bne.w   .move_missiles

.launch_salvo:
        ; Odpal po jednej rakiecie dla kazdego namierzonego wroga
        lea     af_entities,a0
        lea     af_missiles,a1
        moveq   #MAX_ENTITIES-1,d7
.scan_locked:
        tst.b   (a0)
        beq.s   .sl_next
        tst.b   2(a0)
        beq.s   .sl_next
        clr.b   2(a0)                   ; Zdejmij flage lock-on (rakieta juz leci)

        ; Znajdz wolny slot rakiety
        moveq   #MAX_MISSILES-1,d6
        lea     af_missiles,a1
.find_m:
        tst.b   (a1)
        beq.s   .init_m
        addq.l  #8,a1
        dbf     d6,.find_m
        bra.s   .sl_next

.init_m:
        move.b  #1,(a1)                 ; active = 1
        move.b  #18,1(a1)               ; TTL = 18 klatek do trafienia
        move.w  #80,2(a1)               ; start X (z dyszy mysliwca)
        move.w  #104,4(a1)              ; start Y
        move.w  6(a0),6(a1)             ; docelowy X na ekranie
        ; Zniszcz cel po trafieniu i dodaj 500 pkt
        add.l   #500,af_score
        add.l   #6400<<16,12(a0)        ; Respawn wroga dalej na trasie
.sl_next:
        lea     16(a0),a0
        dbf     d7,.scan_locked
        clr.w   af_locks
        moveq   #SFX_MISSILE,d0
        bsr.w   af_trigger_sfx

.move_missiles:
        lea     af_missiles,a1
        moveq   #MAX_MISSILES-1,d7
.m_lp:
        tst.b   (a1)
        beq.s   .m_next
        subq.b  #1,1(a1)
        ble.s   .m_kill

        ; Interpolacja lotu rakiety w strone celu
        move.w  6(a1),d0                ; target X
        sub.w   2(a1),d0
        asr.w   #2,d0
        add.w   d0,2(a1)

        move.w  af_reticle_y,d1
        sub.w   4(a1),d1
        asr.w   #2,d1
        add.w   d1,4(a1)

        ; Rysuj smuge rakiety w chunky_buf
        move.w  2(a1),d0
        move.w  4(a1),d1
        moveq   #2,d3
        move.b  #$FF,d6
        bsr.w   af_fill_chunky_diamond
        bra.s   .m_next
.m_kill:
        clr.b   (a1)
.m_next:
        addq.l  #8,a1
        dbf     d7,.m_lp
        rts

; ============================================================================
; Rysowanie celownika 2D/3D Lock-On oraz paska energii w chunky_buf (160x128)
; ============================================================================
        cnop    0,4
af_draw_reticle_and_hud:
        ; Aktualizuj pozycje celownika zgodnie z przechyłem i pochyleniem mysliwca
        move.w  af_roll,d0
        asr.w   #1,d0
        add.w   #80,d0
        cmp.w   #14,d0
        bge.s   .rx1
        moveq   #14,d0
.rx1:   cmp.w   #145,d0
        ble.s   .rx2
        move.w  #145,d0
.rx2:   move.w  d0,af_reticle_x

        move.w  af_pitch,d1
        add.w   #56,d1
        cmp.w   #14,d1
        bge.s   .ry1
        moveq   #14,d1
.ry1:   cmp.w   #112,d1
        ble.s   .ry2
        move.w  #112,d1
.ry2:   move.w  d1,af_reticle_y

        ; Rysuj zewnetrzny celownik Lock-On (promien 9 px)
        moveq   #9,d3
        move.b  #$FC,d6
        bsr.w   af_draw_chunky_rect

        ; Wewnetrzny krzyzyk celownika
        moveq   #3,d3
        move.b  #$FF,d6
        bsr.w   af_draw_chunky_rect

        ; Rysuj pasek energii z Rdzeni Eteru (lewy gorny rog chunky_buf)
        lea     chunky_buf+(4*160)+6,a0
        move.w  af_energy,d2
        lsr.w   #3,d2                   ; Skaluj 0..255 -> 0..32 px
        cmp.w   #40,d2
        ble.s   .eb_ok
        moveq   #40,d2
.eb_ok: tst.w   d2
        beq.s   .hud_done
        subq.w  #1,d2
.eb_lp: move.b  #$EC,(a0)
        move.b  #$EC,160(a0)
        addq.l  #1,a0
        dbf     d2,.eb_lp
.hud_done:
        rts

; ============================================================================
; Prymitywy rysowania 2D w natywnym buforze Chunky 160x128
; Wejscie: d0.w = cx, d1.w = cy, d3.w = promien, d6.b = kolor
; ============================================================================
        cnop    0,4
af_fill_chunky_diamond:
        movem.l d0-d5/a0,-(sp)
        lea     chunky_buf,a0
        move.w  d1,d4
        sub.w   d3,d4                   ; y = cy - r
        move.w  d1,d5
        add.w   d3,d5                   ; y_end = cy + r
.fd_y:  cmp.w   #0,d4
        blt.s   .fd_ny
        cmp.w   #127,d4
        bgt.s   .fd_ny
        move.w  d4,d2
        mulu.w  #160,d2
        add.w   d0,d2
        move.b  d6,(a0,d2.l)
        move.b  d6,-1(a0,d2.l)
        move.b  d6,1(a0,d2.l)
.fd_ny: addq.w  #1,d4
        cmp.w   d5,d4
        ble.s   .fd_y
        movem.l (sp)+,d0-d5/a0
        rts

        cnop    0,4
af_draw_chunky_rect:
        movem.l d0-d5/a0,-(sp)
        lea     chunky_buf,a0
        move.w  d1,d4
        sub.w   d3,d4                   ; top Y
        move.w  d1,d5
        add.w   d3,d5                   ; bottom Y
        cmp.w   #2,d4
        blt.s   .rc_end
        cmp.w   #125,d5
        bgt.s   .rc_end

        mulu.w  #160,d4
        mulu.w  #160,d5
        move.w  d0,d2
        sub.w   d3,d2                   ; left X
        add.l   d2,d4
        add.l   d2,d5
        move.w  d3,d2
        add.w   d2,d2                   ; szerokosc = 2*r
.rc_x:  move.b  d6,(a0,d4.l)
        move.b  d6,(a0,d5.l)
        addq.l  #1,d4
        addq.l  #1,d5
        dbf     d2,.rc_x
.rc_end:
        movem.l (sp)+,d0-d5/a0
        rts

        even
af_ptrail_init: dc.b    0,0
af_missiles:    dcb.b   8*MAX_MISSILES,0
