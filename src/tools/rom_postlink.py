#!/usr/bin/env python3
"""
rom_postlink.py - Post-link fixups for the ROM built from romsrc/.

1. Re-encodes the packed trap dispatch table (label trap_dispatch_table) from the
   linked addresses of its target labels (romsrc/traptable.lst). Each entry keeps
   its encoding class (byte / word / long). When a moved routine no longer fits its
   class, the entry is promoted (byte -> word -> long): its class in traptable.lst and
   its placeholder bytes in the source file holding trap_dispatch_table are rewritten,
   and the script exits with status 3: the table changed size, so the ROM must be
   assembled and linked again (the Makefile and tools/shift_test.py do that). Classes
   only grow, so this ends; an unmodified source never needs it.
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
from rom_checksum import fix_checksums  # noqa: E402

NM = os.environ.get("M68K_NM", "/usr/m68k-suse-linux/bin/nm")
ROM_BASE = 0x40800000


SIZE = {"u": 1, "b": 1, "w": 2, "l": 5, "end": 2}


def fits_byte(d):
    return d % 2 == 0 and 2 <= d <= 0x7E * 2


def fits_word(d):
    """the word form: delta = sign_extend16((w * 2) & 0xFFFF), w < 0x8000, not 0"""
    return d % 2 == 0 and d != 0 and -0x8000 <= d <= 0x7FFE


def promote(srcdir, lines, entries, grow):
    """new classes in traptable.lst lines and placeholder sizes in the table source"""
    import re
    for n, c in grow.items():
        k, line = entries[n]
        lines[k] = "%s %s" % (c, line[1])
    # the source: one data line per entry after the label, in table order
    for dp, dn, fn in os.walk(srcdir):
        dn[:] = [d for d in dn if d != ".git"]
        for f in fn:
            if not f.endswith(".s"):
                continue
            p = os.path.join(dp, f)
            L = open(p).read().split("\n")
            if "trap_dispatch_table:" not in L:
                continue
            i = L.index("trap_dispatch_table:") + 1
            n = 0
            while n < len(entries):
                m = re.match(r"^(\s+\.byte\s+)[^|]*(\t\|\s*)(\S+)(.*)$", L[i])
                if m:
                    if n in grow:
                        c = grow[n]
                        L[i] = "%s%s%s%s%s" % (m.group(1), ", ".join(["0x00"] * SIZE[c]),
                                                 m.group(2), c, m.group(4))
                    n += 1
                i += 1
            open(p, "w").write("\n".join(L))
            return
    sys.exit("trap_dispatch_table not found in the source")


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
        lines = open(lst).read().split("\n")
        entries = [(k, l.split()) for k, l in enumerate(lines) if l.strip() and not l.startswith("#")]
        cur = 0
        out = bytearray()
        grow = {}                                  # entry number -> new class
        for n, (k, line) in enumerate(entries):
            kind = line[0]
            if kind == "u":
                out.append(0x80)
                continue
            if kind == "end":
                out += b"\0\0"
                continue
            t = syms[line[1]]
            d = t - cur
            if kind == "b" and not fits_byte(d):
                kind = "w" if fits_word(d) else "l"
            elif kind == "w" and not fits_word(d):
                kind = "l"
            if kind != line[0]:
                grow[n] = kind
            if kind == "l":
                out.append(0xFF)
                out += struct.pack(">I", t)
            elif kind == "b":
                out.append(0x80 | (d // 2))
            else:
                out += struct.pack(">H", (d // 2) & 0x7FFF)
            cur = t
        if grow:
            promote(srcdir, lines, entries, grow)
            open(lst, "w").write("\n".join(lines))
            print("trap table: %d entries promoted (%s): assemble and link again"
                  % (len(grow), ", ".join("%s -> %s" % (entries[n][1][1], c) for n, c in grow.items())))
            sys.exit(3)
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
