# Free media

Sounds, icons, cursors and fonts made for this project, to use instead of Apple's
copyrighted ones. They contain no Apple material: the sounds are synthesized or composed here, the images are
drawn as text, and the fonts are rendered from free fonts, all in `make_media.py`, which
regenerates every file here.

| File | Replaces | Description |
|------|----------|-------------|
| `chime.wav` | the boot chime | rolled G major chord, bell-like, 2.2 s |
| `alert.wav` | 'snd ' 1, the alert sound (Apple's "Brass Horn") | two-tone chirp, A5 then D6, 0.12 s |
| `beeps.txt` | boot beep and error beeps 1-4 | own chords and arpeggios (C major; A minor falling; D minor with raised seventh; C diminished rising; C major seventh falling) |
| `icons/boot/happy.png` | startup: disk found | monitor with a smile |
| `icons/boot/disk.png`, `diskq.png`, `diskx.png` | startup: disk, no startup disk, not a startup disk | floppy disk, with ? and with X |
| `icons/sony/media.png` | floppy driver media icon | floppy disk |
| `icons/sony/drive01.png` … `drive17.png` | floppy driver drive icons | a drive and an arrow, pointing the same way as in the original for that group of Macs |
| `icons/edisk/media.png` | RAM disk icon | floppy disk with a memory chip |
| `icons/atboot/frame1.png` … `frame3.png` | network boot animation | the monitor's face appearing |
| `icons/cursors/ibeam.png`, `cross.png` | 'CURS' 1, 2 | I-beam and crosshair (inverting) |
| `icons/cursors/plus.png`, `watch.png` | 'CURS' 3, 4 | thick plus, hourglass |
| `icons/cursors/arrow.png` | QuickDraw's arrow | arrow |
| `fonts/chicago12.bdf` | 'FONT' 12, Chicago 12 (system font) | DejaVu Sans Bold, 12 pixels; menu symbols (command key, check mark, diamond) and an emblem in place of the Apple logo drawn in `make_media.py` |
| `fonts/geneva9.bdf` | 'FONT' 393, Geneva 9 | DejaVu Sans, 9 pixels |
| `fonts/geneva12.bdf` | 'FONT' 396, Geneva 12 | DejaVu Sans, 12 pixels |
| `fonts/monaco9.bdf` | 'FONT' 521, Monaco 9 | X11 misc-fixed 6x10 (public domain), with a square period |

The DejaVu-based fonts are bitmaps rendered from DejaVu Sans 2.37 (Bitstream Vera license
plus public domain changes; see `fonts/LICENSE-DejaVu.txt`). The misc-fixed font is public
domain. Regenerating the fonts needs those fonts installed (`/usr/share/fonts`).

Build a ROM with all of them:

```bash
make -C src rom FREE_MEDIA=1
```

or pick some with `CHIME=`, `ALERT=`, `BEEPS=`, `ICONS=` and `FONTS=` (see the main README).
Apple's originals, for comparison: `make -C src applemedia` (writes `../applemedia/`, not in git). Edit `make_media.py` and
run `python3 media/make_media.py` to change them.
