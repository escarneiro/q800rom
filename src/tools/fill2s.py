#!/usr/bin/env python3
"""fill2s.py - the ROM's filler pattern (romsrc/include/romfill.inc).

Two kinds of filler, neither read by anything:
 - pattern: Apple's build tool filled the whole ROM image with a 152-byte block (team
   initials, a copyright notice and the build date) before placing code and data in it;
   it is left in unused places: a run of 11412 bytes at 0x408F0000 (before the
   declaration ROM data) and short pieces in alignment padding and unused resource name
   fields.
 - word: padding after the end of some code, filled with a repeated four-letter word
   ('Gary', 'YEAH', 'NEAT').
Each place is a macro FILL_<original address> in romfill.inc, called from the source
where the bytes were.

Usage:
  fill2s.py --rom ROM -o romfill.inc          the original bytes (finds the places)
  fill2s.py --romsrc romfill.inc -o OUT.inc   the same places, filled with Lorem Ipsum;
                                              the last block of the main run carries the
                                              project's address (--text to change it)

The replacement blocks are delimited: each starts with '<<' and ends with '>>':
  <<Lorem ipsum dolor sit amet, ... Ut enim ad minim veniam.>>     152 bytes, repeated
  <<q800rom: ... https://github.com/escarneiro/q800rom -------->>  the last one (164 bytes)
The short pieces of the pattern elsewhere are slices of the Lorem Ipsum block at the same
position in the 152-byte cycle as Apple's pattern (0x408F0000 is the start of a block).
Each word fill becomes whole Lorem Ipsum blocks and one shorter block for the rest, also
from '<<' to '>>'.
"""
import argparse
import re
import sys

ROM_BASE = 0x40800000
FILL_BASE = 0xF0000          # the main run; the pattern's phase is counted from here
PERIOD = 152
MAIN_RUN = (0xF0000, 0xF2C94)
MIN_RUN = 4                  # shorter matches are not taken (could be chance)
FILL_WORDS = (b'Gary', b'YEAH', b'NEAT')
MIN_WORDS = 3

# Every replacement block is delimited: it starts with '<<' and ends with '>>', so the
# blocks can be found (and replaced) in a ROM image: '<<Lorem ipsum ... veniam.>>' (152
# bytes, repeated), and the last block of the main run, '<<q800rom: ... ---->>'.
LOREM = ('<<Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor '
         'incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.>>')     # 152 bytes
TEXT = 'q800rom: Macintosh Quadra 800 ROM rebuilt from source - https://github.com/escarneiro/q800rom'


def lorem_block():
    b = LOREM.encode('ascii')
    assert len(b) == PERIOD
    return b


def find_sites(rom):
    pat = rom[FILL_BASE:FILL_BASE + PERIOD]
    sites, a = [], None
    for x in range(len(rom) + 1):
        ok = x < len(rom) and rom[x] == pat[(x - FILL_BASE) % PERIOD]
        if ok and a is None:
            a = x
        if not ok and a is not None:
            if x - a >= MIN_RUN:
                sites.append((a, x - a, 'pattern'))
            a = None
    x = 0
    while x < len(rom) - 4 * MIN_WORDS:
        w = rom[x:x + 4]
        if w in FILL_WORDS and rom[x:x + 4 * MIN_WORDS] == w * MIN_WORDS:
            n = 0
            while rom[x + 4 * n:x + 4 * n + 4] == w:
                n += 1
            sites.append((x, 4 * n, 'word ' + w.decode()))
            x += 4 * n
        else:
            x += 1
    return sorted(sites)


def emit(data):
    """Bytes -> .ascii/.byte lines (printable text as strings)."""
    out, i = [], 0
    while i < len(data):
        j = i
        while j < len(data) and 0x20 <= data[j] < 0x7F and data[j] not in b'"\\' and j - i < 64:
            j += 1
        if j - i >= 4:
            out.append('    .ascii  "%s"' % data[i:j].decode('ascii'))
            i = j
        else:
            k = i + 1
            while k < len(data) and k - i < 16 and not all(0x20 <= c < 0x7F and c not in b'"\\'
                                                            for c in data[k:k + 4]):
                k += 1
            out.append('    .byte   ' + ', '.join('0x%02X' % c for c in data[i:k]))
            i = k
    return out


def write(path, sites, data_of, source):
    out = ['| include/romfill.inc - filler bytes, one macro per place (tools/fill2s.py, %s)' % source,
           '| FILL_<address in the original ROM>: <length> bytes. Nothing reads them.', '']
    for a, n, kind in sites:
        out.append('.macro FILL_%08X  | %d bytes, %s' % (ROM_BASE + a, n, kind))
        out += emit(data_of(a, n, kind))
        out.append('.endm')
    open(path, 'w').write('\n'.join(out) + '\n')


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--rom', help='original ROM image')
    ap.add_argument('--romsrc', help='the existing romfill.inc (for the list of places)')
    ap.add_argument('--text', default=TEXT, help='text of the last block of the main run')
    ap.add_argument('-o', dest='out', required=True)
    a = ap.parse_args()
    if a.rom:
        rom = open(a.rom, 'rb').read()
        write(a.out, find_sites(rom), lambda x, n, kind: rom[x:x + n], 'from the original ROM')
    elif a.romsrc:
        sites = [(int(m.group(1), 16) - ROM_BASE, int(m.group(2)), m.group(3))
                 for m in re.finditer(r'^\.macro FILL_([0-9A-F]{8})\s+\|\s*(\d+) bytes, (pattern|word \w+)',
                                      open(a.romsrc).read(), re.M)]
        block = lorem_block()
        start, end = MAIN_RUN
        last = start + ((end - start) // PERIOD - 1) * PERIOD     # the last whole block, plus the rest
        text = b'<<' + a.text.encode('ascii') + b' '
        if len(text) + 2 > end - last:
            sys.exit('--text is longer than %d bytes' % (end - last - 5))
        tail = text + b'-' * (end - last - len(text) - 2) + b'>>'

        def data_of(x, n, kind):
            if kind.startswith('word'):
                out = block * (n // PERIOD)
                rest = n % PERIOD
                if rest:
                    out += b'<<' + block[2:rest - 2] + b'>>' if rest >= 4 else b'-' * rest
                return out
            out = bytearray()
            for y in range(x, x + n):
                out.append(tail[y - last] if last <= y < end else block[(y - FILL_BASE) % PERIOD])
            return bytes(out)
        write(a.out, sites, data_of, 'Lorem Ipsum')
    else:
        ap.error('give --rom or --romsrc')


if __name__ == '__main__':
    main()
