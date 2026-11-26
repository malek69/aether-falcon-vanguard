import os, struct

# Format pliku binarnego sceny fabularnej data/scene_*.bin:
# Header:
#   magic: "AFSC" (4B)
#   num_acts: uint16
#   palette_rgb: 16 x uint32 (indeksy palety 240..255 dla cieniowania Eon / Another World)
# Dla kazdego aktu:
#   duration_frames: uint16
#   sky_top_idx: uint8, sky_bot_idx: uint8
#   subtitle_len: uint16 + ASCII (padded to even)
#   num_polys: uint16
#   Dla kazdego wielokata:
#     color_idx: uint8, num_verts: uint8
#     verts_start: num_verts x (int16 x, int16 y)   [klatka kluczowa A]
#     verts_end:   num_verts x (int16 x, int16 y)   [klatka kluczowa B -> plynna interpolacja!]

PAL_EON_SUNSET = [
    0x00080C1C, # 240: gleboki granat nocy
    0x00162244, # 241: indygo
    0x002B3A68, # 242: stalowy blekit
    0x00525E8A, # 243: chlodny polcien
    0x008C6A78, # 244: cieply zmierzch
    0x00C87448, # 245: miedziany horyzont
    0x00E89A54, # 246: bursztynowe swiatlo
    0x00FAD07A, # 247: zlote podswietlenie krawedzi (Rim Light)
    0x00101420, # 248: ciemna sylwetka (Cien 1)
    0x001E2638, # 249: pancerz ciemny (Cien 2)
    0x0034425E, # 250: pancerz sredni (Ton 3)
    0x005A7096, # 251: pancerz jasny (Ton 4)
    0x00FF3848, # 252: alarm / czerwony reflektor
    0x0028E8FF, # 253: wizjer HUD / energia Eteru
    0x00FFD430, # 254: zloto / dopalacz
    0x00FFFFFF, # 255: biel blysku
]

def pack_scene(out_path, palette, acts):
    buf = bytearray(b"AFSC")
    buf += struct.pack(">H", len(acts))
    for col in palette:
        buf += struct.pack(">I", col)
    for dur, sky_top, sky_bot, subtitle, polys in acts:
        sub_b = subtitle.encode("ascii", "ignore")
        if len(sub_b) % 2 == 1:
            sub_b += b" "
        buf += struct.pack(">HBBH", dur, sky_top, sky_bot, len(sub_b))
        buf += sub_b
        buf += struct.pack(">H", len(polys))
        for col_idx, v_start, v_end in polys:
            assert len(v_start) == len(v_end) and 3 <= len(v_start) <= 16
            buf += struct.pack(">BB", col_idx, len(v_start))
            for x, y in v_start:
                buf += struct.pack(">hh", x, y)
            for x, y in v_end:
                buf += struct.pack(">hh", x, y)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(buf)
    print(f"Zbudowano modul sceny: {out_path} ({len(buf)} B, {len(acts)} aktow)")

def build_intro_scene():
    # Akt 1: Baza Solis o zmierzchu - pilot patrzy na horyzont, kamera zbliza sie plynnie
    act1_polys = [
        # Pasmo gor w oddali (parallax)
        (241, [(0,165),(55,118),(125,152),(195,112),(265,148),(319,124),(319,175),(0,175)],
              [(0,170),(45,112),(120,150),(190,104),(260,145),(319,118),(319,180),(0,180)]),
        # Plyta lotniska Solis
        (248, [(0,170),(319,170),(319,255),(0,255)],
              [(0,175),(319,175),(319,255),(0,255)]),
        # Sylwetka mysliwca XF-14 na plycie (cel-shaded: kadlub + zloty rim light)
        (249, [(135,168),(215,152),(298,166),(235,182),(145,180)],
              [(115,166),(205,146),(305,164),(230,184),(128,182)]),
        (247, [(135,168),(215,152),(298,166),(285,168),(214,156)],
              [(115,166),(205,146),(305,164),(290,167),(204,151)]),
        # Sylwetka pilota na pierwszym planie (styl Another World / Eon)
        (248, [(42,255),(48,188),(64,162),(82,162),(94,192),(102,255)],
              [(52,255),(58,182),(74,154),(92,154),(106,186),(115,255)]),
        # Zlote podswietlenie krawedzi kasku i ramienia pilota (Eon Rim Light)
        (247, [(76,162),(84,163),(95,192),(90,194),(79,167)],
              [(86,154),(94,155),(107,186),(101,188),(89,160)]),
    ]
    # Akt 2: Kokpit XF-14 - zamykanie opancerzonej owiewki i rozruch HUD
    act2_polys = [
        (241, [(0,0),(319,0),(319,255),(0,255)],
              [(0,0),(319,0),(319,255),(0,255)]),
        # Rama kokpitu opadajaca z gory (klatka A -> klatka B)
        (248, [(0,0),(319,0),(285,35),(35,35)],
              [(0,0),(319,0),(265,95),(55,95)]),
        (250, [(35,35),(285,35),(275,44),(45,44)],
              [(55,95),(265,95),(255,106),(65,106)]),
        # Ekran celownika HUD rozswietlajacy sie w centrum
        (253, [(150,130),(170,130),(170,145),(150,145)],
              [(105,112),(215,112),(215,178),(105,178)]),
        (249, [(112,118),(208,118),(208,172),(112,172)],
              [(112,118),(208,118),(208,172),(112,172)]),
    ]
    # Akt 3: Start XF-14 na dopalaczu w niebo (kamera sledzi wzlot)
    act3_polys = [
        (248, [(0,195),(319,195),(319,255),(0,255)],
              [(0,238),(319,238),(319,255),(0,255)]),
        # Smuga ognia dopalacza
        (254, [(30,198),(125,186),(125,196)],
              [(90,148),(215,112),(205,126)]),
        # Kadlub XF-14 wzbijajacy sie pod katem
        (250, [(115,182),(195,168),(245,180),(180,196)],
              [(195,106),(278,76),(312,92),(248,122)]),
        (247, [(115,182),(195,168),(245,180),(235,183),(194,172)],
              [(195,106),(278,76),(312,92),(302,96),(276,81)]),
    ]
    acts = [
        (160, 240, 245, "SOLIS AIRBASE - DAWN ALERT: VESPERA FLEET INBOUND", act1_polys),
        (140, 240, 242, "XF-14 ALBATROS ONLINE - CANOPY LOCKED, REACTORS HOT", act2_polys),
        (150, 240, 246, "VANGUARD SQUADRON LAUNCH - INTERCEPT COURSE SET", act3_polys),
    ]
    pack_scene("data/scene_intro.bin", PAL_EON_SUNSET, acts)

if __name__ == "__main__":
    build_intro_scene()
