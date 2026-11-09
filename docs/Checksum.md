# Quadra 800 ROM checksum: who checks it, and does Mac OS 8.1 care?

## Summary

* **The ROM verifies its own checksum on every boot.** `STARTUPROMTEST` computes the
  checksum and compares it with the value stored at offset 0. On a mismatch the ROM stops
  in its startup-failure path (error sound, Test Manager); the screen is never initialized.
* **Mac OS 8.1 does not check for a specific checksum value.** A ROM with a different but
  valid checksum boots Mac OS 8.1 to the Finder exactly like the original, and no System
  code reads the checksum during the boot.
* Consequence for this project: a modified ROM boots as long as its checksum is
  recomputed, which the build does automatically (`src/tools/rom_postlink.py`). The
  checksum is therefore not the reason why ROMs shifted below about `0x40840000` fail to
  boot Mac OS.

## The ROM header checksums

| Offset | Content | Original value |
|---|---|---|
| `0x00` | 32-bit sum of all 16-bit big-endian words from offset 4 to the end of the ROM | `0xF1ACAD13` |
| `0x30`-`0x3F` | Four byte-lane sums: for lane `L`, the sum of all bytes at offsets `i mod 4 = L`, excluding `0x00`-`0x03` and `0x30`-`0x3F` | |

The long at offset 0 is also what the 68040 loads as its initial supervisor stack pointer
at reset; the ROM sets up its own stack before using it.

## The ROM's own checks (static analysis)

Routine names are Apple's, from the MPW ROM map (`analysis/Quadra800ROM.lst`).

### `STARTUPROMTEST` (`0x40847A58`): runs on every boot

```
STARTUPROMTEST:
    moveq #0,%d0
    moveq #0,%d1
    lea   MYFIRSTPROC,%a0          | ROM start
    movel %a0@(64),%d3             | ROM size from the header (+0x40)
    subql #4,%d3
    movel %a0@+,%d4                | stored checksum (offset 0)
loop:
    movew %a0@+,%d0                | sum all 16-bit words from offset 4
    addl  %d0,%d1
    subql #2,%d3
    jbne  loop
    eorl  %d4,%d1                  | computed XOR stored
    jbeq  ok
    movew #-1,%d6                  | mismatch: failure flag
ok: jmp   %fp@
```

Its caller in the normal startup sequence (`0x408472B8`) is:

```
    movew #1,%d7
    jmp   STARTUPROMTEST
    tstl  %d6
    jbne  ERROR1HANDLER            | 0x4084A616
```

`ERROR1HANDLER` plays the error sound and enters Apple's Test Manager (`TMENTRY1`), which
polls the serial port (`GETCHAR`) for diagnostic commands. On real hardware this is the
"Chimes of Death" with no video.

### `ROMTEST` (`0x408479F6`): diagnostics only

`ROMTEST` recomputes the four byte-lane sums and compares them with `0x30`-`0x3F`. It is
only called from the ROM's diagnostic test sequence, not during a normal boot; it never
appears in the QEMU execution traces of normal boots (`analysis/executed_pcs.txt`).

## Experiments (Mac OS 8.1 in QEMU)

Setup: the Mac OS 8.1 VM (`qemu-system-m68k -M q800 -m 128`, `MacOS8.1.img`, NuBus
virtio declaration ROM), run headless with the disk opened in `-snapshot` mode and a copy
of the PRAM image.

### Test ROMs

One byte of unused filler was changed in the ROM source: the copyright banner text
"1989" became "1999" at `0x408F1804`. That area is a repeated banner that no code or table
references.

| ROM | Contents | Checksum at offset 0 |
|---|---|---|
| Original | unchanged | `0xF1ACAD13` (valid) |
| B | edited byte; checksum and byte-lane sums recomputed by the build | `0xF1ACAE14` (valid, different value) |
| C | same bytes as B, with the original checksum written back | `0xF1ACAD13` (stale: does not match the contents) |

ROM B differs from the original only at offsets `0x02`, `0x03` (checksum), `0x33` (byte-lane
sum) and `0xF1804` (the edited byte).

### Results

| ROM | Result after 120 s |
|---|---|
| Original | Mac OS 8.1 Finder desktop |
| B (new valid checksum) | Mac OS 8.1 Finder desktop, identical to the original |
| C (stale checksum) | Blank screen; the boot never gets past the ROM's startup tests |

An instruction trace of ROM C (`-d in_asm`) shows `STARTUPROMTEST` taking the mismatch
path (`movew #-1,%d6` at `0x40847A7E`), then `ERROR1HANDLER` (`0x4084A616`), an error beep,
and the Test Manager loop (`TMENTRY1` / `GETCHAR`). With ROMs B and the original, the
`movew #-1,%d6` instruction is never executed.

### Who reads the checksum during a Mac OS boot

QEMU's gdb stub was used to set read watchpoints on the checksum longword:
* at `0x40800000`;
* at all 16 of its 1 MB mirrors in `0x40000000`-`0x40FFFFFF`;
* at `0x00800000`.

The original ROM then booted to the Finder; gdb stayed attached for the whole 240 s run.
All reads came from ROM code and occurred in the first minute:

| PC | Routine | Address read | Meaning |
|---|---|---|---|
| `0x40847A6E` | `STARTUPROMTEST` | `0x40800000` | The checksum test (`%d4` = `0xF1ACAD13`) |
| `0x40870AAA` | unlabeled SWIM floppy code | `0x40800000` | `tstb (%a1)` with `%a1` = `ROMBase`: a dummy bus access for timing; the value is discarded |
| `0x40847850/52` (4 hits) | `MOD3TEST` | `0x00800000` | RAM test patterns; with 128 MB, `0x00800000` is RAM, not a ROM mirror |

No code running from RAM (the System, extensions, the Finder) read the checksum.

## Limits

* The tests cover booting to an idle Finder. Applications that display the ROM checksum
  (system profilers and similar utilities) were not run; they may read it, but nothing in
  the boot depends on its value.
* QEMU watchpoints work on logical addresses. A read through some other MMU mapping of the
  ROM would not be seen; Mac OS on the 68040 normally keeps the ROM at `0x40800000`.
