#!/usr/bin/env python3
"""picts2s.py - the ROM's 'PICT' resources from PNG images.

Usage:  picts2s.py DIR --romsrc ROMSRC -o OUTDIR

For every DIR/<id>.png (95..106: SCSI Disk Mode, 501) writes OUTDIR/rsrc/<file>.s, with the
picture in place of the resource's data. Dark pixels are set. The picture must fit in the
resource's space (the rest is zeroed), so nothing else in the ROM moves. A resource without
a PNG keeps its current data.
"""
import argparse
import glob
import os
import re
import sys

from PIL import Image

from pict2s import data_lines, pict_from_image

DATA = re.compile(r'\s+\.(long|short|byte)\s+([^|/]*)')
SIZE = {'long': 4, 'short': 2, 'byte': 1}


def replace(lines, pict, name):
    head = re.search(r'(\d+) bytes', lines[0])
    if not head:
        sys.exit('picts2s: %s: no size in the first line' % name)
    area = int(head.group(1))
    if len(pict) > area:
        sys.exit('picts2s: %s: %d bytes, %d over the %d available' % (name, len(pict), len(pict) - area, area))
    start = next(i for i, l in enumerate(lines) if re.match(r'rsrc_PICT_\w+:\s*/\* the resource data', l))
    end, got, last = start + 1, 0, b''
    while got < area:
        m = DATA.match(lines[end])
        if not m:
            sys.exit('picts2s: %s: unexpected line %d' % (name, end + 1))
        n = SIZE[m.group(1)]
        last = b''.join(int(v, 0).to_bytes(n, 'big') for v in m.group(2).split(','))
        got += len(last)
        end += 1
    rest = last[len(last) - (got - area):] if got > area else b''       # bytes after the resource
    tail = ['    .byte   ' + ', '.join('0x%02X' % c for c in rest)] if rest else []
    return lines[:start + 1] + data_lines(pict + bytes(area - len(pict))) + tail + lines[end:]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('dir')
    ap.add_argument('--romsrc', required=True)
    ap.add_argument('-o', dest='out', required=True)
    a = ap.parse_args()
    count = 0
    for png in sorted(glob.glob(os.path.join(a.dir, '*.png'))):
        rid = os.path.splitext(os.path.basename(png))[0]
        found = glob.glob(os.path.join(a.romsrc, 'rsrc', '*_PICT_%s_*.s' % rid))
        if len(found) != 1:
            sys.exit('picts2s: %s: no such PICT resource' % png)
        lines = open(found[0], encoding='latin-1').read().split('\n')
        out = os.path.join(a.out, 'rsrc', os.path.basename(found[0]))
        os.makedirs(os.path.dirname(out), exist_ok=True)
        new = replace(lines, pict_from_image(Image.open(png)), png)
        open(out, 'w', encoding='latin-1').write('\n'.join(new))
        count += 1
    print('picts2s: %d pictures' % count)


if __name__ == '__main__':
    main()
