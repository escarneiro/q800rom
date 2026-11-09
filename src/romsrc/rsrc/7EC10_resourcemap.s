/*
 rsrc/7EC10_resourcemap.s - ROM resource map header and the space up to 0x40880000
 From the resource map (0x4087EC10). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 The ROM's resources (fonts, drivers, packages, definition procedures, pictures, colour
 tables, keyboard layouts, AppleTalk code...) form a linked list: the ROM header at +0x1A
 gives the offset of this map header, which gives the offset of the first entry. Each
 resource file in rsrc/ starts with its entry (inferred from the data):
   +0   8 bytes  machine mask: which machines the resource is for (a bit per group of
                 machines; the Resource Manager skips entries not meant for this one)
   +8   long     offset (from the ROM base) of the next entry, 0 at the end
   +12  long     offset of the resource data
   +16  4 chars  resource type
   +20  word     resource ID
   +22  byte     attributes (0x58: system heap, locked, protected)
   +23           name (Pascal string), padding
 The data is preceded by 16 bytes laid out like a Memory Manager block header of a 32-bit
 heap: a long 0, then tag 0xC0 and flags 0xA0 (locked, resource), the physical size (data
 + 12) and a relative handle. With it, the ROM data can be used through a handle like a
 resource read from disk (GetHandleSize, HGetState).
 After the map header comes the space up to 0x40880000 (zeros).
*/

rsrc_CURS_1_50:         /* the map header: offset of the first entry, then three words (0x0408, 1, 12: version and attributes, inferred) */
    .long   rsrc_CURS_1_entry-rom_start	| 4087EC10
    .short  0x0408, 0x0001, 0x000C	| 4087EC14
    .fill   0x3E6, 1, 0x00
rsrc_CURS_1_440:        /* (unused, zeros) */
    .fill   0xD74, 1, 0x00
rsrc_CURS_1_11B4:       /* (unused, zeros) */
    .fill   0x120, 1, 0x00
rsrc_CURS_1_12D4:       /* (unused, zeros) */
    .fill   0x16C, 1, 0x00
