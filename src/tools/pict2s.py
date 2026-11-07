#!/usr/bin/env python3
"""pict2s.py - the hidden start-up picture (PICTUREDATA, romsrc/misc/picturedata.s).

INITOVERPATCH (patches/overpatches.s) shows a picture when a key combination is held for a
second at start-up: the screen fades out and is painted black, and the picture is drawn
in the centre with a double frame. In the original ROM it is the names of the ROM team
(324 x 300 pixels, white on black).

The data at PICTUREDATA (0x408A0B60, 5542 bytes) is a version 1 PICT, compressed:
  long   size of the PICT (the handle INITOVERPATCH allocates)
  word   0x0012: offset from this word to the code stream
  16     bytes: the table of frequent bytes
  ...    the code stream, read with bfexts 9 bits at a time:
           1 + 4 bits   table byte (index 0-15), 5 bits
           0 + 8 bits   literal byte, 9 bits

Usage:
  pict2s.py --rom ROM --png OUT.png               the original picture as PNG
  pict2s.py PNG --romsrc ROMSRC -o OUTDIR         OUTDIR/misc/picturedata.s with the
                                                  picture from PNG (the rest of the file
                                                  from ROMSRC/misc/picturedata.s)
  pict2s.py PNG --pict OUT.pict                   the uncompressed PICT (to check it)

PNG input: dark pixels are set bits (drawn black; the screen around the picture is black
too). Any size that fits the screen; the compressed picture must fit in 5542 bytes, or the
tool says how much is over (large areas of one colour compress best).
"""
import argparse
import collections
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
ROM_BASE = 0x40800000
OFFSET = 0xA0B60          # PICTUREDATA
AREA = 5542               # bytes up to the end of the original data
FILE = 'misc/picturedata.s'


# ---- compression ---------------------------------------------------------------------
def unpack(data):
    """Compressed PICTUREDATA -> PICT bytes (as INITOVERPATCH_150 does)."""
    size, skip = struct.unpack('>IH', data[:6])
    start = 4 + skip
    table = data[start - 16:start]
    bits = int.from_bytes(data[start:] + b'\0\0', 'big')
    nbits = (len(data) - start + 2) * 8
    out, pos = bytearray(), 0
    while len(out) < size:
        v = (bits >> (nbits - pos - 9)) & 0x1FF
        if v & 0x100:
            out.append(table[(v >> 4) & 15])
            pos += 5
        else:
            out.append(v)
            pos += 9
    return bytes(out)


def pack(pict):
    """PICT bytes -> compressed PICTUREDATA (the 16 most frequent bytes in the table)."""
    table = bytes(b for b, _ in collections.Counter(pict).most_common(16)).ljust(16, b'\0')
    index = {b: i for i, b in enumerate(table)}
    acc, n = 0, 0
    for b in pict:
        if b in index:
            acc, n = (acc << 5) | 0x10 | index[b], n + 5
        else:
            acc, n = (acc << 9) | b, n + 9
    pad = -n % 8
    stream = (acc << pad).to_bytes((n + pad) // 8, 'big')
    return struct.pack('>IH', len(pict), 2 + 16) + table + stream


# ---- PICT <-> image ------------------------------------------------------------------
def packbits(row):
    out, i = bytearray(), 0
    while i < len(row):
        j = i
        while j + 1 < len(row) and row[j + 1] == row[i] and j - i < 127:
            j += 1
        if j > i:                                           # run of j-i+1 equal bytes
            out += bytes([257 - (j - i + 1), row[i]])
            i = j + 1
            continue
        j = i + 1                                           # literal: until a run of 3
        while j < len(row) and j - i < 128 and not (j + 2 < len(row) and row[j] == row[j + 1] == row[j + 2]):
            j += 1
        out += bytes([j - i - 1]) + row[i:j]
        i = j
    return bytes(out)


def pict_from_image(im):
    """1-bit image -> version 1 PICT (PackBitsRect, srcCopy), dark pixels set."""
    im = im.convert('L')
    w, h = im.size
    rb = (w + 15) // 16 * 2
    px = im.load()
    rect = struct.pack('>4h', 0, 0, h, w)
    body = bytearray(b'\x11\x01' + b'\x01' + struct.pack('>H', 10) + rect)
    band = max(1, 0x2000 // rb)                             # a few KB of bitmap per opcode
    for top in range(0, h, band):
        bot = min(h, top + band)
        r = struct.pack('>4h', top, 0, bot, w)
        body += b'\x98' + struct.pack('>H', rb) + r + r + r + struct.pack('>H', 0)
        for y in range(top, bot):
            row = bytearray(rb)
            for x in range(w):
                if px[x, y] < 128:
                    row[x >> 3] |= 0x80 >> (x & 7)
            if rb < 8:
                body += row
            else:
                p = packbits(bytes(row))
                body += (bytes([len(p)]) if rb <= 250 else struct.pack('>H', len(p))) + p
    body += b'\xFF'
    pict = struct.pack('>H', (len(body) + 10) & 0xFFFF) + rect + body
    return pict


# ---- source --------------------------------------------------------------------------
def data_lines(data):
    out, i = [], 0
    while i + 16 <= len(data):
        out.append('    .long   ' + ', '.join('0x%08X' % v for v in struct.unpack('>4I', data[i:i + 16])))
        i += 16
    if i < len(data):
        out.append('    .byte   ' + ', '.join('0x%02X' % b for b in data[i:]))
    return out


def write_source(data, romsrc, outdir, png):
    lines = open(os.path.join(romsrc, FILE)).read().split('\n')
    start = lines.index('PICTUREDATA:            /* (data) */')
    end = next(i for i in range(start + 1, len(lines)) if not re.match(r'\s+\.(long|short|byte)\s', lines[i]))
    new = ['PICTUREDATA:            /* (data) the picture from %s (tools/pict2s.py) */'
           % os.path.basename(png)] + data_lines(data)
    out = lines[:start] + new + lines[end:]
    path = os.path.join(outdir, FILE)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, 'w').write('\n'.join(out))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('png', nargs='?', help='picture to put in the ROM')
    ap.add_argument('--rom', help='original ROM image (with --png: export its picture)')
    ap.add_argument('--png', dest='png_out', help='write the picture as PNG')
    ap.add_argument('--romsrc', help='romsrc directory (the rest of %s)' % FILE)
    ap.add_argument('--pict', help='write the uncompressed PICT')
    ap.add_argument('-o', dest='out', help='output directory for %s' % FILE)
    a = ap.parse_args()
    from PIL import Image
    if a.rom:
        import extract_applemedia
        pict = unpack(open(a.rom, 'rb').read()[OFFSET:OFFSET + AREA])
        if a.pict:
            open(a.pict, 'wb').write(pict)
        if a.png_out:
            extract_applemedia.pict_to_png(pict, a.png_out)
        return
    if not a.png:
        ap.error('give a PNG or --rom')
    pict = pict_from_image(Image.open(a.png))
    data = pack(pict)
    if unpack(data) != pict:
        sys.exit('pict2s: internal error, the compressed picture does not unpack the same')
    if len(data) > AREA:
        sys.exit('pict2s: %s: %d bytes compressed, %d over the %d available'
                 % (a.png, len(data), len(data) - AREA, AREA))
    if a.pict:
        open(a.pict, 'wb').write(pict)
    if a.out:
        if not a.romsrc:
            ap.error('-o needs --romsrc')
        write_source(data + bytes(AREA - len(data)), a.romsrc, a.out, a.png)
    print('pict2s: %s: %d x %d, PICT %d bytes, compressed %d of %d'
          % (a.png, Image.open(a.png).width, Image.open(a.png).height, len(pict), len(data), AREA))


if __name__ == '__main__':
    main()
