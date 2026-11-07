# Macintosh Quadra 800 ROM Reverse Engineering & Reconstructed Source

This repository contains the tools to turn the **Macintosh Quadra 800 ROM** (`QUADRA800.ROM`) into Motorola 68040 assembly source and to build the ROM from it again, byte for byte, plus original replacements for Apple's sounds, icons, cursors and fonts. The source itself is generated from your own ROM image and is not in the repository (it contains Apple's code). The analysis uses REA, Ghidra, Apple's MPW ROM map for this ROM and Apple's published technical documentation.

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

---

## 2. Boot & Initialization Sequence

1. **Hardware Power-On Reset**:
   * At power-on the ROM also appears at address `0x00000000` (overlay). The 68040 fetches the
     initial SSP from `0x00000000` (`0xF1ACAD13`, which is also the ROM checksum) and the initial
     PC from `0x00000004` (`0x0000002A`).
   * The instruction at `0x0000002A` (`jmp %pc@(0x60)`) jumps to `0x0000008C`, `STARTBOOT`,
     still in the low copy of the ROM; the code moves to the ROM's real addresses later
     (`JUMPINTOROM`, step 3).

2. **CPU Setup (`STARTBOOT`, `0x4080008C`, and `early_cpu_detect`, `0x40804052`)**:
   * `STARTBOOT` puts the CPU in supervisor mode with interrupts masked (`move.w #$2700, %sr`)
     and calls `early_cpu_detect`, which:
     * sets bit 31 of `CACR` and reads it back, to tell a 68040 from a 68030;
     * on a 68040, invalidates the caches (`cinva bc`), clears `CACR` (caches off) and `TC`
       (MMU off), and sets the transparent translation registers: `DTT0` = `0x807FC040`
       ($80000000-$FFFFFFFF, non-cacheable, serialized) and `DTT1` = `0x500FC040`
       ($50000000-$5FFFFFFF, the I/O space).
   * Back in `STARTBOOT`, the `reset` instruction resets the external devices.

3. **Into the ROM (`JUMPINTOROM`, `0x40802E00`)**:
   * Sets a temporary stack pointer (`%sp = $2600`) and makes `GOTBUSERROR` the bus error
     handler (`BusErrorVector`, used while probing the hardware). Next to it, the 228 bytes after
     a small table at `0x40803D00` are padding filled with the word `'Gary'` (`0x47617279`), see
     "The filler" below.

4. **Hardware Identification & RAM Sizing**:
   * Identifies the machine with the Universal ROM's decoder and product tables (the list at
     `0x4080322C` starts with `UNKNOWNDECODERTABLE`). The Quadra 800 is box flag 35 (`0x23`).
   * The ROM overlay is turned off, so that RAM appears at address `0x00000000` (where exactly
     in the code has not been traced).
   * Sizes the RAM banks and sets up the memory controller.

5. **Low-Memory Globals & Exception Vectors**:
   * Sets `CPUFlag` ($012F) = `4` (Motorola 68040) and `BoxFlag` ($0CB3) = the machine's box
     flag (35 for the Quadra 800).
   * Sets `MemTop` ($0108) = top of detected RAM and `BufPtr` ($010C) = bottom of the
     video/sound buffers.
   * Sets `ROMBase` ($02AE) = `0x40800000`.
   * Sets `SysZone` ($02A6) and `ApplZone` ($02AA).

6. **Trap Dispatcher Installation & Unpacking (`0x40809A96`)**:
   * Installs `trap_dispatcher` (`0x408099B0`) at Vector 10 (`$0028`, Line 1010 Emulator).
   * Reads relative table offset at ROM header byte 34 (`$0022` -> `$000D3370`).
   * Unpacks 1,024 Toolbox Traps into `ToolboxTable` ($0E00).
   * Unpacks 256 OS Traps into `OSTable` ($0400).

7. **Subsystem Launch**:
   * Calls `_SwapMMUMode` (`$A05D`) to enter 32-bit addressing mode.
   * Initializes Color QuickDraw (`_InitGraf` at `0x40831530`), cursor, fonts, windows, menus, and Dialog Manager.
   * Traverses NuBus Declaration ROM and mounts ROM Resource Map (`ROMMapHndl` at `$0B06`).
   * Looks for a startup disk (SCSI, floppy) and reads its boot blocks, which load the System.

---

## 3. Directory Layout

```
media/                     - Original sounds, icons, cursors, fonts and picture (make FREE_MEDIA=1)
applemedia/                - Apple's media from your ROM, for reference (not in git; make applemedia)
src/
├── romsrc/                - Generated 68040 assembly source of the ROM (not in git; make romsrc-regen)
├── traps/
│   └── trap_table.c       - Table of all 1,024 Toolbox and 256 OS traps: names and handler addresses
│                            (read by tools/rom_disasm.py and tools/rom_seeds.py for the trap names)
├── tools/
│   ├── regen_romsrc.sh    - Regenerates romsrc/ from an original ROM (romsrc-regen / romsrc-reanalyze)
│   ├── rom_disasm.py      - ROM -> labelled, byte-exact GNU as source
│   ├── rom_reloc.py       - Turns hard-coded addresses and offsets into label expressions
│   ├── rom_seeds.py       - Code entry points and names from traces and ROM tables (for Ghidra)
│   ├── rom_postlink.py    - Post-link: packed trap table, NuBus offsets, checksums
│   ├── rom_checksum.py    - ROM checksum and byte-lane sums: calculator, verifier & patcher
│   ├── qemu_boot_test.py  - Headless QEMU boot test
│   ├── shift_test.py      - Relocatability test (moves code, rebuilds, boots, compares traces)
│   ├── wav2snd.py         - WAV -> uncompressed 'snd ' (boot chime and alert sound, make CHIME= / ALERT=)
│   ├── beeps2s.py         - text -> boot/error beep table (replacement, make BEEPS=)
│   ├── icons2s.py         - PNGs -> icons and cursors source (replacement, make ICONS=)
│   ├── fonts2s.py         - BDF <-> bitmap 'FONT' source (replacement, make FONTS=)
│   ├── fill2s.py          - the filler in unused places (Apple's or Lorem Ipsum, make FILLER=1)
│   ├── pict2s.py          - PNG <-> the hidden start-up picture (replacement, make PICTURE=)
│   ├── extract_applemedia.py - Apple's media from an original ROM -> applemedia/ (make applemedia)
│   ├── declrom_names.py   - Names for the declaration ROM (sResources, drivers, video modes)
│   ├── context_names.py   - Names for remaining sub_/loc_/dat_ labels from their context
│   ├── name_addresses.py  - Give a name to any ROM address in romsrc/ (adds or renames the label)
│   ├── rename_labels.py   - Apply a rename map to romsrc/
│   ├── disasm_raw.py      - Turn code that is still raw data in romsrc/ into instructions
│   └── ghidra/            - Ghidra headless scripts (Q800Seed, Q800ATraps, Q800Export)
└── Makefile               - Build system (ROM generation, source regeneration, tests)
```

---

## 4. Building the ROM

The whole ROM exists as 68040 assembly source in `src/romsrc/`, produced by
disassembling the original and checked to rebuild it **byte for byte**. `src/romsrc/` is
not in the repository: on a fresh clone, generate it once from your own ROM image (see
"Regenerating `romsrc/`" below). After that the build does not need the ROM image.

### Prerequisites
* **Motorola 68000 cross binutils**: GNU `as`, `ld`, `objcopy`, `nm`, `objdump` (`m68k-suse-linux-*`).
* **Python 3**: ROM packaging, checksum, tests.
* **Optional**: `qemu-system-m68k` (boot tests); Ghidra `analyzeHeadless` (only to regenerate `romsrc/`).

### 1. Build the 1MB ROM

```bash
make -C src rom
```

1. Assembles `src/romsrc/q800rom.s`, which includes the source files in ROM order, and links
   it at `0x40800000` (`build/q800rom.elf`). The generator writes 16 files, `part_00.s` …
   `part_0F.s` (64 KB of ROM each); a hand-maintained copy can split them further, e.g. into
   `boot/`, `os/`, `toolbox/`, … and one file per ROM resource. The build stops if any symbol
   is undefined.
2. Writes the binary image, re-encodes the packed trap table and the NuBus offsets from the
   linked addresses, stamps the byte-lane sums and the checksum (`tools/rom_postlink.py`) and
   writes **`build/QUADRA800_REBUILT.ROM`** (bootable, currently identical to the original
   ROM, checksum `0xF1ACAD13`; checked against `romsrc/q800rom.sha256`). When moved code
   puts a trap's routine too far away for its entry's encoding (byte, word or long form),
   the entry is promoted in `romsrc/traptable.lst` and `romsrc/os/disptable.s` and the ROM
   is assembled and linked again; an unmodified source never needs this. Code inserted
   anywhere moves everything up to the fixed region at `0xF0000`, and only about 3.9 KB
   are free before it.

### 2. Test it

```bash
make -C src test-boot    # headless QEMU: must reach the grey desktop with the cursor
make -C src test-shift   # relocatability: move code, rebuild, boot (SHIFT_AT=, SHIFT_BYTES=)
make -C src test-qemu    # interactive QEMU window
```

`build/QUADRA800_REBUILT.ROM` boots QEMU's q800 machine to the desktop and boots
Mac OS 8.1 to the Finder.

#### Your own boot chime

```bash
make -C src rom CHIME=/path/to/chime.wav
```

The boot chime is taken from the WAV file instead of Apple's sound
(`romsrc/sound/bootchime.s`). `tools/wav2snd.py` mixes it to mono, resamples it to
22254.5 Hz and writes an uncompressed 8-bit `'snd '`, which the ROM's boot-beep code plays
on every sound chip. The sound is padded to the size of the original sound area
(`CHIME_AREA`), so nothing else in the ROM moves; about 3.1 s fit, longer sounds are cut
with a short fade-out. Any PCM WAV works (8/16/24/32-bit, mono or stereo, any rate).
Build again without `CHIME=` to go back to the original sound.

#### Your own alert sound and error beeps

```bash
make -C src rom ALERT=/path/to/alert.wav BEEPS=/path/to/beeps.txt
```

`ALERT=` replaces `'snd '` 1 (Apple's "Brass Horn"), the alert sound `SysBeep` plays when
the System file has no sound with the number chosen in the Sound control panel. It is
converted like the chime, into the same space: 2720 samples, 0.12 s.

`BEEPS=` replaces the boot beep and the four error beeps ("chimes of death", played when
the startup test fails). The ROM plays them by mixing up to four voices of a triangle wave;
the text file gives, for each beep, the mode (voices together or one after another), the
delays between the voices in 1/40 s, and four notes (`A4`, `C#5`, `440Hz`, or `-`; the
highest is about F5). See `src/tools/beeps2s.py` and `media/beeps.txt`.

#### Your own icons and cursors

```bash
make -C src rom ICONS=/path/to/icons
```

The ROM's icons and cursors are taken from PNG files in that directory instead of Apple's;
any image without a PNG keeps the original. Get the originals as a starting point with
`python3 src/tools/icons2s.py --romsrc src/romsrc --png DIR`.

| Directory | Files | Size | What |
|-----------|-------|------|------|
| `boot/` | `happy`, `disk`, `diskq`, `diskx` | 32x32 | startup icons: disk found, disk, no startup disk yet, not a startup disk |
| `sony/` | `media`, `drive01` … `drive17` | 32x32 | floppy driver: the floppy disk, and the drive icon for each group of Mac models |
| `edisk/` | `media` | 32x32 | RAM disk |
| `atboot/` | `frame1` … `frame3` | 32x32 | network boot animation (one mask for all frames) |
| `cursors/` | `ibeam`, `cross`, `plus`, `watch`, `arrow` | 16x16 | the four `'CURS'` resources and QuickDraw's arrow |

Dark pixels are the image. The mask is the opaque area of a PNG with transparency,
otherwise the image's outline filled in. Red pixels invert the screen behind them (the
I-beam and the crosshair work that way). A cursor's hotspot is the PNG text field
`hotspot` (`x,y`). The sizes never change, so nothing else in the ROM moves.
`CHIME=` and `ICONS=` can be combined.

#### Your own fonts

```bash
make -C src rom FONTS=/path/to/fonts
```

The ROM's four bitmap fonts are taken from BDF files in that directory: `chicago12.bdf`
(`'FONT'` 12, the system font), `geneva9.bdf`, `geneva12.bdf` and `monaco9.bdf`
(`'FONT'` 393, 396, 521); a missing file keeps the original. `ENCODING` is the Mac Roman
character code, `DEFAULT_CHAR` the glyph for characters a font lacks, and `FONT_ASCENT` /
`FONT_DESCENT` must stay as they are (12/3, 10/2, 12/3, 9/2). Each font keeps its exact
size, so nothing else in the ROM moves: the glyph images must fit in the original strike
(`tools/fonts2s.py` drops the optional image height table to make room when needed and
reports when a font is too wide). `python3 src/tools/fonts2s.py --rom QUADRA800.ROM --bdf DIR`
writes the original fonts as BDF, and `fonts2s.py DIR --preview sample.png` shows a sample.

Mac OS loads its own fonts from the System file, so these are only seen when the System
does not provide a font of the same number.

#### Your own hidden picture

```bash
make -C src rom PICTURE=/path/to/picture.png
```

The ROM hides a picture: early in start-up, when the System installs its patches
(`INITOVERPATCH` in `romsrc/patches/overpatches.s`), holding Esc and then L, F and W for a
second fades the screen to black, draws the picture in the middle with a double frame and
waits for a click. Apple's is the names of the ROM team, 324 x 300 pixels, white on black.
`PICTURE=` puts a PNG there instead (`tools/pict2s.py`): dark pixels are drawn black, the
screen around it is black, and it is stored as a compressed `'PICT'` that must fit in the
original 5,542 bytes (the tool says how much is over; large areas of one colour compress
best), so nothing else in the ROM moves. `python3 src/tools/pict2s.py --rom QUADRA800.ROM
--png FILE` writes the original as PNG.

#### The filler

Apple's build tool filled the whole ROM image with a 152-byte block (the ROM team's
initials, `(c) Copyright Apple Computer, Inc. 1989-1992` and the build date, `Mon, Oct 21,
1991`) before placing code and data. Nothing reads it; it is left in 88 unused places: a
run of 11,412 bytes before the declaration ROM data at `0x408F0000`, alignment padding and
unused resource name fields. Six more areas after the end of some code are padded with a
repeated word, `Gary`, `YEAH` or `NEAT` (20 to 2,816 bytes), and one, after the Sound
Manager's empty interrupt routines, with 23 copies of the Pascal string `"  Life Is Good  "`
(391 bytes). All of them are macros in `romsrc/include/romfill.inc`.

```bash
make -C src rom FILLER=1
```

fills them with Lorem Ipsum instead, in delimited blocks that are easy to find and
replace later: every block starts with `<<` and ends with `>>`. The long run becomes 74
copies of `<<Lorem ipsum dolor sit amet, ... Ut enim ad minim veniam.>>` (152 bytes) and
a last block `<<q800rom: ... https://github.com/escarneiro/q800rom ---->>` (164 bytes);
the short pieces elsewhere are slices of the Lorem Ipsum block, and each word or string
fill becomes whole Lorem Ipsum blocks plus one shorter `<<Lorem ipsum ...>>` block.

#### The project's own media

`media/` holds an original chime, alert sound and error beeps, original icons and
cursors, fonts made from free fonts and a hidden picture, for all of the above (no Apple
material; see
`media/README.md`). `FREE_MEDIA=1` also sets `FILLER=1`. Build with all of them:

```bash
make -C src rom FREE_MEDIA=1
```

### 3. The disassembled source (`src/romsrc/`)

* Real instructions (MIT syntax, GNU as) with labels for every branch and PC-relative
  target: `trap_GetResource`, `trap_InitGraf`, … for trap handlers (named from the live
  trap tables), `rsrc_DRVR_4__Sony_open` etc. for ROM resources; in the generated source,
  `sub_XXXXXXXX` for other functions and `loc_`/`dat_` for branch and data targets (the
  hex number is the address in the original ROM; it does not change when code moves).
* The declaration ROM is named as part of generating (`declrom_names.py`, applied with
  `rename_labels.py`): the sResource directories and pools, every sResource after its own
  name, drivers, video modes, and the extended format header below the format block
  (`DECL_SUPERINIT`, whose code picks the sResource directory for the machine,
  `DECL_EXT_HEADER`, `DECL_DIRECTORIES`, `DECL_FORMAT_BLOCK`), with all their 24-bit offsets
  relocated.
* Separate tools, run by hand afterwards, name more of the source: `name_addresses.py` (any address, e.g. dispatch-table
  handlers named from documented `csCode`s and selectors), `context_names.py` (the
  remaining `sub_`/`loc_`/`dat_` labels, after the routine or resource that contains them),
  all applied with `rename_labels.py`; and `disasm_raw.py` turns code that the generator
  left as data into instructions. Each change is checked by rebuilding the ROM byte for
  byte.
* Apple's own names from the MPW 3.5 ROM map for this ROM (`analysis/Quadra800ROM.lst`,
  2,672 labels such as `GETRESOURCE`, `SETPORT`, `WAITFORINTNOTIME`) are used wherever
  they apply: 1,099 `sub_`/`loc_`/`dat_` names are replaced by them, 1,148 are added as
  aliases next to existing names (`trap_NewHandle:` + `NWHANDLE:`), and 425 label
  addresses that had no label before.
* Branches to labels are written as `jbra`/`jbsr`/`jbeq`…, so the assembler picks the
  size; where Apple's assembler used a longer form than needed, the explicit size is kept.
* A-line trap calls are written as macros (`_GetResource`), defined in `romsrc/include/traps_gas.inc`.
* Data (resources, fonts, sounds, tables, padding) is written as `.long`/`.short`/`.ascii`/`.fill`.
* About 1% of instructions (mostly Apple's `jsr ([vector])` memory-indirect form, which uses an
  encoding GNU as cannot produce) are written as raw `.short` words with the disassembly as a comment.

#### Relocatable: code can grow and shrink

Hard-coded addresses and offsets are written as label expressions (`tools/rom_reloc.py`,
about 4,800 of them, plus some 26,000 branches the assembler now sizes itself): ROM pointers, jump tables, the ROM header, the resource map, the
Universal ROM hardware tables (ProductInfo records, machine list, primitives tables),
long-range relative calls (`lea (target-here):l,%a0; jmp %pc@(here,%a0:l)`), the
Memory Manager vector tables and other ROMBase-relative offset tables. Two structures need
arithmetic GNU as cannot do across relaxable code; they are written with their original
bytes and re-encoded after linking by `tools/rom_postlink.py`:

* the packed trap dispatch table (`romsrc/traptable.lst`),
* 24-bit self-relative offsets in the NuBus declaration data (`romsrc/relocs.lst`).

The post-link step also recomputes the header checksums (32-bit sum at `0x00` and the
four byte-lane sums at `0x30`). Everything from `0x408F0000` to the end of the ROM
(declaration ROM, format block) stays at a fixed address; the padding before it absorbs
size changes (up to `0xF42` bytes of growth).

Tested with `make -C src test-shift` (`tools/shift_test.py`): bytes are inserted in front
of a function, filled with `ILLEGAL` instructions so that any stale reference traps, and
the rebuilt ROM is booted headless in QEMU. With `--trace`, original and shifted ROM are
run with deterministic timing and the first point where execution differs is reported.
Results:

* Inserting 2, 6, 0x10, 0x40, 0x82, 0x400 or 0xF00 bytes at points from `0x40801000` to
  `0x408E0000` (moving up to the whole ROM below `0x408F0000`): boots to the desktop.
* Mac OS 8.1 boots normally with the change at `0x40860000`, `0x40880000` or `0x408E0000`
  (the points tested in that range). Earlier failures with lower points were relocation gaps
  (hard-coded offsets in driver headers and the startup test tables, now handled by
  `tools/rom_reloc.py`), not fixed addresses in the System file. Mac OS still fails to start
  with insertions at `0x40801050`, `0x4082002E` and `0x40840CD4`; the cause is not found yet
  (the first difference in execution is in reading the startup disk's boot blocks).

#### Apple's media, for reference

```bash
make -C src applemedia ORIG_ROM=/path/to/QUADRA800.ROM
```

writes Apple's sounds (`'snd '` and WAV), boot/error beep table, icons and cursors (PNG),
fonts (BDF), pictures (PNG, with the hidden picture as `pictures/hidden.png`) and the
data of every ROM resource into `applemedia/`, next to
`media/`. It is Apple's copyrighted material, so `applemedia/` is in `.gitignore`.

### 4. Regenerating `romsrc/` (needs an original ROM)

`src/romsrc/` is not in git. On a fresh clone, generate it from your own ROM:

```bash
make -C src romsrc-regen ORIG_ROM=/path/to/QUADRA800.ROM
make -C src rom
```

This uses the analysis committed in `analysis/` and is deterministic: it produces exactly
the tested source (it does not need Ghidra; it takes about 3 minutes).

To improve the disassembly (new QEMU traces, more code coverage), re-run the full analysis:

```bash
make -C src romsrc-reanalyze ORIG_ROM=/path/to/QUADRA800.ROM
```

`tools/regen_romsrc.sh --reanalyze` runs: `tools/rom_seeds.py` (entry points from the QEMU
evidence in `analysis/`, the ROM resource list, verified symbols and code found in ROM
tables by the previous run) → Ghidra headless analysis (`tools/ghidra/Q800Seed.java`,
`Q800ATraps.java`, `Q800Export.java`) → `tools/rom_disasm.py` + `tools/rom_reloc.py`
(source generation, symbolization and per-instruction verification) → `tools/declrom_names.py`
(declaration ROM names, checked to leave the image unchanged) → `tools/apply_fixups.py`
(`analysis/romsrc_fixups.txt`: what the hand-maintained source knows and the generator does
not, by ROM address: data decoded as instructions, code left as data, offset tables and
pointers written as numbers, numbers taken for label differences; also checked to leave
the image unchanged). After changing the hand-maintained source, refresh the fix-ups with
`tools/export_fixups.py HAND_ROMSRC GENERATED_ROMSRC` (generated without the fix-ups).
A new code map
changes the generated source, so run `make -C src test-shift` with several `SHIFT_AT`
values before committing the updated `analysis/` files. See `analysis/README.md`.

`src/romsrc/` is listed in `.gitignore` because it contains Apple's ROM content.

---

### 5. Modifying the ROM

The source is relocatable: code can be inserted or grown anywhere and every reference
follows (checked with `make test-shift`, `tools/shift_sweep.sh`). Whether the result still
runs Mac OS is another question: Mac OS 8.1 patches this ROM by address. It jumps into the
middle of ROM routines and recognises callers by their return addresses, about 900 ROM
addresses in all (`analysis/macos81_rom_refs.txt`, from 0x40800000 to 0x408EDCE6). If one of
them moves, the System's patch for it misbehaves. So there are two ways to change code:

* **Keeping Mac OS 8.1 compatibility:** nothing before 0x408EDCE6 may change size. Change
  code in place with the same size, or hook a routine: `tools/add_hook.py LABEL HOOK
  [--after]` replaces the first instructions at LABEL by a jump to HOOK (the same number
  of bytes) and moves them to `romsrc/patches/hooks.s`, in the free space before the fixed
  region at 0xF0000 (about 3.9 KB), where the new code goes (before the routine, or with
  `--after` after it). `make rom` then reports whether every address Mac OS uses is still
  in place and unchanged (`tools/macos_compat.py`). A worked example (a bar painted on the
  start-up screen) is the `demo-startup-bar` branch of the hand-maintained source; Mac OS
  8.1 boots to the Finder with it.
* **Free changes** (other systems, or a ROM that no longer identifies itself as this one,
  so that Mac OS does not install its patches for it): insert code anywhere. When a trap
  routine moves too far for its packed trap table entry, the entry grows and the ROM is
  built again automatically. Only the free space before 0xF0000 limits how much code can
  be added.

## 5. Testing the Built ROM

### A. Testing in QEMU (Virtual Machine)
To test the rebuilt ROM in QEMU's `q800` machine:

```bash
make -C src test-qemu
```
Or run QEMU directly:
```bash
qemu-system-m68k -M q800 -bios build/QUADRA800_REBUILT.ROM -m 64M
```

The machine starts at `0x0000002A` (the ROM's low copy), jumps to `STARTBOOT`, calls
`early_cpu_detect` (`0x40804052`) to set up the 68040's caches and transparent translation
registers, and continues with the steps described in section 2.

### B. Testing in Basilisk II
Not tested with this project. Basilisk II patches the ROM it loads, so a modified ROM may not
work there.
1. Open or edit your `~/.basilisk_ii_prefs`:
   ```text
   rom /path/to/q800rom/build/QUADRA800_REBUILT.ROM
   ```
2. Start the emulator:
   ```bash
   BasiliskII
   ```

### C. Real Hardware (Macintosh Quadra 800)
Not tested on real hardware.
* The binary `build/QUADRA800_REBUILT.ROM` is exactly 1,048,576 bytes ($100000).
* How to put it on a machine depends on the board (ROM chips or a ROM SIMM socket); check your
  hardware before programming anything.
* The ROM's startup test checks the checksum stored at offset `0x00000000` (a 32-bit sum of
  the ROM's 16-bit words) on every boot; the build recomputes it, and the byte-lane sums, for
  any modified source (`make -C src rom` verifies it).
