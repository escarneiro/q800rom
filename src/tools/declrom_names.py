#!/usr/bin/env python3
"""declrom_names.py - names for the labels of the motherboard declaration ROM.

The declaration ROM (0x408F0000 to the end of the ROM) is NuBus "slot resource" data in
the format documented in "Designing Cards and Drivers for the Macintosh Family" (chapter
8): lists of 4-byte entries (an ID byte and a 24-bit self-relative offset, or data),
ending with 0xFF. This walks the structure from the list at 0x408F2C94 (ID 1: the
directory the format block points to; IDs 0x7E and 0x7F: the Universal ROM's pools of
sResources for all supported machines) and names what it finds, using the IDs from the
book (Tables 8-3 to 8-6) and the names stored in the data itself (sRsrcName strings,
driver names, gamma table names).

Usage:  declrom_names.py ROM ELF > declrom.map
        (ELF: the linked ROM, for the current label names and addresses)
Output: one line per label to rename, "old new  # how the name was found";
        apply it with tools/rename_labels.py.
"""
import os
import re
import struct
import subprocess
import sys

ROM_BASE = 0x40800000
TOP = 0xF2C94                # list: 1 -> directory, 0x7E and 0x7F -> sResource pools

# Table 8-3, 8-5 (and video entries); data entries (no offset) are marked
SRSRC_IDS = {1: 'sRsrcType', 2: 'sRsrcName', 3: 'sRsrcIcon', 4: 'sRsrcDrvrDir', 5: 'sRsrcLoadRec',
             6: 'sRsrcBootRec', 7: 'sRsrcFlags', 8: 'sRsrcHWDevId', 10: 'MinorBaseOS',
             11: 'MinorLength', 12: 'MajorBaseOS', 13: 'MajorLength', 15: 'sRsrcCicn',
             16: 'sRsrcIcl8', 17: 'sRsrcIcl4', 32: 'BoardId', 33: 'PRAMInitData', 34: 'PrimaryInit',
             35: 'STimeOut', 36: 'VendorInfo', 38: 'SecondaryInit', 64: 'sGammaDir',
             65: 'sRsrcVidNames', 125: 'sVidAttributes', 126: 'sVidParmDir',
             128: 'OneBitMode', 129: 'TwoBitMode', 130: 'FourBitMode', 131: 'EightBitMode',
             132: 'SixteenBitMode', 133: 'ThirtyTwoBitMode'}
DATA_IDS = {7, 8, 32, 35, 125}     # word data, no offset (125: in video sResources)
DRVR_IDS = {1: 'sMacOS68000', 2: 'sMacOS68020', 3: 'sMacOS68030', 4: 'sMacOS68040'}    # Table 8-4
VENDOR_IDS = {1: 'VendorId', 2: 'SerialNum', 3: 'RevLevel', 4: 'PartNum', 5: 'Date'}    # Table 8-6
MODE_IDS = {1: 'mVidParams', 2: 'mTable', 3: 'mPageCnt', 4: 'mDevType'}
MODE_DATA = {3, 4}

rom = b''
names = {}                   # ROM offset -> (priority, name, how)


def s24(o):
    v = int.from_bytes(rom[o + 1:o + 4], 'big')
    return v - (1 << 24) if v & 0x800000 else v


def target(o):
    return o + s24(o)


def entries(o):
    out = []
    for k in range(256):
        if rom[o + 4 * k] == 0xFF:
            return out
        out.append((rom[o + 4 * k], o + 4 * k))
    raise ValueError('no end of list at 0x%X' % (ROM_BASE + o))


def cstr(o):
    e = rom.find(b'\0', o)
    s = rom[o:e]
    return s.decode('latin1') if 0 < e - o < 120 and all(32 <= c < 127 for c in s) else None


def ident(s):
    s = re.sub(r'[^A-Za-z0-9]+', '_', s).strip('_')
    return s


def short(name):
    for a, b in (('Display_Video_Apple_', 'Video_'), ('Network_Ethernet_Apple_', 'Ethernet_'),
                 ('Macintosh ', 'Mac')):
        name = name.replace(a, b)
    return ident(name.replace('\\', ''))


def put(o, name, prio, how):
    old = names.get(o)
    if old is None or prio > old[0]:
        names[o] = (prio, name, how)


def srsrc_name(o):
    for i, eo in entries(o):
        if i == 2:
            return cstr(target(eo))
    return None


def walk_drvr_dir(o, base):
    put(o, base + '_DrvrDir', 50, 'sRsrcDrvrDir list (Table 8-4)')
    for i, eo in entries(o):
        put(eo, '%s_DrvrDir_%s_entry' % (base, DRVR_IDS.get(i, 'id%02X' % i)), 40, 'driver directory entry')
        blk = target(eo)
        hdr = blk + 4                              # sBlock: length, then the 'DRVR' resource
        nl = rom[hdr + 0x12]
        dname = rom[hdr + 0x13:hdr + 0x13 + nl].decode('latin1')
        if not dname.startswith('.'):
            continue
        dn = 'DECL_DRVR_' + ident(dname)
        put(blk, dn, 60, "driver sBlock; name from its 'DRVR' header")
        put(hdr, dn + '_header', 55, "'DRVR' header")
        for k, part in enumerate(('Open', 'Prime', 'Control', 'Status', 'Close')):
            off = struct.unpack('>H', rom[hdr + 8 + 2 * k:hdr + 10 + 2 * k])[0]
            if off:
                put(hdr + off, '%s_%s' % (dn, part), 60, "'DRVR' header routine offset")


def walk_sexec(o, base, what):
    put(o, '%s_%s' % (base, what), 50, '%s sExec block' % what)
    code = o + 8 + struct.unpack('>i', rom[o + 8:o + 12])[0]
    put(code, '%s_%s_code' % (base, what), 50, '%s code (sExec code offset)' % what)


def walk_blocks_with_names(o, base, what, prio=45):
    put(o, '%s_%s' % (base, what), 50, '%s list' % what)
    for i, eo in entries(o):
        put(eo, '%s_%s_%02X_entry' % (base, what, i), 35, '%s entry' % what)
        blk = target(eo)
        # name: the first readable C string in the block (gamma tables, video names)
        nm = None
        for k in range(4, 12, 2):
            nm = cstr(blk + k)
            if nm and len(nm) > 2:
                break
            nm = None
        put(blk, '%s_%s_%02X%s' % (base, what, i, '_' + ident(nm) if nm else ''), prio,
            '%s block%s' % (what, ' (name from its data)' if nm else ''))


def walk_mode(o, base, mode):
    mb = '%s_%s' % (base, mode)
    put(o, mb, 50, 'video mode list (%s)' % mode)
    for i, eo in entries(o):
        n = MODE_IDS.get(i, 'id%02X' % i)
        put(eo, '%s_%s_entry' % (mb, n), 40, 'video mode entry')
        if i not in MODE_DATA:
            put(target(eo), '%s_%s_data' % (mb, n), 45, '%s data' % n)


def walk_srsrc(o, base):
    put(o, base, 70, 'sResource (name from its sRsrcName)')
    category = None
    for i, eo in entries(o):
        if i == 1:
            category = struct.unpack('>H', rom[target(eo):target(eo) + 2])[0]
    for i, eo in entries(o):
        n = SRSRC_IDS.get(i, 'id%02X' % i)
        if i >= 128 and category != 3:
            n = 'id%02X' % i          # IDs 128-254 are the card's own, except video modes
        if i in (125, 126) and category != 3:
            n = 'id%02X' % i
        put(eo, '%s_%s_entry' % (base, n), 40, 'sResource entry, ID %d' % i)
        if i in DATA_IDS:
            continue
        t = target(eo)
        if i == 1:
            cat, typ, sw, hw = struct.unpack('>4H', rom[t:t + 8])
            put(t, 'DECL_TYPE_%04X_%04X_%04X_%04X' % (cat, typ, sw, hw), 45,
                'sRsrcType: category, type, DrSW, DrHW')
        elif i == 2:
            put(t, 'DECL_NAME_' + ident(cstr(t) or base), 45, 'sRsrcName string')
        elif i == 4:
            walk_drvr_dir(t, base)
        elif i in (34, 38):
            walk_sexec(t, base, SRSRC_IDS[i])
        elif i == 36:
            put(t, base + '_VendorInfo', 50, 'VendorInfo list (Table 8-6)')
            for j, ve in entries(t):
                vn = VENDOR_IDS.get(j, 'id%02X' % j)
                put(ve, '%s_VendorInfo_%s_entry' % (base, vn), 40, 'VendorInfo entry')
                put(target(ve), '%s_%s' % (base, vn), 45, 'VendorInfo string')
        elif i == 64:
            walk_blocks_with_names(t, base, 'GammaDir')
        elif i == 65:
            walk_blocks_with_names(t, base, 'VidNames')
        elif i == 126 and category == 3:
            walk_blocks_with_names(t, base, 'VidParmDir', prio=40)
        elif 128 <= i <= 133 and category == 3:      # CatDisplay: video modes
            walk_mode(t, base, n)
        else:
            put(t, '%s_%s_data' % (base, n), 30, '%s data' % n)


def main():
    global rom
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    rom = open(sys.argv[1], 'rb').read()
    put(TOP, 'DECL_DIRECTORIES', 90, 'list before the directory: 1, 0x7E, 0x7F')
    for di, deo in entries(TOP):
        d = target(deo)
        dname = 'DECL_SRSRC_DIR' if di == 1 else 'DECL_POOL_%02X' % di
        put(deo, 'DECL_DIRECTORIES_%02X_entry' % di, 80, 'entry of the list before the directory')
        put(d, dname, 90, 'sResource directory' if di == 1 else 'Universal ROM sResource pool')
        for si, seo in entries(d):
            put(seo, '%s_%02X_entry' % (dname, si), 40, 'directory entry')
            t = target(seo)
            nm = srsrc_name(t)
            if nm is None:
                continue
            base = 'DECL_SR%s_%02X_%s' % ('' if di == 1 else '%02X' % di, si, short(nm))
            if t not in names or names[t][0] < 70:
                walk_srsrc(t, base)

    # labels currently at those places
    nm = subprocess.run([os.environ.get('M68K_NM', '/usr/m68k-suse-linux/bin/nm'), sys.argv[2]],
                        capture_output=True, text=True, check=True)
    labels = {}
    for line in nm.stdout.splitlines():
        f = line.split()
        if len(f) == 3:
            labels.setdefault(int(f[0], 16) - ROM_BASE, []).append(f[2])
    used, out = set(), []
    for o in sorted(names):
        prio, new, how = names[o]
        if new in used:
            new = '%s_%X' % (new, ROM_BASE + o)
        used.add(new)
        for old in labels.get(o, []):
            if re.match(r'^(dat|loc|sub|decl)_', old) and old != new:
                out.append('%s %s  # %s' % (old, new, how))
    print('# declrom_names.py: %d places named, %d labels to rename' % (len(names), len(out)))
    print('\n'.join(out))


if __name__ == '__main__':
    main()
