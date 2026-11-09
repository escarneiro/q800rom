/* ROM resource 'mitq' 0: map entry at 0x40872D60, data at 0x40872D90, 12 bytes

 Inverse table queue sizes for Color QuickDraw (MakeITable work space for 3, 4 and 5 bit
 inverse tables).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_mitq_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40872D60
    .long   rsrc_wctb_0_entry-rom_start	| 40872D68
    .long   rsrc_mitq_0-rom_start	| 40872D6C
    .ascii  "mitq"	| 40872D70
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40872D74
    .long   0x00000000, 0xC0A00000, 0x00000018, 0x00000194	| 40872D80
rsrc_mitq_0:            /* the resource data */
    .long   0x000012A0, 0x00002200, 0x00003C00, 0x00000000	| 40872D90
