#!/usr/bin/env python3
import argparse, os, shutil, struct, subprocess, tempfile, zipfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SRC_DIR = os.path.join(ROOT, "src")
BUILD_DIR = os.path.join(ROOT, "build")
AURA_ENG = os.path.join(ROOT, "refs", "aura3d", "engine")
AURA_DEMO = os.path.join(ROOT, "refs", "aura3d", "demo_v1")

PROFILES = {
    "standard": ("-m68020", list(), ["-kick1hunks"], "_020"),
    "thea1200": ("-m68020", ["-DFULL_RES"], list(), "_THEA1200"),
    "060":      ("-m68060", ["-DFULL_RES"], list(), "_060"),
}

def write_whdload_info(path, slave_name):
    tt = ("SLAVE=" + slave_name + chr(0)).encode("ascii")
    tt_block = struct.pack(">I", len(tt) + 4) + tt
    hdr = struct.pack(">HHIIIIIIIBBHI", 0xE310, 1, 0, 0, 0, 0, 64, 32, 0, 4, 0, 0, 0)
    hdr = hdr[:48] + struct.pack(">I", 1) + hdr[52:]
    img = struct.pack(">HHhhhhI", 0, 0, 64, 32, 1, 1, 0) + (bytes([0xFF]) * (8 * 32))
    with open(path, "wb") as f:
        f.write(hdr + img + tt_block)

def build_profile(profile):
    cpu, defs, hunks, sfx = PROFILES[profile]
    os.makedirs(BUILD_DIR, exist_ok=True)
    tmp_w = tempfile.mkdtemp(prefix="af_build_")
    pkg_name = "AetherFalcon"
    pkg_dir = os.path.join(tmp_w, pkg_name)
    s_dir = os.path.join(tmp_w, "S")
    os.makedirs(pkg_dir, exist_ok=True)
    os.makedirs(s_dir, exist_ok=True)

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
            f"AETHER FALCON: VANGUARD v0.0.1 [{profile}] (2026)" + chr(10) +
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
    p.add_argument("--profile", choices=["standard", "thea1200", "060", "all"], default="all")
    args = p.parse_args()
    for t in (list(PROFILES.keys()) if args.profile == "all" else [args.profile]):
        build_profile(t)
