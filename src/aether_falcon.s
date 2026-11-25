; ============================================================================
;  PLIK / FILE: aether_falcon.s
;  PROJEKT: AETHER FALCON: VANGUARD (Amiga 1200 AGA / THEA1200)
; ============================================================================

BPL_SIZE        equ     40*256

STATE_INTRO     equ     0
STATE_BRIEFING  equ     1
STATE_GAMEPLAY  equ     2
STATE_DEBRIEF   equ     3

MAX_ENTITIES    equ     12

        machine 68020
        section code,code

start:
        movem.l d0-a6,-(sp)

        ; 1. Odczyt VBR przez Exec Supervisor() zanim sys_takeover wylaczy OS
        move.l  4.w,a6
        lea     .get_vbr(pc),a5
        jsr     -30(a6)
        move.l  d0,af_vbr_base

        ; 2. Wczytanie danych z dysku twardego (DH0:data/ przed sys_takeover)
        jsr     af_disk_load_all

        ; 3. Przejecie sprzetu AGA (bitplany $80000..$a8000, Copper, Audio .MOD)
        bsr.w   sys_takeover
        tst.l   d0
        beq.w   exit_program

        ; 4. Podpiecie przerwania VBL 50Hz pod prawdziwy adres VBR+$6c
        move.l  af_vbr_base,a0
        move.l  #vbl_irq_handler,$6c(a0)
        bra.s   .vbr_ready
.get_vbr:
        movec   vbr,d0
        rte
.vbr_ready:

        move.l  #0,vbl_tick
        moveq   #3,d0
        jsr     copper_set_sky_theme
        lea     aga_pal256,a0
        move.l  #$00FF3040,252*4(a0)    ; $FC = czerwien bojowa (wrogowie / celownik)
        move.l  #$0020E8FF,253*4(a0)    ; $FD = blekit Eteru (skrzydla / rdzenie)
        move.l  #$00FFD020,254*4(a0)    ; $FE = zloto Solis (emblem / lock-on)
        move.l  #$00FFFFFF,255*4(a0)    ; $FF = czysta biel (napisy / HUD)
        jsr     load_aga_256_palette
        move.b  #1,pal_loaded
        jsr     hud_fps_init
        clr.b   info_visible
        jsr     terrain_3d_init
        bsr.w   af_init_campaign
        jsr     af_play_intro_pcm

        cnop    0,16
mainloop:
        bsr.w   wait_vbl
        jsr     input_update_controls
        cmp.l   #2,vbl_tick
        bne.s   .pal_synced
        lea     aga_pal256,a0
        jsr     load_aga_256_palette
.pal_synced:

        ; Wyjscie po 25 klatkach (debounce klikniecia w okno emulatora)
        cmp.l   #25,vbl_tick
        blo.s   .no_exit
        btst    #6,CIAAPRA              ; LMB
        beq.w   shutdown
        cmp.b   #$75,$bfec01            ; ESC
        beq.w   shutdown
.no_exit:

        move.w  af_state,d0
        cmp.w   #STATE_GAMEPLAY,d0
        beq.w   .do_gameplay

        ; --- TRYB WEKTOROWY: INTRO / BRIEFING / DEBRIEFING ---
        jsr     af_render_vector_screen
        jsr     hud_fps_tick

        ; Przejscie dalej: Joy2 Fire, RMB, Spacja lub Enter
        addq.l  #1,af_state_timer
        cmp.l   #20,af_state_timer
        blo.w   mainloop

        btst    #7,CIAAPRA              ; Joy2 Fire / Pad THEA1200
        beq.s   .advance_state
        btst    #2,$dff016              ; Prawy przycisk myszy (RMB)
        beq.s   .advance_state
        move.b  kbd_held_raw,d1         ; Zdekodowany rawkey z input_ctrl.i!
        cmp.b   #$40,d1                 ; Spacja
        beq.s   .advance_state
        cmp.b   #$44,d1                 ; Enter
        bne.w   mainloop

.advance_state:
        move.b  #$ff,kbd_held_raw
        move.b  #$ff,kbd_last_sdr
        clr.b   fire_held            ; Skonsumuj klawisz (brak przeskoku 2 ekranow naraz)
        clr.l   af_state_timer
        move.w  af_state,d0
        addq.w  #1,d0
        cmp.w   #STATE_DEBRIEF,d0
        ble.s   .store_st
        moveq   #STATE_BRIEFING,d0
        addq.w  #1,af_mission
.store_st:
        move.w  d0,af_state
        cmp.w   #STATE_GAMEPLAY,d0
        bne.w   mainloop
        lea     aga_pal256,a0
        move.l  #$00FF3040,252*4(a0)    ; $FC = czerwien bojowa (wrogowie / celownik)
        move.l  #$0020E8FF,253*4(a0)    ; $FD = blekit Eteru (skrzydla / rdzenie)
        move.l  #$00FFD020,254*4(a0)    ; $FE = zloto Solis (emblem / lock-on)
        move.l  #$00FFFFFF,255*4(a0)    ; $FF = czysta biel (napisy / HUD)
        jsr     load_aga_256_palette
        move.b  #1,pal_loaded
        bsr.w   af_init_mission
        bra.w   mainloop

        ; --- TRYB 3D GAMEPLAY (XF-14 Albatros + Teren 3D + Lock-On) ---
.do_gameplay:
        jsr     af_sfx_tick
        bsr.w   af_update_flight
        bsr.w   af_update_entities
        jsr     af_render_gameplay_3d
        jsr     hud_fps_tick

        move.l  af_pos_z,d0
        swap    d0
        cmp.w   af_mission_len,d0
        blo.w   mainloop

        ; W Misji 03 (af_mission == 2) przywolaj Bossa "Lewiatan" przed Debriefingiem
        cmp.w   #2,af_mission
        bne.s   .mission_clear
        tst.b   af_boss_done
        bne.s   .mission_clear
        tst.b   af_boss_active
        bne.w   mainloop
        st      af_boss_done
        jsr     af_init_boss_leviathan
        bra.w   mainloop

.mission_clear:
        moveq   #3,d0
        jsr     copper_set_sky_theme
        clr.l   af_state_timer
        move.w  #STATE_DEBRIEF,af_state
        bra.w   mainloop

shutdown:
        bsr.w   sys_restore
        jsr     af_disk_save_hiscore
exit_program:
        movem.l (sp)+,d0-a6
        moveq   #0,d0
        rts

; ============================================================================
; LOGIKA LOTU MYSLIWCA XF-14 "ALBATROS" + PRZEWIJANIE TERENU 3D
; ============================================================================
        cnop    0,4
af_init_campaign:
        clr.w   af_state
        clr.w   af_mission
        clr.l   af_score
        clr.l   af_state_timer
        rts

        cnop    0,4
af_init_mission:
        clr.l   af_pos_x
        move.l  #140<<16,af_pos_y
        clr.l   af_pos_z
        lea     af_mission_table,a1
        move.w  af_mission,d0
        cmp.w   #2,d0
        ble.s   .m_idx_ok
        moveq   #2,d0
.m_idx_ok:
        lsl.w   #4,d0
        adda.w  d0,a1
        move.w  (a1),d0                 ; vel_z z data/missions.dat
        swap    d0
        clr.w   d0
        move.l  d0,af_vel_z
        move.w  2(a1),af_mission_len    ; dlugosc trasy misji
        move.w  4(a1),d0
        jsr     copper_set_sky_theme
        clr.w   af_roll
        clr.w   af_pitch
        move.w  #64,af_orbit_angle
        move.w  #118,af_orbit_radius
        clr.w   af_ship_dx
        move.w  #56,af_ship_dy
        move.w  #200,af_energy
        clr.w   af_locks
        clr.b   af_boss_active
        clr.b   af_boss_done
        move.w  #80,af_reticle_x
        move.w  #56,af_reticle_y

        lea     af_entities,a0
        moveq   #MAX_ENTITIES-1,d7
        move.w  #400,d1
.spawn_loop:
        move.b  #1,(a0)
        move.w  d7,d0
        and.b   #1,d0
        add.b   d0,d0
        move.b  d0,1(a0)
        clr.b   2(a0)
        move.b  #1,3(a0)
        move.w  d7,d0
        muls.w  #37,d0
        ext.l   d0
        asl.l   #8,d0
        move.l  d0,4(a0)
        move.l  #110<<16,8(a0)
        move.w  d1,d0
        swap    d0
        clr.w   d0
        move.l  d0,12(a0)
        add.w   #550,d1
        lea     16(a0),a0
        dbf     d7,.spawn_loop
        rts

        cnop    0,16
af_update_flight:
        move.w  $dff00c,d0
        move.w  d0,d1
        lsr.w   #1,d1
        eor.w   d0,d1
        move.b  kbd_held_raw,d4
        move.w  af_orbit_angle,d2
        ; Lewo / Prawo: obrot po okregu (0..255)
        btst    #9,d0
        bne.s   .orb_left
        cmp.b   #$4F,d4
        bne.s   .chk_rt
.orb_left:
        addq.w  #5,d2
        bra.s   .ang_ok
.chk_rt:
        btst    #1,d0
        bne.s   .orb_right
        cmp.b   #$4E,d4
        bne.s   .ang_ok
.orb_right:
        subq.w  #5,d2
.ang_ok:
        and.w   #255,d2
        move.w  d2,af_orbit_angle
        ; Gora / Dol: do srodka okregu (Gora) lub na zewnatrz okregu (Dol)
        move.w  af_orbit_radius,d3
        btst    #8,d1
        bne.s   .rad_in
        cmp.b   #$4C,d4
        bne.s   .chk_dn
.rad_in:
        subq.w  #3,d3
        cmp.w   #20,d3
        bge.s   .rad_ok
        moveq   #20,d3
        bra.s   .rad_ok
.chk_dn:
        btst    #0,d1
        bne.s   .rad_out
        cmp.b   #$4D,d4
        bne.s   .rad_ok
.rad_out:
        addq.w  #3,d3
        cmp.w   #144,d3
        ble.s   .rad_ok
        move.w  #144,d3
.rad_ok:
        move.w  d3,af_orbit_radius
        ; Oblicz dx = cos(angle)*radius, dy = sin(angle)*radius z sin_tab
        lea     sin_tab,a0
        move.w  d2,d0
        add.w   d0,d0
        move.w  (a0,d0.w),d5          ; sin(angle) (-256..256)
        add.w   #64,d2
        and.w   #255,d2
        add.w   d2,d2
        move.w  (a0,d2.w),d4          ; cos(angle) (-256..256)
        muls.w  d3,d4
        asr.l   #8,d4
        move.w  d4,af_ship_dx
        moveq   #64,d0
        sub.w   af_orbit_angle,d0
        and.w   #255,d0
        muls.w  #360,d0
        asr.l   #8,d0
        move.w  d0,af_roll            ; kadlub skierowany do srodka okregu (Gyruss!)
        muls.w  d3,d5
        asr.l   #8,d5
        muls.w  #190,d5
        asr.l   #8,d5               ; pelny okrag na calym ekranie!
        move.w  d5,af_ship_dy
        move.w  d5,af_pitch
        ; Przesuwanie kamery wzdluz kanionu 3D
        move.l  af_vel_z,d0
        btst    #7,CIAAPRA
        beq.s   .boost
        tst.b   fire_held
        beq.s   .no_boost
.boost: add.l   d0,d0
.no_boost:
        add.l   d0,af_pos_z
        rts

af_orbit_angle: dc.w 64
af_orbit_radius:dc.w 62
af_ship_dx:     dc.w 0
af_ship_dy:     dc.w 31
af_update_entities:
        lea     af_entities,a0
        move.l  af_pos_z,d4
        moveq   #MAX_ENTITIES-1,d7
.el:
        tst.b   (a0)
        beq.s   .next_e
        move.l  12(a0),d0
        sub.l   d4,d0
        bgt.s   .in_front
        add.l   #6400<<16,12(a0)
        clr.b   2(a0)
        bra.s   .next_e
.in_front:
        swap    d0
        cmp.w   #96,d0
        bgt.s   .next_e
        cmp.b   #2,1(a0)
        bne.s   .lock_target
        add.w   #40,af_energy
        add.l   #250,af_score
        add.l   #6400<<16,12(a0)
        moveq   #SFX_CORE,d0
        jsr     af_trigger_sfx
        bra.s   .next_e
.lock_target:
        tst.b   2(a0)
        bne.s   .next_e
        cmp.w   #8,af_locks
        bge.s   .next_e
        st      2(a0)
        addq.w  #1,af_locks
        moveq   #SFX_LOCKON,d0
        jsr     af_trigger_sfx
.next_e:
        lea     16(a0),a0
        dbf     d7,.el
        rts

; ============================================================================
; MODULY SILNIKA Z refs/aura3d/engine/ ORAZ MODULY GRY
; ============================================================================
        include "gfx_engine.i"
        include "vec3d_engine.i"
        include "scene_player.i"
        include "pt_player.i"
        include "demo_gfx.i"
        include "engine3d_core.i"
        include "c2p_chunky.i"
        include "aura3d_v2.i"
        include "realtime_3d.i"
        include "demo_v2_scene.i"
        include "demo_scenes.i"
        include "particle_trail.i"
        include "copper_sky.i"
        include "input_ctrl.i"
        include "hud_fps.i"
        include "planar_shadow.i"
        include "ground_grid.i"
        include "mirror_reflect.i"
        include "lens_flare.i"
        include "terrain_3d.i"
        include "af_vector_scenes.i"
        include "af_skel_rig.i"
        section code,code
        include "af_disk_loader.i"
        include "af_audio_sfx.i"
        include "af_campaigns.i"
        include "af_fighter_mesh.i"
        include "af_gameplay_3d.i"
        section code,code

; ============================================================================
; ZMIENNE GRY I WSKAZNIKI BITPLANOW AGA
; ============================================================================
        even
af_state:       dc.w    0
af_mission:     dc.w    0
af_mission_len: dc.w    8192
af_boss_reactors_left: dc.w 0
af_boss_active: dc.b    0
af_boss_done:   dc.b    0
        even
af_boss_reactors: ds.b  24
af_particles:   ds.b    10*MAX_PARTICLES
af_roll:        dc.w    0
af_pitch:       dc.w    0
af_energy:      dc.w    200
af_locks:       dc.w    0
af_reticle_x:   dc.w    80
af_reticle_y:   dc.w    56
af_pos_x:       dc.l    0
af_pos_y:       dc.l    0
af_pos_z:       dc.l    0
af_vel_z:       dc.l    0
af_score:       dc.l    0
af_state_timer: dc.l    0
af_fill_lut_ptr:dc.l    0
af_vbr_base:    dc.l    0

        even
disp_bpl1:      dc.l 0
draw_bpl1:      dc.l 0
disp_bpl2:      dc.l 0
draw_bpl2:      dc.l 0
disp_bpl3:      dc.l 0
draw_bpl3:      dc.l 0
disp_bpl4:      dc.l 0
draw_bpl4:      dc.l 0
disp_bpl5:      dc.l 0
draw_bpl5:      dc.l 0
disp_bpl6:      dc.l 0
draw_bpl6:      dc.l 0
disp_bpl7:      dc.l 0
draw_bpl7:      dc.l 0
disp_bpl8:      dc.l 0
draw_bpl8:      dc.l 0
cop_bpl1_ptr:   dc.l 0
cop_bpl2_ptr:   dc.l 0
cop_bpl3_ptr:   dc.l 0
cop_bpl4_ptr:   dc.l 0
cop_bpl5_ptr:   dc.l 0
cop_bpl6_ptr:   dc.l 0
cop_bpl7_ptr:   dc.l 0
cop_bpl8_ptr:   dc.l 0
copper_ptr:     dc.l 0

        section uv_data,data
        even
uv_tex_bank:    incbin "uv_textures.bin"
        even
tunnel_lut:     incbin "tunnel_lut.bin"
        even
aga_pal256:     incbin "pal256.bin"
        even
scroll_font:    ds.b 1024
        even
ptrail_pool:    ds.b 1024

        even
sin_tab:
        dc.w 0,6,13,19,25,31,38,44,50,56,62,68,74,80,86,92
        dc.w 98,104,109,115,121,126,132,137,142,147,152,157,162,167,172,177
        dc.w 181,185,190,194,198,202,206,209,213,216,220,223,226,229,231,234
        dc.w 237,239,241,243,245,247,248,250,251,252,253,254,255,255,256,256
        dc.w 256,256,256,255,255,254,253,252,251,250,248,247,245,243,241,239
        dc.w 237,234,231,229,226,223,220,216,213,209,206,202,198,194,190,185
        dc.w 181,177,172,167,162,157,152,147,142,137,132,126,121,115,109,104
        dc.w 98,92,86,80,74,68,62,56,50,44,38,31,25,19,13,6
        dc.w 0,-6,-13,-19,-25,-31,-38,-44,-50,-56,-62,-68,-74,-80,-86,-92
        dc.w -98,-104,-109,-115,-121,-126,-132,-137,-142,-147,-152,-157,-162,-167,-172,-177
        dc.w -181,-185,-190,-194,-198,-202,-206,-209,-213,-216,-220,-223,-226,-229,-231,-234
        dc.w -237,-239,-241,-243,-245,-247,-248,-250,-251,-252,-253,-254,-255,-255,-256,-256
        dc.w -256,-256,-256,-255,-255,-254,-253,-252,-251,-250,-248,-247,-245,-243,-241,-239
        dc.w -237,-234,-231,-229,-226,-223,-220,-216,-213,-209,-206,-202,-198,-194,-190,-185
        dc.w -181,-177,-172,-167,-162,-157,-152,-147,-142,-137,-132,-126,-121,-115,-109,-104
        dc.w -98,-92,-86,-80,-74,-68,-62,-56,-50,-44,-38,-31,-25,-19,-13,-6
        dc.w 0,6,13,19,25,31,38,44,50,56,62,68,74,80,86,92
        dc.w 98,104,109,115,121,126,132,137,142,147,152,157,162,167,172,177
        dc.w 181,185,190,194,198,202,206,209,213,216,220,223,226,229,231,234
        dc.w 237,239,241,243,245,247,248,250,251,252,253,254,255,255,256,256

        section chip_mod,data_c
        even
mod_data:       incbin "../data/vanguard_anthem.mod"

        section uv_data,data_p
        even
splash_pal_data:
        incbin  "splash_pal.bin"
splash_bpl_rle:
        incbin  "splash_bpl.rle"

        section fastram_bss,bss
        even
        ifd FULL_RES
chunky_buf:     ds.b 320*256
        else
chunky_buf:     ds.b 320*128
        endif
edge_buf:       ds.b 256*40
af_entities:    ds.b 16*MAX_ENTITIES

; ============================================================================
; Szybki blitter pelnoekranowego tla lotniska 256 kol. AGA + sprite motocykla
; ============================================================================
        section code,code
af_blit_airbase_bg:
        movem.l d0-d7/a0-a1,-(sp)
        lea     bg_airbase_gfx,a0
        lea     chunky_buf,a1
        ifd FULL_RES
        move.w  #255,d7
.ab_row:moveq   #19,d6
.ab_col:move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        dbf     d6,.ab_col
        dbf     d7,.ab_row
        else
        moveq   #127,d7
.ab_row:moveq   #19,d6
.ab_col:move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        dbf     d6,.ab_col
        lea     320(a0),a0
        dbf     d7,.ab_row
        endif
        movem.l (sp)+,d0-d7/a0-a1
        rts

; Rysuje przezroczysty sprite motocykla (96x48) w pozycji (d0=X, d1=Y)
af_blit_moto_sprite:
        movem.l d0-d7/a0-a2,-(sp)
        lea     spr_moto_gfx,a0
        lea     chunky_buf,a1
        mulu.w  #320,d1
        add.l   d1,a1
        add.w   d0,a1
        ifd FULL_RES
        moveq   #47,d7
.sm_y:  move.l  a1,a2
        moveq   #95,d6
.sm_x:  move.b  (a0)+,d2
        beq.s   .sm_sk
        move.b  d2,(a2)
.sm_sk: addq.l  #1,a2
        dbf     d6,.sm_x
        lea     320(a1),a1
        dbf     d7,.sm_y
        else
        moveq   #23,d7
.sm_y:  move.l  a1,a2
        moveq   #95,d6
.sm_x:  move.b  (a0)+,d2
        beq.s   .sm_sk
        move.b  d2,(a2)
.sm_sk: addq.l  #1,a2
        dbf     d6,.sm_x
        lea     96(a0),a0
        lea     320(a1),a1
        dbf     d7,.sm_y
        endif
        movem.l (sp)+,d0-d7/a0-a2
        rts

        section fastram_data,data
        cnop    0,4
bg_airbase_gfx:
        incbin  "../data/bg_airbase.bin"
spr_moto_gfx:
        incbin  "../data/spr_moto.bin"
