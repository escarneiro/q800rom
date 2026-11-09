/* ROM resource 'KMAP' 0: map entry at 0x4087B3D0, data at 0x4087B400, 134 bytes

 Key map 0: from keyboard scan codes to virtual key codes.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_KMAP_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 4087B3D0
    .long   rsrc_KMAP_2_entry-rom_start	| 4087B3D8
    .long   rsrc_KMAP_0-rom_start	| 4087B3DC
    .ascii  "KMAP"	| 4087B3E0
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087B3E4
    .long   0x00000000, 0xC0A00000, 0x00000092, 0x000000BC	| 4087B3F0
rsrc_KMAP_0:            /* the resource data */
    .long   0x00000000, 0x00010203, 0x04050607, 0x08090A0B	| 4087B400
    .long   0x0C0D0E0F, 0x10111213, 0x14151617, 0x18191A1B	| 4087B410
    .long   0x1C1D1E1F, 0x20212223, 0x24252627, 0x28292A2B	| 4087B420
    .long   0x2C2D2E2F, 0x30313233, 0x34353B37, 0x38393A7B	| 4087B430
    .long   0x7C7D7E3F, 0x40414243, 0x44454647, 0x48494A4B	| 4087B440
    .long   0x4C4D4E4F, 0x50515253, 0x54555657, 0x58595A5B	| 4087B450
    .long   0x5C5D5E5F, 0x60616263, 0x64656667, 0x68696A6B	| 4087B460
    .long   0x6C6D6E6F, 0x70717273, 0x74757677, 0x78797A3C	| 4087B470
    .long   0x3D3E367F, 0x00000000, 0x00000000, 0x00000000	| 4087B480
