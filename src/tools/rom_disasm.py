#!/usr/bin/env python3
"""
rom_disasm.py - Quadra 800 ROM -> reassemblable GNU m68k assembler source

Turns the ROM into labelled 68040 assembly that GNU as rebuilds byte for byte:

  * Code/data split comes from a Ghidra code map (tools/ghidra/Q800Export.java),
    seeded with runtime evidence (QEMU boot trace + live trap tables).
  * Instructions are disassembled with m68k objdump (MIT syntax); branch and
    PC-relative targets inside the ROM become labels, so code can be edited.
  * Trap handlers are named after their traps (trap_GetResource, ...), other
    functions sub_XXXXXXXX, branch targets loc_XXXXXXXX, data targets dat_XXXXXXXX.
  * With --rom-map, Apple's own labels (MPW ROM map, analysis/Quadra800ROM.lst) name
    their addresses: they replace sub_/loc_/dat_ names, are added as aliases next to
    other names (trap_NewHandle: NWHANDLE:), and label addresses nothing referenced.
    They are applied after the relocation analysis, so they only change names.
  * A-line trap words are written with trap macros (include/traps_gas.inc).
  * Text in data is written as strings (add_text): resource names and types from the
    resource map, Pascal strings with a matching length byte, reviewed text and
    four-character code tables (TEXT_* below), 'YEAH'/'Gary' fill as .rept blocks;
    instruction immediates that are four-character codes get a comment ('DRVR').
  * Every instruction is verified by assembling it at its exact offset. If GNU as
    picks a different encoding, alternative spellings are tried (abs.w/abs.l
    operand sizes, ...); as a last resort the raw words are emitted with the
    disassembly kept as a comment. The final source is checked byte for byte.

Usage:
  rom_disasm.py <rom> <codemap[,codemap2...]> <seeds.txt> <trap_table.c> <out_dir>
                [--rom-map <Apple ROM.List .lst>]
  (codemaps: Q800Export.java "I/F/S" lines and Q800ATraps.java "A" lines)
"""

import concurrent.futures as cf
import hashlib
import os
import re
import struct
import subprocess
import sys
import tempfile

from rom_reloc import Relocator, extended_header

ROM_BASE = 0x40800000
ROM_SIZE = 0x100000
PART_SIZE = 0x10000
RUN_MIN = 64

OBJDUMP = os.environ.get("M68K_OBJDUMP", "/usr/bin/m68k-suse-linux-objdump")
AS = os.environ.get("M68K_AS", "/usr/m68k-suse-linux/bin/as")
NM = os.environ.get("M68K_NM", "/usr/m68k-suse-linux/bin/nm")
LD = os.environ.get("M68K_LD", "/usr/m68k-suse-linux/bin/ld")
# Padding that ends at these offsets is written as ".org": everything from here to the
# end of the ROM (declaration ROM, format block) stays at a fixed address and the
# padding before it absorbs size changes of the code and data above.
ANCHORS = (0xF0000,)
OBJCOPY = os.environ.get("M68K_OBJCOPY", "/usr/bin/m68k-suse-linux-objcopy")

# ---- text in data (Quadra 800 ROM offsets; found with strings(1) and reviewed)
TEXT_EXCLUDE = [(0xBD250, 0xCE250),       # boot beep patches and sound samples
                (0x8D200, 0x957B0),       # FPSP constants
                (0x72EE0, 0x73910),       # color tables
                (0x7C430, 0x7EB90)]       # fonts
TEXT_PSTR_BAD = {0x5B1A4, 0xD54BC}        # length-prefixed runs that are not text
TEXT_PSTR_EXTRA = [(0x1D923, 5)]          # "Roman" (script name)
TEXT_BARE = [0x0A1BC, 0x0C228, 0x0C2C8, 0x4F0EC, 0x5E3E8, 0x5F038, 0x5FC20, 0x5FC53,
             0x96485, 0xD3C28, 0xD5B1F, 0xD9280, 0xDB7C0, 0xF0000, 0xFDFD3]
TEXT_CODE_TABLES = [(0x169A8, 0x16AA8, 8, 2),   # Gestalt selectors: off16, 'code', 0xFFFF
                    (0xE24CC, 0xE2524, 8, 0)]   # lmgr selector list: 'code', long
TEXT_FILLS = [(0x8A1F4, 639, b"YEAH"), (0x3D1C, 57, b"Gary"), (0x5378, 46, b"Gary"),
              (0x6C9C8, 5, b"Gary")]
OSTYPE_RE = re.compile(r"#(0x[0-9a-fA-F]{8}|\d{9,10})\b")

CC = "(?:t|f|hi|ls|cc|cs|ne|eq|vc|vs|pl|mi|ge|lt|gt|le|hs|lo)"
BRANCH_RE = re.compile(rf"^(?:b(?:ra|sr|{CC})[swl]?|db(?:ra|{CC})|fb\w+|fdb\w+|jbsr|jbra)$")
HEX_RE = re.compile(r"0x[0-9a-fA-F]+")
RELAX_RE = re.compile(rf"^b(ra|sr|{CC})[swl] ([A-Za-z_][\w.$]*)$")


# --------------------------------------------------------------------------- inputs

def load_codemap(paths):
    insns, funcs, strings = {}, {}, {}
    lines = []
    for path in paths.split(","):
        lines += open(path).readlines()
    for line in lines:
        p = line.split()
        if not p:
            continue
        a = int(p[1], 16) - ROM_BASE
        if not 0 <= a < ROM_SIZE:
            continue
        if p[0] == "I":
            insns[a] = int(p[2])
        elif p[0] == "A":                 # A-line trap word reached by code flow
            insns[a] = 2
        elif p[0] == "F":
            funcs[a] = p[2]
        elif p[0] == "S":
            strings[a] = int(p[2])
    return insns, funcs, strings


def load_seed_names(path):
    names = {}
    for line in open(path):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        p = line.split()
        if len(p) > 2 and p[1] in "CXL":
            names[int(p[0], 16) - ROM_BASE] = p[2]
    return names


def load_rom_map(path):
    """Apple MPW ROM map ("ROM.List" .lst): [(offset, name)] in file order."""
    out = []
    for line in open(path, errors="replace"):
        m = re.match(r"^(\S+)\s+Main\s+\$[0-9A-F]+,\$([0-9A-F]+)", line)
        if m and 0 <= int(m.group(2), 16) < ROM_SIZE:
            out.append((int(m.group(2), 16), m.group(1)))
    return out


GENERIC_RE = re.compile(r"\b(?:sub|loc|dat)_[0-9A-F]{8}\b")


def load_data_ranges(path):
    """Known data ranges ("ADDR D name SIZE" lines) and executed PCs from the seed file."""
    ranges, executed = [], set()
    for line in open(path):
        p = line.split()
        if len(p) >= 4 and p[1] == "D":
            st = int(p[0], 16) - ROM_BASE
            ranges.append((st, st + int(p[3], 16)))
        elif len(p) >= 2 and p[1] == "X":
            executed.add(int(p[0], 16) - ROM_BASE)
    return ranges, executed


def load_trap_names(path):
    traps = {}
    for m in re.finditer(r'\{ 0x(A[0-9A-F]{3})U, "(\w+)"', open(path).read()):
        traps[int(m.group(1), 16)] = m.group(2)
    return traps


# --------------------------------------------------------------------------- disassembly

def code_runs(insns):
    runs, start, end = [], None, None
    for a in sorted(insns):
        if start is not None and a == end:
            end = a + insns[a]
            continue
        if start is not None:
            runs.append((start, end))
        start, end = a, a + insns[a]
    if start is not None:
        runs.append((start, end))
    return runs


def objdump_run(args):
    rom_path, start, end = args
    out = subprocess.run(
        [OBJDUMP, "-D", "-b", "binary", "-m", "m68k:68040", "--insn-width=32",
         f"--adjust-vma=0x{ROM_BASE:X}",
         f"--start-address=0x{ROM_BASE + start:X}", f"--stop-address=0x{ROM_BASE + end:X}",
         rom_path], capture_output=True, text=True).stdout
    res = []
    for line in out.splitlines():
        m = re.match(r"^\s*([0-9a-f]+):\t([0-9a-f ]+)\t(.*)$", line)
        if not m:
            continue
        a = int(m.group(1), 16) - ROM_BASE
        n = len(m.group(2).replace(" ", "")) // 2
        res.append((a, n, m.group(3).strip()))
    return res


def disassemble(rom_path, runs, jobs):
    items = {}
    with cf.ThreadPoolExecutor(jobs) as ex:
        for res in ex.map(objdump_run, [(rom_path, s, e) for s, e in runs]):
            for a, n, text in res:
                items[a] = (n, text)
    return items


# --------------------------------------------------------------------------- source model

class Insn:
    __slots__ = ("off", "size", "text", "cands", "ci", "raw")

    def __init__(self, off, size, text):
        self.off, self.size, self.text = off, size, text
        self.cands, self.ci, self.raw = None, 0, False


IND_RE = re.compile(r"(%?[a-z0-9]*)@\((-?)([0-9a-f]+)([,)])")


def fix_syntax(text):
    """Rewrites objdump MIT syntax that GNU as reads differently."""
    mn, ops = split_mnemonic(text)
    if mn.startswith(("cinv", "cpush")):
        ops = re.sub(r"\b(bc|dc|ic|nc)\b", r"%\1", ops)

    # objdump prints index / memory-indirect displacements in hex without 0x,
    # but plain d16(An) displacements in decimal.
    def repl(m):
        reg, neg, num, term = m.groups()
        after = ops[m.end():]
        close = after.find(")") if term == "," else -1
        hexform = (term == "," or not reg or reg == ")" or after.startswith("@(")
                   or (close >= 0 and after[close + 1:].startswith("@(")))
        if not hexform or num.startswith("0x"):
            return m.group(0)
        return f"{reg}@({neg}0x{num}{term}"
    prev = None
    while prev != ops:
        prev = ops
        ops = IND_RE.sub(repl, ops)
    ops = re.sub(r"\)@\((-?)([0-9a-f]+)\)", lambda m: f")@({m.group(1)}0x{m.group(2)})", ops)
    # byte-sized immediates: the ROM stores #-8 as 0x00F8, GNU as as 0xFFF8
    if re.match(r"^\w+b$", mn):
        ops = re.sub(r"#-(\d+)\b", lambda m: f"#0x{(256 - int(m.group(1))) & 0xFF:02x}", ops)
    return f"{mn} {ops}".strip()


def split_mnemonic(text):
    p = text.split(None, 1)
    return p[0], (p[1] if len(p) > 1 else "")


def pcrel_targets(text):
    """Returns [(start, end, address)] spans of PC-relative ROM addresses in text."""
    mn, ops = split_mnemonic(text)
    spans = []
    base = len(text) - len(ops)
    for m in re.finditer(r"%pc@\((0x[0-9a-fA-F]+)", ops):
        spans.append((base + m.start(1), base + m.end(1), int(m.group(1), 16)))
    if BRANCH_RE.match(mn):
        m = re.search(r"(0x[0-9a-fA-F]+)\s*$", ops)
        if m:
            spans.append((base + m.start(1), base + m.end(1), int(m.group(1), 16)))
    return [s for s in spans if ROM_BASE <= s[2] < ROM_BASE + ROM_SIZE]


def abs_candidates(text):
    """Alternative spellings forcing abs.w / abs.l on bare absolute operands."""
    mn, ops = split_mnemonic(text)
    if mn.startswith("."):
        return []
    base = len(text) - len(ops)
    toks = []
    for m in HEX_RE.finditer(ops):
        s, e = m.start(), m.end()
        before = ops[:s].rstrip()
        if before.endswith("#") or before.endswith("@(") or ops[e:e + 1] in (":", ")", "@") \
                or "%pc@(" in ops[max(0, s - 6):s]:
            continue
        toks.append((base + s, base + e))
    if not toks or len(toks) > 3:
        return []
    out = []
    import itertools
    for combo in itertools.product(("", ":w", ":l"), repeat=len(toks)):
        if not any(combo):
            continue
        t = text
        for (s, e), suf in sorted(zip(toks, combo), reverse=True):
            t = t[:e] + suf + t[e:]
        out.append(t)
    return out


def pcrel_numeric(ins):
    """Spelling with literal displacements instead of labels (forward references
    to labels make GNU as pick a longer indexed/PC-relative form)."""
    spans = [sp for sp in pcrel_targets(ins.text) if "%pc@(" in ins.text[max(0, sp[0] - 5):sp[0]]]
    if not spans:
        return []
    t = ins.text
    for s_, e_, addr in sorted(spans, reverse=True):
        t = t[:s_] + str(addr - (ROM_BASE + ins.off + 2)) + t[e_:]
    return [t + "\x00NUM"]


def ostype_comment(text):
    """Append the four-character code of an immediate that is one ('DRVR')."""
    if "|" in text:
        return text
    m = OSTYPE_RE.search(text)
    if not m or int(m.group(1), 0) > 0xFFFFFFFF:
        return text
    s = int(m.group(1), 0).to_bytes(4, "big").decode("latin-1")
    if re.fullmatch(r"[A-Za-z][A-Za-z0-9 #]{3}", s) and sum(c.isalpha() for c in s) >= 3 and len(set(s)) > 1:
        return f"{text}\t| '{s}'"
    return text


def add_text(src):
    """Mark text in data (see TEXT_*): strings -> src.strings, fills -> src.fills."""
    rom = src.rom
    taken = bytearray(ROM_SIZE)
    for off, ins in src.insns.items():
        taken[off:off + ins.size] = b"\1" * ins.size
    for k in src.data_cover:
        taken[k] = 1
    for off, (size, *_r) in list(src.data_block.items()) + list(src.data_expr.items()):
        taken[off:off + size] = b"\1" * size
    for off, n in src.strings.items():
        taken[off:off + n] = b"\1" * n
    free = lambda a, b: 0 <= a and b <= ROM_SIZE and not any(taken[a:b])
    counts = {"resource names": 0, "resource types": 0, "Pascal strings": 0, "text": 0,
              "codes": 0, "fills": 0}
    def add(a, n, what):
        if n > 0 and free(a, a + n):
            src.strings[a] = n
            taken[a:a + n] = b"\1" * n
            counts[what] += 1
    u32 = lambda o: struct.unpack(">I", rom[o:o + 4])[0]
    e, seen = u32(u32(0x1A)), set()
    while e and e not in seen and e < ROM_SIZE:
        seen.add(e)
        add(e + 16, 4, "resource types")
        add(e + 24, rom[e + 23], "resource names")
        e = u32(e + 8)
    def wordy(t):
        letters = sum(c.isalpha() for c in t)
        return (sum(c.isalnum() or c in " .,:;!?()'-/&%+*#=_[]<>@" for c in t) >= 0.9 * len(t)
                and letters >= 0.55 * len(t) and sum(c in "aeiouyAEIOUY" for c in t) >= 0.2 * max(letters, 1)
                and len(set(t)) > 3 and not re.search(r"Nu|Nq|NV|Hn|Hz|J@|/<|YO", t))
    for m in re.finditer(rb"[\x20-\x7e\t]{5,}", rom):
        a, t = m.start(), m.group().decode("latin-1")
        if (a > 0 and rom[a - 1] == len(t) and a not in TEXT_PSTR_BAD and wordy(t)
                and not any(lo <= a < hi for lo, hi in TEXT_EXCLUDE) and free(a - 1, a)):
            add(a, len(t), "Pascal strings")
    for a, n in TEXT_PSTR_EXTRA:
        add(a, n, "Pascal strings")
    for a in TEXT_BARE:
        n = re.match(rb"[\x20-\x7e\t]*", rom[a:]).end()
        add(a, n, "text")
    for lo, hi, stride, at in TEXT_CODE_TABLES:
        for x in range(lo, hi, stride):
            add(x + at, 4, "codes")
    for a, n, unit in TEXT_FILLS:
        if rom[a:a + 4 * n] == unit * n and free(a, a + 4 * n):
            src.fills[a] = (n, unit)
            taken[a:a + 4 * n] = b"\1" * (4 * n)
            counts["fills"] += 1
    return counts


def esc_ascii(bs):
    out = []
    for b in bs:
        if b in (0x22, 0x5C):
            out.append("\\" + chr(b))
        elif 0x20 <= b < 0x7F:
            out.append(chr(b))
        else:
            out.append(f"\\{b:03o}")
    return "".join(out)


class RomSource:
    def __init__(self, rom, items, funcs, seed_names, strings, traps):
        self.rom = rom
        self.insns = {a: Insn(a, n, fix_syntax(t)) for a, (n, t) in items.items()}
        self.strings = strings
        self.traps = traps
        self.trap_macros = {}
        self.data_expr = {}       # off -> (size, expr, note)
        self.data_block = {}      # off -> (size, [lines], note)
        self.data_cover = set()
        self.ins_override = {}    # off -> symbolic instruction text
        self.override_failed = set()
        self.relax_failed = set()  # branches that must keep their explicit size
        self.trap_table_range = None
        self.post_relocs = []     # "s24 <loc> <target>" lines for tools/rom_postlink.py
        self.labels = {}
        self.fills = {}           # off -> (count, unit): repeated 4-byte text fill
        self.aliases = {}         # off -> [extra label names at the same address]
        self.rename = {}          # generic name (sub_/loc_/dat_) -> Apple ROM map name
        for a, n in funcs.items():
            self.labels[a] = n if not n.startswith("FUN_") else f"sub_{ROM_BASE + a:08X}"
        for a, n in seed_names.items():
            self.labels[a] = n
        # rename branch / pc-relative targets
        for ins in self.insns.values():
            for _, _, addr in pcrel_targets(ins.text):
                off = addr - ROM_BASE
                if off not in self.labels:
                    kind = "loc" if off in self.insns else "dat"
                    self.labels[off] = f"{kind}_{addr:08X}"
        self.labels.setdefault(0, "rom_start")
        # make names unique and assembler-safe
        seen = {}
        for off in sorted(self.labels):
            n = re.sub(r"[^A-Za-z0-9_.$]", "_", self.labels[off])
            if n in seen:
                n = f"{n}_{ROM_BASE + off:08X}"
            seen[n] = off
            self.labels[off] = n
        # instruction boundaries (labels inside an instruction become .set)
        self.inside = {}
        for ins in self.insns.values():
            for k in range(1, ins.size):
                self.inside[ins.off + k] = ins.off

    # ---- instruction text with labels
    def render(self, ins):
        if ins.raw:
            words = self.rom[ins.off:ins.off + ins.size]
            if ins.size % 2 == 0:
                vals = ", ".join(f"0x{int.from_bytes(words[i:i + 2], 'big'):04X}"
                                 for i in range(0, ins.size, 2))
                return f".short  {vals}\t| {ins.text}"
            return ".byte   " + ", ".join(f"0x{b:02X}" for b in words) + f"\t| {ins.text}"
        if ins.off in self.ins_override and ins.off not in self.override_failed:
            return self.ins_override[ins.off]
        text = ins.cands[ins.ci] if ins.cands else ins.text
        if text.endswith("\x00NUM"):
            return text[:-4]
        mn, ops = split_mnemonic(text)
        if mn == ".short" and ins.size == 2:
            w = int(ops, 16)
            if 0xA000 <= w <= 0xAFFF:
                name = self.trap_name(w)
                if name:
                    self.trap_macros[name] = w
                    return f"{name}"
                base = self.traps.get(0xA800 | (w & 0x3FF) if w & 0x0800 else 0xA000 | (w & 0xFF))
                if base:
                    flags = w & (0x0400 if w & 0x0800 else 0x0700)
                    kind = "autopop" if w & 0x0800 else "flags"
                    note = f" ({kind} 0x{flags:04X})" if flags else ""
                    return f".short  0x{w:04X}\t| {base}{note}"
        for s, e, addr in sorted(pcrel_targets(text), reverse=True):
            text = text[:s] + self.labels[addr - ROM_BASE] + text[e:]
        if ins.off not in self.relax_failed:
            m = RELAX_RE.match(text)
            if m:
                # size-choosing branch: GNU as picks the shortest form that reaches
                return f"jb{m.group(1)} {m.group(2)}"
        return text

    def trap_name(self, w):
        # Exact trap word (no modifier bits) gets a macro; others stay .short.
        if w & 0x0800:
            num = 0xA800 | (w & 0x3FF)
            if w & 0x0400:
                return None              # auto-pop bit set
        else:
            if w & 0x0F00:
                return None              # OS trap modifier bits set
            num = w
        n = self.traps.get(num)
        if not n or not re.match(r"^_[A-Za-z]\w*$", n) or "Unknown" in n or "Trap_" in n:
            return None
        if list(self.traps.values()).count(n) > 1:
            return None                  # name used for several trap numbers: ambiguous
        return n

    def fill_at(self, i):
        for fs, (n, unit) in self.fills.items():
            if fs <= i < fs + 4 * n:
                return fs, fs + 4 * n, unit
        return None

    @property
    def fill_starts(self):
        return set(self.fills)

    # ---- data emission
    def emit_data(self, out, start, end):
        i = start
        rom = self.rom
        while i < end:
            fill = self.fill_at(i)
            if fill:
                fs, fe, unit = fill
                stop = min(end, fe)
                k = (4 - (i - fs) % 4) % 4
                head = rom[i:min(i + k, stop)]
                if head:
                    out.append(f"    .ascii  \"{esc_ascii(head)}\"\t| {ROM_BASE + i:08X}")
                q = i + len(head)
                n = (stop - q) // 4
                if n:
                    out += [f"    .rept   {n}\t| {ROM_BASE + q:08X} fill",
                            f"    .ascii  \"{esc_ascii(unit)}\"", "    .endr"]
                q += 4 * n
                if q < stop:
                    out.append(f"    .ascii  \"{esc_ascii(rom[q:stop])}\"\t| {ROM_BASE + q:08X}")
                i = stop
                continue
            if i in self.strings:
                n = min(self.strings[i], end - i)
                out.append(f"    .ascii  \"{esc_ascii(rom[i:i + n])}\"")
                i += n
                continue
            j = i
            while j < end and rom[j] == rom[i]:
                j += 1
            if j in ANCHORS and j == end:
                out.append(f"    .org    0x{j:06X}, 0x{rom[i]:02X}\t| padding up to a fixed address")
                i = j
                continue
            if j - i >= RUN_MIN:
                out.append(f"    .fill   0x{j - i:X}, 1, 0x{rom[i]:02X}")
                i = j
                continue
            line_end = min(end, (i & ~0xF) + 0x10)
            k = i + 1
            while k < line_end and k not in self.strings and k not in self.fill_starts:
                r = k
                while r < end and rom[r] == rom[k] and r - k < RUN_MIN:
                    r += 1
                if r - k >= RUN_MIN:
                    break
                k += 1
            chunk = rom[i:k]
            if i % 4 == 0 and len(chunk) % 4 == 0:
                out.append("    .long   " + ", ".join(
                    f"0x{int.from_bytes(chunk[q:q + 4], 'big'):08X}" for q in range(0, len(chunk), 4))
                    + f"\t| {ROM_BASE + i:08X}")
            elif i % 2 == 0 and len(chunk) % 2 == 0:
                out.append("    .short  " + ", ".join(
                    f"0x{int.from_bytes(chunk[q:q + 2], 'big'):04X}" for q in range(0, len(chunk), 2))
                    + f"\t| {ROM_BASE + i:08X}")
            else:
                out.append("    .byte   " + ", ".join(f"0x{b:02X}" for b in chunk)
                           + f"\t| {ROM_BASE + i:08X}")
            i = k

    # ---- whole-source emission; verify=True puts .org before every instruction
    def emit(self, verify=False, part_size=PART_SIZE):
        """Returns list of (part_index, lines, line_to_insn)."""
        cuts = set(self.labels) | set(self.insns) | set(self.strings) | set(self.fills) | set(ANCHORS)
        for ins in self.insns.values():
            cuts.add(ins.off + ins.size)
        for off, (size, *_rest) in list(self.data_expr.items()) + list(self.data_block.items()):
            cuts.add(off)
            cuts.add(off + size)
        cuts |= {p * part_size for p in range(ROM_SIZE // part_size + 1)}
        cuts = sorted(c for c in cuts if c not in self.inside and c <= ROM_SIZE)
        parts = []
        out, linemap = [], {}
        part = 0
        sets = []
        for idx, c in enumerate(cuts):
            if c == ROM_SIZE:
                break
            if c // part_size != part or not out:
                if out:
                    parts.append((part, out, linemap))
                part = c // part_size
                out, linemap = [f"| ROM 0x{ROM_BASE + c:08X}..0x{ROM_BASE + c + part_size - 1:08X}"
                                f" (addresses in comments are those of the original ROM)"], {}
            nxt = cuts[idx + 1]
            if c in self.labels:
                name = self.labels[c]
                is_func = c in self.insns and not name.startswith("loc_")
                if is_func:
                    out.append("")
                out.append(f"{name}:")
                out += [f"{a}:" for a in self.aliases.get(c, ())]
            if c in self.insns:
                ins = self.insns[c]
                if verify:
                    out.append(f"__v_{c:X}:")
                linemap[len(out) + 1] = ins
                out.append(f"    {ostype_comment(self.render(ins))}")
            elif c in self.data_block:
                size, lines, note = self.data_block[c]
                out.append(f"| {note}")
                out += [l if l.endswith(":") else f"    {l}" for l in lines]
            elif c in self.data_expr:
                size, expr, note = self.data_expr[c]
                if expr is None:              # patched after linking: original bytes here
                    raw = ", ".join(f"0x{b:02X}" for b in self.rom[c:c + size])
                    out.append(f"    .byte   {raw}\t| {ROM_BASE + c:08X} {note}")
                else:
                    d = {1: ".byte ", 2: ".short", 4: ".long "}[size]
                    out.append(f"    {d}  {expr}\t| {ROM_BASE + c:08X}{(' ' + note) if note else ''}")
            else:
                self.emit_data(out, c, nxt)
        parts.append((part, out, linemap))
        for off, base in sorted(self.inside.items()):
            if off in self.labels:
                for n in [self.labels[off]] + self.aliases.get(off, []):
                    sets.append(f"    .set    {n}, {self.labels.get(base) or f'.Lmid_{base:X}'} + {off - base}")
        if self.rename:
            parts = [(p, [self.rn(l) for l in lines], lm) for p, lines, lm in parts]
            sets = [self.rn(l) for l in sets]
        return parts, sets

    def apply_rom_map(self, entries):
        """Name addresses with Apple's labels. Run after the relocation analysis: the
        label set it saw is unchanged, references keep their (renamed) targets."""
        used = set(self.labels.values())
        stats = {"renamed": 0, "aliases": 0, "new": 0}
        for off, name in entries:
            if name in used:
                name = f"{name}_{ROM_BASE + off:08X}"
                if name in used:
                    continue
            used.add(name)
            cur = self.labels.get(off)
            if cur is None:
                self.labels[off] = name
                stats["new"] += 1
            elif GENERIC_RE.fullmatch(cur) and cur not in self.rename:
                self.rename[cur] = name
                stats["renamed"] += 1
            else:
                self.aliases.setdefault(off, []).append(name)
                stats["aliases"] += 1
        return stats

    def rn(self, text):
        """Apply the Apple-name renames to emitted text."""
        if not self.rename:
            return text
        return GENERIC_RE.sub(lambda m: self.rename.get(m.group(0), m.group(0)), text)

    def compute_inside(self):
        self.inside = {}
        for ins in self.insns.values():
            for k in range(1, ins.size):
                self.inside[ins.off + k] = ins.off
        for off, (size, *_rest) in list(self.data_expr.items()) + list(self.data_block.items()):
            for k in range(1, size):
                self.inside[off + k] = off

    def mid_anchor_labels(self):
        """Instructions that contain a label must have a label themselves."""
        for off, base in self.inside.items():
            if off in self.labels and base not in self.labels:
                kind = "loc" if base in self.insns else "dat"
                self.labels[base] = f"{kind}_{ROM_BASE + base:08X}"


# --------------------------------------------------------------------------- assemble + verify

def link(obj, elf, binf):
    r = subprocess.run([LD, f"-Ttext=0x{ROM_BASE:X}", "-e", f"0x{ROM_BASE:X}", "--no-warn-rwx-segments",
                        "-o", elf, obj], capture_output=True, text=True)
    if r.returncode != 0:
        return r.stderr
    subprocess.run([OBJCOPY, "-O", "binary", "--only-section=.text", elf, binf], check=True)
    return None


def assemble(src_text, inc_dir, workdir):
    s = os.path.join(workdir, "v.s")
    o = os.path.join(workdir, "v.o")
    e = os.path.join(workdir, "v.elf")
    b = os.path.join(workdir, "v.bin")
    with open(s, "w") as f:
        f.write(src_text)
    r = subprocess.run([AS, "-m68040", "-I", inc_dir, s, "-o", o], capture_output=True, text=True)
    errs = {}
    for line in r.stderr.splitlines():
        m = re.match(r"^.*?v\.s:(\d+): (Error|Warning): (.*)$", line)
        if m and m.group(2) == "Error":
            errs[int(m.group(1))] = m.group(3)
    if r.returncode != 0:
        if not errs:
            sys.exit("Assembly failed:\n" + r.stderr[:3000])
        return None, errs
    err = link(o, e, b)
    if err:
        sys.exit("Link failed:\n" + err[:3000])
    marks = {}
    nm = subprocess.run([NM, e], capture_output=True, text=True).stdout
    for line in nm.splitlines():
        p = line.split()
        if len(p) == 3 and p[2].startswith("__v_"):
            marks[int(p[2][4:], 16)] = int(p[0], 16) - ROM_BASE
    return (open(b, "rb").read(), marks), errs


def trap_macro_file(macros):
    lines = ["| traps_gas.inc - A-line trap macros used by the disassembled ROM source",
             "| (generated by tools/rom_disasm.py)", ""]
    for name, w in sorted(macros.items(), key=lambda kv: kv[1]):
        lines += [f"    .macro  {name}", f"    .short  0x{w:04X}", "    .endm"]
    return "\n".join(lines) + "\n"


def main():
    if len(sys.argv) < 6:
        print(__doc__)
        sys.exit(1)
    rom_path, codemap, seeds, trapc, out_dir = sys.argv[1:6]
    rom_map = None
    if "--rom-map" in sys.argv[6:]:
        rom_map = sys.argv[sys.argv.index("--rom-map") + 1]
    rom = open(rom_path, "rb").read()
    assert len(rom) == ROM_SIZE

    insns, funcs, strings = load_codemap(codemap)
    ranges, executed = load_data_ranges(seeds)
    inrange = bytearray(ROM_SIZE)
    for st, en in ranges:
        inrange[st:en] = b"\1" * (en - st)
    dropped = [a for a, n in insns.items() if any(inrange[a:a + n]) and a not in executed]
    for a in dropped:
        del insns[a]
    funcs = {a: n for a, n in funcs.items() if a in insns}
    print(f"[*] {len(dropped)} instructions inside known data resources kept as data")
    runs = code_runs(insns)
    # code the code map may lack: the declaration ROM's SuperInit routine (rom_reloc R14)
    xh = extended_header(rom)
    if xh and not any(xh["code"] < e and s < xh["eh"] for s, e in runs):
        runs.append((xh["code"], xh["eh"]))
        print(f"[*] declaration ROM SuperInit code at 0x{ROM_BASE + xh['code']:08X} added")
    items = disassemble(rom_path, sorted(runs), os.cpu_count() or 4)
    # objdump's own boundaries win; drop anything overlapping a previous insn
    clean, last_end = {}, 0
    for a in sorted(items):
        n, t = items[a]
        if a < last_end:
            continue
        if t.startswith(".short") and n == 2 and not 0xA000 <= int(t.split()[1], 16) <= 0xAFFF:
            continue                      # undecodable word: leave as data
        clean[a] = (n, t)
        last_end = a + n
    strings = {a: n for a, n in strings.items()
               if not any(a <= x < a + n for x in range(a, a + n) if x in clean)}

    src = RomSource(rom, clean, funcs, load_seed_names(seeds), strings, load_trap_names(trapc))
    src.funcs = funcs
    relocator = Relocator(src)
    stats = relocator.run()
    # code locations found through tables (fed back to the next Ghidra run as seeds)
    hints_path = os.path.join(os.path.dirname(os.path.abspath(codemap.split(",")[0])), "code_hints.txt")
    with open(hints_path, "w") as f:
        f.write("# Code entry points found in ROM tables by tools/rom_reloc.py (C = code seed)\n")
        for o in sorted(relocator.code_hints | relocator.exec_code):
            if o not in src.insns:
                f.write(f"{ROM_BASE + o:08X} C\n")
    for k, v in sorted(stats.items()):
        print(f"[*] symbolized: {k}: {v}")
    # strings overlapping symbolized data are dropped
    src.strings = {a: n for a, n in src.strings.items()
                   if not any(x in src.data_cover for x in range(a, a + n))}
    tc = add_text(src)
    print("[*] text in data: " + ", ".join(f"{v} {k}" for k, v in tc.items()))
    if rom_map:
        st = src.apply_rom_map(load_rom_map(rom_map))
        print(f"[*] Apple ROM map names: {st['renamed']} replace generated names, "
              f"{st['aliases']} aliases, {st['new']} new labels")
    src.compute_inside()
    src.mid_anchor_labels()
    src.compute_inside()
    print(f"[*] {len(src.insns)} instructions, {len(src.labels)} labels, {len(strings)} strings")

    inc_dir = os.path.join(out_dir, "include")
    os.makedirs(inc_dir, exist_ok=True)
    workobj = tempfile.TemporaryDirectory(prefix="q800dis_")
    work = workobj.name

    # ---- verification loop: whole ROM in one file, .org before every instruction
    for it in range(12):
        src.trap_macros = {}
        parts, sets = src.emit(verify=True, part_size=ROM_SIZE)
        _, lines, linemap = parts[0]
        body = "\n".join(lines)
        with open(os.path.join(inc_dir, "traps_gas.inc"), "w") as f:
            f.write(trap_macro_file(src.trap_macros))
        hdr = "    .include \"traps_gas.inc\"\n    .text\n" + ("" if src.labels.get(0) == "rom_start" else "rom_start:\n")
        text = hdr + body + "\n" + "\n".join(sets) + "\n"
        shift = hdr.count("\n")
        binary, errs = assemble(text, inc_dir, work)
        bad = set()
        for ln, msg in errs.items():
            ins = linemap.get(ln - shift)
            if ins is None:
                sys.exit(f"Unmapped assembler error at line {ln}: {msg}")
            bad.add(ins)
        if binary is not None:
            binary, marks = binary
            order = sorted(src.insns)
            # an instruction assembled to the wrong size shifts the next marker
            for a, b in zip(order, order[1:] + [None]):
                da = marks[a] - a
                db = (marks[b] - b) if b is not None else da
                if da != db:
                    bad.add(src.insns[a])
            if not bad and any(marks[a] != a for a in order):
                sys.exit("Global offset mismatch")
            if not bad:
                binary = binary.ljust(ROM_SIZE, b"\0")
                for ins in src.insns.values():
                    if binary[ins.off:ins.off + ins.size] != rom[ins.off:ins.off + ins.size]:
                        bad.add(ins)
            if not bad:
                dropped = 0
                for off, (size, *_r) in list(src.data_expr.items()) + list(src.data_block.items()):
                    if binary[off:off + size] != rom[off:off + size]:
                        d = next(i for i in range(size) if binary[off + i] != rom[off + i])
                        print(f"    dropped expression at 0x{ROM_BASE + off:08X} (size {size}): first "
                              f"difference at +0x{d:X}: built {binary[off + d:off + d + 4].hex()} "
                              f"original {rom[off + d:off + d + 4].hex()}")
                        src.data_expr.pop(off, None)
                        src.data_block.pop(off, None)
                        dropped += 1
                if dropped:
                    print(f"    pass {it}: {dropped} data expressions did not reproduce the ROM; kept as numbers")
                    src.compute_inside()
                    continue
                if binary[:ROM_SIZE] != rom:
                    first = next(i for i in range(ROM_SIZE) if binary[i] != rom[i])
                    sys.exit(f"Data mismatch at 0x{first:06X} not explained by any rewrite")
        if not bad:
            break
        for ins in bad:
            if ins.off in src.ins_override and ins.off not in src.override_failed:
                src.override_failed.add(ins.off)
                continue
            if ins.off not in src.relax_failed and src.render(ins).startswith("jb"):
                src.relax_failed.add(ins.off)
                continue
            if ins.cands is None:
                ins.cands = [ins.text] + abs_candidates(ins.text) + pcrel_numeric(ins)
                ins.ci = 0
            ins.ci += 1
            if ins.ci >= len(ins.cands):
                ins.raw = True
    else:
        sys.exit("Verification did not converge")

    # ---- final, split source
    src.trap_macros = {}
    parts, sets = src.emit(verify=False)
    for p in os.listdir(out_dir):
        if re.match(r"part_[0-9A-F]{2}\.s$", p):
            os.remove(os.path.join(out_dir, p))
    for part, lines, _ in parts:
        with open(os.path.join(out_dir, f"part_{part:02X}.s"), "w") as f:
            f.write("\n".join(lines) + "\n")
    with open(os.path.join(inc_dir, "traps_gas.inc"), "w") as f:
        f.write(trap_macro_file(src.trap_macros))
    digest = hashlib.sha256(rom).hexdigest()
    top = ["| q800rom.s - Macintosh Quadra 800 ROM, disassembled to 68040 GNU as source",
           "| Generated by tools/rom_disasm.py from a Ghidra code map seeded with QEMU",
           "| boot traces. Rebuilds the original ROM byte for byte",
           f"| (SHA-256 {digest}).",
           "| Comments start with '|'. Addresses in comments are ROM addresses (ROMBase 0x40800000).",
           "",
           "    .include \"traps_gas.inc\"",
           "    .text"]
    if src.labels.get(0) != "rom_start":
        top.append("rom_start:")
    top += [f"    .include \"part_{p:02X}.s\"" for p, _, _ in parts]
    top += ["", "| Labels that point inside an instruction"] + sets + [""]
    with open(os.path.join(out_dir, "q800rom.s"), "w") as f:
        f.write("\n".join(top))
    with open(os.path.join(out_dir, "traptable.lst"), "w") as f:
        f.write("# Packed trap dispatch table at label trap_dispatch_table: one entry per line\n"
                "# w/b/l <target label> = word/byte/long encoded entry, u = unimplemented, end\n")
        f.write(src.rn("\n".join(getattr(src, "trap_table_list", []))) + "\n")
    with open(os.path.join(out_dir, "relocs.lst"), "w") as f:
        f.write("# Post-link relocations applied by tools/rom_postlink.py\n"
                "# s24 <loc> <target>: byte loc+1..3 = 24-bit (target - loc) (NuBus sResource entry)\n")
        f.write(src.rn("\n".join(src.post_relocs)) + "\n")
    with open(os.path.join(out_dir, "q800rom.sha256"), "w") as f:
        f.write(f"{digest}  QUADRA800_REBUILT.ROM\n")

    # ---- final check of the real, split source
    r = subprocess.run([AS, "-m68040", "-I", out_dir, "-I", inc_dir, os.path.join(out_dir, "q800rom.s"),
                        "-o", os.path.join(work, "f.o")], capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit("Final assembly failed:\n" + r.stderr[:3000])
    err = link(os.path.join(work, "f.o"), os.path.join(work, "f.elf"), os.path.join(work, "f.bin"))
    if err:
        sys.exit("Final link failed:\n" + err[:3000])
    final = open(os.path.join(work, "f.bin"), "rb").read()
    raw = sum(1 for i in src.insns.values() if i.raw)
    code_bytes = sum(i.size for i in src.insns.values())
    print(f"[+] {len(parts)} parts written to {out_dir}; {len(src.insns)} instructions "
          f"({code_bytes} bytes of code), {raw} emitted as raw words")
    print("[+] Byte-exact rebuild:", "YES" if final == rom else "NO")
    sys.exit(0 if final == rom else 1)


if __name__ == "__main__":
    main()
