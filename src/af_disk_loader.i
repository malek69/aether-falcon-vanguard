; ============================================================================
; AETHER FALCON: VANGUARD - Obsluga dysku twardego (dos.library -> data/)
; Wczytuje dane misji, HISCORE, ekran AGA (title.chk/pal) i audio intro.pcm
; przed wywolaniem sys_takeover!
; ============================================================================
        section code,code

_LVOOpen            equ     -30
_LVOClose           equ     -36
_LVORead            equ     -42
_LVOWrite           equ     -48
MODE_OLDFILE        equ     1005
MODE_NEWFILE        equ     1006

        cnop    0,4
af_disk_load_all:
        movem.l d0-d7/a0-a6,-(sp)
        clr.b   af_has_disk_title
        clr.l   af_intro_pcm_len
        clr.l   af_hiscore

        move.l  4.w,a6
        lea     dos_lib_name(pc),a1
        moveq   #0,d0
        jsr     _LVOOpenLibrary(a6)
        move.l  d0,af_dos_base
        beq.w   .disk_done

        ; 1. Wczytaj data/missions.dat (3 misje x 16 bajtow = 48 bajtow)
        lea     fn_missions(pc),a0
        lea     af_mission_table,a1
        move.l  #48,d0
        bsr.w   af_read_file_to_buf

        ; 2. Wczytaj data/hiscore.dat (4 bajty)
        lea     fn_hiscore(pc),a0
        lea     af_hiscore,a1
        moveq   #4,d0
        bsr.w   af_read_file_to_buf

        ; 3. Wczytaj opcjonalne audio PCM intro (data/intro.pcm -> Chip RAM)
        lea     fn_intro_pcm(pc),a0
        lea     af_intro_pcm_buf,a1
        move.l  #32768,d0
        bsr.w   af_read_file_to_buf
        tst.l   d0
        ble.s   .no_pcm
        and.l   #$fffffffe,d0           ; wyrownaj do slowa dla Pauli
        move.l  d0,af_intro_pcm_len
.no_pcm:

        ; 4. Wczytaj opcjonalny ekran tytulowy AGA (data/title.pal + title.chk)
        lea     fn_title_pal(pc),a0
        lea     af_disk_title_pal,a1
        move.l  #1024,d0
        bsr.w   af_read_file_to_buf
        cmp.l   #1024,d0
        bne.w   .close_dos

        lea     fn_title_chk(pc),a0
        lea     af_disk_title_chk,a1
        move.l  #81920,d0
        bsr.w   af_read_file_to_buf
        cmp.l   #81920,d0
        bne.w   .close_dos
        move.b  #1,af_has_disk_title

        ; 5. Wczytaj bogate mapy terenu 128x128 (data/map_m1..m3.bin -> 3x32KB)
        lea     fn_map_m1(pc),a0
        lea     af_vox_hmap,a1
        move.l  #16384,d0
        bsr.w   af_read_file_to_buf
        lea     fn_map_m1(pc),a0
        lea     af_vox_m1_raw,a1
        move.l  #32768,d0
        bsr.w   af_read_file_to_buf
        cmp.l   #32768,d0
        bne.w   .close_dos
        lea     fn_map_m2(pc),a0
        lea     af_vox_m2_raw,a1
        move.l  #32768,d0
        bsr.w   af_read_file_to_buf
        cmp.l   #32768,d0
        bne.w   .close_dos
        lea     fn_map_m3(pc),a0
        lea     af_vox_m3_raw,a1
        move.l  #32768,d0
        bsr.w   af_read_file_to_buf
        cmp.l   #32768,d0
        bne.w   .close_dos
        move.b  #1,af_has_disk_maps

.close_dos:
        move.l  4.w,a6
        move.l  af_dos_base,a1
        jsr     _LVOCloseLibrary(a6)
        clr.l   af_dos_base

.disk_done:
        movem.l (sp)+,d0-d7/a0-a6
        rts

; Pomocnicza procedura odczytu pliku przez dos.library
; Wejscie: a0 = nazwa pliku, a1 = bufor docelowy, d0.l = max bajtow
; Wyjscie: d0.l = liczba wczytanych bajtow (lub 0 przy braku pliku)
        cnop    0,4
af_read_file_to_buf:
        movem.l d1-d4/a2-a3/a6,-(sp)
        move.l  a1,a2
        move.l  d0,d3
        move.l  af_dos_base,a6
        move.l  a0,d1
        move.l  #MODE_OLDFILE,d2
        jsr     _LVOOpen(a6)
        move.l  d0,d4                   ; uchwyt pliku
        beq.s   .rf_fail

        move.l  d4,d1
        move.l  a2,d2
        jsr     _LVORead(a6)
        move.l  d0,d3                   ; rzeczywista liczba bajtow

        move.l  d4,d1
        jsr     _LVOClose(a6)
        move.l  d3,d0
        bra.s   .rf_exit
.rf_fail:
        moveq   #0,d0
.rf_exit:
        movem.l (sp)+,d1-d4/a2-a3/a6
        rts

; ----------------------------------------------------------------------------
; af_play_intro_pcm: Odtwarza zaladowany data/intro.pcm przez DMA Pauli (CH3)
; ----------------------------------------------------------------------------
        cnop    0,4
af_play_intro_pcm:
        move.l  af_intro_pcm_len,d0
        beq.s   .pcm_ret
        lsr.l   #1,d0                   ; dlugosc w slowach (16-bit)
        cmp.l   #16384,d0
        ble.s   .len_ok
        move.w  #16384,d0
.len_ok:
        lea     $dff000,a0
        move.w  #$0008,$096(a0)         ; wylacz DMA CH3
        move.l  #af_intro_pcm_buf,$0d0(a0)
        move.w  d0,$0d4(a0)             ; AUD3LEN
        move.w  #320,$0d6(a0)           ; ~11025 Hz PAL
        move.w  #64,$0d8(a0)            ; glosnosc max
        move.w  #$8008,$096(a0)         ; wlacz DMA CH3
        move.w  #140,af_sfx_timer       ; czas trwania w ramkach VBL
.pcm_ret:
        rts


; ----------------------------------------------------------------------------
; af_disk_save_hiscore: Zapisuje nowy rekord af_hiscore do data/hiscore.dat
; Wywolywane po sys_restore() przed wyjsciem do AmigaOS / WHDLoad
; ----------------------------------------------------------------------------
        cnop    0,4
af_disk_save_hiscore:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  af_score,d0
        cmp.l   af_hiscore,d0
        ble.s   .sh_done
        move.l  d0,af_hiscore

        move.l  4.w,a6
        lea     dos_lib_name(pc),a1
        moveq   #0,d0
        jsr     _LVOOpenLibrary(a6)
        move.l  d0,af_dos_base
        beq.s   .sh_done

        move.l  d0,a6
        lea     fn_hiscore(pc),a0
        move.l  a0,d1
        move.l  #MODE_NEWFILE,d2
        jsr     _LVOOpen(a6)
        move.l  d0,d4
        beq.s   .sh_close_lib

        move.l  d4,d1
        lea     af_hiscore,a0
        move.l  a0,d2
        moveq   #4,d3
        jsr     _LVOWrite(a6)

        move.l  d4,d1
        jsr     _LVOClose(a6)

.sh_close_lib:
        move.l  4.w,a6
        move.l  af_dos_base,a1
        jsr     _LVOCloseLibrary(a6)
        clr.l   af_dos_base
.sh_done:
        movem.l (sp)+,d0-d7/a0-a6
        rts

dos_lib_name:   dc.b    "dos.library",0
fn_missions:    dc.b    "data/missions.dat",0
fn_hiscore:     dc.b    "data/hiscore.dat",0
fn_intro_pcm:   dc.b    "data/intro.pcm",0
fn_title_pal:   dc.b    "data/title.pal",0
fn_title_chk:   dc.b    "data/title.chk",0
fn_map_m1:      dc.b    "data/map_m1.bin",0
fn_map_m2:      dc.b    "data/map_m2.bin",0
fn_map_m3:      dc.b    "data/map_m3.bin",0
        even

af_dos_base:        dc.l    0
af_hiscore:         dc.l    0
af_intro_pcm_len:   dc.l    0
af_has_disk_title:  dc.b    0
af_has_disk_maps:   dc.b    0
        even

; Domyslna tablica 3 misji (nadpisywana z data/missions.dat jesli plik istnieje)
; Struktura (16B): vel_z.w, length_z.w, sky_theme.w, enemy_hp.w, spawn_step.w, pad(6B)
af_mission_table:
        dc.w    10, 6000, 0, 1, 520, 0, 0, 0     ; Misja 01: Sargas Archipelago
        dc.w    13, 7200, 1, 1, 460, 0, 0, 0     ; Misja 02: Krell Storm Canyon
        dc.w    15, 8400, 2, 2, 420, 0, 0, 0     ; Misja 03: Leviathan Citadel

        section fastram_bss,bss
        even
af_disk_title_pal:  ds.l    256
af_disk_title_chk:  ds.b    81920

        section sfx_chip,data_c
        even
af_intro_pcm_buf:   dcb.b   32768,0
