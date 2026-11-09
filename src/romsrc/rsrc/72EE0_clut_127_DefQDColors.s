/* ROM resource 'clut' 127 "DefQDColors": map entry at 0x40872EE0, data at 0x40872F10, 72 bytes

 Colour table 127 "DefQDColors": the standard colours for that pixel depth.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_clut_127_DefQDColors_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40872EE0
    .long   rsrc_gama_0_StdGamma_entry-rom_start	| 40872EE8
    .long   rsrc_clut_127_DefQDColors-rom_start	| 40872EEC
    .ascii  "clut"	| 40872EF0
    .byte   0x00, 0x7F, 0x58, 0x0B	| 40872EF4
    .ascii  "DefQDColors\000"
    .long   0xC0A00000, 0x00000054, 0x00000184	| 40872F04
rsrc_clut_127_DefQDColors:  /* the resource data */
    .long   0x0000007F, 0x00000007, 0x00000000, 0x00000000	| 40872F10
    .long   0x0001FC00, 0xF37D052F, 0x0002F2D7, 0x085684EC	| 40872F20
    .long   0x0003DD6B, 0x08C206A2, 0x00040241, 0xAB54EAFF	| 40872F30
    .long   0x00050000, 0x64AF11B0, 0x00060000, 0x0000D400	| 40872F40
    .long   0x0007FFFF, 0xFFFFFFFF, 0x00000000, 0x00000000	| 40872F50
