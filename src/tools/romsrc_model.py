#!/usr/bin/env python3
"""romsrc_model.py - what a romsrc/ tree says about each ROM address.

Assembles the source with a marker label before every line (tools/name_addresses.py) and
returns, for every line that emits bytes: its address, size, file and line, whether it is
an instruction or data, and for data lines the items written as label expressions, each
evaluated: (item address, size, target address, base) with base an address, or
('.', N) for "TARGET-.-N" (relative to the item itself).

Used by tools/export_fixups.py to compare the hand-maintained source with the generated one.
"""
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import name_addresses as na  # noqa: E402

NM = na.NM
DATA = re.compile(r'^\.(long|short|byte)\s+(.*)$')
SIZES = {'long': 4, 'short': 2, 'byte': 1}
IDENT = r'[A-Za-z_][A-Za-z0-9_]*'
NUMBER = re.compile(r"-?(0x[0-9A-Fa-f]+|0b[01]+|\d+|'.)")


def code_of(line):
    """the statement of a line: no comments, no label"""
    s = re.sub(r'/\*.*?\*/', '', line)
    q = False
    for k, c in enumerate(s):
        if c == '"':
            q = not q
        elif c == '|' and not q:
            s = s[:k]
            break
    s = s.strip()
    m = re.match(r'^%s:\s*(.*)$' % IDENT, s)
    return m.group(1).strip() if m else s


def split_items(s):
    out, depth, cur = [], 0, ''
    for c in s:
        if c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
        if c == ',' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += c
    if cur.strip():
        out.append(cur.strip())
    return out


def symbols(root):
    """label addresses of the current build of root (assembled in a copy)"""
    import tempfile
    import shutil
    tmp = tempfile.mkdtemp(prefix='model')
    try:
        obj, elf = os.path.join(tmp, 'x.o'), os.path.join(tmp, 'x.elf')
        subprocess.run([na.AS, '-m68040', '-I', root, '-I', os.path.join(root, 'include'),
                        os.path.join(root, 'q800rom.s'), '-o', obj], check=True)
        subprocess.run([na.LD, '-Ttext=0x40800000', '-e', '0x40800000', '--no-warn-rwx-segments',
                        '-o', elf, obj], check=True)
        out = subprocess.run([NM, elf], capture_output=True, text=True, check=True).stdout
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    sym = {}
    for l in out.splitlines():
        f = l.split()
        if len(f) == 3:
            sym[f[2]] = int(f[0], 16)
    return sym


def evaluate(expr, sym, item):
    """(target, base) of a label expression, or None if it is not one"""
    e = expr.replace(' ', '')
    if e in sym:                                   # an absolute address
        return sym[e], 'abs'
    m = re.fullmatch(r'(%s)-\.(?:-(\w+))?' % IDENT, e)
    if m and m.group(1) in sym:
        return sym[m.group(1)], ('.', int(m.group(2), 0) if m.group(2) else 0)
    m = re.fullmatch(r'(%s)-\(?(%s)(?:\+(\w+))?\)?' % (IDENT, IDENT), e)
    if m and m.group(1) in sym and m.group(2) in sym:
        return sym[m.group(1)], sym[m.group(2)] + (int(m.group(3), 0) if m.group(3) else 0)
    return None


def model(root):
    """list of dicts: addr, size, rel, line, kind ('insn'|'data'|'other'), items"""
    lines, _ = na.line_addresses(root)
    sym = symbols(root)
    text, raw = {}, {}
    order = sorted((a, rel, i) for (rel, i), a in lines.items())
    out = []
    for k, (a, rel, i) in enumerate(order):
        if rel not in text:                     # comments removed, line numbers kept
            t = open(os.path.join(root, rel)).read()
            raw[rel] = t.split('\n')
            t = re.sub(r'/\*.*?\*/', lambda m: '\n' * m.group(0).count('\n'), t, flags=re.S)
            text[rel] = t.split('\n')
        s = code_of(text[rel][i])
        if not s or s.startswith(('.include', '.set', '.equ', '.macro', '.endm', '.endr', '.rept')):
            continue
        nxt = next((b for b, _, _ in order[k + 1:] if b > a), None)
        size = (nxt - a) if nxt is not None else 0
        if size <= 0:
            continue
        rec = {'addr': a, 'size': size, 'rel': rel, 'line': i, 'items': [], 'text': s,
               'ann': bool(re.search(r'\|\s*[0-9A-F]{8}\b', raw[rel][i]))}
        m = DATA.match(s)
        if m:
            rec['kind'] = 'data'
            n = SIZES[m.group(1)]
            for j, it in enumerate(split_items(m.group(2))):
                if re.search(IDENT, it) and not NUMBER.fullmatch(it):
                    ia = a + j * n
                    ev = evaluate(it, sym, ia)
                    rec['items'].append((ia, n, it, ev))
        elif s.startswith('.') or s.startswith('FILL_'):
            rec['kind'] = 'other'
        elif re.match(r'^_[A-Z]\w*\b', s):           # A-line trap macro
            rec['kind'] = 'trap'
        else:
            rec['kind'] = 'insn'
        out.append(rec)
    return out, sym


if __name__ == '__main__':
    recs, sym = model(sys.argv[1])
    kinds = {}
    for r in recs:
        kinds[r['kind']] = kinds.get(r['kind'], 0) + r['size']
    items = [it for r in recs for it in r['items']]
    print('bytes by kind:', kinds)
    print('label-expression items: %d, evaluated %d' % (len(items), sum(1 for it in items if it[3])))
    shapes = {}
    for it in items:
        if not it[3]:
            sh = re.sub(IDENT, 'L', it[2])
            shapes[sh] = shapes.get(sh, 0) + 1
    print('not evaluated:', sorted(shapes.items(), key=lambda x: -x[1])[:10])
