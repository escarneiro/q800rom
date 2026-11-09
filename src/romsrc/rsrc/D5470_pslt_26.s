/* ROM resource 'pslt' 26: map entry at 0x408D5470, data at 0x408D54A0, 28 bytes

 PDS slot table ('pslt' 26): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_26_entry:     /* map entry */
    .long   0x78000000, 0x00000000	| 408D5470
    .long   rsrc_pslt_30_entry-rom_start	| 408D5478
    .long   rsrc_pslt_26-rom_start	| 408D547C
    .ascii  "pslt"	| 408D5480
    .byte   0x00, 0x1A, 0x58, 0x00	| 408D5484
    FILL_408D5488
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x00, 0x00, 0x03, 0xAC	| 408D5494
rsrc_pslt_26:           /* the resource data */
    .long   0x00050002, 0x00000000, 0x000A0001, 0x000B0002	| 408D54A0
    .byte   0x00, 0x0C, 0x00, 0x03, 0x00, 0x0D, 0x00, 0x04, 0x00, 0x0E, 0x00, 0x05	| 408D54B0
    FILL_408D54BC
