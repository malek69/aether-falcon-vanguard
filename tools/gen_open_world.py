#!/usr/bin/env python3
import argparse, math, os, random, struct

def p_sin(x, y, freq, phase=0.0):
    a = 2.0 * math.pi * freq / 256.0
    return math.sin(x * a + phase) * math.cos(y * a - phase * 0.7)

def toroidal_dist(x1, y1, x2, y2):
    dx = min(abs(x1 - x2), 256 - abs(x1 - x2))
    dy = min(abs(y1 - y2), 256 - abs(y1 - y2))
    return math.sqrt(dx * dx + dy * dy)

def generate_open_world(seed=2026):
    rng = random.Random(seed)
    ph1 = rng.uniform(0.0, 6.28)
    ph2 = rng.uniform(0.0, 6.28)
    ph3 = rng.uniform(0.0, 6.28)
    sea_x = 128
    sea_y = 148

    bases = [(236, 34), (196, 68)]
    while len(bases) < 8:
        cand_x = rng.randint(24, 232)
        cand_y = rng.randint(24, 232)
        if toroidal_dist(cand_x, cand_y, sea_x, sea_y) >= 54.0 and all(toroidal_dist(cand_x, cand_y, bx, by) >= 38.0 for bx, by in bases):
            bases.append((cand_x, cand_y))

    anomalies = [(246, 46), (214, 54)]
    while len(anomalies) < 8:
        ax = rng.randint(20, 236)
        ay = rng.randint(20, 236)
        if toroidal_dist(ax, ay, sea_x, sea_y) >= 52.0 and all(toroidal_dist(ax, ay, bx, by) >= 28.0 for bx, by in bases) and all(toroidal_dist(ax, ay, ox, oy) >= 34.0 for ox, oy in anomalies):
            anomalies.append((ax, ay))

    heights = bytearray(65536)
    colors = bytearray(65536)

    for y in range(256):
        for x in range(256):
            macro = (
                p_sin(x, y, 1.0, ph1) * 32.0 +
                p_sin(x + 50, y - 35, 1.0, ph2) * 24.0 +
                p_sin(x, y, 2.0, ph3) * 13.0
            )
            detail = p_sin(x, y, 4.0, ph1 * 0.5) * 3.0
            h = 33.0 + macro + detail

            d_sea = toroidal_dist(x, y, sea_x, sea_y)
            if d_sea < 48.0:
                blend = max(0.0, min(1.0, (48.0 - d_sea) / 18.0))
                h = h * (1.0 - blend) + 10.0 * blend

            for bx, by in bases:
                dist = toroidal_dist(x, y, bx, by)
                if dist < 24.0:
                    flat_blend = max(0.0, min(1.0, (24.0 - dist) / 12.0))
                    h = h * (1.0 - flat_blend) + 26.0 * flat_blend

            hi = max(8, min(115, int(round(h))))
            idx = (y << 8) | x
            heights[idx] = hi

            if hi <= 13:
                col = 136
            elif hi <= 16:
                col = 187
            elif hi <= 36:
                col = 183
            elif hi <= 58:
                col = 176
            else:
                col = 169
            colors[idx] = col

    # WYPALANIE BAZ KOLONII BEZPOSREDNIO W WOKSELACH (ladowisko + kopula + wieza przekaźnika)
    for bx, by in bases:
        base_h = 26
        for dy in range(-12, 13):
            for dx in range(-12, 13):
                wx = (bx + dx) & 255
                wy = (by + dy) & 255
                idx = (wy << 8) | wx
                r = math.sqrt(dx * dx + dy * dy)
                if r <= 11.5:
                    # Plyta ladowiska ze stali (kolor 148) + zlote znaczniki krawedzi (190)
                    heights[idx] = base_h + 1
                    if 9.8 <= r <= 11.5 and ((dx + dy) % 3 == 0):
                        colors[idx] = 190
                    elif abs(dx) <= 1 or abs(dy) <= 1:
                        colors[idx] = 152
                    else:
                        colors[idx] = 147
                # Glowna kopula bazy przesunieta lekko na bok ladowiska (dx + 4, dy + 4)
                dr = math.sqrt((dx + 4) ** 2 + (dy + 4) ** 2)
                if dr <= 4.5:
                    dome_h = int(round(14.0 * math.sqrt(max(0.0, 1.0 - (dr / 4.8) ** 2))))
                    heights[idx] = base_h + 2 + dome_h
                    colors[idx] = 158 if dr > 1.3 else 191
                # Wieza antenowa po drugiej stronie (dx - 5, dy - 4)
                if abs(dx - 5) <= 1 and abs(dy - 4) <= 1:
                    heights[idx] = base_h + 18 if (dx == 5 and dy == 4) else base_h + 8
                    colors[idx] = 191 if (dx == 5 and dy == 4) else 150

    # WYPALANIE KRYSZTALOW ANOMALII AETHERU BEZPOSREDNIO W WOKSELACH
    for ax, ay in anomalies:
        ground_h = heights[((ay & 255) << 8) | (ax & 255)]
        for dy in range(-5, 6):
            for dx in range(-5, 6):
                wx = (ax + dx) & 255
                wy = (ay + dy) & 255
                idx = (wy << 8) | wx
                r = abs(dx) + abs(dy)
                if r <= 4:
                    spike = (5 - r) * 4 + (3 if (dx == 0 and dy == 0) else 0)
                    heights[idx] = min(124, ground_h + spike)
                    colors[idx] = 255 if r == 0 else (159 if r <= 2 else 190)

    os.makedirs("data", exist_ok=True)
    open("data/exo_voxel.bin", "wb").write(heights + colors)

    meta = bytearray(struct.pack(">4sI", b"AFWD", seed))
    for bx, by in bases:
        meta.extend(struct.pack(">HHH", bx, by, 0))
    for ax, ay in anomalies:
        meta.extend(struct.pack(">HHH", ax, ay, 0))
    open("data/world_seed.bin", "wb").write(meta)
    print(f"OK: Wypalono 8 baz (ladowiska+kopuly+wieze) i 8 krysztalow bezposrednio w wokselach (SEED={seed})!")

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--seed", type=int, default=2026)
    args = p.parse_args()
    generate_open_world(args.seed)
