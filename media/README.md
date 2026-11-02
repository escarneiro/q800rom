# Free media

Original sound, icons and cursors made for this project, to use instead of Apple's
copyrighted ones. They contain no Apple material: the chime is synthesized and the images
are drawn as text, all in `make_media.py`, which regenerates every file here.

| File | Replaces | Description |
|------|----------|-------------|
| `chime.wav` | the boot chime | rolled G major chord, bell-like, 2.2 s |
| `icons/boot/happy.png` | startup: disk found | monitor with a smile |
| `icons/boot/disk.png`, `diskq.png`, `diskx.png` | startup: disk, no startup disk, not a startup disk | floppy disk, with ? and with X |
| `icons/sony/media.png` | floppy driver media icon | floppy disk |
| `icons/sony/drive01.png` … `drive17.png` | floppy driver drive icons | a drive and an arrow, pointing the same way as in the original for that group of Macs |
| `icons/edisk/media.png` | RAM disk icon | floppy disk with a memory chip |
| `icons/atboot/frame1.png` … `frame3.png` | network boot animation | the monitor's face appearing |
| `icons/cursors/ibeam.png`, `cross.png` | 'CURS' 1, 2 | I-beam and crosshair (inverting) |
| `icons/cursors/plus.png`, `watch.png` | 'CURS' 3, 4 | thick plus, hourglass |
| `icons/cursors/arrow.png` | QuickDraw's arrow | arrow |

Build a ROM with all of them:

```bash
make -C src rom FREE_MEDIA=1
```

or pick some with `CHIME=` and `ICONS=` (see the main README). Edit `make_media.py` and
run `python3 media/make_media.py` to change them.
