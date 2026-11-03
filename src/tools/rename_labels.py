#!/usr/bin/env python3
"""rename_labels.py - rename labels across romsrc/ from a map file.

Map file lines: "old new  # comment" (comments and blank lines ignored), as written by
tools/declrom_names.py and similar tools. Every .s, .inc and .lst file under romsrc/ is
rewritten, replacing whole identifiers only.

  rename_labels.py MAP ROMSRC [--locals ELF]

--locals ELF: also rename the loc_XXXXXXXX labels inside each renamed routine (a label
whose old name was sub_ or loc_, or whose comment mentions code or a routine) to
ROUTINE_<offset>, the convention used in romsrc; ELF (the linked ROM, built before the
rename) gives the addresses. A routine ends at the next label that is not a loc_.
"""
import os
import re
import subprocess
import sys

IDENT = re.compile(r'\b[A-Za-z_][A-Za-z0-9_]*\b')


def read_map(path):
    m, code = {}, set()
    for line in open(path):
        body, _, comment = line.partition('#')
        f = body.split()
        if len(f) != 2:
            continue
        old, new = f
        if old in m and m[old] != new:
            sys.exit('%s mapped twice' % old)
        m[old] = new
        if old.startswith(('sub_', 'loc_')) or re.search(r'code|routine', comment):
            code.add(old)
    return m, code


def files(root):
    for dp, dn, fn in os.walk(root):
        dn[:] = [d for d in dn if d != '.git']
        for f in fn:
            if f.endswith(('.s', '.inc', '.lst')):
                yield os.path.join(dp, f)


def local_names(root, m, code, elf):
    nm = subprocess.run([os.environ.get('M68K_NM', '/usr/m68k-suse-linux/bin/nm'), elf],
                        capture_output=True, text=True, check=True).stdout
    addr = {}
    for line in nm.splitlines():
        f = line.split()
        if len(f) == 3:
            addr[f[2]] = int(f[0], 16)
    extra = {}
    for p in files(root):
        if not p.endswith('.s'):
            continue
        cur = None
        for line in open(p):
            mm = re.match(r'^([A-Za-z_][A-Za-z0-9_]*):', line)
            if not mm:
                continue
            lab = mm.group(1)
            if lab.startswith('loc_'):
                if lab in m:
                    if lab in code:
                        cur = (m[lab], addr.get(lab))
                    continue
                if cur and cur[1] is not None and lab in addr and addr[lab] > cur[1]:
                    extra[lab] = '%s_%X' % (cur[0], addr[lab] - cur[1])
            elif lab in code:
                cur = (m[lab], addr.get(lab))
            else:
                cur = None
    return extra


def main():
    args = sys.argv[1:]
    elf = None
    if '--locals' in args:
        i = args.index('--locals')
        elf = args[i + 1]
        del args[i:i + 2]
    if len(args) != 2:
        sys.exit(__doc__)
    m, code = read_map(args[0])
    root = args[1]
    if elf:
        extra = local_names(root, m, code, elf)
        m.update(extra)
        print('rename_labels: %d local labels inside renamed routines' % len(extra), file=sys.stderr)
    # the new names must not exist already
    existing = set()
    for p in files(root):
        existing.update(re.findall(r'^([A-Za-z_][A-Za-z0-9_]*):', open(p).read(), re.M))
    clash = sorted(set(m.values()) & (existing - set(m)))
    if clash:
        sys.exit('new names already in use: %s' % ', '.join(clash[:10]))
    changed = 0
    for p in files(root):
        s = open(p).read()
        t = IDENT.sub(lambda x: m.get(x.group(0), x.group(0)), s)
        if t != s:
            open(p, 'w').write(t)
            changed += 1
    print('rename_labels: %d names, %d files changed' % (len(m), changed), file=sys.stderr)


if __name__ == '__main__':
    main()
