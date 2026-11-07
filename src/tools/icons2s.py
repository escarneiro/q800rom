#!/usr/bin/env python3
"""icons2s.py - write the ROM's icons and cursors as source, from PNG images.

The icons and cursors live in small source files that the ROM source includes:

  file                        PNG directory   items
  boot/booticons.s            boot/           happy, disk, diskq, diskx
  rsrc/icons/sony_a.s         sony/           media, drive01 .. drive06
  rsrc/icons/sony_b.s         sony/           drive07 .. drive17
  rsrc/icons/edisk.s          edisk/          media
  rsrc/icons/atboot.s         atboot/         frame1, frame2, frame3 (one shared mask)
  rsrc/icons/curs_1.s ..      cursors/        ibeam, cross, plus, watch
  quickdraw/arrow.s           cursors/        arrow

  boot     the startup icons: happy computer (a startup disk was found), plain disk,
           disk with ? (no startup disk yet), disk with X (not a startup disk)
  sony     floppy driver: the media icon (a floppy disk) and 17 drive icons, one per
           group of Mac models; the arrow shows where the drive is
  edisk    RAM disk driver: media icon
  atboot   network boot driver: three animation frames of a computer
  cursors  'CURS' 1-4 (I-beam, crosshair, plus, watch) and QuickDraw's arrow

Usage:
  icons2s.py DIR --romsrc ROMSRC -o OUTDIR
        for every file with at least one PNG in DIR, write OUTDIR/<file>; items without a
        PNG keep their current data (read from ROMSRC/<file>)
  icons2s.py --rom ROM -o OUTDIR       every file, with the icons of an original ROM
  icons2s.py --rom ROM --png PNGDIR    the original icons as PNGs (a starting point)
  icons2s.py DIR --romsrc ROMSRC --png PREVIEW --scale 6     enlarged preview

PNG input: icons 32x32, cursors 16x16 (or an integer multiple). Dark pixels are the image.
The mask is the opaque area of a PNG with transparency, otherwise the image's outline
filled in. Red pixels invert what is behind them (image 1, mask 0: the I-beam and the
crosshair are drawn that way). A cursor's hotspot is read from the PNG text field "hotspot" ("x,y"); without
it the current hotspot is kept. The three atboot frames share one mask (their union).
"""
import argparse
import os
import re
import sys

# kind: icn (32x32 icon + mask), icnw (icn + 2 bytes after it, kept), frame (32x32, no
# mask), mask (32x32 mask for the frames before it), curs (16x16 + mask + hotspot)
SIZE = {'icn': 256, 'icnw': 258, 'frame': 128, 'mask': 128, 'curs': 68}

_DRIVE = 'drive icon %d (the arrow shows where the drive is)'
REGIONS = [
    ('boot/booticons.s', 0x017F2, 'boot',
     'the boot icons, drawn by HAPPYMAC, SHOWPLAINDISK, SHOWDISKQ and SHOWDISKX (boot/startmgr.s)',
     [('happy', 'BOOTICON_HAPPY', 'icn', 'happy computer: startup disk found'),
      ('disk', 'BOOTICON_DISK', 'icn', 'plain disk'),
      ('diskq', 'BOOTICON_DISKQ', 'icn', 'disk with question mark: no startup disk yet'),
      ('diskx', 'BOOTICON_DISKX', 'icn', 'disk with X: not a startup disk')]),
    ('rsrc/icons/sony_a.s', 0x6D930, 'sony',
     'floppy driver (.Sony) icons, found through the per-machine tables at dat_40870C8C',
     [('media', 'SONY_ICON_MEDIA', 'icnw', 'media icon: floppy disk')] +
     [('drive%02d' % i, 'SONY_ICON_DRIVE%02d' % i, 'icnw', _DRIVE % i) for i in range(1, 7)]),
    ('rsrc/icons/sony_b.s', 0x70E16, 'sony',
     'floppy driver (.Sony) icons, continued',
     [('drive%02d' % i, 'SONY_ICON_DRIVE%02d' % i, 'icnw', _DRIVE % i) for i in range(7, 18)]),
    ('rsrc/icons/edisk.s', 0xE7DB2, 'edisk', 'RAM disk driver (.EDisk) icon',
     [('media', 'EDISK_ICON_MEDIA', 'icn', 'media icon: RAM disk')]),
    ('rsrc/icons/atboot.s', 0x5277E, 'atboot',
     'network boot driver (.ATBOOT) animation: frame n is at ATBOOT_ICON_FRAMES + n*128',
     [('frame1', 'ATBOOT_ICON_FRAMES', 'frame', 'frame 1'),
      ('frame2', 'ATBOOT_ICON_FRAME2', 'frame', 'frame 2'),
      ('frame3', 'ATBOOT_ICON_FRAME3', 'frame', 'frame 3'),
      ('mask', 'ATBOOT_ICON_MASK', 'mask', 'mask of all three frames')]),
    ('rsrc/icons/curs_1.s', 0x7EBC0, 'cursors', "'CURS' 1",
     [('ibeam', 'CURS_1_IBEAM', 'curs', 'text I-beam')]),
    ('rsrc/icons/curs_2.s', 0x7EB40, 'cursors', "'CURS' 2",
     [('cross', 'CURS_2_CROSS', 'curs', 'crosshair')]),
    ('rsrc/icons/curs_3.s', 0x7EAC0, 'cursors', "'CURS' 3",
     [('plus', 'CURS_3_PLUS', 'curs', 'plus')]),
    ('rsrc/icons/curs_4.s', 0x7EA40, 'cursors', "'CURS' 4",
     [('watch', 'CURS_4_WATCH', 'curs', 'watch (busy)')]),
    ('quickdraw/arrow.s', 0x3164C, 'cursors', "QuickDraw's arrow cursor (InitCursor)",
     [('arrow', 'ARROW_CURSOR', 'curs', 'arrow')]),
]


# ---- bitmaps --------------------------------------------------------------------------
def rows_of(data, n, width):
    step = width // 8
    return [int.from_bytes(data[i * step:(i + 1) * step], 'big') for i in range(n)]


def bytes_of(rows, width):
    return b''.join(r.to_bytes(width // 8, 'big') for r in rows)


def auto_mask(img, n):
    # outside = light pixels connected to the border; the mask is everything else
    outside = [[False] * n for _ in range(n)]
    stack = [(x, y) for x in range(n) for y in (0, n - 1)] + [(x, y) for y in range(n) for x in (0, n - 1)]
    while stack:
        x, y = stack.pop()
        if 0 <= x < n and 0 <= y < n and not outside[y][x] and not (img[y] >> (n - 1 - x)) & 1:
            outside[y][x] = True
            stack += [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]
    return [sum((0 if outside[y][x] else 1) << (n - 1 - x) for x in range(n)) for y in range(n)]


def read_png(path, n):
    """-> (image rows, mask rows, hotspot or None)"""
    from PIL import Image
    im = Image.open(path)
    if im.width != im.height or im.width % n:
        sys.exit('%s: must be %dx%d (or a multiple)' % (path, n, n))
    f = im.width // n
    hotspot = None
    if 'hotspot' in im.info:
        x, y = (int(v) for v in im.info['hotspot'].split(','))
        hotspot = (y, x)
    has_alpha = im.mode in ('RGBA', 'LA') or 'transparency' in im.info
    px = im.convert('RGBA').load()
    img, mask, inv = [], [], []
    for y in range(n):
        ir = mr = vr = 0
        for x in range(n):
            r, g, b, a = px[x * f + f // 2, y * f + f // 2]
            bit = 1 << (n - 1 - x)
            if a < 128:
                continue
            if r > 200 and g < 80 and b < 80:
                vr |= bit                       # red: invert
            else:
                mr |= bit
                if (r * 299 + g * 587 + b * 114) < 128000:
                    ir |= bit
        img.append(ir)
        mask.append(mr)
        inv.append(vr)
    if not has_alpha:
        mask = auto_mask(img, n)
    mask = [(m | i) & ~v for m, i, v in zip(mask, img, inv)]
    return [i | v for i, v in zip(img, inv)], mask, hotspot


def write_png(path, img, mask, n, scale=1, hotspot=None):
    from PIL import Image, PngImagePlugin
    im = Image.new('RGBA', (n, n))
    for y in range(n):
        for x in range(n):
            b = n - 1 - x
            i, m = (img[y] >> b) & 1, (mask[y] >> b) & 1
            im.putpixel((x, y), [(255, 255, 255, 0), (255, 0, 0, 255),
                                 (255, 255, 255, 255), (0, 0, 0, 255)][m * 2 + i])
    if scale > 1:
        im = im.resize((n * scale, n * scale), Image.NEAREST)
    info = PngImagePlugin.PngInfo()
    if hotspot:
        info.add_text('hotspot', '%d,%d' % (hotspot[1], hotspot[0]))
    im.save(path, pnginfo=info)


# ---- current data: from the ROM or from the existing source file -----------------------
def parse_source(path):
    """Bytes of a file written by this tool (.long/.short/.byte with numeric values)."""
    out = bytearray()
    for line in open(path):
        line = re.sub(r'/\*.*?\*/', '', line).split('|')[0].strip()
        m = re.match(r'\.(long|short|byte)\s+(.*)', line)
        if not m:
            continue
        size = {'long': 4, 'short': 2, 'byte': 1}[m.group(1)]
        for v in m.group(2).split(','):
            out += (int(v.strip(), 0) & ((1 << (8 * size)) - 1)).to_bytes(size, 'big')
    return bytes(out)


def region_size(items):
    return sum(SIZE[k] for _, _, k, _ in items)


# ---- items -> source --------------------------------------------------------------------
def picture(r, n):
    return ''.join('#' if (r >> (n - 1 - x)) & 1 else '.' for x in range(n))


def emit_rows(out, rows, n):
    d = '.long ' if n == 32 else '.short'
    for r in rows:
        out.append('    {}  0b{:0{w}b}  /* {} */'.format(d, r, picture(r, n), w=n))


def asm(name, desc, items, data, source):
    out = ['/*', ' %s - %s' % (name, desc),
           ' Written by tools/icons2s.py (%s): one row per line, the comment shows the row.' % source,
           '*/', '']
    o = 0
    for key, label, kind, idesc in items:
        d = data[o:o + SIZE[kind]]
        o += SIZE[kind]
        out.append('%s:  /* %s */' % (label, idesc))
        if kind in ('icn', 'icnw'):
            emit_rows(out, rows_of(d, 32, 32), 32)
            out.append('%s_mask:' % label)
            emit_rows(out, rows_of(d[128:], 32, 32), 32)
            if kind == 'icnw':
                out.append('    .short  0x%04X  /* after the icon (kept as is) */' % int.from_bytes(d[256:258], 'big'))
        elif kind in ('frame', 'mask'):
            emit_rows(out, rows_of(d, 32, 32), 32)
        else:
            emit_rows(out, rows_of(d, 16, 16), 16)
            out.append('%s_mask:' % label)
            emit_rows(out, rows_of(d[32:], 16, 16), 16)
            out.append('    .short  %d, %d  /* hotspot (vertical, horizontal) */'
                       % (int.from_bytes(d[64:66], 'big'), int.from_bytes(d[66:68], 'big')))
        out.append('')
    return '\n'.join(out)


DATA_LINE = re.compile(r'\s+\.(long|short|byte)\s')


def merge(path, generated):
    """The romsrc file at path with its data lines replaced by those of the generated
    source, in order: its header, comments and any other labels stay as they are."""
    new = [l for l in generated.split('\n') if DATA_LINE.match(l)]
    lines = open(path).read().split('\n')
    old = [i for i, l in enumerate(lines) if DATA_LINE.match(l)]
    if len(old) != len(new):
        sys.exit('%s: %d data lines, expected %d' % (path, len(old), len(new)))
    for i, l in zip(old, new):
        lines[i] = l
    return '\n'.join(lines)


def replace_items(items, data, pngdir):
    """Apply the PNGs found in pngdir to data; -> (new data, number of PNGs used)."""
    data = bytearray(data)
    used = 0
    offs, o = {}, 0
    for key, label, kind, _ in items:
        offs[key] = o
        o += SIZE[kind]
    frames = [k for k, _, kind, _ in items if kind == 'frame']
    frame_masks = []
    for key, label, kind, _ in items:
        p = os.path.join(pngdir, key + '.png')
        if kind == 'mask' or not os.path.exists(p):
            continue
        used += 1
        o = offs[key]
        if kind == 'curs':
            img, mask, hot = read_png(p, 16)
            data[o:o + 64] = bytes_of(img, 16) + bytes_of(mask, 16)
            if hot:
                data[o + 64:o + 68] = hot[0].to_bytes(2, 'big') + hot[1].to_bytes(2, 'big')
        else:
            img, mask, _ = read_png(p, 32)
            if kind == 'frame':
                data[o:o + 128] = bytes_of(img, 32)
                frame_masks.append(mask)
            else:
                data[o:o + 256] = bytes_of(img, 32) + bytes_of(mask, 32)
    if frame_masks:
        mkey = [k for k, _, kind, _ in items if kind == 'mask'][0]
        o = offs[mkey]
        union = [0] * 32 if len(frame_masks) == len(frames) else rows_of(data[o:o + 128], 32, 32)
        for m in frame_masks:
            union = [a | b for a, b in zip(union, m)]
        data[o:o + 128] = bytes_of(union, 32)
    return bytes(data), used


def export_pngs(items, data, outdir, scale):
    os.makedirs(outdir, exist_ok=True)
    o = 0
    mask = None
    kinds = [k for _, _, k, _ in items]
    if 'mask' in kinds:
        mo = sum(SIZE[k] for k in kinds[:kinds.index('mask')])
        mask = rows_of(data[mo:mo + 128], 32, 32)
    for key, label, kind, _ in items:
        d = data[o:o + SIZE[kind]]
        o += SIZE[kind]
        p = os.path.join(outdir, key + '.png')
        if kind in ('icn', 'icnw'):
            write_png(p, rows_of(d, 32, 32), rows_of(d[128:], 32, 32), 32, scale)
        elif kind == 'frame':
            write_png(p, rows_of(d, 32, 32), mask, 32, scale)
        elif kind == 'curs':
            write_png(p, rows_of(d, 16, 16), rows_of(d[32:], 16, 16), 16, scale,
                      (int.from_bytes(d[64:66], 'big'), int.from_bytes(d[66:68], 'big')))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('dir', nargs='?', help='PNG directory (boot/, sony/, edisk/, atboot/, cursors/)')
    ap.add_argument('--rom', help='take the current data from an original ROM image')
    ap.add_argument('--romsrc', help='take the current data from the romsrc/ files')
    ap.add_argument('-o', dest='out', help='directory to write the source files into')
    ap.add_argument('--png', metavar='DIR', help='write the icons as PNGs into DIR')
    ap.add_argument('--scale', type=int, default=1, help='PNG scale factor for --png (default 1)')
    a = ap.parse_args()
    if not a.rom and not a.romsrc:
        ap.error('give --rom or --romsrc')
    if not a.out and not a.png:
        ap.error('nothing to write: give -o or --png')
    rom = open(a.rom, 'rb').read() if a.rom else None

    written = []
    for name, off, sub, desc, items in REGIONS:
        size = region_size(items)
        if rom:
            data, source = rom[off:off + size], 'from the original ROM'
        else:
            data, source = parse_source(os.path.join(a.romsrc, name)), 'from romsrc'
            if len(data) != size:
                sys.exit('%s: %d bytes, expected %d' % (name, len(data), size))
        used = 0
        if a.dir:
            data, used = replace_items(items, data, os.path.join(a.dir, sub))
            source = 'from %s/%s' % (os.path.basename(os.path.normpath(a.dir)), sub)
            if not used and a.out:
                continue        # nothing replaced: the romsrc file is used as it is
        if a.out:
            path = os.path.join(a.out, name)
            os.makedirs(os.path.dirname(path), exist_ok=True)
            text = asm(name, desc, items, data, source)
            if a.romsrc:
                text = merge(os.path.join(a.romsrc, name), text)
            with open(path, 'w') as f:
                f.write(text)
            written.append(name)
        if a.png:
            export_pngs(items, data, os.path.join(a.png, sub), a.scale)
    if a.out:
        print('icons2s.py: wrote %s' % (', '.join(written) or 'nothing (no PNGs found)'), file=sys.stderr)


if __name__ == '__main__':
    main()
