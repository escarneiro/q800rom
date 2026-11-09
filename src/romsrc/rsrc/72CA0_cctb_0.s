/* ROM resource 'cctb' 0: map entry at 0x40872CA0, data at 0x40872CD0, 40 bytes

 Default control colour table (colours of buttons, check boxes and scroll bars).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_cctb_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40872CA0
    .long   rsrc_DRVR_4__Sony_entry-rom_start	| 40872CA8
    .long   rsrc_cctb_0-rom_start	| 40872CAC
    .ascii  "cctb"	| 40872CB0
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40872CB4
    .long   0x00000000, 0xC0A00000, 0x00000034, 0x000001A4	| 40872CC0
rsrc_cctb_0:            /* the resource data */
    .long   0x00000000, 0x00000003, 0x00000000, 0x00000000	| 40872CD0
    .long   0x0001FFFF, 0xFFFFFFFF, 0x00020000, 0x00000000	| 40872CE0
    .long   0x0003FFFF, 0xFFFFFFFF, 0x00000000, 0x00000000	| 40872CF0
