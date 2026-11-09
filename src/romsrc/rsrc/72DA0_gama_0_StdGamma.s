/* ROM resource 'gama' 0 "StdGamma": map entry at 0x40872DA0, data at 0x40872DD0, 268 bytes

 The standard gamma table for video.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_gama_0_StdGamma_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40872DA0
    .long   rsrc_mitq_0_entry-rom_start	| 40872DA8
    .long   rsrc_gama_0_StdGamma-rom_start	| 40872DAC
    .ascii  "gama"	| 40872DB0
    .byte   0x00, 0x00, 0x58, 0x08	| 40872DB4
    .ascii  "StdGamma\000\000\000\000"
    .long   0xC0A00000, 0x00000118, 0x0000018C	| 40872DC4
rsrc_gama_0_StdGamma:   /* the resource data */
    .long   0x00000000, 0x00000001, 0x01000008, 0x0005090B	| 40872DD0
    .long   0x0E101315, 0x17191B1D, 0x1E202224, 0x2527282A	| 40872DE0
    .long   0x2C2D2F30, 0x31333436, 0x37383A3B, 0x3C3E3F40	| 40872DF0
    .long   0x42434445, 0x4748494A, 0x4B4D4E4F, 0x50515254	| 40872E00
    .long   0x55565758, 0x595A5B5C, 0x5E5F6061, 0x62636465	| 40872E10
    .long   0x66676869, 0x6A6B6C6D, 0x6E6F7071, 0x72737475	| 40872E20
    .long   0x76777879, 0x7A7B7C7D, 0x7E7F8081, 0x81828384	| 40872E30
    .long   0x85868788, 0x898A8B8C, 0x8C8D8E8F, 0x90919293	| 40872E40
    .long   0x94959596, 0x9798999A, 0x9B9B9C9D, 0x9E9FA0A1	| 40872E50
    .long   0xA1A2A3A4, 0xA5A6A6A7, 0xA8A9AAAB, 0xABACADAE	| 40872E60
    .long   0xAFB0B0B1, 0xB2B3B4B4, 0xB5B6B7B8, 0xB8B9BABB	| 40872E70
    .long   0xBCBCBDBE, 0xBFC0C0C1, 0xC2C3C3C4, 0xC5C6C7C7	| 40872E80
    .long   0xC8C9CACA, 0xCBCCCDCD, 0xCECFD0D0, 0xD1D2D3D3	| 40872E90
    .long   0xD4D5D6D6, 0xD7D8D9D9, 0xDADBDCDC, 0xDDDEDFDF	| 40872EA0
    .long   0xE0E1E1E2, 0xE3E4E4E5, 0xE6E7E7E8, 0xE9E9EAEB	| 40872EB0
    .long   0xECECEDEE, 0xEEEFF0F1, 0xF1F2F3F3, 0xF4F5F5F6	| 40872EC0
    .long   0xF7F8F8F9, 0xFAFAFBFC, 0xFCFDFEFF, 0x00000000	| 40872ED0
