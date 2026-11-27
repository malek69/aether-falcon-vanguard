#!/usr/bin/env python3
import math, os, random, struct

PERIODS = {
    "C-1":856,"C#1":808,"D-1":762,"D#1":720,"E-1":678,"F-1":640,"F#1":604,"G-1":570,"G#1":538,"A-1":508,"A#1":480,"B-1":453,
    "C-2":428,"C#2":404,"D-2":381,"D#2":360,"E-2":339,"F-2":320,"F#2":302,"G-2":285,"G#2":269,"A-2":254,"A#2":240,"B-2":226,
    "C-3":214,"C#3":202,"D-3":190,"D#3":180,"E-3":170,"F-3":160,"F#3":151,"G-3":143,"G#3":135,"A-3":127,"A#3":120,"B-3":113,
}

def s8(val):
    return max(-127, min(127, int(round(val)))) & 0xFF

def build_samples():
    bass = bytearray()
    for i in range(64):
        ph = 2.0 * math.pi * i / 64.0
        v = 95.0 * math.sin(ph) + 38.0 * math.sin(2.0 * ph) + 14.0 * math.sin(3.0 * ph)
        bass.append(s8(v))

    pad = bytearray()
    for i in range(128):
        ph = 2.0 * math.pi * i / 128.0
        v = 80.0 * math.sin(ph) + 42.0 * math.sin(2.0 * ph + 0.4) + 20.0 * math.cos(3.0 * ph)
        pad.append(s8(v))

    arp = bytearray()
    for i in range(2048):
        env = math.exp(-i / 680.0)
        ph = 2.0 * math.pi * i / 32.0
        mod = math.sin(ph * 2.0) * 1.6 * env
        v = 115.0 * env * math.sin(ph + mod)
        arp.append(s8(v))

    kick = bytearray()
    phase = 0.0
    for i in range(1024):
        env = math.exp(-i / 260.0)
        freq = 0.28 * math.exp(-i / 140.0) + 0.045
        phase += freq
        v = 124.0 * env * math.sin(phase)
        kick.append(s8(v))

    rng = random.Random(2184)
    snare = bytearray()
    for i in range(1024):
        env = math.exp(-i / 210.0)
        noise = rng.uniform(-1.0, 1.0)
        tone = math.sin(2.0 * math.pi * i / 18.0) * 0.35
        snare.append(s8(118.0 * env * (noise * 0.8 + tone)))

    return [
        ("SUB-BASS", bass, 64, 0, 32),
        ("AETHER-PAD", pad, 56, 0, 64),
        ("CRYSTAL-ARP", arp, 60, 0, 1),
        ("ORBIT-KICK", kick, 64, 0, 1),
        ("SOLAR-SNARE", snare, 52, 0, 1),
    ]

def encode_cell(smp, note, fx_cmd=0, fx_arg=0):
    per = PERIODS[note] if note else 0
    b0 = (smp & 0xF0) | ((per >> 8) & 0x0F)
    b1 = per & 0xFF
    b2 = ((smp & 0x0F) << 4) | (fx_cmd & 0x0F)
    b3 = fx_arg & 0xFF
    return bytes((b0, b1, b2, b3))

def build_mod(title, patterns, song_order, out_path):
    samples = build_samples()
    blob = bytearray()
    blob.extend(title.encode("ascii")[:20].ljust(20, bytes(1)))

    for idx in range(31):
        if idx < len(samples):
            name, pcm, vol, rep_st, rep_ln = samples[idx]
            w_len = len(pcm) // 2
            blob.extend(name.encode("ascii")[:22].ljust(22, bytes(1)))
            blob.extend(struct.pack(">HBBHH", w_len, 0, vol, rep_st, rep_ln))
        else:
            blob.extend(bytes(22))
            blob.extend(struct.pack(">HBBHH", 0, 0, 0, 0, 1))

    blob.append(len(song_order))
    blob.append(127)
    order_bytes = bytearray(128)
    for i, p in enumerate(song_order):
        order_bytes[i] = p
    blob.extend(order_bytes)
    blob.extend(b"M.K.")

    for pat in patterns:
        for row in range(64):
            for ch in range(4):
                blob.extend(encode_cell(*pat[row][ch]))

    for _, pcm, _, _, _ in samples:
        blob.extend(pcm)

    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    open(out_path, "wb").write(blob)
    print(f"OK: Wygenerowano {out_path} ({len(patterns)} patternow, {len(blob)} B)")

def make_intro_patterns():
    chords = [
        ("D-1", "D-2", ["D-3", "F-3", "A-3", "D-3", "C-3", "A-2", "F-2", "A-2"]),
        ("A#1", "A#1", ["D-3", "F-3", "A#2", "D-3", "F-3", "A#2", "D-3", "F-3"]),
        ("C-1", "C-2", ["E-3", "G-3", "C-3", "E-3", "G-3", "C-3", "E-3", "G-3"]),
        ("A-1", "A-1", ["C#3", "E-3", "A-2", "C#3", "E-3", "G-3", "E-3", "C#3"]),
    ]
    pats = list()
    for p_idx in range(4):
        pat = [[(0, None, 0, 0) for _ in range(4)] for _ in range(64)]
        if p_idx == 0:
            pat[0][3] = (0, None, 0x0F, 7)
        for bar in range(4):
            c_idx = (bar + p_idx) % 4
            b_note, p_note, arp_seq = chords[c_idx]
            r0 = bar * 16
            pat[r0][0] = (1, b_note, 0, 0)
            pat[r0 + 8][0] = (1, b_note, 0x0C, 46)
            pat[r0][1] = (2, p_note, 0, 0)
            for step in range(8):
                pat[r0 + step * 2][2] = (3, arp_seq[step], 0, 0)
            if p_idx >= 1:
                pat[r0][3] = (4, "C-2", 0, 0)
                pat[r0 + 8][3] = (5, "C-2", 0x0C, 28)
        pats.append(pat)
    return pats

def make_world_patterns():
    prog = [
        ("D-1", "F-2", ["D-3", "A-2", "F-2", "A-2", "D-3", "E-3", "F-3", "E-3"]),
        ("C-1", "E-2", ["C-3", "G-2", "E-2", "G-2", "C-3", "D-3", "E-3", "D-3"]),
        ("A#1", "D-2", ["A#2", "F-2", "D-2", "F-2", "A#2", "C-3", "D-3", "C-3"]),
        ("G-1", "D-2", ["A-2", "E-2", "C#2", "E-2", "A-2", "B-2", "C#3", "E-3"]),
    ]
    melodies = [
        [(0,"A-2"),(6,"D-3"),(10,"E-3"),(12,"F-3"),(16,"E-3"),(22,"C-3"),(28,"D-3"),(32,"D-3"),(38,"F-3"),(42,"G-3"),(44,"A-3"),(48,"G-3"),(54,"E-3"),(58,"D-3")],
        [(0,"D-3"),(4,"F-3"),(8,"A-3"),(12,"G-3"),(16,"E-3"),(20,"G-3"),(24,"C-3"),(28,"D-3"),(32,"A#2"),(36,"D-3"),(40,"F-3"),(44,"E-3"),(48,"A-2"),(54,"C#3"),(58,"D-3")],
    ]
    pats = list()
    for p_idx in range(4):
        pat = [[(0, None, 0, 0) for _ in range(4)] for _ in range(64)]
        if p_idx == 0:
            pat[0][3] = (0, None, 0x0F, 6)
        for bar in range(4):
            b_note, p_note, arp_seq = prog[bar]
            r0 = bar * 16
            pat[r0][0] = (1, b_note, 0, 0)
            pat[r0 + 4][0] = (1, b_note, 0x0C, 48)
            pat[r0 + 8][0] = (1, b_note, 0, 0)
            pat[r0 + 12][0] = (1, b_note, 0x0C, 48)
            for step in range(8):
                pat[r0 + step * 2][2] = (3, arp_seq[step], 0x0C, 40)
            pat[r0][3] = (4, "C-2", 0, 0)
            pat[r0 + 4][3] = (5, "C-2", 0, 0)
            pat[r0 + 8][3] = (4, "C-2", 0, 0)
            pat[r0 + 12][3] = (5, "C-2", 0, 0)
            if p_idx in (0, 2):
                pat[r0][1] = (2, p_note, 0, 0)
        if p_idx in (1, 3):
            mel = melodies[0 if p_idx == 1 else 1]
            for r, n in mel:
                pat[r][1] = (2, n, 0, 0)
        pats.append(pat)
    return pats

if __name__ == "__main__":
    build_mod("AETHER-IV PROLOGUE", make_intro_patterns(), [0, 1, 2, 3], "data/exo_intro.mod")
    build_mod("VANGUARD FRONTIER", make_world_patterns(), [0, 1, 2, 3], "data/exo_theme.mod")
