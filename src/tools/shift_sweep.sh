#!/bin/sh
# shift_sweep.sh - traced shift tests (tools/shift_test.py --trace) every STEP bytes.
# Usage (from src/): tools/shift_sweep.sh OUTPUT [STEP [BYTES]]
# One line per point: where the padding went, the boot test and the trace comparison.
OUT=$1; STEP=${2:-0x4000}; N=${3:-0x40}
: > "$OUT"
a=$((0x40801000))
while [ $a -lt $((0x408EF000)) ]; do
  h=$(printf '0x%08X' $a)
  r=$(timeout 600 python3 tools/shift_test.py --at $h --bytes $N --trace 2>&1 |
      grep -E 'inserting|promoted|BOOT TEST|traces agree|divergence|ROM code run|another order|different code|failed|Error' | tr '\n' ' ')
  echo "$h $r" >> "$OUT"
  a=$((a + STEP))
done
