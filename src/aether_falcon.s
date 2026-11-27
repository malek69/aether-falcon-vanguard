BPL_SIZE equ 40*256
    machine 68040
    section code,code
start:
    movem.l d0-a6,-(sp)
    bsr.w   sys_takeover
    tst.l   d0
    beq.w   exit_program
    lea     aga_pal256,a0
    bsr.w   load_aga_256_palette
    lea     shade_lut_v2,a0
    moveq   #0,d0
.sl_o:
    moveq   #15,d1
    sub.w   d0,d1
    add.w   #98,d1
    move.w  #255,d2
.sl_i:
    move.b  d1,(a0)+
    dbf     d2,.sl_i
    addq.w  #1,d0
    cmp.w   #16,d0
    blt.s   .sl_o
    move.w  #135,cam_alt
    jsr     init_terrain_lut_68040
    jsr     thea1200_init_hw
    jsr     exo_run_title_menu
    jsr     hud_fps_init
mainloop:
    bsr.w   wait_vbl
    jsr     input_update_controls
    jsr     thea1200_read_peripherals
    cmp.b   #$21,kbd_held_raw
    bne.s   .no_sv
    jsr     exo_play_sfx_ping
    jsr     exo_save_game
.no_sv:
    bsr.w   update_flight_360
    bsr.w   render_voxel_3d
    jsr     vec3d_draw_sun_halo
    jsr     vec3d_draw_clouds_360
    jsr     exo_update_and_draw_world
    jsr     vec3d_update_particles
    jsr     exo_draw_ship_and_hud
    clr.w   bbox_x1
    move.w  #319,bbox_x2
    clr.w   bbox_y1
    move.w  #255,bbox_y2
    jsr     c2p_160x128_to_aga
    jsr     hud_fps_tick
    jsr     hud_draw_overlay
    btst    #6,CIAAPRA
    beq.s   shutdown
    cmp.b   #$75,$bfec01
    bne.w   mainloop
shutdown:
    bsr.w   sys_restore
exit_program:
    movem.l (sp)+,d0-a6
    moveq   #0,d0
    rts
update_flight_360:
    move.w  user_yaw,d0
    and.w   #255,d0
    move.w  d0,d1
    sub.w   cam_yaw(pc),d1
    ext.w   d1
    asl.w   #2,d1
    move.w  d1,ship_bank
    move.w  d0,cam_yaw
    lea     sin_tab,a0
    add.w   d0,d0
    move.w  (a0,d0.w),d1
    sub.w   #128,d0
    and.w   #510,d0
    move.w  (a0,d0.w),d2
    moveq   #1,d3
    cmp.b   #1,player_role
    bne.s   .r_sp
    moveq   #2,d3
.r_sp:  tst.b   fire_held
    beq.s   .sp_ok
    addq.w  #2,d3
.sp_ok:
    muls.w  d3,d1
    muls.w  d3,d2
    add.l   d1,cam_x
    add.l   d2,cam_y
    move.w  #135,d0
    sub.w   user_pitch,d0
    cmp.w   #75,d0
    bge.s   .al_lo
    moveq   #75,d0
.al_lo:
    cmp.w   #220,d0
    ble.s   .al_hi
    move.w  #220,d0
.al_hi:
    move.w  d0,cam_alt
    rts
af_fill_lut_ptr: dc.l 0
    include "vec3d_engine.i"
    include "terrain_3d.i"
    include "cinematic_fx.i"
    include "thea1200_hw.i"
cam_x:      dc.l 0
cam_y:      dc.l 0
cam_alt:    dc.w 135
cam_yaw:    dc.w 0
ship_bank:  dc.w 0
vx_rx:      dc.l 0
vx_ry:      dc.l 0
vx_sx:      dc.l 0
vx_sy:      dc.l 0
disp_bpl1:  dc.l 0
draw_bpl1:  dc.l 0
disp_bpl2:  dc.l 0
draw_bpl2:  dc.l 0
disp_bpl3:  dc.l 0
draw_bpl3:  dc.l 0
disp_bpl4:  dc.l 0
draw_bpl4:  dc.l 0
disp_bpl5:  dc.l 0
draw_bpl5:  dc.l 0
disp_bpl6:  dc.l 0
draw_bpl6:  dc.l 0
disp_bpl7:  dc.l 0
draw_bpl7:  dc.l 0
disp_bpl8:  dc.l 0
draw_bpl8:  dc.l 0
cop_bpl1_ptr: dc.l 0
cop_bpl2_ptr: dc.l 0
cop_bpl3_ptr: dc.l 0
cop_bpl4_ptr: dc.l 0
cop_bpl5_ptr: dc.l 0
cop_bpl6_ptr: dc.l 0
cop_bpl7_ptr: dc.l 0
cop_bpl8_ptr: dc.l 0
copper_ptr:   dc.l 0
    include "gfx_engine.i"
    include "pt_player.i"
    include "copper_sky.i"
    include "engine3d_core.i"
    include "aura3d_v2.i"
    include "c2p_chunky.i"

grid_enabled: dc.b 0
mirror_enabled: dc.b 0
shadows_enabled: dc.b 0
flare_enabled: dc.b 0
    include "input_ctrl.i"

STATE_GAMEPLAY equ 2
af_state: dc.w 2
scene_timeline_table: dc.l 0,0,0,0
    include "hud_fps.i"
    include "exo_ship_hud.i"
    include "exo_world_objs.i"
    include "exo_menu.i"
    include "exo_save_load.i"
    include "exo_sound.i"
sin_tab:
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
    dc.w 256,256,256,255,255,254,253,252,251,250,248,247,245,243,241,239
    dc.w 237,234,231,229,226,223,220,216,213,209,206,202,198,194,190,185
    dc.w 181,177,172,167,162,157,152,147,142,137,132,126,121,115,109,104
    dc.w 98,92,86,80,74,68,62,56,50,44,38,31,25,19,13,6
    section fastram_data,data
    even
aga_pal256:     incbin "../data/exo_pal256.bin"
    even
exo_voxel_data: incbin "../data/exo_voxel.bin"
    section fastram_bss,bss
    even
chunky_buf:     ds.b 320*256
vx_ybuf:        ds.w 320
edge_buf:       ds.b 256*8

    section chip_mod,data_c
    even
mod_data: incbin "../data/exo_theme.mod"
