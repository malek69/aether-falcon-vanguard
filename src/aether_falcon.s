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

        ; 2. Alokacja 512 KB w Fast RAM dla fill_lut (MEMF_PUBLIC|MEMF_FAST|MEMF_CLEAR)
        move.l  4.w,a6
        move.l  #524288,d0
        move.l  #$00010005,d1
        jsr     -198(a6)
        move.l  d0,af_fill_lut_ptr
        beq.w   exit_program

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
        lea     aga_pal256,a0
        move.l  #$00FF3040,252*4(a0)    ; $FC = czerwien bojowa (wrogowie / celownik)
        move.l  #$0020E8FF,253*4(a0)    ; $FD = blekit Eteru (skrzydla / rdzenie)
        move.l  #$00FFD020,254*4(a0)    ; $FE = zloto Solis (emblem / lock-on)
        move.l  #$00FFFFFF,255*4(a0)    ; $FF = czysta biel (napisy / HUD)
        jsr     load_aga_256_palette
        move.b  #1,pal_loaded
        jsr     hud_fps_init
        clr.b   info_visible
        bsr.w   init_fill_lut
        jsr     terrain_3d_init
        bsr.w   af_init_campaign

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
        clr.b   kbd_held_raw            ; Skonsumuj klawisz (brak przeskoku 2 ekranow naraz)
        clr.l   af_state_timer
        move.w  af_state,d0
        addq.w  #1,d0
        cmp.w   #STATE_DEBRIEF,d0
        ble.s   .store_st
        clr.w   d0
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
        cmp.w   #8192,d0
        blo.w   mainloop

        clr.l   af_state_timer
        move.w  #STATE_DEBRIEF,af_state
        bra.w   mainloop

shutdown:
        bsr.w   sys_restore
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
        moveq   #10,d0
        add.w   af_mission,d0
        add.w   af_mission,d0
        swap    d0
        clr.w   d0
        move.l  d0,af_vel_z
        clr.w   af_roll
        clr.w   af_pitch
        move.w  #200,af_energy
        clr.w   af_locks
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
        move.w  af_roll,d2
        btst    #9,d0
        bne.s   .do_left
        cmp.b   #$4F,d4                 ; Kursor Lewo
        bne.s   .chk_rt
.do_left:
        sub.w   #14,d2
        cmp.w   #-128,d2
        bge.s   .roll_ok
        move.w  #-128,d2
        bra.s   .roll_ok
.chk_rt:
        btst    #1,d0
        bne.s   .do_right
        cmp.b   #$4E,d4                 ; Kursor Prawo
        bne.s   .damp_roll
.do_right:
        add.w   #14,d2
        cmp.w   #128,d2
        ble.s   .roll_ok
        move.w  #128,d2
        bra.s   .roll_ok
.damp_roll:
        move.w  d2,d3
        asr.w   #3,d3
        sub.w   d3,d2
.roll_ok:
        move.w  d2,af_roll
        ext.l   d2
        asl.l   #8,d2
        add.l   d2,af_pos_x

        move.w  af_roll,d0
        asr.w   #2,d0
        move.w  d0,user_yaw

        move.w  af_pitch,d2
        btst    #8,d1
        bne.s   .do_up
        cmp.b   #$4C,d4                 ; Kursor Gora
        bne.s   .chk_dn
.do_up:
        sub.w   #10,d2
        bra.s   .pitch_ok
.chk_dn:
        btst    #0,d1
        bne.s   .do_down
        cmp.b   #$4D,d4                 ; Kursor Dol
        bne.s   .damp_pitch
.do_down:
        add.w   #10,d2
        bra.s   .pitch_ok
.damp_pitch:
        move.w  d2,d3
        asr.w   #3,d3
        sub.w   d3,d2
.pitch_ok:
        move.w  d2,af_pitch
        move.w  d2,user_pitch

        move.l  af_vel_z,d0
        btst    #7,CIAAPRA
        bne.s   .no_boost
        tst.w   af_energy
        beq.s   .no_boost
        add.l   #8<<16,d0
        subq.w  #1,af_energy
.no_boost:
        add.l   d0,af_pos_z
        move.l  af_pos_z,d1
        move.w  d1,ter_sub_z
        swap    d1
        move.w  d1,ter_scroll_z
        rts

        cnop    0,4
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
        section code,code
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
mod_data:       incbin "demo_tune.mod"

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
