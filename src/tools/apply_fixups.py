#!/usr/bin/env python3
"""apply_fixups.py - apply analysis/romsrc_fixups.txt to a generated romsrc/.

The fix-ups (written by tools/export_fixups.py from the hand-maintained source) correct
what the generator gets wrong, by ROM address:
  1. data START END   -> tools/to_data.py --ranges (data decoded as instructions)
     keep START END   -> bytes step 2 must not decode (data in the hand source)
  2. number ADDR SIZE -> the item is written as a number
  3. code ADDR        -> tools/disasm_raw.py --seeds-only: exactly these instructions
                         (code left as raw data)
  4. reloc ...        -> tools/reloc_table.py (offsets and addresses written as numbers)
  5. tools/relax_branches.py: the converted code's branches sized by the assembler
The image must stay the original one (checked at the end).

Usage (from src/):  tools/apply_fixups.py ROMSRC ROM [FIXUPS]
"""
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import name_addresses as na  # noqa: E402
import romsrc_model as rm  # noqa: E402
import relax_branches as rb  # noqa: E402

ROM_BASE = 0x40800000


def run(args, **kw):
    r = subprocess.run([sys.executable] + args, capture_output=True, text=True, **kw)
    out = (r.stdout + r.stderr).strip()
    if r.returncode:
        sys.exit('%s failed:\n%s' % (os.path.basename(args[0]), out[-3000:]))
    return out


def image(root):
    with tempfile.TemporaryDirectory() as tmp:
        return rb.build(root, tmp)


def numbers(root, items, rom):
    """write the items at these addresses as plain numbers"""
    lines, _ = na.line_addresses(root)
    byaddr = sorted((a, rel, i) for (rel, i), a in lines.items())
    import bisect
    keys = [a for a, _, _ in byaddr]
    text, done = {}, 0
    for ia, n in items:
        k = bisect.bisect_right(keys, ia) - 1
        # the line that emits the item: the last line starting at or before it with data
        while k >= 0:
            a, rel, i = byaddr[k]
            if rel not in text:
                text[rel] = open(os.path.join(root, rel)).read().split('\n')
            s = rm.code_of(text[rel][i])
            m = rm.DATA.match(s)
            if m:
                break
            k -= 1
        if k < 0:
            continue
        a, rel, i = byaddr[k]
        line = text[rel][i]
        m = rm.DATA.match(rm.code_of(line))
        size = rm.SIZES[m.group(1)]
        items_ = rm.split_items(m.group(2))
        j = (ia - a) // size
        if size != n or j >= len(items_) or (ia - a) % size:
            sys.stderr.write('number at %X: no %d-byte item there\n' % (ia, n))
            continue
        v = int.from_bytes(rom[ia - ROM_BASE:ia - ROM_BASE + n], 'big')
        old = items_[j]
        items_[j] = '0x%0*X' % (2 * n, v)
        head = re.match(r'^(\s*(?:\w+:\s*)?\.(?:long|short|byte)\s+)', line).group(1)
        tail = line[line.index('|'):] if '|' in line else ''
        text[rel][i] = '%s%s /* number, not a label difference (was %s) */%s' % (
            head, ', '.join(items_), old, ('\t' + tail) if tail else '')
        done += 1
    for rel in text:
        open(os.path.join(root, rel), 'w').write('\n'.join(text[rel]))
    return done


def check(root, rom, step):
    if image(root) != rom:
        sys.exit('apply_fixups: the image changed in step %d' % step)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    root, romf = sys.argv[1], os.path.abspath(sys.argv[2])
    fix = sys.argv[3] if len(sys.argv) > 3 else os.path.join(HERE, '..', '..', 'analysis',
                                                             'romsrc_fixups.txt')
    rom = open(romf, 'rb').read()
    data, code, nums, relocs, keep = [], [], [], [], []
    for l in open(fix):
        f = l.split('#')[0].split()
        if not f:
            continue
        if f[0] == 'data':
            data.append('%s %s' % (f[1], f[2]))
        elif f[0] == 'keep':
            keep.append('%s %s' % (f[1], f[2]))
        elif f[0] == 'code':
            code.append(f[1])
        elif f[0] == 'number':
            nums.append((int(f[1], 16), int(f[2])))
        elif f[0] == 'reloc':
            relocs.append(' '.join(f[1:]))
    tmp = tempfile.mkdtemp(prefix='fixups')
    env = dict(os.environ, TMPDIR=tmp)
    files = sorted(os.path.relpath(os.path.join(dp, f), root)
                   for dp, dn, fn in os.walk(root) for f in fn
                   if f.endswith('.s') and f != 'q800rom.s' and '.git' not in dp)

    # 1. data
    p = os.path.join(tmp, 'data.txt')
    open(p, 'w').write('\n'.join(data) + '\n')
    print('[1] ' + run([os.path.join(HERE, 'to_data.py'), root, '--ranges', p, romf]).splitlines()[-1])
    check(root, rom, 1)
    # 2. numbers (before decoding: an item inside code must be a plain number)
    print('[2] %d items written as numbers' % numbers(root, nums, rom))
    check(root, rom, 2)
    # 3. code, until nothing more is converted
    p = os.path.join(tmp, 'code.txt')
    open(p, 'w').write('\n'.join(code) + '\n')
    stop = os.path.join(tmp, 'stop.txt')
    open(stop, 'w').write('\n'.join(keep) + '\n')
    last = None
    for k in range(8):
        out = run([os.path.join(HERE, 'disasm_raw.py'), root, romf] + files + ['--seeds', p, '--seeds-only', '--stop', stop], env=env)
        line = [x for x in out.splitlines() if x.startswith('disasm_raw:')][-1]
        print('[3] pass %d: %s' % (k + 1, line))
        if re.search(r': \d+ seeds, 0 instructions', line) or line == last:
            break
        last = line
    check(root, rom, 3)
    # 4. relocations
    p = os.path.join(tmp, 'relocs.txt')
    open(p, 'w').write('\n'.join(relocs) + '\n')
    out = run([os.path.join(HERE, 'reloc_table.py'), p, root], env=env)
    print('[4] %d tables relocated, %s' % (sum(1 for x in out.splitlines() if ' entries, base ' in x),
                                          out.splitlines()[-1]))
    # 5. branches
    out = run([os.path.join(HERE, 'relax_branches.py'), root, romf], env=env)
    print('[5] ' + out.splitlines()[-1])
    if image(root) != rom:
        sys.exit('apply_fixups: the image is not the original one')
    print('apply_fixups: image unchanged')


if __name__ == '__main__':
    main()
