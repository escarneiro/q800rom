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
   * Points `VBR` to ROM exception vector table at `0x40803D08`, pre-populated with Gary Davidian's trap handler (`0x47617279` / `'Gary'`).

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

6. **Trap Dispatcher Installation & Unpacking (`0x40809A88`)**:
   * Installs `_trap_dispatcher` (`0x408099B0`) at Vector 10 (`$0028`, Line 1010 Emulator).
   * Reads relative table offset at ROM header byte 34 (`$0022` -> `$000D3370`).
   * Unpacks 1,024 Toolbox Traps into `ToolboxTable` ($0E00).
   * Unpacks 256 OS Traps into `OSTable` ($0400).

7. **Subsystem Launch**:
   * Calls `_SwapMMUMode` (`$A05D`) to enter 32-bit addressing mode.
   * Initializes Color QuickDraw (`_InitGraf` at `0x40841530`), cursor, fonts, windows, menus, and Dialog Manager.
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
│   ├── lowmem.inc         - Assembly equates for low-memory globals
│   ├── traps.h            - Decoded A-Trap equates ($A000-$AFFF) with ROM routine addresses
│   ├── traps.inc          - Assembly trap equates
│   ├── hw_quadra.h        - Hardware register definitions (VIA1, VIA2, SCC, SCSI, DAFB, 68040 CACR/TC/DTT)
│   ├── hw_quadra.inc      - Assembly hardware equates
│   ├── declrom.h          - NuBus Declaration ROM structures and sResource types
│   └── rom_symbols.h      - Complete map of decompiled ROM entry points and symbols
├── boot/
│   ├── reset.s            - 68040 assembly for power-on reset sequence (ROM header, MMU/cache, overlay disable)
│   ├── cpu68040.c / .h    - 68040 processor detection, cache invalidation, and transparent translation setup
│   ├── hwinit.c / .h      - VIA1 timer calibration, RAM sizing, and machine identification
│   └── lowmem_init.c / .h - Initialization of low-memory globals and vector table
├── traps/
│   ├── trap_dispatcher.s  - A-Line Trap Dispatcher (vector 10, $0028) decompiled from 0x408099B0
│   ├── trap_unpacker.c/.h - Compressed ROM trap table unpacker decompiled from 0x40809A88
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

### Prerequisites
* **Host C Compiler**: `gcc` / `clang` (for the analysis harness and host testing).
* **Motorola 68000 Cross-Toolchain**: `m68k-suse-linux-gcc`, `m68k-elf-gcc`, or `m68k-linux-gnu-gcc` with GNU `as` and `ld`.
* **Python 3**: For checksum validation and ROM binary composition.
* **Emulator** (Optional for testing): `qemu-system-m68k` (with `q800` machine support) or `BasiliskII`.

### 1. Build the Entire Project & 1MB ROM
From the `src/` directory, simply run:

```bash
make -C src rom
```

This single command automatically:
1. Compiles all C modules (`boot/`, `traps/`, `toolbox/`, `declrom/`) with the m68040 cross-compiler.
2. Assembles `boot/reset.s` and `traps/trap_dispatcher.s`.
3. Links all bare-metal objects using [`src/rom.ld`](file:///home/eder/Downloads/_IA_/REA/q800rom/src/rom.ld) into `build/q800_rom.elf`.
4. Invokes [`src/tools/build_rom.py`](file:///home/eder/Downloads/_IA_/REA/q800rom/src/tools/build_rom.py) to package both:
   * **`build/QUADRA800_REBUILT.ROM`**: A 1,048,576 byte (1MB) composite ROM injecting our recompiled 68040 CPU detect, cache/MMU setup, and fast A-line trap dispatcher into the Quadra 800 layout.
   * **`build/QUADRA800_STANDALONE.ROM`**: A 1,048,576 byte (1MB) pure standalone ROM built from ELF sections and NuBus Format Block.
5. Computes and stamps the classic 16-bit word addition checksum at offset `0x00000000` and validates the result.

```text
[*] Building Standalone 1MB ROM from ELF: ../build/q800_rom.elf
    -> Computed Checksum: 0x174B0787
[+] Successfully generated: ../build/QUADRA800_STANDALONE.ROM (1048576 bytes)
[*] Building Overlay ROM from template: ../QUADRA800.ROM
    -> Injected _early_cpu_detect (80 bytes) at offset 0x00004052
    -> Injected _trap_dispatcher (120 bytes) at offset 0x000099B0
    -> Verified NuBus Declaration ROM Format Block at 0x0FFFEC
    -> Computed Checksum: 0xF1AF0BAE written to offset 0x00000000
[+] Successfully generated: ../build/QUADRA800_REBUILT.ROM (1048576 bytes)
ROM File:          ../build/QUADRA800_REBUILT.ROM (1048576 bytes)
Stored Checksum:   0xF1AF0BAE
Computed Checksum: 0xF1AF0BAE
Status:            VALID
```

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
This builds and executes `quadra_rom_harness` on `QUADRA800.ROM`.
