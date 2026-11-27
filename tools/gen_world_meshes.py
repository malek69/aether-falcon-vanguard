import math, pathlib

def norm_vec(x, y, z):
    l = math.sqrt(x*x + y*y + z*z) or 1.0
    return (int(round(x/l*250)), int(round(y/l*250)), int(round(z/l*250)))

drone_v = [
    (  0,  0, 11), (  0, -3,  4), (  0,  3,  4), ( -6, -3, -3),
    (  6, -3, -3), ( -6,  3, -3), (  6,  3, -3), (  0,  0,-10),
    (-13, -1, -1), ( 13, -1, -1), (  0, -7, -5), (  0,  6, -4),
]
drone_n = [norm_vec(x, y-2, z) for (x, y, z) in drone_v]
drone_t = [
    (0,1,3,3), (0,4,1,3), (0,3,2,2), (0,2,4,2),
    (1,4,3,2), (2,3,4,2),
    (3,4,7,2), (4,6,7,2), (6,5,7,2), (5,3,7,2),
    (3,5,2,2), (4,2,6,2),
    (3,8,5,3), (3,1,8,3), (5,8,7,2),
    (4,6,9,3), (4,9,1,3), (6,7,9,2),
    (1,4,10,3), (1,10,3,3),
]

dome_v = []
for i in range(8):
    a = i * math.pi / 4.0
    dome_v.append((int(round(20*math.cos(a))), 0, int(round(20*math.sin(a)))))
for i in range(8):
    a = i * math.pi / 4.0
    dome_v.append((int(round(12*math.cos(a))), -12, int(round(12*math.sin(a)))))
dome_v.append((0, -18, 0))
dome_v.extend([
    (18, -1, -11), (38, -1, -11), (38, -1,  11), (18, -1,  11),
    (-25,  0, -4), (-19,  0,  4), (-22,-28,  0),
])

dome_n = []
for idx, (x, y, z) in enumerate(dome_v):
    if idx <= 16:
        dome_n.append(norm_vec(x, y - 12, z))
    elif idx <= 20:
        dome_n.append((0, -250, 0))
    else:
        dome_n.append(norm_vec(x + 22, y - 8, z))

dome_t = []
for i in range(8):
    ni = (i + 1) % 8
    dome_t.append((i, ni, 8 + ni, 1))
    dome_t.append((i, 8 + ni, 8 + i, 1))
    dome_t.append((8 + i, 8 + ni, 16, 1))
dome_t.extend([
    (17, 18, 19, 2), (17, 19, 20, 2),
    (17, 19, 18, 2), (17, 20, 19, 2),
    (21, 22, 23, 3), (21, 23, 22, 3),
])

def fmt_verts(name, verts):
    return chr(10).join([f"{name}:", f"        dc.w {len(verts)}"] + [f"        dc.w {x:4d},{y:4d},{z:4d}" for x, y, z in verts])

def fmt_norms(name, norms):
    return chr(10).join([f"{name}:"] + [f"        dc.w {nx:4d},{ny:4d},{nz:4d}" for nx, ny, nz in norms])

def fmt_tris(name, tris):
    return chr(10).join([f"{name}:", f"        dc.w {len(tris)}"] + [f"        dc.w {i0:2d},{i1:2d},{i2:2d},{tid:2d}" for i0, i1, i2, tid in tris])

p = pathlib.Path("src/exo_world_objs.i")
txt = p.read_text(encoding="latin1")

e_idx = txt.find(".b_nx:  addq.l  #6,a4")
s_idx = txt.rfind("move.w  d0,d3", 0, e_idx) - 8
assert s_idx != -1 and e_idx != -1, f"Zakres nie znaleziony: {s_idx}, {e_idx}"

new_block = chr(10).join([
    "        move.w  d5,d6",
    "        asl.w   #2,d6",
    "        move.w  d1,d4",
    "        sub.w   #160,d4",
    "        muls.w  d6,d4",
    "        asr.l   #8,d4",
    "        move.w  d0,d5",
    "        sub.w   #128,d5",
    "        muls.w  d6,d5",
    "        asr.l   #8,d5",
    "        sub.w   #150,d6",
    "        move.w  #192,d0",
    "        move.w  #192,d1",
    "        move.w  #192,d2",
    "        lea     exo_dome_mesh_v(pc),a0",
    "        lea     exo_dome_mesh_n(pc),a2",
    "        lea     exo_dome_mesh_t(pc),a3",
    "        jsr     vec3d_draw_mesh_3d",
    ""
])
txt = txt[:s_idx] + new_block + txt[e_idx:]

old_drone_y = "        moveq   #-22,d5" + chr(10) + "        muls.w  d6,d5" + chr(10) + "        asr.l   #8,d5"
new_drone_y = "        sub.w   #144,d0" + chr(10) + "        move.w  d0,d5" + chr(10) + "        muls.w  d6,d5" + chr(10) + "        asr.l   #8,d5"
assert old_drone_y in txt, "Nie znaleziono wysokosci drona"
txt = txt.replace(old_drone_y, new_drone_y, 1)

cut = txt.find("exo_drone_mesh_v:")
assert cut != -1
meshes = (chr(10) * 2).join([
    "        even",
    fmt_verts("exo_drone_mesh_v", drone_v),
    fmt_norms("exo_drone_mesh_n", drone_n),
    fmt_tris("exo_drone_mesh_t", drone_t),
    "        even",
    fmt_verts("exo_dome_mesh_v", dome_v),
    fmt_norms("exo_dome_mesh_n", dome_n),
    fmt_tris("exo_dome_mesh_t", dome_t),
    ""
])
p.write_text(txt[:cut] + meshes, encoding="latin1")
print("OK: Wygenerowano siatki 3D kopul i dronow na gruncie.")
