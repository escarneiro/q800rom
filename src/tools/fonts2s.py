#!/usr/bin/env python3
"""fonts2s.py - the ROM's bitmap fonts: 'FONT' resources <-> BDF files <-> source.

  key        file                    resource    font
  chicago12  rsrc/fonts/chicago12.s  'FONT' 12   Chicago 12 (system font: menus, dialogs)
  geneva9    rsrc/fonts/geneva9.s    'FONT' 393  Geneva 9 (application font, small)
  geneva12   rsrc/fonts/geneva12.s   'FONT' 396  Geneva 12
  monaco9    rsrc/fonts/monaco9.s    'FONT' 521  Monaco 9 (monospaced)

Usage:
  fonts2s.py DIR -o OUTDIR          OUTDIR/<file> for every DIR/<key>.bdf
  fonts2s.py DIR --preview PNG      sample text in each font of DIR

BDF input: ENCODING is the Mac Roman character code (0-255). FONT_ASCENT and
FONT_DESCENT must equal those of the font replaced (the line height does not change).
Each glyph's BBX gives its bitmap and its position, DWIDTH its advance. Glyph DEFAULT_CHAR
(or the last glyph if it is above the font's last character) is drawn for characters the
font lacks.

The resource keeps its exact size, so nothing else in the ROM moves: the glyph images must
fit in the original strike (rowWords x 16 pixels, plus the room of the optional image
height table, which is dropped when needed); unused space is zero-filled.
"""
import argparse
import math
import os
import struct
import sys

# key, file, ROM offset, size, description, (ascent, descent, leading, firstChar, lastChar)
FONTS = [
    ('chicago12', 'rsrc/fonts/chicago12.s', 0x7DBC0, 3614, "'FONT' 12: Chicago 12, the system font",
     (12, 3, 1, 0x00, 0xF0)),
    ('geneva9', 'rsrc/fonts/geneva9.s', 0x7D130, 2594, "'FONT' 393: Geneva 9", (10, 2, 0, 0x00, 0xD9)),
    ('geneva12', 'rsrc/fonts/geneva12.s', 0x7C490, 3176, "'FONT' 396: Geneva 12", (12, 3, 1, 0x00, 0xD9)),
    ('monaco9', 'rsrc/fonts/monaco9.s', 0x7BA80, 2468, "'FONT' 521: Monaco 9", (9, 2, 0, 0x00, 0xD9)),
]
FIELDS = ('fontType firstChar lastChar widMax kernMax nDescent fRectWidth fRectHeight owTLoc '
          'ascent descent leading rowWords').split()
COMMENTS = {
    'fontType': 'font type (0x9001: with image height table, 0x9000: without)',
    'firstChar': 'first character code', 'lastChar': 'last character code',
    'widMax': 'widest advance', 'kernMax': 'most negative glyph offset (kerning)',
    'nDescent': 'negated ascent', 'fRectWidth': 'width of the font rectangle',
    'fRectHeight': 'height of the font rectangle (strike rows)',
    'owTLoc': 'offset to the offset/width table, in words from this field',
    'ascent': 'ascent', 'descent': 'descent', 'leading': 'leading',
    'rowWords': 'strike row width, in words'}


# ---- 'FONT' resource data ----------------------------------------------------------------
def parse(d):
    h = dict(zip(FIELDS, struct.unpack('>13h', d[:26])))
    n = h['lastChar'] - h['firstChar'] + 3
    H, rb = h['fRectHeight'], h['rowWords'] * 2
    strike = d[26:26 + rb * H]
    o = 26 + rb * H
    loc = struct.unpack('>%dH' % n, d[o:o + 2 * n])
    ow = struct.unpack('>%dH' % n, d[o + 2 * n:o + 4 * n])
    o += 4 * n
    heights = None
    if h['fontType'] & 1:
        heights = struct.unpack('>%dH' % n, d[o:o + 2 * n])
        o += 2 * n
    return h, strike, loc, ow, heights, o


def glyphs_of(d):
    """-> (header, {code or 'missing': (advance, xoffset, rows)}); rows: lists of 0/1, full height."""
    h, strike, loc, ow, _, _ = parse(d)
    H, rb = h['fRectHeight'], h['rowWords'] * 2
    out = {}
    for i in range(h['lastChar'] - h['firstChar'] + 2):
        if ow[i] == 0xFFFF:
            continue
        rows = [[(strike[y * rb + x // 8] >> (7 - x % 8)) & 1 for x in range(loc[i], loc[i + 1])]
                for y in range(H)]
        code = h['firstChar'] + i if i <= h['lastChar'] - h['firstChar'] else 'missing'
        out[code] = (ow[i] & 0xFF, (ow[i] >> 8) + h['kernMax'], rows)
    return h, out


def build(glyphs, ascent, descent, leading, first, last, size):
    """Glyphs -> 'FONT' data of exactly size bytes."""
    H = ascent + descent
    n = last - first + 3
    order = [glyphs.get(c) for c in range(first, last + 1)] + [glyphs['missing']]
    imgs = []
    for g in order:
        if g is None:
            imgs.append(None)
            continue
        adv, xoff, rows = g
        cols = [x for x in range(len(rows[0]) if rows else 0) if any(r[x] for r in rows)]
        if cols:
            x0, x1 = cols[0], cols[-1] + 1
            imgs.append((adv, xoff + x0, [r[x0:x1] for r in rows]))
        else:
            imgs.append((adv, 0, [[] for _ in range(H)]))
    present = [g for g in imgs if g]
    kern = min(0, min(g[1] for g in present))
    total = sum(len(g[2][0]) for g in present)
    words = math.ceil(total / 16)
    base = 26 + 4 * n
    with_heights = base + words * 2 * H + 2 * n <= size
    if not with_heights and base + words * 2 * H > size:
        sys.exit('font does not fit: %d strike pixels, room for %d'
                 % (total, (size - base) // (2 * H) * 16))
    if with_heights:
        words = (size - base - 2 * n) // (2 * H)
    else:
        words = (size - base) // (2 * H)
    strike = [[0] * (words * 16) for _ in range(H)]
    loc, ow, heights = [], [], []
    x = 0
    for g in imgs:
        loc.append(x)
        if g is None:
            ow.append(0xFFFF)
            heights.append(0)
            continue
        adv, xoff, rows = g
        w = len(rows[0])
        for y in range(H):
            strike[y][x:x + w] = rows[y]
        ink = [y for y in range(H) if any(rows[y])]
        heights.append((ink[0] << 8) | (ink[-1] - ink[0] + 1) if ink else 0)
        ow.append(((xoff - kern) << 8) | adv)
        x += w
    loc.append(x)
    ow.append(0xFFFF)
    heights.append(0)
    widmax = max(g[0] for g in present)
    frect = max(g[1] + len(g[2][0]) for g in present) - kern
    owtloc = (26 + words * 2 * H + 2 * n - 16) // 2
    hdr = struct.pack('>13h', 0x9001 - (0 if with_heights else 1) - 0x10000, first, last, widmax, kern,
                      -ascent, frect, H, owtloc, ascent, descent, leading, words)
    bits = bytearray()
    for row in strike:
        for i in range(0, len(row), 8):
            bits.append(sum(b << (7 - j) for j, b in enumerate(row[i:i + 8])))
    d = hdr + bytes(bits) + struct.pack('>%dH' % n, *loc) + struct.pack('>%dH' % n, *ow)
    if with_heights:
        d += struct.pack('>%dH' % n, *heights)
    return d + bytes(size - len(d))


# ---- BDF ---------------------------------------------------------------------------------
def to_bdf(name, h, glyphs):
    A, D = h['ascent'], h['descent']
    lines = ['STARTFONT 2.1', 'FONT -q800rom-%s-medium-r-normal--%d-%d-75-75-p-0-apple-roman'
             % (name, A + D, (A + D) * 10),
             'SIZE %d 75 75' % (A + D), 'FONTBOUNDINGBOX %d %d %d %d' % (h['fRectWidth'], A + D, h['kernMax'], -D),
             'STARTPROPERTIES 4', 'FONT_ASCENT %d' % A, 'FONT_DESCENT %d' % D,
             'DEFAULT_CHAR 256', 'COMMENT_LEADING %d' % h['leading'], 'ENDPROPERTIES',
             'CHARS %d' % len(glyphs)]
    for code in sorted(glyphs, key=lambda c: 256 if c == 'missing' else c):
        adv, xoff, rows = glyphs[code]
        w = len(rows[0]) if rows else 0
        ink = [y for y in range(len(rows)) if any(rows[y])] if w else []
        y0, y1 = (ink[0], ink[-1] + 1) if ink else (A, A)
        enc = 256 if code == 'missing' else code
        lines += ['STARTCHAR %s' % ('missing' if code == 'missing' else 'C%02X' % code),
                  'ENCODING %d' % enc, 'SWIDTH %d 0' % (adv * 1000 // max(1, A + D)), 'DWIDTH %d 0' % adv,
                  'BBX %d %d %d %d' % (w, y1 - y0, xoff, A - y1), 'BITMAP']
        for y in range(y0, y1):
            bits = rows[y] + [0] * (-w % 8)
            lines.append(''.join('%02X' % sum(b << (7 - j) for j, b in enumerate(bits[i:i + 8]))
                                 for i in range(0, len(bits), 8)))
        lines.append('ENDCHAR')
    lines.append('ENDFONT')
    return '\n'.join(lines) + '\n'


def from_bdf(path):
    """-> (ascent, descent, leading or None, {code or 'missing': (advance, xoffset, rows)})"""
    props, glyphs, default = {}, {}, None
    lines = iter(open(path).read().split('\n'))
    for line in lines:
        f = line.split()
        if not f:
            continue
        if f[0] in ('FONT_ASCENT', 'FONT_DESCENT', 'COMMENT_LEADING'):
            props[f[0]] = int(f[1])
        elif f[0] == 'DEFAULT_CHAR':
            default = int(f[1])
        elif f[0] == 'STARTCHAR':
            enc = adv = None
            for line in lines:
                f = line.split()
                if f[0] == 'ENCODING':
                    enc = int(f[1])
                elif f[0] == 'DWIDTH':
                    adv = int(f[1])
                elif f[0] == 'BBX':
                    w, hh, xo, yo = (int(v) for v in f[1:5])
                elif f[0] == 'BITMAP':
                    bm = [next(lines).strip() for _ in range(hh)]
                    next(lines)                                   # ENDCHAR
                    break
            A, D = props['FONT_ASCENT'], props['FONT_DESCENT']
            rows = [[0] * w for _ in range(A + D)]
            for i, hexrow in enumerate(bm):
                y = A - (yo + hh) + i
                v = int(hexrow, 16) if hexrow else 0
                nb = len(hexrow) * 4
                for x in range(w):
                    if 0 <= y < A + D and (v >> (nb - 1 - x)) & 1:
                        rows[y][x] = 1
            glyphs[enc] = (adv, xo, rows)
    if default is not None and default in glyphs:
        glyphs['missing'] = glyphs.pop(default) if default > 255 else glyphs[default]
    elif 'missing' not in glyphs:
        hi = [c for c in glyphs if isinstance(c, int) and c > 255]
        if not hi:
            sys.exit('%s: no glyph for missing characters (DEFAULT_CHAR)' % path)
        glyphs['missing'] = glyphs.pop(max(hi))
    for c in [c for c in glyphs if isinstance(c, int) and c > 255]:
        del glyphs[c]
    return props['FONT_ASCENT'], props['FONT_DESCENT'], props.get('COMMENT_LEADING'), glyphs


# ---- source --------------------------------------------------------------------------------
def asm(key, desc, d, source):
    h, strike, loc, ow, heights, end = parse(d)
    rb = h['rowWords'] * 2
    out = ['| %s - %s' % (key, desc),
           '| Written by tools/fonts2s.py (%s); edit the BDF file instead and regenerate.' % source,
           '| Layout: header, strike (all glyph images side by side, one row of the font per',
           '| block), location table, offset/width table%s.'
           % (', image height table' if heights else ''), '']
    for f, v in zip(FIELDS, struct.unpack('>13h', d[:26])):
        v = '0x%04X' % (v & 0xFFFF) if f == 'fontType' else str(v)
        out.append('    .short  %-6s | %s: %s' % (v, f, COMMENTS[f]))
    for y in range(h['fRectHeight']):
        out.append('| strike row %d' % y)
        row = strike[y * rb:(y + 1) * rb]
        for i in range(0, len(row), 16):
            out.append('    .short  ' + ', '.join('0x%04X' % struct.unpack('>H', row[j:j + 2])[0]
                                                 for j in range(i, min(i + 16, len(row)), 2)))

    def table(title, vals):
        out.append('| ' + title)
        for i in range(0, len(vals), 8):
            c0 = h['firstChar'] + i
            out.append('    .short  ' + ', '.join('0x%04X' % v for v in vals[i:i + 8]) + '  | chars 0x%02X-' % c0)
    table('location table: x of each glyph image in the strike', loc)
    table('offset/width table: offset << 8 | advance (0xFFFF: no glyph)', ow)
    if heights:
        table('image height table: first row << 8 | number of rows', heights)
    if end < len(d):
        rest = d[end:]
        if any(rest):
            sys.exit('%s: unexpected data after the tables' % key)
        out.append('    .fill   %d, 1, 0  | unused' % len(rest))
    return '\n'.join(out) + '\n'


def preview(fonts, path):
    from PIL import Image
    text = ['The quick brown fox jumps over the lazy dog. 0123456789',
            'File Edit View Special Help  Äéñüç «•…» ⌘✓◆']
    lines = []
    for title, (A, D, glyphs) in fonts:
        for t in text:
            codes = []
            for ch in t:
                c = {'⌘': 0x11, '✓': 0x12, '◆': 0x13}.get(ch)
                codes.append(c if c is not None else ch.encode('mac_roman', 'replace')[0])
            lines.append((A + D, glyphs, codes))
    W = 4 + max(sum((g.get(c) or g['missing'])[0] for c in codes) for _, g, codes in lines)
    Hs = sum(h + 3 for h, _, _ in lines)
    im = Image.new('L', (W, Hs), 255)
    y = 0
    for h, g, codes in lines:
        x = 2
        for c in codes:
            adv, xo, rows = g.get(c) or g['missing']
            for yy, r in enumerate(rows):
                for xx, b in enumerate(r):
                    if b and 0 <= x + xo + xx < W:
                        im.putpixel((x + xo + xx, y + yy), 0)
            x += adv
        y += h + 3
    im.resize((W * 3, Hs * 3), Image.NEAREST).save(path)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('dir', nargs='?', help='directory with <key>.bdf files')
    ap.add_argument('-o', dest='out', help='directory to write the source files into')
    ap.add_argument('--preview', metavar='PNG', help='write a sample of the fonts')
    a = ap.parse_args()
    written, samples = [], []
    for key, name, off, size, desc, (fa, fd, flead, first, last) in FONTS:
        data, source = None, None
        bdf = os.path.join(a.dir, key + '.bdf') if a.dir else None
        if bdf and os.path.exists(bdf):
            A, D, lead, g = from_bdf(bdf)
            if (A, D) != (fa, fd):
                sys.exit('%s: FONT_ASCENT %d, FONT_DESCENT %d; must be %d and %d' % (bdf, A, D, fa, fd))
            if a.preview:
                samples.append((key, (A, D, g)))
            data = build(g, A, D, flead, first, last, size)
            source = 'from %s' % os.path.basename(bdf)
        if data and a.out:
            path = os.path.join(a.out, name)
            os.makedirs(os.path.dirname(path), exist_ok=True)
            open(path, 'w').write(asm(key, desc, data, source))
            written.append(name)
    if a.preview:
        preview(samples, a.preview)
    if a.out:
        print('fonts2s.py: wrote %s' % (', '.join(written) or 'nothing (no BDF files found)'), file=sys.stderr)


if __name__ == '__main__':
    main()
