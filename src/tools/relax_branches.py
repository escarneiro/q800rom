#!/usr/bin/env python3
"""relax_branches.py - let the assembler choose branch sizes where it gives the same bytes.

tools/disasm_raw.py writes branches with an explicit size (bras, beqw, bsrw ...) so that
the bytes are certainly the original ones. An explicit size cannot grow: once code is
inserted between a short branch and its target the source no longer assembles ("value
out of range"). The generator writes jbra/jbeq/jbsr ... instead, which the assembler
relaxes to the shortest form that reaches.

This rewrites every explicitly sized branch as its jb form, then builds: the first byte
that differs from the original image belongs to a branch the assembler made shorter than
the original (e.g. a bra.w that would fit in a bra.s); that one keeps its explicit size.
Repeated until the image is identical.

Usage (from src/):  tools/relax_branches.py ROMSRC ORIGINAL_ROM [--fix]
  --fix: the other way round, for a source whose jb branches no longer give the original
  bytes: each jb branch at the first difference gets the size the original ROM has there.
"""
import os
import re
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import name_addresses as na  # noqa: E402

ROM_BASE = 0x40800000
AS = os.environ.get('M68K_AS', '/usr/m68k-suse-linux/bin/as')
LD = os.environ.get('M68K_LD', '/usr/m68k-suse-linux/bin/ld')
OBJCOPY = os.environ.get('M68K_OBJCOPY', '/usr/bin/m68k-suse-linux-objcopy')
CC = 'ra|sr|hi|ls|cc|cs|ne|eq|vc|vs|pl|mi|ge|lt|gt|le'
BR = re.compile(r'^(\s+)b(%s)([swl])(\s+)([A-Za-z_]\w*)(\s*(?:\t\|.*)?)$' % CC)


def build(root, tmp, postlink=True):
    obj, elf, binf = (os.path.join(tmp, 'r' + x) for x in ('.o', '.elf', '.bin'))
    r = subprocess.run([AS, '-m68040', '-I', root, '-I', os.path.join(root, 'include'),
                        os.path.join(root, 'q800rom.s'), '-o', obj], capture_output=True, text=True)
    if r.returncode:
        sys.exit(r.stderr[-2000:])
    subprocess.run([LD, '-Ttext=0x%X' % ROM_BASE, '-e', '0x%X' % ROM_BASE,
                    '--no-warn-rwx-segments', '-o', elf, obj], check=True)
    subprocess.run([OBJCOPY, '-O', 'binary', '--only-section=.text', elf, binf], check=True)
    if postlink:                                 # as make rom: trap table, checksums
        subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'rom_postlink.py'), elf, binf, root], check=True, capture_output=True)
    return open(binf, 'rb').read()


def first_diff(img, rom):
    """first differing offset, not counting the checksum (bytes 0-3, follows everything)
    and the declaration ROM's CRC near the end"""
    d = next((k for k in range(4, len(rom)) if img[k] != rom[k]), None)
    if d is not None and d >= len(rom) - 0x100:
        return None if img == rom or all(img[k] == rom[k] for k in range(4, len(rom) - 0x100)) else d
    return d


ADDR = re.compile(r'\t\| ([0-9A-F]{8})\b')
JB = re.compile(r'^(\s+)jb(%s)(\s+)([A-Za-z_]\w*)(\s*(?:\t\|.*)?)$' % CC)


def fix(root, rom):
    """give jb branches the original sizes where the assembler chose another one

    Lines are walked in address order with the sum of the size changes so far, which turns
    a line's current address into its address in the original image: there the original
    opcode gives the original size. Repeated until no size differs."""
    total = 0
    with tempfile.TemporaryDirectory() as tmp:
        while True:
            img = build(root, tmp, postlink=False)
            lines, _ = na.line_addresses(root)
            text = {}
            order = sorted((a, rel, i) for (rel, i), a in lines.items())
            # size of each line in the current build = next line's address - its own
            fixed, shift = 0, 0
            for k, (a, rel, i) in enumerate(order):
                if rel not in text:
                    text[rel] = open(os.path.join(root, rel)).read().split('\n')
                anchor = ADDR.search(text[rel][i])
                if anchor:                         # the original address is in the line
                    shift = a - int(anchor.group(1), 16)
                m = JB.match(text[rel][i])
                if not m:
                    continue
                nxt = next((b for b, _, _ in order[k + 1:] if b > a), None)
                if nxt is None:
                    continue
                cur = nxt - a
                if cur not in (2, 4, 6):          # several lines at one address: skip
                    continue
                o = a - shift                      # address in the original image
                low = rom[o - ROM_BASE + 1]
                size, n = ('w', 4) if low == 0 else ('l', 6) if low == 0xFF else ('s', 2)
                if rom[o - ROM_BASE] & 0xF0 != 0x60:
                    sys.exit('%s:%d: no branch in the original at %X' % (rel, i + 1, o))
                if cur != n:
                    text[rel][i] = '%sb%s%s%s%s%s' % (m.group(1), m.group(2), size, m.group(3),
                                                       m.group(4), m.group(5))
                    shift += cur - n
                    fixed += 1
            for rel in text:
                open(os.path.join(root, rel), 'w').write('\n'.join(text[rel]))
            total += fixed
            if not fixed:
                break
    print('relax_branches: %d branches given their original size' % total)


def main():
    args = [a for a in sys.argv[1:] if a != '--fix']
    if len(args) != 2:
        sys.exit(__doc__)
    root, romf = args
    rom = open(romf, 'rb').read()
    if '--fix' in sys.argv:
        return fix(root, rom)
    lines, _ = na.line_addresses(root)          # addresses of the original lines
    text = {}
    changed = []                                 # (address, file, line index)
    for (rel, i), a in lines.items():
        if rel not in text:
            text[rel] = open(os.path.join(root, rel)).read().split('\n')
        m = BR.match(text[rel][i])
        if m:
            changed.append((a, rel, i, text[rel][i]))
    changed.sort()
    for a, rel, i, old in changed:
        m = BR.match(old)
        j = 'jbra' if m.group(2) == 'ra' else 'jbsr' if m.group(2) == 'sr' else 'jb' + m.group(2)
        text[rel][i] = '%s%s%s%s%s' % (m.group(1), j, m.group(4), m.group(5), m.group(6))
    files = set(rel for _, rel, _, _ in changed)

    def write():
        for rel in files:
            open(os.path.join(root, rel), 'w').write('\n'.join(text[rel]))

    write()
    print('relax_branches: %d explicitly sized branches written as jb' % len(changed))
    fix(root, rom)


if __name__ == '__main__':
    main()
