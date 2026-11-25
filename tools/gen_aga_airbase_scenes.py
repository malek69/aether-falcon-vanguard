import struct, math, random
import numpy as np
from PIL import Image, ImageDraw
from pathlib import Path

pal_raw = Path("refs/aura3d/demo_v1/pal256.bin").read_bytes()
pal_rgb = np.zeros((252, 3), dtype=np.int32)
for i in range(1, 252):
    _, r, g, b = struct.unpack(">BBBB", pal_raw[i*4:i*4+4])
    pal_rgb[i] = [r, g, b]

def quantize_to_aga(img):
    arr = np.array(img.convert("RGB"), dtype=np.int32)
    h, w, _ = arr.shape
    flat = arr.reshape(-1, 3)
    dists = ((flat[:, None, :] - pal_rgb[1:][None, :, :]) ** 2).sum(axis=2)
    idx = (np.argmin(dists, axis=1) + 1).astype(np.uint8).reshape(h, w)
    return idx

def make_airbase_bg():
    W, H = 320, 256
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    # Niebo zachodu slonca (Top Gun Miramar / Solis sunset gradient)
    for y in range(136):
        t = y / 135.0
        r = int(18 + 195 * (t ** 1.6))
        g = int(24 + 95 * (t ** 2.0))
        b = int(68 + 45 * math.sin(t * math.pi))
        d.line([(0, y), (W, y)], fill=(min(255,r), min(255,g), min(255,b)))
    # Tarcza zachodzacego slonca + poswiata
    d.ellipse([215, 76, 275, 136], fill=(255, 190, 70))
    d.ellipse([224, 85, 266, 127], fill=(255, 235, 150))
    # Chmury warstwowe
    for cx, cy, cw, ch, col in [(60,48,90,10,(120,65,95)),(180,62,110,12,(175,85,80)),(110,88,130,9,(220,125,75))]:
        d.ellipse([cx, cy, cx+cw, cy+ch], fill=col)
    # Pasma gorskie na horyzoncie
    d.polygon([(0,136),(0,112),(48,96),(95,118),(155,92),(215,114),(270,98),(320,116),(320,136)], fill=(42,36,64))
    d.polygon([(0,136),(30,118),(85,104),(140,124),(200,106),(265,122),(320,112),(320,136)], fill=(58,48,78))
    # Stalowe hangary lotnicze po lewej i w centrum
    d.rectangle([10, 108, 96, 142], fill=(64, 72, 92))
    d.pieslice([10, 94, 96, 124], 180, 360, fill=(88, 98, 122))
    d.rectangle([28, 118, 78, 142], fill=(20, 24, 34))
    for rx in range(16, 94, 10):
        d.line([(rx, 106), (rx, 142)], fill=(45, 52, 68))
    # Wieza kontroli lotow (ATC Tower) z oszklona kopula i radarem
    d.rectangle([118, 92, 134, 142], fill=(82, 90, 110))
    d.polygon([(110,92),(142,92),(138,76),(114,76)], fill=(115, 130, 155))
    d.rectangle([114, 80, 138, 88], fill=(40, 210, 245))
    d.line([(126, 76), (126, 62)], fill=(220, 225, 235), width=2)
    d.ellipse([119, 58, 133, 66], fill=(240, 240, 250))
    # Zaparkowane mysliwce w tle przy hangarze
    d.polygon([(152,138),(186,128),(205,138)], fill=(50, 58, 74))
    d.polygon([(180,128),(184,116),(192,128)], fill=(70, 80, 98))
    # Plyta lotniska (betonowe plyty z faktura i liniami pasa)
    for y in range(136, H):
        t = (y - 136) / 120.0
        v = int(56 + 44 * t)
        d.line([(0, y), (W, y)], fill=(v, v+4, v+14))
    for x in range(0, W, 32):
        d.line([(x, 140), (x - 40 + x//4, 255)], fill=(44, 48, 60))
    for y in [156, 182, 214, 246]:
        d.line([(0, y), (W, y)], fill=(48, 52, 64))
    # Zolte i biale linie pasa kolowania + swiatla nawigacyjne
    d.polygon([(0, 224), (320, 224), (320, 230), (0, 230)], fill=(235, 190, 40))
    for lx in range(18, 310, 42):
        d.ellipse([lx-2, 144, lx+2, 148], fill=(255, 60, 60))
        d.ellipse([lx-3, 238, lx+3, 243], fill=(60, 230, 255))
    arr = quantize_to_aga(img)
    Path("data/bg_airbase.bin").write_bytes(arr.tobytes())
    print("SAVED data/bg_airbase.bin:", arr.shape)

def make_moto_sprite():
    W, H = 96, 48
    img = Image.new("RGB", (W, H), (0, 0, 0))
    d = ImageDraw.Draw(img)
    # Tylne i przednie kolo z opona, felga i tarcza hamulcowa
    for cx in [20, 76]:
        d.ellipse([cx-12, 22, cx+12, 46], fill=(18, 20, 26))
        d.ellipse([cx-7, 27, cx+7, 41], fill=(140, 150, 170))
        d.ellipse([cx-3, 31, cx+3, 37], fill=(230, 235, 245))
    # Silnik i wydech
    d.rectangle([28, 24, 64, 38], fill=(55, 62, 76))
    d.polygon([(14,34),(42,32),(42,37),(12,38)], fill=(185, 195, 210))
    # Czerwona aerodynamiczna owiewka GPZ900R + bialy pas
    d.polygon([(8,20),(34,22),(52,14),(84,20),(76,30),(24,30)], fill=(235, 36, 48))
    d.polygon([(26,22),(76,22),(72,26),(24,26)], fill=(245, 245, 255))
    # Szyba owiewki + reflektor
    d.polygon([(54,14),(68,8),(78,16),(64,18)], fill=(50, 225, 255))
    d.ellipse([81, 18, 87, 24], fill=(255, 240, 140))
    # Kierowca na motocyklu (kurtka + bialy kask + zloty wizjer)
    d.polygon([(28,22),(38,10),(54,12),(50,22)], fill=(45, 120, 210))
    d.ellipse([44, 2, 58, 15], fill=(245, 248, 255))
    d.rectangle([52, 6, 58, 11], fill=(255, 205, 40))
    raw = np.array(img, dtype=np.int32)
    mask = (raw[:, :, 0] > 4) | (raw[:, :, 1] > 4) | (raw[:, :, 2] > 4)
    q = quantize_to_aga(img)
    q[~mask] = 0
    Path("data/spr_moto.bin").write_bytes(q.tobytes())
    print("SAVED data/spr_moto.bin:", q.shape)

make_airbase_bg()
make_moto_sprite()
