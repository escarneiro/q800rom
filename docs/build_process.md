# Macintosh Quadra 800 ROM Build Process

How the 68040 assembly source in `src/romsrc/` becomes a bootable 1,048,576-byte (1 MB) ROM image.

---

## 1. System & ROM Architecture Overview

The Macintosh Quadra 800 (1993) is powered by a **Motorola 68040 microprocessor running at 33 MHz** with integrated floating-point unit (FPU) and paged memory management unit (MMU).

* **ROM Capacity**: Exactly 1,048,576 bytes ($100000 = 1 Megabyte).
* **Base Memory Address (`ROMBase`)**: `0x40800000` (up to `0x408FFFFF`).
* **ROM Header**:
  * Offset `0x00000000`: 32-bit ROM checksum, also fetched as the initial Supervisor Stack Pointer at power-on. Its value depends on the ROM's contents.
  * Offset `0x00000004`: initial Program Counter (`0x0000002A`). The `jmp` there goes to `STARTBOOT` at offset `0x8C`, in the low copy of the ROM that appears at address 0 at power-on (`0x4080008C` is the same code at the ROM's real address).
  * Offsets `0x30`-`0x3F`: four byte-lane sums (one per ROM chip lane).

---

## 2. High-Level Pipeline Diagram

```
+-------------------------------------------------------------+
|                 1. MEDIA (make MEDIA=dir)                   |
|  - tools/*2s.py: sounds, images and fonts from media/ ->    |
|    source files in build/media/, used instead of romsrc/    |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|          2. ASSEMBLY & LINKING OF THE ROM SOURCE            |
|  - m68k-as (-m68040) romsrc/q800rom.s -> build/q800rom.o    |
|  - m68k-ld -Ttext=0x40800000 -> build/q800rom.elf           |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|          3. BINARY IMAGE, POST-LINK FIX-UPS & CHECKSUM      |
|  - objcopy -O binary -> build/QUADRA800_REBUILT.ROM         |
|  - tools/rom_postlink.py: packed trap table (traptable.lst),|
|    NuBus 24-bit offsets (relocs.lst), byte-lane sums (0x30) |
|    and 32-bit checksum (0x00)                               |
|  - tools/rom_checksum.py --verify                           |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|                     4. BOOTABLE ROM                         |
|  - build/QUADRA800_REBUILT.ROM                              |
+-------------------------------------------------------------+
```

---

## 3. Step 1: Media

Each media item is converted to the source file it replaces, in its own directory under `build/media/`. These directories are passed to the assembler with `-I` before `romsrc`, so a file there takes the place of the `romsrc/` file with the same path. An item with no input file leaves the `romsrc/` file in use.

| Option | Default | Tool | Writes (under `build/media/`) |
|--------|---------|------|-------------------------------|
| `CHIME=` | `media/chime.wav` | `tools/wav2snd.py` | `chime/sound/bootchime.s`, `.bin`: uncompressed 8-bit `'snd '` at 22254.5 Hz, padded to `CHIME_AREA` bytes |
| `ALERT=` | `media/alert.wav` | `tools/wav2snd.py` | `alert/sound/alertsound.s`, `.bin`: `'snd '` 1, `ALERT_AREA` (2762) bytes |
| `BEEPS=` | `media/beeps.txt` | `tools/beeps2s.py` | `beeps/sound/beeptable.s` |
| `ICONS=` | `media/icons` | `tools/icons2s.py` | `icons/boot/booticons.s`, `icons/rsrc/icons/*.s`, `icons/quickdraw/arrow.s` |
| `FONTS=` | `media/fonts` | `tools/fonts2s.py` | `fonts/rsrc/fonts/*.s` |
| `PICTURE=` | `media/picture.png` | `tools/pict2s.py` | `picture/misc/picturedata.s` |
| `PICTS=` | `media/picts` | `tools/picts2s.py` | `picts/rsrc/*_PICT_*.s` |

`MEDIA=dir` changes the directory the defaults come from. Every item keeps its size, so nothing else in the ROM moves.

---

## 4. Step 2: Assembling and Linking the ROM Source

```bash
/usr/m68k-suse-linux/bin/as -m68040 -I ../build/media/chime ... -I romsrc -I romsrc/include romsrc/q800rom.s -o ../build/q800rom.o
/usr/m68k-suse-linux/bin/ld -Ttext=0x40800000 -e 0x40800000 --no-warn-rwx-segments \
    -o ../build/q800rom.elf ../build/q800rom.o
```

Linking at `ROMBase` (`0x40800000`) makes every label resolve to its ROM address. The build stops if any symbol is undefined. Padding in front of the fixed region at `0x408F0000` (declaration ROM and format block) is written as `.org`, so the code before it can grow or shrink.

---

## 5. Step 3: Binary Image and Post-Link Fix-Ups (`tools/rom_postlink.py`)

```bash
/usr/bin/m68k-suse-linux-objcopy -O binary --only-section=.text ../build/q800rom.elf ../build/QUADRA800_REBUILT.ROM
python3 tools/rom_postlink.py ../build/q800rom.elf ../build/QUADRA800_REBUILT.ROM romsrc
```

Two ROM structures cannot be expressed as GNU `as` expressions across relaxable branches, so they are filled in after linking from the label addresses in the ELF (`nm`):

1. **Packed trap dispatch table** (header long at `0x22`, table at `0x408D3370`): re-encoded from `romsrc/traptable.lst`, one line per trap (`b`/`w`/`l` encoded entry with its target label, `u` unimplemented). If a moved routine no longer fits its entry's encoding, the entry is promoted (byte to word to long) in `traptable.lst` and in the source, and the script exits with status 3. The Makefile then assembles and links the ROM again.
2. **NuBus sResource entries**: 24-bit self-relative offsets from `romsrc/relocs.lst` (`s24 <loc> <target>`).

The same step then writes the checksums (see below).

---

## 6. Checksum Calculation & Validation (`tools/rom_checksum.py`)

During every boot, the ROM verifies its checksum in `STARTUPROMTEST`. If it does not match the header value, the ROM stops in its startup-failure path (an error sound, then the Test Manager) and the screen is never initialized. See [Checksum.md](Checksum.md).

### Checksum Algorithm
The checksum is the **32-bit sum of all 16-bit big-endian words** from byte offset `0x00000004` to the end of the ROM (`0x000FFFFE`):

$$\text{Checksum}_{32} = \left(\sum_{i=2}^{524287} \text{Word}_{16}[i]\right) \pmod{2^{32}}$$

Before it, the four **byte-lane sums** at `0x30`-`0x3F` are computed: for each lane `L` (0-3), the sum of all bytes at offsets `i` with `i mod 4 = L`, excluding `0x00`-`0x03` and `0x30`-`0x3F`.

In Python (`fix_checksums` in `tools/rom_checksum.py`, with the checksum loop written out):
```python
def fix_checksums(rom: bytearray) -> int:
    lanes = [0, 0, 0, 0]
    for i, b in enumerate(rom):
        lanes[i & 3] += b
    for i in list(range(0, 4)) + list(range(0x30, 0x40)):
        lanes[i & 3] -= rom[i]
    struct.pack_into(">4I", rom, 0x30, *[x & 0xFFFFFFFF for x in lanes])
    csum = 0
    for i in range(4, len(rom), 2):
        csum = (csum + ((rom[i] << 8) | rom[i + 1])) & 0xFFFFFFFF
    struct.pack_into(">I", rom, 0, csum)
    return csum
```
The resulting 32-bit integer is written in big-endian byte order at offset `0x00000000`. `tools/rom_checksum.py <rom> --verify` checks it.

---

## 7. Summary of Build Commands

```bash
# Build the ROM with the media in media/
make -C src rom       # or just: make -C src

# With another media directory
make -C src rom MEDIA=/path/to/my/media

# With one item replaced
make -C src rom CHIME=/path/to/chime.wav

# Run it in QEMU
make -C src test-qemu
# or directly:
qemu-system-m68k -M q800 -bios build/QUADRA800_REBUILT.ROM -m 64M
```
