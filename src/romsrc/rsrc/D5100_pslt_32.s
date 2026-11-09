/* ROM resource 'pslt' 32: map entry at 0x408D5100, data at 0x408D5130, 12 bytes

 PDS slot table ('pslt' 32): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_32_entry:     /* map entry */
    .long   0x78000000, 0x00000000	| 408D5100
    .long   rsrc_DRVR_m16511__Backlight_entry-rom_start	| 408D5108
    .long   rsrc_pslt_32-rom_start	| 408D510C
    .ascii  "pslt"	| 408D5110
    .byte   0x00, 0x20, 0x58, 0x00	| 408D5114
    FILL_408D5118
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x04, 0x0C	| 408D5124
rsrc_pslt_32:           /* the resource data */
    .byte   0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01	| 408D5130
    FILL_408D513C
