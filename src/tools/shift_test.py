#!/usr/bin/env python3
"""
shift_test.py - Check that the ROM source is relocatable.

Inserts N bytes of padding in front of a function in a temporary copy of
romsrc/ (everything after it, up to the fixed region at 0xF0000, moves by N),
builds the ROM, and boots it headless in QEMU. With --trace, the original and the
shifted ROM are run with deterministic timing (-icount) and the first point where
their execution differs (after mapping addresses by the shift) is reported: the
code there uses an address or offset that is not yet written as a label.

Usage (from src/):
  tools/shift_test.py --at 0x40880000 --bytes 0x40 [--trace] [--seconds 15]
                      [--disk IMAGE [--pram PRAM]]
With --disk, the traced runs boot from that disk image (attached read-only, snapshot=on;
the PRAM is a copy). Note: Mac OS patches this ROM by address ("come-from" checks of
return addresses, jumps into ROM code), so with a disk the traces part as soon as the
System checks an address that moved: that is the System, not the relocation.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.dirname(HERE)

AS = os.environ.get("M68K_AS", "/usr/m68k-suse-linux/bin/as")
LD = os.environ.get("M68K_LD", "/usr/m68k-suse-linux/bin/ld")
NM = os.environ.get("M68K_NM", "/usr/m68k-suse-linux/bin/nm")
OBJCOPY = os.environ.get("M68K_OBJCOPY", "/usr/bin/m68k-suse-linux-objcopy")
ROM_BASE = 0x40800000
FIXED = 0xF0000


def build(srcdir, work, tag):
    o, e, b = (os.path.join(work, f"{tag}.{x}") for x in ("o", "elf", "rom"))
    for attempt in range(8):            # again when a trap table entry had to grow
        r = subprocess.run([AS, "-m68040", "-I", srcdir, "-I", os.path.join(srcdir, "include"),
                            os.path.join(srcdir, "q800rom.s"), "-o", o], capture_output=True, text=True)
        if r.returncode:
            sys.exit("assembly failed:\n" + r.stderr[:2000])
        r = subprocess.run([LD, f"-Ttext=0x{ROM_BASE:X}", "-e", f"0x{ROM_BASE:X}", "--no-warn-rwx-segments",
                            "-o", e, o], capture_output=True, text=True)
        if r.returncode:
            sys.exit("link failed:\n" + r.stderr[:2000])
        subprocess.run([OBJCOPY, "-O", "binary", "--only-section=.text", e, b], check=True)
        if os.path.getsize(b) != 0x100000:
            sys.exit(f"ROM size is 0x{os.path.getsize(b):X}, expected 0x100000")
        r = subprocess.run([sys.executable, os.path.join(HERE, "rom_postlink.py"), e, b, srcdir],
                           capture_output=True, text=True)
        if r.returncode == 3:
            print("[*] " + r.stdout.strip().splitlines()[-1])
            continue
        if r.returncode:
            sys.exit("post-link failed:\n" + r.stdout + r.stderr)
        return e, b
    sys.exit("post-link: the trap table did not settle")


def symbols(elf):
    out = {}
    for line in subprocess.run([NM, "-n", elf], capture_output=True, text=True).stdout.splitlines():
        p = line.split()
        if len(p) == 3:
            out.setdefault(int(p[0], 16), p[2])
    return out


DISK = None          # --disk: a boot disk image, attached read-only (snapshot=on)


def disk_args(work, tag):
    if not DISK:
        return []
    pram = os.path.join(work, f"{tag}.pram")
    open(pram, "wb").write(open(DISK[1], "rb").read() if DISK[1] else bytes(512))
    return ["-drive", f"file={pram},format=raw,if=mtd",
            "-drive", f"file={DISK[0]},format=raw,if=none,id=hd1,snapshot=on",
            "-device", "scsi-hd,scsi-id=0,drive=hd1"]


def trace(rom, work, tag, seconds):
    log = os.path.join(work, f"{tag}.log")
    subprocess.run(["timeout", str(seconds), "qemu-system-m68k", "-M", "q800", "-m", "64", "-bios", rom] + disk_args(work, tag) + [
                    "-display", "none", "-g", "640x480x8", "-icount", "shift=4,align=off,sleep=off",
                    "-rtc", "clock=vm,base=2000-01-01T00:00:00",
                    "-d", "in_asm,nochain", "-D", log], capture_output=True)
    # every translated instruction, in translation order (block splits do not matter)
    pcs = []
    seen = set()
    for line in open(log, errors="replace"):
        m = re.match(r"^0x([0-9a-f]{8}):", line)
        if m:
            pc = int(m.group(1), 16)
            if pc not in seen:
                seen.add(pc)
                pcs.append(pc)
    return pcs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--at", required=True, help="ROM address (original ROM) to insert before")
    ap.add_argument("--bytes", default="0x40")
    ap.add_argument("--trace", action="store_true")
    ap.add_argument("--seconds", type=int, default=30,
                    help="real seconds per traced run (the end of a trace depends on host load)")
    ap.add_argument("--keep", help="copy the shifted ROM here")
    ap.add_argument("--disk", help="boot disk image for --trace (read-only: snapshot=on)")
    ap.add_argument("--pram", help="PRAM image to start from with --disk (a copy is used)")
    a = ap.parse_args()
    global DISK
    if a.disk:
        DISK = (os.path.abspath(a.disk), os.path.abspath(a.pram) if a.pram else None)
    at = int(a.at, 0)
    n = int(a.bytes, 0)

    with tempfile.TemporaryDirectory(prefix="q800shift_") as work:
        orig_elf, orig_rom = build(os.path.join(SRC, "romsrc"), work, "orig")
        syms = symbols(orig_elf)
        # first label at/after the requested address that is not reached by falling
        # through: the previous instruction must be an unconditional transfer
        addr_of = {nm_: ad for ad, nm_ in syms.items()}
        shifted = os.path.join(work, "romsrc")
        shutil.copytree(os.path.join(SRC, "romsrc"), shifted, ignore=shutil.ignore_patterns(".git"))
        best = None
        sources = sorted(os.path.relpath(os.path.join(d, f), shifted)
                         for d, _, fs in os.walk(shifted) for f in fs)
        for fn in sources:
            if not fn.endswith(".s") or fn == "q800rom.s":
                continue
            lines = open(os.path.join(shifted, fn)).read().split("\n")
            prev = ""
            for i, l in enumerate(lines):
                m = re.match(r"^(\w+):$", l)
                if m and m.group(1) in addr_of:
                    ad = addr_of[m.group(1)]
                    if ad >= at and ad - ROM_BASE < FIXED and re.match(
                            r"^(rts|rte|rtd|jmp|j?bra[swl]?)\b", prev) and re.match(r"^(sub_|trap_|rsrc_|[A-Z][A-Z0-9_]*$)", m.group(1)) and (best is None or ad < best[0]):
                        best = (ad, fn, i, m.group(1))
                    continue
                t = l.split("|")[0].strip()
                if t:
                    prev = t
        if best is None:
            sys.exit("no suitable label found at/after that address")
        ins_at, fn, idx, name = best
        p = os.path.join(shifted, fn)
        lines = open(p).read().split("\n")
        # insert in front of all labels of that address (aliases follow the first one)
        while idx > 0 and re.match(r"^\w+:$", lines[idx - 1]):
            idx -= 1
        # ILLEGAL instructions: a stale reference into the padding traps instead of
        # sliding through it (zero bytes would decode as harmless ori.b #0,d0)
        pad = f"    .fill   0x{n // 2:X}, 2, 0x4AFC" if n >= 2 else ""
        if n % 2:
            pad += "\n    .byte   0x4A"
        lines.insert(idx, pad + "\t| shift test")
        open(p, "w").write("\n".join(lines))
        print(f"[*] inserting 0x{n:X} bytes before {name} (0x{ins_at:08X}); "
              f"0x{ins_at:08X}..0x{ROM_BASE + FIXED:08X} moves")
        sh_elf, sh_rom = build(shifted, work, "shifted")
        if a.keep:
            shutil.copy(sh_rom, a.keep)
        r = subprocess.run([sys.executable, os.path.join(HERE, "qemu_boot_test.py"), sh_rom,
                            str(a.seconds)], capture_output=True, text=True)
        print(r.stdout.strip())
        ok = r.returncode == 0

        if a.trace:
            # map original addresses through the symbol tables of both builds (code can
            # grow when relaxed branches crossing the insertion need a longer form)
            import bisect
            s0 = symbols(orig_elf)
            s1 = {nm_: ad for ad, nm_ in symbols(sh_elf).items()}
            addrs = sorted(ad for ad, nm_ in s0.items() if nm_ in s1 and not nm_.startswith("__"))

            def mapped(pc):
                base = ROM_BASE if pc >= ROM_BASE else 0x00800000
                full = pc - base + ROM_BASE
                if not ROM_BASE <= full < ROM_BASE + 0x100000:
                    return pc
                i = bisect.bisect_right(addrs, full) - 1
                if i < 0:
                    return pc
                lab = addrs[i]
                return s1[s0[lab]] + (full - lab) - ROM_BASE + base
            t0 = trace(orig_rom, work, "orig", a.seconds)
            t1 = trace(sh_rom, work, "shifted", a.seconds)
            m0 = [mapped(p) for p in t0]
            for i, (x, y) in enumerate(zip(m0, t1)):
                if x != y:
                    print(f"[!] first divergence at instruction #{i}: original 0x{t0[i]:08X} "
                          f"(expected 0x{x:08X} in shifted ROM), shifted ROM went to 0x{y:08X}")
                    print("    preceding instructions (original ROM addresses):",
                          " ".join(f"0x{p:08X}" for p in t0[max(0, i - 6):i]))
                    inrom = lambda p: 0x40800000 <= p < 0x40900000
                    a_, b_ = set(p for p in m0 if inrom(p)), set(p for p in t1 if inrom(p))
                    print("    ROM code run: original %d, shifted %d; only in original %d, only in shifted %d"
                          % (len(a_), len(b_), len(a_ - b_), len(b_ - a_)))
                    print("    (the same code in another order: interrupt timing, not a relocation error)"
                          if a_ == b_ else "    different code ran:")
                    print("    only in original:", " ".join("0x%08X" % p for p in sorted(a_ - b_)[:8]))
                    print("    only in shifted:", " ".join("0x%08X" % p for p in sorted(b_ - a_)[:8]))
                    break
            else:
                rom_pcs = sum(1 for p in t0 if 0x40800000 <= p < 0x40900000 or 0x00800000 <= p < 0x00900000)
                print(f"[=] traces agree for {min(len(t0), len(t1))} instructions "
                      f"({rom_pcs} of them in ROM)")
        sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
