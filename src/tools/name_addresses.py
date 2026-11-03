#!/usr/bin/env python3
"""name_addresses.py - give names to ROM addresses in romsrc/.

Input lines: "ADDRESS NAME  # comment" (address in hex, e.g. 4086CBF6 or 0x4086CBF6).
For each address:
  - a generic label already there (sub_, loc_, dat_, thunk_, caseD_) is renamed
    everywhere (like tools/rename_labels.py);
  - otherwise a label is inserted before the source line that starts at that address;
    an address inside a data line (.long/.short/.byte with plain numbers) splits the line;
    an address inside an instruction is reported and skipped.

Line addresses are found by assembling a copy of romsrc/ with a marker label before
every line (labels do not change the bytes), so the result is exact.

Usage:  name_addresses.py NAMES ROMSRC [--dry-run]
Environment: M68K_AS, M68K_LD, M68K_NM as in the Makefile.
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROM_BASE = 0x40800000
AS = os.environ.get('M68K_AS', '/usr/m68k-suse-linux/bin/as')
LD = os.environ.get('M68K_LD', '/usr/m68k-suse-linux/bin/ld')
NM = os.environ.get('M68K_NM', '/usr/m68k-suse-linux/bin/nm')
LABEL = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*):')
GENERIC = re.compile(r'^((sub|loc|dat|thunk_FUN)_[0-9A-Fa-f]{8}|caseD_[0-9A-Fa-f]+)$')


def src_files(root):
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d != '.git']
        for f in fn:
            if f.endswith('.s'):
                yield os.path.relpath(os.path.join(dp, f), root)


def line_addresses(root):
    """{(file, line index): address} for every line start, and {label: address}."""
    tmp = tempfile.mkdtemp(prefix='nameaddr')
    try:
        shutil.copytree(root, os.path.join(tmp, 'src'), ignore=shutil.ignore_patterns('.git'))
        ids = {}
        for k, rel in enumerate(sorted(src_files(root))):
            p = os.path.join(tmp, 'src', rel)
            lines = open(p).read().split('\n')
            out, depth = [], 0
            for i, l in enumerate(lines):
                s = l.split('|')[0].strip()
                if re.match(r'\.(rept|macro|irp|irpc)\b', s):
                    depth += 1
                if depth == 0 and not s.startswith('.set') and not s.startswith('.endr'):
                    out.append('__ln_%d_%d:' % (k, i))
                    ids[(k, i)] = rel
                out.append(l)
                if re.match(r'\.(endr|endm)\b', s):
                    depth -= 1
            open(p, 'w').write('\n'.join(out))
        obj, elf = os.path.join(tmp, 'x.o'), os.path.join(tmp, 'x.elf')
        src = os.path.join(tmp, 'src')
        subprocess.run([AS, '-m68040', '-I', src, '-I', os.path.join(src, 'include'),
                        os.path.join(src, 'q800rom.s'), '-o', obj], check=True, cwd=tmp)
        und = subprocess.run([NM, '-u', obj], capture_output=True, text=True, check=True).stdout.strip()
        if und:
            sys.exit('undefined symbols in romsrc (addresses would be wrong):\n' + und)
        subprocess.run([LD, '-Ttext=0x40800000', '-e', '0x40800000', '--no-warn-rwx-segments',
                        '-o', elf, obj], check=True)
        nm = subprocess.run([NM, elf], capture_output=True, text=True, check=True).stdout
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    lines, labels = {}, {}
    for l in nm.splitlines():
        f = l.split()
        if len(f) != 3:
            continue
        a = int(f[0], 16)
        m = re.match(r'__ln_(\d+)_(\d+)$', f[2])
        if m:
            k, i = int(m.group(1)), int(m.group(2))
            lines[(ids[(k, i)], i)] = a
        else:
            labels.setdefault(a, []).append(f[2])
    return lines, labels


def data_bytes(line):
    """Bytes of a data line with plain numbers, or None."""
    s = line.split('|')[0].strip()
    m = re.match(r'\.(long|short|byte)\s+(.*)$', s)
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


def main():
    args = [a for a in sys.argv[1:] if a != '--dry-run']
    dry = '--dry-run' in sys.argv
    if len(args) != 2:
        sys.exit(__doc__)
    want = []
    for l in open(args[0]):
        body = l.split('#')[0].split()
        if len(body) == 2:
            want.append((int(body[0], 16), body[1]))
    root = args[1]
    lines, labels = line_addresses(root)
    existing = {n for ns in labels.values() for n in ns}
    by_addr = {}
    for (rel, i), a in lines.items():
        by_addr.setdefault(a, []).append((rel, i))
    starts = sorted(by_addr)
    import bisect

    renames, inserts, skipped = {}, {}, []
    for a, name in want:
        if name in existing:
            skipped.append((a, name, 'name already used'))
            continue
        gen = [n for n in labels.get(a, []) if GENERIC.match(n)]
        if gen:
            renames[gen[0]] = name
            existing.add(name)
            continue
        if labels.get(a):
            skipped.append((a, name, 'has a label already: %s' % labels[a][0]))
            continue
        if a in by_addr:
            rel, i = max(by_addr[a], key=lambda x: x[1])      # last line starting there
            # insert before the first non-label line starting at a
            cands = sorted(by_addr[a], key=lambda x: x[1])
            rel, i = cands[0]
            inserts.setdefault(rel, []).append((i, 0, name))
            existing.add(name)
            continue
        k = bisect.bisect_right(starts, a) - 1
        start = starts[k]
        rel, i = sorted(by_addr[start], key=lambda x: x[1])[-1]
        text = open(os.path.join(root, rel)).read().split('\n')[i]
        b = data_bytes(text)
        if b is None or not (start < a < start + len(b)):
            skipped.append((a, name, 'inside: %s' % text.strip()[:60]))
            continue
        inserts.setdefault(rel, []).append((i, a - start, name))
        existing.add(name)

    for a, name, why in skipped:
        print('skipped %08X %s: %s' % (a, name, why), file=sys.stderr)
    print('name_addresses: %d renames, %d new labels, %d skipped'
          % (len(renames), sum(len(v) for v in inserts.values()), len(skipped)), file=sys.stderr)
    if dry:
        return
    for rel, items in inserts.items():
        p = os.path.join(root, rel)
        L = open(p).read().split('\n')
        for i, off, name in sorted(items, reverse=True):
            if off == 0:
                L.insert(i, name + ':')
                continue
            b = data_bytes(L[i])
            start = lines[(rel, i)]
            head, tail = b[:off], b[off:]
            new = []
            if head:
                new.append('    .byte   ' + ', '.join('0x%02X' % x for x in head) + '\t| %08X' % start)
            new.append(name + ':')
            new.append('    .byte   ' + ', '.join('0x%02X' % x for x in tail) + '\t| %08X' % (start + off))
            L[i:i + 1] = new
        open(p, 'w').write('\n'.join(L))
    if renames:
        ident = re.compile(r'\b[A-Za-z_][A-Za-z0-9_]*\b')
        for dp, dn, fn in os.walk(root):
            dn[:] = [d for d in dn if d != '.git']
            for f in fn:
                if f.endswith(('.s', '.inc', '.lst')):
                    p = os.path.join(dp, f)
                    s = open(p).read()
                    t = ident.sub(lambda x: renames.get(x.group(0), x.group(0)), s)
                    if t != s:
                        open(p, 'w').write(t)


if __name__ == '__main__':
    main()
