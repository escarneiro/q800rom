#!/usr/bin/env python3
"""make_media.py - generate the project's own boot chime and boot icons.

Everything here is original work made for this project (no Apple material): the chime is
synthesized, the icons are drawn below as text. Run it to regenerate the files:

  python3 media/make_media.py        writes media/chime.wav and media/icons/*/*.png

Build a ROM with them:  make -C src rom FREE_MEDIA=1
"""
import math
import os
import struct
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


def main():
    chime(os.path.join(HERE, 'chime.wav'))
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


if __name__ == '__main__':
    main()
