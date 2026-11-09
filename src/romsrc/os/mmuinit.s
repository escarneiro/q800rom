/*
 os/mmuinit.s - top 512 KB of the ROM: MMU initialization and translation
 From TOP512KOFROM (0x40880000). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. The first part of this file
 is data (MMU set-up templates per decoder and MMU type: physical/logical ranges,
 page attributes), now written as .long/.byte (the generator had decoded it as
 instructions). INITMMU builds the MMU
 tables in the boot globals at the top of RAM (a5/fp frames), sets the translation
 control and transparent translation registers, and continues at a2 with the new
 memory map. Labels without a comment of their own are commented mechanically.
*/

/* TOP512KOFROM: start of the top 512 KB of the ROM: MMU templates (data). */
TOP512KOFROM:
MMUSTUFF_40880000:      /* (template data) */
    .long   0x80F84500, 0x00000000, 0x00000000, 0x01D40000	| 40880000
    .byte   0x08, 0xE4	| 40880010
MMUSTUFF_40880000_12:   /* (data) */
    .byte   0x80, 0xF0, 0x57, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x4A	| 40880012
    .byte   0x06, 0x82, 0x08, 0xD2	| 40880020
MMUSTUFF_40880000_24:   /* (data) */
    .byte   0x80, 0xF8, 0x45, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40880024
    .long   0x01B0FFDC, 0x08C080F0, 0x57500000, 0x00000000	| 40880030
    .long   0x00000426, 0x065E08AE, 0x80F05660, 0x00000000	| 40880040
    .long   0x00000000, 0x0414064C, 0x089C80F0, 0x55700000	| 40880050
    .long   0x00000000, 0x00000402, 0x063A088A, 0x80F05480	| 40880060
    .long   0x00000000, 0x00000000, 0x03F00628, 0x087880F0	| 40880070
    .long   0x89000000, 0x00000000, 0x000003DE, 0x06160866	| 40880080
    .long   0x80F07A00, 0x00000000, 0x00000000, 0x03CC0604	| 40880090
    .byte   0x08, 0x54	| 408800A0
MMUSTUFF_40880000_A2:   /* (data) */
    .byte   0x80, 0xF0	| 408800A2
TOP512KOFROM_A4:        /* (template data) */
    .long   0x6B000000, 0x00000000, 0x000003BA	| 408800A4
    .byte   0x05, 0xF2, 0x08, 0x42	| 408800B0
TOP512KOFROM_B4:        /* (data) */
    .byte   0x80, 0xF8, 0x45, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408800B4
    .long   0x0168FF4C	| 408800C0
    .byte   0x09, 0xF2	| 408800C4
TOP512KOFROM_C6:        /* (data) */
    .byte   0x80, 0xF0	| 408800C6
    .long   0x57500000, 0x00000000	| 408800C8
    .byte   0x00, 0x00, 0x03, 0xBE, 0x06, 0x06, 0x09, 0xE0	| 408800D0
TOP512KOFROM_D8:        /* (data) */
    .byte   0x80, 0xF8, 0x45, 0x00, 0x00, 0x00, 0x00, 0x00	| 408800D8
    .byte   0x00, 0x00, 0x00, 0x00, 0x01, 0x94, 0xFF, 0x28, 0x0B, 0x3C	| 408800E0
TOP512KOFROM_EA:        /* (data) */
    .byte   0x80, 0xF0, 0x57, 0x50, 0x00, 0x00	| 408800EA
    .long   0x00000000, 0x000003DA, 0x06320B2A	| 408800F0
TOP512KOFROM_FC:        /* (template: 24-bit map) */
    .long   0x0000C000	| 408800FC
    .long   0x00000000, 0x00000000, 0x01C8FF04	| 40880100
    .byte   0x0F, 0x80	| 4088010C
TOP512KOFROM_10E:       /* (template: 32-bit map) */
    .byte   0x00, 0x00	| 4088010E
    .long   0xC000F900, 0xC060807F, 0xC04003F6, 0x065E0F6E	| 40880110
TOP512KOFROM_120:       /* (data) */
    .long   0x80F84500, 0x00000000, 0x00000000, 0x0204FEE0	| 40880120
    .byte   0x0C, 0x62	| 40880130
TOP512KOFROM_132:       /* (data) */
    .byte   0x80, 0xF0, 0x57, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x12	| 40880132
    .long   0x068A0C50	| 40880140
TOP512KOFROM_144:       /* (data) */
    .byte   0x80, 0xD8	| 40880144
TOP512KOFROM_146:       /* (template data) */
    .byte   0x65, 0x00	| 40880146
    .long   0x00000000, 0x00000000	| 40880148
    .long   0x0218FEBC	| 40880150
    .byte   0x0C, 0x94	| 40880154
TOP512KOFROM_156:       /* (data) */
    .byte   0x80, 0xD0	| 40880156
    .long   0x7750600F, 0x8507807F	| 40880158
    .long   0x8507042E, 0x06B60C82	| 40880160
TOP512KOFROM_168:       /* (data) */
    .byte   0x80, 0xD8, 0x65	| 40880168
TOP512KOFROM_16B:       /* (template data) */
    .byte   0x00	| 4088016B
    .long   0x00000000	| 4088016C
    .byte   0x00, 0x00, 0x00, 0x00, 0x02, 0x3C, 0xFE, 0x98, 0x0E, 0x32	| 40880170
TOP512KOFROM_17A:       /* (data) */
    .byte   0x80, 0xD0, 0x77, 0x50, 0x60, 0x0F	| 4088017A
    .byte   0x85, 0x07, 0x00, 0x00, 0x00, 0x00, 0x04, 0x42, 0x06, 0xD2, 0x0E, 0x20	| 40880180
TOP512KOFROM_18C:       /* (data) */
    .byte   0x80, 0xD8, 0x65, 0x00	| 4088018C
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x50, 0xFE, 0x74, 0x10, 0x96	| 40880190
TOP512KOFROM_19E:       /* (data) */
    .byte   0x80, 0xD0	| 4088019E
    .long   0x7750600F, 0x8507807F, 0x8507046E, 0x07061084	| 408801A0
TOP512KOFROM_1B0:       /* (data) */
    .long   0x80F84500, 0x00000000, 0x00000000, 0x027CFE50	| 408801B0
    .byte   0x12, 0x34	| 408801C0
TOP512KOFROM_1C2:       /* (data) */
    .byte   0x80, 0xF0, 0x57, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x82	| 408801C2
    .long   0xFE3E1222, 0x00800000, 0x00000001, 0x00100000	| 408801D0
    .long   0x00000003, 0x00100000, 0xF9000026, 0x00100000	| 408801E0
    .long   0xFA000026, 0x00100000, 0xFB000026, 0x00100000	| 408801F0
    .long   0xFC000026, 0x00100000, 0xFD000026, 0x00100000	| 40880200
    .long   0xFE000026, 0x00100000, 0x50000026, 0x00800000	| 40880210
    .long   0x00000001, 0x00100000, 0x00000003, 0x00100000	| 40880220
    .long   0xF9000026, 0x00100000, 0xFA000026, 0x00008000	| 40880230
    .long   0x00000004, 0x000F8000, 0x00000005, 0x00100000	| 40880240
    .long   0xFC000026, 0x00100000, 0xFD000026, 0x00100000	| 40880250
    .long   0xFE000026, 0x00100000, 0x50000026, 0x00800000	| 40880260
    .long   0x00000001, 0x00100000, 0x00000003, 0x00100000	| 40880270
    .long   0xF9000026, 0x00100000, 0xFA000026, 0x00100000	| 40880280
    .long   0xFB000026, 0x00100000, 0xFC000026, 0x00100000	| 40880290
    .long   0xFD000026, 0x00008000, 0x00000004, 0x000F8000	| 408802A0
    .long   0x00000005, 0x00000000, 0x00000007, 0x00100000	| 408802B0
    .long   0x50000026, 0x00800000, 0x00000011, 0x00100000	| 408802C0
    .long   0x00000013, 0x00100000, 0xF9000036, 0x00100000	| 408802D0
    .long   0xFA000026, 0x00100000, 0xFB000026, 0x00100000	| 408802E0
    .long   0xFC000026, 0x00100000, 0xFD000026, 0x00100000	| 408802F0
    .long   0xFE000026, 0x00040000, 0x50F00026, 0x00040000	| 40880300
    .long   0x50F40036, 0x00080000, 0x00000007, 0xFF000001	| 40880310
    .long   0x00000008, 0x00800000, 0x00000001, 0x00100000	| 40880320
    .long   0x00000003, 0x00500000, 0x00000007, 0x00008000	| 40880330
    .long   0x00000004, 0x00008000, 0x00000009, 0x000F0000	| 40880340
    .long   0x00000007, 0x00100000, 0x50000026, 0x00800000	| 40880350
    .long   0x00000041, 0x00100000, 0x00000043, 0x00100000	| 40880360
    .long   0xF9000026, 0x00100000, 0xFA000026, 0x00100000	| 40880370
    .long   0xFB000026, 0x00100000, 0xFC000026, 0x00100000	| 40880380
    .long   0xFD000026, 0x00100000, 0xFE000026, 0x00100000	| 40880390
    .long   0x50F00026, 0x00800000, 0x00000041, 0x00100000	| 408803A0
    .long   0x00000043, 0x00300000, 0x00000007, 0x00100000	| 408803B0
    .long   0xFC000026, 0x00100000, 0xFD000026, 0x00100000	| 408803C0
    .long   0xFE000026, 0x00100000, 0x50F00026, 0x00800000	| 408803D0
    .long   0x00000041, 0x00100000, 0x00000043, 0x00100000	| 408803E0
    .long   0xF9000026, 0x00100000, 0xFA000026, 0x00100000	| 408803F0
    .long   0x60B00026, 0x00100000, 0xFC000026, 0x00100000	| 40880400
    .long   0xFD000026, 0x00100000, 0xFE000026, 0x000C0000	| 40880410
    .long   0x50F00026, 0x00040000, 0xFEE00026, 0x00800000	| 40880420
    .long   0x00000001, 0x00600000, 0x00000000, 0x00100000	| 40880430
    .long   0xFE000026, 0x000C0000, 0x00000020, 0x00010000	| 40880440
    .long   0x00E00026, 0x00030000, 0x00000020, 0x40000000	| 40880450
    .long   0x00000001, 0x10000000, 0x00000002, 0x20000000	| 40880460
    .long   0x00000020, 0x10000000, 0x0000000A, 0x80000000	| 40880470
    .long   0x00000020, 0x40000000, 0x00000001, 0x10000000	| 40880480
    .long   0x00000002, 0x20000000, 0x00000020, 0x10000000	| 40880490
    .long   0x0000000A, 0x7BB00000, 0x00000020, 0x00008000	| 408804A0
    .long   0x00000004, 0x000F8000, 0x00000005, 0x04400000	| 408804B0
    .long   0x00000020, 0x40000000, 0x00000001, 0x10000000	| 408804C0
    .long   0x00000002, 0x20000000, 0x00000020, 0x10000000	| 408804D0
    .long   0x0000000A, 0x7EE00000, 0x00000020, 0x00008000	| 408804E0
    .long   0x00000004, 0x000F8000, 0x00000005, 0x01100000	| 408804F0
    .long   0x00000020, 0x40800000, 0x00000011, 0x00100000	| 40880500
    .long   0x00000012, 0x10600000, 0x00000007, 0x00040000	| 40880510
    .long   0x00000020, 0x00040000, 0x00000030, 0x1F080000	| 40880520
    .long   0x00000007, 0x10000000, 0x0000001A, 0x80000000	| 40880530
    .long   0x00000007, 0x40000000, 0x00000001, 0x10000000	| 40880540
    .long   0x00000002, 0x20000000, 0x00000020, 0x10000000	| 40880550
    .long   0x0000000A, 0x7EE00000, 0x00000020, 0x00008000	| 40880560
    .long   0x00000004, 0x00008000, 0x00000009, 0x011F0000	| 40880570
    .long   0x00000020, 0x40800000, 0x00000041, 0x00100000	| 40880580
    .long   0x00000042, 0x10600000, 0x00000007, 0x0F100000	| 40880590
    .long   0x00000020, 0x10000000, 0x00000007, 0x10000000	| 408805A0
    .long   0x0000000A, 0x80000000, 0x00000007, 0x40800000	| 408805B0
    .long   0x00000041, 0x00100000, 0x00000042, 0x10600000	| 408805C0
    .long   0x00000007, 0x0F100000, 0x00000020, 0x10000000	| 408805D0
    .long   0x00000007, 0x10000000, 0x0000000A, 0x7E000000	| 408805E0
    .long   0x00000020, 0x00F60000, 0x00000020, 0x000A0000	| 408805F0
    .long   0x40800026, 0x01000000, 0x00000020, 0x40800000	| 40880600
    .long   0x00000041, 0x00100000, 0x00000042, 0x10600000	| 40880610
    .long   0x00000007, 0x0F100000, 0x00000020, 0x10000000	| 40880620
    .long   0x00000020, 0x10000000, 0x0000000A, 0x80000000	| 40880630
    .long   0x00000007, 0x00800000, 0x00000001, 0x00200000	| 40880640
    .long   0x00000000, 0x40000000, 0x00000001, 0x00400000	| 40880650
    .long   0x00A00006, 0x10100000, 0x00000007, 0x000C0000	| 40880660
    .long   0x00F00026, 0x00010000, 0x00E00026, 0x1F030000	| 40880670
    .long   0x00000020, 0x10000000, 0x0000000A, 0x80000000	| 40880680
    .long   0x00000020, 0x00010000, 0x00000001, 0x37FF0000	| 40880690
    .long   0x00000007, 0x08000000, 0x00000001, 0x10000000	| 408806A0
    .long   0x00000002, 0x20000000, 0x00000020, 0x10000000	| 408806B0
    .long   0x0000000A, 0x80000000, 0x00000020, 0x00010000	| 408806C0
    .long   0x00000001, 0x37FF0000, 0x00000007, 0x08000000	| 408806D0
    .long   0x00000001, 0x10000000, 0x00000002, 0x20000000	| 408806E0
    .long   0x00000020, 0x10000000, 0x0000000A, 0x7BB00000	| 408806F0
    .long   0x00000020, 0x00008000, 0x00000004, 0x000F8000	| 40880700
    .long   0x00000005, 0x04400000, 0x00000020, 0x00010000	| 40880710
    .long   0x00000001, 0x37FF0000, 0x00000007, 0x08000000	| 40880720
    .long   0x00000001, 0x10000000, 0x00000002, 0x20000000	| 40880730
    .long   0x00000020, 0x10000000, 0x0000000A, 0x7EE00000	| 40880740
    .long   0x00000020, 0x00008000, 0x00000004, 0x000F8000	| 40880750
    .long   0x00000005, 0x01100000, 0x00000020, 0x00010000	| 40880760
    .long   0x00000011, 0x37FF0000, 0x00000007, 0x08800000	| 40880770
    .long   0x00000011, 0x00100000, 0x00000012, 0x10600000	| 40880780
    .long   0x00000007, 0x00040000, 0x00000020, 0x00040000	| 40880790
    .long   0x00000030, 0x1F080000, 0x00000007, 0x10000000	| 408807A0
    .long   0x0000001A, 0x80000000, 0x00000007, 0x00010000	| 408807B0
    .long   0x00000001, 0x37FF0000, 0x00000007, 0x08000000	| 408807C0
    .long   0x00000001, 0x10000000, 0x00000002, 0x20000000	| 408807D0
    .long   0x00000020, 0x10000000, 0x0000000A, 0x7EE00000	| 408807E0
    .long   0x00000020, 0x00008000, 0x00000004, 0x00008000	| 408807F0
    .long   0x00000005, 0x011F0000, 0x00000020, 0x00010000	| 40880800
    .long   0x00000041, 0x37FF0000, 0x00000007, 0x08800000	| 40880810
    .long   0x00000041, 0x00100000, 0x00000002, 0x1F700000	| 40880820
    .long   0x00000020, 0x10000000, 0x00000007, 0x10000000	| 40880830
    .long   0x0000000A, 0x80000000, 0x00000007, 0x00010000	| 40880840
    .long   0x00000041, 0x37FF0000, 0x00000007, 0x08800000	| 40880850
    .long   0x00000041, 0x00100000, 0x00000002, 0x1F700000	| 40880860
    .long   0x00000020, 0x10000000, 0x00000007, 0x10000000	| 40880870
    .long   0x0000000A, 0x7E000000, 0x00000020, 0x00F60000	| 40880880
    .long   0x00000020, 0x000A0000, 0x40800026, 0x01000000	| 40880890
    .long   0x00000020, 0x00010000, 0x00000041, 0x37FF0000	| 408808A0
    .long   0x00000007, 0x08800000, 0x00000041, 0x00100000	| 408808B0
    .long   0x00000002, 0x1F700000, 0x00000020, 0x10000000	| 408808C0
    .long   0x00000007, 0x10000000, 0x0000000A, 0x80000000	| 408808D0
    .long   0x00000007, 0x00010001, 0x00000000, 0x00000000	| 408808E0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408808F0
    .long   0x00020001, 0x40000000, 0x10000000, 0x40000000	| 40880900
    .long   0x10000000, 0x00800000, 0x00100000, 0x00030000	| 40880910
    .long   0x50000000, 0x10000000, 0x50000000, 0x10000000	| 40880920
    .long   0x00F00000, 0x00100000, 0x00050000, 0x60000000	| 40880930
    .long   0x10000000, 0x60000000, 0x10000000, 0x00000000	| 40880940
    .long   0x00000000, 0x00050000, 0x90000000, 0x10000000	| 40880950
    .long   0x90000000, 0x10000000, 0x00000000, 0x00000000	| 40880960
    .long   0x00050000, 0xA0000000, 0x10000000, 0xA0000000	| 40880970
    .long   0x10000000, 0x00000000, 0x00000000, 0x00050000	| 40880980
    .long   0xB0000000, 0x10000000, 0xB0000000, 0x10000000	| 40880990
    .long   0x00000000, 0x00000000, 0x00050000, 0xC0000000	| 408809A0
    .long   0x10000000, 0xC0000000, 0x10000000, 0x00000000	| 408809B0
    .long   0x00000000, 0x00050000, 0xD0000000, 0x10000000	| 408809C0
    .long   0xD0000000, 0x10000000, 0x00000000, 0x00000000	| 408809D0
    .long   0x00050000, 0xE0000000, 0x10000000, 0xE0000000	| 408809E0
    .long   0x10000000, 0x00000000, 0x00000000, 0x00040000	| 408809F0
    .long   0xF9000000, 0x01000000, 0xF9000000, 0x01000000	| 40880A00
    .long   0x00900000, 0x00100000, 0x00040000, 0xFA000000	| 40880A10
    .long   0x01000000, 0xFA000000, 0x01000000, 0x00A00000	| 40880A20
    .long   0x00100000, 0x00040000, 0xFB000000, 0x01000000	| 40880A30
    .long   0xFB000000, 0x01000000, 0x00B00000, 0x00100000	| 40880A40
    .long   0x00040000, 0xFC000000, 0x01000000, 0xFC000000	| 40880A50
    .long   0x01000000, 0x00C00000, 0x00100000, 0x00040000	| 40880A60
    .long   0xFD000000, 0x01000000, 0xFD000000, 0x01000000	| 40880A70
    .long   0x00D00000, 0x00100000, 0x00040000, 0xFE000000	| 40880A80
    .long   0x01000000, 0xFE000000, 0x01000000, 0x00E00000	| 40880A90
    .long   0x00100000, 0xFFFF0001, 0x00010000, 0x00000000	| 40880AA0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40880AB0
    .long   0x00000002, 0x00014000, 0x00001000, 0x00004000	| 40880AC0
    .long   0x00001000, 0x00000080, 0x00000010, 0x00000003	| 40880AD0
    .long   0x00005000, 0x00001000, 0x00005000, 0x00001000	| 40880AE0
    .long   0x000000F0, 0x00000010, 0x00000005, 0x00009000	| 40880AF0
    .long   0x00001000, 0x00009000, 0x00001000, 0x00000000	| 40880B00
    .long   0x00000000, 0x00000005, 0x0000A000, 0x00001000	| 40880B10
    .long   0x0000A000, 0x00001000, 0x00000000, 0x00000000	| 40880B20
    .long   0x00000005, 0x0000C000, 0x00001000, 0x0000C000	| 40880B30
    .long   0x00001000, 0x00000000, 0x00000000, 0x00000005	| 40880B40
    .long   0x0000D000, 0x00001000, 0x0000D000, 0x00001000	| 40880B50
    .long   0x00000000, 0x00000000, 0x00000005, 0x0000E000	| 40880B60
    .long   0x00001000, 0x0000E000, 0x00001000, 0x00000000	| 40880B70
    .long   0x00000000, 0x00000004, 0x0000F900, 0x00000100	| 40880B80
    .long   0x0000F900, 0x00000100, 0x00000090, 0x00000010	| 40880B90
    .long   0x00000004, 0x0000FA00, 0x00000100, 0x0000FA00	| 40880BA0
    .long   0x00000100, 0x000000A0, 0x00000010, 0x00000004	| 40880BB0
    .long   0x0000FC00, 0x00000100, 0x0000FC00, 0x00000100	| 40880BC0
    .long   0x000000C0, 0x00000010, 0x00000004, 0x0000FD00	| 40880BD0
    .long   0x00000100, 0x0000FD00, 0x00000100, 0x000000D0	| 40880BE0
    .long   0x00000010, 0x00000004, 0x0000FE00, 0x00000100	| 40880BF0
    .long   0x0000FE00, 0x00000100, 0x000000E0, 0x00000010	| 40880C00
    .long   0x0000FFFF, 0x00010001, 0x00000000, 0x00000000	| 40880C10
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40880C20
    .long   0x00020001, 0x40000000, 0x10000000, 0x40000000	| 40880C30
    .long   0x10000000, 0x00800000, 0x00100000, 0x00030000	| 40880C40
    .long   0x50000000, 0x10000000, 0x50000000, 0x10000000	| 40880C50
    .long   0x00F00000, 0x00100000, 0x00050000, 0x90000000	| 40880C60
    .long   0x10000000, 0x90000000, 0x10000000, 0x00000000	| 40880C70
    .long   0x00000000, 0x00050000, 0xA0000000, 0x10000000	| 40880C80
    .long   0xA0000000, 0x10000000, 0x00000000, 0x00000000	| 40880C90
    .long   0x00050000, 0xB0000000, 0x10000000, 0xB0000000	| 40880CA0
    .long   0x10000000, 0x00000000, 0x00000000, 0x00050000	| 40880CB0
    .long   0xC0000000, 0x10000000	| 40880CC0
TOP512KOFROM_CC8:       /* (template data: per-decoder range lists) */
    .long   0xC0000000, 0x10000000	| 40880CC8
    .long   0x00000000, 0x00000000, 0x00050000, 0xD0000000	| 40880CD0
    .long   0x10000000, 0xD0000000, 0x10000000, 0x00000000	| 40880CE0
    .long   0x00000000, 0x00040000, 0xF9000000, 0x01000000	| 40880CF0
    .long   0xF9000000, 0x01000000, 0x00900000, 0x00100000	| 40880D00
    .long   0x00040000, 0xFA000000, 0x01000000, 0xFA000000	| 40880D10
    .long   0x01000000, 0x00A00000, 0x00100000, 0x00040000	| 40880D20
    .long   0xFB000000, 0x01000000, 0xFB000000, 0x01000000	| 40880D30
    .long   0x00B00000, 0x00100000, 0x00040000, 0xFC000000	| 40880D40
    .long   0x01000000, 0xFC000000, 0x01000000, 0x00C00000	| 40880D50
    .long   0x00100000, 0x00040000, 0xFD000000, 0x01000000	| 40880D60
    .long   0xFD000000, 0x01000000, 0x00D00000, 0x00100000	| 40880D70
    .long   0xFFFF0001, 0x00010000, 0x00000000, 0x00000000	| 40880D80
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000002	| 40880D90
    .long   0x00014000, 0x00001000, 0x00004000, 0x00001000	| 40880DA0
    .long   0x00000080, 0x00000010, 0x00000003, 0x00005000	| 40880DB0
    .long   0x00001000, 0x00005000, 0x00001000, 0x000000F0	| 40880DC0
    .long   0x00000010, 0x0000FFFF, 0x00010001, 0x00000000	| 40880DD0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40880DE0
    .long   0x00000000, 0x00020001, 0x40800000, 0x00100000	| 40880DF0
    .long   0x40800000, 0x00100000, 0x00800000, 0x00100000	| 40880E00
    .long   0x00030000, 0x50000000, 0x10000000, 0x50000000	| 40880E10
    .long   0x10000000, 0x00F00000, 0x00100000, 0x00080000	| 40880E20
    .long   0x60000000, 0x10000000, 0x60000000, 0x10000000	| 40880E30
    .long   0x00000000, 0x00000000, 0x00050000, 0x90000000	| 40880E40
    .long   0x10000000, 0x90000000, 0x10000000, 0x00000000	| 40880E50
    .long   0x00000000, 0x00050000, 0xA0000000, 0x10000000	| 40880E60
    .long   0xA0000000, 0x10000000, 0x00000000, 0x00000000	| 40880E70
    .long   0x00050000, 0xB0000000, 0x10000000, 0xB0000000	| 40880E80
    .long   0x10000000, 0x00000000, 0x00000000, 0x00050000	| 40880E90
    .long   0xC0000000, 0x10000000, 0xC0000000, 0x10000000	| 40880EA0
    .long   0x00000000, 0x00000000, 0x00050000, 0xD0000000	| 40880EB0
    .long   0x10000000, 0xD0000000, 0x10000000, 0x00000000	| 40880EC0
    .long   0x00000000, 0x00050000, 0xE0000000, 0x10000000	| 40880ED0
    .long   0xE0000000, 0x10000000, 0x00000000, 0x00000000	| 40880EE0
    .long   0x00040000, 0xF9000000, 0x01000000, 0xF9000000	| 40880EF0
    .long   0x01000000, 0x00900000, 0x00100000, 0x00040000	| 40880F00
    .long   0xFA000000, 0x01000000, 0xFA000000, 0x01000000	| 40880F10
    .long   0x00A00000, 0x00100000, 0x00040000, 0xFB000000	| 40880F20
    .long   0x01000000, 0xFB000000, 0x01000000, 0x00B00000	| 40880F30
    .long   0x00100000, 0x00040000, 0xFC000000, 0x01000000	| 40880F40
    .long   0xFC000000, 0x01000000, 0x00C00000, 0x00100000	| 40880F50
    .long   0x00040000, 0xFD000000, 0x01000000, 0xFD000000	| 40880F60
    .long   0x01000000, 0x00D00000, 0x00100000, 0x00040000	| 40880F70
    .long   0xFE000000, 0x01000000, 0xFE000000, 0x01000000	| 40880F80
    .long   0x00E00000, 0x00100000, 0xFFFF0001, 0x00010000	| 40880F90
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40880FA0
    .long   0x00000000, 0x00000002, 0x00014080, 0x00000010	| 40880FB0
    .long   0x00004080, 0x00000010, 0x00000080, 0x00000010	| 40880FC0
    .long   0x00000003, 0x00005000, 0x00001000, 0x00005000	| 40880FD0
    .long   0x00001000, 0x000000F0, 0x00000010, 0x00000008	| 40880FE0
    .long   0x00006000, 0x00001000, 0x00006000, 0x00001000	| 40880FF0
    .long   0x00000000, 0x00000000, 0x00000004, 0x0000FC00	| 40881000
    .long   0x00000100, 0x0000FC00, 0x00000100, 0x000000C0	| 40881010
    .long   0x00000010, 0x00000004, 0x0000FD00, 0x00000100	| 40881020
    .long   0x0000FD00, 0x00000100, 0x000000D0, 0x00000010	| 40881030
    .long   0x00000004, 0x0000FE00, 0x000000F6, 0x0000FE00	| 40881040
    .long   0x000000F6, 0x000000E0, 0x00000010, 0x00000004	| 40881050
    .long   0x00004080, 0x0000000A, 0x0000FEF6, 0x0000000A	| 40881060
    .long   0x00000000, 0x00000000, 0x0000FFFF, 0x00010001	| 40881070
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40881080
    .long   0x00000000, 0x00000000, 0x00020001, 0x40800000	| 40881090
    .long   0x00100000, 0x40800000, 0x00100000, 0x00800000	| 408810A0
    .long   0x00100000, 0x00030000, 0x50F00000, 0x00040000	| 408810B0
    .long   0x50F00000, 0x00040000, 0x00F00000, 0x00040000	| 408810C0
    .long   0x00030000, 0x50F40000, 0x00040000, 0x50F40000	| 408810D0
    .long   0x00040000, 0x00F40000, 0x00040000, 0x00050000	| 408810E0
    .long   0xA0000000, 0x10000000, 0xA0000000, 0x10000000	| 408810F0
    .long   0x00000000, 0x00000000, 0x00050000, 0xB0000000	| 40881100
    .long   0x10000000, 0xB0000000, 0x10000000, 0x00000000	| 40881110
    .long   0x00000000, 0x00050000, 0xC0000000, 0x10000000	| 40881120
    .long   0xC0000000, 0x10000000, 0x00000000, 0x00000000	| 40881130
    .long   0x00050000, 0xD0000000, 0x10000000, 0xD0000000	| 40881140
    .long   0x10000000, 0x00000000, 0x00000000, 0x00050000	| 40881150
    .long   0xE0000000, 0x10000000, 0xE0000000, 0x10000000	| 40881160
    .long   0x00000000, 0x00000000, 0x00080000, 0xF9000000	| 40881170
    .long   0x01000000, 0xF9000000, 0x01000000, 0x00900000	| 40881180
    .long   0x00100000, 0x00040000, 0xFA000000, 0x01000000	| 40881190
    .long   0xFA000000, 0x01000000, 0x00A00000, 0x00100000	| 408811A0
    .long   0x00040000, 0xFB000000, 0x01000000, 0xFB000000	| 408811B0
    .long   0x01000000, 0x00B00000, 0x00100000, 0x00040000	| 408811C0
    .long   0xFC000000, 0x01000000, 0xFC000000, 0x01000000	| 408811D0
    .long   0x00C00000, 0x00100000, 0x00040000, 0xFD000000	| 408811E0
    .long   0x01000000, 0xFD000000, 0x01000000, 0x00D00000	| 408811F0
    .long   0x00100000, 0x00040000, 0xFE000000, 0x01000000	| 40881200
    .long   0xFE000000, 0x01000000, 0x00E00000, 0x00100000	| 40881210
    .long   0xFFFF0001, 0x00010000, 0x00000000, 0x00000000	| 40881220
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000002	| 40881230
    .long   0x00014080, 0x00000010, 0x00004080, 0x00000010	| 40881240
    .long   0x00000080, 0x00000010, 0x00000003, 0x00005000	| 40881250
    .long   0x00001000, 0x00005000, 0x000000FC, 0x000000F0	| 40881260
    .long   0x0000000C, 0x00000008, 0x00006000, 0x00000100	| 40881270
    .long   0x00006000, 0x00000100, 0x000000B0, 0x00000010	| 40881280
    .long   0x00000005, 0x00009000, 0x00001000, 0x00009000	| 40881290
    .long   0x00001000, 0x00000000, 0x00000000, 0x00000005	| 408812A0
    .long   0x0000A000, 0x00001000, 0x0000A000, 0x00001000	| 408812B0
    .long   0x00000000, 0x00000000, 0x00000005, 0x0000B000	| 408812C0
    .long   0x00001000, 0x0000B000, 0x00001000, 0x00000000	| 408812D0
    .long   0x00000000, 0x00000005, 0x0000C000, 0x00001000	| 408812E0
    .long   0x0000C000, 0x00001000, 0x00000000, 0x00000000	| 408812F0
    .long   0x00000005, 0x0000D000, 0x00001000, 0x0000D000	| 40881300
    .long   0x00001000, 0x00000000, 0x00000000, 0x00000005	| 40881310
    .long   0x0000E000, 0x00001000, 0x0000E000, 0x00001000	| 40881320
    .long   0x00000000, 0x00000000, 0x00000004, 0x0000F900	| 40881330
    .long   0x00000100, 0x0000F900, 0x00000100, 0x00000090	| 40881340
    .long   0x00000010, 0x00000004, 0x0000FA00, 0x00000100	| 40881350
    .long   0x0000FA00, 0x00000100, 0x000000A0, 0x00000010	| 40881360
    .long   0x00000004, 0x0000FC00, 0x00000100, 0x0000FC00	| 40881370
    .long   0x00000100, 0x000000C0, 0x00000010, 0x00000004	| 40881380
    .long   0x0000FD00, 0x00000100, 0x0000FD00, 0x00000100	| 40881390
    .long   0x000000D0, 0x00000010, 0x00000004, 0x0000FE00	| 408813A0
    .long   0x00000100, 0x0000FE00, 0x00000100, 0x000000E0	| 408813B0
    .long   0x00000010, 0x00000000, 0x0000FEE0, 0x00000004	| 408813C0
    .long   0x000050FC, 0x00000004, 0x000000FC, 0x00000004	| 408813D0
    .long   0x0000FFFF, 0x00010001, 0x00000000, 0x00000000	| 408813E0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408813F0
    .long   0x00020001, 0x00A00000, 0x00100000, 0x40A00000	| 40881400
    .long   0x00100000, 0x00A00000, 0x00100000, 0x00020001	| 40881410
    .long   0x00B00000, 0x00100000, 0x40B00000, 0x00100000	| 40881420
    .long   0x00B00000, 0x00100000, 0x00020001, 0x00C00000	| 40881430
    .long   0x00100000, 0x40C00000, 0x00100000, 0x00C00000	| 40881440
    .long   0x00100000, 0x00020001, 0x00D00000, 0x00100000	| 40881450
    .long   0x40D00000, 0x00100000, 0x00D00000, 0x00100000	| 40881460
    .long   0x00030000, 0x00F00000, 0x000C0000, 0x50F00000	| 40881470
    .long   0x000C0000, 0x00F00000, 0x000C0000, 0x00050000	| 40881480
    .long   0xE0000000, 0x10000000, 0xE0000000, 0x10000000	| 40881490
    .long   0x00000000, 0x00000000, 0x00040000, 0xFE000000	| 408814A0
    .long   0x01000000, 0xFE000000, 0x01000000, 0x00E00000	| 408814B0
    .long   0x00100000, 0x00000000, 0x00E00000, 0x00010000	| 408814C0
    .long   0x50FC0000, 0x00010000, 0x00FC0000, 0x00010000	| 408814D0
    .byte   0xFF, 0xFF	| 408814E0
TOP512KOFROM_CC8_81A:   /* unsupported MMU/decoder: critical error (d7 = 15, d6 = 102) */
    movew #102,%d6
    moveq #15,%d7
    bigjmp CRITICAL

/*
 INITMMU: set up the MMU from the RAM bank table and the machine's template: sizes
 (sound buffer, video RAM in main memory, the 32-bit RAM reserved for a ROM image from
 XPRAM 0x8A), build the 24-bit and 32-bit tables, then switch to the new tables
 (68040: TT registers, SRP, TC) and continue in the remapped space. No MMU: return
 with the registers as they were.
*/
INITMMU:
    linkw %a5,#-196
    jbsr INITMMU_FA
    jbsr INITMMU_402
    cmpib #1,%fp@(-26)
    jbne INITMMU_20
    moveml %a5@(-24),%d0-%d2/%d7-%a1
    moveal %fp,%a4
    unlk %a5
    rts
INITMMU_20:             /* build the tables */
    moveal %a1,%a4
    moveal %a0,%a2
    jbsr INITMMU_622
    moveal %a2,%a0
    jbsr INITMMU_7C4
    lea %fp@(-66),%a1
    jbsr INITMMU_29E
    btst #0,%fp@(-25)
    jbne INITMMU_46
    moveal %a4,%a0
    moveal %a4,%a2
    jbsr INITMMU_7C4
INITMMU_46:             /* (32-bit tables) */
    lea %fp@(-46),%a1
    jbsr INITMMU_29E
    jbsr INITMMU_206
    cmpiw #4,%d7
    jbeq INITMMU_B0
    .short  0xF000, 0x2400	| 4088154A pflusha
    addal %d3,%a0
    addal %d3,%a1
    movec %vbr,%a5
    movew #63,%d5
INITMMU_46_22:
    addl %d3,%a5@+
    dbf %d5,INITMMU_46_22
    movec %cacr,%d5
    oriw #2056,%d5
    .short  0x4E7B, 0x5002, 0xF02B, 0x0800, 0x0004, 0xF02B, 0x0C00, 0x0008	| 40881568
    lea %a3@(-8),%fp
    lea %pc@(INITMMU_46_4A),%a5
    bras INITMMU_46_58
INITMMU_46_4A:
    lea %pc@(INITMMU_AE),%a5
    addal %d3,%a5
    moveq #0,%d5
    movec %d5,%vbr
    nop
INITMMU_46_58:
    bnes INITMMU_46_5E
    .short  0xF016, 0x4C00	| 40881592 pmove %fp@,%crp
INITMMU_46_5E:
    nop
    bnes INITMMU_46_66
    .short  0xF013, 0x4000	| 4088159A pmove %a3@,%tc
INITMMU_46_66:
    jmp %a5@
INITMMU_AE:             /* continue at a2 */
    jmp %a2@
INITMMU_B0:             /* 68040: load the TT registers, VBR, SRP and TC */
    pflusha
    movel %a3@(4),%d5
    movec %d5,%itt0
    movec %d5,%dtt0
    movel %a3@(8),%d5
    movec %d5,%itt1
    movec %d5,%dtt1
    moveq #0,%d5
    lea %pc@(INITMMU_D2),%a5
    jbra INITMMU_EE
INITMMU_D2:             /* (relocated return) */
    lea %pc@(INITMMU_AE),%a5
    addal %d3,%a5
    movec %d5,%vbr
    moveal %a3@(-4),%fp
    movel %a3@,%d5
    jbra INITMMU_EE
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408815D6
INITMMU_EE:             /* TC on? */
    jbeq INITMMU_F8
    movec %fp,%srp
    movec %d5,%tc
INITMMU_F8:             /* jump */
    jmp %a5@

INITMMU_FA:             /* save the registers, ROM physical address, MMU type, sound buffer size, XPRAM settings */
    moveml %d0-%d2/%d7-%a1,%a5@(-24)
    movel %a0@,%d0
    movel %d0,%a5@(-184)
    tstl %a0@(112)
    beqw INITMMU_112
    movel %a0@(112),%d0
INITMMU_112:            /* set %a5@(-188) */
    movel %d0,%a5@(-188)
    jbsr INITMMU_2CA
    moveb %d0,%fp@(-26)
    clrl %a5@(-172)
    clrl %a5@(-168)
    clrl %a5@(-164)
    moveb %a5@(-13),%d2
    lea %pc@(INITMMU_138),%a2
    jbra SIZESOUNDBUFFER
INITMMU_138:            /* video RAM taken from main memory (XPRAM 0xAF)? */
    movel %a0,%a5@(-192)
    movel %d0,%a5@(-196)
    movel #1879048192,%fp@(-74)
    clrl %fp@(-70)
    movel #-1,%a5@(-152)
    lea 0xffffffb6,%a0
    movel %a0,%fp@(-12)
    moveb #0xaf,%d0
    bsrw INITMMU_1DC
    andil #255,%d0
    jbeq INITMMU_19E
    moveq #0,%d3
    lea %fp@(4),%a0
INITMMU_172:            /* total RAM */
    addl %a0@+,%d3
    tstl %a0@+
    jbpl INITMMU_172
    lsrl #8,%d3
    mulul %d3,%d0
    addil #32767,%d0
    andiw #-32768,%d0
    cmpil #196608,%d0
    jbcs INITMMU_19E
    lea %fp@,%a0
    lea %a5@(-152),%a1
    jbsr INITMMU_34E
    movel %d1,%fp@(-70)
INITMMU_19E:            /* logical RAM size, XPRAM 0x8A flags (32-bit, ROM in RAM) */
    lea %fp@,%a0
    lea %a5@(-88),%a1
    jbsr INITMMU_31E
    movel %d0,%a5@(-160)
    movel %d1,%fp@(-20)
    subl %a0,%d1
    moveb #0x8a,%d0
    bsrw INITMMU_1DC
    btst #0,%d0
    jbne INITMMU_1C6
    bclr #4,%d0
    jbra INITMMU_1D2
INITMMU_1C6:            /* test bit 4 of %d0 */
    btst #4,%d0
    jbeq INITMMU_1D2
    addil #939458560,%d1
INITMMU_1D2:            /* set %fp@(-25) */
    moveb %d0,%fp@(-25)
    movel %d1,%fp@(-24)
    rts

INITMMU_1DC:            /* read XPRAM byte d0 without RAM (PRAMIO) */
    moveml %d1-%d6/%a0-%a3,%sp@-
    moveal %a5@(-8),%a0
    moveal %a5@(-4),%a1
    movel %a5@(-20),%d1
    moveq #1,%d3
    swap %d3
    movew %d0,%d3
    subqw #2,%sp
    moveal %sp,%a3
    jbsr PRAMIO
    moveq #0,%d0
    moveb %sp@+,%d0
    moveml %sp@+,%d1-%d6/%a0-%a3
    rts

INITMMU_206:            /* finish: boot globals position, new stack, physical-to-logical offsets */
    moveal %fp,%a0
    addal %fp@(-16),%a0
    addal %a5@(-156),%a0
    movel %fp@(-8),%d0
    subl %fp@(-12),%d0
    movel %a5@(-196),%d1
    addl %d0,%d1
    subl %d1,%a0@(8)
    movel %a0@(4),%d1
    addl %a0@(8),%d1
    lea %a0@(28),%a0
    movel %d1,%a0@(4)
    movel %d0,%a0@(8)
    movew #7,%a0@
    movel %sp@,%d5
    movel %fp,%d0
    addl %fp@(-24),%d0
    moveal %d0,%a4
    addl %fp@(-12),%d0
    btst #4,%fp@(-25)
    jbeq INITMMU_25E
    moveal %d0,%sp
    subil #939458560,%d0
    lsrl #1,%d0
    subal %d0,%sp
    jbra INITMMU_27A
INITMMU_25E:            /* test #2097152,%d0 */
    cmpil #2097152,%d0
    jbge INITMMU_272
    lsrl #2,%d0
    mulul #3,%d0
    jbra INITMMU_278
INITMMU_272:            /* set %d0 */
    movel #1572864,%d0
INITMMU_278:            /* set %sp */
    moveal %d0,%sp
INITMMU_27A:            /* from here: biglea MYFIRSTPROC, a1 */
    biglea MYFIRSTPROC, a1
    movel %a5@(-184),%d3
    subl %a1,%d3
    moveal %a5@(4),%a2
    addal %d3,%a2
    lea %fp@(-58),%a3
    moveml %a5@(-24),%d0-%d2/%d7-%a1
    moveal %d5,%a5
    jmp %a5@

INITMMU_29E:            /* store an MMU configuration (TC, root, TT registers) for SwapMMUMode */
    movel %a2@,%a1@(8)
    movel %a2@(4),%a1@(12)
    movel %a2@(8),%a1@(16)
    movel %d0,%a1@
    movel %a0,%a1@(4)
    cmpiw #4,%d7
    jbne INITMMU_2C2
    andil #-512,%a1@(4)
INITMMU_2C2:            /* return */
    rts
INITMMU_2C4:            /* MMU type per CPU kind */
    .short  0x0000, 0x0104, 0x0500	| 408817B6

INITMMU_2CA:            /* MMU type for this machine (0 none... 3 PMMU), with a check of the HMMU on the old machines */
    cmpiw #4,%d7
    jbhi TOP512KOFROM_CC8_81A
    moveq #0,%d0
    moveb %pc@(INITMMU_2C4,%d7:w),%d0
    cmpib #1,%d0
    jbne INITMMU_31C
    moveal %a5@(-8),%a0
    cmpib #7,%a0@(-4)
    jbeq INITMMU_31C
    movel %a0@(44),%d1
    moveal %d1,%a0
    bfclr %d1,0,8
    moveal %d1,%a1
    moveb %a1@(1024),%d2
    moveb %a0@(1024),%d1
    addqb #1,%d1
    moveb %d1,%a1@(1024)
    subqb #1,%d1
    andib #0xf7,%a0@
    cmpb %a1@(1024),%d1
    jbeq INITMMU_314
    moveq #3,%d0
    jbra INITMMU_318
INITMMU_314:            /* from here: orib #8,%a0@ */
    orib #8,%a0@
INITMMU_318:            /* set %a1@(1024) */
    moveb %d2,%a1@(1024)
INITMMU_31C:            /* return */
    rts

INITMMU_31E:            /* copy the bank table and find its total and smallest bank */
    moveml %d2-%d5,%sp@-
    moveq #0,%d1
    moveq #-1,%d0
    moveq #-1,%d5
    jbra INITMMU_336
INITMMU_32A:            /* loop: cmp */
    cmpl %d0,%d3
    jbcc INITMMU_330
    movel %d3,%d0
INITMMU_330:            /* from here: addl %d3,%d1 */
    addl %d3,%d1
    movel %d2,%d4
    addl %d3,%d4
INITMMU_336:            /* set %d2 */
    movel %a0@+,%d2
    movel %a0@+,%d3
    movel %d2,%a1@+
    movel %d3,%a1@+
    jbne INITMMU_342
    subqw #8,%a1
INITMMU_342:            /* test %d5,%d2 */
    cmpl %d5,%d2
    jbne INITMMU_32A
    moveal %d4,%a0
    moveml %sp@+,%d2-%d5
    rts

INITMMU_34E:            /* take d0 bytes off the end of RAM for the video buffer (keep it 512 KB aligned) */
    moveml %d2-%d5/%a4,%sp@-
    moveal %a0,%a2
    moveal %a1,%a3
    movel %d0,%d2
    moveq #0,%d3
INITMMU_35A:            /* loop: cmpi */
    cmpil #-1,%a2@+
    jbeq INITMMU_366
    addl %a2@+,%d3
    jbra INITMMU_35A
INITMMU_366:            /* from here: subil #1835008,%d3 */
    subil #1835008,%d3
    jble INITMMU_3FE
    cmpl %d3,%d2
    jbhi INITMMU_3FE
    addil #524288,%d2
    subql #4,%a2
    cmpil #524288,%a2@(-4)
    jbeq INITMMU_3B0
    movel %a2@(-4),%d4
    subil #524288,%d4
    movel %d4,%a2@(-4)
    addl %a2@(-8),%d4
    movel %d4,%a2@
    movel #524288,%a2@(4)
    movel #-1,%a2@(8)
    addql #8,%a2
    moveal %a2,%a4
INITMMU_3B0:            /* loop: su */
    subl %a2@-,%d2
    subql #4,%a2
    jbgt INITMMU_3B0
    moveal %a2,%a0
    jbsr INITMMU_31E
    addl %d2,%d1
    negl %d2
    movel %d2,%a2@(4)
    subl %d2,%a3@(4)
    addl %d2,%a3@
    movel %a4@(-8),%a2@(8)
    movel %a4@(-4),%a2@(12)
    movel #-1,%a2@(16)
INITMMU_3DE:            /* loop: cmpi */
    cmpil #-1,%a3@+
    jbeq INITMMU_3EA
    addql #4,%a3
    jbra INITMMU_3DE
INITMMU_3EA:            /* set %a3@(-12) */
    movel #-1,%a3@(-12)
    subil #524288,%d1
INITMMU_3F8:            /* restore registers, return */
    moveml %sp@+,%d2-%d5/%a4
    rts
INITMMU_3FE:            /* clear %d1 */
    moveq #0,%d1
    jbra INITMMU_3F8

INITMMU_402:            /* the machine's templates (by decoder kind) */
    moveml %d2-%d6/%a2,%sp@-
    moveml %a5@(-88),%d2-%d5
    moveal %a5@(-8),%a1
    movel %a5@(-24),%d6
    moveq #0,%d0
    moveb %a5@(-13),%d0
    movew %pc@(INITMMU_422,%d0:w:2),%d0
    jmp %pc@(INITMMU_422,%d0:w)
INITMMU_422:            /* offsets by decoder kind */
    .short  INITMMU_43E-INITMMU_422	| 40881914
    .short  INITMMU_43E-INITMMU_422	| 40881916
    .short  INITMMU_43E-INITMMU_422	| 40881918
    .short  INITMMU_43E-INITMMU_422	| 4088191A
    .short  INITMMU_44A-INITMMU_422	| 4088191C
    .short  INITMMU_50E-INITMMU_422	| 4088191E
    .short  INITMMU_4FC-INITMMU_422	| 40881920
    .short  INITMMU_5F0-INITMMU_422	| 40881922
    .short  INITMMU_476-INITMMU_422	| 40881924
    .short  INITMMU_482-INITMMU_422	| 40881926
    .short  INITMMU_4B0-INITMMU_422	| 40881928
    .short  INITMMU_46A-INITMMU_422	| 4088192A
    .short  INITMMU_4D6-INITMMU_422	| 4088192C
    .short  INITMMU_476-INITMMU_422	| 4088192E
INITMMU_43E:            /* continue at TOP512KOFROM_CC8_81A */
    jbra TOP512KOFROM_CC8_81A	| 40881930
    .byte   0x70, 0x02, 0x70, 0x02, 0x60, 0x00, 0x01, 0xD4	| 40881934
INITMMU_44A:            /* address %pc@(MMUSTUFF_40880000_12) */
    lea %pc@(MMUSTUFF_40880000_12),%a0	| 4088193C
    lea %pc@(MMUSTUFF_40880000),%a1	| 40881940
    tstl %d2	| 40881944
    jbne INITMMU_45C	| 40881946
    addql #1,%d4	| 40881948
    jbeq INITMMU_61C	| 4088194A
INITMMU_45C:            /* test #1,%fp@(-26) */
    cmpib #1,%fp@(-26)	| 4088194E
    jbne INITMMU_604	| 40881954
    jbra TOP512KOFROM_CC8_81A	| 40881958
INITMMU_46A:            /* address %pc@(TOP512KOFROM_19E) */
    lea %pc@(TOP512KOFROM_19E),%a0	| 4088195C
    lea %pc@(TOP512KOFROM_18C),%a1	| 40881960
    jbra INITMMU_61C	| 40881964
INITMMU_476:            /* address %pc@(TOP512KOFROM_10E) */
    lea %pc@(TOP512KOFROM_10E),%a0
    lea %pc@(TOP512KOFROM_FC),%a1
    jbra INITMMU_61C
INITMMU_482:            /* set %a0 */
    moveal %a5@(-4),%a0	| 40881974
    moveal %a0,%a1	| 40881978
    addal %a0@(8),%a1	| 4088197A
    movel %a1@,%a5@(-164)	| 4088197E
    movel %a1@(4),%a5@(-180)	| 40881982
    movel %a1@(8),%a5@(-176)	| 40881988
    movel #32768,%a5@(-168)	| 4088198E
    lea %pc@(TOP512KOFROM_132),%a0	| 40881996
    lea %pc@(TOP512KOFROM_120),%a1	| 4088199A
    jbra INITMMU_61C	| 4088199E
INITMMU_4B0:            /* set %a0 */
    moveal %a5@(-4),%a0	| 408819A2
    moveal %a0,%a1	| 408819A6
    addal %a0@(8),%a1	| 408819A8
    movel %a1@,%a5@(-164)	| 408819AC
    movel %a1@(4),%a5@(-180)	| 408819B0
    movel %a1@(8),%a5@(-176)	| 408819B6
    lea %pc@(TOP512KOFROM_156),%a0	| 408819BC
    lea %pc@(TOP512KOFROM_144),%a1	| 408819C0
    jbra INITMMU_61C	| 408819C4
INITMMU_4D6:            /* set %a0 */
    moveal %a5@(-4),%a0	| 408819C8
    moveal %a0,%a1	| 408819CC
    addal %a0@(8),%a1	| 408819CE
    movel %a1@,%a5@(-164)	| 408819D2
    movel %a1@(4),%a5@(-180)	| 408819D6
    movel %a1@(8),%a5@(-176)	| 408819DC
    lea %pc@(TOP512KOFROM_17A),%a0	| 408819E2
    lea %pc@(TOP512KOFROM_168),%a1	| 408819E6
    jbra INITMMU_61C	| 408819EA
INITMMU_4FC:            /* address %pc@(MMUSTUFF_40880000_12) */
    lea %pc@(MMUSTUFF_40880000_12),%a0	| 408819EE
    lea %pc@(MMUSTUFF_40880000),%a1	| 408819F2
    tstl %d2	| 408819F6
    jbne INITMMU_604	| 408819F8
    jbra INITMMU_61C	| 408819FC
INITMMU_50E:            /* test bit 13 of %d6 */
    btst #13,%d6	| 40881A00
    jbeq INITMMU_604	| 40881A04
    moveal %a5@(-4),%a0	| 40881A08
    moveal %a0,%a1	| 40881A0C
    addal %a0@(8),%a1	| 40881A0E
    movel %a1@,%a5@(-164)	| 40881A12
    movel %a1@(4),%a5@(-180)	| 40881A16
    movel %a1@(8),%a5@(-176)	| 40881A1C
    cmpil #-72318976,%a5@(-180)	| 40881A22
    addal %a0@,%a0	| 40881A2A
    jbne INITMMU_542	| 40881A2C
    lea %pc@(TOP512KOFROM_C6),%a3	| 40881A2E
    jbra INITMMU_546	| 40881A32
INITMMU_542:            /* address %pc@(TOP512KOFROM_EA) */
    lea %pc@(TOP512KOFROM_EA),%a3	| 40881A34
INITMMU_546:            /* from here: bfextu %a3@,8,4,%d0 */
    bfextu %a3@,8,4,%d0	| 40881A38
    moveq #0,%d6	| 40881A3C
    bset %d0,%d6	| 40881A3E
    movel %fp@(-20),%d0	| 40881A40
    moveq #0,%d1	| 40881A44
    moveal %a0@(52),%a0	| 40881A46
    moveal %a5@(-4),%a2	| 40881A4A
    jbsr INITMMU_D04	| 40881A4E
    movel %d0,%a5@(-168)	| 40881A52
    movel %fp@(-20),%d0	| 40881A56
    movel %d6,%d1	| 40881A5A
INITMMU_56A:            /* (40881A5C lea 0x79a,%a4) */
    lea 0x79a:l,%a4	| 40881A5C
    jsr %pc@(INITMMU_56A,%a4:l)	| 40881A62
    movel %d0,%a5@(-172)	| 40881A66
    jbeq INITMMU_604	| 40881A6A
    tstl %d2	| 40881A6E
    jbne INITMMU_604	| 40881A70
    subl %d0,%d3	| 40881A74
    movel %d3,%a5@(-84)	| 40881A76
    addl %d0,%d2	| 40881A7A
    movel %d2,%a5@(-88)	| 40881A7C
    subl %d0,%fp@(-24)	| 40881A80
    moveal %a3,%a0	| 40881A84
    lea %a5@(-80),%a1	| 40881A86
    tstl %fp@(-70)	| 40881A8A
    jbeq INITMMU_5A0	| 40881A8E
    addql #8,%a1	| 40881A90
INITMMU_5A0:            /* test %a1@ */
    tstl %a1@	| 40881A92
    jbmi INITMMU_5CA	| 40881A94
    tstl %fp@(-70)	| 40881A96
    jbne INITMMU_5AC	| 40881A9A
    subl %d1,%d5	| 40881A9C
INITMMU_5AC:            /* address %a5@(-88) */
    lea %a5@(-88),%a1	| 40881A9E
    movel %d4,%a1@+	| 40881AA2
    movel %d5,%a1@+	| 40881AA4
    movel %d2,%a1@+	| 40881AA6
    movel %d3,%a1@+	| 40881AA8
    tstl %fp@(-70)	| 40881AAA
    jbne INITMMU_5CA	| 40881AAE
    addl %d5,%d4	| 40881AB0
    movel %d4,%a1@+	| 40881AB2
    movel %d1,%a1@+	| 40881AB4
    moveq #-1,%d4	| 40881AB6
    movel %d4,%a1@+	| 40881AB8
    movel %d4,%a1@+	| 40881ABA
INITMMU_5CA:            /* set %d2 */
    movel #11567104,%d2	| 40881ABC
    movel %a5@(-176),%d3	| 40881AC2
    andil #16777215,%d2	| 40881AC6
    andil #16777215,%d3	| 40881ACC
    cmpl %d3,%d2	| 40881AD2
    jbne INITMMU_5EA	| 40881AD4
    lea %pc@(TOP512KOFROM_B4),%a1	| 40881AD6
    jbra INITMMU_5EE	| 40881ADA
INITMMU_5EA:            /* address %pc@(TOP512KOFROM_D8) */
    lea %pc@(TOP512KOFROM_D8),%a1	| 40881ADC
INITMMU_5EE:            /* continue at INITMMU_61C */
    jbra INITMMU_61C	| 40881AE0
INITMMU_5F0:            /* from here: subil #4096,%fp@(-12) */
    subil #4096,%fp@(-12)	| 40881AE2
    lea %pc@(TOP512KOFROM_1B0),%a1	| 40881AEA
    lea %pc@(TOP512KOFROM_1C2),%a0	| 40881AEE
    braw INITMMU_61C	| 40881AF2
INITMMU_604:            /* set %d0 */
    movel %a5@(-160),%d0	| 40881AF6
    bfffo %d0,0,0,%d0	| 40881AFA
    subqw #5,%d0	| 40881AFE
    mulsw #-18,%d0	| 40881B00
    lea %pc@(MMUSTUFF_40880000_A2,%d0:w),%a0	| 40881B04
    lea %pc@(MMUSTUFF_40880000_24),%a1	| 40881B0A
INITMMU_61C:            /* return */
    moveml %sp@+,%d2-%d6/%a2
    rts

INITMMU_622:            /* expand the template ranges (RAM, video, ROM entries) into a range list */
    moveml %a1-%a2,%sp@-
    subaw #842,%sp
    moveal %sp,%a2
    moveal %a2,%a1
    addaw %a0@(16),%a0
INITMMU_632:            /* loop: move */
    movew %a0@,%d0
    cmpiw #-1,%d0
    jbeq INITMMU_664
    cmpiw #1,%d0
    jbne INITMMU_64A
    bsrw INITMMU_69A
    lea %a0@(28),%a0
    jbra INITMMU_632
INITMMU_64A:            /* test #2,%d0 */
    cmpiw #2,%d0
    jbne INITMMU_65A
    jbsr INITMMU_76E
    lea %a0@(28),%a0
    jbra INITMMU_632
INITMMU_65A:            /* set %d0 */
    moveq #27,%d0
INITMMU_65C:            /* loop: move */
    moveb %a0@+,%a1@+
    dbf %d0,INITMMU_65C
    jbra INITMMU_632
INITMMU_664:            /* from here: subal %a2,%a1 */
    subal %a2,%a1
    movel %a1,%d1
    addql #4,%a1
    moveal %fp,%a0
    movel %fp@(-12),%d0
    subl %a1,%d0
    movel %d0,%fp@(-16)
    movel %d0,%fp@(-12)
    addal %d0,%a0
    movel %d1,%d0
    divuw #28,%d0
    movew %d0,%a0@+
    movew #28,%a0@+
    jbra INITMMU_68C
INITMMU_68A:            /* loop: move */
    moveb %a2@+,%a0@+
INITMMU_68C:            /* count down */
    dbf %d1,INITMMU_68A
    lea %sp@(842),%sp
    moveml %sp@+,%a1-%a2
    rts

INITMMU_69A:            /* RAM ranges of the template */
    moveml %d2-%d4/%a3-%a4,%sp@-
    movel %a5@(-168),%d0
    jbeq INITMMU_6D6
    movel %a5@(-164),%d4
    moveq #8,%d1
    movel %a5@(-180),%d2
    movel %a5@(-176),%d3
    jbsr INITMMU_756
    addl %d0,%d2
    addl %d0,%d3
    movel #32768,%d0
    moveq #9,%d1
    jbsr INITMMU_756
    movel %a5@(-180),%d2
    subl %d0,%d2
    movel %a5@(-176),%d3
    subl %d0,%d3
    bsrw INITMMU_756
INITMMU_6D6:            /* test %fp@(-70) */
    tstl %fp@(-70)
    jbeq INITMMU_6FC
    moveq #10,%d1
    movel %fp@(-74),%d2
    moveq #0,%d3
    lea %a5@(-152),%a3
INITMMU_6E8:            /* loop: move */
    movel %a3@+,%d4
    movel %a3@+,%d0
    cmpil #-1,%d4
    jbeq INITMMU_6FC
    bsrw INITMMU_756
    addl %d0,%d2
    jbra INITMMU_6E8
INITMMU_6FC:            /* set %d0 */
    moveq #6,%d0
    lea %a5@(-88),%a3
INITMMU_702:            /* loop: movem */
    moveml %a3@+,%d1-%d2
    cmpil #-1,%d1
    jbeq INITMMU_726
    moveal %a1,%a4
    movew %d0,%a1@+
    movew #1,%a1@+
    movel %d1,%a1@+
    movel %d2,%a1@+
    clrl %a1@+
    clrl %a1@+
    clrl %a1@+
    clrl %a1@+
    moveq #1,%d0
    jbra INITMMU_702
INITMMU_726:            /* set %d0 */
    movel %a4,%d0
    subl %a2,%d0
    addql #4,%d0
    movel %d0,%a5@(-156)
    moveq #27,%d0
INITMMU_732:            /* loop: move */
    moveb %a4@+,%a1@+
    dbf %d0,INITMMU_732
    movel %a5@(-196),%d0
    jbeq INITMMU_750
    clrw %a1@+
    clrw %a1@+
    movel %a5@(-192),%a1@+
    movel %d0,%a1@+
    clrl %a1@+
    movel %d0,%a1@+
    clrl %a1@+
    movel %d0,%a1@+
INITMMU_750:            /* restore registers, return */
    moveml %sp@+,%d2-%d4/%a3-%a4
    rts

INITMMU_756:            /* set %a1@+ */
    movew %d1,%a1@+
    clrw %a1@+
    movel %d4,%a1@+
    movel %d0,%a1@+
    movel %d2,%a1@+
    movel %d0,%a1@+
    movel %d3,%a1@
    andil #16777215,%a1@+
    movel %d0,%a1@+
    rts

INITMMU_76E:            /* from here: exg %d1,%a3 */
    exg %d1,%a3
    movew %a0@,%a1@+
    movew %a0@(2),%a1@+
    movel %a0@(8),%d0
    cmpil #268435456,%d0
    jbne INITMMU_7AA
    biglea MYFIRSTPROC, a3
    movel %a3,%a1@+
    movel %a3@(64),%d0
    movel %d0,%a1@+
    exg %d1,%a3
    movel %a5@(-184),%d1
    movel %d1,%a1@+
    movel %d0,%a1@+
    andil #16777215,%d1
    movel %d1,%a1@+
    movel %d0,%a1@+
    jbra INITMMU_7C0
INITMMU_7AA:            /* set %a1@+ */
    movel %a0@(4),%a1@+
    movel %d0,%a1@+
    movel %a0@(12),%a1@+
    movel %a0@(16),%a1@+
    movel %a0@(20),%a1@+
    movel %a0@(24),%a1@+
INITMMU_7C0:            /* from here: exg %d1,%a3 */
    exg %d1,%a3
    rts

INITMMU_7C4:            /* from here: linkl %a4,#-196766 */
    linkl %a4,#-196766
    moveml %d2/%a1,%sp@-
    movel %a0,%a4@(-4)
    movew %a0@(12),%d0
    btst #4,%fp@(-25)
    jbeq INITMMU_7E2
    movew %a0@(14),%d0
INITMMU_7E2:            /* from here: addaw %d0,%a0 */
    addaw %d0,%a0
    movel %a0,%a4@(-8)
    lea %a5@(-88),%a0
    lea %a4@(-80),%a1
    jbsr INITMMU_31E
    lea %a5@(-152),%a0
    lea %a4@(-144),%a1
    jbsr INITMMU_31E
    movel %a5@(-164),%a4@(-148)
    movel %a5@(-172),%a4@(-152)
    jbsr INITMMU_81A
    jbsr INITMMU_B66
    moveml %sp@+,%d2/%a1
    unlk %a4
    rts

INITMMU_81A:            /* set %sp@- */
    movel %d2,%sp@-
    lea %a4@(-158),%a0
    movel %a0,%a4@(-16)
    clrl %a4@(-12)
    clrw %a4@(-154)
    moveq #1,%d0
    jbsr INITMMU_83A
    moveq #0,%d2
    jbsr INITMMU_A72
    movel %sp@+,%d2
    rts

INITMMU_83A:            /* save registers */
    moveml %d2-%d4,%sp@-
    movew %d0,%d2
    jbsr INITMMU_B0E
    movel %d0,%d3
    movel %d1,%d4
    jbra INITMMU_84C
INITMMU_84A:            /* call INITMMU_856 (loop) */
    jbsr INITMMU_856
INITMMU_84C:            /* count down */
    dbf %d4,INITMMU_84A
    moveml %sp@+,%d2-%d4
    rts

INITMMU_856:            /* call INITMMU_888 */
    jbsr INITMMU_888
    moveb %pc@(INITMMU_860,%d0:w),%d0
    jmp %pc@(INITMMU_860,%d0:w)
INITMMU_860:            /* (data) */
    .short  0x040A, 0x1026	| 40881D52
    jbsr INITMMU_A4E
    jbra INITMMU_886
    jbsr INITMMU_A6A
    jbra INITMMU_886
    jbsr INITMMU_A1E
    jbeq INITMMU_882
    movew %d2,%d0
    addqw #1,%d0
    jbsr INITMMU_83A
    jbsr INITMMU_A72
    jbra INITMMU_886
INITMMU_882:            /* call INITMMU_A6A */
    jbsr INITMMU_A6A
INITMMU_886:            /* return */
    rts

INITMMU_888:            /* save registers */
    moveml %d3-%d5,%sp@-
    moveal %a4@(-8),%a0
    moveq #0,%d5
    movel %a4@(-12),%d0
INITMMU_896:            /* loop: move */
    movel %a0@,%d1
    movel %d0,%d4
    subl %d5,%d4
    cmpl %d4,%d1
    jbhi INITMMU_8A6
    addl %d1,%d5
    addql #8,%a0
    jbra INITMMU_896
INITMMU_8A6:            /* set %d0 */
    movel %d3,%d0
    addl %d4,%d3
    cmpl %d3,%d1
    jbcc INITMMU_8B4
    moveq #2,%d0
    jbra INITMMU_966
INITMMU_8B4:            /* set %d3 */
    movel %a0@(4),%d3
    movel %d3,%d5
    andil #15,%d5
    moveb %pc@(INITMMU_8C8,%d5:w),%d5
    jmp %pc@(INITMMU_8C8,%d5:w)
INITMMU_8C8:            /* (data) */
    .short  0x0C12, 0x223C	| 40881DBA cmpib #60,%a2@
    .byte   0x44, 0x4A, 0x5C, 0x1E, 0x18, 0x50, 0x56, 0x00	| 40881DBE
    moveal %a4@(-12),%a0
    jbra INITMMU_930
    jbsr INITMMU_96C
    jbra INITMMU_932
    movew #1,%a4@(-154)
    moveq #1,%d0
    jbra INITMMU_932
    movel %a5@(-188),%d0
    cmpiw #4,%d7
    jbeq INITMMU_900
    btst #6,%d3
    jbne INITMMU_900
    andil #-16777216,%d0
INITMMU_900:            /* set %a0 */
    moveal %d0,%a0
    jbra INITMMU_908
    moveal %a5@(-188),%a0
INITMMU_908:            /* from here: addal %d4,%a0 */
    addal %d4,%a0
    jbra INITMMU_930
    moveal %a5@(-164),%a0
    jbra INITMMU_930
    jbsr INITMMU_9AC
    jbra INITMMU_932
    moveal %a5@(-164),%a0
    jbra INITMMU_930
    jbsr INITMMU_9E0
    jbra INITMMU_932
    movel %d3,%d0
    andil #-65536,%d0
    moveal %d0,%a0
    addal %d4,%a0
INITMMU_930:            /* clear %d0 */
    moveq #0,%d0
INITMMU_932:            /* test #4,%d7 */
    cmpiw #4,%d7
    jbeq INITMMU_94E
    btst #6,%d3
    jbeq INITMMU_946
    andil #32,%d3
    jbra INITMMU_954
INITMMU_946:            /* from here: andil #32,%d3 */
    andil #32,%d3
    jbra INITMMU_962
INITMMU_94E:            /* from here: andil #48,%d3 */
    andil #48,%d3
INITMMU_954:            /* call INITMMU_A1E */
    jbsr INITMMU_A1E
    jbeq INITMMU_962
    cmpiw #0,%d0
    jbne INITMMU_962
    moveq #2,%d0
INITMMU_962:            /* from here: lsll #1,%d3 */
    lsll #1,%d3
    movew %d3,%d1
INITMMU_966:            /* restore registers, return */
    moveml %sp@+,%d3-%d5
    rts

INITMMU_96C:            /* address %a4@(-80) */
    lea %a4@(-80),%a0
    movel %d0,%d1
    moveq #1,%d0
INITMMU_974:            /* loop: cmpi */
    cmpil #-1,%a0@+
    jbeq INITMMU_9AA
    tstl %a0@+
    jbeq INITMMU_974
    moveq #2,%d0
    cmpl %a0@(-4),%d1
    jbhi INITMMU_9AA
    cmpiw #4,%d7
    jbeq INITMMU_994
    btst #6,%d3
    jbeq INITMMU_99A
INITMMU_994:            /* call INITMMU_A1E */
    jbsr INITMMU_A1E
    jbne INITMMU_9A8
INITMMU_99A:            /* set %d0 */
    movel %a0@(-8),%d0
    addl %d1,%a0@(-8)
    subl %d1,%a0@(-4)
    moveal %d0,%a0
INITMMU_9A8:            /* clear %d0 */
    moveq #0,%d0
INITMMU_9AA:            /* return */
    rts

INITMMU_9AC:            /* set %d1 */
    movel %d0,%d1
    moveal %a5@(-164),%a0
    tstl %a4@(-152)
    jbeq INITMMU_9DC
    moveq #2,%d0
    cmpl %a4@(-152),%d1
    jbhi INITMMU_9DE
    cmpiw #4,%d7
    jbeq INITMMU_9CC
    btst #6,%d3
    jbeq INITMMU_9D0
INITMMU_9CC:            /* call INITMMU_A1E */
    jbsr INITMMU_A1E
    jbne INITMMU_9DC
INITMMU_9D0:            /* set %a0 */
    moveal %a4@(-148),%a0
    addl %d1,%a4@(-148)
    subl %d1,%a4@(-152)
INITMMU_9DC:            /* clear %d0 */
    moveq #0,%d0
INITMMU_9DE:            /* return */
    rts

INITMMU_9E0:            /* address %a4@(-144) */
    lea %a4@(-144),%a0
    movel %d0,%d1
    moveq #1,%d0
INITMMU_9E8:            /* loop: cmpi */
    cmpil #-1,%a0@+
    jbeq INITMMU_A1C
    tstl %a0@+
    jbeq INITMMU_9E8
    moveq #2,%d0
    cmpl %a0@(-4),%d1
    jbhi INITMMU_A1C
    cmpiw #4,%d7
    jbeq INITMMU_A08
    btst #6,%d3
    jbeq INITMMU_A0C
INITMMU_A08:            /* call INITMMU_A1E */
    jbsr INITMMU_A1E
    jbne INITMMU_A1A
INITMMU_A0C:            /* set %d0 */
    movel %a0@(-8),%d0
    addl %d1,%a0@(-8)
    subl %d1,%a0@(-4)
    moveal %d0,%a0
INITMMU_A1A:            /* clear %d0 */
    moveq #0,%d0
INITMMU_A1C:            /* return */
    rts

INITMMU_A1E:            /* save registers */
    moveml %d0/%a0,%sp@-
    cmpiw #4,%d7
    jbne INITMMU_A2E
    cmpiw #3,%d2
    jbra INITMMU_A48
INITMMU_A2E:            /* test #4,%d2 */
    cmpiw #4,%d2
    jbeq INITMMU_A48
    moveq #0,%d0
    movew %d2,%d0
    addqw #1,%d0
    lslw #2,%d0
    addiw #12,%d0
    moveal %a4@(-4),%a0
    bfextu %a0@,%d0,4,%d0
INITMMU_A48:            /* restore registers, return */
    moveml %sp@+,%d0/%a0
    rts

INITMMU_A4E:            /* clear %d0 */
    moveq #0,%d0
    movew %d2,%d0
    lslw #3,%d0
    orw %d1,%d0
    addl %a0,%d0
    addqw #1,%d0
INITMMU_A5A:            /* loop: add */
    addl %d3,%a4@(-12)
INITMMU_A5E:            /* loop: movea */
    moveal %a4@(-16),%a0
    movel %d0,%a0@-
    movel %a0,%a4@(-16)
    rts

INITMMU_A6A:            /* clear %d0 */
    moveq #0,%d0
    movew %d2,%d0
    lslw #3,%d0
    jbra INITMMU_A5A

INITMMU_A72:            /* test #4,%d7 */
    cmpiw #4,%d7
    jbne INITMMU_A80
    moveal #2147418112,%a0
    jbra INITMMU_A82
INITMMU_A80:            /* call INITMMU_A96 */
    jbsr INITMMU_A96
INITMMU_A82:            /* clear %d0 */
    moveq #0,%d0
    movew %d2,%d0
    lslw #3,%d0
    tstw %a0
    jbne INITMMU_A94
    addqw #2,%d0
    addl %a0,%d0
    oriw #-1024,%d0
INITMMU_A94:            /* continue at INITMMU_A5E */
    jbra INITMMU_A5E

INITMMU_A96:            /* set %sp@- */
    movel %d3,%sp@-
    jbsr INITMMU_ABE
    movew %d0,%d3
    jbsr INITMMU_ACA
    movew %d0,%d1
    orw %d3,%d0
    jbne INITMMU_AAC
    moveal #2147418112,%a0
    jbra INITMMU_ABA
INITMMU_AAC:            /* test %d1,%d3 */
    cmpw %d1,%d3
    jbhi INITMMU_AB6
    movew %d1,%d0
    jbsr INITMMU_AE2
    jbra INITMMU_ABA
INITMMU_AB6:            /* set %d0 */
    movew %d3,%d0
    jbsr INITMMU_AC2
INITMMU_ABA:            /* set %d3 */
    movel %sp@+,%d3
    rts

INITMMU_ABE:            /* result 0 */
    moveq #0,%d0
    rts

INITMMU_AC2:            /* set %a0 */
    moveal #2147418112,%a0
    rts

INITMMU_ACA:            /* clear %d0 */
    moveq #0,%d0
    moveal %a4@(-16),%a0
INITMMU_AD0:            /* loop: move */
    movel %a0@+,%d1
    bfextu %d1,30,2,%d1
    jbne INITMMU_AE0
    addqw #1,%d0
    cmpal %a4@(-158),%a0
    jbne INITMMU_AD0
INITMMU_AE0:            /* return */
    rts

INITMMU_AE2:            /* set %sp@- */
    movel %d2,%sp@-
    exg %d2,%d0
    addqw #1,%d0
    jbsr INITMMU_B0E
    cmpw %d2,%d1
    jblt INITMMU_AFE
    subw %d2,%d1
    subqw #1,%d1
    swap %d1
    clrw %d1
    moveal %d1,%a0
    moveq #0,%d0
    movew %d2,%d0
    jbra INITMMU_B04
INITMMU_AFE:            /* set %d0 */
    movel %d1,%d0
    moveaw #1,%a0
INITMMU_B04:            /* from here: lsll #2,%d0 */
    lsll #2,%d0
    addl %d0,%a4@(-16)
    movel %sp@+,%d2
    rts

INITMMU_B0E:            /* save registers */
    moveml %d2-%d3,%sp@-
    moveal %a4@(-4),%a0
    cmpiw #4,%d7
    jbne INITMMU_B3A
    moveq #0,%d2
    moveq #0,%d3
    subqw #1,%d0
    moveb %pc@(INITMMU_B60:w,%d0:w:2),%d2	| 40882014
    moveb %pc@(INITMMU_B61:w,%d0:w:2),%d3
    moveq #14,%d0
    btst %d0,%a0@
    jbeq INITMMU_B38
    subqw #1,%d2
    addqw #1,%d3
INITMMU_B38:            /* continue at INITMMU_B52 */
    jbra INITMMU_B52
INITMMU_B3A:            /* set %d2 */
    moveq #32,%d2
    bfextu %a0@,12,4,%d1
    subl %d1,%d2
    moveq #16,%d1
    subqw #1,%d0
INITMMU_B46:            /* loop: bfextu */
    bfextu %a0@,%d1,4,%d3
    subl %d3,%d2
    addqw #4,%d1
    dbf %d0,INITMMU_B46
INITMMU_B52:            /* clear %d0 */
    moveq #0,%d0
    bset %d2,%d0
    moveq #0,%d1
    bset %d3,%d1
    moveml %sp@+,%d2-%d3
    rts
INITMMU_B60:            /* (data) */
    .byte   0x19	| 40882052
INITMMU_B61:            /* (data) */
    .byte   0x07, 0x12, 0x07, 0x0D, 0x05	| 40882053

INITMMU_B66:            /* address %a4@(-158) */
    lea %a4@(-158),%a0
    movel %a0,%a4@(-16)
    moveq #1,%d0
    jbsr INITMMU_B9A
    tstw %a4@(-154)
    jbeq INITMMU_B7C
    jbsr INITMMU_CA8
INITMMU_B7C:            /* (movel %a4@(0xfffffffffffffff0)@(0xfffffffffffffffc) */
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    movel %a4@(0xfffffffffffffff0,%za0)@(0xfffffffffffffffc),%d1	| 4088206E
    addw %d0,%d1
    andiw #3,%d1
    cmpib #3,%fp@(-26)
    jbne INITMMU_B96
    bset #9,%d1
INITMMU_B96:            /* set %d0 */
    movel %d1,%d0
    rts

INITMMU_B9A:            /* save registers */
    moveml %d2-%d4/%a1-%a2,%sp@-
    movel %d0,%d4
    jbsr INITMMU_BE0
    movew %d0,%d3
    movew %d1,%d2
    jbsr INITMMU_C18
    moveal %a0,%a1
    moveal %a0,%a2
    jbra INITMMU_BD0
INITMMU_BAE:            /* (movel %a4@(0xfffffffffffffff0)@(0xfffffffffffffffc) */
    movel %a4@(0xfffffffffffffff0,%za0)@(0xfffffffffffffffc),%d0	| 408820A0
    bfextu %d0,27,2,%d1
    cmpw %d1,%d4
    jbcc INITMMU_BCA
    movew %d4,%d0
    addqw #1,%d0
    jbsr INITMMU_B9A
    jbsr INITMMU_C52
    jbra INITMMU_BD0
INITMMU_BCA:            /* from here: jbne INITMMU_BDE */
    jbne INITMMU_BDE
    jbsr INITMMU_C7E
INITMMU_BD0:            /* count down */
    dbf %d3,INITMMU_BAE
    moveal %a2,%a0
    movew %d2,%d0
    moveml %sp@+,%d2-%d4/%a1-%a2
    rts
INITMMU_BDE:            /* _Debugger */
    _Debugger

INITMMU_BE0:            /* save registers */
    moveml %d2-%d4,%sp@-
    movew %d0,%d2
    moveal %a4@(-16),%a0
    moveq #0,%d1
    moveq #0,%d0
INITMMU_BEE:            /* loop: move */
    movel %a0@-,%d3
    bfextu %d3,27,2,%d4
    cmpw %d4,%d2
    jbhi INITMMU_C12
    jbne INITMMU_BEE
    addqw #1,%d0
    bfextu %d3,30,2,%d4
    cmpiw #2,%d4
    jbne INITMMU_BEE
    swap %d3
    cmpiw #32767,%d3
    jbeq INITMMU_BEE
    moveq #1,%d1
    jbra INITMMU_BEE
INITMMU_C12:            /* restore registers, return */
    moveml %sp@+,%d2-%d4
    rts

INITMMU_C18:            /* from here: andil #65535,%d0 */
    andil #65535,%d0
    addqw #2,%d1
    extl %d1
    lsll %d1,%d0
    movel %fp,%d1
    addl %fp@(-12),%d1
    subl %d0,%d1
    cmpiw #4,%d7
    jbne INITMMU_C3C
    lea %pc@(INITMMU_C4A),%a0
    andw %a0@(0x0,%d4:w:2),%d1
    jbra INITMMU_C40
INITMMU_C3C:            /* from here: andib #0xf0,%d1 */
    andib #0xf0,%d1
INITMMU_C40:            /* set %a0 */
    moveal %d1,%a0
    subl %fp,%d1
    movel %d1,%fp@(-12)
    rts
INITMMU_C4A:            /* (data) */
    .long   0x0000FE00	| 4088213C
    .long   0xFE00FF00	| 40882140

INITMMU_C52:            /* subtract 4 to %a4@(-16) */
    subql #4,%a4@(-16)
    movel %a4@(0xfffffffffffffff0,%za0)@(0),%d1	| 40882148
    addw %d0,%d1
    bfextu %d1,30,2,%d0
    tstw %d2
    jbne INITMMU_C70
    addl %a0,%d0
    bset #3,%d0
    movel %d0,%a1@+
    jbra INITMMU_C7C
INITMMU_C70:            /* from here: bfclr %d1,24,6 */
    bfclr %d1,24,6
    bset #3,%d1
    movel %d1,%a1@+
    movel %a0,%a1@+
INITMMU_C7C:            /* return */
    rts

INITMMU_C7E:            /* subtract 4 to %a4@(-16) */
    subql #4,%a4@(-16)
    movel %a4@(0xfffffffffffffff0,%za0)@(0),%d0	| 40882174
    bfextu %d0,25,7,%d1
    andiw #-256,%d0
    bfset %d1,27,2
    tstw %d2
    jbne INITMMU_C9E
    addl %d0,%d1
    movel %d1,%a1@+
    jbra INITMMU_CA6
INITMMU_C9E:            /* from here: bfset %d1,1,21 */
    bfset %d1,1,21
    movel %d1,%a1@+
    movel %d0,%a1@+
INITMMU_CA6:            /* return */
    rts

INITMMU_CA8:            /* save registers */
    moveml %d2/%a1-%a2,%sp@-
    moveal %a0,%a2
    movew #2,%d0
    jbsr INITMMU_B0E
    mulul %d1,%d0
    moveq #24,%d2
    lsrl %d2,%d0
    andil #65535,%d1
    divuw %d0,%d1
    movel %a2@,%d2
    andil #-16,%d2
    moveal %d2,%a1
    subql #2,%d0
    moveal %a1,%a0
    lsll #2,%d1
INITMMU_CD6:            /* loop: adda */
    addal %d1,%a0
    moveq #0,%d2
INITMMU_CDA:            /* loop: move */
    movel %a1@(0x0,%d2:w),%a0@(0x0,%d2:w)
    addql #4,%d2
    cmpl %d2,%d1
    jbne INITMMU_CDA
    dbf %d0,INITMMU_CD6
    moveq #1,%d0
    jbsr INITMMU_B0E
    moveal %a2,%a1
    addql #4,%a1
    subqw #2,%d1
INITMMU_CF6:            /* loop: move */
    movel %a2@,%a1@+
    dbf %d1,INITMMU_CF6
    moveal %a2,%a0
    moveml %sp@+,%d2/%a1-%a2
    rts
INITMMU_D04:            /* continue at TRANS_4C */
    jbra TRANS_4C	| 408821F6
TRANS:                  /* (data) */
    .long   0x00000040, 0x00200000	| 408821F8
    .long   0x00000040, 0x00300000	| 40882200
    .short  0x0002, 0xAC00	| orib #0,%d2
    .short  0x0000, 0x5580	| orib #0x80,%d0
    .short  0x0001, 0x5600	| orib #0,%d1
    .short  0x0000, 0xA600	| orib #0,%d0
    orib #0,%d3
    .short  0x0000, 0x6000	| orib #0,%d0
    .short  0x0001, 0x8000	| orib #0,%d1
    .short  0x0000, 0xC000	| orib #0,%d0
    .short  0x0004, 0xB000	| orib #0,%d4
    .short  0x0000, 0x9600	| orib #0,%d0
    .short  0x0002, 0x5800	| orib #0,%d2
    .short  0x0001, 0x2C00	| orib #0,%d1
    .short  0x0004, 0x3F80	| orib #0x80,%d4
    .short  0x0001, 0x0FE0	| orib #0xe0,%d1
    .short  0x0002, 0x1FC0	| orib #0xc0,%d2
TRANS_4C:               /* save registers */
    moveml %d1-%d4/%a0,%sp@-
    movel %d1,%sp@-
    moveq #56,%d4
    andb %a0@(16),%d4
    lsrb #3,%d4
    moveq #0,%d3
    cmpil #1572864,%d0
    jbge TRANS_68
    bset #3,%d3
TRANS_68:               /* set %a0 */
    moveal %a2,%a0
    addal %a2@(8),%a0
    moveq #0,%d2
    moveb %a0@(13),%d2
    movew %d2,%d0
    addqw #4,%d0
    jbsr INITMMU_1DC
    eorb %d3,%d0
    btst #3,%d0
    jbne TRANS_A6
    movew %d2,%d0
    addqw #3,%d0
    jbsr INITMMU_1DC
    bclr #7,%d0
    movew %d0,%d3
    andil #7,%d0
    moveq #0,%d1
    movew %pc@(TRANS,%d4:w:2),%d1
    jbeq TRANS_DA
    cmpb %d0,%d4
    jbeq TRANS_B2
TRANS_A6:               /* test bit 3 of %d3 */
    btst #3,%d3
    jbeq TRANS_B0
    bclr #4,%d3
TRANS_B0:               /* from here: orb %d4,%d3 */
    orb %d4,%d3
TRANS_B2:               /* address %pc@(TRANS) */
    lea %pc@(TRANS),%a0
    moveq #0,%d1
    movew %pc@(TRANS,%d4:w:2),%d1
    jbeq TRANS_DA
    addal %d1,%a0
    lsrw #3,%d3
    movel %a0@(0x0,%d3:w:4),%d1
    movel %sp@,%d0
    jbeq TRANS_DA
    movel %d1,%d2
    divull %d0,%d3,%d2
    tstl %d3
    jbeq TRANS_DA
    subl %d3,%d0
    addl %d0,%d1
TRANS_DA:               /* set %d0 */
    movel %d1,%d0
    movel %sp@+,%d1
    moveml %sp@+,%d1-%d4/%a0
    rts
    .fill   0xDCB, 1, 0x00
TRANS_EAF:              /* (unused, zeros) */
    .fill   0xF59, 1, 0x00
