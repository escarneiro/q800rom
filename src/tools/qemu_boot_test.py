#!/usr/bin/env python3
"""
qemu_boot_test.py - Headless boot smoke test for a Quadra 800 ROM image.

Boots the ROM in QEMU's q800 machine with no disks attached, waits, takes a
screenshot through the QEMU monitor and checks the screen. A ROM that gets
through POST, RAM sizing, video init and the Start Manager shows the grey
desktop with the blinking "no bootable disk" floppy icon; a dead ROM leaves the
screen black (or a solid single colour).

Usage: qemu_boot_test.py <rom> [seconds=12] [screenshot.ppm]
Exit status 0 = screen shows a real image (boot reached video/desktop), 1 = not.
"""

import os
import socket
import subprocess
import sys
import tempfile
import time


def read_ppm(path):
    with open(path, "rb") as f:
        data = f.read()
    # P6\n<w> <h>\n<max>\n<bytes>
    parts = data.split(b"\n", 3)
    w, h = map(int, parts[1].split())
    return w, h, parts[3]


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    rom = os.path.abspath(sys.argv[1])
    secs = float(sys.argv[2]) if len(sys.argv) > 2 else 12.0
    tmp = tempfile.mkdtemp(prefix="q800boot_")
    shot = os.path.abspath(sys.argv[3]) if len(sys.argv) > 3 else os.path.join(tmp, "screen.ppm")
    mon = os.path.join(tmp, "mon.sock")

    qemu = subprocess.Popen(
        ["qemu-system-m68k", "-M", "q800", "-m", "64", "-bios", rom,
         "-display", "none", "-g", "640x480x8",
         "-monitor", f"unix:{mon},server,nowait"],
        stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    try:
        time.sleep(secs)
        if qemu.poll() is not None:
            print("QEMU exited early:", qemu.stderr.read().decode(errors="replace"))
            sys.exit(1)
        s = socket.socket(socket.AF_UNIX)
        s.connect(mon)
        s.sendall(f"screendump {shot}\n".encode())
        time.sleep(1.5)
        s.sendall(b"info registers\n")
        time.sleep(0.5)
        s.settimeout(0.5)
        out = b""
        try:
            while True:
                chunk = s.recv(65536)
                if not chunk:
                    break
                out += chunk
        except socket.timeout:
            pass
        s.close()
    finally:
        qemu.kill()
        qemu.wait()

    for line in out.decode(errors="replace").splitlines():
        if line.startswith("PC") or " PC=" in line or line.startswith("D0"):
            print("   ", line.strip())

    w, h, px = read_ppm(shot)
    colours = {}
    for i in range(0, len(px), 3 * 7):          # sample pixels
        c = px[i:i + 3]
        colours[c] = colours.get(c, 0) + 1
    nonblack = sum(n for c, n in colours.items() if c != b"\x00\x00\x00")
    total = sum(colours.values())
    print(f"Screenshot {shot}: {w}x{h}, {len(colours)} distinct colours, "
          f"{100.0 * nonblack / total:.1f}% non-black")
    # The grey desktop is a 50% black/white dither; a dead ROM gives one solid colour.
    ok = len(colours) >= 2 and nonblack >= total * 0.2
    print("BOOT TEST:", "PASS (desktop/video reached)" if ok else "FAIL (no picture)")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
