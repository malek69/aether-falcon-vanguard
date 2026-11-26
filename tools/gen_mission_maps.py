import os, numpy as np

N = 128

def fbm_torus(seed, octaves=(2, 4, 8, 16), weights=(0.45, 0.30, 0.16, 0.09)):
    rng = np.random.default_rng(seed)
    y, x = np.mgrid[0:N, 0:N].astype(np.float64)
    u = 2.0 * np.pi * x / N
    v = 2.0 * np.pi * y / N
    acc = np.zeros((N, N), dtype=np.float64)
    for freq, w in zip(octaves, weights):
        p1, p2, p3, p4 = rng.uniform(0, 2.0 * np.pi, 4)
        layer = (
            np.sin(freq * u + p1) * np.cos(freq * v + p2)
            + 0.5 * np.sin(freq * (u + v) + p3)
            + 0.5 * np.cos(freq * (u - v) + p4)
        ) / 2.0
        acc += w * layer
    acc = (acc - acc.min()) / (acc.max() - acc.min() + 1e-9)
    return acc

def build_m1():
    n = fbm_torus(101, (1, 2, 4, 8, 16), (0.38, 0.28, 0.18, 0.10, 0.06))
    h = np.zeros((N, N), dtype=np.uint8)
    c = np.zeros((N, N), dtype=np.uint8)
    deep = n < 0.42
    reef = (n >= 0.42) & (n < 0.48)
    sand = (n >= 0.48) & (n < 0.56)
    hill = (n >= 0.56) & (n < 0.76)
    peak = n >= 0.76
    h[deep] = 6;  c[deep] = 1
    h[reef] = 7;  c[reef] = 9
    h[sand] = np.clip(8 + ((n[sand] - 0.48) * 50).astype(int), 8, 12);   c[sand] = 2
    h[hill] = np.clip(13 + ((n[hill] - 0.56) * 55).astype(int), 13, 24); c[hill] = 3
    h[peak] = np.clip(25 + ((n[peak] - 0.76) * 45).astype(int), 25, 36); c[peak] = 4
    return h, c

def build_m2():
    n = fbm_torus(202, (2, 4, 8, 16), (0.40, 0.30, 0.20, 0.10))
    y, x = np.mgrid[0:N, 0:N].astype(np.float64)
    v = 2.0 * np.pi * y / N
    meander = 64.0 + 18.0 * np.sin(v) + 8.0 * np.cos(2.0 * v + 0.7)
    dist = np.abs(x - meander)
    # Boczne wawozy erozyjne
    side_gorge = np.abs(np.sin(3.0 * v + 0.4)) * 7.0
    eff_dist = np.maximum(0.0, dist - side_gorge * (n > 0.55))
    h = np.zeros((N, N), dtype=np.uint8)
    c = np.zeros((N, N), dtype=np.uint8)
    river = eff_dist < 7.0
    bank  = (eff_dist >= 7.0) & (eff_dist < 11.0)
    cliff = (eff_dist >= 11.0) & (eff_dist < 26.0)
    ridge = eff_dist >= 26.0
    h[river] = 3; c[river] = 1
    h[bank]  = np.clip(6 + (n[bank] * 6).astype(int), 6, 11); c[bank] = 2
    raw_c = 12.0 + (eff_dist[cliff] - 11.0) * 1.35 + n[cliff] * 8.0
    h[cliff] = np.clip(raw_c.astype(int), 12, 32)
    # Warstwy geologiczne kanionu (ochra vs terakota)
    strata = ((h[cliff] // 4) % 2) == 0
    c[cliff] = np.where(strata, 8, 10)
    raw_r = 32.0 + n[ridge] * 10.0
    h[ridge] = np.clip(raw_r.astype(int), 32, 42)
    c[ridge] = 4
    return h, c

def build_m3():
    n = fbm_torus(303, (2, 4, 8, 16), (0.42, 0.28, 0.18, 0.12))
    y, x = np.mgrid[0:N, 0:N].astype(np.float64)
    v = 2.0 * np.pi * y / N
    tunnel_center = 64.0 + 10.0 * np.sin(v)
    dist = np.abs(x - tunnel_center)
    h = np.zeros((N, N), dtype=np.uint8)
    c = np.zeros((N, N), dtype=np.uint8)
    # Dolina wulkaniczna w centrum (rzeki lawy + obsydian)
    valley = dist < 24.0
    lava = valley & (n < 0.34)
    basalt = valley & (~lava)
    h[lava] = 4; c[lava] = 7
    h[basalt] = np.clip(8 + ((n[basalt] - 0.34) * 22).astype(int), 8, 22); c[basalt] = 5
    # Mury Cytadeli i bastiony po obu stronach tunelu
    wall = ~valley
    wall_h = 26.0 + np.minimum(14.0, (dist[wall] - 24.0) * 0.65) + n[wall] * 4.0
    h[wall] = np.clip(wall_h.astype(int), 26, 42)
    c[wall] = 6
    # Wieze obronne i pylony energetyczne co 16 jednostek wzdluz Z
    tower = (dist >= 22.0) & (dist <= 30.0) & ((y.astype(int) % 16) >= 4) & ((y.astype(int) % 16) <= 9)
    h[tower] = 42
    c[tower] = 11
    return h, c

def main():
    os.makedirs("data", exist_ok=True)
    for idx, fn_builder in [(1, build_m1), (2, build_m2), (3, build_m3)]:
        h, c = fn_builder()
        out = f"data/map_m{idx}.bin"
        with open(out, "wb") as f:
            f.write(h.tobytes() + c.tobytes())
        print(f"Wygenerowano {out}: {os.path.getsize(out)} B (128x128 hmap + cmap)")

if __name__ == "__main__":
    main()
