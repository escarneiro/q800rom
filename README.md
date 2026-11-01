# Macintosh Quadra 800 ROM Reverse Engineering & Reconstructed Source

This repository contains the decompiled and reconstructed C and Motorola 68040 assembly source code for the **Macintosh Quadra 800 ROM** (`QUADRA800.ROM`), based on reverse engineering with REA, Ghidra, and official Apple technical documentation.

---

## 1. System & ROM Architecture Overview

The Macintosh Quadra 800 (1993) is powered by a **Motorola 68040 CPU running at 33 MHz** with integrated FPU and MMU. The ROM image is exactly **1,048,576 bytes (1 Megabyte)**.

### Physical & Virtual Memory Map
* **RAM Base**: `0x00000000` (8 MB fixed interleaved RAM on motherboard, expandable to 136 MB)
* **ROM Base (`ROMBase`)**: `0x40800000` (ends at `0x408FFFFF`)
* **I/O Space Base**: `0x50F00000`
  * **VIA1**: `0x50F00000` (ADB, Timer 1/2, VBL, RTC clock line, ROM overlay control)
  * **VIA2 / OSS**: `0x50F02000` (NuBus slot interrupts, SCSI DRQ/IRQ, Ethernet IRQ)
  * **SCC (Z8530)**: `0x50F04000` (read) / `0x50F06000` (write)
  * **SCSI (NCR 53C96)**: `0x50F10000` (Controller), `0x50F12000` (Handshake), `0x50F14000` (DMA)
  * **DAFB Video Controller**: `0x50F16000` (CLUT DAC, resolution sensing, frame buffer control)
  * **SONIC Ethernet (DP83932)**: `0x50F0A000`
* **NuBus Standard Slots**: `$F9000000` - `$FE000000` (Slots 9 through E)

---

## 2. Boot & Initialization Sequence

1. **Hardware Power-On Reset**:
   * The 68040 processor fetches initial SSP from address `0x00000000` (`0xF1ACAD13`, serving also as the ROM checksum) and initial PC from address `0x00000004` (`0x0000002A`).
   * At power-on, hardware overlay maps ROM to address `0x00000000`.
   * Address `0x0000002A` branches immediately to `0x4080008C` (`_reset_startup`).

2. **CPU Detection & Cache/MMU Setup (`0x40804052`)**:
   * Puts CPU in supervisor mode and disables interrupts (`move.w #$2700, %sr`).
   * Tests bit 31 of `CACR` to detect Motorola 68040 vs 68030.
   * On 68040:
     * Issues `cinva bc` (`0xF4D8`) to invalidate all cache lines.
     * Clears `CACR` (caches disabled during boot) and `TC` (MMU disabled).
     * Configures Data Transparent Translation register `DTT0` to `0x807FC040` (maps $80000000-$FFFFFFFF as non-cacheable serialized memory).
     * Configures `DTT1` to `0x500FC040` (maps Apple internal I/O space $50000000-$50FFFFFF).
   * Asserts the `reset` CPU instruction to reset external bus peripherals.

3. **Temporary Exception Vector Table (`0x40802E00`)**:
   * Sets temporary stack pointer `%sp = $2600`.
   * Points `VBR` to ROM exception vector table at `0x40803D00`, pre-populated with Gary Davidian's trap handler (`0x47617279` / `'Gary'`).

4. **Hardware Identification & RAM Sizing**:
   * Looks up motherboard configuration table at `0x4080322C`. Quadra 800 is identified by Machine ID `0x0023` (BoxFlag 35).
   * Disables ROM overlay via VIA1 Port B bit 4 so physical RAM is mapped to address `0x00000000`.
   * Sizes RAM banks and sets up parity/interleaving registers.

5. **Low-Memory Globals & Exception Vectors**:
   * Sets `CPUFlag` ($012F) = `4` (Motorola 68040).
   * Sets `MMUFlags` ($0CB3) = `1` (32-bit clean mode).
   * Sets `MemTop` ($0108) = top of detected RAM.
   * Sets `BufPtr` ($010C) = bottom of video/sound buffers.
   * Sets `ROMBase` ($02AE) and `ROMBaseCopy` ($0DDC) = `0x40800000`.
   * Sets `SysZone` ($02A6) and `ApplZone` ($02AA).

6. **Trap Dispatcher Installation & Unpacking (`0x40809A96`)**:
   * Installs `_trap_dispatcher` (`0x408099B0`) at Vector 10 (`$0028`, Line 1010 Emulator).
   * Reads relative table offset at ROM header byte 34 (`$0022` -> `$000D3370`).
   * Unpacks 1,024 Toolbox Traps into `ToolboxTable` ($0E00).
   * Unpacks 256 OS Traps into `OSTable` ($0400).

7. **Subsystem Launch**:
   * Calls `_SwapMMUMode` (`$A05D`) to enter 32-bit addressing mode.
   * Initializes Color QuickDraw (`_InitGraf` at `0x40831530`), cursor, fonts, windows, menus, and Dialog Manager.
   * Traverses NuBus Declaration ROM and mounts ROM Resource Map (`ROMMapHndl` at `$0B06`).
   * Invokes `'boot'` resource to locate startup volume (SCSI, Floppy, or CD-ROM).

---

## 3. Directory Layout

```
src/
├── include/
│   ├── mac_types.h        - Standard Macintosh data types (Point, Rect, GrafPort, Handle, Ptr, OSErr)
│   ├── string.h           - Freestanding memory & string routines (memcpy, memset, strcmp) for bare-metal builds
│   ├── lowmem.h           - Complete definitions of low-memory globals ($0000 - $2000)
│   ├── traps.h            - Decoded A-Trap equates ($A000-$AFFF) with ROM routine addresses
│   ├── hw_quadra.h        - Hardware register definitions (VIA1, VIA2, SCC, SCSI, DAFB, 68040 CACR/TC/DTT)
│   ├── declrom.h          - NuBus Declaration ROM structures and sResource types
│   └── rom_symbols.h      - Complete map of decompiled ROM entry points and symbols
├── boot/
│   ├── reset.s            - 68040 assembly for power-on reset sequence (ROM header, MMU/cache, overlay disable)
│   ├── cpu68040.c / .h    - 68040 processor detection, cache invalidation, and transparent translation setup
│   ├── hwinit.c / .h      - VIA1 timer calibration, RAM sizing, and machine identification
│   └── lowmem_init.c / .h - Initialization of low-memory globals and vector table
├── traps/
│   ├── trap_dispatcher.s  - A-Line Trap Dispatcher (vector 10, $0028) decompiled from 0x408099B0
│   ├── trap_unpacker.c/.h - Compressed ROM trap table unpacker decompiled from 0x40809A96
│   └── trap_table.c / .h  - Complete table of all 1,024 Toolbox Traps and 256 OS Traps
├── toolbox/
│   ├── mem_manager.c / .h - Memory Manager (_NewPtr, _DisposPtr, _NewHandle, _DisposHandle, _HLock, _HUnlock)
│   ├── resource_mgr.c/.h  - Resource Manager (_InitResources, _GetResource, _ReleaseResource, _CurResFile)
│   ├── quickdraw.c / .h   - Color QuickDraw engine (_InitGraf, _InitCursor, port setup)
│   ├── slot_mgr.c / .h    - NuBus Slot Manager (sGetFormatBlock, sRsrcInfo, directory parsing)
│   └── os_traps.c / .h    - Device Manager and OS traps (_Open, _Close, _Read, _Write)
├── declrom/
│   ├── declrom_quadra.c/.h- Quadra 800 Declaration ROM structures (Motherboard and Video sResources)
│   └── video_dafb.c / .h  - DAFB / ViSC onboard video controller driver interface
├── tools/
│   ├── rom_checksum.py    - Classic Macintosh 16-bit word addition checksum calculator & patcher
│   └── build_rom.py       - 1MB ROM image packager (overlay & standalone modes)
├── rom.ld                 - Bare-metal GNU ld linker script for 1MB ROM mapped at 0x40800000
├── main.c                 - Verification and analysis harness
└── Makefile               - Unified build system (host verification, bare-metal cross-build, ROM generation)
```

---

## 4. Building the ROM

The build no longer needs the original `QUADRA800.ROM`. The whole ROM exists as
68040 assembly source in `src/romsrc/`, produced by disassembling the original
and checked to rebuild it **byte for byte**.

### Prerequisites
* **Motorola 68000 Cross-Toolchain**: `m68k-suse-linux-gcc` with GNU `as`, `ld`, `objcopy`.
* **Host C Compiler**: `gcc` (analysis harness only).
* **Python 3**: ROM packaging, checksum, tests.
* **Optional**: `qemu-system-m68k` (boot tests); Ghidra `analyzeHeadless` (only to regenerate `romsrc/`).

### 1. Build the 1MB ROM

```bash
make -C src rom
```

1. Assembles `src/romsrc/q800rom.s` (which includes `part_00.s` … `part_0F.s`) into
   `build/QUADRA800_BASE.ROM` and checks it against `romsrc/q800rom.sha256`.
2. Compiles and links the reconstructed C/assembly modules (`boot/`, `traps/`,
   `toolbox/`, `declrom/`) into `build/q800_rom.elf` and `build/QUADRA800_STANDALONE.ROM`
   (experimental; this image does not boot yet).
3. Overlays the reconstructed `_early_cpu_detect` and `_trap_dispatcher` on the base image,
   stamps the checksum and writes **`build/QUADRA800_REBUILT.ROM`** (bootable, currently
   identical to the original ROM, checksum `0xF1ACAD13`).

### 2. Test it

```bash
make -C src test-boot    # headless QEMU: must reach the grey desktop with the cursor
make -C src test-shift   # relocatability: move code, rebuild, boot (SHIFT_AT=, SHIFT_BYTES=)
make -C src test-qemu    # interactive QEMU window
```

`build/QUADRA800_REBUILT.ROM` boots QEMU's q800 machine to the desktop and boots
Mac OS 8.1 to the Finder.

### 3. The disassembled source (`src/romsrc/`)

* Real instructions (MIT syntax, GNU as) with labels for every branch and PC-relative
  target: `trap_GetResource`, `trap_InitGraf`, … for trap handlers (named from the live
  trap tables), `rsrc_DRVR_4__Sony_open` etc. for ROM resources, `sub_XXXXXXXX` for other
  functions, `loc_`/`dat_` for branch and data targets (the hex number is the address in
  the original ROM; it does not change when code moves).
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
* Mac OS 8.1 boots normally with the change at `0x40880000` or `0x408E0000` (the points tested
  in that range). With changes at `0x40840000` or lower
  Mac OS fails during startup (bus error after "Welcome to Mac OS", or a Sad
  Mac). The most likely reason: the System file's patches for this ROM version use fixed
  ROM addresses. Not proven; a remaining unsymbolized reference that only Mac OS uses is
  also possible.

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
(source generation, symbolization and per-instruction verification). A new code map
changes the generated source, so run `make -C src test-shift` with several `SHIFT_AT`
values before committing the updated `analysis/` files. See `analysis/README.md`.

`src/romsrc/` is listed in `.gitignore` because it contains Apple's ROM content.

---

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

The virtual machine executes from address `0x4080002A`, branches to `0x4080008C`, executes our recompiled `_early_cpu_detect` routine at `0x40804052`, configures 68040 caches, sets up transparent translation registers `DTT0`/`DTT1`, and proceeds with system initialization.

### B. Testing in Basilisk II
1. Open or edit your `~/.basilisk_ii_prefs`:
   ```text
   rom /path/to/q800rom/build/QUADRA800_REBUILT.ROM
   ```
2. Start the emulator:
   ```bash
   BasiliskII
   ```

### C. Testing on Real Hardware (Macintosh Quadra 800)
* The binary `build/QUADRA800_REBUILT.ROM` is exactly 1,048,576 bytes ($100000).
* It can be written directly to a standard programmable Macintosh 64-pin ROM SIMM, or split across 4 $\times$ 256KB 8-bit / 2 $\times$ 512KB 16-bit EPROMs.
* The hardware POST verifies the 16-bit word addition checksum at offset `0x00000000` during cold startup; our automated build process ensures this checksum is verified and matches.

---

## 6. Host Verification Harness

To verify the decompiled structures, test the trap table unpacker, and inspect NuBus Declaration ROM tables locally on Linux without an m68k toolchain:

```bash
make -C src run
```
This builds and executes `quadra_rom_harness` on `build/QUADRA800_REBUILT.ROM`.
