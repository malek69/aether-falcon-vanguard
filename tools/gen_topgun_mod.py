import math, struct
from pathlib import Path

def make_samples():
    s1 = bytes([int(55 * math.sin(2*math.pi*i/64) + 35 * math.sin(4*math.pi*i/64) + 20 * math.sin(6*math.pi*i/64)) & 0xff for i in range(128)])
    s2 = bytes([int(75 * (1 if (i % 64) < 32 else -1) * 0.6 + 45 * math.sin(2*math.pi*i/64)) & 0xff for i in range(128)])
    s3 = bytearray(1024)
    for i in range(1024):
        env = math.exp(-i / 180.0)
        freq = 140.0 * math.exp(-i / 120.0) + 42.0
        val = int(115 * env * math.sin(2 * math.pi * freq * i / 8287.0))
        s3[i] = max(-128, min(127, val)) & 0xff
    s4 = bytes([int(60 * math.sin(2*math.pi*i/64) + 30 * math.sin(3*2*math.pi*i/64)) & 0xff for i in range(128)])
    return [s1, s2, bytes(s3), s4]

def enc_note(smp, period, eff=0, param=0):
    b0 = (smp & 0xf0) | ((period >> 8) & 0x0f)
    b1 = period & 0xff
    b2 = ((smp & 0x0f) << 4) | (eff & 0x0f)
    b3 = param & 0xff
    return bytes([b0, b1, b2, b3])

P = {"C2":428,"G1":570,"A1":508,"F1":640,"C3":214,"D3":190,"E3":170,"F3":160,"G3":143,"A3":127,"B3":113,"C4":107}
CHORDS = [("C2","C3","E3","G3"), ("G1","G3","B3","D3"), ("A1","A3","C4","E3"), ("F1","F3","A3","C4")]
LEAD = [
    [("C3",0),("G3",4),("G3",8),("F3",12),("E3",14),("D3",16),("E3",20),("C3",24)],
    [("D3",0),("G3",4),("A3",8),("G3",12),("E3",14),("D3",16),("B3",20),("G3",24)],
    [("E3",0),("A3",4),("C4",8),("B3",12),("A3",14),("G3",16),("A3",20),("E3",24)],
    [("F3",0),("A3",4),("C4",8),("B3",12),("A3",14),("G3",16),("G3",20),("D3",24)],
]

def build_mod(out_path):
    smps = make_samples()
    hdr = bytearray(1084)
    hdr[0:20] = b"AETHER FALCON ANTHEM"
    vols = [64, 64, 64, 52]
    reps = [(0, 64), (0, 64), (0, 1), (0, 64)]
    for idx, s in enumerate(smps):
        off = 20 + idx * 30
        hdr[off:off+22] = f"SYNTH_CH_{idx+1}".encode("ascii").ljust(22, b"\x00")
        struct.pack_into(">HBBHH", hdr, off+22, len(s)//2, 0, vols[idx], reps[idx][0], reps[idx][1])
    order = [0, 1, 2, 3, 0, 1, 2, 3]
    hdr[950] = len(order)
    hdr[952:952+len(order)] = bytes(order)
    hdr[1080:1084] = b"M.K."
    pats = bytearray()
    for p_idx in range(4):
        bass_n, a1, a2, a3 = CHORDS[p_idx]
        arp_seq = [a1, a2, a3, a2]
        l_map = {r: n for n, r in LEAD[p_idx]}
        for row in range(64):
            ch0 = enc_note(1, P[l_map[row]]) if row in l_map else (enc_note(0, 0, 0x0f, 5) if row == 0 else enc_note(0, 0))
            ch1 = enc_note(2, P[bass_n]) if (row % 2 == 0) else enc_note(0, 0)
            ch2 = enc_note(3, 214 if (row % 8 == 0) else 143) if (row % 4 == 0) else enc_note(0, 0)
            ch3 = enc_note(4, P[arp_seq[(row // 2) % 4]]) if (row % 2 == 0) else enc_note(0, 0)
            pats.extend(ch0 + ch1 + ch2 + ch3)
    Path(out_path).write_bytes(bytes(hdr) + bytes(pats) + b"".join(smps))
    print("GENERATED_ROYALTY_FREE_MOD:", out_path)

build_mod("data/vanguard_anthem.mod")
