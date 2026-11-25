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
        bsr.w   sys_takeover
        tst.l   d0
        beq.w   exit_program

        move.l  #0,vbl_tick
        jsr     hud_fps_init
        bsr.w   init_fill_lut
        jsr     terrain_3d_init
        bsr.w   af_init_campaign

        cnop    0,16
mainloop:
        bsr.w   wait_vbl
        jsr     input_update_controls

        btst    #6,CIAAPRA
        beq.w   shutdown
        cmp.b   #$75,$bfec01
        beq.w   shutdown

        move.w  af_state,d0
        cmp.w   #STATE_GAMEPLAY,d0
        beq.w   .do_gameplay

        bsr.w   clear_draw_bpl
        move.l  draw_bpl3,a0
        bsr.w   blit_clear_full
        bsr.w   wait_blitter

        move.w  af_state,d0
        cmp.w   #STATE_DEBRIEF,d0
        bne.s   .set_vec_frm
        moveq   #2,d0
.set_vec_frm:
        move.w  d0,cur_frame
        jsr     af_play_vector_frame
        jsr     hud_fps_tick

        addq.l  #1,af_state_timer
        cmp.l   #25,af_state_timer
        blo.w   mainloop
        btst    #7,CIAAPRA
        beq.s   .advance_state
        cmp.b   #$7F,$bfec01
        bne.w   mainloop

.advance_state:
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
        bsr.w   af_init_mission
        bra.w   mainloop

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
        move.w  #160,af_reticle_x
        move.w  #64,af_reticle_y

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

        move.w  af_roll,d2
        btst    #9,d0
        beq.s   .chk_rt
        sub.w   #12,d2
        cmp.w   #-128,d2
        bge.s   .roll_ok
        move.w  #-128,d2
        bra.s   .roll_ok
.chk_rt:
        btst    #1,d0
        beq.s   .damp_roll
        add.w   #12,d2
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
        beq.s   .chk_dn
        sub.w   #8,d2
        bra.s   .pitch_ok
.chk_dn:
        btst    #0,d1
        beq.s   .damp_pitch
        add.w   #8,d2
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
        bra.s   .next_e
.lock_target:
        tst.b   2(a0)
        bne.s   .next_e
        cmp.w   #8,af_locks
        bge.s   .next_e
        st      2(a0)
        addq.w  #1,af_locks
.next_e:
        lea     16(a0),a0
        dbf     d7,.el
        rts

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
        include "af_audio_sfx.i"
        include "af_campaigns.i"
        include "af_fighter_mesh.i"
        include "af_gameplay_3d.i"
        section code,code
        section code,code

        even
af_state:       dc.w    0
af_mission:     dc.w    0
af_roll:        dc.w    0
af_pitch:       dc.w    0
af_energy:      dc.w    200
af_locks:       dc.w    0
af_reticle_x:   dc.w    160
af_reticle_y:   dc.w    64
af_pos_x:       dc.l    0
af_pos_y:       dc.l    0
af_pos_z:       dc.l    0
af_vel_z:       dc.l    0
af_score:       dc.l    0
af_state_timer: dc.l    0

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
