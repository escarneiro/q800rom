#!/usr/bin/env python3
"""
rom_postlink.py - Post-link fixups for the ROM built from romsrc/.

1. Re-encodes the packed trap dispatch table (label trap_dispatch_table) from the
   linked addresses of its target labels (romsrc/traptable.lst). Each entry keeps
   its encoding class (byte / word / long); the build fails if a moved routine no
   longer fits its class.
2. Applies romsrc/relocs.lst (24-bit self-relative NuBus sResource offsets).
3. Recomputes the byte-lane sums (0x30) and the checksum (0x00).

Usage: rom_postlink.py <linked.elf> <rom.bin> <romsrc_dir>
"""

import os
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from build_rom import fix_checksums  # noqa: E402

NM = os.environ.get("M68K_NM", "/usr/m68k-suse-linux/bin/nm")
ROM_BASE = 0x40800000


def main():
    elf, binf, srcdir = sys.argv[1:4]
    syms = {}
    for line in subprocess.run([NM, elf], capture_output=True, text=True).stdout.splitlines():
        p = line.split()
        if len(p) == 3:
            syms[p[2]] = int(p[0], 16) - ROM_BASE
    rom = bytearray(open(binf, "rb").read())

    lst = os.path.join(srcdir, "traptable.lst")
    if os.path.exists(lst) and "trap_dispatch_table" in syms:
        o = syms["trap_dispatch_table"]
        cur = 0
        out = bytearray()
        for n, line in enumerate(l.split() for l in open(lst) if l.strip() and not l.startswith("#")):
            kind = line[0]
            if kind == "u":
                out.append(0x80)
                continue
            if kind == "end":
                out += b"\0\0"
                continue
            t = syms[line[1]]
            d = t - cur
            if kind == "l":
                out.append(0xFF)
                out += struct.pack(">I", t)
            elif kind == "b":
                if d % 2 or not 2 <= d <= 0x7E * 2:
                    sys.exit(f"trap table entry {n} ({line[1]}): delta {d} no longer fits the byte form")
                out.append(0x80 | (d // 2))
            elif kind == "w":
                if d % 2 or not -0x8000 <= d <= 0x7FFE or d == 0:
                    sys.exit(f"trap table entry {n} ({line[1]}): delta {d} no longer fits the word form")
                w = (d // 2) & 0x7FFF
                if ((w * 2) & 0xFFFF) - (0x10000 if (w * 2) & 0x8000 else 0) != d:
                    sys.exit(f"trap table entry {n} ({line[1]}): delta {d} not encodable")
                out += struct.pack(">H", w)
            cur = t
        old = bytes(rom[o:o + len(out)])
        rom[o:o + len(out)] = out
        print(f"trap table at 0x{ROM_BASE + o:08X}: {len(out)} bytes re-encoded"
              f"{'' if old == bytes(out) else ' (changed)'}")
    rel = os.path.join(srcdir, "relocs.lst")
    if os.path.exists(rel):
        n = changed = 0
        for line in open(rel):
            p = line.split()
            if not p or p[0].startswith("#"):
                continue
            if p[0] == "s24":
                loc, tgt = syms[p[1]], syms[p[2]]
                v = tgt - loc
                if not -0x800000 <= v < 0x800000:
                    sys.exit(f"s24 relocation {p[1]} -> {p[2]} out of range")
                new = (v & 0xFFFFFF).to_bytes(3, "big")
                changed += rom[loc + 1:loc + 4] != new
                rom[loc + 1:loc + 4] = new
                n += 1
        print(f"{n} sResource offsets patched ({changed} changed)")
    csum = fix_checksums(rom)
    open(binf, "wb").write(rom)
    print(f"checksum 0x{csum:08X}")


if __name__ == "__main__":
    main()
