# Macintosh Quadra 800 ROM Build Process

This document details the step-by-step build process of the **Macintosh Quadra 800 ROM** (`QUADRA800.ROM`): from the disassembled, relocatable Motorola 68040 assembly source in `src/romsrc/` into a bootable 1,048,576-byte (1 MB) binary image that is byte-identical to the original.

---

## 1. System & ROM Architecture Overview

The Macintosh Quadra 800 (1993) is powered by a **Motorola 68040 microprocessor running at 33 MHz** with integrated floating-point unit (FPU) and paged memory management unit (MMU).

* **ROM Capacity**: Exactly 1,048,576 bytes ($100000 = 1 Megabyte).
* **Base Memory Address (`ROMBase`)**: `0x40800000` (mapped physically and in 32-bit virtual addressing up to `0x408FFFFF`).
* **ROM Header**:
  * Offset `0x00000000`: 32-bit ROM checksum (`0xF1ACAD13`), also fetched as the initial Supervisor Stack Pointer at power-on.
  * Offset `0x00000004`: Initial Program Counter reset vector (`0x0000002A`), which branches to the cold-reset code at `0x4080008C`.
  * Offsets `0x30`-`0x3F`: four byte-lane sums (one per ROM chip lane).

---

## 2. High-Level Pipeline Diagram

```
+-------------------------------------------------------------+
|        0. SOURCE GENERATION (once per checkout)             |
|  make -C src romsrc-regen ORIG_ROM=<your QUADRA800.ROM>     |
|  - tools/rom_disasm.py + tools/rom_reloc.py, driven by      |
|    analysis/ (Ghidra code map, QEMU traces, Apple ROM map)  |
|  - Produces src/romsrc/ (not in git), verified byte-exact   |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|          1. ASSEMBLY & LINKING OF THE ROM SOURCE            |
|  - m68k-as (-m68040) romsrc/q800rom.s -> build/q800rom.o    |
|  - m68k-ld -Ttext=0x40800000 -> build/q800rom.elf           |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|          2. BINARY IMAGE, POST-LINK FIX-UPS & CHECKSUM      |
|  - objcopy -O binary -> build/QUADRA800_REBUILT.ROM         |
|  - tools/rom_postlink.py: packed trap table (traptable.lst),|
|    NuBus 24-bit offsets (relocs.lst), byte-lane sums (0x30) |
|    and 32-bit checksum (0x00)                               |
|  - SHA-256 check against romsrc/q800rom.sha256              |
|  - tools/rom_checksum.py --verify                           |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|                     3. BOOTABLE ROM                         |
|  - build/QUADRA800_REBUILT.ROM (identical to the original)  |
|  - Verified in QEMU (q800 machine): desktop, Mac OS 8.1     |
+-------------------------------------------------------------+
```

---

## 3. Step 0: Generating the ROM Source (`make romsrc-regen`)

`src/romsrc/` is generated, not stored in git: it contains the ROM's bytes. It is produced once per checkout from a user-supplied original ROM and the committed analysis in `analysis/`:

```bash
make -C src romsrc-regen ORIG_ROM=/path/to/QUADRA800.ROM     # about 3 minutes
```

`tools/regen_romsrc.sh` runs `tools/rom_disasm.py`, which:
* splits code from data with the committed Ghidra code map (`analysis/ghidra_codemap.txt`, `analysis/ghidra_atraps.txt`), seeded by QEMU boot traces and the live trap tables (`analysis/ghidra_seeds.txt`);
* disassembles the code with m68k `objdump` into GNU `as` (MIT syntax) source, with labels for every branch and PC-relative target and `jbra`/`jbsr`/`jbcc` branches so the assembler picks the size;
* names labels after their traps (`trap_GetResource`, names from `src/traps/trap_table.c`) and after Apple's own MPW ROM map (`analysis/Quadra800ROM.lst`: `GETRESOURCE`, `SETPORT`, ...);
* writes A-line trap calls as macros (`romsrc/include/traps_gas.inc`);
* turns hard-coded addresses and offsets into label expressions (`tools/rom_reloc.py`: ProductInfo records, primitives tables, Memory Manager vectors, NuBus sResources, the resource map, long relative calls, ...), so that code can be edited and moved;
* verifies that the source assembles back to the original ROM byte for byte.

Output in `src/romsrc/`: `q800rom.s` (includes `part_00.s` ... `part_0F.s`, one per 64 KB), `include/traps_gas.inc`, `traptable.lst`, `relocs.lst` and `q800rom.sha256`.

`make -C src romsrc-reanalyze` additionally re-runs Ghidra (`analyzeHeadless` with `tools/ghidra/Q800Seed.java`, `Q800ATraps.java`, `Q800Export.java`) to improve the code map; that changes the generated source.

---

## 4. Step 1: Assembling and Linking the ROM Source

```bash
/usr/m68k-suse-linux/bin/as -m68040 -I romsrc -I romsrc/include romsrc/q800rom.s -o ../build/q800rom.o
/usr/m68k-suse-linux/bin/ld -Ttext=0x40800000 -e 0x40800000 --no-warn-rwx-segments \
    -o ../build/q800rom.elf ../build/q800rom.o
```

Linking at `ROMBase` (`0x40800000`) makes every label resolve to its ROM address. Padding in front of the fixed region at `0x408F0000` (declaration ROM and format block) is written as `.org`, so the code above it can grow or shrink.

---

## 5. Step 2: Binary Image and Post-Link Fix-Ups (`tools/rom_postlink.py`)

```bash
/usr/bin/m68k-suse-linux-objcopy -O binary --only-section=.text ../build/q800rom.elf ../build/QUADRA800_REBUILT.ROM
python3 tools/rom_postlink.py ../build/q800rom.elf ../build/QUADRA800_REBUILT.ROM romsrc
```

Two ROM structures cannot be expressed as GNU `as` expressions across relaxable branches, so they are filled in after linking from the label addresses in the ELF (`nm`):

1. **Packed trap dispatch table** (header long at `0x22`, table at `0x408D3370`): re-encoded from `romsrc/traptable.lst`, one line per trap (`b`/`w`/`l` encoded entry with its target label, `u` unimplemented). Each entry keeps its encoding class; the build fails if a moved routine no longer fits it.
2. **NuBus sResource entries**: 24-bit self-relative offsets from `romsrc/relocs.lst` (`s24 <loc> <target>`).
3. **Checksums**: byte-lane sums and the 32-bit checksum (see Step 3).

The result is compared with `romsrc/q800rom.sha256`: an unmodified source gives an image identical to the original ROM; a mismatch is reported (modified source) but is not an error.

---

## 6. Step 3: Checksum Calculation & Validation (`tools/rom_checksum.py`)

During cold boot, the ROM verifies its checksum as part of its Power-On Self Test. If the checksum does not match the header value, the machine sounds the error chime ("Chimes of Death") and halts.

### Checksum Algorithm
The Classic Macintosh checksum is computed as the **32-bit sum of all 16-bit big-endian words** from byte offset `0x00000004` to the end of the ROM (`0x000FFFFE`):

$$\text{Checksum}_{32} = \left(\sum_{i=2}^{524287} \text{Word}_{16}[i]\right) \pmod{2^{32}}$$

Before it, the four **byte-lane sums** at `0x30`-`0x3F` are computed: for each lane `L` (0-3), the sum of all bytes at offsets `i` with `i mod 4 = L`, excluding `0x00`-`0x03` and `0x30`-`0x3F`.

Implemented in Python (`fix_checksums` in `tools/rom_checksum.py`, called by `tools/rom_postlink.py`):
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

## 7. Summary of Build Commands & Execution

```bash
# 0. Once per checkout: generate src/romsrc/ from your own ROM
make -C src romsrc-regen ORIG_ROM=/path/to/QUADRA800.ROM

# 1. Build the ROM
make -C src rom       # or just: make -C src
```

### Verification & Testing
* **Headless boot test** (QEMU, must reach the grey desktop with the cursor):
  ```bash
  make -C src test-boot
  ```
* **Relocatability test**: inserts bytes (filled with `ILLEGAL`) before a function so that almost the whole ROM moves, rebuilds and boots it:
  ```bash
  make -C src test-shift SHIFT_AT=0x40830000 SHIFT_BYTES=0x40
  ```
* **QEMU Quadra 800 Virtual Machine** (interactive):
  ```bash
  make -C src test-qemu
  # or directly:
  qemu-system-m68k -M q800 -bios build/QUADRA800_REBUILT.ROM -m 64M
  ```
