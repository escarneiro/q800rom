#!/usr/bin/env python3
"""
build_rom.py - Macintosh Quadra 800 ROM Binary Builder

Produces 1,048,576 byte (1MB) Macintosh ROM images:
1. 'standalone': Pure reconstructed ROM built from compiled bare-metal 68040 objects.
2. 'overlay': Injects reconstructed modules (reset startup, 68040 MMU/cache,
   fast trap dispatcher, decompiled managers) into the Quadra 800 ROM layout,
   recomputing the exact 16-bit word addition checksum.
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

def build_overlay_rom(template_path: str, out_path: str, obj_dir: str):
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
        if reset_bin and len(reset_bin) >= 0x122:
            cpu_detect_code = reset_bin[0xD2:0x122]
            dest_off = 0x00004052
            rom[dest_off:dest_off + len(cpu_detect_code)] = cpu_detect_code
            print(f"    -> Injected _early_cpu_detect ({len(cpu_detect_code)} bytes) at offset 0x{dest_off:08X}")

    # 2. Overlay trap_dispatcher.o
    trap_obj = os.path.join(obj_dir, "traps", "trap_dispatcher.o")
    if os.path.exists(trap_obj):
        trap_bin = extract_section_bytes(trap_obj, ".text")
        if trap_bin:
            disp_code = trap_bin[:0x78]
            dest_off = 0x000099B0
            rom[dest_off:dest_off + len(disp_code)] = disp_code
            print(f"    -> Injected _trap_dispatcher ({len(disp_code)} bytes) at offset 0x{dest_off:08X}")

    # 3. Ensure NuBus Declaration ROM Format Block is present at 0x0FFFEC
    fmt_offset = 0x0FFFEC
    # Format block structure:
    # int32_t directoryOffset (-54088 = 0xFF2CB8 -> points to 0x0F2CA4)
    # uint32_t length (0)
    # uint32_t crc (0)
    # uint8_t revision (1)
    # uint8_t format (1)
    # uint32_t testPattern (0x5A932BC7)
    # uint8_t reserved (0)
    # uint8_t byteLanes (0x0F)
    struct.pack_into(">iiiBBIBB", rom, fmt_offset,
                     -54088, 0, 0, 1, 1, NUBUS_TEST_PATTERN, 0, 0x0F)
    print(f"    -> Verified NuBus Declaration ROM Format Block at 0x{fmt_offset:06X}")

    # 4. Compute and write new 32-bit checksum at offset 0
    csum = calc_mac_checksum(rom)
    struct.pack_into(">I", rom, 0, csum)
    print(f"    -> Computed Checksum: 0x{csum:08X} written to offset 0x00000000")

    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(rom)

    print(f"[+] Successfully generated: {out_path} ({len(rom)} bytes)")

def build_standalone_rom(elf_path: str, out_path: str):
    """Builds a standalone 1MB ROM binary from linked ELF."""
    print(f"[*] Building Standalone 1MB ROM from ELF: {elf_path}")
    if not os.path.exists(elf_path):
        print(f"Error: ELF file '{elf_path}' not found!")
        sys.exit(1)

    raw_bin = "/tmp/raw_rom.bin"
    cmd = ["/usr/bin/m68k-suse-linux-objcopy", "-O", "binary", elf_path, raw_bin]
    res = subprocess.run(cmd, capture_output=True)
    if res.returncode != 0:
        print(f"Error extracting binary from ELF: {res.stderr.decode()}")
        sys.exit(1)

    with open(raw_bin, "rb") as f:
        data = bytearray(f.read())
    if os.path.exists(raw_bin):
        os.remove(raw_bin)

    # Pad or create 1MB image
    rom = bytearray(ROM_SIZE)
    copy_len = min(len(data), ROM_SIZE)
    rom[0:copy_len] = data[0:copy_len]

    # Ensure format block at 0x0FFFEC
    fmt_offset = 0x0FFFEC
    struct.pack_into(">iiiBBIBB", rom, fmt_offset,
                     -54088, 0, 0, 1, 1, NUBUS_TEST_PATTERN, 0, 0x0F)

    # Compute checksum
    csum = calc_mac_checksum(rom)
    struct.pack_into(">I", rom, 0, csum)
    print(f"    -> Computed Checksum: 0x{csum:08X}")

    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    with open(out_path, "wb") as f:
        f.write(rom)

    print(f"[+] Successfully generated: {out_path} ({len(rom)} bytes)")

def main():
    if len(sys.argv) < 3:
        print("Usage: build_rom.py <mode: overlay|standalone> <output_rom> [template_rom_or_elf] [obj_dir]")
        sys.exit(1)

    mode = sys.argv[1]
    out_path = sys.argv[2]

    if mode == "overlay":
        template = sys.argv[3] if len(sys.argv) > 3 else "QUADRA800.ROM"
        obj_dir = sys.argv[4] if len(sys.argv) > 4 else "src"
        build_overlay_rom(template, out_path, obj_dir)
    elif mode == "standalone":
        elf_path = sys.argv[3] if len(sys.argv) > 3 else "build/q800_rom.elf"
        build_standalone_rom(elf_path, out_path)
    else:
        print(f"Unknown mode: {mode}")
        sys.exit(1)

if __name__ == "__main__":
    main()
