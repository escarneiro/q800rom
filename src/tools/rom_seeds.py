#!/usr/bin/env python3
"""
rom_seeds.py - Collect code entry points and names for the Quadra 800 ROM.

Evidence used (all optional except the ROM):
  --traps FILE     runtime trap tables dumped from RAM after a QEMU boot
                   (lines "OS|TB <index hex> <address hex>")
  --trace FILE     QEMU "-d in_asm" logs (any number); every executed ROM PC
  --names FILE     trap_table.c, for trap names
  --symbols FILE   rom_symbols.h; only symbols confirmed by other evidence are kept
  ROM structures   the ROM resource list (header offset 0x1A) and the NuBus
                   declaration ROM (format block at the end of the ROM)

Output lines: "ADDR KIND [name] [size]"
  KIND = C (code entry, becomes a function), X (executed PC), L (label only),
         D (known data range of SIZE bytes, e.g. fonts/sounds; never code)
"""

import argparse
import re
import struct

ROM_BASE = 0x40800000
ROM_SIZE = 0x100000

# resource types whose data starts with 68k code
CODE_TYPES = {"PACK", "CDEF", "MDEF", "MBDF", "WDEF", "LDEF", "INIT", "SERD",
              "atlk", "ltlk", "lmgr", "PTCH", "ADBS", "proc", "CODE"}
DRVR_TYPES = {"DRVR", "drvr", "enet"}
# resource types that are never 68k code (iopc is 6502 code for the I/O processors)
DATA_TYPES = {"CURS", "FONT", "NFNT", "KCHR", "KMAP", "KCAP", "snd ", "accl", "clut",
              "gama", "mitq", "wctb", "cctb", "PICT", "free", "iopc", "pslt", "ecfg",
              "attx", "ICON", "ICN#", "STR ", "STR#"}


def u32(r, o):
    return struct.unpack(">I", r[o:o + 4])[0]


def u16(r, o):
    return struct.unpack(">H", r[o:o + 2])[0]


def s24(r, o):
    v = int.from_bytes(r[o + 1:o + 4], "big")
    return v - 0x1000000 if v & 0x800000 else v


def safe(s):
    return re.sub(r"[^A-Za-z0-9_]", "_", s).strip("_")


class Seeds:
    def __init__(self):
        self.d = {}            # off -> [kind, name]
        self.ranges = []       # (start, end, name) known data, never code

    def add(self, off, kind, name=None):
        if not 0 <= off < ROM_SIZE:
            return
        if kind in "CX" and off % 2:
            return
        rank = {"L": 0, "X": 1, "C": 2}
        cur = self.d.get(off)
        if cur is None:
            self.d[off] = [kind, name]
            return
        if rank[kind] > rank[cur[0]]:
            cur[0] = kind
        if name and not cur[1]:
            cur[1] = name


def drvr_entries(r, base):
    """DRVR header: flags, delay, emask, menu, then 5 word offsets."""
    out = []
    for i, n in enumerate(("open", "prime", "ctl", "status", "close")):
        e = u16(r, base + 8 + 2 * i)
        if 0 < e < 0x10000 and (base + e) % 2 == 0:
            out.append((n, base + e))
    return out


def rom_resources(r, seeds):
    first = u32(r, u32(r, 0x1A))
    off, seen, n = first, set(), 0
    while off and off not in seen and 0 < off < ROM_SIZE:
        seen.add(off)
        nxt, data = struct.unpack(">II", r[off + 8:off + 16])
        typ = r[off + 16:off + 20].decode("mac_roman")
        rid = struct.unpack(">h", r[off + 20:off + 22])[0]
        nl = r[off + 23]
        name = r[off + 24:off + 24 + nl].decode("mac_roman", "replace")
        size = u32(r, data - 8) - 12
        tag = safe(f"rsrc_{typ}_{rid if rid >= 0 else 'm%d' % -rid}_{name}")
        seeds.add(off, "L", tag + "_entry")
        seeds.add(data, "L", tag)
        if size > 0:
            if typ in DATA_TYPES:
                seeds.ranges.append((data, data + size, tag))
            if typ in CODE_TYPES:
                seeds.add(data, "C", tag)
            elif typ in DRVR_TYPES:
                seeds.add(data, "L", tag)
                for en, a in drvr_entries(r, data):
                    if a < data + size:
                        seeds.add(a, "C", f"{tag}_{en}")
        off = nxt
        n += 1
    return n


def decl_rom(r, seeds):
    fb = ROM_SIZE - 20
    seeds.add(fb, "L", "decl_format_block")
    d = fb + s24(r, fb)
    seeds.add(d, "L", "decl_sresource_dir")
    found = 0
    o = d
    while r[o] != 0xFF and o < ROM_SIZE:
        sid = r[o]
        sr = o + s24(r, o)
        seeds.add(sr, "L", f"decl_srsrc_{sid:02X}")
        p = sr
        while r[p] != 0xFF and p < ROM_SIZE:
            eid = r[p]
            tgt = p + s24(r, p)
            if eid == 0x04:                      # sRsrcDrvrDir
                q = tgt
                while r[q] != 0xFF:
                    blk = q + s24(r, q)
                    seeds.add(blk, "L", f"decl_srsrc_{sid:02X}_driver_{r[q]:02X}")
                    drv = blk + 4                # sBlock: long length, then DRVR
                    for en, a in drvr_entries(r, drv):
                        seeds.add(a, "C", f"decl_srsrc_{sid:02X}_drvr_{en}")
                        found += 1
                    q += 4
            elif eid in (0x06, 0x22, 0x26):      # sRsrcBootRec, PrimaryInit, SecondaryInit
                # sExecBlock: long size, byte rev, byte cpu, word 0, long code offset
                code = tgt + 8 + struct.unpack(">i", r[tgt + 8:tgt + 12])[0]
                if tgt < code < tgt + u32(r, tgt):
                    nm = {0x06: "bootrec", 0x22: "primary_init", 0x26: "secondary_init"}[eid]
                    seeds.add(code, "C", f"decl_srsrc_{sid:02X}_{nm}")
                    found += 1
            p += 4
        o += 4
    return found


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rom")
    ap.add_argument("out")
    ap.add_argument("--traps")
    ap.add_argument("--trace", action="append", default=[])
    ap.add_argument("--names")
    ap.add_argument("--symbols")
    ap.add_argument("--hints", help="code_hints.txt from rom_disasm.py (code found in ROM tables)")
    a = ap.parse_args()
    r = open(a.rom, "rb").read()
    seeds = Seeds()

    names = {}
    if a.names:
        for m in re.finditer(r'\{ 0x(A[0-9A-F]{3})U, "(\w+)"', open(a.names).read()):
            names[int(m.group(1), 16)] = m.group(2).lstrip("_")
    trapaddrs = set()
    if a.traps:
        for line in open(a.traps):
            k, i, addr = line.split()
            i, addr = int(i, 16), int(addr, 16)
            t = (0xA000 + i) if k == "OS" else (0xA800 + i)
            off = addr - ROM_BASE
            if not 0 <= off < ROM_SIZE:
                continue
            trapaddrs.add(off)
            n = "UnimplementedTrap" if addr == 0x40809AE6 else "trap_" + (names.get(t) or f"{t:04X}")
            seeds.add(off, "C", n)

    executed = set()
    for path in a.trace:
        for line in open(path, errors="replace"):
            m = re.match(r"^0x([0-9a-f]{8}):\s", line)
            if m:
                pc = int(m.group(1), 16)
                if 0x40000000 <= pc < 0x41000000:       # ROM and its mirrors
                    executed.add((pc - 0x40000000) % ROM_SIZE)
    for off in executed:
        seeds.add(off, "X")

    if a.symbols:
        for m in re.finditer(r"#define\s+SYM_(\w+)\s+0x([0-9A-F]+)U", open(a.symbols).read()):
            off = int(m.group(2), 16) - ROM_BASE
            if off in executed or off in trapaddrs:
                seeds.add(off, "C", m.group(1).lower())

    # 68k exception vector table in ROM at 0x3D08... is data; reset/ROM header entries
    for o, n in ((0x2A, "reset_entry"), (0x0A, "StartBoot"), (0x0E, "BadDisk"),
                 (0x1E, "hdr_jmp_1E"), (0x26, "hdr_jmp_26")):
        if u16(r, o) == 0x4EFA:
            seeds.add(o, "C", n)

    nhints = 0
    if a.hints:
        import os
        if os.path.exists(a.hints):
            for line in open(a.hints):
                p = line.split()
                if p and not p[0].startswith("#"):
                    seeds.add(int(p[0], 16) - ROM_BASE, "C")
                    nhints += 1

    nres = rom_resources(r, seeds)
    ndecl = decl_rom(r, seeds)

    with open(a.out, "w") as f:
        f.write("# Quadra 800 ROM seeds (tools/rom_seeds.py). C=code entry, X=executed, L=label\n")
        for off in sorted(seeds.d):
            k, n = seeds.d[off]
            f.write(f"{ROM_BASE + off:08X} {k} {n or ''}".rstrip() + "\n")
        for st, en, n in seeds.ranges:
            f.write(f"{ROM_BASE + st:08X} D {n}_data {en - st:X}\n")
    kinds = {}
    for k, _ in seeds.d.values():
        kinds[k] = kinds.get(k, 0) + 1
    print(f"[+] {len(seeds.d)} seeds {kinds}: {len(executed)} executed PCs, "
          f"{len(trapaddrs)} trap handlers, {nres} resources, {ndecl} decl-ROM code entries, "
          f"{nhints} table hints")


if __name__ == "__main__":
    main()
