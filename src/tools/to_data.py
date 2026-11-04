#!/usr/bin/env python3
"""to_data.py - rewrite lines of a romsrc file as plain data (.long/.byte).

For data the generator decoded as instructions: the bytes stay the same, the misleading
instructions (and the branches between them, which made labels inside the data) go.
Labels in the range stay at their addresses with their comments; more can be added.
The image must not change.

Usage (from src/):  tools/to_data.py ROMSRC FILE.s FIRST_LINE LAST_LINE ROM [ADDR=NAME...]
  FIRST_LINE..LAST_LINE (1-based, inclusive) are replaced; ROM is the image the current
  source builds.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import name_addresses as na  # noqa: E402

ROM_BASE = 0x40800000


def main():
    if len(sys.argv) < 6:
        sys.exit(__doc__)
    root, rel, first, last, romf = sys.argv[1:6]
    first, last = int(first) - 1, int(last) - 1
    extra = {}
    for x in sys.argv[6:]:
        a, n = x.split('=')
        extra[int(a, 16)] = n
    rom = open(romf, 'rb').read()
    lines, _ = na.line_addresses(root)
    addr = {i: a for (r, i), a in lines.items() if r == rel}
    p = os.path.join(root, rel)
    L = open(p).read().split('\n')
    lo = addr[first]
    nxt = min(i for i in addr if i > last)
    hi = addr[nxt]
    labels = {}
    for i in range(first, last + 1):
        m = re.match(r'^(\w+):(.*)$', L[i])
        if m:
            labels.setdefault(addr[i], []).append(L[i].rstrip())
    for a, n in extra.items():
        assert lo <= a < hi, hex(a)
        labels.setdefault(a, []).append(n + ':')
    out, cur, start = [], bytearray(), lo

    def flush(end):
        nonlocal cur, start
        a = start
        while a < end:                      # .long rows of up to 4 longs, on 16-byte lines
            if a % 4 == 0 and end - a >= 4:
                n = min((end - a) // 4, (16 - a % 16) // 4) or 1
                vals = [int.from_bytes(rom[a - ROM_BASE + 4 * k:a - ROM_BASE + 4 * k + 4], 'big')
                        for k in range(n)]
                out.append('    .long   ' + ', '.join('0x%08X' % v for v in vals) + '\t| %08X' % a)
                a += 4 * n
            else:
                n = min(end - a, 4 - a % 4 if a % 4 else end - a, 16)
                out.append('    .byte   ' + ', '.join('0x%02X' % rom[a - ROM_BASE + k]
                                                    for k in range(n)) + '\t| %08X' % a)
                a += n
        start = end

    for a in sorted(labels):
        flush(a)
        out += labels[a]
    flush(hi)
    L[first:last + 1] = out
    open(p, 'w').write('\n'.join(L))
    print('%s: lines %d-%d -> %d data lines, 0x%X..0x%X, %d labels'
          % (rel, first + 1, last + 1, len(out), lo, hi, sum(len(v) for v in labels.values())))


if __name__ == '__main__':
    main()
