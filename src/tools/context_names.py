#!/usr/bin/env python3
"""context_names.py - names for the remaining sub_XXXXXXXX labels, from where they are.

Helpers without a documented name are named after what contains them, with the offset
from its start (the ROUTINE_offset convention used throughout romsrc/):

  main ROM      the nearest Apple routine before it (Apple's MPW link map lists the
                ROM's routines in address order, so the code up to the next listed
                routine is part of that one): GETRESOURCE_1A4; in the FPSP, the
                nearest Motorola routine (fpsp_*) if closer
  resources     the resource the code is in, from the start of its data:
                rsrc_DRVR_4__Sony_1A4E
  declaration   the driver it is in (DECL_DRVR_<name>, counted from the sBlock), else
  ROM           the nearest DECL_ code label before it

With --dat ROM, the dat_XXXXXXXX labels instead: data that starts with readable text
(a C string, or a Pascal string with its length byte) is named after the text, STR_... or
PSTR_...; other data by its context as above. ROM is the image the ELF was built into.

Usage:  context_names.py ELF ROMSRC APPLEMAP [--dat ROM] > names.map
        then: rename_labels.py names.map ROMSRC --locals ELF
"""
import bisect
import os
import re
import subprocess
import sys

ROM_BASE = 0x40800000


def ident(t):
    return re.sub(r'[^A-Za-z0-9]+', '_', t).strip('_')


def text_at(rom, o):
    """('STR'|'PSTR', text) when the bytes at o read as a string, else None."""
    def readable(b):
        if not b or not all(32 <= c < 127 for c in b):
            return False
        letters = sum(1 for c in b if chr(c).isalpha())
        return letters >= 3 and letters >= 0.6 * len(b.replace(b' ', b''))
    n = rom[o]
    if 3 <= n <= 63 and readable(rom[o + 1:o + 1 + n]):
        return 'PSTR', rom[o + 1:o + 1 + n].decode('ascii')
    e = rom.find(b'\0', o, o + 80)
    if e - o >= 5 and readable(rom[o:e]):
        t = rom[o:e].decode('ascii')
        # code that reads as text: 'Nu' is rts (0x4E75); '@' and '"' are rare in names;
        # short words in capitals without spaces are as likely code or a type code
        if 'Nu' in t or '@' in t or '"' in t or (len(t) < 7 and ' ' not in t and t.isupper()):
            return None
        return 'STR', t
    return None


def main():
    args = sys.argv[1:]
    rom = None
    if '--dat' in args:
        i = args.index('--dat')
        rom = open(args[i + 1], 'rb').read()
        del args[i:i + 2]
    if len(args) != 3:
        sys.exit(__doc__)
    elf, root, mapfile = args
    kind = 'dat' if rom else 'sub'
    apple = {}
    for line in open(mapfile):
        f = line.split()
        if len(f) >= 3 and f[1] == 'Main' and re.match(r'\$75,\$[0-9A-F]+$', f[2]):
            apple[f[0]] = None
    nm = subprocess.run([os.environ.get('M68K_NM', '/usr/m68k-suse-linux/bin/nm'), '-n', elf],
                        capture_output=True, text=True, check=True).stdout
    addr = {}
    for line in nm.splitlines():
        f = line.split()
        if len(f) == 3:
            addr[f[2]] = int(f[0], 16)
    # which file each label is defined in
    where = {}
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d != '.git']
        for f in fn:
            if f.endswith('.s'):
                rel = os.path.relpath(os.path.join(dp, f), root)
                for m in re.finditer(r'^([A-Za-z_][A-Za-z0-9_]*):', open(os.path.join(dp, f)).read(), re.M):
                    where[m.group(1)] = rel
    used = set(addr)

    def base_list(names):
        lst = sorted((addr[n], n) for n in names if n in addr)
        return lst, [a for a, _ in lst]

    fpsp_names = set()
    for line in open(os.path.join(root, 'os', 'fpsp.s')):
        m = re.match(r'^(fpsp_[A-Za-z0-9_]+):', line)
        if m and not re.search(r'_[0-9A-F]+$', m.group(1)):
            fpsp_names.add(m.group(1))
    apple_b = base_list([n for n in apple if n in addr] + list(fpsp_names))
    # resource data starts: what the resource map entries point to
    starts = set()
    for dp, dn, fn in os.walk(os.path.join(root, 'rsrc')):
        for f in fn:
            if f.endswith('.s'):
                starts.update(re.findall(r'^\s+\.long\s+(rsrc_\w+)-rom_start', open(os.path.join(dp, f)).read(), re.M))
    rsrc_b = base_list([n for n in starts if not re.search(r'_entry(_[0-9A-F]{8})?$', n)])
    # declaration ROM drivers: the sBlock labels that have a _header label after them
    drvr_b = base_list([n for n in addr if n.startswith('DECL_DRVR_') and n + '_header' in addr])
    decl_code_b = base_list([n for n in addr if n.startswith('DECL_') and
                             re.search(r'_(code|Open|Prime|Control|Status|Close)$', n)])
    decl_any_b = base_list([n for n in addr if n.startswith('DECL_') and not n.endswith('_entry')
                            and not re.search(r'_[0-9A-F]+$', n)])

    def nearest(b, a):
        lst, keys = b
        i = bisect.bisect_right(keys, a) - 1
        return lst[i] if i >= 0 else None

    out = []
    for n, a in sorted(addr.items(), key=lambda x: x[1]):
        if not re.match(r'^%s_[0-9A-F]{8}$' % kind, n):
            continue
        f = where.get(n, '')
        what = 'routine' if kind == 'sub' else 'data'
        if rom:
            t = text_at(rom, a - ROM_BASE)
            if t:
                new = '%s_%s' % (t[0], ident(t[1])[:40])
                if new in used:
                    new = '%s_%X' % (new, a)
                used.add(new)
                out.append('%s %s  # %s string "%s"' % (n, new, 'Pascal' if t[0] == 'PSTR' else 'C', t[1][:60]))
                continue
        if f.startswith('rsrc/'):
            b = nearest(rsrc_b, a)
            how = 'in resource %s' % (b[1] if b else '?')
        elif f.startswith('declrom/'):
            b = nearest(drvr_b, a)
            if b and where.get(b[1]) == f and a - b[0] < 0x4000:
                how = 'in driver %s' % b[1]
            else:
                b = nearest(decl_code_b if kind == 'sub' else decl_any_b, a)
                how = 'after %s' % (b[1] if b else '?')
        else:
            b = nearest(apple_b, a)
            how = ('inside Motorola FPSP routine %s' if b and b[1].startswith('fpsp_') else
                   'inside Apple routine %s (MPW link map)') % (b[1] if b else '?')
        if not b or a <= b[0]:
            continue
        new = '%s_%X' % (b[1], a - b[0])
        if new in used:
            continue
        used.add(new)
        out.append('%s %s  # %s %s' % (n, new, what, how))
    print('# context_names.py: %d %s_ labels' % (len(out), kind))
    print('\n'.join(out))


if __name__ == '__main__':
    main()
