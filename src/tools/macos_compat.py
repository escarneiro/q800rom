#!/usr/bin/env python3
"""macos_compat.py - is a modified ROM still compatible with Mac OS 8.1's patches?

Mac OS 8.1 uses about 900 ROM addresses directly (analysis/macos81_rom_refs.txt):
jumps into ROM routines, come-from checks of return addresses, loaded addresses. For each
one this checks, in the built ROM:
  moved    the code there (found by its label in the ELF) is no longer at that address
  changed  the bytes the System relies on differ from the original ROM: the instruction a
           jump lands on, the call just before a come-from return address, the first word
           at a loaded address
Exit status 0 when nothing moved or changed, 1 otherwise.

Usage (from src/):  tools/macos_compat.py ELF ROM ORIGINAL_ROM [REFS] [-v]
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
NM = os.environ.get('M68K_NM', '/usr/m68k-suse-linux/bin/nm')
ROM_BASE = 0x40800000


def main():
    args = [a for a in sys.argv[1:] if a != '-v']
    verbose = '-v' in sys.argv
    if len(args) < 3:
        sys.exit(__doc__)
    elf, romf, origf = args[:3]
    refs = args[3] if len(args) > 3 else os.path.join(HERE, '..', '..', 'analysis', 'macos81_rom_refs.txt')
    rom, orig = open(romf, 'rb').read(), open(origf, 'rb').read()
    sym = {}
    for line in subprocess.run([NM, elf], capture_output=True, text=True, check=True).stdout.splitlines():
        f = line.split()
        if len(f) == 3:
            sym[f[2]] = int(f[0], 16)
    moved, changed, unknown, n = [], [], [], 0
    for line in open(refs):
        if not line.strip() or line.startswith('#'):
            continue
        f = line.split()
        a, use, name = int(f[0], 16), f[1], f[-1]
        n += 1
        lab, _, off = name.partition('+')
        if lab not in sym:
            unknown.append((a, use, name))
        else:
            new = sym[lab] + (int(off, 16) if off else 0)
            if new != a:
                moved.append((a, use, name, new))
        o = a - ROM_BASE
        span = {'come-from': (o - 2, o), 'jump-in': (o, o + 4)}.get(use, (o, o + 2))
        if rom[span[0]:span[1]] != orig[span[0]:span[1]]:
            changed.append((a, use, name))
    if not moved and not changed:
        print('Mac OS 8.1 compatibility: all %d ROM addresses it uses are in place and unchanged' % n)
        return 0
    print('Mac OS 8.1 compatibility: NO - %d of %d ROM addresses moved, %d changed'
          % (len(moved), n, len(changed)))
    for a, use, name, new in moved[:None if verbose else 10]:
        print('  moved    %08X %-9s %s -> %08X' % (a, use, name, new))
    for a, use, name in changed[:None if verbose else 10]:
        print('  changed  %08X %-9s %s' % (a, use, name))
    if not verbose and (len(moved) > 10 or len(changed) > 10):
        print('  (-v for all)')
    if unknown:
        print('  %d labels from the list are not in the build (renamed?)' % len(unknown))
    return 1


if __name__ == '__main__':
    sys.exit(main())
