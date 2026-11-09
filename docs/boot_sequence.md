# Macintosh Quadra 800 Boot & Initialization Sequence

1. **Hardware Power-On Reset**:
   * At power-on the ROM also appears at address `0x00000000` (overlay). The 68040 fetches the
     initial SSP from `0x00000000` (the first long of the ROM, which is also its checksum) and the initial
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
     handler (`BusErrorVector`, used while probing the hardware).

4. **Hardware Identification & RAM Sizing**:
   * Identifies the machine with the Universal ROM's decoder and product tables (the list at
     `0x4080322C` starts with `UNKNOWNDECODERTABLE`). The Quadra 800 is box flag 29 (`0x1D`); its Gestalt machine type is that plus 6, 35.
   * The ROM overlay is turned off, so that RAM appears at address `0x00000000` (where exactly
     in the code has not been traced).
   * Sizes the RAM banks and sets up the memory controller.

5. **Low-Memory Globals & Exception Vectors**:
   * Sets `CPUFlag` ($012F) = `4` (Motorola 68040) and `BoxFlag` ($0CB3) = the machine's box
     flag (29 for the Quadra 800).
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
