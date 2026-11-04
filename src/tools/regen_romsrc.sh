#!/bin/sh
# regen_romsrc.sh - Regenerate src/romsrc/ (disassembled ROM source) from an original ROM.
#
# Pipeline:
#   1. rom_seeds.py   code entry points + names: runtime trap tables and QEMU execution
#                     traces (analysis/), ROM resource list
#   2. Ghidra         headless auto-analysis (+ Aggressive Instruction Finder), seeded by 1;
#                     Q800ATraps.java follows code across A-line trap calls;
#                     Q800Export.java writes the code map
#   3. rom_disasm.py  labelled GNU as source, verified to rebuild the ROM byte for byte;
#                     tools/rom_reloc.py turns addresses/offsets into label expressions and
#                     writes code locations found in ROM tables to analysis/code_hints.txt
#                     (used as extra seeds by the next run of this script); labels from
#                     Apple's MPW ROM map (analysis/Quadra800ROM.lst) name their addresses
#   4. declrom_names.py names for the declaration ROM, applied with rename_labels.py
#   5. apply_fixups.py  what the hand-maintained source knows and the generator does not
#                     (analysis/romsrc_fixups.txt, by ROM address): data decoded as
#                     instructions, code left as data, offset tables and pointers that are
#                     plain numbers, numbers taken for label differences. Refresh it with
#                     tools/export_fixups.py after changing the hand-maintained source.
#
# The QEMU evidence in analysis/ (trap_tables_runtime.txt, executed_pcs.txt) was captured
# by booting the original ROM with "-d in_asm" (to the desktop and into Mac OS 8.1).
#
# Usage (from src/):
#   tools/regen_romsrc.sh ../QUADRA800.ROM               step 3 only, from the committed
#                                                        Ghidra code map (deterministic:
#                                                        gives the tested source; no Ghidra)
#   tools/regen_romsrc.sh --reanalyze ../QUADRA800.ROM   steps 1-3 (needs Ghidra). The new
#                                                        code map changes the source: re-run
#                                                        "make test-shift" before committing.
set -e
REANALYZE=0
if [ "$1" = "--reanalyze" ]; then REANALYZE=1; shift; fi
ROM=$(realpath "${1:-../QUADRA800.ROM}")
SRC=$(cd "$(dirname "$0")/.." && pwd)
AN=$(cd "$SRC/../analysis" && pwd)
# A romsrc/ under version control is maintained by hand: never overwrite it
if [ -e "$SRC/romsrc/.git" ] && [ "${FORCE_REGEN:-0}" != 1 ]; then
    echo "src/romsrc/ is a git repository (hand-maintained source); not regenerating it." >&2
    echo "Move it away first, or run with FORCE_REGEN=1 to overwrite the generated parts." >&2
    exit 1
fi
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

if [ $REANALYZE = 1 ]; then
python3 "$SRC/tools/rom_seeds.py" "$ROM" "$AN/ghidra_seeds.txt" \
    --traps "$AN/trap_tables_runtime.txt" --trace "$AN/executed_pcs.txt" \
    --names "$SRC/traps/trap_table.c" \
    --hints "$AN/code_hints.txt"

analyzeHeadless "$WORK" q800 -import "$ROM" \
    -processor 68000:BE:32:default -loader BinaryLoader -loader-baseAddr 0x40800000 \
    -scriptPath "$SRC/tools/ghidra" \
    -preScript Q800Seed.java "$AN/ghidra_seeds.txt" aggressive \
    -postScript Q800ATraps.java "$AN/ghidra_atraps.txt" \
    -postScript Q800Export.java "$AN/ghidra_codemap.txt" > "$WORK/ghidra.log" 2>&1 \
    || { tail -30 "$WORK/ghidra.log"; exit 1; }
grep -E "Q800(Seed|ATraps|Export)\.java> Q800[A-Za-z]*: [0-9]" "$WORK/ghidra.log" | sed 's/^.*> /    /' | tail -3
fi

python3 "$SRC/tools/rom_disasm.py" "$ROM" "$AN/ghidra_codemap.txt,$AN/ghidra_atraps.txt" \
    "$AN/ghidra_seeds.txt" "$SRC/traps/trap_table.c" "$SRC/romsrc" \
    --rom-map "$AN/Quadra800ROM.lst"

# Names for the declaration ROM (sResources, drivers, video modes...): tools/declrom_names.py
# on the generated source, applied with tools/rename_labels.py; the result must still
# rebuild the same image.
AS=${M68K_AS:-/usr/m68k-suse-linux/bin/as}
LD=${M68K_LD:-/usr/m68k-suse-linux/bin/ld}
OBJCOPY=${M68K_OBJCOPY:-/usr/bin/m68k-suse-linux-objcopy}
build() {
    "$AS" -m68040 -I "$SRC/romsrc" -I "$SRC/romsrc/include" "$SRC/romsrc/q800rom.s" -o "$WORK/r.o"
    "$LD" -Ttext=0x40800000 -e 0x40800000 --no-warn-rwx-segments -o "$WORK/r.elf" "$WORK/r.o"
}
build
python3 "$SRC/tools/declrom_names.py" "$ROM" "$WORK/r.elf" > "$WORK/declrom.map"
python3 "$SRC/tools/rename_labels.py" "$WORK/declrom.map" "$SRC/romsrc" --locals "$WORK/r.elf"
build
"$OBJCOPY" -O binary --only-section=.text "$WORK/r.elf" "$WORK/r.bin"
python3 "$SRC/tools/rom_postlink.py" "$WORK/r.elf" "$WORK/r.bin" "$SRC/romsrc" > /dev/null
if [ "$(sha256sum < "$WORK/r.bin" | cut -d' ' -f1)" != "$(cut -d' ' -f1 "$SRC/romsrc/q800rom.sha256")" ]; then
    echo "declaration ROM names changed the image" >&2
    exit 1
fi
echo "[*] declaration ROM names applied; image unchanged"

# Fix-ups from the hand-maintained source (tools/export_fixups.py), checked to leave the
# image unchanged
if [ -f "$AN/romsrc_fixups.txt" ]; then
    TMPDIR="$WORK" python3 "$SRC/tools/apply_fixups.py" "$SRC/romsrc" "$ROM" "$AN/romsrc_fixups.txt"
fi
