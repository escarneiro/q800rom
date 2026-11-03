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

Usage:  context_names.py ELF ROMSRC APPLEMAP > names.map
        then: rename_labels.py names.map ROMSRC --locals ELF
"""
import bisect
import os
import re
import subprocess
import sys

ROM_BASE = 0x40800000


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    elf, root, mapfile = sys.argv[1:]
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
    rsrc_b = base_list([n for n in addr if re.match(r'^rsrc_[A-Za-z0-9_]+$', n)
                        and not n.endswith(('_entry', '_open', '_prime', '_ctl', '_status', '_close'))
                        and not re.search(r'_entry_[0-9A-F]{8}$', n)])
    drvr_b = base_list([n for n in addr if re.match(r'^DECL_DRVR_[A-Za-z0-9_]+$', n)
                        and not re.search(r'_(header|Open|Prime|Control|Status|Close)\w*$', n)])
    decl_code_b = base_list([n for n in addr if n.startswith('DECL_') and
                             re.search(r'_(code|Open|Prime|Control|Status|Close)$', n)])

    def nearest(b, a):
        lst, keys = b
        i = bisect.bisect_right(keys, a) - 1
        return lst[i] if i >= 0 else None

    out = []
    for n, a in sorted(addr.items(), key=lambda x: x[1]):
        if not re.match(r'^sub_[0-9A-F]{8}$', n):
            continue
        f = where.get(n, '')
        if f.startswith('rsrc/'):
            b = nearest(rsrc_b, a)
            how = 'in resource %s' % (b[1] if b else '?')
        elif f.startswith('declrom/'):
            b = nearest(drvr_b, a)
            if b and where.get(b[1]) == f and a - b[0] < 0x4000:
                how = 'in driver %s' % b[1]
            else:
                b = nearest(decl_code_b, a)
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
        out.append('%s %s  # routine %s' % (n, new, how))
    print('# context_names.py: %d sub_ labels' % len(out))
    print('\n'.join(out))


if __name__ == '__main__':
    main()
