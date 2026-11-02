#!/usr/bin/env python3
"""icons2s.py - write the boot icons (romsrc/boot/booticons.s) from images.

The ROM's startup code draws four 32x32 black-and-white icons, each stored as a 128-byte
bitmap followed by a 128-byte mask (boot/startmgr.s: HAPPYMAC, SHOWPLAINDISK, SHOWDISKQ,
SHOWDISKX):

  happy  BOOTICON_HAPPY   a bootable disk was found, the system is starting
  disk   BOOTICON_DISK    plain disk
  diskq  BOOTICON_DISKQ   no startup disk yet (blinks)
  diskx  BOOTICON_DISKX   the disk is not a startup disk (ejected)

Usage:
  icons2s.py DIR -o booticons.s       from DIR/happy.png, disk.png, diskq.png, diskx.png
  icons2s.py --rom ROM -o booticons.s the icons of an original ROM (as they are in romsrc/)
  icons2s.py --rom ROM --png OUTDIR   the ROM's icons as PNGs (a starting point)
  icons2s.py DIR --png OUTDIR --scale 6   preview: enlarged PNGs, mask as transparency

PNG input: 32x32 (or larger, scaled down by an integer factor). Dark pixels are the
icon. The mask is the opaque area if the image has transparency, otherwise everything
not reachable from the border through light pixels (the icon's outline, filled).
"""
import argparse
import os
import sys

ICONS = [('happy', 'BOOTICON_HAPPY', 'happy computer: startup disk found'),
         ('disk', 'BOOTICON_DISK', 'plain disk'),
         ('diskq', 'BOOTICON_DISKQ', 'disk with question mark: no startup disk yet'),
         ('diskx', 'BOOTICON_DISKX', 'disk with X: not a startup disk')]
ROM_ICONS = 0x17F2          # offset of the first icon in the original ROM


def bits_to_rows(data):
    return [int.from_bytes(data[i * 4:i * 4 + 4], 'big') for i in range(32)]


def rows_to_bytes(rows):
    return b''.join(r.to_bytes(4, 'big') for r in rows)


def auto_mask(icon):
    # outside = light pixels connected to the border; the mask is everything else
    outside = [[False] * 32 for _ in range(32)]
    stack = [(x, y) for x in range(32) for y in (0, 31)] + [(x, y) for y in range(32) for x in (0, 31)]
    while stack:
        x, y = stack.pop()
        if 0 <= x < 32 and 0 <= y < 32 and not outside[y][x] and not (icon[y] >> (31 - x)) & 1:
            outside[y][x] = True
            stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return [sum((0 if outside[y][x] else 1) << (31 - x) for x in range(32)) for y in range(32)]


def read_png(path):
    from PIL import Image
    im = Image.open(path)
    if im.width != im.height or im.width % 32:
        sys.exit('%s: must be 32x32 (or a multiple)' % path)
    f = im.width // 32
    has_alpha = im.mode in ('RGBA', 'LA') or 'transparency' in im.info
    im = im.convert('RGBA')
    px = im.load()
    icon, mask = [], []
    for y in range(32):
        ir = mr = 0
        for x in range(32):
            r, g, b, a = px[x * f + f // 2, y * f + f // 2]
            dark = a >= 128 and (r * 299 + g * 587 + b * 114) < 128000
            ir |= dark << (31 - x)
            mr |= (a >= 128) << (31 - x)
        icon.append(ir)
        mask.append(mr)
    if not has_alpha:
        mask = auto_mask(icon)
    mask = [m | i for m, i in zip(mask, icon)]    # the icon must lie inside its mask
    return icon, mask


def write_png(path, icon, mask, scale=1):
    from PIL import Image
    im = Image.new('RGBA', (32, 32))
    for y in range(32):
        for x in range(32):
            b = 31 - x
            if (mask[y] >> b) & 1:
                im.putpixel((x, y), (0, 0, 0, 255) if (icon[y] >> b) & 1 else (255, 255, 255, 255))
            else:
                im.putpixel((x, y), (255, 255, 255, 0))
    if scale > 1:
        im = im.resize((32 * scale, 32 * scale), Image.NEAREST)
    im.save(path)


def picture(r):
    return ''.join('#' if (r >> (31 - x)) & 1 else '.' for x in range(32))


def asm(icons, source):
    out = ['| boot/booticons.s - the boot icons, drawn by HAPPYMAC, SHOWPLAINDISK, SHOWDISKQ and',
           '| SHOWDISKX (boot/startmgr.s): 32x32 bitmaps, each followed by its mask.',
           '| Written by tools/icons2s.py (%s). One .long per row; the comment shows the row.' % source,
           '']
    for (key, label, desc), (icon, mask) in zip(ICONS, icons):
        out.append('%s:                       | %s' % (label, desc))
        for r in icon:
            out.append('    .long   0b{:032b}  | {}'.format(r, picture(r)))
        out.append('%s_mask:' % label)
        for r in mask:
            out.append('    .long   0b{:032b}  | {}'.format(r, picture(r)))
        out.append('')
    return '\n'.join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('dir', nargs='?', help='directory with happy.png, disk.png, diskq.png, diskx.png')
    ap.add_argument('-o', dest='out', help='booticons.s to write')
    ap.add_argument('--rom', help='take the icons from an original ROM image')
    ap.add_argument('--png', metavar='DIR', help='write the icons as PNGs into DIR')
    ap.add_argument('--scale', type=int, default=1, help='PNG scale factor for --png (default 1)')
    a = ap.parse_args()

    if a.rom:
        r = open(a.rom, 'rb').read()
        icons = [(bits_to_rows(r[ROM_ICONS + k * 256:]), bits_to_rows(r[ROM_ICONS + k * 256 + 128:]))
                 for k in range(len(ICONS))]
        source = 'from the original ROM'
    elif a.dir:
        icons = []
        for key, _, _ in ICONS:
            p = os.path.join(a.dir, key + '.png')
            if not os.path.exists(p):
                sys.exit('missing %s (need %s)' % (p, ', '.join(k + '.png' for k, _, _ in ICONS)))
            icons.append(read_png(p))
        source = 'from %s' % os.path.basename(os.path.normpath(a.dir))
    else:
        ap.error('give a DIR of PNGs or --rom')

    if a.png:
        os.makedirs(a.png, exist_ok=True)
        for (key, _, _), (icon, mask) in zip(ICONS, icons):
            write_png(os.path.join(a.png, key + '.png'), icon, mask, a.scale)
    if a.out:
        with open(a.out, 'w') as f:
            f.write(asm(icons, source))
    if not a.out and not a.png:
        ap.error('nothing to write: give out.s or --png')


if __name__ == '__main__':
    main()
