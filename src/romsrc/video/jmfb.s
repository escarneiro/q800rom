/*
 video/jmfb.s - JMFB video driver
 From JMFBDRVR (0x40895960). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the video driver interface in Designing Cards
 and Drivers), not taken from Apple.
 Video driver for the Macintosh Display Card 8*24 ("JMFB" hardware). a1 = the DCE, a2 =
 csParam, a3 = the driver's private storage: +0 current mode, +2 current page, +4
 base address, +12 gamma table, +16 flags (bit 8 32-bit addressing, 9/11/13 monitor
 and card variants, 10 alternate timing, 12 gray), +18 mode table, +24 card base
 address, +30 monitor sense flags. The card's registers are at +0x200000 from its base.
 Mode numbers start at 128 (1 bit) up to 132 (24 bit).
*/

/*
 JMFBDRVR: the 'DRVR' header (flags, offsets of Open 0xB6A, Control 0xDE0, Status
 0x1382, Close 0x1358), its name ".Display_Video_Apple_MDC", then the mode tables
 and raw code (the Open routine and the control call dispatch are still raw words).
*/
JMFBDRVR:
    .long   0x4C000000, 0x00000000, 0x0B6A0000, 0x0DE01382	| 40895960
    .byte   0x13, 0x58, 0x18	| 40895970
    .ascii  ".Display_Video_Apple_MDC\000"
    .long   0x01100703	| 4089598C
    .long   0x0100FF03, 0x0100FFFF, 0x00900120, 0x02400480	| 40895990
    .long   0x00000366, 0x00C02002, 0x00F80004, 0x00240003	| 408959A0
    .long   0x00000090, 0x011E0016, 0x001E0012, 0x00030000	| 408959B0
    .long   0x06CC004E, 0x00060006, 0x0000014C, 0x00C82002	| 408959C0
    .long   0x00FC0004, 0x00480003, 0x00000090, 0x011E001A	| 408959D0
    .long   0x001E000E, 0x00030000, 0x06CC004E, 0x00060006	| 408959E0
    .long   0x0000014C, 0x00D02002, 0x00FE0004, 0x00900003	| 408959F0
    .long   0x00000090, 0x011E001C, 0x001E000C, 0x00030000	| 40895A00
    .long   0x06CC004E, 0x00060006, 0x0000014C, 0x00D82002	| 40895A10
    .long   0x00FF0004, 0x01200003, 0x00000090, 0x011E001D	| 40895A20
    .long   0x001E000B, 0x00030000, 0x06CC004E, 0x00060006	| 40895A30
    .long   0x0000014C, 0x0E060200, 0xFF060200, 0xFFFF0050	| 40895A40
    .long   0x00A00140, 0x02800000, 0x036600A0	| 40895A50
    .long   0x000200F0 /* number, not an address (F4) */	| 40895A5C
    .long   0x00040014 /* number, not an address (F4) */	| 40895A60
    .long   0x00030000 /* number, not an address (F4) */	| 40895A64
    .long   0x00A0013E, 0x00120026	| 40895A68
    .long   0x00220003, 0x000006CC, 0x00540006, 0x00060000	| 40895A70
    .long   0x017800A8	| 40895A80
    .long   0x000200F8 /* number, not an address (F4) */	| 40895A84
    .long   0x00040028 /* number, not an address (F4) */	| 40895A88
    .long   0x00030000 /* number, not an address (F4) */	| 40895A8C
    .long   0x00A0013E, 0x001A0026, 0x001A0003, 0x000006CC	| 40895A90
    .long   0x00540006, 0x00060000, 0x017800B0	| 40895AA0
    .long   0x000200FC /* number, not an address (F4) */	| 40895AAC
    .long   0x00040050 /* number, not an address (F4) */	| 40895AB0
    .long   0x00030000 /* number, not an address (F4) */	| 40895AB4
    .byte   0x00, 0xA0, 0x01, 0x3E, 0x00, 0x1E, 0x00, 0x26, 0x00, 0x16, 0x00, 0x03, 0x00, 0x00, 0x06, 0xCC	| 40895AB8
    .byte   0x00, 0x54, 0x00, 0x06, 0x00, 0x06, 0x00, 0x00, 0x01, 0x78, 0x00, 0xB8, 0x00, 0x02, 0x00, 0xFE	| 40895AC8
    .byte   0x00, 0x04, 0x00, 0xA0, 0x00, 0x03, 0x00, 0x00, 0x00, 0xA0, 0x01, 0x3E, 0x00, 0x20, 0x00, 0x26	| 40895AD8
    .byte   0x00, 0x14, 0x00, 0x03, 0x00, 0x00, 0x06, 0xCC, 0x00, 0x54, 0x00, 0x06, 0x00, 0x06, 0x00, 0x00	| 40895AE8
    .byte   0x01, 0x78, 0x1A, 0x0C, 0x05, 0x02, 0x00, 0x0C, 0x05, 0x02, 0x00, 0xFF, 0x00, 0x50, 0x00, 0xA0	| 40895AF8
    .byte   0x01, 0x40, 0x02, 0x80, 0x0A, 0x00, 0x01, 0xE0	| 40895B08
JMFBDRVR_1B0:
    .byte   0x00, 0x80, 0x00, 0x82, 0x00, 0xE0, 0x00, 0x50, 0x00, 0x14, 0x00, 0x03, 0x00, 0x00, 0x01, 0x3A	| 40895B10
    .byte   0x02, 0x7E, 0x00, 0x34, 0x00, 0x3E, 0x00, 0x68, 0x00, 0x03, 0x00, 0x00, 0x03, 0xC0, 0x00, 0x4E	| 40895B20
    .byte   0x00, 0x06, 0x00, 0x06, 0x00, 0x04, 0x03, 0x20, 0x00, 0x88, 0x00, 0x82, 0x00, 0xF0, 0x00, 0x50	| 40895B30
    .byte   0x00, 0x28, 0x00, 0x03, 0x00, 0x00, 0x01, 0x2A, 0x02, 0x7E, 0x00, 0x44, 0x00, 0x3E, 0x00, 0x58	| 40895B40
    .byte   0x00, 0x03, 0x00, 0x00, 0x03, 0xC0, 0x00, 0x4E, 0x00, 0x06, 0x00, 0x06, 0x00, 0x04, 0x03, 0x20	| 40895B50
    .byte   0x00, 0x90, 0x00, 0x82, 0x00, 0xF8, 0x00, 0x50, 0x00, 0x50, 0x00, 0x03, 0x00, 0x00, 0x01, 0x22	| 40895B60
    .byte   0x02, 0x7E, 0x00, 0x4C, 0x00, 0x3E, 0x00, 0x50, 0x00, 0x03, 0x00, 0x00, 0x03, 0xC0, 0x00, 0x4E	| 40895B70
    .byte   0x00, 0x06, 0x00, 0x06, 0x00, 0x04, 0x03, 0x20, 0x00, 0x98, 0x00, 0x82, 0x00, 0xFC, 0x00, 0x50	| 40895B80
    .byte   0x00, 0xA0, 0x00, 0x03, 0x00, 0x00, 0x01, 0x1E, 0x02, 0x7E, 0x00, 0x50, 0x00, 0x3E, 0x00, 0x4C	| 40895B90
    .byte   0x00, 0x03, 0x00, 0x00, 0x03, 0xC0, 0x00, 0x4E, 0x00, 0x06, 0x00, 0x06, 0x00, 0x04, 0x03, 0x20	| 40895BA0
    .byte   0x00, 0x9A, 0x00, 0x86, 0x00, 0xFF, 0x00, 0x1E, 0x00, 0xF0, 0x00, 0x03, 0x00, 0x00, 0x01, 0x40	| 40895BB0
    .byte   0x02, 0x7E, 0x00, 0x53, 0x00, 0x3E, 0x00, 0x49, 0x00, 0x03, 0x00, 0x00, 0x03, 0xC0, 0x00, 0x4E	| 40895BC0
    .byte   0x00, 0x06, 0x00, 0x06, 0x00, 0x04, 0x03, 0x20, 0x29, 0x14, 0x09, 0x04, 0x00, 0x14, 0x09, 0x04	| 40895BD0
    .byte   0x01, 0xFF, 0x00, 0x40, 0x00, 0x80, 0x01, 0x00, 0x02, 0x00, 0x08, 0x00, 0x01, 0x80, 0x00, 0x80	| 40895BE0
    .byte   0x00, 0x82, 0x00, 0xE0, 0x00, 0x50, 0x00, 0x10, 0x00, 0x03, 0x00, 0x00, 0x01, 0x00, 0x01, 0xFE	| 40895BF0
    .byte   0x00, 0x24, 0x00, 0x1E, 0x00, 0x38, 0x00, 0x03, 0x00, 0x00, 0x03, 0x00, 0x00, 0x26, 0x00, 0x06	| 40895C00
    .byte   0x00, 0x02, 0x00, 0x04, 0x02, 0x60, 0x00, 0x88, 0x00, 0x82, 0x00, 0xF0, 0x00, 0x50, 0x00, 0x20	| 40895C10
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x00, 0x01, 0xFE, 0x00, 0x34, 0x00, 0x1E, 0x00, 0x28, 0x00, 0x03	| 40895C20
    .byte   0x00, 0x00, 0x03, 0x00, 0x00, 0x26, 0x00, 0x06, 0x00, 0x02, 0x00, 0x04, 0x02, 0x60, 0x00, 0x90	| 40895C30
    .byte   0x00, 0x82, 0x00, 0xF8, 0x00, 0x50, 0x00, 0x40, 0x00, 0x03, 0x00, 0x00, 0x01, 0x00, 0x01, 0xFE	| 40895C40
    .byte   0x00, 0x3C, 0x00, 0x1E, 0x00, 0x20, 0x00, 0x03, 0x00, 0x00, 0x03, 0x00, 0x00, 0x26, 0x00, 0x06	| 40895C50
    .byte   0x00, 0x02, 0x00, 0x04, 0x02, 0x60, 0x00, 0x98, 0x00, 0x82, 0x00, 0xFC, 0x00, 0x50, 0x00, 0x80	| 40895C60
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x00, 0x01, 0xFE, 0x00, 0x40, 0x00, 0x1E, 0x00, 0x1C, 0x00, 0x03	| 40895C70
    .byte   0x00, 0x00, 0x03, 0x00, 0x00, 0x26, 0x00, 0x06, 0x00, 0x02, 0x00, 0x04, 0x02, 0x60, 0x00, 0x9A	| 40895C80
    .byte   0x00, 0x86, 0x00, 0xFF, 0x00, 0x1E, 0x00, 0xC0, 0x00, 0x03, 0x00, 0x00, 0x01, 0x00, 0x01, 0xFE	| 40895C90
    .byte   0x00, 0x43, 0x00, 0x1E, 0x00, 0x19, 0x00, 0x03, 0x00, 0x00, 0x03, 0x00, 0x00, 0x26, 0x00, 0x06	| 40895CA0
    .byte   0x00, 0x02, 0x00, 0x04, 0x02, 0x60, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF	| 40895CB0
    .byte   0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x40	| 40895CC0
JMFBDRVR_1B0_1BC:
    .byte   0x00, 0x80, 0x81, 0x12, 0x00, 0xE0, 0x01, 0x00, 0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x60	| 40895CCC
    .byte   0x02, 0xFE, 0x00, 0x31, 0x00, 0x43, 0x00, 0x36, 0x00, 0x03, 0x00, 0x00, 0x02, 0x3F, 0x00, 0x28	| 40895CDC
    .byte   0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0x88, 0x81, 0x12, 0x00, 0xF0, 0x01, 0x00	| 40895CEC
    .byte   0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x50, 0x02, 0xFE, 0x00, 0x41, 0x00, 0x43, 0x00, 0x26	| 40895CFC
    .byte   0x00, 0x03, 0x00, 0x00, 0x02, 0x3F, 0x00, 0x28, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93	| 40895D0C
    .byte   0x00, 0x90, 0x81, 0x12, 0x00, 0xF8, 0x01, 0x00, 0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x48	| 40895D1C
    .byte   0x02, 0xFE, 0x00, 0x49, 0x00, 0x43, 0x00, 0x1E, 0x00, 0x03, 0x00, 0x00, 0x02, 0x3F, 0x00, 0x28	| 40895D2C
    .byte   0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0x98, 0x81, 0x12, 0x00, 0xFC, 0x01, 0x00	| 40895D3C
    .byte   0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x44, 0x02, 0xFE, 0x00, 0x4D, 0x00, 0x43, 0x00, 0x1A	| 40895D4C
    .byte   0x00, 0x03, 0x00, 0x00, 0x02, 0x3F, 0x00, 0x28, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93	| 40895D5C
    .byte   0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00	| 40895D6C
    .byte   0x04, 0x00, 0x00, 0x00, 0x02, 0x40	| 40895D7C
JMFBDRVR_1B0_272:
    .byte   0x00, 0xC1, 0x81, 0x32, 0x00, 0xF8, 0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40895D82
    .byte   0x0D, 0x09, 0x01, 0x00, 0x06, 0x04, 0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00	| 40895D92
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x60, 0x02, 0xFE, 0x00, 0x31, 0x00, 0x43, 0x00, 0x36, 0x00, 0x03	| 40895DA2
    .byte   0x00, 0x00, 0x02, 0x3F, 0x00, 0x28, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0xC9	| 40895DB2
    .byte   0x81, 0x32, 0x00, 0xFC, 0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x09	| 40895DC2
    .byte   0x01, 0x00, 0x06, 0x04, 0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03	| 40895DD2
    .byte   0x00, 0x00, 0x01, 0x50, 0x02, 0xFE, 0x00, 0x41, 0x00, 0x43, 0x00, 0x26, 0x00, 0x03, 0x00, 0x00	| 40895DE2
    .byte   0x02, 0x3F, 0x00, 0x28, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0xD1, 0x81, 0x32	| 40895DF2
    .byte   0x00, 0xFE, 0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x09, 0x01, 0x00	| 40895E02
    .byte   0x06, 0x04, 0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00	| 40895E12
    .byte   0x01, 0x48, 0x02, 0xFE, 0x00, 0x49, 0x00, 0x43, 0x00, 0x1E, 0x00, 0x03, 0x00, 0x00, 0x02, 0x3F	| 40895E22
    .byte   0x00, 0x28, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0xD9, 0x81, 0x32, 0x00, 0xFF	| 40895E32
    .byte   0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x09, 0x01, 0x00, 0x06, 0x04	| 40895E42
    .byte   0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x44	| 40895E52
    .byte   0x02, 0xFE, 0x00, 0x4D, 0x00, 0x43, 0x00, 0x1A, 0x00, 0x03, 0x00, 0x00, 0x02, 0x3F, 0x00, 0x28	| 40895E62
    .byte   0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00	| 40895E72
    .byte   0x00, 0xFF, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x0A, 0x00, 0x01, 0xE0	| 40895E82
JMFBDRVR_530:
    .byte   0x00, 0x80, 0x81, 0x12, 0x00, 0xE0, 0x01, 0x00, 0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x20	| 40895E90
    .byte   0x02, 0x7E, 0x00, 0x71, 0x00, 0x43, 0x00, 0x76, 0x00, 0x03, 0x00, 0x00, 0x02, 0x0F, 0x00, 0x58	| 40895EA0
    .byte   0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0x88, 0x81, 0x12, 0x00, 0xF0, 0x01, 0x00	| 40895EB0
    .byte   0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x10, 0x02, 0x7E, 0x00, 0x81, 0x00, 0x43, 0x00, 0x66	| 40895EC0
    .byte   0x00, 0x03, 0x00, 0x00, 0x02, 0x0F, 0x00, 0x58, 0x00, 0x05	| 40895ED0
    .long   0x0005005E /* number, not a label difference (was rsrc_DRVR_3__Sound_548-.) */	| 40895EDA
    .byte   0x01, 0x93, 0x00, 0x90, 0x81, 0x12, 0x00, 0xF8, 0x01, 0x00, 0x01, 0x00, 0x00, 0x03, 0x00, 0x00	| 40895EDE
    .byte   0x01, 0x08, 0x02, 0x7E, 0x00, 0x89, 0x00, 0x43, 0x00, 0x5E, 0x00, 0x03, 0x00, 0x00, 0x02, 0x0F	| 40895EEE
    .byte   0x00, 0x58, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0x98, 0x81, 0x12, 0x00, 0xFC	| 40895EFE
    .byte   0x01, 0x00, 0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x04, 0x02, 0x7E, 0x00, 0x8D, 0x00, 0x43	| 40895F0E
    .byte   0x00, 0x5A, 0x00, 0x03, 0x00, 0x00, 0x02, 0x0F, 0x00, 0x58, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E	| 40895F1E
    .byte   0x01, 0x93, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x04, 0x00, 0x04, 0x00	| 40895F2E
    .byte   0x04, 0x00, 0x04, 0x00, 0x0A, 0x00, 0x01, 0xE0	| 40895F3E
JMFBDRVR_530_B6:
    .byte   0x00, 0xC1, 0x81, 0x32, 0x00, 0xF8, 0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40895F46
    .byte   0x0D, 0x09, 0x01, 0x00, 0x06, 0x04, 0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00	| 40895F56
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x20, 0x02, 0x7E, 0x00, 0x71, 0x00, 0x43, 0x00, 0x76, 0x00, 0x03	| 40895F66
    .byte   0x00, 0x00, 0x02, 0x0F, 0x00, 0x58, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0xC9	| 40895F76
    .byte   0x81, 0x32, 0x00, 0xFC, 0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x09	| 40895F86
    .byte   0x01, 0x00, 0x06, 0x04, 0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03	| 40895F96
    .byte   0x00, 0x00, 0x01, 0x10, 0x02, 0x7E, 0x00, 0x81, 0x00, 0x43, 0x00, 0x66, 0x00, 0x03, 0x00, 0x00	| 40895FA6
    .byte   0x02, 0x0F, 0x00, 0x58, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0xD1, 0x81, 0x32	| 40895FB6
    .byte   0x00, 0xFE, 0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x09, 0x01, 0x00	| 40895FC6
    .byte   0x06, 0x04, 0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00	| 40895FD6
    .byte   0x01, 0x08, 0x02, 0x7E, 0x00, 0x89, 0x00, 0x43, 0x00, 0x5E, 0x00, 0x03, 0x00, 0x00, 0x02, 0x0F	| 40895FE6
    .byte   0x00, 0x58, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0xD9, 0x81, 0x32, 0x00, 0xFF	| 40895FF6
    .byte   0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x09, 0x01, 0x00, 0x06, 0x04	| 40896006
    .byte   0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x04	| 40896016
    .byte   0x02, 0x7E, 0x00, 0x8D, 0x00, 0x43, 0x00, 0x5A, 0x00, 0x03, 0x00, 0x00, 0x02, 0x0F, 0x00, 0x58	| 40896026
    .byte   0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x00, 0x9A, 0x81, 0x16, 0x00, 0xFF, 0x00, 0x00	| 40896036
    .byte   0x00, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x09, 0x01, 0x00, 0x06, 0x04, 0x00, 0x01	| 40896046
    .byte   0x01, 0x03, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x01, 0x02, 0x7E	| 40896056
    .byte   0x00, 0x90, 0x00, 0x43, 0x00, 0x57, 0x00, 0x03, 0x00, 0x00, 0x02, 0x0F, 0x00, 0x58, 0x00, 0x05	| 40896066
    .byte   0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF	| 40896076
    .byte   0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x0A, 0x00, 0x01, 0xE0	| 40896086
JMFBDRVR_530_202:
    .byte   0x00, 0x80, 0x81, 0x12, 0x00, 0xE0, 0x01, 0x00, 0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x36	| 40896092
    .byte   0x02, 0x7E, 0x00, 0x12, 0x00, 0x3A, 0x00, 0x3A, 0x00, 0x03, 0x00, 0x00, 0x01, 0xE0, 0x00, 0x21	| 408960A2
    .byte   0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0x88, 0x81, 0x12, 0x00, 0xF0, 0x01, 0x00	| 408960B2
    .byte   0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x26, 0x02, 0x7E, 0x00, 0x22, 0x00, 0x3A, 0x00, 0x2A	| 408960C2
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0xE0, 0x00, 0x21, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A	| 408960D2
    .byte   0x00, 0x90, 0x81, 0x12, 0x00, 0xF8, 0x01, 0x00, 0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x1E	| 408960E2
    .byte   0x02, 0x7E, 0x00, 0x2A, 0x00, 0x3A, 0x00, 0x22, 0x00, 0x03, 0x00, 0x00, 0x01, 0xE0, 0x00, 0x21	| 408960F2
    .byte   0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0x98, 0x81, 0x12, 0x00, 0xFC, 0x01, 0x00	| 40896102
    .byte   0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x1A, 0x02, 0x7E, 0x00, 0x2E, 0x00, 0x3A, 0x00, 0x1E	| 40896112
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0xE0, 0x00, 0x21, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A	| 40896122
    .byte   0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00	| 40896132
    .byte   0x04, 0x00, 0x0A, 0x00, 0x01, 0xE0	| 40896142
JMFBDRVR_530_2B8:
    .byte   0x00, 0xC1, 0x81, 0x32, 0x00, 0xF8, 0x00, 0x60, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00	| 40896148
    .byte   0x0C, 0x01, 0x02, 0x00, 0x07, 0x03, 0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00	| 40896158
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x36, 0x02, 0x7E, 0x00, 0x12, 0x00, 0x3A, 0x00, 0x3A, 0x00, 0x03	| 40896168
    .byte   0x00, 0x00, 0x01, 0xE0, 0x00, 0x21, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0xC9	| 40896178
    .byte   0x81, 0x32, 0x00, 0xFC, 0x00, 0x60, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00, 0x0C, 0x01	| 40896188
    .byte   0x02, 0x00, 0x07, 0x03, 0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03	| 40896198
    .byte   0x00, 0x00, 0x01, 0x26, 0x02, 0x7E, 0x00, 0x22, 0x00, 0x3A, 0x00, 0x2A, 0x00, 0x03, 0x00, 0x00	| 408961A8
    .byte   0x01, 0xE0, 0x00, 0x21, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0xD1, 0x81, 0x32	| 408961B8
    .byte   0x00, 0xFE, 0x00, 0x60, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00, 0x0C, 0x01, 0x02, 0x00	| 408961C8
    .byte   0x07, 0x03, 0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00	| 408961D8
    .byte   0x01, 0x1E, 0x02, 0x7E, 0x00, 0x2A, 0x00, 0x3A, 0x00, 0x22, 0x00, 0x03, 0x00, 0x00, 0x01, 0xE0	| 408961E8
    .byte   0x00, 0x21, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0xD9, 0x81, 0x32, 0x00, 0xFF	| 408961F8
    .byte   0x00, 0x60, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00, 0x0C, 0x01, 0x02, 0x00, 0x07, 0x03	| 40896208
    .byte   0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x1A	| 40896218
    .byte   0x02, 0x7E, 0x00, 0x2E, 0x00, 0x3A, 0x00, 0x1E, 0x00, 0x03, 0x00, 0x00, 0x01, 0xE0, 0x00, 0x21	| 40896228
    .byte   0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0x9A, 0x81, 0x16, 0x00, 0xFF, 0x00, 0x00	| 40896238
    .byte   0x00, 0xF0, 0x00, 0x1B, 0x00, 0xB0, 0x00, 0x00, 0x0C, 0x01, 0x02, 0x00, 0x07, 0x03, 0x00, 0x00	| 40896248
    .byte   0x00, 0x04, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x01, 0x1D, 0x02, 0x7E	| 40896258
    .byte   0x00, 0x2B, 0x00, 0x3A, 0x00, 0x21, 0x00, 0x03, 0x00, 0x00, 0x01, 0xE0, 0x00, 0x21, 0x00, 0x06	| 40896268
    .byte   0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF	| 40896278
    .byte   0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00, 0x0A, 0x00, 0x01, 0x80	| 40896288
JMFBDRVR_530_404:
    .byte   0x00, 0x80, 0x81, 0x12, 0x00, 0xE0, 0x01, 0x00, 0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xF4	| 40896294
    .byte   0x01, 0xFE, 0x00, 0x54, 0x00, 0x3A, 0x00, 0x78, 0x00, 0x03, 0x00, 0x00, 0x01, 0xB0, 0x00, 0x51	| 408962A4
    .byte   0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0x88, 0x81, 0x12, 0x00, 0xF0, 0x01, 0x00	| 408962B4
    .byte   0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xE4, 0x01, 0xFE, 0x00, 0x64, 0x00, 0x3A, 0x00, 0x68	| 408962C4
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0xB0, 0x00, 0x51, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A	| 408962D4
    .byte   0x00, 0x90, 0x81, 0x12, 0x00, 0xF8, 0x01, 0x00, 0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xDC	| 408962E4
    .byte   0x01, 0xFE, 0x00, 0x6C, 0x00, 0x3A, 0x00, 0x60, 0x00, 0x03, 0x00, 0x00, 0x01, 0xB0, 0x00, 0x51	| 408962F4
    .byte   0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0x98, 0x81, 0x12, 0x00, 0xFC, 0x01, 0x00	| 40896304
    .byte   0x01, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xD8, 0x01, 0xFE, 0x00, 0x70, 0x00, 0x3A, 0x00, 0x5C	| 40896314
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0xB0, 0x00, 0x51, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A	| 40896324
    .byte   0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x04, 0x00, 0x04, 0x00, 0x04, 0x00	| 40896334
    .byte   0x04, 0x00, 0x0A, 0x00, 0x01, 0x80	| 40896344
JMFBDRVR_530_4BA:
    .byte   0x00, 0xC1, 0x81, 0x32, 0x00, 0xF8, 0x00, 0x60, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00	| 4089634A
    .byte   0x0C, 0x01, 0x02, 0x00, 0x07, 0x03, 0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00	| 4089635A
    .byte   0x00, 0x03, 0x00, 0x00, 0x00, 0xF4, 0x01, 0xFE, 0x00, 0x54, 0x00, 0x3A, 0x00, 0x78, 0x00, 0x03	| 4089636A
    .byte   0x00, 0x00, 0x01, 0xB0, 0x00, 0x51, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0xC9	| 4089637A
    .byte   0x81, 0x32, 0x00, 0xFC, 0x00, 0x60, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00, 0x0C, 0x01	| 4089638A
    .byte   0x02, 0x00, 0x07, 0x03, 0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03	| 4089639A
    .byte   0x00, 0x00, 0x00, 0xE4, 0x01, 0xFE, 0x00, 0x64, 0x00, 0x3A, 0x00, 0x68, 0x00, 0x03, 0x00, 0x00	| 408963AA
    .byte   0x01, 0xB0, 0x00, 0x51, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0xD1, 0x81, 0x32	| 408963BA
    .byte   0x00, 0xFE, 0x00, 0x60, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00, 0x0C, 0x01, 0x02, 0x00	| 408963CA
    .byte   0x07, 0x03, 0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00	| 408963DA
    .byte   0x00, 0xDC, 0x01, 0xFE, 0x00, 0x6C, 0x00, 0x3A, 0x00, 0x60, 0x00, 0x03, 0x00, 0x00, 0x01, 0xB0	| 408963EA
    .byte   0x00, 0x51, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0xD9, 0x81, 0x32, 0x00, 0xFF	| 408963FA
    .byte   0x00, 0x60, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00, 0x0C, 0x01, 0x02, 0x00, 0x07, 0x03	| 4089640A
    .byte   0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xD8	| 4089641A
    .byte   0x01, 0xFE, 0x00, 0x70, 0x00, 0x3A, 0x00, 0x5C, 0x00, 0x03, 0x00, 0x00, 0x01, 0xB0, 0x00, 0x51	| 4089642A
    .byte   0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x00, 0x9A, 0x81, 0x16, 0x00, 0xFF, 0x00, 0x00	| 4089643A
    .byte   0x00, 0xF0, 0x00, 0x1B, 0x00, 0xB0, 0x00, 0x00, 0x0C, 0x01, 0x02, 0x00, 0x07, 0x03, 0x00, 0x00	| 4089644A
    .byte   0x00, 0x04, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0xD5, 0x01, 0xFE	| 4089645A
    .byte   0x00, 0x73, 0x00, 0x3A, 0x00, 0x59, 0x00, 0x03, 0x00, 0x00, 0x01, 0xB0, 0x00, 0x51, 0x00, 0x06	| 4089646A
    .byte   0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A	| 4089647A
JMFBDRVR_B20:           /* copyright string, then: number of pages... per mode (indexed by mode-128) */
    .byte   0x01, 0x03, 0x0F, 0xFF, 0xFF	| 40896480
    .ascii  "Software by Casey King, Hardware by James Lundblad and Mohammed Sritip$"	| 40896485
    .byte   0xA4, 0x40, 0x70, 0x24	| 408964CC
    .short  0xA722	| 408964D0
    bnew JMFBDRVR_DD0_C
    movel %a0,%a1@(20)
    _HLock
    movel %a0@,%d0
    _StripAddress
    moveal %d0,%a3
    movel #-268435456,%d1
    moveb %a1@(40),%d0
    bfins %d0,%d1,4,4
    moveal %d1,%a0
    movel %a0,%a3@(24)
    movel %a0,%sp@-
    subaw #56,%sp
    moveal %sp,%a0
    moveb %d0,%a0@(49)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0
    _SlotManager
    cmpib #0,%sp@(6)
    beqs JMFBDRVR_B20_98
    bset #12,%a3@(30)
JMFBDRVR_B20_98:
    lea %sp@(64),%sp
    moveal %sp@+,%a0
    moveb %a1@(41),%d3
    btst #4,%d3
    bnes JMFBDRVR_B20_AE
    bset #8,%a3@(16)
JMFBDRVR_B20_AE:
    btst #5,%d3
    bnes JMFBDRVR_B20_BA
    bset #13,%a3@(16)
JMFBDRVR_B20_BA:
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%sp@-
    movel #2097152,%d0
    bfextu %a0@(0x0,%d0:l),20,3,%d1
    cmpib #7,%d1
    bnes JMFBDRVR_B20_EE
    movel %d0,%d1
    movel %a1,%sp@-
    moveal %a0,%a1
    bsrw JMFBDRVR_151C_A_6
    moveal %sp@+,%a1
    cmpib #20,%d0
    bnes JMFBDRVR_B20_EA
    moveb #4,%d1
    bras JMFBDRVR_B20_F8
JMFBDRVR_B20_EA:
    clrb %d1
    bras JMFBDRVR_B20_F8
JMFBDRVR_B20_EE:
    cmpib #0,%d1
    bnes JMFBDRVR_B20_F8
    moveb #7,%d1
JMFBDRVR_B20_F8:
    movew %sp@+,%d0
    _SwapMMUMode
    btst #0,%d1
    beqs JMFBDRVR_B20_11A
    bset #9,%a3@(16)
    bclr #2,%d1
    bnes JMFBDRVR_B20_11A
    bset #15,%a3@(16)
    bset #12,%a3@(16)
JMFBDRVR_B20_11A:
    movel %d1,%d0
    cmpiw #7,%d0
    bhiw JMFBDRVR_DD0_C
    movew %pc@(JMFBDRVR_B20_12C,%d0:w:2),%d0
    jmp %pc@(JMFBDRVR_B20_12C,%d0:w)
JMFBDRVR_B20_12C:
    orib #40,%a0@(0x18,%d0:w)
    orib #56,%a0@-
    orib #16,%a0@(32)
    lea %pc@(JMFBDRVR_1B0),%a0
    braw JMFBDRVR_B20_1E0
    .short  0x41FA, 0xF628	| lea %pc@(40895bee <JMFBDRVR+0x28e>),%a0
    braw JMFBDRVR_B20_1E0
    .short  0x41FA, 0xF3D6	| lea %pc@(408959a4 <JMFBDRVR+0x44>),%a0
    braw JMFBDRVR_B20_1E0
    .short  0x41FA, 0xF484	| lea %pc@(40895a5a <JMFBDRVR+0xfa>),%a0
    braw JMFBDRVR_B20_1E0
    bset #13,%a3@(30)
    bras JMFBDRVR_B20_16A
    bclr #13,%a3@(30)
JMFBDRVR_B20_16A:
    bset #11,%a3@(16)
    btst #3,%d3
    bnes JMFBDRVR_B20_17C
    bset #15,%a3@(30)
JMFBDRVR_B20_17C:
    btst #13,%a3@(16)
    beqs JMFBDRVR_B20_1B0
    btst #15,%a3@(30)
    bnes JMFBDRVR_B20_19E
    cmpib #4,%d1
    beqs JMFBDRVR_B20_198
    lea %pc@(JMFBDRVR_1B0_1BC),%a0	| 40896612
    bras JMFBDRVR_B20_1E0
JMFBDRVR_B20_198:
    lea %pc@(JMFBDRVR_530_202),%a0	| 40896618
    bras JMFBDRVR_B20_1E0
JMFBDRVR_B20_19E:
    cmpib #4,%d1
    beqs JMFBDRVR_B20_1AA
    lea %pc@(JMFBDRVR_530),%a0
    bras JMFBDRVR_B20_1E0
JMFBDRVR_B20_1AA:
    lea %pc@(JMFBDRVR_530_404),%a0	| 4089662A
    bras JMFBDRVR_B20_1E0
JMFBDRVR_B20_1B0:
    bset #14,%a3@(30)
    btst #15,%a3@(30)
    bnes JMFBDRVR_B20_1D0
    cmpib #4,%d1
    beqs JMFBDRVR_B20_1CA
    lea %pc@(JMFBDRVR_1B0_272),%a0	| 40896644
    bras JMFBDRVR_B20_1E0
JMFBDRVR_B20_1CA:
    lea %pc@(JMFBDRVR_530_2B8),%a0	| 4089664A
    bras JMFBDRVR_B20_1E0
JMFBDRVR_B20_1D0:
    cmpib #4,%d1
    beqs JMFBDRVR_B20_1DC
    lea %pc@(JMFBDRVR_530_B6),%a0	| 40896656
    bras JMFBDRVR_B20_1E0
JMFBDRVR_B20_1DC:
    lea %pc@(JMFBDRVR_530_4BA),%a0	| 4089665C
JMFBDRVR_B20_1E0:
    movel %a0,%a3@(18)
    movew %d1,%a3@(28)
    bclr #3,%d3
    bclr #4,%d3
    bclr #5,%d3
    subaw #56,%sp
    moveq #16,%d0
    .short  0xA71E	| 4089667A _NewPtr (flags 0x0700)
    bnew JMFBDRVR_DD0_2
    movel %a0,%a3@(8)
    bsrw JMFBDRVR_12D0
    bnew JMFBDRVR_DD0_2
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrw %a0@(50)
    clrb %a0@(48)
    movew #3,%a0@(40)
    movew #1,%a0@(42)
    movew #1,%a0@(44)
    movew #25,%a0@(46)
    clrb %a0@(52)
    moveq #21,%d0
    _SlotManager
    moveb #64,%a0@(50)
    moveq #6,%d0
    _SlotManager
    .short  0x117C, 0x0080, 0x0032	| moveb #-128,%a0@(50)
    moveq #5,%d0
    _SlotManager
    bnes JMFBDRVR_B20_26E
    moveal %a0@,%a0
    movel %a0,%a3@(32)
    addqw #2,%a0
JMFBDRVR_B20_25A:
    tstb %a0@+
    bnes JMFBDRVR_B20_25A
    addqw #1,%a0
    movel %a0,%d0
    andil #-2,%d0
    movel %d0,%a3@(12)
    bras JMFBDRVR_B20_2AA
JMFBDRVR_B20_26E:
    moveq #12,%d0
    addiw #256,%d0
    .short  0xA71E	| 408966F4 _NewPtr (flags 0x0700)
    bnes JMFBDRVR_DD0_2
    movel %a0,%a3@(32)
    movel %a0,%a3@(12)
    movew #25,%a0@(2)
    movew #1,%a0@(6)
    movew #256,%a0@(8)
    movew #8,%a0@(10)
    lea %a0@(12),%a0
    movew #255,%d0
    moveq #0,%d1
JMFBDRVR_B20_2A2:
    moveb %d1,%a0@+
    addqw #1,%d1
    dbf %d0,JMFBDRVR_B20_2A2
JMFBDRVR_B20_2AA:
    lea %sp@(56),%sp
    moveq #0,%d0
JMFBDRVR_DD0:           /* rts / return -23 (openErr) */
    rts
JMFBDRVR_DD0_2:
    moveal %a1@(20),%a0	| 40896732
    _DisposHandle
    lea %sp@(56),%sp
JMFBDRVR_DD0_C:
    moveq #-23,%d0
    jbra JMFBDRVR_DD0
    movel %a0,%sp@-
    movel %a1,%d0
    _StripAddress
    moveal %d0,%a1
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    movel %a0@(28),%d0
    _StripAddress
    moveal %d0,%a2
    movew %a0@(26),%d0
    cmpiw #9,%d0
    bhis JMFBDRVR_E20
    movew %pc@(JMFBDRVR_DD0_3C,%d0:w:2),%d0
    jmp %pc@(JMFBDRVR_DD0_3C,%d0:w)
JMFBDRVR_DD0_3C:
    orib #24,%a0@-
    oriw #202,%d6
    andiw #942,%a0@
    subiw #1138,%a4@
    movepw %a4@(1312),%d2
JMFBDRVR_E20:           /* Control: controlErr (-17) */
    moveq #-17,%d0
    jbra JMFBDRVR_E26

JMFBDRVR_E24:           /* Control: noErr */
    moveq #0,%d0
JMFBDRVR_E26:           /* Control: done (IODone unless immediate). Then control handlers: SetMode... */
    moveal %sp@+,%a0
    jbra JMFBDRVR_151C
    .long   0x34BC0080	| 4089678C
    .short  0x36BC, 0x0080, 0x323C, 0x0001, 0x7800, 0x3544, 0x0006	| 40896790
    jbsr JMFBDRVR_1698
    jbsr JMFBDRVR_17FA
    movel %a3@(4),%a2@(8)
    jbsr JMFBDRVR_18EE
    jbra JMFBDRVR_E24
    .short  0x3212, 0x6100, 0x0742, 0x66C6, 0x302A, 0x0006, 0x3800	| 408967B2
    .long   0x610007B2, 0x66BA3412, 0xB453675C, 0x3692206B	| 408967C0
    .long   0x000C3628, 0x00043428, 0x0008E24A, 0x41E8000C	| 408967D0
    .long   0xD0C31630, 0x2000206B, 0x0018D1FC, 0x00200204	| 408967E0
    .long   0x7001A05D, 0x3F0040E7, 0x7007C017, 0x55406C08	| 408967F0
    .long   0x007C0200, 0x027CFAFF, 0x610007A8, 0x42A8FFFC	| 40896800
    .long   0x343C00FF, 0x20832083, 0x208351CA, 0xFFF846DF	| 40896810
    .long   0x301FA05D	| 40896820
    jbsr JMFBDRVR_1698
    jbsr JMFBDRVR_17FA
    movel %a3@(4),%a2@(8)
    jbra JMFBDRVR_E24
    movel %a2@,%d0
    beqw JMFBDRVR_E20
    btst #10,%a3@(16)
    bnew JMFBDRVR_E20
JMFBDRVR_E26_C0:
    moveml %d4-%d7/%a4-%fp,%sp@-
    movew %a3@(16),%d5
    moveal %a3@(12),%a0
    lea %a0@(12),%a4
    addaw %a0@(4),%a4
    moveal %a4,%a5
    moveal %a4,%fp
    movew %a0@(10),%d7
    cmpiw #1,%a0@(6)
    beqs JMFBDRVR_E26_F6
    movew %a0@(8),%d0
    movew %d7,%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %d1,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
JMFBDRVR_E26_F6:
    movew %a3@,%d1
    subiw #128,%d1
    lea %pc@(JMFBDRVR_B20),%a3
    moveq #0,%d6
    moveb %a3@(0x0,%d1:w),%d6
    movew %a2@(6),%d3
    cmpw %d6,%d3
    bhiw JMFBDRVR_E26_1DC
    movew %a2@(4),%d0
    addqw #1,%d0
    bmiw JMFBDRVR_E26_1DC
    movel %sp,%d1
    movel %d1,%d0
    negw %d0
    andiw #3,%d0
    beqs JMFBDRVR_E26_128
    subaw %d0,%sp
JMFBDRVR_E26_128:
    movel %d1,%sp@-
    movel %d3,%d4
    addqw #1,%d4
    aslw #2,%d4
    subaw %d4,%sp
    moveal %sp,%a0
    movel %a2@,%d0
    _StripAddress
    moveal %d0,%a3
JMFBDRVR_E26_13A:
    bsrw JMFBDRVR_E26_1E4
    movel %d2,%a0@+
    dbf %d3,JMFBDRVR_E26_13A
    movew %a2@(6),%d3
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%d1
    movew %sr,%d6
    moveq #7,%d0
    rorw #8,%d6
    andb %d6,%d0
    rolw #8,%d6
    subqw #2,%d0
    bges JMFBDRVR_E26_16E
    oriw #512,%sr
    andiw #-1281,%sr
JMFBDRVR_E26_16E:
    bsrw JMFBDRVR_1652
    moveal %a3@(24),%a3
    addal #2097668,%a3
    movew %a2@(4),%d7
    bpls JMFBDRVR_E26_1A8
JMFBDRVR_E26_182:
    movel %sp@+,%d2
    movel %d2,%a3@(-4)
    lsrl #8,%d2
    btst #12,%d5
    beqs JMFBDRVR_E26_198
    clrl %a3@
    clrl %a3@
    movel %d2,%a3@
    bras JMFBDRVR_E26_1A2
JMFBDRVR_E26_198:
    movel %d2,%a3@
    lsrl #8,%d2
    movel %d2,%a3@
    lsrl #8,%d2
    movel %d2,%a3@
JMFBDRVR_E26_1A2:
    dbf %d3,JMFBDRVR_E26_182
    bras JMFBDRVR_E26_1CC
JMFBDRVR_E26_1A8:
    movel %d7,%a3@(-4)
JMFBDRVR_E26_1AC:
    movel %sp@+,%d2
    lsrl #8,%d2
    btst #12,%d5
    beqs JMFBDRVR_E26_1BE
    clrl %a3@
    clrl %a3@
    movel %d2,%a3@
    bras JMFBDRVR_E26_1C8
JMFBDRVR_E26_1BE:
    movel %d2,%a3@
    lsrl #8,%d2
    movel %d2,%a3@
    lsrl #8,%d2
    movel %d2,%a3@
JMFBDRVR_E26_1C8:
    dbf %d3,JMFBDRVR_E26_1AC
JMFBDRVR_E26_1CC:
    movew %d1,%d0
    _SwapMMUMode
    movew %d6,%sr
    moveal %sp@+,%sp
    moveml %sp@+,%d4-%d7/%a4-%fp
    braw JMFBDRVR_E24
JMFBDRVR_E26_1DC:
    moveml %sp@+,%d4-%d7/%a4-%fp
    braw JMFBDRVR_E20
JMFBDRVR_E26_1E4:
    movel %d3,%sp@-
    movew %a3@+,%d3
    movew %a3@+,%d0
    movew %a3@+,%d1
    movew %a3@+,%d2
    tstw %d5
    bpls JMFBDRVR_E26_212
    btst #10,%d5
    bnes JMFBDRVR_E26_212
    muluw #19660,%d0
    muluw #-26870,%d1
    muluw #7209,%d2
    addl %d1,%d0
    addl %d2,%d0
    bfextu %d0,0,%d7,%d1
    movew %d1,%d0
    movew %d1,%d2
    bras JMFBDRVR_E26_21E
JMFBDRVR_E26_212:
    bfextu %d0,16,%d7,%d0
    bfextu %d1,16,%d7,%d1
    bfextu %d2,16,%d7,%d2
JMFBDRVR_E26_21E:
    moveb %fp@(0x0,%d2:w),%d2
    lsll #8,%d2
    moveb %a5@(0x0,%d1:w),%d2
    lsll #8,%d2
    moveb %a4@(0x0,%d0:w),%d2
    lsll #8,%d2
    moveb %d3,%d2
    movel %sp@+,%d3
    rts
    movel %a2@,%d0
    beqw JMFBDRVR_E26_2E6
    moveal %d0,%a2
    tstw %a2@
    bnew JMFBDRVR_E20
    cmpiw #6,%a3@(28)
    bnes JMFBDRVR_E26_252
    tstw %a2@(2)
    beqs JMFBDRVR_E26_272
JMFBDRVR_E26_252:
    cmpiw #25,%a2@(2)
    bnew JMFBDRVR_E20
    tstw %a2@(4)
    beqs JMFBDRVR_E26_272
    movew %a2@(12),%d0
    cmpw %a3@(22),%d0
    beqs JMFBDRVR_E26_272
    addqw #1,%d0
    bnew JMFBDRVR_E20
JMFBDRVR_E26_272:
    moveal %a3@(12),%a0
    movew %a2@(4),%d0
    cmpw %a0@(4),%d0
    bnes JMFBDRVR_E26_296
    movew %a2@(6),%d0
    cmpw %a0@(6),%d0
    beqs JMFBDRVR_E26_2C4
    bgts JMFBDRVR_E26_296
    moveal %a3@(32),%a0
    _DisposPtr
    clrl %a3@(32)
JMFBDRVR_E26_296:
    movew %a2@(8),%d0
    muluw %a2@(6),%d0
    addw %a2@(4),%d0
    addiw #12,%d0
    .short  0xA51E	| 40896A2C _NewPtr (flags 0x0500)
    bnew JMFBDRVR_E20
    movel %a3@(32),%d0
    movel %a0,%a3@(12)
    tstl %d0
    beqs JMFBDRVR_E26_2C4
    moveal %d0,%a0
    _DisposPtr
    moveal %a3@(12),%a0
    movel %a0,%a3@(32)
JMFBDRVR_E26_2C4:
    movew %a2@(6),%d0
    movew %a2@(4),%d1
    movew %a2@(8),%d2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    muluw %d0,%d2
    addw %d1,%d2
    subqw #1,%d2
JMFBDRVR_E26_2DC:
    moveb %a2@+,%d0
    moveb %d0,%a0@+
    dbf %d2,JMFBDRVR_E26_2DC
    bras JMFBDRVR_E26_30A
JMFBDRVR_E26_2E6:
    moveal %a3@(12),%a0
    movew %a0@(4),%d0
    movew %a0@(6),%d2
    subqw #1,%d2
    lea %a0@(12),%a0
    addaw %d0,%a0
JMFBDRVR_E26_2FA:
    movew #255,%d0
JMFBDRVR_E26_2FE:
    moveb %d0,%a0@
    notb %a0@+
    dbf %d0,JMFBDRVR_E26_2FE
    dbf %d2,JMFBDRVR_E26_2FA
JMFBDRVR_E26_30A:
    btst #10,%a3@(16)
    beqw JMFBDRVR_E24
    moveal %a3@(12),%a0
    lea %a0@(12),%a4
    addaw %a0@(4),%a4
    moveal %a4,%a5
    moveal %a4,%fp
    movew %a0@(10),%d7
    cmpiw #1,%a0@(6)
    beqs JMFBDRVR_E26_342
    movew %a0@(8),%d0
    movew %d7,%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %d1,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
JMFBDRVR_E26_342:
    moveal %a3@(24),%a0
    addal #2097668,%a0
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqw #2,%d0
    bges JMFBDRVR_E26_364
    oriw #512,%sr
    andiw #-1281,%sr
JMFBDRVR_E26_364:
    bsrw JMFBDRVR_1652
    clrl %a0@(-4)
    movew #255,%d0
    moveq #0,%d1
JMFBDRVR_E26_372:
    moveb %a4@(0x0,%d1:w),%d2
    movel %d2,%a0@
    moveb %a5@(0x0,%d1:w),%d2
    movel %d2,%a0@
    moveb %fp@(0x0,%d1:w),%d2
    movel %d2,%a0@
    addqw #1,%d1
    dbf %d0,JMFBDRVR_E26_372
    movew %sp@+,%sr
    movew %sp@+,%d0
    _SwapMMUMode
    braw JMFBDRVR_E24
    movew %a3@,%d1
    movew %d1,%a2@
    bsrw JMFBDRVR_1598
    bnew JMFBDRVR_E20
    movew %a2@(6),%d0
    bsrw JMFBDRVR_1614
    bnew JMFBDRVR_E20
    bsrw JMFBDRVR_18EE
    btst #10,%a3@(16)
    beqw JMFBDRVR_E24
    moveal %a3@(12),%a0
    lea %a0@(12),%a4
    addaw %a0@(4),%a4
    moveal %a4,%a5
    moveal %a4,%fp
    movew %a0@(10),%d7
    cmpiw #1,%a0@(6)
    beqs JMFBDRVR_E26_3E8
    movew %a0@(8),%d0
    movew %d7,%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %d1,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
JMFBDRVR_E26_3E8:
    moveal %a3@(24),%a0
    addal #2097668,%a0
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqw #2,%d0
    bges JMFBDRVR_E26_40A
    oriw #512,%sr
    andiw #-1281,%sr
JMFBDRVR_E26_40A:
    bsrw JMFBDRVR_1652
    clrl %a0@(-4)
    movew #255,%d0
    moveq #0,%d1
JMFBDRVR_E26_418:
    moveb %a4@(0x0,%d1:w),%d2
    movel %d2,%a0@
    moveb %a5@(0x0,%d1:w),%d2
    movel %d2,%a0@
    moveb %fp@(0x0,%d1:w),%d2
    movel %d2,%a0@
    addqw #1,%d1
    dbf %d0,JMFBDRVR_E26_418
    movew %sp@+,%sr
    movew %sp@+,%d0
    _SwapMMUMode
    braw JMFBDRVR_E24
    btst #12,%a3@(16)
    jbeq JMFBDRVR_126C
    moveb #1,%a2@
JMFBDRVR_126C:          /* SetGray: store the gray flag (bit 12) */
    moveq #0,%d1
    jbsr JMFBDRVR_1274
    jbra JMFBDRVR_E24

JMFBDRVR_1274:          /* set flag bit d1 of +16 from csParam's byte */
    moveb %a2@,%d0
    bfins %d0,%a3@(16),%d1,1
    rts
    moveq #1,%d1
    jbsr JMFBDRVR_1274
    jbne JMFBDRVR_1274_1A
    jbsr JMFBDRVR_12D0
    jbne JMFBDRVR_E20
    jbra JMFBDRVR_E24
JMFBDRVR_1274_1A:       /* SetInterrupt 1: disable the VBL interrupt */
    jbsr JMFBDRVR_1294
    jbra JMFBDRVR_E24

JMFBDRVR_1294:          /* remove the slot VBL interrupt: card interrupt off, SIntRemove */
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%d3
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqw #2,%d0
    jbge JMFBDRVR_1294_18
    oriw #512,%sr
    andiw #-1281,%sr
JMFBDRVR_1294_18:       /* (interrupt level at least 2) */
    clrw %d0
    moveb %a1@(40),%d0
    moveal %a3@(24),%a0
    addal #2097468,%a0
    movel #7,%a0@
    movew %d3,%d0
    _SwapMMUMode
    moveal %a3@(8),%a0
    _SIntRemove
    movew %sp@+,%sr
    rts

JMFBDRVR_12D0:          /* install the slot VBL interrupt (handler JMFBDRVR_19DC), card interrupt on */
    moveal %a3@(8),%a0
    lea %pc@(JMFBDRVR_19DC),%a2
    movel %a2,%d0
    _StripAddress
    moveal %d0,%a2
    movew #6,%a0@(4)
    movel %a2,%a0@(8)
    moveal %a3@(24),%a2
    addal #2097480,%a2
    movel %a2,%a0@(12)
    moveq #0,%d0
    moveb %a1@(40),%d0
    _SIntInstall
    jbne JMFBDRVR_12D0_44
    addaw #-12,%a2
    moveq #1,%d0
    _SwapMMUMode
    movel #5,%a2@
    _SwapMMUMode
    cmpw %d1,%d1
    rts
JMFBDRVR_12D0_44:       /* SIntInstall failed: Z clear */
    moveq #1,%d0
    rts
    movel %a2@,%d0
    beqw JMFBDRVR_E20
    btst #10,%a3@(16)
    beqw JMFBDRVR_E20
    braw JMFBDRVR_E26_C0
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0
    _SlotManager
    moveb %a2@,%sp@(3)
    movel %sp,%a0@(4)
    moveq #18,%d0
    _SlotManager
    lea %sp@(64),%sp
    braw JMFBDRVR_E24
    movel %a1,%d0
    _StripAddress
    moveal %d0,%a1
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    bsrw JMFBDRVR_1294
    moveal %a3@(32),%a0
    _DisposPtr
    moveal %a1@(20),%a0
    _DisposHandle
    moveal %a3@(8),%a0
    _DisposPtr
    moveq #0,%d0
    rts
    movel %a0,%sp@-
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    movew %a0@(26),%d0
    moveal %a0@(28),%a2
    cmpiw #9,%d0
    jbhi JMFBDRVR_13BA
    lslw #1,%d0
    movew %pc@(JMFBDRVR_13A6,%d0:w),%d0
    jmp %pc@(JMFBDRVR_13A6,%d0:w)
JMFBDRVR_13A6:          /* Status dispatch: offsets for csCode 0..9 */
    .short  JMFBDRVR_13BA-JMFBDRVR_13A6	| 40896D06
    .short  JMFBDRVR_13BA-JMFBDRVR_13A6	| 40896D08
    .short  JMFBDRVR_13C6-JMFBDRVR_13A6	| 40896D0A
    .short  JMFBDRVR_13D6-JMFBDRVR_13A6	| 40896D0C
    .short  JMFBDRVR_1460-JMFBDRVR_13A6	| 40896D0E
    .short  JMFBDRVR_1494-JMFBDRVR_13A6	| 40896D10
    .short  JMFBDRVR_14DE-JMFBDRVR_13A6	| 40896D12
    .short  JMFBDRVR_14EC-JMFBDRVR_13A6	| 40896D14
    .short  JMFBDRVR_14F0-JMFBDRVR_13A6	| 40896D16
    .short  JMFBDRVR_14F8-JMFBDRVR_13A6	| 40896D18
JMFBDRVR_13BA:          /* Status: statusErr (-18) */
    moveq #-18,%d0
    jbra JMFBDRVR_13C0
JMFBDRVR_13BE:          /* Status: noErr */
    moveq #0,%d0
JMFBDRVR_13C0:          /* Status: done */
    moveal %sp@+,%a0
    jbra JMFBDRVR_151C
JMFBDRVR_13C6:          /* GetMode (2): mode, page, base address */
    movew %a3@,%a2@
    movew %a3@(2),%a2@(6)
    movel %a3@(4),%a2@(8)
    jbra JMFBDRVR_13BE
JMFBDRVR_13D6:          /* GetEntries (3): read the color table entries from the card's CLUT */
    movel %a2@,%d0
    jbeq JMFBDRVR_13BA
    _StripAddress
    moveal %d0,%a0
    movew %a3@,%d1
    subiw #128,%d1
    lea %pc@(JMFBDRVR_B20),%a3
    moveq #0,%d3
    moveb %a3@(0x0,%d1:w),%d3
    movew %a2@(6),%d4
    tstw %d4
    jbmi JMFBDRVR_13BA
    cmpw %d3,%d4
    jbhi JMFBDRVR_13BA
    movew %d4,%d2
    cmpiw #-1,%a2@(4)
    jbeq JMFBDRVR_1414
    movew %d4,%d1
    addw %a2@(4),%d2
JMFBDRVR_140A:          /* sequence mode: fill in the index of each entry */
    movew %d2,%a0@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,JMFBDRVR_140A
JMFBDRVR_1414:          /* CLUT data register (32-bit mode) */
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    moveal %a3@(24),%a3
    addal #2097668,%a3
    moveq #1,%d0
    _SwapMMUMode
JMFBDRVR_142C:          /* one entry: select its index, read red, green, blue (byte doubled) */
    movew %a0@,%d1
    cmpw %d3,%d1
    jbhi JMFBDRVR_1454
    movel %d1,%a3@(-4)
    movel %a3@,%d1
    moveb %d1,%a0@(2)
    moveb %d1,%a0@(3)
    movel %a3@,%d1
    moveb %d1,%a0@(4)
    moveb %d1,%a0@(5)
    movel %a3@,%d1
    moveb %d1,%a0@(6)
    moveb %d1,%a0@(7)
JMFBDRVR_1454:          /* next entry */
    addql #8,%a0
    dbf %d4,JMFBDRVR_142C
    _SwapMMUMode
    jbra JMFBDRVR_13BE
JMFBDRVR_1460:          /* GetPageCnt (4): number of pages for the mode */
    movew %a2@,%d1
    movew %d1,%d2
    jbsr JMFBDRVR_1598
    jbne JMFBDRVR_13BA
    subiw #128,%d2
    moveal %a3@(18),%a0
    btst #13,%a3@(16)
    jbne JMFBDRVR_1484
    moveb %a0@(0xffffffffffffffea,%d2:w),%d1
    extw %d1
    jbra JMFBDRVR_148A
JMFBDRVR_1484:          /* (other monitor table) */
    moveb %a0@(0xffffffffffffffef,%d2:w),%d1
    extw %d1
JMFBDRVR_148A:          /* pages = table value + 1 */
    addqw #1,%d1
    movew %d1,%a2@(6)
    jbra JMFBDRVR_13BE
JMFBDRVR_1494:          /* GetBaseAddr (5): base address of a page of a mode */
    movew %a3@,%d1
    movew %d1,%a2@
    jbsr JMFBDRVR_1598
    movew %a2@(6),%d0
    jbsr JMFBDRVR_1614
    jbne JMFBDRVR_13BA
    movew %a3@,%d1
    subiw #128,%d1
    moveal %a3@(18),%a0
    muluw %a0@(0xfffffffffffffff4,%d1:w:2),%d0
    muluw %a0@(-2),%d0
    movel %d0,%d1
    jbsr JMFBDRVR_18B8
    addl %d1,%d0
    addl %a3@(24),%d0
    btst #8,%a3@(16)
    jbne JMFBDRVR_14D6
    bfextu %d0,4,4,%d1
    bfins %d1,%d0,8,4
JMFBDRVR_14D6:          /* (24-bit address form when not in 32-bit mode) */
    movel %d0,%a2@(8)
    jbra JMFBDRVR_13BE
JMFBDRVR_14DE:          /* GetGray (6) */
    moveq #0,%d1
JMFBDRVR_14E0:          /* return flag bit d1 as a byte */
    bfextu %a3@(16),%d1,1,%d0
    moveb %d0,%a2@
    jbra JMFBDRVR_13BE
JMFBDRVR_14EC:          /* GetInterrupt (7) */
    moveq #1,%d1
    jbra JMFBDRVR_14E0
JMFBDRVR_14F0:          /* GetGamma (8): the gamma table pointer */
    movel %a3@(12),%a2@
    jbra JMFBDRVR_13BE
JMFBDRVR_14F8:          /* GetDefaultMode (9): from the slot's PRAM record (sReadPRAMRec) */
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    moveb %sp@(3),%a2@
    lea %sp@(64),%sp
    jbra JMFBDRVR_13BE

JMFBDRVR_151C:          /* return from the driver: rts if immediate, else jump to IODone */
    btst #9,%a0@(6)
    jbeq JMFBDRVR_151C_A
    rts
JMFBDRVR_151C_A:        /* IODone */
    moveal JIODone,%a0
    jmp %a0@
JMFBDRVR_151C_A_6:
    moveml %d2-%d6,%sp@-
    clrw %d0
    moveq #9,%d5
    moveq #4,%d3
    lslw %d5,%d3
    movel %a1@(0x0,%d1:l),%d4
    andiw #-3585,%d4
    orl %d3,%d4
    movel %d4,%a1@(0x0,%d1:l)
    bfextu %a1@(0x0,%d1:l),20,3,%d2
    moveb %d2,%d0
    lslb #2,%d0
    moveq #2,%d3
    lslw %d5,%d3
    movel %a1@(0x0,%d1:l),%d4
    andiw #-3585,%d4
    orl %d3,%d4
    movel %d4,%a1@(0x0,%d1:l)
    bfextu %a1@(0x0,%d1:l),20,3,%d2
    moveb %d2,%d6
    andib #1,%d6
    lsrb #1,%d2
    orb %d6,%d2
    orb %d2,%d0
    lslb #2,%d0
    moveq #1,%d3
    lsll %d5,%d3
    movel %a1@(0x0,%d1:l),%d4
    andiw #-3585,%d4
    orl %d3,%d4
    movel %d4,%a1@(0x0,%d1:l)
    bfextu %a1@(0x0,%d1:l),20,3,%d2
    lsrl #1,%d2
    orb %d2,%d0
    moveml %sp@+,%d2-%d6
    rts

JMFBDRVR_1598:          /* check mode d1 for this card and monitor. Out: d1 = depth bits, Z = valid */
    subiw #128,%d1
    jbmi JMFBDRVR_1598_76
    cmpiw #4,%d1
    jbgt JMFBDRVR_1598_76
    bclr #10,%a3@(16)
    moveq #1,%d0
    lslw %d1,%d0
    movew %d0,%d1
    cmpiw #4,%d1
    jble JMFBDRVR_1598_72
    btst #13,%a3@(16)
    jbne JMFBDRVR_1598_54
    cmpiw #8,%d1
    jbeq JMFBDRVR_1598_72
    btst #9,%a3@(16)
    jbne JMFBDRVR_1598_76
    btst #8,%a3@(16)
    jbeq JMFBDRVR_1598_76
    btst #13,%a3@(30)
    jbeq JMFBDRVR_1598_4C
    btst #15,%a3@(30)
    jbeq JMFBDRVR_1598_76
JMFBDRVR_1598_4C:       /* alternate timing needed */
    bset #10,%a3@(16)
    jbra JMFBDRVR_1598_72
JMFBDRVR_1598_54:       /* (monitor variant) */
    btst #9,%a3@(16)
    jbne JMFBDRVR_1598_76
    btst #13,%a3@(30)
    jbeq JMFBDRVR_1598_6C
    btst #15,%a3@(30)
    jbeq JMFBDRVR_1598_76
JMFBDRVR_1598_6C:       /* only 8 bits per pixel */
    cmpiw #8,%d1
    jbne JMFBDRVR_1598_76
JMFBDRVR_1598_72:       /* valid */
    cmpw %d1,%d1
    jbra JMFBDRVR_1598_7A
JMFBDRVR_1598_76:       /* invalid */
    st %d1
    tstb %d1
JMFBDRVR_1598_7A:       /* return */
    rts

JMFBDRVR_1614:          /* check page d0 for the mode in csParam. Out: Z set if valid */
    moveml %d2-%d3/%a0-%a1,%sp@-
    tstw %d0
    jbmi JMFBDRVR_1614_34
    moveq #0,%d3
    movew %a2@,%d2
    subiw #128,%d2
    moveal %a3@(18),%a1
    btst #13,%a3@(16)
    jbne JMFBDRVR_1614_26
    moveb %a1@(0xffffffffffffffea,%d2:w),%d3
    extw %d3
    cmpw %d3,%d0
    jbra JMFBDRVR_1614_2E
JMFBDRVR_1614_26:       /* (other monitor table) */
    moveb %a1@(0xffffffffffffffef,%d2:w),%d3
    extw %d3
    cmpw %d3,%d0
JMFBDRVR_1614_2E:       /* compare with the page count */
    sgt %d2
    tstb %d2
    jbra JMFBDRVR_1614_38
JMFBDRVR_1614_34:       /* negative: invalid */
    st %d2
    tstb %d2
JMFBDRVR_1614_38:       /* return */
    moveml %sp@+,%d2-%d3/%a0-%a1
    rts

JMFBDRVR_1652:          /* wait for the start of a vertical blanking period (card status bit) */
    moveml %d0/%a0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqw #2,%d0
    jbge JMFBDRVR_1652_16
    oriw #512,%sr
    andiw #-1281,%sr
JMFBDRVR_1652_16:       /* card status register */
    moveal %a3@(24),%a0
    addal #2097600,%a0
JMFBDRVR_1652_20:       /* wait for 1 */
    bfextu %a0@,29,1,%d0
    cmpib #1,%d0
    jbne JMFBDRVR_1652_20
JMFBDRVR_1652_2A:       /* then 0 */
    bfextu %a0@,29,1,%d0
    cmpib #0,%d0
    jbne JMFBDRVR_1652_2A
JMFBDRVR_1652_34:       /* then 1 again */
    bfextu %a0@,29,1,%d0
    cmpib #1,%d0
    jbne JMFBDRVR_1652_34
    movew %sp@+,%sr
    moveml %sp@+,%d0/%a0
    rts

JMFBDRVR_1698:          /* program the card for depth d1 (1, 2, 4, 8, 24): timing, depth and CLUT registers */
    moveml %d0-%d2/%a0-%a4,%sp@-
    cmpiw #16,%d1
    jbgt JMFBDRVR_1698_15C
    movew %a2@,%a3@
    moveal %a3@(18),%a0
    cmpiw #1,%d1
    jbeq JMFBDRVR_1698_40
    cmpiw #2,%d1
    jbeq JMFBDRVR_1698_3C
    cmpiw #4,%d1
    jbeq JMFBDRVR_1698_36
    cmpiw #8,%d1
    jbeq JMFBDRVR_1698_30
    addaw #160,%a0
    jbra JMFBDRVR_1698_40
JMFBDRVR_1698_30:       /* 8 bits: its register values */
    addaw #120,%a0
    jbra JMFBDRVR_1698_40
JMFBDRVR_1698_36:       /* 4 bits */
    addaw #80,%a0
    jbra JMFBDRVR_1698_40
JMFBDRVR_1698_3C:       /* 2 bits */
    addaw #40,%a0
JMFBDRVR_1698_40:       /* 32-bit mode, interrupts at level 2 or more */
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqw #2,%d0
    jbge JMFBDRVR_1698_58
    oriw #512,%sr
    andiw #-1281,%sr
JMFBDRVR_1698_58:       /* wait for blanking, monitor-specific values */
    jbsr JMFBDRVR_1652
    btst #14,%a3@(30)
    jbeq JMFBDRVR_1698_70
    movew %a3@,%d2
    subiw #128,%d2
    muluw #22,%d2
    addal %d2,%a0
JMFBDRVR_1698_70:       /* write the control registers */
    moveal %a3@(24),%a1
    movew %a3@(30),%d2
    moveal %a3,%a4
    moveal %a1,%a3
    addal #2097672,%a1
    moveq #0,%d0
    movew %a0@+,%d0
    movel %d0,%a1@
    moveal %a3,%a1
    addal #2097152,%a1
    moveal %a1,%a2
    movew #2,%d1
    moveq #0,%d0
    movew %a0@+,%d0
    btst #12,%a4@(30)
    jbne JMFBDRVR_1698_A6
    oriw #8192,%d0
JMFBDRVR_1698_A6:       /* (gray: no color bit) */
    movel %d0,%a1@+
JMFBDRVR_1698_A8:       /* next register */
    movew %a0@+,%d0
    movel %d0,%a1@+
    dbf %d1,JMFBDRVR_1698_A8
    moveal %a3,%a1
    addal #2097920,%a1
    btst #14,%d2
    jbeq JMFBDRVR_1698_EA
    btst #12,%a4@(30)
    jbne JMFBDRVR_1698_DA
    movew #2,%d1
    moveq #0,%d0
JMFBDRVR_1698_CC:       /* timing registers (one monitor kind) */
    movew %a0@+,%d0
    movel %d0,%a1@+
    dbf %d1,JMFBDRVR_1698_CC
    addaw #16,%a0
    jbra JMFBDRVR_1698_EA
JMFBDRVR_1698_DA:       /* timing registers (other kind) */
    addql #6,%a0
    movew #15,%d1
    moveq #0,%d0
JMFBDRVR_1698_E2:       /* next */
    moveb %a0@+,%d0
    movel %d0,%a1@+
    dbf %d1,JMFBDRVR_1698_E2
JMFBDRVR_1698_EA:       /* reset the timing generator */
    addaw #0,%a2
    btst #12,%a4@(30)
    jbne JMFBDRVR_1698_102
    movel %a2@,%d1
    andiw #-3585,%d1
    oriw #8192,%d1
    movel %d1,%a2@
JMFBDRVR_1698_102:      /* short delay, then restart it */
    movew #5,%d1
JMFBDRVR_1698_106:      /* delay */
    dbf %d1,JMFBDRVR_1698_106
    movel %a2@,%d1
    andiw #-3585,%d1
    oriw #-32768,%d1
    movel %d1,%a2@
    moveal %a3,%a1
    addal #2097408,%a1
    movew #14,%d1
    moveq #0,%d0
JMFBDRVR_1698_124:      /* depth registers, then enable the video again */
    movew %a0@+,%d0
    movel %d0,%a1@+
    dbf %d1,JMFBDRVR_1698_124
    movel #4,%a1@
    movel #5,%a1@
    movel %a2@,%d1
    andiw #-3585,%d1
    oriw #8,%d1
    movel %d1,%a2@
    moveal %a4,%a3
    jbsr JMFBDRVR_1652
    movel %a2@,%d1
    andiw #-3585,%d1
    oriw #64,%d1
    movel %d1,%a2@
    movew %sp@+,%sr
    movew %sp@+,%d0
    _SwapMMUMode
JMFBDRVR_1698_15C:      /* return */
    moveml %sp@+,%d0-%d2/%a0-%a4
    rts

JMFBDRVR_17FA:          /* set the page (d4) and base address: clear the border, set the base register */
    moveml %d0-%d5/%a0,%sp@-
    movew %d4,%a3@(2)
    movew %a3@,%d1
    subiw #128,%d1
    moveal %a3@(18),%a0
    movew %a0@(0xfffffffffffffff4,%d1:w:2),%d2
    muluw %d2,%d4
    muluw %a0@(-2),%d4
    jbsr JMFBDRVR_18B8
    addl %d0,%d4
    movel %d4,%d5
    moveq #1,%d0
    _SwapMMUMode
    btst #11,%a3@(16)
    jbeq JMFBDRVR_17FA_7C
    btst #13,%a3@(16)
    jbeq JMFBDRVR_17FA_40
    subil #1024,%d4
    jbra JMFBDRVR_17FA_4C
JMFBDRVR_17FA_40:       /* (small screens) */
    cmpib #3,%d1
    jbgt JMFBDRVR_17FA_64
    subil #5120,%d4
JMFBDRVR_17FA_4C:       /* fill the area before the page with ones */
    moveal %a3@(24),%a0
    addiw #8192,%d2
    lsrw #2,%d2
    subqw #1,%d2
JMFBDRVR_17FA_58:       /* fill loop */
    movel #-1,%a0@+
    dbf %d2,JMFBDRVR_17FA_58
    jbra JMFBDRVR_17FA_7C
JMFBDRVR_17FA_64:       /* (deeper modes): fill with zeros */
    subil #2560,%d4
    moveal %a3@(24),%a0
    addiw #2560,%d2
    lsrw #2,%d2
    subqw #1,%d2
JMFBDRVR_17FA_76:       /* fill loop */
    clrl %a0@+
    dbf %d2,JMFBDRVR_17FA_76
JMFBDRVR_17FA_7C:       /* base address of the page (24-bit form when needed) */
    addl %a3@(24),%d5
    btst #8,%a3@(16)
    jbne JMFBDRVR_17FA_90
    bfextu %d5,4,4,%d3
    bfins %d3,%d5,8,4
JMFBDRVR_17FA_90:       /* write the card's base register (in units of 32 bytes) */
    movel %d5,%a3@(4)
    moveal %a3@(24),%a0
    addal #2097152,%a0
    addql #8,%a0
    cmpib #3,%d1
    jble JMFBDRVR_17FA_B2
    asrl #2,%d4
    .short  0x4C3C, 0x4004, 0x0000, 0x0003	| 40897202 mulul #3,%d4
    lsrl #1,%d4
JMFBDRVR_17FA_B2:       /* (scaled for the depth) */
    lsrl #5,%d4
    movel %d4,%a0@
    _SwapMMUMode
    moveml %sp@+,%d0-%d5/%a0
    rts

JMFBDRVR_18B8:          /* offset of the visible screen in the frame buffer for this card. Out: d0 */
    btst #11,%a3@(16)
    jbne JMFBDRVR_18B8_20
    btst #9,%a3@(16)
    jbeq JMFBDRVR_18B8_18
    movel #128,%d0
    jbra JMFBDRVR_18B8_34
JMFBDRVR_18B8_18:       /* 2560 */
    movel #2560,%d0
    jbra JMFBDRVR_18B8_34
JMFBDRVR_18B8_20:       /* big card: 8192 for the low depths */
    cmpiw #131,%a3@
    jbgt JMFBDRVR_18B8_2E
    movel #8192,%d0
    jbra JMFBDRVR_18B8_34
JMFBDRVR_18B8_2E:       /* 2560 */
    movel #2560,%d0
JMFBDRVR_18B8_34:       /* return */
    rts

JMFBDRVR_18EE:          /* fill the screen with the 50% gray pattern for the depth (JMFBDRVR_19C8) */
    moveml %d0-%d6/%a0-%a1,%sp@-
    movew %a3@,%d1
    subiw #128,%d1
    movew %d1,%d3
    lea %pc@(JMFBDRVR_19C8),%a1
    movel %a1@(0x0,%d3:w:4),%d5
    moveal %a3@(18),%a1
    movew %a1@(0xfffffffffffffff4,%d1:w:2),%d4
    movew %a1@(-2),%d3
    subqw #1,%d3
    moveal %a3@(4),%a1
    btst #8,%a3@(16)
    jbne JMFBDRVR_18EE_38
    movel %a1,%d0
    andil #-15728641,%d0
    moveal %d0,%a1
JMFBDRVR_18EE_38:       /* 32-bit mode */
    moveq #1,%d0
    _SwapMMUMode
    cmpib #4,%d1
    jbeq JMFBDRVR_18EE_8C
JMFBDRVR_18EE_42:       /* each row: the pattern, inverted on the next row */
    moveal %a1,%a0
    movew %d4,%d2
    lsrw #2,%d2
    movew %d2,%d7
    subqw #1,%d2
JMFBDRVR_18EE_4C:       /* one row */
    movel %d5,%a0@+
    dbf %d2,JMFBDRVR_18EE_4C
    notl %d5
    addaw %d4,%a1
    dbf %d3,JMFBDRVR_18EE_42
    btst #11,%a3@(16)
    jbeq JMFBDRVR_18EE_D2
    btst #15,%a3@(30)
    jbeq JMFBDRVR_18EE_D2
    movew %d7,%d2
    btst #13,%a3@(30)
    jbne JMFBDRVR_18EE_7A
    muluw #50,%d2
    jbra JMFBDRVR_18EE_7E
JMFBDRVR_18EE_7A:       /* (taller monitor) */
    muluw #58,%d2
JMFBDRVR_18EE_7E:       /* fill the bottom border */
    subqw #1,%d2
JMFBDRVR_18EE_80:       /* border fill */
    movel #-1,%a0@+
    dbf %d2,JMFBDRVR_18EE_80
    jbra JMFBDRVR_18EE_D2
JMFBDRVR_18EE_8C:       /* 24 bits per pixel: alternate the pattern per pixel */
    moveal %a1,%a0
    movew %d4,%d2
    lsrw #2,%d2
    movew %d2,%d7
    subqw #1,%d2
JMFBDRVR_18EE_96:       /* one row */
    movel %d5,%a0@+
    notl %d5
    dbf %d2,JMFBDRVR_18EE_96
    notl %d5
    addaw %d4,%a1
    dbf %d3,JMFBDRVR_18EE_8C
    btst #11,%a3@(16)
    jbeq JMFBDRVR_18EE_D2
    btst #15,%a3@(30)
    jbeq JMFBDRVR_18EE_D2
    movew %d7,%d2
    btst #13,%a3@(30)
    jbne JMFBDRVR_18EE_C6
    muluw #50,%d2
    jbra JMFBDRVR_18EE_CA
JMFBDRVR_18EE_C6:       /* (taller monitor) */
    muluw #58,%d2
JMFBDRVR_18EE_CA:       /* fill the bottom border */
    subqw #1,%d2
JMFBDRVR_18EE_CC:       /* border fill */
    clrl %a0@+
    dbf %d2,JMFBDRVR_18EE_CC
JMFBDRVR_18EE_D2:       /* back to the previous addressing mode */
    _SwapMMUMode
    moveml %sp@+,%d0-%d6/%a0-%a1
    rts
JMFBDRVR_19C8:          /* gray patterns, one long per depth */
    .long   0xAAAAAAAA, 0xCCCCCCCC	| 40897328
    .long   0xF0F0F0F0, 0xFF00FF00, 0x00000000	| 40897330
JMFBDRVR_19DC:          /* VBL interrupt handler: wait for the card, acknowledge it, run the slot's VBL tasks */
    moveml %d1-%d2/%a0-%a1,%sp@-
    moveq #1,%d0
    moveal JSwapMMU,%a0
    jsr %a0@
    moveml %sp@+,%d1-%d2/%a0-%a1
    movel %d1,%sp@-
JMFBDRVR_19EE:          /* wait while the card is busy */
    movel %a1@(132),%d1
    andiw #8,%d1
    jbne JMFBDRVR_19EE
    movel %sp@+,%d1
    movel #1,%a1@
    moveml %d1-%d2/%a0-%a1,%sp@-
    moveal JSwapMMU,%a0
    jsr %a0@
    moveml %sp@+,%d1-%d2/%a0-%a1
    movel %a1,%d0
    roll #8,%d0
    andiw #15,%d0
    moveal JVBLTask,%a0
    jsr %a0@
    moveq #1,%d0
    rts
JMFBDRVRSIZE:           /* size of the driver */
    .long   0x00001A20, 0x00000000, 0x00000000, 0x00000000	| 40897380

/*
 JMFBPRIMARYINIT: the card's PrimaryInit code: sense the monitor
 type and set up the card at start-up.
*/
JMFBPRIMARYINIT:
    nop
    moveml %d0-%a4,%sp@-
    movew #1,%a0@(2)
    movel #-268435456,%d1
    moveb %a0@,%d0
    bfins %d0,%d1,4,4
    moveal %d1,%a1
    subaw #56,%sp
    moveal %sp,%a0
    moveb %d0,%a0@(49)
    clrb %a0@(51)
    clrb %d6
    moveq #8,%d0
    _SlotManager
    sne %d6
    moveq #1,%d0
    _SwapMMUMode
    movel %d0,%sp@-
    movel #2097152,%d1
    bfextu %a1@(0x0,%d1:l),20,3,%d4
    cmpib #7,%d4
    bnes JMFBPRIMARYINIT_5E
    bsrw JMFBPRIMARYINIT_418
    cmpib #20,%d0
    bnes JMFBPRIMARYINIT_58
    moveb #4,%d4
    bras JMFBPRIMARYINIT_68
JMFBPRIMARYINIT_58:
    moveb #0xf0,%d4	| 408973E8
    bras JMFBPRIMARYINIT_68
JMFBPRIMARYINIT_5E:
    cmpib #0,%d4
    bnes JMFBPRIMARYINIT_68
    moveb #7,%d4
JMFBPRIMARYINIT_68:
    movel %sp@+,%d0
    _SwapMMUMode
    movel %d4,%d5
    moveb #0xf0,%d3	| 408973FE
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0
    _SlotManager
    moveb %sp@(3),%d1
    sf %d2
    moveal %a1,%a3
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%d7
    bsrw JMFBPRIMARYINIT_418_6C
    cmpb %sp@(6),%d0
    beqs JMFBPRIMARYINIT_98
    moveb %d0,%sp@(6)
    st %d2
JMFBPRIMARYINIT_98:
    movew %d7,%d0
    _SwapMMUMode
    bfextu %d1,29,3,%d0
    cmpb %d4,%d0
    beqs JMFBPRIMARYINIT_A8
    st %d2
    bras JMFBPRIMARYINIT_E4
JMFBPRIMARYINIT_A8:
    moveb %d4,%d0
    andib #3,%d0
    cmpib #0,%d0
    bnes JMFBPRIMARYINIT_E4
    clrb %sp@(5)
    tstb %d6
    beqs JMFBPRIMARYINIT_CA
    cmpib #0x84,%sp@(2)	| 4089744C
    bnes JMFBPRIMARYINIT_CA
    moveb #0xff,%sp@(5)	| 40897454
JMFBPRIMARYINIT_CA:
    movel %a0@,%a0@(4)
    moveq #18,%d0
    _SlotManager
    btst #3,%d1
    beqs JMFBPRIMARYINIT_DC
    bset #3,%d4
JMFBPRIMARYINIT_DC:
    cmpb %sp@(4),%d1
    beqs JMFBPRIMARYINIT_E4
    st %d2
JMFBPRIMARYINIT_E4:
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%d7
    movel #1002240,%d1
    movel #-1431655766,%d5
    movel %d5,%a1@(0x0,%d1:l)
    movel MinusOne,%sp@-
    addqw #4,%sp
    cmpl %a1@(0x0,%d1:l),%d5
    bnes JMFBPRIMARYINIT_10A
    bset #5,%d4
JMFBPRIMARYINIT_10A:
    bset #7,%d4
    tstb %d6
    beqs JMFBPRIMARYINIT_118
    bset #4,%d4
    bras JMFBPRIMARYINIT_11E
JMFBPRIMARYINIT_118:
    moveb %d4,%d3
    bchg #3,%d3
JMFBPRIMARYINIT_11E:
    tstb %d2
    beqs JMFBPRIMARYINIT_13C
    moveb %d4,%sp@(3)
    moveb %d4,%sp@(4)
    moveb #0x80,%sp@(2)	| 408974BA
    clrb %sp@(5)
    movel %sp,%a0@(4)
    moveq #18,%d0
    _SlotManager
JMFBPRIMARYINIT_13C:
    addqw #8,%sp
    bclr #4,%d4
    bclr #4,%d3
    movew %d7,%d0
    _SwapMMUMode
    .short  0x45FA, 0x0372	| lea %pc@(4089784e <JMFBPRIMARYINIT_418+0xa6>),%a2
    moveq #11,%d1
JMFBPRIMARYINIT_150:
    moveb %a2@+,%d2
    tstb %d6
    bnes JMFBPRIMARYINIT_15A
    bset #4,%d2
JMFBPRIMARYINIT_15A:
    moveb %d2,%a0@(50)
    moveq #49,%d0
    _SlotManager
    dbf %d1,JMFBPRIMARYINIT_150
    clrw %d7
    btst #0,%d4
    beqs JMFBPRIMARYINIT_172
    bclr #2,%d4
JMFBPRIMARYINIT_172:
    lea %pc@(JMFBPRIMARYINIT_418_6C_36+0x4),%a2	| 40897502
    moveq #11,%d1
JMFBPRIMARYINIT_178:
    moveb %a2@+,%d2
    cmpb %d3,%d2
    bnes JMFBPRIMARYINIT_1A0
    tstb %d6
    bnes JMFBPRIMARYINIT_1A0
    bclr #4,%d2
    moveb %d2,%a0@(50)
    movel #1,%a0@(24)
    clrb %a0@(51)
    moveq #9,%d0
    _SlotManager
    clrl %a0@(24)
    bras JMFBPRIMARYINIT_1B6
JMFBPRIMARYINIT_1A0:
    cmpb %d4,%d2
    beqs JMFBPRIMARYINIT_1B6
    tstb %d6
    beqs JMFBPRIMARYINIT_1AC
    bset #4,%d2
JMFBPRIMARYINIT_1AC:
    moveb %d2,%a0@(50)
    moveq #49,%d0
    _SlotManager
    addqw #1,%d7
JMFBPRIMARYINIT_1B6:
    dbf %d1,JMFBPRIMARYINIT_178
    cmpiw #12,%d7
    beqw JMFBPRIMARYINIT_40E
    moveb %d4,%d2
    andib #7,%d4
    tstb %d6
    beqs JMFBPRIMARYINIT_1F4
    moveb %a0@(49),%d3
    subqw #2,%sp
    moveal %sp,%a0
    _GetVideoDefault
    cmpb %a0@,%d3
    bnes JMFBPRIMARYINIT_1F2
    bclr #4,%d2
    cmpb %a0@(1),%d2
    bnes JMFBPRIMARYINIT_1F2
    bset #4,%d2
    moveb %d2,%a0@(1)
    .short  0xA081	| 4089757C _SetVideoDefault (flags 0x0000)
    bclr #4,%d2
JMFBPRIMARYINIT_1F2:
    addqw #2,%sp
JMFBPRIMARYINIT_1F4:
    cmpib #2,%d4
    beqs JMFBPRIMARYINIT_218
    cmpib #3,%d4
    beqs JMFBPRIMARYINIT_21E
    cmpib #1,%d4
    beqs JMFBPRIMARYINIT_224
    cmpib #4,%d4
    beqs JMFBPRIMARYINIT_22A
    cmpib #0,%d4
    beqs JMFBPRIMARYINIT_254
    lea %pc@(JMFBPRIMARYINIT_418_178_18C),%a0	| 408975A2
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_218:
    lea %pc@(JMFBPRIMARYINIT_418_178_14A),%a0	| 408975A8
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_21E:
    lea %pc@(JMFBPRIMARYINIT_418_388),%a0
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_224:
    lea %pc@(JMFBPRIMARYINIT_418_178_1CE),%a0	| 408975B4
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_22A:
    btst #5,%d2
    beqs JMFBPRIMARYINIT_242
    btst #3,%d2
    beqs JMFBPRIMARYINIT_23C
    lea %pc@(JMFBPRIMARYINIT_418_178_84),%a0	| 408975C6
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_23C:
    lea %pc@(JMFBPRIMARYINIT_418_178_108),%a0	| 408975CC
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_242:
    btst #3,%d2
    beqs JMFBPRIMARYINIT_24E
    lea %pc@(JMFBPRIMARYINIT_418_178_42),%a0	| 408975D8
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_24E:
    lea %pc@(JMFBPRIMARYINIT_418_178_C6),%a0	| 408975DE
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_254:
    btst #5,%d2
    beqs JMFBPRIMARYINIT_26C
    btst #3,%d2
    beqs JMFBPRIMARYINIT_266
    lea %pc@(JMFBPRIMARYINIT_418_6C_36_52),%a0	| 408975F0
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_266:
    lea %pc@(JMFBPRIMARYINIT_418_178),%a0
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_26C:
    btst #3,%d2
    beqs JMFBPRIMARYINIT_278
    lea %pc@(JMFBPRIMARYINIT_418_6C_36+0x10),%a0	| 40897602
    bras JMFBPRIMARYINIT_27C
JMFBPRIMARYINIT_278:
    lea %pc@(JMFBPRIMARYINIT_418_6C_36_94),%a0	| 40897608
JMFBPRIMARYINIT_27C:
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%sp@-
    moveal %a1,%a3
    addal #2097672,%a1
    moveq #0,%d0
    movew %a0@+,%d0
    movel %d0,%a1@+
    moveal %a3,%a1
    addal #2097152,%a1
    moveal %a1,%a2
    movew #3,%d1
    moveq #0,%d0
JMFBPRIMARYINIT_2A0:
    movew %a0@+,%d0
    movel %d0,%a1@+
    dbf %d1,JMFBPRIMARYINIT_2A0
    bsrw JMFBPRIMARYINIT_418_6C
    movel %d0,%sp@-
    moveal %a3,%a1
    addal #2097920,%a1
    cmpiw #0,%d0
    bnes JMFBPRIMARYINIT_2D0
    movew #2,%d1
    moveq #0,%d0
JMFBPRIMARYINIT_2C2:
    movew %a0@+,%d0
    movel %d0,%a1@+
    dbf %d1,JMFBPRIMARYINIT_2C2
    addaw #16,%a0
    bras JMFBPRIMARYINIT_2E0
JMFBPRIMARYINIT_2D0:
    addql #6,%a0
    movew #15,%d1
    moveq #0,%d0
JMFBPRIMARYINIT_2D8:
    moveb %a0@+,%d0
    movel %d0,%a1@+
    dbf %d1,JMFBPRIMARYINIT_2D8
JMFBPRIMARYINIT_2E0:
    addaw #0,%a2
    movel %sp@+,%d0
    cmpiw #0,%d0
    bnes JMFBPRIMARYINIT_2F8
    movel %a2@,%d1
    andiw #-3585,%d1
    oriw #8192,%d1
    movel %d1,%a2@
JMFBPRIMARYINIT_2F8:
    movew TimeDBRA,%d1
JMFBPRIMARYINIT_2FC:
    dbf %d1,JMFBPRIMARYINIT_2FC
    movew TimeDBRA,%d1
JMFBPRIMARYINIT_304:
    dbf %d1,JMFBPRIMARYINIT_304
    movel %a2@,%d1
    andiw #-3585,%d1
    oriw #-32768,%d1
    movel %d1,%a2@
    moveal %a3,%a1
    addal #2097408,%a1
    movew #14,%d1
    moveq #0,%d0
JMFBPRIMARYINIT_322:
    movew %a0@+,%d0
    movel %d0,%a1@+
    dbf %d1,JMFBPRIMARYINIT_322
    movel #6,%a1@
    movel #7,%a1@
    movel %a2@,%d1
    andiw #-3585,%d1
    oriw #8,%d1
    movel %d1,%a2@
    moveal %a2,%a4
    moveal %a3,%a1
    movel #2097668,%d1
    clrl %a1@(-4,%d1:l)
    bras JMFBPRIMARYINIT_370
    clrl %a1@(0x0,%d1:l)
    clrl %a1@(0x0,%d1:l)
    movel #255,%a1@(0x0,%d1:l)
    clrl %a1@(0x0,%d1:l)
    clrl %a1@(0x0,%d1:l)
    clrl %a1@(0x0,%d1:l)
    bras JMFBPRIMARYINIT_394
JMFBPRIMARYINIT_370:
    movel #255,%a1@(0x0,%d1:l)
    movel #255,%a1@(0x0,%d1:l)
    movel #255,%a1@(0x0,%d1:l)
    clrl %a1@(0x0,%d1:l)
    clrl %a1@(0x0,%d1:l)
    clrl %a1@(0x0,%d1:l)
JMFBPRIMARYINIT_394:
    moveal %a3,%a2
    andib #3,%d4
    cmpib #0,%d4
    beqs JMFBPRIMARYINIT_3B0
    movew #2560,%d3
    lsrw #2,%d3
    subqw #1,%d3
JMFBPRIMARYINIT_3A8:
    clrl %a2@+
    dbf %d3,JMFBPRIMARYINIT_3A8
    bras JMFBPRIMARYINIT_3C2
JMFBPRIMARYINIT_3B0:
    movew #8192,%d3
    lsrw #2,%d3
    subqw #1,%d3
JMFBPRIMARYINIT_3B8:
    movel #-1,%a2@+
    dbf %d3,JMFBPRIMARYINIT_3B8
JMFBPRIMARYINIT_3C2:
    moveal %a3,%a2
    cmpib #0,%d4
    beqs JMFBPRIMARYINIT_3D0
    addaw #2560,%a2
    bras JMFBPRIMARYINIT_3D4
JMFBPRIMARYINIT_3D0:
    addaw #8192,%a2
JMFBPRIMARYINIT_3D4:
    movel #-1431655766,%d5
    movew %a0@+,%d3
JMFBPRIMARYINIT_3DC:
    movew %a0@,%d1
JMFBPRIMARYINIT_3DE:
    movel %d5,%a2@+
    dbf %d1,JMFBPRIMARYINIT_3DE
    notl %d5
    dbf %d3,JMFBPRIMARYINIT_3DC
    btst #3,%d2
    bnes JMFBPRIMARYINIT_3FE
    movew #14847,%d1
JMFBPRIMARYINIT_3F4:
    movel #-1,%a2@+
    dbf %d1,JMFBPRIMARYINIT_3F4
JMFBPRIMARYINIT_3FE:
    movel %a4@,%d1
    andiw #-3585,%d1
    oriw #64,%d1
    movel %d1,%a4@
    movew %sp@+,%d0
    _SwapMMUMode
JMFBPRIMARYINIT_40E:
    lea %sp@(56),%sp
    moveml %sp@+,%d0-%a4
    rts

JMFBPRIMARYINIT_418:    /* read the monitor sense lines: drive each line in turn and read the other two, giving a sense code in d0 */
    moveml %d2-%d6,%sp@-
    clrw %d0
    moveq #9,%d5
    moveq #4,%d3
    lslw %d5,%d3
    movel %a1@(0x0,%d1:l),%d4
    andiw #-3585,%d4
    orl %d3,%d4
    movel %d4,%a1@(0x0,%d1:l)
    bfextu %a1@(0x0,%d1:l),20,3,%d2
    moveb %d2,%d0
    lslb #2,%d0
    moveq #2,%d3
    lslw %d5,%d3
    movel %a1@(0x0,%d1:l),%d4
    andiw #-3585,%d4
    orl %d3,%d4
    movel %d4,%a1@(0x0,%d1:l)
    bfextu %a1@(0x0,%d1:l),20,3,%d2
    moveb %d2,%d6
    andib #1,%d6
    lsrb #1,%d2
    orb %d6,%d2
    orb %d2,%d0
    lslb #2,%d0
    moveq #1,%d3
    lsll %d5,%d3
    movel %a1@(0x0,%d1:l),%d4
    andiw #-3585,%d4
    orl %d3,%d4
    movel %d4,%a1@(0x0,%d1:l)
    bfextu %a1@(0x0,%d1:l),20,3,%d2
    lsrl #1,%d2
    orb %d2,%d0
    moveml %sp@+,%d2-%d6
    rts
JMFBPRIMARYINIT_418_6C:
    movel %a0,%sp@-
    moveal %a3,%a0
    addal #2097920,%a0
    movel #85,%a0@
    movel %a0@,%d0
    andiw #255,%d0
    cmpiw #85,%d0
    bnes JMFBPRIMARYINIT_418_6C_32
    movel #170,%a0@
    movel %a0@,%d0
    andiw #255,%d0
    cmpiw #170,%d0
    bnes JMFBPRIMARYINIT_418_6C_32
    clrw %d0
    bras JMFBPRIMARYINIT_418_6C_36
JMFBPRIMARYINIT_418_6C_32:
    movew #-1,%d0
JMFBPRIMARYINIT_418_6C_36:
    moveal %sp@+,%a0
    rts
    orl %a4@-,%d2
    orl %d0,%a1@-
    orl %fp@-,%d3
    orl %d1,%a3@-
    orl %a2@-,%d1
    orl %a4@(128),%d6
    orb %d0,%a2@
    .short  0x00E0	| .short 0x00e0
    btst %d0,%d0
    btst %d0,%d0
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000, 0x0D09	| orib #9,%d0
    btst %d0,%d0
    addib #1,%d4
    btst %d0,%d3
    btst %d6,%d6
    .short  0x0001, 0x0000	| orib #0,%d1
    .short  0x0003, 0x0000	| orib #0,%d3
    bchg %d0,%a0@-
    .byte   0x02, 0xFE, 0x00, 0x31, 0x00, 0x43, 0x00, 0x36, 0x00, 0x03, 0x00, 0x00, 0x02, 0x3F, 0x00, 0x28	| 40897880
    .byte   0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x02, 0x3F, 0x00, 0xFF	| 40897890
JMFBPRIMARYINIT_418_6C_36_52:
    .byte   0x00, 0xC1, 0x81, 0x32, 0x00, 0xF8, 0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4089789C
    .byte   0x0D, 0x09, 0x01, 0x00, 0x06, 0x04, 0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00	| 408978AC
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x60, 0x02, 0xFE, 0x00, 0x31, 0x00, 0x43, 0x00, 0x36, 0x00, 0x03	| 408978BC
    .byte   0x00, 0x00, 0x02, 0x3F, 0x00, 0x28, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x02, 0x3F	| 408978CC
    .byte   0x00, 0xFF	| 408978DC
JMFBPRIMARYINIT_418_6C_36_94:
    .byte   0x00, 0x80, 0x81, 0x12, 0x00, 0xE0, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408978DE
    .byte   0x0D, 0x09, 0x01, 0x00, 0x06, 0x04, 0x00, 0x01, 0x01, 0x03, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00	| 408978EE
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x14, 0x02, 0x66, 0x00, 0x7D, 0x00, 0x43, 0x00, 0x82, 0x00, 0x03	| 408978FE
    .byte   0x00, 0x00, 0x02, 0x05, 0x00, 0x62, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x01, 0xDF	| 4089790E
    .byte   0x00, 0xFF	| 4089791E
JMFBPRIMARYINIT_418_178:
    .byte   0x00, 0xC1, 0x81, 0x32, 0x00, 0xF8, 0x00, 0x60, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40897920
    .byte   0x0D, 0x09, 0x01, 0x00, 0x06, 0x04, 0x00, 0x01, 0x01, 0x01, 0x0D, 0x06, 0x00, 0x01, 0x00, 0x00	| 40897930
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x14, 0x02, 0x66, 0x00, 0x7D, 0x00, 0x43, 0x00, 0x82, 0x00, 0x03	| 40897940
    .byte   0x00, 0x00, 0x02, 0x05, 0x00, 0x62, 0x00, 0x05, 0x00, 0x05, 0x00, 0x5E, 0x01, 0x93, 0x01, 0xDF	| 40897950
    .byte   0x00, 0xFF	| 40897960
JMFBPRIMARYINIT_418_178_42:
    .byte   0x00, 0x80, 0x01, 0x12, 0x00, 0xE0, 0x01, 0x00, 0x01, 0x00, 0x00, 0x1B, 0x00, 0xB0, 0x00, 0x00	| 40897962
    .byte   0x0C, 0x01, 0x02, 0x00, 0x07, 0x03, 0x00, 0x00, 0x00, 0x04, 0x0D, 0x06, 0x04, 0x01, 0x00, 0x00	| 40897972
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x36, 0x02, 0x7E, 0x00, 0x12, 0x00, 0x3A, 0x00, 0x3A, 0x00, 0x03	| 40897982
    .byte   0x00, 0x00, 0x01, 0xE0, 0x00, 0x21, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x01, 0xDF	| 40897992
    .byte   0x00, 0xFF	| 408979A2
JMFBPRIMARYINIT_418_178_84:
    .byte   0x00, 0xC1, 0x01, 0x32, 0x00, 0xF8, 0x00, 0xE0, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00	| 408979A4
    .byte   0x0C, 0x01, 0x02, 0x00, 0x07, 0x03, 0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x04, 0x01, 0x00, 0x00	| 408979B4
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x36, 0x02, 0x7E, 0x00, 0x12, 0x00, 0x3A, 0x00, 0x3A, 0x00, 0x03	| 408979C4
    .byte   0x00, 0x00, 0x01, 0xE0, 0x00, 0x21, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x01, 0xDF	| 408979D4
    .byte   0x00, 0xFF	| 408979E4
JMFBPRIMARYINIT_418_178_C6:
    .byte   0x00, 0x80, 0x01, 0x12, 0x00, 0xE0, 0x01, 0x00, 0x01, 0x00, 0x00, 0x1B, 0x00, 0xB0, 0x00, 0x00	| 408979E6
    .byte   0x0C, 0x01, 0x02, 0x00, 0x07, 0x03, 0x00, 0x00, 0x00, 0x04, 0x0D, 0x06, 0x04, 0x01, 0x00, 0x00	| 408979F6
    .byte   0x00, 0x03, 0x00, 0x00, 0x00, 0xF4, 0x01, 0xFE, 0x00, 0x54, 0x00, 0x3A, 0x00, 0x78, 0x00, 0x03	| 40897A06
    .byte   0x00, 0x00, 0x01, 0xB0, 0x00, 0x51, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x01, 0x7F	| 40897A16
    .byte   0x00, 0xFF	| 40897A26
JMFBPRIMARYINIT_418_178_108:
    .byte   0x00, 0xC1, 0x01, 0x32, 0x00, 0xF8, 0x00, 0xE0, 0x01, 0x00, 0x00, 0x6C, 0x00, 0xB0, 0x00, 0x00	| 40897A28
    .byte   0x0C, 0x01, 0x02, 0x00, 0x07, 0x03, 0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x04, 0x01, 0x00, 0x00	| 40897A38
    .byte   0x00, 0x03, 0x00, 0x00, 0x00, 0xF4, 0x01, 0xFE, 0x00, 0x54, 0x00, 0x3A, 0x00, 0x78, 0x00, 0x03	| 40897A48
    .byte   0x00, 0x00, 0x01, 0xB0, 0x00, 0x51, 0x00, 0x06, 0x00, 0x06, 0x00, 0x6E, 0x01, 0x4A, 0x01, 0x7F	| 40897A58
    .byte   0x00, 0xFF	| 40897A68
JMFBPRIMARYINIT_418_178_14A:
    .byte   0x00, 0x80, 0x00, 0x82, 0x00, 0xE0, 0x00, 0x50, 0x00, 0x10, 0x00, 0x2F, 0x00, 0xF0, 0x00, 0x00	| 40897A6A
    .byte   0x0E, 0x05, 0x00, 0x00, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x03, 0x0D, 0x06, 0x04, 0x01, 0x00, 0x00	| 40897A7A
    .byte   0x00, 0x03, 0x00, 0x00, 0x01, 0x00, 0x01, 0xFE, 0x00, 0x2A, 0x00, 0x1E, 0x00, 0x32, 0x00, 0x03	| 40897A8A
    .byte   0x00, 0x00, 0x03, 0x00, 0x00, 0x26, 0x00, 0x06, 0x00, 0x02, 0x00, 0x04, 0x02, 0x60, 0x01, 0x7F	| 40897A9A
    .byte   0x00, 0x0F	| 40897AAA
JMFBPRIMARYINIT_418_178_18C:
    .byte   0x00, 0xC0, 0x00, 0x82, 0x00, 0xF8, 0x00, 0x50, 0x00, 0x14, 0x00, 0x11, 0x00, 0x2D, 0x00, 0x00	| 40897AAC
    .byte   0x0F, 0x07, 0x00, 0x00, 0x05, 0x01, 0x00, 0x00, 0x00, 0x02, 0x0D, 0x06, 0x04, 0x01, 0x00, 0x00	| 40897ABC
    .byte   0x00, 0x03, 0x00, 0x00, 0x00, 0x50, 0x00, 0x9E, 0x00, 0x0A, 0x00, 0x0E, 0x00, 0x1A, 0x00, 0x03	| 40897ACC
    .byte   0x00, 0x00, 0x03, 0xC0, 0x00, 0x4E, 0x00, 0x06, 0x00, 0x06, 0x00, 0x04, 0x00, 0xC8, 0x01, 0xDF	| 40897ADC
    .byte   0x00, 0x13	| 40897AEC
JMFBPRIMARYINIT_418_178_1CE:
    .byte   0x00, 0xA0, 0x00, 0x02, 0x00, 0xF0, 0x00, 0x50, 0x00, 0x14, 0x00, 0x2B, 0x00, 0x3C, 0x00, 0x00	| 40897AEE
    .byte   0x0E, 0x07, 0x00, 0x00, 0x06, 0x01, 0x00, 0x00, 0x00, 0x01, 0x0D, 0x06, 0x04, 0x01, 0x00, 0x00	| 40897AFE
    .byte   0x00, 0x03, 0x00, 0x00, 0x00, 0xA0, 0x01, 0x3E, 0x00, 0x12, 0x00, 0x26, 0x00, 0x22, 0x00, 0x03	| 40897B0E
    .byte   0x00, 0x00, 0x06, 0xCC, 0x00, 0x54, 0x00, 0x06, 0x00, 0x06, 0x00, 0x00, 0x01, 0x78, 0x03, 0x65	| 40897B1E
    .byte   0x00, 0x13	| 40897B2E
JMFBPRIMARYINIT_418_388:
    .byte   0x00, 0xC0, 0x20, 0x02, 0x00, 0xF8, 0x00, 0x50, 0x00, 0x24, 0x00, 0x05, 0x00, 0x04, 0x00, 0x00	| 40897B30
    .byte   0x0E, 0x0B, 0x00, 0x00, 0x03, 0x01, 0x00, 0x00, 0x00, 0x01, 0x0D, 0x06, 0x04, 0x01, 0x00, 0x00	| 40897B40
    .byte   0x00, 0x03, 0x00, 0x00, 0x00, 0x90, 0x01, 0x1E, 0x00, 0x16, 0x00, 0x1E, 0x00, 0x12, 0x00, 0x03	| 40897B50
    .byte   0x00, 0x00, 0x06, 0xCC, 0x00, 0x4E, 0x00, 0x06, 0x00, 0x06, 0x00, 0x00, 0x01, 0x4C, 0x03, 0x65	| 40897B60
    .byte   0x00, 0x23, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40897B70
