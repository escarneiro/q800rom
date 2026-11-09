# Macintosh Quadra 800 ROM source

Motorola 68040 assembly source for the **Macintosh Quadra 800 ROM**, and everything needed to build a bootable 1 MB ROM image from it with GNU binutils. The ROM's sounds, images and fonts are built from the free files in `media/`, and you can supply your own.

## Origin and copyright

The code in `src/romsrc/` derives from Apple's Macintosh Quadra 800 ROM, and Apple holds the copyright on it. No license from this project covers that code. This project is not affiliated with or endorsed by Apple. The files in `media/` are this project's own (see `media/README.md`).

---

## 1. System & ROM Architecture Overview

The Macintosh Quadra 800 (1993) is powered by a **Motorola 68040 CPU running at 33 MHz** with integrated FPU and MMU. The ROM image is exactly **1,048,576 bytes (1 Megabyte)**.

### Physical & Virtual Memory Map
* **RAM Base**: `0x00000000` (8 MB fixed interleaved RAM on motherboard, expandable to 136 MB)
* **ROM Base (`ROMBase`)**: `0x40800000` (ends at `0x408FFFFF`)
* **I/O Space Base**: `0x50F00000`. The addresses below are those in the ROM's decoder table for
  this machine family (`DJMEMCTABLE`, the djMEMC memory controller of the Quadra 610/650/800):
  * **VIA1**: `0x50F00000` (ADB, timers, VBL, real-time clock)
  * **VIA2**: `0x50F02000` (NuBus slot and SCSI interrupts)
  * **SONIC Ethernet (DP83932)**: `0x50F0A000`
  * **SCC (Z8530 serial)**: `0x50F0C020`
  * **SCSI (NCR 53C96)**: `0x50F10000`
  * **Sound chip**: `0x50F14000`
  * **Floppy controller (SWIM)**: `0x50F1E000`
  * **Built-in video**: `0xF9800000` (most likely the DAFB video controller)
* **NuBus slot space**: `$F9000000` - `$FEFFFFFF` (slots 9 to E; the built-in video uses
  slot 9's space)

The boot sequence is described in [docs/boot_sequence.md](docs/boot_sequence.md), and the build steps in [docs/build_process.md](docs/build_process.md).

---

## 2. Directory Layout

```
media/                     - Default sounds, icons, cursors, fonts and pictures
docs/                      - Notes on the ROM
src/
├── romsrc/                - 68040 assembly source of the ROM
├── tools/
│   ├── rom_postlink.py    - Post-link: packed trap table, NuBus offsets, checksums
│   ├── rom_checksum.py    - ROM checksum and byte-lane sums: calculator, verifier & patcher
│   ├── wav2snd.py         - WAV -> 'snd ' (boot chime and alert sound)
│   ├── beeps2s.py         - text -> boot and error beep table
│   ├── icons2s.py         - PNGs -> icons and cursors source
│   ├── fonts2s.py         - BDF -> bitmap 'FONT' source
│   ├── pict2s.py          - PNG -> the hidden start-up picture
│   └── picts2s.py         - PNGs -> the 'PICT' resources
└── Makefile               - Build system
```

---

## 3. Building the ROM

### Prerequisites
* **Motorola 68000 cross binutils**: GNU `as`, `ld`, `objcopy`, `nm`. The Makefile defaults to openSUSE's `m68k-suse-linux-*`; for another toolchain, set `M68K_AS`, `M68K_LD`, `M68K_NM` and `M68K_OBJCOPY` on the command line.
* **Python 3** with **Pillow** (`python3-pil`).
* **Optional**: `qemu-system-m68k`, to run the ROM.

### Build

```bash
make -C src rom
```

This assembles `src/romsrc/q800rom.s`, links it at `0x40800000`, re-encodes the packed trap table and the NuBus offsets from the linked addresses, stamps the byte-lane sums and the checksum, and writes **`build/QUADRA800_REBUILT.ROM`** (1,048,576 bytes). The build stops if any symbol is undefined.

### Run it

```bash
make -C src test-qemu
```

### Using other media

By default the build takes its media from `media/`. To use another directory laid out the same way:

```bash
make -C src rom MEDIA=/path/to/my/media
```

A relative path is taken from `src/`. A file or directory missing from it leaves that item as it is in `src/romsrc/`. Each item can also be given by itself:

| Option | Takes | Replaces |
|--------|-------|----------|
| `CHIME=file.wav` | PCM WAV, any rate, mono or stereo | boot chime (about 3.1 s fit; longer sounds are cut) |
| `ALERT=file.wav` | PCM WAV | `'snd '` 1, the alert sound (0.12 s) |
| `BEEPS=file` | text file | boot beep and the four error beeps |
| `ICONS=dir` | PNGs | icons and cursors |
| `FONTS=dir` | BDF files | bitmap fonts |
| `PICTURE=file.png` | PNG | the hidden start-up picture |
| `PICTS=dir` | PNGs named `<id>.png` | the `'PICT'` resources |

Every item keeps its size, so nothing else in the ROM moves.

#### Alert sound and beeps

`ALERT=` replaces the sound `SysBeep` plays when the System file has no sound with the number chosen in the Sound control panel.

`BEEPS=` replaces the boot beep and the error beeps played when the startup test fails. The ROM plays them by mixing up to four voices of a triangle wave. The text file gives, for each beep, the mode (voices together or one after another), the delays between the voices in 1/40 s, and four notes (`A4`, `C#5`, `440Hz`, or `-`; the highest is about F5). See `src/tools/beeps2s.py` and `media/beeps.txt`.

#### Icons and cursors

| Directory | Files | Size | What |
|-----------|-------|------|------|
| `boot/` | `happy`, `disk`, `diskq`, `diskx` | 32x32 | startup icons: disk found, disk, no startup disk yet, not a startup disk |
| `sony/` | `media`, `drive01` … `drive17` | 32x32 | floppy driver: the floppy disk, and the drive icon for each group of Mac models |
| `edisk/` | `media` | 32x32 | RAM disk |
| `atboot/` | `frame1` … `frame3` | 32x32 | network boot animation (one mask for all frames) |
| `cursors/` | `ibeam`, `cross`, `plus`, `watch`, `arrow` | 16x16 | the four `'CURS'` resources and QuickDraw's arrow |

Dark pixels are the image. The mask is the opaque area of a PNG with transparency, otherwise the image's outline filled in. Red pixels invert the screen behind them. A cursor's hotspot is the PNG text field `hotspot` (`x,y`).

#### Fonts

`chicago12.bdf` (`'FONT'` 12, the system font), `geneva9.bdf`, `geneva12.bdf` and `monaco9.bdf` (`'FONT'` 393, 396, 521). `ENCODING` is the Mac Roman character code, `DEFAULT_CHAR` the glyph for characters a font lacks, and `FONT_ASCENT` / `FONT_DESCENT` must stay as they are (12/3, 10/2, 12/3, 9/2). The glyph images must fit in the font's strike; `tools/fonts2s.py` reports when a font is too wide. Mac OS loads its own fonts from the System file, so these are only seen when the System does not provide a font of the same number.

#### Hidden picture

Early in start-up, when the System installs its patches (`INITOVERPATCH` in `romsrc/patches/overpatches.s`), holding Esc and then L, F and W for a second fades the screen to black, draws a picture in the middle with a double frame and waits for a click. `PICTURE=` sets it: dark pixels are drawn black, and the compressed picture must fit in 5,542 bytes (the tool says how much is over).

#### `'PICT'` resources

`PICTS=` takes `95.png` to `106.png` (SCSI Disk Mode: the drive, arrows, battery and SCSI ID digits) and `501.png`. Each must fit in its resource's space; the tool says how much is over.

### The source (`src/romsrc/`)

* Real instructions (MIT syntax, GNU as) with labels for every branch and PC-relative target. Trap handlers are `trap_GetResource`, `trap_InitGraf`, …; ROM resources are `rsrc_DRVR_4__Sony_open` and so on.
* Branches to labels are written as `jbra`/`jbsr`/`jbeq`…, so the assembler picks the size; where an explicit size is needed, it is kept.
* A-line trap calls are written as macros (`_GetResource`), defined in `romsrc/include/traps_gas.inc`.
* Data (resources, tables, padding) is written as `.long`/`.short`/`.ascii`/`.fill`. Unused space is zero filled (`romsrc/include/romfill.inc`).

#### Relocatable: code can grow and shrink

Addresses and offsets are written as label expressions: ROM pointers, jump tables, the ROM header, the resource map, the Universal ROM hardware tables, long-range relative calls and the Memory Manager vector tables. Two structures need arithmetic GNU as cannot do across relaxable code, so they are re-encoded after linking by `tools/rom_postlink.py`:

* the packed trap dispatch table (`romsrc/traptable.lst`),
* 24-bit self-relative offsets in the NuBus declaration data (`romsrc/relocs.lst`).

The post-link step also recomputes the header checksums (32-bit sum at `0x00` and the four byte-lane sums at `0x30`). When moved code puts a trap's routine too far away for its entry's encoding, the entry is promoted and the ROM is assembled and linked again. Everything from `0x408F0000` to the end of the ROM (declaration ROM, format block) stays at a fixed address; the padding before it absorbs size changes (about 3.9 KB).

### Modifying the ROM

Code can be inserted or grown anywhere and every reference follows. Whether the result still runs Mac OS is another question: Mac OS 8.1 patches this ROM by address, about 900 ROM addresses in all ([docs/macos81_rom_refs.md](docs/macos81_rom_refs.md), from `0x40800000` to `0x408EDCE6`). If one of them moves, the System's patch for it misbehaves. So there are two ways to change code:

* **Keeping Mac OS 8.1 compatibility:** nothing before `0x408EDCE6` may change size. Change code in place with the same size, or replace the first instructions of a routine by a jump to new code in `romsrc/patches/hooks.s`, in the free space before the fixed region at `0xF0000`.
* **Free changes** (other systems, or a ROM that no longer identifies itself as this one, so that Mac OS does not install its patches for it): insert code anywhere. Only the free space before `0xF0000` limits how much code can be added.

## 4. Testing the Built ROM

### A. QEMU

```bash
make -C src test-qemu
```

Or run QEMU directly:

```bash
qemu-system-m68k -M q800 -bios build/QUADRA800_REBUILT.ROM -m 64M
```

### B. Basilisk II

Not tested with this project. Basilisk II patches the ROM it loads, so a modified ROM may not work there. Set `rom /path/to/q800rom/build/QUADRA800_REBUILT.ROM` in `~/.basilisk_ii_prefs`.

### C. Real hardware

Not tested on real hardware. How to put the image on a machine depends on the board (ROM chips or a ROM SIMM socket); check your hardware before programming anything. The ROM's startup test checks the checksum at offset 0 on every boot; the build computes it.
