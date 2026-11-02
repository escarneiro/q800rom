#!/usr/bin/env python3
"""extract_applemedia.py - save Apple's media and resources from an original ROM image.

For reference and comparison only: the output is Apple's copyrighted material and is not
part of the repository (applemedia/ is listed in .gitignore).

Usage:  extract_applemedia.py ROM OUTDIR        (make -C src applemedia ORIG_ROM=...)

OUTDIR/
  sounds/     the boot chimes and the alert sound as 'snd ' resources (.snd); the
              uncompressed ones also as .wav; the boot/error beeps as beeps.txt
              (tools/beeps2s.py format)
  icons/      icons and cursors as PNG (tools/icons2s.py layout)
  fonts/      the four bitmap fonts as BDF, and a sample (fonts.png)
  pictures/   the 'PICT' resources as PNG
  resources/  every ROM resource's data, as TYPE/ID[_name].bin
"""
import os
import struct
import sys
import wave

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import beeps2s      # noqa: E402
import fonts2s      # noqa: E402
import icons2s      # noqa: E402

ROM_BASE = 0x40800000
SOUNDS = [          # name, ROM offset, end of the sound data
    ('bootchime', 0xC2722, 0xC67AE),            # enhanced sound chip (Quadra 800); compressed
    ('bootchime_alt', 0xBD4C4, 0xC2711),        # enhanced chip, hardware flag set; compressed
    ('bootchime_plain', 0xC67BE, 0xCE1B2),      # other sound chips; uncompressed
]


def u16(d, o):
    return struct.unpack('>H', d[o:o + 2])[0]


def u32(d, o):
    return struct.unpack('>I', d[o:o + 4])[0]


def resources(rom):
    """-> [(type, id, name, data)] from the ROM resource map (header offset 0x1A)."""
    out = []
    e = u32(rom, u32(rom, 0x1A))
    while e:
        data = u32(rom, e + 12)
        typ = rom[e + 16:e + 20].decode('mac_roman')
        rid = struct.unpack('>h', rom[e + 20:e + 22])[0]
        name = rom[e + 24:e + 24 + rom[e + 23]].decode('mac_roman')
        size = u32(rom, data - 8) - 12
        out.append((typ, rid, name, rom[data:data + size]))
        e = u32(rom, e + 8)
    return out


def snd_to_wav(snd, path):
    """Write an uncompressed 8-bit format 1 'snd ' as a WAV file; False if it is not one."""
    if u16(snd, 0) != 1 or u16(snd, 2) != 1:
        return False
    cmd = 4 + 6 * u16(snd, 2) + 2                         # first command, after the synths
    h = u32(snd, cmd + 4)                                 # its param2: the sound header
    if snd[h + 20] != 0:
        return False                                       # compressed or extended header
    n, rate = u32(snd, h + 4), u32(snd, h + 8) / 65536.0
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(1)                                  # WAV 8-bit is unsigned, like the Mac's
        w.setframerate(int(round(rate)))
        w.writeframes(snd[h + 22:h + 22 + n])
    return True


def pict_to_png(d, path):
    """Version 1 PICT with bitmap opcodes -> PNG. Returns False for opcodes not handled."""
    from PIL import Image
    top, left, bottom, right = struct.unpack('>4h', d[2:10])
    if d[10:12] != b'\x11\x01':
        return False
    im = Image.new('1', (right - left, bottom - top), 1)
    o = 12
    while o < len(d):
        op = d[o]
        o += 1
        if op == 0xFF:
            break
        elif op == 0x00:
            continue
        elif op == 0x01:                                   # clip region
            o += u16(d, o)
        elif op == 0xA0:                                   # short comment
            o += 2
        elif op == 0xA1:                                   # long comment
            o += 4 + u16(d, o + 2)
        elif op == 0x1E:                                   # DefHilite
            continue
        elif op in (0x90, 0x91, 0x98, 0x99):               # bitmap, maybe PackBits
            rb = u16(d, o) & 0x3FFF
            bt, bl, bb, br = struct.unpack('>4h', d[o + 2:o + 10])
            dt, dl = struct.unpack('>2h', d[o + 18:o + 22])
            o += 28
            if op in (0x91, 0x99):
                o += u16(d, o)
            rows = []
            for _ in range(bb - bt):
                if op in (0x98, 0x99) and rb >= 8:
                    n = d[o] if rb <= 250 else u16(d, o)
                    o += 1 if rb <= 250 else 2
                    end, row = o + n, bytearray()
                    while o < end:
                        c = d[o]
                        o += 1
                        if c < 128:
                            row += d[o:o + c + 1]
                            o += c + 1
                        elif c > 128:
                            row += bytes([d[o]]) * (257 - c)
                            o += 1
                    rows.append(bytes(row))
                else:
                    rows.append(d[o:o + rb])
                    o += rb
            for y, row in enumerate(rows):
                for x in range(br - bl):
                    if (row[x // 8] >> (7 - x % 8)) & 1:
                        px, py = dl - left + x, dt - top + y
                        if 0 <= px < im.width and 0 <= py < im.height:
                            im.putpixel((px, py), 0)
        else:
            return False
    im.save(path)
    return True


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    rom = open(sys.argv[1], 'rb').read()
    out = sys.argv[2]
    if len(rom) != 0x100000:
        sys.exit('%s: not a 1 MB ROM image' % sys.argv[1])
    res = resources(rom)

    d = os.path.join(out, 'resources')
    for typ, rid, name, data in res:
        safe = ''.join(c if c.isalnum() or c in '-_.' else '_' for c in typ)
        os.makedirs(os.path.join(d, safe), exist_ok=True)
        fn = str(rid) + ('_' + ''.join(c if c.isalnum() else '_' for c in name) if name else '')
        open(os.path.join(d, safe, fn + '.bin'), 'wb').write(data)

    d = os.path.join(out, 'sounds')
    os.makedirs(d, exist_ok=True)
    snds = [(n, rom[a:b]) for n, a, b in SOUNDS]
    snds += [('alertsound', data) for typ, rid, name, data in res if typ == 'snd ' and rid == 1]
    for n, snd in snds:
        open(os.path.join(d, n + '.snd'), 'wb').write(snd)
        snd_to_wav(snd, os.path.join(d, n + '.wav'))
    open(os.path.join(d, 'beeps.txt'), 'w').write(beeps2s.text(beeps2s.from_rom(rom)))

    for name, off, sub, desc, items in icons2s.REGIONS:
        size = icons2s.region_size(items)
        icons2s.export_pngs(items, rom[off:off + size], os.path.join(out, 'icons', sub), 1)

    d = os.path.join(out, 'fonts')
    os.makedirs(d, exist_ok=True)
    samples = []
    for key, name, off, size, desc, _ in fonts2s.FONTS:
        h, g = fonts2s.glyphs_of(rom[off:off + size])
        open(os.path.join(d, key + '.bdf'), 'w').write(fonts2s.to_bdf(key, h, g))
        samples.append((key, (h['ascent'], h['descent'], g)))
    fonts2s.preview(samples, os.path.join(d, 'fonts.png'))

    d = os.path.join(out, 'pictures')
    os.makedirs(d, exist_ok=True)
    bad = []
    for typ, rid, name, data in res:
        if typ == 'PICT':
            fn = str(rid) + ('_' + ''.join(c if c.isalnum() else '_' for c in name) if name else '')
            if not pict_to_png(data, os.path.join(d, fn + '.png')):
                bad.append(rid)
    print('applemedia: %d resources, %d sounds, icons, fonts, pictures%s -> %s'
          % (len(res), len(snds), ' (PICTs not converted: %s)' % bad if bad else '', out))


if __name__ == '__main__':
    main()
