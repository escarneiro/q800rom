/* ROM resource 'wctb' 0: map entry at 0x40872D00, data at 0x40872D30, 48 bytes

 Default window colour table (colours of window frames and title bars).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_wctb_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40872D00
    .long   rsrc_cctb_0_entry-rom_start	| 40872D08
    .long   rsrc_wctb_0-rom_start	| 40872D0C
    .ascii  "wctb"	| 40872D10
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40872D14
    .long   0x00000000, 0xC0A00000, 0x0000003C, 0x0000019C	| 40872D20
rsrc_wctb_0:            /* the resource data */
    .long   0x00000000, 0x00000004, 0x0000FFFF, 0xFFFFFFFF	| 40872D30
    .long   0x00010000, 0x00000000, 0x00020000, 0x00000000	| 40872D40
    .long   0x00030000, 0x00000000, 0x0004FFFF, 0xFFFFFFFF	| 40872D50
