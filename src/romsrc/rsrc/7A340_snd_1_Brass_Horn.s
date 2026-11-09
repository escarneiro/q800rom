/* ROM resource 'snd ' 1 "Brass Horn": map entry at 0x4087A340, data at 0x4087A370, 2762 bytes

 The Brass Horn alert sound (sampled sound resource).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_snd__1_Brass_Horn_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 4087A340
    .long   rsrc_PACK_7_entry-rom_start	| 4087A348
    .long   rsrc_snd__1_Brass_Horn-rom_start	| 4087A34C
    .ascii  "snd "	| 4087A350
    .byte   0x00, 0x01	| 4087A354
    .ascii  "X\012Brass Horn\000\000"
    .long   0xC0A00000, 0x00000AD6, 0x000000DC	| 4087A364
rsrc_snd__1_Brass_Horn:  /* the resource data */
    .include "sound/alertsound.s"
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087AE3A
