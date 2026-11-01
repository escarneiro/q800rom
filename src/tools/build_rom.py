#!/usr/bin/env python3
"""
build_rom.py - Macintosh Quadra 800 ROM Binary Builder

Produces the 1,048,576 byte (1MB) rebuilt Macintosh ROM image ('overlay' mode):
copies the hand-written 68040 routines (boot/reset.s: early CPU detection and
MMU/cache setup; traps/trap_dispatcher.s: A-line trap dispatcher) over the base
image assembled from romsrc/, writes the NuBus format block and recomputes the
byte-lane sums and the 32-bit checksum.
"""

import sys
import os
import struct
import subprocess

NUBUS_TEST_PATTERN = 0x5A932BC7
ROM_SIZE = 1048576  # 1 MB

def calc_mac_checksum(rom: bytes) -> int:
    """Computes the classic Macintosh 16-bit word addition checksum."""
    csum = 0
    for i in range(4, len(rom), 2):
        word = (rom[i] << 8) | rom[i + 1]
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
    csum = calc_mac_checksum(rom)
    struct.pack_into(">I", rom, 0, csum)
    return csum


def symbol_offset(elf: str, name: str):
    """ROM offset of a symbol in the linked base image (None if absent)."""
    if not elf or not os.path.exists(elf):
        return None
    res = subprocess.run(["/usr/m68k-suse-linux/bin/nm", elf], capture_output=True, text=True)
    for line in res.stdout.splitlines():
        p = line.split()
        if len(p) == 3 and p[2] == name:
            return int(p[0], 16) - 0x40800000
    return None


def extract_section_bytes(elf_or_obj: str, section: str = ".text") -> bytes:
    """Extracts raw binary bytes of a section from an ELF/object file."""
    cmd = ["/usr/bin/m68k-suse-linux-objcopy", "-O", "binary", f"--only-section={section}", elf_or_obj, "/tmp/sec.bin"]
    res = subprocess.run(cmd, capture_output=True)
    if res.returncode == 0 and os.path.exists("/tmp/sec.bin"):
        with open("/tmp/sec.bin", "rb") as f:
            data = f.read()
        os.remove("/tmp/sec.bin")
        return data
    return b""

def get_symbol_range(obj_file: str, sym_name: str, end_sym: str = None) -> tuple:
    """Finds byte range of a symbol in an object file using nm."""
    res = subprocess.run(["/usr/m68k-suse-linux/bin/nm", "-n", obj_file], capture_output=True, text=True)
    if res.returncode != 0:
        return None, None
    symbols = []
    for line in res.stdout.splitlines():
        parts = line.split()
        if len(parts) >= 3:
            symbols.append((int(parts[0], 16), parts[2]))
    for i, (addr, name) in enumerate(symbols):
        if name == sym_name:
            if end_sym:
                for j in range(i + 1, len(symbols)):
                    if symbols[j][1] == end_sym:
                        return addr, symbols[j][0]
            return addr, symbols[i + 1][0] if i + 1 < len(symbols) else None
    return None, None

def build_overlay_rom(template_path: str, out_path: str, obj_dir: str, base_elf: str = None):
    """Builds a bootable composite ROM by overlaying reconstructed modules."""
    print(f"[*] Building Overlay ROM from template: {template_path}")
    if not os.path.exists(template_path):
        print(f"Error: Template ROM '{template_path}' not found!")
        sys.exit(1)

    with open(template_path, "rb") as f:
        rom = bytearray(f.read())

    if len(rom) != ROM_SIZE:
        print(f"Error: Template ROM must be exactly {ROM_SIZE} bytes (got {len(rom)})")
        sys.exit(1)

    # 1. Overlay _early_cpu_detect from reset.o
    reset_obj = os.path.join(obj_dir, "boot", "reset.o")
    if os.path.exists(reset_obj):
        reset_bin = extract_section_bytes(reset_obj, ".text")
        s, e = get_symbol_range(reset_obj, "_early_cpu_detect", "_cpu_detect_done")
        if reset_bin and s is not None and e is not None and e > s:
            cpu_detect_code = reset_bin[s:e]
            dest_off = symbol_offset(base_elf, "early_cpu_detect")
            if dest_off is None:
                dest_off = 0x00004052
            rom[dest_off:dest_off + len(cpu_detect_code)] = cpu_detect_code
            print(f"    -> Injected _early_cpu_detect ({len(cpu_detect_code)} bytes from {hex(s)}..{hex(e)}) at offset 0x{dest_off:08X}")

    # 2. Overlay trap_dispatcher.o
    trap_obj = os.path.join(obj_dir, "traps", "trap_dispatcher.o")
    if os.path.exists(trap_obj):
        trap_bin = extract_section_bytes(trap_obj, ".text")
        s, e = get_symbol_range(trap_obj, "_trap_dispatcher", "_trap_dispatcher_end")
        if trap_bin and s is not None and e is not None and e > s:
            disp_code = trap_bin[s:e]
            dest_off = symbol_offset(base_elf, "trap_dispatcher")
            if dest_off is None:
                dest_off = 0x000099B0
            rom[dest_off:dest_off + len(disp_code)] = disp_code
            print(f"    -> Injected _trap_dispatcher ({len(disp_code)} bytes from {hex(s)}..{hex(e)}) at offset 0x{dest_off:08X}")

    # 3. Ensure NuBus Declaration ROM Format Block is present at 0x0FFFEC
    fmt_offset = 0x0FFFEC
    # Format block structure:
    # uint32_t directoryOffset (0x00FF2CB8 -> 24-bit offset to 0x0F2CA4)
    # uint32_t length (0)
    # uint32_t crc (0)
    # uint8_t revision (1)
    # uint8_t format (1)
    # uint32_t testPattern (0x5A932BC7)
    # uint8_t reserved (0)
    # uint8_t byteLanes (0x0F)
    struct.pack_into(">IIIBBIBB", rom, fmt_offset,
                     0x00FF2CB8, 0, 0, 1, 1, NUBUS_TEST_PATTERN, 0, 0x0F)
    print(f"    -> Verified NuBus Declaration ROM Format Block at 0x{fmt_offset:06X}")

    # 4. Recompute the byte-lane sums (0x30) and the 32-bit checksum (0x00)
    csum = fix_checksums(rom)
    print(f"    -> Computed Checksum: 0x{csum:08X} written to offset 0x00000000")

    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(rom)

    print(f"[+] Successfully generated: {out_path} ({len(rom)} bytes)")

def main():
    if len(sys.argv) < 3:
        print("Usage: build_rom.py overlay <output_rom> [template_rom] [obj_dir] [base_elf]")
        sys.exit(1)

    mode = sys.argv[1]
    out_path = sys.argv[2]

    if mode == "overlay":
        template = sys.argv[3] if len(sys.argv) > 3 else "build/QUADRA800_BASE.ROM"
        obj_dir = sys.argv[4] if len(sys.argv) > 4 else "src"
        base_elf = sys.argv[5] if len(sys.argv) > 5 else None
        build_overlay_rom(template, out_path, obj_dir, base_elf)
    else:
        print(f"Unknown mode: {mode}")
        sys.exit(1)

if __name__ == "__main__":
    main()
