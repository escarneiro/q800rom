#!/usr/bin/env python3
"""add_hook.py - hook a ROM routine without moving anything.

The first whole instructions at LABEL (at least 6 bytes) are replaced by
    jmp HOOK:l          (6 bytes, then nops up to the size they had)
and moved to romsrc/patches/hooks.s, after a place for new code:
    HOOK:
        <new code goes here>
        <the instructions moved from LABEL>
        jmp LABEL_HOOKRET:l     (back to the first instruction after them)
Every byte after the hooked instructions stays where it was, so the ROM keeps its layout
(see tools/macos_compat.py). The moved instructions are reassembled at their new place
from the source, so their label references stay right.

Refused when: a label lies inside the instructions to move (something jumps there), one
of them is data or depends on its own address (%pc@(0,...), raw words), or Mac OS 8.1
uses an address inside them (analysis/macos81_rom_refs.txt).

With --after, the new code runs after the routine instead of before it:
    HOOK:
        jsr HOOK_ORIG:l         (the routine itself, from its first instruction)
        <new code goes here>
        rts
    HOOK_ORIG:
        <the instructions moved from LABEL>
        jmp LABEL_HOOKRET:l
(for a routine that returns with rts and leaves the stack as it found it).

Usage (from src/):  tools/add_hook.py LABEL HOOK [--after] [ROMSRC]
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import name_addresses as na  # noqa: E402
import romsrc_model as rm  # noqa: E402

LABEL_RE = re.compile(r'^([A-Za-z_]\w*):')


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    args = [a for a in sys.argv[1:] if a != '--after']
    after = '--after' in sys.argv
    label, hook = args[0], args[1]
    root = args[2] if len(args) > 2 else os.path.join(HERE, '..', 'romsrc')
    lines, labels = na.line_addresses(root)
    # where LABEL is
    hit = None
    for (rel, i), a in lines.items():
        if rel.endswith('.s') and open(os.path.join(root, rel)).read().split('\n')[i].startswith(label + ':'):
            hit = (rel, i, a)
            break
    if not hit:
        sys.exit('label %s not found' % label)
    rel, i0, start = hit
    p = os.path.join(root, rel)
    L = open(p).read().split('\n')
    addr = {i: a for (r, i), a in lines.items() if r == rel}
    # the instructions after the label, up to 6 bytes
    moved, k, end = [], i0 + 1, start
    while end - start < 6:
        while k < len(L) and not rm.code_of(L[k]).strip() and not LABEL_RE.match(L[k]):
            k += 1                                       # blank and comment lines
        if k >= len(L):
            sys.exit('end of file inside the hooked instructions')
        if LABEL_RE.match(L[k]):
            if addr.get(k) == start:                     # another name for the same address
                k += 1
                continue
            sys.exit('label inside the hooked instructions: %s' % L[k].split(':')[0])
        s = rm.code_of(L[k])
        if s.startswith('.') or re.search(r'%pc@\(0,|%pc@\(\d', s):
            sys.exit('cannot move: %s' % L[k].strip())
        nxt = min(a for j, a in addr.items() if j > k and a > addr[k])
        moved.append((k, L[k], nxt - addr[k]))
        end = nxt
        k += 1
    size = end - start
    # Mac OS 8.1's addresses inside (start, end): refuse; at start: fine (it jumps to the hook)
    refs = os.path.join(HERE, '..', '..', 'analysis', 'macos81_rom_refs.txt')
    if os.path.exists(refs):
        for line in open(refs):
            if line.startswith('#') or not line.strip():
                continue
            a = int(line.split()[0], 16)
            use = line.split()[1]
            if start < a < end or (use == 'come-from' and start < a <= end):
                sys.exit('Mac OS 8.1 uses %08X (%s) inside the hooked instructions' % (a, use))
    ret = '%s_HOOKRET' % label
    # rewrite the routine: jmp HOOK:l, nops, a label for the way back
    first, last = moved[0][0], moved[-1][0]
    new = ['    jmp %s:l\t/* hook: tools/add_hook.py, code in patches/hooks.s */' % hook]
    new += ['    nop'] * ((size - 6) // 2)
    new += ['%s:' % ret]
    keep = [l for j, l in enumerate(L[first:last + 1], first) if j not in [m[0] for m in moved]]
    L[first:last + 1] = new + keep
    open(p, 'w').write('\n'.join(L))
    hp = os.path.join(root, 'patches', 'hooks.s')
    with open(hp, 'a') as f:
        if after:
            f.write('\n/* hook on %s (%s): the routine (its first %d bytes of instructions moved\n'
                    ' to %s_ORIG), then new code */\n%s:\n    jsr %s_ORIG:l\n'
                    '    /* new code here */\n    rts\n%s_ORIG:\n' % (label, rel, size, hook, hook, hook, hook))
        else:
            f.write('\n/* hook on %s (%s): new code first, then the %d bytes of instructions moved from\n'
                    ' there, then back */\n%s:\n    /* new code here */\n' % (label, rel, size, hook))
        for _, l, _ in moved:
            f.write('    %s\n' % rm.code_of(l))
        f.write('    jmp %s:l\n' % ret)
    print('%s at %08X: %d bytes (%d instructions) moved to patches/hooks.s as %s'
          % (label, start, size, len(moved), hook))


if __name__ == '__main__':
    main()
