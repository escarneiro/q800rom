# analysis/ — evidence used to disassemble the ROM

These files drive `src/tools/regen_romsrc.sh`, which turns an original `QUADRA800.ROM`
into the assembler source in `src/romsrc/`.

| File | What it is | How it was produced |
|---|---|---|
| `trap_tables_runtime.txt` | The real OS (256) and Toolbox (1024) trap dispatch tables | Original ROM booted in QEMU (`-M q800`, no disk) to the desktop; RAM `$0400` and `$0E00` dumped with `pmemsave` |
| `executed_pcs.txt` | 30,551 ROM addresses that were actually executed | QEMU `-d in_asm,nochain` traces: boot to the desktop with no disk, plus a full Mac OS 8.1 boot to the Finder (`-snapshot`, read-only disk) |
| `ghidra_seeds.txt` | Code entry points, names and known data ranges | `src/tools/rom_seeds.py` (the files above + ROM resource list + verified `rom_symbols.h` entries) |
| `ghidra_codemap.txt` | Instructions, functions and strings found by Ghidra | `analyzeHeadless` + `Q800Seed.java` (aggressive instruction finder) + `Q800Export.java` |
| `ghidra_atraps.txt` | A-line trap call sites | `Q800ATraps.java` (Ghidra can't decode A-line words, so it stops at every trap call; this script resumes after them) |
| `qemu_macos81_boot_*.png` | Mac OS 8.1 Finder screenshots with the original and the rebuilt ROM | QEMU `screendump` (local only, not in git) |

## Findings worth knowing

* **Trap and symbol addresses were wrong and have been corrected.** Originally only 558 of
  the 1280 addresses in `src/traps/trap_table.c` matched the tables the ROM installs, and many
  `src/include/rom_symbols.h` entries were off by multiples of 0x10000 (e.g. `_InitGraf` is at
  `0x40831530`, not `0x40841530`). Both files, the `/* ROM: */` comments in `include/traps.h` and
  the address comments in `toolbox/*`, `traps/trap_unpacker.*` and the READMEs now use the runtime
  values. Other fixes: the early VBR is `0x40803D00` (`0x40803D08` is only the table entry it
  matches); the trap-table builder that actually runs starts at `0x40809A96` (`0x40809A88` only
  stores the A-line vector); the video driver is the `.Display_Video_Apple_ViSC` DRVR at
  `0x4089BCC4` (`0x4089A2EA` is its driver directory); `$A0A0`–`$A0A2` are installed in RAM.
* **Trap names in `trap_table.c` are still partly wrong.** 45 names are used for two trap
  numbers (e.g. `$A916` is `_HideWindow`, not `_InitMenus`), and 597 traps only have placeholder
  names (`_ToolboxTrap_A833`). The disassembly labels in `src/romsrc/` inherit these names.
* The motherboard NuBus declaration ROM at the top of the image is only a stub
  ("Unknown Macintosh") with no code.
* `0xC0000–0xCFFFF` is mostly 8-bit sound sample data. Most of `0xF0000–0xFFFFF` is filler:
  a repeated Apple copyright banner.

## Coverage of the generated source

* 137,079 instructions = 415,912 bytes (about 40% of the ROM) are emitted as instructions,
  including 3,008 A-trap call sites. 1,418 of them are written as raw words with the
  disassembly as a comment.
* About 23% is ROM resource data and 14% is padding. The rest is data tables plus code that
  no trace or analysis reached; it is emitted as `.long` data. More traces (running
  applications, AppleTalk, serial, floppy) add more code: append them to `executed_pcs.txt`
  in the same `0x<addr>: ` format and run `make -C src romsrc-regen`.
