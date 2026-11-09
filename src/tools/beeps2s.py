#!/usr/bin/env python3
"""beeps2s.py - the boot beep and error beeps ("chimes of death") from a text file.

DOBEEP (sound/bootbeep.s) plays beep 0 (the old boot beep) and beeps 1-4 (ERRORBEEP1-4,
the startup test failed) by mixing up to four voices of a triangle wave. Each beep is
one line of the table in sound/beeptable.s:

  mode     0: all voices start together, 1: one after another
  delays   three times between the starts of voices 1-2, 2-3 and 3-4, in units of 1/40 s
  notes    four pitches: a note name (A4, C#5, Bb3), a frequency (440Hz), a raw table
           value (0xA145) or - for a silent voice. Range: up to 0xFFFF, about 695 Hz (F5).

Text file format, one beep per line (# at the start or after a space starts a comment):

  # beep  mode  delays     notes
  1       1     8 8 8      F4 A4 C5 -

Usage:
  beeps2s.py BEEPS.txt -o beeptable.s     table from a text file
"""
import argparse
import math
import re
import struct
import sys

ROM_TABLE = 0x45E48                 # DOBEEP's table: 5 offsets, then 5 entries of 16 bytes
RATE = 0x56EE8BA3 / 65536.0         # output sample rate of the beep player
WAVE = 32                           # samples per cycle of the triangle wave
NOTES = {'C': -9, 'D': -7, 'E': -5, 'F': -4, 'G': -2, 'A': 0, 'B': 2}


def value_of_hz(hz):
    return round(hz * WAVE * 65536 / RATE)


def hz_of_value(v):
    return v / 65536 * RATE / WAVE


def note_value(s):
    if s == '-':
        return 0
    if s.lower().startswith('0x'):
        v = int(s, 16)
    elif s.lower().endswith('hz'):
        v = value_of_hz(float(s[:-2]))
    else:
        m = re.fullmatch(r'([A-G])([#b]?)(-?\d)', s)
        if not m:
            sys.exit('bad note %r' % s)
        semis = NOTES[m.group(1)] + {'#': 1, 'b': -1, '': 0}[m.group(2)] + 12 * (int(m.group(3)) - 4)
        v = value_of_hz(440.0 * 2 ** (semis / 12))
    if not 0 <= v <= 0xFFFF:
        sys.exit('note %s out of range (value 0x%X, the highest is 0xFFFF, about 695 Hz)' % (s, v))
    return v


def note_name(v):
    if v == 0:
        return '-'
    semis = 12 * math.log2(hz_of_value(v) / 440.0)
    n = round(semis)
    name = ['A', 'Bb', 'B', 'C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab'][n % 12]
    octave = 4 + (n + 9) // 12
    return '%s%d%+d' % (name, octave, round((semis - n) * 100))      # cents off


def parse_text(path):
    beeps = {}
    for line in open(path):
        line = re.split(r'(?:^|\s)#', line)[0].split()     # '#' after a space: comment
        if not line:
            continue
        if len(line) != 9:
            sys.exit('%s: need 9 fields (beep mode d1 d2 d3 n1 n2 n3 n4): %s' % (path, ' '.join(line)))
        k = int(line[0])
        beeps[k] = [int(line[1])] + [int(x) for x in line[2:5]] + [note_value(x) for x in line[5:9]]
    if sorted(beeps) != [0, 1, 2, 3, 4]:
        sys.exit('%s: need beeps 0 to 4' % path)
    return [beeps[k] for k in range(5)]


def asm(beeps, source):
    out = ['| sound/beeptable.s - DOBEEP\'s table: the boot beep (0) and error beeps 1-4',
           '| Written by tools/beeps2s.py (%s). Each entry: mode (0: voices together, 1: one' % source,
           '| after another), three delays in 1/40 s, four pitches (16.16 steps through a 32-sample',
           '| triangle wave at 22254.5 Hz: 0x8000 is about 348 Hz; 0 is silent).',
           '', 'BEEPTABLE:']
    for k in range(5):
        out.append('    .short  BEEP%d-BEEPTABLE' % k)
    for k, b in enumerate(beeps):
        out.append('BEEP%d:  | %s' % (k, 'boot beep' if k == 0 else 'error beep %d' % k))
        out.append('    .short  %d, %d, %d, %d  | mode, delays' % tuple(b[:4]))
        out.append('    .short  ' + ', '.join('0x%04X' % v for v in b[4:]) + '  | ' +
                   ' '.join(note_name(v) for v in b[4:]))
    return '\n'.join(out) + '\n'


def text(beeps):
    out = ['# Boot beep (0) and error beeps 1-4: see src/tools/beeps2s.py for the format.',
           '# beep  mode  delays      notes']
    for k, b in enumerate(beeps):
        notes = ['0x%04X' % v if v else '-' for v in b[4:]]
        out.append('%-7d %-5d %-11s %s   # %s' % (k, b[0], '%d %d %d' % tuple(b[1:4]), ' '.join(notes),
                                                 ' '.join(note_name(v) for v in b[4:])))
    return '\n'.join(out) + '\n'


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('file', nargs='?', help='text file with the beeps')
    ap.add_argument('-o', dest='out', help='beeptable.s to write')
    ap.add_argument('--text', help='write the table as a text file')
    a = ap.parse_args()
    if a.file:
        beeps, source = parse_text(a.file), 'from %s' % a.file.replace('\\', '/').rsplit('/', 1)[-1]
    else:
        ap.error('give a text file')
    if a.out:
        open(a.out, 'w').write(asm(beeps, source))
    if a.text:
        open(a.text, 'w').write(text(beeps))


if __name__ == '__main__':
    main()
