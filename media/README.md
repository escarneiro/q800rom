# Free media

Original sound and icons made for this project, to use instead of Apple's copyrighted
ones. They contain no Apple material: the chime is synthesized and the icons are drawn as
text, both in `make_media.py`, which regenerates every file here.

| File | Replaces | Description |
|------|----------|-------------|
| `chime.wav` | the boot chime (`romsrc/sound/bootchime.s`) | rolled G major chord, bell-like, 2.2 s |
| `booticons/happy.png` | `BOOTICON_HAPPY` | monitor with a smile: startup disk found |
| `booticons/disk.png` | `BOOTICON_DISK` | floppy disk |
| `booticons/diskq.png` | `BOOTICON_DISKQ` | floppy with a question mark: no startup disk yet |
| `booticons/diskx.png` | `BOOTICON_DISKX` | floppy with an X: not a startup disk |

Build a ROM with all of them:

```bash
make -C src rom FREE_MEDIA=1
```

or pick single items with `CHIME=` and `BOOTICONS=` (see the main README). Edit
`make_media.py` and run `python3 media/make_media.py` to change them.
