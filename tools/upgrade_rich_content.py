#!/usr/bin/env python3
import math, os, pathlib, random, struct
from tools.png_to_aga import load_aga_palette, nearest_color_idx

# ==============================================================================
# 1. KOMPOZYTOR PROTRACKER .MOD (4 PELNE SCIEZKI NA CALA GRE)
# ==============================================================================
PERIODS = {
    "C-1":856,"C#1":808,"D-1":762,"D#1":720,"E-1":678,"F-1":640,"F#1":604,"G-1":570,"G#1":538,"A-1":508,"A#1":480,"B-1":453,
    "C-2":428,"C#2":404,"D-2":381,"D#2":360,"E-2":339,"F-2":320,"F#2":302,"G-2":285,"G#2":269,"A-2":254,"A#2":240,"B-2":226,
    "C-3":214,"C#3":202,"D-3":190,"D#3":180,"E-3":170,"F-3":160,"F#3":151,"G-3":143,"G#3":135,"A-3":127,"A#3":120,"B-3":113,
}

def s8(val):
    return max(-127, min(127, int(round(val)))) & 0xFF

def build_samples():
    # Bogate, wieloharmoniczne instrumenty Amiga Paula (16-bitowy miks -> 8-bit PCM)
    bass = bytearray()
    for i in range(256):
        ph = 2.0 * math.pi * i / 64.0
        sub = math.sin(ph) * 78.0
        saw = (2.0 * ((i % 64) / 64.0) - 1.0) * 36.0 * math.cos(ph * 0.5)
        warm = math.sin(2.0 * ph + 0.3) * 24.0
        bass.append(s8(sub + saw + warm))

    pad = bytearray()
    for i in range(512):
        ph1 = 2.0 * math.pi * i / 128.0
        ph2 = 2.0 * math.pi * i / 127.2
        v = 54.0 * math.sin(ph1) + 48.0 * math.sin(ph2) + 26.0 * math.sin(2.0 * ph1) + 14.0 * math.cos(3.0 * ph2)
        pad.append(s8(v))

    arp = bytearray()
    for i in range(2048):
        env = math.exp(-i / 680.0)
        ph = 2.0 * math.pi * i / 32.0
        arp.append(s8(116.0 * env * math.sin(ph + math.sin(ph * 2.0) * 1.6 * env)))

    kick = bytearray()
    phase = 0.0
    for i in range(1024):
        env = math.exp(-i / 250.0)
        phase += 0.29 * math.exp(-i / 135.0) + 0.045
        kick.append(s8(124.0 * env * math.sin(phase)))

    rng = random.Random(2184)
    snare = bytearray()
    for i in range(1024):
        env = math.exp(-i / 200.0)
        snare.append(s8(118.0 * env * (rng.uniform(-1.0, 1.0) * 0.8 + math.sin(2.0 * math.pi * i / 18.0) * 0.35)))

    lead = bytearray()
    for i in range(128):
        ph = 2.0 * math.pi * i / 128.0
        sq = 1.0 if math.sin(ph) >= 0 else -1.0
        lead.append(s8(68.0 * sq + 42.0 * math.sin(ph)))

    return [
        ("SUB-BASS", bass, 64, 0, 128),
        ("AETHER-PAD", pad, 56, 0, 256),
        ("CRYSTAL-ARP", arp, 58, 0, 1),
        ("ORBIT-KICK", kick, 64, 0, 1),
        ("SOLAR-SNARE", snare, 52, 0, 1),
        ("VANGUARD-LEAD", lead, 56, 0, 64),
    ]

def encode_cell(smp, note, fx_cmd=0, fx_arg=0):
    per = PERIODS[note] if note else 0
    return bytes(((smp & 0xF0) | ((per >> 8) & 0x0F), per & 0xFF, ((smp & 0x0F) << 4) | (fx_cmd & 0x0F), fx_arg & 0xFF))

def build_mod(title, patterns, song_order, out_path):
    samples = build_samples()
    blob = bytearray(title.encode("ascii")[:20].ljust(20, bytes(1)))
    for idx in range(31):
        if idx < len(samples):
            name, pcm, vol, rep_st, rep_ln = samples[idx]
            blob.extend(name.encode("ascii")[:22].ljust(22, bytes(1)))
            blob.extend(struct.pack(">HBBHH", len(pcm) // 2, 0, vol, rep_st, rep_ln))
        else:
            blob.extend(bytes(22) + struct.pack(">HBBHH", 0, 0, 0, 0, 1))
    blob.append(len(song_order))
    blob.append(127)
    order_bytes = bytearray(128)
    for i, p in enumerate(song_order):
        order_bytes[i] = p
    blob.extend(order_bytes + b"M.K.")
    for pat in patterns:
        for row in range(64):
            for ch in range(4):
                blob.extend(encode_cell(*pat[row][ch]))
    for _, pcm, _, _, _ in samples:
        blob.extend(pcm)
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    open(out_path, "wb").write(blob)
    print(f"OK: {out_path} ({len(patterns)} pat, {len(blob)} B)")

def make_track_patterns(chords, melodies, speed=6, drum_mode=1):
    pats = list()
    for p_idx in range(6):
        pat = [[(0, None, 0, 0) for _ in range(4)] for _ in range(64)]
        if p_idx == 0:
            pat[0][0] = (0, None, 0x0F, speed)
        for bar in range(4):
            b_note, p_note, arp_seq = chords[(bar + (p_idx // 2)) % len(chords)]
            r0 = bar * 16
            pat[r0][0] = (1, b_note, 0, 0)
            pat[r0 + 8][0] = (1, b_note, 0x0C, 46)
            if drum_mode >= 2:
                pat[r0 + 4][0] = (1, b_note, 0x0C, 52)
                pat[r0 + 12][0] = (1, b_note, 0x0C, 52)
            for step in range(8):
                pat[r0 + step * 2][2] = (3, arp_seq[step], 0x0C, 40)
            if drum_mode == 0:
                if p_idx >= 1:
                    pat[r0][3] = (4, "C-2", 0, 0)
                    pat[r0 + 8][3] = (5, "C-2", 0x0C, 26)
            elif drum_mode == 1:
                pat[r0][3] = (4, "C-2", 0, 0)
                pat[r0 + 4][3] = (5, "C-2", 0, 0)
                pat[r0 + 8][3] = (4, "C-2", 0, 0)
                pat[r0 + 12][3] = (5, "C-2", 0, 0)
            else:
                for s in range(0, 16, 4):
                    pat[r0 + s][3] = (4, "C-2", 0, 0)
                    pat[r0 + s + 2][3] = (5, "C-2", 0, 0)
            if p_idx % 2 == 0:
                pat[r0][1] = (2, p_note, 0, 0)
        if p_idx % 2 == 1:
            mel = melodies[(p_idx // 2) % len(melodies)]
            for r, n in mel:
                pat[r][1] = (6, n, 0, 0)
        pats.append(pat)
    return pats

def generate_all_music():
    # Track 0: Prolog / Menu / Epilog (tajemniczy ambient d-moll)
    c0 = [
        ("D-1","D-2",["D-3","F-3","A-3","D-3","C-3","A-2","F-2","A-2"]),
        ("A#1","A#1",["D-3","F-3","A#2","D-3","F-3","A#2","D-3","F-3"]),
        ("C-1","C-2",["E-3","G-3","C-3","E-3","G-3","C-3","E-3","G-3"]),
        ("A-1","A-1",["C#3","E-3","A-2","C#3","E-3","G-3","E-3","C#3"]),
    ]
    m0 = [[(0,"A-2"),(8,"D-3"),(16,"F-3"),(24,"E-3"),(32,"C-3"),(40,"D-3"),(48,"A-2"),(56,"D-2")]]
    build_mod("AETHER-IV PROLOGUE", make_track_patterns(c0, m0, speed=7, drum_mode=0), [0,1,2,3,4,5], "data/exo_intro.mod")

    # Track 1: Akt I - Przyczolek Kolonii (eksploracja)
    c1 = [
        ("D-1","F-2",["D-3","A-2","F-2","A-2","D-3","E-3","F-3","E-3"]),
        ("C-1","E-2",["C-3","G-2","E-2","G-2","C-3","D-3","E-3","D-3"]),
        ("A#1","D-2",["A#2","F-2","D-2","F-2","A#2","C-3","D-3","C-3"]),
        ("G-1","D-2",["A-2","E-2","C#2","E-2","A-2","B-2","C#3","E-3"]),
    ]
    m1 = [
        [(0,"A-2"),(6,"D-3"),(10,"E-3"),(12,"F-3"),(16,"E-3"),(22,"C-3"),(28,"D-3"),(32,"D-3"),(38,"F-3"),(42,"G-3"),(44,"A-3"),(48,"G-3"),(54,"E-3"),(58,"D-3")],
        [(0,"D-3"),(4,"F-3"),(8,"A-3"),(12,"G-3"),(16,"E-3"),(20,"G-3"),(24,"C-3"),(28,"D-3"),(32,"A#2"),(36,"D-3"),(40,"F-3"),(44,"E-3"),(48,"A-2"),(54,"C#3"),(58,"D-3")],
    ]
    build_mod("ACT I LANDFALL", make_track_patterns(c1, m1, speed=6, drum_mode=1), [0,1,2,3,4,5], "data/exo_theme.mod")

    # Track 2: Akt II - Puls Aetheru (tajemnica i napiecie a-moll / f-moll)
    c2 = [
        ("A-1","C-2",["A-2","E-3","C-3","E-3","A-3","G-3","E-3","C-3"]),
        ("F-1","A-1",["F-2","C-3","A-2","C-3","F-3","E-3","C-3","A-2"]),
        ("G-1","B-1",["G-2","D-3","B-2","D-3","G-3","F-3","D-3","B-2"]),
        ("E-1","G#1",["E-2","B-2","G#2","B-2","E-3","D-3","B-2","G#2"]),
    ]
    m2 = [
        [(0,"E-3"),(4,"A-3"),(8,"G-3"),(12,"E-3"),(16,"F-3"),(20,"A-3"),(24,"G-3"),(28,"F-3"),(32,"D-3"),(36,"G-3"),(40,"F-3"),(44,"D-3"),(48,"E-3"),(56,"B-2")],
        [(0,"A-3"),(6,"G-3"),(12,"E-3"),(16,"C-3"),(22,"D-3"),(28,"E-3"),(32,"B-2"),(38,"D-3"),(44,"F-3"),(48,"E-3"),(56,"A-2")],
    ]
    build_mod("ACT II ANOMALY", make_track_patterns(c2, m2, speed=5, drum_mode=2), [0,1,2,3,4,5], "data/exo_act2.mod")

    # Track 3: Akt III - Decyzja Awangardy (epicki final)
    c3 = [
        ("D-1","A-1",["D-3","A-3","F-3","A-3","D-3","A-3","G-3","A-3"]),
        ("A#1","F-2",["A#2","F-3","D-3","F-3","A#2","F-3","E-3","F-3"]),
        ("G-1","D-2",["G-2","D-3","A#2","D-3","G-2","D-3","C-3","D-3"]),
        ("A-1","E-2",["A-2","E-3","C#3","E-3","A-2","G-3","E-3","C#3"]),
    ]
    m3 = [
        [(0,"D-3"),(4,"A-3"),(8,"G-3"),(10,"F-3"),(12,"E-3"),(16,"F-3"),(20,"A#3"),(24,"A-3"),(28,"F-3"),(32,"G-3"),(36,"A#3"),(40,"A-3"),(44,"G-3"),(48,"A-3"),(54,"C#3"),(58,"D-3")],
    ]
    build_mod("ACT III VANGUARD", make_track_patterns(c3, m3, speed=5, drum_mode=2), [0,1,2,3,4,5], "data/exo_act3.mod")

# ==============================================================================
# 2. BANK 6 POSTACI SCI-FI AGA (6 x 48x58 px = 16704 B)
# ==============================================================================
def generate_6_portraits():
    pal = load_aga_palette("data/exo_pal256.bin")
    def px(r, g, b):
        return nearest_color_idx(max(0, min(255, int(r))), max(0, min(255, int(b))), max(0, min(255, int(b))), pal, min_idx=1)

    styles = [
        # (bg1, bg2, suit, helmet/hair, visor, visor_hi)
        ((14,24,42), (22,42,70), (48,96,148), (160,175,198), (45,225,255), (235,250,255)),   # 0: Komandor Vance
        ((28,18,22), (48,28,32), (155,78,48), (72,44,38),    (250,165,45), (255,240,180)),   # 1: Dr Elena Rostova
        ((16,30,26), (26,48,40), (62,128,86), (165,132,88),  (75,240,130), (220,255,230)),   # 2: Zwiadowca Kael
        ((18,28,36), (30,48,60), (175,185,195),(55,65,80),   (80,245,220), (235,255,250)),   # 3: Dr Aris Thorne (Ksenobiolog)
        ((32,16,18), (54,24,28), (110,36,42), (60,64,72),    (255,70,70),  (255,200,190)),   # 4: Kpt. Marcus Mercer (Ochrona)
    ]

    all_p = bytearray()
    for pid in range(6):
        w, h = 48, 58
        buf = bytearray(w * h)
        for y in range(h):
            for x in range(w):
                if pid == 5:
                    # 5: Krystaliczny Rdzen Aetheru
                    cx, cy = x - 23.5, y - 28.5
                    rad = math.sqrt(cx*cx + cy*cy)
                    ang = math.atan2(cy, cx)
                    pulse = math.sin(rad * 0.45 - ang * 3.0) * 65.0
                    r = 45 + max(0.0, pulse) * 1.5
                    g = 115 + math.cos(rad * 0.35) * 85.0
                    b = 185 + math.sin(ang * 4.0) * 65.0
                    if rad < 9.0:
                        r, g, b = 230, 252, 255
                    if x == 0 or x == w - 1 or y == 0 or y == h - 1:
                        r, g, b = 120, 240, 255
                    buf[y * w + x] = px(r, g, b)
                    continue

                bg1, bg2, suit, helm, vis, vhi = styles[pid]
                r, g, b = bg1 if y % 6 else bg2
                dx = (x - 23.5) / 14.0
                dy = (y - 23.0) / 17.0
                dist_head = dx*dx + dy*dy

                if y >= 38:
                    sh_w = 13.0 + (y - 38) * 0.65
                    if abs(x - 23.5) <= sh_w:
                        shade = 1.0 - abs(x - 23.5) / (sh_w + 4.0) * 0.55
                        r, g, b = suit[0]*shade, suit[1]*shade, suit[2]*shade
                        if 41 <= y <= 44 and (8 <= x <= 14 or 33 <= x <= 39):
                            r, g, b = 235, 175, 58
                        if 21 <= x <= 26:
                            r, g, b = 26, 36, 52

                if 34 <= y <= 40 and 19 <= x <= 28:
                    r, g, b = 125, 88, 68

                if dist_head <= 1.0:
                    light = max(0.35, min(1.25, 0.95 - dx * 0.45 - dy * 0.25))
                    if y < 17 or abs(x - 23.5) > 10.5:
                        r, g, b = helm[0]*light, helm[1]*light, helm[2]*light
                    else:
                        r, g, b = 212*light, 156*light, 118*light

                if 19 <= y <= 23 and 13 <= x <= 34:
                    glow = 1.0 - abs(x - 23.5) / 14.0 * 0.35
                    r, g, b = vis[0]*glow, vis[1]*glow, vis[2]*glow
                    if y == 20:
                        r, g, b = vhi

                if x == 0 or x == w - 1 or y == 0 or y == h - 1:
                    r, g, b = 68, 165, 215
                buf[y * w + x] = px(r, g, b)
        all_p.extend(buf)
    pathlib.Path("data/exo_portrait.bin").write_bytes(all_p)
    print(f"OK: Wygenerowano 6 portretow postaci AGA ({len(all_p)} B)")

# ==============================================================================
# 3. ROZBUDOWANA FABULA NA CALA GRE (83 WPISY PL + EN <= 40 ZNAKOW)
# ==============================================================================
def update_story():
    bs_p = pathlib.Path("tools/build_story.py")
    bs = bs_p.read_text(encoding="utf-8")
    sector_lore = """    # 75..82 Unikalne transmisje 8 sektorow w terenie
    ("HELIOS: TU ZACZĘŁA SIĘ KOLONIZACJA.", "HELIOS: WHERE COLONIZATION BEGAN."),
    ("KANION: SILNE ECHA POD SKORUPĄ.", "CANYON: STRONG SUBCRUST ECHOES."),
    ("HYDRO-03: WODA ZAWIERA CZĄSTKI AETHERU.", "HYDRO-03: WATER CARRIES AETHER IONS."),
    ("GRAŃ: ANTENY ODBIERAJĄ SYGNAŁ Z GŁĘBI.", "RIDGE: DISHES DETECT DEEP PULSES."),
    ("DOLINA: KRYSZTAŁY ROSNĄ W KWARCU.", "VALLEY: CRYSTALS GROW IN QUARTZ."),
    ("BETA: GÓRNICY DOTARLI DO KOMORY.", "BETA: MINERS BREACHED THE CHAMBER."),
    ("PRZEKAŹNIK: ORBITA BLOKUJE TRANSMISJĘ.", "RELAY: ORBIT BLOCKS TRANSMISSION."),
    ("ARKA: SERCE CAŁEJ SIECI AETHER-IV.", "ARK: HEART OF THE AETHER-IV GRID."),
]"""
    if "HELIOS: TU ZACZĘŁA" not in bs:
        bs = bs.replace(chr(10) + "]" + chr(10)*2 + "def compile_lang", chr(10) + sector_lore + chr(10)*2 + "def compile_lang")
        bs_p.write_text(bs, encoding="utf-8")

# ==============================================================================
# 4. PODPIECIE 4 SCIEZEK MUZYCZNYCH DO AKTOW I 3D KRYSZTALOW ANOMALII W TERENIE
# ==============================================================================
def wire_engine():
    # exo_sound.i: 4 bufory Fast RAM dla 4 utworow .MOD
    snd_asm = """        section code,code

audio_load_tracks_hdd:
        movem.l d0-d7/a0-a6,-(sp)
        move.l  4.w,a6
        lea     snd_dos_name(pc),a1
        moveq   #0,d0
        jsr     -552(a6)
        move.l  d0,a6
        tst.l   d0
        beq.w   .al_end

        lea     mod_path_0(pc),a2
        lea     mod_buf_0,a3
        moveq   #3,d7
.tr_lp: move.l  a2,d1
        move.l  #1005,d2
        jsr     -30(a6)
        move.l  d0,d4
        beq.s   .tr_nx
        move.l  d4,d1
        move.l  a3,d2
        move.l  #24576,d3
        jsr     -42(a6)
        move.l  d4,d1
        jsr     -36(a6)
.tr_nx: adda.w  #20,a2
        adda.l  #24576,a3
        dbf     d7,.tr_lp

        move.l  a6,a1
        move.l  4.w,a6
        jsr     -414(a6)
.al_end:movem.l (sp)+,d0-d7/a0-a6
        rts

; d0.w = 0 (Intro/Epilog), 1 (Akt I), 2 (Akt II), 3 (Akt III)
audio_switch_track:
        movem.l d0-d1/a0-a1,-(sp)
        and.w   #3,d0
        cmp.b   current_track_id(pc),d0
        beq.s   .sw_dn
        move.b  d0,current_track_id
        mulu.w  #24576,d0
        lea     mod_buf_0,a0
        add.l   d0,a0
        lea     mod_data,a1
        move.w  #6143,d1
.cp_lp: move.l  (a0)+,(a1)+
        dbf     d1,.cp_lp
        jsr     pt_init
.sw_dn: movem.l (sp)+,d0-d1/a0-a1
        rts

exo_play_sfx_ping:
        movem.l d0-d1/a0,-(sp)
        lea     $dff000,a0
        move.w  #$0008,$96(a0)
        move.l  #exo_sfx_chime,$d0(a0)
        move.w  #128,$d4(a0)
        move.w  #175,$d6(a0)
        move.w  #60,$d8(a0)
        move.w  #$8008,$96(a0)
        movem.l (sp)+,d0-d1/a0
        rts

exo_play_sfx_scan:
        movem.l d0-d1/a0,-(sp)
        lea     $dff000,a0
        move.w  #$0008,$96(a0)
        move.l  #exo_sfx_beam,$d0(a0)
        move.w  #64,$d4(a0)
        move.w  #260,$d6(a0)
        move.w  #44,$d8(a0)
        move.w  #$8008,$96(a0)
        movem.l (sp)+,d0-d1/a0
        rts

snd_dos_name:   dc.b "dos.library",0
        even
mod_path_0:     dc.b "data/exo_intro.mod",0,0
mod_path_1:     dc.b "data/exo_theme.mod",0,0
mod_path_2:     dc.b "data/exo_act2.mod",0,0,0
mod_path_3:     dc.b "data/exo_act3.mod",0,0,0
current_track_id: dc.b 255,0

        section sfx_chip,data_c
        even
exo_sfx_chime:
        dc.b 0,35,68,96,116,126,124,110,86,54,18,-20,-56,-88,-112,-124
        dc.b -126,-116,-96,-68,-35,0,35,68,96,116,126,124,110,86,54,18
        dc.b 0,48,90,118,126,110,72,22,-32,-80,-114,-126,-114,-80,-32,22
        dc.b 72,110,126,118,90,48,0,-48,-90,-118,-126,-110,-72,-22,32,80
        dcb.b 192,0
exo_sfx_beam:
        dc.b 0,60,110,126,95,30,-45,-105,-126,-90,-20,55,115,124,80,10
        dc.b -65,-118,-122,-70,5,75,122,115,55,-20,-90,-126,-105,-45,30,95
        dcb.b 96,0

        section fastram_bss,bss
        even
mod_buf_0:      ds.b 24576
mod_buf_1:      ds.b 24576
mod_buf_2:      ds.b 24576
mod_buf_3:      ds.b 24576
        section code,code
"""
    pathlib.Path("src/exo_sound.i").write_text(snd_asm, encoding="ascii")

    # story_engine.i: automatyczna zmiana sciezki muzycznej przy zmianie Aktu I -> II -> III
    se_p = pathlib.Path("src/story_engine.i")
    se = se_p.read_text(encoding="ascii")
    if "audio_switch_track" not in se:
        se = se.replace(
            ".act_ok:move.w  d1,story_act_num",
            ".act_ok:move.w  d1,story_act_num" + chr(10) + "        tst.b   intro_turn_done" + chr(10) + "        beq.s   .no_msw" + chr(10) + "        move.w  d1,d0" + chr(10) + "        jsr     audio_switch_track" + chr(10) + ".no_msw:"
        )
        se_p.write_text(se, encoding="ascii")

    # cinematic_fx.i: obsluga 6 portretow (0..5) i przypisanie postaci wg sektora/roli/aktu
    cf_p = pathlib.Path("src/cinematic_fx.i")
    cf = cf_p.read_text(encoding="latin1")
    cf = cf.replace("and.w   #3,d0", "cmp.w   #5,d0" + chr(10) + "        ble.s   .pid_ok" + chr(10) + "        moveq   #5,d0" + chr(10) + ".pid_ok:")
    cf = cf.replace("move.b  #3,cine_portrait_id", "move.b  #5,cine_portrait_id")
    cf_p.write_text(cf, encoding="latin1")

    # open_world.i: renderowanie obracajacego sie 3D krysztalu anomalii w terenie + dzwiek skanera
    ow_p = pathlib.Path("src/open_world.i")
    ow = ow_p.read_text(encoding="ascii")
    if "ow_draw_3d_anomaly" not in ow:
        ow = ow.replace(
            ".an_hit:add.l   #250,colony_credits",
            ".an_hit:jsr     exo_play_sfx_scan" + chr(10) + "        add.l   #250,colony_credits"
        )
        ow = ow.replace(
            "        move.b  #3,cine_portrait_id",
            "        move.b  #5,cine_portrait_id"
        )
        ow = ow.replace(
            ".draw_nav:",
            "        bsr.w   ow_draw_3d_anomaly" + chr(10) + ".draw_nav:"
        )
        crystal_code = """
; Renderuje w 3D obracajacy sie krysztal / sonde anomalii w terenie
ow_draw_3d_anomaly:
        movem.l d0-d7/a0-a3,-(sp)
        move.w  contract_target_x(pc),d0
        move.b  cam_x+2(pc),d1
        ext.w   d1
        sub.w   d1,d0
        ext.w   d0
        move.w  contract_target_y(pc),d1
        move.b  cam_y+2(pc),d2
        ext.w   d2
        sub.w   d2,d1
        ext.w   d1
        lea     sin_tab,a0
        move.w  cam_yaw(pc),d2
        and.w   #255,d2
        add.w   d2,d2
        move.w  (a0,d2.w),d3
        sub.w   #128,d2
        and.w   #510,d2
        move.w  (a0,d2.w),d4
        move.w  d0,d5
        muls.w  d3,d5
        move.w  d1,d6
        muls.w  d4,d6
        add.l   d6,d5
        asr.l   #8,d5
        cmp.w   #12,d5
        blt.w   .an_end
        cmp.w   #115,d5
        bgt.w   .an_end
        muls.w  d3,d1
        muls.w  d4,d0
        sub.l   d0,d1
        asr.l   #8,d1
        cmp.w   #-110,d1
        blt.w   .an_end
        cmp.w   #110,d1
        bgt.w   .an_end
        asl.l   #7,d1
        divs.w  d5,d1
        add.w   #160,d1
        cmp.w   #20,d1
        blt.w   .an_end
        cmp.w   #300,d1
        bgt.w   .an_end

        move.w  d5,d6
        asl.w   #2,d6
        move.w  d1,d4
        sub.w   #160,d4
        muls.w  d6,d4
        asr.l   #8,d4
        moveq   #-10,d5
        muls.w  d6,d5
        asr.l   #8,d5
        sub.w   #150,d6
        move.w  #192,d0
        move.w  vbl_tick+2(pc),d1
        and.w   #255,d1
        move.w  #192,d2
        lea     ow_crystal_v(pc),a0
        lea     ow_crystal_n(pc),a2
        lea     ow_crystal_t(pc),a3
        jsr     vec3d_draw_mesh_3d
.an_end:movem.l (sp)+,d0-d7/a0-a3
        rts

        even
ow_crystal_v:
        dc.w 6
        dc.w    0, -24,   0
        dc.w   11,  -6,   0
        dc.w    0,  -6,  11
        dc.w  -11,  -6,   0
        dc.w    0,  -6, -11
        dc.w    0,  10,   0
ow_crystal_n:
        dc.w    0,-250,   0
        dc.w  250,   0,   0
        dc.w    0,   0, 250
        dc.w -250,   0,   0
        dc.w    0,   0,-250
        dc.w    0, 250,   0
ow_crystal_t:
        dc.w 8
        dc.w  0, 1, 2, 3
        dc.w  0, 2, 3, 3
        dc.w  0, 3, 4, 3
        dc.w  0, 4, 1, 3
        dc.w  5, 2, 1, 1
        dc.w  5, 3, 2, 1
        dc.w  5, 4, 3, 1
        dc.w  5, 1, 4, 1
"""
        ow += crystal_code
        ow_p.write_text(ow, encoding="ascii")

    # Podbicie wersji w tools/build_game.py na v0.2.1.0
    bg_p = pathlib.Path("tools/build_game.py")
    bg = bg_p.read_text(encoding="utf-8")
    bg = bg.replace("v0.1.3.1", "v0.2.1.0")
    bg_p.write_text(bg, encoding="utf-8")

if __name__ == "__main__":
    generate_all_music()
    generate_6_portraits()
    update_story()
    wire_engine()
    print("OK: Kompletny pakiet v0.2.1.0 (4 utwory .MOD, 6 portretow, rozbudowana fabula i krysztaly 3D) gotowy!")
