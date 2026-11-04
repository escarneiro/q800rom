#!/usr/bin/env python3
"""export_fixups.py - what the hand-maintained romsrc/ knows that the generator does not.

Compares the hand-maintained source with freshly generated source (both rebuild the same
image) address by address and writes the differences as fix-ups, by ROM address only, for
tools/apply_fixups.py to apply after generating (tools/regen_romsrc.sh):

  data START END                 bytes the generator decoded as instructions that are data
                                 (or data lines to rewrite plainly before decoding them)
  keep START END                 data the decoder must not run into (from a second run:
                                 tools/export_fixups.py --keep, see below)
  code ADDR                      an instruction the generator left as raw data
  number ADDR SIZE               an item the generator wrote as a label expression that is
                                 a plain number
  reloc ADDR COUNT BASE STRIDE POS SIZE
                                 items that are label expressions (offset or address) where
                                 the generator wrote numbers; as tools/reloc_table.py takes
                                 them, BASE as an address: 0xADDR[+N], .[+N] (relative to
                                 the item) or abs (an absolute address)

Usage (from src/):  tools/export_fixups.py HAND_ROMSRC GENERATED_ROMSRC > ../analysis/romsrc_fixups.txt
"""
import bisect
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import romsrc_model as rm  # noqa: E402


def cover(recs):
    """sorted starts and records, for 'which line covers address a'"""
    recs = sorted(recs, key=lambda r: r['addr'])
    return [r['addr'] for r in recs], recs


def at(cv, a):
    keys, recs = cv
    k = bisect.bisect_right(keys, a) - 1
    if k >= 0 and recs[k]['addr'] <= a < recs[k]['addr'] + recs[k]['size']:
        return recs[k]
    return None


def base_text(ev_base, item, sym_by_addr=None):
    if ev_base == 'abs':
        return 'abs'
    if isinstance(ev_base, tuple):
        return '.' + ('+%d' % ev_base[1] if ev_base[1] else '')
    return '0x%08X' % ev_base


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    hand, _ = rm.model(sys.argv[1])
    gen, _ = rm.model(sys.argv[2])
    hc, gc = cover(hand), cover(gen)
    out = []

    # data the generator decoded as instructions: generated instruction lines with a byte
    # that the hand source has as data (or .ascii/.fill ...)
    ranges = []
    for g in gc[1]:
        if g['kind'] != 'insn':
            continue
        a, e = g['addr'], g['addr'] + g['size']
        x = a
        bad = False
        while x < e:
            h = at(hc, x)
            if h is None:
                x += 1
                continue
            if h['kind'] != 'insn':
                bad = True
                break
            x = h['addr'] + h['size']
        if not bad:                                # an instruction the hand source has
            h = at(hc, a)                          # starting elsewhere: misaligned
            bad = h is not None and h['kind'] == 'insn' and h['addr'] != a
        if bad:
            if ranges and ranges[-1][1] == a:
                ranges[-1][1] = e
            else:
                ranges.append([a, e])
    # data lines without an address note (instructions kept as words, with the
    # disassembly as a comment) that hold a hand instruction: rewritten first
    for h in hc[1]:
        if h['kind'] != 'insn':
            continue
        g = at(gc, h['addr'])
        if g is not None and g['kind'] == 'data' and not g['ann']:
            r = [g['addr'], g['addr'] + g['size']]
            if r not in ranges:
                ranges.append(r)
    ranges.sort()
    merged = []
    for a, e in ranges:
        if merged and a <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], e)
        else:
            merged.append([a, e])
    ranges = merged
    for a, e in ranges:
        out.append('data 0x%08X 0x%08X' % (a, e))
    # inside them, the bytes the hand source has as data: the decoder must stay out
    for a, e in ranges:
        x, run = a, None
        while x < e:
            h = at(hc, x)
            step = (h['addr'] + h['size'] - x) if h else 1
            isdata = h is None or h['kind'] in ('data', 'other')
            if isdata and run is None:
                run = x
            if not isdata and run is not None:
                out.append('keep 0x%08X 0x%08X' % (run, x))
                run = None
            x += step
        if run is not None:
            out.append('keep 0x%08X 0x%08X' % (run, e))
    in_range = lambda x: any(a <= x < e for a, e in ranges)  # noqa: E731

    # instructions the generator left as data (or that the data ranges above will turn
    # into data): every hand instruction start inside generated data
    for h in hc[1]:
        if h['kind'] != 'insn':
            continue
        g = at(gc, h['addr'])
        if g is not None and g['kind'] in ('trap', 'other'):
            continue
        if g is None or g['kind'] != 'insn' or in_range(h['addr']):
            if g is None or g['kind'] != 'insn' or g['addr'] != h['addr'] or in_range(h['addr']):
                out.append('code 0x%08X' % h['addr'])

    # label expressions
    gitems = {}
    for g in gc[1]:
        for ia, n, txt, ev in g['items']:
            gitems[ia] = (n, ev)
    hitems = {}
    for h in hc[1]:
        for ia, n, txt, ev in h['items']:
            hitems[ia] = (n, ev)
    for ia, (n, ev) in sorted(gitems.items()):
        if ia in hitems:
            continue
        h = at(hc, ia)
        if h is not None and h['kind'] == 'data':
            out.append('number 0x%08X %d' % (ia, n))
    todo = [(ia, n, ev) for ia, (n, ev) in sorted(hitems.items()) if gitems.get(ia) != (n, ev)]
    # group runs: same size and base kind, constant stride, same base address (or the same
    # relative base), and for absolute addresses / offsets alike
    k = 0
    while k < len(todo):
        ia, n, ev = todo[k]
        tgt, base = ev
        j = k + 1
        stride = None
        while j < len(todo):
            ja, jn, jev = todo[j]
            st = ja - todo[j - 1][0]
            if jn != n or jev[1] != base or st < n or st > 16 or (stride is not None and st != stride):
                break
            stride = st
            j += 1
        count = j - k
        stride = stride or n
        size_field = 4 if n == 4 else 2
        if n == 1:
            sys.stderr.write('byte item at %X not handled\n' % ia)
            k = j
            continue
        if n == 4 and stride != 4:                 # longs in records: one at a time
            for x in range(k, j):
                out.append('reloc 0x%08X 1 %s 4 0 4' % (todo[x][0], base_text(base, todo[x][0])))
        else:
            out.append('reloc 0x%08X %d %s %d 0 %d' % (ia, count, base_text(base, ia), stride, size_field))
        k = j
    print('# romsrc_fixups.txt - written by tools/export_fixups.py, applied by tools/apply_fixups.py')
    print('# (ROM addresses only; see tools/export_fixups.py for the format)')
    print('\n'.join(out))
    kinds = {}
    for l in out:
        kinds[l.split()[0]] = kinds.get(l.split()[0], 0) + 1
    sys.stderr.write('export_fixups: %s\n' % kinds)


if __name__ == '__main__':
    main()
