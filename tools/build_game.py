#!/usr/bin/env python3
import argparse, os, shutil, struct, subprocess, tempfile, zipfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SRC_DIR = os.path.join(ROOT, "src")
BUILD_DIR = os.path.join(ROOT, "build")
AURA_ENG = os.path.join(ROOT, "refs", "aura3d", "engine")
AURA_DEMO = os.path.join(ROOT, "refs", "aura3d", "demo_v1")

PROFILES = {
    "standard": ("-m68020", ["-DLANG_PL"], ["-kick1hunks"], "_020"),
    "thea1200": ("-m68040", ["-DFULL_RES", "-DWIDESCREEN_16_9", "-DLANG_PL"], list(), "_THEA1200"),
    "thea1200_pl": ("-m68040", ["-DFULL_RES", "-DWIDESCREEN_16_9", "-DLANG_PL"], list(), "_THEA1200_PL"),
    "thea1200_en": ("-m68040", ["-DFULL_RES", "-DWIDESCREEN_16_9", "-DLANG_EN"], list(), "_THEA1200_EN"),
    "060": ("-m68060", ["-DFULL_RES", "-DWIDESCREEN_16_9", "-DM68060", "-DLANG_PL"], list(), "_060"),
}

def write_whdload_info(path, slave_name):
    tooltypes = ("SLAVE=" + slave_name, "NoMMU")
    hdr = struct.pack(">HH", 0xE310, 1)
    gad = struct.pack(">IhhhhHHHIIIIIHI", 0, 0, 0, 32, 16, 4, 3, 1, 1, 0, 0, 0, 0, 0, 0)
    body = struct.pack(">BBIIIIIII", 4, 0, 1, 1, 0x80000000, 0x80000000, 0, 0, 8192)
    img = struct.pack(">hhhhhIBBI", 0, 0, 32, 16, 1, 1, 1, 0, 0) + (bytes((255, 0, 255, 0)) * 16)
    dt = b"WHDLoad" + bytes([0]) + b""
    dt_blk = struct.pack(">I", len(dt)) + dt
    tt_entries = b"".join(struct.pack(">I", len(x) + 1) + x.encode("ascii") + b"" + bytes() + b"" for x in tooltypes)
    tt_blk = struct.pack(">I", (len(tooltypes) + 1) * 4) + tt_entries
    with open(path, "wb") as f:
        f.write(hdr + gad + body + img + dt_blk + tt_blk)

def build_profile(profile):
    cpu, defs, hunks, sfx = PROFILES[profile]
    os.makedirs(BUILD_DIR, exist_ok=True)
    tmp_w = tempfile.mkdtemp(prefix="af_build_")
    pkg_name = "AetherFalcon"
    pkg_dir = os.path.join(tmp_w, pkg_name)
    s_dir = os.path.join(tmp_w, "S")
    os.makedirs(pkg_dir, exist_ok=True)
    os.makedirs(s_dir, exist_ok=True)
    data_src = os.path.join(ROOT, "data")
    if os.path.isdir(data_src):
        shutil.copytree(data_src, os.path.join(pkg_dir, "data"), dirs_exist_ok=True)
        lang_src = os.path.join(data_src, "story_en.bin" if profile == "thea1200_en" else "story_pl.bin")
        if os.path.exists(lang_src):
            shutil.copy2(lang_src, os.path.join(pkg_dir, "data", "story.bin"))

    exe_path = os.path.join(pkg_dir, "AETHER_FALCON")
    slave_path = os.path.join(pkg_dir, "AetherFalcon.slave")

    print(f"[*] Kompilacja profilu {profile} ({cpu})...")
    subprocess.run([
        "vasmm68k_mot", cpu, *defs, "-Fhunkexe", *hunks, "-nosym",
        f"-I{SRC_DIR}", f"-I{AURA_ENG}", f"-I{AURA_DEMO}",
        os.path.join(SRC_DIR, "aether_falcon.s"), "-o", exe_path
    ], check=True)

    subprocess.run([
        "vasmm68k_mot", cpu, *defs, "-Fhunkexe", "-nosym",
        f"-I{SRC_DIR}",
        os.path.join(SRC_DIR, "af_whdload_slave.s"), "-o", slave_path
    ], check=True)

    write_whdload_info(os.path.join(pkg_dir, f"{pkg_name}.info"), "AetherFalcon.slave")
    write_whdload_info(os.path.join(tmp_w, f"{pkg_name}.info"), "AetherFalcon.slave")

    with open(os.path.join(s_dir, "startup-sequence"), "w", newline=chr(10)) as sf:
        sf.write(f"cd {pkg_name}" + chr(10) + "AETHER_FALCON" + chr(10))

    with open(os.path.join(pkg_dir, "README.txt"), "w", newline=chr(10)) as rf:
        rf.write(
            f"AETHER FALCON: VANGUARD v0.2.1.0 [{profile}] (2026)" + chr(10) +
            "Bare-Metal Amiga 1200 AGA / THEA1200 3D Combat Sim" + chr(10) +
            "Controls: Joy2 / THEA1200 Pad / Arrows + Space | Exit: LMB or ESC" + chr(10)
        )

    zip_path = os.path.join(BUILD_DIR, f"AetherFalcon_AGA{sfx}_FSUAE.zip")
    if os.path.exists(zip_path): os.remove(zip_path)
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for bd, dirs, files in os.walk(tmp_w):
            dirs.sort()
            for fn in sorted(files):
                full = os.path.join(bd, fn)
                zf.write(full, os.path.relpath(full, tmp_w))

    lha_bin = shutil.which("lha")
    lha_msg = ""
    if lha_bin:
        lha_path = os.path.join(BUILD_DIR, f"AetherFalcon_AGA{sfx}.lha")
        if os.path.exists(lha_path): os.remove(lha_path)
        env = os.environ.copy()
        env["TMPDIR"] = "/tmp"
        subprocess.run([lha_bin, "ao1w=/tmp", lha_path, pkg_name, f"{pkg_name}.info", "S"], cwd=tmp_w, env=env, check=True)
        lha_msg = f" | {lha_path}"

    shutil.rmtree(tmp_w, ignore_errors=True)
    print(f"[OK] {profile}: {zip_path}{lha_msg}")

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--profile", choices=["standard", "thea1200", "thea1200_pl", "thea1200_en", "060", "all"], default="all")
    args = p.parse_args()
    for t in (list(PROFILES.keys()) if args.profile == "all" else [args.profile]):
        build_profile(t)