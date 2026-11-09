/* ROM resource 'KMAP' 2: map entry at 0x4087B310, data at 0x4087B340, 144 bytes

 Key map 2: from keyboard scan codes to virtual key codes.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_KMAP_2_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 4087B310
    .long   rsrc_KCAP_6_entry-rom_start	| 4087B318
    .long   rsrc_KMAP_2-rom_start	| 4087B31C
    .ascii  "KMAP"	| 4087B320
    .byte   0x00, 0x02, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087B324
    .long   0x00000000, 0xC0A00000, 0x0000009C, 0x000000C4	| 4087B330
rsrc_KMAP_2:            /* the resource data */
    .long   0x00020000, 0x00010203, 0x04050607, 0x08090A0B	| 4087B340
    .long   0x0C0D0E0F, 0x10111213, 0x14151617, 0x18191A1B	| 4087B350
    .long   0x1C1D1E1F, 0x20212223, 0x24252627, 0x28292A2B	| 4087B360
    .long   0x2C2D2E2F, 0x30313233, 0x34353B37, 0x38B93A7B	| 4087B370
    .long   0x7C7D7E3F, 0x40414243, 0x44454647, 0x48494A4B	| 4087B380
    .long   0x4C4D4E4F, 0x50515253, 0x54555657, 0x58595A5B	| 4087B390
    .long   0x5C5D5E5F, 0x60616263, 0x64656667, 0x68696A6B	| 4087B3A0
    .long   0x6C6D6E6F, 0x70717273, 0x74757677, 0x78797A3C	| 4087B3B0
    .long   0x3D3E367F, 0x0002390E, 0x020002B9, 0x0E020002	| 4087B3C0
