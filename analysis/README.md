# analysis/ — evidence used to disassemble the ROM

These files drive `src/tools/regen_romsrc.sh`, which turns an original `QUADRA800.ROM`
into the assembler source in `src/romsrc/`.

| File | What it is | How it was produced |
|---|---|---|
| `trap_tables_runtime.txt` | The real OS (256) and Toolbox (1024) trap dispatch tables | Original ROM booted in QEMU (`-M q800`, no disk) to the desktop; RAM `$0400` and `$0E00` dumped with `pmemsave` |
| `executed_pcs.txt` | 30,551 ROM addresses that were actually executed | QEMU `-d in_asm,nochain` traces: boot to the desktop with no disk, plus a full Mac OS 8.1 boot to the Finder (`-snapshot`, read-only disk) |
| `ghidra_seeds.txt` | Code entry points, names and known data ranges | `src/tools/rom_seeds.py` (the files above + ROM resource list) |
| `ghidra_codemap.txt` | Instructions, functions and strings found by Ghidra | `analyzeHeadless` + `Q800Seed.java` (aggressive instruction finder) + `Q800Export.java` |
| `code_hints.txt` | Code entry points found in ROM tables (Universal primitives, ROMBase offset tables, NuBus init blocks) | Written by `src/tools/rom_disasm.py`; fed back to Ghidra as seeds on the next regeneration |
| `ghidra_atraps.txt` | A-line trap call sites | `Q800ATraps.java` (Ghidra can't decode A-line words, so it stops at every trap call; this script resumes after them) |
| `Quadra800ROM.lst` | Apple's symbol map of this ROM (2,672 labels; Apple used it for the Quadra 800 and Centris 610/650) | MPW 3.5 GM `ROM Maps/ROM.List`, via [cy384/68k-mac-rom-maps](https://github.com/cy384/68k-mac-rom-maps); line endings converted to LF. Gives `trap_table.c` its names and `src/romsrc/` its Apple labels |
| `macos81_rom_refs.txt` | The 908 ROM addresses that Mac OS 8.1's patches use directly (come-from checks, jumps into ROM routines, loaded addresses); code before the last one must keep its layout to stay compatible with Mac OS | Original ROM booted to the Finder from a Mac OS 8.1 disk in QEMU: the executed instructions (`-d in_asm`) and a RAM dump after the boot, scanned for 68k instructions with a ROM address operand |
| `romsrc_fixups.txt` | Corrections to the generated source, by ROM address (data ranges, code starts, offset tables and pointers, numbers); no ROM content | `src/tools/export_fixups.py` (the hand-maintained source compared with the generated one); applied by `src/tools/apply_fixups.py` as the last step of `regen_romsrc.sh` |
| `qemu_macos81_boot_*.png` | Mac OS 8.1 Finder screenshots with the original and the rebuilt ROM | QEMU `screendump` (local only, not in git) |

## Findings worth knowing

* **Trap and symbol addresses were wrong and have been corrected.** Originally only 558 of
  the 1280 addresses in `src/traps/trap_table.c` matched the tables the ROM installs, and many
  entries of the (since removed) `rom_symbols.h` were off by multiples of 0x10000 (e.g. `_InitGraf`
  is at `0x40831530`, not `0x40841530`). `trap_table.c` and the address comments in the READMEs
  now use the runtime values. Other fixes: the early VBR is `0x40803D00` (`0x40803D08` is only the table entry it
  matches); the trap-table builder that actually runs starts at `0x40809A96` (`0x40809A88` only
  stores the A-line vector); the video driver is the `.Display_Video_Apple_ViSC` DRVR at
  `0x4089BCC4` (`0x4089A2EA` is its driver directory); `$A0A0`–`$A0A2` hold 24-bit addresses
  (`0x0086xxxx` is the ROM through its 24-bit mirror): they are not real traps but three jump
  vectors of the ROM's `.Sony` floppy driver, a second read-address / read-data / write-data
  set (most likely for MFM disks) that its open routine stores at `$680`–`$688` next to
  `JRdAddr`/`JRdData`/`JWrData`. `$A0BD` is `_CacheFlush`: the packed table points it at
  Apple's `VCACHEFLUSH`, replaced on a 68040 by `cpusha bc` at `0x40885030`
  (`CACHEVECTORPATCH`).
* **Trap names come from Apple.** `src/traps/trap_table.c` used to have 114 wrong names
  (several ranges shifted by one or more slots, e.g. `$A916` is `_HideWindow`, not
  `_InitMenus`) and 597 placeholders. Names now come from Apple's `Traps.h`, checked against
  `Quadra800ROM.lst`: 1275 of the 1280 handler addresses carry an Apple label, and it agrees
  with the `Traps.h` name for every trap that has both. Private traps carry Apple's label
  (`_VBTOPEN`, `_BITBLT`); only 210 unused or RAM-installed slots keep placeholders.
* **Packed trap table format.** Decoded by the ROM at `0x40809A96`. A byte with bit 7 set:
  `0x80` = unimplemented, `0xFF` + long = absolute ROM offset, otherwise `(b & 0x7F) * 2` bytes
  forward. A byte with bit 7 clear starts a word `w`; the delta is `sign_extend16((w * 2) & 0xFFFF)`.
  Toolbox entries come first, then OS entries; a zero delta ends the table. The project's
  original C unpacker (since removed) used plain `w * 2`, which is why only 558 entries were right;
  decoded correctly, 1264/1280 match the runtime tables (the other 16 are installed later at boot).
* **Where the ROM keeps addresses** (all symbolized in `src/romsrc/`, see `src/tools/rom_reloc.py`):
  Universal ROM ProductInfo records (0x40 bytes, offsets relative to the record), the machine
  list at `0x4080322C` (self-relative longs), "primitives" routine tables (offsets relative to the
  table), the Memory Manager vector tables at `0x4080CB20` (ROMBase-relative, copied to
  `$1E00`/`$1F00`), device records such as `0x40846040` (offsets relative to the table), NuBus
  sResources (24-bit self-relative), the packed trap table, the resource map, and many
  `lea N,%a0; jmp %pc@(here,%a0:l)` long calls.
* The motherboard NuBus declaration ROM at the top of the image is only a stub
  ("Unknown Macintosh") with no code.
* `0xC0000–0xCFFFF` is mostly 8-bit sound sample data. Most of `0xF0000–0xFFFFF` is filler:
  a repeated Apple copyright banner.

## Coverage of the generated source

* 139,052 instructions = 422,334 bytes (about 40% of the ROM) are emitted as instructions,
  including about 3,000 A-trap call sites. About 1,600 of them are written as raw words
  with the disassembly as a comment.
* About 23% is ROM resource data and 14% is padding. The rest is data tables plus code that
  no trace or analysis reached; it is emitted as `.long` data. More traces (running
  applications, AppleTalk, serial, floppy) add more code: append them to `executed_pcs.txt`
  in the same `0x<addr>: ` format and run `make -C src romsrc-regen`.
