#!/usr/bin/env python3
"""reloc_table.py - write tables of 16-bit code offsets as label differences.

A jump table read by
    movew %pc@(TABLE,%d0:w),%d0
    jmp   %pc@(BASE,%d0:w)          (or lea; jmp %pc@(0,%d0:w) has BASE = the jmp + 2)
holds target-BASE in each word. When the generator did not see the targets as code, the
words stay plain numbers, and the table breaks as soon as code moves between BASE and a
target. This tool takes such tables, gives every target a label (an existing one, or
ROUTINE_offset after the routine that contains it, inserted with name_addresses.py), and
rewrites the words as ".short TARGET-BASE". The image must not change.

Input lines:  TABLE COUNT BASE [STRIDE [POS [SIZE]]] [# comment]
  TABLE is a hex address or a label.
  BASE ".+N": each offset counts from N bytes after its own entry (written TARGET-.-N).
  SIZE 4: the offsets are longs (.long; the record is then just the long).
  BASE is a label or label+N (e.g. FOO_20+2 for "jmp %pc@(0,%d0:w)" at FOO_20).
  Records of STRIDE bytes (default 2) with the offset word at byte POS (default 0): the
  other words of each record are written as plain numbers.
Usage (from src/):  tools/reloc_table.py TABLES [ROMSRC] [--targets]
  --targets: only print the target addresses (e.g. as seeds for disasm_raw.py, so that
  code reached only through the table is turned into instructions first).
Environment: M68K_AS, M68K_LD, M68K_NM, M68K_OBJCOPY as in the Makefile.
"""
import os
import re
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.dirname(HERE)
ROM_BASE = 0x40800000
AS = os.environ.get('M68K_AS', '/usr/m68k-suse-linux/bin/as')
LD = os.environ.get('M68K_LD', '/usr/m68k-suse-linux/bin/ld')
NM = os.environ.get('M68K_NM', '/usr/m68k-suse-linux/bin/nm')
OBJCOPY = os.environ.get('M68K_OBJCOPY', '/usr/bin/m68k-suse-linux-objcopy')
GENERIC = re.compile(r'^((sub|loc|dat)_[0-9A-F]{8}|thunk_FUN_[0-9a-f]{8}|caseD_[0-9A-Fa-f]+)$')


def build(root, work):
    obj, elf, binf = (os.path.join(work, 'rt' + x) for x in ('.o', '.elf', '.bin'))
    subprocess.run([AS, '-m68040', '-I', root, '-I', os.path.join(root, 'include'),
                    os.path.join(root, 'q800rom.s'), '-o', obj], check=True)
    und = subprocess.run([NM, '-u', obj], capture_output=True, text=True, check=True).stdout.strip()
    if und:
        sys.exit('undefined symbols:\n' + und)
    subprocess.run([LD, '-Ttext=0x%X' % ROM_BASE, '-e', '0x%X' % ROM_BASE,
                    '--no-warn-rwx-segments', '-o', elf, obj], check=True)
    subprocess.run([OBJCOPY, '-O', 'binary', '--only-section=.text', elf, binf], check=True)
    sym = {}
    for line in subprocess.run([NM, elf], capture_output=True, text=True, check=True).stdout.splitlines():
        f = line.split()
        if len(f) == 3:
            sym[f[2]] = int(f[0], 16)
    return sym, open(binf, 'rb').read()


def main():
    args = [a for a in sys.argv[1:] if a != '--targets']
    only_targets = '--targets' in sys.argv
    if not args:
        sys.exit(__doc__)
    root = args[1] if len(args) > 1 else os.path.join(SRC, 'romsrc')
    work = os.environ.get('TMPDIR', '/tmp')
    tables = []
    for line in open(args[0]):
        line = line.split('#')[0].split()
        if line:
            stride = int(line[3], 0) if len(line) > 3 else 2
            pos = int(line[4], 0) if len(line) > 4 else 0
            size = int(line[5], 0) if len(line) > 5 else 2
            assert stride % 2 == 0 and pos % 2 == 0 and pos < stride
            assert size == 2 or (size == 4 and stride == 4 and pos == 0)
            tables.append((line[0], int(line[1], 0), line[2], stride, pos, size))
    # labels defined in the source (not .set aliases), and where
    defined = {}
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d != '.git']
        for f in fn:
            if f.endswith('.s'):
                p = os.path.join(dp, f)
                for m in re.finditer(r'^([A-Za-z_]\w*):', open(p).read(), re.M):
                    defined[m.group(1)] = p
    sym, img = build(root, work)
    byaddr = {}
    for n, a in sym.items():
        if n in defined and not n.startswith('RELOC_TABLE_END_'):
            byaddr.setdefault(a, []).append(n)
    order = sorted((a, n) for n, a in sym.items() if n in defined)
    keys = [a for a, _ in order]

    def base_addr(expr, entry=None):
        if expr.startswith('.'):                    # relative to the entry itself
            return entry + (int(expr[2:], 0) if len(expr) > 1 else 0)
        m = re.match(r'^(\w+)(?:\+(\w+))?$', expr)
        return sym[m.group(1)] + (int(m.group(2), 0) if m.group(2) else 0)

    def word(a, size=2):
        return struct.unpack('>h' if size == 2 else '>i', img[a - ROM_BASE:a - ROM_BASE + size])[0]

    import bisect
    used = set(sym)
    new = {}

    def name_for(a, fallback_root=None):
        if a in byaddr:
            good = [n for n in byaddr[a] if not GENERIC.match(n)]
            return sorted(good or byaddr[a], key=len)[0]
        if a in new:
            return new[a]
        i = bisect.bisect_right(keys, a) - 1
        s = order[i][1]
        while True:                      # X_off is "off bytes into X": count from X
            m = re.match(r'^(.*)_([0-9A-F]+)$', s)
            if m and m.group(1) in sym and sym[m.group(1)] + int(m.group(2), 16) == sym[s]:
                s = m.group(1)
            else:
                break
        n = '%s_%X' % (s, a - sym[s])
        assert n not in used, n
        used.add(n)
        new[a] = n
        return n

    plan = []
    def target(t, k, bexpr, stride, pos, size):
        e = t + stride * k + pos
        return base_addr(bexpr, e) + word(e, size)

    if only_targets:
        for t, count, bexpr, stride, pos, size in tables:
            t = sym[t] if t in sym else int(t, 16)
            for k in range(count):
                print('%X  # %X entry %d' % (target(t, k, bexpr, stride, pos, size), t, k))
        return
    for t, count, bexpr, stride, pos, size in tables:
        t = sym[t] if t in sym else int(t, 16)
        start = name_for(t)
        e = t + stride * count               # end marker: a label there, else a temporary one
        end = name_for(e) if e in byaddr else 'RELOC_TABLE_END_%X' % t
        targets = [target(t, k, bexpr, stride, pos, size) for k in range(count)]
        for a in targets:
            name_for(a)
        plan.append((t, count, bexpr, start, end, targets, stride, pos, size))
    names = os.path.join(work, 'rt_names.txt')
    with open(names, 'w') as f:
        for a, n in sorted(new.items()):
            f.write('%X %s  # target of a code offset table\n' % (a, n))
        for t, count, _, _, end, _, stride, _, _ in plan:
            if end.startswith('RELOC_TABLE_END_'):
                f.write('%X %s  # temporary\n' % (t + stride * count, end))
    r = subprocess.run([sys.executable, os.path.join(HERE, 'name_addresses.py'), names, root],
                       capture_output=True, text=True)
    sys.stderr.write(r.stdout + r.stderr)
    if 'inside' in r.stdout + r.stderr or r.returncode:
        sys.exit('a target is inside an instruction: stopped (labels already inserted)')
    sym, img2 = build(root, work)
    for t, count, bexpr, start, end, targets, stride, pos, size in plan:
        p = defined.get(start) or next(
            os.path.join(dp, f) for dp, dn, fn in os.walk(root) for f in fn
            if f.endswith('.s') and re.search(r'^%s:' % start, open(os.path.join(dp, f)).read(), re.M))
        L = open(p).read().split('\n')
        i0 = next(i for i, l in enumerate(L) if l.startswith(start + ':'))
        i1 = next((i for i, l in enumerate(L) if l.startswith(end + ':')), None)
        temp = end.startswith('RELOC_TABLE_END_')
        if i1 is None:                          # temporary end label gone: written before
            print('%s: %s already written' % (os.path.relpath(p, root), start))
            continue
        # labels inside the table keep their place
        inside = {}
        for l in L[i0:i1]:
            m = re.match(r'^(\w+):(.*)$', l)
            if m:
                inside.setdefault(sym[m.group(1)], []).append(l)
        if bexpr.startswith('.'):
            bt = '.' + ('-' + bexpr[2:] if len(bexpr) > 1 else '')
        else:
            bt = '(%s)' % bexpr if '+' in bexpr else bexpr
        out = []
        for k in range(count):
            a = t + stride * k
            out += inside.pop(a, [])
            if size == 4:
                out.append('    .long   %s-%s\t| %08X' % (name_for(targets[k]), bt, a))
                continue
            w = ['0x%04X' % (word(a + j) & 0xFFFF) for j in range(0, stride, 2)]
            w[pos // 2] = '%s-%s' % (name_for(targets[k]), bt)
            out.append('    .short  %s\t| %08X' % (', '.join(w), a))
            for j in range(2, stride, 2):
                assert a + j not in inside, 'label inside a record at %X' % (a + j)
        out += inside.pop(t + stride * count, [])       # labels at the end stay after the table
        assert not inside, 'labels not at an entry: %s' % inside
        L[i0:i1 + (1 if temp else 0)] = out
        open(p, 'w').write('\n'.join(L))
        print('%s: %s, %d entries, base %s' % (os.path.relpath(p, root), start, count, bexpr))
    sym, img3 = build(root, work)
    if img3 != img:
        sys.exit('the image changed')
    print('image unchanged')


if __name__ == '__main__':
    main()
