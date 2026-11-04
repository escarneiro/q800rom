#!/usr/bin/env python3
"""disasm_raw.py - turn code that is still raw data in romsrc/ into instructions.

Some code in the generated source is still written as .long/.short/.byte data (the code
map did not reach it). This finds it from places that are certainly code and follows the
control flow from there:

  - seeds: addresses inside raw data lines that existing instructions branch or jump to
    (bra/bsr/b<cc>/db<cc>/jmp/jsr/jbra/jbsr ...), the routines of every 'DRVR' header in
    the given files, and the addresses listed with --seeds;
  - from each seed, instructions are decoded (objdump) and followed until an unconditional
    transfer (bra, jmp, rts, rte, rtd, rtr); branch targets inside raw data become new
    seeds. Raw data that nothing proves to be code stays data.

Each instruction is checked on its own before it is written: it is assembled with its
branch and PC-relative targets placed at the right distance, and the bytes must equal the
ROM's; otherwise (an encoding the assembler would choose differently, an A-line trap) it
is kept as .short words with the disassembly as a comment, as elsewhere in romsrc.
Branch and PC-relative targets are written as labels: existing ones, or new ones named
ROUTINE_offset after the nearest label before them. Labels needed outside the converted
code are added first with tools/name_addresses.py.

With --lea, also the targets of lea/pea %pc@(X) inside raw data whose bytes decode as
code (completion routines, continuations).

With --seeds-only, exactly the instructions at the addresses listed with --seeds (one
each, no control flow followed: for a list of every instruction start, e.g. from
tools/export_fixups.py).
With --stop FILE ("START END" lines, hex), decoding never enters those bytes.

Usage:  disasm_raw.py ROMSRC ROM FILE.s... [--seeds FILE] [--seeds-only] [--lea] [--dry-run]
        (FILE.s relative to ROMSRC; ROM: the image the current source builds)
"""
import bisect
import os
import re
import subprocess
import sys
import tempfile

ROM_BASE = 0x40800000
TOOLS = os.path.dirname(os.path.abspath(__file__))
AS = os.environ.get('M68K_AS', '/usr/m68k-suse-linux/bin/as')
LD = os.environ.get('M68K_LD', '/usr/m68k-suse-linux/bin/ld')
NM = os.environ.get('M68K_NM', '/usr/m68k-suse-linux/bin/nm')
OBJDUMP = os.environ.get('M68K_OBJDUMP', '/usr/bin/m68k-suse-linux-objdump')
OBJCOPY = os.environ.get('M68K_OBJCOPY', '/usr/bin/m68k-suse-linux-objcopy')
ANN = re.compile(r'\|\s*([0-9A-F]{8})\b')
DATA = re.compile(r'^\s+\.(long|short|byte)\s+([^|]*?)\s*(\|.*)?$')
LABEL = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*):')
BRANCH = re.compile(r'^(b(ra|sr|hi|ls|cc|cs|ne|eq|vc|vs|pl|mi|ge|lt|gt|le)[swl]?|'
                    r'db(t|f|ra|hi|ls|cc|cs|ne|eq|vc|vs|pl|mi|ge|lt|gt|le)|'
                    r'fb\w+|fdb\w+)$')
STOP = {'rts', 'rte', 'rtr', 'rtd', 'jmp', 'bras', 'braw', 'bral', 'stop', 'illegal'}


def numeric_data(line):
    m = DATA.match(re.sub(r'/\*.*?\*/', '', line))
    if not m:
        return None
    size = {'long': 4, 'short': 2, 'byte': 1}[m.group(1)]
    out = bytearray()
    for v in m.group(2).split(','):
        v = v.strip()
        if not re.fullmatch(r'-?(0x[0-9A-Fa-f]+|\d+)', v):
            return None
        out += (int(v, 0) & ((1 << (8 * size)) - 1)).to_bytes(size, 'big')
    return bytes(out)


class Source:
    """Raw data lines (with an address annotation and plain numbers) of the given files."""

    def __init__(self, root, files):
        self.root, self.files = root, files
        self.raw = []                                      # (start, end, file, line index)
        for f in files:
            for i, line in enumerate(open(os.path.join(root, f)).read().split('\n')):
                m = ANN.search(line)
                b = numeric_data(line)
                if m and b:
                    a = int(m.group(1), 16)
                    self.raw.append((a, a + len(b), f, i))
        self.raw.sort()
        self.keys = [r[0] for r in self.raw]

    def line_at(self, a):
        k = bisect.bisect_right(self.keys, a) - 1
        if k >= 0 and self.raw[k][0] <= a < self.raw[k][1]:
            return self.raw[k]
        return None

    def raw_run(self, a, n):
        """True if the n bytes at a are all inside raw data lines."""
        x = a
        while x < a + n:
            r = self.line_at(x)
            if not r:
                return False
            x = r[1]
        return True


def symbols(elf):
    out = subprocess.run([NM, elf], capture_output=True, text=True, check=True).stdout
    by_addr, by_name = {}, {}
    for line in out.splitlines():
        f = line.split()
        if len(f) == 3:
            a = int(f[0], 16)
            by_addr.setdefault(a, []).append(f[2])
            by_name[f[2]] = a
    return by_addr, by_name


def decode(romfile, a, cache={}):
    """(text, length) of the instruction at a, or None."""
    if a in cache:
        return cache[a]
    out = subprocess.run([OBJDUMP, '-D', '-b', 'binary', '-m', 'm68k:68040',
                          '--adjust-vma=0x%X' % ROM_BASE, '--start-address=0x%X' % a,
                          '--stop-address=0x%X' % (a + 24), romfile],
                         capture_output=True, text=True).stdout
    ins = []
    for line in out.splitlines():
        m = re.match(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{4} ?)+)\s+(\S.*)$', line)
        if m:                                   # (continuation lines carry only bytes)
            ins.append((int(m.group(1), 16), m.group(3).strip()))
    res = None
    if len(ins) >= 2 and ins[0][0] == a:
        text = ins[0][1]
        m = re.match(r'^\.short 0x(a[0-9a-f]{3})$', text)
        if m:                                   # A-line trap: a system call, 2 bytes
            res = ('.short 0x%s' % m.group(1).upper().replace('0X', ''), 2)
        elif not text.startswith('.short') and 'unknown' not in text:
            res = (text, ins[1][0] - a)
    cache[a] = res
    return res


def targets(text):
    """ROM addresses an instruction refers to (branch targets, PC-relative operands)."""
    mnem = text.split()[0]
    out = []
    if BRANCH.match(mnem) or mnem in ('jmp', 'jsr'):
        m = re.search(r'(?:^|,|\s)0x([0-9a-f]{8})$', text)
        if m and BRANCH.match(mnem):
            out.append(('branch', int(m.group(1), 16)))
    for m in re.finditer(r'%pc@\(0x([0-9a-f]{8})', text):
        out.append(('pcrel', int(m.group(1), 16)))
    return out


def check(text, a, length, rom, tmp):
    """Assemble text (with targets as symbols) at a; True if the bytes equal the ROM's."""
    syms = {}

    def sub(m):
        t = int(m.group(1), 16)
        syms.setdefault(t, 'T%d' % len(syms))
        return syms[t]
    src = re.sub(r'0x(408[0-9a-f]{5})', sub, text)
    lines = ['    .text', '    .org 0x100000', 'L0: ' + src]
    for t, n in syms.items():
        lines.append('    .set %s, L0%+d' % (n, t - a))
    s, o, b = os.path.join(tmp, 'c.s'), os.path.join(tmp, 'c.o'), os.path.join(tmp, 'c.bin')
    open(s, 'w').write('\n'.join(lines) + '\n')
    if subprocess.run([AS, '-m68040', s, '-o', o], capture_output=True).returncode:
        return False, src
    subprocess.run([OBJCOPY, '-O', 'binary', '--only-section=.text', o, b], check=True)
    got = open(b, 'rb').read()[0x100000:]
    return got == rom[a - ROM_BASE:a - ROM_BASE + length], src      # same bytes, same length


START = re.compile(r'^(lea|pea|move[abwlmq]*|moveal|moveml|link\w*|tst[bwl]|cmp\w*|clr[bwl]|bsr[sw]?|'
                   r'jsr|subq[bwl]|addq[bwl])$')


def looks_like_code(romfile, src, a, n=6):
    """Bytes at a decode like the start of a routine: a typical first instruction, then
    at least three instructions, none of the forms data tends to decode as."""
    seq = []
    for _ in range(n):
        d = decode(romfile, a)
        if not d or not src.raw_run(a, d[1]):
            break
        seq.append(d)
        if d[0].split()[0] in STOP:
            break
        a += d[1]
    if len(seq) < 3 and not (len(seq) >= 2 and seq[-1][0].split()[0] in STOP):
        return False
    if not START.match(seq[0][0].split()[0]):
        return False
    for k, (text, ln) in enumerate(seq):
        mnem = text.split()[0]
        if mnem.startswith(('ori', 'chk', 'negx')):
            return False
        if k and text == seq[k - 1][0]:                 # repeated: a data pattern
            return False
        for v in re.findall(r'(?<![#@(\w])0x([0-9a-f]+)\b', text):  # absolute addresses
            x = int(v, 16)
            if not (x < 0x10000 or 0x40800000 <= x < 0x40900000 or 0x50000000 <= x < 0x60000000):
                return False
        if mnem[-1:] in ('w', 'l') and re.search(r'@\((-?\d*[13579])[,)]', text):
            return False                                # word/long access at an odd offset
    return True


def drvr_entries(rom, src):
    """Routine offsets of 'DRVR' headers found at the start of resource data / sBlocks."""
    out = []
    for f in src.files:
        text = open(os.path.join(src.root, f)).read()
        for m in re.finditer(r'data at 0x([0-9A-F]{8})', text):
            hdr = int(m.group(1), 16)
            out += header_routines(rom, hdr)
    return out


def header_routines(rom, hdr):
    o = hdr - ROM_BASE
    n = rom[o + 0x12]
    name = rom[o + 0x13:o + 0x13 + n]
    if not (n and name[:1] == b'.' and all(32 < c < 127 for c in name)):
        return []
    return [hdr + int.from_bytes(rom[o + 8 + 2 * k:o + 10 + 2 * k], 'big')
            for k in range(5) if int.from_bytes(rom[o + 8 + 2 * k:o + 10 + 2 * k], 'big')]


def main():
    args = sys.argv[1:]
    dry = '--dry-run' in args
    only = '--seeds-only' in args
    args = [x for x in args if x not in ('--dry-run', '--lea', '--seeds-only')]
    extra = []
    stops = []
    if '--stop' in args:
        i = args.index('--stop')
        for l in open(args[i + 1]):
            f = l.split('#')[0].split()
            if len(f) >= 2:
                stops.append((int(f[0], 16), int(f[1], 16)))
        del args[i:i + 2]
    if '--seeds' in args:
        i = args.index('--seeds')
        extra = [int(l.split()[0], 16) for l in open(args[i + 1]) if l.split() and not l.startswith('#')]
        del args[i:i + 2]
    if len(args) < 3:
        sys.exit(__doc__)
    root, romfile, files = args[0], args[1], args[2:]
    rom = open(romfile, 'rb').read()
    src = Source(root, files)

    # the current build, for label addresses
    with tempfile.TemporaryDirectory() as tmp:
        obj, elf = os.path.join(tmp, 'x.o'), os.path.join(tmp, 'x.elf')
        subprocess.run([AS, '-m68040', '-I', root, '-I', os.path.join(root, 'include'),
                        os.path.join(root, 'q800rom.s'), '-o', obj], check=True)
        subprocess.run([LD, '-Ttext=0x40800000', '-e', '0x40800000', '--no-warn-rwx-segments',
                        '-o', elf, obj], check=True)
        by_addr, by_name = symbols(elf)
    built = open(romfile, 'rb').read()

    # seeds: code references into raw data, driver routines, extra
    seeds = set(a for a in extra if src.line_at(a) and a % 2 == 0)
    for f in ([] if only else files):
        for line in open(os.path.join(root, f)):
            s = line.split('|')[0].strip()
            if not s or s.startswith('.') or LABEL.match(s):
                continue
            mnem = s.split()[0]
            if not (BRANCH.match(mnem) or mnem.startswith(('jb', 'jmp', 'jsr', 'bsr'))):
                continue
            for n in re.findall(r'[A-Za-z_][A-Za-z0-9_]*', s.split(None, 1)[1] if ' ' in s else ''):
                if n in by_name and src.line_at(by_name[n]):
                    seeds.add(by_name[n])
    for a in ([] if only else drvr_entries(built, src)):
        if src.line_at(a):
            seeds.add(a)
    # lea/pea of a PC-relative address inside raw data: a continuation or completion
    # routine if the bytes there decode as code (tables decode as ori #0 and odd words)
    if '--lea' in sys.argv:
        for f in files:
            for line in open(os.path.join(root, f)):
                s = line.split('|')[0].strip()
                m = re.match(r'^(lea|pea)\s+%pc@\(([A-Za-z_][A-Za-z0-9_]*)\)', s)
                if m and m.group(2) in by_name and src.line_at(by_name[m.group(2)]) \
                        and not m.group(2).startswith(('STR_', 'PSTR_')):
                    a = by_name[m.group(2)]
                    if looks_like_code(romfile, src, a):
                        seeds.add(a)

    # follow the control flow
    code, todo = {}, sorted(seeds)
    label_addrs = set(by_addr)
    with tempfile.TemporaryDirectory() as tmp:
        while todo:
            a = todo.pop()
            while a not in code and a % 2 == 0:
                d = decode(romfile, a)
                if not d or not src.raw_run(a, d[1]):
                    break
                text, n = d
                if any(lo < a + n and a < hi for lo, hi in stops):
                    break
                # a label strictly inside the instruction: not code
                if any(x in label_addrs for x in range(a + 1, a + n)):
                    break
                ok, srctext = check(text, a, n, built, tmp)
                code[a] = (text, n, ok)
                if only:
                    break
                for kind, t in targets(text):
                    if kind == 'branch' and src.line_at(t) and t not in code:
                        todo.append(t)
                mnem = text.split()[0]
                if mnem in STOP or (mnem == 'jmp'):
                    break
                a += n
    print('disasm_raw: %d seeds, %d instructions (%d bytes), %d kept as words'
          % (len(seeds), len(code), sum(v[1] for v in code.values()),
             sum(1 for v in code.values() if not v[2])), file=sys.stderr)
    if dry:
        return

    # labels: every target of a converted instruction needs one
    need = {}
    for a, (text, n, ok) in code.items():
        if not ok:
            continue
        for kind, t in targets(text):
            need.setdefault(t, None)
    names_all = {n for ns in by_addr.values() for n in ns}
    label_keys = sorted(by_addr)

    def new_name(t):
        k = bisect.bisect_right(label_keys, t) - 1
        while k >= 0:
            base = by_addr[label_keys[k]][0]
            if not base.startswith(('__', '.')):
                break
            k -= 1
        while True:
            m = re.match(r'^(.*)_([0-9A-F]+)$', base)
            if m and m.group(1) in by_name and by_name[m.group(1)] + int(m.group(2), 16) == by_name[base]:
                base = m.group(1)
            else:
                break
        nm = '%s_%X' % (base, t - by_name[base])
        while nm in names_all:
            nm += '_'
        names_all.add(nm)
        return nm
    outside = {}
    for t in need:
        if t in by_addr:
            need[t] = by_addr[t][0]
        else:
            need[t] = new_name(t)
            if t not in code:
                outside[t] = need[t]
    if outside:
        nf = os.path.join(tempfile.gettempdir(), 'disasm_raw_names.txt')
        with open(nf, 'w') as f:
            for t, n in sorted(outside.items()):
                f.write('%08X %s  # target of disassembled code\n' % (t, n))
        subprocess.run([sys.executable, os.path.join(TOOLS, 'name_addresses.py'), nf, root], check=True)
        src = Source(root, files)
        # names that could not be placed (e.g. inside a .fill): code using them stays words
        defined = set()
        for dp, dn, fn in os.walk(root):
            dn[:] = [d for d in dn if d != '.git']
            for fl in fn:
                if fl.endswith('.s'):
                    defined.update(re.findall(r'^([A-Za-z_][A-Za-z0-9_]*):', open(os.path.join(dp, fl)).read(), re.M))
        missing = {t for t, n in outside.items() if n not in defined}
        for a, (text, n, ok) in list(code.items()):
            if ok and any(t in missing for _, t in targets(text)):
                code[a] = (text, n, False)

    # write the instructions in place of the raw bytes, run by run (consecutive raw data
    # lines at contiguous addresses; label lines between them stay at their addresses)
    files_with_code = set()
    for a in code:
        r = src.line_at(a)
        if r:
            files_with_code.add(r[2])
    for f in files_with_code:
        p = os.path.join(root, f)
        L = open(p).read().split('\n')
        info = {}
        for (a0, a1, ff, i) in src.raw:
            if ff == f:
                info[i] = (a0, numeric_data(L[i]))
        out, i = [], 0
        while i < len(L):
            if i not in info:
                out.append(L[i])
                i += 1
                continue
            # collect a run
            run_labels, data = {}, bytearray()
            start = info[i][0]
            j = i
            pending = []
            while j < len(L):
                if j in info and info[j][0] == start + len(data):
                    for lab in pending:
                        run_labels.setdefault(start + len(data), []).append(lab)
                    pending = []
                    data += info[j][1]
                    j += 1
                elif LABEL.match(L[j]) and L[j].strip().endswith(':'):
                    pending.append(L[j])
                    j += 1
                else:
                    break
            j -= len(pending)                      # labels after the run stay where they were
            end = start + len(data)
            if not any(start <= a < end for a in code):
                out.extend(L[i:j])
                i = j
                continue
            pend, pend_at, x = bytearray(), start, start

            def flush():
                if pend:
                    for k in range(0, len(pend), 16):
                        chunk = pend[k:k + 16]
                        out.append('    .byte   ' + ', '.join('0x%02X' % c for c in chunk)
                                   + '\t| %08X' % (pend_at + k))
                    pend.clear()
            while x < end:
                if x in run_labels:
                    flush()
                    out.extend(run_labels[x])
                if x in code and x + code[x][1] <= end and \
                        not any(y in run_labels for y in range(x + 1, x + code[x][1])):
                    flush()
                    text, n, ok = code[x]
                    if x in need and x not in by_addr:
                        out.append(need[x] + ':')
                    if ok:
                        s2 = text
                        for t in sorted(set(int(v, 16) for v in re.findall(r'0x(408[0-9a-f]{5})', text))):
                            if t in need:
                                s2 = s2.replace('0x%x' % t, need[t])
                        out.append('    %s\t| %08X%s' % (s2, x, ' A-line trap' if s2.startswith('.short 0xA') else ''))
                    else:
                        w = rom[x - ROM_BASE:x - ROM_BASE + n]
                        out.append('    .short  ' + ', '.join('0x%02X%02X' % (w[k], w[k + 1])
                                                            for k in range(0, n - 1, 2))
                                   + '\t| %08X %s' % (x, text))
                    x += n
                    pend_at = x
                else:
                    if not pend:
                        pend_at = x
                    pend.append(data[x - start])
                    x += 1
            flush()
            i = j
        open(p, 'w').write('\n'.join(out))

if __name__ == '__main__':
    main()
