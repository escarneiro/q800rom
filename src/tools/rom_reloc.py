"""
rom_reloc.py - Turn hard-coded addresses and offsets in the disassembled ROM into
label expressions, so that code and data can move.

Used by rom_disasm.py. Each rule records either
  * a data expression:        src.data_expr[off] = (size, expr, note)
  * an instruction rewrite:   src.ins_override[off] = text
All rewrites must still assemble to the original bytes; the verification loop
in rom_disasm.py drops any rewrite that does not (falls back to the number).

Rules (all verified on the original ROM):
  R1  data longs that point into the ROM (0x408xxxxx)       -> .long label
  R2  PC-relative word jump tables (movew %pc@(T,..); jmp %pc@(T,..))
                                                           -> .short target-T
      and bra.w tables reached by jmp %pc@(T,%dN:w:4) that were left as data
  R3  ROM header offsets (0x16, 0x1A, 0x22, 0x44..0x58)    -> .long label-rom_start
  R4  packed trap dispatch table (header 0x22)             -> re-encoded from labels
  R5  ROM resource map (header 0x1A) next/data offsets     -> .long label-rom_start
  R7  Universal ROM hardware tables: ProductInfo records (offset fields relative to the
      record), the self-relative machine list at 0x322C, and the "primitives" routine
      tables the records point to (offsets relative to the table start)
  R8  longs in a data table that are offsets from the table's label to a function entry
      (e.g. the device records at 0x40846040: base + [record+4] -> routine)
  R9  self-relative longs that point to a function entry
      (R8/R9 only accept exact function entries at least 0x40 bytes away)
  R10 tables of ROMBase-relative offsets to code (runs of >= 3 longs whose values are
      offsets of instruction starts, e.g. the Memory Manager vector tables at
      0x4080CB20 that boot code copies to $1E00/$1F00 adding ROMBase)
  R11 NuBus declaration data (sResource directories/lists): entries are an id byte and a
      24-bit offset relative to the entry; patched after linking (relocs.lst "s24")
  R12 driver headers (flags, delay, event mask, menu, then five word offsets of the
      open/prime/control/status/close routines, then the name ".xxx")
                                                           -> .short routine-header
  R13 diagnostic test tables (USTTESTS, USTSUBTESTS): 24-byte entries (id, code offset,
      name offset, ...) with offsets relative to the table start, ended by id -1
                                                           -> .long label-table
  R14 the declaration ROM's format block and the extended format header below it: the
      format block's directory offset; a list (id 1 -> an SExecBlock, DECL_SUPERINIT,
      whose code picks the sResource directory; id 0xFE -> the list of directories,
      DECL_DIRECTORIES), "s24" like R11; the SExecBlock's size and code offset as label
      expressions; every directory in the list is walked by R11. Names: DECL_FORMAT_BLOCK,
      DECL_EXT_HEADER, DECL_SUPERINIT(_code), DECL_DIRECTORIES, DECL_SRSRC_DIR
  R6  long-range PC-relative calls:
        lea N,%aX / movel #N,%dX ; jmp|jsr|lea|pea %pc@(B,%reg:l)
                                                           -> N written as (target-B)

False relocations: R1, R8-R10 guess from values alone and also catch plain numbers that
happen to look like addresses or offsets (they would change wrongly when code moves).
A final pass turns these back into numbers:
  F1  ROM-start/absolute references inside a ROM resource (fonts, pictures, color tables,
      IOP code, ...), except the resource map fields
  F2  table-relative references inside a resource whose target or base lies outside it
  F3  ROM-start/absolute references in the declaration ROM area (0x408F0000..)
  F4  tables of this ROM found by inspection to hold numbers (FALSE_TABLES below)
  F5  table-relative values that are masks or multiples of 0x10000
"""

import re
import struct

ROM_BASE = 0x40800000
ROM_SIZE = 0x100000
UNIMPL = 0x9AE6
TEST_TABLES = (0x46040, 0x460C6)    # USTTESTS, USTSUBTESTS (Quadra 800 ROM)
TEST_PATTERN = 0x5A932BC7           # NuBus declaration ROM test pattern


def s24_target(r, q):
    v = int.from_bytes(r[q + 1:q + 4], "big")
    return q + (v - 0x1000000 if v & 0x800000 else v)


def extended_header(r):
    """The declaration ROM's extended format header, or None:
    {'fb', 'eh', 'superinit', 'code', 'dirlist', 'dirs': [(entry, id, directory)]}.
    Layout below the 20-byte format block: entry id 1 -> SExecBlock, entry id 0xFE ->
    list of sResource directories, 0xFF000000, test pattern."""
    fb = ROM_SIZE - 20
    eh = fb - 16
    if u32(r, eh + 12) != TEST_PATTERN or u32(r, eh + 8) != 0xFF000000:
        return None
    if r[eh] != 0x01 or r[eh + 4] != 0xFE:
        return None
    sx, dl = s24_target(r, eh), s24_target(r, eh + 4)
    if not (0 <= sx < eh and 0 <= dl < eh):
        return None
    size = u32(r, sx)
    code = sx + 8 + struct.unpack(">i", r[sx + 8:sx + 12])[0]
    if sx + size != eh or not sx + 12 <= code < eh or r[sx + 4] != 2:
        return None
    dirs = []
    q = dl
    while r[q] != 0xFF and len(dirs) < 32:
        dirs.append((q, r[q], s24_target(r, q)))
        q += 4
    return {"fb": fb, "eh": eh, "superinit": sx, "code": code, "dirlist": dl, "dirs": dirs}
DECLROM = 0xF0000

# F4: ROM offset ranges (inclusive) of Quadra 800 data that hold numbers, not addresses;
# only ROM-start/absolute references are dropped there
FALSE_TABLES = [
    (0x0348E, 0x0349A, "I/O address halves in the universal tables"),
    (0x497EC, 0x49804, "test address pattern (0x706, 0x10706, ...)"),
    (0x8D200, 0x957AF, "FPSP floating-point constants"),
    (0x95960, 0x97B7F, "JMFB video parameters"),
    (0xB451C, 0xB47A8, "Power Manager primitives data"),
    (0xB6D2A, 0xB6D42, "cursor acceleration steps"),
    (0xD319E, 0xD31CA, "numeric sequence in steps of 0x400"),
]


def u16(r, o):
    return struct.unpack(">H", r[o:o + 2])[0]


def s16(r, o):
    return struct.unpack(">h", r[o:o + 2])[0]


def u32(r, o):
    return struct.unpack(">I", r[o:o + 4])[0]


class Relocator:
    def __init__(self, src):
        self.src = src
        self.rom = src.rom
        self.stats = {}
        self.created = set()        # labels created by ref() for relocations

    # ------------------------------------------------------------ helpers
    def ref(self, off):
        """Label name for a ROM offset (creates one if needed)."""
        src = self.src
        if off in src.labels:
            return src.labels[off]
        kind = "loc" if off in src.insns else "dat"
        name = f"{kind}_{ROM_BASE + off:08X}"
        src.labels[off] = name
        self.created.add(off)
        return name

    def is_data(self, off, size):
        src = self.src
        for k in range(off, off + size):
            if k in src.insns or k in src.inside:
                return False
            if k in src.data_cover:
                return False
        return True

    def add_data(self, off, size, expr, rule, note=""):
        if off in self.src.data_expr or not self.is_data(off, size):
            return False
        self.src.data_expr[off] = (size, expr, note)
        for k in range(off, off + size):
            self.src.data_cover.add(k)
        self.stats[rule] = self.stats.get(rule, 0) + 1
        return True

    def romoff(self, off):
        return f"{self.ref(off)}-rom_start"

    # ------------------------------------------------------------ rules
    def r1_data_pointers(self):
        r = self.rom
        for off in range(0, ROM_SIZE - 3, 2):
            v = u32(r, off)
            if ROM_BASE <= v < ROM_BASE + ROM_SIZE and self.is_data(off, 4):
                t = v - ROM_BASE
                if t in self.src.insns or t in self.src.labels:
                    self.add_data(off, 4, self.ref(t), "R1 data pointers")

    def r2_jump_tables(self):
        src, r = self.src, self.rom
        order = sorted(src.insns)
        pat_load = re.compile(r"^(movew|addaw|moveal|movel) %pc@\((0x[0-9a-f]+),%(d\d):(w)(:2)?\),(%[ad]\d)$")
        pat_jump = re.compile(r"^(jmp|jsr|lea|pea) %pc@\((0x[0-9a-f]+),%([ad]\d):w\)")
        pat_bra4 = re.compile(r"^(jmp|jsr) %pc@\((0x[0-9a-f]+),%(d\d):w:4\)$")
        for i, off in enumerate(order):
            t = src.insns[off].text
            m = pat_load.match(t)
            if m and m.group(1) in ("movew", "addaw"):
                table = int(m.group(2), 16) - ROM_BASE
                base = None
                if m.group(1) == "addaw":
                    # lea %pc@(T),%aX ; addaw %pc@(T,%dN:w),%aX ; jsr %aX@
                    base = table
                else:
                    dst = m.group(6)
                    for nxt in order[i + 1:i + 4]:
                        mj = pat_jump.match(src.insns[nxt].text)
                        if mj and "%" + mj.group(3) == dst:
                            base = int(mj.group(2), 16) - ROM_BASE
                            break
                if base is not None:
                    self._word_table(table, base)
            m4 = pat_bra4.match(t)
            if m4:
                self._bra_table(int(m4.group(2), 16) - ROM_BASE)

    def _word_table(self, table, base):
        src, r = self.src, self.rom
        k = table
        n = 0
        while k + 2 <= ROM_SIZE and n < 512:
            if k != table and (k in src.labels and not src.labels[k].startswith("dat_")):
                break
            if not self.is_data(k, 2) and k not in src.data_expr:
                break
            tgt = base + s16(r, k)
            if not (0 <= tgt < ROM_SIZE) or tgt not in src.insns:
                break
            if k not in src.data_expr:
                self.add_data(k, 2, f"{self.ref(tgt)}-{self.ref(base)}", "R2 word jump tables")
            k += 2
            n += 1

    def _bra_table(self, table):
        src, r = self.src, self.rom
        k = table
        n = 0
        while k + 4 <= ROM_SIZE and n < 256:
            if k in src.insns:            # already disassembled: labels handle it
                ins = src.insns[k]
                if ins.size != 4 or not ins.text.startswith(("braw", "jmp %pc@(", "bsrw")):
                    break
                k += 4
                n += 1
                continue
            op = u16(r, k)
            if op not in (0x6000, 0x4EFA) or not self.is_data(k, 4):
                break
            tgt = k + 2 + s16(r, k + 2)
            if not (0 <= tgt < ROM_SIZE):
                break
            self.add_data(k, 2, f"0x{op:04X}", "R2 bra tables")
            self.add_data(k + 2, 2, f"{self.ref(tgt)}-.", "R2 bra tables")
            k += 4
            n += 1

    def r3_header(self):
        r = self.rom
        for off in (0x16, 0x1A, 0x22, 0x44, 0x48, 0x4C, 0x50, 0x54, 0x58):
            v = u32(r, off)
            if 0 < v < ROM_SIZE:
                self.add_data(off, 4, self.romoff(v), "R3 ROM header offsets")

    def r4_trap_table(self):
        """Re-encode the packed dispatch table (same encoding classes as the original)."""
        src, r = self.src, self.rom
        s = u32(r, 0x22)
        start = s
        cur = 0
        entries = []
        while True:
            b = r[s]
            if b & 0x80 == 0:
                w = (b << 8) | r[s + 1]
                d = (w * 2) & 0xFFFF
                if d == 0:
                    entries.append(("end", s, 2, None))
                    s += 2
                    break
                if d & 0x8000:
                    d -= 0x10000
                cur += d
                entries.append(("w", s, 2, cur))
                s += 2
            else:
                c = b & 0x7F
                if c == 0:
                    entries.append(("u", s, 1, None))
                    s += 1
                elif c == 0x7F:
                    cur = u32(r, s + 1)
                    entries.append(("l", s, 5, cur))
                    s += 5
                else:
                    cur += c * 2
                    entries.append(("b", s, 1, cur))
                    s += 1
        if not self.is_data(start, s - start):
            return
        # The encoding needs (target-prev)/2, which GNU as cannot resolve across
        # relaxable code; the table is emitted with its original bytes and re-encoded
        # from the linked symbol addresses by tools/rom_postlink.py (traptable.lst).
        lines = ["trap_dispatch_table:"]
        lst = []
        for kind, off, size, tgt in entries:
            raw = ", ".join(f"0x{b:02X}" for b in r[off:off + size])
            if kind in ("w", "b", "l"):
                t = self.ref(tgt)
                lst.append(f"{kind} {t}")
                lines.append(f".byte   {raw}\t| {kind} {t}")
            else:
                lst.append(kind)
                lines.append(f".byte   {raw}\t| {'unimplemented' if kind == 'u' else 'end'}")
        self.src.data_block[start] = (s - start, lines,
                                      "packed trap dispatch table (decoded by the code at 0x40809A96; "
                                      "re-encoded after linking by tools/rom_postlink.py)")
        self.src.data_cover.update(range(start, s))
        self.src.trap_table_range = (start, s)
        self.src.trap_table_list = lst
        self.stats["R4 trap table entries"] = len(entries)

    def r5_resource_map(self):
        r = self.rom
        m = u32(r, 0x1A)
        first = u32(r, m)
        self.add_data(m, 4, self.romoff(first), "R5 resource map")
        off, seen = first, set()
        while off and off not in seen and off < ROM_SIZE:
            seen.add(off)
            nxt, data = struct.unpack(">II", r[off + 8:off + 16])
            if nxt:
                self.add_data(off + 8, 4, self.romoff(nxt), "R5 resource map")
            self.add_data(off + 12, 4, self.romoff(data), "R5 resource map")
            off = nxt

    def r6_long_calls(self):
        src, r = self.src, self.rom
        order = sorted(src.insns)
        pat = re.compile(r"^(jmp|jsr|lea|pea) %pc@\((0x[0-9a-f]+),%([ad]\d):l\)")
        for i, off in enumerate(order[1:], 1):
            m = pat.match(src.insns[off].text)
            if not m:
                continue
            prev = order[i - 1]
            pi = src.insns[prev]
            if prev + pi.size != off:
                continue
            base = int(m.group(2), 16) - ROM_BASE
            reg = m.group(3)
            op = u16(r, prev)
            rnum = int(reg[1])
            text = None
            if reg[0] == "a" and op == (0x41F9 | rnum << 9):          # lea abs.l,An
                n = u32(r, prev + 2)
                fmt = "lea ({e}):l,%{reg}"
            elif reg[0] == "a" and op == (0x41F8 | rnum << 9):        # lea abs.w,An
                n = s16(r, prev + 2)
                fmt = "lea ({e}):w,%{reg}"
            elif reg[0] == "a" and op == (0x207C | rnum << 9):        # movea.l #imm,An
                n = u32(r, prev + 2)
                fmt = "moveal #{e},%{reg}"
            elif reg[0] == "d" and op == (0x203C | rnum << 9):        # move.l #imm,Dn
                n = u32(r, prev + 2)
                fmt = "movel #{e},%{reg}"
            else:
                continue
            tgt = (base + n) & 0xFFFFFFFF
            if not 0 <= tgt < ROM_SIZE:
                continue
            e = f"{self.ref(tgt)}-{self.ref(base)}"
            src.ins_override[prev] = fmt.format(e=e, reg=reg)
            self.stats["R6 long-range relative calls"] = self.stats.get("R6 long-range relative calls", 0) + 1

    PI_OFFSET_FIELDS = (0x00, 0x04, 0x08, 0x0C, 0x28, 0x2C, 0x30, 0x34, 0x38)
    PI_PRIMITIVE_FIELDS = (0x30, 0x34, 0x38)

    def product_infos(self):
        """ProductInfo records (0x40 bytes), found by their flag signature."""
        r = self.rom
        recs = []
        for R in range(0, ROM_SIZE - 0x40, 2):
            if r[R + 0x10] not in (0x00, 0xCC, 0xDC, 0xDD) or r[R + 0x11] != 0:
                continue
            if u16(r, R + 0x14) not in (0x3FFF, 0x7FFF, 0xFFFF):
                continue
            offs = [struct.unpack(">i", r[R + f:R + f + 4])[0] for f in self.PI_OFFSET_FIELDS]
            if not any(offs):
                continue
            if all(v == 0 or 0 <= R + v < ROM_SIZE for v in offs):
                recs.append(R)
        return recs

    def r7_universal_tables(self):
        r = self.rom
        src = self.src
        # self-relative machine list (walked by the code at 0x40802F3E / 0x40802F94)
        o = 0x322C
        while struct.unpack(">i", r[o:o + 4])[0] != 0:
            t = o + struct.unpack(">i", r[o:o + 4])[0]
            if 0 <= t < ROM_SIZE:
                self.add_data(o, 4, f"{self.ref(t)}-.", "R7 machine list")
            o += 4
        for R in self.product_infos():
            if not self.is_data(R, 0x40):
                continue
            base = self.ref(R)
            for f in self.PI_OFFSET_FIELDS:
                v = struct.unpack(">i", r[R + f:R + f + 4])[0]
                if v == 0 or not 0 <= R + v < ROM_SIZE:
                    continue
                self.add_data(R + f, 4, f"{self.ref(R + v)}-{base}", "R7 ProductInfo offsets")
                if f in self.PI_PRIMITIVE_FIELDS:
                    self._primitives(R + v)

    def _primitives(self, T):
        r = self.rom
        src = self.src
        base = self.ref(T)
        k = T
        while k + 4 <= ROM_SIZE and k - T < 0x200:
            v = struct.unpack(">i", r[k:k + 4])[0]
            tgt = T + v
            if v != 0 and not (0 <= tgt < ROM_SIZE and tgt % 2 == 0):
                break
            if v != 0:
                if not self.add_data(k, 4, f"{self.ref(tgt)}-{base}", "R7 primitives entries") \
                        and k not in src.data_expr:
                    break
                self.code_hints.add(tgt)
            k += 4

    def function_entries(self):
        src = self.src
        ents = set()
        for off, name in src.labels.items():
            if name.startswith(("sub_", "trap_", "rsrc_")) and off in src.insns:
                ents.add(off)
        ents.update(o for o in src.funcs if o in src.insns)
        return ents

    def r8_r9_function_offsets(self):
        src, r = self.src, self.rom
        ents = self.function_entries()
        # R9: self-relative
        for p in range(0, ROM_SIZE - 3, 2):
            v = struct.unpack(">i", r[p:p + 4])[0]
            if abs(v) >= 0x40 and (p + v) in ents and self.is_data(p, 4):
                self.add_data(p, 4, f"{self.ref(p + v)}-.", "R9 self-relative function offsets")
        # R8: relative to a preceding data label; at least two hits per table
        data_labels = sorted(o for o, n in src.labels.items() if o not in src.insns)
        for L in data_labels:
            hits = []
            p = L
            while p + 4 <= ROM_SIZE and p - L < 0x800:
                if p in src.insns:
                    break
                if p != L and p in src.labels and not src.labels[p].startswith("dat_"):
                    break
                v = struct.unpack(">i", r[p:p + 4])[0]
                if abs(v) >= 0x40 and (L + v) in ents and self.is_data(p, 4):
                    hits.append((p, L + v))
                p += 4                       # table entries are long-aligned to the table
            if len(hits) >= 2:
                for p, t in hits:
                    self.add_data(p, 4, f"{self.ref(t)}-{self.ref(L)}", "R8 table-relative function offsets")

    def r10_rombase_offset_tables(self):
        src, r = self.src, self.rom
        starts = set(src.insns)
        p = 0
        while p < ROM_SIZE - 4:
            # a run of longs (stride 4) that are 0 or even in-ROM offsets
            run, hits, q = [], set(), p
            while q + 4 <= ROM_SIZE and self.is_data(q, 4):
                v = u32(r, q)
                if v == 0:
                    run.append((q, 0))
                elif 0x100 <= v < ROM_SIZE and v % 2 == 0:
                    run.append((q, v))
                    if v in starts:
                        hits.add(v)
                else:
                    break
                q += 4
            while run and run[-1][1] == 0:
                run.pop()
            nonzero = sum(1 for _, v in run if v)
            # >= 3 distinct instruction starts, and at least half of the entries
            if len(hits) >= 3 and len(hits) * 2 >= nonzero:
                for q2, v in run:
                    if v:
                        self.add_data(q2, 4, self.romoff(v), "R10 ROMBase-relative code tables")
                        self.code_hints.add(v)
                p = q
            else:
                p += 2

    def _slist(self, p):
        """Entries of a valid sResource list at p (strictly increasing ids, 0xFF end)."""
        r = self.rom
        ents, last = [], -1
        q = p
        while q + 4 <= ROM_SIZE and len(ents) < 128:
            i = r[q]
            if i == 0xFF:
                return ents if r[q + 1:q + 4] == b"\0\0\0" else None
            if i <= last or i == 0:
                return None
            v = int.from_bytes(r[q + 1:q + 4], "big")
            if v & 0x800000:
                v -= 0x1000000
            ents.append((q, i, v))
            last = i
            q += 4
        return None

    def r11_sresources(self):
        src, r = self.src, self.rom

        def is_rsrc(p):
            # real sResources start with sRsrcType (1) and sRsrcName (2 -> C string)
            ents = self._slist(p)
            if not ents or len(ents) < 2 or ents[0][1] != 1 or ents[1][1] != 2:
                return False
            q, _, v = ents[1]
            n = q + v
            if not 0 <= n < ROM_SIZE:
                return False
            e = r.find(b"\0", n, n + 64)
            return e > n and all(0x20 <= c < 0x7F for c in r[n:e])

        def is_dir(p):
            ents = self._slist(p)
            return bool(ents) and all(0 <= q + v < ROM_SIZE and is_rsrc(q + v) for q, _, v in ents)

        # roots: the directory named by the format block at the end of the ROM and every
        # directory whose entries all lead to real sResources
        fb = ROM_SIZE - 20
        d = int.from_bytes(r[fb + 1:fb + 4], "big")
        roots = [fb + (d - 0x1000000 if d & 0x800000 else d)]
        roots += [p for p in range(0, ROM_SIZE - 8, 2)
                  if r[p] not in (0, 0xFF) and r[p + 4] != 0 and is_dir(p)]
        xh = extended_header(r)
        if xh:
            roots += [d for _, _, d in xh["dirs"]]
        roots = [p for p in roots if is_dir(p)]
        seen = set()
        relocs = []

        def walk(p, kind):
            # kind: "dir" (entries -> sResources), "rsrc", "drvrdir", "gammadir", "mode"
            if p in seen:
                return
            seen.add(p)
            ents = self._slist(p)
            if not ents:
                return
            end = p + 4 * len(ents) + 4
            # entry ids whose 24 bits are a value, not an offset (Designing Cards and
            # Drivers: sRsrcFlags, sRsrcHWDevId, BoardId, STimeOut, BoardFlags; in video
            # mode lists mPageCnt and mDevType)
            data_ids = {"rsrc": {0x07, 0x08, 0x20, 0x23, 0x25}, "mode": {0x03, 0x04}}.get(kind, set())
            for q, i, v in ents:
                t = q + v
                if i in data_ids or not 0 <= t < ROM_SIZE or p <= t < end:
                    continue                 # data entry (value), not an offset
                if not self.is_data(q, 4):
                    continue
                relocs.append((q, t))
                sub = None
                if kind == "dir":
                    sub = "rsrc"
                elif kind == "rsrc" and i == 0x04:
                    sub = "drvrdir"
                elif kind == "rsrc" and i == 0x40:
                    sub = "gammadir"
                elif kind == "rsrc" and i >= 0x80:
                    sub = "mode"
                if kind == "rsrc" and i in (0x06, 0x22, 0x26) and t + 12 <= ROM_SIZE:
                    # sExecBlock: long size, rev, cpu, word, long code offset (from +8)
                    c = t + 8 + struct.unpack(">i", r[t + 8:t + 12])[0]
                    if t < c < t + u32(r, t):
                        self.exec_code.add(c)
                if sub and self._slist(t):
                    walk(t, sub)
        for p in roots:
            walk(p, "dir")
        for q, t in relocs:
            if q in src.data_expr:
                continue
            loc = self.ref(q)
            if self.add_data(q, 4, None, "R11 sResource offsets", f"s24 -> {self.ref(t)}"):
                src.post_relocs.append(f"s24 {loc} {self.ref(t)}")
        self.stats["R11 sResource roots"] = len(roots)

    def run(self):
        self.code_hints = set()
        self.exec_code = set()
        self.verified = set()       # offsets whose expression a rule checked structurally
        self.r7_universal_tables()
        self.r4_trap_table()
        self.r3_header()
        self.r5_resource_map()
        self.r13_test_tables()
        self.r2_jump_tables()
        self.r6_long_calls()
        self.r1_data_pointers()
        self.r14_extended_header()
        self.r11_sresources()
        self.r10_rombase_offset_tables()
        self.r8_r9_function_offsets()
        self.r12_driver_headers()
        self.drop_false_relocations()
        return self.stats

    def r14_extended_header(self):
        """Format block and extended format header of the declaration ROM (R14)."""
        src, r = self.src, self.rom
        xh = extended_header(r)
        if not xh:
            return
        names = {xh["fb"]: "DECL_FORMAT_BLOCK", xh["eh"]: "DECL_EXT_HEADER",
                 xh["eh"] + 4: "DECL_EXT_HEADER_FE_entry", xh["superinit"]: "DECL_SUPERINIT",
                 xh["code"]: "DECL_SUPERINIT_code", xh["dirlist"]: "DECL_DIRECTORIES"}
        for q, i, d in xh["dirs"]:
            if q != xh["dirlist"]:
                names[q] = "DECL_DIRECTORIES_%02X_entry" % i
            if i == 1:
                names[d] = "DECL_SRSRC_DIR"
        for off, n in names.items():
            src.labels[off] = n
        n = 0
        rel = [(xh["fb"], s24_target(r, xh["fb"])), (xh["eh"], xh["superinit"]),
               (xh["eh"] + 4, xh["dirlist"])] + [(q, d) for q, _, d in xh["dirs"]]
        for q, t in rel:
            if self.add_data(q, 4, None, "R14 extended format header", f"s24 -> {self.ref(t)}"):
                src.post_relocs.append(f"s24 {self.ref(q)} {self.ref(t)}")
                n += 1
        sx = xh["superinit"]
        self.add_data(sx, 4, "DECL_EXT_HEADER-DECL_SUPERINIT", "R14 extended format header",
                      "physical block size")
        self.add_data(sx + 8, 4, "DECL_SUPERINIT_code-.", "R14 extended format header", "code offset")
        self.verified.update((sx, sx + 8))    # checked by extended_header(): not false ones
        self.exec_code.add(xh["code"])

    def r13_test_tables(self):
        """Diagnostic test tables: code and name offsets relative to the table start."""
        r, n = self.rom, 0
        for base in TEST_TABLES:
            p = base
            while u32(r, p) != 0xFFFFFFFF and p < base + 0x1000:
                code, name = u32(r, p + 4), u32(r, p + 8)
                if code and code < ROM_SIZE:
                    self.add_data(p + 4, 4, f"{self.ref((base + code) % ROM_SIZE)}-{self.ref(base)}", "R13 test table offsets")
                if name and name < 0x1000:
                    self.add_data(p + 8, 4, f"{self.ref(base + name)}-{self.ref(base)}", "R13 test table offsets")
                p += 24
                n += 1
        self.stats["R13 test table entries"] = n

    def r12_driver_headers(self):
        """Device driver headers: the routine offsets are relative to the header."""
        r = self.rom
        seen = set()
        for m in re.finditer(rb"\.[A-Za-z][\x20-\x7e]{1,30}", r):
            p = m.start()
            n = r[p - 1]
            if not (2 <= n <= 31) or not all(0x20 <= c < 0x7F for c in r[p:p + n]):
                continue
            h = p - 1 - 0x12
            if h < 0 or h in seen:
                continue
            flags = u16(r, h)
            offs = struct.unpack(">5H", r[h + 8:h + 0x12])
            if flags & 0xFF or not flags & 0xFF00:
                continue
            if sum(1 for o in offs if o) < 3 or not all(o == 0 or (0x12 < o < 0x8000 and o % 2 == 0) for o in offs):
                continue
            seen.add(h)
            for k, o in enumerate(offs):
                if o:
                    self.add_data(h + 8 + 2 * k, 2, f"{self.ref(h + o)}-{self.ref(h)}", "R12 driver header offsets")
        self.stats["R12 driver headers"] = len(seen)

    # ------------------------------------------------------------ false relocations
    def resource_ranges(self):
        """[(entry, end, map field offsets)] of every ROM resource (map entry .. data end)."""
        r = self.rom
        m = u32(r, 0x1A)
        off, seen, out = u32(r, m), set(), []
        while off and off not in seen and off < ROM_SIZE:
            seen.add(off)
            data = u32(r, off + 12)
            end = data + u32(r, data - 8) - 12
            out.append((off, end))
            off = u32(r, off + 8)
        return out, m

    def drop_false_relocations(self):
        src = self.src
        res, mapptr = self.resource_ranges()
        fields = {mapptr} | {e + 8 for e, _ in res} | {e + 12 for e, _ in res}
        offs = {n: o for o, n in src.labels.items()}
        def owner(off):
            for lo, hi in res:
                if lo <= off < hi:
                    return lo, hi
            return None
        drop = {}
        for off, (size, expr, note) in src.data_expr.items():
            if expr is None or off in fields or off in getattr(self, "verified", ()):
                continue
            m = re.fullmatch(r"(\w+)(?:-(\w+|\.))?", expr)
            if not m or m.group(1) not in offs:
                continue
            tgt, base = offs[m.group(1)], m.group(2)
            form = "abs" if base is None else ("rom" if base == "rom_start" else "rel")
            if base == ".":                     # self-relative: base is the location itself
                base = None
                b = off
                v = (tgt - b) & ((1 << (8 * size)) - 1)
                if res_of_self := owner(off):
                    if not (res_of_self[0] <= tgt <= res_of_self[1]):
                        drop[off] = "F2 table-relative reference leaving its resource"
                        continue
                if off >= DECLROM:
                    drop[off] = "F3 self-relative reference in the declaration ROM"
                elif v in (0xFFFFFFFF, 0xFFFFFF00, 0xFFFF0000, 0x0000FFFF) or (v and size == 4 and v & 0xFFFF == 0):
                    drop[off] = "F5 table-relative mask or multiple of 0x10000"
                continue
            res_of = owner(off)
            rule = None
            if form in ("abs", "rom"):
                if res_of:
                    rule = "F1 ROM-start/absolute reference inside a ROM resource"
                elif off >= DECLROM:
                    rule = "F3 ROM-start/absolute reference in the declaration ROM"
                elif any(lo <= off <= hi for lo, hi, _ in FALSE_TABLES):
                    rule = "F4 known numeric table"
            elif base in offs:
                b = offs[base]
                v = (tgt - b) & ((1 << (8 * size)) - 1)
                if res_of and not (res_of[0] <= tgt <= res_of[1] and res_of[0] <= b <= res_of[1]):
                    rule = "F2 table-relative reference leaving its resource"
                elif v in (0xFFFFFFFF, 0xFFFFFF00, 0xFFFF0000, 0x0000FFFF) or (v and size == 4 and v & 0xFFFF == 0):
                    rule = "F5 table-relative mask or multiple of 0x10000"
            if rule:
                drop[off] = rule
        for off, rule in drop.items():
            size = src.data_expr.pop(off)[0]
            for k in range(off, off + size):
                src.data_cover.discard(k)
            key = rule.split(" ", 1)[0] + " false relocations dropped"
            self.stats[key] = self.stats.get(key, 0) + 1
        # labels created only for dropped references
        used = " ".join(e for _, e, _ in src.data_expr.values() if e) + " " + " ".join(src.ins_override.values())
        used += " " + " ".join(getattr(src, "trap_table_list", [])) + " " + " ".join(src.post_relocs)
        words = set(re.findall(r"\w+", used))
        for off in list(self.created):
            if src.labels.get(off) not in words and off not in src.insns:
                src.labels.pop(off, None)
                self.created.discard(off)
