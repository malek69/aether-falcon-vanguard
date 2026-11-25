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

        ; 2. Inicjalizacja kamery 3D (cam_oz=-155, cam_cos=256) + gwiazdy + teren
        clr.w   v2_uv_anim_u
        clr.w   v2_uv_anim_v
        jsr     clear_chunky
        bsr.w   af_clear_fighter_zbuffer
        ifd FULL_RES
        jsr     draw_256_starfield
        endif

        move.l  af_pos_x,d0
        swap    d0
        asr.w   #2,d0
        move.w  d0,cam_ox
        move.w  #-26,cam_oy
        move.w  #-155,d0
        btst    #7,CIAAPRA
        beq.s   .cam_boost
        cmp.b   #$40,kbd_held_raw
        bne.s   .cam_z_ok
.cam_boost:
        move.w  #-170,d0
.cam_z_ok:
        move.w  d0,cam_oz
        clr.w   cam_sin
        move.w  #256,cam_cos

        jsr     render_3d_terrain_flyover

        ; 3. Rzutuj i rysuj wrogie cele (Dominium Vespera) oraz Rdzenie Eteru
        bsr.w   af_draw_world_entities

        ; 3b. Renderuj i obsluguj Bossa Misji 03 (Latajaca Forteca Lewiatan)
        bsr.w   af_update_and_draw_boss

        ; 4. Aktualizuj i rysuj salwy samonaprowadzajacych rakiet + czasteczki 3D
        bsr.w   af_update_and_draw_missiles
        bsr.w   af_update_and_draw_particles

        ; 5. Renderuj mysliwiec gracza XF-14 "Albatros" w widoku zza ogona
        tst.b   af_ptrail_init
        bne.s   .pt_ok
        move.b  #1,af_ptrail_init
        jsr     ptrail_reset
.pt_ok:
        ; Sztywna orientacja 360 st. (Gyruss/Tempest):
        ; dziob w srodek ekranu, brzuch na zewnatrz, skrzydla stycznie wzdluz okregu
        bsr.w   af_build_xf14_gyruss_matrix

        ; Pozycja XF-14 na okregu unikow (Lewo/Prawo = kat, Gora/Dol = promien)
        move.w  af_ship_dx,d4
        move.w  af_ship_dy,d5
        ifd FULL_RES
        subq.w  #4,d5
        moveq   #22,d6
        else
        subq.w  #2,d5
        moveq   #24,d6
        endif
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

        ; Podwojna smuga spalin zsynchronizowana z pozycja na okregu
        move.w  af_ship_dx,d4
        move.w  af_ship_dy,d5
        ifd FULL_RES
        subq.w  #4,d5
        moveq   #22,d6
        else
        subq.w  #2,d5
        moveq   #24,d6
        endif
        jsr     ptrail_emit_twin_nozzles
        jsr     ptrail_update_and_draw

        ; 6. Rozblysk soczewkowy 3D (Lens Flare) + celownik Lock-On i HUD
        ifd FULL_RES
        jsr     draw_3d_lens_flare
        endif
        bsr.w   af_draw_reticle_and_hud
        bsr.w   af_draw_cannon_beams

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
        swap    d4
        move.l  af_pos_z,d5
        swap    d5
        move.w  #3200,af_auto_min_z
        moveq   #MAX_ENTITIES-1,d7
.ent_lp:
        tst.b   (a4)
        beq.w   .next_ent
        ; Wrogowie aktywnie zblizaja sie do gracza!
        cmp.b   #2,1(a4)
        beq.s   .z_chk
        sub.l   #26<<16,12(a4)
.z_chk: move.l  12(a4),d2
        swap    d2
        sub.w   d5,d2
        cmp.w   #48,d2
        bge.s   .z_far
        ; Gdy wrog minal gracza, odrodz go na horyzoncie w nowej formacji 360 st.
        move.l  af_pos_z,d0
        add.l   #2800<<16,d0
        move.l  d0,12(a4)
        clr.b   2(a4)
        move.l  a4,a0
        move.w  d7,d0
        add.w   vbl_tick+2,d0
        jsr     af_set_entity_360_slot
        bra.w   .next_ent
.z_far: cmp.w   #3200,d2
        bgt.w   .next_ent
        move.l  4(a4),d0
        swap    d0
        sub.w   d4,d0
        ext.l   d0
        asl.l   #7,d0
        divs.w  d2,d0
        ifd WIDESCREEN_16_9
        muls.w  #3,d0
        asr.w   #2,d0
        endif
        add.w   #160,d0
        move.l  8(a4),d1
        swap    d1
        sub.w   #110,d1
        ext.l   d1
        asl.l   #6,d1
        divs.w  d2,d1
        ifd FULL_RES
        add.w   #104,d1
        else
        add.w   #52,d1
        endif
        cmp.w   #12,d0
        blt.w   .next_ent
        cmp.w   #308,d0
        bgt.w   .next_ent
        cmp.w   #12,d1
        blt.w   .next_ent
        ifd FULL_RES
        cmp.w   #236,d1
        else
        cmp.w   #116,d1
        endif
        bgt.w   .next_ent
        ; Rozmiar obiektu rosnie wyraznie w miare zblizania sie (3..12 px)
        move.w  #1200,d3
        ext.l   d3
        divs.w  d2,d3
        cmp.w   #3,d3
        bge.s   .r_min
        moveq   #3,d3
.r_min: cmp.w   #12,d3
        ble.s   .r_max
        moveq   #12,d3
.r_max: move.b  #$FC,d6
        cmp.b   #2,1(a4)
        bne.s   .draw_box
        move.b  #$FD,d6
.draw_box:
        bsr.w   af_fill_chunky_diamond
        ; Skrzydla mysliwca wroga dla wiekszej czytelnosci sylwetki
        cmp.b   #2,1(a4)
        beq.s   .next_ent
        sub.w   d3,d0
        asr.w   #1,d3
        move.b  #$FE,d6
        bsr.w   af_fill_chunky_diamond
        add.w   d3,d0
        add.w   d3,d0
        add.w   d3,d0
        add.w   d3,d0
        bsr.w   af_fill_chunky_diamond
        sub.w   d3,d0
        sub.w   d3,d0
        lsl.w   #1,d3
        ; AUTOMATYCZNE NAMIERZANIE (Auto-Lock na najblizszym wrogu w kadrze!)
        cmp.w   af_auto_min_z(pc),d2
        bge.s   .chk_lk_box
        move.w  d2,af_auto_min_z
        move.w  d0,af_reticle_x
        move.w  d1,af_reticle_y
        tst.b   2(a4)
        bne.s   .chk_lk_box
        st      2(a4)
        move.w  #1,af_locks
        moveq   #SFX_LOCKON,d0
        bsr.w   af_trigger_sfx
        move.w  af_reticle_x,d0
.chk_lk_box:
        tst.b   2(a4)
        beq.s   .next_ent
        addq.w  #3,d3
        move.b  #$FE,d6
        bsr.w   af_draw_chunky_rect
.next_ent:
        lea     16(a4),a4
        dbf     d7,.ent_lp
        ; Wrogie pociski lecace w strone gracza (do unikania!)
        bsr.s   af_update_enemy_bolts
        rts

af_auto_min_z:  dc.w 3200
af_ebolt_pool:  ds.w 24                 ; 6 pociskow x 4 slowa (z, sx, sy, phase)

af_update_enemy_bolts:
        movem.l d0-d7/a2,-(sp)
        move.w  af_mission,d7
        cmp.w   #2,d7
        ble.s   .m_cap
        moveq   #2,d7
.m_cap: addq.w  #1,d7
        add.w   d7,d7
        subq.w  #1,d7                   ; D7 = liczba aktywnych pociskow - 1 (1, 3 lub 5)
        lea     af_ebolt_pool(pc),a2
.eb_lp: tst.w   (a2)
        bgt.s   .eb_adv
        cmp.w   #3200,af_auto_min_z(pc)
        beq.w   .eb_nxt
        ; Odpal nowy pocisk z opoznieniem fazowym dla kazdego slotu
        move.w  d7,d0
        mulu.w  #42,d0
        add.w   #160,d0
        move.w  d0,(a2)
        move.w  af_reticle_x,2(a2)
        move.w  af_reticle_y,4(a2)
        move.w  d7,d1
        lsl.w   #5,d1
        move.w  d1,6(a2)
        bra.w   .eb_nxt
.eb_adv:move.w  af_mission,d0
        addq.w  #5,d0
        sub.w   d0,(a2)
        bgt.s   .eb_drw
        ; Sprawdz trafienie 2D w aktualna pozycje mysliwca na okregu 360 st.
        move.w  af_ship_dx,d0
        add.w   #160,d0
        sub.w   2(a2),d0
        bpl.s   .adx
        neg.w   d0
.adx:   cmp.w   #22,d0
        bgt.w   .eb_nxt
        move.w  af_ship_dy,d1
        ifd FULL_RES
        add.w   #136,d1
        else
        add.w   #68,d1
        endif
        sub.w   4(a2),d1
        bpl.s   .ady
        neg.w   d1
.ady:   cmp.w   #18,d1
        bgt.w   .eb_nxt
        ; Trafienie w tarcze XF-14!
        move.b  #14,af_shield_flash
        moveq   #SFX_EXPLODE,d0
        bsr.w   af_trigger_sfx
        sub.w   #25,af_energy
        bgt.s   .sh_ok
        clr.w   af_energy
        st      af_game_over
        clr.b   af_boss_active
        moveq   #3,d0
        jsr     copper_set_sky_theme
        clr.l   af_state_timer
        move.w  #STATE_DEBRIEF,af_state
.sh_ok:
        bra.w   .eb_nxt
.eb_drw:move.w  #260,d2
        sub.w   (a2),d2
        bpl.s   .z_pos
        moveq   #4,d2
.z_pos: move.w  2(a2),d0
        move.w  4(a2),d1
        ; Rozrzut pociskow po okregu
        move.w  6(a2),d4
        and.w   #255,d4
        lea     sin_tab,a0
        add.w   d4,d4
        move.w  (a0,d4.w),d5
        muls.w  d2,d5
        asr.l   #8,d5
        asr.w   #2,d5
        add.w   d5,d0
        ifd FULL_RES
        move.w  #136,d3
        else
        moveq   #68,d3
        endif
        sub.w   d1,d3
        muls.w  d2,d3
        divs.w  #260,d3
        add.w   d3,d1
        lsr.w   #5,d2
        addq.w  #2,d2
        move.w  d2,d3
        move.b  #$FC,d6
        bsr.w   af_fill_chunky_diamond
        subq.w  #1,d3
        move.b  #$FF,d6
        bsr.w   af_fill_chunky_diamond
.eb_nxt:addq.l  #8,a2
        dbf     d7,.eb_lp
        movem.l (sp)+,d0-d7/a2
        rts
; ============================================================================
; Salwa samonaprowadzajacych rakiet (Panzer Dragoon Multi-Lock Barrage)
; ============================================================================
        cnop    0,4
af_update_and_draw_missiles:
        ; Sprawdz czy gracz wcisnal FIRE (Joy2 bit 7, Spacja $40 lub Lewy Alt $64)
        btst    #7,CIAAPRA
        beq.s   .do_fire_weapons
        move.b  kbd_held_raw,d0
        cmp.b   #$40,d0                 ; Spacja
        beq.s   .do_fire_weapons
        cmp.b   #$64,d0                 ; Lewy Alt
        bne.w   .move_missiles

.do_fire_weapons:
        ; 1. Natychmiastowy strzal podwojnymi dzialkami plazmowymi w celownik!
        move.w  af_reticle_x,d0
        move.w  af_reticle_y,d1
        moveq   #4,d3
        move.b  #$FD,d6
        bsr.w   af_fill_chunky_diamond
        moveq   #2,d3
        move.b  #$FF,d6
        bsr.w   af_fill_chunky_diamond
        moveq   #SFX_MISSILE,d0
        bsr.w   af_trigger_sfx

        ; Sprawdz bezposrednie trafienie dzialkiem w wroga pod celownikiem
        lea     af_entities,a0
        moveq   #MAX_ENTITIES-1,d7
.gun_hit_lp:
        tst.b   (a0)
        beq.s   .gh_next
        cmp.b   #2,1(a0)
        beq.s   .gh_next
        tst.b   2(a0)
        beq.s   .gh_next
        clr.b   2(a0)
        subq.w  #1,af_locks
        bge.s   .lk_ok
        clr.w   af_locks
.lk_ok: move.w  af_reticle_x,d0
        move.w  af_reticle_y,d1
        bsr.w   af_spawn_explosion
        add.l   #300,af_score
        add.l   #6400<<16,12(a0)
.gh_next:
        lea     16(a0),a0
        dbf     d7,.gun_hit_lp

        ; 2. Jesli sa namierzone cele Multi-Lock -> odpal salwe samonaprowadzajacych rakiet!
        tst.w   af_locks
        beq.w   .move_missiles

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
        move.w  #160,2(a1)              ; start X (z dyszy mysliwca)
        ifd FULL_RES
        move.w  #140,4(a1)
        else
        move.w  #104,4(a1)
        endif
        move.w  af_reticle_x,6(a1)    ; docelowy X na ekranie
        ; Wyzwol eksplozje czasteczkowa 3D + dodaj 500 pkt
        move.w  af_reticle_x,d0
        move.w  af_reticle_y,d1
        bsr.w   af_spawn_explosion
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
        ; Celownik Auto-Lock zostaje na najblizszym wrogu (nie rusza sie z klawiszami!)
        cmp.w   #3200,af_auto_min_z(pc)
        bne.s   .ret_ok
        move.w  #160,af_reticle_x
        ifd FULL_RES
        move.w  #104,af_reticle_y
        else
        move.w  #52,af_reticle_y
        endif
.ret_ok:
        move.w  af_reticle_x,d0
        move.w  af_reticle_y,d1
        ; Rysuj zewnetrzny celownik Lock-On (promien 9 px)
        moveq   #9,d3
        move.b  #$FC,d6
        bsr.w   af_draw_chunky_rect

        ; Wewnetrzny krzyzyk celownika
        moveq   #3,d3
        move.b  #$FF,d6
        bsr.w   af_draw_chunky_rect

        ; Rysuj pasek energii tarczy (lewy gorny rog chunky_buf) z kolorem wg stanu
        move.b  #$FD,d6                 ; Blekit = tarcza pelna (>100)
        move.w  af_energy,d2
        cmp.w   #50,d2
        bgt.s   .sh_col1
        move.b  #$FC,d6                 ; Czerwien = stan krytyczny (<=50)
        bra.s   .sh_col_ok
.sh_col1:
        cmp.w   #100,d2
        bgt.s   .sh_col_ok
        move.b  #$FE,d6                 ; Zloto = tarcza oslabiona (<=100)
.sh_col_ok:
        lea     chunky_buf+(8*320)+10,a0
        lsr.w   #3,d2                   ; Skaluj 0..255 -> 0..32 px
        cmp.w   #40,d2
        ble.s   .eb_ok
        moveq   #40,d2
.eb_ok: tst.w   d2
        beq.s   .sh_warn_chk
        subq.w  #1,d2
.eb_lp: move.b  d6,(a0)
        move.b  d6,320(a0)
        addq.l  #1,a0
        dbf     d2,.eb_lp

.sh_warn_chk:
        ; Ostrzezenie o trafieniu / niskiej tarczy
        tst.b   af_shield_flash
        beq.s   .sh_crit_chk
        subq.b  #1,af_shield_flash
        ; Czerwona ramka alarmowa przy trafieniu w tarcze
        move.w  #160,d0
        ifd FULL_RES
        move.w  #128,d1
        moveq   #122,d3
        else
        moveq   #64,d1
        moveq   #60,d3
        endif
        move.b  #$FC,d6
        bsr.w   af_draw_chunky_rect
        lea     str_shield_hit(pc),a0
        move.w  #128,d0
        moveq   #6,d1
        move.b  #$FC,d6
        jsr     af_print_chunky_str
        bra.s   .hud_done

.sh_crit_chk:
        cmp.w   #50,af_energy
        bgt.s   .hud_done
        btst    #3,vbl_tick+3
        beq.s   .hud_done
        lea     str_shield_low(pc),a0
        moveq   #112,d0
        moveq   #6,d1
        move.b  #$FC,d6
        jsr     af_print_chunky_str
.hud_done:
        rts

str_shield_hit: dc.b    "SHIELD HIT!",0
str_shield_low: dc.b    "CRITICAL SHIELD!",0
        even

; ============================================================================
; Prymitywy rysowania 2D w natywnym buforze Chunky 160x128
; Wejscie: d0.w = cx, d1.w = cy, d3.w = promien, d6.b = kolor
; ============================================================================
        cnop    0,4
af_fill_chunky_diamond:
        movem.l d0-d7/a0-a1,-(sp)
        lea     chunky_buf,a0
        move.w  d1,d4
        sub.w   d3,d4                   ; y = cy - r
        move.w  d1,d5
        add.w   d3,d5                   ; y_end = cy + r
.fd_y:  cmp.w   #2,d4
        blt.s   .fd_ny
        cmp.w   #250,d4
        bgt.s   .fd_ny

        ; Polowa szerokosci w tym wierszu: hw = r - abs(y - cy)
        move.w  d4,d7
        sub.w   d1,d7
        bpl.s   .abs_ok
        neg.w   d7
.abs_ok:
        move.w  d3,d2
        sub.w   d7,d2                   ; d2 = hw (>= 0)
        move.w  d4,d7
        mulu.w  #320,d7
        add.w   d0,d7
        sub.w   d2,d7
        lea     (a0,d7.l),a1            ; lewy brzeg wiersza
        add.w   d2,d2                   ; szerokosc = 2*hw + 1
.fd_x:  move.b  d6,(a1)+
        dbf     d2,.fd_x

.fd_ny: addq.w  #1,d4
        cmp.w   d5,d4
        ble.s   .fd_y
        movem.l (sp)+,d0-d7/a0-a1
        rts

        cnop    0,4
af_draw_chunky_rect:
        movem.l d0-d7/a0-a2,-(sp)
        lea     chunky_buf,a0
        move.w  d1,d4
        sub.w   d3,d4                   ; top Y
        move.w  d1,d5
        add.w   d3,d5                   ; bottom Y
        cmp.w   #2,d4
        blt.s   .rc_end
        cmp.w   #250,d5
        bgt.s   .rc_end

        ; Gorny i dolny bok ramki
        move.w  d4,d7
        mulu.w  #320,d7
        add.w   d0,d7
        sub.w   d3,d7
        lea     (a0,d7.l),a1            ; top-left

        move.w  d5,d7
        mulu.w  #320,d7
        add.w   d0,d7
        sub.w   d3,d7
        lea     (a0,d7.l),a2            ; bottom-left

        move.w  d3,d2
        add.w   d2,d2
.rc_x:  move.b  d6,(a1)+
        move.b  d6,(a2)+
        dbf     d2,.rc_x

        ; Lewy i prawy bok ramki
        move.w  d4,d7
        mulu.w  #320,d7
        add.w   d0,d7
        sub.w   d3,d7
        lea     (a0,d7.l),a1            ; top-left
        move.w  d3,d2
        add.w   d2,d2
        lea     (a1,d2.w),a2            ; top-right
.rc_y:  move.b  d6,(a1)
        move.b  d6,(a2)
        lea     320(a1),a1
        lea     320(a2),a2
        dbf     d2,.rc_y
.rc_end:
        movem.l (sp)+,d0-d7/a0-a2
        rts

        even
af_ptrail_init: dc.b    0,0
af_missiles:    dcb.b   8*MAX_MISSILES,0

; ============================================================================
; Selektywne czyszczenie Z-Buffera tylko w oknie mysliwca XF-14
; Oszczedza ~90% przepustowosci Fast RAM na bazowej Amidze 1200 (14 MHz)
; ============================================================================
        cnop    0,4
af_clear_fighter_zbuffer:
        movem.l d0-d2/a0-a1,-(sp)
        move.l  #$7fff7fff,d0
        ifd FULL_RES
        lea     zbuf_3d+(40*640),a0
        move.w  #215,d2                 ; 216 wierszy x pelne 320 px szerokosci (zero prostokata!)
        else
        lea     zbuf_3d+(20*640),a0
        moveq   #107,d2                 ; 108 wierszy x pelne 320 px szerokosci
        endif
.zb_row:
        moveq   #39,d1                  ; 40 x 16 bajtow = 640 bajtow (cale 320 px!)
        move.l  a0,a1
.zb_col:
        move.l  d0,(a1)+
        move.l  d0,(a1)+
        move.l  d0,(a1)+
        move.l  d0,(a1)+
        dbf     d1,.zb_col
        lea     640(a0),a0
        dbf     d2,.zb_row
        movem.l (sp)+,d0-d2/a0-a1
        rts

; ============================================================================
; MISJA 03 BOSS: Latajaca Forteca "LEWIATAN" (4 niezalezne reaktory Multi-Lock)
; ============================================================================
MAX_PARTICLES   equ     32

        cnop    0,4
af_init_boss_leviathan:
        move.b  #1,af_boss_active
        move.w  #4,af_boss_reactors_left
        ; 4 reaktory: [hp.b, locked.b, off_x.w, off_y.w] (6 bajtow na reaktor)
        lea     af_boss_reactors,a0
        move.b  #2,(a0)+
        clr.b   (a0)+
        move.w  #-54,(a0)+
        move.w  #-12,(a0)+

        move.b  #2,(a0)+
        clr.b   (a0)+
        move.w  #54,(a0)+
        move.w  #-12,(a0)+

        move.b  #2,(a0)+
        clr.b   (a0)+
        move.w  #-28,(a0)+
        move.w  #14,(a0)+

        move.b  #2,(a0)+
        clr.b   (a0)+
        move.w  #28,(a0)+
        move.w  #14,(a0)+
        rts

        cnop    0,4
af_update_and_draw_boss:
        tst.b   af_boss_active
        beq.w   .boss_ret

        movem.l d0-d7/a0-a3,-(sp)
        ; Cytadela Lewiatan w centrum tunelu 360 st. z lekka oscylacja orbitalna
        move.l  vbl_tick,d0
        and.w   #$ff,d0
        lea     sin_tab,a1
        move.w  (a1,d0.w*2),d4
        asr.w   #4,d4
        add.w   #160,d4                 ; d4 = boss_cx (144..176)
        add.w   #64,d0
        and.w   #$ff,d0
        move.w  (a1,d0.w*2),d5
        asr.w   #5,d5
        ifd FULL_RES
        add.w   #128,d5                 ; d5 = centrum okregu 320x256
        else
        add.w   #64,d5                  ; d5 = centrum okregu 320x128
        endif

        ; Glowny pancerz cytadeli Lewiatan (podwojny romb energetyczny w centrum tunelu)
        move.w  d4,d0
        move.w  d5,d1
        ifd FULL_RES
        moveq   #26,d3
        else
        moveq   #14,d3
        endif
        move.b  #$F4,d6
        bsr.w   af_fill_chunky_diamond
        ifd FULL_RES
        moveq   #14,d3
        else
        moveq   #8,d3
        endif
        move.b  #$FC,d6
        bsr.w   af_fill_chunky_diamond

        ; Co 64 klatki Lewiatan odpala salwe promieniowa w strone pozycji gracza na okregu 360 st.
        move.l  vbl_tick,d0
        and.w   #$3f,d0
        bne.s   .boss_no_shot
        lea     af_ebolt_pool(pc),a3
        tst.w   (a3)
        bgt.s   .boss_no_shot
        move.w  #220,(a3)
        move.w  af_ship_dx,d0
        add.w   #160,d0
        move.w  d0,2(a3)
        move.w  af_ship_dy,d0
        ifd FULL_RES
        add.w   #136,d0
        else
        add.w   #68,d0
        endif
        move.w  d0,4(a3)
        move.w  vbl_tick+2,6(a3)
.boss_no_shot:

        ; Rysuj i obracaj 4 niezalezne reaktory na pelnym okregu 360 st. wokol rdzenia!
        lea     af_boss_reactors,a2
        moveq   #3,d7
.br_lp:
        tst.b   (a2)                    ; hp > 0?
        beq.w   .br_next

        ; Kat reaktora = d7*64 + vbl_tick (pelny obrot 360 st. wokol cytadeli)
        move.w  d7,d2
        lsl.w   #6,d2
        add.w   vbl_tick+2,d2
        and.w   #$ff,d2
        lea     sin_tab,a1
        move.w  (a1,d2.w*2),d0          ; sin(a)
        muls.w  #62,d0
        asr.l   #8,d0
        add.w   d4,d0                   ; rx = boss_cx + 62*sin(a)

        add.w   #64,d2
        and.w   #$ff,d2
        move.w  (a1,d2.w*2),d1          ; cos(a)
        ifd FULL_RES
        muls.w  #54,d1
        else
        muls.w  #27,d1
        endif
        asr.l   #8,d1
        add.w   d5,d1                   ; ry = boss_cy + R_y*cos(a)
        move.w  d0,2(a2)
        move.w  d1,4(a2)

        ; Rysuj rdzen reaktora (pulsacja zloto/czerwien)
        moveq   #6,d3
        move.b  #$FC,d6
        bsr.w   af_fill_chunky_diamond
        moveq   #3,d3
        move.b  #$FE,d6
        bsr.w   af_fill_chunky_diamond

        ; Sprawdz najazd celownika lub promienia dziobu XF-14 na reaktor
        move.w  af_reticle_x,d2
        sub.w   d0,d2
        bpl.s   .bdx
        neg.w   d2
.bdx:   cmp.w   #15,d2
        bgt.s   .b_chk_lock

        move.w  af_reticle_y,d2
        sub.w   d1,d2
        bpl.s   .bdy
        neg.w   d2
.bdy:   cmp.w   #15,d2
        bgt.s   .b_chk_lock

        tst.b   1(a2)                   ; juz namierzony?
        bne.s   .b_chk_lock
        cmp.w   #MAX_MISSILES,af_locks
        bge.s   .b_chk_lock
        st      1(a2)
        addq.w  #1,af_locks
        moveq   #SFX_LOCKON,d0
        bsr.w   af_trigger_sfx

.b_chk_lock:
        tst.b   1(a2)
        beq.s   .br_next
        move.w  2(a2),d0
        move.w  4(a2),d1
        moveq   #8,d3
        move.b  #$FF,d6
        bsr.w   af_draw_chunky_rect

        ; Jesli gracz nacisnal FIRE podczas namierzenia reaktora -> trafienie!
        btst    #7,CIAAPRA
        beq.s   .hit_reactor
        cmp.b   #$40,kbd_held_raw
        bne.s   .br_next

.hit_reactor:
        clr.b   1(a2)
        subq.w  #1,af_locks
        bpl.s   .lk_ok
        clr.w   af_locks
.lk_ok: subq.b  #1,(a2)
        bsr.w   af_spawn_explosion
        add.l   #1000,af_score
        tst.b   (a2)
        bne.s   .br_next
        ; Reaktor zniszczony!
        add.l   #1500,af_score
        subq.w  #1,af_boss_reactors_left
        bgt.s   .br_next
        ; Wszystkie 4 reaktory zniszczone - koniec Bossa i Misji 03!
        clr.b   af_boss_active
        add.l   #5000,af_score

.br_next:
        addq.l  #6,a2
        dbf     d7,.br_lp
        movem.l (sp)+,d0-d7/a0-a3
.boss_ret:
        rts

; ============================================================================
; EKSPLOZJE CZASTECZKOWE 3D + BLYSK + PAULA SFX CH3
; Wejscie af_spawn_explosion: d0.w = cx, d1.w = cy
; ============================================================================
        cnop    0,4
af_spawn_explosion:
        movem.l d0-d5/a0-a1,-(sp)
        move.w  d0,d4
        move.w  d1,d5
        moveq   #SFX_EXPLODE,d0
        bsr.w   af_trigger_sfx

        lea     af_particles,a0
        lea     .vel_tab(pc),a1
        moveq   #11,d3                  ; 12 odlamkow na eksplozje
        moveq   #MAX_PARTICLES-1,d2
.sp_find:
        tst.b   (a0)
        bne.s   .sp_next
        move.b  #16,(a0)                ; life = 16 klatek
        move.b  #$FE,1(a0)              ; kolor zloto/ogien
        btst    #0,d3
        beq.s   .c_ok
        move.b  #$FC,1(a0)              ; co drugi odlamek czerwony
.c_ok:  move.w  d4,2(a0)                ; x
        move.w  d5,4(a0)                ; y
        move.w  (a1)+,6(a0)             ; vx
        move.w  (a1)+,8(a0)             ; vy
        subq.w  #1,d3
        blt.s   .sp_done
.sp_next:
        lea     10(a0),a0
        dbf     d2,.sp_find
.sp_done:
        movem.l (sp)+,d0-d5/a0-a1
        rts
.vel_tab:
        dc.w    -5,-4, 5,-4, -6,1, 6,1, -4,5, 4,5
        dc.w    -2,-6, 2,-6, -7,-1, 7,-1, -2,6, 2,6

        cnop    0,4
af_update_and_draw_particles:
        movem.l d0-d3/d6-d7/a0,-(sp)
        lea     af_particles,a0
        moveq   #MAX_PARTICLES-1,d7
.pt_lp:
        tst.b   (a0)
        beq.s   .pt_next
        subq.b  #1,(a0)
        beq.s   .pt_next
        move.w  6(a0),d0
        add.w   d0,2(a0)
        move.w  8(a0),d1
        add.w   d1,4(a0)
        addq.w  #1,8(a0)                ; grawitacja odlamkow
        move.w  2(a0),d0
        move.w  4(a0),d1
        cmp.w   #4,d0
        blt.s   .pt_kill
        cmp.w   #315,d0
        bgt.s   .pt_kill
        cmp.w   #4,d1
        blt.s   .pt_kill
        ifd FULL_RES
        cmp.w   #250,d1
        else
        cmp.w   #122,d1
        endif
        bgt.s   .pt_kill
        moveq   #2,d3
        move.b  1(a0),d6
        bsr.w   af_fill_chunky_diamond
        bra.s   .pt_next
.pt_kill:
        clr.b   (a0)
.pt_next:
        lea     10(a0),a0
        dbf     d7,.pt_lp
        movem.l (sp)+,d0-d3/d6-d7/a0
        rts

af_draw_cannon_beams:
        cmp.w   #3200,af_auto_min_z(pc)
        bne.s   .cb_fire
        btst    #7,CIAAPRA
        beq.s   .cb_fire
        tst.b   fire_held
        bne.s   .cb_fire
        rts
.cb_fire:
        movem.l d0-d7/a0-a1,-(sp)
        ; Oblicz wektor skrzydla (wx, wy) z kata obrotu po okregu (af_orbit_angle)
        lea     sin_tab,a0
        move.w  af_orbit_angle,d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d2          ; sin(angle) -> wektor skrzydla X
        muls.w  #24,d2
        asr.l   #8,d2               ; wx = 24 * sin(angle)
        move.w  af_orbit_angle,d0
        add.w   #64,d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d3          ; cos(angle) -> wektor skrzydla Y
        neg.w   d3                  ; styczny wektor skrzydla Y = -cos(angle)
        muls.w  #14,d3
        asr.l   #8,d3               ; wy = -14 * cos(angle)
        ; Srodek mysliwca na ekranie: sx = 160 + af_ship_dx, sy = 120 + af_ship_dy (60 dla lowres)
        move.w  af_ship_dx,d4
        add.w   #160,d4
        move.w  af_ship_dy,d5
        ifd FULL_RES
        add.w   #120,d5
        else
        add.w   #60,d5
        endif
        moveq   #7,d7
.cb_lp: ; Lewa koncowka skrzydla -> celownik
        move.w  d4,d0
        sub.w   d2,d0
        move.w  af_reticle_x,d6
        sub.w   d0,d6
        muls.w  d7,d6
        asr.l   #3,d6
        add.w   d6,d0
        move.w  d5,d1
        add.w   d3,d1
        move.w  af_reticle_y,d6
        sub.w   d1,d6
        muls.w  d7,d6
        asr.l   #3,d6
        add.w   d6,d1
        movem.w d2-d5,-(sp)
        moveq   #2,d3
        move.b  #$FD,d6
        bsr.w   af_fill_chunky_diamond
        movem.w (sp)+,d2-d5
        ; Prawa koncowka skrzydla -> celownik
        move.w  d4,d0
        add.w   d2,d0
        move.w  af_reticle_x,d6
        sub.w   d0,d6
        muls.w  d7,d6
        asr.l   #3,d6
        add.w   d6,d0
        move.w  d5,d1
        sub.w   d3,d1
        move.w  af_reticle_y,d6
        sub.w   d1,d6
        muls.w  d7,d6
        asr.l   #3,d6
        add.w   d6,d1
        movem.w d2-d5,-(sp)
        moveq   #2,d3
        move.b  #$FF,d6
        bsr.w   af_fill_chunky_diamond
        movem.w (sp)+,d2-d5
        dbf     d7,.cb_lp
        movem.l (sp)+,d0-d7/a0-a1
        rts

;------------------------------------------------------------------------------
; af_build_xf14_gyruss_matrix
; Buduje ortonormalna macierz 3x3 (rot_m00..rot_m22, skala 256) dla XF-14:
; - Skrzydla (+X, kolumna 0): stycznie wzdluz okregu (sin(a), -cos(a), 0)
; - Brzuch   (+Y, kolumna 1): na zewnatrz okregu (ca*cos(a), ca*sin(a), sa)
; - Dziob    (+Z, kolumna 2): w glab i lekko w srodek ekranu (-sa*cos(a), -sa*sin(a), ca)
; Klawisze Gora/Dol zmieniaja tylko promien bez obracania kadlubem.
;------------------------------------------------------------------------------
af_build_xf14_gyruss_matrix:
        movem.l d0-d5/a0-a1,-(sp)
        lea     sin_tab,a0
        move.w  af_orbit_angle,d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d2          ; d2 = sin(theta) (-256..256)
        move.w  af_orbit_angle,d0
        add.w   #64,d0
        and.w   #255,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d3          ; d3 = cos(theta) (-256..256)

        ; Staly kat pochylenia dziobu ku srodkowi tunelu: alpha = 14/256 (~20 st.)
        ; sin(alpha) = 88, cos(alpha) = 240 (88^2 + 240^2 = 65344 ~= 256^2)
        moveq   #88,d4                ; sa = sin(alpha)
        move.w  #240,d5               ; ca = cos(alpha)

        lea     rot_m00,a1
        ; Kolumna 0 (+X = prawe skrzydlo): (sin(theta), -cos(theta), 0)
        move.w  d2,(a1)               ; m00 = sin(theta)
        move.w  d3,d0
        neg.w   d0
        move.w  d0,6(a1)              ; m10 = -cos(theta)
        clr.w   12(a1)                ; m20 = 0

        ; Kolumna 1 (+Y = brzuch na zewnatrz): (ca*cos(theta), ca*sin(theta), sa)
        move.w  d5,d0
        muls.w  d3,d0
        asr.l   #8,d0
        move.w  d0,2(a1)              ; m01 = ca * cos(theta)
        move.w  d5,d0
        muls.w  d2,d0
        asr.l   #8,d0
        move.w  d0,8(a1)              ; m11 = ca * sin(theta)
        move.w  d4,14(a1)             ; m21 = sa

        ; Kolumna 2 (+Z = dziob w srodek ekranu): (-sa*cos(theta), -sa*sin(theta), ca)
        move.w  d4,d0
        muls.w  d3,d0
        asr.l   #8,d0
        neg.w   d0
        move.w  d0,4(a1)              ; m02 = -sa * cos(theta)
        move.w  d4,d0
        muls.w  d2,d0
        asr.l   #8,d0
        neg.w   d0
        move.w  d0,10(a1)             ; m12 = -sa * sin(theta)
        move.w  d5,16(a1)             ; m22 = ca

        movem.l (sp)+,d0-d5/a0-a1
        rts

;------------------------------------------------------------------------------
; af_set_entity_360_slot
; Rozmieszcza encje (a0) na pelnym okregu 360 st. wg aktualnej misji:
; - Misja 01: Spirala 360 st. (co 30 st., promien R=135)
; - Misja 02: Podwojna Helisa Krell 360 st. (naprzemiennie R=155 i R=90)
; - Misja 03: Pierścienie Cytadeli 360 st. (4 sektory co 90 st. + rozrzut)
; Wejscie: a0 = wskaznik rekordu encji (16B), d0.w = indeks slotu
;------------------------------------------------------------------------------
af_set_entity_360_slot:
        movem.l d0-d4/a1,-(sp)
        lea     sin_tab,a1
        move.w  af_mission,d3
        cmp.w   #1,d3
        beq.s   .f_m2
        cmp.w   #2,d3
        beq.s   .f_m3

        ; Misja 01: pelna spirala 360 st. (krok ~21 jednostek z 256)
        move.w  d0,d1
        mulu.w  #21,d1
        move.w  #135,d2
        bra.s   .f_calc

.f_m2:  ; Misja 02: podwojna helisa 360 st.
        move.w  d0,d1
        mulu.w  #32,d1
        move.w  #155,d2
        btst    #0,d0
        beq.s   .f_calc
        moveq   #90,d2
        add.w   #16,d1
        bra.s   .f_calc

.f_m3:  ; Misja 03: formacja pierscieniowa 4 sektorow cytadeli (co 64 z 256)
        move.w  d0,d1
        and.w   #3,d1
        lsl.w   #6,d1
        move.w  d0,d4
        and.w   #12,d4
        add.w   d4,d1
        move.w  #140,d2

.f_calc:
        and.w   #$ff,d1
        move.w  (a1,d1.w*2),d3          ; sin(angle)
        muls.w  d2,d3
        asr.l   #8,d3
        swap    d3
        clr.w   d3
        move.l  d3,4(a0)                ; X na okregu 360 st.

        add.w   #64,d1
        and.w   #$ff,d1
        move.w  (a1,d1.w*2),d3          ; cos(angle)
        muls.w  d2,d3
        asr.l   #8,d3
        add.w   #110,d3                 ; Y wzgledem osi tunelu (110)
        swap    d3
        clr.w   d3
        move.l  d3,8(a0)                ; Y na okregu 360 st.

        movem.l (sp)+,d0-d4/a1
        rts
