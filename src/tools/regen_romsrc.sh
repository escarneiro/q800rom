#!/bin/sh
# regen_romsrc.sh - Regenerate src/romsrc/ (disassembled ROM source) from an original ROM.
#
# Pipeline:
#   1. rom_seeds.py   code entry points + names: runtime trap tables and QEMU execution
#                     traces (analysis/), ROM resource list, verified rom_symbols.h entries
#   2. Ghidra         headless auto-analysis (+ Aggressive Instruction Finder), seeded by 1;
#                     Q800ATraps.java follows code across A-line trap calls;
#                     Q800Export.java writes the code map
#   3. rom_disasm.py  labelled GNU as source, verified to rebuild the ROM byte for byte
#
# The QEMU evidence in analysis/ (trap_tables_runtime.txt, executed_pcs.txt) was captured
# by booting the original ROM with "-d in_asm" (to the desktop and into Mac OS 8.1).
#
# Usage (from src/): tools/regen_romsrc.sh ../QUADRA800.ROM
set -e
ROM=$(realpath "${1:-../QUADRA800.ROM}")
SRC=$(cd "$(dirname "$0")/.." && pwd)
AN=$(cd "$SRC/../analysis" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

python3 "$SRC/tools/rom_seeds.py" "$ROM" "$AN/ghidra_seeds.txt" \
    --traps "$AN/trap_tables_runtime.txt" --trace "$AN/executed_pcs.txt" \
    --names "$SRC/traps/trap_table.c" --symbols "$SRC/include/rom_symbols.h"

analyzeHeadless "$WORK" q800 -import "$ROM" \
    -processor 68000:BE:32:default -loader BinaryLoader -loader-baseAddr 0x40800000 \
    -scriptPath "$SRC/tools/ghidra" \
    -preScript Q800Seed.java "$AN/ghidra_seeds.txt" aggressive \
    -postScript Q800ATraps.java "$AN/ghidra_atraps.txt" \
    -postScript Q800Export.java "$AN/ghidra_codemap.txt" > "$WORK/ghidra.log" 2>&1 \
    || { tail -30 "$WORK/ghidra.log"; exit 1; }
grep -E "Q800(Seed|ATraps|Export)\.java> Q800[A-Za-z]*: [0-9]" "$WORK/ghidra.log" | sed 's/^.*> /    /' | tail -3

python3 "$SRC/tools/rom_disasm.py" "$ROM" "$AN/ghidra_codemap.txt,$AN/ghidra_atraps.txt" \
    "$AN/ghidra_seeds.txt" "$SRC/traps/trap_table.c" "$SRC/romsrc"
