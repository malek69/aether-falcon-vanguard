import math, random, struct
from pathlib import Path

def make_samples():
    rng = random.Random(1993)
    # 1: Rich Supersaw / PWM Lead (256B looped)
    s1 = bytearray(256)
    for i in range(256):
        t = i / 256.0
        saw1 = 2.0 * ((t * 2.0) % 1.0) - 1.0
        saw2 = 2.0 * ((t * 2.0 + 0.17) % 1.0) - 1.0
        sqr  = 1.0 if ((t * 4.0) % 1.0) < 0.35 else -1.0
        v = int(52 * saw1 + 42 * saw2 + 28 * sqr)
        s1[i] = max(-128, min(127, v)) & 0xff

    # 2: Punchy Octave Synth Bass (128B looped)
    s2 = bytearray(128)
    for i in range(128):
        t = i / 128.0
        v = int(78 * math.sin(2 * math.pi * t) + 44 * (1.0 if t < 0.4 else -1.0))
        s2[i] = max(-128, min(127, v)) & 0xff

    # 3: Amiga Kick Drum (1024B one-shot)
    s3 = bytearray(1024)
    phase = 0.0
    for i in range(1024):
        env = math.exp(-i / 190.0)
        freq = 165.0 * math.exp(-i / 95.0) + 44.0
        phase += 2.0 * math.pi * freq / 8287.0
        v = int(122 * env * math.sin(phase))
        s3[i] = max(-128, min(127, v)) & 0xff

    # 4: Crispy White-Noise Snare Drum (1280B one-shot)
    s4 = bytearray(1280)
    for i in range(1280):
        env = math.exp(-i / 240.0)
        tone = math.sin(2.0 * math.pi * 195.0 * i / 8287.0) * math.exp(-i / 80.0)
        noise = rng.uniform(-1.0, 1.0)
        v = int(115 * env * (0.75 * noise + 0.25 * tone))
        s4[i] = max(-128, min(127, v)) & 0xff

    # 5: Metallic Hi-Hat (384B one-shot)
    s5 = bytearray(384)
    for i in range(384):
        env = math.exp(-i / 55.0)
        v = int(95 * env * rng.uniform(-1.0, 1.0))
        s5[i] = max(-128, min(127, v)) & 0xff

    # 6: Warm Demoscene Chord Pad (256B looped)
    s6 = bytearray(256)
    for i in range(256):
        t = i / 256.0
        v = int(58 * math.sin(2*math.pi*t) + 34 * math.sin(4*math.pi*t) + 22 * math.sin(6*math.pi*t))
        s6[i] = max(-128, min(127, v)) & 0xff

    return [bytes(s1), bytes(s2), bytes(s3), bytes(s4), bytes(s5), bytes(s6)]

def enc_note(smp, period, eff=0, param=0):
    b0 = (smp & 0xf0) | ((period >> 8) & 0x0f)
    b1 = period & 0xff
    b2 = ((smp & 0x0f) << 4) | (eff & 0x0f)
    b3 = param & 0xff
    return bytes([b0, b1, b2, b3])

P = {
    "A1":508,"C2":428,"D2":381,"E2":339,"F2":320,"G2":285,
    "A2":254,"B2":226,"C3":214,"D3":190,"E3":170,"F3":160,"G3":143,
    "A3":127,"B3":113,"C4":107,"D4":95,"E4":85
}

# 8 patterns: Intro Fanfare (0-1), Main Theme (2-5), Boss Assault (6-7)
PROG = [
    ("A1", "A2", 0x37, [("E3",0),("A3",6),("B3",10),("C4",14),("B3",20),("A3",24),("E3",28)]),
    ("F1" if False else "F2", "F2", 0x47, [("F3",0),("A3",6),("C4",10),("D4",14),("C4",20),("A3",24),("G3",28)]),
    ("C2", "C2", 0x47, [("G3",0),("C4",4),("E4",8),("D4",12),("C4",16),("B3",20),("G3",24),("E3",28)]),
    ("G2", "G2", 0x47, [("D3",0),("G3",4),("B3",8),("D4",12),("C4",16),("B3",20),("A3",24),("G3",28)]),
    ("A1", "A2", 0x37, [("A3",0),("C4",4),("E4",8),("D4",12),("C4",14),("B3",16),("C4",20),("A3",24),("E3",28)]),
    ("F2", "F2", 0x47, [("F3",0),("A3",4),("C4",8),("E4",12),("D4",16),("C4",20),("B3",24),("A3",28)]),
    ("D2", "D2", 0x37, [("D3",0),("F3",2),("A3",4),("D4",6),("C4",8),("A3",10),("F3",12),("D3",14),("E3",16),("G3",18),("B3",20),("E4",22),("D4",24),("B3",26),("G3",28),("E3",30)]),
    ("E2", "E2", 0x47, [("E3",0),("G#3" if False else "A3",2),("B3",4),("E4",6),("D4",8),("B3",10),("A3",12),("E3",14),("G3",16),("B3",18),("D4",20),("E4",22),("D4",24),("B3",26),("A3",28),("E3",30)]),
]

def build_mod(out_path):
    smps = make_samples()
    hdr = bytearray(1084)
    hdr[0:20] = b"AETHER FALCON AGA"
    vols = [64, 62, 64, 60, 46, 48]
    reps = [(0, 128), (0, 64), (0, 1), (0, 1), (0, 1), (0, 128)]
    for idx, s in enumerate(smps):
        off = 20 + idx * 30
        hdr[off:off+22] = f"AGA_SYNTH_{idx+1}".encode("ascii").ljust(22, bytes(1))
        struct.pack_into(">HBBHH", hdr, off+22, len(s)//2, 0, vols[idx], reps[idx][0], reps[idx][1])

    order = [0, 1, 2, 3, 4, 5, 2, 3, 6, 7, 4, 5]
    hdr[950] = len(order)
    hdr[952:952+len(order)] = bytes(order)
    hdr[1080:1084] = b"M.K."

    pat_bytes = bytearray()
    for p_idx, (bass_root, arp_root, arp_param, lead_notes) in enumerate(PROG):
        lead_map = dict((r, n) for n, r in lead_notes)
        for row in range(64):
            r32 = row % 32
            # CH0: Supersaw Lead + Vibrato (04 43)
            if r32 in lead_map:
                pat_bytes += enc_note(1, P[lead_map[r32]], 0x04, 0x43)
            else:
                pat_bytes += enc_note(0, 0, 0x04, 0x43)
            # CH1: Driving 16th-note Octave Bass
            if row % 2 == 0:
                per = P[bass_root] if (row % 4 == 0) else max(113, P[bass_root] // 2)
                pat_bytes += enc_note(2, per, 0, 0)
            else:
                pat_bytes += enc_note(0, 0, 0, 0)
            # CH2: Kick (0, 8, 16, 24) + Snare (4, 12, 20, 28) + Hi-Hat (2, 6, 10...)
            if row % 8 == 0:
                pat_bytes += enc_note(3, 214, 0x0f, 5 if p_idx < 6 else 4)
            elif row % 8 == 4:
                pat_bytes += enc_note(4, 190, 0, 0)
            elif row % 2 == 0:
                pat_bytes += enc_note(5, 143, 0, 0)
            else:
                pat_bytes += enc_note(0, 0, 0, 0)
            # CH3: Classic Amiga Demoscene Fast Arpeggio Chords (0xy)
            if row % 4 == 0:
                pat_bytes += enc_note(6, P[arp_root], 0x00, arp_param)
            else:
                pat_bytes += enc_note(0, 0, 0x00, arp_param)

    Path(out_path).write_bytes(bytes(hdr) + bytes(pat_bytes) + b"".join(smps))
    print(f"Wygenerowano rozbudowany MOD: {out_path} ({Path(out_path).stat().st_size} B, 12 pozycji)")

if __name__ == "__main__":
    build_mod("data/vanguard_anthem.mod")
