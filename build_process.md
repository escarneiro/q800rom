# Macintosh Quadra 800 ROM Build Process

This document details the complete step-by-step build process of the **Macintosh Quadra 800 ROM** (`QUADRA800.ROM`) from reconstructed Motorola 68040 assembly and C source code into a bootable 1,048,576-byte (1 MB) binary image.

---

## 1. System & ROM Architecture Overview

The Macintosh Quadra 800 (1993) is powered by a **Motorola 68040 microprocessor running at 33 MHz** with integrated floating-point unit (FPU) and paged memory management unit (MMU).

* **ROM Capacity**: Exactly 1,048,576 bytes ($100000 = 1 Megabyte).
* **Base Memory Address (`ROMBase`)**: `0x40800000` (mapped physically and in 32-bit virtual addressing up to `0x408FFFFF`).
* **Power-On Reset Vector**: Stored in the ROM header:
  * Offset `0x00000000`: Initial Supervisor Stack Pointer (`0xF1ACAD13`, serving also as the cold-boot 32-bit checksum).
  * Offset `0x00000004`: Initial Program Counter reset vector (`0x0000002A`), which branches directly to `0x4080008C` (`_reset_startup`).

---

## 2. High-Level Pipeline Diagram

```
+-------------------------------------------------------------+
|                     1. SOURCE CODE                          |
|  - Assembly: boot/reset.s, traps/trap_dispatcher.s          |
|  - C Subsystems: boot/, traps/, toolbox/, declrom/          |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|             2. ASSEMBLY & CROSS-COMPILATION                 |
|  - m68k-as (-m68030)  -> boot/reset.o, trap_dispatcher.o   |
|  - m68k-gcc (-m68040) -> build/*_m68k.o                     |
|    (-nostdlib -ffreestanding, freestanding string.h)        |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|               3. MEMORY-MAPPED LINKING                      |
|  - m68k-ld using linker script src/rom.ld                   |
|  - Origin: 0x40800000, Length: 1048576 bytes                |
|  - Produces: build/q800_rom.elf                             |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|          4. ROM IMAGE PACKAGING & CHECKSUM                  |
|  - Standalone: objcopy -O binary & pad to 1,048,576 bytes    |
|  - Composite/Overlay: Inject compiled routines into layout: |
|      * 0x40804052: _early_cpu_detect (68040 MMU/cache)      |
|      * 0x408099B0: _trap_dispatcher (Vector 10 handler)     |
|      * 0x408FFFEC: NuBus Declaration ROM Format Block       |
|  - Compute 32-bit sum of 16-bit words (rom_checksum.py)     |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|                     5. BOOTABLE ROM                         |
|  - build/QUADRA800_REBUILT.ROM                              |
|  - build/QUADRA800_STANDALONE.ROM                           |
|  - Verified in QEMU (q800 machine), Basilisk II & Hardware  |
+-------------------------------------------------------------+
```

---

## 3. Step 1: Assembly Phase (`m68k-as`)

The low-level CPU bootstrap and exception dispatching must be compiled directly to 680x0 machine instructions:

### A. `src/boot/reset.s` -> `boot/reset.o`
* **ROM Header (`0x40800000`)**:
  * Emits the 32-bit checksum slot at offset `0x00000000`.
  * Emits the initial PC entry vector (`0x0000002A`) at offset `0x00000004`.
  * Sets up ROM flags (`0x067C`) and jump tables at offset `0x40` pointing to subsystem initialization entry points.
* **Cold Reset Startup (`_reset_startup` at offset `0x008C`)**:
  * Enters supervisor mode with all interrupts masked (`move.w #0x2700, %sr`).
  * Asserts the external `reset` CPU instruction to clear bus devices.
  * Disables the VIA1 hardware ROM overlay so that physical RAM is mapped to address `0x00000000`.
  * Sets up the early temporary Vector Base Register (`VBR`) to point to the ROM exception vector table at `0x40803D10`.
* **68040 CPU Detection & MMU/Cache Configuration (`_early_cpu_detect` at offset `0x4052`)**:
  * Probes bit 31 of `CACR` to distinguish between Motorola 68040 and 68030 processors.
  * Executes `cinva bc` (`.word 0xF4D8`) to invalidate both on-chip instruction and data caches.
  * Disables translation control via `movec %d0, %tc` (`.word 0x4E7B, 0x0003`).
  * Configures Data Transparent Translation Registers:
    * `DTT0 = 0x807FC040`: Maps `$80000000-$FFFFFFFF` as non-cacheable serialized memory.
    * `DTT1 = 0x500FC040`: Maps Apple internal I/O space `$50000000-$50FFFFFF`.

### B. `src/traps/trap_dispatcher.s` -> `traps/trap_dispatcher.o`
* Implements **Vector 10 (Line 1010 Emulator at `$0028`)**, decompiled from ROM address `0x408099B0`.
* Decodes OS Traps (`$A000-$A0FF`) through the OS Dispatch Table (`OSTable` at `$0400`).
* Decodes Toolbox Traps (`$A800-$AFFF`) through `ToolboxTable` (`$0E00` / `$1E00`).
* Supports auto-pop Toolbox Traps (`$AC00-$AFFF`) using `rtd #4`.

### Assembler Invocation
```bash
/usr/m68k-suse-linux/bin/as -m68030 boot/reset.s -o boot/reset.o
/usr/m68k-suse-linux/bin/as -m68030 traps/trap_dispatcher.s -o traps/trap_dispatcher.o
```
*Note*: Multi-generation CPU instructions (such as `cinva` and 68040 control register `movec` operations) are encoded as raw `.word` machine codes to guarantee clean compilation under any GNU assembler dialect.

---

## 4. Step 2: C Compilation Phase (`m68k-gcc`)

Higher-level ROM managers and hardware drivers are compiled with GNU GCC targeting the 68040.

### A. Compiled Modules & Responsibilities
1. **Boot & Hardware Initialization**:
   * `boot/cpu68040.c`: Cache flush (`cpusha bc`), invalidation, and MMU control register interfaces.
   * `boot/hwinit.c`: Motherboard identification table lookup (`0x4080322C`), machine ID detection (`0x0023` for Quadra 800 / BoxFlag 35), and VIA1 timer calibration.
   * `boot/lowmem_init.c`: Initialization of low-memory RAM global variables (`MemTop`, `BufPtr`, `ROMBase`, `SysZone`, `ApplZone`).
2. **Macintosh Toolbox Managers**:
   * `toolbox/mem_manager.c`: Memory Manager (`_NewPtr`, `_DisposPtr`, `_NewHandle`, `_DisposHandle`, `_HLock`, `_HUnlock`).
   * `toolbox/resource_mgr.c`: Resource Manager (`_InitResources`, `_GetResource`, `_ReleaseResource`, `_CurResFile`).
   * `toolbox/quickdraw.c`: Color QuickDraw engine (`_InitGraf`, `_InitCursor`, GrafPort setup).
   * `toolbox/slot_mgr.c`: NuBus Slot Manager (`sGetFormatBlock`, `sRsrcInfo`).
   * `toolbox/os_traps.c`: Device Manager and OS trap wrappers (`_Open`, `_Close`, `_Read`, `_Write`).
3. **NuBus Declaration ROM**:
   * `declrom/declrom_quadra.c`: Motherboard sResource Directory (`0x0F2CA4`) and NuBus Format Block.
   * `declrom/video_dafb.c`: DAFB / ViSC onboard video controller definitions.
4. **Trap Tables**:
   * `traps/trap_unpacker.c`: Unpacker for the compressed ROM trap table stream at offset `0x000D3370`.
   * `traps/trap_table.c`: Complete mapping table for all 1,280 system traps.

### B. Freestanding Compilation Flags
Because the ROM runs on bare metal without an OS or standard C library, the modules are compiled freestanding:
```bash
/usr/bin/m68k-suse-linux-gcc -m68040 -nostdlib -ffreestanding \
    -Iinclude -Iboot -Itraps -Itoolbox -Ideclrom -O2 -c <file>.c -o build/<file>_m68k.o
```
* `-nostdlib -ffreestanding`: Prevents the compiler from linking hosted runtime libraries.
* `src/include/string.h`: Implements freestanding inline `memcpy`, `memset`, and `strcmp`.
* `src/include/mac_types.h`: Defines Classic Macintosh types (`Handle`, `Ptr`, `Rect`, `Point`, `OSErr`).

---

## 5. Step 3: Memory-Mapped Linking Phase (`m68k-ld`)

All bare-metal assembly and C objects are combined into an ELF binary using the linker script `src/rom.ld`.

### The Linker Script (`src/rom.ld`)
The script establishes the physical memory origin at `0x40800000` with a length of `1048576` bytes (1 MB):

```ld
OUTPUT_FORMAT("elf32-m68k")
OUTPUT_ARCH(m68k)
ENTRY(_rom_start)

MEMORY
{
    rom (rx) : ORIGIN = 0x40800000, LENGTH = 1048576
}

SECTIONS
{
    /* ROM Header and Reset Sequence anchored at 0x40800000 */
    .rom_head 0x40800000 : {
        KEEP(*boot/reset.o(.text .text.*))
    } > rom

    /* Trap Dispatcher, C subsystems and executable code */
    .text   : { *(.text) *(.text.*) } > rom
    .rodata : { *(.rodata) *(.rodata.*) } > rom
    .data   : { *(.data) *(.data.*) } > rom
    .bss    : { *(.bss) *(.bss.*) *(COMMON) } > rom

    /* NuBus Declaration ROM structures placed at 0x408F0000 */
    .declrom 0x408F0000 : {
        KEEP(*declrom/*.o(.rodata .rodata.* .data .data.*))
    } > rom

    /* NuBus Format Block anchored at the top of memory (0x408FFFEC) */
    .format_block 0x408FFFEC : {
        LONG(-54088)        /* Directory offset -> points to 0x408F2CA4 */
        LONG(0x00000000)    /* Length */
        LONG(0x00000000)    /* CRC */
        BYTE(0x01)          /* NuBus Revision Level */
        BYTE(0x01)          /* Format Version */
        LONG(0x5A932BC7)    /* Test Pattern: $5A932BC7 */
        BYTE(0x00)          /* Reserved */
        BYTE(0x0F)          /* ByteLanes: 32-bit word lanes ($0F) */
    } > rom
}
```

### Linking Invocation
```bash
/usr/m68k-suse-linux/bin/ld -T rom.ld boot/reset.o traps/trap_dispatcher.o build/*_m68k.o -o build/q800_rom.elf
```
This produces `build/q800_rom.elf` containing full symbol resolution and relocation records mapped to `0x40800000`.

---

## 6. Step 4: Binary ROM Packaging (`tools/build_rom.py`)

A physical ROM chip or emulator requires a raw, contiguous 1,048,576-byte binary image rather than an ELF container. The Python builder tool creates two distinct ROM targets:

### 1. Composite / Overlay ROM (`build/QUADRA800_REBUILT.ROM`)
This is the recommended target for emulation and hardware validation:
1. Loads the original 1MB ROM image (`QUADRA800.ROM`) as a base template.
2. Extracts raw machine instructions from `boot/reset.o` and injects `_early_cpu_detect` at exact functional offset `0x00004052`.
3. Extracts raw machine instructions from `traps/trap_dispatcher.o` and injects `_trap_dispatcher` at offset `0x000099B0`.
4. Verifies the NuBus Declaration ROM Format Block at `0x0FFFEC`.
5. Recalculates and stamps the 32-bit checksum at offset `0x00000000`.

### 2. Standalone ROM (`build/QUADRA800_STANDALONE.ROM`)
1. Strips all ELF metadata using `objcopy -O binary build/q800_rom.elf raw.bin`.
2. Pads the binary image with zeroes up to exactly 1,048,576 bytes.
3. Anchors the NuBus Declaration ROM Format Block at offset `0x0FFFEC`.
4. Computes and writes the checksum at offset `0x00000000`.

---

## 7. Step 5: Checksum Calculation & Validation (`tools/rom_checksum.py`)

During cold boot, the 68040 processor runs a Power-On Self Test (POST). If the ROM checksum does not match the header value, the machine sounds the error chime ("Chimes of Death") and halts.

### Checksum Algorithm
The Classic Macintosh checksum is computed as the **32-bit sum of all 16-bit big-endian words** from byte offset `0x00000004` to the end of the ROM (`0x000FFFFE`):

$$\text{Checksum}_{32} = \left(\sum_{i=2}^{524287} \text{Word}_{16}[i]\right) \pmod{2^{32}}$$

Implemented in Python:
```python
def calculate_checksum(rom_bytes: bytes) -> int:
    csum = 0
    for i in range(4, len(rom_bytes), 2):
        word = (rom_bytes[i] << 8) | rom_bytes[i + 1]
        csum = (csum + word) & 0xFFFFFFFF
    return csum
```
The resulting 32-bit integer is written in big-endian byte order at offset `0x00000000`.

---

## 8. Summary of Build Commands & Execution

Executing `make -C src rom` orchestrates the entire workflow automatically:

```bash
# 1. Build and run the host verification harness
make -C src

# 2. Compile bare-metal 68040 assembly and C objects, link, and package ROMs
make -C src rom
```

### Verification & Testing
* **QEMU Quadra 800 Virtual Machine**:
  ```bash
  make -C src test-qemu
  # or directly:
  qemu-system-m68k -M q800 -bios build/QUADRA800_REBUILT.ROM -m 64M
  ```
* **Basilisk II**:
  Configure `rom /path/to/build/QUADRA800_REBUILT.ROM` in `~/.basilisk_ii_prefs`.
* **Physical Hardware**:
  Flash the 1,048,576-byte binary to a Macintosh 64-pin ROM SIMM or split across 4x 256KB EPROMs.
