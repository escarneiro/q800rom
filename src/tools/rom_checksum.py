#!/usr/bin/env python3
"""
rom_checksum.py - Macintosh Classic ROM Checksum Calculator and Patcher

Classic Macintosh ROMs (68000 through 68040) compute the 32-bit ROM checksum
by summing all 16-bit words from offset 0x00000004 to the end of the ROM:
    sum_16bit = sum(word_16) & 0xFFFFFFFF
The resulting 32-bit value is stored as a big-endian uint32_t at offset 0x00000000.
Before it, the four byte-lane sums at 0x30..0x3F are computed (fix_checksums).
"""

import sys
import struct
import os

def calculate_checksum(rom_bytes: bytes) -> int:
    """Calculates the 32-bit sum of all 16-bit words from offset 4 to len."""
    csum = 0
    # Process 2 bytes at a time
    for i in range(4, len(rom_bytes), 2):
        word = (rom_bytes[i] << 8) | rom_bytes[i + 1]
        csum = (csum + word) & 0xFFFFFFFF
    return csum

def fix_checksums(rom: bytearray) -> int:
    """Recomputes the ROM header checksums.

    0x30..0x3F: four byte-lane sums (sum of the bytes at offset % 4 == lane, excluding
    0x00..0x03 and 0x30..0x3F). 0x00: 32-bit sum of all 16-bit words from offset 4.
    Both formulas reproduce the original Quadra 800 ROM header.
    """
    lanes = [0, 0, 0, 0]
    for i, b in enumerate(rom):
        lanes[i & 3] += b
    for i in list(range(0, 4)) + list(range(0x30, 0x40)):
        lanes[i & 3] -= rom[i]
    struct.pack_into(">4I", rom, 0x30, *[x & 0xFFFFFFFF for x in lanes])
    csum = calculate_checksum(rom)
    struct.pack_into(">I", rom, 0, csum)
    return csum

def verify_checksum(rom_bytes: bytes) -> tuple:
    if len(rom_bytes) < 4:
        return False, 0, 0
    stored = struct.unpack(">I", rom_bytes[0:4])[0]
    computed = calculate_checksum(rom_bytes)
    return (stored == computed), stored, computed

def patch_checksum(file_path: str) -> int:
    with open(file_path, "rb") as f:
        rom = bytearray(f.read())

    if len(rom) != 1048576:
        print(f"Warning: ROM size is {len(rom)} bytes (expected 1048576 = 1MB).")

    csum = calculate_checksum(rom)
    struct.pack_into(">I", rom, 0, csum)

    with open(file_path, "wb") as f:
        f.write(rom)

    return csum

def main():
    if len(sys.argv) < 2:
        print("Usage: rom_checksum.py <rom_file> [--patch | --verify | --fix-all]")
        sys.exit(1)

    file_path = sys.argv[1]
    if "--fix-all" in sys.argv:
        with open(file_path, "rb") as f:
            rom = bytearray(f.read())
        csum = fix_checksums(rom)
        with open(file_path, "wb") as f:
            f.write(rom)
        print(f"Byte-lane sums and checksum 0x{csum:08X} written to {file_path}")
        return

    patch = "--patch" in sys.argv
    verify = "--verify" in sys.argv or not patch

    if not os.path.exists(file_path):
        print(f"Error: File not found: {file_path}")
        sys.exit(1)

    with open(file_path, "rb") as f:
        rom = f.read()

    is_valid, stored, computed = verify_checksum(rom)

    print(f"ROM File:         {file_path} ({len(rom)} bytes)")
    print(f"Stored Checksum:   0x{stored:08X}")
    print(f"Computed Checksum: 0x{computed:08X}")
    print(f"Status:            {'VALID' if is_valid else 'INVALID'}")

    if patch:
        new_csum = patch_checksum(file_path)
        print(f"Patched Checksum:  0x{new_csum:08X} written to offset 0.")

if __name__ == "__main__":
    main()
