#!/usr/bin/env python3
import math, os

# 8 baz kolonii (zgodne z exo_bases w exo_world_objs.i)
BASES = [
    (40, 40), (110, 65), (190, 50), (220, 130),
    (175, 205), (95, 215), (35, 170), (130, 130)
]

def p_sin(x, y, freq, phase=0.0):
    a = 2.0 * math.pi * freq / 256.0
    return math.sin(x * a + phase) * math.cos(y * a - phase * 0.7)

def generate_planet():
    heights = bytearray(65536)
    colors = bytearray(65536)

    for y in range(256):
        for x in range(256):
            # Bardzo szerokie, dlugofalowe uksztaltowanie kontynentow i dolin (freq 1 i 2)
            macro = (
                p_sin(x, y, 1.0, 0.4) * 34.0 +
                p_sin(x + 60, y - 30, 1.0, 1.9) * 26.0 +
                p_sin(x, y, 2.0, 1.1) * 14.0
            )
            # Delikatna rzezba wydm / plaskowyzow (bez ciasnych szpilek)
            detail = p_sin(x, y, 4.0, 0.3) * 3.5

            h = 34.0 + macro + detail

            # Rozlegle Morze Aetheru w centralno-wschodniej czesci mapy
            dx_sea = min(abs(x - 155), 256 - abs(x - 155))
            dy_sea = min(abs(y - 115), 256 - abs(y - 115))
            d_sea = math.sqrt(dx_sea * dx_sea + dy_sea * dy_sea)
            if d_sea < 46.0:
                blend = max(0.0, min(1.0, (46.0 - d_sea) / 18.0))
                h = h * (1.0 - blend) + 10.0 * blend

            # Wyrownanie szerokich, plaskich dolin/plaskowyzow pod 8 baz kolonii
            for bx, by in BASES:
                dx = min(abs(x - bx), 256 - abs(x - bx))
                dy = min(abs(y - by), 256 - abs(y - by))
                dist = math.sqrt(dx * dx + dy * dy)
                if dist < 24.0:
                    flat_blend = max(0.0, min(1.0, (24.0 - dist) / 12.0))
                    h = h * (1.0 - flat_blend) + 26.0 * flat_blend

            hi = max(8, min(115, int(round(h))))
            idx = (y << 8) | x
            heights[idx] = hi

            # Dobor naturalnych biomow do wysokosci
            if hi <= 13:
                col = 136  # Glebokie Morze Aetheru
            elif hi <= 16:
                col = 187  # Zloty piasek wybrzeza
            elif hi <= 36:
                col = 183  # Szeroka rownina pustynna (ochra)
            elif hi <= 58:
                col = 176  # Wzgorza i skarpy kanionu (terakota)
            else:
                col = 169  # Wysokie grzbiety gorskie
            colors[idx] = col

    os.makedirs("data", exist_ok=True)
    open("data/exo_voxel.bin", "wb").write(heights + colors)
    print("OK: Wygenerowano przestronna mape planety data/exo_voxel.bin (131072 B)")

if __name__ == "__main__":
    generate_planet()
