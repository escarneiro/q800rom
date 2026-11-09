| sound/beeptable.s - DOBEEP's table: the boot beep (0) and error beeps 1-4
| Written by tools/beeps2s.py (from beeps.txt). Each entry: mode (0: voices together, 1: one
| after another), three delays in 1/40 s, four pitches (16.16 steps through a 32-sample
| triangle wave at 22254.5 Hz: 0x8000 is about 348 Hz; 0 is silent).

BEEPTABLE:
    .short  BEEP0-BEEPTABLE
    .short  BEEP1-BEEPTABLE
    .short  BEEP2-BEEPTABLE
    .short  BEEP3-BEEPTABLE
    .short  BEEP4-BEEPTABLE
BEEP0:  | boot beep
    .short  0, 0, 0, 0  | mode, delays
    .short  0xC09C, 0xF2AD, 0x904C, 0x0000  | C5+0 E5+0 G4+0 -
BEEP1:  | error beep 1
    .short  1, 6, 6, 6  | mode, delays
    .short  0xF2AD, 0xC09C, 0xA1F7, 0x7956  | E5+0 C5+0 A4+0 E4+0
BEEP2:  | error beep 2
    .short  1, 6, 6, 6  | mode, delays
    .short  0x6C19, 0xA1F7, 0x808D, 0xCC10  | D4+0 A4+0 F4+0 C#5+0
BEEP3:  | error beep 3
    .short  1, 5, 5, 5  | mode, delays
    .short  0x604E, 0x7287, 0x8832, 0xA1F7  | C4+0 Eb4+0 F#4+0 A4+0
BEEP4:  | error beep 4
    .short  1, 8, 4, 8  | mode, delays
    .short  0xB5CD, 0x904C, 0x7956, 0x604E  | B4+0 G4+0 E4+0 C4+0
