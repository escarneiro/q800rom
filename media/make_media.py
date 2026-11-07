#!/usr/bin/env python3
"""make_media.py - generate the project's own sounds, icons, fonts and picture.

Everything here is original work made for this project (no Apple material): the chime is
synthesized, the icons are drawn below as text. Run it to regenerate the files:

  python3 media/make_media.py        writes media/chime.wav, alert.wav, beeps.txt,
                                     media/icons/*/*.png, media/fonts/*.bdf and
                                     media/picture.png

The fonts are rendered from free fonts installed on the system: DejaVu Sans (2.37; see
fonts/LICENSE-DejaVu.txt) and the public domain X11 misc-fixed 6x10 terminal font.

Build a ROM with them:  make -C src rom FREE_MEDIA=1
"""
import gzip
import math
import os
import struct
import sys
import wave

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))


# ---- boot chime: a rolled G major chord with bell-like partials, 2.2 s -------------------
def chime(path):
    rate, length = 44100, 2.2
    notes = [(392.00, 0.0), (493.88, 0.06), (587.33, 0.12), (783.99, 0.18)]
    frames = bytearray()
    for i in range(int(rate * length)):
        t = i / rate
        s = 0.0
        for f, delay in notes:
            u = t - delay
            if u < 0:
                continue
            env = min(1, u / 0.004) * math.exp(-u * 2.2)
            s += env * (math.sin(2 * math.pi * f * u)
                        + 0.35 * math.sin(2 * math.pi * 2 * f * u) * math.exp(-u * 3)
                        + 0.12 * math.sin(2 * math.pi * 3.01 * f * u) * math.exp(-u * 5))
        frames += struct.pack('<h', int(max(-1, min(1, s / 4)) * 30000))
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(bytes(frames))


# ---- alert sound ('snd ' 1, SysBeep): a two-tone chirp, 0.12 s (the space in the ROM) ---
def alert(path):
    rate, length = 22050, 0.12
    frames = bytearray()
    for i in range(int(rate * length)):
        t = i / rate
        f = 880.0 if t < 0.045 else 1174.66                  # A5, then D6
        ph = 2 * math.pi * f * t
        s = math.sin(ph) + math.sin(3 * ph) / 5 + math.sin(5 * ph) / 12     # soft square
        env = min(1.0, t / 0.002) * min(1.0, (length - t) / 0.015)
        frames += struct.pack('<h', int(s / 1.3 * env * 30000))
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(bytes(frames))


# ---- boot beep (0) and error beeps 1-4 ("the startup test failed"), for tools/beeps2s.py --
BEEPS = """# Boot beep (0) and error beeps 1-4, played by DOBEEP when the startup test fails.
# Format: see src/tools/beeps2s.py. Mode 0: voices start together, 1: one after another;
# delays between voice starts in 1/40 s; notes up to about F5.
# beep  mode  delays    notes
0       0     0 0 0     C5 E5 G4 -        # boot beep: C major chord
1       1     6 6 6     E5 C5 A4 E4       # falling A minor arpeggio
2       1     6 6 6     D4 A4 F4 C#5      # D minor with a raised seventh, broken
3       1     5 5 5     C4 Eb4 F#4 A4     # rising diminished chord
4       1     8 4 8     B4 G4 E4 C4       # falling C major seventh
"""


# ---- icons, 32x32: '#' black, '.' white (the mask is the filled outline) -----------------
happy = """
................................
................................
..############################..
.#############################..
.##..........................##.
.##..........................##.
.##..........................##.
.##..........................##.
.##........##......##........##.
.##........##......##........##.
.##..........................##.
.##..........................##.
.##..........................##.
.##.......#..........#.......##.
.##........#........#........##.
.##.........########.........##.
.##..........................##.
.##..........................##.
.##..........................##.
.##..........................##.
..############################..
...##########################...
.............#....#.............
.............#....#.............
.............#....#.............
.............#....#.............
..........############..........
.........#............#.........
.........##############.........
................................
................................
................................
"""
disk = """
................................
................................
...######################.......
...#....#..........#....##......
...#....#..........#....#.#.....
...#....#....###...#....#..#....
...#....#....###...#....#...#...
...#....#....###...#....#....#..
...#....#....###...#....#....#..
...#....#..........#....#....#..
...#.....##########.....#....#..
...#....................#....#..
...#.##################.#....#..
...#.#.................##....#..
...#.#.......................#..
...#.#.......................#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#.....................#.#..
...#.#######################.#..
...#.........................#..
...###########################..
................................
................................
"""
q = ["............###.............",
     "...........#####............",
     "..........##...##...........",
     "...............##...........",
     "..............##............",
     ".............##.............",
     ".............##.............",
     "............................",
     ".............##.............",
     ".............##............."]
x = ["..........##.....##.........",
     "...........##...##..........",
     "............##.##...........",
     ".............###............",
     "............##.##...........",
     "...........##...##..........",
     "..........##.....##........."]


# RAM chip, drawn on the disk's label for the RAM disk icon
chip = ["....#.#.#.#.#.#.....",
        "....#.#.#.#.#.#.....",
        "..##############....",
        "..#............#....",
        "..#.##.........#....",
        "..#.##.........#....",
        "..#............#....",
        "..##############....",
        "....#.#.#.#.#.#.....",
        "....#.#.#.#.#.#....."]


def grid(s):
    return [list(line) for line in s.strip('\n').split('\n')]


def blank(n=32):
    return [['.'] * n for _ in range(n)]


def overlay(base, art, top, left):
    g = [r[:] for r in base]
    for dy, line in enumerate(art):
        for dx, c in enumerate(line):
            if c == '#':
                g[top + dy][left + dx] = '#'
    return g


def box(g, x0, y0, x1, y1):
    for x in range(x0, x1 + 1):
        g[y0][x] = g[y1][x] = '#'
    for y in range(y0, y1 + 1):
        g[y][x0] = g[y][x1] = '#'


def line(g, x0, y0, x1, y1):
    for y in range(min(y0, y1), max(y0, y1) + 1):
        for x in range(min(x0, x1), max(x0, x1) + 1):
            g[y][x] = '#'


def arrow(g, x, y, direction, length=7):
    """Solid arrow whose point is at (x, y), pointing in direction."""
    dx, dy = {'down': (0, 1), 'up': (0, -1), 'left': (-1, 0), 'right': (1, 0)}[direction]
    for k in range(4):                          # head
        for s in range(-k, k + 1):
            px, py = x - dx * k + (s if dx == 0 else 0), y - dy * k + (s if dy == 0 else 0)
            g[py][px] = '#'
    for k in range(4, 4 + length):              # shaft, 2 pixels wide
        px, py = x - dx * k, y - dy * k
        g[py][px] = '#'
        g[py + (1 if dx else 0)][px + (1 if dy else 0)] = '#'


def drive_icon(direction):
    """A floppy drive and an arrow that shows where the drive is."""
    g = blank()
    if direction in ('down', 'up'):
        top = 17 if direction == 'down' else 6
        box(g, 3, top, 28, top + 8)             # drive
        line(g, 7, top + 3, 19, top + 3)        # slot
        line(g, 23, top + 5, 25, top + 6)       # light
        if direction == 'down':
            arrow(g, 13, top - 2, 'down')
        else:
            arrow(g, 13, top + 11, 'up')
    else:
        left = 4 if direction == 'left' else 15
        box(g, left, 3, left + 12, 28)          # tower
        line(g, left + 3, 8, left + 9, 8)       # slot
        line(g, left + 3, 23, left + 4, 24)     # light
        if direction == 'left':
            arrow(g, left + 14, 8, 'left')
        else:
            arrow(g, left - 2, 8, 'right')
    return g


# where the drive is, for each of the floppy driver's 17 drive icons (as in the originals)
DRIVES = ['down', 'up', 'up', 'right', 'down', 'down', 'down', 'down', 'down', 'down',
          'left', 'left', 'left', 'left', 'down', 'right', 'down']


# ---- cursors, 16x16: '#' black, '.' white, ' ' transparent, 'r' inverts the screen -------
CURSORS = {
    'ibeam': ((8, 7), """
                
    rrr  rrr    
       rr       
       rr       
       rr       
       rr       
       rr       
       rr       
       rr       
       rr       
       rr       
       rr       
       rr       
       rr       
    rrr  rrr    
                """),
    'cross': ((7, 7), """
       r        
       r        
       r        
       r        
       r        
                
rrrrr  r  rrrrr 
                
       r        
       r        
       r        
       r        
       r        
       r        
                
                """),
    'plus': ((8, 8), """
                
     ######     
     #....#     
     #....#     
     #....#     
######....######
#..............#
#......##......#
#......##......#
#..............#
######....######
     #....#     
     #....#     
     #....#     
     ######     
                """),
    'watch': ((8, 8), """
 ############## 
 #............# 
  #..........#  
  #.########.#  
   #.######.#   
    #.####.#    
     #.##.#     
      #..#      
      #..#      
     #....#     
    #......#    
   #...##...#   
  #..######..#  
  #.########.#  
 ############## 
                """),
    'arrow': ((1, 1), """
                
 #              
 ##             
 #.#            
 #..#           
 #...#          
 #....#         
 #.....#        
 #......#       
 #.......#      
 #....#####     
 #..#.#         
 #.# #.#        
 ##   #.#       
 #     ##       
                """),
}


def save(g, path):
    n = len(g)
    assert all(len(r) == n for r in g), path
    im = Image.new('L', (n, n), 255)
    for y, row in enumerate(g):
        for x, c in enumerate(row):
            if c == '#':
                im.putpixel((x, y), 0)
    im.save(path)


def save_cursor(art, hotspot, path):
    from PIL import PngImagePlugin
    rows = art.strip('\n').split('\n')
    assert len(rows) == 16 and all(len(r) == 16 for r in rows), path
    colours = {'#': (0, 0, 0, 255), '.': (255, 255, 255, 255), ' ': (255, 255, 255, 0),
               'r': (255, 0, 0, 255)}
    im = Image.new('RGBA', (16, 16))
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            im.putpixel((x, y), colours[c])
    info = PngImagePlugin.PngInfo()
    info.add_text('hotspot', '%d,%d' % hotspot)
    im.save(path, pnginfo=info)


# ---- fonts --------------------------------------------------------------------------------
sys.path.insert(0, os.path.join(HERE, '..', 'src', 'tools'))
TTF = '/usr/share/fonts/truetype/'
PCF = '/usr/share/fonts/misc/'

# special characters of the system font (Chicago 12), drawn here; 9x12 above the baseline
CHICAGO_SPECIAL = {
    0x11: """
.........
.........
.........
.##...##.
#..#.#..#
#..#.#..#
.#######.
...#.#...
.#######.
#..#.#..#
#..#.#..#
.##...##.""",                 # command key
    0x12: """
.........
.........
.........
.........
........#
.......##
......##.
.##..##..
..####...
...##....
.........
.........""",                 # check mark
    0x13: """
.........
.........
.........
.........
....#....
...###...
..#####..
.#######.
..#####..
...###...
....#....
.........""",                 # diamond
    0x10: """
.........
.........
..#####..
.#.....#.
#..###..#
#.#...#.#
#.#...#.#
#.#...#.#
#..###..#
.#.....#.
..#####..
.........""",                 # emblem, outlined (stands for the Apple logo)
    0x14: """
.........
.........
..#####..
.#######.
###...###
##.....##
##.....##
##.....##
###...###
.#######.
..#####..
.........""",                 # emblem, filled
}
MISSING = """
.......
#######
#.....#
#.....#
#.....#
#.....#
#.....#
#.....#
#######"""                     # glyph for characters a font lacks


def art_glyph(art, A, D, adv=None):
    rows = [[1 if c == '#' else 0 for c in line] for line in art.strip('\n').split('\n')]
    w = len(rows[0])
    full = [[0] * w for _ in range(A - len(rows))] + rows + [[0] * w for _ in range(D)]
    return (adv if adv is not None else w + 2, 1, full)


def ttf_glyphs(path, px, A, D, last, space_min):
    from PIL import ImageFont
    font = ImageFont.truetype(path, px)
    asc = font.getmetrics()[0]
    out = {}
    for c in range(0x20, last + 1):
        ch = bytes([c]).decode('mac_roman')
        if ch == '':
            continue                                    # Apple logo: not in free fonts
        mask, (ox, oy) = font.getmask2(ch, mode='1')
        w, h = mask.size
        rows = [[0] * w for _ in range(A + D)]
        for y in range(h):
            ty = oy + y - asc + A
            for x in range(w):
                if mask.getpixel((x, y)) and 0 <= ty < A + D:
                    rows[ty][x] = 1
        adv = round(font.getlength(ch, mode='1'))     # hinted advance
        if c == 0x20:
            adv = max(adv, space_min)
        out[c] = (adv, ox, rows)
    return out


def pcf_glyphs(path, A, D, last):
    from PIL import PcfFontFile
    with gzip.open(path) as f:
        pcf = PcfFontFile.PcfFontFile(f, 'mac_roman')
    out = {}
    for c in range(0x20, last + 1):
        g = pcf.glyph[c]
        if not g:
            continue
        (adv, _), (x0, top, x1, bottom), _, im = g      # top: -(rows above the baseline)
        w, h = x1 - x0, bottom - top
        rows = [[0] * w for _ in range(A + D)]
        for y in range(h):
            ty = A + top + y
            for x in range(w):
                if im.getpixel((x, y)) and 0 <= ty < A + D:
                    rows[ty][x] = 1
        out[c] = (adv, x0, rows)
    return out


MISSING_NARROW = """
#####
#...#
#...#
#...#
#...#
#...#
#####"""                       # the same for the monospaced font (6 pixels per character)


def add_controls(g, A, D, space, mono=False):
    blank = lambda adv: (adv, 0, [[] for _ in range(A + D)])
    g[0x00] = blank(0)
    g[0x09] = blank(space)
    g[0x0D] = blank(0)
    g['missing'] = art_glyph(MISSING_NARROW, A, D, 6) if mono else art_glyph(MISSING, A, D)


def fonts(out):
    import fonts2s
    os.makedirs(out, exist_ok=True)
    specs = {   # key: (glyph source, space advance at least)
        'chicago12': (lambda A, D, last: ttf_glyphs(TTF + 'DejaVuSans-Bold.ttf', 12, A, D, last, 4), 4),
        'geneva9': (lambda A, D, last: ttf_glyphs(TTF + 'DejaVuSans.ttf', 9, A, D, last, 3), 3),
        'geneva12': (lambda A, D, last: ttf_glyphs(TTF + 'DejaVuSans.ttf', 12, A, D, last, 4), 4),
        'monaco9': (lambda A, D, last: pcf_glyphs(PCF + '6x10.pcf.gz', A, D, last), 6),
    }
    for key, name, off, size, desc, (A, D, lead, first, last) in fonts2s.FONTS:
        source, space_min = specs[key]
        # Chicago has no glyphs for 0xD9-0xEF; keep that, so the font fits its space
        g = source(A, D, 0xD8 if key == 'chicago12' else last)
        add_controls(g, A, D, g[0x20][0], mono=(key == 'monaco9'))
        if key == 'chicago12':
            for c, art in CHICAGO_SPECIAL.items():
                g[c] = art_glyph(art, A, D, 11)
            g[0xF0] = g[0x14]
        if key == 'monaco9':
            g[ord('.')] = art_glyph('##\n##', A, D, 6)      # 6x10's period is a small plus
            g[ord('.')] = (6, 2, g[ord('.')][2])
        xs = [xo for adv, xo, rows in g.values()]
        h = {'ascent': A, 'descent': D, 'leading': lead, 'kernMax': min(0, min(xs)),
             'fRectWidth': max(xo + (len(rows[0]) if rows else 0) for adv, xo, rows in g.values())}
        with open(os.path.join(out, key + '.bdf'), 'w') as f:
            f.write(fonts2s.to_bdf(key, h, g))


# ---- hidden start-up picture (PICTUREDATA): the happy monitor and the project's name ---
def picture(happy_icon, path):
    """324 x 300 like the original, white on black (dark pixels are drawn black)."""
    from PIL import ImageDraw, ImageFont
    w, h = 324, 300
    im = Image.new('L', (w, h), 0)
    scale, top = 3, 28
    left = (w - 32 * scale) // 2
    for y, row in enumerate(happy_icon):
        for x, c in enumerate(row):
            if c == '#':
                im.paste(255, (left + x * scale, top + y * scale,
                               left + (x + 1) * scale, top + (y + 1) * scale))
    draw = ImageDraw.Draw(im)
    draw.fontmode = '1'                       # no anti-aliasing: one bit per pixel
    y = top + 32 * scale + 22
    for text, font, px, gap in (('q800rom', 'DejaVuSans-Bold.ttf', 30, 12),
                                ('Macintosh Quadra 800 ROM', 'DejaVuSans.ttf', 16, 4),
                                ('rebuilt from source', 'DejaVuSans.ttf', 16, 14),
                                ('github.com/escarneiro/q800rom', 'DejaVuSans.ttf', 13, 0)):
        f = ImageFont.truetype(TTF + font, px)
        x0, y0, x1, y1 = draw.textbbox((0, 0), text, font=f)
        draw.text(((w - (x1 - x0)) // 2 - x0, y - y0), text, font=f, fill=255)
        y += y1 - y0 + gap
    im.point(lambda v: 255 if v >= 128 else 0).save(path)


def main():
    chime(os.path.join(HERE, 'chime.wav'))
    alert(os.path.join(HERE, 'alert.wav'))
    with open(os.path.join(HERE, 'beeps.txt'), 'w') as f:
        f.write(BEEPS)
    icons = os.path.join(HERE, 'icons')
    for sub in ('boot', 'sony', 'edisk', 'atboot', 'cursors'):
        os.makedirs(os.path.join(icons, sub), exist_ok=True)
    d = grid(disk)
    h = grid(happy)
    save(h, os.path.join(icons, 'boot', 'happy.png'))
    save(d, os.path.join(icons, 'boot', 'disk.png'))
    save(overlay(d, q, 15, 2), os.path.join(icons, 'boot', 'diskq.png'))
    save(overlay(d, x, 17, 2), os.path.join(icons, 'boot', 'diskx.png'))
    save(d, os.path.join(icons, 'sony', 'media.png'))
    for i, direction in enumerate(DRIVES, 1):
        save(drive_icon(direction), os.path.join(icons, 'sony', 'drive%02d.png' % i))
    save(overlay(d, chip, 15, 6), os.path.join(icons, 'edisk', 'media.png'))
    # network boot: the monitor's face appears step by step
    eyes_only = [r[:] for r in h]
    for y in (13, 14, 15):
        eyes_only[y] = h[4][:]                  # an empty screen row
    empty = [r[:] for r in eyes_only]
    for y in (8, 9):
        empty[y] = h[4][:]
    save(empty, os.path.join(icons, 'atboot', 'frame1.png'))
    save(eyes_only, os.path.join(icons, 'atboot', 'frame2.png'))
    save(h, os.path.join(icons, 'atboot', 'frame3.png'))
    for name, (hotspot, art) in CURSORS.items():
        save_cursor(art, hotspot, os.path.join(icons, 'cursors', name + '.png'))
    fonts(os.path.join(HERE, 'fonts'))
    picture(h, os.path.join(HERE, 'picture.png'))


if __name__ == '__main__':
    main()
