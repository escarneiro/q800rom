/* declrom/declrom.s - motherboard NuBus declaration ROM, filler, format block (0x408F0000..)

 The motherboard's NuBus declaration ROM, as seen by the Slot Manager through slot 0: it
 describes the built-in hardware (CPU, video, Ethernet...) with sResources, like a NuBus
 card does (Apple, Designing Cards and Drivers for the Macintosh Family, chapter 8). The
 Slot Manager reads it from the end: the format block (DECL_FORMAT_BLOCK, the ROM's last 20
 bytes) gives the offset of the sResource directory, and the extended header just below it
 (DECL_EXT_HEADER) a SuperInit record (DECL_SUPERINIT, whose code picks the directory for
 this machine) and the list of directories (DECL_DIRECTORIES). A directory is a list of
 entries, one byte ID and a 24-bit offset relative to the entry, ending with 0xFF; each
 sResource is such a list too (sRsrcType, sRsrcName, driver directory, video modes...).
 Pools 7E and 7F hold the sResources of the machine families this ROM supports (built-in
 video of each model, CPUs, Ethernet). The 24-bit offsets are written as label
 expressions and stamped after linking (romsrc/relocs.lst, tools/rom_postlink.py). The
 drivers in the sResources' driver directories (sRsrcDrvrDir) are the built-in video
 drivers (RBV, V8, DAFB, TIM, DBLite, Sonora) and an Ethernet driver; they are installed
 by the Slot Manager at start-up. Comments come
 from the structure and the documented fields and calls.
*/

/* Filler up to the declaration data (unused ROM space). */
DECLROM_AREA:
    FILL_408F0000

/* The list of sResource directories (one per group of machines): ID, offset of the directory. */
DECL_DIRECTORIES:  /* the sResource directories; DECL_EXT_HEADER points here, DECL_SUPERINIT picks one */
    .byte   0x01, 0x00, 0x00, 0x10	/* 408F2C94 s24 -> DECL_SRSRC_DIR (the standard directory) */
DECL_DIRECTORIES_7E_entry:
    .byte   0x7E, 0x00, 0x00, 0x3A	| 408F2C98 s24 -> DECL_POOL_7E
DECL_DIRECTORIES_7F_entry:  /* (408F2C9C s24 -> DECL_POOL_7F) */
    .byte   0x7F, 0x00, 0x00, 0x9A	| 408F2C9C s24 -> DECL_POOL_7F
    .long   0xFF000000	/* 408F2CA0 end of list */

/* The standard sResource directory (the one the format block points to): for an unknown machine. */
DECL_SRSRC_DIR:
    .byte   0x01, 0x00, 0x00, 0x08	| 408F2CA4 s24 -> DECL_SR_01_Unknown_Macintosh
    .long   0xFF000000	| 408F2CA8
DECL_SR_01_Unknown_Macintosh:  /* sResource 01: Unknown Macintosh (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x09, 0x56	| 408F2CAC s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR_01_Unknown_Macintosh_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F2CB0 s24 -> DECL_NAME_Unknown_Macintosh
    .long   0x20000000	| 408F2CB4
DECL_SR_01_Unknown_Macintosh_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x09, 0x52	| 408F2CB8 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
    .long   0xFF000000	| 408F2CBC
DECL_NAME_Unknown_Macintosh:  /* name string (C string) */
    .ascii  "Unknown Macintosh\000"
DECL_POOL_7E:           /* sResource directory pool 7E: the sResources of one group of machines (ID, offset) */
    .byte   0x15, 0x00, 0x05, 0x2A	| 408F2CD2 s24 -> DECL_SR7E_15_MacAA_Built_In_Video
DECL_POOL_7E_16_entry:  /* entry: sResource 16 */
    .byte   0x16, 0x00, 0x05, 0x6A	| 408F2CD6 s24 -> DECL_SR7E_16_Death_of_a_Macintosh
DECL_POOL_7E_80_entry:  /* entry: sResource 80 */
    .byte   0x80, 0x00, 0x18, 0xA8	| 408F2CDA s24 -> DECL_SR7E_80_Video_Sonora
DECL_POOL_7E_81_entry:  /* entry: sResource 81 */
    .byte   0x81, 0x00, 0x18, 0xD0	| 408F2CDE s24 -> DECL_SR7E_81_Video_Sonora
DECL_POOL_7E_82_entry:  /* entry: sResource 82 */
    .byte   0x82, 0x00, 0x18, 0xFC	| 408F2CE2 s24 -> DECL_SR7E_82_Video_Sonora
DECL_POOL_7E_83_entry:  /* entry: sResource 83 */
    .byte   0x83, 0x00, 0x19, 0x2C	| 408F2CE6 s24 -> DECL_SR7E_83_Video_Sonora
DECL_POOL_7E_84_entry:  /* entry: sResource 84 */
    .byte   0x84, 0x00, 0x19, 0x5C	| 408F2CEA s24 -> DECL_SR7E_84_Video_Sonora
DECL_POOL_7E_85_entry:  /* entry: sResource 85 */
    .byte   0x85, 0x00, 0x19, 0x90	| 408F2CEE s24 -> DECL_SR7E_85_Video_Sonora
DECL_POOL_7E_86_entry:  /* entry: sResource 86 */
    .byte   0x86, 0x00, 0x19, 0xC0	| 408F2CF2 s24 -> DECL_SR7E_86_Video_Sonora
DECL_POOL_7E_87_entry:  /* entry: sResource 87 */
    .byte   0x87, 0x00, 0x19, 0xF4	| 408F2CF6 s24 -> DECL_SR7E_87_Video_Sonora
DECL_POOL_7E_88_entry:  /* entry: sResource 88 */
    .byte   0x88, 0x00, 0x1A, 0x1C	| 408F2CFA s24 -> DECL_SR7E_88_Video_Sonora
DECL_POOL_7E_89_entry:  /* entry: sResource 89 */
    .byte   0x89, 0x00, 0x1A, 0x48	| 408F2CFE s24 -> DECL_SR7E_89_Video_Sonora
DECL_POOL_7E_8A_entry:  /* entry: sResource 8A */
    .byte   0x8A, 0x00, 0x1A, 0x78	| 408F2D02 s24 -> DECL_SR7E_8A_Video_Sonora
DECL_POOL_7E_8B_entry:  /* entry: sResource 8B */
    .byte   0x8B, 0x00, 0x1A, 0xA4	| 408F2D06 s24 -> DECL_SR7E_8B_Video_Sonora
DECL_POOL_7E_8C_entry:  /* entry: sResource 8C */
    .byte   0x8C, 0x00, 0x1A, 0xD4	| 408F2D0A s24 -> DECL_SR7E_8C_Video_Sonora
DECL_POOL_7E_8D_entry:  /* entry: sResource 8D */
    .byte   0x8D, 0x00, 0x1B, 0x08	| 408F2D0E s24 -> DECL_SR7E_8D_Video_Sonora
DECL_POOL_7E_8E_entry:  /* entry: sResource 8E */
    .byte   0x8E, 0x00, 0x1B, 0x38	| 408F2D12 s24 -> DECL_SR7E_8E_Video_Sonora
DECL_POOL_7E_8F_entry:  /* entry: sResource 8F */
    .byte   0x8F, 0x00, 0x1A, 0x64	| 408F2D16 s24 -> DECL_SR7E_8A_Video_Sonora
DECL_POOL_7E_90_entry:  /* entry: sResource 90 */
    .byte   0x90, 0x00, 0x1A, 0x90	| 408F2D1A s24 -> DECL_SR7E_8B_Video_Sonora
DECL_POOL_7E_91_entry:  /* entry: sResource 91 */
    .byte   0x91, 0x00, 0x1A, 0xC0	| 408F2D1E s24 -> DECL_SR7E_8C_Video_Sonora
DECL_POOL_7E_92_entry:  /* entry: sResource 92 */
    .byte   0x92, 0x00, 0x1B, 0x60	| 408F2D22 s24 -> DECL_SR7E_92_Video_Sonora
DECL_POOL_7E_93_entry:  /* entry: sResource 93 */
    .byte   0x93, 0x00, 0x1B, 0x88	| 408F2D26 s24 -> DECL_SR7E_93_Video_Sonora
DECL_POOL_7E_FA_entry:  /* entry: sResource FA */
    .byte   0xFA, 0x00, 0x09, 0x42	| 408F2D2A s24 -> DECL_SR7E_FA_CPU_68030_MacIIFamily
DECL_POOL_7E_FD_entry:  /* entry: sResource FD */
    .byte   0xFD, 0x00, 0x1B, 0xB4	| 408F2D2E s24 -> DECL_SR7E_FD_Ethernet_Sonic
    .short  0xFF00, 0x0000	| 408F2D32
DECL_POOL_7F:           /* sResource directory pool 7F: the sResources of one group of machines (ID, offset) */
    .byte   0x01, 0x00, 0x01, 0xD8	| 408F2D36 s24 -> DECL_SR7F_01_MacII
DECL_POOL_7F_02_entry:  /* entry: sResource 02 */
    .byte   0x02, 0x00, 0x01, 0xFA	| 408F2D3A s24 -> DECL_SR7F_02_MacIIx
DECL_POOL_7F_03_entry:  /* entry: sResource 03 */
    .byte   0x03, 0x00, 0x02, 0x18	| 408F2D3E s24 -> DECL_SR7F_03_MacIIcx
DECL_POOL_7F_04_entry:  /* entry: sResource 04 */
    .byte   0x04, 0x00, 0x02, 0x38	| 408F2D42 s24 -> DECL_SR7F_04_MacSE_30
DECL_POOL_7F_06_entry:  /* entry: sResource 06 */
    .byte   0x06, 0x00, 0x02, 0x58	| 408F2D46 s24 -> DECL_SR7F_06_MacIIci_Built_In_Video
DECL_POOL_7F_08_entry:  /* entry: sResource 08 */
    .byte   0x08, 0x00, 0x02, 0x86	| 408F2D4A s24 -> DECL_SR7F_08_MacIIfx
DECL_POOL_7F_0D_entry:  /* entry: sResource 0D */
    .byte   0x0D, 0x00, 0x02, 0xA6	| 408F2D4E s24 -> DECL_SR7F_0D_MacA_Built_In_Video
DECL_POOL_7F_0E_entry:  /* entry: sResource 0E */
    .byte   0x0E, 0x00, 0x02, 0xD2	| 408F2D52 s24 -> DECL_SR7F_0E_MacB_Built_In_Video
DECL_POOL_7F_0F_entry:  /* entry: sResource 0F */
    .byte   0x0F, 0x00, 0x02, 0xFE	| 408F2D56 s24 -> DECL_SR7F_0F_MacC_Built_In_Video
DECL_POOL_7F_10_entry:  /* entry: sResource 10 */
    .byte   0x10, 0x00, 0x03, 0x3A	| 408F2D5A s24 -> DECL_SR7F_10_MacD_Built_In_Video
DECL_POOL_7F_11_entry:  /* entry: sResource 11 */
    .byte   0x11, 0x00, 0x03, 0x6E	| 408F2D5E s24 -> DECL_SR7F_11_MacE_Built_In_Video
DECL_POOL_7F_14_entry:  /* entry: sResource 14 */
    .byte   0x14, 0x00, 0x03, 0x32	| 408F2D62 s24 -> DECL_SR7F_10_MacD_Built_In_Video
DECL_POOL_7F_15_entry:  /* entry: sResource 15 */
    .byte   0x15, 0x00, 0x03, 0xA6	| 408F2D66 s24 -> DECL_SR7F_15_MacG_Built_In_Video
DECL_POOL_7F_18_entry:  /* entry: sResource 18 */
    .byte   0x18, 0x00, 0x03, 0xE2	| 408F2D6A s24 -> DECL_SR7F_18_MacH_Built_In_Video
DECL_POOL_7F_19_entry:  /* entry: sResource 19 */
    .byte   0x19, 0x00, 0x04, 0x16	| 408F2D6E s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_1B_entry:  /* entry: sResource 1B */
    .byte   0x1B, 0x00, 0x03, 0xDA	| 408F2D72 s24 -> DECL_SR7F_18_MacH_Built_In_Video
DECL_POOL_7F_1C_entry:  /* entry: sResource 1C */
    .byte   0x1C, 0x00, 0x04, 0x4E	| 408F2D76 s24 -> DECL_SR7F_1C_MacJ_Built_In_Video
DECL_POOL_7F_1D_entry:  /* entry: sResource 1D */
    .byte   0x1D, 0x00, 0x04, 0x4A	| 408F2D7A s24 -> DECL_SR7F_1C_MacJ_Built_In_Video
DECL_POOL_7F_1E_entry:  /* entry: sResource 1E */
    .byte   0x1E, 0x00, 0x04, 0x06	| 408F2D7E s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_1F_entry:  /* entry: sResource 1F */
    .byte   0x1F, 0x00, 0x04, 0x02	| 408F2D82 s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_21_entry:  /* entry: sResource 21 */
    .byte   0x21, 0x00, 0x03, 0xC6	| 408F2D86 s24 -> DECL_SR7F_18_MacH_Built_In_Video
DECL_POOL_7F_22_entry:  /* entry: sResource 22 */
    .byte   0x22, 0x00, 0x03, 0xC2	| 408F2D8A s24 -> DECL_SR7F_18_MacH_Built_In_Video
DECL_POOL_7F_2E_entry:  /* entry: sResource 2E */
    .byte   0x2E, 0x00, 0x03, 0xF6	| 408F2D8E s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_2F_entry:  /* entry: sResource 2F */
    .byte   0x2F, 0x00, 0x03, 0xF2	| 408F2D92 s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_30_entry:  /* entry: sResource 30 */
    .byte   0x30, 0x00, 0x03, 0xEE	| 408F2D96 s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_34_entry:  /* entry: sResource 34 */
    .byte   0x34, 0x00, 0x03, 0xEA	| 408F2D9A s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_35_entry:  /* entry: sResource 35 */
    .byte   0x35, 0x00, 0x03, 0xE6	| 408F2D9E s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_36_entry:  /* entry: sResource 36 */
    .byte   0x36, 0x00, 0x03, 0xE2	| 408F2DA2 s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_3A_entry:  /* entry: sResource 3A */
    .byte   0x3A, 0x00, 0x03, 0xDE	| 408F2DA6 s24 -> DECL_SR7F_19_MacI_Built_In_Video
DECL_POOL_7F_81_entry:  /* entry: sResource 81 */
    .byte   0x81, 0x00, 0x09, 0xD4	| 408F2DAA s24 -> DECL_SR7F_81_Video_RBV1
DECL_POOL_7F_82_entry:  /* entry: sResource 82 */
    .byte   0x82, 0x00, 0x0A, 0x48	| 408F2DAE s24 -> DECL_SR7F_82_Video_RBV1
DECL_POOL_7F_86_entry:  /* entry: sResource 86 */
    .byte   0x86, 0x00, 0x09, 0x24	| 408F2DB2 s24 -> DECL_SR7F_86_Video_RBV1
DECL_POOL_7F_87_entry:  /* entry: sResource 87 */
    .byte   0x87, 0x00, 0x0A, 0xE8	| 408F2DB6 s24 -> DECL_SR7F_87_Video_RBV1
DECL_POOL_7F_89_entry:  /* entry: sResource 89 */
    .byte   0x89, 0x00, 0x0A, 0x18	| 408F2DBA s24 -> DECL_SR7F_89_Video_RBV1
DECL_POOL_7F_8A_entry:  /* entry: sResource 8A */
    .byte   0x8A, 0x00, 0x0A, 0xBC	| 408F2DBE s24 -> DECL_SR7F_8A_Video_RBV1
DECL_POOL_7F_8E_entry:  /* entry: sResource 8E */
    .byte   0x8E, 0x00, 0x09, 0x98	| 408F2DC2 s24 -> DECL_SR7F_8E_Video_RBV1
DECL_POOL_7F_8F_entry:  /* entry: sResource 8F */
    .byte   0x8F, 0x00, 0x0B, 0x5C	| 408F2DC6 s24 -> DECL_SR7F_8F_Video_RBV1
DECL_POOL_7F_91_entry:  /* entry: sResource 91 */
    .byte   0x91, 0x00, 0x09, 0xE0	| 408F2DCA s24 -> DECL_SR7F_91_Video_RBV1
DECL_POOL_7F_92_entry:  /* entry: sResource 92 */
    .byte   0x92, 0x00, 0x0A, 0x58	| 408F2DCE s24 -> DECL_SR7F_92_Video_RBV1
DECL_POOL_7F_96_entry:  /* entry: sResource 96 */
    .byte   0x96, 0x00, 0x09, 0x34	| 408F2DD2 s24 -> DECL_SR7F_96_Video_RBV1
DECL_POOL_7F_97_entry:  /* entry: sResource 97 */
    .byte   0x97, 0x00, 0x0A, 0xF8	| 408F2DD6 s24 -> DECL_SR7F_97_Video_RBV1
DECL_POOL_7F_9A_entry:  /* entry: sResource 9A */
    .byte   0x9A, 0x00, 0x0A, 0x78	| 408F2DDA s24 -> DECL_SR7F_9A_Video_RBV1
DECL_POOL_7F_9E_entry:  /* entry: sResource 9E */
    .byte   0x9E, 0x00, 0x09, 0x54	| 408F2DDE s24 -> DECL_SR7F_9E_Video_RBV1
DECL_POOL_7F_9F_entry:  /* entry: sResource 9F */
    .byte   0x9F, 0x00, 0x0B, 0x18	| 408F2DE2 s24 -> DECL_SR7F_9F_Video_RBV1
DECL_POOL_7F_A2_entry:  /* entry: sResource A2 */
    .byte   0xA2, 0x00, 0x0B, 0x60	| 408F2DE6 s24 -> DECL_SR7F_A2_Video_V8
DECL_POOL_7F_A3_entry:  /* entry: sResource A3 */
    .byte   0xA3, 0x00, 0x0C, 0x78	| 408F2DEA s24 -> DECL_SR7F_A3_Video_V8
DECL_POOL_7F_A6_entry:  /* entry: sResource A6 */
    .byte   0xA6, 0x00, 0x0C, 0x18	| 408F2DEE s24 -> DECL_SR7F_A6_Video_V8
DECL_POOL_7F_AA_entry:  /* entry: sResource AA */
    .byte   0xAA, 0x00, 0x0B, 0x88	| 408F2DF2 s24 -> DECL_SR7F_AA_Video_V8
DECL_POOL_7F_AB_entry:  /* entry: sResource AB */
    .byte   0xAB, 0x00, 0x0C, 0x98	| 408F2DF6 s24 -> DECL_SR7F_AB_Video_V8
DECL_POOL_7F_AE_entry:  /* entry: sResource AE */
    .byte   0xAE, 0x00, 0x0C, 0x3C	| 408F2DFA s24 -> DECL_SR7F_AE_Video_V8
DECL_POOL_7F_B2_entry:  /* entry: sResource B2 */
    .byte   0xB2, 0x00, 0x0B, 0xAC	| 408F2DFE s24 -> DECL_SR7F_B2_Video_V8
DECL_POOL_7F_BA_entry:  /* entry: sResource BA */
    .byte   0xBA, 0x00, 0x0B, 0xD8	| 408F2E02 s24 -> DECL_SR7F_BA_Video_V8
DECL_POOL_7F_BB_entry:  /* entry: sResource BB */
    .byte   0xBB, 0x00, 0x16, 0xF4	| 408F2E06 s24 -> DECL_SR7F_BB_Video_DBLite
DECL_POOL_7F_BC_entry:  /* entry: sResource BC */
    .byte   0xBC, 0x00, 0x17, 0x20	| 408F2E0A s24 -> DECL_SR7F_BC_Video_DBLite
DECL_POOL_7F_BD_entry:  /* entry: sResource BD */
    .byte   0xBD, 0x00, 0x17, 0x4C	| 408F2E0E s24 -> DECL_SR7F_BD_Video_DBLite
DECL_POOL_7F_BE_entry:  /* entry: sResource BE */
    .byte   0xBE, 0x00, 0x0C, 0xA4	| 408F2E12 s24 -> DECL_SR7F_BE_Video_DAFB
DECL_POOL_7F_BF_entry:  /* entry: sResource BF */
    .byte   0xBF, 0x00, 0x0C, 0xD0	| 408F2E16 s24 -> DECL_SR7F_BF_Video_DAFB
DECL_POOL_7F_C0_entry:  /* entry: sResource C0 */
    .byte   0xC0, 0x00, 0x0D, 0x38	| 408F2E1A s24 -> DECL_SR7F_C0_Video_DAFB
DECL_POOL_7F_C1_entry:  /* entry: sResource C1 */
    .byte   0xC1, 0x00, 0x0D, 0x64	| 408F2E1E s24 -> DECL_SR7F_C1_Video_DAFB
DECL_POOL_7F_C2_entry:  /* entry: sResource C2 */
    .byte   0xC2, 0x00, 0x0E, 0xD8	| 408F2E22 s24 -> DECL_SR7F_C2_Video_DAFB
DECL_POOL_7F_C3_entry:  /* entry: sResource C3 */
    .byte   0xC3, 0x00, 0x0F, 0x08	| 408F2E26 s24 -> DECL_SR7F_C3_Video_DAFB
DECL_POOL_7F_C4_entry:  /* entry: sResource C4 */
    .byte   0xC4, 0x00, 0x0D, 0x8C	| 408F2E2A s24 -> DECL_SR7F_C4_Video_DAFB
DECL_POOL_7F_C5_entry:  /* entry: sResource C5 */
    .byte   0xC5, 0x00, 0x0D, 0xB8	| 408F2E2E s24 -> DECL_SR7F_C5_Video_DAFB
DECL_POOL_7F_C6_entry:  /* entry: sResource C6 */
    .byte   0xC6, 0x00, 0x0D, 0xE8	| 408F2E32 s24 -> DECL_SR7F_C6_Video_DAFB
DECL_POOL_7F_C7_entry:  /* entry: sResource C7 */
    .byte   0xC7, 0x00, 0x0E, 0x18	| 408F2E36 s24 -> DECL_SR7F_C7_Video_DAFB
DECL_POOL_7F_C8_entry:  /* entry: sResource C8 */
    .byte   0xC8, 0x00, 0x0F, 0xA0	| 408F2E3A s24 -> DECL_SR7F_C8_Video_DAFB
DECL_POOL_7F_C9_entry:  /* entry: sResource C9 */
    .byte   0xC9, 0x00, 0x0F, 0xD0	| 408F2E3E s24 -> DECL_SR7F_C9_Video_DAFB
DECL_POOL_7F_CA_entry:  /* entry: sResource CA */
    .byte   0xCA, 0x00, 0x0F, 0x98	| 408F2E42 s24 -> DECL_SR7F_C8_Video_DAFB
DECL_POOL_7F_CB_entry:  /* entry: sResource CB */
    .byte   0xCB, 0x00, 0x0F, 0xC8	| 408F2E46 s24 -> DECL_SR7F_C9_Video_DAFB
DECL_POOL_7F_CC_entry:  /* entry: sResource CC */
    .byte   0xCC, 0x00, 0x11, 0x50	| 408F2E4A s24 -> DECL_SR7F_CC_Video_DAFB
DECL_POOL_7F_CD_entry:  /* entry: sResource CD */
    .byte   0xCD, 0x00, 0x11, 0x7C	| 408F2E4E s24 -> DECL_SR7F_CD_Video_DAFB
DECL_POOL_7F_CE_entry:  /* entry: sResource CE */
    .byte   0xCE, 0x00, 0x11, 0xE4	| 408F2E52 s24 -> DECL_SR7F_CE_Video_DAFB
DECL_POOL_7F_CF_entry:  /* entry: sResource CF */
    .byte   0xCF, 0x00, 0x12, 0x10	| 408F2E56 s24 -> DECL_SR7F_CF_Video_DAFB
DECL_POOL_7F_D0_entry:  /* entry: sResource D0 */
    .byte   0xD0, 0x00, 0x12, 0x78	| 408F2E5A s24 -> DECL_SR7F_D0_Video_DAFB
DECL_POOL_7F_D1_entry:  /* entry: sResource D1 */
    .byte   0xD1, 0x00, 0x12, 0xA4	| 408F2E5E s24 -> DECL_SR7F_D1_Video_DAFB
DECL_POOL_7F_D2_entry:  /* entry: sResource D2 */
    .byte   0xD2, 0x00, 0x13, 0x70	| 408F2E62 s24 -> DECL_SR7F_D2_Video_DAFB
DECL_POOL_7F_D3_entry:  /* entry: sResource D3 */
    .byte   0xD3, 0x00, 0x13, 0x9C	| 408F2E66 s24 -> DECL_SR7F_D3_Video_DAFB
DECL_POOL_7F_D4_entry:  /* entry: sResource D4 */
    .byte   0xD4, 0x00, 0x14, 0x68	| 408F2E6A s24 -> DECL_SR7F_D4_Video_DAFB
DECL_POOL_7F_D5_entry:  /* entry: sResource D5 */
    .byte   0xD5, 0x00, 0x14, 0x94	| 408F2E6E s24 -> DECL_SR7F_D5_Video_DAFB
DECL_POOL_7F_D6_entry:  /* entry: sResource D6 */
    .byte   0xD6, 0x00, 0x15, 0x60	| 408F2E72 s24 -> DECL_SR7F_D6_Video_DAFB
DECL_POOL_7F_D7_entry:  /* entry: sResource D7 */
    .byte   0xD7, 0x00, 0x15, 0x8C	| 408F2E76 s24 -> DECL_SR7F_D7_Video_DAFB
DECL_POOL_7F_D8_entry:  /* entry: sResource D8 */
    .byte   0xD8, 0x00, 0x13, 0x28	| 408F2E7A s24 -> DECL_SR7F_D8_Video_DAFB
DECL_POOL_7F_D9_entry:  /* entry: sResource D9 */
    .byte   0xD9, 0x00, 0x13, 0x24	| 408F2E7E s24 -> DECL_SR7F_D8_Video_DAFB
DECL_POOL_7F_DA_entry:  /* entry: sResource DA */
    .byte   0xDA, 0x00, 0x14, 0x20	| 408F2E82 s24 -> DECL_SR7F_DA_Video_DAFB
DECL_POOL_7F_DB_entry:  /* entry: sResource DB */
    .byte   0xDB, 0x00, 0x14, 0x1C	| 408F2E86 s24 -> DECL_SR7F_DA_Video_DAFB
DECL_POOL_7F_DC_entry:  /* entry: sResource DC */
    .byte   0xDC, 0x00, 0x15, 0x18	| 408F2E8A s24 -> DECL_SR7F_DC_Video_DAFB
DECL_POOL_7F_DD_entry:  /* entry: sResource DD */
    .byte   0xDD, 0x00, 0x15, 0x14	| 408F2E8E s24 -> DECL_SR7F_DC_Video_DAFB
DECL_POOL_7F_DE_entry:  /* entry: sResource DE */
    .byte   0xDE, 0x00, 0x16, 0x10	| 408F2E92 s24 -> DECL_SR7F_DE_Video_DAFB
DECL_POOL_7F_DF_entry:  /* entry: sResource DF */
    .byte   0xDF, 0x00, 0x16, 0x0C	| 408F2E96 s24 -> DECL_SR7F_DE_Video_DAFB
DECL_POOL_7F_E0_entry:  /* entry: sResource E0 */
    .byte   0xE0, 0x00, 0x16, 0x38	| 408F2E9A s24 -> DECL_SR7F_E0_Video_TIM
DECL_POOL_7F_E2_entry:  /* entry: sResource E2 */
    .byte   0xE2, 0x00, 0x0F, 0xA8	| 408F2E9E s24 -> DECL_SR7F_E2_Video_DAFB
DECL_POOL_7F_E3_entry:  /* entry: sResource E3 */
    .byte   0xE3, 0x00, 0x0F, 0xDC	| 408F2EA2 s24 -> DECL_SR7F_E3_Video_DAFB
DECL_POOL_7F_E4_entry:  /* entry: sResource E4 */
    .byte   0xE4, 0x00, 0x0F, 0xA0	| 408F2EA6 s24 -> DECL_SR7F_E2_Video_DAFB
DECL_POOL_7F_E5_entry:  /* entry: sResource E5 */
    .byte   0xE5, 0x00, 0x0F, 0xD4	| 408F2EAA s24 -> DECL_SR7F_E3_Video_DAFB
DECL_POOL_7F_E6_entry:  /* entry: sResource E6 */
    .byte   0xE6, 0x00, 0x0D, 0xD8	| 408F2EAE s24 -> DECL_SR7F_E6_Video_DAFB
DECL_POOL_7F_E7_entry:  /* entry: sResource E7 */
    .byte   0xE7, 0x00, 0x0E, 0x0C	| 408F2EB2 s24 -> DECL_SR7F_E7_Video_DAFB
DECL_POOL_7F_E8_entry:  /* entry: sResource E8 */
    .byte   0xE8, 0x00, 0x10, 0x70	| 408F2EB6 s24 -> DECL_SR7F_E8_Video_DAFB
DECL_POOL_7F_E9_entry:  /* entry: sResource E9 */
    .byte   0xE9, 0x00, 0x10, 0xA4	| 408F2EBA s24 -> DECL_SR7F_E9_Video_DAFB
DECL_POOL_7F_EA_entry:  /* entry: sResource EA */
    .byte   0xEA, 0x00, 0x0F, 0xFC	| 408F2EBE s24 -> DECL_SR7F_EA_Video_DAFB
DECL_POOL_7F_EB_entry:  /* entry: sResource EB */
    .byte   0xEB, 0x00, 0x10, 0x2C	| 408F2EC2 s24 -> DECL_SR7F_EB_Video_DAFB
DECL_POOL_7F_EC_entry:  /* entry: sResource EC */
    .byte   0xEC, 0x00, 0x0E, 0xA0	| 408F2EC6 s24 -> DECL_SR7F_EC_Video_DAFB
DECL_POOL_7F_ED_entry:  /* entry: sResource ED */
    .byte   0xED, 0x00, 0x11, 0x34	| 408F2ECA s24 -> DECL_SR7F_ED_Video_DAFB
DECL_POOL_7F_EE_entry:  /* entry: sResource EE */
    .byte   0xEE, 0x00, 0x0E, 0xD4	| 408F2ECE s24 -> DECL_SR7F_EE_Video_DAFB
DECL_POOL_7F_EF_entry:  /* entry: sResource EF */
    .byte   0xEF, 0x00, 0x11, 0xC8	| 408F2ED2 s24 -> DECL_SR7F_EF_Video_DAFB
DECL_POOL_7F_F0_entry:  /* entry: sResource F0 */
    .byte   0xF0, 0x00, 0x12, 0x60	| 408F2ED6 s24 -> DECL_SR7F_F0_Video_DAFB
DECL_POOL_7F_F1_entry:  /* entry: sResource F1 */
    .byte   0xF1, 0x00, 0x12, 0x90	| 408F2EDA s24 -> DECL_SR7F_F1_Video_DAFB
DECL_POOL_7F_F2_entry:  /* entry: sResource F2 */
    .byte   0xF2, 0x00, 0x13, 0x58	| 408F2EDE s24 -> DECL_SR7F_F2_Video_DAFB
DECL_POOL_7F_F3_entry:  /* entry: sResource F3 */
    .byte   0xF3, 0x00, 0x13, 0x88	| 408F2EE2 s24 -> DECL_SR7F_F3_Video_DAFB
DECL_POOL_7F_F4_entry:  /* entry: sResource F4 */
    .byte   0xF4, 0x00, 0x14, 0x50	| 408F2EE6 s24 -> DECL_SR7F_F4_Video_DAFB
DECL_POOL_7F_F5_entry:  /* entry: sResource F5 */
    .byte   0xF5, 0x00, 0x14, 0x80	| 408F2EEA s24 -> DECL_SR7F_F5_Video_DAFB
DECL_POOL_7F_F6_entry:  /* entry: sResource F6 */
    .byte   0xF6, 0x00, 0x15, 0x48	| 408F2EEE s24 -> DECL_SR7F_F6_Video_DAFB
DECL_POOL_7F_F7_entry:  /* entry: sResource F7 */
    .byte   0xF7, 0x00, 0x15, 0x78	| 408F2EF2 s24 -> DECL_SR7F_F7_Video_DAFB
DECL_POOL_7F_F9_entry:  /* entry: sResource F9 */
    .byte   0xF9, 0x00, 0x0C, 0x24	| 408F2EF6 s24 -> DECL_SR7F_F9_Video_DAFB
DECL_POOL_7F_FA_entry:  /* entry: sResource FA */
    .byte   0xFA, 0x00, 0x07, 0x72	| 408F2EFA s24 -> DECL_SR7E_FA_CPU_68030_MacIIFamily
DECL_POOL_7F_FB_entry:  /* entry: sResource FB */
    .byte   0xFB, 0x00, 0x07, 0x82	| 408F2EFE s24 -> DECL_SR7F_FB_CPU_68040
DECL_POOL_7F_FD_entry:  /* entry: sResource FD */
    .byte   0xFD, 0x00, 0x19, 0xE0	| 408F2F02 s24 -> DECL_SR7E_FD_Ethernet_Sonic
DECL_POOL_7F_FE_entry:  /* entry: sResource FE */
    .byte   0xFE, 0x00, 0x19, 0xF4	| 408F2F06 s24 -> DECL_SR7F_FE_CPU_AppleII_AppleIIe_FeatureCard
    .short  0xFF00, 0x0000	| 408F2F0A
DECL_SR7F_01_MacII:     /* sResource 01 in pool 7F: MacII (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0xF4	| 408F2F0E s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_01_MacII_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x14	| 408F2F12 s24 -> DECL_NAME_Macintosh_II
    .short  0x2000, 0x0010	| 408F2F16
DECL_SR7F_01_MacII_PrimaryInit_entry:  /* entry PrimaryInit (34): code run by the Slot Manager at start-up */
    .byte   0x22, 0x00, 0x57, 0x60	| 408F2F1A s24 -> DECL_SR7F_01_MacII_PrimaryInit
DECL_SR7F_01_MacII_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x06, 0xEC	| 408F2F1E s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
    .short  0xFF00, 0x0000	| 408F2F22
DECL_NAME_Macintosh_II:  /* name string (C string) */
    .ascii  "Macintosh II\000\000"
DECL_SR7F_02_MacIIx:    /* sResource 02 in pool 7F: MacIIx (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0xCE	| 408F2F34 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_02_MacIIx_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F2F38 s24 -> DECL_NAME_Macintosh_IIx
    .long   0x20000021	| 408F2F3C
DECL_SR7F_02_MacIIx_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x06, 0xCA	| 408F2F40 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
    .long   0xFF000000	| 408F2F44
DECL_NAME_Macintosh_IIx:  /* name string (C string) */
    .ascii  "Macintosh IIx\000"
DECL_SR7F_03_MacIIcx:   /* sResource 03 in pool 7F: MacIIcx (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0xAC	| 408F2F56 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_03_MacIIcx_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F2F5A s24 -> DECL_NAME_Macintosh_IIcx
    .short  0x2000, 0x0023	| 408F2F5E
DECL_SR7F_03_MacIIcx_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x06, 0xA8	| 408F2F62 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
    .short  0xFF00, 0x0000	| 408F2F66
DECL_NAME_Macintosh_IIcx:  /* name string (C string) */
    .ascii  "Macintosh IIcx\000"
    .byte   0x00	| 408F2F79
DECL_SR7F_04_MacSE_30:  /* sResource 04 in pool 7F: MacSE 30 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0x88	| 408F2F7A s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_04_MacSE_30_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F2F7E s24 -> DECL_NAME_Macintosh_SE_30
    .short  0x2000, 0x0022	| 408F2F82
DECL_SR7F_04_MacSE_30_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x06, 0x84	| 408F2F86 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
    .short  0xFF00, 0x0000	| 408F2F8A
DECL_NAME_Macintosh_SE_30:  /* name string (C string) */
    .ascii  "Macintosh SE/30\000"
DECL_SR7F_06_MacIIci_Built_In_Video:  /* sResource 06 in pool 7F: MacIIci Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0x64	| 408F2F9E s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_06_MacIIci_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F2FA2 s24 -> DECL_NAME_Macintosh_IIci_Built_In_Video
    .short  0x2000, 0x001F	| 408F2FA6
DECL_SR7F_06_MacIIci_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x06, 0x60	| 408F2FAA s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
    .short  0xFF00, 0x0000	| 408F2FAE
DECL_NAME_Macintosh_IIci_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh IIci Built-In Video\000"
DECL_SR7F_08_MacIIfx:   /* sResource 08 in pool 7F: MacIIfx (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0x32	| 408F2FD0 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_08_MacIIfx_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F2FD4 s24 -> DECL_NAME_Macintosh_IIfx
    .long   0x20000024	| 408F2FD8
DECL_SR7F_08_MacIIfx_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x06, 0x2E	| 408F2FDC s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
    .long   0xFF000000	| 408F2FE0
DECL_NAME_Macintosh_IIfx:  /* name string (C string) */
    .ascii  "Macintosh IIfx\000\000"
DECL_SR7F_0D_MacA_Built_In_Video:  /* sResource 0D in pool 7F: MacA Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0x0E	| 408F2FF4 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_0D_MacA_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F2FF8 s24 -> DECL_NAME_Macintosh_A_Built_In_Video
    .long   0x20000028	| 408F2FFC
DECL_SR7F_0D_MacA_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x06, 0x0A	| 408F3000 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
    .long   0xFF000000	| 408F3004
DECL_NAME_Macintosh_A_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh A Built-In Video\000\000"
DECL_SR7F_0E_MacB_Built_In_Video:  /* sResource 0E in pool 7F: MacB Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x05, 0xDE	| 408F3024 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_0E_MacB_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F3028 s24 -> DECL_NAME_Macintosh_B_Built_In_Video
    .long   0x20000029	| 408F302C
DECL_SR7F_0E_MacB_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x05, 0xDA	| 408F3030 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
    .long   0xFF000000	| 408F3034
DECL_NAME_Macintosh_B_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh B Built-In Video\000\000"
DECL_SR7F_0F_MacC_Built_In_Video:  /* sResource 0F in pool 7F: MacC Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x05, 0xAE	| 408F3054 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_0F_MacC_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x20	| 408F3058 s24 -> DECL_NAME_Macintosh_C_Built_In_Video
DECL_SR7F_0F_MacC_Built_In_Video_sRsrcIcon_entry:  /* entry sRsrcIcon (3): its icon */
    .byte   0x03, 0x00, 0x19, 0xD0	| 408F305C s24 -> DECL_SR7E_15_MacAA_Built_In_Video_sRsrcIcon_data
    .long   0x2000002B	| 408F3060
DECL_SR7F_0F_MacC_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x05, 0xA6	| 408F3064 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
DECL_SR7F_0F_MacC_Built_In_Video_SecondaryInit_entry:  /* entry SecondaryInit (38): code run after the system is loaded */
    .byte   0x26, 0x00, 0x74, 0x9C	| 408F3068 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit
DECL_SR7F_0F_MacC_Built_In_Video_sRsrcVidNames_entry:  /* entry sRsrcVidNames (65): names of its video modes */
    .byte   0x41, 0x00, 0x02, 0x0E	| 408F306C s24 -> DECL_SR7F_0F_MacC_Built_In_Video_VidNames
DECL_SR7F_0F_MacC_Built_In_Video_id7E_entry:  /* entry, ID 7E */
    .byte   0x7E, 0x00, 0x22, 0xDE	| 408F3070 s24 -> DECL_SR7F_0F_MacC_Built_In_Video_id7E_data
    .long   0xFF000000	| 408F3074
DECL_NAME_Macintosh_C_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh C Built-In Video\000\000"
DECL_SR7F_10_MacD_Built_In_Video:  /* sResource 10 in pool 7F: MacD Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x05, 0x6E	| 408F3094 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_10_MacD_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x18	| 408F3098 s24 -> DECL_NAME_Macintosh_D_Built_In_Video
DECL_SR7F_10_MacD_Built_In_Video_sRsrcIcon_entry:  /* entry sRsrcIcon (3): its icon */
    .byte   0x03, 0x00, 0x1A, 0x10	| 408F309C s24 -> DECL_SR7F_10_MacD_Built_In_Video_sRsrcIcon_data
    .long   0x2000002A	| 408F30A0
DECL_SR7F_10_MacD_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x05, 0x66	| 408F30A4 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
DECL_SR7F_10_MacD_Built_In_Video_sRsrcVidNames_entry:  /* entry sRsrcVidNames (65): names of its video modes */
    .byte   0x41, 0x00, 0x05, 0x26	| 408F30A8 s24 -> DECL_SR7F_10_MacD_Built_In_Video_VidNames
    .long   0xFF000000	| 408F30AC
DECL_NAME_Macintosh_D_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh D Built-In Video\000\000"
DECL_SR7F_11_MacE_Built_In_Video:  /* sResource 11 in pool 7F: MacE Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x05, 0x36	| 408F30CC s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_11_MacE_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x20	| 408F30D0 s24 -> DECL_NAME_Macintosh_E_Built_In_Video
DECL_SR7F_11_MacE_Built_In_Video_sRsrcIcon_entry:  /* entry sRsrcIcon (3): its icon */
    .byte   0x03, 0x00, 0x19, 0x58	| 408F30D4 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_sRsrcIcon_data
    .long   0x20000033	| 408F30D8
DECL_SR7F_11_MacE_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x05, 0x2E	| 408F30DC s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
DECL_SR7F_11_MacE_Built_In_Video_SecondaryInit_entry:  /* entry SecondaryInit (38): code run after the system is loaded */
    .byte   0x26, 0x00, 0x74, 0x24	| 408F30E0 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit
DECL_SR7F_11_MacE_Built_In_Video_sRsrcVidNames_entry:  /* entry sRsrcVidNames (65): names of its video modes */
    .byte   0x41, 0x00, 0x01, 0x96	| 408F30E4 s24 -> DECL_SR7F_0F_MacC_Built_In_Video_VidNames
DECL_SR7F_11_MacE_Built_In_Video_id7E_entry:  /* entry, ID 7E */
    .byte   0x7E, 0x00, 0x22, 0x66	| 408F30E8 s24 -> DECL_SR7F_0F_MacC_Built_In_Video_id7E_data
    .long   0xFF000000	| 408F30EC
DECL_NAME_Macintosh_E_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh E Built-In Video\000\000"
DECL_SR7F_15_MacG_Built_In_Video:  /* sResource 15 in pool 7F: MacG Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0xF6	| 408F310C s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_15_MacG_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x20	| 408F3110 s24 -> DECL_NAME_Macintosh_G_Built_In_Video
DECL_SR7F_15_MacG_Built_In_Video_sRsrcIcon_entry:  /* entry sRsrcIcon (3): its icon */
    .byte   0x03, 0x00, 0x19, 0x18	| 408F3114 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_sRsrcIcon_data
    .long   0x20000036	| 408F3118
DECL_SR7F_15_MacG_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x04, 0xEE	| 408F311C s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
DECL_SR7F_15_MacG_Built_In_Video_SecondaryInit_entry:  /* entry SecondaryInit (38): code run after the system is loaded */
    .byte   0x26, 0x00, 0x73, 0xE4	| 408F3120 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit
DECL_SR7F_15_MacG_Built_In_Video_sRsrcVidNames_entry:  /* entry sRsrcVidNames (65): names of its video modes */
    .byte   0x41, 0x00, 0x01, 0x56	| 408F3124 s24 -> DECL_SR7F_0F_MacC_Built_In_Video_VidNames
DECL_SR7F_15_MacG_Built_In_Video_id7E_entry:  /* entry, ID 7E */
    .byte   0x7E, 0x00, 0x22, 0x26	| 408F3128 s24 -> DECL_SR7F_0F_MacC_Built_In_Video_id7E_data
    .long   0xFF000000	| 408F312C
DECL_NAME_Macintosh_G_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh G Built-In Video\000\000"
DECL_SR7F_18_MacH_Built_In_Video:  /* sResource 18 in pool 7F: MacH Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0xB6	| 408F314C s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_18_MacH_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x18	| 408F3150 s24 -> DECL_NAME_Macintosh_H_Built_In_Video
    .long   0x20000035	| 408F3154
DECL_SR7F_18_MacH_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x04, 0xB2	| 408F3158 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
DECL_SR7F_18_MacH_Built_In_Video_SecondaryInit_entry:  /* entry SecondaryInit (38): code run after the system is loaded */
    .byte   0x26, 0x00, 0x73, 0xA8	| 408F315C s24 -> DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit
DECL_SR7F_18_MacH_Built_In_Video_sRsrcVidNames_entry:  /* entry sRsrcVidNames (65): names of its video modes */
    .byte   0x41, 0x00, 0x04, 0x76	| 408F3160 s24 -> DECL_SR7F_18_MacH_Built_In_Video_VidNames
    .long   0xFF000000	| 408F3164
DECL_NAME_Macintosh_H_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh H Built-In Video\000\000"
DECL_SR7F_19_MacI_Built_In_Video:  /* sResource 19 in pool 7F: MacI Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0x7E	| 408F3184 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_19_MacI_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x20	| 408F3188 s24 -> DECL_NAME_Macintosh_I_Built_In_Video
DECL_SR7F_19_MacI_Built_In_Video_sRsrcIcon_entry:  /* entry sRsrcIcon (3): its icon */
    .byte   0x03, 0x00, 0x18, 0xA0	| 408F318C s24 -> DECL_SR7E_15_MacAA_Built_In_Video_sRsrcIcon_data
    .long   0x2000003B	| 408F3190
DECL_SR7F_19_MacI_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x04, 0x76	| 408F3194 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
DECL_SR7F_19_MacI_Built_In_Video_SecondaryInit_entry:  /* entry SecondaryInit (38): code run after the system is loaded */
    .byte   0x26, 0x00, 0x73, 0x6C	| 408F3198 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit
DECL_SR7F_19_MacI_Built_In_Video_sRsrcVidNames_entry:  /* entry sRsrcVidNames (65): names of its video modes */
    .byte   0x41, 0x00, 0x00, 0xDE	| 408F319C s24 -> DECL_SR7F_0F_MacC_Built_In_Video_VidNames
DECL_SR7F_19_MacI_Built_In_Video_id7E_entry:  /* entry, ID 7E */
    .byte   0x7E, 0x00, 0x21, 0xAE	| 408F31A0 s24 -> DECL_SR7F_0F_MacC_Built_In_Video_id7E_data
    .long   0xFF000000	| 408F31A4
DECL_NAME_Macintosh_I_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh I Built-In Video\000\000"
DECL_SR7F_1C_MacJ_Built_In_Video:  /* sResource 1C in pool 7F: MacJ Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0x3E	| 408F31C4 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7F_1C_MacJ_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x18	| 408F31C8 s24 -> DECL_NAME_Macintosh_J_Built_In_Video
    .long   0x20000040	| 408F31CC
DECL_SR7F_1C_MacJ_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x04, 0x3A	| 408F31D0 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
DECL_SR7F_1C_MacJ_Built_In_Video_SecondaryInit_entry:  /* entry SecondaryInit (38): code run after the system is loaded */
    .byte   0x26, 0x00, 0x73, 0x30	| 408F31D4 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit
DECL_SR7F_1C_MacJ_Built_In_Video_sRsrcVidNames_entry:  /* entry sRsrcVidNames (65): names of its video modes */
    .byte   0x41, 0x00, 0x03, 0xFE	| 408F31D8 s24 -> DECL_SR7F_18_MacH_Built_In_Video_VidNames
    .long   0xFF000000	| 408F31DC
DECL_NAME_Macintosh_J_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh J Built-In Video\000\000"
DECL_SR7E_15_MacAA_Built_In_Video:  /* sResource 15 in pool 7E: MacAA Built In Video (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0x06	| 408F31FC s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7E_15_MacAA_Built_In_Video_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x24	| 408F3200 s24 -> DECL_NAME_Macintosh_AA_Built_In_Video
DECL_SR7E_15_MacAA_Built_In_Video_sRsrcIcon_entry:  /* entry sRsrcIcon (3): its icon */
    .byte   0x03, 0x00, 0x18, 0x28	| 408F3204 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_sRsrcIcon_data
    .long   0x2000003A	| 408F3208
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_entry:  /* entry PrimaryInit (34): code run by the Slot Manager at start-up */
    .byte   0x22, 0x00, 0x6C, 0x40	| 408F320C s24 -> DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit
DECL_SR7E_15_MacAA_Built_In_Video_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x03, 0xFA	| 408F3210 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_entry:  /* entry SecondaryInit (38): code run after the system is loaded */
    .byte   0x26, 0x00, 0x72, 0xF0	| 408F3214 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit
DECL_SR7E_15_MacAA_Built_In_Video_sRsrcVidNames_entry:  /* entry sRsrcVidNames (65): names of its video modes */
    .byte   0x41, 0x00, 0x01, 0x4A	| 408F3218 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_VidNames
DECL_SR7E_15_MacAA_Built_In_Video_id7E_entry:  /* entry, ID 7E */
    .byte   0x7E, 0x00, 0x22, 0x22	| 408F321C s24 -> DECL_SR7E_15_MacAA_Built_In_Video_id7E_data
    .long   0xFF000000	| 408F3220
DECL_NAME_Macintosh_AA_Built_In_Video:  /* name string (C string) */
    .ascii  "Macintosh AA Built-In Video\000"
DECL_SR7E_16_Death_of_a_Macintosh:  /* sResource 16 in pool 7E: Death of a Macintosh (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x03, 0xC2	| 408F3240 s24 -> DECL_TYPE_0001_0000_0000_0000
DECL_SR7E_16_Death_of_a_Macintosh_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x20	| 408F3244 s24 -> DECL_NAME_Death_of_a_Macintosh
DECL_SR7E_16_Death_of_a_Macintosh_sRsrcIcon_entry:  /* entry sRsrcIcon (3): its icon */
    .byte   0x03, 0x00, 0x17, 0xE4	| 408F3248 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_sRsrcIcon_data
    .long   0x2000003A	| 408F324C
DECL_SR7E_16_Death_of_a_Macintosh_VendorInfo_entry:  /* entry VendorInfo (36): vendor, revision, part number */
    .byte   0x24, 0x00, 0x03, 0xBA	| 408F3250 s24 -> DECL_SR_01_Unknown_Macintosh_VendorInfo
DECL_SR7E_16_Death_of_a_Macintosh_SecondaryInit_entry:  /* entry SecondaryInit (38): code run after the system is loaded */
    .byte   0x26, 0x00, 0x72, 0xB0	| 408F3254 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit
DECL_SR7E_16_Death_of_a_Macintosh_sRsrcVidNames_entry:  /* entry sRsrcVidNames (65): names of its video modes */
    .byte   0x41, 0x00, 0x01, 0x0A	| 408F3258 s24 -> DECL_SR7E_15_MacAA_Built_In_Video_VidNames
DECL_SR7E_16_Death_of_a_Macintosh_id7E_entry:  /* entry, ID 7E */
    .byte   0x7E, 0x00, 0x21, 0xE2	| 408F325C s24 -> DECL_SR7E_15_MacAA_Built_In_Video_id7E_data
    .long   0xFF000000	| 408F3260
DECL_NAME_Death_of_a_Macintosh:  /* name string (C string) */
    .ascii  "Death of a Macintosh!\000"
DECL_SR7F_0F_MacC_Built_In_Video_VidNames:  /* sResource 0F in pool 7F: MacC Built In Video VidNames (its entry list; the first entry, sRsrcType, is here) */
    .short  0xBE00, 0x0316, 0xBF00	| 408F327A
    .long   0x0312C000, 0x0134C100, 0x0130C200, 0x014EC300	| 408F3280
    .long   0x014AC400, 0x0162C500, 0x015EC600, 0x017CC700	| 408F3290
    .long   0x0178C800, 0x0196C900, 0x0192CA00, 0x01AECB00	| 408F32A0
    .long   0x01AACC00, 0x01E0CD00, 0x01DCCE00, 0x01F4CF00	| 408F32B0
    .long   0x01F0D000, 0x020ED100, 0x020AD200, 0x021AD300	| 408F32C0
    .long   0x0216D400, 0x0226D500, 0x0222D600, 0x0230D700	| 408F32D0
    .long   0x022CD800, 0x023AD900, 0x0236DA00, 0x0250DB00	| 408F32E0
    .long   0x024CDC00, 0x0266DD00, 0x0262DE00, 0x027ADF00	| 408F32F0
    .long   0x0276E200, 0x0136E300, 0x0132E400, 0x014EE500	| 408F3300
    .long   0x014AE600, 0x0104E700, 0x0100E800, 0x0158E900	| 408F3310
    .long   0x0154EA00, 0x0150EB00, 0x014CEC00, 0x00AEED00	| 408F3320
    .long   0x0164EE00, 0x00A6EF00, 0x0178F000, 0x0196F100	| 408F3330
    .long   0x0192F200, 0x01A2F300, 0x019EF400, 0x01AEF500	| 408F3340
    .long   0x01AAF600, 0x01B8F700, 0x01B4F900, 0x0236FF00	| 408F3350
    .short  0x0000	| 408F3360
DECL_SR7E_15_MacAA_Built_In_Video_VidNames:  /* sResource 15 in pool 7E: MacAA Built In Video VidNames (its entry list; the first entry, sRsrcType, is here) */
    .short  0x8000, 0x0054, 0x8100, 0x0050, 0x8200, 0x004C, 0x8300	| 408F3362
    .long   0x006A8400, 0x00668500, 0x02308600, 0x022C8700	| 408F3370
    .long   0x01148800, 0x01108900, 0x010C8A00, 0x00AE8B00	| 408F3380
    .long   0x00AA8C00, 0x00A68D00, 0x02228E00, 0x021E8F00	| 408F3390
    .long   0x00BA9000, 0x00B69100, 0x00B29200, 0x006C9300	| 408F33A0
    .long   0x0068FF00, 0x00000000, 0x00220080	| 408F33B0
    .ascii  "Macintosh Portrait Display\000\000"
    .short  0x0000, 0x001C, 0x0081	| 408F33D8
    .ascii  "Macintosh RGB Display\000"
    .short  0x0000, 0x0022, 0x0082	| 408F33F4
    .ascii  "Macintosh Two-Page Display\000\000\000\000"
    .long   0x00220083	| 408F3418
    .ascii  "Macintosh 16\" Color Display\000"
    .short  0x0000, 0x0020, 0x0085	| 408F3438
    .ascii  "Macintosh Hi-Res Display\000\000"
    .long   0x0000001A, 0x00863634	| 408F3458
    .long   0x30783438, 0x30205647, 0x41202836, 0x3020487A	| 408F3460
    .long   0x29000000, 0x00200087	| 408F3470
    .ascii  "800x600 SuperVGA (56 Hz)\000\000\000\000"
    .long   0x001C0088	| 408F3494
    .ascii  "RGB Portrait Display\000\000\000\000"
    .long   0x00220089	| 408F34B0
    .ascii  "Macintosh 21\" Color Display\000"
    .long   0x00000014, 0x008A3531, 0x32783338, 0x34204E54	| 408F34D0
    .long   0x53430000, 0x00000014, 0x008B3634, 0x30783438	| 408F34E0
    .long   0x30204E54, 0x53430000, 0x00000012, 0x008C3634	| 408F34F0
    .long   0x30783438, 0x30205041, 0x4C000000, 0x0012008D	| 408F3500
    .long   0x37363878, 0x35373620, 0x50414C00, 0x0000001E	| 408F3510
    .short  0x008E	| 408F3520
    .ascii  "512x384 NTSC Convolved\000\000\000\000"
    .long   0x001E008F	| 408F353C
    .ascii  "640x480 NTSC Convolved\000\000"
    .short  0x0000, 0x001C, 0x0090	| 408F3558
    .ascii  "640x480 PAL Convolved\000"
    .short  0x0000, 0x001C, 0x0091	| 408F3574
    .ascii  "768x576 PAL Convolved\000"
    .short  0x0000, 0x0016, 0x0092	| 408F3590
    .ascii  "19\" RGB Display\000\000\000"
    .long   0x00120093, 0x35363078	| 408F35A8
    .short  0x3338, 0x3420, 0x5247, 0x4200, 0x0000, 0x0016, 0x0097	| 408F35B0
    .ascii  "640x400 Hi-Res\000"
    .byte   0x00	| 408F35CD
DECL_SR7F_10_MacD_Built_In_Video_VidNames:  /* sResource 10 in pool 7F: MacD Built In Video VidNames (its entry list; the first entry, sRsrcType, is here) */
    .short  0xE000, 0x0018, 0xFF00, 0x0000	| 408F35CE
DECL_SR7F_18_MacH_Built_In_Video_VidNames:  /* sResource 18 in pool 7F: MacH Built In Video VidNames (its entry list; the first entry, sRsrcType, is here) */
    .short  0xBB00, 0x0010, 0xBC00, 0x000C, 0xBD00	| 408F35D6
    .long   0x0008FF00, 0x00000000, 0x001C0080	| 408F35E0
    .ascii  "Macintosh LCD Display\000"
DECL_TYPE_0001_0000_0000_0000:  /* sRsrcType: category 0001, cType 0000, DrSW 0000, DrHW 0000 */
    .short  0x0001, 0x0000, 0x0000, 0x0000	| 408F3602
DECL_SR_01_Unknown_Macintosh_VendorInfo:  /* the VendorInfo (36) (pointed to by its entry) */
    .short  0x0100, 0x0014, 0x0300, 0x0028, 0x0400, 0x0040, 0x0500, 0x004C	| 408F360A
    .short  0xFF00, 0x0000	| 408F361A
    .ascii  "Apple Computer, Inc.\000\000"
    .short  0x0000	| 408F3634
    .ascii  "Macintosh CPU Family 4.0\000\000"
    .short  0x0000	| 408F3650
    .ascii  "The Horror ROM\000"
    .byte   0x00, 0x31, 0x38, 0x2D, 0x4D, 0x61, 0x79, 0x2D, 0x39, 0x33, 0x00	| 408F3661
DECL_SR7E_FA_CPU_68030_MacIIFamily:  /* sResource FA in pool 7E: CPU 68030 MacIIFamily (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x00, 0x28	| 408F366C s24 -> DECL_TYPE_000A_0004_0000_0018
DECL_SR7E_FA_CPU_68030_MacIIFamily_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x34	| 408F3670 s24 -> DECL_NAME_CPU_68030_MacIIFamily
DECL_SR7E_FA_CPU_68030_MacIIFamily_id81_entry:  /* entry, ID 81 */
    .byte   0x81, 0x00, 0x00, 0x52	| 408F3674 s24 -> DECL_SR7E_FA_CPU_68030_MacIIFamily_id81_data
DECL_SR7E_FA_CPU_68030_MacIIFamily_id82_entry:  /* entry, ID 82 */
    .byte   0x82, 0x00, 0x00, 0x56	| 408F3678 s24 -> DECL_SR7E_FA_CPU_68030_MacIIFamily_id82_data
    .long   0xFF000000	| 408F367C
DECL_SR7F_FB_CPU_68040:  /* sResource FB in pool 7F: CPU 68040 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x00, 0x1C	| 408F3680 s24 -> DECL_TYPE_000A_0005_0000_0018
DECL_SR7F_FB_CPU_68040_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x00, 0x38	| 408F3684 s24 -> DECL_NAME_CPU_68040
DECL_SR7F_FB_CPU_68040_id81_entry:  /* entry, ID 81 */
    .byte   0x81, 0x00, 0x00, 0x3E	| 408F3688 s24 -> DECL_SR7E_FA_CPU_68030_MacIIFamily_id81_data
DECL_SR7F_FB_CPU_68040_id82_entry:  /* entry, ID 82 */
    .byte   0x82, 0x00, 0x00, 0x42	| 408F368C s24 -> DECL_SR7E_FA_CPU_68030_MacIIFamily_id82_data
    .long   0xFF000000	| 408F3690
DECL_TYPE_000A_0004_0000_0018:  /* sRsrcType: category 000A, cType 0004, DrSW 0000, DrHW 0018 */
    .long   0x000A0004, 0x00000018	| 408F3694
DECL_TYPE_000A_0005_0000_0018:  /* sRsrcType: category 000A, cType 0005, DrSW 0000, DrHW 0018 */
    .long   0x000A0005	| 408F369C
    .long   0x00000018	| 408F36A0
DECL_NAME_CPU_68030_MacIIFamily:  /* name string (C string) */
    .ascii  "CPU_68030_\\_MacIIFamily\000"
DECL_NAME_CPU_68040:    /* name string (C string) */
    .long   0x4350555F	| 408F36BC
    .short  0x3638, 0x3034, 0x3000	| 408F36C0
DECL_SR7E_FA_CPU_68030_MacIIFamily_id81_data:  /* data of entry ID 81 */
    .short  0x0000, 0x0000, 0x3FFF, 0xFFFF	| 408F36C6
DECL_SR7E_FA_CPU_68030_MacIIFamily_id82_data:  /* data of entry ID 82 */
    .short  0xF080, 0x0000, 0xF0FF, 0xFFFF	| 408F36CE
DECL_SR7F_86_Video_RBV1:  /* sResource 86 in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x12, 0x34	| 408F36D6 s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_86_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x12, 0x70	| 408F36DA s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_86_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x14, 0x4E	| 408F36DE s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F36E2
DECL_SR7F_86_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x14, 0x7E	| 408F36E6 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_86_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x14, 0xA6	| 408F36EA s24 -> DECL_SR7F_86_Video_RBV1_MinorLength_data
DECL_SR7F_86_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x15, 0xC2	| 408F36EE s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_86_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x32, 0x22	| 408F36F2 s24 -> DECL_SR7E_8A_Video_Sonora_OneBitMode
DECL_SR7F_86_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x38, 0x42	| 408F36F6 s24 -> DECL_SR7E_8A_Video_Sonora_TwoBitMode
DECL_SR7F_86_Video_RBV1_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3E, 0xA0	| 408F36FA s24 -> DECL_SR7E_8A_Video_Sonora_FourBitMode
DECL_SR7F_86_Video_RBV1_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x45, 0x5E	| 408F36FE s24 -> DECL_SR7E_8B_Video_Sonora_EightBitMode
    .short  0xFF00, 0x0000	| 408F3702
DECL_SR7F_96_Video_RBV1:  /* sResource 96 in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x12, 0x04	| 408F3706 s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_96_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x12, 0x40	| 408F370A s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_96_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x14, 0x1E	| 408F370E s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F3712
DECL_SR7F_96_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x14, 0x4E	| 408F3716 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_96_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x14, 0x7A	| 408F371A s24 -> DECL_SR7F_96_Video_RBV1_MinorLength_data
DECL_SR7F_96_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x15, 0x92	| 408F371E s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_96_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x31, 0xF2	| 408F3722 s24 -> DECL_SR7E_8A_Video_Sonora_OneBitMode
DECL_SR7F_96_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x38, 0x12	| 408F3726 s24 -> DECL_SR7E_8A_Video_Sonora_TwoBitMode
DECL_SR7F_96_Video_RBV1_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3E, 0x70	| 408F372A s24 -> DECL_SR7E_8A_Video_Sonora_FourBitMode
    .short  0xFF00, 0x0000	| 408F372E
DECL_SR7F_9E_Video_RBV1:  /* sResource 9E in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x11, 0xD8	| 408F3732 s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_9E_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x12, 0x14	| 408F3736 s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_9E_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x13, 0xF2	| 408F373A s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F373E
DECL_SR7F_9E_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x14, 0x22	| 408F3742 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_9E_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x14, 0x52	| 408F3746 s24 -> DECL_SR7F_9E_Video_RBV1_MinorLength_data
DECL_SR7F_9E_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x15, 0x66	| 408F374A s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_9E_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x31, 0xC6	| 408F374E s24 -> DECL_SR7E_8A_Video_Sonora_OneBitMode
DECL_SR7F_9E_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x37, 0xE6	| 408F3752 s24 -> DECL_SR7E_8A_Video_Sonora_TwoBitMode
    .short  0xFF00, 0x0000	| 408F3756
DECL_SR7F_8E_Video_RBV1:  /* sResource 8E in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x11, 0xB0	| 408F375A s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_8E_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x11, 0xEC	| 408F375E s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_8E_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x13, 0xCA	| 408F3762 s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F3766
DECL_SR7F_8E_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x13, 0xFA	| 408F376A s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_8E_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x14, 0x2E	| 408F376E s24 -> DECL_SR7F_8E_Video_RBV1_MinorLength_data
DECL_SR7F_8E_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x15, 0x3E	| 408F3772 s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_8E_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x31, 0x9E	| 408F3776 s24 -> DECL_SR7E_8A_Video_Sonora_OneBitMode
    .short  0xFF00, 0x0000	| 408F377A
DECL_SR7F_81_Video_RBV1:  /* sResource 81 in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x11, 0x8C	| 408F377E s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_81_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x11, 0xC8	| 408F3782 s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_81_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x13, 0xA6	| 408F3786 s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F378A
DECL_SR7F_81_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x13, 0xD6	| 408F378E s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_81_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x14, 0x0E	| 408F3792 s24 -> DECL_SR7F_81_Video_RBV1_MinorLength_data
DECL_SR7F_81_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x15, 0x22	| 408F3796 s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7F_81_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x31, 0x9A	| 408F379A s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode
DECL_SR7F_81_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x37, 0xBA	| 408F379E s24 -> DECL_SR7E_80_Video_Sonora_TwoBitMode
DECL_SR7F_81_Video_RBV1_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3E, 0x18	| 408F37A2 s24 -> DECL_SR7E_81_Video_Sonora_FourBitMode
    .short  0xFF00, 0x0000	| 408F37A6
DECL_SR7F_91_Video_RBV1:  /* sResource 91 in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x11, 0x60	| 408F37AA s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_91_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x11, 0x9C	| 408F37AE s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_91_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x13, 0x7A	| 408F37B2 s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F37B6
DECL_SR7F_91_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x13, 0xAA	| 408F37BA s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_91_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x13, 0xE6	| 408F37BE s24 -> DECL_SR7F_91_Video_RBV1_MinorLength_data
DECL_SR7F_91_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x14, 0xF6	| 408F37C2 s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7F_91_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x31, 0x6E	| 408F37C6 s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode
DECL_SR7F_91_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x37, 0x8E	| 408F37CA s24 -> DECL_SR7E_80_Video_Sonora_TwoBitMode
    .short  0xFF00, 0x0000	| 408F37CE
DECL_SR7F_89_Video_RBV1:  /* sResource 89 in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x11, 0x38	| 408F37D2 s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_89_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x11, 0x74	| 408F37D6 s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_89_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x13, 0x52	| 408F37DA s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F37DE
DECL_SR7F_89_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x13, 0x82	| 408F37E2 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_89_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x13, 0xC2	| 408F37E6 s24 -> DECL_SR7F_89_Video_RBV1_MinorLength_data
DECL_SR7F_89_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x14, 0xCE	| 408F37EA s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7F_89_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x31, 0x46	| 408F37EE s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode
    .short  0xFF00, 0x0000	| 408F37F2
DECL_SR7F_82_Video_RBV1:  /* sResource 82 in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x11, 0x14	| 408F37F6 s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_82_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x11, 0x50	| 408F37FA s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_82_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x13, 0x2E	| 408F37FE s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F3802
DECL_SR7F_82_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x13, 0x5E	| 408F3806 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_82_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x13, 0xB2	| 408F380A s24 -> DECL_SR7F_82_Video_RBV1_MinorLength_data
DECL_SR7F_82_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x14, 0xB2	| 408F380E s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_82_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x31, 0x32	| 408F3812 s24 -> DECL_SR7E_83_Video_Sonora_OneBitMode
DECL_SR7F_82_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x37, 0x52	| 408F3816 s24 -> DECL_SR7E_83_Video_Sonora_TwoBitMode
DECL_SR7F_82_Video_RBV1_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3D, 0xB0	| 408F381A s24 -> DECL_SR7E_83_Video_Sonora_FourBitMode
DECL_SR7F_82_Video_RBV1_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x44, 0x6E	| 408F381E s24 -> DECL_SR7E_83_Video_Sonora_EightBitMode
    .short  0xFF00, 0x0000	| 408F3822
DECL_SR7F_92_Video_RBV1:  /* sResource 92 in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x10, 0xE4	| 408F3826 s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_92_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x11, 0x20	| 408F382A s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_92_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x12, 0xFE	| 408F382E s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F3832
DECL_SR7F_92_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x13, 0x2E	| 408F3836 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_92_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x13, 0x86	| 408F383A s24 -> DECL_SR7F_92_Video_RBV1_MinorLength_data
DECL_SR7F_92_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x14, 0x82	| 408F383E s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_92_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x31, 0x02	| 408F3842 s24 -> DECL_SR7E_83_Video_Sonora_OneBitMode
DECL_SR7F_92_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x37, 0x22	| 408F3846 s24 -> DECL_SR7E_83_Video_Sonora_TwoBitMode
DECL_SR7F_92_Video_RBV1_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3D, 0x80	| 408F384A s24 -> DECL_SR7E_83_Video_Sonora_FourBitMode
    .short  0xFF00, 0x0000	| 408F384E
DECL_SR7F_9A_Video_RBV1:  /* sResource 9A in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x10, 0xB8	| 408F3852 s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_9A_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x10, 0xF4	| 408F3856 s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_9A_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x12, 0xD2	| 408F385A s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F385E
DECL_SR7F_9A_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x13, 0x02	| 408F3862 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_9A_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x13, 0x5E	| 408F3866 s24 -> DECL_SR7F_9A_Video_RBV1_MinorLength_data
DECL_SR7F_9A_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x14, 0x56	| 408F386A s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_9A_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x30, 0xD6	| 408F386E s24 -> DECL_SR7E_83_Video_Sonora_OneBitMode
DECL_SR7F_9A_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x36, 0xF6	| 408F3872 s24 -> DECL_SR7E_83_Video_Sonora_TwoBitMode
    .short  0xFF00, 0x0000	| 408F3876
DECL_SR7F_8A_Video_RBV1:  /* sResource 8A in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x10, 0x90	| 408F387A s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_8A_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x10, 0xCC	| 408F387E s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_8A_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x12, 0xAA	| 408F3882 s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F3886
DECL_SR7F_8A_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x12, 0xDA	| 408F388A s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_8A_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x13, 0x3A	| 408F388E s24 -> DECL_SR7F_8A_Video_RBV1_MinorLength_data
DECL_SR7F_8A_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x14, 0x2E	| 408F3892 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_8A_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x30, 0xAE	| 408F3896 s24 -> DECL_SR7E_83_Video_Sonora_OneBitMode
    .short  0xFF00, 0x0000	| 408F389A
DECL_SR7F_87_Video_RBV1:  /* sResource 87 in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x10, 0x6C	| 408F389E s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_87_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x10, 0xA8	| 408F38A2 s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_87_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x12, 0x86	| 408F38A6 s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F38AA
DECL_SR7F_87_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x12, 0xB6	| 408F38AE s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_87_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x12, 0xFA	| 408F38B2 s24 -> DECL_SR7F_87_Video_RBV1_MinorLength_data
DECL_SR7F_87_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x14, 0x0A	| 408F38B6 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_87_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x30, 0xBA	| 408F38BA s24 -> DECL_SR7F_87_Video_RBV1_OneBitMode
DECL_SR7F_87_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x36, 0xDA	| 408F38BE s24 -> DECL_SR7F_87_Video_RBV1_TwoBitMode
DECL_SR7F_87_Video_RBV1_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3D, 0x38	| 408F38C2 s24 -> DECL_SR7F_87_Video_RBV1_FourBitMode
DECL_SR7F_87_Video_RBV1_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x43, 0xF6	| 408F38C6 s24 -> DECL_SR7F_87_Video_RBV1_EightBitMode
    .short  0xFF00, 0x0000	| 408F38CA
DECL_SR7F_97_Video_RBV1:  /* sResource 97 in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x10, 0x3C	| 408F38CE s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_97_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x10, 0x78	| 408F38D2 s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_97_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x12, 0x56	| 408F38D6 s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F38DA
DECL_SR7F_97_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x12, 0x86	| 408F38DE s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_97_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x12, 0xCE	| 408F38E2 s24 -> DECL_SR7F_97_Video_RBV1_MinorLength_data
DECL_SR7F_97_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x13, 0xDA	| 408F38E6 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_97_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x30, 0x8A	| 408F38EA s24 -> DECL_SR7F_87_Video_RBV1_OneBitMode
DECL_SR7F_97_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x36, 0xAA	| 408F38EE s24 -> DECL_SR7F_87_Video_RBV1_TwoBitMode
DECL_SR7F_97_Video_RBV1_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3D, 0x08	| 408F38F2 s24 -> DECL_SR7F_87_Video_RBV1_FourBitMode
    .short  0xFF00, 0x0000	| 408F38F6
DECL_SR7F_9F_Video_RBV1:  /* sResource 9F in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x10, 0x10	| 408F38FA s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_9F_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x10, 0x4C	| 408F38FE s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_9F_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x12, 0x2A	| 408F3902 s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F3906
DECL_SR7F_9F_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x12, 0x5A	| 408F390A s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_9F_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x12, 0xA6	| 408F390E s24 -> DECL_SR7F_9F_Video_RBV1_MinorLength_data
DECL_SR7F_9F_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x13, 0xAE	| 408F3912 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_9F_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x30, 0x5E	| 408F3916 s24 -> DECL_SR7F_87_Video_RBV1_OneBitMode
DECL_SR7F_9F_Video_RBV1_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x36, 0x7E	| 408F391A s24 -> DECL_SR7F_87_Video_RBV1_TwoBitMode
    .short  0xFF00, 0x0000	| 408F391E
DECL_SR7F_8F_Video_RBV1:  /* sResource 8F in pool 7F: Video RBV1 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0F, 0xE8	| 408F3922 s24 -> DECL_TYPE_0003_0001_0001_0018
DECL_SR7F_8F_Video_RBV1_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x10, 0x24	| 408F3926 s24 -> DECL_NAME_Display_Video_Apple_RBV1
DECL_SR7F_8F_Video_RBV1_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x12, 0x02	| 408F392A s24 -> DECL_SR7F_81_Video_RBV1_DrvrDir
    .short  0x0800, 0x0001	| 408F392E
DECL_SR7F_8F_Video_RBV1_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x12, 0x32	| 408F3932 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_8F_Video_RBV1_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x12, 0x82	| 408F3936 s24 -> DECL_SR7F_8F_Video_RBV1_MinorLength_data
DECL_SR7F_8F_Video_RBV1_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x13, 0x86	| 408F393A s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_8F_Video_RBV1_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x30, 0x36	| 408F393E s24 -> DECL_SR7F_87_Video_RBV1_OneBitMode
    .short  0xFF00, 0x0000	| 408F3942
DECL_SR7F_A2_Video_V8:  /* sResource A2 in pool 7F: Video V8 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0F, 0xCC	| 408F3946 s24 -> DECL_TYPE_0003_0001_0001_001A
DECL_SR7F_A2_Video_V8_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x10, 0x1C	| 408F394A s24 -> DECL_NAME_Display_Video_Apple_V8
DECL_SR7F_A2_Video_V8_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x11, 0xE6	| 408F394E s24 -> DECL_SR7F_A2_Video_V8_DrvrDir
    .short  0x0800, 0x0001	| 408F3952
DECL_SR7F_A2_Video_V8_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x12, 0x0E	| 408F3956 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_A2_Video_V8_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x12, 0x7A	| 408F395A s24 -> DECL_SR7F_A2_Video_V8_MinorLength_data
DECL_SR7F_A2_Video_V8_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x13, 0x62	| 408F395E s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_A2_Video_V8_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x30, 0x42	| 408F3962 s24 -> DECL_SR7F_A2_Video_V8_OneBitMode
DECL_SR7F_A2_Video_V8_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x36, 0x62	| 408F3966 s24 -> DECL_SR7F_A2_Video_V8_TwoBitMode
DECL_SR7F_A2_Video_V8_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3C, 0xC0	| 408F396A s24 -> DECL_SR7F_A2_Video_V8_FourBitMode
DECL_SR7F_A2_Video_V8_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x43, 0x6E	| 408F396E s24 -> DECL_SR7F_A2_Video_V8_EightBitMode
DECL_SR7F_A2_Video_V8_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x48, 0x40	| 408F3972 s24 -> DECL_SR7E_84_Video_Sonora_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3976
DECL_SR7F_AA_Video_V8:  /* sResource AA in pool 7F: Video V8 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0F, 0x98	| 408F397A s24 -> DECL_TYPE_0003_0001_0001_001A
DECL_SR7F_AA_Video_V8_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0F, 0xE8	| 408F397E s24 -> DECL_NAME_Display_Video_Apple_V8
DECL_SR7F_AA_Video_V8_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x11, 0xB2	| 408F3982 s24 -> DECL_SR7F_A2_Video_V8_DrvrDir
    .short  0x0800, 0x0001	| 408F3986
DECL_SR7F_AA_Video_V8_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x11, 0xDA	| 408F398A s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_AA_Video_V8_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x12, 0x4A	| 408F398E s24 -> DECL_SR7F_AA_Video_V8_MinorLength_data
DECL_SR7F_AA_Video_V8_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x13, 0x2E	| 408F3992 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_AA_Video_V8_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x30, 0x1E	| 408F3996 s24 -> DECL_SR7F_AA_Video_V8_OneBitMode
DECL_SR7F_AA_Video_V8_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x36, 0x3E	| 408F399A s24 -> DECL_SR7F_AA_Video_V8_TwoBitMode
DECL_SR7F_AA_Video_V8_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3C, 0x9C	| 408F399E s24 -> DECL_SR7F_AA_Video_V8_FourBitMode
DECL_SR7F_AA_Video_V8_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x43, 0x4A	| 408F39A2 s24 -> DECL_SR7F_AA_Video_V8_EightBitMode
    .short  0xFF00, 0x0000	| 408F39A6
DECL_SR7F_B2_Video_V8:  /* sResource B2 in pool 7F: Video V8 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0F, 0x68	| 408F39AA s24 -> DECL_TYPE_0003_0001_0001_001A
DECL_SR7F_B2_Video_V8_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0F, 0xB8	| 408F39AE s24 -> DECL_NAME_Display_Video_Apple_V8
DECL_SR7F_B2_Video_V8_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x11, 0x82	| 408F39B2 s24 -> DECL_SR7F_A2_Video_V8_DrvrDir
    .short  0x0800, 0x0001	| 408F39B6
DECL_SR7F_B2_Video_V8_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x11, 0xAA	| 408F39BA s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_B2_Video_V8_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x12, 0x26	| 408F39BE s24 -> DECL_SR7F_B2_Video_V8_MinorLength_data
DECL_SR7F_B2_Video_V8_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x12, 0xFE	| 408F39C2 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_B2_Video_V8_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2F, 0xFE	| 408F39C6 s24 -> DECL_SR7F_B2_Video_V8_OneBitMode
DECL_SR7F_B2_Video_V8_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x36, 0x1E	| 408F39CA s24 -> DECL_SR7F_B2_Video_V8_TwoBitMode
DECL_SR7F_B2_Video_V8_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3C, 0x7C	| 408F39CE s24 -> DECL_SR7F_B2_Video_V8_FourBitMode
DECL_SR7F_B2_Video_V8_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x43, 0x2A	| 408F39D2 s24 -> DECL_SR7F_B2_Video_V8_EightBitMode
    .short  0xFF00, 0x0000	| 408F39D6
DECL_SR7F_BA_Video_V8:  /* sResource BA in pool 7F: Video V8 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0F, 0x38	| 408F39DA s24 -> DECL_TYPE_0003_0001_0001_001A
DECL_SR7F_BA_Video_V8_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0F, 0x88	| 408F39DE s24 -> DECL_NAME_Display_Video_Apple_V8
DECL_SR7F_BA_Video_V8_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x11, 0x52	| 408F39E2 s24 -> DECL_SR7F_A2_Video_V8_DrvrDir
    .short  0x0800, 0x0001	| 408F39E6
DECL_SR7F_BA_Video_V8_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x11, 0x7A	| 408F39EA s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_BA_Video_V8_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x11, 0xFA	| 408F39EE s24 -> DECL_SR7F_BA_Video_V8_MinorLength_data
DECL_SR7F_BA_Video_V8_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x12, 0xCE	| 408F39F2 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_BA_Video_V8_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2F, 0xDE	| 408F39F6 s24 -> DECL_SR7F_BA_Video_V8_OneBitMode
DECL_SR7F_BA_Video_V8_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x35, 0xFE	| 408F39FA s24 -> DECL_SR7F_BA_Video_V8_TwoBitMode
DECL_SR7F_BA_Video_V8_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3C, 0x5C	| 408F39FE s24 -> DECL_SR7F_BA_Video_V8_FourBitMode
    .short  0xFF00, 0x0000	| 408F3A02
DECL_SR7F_A6_Video_V8:  /* sResource A6 in pool 7F: Video V8 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0F, 0x0C	| 408F3A06 s24 -> DECL_TYPE_0003_0001_0001_001A
DECL_SR7F_A6_Video_V8_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0F, 0x5C	| 408F3A0A s24 -> DECL_NAME_Display_Video_Apple_V8
DECL_SR7F_A6_Video_V8_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x11, 0x26	| 408F3A0E s24 -> DECL_SR7F_A2_Video_V8_DrvrDir
    .short  0x0800, 0x0001	| 408F3A12
DECL_SR7F_A6_Video_V8_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x11, 0x4E	| 408F3A16 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_A6_Video_V8_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x11, 0xB2	| 408F3A1A s24 -> DECL_SR7F_A6_Video_V8_MinorLength_data
DECL_SR7F_A6_Video_V8_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x12, 0x92	| 408F3A1E s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_A6_Video_V8_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2F, 0x62	| 408F3A22 s24 -> DECL_SR7F_A3_Video_V8_OneBitMode
DECL_SR7F_A6_Video_V8_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x35, 0x82	| 408F3A26 s24 -> DECL_SR7F_A3_Video_V8_TwoBitMode
DECL_SR7F_A6_Video_V8_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3B, 0xE0	| 408F3A2A s24 -> DECL_SR7F_A3_Video_V8_FourBitMode
DECL_SR7F_A6_Video_V8_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x42, 0x9E	| 408F3A2E s24 -> DECL_SR7F_A3_Video_V8_EightBitMode
    .short  0xFF00, 0x0000	| 408F3A32
DECL_SR7F_AE_Video_V8:  /* sResource AE in pool 7F: Video V8 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0E, 0xDC	| 408F3A36 s24 -> DECL_TYPE_0003_0001_0001_001A
DECL_SR7F_AE_Video_V8_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0F, 0x2C	| 408F3A3A s24 -> DECL_NAME_Display_Video_Apple_V8
DECL_SR7F_AE_Video_V8_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x10, 0xF6	| 408F3A3E s24 -> DECL_SR7F_A2_Video_V8_DrvrDir
    .short  0x0800, 0x0001	| 408F3A42
DECL_SR7F_AE_Video_V8_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x11, 0x1E	| 408F3A46 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_AE_Video_V8_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x11, 0x86	| 408F3A4A s24 -> DECL_SR7F_AE_Video_V8_MinorLength_data
DECL_SR7F_AE_Video_V8_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x12, 0x62	| 408F3A4E s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_AE_Video_V8_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2F, 0x42	| 408F3A52 s24 -> DECL_SR7F_AB_Video_V8_OneBitMode
DECL_SR7F_AE_Video_V8_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x35, 0x62	| 408F3A56 s24 -> DECL_SR7F_AB_Video_V8_TwoBitMode
DECL_SR7F_AE_Video_V8_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3B, 0xC0	| 408F3A5A s24 -> DECL_SR7F_AB_Video_V8_FourBitMode
    .short  0xFF00, 0x0000	| 408F3A5E
DECL_SR7F_A3_Video_V8:  /* sResource A3 in pool 7F: Video V8 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0E, 0xB0	| 408F3A62 s24 -> DECL_TYPE_0003_0001_0001_001A
DECL_SR7F_A3_Video_V8_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0F, 0x00	| 408F3A66 s24 -> DECL_NAME_Display_Video_Apple_V8
DECL_SR7F_A3_Video_V8_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x10, 0xCA	| 408F3A6A s24 -> DECL_SR7F_A2_Video_V8_DrvrDir
    .short  0x0800, 0x0001	| 408F3A6E
DECL_SR7F_A3_Video_V8_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x10, 0xF2	| 408F3A72 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_A3_Video_V8_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x11, 0x66	| 408F3A76 s24 -> DECL_SR7F_A3_Video_V8_MinorLength_data
DECL_SR7F_A3_Video_V8_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2F, 0x0A	| 408F3A7A s24 -> DECL_SR7F_A3_Video_V8_OneBitMode
DECL_SR7F_A3_Video_V8_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x35, 0x2A	| 408F3A7E s24 -> DECL_SR7F_A3_Video_V8_TwoBitMode
DECL_SR7F_A3_Video_V8_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3B, 0x88	| 408F3A82 s24 -> DECL_SR7F_A3_Video_V8_FourBitMode
DECL_SR7F_A3_Video_V8_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x42, 0x46	| 408F3A86 s24 -> DECL_SR7F_A3_Video_V8_EightBitMode
    .short  0xFF00, 0x0000	| 408F3A8A
DECL_SR7F_AB_Video_V8:  /* sResource AB in pool 7F: Video V8 (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0E, 0x84	| 408F3A8E s24 -> DECL_TYPE_0003_0001_0001_001A
DECL_SR7F_AB_Video_V8_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0E, 0xD4	| 408F3A92 s24 -> DECL_NAME_Display_Video_Apple_V8
DECL_SR7F_AB_Video_V8_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x10, 0x9E	| 408F3A96 s24 -> DECL_SR7F_A2_Video_V8_DrvrDir
    .short  0x0800, 0x0001	| 408F3A9A
DECL_SR7F_AB_Video_V8_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x10, 0xC6	| 408F3A9E s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_AB_Video_V8_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x11, 0x3E	| 408F3AA2 s24 -> DECL_SR7F_AB_Video_V8_MinorLength_data
DECL_SR7F_AB_Video_V8_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2E, 0xEE	| 408F3AA6 s24 -> DECL_SR7F_AB_Video_V8_OneBitMode
DECL_SR7F_AB_Video_V8_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x35, 0x0E	| 408F3AAA s24 -> DECL_SR7F_AB_Video_V8_TwoBitMode
DECL_SR7F_AB_Video_V8_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3B, 0x6C	| 408F3AAE s24 -> DECL_SR7F_AB_Video_V8_FourBitMode
    .short  0xFF00, 0x0000	| 408F3AB2
DECL_SR7F_BE_Video_DAFB:  /* sResource BE in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0E, 0x6C	| 408F3AB6 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_BE_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0E, 0xDC	| 408F3ABA s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_BE_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x10, 0x7E	| 408F3ABE s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3AC2
DECL_SR7F_BE_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x10, 0x9E	| 408F3ACA s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_BE_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x11, 0x86	| 408F3ACE s24 -> DECL_SR7F_BE_Video_DAFB_MinorLength_data
DECL_SR7F_BE_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x11, 0xD2	| 408F3AD2 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_BE_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2F, 0x0E	| 408F3AD6 s24 -> DECL_SR7F_BE_Video_DAFB_OneBitMode
DECL_SR7F_BE_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x35, 0x2E	| 408F3ADA s24 -> DECL_SR7F_BE_Video_DAFB_TwoBitMode
DECL_SR7F_BE_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3B, 0x8C	| 408F3ADE s24 -> DECL_SR7F_BE_Video_DAFB_FourBitMode
    .short  0xFF00, 0x0000	| 408F3AE2
DECL_SR7F_BF_Video_DAFB:  /* sResource BF in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0E, 0x3C	| 408F3AE6 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_BF_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0E, 0xAC	| 408F3AEA s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_BF_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x10, 0x4E	| 408F3AEE s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3AF2
DECL_SR7F_BF_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x10, 0x6E	| 408F3AFA s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_BF_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x11, 0x5A	| 408F3AFE s24 -> DECL_SR7F_BF_Video_DAFB_MinorLength_data
DECL_SR7F_BF_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x11, 0xA2	| 408F3B02 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_BF_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2E, 0xDE	| 408F3B06 s24 -> DECL_SR7F_BE_Video_DAFB_OneBitMode
DECL_SR7F_BF_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x34, 0xFE	| 408F3B0A s24 -> DECL_SR7F_BE_Video_DAFB_TwoBitMode
DECL_SR7F_BF_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3B, 0x5C	| 408F3B0E s24 -> DECL_SR7F_BE_Video_DAFB_FourBitMode
DECL_SR7F_BF_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x41, 0xFA	| 408F3B12 s24 -> DECL_SR7F_BF_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F3B16
DECL_SR7F_F9_Video_DAFB:  /* sResource F9 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0E, 0x08	| 408F3B1A s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_F9_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0E, 0x78	| 408F3B1E s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_F9_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x10, 0x1A	| 408F3B22 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3B26
DECL_SR7F_F9_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x10, 0x3A	| 408F3B2E s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_F9_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x11, 0x2A	| 408F3B32 s24 -> DECL_SR7F_F9_Video_DAFB_MinorLength_data
DECL_SR7F_F9_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x11, 0x6E	| 408F3B36 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_F9_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2E, 0xAA	| 408F3B3A s24 -> DECL_SR7F_BE_Video_DAFB_OneBitMode
DECL_SR7F_F9_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x34, 0xCA	| 408F3B3E s24 -> DECL_SR7F_BE_Video_DAFB_TwoBitMode
DECL_SR7F_F9_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3B, 0x28	| 408F3B42 s24 -> DECL_SR7F_BE_Video_DAFB_FourBitMode
DECL_SR7F_F9_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x41, 0xC6	| 408F3B46 s24 -> DECL_SR7F_BF_Video_DAFB_EightBitMode
DECL_SR7F_F9_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x46, 0x88	| 408F3B4A s24 -> DECL_SR7F_F9_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3B4E
DECL_SR7F_C0_Video_DAFB:  /* sResource C0 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0D, 0xD0	| 408F3B52 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C0_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0E, 0x40	| 408F3B56 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C0_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0F, 0xE2	| 408F3B5A s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3B5E
DECL_SR7F_C0_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x10, 0x02	| 408F3B66 s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C0_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x10, 0x82	| 408F3B6A s24 -> DECL_SR7F_C0_Video_DAFB_MinorLength_data
DECL_SR7F_C0_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x11, 0x4A	| 408F3B6E s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7F_C0_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2E, 0x82	| 408F3B72 s24 -> DECL_SR7F_C0_Video_DAFB_OneBitMode
DECL_SR7F_C0_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x34, 0xA2	| 408F3B76 s24 -> DECL_SR7F_C0_Video_DAFB_TwoBitMode
DECL_SR7F_C0_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3B, 0x00	| 408F3B7A s24 -> DECL_SR7F_C0_Video_DAFB_FourBitMode
    .short  0xFF00, 0x0000	| 408F3B7E
DECL_SR7F_C1_Video_DAFB:  /* sResource C1 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0D, 0xA0	| 408F3B82 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C1_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0E, 0x10	| 408F3B86 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C1_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0F, 0xB2	| 408F3B8A s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3B8E
DECL_SR7F_C1_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0F, 0xD2	| 408F3B96 s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C1_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x10, 0x56	| 408F3B9A s24 -> DECL_SR7F_C1_Video_DAFB_MinorLength_data
DECL_SR7F_C1_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x11, 0x1A	| 408F3B9E s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7F_C1_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2E, 0x52	| 408F3BA2 s24 -> DECL_SR7F_C0_Video_DAFB_OneBitMode
DECL_SR7F_C1_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x34, 0x72	| 408F3BA6 s24 -> DECL_SR7F_C0_Video_DAFB_TwoBitMode
DECL_SR7F_C1_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3A, 0xD0	| 408F3BAA s24 -> DECL_SR7F_C0_Video_DAFB_FourBitMode
DECL_SR7F_C1_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x41, 0x6E	| 408F3BAE s24 -> DECL_SR7F_C1_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F3BB2
DECL_SR7F_C4_Video_DAFB:  /* sResource C4 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0D, 0x6C	| 408F3BB6 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C4_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0D, 0xDC	| 408F3BBA s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C4_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0F, 0x7E	| 408F3BBE s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3BC2
DECL_SR7F_C4_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0F, 0xA6	| 408F3BCA s24 -> DECL_SR7F_C4_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C4_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x10, 0x2A	| 408F3BCE s24 -> DECL_SR7F_C4_Video_DAFB_MinorLength_data
DECL_SR7F_C4_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x10, 0xE6	| 408F3BD2 s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7F_C4_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2E, 0x2E	| 408F3BD6 s24 -> DECL_SR7F_C4_Video_DAFB_OneBitMode
DECL_SR7F_C4_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x34, 0x4E	| 408F3BDA s24 -> DECL_SR7F_C4_Video_DAFB_TwoBitMode
DECL_SR7F_C4_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3A, 0xAC	| 408F3BDE s24 -> DECL_SR7F_C4_Video_DAFB_FourBitMode
    .short  0xFF00, 0x0000	| 408F3BE2
DECL_SR7F_C5_Video_DAFB:  /* sResource C5 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0D, 0x3C	| 408F3BE6 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C5_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0D, 0xAC	| 408F3BEA s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C5_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0F, 0x4E	| 408F3BEE s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3BF2
DECL_SR7F_C5_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0F, 0x76	| 408F3BFA s24 -> DECL_SR7F_C4_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C5_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0F, 0xFE	| 408F3BFE s24 -> DECL_SR7F_C5_Video_DAFB_MinorLength_data
DECL_SR7F_C5_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x10, 0xB6	| 408F3C02 s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7F_C5_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2D, 0xFE	| 408F3C06 s24 -> DECL_SR7F_C4_Video_DAFB_OneBitMode
DECL_SR7F_C5_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x34, 0x1E	| 408F3C0A s24 -> DECL_SR7F_C4_Video_DAFB_TwoBitMode
DECL_SR7F_C5_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3A, 0x7C	| 408F3C0E s24 -> DECL_SR7F_C4_Video_DAFB_FourBitMode
DECL_SR7F_C5_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x41, 0x1A	| 408F3C12 s24 -> DECL_SR7F_C5_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F3C16
DECL_SR7F_C6_Video_DAFB:  /* sResource C6 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0D, 0x08	| 408F3C1A s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C6_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0D, 0x78	| 408F3C1E s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C6_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0F, 0x1A	| 408F3C22 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3C26
DECL_SR7F_C6_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0F, 0x4A	| 408F3C2E s24 -> DECL_SR7F_C6_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C6_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0F, 0xD2	| 408F3C32 s24 -> DECL_SR7F_C6_Video_DAFB_MinorLength_data
DECL_SR7F_C6_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x10, 0x6E	| 408F3C36 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_C6_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2D, 0xDA	| 408F3C3A s24 -> DECL_SR7F_C6_Video_DAFB_OneBitMode
DECL_SR7F_C6_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x33, 0xFA	| 408F3C3E s24 -> DECL_SR7F_C6_Video_DAFB_TwoBitMode
DECL_SR7F_C6_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3A, 0x58	| 408F3C42 s24 -> DECL_SR7F_C6_Video_DAFB_FourBitMode
DECL_SR7F_C6_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x40, 0xF6	| 408F3C46 s24 -> DECL_SR7F_C6_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F3C4A
DECL_SR7F_C7_Video_DAFB:  /* sResource C7 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0C, 0xD4	| 408F3C4E s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C7_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0D, 0x44	| 408F3C52 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C7_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0E, 0xE6	| 408F3C56 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3C5A
DECL_SR7F_C7_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0F, 0x12	| 408F3C62 s24 -> DECL_SR7F_C7_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C7_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0F, 0xA6	| 408F3C66 s24 -> DECL_SR7F_C7_Video_DAFB_MinorLength_data
DECL_SR7F_C7_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x10, 0x3A	| 408F3C6A s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_C7_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2D, 0xA6	| 408F3C6E s24 -> DECL_SR7F_C6_Video_DAFB_OneBitMode
DECL_SR7F_C7_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x33, 0xC6	| 408F3C72 s24 -> DECL_SR7F_C6_Video_DAFB_TwoBitMode
DECL_SR7F_C7_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x3A, 0x24	| 408F3C76 s24 -> DECL_SR7F_C6_Video_DAFB_FourBitMode
DECL_SR7F_C7_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x40, 0xC2	| 408F3C7A s24 -> DECL_SR7F_C6_Video_DAFB_EightBitMode
DECL_SR7F_C7_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x48, 0x4A	| 408F3C7E s24 -> DECL_SR7F_C7_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3C82
DECL_SR7F_E6_Video_DAFB:  /* sResource E6 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0C, 0x9C	| 408F3C86 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_E6_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0D, 0x0C	| 408F3C8A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_E6_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0E, 0xAE	| 408F3C8E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3C92
DECL_SR7F_E6_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0E, 0xDE	| 408F3C9A s24 -> DECL_SR7F_C6_Video_DAFB_MinorBaseOS_data
DECL_SR7F_E6_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0F, 0x6A	| 408F3C9E s24 -> DECL_SR7F_E6_Video_DAFB_MinorLength_data
DECL_SR7F_E6_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x10, 0x02	| 408F3CA2 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_E6_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2D, 0x6E	| 408F3CA6 s24 -> DECL_SR7F_C6_Video_DAFB_OneBitMode
DECL_SR7F_E6_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x33, 0x8E	| 408F3CAA s24 -> DECL_SR7F_C6_Video_DAFB_TwoBitMode
DECL_SR7F_E6_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x39, 0xEC	| 408F3CAE s24 -> DECL_SR7F_C6_Video_DAFB_FourBitMode
DECL_SR7F_E6_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x40, 0x8A	| 408F3CB2 s24 -> DECL_SR7F_C6_Video_DAFB_EightBitMode
DECL_SR7F_E6_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x45, 0x4C	| 408F3CB6 s24 -> DECL_SR7F_E6_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3CBA
DECL_SR7F_E7_Video_DAFB:  /* sResource E7 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0C, 0x64	| 408F3CBE s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_E7_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0C, 0xD4	| 408F3CC2 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_E7_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0E, 0x76	| 408F3CC6 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3CCA
DECL_SR7F_E7_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0E, 0xA2	| 408F3CD2 s24 -> DECL_SR7F_C7_Video_DAFB_MinorBaseOS_data
DECL_SR7F_E7_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0F, 0x36	| 408F3CD6 s24 -> DECL_SR7F_C7_Video_DAFB_MinorLength_data
DECL_SR7F_E7_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0F, 0xCA	| 408F3CDA s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_E7_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2D, 0x36	| 408F3CDE s24 -> DECL_SR7F_C6_Video_DAFB_OneBitMode
DECL_SR7F_E7_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x33, 0x56	| 408F3CE2 s24 -> DECL_SR7F_C6_Video_DAFB_TwoBitMode
DECL_SR7F_E7_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x39, 0xB4	| 408F3CE6 s24 -> DECL_SR7F_C6_Video_DAFB_FourBitMode
DECL_SR7F_E7_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x40, 0x52	| 408F3CEA s24 -> DECL_SR7F_C6_Video_DAFB_EightBitMode
DECL_SR7F_E7_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x45, 0x14	| 408F3CEE s24 -> DECL_SR7F_E6_Video_DAFB_SixteenBitMode
DECL_SR7F_E7_Video_DAFB_ThirtyTwoBitMode_entry:  /* entry ThirtyTwoBitMode (133): 32 bits per pixel */
    .byte   0x85, 0x00, 0x47, 0xD6	| 408F3CF2 s24 -> DECL_SR7F_C7_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3CF6
DECL_SR7F_C2_Video_DAFB:  /* sResource C2 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0C, 0x28	| 408F3CFA s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C2_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0C, 0x98	| 408F3CFE s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C2_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0E, 0x3A	| 408F3D02 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3D06
DECL_SR7F_C2_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0E, 0x5A	| 408F3D0E s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C2_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0E, 0xFE	| 408F3D12 s24 -> DECL_SR7F_C2_Video_DAFB_MinorLength_data
DECL_SR7F_C2_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0F, 0xAA	| 408F3D16 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_C2_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2D, 0x0A	| 408F3D1A s24 -> DECL_SR7F_C2_Video_DAFB_OneBitMode
DECL_SR7F_C2_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x33, 0x2A	| 408F3D1E s24 -> DECL_SR7F_C2_Video_DAFB_TwoBitMode
DECL_SR7F_C2_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x39, 0x88	| 408F3D22 s24 -> DECL_SR7F_C2_Video_DAFB_FourBitMode
DECL_SR7F_C2_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x40, 0x26	| 408F3D26 s24 -> DECL_SR7F_C2_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F3D2A
DECL_SR7F_C3_Video_DAFB:  /* sResource C3 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0B, 0xF4	| 408F3D2E s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C3_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0C, 0x64	| 408F3D32 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C3_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0E, 0x06	| 408F3D36 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3D3A
DECL_SR7F_C3_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0E, 0x26	| 408F3D42 s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C3_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0E, 0xCE	| 408F3D46 s24 -> DECL_SR7F_C3_Video_DAFB_MinorLength_data
DECL_SR7F_C3_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0F, 0x76	| 408F3D4A s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_C3_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2C, 0xD6	| 408F3D4E s24 -> DECL_SR7F_C2_Video_DAFB_OneBitMode
DECL_SR7F_C3_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x32, 0xF6	| 408F3D52 s24 -> DECL_SR7F_C2_Video_DAFB_TwoBitMode
DECL_SR7F_C3_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x39, 0x54	| 408F3D56 s24 -> DECL_SR7F_C2_Video_DAFB_FourBitMode
DECL_SR7F_C3_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3F, 0xF2	| 408F3D5A s24 -> DECL_SR7F_C2_Video_DAFB_EightBitMode
DECL_SR7F_C3_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x47, 0x7A	| 408F3D5E s24 -> DECL_SR7F_C3_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3D62
DECL_SR7F_EC_Video_DAFB:  /* sResource EC in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0B, 0xBC	| 408F3D66 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_EC_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0C, 0x2C	| 408F3D6A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_EC_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0D, 0xCE	| 408F3D6E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3D72
DECL_SR7F_EC_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0D, 0xEE	| 408F3D7A s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_EC_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0E, 0x96	| 408F3D7E s24 -> DECL_SR7F_C3_Video_DAFB_MinorLength_data
DECL_SR7F_EC_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0F, 0x3E	| 408F3D82 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_EC_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2C, 0x9E	| 408F3D86 s24 -> DECL_SR7F_C2_Video_DAFB_OneBitMode
DECL_SR7F_EC_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x32, 0xBE	| 408F3D8A s24 -> DECL_SR7F_C2_Video_DAFB_TwoBitMode
DECL_SR7F_EC_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x39, 0x1C	| 408F3D8E s24 -> DECL_SR7F_C2_Video_DAFB_FourBitMode
DECL_SR7F_EC_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3F, 0xBA	| 408F3D92 s24 -> DECL_SR7F_C2_Video_DAFB_EightBitMode
DECL_SR7F_EC_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x44, 0x7C	| 408F3D96 s24 -> DECL_SR7F_EC_Video_DAFB_SixteenBitMode
DECL_SR7F_EC_Video_DAFB_ThirtyTwoBitMode_entry:  /* entry ThirtyTwoBitMode (133): 32 bits per pixel */
    .byte   0x85, 0x00, 0x47, 0x3E	| 408F3D9A s24 -> DECL_SR7F_C3_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3D9E
DECL_SR7F_EE_Video_DAFB:  /* sResource EE in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0B, 0x80	| 408F3DA2 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_EE_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0B, 0xF0	| 408F3DA6 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_EE_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0D, 0x92	| 408F3DAA s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3DAE
DECL_SR7F_EE_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0D, 0xB2	| 408F3DB6 s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_EE_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0E, 0x5A	| 408F3DBA s24 -> DECL_SR7F_C3_Video_DAFB_MinorLength_data
DECL_SR7F_EE_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0F, 0x02	| 408F3DBE s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7F_EE_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2C, 0x62	| 408F3DC2 s24 -> DECL_SR7F_C2_Video_DAFB_OneBitMode
DECL_SR7F_EE_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x32, 0x82	| 408F3DC6 s24 -> DECL_SR7F_C2_Video_DAFB_TwoBitMode
DECL_SR7F_EE_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x38, 0xE0	| 408F3DCA s24 -> DECL_SR7F_C2_Video_DAFB_FourBitMode
DECL_SR7F_EE_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3F, 0x7E	| 408F3DCE s24 -> DECL_SR7F_C2_Video_DAFB_EightBitMode
DECL_SR7F_EE_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x44, 0x40	| 408F3DD2 s24 -> DECL_SR7F_EC_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3DD6
DECL_SR7F_C8_Video_DAFB:  /* sResource C8 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0B, 0x48	| 408F3DDA s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C8_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0B, 0xB8	| 408F3DDE s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C8_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0D, 0x5A	| 408F3DE2 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3DE6
DECL_SR7F_C8_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0D, 0x7A	| 408F3DEE s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C8_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0E, 0x2A	| 408F3DF2 s24 -> DECL_SR7F_C8_Video_DAFB_MinorLength_data
DECL_SR7F_C8_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0E, 0xBA	| 408F3DF6 s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_C8_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2C, 0x3A	| 408F3DFA s24 -> DECL_SR7F_C8_Video_DAFB_OneBitMode
DECL_SR7F_C8_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x32, 0x5A	| 408F3DFE s24 -> DECL_SR7F_C8_Video_DAFB_TwoBitMode
DECL_SR7F_C8_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x38, 0xB8	| 408F3E02 s24 -> DECL_SR7F_C8_Video_DAFB_FourBitMode
DECL_SR7F_C8_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3F, 0x56	| 408F3E06 s24 -> DECL_SR7F_C8_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F3E0A
DECL_SR7F_C9_Video_DAFB:  /* sResource C9 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0B, 0x14	| 408F3E0E s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_C9_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0B, 0x84	| 408F3E12 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_C9_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0D, 0x26	| 408F3E16 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3E1A
DECL_SR7F_C9_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0D, 0x46	| 408F3E22 s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_C9_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0D, 0xFE	| 408F3E26 s24 -> DECL_SR7F_C9_Video_DAFB_MinorLength_data
DECL_SR7F_C9_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0E, 0x86	| 408F3E2A s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_C9_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2C, 0x06	| 408F3E2E s24 -> DECL_SR7F_C8_Video_DAFB_OneBitMode
DECL_SR7F_C9_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x32, 0x26	| 408F3E32 s24 -> DECL_SR7F_C8_Video_DAFB_TwoBitMode
DECL_SR7F_C9_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x38, 0x84	| 408F3E36 s24 -> DECL_SR7F_C8_Video_DAFB_FourBitMode
DECL_SR7F_C9_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3F, 0x22	| 408F3E3A s24 -> DECL_SR7F_C8_Video_DAFB_EightBitMode
DECL_SR7F_C9_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x46, 0xAA	| 408F3E3E s24 -> DECL_SR7F_C9_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3E42
DECL_SR7F_E2_Video_DAFB:  /* sResource E2 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0A, 0xDC	| 408F3E46 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_E2_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0B, 0x4C	| 408F3E4A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_E2_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0C, 0xEE	| 408F3E4E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3E52
DECL_SR7F_E2_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0D, 0x0E	| 408F3E5A s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_E2_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0D, 0xC2	| 408F3E5E s24 -> DECL_SR7F_E2_Video_DAFB_MinorLength_data
DECL_SR7F_E2_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0E, 0x4E	| 408F3E62 s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_E2_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2B, 0xCE	| 408F3E66 s24 -> DECL_SR7F_C8_Video_DAFB_OneBitMode
DECL_SR7F_E2_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x31, 0xEE	| 408F3E6A s24 -> DECL_SR7F_C8_Video_DAFB_TwoBitMode
DECL_SR7F_E2_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x38, 0x4C	| 408F3E6E s24 -> DECL_SR7F_C8_Video_DAFB_FourBitMode
DECL_SR7F_E2_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3E, 0xEA	| 408F3E72 s24 -> DECL_SR7F_C8_Video_DAFB_EightBitMode
DECL_SR7F_E2_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x43, 0xAC	| 408F3E76 s24 -> DECL_SR7F_E2_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3E7A
DECL_SR7F_E3_Video_DAFB:  /* sResource E3 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0A, 0xA4	| 408F3E7E s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_E3_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0B, 0x14	| 408F3E82 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_E3_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0C, 0xB6	| 408F3E86 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3E8A
DECL_SR7F_E3_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0C, 0xD6	| 408F3E92 s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_E3_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0D, 0x8E	| 408F3E96 s24 -> DECL_SR7F_C9_Video_DAFB_MinorLength_data
DECL_SR7F_E3_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0E, 0x16	| 408F3E9A s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_E3_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2B, 0x96	| 408F3E9E s24 -> DECL_SR7F_C8_Video_DAFB_OneBitMode
DECL_SR7F_E3_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x31, 0xB6	| 408F3EA2 s24 -> DECL_SR7F_C8_Video_DAFB_TwoBitMode
DECL_SR7F_E3_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x38, 0x14	| 408F3EA6 s24 -> DECL_SR7F_C8_Video_DAFB_FourBitMode
DECL_SR7F_E3_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3E, 0xB2	| 408F3EAA s24 -> DECL_SR7F_C8_Video_DAFB_EightBitMode
DECL_SR7F_E3_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x43, 0x74	| 408F3EAE s24 -> DECL_SR7F_E2_Video_DAFB_SixteenBitMode
DECL_SR7F_E3_Video_DAFB_ThirtyTwoBitMode_entry:  /* entry ThirtyTwoBitMode (133): 32 bits per pixel */
    .byte   0x85, 0x00, 0x46, 0x36	| 408F3EB2 s24 -> DECL_SR7F_C9_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3EB6
DECL_SR7F_EA_Video_DAFB:  /* sResource EA in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0A, 0x68	| 408F3EBA s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_EA_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0A, 0xD8	| 408F3EBE s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_EA_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0C, 0x7A	| 408F3EC2 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3EC6
DECL_SR7F_EA_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0C, 0xAA	| 408F3ECE s24 -> DECL_SR7F_C6_Video_DAFB_MinorBaseOS_data
DECL_SR7F_EA_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0D, 0x76	| 408F3ED2 s24 -> DECL_SR7F_EA_Video_DAFB_MinorLength_data
DECL_SR7F_EA_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0D, 0xDA	| 408F3ED6 s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_EA_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2B, 0x6A	| 408F3EDA s24 -> DECL_SR7F_E8_Video_DAFB_OneBitMode
DECL_SR7F_EA_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x31, 0x8A	| 408F3EDE s24 -> DECL_SR7F_E8_Video_DAFB_TwoBitMode
DECL_SR7F_EA_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x37, 0xE8	| 408F3EE2 s24 -> DECL_SR7F_E8_Video_DAFB_FourBitMode
DECL_SR7F_EA_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3E, 0x86	| 408F3EE6 s24 -> DECL_SR7F_E8_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F3EEA
DECL_SR7F_EB_Video_DAFB:  /* sResource EB in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x0A, 0x34	| 408F3EEE s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_EB_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0A, 0xA4	| 408F3EF2 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_EB_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0C, 0x46	| 408F3EF6 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3EFA
DECL_SR7F_EB_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0C, 0x72	| 408F3F02 s24 -> DECL_SR7F_C7_Video_DAFB_MinorBaseOS_data
DECL_SR7F_EB_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0D, 0x4A	| 408F3F06 s24 -> DECL_SR7F_E9_Video_DAFB_MinorLength_data
DECL_SR7F_EB_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0D, 0xA6	| 408F3F0A s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_EB_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2B, 0x36	| 408F3F0E s24 -> DECL_SR7F_E8_Video_DAFB_OneBitMode
DECL_SR7F_EB_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x31, 0x56	| 408F3F12 s24 -> DECL_SR7F_E8_Video_DAFB_TwoBitMode
DECL_SR7F_EB_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x37, 0xB4	| 408F3F16 s24 -> DECL_SR7F_E8_Video_DAFB_FourBitMode
DECL_SR7F_EB_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3E, 0x52	| 408F3F1A s24 -> DECL_SR7F_E8_Video_DAFB_EightBitMode
DECL_SR7F_EB_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x45, 0xDA	| 408F3F1E s24 -> DECL_SR7F_E9_Video_DAFB_ThirtyTwoBitMode
    .short  0xFF00, 0x0000	| 408F3F22
DECL_SR7F_E8_Video_DAFB:  /* sResource E8 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x09, 0xFC	| 408F3F26 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_E8_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0A, 0x6C	| 408F3F2A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_E8_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0C, 0x0E	| 408F3F2E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3F32
DECL_SR7F_E8_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0C, 0x3E	| 408F3F3A s24 -> DECL_SR7F_C6_Video_DAFB_MinorBaseOS_data
DECL_SR7F_E8_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0D, 0x0E	| 408F3F3E s24 -> DECL_SR7F_E8_Video_DAFB_MinorLength_data
DECL_SR7F_E8_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0D, 0x6E	| 408F3F42 s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_E8_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2A, 0xFE	| 408F3F46 s24 -> DECL_SR7F_E8_Video_DAFB_OneBitMode
DECL_SR7F_E8_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x31, 0x1E	| 408F3F4A s24 -> DECL_SR7F_E8_Video_DAFB_TwoBitMode
DECL_SR7F_E8_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x37, 0x7C	| 408F3F4E s24 -> DECL_SR7F_E8_Video_DAFB_FourBitMode
DECL_SR7F_E8_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3E, 0x1A	| 408F3F52 s24 -> DECL_SR7F_E8_Video_DAFB_EightBitMode
DECL_SR7F_E8_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x42, 0xDC	| 408F3F56 s24 -> DECL_SR7F_E8_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F3F5A
DECL_SR7F_E9_Video_DAFB:  /* sResource E9 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x09, 0xC4	| 408F3F5E s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_E9_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x0A, 0x34	| 408F3F62 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_E9_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0B, 0xD6	| 408F3F66 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3F6A
DECL_SR7F_E9_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0C, 0x02	| 408F3F72 s24 -> DECL_SR7F_C7_Video_DAFB_MinorBaseOS_data
DECL_SR7F_E9_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0C, 0xDA	| 408F3F76 s24 -> DECL_SR7F_E9_Video_DAFB_MinorLength_data
DECL_SR7F_E9_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0D, 0x36	| 408F3F7A s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7F_E9_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2A, 0xC6	| 408F3F7E s24 -> DECL_SR7F_E8_Video_DAFB_OneBitMode
DECL_SR7F_E9_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x30, 0xE6	| 408F3F82 s24 -> DECL_SR7F_E8_Video_DAFB_TwoBitMode
DECL_SR7F_E9_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x37, 0x44	| 408F3F86 s24 -> DECL_SR7F_E8_Video_DAFB_FourBitMode
DECL_SR7F_E9_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3D, 0xE2	| 408F3F8A s24 -> DECL_SR7F_E8_Video_DAFB_EightBitMode
DECL_SR7F_E9_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x42, 0xA4	| 408F3F8E s24 -> DECL_SR7F_E8_Video_DAFB_SixteenBitMode
DECL_SR7F_E9_Video_DAFB_ThirtyTwoBitMode_entry:  /* entry ThirtyTwoBitMode (133): 32 bits per pixel */
    .byte   0x85, 0x00, 0x45, 0x66	| 408F3F92 s24 -> DECL_SR7F_E9_Video_DAFB_ThirtyTwoBitMode
    .short  0xFF00, 0x0000	| 408F3F96
DECL_SR7F_CC_Video_DAFB:  /* sResource CC in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x09, 0x88	| 408F3F9A s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_CC_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x09, 0xF8	| 408F3F9E s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_CC_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0B, 0x9A	| 408F3FA2 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3FA6
DECL_SR7F_CC_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0B, 0xBA	| 408F3FAE s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_CC_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0C, 0x3A	| 408F3FB2 s24 -> DECL_SR7F_C0_Video_DAFB_MinorLength_data
DECL_SR7F_CC_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0C, 0xEE	| 408F3FB6 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_CC_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2A, 0x3A	| 408F3FBA s24 -> DECL_SR7F_C0_Video_DAFB_OneBitMode
DECL_SR7F_CC_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x30, 0x5A	| 408F3FBE s24 -> DECL_SR7F_C0_Video_DAFB_TwoBitMode
DECL_SR7F_CC_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x36, 0xB8	| 408F3FC2 s24 -> DECL_SR7F_C0_Video_DAFB_FourBitMode
    .short  0xFF00, 0x0000	| 408F3FC6
DECL_SR7F_CD_Video_DAFB:  /* sResource CD in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x09, 0x58	| 408F3FCA s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_CD_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x09, 0xC8	| 408F3FCE s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_CD_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0B, 0x6A	| 408F3FD2 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F3FD6
DECL_SR7F_CD_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0B, 0x8A	| 408F3FDE s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_CD_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0C, 0x0E	| 408F3FE2 s24 -> DECL_SR7F_C1_Video_DAFB_MinorLength_data
DECL_SR7F_CD_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0C, 0xBE	| 408F3FE6 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_CD_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x2A, 0x0A	| 408F3FEA s24 -> DECL_SR7F_C0_Video_DAFB_OneBitMode
DECL_SR7F_CD_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x30, 0x2A	| 408F3FEE s24 -> DECL_SR7F_C0_Video_DAFB_TwoBitMode
DECL_SR7F_CD_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x36, 0x88	| 408F3FF2 s24 -> DECL_SR7F_C0_Video_DAFB_FourBitMode
DECL_SR7F_CD_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3D, 0x26	| 408F3FF6 s24 -> DECL_SR7F_C1_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F3FFA
DECL_SR7F_ED_Video_DAFB:  /* sResource ED in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x09, 0x24	| 408F3FFE s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_ED_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x09, 0x94	| 408F4002 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_ED_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0B, 0x36	| 408F4006 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F400A
DECL_SR7F_ED_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0B, 0x56	| 408F4012 s24 -> DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data
DECL_SR7F_ED_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0B, 0xDE	| 408F4016 s24 -> DECL_SR7F_ED_Video_DAFB_MinorLength_data
DECL_SR7F_ED_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0C, 0x8A	| 408F401A s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_ED_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x29, 0xD6	| 408F401E s24 -> DECL_SR7F_C0_Video_DAFB_OneBitMode
DECL_SR7F_ED_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2F, 0xF6	| 408F4022 s24 -> DECL_SR7F_C0_Video_DAFB_TwoBitMode
DECL_SR7F_ED_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x36, 0x54	| 408F4026 s24 -> DECL_SR7F_C0_Video_DAFB_FourBitMode
DECL_SR7F_ED_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3C, 0xF2	| 408F402A s24 -> DECL_SR7F_C1_Video_DAFB_EightBitMode
DECL_SR7F_ED_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x41, 0xB4	| 408F402E s24 -> DECL_SR7F_ED_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4032
DECL_SR7F_CE_Video_DAFB:  /* sResource CE in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x08, 0xEC	| 408F4036 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_CE_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x09, 0x5C	| 408F403A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_CE_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0A, 0xFE	| 408F403E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4042
DECL_SR7F_CE_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0B, 0x26	| 408F404A s24 -> DECL_SR7F_C4_Video_DAFB_MinorBaseOS_data
DECL_SR7F_CE_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0B, 0xAA	| 408F404E s24 -> DECL_SR7F_C4_Video_DAFB_MinorLength_data
DECL_SR7F_CE_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0C, 0x52	| 408F4052 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_CE_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x29, 0xAE	| 408F4056 s24 -> DECL_SR7F_C4_Video_DAFB_OneBitMode
DECL_SR7F_CE_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2F, 0xCE	| 408F405A s24 -> DECL_SR7F_C4_Video_DAFB_TwoBitMode
DECL_SR7F_CE_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x36, 0x2C	| 408F405E s24 -> DECL_SR7F_C4_Video_DAFB_FourBitMode
    .short  0xFF00, 0x0000	| 408F4062
DECL_SR7F_CF_Video_DAFB:  /* sResource CF in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x08, 0xBC	| 408F4066 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_CF_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x09, 0x2C	| 408F406A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_CF_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0A, 0xCE	| 408F406E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4072
DECL_SR7F_CF_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0A, 0xF6	| 408F407A s24 -> DECL_SR7F_C4_Video_DAFB_MinorBaseOS_data
DECL_SR7F_CF_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0B, 0x7E	| 408F407E s24 -> DECL_SR7F_C5_Video_DAFB_MinorLength_data
DECL_SR7F_CF_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0C, 0x22	| 408F4082 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_CF_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x29, 0x7E	| 408F4086 s24 -> DECL_SR7F_C4_Video_DAFB_OneBitMode
DECL_SR7F_CF_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2F, 0x9E	| 408F408A s24 -> DECL_SR7F_C4_Video_DAFB_TwoBitMode
DECL_SR7F_CF_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x35, 0xFC	| 408F408E s24 -> DECL_SR7F_C4_Video_DAFB_FourBitMode
DECL_SR7F_CF_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3C, 0x9A	| 408F4092 s24 -> DECL_SR7F_C5_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F4096
DECL_SR7F_EF_Video_DAFB:  /* sResource EF in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x08, 0x88	| 408F409A s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_EF_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x08, 0xF8	| 408F409E s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_EF_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0A, 0x9A	| 408F40A2 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F40A6
DECL_SR7F_EF_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0A, 0xBE	| 408F40AE s24 -> DECL_SR7F_EF_Video_DAFB_MinorBaseOS_data
DECL_SR7F_EF_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0B, 0x4E	| 408F40B2 s24 -> DECL_SR7F_EF_Video_DAFB_MinorLength_data
DECL_SR7F_EF_Video_DAFB_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x0B, 0xEE	| 408F40B6 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7F_EF_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x29, 0x4A	| 408F40BA s24 -> DECL_SR7F_C4_Video_DAFB_OneBitMode
DECL_SR7F_EF_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2F, 0x6A	| 408F40BE s24 -> DECL_SR7F_C4_Video_DAFB_TwoBitMode
DECL_SR7F_EF_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x35, 0xC8	| 408F40C2 s24 -> DECL_SR7F_C4_Video_DAFB_FourBitMode
DECL_SR7F_EF_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3C, 0x66	| 408F40C6 s24 -> DECL_SR7F_C5_Video_DAFB_EightBitMode
DECL_SR7F_EF_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x41, 0x28	| 408F40CA s24 -> DECL_SR7F_EF_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F40CE
DECL_SR7F_D0_Video_DAFB:  /* sResource D0 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x08, 0x50	| 408F40D2 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_D0_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x08, 0xC0	| 408F40D6 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_D0_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0A, 0x62	| 408F40DA s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F40DE
DECL_SR7F_D0_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0A, 0x96	| 408F40E6 s24 -> DECL_SR7F_D0_Video_DAFB_MinorBaseOS_data
DECL_SR7F_D0_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0B, 0x26	| 408F40EA s24 -> DECL_SR7F_C2_Video_DAFB_MinorLength_data
DECL_SR7F_D0_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x29, 0x66	| 408F40EE s24 -> DECL_SR7F_D0_Video_DAFB_OneBitMode
DECL_SR7F_D0_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2F, 0x86	| 408F40F2 s24 -> DECL_SR7F_D0_Video_DAFB_TwoBitMode
DECL_SR7F_D0_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x35, 0xE4	| 408F40F6 s24 -> DECL_SR7F_D0_Video_DAFB_FourBitMode
DECL_SR7F_D0_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3C, 0x82	| 408F40FA s24 -> DECL_SR7F_D0_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F40FE
DECL_SR7F_D1_Video_DAFB:  /* sResource D1 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x08, 0x20	| 408F4102 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_D1_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x08, 0x90	| 408F4106 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_D1_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x0A, 0x32	| 408F410A s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F410E
DECL_SR7F_D1_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0A, 0x66	| 408F4116 s24 -> DECL_SR7F_D0_Video_DAFB_MinorBaseOS_data
DECL_SR7F_D1_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0A, 0xFE	| 408F411A s24 -> DECL_SR7F_D1_Video_DAFB_MinorLength_data
DECL_SR7F_D1_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x29, 0x36	| 408F411E s24 -> DECL_SR7F_D0_Video_DAFB_OneBitMode
DECL_SR7F_D1_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2F, 0x56	| 408F4122 s24 -> DECL_SR7F_D0_Video_DAFB_TwoBitMode
DECL_SR7F_D1_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x35, 0xB4	| 408F4126 s24 -> DECL_SR7F_D0_Video_DAFB_FourBitMode
DECL_SR7F_D1_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3C, 0x52	| 408F412A s24 -> DECL_SR7F_D0_Video_DAFB_EightBitMode
DECL_SR7F_D1_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x43, 0xDA	| 408F412E s24 -> DECL_SR7F_D1_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4132
DECL_SR7F_F0_Video_DAFB:  /* sResource F0 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x07, 0xEC	| 408F4136 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_F0_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x08, 0x5C	| 408F413A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_F0_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x09, 0xFE	| 408F413E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4142
DECL_SR7F_F0_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x0A, 0x32	| 408F414A s24 -> DECL_SR7F_D0_Video_DAFB_MinorBaseOS_data
DECL_SR7F_F0_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0A, 0xC6	| 408F414E s24 -> DECL_SR7F_C3_Video_DAFB_MinorLength_data
DECL_SR7F_F0_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x29, 0x02	| 408F4152 s24 -> DECL_SR7F_D0_Video_DAFB_OneBitMode
DECL_SR7F_F0_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2F, 0x22	| 408F4156 s24 -> DECL_SR7F_D0_Video_DAFB_TwoBitMode
DECL_SR7F_F0_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x35, 0x80	| 408F415A s24 -> DECL_SR7F_D0_Video_DAFB_FourBitMode
DECL_SR7F_F0_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3C, 0x1E	| 408F415E s24 -> DECL_SR7F_D0_Video_DAFB_EightBitMode
DECL_SR7F_F0_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x40, 0xE0	| 408F4162 s24 -> DECL_SR7F_F0_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4166
DECL_SR7F_F1_Video_DAFB:  /* sResource F1 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x07, 0xB8	| 408F416A s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_F1_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x08, 0x28	| 408F416E s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_F1_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x09, 0xCA	| 408F4172 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4176
DECL_SR7F_F1_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x09, 0xFE	| 408F417E s24 -> DECL_SR7F_D0_Video_DAFB_MinorBaseOS_data
DECL_SR7F_F1_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0A, 0x96	| 408F4182 s24 -> DECL_SR7F_D1_Video_DAFB_MinorLength_data
DECL_SR7F_F1_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x28, 0xCE	| 408F4186 s24 -> DECL_SR7F_D0_Video_DAFB_OneBitMode
DECL_SR7F_F1_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2E, 0xEE	| 408F418A s24 -> DECL_SR7F_D0_Video_DAFB_TwoBitMode
DECL_SR7F_F1_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x35, 0x4C	| 408F418E s24 -> DECL_SR7F_D0_Video_DAFB_FourBitMode
DECL_SR7F_F1_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3B, 0xEA	| 408F4192 s24 -> DECL_SR7F_D0_Video_DAFB_EightBitMode
DECL_SR7F_F1_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x40, 0xAC	| 408F4196 s24 -> DECL_SR7F_F0_Video_DAFB_SixteenBitMode
DECL_SR7F_F1_Video_DAFB_ThirtyTwoBitMode_entry:  /* entry ThirtyTwoBitMode (133): 32 bits per pixel */
    .byte   0x85, 0x00, 0x43, 0x6E	| 408F419A s24 -> DECL_SR7F_D1_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F419E
DECL_SR7F_D8_Video_DAFB:  /* sResource D8 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x07, 0x80	| 408F41A2 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_D8_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x07, 0xF0	| 408F41A6 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_D8_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x09, 0x92	| 408F41AA s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F41AE
DECL_SR7F_D8_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x09, 0xCA	| 408F41B6 s24 -> DECL_SR7F_D8_Video_DAFB_MinorBaseOS_data
DECL_SR7F_D8_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0A, 0x56	| 408F41BA s24 -> DECL_SR7F_C2_Video_DAFB_MinorLength_data
DECL_SR7F_D8_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x28, 0x96	| 408F41BE s24 -> DECL_SR7F_D0_Video_DAFB_OneBitMode
DECL_SR7F_D8_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2E, 0xB6	| 408F41C2 s24 -> DECL_SR7F_D0_Video_DAFB_TwoBitMode
DECL_SR7F_D8_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x35, 0x14	| 408F41C6 s24 -> DECL_SR7F_D0_Video_DAFB_FourBitMode
DECL_SR7F_D8_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3B, 0xB2	| 408F41CA s24 -> DECL_SR7F_D0_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F41CE
DECL_SR7F_D2_Video_DAFB:  /* sResource D2 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x07, 0x50	| 408F41D2 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_D2_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x07, 0xC0	| 408F41D6 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_D2_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x09, 0x62	| 408F41DA s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F41DE
DECL_SR7F_D2_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x09, 0x96	| 408F41E6 s24 -> DECL_SR7F_D0_Video_DAFB_MinorBaseOS_data
DECL_SR7F_D2_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0A, 0x32	| 408F41EA s24 -> DECL_SR7F_C8_Video_DAFB_MinorLength_data
DECL_SR7F_D2_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x28, 0x46	| 408F41EE s24 -> DECL_SR7F_C8_Video_DAFB_OneBitMode
DECL_SR7F_D2_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2E, 0x66	| 408F41F2 s24 -> DECL_SR7F_C8_Video_DAFB_TwoBitMode
DECL_SR7F_D2_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x34, 0xC4	| 408F41F6 s24 -> DECL_SR7F_C8_Video_DAFB_FourBitMode
DECL_SR7F_D2_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3B, 0x62	| 408F41FA s24 -> DECL_SR7F_C8_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F41FE
DECL_SR7F_D3_Video_DAFB:  /* sResource D3 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x07, 0x20	| 408F4202 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_D3_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x07, 0x90	| 408F4206 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_D3_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x09, 0x32	| 408F420A s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F420E
DECL_SR7F_D3_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x09, 0x66	| 408F4216 s24 -> DECL_SR7F_D0_Video_DAFB_MinorBaseOS_data
DECL_SR7F_D3_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x0A, 0x0A	| 408F421A s24 -> DECL_SR7F_C9_Video_DAFB_MinorLength_data
DECL_SR7F_D3_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x28, 0x16	| 408F421E s24 -> DECL_SR7F_C8_Video_DAFB_OneBitMode
DECL_SR7F_D3_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2E, 0x36	| 408F4222 s24 -> DECL_SR7F_C8_Video_DAFB_TwoBitMode
DECL_SR7F_D3_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x34, 0x94	| 408F4226 s24 -> DECL_SR7F_C8_Video_DAFB_FourBitMode
DECL_SR7F_D3_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3B, 0x32	| 408F422A s24 -> DECL_SR7F_C8_Video_DAFB_EightBitMode
DECL_SR7F_D3_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x42, 0xBA	| 408F422E s24 -> DECL_SR7F_C9_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4232
DECL_SR7F_F2_Video_DAFB:  /* sResource F2 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0xEC	| 408F4236 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_F2_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x07, 0x5C	| 408F423A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_F2_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x08, 0xFE	| 408F423E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4242
DECL_SR7F_F2_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x09, 0x32	| 408F424A s24 -> DECL_SR7F_D0_Video_DAFB_MinorBaseOS_data
DECL_SR7F_F2_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x09, 0xD2	| 408F424E s24 -> DECL_SR7F_E2_Video_DAFB_MinorLength_data
DECL_SR7F_F2_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x27, 0xE2	| 408F4252 s24 -> DECL_SR7F_C8_Video_DAFB_OneBitMode
DECL_SR7F_F2_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2E, 0x02	| 408F4256 s24 -> DECL_SR7F_C8_Video_DAFB_TwoBitMode
DECL_SR7F_F2_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x34, 0x60	| 408F425A s24 -> DECL_SR7F_C8_Video_DAFB_FourBitMode
DECL_SR7F_F2_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3A, 0xFE	| 408F425E s24 -> DECL_SR7F_C8_Video_DAFB_EightBitMode
DECL_SR7F_F2_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x3F, 0xC0	| 408F4262 s24 -> DECL_SR7F_E2_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4266
DECL_SR7F_F3_Video_DAFB:  /* sResource F3 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0xB8	| 408F426A s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_F3_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x07, 0x28	| 408F426E s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_F3_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x08, 0xCA	| 408F4272 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4276
DECL_SR7F_F3_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x08, 0xFE	| 408F427E s24 -> DECL_SR7F_D0_Video_DAFB_MinorBaseOS_data
DECL_SR7F_F3_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x09, 0xA2	| 408F4282 s24 -> DECL_SR7F_C9_Video_DAFB_MinorLength_data
DECL_SR7F_F3_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x27, 0xAE	| 408F4286 s24 -> DECL_SR7F_C8_Video_DAFB_OneBitMode
DECL_SR7F_F3_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2D, 0xCE	| 408F428A s24 -> DECL_SR7F_C8_Video_DAFB_TwoBitMode
DECL_SR7F_F3_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x34, 0x2C	| 408F428E s24 -> DECL_SR7F_C8_Video_DAFB_FourBitMode
DECL_SR7F_F3_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3A, 0xCA	| 408F4292 s24 -> DECL_SR7F_C8_Video_DAFB_EightBitMode
DECL_SR7F_F3_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x3F, 0x8C	| 408F4296 s24 -> DECL_SR7F_E2_Video_DAFB_SixteenBitMode
DECL_SR7F_F3_Video_DAFB_ThirtyTwoBitMode_entry:  /* entry ThirtyTwoBitMode (133): 32 bits per pixel */
    .byte   0x85, 0x00, 0x42, 0x4E	| 408F429A s24 -> DECL_SR7F_C9_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F429E
DECL_SR7F_DA_Video_DAFB:  /* sResource DA in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0x80	| 408F42A2 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_DA_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x06, 0xF0	| 408F42A6 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_DA_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x08, 0x92	| 408F42AA s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F42AE
DECL_SR7F_DA_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x08, 0xCA	| 408F42B6 s24 -> DECL_SR7F_D8_Video_DAFB_MinorBaseOS_data
DECL_SR7F_DA_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x09, 0x62	| 408F42BA s24 -> DECL_SR7F_C8_Video_DAFB_MinorLength_data
DECL_SR7F_DA_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x27, 0x76	| 408F42BE s24 -> DECL_SR7F_C8_Video_DAFB_OneBitMode
DECL_SR7F_DA_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2D, 0x96	| 408F42C2 s24 -> DECL_SR7F_C8_Video_DAFB_TwoBitMode
DECL_SR7F_DA_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x33, 0xF4	| 408F42C6 s24 -> DECL_SR7F_C8_Video_DAFB_FourBitMode
DECL_SR7F_DA_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3A, 0x92	| 408F42CA s24 -> DECL_SR7F_C8_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F42CE
DECL_SR7F_D4_Video_DAFB:  /* sResource D4 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0x50	| 408F42D2 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_D4_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x06, 0xC0	| 408F42D6 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_D4_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x08, 0x62	| 408F42DA s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F42DE
DECL_SR7F_D4_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x08, 0xA2	| 408F42E6 s24 -> DECL_SR7F_D4_Video_DAFB_MinorBaseOS_data
DECL_SR7F_D4_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x09, 0x4E	| 408F42EA s24 -> DECL_SR7F_D4_Video_DAFB_MinorLength_data
DECL_SR7F_D4_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x27, 0x76	| 408F42EE s24 -> DECL_SR7F_D4_Video_DAFB_OneBitMode
DECL_SR7F_D4_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2D, 0x96	| 408F42F2 s24 -> DECL_SR7F_D4_Video_DAFB_TwoBitMode
DECL_SR7F_D4_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x33, 0xF4	| 408F42F6 s24 -> DECL_SR7F_D4_Video_DAFB_FourBitMode
DECL_SR7F_D4_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3A, 0x92	| 408F42FA s24 -> DECL_SR7F_D4_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F42FE
DECL_SR7F_D5_Video_DAFB:  /* sResource D5 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x06, 0x20	| 408F4302 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_D5_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x06, 0x90	| 408F4306 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_D5_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x08, 0x32	| 408F430A s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F430E
DECL_SR7F_D5_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x08, 0x6E	| 408F4316 s24 -> DECL_SR7F_D5_Video_DAFB_MinorBaseOS_data
DECL_SR7F_D5_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x09, 0x26	| 408F431A s24 -> DECL_SR7F_D5_Video_DAFB_MinorLength_data
DECL_SR7F_D5_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x27, 0x46	| 408F431E s24 -> DECL_SR7F_D4_Video_DAFB_OneBitMode
DECL_SR7F_D5_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2D, 0x66	| 408F4322 s24 -> DECL_SR7F_D4_Video_DAFB_TwoBitMode
DECL_SR7F_D5_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x33, 0xC4	| 408F4326 s24 -> DECL_SR7F_D4_Video_DAFB_FourBitMode
DECL_SR7F_D5_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3A, 0x62	| 408F432A s24 -> DECL_SR7F_D4_Video_DAFB_EightBitMode
DECL_SR7F_D5_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x41, 0xEA	| 408F432E s24 -> DECL_SR7F_D5_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4332
DECL_SR7F_F4_Video_DAFB:  /* sResource F4 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x05, 0xEC	| 408F4336 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_F4_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x06, 0x5C	| 408F433A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_F4_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x07, 0xFE	| 408F433E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4342
DECL_SR7F_F4_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x08, 0x3E	| 408F434A s24 -> DECL_SR7F_D4_Video_DAFB_MinorBaseOS_data
DECL_SR7F_F4_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x08, 0xEE	| 408F434E s24 -> DECL_SR7F_F4_Video_DAFB_MinorLength_data
DECL_SR7F_F4_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x27, 0x12	| 408F4352 s24 -> DECL_SR7F_D4_Video_DAFB_OneBitMode
DECL_SR7F_F4_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2D, 0x32	| 408F4356 s24 -> DECL_SR7F_D4_Video_DAFB_TwoBitMode
DECL_SR7F_F4_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x33, 0x90	| 408F435A s24 -> DECL_SR7F_D4_Video_DAFB_FourBitMode
DECL_SR7F_F4_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x3A, 0x2E	| 408F435E s24 -> DECL_SR7F_D4_Video_DAFB_EightBitMode
DECL_SR7F_F4_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x3E, 0xF0	| 408F4362 s24 -> DECL_SR7F_F4_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4366
DECL_SR7F_F5_Video_DAFB:  /* sResource F5 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x05, 0xB8	| 408F436A s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_F5_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x06, 0x28	| 408F436E s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_F5_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x07, 0xCA	| 408F4372 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4376
DECL_SR7F_F5_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x08, 0x06	| 408F437E s24 -> DECL_SR7F_D5_Video_DAFB_MinorBaseOS_data
DECL_SR7F_F5_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x08, 0xBE	| 408F4382 s24 -> DECL_SR7F_D5_Video_DAFB_MinorLength_data
DECL_SR7F_F5_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x26, 0xDE	| 408F4386 s24 -> DECL_SR7F_D4_Video_DAFB_OneBitMode
DECL_SR7F_F5_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2C, 0xFE	| 408F438A s24 -> DECL_SR7F_D4_Video_DAFB_TwoBitMode
DECL_SR7F_F5_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x33, 0x5C	| 408F438E s24 -> DECL_SR7F_D4_Video_DAFB_FourBitMode
DECL_SR7F_F5_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x39, 0xFA	| 408F4392 s24 -> DECL_SR7F_D4_Video_DAFB_EightBitMode
DECL_SR7F_F5_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x3E, 0xBC	| 408F4396 s24 -> DECL_SR7F_F4_Video_DAFB_SixteenBitMode
DECL_SR7F_F5_Video_DAFB_ThirtyTwoBitMode_entry:  /* entry ThirtyTwoBitMode (133): 32 bits per pixel */
    .byte   0x85, 0x00, 0x41, 0x7E	| 408F439A s24 -> DECL_SR7F_D5_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F439E
DECL_SR7F_DC_Video_DAFB:  /* sResource DC in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x05, 0x80	| 408F43A2 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_DC_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x05, 0xF0	| 408F43A6 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_DC_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x07, 0x92	| 408F43AA s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F43AE
DECL_SR7F_DC_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x07, 0xD6	| 408F43B6 s24 -> DECL_SR7F_DC_Video_DAFB_MinorBaseOS_data
DECL_SR7F_DC_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x08, 0x8A	| 408F43BA s24 -> DECL_SR7F_DC_Video_DAFB_MinorLength_data
DECL_SR7F_DC_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x26, 0xB6	| 408F43BE s24 -> DECL_SR7F_DC_Video_DAFB_OneBitMode
DECL_SR7F_DC_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2C, 0xD6	| 408F43C2 s24 -> DECL_SR7F_DC_Video_DAFB_TwoBitMode
DECL_SR7F_DC_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x33, 0x34	| 408F43C6 s24 -> DECL_SR7F_DC_Video_DAFB_FourBitMode
DECL_SR7F_DC_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x39, 0xD2	| 408F43CA s24 -> DECL_SR7F_DC_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F43CE
DECL_SR7F_D6_Video_DAFB:  /* sResource D6 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x05, 0x50	| 408F43D2 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_D6_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x05, 0xC0	| 408F43D6 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_D6_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x07, 0x62	| 408F43DA s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F43DE
DECL_SR7F_D6_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x07, 0xA2	| 408F43E6 s24 -> DECL_SR7F_D4_Video_DAFB_MinorBaseOS_data
DECL_SR7F_D6_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x08, 0x3E	| 408F43EA s24 -> DECL_SR7F_D6_Video_DAFB_MinorLength_data
DECL_SR7F_D6_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x26, 0x96	| 408F43EE s24 -> DECL_SR7F_D6_Video_DAFB_OneBitMode
DECL_SR7F_D6_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2C, 0xB6	| 408F43F2 s24 -> DECL_SR7F_D6_Video_DAFB_TwoBitMode
DECL_SR7F_D6_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x33, 0x14	| 408F43F6 s24 -> DECL_SR7F_D6_Video_DAFB_FourBitMode
DECL_SR7F_D6_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x39, 0xB2	| 408F43FA s24 -> DECL_SR7F_D6_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F43FE
DECL_SR7F_D7_Video_DAFB:  /* sResource D7 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x05, 0x20	| 408F4402 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_D7_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x05, 0x90	| 408F4406 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_D7_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x07, 0x32	| 408F440A s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F440E
DECL_SR7F_D7_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x07, 0x6E	| 408F4416 s24 -> DECL_SR7F_D5_Video_DAFB_MinorBaseOS_data
DECL_SR7F_D7_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x08, 0x16	| 408F441A s24 -> DECL_SR7F_D7_Video_DAFB_MinorLength_data
DECL_SR7F_D7_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x26, 0x66	| 408F441E s24 -> DECL_SR7F_D6_Video_DAFB_OneBitMode
DECL_SR7F_D7_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2C, 0x86	| 408F4422 s24 -> DECL_SR7F_D6_Video_DAFB_TwoBitMode
DECL_SR7F_D7_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x32, 0xE4	| 408F4426 s24 -> DECL_SR7F_D6_Video_DAFB_FourBitMode
DECL_SR7F_D7_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x39, 0x82	| 408F442A s24 -> DECL_SR7F_D6_Video_DAFB_EightBitMode
DECL_SR7F_D7_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x40, 0xFA	| 408F442E s24 -> DECL_SR7F_D7_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4432
DECL_SR7F_F6_Video_DAFB:  /* sResource F6 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0xEC	| 408F4436 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_F6_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x05, 0x5C	| 408F443A s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_F6_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x06, 0xFE	| 408F443E s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4442
DECL_SR7F_F6_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x07, 0x3E	| 408F444A s24 -> DECL_SR7F_D4_Video_DAFB_MinorBaseOS_data
DECL_SR7F_F6_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x07, 0xDE	| 408F444E s24 -> DECL_SR7F_F6_Video_DAFB_MinorLength_data
DECL_SR7F_F6_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x26, 0x32	| 408F4452 s24 -> DECL_SR7F_D6_Video_DAFB_OneBitMode
DECL_SR7F_F6_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2C, 0x52	| 408F4456 s24 -> DECL_SR7F_D6_Video_DAFB_TwoBitMode
DECL_SR7F_F6_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x32, 0xB0	| 408F445A s24 -> DECL_SR7F_D6_Video_DAFB_FourBitMode
DECL_SR7F_F6_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x39, 0x4E	| 408F445E s24 -> DECL_SR7F_D6_Video_DAFB_EightBitMode
DECL_SR7F_F6_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x3E, 0x00	| 408F4462 s24 -> DECL_SR7F_F6_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4466
DECL_SR7F_F7_Video_DAFB:  /* sResource F7 in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0xB8	| 408F446A s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_F7_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x05, 0x28	| 408F446E s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_F7_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x06, 0xCA	| 408F4472 s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4476
DECL_SR7F_F7_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x07, 0x06	| 408F447E s24 -> DECL_SR7F_D5_Video_DAFB_MinorBaseOS_data
DECL_SR7F_F7_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x07, 0xAE	| 408F4482 s24 -> DECL_SR7F_D7_Video_DAFB_MinorLength_data
DECL_SR7F_F7_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x25, 0xFE	| 408F4486 s24 -> DECL_SR7F_D6_Video_DAFB_OneBitMode
DECL_SR7F_F7_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2C, 0x1E	| 408F448A s24 -> DECL_SR7F_D6_Video_DAFB_TwoBitMode
DECL_SR7F_F7_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x32, 0x7C	| 408F448E s24 -> DECL_SR7F_D6_Video_DAFB_FourBitMode
DECL_SR7F_F7_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x39, 0x1A	| 408F4492 s24 -> DECL_SR7F_D6_Video_DAFB_EightBitMode
DECL_SR7F_F7_Video_DAFB_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x3D, 0xCC	| 408F4496 s24 -> DECL_SR7F_F6_Video_DAFB_SixteenBitMode
DECL_SR7F_F7_Video_DAFB_ThirtyTwoBitMode_entry:  /* entry ThirtyTwoBitMode (133): 32 bits per pixel */
    .byte   0x85, 0x00, 0x40, 0x8E	| 408F449A s24 -> DECL_SR7F_D7_Video_DAFB_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F449E
DECL_SR7F_DE_Video_DAFB:  /* sResource DE in pool 7F: Video DAFB (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0x80	| 408F44A2 s24 -> DECL_TYPE_0003_0001_0001_001C
DECL_SR7F_DE_Video_DAFB_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x04, 0xF0	| 408F44A6 s24 -> DECL_NAME_Display_Video_Apple_DAFB
DECL_SR7F_DE_Video_DAFB_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x06, 0x92	| 408F44AA s24 -> DECL_SR7F_BE_Video_DAFB_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F44AE
DECL_SR7F_DE_Video_DAFB_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x06, 0xD6	| 408F44B6 s24 -> DECL_SR7F_DC_Video_DAFB_MinorBaseOS_data
DECL_SR7F_DE_Video_DAFB_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x07, 0x7A	| 408F44BA s24 -> DECL_SR7F_DE_Video_DAFB_MinorLength_data
DECL_SR7F_DE_Video_DAFB_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x25, 0xD6	| 408F44BE s24 -> DECL_SR7F_DE_Video_DAFB_OneBitMode
DECL_SR7F_DE_Video_DAFB_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2B, 0xF6	| 408F44C2 s24 -> DECL_SR7F_DE_Video_DAFB_TwoBitMode
DECL_SR7F_DE_Video_DAFB_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x32, 0x54	| 408F44C6 s24 -> DECL_SR7F_DE_Video_DAFB_FourBitMode
DECL_SR7F_DE_Video_DAFB_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x38, 0xF2	| 408F44CA s24 -> DECL_SR7F_DE_Video_DAFB_EightBitMode
    .short  0xFF00, 0x0000	| 408F44CE
DECL_SR7F_E0_Video_TIM:  /* sResource E0 in pool 7F: Video TIM (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0x48	| 408F44D2 s24 -> DECL_TYPE_0003_0001_0001_001B
DECL_SR7F_E0_Video_TIM_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x04, 0xA8	| 408F44D6 s24 -> DECL_NAME_Display_Video_Apple_TIM
DECL_SR7F_E0_Video_TIM_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x06, 0x6A	| 408F44DA s24 -> DECL_SR7F_E0_Video_TIM_DrvrDir
    .short  0x0700, 0x0002, 0x0800, 0x0001	| 408F44DE
DECL_SR7F_E0_Video_TIM_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x06, 0x7E	| 408F44E6 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_E0_Video_TIM_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x07, 0x7E	| 408F44EA s24 -> DECL_SR7F_BD_Video_DBLite_MinorLength_data
    .short  0x7D00, 0x0003	| 408F44EE
DECL_SR7F_E0_Video_TIM_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x25, 0xB2	| 408F44F2 s24 -> DECL_SR7F_BC_Video_DBLite_OneBitMode
    .short  0xFF00, 0x0000	| 408F44F6
DECL_SR7F_BB_Video_DBLite:  /* sResource BB in pool 7F: Video DBLite (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0x30	| 408F44FA s24 -> DECL_TYPE_0003_0001_0001_001E
DECL_SR7F_BB_Video_DBLite_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x04, 0xB4	| 408F44FE s24 -> DECL_NAME_Display_Video_Apple_DBLite
DECL_SR7F_BB_Video_DBLite_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x06, 0x4A	| 408F4502 s24 -> DECL_SR7F_BB_Video_DBLite_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4506
DECL_SR7F_BB_Video_DBLite_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x06, 0x56	| 408F450E s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_BB_Video_DBLite_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x07, 0x4E	| 408F4512 s24 -> DECL_SR7F_BB_Video_DBLite_MinorLength_data
    .short  0x7D00, 0x0003	| 408F4516
DECL_SR7F_BB_Video_DBLite_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x25, 0x9E	| 408F451A s24 -> DECL_SR7F_BB_Video_DBLite_OneBitMode
DECL_SR7F_BB_Video_DBLite_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2B, 0xBE	| 408F451E s24 -> DECL_SR7F_BB_Video_DBLite_TwoBitMode
DECL_SR7F_BB_Video_DBLite_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x32, 0x1C	| 408F4522 s24 -> DECL_SR7F_BB_Video_DBLite_FourBitMode
    .short  0xFF00, 0x0000	| 408F4526
DECL_SR7F_BC_Video_DBLite:  /* sResource BC in pool 7F: Video DBLite (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x04, 0x00	| 408F452A s24 -> DECL_TYPE_0003_0001_0001_001E
DECL_SR7F_BC_Video_DBLite_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x04, 0x84	| 408F452E s24 -> DECL_NAME_Display_Video_Apple_DBLite
DECL_SR7F_BC_Video_DBLite_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x06, 0x1A	| 408F4532 s24 -> DECL_SR7F_BB_Video_DBLite_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4536
DECL_SR7F_BC_Video_DBLite_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x06, 0x26	| 408F453E s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_BC_Video_DBLite_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x07, 0x22	| 408F4542 s24 -> DECL_SR7F_BC_Video_DBLite_MinorLength_data
    .short  0x7D00, 0x0003	| 408F4546
DECL_SR7F_BC_Video_DBLite_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x25, 0x5A	| 408F454A s24 -> DECL_SR7F_BC_Video_DBLite_OneBitMode
DECL_SR7F_BC_Video_DBLite_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x2B, 0x7A	| 408F454E s24 -> DECL_SR7F_BC_Video_DBLite_TwoBitMode
DECL_SR7F_BC_Video_DBLite_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x31, 0xD8	| 408F4552 s24 -> DECL_SR7F_BC_Video_DBLite_FourBitMode
    .short  0xFF00, 0x0000	| 408F4556
DECL_SR7F_BD_Video_DBLite:  /* sResource BD in pool 7F: Video DBLite (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x03, 0xD0	| 408F455A s24 -> DECL_TYPE_0003_0001_0001_001E
DECL_SR7F_BD_Video_DBLite_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x04, 0x54	| 408F455E s24 -> DECL_NAME_Display_Video_Apple_DBLite
DECL_SR7F_BD_Video_DBLite_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x05, 0xEA	| 408F4562 s24 -> DECL_SR7F_BB_Video_DBLite_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4566
DECL_SR7F_BD_Video_DBLite_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x05, 0xF6	| 408F456E s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7F_BD_Video_DBLite_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x06, 0xF6	| 408F4572 s24 -> DECL_SR7F_BD_Video_DBLite_MinorLength_data
    .short  0x7D00, 0x0003	| 408F4576
DECL_SR7F_BD_Video_DBLite_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x25, 0x2A	| 408F457A s24 -> DECL_SR7F_BC_Video_DBLite_OneBitMode
    .short  0xFF00, 0x0000	| 408F457E
DECL_SR7E_80_Video_Sonora:  /* sResource 80 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x03, 0xB0	| 408F4582 s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_80_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x04, 0x48	| 408F4586 s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_80_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x05, 0xCA	| 408F458A s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F458E
DECL_SR7E_80_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x05, 0xCE	| 408F4596 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_80_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x06, 0xD2	| 408F459A s24 -> DECL_SR7E_80_Video_Sonora_MinorLength_data
DECL_SR7E_80_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x07, 0x1A	| 408F459E s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7E_80_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x23, 0x92	| 408F45A2 s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode
DECL_SR7E_80_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x29, 0xB2	| 408F45A6 s24 -> DECL_SR7E_80_Video_Sonora_TwoBitMode
    .short  0xFF00, 0x0000	| 408F45AA
DECL_SR7E_81_Video_Sonora:  /* sResource 81 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x03, 0x84	| 408F45AE s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_81_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x04, 0x1C	| 408F45B2 s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_81_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x05, 0x9E	| 408F45B6 s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F45BA
DECL_SR7E_81_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x05, 0xA2	| 408F45C2 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_81_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x06, 0xAA	| 408F45C6 s24 -> DECL_SR7E_81_Video_Sonora_MinorLength_data
DECL_SR7E_81_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x06, 0xEE	| 408F45CA s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7E_81_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x23, 0x66	| 408F45CE s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode
DECL_SR7E_81_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x29, 0x86	| 408F45D2 s24 -> DECL_SR7E_80_Video_Sonora_TwoBitMode
DECL_SR7E_81_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2F, 0xE4	| 408F45D6 s24 -> DECL_SR7E_81_Video_Sonora_FourBitMode
    .short  0xFF00, 0x0000	| 408F45DA
DECL_SR7E_82_Video_Sonora:  /* sResource 82 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x03, 0x54	| 408F45DE s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_82_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x03, 0xEC	| 408F45E2 s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_82_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x05, 0x6E	| 408F45E6 s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F45EA
DECL_SR7E_82_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x05, 0x72	| 408F45F2 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_82_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x06, 0x7E	| 408F45F6 s24 -> DECL_SR7E_82_Video_Sonora_MinorLength_data
DECL_SR7E_82_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x06, 0xBE	| 408F45FA s24 -> DECL_SR7E_80_Video_Sonora_GammaDir
DECL_SR7E_82_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x23, 0x36	| 408F45FE s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode
DECL_SR7E_82_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x29, 0x56	| 408F4602 s24 -> DECL_SR7E_80_Video_Sonora_TwoBitMode
DECL_SR7E_82_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2F, 0xB4	| 408F4606 s24 -> DECL_SR7E_81_Video_Sonora_FourBitMode
DECL_SR7E_82_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x36, 0x72	| 408F460A s24 -> DECL_SR7E_82_Video_Sonora_EightBitMode
    .short  0xFF00, 0x0000	| 408F460E
DECL_SR7E_83_Video_Sonora:  /* sResource 83 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x03, 0x20	| 408F4612 s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_83_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x03, 0xB8	| 408F4616 s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_83_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x05, 0x3A	| 408F461A s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F461E
DECL_SR7E_83_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x05, 0x3E	| 408F4626 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_83_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x06, 0x4E	| 408F462A s24 -> DECL_SR7E_83_Video_Sonora_MinorLength_data
DECL_SR7E_83_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x06, 0x92	| 408F462E s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7E_83_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x23, 0x12	| 408F4632 s24 -> DECL_SR7E_83_Video_Sonora_OneBitMode
DECL_SR7E_83_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x29, 0x32	| 408F4636 s24 -> DECL_SR7E_83_Video_Sonora_TwoBitMode
DECL_SR7E_83_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2F, 0x90	| 408F463A s24 -> DECL_SR7E_83_Video_Sonora_FourBitMode
DECL_SR7E_83_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x36, 0x4E	| 408F463E s24 -> DECL_SR7E_83_Video_Sonora_EightBitMode
    .short  0xFF00, 0x0000	| 408F4642
DECL_SR7E_84_Video_Sonora:  /* sResource 84 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x02, 0xEC	| 408F4646 s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_84_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x03, 0x84	| 408F464A s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_84_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x05, 0x06	| 408F464E s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4652
DECL_SR7E_84_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x05, 0x0A	| 408F465A s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_84_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x06, 0x1E	| 408F465E s24 -> DECL_SR7E_84_Video_Sonora_MinorLength_data
DECL_SR7E_84_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x06, 0x5E	| 408F4662 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7E_84_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x22, 0xDE	| 408F4666 s24 -> DECL_SR7E_83_Video_Sonora_OneBitMode
DECL_SR7E_84_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x28, 0xFE	| 408F466A s24 -> DECL_SR7E_83_Video_Sonora_TwoBitMode
DECL_SR7E_84_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2F, 0x5C	| 408F466E s24 -> DECL_SR7E_83_Video_Sonora_FourBitMode
DECL_SR7E_84_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x36, 0x1A	| 408F4672 s24 -> DECL_SR7E_83_Video_Sonora_EightBitMode
DECL_SR7E_84_Video_Sonora_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x3B, 0x3C	| 408F4676 s24 -> DECL_SR7E_84_Video_Sonora_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F467A
DECL_SR7E_85_Video_Sonora:  /* sResource 85 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x02, 0xB4	| 408F467E s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_85_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x03, 0x4C	| 408F4682 s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_85_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x04, 0xCE	| 408F4686 s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F468A
DECL_SR7E_85_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x04, 0xD2	| 408F4692 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_85_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x05, 0xEA	| 408F4696 s24 -> DECL_SR7E_85_Video_Sonora_MinorLength_data
DECL_SR7E_85_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x06, 0x26	| 408F469A s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7E_85_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x22, 0xB6	| 408F469E s24 -> DECL_SR7E_85_Video_Sonora_OneBitMode
DECL_SR7E_85_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x28, 0xD6	| 408F46A2 s24 -> DECL_SR7E_85_Video_Sonora_TwoBitMode
DECL_SR7E_85_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2F, 0x34	| 408F46A6 s24 -> DECL_SR7E_85_Video_Sonora_FourBitMode
DECL_SR7E_85_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x35, 0xF2	| 408F46AA s24 -> DECL_SR7E_85_Video_Sonora_EightBitMode
    .short  0xFF00, 0x0000	| 408F46AE
DECL_SR7E_86_Video_Sonora:  /* sResource 86 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x02, 0x80	| 408F46B2 s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_86_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x03, 0x18	| 408F46B6 s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_86_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x04, 0x9A	| 408F46BA s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F46BE
DECL_SR7E_86_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x04, 0x9E	| 408F46C6 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_86_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x05, 0xBA	| 408F46CA s24 -> DECL_SR7E_86_Video_Sonora_MinorLength_data
DECL_SR7E_86_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x05, 0xF2	| 408F46CE s24 -> DECL_SR7E_83_Video_Sonora_GammaDir
DECL_SR7E_86_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x22, 0x82	| 408F46D2 s24 -> DECL_SR7E_85_Video_Sonora_OneBitMode
DECL_SR7E_86_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x28, 0xA2	| 408F46D6 s24 -> DECL_SR7E_85_Video_Sonora_TwoBitMode
DECL_SR7E_86_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2F, 0x00	| 408F46DA s24 -> DECL_SR7E_85_Video_Sonora_FourBitMode
DECL_SR7E_86_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x35, 0xBE	| 408F46DE s24 -> DECL_SR7E_85_Video_Sonora_EightBitMode
DECL_SR7E_86_Video_Sonora_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x3A, 0xE0	| 408F46E2 s24 -> DECL_SR7E_86_Video_Sonora_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F46E6
DECL_SR7E_87_Video_Sonora:  /* sResource 87 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x02, 0x48	| 408F46EA s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_87_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x02, 0xE0	| 408F46EE s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_87_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x04, 0x62	| 408F46F2 s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F46F6
DECL_SR7E_87_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x04, 0x66	| 408F46FE s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_87_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x05, 0x6A	| 408F4702 s24 -> DECL_SR7E_80_Video_Sonora_MinorLength_data
DECL_SR7E_87_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x05, 0x9E	| 408F4706 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7E_87_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x22, 0x2A	| 408F470A s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode
DECL_SR7E_87_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x28, 0x4A	| 408F470E s24 -> DECL_SR7E_80_Video_Sonora_TwoBitMode
    .short  0xFF00, 0x0000	| 408F4712
DECL_SR7E_88_Video_Sonora:  /* sResource 88 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x02, 0x1C	| 408F4716 s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_88_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x02, 0xB4	| 408F471A s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_88_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x04, 0x36	| 408F471E s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4722
DECL_SR7E_88_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x04, 0x3A	| 408F472A s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_88_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x05, 0x42	| 408F472E s24 -> DECL_SR7E_81_Video_Sonora_MinorLength_data
DECL_SR7E_88_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x05, 0x72	| 408F4732 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7E_88_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x21, 0xFE	| 408F4736 s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode
DECL_SR7E_88_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x28, 0x1E	| 408F473A s24 -> DECL_SR7E_80_Video_Sonora_TwoBitMode
DECL_SR7E_88_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2E, 0x7C	| 408F473E s24 -> DECL_SR7E_81_Video_Sonora_FourBitMode
    .short  0xFF00, 0x0000	| 408F4742
DECL_SR7E_89_Video_Sonora:  /* sResource 89 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x01, 0xEC	| 408F4746 s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_89_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x02, 0x84	| 408F474A s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_89_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x04, 0x06	| 408F474E s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4752
DECL_SR7E_89_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x04, 0x0A	| 408F475A s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_89_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x05, 0x16	| 408F475E s24 -> DECL_SR7E_82_Video_Sonora_MinorLength_data
DECL_SR7E_89_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x05, 0x42	| 408F4762 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7E_89_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x21, 0xCE	| 408F4766 s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode
DECL_SR7E_89_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x27, 0xEE	| 408F476A s24 -> DECL_SR7E_80_Video_Sonora_TwoBitMode
DECL_SR7E_89_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2E, 0x4C	| 408F476E s24 -> DECL_SR7E_81_Video_Sonora_FourBitMode
DECL_SR7E_89_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x35, 0x0A	| 408F4772 s24 -> DECL_SR7E_82_Video_Sonora_EightBitMode
    .short  0xFF00, 0x0000	| 408F4776
DECL_SR7E_8A_Video_Sonora:  /* sResource 8A in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x01, 0xB8	| 408F477A s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_8A_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x02, 0x50	| 408F477E s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_8A_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x03, 0xD2	| 408F4782 s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4786
DECL_SR7E_8A_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x03, 0xD6	| 408F478E s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_8A_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x04, 0xF6	| 408F4792 s24 -> DECL_SR7E_8A_Video_Sonora_MinorLength_data
DECL_SR7E_8A_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x05, 0x1A	| 408F4796 s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7E_8A_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x21, 0x7A	| 408F479A s24 -> DECL_SR7E_8A_Video_Sonora_OneBitMode
DECL_SR7E_8A_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x27, 0x9A	| 408F479E s24 -> DECL_SR7E_8A_Video_Sonora_TwoBitMode
DECL_SR7E_8A_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2D, 0xF8	| 408F47A2 s24 -> DECL_SR7E_8A_Video_Sonora_FourBitMode
    .short  0xFF00, 0x0000	| 408F47A6
DECL_SR7E_8B_Video_Sonora:  /* sResource 8B in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x01, 0x88	| 408F47AA s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_8B_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x02, 0x20	| 408F47AE s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_8B_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x03, 0xA2	| 408F47B2 s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F47B6
DECL_SR7E_8B_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x03, 0xA6	| 408F47BE s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_8B_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x04, 0xCA	| 408F47C2 s24 -> DECL_SR7E_8B_Video_Sonora_MinorLength_data
DECL_SR7E_8B_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x04, 0xEA	| 408F47C6 s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7E_8B_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x21, 0x4A	| 408F47CA s24 -> DECL_SR7E_8A_Video_Sonora_OneBitMode
DECL_SR7E_8B_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x27, 0x6A	| 408F47CE s24 -> DECL_SR7E_8A_Video_Sonora_TwoBitMode
DECL_SR7E_8B_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2D, 0xC8	| 408F47D2 s24 -> DECL_SR7E_8A_Video_Sonora_FourBitMode
DECL_SR7E_8B_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x34, 0x86	| 408F47D6 s24 -> DECL_SR7E_8B_Video_Sonora_EightBitMode
    .short  0xFF00, 0x0000	| 408F47DA
DECL_SR7E_8C_Video_Sonora:  /* sResource 8C in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x01, 0x54	| 408F47DE s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_8C_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x01, 0xEC	| 408F47E2 s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_8C_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x03, 0x6E	| 408F47E6 s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F47EA
DECL_SR7E_8C_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x03, 0x72	| 408F47F2 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_8C_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x04, 0x9A	| 408F47F6 s24 -> DECL_SR7E_8C_Video_Sonora_MinorLength_data
DECL_SR7E_8C_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x04, 0xB6	| 408F47FA s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7E_8C_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x21, 0x16	| 408F47FE s24 -> DECL_SR7E_8A_Video_Sonora_OneBitMode
DECL_SR7E_8C_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x27, 0x36	| 408F4802 s24 -> DECL_SR7E_8A_Video_Sonora_TwoBitMode
DECL_SR7E_8C_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2D, 0x94	| 408F4806 s24 -> DECL_SR7E_8A_Video_Sonora_FourBitMode
DECL_SR7E_8C_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x34, 0x52	| 408F480A s24 -> DECL_SR7E_8B_Video_Sonora_EightBitMode
DECL_SR7E_8C_Video_Sonora_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x39, 0x84	| 408F480E s24 -> DECL_SR7E_8C_Video_Sonora_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F4812
DECL_SR7E_8D_Video_Sonora:  /* sResource 8D in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x01, 0x1C	| 408F4816 s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_8D_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x01, 0xB4	| 408F481A s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_8D_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x03, 0x36	| 408F481E s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4822
DECL_SR7E_8D_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x03, 0x3A	| 408F482A s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_8D_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x04, 0x66	| 408F482E s24 -> DECL_SR7E_8D_Video_Sonora_MinorLength_data
DECL_SR7E_8D_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x04, 0x7E	| 408F4832 s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7E_8D_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x20, 0xEE	| 408F4836 s24 -> DECL_SR7E_8D_Video_Sonora_OneBitMode
DECL_SR7E_8D_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x27, 0x0E	| 408F483A s24 -> DECL_SR7E_8D_Video_Sonora_TwoBitMode
DECL_SR7E_8D_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2D, 0x6C	| 408F483E s24 -> DECL_SR7E_8D_Video_Sonora_FourBitMode
DECL_SR7E_8D_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x34, 0x2A	| 408F4842 s24 -> DECL_SR7E_8D_Video_Sonora_EightBitMode
    .short  0xFF00, 0x0000	| 408F4846
DECL_SR7E_8E_Video_Sonora:  /* sResource 8E in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x00, 0xE8	| 408F484A s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_8E_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x01, 0x80	| 408F484E s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_8E_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x03, 0x02	| 408F4852 s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F4856
DECL_SR7E_8E_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x03, 0x06	| 408F485E s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_8E_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x04, 0x36	| 408F4862 s24 -> DECL_SR7E_8E_Video_Sonora_MinorLength_data
DECL_SR7E_8E_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x04, 0x4A	| 408F4866 s24 -> DECL_SR7E_8A_Video_Sonora_GammaDir
DECL_SR7E_8E_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x20, 0xBA	| 408F486A s24 -> DECL_SR7E_8D_Video_Sonora_OneBitMode
DECL_SR7E_8E_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x26, 0xDA	| 408F486E s24 -> DECL_SR7E_8D_Video_Sonora_TwoBitMode
DECL_SR7E_8E_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2D, 0x38	| 408F4872 s24 -> DECL_SR7E_8D_Video_Sonora_FourBitMode
DECL_SR7E_8E_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x33, 0xF6	| 408F4876 s24 -> DECL_SR7E_8D_Video_Sonora_EightBitMode
DECL_SR7E_8E_Video_Sonora_SixteenBitMode_entry:  /* entry SixteenBitMode (132): 16 bits per pixel */
    .byte   0x84, 0x00, 0x39, 0x28	| 408F487A s24 -> DECL_SR7E_8E_Video_Sonora_SixteenBitMode
    .short  0xFF00, 0x0000	| 408F487E
DECL_SR7E_92_Video_Sonora:  /* sResource 92 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x00, 0xB0	| 408F4882 s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_92_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x01, 0x48	| 408F4886 s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_92_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x02, 0xCA	| 408F488A s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F488E
DECL_SR7E_92_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x02, 0xCE	| 408F4896 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_92_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x04, 0x02	| 408F489A s24 -> DECL_SR7E_92_Video_Sonora_MinorLength_data
DECL_SR7E_92_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x04, 0x06	| 408F489E s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7E_92_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x20, 0xC2	| 408F48A2 s24 -> DECL_SR7E_92_Video_Sonora_OneBitMode
DECL_SR7E_92_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x26, 0xE2	| 408F48A6 s24 -> DECL_SR7E_92_Video_Sonora_TwoBitMode
    .short  0xFF00, 0x0000	| 408F48AA
DECL_SR7E_93_Video_Sonora:  /* sResource 93 in pool 7E: Video Sonora (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x00, 0x84	| 408F48AE s24 -> DECL_TYPE_0003_0001_0001_0022
DECL_SR7E_93_Video_Sonora_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x01, 0x1C	| 408F48B2 s24 -> DECL_NAME_Display_Video_Apple_Sonora
DECL_SR7E_93_Video_Sonora_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x02, 0x9E	| 408F48B6 s24 -> DECL_SR7E_80_Video_Sonora_DrvrDir
    .short  0x0700, 0x0006, 0x0800, 0x0001	| 408F48BA
DECL_SR7E_93_Video_Sonora_MinorBaseOS_entry:  /* entry MinorBaseOS (10): offset of its device space in the slot (the frame buffer) */
    .byte   0x0A, 0x00, 0x02, 0xA2	| 408F48C2 s24 -> DECL_SR7E_80_Video_Sonora_MinorBaseOS_data
DECL_SR7E_93_Video_Sonora_MinorLength_entry:  /* entry MinorLength (11): length of that space */
    .byte   0x0B, 0x00, 0x03, 0xDA	| 408F48C6 s24 -> DECL_SR7E_93_Video_Sonora_MinorLength_data
DECL_SR7E_93_Video_Sonora_sGammaDir_entry:  /* entry sGammaDir (64): its gamma tables */
    .byte   0x40, 0x00, 0x03, 0xDA	| 408F48CA s24 -> DECL_SR7E_87_Video_Sonora_GammaDir
DECL_SR7E_93_Video_Sonora_OneBitMode_entry:  /* entry OneBitMode (128): the 1 bit per pixel mode */
    .byte   0x80, 0x00, 0x20, 0x96	| 408F48CE s24 -> DECL_SR7E_92_Video_Sonora_OneBitMode
DECL_SR7E_93_Video_Sonora_TwoBitMode_entry:  /* entry TwoBitMode (129): 2 bits per pixel */
    .byte   0x81, 0x00, 0x26, 0xB6	| 408F48D2 s24 -> DECL_SR7E_92_Video_Sonora_TwoBitMode
DECL_SR7E_93_Video_Sonora_FourBitMode_entry:  /* entry FourBitMode (130): 4 bits per pixel */
    .byte   0x82, 0x00, 0x2D, 0x14	| 408F48D6 s24 -> DECL_SR7E_93_Video_Sonora_FourBitMode
DECL_SR7E_93_Video_Sonora_EightBitMode_entry:  /* entry EightBitMode (131): 8 bits per pixel */
    .byte   0x83, 0x00, 0x33, 0xD2	| 408F48DA s24 -> DECL_SR7E_93_Video_Sonora_EightBitMode
    .short  0xFF00, 0x0000	| 408F48DE
DECL_SR7E_FD_Ethernet_Sonic:  /* sResource FD in pool 7E: Ethernet Sonic (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x00, 0x58	| 408F48E2 s24 -> DECL_TYPE_0004_0001_0001_0110
DECL_SR7E_FD_Ethernet_Sonic_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x01, 0x04	| 408F48E6 s24 -> DECL_NAME_Network_Ethernet_Apple_Sonic
DECL_SR7E_FD_Ethernet_Sonic_sRsrcDrvrDir_entry:  /* entry sRsrcDrvrDir (4): its driver directory */
    .byte   0x04, 0x00, 0x02, 0x72	| 408F48EA s24 -> DECL_SR7E_FD_Ethernet_Sonic_DrvrDir
    .short  0x0700, 0x0000, 0x0800, 0x0001, 0xFF00, 0x0000	| 408F48EE
DECL_SR7F_FE_CPU_AppleII_AppleIIe_FeatureCard:  /* sResource FE in pool 7F: CPU AppleII AppleIIe FeatureCard (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x01, 0x00, 0x00, 0x48	| 408F48FA s24 -> DECL_TYPE_000A_0015_0001_0001
DECL_SR7F_FE_CPU_AppleII_AppleIIe_FeatureCard_sRsrcName_entry:  /* entry sRsrcName (2): the sResource's name */
    .byte   0x02, 0x00, 0x01, 0x0C	| 408F48FE s24 -> DECL_NAME_CPU_AppleII_AppleIIe_FeatureCard
DECL_SR7F_FE_CPU_AppleII_AppleIIe_FeatureCard_id80_entry:  /* entry, ID 80 */
    .byte   0x80, 0x00, 0x80, 0x07	| 408F4902 s24 -> DECL_SR7F_FE_CPU_AppleII_AppleIIe_FeatureCard_id80_data
    .short  0xFF00, 0x0000	| 408F4906
DECL_TYPE_0003_0001_0001_0018:  /* sRsrcType: category 0003, cType 0001, DrSW 0001, DrHW 0018 */
    .short  0x0003, 0x0001, 0x0001, 0x0018	| 408F490A
DECL_TYPE_0003_0001_0001_001A:  /* sRsrcType: category 0003, cType 0001, DrSW 0001, DrHW 001A */
    .short  0x0003, 0x0001, 0x0001, 0x001A	| 408F4912
DECL_TYPE_0003_0001_0001_001B:  /* sRsrcType: category 0003, cType 0001, DrSW 0001, DrHW 001B */
    .short  0x0003, 0x0001, 0x0001, 0x001B	| 408F491A
DECL_TYPE_0003_0001_0001_001C:  /* sRsrcType: category 0003, cType 0001, DrSW 0001, DrHW 001C */
    .short  0x0003, 0x0001, 0x0001, 0x001C	| 408F4922
DECL_TYPE_0003_0001_0001_001E:  /* sRsrcType: category 0003, cType 0001, DrSW 0001, DrHW 001E */
    .short  0x0003, 0x0001, 0x0001, 0x001E	| 408F492A
DECL_TYPE_0003_0001_0001_0022:  /* sRsrcType: category 0003, cType 0001, DrSW 0001, DrHW 0022 */
    .short  0x0003, 0x0001, 0x0001, 0x0022	| 408F4932
DECL_TYPE_0004_0001_0001_0110:  /* sRsrcType: category 0004, cType 0001, DrSW 0001, DrHW 0110 */
    .short  0x0004, 0x0001, 0x0001, 0x0110	| 408F493A
DECL_TYPE_000A_0015_0001_0001:  /* sRsrcType: category 000A, cType 0015, DrSW 0001, DrHW 0001 */
    .short  0x000A, 0x0015, 0x0001, 0x0001	| 408F4942
DECL_NAME_Display_Video_Apple_RBV1:  /* name string (C string) */
    .ascii  "Display_Video_Apple_RBV1\000\000"
    .short  0x0000	| 408F4964
DECL_NAME_Display_Video_Apple_V8:  /* name string (C string) */
    .ascii  "Display_Video_Apple_V8\000"
    .byte   0x00	| 408F497D
DECL_NAME_Display_Video_Apple_TIM:  /* name string (C string) */
    .ascii  "Display_Video_Apple_TIM\000"
DECL_NAME_Display_Video_Apple_DAFB:  /* name string (C string) */
    .ascii  "Display_Video_Apple_DAFB\000\000"
    .short  0x0000	| 408F49B0
DECL_NAME_Display_Video_Apple_DBLite:  /* name string (C string) */
    .ascii  "Display_Video_Apple_DBLite\000"
    .byte   0x00	| 408F49CD
DECL_NAME_Display_Video_Apple_Sonora:  /* name string (C string) */
    .ascii  "Display_Video_Apple_Sonora\000"
    .byte   0x00	| 408F49E9
DECL_NAME_Network_Ethernet_Apple_Sonic:  /* name string (C string) */
    .ascii  "Network_Ethernet_Apple_Sonic\000\000"
    .short  0x0000	| 408F4A08
DECL_NAME_CPU_AppleII_AppleIIe_FeatureCard:  /* name string (C string) */
    .ascii  "CPU_AppleII_AppleIIe_FeatureCard\000\000"
DECL_SR7E_15_MacAA_Built_In_Video_sRsrcIcon_data:  /* data of sRsrcIcon (3) */
    .long   0x3FFFE000	| 408F4A2C
    .long   0x40001000, 0x4FFF9000, 0x50005000, 0x55505000	| 408F4A30
    .long   0x50005000, 0x55005000, 0x50007FFC, 0x54004002	| 408F4A40
    .long   0x50004FF2, 0x5000500A, 0x5000554A, 0x4FFFD00A	| 408F4A50
    .long   0x4000550A, 0x3FFFD00A, 0x0800540A, 0x3BFF500A	| 408F4A60
    .long   0x2000540A, 0x3FFFD00A, 0x0000500A, 0x3FFE500A	| 408F4A70
    .long   0x40014FF2, 0x4FF94002, 0x50053FFC, 0x55050810	| 408F4A80
    .long   0x50057BDE, 0x54054002, 0x50057FFE, 0x50050000	| 408F4A90
    .long   0x4FF90000, 0x40010000, 0x3FFE0000	| 408F4AA0
DECL_SR7F_10_MacD_Built_In_Video_sRsrcIcon_data:  /* data of sRsrcIcon (3) */
    .long   0x00000000	| 408F4AAC
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408F4AB0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408F4AC0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408F4AD0
    .long   0x00000002, 0x00000005, 0x00000009, 0x00000012	| 408F4AE0
    .long   0x00000024, 0x00000048, 0x00000090	| 408F4AF0
    .long   0x00000120 /* number, not an address (F3) */	| 408F4AFC
    .long   0x00000240 /* number, not an address (F3) */	| 408F4B00
    .long   0x00000480 /* number, not an address (F3) */	| 408F4B04
    .long   0x00000900 /* number, not an address (F3) */	| 408F4B08
    .long   0x00000E00 /* number, not an address (F3) */	| 408F4B0C
    .long   0x00001C00 /* number, not an address (F3) */	| 408F4B10
    .long   0x00DB7E00, 0x01FFC200, 0x7F004200	| 408F4B14
    .long   0x803F4200, 0x80004200, 0xFFFFFC00	| 408F4B20
DECL_SR7F_81_Video_RBV1_DrvrDir:  /* sResource 81 in pool 7F: Video RBV1 DrvrDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x02, 0x00, 0x5B, 0x7C	| 408F4B2C s24 -> DECL_DRVR_Display_Video_Apple_RBV1
    .long   0xFF000000	| 408F4B30
DECL_SR7F_A2_Video_V8_DrvrDir:  /* sResource A2 in pool 7F: Video V8 DrvrDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x02, 0x00, 0x63, 0x10	| 408F4B34 s24 -> DECL_DRVR_Display_Video_Apple_V8
    .long   0xFF000000	| 408F4B38
DECL_SR7F_BE_Video_DAFB_DrvrDir:  /* sResource BE in pool 7F: Video DAFB DrvrDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x02, 0x00, 0x6B, 0xAC	| 408F4B3C s24 -> DECL_DRVR_Display_Video_Apple_DAFB
    .long   0xFF000000	| 408F4B40
DECL_SR7F_E0_Video_TIM_DrvrDir:  /* sResource E0 in pool 7F: Video TIM DrvrDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x02, 0x00, 0x80, 0xCC	| 408F4B44 s24 -> DECL_DRVR_Display_Video_Apple_TIM
    .long   0xFF000000	| 408F4B48
DECL_SR7F_BB_Video_DBLite_DrvrDir:  /* sResource BB in pool 7F: Video DBLite DrvrDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x02, 0x00, 0x83, 0xF0	| 408F4B4C s24 -> DECL_DRVR_Display_Video_Apple_DBLite
    .long   0xFF000000	| 408F4B50
DECL_SR7E_80_Video_Sonora_DrvrDir:  /* sResource 80 in pool 7E: Video Sonora DrvrDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x02, 0x00, 0x88, 0x64	| 408F4B54 s24 -> DECL_DRVR_Display_Video_Apple_Sonora
    .long   0xFF000000	| 408F4B58
DECL_SR7E_FD_Ethernet_Sonic_DrvrDir:  /* sResource FD in pool 7E: Ethernet Sonic DrvrDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x02, 0x00, 0x94, 0x54	| 408F4B5C s24 -> DECL_DRVR_ENET
    .long   0xFF000000	| 408F4B60
DECL_SR7E_80_Video_Sonora_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00000000	| 408F4B64
DECL_SR7F_BE_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00001000	| 408F4B68
DECL_SR7F_EF_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00000A00	| 408F4B6C
DECL_SR7F_C4_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00000080	| 408F4B70
DECL_SR7F_C7_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00000E00	| 408F4B74
DECL_SR7F_C6_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00000080	| 408F4B78
DECL_SR7F_D0_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00001020 /* number, not an address (F3) */	| 408F4B7C
DECL_SR7F_D8_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00001400 /* number, not an address (F3) */	| 408F4B80
DECL_SR7F_D5_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00000E20 /* number, not an address (F3) */	| 408F4B84
DECL_SR7F_D4_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00000700 /* number, not an address (F3) */	| 408F4B88
DECL_SR7F_DC_Video_DAFB_MinorBaseOS_data:  /* data of MinorBaseOS (10) */
    .long   0x00001420 /* number, not an address (F3) */	| 408F4B8C
DECL_SR7F_86_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0004B000 /* number, not an address (F3) */	| 408F4B90
DECL_SR7F_96_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00009600 /* number, not an address (F3) */	| 408F4B94
DECL_SR7F_9E_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00025800 /* number, not an address (F3) */	| 408F4B98
DECL_SR7F_8E_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00012C00 /* number, not an address (F3) */	| 408F4B9C
DECL_SR7F_81_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00043F80 /* number, not an address (F3) */	| 408F4BA0
DECL_SR7F_91_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00010FE0 /* number, not an address (F3) */	| 408F4BA4
DECL_SR7F_89_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00021FC0 /* number, not an address (F3) */	| 408F4BA8
DECL_SR7F_87_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0002AC00 /* number, not an address (F3) */	| 408F4BAC
DECL_SR7F_97_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00005580 /* number, not an address (F3) */	| 408F4BB0
DECL_SR7F_9F_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00015600 /* number, not an address (F3) */	| 408F4BB4
DECL_SR7F_8F_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0000AB00 /* number, not an address (F3) */	| 408F4BB8
DECL_SR7F_82_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00030000 /* number, not an address (F3) */	| 408F4BBC
DECL_SR7F_92_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00006000 /* number, not an address (F3) */	| 408F4BC0
DECL_SR7F_9A_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00018000 /* number, not an address (F3) */	| 408F4BC4
DECL_SR7F_8A_Video_RBV1_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0000C000 /* number, not an address (F3) */	| 408F4BC8
DECL_SR7F_A6_Video_V8_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00078000 /* number, not an address (F3) */	| 408F4BCC
DECL_SR7F_AE_Video_V8_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0003C000 /* number, not an address (F3) */	| 408F4BD0
DECL_SR7F_A2_Video_V8_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00060000 /* number, not an address (F3) */	| 408F4BD4
DECL_SR7F_AA_Video_V8_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00030000 /* number, not an address (F3) */	| 408F4BD8
DECL_SR7F_A3_Video_V8_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00078000 /* number, not an address (F3) */	| 408F4BDC
DECL_SR7F_AB_Video_V8_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0003C000 /* number, not an address (F3) */	| 408F4BE0
DECL_SR7F_B2_Video_V8_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00060000 /* number, not an address (F3) */	| 408F4BE4
DECL_SR7F_BA_Video_V8_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00030000 /* number, not an address (F3) */	| 408F4BE8
DECL_SR7F_C0_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0006CC00 /* number, not an address (F3) */	| 408F4BEC
DECL_SR7F_C1_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x000D9800 /* number, not an address (F3) */	| 408F4BF0
DECL_SR7F_ED_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x001B3000	| 408F4BF4
DECL_SR7F_C4_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0007A580	| 408F4BF8
DECL_SR7F_C5_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x000F4B00	| 408F4BFC
DECL_SR7F_EF_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x001E9600	| 408F4C00
DECL_SR7F_C6_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0007EC00	| 408F4C04
DECL_SR7F_E6_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x000FD800	| 408F4C08
DECL_SR7F_C7_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x001FB000	| 408F4C0C
DECL_SR7F_C2_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00060000	| 408F4C10
DECL_SR7F_C3_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x000C0000	| 408F4C14
DECL_SR7F_D1_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00180000	| 408F4C18
DECL_SR7F_C8_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00078000	| 408F4C1C
DECL_SR7F_E2_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x000F0000	| 408F4C20
DECL_SR7F_C9_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x001E0000	| 408F4C24
DECL_SR7F_D6_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00075000	| 408F4C28
DECL_SR7F_F6_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x000EA000	| 408F4C2C
DECL_SR7F_D7_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x001D4000	| 408F4C30
DECL_SR7F_DE_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00090000	| 408F4C34
DECL_SR7F_D4_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00061800	| 408F4C38
DECL_SR7F_F4_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x000C3000	| 408F4C3C
DECL_SR7F_D5_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00186000	| 408F4C40
DECL_SR7F_DC_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00078000	| 408F4C44
DECL_SR7F_EA_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00079E00	| 408F4C48
DECL_SR7F_E8_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x000F3C00	| 408F4C4C
DECL_SR7F_E9_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x001E7800	| 408F4C50
DECL_SR7F_BE_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00060000	| 408F4C54
DECL_SR7F_BF_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x000C0000	| 408F4C58
DECL_SR7F_F9_Video_DAFB_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00180000	| 408F4C5C
DECL_SR7F_BB_Video_DBLite_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00025800	| 408F4C60
DECL_SR7F_BC_Video_DBLite_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0001F400	| 408F4C64
DECL_SR7F_BD_Video_DBLite_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00007D00	| 408F4C68
DECL_SR7E_80_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00021FC0	| 408F4C6C
DECL_SR7E_81_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00043F80	| 408F4C70
DECL_SR7E_82_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00087F00	| 408F4C74
DECL_SR7E_83_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00030000	| 408F4C78
DECL_SR7E_84_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00060000	| 408F4C7C
DECL_SR7E_85_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00030000	| 408F4C80
DECL_SR7E_86_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00060000	| 408F4C84
DECL_SR7E_8A_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00025800	| 408F4C88
DECL_SR7E_8B_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0004B000	| 408F4C8C
DECL_SR7E_8C_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x00096000	| 408F4C90
DECL_SR7E_8D_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0003E800	| 408F4C94
DECL_SR7E_8E_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0007D000	| 408F4C98
DECL_SR7E_92_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0001FB00	| 408F4C9C
DECL_SR7E_93_Video_Sonora_MinorLength_data:  /* data of MinorLength (11) */
    .long   0x0007EC00	| 408F4CA0
DECL_SR7E_87_Video_Sonora_GammaDir:  /* sResource 87 in pool 7E: Video Sonora GammaDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x80, 0x00, 0x03, 0x48	| 408F4CA4 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir_80_Mac_Std_Gamma
DECL_SR7E_87_Video_Sonora_GammaDir_81_entry:  /* entry, ID 81 */
    .byte   0x81, 0x00, 0x00, 0x20	| 408F4CA8 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir_81_Page_White_Gamma
    .long   0xFF000000	| 408F4CAC
DECL_SR7E_8A_Video_Sonora_GammaDir:  /* sResource 8A in pool 7E: Video Sonora GammaDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x80, 0x00, 0x03, 0x3C	| 408F4CB0 s24 -> DECL_SR7E_87_Video_Sonora_GammaDir_80_Mac_Std_Gamma
    .long   0xFF000000	| 408F4CB4
DECL_SR7E_80_Video_Sonora_GammaDir:  /* sResource 80 in pool 7E: Video Sonora GammaDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x80, 0x00, 0x04, 0x54	| 408F4CB8 s24 -> DECL_SR7E_80_Video_Sonora_GammaDir_80_Mac_Gray_Gamma
    .long   0xFF000000	| 408F4CBC
DECL_SR7E_83_Video_Sonora_GammaDir:  /* sResource 83 in pool 7E: Video Sonora GammaDir (its entry list; the first entry, sRsrcType, is here) */
    .byte   0x80, 0x00, 0x05, 0x6E	| 408F4CC0 s24 -> DECL_SR7E_83_Video_Sonora_GammaDir_80_Mac_RGB_Gamma
    .long   0xFF000000	| 408F4CC4
DECL_SR7E_87_Video_Sonora_GammaDir_81_Page_White_Gamma:  /* sResource 87 in pool 7E: Video Sonora GammaDir 81 Page White Gamma (its entry list; the first entry, sRsrcType, is here) */
    .short  0x0000, 0x0324, 0x07D0	| 408F4CC8
    .ascii  "Page-White Gamma\000\000"
    .long   0x00000000, 0x00000003, 0x01000008, 0x00030609	| 408F4CE0
    .long   0x0C101012, 0x13151616, 0x181B1C1E, 0x1F222326	| 408F4CF0
    .long   0x282B2C2F, 0x3234373A, 0x3C3F4041, 0x42434445	| 408F4D00
    .long   0x46474749, 0x4A4B4C4D, 0x4E4F5051, 0x52535454	| 408F4D10
    .long   0x56565758, 0x595A5B5C, 0x5D5E5F60, 0x61626364	| 408F4D20
    .long   0x65666768, 0x696A6B6C, 0x6D6E6F70, 0x71727273	| 408F4D30
    .long   0x74757677, 0x78797A7A, 0x7B7C7D7E, 0x7F818283	| 408F4D40
    .long   0x83848586, 0x8788898A, 0x8A8B8C8D, 0x8E8F9091	| 408F4D50
    .long   0x92939394, 0x95969798, 0x98999A9B, 0x9C9D9E9F	| 408F4D60
    .long   0xA0A1A1A2, 0xA3A4A4A5, 0xA6A7A8A8, 0xA9AAABAC	| 408F4D70
    .long   0xADADAEAF, 0xB0B1B2B2, 0xB3B4B5B5, 0xB6B7B8B8	| 408F4D80
    .long   0xB9BABBBC, 0xBCBDBEBF, 0xC0C0C1C2, 0xC3C3C4C5	| 408F4D90
    .long   0xC6C6C7C8, 0xC9C9CACB, 0xCCCDCDCE, 0xCFD0D1D1	| 408F4DA0
    .long   0xD2D3D4D4, 0xD5D6D7D7, 0xD8D9DADA, 0xDBDCDDDE	| 408F4DB0
    .long   0xDEDFE0E1, 0xE1E2E3E4, 0xE4E5E6E7, 0xE7E8E9EA	| 408F4DC0
    .long   0xEAEBECED, 0xEEEEEFF0, 0xF1F1F2F3, 0xF4F4F5F6	| 408F4DD0
    .long   0xF7F8F8F9, 0xFAFBFBFC, 0xFDFEFFFF, 0x00030609	| 408F4DE0
    .long   0x0C101018, 0x20202223, 0x24252728, 0x292C2D2E	| 408F4DF0
    .long   0x30323437, 0x383A3D3F, 0x40414242, 0x43444445	| 408F4E00
    .long   0x46474849, 0x4A4A4B4C, 0x4D4E4F50, 0x51525354	| 408F4E10
    .long   0x55565758, 0x595B5C5D, 0x5E5F6061, 0x62636465	| 408F4E20
    .long   0x65666768, 0x696A6B6C, 0x6D6E6F70, 0x71717273	| 408F4E30
    .long   0x74747576, 0x77787979, 0x7A7B7C7D, 0x7E7F8081	| 408F4E40
    .long   0x82838484, 0x85868788, 0x88898A8B, 0x8C8D8E8E	| 408F4E50
    .long   0x8F909192, 0x93939495, 0x96969798, 0x999A9A9B	| 408F4E60
    .long   0x9C9D9E9E, 0x9FA0A1A2, 0xA2A3A4A5, 0xA5A6A7A8	| 408F4E70
    .long   0xA8A9AAAB, 0xABACADAE, 0xAFAFB0B1, 0xB2B2B3B4	| 408F4E80
    .long   0xB5B5B6B7, 0xB7B8B9BA, 0xBABBBCBD, 0xBDBEBFC0	| 408F4E90
    .long   0xC1C1C2C3, 0xC3C4C5C6, 0xC6C7C8C9, 0xC9CACBCC	| 408F4EA0
    .long   0xCCCDCECF, 0xCFD0D1D2, 0xD2D3D4D4, 0xD5D6D6D7	| 408F4EB0
    .long   0xD8D9D9DA, 0xDBDCDCDD, 0xDEDEDFE0, 0xE1E1E2E3	| 408F4EC0
    .long   0xE4E4E5E6, 0xE6E7E8E9, 0xE9EAEBEC, 0xECEDEEEF	| 408F4ED0
    .long   0xEFF0F1F2, 0xF2F3F4F4, 0xF5F6F7F7, 0x00020508	| 408F4EE0
    .long   0x0A0D1010, 0x10202022, 0x23232425, 0x25272829	| 408F4EF0
    .long   0x2A2C2D2E, 0x2F303233, 0x34363738, 0x3A3C3D3F	| 408F4F00
    .long   0x40414142, 0x42434444, 0x45454647, 0x4748494A	| 408F4F10
    .long   0x4A4B4C4D, 0x4D4E4F4F, 0x51515253, 0x54555656	| 408F4F20
    .long   0x5758595A, 0x5B5C5D5E, 0x5F606061, 0x62626364	| 408F4F30
    .long   0x64656666, 0x67686969, 0x6A6B6C6C, 0x6D6E6F6F	| 408F4F40
    .long   0x70717272, 0x73747475, 0x76777778, 0x79797A7B	| 408F4F50
    .long   0x7C7C7D7E, 0x7F808182, 0x82838484, 0x85868687	| 408F4F60
    .long   0x8888898A, 0x8A8B8C8D, 0x8D8E8F90, 0x90919192	| 408F4F70
    .long   0x93939495, 0x95969797, 0x9899999A, 0x9B9B9C9D	| 408F4F80
    .long   0x9D9E9FA0, 0xA0A1A1A2, 0xA3A3A4A4, 0xA5A6A6A7	| 408F4F90
    .long   0xA7A8A9A9, 0xAAABABAC, 0xADADAEAF, 0xAFB0B0B1	| 408F4FA0
    .long   0xB2B2B3B3, 0xB4B5B5B6, 0xB6B7B8B8, 0xB9BABABB	| 408F4FB0
    .long   0xBBBCBDBD, 0xBEBFBFC0, 0xC0C1C2C2, 0xC3C3C4C5	| 408F4FC0
    .long   0xC5C6C6C7, 0xC8C8C9C9, 0xCACBCBCC, 0xCCCDCECE	| 408F4FD0
    .long   0xCFD0D0D1, 0xD1D2D3D3, 0xD4D4D5D6	| 408F4FE0
DECL_SR7E_87_Video_Sonora_GammaDir_80_Mac_Std_Gamma:  /* sResource 87 in pool 7E: Video Sonora GammaDir 80 Mac Std Gamma (its entry list; the first entry, sRsrcType, is here) */
    .long   0x00000120	| 408F4FEC
    .short  0x07D1	| 408F4FF0
    .ascii  "Mac Std Gamma\000"
    .long   0x00000000, 0x00000001, 0x01000008, 0x0005090B	| 408F5000
    .long   0x0E101315, 0x17191B1D, 0x1E202224, 0x2527282A	| 408F5010
    .long   0x2C2D2F30, 0x31333436, 0x37383A3B, 0x3C3E3F40	| 408F5020
    .long   0x42434445, 0x4748494A, 0x4B4D4E4F, 0x50515254	| 408F5030
    .long   0x55565758, 0x595A5B5C, 0x5E5F6061, 0x62636465	| 408F5040
    .long   0x66676869, 0x6A6B6C6D, 0x6E6F7071, 0x72737475	| 408F5050
    .long   0x76777879, 0x7A7B7C7D, 0x7E7F8081, 0x81828384	| 408F5060
    .long   0x85868788, 0x898A8B8C, 0x8C8D8E8F, 0x90919293	| 408F5070
    .long   0x94959596, 0x9798999A, 0x9B9B9C9D, 0x9E9FA0A1	| 408F5080
    .long   0xA1A2A3A4, 0xA5A6A6A7, 0xA8A9AAAB, 0xABACADAE	| 408F5090
    .long   0xAFB0B0B1, 0xB2B3B4B4, 0xB5B6B7B8, 0xB8B9BABB	| 408F50A0
    .long   0xBCBCBDBE, 0xBFC0C0C1, 0xC2C3C3C4, 0xC5C6C7C7	| 408F50B0
    .long   0xC8C9CACA, 0xCBCCCDCD, 0xCECFD0D0, 0xD1D2D3D3	| 408F50C0
    .long   0xD4D5D6D6, 0xD7D8D9D9, 0xDADBDCDC, 0xDDDEDFDF	| 408F50D0
    .long   0xE0E1E1E2, 0xE3E4E4E5, 0xE6E7E7E8, 0xE9E9EAEB	| 408F50E0
    .long   0xECECEDEE, 0xEEEFF0F1, 0xF1F2F3F3, 0xF4F5F5F6	| 408F50F0
    .long   0xF7F8F8F9, 0xFAFAFBFC, 0xFCFDFEFF	| 408F5100
DECL_SR7E_80_Video_Sonora_GammaDir_80_Mac_Gray_Gamma:  /* sResource 80 in pool 7E: Video Sonora GammaDir 80 Mac Gray Gamma (its entry list; the first entry, sRsrcType, is here) */
    .long   0x00000122	| 408F510C
    .short  0x07D2	| 408F5110
    .ascii  "Mac Gray Gamma\000\000\000\000"
    .long   0x00000000, 0x00010100, 0x0008000A	| 408F5124
    .long   0x141D2326, 0x2B2E3032, 0x3437393B, 0x3C3E4041	| 408F5130
    .long   0x42444547, 0x484A4B4D, 0x4E4F5051, 0x52545556	| 408F5140
    .long   0x57585A5B, 0x5C5D5E5F, 0x60616364, 0x65666768	| 408F5150
    .long   0x696A6B6C, 0x6D6E6F70, 0x71717273, 0x74757677	| 408F5160
    .long   0x78797A7B, 0x7C7D7E7F, 0x80808182, 0x83848485	| 408F5170
    .long   0x86878889, 0x8A8A8B8C, 0x8D8E8F90, 0x90919292	| 408F5180
    .long   0x93949596, 0x97979899, 0x9A9A9B9C, 0x9D9E9E9F	| 408F5190
    .long   0xA0A1A1A2, 0xA3A3A4A5, 0xA6A7A7A8, 0xA9AAAAAB	| 408F51A0
    .long   0xACADADAE, 0xAFAFB0B1, 0xB2B2B3B4, 0xB4B5B6B6	| 408F51B0
    .long   0xB7B7B8B9, 0xB9BABBBC, 0xBCBDBEBE, 0xBFC0C0C1	| 408F51C0
    .long   0xC2C2C3C4, 0xC5C5C6C6, 0xC7C8C8C9, 0xCACBCCCD	| 408F51D0
    .long   0xCDCECFCF, 0xD0D0D1D2, 0xD2D3D3D4, 0xD5D6D6D7	| 408F51E0
    .long   0xD7D8D9D9, 0xDADADBDC, 0xDDDDDEDF, 0xDFE0E0E1	| 408F51F0
    .long   0xE2E3E3E4, 0xE5E5E6E6, 0xE7E7E8E8, 0xE9EAEAEB	| 408F5200
    .long   0xEBECEDED, 0xEEEFF0F0, 0xF1F2F2F3, 0xF4F4F5F5	| 408F5210
    .short  0xF6F7, 0xF7F8, 0xF9FA, 0xFAFB, 0xFCFC, 0xFDFE, 0xFEFF	| 408F5220
DECL_SR7E_83_Video_Sonora_GammaDir_80_Mac_RGB_Gamma:  /* sResource 83 in pool 7E: Video Sonora GammaDir 80 Mac RGB Gamma (its entry list; the first entry, sRsrcType, is here) */
    .short  0x0000	| 408F522E
    .long   0x012007D3	| 408F5230
    .ascii  "Mac RGB Gamma\000\000\000"
    .long   0x00000000, 0x00010100, 0x00080507	| 408F5244
    .long   0x08090B0C, 0x0D0F1011, 0x12141516, 0x18191A1C	| 408F5250
    .long   0x1D1E2021, 0x22232426, 0x28292A2C, 0x2D2F3031	| 408F5260
    .long   0x33343637, 0x38393A3C, 0x3D3E4041, 0x42434445	| 408F5270
    .long   0x4648494B, 0x4C4D4E4F, 0x50515253, 0x54555758	| 408F5280
    .long   0x595A5B5C, 0x5D5E5F60, 0x61636365, 0x65676769	| 408F5290
    .long   0x6A6B6C6D, 0x6E6F7071, 0x72737475, 0x76777879	| 408F52A0
    .long   0x7A7A7B7C, 0x7D7E7F81, 0x82838384, 0x85868788	| 408F52B0
    .long   0x898A8B8C, 0x8D8E8E90, 0x90919293, 0x93949596	| 408F52C0
    .long   0x9798999A, 0x9B9C9D9E, 0x9FA0A0A1, 0xA2A3A4A4	| 408F52D0
    .long   0xA5A6A7A8, 0xA9AAAAAC, 0xADADAEAE, 0xB0B1B2B3	| 408F52E0
    .long   0xB3B4B5B6, 0xB7B8B9B9, 0xBABBBCBD, 0xBEBFBFC0	| 408F52F0
    .long   0xC1C2C2C3, 0xC4C5C6C7, 0xC8C9CACB, 0xCCCDCDCE	| 408F5300
    .long   0xCECFD0D1, 0xD2D3D3D4, 0xD5D6D6D7, 0xD8D8D9DA	| 408F5310
    .long   0xDBDCDDDE, 0xDEDFE0E1, 0xE1E2E3E4, 0xE4E5E6E7	| 408F5320
    .long   0xE7E8E9EA, 0xEBECEDEE, 0xEEEFEFF0, 0xF1F2F3F3	| 408F5330
    .short  0xF4F5, 0xF6F7, 0xF8F8, 0xF9F9, 0xFAFB, 0xFCFD, 0xFEFF	| 408F5340
DECL_SR7F_0F_MacC_Built_In_Video_id7E_data:  /* data of entry ID 7E */
    .short  0xBE00	| 408F534E
    .long   0x0252BF00, 0x024EC000, 0x013CC100, 0x0138C200	| 408F5350
    .long   0x0350C300, 0x034CC400, 0x0484C500, 0x0480C600	| 408F5360
    .long   0x0778C700, 0x0774C800, 0x08ACC900, 0x08A8CA00	| 408F5370
    .long   0x09E0CB00, 0x09DCCC00, 0x010CCD00, 0x0108CE00	| 408F5380
    .long   0x045CCF00, 0x0458D000, 0x0C40D100, 0x0C3CD200	| 408F5390
    .long   0x0D74D300, 0x0D70D400, 0x1068D500, 0x1064D600	| 408F53A0
    .long   0x119CD700, 0x1198D800, 0x0E98D900, 0x0E94DA00	| 408F53B0
    .long   0x0F70DB00, 0x0F6CDC00, 0x12C0DD00, 0x12BCDE00	| 408F53C0
    .long   0x1398DF00, 0x1394E200, 0x084CE300, 0x0848E400	| 408F53D0
    .long   0x0980E500, 0x097CE600, 0x0700E700, 0x06FCE800	| 408F53E0
    .long   0x0AACE900, 0x0AA8EA00, 0x0AA4EB00, 0x0AA0EC00	| 408F53F0
    .long   0x02B0ED00, 0x0090EE00, 0x02A8EF00, 0x03E0F000	| 408F5400
    .long   0x0BC8F100, 0x0BC4F200, 0x0CFCF300, 0x0CF8F400	| 408F5410
    .long   0x0FF0F500, 0x0FECF600, 0x1124F700, 0x1120F900	| 408F5420
    .short  0x0172, 0xFD00, 0x04C6, 0xFE00, 0x05D0, 0xFF00, 0x0000	| 408F5430
DECL_SR7E_15_MacAA_Built_In_Video_id7E_data:  /* data of entry ID 7E */
    .short  0x8000	| 408F543E
    .long   0x14088100, 0x14048200, 0x14008300, 0x14188400	| 408F5440
    .long   0x14148500, 0x142E8600, 0x142A8700, 0x13EC8800	| 408F5450
    .long   0x13E88900, 0x13E48A00, 0x14388B00, 0x14348C00	| 408F5460
    .long   0x14308D00, 0x144A8E00, 0x14468F00, 0x14609000	| 408F5470
    .long   0x145C9100, 0x14589200, 0x14729300, 0x146EFF00	| 408F5480
    .long   0x00000000, 0x010E0E07, 0x00000B00, 0x00000002	| 408F5490
    .long   0x2C0501A0, 0x7E008384, 0xFFFF0365, 0x072C072A	| 408F54A0
    .long   0x00040009, 0x00580724, 0x072A0080, 0x060E0010	| 408F54B0
    .long   0x017600D0, 0x0014019F, 0x0027002D, 0x003F004B	| 408F54C0
    .long   0x018B019E, 0x001D00A0, 0x001A0048, 0x01880009	| 408F54D0
    .long   0x0000FFFF, 0x000001B0, 0x00800606, 0x00100176	| 408F54E0
    .long   0x00D00014, 0x019F0027, 0x002D003F, 0x004B018B	| 408F54F0
    .long   0x019E0035, 0x00A80032, 0x00480188, 0x00130000	| 408F5500
    .long   0xFFFF0000, 0x01600080, 0x06020010, 0x017600D0	| 408F5510
    .long   0x0014019F, 0x0027002D, 0x003F004B, 0x018B019E	| 408F5520
    .long   0x004100B0, 0x003E0048, 0x01880027, 0x0000FFFF	| 408F5530
    .long   0x000000C0, 0x01000600, 0x00100176, 0x00D00014	| 408F5540
    .long   0x019F0027, 0x002D003F, 0x004B018B, 0x019E0047	| 408F5550
    .long   0x00B80044, 0x00480188, 0x004F0000, 0xFFFF0000	| 408F5560
    .long   0x01800200, 0x06FF0011, 0x017600D0, 0x0014019F	| 408F5570
    .long   0x0027002D, 0x003F004B, 0x018B019E, 0x004A00BE	| 408F5580
    .long   0x00470048, 0x0188009F, 0x0000FFFF, 0x00000300	| 408F5590
    .long   0x0000010E, 0x080F0000, 0x0F010000, 0x00013C04	| 408F55A0
    .long   0x00400400, 0x8384FFFF, 0x02FF0648, 0x06460004	| 408F55B0
    .long   0x00090040, 0x06400644, 0x00800606, 0x0030012A	| 408F55C0
    .long   0x00A5000C, 0x014B0017, 0x001A0023, 0x003F013F	| 408F55D0
    .long   0x014A0029, 0x00C00029, 0x003F013F, 0x000F0000	| 408F55E0
    .long   0xFFFF0000, 0x01800080, 0x06020030, 0x012A00A5	| 408F55F0
    .long   0x000C014B, 0x0017001A, 0x0023003F, 0x013F014A	| 408F5600
    .long   0x003500C8, 0x0035003F, 0x013F001F, 0x0000FFFF	| 408F5610
    .long   0x00000100, 0x00800600, 0x0030012A, 0x00A5000C	| 408F5620
    .long   0x014B0017, 0x001A0023, 0x003F013F, 0x014A003B	| 408F5630
    .long   0x00D0003B, 0x003F013F, 0x003F0000, 0xFFFF0000	| 408F5640
    .long   0x00000100, 0x06FF0030, 0x012A00A5, 0x000C014B	| 408F5650
    .long   0x0017001A, 0x0023003F, 0x013F014A, 0x003F00D8	| 408F5660
    .long   0x003F003F, 0x013F007F, 0x0000FFFF, 0x00000000	| 408F5670
    .long   0x020006FF, 0x00310254, 0x014A0018, 0x0297002F	| 408F5680
    .long   0x00350047, 0x00810281, 0x02960080, 0x00BE0080	| 408F5690
    .long   0x00810281, 0x00FF0000, 0xFFFF0000, 0x00000000	| 408F56A0
    .long   0x013C0E05, 0x00000F00, 0x00000003, 0x1C0540A0	| 408F56B0
    .long   0x7A008585, 0xFFFF017F, 0x032E032C, 0x00040009	| 408F56C0
    .long   0x002A032A, 0x032B0100, 0x061E0050, 0x025E0140	| 408F56D0
    .long   0x0010027F, 0x001F002B, 0x004F0068, 0x0268027E	| 408F56E0
    .long   0x000A0080, 0x00050063, 0x02630007, 0x0000FFFF	| 408F56F0
    .long   0x000003C0, 0x0100060E, 0x0050025E, 0x01400010	| 408F5700
    .long   0x027F001F, 0x002B004F, 0x00680268, 0x027E003A	| 408F5710
    .long   0x00880035, 0x00630263, 0x000F0000, 0xFFFF0000	| 408F5720
    .long   0x03800100, 0x06060050, 0x025E0140, 0x0010027F	| 408F5730
    .long   0x001F002B, 0x004F0068, 0x0268027E, 0x00520090	| 408F5740
    .long   0x004D0063, 0x0263001F, 0x0000FFFF, 0x00000300	| 408F5750
    .long   0x01000602, 0x0050025E, 0x01400010, 0x027F001F	| 408F5760
    .long   0x002B004F, 0x00680268, 0x027E005E, 0x00980059	| 408F5770
    .long   0x00630263, 0x003F0000, 0xFFFF0000, 0x02000100	| 408F5780
    .long   0x06000050, 0x025E0140, 0x0010027F, 0x001F002B	| 408F5790
    .long   0x004F0063, 0x0263027E, 0x005F009E, 0x005F0063	| 408F57A0
    .long   0x0263007F, 0x0000FFFF, 0x00000000, 0x020006FF	| 408F57B0
    .long   0x0050025E, 0x01400010, 0x027F001F, 0x002B004F	| 408F57C0
    .long   0x00690269, 0x027E0069, 0x009C0063, 0x00630263	| 408F57D0
    .long   0x00FF0000, 0xFFFF0000, 0x00000000, 0x010E0E0B	| 408F57E0
    .long   0x00000602, 0x00000000, 0x1C040040, 0x14008384	| 408F57F0
    .long   0x03FF0365, 0x07260724, 0x00040009, 0x0052071E	| 408F5800
    .long   0x07220090, 0x04060010, 0x014A00B6, 0x0010016B	| 408F5810
    .long   0x001F0022, 0x002B0040, 0x0160016A, 0x002A00C0	| 408F5820
    .long   0x0029003F, 0x015F0011, 0x0000FFFF, 0x000001B0	| 408F5830
    .long   0x00900402, 0x0010014A, 0x00B60010, 0x016B001F	| 408F5840
    .long   0x0022002B, 0x00400160, 0x016A0036, 0x00C80035	| 408F5850
    .long   0x003F015F, 0x00230000, 0xFFFF0000, 0x01200090	| 408F5860
    .long   0x04000010, 0x014A00B6, 0x0010016B, 0x001F0022	| 408F5870
    .long   0x002B0040, 0x0160016A, 0x003C00D0, 0x003B003F	| 408F5880
    .long   0x015F0047, 0x0000FFFF, 0x00000000, 0x012004FF	| 408F5890
    .long   0x0011014A, 0x00B60010, 0x016B001F, 0x0022002B	| 408F58A0
    .long   0x00400160, 0x016A0040, 0x00D8003F, 0x003F015F	| 408F58B0
    .long   0x008F0000	| 408F58C0
    .long   0xFFFF0000 /* number, not a label difference (was rsrc_DRVR_9__MPP_1234-.) */	| 408F58C4
    .long   0x00000240, 0x04FF0011	| 408F58C8
    .long   0x0294016C, 0x002002D7, 0x003F0045, 0x00570087	| 408F58D0
    .long   0x02C702D6, 0x008600BE, 0x00800081, 0x02C1011F	| 408F58E0
    .long   0x0000FFFF, 0x00000000, 0x0000010E, 0x0E0B0000	| 408F58F0
    .long   0x06020000, 0x00001C04, 0x00401400, 0x838403FF	| 408F5900
    .long   0x03650720, 0x071E0004, 0x00090046, 0x0712071C	| 408F5910
    .long   0x00900406, 0x0010014A, 0x00B60010, 0x017F002B	| 408F5920
    .long   0x002E0037, 0x005B017B, 0x017E0045, 0x00C00045	| 408F5930
    .long   0x005B017B, 0x00110000, 0xFFFF0000, 0x01B00090	| 408F5940
    .long   0x04020010, 0x014A00B6, 0x0010017F, 0x002B002E	| 408F5950
    .long   0x0037005B, 0x017B017E, 0x005100C8, 0x0051005B	| 408F5960
    .long   0x017B0023, 0x0000FFFF, 0x00000120, 0x00900400	| 408F5970
    .long   0x0010014A, 0x00B60010, 0x017F002B, 0x002E0037	| 408F5980
    .long   0x005B017B, 0x017E0057, 0x00D00057, 0x005B017B	| 408F5990
    .long   0x00470000, 0xFFFF0000, 0x00000120, 0x04FF0011	| 408F59A0
    .long   0x014A00B6, 0x0010017F, 0x002B002E, 0x0037005B	| 408F59B0
    .long   0x017B017E, 0x005B00D8, 0x005B005B, 0x017B008F	| 408F59C0
    .long   0x0000FFFF, 0x00000000, 0x024004FF, 0x00110294	| 408F59D0
    .long   0x016C0020, 0x02FF0057, 0x005D006F, 0x00B902F9	| 408F59E0
    .long   0x02FE00B8, 0x00BE00B8, 0x00B902F9, 0x011F0000	| 408F59F0
    .long   0xFFFF0000, 0x00000000, 0x00E00E0B, 0x00000602	| 408F5A00
    .long   0x00000000, 0x1C040040, 0x14000203, 0xFFFF0365	| 408F5A10
    .long   0x0730072E, 0x001C0021, 0x00560722, 0x072C0090	| 408F5A20
    .long   0x04060010, 0x014A00B6, 0x0010017F, 0x002B002E	| 408F5A30
    .long   0x0037005B, 0x017B017E, 0x004500C0, 0x0045005B	| 408F5A40
    .long   0x017B0011, 0x0000FFFF, 0x000001B0, 0x00900402	| 408F5A50
    .long   0x0010014A, 0x00B60010, 0x017F002B, 0x002E0037	| 408F5A60
    .long   0x005B017B, 0x017E0051, 0x00C80051, 0x005B017B	| 408F5A70
    .long   0x00230000, 0xFFFF0000, 0x01200090, 0x04000010	| 408F5A80
    .long   0x014A00B6, 0x0010017F, 0x002B002E, 0x0037005B	| 408F5A90
    .long   0x017B017E, 0x005700D0, 0x0057005B, 0x017B0047	| 408F5AA0
    .long   0x0000FFFF, 0x00000000, 0x012004FF, 0x0010014A	| 408F5AB0
    .long   0x00B60010, 0x017F002B, 0x002E0037, 0x005B017B	| 408F5AC0
    .long   0x017E005B, 0x00D8005B, 0x005B017B, 0x008F0000	| 408F5AD0
    .long   0xFFFF0000, 0x00000000, 0x013C0E07, 0x00000B00	| 408F5AE0
    .long   0x00000002, 0x2C0501A0, 0x7E008485, 0x04FF026F	| 408F5AF0
    .long   0x05360534, 0x00040009, 0x00520532, 0x053300D0	| 408F5B00
    .long   0x060E0010, 0x021E0120, 0x0010023F, 0x001F0025	| 408F5B10
    .long   0x0037008B, 0x022B023E, 0x005D00A0, 0x005B0089	| 408F5B20
    .long   0x0229000C, 0x0000FFFF, 0x000002D8, 0x00D00606	| 408F5B30
    .long   0x0010021E, 0x01200010, 0x023F001F, 0x00250037	| 408F5B40
    .long   0x008B022B, 0x023E0075, 0x00A80073, 0x00890229	| 408F5B50
    .long   0x00190000, 0xFFFF0000, 0x027000D0, 0x06020010	| 408F5B60
    .long   0x021E0120, 0x0010023F, 0x001F0025, 0x0037008B	| 408F5B70
    .long   0x022B023E, 0x008100B0, 0x007F0089, 0x02290033	| 408F5B80
    .long   0x0000FFFF, 0x000001A0, 0x00D00600, 0x0010021E	| 408F5B90
    .long   0x01200010, 0x023F001F, 0x00250037, 0x008B022B	| 408F5BA0
    .long   0x023E0087, 0x00B80085, 0x00890229, 0x00670000	| 408F5BB0
    .long   0xFFFF0000, 0x000001A0, 0x06FF0011, 0x021E0120	| 408F5BC0
    .long   0x0010023F, 0x001F0025, 0x00370089, 0x0229023E	| 408F5BD0
    .long   0x008800BE, 0x00890089, 0x022900CF, 0x0000FFFF	| 408F5BE0
    .long   0x00000000, 0x03400000, 0x0011043E, 0x02400020	| 408F5BF0
    .long   0x047F003F, 0x004B006F, 0x01190459, 0x047E0118	| 408F5C00
    .long   0x003C0113, 0x01130453, 0x019F0000, 0xFFFF0000	| 408F5C10
    .long   0x00000000, 0x013C0E0F, 0x00000501, 0x00000003	| 408F5C20
    .long   0x1C058190, 0x67008485, 0xFFFF01DF, 0x041A0418	| 408F5C30
    .long   0x00040009, 0x00520412, 0x04160100, 0x061E0030	| 408F5C40
    .long   0x031E01B0, 0x0020035F, 0x003F004B, 0x006F0098	| 408F5C50
    .long   0x0318035E, 0x003A0080, 0x00350093, 0x03130009	| 408F5C60
    .long   0x0000FFFF, 0x000003B0, 0x0100060E, 0x0030031E	| 408F5C70
    .long   0x01B00020, 0x035F003F, 0x004B006F, 0x00980318	| 408F5C80
    .long   0x035E006A, 0x00880065, 0x00930313, 0x00130000	| 408F5C90
    .long   0xFFFF0000, 0x03600100, 0x06060030, 0x031E01B0	| 408F5CA0
    .long   0x0020035F, 0x003F004B, 0x006F0098, 0x0318035E	| 408F5CB0
    .long   0x00820090, 0x007D0093, 0x03130027, 0x0000FFFF	| 408F5CC0
    .long   0x000002C0, 0x01000602, 0x0030031E, 0x01B00020	| 408F5CD0
    .long   0x035F003F, 0x004B006F, 0x00980318, 0x035E008E	| 408F5CE0
    .long   0x00980089, 0x00930313, 0x004F0000, 0xFFFF0000	| 408F5CF0
    .long   0x01800200, 0x06000030, 0x031E01B0, 0x0020035F	| 408F5D00
    .long   0x003F004B, 0x006F0093, 0x0313035E, 0x008F009E	| 408F5D10
    .long   0x008F0093, 0x0313009F, 0x0000FFFF, 0x00000300	| 408F5D20
    .long   0x040006FF, 0x0032031E, 0x01B00020, 0x035F003F	| 408F5D30
    .long   0x004B006F, 0x00990319, 0x035E0099, 0x009C0093	| 408F5D40
    .long   0x00930313, 0x013F0000, 0xFFFF0000, 0x06000000	| 408F5D50
    .long   0x013C0F01, 0x01000903, 0x00000002, 0x2C058130	| 408F5D60
    .long   0x3F008485, 0xFFFF01DF, 0x041A0418, 0x00020007	| 408F5D70
    .long   0x00440404, 0x04080100, 0x061E0030, 0x026E0190	| 408F5D80
    .long   0x0030031F, 0x005F006B, 0x007E0088, 0x0308031E	| 408F5D90
    .long   0x002A0080, 0x00250083, 0x03030009, 0x0000FFFF	| 408F5DA0
    .long   0x000003B0, 0x0100060E, 0x0030026E, 0x01900030	| 408F5DB0
    .long   0x031F005F, 0x006B007E, 0x00880308, 0x031E005A	| 408F5DC0
    .long   0x00880055, 0x00830303, 0x00130000, 0xFFFF0000	| 408F5DD0
    .long   0x03600100, 0x06060030, 0x026E0190, 0x0030031F	| 408F5DE0
    .long   0x005F006B, 0x007E0088, 0x0308031E, 0x00720090	| 408F5DF0
    .long   0x006D0083, 0x03030027, 0x0000FFFF, 0x000002C0	| 408F5E00
    .long   0x01000602, 0x0030026E, 0x01900030, 0x031F005F	| 408F5E10
    .long   0x006B007E, 0x00880308, 0x031E007E, 0x00980079	| 408F5E20
    .long   0x00830303, 0x004F0000, 0xFFFF0000, 0x01800200	| 408F5E30
    .long   0x06000030, 0x026E0190, 0x0030031F, 0x005F006B	| 408F5E40
    .long   0x007E0083, 0x0303031E, 0x007F009E, 0x007F0083	| 408F5E50
    .long   0x0303009F, 0x0000FFFF, 0x00000300, 0x040006FF	| 408F5E60
    .long   0x0032026E, 0x01900030, 0x031F005F, 0x006B007E	| 408F5E70
    .long   0x00890309, 0x031E0089, 0x009C0083, 0x00830303	| 408F5E80
    .long   0x013F0000, 0xFFFF0000, 0x06000000, 0x013C0C0F	| 408F5E90
    .long   0x00000302, 0x00000002, 0x1C0480A0, 0x36008485	| 408F5EA0
    .long   0x04FF0257, 0x04E804E6, 0x001A001F, 0x002804D8	| 408F5EB0
    .long   0x04DC00D0, 0x060E0030, 0x01C60100, 0x001C01FF	| 408F5EC0
    .long   0x0037003D, 0x004F0063, 0x01F301FE, 0x003500A0	| 408F5ED0
    .long   0x00320060, 0x01F00018, 0x0000FFFF, 0x000002DC	| 408F5EE0
    .long   0x00D00606, 0x003001C6, 0x0100001C, 0x01FF0037	| 408F5EF0
    .long   0x003D004F, 0x006301F3, 0x01FE004D, 0x00A8004A	| 408F5F00
    .long   0x006001F0, 0x00310000, 0xFFFF0000, 0x027800D0	| 408F5F10
    .long   0x06020030, 0x01C60100, 0x001C01FF, 0x0037003D	| 408F5F20
    .long   0x004F0063, 0x01F301FE, 0x005900B0, 0x00560060	| 408F5F30
    .long   0x01F00063, 0x0000FFFF, 0x000001B0, 0x00D00600	| 408F5F40
    .long   0x003001C6, 0x0100001C, 0x01FF0037, 0x003D004F	| 408F5F50
    .long   0x006301F3, 0x01FE005F, 0x00B8005C, 0x006001F0	| 408F5F60
    .long   0x00C70000, 0xFFFF0000, 0x002001A0, 0x06FF0031	| 408F5F70
    .long   0x01C60100, 0x001C01FF, 0x0037003D, 0x004F0060	| 408F5F80
    .long   0x01F001FE, 0x005F00BE, 0x00600060, 0x01F0018F	| 408F5F90
    .long   0x0000FFFF, 0x00000040, 0x03400000, 0x0031038C	| 408F5FA0
    .long   0x02000038, 0x03FF006F, 0x007B009F, 0x00C903E9	| 408F5FB0
    .long   0x03FE00C8, 0x003C00C3, 0x00C303E3, 0x018F0000	| 408F5FC0
    .long   0xFFFF0000, 0x00800000, 0x013C0C01, 0x02000703	| 408F5FD0
    .long   0x00000004, 0x1C05C1A0, 0x36008485, 0xFFFF017F	| 408F5FE0
    .long   0x020D020C, 0x0005000B, 0x00230203, 0x02060200	| 408F5FF0
    .long   0x061E0074, 0x014C0186, 0x001D030B, 0x0039003F	| 408F6000
    .long   0x00620072, 0x02F2030A, 0x08140080, 0x080F006D	| 408F6010
    .long   0x02ED0007, 0x00300013, 0x000203B0, 0x0200060E	| 408F6020
    .long   0x0074014C, 0x0186001D, 0x030B0039, 0x003F0062	| 408F6030
    .long   0x007202F2, 0x030A0844, 0x0088083F, 0x006D02ED	| 408F6040
    .long   0x000F0030, 0x00270004, 0x03600200, 0x06060074	| 408F6050
    .long   0x014C0186, 0x001D030B, 0x0039003F, 0x00620072	| 408F6060
    .long   0x02F2030A, 0x085C0090, 0x0857006D, 0x02ED001F	| 408F6070
    .long   0x0030004F, 0x000802C0, 0x02000602, 0x0074014C	| 408F6080
    .long   0x0186001D, 0x030B0039, 0x003F0062, 0x007202F2	| 408F6090
    .long   0x030A0868, 0x00980863, 0x006D02ED, 0x003F0030	| 408F60A0
    .long   0x009F0010, 0x01800400, 0x06000074, 0x014C0186	| 408F60B0
    .long   0x001D030B, 0x0039003F, 0x0062006D, 0x02ED030A	| 408F60C0
    .long   0x0869009E, 0x0869006D, 0x02ED007F, 0x0030013F	| 408F60D0
    .long   0x00200300, 0x080006FF, 0x0076014C, 0x0186001D	| 408F60E0
    .long   0x030B0039, 0x003F0062, 0x007302F3, 0x030A0873	| 408F60F0
    .long   0x009C086D, 0x006D02ED, 0x00FF0030, 0x027F0040	| 408F6100
    .long   0x06000000, 0x013C0C01, 0x02000703, 0x00000004	| 408F6110
    .long   0x1C05C1A0, 0x36008485, 0xFFFF01DF, 0x020D020C	| 408F6120
    .long   0x0005000B, 0x00230203, 0x02060200, 0x061E0074	| 408F6130
    .long   0x014C0186, 0x001D030B, 0x0039003F, 0x00620072	| 408F6140
    .long   0x02F2030A, 0x08140080, 0x080F006D, 0x02ED0009	| 408F6150
    .long   0x0000FFFF, 0x000003B0, 0x0200060E, 0x0074014C	| 408F6160
    .long   0x0186001D, 0x030B0039, 0x003F0062, 0x007202F2	| 408F6170
    .long   0x030A0844, 0x0088083F, 0x006D02ED, 0x00130000	| 408F6180
    .long   0xFFFF0000, 0x03600200, 0x06060074, 0x014C0186	| 408F6190
    .long   0x001D030B, 0x0039003F, 0x00620072, 0x02F2030A	| 408F61A0
    .long   0x085C0090, 0x0857006D, 0x02ED0027, 0x0000FFFF	| 408F61B0
    .long   0x000002C0, 0x02000602, 0x0074014C, 0x0186001D	| 408F61C0
    .long   0x030B0039, 0x003F0062, 0x007202F2, 0x030A0868	| 408F61D0
    .long   0x00980863, 0x006D02ED, 0x004F0000, 0xFFFF0000	| 408F61E0
    .long   0x01800400, 0x06000074, 0x014C0186, 0x001D030B	| 408F61F0
    .long   0x0039003F, 0x0062006D, 0x02ED030A, 0x0869009E	| 408F6200
    .long   0x0869006D, 0x02ED009F, 0x0000FFFF, 0x00000300	| 408F6210
    .long   0x080006FF, 0x0076014C, 0x0186001D, 0x030B0039	| 408F6220
    .long   0x003F0062, 0x007302F3, 0x030A0873, 0x009C086D	| 408F6230
    .long   0x006D02ED, 0x013F0000, 0xFFFF0000, 0x06000000	| 408F6240
    .long   0x00E00C01, 0x02000703, 0x00000002, 0x05060401	| 408F6250
    .long   0x00000303, 0xFFFF017F, 0x020D020C, 0x0005000B	| 408F6260
    .long   0x00230203, 0x02060200, 0x060E007C, 0x0298030C	| 408F6270
    .long   0x003A0617, 0x0073007F, 0x00B100BE, 0x05EC0616	| 408F6280
    .long   0x08A000A1, 0x089C00BA, 0x05BA0007, 0x00300013	| 408F6290
    .long   0x000203B0, 0x02000606, 0x007C0298, 0x030C003A	| 408F62A0
    .long   0x06170073, 0x007F00B1, 0x00D605EC, 0x061608C8	| 408F62B0
    .long   0x00A908C4, 0x00D205D2, 0x000F0030, 0x00270004	| 408F62C0
    .long   0x03600200, 0x0602007C, 0x0298030C, 0x003A0617	| 408F62D0
    .long   0x0073007F, 0x00B100E2, 0x05EC0616, 0x08DC00B1	| 408F62E0
    .long   0x08D800DE, 0x05DE001F, 0x0030004F, 0x000802C0	| 408F62F0
    .long   0x02000600, 0x007C0298, 0x030C003A, 0x06170073	| 408F6300
    .long   0x007F00B1, 0x00E805EC, 0x061608E6, 0x00B908E2	| 408F6310
    .long   0x00E405E4, 0x003F0030, 0x009F0010, 0x01800000	| 408F6320
    .long   0x00E00C01, 0x02000703, 0x00000002, 0x05060401	| 408F6330
    .long   0x00000303, 0xFFFF01DF, 0x020D020C, 0x0005000B	| 408F6340
    .long   0x00230203, 0x02060200, 0x060E007C, 0x0298030C	| 408F6350
    .long   0x003A0617, 0x0073007F, 0x00B100BE, 0x05EC0616	| 408F6360
    .long   0x08A000A1, 0x089C00BA, 0x05BA0009, 0x0000FFFF	| 408F6370
    .long   0x000003B0, 0x02000606, 0x007C0298, 0x030C003A	| 408F6380
    .long   0x06170073, 0x007F00B1, 0x00D605EC, 0x061608C8	| 408F6390
    .long   0x00A908C4, 0x00D205D2, 0x00130000, 0xFFFF0000	| 408F63A0
    .long   0x03600200, 0x0602007C, 0x0298030C, 0x003A0617	| 408F63B0
    .long   0x0073007F, 0x00B100E2, 0x05EC0616, 0x08DC00B1	| 408F63C0
    .long   0x08D800DE, 0x05DE0027, 0x0000FFFF, 0x000002C0	| 408F63D0
    .long   0x02000600, 0x007C0298, 0x030C003A, 0x06170073	| 408F63E0
    .long   0x007F00B1, 0x00E805EC, 0x061608E6, 0x00B908E2	| 408F63F0
    .long   0x00E405E4, 0x004F0000, 0xFFFF0000, 0x01800000	| 408F6400
    .long   0x013C0D09, 0x01000604, 0x00010103, 0x1C05C0A0	| 408F6410
    .long   0x6E008485, 0x04FF01DF, 0x02710270, 0x00040009	| 408F6420
    .long   0x00270267, 0x026B01A0, 0x061E0074, 0x019201D8	| 408F6430
    .long   0x002303AF, 0x00450049, 0x006D0092, 0x039203AE	| 408F6440
    .long   0x08340000, 0x082F008D, 0x038D0009, 0x00300017	| 408F6450
    .long   0x000202E0, 0x01A0060E, 0x00740192, 0x01D80023	| 408F6460
    .long   0x03AF0045, 0x0049006D, 0x00920392, 0x03AE0864	| 408F6470
    .long   0x0008085F, 0x008D038D, 0x00130030, 0x002F0004	| 408F6480
    .long   0x028001A0, 0x06060074, 0x019201D8, 0x002303AF	| 408F6490
    .long   0x00450049, 0x006D0092, 0x039203AE, 0x087C0010	| 408F64A0
    .long   0x0877008D, 0x038D0027, 0x0030005F, 0x000801C0	| 408F64B0
    .long   0x01A00602, 0x00740192, 0x01D80023, 0x03AF0045	| 408F64C0
    .long   0x0049006D, 0x00920392, 0x03AE0888, 0x00180883	| 408F64D0
    .long   0x008D038D, 0x004F0030, 0x00BF0010, 0x00400340	| 408F64E0
    .long   0x06000075, 0x019201D8, 0x002303AF, 0x00450049	| 408F64F0
    .long   0x006D008D, 0x038D03AE, 0x0887001E, 0x0888008D	| 408F6500
    .long   0x038D009F, 0x0030017F, 0x00200080, 0x068006FF	| 408F6510
    .long   0x00750192, 0x01D80023, 0x03AF0045, 0x0049006D	| 408F6520
    .long   0x00930393, 0x03AE0892, 0x001C088C, 0x008D038D	| 408F6530
    .long   0x013F0030, 0x02FF0040, 0x01000000, 0x013C0D09	| 408F6540
    .long   0x01000604, 0x00010103, 0x1C05C0A0, 0x6E008485	| 408F6550
    .long   0x04FF023F, 0x02710270, 0x00040009, 0x00270267	| 408F6560
    .long   0x026B01A0, 0x061E0074, 0x019201D8, 0x002303AF	| 408F6570
    .long   0x00450049, 0x006D0092, 0x039203AE, 0x08340000	| 408F6580
    .long   0x082F008D, 0x038D000B, 0x0000FFFF, 0x000002E0	| 408F6590
    .long   0x01A0060E, 0x00740192, 0x01D80023, 0x03AF0045	| 408F65A0
    .long   0x0049006D, 0x00920392, 0x03AE0864, 0x0008085F	| 408F65B0
    .long   0x008D038D, 0x00170000, 0xFFFF0000, 0x028001A0	| 408F65C0
    .long   0x06060074, 0x019201D8, 0x002303AF, 0x00450049	| 408F65D0
    .long   0x006D0092, 0x039203AE, 0x087C0010, 0x0877008D	| 408F65E0
    .long   0x038D002F, 0x0000FFFF, 0x000001C0, 0x01A00602	| 408F65F0
    .long   0x00740192, 0x01D80023, 0x03AF0045, 0x0049006D	| 408F6600
    .long   0x00920392, 0x03AE0888, 0x00180883, 0x008D038D	| 408F6610
    .long   0x005F0000, 0xFFFF0000, 0x00400340, 0x06000075	| 408F6620
    .long   0x019201D8, 0x002303AF, 0x00450049, 0x006D008D	| 408F6630
    .long   0x038D03AE, 0x0887001E, 0x0888008D, 0x038D00BF	| 408F6640
    .long   0x0000FFFF, 0x00000080, 0x068006FF, 0x00750192	| 408F6650
    .long   0x01D80023, 0x03AF0045, 0x0049006D, 0x00930393	| 408F6660
    .long   0x03AE0892, 0x001C088C, 0x008D038D, 0x017F0000	| 408F6670
    .long   0xFFFF0000, 0x01000000, 0x00E00D09, 0x01000604	| 408F6680
    .long   0x00010101, 0x05060001, 0x00000303, 0xFFFF01DF	| 408F6690
    .long   0x02710270, 0x00040009, 0x00270267, 0x026B0200	| 408F66A0
    .long   0x060E007C, 0x032403B0, 0x0046075F, 0x008B0093	| 408F66B0
    .long   0x00DB00FE, 0x072C075E, 0x08E00021, 0x08DC00FA	| 408F66C0
    .long   0x06FA0009, 0x00300017, 0x000203A0, 0x02000606	| 408F66D0
    .long   0x007C0324, 0x03B00046, 0x075F008B, 0x009300DB	| 408F66E0
    .long   0x0116072C, 0x075E0908, 0x00290904, 0x01120712	| 408F66F0
    .long   0x00130030, 0x002F0004, 0x03400200, 0x0602007C	| 408F6700
    .long   0x032403B0, 0x0046075F, 0x008B0093, 0x00DB0122	| 408F6710
    .long   0x072C075E, 0x091C0031, 0x0918011E, 0x071E0027	| 408F6720
    .long   0x0030005F, 0x00080280, 0x02000600, 0x007C0324	| 408F6730
    .long   0x03B00046, 0x075F008B, 0x009300DB, 0x0128072C	| 408F6740
    .long   0x075E0926, 0x00390922, 0x01240724, 0x004F0030	| 408F6750
    .long   0x00BF0010, 0x01000000, 0x00E00D09, 0x01000604	| 408F6760
    .long   0x00010101, 0x05060001, 0x00000303, 0xFFFF023F	| 408F6770
    .long   0x02710270, 0x00040009, 0x00270267, 0x026B0200	| 408F6780
    .long   0x060E007C, 0x032403B0, 0x0046075F, 0x008B0093	| 408F6790
    .long   0x00DB00FE, 0x072C075E, 0x08E00021, 0x08DC00FA	| 408F67A0
    .long   0x06FA000B, 0x0000FFFF, 0x000003A0, 0x02000606	| 408F67B0
    .long   0x007C0324, 0x03B00046, 0x075F008B, 0x009300DB	| 408F67C0
    .long   0x0116072C, 0x075E0908, 0x00290904, 0x01120712	| 408F67D0
    .long   0x00170000, 0xFFFF0000, 0x03400200, 0x0602007C	| 408F67E0
    .long   0x032403B0, 0x0046075F, 0x008B0093, 0x00DB0122	| 408F67F0
    .long   0x072C075E, 0x091C0031, 0x0918011E, 0x071E002F	| 408F6800
    .long   0x0000FFFF, 0x00000280, 0x02000600, 0x007C0324	| 408F6810
    .long   0x03B00046, 0x075F008B, 0x009300DB, 0x0128072C	| 408F6820
    .long   0x075E0926, 0x00390922, 0x01240724, 0x005F0000	| 408F6830
    .long   0xFFFF0000, 0x01000000, 0x001C351D, 0x0100351D	| 408F6840
    .long   0x01000100, 0x81828300, 0x03650013, 0x0027004F	| 408F6850
    .long   0x009F0000, 0x001E2C2C, 0x02000000, 0x02000200	| 408F6860
    .long   0x83848400, 0x017F000F, 0x001F003F, 0x007F00FF	| 408F6870
    .long   0x0000001E, 0x2C280200, 0x36310200, 0x0A008384	| 408F6880
    .long   0x8400017F, 0x00100022, 0x0045008B, 0x01170000	| 408F6890
    .long   0x001E3739, 0x01003739, 0x01000600, 0x82838400	| 408F68A0
    .long   0x01DF0013, 0x0027004F, 0x009F013F, 0x0000001E	| 408F68B0
    .long   0x37390100, 0x37390100, 0x0D008384, 0x8400018F	| 408F68C0
    .long   0x00130027, 0x004F009F, 0x013F0000, 0x001E2D1C	| 408F68D0
    .long   0x02003521, 0x02000B00, 0x82838400, 0x01DF0013	| 408F68E0
    .long   0x0027004F, 0x009F013F, 0x0000001C, 0x351D0100	| 408F68F0
    .long   0x351D0100, 0x09008183, 0x8300026F, 0x00190033	| 408F6900
    .long   0x006700CF	| 408F6910
DECL_SR7E_8A_Video_Sonora_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xD4	| 408F6914 s24 -> DECL_SR7E_8A_Video_Sonora_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6918
    .long   0xFF000000	| 408F6920
DECL_SR7E_8D_Video_Sonora_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xF2	| 408F6924 s24 -> DECL_SR7E_8D_Video_Sonora_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6928
    .long   0xFF000000	| 408F6930
DECL_SR7E_80_Video_Sonora_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x10	| 408F6934 s24 -> DECL_SR7E_80_Video_Sonora_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6938
    .long   0xFF000000	| 408F6940
DECL_SR7E_83_Video_Sonora_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x2E	| 408F6944 s24 -> DECL_SR7E_83_Video_Sonora_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6948
    .long   0xFF000000	| 408F6950
DECL_SR7E_85_Video_Sonora_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x4C	| 408F6954 s24 -> DECL_SR7E_85_Video_Sonora_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6958
    .long   0xFF000000	| 408F6960
DECL_SR7E_92_Video_Sonora_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x6A	| 408F6964 s24 -> DECL_SR7E_92_Video_Sonora_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6968
    .long   0xFF000000	| 408F6970
DECL_SR7F_87_Video_RBV1_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x88	| 408F6974 s24 -> DECL_SR7F_87_Video_RBV1_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6978
    .long   0xFF000000	| 408F6980
DECL_SR7F_A3_Video_V8_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xA6	| 408F6984 s24 -> DECL_SR7F_A3_Video_V8_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6988
    .long   0xFF000000	| 408F6990
DECL_SR7F_AB_Video_V8_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xC4	| 408F6994 s24 -> DECL_SR7F_AB_Video_V8_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6998
    .long   0xFF000000	| 408F69A0
DECL_SR7F_A2_Video_V8_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xE2	| 408F69A4 s24 -> DECL_SR7F_A2_Video_V8_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F69A8
    .long   0xFF000000	| 408F69B0
DECL_SR7F_AA_Video_V8_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x00	| 408F69B4 s24 -> DECL_SR7F_AA_Video_V8_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F69B8
    .long   0xFF000000	| 408F69C0
DECL_SR7F_B2_Video_V8_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x1E	| 408F69C4 s24 -> DECL_SR7F_B2_Video_V8_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F69C8
    .long   0xFF000000	| 408F69D0
DECL_SR7F_BA_Video_V8_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x0E	| 408F69D4 s24 -> DECL_SR7F_B2_Video_V8_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F69D8
    .long   0xFF000000	| 408F69E0
DECL_SR7F_BE_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x2C	| 408F69E4 s24 -> DECL_SR7F_BE_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F69E8
    .long   0xFF000000	| 408F69F0
DECL_SR7F_C0_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x4A	| 408F69F4 s24 -> DECL_SR7F_C0_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F69F8
    .long   0xFF000000	| 408F6A00
DECL_SR7F_C4_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x68	| 408F6A04 s24 -> DECL_SR7F_C4_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A08
    .long   0xFF000000	| 408F6A10
DECL_SR7F_C6_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x86	| 408F6A14 s24 -> DECL_SR7F_C6_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A18
    .long   0xFF000000	| 408F6A20
DECL_SR7F_C2_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x62	| 408F6A24 s24 -> DECL_SR7F_A2_Video_V8_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A28
    .long   0xFF000000	| 408F6A30
DECL_SR7F_C8_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xF6	| 408F6A34 s24 -> DECL_SR7F_A3_Video_V8_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A38
    .long   0xFF000000	| 408F6A40
DECL_SR7F_E8_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x84	| 408F6A44 s24 -> DECL_SR7F_E8_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A48
    .long   0xFF000000	| 408F6A50
DECL_SR7F_D0_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xA2	| 408F6A54 s24 -> DECL_SR7F_D0_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A58
    .long   0xFF000000	| 408F6A60
DECL_SR7F_D4_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xC0	| 408F6A64 s24 -> DECL_SR7F_D4_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A68
    .long   0xFF000000	| 408F6A70
DECL_SR7F_DC_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x0C	| 408F6A74 s24 -> DECL_SR7F_DC_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A78
    .long   0xFF000000	| 408F6A80
DECL_SR7F_D6_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xCE	| 408F6A84 s24 -> DECL_SR7F_D6_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A88
    .long   0xFF000000	| 408F6A90
DECL_SR7F_DE_Video_DAFB_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x1A	| 408F6A94 s24 -> DECL_SR7F_DE_Video_DAFB_OneBitMode_mVidParams_data
    .long   0x03000001, 0x04000000	| 408F6A98
    .long   0xFF000000	| 408F6AA0
DECL_SR7F_BC_Video_DBLite_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x38	| 408F6AA4 s24 -> DECL_SR7F_BC_Video_DBLite_OneBitMode_mVidParams_data
DECL_SR7F_BC_Video_DBLite_OneBitMode_mTable_entry:  /* entry mTable (2): the mode's default colour table */
    .byte   0x02, 0x00, 0x00, 0x24	| 408F6AA8 s24 -> DECL_SR7F_BB_Video_DBLite_OneBitMode_mTable_data
    .long   0x03000001	| 408F6AAC
    .long   0x04000001, 0xFF000000	| 408F6AB0
DECL_SR7F_BB_Video_DBLite_OneBitMode:  /* the OneBitMode (128) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x52	| 408F6AB8 s24 -> DECL_SR7F_BB_Video_DBLite_OneBitMode_mVidParams_data
DECL_SR7F_BB_Video_DBLite_OneBitMode_mTable_entry:  /* entry mTable (2): the mode's default colour table */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F6ABC s24 -> DECL_SR7F_BB_Video_DBLite_OneBitMode_mTable_data
    .long   0x03000001, 0x04000001, 0xFF000000	| 408F6AC0
DECL_SR7F_BB_Video_DBLite_OneBitMode_mTable_data:  /* data of mTable (2) */
    .long   0x0000001C	| 408F6ACC
    .long   0x00000021, 0x00000001, 0x0000FFFF, 0xFFFFFFFF	| 408F6AD0
    .long   0x00010000, 0x00000000	| 408F6AE0
DECL_SR7E_8A_Video_Sonora_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F6AE8
    .long   0x00500000, 0x000001E0, 0x02800000, 0x00000000	| 408F6AF0
    .long   0x00000048, 0x00000048, 0x00000000, 0x00010001	| 408F6B00
    .short  0x0001, 0x0000, 0x0000	| 408F6B10
DECL_SR7E_8D_Video_Sonora_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0050	| 408F6B16
    .long   0x00000000, 0x01900280, 0x00000000, 0x00000000	| 408F6B20
    .long   0x00480000, 0x00480000, 0x00000001, 0x00010001	| 408F6B30
    .long   0x00000000	| 408F6B40
DECL_SR7E_80_Video_Sonora_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x00500000	| 408F6B44
    .long   0x00000366, 0x02800000, 0x00000000, 0x00000050	| 408F6B50
    .long   0x00000050, 0x00000000, 0x00010001, 0x00010000	| 408F6B60
    .short  0x0000	| 408F6B70
DECL_SR7E_83_Video_Sonora_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0040, 0x0000, 0x0000	| 408F6B72
    .long   0x01800200, 0x00000000, 0x00000000, 0x00480000	| 408F6B80
    .long   0x00480000, 0x00000001, 0x00010001, 0x00000000	| 408F6B90
DECL_SR7E_85_Video_Sonora_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x00460000, 0x00000180	| 408F6BA0
    .long   0x02300000, 0x00000000, 0x00000048, 0x00000048	| 408F6BB0
    .short  0x0000, 0x0000, 0x0001, 0x0001, 0x0001, 0x0000, 0x0000	| 408F6BC0
DECL_SR7E_92_Video_Sonora_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F6BCE
    .long   0x002E0000, 0x00000068, 0x00000000, 0x02700340	| 408F6BD0
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F6BE0
    .long   0x00000001, 0x00010001, 0x00000000	| 408F6BF0
DECL_SR7F_87_Video_RBV1_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F6BFC
    .long   0x00000000, 0x00400000, 0x00000156, 0x02000000	| 408F6C00
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F6C10
    .short  0x0001, 0x0001, 0x0001, 0x0000, 0x0000	| 408F6C20
DECL_SR7F_A3_Video_V8_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F6C2A
    .long   0x00000400, 0x00000000, 0x01E00280, 0x00000000	| 408F6C30
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000001	| 408F6C40
    .long   0x00010001, 0x00000000	| 408F6C50
DECL_SR7F_AB_Video_V8_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F6C58
    .long   0x02000000, 0x000001E0, 0x02800000, 0x00000000	| 408F6C60
    .long   0x00000048, 0x00000048, 0x00000000, 0x00010001	| 408F6C70
    .short  0x0001, 0x0000, 0x0000	| 408F6C80
DECL_SR7F_A2_Video_V8_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0400	| 408F6C86
    .long   0x00000000, 0x01800200, 0x00000000, 0x00000000	| 408F6C90
    .long   0x00480000, 0x00480000, 0x00000001, 0x00010001	| 408F6CA0
    .long   0x00000000	| 408F6CB0
DECL_SR7F_AA_Video_V8_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x02000000	| 408F6CB4
    .long   0x00000180, 0x02000000, 0x00000000, 0x00000048	| 408F6CC0
    .long   0x00000048, 0x00000000, 0x00010001, 0x00010000	| 408F6CD0
    .short  0x0000	| 408F6CE0
DECL_SR7F_B2_Video_V8_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0200, 0x0000, 0x0000	| 408F6CE2
    .long   0x01800230, 0x00000000, 0x00000000, 0x00480000	| 408F6CF0
    .long   0x00480000, 0x00000001, 0x00010001, 0x00000000	| 408F6D00
DECL_SR7F_BE_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x02000000, 0x00000300	| 408F6D10
    .long   0x04000000, 0x00000000, 0x00000048, 0x00000048	| 408F6D20
    .short  0x0000, 0x0000, 0x0001, 0x0001, 0x0001, 0x0000, 0x0000	| 408F6D30
DECL_SR7F_C0_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F6D3E
    .long   0x002E0000, 0x00000200, 0x00000000, 0x03660280	| 408F6D40
    .long   0x00000000, 0x00000000, 0x00500000, 0x00500000	| 408F6D50
    .long   0x00000001, 0x00010001, 0x00000000	| 408F6D60
DECL_SR7F_C4_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F6D6C
    .long   0x00000000, 0x02400000, 0x00000366, 0x04800000	| 408F6D70
    .long   0x00000000, 0x0000004D, 0x0000004D, 0x00000000	| 408F6D80
    .short  0x0001, 0x0001, 0x0001, 0x0000, 0x0000	| 408F6D90
DECL_SR7F_C6_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F6D9A
    .long   0x00000340, 0x00000000, 0x02700340, 0x00000000	| 408F6DA0
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000001	| 408F6DB0
    .long   0x00010001, 0x00000000	| 408F6DC0
DECL_SR7F_E8_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F6DC8
    .long   0x03400000, 0x00000258, 0x03200000, 0x00000000	| 408F6DD0
    .long   0x00000048, 0x00000048, 0x00000000, 0x00010001	| 408F6DE0
    .short  0x0001, 0x0000, 0x0000	| 408F6DF0
DECL_SR7F_D0_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0xC008, 0x0400	| 408F6DF6
    .long   0x00000000, 0x01800200, 0x00000000, 0x00000000	| 408F6E00
    .long   0x00480000, 0x00480000, 0x00000001, 0x00010001	| 408F6E10
    .long   0x00000000	| 408F6E20
DECL_SR7F_D4_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00009C08, 0x03400000	| 408F6E24
    .long   0x000001E0, 0x02800000, 0x00000000, 0x00000048	| 408F6E30
    .long   0x00000048, 0x00000000, 0x00010001, 0x00010000	| 408F6E40
    .short  0x0000	| 408F6E50
DECL_SR7F_D6_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0340, 0x0000, 0x0000	| 408F6E52
    .long   0x02400300, 0x00000000, 0x00000000, 0x00480000	| 408F6E60
    .long   0x00480000, 0x00000001, 0x00010001, 0x00000000	| 408F6E70
DECL_SR7F_DC_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x0000C008, 0x04000000, 0x000001E0	| 408F6E80
    .long   0x02800000, 0x00000000, 0x00000048, 0x00000048	| 408F6E90
    .short  0x0000, 0x0000, 0x0001, 0x0001, 0x0001, 0x0000, 0x0000	| 408F6EA0
DECL_SR7F_DE_Video_DAFB_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F6EAE
    .long   0x002E0000, 0x00000400, 0x00000000, 0x02400300	| 408F6EB0
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F6EC0
    .long   0x00000001, 0x00010001, 0x00000000	| 408F6ED0
DECL_SR7F_BC_Video_DBLite_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F6EDC
    .long   0x00000000, 0x00500000, 0x00000190, 0x02800000	| 408F6EE0
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F6EF0
    .short  0x0001, 0x0001, 0x0001, 0x0000, 0x0000	| 408F6F00
DECL_SR7F_BB_Video_DBLite_OneBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F6F0A
    .long   0x00000050, 0x00000000, 0x01E00280, 0x00000000	| 408F6F10
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000001	| 408F6F20
    .long   0x00010001, 0x00000000	| 408F6F30
DECL_SR7E_8A_Video_Sonora_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xE4	| 408F6F38 s24 -> DECL_SR7E_8A_Video_Sonora_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6F3C
    .long   0x04000000, 0xFF000000	| 408F6F40
DECL_SR7E_8D_Video_Sonora_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x02	| 408F6F48 s24 -> DECL_SR7E_8D_Video_Sonora_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6F4C
    .long   0x04000000, 0xFF000000	| 408F6F50
DECL_SR7E_80_Video_Sonora_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x20	| 408F6F58 s24 -> DECL_SR7E_80_Video_Sonora_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6F5C
    .long   0x04000000, 0xFF000000	| 408F6F60
DECL_SR7E_83_Video_Sonora_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x3E	| 408F6F68 s24 -> DECL_SR7E_83_Video_Sonora_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6F6C
    .long   0x04000000, 0xFF000000	| 408F6F70
DECL_SR7E_85_Video_Sonora_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x5C	| 408F6F78 s24 -> DECL_SR7E_85_Video_Sonora_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6F7C
    .long   0x04000000, 0xFF000000	| 408F6F80
DECL_SR7E_92_Video_Sonora_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x7A	| 408F6F88 s24 -> DECL_SR7E_92_Video_Sonora_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6F8C
    .long   0x04000000, 0xFF000000	| 408F6F90
DECL_SR7F_87_Video_RBV1_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x98	| 408F6F98 s24 -> DECL_SR7F_87_Video_RBV1_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6F9C
    .long   0x04000000, 0xFF000000	| 408F6FA0
DECL_SR7F_A3_Video_V8_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xB6	| 408F6FA8 s24 -> DECL_SR7F_A3_Video_V8_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6FAC
    .long   0x04000000, 0xFF000000	| 408F6FB0
DECL_SR7F_AB_Video_V8_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xD4	| 408F6FB8 s24 -> DECL_SR7F_AB_Video_V8_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6FBC
    .long   0x04000000, 0xFF000000	| 408F6FC0
DECL_SR7F_A2_Video_V8_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xF2	| 408F6FC8 s24 -> DECL_SR7F_A2_Video_V8_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6FCC
    .long   0x04000000, 0xFF000000	| 408F6FD0
DECL_SR7F_AA_Video_V8_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x10	| 408F6FD8 s24 -> DECL_SR7F_AA_Video_V8_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6FDC
    .long   0x04000000, 0xFF000000	| 408F6FE0
DECL_SR7F_B2_Video_V8_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x2E	| 408F6FE8 s24 -> DECL_SR7F_B2_Video_V8_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6FEC
    .long   0x04000000, 0xFF000000	| 408F6FF0
DECL_SR7F_BA_Video_V8_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x4C	| 408F6FF8 s24 -> DECL_SR7F_BA_Video_V8_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F6FFC
    .long   0x04000000, 0xFF000000	| 408F7000
DECL_SR7F_BE_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x6A	| 408F7008 s24 -> DECL_SR7F_BE_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F700C
    .long   0x04000000, 0xFF000000	| 408F7010
DECL_SR7F_C0_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x88	| 408F7018 s24 -> DECL_SR7F_C0_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F701C
    .long   0x04000000, 0xFF000000	| 408F7020
DECL_SR7F_C4_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xA6	| 408F7028 s24 -> DECL_SR7F_C4_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F702C
    .long   0x04000000, 0xFF000000	| 408F7030
DECL_SR7F_C6_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xC4	| 408F7038 s24 -> DECL_SR7F_C6_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F703C
    .long   0x04000000, 0xFF000000	| 408F7040
DECL_SR7F_C2_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x72	| 408F7048 s24 -> DECL_SR7F_A2_Video_V8_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F704C
    .long   0x04000000, 0xFF000000	| 408F7050
DECL_SR7F_C8_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x06	| 408F7058 s24 -> DECL_SR7F_A3_Video_V8_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F705C
    .long   0x04000000, 0xFF000000	| 408F7060
DECL_SR7F_E8_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xC2	| 408F7068 s24 -> DECL_SR7F_E8_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F706C
    .long   0x04000000, 0xFF000000	| 408F7070
DECL_SR7F_D0_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xE0	| 408F7078 s24 -> DECL_SR7F_D0_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F707C
    .long   0x04000000, 0xFF000000	| 408F7080
DECL_SR7F_D4_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xFE	| 408F7088 s24 -> DECL_SR7F_D4_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F708C
    .long   0x04000000, 0xFF000000	| 408F7090
DECL_SR7F_DC_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x4A	| 408F7098 s24 -> DECL_SR7F_DC_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F709C
    .long   0x04000000, 0xFF000000	| 408F70A0
DECL_SR7F_D6_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x0C	| 408F70A8 s24 -> DECL_SR7F_D6_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F70AC
    .long   0x04000000, 0xFF000000	| 408F70B0
DECL_SR7F_DE_Video_DAFB_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x58	| 408F70B8 s24 -> DECL_SR7F_DE_Video_DAFB_TwoBitMode_mVidParams_data
    .long   0x03000001	| 408F70BC
    .long   0x04000000, 0xFF000000	| 408F70C0
DECL_SR7F_BC_Video_DBLite_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x76	| 408F70C8 s24 -> DECL_SR7F_BC_Video_DBLite_TwoBitMode_mVidParams_data
DECL_SR7F_BC_Video_DBLite_TwoBitMode_mTable_entry:  /* entry mTable (2): the mode's default colour table */
    .byte   0x02, 0x00, 0x00, 0x24	| 408F70CC s24 -> DECL_SR7F_BB_Video_DBLite_TwoBitMode_mTable_data
    .long   0x03000001, 0x04000001, 0xFF000000	| 408F70D0
DECL_SR7F_BB_Video_DBLite_TwoBitMode:  /* the TwoBitMode (129) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x90	| 408F70DC s24 -> DECL_SR7F_BB_Video_DBLite_TwoBitMode_mVidParams_data
DECL_SR7F_BB_Video_DBLite_TwoBitMode_mTable_entry:  /* entry mTable (2): the mode's default colour table */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F70E0 s24 -> DECL_SR7F_BB_Video_DBLite_TwoBitMode_mTable_data
    .long   0x03000001, 0x04000001, 0xFF000000	| 408F70E4
DECL_SR7F_BB_Video_DBLite_TwoBitMode_mTable_data:  /* data of mTable (2) */
    .long   0x0000002C, 0x00000022, 0x00000003, 0x0000FFFF	| 408F70F0
    .long   0xFFFFFFFF, 0x0001AAAA, 0xAAAAAAAA, 0x00025555	| 408F7100
    .long   0x55555555, 0x00030000, 0x00000000	| 408F7110
DECL_SR7E_8A_Video_Sonora_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F711C
    .long   0x00000000, 0x00A00000, 0x000001E0, 0x02800000	| 408F7120
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F7130
    .short  0x0002, 0x0001, 0x0002, 0x0000, 0x0000	| 408F7140
DECL_SR7E_8D_Video_Sonora_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F714A
    .long   0x000000A0, 0x00000000, 0x01900280, 0x00000000	| 408F7150
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000002	| 408F7160
    .long   0x00010002, 0x00000000	| 408F7170
DECL_SR7E_80_Video_Sonora_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F7178
    .long   0x00A00000, 0x00000366, 0x02800000, 0x00000000	| 408F7180
    .long   0x00000050, 0x00000050, 0x00000000, 0x00020001	| 408F7190
    .short  0x0002, 0x0000, 0x0000	| 408F71A0
DECL_SR7E_83_Video_Sonora_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0080	| 408F71A6
    .long   0x00000000, 0x01800200, 0x00000000, 0x00000000	| 408F71B0
    .long   0x00480000, 0x00480000, 0x00000002, 0x00010002	| 408F71C0
    .long   0x00000000	| 408F71D0
DECL_SR7E_85_Video_Sonora_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x008C0000	| 408F71D4
    .long   0x00000180, 0x02300000, 0x00000000, 0x00000048	| 408F71E0
    .long   0x00000048, 0x00000000, 0x00020001, 0x00020000	| 408F71F0
    .short  0x0000	| 408F7200
DECL_SR7E_92_Video_Sonora_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x00D0, 0x0000, 0x0000	| 408F7202
    .long   0x02700340, 0x00000000, 0x00000000, 0x00480000	| 408F7210
    .long   0x00480000, 0x00000002, 0x00010002, 0x00000000	| 408F7220
DECL_SR7F_87_Video_RBV1_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x00800000, 0x00000156	| 408F7230
    .long   0x02000000, 0x00000000, 0x00000048, 0x00000048	| 408F7240
    .short  0x0000, 0x0000, 0x0002, 0x0001, 0x0002, 0x0000, 0x0000	| 408F7250
DECL_SR7F_A3_Video_V8_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F725E
    .long   0x002E0000, 0x00000400, 0x00000000, 0x01E00280	| 408F7260
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F7270
    .long   0x00000002, 0x00010002, 0x00000000	| 408F7280
DECL_SR7F_AB_Video_V8_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F728C
    .long   0x00000000, 0x02000000, 0x000001E0, 0x02800000	| 408F7290
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F72A0
    .short  0x0002, 0x0001, 0x0002, 0x0000, 0x0000	| 408F72B0
DECL_SR7F_A2_Video_V8_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F72BA
    .long   0x00000400, 0x00000000, 0x01800200, 0x00000000	| 408F72C0
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000002	| 408F72D0
    .long   0x00010002, 0x00000000	| 408F72E0
DECL_SR7F_AA_Video_V8_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F72E8
    .long   0x02000000, 0x00000180, 0x02000000, 0x00000000	| 408F72F0
    .long   0x00000048, 0x00000048, 0x00000000, 0x00020001	| 408F7300
    .short  0x0002, 0x0000, 0x0000	| 408F7310
DECL_SR7F_B2_Video_V8_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0400	| 408F7316
    .long   0x00000000, 0x01800230, 0x00000000, 0x00000000	| 408F7320
    .long   0x00480000, 0x00480000, 0x00000002, 0x00010002	| 408F7330
    .long   0x00000000	| 408F7340
DECL_SR7F_BA_Video_V8_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x02000000	| 408F7344
    .long   0x00000180, 0x02300000, 0x00000000, 0x00000048	| 408F7350
    .long   0x00000048, 0x00000000, 0x00020001, 0x00020000	| 408F7360
    .short  0x0000	| 408F7370
DECL_SR7F_BE_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0200, 0x0000, 0x0000	| 408F7372
    .long   0x03000400, 0x00000000, 0x00000000, 0x00480000	| 408F7380
    .long   0x00480000, 0x00000002, 0x00010002, 0x00000000	| 408F7390
DECL_SR7F_C0_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x02000000, 0x00000366	| 408F73A0
    .long   0x02800000, 0x00000000, 0x00000050, 0x00000050	| 408F73B0
    .short  0x0000, 0x0000, 0x0002, 0x0001, 0x0002, 0x0000, 0x0000	| 408F73C0
DECL_SR7F_C4_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F73CE
    .long   0x002E0000, 0x00000240, 0x00000000, 0x03660480	| 408F73D0
    .long   0x00000000, 0x00000000, 0x004D0000, 0x004D0000	| 408F73E0
    .long   0x00000002, 0x00010002, 0x00000000	| 408F73F0
DECL_SR7F_C6_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F73FC
    .long   0x00000000, 0x03400000, 0x00000270, 0x03400000	| 408F7400
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F7410
    .short  0x0002, 0x0001, 0x0002, 0x0000, 0x0000	| 408F7420
DECL_SR7F_E8_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F742A
    .long   0x00000340, 0x00000000, 0x02580320, 0x00000000	| 408F7430
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000002	| 408F7440
    .long   0x00010002, 0x00000000	| 408F7450
DECL_SR7F_D0_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x0000C010	| 408F7458
    .long   0x04000000, 0x00000180, 0x02000000, 0x00000000	| 408F7460
    .long   0x00000048, 0x00000048, 0x00000000, 0x00020001	| 408F7470
    .short  0x0002, 0x0000, 0x0000	| 408F7480
DECL_SR7F_D4_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x9C10, 0x0340	| 408F7486
    .long   0x00000000, 0x01E00280, 0x00000000, 0x00000000	| 408F7490
    .long   0x00480000, 0x00480000, 0x00000002, 0x00010002	| 408F74A0
    .long   0x00000000	| 408F74B0
DECL_SR7F_D6_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x03400000	| 408F74B4
    .long   0x00000240, 0x03000000, 0x00000000, 0x00000048	| 408F74C0
    .long   0x00000048, 0x00000000, 0x00020001, 0x00020000	| 408F74D0
    .short  0x0000	| 408F74E0
DECL_SR7F_DC_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0xC010, 0x0400, 0x0000, 0x0000	| 408F74E2
    .long   0x01E00280, 0x00000000, 0x00000000, 0x00480000	| 408F74F0
    .long   0x00480000, 0x00000002, 0x00010002, 0x00000000	| 408F7500
DECL_SR7F_DE_Video_DAFB_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x04000000, 0x00000240	| 408F7510
    .long   0x03000000, 0x00000000, 0x00000048, 0x00000048	| 408F7520
    .short  0x0000, 0x0000, 0x0002, 0x0001, 0x0002, 0x0000, 0x0000	| 408F7530
DECL_SR7F_BC_Video_DBLite_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F753E
    .long   0x002E0000, 0x000000A0, 0x00000000, 0x01900280	| 408F7540
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F7550
    .long   0x00000002, 0x00010002, 0x00000000	| 408F7560
DECL_SR7F_BB_Video_DBLite_TwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F756C
    .long   0x00000000, 0x00A00000, 0x000001E0, 0x02800000	| 408F7570
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F7580
    .short  0x0002, 0x0001, 0x0002, 0x0000, 0x0000	| 408F7590
DECL_SR7E_8A_Video_Sonora_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x44	| 408F759A s24 -> DECL_SR7E_8A_Video_Sonora_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F759E
DECL_SR7E_8D_Video_Sonora_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x62	| 408F75AA s24 -> DECL_SR7E_8D_Video_Sonora_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F75AE
DECL_SR7E_81_Video_Sonora_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x80	| 408F75BA s24 -> DECL_SR7E_81_Video_Sonora_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F75BE
DECL_SR7E_83_Video_Sonora_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x9E	| 408F75CA s24 -> DECL_SR7E_83_Video_Sonora_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F75CE
DECL_SR7E_85_Video_Sonora_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xBC	| 408F75DA s24 -> DECL_SR7E_85_Video_Sonora_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F75DE
DECL_SR7E_93_Video_Sonora_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xDA	| 408F75EA s24 -> DECL_SR7E_93_Video_Sonora_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F75EE
DECL_SR7F_87_Video_RBV1_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xF8	| 408F75FA s24 -> DECL_SR7F_87_Video_RBV1_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F75FE
DECL_SR7F_A3_Video_V8_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x16	| 408F760A s24 -> DECL_SR7F_A3_Video_V8_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F760E
DECL_SR7F_AB_Video_V8_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x34	| 408F761A s24 -> DECL_SR7F_AB_Video_V8_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F761E
DECL_SR7F_A2_Video_V8_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x52	| 408F762A s24 -> DECL_SR7F_A2_Video_V8_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F762E
DECL_SR7F_AA_Video_V8_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x70	| 408F763A s24 -> DECL_SR7F_AA_Video_V8_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F763E
DECL_SR7F_B2_Video_V8_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x8E	| 408F764A s24 -> DECL_SR7F_B2_Video_V8_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F764E
DECL_SR7F_BA_Video_V8_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xAC	| 408F765A s24 -> DECL_SR7F_BA_Video_V8_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F765E
DECL_SR7F_BE_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xCA	| 408F766A s24 -> DECL_SR7F_BE_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F766E
DECL_SR7F_C0_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xE8	| 408F767A s24 -> DECL_SR7F_C0_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F767E
DECL_SR7F_C4_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x06	| 408F768A s24 -> DECL_SR7F_C4_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F768E
DECL_SR7F_C6_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x24	| 408F769A s24 -> DECL_SR7F_C6_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F769E
DECL_SR7F_C2_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xD2	| 408F76AA s24 -> DECL_SR7F_A2_Video_V8_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F76AE
DECL_SR7F_C8_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x66	| 408F76BA s24 -> DECL_SR7F_A3_Video_V8_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F76BE
DECL_SR7F_E8_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x22	| 408F76CA s24 -> DECL_SR7F_E8_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F76CE
DECL_SR7F_D0_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x40	| 408F76DA s24 -> DECL_SR7F_D0_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F76DE
DECL_SR7F_D4_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x5E	| 408F76EA s24 -> DECL_SR7F_D4_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F76EE
DECL_SR7F_DC_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0xAA	| 408F76FA s24 -> DECL_SR7F_DC_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F76FE
DECL_SR7F_D6_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0x6C	| 408F770A s24 -> DECL_SR7F_D6_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F770E
DECL_SR7F_DE_Video_DAFB_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0xB8	| 408F771A s24 -> DECL_SR7F_DE_Video_DAFB_FourBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 408F771E
DECL_SR7F_BC_Video_DBLite_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0xD6	| 408F772A s24 -> DECL_SR7F_BC_Video_DBLite_FourBitMode_mVidParams_data
DECL_SR7F_BC_Video_DBLite_FourBitMode_mTable_entry:  /* entry mTable (2): the mode's default colour table */
    .byte   0x02, 0x00, 0x00, 0x24	| 408F772E s24 -> DECL_SR7F_BB_Video_DBLite_FourBitMode_mTable_data
    .short  0x0300, 0x0001, 0x0400, 0x0001, 0xFF00, 0x0000	| 408F7732
DECL_SR7F_BB_Video_DBLite_FourBitMode:  /* the FourBitMode (130) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x04, 0xF0	| 408F773E s24 -> DECL_SR7F_BB_Video_DBLite_FourBitMode_mVidParams_data
DECL_SR7F_BB_Video_DBLite_FourBitMode_mTable_entry:  /* entry mTable (2): the mode's default colour table */
    .byte   0x02, 0x00, 0x00, 0x10	| 408F7742 s24 -> DECL_SR7F_BB_Video_DBLite_FourBitMode_mTable_data
    .short  0x0300, 0x0001, 0x0400, 0x0001, 0xFF00, 0x0000	| 408F7746
DECL_SR7F_BB_Video_DBLite_FourBitMode_mTable_data:  /* data of mTable (2) */
    .short  0x0000, 0x008C, 0x0000, 0x0024, 0x0000, 0x000F, 0x0000	| 408F7752
    .long   0xFFFFFFFF, 0xFFFF0001, 0xEEEEEEEE, 0xEEEE0002	| 408F7760
    .long   0xDDDDDDDD, 0xDDDD0003, 0xCCCCCCCC, 0xCCCC0004	| 408F7770
    .long   0xBBBBBBBB, 0xBBBB0005, 0xAAAAAAAA, 0xAAAA0006	| 408F7780
    .long   0x99999999, 0x99990007, 0x88888888, 0x88880008	| 408F7790
    .long   0x77777777, 0x77770009, 0x66666666, 0x6666000A	| 408F77A0
    .long   0x55555555, 0x5555000B, 0x44444444, 0x4444000C	| 408F77B0
    .long   0x33333333, 0x3333000D, 0x22222222, 0x2222000E	| 408F77C0
    .short  0x1111, 0x1111, 0x1111, 0x000F, 0x0000, 0x0000, 0x0000	| 408F77D0
DECL_SR7E_8A_Video_Sonora_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F77DE
    .long   0x002E0000, 0x00000140, 0x00000000, 0x01E00280	| 408F77E0
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F77F0
    .long   0x00000004, 0x00010004, 0x00000000	| 408F7800
DECL_SR7E_8D_Video_Sonora_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F780C
    .long   0x00000000, 0x01400000, 0x00000190, 0x02800000	| 408F7810
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F7820
    .short  0x0004, 0x0001, 0x0004, 0x0000, 0x0000	| 408F7830
DECL_SR7E_81_Video_Sonora_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F783A
    .long   0x00000140, 0x00000000, 0x03660280, 0x00000000	| 408F7840
    .long   0x00000000, 0x00500000, 0x00500000, 0x00000004	| 408F7850
    .long   0x00010004, 0x00000000	| 408F7860
DECL_SR7E_83_Video_Sonora_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F7868
    .long   0x01000000, 0x00000180, 0x02000000, 0x00000000	| 408F7870
    .long   0x00000048, 0x00000048, 0x00000000, 0x00040001	| 408F7880
    .short  0x0004, 0x0000, 0x0000	| 408F7890
DECL_SR7E_85_Video_Sonora_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0118	| 408F7896
    .long   0x00000000, 0x01800230, 0x00000000, 0x00000000	| 408F78A0
    .long   0x00480000, 0x00480000, 0x00000004, 0x00010004	| 408F78B0
    .long   0x00000000	| 408F78C0
DECL_SR7E_93_Video_Sonora_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x01A00000	| 408F78C4
    .long   0x00000270, 0x03400000, 0x00000000, 0x00000048	| 408F78D0
    .long   0x00000048, 0x00000000, 0x00040001, 0x00040000	| 408F78E0
    .short  0x0000	| 408F78F0
DECL_SR7F_87_Video_RBV1_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0100, 0x0000, 0x0000	| 408F78F2
    .long   0x01560200, 0x00000000, 0x00000000, 0x00480000	| 408F7900
    .long   0x00480000, 0x00000004, 0x00010004, 0x00000000	| 408F7910
DECL_SR7F_A3_Video_V8_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x04000000, 0x000001E0	| 408F7920
    .long   0x02800000, 0x00000000, 0x00000048, 0x00000048	| 408F7930
    .short  0x0000, 0x0000, 0x0004, 0x0001, 0x0004, 0x0000, 0x0000	| 408F7940
DECL_SR7F_AB_Video_V8_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F794E
    .long   0x002E0000, 0x00000200, 0x00000000, 0x01E00280	| 408F7950
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F7960
    .long   0x00000004, 0x00010004, 0x00000000	| 408F7970
DECL_SR7F_A2_Video_V8_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F797C
    .long   0x00000000, 0x04000000, 0x00000180, 0x02000000	| 408F7980
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F7990
    .short  0x0004, 0x0001, 0x0004, 0x0000, 0x0000	| 408F79A0
DECL_SR7F_AA_Video_V8_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F79AA
    .long   0x00000200, 0x00000000, 0x01800200, 0x00000000	| 408F79B0
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000004	| 408F79C0
    .long   0x00010004, 0x00000000	| 408F79D0
DECL_SR7F_B2_Video_V8_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F79D8
    .long   0x04000000, 0x00000180, 0x02300000, 0x00000000	| 408F79E0
    .long   0x00000048, 0x00000048, 0x00000000, 0x00040001	| 408F79F0
    .short  0x0004, 0x0000, 0x0000	| 408F7A00
DECL_SR7F_BA_Video_V8_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0200	| 408F7A06
    .long   0x00000000, 0x01800230, 0x00000000, 0x00000000	| 408F7A10
    .long   0x00480000, 0x00480000, 0x00000004, 0x00010004	| 408F7A20
    .long   0x00000000	| 408F7A30
DECL_SR7F_BE_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x02000000	| 408F7A34
    .long   0x00000300, 0x04000000, 0x00000000, 0x00000048	| 408F7A40
    .long   0x00000048, 0x00000000, 0x00040001, 0x00040000	| 408F7A50
    .short  0x0000	| 408F7A60
DECL_SR7F_C0_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0200, 0x0000, 0x0000	| 408F7A62
    .long   0x03660280, 0x00000000, 0x00000000, 0x00500000	| 408F7A70
    .long   0x00500000, 0x00000004, 0x00010004, 0x00000000	| 408F7A80
DECL_SR7F_C4_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x02400000, 0x00000366	| 408F7A90
    .long   0x04800000, 0x00000000, 0x0000004D, 0x0000004D	| 408F7AA0
    .short  0x0000, 0x0000, 0x0004, 0x0001, 0x0004, 0x0000, 0x0000	| 408F7AB0
DECL_SR7F_C6_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F7ABE
    .long   0x002E0000, 0x00000340, 0x00000000, 0x02700340	| 408F7AC0
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F7AD0
    .long   0x00000004, 0x00010004, 0x00000000	| 408F7AE0
DECL_SR7F_E8_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F7AEC
    .long   0x00000000, 0x03400000, 0x00000258, 0x03200000	| 408F7AF0
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F7B00
    .short  0x0004, 0x0001, 0x0004, 0x0000, 0x0000	| 408F7B10
DECL_SR7F_D0_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F7B1A
    .long   0xC0200400, 0x00000000, 0x01800200, 0x00000000	| 408F7B20
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000004	| 408F7B30
    .long   0x00010004, 0x00000000	| 408F7B40
DECL_SR7F_D4_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00009C20	| 408F7B48
    .long   0x03400000, 0x000001E0, 0x02800000, 0x00000000	| 408F7B50
    .long   0x00000048, 0x00000048, 0x00000000, 0x00040001	| 408F7B60
    .short  0x0004, 0x0000, 0x0000	| 408F7B70
DECL_SR7F_D6_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0340	| 408F7B76
    .long   0x00000000, 0x02400300, 0x00000000, 0x00000000	| 408F7B80
    .long   0x00480000, 0x00480000, 0x00000004, 0x00010004	| 408F7B90
    .long   0x00000000	| 408F7BA0
DECL_SR7F_DC_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x0000C020, 0x04000000	| 408F7BA4
    .long   0x000001E0, 0x02800000, 0x00000000, 0x00000048	| 408F7BB0
    .long   0x00000048, 0x00000000, 0x00040001, 0x00040000	| 408F7BC0
    .short  0x0000	| 408F7BD0
DECL_SR7F_DE_Video_DAFB_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0400, 0x0000, 0x0000	| 408F7BD2
    .long   0x02400300, 0x00000000, 0x00000000, 0x00480000	| 408F7BE0
    .long   0x00480000, 0x00000004, 0x00010004, 0x00000000	| 408F7BF0
DECL_SR7F_BC_Video_DBLite_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x01400000, 0x00000190	| 408F7C00
    .long   0x02800000, 0x00000000, 0x00000048, 0x00000048	| 408F7C10
    .short  0x0000, 0x0000, 0x0004, 0x0001, 0x0004, 0x0000, 0x0000	| 408F7C20
DECL_SR7F_BB_Video_DBLite_FourBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F7C2E
    .long   0x002E0000, 0x00000140, 0x00000000, 0x01E00280	| 408F7C30
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F7C40
    .long   0x00000004, 0x00010004, 0x00000000	| 408F7C50
DECL_SR7E_8B_Video_Sonora_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0x70	| 408F7C5C s24 -> DECL_SR7E_8B_Video_Sonora_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7C60
DECL_SR7E_8D_Video_Sonora_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0x8E	| 408F7C6C s24 -> DECL_SR7E_8D_Video_Sonora_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7C70
DECL_SR7E_82_Video_Sonora_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xAC	| 408F7C7C s24 -> DECL_SR7E_82_Video_Sonora_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7C80
DECL_SR7E_83_Video_Sonora_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xCA	| 408F7C8C s24 -> DECL_SR7E_83_Video_Sonora_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7C90
DECL_SR7E_85_Video_Sonora_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xE8	| 408F7C9C s24 -> DECL_SR7E_85_Video_Sonora_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7CA0
DECL_SR7E_93_Video_Sonora_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x06	| 408F7CAC s24 -> DECL_SR7E_93_Video_Sonora_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7CB0
DECL_SR7F_87_Video_RBV1_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x24	| 408F7CBC s24 -> DECL_SR7F_87_Video_RBV1_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7CC0
DECL_SR7F_A3_Video_V8_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x42	| 408F7CCC s24 -> DECL_SR7F_A3_Video_V8_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7CD0
DECL_SR7F_A2_Video_V8_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x60	| 408F7CDC s24 -> DECL_SR7F_A2_Video_V8_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7CE0
DECL_SR7F_AA_Video_V8_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x7E	| 408F7CEC s24 -> DECL_SR7F_AA_Video_V8_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7CF0
DECL_SR7F_B2_Video_V8_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x9C	| 408F7CFC s24 -> DECL_SR7F_B2_Video_V8_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D00
DECL_SR7F_BF_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xBA	| 408F7D0C s24 -> DECL_SR7F_BF_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D10
DECL_SR7F_C1_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xD8	| 408F7D1C s24 -> DECL_SR7F_C1_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D20
DECL_SR7F_C5_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0xF6	| 408F7D2C s24 -> DECL_SR7F_C5_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D30
DECL_SR7F_C6_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x14	| 408F7D3C s24 -> DECL_SR7F_C6_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D40
DECL_SR7F_C2_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xF0	| 408F7D4C s24 -> DECL_SR7F_A2_Video_V8_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D50
DECL_SR7F_C8_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xB2	| 408F7D5C s24 -> DECL_SR7F_A3_Video_V8_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D60
DECL_SR7F_E8_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x12	| 408F7D6C s24 -> DECL_SR7F_E8_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D70
DECL_SR7F_D0_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x30	| 408F7D7C s24 -> DECL_SR7F_D0_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D80
DECL_SR7F_D4_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x4E	| 408F7D8C s24 -> DECL_SR7F_D4_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7D90
DECL_SR7F_DC_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x9A	| 408F7D9C s24 -> DECL_SR7F_DC_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7DA0
DECL_SR7F_D6_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0x5C	| 408F7DAC s24 -> DECL_SR7F_D6_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7DB0
DECL_SR7F_DE_Video_DAFB_EightBitMode:  /* the EightBitMode (131) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x03, 0xA8	| 408F7DBC s24 -> DECL_SR7F_DE_Video_DAFB_EightBitMode_mVidParams_data
    .long   0x03000001, 0x04000000, 0xFF000000	| 408F7DC0
DECL_SR7E_8B_Video_Sonora_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F7DCC
    .long   0x00000000, 0x02800000, 0x000001E0, 0x02800000	| 408F7DD0
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F7DE0
    .short  0x0008, 0x0001, 0x0008, 0x0000, 0x0000	| 408F7DF0
DECL_SR7E_8D_Video_Sonora_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F7DFA
    .long   0x00000280, 0x00000000, 0x01900280, 0x00000000	| 408F7E00
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000008	| 408F7E10
    .long   0x00010008, 0x00000000	| 408F7E20
DECL_SR7E_82_Video_Sonora_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F7E28
    .long   0x02800000, 0x00000366, 0x02800000, 0x00000000	| 408F7E30
    .long   0x00000050, 0x00000050, 0x00000000, 0x00080001	| 408F7E40
    .short  0x0008, 0x0000, 0x0000	| 408F7E50
DECL_SR7E_83_Video_Sonora_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0200	| 408F7E56
    .long   0x00000000, 0x01800200, 0x00000000, 0x00000000	| 408F7E60
    .long   0x00480000, 0x00480000, 0x00000008, 0x00010008	| 408F7E70
    .long   0x00000000	| 408F7E80
DECL_SR7E_85_Video_Sonora_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x02300000	| 408F7E84
    .long   0x00000180, 0x02300000, 0x00000000, 0x00000048	| 408F7E90
    .long   0x00000048, 0x00000000, 0x00080001, 0x00080000	| 408F7EA0
    .short  0x0000	| 408F7EB0
DECL_SR7E_93_Video_Sonora_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0340, 0x0000, 0x0000	| 408F7EB2
    .long   0x02700340, 0x00000000, 0x00000000, 0x00480000	| 408F7EC0
    .long   0x00480000, 0x00000008, 0x00010008, 0x00000000	| 408F7ED0
DECL_SR7F_87_Video_RBV1_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x02000000, 0x00000156	| 408F7EE0
    .long   0x02000000, 0x00000000, 0x00000048, 0x00000048	| 408F7EF0
    .short  0x0000, 0x0000, 0x0008, 0x0001, 0x0008, 0x0000, 0x0000	| 408F7F00
DECL_SR7F_A3_Video_V8_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F7F0E
    .long   0x002E0000, 0x00000400, 0x00000000, 0x01E00280	| 408F7F10
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F7F20
    .long   0x00000008, 0x00010008, 0x00000000	| 408F7F30
DECL_SR7F_A2_Video_V8_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F7F3C
    .long   0x00000000, 0x04000000, 0x00000180, 0x02000000	| 408F7F40
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F7F50
    .short  0x0008, 0x0001, 0x0008, 0x0000, 0x0000	| 408F7F60
DECL_SR7F_AA_Video_V8_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F7F6A
    .long   0x00000200, 0x00000000, 0x01800200, 0x00000000	| 408F7F70
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000008	| 408F7F80
    .long   0x00010008, 0x00000000	| 408F7F90
DECL_SR7F_B2_Video_V8_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F7F98
    .long   0x04000000, 0x00000180, 0x02300000, 0x00000000	| 408F7FA0
    .long   0x00000048, 0x00000048, 0x00000000, 0x00080001	| 408F7FB0
    .short  0x0008, 0x0000, 0x0000	| 408F7FC0
DECL_SR7F_BF_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0400	| 408F7FC6
    .long   0x00000000, 0x03000400, 0x00000000, 0x00000000	| 408F7FD0
    .long   0x00480000, 0x00480000, 0x00000008, 0x00010008	| 408F7FE0
    .long   0x00000000	| 408F7FF0
DECL_SR7F_C1_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x04000000	| 408F7FF4
    .long   0x00000366, 0x02800000, 0x00000000, 0x00000050	| 408F8000
    .long   0x00000050, 0x00000000, 0x00080001, 0x00080000	| 408F8010
    .short  0x0000	| 408F8020
DECL_SR7F_C5_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0480, 0x0000, 0x0000	| 408F8022
    .long   0x03660480, 0x00000000, 0x00000000, 0x004D0000	| 408F8030
    .long   0x004D0000, 0x00000008, 0x00010008, 0x00000000	| 408F8040
DECL_SR7F_C6_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x03400000, 0x00000270	| 408F8050
    .long   0x03400000, 0x00000000, 0x00000048, 0x00000048	| 408F8060
    .short  0x0000, 0x0000, 0x0008, 0x0001, 0x0008, 0x0000, 0x0000	| 408F8070
DECL_SR7F_E8_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F807E
    .long   0x002E0000, 0x00000340, 0x00000000, 0x02580320	| 408F8080
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F8090
    .long   0x00000008, 0x00010008, 0x00000000	| 408F80A0
DECL_SR7F_D0_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F80AC
    .long   0x0000C040, 0x04000000, 0x00000180, 0x02000000	| 408F80B0
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 408F80C0
    .short  0x0008, 0x0001, 0x0008, 0x0000, 0x0000	| 408F80D0
DECL_SR7F_D4_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F80DA
    .long   0x9C400340, 0x00000000, 0x01E00280, 0x00000000	| 408F80E0
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000008	| 408F80F0
    .long   0x00010008, 0x00000000	| 408F8100
DECL_SR7F_D6_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F8108
    .long   0x03400000, 0x00000240, 0x03000000, 0x00000000	| 408F8110
    .long   0x00000048, 0x00000048, 0x00000000, 0x00080001	| 408F8120
    .short  0x0008, 0x0000, 0x0000	| 408F8130
DECL_SR7F_DC_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0xC040, 0x0400	| 408F8136
    .long   0x00000000, 0x01E00280, 0x00000000, 0x00000000	| 408F8140
    .long   0x00480000, 0x00480000, 0x00000008, 0x00010008	| 408F8150
    .long   0x00000000	| 408F8160
DECL_SR7F_DE_Video_DAFB_EightBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x04000000	| 408F8164
    .long   0x00000240, 0x03000000, 0x00000000, 0x00000048	| 408F8170
    .long   0x00000048, 0x00000000, 0x00080001, 0x00080000	| 408F8180
    .short  0x0000	| 408F8190
DECL_SR7E_8C_Video_Sonora_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x00, 0xE0	| 408F8192 s24 -> DECL_SR7E_8C_Video_Sonora_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F8196
DECL_SR7E_8E_Video_Sonora_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x00, 0xFE	| 408F81A2 s24 -> DECL_SR7E_8E_Video_Sonora_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F81A6
DECL_SR7E_84_Video_Sonora_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0x1C	| 408F81B2 s24 -> DECL_SR7E_84_Video_Sonora_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F81B6
DECL_SR7E_86_Video_Sonora_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0x3A	| 408F81C2 s24 -> DECL_SR7E_86_Video_Sonora_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F81C6
DECL_SR7F_F9_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0x58	| 408F81D2 s24 -> DECL_SR7F_F9_Video_DAFB_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F81D6
DECL_SR7F_ED_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0x76	| 408F81E2 s24 -> DECL_SR7F_ED_Video_DAFB_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F81E6
DECL_SR7F_EF_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0x94	| 408F81F2 s24 -> DECL_SR7F_EF_Video_DAFB_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F81F6
DECL_SR7F_E6_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xB2	| 408F8202 s24 -> DECL_SR7F_E6_Video_DAFB_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F8206
DECL_SR7F_EC_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x00, 0xBC	| 408F8212 s24 -> DECL_SR7E_84_Video_Sonora_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F8216
DECL_SR7F_E2_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xC0	| 408F8222 s24 -> DECL_SR7F_E2_Video_DAFB_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F8226
DECL_SR7F_E8_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xDE	| 408F8232 s24 -> DECL_SR7F_E8_Video_DAFB_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F8236
DECL_SR7F_F0_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0xFC	| 408F8242 s24 -> DECL_SR7F_F0_Video_DAFB_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F8246
DECL_SR7F_F4_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x1A	| 408F8252 s24 -> DECL_SR7F_F4_Video_DAFB_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F8256
DECL_SR7F_F6_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x02, 0x38	| 408F8262 s24 -> DECL_SR7F_F6_Video_DAFB_SixteenBitMode_mVidParams_data
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 408F8266
DECL_SR7E_8C_Video_Sonora_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0500, 0x0000, 0x0000	| 408F8272
    .long   0x01E00280, 0x00000000, 0x00000000, 0x00480000	| 408F8280
    .long   0x00480000, 0x00100010, 0x00030005, 0x00000000	| 408F8290
DECL_SR7E_8E_Video_Sonora_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x05000000, 0x00000190	| 408F82A0
    .long   0x02800000, 0x00000000, 0x00000048, 0x00000048	| 408F82B0
    .short  0x0000, 0x0010, 0x0010, 0x0003, 0x0005, 0x0000, 0x0000	| 408F82C0
DECL_SR7E_84_Video_Sonora_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F82CE
    .long   0x002E0000, 0x00000400, 0x00000000, 0x01800200	| 408F82D0
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F82E0
    .long   0x00100010, 0x00030005, 0x00000000	| 408F82F0
DECL_SR7E_86_Video_Sonora_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F82FC
    .long   0x00000000, 0x04600000, 0x00000180, 0x02300000	| 408F8300
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000010	| 408F8310
    .short  0x0010, 0x0003, 0x0005, 0x0000, 0x0000	| 408F8320
DECL_SR7F_F9_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000	| 408F832A
    .long   0x00000800, 0x00000000, 0x03000400, 0x00000000	| 408F8330
    .long   0x00000000, 0x00480000, 0x00480000, 0x00100010	| 408F8340
    .long   0x00030005, 0x00000000	| 408F8350
DECL_SR7F_ED_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F8358
    .long   0x08000000, 0x00000366, 0x02800000, 0x00000000	| 408F8360
    .long   0x00000050, 0x00000050, 0x00000010, 0x00100003	| 408F8370
    .short  0x0005, 0x0000, 0x0000	| 408F8380
DECL_SR7F_EF_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0900	| 408F8386
    .long   0x00000000, 0x03660480, 0x00000000, 0x00000000	| 408F8390
    .long   0x004D0000, 0x004D0000, 0x00100010, 0x00030005	| 408F83A0
    .long   0x00000000	| 408F83B0
DECL_SR7F_E6_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x06800000	| 408F83B4
    .long   0x00000270, 0x03400000, 0x00000000, 0x00000048	| 408F83C0
    .long   0x00000048, 0x00000010, 0x00100003, 0x00050000	| 408F83D0
    .short  0x0000	| 408F83E0
DECL_SR7F_E2_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0800, 0x0000, 0x0000	| 408F83E2
    .long   0x01E00280, 0x00000000, 0x00000000, 0x00480000	| 408F83F0
    .long   0x00480000, 0x00100010, 0x00030005, 0x00000000	| 408F8400
DECL_SR7F_E8_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x06800000, 0x00000258	| 408F8410
    .long   0x03200000, 0x00000000, 0x00000048, 0x00000048	| 408F8420
    .short  0x0000, 0x0010, 0x0010, 0x0003, 0x0005, 0x0000, 0x0000	| 408F8430
DECL_SR7F_F0_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F843E
    .long   0x002E0001, 0x80800800, 0x00000000, 0x01800200	| 408F8440
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F8450
    .long   0x00100010, 0x00030005, 0x00000000	| 408F8460
DECL_SR7F_F4_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F846C
    .long   0x00013880, 0x06800000, 0x000001E0, 0x02800000	| 408F8470
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000010	| 408F8480
    .short  0x0010, 0x0003, 0x0005, 0x0000, 0x0000	| 408F8490
DECL_SR7F_F6_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x01E0, 0x0000	| 408F849A
    .long   0x00000680, 0x00000000, 0x02400300, 0x00000000	| 408F84A0
    .long   0x00000000, 0x00480000, 0x00480000, 0x00100010	| 408F84B0
    .long   0x00030005, 0x00000000	| 408F84C0
DECL_SR7F_C7_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x00, 0x70	| 408F84C8 s24 -> DECL_SR7F_C7_Video_DAFB_SixteenBitMode_mVidParams_data
    .long   0x03000001	| 408F84CC
    .long   0x04000002, 0xFF000000	| 408F84D0
DECL_SR7F_C3_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x00, 0x8E	| 408F84D8 s24 -> DECL_SR7F_C3_Video_DAFB_SixteenBitMode_mVidParams_data
    .long   0x03000001	| 408F84DC
    .long   0x04000002, 0xFF000000	| 408F84E0
DECL_SR7F_C9_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x00, 0xAC	| 408F84E8 s24 -> DECL_SR7F_C9_Video_DAFB_SixteenBitMode_mVidParams_data
    .long   0x03000001	| 408F84EC
    .long   0x04000002, 0xFF000000	| 408F84F0
DECL_SR7F_E9_Video_DAFB_ThirtyTwoBitMode:  /* the ThirtyTwoBitMode (133) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x00, 0xCA	| 408F84F8 s24 -> DECL_SR7F_E9_Video_DAFB_ThirtyTwoBitMode_mVidParams_data
    .long   0x03000001	| 408F84FC
    .long   0x04000002, 0xFF000000	| 408F8500
DECL_SR7F_D1_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x00, 0xE8	| 408F8508 s24 -> DECL_SR7F_D1_Video_DAFB_SixteenBitMode_mVidParams_data
    .long   0x03000001	| 408F850C
    .long   0x04000002, 0xFF000000	| 408F8510
DECL_SR7F_D5_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0x06	| 408F8518 s24 -> DECL_SR7F_D5_Video_DAFB_SixteenBitMode_mVidParams_data
    .long   0x03000001	| 408F851C
    .long   0x04000002, 0xFF000000	| 408F8520
DECL_SR7F_D7_Video_DAFB_SixteenBitMode:  /* the SixteenBitMode (132) (pointed to by its entry) */
    .byte   0x01, 0x00, 0x01, 0x24	| 408F8528 s24 -> DECL_SR7F_D7_Video_DAFB_SixteenBitMode_mVidParams_data
    .long   0x03000001	| 408F852C
    .long   0x04000002, 0xFF000000	| 408F8530
DECL_SR7F_C7_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000	| 408F8538
    .long   0x0D000000, 0x00000270, 0x03400000, 0x00000000	| 408F8540
    .long   0x00000048, 0x00000048, 0x00000010, 0x00200003	| 408F8550
    .short  0x0008, 0x0000, 0x0000	| 408F8560
DECL_SR7F_C3_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0800	| 408F8566
    .long   0x00000000, 0x01800200, 0x00000000, 0x00000000	| 408F8570
    .long   0x00480000, 0x00480000, 0x00100020, 0x00030008	| 408F8580
    .long   0x00000000	| 408F8590
DECL_SR7F_C9_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00000000, 0x10000000	| 408F8594
    .long   0x000001E0, 0x02800000, 0x00000000, 0x00000048	| 408F85A0
    .long   0x00000048, 0x00000010, 0x00200003, 0x00080000	| 408F85B0
    .short  0x0000	| 408F85C0
DECL_SR7F_E9_Video_DAFB_ThirtyTwoBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000, 0x002E, 0x0000, 0x0000, 0x0D00, 0x0000, 0x0000	| 408F85C2
    .long   0x02580320, 0x00000000, 0x00000000, 0x00480000	| 408F85D0
    .long   0x00480000, 0x00100020, 0x00030008, 0x00000000	| 408F85E0
DECL_SR7F_D1_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E, 0x00030100, 0x10000000, 0x00000180	| 408F85F0
    .long   0x02000000, 0x00000000, 0x00000048, 0x00000048	| 408F8600
    .short  0x0000, 0x0010, 0x0020, 0x0003, 0x0008, 0x0000, 0x0000	| 408F8610
DECL_SR7F_D5_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .short  0x0000	| 408F861E
    .long   0x002E0002, 0x71000D00, 0x00000000, 0x01E00280	| 408F8620
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 408F8630
    .long   0x00100020, 0x00030008, 0x00000000	| 408F8640
DECL_SR7F_D7_Video_DAFB_SixteenBitMode_mVidParams_data:  /* data of mVidParams (1) */
    .long   0x0000002E	| 408F864C
    .long   0x00000000, 0x0D000000, 0x00000240, 0x03000000	| 408F8650
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000010	| 408F8660
    .short  0x0020, 0x0003, 0x0008, 0x0000, 0x0000	| 408F8670
DECL_SR7F_01_MacII_PrimaryInit:  /* the PrimaryInit (34) (pointed to by its entry) */
    .short  0x0000, 0x17D2, 0x0202, 0x0000, 0x0000, 0x0004	| 408F867A

/*
 PrimaryInit of the board sResource, run by the Slot Manager at start-up for slot 0:
 enables or disables the built-in sResources that this machine has or lacks (Slot
 Manager selector 49 on the sResources 0xFA, 0xFB, 0xFE...: CPU, Ethernet and others),
 with helpers shared by the video PrimaryInit (from ..._17D2 on). Inferred from the code.
*/
DECL_SR7F_01_MacII_PrimaryInit_code:/* PrimaryInit of the CPU sResource: PRAM record (Slot Manager 17); if empty, initialized from this machine's sResource (id BoxFlag + 1, field 32, Slot Manager 51) */
    linkw %fp,#-84
    movew #1,%a0@(2)
    clrb %fp@(-7)
    clrb %fp@(-5)
    movew #128,%fp@(-66)
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_14FA),%a1
    clrw %d0
    moveb 0xcb3,%d1
    addqw #1,%d1
    lea %fp@(-56),%a0
    lea %fp@(-64),%a2
    movel %a2,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    tstw %a2@
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_54
    moveb %d1,%a0@(50)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    moveb #32,%a0@(50)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    movew %a0@(2),%a2@
    movel %a2,%a0@(4)
    moveq #51,%d0	/* _SlotManager 51: INITSLOTPRAM */
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_54:/* the CPU sResources: delete all but this machine's */
    movew %a1@+,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_56:/* per entry; Slot Manager 49 deletes it */
    moveb %a1@+,%d0
    cmpb %d0,%d1
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_64
    moveb %d0,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_64:/* next. Then the 0xFA and 0xFB sResources: which one this machine keeps (lists at _151A, _152C) */
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_56
    moveb 0xcb3,%d1
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_151A),%a1
    movew %a1@+,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_72:/* BoxFlag in the first list? */
    moveb %a1@+,%d0
    cmpb %d0,%d1
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_8E
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_72
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_152C),%a1
    movew %a1@+,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_82:/* in the second list? */
    moveb %a1@+,%d0
    cmpb %d0,%d1
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_9A
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_82
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_A6
DECL_SR7F_01_MacII_PrimaryInit_code_8E:/* first list: delete 0xFB */
    moveb #0xfb,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_BA
DECL_SR7F_01_MacII_PrimaryInit_code_9A:/* second list: delete 0xFA */
    moveb #0xfa,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_BA
DECL_SR7F_01_MacII_PrimaryInit_code_A6:/* neither: delete both */
    moveb #0xfa,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
    moveb #0xfb,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_BA:/* delete 0xFE; decoder flag (0xDD1 bit 7) clear: no Ethernet, delete 0xFD */
    moveb #0xfe,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
    btst #7,0xdd1
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_D8
    moveb #0xfd,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_104
DECL_SR7F_01_MacII_PrimaryInit_code_D8:/* Ethernet present: stop the SONIC (RXDIS, wait, RST; IMR and CAM enable 0) */
    movel %a2,%sp@-
    moveal 0xdd8,%a2
    addal %a2@,%a2
    moveal %a2@(92),%a2
    moveq #4,%d0
    movel %d0,%a2@
DECL_SR7F_01_MacII_PrimaryInit_code_E8:/* loop: until RXEN clears */
    movel %a2@,%d0
    btst #3,%d0
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_E8
    movel #128,%d0
    movel %d0,%a2@
    subl %d0,%d0
    movel %d0,%a2@(16)
    movel %d0,%a2@(148)
    moveal %sp@+,%a2
DECL_SR7F_01_MacII_PrimaryInit_code_104:/* the video PrimaryInit for this BoxFlag */
    moveq #0,%d0
    moveb 0xcb3,%d0
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_124),%a0
DECL_SR7F_01_MacII_PrimaryInit_code_10E:/* search the table */
    cmpw %a0@,%d0
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_118
    tstl %a0@+
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_10E
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_188
DECL_SR7F_01_MacII_PrimaryInit_code_118:/* call it */
    movew %a0@(2),%d0
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_188
    jsr %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_124,%d0:w)
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_19E

/* subroutine (103 instructions): traps SlotManager, SwapMMUMode; calls DECL_SR7F_01_MacII_PrimaryInit_code_12D4; low memory BusErrorVector (mechanical summary) */
DECL_SR7F_01_MacII_PrimaryInit_code_124:/* table of (BoxFlag, offset from here); 0 ends. The Quadra 800 (0x1D) goes to offset 0x730 (_656_1EA + 0x14) */
    orib #126,%d5	| 408F87AA
    .byte   0x00, 0x0C, 0x00, 0x7E, 0x00, 0x0D, 0x02, 0x4A, 0x00, 0x0E, 0x07, 0x38, 0x00, 0x10, 0x07, 0x38	| 408F87AE
    .byte   0x00, 0x14, 0x07, 0x38, 0x00, 0x34, 0x07, 0x30, 0x00, 0x18, 0x07, 0x30, 0x00, 0x1E, 0x07, 0x30	| 408F87BE
    .byte   0x00, 0x2D, 0x07, 0x30, 0x00, 0x1D, 0x07, 0x30, 0x00, 0x35, 0x07, 0x30, 0x00, 0x2E, 0x07, 0x30	| 408F87CE
    .byte   0x00, 0x2F, 0x07, 0x30, 0x00, 0x33, 0x07, 0x30, 0x00, 0x39, 0x07, 0x30, 0x00, 0x0F, 0x05, 0x36	| 408F87DE
    .byte   0x00, 0x13, 0x05, 0x36, 0x00, 0x17, 0x05, 0x5E, 0x00, 0x1A, 0x05, 0x5E, 0x00, 0x20, 0x05, 0x5E	| 408F87EE
    .byte   0x00, 0x21, 0x05, 0x5E, 0x00, 0x1B, 0x05, 0x5E, 0x00, 0x1C, 0x05, 0x5E, 0x00, 0x00, 0x00, 0x00	| 408F87FE
DECL_SR7F_01_MacII_PrimaryInit_code_188:/* no video on this machine: delete every video sResource (list at _1586) */
    lea %fp@(-56),%a0
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586),%a1
    movew %a1@+,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_192:/* loop */
    moveb %a1@+,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_192
DECL_SR7F_01_MacII_PrimaryInit_code_19E:/* return. The video PrimaryInit routines of each family follow */
    unlk %fp
    rts
    moveal ghost_VIA2,%a3
    moveb #64,%a3@(18)
    moveq #1,%d0
    _SwapMMUMode
    moveal 0xddc,%a0
    movel %a0@,%d1
    _SwapMMUMode
    tstl %d1
    bnew DECL_SR7F_01_MacII_PrimaryInit_code_358_E
    sf %fp@(-67)
    cmpib #8,0xcb3
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_34
    cmpib #10,0xcb3
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_19E_38
DECL_SR7F_01_MacII_PrimaryInit_code_19E_34:
    st %fp@(-67)
DECL_SR7F_01_MacII_PrimaryInit_code_19E_38:
    lea %fp@(-56),%a0
    lea %fp@(-64),%a1
    movel %a1,%a0@
    moveq #17,%d0
    _SlotManager
    moveb %a1@(3),%d5
    moveb %a1@(4),%d6
    moveb %a3@(16),%d4
    lsrb #3,%d4
    andib #7,%d4
    cmpib #0,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_80
    cmpib #3,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_80
    cmpib #4,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_80
    cmpib #7,%d4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_19E_8A
    cmpib #9,0xcb3
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_8A
    cmpib #10,0xcb3
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_8A
DECL_SR7F_01_MacII_PrimaryInit_code_19E_80:
    clrb %d4
    clrb %d6
    tstb %d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_F0
    bras DECL_SR7F_01_MacII_PrimaryInit_code_19E_DA
DECL_SR7F_01_MacII_PrimaryInit_code_19E_8A:
    moveq #0,%d0
    cmpil #1048576,MemTop
    bhis DECL_SR7F_01_MacII_PrimaryInit_code_19E_9A
    bset #3,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_19E_9A:
    tstb %fp@(-67)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_A4
    bset #4,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_19E_A4:
    exg %d0,%d6
    eorb %d6,%d0
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_19E_B8
    moveb %d5,%d0
    andib #7,%d0
    cmpb %d0,%d4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_19E_B8
    moveb %d5,%d4
    bras DECL_SR7F_01_MacII_PrimaryInit_code_19E_F0
DECL_SR7F_01_MacII_PrimaryInit_code_19E_B8:
    bset #7,%d4
    orb %d6,%d4
    cmpil #1048576,MemTop
    bhis DECL_SR7F_01_MacII_PrimaryInit_code_19E_CC
    bclr #4,%d4
DECL_SR7F_01_MacII_PrimaryInit_code_19E_CC:
    clrb 0xc2d
    lea %fp@(-66),%a0
    .short  0xA081	| 408F88F8 _SetVideoDefault (flags 0x0000)
    lea %fp@(-56),%a0
DECL_SR7F_01_MacII_PrimaryInit_code_19E_DA:
    moveb %d4,%fp@(-61)
    moveb %d6,%fp@(-60)
    moveb #0x80,%fp@(-62)	| 408F8906
    movel %a0@,%a0@(4)
    moveq #18,%d0
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_19E_F0:
    tstb %d4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_19E_FC
    moveb #64,%a3@(16)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_19E_100
DECL_SR7F_01_MacII_PrimaryInit_code_19E_FC:
    clrb %a3@(16)
DECL_SR7F_01_MacII_PrimaryInit_code_19E_100:
    lea %fp@(-56),%a0
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586),%a1
    bset #7,%d4
    moveb %d4,%d3
    andib #103,%d3
    movew %a1@+,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_19E_114:
    moveb %a1@+,%d2
    moveb %d2,%a0@(50)
    cmpb %d4,%d2
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_150
    tstb %fp@(-67)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_130
    cmpiw #134,%d2
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_14C
    cmpiw #129,%d2
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_19E_14C
DECL_SR7F_01_MacII_PrimaryInit_code_19E_130:
    moveb %d2,%d5
    andib #103,%d5
    cmpb %d5,%d3
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_19E_14C
    movel #1,%a0@(24)
    clrl %a0@(4)
    moveq #9,%d0
    _SlotManager
    bras DECL_SR7F_01_MacII_PrimaryInit_code_19E_150
DECL_SR7F_01_MacII_PrimaryInit_code_19E_14C:
    moveq #49,%d0
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_19E_150:
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_19E_114
    cmpib #0x80,%d4	| 408F8978
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C
    andib #7,%d4	| 408F897E
    cmpib #6,%d4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_19E_150+0x1a
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_154A),%a1
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_324
    cmpib #2,%d4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_19E_176
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_152C_18),%a1	| 408F8994
    bras DECL_SR7F_01_MacII_PrimaryInit_code_324
DECL_SR7F_01_MacII_PrimaryInit_code_19E_176:
    cmpib #7,%d4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_19E_182
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_154A_6),%a1	| 408F89A0
    bras DECL_SR7F_01_MacII_PrimaryInit_code_324
DECL_SR7F_01_MacII_PrimaryInit_code_19E_182:
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_152C_12),%a1	| 408F89A6
DECL_SR7F_01_MacII_PrimaryInit_code_324:  /* call DECL_SR7F_01_MacII_PrimaryInit_code_12D4 */
    jsr %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_12D4)
    btst #6,0xdd2
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_36C
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(56),%a3
    moveb #0xff,%a3@(8)
    lea %a3@(4),%a0
    moveb #0xfe,%a0@(-4)
    cmpib #1,%d4
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_358
    sf %a0@
    sf %a0@
    st %a0@
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_36C
DECL_SR7F_01_MacII_PrimaryInit_code_358:  /* from here: st %a0@ */
    st %a0@
    st %a0@
    st %a0@
    sf %a0@
    sf %a0@
    sf %a0@
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_36C
DECL_SR7F_01_MacII_PrimaryInit_code_358_E:
    moveb #64,%a3@(16)	| 408F89EC
DECL_SR7F_01_MacII_PrimaryInit_code_36C:  /* return */
    rts
    moveal ghost_VIA2,%a3
    moveb #64,%a3@(18)
    lea %fp@(-56),%a0
    lea %fp@(-64),%a1
    movel %a1,%a0@
    moveq #17,%d0
    _SlotManager
    moveb %a1@(3),%d5
    moveb %a1@(4),%d6
    moveb %a3@(16),%d3
    lsrb #3,%d3
    andib #7,%d3
    moveal #1358168064,%a2
    moveb %d3,%d4
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    movel #892416587,%a2@(0x7fffc,%za0)	| 408F8A26
    movel #842348107,%a2@(0x3fffc,%za0)	| 408F8A32
    cmpil #892416587,%a2@(0x7fffc,%za0)	| 408F8A3E
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C_6E
    cmpil #842348107,%a2@(0x3fffc,%za0)	| 408F8A4C
    bnew DECL_SR7F_01_MacII_PrimaryInit_code_36C_136
    bset #3,%d4
DECL_SR7F_01_MacII_PrimaryInit_code_36C_6E:
    sf %d7
    lea %fp@(-56),%a0
    moveb #3,%a0@(48)
    movew #10,%a0@(40)
    movew #21,%a0@(42)
    moveq #21,%d0
    _SlotManager
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C_DA
    clrb %a0@(48)
    movew #1,%a0@(40)
    clrw %a0@(42)
    clrw %a0@(44)
    clrw %a0@(46)
    moveb #14,%a0@(49)
    moveq #0,%d0
    bset #1,%d0
    movel %d0,%a0@(24)
    moveq #11,%d0
    _SlotManager
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C_F8
    bsrw DECL_SR7F_01_MacII_PrimaryInit_code_5B6
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_F8
    moveb #0xfe,%a0@(50)	| 408F8AB0
    clrb %a0@(49)
    clrl %a0@(4)
    clrw %a0@(38)
    clrl %a0@(24)
    moveq #10,%d0
    _SlotManager
    bras DECL_SR7F_01_MacII_PrimaryInit_code_36C_F0
DECL_SR7F_01_MacII_PrimaryInit_code_36C_DA:
    moveb #0x80,%a0@(50)	| 408F8ACC
    moveq #1,%d0
    _SlotManager
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_F8
    movew %a0@(2),%d0
    btst #0,%d0
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C_F8
DECL_SR7F_01_MacII_PrimaryInit_code_36C_F0:
    cmpib #2,%d3
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_F8
    st %d7
DECL_SR7F_01_MacII_PrimaryInit_code_36C_F8:
    clrl %a0@(24)
    clrb %a0@(49)
    cmpib #7,%d3
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_13C
    movel %a0,%sp@-
    subqw #4,%sp
    moveal %sp,%a0
    movel #262396,%d0
    _ReadXPRam
    movel %sp@+,%d0
    moveal %sp@+,%a0
    cmpil #1380862286,%d0
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_136
    moveb #2,%d3
    andib #0xf8,%d4	| 408F8B16
    orb %d3,%d4
    moveb %d4,%d6
    moveb %d4,%d5
    .short  0x0005, 0x00A0	| orib #-96,%d5
    sf %d7
    bras DECL_SR7F_01_MacII_PrimaryInit_code_36C_174
DECL_SR7F_01_MacII_PrimaryInit_code_36C_136:
    clrb %d4
    clrb %d6
    bras DECL_SR7F_01_MacII_PrimaryInit_code_36C_158
DECL_SR7F_01_MacII_PrimaryInit_code_36C_13C:
    moveb %d5,%d0
    andib #7,%d0
    cmpib #2,%d0
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_152
    btst #4,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C_152
    tstb %d7
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C_156
DECL_SR7F_01_MacII_PrimaryInit_code_36C_152:
    cmpb %d6,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C_174
DECL_SR7F_01_MacII_PrimaryInit_code_36C_156:
    moveb %d4,%d6
DECL_SR7F_01_MacII_PrimaryInit_code_36C_158:
    moveb %d6,%a1@(4)
    moveb %d4,%d5
    .short  0x0005, 0x00A0	| orib #-96,%d5
    moveb %d5,%a1@(3)
    moveb #0x80,%a1@(2)	| 408F8B58
    movel %a1,%a0@(4)
    moveq #18,%d0
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_36C_174:
    moveb %a3@(1),%d0
    moveb %d5,%d2
    andib #23,%d2
    cmpib #18,%d2
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_188
    bset #0,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_36C_188:
    moveb %d0,%a3@(1)
    cmpib #18,%d2
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_19A
    moveb #1,%a3@(16)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_36C_19E
DECL_SR7F_01_MacII_PrimaryInit_code_36C_19A:
    clrb %a3@(16)
DECL_SR7F_01_MacII_PrimaryInit_code_36C_19E:
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586),%a1
    moveb %d5,%d4
    andib #111,%d4
    movew %a1@+,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_36C_1AA:
    moveb %a1@+,%d2
    moveb %d2,%a0@(50)
    cmpb %d5,%d2
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C_1D8
    moveb %d2,%d6
    andib #111,%d6
    cmpb %d6,%d4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_1D4
    tstb %d7
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_36C_1D4
    movel #1,%a0@(24)
    clrl %a0@(4)
    moveq #9,%d0
    _SlotManager
    bras DECL_SR7F_01_MacII_PrimaryInit_code_36C_1D8
DECL_SR7F_01_MacII_PrimaryInit_code_36C_1D4:
    moveq #49,%d0
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_36C_1D8:
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_36C_1AA
    cmpib #0xa0,%d5	| 408F8BCE
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_586_2E
    moveb %d5,%d0
    andib #31,%d0
    cmpib #3,%d3
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_1F4
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_154A_C_C),%a1	| 408F8BE0
    bras DECL_SR7F_01_MacII_PrimaryInit_code_36C_210
DECL_SR7F_01_MacII_PrimaryInit_code_36C_1F4:
    cmpib #22,%d0
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_200
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_154A),%a1
    bras DECL_SR7F_01_MacII_PrimaryInit_code_36C_210
DECL_SR7F_01_MacII_PrimaryInit_code_36C_200:
    cmpib #6,%d3
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_36C_20C
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_154A_C_12),%a1	| 408F8BF8
    bras DECL_SR7F_01_MacII_PrimaryInit_code_36C_210
DECL_SR7F_01_MacII_PrimaryInit_code_36C_20C:
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_154A_C_18),%a1	| 408F8BFE
DECL_SR7F_01_MacII_PrimaryInit_code_36C_210:
    btst #3,%d5
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_586
    lea %a1@(18),%a1
DECL_SR7F_01_MacII_PrimaryInit_code_586:  /* call DECL_SR7F_01_MacII_PrimaryInit_code_12D4 */
    jsr %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_12D4)
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(56),%a3
    moveb #8,%a3@(2)
    addqw #1,%a3
    moveb #127,%a3@(-1)
    st %a3@
    st %a3@
    st %a3@
    moveb #0xff,%a3@(-1)
    sf %a3@
    sf %a3@
    sf %a3@
DECL_SR7F_01_MacII_PrimaryInit_code_586_2E:
    rts

DECL_SR7F_01_MacII_PrimaryInit_code_5B6:  /* set up and call _SwapMMUMode */
    moveml %d0-%d2/%a2-%a5,%sp@-
    moveq #1,%d0
    _SwapMMUMode
    movew %d0,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal BusErrorVector,%a4
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_5B6_4A),%a2
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_614),%a5
    movel %a5,BusErrorVector
    moveal #-33554432,%a3
    moveq #0,%d1
    moveq #0,%d2
    movew %a3@(28),%d1
    movew %a3@(16),%d0
    addqw #1,%d1
    cmpw %a3@(28),%d1
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_5B6_4A
    movew %a3@(16),%d0
    movew %a3@(16),%d0
    movew %a3@(16),%d0
    movew %a3@(28),%d2
DECL_SR7F_01_MacII_PrimaryInit_code_5B6_4A:  /* set up and call _SwapMMUMode */
    movew %sp@+,%sr
    movel %a4,BusErrorVector
    movew %sp@+,%d0
    _SwapMMUMode
    addqw #3,%d1
    cmpw %d1,%d2
    moveml %sp@+,%d0-%d2/%a2-%a5
    rts
DECL_SR7F_01_MacII_PrimaryInit_code_614:  /* set %sp@- */
    movel %d0,%sp@-	| 408F8C9A
    movew %sp@(14),%d0	| 408F8C9C
    andiw #-3648,%d0	| 408F8CA0
    cmpiw #320,%d0	| 408F8CA4
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_656	| 408F8CA8
    moveb %sp@(10),%d0	| 408F8CAA
    lsrb #4,%d0	| 408F8CAE
    cmpib #11,%d0	| 408F8CB0
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_656	| 408F8CB4
    moveb %sp@(20),%d0	| 408F8CB6
    cmpib #0xff,%d0	| 408F8CBA 408F8CBA cmpib #-1,%d0
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_656	| 408F8CBE
    cmpib #0xf0,%d0	| 408F8CC0 408F8CC0 cmpib #-16,%d0
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_656	| 408F8CC4
    movel %sp@,%d0	| 408F8CC6
    movel %a2,%sp@(90)	| 408F8CC8
    movew %sp@(4),%sp@(88)	| 408F8CCC
    clrw %sp@(94)	| 408F8CD2
    lea %sp@(88),%sp	| 408F8CD6
    rte	| 408F8CDA
DECL_SR7F_01_MacII_PrimaryInit_code_656:/* pop and jump through a4. After it, offset 0x536 of the table: delete every video sResource but 0xE0, gray the screen */
    movel %sp@+,%d0	| 408F8CDC
    jmp %a4@	| 408F8CDE
    lea %fp@(-56),%a0	| 408F8CE0
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586),%a1
    movew %a1@+,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_656_E:/* per video sResource */
    moveb %a1@+,%d2	| 408F8CEA
    cmpib #0xe0,%d2
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_1E
    moveb %d2,%a0@(50)
    moveq #49,%d0
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_656_1E:/* next. After the rts, offset 0x55E of the table: machines with sResource 0xBC. Docking state (if _DockingDispatch is implemented) */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_656_E	| 408F8CFA
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_154A_C),%a1
    jsr %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_12D4)
    rts
    movew #-22369,%d0
    .short  0xA746	| 408F8D0C _GetTrapAddress (flags 0x0700)
    moveal %a0,%a1
    movew %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_656_48),%d0
    .short  0xA746	| 408F8D14 _GetTrapAddress (flags 0x0700)
    cmpal %a0,%a1
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_4E
    subqw #4,%sp
    movel #1685021547,%sp@-
    clrl %sp@-
DECL_SR7F_01_MacII_PrimaryInit_code_656_48:/* _DockingDispatch (its trap word is also read above, to compare with _Unimplemented) */
    _DockingDispatch	| 408F8D24
    moveq #8,%d0
    andl %sp@+,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_656_4E:/* fp-84 = docked; if 0xDD5 bit 4: write 64 to byte +18 and set bit 3 of byte +33 of the device at decoder entry +52 */
    sne %fp@(-84)	| 408F8D2A
    btst #4,0xdd5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_70
    moveal 0xdd8,%a1
    addal %a1@,%a1
    moveal %a1@(52),%a1
    moveb #64,%a1@(18)
    bset #3,%a1@(33)
DECL_SR7F_01_MacII_PrimaryInit_code_656_70:/* bits 0-2 of byte +1 of the device at decoder entry +56, with bus errors caught by _656_1EA (-1 = no device); -1 quits. Else its 11-byte register record */
    movec %vbr,%a2	| 408F8D4C
    movel %a2@(8),%sp@-
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_656_1EA),%a0
    movel %a0,%a2@(8)
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(56),%a0
    moveq #7,%d0
    andb %a0@(1),%d0
    movel %sp@+,%a2@(8)
    cmpil #-1,%d0
    beqw DECL_SR7F_01_MacII_PrimaryInit_code_188
    movel %d0,%d2
    muluw #11,%d0
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_656_18A),%a2
    addal %d0,%a2
    addqw #3,%a0
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    lea %a0@(18),%a0
    moveb %a2@+,%a0@+
    movew %a2@+,%a0@+
    btst #4,0xdd5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_E6
    moveq #-127,%d0
    tstb %fp@(-84)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_D0
    moveq #1,%d0
    bclr #3,%a1@(33)
DECL_SR7F_01_MacII_PrimaryInit_code_656_D0:/* Power Manager command 17: one byte, 0x81 (1 when docked) */
    moveb %d0,%sp@-	| 408F8DAC
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #1,%sp@-
    movew #17,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(14),%sp
DECL_SR7F_01_MacII_PrimaryInit_code_656_E6:/* PRAM: sResource 0xBC and the mode by configuration */
    moveb #0xbc,%d3	| 408F8DC2
    lea %fp@(-56),%a0
    lea %fp@(-64),%a2
    movel %a2,%a0@
    moveq #17,%d0
    _SlotManager
    cmpb %a2@(4),%d3
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_114
    moveb %d3,%a2@(4)
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_656_1E2),%a1
    moveb %a1@(0x0,%d2:w),%a2@(2)
    movel %a2,%a0@(4)
    moveq #18,%d0
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_656_114:/* delete the video sResources other than 0xBC */
    lea %fp@(-56),%a0	| 408F8DF0
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586),%a1
    movew %a1@+,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_656_11E:/* per sResource */
    moveb %a1@+,%d2	| 408F8DFA
    moveb %d2,%a0@(50)
    cmpb %d3,%d2
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_12E
    moveq #49,%d0
    _SlotManager
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_144
DECL_SR7F_01_MacII_PrimaryInit_code_656_12E:/* docked: disable 0xBC instead */
    tstb %fp@(-84)	| 408F8E0A
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_144
    movel #1,%a0@(24)
    clrl %a0@(4)
    moveq #9,%d0
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_656_144:/* next; if not docked: gray the screen, and if 0xDD5 bit 5, Power Manager command 224 with bytes 0x00, 0xEA, 0x0E */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_656_11E	| 408F8E20
    tstb %fp@(-84)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_188
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_154A_C),%a1
    bsrw DECL_SR7F_01_MacII_PrimaryInit_code_12D4
    btst #5,0xdd5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_178
    movel #15339008,%sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #3,%sp@-
    movew #224,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(16),%sp
DECL_SR7F_01_MacII_PrimaryInit_code_656_178:/* set bit 5 of register +4 */
    moveal 0xdd8,%a0	| 408F8E54
    addal %a0@,%a0
    moveal %a0@(56),%a0
    bset #5,%a0@(4)
DECL_SR7F_01_MacII_PrimaryInit_code_656_188:/* return */
    rts	| 408F8E64
DECL_SR7F_01_MacII_PrimaryInit_code_656_18A:/* the 11-byte register records, by configuration id */
    .byte   0x10, 0x00, 0x64, 0x80, 0x80, 0x02, 0x05, 0xA0, 0x00, 0x00, 0x03, 0x12, 0x00, 0x64, 0x80, 0x80	| 408F8E66
    .byte   0x02, 0x05, 0xFF, 0x00, 0x00, 0x03, 0x10, 0x00, 0x64, 0x80, 0x80, 0x02, 0x05, 0xFF, 0x00, 0x00	| 408F8E76
    .byte   0x03, 0x10, 0x00, 0x64, 0x80, 0x80, 0x02, 0x05, 0xA0, 0x00, 0x00, 0x03, 0x10, 0x00, 0x64, 0x80	| 408F8E86
    .byte   0x80, 0x05, 0x05, 0xA0, 0x00, 0x00, 0x03, 0x10, 0x00, 0x64, 0x80, 0x80, 0x05, 0x05, 0xA0, 0x00	| 408F8E96
    .byte   0x00, 0x03, 0x10, 0x00, 0x63, 0x00, 0x80, 0x05, 0x05, 0x9C, 0x00, 0x00, 0x03, 0x10, 0x00, 0x64	| 408F8EA6
    .byte   0x80, 0x80, 0x05, 0x05, 0xA0, 0x00, 0x00, 0x03	| 408F8EB6
DECL_SR7F_01_MacII_PrimaryInit_code_656_1E2:/* the PRAM mode, by configuration id */
    .byte   0x82, 0x82, 0x82, 0x82, 0x81, 0x81, 0x82, 0x00	| 408F8EBE
DECL_SR7F_01_MacII_PrimaryInit_code_656_1EA:/* (raw) bus error handler for _656_70, 68030 stack frame: clears RC, RB and DF in the SSW so the cycle is not rerun, -1 as the data read, %d0 = -1, rte. At +0x14: table entry of the Quadra 800 family (fp-80 = 1). At +0x1C: table entry of the Quadra 700/900/950 (fp-80 = 0) */
    .byte   0x30, 0x2F, 0x00, 0x0A, 0x02, 0x40, 0xCE, 0xFF, 0x3F, 0x40, 0x00, 0x0A, 0x70, 0xFF, 0x2F, 0x40	| 408F8EC6
    .byte   0x00, 0x2C, 0x4E, 0x73	| 408F8ED6
    moveb #1,%fp@(-80)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_20A
    clrb %fp@(-80)
DECL_SR7F_01_MacII_PrimaryInit_code_656_20A:/* 32-bit mode; the sense line in fp-67 */
    moveq #1,%d0	| 408F8EE6
    _SwapMMUMode
    moveb %d0,%fp@(-68)
    tstb %fp@(-80)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_222
    moveal ghost_VIA2,%a0
    btst #5,%a0@
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_22C
DECL_SR7F_01_MacII_PrimaryInit_code_656_222:/* VIA1 +0x1E00 bit 4 for Quadra 800 family (the other: VIA2 bit 5) */
    moveal VIA,%a0	| 408F8EFE
    btst #4,%a0@(7680)
DECL_SR7F_01_MacII_PrimaryInit_code_656_22C:/* fp-67 = line low; DAFB registers: the first 12 from the table, 30 at +256 cleared */
    seq %fp@(-67)	| 408F8F08
    moveal 0xdd8,%a4
    moveal %a4,%a3
    addal %a3@,%a3
    moveal %a3@(104),%a3
    moveal %a3,%a2
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_656_25A),%a1
    moveq #11,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_656_244:/* loop */
    movel %a1@+,%a2@+	| 408F8F20
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_656_244
    moveal %a3,%a2
    lea %a2@(256),%a2
    moveq #29,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_656_252:/* loop */
    clrl %a2@+	| 408F8F2E
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_656_252
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_28A
DECL_SR7F_01_MacII_PrimaryInit_code_656_25A:/* first 12 DAFB register values */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408F8F36
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07	| 408F8F46
    .byte   0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408F8F56
DECL_SR7F_01_MacII_PrimaryInit_code_656_28A:/* Quadra 800 family, line high and VIA1 bit 2 set: register +288 bit 7 */
    tstb %fp@(-80)	| 408F8F66
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_2A6
    tstb %fp@(-67)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_2A6
    btst #2,%a0@(7680)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_2A6
    oril #128,%a3@(288)
DECL_SR7F_01_MacII_PrimaryInit_code_656_2A6:/* identify the RAMDAC: index 6 read back; fp-78 = it is 6; fp-79 = its index 1 is not 0 */
    clrl %a3@(512)	| 408F8F82
    nop
    movel #6,%a3@(544)
    nop
    movel #1,%a3@(512)
    nop
    clrl %a3@(544)
    nop
    clrl %a3@(512)
    nop
    movel %a3@(544),%d0
    andil #15,%d0
    cmpib #6,%d0
    seq %fp@(-78)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_302
    movel #1,%a3@(512)
    nop
    movel %a3@(544),%d0
    andil #15,%d0
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_2FE
    moveb #1,%fp@(-79)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_302
DECL_SR7F_01_MacII_PrimaryInit_code_656_2FE:/* 0 */
    clrb %fp@(-79)	| 408F8FDA
DECL_SR7F_01_MacII_PrimaryInit_code_656_302:/* the timing record for the first mode */
    tstb %fp@(-80)	| 408F8FDE
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_30E
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586_1B0),%a1
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_312
DECL_SR7F_01_MacII_PrimaryInit_code_656_30E:/* Quadra 800 family's record */
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586_1F8),%a1	| 408F8FEA
DECL_SR7F_01_MacII_PrimaryInit_code_656_312:/* program the RAMDAC (P_1306_EC + 0xC), base address 4096, the timing fields */
    moveq #0,%d0	| 408F8FEE
    moveal %a3,%a2
    movel %a1,%fp@(-72)
    clrb %fp@(-81)
    bsrw DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC+0xc
    movel #4096,%d0
    andil #2097151,%d0
    lsrl #5,%d0
    movel %d0,%a2@(4)
    andil #15,%a2@(4)
    lsrl #4,%d0
    movel %d0,%a2@
    movew %a1@(36),%a2@(10)
    movew %a1@(40),%a2@(18)
    tstb %fp@(-67)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_386
    tstb %fp@(-80)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_362
    oril #2048,%a2@(16)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_386
DECL_SR7F_01_MacII_PrimaryInit_code_656_362:/* Quadra 800 family: registers +16 bits 9 (and 11) */
    andil #4092,%a2@(16)	| 408F903E
    oril #512,%a2@(16)
    subqw #2,%sp
    movew %a2@(290),%sp@
    andiw #128,%sp@+
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_386
    oril #2560,%a2@(16)
DECL_SR7F_01_MacII_PrimaryInit_code_656_386:/* the timing fields into registers +294..+358; reset sequence on +32: 3, 7, 3, 2, 0 */
    movew %a1@(62),%a2@(362)	| 408F9062
    movel #4082,%a3@(256)
    movew %a1@(42),%a2@(294)
    movew %a1@(44),%a2@(298)
    movew %a1@(46),%a2@(302)
    movew %a1@(48),%a2@(306)
    movew %a1@(50),%a2@(310)
    movew %a1@(52),%a2@(314)
    movew %a1@(54),%a2@(318)
    movew %a1@(56),%a2@(322)
    movew %a1@(58),%a2@(326)
    movew %a1@(60),%a2@(330)
    movew %a1@(22),%a2@(334)
    movew %a1@(24),%a2@(338)
    movew %a1@(26),%a2@(342)
    movew %a1@(28),%a2@(346)
    movew %a1@(30),%a2@(350)
    movew %a1@(32),%a2@(354)
    movew %a1@(34),%a2@(358)
    movel #3,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F90DE
    tstb @(VIA,%za0)@(0)	| 408F90E4
    tstb @(VIA,%za0)@(0)	| 408F90EA
    movel #7,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F90F8
    tstb @(VIA,%za0)@(0)	| 408F90FE
    tstb @(VIA,%za0)@(0)	| 408F9104
    movel #3,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F9112
    tstb @(VIA,%za0)@(0)	| 408F9118
    tstb @(VIA,%za0)@(0)	| 408F911E
    movel #2,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F912C
    tstb @(VIA,%za0)@(0)	| 408F9132
    tstb @(VIA,%za0)@(0)	| 408F9138
    clrl %a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F9142
    tstb @(VIA,%za0)@(0)	| 408F9148
    tstb @(VIA,%za0)@(0)	| 408F914E
    clrl %a3@(260)
    moveal %a4,%a0
    addal %a4@(8),%a0
    moveal %a0@(4),%a0
    movel %a0,%fp@(-76)
    moveq #7,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_656_48C:/* video memory size: read to settle, write signatures '2MEG', '1.5M', '1meg', '512K', see which survive */
    tstl %a0@(0x1ffffc,%za0)	| 408F9168
    tstl %a0@(0x17fffc,%za0)	| 408F9170
    tstl %a0@(0xffffc,%za0)	| 408F9178
    tstl %a0@(0x7fffc,%za0)	| 408F9180
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_656_48C
    movel #843924807,%a0@(0x1ffffc,%za0)	| 408F918C
    nop
    movel #825111885,%a0@(0x17fffc,%za0)	| 408F919A
    nop
    movel #829252967,%a0@(0xffffc,%za0)	| 408F91A8
    nop
    movel #892416587,%a0@(0x7fffc,%za0)	| 408F91B6
    nop
    moveq #2,%d2
    cmpil #829252967,%a0@(0xffffc,%za0)	| 408F91C6
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_518
    subqw #1,%d2
    cmpil #825111885,%a0@(0x17fffc,%za0)	| 408F91D6
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_518
    cmpil #843924807,%a0@(0x1ffffc,%za0)	| 408F91E4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_518
    subqw #1,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_656_518:/* d2 = size code (2, 1 or 0) into register +288 bits 9-10; bit 3 for Quadra 800 family */
    movel %a3@(288),%d0	| 408F91F4
    bfins %d2,%d0,21,2
    tstb %fp@(-80)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_52A
    bset #3,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_656_52A:/* bit 6 from fp-79 */
    tstb %fp@(-79)	| 408F9206
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_534
    bset #6,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_656_534:/* bit 11 clear, +256 = 4081; PRAM bit 5 to fp-83 */
    movel %d0,%a3@(288)	| 408F9210
    andil #-2049,%a2@(288)
    movel #4081,%a2@(256)
    clrb %fp@(-82)
    clrb %fp@(-83)
    lea %fp@(-64),%a0
    bclr #5,%a0@(6)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_562
    moveb #1,%fp@(-83)
DECL_SR7F_01_MacII_PrimaryInit_code_656_562:/* read the three sense lines (register +28): 3 = extended, 5, 6, 7 = extended no-connect; else use d4 as the monitor */
    moveq #0,%d4	| 408F923E
    clrl %sp@-
    movel %a2@(28),%sp@
    notb %sp@(3)
    andib #7,%sp@(3)
    moveb %sp@(3),%d4
    tstl %sp@+
    movel #7,%a2@(28)
    tstb @(VIA,%za0)@(0)	| 408F925E
    tstb @(VIA,%za0)@(0)	| 408F9264
    tstb @(VIA,%za0)@(0)	| 408F926A
    cmpib #3,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_5B0
    cmpib #5,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_5EE
    cmpib #6,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_5F2
    cmpib #7,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_5FA
    braw DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4
DECL_SR7F_01_MacII_PrimaryInit_code_656_5B0:/* code 3: extended sense; 49 and 52 are special */
    bsrw DECL_SR7F_01_MacII_PrimaryInit_code_1306	| 408F928C
    cmpib #49,%d4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_5D0
DECL_SR7F_01_MacII_PrimaryInit_code_656_5BA:/* 49: register +288 bits 4 and 5 set; monitor 0 */
    movel %a3@(288),%d0	| 408F9296
    bset #4,%d0
    bset #5,%d0
    movel %d0,%a3@(288)
    clrb %d4
    braw DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4
DECL_SR7F_01_MacII_PrimaryInit_code_656_5D0:/* 52 */
    cmpib #52,%d4	| 408F92AC
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_5E6
DECL_SR7F_01_MacII_PrimaryInit_code_656_5D6:/* 52: bit 4 set, bit 5 clear */
    movel %a3@(288),%d0	| 408F92B2
    bset #4,%d0
    bclr #5,%d0
    movel %d0,%a3@(288)
DECL_SR7F_01_MacII_PrimaryInit_code_656_5E6:/* monitor 3 */
    moveb #3,%d4	| 408F92C2
    braw DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4
DECL_SR7F_01_MacII_PrimaryInit_code_656_5EE:/* code 5 */
    braw DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4	| 408F92CA
DECL_SR7F_01_MacII_PrimaryInit_code_656_5F2:/* code 6: monitor 3, unless PRAM overrides */
    moveb #3,%d4	| 408F92CE
    braw DECL_SR7F_01_MacII_PrimaryInit_code_656_69E
DECL_SR7F_01_MacII_PrimaryInit_code_656_5FA:/* code 7: extended sense; 63 = nothing connected; else mapped by the table */
    bsrw DECL_SR7F_01_MacII_PrimaryInit_code_1306	| 408F92D6
    cmpib #63,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_626
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_656_618),%a1
DECL_SR7F_01_MacII_PrimaryInit_code_656_608:/* loop */
    moveb %a1@+,%d0	| 408F92E4
    bmis DECL_SR7F_01_MacII_PrimaryInit_code_656_626
    moveb %a1@+,%d1
    cmpb %d0,%d4
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_608
    moveb %d1,%d4
    braw DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4
DECL_SR7F_01_MacII_PrimaryInit_code_656_618:/* extended sense code to monitor: pairs, 0xFF ends */
    .byte   0x30, 0x09, 0x00, 0x09, 0x14, 0x04, 0x17, 0x08, 0x2D, 0x0A, 0x3A, 0x0B, 0xFF, 0xFF	| 408F92F4
DECL_SR7F_01_MacII_PrimaryInit_code_656_626:/* no monitor sensed: monitor 7, or the override in parameter RAM 0xFC (4-character codes) */
    moveb #7,%d4	| 408F9302
    subqw #4,%sp
    moveal %sp,%a0
    movew #4,%d0
    swap %d0
    movew #252,%d0
    _ReadXPRam
    movel %sp@+,%d0
    beqw DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_656_656),%a1
DECL_SR7F_01_MacII_PrimaryInit_code_656_644:/* loop */
    movel %a1@+,%d1	| 408F9320
    beqw DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4
    movel %a1@+,%d3
    cmpl %d0,%d1
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_644
    moveb %d3,%d4
    braw DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4
DECL_SR7F_01_MacII_PrimaryInit_code_656_656:/* override codes and their monitors: 'RNIN' 6, 'SRNN' 2, 'RN12' 2, 'RN13' 6, 'RN15' 5, 'RN16' 10, 'RN19' 11, 'RN21' 0 */
    .byte   0x52, 0x4E, 0x49, 0x4E, 0x00, 0x00, 0x00, 0x06, 0x53, 0x52, 0x4E, 0x4E, 0x00, 0x00, 0x00, 0x02	| 408F9332
    .byte   0x52, 0x4E, 0x31, 0x32, 0x00, 0x00, 0x00, 0x02, 0x52, 0x4E, 0x31, 0x33, 0x00, 0x00, 0x00, 0x06	| 408F9342
    .byte   0x52, 0x4E, 0x31, 0x35, 0x00, 0x00, 0x00, 0x05, 0x52, 0x4E, 0x31, 0x36, 0x00, 0x00, 0x00, 0x0A	| 408F9352
    .byte   0x52, 0x4E, 0x31, 0x39, 0x00, 0x00, 0x00, 0x0B, 0x52, 0x4E, 0x32, 0x31, 0x00, 0x00, 0x00, 0x00	| 408F9362
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408F9372
DECL_SR7F_01_MacII_PrimaryInit_code_656_69E:/* code 6: PRAM byte 7 bit 6: a user-set monitor */
    lea %fp@(-64),%a2	| 408F937A
    moveb %a2@(7),%d0
    andib #64,%d0
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_6BA
    cmpib #3,%d4
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_6B4
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4
DECL_SR7F_01_MacII_PrimaryInit_code_656_6B4:/* no setting: monitor 6 */
    moveb #6,%d4	| 408F9390
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4
DECL_SR7F_01_MacII_PrimaryInit_code_656_6BA:/* the setting; PRAM bit 5 set */
    moveb %a2@(7),%d4	| 408F9396
    andib #63,%d4
    bset #5,%a2@(6)
    tstb %fp@(-83)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_6D4
    moveb #1,%fp@(-82)
DECL_SR7F_01_MacII_PrimaryInit_code_656_6D4:/* 49 and 52 as above */
    cmpib #49,%d4	| 408F93B0
    beqw DECL_SR7F_01_MacII_PrimaryInit_code_656_5BA
    cmpib #52,%d4
    beqw DECL_SR7F_01_MacII_PrimaryInit_code_656_5D6
DECL_SR7F_01_MacII_PrimaryInit_code_656_6E4:/* monitor d4: the table at P_1586_58 (8 bytes each) gives the extra sResources and, by memory size, the sResource id (d5); PRAM bytes */
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586_58),%a0	| 408F93C0
    lea %a0@(0x0,%d4:w:8),%a0
    movel %a0@(0:w),%d7	| 408F93C8
    moveb %a0@(0x5,%d2:w),%d5
    moveq #0,%d6
    moveb %d4,%d6
    lea %fp@(-64),%a2
    moveb %d6,%a2@(5)
    bclr #1,%a2@(6)
    bclr #4,%a2@(6)
    bset #3,%a2@(6)
    tstb %fp@(-78)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_78A
    bset #1,%a2@(6)
    cmpib #0xc2,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_72A
    cmpib #2,%d2
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_78A
DECL_SR7F_01_MacII_PrimaryInit_code_656_72A:/* 16-bit capable RAMDAC (fp-78): is the extra VRAM usable? */
    tstb %fp@(-80)	| 408F9406
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_748
    tstb %fp@(-67)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_750
    movel %a3@(44),%d0
    andiw #4095,%d0
    moveq #9,%d1
    lsrw %d1,%d0
    cmpib #2,%d0
    blts DECL_SR7F_01_MacII_PrimaryInit_code_656_750
DECL_SR7F_01_MacII_PrimaryInit_code_656_748:/* yes: PRAM bit 2 */
    bset #2,%a2@(6)	| 408F9424
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_758
DECL_SR7F_01_MacII_PrimaryInit_code_656_750:/* no: only if PRAM bit 2 is set */
    btst #2,%a2@(6)	| 408F942C
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_78A
DECL_SR7F_01_MacII_PrimaryInit_code_656_758:/* the 16-bit sResource table (P_1586_B8); PRAM bit 4; 0xEC becomes 0xEE with fp-79 */
    cmpib #0xa0,%d5	| 408F9434
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_78A
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586_B8),%a0
    lea %a0@(0x0,%d6:w:8),%a0
    movel %a0@(0:w),%d7	| 408F9442
    moveb %a0@(0x5,%d2:w),%d5
    cmpib #0xe2,%d5
    blts DECL_SR7F_01_MacII_PrimaryInit_code_656_78A
    bset #4,%a2@(6)
    tstb %fp@(-79)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_78A
    cmpib #0xec,%d5
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_78A
    moveb #0xee,%d5
DECL_SR7F_01_MacII_PrimaryInit_code_656_78A:/* PRAM's sResource still valid? else update */
    cmpb %a2@(4),%d5	| 408F9466
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_7A4
    moveb %a2@(6),%d0
    lsrb #5,%d0
    andib #1,%d0
    moveb %fp@(-83),%d1
    cmpb %d0,%d1
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_7C0
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_7C6
DECL_SR7F_01_MacII_PrimaryInit_code_656_7A4:/* new: sResource id and its default mode (P_1586_180) */
    moveb %d5,%a2@(4)	| 408F9480
    moveb %d5,%a2@(3)
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586_180),%a0
    lea %a0@(0x0,%d6:w:4),%a0
    moveb %a0@(0x0,%d2:w),%a2@(2)
    tstb %fp@(-82)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_7C6
DECL_SR7F_01_MacII_PrimaryInit_code_656_7C0:/* PRAM bit 0 */
    bset #0,%a2@(6)	| 408F949C
DECL_SR7F_01_MacII_PrimaryInit_code_656_7C6:/* write PRAM; extras in d7 by memory size */
    lea %fp@(-56),%a0	| 408F94A2
    movel %a2,%a0@(4)
    moveq #18,%d0
    _SlotManager
    moveb %a2@(3),%d5
    tstl %d7
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_7FE
    tstb %d2
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_7F2
    cmpib #1,%d2
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_7EC
    andil #-258,%d7
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_7F2
DECL_SR7F_01_MacII_PrimaryInit_code_656_7EC:/* size 2 */
    andil #65278,%d7	| 408F94C8
DECL_SR7F_01_MacII_PrimaryInit_code_656_7F2:/* Quadra 800 family: the low word only */
    tstb %fp@(-80)	| 408F94CE
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_7FE
    andil #65535,%d7
DECL_SR7F_01_MacII_PrimaryInit_code_656_7FE:/* delete every video sResource but d5 and the extras */
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586),%a1	| 408F94DA
    movew %a1@+,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_656_804:/* per sResource */
    moveb %a1@+,%a0@(50)	| 408F94E0
    cmpb %a0@(50),%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_824
    tstl %d7
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_820
    moveq #3,%d3
DECL_SR7F_01_MacII_PrimaryInit_code_656_814:/* loop over the 4 extras */
    cmpb %a0@(50),%d7	| 408F94F0
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_82A
    roll #8,%d7
    dbf %d3,DECL_SR7F_01_MacII_PrimaryInit_code_656_814
DECL_SR7F_01_MacII_PrimaryInit_code_656_820:/* delete */
    moveq #49,%d0	| 408F94FC
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_656_824:/* next */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_656_804	| 408F9500
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_83C
DECL_SR7F_01_MacII_PrimaryInit_code_656_82A:/* an extra: disable it instead */
    movel #1,%a0@(24)	| 408F9506
    clrl %a0@(4)
    moveq #9,%d0
    _SlotManager
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_824
DECL_SR7F_01_MacII_PrimaryInit_code_656_83C:/* 0xA0: no video here: done */
    cmpib #0xa0,%d5	| 408F9518
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_846
    braw DECL_SR7F_01_MacII_PrimaryInit_code_656_C76
DECL_SR7F_01_MacII_PrimaryInit_code_656_846:/* this sResource's timing block (type 3,1,1,28; id 126; a variant 0xFD or 0xFE by +288 bits 4, 5); its base offset */
    lea %fp@(-56),%a0	| 408F9522
    clrw %a0@(50)
    clrb %a0@(48)
    movew #1,%a0@(40)
    clrw %a0@(42)
    clrw %a0@(44)
    clrw %a0@(46)
    clrl %a0@(24)
    bset #1,%a0@(27)
    moveq #12,%d0
    _SlotManager
    moveb #126,%a0@(50)
    moveq #6,%d0
    _SlotManager
    moveb %d5,%d1
    movel %a3@(288),%d0
    btst #4,%d0
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_898
    btst #5,%d0
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_894
    moveb #0xfd,%d1
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_898
DECL_SR7F_01_MacII_PrimaryInit_code_656_894:/* 0xFE */
    moveb #0xfe,%d1	| 408F9570
DECL_SR7F_01_MacII_PrimaryInit_code_656_898:/* load it (fp-72); minor base (+10) added to fp-76; program RAMDAC; monitor 2 of the other family: register +0 = 7 */
    moveb %d1,%a0@(50)	| 408F9574
    moveq #5,%d0
    _SlotManager
    moveal %a0@,%a1
    movel %a1,%fp@(-72)
    moveb %d5,%a0@(50)
    moveq #22,%d0
    _SlotManager
    moveb #10,%a0@(50)
    moveq #2,%d0
    _SlotManager
    movel %a0@,%d0
    addl %d0,%fp@(-76)
    moveq #0,%d0
    moveal %a3,%a2
    moveb #1,%fp@(-81)
    bsrw DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC+0xc
    tstb %fp@(-80)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_8E4
    cmpib #2,%d6
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_8E4
    movel #7,%a2@
    clrl %a2@(4)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_900
DECL_SR7F_01_MacII_PrimaryInit_code_656_8E4:/* the base address, registers +4 and +0 */
    movel %fp@(-76),%d0	| 408F95C0
    andil #2097151,%d0
    lsrl #5,%d0
    movel %d0,%a2@(4)
    andil #15,%a2@(4)
    lsrl #4,%d0
    movel %d0,%a2@
DECL_SR7F_01_MacII_PrimaryInit_code_656_900:/* timing fields */
    movew %a1@(36),%a2@(10)	| 408F95DC
    movew %a1@(40),%a2@(18)
    tstb %fp@(-67)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_946
    tstb %fp@(-80)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_922
    oril #2048,%a2@(16)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_946
DECL_SR7F_01_MacII_PrimaryInit_code_656_922:/* Quadra 800 family: registers +16 bits 9 (and 11) */
    andil #4092,%a2@(16)	| 408F95FE
    oril #512,%a2@(16)
    subqw #2,%sp
    movew %a2@(290),%sp@
    andiw #128,%sp@+
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_946
    oril #2560,%a2@(16)
DECL_SR7F_01_MacII_PrimaryInit_code_656_946:/* timing fields into +294..+358; RAMDAC mode (+546); zero 6 color entries */
    movew %a1@(62),%a2@(362)	| 408F9622
    movew %a1@(42),%a2@(294)
    movew %a1@(44),%a2@(298)
    movew %a1@(46),%a2@(302)
    movew %a1@(48),%a2@(306)
    movew %a1@(50),%a2@(310)
    movew %a1@(52),%a2@(314)
    movew %a1@(54),%a2@(318)
    movew %a1@(56),%a2@(322)
    movew %a1@(58),%a2@(326)
    movew %a1@(60),%a2@(330)
    movew %a1@(22),%a2@(334)
    movew %a1@(24),%a2@(338)
    movew %a1@(26),%a2@(342)
    movew %a1@(28),%a2@(346)
    movew %a1@(30),%a2@(350)
    movew %a1@(32),%a2@(354)
    movew %a1@(34),%a2@(358)
    clrl %a3@(512)
    movew %a1@(64),%a2@(546)
    nop
    tstl %a3@(512)
    moveq #0,%d0
    moveq #5,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_656_9C6:/* loop */
    moveb %d0,%a3@(531)	| 408F96A2
    tstb %fp@(-79)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_9D6
    tstb @(VIA,%za0)@(0)	| 408F96AC
DECL_SR7F_01_MacII_PrimaryInit_code_656_9D6:/* 16-bit RAMDAC: three more fields; Quadra 800 family: adjust by the row table */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_656_9C6	| 408F96B2
    tstb %fp@(-78)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_A34
    movew %a1@(66),%a2@(362)
    movew %a1@(68),%a2@(322)
    movew %a1@(70),%a2@(326)
    tstb %fp@(-80)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_A34
    moveq #32,%d1
    moveq #0,%d0
    movew %a1@(64),%d0
    bclr #7,%d0
    lsrw #5,%d0
    movew %d0,%d3
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_A0E
    lslw #1,%d0
    divuw %d0,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_656_A0E:/* adjust register +360; fp-79: also +320, +324 */
    addl %d1,%a2@(360)	| 408F96EA
    tstb %fp@(-79)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_A34
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_656_A2E),%a0
    movew %a0@(0x0,%d3:w:2),%d0
    addl %d0,%a2@(360)
    addl %d0,%a2@(320)
    addl %d0,%a2@(324)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_A34
DECL_SR7F_01_MacII_PrimaryInit_code_656_A2E:/* adjustments by timing word */
    .byte   0x00, 0x05, 0x00, 0x02, 0x00, 0x01	| 408F970A
DECL_SR7F_01_MacII_PrimaryInit_code_656_A34:/* the mode record (+72); PRAM bit 0 to register +12 bit 9 (Quadra 800 family) or VIA2 +0x1E00 bit 7 */
    lea %a1@(72),%a1	| 408F9710
    lea %fp@(-64),%a2
    tstb %fp@(-80)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_A5E
    movel %a3@(12),%d0
    btst #0,%a2@(6)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_A52
    moveq #0,%d1
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_A54
DECL_SR7F_01_MacII_PrimaryInit_code_656_A52:/* set */
    moveq #1,%d1	| 408F972E
DECL_SR7F_01_MacII_PrimaryInit_code_656_A54:/* store */
    bfins %d1,%d0,22,1	| 408F9730
    movel %d0,%a3@(12)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_A70
DECL_SR7F_01_MacII_PrimaryInit_code_656_A5E:/* the other family */
    btst #0,%a2@(6)	| 408F973A
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_A70
    moveal ghost_VIA2,%a0
    bclr #7,%a0@(7680)
DECL_SR7F_01_MacII_PrimaryInit_code_656_A70:/* register +24 from +16 bit 0 and PRAM bit 3 */
    movel %a3@(16),%d0	| 408F974C
    bfextu %d0,31,1,%d0
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_A86
    btst #3,%a2@(6)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_A8C
    moveq #1,%d0
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_A88
DECL_SR7F_01_MacII_PrimaryInit_code_656_A86:/* 0 */
    moveq #0,%d0	| 408F9762
DECL_SR7F_01_MacII_PrimaryInit_code_656_A88:/* store */
    movel %d0,%a3@(24)	| 408F9764
DECL_SR7F_01_MacII_PrimaryInit_code_656_A8C:/* +288 bit 11; +256 = 4082; reset sequence; then gray the screen */
    moveal %a3,%a2	| 408F9768
    oril #2048,%a2@(288)
    movel #4082,%a2@(256)
    movel #3,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F9782
    tstb @(VIA,%za0)@(0)	| 408F9788
    tstb @(VIA,%za0)@(0)	| 408F978E
    movel #7,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F979C
    tstb @(VIA,%za0)@(0)	| 408F97A2
    tstb @(VIA,%za0)@(0)	| 408F97A8
    movel #3,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F97B6
    tstb @(VIA,%za0)@(0)	| 408F97BC
    tstb @(VIA,%za0)@(0)	| 408F97C2
    movel #2,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F97D0
    tstb @(VIA,%za0)@(0)	| 408F97D6
    tstb @(VIA,%za0)@(0)	| 408F97DC
    clrl %a2@(32)
    tstb @(VIA,%za0)@(0)	| 408F97E6
    tstb @(VIA,%za0)@(0)	| 408F97EC
    tstb @(VIA,%za0)@(0)	| 408F97F2
    moveal %fp@(-76),%a2
    moveal %fp@(-72),%a0
    moveq #-1,%d3
    cmpib #2,%d6
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_B5E
    cmpib #0xd9,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_B64
    cmpib #0xdb,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_B64
    cmpib #0xd8,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_B64
    cmpib #0xda,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_B64
    cmpib #0xdd,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_B64
    cmpib #0xdf,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_B64
    cmpib #0xdc,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_B64
    cmpib #0xde,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_B64
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_B74
DECL_SR7F_01_MacII_PrimaryInit_code_656_B5E:/* monitor 2: 512 bytes of black above */
    movew #512,%d0	| 408F983A
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_B68
DECL_SR7F_01_MacII_PrimaryInit_code_656_B64:/* some sResources: 1024 bytes */
    movew #1024,%d0	| 408F9840
DECL_SR7F_01_MacII_PrimaryInit_code_656_B68:/* start earlier by that */
    subaw %d0,%a2	| 408F9844
    lsrw #2,%d0
    subqw #1,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_656_B6E:/* loop */
    movel %d3,%a2@+	| 408F984A
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_656_B6E
DECL_SR7F_01_MacII_PrimaryInit_code_656_B74:/* top border */
    movew %a1@(2),%d1	| 408F9850
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_B88
DECL_SR7F_01_MacII_PrimaryInit_code_656_B7A:/* per row */
    movew %a1@(4),%d0	| 408F9856
DECL_SR7F_01_MacII_PrimaryInit_code_656_B7E:/* loop */
    movel %d3,%a2@+	| 408F985A
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_656_B7E
    addaw %a1@(8),%a2
DECL_SR7F_01_MacII_PrimaryInit_code_656_B88:/* next; the visible rows, pattern 0xAAAAAAAA */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_656_B7A	| 408F9864
    movel #-1431655766,%d4
    movew %a0@(20),%d1
DECL_SR7F_01_MacII_PrimaryInit_code_656_B96:/* per row: left border */
    movew %a1@(6),%d0	| 408F9872
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_B9E
DECL_SR7F_01_MacII_PrimaryInit_code_656_B9C:/* loop */
    movel %d3,%a2@+	| 408F9878
DECL_SR7F_01_MacII_PrimaryInit_code_656_B9E:/* next; the row's longs */
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_656_B9C	| 408F987A
    movew %a1@,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_656_BA4:/* pattern (twice per step except for sResources 0xE8..0xEB) */
    movel %d4,%a2@+	| 408F9880
    cmpib #0xea,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_BC0
    cmpib #0xeb,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_BC0
    cmpib #0xe8,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_BC0
    cmpib #0xe9,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_BC0
    movel %d4,%a2@+
DECL_SR7F_01_MacII_PrimaryInit_code_656_BC0:/* next long; invert for the next row; right border */
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_656_BA4	| 408F989C
    notl %d4
    movew %a1@(6),%d0
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_BCE
DECL_SR7F_01_MacII_PrimaryInit_code_656_BCC:/* loop */
    movel %d3,%a2@+	| 408F98A8
DECL_SR7F_01_MacII_PrimaryInit_code_656_BCE:/* next; next row; bottom border */
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_656_BCC	| 408F98AA
    addaw %a1@(8),%a2
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_656_B96
    movew %a1@(2),%d1
    cmpib #0xd9,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C10
    cmpib #0xdb,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C10
    cmpib #0xd8,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C10
    cmpib #0xda,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C10
    cmpib #0xdd,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C10
    cmpib #0xdf,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C10
    cmpib #0xdc,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C10
    cmpib #0xde,%d5
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C10
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_C12
DECL_SR7F_01_MacII_PrimaryInit_code_656_C10:/* one more row for those sResources */
    addqw #1,%d1	| 408F98EC
DECL_SR7F_01_MacII_PrimaryInit_code_656_C12:/* bottom border */
    bras DECL_SR7F_01_MacII_PrimaryInit_code_656_C22	| 408F98EE
DECL_SR7F_01_MacII_PrimaryInit_code_656_C14:/* per row */
    movew %a1@(4),%d0	| 408F98F0
DECL_SR7F_01_MacII_PrimaryInit_code_656_C18:/* loop */
    movel %d3,%a2@+	| 408F98F4
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_656_C18
    addaw %a1@(8),%a2
DECL_SR7F_01_MacII_PrimaryInit_code_656_C22:/* next; two color table entries for the gray pattern (P_1586_118, by monitor; 12 for monitor type 52) */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_656_C14	| 408F98FE
    movew %d6,%d1
    movel %a3@(288),%d0
    btst #4,%d0
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C3C
    btst #5,%d0
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_656_C3C
    movew #12,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_656_C3C:/* RAMDAC index 0: two entries */
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586_118),%a0	| 408F9918
    lea %a0@(0x0,%d1:w:8),%a0
    clrl %a3@(512)
    lea %a3@(531),%a3
    moveq #0,%d0
    moveb %a0@(1),%a3@
    moveb %a0@(3),%a3@
    moveb %a0@(5),%a3@
    tstb %fp@(-79)
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_656_C66
    tstb @(VIA,%za0)@(0)	| 408F993C
DECL_SR7F_01_MacII_PrimaryInit_code_656_C66:/* free the timing block */
    moveb %a0@,%a3@	| 408F9942
    moveb %a0@(2),%a3@
    moveb %a0@(4),%a3@
    moveal %fp@(-72),%a0
    _DisposPtr
DECL_SR7F_01_MacII_PrimaryInit_code_656_C76:/* addressing mode back; return */
    moveb %fp@(-68),%d0	| 408F9952
    _SwapMMUMode
    rts

/* subroutine (70 instructions): traps SwapMMUMode (mechanical summary) */
DECL_SR7F_01_MacII_PrimaryInit_code_12D4:/* gray the screen: alternate rows of 0xAAAAAAAA / 0x55555555; a1 = row skip, longs, rows */
    moveal 0xdd8,%a0
    addal %a0@(8),%a0
    moveal %a0@(4),%a0
    movel #-1431655766,%d4
    movew %a1@,%d3
    movew %a1@(4),%d2
    moveq #1,%d0
    _SwapMMUMode
DECL_SR7F_01_MacII_PrimaryInit_code_12D4_1C:/* per row */
    movew %a1@(2),%d1
DECL_SR7F_01_MacII_PrimaryInit_code_12D4_20:/* loop: longs; next row inverts the pattern */
    movel %d4,%a0@+
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_12D4_20
    addaw %d3,%a0
    notl %d4
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_12D4_1C
    _SwapMMUMode
    rts

DECL_SR7F_01_MacII_PrimaryInit_code_1306:/* read the three-line monitor sense through DAFB register +28: lines driven 3, 5, 6 give the extended sense code in d4 */
    moveml %d0-%d1,%sp@-
    moveq #0,%d1
    moveq #0,%d0
    cmpib #3,%d4
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_1306_12
    moveb %d4,%d0
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_1306_4E
DECL_SR7F_01_MacII_PrimaryInit_code_1306_12:/* drive pattern 3, read back, restore 7, delay */
    movel #3,%a2@(28)
    clrl %sp@-
    movel %a2@(28),%sp@
    notb %sp@(3)
    andib #7,%sp@(3)
    moveb %sp@(3),%d0
    tstl %sp@+
    movel #7,%a2@(28)
    tstb @(VIA,%za0)@(0)	| 408F99C4
    tstb @(VIA,%za0)@(0)	| 408F99CA
    tstb @(VIA,%za0)@(0)	| 408F99D0
    andib #3,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_1306_4E:/* first two bits; next pattern */
    moveb %d0,%d1
    lslb #2,%d1
    cmpib #5,%d4
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_1306_5C
    moveb %d4,%d0
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_1306_98
DECL_SR7F_01_MacII_PrimaryInit_code_1306_5C:/* drive pattern 5 */
    movel #5,%a2@(28)
    clrl %sp@-
    movel %a2@(28),%sp@
    notb %sp@(3)
    andib #7,%sp@(3)
    moveb %sp@(3),%d0
    tstl %sp@+
    movel #7,%a2@(28)
    tstb @(VIA,%za0)@(0)	| 408F9A0E
    tstb @(VIA,%za0)@(0)	| 408F9A14
    tstb @(VIA,%za0)@(0)	| 408F9A1A
    andib #5,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_1306_98:/* bit 2 moved to bit 1 */
    bclr #2,%d0
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_1306_A2
    bset #1,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_1306_A2:/* next two bits; next pattern */
    orb %d0,%d1
    lslb #2,%d1
    cmpib #6,%d4
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_1306_B0
    moveb %d4,%d0
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC
DECL_SR7F_01_MacII_PrimaryInit_code_1306_B0:/* drive pattern 6 */
    movel #6,%a2@(28)
    clrl %sp@-
    movel %a2@(28),%sp@
    notb %sp@(3)
    andib #7,%sp@(3)
    moveb %sp@(3),%d0
    tstl %sp@+
    movel #7,%a2@(28)
    tstb @(VIA,%za0)@(0)	| 408F9A62
    tstb @(VIA,%za0)@(0)	| 408F9A68
    tstb @(VIA,%za0)@(0)	| 408F9A6E
    andib #6,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC:/* last bits: the code. After it: program DAFB from the timing record */
    lsrb #1,%d0
    orb %d0,%d1
    moveb %d1,%d4
    moveml %sp@+,%d0-%d1
    rts
    tstb %fp@(-67)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_46
    tstb %fp@(-80)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_22
    oril #2048,%a2@(16)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_46
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_22:/* boards with fp-80 set: register +16 bits */
    andil #4092,%a2@(16)
    oril #512,%a2@(16)
    subqw #2,%sp
    movew %a2@(290),%sp@
    andiw #128,%sp@+
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_46
    oril #2560,%a2@(16)
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_46:/* register +14, keeping bit 8 on those boards */
    tstb %fp@(-81)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_54
    movew %a1@(38),%a2@(14)
    bras DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_68
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_54:/* keep bit 8 */
    movel %a2@(12),%d0
    andil #256,%d0
    movew %a1@(38),%a2@(14)
    orl %d0,%a2@(12)
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_68:/* register block at +768, one value per 16 bytes */
    lea %a2@(768),%a2
    tstb %fp@(-80)
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_98
    movew #9,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_76:/* loop: 10 values from the record */
    moveb %a1@+,%d0
    movel %d0,%a2@
    lea %a2@(16),%a2
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_76
    lea %pc@(DECL_SR7F_01_MacII_PrimaryInit_code_1586_1B0_A),%a1	| 408F9AFA
    movew #5,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_8A:/* loop: 6 from the table */
    moveb %a1@+,%d0
    movel %d0,%a2@
    lea %a2@(16),%a2
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_8A
    bras DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_100
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_98:/* the other board: a serial clock chip, 21 sets of 3 fields */
    moveq #20,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_9A:/* per set */
    lea %a1@(10),%a1
    eoriw #8,%a1@
    cmpiw #1,%d1
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_B0
    eoriw #8,%a1@
    oriw #256,%a1@
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_B0:/* three fields */
    swap %d1
    movew #2,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_B6:/* 16 bits */
    moveq #15,%d3
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_B8:/* load the field */
    moveq #0,%d0
    movew %a1@+,%d0
    swap %d0
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_BE:/* loop: one bit at a time */
    roll #1,%d0
    moveb %d0,%a2@(3)
    nop
    dbf %d3,DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_BE
    cmpiw #1,%d1
    bnes DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_D6
    moveq #13,%d3
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_B8
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_D6:/* next field; latch */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_B6
    roll #1,%d0
    moveb %d0,%a2@(19)
    nop
    swap %d1
    moveal %fp@(-72),%a1
    btst #0,%d1
    beqs DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_FC
    movew #174,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_F2:/* delay */
    tstb @(VIA,%za0)@(0)
    dbf %d0,DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_F2
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_FC:/* next set */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_9A
DECL_SR7F_01_MacII_PrimaryInit_code_1306_EC_100:/* return */
    moveal %fp@(-72),%a1
    moveal %a3,%a2
    rts
DECL_SR7F_01_MacII_PrimaryInit_code_14FA:/* count - 1, then the CPU sResource ids, one per machine (BoxFlag + 1) */
    .byte   0x00, 0x1D, 0x01, 0x02, 0x03, 0x04, 0x06, 0x08, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x14, 0x15, 0x18	| 408F9B80
    .byte   0x1B, 0x21, 0x22, 0x35, 0x19, 0x1F, 0x2E, 0x1E, 0x36, 0x2F, 0x30, 0x34, 0x3A, 0x1C, 0x1D, 0x00	| 408F9B90
DECL_SR7F_01_MacII_PrimaryInit_code_151A:/* count - 1, then the BoxFlags that keep sResource 0xFA */
    .byte   0x00, 0x0F, 0x00, 0x0D, 0x01, 0x02, 0x03, 0x05, 0x07, 0x0C, 0x0F, 0x17, 0x1A, 0x20, 0x21, 0x13	| 408F9BA0
    .byte   0x1B, 0x1C	| 408F9BB0
DECL_SR7F_01_MacII_PrimaryInit_code_152C:/* count - 1, then the BoxFlags that keep sResource 0xFB; screen sizes for graying follow */
    .byte   0x00, 0x0D, 0x10, 0x0E, 0x14, 0x34, 0x18, 0x1E, 0x2D, 0x1D, 0x35, 0x2E, 0x2F, 0x33, 0x39, 0x00	| 408F9BB2
    .byte   0x00, 0x00	| 408F9BC2
DECL_SR7F_01_MacII_PrimaryInit_code_152C_12:
    .byte   0x00, 0x00, 0x00, 0x13, 0x03, 0x65	| 408F9BC4
DECL_SR7F_01_MacII_PrimaryInit_code_152C_18:
    .byte   0x00, 0x00, 0x00, 0x0F, 0x01, 0x7F	| 408F9BCA
DECL_SR7F_01_MacII_PrimaryInit_code_154A:/* more of those sizes */
    .byte   0x00, 0x00, 0x00, 0x13, 0x01, 0xDF	| 408F9BD0
DECL_SR7F_01_MacII_PrimaryInit_code_154A_6:
    .byte   0x00, 0x00, 0x00, 0x0F, 0x01, 0x55	| 408F9BD6
DECL_SR7F_01_MacII_PrimaryInit_code_154A_C:/* screen geometry used for graying (row skip, longs, rows) */
    .byte   0x00, 0x00, 0x00, 0x13, 0x01, 0x8F, 0x00, 0x00, 0x00, 0x13, 0x01, 0xDF	| 408F9BDC
DECL_SR7F_01_MacII_PrimaryInit_code_154A_C_C:
    .byte   0x03, 0xB0, 0x00, 0x13, 0x01, 0xDF	| 408F9BE8
DECL_SR7F_01_MacII_PrimaryInit_code_154A_C_12:
    .byte   0x03, 0xB0, 0x00, 0x13, 0x01, 0xDF	| 408F9BEE
DECL_SR7F_01_MacII_PrimaryInit_code_154A_C_18:
    .byte   0x03, 0xB8, 0x00, 0x11, 0x01, 0x7F, 0x01, 0xB0, 0x00, 0x13, 0x01, 0xDF, 0x01, 0xB0, 0x00, 0x13	| 408F9BF4
    .byte   0x01, 0xDF, 0x01, 0xB8, 0x00, 0x11, 0x01, 0x7F	| 408F9C04
DECL_SR7F_01_MacII_PrimaryInit_code_1586:/* count - 1, then every video sResource id; tables of the video PrimaryInit routines follow */
    .byte   0x00, 0x53, 0xA2, 0xAA, 0xB2, 0xBA, 0xA6, 0xAE, 0xA3, 0xAB, 0x86, 0x81, 0x82, 0x87, 0x96, 0x9E	| 408F9C0C
    .byte   0x8E, 0x91, 0x89, 0x92, 0x9A, 0x8A, 0x97, 0x9F, 0x8F, 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6	| 408F9C1C
    .byte   0xC7, 0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 0xD9, 0xD0, 0xD1, 0xDB, 0xD2, 0xD3, 0xDD	| 408F9C2C
    .byte   0xD4, 0xD5, 0xDF, 0xD6, 0xD7, 0xEA, 0xEB, 0xBE, 0xBF, 0xD8, 0xDA, 0xDC, 0xDE, 0xE2, 0xE3, 0xE4	| 408F9C3C
    .byte   0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEC, 0xEE, 0xED, 0xEF, 0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6	| 408F9C4C
    .byte   0xF7, 0xF9, 0xE0, 0xBD, 0xBC, 0xBB, 0x00, 0x00	| 408F9C5C
DECL_SR7F_01_MacII_PrimaryInit_code_1586_58:/* per monitor, 8 bytes: 4 extra sResources, then the sResource id by memory size */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0xCF, 0xCF, 0xCE, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC1, 0xC1, 0xC0	| 408F9C64
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0xC3, 0xC3, 0xC2, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC5, 0xC5, 0xC4	| 408F9C74
    .byte   0xD9, 0xDB, 0xD1, 0xD3, 0x00, 0xD1, 0xD0, 0xD0, 0x00, 0x00, 0x00, 0x00, 0x00, 0xCD, 0xCD, 0xCC	| 408F9C84
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0xC9, 0xC8, 0xC8, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0xA0, 0xA0	| 408F9C94
    .byte   0x00, 0x00, 0xCB, 0xEB, 0x00, 0xCB, 0xCA, 0xCA, 0xDD, 0xDF, 0xD5, 0xD7, 0x00, 0xD5, 0xD4, 0xD4	| 408F9CA4
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0xC7, 0xC6, 0xC6, 0x00, 0x00, 0x00, 0x00, 0x00, 0xBF, 0xBF, 0xBE	| 408F9CB4
DECL_SR7F_01_MacII_PrimaryInit_code_1586_B8:/* the same for 16-bit capable RAMDACs */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0xEF, 0xCF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC1, 0xC1, 0x00	| 408F9CC4
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0xEC, 0xEC, 0xEE, 0x00, 0x00, 0x00, 0x00, 0x00, 0xC5, 0xC5, 0x00	| 408F9CD4
    .byte   0xD8, 0xDA, 0xF1, 0xF3, 0x00, 0xF1, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xED, 0xCD, 0x00	| 408F9CE4
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0xE3, 0xE2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0xA0, 0xA0	| 408F9CF4
    .byte   0x00, 0x00, 0xE5, 0xE9, 0x00, 0xE5, 0xE4, 0x00, 0xDC, 0xDE, 0xF5, 0xF7, 0x00, 0xF5, 0xF4, 0x00	| 408F9D04
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0xE7, 0xE6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF9, 0xBF, 0x00	| 408F9D14
DECL_SR7F_01_MacII_PrimaryInit_code_1586_118:/* per monitor: two color table entries for the gray pattern */
    .byte   0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00	| 408F9D24
    .byte   0x05, 0xFF, 0x05, 0xFF, 0x05, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00	| 408F9D34
    .byte   0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00	| 408F9D44
    .byte   0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408F9D54
    .byte   0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00	| 408F9D64
    .byte   0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0x00	| 408F9D74
    .byte   0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00	| 408F9D84
DECL_SR7F_01_MacII_PrimaryInit_code_1586_180:/* per monitor, 4 bytes: the default mode by memory size */
    .byte   0x83, 0x83, 0x82, 0x00, 0x80, 0x80, 0x80, 0x00, 0x83, 0x83, 0x83, 0x00, 0x80, 0x80, 0x80, 0x00	| 408F9D8C
    .byte   0x83, 0x83, 0x83, 0x00, 0x83, 0x83, 0x82, 0x00, 0x83, 0x83, 0x83, 0x00, 0x00, 0x00, 0x00, 0x00	| 408F9D9C
    .byte   0x83, 0x83, 0x83, 0x00, 0x83, 0x83, 0x83, 0x00, 0x83, 0x83, 0x83, 0x00, 0x83, 0x83, 0x82, 0x00	| 408F9DAC
DECL_SR7F_01_MacII_PrimaryInit_code_1586_1B0:/* timing record for start-up (the other family) */
    .byte   0x08, 0x0F, 0x00, 0x00, 0x0F, 0x01, 0x00, 0x00, 0x00, 0x01	| 408F9DBC
DECL_SR7F_01_MacII_PrimaryInit_code_1586_1B0_A:
    .byte   0x05, 0x06, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x48, 0x06, 0x46	| 408F9DC6
    .byte   0x00, 0x04, 0x00, 0x09, 0x00, 0x40, 0x06, 0x40, 0x06, 0x44, 0x00, 0x80, 0x06, 0x06, 0x00, 0x30	| 408F9DD6
    .byte   0x01, 0x2A, 0x00, 0xA5, 0x00, 0x0C, 0x01, 0x4B, 0x00, 0x17, 0x00, 0x1A, 0x00, 0x23, 0x00, 0x3F	| 408F9DE6
    .byte   0x01, 0x3F, 0x01, 0x4A, 0x00, 0x29, 0x00, 0xC0, 0x00, 0x29, 0x00, 0x3F, 0x01, 0x3F	| 408F9DF6
DECL_SR7F_01_MacII_PrimaryInit_code_1586_1F8:/* timing record for start-up (the Quadra 800 family) */
    .byte   0x08, 0x0F, 0x00, 0x00, 0x0F, 0x01, 0x00, 0x00, 0x00, 0x01, 0x3C, 0x04, 0x00, 0x40, 0x04, 0x00	| 408F9E04
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x48, 0x06, 0x46, 0x00, 0x04, 0x00, 0x09, 0x00, 0x40	| 408F9E14
    .byte   0x06, 0x40, 0x06, 0x44, 0x00, 0x80, 0x07, 0x06, 0x00, 0x30, 0x01, 0x2A, 0x00, 0xA5, 0x00, 0x0C	| 408F9E24
    .byte   0x01, 0x4B, 0x00, 0x17, 0x00, 0x1A, 0x00, 0x23, 0x00, 0x3F, 0x01, 0x3F, 0x01, 0x4A, 0x00, 0x29	| 408F9E34
    .byte   0x00, 0xC0, 0x00, 0x29, 0x00, 0x3F, 0x01, 0x3F	| 408F9E44
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit:  /* the PrimaryInit (34) (pointed to by its entry) */
    .byte   0x00, 0x00, 0x06, 0xB8, 0x02, 0x02, 0x00, 0x00	| 408F9E4C
    .long   DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code-.	| 408F9E54

/* subroutine (11 instructions): traps SlotManager (mechanical summary) */
DECL_SR7F_01_MacII_PrimaryInit_code_17D2:/* delete every sResource of the list at a1 except d0 */
    moveb %d0,%sp@-
    movew %a1@+,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_17D6:/* loop */
    moveb %a1@+,%d0
    cmpb %sp@,%d0
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_17E4
    moveb %d0,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_17E4:/* next */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_17D6
    tstb %sp@+
    rts

/* subroutine (14 instructions): traps SlotManager (mechanical summary) */
DECL_SR7F_01_MacII_PrimaryInit_code_17EC:/* disable the same way (Slot Manager 10, flags 1) */
    moveb %d0,%sp@-
    movew %a1@+,%d1
DECL_SR7F_01_MacII_PrimaryInit_code_17F0:/* loop */
    moveb %a1@+,%d0
    cmpb %sp@,%d0
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_180E
    moveb %d0,%a0@(50)
    clrl %a0@(4)
    movel #1,%a0@(24)
    clrw %a0@(38)
    moveq #10,%d0	/* _SlotManager 10: INSERTSRT, sInsertSRTRec */
    _SlotManager
DECL_SR7F_01_MacII_PrimaryInit_code_180E:/* next */
    dbf %d1,DECL_SR7F_01_MacII_PrimaryInit_code_17F0
    tstb %sp@+
    rts

/* subroutine (60 instructions) (mechanical summary) */
DECL_SR7F_01_MacII_PrimaryInit_code_1816:/* the three-line sense through a VIA-style register (+2): patterns 3, 5, 6 give d6 */
    moveml %d0-%d1,%sp@-
    moveq #0,%d1
    moveq #0,%d0
    cmpib #3,%d6
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_1816_12
    moveb %d6,%d0
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_1816_48
DECL_SR7F_01_MacII_PrimaryInit_code_1816_12:/* drive pattern 3 */
    moveb #3,%a2@(2)
    movew #550,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_1816_1C:/* delay */
    tstb @(VIA,%za0)@(0)
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_1816_1C
    moveq #0,%d2
    moveb %a2@(2),%d2
    lsrb #4,%d2
    moveb %d2,%d0
    moveb #7,%a2@(2)
    movew #550,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_1816_3A:/* delay */
    tstb @(VIA,%za0)@(0)
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_1816_3A
    andib #3,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_1816_48:/* first two bits; next pattern */
    moveb %d0,%d1
    lslb #2,%d1
    cmpib #5,%d6
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_1816_56
    moveb %d6,%d0
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_1816_8C
DECL_SR7F_01_MacII_PrimaryInit_code_1816_56:/* drive pattern 5 */
    moveb #5,%a2@(2)
    movew #550,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_1816_60:/* delay */
    tstb @(VIA,%za0)@(0)
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_1816_60
    moveq #0,%d2
    moveb %a2@(2),%d2
    lsrb #4,%d2
    moveb %d2,%d0
    moveb #7,%a2@(2)
    movew #550,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_1816_7E:/* delay */
    tstb @(VIA,%za0)@(0)
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_1816_7E
    andib #5,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_1816_8C:/* bit 2 moved to bit 1 */
    bclr #2,%d0
    jbeq DECL_SR7F_01_MacII_PrimaryInit_code_1816_96
    bset #1,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_1816_96:/* next two bits; next pattern */
    orb %d0,%d1
    lslb #2,%d1
    cmpib #6,%d6
    jbne DECL_SR7F_01_MacII_PrimaryInit_code_1816_A4
    moveb %d6,%d0
    jbra DECL_SR7F_01_MacII_PrimaryInit_code_1816_DA
DECL_SR7F_01_MacII_PrimaryInit_code_1816_A4:/* drive pattern 6 */
    moveb #6,%a2@(2)
    movew #550,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_1816_AE:/* delay */
    tstb @(VIA,%za0)@(0)
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_1816_AE
    moveq #0,%d2
    moveb %a2@(2),%d2
    lsrb #4,%d2
    moveb %d2,%d0
    moveb #7,%a2@(2)
    movew #550,%d2
DECL_SR7F_01_MacII_PrimaryInit_code_1816_CC:/* delay */
    tstb @(VIA,%za0)@(0)
    dbf %d2,DECL_SR7F_01_MacII_PrimaryInit_code_1816_CC
    andib #6,%d0
DECL_SR7F_01_MacII_PrimaryInit_code_1816_DA:/* last bits: the code in d6 */
    lsrb #1,%d0
    orb %d0,%d1
    moveb %d1,%d6
    moveml %sp@+,%d0-%d1
    rts

/* subroutine (9 instructions): traps EgretDispatch (mechanical summary) */
DECL_SR7F_01_MacII_PrimaryInit_code_1816_E6:/* Egret call (command 270) with a 4-byte parameter */
    orib #87,%d0
    lea %fp@(-84),%a0
    movew #270,%a0@
    movel %d0,%a0@(2)
    movew #4,%a0@(6)
    clrw %a0@(14)
    clrl %a0@(16)
    _EgretDispatch
    rts

/* subroutine (333 instructions): traps SlotManager, EgretDispatch, SwapMMUMode, ReadXPRam, DisposPtr; calls DECL_SR7F_01_MacII_PrimaryInit_code_17D2, DECL_SR7F_01_MacII_PrimaryInit_code_1816_E6, DECL_SR7F_01_MacII_PrimaryInit_code_1816, DECL_SR7F_01_MacII_PrimaryInit_code_17EC (mechanical summary) */

/*
 PrimaryInit of the built-in video: identifies the monitor connected (its sense lines),
 picks the video sResource for it, sets up the video hardware and its first mode from
 the settings in PRAM (through Egret on some machines). Inferred from the code (traps
 used: SlotManager, EgretDispatch, ReadXPRam, SwapMMUMode).
*/
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code:
    linkw %fp,#-100
    movew #1,%a0@(2)
    clrb %fp@(-7)
    clrb %fp@(-5)
    moveal 0xdd8,%a4
    lea %fp@(-56),%a0
    lea %fp@(-64),%a2
    movel %a2,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    moveal %a4,%a3
    addal %a3@(8),%a3
    tstw %a2@
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_56
    moveb %a3@(15),%a0@(50)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    moveb #32,%a0@(50)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    movew %a0@(2),%a2@
    clrb %a2@(6)
    clrb %a2@(7)
    movel %a2,%a0@(4)
    moveq #51,%d0	/* _SlotManager 51: INITSLOTPRAM */
    _SlotManager
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_56:  /* address %pc@(DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_440) */
    lea %pc@(DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_440),%a1
    moveb %a3@(15),%d0
    jbsr DECL_SR7F_01_MacII_PrimaryInit_code_17D2
    btst #2,%a2@(6)
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_6E
    clrb %d0
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_72
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_6E:  /* set %d0 */
    moveb #0xff,%d0
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_72:  /* address %fp@(-84) */
    lea %fp@(-84),%a0
    movew #284,%a0@
    moveb %d0,%a0@(2)
    clrw %a0@(14)
    clrl %a0@(16)
    _EgretDispatch
    btst #7,0xdd1
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_A0
    lea %fp@(-56),%a0
    moveb #0xfd,%a0@(50)
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_DA
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_A0:  /* set %a2 */
    moveal %a4,%a2
    addal %a2@,%a2
    moveal %a2@(92),%a2
    moveq #0,%d0
    bset #15,%d0
    movel %d0,%a2@(252)
    moveq #0,%d0
    bset #15,%d0
    movel %d0,%a2@(4)
    moveq #4,%d0
    movel %d0,%a2@
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_C0:  /* loop: move */
    movel %a2@,%d0
    btst #3,%d0
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_C0
    movel #128,%d0
    movel %d0,%a2@
    subl %d0,%d0
    movel %d0,%a2@(16)
    movel %d0,%a2@(148)
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_DA:  /* set %a3 */
    moveal %a4,%a3
    addal %a3@,%a3
    moveal %a3@(8),%a3
    moveal %a3,%a2
    addal #155648,%a2
    movel %a2,%fp@(-100)
    moveb #64,%a2@(18)
    moveal %a4,%a1
    addal %a4@(8),%a1
    moveal %a1@(4),%a1
    moveq #1,%d0
    _SwapMMUMode
    moveb #6,%a2@(4)
    moveq #0,%d4
    movel #842348107,%a1@
    subql #4,%sp@
    addql #4,%sp@
    cmpil #842348107,%a1@(512)
    addal #524288,%a1
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_128
    addqw #1,%d4
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_15E
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_128:  /* set %a1@ */
    movel #892416575,%a1@
    subql #4,%sp@
    addql #4,%sp@
    cmpil #892416575,%a1@
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_140
    clrb %a2@(4)
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_18C
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_140:  /* add 1 to %d4 */
    addqw #1,%d4
    cmpil #892416575,%a1@(512)
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_156
    moveb #2,%a2@(4)
    addqw #1,%d4
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_18C
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_156:  /* set %a2@(4) */
    moveb #1,%a2@(4)
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_18C
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_15E:  /* set %a1@ */
    movel #926300223,%a1@
    subql #4,%sp@
    addql #4,%sp@
    cmpil #926300223,%a1@
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_178
    moveb #4,%a2@(4)
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_18C
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_178:  /* add 1 to %d4 */
    addqw #1,%d4
    cmpil #926300223,%a1@(512)
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_186
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_18C
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_186:  /* set %a2@(4) */
    moveb #5,%a2@(4)
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_18C:  /* _SwapMMUMode */
    _SwapMMUMode
    moveal %a3,%a2
    addal #163840,%a2
    movel %a2,%fp@(-96)
    bclr #7,%a2@
    movel #1860501504,%d0
    jbsr DECL_SR7F_01_MacII_PrimaryInit_code_1816_E6
    moveq #0,%d6
    moveb #7,%a2@(2)
    movew #550,%d2
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1B4:/* delay: a byte read of the VIA */
    tstb @(VIA,%za0)@(0)
    dbf %d2,DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1B4
    moveq #0,%d2
    moveb %a2@(2),%d2
    lsrb #4,%d2
    moveb %d2,%d6
    moveb #7,%a2@(2)
    movew #550,%d2
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1D2:/* delay: a byte read of the VIA */
    tstb @(VIA,%za0)@(0)
    dbf %d2,DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1D2
    cmpib #6,%d6
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1EC
    cmpib #7,%d6
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1F4
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_296
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1EC:  /* set %d6 */
    moveb #3,%d6
    braw DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_272
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1F4:  /* call DECL_SR7F_01_MacII_PrimaryInit_code_1816 */
    jbsr DECL_SR7F_01_MacII_PrimaryInit_code_1816
    lea %pc@(DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_20C),%a1
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1FC:  /* loop: move */
    moveb %a1@+,%d0
    jbmi DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_212
    moveb %a1@+,%d1
    cmpb %d0,%d6
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_1FC
    moveb %d1,%d6
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_296
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_20C:  /* (data) */
    .short  0x1708, 0x2D0A, 0xFFFF	| 408FA1B0
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_212:  /* set %d6 */
    moveb #7,%d6
    subqw #4,%sp
    moveal %sp,%a0
    movew #4,%d0
    swap %d0
    movew #252,%d0
    _ReadXPRam
    movel %sp@+,%d0
    lea %pc@(DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_23A),%a1
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_22C:  /* loop: move */
    movel %a1@+,%d1
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_296
    movel %a1@+,%d2
    cmpl %d0,%d1
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_22C
    moveb %d2,%d6
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_296
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_23A:  /* (data) */
    .short  0x524E	| 408FA1DE
    .long   0x494E0000, 0x00065352, 0x4E4E0000, 0x0002524E	| 408FA1E0
    .long   0x31320000, 0x0002524E, 0x31330000, 0x0006524E	| 408FA1F0
    .long   0x31350000, 0x0005524E, 0x31360000, 0x000A0000	| 408FA200
    .short  0x0000, 0x0000, 0x0000	| 408FA210
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_272:  /* address %fp@(-64) */
    lea %fp@(-64),%a2
    moveb %a2@(7),%d0
    andib #64,%d0
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_28E
    cmpib #3,%d6
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_288
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_296
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_288:  /* set %d6 */
    moveb #6,%d6
    jbra DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_296
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_28E:  /* set %d6 */
    moveb %a2@(7),%d6
    andib #63,%d6
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_296:  /* set %a2 */
    moveal %fp@(-96),%a2
    bset #7,%a2@
    moveq #0,%d0
    jbsr DECL_SR7F_01_MacII_PrimaryInit_code_1816_E6
    lea %pc@(DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_470),%a1
    movew #20,%d0
    muluw %d6,%d0
    addal %d0,%a1
    movel %a1,%fp@(-92)
    addql #8,%a1
    movew #4,%d0
    muluw %d4,%d0
    addal %d0,%a1
    moveb %a1@(1),%d7
    moveb %a1@,%d5
    lea %fp@(-56),%a0
    lea %fp@(-64),%a2
    moveb %a2@(6),%d0
    bfins %d4,%d0,30,2
    moveb %d0,%a2@(6)
    moveb %d6,%a2@(5)
    cmpb %a2@(4),%d5
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_2EE
    moveb %d5,%a2@(3)
    moveb %d5,%a2@(4)
    moveb %d7,%a2@(2)
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_2EE:  /* set up and call _SlotManager */
    movel %a2,%a0@(4)
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */
    _SlotManager
    moveb %a2@(3),%d5
    lea %pc@(DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_444),%a1
    moveb %d5,%d0
    jbsr DECL_SR7F_01_MacII_PrimaryInit_code_17D2
    cmpib #0xfe,%d5
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_43C
    moveal %fp@(-92),%a1
    addqw #8,%a1
    movew #4,%d0
    muluw %d4,%d0
    addal %d0,%a1
    movew %a1@(2),%d0
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_32C
    moveal %fp@(-92),%a1
    addaw %d0,%a1
    moveb %d5,%d0
    jbsr DECL_SR7F_01_MacII_PrimaryInit_code_17EC
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_32C:  /* clear %a0@(50) */
    clrw %a0@(50)
    clrb %a0@(48)
    movew #1,%a0@(40)
    clrw %a0@(42)
    clrw %a0@(44)
    clrw %a0@(46)
    clrl %a0@(24)
    bset #1,%a0@(27)
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */
    _SlotManager
    moveb #126,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    moveb %d5,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    moveal %a0@,%a1
    movel %a1,%fp@(-88)
    moveal %a1,%a0
    moveal %fp@(-100),%a2
    moveb %a2@(4),%d0
    cmpib #4,%d0
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_382
    cmpib #5,%d0
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_384
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_382:  /* add 4 to %a0 */
    addqw #4,%a0
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_384:  /* clear %d0 */
    moveq #0,%d0
    moveb %a0@,%d0
    lslw #7,%d0
    moveb %a0@(1),%d1
    orb %d1,%d0
    moveb %a0@(2),%d1
    lslw #2,%d0
    orb %d1,%d0
    swap %d0
    jbsr DECL_SR7F_01_MacII_PrimaryInit_code_1816_E6
    moveal %fp@(-96),%a2
    clrb %a2@(1)
    moveb %a1@(8),%d0
    bset #7,%d0
    moveb %d0,%a2@
    moveal %a4,%a2
    addal %a2@,%a2
    moveal %a2@(56),%a2
    moveb #8,%a2@(2)
    addqw #1,%a2
    moveal %fp@(-92),%a5
    moveb #127,%a2@(-1)
    moveb %a5@(1),%a2@
    moveb %a5@(3),%a2@
    moveb %a5@(5),%a2@
    moveb #0xff,%a2@(-1)
    moveb %a5@,%a2@
    moveb %a5@(2),%a2@
    moveb %a5@(4),%a2@
    moveal %a4,%a2
    addal %a2@(8),%a2
    moveal %a2@(4),%a2
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    movew %a1@(14),%d3
    movel #-1431655766,%d2
    moveq #1,%d0
    cmpib #0x85,%d5
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_40E
    cmpib #0x86,%d5
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_410
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_40E:  /* clear %d0 */
    moveq #0,%d0
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_410:  /* loop: move */
    movew %a1@(16),%d1
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_414:  /* loop: move */
    movel %d2,%a2@+
    dbf %d1,DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_414
    tstb %d0
    jbne DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_420
    movew %d2,%a2@+
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_420:  /* set up and call _SwapMMUMode */
    notl %d2
    dbf %d3,DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_410
    moveb %sp@+,%d0
    _SwapMMUMode
    moveal %fp@(-96),%a2
    moveb %a2@,%d0
    bclr #7,%d0
    moveb %d0,%a2@
    moveal %fp@(-88),%a0
    _DisposPtr
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_43C:  /* return */
    unlk %fp
    rts
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_440:  /* (data) */
    .long   0x00011516	| 408FA3E4
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_444:  /* (data) */
    .long   0x00138081, 0x82838485	| 408FA3E8
    .long   0x86878889, 0x8A8B8C8D, 0x8E8F9091, 0x92930000	| 408FA3F0
    .long   0x00018385, 0x00018486, 0x00018A8D, 0x00018B8E	| 408FA400
    .long   0x00018C8E	| 408FA410
DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_470:  /* (data) */
    .long   0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE	| 408FA414
    .long   0xFEFEFEFE, 0xFEFEFEFE, 0x00000000, 0x00FF0000	| 408FA420
    .long   0x80800000, 0x81800000, 0x82800000, 0x05FF05FF	| 408FA430
    .long   0x05FF0000, 0x8383FFC4, 0x8483FFC8, 0x8483FFC8	| 408FA440
    .long   0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE	| 408FA450
    .long   0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE	| 408FA460
    .long   0xFEFEFEFE, 0xFEFEFEFE, 0x00FF00FF, 0x00FF0000	| 408FA470
    .long   0x87810000, 0x88820000, 0x89830000, 0x00FF00FF	| 408FA480
    .long   0x00FF0000, 0x8A82FF7C, 0x8B83FF80, 0x8C83FF84	| 408FA490
    .long   0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE	| 408FA4A0
    .long   0xFEFEFEFE, 0x00FF00FF, 0x00FF0000, 0x8F820000	| 408FA4B0
    .long   0x90830000, 0x91830000, 0xFEFEFEFE, 0xFEFEFEFE	| 408FA4C0
    .long   0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE, 0x00FF00FF	| 408FA4D0
    .long   0x00FF0000, 0x92810000, 0x93830000, 0x93830000	| 408FA4E0
    .long   0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE, 0xFEFEFEFE	| 408FA4F0
    .long   0xFEFEFEFE	| 408FA500
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit:  /* the SecondaryInit (38) (pointed to by its entry) */
    .long   0x000001A4, 0x02020000	| 408FA504
    .long   DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code-.	| 408FA50C
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_C:  /* set %a0@(10) */
    movew #30,%a0@(10)	| 408FA510
    moveal ASCBase,%a1	| 408FA516
    movew %sr,%sp@-	| 408FA51A
    oriw #1792,%sr	| 408FA51C
    tstb %a1@(3849)	| 408FA520
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_28	| 408FA524
    tstb %a1@(3881)	| 408FA526
    jbne DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_42	| 408FA52A
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_28:  /* set %a1@(3849) */
    moveb #1,%a1@(3849)	| 408FA52C
    moveb #1,%a1@(3881)	| 408FA532
    clrb %a1@(3849)	| 408FA538
    clrb %a1@(3881)	| 408FA53C
    movew #1,%a0@(10)	| 408FA540
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_42:  /* set %sr */
    movew %sp@+,%sr	| 408FA546
    rts	| 408FA548

DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_5A6:  /* from here: linkw %fp,#0 */
    linkw %fp,#0
    moveal %fp@(8),%a0
    moveq #64,%d0
    movel %d0,%a0@
    clrw %fp@(16)
    unlk %fp
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* subroutine (349 instructions): traps SlotManager, ShutDown, Gestalt, NewPtr, BlockMove, SoundDispatch, VRemove, PowerDispatch; calls DECL_DRVR_Display_Video_Apple_RBV1_45A, DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC, DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34, DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E, DE; low memory KeyMap, VBLQueue, ExpandMem, HWCfgFlags (mechanical summary) */

/*
 SecondaryInit of the built-in video, run once the system is loaded: installs what the
 video needs with the system running (time tasks, shutdown and power handling, sound
 settings). Inferred from the code (traps used: ShutDown, Gestalt, SoundDispatch,
 PowerDispatch, InsTime/RmvTime).
*/
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code:
    linkw %fp,#-64
    movew #1,%a0@(2)
    clrb %fp@(-7)
    clrb %fp@(-5)
    lea %fp@(-56),%a0
    lea %fp@(-64),%a2
    movel %a2,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    moveb %a2@(7),%d0
    moveb %d0,%d4
    andib #64,%d0
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_64
    moveml KeyMap,%d0-%d3
    bclr #7,%d3
    bclr #1,%d1
    bclr #0,%d1
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_82
    orl %d1,%d0
    orl %d2,%d0
    orl %d3,%d0
    jbne DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_82
    moveb %d4,%d0
    andib #63,%d0
    orib #0x80,%d0
    moveb %d0,%a2@(7)
    movel %a2,%a0@(4)
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */
    _SlotManager
    movew #2,%sp@-
    _ShutDown
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_64:  /* set %d0 */
    moveb %d4,%d0
    andib #0x80,%d0
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_82
    moveb %d4,%d0
    andib #63,%d0
    orib #64,%d0
    moveb %d0,%a2@(7)
    movel %a2,%a0@(4)
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */
    _SlotManager
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_82:  /* set %d0 */
    movel #786432,%d0
    andl 0xdd4,%d0
    subil #262144,%d0
    jbne DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_C4
    movel #1651861370,%d0
    .short  0xA1AD	| 408FA5FC _Gestalt (flags 0x0100)
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_C4
    lea %pc@(DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_5A6),%a1
    lea %pc@(DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code),%a0
    subal %a1,%a0
    movel %a0,%d0
    movel %d0,%d1
    .short  0xA51E	| 408FA60E _NewPtr (flags 0x0500)
    jbne DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_C4
    lea %pc@(DECL_SR7E_15_MacAA_Built_In_Video_PrimaryInit_code_5A6),%a1
    exg %a0,%a1
    movel %d1,%d0
    _BlockMove
    movel #1651861370,%d0
    exg %a1,%a0
    .short  0xA3AD	| 408FA624 _Gestalt (flags 0x0300)
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_C4:  /* test bit 7 of 0xdd5 */
    btst #7,0xdd5
    jbne DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_D4
    cmpib #20,0xcb3
    jbne DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_136
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_D4:  /* set up and call _SoundDispatch */
    clrl %sp@-
    movel #786440,%d0
    _SoundDispatch
    movel %sp@+,%d0
    cmpil #33652736,%d0
    jbne DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_136
    movew %sr,%sp@-
    oriw #256,%sr
    lea VBLQueue,%a1
    lea %a1@(2),%a0
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_F6:  /* loop: move */
    movel %a0@,%d0
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_112
    moveal %d0,%a0
    moveal %a0@(6),%a1
    lea %pc@(DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_C),%a2
    movew #28,%d0
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_108:  /* set up and call _VRemove (loop) */
    cmpmw %a1@+,%a2@+
    dbne %d0,DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_108
    jbne DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_F6
    _VRemove
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_112:  /* set %sr */
    movew %sp@+,%sr
    cmpib #20,0xcb3
    jbne DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_136
    moveal 0xdd8,%a0
    addal %a0@(48),%a0
    addal %a0@(24),%a0
    movel %a0,%d0
    moveal ExpandMem,%a0
    moveal %a0@(426),%a0
    movel %d0,%a0@(24)
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_136:  /* set up and call _PowerDispatch */
    btst #0,HWCfgFlags
    jbeq DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_142
    moveq #10,%d0
    _PowerDispatch
DECL_SR7E_15_MacAA_Built_In_Video_SecondaryInit_code_142:  /* return */
    unlk %fp
    rts

/* Driver (sBlock: length, then the driver: header with the routine offsets, name, code) for Display Video Apple RBV1. */
DECL_DRVR_Display_Video_Apple_RBV1:
    .long   0x0000079C, 0x4C000000	| 408FA6A8
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x01, 0x0E, 0x04, 0xE0, 0x04, 0xBA, 0x19	| 408FA6B0
    .ascii  ".Display_Video_Apple_RBV1\000"
    .byte   0x01	| 408FA6D9
DECL_DRVR_Display_Video_Apple_RBV1_32:  /* (data) */
    .byte   0x01, 0x03, 0x0F, 0xFF	| 408FA6DA
DECL_DRVR_Display_Video_Apple_RBV1_36:  /* (data) */
    .byte   0xFE, 0xFC, 0xF0, 0x00	| 408FA6DE
    moveq #40,%d0	| 408FA6E2
    .short  0xA440	| 408FA6E4 408FA6E4 A-line trap
    moveq #40,%d0	| 408FA6E6
    .short  0xA722	| 408FA6E8 408FA6E8 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_RBV1_10A	| 408FA6EA
    movel %a0,%a1@(20)	| 408FA6EE
    _HLock	| 408FA6F2 408FA6F2 A-line trap
    moveal %a0@,%a3	| 408FA6F4
    moveal 0xdd8,%a0	| 408FA6F6
    addal %a0@,%a0	| 408FA6FA
    movel %a0@(56),%a3@(12)	| 408FA6FC
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_Status_2AC),%a0	| 408FA702
    movel %a0,%a3@(22)	| 408FA706
    lea %a3@(16),%a0	| 408FA70A
    _InsTime	| 408FA70E 408FA70E A-line trap
    moveq #16,%d0	| 408FA710
    .short  0xA71E	| 408FA712 408FA712 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_RBV1_FE	| 408FA714
    movel %a0,%a3@(4)	| 408FA718
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_45A	| 408FA71C
    jbne DECL_DRVR_Display_Video_Apple_RBV1_FE	| 408FA720
    moveal ghost_VIA2,%a0	| 408FA724
    moveb %a0@(16),%d0	| 408FA728
    lsrb #3,%d0	| 408FA72C
    andiw #7,%d0	| 408FA72E
    movew %d0,%a3@(34)	| 408FA732
    cmpiw #1,%d0	| 408FA736
    jbne DECL_DRVR_Display_Video_Apple_RBV1_9A	| 408FA73A
    orib #0xa0,%a3@(30)	| 408FA73C
DECL_DRVR_Display_Video_Apple_RBV1_9A:
    cmpib #10,0xcb3	| 408FA742
    jbne DECL_DRVR_Display_Video_Apple_RBV1_A8	| 408FA748
    bset #11,%a3@(30)	| 408FA74A
DECL_DRVR_Display_Video_Apple_RBV1_A8:  /* from here: subaw #56,%sp */
    subaw #56,%sp	| 408FA750
    moveal %sp,%a0	| 408FA754
    moveb %a1@(40),%a0@(49)	| 408FA756
    moveb %a1@(41),%a0@(50)	| 408FA75C
    clrb %a0@(51)	| 408FA762
    clrb %a0@(52)	| 408FA766
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */	| 408FA76A
    _SlotManager	| 408FA76C 408FA76C A-line trap
    moveb #64,%a0@(50)	| 408FA76E
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 408FA774
    _SlotManager	| 408FA776 408FA776 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_RBV1_FE	| 408FA778
    moveb #0x80,%a0@(50)	| 408FA77A
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */	| 408FA780
    _SlotManager	| 408FA782 408FA782 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_RBV1_FE	| 408FA784
    moveal %a0@,%a0	| 408FA786
    movel %a0,%a3@(36)	| 408FA788
    addqw #2,%a0	| 408FA78C
DECL_DRVR_Display_Video_Apple_RBV1_E6:  /* loop: tst */
    tstb %a0@+	| 408FA78E
    jbne DECL_DRVR_Display_Video_Apple_RBV1_E6	| 408FA790
    movel %a0,%d0	| 408FA792
    addqw #1,%d0	| 408FA794
    bclr #0,%d0	| 408FA796
    movel %d0,%a3@(8)	| 408FA79A
    lea %sp@(56),%sp	| 408FA79E
    moveq #0,%d0	| 408FA7A2
DECL_DRVR_Display_Video_Apple_RBV1_FC:  /* return */
    rts	| 408FA7A4
DECL_DRVR_Display_Video_Apple_RBV1_FE:  /* address %a3@(16) */
    lea %a3@(16),%a0	| 408FA7A6
    _RmvTime	| 408FA7AA 408FA7AA A-line trap
    moveal %a1@(20),%a0	| 408FA7AC
    _DisposHandle	| 408FA7B0 408FA7B0 A-line trap
DECL_DRVR_Display_Video_Apple_RBV1_10A:
    moveq #-23,%d0	| 408FA7B2
    lea %sp@(56),%sp	| 408FA7B4
    jbra DECL_DRVR_Display_Video_Apple_RBV1_FC	| 408FA7B8
    movel %a0,%sp@-	| 408FA7BA
    movew %a0@(26),%d0	| 408FA7BC
    moveal %a0@(28),%a2	| 408FA7C0
    moveal %a1@(20),%a3	| 408FA7C4
    moveal %a3@,%a3	| 408FA7C8
    cmpiw #9,%d0	| 408FA7CA
    jbhi DECL_DRVR_Display_Video_Apple_RBV1_144	| 408FA7CE
    movew %pc@(DECL_DRVR_Display_Video_Apple_RBV1_130,%d0:w:2),%d0	| 408FA7D0
    jmp %pc@(DECL_DRVR_Display_Video_Apple_RBV1_130,%d0:w)	| 408FA7D4
DECL_DRVR_Display_Video_Apple_RBV1_130:  /* from here: orib #24,%a0@- */
    orib #24,%a0@-	| 408FA7D8
    oriw #178,%d2	| 408FA7DC
    .short  0x01F6, 0x02C0	/* 408FA7E0 bset %d0,%fp@(ffffffffffffffc0,%d0:w:2) */
    .byte   0x02, 0xDE, 0x02, 0xFC, 0x00, 0x14, 0x03, 0x62	| 408FA7E4

DECL_DRVR_Display_Video_Apple_RBV1_144:  /* result -17 */
    moveq #-17,%d0
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148_2

DECL_DRVR_Display_Video_Apple_RBV1_148:  /* loop: moveq */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_RBV1_148_2:  /* set %a0 */
    moveal %sp@+,%a0
    jbra DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_24
    .long   0x34BC0080, 0x377C0080	| 408FA7F8
    .long   0x0020323C, 0x00017000, 0x35400006, 0x6100054A	| 408FA800
    .long   0x25530008	| 408FA810
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148
    .short  0x3212	| 408FA81A
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34
    jbne DECL_DRVR_Display_Video_Apple_RBV1_144
    cmpiw #0,%a2@(6)
    jbne DECL_DRVR_Display_Video_Apple_RBV1_144
    movew %a2@,%d2
    cmpw %a3@(32),%d2
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_148_92
    movew %d2,%a3@(32)
    moveal %a3@(8),%a0
    movew %a0@(4),%d3
    movew %a0@(8),%d2
    lsrw #1,%d2
    lea %a0@(12),%a0
    addaw %d3,%a0
    moveb %a0@(0x0,%d2:w),%d3
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge DECL_DRVR_Display_Video_Apple_RBV1_148_70
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_RBV1_148_70:  /* call DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E */
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E
    moveal %a3@(12),%a0
    addqw #4,%a0
    clrb %a0@(-4)
    movew #255,%d2
DECL_DRVR_Display_Video_Apple_RBV1_148_82:  /* loop: move */
    moveb %d3,%a0@
    moveb %d3,%a0@
    moveb %d3,%a0@
    dbf %d2,DECL_DRVR_Display_Video_Apple_RBV1_148_82
    movew %sp@+,%sr
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_A2
DECL_DRVR_Display_Video_Apple_RBV1_148_92:  /* set %a2@(8) */
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148
    movel %a2@,%d0
    beqw DECL_DRVR_Display_Video_Apple_RBV1_144
    moveml %d4-%d7/%a1/%a4-%fp,%sp@-
    movew %a3@(30),%d5
    cmpiw #-1,%a2@(4)
    beqs DECL_DRVR_Display_Video_Apple_RBV1_148_92_22
    bset #12,%d5
DECL_DRVR_Display_Video_Apple_RBV1_148_92_22:
    moveal %a3@(8),%a0
    movew %a0@(4),%d0
    lea %a0@(12),%a4
    addaw %d0,%a4
    moveal %a4,%a5
    moveal %a4,%fp
    movew %a0@(10),%d7
    cmpiw #1,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_148_E4
    movew %a0@(8),%d0
    movew %d7,%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %d1,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
DECL_DRVR_Display_Video_Apple_RBV1_148_E4:  /* set %d1 */
    movew %a3@(32),%d1
    subiw #128,%d1
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_32),%a1
    moveb %a1@(0x0,%d1:w),%d6
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_36),%a1
    moveb %a1@(0x0,%d1:w),%d5
    movew %a2@(6),%d3
    cmpb %d6,%d3
    jbhi DECL_DRVR_Display_Video_Apple_RBV1_148_1D6
    movel %d3,%d4
    addqw #1,%d4
    btst #12,%d5
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_148_116
    muluw #3,%d4
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148_118
DECL_DRVR_Display_Video_Apple_RBV1_148_116:  /* from here: aslw #2,%d4 */
    aslw #2,%d4
DECL_DRVR_Display_Video_Apple_RBV1_148_118:  /* from here: subaw %d4,%sp */
    subaw %d4,%sp
    moveal %sp,%a0
    moveal %a2@,%a1
DECL_DRVR_Display_Video_Apple_RBV1_148_11E:  /* loop: move */
    movew %a1@+,%d0
    btst #12,%d5
    jbne DECL_DRVR_Display_Video_Apple_RBV1_148_12A
    addb %d5,%d0
    moveb %d0,%a0@+
DECL_DRVR_Display_Video_Apple_RBV1_148_12A:  /* set %d0 */
    movew %a1@+,%d0
    movew %a1@+,%d1
    movew %a1@+,%d2
    tstw %d5
    jbpl DECL_DRVR_Display_Video_Apple_RBV1_148_14E
    muluw #19660,%d0
    muluw #-26870,%d1
    muluw #7209,%d2
    addl %d1,%d0
    addl %d2,%d0
    bfextu %d0,0,%d7,%d1
    movew %d1,%d0
    movew %d1,%d2
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148_15A
DECL_DRVR_Display_Video_Apple_RBV1_148_14E:  /* from here: bfextu %d0,16,%d7,%d0 */
    bfextu %d0,16,%d7,%d0
    bfextu %d1,16,%d7,%d1
    bfextu %d2,16,%d7,%d2
DECL_DRVR_Display_Video_Apple_RBV1_148_15A:  /* test bit 13 of %d5 */
    btst #13,%d5
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_148_164
    clrw %a0@+
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148_16C
DECL_DRVR_Display_Video_Apple_RBV1_148_164:  /* set %a0@+ */
    moveb %a4@(0x0,%d0:w),%a0@+
    moveb %a5@(0x0,%d1:w),%a0@+
DECL_DRVR_Display_Video_Apple_RBV1_148_16C:  /* set %a0@+ */
    moveb %fp@(0x0,%d2:w),%a0@+
    dbf %d3,DECL_DRVR_Display_Video_Apple_RBV1_148_11E
    movew %a2@(6),%d3
    moveal %a3@(12),%a3
    moveb #0xff,%a3@(8)
    lea %a3@(4),%a3
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge DECL_DRVR_Display_Video_Apple_RBV1_148_198
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_RBV1_148_198:  /* call DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E */
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E
    lea %sp@(2),%a0
    btst #12,%d5
    jbne DECL_DRVR_Display_Video_Apple_RBV1_148_1B6
DECL_DRVR_Display_Video_Apple_RBV1_148_1A6:  /* loop: move */
    moveb %a0@+,%a3@(-4)
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    dbf %d3,DECL_DRVR_Display_Video_Apple_RBV1_148_1A6
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148_1CA
DECL_DRVR_Display_Video_Apple_RBV1_148_1B6:  /* set %d0 */
    movew %a2@(4),%d0
    addb %d5,%d0
    moveb %d0,%a3@(-4)
DECL_DRVR_Display_Video_Apple_RBV1_148_1C0:  /* loop: move */
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    dbf %d3,DECL_DRVR_Display_Video_Apple_RBV1_148_1C0
DECL_DRVR_Display_Video_Apple_RBV1_148_1CA:  /* set %sr */
    movew %sp@+,%sr
    addaw %d4,%sp
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148
DECL_DRVR_Display_Video_Apple_RBV1_148_1D6:  /* restore registers */
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    jbra DECL_DRVR_Display_Video_Apple_RBV1_144
    .short  0x2012	| 408FA9CE
    .long   0x6700009E, 0x24404A52, 0x6600FE12, 0x4A6A0002	| 408FA9D0
    .long   0x67200C6A, 0x00180002, 0x6600FE02, 0x4A6A0004	| 408FA9E0
    .long   0x6710302A, 0x000CB06B, 0x00226706, 0x52406600	| 408FA9F0
    .long   0xFDEC206B, 0x0008302A, 0x0004B068, 0x00046612	| 408FAA00
    .long   0x302A0006, 0xB0680006, 0x67326E06, 0xA01F42AB	| 408FAA10
    .long   0x0008302A, 0x0008C0EA, 0x0006D06A, 0x00040640	| 408FAA20
    .long   0x000CA51E, 0x6600FDB6, 0x202B0008, 0x27480008	| 408FAA30
    .long   0x4A806708, 0x2040A01F	| 408FAA40
    moveal %a3@(8),%a0
    movew %a2@(6),%d0
    movew %a2@(4),%d1
    movew %a2@(8),%d2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    muluw %d0,%d2
    addw %d1,%d2
    subqw #1,%d2
DECL_DRVR_Display_Video_Apple_RBV1_148_274:  /* loop: move */
    moveb %a2@+,%d0
    moveb %d0,%a0@+
    dbf %d2,DECL_DRVR_Display_Video_Apple_RBV1_148_274
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148
    moveal %a3@(8),%a0
    movew %a0@(4),%d0
    movew %a0@(6),%d2
    subqw #1,%d2
    lea %a0@(12),%a0
    addaw %d0,%a0
DECL_DRVR_Display_Video_Apple_RBV1_148_294:  /* loop: move */
    movew #255,%d0
DECL_DRVR_Display_Video_Apple_RBV1_148_298:  /* loop: move */
    moveb %d0,%a0@
    notb %a0@+
    dbf %d0,DECL_DRVR_Display_Video_Apple_RBV1_148_298
    dbf %d2,DECL_DRVR_Display_Video_Apple_RBV1_148_294
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148
    movew %a3@(32),%d1
    movew %d1,%a2@
    bsrw DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34
    bnew DECL_DRVR_Display_Video_Apple_RBV1_144
    movew %a2@(6),%d0
    bnew DECL_DRVR_Display_Video_Apple_RBV1_144
    bsrw DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC
    braw DECL_DRVR_Display_Video_Apple_RBV1_148
    btst #13,%a3@(30)
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_148_2D2
    moveb #1,%a2@
DECL_DRVR_Display_Video_Apple_RBV1_148_2D2:  /* clear %d1 */
    moveq #0,%d1
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_422
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148

/* subroutine (11 instructions): calls DECL_DRVR_Display_Video_Apple_RBV1_422, DECL_DRVR_Display_Video_Apple_RBV1_45A, DECL_DRVR_Display_Video_Apple_RBV1_442 (mechanical summary) */
DECL_DRVR_Display_Video_Apple_RBV1_422:
    moveb %a2@,%d0
    bfins %d0,%a3@(30),%d1,1
    rts
    moveq #1,%d1
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_422
    jbne DECL_DRVR_Display_Video_Apple_RBV1_422_1A
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_45A
    jbne DECL_DRVR_Display_Video_Apple_RBV1_144
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148
DECL_DRVR_Display_Video_Apple_RBV1_422_1A:  /* call DECL_DRVR_Display_Video_Apple_RBV1_442 */
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_442
    jbra DECL_DRVR_Display_Video_Apple_RBV1_148

/* subroutine (7 instructions): traps SIntRemove; calls DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E (mechanical summary) */
DECL_DRVR_Display_Video_Apple_RBV1_442:
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E
    moveal ghost_VIA2,%a0
    moveb #64,%a0@(18)
    clrw %d0
    moveal %a3@(4),%a0
    _SIntRemove
    rts

/* subroutine (41 instructions): traps SIntInstall, RmvTime, DisposPtr, DisposHandle; calls DECL_DRVR_Display_Video_Apple_RBV1_442 (mechanical summary) */
DECL_DRVR_Display_Video_Apple_RBV1_45A:
    moveal %a3@(4),%a0
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_Status_27E),%a2
    movew #6,%a0@(4)
    movel %a2,%a0@(8)
    moveal %a1@(20),%a2
    moveal %a2@,%a2
    movel %a2,%a0@(12)
    clrw %d0
    _SIntInstall
    jbne DECL_DRVR_Display_Video_Apple_RBV1_45A_34
    movel %a0,%sp@-
    moveal ghost_VIA2,%a0
    moveb #0xc0,%a0@(18)
    moveal %sp@+,%a0
    movew %d0,%d0
    rts
DECL_DRVR_Display_Video_Apple_RBV1_45A_34:  /* result 1 */
    moveq #1,%d0
    rts
    .byte   0x9E, 0xFC, 0x00, 0x38, 0x20, 0x4F, 0x11, 0x69, 0x00, 0x28, 0x00, 0x31, 0x42, 0x28, 0x00, 0x33	| 408FAB3A
    .byte   0x51, 0x4F, 0x20, 0x8F, 0x70, 0x11, 0xA0, 0x6E, 0x1F, 0x52, 0x00, 0x03, 0x21, 0x4F, 0x00, 0x04	| 408FAB4A
    .byte   0x70, 0x12, 0xA0, 0x6E, 0x4F, 0xEF, 0x00, 0x40, 0x60, 0x00, 0xFC, 0x8C	| 408FAB5A
    moveal %a1@(20),%a3	| 408FAB66
    moveal %a3@,%a3	| 408FAB6A
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_442	| 408FAB6C
    lea %a3@(16),%a0	| 408FAB70
    _RmvTime	| 408FAB74 408FAB74 A-line trap
    moveal %a3@(4),%a0	| 408FAB76
    _DisposPtr	| 408FAB7A 408FAB7A A-line trap
    moveal %a3@(36),%a0	| 408FAB7C
    _DisposPtr	| 408FAB80 408FAB80 A-line trap
    moveal %a1@(20),%a0	| 408FAB82
    _DisposHandle	| 408FAB86 408FAB86 A-line trap
    moveq #0,%d0	| 408FAB88
    rts	| 408FAB8A

/* Status: find csCode in the status table and call its routine (out of range: StatusBadCode) (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_Status:
    movel %a0,%sp@-	| 408FAB8C
    movew %a0@(26),%d0	| 408FAB8E
    moveal %a0@(28),%a2
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    cmpiw #9,%d0
    jbhi DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode
    lslw #1,%d0
    movew %pc@(DECL_DRVR_Display_Video_Apple_RBV1_StatusTable,%d0:w),%d0
    jmp %pc@(DECL_DRVR_Display_Video_Apple_RBV1_StatusTable,%d0:w)

/* status table: routine offsets by csCode (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_StatusTable:
    .short  DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABAC
    .short  DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABAE
    .short  DECL_DRVR_Display_Video_Apple_RBV1_GetMode-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABB0
    .short  DECL_DRVR_Display_Video_Apple_RBV1_GetEntries-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABB2
    .short  DECL_DRVR_Display_Video_Apple_RBV1_GetPages-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABB4
    .short  DECL_DRVR_Display_Video_Apple_RBV1_GetBaseAddr-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABB6
    .short  DECL_DRVR_Display_Video_Apple_RBV1_GetGray-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABB8
    .short  DECL_DRVR_Display_Video_Apple_RBV1_GetInterrupt-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABBA
    .short  DECL_DRVR_Display_Video_Apple_RBV1_GetGamma-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABBC
    .short  DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode-DECL_DRVR_Display_Video_Apple_RBV1_StatusTable	| 408FABBE

/* unknown status csCode: statusErr (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode:
    moveq #-18,%d0
    jbra DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_6
DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_4:  /* loop: moveq */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_6:  /* set %a0 */
    moveal %sp@+,%a0
    jbra DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_24

/* Status csCode 2, cscGetMode: current mode, page and base address (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_GetMode:
    movew %a3@(32),%a2@
    clrw %a2@(6)
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_4

/* Status csCode 3, cscGetEntries: read colour table entries (from the CLUT) (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_GetEntries:
    movel %a2@,%d0
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode
    moveml %d1/%d4/%a1/%a3-%a4,%sp@-
    moveal %d0,%a4
    movew %a3@(32),%d1
    subiw #128,%d1
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_32),%a0
    moveb %a0@(0x0,%d1:w),%d3
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_36),%a0
    moveb %a0@(0x0,%d1:w),%d4
    movew %a2@(6),%d0
    movew %d0,%d2
    cmpiw #-1,%a2@(4)
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_GetEntries_40
    movew %d0,%d1
    addw %a2@(4),%d2
DECL_DRVR_Display_Video_Apple_RBV1_GetEntries_36:  /* loop: move */
    movew %d2,%a4@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,DECL_DRVR_Display_Video_Apple_RBV1_GetEntries_36
DECL_DRVR_Display_Video_Apple_RBV1_GetEntries_40:  /* set %a1 */
    moveal %a3@(12),%a1
    addqw #4,%a1
    movew %sr,%sp@-
    moveq #7,%d1
    andb %sp@,%d1
    subqb #2,%d1
    jbge DECL_DRVR_Display_Video_Apple_RBV1_GetEntries_58
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_RBV1_GetEntries_58:  /* loop: move */
    movew %a4@,%d1
    cmpb %d3,%d1
    jbhi DECL_DRVR_Display_Video_Apple_RBV1_GetEntries_82
    addb %d4,%d1
    moveb %d1,%a1@(8)
    moveb %a1@,%d1
    moveb %d1,%a4@(2)
    moveb %d1,%a4@(3)
    moveb %a1@,%d1
    moveb %d1,%a4@(4)
    moveb %d1,%a4@(5)
    moveb %a1@,%d1
    moveb %d1,%a4@(6)
    moveb %d1,%a4@(7)
DECL_DRVR_Display_Video_Apple_RBV1_GetEntries_82:  /* add 8 to %a4 */
    addql #8,%a4
    dbf %d0,DECL_DRVR_Display_Video_Apple_RBV1_GetEntries_58
    movew %sp@+,%sr
    moveml %sp@+,%d1/%d4/%a1/%a3-%a4
    jbra DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_4

/* Status csCode 4, cscGetPages: number of video pages for a mode (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_GetPages:
    movew %a2@,%d1
    movew %d1,%d2
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34
    jbgt DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode
    movew #1,%a2@(6)
    jbra DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_4

/* Status csCode 5, cscGetBaseAddr: base address of a page (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_GetBaseAddr:
    movew %a3@(32),%d1
    movew %d1,%a2@
    jbsr DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34
    movew %a2@(6),%d0
    cmpiw #0,%d0
    jbne DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_4

/* Status csCode 6, cscGetGray: whether luminance mapping (gray) is on (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_GetGray:
    moveq #0,%d1
DECL_DRVR_Display_Video_Apple_RBV1_GetGray_2:  /* loop: bfextu */
    bfextu %a3@(30),%d1,1,%d0
    moveb %d0,%a2@
    jbra DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_4

/* Status csCode 7, cscGetInterrupt: whether the VBL interrupt is enabled (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_GetInterrupt:
    moveq #1,%d1
    jbra DECL_DRVR_Display_Video_Apple_RBV1_GetGray_2

/* Status csCode 8, cscGetGamma: the current gamma table (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_GetGamma:
    movel %a3@(8),%a2@
    jbra DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_4

/* Status csCode 9, cscGetDefaultMode: the default mode (from slot PRAM) (Display Video Apple RBV1). */
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode:
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
    jbra DECL_DRVR_Display_Video_Apple_RBV1_StatusBadCode_4

DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_24:  /* test bit 9 of %a0@(6) */
    btst #9,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_24_A
    rts
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_24_A:  /* set %a0 */
    moveal JIODone,%a0
    jmp %a0@

/* subroutine (19 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34:
    moveml %d0/%d2,%sp@-
    subib #0x80,%d1
    movew #3,%d2
    movew %a3@(34),%d0
    cmpiw #7,%d0
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34_2E
    cmpiw #2,%d0
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34_2E
    cmpiw #6,%d0
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34_24
    subqw #1,%d2
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34_24:  /* test bit 11 of %a3@(30) */
    btst #11,%a3@(30)
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34_2E
    subqw #1,%d2
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34_2E:  /* test %d2,%d1 */
    cmpw %d2,%d1
    jbgt DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34_34
    cmpw %d1,%d1
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_34_34:  /* restore registers, return */
    moveml %sp@+,%d0/%d2
    rts

/* subroutine (19 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E:
    moveml %d0/%a0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E_16
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E_16:  /* set %a0 */
    moveal ghost_VIA2,%a0
    addqw #2,%a0
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E_1C:  /* loop: move */
    moveb %a0@,%d0
    btst #6,%d0
    jbeq DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E_1C
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E_24:  /* loop: move */
    moveb %a0@,%d0
    btst #6,%d0
    jbne DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_6E_24
    movew %sp@+,%sr
    moveml %sp@+,%d0/%a0
    rts

/* subroutine (11 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_A2:
    moveml %d0/%a0-%a1,%sp@-
    moveal ghost_VIA2,%a0
    lea %a0@(16),%a0
    moveb %d1,%a0@
    movew %a2@,%a3@(32)
    moveal 0xdd8,%a1
    addal %a1@(8),%a1
    movel %a1@(4),%a3@
    addil #0,%a3@
    moveml %sp@+,%d0/%a0-%a1
    rts

/* subroutine (301 instructions): traps trap_A440, trap_A722, HLock, trap_A71E, SlotManager, DisposHandle; calls DECL_DRVR_Display_Video_Apple_V8_478, DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4, DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34, DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C, DECL_DRVR_ (mechanical summary) */
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC:
    moveml %d0-%d3/%a0-%a1,%sp@-
    movew %a3@(34),%d0
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_11E),%a1
    movel %a1@(0x0,%d1:w:4),%d3
    cmpiw #2,%d0
    jbne DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_1C
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_136),%a1
    jbra DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_38
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_1C:  /* test #6,%d0 */
    cmpiw #6,%d0
    jbne DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_28
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_140),%a1
    jbra DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_38
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_28:  /* test #7,%d0 */
    cmpiw #7,%d0
    jbne DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_34
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_14A),%a1
    jbra DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_38
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_34:  /* address %pc@(DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_12E) */
    lea %pc@(DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_12E),%a1
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_38:  /* set %a0 */
    moveal %a3@,%a0
    movew %a1@,%d0
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_3C:  /* loop: move */
    movew %a1@(0x2,%d1:w:2),%d2
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_40:  /* loop: move */
    movel %d3,%a0@+
    dbf %d2,DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_40
    notl %d3
    dbf %d0,DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_CC_3C
    moveml %sp@+,%d0-%d3/%a0-%a1
    rts
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_11E:  /* (data) */
    .long   0xAAAAAAAA, 0xCCCCCCCC, 0xF0F0F0F0	| 408FADD4
    .long   0xFF00FF00	| 408FADE0
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_12E:  /* (data) */
    .long   0x03650013, 0x0027004F	| 408FADE4
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_136:  /* (data) */
    .long   0x017F000F	| 408FADEC
    .short  0x001F, 0x003F, 0x007F	| 408FADF0
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_140:  /* (data) */
    .short  0x01DF, 0x0013, 0x0027, 0x004F, 0x009F	| 408FADF6
DECL_DRVR_Display_Video_Apple_RBV1_GetDefaultMode_14A:  /* (data) */
    .short  0x0155, 0x000F, 0x001F, 0x003F, 0x007F	| 408FAE00
DECL_DRVR_Display_Video_Apple_RBV1_Status_27E:  /* set %sp@- */
    movel %a1,%sp@-
    clrw %d0
    moveal JVBLTask,%a0
    jsr %a0@
    moveal %sp@+,%a1
    moveal ghost_VIA2,%a0
    btst #6,%a0@(2)
    jbne DECL_DRVR_Display_Video_Apple_RBV1_Status_2A8
    moveb #64,%a0@(18)
    lea %a1@(16),%a0
    moveq #2,%d0
    moveal 0x568,%a1
    jsr %a1@
DECL_DRVR_Display_Video_Apple_RBV1_Status_2A8:  /* result 1 */
    moveq #1,%d0
    rts
DECL_DRVR_Display_Video_Apple_RBV1_Status_2AC:  /* set %a0 */
    moveal ghost_VIA2,%a0	| 408FAE38
    moveb #0xc0,%a0@(18)	| 408FAE3C
    rts	| 408FAE42

/* Driver (sBlock: length, then the driver: header with the routine offsets, name, code) for Display Video Apple V8. */
DECL_DRVR_Display_Video_Apple_V8:
    .byte   0x00, 0x00, 0x08, 0xA4, 0x4C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3C, 0x00, 0x00	| 408FAE44
    .byte   0x00, 0xEC, 0x05, 0x42, 0x05, 0x22, 0x17	| 408FAE54
    .ascii  ".Display_Video_Apple_V8\000\000"
DECL_DRVR_Display_Video_Apple_V8_30:  /* (data) */
    .byte   0x01, 0x7F, 0x00, 0x80, 0x03, 0x3F, 0x00, 0x40, 0x0F, 0x0F, 0x00, 0x10, 0xFF, 0x00, 0x00, 0x01	| 408FAE74
    moveq #28,%d0	| 408FAE84
    .short  0xA440	| 408FAE86 408FAE86 A-line trap
    moveq #28,%d0	| 408FAE88
    .short  0xA722	| 408FAE8A 408FAE8A A-line trap
    jbne DECL_DRVR_Display_Video_Apple_RBV1_Status_3A4	| 408FAE8C
    movel %a0,%a1@(20)	| 408FAE90
    _HLock	| 408FAE94 408FAE94 A-line trap
    moveal %a0@,%a3	| 408FAE96
    moveal 0xdd8,%a0	| 408FAE98
    addal %a0@,%a0	| 408FAE9C
    movel %a0@(56),%a3@(16)	| 408FAE9E
    movel %a1@(42),%a3@	| 408FAEA4
    moveb %a1@(41),%a3@(26)	| 408FAEA8
    moveq #16,%d0	| 408FAEAE
    .short  0xA71E	| 408FAEB0 408FAEB0 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_RBV1_Status_39E	| 408FAEB2
    movel %a0,%a3@(4)	| 408FAEB4
    jbsr DECL_DRVR_Display_Video_Apple_V8_478	| 408FAEB8
    jbne DECL_DRVR_Display_Video_Apple_RBV1_Status_39E	| 408FAEBC
    moveal ghost_VIA2,%a2	| 408FAEBE
    moveb %a2@(16),%d0	| 408FAEC2
    lsrb #3,%d0	| 408FAEC6
    andiw #7,%d0	| 408FAEC8
    movew %d0,%a3@(24)	| 408FAECC
    subaw #56,%sp	| 408FAED0
    moveal %sp,%a0	| 408FAED4
    moveb %a1@(40),%a0@(49)	| 408FAED6
    moveb %a1@(41),%a0@(50)	| 408FAEDC
    clrb %a0@(51)	| 408FAEE2
    clrb %a0@(52)	| 408FAEE6
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */	| 408FAEEA
    _SlotManager	| 408FAEEC 408FAEEC A-line trap
    moveb #64,%a0@(50)	| 408FAEEE
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 408FAEF4
    _SlotManager	| 408FAEF6 408FAEF6 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_RBV1_Status_39A	| 408FAEF8
    moveb #0x80,%a0@(50)	| 408FAEFA
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */	| 408FAF00
    _SlotManager	| 408FAF02 408FAF02 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_RBV1_Status_39A	| 408FAF04
    moveal %a0@,%a0	| 408FAF06
    movel %a0,%a3@(12)	| 408FAF08
    addqw #2,%a0	| 408FAF0C
DECL_DRVR_Display_Video_Apple_V8_CA:  /* loop: tst */
    tstb %a0@+	| 408FAF0E
    jbne DECL_DRVR_Display_Video_Apple_V8_CA	| 408FAF10
    movel %a0,%d0	| 408FAF12
    addqw #1,%d0	| 408FAF14
    bclr #0,%d0	| 408FAF16
    movel %d0,%a3@(8)	| 408FAF1A
    lea %sp@(56),%sp	| 408FAF1E
    moveq #0,%d0	| 408FAF22
DECL_DRVR_Display_Video_Apple_RBV1_Status_398:  /* return */
    rts
DECL_DRVR_Display_Video_Apple_RBV1_Status_39A:  /* address %sp@(56) */
    lea %sp@(56),%sp	| 408FAF26
DECL_DRVR_Display_Video_Apple_RBV1_Status_39E:  /* set %a0 */
    moveal %a1@(20),%a0	| 408FAF2A
    _DisposHandle	| 408FAF2E 408FAF2E A-line trap
DECL_DRVR_Display_Video_Apple_RBV1_Status_3A4:
    moveq #-23,%d0
    jbra DECL_DRVR_Display_Video_Apple_RBV1_Status_398
    movel %a0,%sp@-	| 408FAF34
    movew %a0@(26),%d0	| 408FAF36
    cmpiw #128,%d0	| 408FAF3A
    jbne DECL_DRVR_Display_Video_Apple_RBV1_Status_3B8	| 408FAF3E
    jbra DECL_DRVR_Display_Video_Apple_V8_4F0	| 408FAF40
DECL_DRVR_Display_Video_Apple_RBV1_Status_3B8:  /* set %a2 */
    moveal %a0@(28),%a2	| 408FAF44
    moveal %a1@(20),%a3	| 408FAF48
    moveal %a3@,%a3	| 408FAF4C
    cmpiw #9,%d0	| 408FAF4E
    jbhi DECL_DRVR_Display_Video_Apple_V8_12C	| 408FAF52
    movew %pc@(DECL_DRVR_Display_Video_Apple_RBV1_Status_3D0,%d0:w:2),%d0	| 408FAF54
    jmp %pc@(DECL_DRVR_Display_Video_Apple_RBV1_Status_3D0,%d0:w)	| 408FAF58
DECL_DRVR_Display_Video_Apple_RBV1_Status_3D0:  /* from here: orib #24,%a0@- */
    orib #24,%a0@-	| 408FAF5C
    oriw #172,%d2	| 408FAF60
    .byte   0x02, 0x0C, 0x02, 0xE2, 0x03, 0x0C, 0x03, 0x1E, 0x03, 0x94, 0x03, 0xAC	| 408FAF64

DECL_DRVR_Display_Video_Apple_V8_12C:  /* result -17 */
    moveq #-17,%d0
    jbra DECL_DRVR_Display_Video_Apple_V8_130_2

DECL_DRVR_Display_Video_Apple_V8_130:  /* loop: moveq */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_V8_130_2:  /* set %a0 */
    moveal %sp@+,%a0
    jbra DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_24
    .long   0x34BC0080	| 408FAF7C
    .long   0x377C0080, 0x0016323C, 0x00017000, 0x35400006	| 408FAF80
    .long   0x6100058C, 0x25530008	| 408FAF90
    jbsr DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4
    jbra DECL_DRVR_Display_Video_Apple_V8_130
    .short  0x3212	| 408FAF9E
    jbsr DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34
    jbne DECL_DRVR_Display_Video_Apple_V8_12C
    tstw %a2@(6)
    jbne DECL_DRVR_Display_Video_Apple_V8_12C
    movew %a2@,%d2
    cmpw %a3@(22),%d2
    jbeq DECL_DRVR_Display_Video_Apple_V8_130_8C
    movew %d2,%a3@(22)
    moveal %a3@(8),%a0
    movew %a0@(4),%d3
    movew %a0@(8),%d2
    lsrw #1,%d2
    lea %a0@(12),%a0
    addaw %d3,%a0
    moveb %a0@(0x0,%d2:w),%d3
    movew %sr,%sp@-
    moveq #7,%d2
    andb %sp@,%d2
    subqb #2,%d2
    jbge DECL_DRVR_Display_Video_Apple_V8_130_6E
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_V8_130_6E:  /* call DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C */
    jbsr DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C
    moveal %a3@(16),%a0
    addqw #1,%a0
    clrb %a0@(-1)
    movew #767,%d2
DECL_DRVR_Display_Video_Apple_V8_130_80:  /* loop: move */
    moveb %d3,%a0@
    dbf %d2,DECL_DRVR_Display_Video_Apple_V8_130_80
    movew %sp@+,%sr
    jbsr DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_8A
DECL_DRVR_Display_Video_Apple_V8_130_8C:  /* set %a2@(8) */
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_V8_130
    .long   0x082B000A, 0x00146600	| 408FB008
    .short  0xFF60	| 408FB010

DECL_DRVR_Display_Video_Apple_V8_1CE:  /* loop: tst */
    tstl %a2@
    jbeq DECL_DRVR_Display_Video_Apple_V8_12C
    moveml %d4-%d7/%a1/%a4-%fp,%sp@-
    movew %a3@(20),%d5
    cmpiw #-1,%a2@(4)
    jbeq DECL_DRVR_Display_Video_Apple_V8_1CE_26
    bset #9,%d5
    cmpiw #131,%a3@(22)
    jblt DECL_DRVR_Display_Video_Apple_V8_1CE_26
    bset #12,%d5
DECL_DRVR_Display_Video_Apple_V8_1CE_26:  /* set %a0 */
    moveal %a3@(8),%a0
    movew %a0@(4),%d0
    lea %a0@(12),%a4
    addaw %d0,%a4
    moveal %a4,%a5
    moveal %a4,%fp
    movew %a0@(10),%d7
    cmpiw #1,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_V8_1CE_56
    movew %a0@(8),%d0
    movew %d7,%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %d1,%d0
    addaw %d0,%a5
    aslw #1,%d0
    addaw %d0,%fp
DECL_DRVR_Display_Video_Apple_V8_1CE_56:  /* set %d6 */
    movel %a3@(16),%d6
    movew %a3@(22),%d1
    subiw #128,%d1
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_30,%d1:w:4),%a3
    movew %a2@(6),%d3
    cmpb %a3@,%d3
    jbhi DECL_DRVR_Display_Video_Apple_V8_1CE_14C
    movel %d3,%d4
    addqw #1,%d4
    btst #12,%d5
    jbeq DECL_DRVR_Display_Video_Apple_V8_1CE_82
    muluw #3,%d4
    jbra DECL_DRVR_Display_Video_Apple_V8_1CE_84
DECL_DRVR_Display_Video_Apple_V8_1CE_82:  /* from here: aslw #2,%d4 */
    aslw #2,%d4
DECL_DRVR_Display_Video_Apple_V8_1CE_84:  /* from here: subaw %d4,%sp */
    subaw %d4,%sp
    moveal %sp,%a0
    moveal %a2@,%a1
    swap %d4
    movew %a2@(4),%d4
DECL_DRVR_Display_Video_Apple_V8_1CE_90:  /* loop: move */
    movew %a1@+,%d0
    btst #12,%d5
    jbne DECL_DRVR_Display_Video_Apple_V8_1CE_AC
    btst #9,%d5
    jbeq DECL_DRVR_Display_Video_Apple_V8_1CE_A2
    movew %d4,%d0
    addqw #1,%d4
DECL_DRVR_Display_Video_Apple_V8_1CE_A2:  /* from here: muluw %a3@(2),%d0 */
    muluw %a3@(2),%d0
    addb %a3@(1),%d0
    moveb %d0,%a0@+
DECL_DRVR_Display_Video_Apple_V8_1CE_AC:  /* set %d0 */
    movew %a1@+,%d0
    movew %a1@+,%d1
    movew %a1@+,%d2
    tstw %d5
    jbpl DECL_DRVR_Display_Video_Apple_V8_1CE_D6
    btst #10,%d5
    jbne DECL_DRVR_Display_Video_Apple_V8_1CE_D6
    muluw #19660,%d0
    muluw #-26870,%d1
    muluw #7209,%d2
    addl %d1,%d0
    addl %d2,%d0
    bfextu %d0,0,%d7,%d1
    movew %d1,%d0
    movew %d1,%d2
    jbra DECL_DRVR_Display_Video_Apple_V8_1CE_E2
DECL_DRVR_Display_Video_Apple_V8_1CE_D6:  /* from here: bfextu %d0,16,%d7,%d0 */
    bfextu %d0,16,%d7,%d0
    bfextu %d1,16,%d7,%d1
    bfextu %d2,16,%d7,%d2
DECL_DRVR_Display_Video_Apple_V8_1CE_E2:  /* set %a0@+ */
    moveb %a4@(0x0,%d0:w),%a0@+
    moveb %a5@(0x0,%d1:w),%a0@+
    moveb %fp@(0x0,%d2:w),%a0@+
    dbf %d3,DECL_DRVR_Display_Video_Apple_V8_1CE_90
    swap %d4
    movew %a2@(6),%d3
    moveal %d6,%a3
    lea %a3@(1),%a3
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge DECL_DRVR_Display_Video_Apple_V8_1CE_110
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_V8_1CE_110:  /* call DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C */
    jbsr DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C
    lea %sp@(2),%a0
    btst #12,%d5
    jbne DECL_DRVR_Display_Video_Apple_V8_1CE_12E
DECL_DRVR_Display_Video_Apple_V8_1CE_11E:  /* loop: move */
    moveb %a0@+,%a3@(-1)
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    dbf %d3,DECL_DRVR_Display_Video_Apple_V8_1CE_11E
    jbra DECL_DRVR_Display_Video_Apple_V8_1CE_140
DECL_DRVR_Display_Video_Apple_V8_1CE_12E:  /* set %d0 */
    movew %a2@(4),%d0
    moveb %d0,%a3@(-1)
DECL_DRVR_Display_Video_Apple_V8_1CE_136:  /* loop: move */
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    dbf %d3,DECL_DRVR_Display_Video_Apple_V8_1CE_136
DECL_DRVR_Display_Video_Apple_V8_1CE_140:  /* set %sr */
    movew %sp@+,%sr
    addaw %d4,%sp
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    jbra DECL_DRVR_Display_Video_Apple_V8_130
DECL_DRVR_Display_Video_Apple_V8_1CE_14C:  /* add 4 to %sp */
    addqw #4,%sp
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    jbra DECL_DRVR_Display_Video_Apple_V8_12C
    .long   0x20126700, 0x00AA2440	| 408FB168
    .long   0x4A526600, 0xFDFC4A6A, 0x00026720, 0x0C6A001A	| 408FB170
    .long   0x00026600, 0xFDEC4A6A, 0x00046710, 0x302A000C	| 408FB180
    .long   0xB06B0018, 0x67065240, 0x6600FDD6, 0x206B0008	| 408FB190
    .long   0x302A0004, 0xB0680004, 0x6612302A, 0x0006B068	| 408FB1A0
    .long   0x00066732, 0x6E06A01F, 0x42AB0008, 0x302A0008	| 408FB1B0
    .long   0xC0EA0006, 0xD06A0004, 0x0640000C, 0xA51E6600	| 408FB1C0
    .long   0xFDA0202B, 0x00082748, 0x00084A80, 0x67082040	| 408FB1D0
    .short  0xA01F	| 408FB1E0
    moveal %a3@(8),%a0
    movew %a2@(6),%d0
    movew %a2@(4),%d1
    movew %a2@(8),%d2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    muluw %d0,%d2
    addw %d1,%d2
    subqw #1,%d2
DECL_DRVR_Display_Video_Apple_V8_1CE_1EC:  /* loop: move */
    moveb %a2@+,%d0
    moveb %d0,%a0@+
    dbf %d2,DECL_DRVR_Display_Video_Apple_V8_1CE_1EC
    btst #10,%a3@(20)
    jbeq DECL_DRVR_Display_Video_Apple_V8_1CE_200
    jbsr DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150
DECL_DRVR_Display_Video_Apple_V8_1CE_200:  /* continue at DECL_DRVR_Display_Video_Apple_V8_130 */
    jbra DECL_DRVR_Display_Video_Apple_V8_130
    moveal %a3@(8),%a0
    movew %a0@(4),%d0
    movew %a0@(6),%d2
    subqw #1,%d2
    lea %a0@(12),%a0
    addaw %d0,%a0
DECL_DRVR_Display_Video_Apple_V8_1CE_218:  /* loop: move */
    movew #255,%d0
DECL_DRVR_Display_Video_Apple_V8_1CE_21C:  /* loop: move */
    moveb %d0,%a0@(0x0,%d0:w)
    dbf %d0,DECL_DRVR_Display_Video_Apple_V8_1CE_21C
    dbf %d2,DECL_DRVR_Display_Video_Apple_V8_1CE_218
    jbra DECL_DRVR_Display_Video_Apple_V8_130
    .short  0x322B	| 408FB23E
    .long   0x00163481, 0x61000282, 0x6600FD26, 0x302A0006	| 408FB240
    .long   0x6600FD1E, 0x61000322	| 408FB250
    btst #10,%a3@(20)
    jbeq DECL_DRVR_Display_Video_Apple_V8_1CE_252
    jbsr DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150
DECL_DRVR_Display_Video_Apple_V8_1CE_252:  /* continue at DECL_DRVR_Display_Video_Apple_V8_130 */
    jbra DECL_DRVR_Display_Video_Apple_V8_130
    moveq #0,%d1
    jbsr DECL_DRVR_Display_Video_Apple_V8_42C
    jbra DECL_DRVR_Display_Video_Apple_V8_130

/* subroutine (11 instructions): calls DECL_DRVR_Display_Video_Apple_V8_42C, DECL_DRVR_Display_Video_Apple_V8_478, DECL_DRVR_Display_Video_Apple_V8_44C (mechanical summary) */
DECL_DRVR_Display_Video_Apple_V8_42C:
    moveb %a2@,%d0
    bfins %d0,%a3@(20),%d1,1
    rts
    moveq #1,%d1
    jbsr DECL_DRVR_Display_Video_Apple_V8_42C
    jbne DECL_DRVR_Display_Video_Apple_V8_42C_1A
    jbsr DECL_DRVR_Display_Video_Apple_V8_478
    jbne DECL_DRVR_Display_Video_Apple_V8_12C
    jbra DECL_DRVR_Display_Video_Apple_V8_130
DECL_DRVR_Display_Video_Apple_V8_42C_1A:  /* call DECL_DRVR_Display_Video_Apple_V8_44C */
    jbsr DECL_DRVR_Display_Video_Apple_V8_44C
    jbra DECL_DRVR_Display_Video_Apple_V8_130

/* subroutine (15 instructions): traps SIntRemove; calls DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C (mechanical summary) */
DECL_DRVR_Display_Video_Apple_V8_44C:
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge DECL_DRVR_Display_Video_Apple_V8_44C_12
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_V8_44C_12:  /* call DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C */
    jbsr DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C
    moveal ghost_VIA2,%a0
    moveb #64,%a0@(18)
    movew %sp@+,%sr
    clrw %d0
    moveal %a3@(4),%a0
    _SIntRemove
    rts

/* subroutine (60 instructions): traps SIntInstall, DisposPtr, DisposHandle; calls DECL_DRVR_Display_Video_Apple_V8_44C (mechanical summary) */
DECL_DRVR_Display_Video_Apple_V8_478:
    moveal %a3@(4),%a0
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_Status_348),%a2
    movew #6,%a0@(4)
    movel %a2,%a0@(8)
    moveal %a1@(20),%a2
    moveal %a2@,%a2
    movel %a2,%a0@(12)
    clrw %d0
    _SIntInstall
    jbne DECL_DRVR_Display_Video_Apple_V8_478_32
    movel %a0,%sp@-
    moveal ghost_VIA2,%a0
    moveb #0xc0,%a0@(18)
    moveal %sp@+,%a0
    movew %d0,%d0
DECL_DRVR_Display_Video_Apple_V8_478_32:  /* return */
    rts
    btst #10,%a3@(20)
    jbeq DECL_DRVR_Display_Video_Apple_V8_12C
    cmpiw #31,%a2@(6)
    jbgt DECL_DRVR_Display_Video_Apple_V8_12C
    jbra DECL_DRVR_Display_Video_Apple_V8_1CE
    .byte   0x9E, 0xFC, 0x00, 0x38, 0x20, 0x4F, 0x11, 0x69, 0x00, 0x28, 0x00, 0x31, 0x42, 0x28, 0x00, 0x33	| 408FB308
    .byte   0x51, 0x4F, 0x20, 0x8F, 0x70, 0x11, 0xA0, 0x6E, 0x1F, 0x52, 0x00, 0x03, 0x21, 0x4F, 0x00, 0x04	| 408FB318
    .byte   0x70, 0x12, 0xA0, 0x6E, 0x4F, 0xEF, 0x00, 0x40, 0x60, 0x00, 0xFC, 0x42	| 408FB328
DECL_DRVR_Display_Video_Apple_V8_4F0:  /* set %sp@- */
    movew %sr,%sp@-	| 408FB334
    moveq #7,%d2	| 408FB336
    andb %sp@,%d2	| 408FB338
    subqb #2,%d2	| 408FB33A
    jbge DECL_DRVR_Display_Video_Apple_V8_502	| 408FB33C
    oriw #512,%sr	| 408FB33E
    andiw #-1281,%sr	| 408FB342
DECL_DRVR_Display_Video_Apple_V8_502:  /* set %a0 */
    moveal 0xdd8,%a0	| 408FB346
    addal %a0@,%a0	| 408FB34A
    moveal %a0@(56),%a0	| 408FB34C
    addqw #1,%a0	| 408FB350
    clrb %a0@(-1)	| 408FB352
    moveb #127,%d3	| 408FB356
    movew #1793,%d2	| 408FB35A
DECL_DRVR_Display_Video_Apple_V8_51A:  /* loop: move */
    moveb %d3,%a0@	| 408FB35E
    dbf %d2,DECL_DRVR_Display_Video_Apple_V8_51A	| 408FB360
    movew %sp@+,%sr	| 408FB364
    jbra DECL_DRVR_Display_Video_Apple_V8_130	| 408FB366
    moveal %a1@(20),%a3	| 408FB36A
    moveal %a3@,%a3	| 408FB36E
    jbsr DECL_DRVR_Display_Video_Apple_V8_44C	| 408FB370
    moveal %a3@(4),%a0	| 408FB374
    _DisposPtr	| 408FB378 408FB378 A-line trap
    moveal %a3@(12),%a0	| 408FB37A
    _DisposPtr	| 408FB37E 408FB37E A-line trap
    moveal %a1@(20),%a0	| 408FB380
    _DisposHandle	| 408FB384 408FB384 A-line trap
    moveq #0,%d0	| 408FB386
    rts	| 408FB388

/* Status: find csCode in the status table and call its routine (out of range: StatusBadCode) (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_Status:
    movel %a0,%sp@-	| 408FB38A
    movew %a0@(26),%d0	| 408FB38C
    moveal %a0@(28),%a2
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    cmpiw #9,%d0
    jbhi DECL_DRVR_Display_Video_Apple_V8_StatusBadCode
    lslw #1,%d0
    movew %pc@(DECL_DRVR_Display_Video_Apple_V8_StatusTable,%d0:w),%d0
    jmp %pc@(DECL_DRVR_Display_Video_Apple_V8_StatusTable,%d0:w)

/* status table: routine offsets by csCode (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_StatusTable:
    .short  DECL_DRVR_Display_Video_Apple_V8_StatusBadCode-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3AA
    .short  DECL_DRVR_Display_Video_Apple_V8_StatusBadCode-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3AC
    .short  DECL_DRVR_Display_Video_Apple_V8_GetMode-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3AE
    .short  DECL_DRVR_Display_Video_Apple_V8_GetEntries-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3B0
    .short  DECL_DRVR_Display_Video_Apple_V8_GetPages-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3B2
    .short  DECL_DRVR_Display_Video_Apple_V8_GetBaseAddr-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3B4
    .short  DECL_DRVR_Display_Video_Apple_V8_GetGray-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3B6
    .short  DECL_DRVR_Display_Video_Apple_V8_GetInterrupt-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3B8
    .short  DECL_DRVR_Display_Video_Apple_V8_GetGamma-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3BA
    .short  DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode-DECL_DRVR_Display_Video_Apple_V8_StatusTable	| 408FB3BC

/* unknown status csCode: statusErr (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_StatusBadCode:
    moveq #-18,%d0
    jbra DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_6
DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_4:  /* loop: moveq */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_6:  /* set %a0 */
    moveal %sp@+,%a0
    jbra DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_24

/* Status csCode 2, cscGetMode: current mode, page and base address (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_GetMode:
    movew %a3@(22),%a2@
    clrw %a2@(6)
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_4

/* Status csCode 3, cscGetEntries: read colour table entries (from the CLUT) (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_GetEntries:
    movel %a2@,%d0
    jbeq DECL_DRVR_Display_Video_Apple_V8_StatusBadCode
    moveml %d2-%d5/%a1/%a3-%a4,%sp@-
    moveal %d0,%a4
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_30),%a0
    movew %a3@(22),%d0
    subiw #128,%d0
    moveb %a0@(0x0,%d0:w:4),%d3
    moveb %a0@(0x1,%d0:w:4),%d4
    movew %a0@(0x2,%d0:w:4),%d5
    movew %a2@(6),%d0
    movew %d0,%d2
    tstw %a2@(4)
    jbmi DECL_DRVR_Display_Video_Apple_V8_GetEntries_3E
    movew %d0,%d1
    addw %a2@(4),%d2
DECL_DRVR_Display_Video_Apple_V8_GetEntries_34:  /* loop: move */
    movew %d2,%a4@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,DECL_DRVR_Display_Video_Apple_V8_GetEntries_34
DECL_DRVR_Display_Video_Apple_V8_GetEntries_3E:  /* set %a1 */
    moveal %a3@(16),%a1
    addqw #1,%a1
    movew %sr,%sp@-
    moveq #7,%d1
    andb %sp@,%d1
    subqb #2,%d1
    jbge DECL_DRVR_Display_Video_Apple_V8_GetEntries_56
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_V8_GetEntries_56:  /* loop: move */
    movew %a4@+,%d1
    cmpb %d3,%d1
    jbhi DECL_DRVR_Display_Video_Apple_V8_GetEntries_70
    muluw %d5,%d1
    addb %d4,%d1
    moveb %d1,%a1@(-1)
    moveq #2,%d6
DECL_DRVR_Display_Video_Apple_V8_GetEntries_66:  /* loop: move */
    moveb %a1@,%d1
    moveb %d1,%a4@+
    moveb %d1,%a4@+
    dbf %d6,DECL_DRVR_Display_Video_Apple_V8_GetEntries_66
DECL_DRVR_Display_Video_Apple_V8_GetEntries_70:  /* count down */
    dbf %d0,DECL_DRVR_Display_Video_Apple_V8_GetEntries_56
    movew %sp@+,%sr
    moveml %sp@+,%d2-%d5/%a1/%a3-%a4
    jbra DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_4

/* Status csCode 4, cscGetPages: number of video pages for a mode (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_GetPages:
    movew %a2@,%d1
    movew %d1,%d2
    jbsr DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34
    jbgt DECL_DRVR_Display_Video_Apple_V8_StatusBadCode
    movew #1,%a2@(6)
    jbra DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_4

/* Status csCode 5, cscGetBaseAddr: base address of a page (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_GetBaseAddr:
    tstw %a2@(6)
    jbne DECL_DRVR_Display_Video_Apple_V8_StatusBadCode
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_4

/* Status csCode 6, cscGetGray: whether luminance mapping (gray) is on (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_GetGray:
    moveq #0,%d1
DECL_DRVR_Display_Video_Apple_V8_GetGray_2:  /* loop: bfextu */
    bfextu %a3@(20),%d1,1,%d0
    moveb %d0,%a2@
    jbra DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_4

/* Status csCode 7, cscGetInterrupt: whether the VBL interrupt is enabled (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_GetInterrupt:
    moveq #1,%d1
    jbra DECL_DRVR_Display_Video_Apple_V8_GetGray_2

/* Status csCode 8, cscGetGamma: the current gamma table (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_GetGamma:
    movel %a3@(8),%a2@
    jbra DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_4

/* Status csCode 9, cscGetDefaultMode: the default mode (from slot PRAM) (Display Video Apple V8). */
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode:
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
    jbra DECL_DRVR_Display_Video_Apple_V8_StatusBadCode_4

DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_24:  /* test bit 9 of %a0@(6) */
    btst #9,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_24_A
    rts
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_24_A:  /* set %a0 */
    moveal JIODone,%a0
    jmp %a0@

/* subroutine (19 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34:
    moveml %d0/%d2-%d3,%sp@-
    subiw #128,%d1
    moveb %a3@(26),%d0
    bclr #4,%d0
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34_16
    bset #2,%d0
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34_16:  /* set %d2 */
    movew #2,%d2
    moveb %d0,%d3
    andib #5,%d3
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34_24
    addqw #1,%d2
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34_24:  /* test bit 3 of %d0 */
    btst #3,%d0
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34_2C
    addqw #1,%d2
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34_2C:  /* test %d2,%d1 */
    cmpb %d2,%d1
    jbgt DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34_32
    cmpw %d1,%d1
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_34_32:  /* restore registers, return */
    moveml %sp@+,%d0/%d2-%d3
    rts

/* subroutine (11 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C:
    movel %a0,%sp@-
    movel %d0,%sp@-
    moveal ghost_VIA2,%a0
    moveb #64,%a0@(2)
    addqw #2,%a0
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C_10:  /* loop: move */
    moveb %a0@,%d0
    btst #6,%d0
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_6C_10
    movel %sp@+,%d0
    moveal %sp@+,%a0
    rts

/* subroutine (25 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_8A:
    moveml %d2-%d3/%a0-%a1,%sp@-
    moveb %d1,%d3
    moveb %a3@(26),%d2
    andib #0xf7,%d2
    cmpib #0xb2,%d2
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_8A_16
    addqw #1,%d3
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_8A_16:  /* set %a0 */
    moveal ghost_VIA2,%a0
    moveb %a0@(16),%d2
    andib #0xf8,%d2
    orb %d3,%d2
    moveb %d2,%a0@(16)
    moveal %a3@(16),%a0
    moveb %a0@(2),%d2
    andib #0xf8,%d2
    orb %d1,%d2
    moveb %d2,%a0@(2)
    movew %a2@,%a3@(22)
    cmpiw #132,%a3@(22)
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_8A_4E
    bset #10,%a3@(20)
    jbra DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_8A_54
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_8A_4E:  /* clear bit 10 of %a3@(20) */
    bclr #10,%a3@(20)
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_8A_54:  /* restore registers, return */
    moveml %sp@+,%d2-%d3/%a0-%a1
    rts

/* subroutine (27 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4:
    moveml %d0-%d3/%a0-%a1,%sp@-
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_13C),%a1
    movel %a1@(0x0,%d1:w:4),%d3
    moveq #23,%d0
    andb %a3@(26),%d0
    cmpib #2,%d0
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_1E
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_1C4),%a1
    jbra DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_2E
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_1E:  /* test #18,%d0 */
    cmpib #18,%d0
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_2A
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_1EC),%a1
    jbra DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_2E
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_2A:  /* address %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_1DA) */
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_1DA),%a1
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_2E:  /* test bit 3 of %a3@(26) */
    btst #3,%a3@(26)
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_3A
    lea %a1@(58),%a1
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_3A:  /* set %a0 */
    moveal %a3@,%a0
    movew %a1@+,%d0
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_3E:  /* loop: move */
    movew %a1@(0x0,%d1:w:4),%d2
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_42:  /* loop: move */
    movel %d3,%a0@+
    dbf %d2,DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_42
    addaw %a1@(0x2,%d1:w:4),%a0
    notl %d3
    dbf %d0,DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_E4_3E
    moveml %sp@+,%d0-%d3/%a0-%a1
    rts
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_13C:  /* (data) */
    .long   0xAAAAAAAA, 0xCCCCCCCC, 0xF0F0F0F0, 0xFF00FF00	| 408FB5D0
    .long   0x0000FFFF	| 408FB5E0

/* subroutine (323 instructions): traps trap_A440, trap_A722, HLock, StripAddress, trap_A71E, SwapMMUMode, SlotManager, DisposPtr; calls DECL_DRVR_Display_Video_Apple_DAFB_84E, DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268, DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138, DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C (mechanical summary) */
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150:
    moveml %d0-%d2/%a0/%a4-%fp,%sp@-
    moveal %a3@(8),%a0
    movew %a0@(4),%d0
    lea %a0@(12),%a4
    addaw %d0,%a4
    moveal %a4,%a5
    moveal %a4,%fp
    cmpiw #1,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150_30
    movew %a0@(10),%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %a0@(8),%d1
    addaw %d1,%a5
    aslw #1,%d0
    addaw %d1,%fp
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150_30:  /* set %a0 */
    moveal %a3@(16),%a0
    addqw #1,%a0
    clrb %a0@(-1)
    movew #31,%d2
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150_50
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150_50:  /* clear %d0 */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150_52:  /* loop: move */
    movel %d0,%d1
    swap %d1
    moveb %a4@(0x0,%d1:w),%a0@
    moveb %a5@(0x0,%d1:w),%a0@
    moveb %fp@(0x0,%d1:w),%a0@
    addil #538880,%d0
    dbf %d2,DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150_52
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d2/%a0/%a4-%fp
    rts
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_1C4:  /* (data) */
    .long   0x017F000F, 0x01C0001F	| 408FB658
    .short  0x0180, 0x003F, 0x0100, 0x007F, 0x0000, 0x0000, 0x0000	| 408FB660
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_1DA:  /* (data) */
    .short  0x01DF	| 408FB66E
    .long   0x001301B0, 0x00270160, 0x004F00C0, 0x00000000	| 408FB670
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_1EC:  /* (data) */
    .long   0x017F0010, 0x01BA0022, 0x01740045, 0x00E80000	| 408FB680
    .long   0x0000017F, 0x000F03C0, 0x001F0380, 0x003F0300	| 408FB690
    .long   0x007F0200, 0x00FF0000, 0x01DF0013, 0x03B00027	| 408FB6A0
    .long   0x0360004F, 0x02C0009F, 0x0180017F, 0x001003BA	| 408FB6B0
    .short  0x0022, 0x0374	| orib #116,%a2@-
    oriw #744,%d5
    .short  0x008B	| 408FB6C8
    bset %d0,%a0@
    bset %d0,%sp@+
    orib #0,%a3@
DECL_DRVR_Display_Video_Apple_V8_Status_348:  /* set %a0 */
    moveal ghost_VIA2,%a0
    moveb #64,%a0@(2)
    clrw %d0
    moveal JVBLTask,%a0
    jsr %a0@
    moveq #1,%d0
    rts
DECL_DRVR_Display_Video_Apple_DAFB:/* DAFB driver header: size 0x1528; offsets of Open (0xA0), Control (0x360), Status (0xBDA), Close (0xB96); name, version */
    .long   0x00001528, 0x4C000000	| 408FB6E8
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x03, 0x60, 0x0B, 0xDA, 0x0B, 0x96, 0x19	| 408FB6F0
    .ascii  ".Display_Video_Apple_DAFB\000"
    .byte   0x03	| 408FB719
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_286:/* colors minus 1 per mode without 16-bit depth: 1, 2, 4, 8 bits, 32-bit */
    .byte   0x01, 0x03, 0x0F, 0xFF, 0xFF	| 408FB71A
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_28B:/* the same with 16-bit depth (flag bit 9): 1, 2, 4, 8, 16 (31), 32 bits */
    .byte   0x01, 0x03, 0x0F, 0xFF, 0x1F, 0xFF, 0x00	| 408FB71F
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_292:/* fill patterns per mode (1, 2, 4, 8 bits, direct) for graying the screen */
    .byte   0xAA, 0xAA, 0xAA, 0xAA, 0xCC, 0xCC, 0xCC, 0xCC, 0xF0, 0xF0, 0xF0, 0xF0, 0xFF, 0x00, 0xFF, 0x00	| 408FB726
    .byte   0x00, 0x00, 0x00, 0x00	| 408FB736
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_2A6:/* the same with 16-bit depth */
    .byte   0xAA, 0xAA, 0xAA, 0xAA, 0xCC, 0xCC, 0xCC, 0xCC, 0xF0, 0xF0, 0xF0, 0xF0, 0xFF, 0x00, 0xFF, 0x00	| 408FB73A
    .byte   0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00	| 408FB74A
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_2BE:/* count - 1, then the monitor sense codes csCode 131 accepts */
    .byte   0x00, 0x0C, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x00, 0x14, 0x17, 0x2D, 0x30, 0x3A, 0x00	| 408FB752
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_2CE:/* per timing word and mode: amounts added to register +360 for boards with +33 set */
    .byte   0x00, 0x20, 0x00, 0x10, 0x00, 0x08, 0x00, 0x04, 0x00, 0x02, 0x00, 0x01, 0x00, 0x10, 0x00, 0x08	| 408FB762
    .byte   0x00, 0x04, 0x00, 0x02, 0x00, 0x01, 0x00, 0x00, 0x00, 0x08, 0x00, 0x04, 0x00, 0x02, 0x00, 0x01	| 408FB772
    .byte   0x00, 0x00, 0x00, 0x00	| 408FB782
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_2F2:/* 3 words of adjustment; then Open: 42-byte locked globals in the system heap: +0 and +4 frame buffer base, +8 interrupt queue element, +12 gamma, +20 RAMDAC, +24 DAFB registers (from ProductInfo), +28 timing data, +32 flags, +36 mode, +38 monitor, +40 sResource; interrupts on; the gamma resource */
    .byte   0x00, 0x05, 0x00, 0x02, 0x00, 0x01	| 408FB786
    moveq #42,%d0	| 408FB78C
    .short  0xA440	| 408FB78E 408FB78E A-line trap
    moveq #42,%d0	| 408FB790
    .short  0xA722	| 408FB792 408FB792 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6BE	| 408FB794
    movel %a0,%a1@(20)	| 408FB798
    _HLock	| 408FB79C 408FB79C A-line trap
    movel %a0@,%d0	| 408FB79E
    _StripAddress	| 408FB7A0 408FB7A0 A-line trap
    moveal %d0,%a3	| 408FB7A2
    moveal 0xdd8,%a0	| 408FB7A4
    addal %a0@,%a0	| 408FB7A8
    movel %a0@(56),%a3@(20)	| 408FB7AA
    movel %a0@(104),%a3@(24)	| 408FB7B0
    moveal 0xdd8,%a0	| 408FB7B6
    addal %a0@(8),%a0	| 408FB7BA
    movel %a0@(4),%a3@	| 408FB7BE
    moveq #16,%d0	| 408FB7C2
    .short  0xA71E	| 408FB7C4 408FB7C4 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6B8	| 408FB7C6
    movel %a0,%a3@(8)	| 408FB7CA
    moveq #1,%d0	| 408FB7CE
    _SwapMMUMode	| 408FB7D0 408FB7D0 A-line trap
    moveal %a3@(24),%a2	| 408FB7D2
    oril #2048,%a2@(288)	| 408FB7D6
    movel #4082,%a2@(256)	| 408FB7DE
    _SwapMMUMode	| 408FB7E6 408FB7E6 A-line trap
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_84E	| 408FB7E8
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6B8	| 408FB7EC
    subaw #56,%sp	| 408FB7F0
    moveal %sp,%a0	| 408FB7F4
    moveb %a1@(40),%a0@(49)	| 408FB7F6
    moveb %a1@(41),%a0@(50)	| 408FB7FC
    clrb %a0@(51)	| 408FB802
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */	| 408FB806
    _SlotManager	| 408FB808 408FB808 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6B4	| 408FB80A
    moveb #64,%a0@(50)	| 408FB80E
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 408FB814
    _SlotManager	| 408FB816 408FB816 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_3AC	| 408FB818
    moveb #0x80,%a0@(50)	| 408FB81A
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */	| 408FB820
    _SlotManager	| 408FB822 408FB822 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_3AC	| 408FB824
    moveal %a0@,%a0	| 408FB826
    movel %a0,%a3@(16)	| 408FB828
    addqw #2,%a0	| 408FB82C
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_39A:/* skip the gamma table's name; align */
    tstb %a0@+	| 408FB82E
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_39A	| 408FB830
    movel %a0,%d0	| 408FB832
    addqw #1,%d0	| 408FB834
    bclr #0,%d0	| 408FB836
    movel %d0,%a3@(12)	| 408FB83A
    jbra DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_3E6	| 408FB83E
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_3AC:/* no gamma resource: a linear 256-entry table */
    moveq #12,%d0	| 408FB840
    addiw #256,%d0	| 408FB842
    .short  0xA71E	| 408FB846 408FB846 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6B4	| 408FB848
    movel %a0,%a3@(16)	| 408FB84C
    movel %a0,%a3@(12)	| 408FB850
    movew #28,%a0@(2)	| 408FB854
    movew #1,%a0@(6)	| 408FB85A
    movew #256,%a0@(8)	| 408FB860
    movew #8,%a0@(10)	| 408FB866
    lea %a0@(268),%a0	| 408FB86C
    movew #255,%d0	| 408FB870
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_3E0:/* loop: value = index */
    moveb %d0,%a0@-	| 408FB874
    dbf %d0,DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_3E0	| 408FB876
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_3E6:/* the board's timing block (type 3,1,1,28 sResources, id 126); +28; base address offset; PRAM: mode (+36), monitor (+38), flags */
    moveal %sp,%a0	| 408FB87A
    clrw %a0@(50)	| 408FB87C
    clrb %a0@(48)	| 408FB880
    movew #1,%a0@(40)	| 408FB884
    clrw %a0@(42)	| 408FB88A
    clrw %a0@(44)	| 408FB88E
    clrw %a0@(46)	| 408FB892
    clrl %a0@(24)	| 408FB896
    bset #1,%a0@(27)	| 408FB89A
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */	| 408FB8A0
    _SlotManager	| 408FB8A2 408FB8A2 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6AE	| 408FB8A4
    moveb #126,%a0@(50)	| 408FB8A8
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 408FB8AE
    _SlotManager	| 408FB8B0 408FB8B0 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6AE	| 408FB8B2
    moveal %a3@(24),%a4	| 408FB8B6
    moveb %a1@(41),%d1	| 408FB8BA
    moveq #1,%d0	| 408FB8BE
    _SwapMMUMode	| 408FB8C0 408FB8C0 A-line trap
    moveb %d0,%sp@-	| 408FB8C2
    movel %a4@(288),%d0	| 408FB8C4
    btst #4,%d0	| 408FB8C8
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_44A	| 408FB8CC
    btst #5,%d0	| 408FB8CE
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_446	| 408FB8D2
    moveb #0xfd,%d1	| 408FB8D4 408FB8D4 moveb #-3,%d1
    jbra DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_44A	| 408FB8D8
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_446:/* the alternative timing block when the register +288 bit 5 is clear */
    moveb #0xfe,%d1	| 408FB8DA 408FB8DA moveb #-2,%d1
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_44A:/* load it (+28); minor base offset added to +0; read PRAM; mode, monitor, sResource; PRAM flag bit 0 to flags bit 8 */
    moveb %sp@+,%d0	| 408FB8DE
    _SwapMMUMode	| 408FB8E0 408FB8E0 A-line trap
    moveb %d1,%a0@(50)	| 408FB8E2
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */	| 408FB8E6
    _SlotManager	| 408FB8E8 408FB8E8 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6AE	| 408FB8EA
    movel %a0@,%a3@(28)	| 408FB8EE
    moveb %a1@(41),%a0@(50)	| 408FB8F2
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */	| 408FB8F8
    _SlotManager	| 408FB8FA 408FB8FA A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6A8	| 408FB8FC
    moveb #10,%a0@(50)	| 408FB900
    moveq #2,%d0	/* _SlotManager 2: READSLOTLONG, sReadLong */	| 408FB906
    _SlotManager	| 408FB908 408FB908 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6A8	| 408FB90A
    movel %a0@,%d0	| 408FB90E
    addl %d0,%a3@	| 408FB910
    moveal %sp,%a0	| 408FB912
    moveb %a1@(40),%a0@(49)	| 408FB914
    subqw #8,%sp	| 408FB91A
    movel %sp,%a0@	| 408FB91C
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */	| 408FB91E
    _SlotManager	| 408FB920 408FB920 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6A6	| 408FB922
    moveq #0,%d3	| 408FB926
    moveq #0,%d2	| 408FB928
    moveb %sp@(2),%d3	| 408FB92A
    moveb %sp@(5),%d2	| 408FB92E
    moveb %sp@(6),%d1	| 408FB932
    lea %sp@(64),%sp	| 408FB936
    movew %d3,%a3@(36)	| 408FB93A
    movew %d2,%a3@(38)	| 408FB93E
    moveb %a1@(41),%a3@(40)	| 408FB942
    btst #0,%d1	| 408FB948
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_4C0	| 408FB94C
    bset #8,%a3@(32)	| 408FB94E
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_4C0:/* PRAM bit 1: +34; PRAM bit 4: 16-bit depth available (flags bit 9) */
    btst #1,%d1	| 408FB954
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_4D8	| 408FB958
    moveb #1,%a3@(34)	| 408FB95A
    btst #4,%d1	| 408FB960
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_4D8	| 408FB964
    bset #9,%a3@(32)	| 408FB966
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_4D8:/* PRAM bit 3 to +35 */
    moveal %a3@(24),%a4	| 408FB96C
    btst #3,%d1	| 408FB970
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_4E8	| 408FB974
    clrb %a3@(35)	| 408FB976
    jbra DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_4EE	| 408FB97A
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_4E8:/* set */
    moveb #1,%a3@(35)	| 408FB97C
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_4EE:/* register +24 = 1 if register +16 bit 0 is clear and +35 is set */
    moveb #1,%d0	| 408FB982
    _SwapMMUMode	| 408FB986 408FB986 A-line trap
    moveb %d0,%sp@-	| 408FB988
    movel %a4@(16),%d0	| 408FB98A
    bfextu %d0,31,1,%d0	| 408FB98E
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_50A	| 408FB992
    tstb %a3@(35)	| 408FB994
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_50A	| 408FB998
    moveq #1,%d0	| 408FB99A
    jbra DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_50C	| 408FB99C
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_50A:/* 0 */
    moveq #0,%d0	| 408FB99E
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_50C:/* store; register +288 bit 3 to +33 */
    movel %d0,%a4@(24)	| 408FB9A0
    movel %a4@(288),%d0	| 408FB9A4
    btst #3,%d0	| 408FB9A8
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_520	| 408FB9AC
    moveb #1,%a3@(33)	| 408FB9AE
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_520:/* register +288 bit 6 to +41 */
    btst #6,%d0	| 408FB9B4
    jbeq DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_52C	| 408FB9B8
    moveb #1,%a3@(41)	| 408FB9BA
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_52C:/* flags bit 11 clear: program the mode, its base, gray the screen */
    movew %d0,%d1	| 408FB9C0
    moveb %sp@+,%d0	| 408FB9C2
    _SwapMMUMode	| 408FB9C4 408FB9C4 A-line trap
    btst #11,%d1	| 408FB9C6
    jbne DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_54E	| 408FB9CA
    movew %a3@(36),%d1	| 408FB9CC
    subiw #128,%d1	| 408FB9D0
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C
    jbra DECL_DRVR_Display_Video_Apple_V8_Status_662
DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_54E:/* flags bit 11 set: only the state for mode 128 */
    movew #128,%a3@(36)	| 408FB9E2
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138	| 408FB9E8
DECL_DRVR_Display_Video_Apple_V8_Status_662:/* monitor 1 or 3: flags bits 13 and 15 (no color, luminance mapping) */
    cmpiw #1,%a3@(38)
    jbeq DECL_DRVR_Display_Video_Apple_V8_Status_674
    cmpiw #3,%a3@(38)
    jbeq DECL_DRVR_Display_Video_Apple_V8_Status_674
    jbra DECL_DRVR_Display_Video_Apple_V8_Status_680
DECL_DRVR_Display_Video_Apple_V8_Status_674:/* set them */
    bset #13,%a3@(32)
    bset #15,%a3@(32)
DECL_DRVR_Display_Video_Apple_V8_Status_680:/* the sense line: VIA2 bit 5 or, with +33, VIA1 +0x1E00 bit 4 */
    tstb %a3@(33)
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_690
    moveal ghost_VIA2,%a0
    btst #5,%a0@
    jbra DECL_DRVR_Display_Video_Apple_V8_Status_69A
DECL_DRVR_Display_Video_Apple_V8_Status_690:/* the other VIA */
    moveal VIA,%a0
    btst #4,%a0@(7680)
DECL_DRVR_Display_Video_Apple_V8_Status_69A:/* set: flags bit 11 */
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_6A2
    bset #11,%a3@(32)
DECL_DRVR_Display_Video_Apple_V8_Status_6A2:/* noErr */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_V8_Status_6A4:/* return */
    rts
DECL_DRVR_Display_Video_Apple_V8_Status_6A6:/* errors: undo what was allocated, last first */
    addqw #8,%sp	| 408FBA30
DECL_DRVR_Display_Video_Apple_V8_Status_6A8:/* dispose of the timing block */
    moveal %a3@(28),%a0	| 408FBA32
    _DisposPtr	| 408FBA36 408FBA36 A-line trap
DECL_DRVR_Display_Video_Apple_V8_Status_6AE:/* dispose of the gamma table */
    moveal %a3@(16),%a0	| 408FBA38
    _DisposPtr	| 408FBA3C 408FBA3C A-line trap
DECL_DRVR_Display_Video_Apple_V8_Status_6B4:/* drop the Slot Manager parameter block */
    lea %sp@(56),%sp	| 408FBA3E
DECL_DRVR_Display_Video_Apple_V8_Status_6B8:/* dispose of the globals */
    moveal %a1@(20),%a0	| 408FBA42
    _DisposHandle	| 408FBA46 408FBA46 A-line trap
DECL_DRVR_Display_Video_Apple_V8_Status_6BE:/* openErr (-23); after it, Control: csCodes 128..131 are private, 0..9 through the table */
    moveq #-23,%d0
    jbra DECL_DRVR_Display_Video_Apple_V8_Status_6A4
    moveml %a0-%a1,%sp@-	| 408FBA4C
    moveal %a0@(28),%a2	| 408FBA50
    moveal %a1@(20),%a3	| 408FBA54
    movel %a3@,%d0	| 408FBA58
    _StripAddress	| 408FBA5A 408FBA5A A-line trap
    moveal %d0,%a3	| 408FBA5C
    movew %a0@(26),%d0	| 408FBA5E
    cmpiw #128,%d0	| 408FBA62
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_930	| 408FBA66
    cmpiw #129,%d0	| 408FBA6A
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_9CC	| 408FBA6E
    cmpiw #130,%d0	| 408FBA72
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_A44	| 408FBA76
    cmpiw #131,%d0	| 408FBA7A
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_AB0	| 408FBA7E
    cmpiw #9,%d0	| 408FBA82
    jbhi DECL_DRVR_Display_Video_Apple_V8_Status_71A	| 408FBA86
    movew %pc@(DECL_DRVR_Display_Video_Apple_V8_Status_706,%d0:w:2),%d0	| 408FBA88
    jmp %pc@(DECL_DRVR_Display_Video_Apple_V8_Status_706,%d0:w)	| 408FBA8C
DECL_DRVR_Display_Video_Apple_V8_Status_706:/* Control table by csCode: 0 Reset, 1 KillIO, 2 SetMode, 3 SetEntries, 4 SetGamma, 5 GrayPage, 6 SetGray, 7 SetInterrupt, 8 DirectSetEntries, 9 SetDefaultMode */
    orib #24,%a2@-	| 408FBA90
    .byte   0x00, 0x48, 0x01, 0x40, 0x03, 0x44, 0x04, 0x26, 0x04, 0x4E, 0x04, 0x6C, 0x04, 0xEE, 0x04, 0xFC	| 408FBA94
DECL_DRVR_Display_Video_Apple_V8_Status_71A:/* controlErr (-17) */
    moveq #-17,%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0_2

DECL_DRVR_Display_Video_Apple_DAFB_3C0:/* noErr */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_DAFB_3C0_2:/* common exit: registers back, IODone. After it: csCode 0 Reset (mode 128); csCode 2 SetMode: valid mode, page 0, nothing if unchanged; the gamma table's three channels */
    moveml %sp@+,%a0-%a1
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_128
    movew #128,%a2@	| 408FBAB2
    movew #128,%a3@(36)
    moveq #0,%d1
    moveq #0,%d0
    movew %d0,%a2@(6)
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138
    movel %a3@(4),%a2@(8)
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0
    movew %a2@,%d1
    bsrw DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4
    bnes DECL_DRVR_Display_Video_Apple_V8_Status_71A
    tstw %a2@(6)
    bnes DECL_DRVR_Display_Video_Apple_V8_Status_71A
    movew %a2@,%d2
    cmpw %a3@(36),%d2
    beqw DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A
    movew %d2,%a3@(36)
    moveml %d5-%d6/%a4-%fp,%sp@-
    moveal %a3@(12),%a0
    lea %a0@(12),%a4
    addaw %a0@(4),%a4
    moveal %a4,%a5
    moveal %a4,%fp
    cmpiw #1,%a0@(6)
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_7A
    movew %a0@(10),%d2
    movew %a0@(8),%d0
    addqw #7,%d2
    lsrw #3,%d2
    muluw %d2,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_7A:/* 32-bit addressing; black entries for the channels of a monochrome monitor (register +288 bits 4 and 5) */
    movew %a0@(8),%d3
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    movew %a3@(32),%d5
    moveq #0,%d6
    btst #13,%d5
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_A8
    moveal %a3@(24),%a0
    movel %a0@(288),%d0
    btst #4,%d0
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_A8
    btst #5,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_A8
    bset #13,%d6
DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_A8:/* blank the color table during vertical blanking, RAMDAC index 0 */
    moveal %a3@(20),%a0
    clrl %a0@(512)
    lea %a0@(531),%a0
    movew %sr,%sp@-
    bsrw DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84
    movew %d3,%d0
    subqw #1,%d0
    lsrw #1,%d3
DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_C0:/* each entry: the middle gamma value */
    btst #13,%d6
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_D4
    clrb %a0@
    moveb %a4@(0x0,%d3:w),%a0@
    clrb %a0@
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_C0
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_F0
DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_D4:/* mono flag only: red and green 0 */
    btst #13,%d5
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_E0
    clrb %a0@
    clrb %a0@
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_E8
DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_E0:/* red and green */
    moveb %a4@(0x0,%d3:w),%a0@
    moveb %a5@(0x0,%d3:w),%a0@
DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_E8:/* blue; next */
    moveb %fp@(0x0,%d3:w),%a0@
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_C0
DECL_DRVR_Display_Video_Apple_DAFB_3C0_2_F0:/* program the mode; 16 bits and up: flags bit 10 */
    movew %sp@+,%sr
    moveb %sp@+,%d0
    _SwapMMUMode
    .short  0x4CDF	| 408FBBA0
    moveq #96,%d0
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268
    movew %a2@,%a3@(36)
    cmpiw #132,%a3@(36)
    jblt DECL_DRVR_Display_Video_Apple_DAFB_3C0_114
    bset #10,%a3@(32)
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A
DECL_DRVR_Display_Video_Apple_DAFB_3C0_114:/* indexed: clear it */
    bclr #10,%a3@(32)
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A:/* the new base; return it. After it: csCode 3 SetEntries (not in direct modes) */
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138
    movel %a3@(4),%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0
    btst #10,%a3@(32)
    bnew DECL_DRVR_Display_Video_Apple_V8_Status_71A
    tstl %a2@
    beqw DECL_DRVR_Display_Video_Apple_V8_Status_71A
    moveml %d4-%d7/%a1/%a4-%fp,%sp@-
    movew %a3@(32),%d5
    cmpiw #-1,%a2@(4)
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_32
    bset #12,%d5
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_32:/* the gamma table's three channels; data width */
    moveal %a3@(12),%a0
    movew %a0@(4),%d0
    lea %a0@(0xc,%d0:w),%a4
    moveal %a4,%a5
    moveal %a4,%fp
    movew %a0@(10),%d7
    cmpiw #1,%a0@(6)
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_60
    movew %a0@(8),%d0
    movew %d7,%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %d1,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_60:/* the mode's depth table */
    movew %a3@(36),%d1
    subiw #128,%d1
    btst #9,%d5
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_70
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_76
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_70:/* with 16-bit depth */
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_28B),%a0
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_7A
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_76:/* without */
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_286),%a0
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_7A:/* count must fit; start -1 or valid; the table address */
    moveq #0,%d6
    moveb %a0@(0x0,%d1:w),%d6
    movew %a2@(6),%d4
    cmpw %d6,%d4
    bhiw DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_20A
    movew %a2@(4),%d0
    addqw #1,%d0
    bmiw DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_20A
    movel %a2@,%d0
    _StripAddress
    moveal %d0,%a1
    movew %d4,%d1
    addqw #1,%d4
    moveq #0,%d6
    btst #9,%d5
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_A8
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_D4
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_A8:/* 16-bit mode, no +41: entries are indexed sequentially */
    movew %a3@(36),%d0
    cmpiw #132,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_D4
    tstb %a3@(41)
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_D4
    bset #12,%d6
    bclr #12,%d5
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_E2
    movew %d1,%d2
    addw %a2@(4),%d2
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_C8:/* loop: fill in value (the entry numbers) */
    movew %d2,%a1@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_C8
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_E2
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_D4:/* stack space: 3 bytes per entry, else 4 */
    addqw #1,%d4
    btst #12,%d5
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_E2
    muluw #3,%d4
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_E4
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_E2:/* 4 bytes per entry */
    aslw #2,%d4
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_E4:/* on the stack; a mono flag from the registers (+288 bits 4, 5) */
    subaw %d4,%sp
    btst #13,%d5
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_10E
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    moveal %a3@(24),%a0
    movel %a0@(288),%d0
    btst #4,%d0
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_10A
    btst #5,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_10A
    bset #13,%d6
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_10A:/* mode back */
    moveb %sp@+,%d0
    _SwapMMUMode
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_10E:/* translate each entry into the buffer */
    moveal %sp,%a0
    movew %a2@(6),%d3
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_114:/* the index (expanded for 16-bit modes) */
    movew %a1@+,%d1
    btst #12,%d5
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_128
    btst #12,%d6
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_126
    bsrw DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138_6C
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_126:/* store it */
    moveb %d1,%a0@+
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_128:/* R, G, B; luminance mapping (flags bit 15, not direct): weights 19660, 38666, 7209 (0.30, 0.59, 0.11) */
    movew %a1@+,%d0
    movew %a1@+,%d1
    movew %a1@+,%d2
    tstw %d5
    bpls DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_152
    btst #10,%d5
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_152
    muluw #19660,%d0
    muluw #-26870,%d1
    muluw #7209,%d2
    addl %d1,%d0
    addl %d2,%d0
    bfextu %d0,0,%d7,%d0
    movew %d0,%d1
    movew %d0,%d2
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_15E
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_152:/* else each channel: its top bits */
    bfextu %d0,16,%d7,%d0
    bfextu %d1,16,%d7,%d1
    bfextu %d2,16,%d7,%d2
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_15E:/* through the gamma table: mono flag: green only */
    btst #13,%d6
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_172
    clrb %a0@+
    moveb %a4@(0x0,%d0:w),%a0@+
    clrb %a0@+
    dbf %d3,DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_114
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_18E
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_172:/* mono: red and green 0 */
    btst #13,%d5
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_17E
    clrb %a0@+
    clrb %a0@+
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_186
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_17E:/* red and green */
    moveb %a4@(0x0,%d0:w),%a0@+
    moveb %a5@(0x0,%d1:w),%a0@+
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_186:/* blue; next */
    moveb %fp@(0x0,%d2:w),%a0@+
    dbf %d3,DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_114
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_18E:/* write them to the RAMDAC during blanking, in 32-bit mode */
    movew %a2@(6),%d3
    moveal %a3@(20),%a4
    lea %a4@(528),%a4
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    lea %sp@(2),%a0
    moveq #0,%d1
    movew %sr,%sp@-
    bsrw DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84
    btst #12,%d5
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1D6
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1B2:/* random access: index, then R, G, B */
    moveb %a0@+,%d1
    movel %d1,%a4@(-16)
    moveb %a0@+,%a4@(3)
    moveb %a0@+,%a4@(3)
    moveb %a0@+,%a4@(3)
    tstb %a3@(41)
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1D0
    tstb @(VIA,%za0)@(0)	| 408FBD8C
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1D0:/* next */
    dbf %d3,DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1B2
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1FA
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1D6:/* sequential: start index once */
    movew %a2@(4),%d1
    movel %d1,%a4@(-16)
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1DE:/* R, G, B */
    moveb %a0@+,%a4@(3)
    moveb %a0@+,%a4@(3)
    moveb %a0@+,%a4@(3)
    tstb %a3@(41)
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1F6
    tstb @(VIA,%za0)@(0)	| 408FBDB2
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1F6:/* next */
    dbf %d3,DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1DE
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_1FA:/* restore; return noErr */
    movew %sp@+,%sr
    moveb %sp@+,%d0
    _SwapMMUMode
    addaw %d4,%sp
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    braw DECL_DRVR_Display_Video_Apple_DAFB_3C0
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_20A:/* bad parameters: controlErr. After it: csCode 4 SetGamma: nil = linear; form 0, 1 or 3 channels of 8 bits, for this monitor (or any: -1) */
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    braw DECL_DRVR_Display_Video_Apple_V8_Status_71A
    movel %a2@,%d0
    beqw DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_2BC
    moveal %d0,%a2
    tstw %a2@
    bnew DECL_DRVR_Display_Video_Apple_V8_Status_71A
    tstw %a2@(2)
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_246
    cmpiw #28,%a2@(2)
    bnew DECL_DRVR_Display_Video_Apple_V8_Status_71A
    tstw %a2@(4)
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_246
    movew %a2@(12),%d0
    cmpw %a3@(38),%d0
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_246
    addqw #1,%d0
    bnew DECL_DRVR_Display_Video_Apple_V8_Status_71A
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_246:/* same shape as the current one? else a new pointer */
    moveal %a3@(12),%a0
    movew %a2@(4),%d0
    cmpw %a0@(4),%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_26A
    movew %a2@(6),%d0
    cmpw %a0@(6),%d0
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_29A
    bgts DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_26A
    moveal %a3@(16),%a0
    _DisposPtr
    clrl %a3@(16)
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_26A:/* the size; new pointer; dispose of the old */
    moveq #0,%d0
    movew %a2@(8),%d0
    muluw %a2@(6),%d0
    addw %a2@(4),%d0
    addiw #12,%d0
    .short  0xA51E	| 408FBE3E _NewPtr (flags 0x0500)
    bnew DECL_DRVR_Display_Video_Apple_V8_Status_71A
    movel %a3@(16),%d0
    movel %a0,%a3@(12)
    tstl %d0
    beqs DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_29A
    moveal %d0,%a0
    _DisposPtr
    moveal %a3@(12),%a0
    movel %a0,%a3@(16)
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_29A:/* copy the header and data */
    movew %a2@(6),%d0
    movew %a2@(4),%d1
    movew %a2@(8),%d2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    muluw %d0,%d2
    addw %d1,%d2
    subqw #1,%d2
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_2B2:/* loop */
    moveb %a2@+,%d0
    moveb %d0,%a0@+
    dbf %d2,DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_2B2
    bras DECL_DRVR_Display_Video_Apple_DAFB_3C0_3F2_C
DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A_2BC:/* nil: rewrite the current table as a linear ramp */
    moveal %a3@(12),%a0
    movew %a0@(4),%d0
    movew %a0@(6),%d2
    subqw #1,%d2
    movew %a0@(8),%d3
    subqw #1,%d3
    lea %a0@(12),%a0
    addaw %d0,%a0
DECL_DRVR_Display_Video_Apple_DAFB_3C0_3F0:/* per channel */
    movew %d3,%d0
DECL_DRVR_Display_Video_Apple_DAFB_3C0_3F2:/* loop: value = index, complemented */
    moveb %d0,%a0@
    notb %a0@+
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_3C0_3F2
    dbf %d2,DECL_DRVR_Display_Video_Apple_DAFB_3C0_3F0
DECL_DRVR_Display_Video_Apple_DAFB_3C0_3F2_C:/* direct modes: reload the gamma ramp */
    btst #10,%a3@(32)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_3C0_40A
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6
DECL_DRVR_Display_Video_Apple_DAFB_3C0_40A:/* return. After it: csCode 5 GrayPage: page 0, gray the screen */
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0
    movew %a3@(36),%d1	| 408FBEB6
    bsrw DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4
    bnew DECL_DRVR_Display_Video_Apple_V8_Status_71A
    movew %a2@(6),%d0
    bnew DECL_DRVR_Display_Video_Apple_V8_Status_71A
    bsrw DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C
    btst #10,%a3@(32)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_3C0_432
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6
DECL_DRVR_Display_Video_Apple_DAFB_3C0_432:/* return. After it: csCode 6 SetGray: always on for monochrome */
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0
    btst #13,%a3@(32)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_3C0_442
    moveb #1,%a2@
DECL_DRVR_Display_Video_Apple_DAFB_3C0_442:/* store it in flags bit 15; after it csCode 7 SetInterrupt: flags bit 14, install or remove the handler */
    moveq #0,%d1
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_80A
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0

/* subroutine (11 instructions): calls DECL_DRVR_Display_Video_Apple_DAFB_80A, DECL_DRVR_Display_Video_Apple_DAFB_84E, DECL_DRVR_Display_Video_Apple_DAFB_82A (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_80A:/* flags bit (d1) = the parameter byte */
    moveb %a2@,%d0
    bfins %d0,%a3@(32),%d1,1
    rts
    moveq #1,%d1
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_80A
    jbne DECL_DRVR_Display_Video_Apple_DAFB_80A_1A
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_84E
    jbne DECL_DRVR_Display_Video_Apple_V8_Status_71A
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0
DECL_DRVR_Display_Video_Apple_DAFB_80A_1A:/* disable */
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_82A
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0

/* subroutine (14 instructions): traps SwapMMUMode, SIntRemove; calls DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84 (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_82A:/* disable the VBL interrupt (register +260 = 0), remove the slot interrupt */
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84
    moveal %a3@(24),%a0
    clrl %a0@(260)
    movew %sp@+,%sr
    moveb %sp@+,%d0
    _SwapMMUMode
    clrw %d0
    moveal %a3@(8),%a0
    _SIntRemove
    rts

/* subroutine (258 instructions): traps SIntInstall, SwapMMUMode, SlotManager, StripAddress, DisposPtr, DisposHandle; calls DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84, DECL_DRVR_Display_Video_Apple_DAFB_82A (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_84E:/* install the slot interrupt (priority 6), enable it (registers +280, +260) */
    moveal %a3@(8),%a0
    lea %pc@(DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_A6),%a2
    movew #6,%a0@(4)
    movel %a2,%a0@(8)
    movel %a3,%a0@(12)
    clrw %d0
    _SIntInstall
    jbne DECL_DRVR_Display_Video_Apple_DAFB_84E_46
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    moveal %a3@(24),%a0
    movel %a0@(352),%d0
    andil #4095,%d0
    lsrl #1,%d0
    addqw #1,%d0
    movel %d0,%a0@(280)
    movel #4,%a0@(260)
    moveb %sp@+,%d0
    _SwapMMUMode
    cmpw %d0,%d0
DECL_DRVR_Display_Video_Apple_DAFB_84E_46:/* return. After the rts: an entry that needs flags bit 10; then SetDefaultMode (csCode 9): the sResource must be type 3,1,1,28 */
    rts
    btst #10,%a3@(32)	| 408FBF7E
    beqw DECL_DRVR_Display_Video_Apple_V8_Status_71A
    braw DECL_DRVR_Display_Video_Apple_DAFB_3C0_11A+0x18
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0
    _SlotManager
    moveb %a2@,%a0@(50)
    clrl %a0@(24)
    orib #3,%a0@(27)
    moveq #11,%d0
    _SlotManager
    bnes DECL_DRVR_Display_Video_Apple_DAFB_84E_46_94
    movew %a0@(40),%d0
    cmpiw #3,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_84E_46_94
    movew %a0@(42),%d0
    cmpiw #1,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_84E_46_94
    movew %a0@(44),%d0
    cmpiw #1,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_84E_46_94
    movew %a0@(46),%d0
    cmpiw #28,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_84E_46_94
    btst #10,%a3@(32)
    beqs DECL_DRVR_Display_Video_Apple_DAFB_84E_46_80
    moveb %a2@,%d0
    cmpib #0xd8,%d0
    blts DECL_DRVR_Display_Video_Apple_DAFB_84E_46_80
    cmpib #0xdf,%d0
    bgts DECL_DRVR_Display_Video_Apple_DAFB_84E_46_80
    moveb #0x83,%sp@(2)
DECL_DRVR_Display_Video_Apple_DAFB_84E_46_80:/* new default in parameter RAM (mode 0x83 for sResources 0xD8..0xDF when flags bit 10 is set) */
    moveb %a2@,%sp@(3)	| 408FBFFC
    movel %sp,%a0@(4)
    moveq #18,%d0
    _SlotManager
    lea %sp@(64),%sp
    braw DECL_DRVR_Display_Video_Apple_DAFB_3C0
DECL_DRVR_Display_Video_Apple_DAFB_84E_46_94:/* not a usable sResource: error return */
    lea %sp@(64),%sp	| 408FC010
    braw DECL_DRVR_Display_Video_Apple_V8_Status_71A
DECL_DRVR_Display_Video_Apple_DAFB_930:/* private csCode 128: PRAM bit 0, flags bit 8, register +12 bit 9 (or VIA2 +0x1E00 bit 7) */
    subaw #56,%sp	| 408FC018
    moveal %sp,%a0	| 408FC01C
    moveb %a1@(40),%a0@(49)	| 408FC01E
    clrb %a0@(51)	| 408FC024
    subqw #8,%sp	| 408FC028
    movel %sp,%a0@	| 408FC02A
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */	| 408FC02C
    _SlotManager	| 408FC02E 408FC02E A-line trap
    tstb %a2@	| 408FC030
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_964	| 408FC032
    btst #8,%a3@(32)	| 408FC034
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_9C4	| 408FC03A
    bclr #8,%a3@(32)	| 408FC03C
    bclr #0,%sp@(6)	| 408FC042
    moveq #0,%d1	| 408FC048
    jbra DECL_DRVR_Display_Video_Apple_DAFB_97A	| 408FC04A
DECL_DRVR_Display_Video_Apple_DAFB_964:/* set it */
    btst #8,%a3@(32)	| 408FC04C
    jbne DECL_DRVR_Display_Video_Apple_DAFB_9C4	| 408FC052
    bset #8,%a3@(32)	| 408FC054
    bset #0,%sp@(6)	| 408FC05A
    moveq #1,%d1	| 408FC060
DECL_DRVR_Display_Video_Apple_DAFB_97A:/* write PRAM; update the hardware at blanking */
    movel %sp,%a0@(4)	| 408FC062
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */	| 408FC066
    _SlotManager	| 408FC068 408FC068 A-line trap
    moveq #1,%d0	| 408FC06A
    _SwapMMUMode	| 408FC06C 408FC06C A-line trap
    moveb %d0,%sp@-	| 408FC06E
    movew %sr,%sp@-	| 408FC070
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84	| 408FC072
    movew %sp@+,%sr	| 408FC076
    tstb %a3@(33)	| 408FC078
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_9A8	| 408FC07C
    moveal %a3@(24),%a0	| 408FC07E
    movel %a0@(12),%d0	| 408FC082
    bfins %d1,%d0,22,1	| 408FC086
    movel %d0,%a0@(12)	| 408FC08A
    jbra DECL_DRVR_Display_Video_Apple_DAFB_9C0	| 408FC08E
DECL_DRVR_Display_Video_Apple_DAFB_9A8:/* VIA2 form */
    moveal ghost_VIA2,%a0	| 408FC090
    btst #0,%d1	| 408FC094
    jbne DECL_DRVR_Display_Video_Apple_DAFB_9BA	| 408FC098
    bclr #7,%a0@(7680)	| 408FC09A
    jbra DECL_DRVR_Display_Video_Apple_DAFB_9C0	| 408FC0A0
DECL_DRVR_Display_Video_Apple_DAFB_9BA:/* set */
    bset #7,%a0@(7680)	| 408FC0A2
DECL_DRVR_Display_Video_Apple_DAFB_9C0:/* mode back */
    moveb %sp@+,%d0	| 408FC0A8
    _SwapMMUMode	| 408FC0AA 408FC0AA A-line trap
DECL_DRVR_Display_Video_Apple_DAFB_9C4:/* return */
    lea %sp@(64),%sp	| 408FC0AC
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0	| 408FC0B0
DECL_DRVR_Display_Video_Apple_DAFB_9CC:/* private csCode 129: PRAM bit 2, only if PRAM bit 1 is set and the sensed value allows it */
    subaw #56,%sp	| 408FC0B4
    moveal %sp,%a0	| 408FC0B8
    moveb %a1@(40),%a0@(49)	| 408FC0BA
    clrb %a0@(51)	| 408FC0C0
    subqw #8,%sp	| 408FC0C4
    movel %sp,%a0@	| 408FC0C6
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */	| 408FC0C8
    _SlotManager	| 408FC0CA 408FC0CA A-line trap
    btst #1,%sp@(6)	| 408FC0CC
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_A3C	| 408FC0D2
    moveq #1,%d0	| 408FC0D4
    _SwapMMUMode	| 408FC0D6 408FC0D6 A-line trap
    moveb %d0,%d1	| 408FC0D8
    btst #11,%a3@(32)	| 408FC0DA
    jbne DECL_DRVR_Display_Video_Apple_DAFB_A12	| 408FC0E0
    moveal %a3@(24),%a3	| 408FC0E2
    movel %a3@(44),%d0	| 408FC0E6
    andiw #4095,%d0	| 408FC0EA
    moveq #9,%d2	| 408FC0EE
    lsrw %d2,%d0	| 408FC0F0
    cmpib #2,%d0	| 408FC0F2
    jblt DECL_DRVR_Display_Video_Apple_DAFB_A12	| 408FC0F6
    jbra DECL_DRVR_Display_Video_Apple_DAFB_A30	| 408FC0F8
DECL_DRVR_Display_Video_Apple_DAFB_A12:/* the parameter: clear or set PRAM bit 2 */
    tstb %a2@	| 408FC0FA
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_A20	| 408FC0FC
    bclr #2,%sp@(6)	| 408FC0FE
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_A30	| 408FC104
    jbra DECL_DRVR_Display_Video_Apple_DAFB_A28	| 408FC106
DECL_DRVR_Display_Video_Apple_DAFB_A20:/* set it */
    bset #2,%sp@(6)	| 408FC108
    jbne DECL_DRVR_Display_Video_Apple_DAFB_A30	| 408FC10E
DECL_DRVR_Display_Video_Apple_DAFB_A28:/* write PRAM */
    movel %sp,%a0@(4)	| 408FC110
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */	| 408FC114
    _SlotManager	| 408FC116 408FC116 A-line trap
DECL_DRVR_Display_Video_Apple_DAFB_A30:/* mode back; return */
    moveb %d1,%d0	| 408FC118
    _SwapMMUMode	| 408FC11A 408FC11A A-line trap
    lea %sp@(64),%sp	| 408FC11C
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0	| 408FC120
DECL_DRVR_Display_Video_Apple_DAFB_A3C:/* controlErr */
    lea %sp@(64),%sp	| 408FC124
    jbra DECL_DRVR_Display_Video_Apple_V8_Status_71A	| 408FC128
DECL_DRVR_Display_Video_Apple_DAFB_A44:/* private csCode 130: PRAM bit 3, +35, register +24 */
    subaw #56,%sp	| 408FC12C
    moveal %sp,%a0	| 408FC130
    moveb %a1@(40),%a0@(49)	| 408FC132
    clrb %a0@(51)	| 408FC138
    subqw #8,%sp	| 408FC13C
    movel %sp,%a0@	| 408FC13E
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */	| 408FC140
    _SlotManager	| 408FC142 408FC142 A-line trap
    moveq #1,%d0	| 408FC144
    _SwapMMUMode	| 408FC146 408FC146 A-line trap
    moveb %d0,%d1	| 408FC148
    moveal %a3@(24),%a1	| 408FC14A
    tstb %a2@	| 408FC14E
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_A76	| 408FC150
    clrb %a3@(35)	| 408FC152
    bclr #3,%sp@(6)	| 408FC156
    jbra DECL_DRVR_Display_Video_Apple_DAFB_A82	| 408FC15C
DECL_DRVR_Display_Video_Apple_DAFB_A76:/* set it */
    moveb #1,%a3@(35)	| 408FC15E
    bset #3,%sp@(6)	| 408FC164
DECL_DRVR_Display_Video_Apple_DAFB_A82:/* write PRAM; register +24 = 1 if register +16 bit 0 is clear and +35 is set */
    movel %sp,%a0@(4)	| 408FC16A
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */	| 408FC16E
    _SlotManager	| 408FC170 408FC170 A-line trap
    lea %sp@(64),%sp	| 408FC172
    movel %a1@(16),%d0	| 408FC176
    bfextu %d0,31,1,%d0	| 408FC17A
    jbne DECL_DRVR_Display_Video_Apple_DAFB_AA2	| 408FC17E
    tstb %a3@(35)	| 408FC180
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_AA2	| 408FC184
    moveq #1,%d0	| 408FC186
    jbra DECL_DRVR_Display_Video_Apple_DAFB_AA4	| 408FC188
DECL_DRVR_Display_Video_Apple_DAFB_AA2:/* 0 */
    moveq #0,%d0	| 408FC18A
DECL_DRVR_Display_Video_Apple_DAFB_AA4:/* store; return */
    movel %d0,%a1@(24)	| 408FC18C
    moveb %d1,%d0	| 408FC190
    _SwapMMUMode	| 408FC192 408FC192 A-line trap
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0	| 408FC194
DECL_DRVR_Display_Video_Apple_DAFB_AB0:/* private csCode 131: a monitor sense code (d0 = family byte, a2@ = code); PRAM byte 7 */
    subaw #56,%sp	| 408FC198
    moveal %sp,%a0	| 408FC19C
    moveb %a1@(40),%a0@(49)	| 408FC19E
    clrb %a0@(51)	| 408FC1A4
    subqw #8,%sp	| 408FC1A8
    movel %sp,%a0@	| 408FC1AA
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */	| 408FC1AC
    _SlotManager	| 408FC1AE 408FC1AE A-line trap
    moveb %a2@(1),%d0	| 408FC1B0
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_B06	| 408FC1B4
    cmpib #3,%d0	| 408FC1B6
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_AE4	| 408FC1BA
    cmpib #6,%d0	| 408FC1BC
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_AF8	| 408FC1C0
    cmpib #7,%d0	| 408FC1C2
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_B06	| 408FC1C6
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B92	| 408FC1C8
DECL_DRVR_Display_Video_Apple_DAFB_AE4:/* family 3: codes 49, 52 */
    moveb %a2@,%d1	| 408FC1CC
    cmpib #49,%d1	| 408FC1CE
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC1D2
    cmpib #52,%d1	| 408FC1D6
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC1DA
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B92	| 408FC1DC
DECL_DRVR_Display_Video_Apple_DAFB_AF8:/* family 6: code 3 */
    cmpib #3,%a2@	| 408FC1E0
    jbne DECL_DRVR_Display_Video_Apple_DAFB_B92	| 408FC1E4
    moveb #6,%d1	| 408FC1E8
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC1EC
DECL_DRVR_Display_Video_Apple_DAFB_B06:/* family 0 or 7: code in the list; codes 7, 63: clear */
    moveb %a2@,%d1	| 408FC1EE
    cmpib #7,%d1	| 408FC1F0
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_B7E	| 408FC1F4
    cmpib #63,%d1	| 408FC1F6
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_B7E	| 408FC1FA
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_2BE),%a1	| 408FC1FC
    movew %a1@+,%d0	| 408FC200
DECL_DRVR_Display_Video_Apple_DAFB_B1A:/* search the list */
    moveb %a1@+,%d1	| 408FC202
    cmpb %a2@,%d1	| 408FC204
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_B26	| 408FC206
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_B1A	| 408FC208
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B92	| 408FC20C
DECL_DRVR_Display_Video_Apple_DAFB_B26:/* map to a monitor number: 23 to 8, 48 to 9, 0 to 9, 20 to 4, 45 to 10, 58 to 11 */
    tstb %a2@(1)	| 408FC20E
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC212
    cmpib #23,%d1	| 408FC214
    jbne DECL_DRVR_Display_Video_Apple_DAFB_B38	| 408FC218
    moveb #8,%d1	| 408FC21A
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC21E
DECL_DRVR_Display_Video_Apple_DAFB_B38:/* 48 */
    cmpib #48,%d1	| 408FC220
    jbne DECL_DRVR_Display_Video_Apple_DAFB_B44	| 408FC224
    moveb #9,%d1	| 408FC226
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC22A
DECL_DRVR_Display_Video_Apple_DAFB_B44:/* 0 */
    cmpib #0,%d1	| 408FC22C
    jbne DECL_DRVR_Display_Video_Apple_DAFB_B50	| 408FC230
    moveb #9,%d1	| 408FC232
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC236
DECL_DRVR_Display_Video_Apple_DAFB_B50:/* 20 */
    cmpib #20,%d1	| 408FC238
    jbne DECL_DRVR_Display_Video_Apple_DAFB_B5C	| 408FC23C
    moveb #4,%d1	| 408FC23E
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC242
DECL_DRVR_Display_Video_Apple_DAFB_B5C:/* 45 */
    cmpib #45,%d1	| 408FC244
    jbne DECL_DRVR_Display_Video_Apple_DAFB_B68	| 408FC248
    moveb #10,%d1	| 408FC24A
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC24E
DECL_DRVR_Display_Video_Apple_DAFB_B68:/* 58 */
    cmpib #58,%d1	| 408FC250
    jbne DECL_DRVR_Display_Video_Apple_DAFB_B72	| 408FC254
    moveb #11,%d1	| 408FC256
DECL_DRVR_Display_Video_Apple_DAFB_B72:/* PRAM byte 7 = number + 0x40 */
    moveb %d1,%sp@(7)	| 408FC25A
    orib #64,%sp@(7)	| 408FC25E
    jbra DECL_DRVR_Display_Video_Apple_DAFB_B82	| 408FC264
DECL_DRVR_Display_Video_Apple_DAFB_B7E:/* clear */
    clrb %sp@(7)	| 408FC266
DECL_DRVR_Display_Video_Apple_DAFB_B82:/* write PRAM; return */
    movel %sp,%a0@(4)	| 408FC26A
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */	| 408FC26E
    _SlotManager	| 408FC270 408FC270 A-line trap
    lea %sp@(64),%sp	| 408FC272
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0	| 408FC276
DECL_DRVR_Display_Video_Apple_DAFB_B92:/* controlErr. After it: Close: interrupts off, registers +288 bit 11 cleared, +256 = 4081, dispose of everything */
    lea %sp@(64),%sp	| 408FC27A
    jbra DECL_DRVR_Display_Video_Apple_V8_Status_71A	| 408FC27E
    moveal %a1@(20),%a3	| 408FC282
    movel %a3@,%d0	| 408FC286
    _StripAddress	| 408FC288 408FC288 A-line trap
    moveal %d0,%a3	| 408FC28A
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_82A	| 408FC28C
    moveq #1,%d0	| 408FC290
    _SwapMMUMode	| 408FC292 408FC292 A-line trap
    moveal %a3@(24),%a2	| 408FC294
    andil #-2049,%a2@(288)	| 408FC298
    movel #4081,%a2@(256)	| 408FC2A0
    _SwapMMUMode	| 408FC2A8 408FC2A8 A-line trap
    moveal %a3@(8),%a0	| 408FC2AA
    _DisposPtr	| 408FC2AE 408FC2AE A-line trap
    moveal %a3@(16),%a0	| 408FC2B0
    _DisposPtr	| 408FC2B4 408FC2B4 A-line trap
    moveal %a3@(28),%a0	| 408FC2B6
    _DisposPtr	| 408FC2BA 408FC2BA A-line trap
    moveal %a1@(20),%a0	| 408FC2BC
    _DisposHandle	| 408FC2C0 408FC2C0 A-line trap
    moveq #0,%d0	| 408FC2C2
    rts	| 408FC2C4

/* Status: find csCode in the status table and call its routine (out of range: StatusBadCode) (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_Status:/* Status: csCodes 128..131 private, 0..9 through the table */
    moveml %a0-%a1,%sp@-
    moveal %a0@(28),%a2
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    movew %a0@(26),%d0
    cmpiw #128,%d0
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_24
    cmpiw #129,%d0
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_3A
    cmpiw #130,%d0
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_7A
    cmpiw #131,%d0
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E
    cmpiw #9,%d0
    jbhi DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode
    movew %pc@(DECL_DRVR_Display_Video_Apple_DAFB_StatusTable,%d0:w:2),%d0
    jmp %pc@(DECL_DRVR_Display_Video_Apple_DAFB_StatusTable,%d0:w)

/* status table: routine offsets by csCode (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_StatusTable:/* Status table by csCode */
    .short  DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC30A
    .short  DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC30C
    .short  DECL_DRVR_Display_Video_Apple_DAFB_GetMode-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC30E
    .short  DECL_DRVR_Display_Video_Apple_DAFB_GetEntries-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC310
    .short  DECL_DRVR_Display_Video_Apple_DAFB_GetPages-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC312
    .short  DECL_DRVR_Display_Video_Apple_DAFB_GetBaseAddr-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC314
    .short  DECL_DRVR_Display_Video_Apple_DAFB_GetGray-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC316
    .short  DECL_DRVR_Display_Video_Apple_DAFB_GetInterrupt-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC318
    .short  DECL_DRVR_Display_Video_Apple_DAFB_GetGamma-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC31A
    .short  DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode-DECL_DRVR_Display_Video_Apple_DAFB_StatusTable	| 408FC31C

/* unknown status csCode: statusErr (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode:/* statusErr (-18) */
    moveq #-18,%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_6
DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4:/* noErr */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_6:/* registers back; IODone */
    moveml %sp@+,%a0-%a1
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_128

/* Status csCode 2, cscGetMode: current mode, page and base address (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_GetMode:/* csCode 2: mode, page 0, base address */
    movew %a3@(36),%a2@
    clrw %a2@(6)
    movel %a3@(4),%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4

/* Status csCode 3, cscGetEntries: read colour table entries (from the CLUT) (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_GetEntries:/* csCode 3: read the RAMDAC; nil table: error */
    moveml %d4-%d6,%sp@-
    tstl %sp@-
    movel %a2@,%d0
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_C4
    _StripAddress
    movel %d0,%sp@
    movew %a3@(36),%d1
    subiw #128,%d1
    movel %d1,%d6
    movew %a3@(32),%d5
    btst #9,%d5
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_2A
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_286),%a0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_3E
DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_2A:/* with 16-bit depth; 16-bit mode: sequential entries */
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_28B),%a0
    cmpiw #4,%d6
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_3E
    tstb %a3@(41)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_3E
    bset #12,%d5
DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_3E:/* count check; start -1: entries already numbered, else number them */
    moveq #0,%d3
    moveb %a0@(0x0,%d1:w),%d3
    movew %a2@(6),%d4
    jbmi DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_C4
    cmpw %d3,%d4
    jbhi DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_C4
    movew %d4,%d2
    cmpiw #-1,%a2@(4)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_6A
    movew %d4,%d1
    addw %a2@(4),%d2
    moveal %sp@,%a0
DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_60:/* loop: entry numbers */
    movew %d2,%a0@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_60
DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_6A:/* 32-bit mode; RAMDAC data port; wait for blanking */
    moveq #1,%d0
    _SwapMMUMode
    moveal %sp@+,%a0
    moveal %a3@(20),%a2
    addaw #528,%a2
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84
DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_7E:/* each entry: index */
    movew %a0@,%d1
    cmpw %d3,%d1
    jbhi DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_B2
    btst #12,%d5
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_8E
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138_6C
DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_8E:/* read R, G, B (one byte each, stored in both bytes of the word) */
    movel %d1,%a2@(-16)
    nop
    movel %a2@,%d1
    moveb %d1,%a0@(2)
    moveb %d1,%a0@(3)
    movel %a2@,%d1
    moveb %d1,%a0@(4)
    moveb %d1,%a0@(5)
    movel %a2@,%d1
    moveb %d1,%a0@(6)
    moveb %d1,%a0@(7)
DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_B2:/* next; restore */
    addqw #8,%a0
    dbf %d4,DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_7E
    movew %sp@+,%sr
    _SwapMMUMode
    moveml %sp@+,%d4-%d6
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_DAFB_GetEntries_C4:/* bad parameters */
    tstl %sp@+
    moveml %sp@+,%d4-%d6
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode

/* Status csCode 4, cscGetPages: number of video pages for a mode (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_GetPages:/* csCode 4: one page per valid mode */
    movew %a2@,%d1
    movew %d1,%d2
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4
    jbne DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode
    movew #1,%a2@(6)
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4

/* Status csCode 5, cscGetBaseAddr: base address of a page (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_GetBaseAddr:/* csCode 5: page 0's base */
    tstw %a2@(6)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode
    movel %a3@(4),%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4

/* Status csCode 6, cscGetGray: whether luminance mapping (gray) is on (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_GetGray:/* csCode 6: flags bit 15 */
    moveq #0,%d1
DECL_DRVR_Display_Video_Apple_DAFB_GetGray_2:/* read flag bit d1 */
    bfextu %a3@(32),%d1,1,%d0
    moveb %d0,%a2@
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4

/* Status csCode 7, cscGetInterrupt: whether the VBL interrupt is enabled (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_GetInterrupt:/* csCode 7: flags bit 14 */
    moveq #1,%d1
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetGray_2

/* Status csCode 8, cscGetGamma: the current gamma table (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_GetGamma:/* csCode 8: the gamma table */
    movel %a3@(12),%a2@
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4

/* Status csCode 9, cscGetDefaultMode: the default mode (from slot PRAM) (Display Video Apple DAFB). */
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode:/* csCode 9: PRAM byte 3 */
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
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_24:/* private 128: 1 if flags bit 8 is clear */
    btst #8,%a3@(32)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_34
    moveb #1,%a2@
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_34:/* 0 */
    clrb %a2@
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_3A:/* private 129: PRAM bit 1 set: 1 if PRAM bit 2 is clear */
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    btst #1,%sp@(6)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_72
    btst #2,%sp@(6)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_68
    moveb #1,%a2@
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6A
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_68:/* 0 */
    clrb %a2@
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6A:/* return */
    lea %sp@(64),%sp
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_72:/* PRAM bit 1 clear: statusErr */
    lea %sp@(64),%sp
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_7A:/* private 130: 1 if register +24 bit 0 is clear */
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    moveal %a3@(24),%a0
    movel %a0@(24),%d0
    btst #0,%d0
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_94
    moveb #1,%a2@
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_96
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_94:/* 0 */
    clrb %a2@
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_96:/* mode back; return */
    moveb %sp@+,%d0
    _SwapMMUMode
    jbra DECL_DRVR_Display_Video_Apple_DAFB_3C0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E:/* private 131: PRAM byte 7 back to a sense code and family: number to code 8 to 23, 9 to 48, 10 to 45, 11 to 58 */
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    .short  0x422A	| 408FC502
    .short  0x0001, 0x102F	| orib #47,%d1
    .short  0x0007, 0x0200	| orib #0,%d7
    oriw #26118,%d0
    moveb #7,%a2@
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_120
    moveb %sp@(7),%d0
    andib #63,%d0
    cmpib #8,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_40
    moveb #23,%d0
    bras DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_7A
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_40:/* 9 */
    cmpib #9,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_4C
    moveb #48,%d0
    bras DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_7A
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_4C:/* 10 */
    cmpib #10,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_58
    moveb #45,%d0
    bras DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_7A
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_58:/* 11 */
    cmpib #11,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_64
    moveb #58,%d0
    bras DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_7A
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_64:/* 49 */
    cmpib #49,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_6C
    bras DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_6C_6	| 408FC554
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_6C:/* 52: family 3 */
    cmpib #52,%d0
    bnes DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_11E
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_6C_6:
    .byte   0x15, 0x7C	| 408FC55C
    orib #1,%d3
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_11E
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_9E_7A:/* family 7 */
    moveb #7,%a2@(1)	| 408FC564
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_11E:/* the code */
    moveb %d0,%a2@
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_120:/* return */
    lea %sp@(64),%sp
    jbra DECL_DRVR_Display_Video_Apple_DAFB_StatusBadCode_4

DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_128:/* immediate call (bit 9): rts; else JIODone */
    btst #9,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_128_A
    rts
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_128_A:/* JIODone */
    movel JIODone,%sp@-
    rts

/* subroutine (30 instructions): traps SlotManager, DisposPtr (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138:/* the base address of mode (+36): from the mode's sResource (Slot Manager): +0 + its offset into +4 */
    moveml %d0/%a0-%a1,%sp@-
    subaw #56,%sp
    moveal %sp,%a0
    clrb %a0@(49)
    clrb %a0@(50)
    clrb %a0@(51)
    clrb %a0@(48)
    movew #3,%a0@(40)
    movew #1,%a0@(42)
    movew #1,%a0@(44)
    movew #28,%a0@(46)
    clrl %a0@(24)
    bset #1,%a0@(27)
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */
    _SlotManager
    movew %a3@(36),%d0
    moveb %d0,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    moveb #1,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    moveal %a0@,%a0
    moveal %a3@,%a1
    addal %a0@,%a1
    movel %a1,%a3@(4)
    _DisposPtr
    lea %sp@(56),%sp
    moveml %sp@+,%d0/%a0-%a1
    rts

/* subroutine (8 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138_6C:/* expand index d1 for 16-bit: value (5 bits) to 8 bits by copying its top bits */
    movel %d0,%sp@-
    moveq #0,%d0
    movew %d1,%d0
    lslw #3,%d1
    lsrw #2,%d0
    orw %d0,%d1
    movel %sp@+,%d0
    rts

/* subroutine (45 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4:/* is mode d1 valid? (Z set; else d1 = -1, NE); mono monitors stop below 32-bit */
    moveml %d0/%d2/%a0,%sp@-
    subiw #128,%d1
    jblt DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_7C
    btst #13,%a3@(32)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_1A
    cmpiw #4,%d1
    jblt DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_1A
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_7C
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_1A:/* the highest mode from the timing block (+16, +17 by sResource bit 0) */
    moveal %a3@(28),%a0
    lea %a0@(16),%a0
    moveb %a3@(40),%d0
    btst #0,%d0
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_2E
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_32
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_2E:/* index 0 */
    moveq #0,%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_34
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_32:/* index 1 */
    moveq #1,%d0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_34:/* the limit, as an index; adjust for this board (+33, monitor 2, +41, flags bit 9) */
    moveb %d0,%d2
    moveb %a0@(0x0,%d0:w),%d0
    cmpib #0x80,%d0
    jblt DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_74
    subib #0x80,%d0
    tstb %a3@(33)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_5C
    cmpiw #2,%a3@(38)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_5C
    tstb %a3@(41)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_5C
    subqw #1,%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_74
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_5C:/* without 16-bit depth one less; two less for monitor 2 at index 0 */
    btst #9,%a3@(32)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_74
    subqw #1,%d0
    tstb %d2
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_74
    cmpiw #2,%a3@(38)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_74
    subqw #1,%d0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_74:/* compare */
    cmpw %d0,%d1
    jbgt DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_7C
    cmpw %d1,%d1
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_7E
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_7C:/* invalid */
    moveq #-1,%d1
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_7E:/* restore, return */
    moveml %sp@+,%d0/%d2/%a0
    rts

/* subroutine (18 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84:/* wait for vertical blanking: interrupts below level 3 are masked if needed; clear the flag (+268), poll bit 2 of +264 */
    movel %a0,%sp@-
    movel %d0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_9A
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_9A:/* clear the VBL flag */
    tstw %sp@+
    moveal %a3@(24),%a0
    clrl %a0@(268)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_A4:/* loop until blanking */
    movel %a0@(264),%d0
    btst #2,%d0
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_A4
    movel %sp@+,%d0
    moveal %sp@+,%a0
    rts

/* subroutine (159 instructions): traps SwapMMUMode; calls DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84 (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268:/* program mode index d1: the timing block's record for it (46 bytes each, from +36) */
    moveml %d0-%d2/%a0-%a2,%sp@-
    moveal %a3@(24),%a2
    moveal %a3@(28),%a1
    movew %d1,%d2
    btst #9,%a3@(32)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1E
    cmpiw #4,%d2
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1E
    addqw #1,%d2
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1E:/* 32-bit mode; +33 clear, monitor 2: register +0 = 7, or 8 above index 0 */
    muluw #46,%d2
    lea %a1@(0x24,%d2:w),%a1
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    tstb %a3@(33)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_4E
    cmpiw #2,%a3@(38)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_4E
    cmpiw #0,%d1
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_48
    movel #8,%a2@
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_4E
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_48:/* index 0: 7 */
    movel #7,%a2@
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_4E:/* the record's first fields into registers +10, +14 (keeping bit 8) and +18 */
    movew %a1@,%a2@(10)
    movew %a1@(4),%a2@(18)
    movel %a2@(12),%d0
    andil #256,%d0
    movew %a1@(2),%a2@(14)
    orl %d0,%a2@(12)
    tstb %a3@(33)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_7A
    andil #4092,%a2@(16)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_7A:/* register +24 from register +16 bit 0 and +35 */
    movel %a2@(16),%d0
    bfextu %d0,31,1,%d0
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_8E
    tstb %a3@(35)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_8E
    moveq #1,%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_90
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_8E:/* 0 */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_90:/* store; flags bit 11 clear: enable bits in +16 */
    movel %d0,%a2@(24)
    btst #11,%a3@(32)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_C8
    tstb %a3@(33)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_AC
    oril #2048,%a2@(16)
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_C8
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_AC:/* this board: bit 9, plus bit 11 if register +290 bit 7 is set */
    oril #512,%a2@(16)
    subqw #2,%sp
    movew %a2@(290),%sp@
    andiw #128,%sp@+
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_C8
    oril #2560,%a2@(16)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_C8:/* the record's timing fields into registers +294 to +330 and +362; +546; a 16-bit mode: 192 at +544 */
    movew %a1@(26),%a2@(362)
    movew %a1@(6),%a2@(294)
    movew %a1@(8),%a2@(298)
    movew %a1@(10),%a2@(302)
    movew %a1@(12),%a2@(306)
    movew %a1@(14),%a2@(310)
    movew %a1@(16),%a2@(314)
    movew %a1@(18),%a2@(318)
    movew %a1@(20),%a2@(322)
    movew %a1@(22),%a2@(326)
    movew %a1@(24),%a2@(330)
    clrl %a2@(512)
    movew %a1@(28),%a2@(546)
    nop
    tstl %a2@(512)
    btst #9,%a3@(32)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_142
    cmpiw #4,%d1
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_142
    movel #1,%a2@(512)
    movel #192,%a2@(544)
    nop
    tstl %a2@(512)
    clrl %a2@(512)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_142:/* PRAM bit 1 (+34): RAMDAC register 6 (+544) bit 4 from register +12 bit 10 */
    tstb %a3@(34)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_244
    movel %a2@(12),%d0
    bfextu %d0,21,1,%d2
    notl %d2
    clrl %a2@(512)
    nop
    movel %a2@(544),%sp@-
    movel #6,%a2@(544)
    movel #1,%a2@(512)
    nop
    movel %a2@(544),%d0
    bfins %d2,%d0,27,1
    movel %d0,%a2@(544)
    nop
    tstl %a2@(512)
    clrl %a2@(512)
    movel %sp@+,%a2@(544)
    tstb %a3@(33)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1A2
    btst #0,%d2
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1A2
    movel %a2@(12),%d0
    bfins %d2,%d0,22,1
    movel %d0,%a2@(12)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1A2:/* first mode of the record: the extra adjustment (+18, +19 of the timing block) */
    tstb %a3@(33)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1C6
    moveal %a3@(28),%a0
    cmpb %a0@(18),%d1
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1C6
    movew %a1@(30),%a2@(362)
    movel %a2@(360),%d0
    addb %a0@(19),%d0
    movel %d0,%a2@(360)
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1CC
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1C6:/* the normal CRTC field */
    movew %a1@(30),%a2@(362)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_1CC:/* two more timing fields; with +33: the amounts from the table added to +360, +320, +324 */
    movew %a1@(32),%a2@(322)
    movew %a1@(34),%a2@(326)
    tstb %a3@(33)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_244
    moveq #0,%d0
    movew %a1@(28),%d0
    bclr #7,%d0
    lsrw #5,%d0
    movew %d0,%d2
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_2CE),%a0
    muluw #12,%d0
    addaw %d0,%a0
    movew %a0@(0x0,%d1:w:2),%d0
    addl %d0,%a2@(360)
    tstb %a3@(41)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_22A
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_2F2),%a0
    movew %a0@(0x0,%d2:w:2),%d0
    addl %d0,%a2@(360)
    addl %d0,%a2@(320)
    addl %d0,%a2@(324)
    cmpiw #4,%d1
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_22A
    cmpiw #9,%a3@(38)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_22A
    addql #1,%a2@(360)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_22A:/* register +12 bit 9 from flags bit 8 */
    movel %a2@(12),%d0
    btst #8,%a3@(32)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_23A
    moveq #0,%d1
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_23C
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_23A:/* set */
    moveq #1,%d1
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_23C:/* store */
    bfins %d1,%d0,22,1
    movel %d0,%a2@(12)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_244:/* at blanking: reset sequence on register +32: 3, 7, 3, 2, 0 */
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84
    movew %sp@+,%sr
    movel #3,%a2@(32)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_254:/* delays (byte reads of VIA at 0x1D4) between the writes */
    tstb @(VIA,%za0)@(0)
    tstb @(VIA,%za0)@(0)
    tstb @(VIA,%za0)@(0)
    movel #7,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408FC922
    tstb @(VIA,%za0)@(0)	| 408FC928
    tstb @(VIA,%za0)@(0)	| 408FC92E
    movel #3,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408FC93C
    tstb @(VIA,%za0)@(0)	| 408FC942
    tstb @(VIA,%za0)@(0)	| 408FC948
    movel #2,%a2@(32)
    tstb @(VIA,%za0)@(0)	| 408FC956
    tstb @(VIA,%za0)@(0)	| 408FC95C
    tstb @(VIA,%za0)@(0)	| 408FC962
    clrl %a2@(32)
    tstb @(VIA,%za0)@(0)	| 408FC96C
    tstb @(VIA,%za0)@(0)	| 408FC972
    tstb @(VIA,%za0)@(0)	| 408FC978
    moveb %sp@+,%d0
    _SwapMMUMode
    moveml %sp@+,%d0-%d2/%a0-%a2
    rts

/* subroutine (143 instructions): traps SwapMMUMode (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C:/* gray the screen for mode d1: pattern, frame buffer address */
    moveml %d0-%a2,%sp@-
    moveal %a3@,%a2
    movew %d1,%d7
    moveb %a3@(40),%d3
    btst #9,%a3@(32)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_16
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_50
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_16:/* with 16-bit depth */
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_2A6),%a0
    movel %a0@(0x0,%d1:w:4),%d4
    movel %d4,%d5
    moveq #-1,%d6
    cmpiw #4,%d1
    jblt DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_66
    cmpiw #4,%d1
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_30
    notl %d5
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_30:/* direct mode: border 0; some sResources start at the base (+4) */
    moveq #0,%d6
    cmpib #0xf0,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_66
    cmpib #0xf1,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_66
    cmpib #0xf4,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_66
    cmpib #0xf5,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_66
    moveal %a3@(4),%a2
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_66
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_50:/* without 16-bit depth */
    lea %pc@(DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_292),%a0
    movel %a0@(0x0,%d1:w:4),%d4
    movel %d4,%d5
    moveq #-1,%d6
    cmpiw #4,%d1
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_66
    notl %d5
    moveq #0,%d6
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_66:/* the record: sizes and borders (+72 onwards) */
    moveal %a3@(28),%a1
    moveal %a1,%a0
    btst #9,%a3@(32)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_7C
    cmpiw #4,%d1
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_7C
    addqw #1,%d1
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_7C:/* 32-bit mode; extra lines above for monitor 2 and some sResources */
    muluw #46,%d1
    lea %a1@(0x48,%d1:w),%a1
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%d2
    cmpiw #2,%a3@(38)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_C4
    cmpib #0xd9,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CA
    cmpib #0xdb,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CA
    cmpib #0xd8,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CA
    cmpib #0xda,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CA
    cmpib #0xdd,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CA
    cmpib #0xdf,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CA
    cmpib #0xdc,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CA
    cmpib #0xde,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CA
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_DA
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_C4:/* 512 bytes */
    movew #512,%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CE
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CA:/* 1024 bytes */
    movew #1024,%d0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_CE:/* start earlier by that; black */
    subaw %d0,%a2
    lsrw #2,%d0
    subqw #1,%d0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_D4:/* loop */
    movel %d6,%a2@+
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_D4
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_DA:/* top border rows */
    movew %a1@(2),%d1
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_EE
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_E0:/* per row */
    movew %a1@(4),%d0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_E4:/* loop: border longs */
    movel %d6,%a2@+
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_E4
    addaw %a1@(8),%a2
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_EE:/* next row; then the visible rows */
    dbf %d1,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_E0
    movew %a0@(20),%d1
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_F6:/* per row: left border */
    movew %a1@(6),%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_FE
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_FC:/* loop */
    movel %d6,%a2@+
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_FE:/* next; the row's longs */
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_FC
    movew %a1@,%d0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_104:/* pattern, alternating */
    movel %d4,%a2@+
    cmpib #0xea,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_120
    cmpib #0xeb,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_120
    cmpib #0xe8,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_120
    cmpib #0xe9,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_120
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_136
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_120:/* some sResources: two longs per step in one mode */
    btst #9,%a3@(32)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_130
    cmpiw #4,%d7
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_138
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_136
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_130:/* mode 5 */
    cmpiw #5,%d7
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_138
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_136:/* the other half */
    movel %d5,%a2@+
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_138:/* next long; the next row inverts the pattern; right border */
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_104
    notl %d4
    notl %d5
    movew %a1@(6),%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_148
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_146:/* loop */
    movel %d6,%a2@+
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_148:/* next; next row; bottom border */
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_146
    addaw %a1@(8),%a2
    dbf %d1,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_F6
    movew %a1@(2),%d1
    cmpib #0xd9,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18A
    cmpib #0xdb,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18A
    cmpib #0xd8,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18A
    cmpib #0xda,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18A
    cmpib #0xdd,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18A
    cmpib #0xdf,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18A
    cmpib #0xdc,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18A
    cmpib #0xde,%d3
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18A
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18C
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18A:/* one more row for those sResources */
    addqw #1,%d1
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18C:/* bottom border */
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_19C
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18E:/* per row */
    movew %a1@(4),%d0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_192:/* loop */
    movel %d6,%a2@+
    dbf %d0,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_192
    addaw %a1@(8),%a2
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_19C:/* next; addressing mode back */
    dbf %d1,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_53C_18E
    moveb %d2,%d0
    _SwapMMUMode
    moveml %sp@+,%d0-%a2
    rts

/* subroutine (147 instructions): traps SwapMMUMode, trap_A440, trap_A722, HLock, StripAddress, trap_A458, SlotManager, Open; calls DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84, DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138_6C, DECL_DRVR_Display_Video_Apple_DAFB_Status_ACA, DECL_DRVR_Display_Video_Apple_TIM_GetDef; low memory Backlight (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6:/* load the gamma table as a linear ramp into the RAMDAC for direct modes: its three channels */
    moveml %d0-%d3/%d5/%a0/%a4-%fp,%sp@-
    moveal %a3@(12),%a0
    movew %a0@(4),%d0
    lea %a0@(12),%a4
    addaw %d0,%a4
    moveal %a4,%a5
    moveal %a4,%fp
    cmpiw #1,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_30
    movew %a0@(10),%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %a0@(8),%d1
    addaw %d1,%a5
    addaw %d1,%fp
    addaw %d1,%fp
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_30:/* 32-bit mode; RAMDAC index 0; 16-bit mode: 32 entries */
    movew %a0@(8),%d2
    subqw #1,%d2
    moveq #1,%d0
    _SwapMMUMode
    moveal %a3@(20),%a0
    lea %a0@(528),%a0
    clrl %a0@(-16)
    movew %a3@(32),%d5
    btst #9,%d5
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_52
    jbra DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_64
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_52:/* 16-bit (mode 0x84) */
    movew %a3@(36),%d1
    cmpib #0x84,%d1
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_64
    bset #12,%d5
    movew #31,%d2
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_64:/* wait for blanking */
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_1B4_84
    moveq #0,%d3
    moveq #0,%d1
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_6E:/* each entry: expanded for 16-bit */
    movew %d3,%d1
    btst #12,%d5
    jbeq DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_84
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_138_6C
    tstb %a3@(41)
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_84
    movel %d1,%a0@(-16)
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_84:/* R, G, B through the gamma table */
    moveb %a4@(0x0,%d1:w),%a0@(3)
    moveb %a5@(0x0,%d1:w),%a0@(3)
    moveb %fp@(0x0,%d1:w),%a0@(3)
    addqw #1,%d3
    dbf %d2,DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_6E
    movew %sp@+,%sr
    _SwapMMUMode
    moveml %sp@+,%d0-%d3/%d5/%a0/%a4-%fp
    rts
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_A6:/* the VBL interrupt handler: clear the flag, JVBLTask (vector 0xD28) for this slot */
    movel %a0,%sp@-
    movel %d1,%sp@-
    moveq #1,%d0
    jsr @(JSwapMMU,%za0)@(0)	| 408FCBDE
    moveb %d0,%sp@-
    moveal %a1@(24),%a0
DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_B8:/* loop until the flag clears */
    clrl %a0@(268)
    movel %a0@(264),%d0
    btst #2,%d0
    jbne DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_6E6_B8
    moveb %sp@+,%d0
    jsr @(JSwapMMU,%za0)@(0)	| 408FCBFA
    moveq #0,%d0
    jsr @(JVBLTask,%za0)@(0)	| 408FCC02
    moveq #1,%d0
    movel %sp@+,%d1
    moveal %sp@+,%a0
    rts

/* Driver (sBlock: length, then the driver: header with the routine offsets, name, code) for Display Video Apple TIM. */
DECL_DRVR_Display_Video_Apple_TIM:
    .long   0x0000032C, 0x5C000000, 0x00000000, 0x003A0000	| 408FCC10
    .byte   0x00, 0xEA, 0x01, 0xD4, 0x01, 0x92, 0x18	| 408FCC20
    .ascii  ".Display_Video_Apple_TIM\000"
    .short  0x0000	| 408FCC40
DECL_DRVR_Display_Video_Apple_TIM_32:  /* string "\012.Backlight\000" */
    .ascii  "\012.Backlight\000"
    moveq #38,%d0	| 408FCC4E
    .short  0xA440	| 408FCC50 408FCC50 A-line trap
    moveq #38,%d0	| 408FCC52
    .short  0xA722	| 408FCC54 408FCC54 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_DAFB_Status_A34	| 408FCC56
    movel %a0,%a1@(20)	| 408FCC5A
    _HLock	| 408FCC5E 408FCC5E A-line trap
    moveal %a0@,%a3	| 408FCC60
    movel %a0@,%d0	| 408FCC62
    _StripAddress	| 408FCC64 408FCC64 A-line trap
    moveal %d0,%a3	| 408FCC66
    movel %a1@(42),%a3@	| 408FCC68
    lea %pc@(DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_48),%a0	| 408FCC6C
    movel %a0,%a3@(20)	| 408FCC70
    lea %a3@(14),%a0	| 408FCC74
    movel #1700881505,%a0@	| 408FCC78
    .short  0xA458	| 408FCC7E 408FCC7E A-line trap
    jbsr DECL_DRVR_Display_Video_Apple_DAFB_Status_ACA	| 408FCC80
    subaw #56,%sp	| 408FCC84
    moveal %sp,%a0	| 408FCC88
    moveb %a1@(40),%a0@(49)	| 408FCC8A
    moveb %a1@(41),%a0@(50)	| 408FCC90
    clrb %a0@(51)	| 408FCC96
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */	| 408FCC9A
    _SlotManager	| 408FCC9C 408FCC9C A-line trap
    jbne DECL_DRVR_Display_Video_Apple_DAFB_Status_A24	| 408FCC9E
    moveb #0x80,%a0@(50)	| 408FCCA0
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 408FCCA6
    _SlotManager	| 408FCCA8 408FCCA8 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_DAFB_Status_A24	| 408FCCAA
    moveb #2,%a0@(50)	| 408FCCAC
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */	| 408FCCB2
    _SlotManager	| 408FCCB4 408FCCB4 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_DAFB_Status_A24	| 408FCCB6
    moveal %a0@,%a0	| 408FCCB8
    movew %a0@(6),%a3@(8)	| 408FCCBA
    lea %a0@(8),%a0	| 408FCCC0
    movel %a0,%a3@(4)	| 408FCCC4
    lea %sp@(56),%sp	| 408FCCC8
    movew #128,%a3@(10)	| 408FCCCC
    subaw #50,%sp	| 408FCCD2
    moveal %sp,%a0	| 408FCCD6
    lea %pc@(DECL_DRVR_Display_Video_Apple_TIM_32),%a1	| 408FCCD8
    movel %a1,%a0@(18)	| 408FCCDC
    _Open	| 408FCCE0 408FCCE0 A-line trap
    lea %sp@(50),%sp	| 408FCCE2
    moveq #0,%d0	| 408FCCE6
DECL_DRVR_Display_Video_Apple_DAFB_Status_A22:  /* return */
    rts
DECL_DRVR_Display_Video_Apple_DAFB_Status_A24:  /* address %sp@(56) */
    lea %sp@(56),%sp	| 408FCCEA
    lea %a3@(14),%a0	| 408FCCEE
    _RmvTime	| 408FCCF2 408FCCF2 A-line trap
    moveal %a1@(20),%a0	| 408FCCF4
    _DisposHandle	| 408FCCF8 408FCCF8 A-line trap
DECL_DRVR_Display_Video_Apple_DAFB_Status_A34:
    moveq #-23,%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_Status_A22
    moveml %a0-%a1,%sp@-	| 408FCCFE
    moveal %a0@(28),%a2	| 408FCD02
    moveal %a1@(20),%a3	| 408FCD06
    movel %a3@,%d0	| 408FCD0A
    _StripAddress	| 408FCD0C 408FCD0C A-line trap
    moveal %d0,%a3	| 408FCD0E
    movew %a0@(26),%d0	| 408FCD10
    addqw #1,%d0	| 408FCD14
    cmpiw #10,%d0	| 408FCD16
    jbhi DECL_DRVR_Display_Video_Apple_DAFB_Status_A74	| 408FCD1A
    movew %pc@(DECL_DRVR_Display_Video_Apple_DAFB_Status_A5E,%d0:w:2),%d0	| 408FCD1C
    jmp %pc@(DECL_DRVR_Display_Video_Apple_DAFB_Status_A5E,%d0:w)	| 408FCD20
DECL_DRVR_Display_Video_Apple_DAFB_Status_A5E:  /* from here: orib #40,%a4@- */
    orib #40,%a4@-	| 408FCD24
    orib #64,%a2@+	| 408FCD28
    orib #22,%fp@	| 408FCD2C
    oriw #22,%a2@	| 408FCD30
    oriw #22,%fp@+	| 408FCD34
    .byte   0x00, 0x16	| 408FCD38
DECL_DRVR_Display_Video_Apple_DAFB_Status_A74:  /* result -17 */
    moveq #-17,%d0
    jbra DECL_DRVR_Display_Video_Apple_DAFB_Status_A7A
DECL_DRVR_Display_Video_Apple_DAFB_Status_A78:  /* loop: moveq */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_DAFB_Status_A7A:  /* restore registers */
    moveml %sp@+,%a0-%a1
    jbra DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_8
    bsrs DECL_DRVR_Display_Video_Apple_DAFB_Status_ACA_16
    bras DECL_DRVR_Display_Video_Apple_DAFB_Status_A78
    movew #128,%a2@
    movew #128,%a3@(10)
    clrw %a2@(6)
    movel %a3@,%a2@(8)
    jbsr DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_18
    jbra DECL_DRVR_Display_Video_Apple_DAFB_Status_A78
    cmpiw #128,%a2@
    bnes DECL_DRVR_Display_Video_Apple_DAFB_Status_A74
    tstw %a2@(6)
    bnes DECL_DRVR_Display_Video_Apple_DAFB_Status_A74
    movel %a3@,%a2@(8)
    bras DECL_DRVR_Display_Video_Apple_DAFB_Status_A78
    .short  0x4A6A	| 408FCD76
    .short  0x0006, 0x66BE	| orib #0xbe,%d6
    jbsr DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_18
    jbra DECL_DRVR_Display_Video_Apple_DAFB_Status_A78
    .byte   0x10, 0x12, 0x48, 0x80, 0x37, 0x40, 0x00, 0x24, 0x66, 0x02, 0x61, 0x02, 0x60, 0xAE	| 408FCD82

/* subroutine (40 instructions): traps StripAddress, RmvTime, Open, Close, DisposPtr, DisposHandle; calls DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_18 (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DAFB_Status_ACA:
    movel %a1,%sp@-	| 408FCD90
    lea %a3@(14),%a0	| 408FCD92
    movel #-16626,%d0	| 408FCD96
    moveal 0x568,%a1	| 408FCD9C
    jsr %a1@	| 408FCDA0
    moveal %sp@+,%a1	| 408FCDA2
    rts	| 408FCDA4
DECL_DRVR_Display_Video_Apple_DAFB_Status_ACA_16:
    moveal %a1@(20),%a3	| 408FCDA6
    movel %a3@,%d0	| 408FCDAA
    _StripAddress	| 408FCDAC 408FCDAC A-line trap
    moveal %d0,%a3	| 408FCDAE
    movew #1,%a3@(36)	| 408FCDB0
    lea %a3@(14),%a0	| 408FCDB6
    _RmvTime	| 408FCDBA 408FCDBA A-line trap
    subaw #50,%sp	| 408FCDBC
    moveal %sp,%a0	| 408FCDC0
    lea %pc@(DECL_DRVR_Display_Video_Apple_TIM_32),%a1	| 408FCDC2
    movel %a1,%a0@(18)	| 408FCDC6
    _Open	| 408FCDCA 408FCDCA A-line trap
    jbne DECL_DRVR_Display_Video_Apple_DAFB_Status_B0A	| 408FCDCC
    _Close	| 408FCDCE 408FCDCE A-line trap
DECL_DRVR_Display_Video_Apple_DAFB_Status_B0A:
    lea %sp@(50),%sp	| 408FCDD0
    jbsr DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_18	| 408FCDD4
    moveal %a3@(4),%a0	| 408FCDD8
    _DisposPtr	| 408FCDDC 408FCDDC A-line trap
    moveal %a1@(20),%a0	| 408FCDDE
    _DisposHandle	| 408FCDE2 408FCDE2 A-line trap
    moveq #0,%d0	| 408FCDE4
    rts	| 408FCDE6

/* Status: find csCode in the status table and call its routine (out of range: StatusBadCode) (Display Video Apple TIM). */
DECL_DRVR_Display_Video_Apple_TIM_Status:
    moveml %a0-%a1,%sp@-
    moveal %a0@(28),%a2
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    movew %a0@(26),%d0
    cmpiw #9,%d0
    jbhi DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode
    movew %pc@(DECL_DRVR_Display_Video_Apple_TIM_StatusTable,%d0:w:2),%d0
    jmp %pc@(DECL_DRVR_Display_Video_Apple_TIM_StatusTable,%d0:w)

/* status table: routine offsets by csCode (Display Video Apple TIM). */
DECL_DRVR_Display_Video_Apple_TIM_StatusTable:
    .short  DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE0C
    .short  DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE0E
    .short  DECL_DRVR_Display_Video_Apple_TIM_GetMode-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE10
    .short  DECL_DRVR_Display_Video_Apple_TIM_GetEntries-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE12
    .short  DECL_DRVR_Display_Video_Apple_TIM_GetPages-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE14
    .short  DECL_DRVR_Display_Video_Apple_TIM_GetBaseAddr-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE16
    .short  DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE18
    .short  DECL_DRVR_Display_Video_Apple_TIM_GetInterrupt-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE1A
    .short  DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE1C
    .short  DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode-DECL_DRVR_Display_Video_Apple_TIM_StatusTable	| 408FCE1E

/* unknown status csCode: statusErr (Display Video Apple TIM). */
DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode:
    moveq #-18,%d0
    jbra DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_6
DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_4:  /* loop: moveq */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_6:  /* restore registers */
    moveml %sp@+,%a0-%a1
    jbra DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_8

/* Status csCode 2, cscGetMode: current mode, page and base address (Display Video Apple TIM). */
DECL_DRVR_Display_Video_Apple_TIM_GetMode:
    movew %a3@(10),%a2@
    clrw %a2@(6)
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_4

/* Status csCode 3, cscGetEntries: read colour table entries (from the CLUT) (Display Video Apple TIM). */
DECL_DRVR_Display_Video_Apple_TIM_GetEntries:
    movel %a2@,%d0
    jbeq DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode
    _StripAddress
    movel %d4,%sp@-
    movew %a3@(8),%d3
    movew %a2@(6),%d4
    jbmi DECL_DRVR_Display_Video_Apple_TIM_GetEntries_5C
    cmpw %d3,%d4
    jbhi DECL_DRVR_Display_Video_Apple_TIM_GetEntries_5C
    movew %d4,%d2
    moveal %d0,%a0
    cmpiw #-1,%a2@(4)
    jbeq DECL_DRVR_Display_Video_Apple_TIM_GetEntries_32
    movew %d4,%d1
    addw %a2@(4),%d2
DECL_DRVR_Display_Video_Apple_TIM_GetEntries_28:  /* loop: move */
    movew %d2,%a0@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,DECL_DRVR_Display_Video_Apple_TIM_GetEntries_28
DECL_DRVR_Display_Video_Apple_TIM_GetEntries_32:  /* loop: move */
    movew %a0@,%d1
    cmpw %d3,%d1
    jbhi DECL_DRVR_Display_Video_Apple_TIM_GetEntries_52
    moveal %a3@(4),%a1
    lea %a1@(0x0,%d1:w:8),%a1
    .long   0x31690002	| 408FCE7C
    .short  0x0002, 0x3169	| orib #105,%d2
    orib #4,%d4
    movew %a1@(6),%a0@(6)
DECL_DRVR_Display_Video_Apple_TIM_GetEntries_52:  /* add 8 to %a0 */
    addqw #8,%a0
    dbf %d4,DECL_DRVR_Display_Video_Apple_TIM_GetEntries_32
    movel %sp@+,%d4
    jbra DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_TIM_GetEntries_5C:  /* set %d4 */
    movel %sp@+,%d4
    jbra DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode

/* Status csCode 4, cscGetPages: number of video pages for a mode (Display Video Apple TIM). */
DECL_DRVR_Display_Video_Apple_TIM_GetPages:
    cmpiw #128,%a2@
    jbne DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode
    movew #1,%a2@(6)
    jbra DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_4

/* Status csCode 5, cscGetBaseAddr: base address of a page (Display Video Apple TIM). */
DECL_DRVR_Display_Video_Apple_TIM_GetBaseAddr:
    movew %a2@(6),%d0
    jbne DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_4

/* Status csCode 7, cscGetInterrupt: whether the VBL interrupt is enabled (Display Video Apple TIM). */
DECL_DRVR_Display_Video_Apple_TIM_GetInterrupt:
    tstw %a3@(36)
    jbeq DECL_DRVR_Display_Video_Apple_TIM_GetInterrupt_E
    moveb #1,%a2@
    jbra DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_TIM_GetInterrupt_E:  /* clear %a2@ */
    clrb %a2@
    jbra DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_4

/* Status csCode 9, cscGetDefaultMode: the default mode (from slot PRAM) (Display Video Apple TIM). */
DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode:
    moveb %a1@(41),%a2@
    jbra DECL_DRVR_Display_Video_Apple_TIM_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_8:  /* test bit 9 of %a0@(6) */
    btst #9,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_12
    rts
DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_12:  /* set %sp@- */
    movel JIODone,%sp@-
    rts

/* subroutine (139 instructions): traps SwapMMUMode, trap_A440, trap_A722, HLock, StripAddress, trap_A71E, trap_A458, Open; calls DECL_DRVR_Display_Video_Apple_DBLite_212, DECL_DRVR_Display_Video_Apple_DBLite_22C, DECL_DRVR_Display_Video_Apple_DBLite_41E, DECL_DRVR_Display_Video_Apple_DBLite_34E, DECL_DRVR_Display_Video_Apple_DBLite; low memory Backlight (mechanical summary) */
DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_18:
    moveml %d0/%d2-%d3/%a0-%a1,%sp@-
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    movel #-1431655766,%d3
    moveal %a3@,%a0
    movew #399,%d0
DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_18_16:  /* loop: move */
    movew #19,%d2
DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_18_1A:  /* loop: move */
    movel %d3,%a0@+
    dbf %d2,DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_18_1A
    notl %d3
    dbf %d0,DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_18_16
    moveb %sp@+,%d0
    _SwapMMUMode
    moveml %sp@+,%d0/%d2-%d3/%a0-%a1
    rts
DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_48:  /* set %sp@- */
    movel %a1,%sp@-	| 408FCF1A
    clrw %d0	| 408FCF1C
    moveal JVBLTask,%a0	| 408FCF1E
    jsr %a0@	| 408FCF22
    moveal %sp@+,%a1	| 408FCF24
    tstw %a1@(22)	| 408FCF26
    jbne DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_68	| 408FCF2A
    moveal %a1,%a0	| 408FCF2C
    movel #-16626,%d0	| 408FCF2E
    moveal 0x568,%a1	| 408FCF34
    jsr %a1@	| 408FCF38
DECL_DRVR_Display_Video_Apple_TIM_GetDefaultMode_68:  /* return */
    rts	| 408FCF3A

/* Driver (sBlock: length, then the driver: header with the routine offsets, name, code) for Display Video Apple DBLite. */
DECL_DRVR_Display_Video_Apple_DBLite:
    .byte   0x00, 0x00, 0x04, 0x7C, 0x4C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x54, 0x00, 0x00	| 408FCF3C
    .byte   0x01, 0x0C, 0x01, 0x2C, 0x00, 0xC8, 0x1B	| 408FCF4C
    .ascii  ".Display_Video_Apple_DBLite\000"
    .byte   0x01	| 408FCF6F
DECL_DRVR_Display_Video_Apple_DBLite_34:  /* string "\012.Backlight\000" */
    .ascii  "\012.Backlight\000"
DECL_DRVR_Display_Video_Apple_DBLite_40:  /* (data) */
    .byte   0xAA, 0xAA, 0xAA, 0xAA, 0x00, 0x13, 0x01, 0x8F, 0xCC, 0xCC, 0xCC, 0xCC, 0x00, 0x27, 0x01, 0x8F	| 408FCF7C
    .byte   0xF0, 0xF0, 0xF0, 0xF0, 0x00, 0x4F, 0x01, 0x8F	| 408FCF8C
    moveq #44,%d0	| 408FCF94
    .short  0xA440	| 408FCF96 408FCF96 A-line trap
    moveq #44,%d0	| 408FCF98
    .short  0xA722	| 408FCF9A 408FCF9A A-line trap
    jbne DECL_DRVR_Display_Video_Apple_DBLite_C8	| 408FCF9C
    movel %a0,%a1@(20)	| 408FCF9E
    _HLock	| 408FCFA2 408FCFA2 A-line trap
    movel %a0@,%d0	| 408FCFA4
    _StripAddress	| 408FCFA6 408FCFA6 A-line trap
    moveal %d0,%a3	| 408FCFA8
    moveal 0xdd8,%a0	| 408FCFAA
    movel %a0,%sp@-	| 408FCFAE
    addal %a0@,%a0	| 408FCFB0
    movel %a0@(56),%a3@(4)	| 408FCFB2
    moveal %sp@+,%a0	| 408FCFB8
    addal %a0@(8),%a0	| 408FCFBA
    movel %a0@(4),%a3@	| 408FCFBE
    moveq #16,%d0	| 408FCFC2
    .short  0xA71E	| 408FCFC4 408FCFC4 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_DBLite_C2	| 408FCFC6
    movel %a0,%a3@(8)	| 408FCFC8
    lea %pc@(DECL_DRVR_Display_Video_Apple_DBLite_45A),%a0	| 408FCFCC
    movel %a0,%a3@(26)	| 408FCFD0
    lea %a3@(20),%a0	| 408FCFD4
    movel #1700881505,%a0@	| 408FCFD8
    .short  0xA458	| 408FCFDE 408FCFDE A-line trap
    jbsr DECL_DRVR_Display_Video_Apple_DBLite_212	| 408FCFE0
    jbne DECL_DRVR_Display_Video_Apple_DBLite_C2	| 408FCFE4
    subaw #50,%sp	| 408FCFE6
    moveal %sp,%a0	| 408FCFEA
    lea %pc@(DECL_DRVR_Display_Video_Apple_DBLite_34),%a1	| 408FCFEC
    movel %a1,%a0@(18)	| 408FCFF0
    _Open	| 408FCFF4 408FCFF4 A-line trap
    lea %sp@(50),%sp	| 408FCFF6
    moveq #0,%d0	| 408FCFFA
    rts	| 408FCFFC
DECL_DRVR_Display_Video_Apple_DBLite_C2:  /* set %a0 */
    moveal %a1@(20),%a0	| 408FCFFE
    _DisposHandle	| 408FD002 408FD002 A-line trap
DECL_DRVR_Display_Video_Apple_DBLite_C8:
    moveq #-23,%d0	| 408FD004
    rts	| 408FD006
    moveal %a1@(20),%a3	| 408FD008
    movel %a3@,%d0	| 408FD00C
    _StripAddress	| 408FD00E 408FD00E A-line trap
    moveal %d0,%a3	| 408FD010
    jbsr DECL_DRVR_Display_Video_Apple_DBLite_22C	| 408FD012
    subaw #50,%sp	| 408FD016
    moveal %sp,%a0	| 408FD01A
    lea %pc@(DECL_DRVR_Display_Video_Apple_DBLite_34),%a1	| 408FD01C
    movel %a1,%a0@(18)	| 408FD020
    _Open	| 408FD024 408FD024 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_DBLite_EE	| 408FD026
    _Close	| 408FD028 408FD028 A-line trap
DECL_DRVR_Display_Video_Apple_DBLite_EE:
    lea %sp@(50),%sp	| 408FD02A
    jbsr DECL_DRVR_Display_Video_Apple_DBLite_41E	| 408FD02E
    moveal %a3@(8),%a0	| 408FD032
    _DisposPtr	| 408FD036 408FD036 A-line trap
    movel %a3@(12),%d0	| 408FD038
    jbeq DECL_DRVR_Display_Video_Apple_DBLite_106	| 408FD03C
    moveal %d0,%a0	| 408FD03E
    _DisposPtr	| 408FD040 408FD040 A-line trap
DECL_DRVR_Display_Video_Apple_DBLite_106:
    moveal %a1@(20),%a0	| 408FD042
    _DisposHandle	| 408FD046 408FD046 A-line trap
    moveq #0,%d0	| 408FD048
    rts	| 408FD04A
    lea %pc@(DECL_DRVR_Display_Video_Apple_DBLite_118),%a4	| 408FD04C
    moveq #-17,%d0	| 408FD050
    jbra DECL_DRVR_Display_Video_Apple_DBLite_150	| 408FD052
DECL_DRVR_Display_Video_Apple_DBLite_118:  /* (data) */
    .byte   0x00, 0x07, 0x00, 0x84, 0x00, 0x9E, 0x00, 0xA2, 0x00, 0x82, 0x00, 0x82, 0x00, 0xD6, 0x00, 0x82	| 408FD054
    .byte   0x00, 0xEE, 0x00, 0x85, 0x03, 0x04, 0x00, 0x00	| 408FD064
    lea %pc@(DECL_DRVR_Display_Video_Apple_DBLite_138),%a4	| 408FD06C
    moveq #-18,%d0	| 408FD070
    jbra DECL_DRVR_Display_Video_Apple_DBLite_150	| 408FD072
DECL_DRVR_Display_Video_Apple_DBLite_138:  /* (data) */
    .byte   0x00, 0x09, 0x00, 0x62, 0x00, 0x62, 0x01, 0x00, 0x01, 0x1C, 0x01, 0xD6, 0x01, 0xE6, 0x00, 0x62	| 408FD074
    .byte   0x01, 0xF4, 0x00, 0x62, 0x02, 0x02, 0x00, 0x00	| 408FD084
DECL_DRVR_Display_Video_Apple_DBLite_150:  /* set %d1 */
    movew %a0@(26),%d1	| 408FD08C
    movew %a4@+,%d2	| 408FD090
    cmpw %d2,%d1	| 408FD092
    jbls DECL_DRVR_Display_Video_Apple_DBLite_16E	| 408FD094
    movew %d2,%d3	| 408FD096
    subqw #1,%d3	| 408FD098
DECL_DRVR_Display_Video_Apple_DBLite_15E:  /* loop: addq */
    addqw #2,%d3	| 408FD09A
    movew %a4@(0,%d3:w:2),%d2	| 408FD09C
    jbeq DECL_DRVR_Display_Video_Apple_DBLite_190	| 408FD0A0
    cmpw %d2,%d1	| 408FD0A2
    jbne DECL_DRVR_Display_Video_Apple_DBLite_15E	| 408FD0A4
    movew %d3,%d1	| 408FD0A6
    addqw #1,%d1	| 408FD0A8
DECL_DRVR_Display_Video_Apple_DBLite_16E:  /* save registers */
    moveml %a0-%a1,%sp@-	| 408FD0AA
    moveal %a0@(28),%a2	| 408FD0AE
    movel %d0,%sp@-	| 408FD0B2
    moveal %a1@(20),%a3	| 408FD0B4
    movel %a3@,%d0	| 408FD0B8
    _StripAddress	| 408FD0BA 408FD0BA A-line trap
    moveal %d0,%a3	| 408FD0BC
    movel %sp@+,%d0	| 408FD0BE
    movew %a4@(0,%d1:w:2),%d1	| 408FD0C0
    jsr %a4@(0,%d1:w)	| 408FD0C4
    moveml %sp@+,%a0-%a1	| 408FD0C8
DECL_DRVR_Display_Video_Apple_DBLite_190:  /* test bit 9 of %a0@(6) */
    btst #9,%a0@(6)	| 408FD0CC
    jbne DECL_DRVR_Display_Video_Apple_DBLite_19C	| 408FD0D2
    movel JIODone,%sp@-	| 408FD0D4
DECL_DRVR_Display_Video_Apple_DBLite_19C:  /* return */
    rts	| 408FD0D8
    .byte   0x34, 0xBC, 0x00, 0x80, 0x37, 0x7C, 0x00, 0x80, 0x00, 0x12	| 408FD0DA
    moveq #0,%d1
    moveq #0,%d0
    movew %d0,%a2@(6)
    jbsr DECL_DRVR_Display_Video_Apple_DBLite_34E
    movel %a3@,%a2@(8)
    moveq #0,%d0
    rts
    movew %a2@,%d1
    bsrw DECL_DRVR_Display_Video_Apple_DBLite_22C_118
    bhis DECL_DRVR_Display_Video_Apple_DBLite_19C_52
    tstw %a2@(6)
    bnes DECL_DRVR_Display_Video_Apple_DBLite_19C_52
    movew %a2@,%d2
    cmpw %a3@(18),%d2
    beqs DECL_DRVR_Display_Video_Apple_DBLite_19C_4C
    movew %d2,%a3@(18)
    bsrw DECL_DRVR_Display_Video_Apple_DBLite_34E
    movel %a3@(12),%d0
    beqs DECL_DRVR_Display_Video_Apple_DBLite_19C_4C
    moveal %d0,%a0
    _DisposPtr
    clrl %a3@(12)
DECL_DRVR_Display_Video_Apple_DBLite_19C_4C:
    movel %a3@,%a2@(8)
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_DBLite_19C_52:
    rts
    movew %a3@(18),%d1
    bsrw DECL_DRVR_Display_Video_Apple_DBLite_22C_118
    bhis DECL_DRVR_Display_Video_Apple_DBLite_19C_6A
    tstw %a2@(6)	| 408FD136
    bnes DECL_DRVR_Display_Video_Apple_DBLite_19C_6A
    jbsr DECL_DRVR_Display_Video_Apple_DBLite_3EA
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_DBLite_19C_6A:
    rts
    .long   0x4A126620	| 408FD144
    jbsr DECL_DRVR_Display_Video_Apple_DBLite_212
    moveq #0,%d0
    rts

/* subroutine (8 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DBLite_212:
    movew %d0,%a3@(42)
    movel %a1,%sp@-
    lea %a3@(20),%a0
    movel #-16626,%d0
    moveal 0x568,%a1
    jsr %a1@
    moveal %sp@+,%a1
    rts

/* subroutine (4 instructions): traps RmvTime (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DBLite_22C:
    movew #-1,%a3@(42)	| 408FD168
    lea %a3@(20),%a0	| 408FD16E
    _RmvTime	| 408FD172 408FD172 A-line trap
    rts	| 408FD174
    .byte   0x4A, 0x6B, 0x00, 0x12, 0x66, 0x06, 0x37, 0x7C, 0x00, 0x80, 0x00, 0x12, 0x34, 0xAB, 0x00, 0x12	| 408FD176
    .byte   0x42, 0x6A, 0x00, 0x06, 0x25, 0x53, 0x00, 0x08, 0x70, 0x00, 0x4E, 0x75, 0x22, 0x12, 0x67, 0x00	| 408FD186
    .byte   0x00, 0xB4, 0x20, 0x01, 0xA0, 0x55, 0x26, 0x00, 0x4A, 0xAB, 0x00, 0x0C, 0x66, 0x52, 0x4F, 0xEF	| 408FD196
    .byte   0xFF, 0xC8, 0x20, 0x4F, 0x42, 0x28, 0x00, 0x31, 0x11, 0x69, 0x00, 0x29, 0x00, 0x32, 0x42, 0x28	| 408FD1A6
    .byte   0x00, 0x33, 0x70, 0x16, 0xA0, 0x6E, 0x66, 0x30, 0x30, 0x2B, 0x00, 0x12, 0x66, 0x04, 0x10, 0x3C	| 408FD1B6
    .byte   0x00, 0x80, 0x11, 0x40, 0x00, 0x32, 0x70, 0x06, 0xA0, 0x6E, 0x66, 0x1C, 0x11, 0x7C, 0x00, 0x02	| 408FD1C6
    .byte   0x00, 0x32, 0x70, 0x05, 0xA0, 0x6E, 0x66, 0x10, 0x20, 0x50, 0x37, 0x68, 0x00, 0x06, 0x00, 0x10	| 408FD1D6
    .byte   0x41, 0xE8, 0x00, 0x08, 0x27, 0x48, 0x00, 0x0C, 0x4F, 0xEF, 0x00, 0x38, 0x4A, 0x40, 0x66, 0x54	| 408FD1E6
    .byte   0x70, 0xEE, 0x20, 0x43, 0x36, 0x2B, 0x00, 0x10, 0x38, 0x2A, 0x00, 0x06, 0x6B, 0x46, 0xB8, 0x43	| 408FD1F6
    .byte   0x62, 0x42, 0x34, 0x04, 0x0C, 0x6A	| 408FD206
    .long   0xFFFF0004 /* number, not a label difference (was rsrc_PACK_4_408E9A20_37F0-.) */	| 408FD20C
    beqs DECL_DRVR_Display_Video_Apple_DBLite_22C_BA
    movew %d4,%d1
    addw %a2@(4),%d2
DECL_DRVR_Display_Video_Apple_DBLite_22C_B0:
    movew %d2,%a0@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,DECL_DRVR_Display_Video_Apple_DBLite_22C_B0
DECL_DRVR_Display_Video_Apple_DBLite_22C_BA:
    movew %a0@,%d1
    cmpw %d3,%d1
    bhis DECL_DRVR_Display_Video_Apple_DBLite_22C_DA
    moveal %a3@(12),%a1
    lea %a1@(0x0,%d1:w:8),%a1
    movew %a1@(2),%a0@(2)
    movew %a1@(4),%a0@(4)
    movew %a1@(6),%a0@(6)
DECL_DRVR_Display_Video_Apple_DBLite_22C_DA:
    addqw #8,%a0
    dbf %d4,DECL_DRVR_Display_Video_Apple_DBLite_22C_BA
    moveq #0,%d0
    rts
    movew %a2@,%d1
    bsrs DECL_DRVR_Display_Video_Apple_DBLite_22C_118
    bhis DECL_DRVR_Display_Video_Apple_DBLite_22C_F2
    movew #1,%a2@(6)
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_DBLite_22C_F2:
    rts
    tstw %a2@(6)
    bnes DECL_DRVR_Display_Video_Apple_DBLite_22C_100
    movel %a3@,%a2@(8)
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_DBLite_22C_100:
    rts
    tstw %a3@(42)
    seq %d0
    negb %d0
    moveb %d0,%a2@
    moveq #0,%d0
    rts
    moveb %a1@(41),%a2@
    moveq #0,%d0
    rts
DECL_DRVR_Display_Video_Apple_DBLite_22C_118:
    subiw #128,%d1
    cmpiw #2,%d1
    rts

/* subroutine (33 instructions): low memory TimeDBRA (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DBLite_34E:
    moveml %d0/%d2/%a0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge DECL_DRVR_Display_Video_Apple_DBLite_34E_16
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_DBLite_34E_16:  /* set %a0 */
    moveal %a3@(4),%a0
    moveb %a0@(4),%d0
    moveq #0,%d2
    bfins %d2,%d0,26,1
    moveb %d0,%a0@(4)
    moveq #33,%d2
DECL_DRVR_Display_Video_Apple_DBLite_34E_2A:  /* loop: swap */
    swap %d2
    movew TimeDBRA,%d2
DECL_DRVR_Display_Video_Apple_DBLite_34E_30:  /* count down (loop) */
    dbf %d2,DECL_DRVR_Display_Video_Apple_DBLite_34E_30
    swap %d2
    dbf %d2,DECL_DRVR_Display_Video_Apple_DBLite_34E_2A
    bfins %d1,%d0,29,3
    moveb %d0,%a0@(4)
    moveq #7,%d2
    andb %a0@(1),%d2
    muluw #3,%d2
    addw %d1,%d2
    moveb %pc@(DECL_DRVR_Display_Video_Apple_DBLite_3BA,%d2:w),%a0@(8)
    moveb %pc@(DECL_DRVR_Display_Video_Apple_DBLite_3D2,%d2:w),%a0@(10)
    moveq #1,%d2
    bfins %d2,%d0,26,1
    moveb %d0,%a0@(4)
    movew %sp@+,%sr
    moveml %sp@+,%d0/%d2/%a0
    rts
DECL_DRVR_Display_Video_Apple_DBLite_3BA:  /* (data) */
    .short  0x0503, 0x0305, 0x0303, 0x0503, 0x0305, 0x0303, 0x0503, 0x0305	| 408FD2F6
    .short  0x0303, 0x0503, 0x0305, 0x0303	| 408FD306
DECL_DRVR_Display_Video_Apple_DBLite_3D2:  /* (data) */
    .short  0xA040	| 408FD30E
    .long   0x40FF8040, 0xFF8040FF, 0x8040A040, 0x40A04040	| 408FD310
    .short  0x9C40, 0x03A0, 0x4040	| 408FD320

/* subroutine (18 instructions): traps SwapMMUMode (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DBLite_3EA:
    moveml %d0/%d2-%d3/%a0-%a1,%sp@-
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    lea %pc@(DECL_DRVR_Display_Video_Apple_DBLite_40),%a0
    lea %a0@(0x0,%d1:w:8),%a0
    moveal %a3@,%a1
    movew %a0@(6),%d0
    movel %a0@,%d3
DECL_DRVR_Display_Video_Apple_DBLite_3EA_1A:  /* loop: move */
    movew %a0@(4),%d2
DECL_DRVR_Display_Video_Apple_DBLite_3EA_1E:  /* loop: move */
    movel %d3,%a1@+
    dbf %d2,DECL_DRVR_Display_Video_Apple_DBLite_3EA_1E
    notl %d3
    dbf %d0,DECL_DRVR_Display_Video_Apple_DBLite_3EA_1A
    moveb %sp@+,%d0
    _SwapMMUMode
    moveml %sp@+,%d0/%d2-%d3/%a0-%a1
    rts

/* subroutine (374 instructions): traps SwapMMUMode, trap_A440, trap_A722, HLock, StripAddress, trap_A71E, SlotManager, DisposPtr; calls DECL_DRVR_Display_Video_Apple_Sonora_5E8, DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_F0, DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120, DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultM (mechanical summary) */
DECL_DRVR_Display_Video_Apple_DBLite_41E:
    moveml %d0/%d2-%d3/%a0-%a1,%sp@-
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    moveq #0,%d1
    movew %a3@(18),%d1
    subiw #128,%d1
    lea %pc@(DECL_DRVR_Display_Video_Apple_DBLite_40),%a0
    lea %a0@(0x0,%d1:w:8),%a0
    moveal %a3@,%a1
    movew %a0@(6),%d0
    moveq #-1,%d3
DECL_DRVR_Display_Video_Apple_DBLite_41E_24:  /* loop: move */
    movew %a0@(4),%d2
DECL_DRVR_Display_Video_Apple_DBLite_41E_28:  /* loop: move */
    movel %d3,%a1@+
    dbf %d2,DECL_DRVR_Display_Video_Apple_DBLite_41E_28
    dbf %d0,DECL_DRVR_Display_Video_Apple_DBLite_41E_24
    moveb %sp@+,%d0
    _SwapMMUMode
    moveml %sp@+,%d0/%d2-%d3/%a0-%a1
    rts
DECL_DRVR_Display_Video_Apple_DBLite_45A:  /* set %sp@- */
    movel %a1,%sp@-	| 408FD396
    clrw %d0	| 408FD398
    moveal JVBLTask,%a0	| 408FD39A
    jsr %a0@	| 408FD39E
    moveal %sp@+,%a1	| 408FD3A0
    tstw %a1@(22)	| 408FD3A2
    jbne DECL_DRVR_Display_Video_Apple_DBLite_47A	| 408FD3A6
    moveal %a1,%a0	| 408FD3A8
    movel #-16626,%d0	| 408FD3AA
    moveal 0x568,%a1	| 408FD3B0
    jsr %a1@	| 408FD3B4
DECL_DRVR_Display_Video_Apple_DBLite_47A:  /* return */
    rts	| 408FD3B6

/* Driver (sBlock: length, then the driver: header with the routine offsets, name, code) for Display Video Apple Sonora. */
DECL_DRVR_Display_Video_Apple_Sonora:
    .byte   0x00, 0x00, 0x0B, 0xF8, 0x4C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00	| 408FD3B8
    .byte   0x01, 0xEE, 0x08, 0xA6, 0x08, 0x7C, 0x1B	| 408FD3C8
    .ascii  ".Display_Video_Apple_Sonora\000\000"
DECL_DRVR_Display_Video_Apple_Sonora_34:  /* (data) */
    .byte   0x01, 0x7F, 0x00, 0x80, 0x03, 0x3F, 0x00, 0x40, 0x0F, 0x0F, 0x00, 0x10, 0xFF, 0x00, 0x00, 0x01	| 408FD3EC
    .byte   0x1F, 0x00, 0x00, 0x01	| 408FD3FC
DECL_DRVR_Display_Video_Apple_Sonora_48:  /* (data) */
    .byte   0xAA, 0xAA, 0xAA, 0xAA, 0xCC, 0xCC, 0xCC, 0xCC, 0xF0, 0xF0, 0xF0, 0xF0, 0xFF, 0x00, 0xFF, 0x00	| 408FD400
    .byte   0x00, 0x00, 0xFF, 0xFF	| 408FD410
DECL_DRVR_Display_Video_Apple_Sonora_5C:  /* (data) */
    .byte   0x00, 0x05, 0x01, 0x02, 0x05, 0x06, 0x17, 0x2D	| 408FD414
    moveq #35,%d0	| 408FD41C
    .short  0xA440	| 408FD41E 408FD41E A-line trap
    moveq #35,%d0	| 408FD420
    .short  0xA722	| 408FD422 408FD422 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_7BE	| 408FD424
    movel %a0,%a1@(20)	| 408FD428
    _HLock	| 408FD42C 408FD42C A-line trap
    movel %a0@,%d0	| 408FD42E
    _StripAddress	| 408FD430 408FD430 A-line trap
    moveal %d0,%a3	| 408FD432
    moveal 0xdd8,%a0	| 408FD434
    addal %a0@,%a0	| 408FD438
    movel %a0@(56),%a3@(20)	| 408FD43A
    movel %a0@(8),%a3@(24)	| 408FD440
    moveal 0xdd8,%a0	| 408FD446
    addal %a0@(8),%a0	| 408FD44A
    movel %a0@(4),%a3@	| 408FD44E
    moveq #16,%d0	| 408FD452
    .short  0xA71E	| 408FD454 408FD454 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_7B8	| 408FD456
    movel %a0,%a3@(4)	| 408FD45A
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_5E8	| 408FD45E
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_7B8	| 408FD462
    subaw #56,%sp	| 408FD466
    moveal %sp,%a0	| 408FD46A
    moveb %a1@(40),%a0@(49)	| 408FD46C
    moveb %a1@(41),%a0@(50)	| 408FD472
    clrb %a0@(51)	| 408FD478
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */	| 408FD47C
    _SlotManager	| 408FD47E 408FD47E A-line trap
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_7B4	| 408FD480
    moveb #64,%a0@(50)	| 408FD484
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 408FD48A
    _SlotManager	| 408FD48C 408FD48C A-line trap
    jbne DECL_DRVR_Display_Video_Apple_Sonora_FE	| 408FD48E
    moveb #0x80,%a0@(50)	| 408FD490
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */	| 408FD496
    _SlotManager	| 408FD498 408FD498 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_Sonora_FE	| 408FD49A
    moveal %a0@,%a0	| 408FD49C
    movel %a0,%a3@(12)	| 408FD49E
    addqw #2,%a0	| 408FD4A2
DECL_DRVR_Display_Video_Apple_Sonora_EC:  /* loop: tst */
    tstb %a0@+	| 408FD4A4
    jbne DECL_DRVR_Display_Video_Apple_Sonora_EC	| 408FD4A6
    movel %a0,%d0	| 408FD4A8
    addqw #1,%d0	| 408FD4AA
    bclr #0,%d0	| 408FD4AC
    movel %d0,%a3@(8)	| 408FD4B0
    jbra DECL_DRVR_Display_Video_Apple_Sonora_138	| 408FD4B4
DECL_DRVR_Display_Video_Apple_Sonora_FE:  /* set %d0 */
    moveq #12,%d0	| 408FD4B6
    addiw #256,%d0	| 408FD4B8
    .short  0xA71E	| 408FD4BC 408FD4BC A-line trap
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_7B4	| 408FD4BE
    movel %a0,%a3@(12)	| 408FD4C2
    movel %a0,%a3@(8)	| 408FD4C6
    movew #34,%a0@(2)	| 408FD4CA
    movew #1,%a0@(6)	| 408FD4D0
    movew #256,%a0@(8)	| 408FD4D6
    movew #8,%a0@(10)	| 408FD4DC
    lea %a0@(268),%a0	| 408FD4E2
    movew #255,%d0	| 408FD4E6
DECL_DRVR_Display_Video_Apple_Sonora_132:  /* loop: move */
    moveb %d0,%a0@-	| 408FD4EA
    dbf %d0,DECL_DRVR_Display_Video_Apple_Sonora_132	| 408FD4EC
DECL_DRVR_Display_Video_Apple_Sonora_138:  /* set %a0 */
    moveal %sp,%a0	| 408FD4F0
    clrw %a0@(50)	| 408FD4F2
    clrb %a0@(48)	| 408FD4F6
    movew #1,%a0@(40)	| 408FD4FA
    clrw %a0@(42)	| 408FD500
    clrw %a0@(44)	| 408FD504
    clrw %a0@(46)	| 408FD508
    clrl %a0@(24)	| 408FD50C
    bset #1,%a0@(27)	| 408FD510
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */	| 408FD516
    _SlotManager	| 408FD518 408FD518 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_7AE	| 408FD51A
    moveb #126,%a0@(50)	| 408FD51C
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 408FD522
    _SlotManager	| 408FD524 408FD524 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_7AE	| 408FD526
    moveb %a1@(41),%a0@(50)	| 408FD528
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */	| 408FD52E
    _SlotManager	| 408FD530 408FD530 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_7AE	| 408FD532
    movel %a0@,%a3@(16)	| 408FD534
    moveal %sp,%a0	| 408FD538
    moveb %a1@(40),%a0@(49)	| 408FD53A
    subqw #8,%sp	| 408FD540
    movel %sp,%a0@	| 408FD542
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */	| 408FD544
    _SlotManager	| 408FD546 408FD546 A-line trap
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_7AC	| 408FD548
    moveq #0,%d2	| 408FD54A
    moveb %sp@(5),%d2	| 408FD54C
    moveb %sp@(6),%d1	| 408FD550
    lea %sp@(64),%sp	| 408FD554
    movew %d2,%a3@(32)	| 408FD558
    bfextu %d1,30,2,%d1	| 408FD55C
    moveb %d1,%a3@(34)	| 408FD560
    cmpiw #1,%a3@(32)	| 408FD564
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_1B6	| 408FD56A
    jbra DECL_DRVR_Display_Video_Apple_Sonora_1C2	| 408FD56C
DECL_DRVR_Display_Video_Apple_Sonora_1B6:  /* set bit 13 of %a3@(28) */
    bset #13,%a3@(28)	| 408FD56E
    bset #15,%a3@(28)	| 408FD574
DECL_DRVR_Display_Video_Apple_Sonora_1C2:  /* (408FD57A cmpib #-123,%a1@(41)) */
    cmpib #0x85,%a1@(41)	| 408FD57A 408FD57A cmpib #-123,%a1@(41)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_1D2	| 408FD580
    cmpib #0x86,%a1@(41)	| 408FD582
    jbne DECL_DRVR_Display_Video_Apple_Sonora_1D8	| 408FD588
DECL_DRVR_Display_Video_Apple_Sonora_1D2:  /* set bit 8 of %a3@(28) */
    bset #8,%a3@(28)	| 408FD58A
DECL_DRVR_Display_Video_Apple_Sonora_1D8:  /* clear %d0 */
    moveq #0,%d0	| 408FD590
DECL_DRVR_Display_Video_Apple_TIM_Status_7AA:  /* return */
    rts
DECL_DRVR_Display_Video_Apple_TIM_Status_7AC:  /* add 8 to %sp */
    addqw #8,%sp	| 408FD594
DECL_DRVR_Display_Video_Apple_TIM_Status_7AE:  /* set %a0 */
    moveal %a3@(12),%a0	| 408FD596
    _DisposPtr	| 408FD59A 408FD59A A-line trap
DECL_DRVR_Display_Video_Apple_TIM_Status_7B4:
    lea %sp@(56),%sp	| 408FD59C
DECL_DRVR_Display_Video_Apple_TIM_Status_7B8:  /* set %a0 */
    moveal %a1@(20),%a0	| 408FD5A0
    _DisposHandle	| 408FD5A4 408FD5A4 A-line trap
DECL_DRVR_Display_Video_Apple_TIM_Status_7BE:
    moveq #-23,%d0
    jbra DECL_DRVR_Display_Video_Apple_TIM_Status_7AA
    moveml %a0-%a1,%sp@-	| 408FD5AA
    moveal %a0@(28),%a2	| 408FD5AE
    moveal %a1@(20),%a3	| 408FD5B2
    movel %a3@,%d0	| 408FD5B6
    _StripAddress	| 408FD5B8 408FD5B8 A-line trap
    moveal %d0,%a3	| 408FD5BA
    movew %a0@(26),%d0	| 408FD5BC
    cmpiw #129,%d0	| 408FD5C0
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_69A	| 408FD5C4
    cmpiw #131,%d0	| 408FD5C8
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_7E4	| 408FD5CC
    cmpiw #9,%d0	| 408FD5D0
    jbhi DECL_DRVR_Display_Video_Apple_TIM_Status_80A	| 408FD5D4
    movew %pc@(DECL_DRVR_Display_Video_Apple_TIM_Status_7F6,%d0:w:2),%d0	| 408FD5D6
    jmp %pc@(DECL_DRVR_Display_Video_Apple_TIM_Status_7F6,%d0:w)	| 408FD5DA
DECL_DRVR_Display_Video_Apple_TIM_Status_7F6:  /* from here: orib #24,%a2@- */
    orib #24,%a2@-	| 408FD5DE
    .byte   0x00, 0x48, 0x00, 0xF6, 0x02, 0x62, 0x03, 0x44, 0x03, 0x6C, 0x03, 0x8A, 0x03, 0xF6, 0x04, 0x04	| 408FD5E2
DECL_DRVR_Display_Video_Apple_TIM_Status_80A:  /* result -17 */
    moveq #-17,%d0
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E_2

DECL_DRVR_Display_Video_Apple_Sonora_23E:  /* loop: moveq */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_Sonora_23E_2:  /* restore registers */
    moveml %sp@+,%a0-%a1
    jbra DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_7E
    .short  0x34BC, 0x0080, 0x377C, 0x0080, 0x001E	| 408FD600
    moveq #0,%d1
    moveq #0,%d0
    movew %d0,%a2@(6)
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_F0
    bclr #10,%a3@(28)
    movel %a3@,%a2@(8)
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E
    .short  0x3212	| 408FD626
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_8E
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    tstw %a2@(6)
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    movew %a2@,%d2
    cmpw %a3@(30),%d2
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_D6
    movew %d2,%a3@(30)
    moveml %a4-%fp,%sp@-
    moveal %a3@(8),%a0
    lea %a0@(12),%a4
    addaw %a0@(4),%a4
    moveal %a4,%a5
    moveal %a4,%fp
    cmpiw #1,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_7C
    movew %a0@(10),%d2
    movew %a0@(8),%d0
    addqw #7,%d2
    lsrw #3,%d2
    muluw %d2,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
DECL_DRVR_Display_Video_Apple_Sonora_23E_7C:  /* set %d3 */
    movew %a0@(8),%d3
    moveal %a3@(20),%a0
    addqw #1,%a0
    clrb %a0@(-1)
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8
    movew %d3,%d0
    subqw #1,%d0
    movew %a3@(28),%d2
    lsrw #1,%d3
DECL_DRVR_Display_Video_Apple_Sonora_23E_9A:  /* loop: btst */
    btst #13,%d2
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_A6
    clrb %a0@
    clrb %a0@
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E_AE
DECL_DRVR_Display_Video_Apple_Sonora_23E_A6:  /* set %a0@ */
    moveb %a4@(0x0,%d3:w),%a0@
    moveb %a5@(0x0,%d3:w),%a0@
DECL_DRVR_Display_Video_Apple_Sonora_23E_AE:  /* set %a0@ */
    moveb %fp@(0x0,%d3:w),%a0@
    dbf %d0,DECL_DRVR_Display_Video_Apple_Sonora_23E_9A
    movew %sp@+,%sr
    moveml %sp@+,%a4-%fp
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_F0
    cmpiw #132,%a3@(30)
    jblt DECL_DRVR_Display_Video_Apple_Sonora_23E_D0
    bset #10,%a3@(28)
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E_D6
DECL_DRVR_Display_Video_Apple_Sonora_23E_D0:  /* clear bit 10 of %a3@(28) */
    bclr #10,%a3@(28)
DECL_DRVR_Display_Video_Apple_Sonora_23E_D6:  /* set %a2@(8) */
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E
    .short  0x082B, 0x000A, 0x001C, 0x6600, 0xFF16	| 408FD6D4
DECL_DRVR_Display_Video_Apple_Sonora_23E_E8:  /* loop: tst */
    tstl %a2@
    jbeq DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    moveml %d4-%d7/%a1/%a4-%fp,%sp@-
    movew %a3@(28),%d5
    cmpiw #-1,%a2@(4)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_10E
    bset #9,%d5
    cmpiw #131,%a3@(30)
    jblt DECL_DRVR_Display_Video_Apple_Sonora_23E_10E
    bset #12,%d5
DECL_DRVR_Display_Video_Apple_Sonora_23E_10E:  /* set %a0 */
    moveal %a3@(8),%a0
    movew %a0@(4),%d0
    lea %a0@(0xc,%d0:w),%a4
    moveal %a4,%a5
    moveal %a4,%fp
    movew %a0@(10),%d7
    cmpiw #1,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_13C
    movew %a0@(8),%d0
    movew %d7,%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %d1,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
DECL_DRVR_Display_Video_Apple_Sonora_23E_13C:  /* set %d1 */
    movew %a3@(30),%d1
    subiw #128,%d1
    moveq #0,%d6
    lea %pc@(DECL_DRVR_Display_Video_Apple_Sonora_34),%a0
    lea %a0@(0x0,%d1:w:4),%a0
    moveb %a0@,%d6
    movew %a2@(6),%d3
    cmpw %d6,%d3
    jbhi DECL_DRVR_Display_Video_Apple_Sonora_23E_242
    movew %a2@(4),%d0
    addqw #1,%d0
    jbmi DECL_DRVR_Display_Video_Apple_Sonora_23E_242
    movew %d3,%d4
    addqw #1,%d4
    btst #12,%d5
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_174
    muluw #3,%d4
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E_176
DECL_DRVR_Display_Video_Apple_Sonora_23E_174:  /* from here: aslw #2,%d4 */
    aslw #2,%d4
DECL_DRVR_Display_Video_Apple_Sonora_23E_176:  /* from here: subaw %d4,%sp */
    subaw %d4,%sp
    movel %a3,%d6
    moveal %a0,%a3
    moveal %sp,%a0
    moveal %a2@,%a1
    swap %d4
    movew %a2@(4),%d4
DECL_DRVR_Display_Video_Apple_Sonora_23E_186:  /* loop: move */
    movew %a1@+,%d0
    btst #12,%d5
    jbne DECL_DRVR_Display_Video_Apple_Sonora_23E_1A2
    btst #9,%d5
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_198
    movew %d4,%d0
    addqw #1,%d4
DECL_DRVR_Display_Video_Apple_Sonora_23E_198:  /* from here: muluw %a3@(2),%d0 */
    muluw %a3@(2),%d0
    addb %a3@(1),%d0
    moveb %d0,%a0@+
DECL_DRVR_Display_Video_Apple_Sonora_23E_1A2:  /* set %d0 */
    movew %a1@+,%d0
    movew %a1@+,%d1
    movew %a1@+,%d2
    tstw %d5
    jbpl DECL_DRVR_Display_Video_Apple_Sonora_23E_1CC
    btst #10,%d5
    jbne DECL_DRVR_Display_Video_Apple_Sonora_23E_1CC
    muluw #19660,%d0
    muluw #-26870,%d1
    muluw #7209,%d2
    addl %d1,%d0
    addl %d2,%d0
    bfextu %d0,0,%d7,%d0
    movew %d0,%d1
    movew %d0,%d2
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E_1D8
DECL_DRVR_Display_Video_Apple_Sonora_23E_1CC:  /* from here: bfextu %d0,16,%d7,%d0 */
    bfextu %d0,16,%d7,%d0
    bfextu %d1,16,%d7,%d1
    bfextu %d2,16,%d7,%d2
DECL_DRVR_Display_Video_Apple_Sonora_23E_1D8:  /* test bit 13 of %d5 */
    btst #13,%d5
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_1E4
    clrb %a0@+
    clrb %a0@+
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E_1EC
DECL_DRVR_Display_Video_Apple_Sonora_23E_1E4:  /* set %a0@+ */
    moveb %a4@(0x0,%d0:w),%a0@+
    moveb %a5@(0x0,%d1:w),%a0@+
DECL_DRVR_Display_Video_Apple_Sonora_23E_1EC:  /* set %a0@+ */
    moveb %fp@(0x0,%d2:w),%a0@+
    dbf %d3,DECL_DRVR_Display_Video_Apple_Sonora_23E_186
    swap %d4
    moveal %d6,%a3
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8
    movew %a2@(6),%d3
    moveal %a3@(20),%a3
    lea %a3@(1),%a3
    lea %sp@(2),%a0
    btst #12,%d5
    jbne DECL_DRVR_Display_Video_Apple_Sonora_23E_224
DECL_DRVR_Display_Video_Apple_Sonora_23E_214:  /* loop: move */
    moveb %a0@+,%a3@(-1)
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    dbf %d3,DECL_DRVR_Display_Video_Apple_Sonora_23E_214
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E_236
DECL_DRVR_Display_Video_Apple_Sonora_23E_224:  /* set %d0 */
    movew %a2@(4),%d0
    moveb %d0,%a3@(-1)
DECL_DRVR_Display_Video_Apple_Sonora_23E_22C:  /* loop: move */
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    dbf %d3,DECL_DRVR_Display_Video_Apple_Sonora_23E_22C
DECL_DRVR_Display_Video_Apple_Sonora_23E_236:  /* set %sr */
    movew %sp@+,%sr
    addaw %d4,%sp
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E
DECL_DRVR_Display_Video_Apple_Sonora_23E_242:  /* restore registers */
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    jbra DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    movel %a2@,%d0
    beqw DECL_DRVR_Display_Video_Apple_Sonora_23E_242_B2
    moveal %d0,%a2
    tstw %a2@
    bnew DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    tstw %a2@(2)
    beqs DECL_DRVR_Display_Video_Apple_Sonora_23E_242_3C
    cmpiw #34,%a2@(2)
    bnew DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    tstw %a2@(4)
    beqs DECL_DRVR_Display_Video_Apple_Sonora_23E_242_3C
    movew %a2@(12),%d0
    cmpw %a3@(32),%d0
    beqs DECL_DRVR_Display_Video_Apple_Sonora_23E_242_3C
    addqw #1,%d0
    bnew DECL_DRVR_Display_Video_Apple_TIM_Status_80A
DECL_DRVR_Display_Video_Apple_Sonora_23E_242_3C:
    moveal %a3@(8),%a0
    movew %a2@(4),%d0
    cmpw %a0@(4),%d0
    bnes DECL_DRVR_Display_Video_Apple_Sonora_23E_242_60
    movew %a2@(6),%d0
    cmpw %a0@(6),%d0
    beqs DECL_DRVR_Display_Video_Apple_Sonora_23E_242_90
    bgts DECL_DRVR_Display_Video_Apple_Sonora_23E_242_60
    moveal %a3@(12),%a0
    _DisposPtr
    clrl %a3@(12)
DECL_DRVR_Display_Video_Apple_Sonora_23E_242_60:
    moveq #0,%d0
    movew %a2@(8),%d0
    muluw %a2@(6),%d0
    addw %a2@(4),%d0
    addiw #12,%d0
    .short  0xA51E	| 408FD8AA _NewPtr (flags 0x0500)
    bnew DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    movel %a3@(12),%d0
    movel %a0,%a3@(8)
    tstl %d0
    beqs DECL_DRVR_Display_Video_Apple_Sonora_23E_242_90
    moveal %d0,%a0
    _DisposPtr
    moveal %a3@(8),%a0
    movel %a0,%a3@(12)
DECL_DRVR_Display_Video_Apple_Sonora_23E_242_90:
    movew %a2@(6),%d0
    movew %a2@(4),%d1
    movew %a2@(8),%d2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    muluw %d0,%d2
    addw %d1,%d2
    subqw #1,%d2
DECL_DRVR_Display_Video_Apple_Sonora_23E_242_A8:
    moveb %a2@+,%d0
    moveb %d0,%a0@+
    dbf %d2,DECL_DRVR_Display_Video_Apple_Sonora_23E_242_A8
    bras DECL_DRVR_Display_Video_Apple_Sonora_23E_310_C
DECL_DRVR_Display_Video_Apple_Sonora_23E_242_B2:
    moveal %a3@(8),%a0
    movew %a0@(4),%d0
    movew %a0@(6),%d2
    subqw #1,%d2
    movew %a0@(8),%d3
    subqw #1,%d3
    lea %a0@(12),%a0
    addaw %d0,%a0
DECL_DRVR_Display_Video_Apple_Sonora_23E_30E:  /* loop: move */
    movew %d3,%d0
DECL_DRVR_Display_Video_Apple_Sonora_23E_310:  /* loop: move */
    moveb %d0,%a0@
    notb %a0@+
    dbf %d0,DECL_DRVR_Display_Video_Apple_Sonora_23E_310
    dbf %d2,DECL_DRVR_Display_Video_Apple_Sonora_23E_30E
DECL_DRVR_Display_Video_Apple_Sonora_23E_310_C:
    btst #10,%a3@(28)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_328
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_184
DECL_DRVR_Display_Video_Apple_Sonora_23E_328:  /* continue at DECL_DRVR_Display_Video_Apple_Sonora_23E */
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E
    .short  0x322B, 0x001E, 0x6100, 0x050C, 0x6600, 0xFCC6, 0x302A, 0x0006	| 408FD922
    .short  0x6600, 0xFCBE, 0x6100, 0x058E	| 408FD932
    btst #10,%a3@(28)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_350
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_184
DECL_DRVR_Display_Video_Apple_Sonora_23E_350:  /* continue at DECL_DRVR_Display_Video_Apple_Sonora_23E */
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E
    btst #13,%a3@(28)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_23E_360
    moveb #1,%a2@
DECL_DRVR_Display_Video_Apple_Sonora_23E_360:  /* clear %d1 */
    moveq #0,%d1
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_5A6
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E

/* subroutine (11 instructions): calls DECL_DRVR_Display_Video_Apple_Sonora_5A6, DECL_DRVR_Display_Video_Apple_Sonora_5E8, DECL_DRVR_Display_Video_Apple_Sonora_5C6 (mechanical summary) */
DECL_DRVR_Display_Video_Apple_Sonora_5A6:
    moveb %a2@,%d0
    bfins %d0,%a3@(28),%d1,1
    rts
    moveq #1,%d1
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_5A6
    jbne DECL_DRVR_Display_Video_Apple_Sonora_5A6_1A
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_5E8
    jbne DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E
DECL_DRVR_Display_Video_Apple_Sonora_5A6_1A:  /* call DECL_DRVR_Display_Video_Apple_Sonora_5C6 */
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_5C6
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E

/* subroutine (10 instructions): traps SIntRemove; calls DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8 (mechanical summary) */
DECL_DRVR_Display_Video_Apple_Sonora_5C6:
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8
    moveal %a3@(24),%a0
    addal #155648,%a0
    moveb #64,%a0@(18)
    movew %sp@+,%sr
    clrw %d0
    moveal %a3@(4),%a0
    _SIntRemove
    rts

/* subroutine (180 instructions): traps SIntInstall, SlotManager, EgretDispatch, StripAddress, DisposPtr, DisposHandle; calls DECL_DRVR_Display_Video_Apple_Sonora_5C6 (mechanical summary) */
DECL_DRVR_Display_Video_Apple_Sonora_5E8:
    moveal %a3@(4),%a0
    lea %pc@(DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_184_6A),%a2
    movew #6,%a0@(4)
    movel %a2,%a0@(8)
    movel %a3,%a0@(12)
    clrw %d0
    _SIntInstall
    jbne DECL_DRVR_Display_Video_Apple_Sonora_5E8_32
    movel %a0,%sp@-
    moveal %a3@(24),%a0
    addal #155648,%a0
    moveb #0xc0,%a0@(18)
    moveal %sp@+,%a0
    cmpw %d0,%d0
DECL_DRVR_Display_Video_Apple_Sonora_5E8_32:  /* return */
    rts
    btst #10,%a3@(28)
    jbeq DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E_E8
    .byte   0x9E, 0xFC, 0x00, 0x38, 0x20, 0x4F, 0x11, 0x69, 0x00, 0x28, 0x00, 0x31, 0x42, 0x28, 0x00, 0x33	| 408FD9E2
    .byte   0x51, 0x4F, 0x20, 0x8F, 0x70, 0x11, 0xA0, 0x6E, 0x11, 0x52, 0x00, 0x32, 0x42, 0xA8, 0x00, 0x18	| 408FD9F2
    .byte   0x00, 0x28, 0x00, 0x03, 0x00, 0x1B, 0x70, 0x0B, 0xA0, 0x6E, 0x66, 0x3C, 0x30, 0x28, 0x00, 0x28	| 408FDA02
    .byte   0x0C, 0x40, 0x00, 0x03, 0x66, 0x32, 0x30, 0x28, 0x00, 0x2A, 0x0C, 0x40, 0x00, 0x01, 0x66, 0x28	| 408FDA12
    .byte   0x30, 0x28, 0x00, 0x2C, 0x0C, 0x40, 0x00, 0x01, 0x66, 0x1E, 0x30, 0x28, 0x00, 0x2E, 0x0C, 0x40	| 408FDA22
    .byte   0x00, 0x22, 0x66, 0x14, 0x1F, 0x52, 0x00, 0x03, 0x21, 0x4F, 0x00, 0x04, 0x70, 0x12, 0xA0, 0x6E	| 408FDA32
    .byte   0x4F, 0xEF, 0x00, 0x40, 0x60, 0x00, 0xFB, 0xAE, 0x4F, 0xEF, 0x00, 0x40, 0x60, 0x00, 0xFB, 0xA2	| 408FDA42
DECL_DRVR_Display_Video_Apple_Sonora_69A:  /* test bit 8 of %a3@(28) */
    btst #8,%a3@(28)	| 408FDA52
    jbne DECL_DRVR_Display_Video_Apple_Sonora_23E	| 408FDA58
    tstb %a2@	| 408FDA5C
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_6BC	| 408FDA5E
    cmpib #0x85,%a1@(41)	| 408FDA60
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_6D0	| 408FDA66
    cmpib #0x86,%a1@(41)	| 408FDA68
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_6D6	| 408FDA6E
    jbra DECL_DRVR_Display_Video_Apple_TIM_Status_80A	| 408FDA70
DECL_DRVR_Display_Video_Apple_Sonora_6BC:  /* (408FDA74 cmpib #-125,%a1@(41)) */
    cmpib #0x83,%a1@(41)	| 408FDA74 408FDA74 cmpib #-125,%a1@(41)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_6DC	| 408FDA7A
    cmpib #0x84,%a1@(41)	| 408FDA7C
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_6E2	| 408FDA82
    jbra DECL_DRVR_Display_Video_Apple_TIM_Status_80A	| 408FDA84
DECL_DRVR_Display_Video_Apple_Sonora_6D0:  /* (408FDA88 moveb #-125,%d0) */
    moveb #0x83,%d0	| 408FDA88 408FDA88 moveb #-125,%d0
    jbra DECL_DRVR_Display_Video_Apple_Sonora_6E6	| 408FDA8C
DECL_DRVR_Display_Video_Apple_Sonora_6D6:  /* (408FDA8E moveb #-124,%d0) */
    moveb #0x84,%d0	| 408FDA8E 408FDA8E moveb #-124,%d0
    jbra DECL_DRVR_Display_Video_Apple_Sonora_6E6	| 408FDA92
DECL_DRVR_Display_Video_Apple_Sonora_6DC:  /* (408FDA94 moveb #-123,%d0) */
    moveb #0x85,%d0	| 408FDA94 408FDA94 moveb #-123,%d0
    jbra DECL_DRVR_Display_Video_Apple_Sonora_6E6	| 408FDA98
DECL_DRVR_Display_Video_Apple_Sonora_6E2:  /* (408FDA9A moveb #-122,%d0) */
    moveb #0x86,%d0	| 408FDA9A 408FDA9A moveb #-122,%d0
DECL_DRVR_Display_Video_Apple_Sonora_6E6:
    moveb %a1@(41),%d1	| 408FDA9E
    moveb %d0,%a1@(41)	| 408FDAA2
    subaw #56,%sp	| 408FDAA6
    moveal %sp,%a0	| 408FDAAA
    clrb %a0@(49)	| 408FDAAC
    clrb %a0@(51)	| 408FDAB0
    moveb %d1,%a0@(50)	| 408FDAB4
    movel #1,%a0@(24)	| 408FDAB8
    moveq #9,%d0	/* _SlotManager 9: SETSRSRCSTATE, sSetsRsrcState */	| 408FDAC0
    _SlotManager	| 408FDAC2 408FDAC2 A-line trap
    moveb %a1@(41),%a0@(50)	| 408FDAC4
    clrl %a0@(24)	| 408FDACA
    moveq #9,%d0	/* _SlotManager 9: SETSRSRCSTATE, sSetsRsrcState */	| 408FDACE
    _SlotManager	| 408FDAD0 408FDAD0 A-line trap
    clrw %a0@(50)	| 408FDAD2
    clrb %a0@(48)	| 408FDAD6
    movew #1,%a0@(40)	| 408FDADA
    clrw %a0@(42)	| 408FDAE0
    clrw %a0@(44)	| 408FDAE4
    clrw %a0@(46)	| 408FDAE8
    clrl %a0@(24)	| 408FDAEC
    bset #1,%a0@(27)	| 408FDAF0
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */	| 408FDAF6
    _SlotManager	| 408FDAF8 408FDAF8 A-line trap
    moveb #126,%a0@(50)	| 408FDAFA
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 408FDB00
    _SlotManager	| 408FDB02 408FDB02 A-line trap
    moveb %a1@(41),%a0@(50)	| 408FDB04
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */	| 408FDB0A
    _SlotManager	| 408FDB0C 408FDB0C A-line trap
    movel %a0@,%a3@(16)	| 408FDB0E
    lea %sp@(56),%sp	| 408FDB12
    moveml %a4-%fp,%sp@-	| 408FDB16
    moveal %a3@(16),%a4	| 408FDB1A
    moveal %a4,%a5	| 408FDB1E
    moveal 0xdd8,%fp	| 408FDB20
    addal %fp@,%fp	| 408FDB24
    moveal %fp@(8),%fp	| 408FDB26
    addal #163840,%fp	| 408FDB2A
    bset #7,%fp@	| 408FDB30
    addaw #-8192,%fp	| 408FDB34
    moveb %fp@(4),%d0	| 408FDB38
    addaw #8192,%fp	| 408FDB3C
    cmpib #4,%d0	| 408FDB40
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_794	| 408FDB44
    cmpib #5,%d0	| 408FDB46
    jbne DECL_DRVR_Display_Video_Apple_Sonora_796	| 408FDB4A
DECL_DRVR_Display_Video_Apple_Sonora_794:  /* add 4 to %a5 */
    addqw #4,%a5	| 408FDB4C
DECL_DRVR_Display_Video_Apple_Sonora_796:  /* clear %d0 */
    moveq #0,%d0	| 408FDB4E
    moveb %a5@,%d0	| 408FDB50
    lslw #7,%d0	| 408FDB52
    moveb %a5@(1),%d1	| 408FDB54
    orb %d1,%d0	| 408FDB58
    moveb %a5@(2),%d1	| 408FDB5A
    lslw #2,%d0	| 408FDB5E
    orb %d1,%d0	| 408FDB60
    swap %d0	| 408FDB62
    orib #87,%d0	| 408FDB64
    subaw #20,%sp	| 408FDB68
    moveal %sp,%a0	| 408FDB6C
    movew #270,%a0@	| 408FDB6E
    movel %d0,%a0@(2)	| 408FDB72
    movew #4,%a0@(6)	| 408FDB76
    clrw %a0@(14)	| 408FDB7C
    clrl %a0@(16)	| 408FDB80
    _EgretDispatch	| 408FDB84 408FDB84 A-line trap
    lea %sp@(20),%sp	| 408FDB86
    moveb %a4@(8),%d0	| 408FDB8A
    bclr #7,%d0	| 408FDB8E
    moveb %d0,%fp@	| 408FDB92
    moveml %sp@+,%a4-%fp	| 408FDB94
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E	| 408FDB98
DECL_DRVR_Display_Video_Apple_Sonora_7E4:  /* from here: subaw #56,%sp */
    subaw #56,%sp	| 408FDB9C
    moveal %sp,%a0	| 408FDBA0
    moveb %a1@(40),%a0@(49)	| 408FDBA2
    clrb %a0@(51)	| 408FDBA8
    subqw #8,%sp	| 408FDBAC
    movel %sp,%a0@	| 408FDBAE
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */	| 408FDBB0
    _SlotManager	| 408FDBB2 408FDBB2 A-line trap
    moveb %a2@(1),%d0	| 408FDBB4
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_81C	| 408FDBB8
    cmpib #6,%d0	| 408FDBBA
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_810	| 408FDBBE
    cmpib #7,%d0	| 408FDBC0
    beqs DECL_DRVR_Display_Video_Apple_Sonora_81C
    jbra DECL_DRVR_Display_Video_Apple_Sonora_5E8_290
DECL_DRVR_Display_Video_Apple_Sonora_810:  /* test #3,%a2@ */
    cmpib #3,%a2@	| 408FDBC8
    jbne DECL_DRVR_Display_Video_Apple_Sonora_5E8_290	| 408FDBCC
    moveb #6,%d1	| 408FDBCE
    jbra DECL_DRVR_Display_Video_Apple_Sonora_858	| 408FDBD2
DECL_DRVR_Display_Video_Apple_Sonora_81C:  /* set %d1 */
    moveb %a2@,%d1	| 408FDBD4
    cmpib #7,%d1	| 408FDBD6
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_864	| 408FDBDA
    cmpib #63,%d1	| 408FDBDC
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_864	| 408FDBE0
    lea %pc@(DECL_DRVR_Display_Video_Apple_Sonora_5C),%a1	| 408FDBE2
    movew %a1@+,%d0	| 408FDBE6
DECL_DRVR_Display_Video_Apple_Sonora_830:  /* loop: move */
    moveb %a1@+,%d1	| 408FDBE8
    cmpb %a2@,%d1	| 408FDBEA
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_83C	| 408FDBEC
    dbf %d0,DECL_DRVR_Display_Video_Apple_Sonora_830	| 408FDBEE
    jbra DECL_DRVR_Display_Video_Apple_Sonora_5E8_290	| 408FDBF2
DECL_DRVR_Display_Video_Apple_Sonora_83C:  /* test %a2@(1) */
    tstb %a2@(1)	| 408FDBF4
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_858	| 408FDBF8
    cmpib #23,%d1	| 408FDBFA
    jbne DECL_DRVR_Display_Video_Apple_Sonora_84E	| 408FDBFE
    moveb #8,%d1	| 408FDC00
    jbra DECL_DRVR_Display_Video_Apple_Sonora_858	| 408FDC04
DECL_DRVR_Display_Video_Apple_Sonora_84E:  /* test #45,%d1 */
    cmpib #45,%d1	| 408FDC06
    jbne DECL_DRVR_Display_Video_Apple_Sonora_858	| 408FDC0A
    moveb #10,%d1	| 408FDC0C
DECL_DRVR_Display_Video_Apple_Sonora_858:  /* set %sp@(7) */
    moveb %d1,%sp@(7)	| 408FDC10
    orib #64,%sp@(7)	| 408FDC14
    jbra DECL_DRVR_Display_Video_Apple_Sonora_868	| 408FDC1A
DECL_DRVR_Display_Video_Apple_Sonora_864:  /* clear %sp@(7) */
    clrb %sp@(7)	| 408FDC1C
DECL_DRVR_Display_Video_Apple_Sonora_868:  /* set %a0@(4) */
    movel %sp,%a0@(4)	| 408FDC20
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */	| 408FDC24
    _SlotManager	| 408FDC26 408FDC26 A-line trap
    lea %sp@(64),%sp	| 408FDC28
    jbra DECL_DRVR_Display_Video_Apple_Sonora_23E	| 408FDC2C
DECL_DRVR_Display_Video_Apple_Sonora_5E8_290:  /* address %sp@(64) */
    lea %sp@(64),%sp
    jbra DECL_DRVR_Display_Video_Apple_TIM_Status_80A
    moveal %a1@(20),%a3	| 408FDC38
    movel %a3@,%d0	| 408FDC3C
    _StripAddress	| 408FDC3E 408FDC3E A-line trap
    moveal %d0,%a3	| 408FDC40
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_5C6	| 408FDC42
    moveal %a3@(4),%a0	| 408FDC46
    _DisposPtr	| 408FDC4A 408FDC4A A-line trap
    moveal %a3@(12),%a0	| 408FDC4C
    _DisposPtr	| 408FDC50 408FDC50 A-line trap
    moveal %a3@(16),%a0	| 408FDC52
    _DisposPtr	| 408FDC56 408FDC56 A-line trap
    moveal %a1@(20),%a0	| 408FDC58
    _DisposHandle	| 408FDC5C 408FDC5C A-line trap
    moveq #0,%d0	| 408FDC5E
    rts	| 408FDC60

/* Status: find csCode in the status table and call its routine (out of range: StatusBadCode) (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_Status:
    moveml %a0-%a1,%sp@-
    moveal %a0@(28),%a2
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    movew %a0@(26),%d0
    cmpiw #131,%d0
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_24
    cmpiw #9,%d0
    jbhi DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode
    movew %pc@(DECL_DRVR_Display_Video_Apple_Sonora_StatusTable,%d0:w:2),%d0
    jmp %pc@(DECL_DRVR_Display_Video_Apple_Sonora_StatusTable,%d0:w)

/* status table: routine offsets by csCode (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_StatusTable:
    .short  DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDC8E
    .short  DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDC90
    .short  DECL_DRVR_Display_Video_Apple_Sonora_GetMode-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDC92
    .short  DECL_DRVR_Display_Video_Apple_Sonora_GetEntries-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDC94
    .short  DECL_DRVR_Display_Video_Apple_Sonora_GetPages-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDC96
    .short  DECL_DRVR_Display_Video_Apple_Sonora_GetBaseAddr-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDC98
    .short  DECL_DRVR_Display_Video_Apple_Sonora_GetGray-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDC9A
    .short  DECL_DRVR_Display_Video_Apple_Sonora_GetInterrupt-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDC9C
    .short  DECL_DRVR_Display_Video_Apple_Sonora_GetGamma-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDC9E
    .short  DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode-DECL_DRVR_Display_Video_Apple_Sonora_StatusTable	| 408FDCA0

/* unknown status csCode: statusErr (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode:
    moveq #-18,%d0
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_6
DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_4:  /* loop: moveq */
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_6:  /* restore registers */
    moveml %sp@+,%a0-%a1
    jbra DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_7E

/* Status csCode 2, cscGetMode: current mode, page and base address (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_GetMode:
    movew %a3@(30),%a2@
    clrw %a2@(6)
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_4

/* Status csCode 3, cscGetEntries: read colour table entries (from the CLUT) (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_GetEntries:
    moveml %d4-%d6,%sp@-
    tstl %sp@-
    movel %a2@,%d0
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_9E
    _StripAddress
    movel %d0,%sp@
    movew %a3@(30),%d1
    subiw #128,%d1
    moveq #0,%d3
    lea %pc@(DECL_DRVR_Display_Video_Apple_Sonora_34),%a0
    lea %a0@(0x0,%d1:w:4),%a0
    moveb %a0@,%d3
    movew %a2@(6),%d4
    jbmi DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_9E
    cmpw %d3,%d4
    jbhi DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_9E
    movew %d4,%d2
    moveb %a0@(1),%d4	| 408FDCEE
    movew %a0@(2),%d5
    movew %d2,%d6
    cmpiw #-1,%a2@(4)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_54
    movew %d2,%d1
    addw %a2@(4),%d2
    moveal %sp@,%a0
DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_4A:  /* loop: move */
    movew %d2,%a0@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_4A
DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_54:  /* set %a0 */
    moveal %sp@+,%a0
    moveal %a3@(20),%a2
    addqw #1,%a2
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8
DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_62:  /* loop: move */
    movew %a0@,%d1
    cmpw %d3,%d1
    jbhi DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_8E
    muluw %d5,%d1
    addb %d4,%d1
    moveb %d1,%a2@(-1)
    moveb %a2@,%d1
    moveb %d1,%a0@(2)
    moveb %d1,%a0@(3)
    moveb %a2@,%d1
    moveb %d1,%a0@(4)
    moveb %d1,%a0@(5)
    moveb %a2@,%d1
    moveb %d1,%a0@(6)
    moveb %d1,%a0@(7)
DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_8E:  /* add 8 to %a0 */
    addqw #8,%a0
    dbf %d6,DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_62
    movew %sp@+,%sr
    moveml %sp@+,%d4-%d6
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_Sonora_GetEntries_9E:  /* test %sp@+ */
    tstl %sp@+
    moveml %sp@+,%d4-%d6
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode

/* Status csCode 4, cscGetPages: number of video pages for a mode (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_GetPages:
    movew %a2@,%d1
    movew %d1,%d2
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_8E
    jbne DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode
    movew #1,%a2@(6)
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_4

/* Status csCode 5, cscGetBaseAddr: base address of a page (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_GetBaseAddr:
    tstw %a2@(6)
    jbne DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode
    movel %a3@,%a2@(8)
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_4

/* Status csCode 6, cscGetGray: whether luminance mapping (gray) is on (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_GetGray:
    moveq #0,%d1
DECL_DRVR_Display_Video_Apple_Sonora_GetGray_2:  /* loop: bfextu */
    bfextu %a3@(28),%d1,1,%d0
    moveb %d0,%a2@
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_4

/* Status csCode 7, cscGetInterrupt: whether the VBL interrupt is enabled (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_GetInterrupt:
    moveq #1,%d1
    jbra DECL_DRVR_Display_Video_Apple_Sonora_GetGray_2

/* Status csCode 8, cscGetGamma: the current gamma table (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_GetGamma:
    movel %a3@(8),%a2@
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_4

/* Status csCode 9, cscGetDefaultMode: the default mode (from slot PRAM) (Display Video Apple Sonora). */
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode:
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
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_4
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_24:  /* from here: subaw #56,%sp */
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    .short  0x422A	| 408FDDE2
    .short  0x0001, 0x102F	| orib #47,%d1
    .short  0x0007, 0x0200	| orib #0,%d7
    oriw #26118,%d0
    moveb #7,%a2@
    jbra DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_76
    moveb %sp@(7),%d0
    andib #63,%d0
    cmpib #8,%d0
    bnes DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_24_40
    moveb #23,%d0
    bras DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_24_4A
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_24_40:
    cmpib #10,%d0
    bnes DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_24_50
    moveb #45,%d0
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_24_4A:
    moveb #7,%a2@(1)
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_24_50:
    moveb %d0,%a2@
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_76:  /* address %sp@(64) */
    lea %sp@(64),%sp
    jbra DECL_DRVR_Display_Video_Apple_Sonora_StatusBadCode_4

DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_7E:  /* test bit 9 of %a0@(6) */
    btst #9,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_7E_A
    rts
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_7E_A:  /* set %sp@- */
    movel JIODone,%sp@-
    rts

/* subroutine (13 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_8E:
    moveml %d0/%a0,%sp@-
    subiw #128,%d1
    jblt DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_8E_24
    moveal %a3@(16),%a0
    lea %a0@(10),%a0
    moveb %a3@(34),%d0
    moveb %a0@(0x0,%d0:w),%d0
    subiw #128,%d0
    cmpw %d0,%d1
    jbgt DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_8E_24
    cmpw %d1,%d1
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_8E_24:  /* restore registers, return */
    moveml %sp@+,%d0/%a0
    rts

/* subroutine (20 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8:
    movel %a0,%sp@-
    movel %d0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8_16
    oriw #512,%sr
    andiw #-1281,%sr
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8_16:  /* test %sp@+ */
    tstw %sp@+
    moveal %a3@(24),%a0
    addal #155648,%a0
    moveb #64,%a0@(2)
    addqw #2,%a0
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8_2A:  /* loop: move */
    moveb %a0@,%d0
    btst #6,%d0
    jbne DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8_2A
    movel %sp@+,%d0
    moveal %sp@+,%a0
    rts

/* subroutine (14 instructions): calls DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8 (mechanical summary) */
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_F0:
    moveml %d0-%d1/%a0,%sp@-
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8
    moveal %a3@(24),%a0
    addal #163840,%a0
    moveb %d1,%a0@(1)
    moveal %a3@(20),%a0
    moveb %a0@(2),%d0
    andib #0xf8,%d0
    orb %d1,%d0
    moveb %d0,%a0@(2)
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d1/%a0
    rts

/* subroutine (29 instructions): traps SwapMMUMode (mechanical summary) */
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120:
    moveml %d0-%d5/%a1-%a2,%sp@-
    moveal %a3@,%a2
    moveb %a1@(41),%d5
    cmpib #0x85,%d5
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_16
    cmpib #0x86,%d5
    jbne DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_1C
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_16:  /* test %d1 */
    tstb %d1
    jbne DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_1C
    clrb %d5
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_1C:  /* set %a1 */
    moveal %a3@(16),%a1
    movew %a1@(14),%d4
    lea %a1@(16),%a1
    movew %a1@(0x0,%d1:w:2),%d3
    lea %pc@(DECL_DRVR_Display_Video_Apple_Sonora_48),%a1
    movel %a1@(0x0,%d1:w:4),%d2
    moveq #1,%d0
    _SwapMMUMode
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_38:  /* loop: move */
    movel %d3,%d1
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_3A:  /* loop: move */
    movel %d2,%a2@+
    dbf %d1,DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_3A
    tstb %d5
    jbne DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_46
    movew %d2,%a2@+
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_46:  /* set up and call _SwapMMUMode */
    notl %d2
    dbf %d4,DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_120_38
    _SwapMMUMode
    moveml %sp@+,%d0-%d5/%a1-%a2
    rts

/* subroutine (8 instructions) (mechanical summary) */
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_174:
    movel %d0,%sp@-
    moveq #0,%d0
    movew %d1,%d0
    lslw #3,%d1
    lsrw #2,%d0
    orw %d0,%d1
    movel %sp@+,%d0
    rts

/* subroutine (86 instructions): traps MemoryDispatch; calls DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8, DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_174, DECL_DRVR_ENET_GetInfo_2B8, DECL_DRVR_ENET_GetInfo_23A, DECL_DRVR_ENET_GetInfo_276; low memory ENET, Ethernet, Driver, Apple, Computer (mechanical summary) */
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_184:
    moveml %d0-%d2/%a0/%a4-%fp,%sp@-
    moveal %a3@(8),%a0
    movew %a0@(4),%d0
    lea %a0@(12),%a4
    addaw %d0,%a4
    moveal %a4,%a5
    moveal %a4,%fp
    cmpiw #1,%a0@(6)
    jbeq DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_184_30
    movew %a0@(10),%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %a0@(8),%d1
    addaw %d1,%a5
    addaw %d1,%fp
    addaw %d1,%fp
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_184_30:  /* set %d2 */
    movew %a0@(8),%d2
    subqw #1,%d2
    moveal %a3@(20),%a0
    addqw #1,%a0
    clrb %a0@(-1)
    movew #31,%d2
    movew %sr,%sp@-
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_B8
    moveq #0,%d0
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_184_4C:  /* loop: move */
    movew %d0,%d1
    jbsr DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_174
    moveb %a4@(0x0,%d1:w),%a0@
    moveb %a5@(0x0,%d1:w),%a0@
    moveb %fp@(0x0,%d1:w),%a0@
    addqw #1,%d0
    dbf %d2,DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_184_4C
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d2/%a0/%a4-%fp
    rts
DECL_DRVR_Display_Video_Apple_Sonora_GetDefaultMode_184_6A:  /* set %a0 */
    moveal %a1@(24),%a0
    addal #155648,%a0
    moveb #64,%a0@(2)
    moveq #0,%d0
    jsr @(JVBLTask,%za0)@(0)	| 408FDFA6
    moveq #1,%d0
    rts

/* Driver (sBlock: length, then the driver: header with the routine offsets, name, code) for ENET. */
DECL_DRVR_ENET:         /* .ENET driver header: size 0x181E; flags; offsets of Open (0x68), Prime and Status (0xB06), Control (0x4F0), Close (0xAAE); name */
    .long   0x0000181E, 0x44000000, 0x00000000, 0x00680B06	| 408FDFB0
    .byte   0x04, 0xF0, 0x0B, 0x06, 0x0A, 0xAE	| 408FDFC0
    .byte   5	/* 408FDFC6 Pascal string length */
    .ascii  ".ENET"	| 408FDFC7
DECL_DRVR_ENET_1C:      /* version and copyright strings. Open (from the Gestalt call): 'vm  ' present: flag bit 5 in the DCE's storage field, DCE locked */
    .byte   0x01, 0x04, 0x80, 0x01	| 408FDFCC
    .byte   0x00, 0x00, 0x07	| 408FDFD0
    .ascii  "1.0.4f1AQuadra Ethernet Driver v1.0.4f1; "	| 408FDFD3
    .byte   0xA9	| 408FDFFC
    .ascii  " Apple Computer, Inc. 1990-1992NV\000\000"
    movel %a1,%sp@-
    movel #1986863136,%d0
    .short  0xA1AD	| 408FE028 _Gestalt (flags 0x0100)
    bnes DECL_DRVR_ENET_8C
    movel %a0,%d0
    beqs DECL_DRVR_ENET_8C
    bset #5,%a1@(20)
    bset #0,%a1@(5)
DECL_DRVR_ENET_8C:      /* the globals: 590 bytes, 160 fewer without VM */
    lea %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a3
    movel #590,%d0
    btst #5,%a1@(20)
    bnes DECL_DRVR_ENET_A4
    subil #160,%d0
DECL_DRVR_ENET_A4:      /* new pointer (E_GetInfo_2D0 points to it): +0 DCE, +22 largest packet 1500, +362 _BlockMove's address, +384 machine ('mach'); the 'ecfg' resource for the machine: System file, else ROM */
    .short  0xA71E	| 408FE054 _NewPtr (flags 0x0700)
    bnew DECL_DRVR_ENET_3E6
    movel %a0,%a3@
    moveal %a0,%a2
    moveb %pc@(DECL_DRVR_ENET_1C),%a1@(7)
    movel %a1,%d0
    _StripAddress
    movel %d0,%a2@
    movew #-24530,%d0
    .short  0xA146	| 408FE06E _GetTrapAddress (flags 0x0100)
    movel %a0,%a2@(362)
    movew #1500,%a2@(22)
    movel #1835098984,%d0
    .short  0xA1AD	| 408FE080 _Gestalt (flags 0x0100)
    movel %a0,%d0
    movew %d0,%a2@(384)
    subqw #4,%sp
    movel #1701013095,%sp@-
    movew %d0,%sp@-
    _GetResource
    movel %sp@+,%d0
    bnes DECL_DRVR_ENET_106
    subqw #4,%sp
    movel #1701013095,%sp@-
    movew %a2@(384),%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@+,%d0
    bnes DECL_DRVR_ENET_106
    moveq #-1,%d0
    braw DECL_DRVR_ENET_3E6
DECL_DRVR_ENET_106:     /* copy 36 bytes of it to +394; +420: an override Ethernet address */
    moveal %d0,%a3
    moveal %a3@,%a0
    lea %a2@(394),%a1
    moveq #36,%d0
    _BlockMove
    movel %a3,%sp@-
    _ReleaseResource
    lea %a2@(420),%a0
    tstl %a0@
    bnes DECL_DRVR_ENET_124
    tstw %a0@(4)
    beqs DECL_DRVR_ENET_132
DECL_DRVR_ENET_124:     /* valid (even first byte): to +4 */
    btst #0,%a0@
    bnes DECL_DRVR_ENET_132
    movel %a0@+,%a2@(4)
    movew %a0@+,%a2@(8)
DECL_DRVR_ENET_132:     /* receive descriptors (d2) and transmit buffers (d3): 8 each, or from the 'ecfg' */
    moveq #8,%d2
    movel %d2,%d3
    movew %a2@(428),%d0
    beqs DECL_DRVR_ENET_13E
    movew %d0,%d2
DECL_DRVR_ENET_13E:     /* with VM, the 'ecfg' value is not used */
    btst #5,%a2@(0,%za0)@(0x14)	| 408FE0EE
    bnes DECL_DRVR_ENET_150
    movew %a2@(426),%d0
    beqs DECL_DRVR_ENET_150
    movew %d0,%d3
DECL_DRVR_ENET_150:     /* the memory for both: fewer buffers until it fits; below 2: error */
    cmpiw #2,%d3
    bcss DECL_DRVR_ENET_188
    movel #3428,%d0
    moveq #28,%d1
    muluw %d3,%d1
    addl %d1,%d0
    lsll #1,%d0
    movel #1518,%d1
    muluw %d3,%d1
    addl %d1,%d0
    movel %d0,%d4
    movel %d2,%d1
    muluw #1536,%d1
    addl %d1,%d0
    movel %d0,%d5
    .short  0xA71E	| 408FE12A _NewPtr (flags 0x0700)
    beqs DECL_DRVR_ENET_190
    subql #1,%d2
    bhis DECL_DRVR_ENET_150
    moveq #1,%d2
    subql #1,%d3
    bhis DECL_DRVR_ENET_150
DECL_DRVR_ENET_188:     /* mFulErr (-41) */
    movew #-41,%d0
    braw DECL_DRVR_ENET_3E6
DECL_DRVR_ENET_190:     /* with VM or +419: LockMemoryContiguous */
    btst #5,%a2@(0,%za0)@(0x14)	| 408FE140
    bnes DECL_DRVR_ENET_1A0
    tstb %a2@(419)
    beqs DECL_DRVR_ENET_1AE
DECL_DRVR_ENET_1A0:     /* lock it */
    movel %a1,%sp@-
    moveal %d5,%a1
    moveq #4,%d0
    _MemoryDispatch
    moveal %sp@+,%a1
    bnew DECL_DRVR_ENET_3E6
DECL_DRVR_ENET_1AE:     /* transmit buffers of 1526 bytes linked into a free list (+370); after them a table of (logical, physical) addresses */
    movel %d2,%a2@(376)
    movel %d1,%d5
    movel %a0,%d0
    _StripAddress
    moveal %d0,%a0
    movel %d0,%a2@(338)
    movel %a0,%a2@(370)
    movel %d2,%d0
    subqw #1,%d0
    bras DECL_DRVR_ENET_1D0
DECL_DRVR_ENET_1C8:     /* link one */
    pea %a0@(1526)
    movel %sp@,%a0@
    moveal %sp@+,%a0
DECL_DRVR_ENET_1D0:     /* next; then each buffer's physical address (E_428) */
    dbf %d0,DECL_DRVR_ENET_1C8
    clrl %a0@
    lea %a0@(1526),%a0
    movel %a0,%a2@(380)
    moveal %a2@(370),%a1
    movel %d2,%d1
    bras DECL_DRVR_ENET_210
DECL_DRVR_ENET_1D0_16:
    .byte   0x48, 0xE7	| 408FE196
    .long   0x40802F3C /* number, not an address (F3) */	| 408FE198
    .short  0x0000, 0x05F6	| orib #-10,%d0
    movel %a1,%sp@-
    bsrw DECL_DRVR_ENET_428
    moveal %sp@+,%a1
    addqw #4,%sp
    moveml %sp@+,%d1/%a0
    movel %a1,%a0@(4)
    movel %d0,%a0@
    movel %d0,%a1@(1520)
    lea %a0@(8),%a0
    lea %a1@(1526),%a1
DECL_DRVR_ENET_210:     /* next. No override address: read the ROM's (+402): 8 bytes must XOR to 0xFF; each byte bit-reversed */
    dbf %d1,DECL_DRVR_ENET_1D0_16	| 408FE1C0
    lea %a2@(4),%a1
    tstl %a1@
    bnes DECL_DRVR_ENET_262
    tstw %a1@(4)
    bnes DECL_DRVR_ENET_262
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    bsrw DECL_DRVR_ENET_GetInfo_276_34_8
    moveq #0,%d1
    moveq #7,%d0
DECL_DRVR_ENET_230:     /* loop: XOR */
    moveb %a0@+,%d2
    eorb %d2,%d1
    dbf %d0,DECL_DRVR_ENET_230
    subib #0xff,%d1	| 408FE1E8
    beqs DECL_DRVR_ENET_248
    moveb %sp@+,%d0
    _SwapMMUMode
    moveq #-1,%d0
    braw DECL_DRVR_ENET_3E6
DECL_DRVR_ENET_248:     /* copy the address */
    addqw #6,%a1
    bsrw DECL_DRVR_ENET_GetInfo_276_34_8
    moveq #5,%d2
DECL_DRVR_ENET_250:     /* loop: bit-reverse into +4 */
    moveb %a0@(0x0,%d2:w),%d0
    bsrw DECL_DRVR_ENET_40C
    moveb %d0,%a1@-
    dbf %d2,DECL_DRVR_ENET_250
    moveb %sp@+,%d0
    _SwapMMUMode
DECL_DRVR_ENET_262:     /* the mask for 24-bit pointers (+358); parameters for E_GetInfo_776 (chip init) pushed; memory that did not get used returned */
    moveq #-1,%d0
    _StripAddress
    movel %d0,%a2@(358)
    subaw #56,%sp
    pea %pc@(DECL_DRVR_ENET_428)
    movel %sp@+,%sp@(52)
    bsrw DECL_DRVR_ENET_GetInfo_2B8
    movel %a2@(414),%d0
    movel %d0,%a0@(252)
    movel %a2@(406),%d0
    movel %d0,%sp@(48)
    pea %a2@(278)
    movel %sp@+,%sp@(44)
    pea %pc@(DECL_DRVR_ENET_428_36_8+0x8)	| 408FE242
    movel %sp@+,%sp@(40)
    pea %pc@(DECL_DRVR_ENET_428_36_8)
    movel %sp@+,%sp@(36)
    movel %d3,%sp@(32)
    movel %d4,%sp@(28)
    movel %a2@(338),%sp@(24)
    addl %d5,%sp@(24)
    movel %a2,%sp@(20)
    pea %pc@(DECL_DRVR_ENET_Write_CC_C)
    movel %sp@+,%sp@(16)
    movel %a2@,%sp@(12)
    pea %pc@(DECL_DRVR_ENET_GetInfo_38_A)
    movel %sp@+,%sp@(8)
    pea %pc@(DECL_DRVR_ENET_428_36_8+0xe)	| 408FE27C
    movel %sp@+,%sp@(4)
    bsrw DECL_DRVR_ENET_GetInfo_2B8
    movel %a0,%sp@
    bsrw DECL_DRVR_ENET_GetInfo_23A
    bsrw DECL_DRVR_ENET_GetInfo_776
    lea %sp@(56),%sp
    bsrw DECL_DRVR_ENET_GetInfo_276
    bltw DECL_DRVR_ENET_3E6
    beqs DECL_DRVR_ENET_2FE
    negl %d0
    movel %d0,%sp@-
    moveal %a2@(338),%a0
    .short  0xA421	| 408FE2A8 _GetPtrSize (flags 0x0400)
    addl %sp@+,%d0
    .short  0xA420	| 408FE2AC _SetPtrSize (flags 0x0400)
DECL_DRVR_ENET_2FE:     /* the station address into the CAM; loopback tests (E_GetInfo_C86): RCR loopback modes 1, 2, 3; none passes: failure. Then back to normal; the VBL task; noErr */
    subaw #14,%sp
    movel #-1,%sp@(10)
    movel %a2@(6),%sp@(6)
    movew %a2@(4),%sp@(4)
    bsrw DECL_DRVR_ENET_GetInfo_2B8
    movel %a0,%sp@
    bsrw DECL_DRVR_ENET_GetInfo_23A
    bsrw DECL_DRVR_ENET_GetInfo_B4E
    lea %sp@(14),%sp
    bsrw DECL_DRVR_ENET_GetInfo_276
    pea %a2@(4)
    moveal %a2@,%a1
    movew %a1@(24),%d0
    movel %d0,%sp@-
    bsrw DECL_DRVR_ENET_GetInfo_2B8
    moveal %a0,%a3
    movel %a3@(8),%d0
    eoriw #-8192,%d0
    oriw #512,%d0
    movel %d0,%a3@(8)
    bsrw DECL_DRVR_ENET_GetInfo_C86
    beqw DECL_DRVR_ENET_3DA
    movel %a3@(8),%d0
    eoriw #512,%d0
    oriw #1024,%d0
    movel %d0,%a3@(8)
    bsrw DECL_DRVR_ENET_GetInfo_C86
    beqs DECL_DRVR_ENET_3DA
    movel %a3@(8),%d0
    eoriw #1024,%d0
    oriw #1536,%d0
    movel %d0,%a3@(8)
    bsrw DECL_DRVR_ENET_GetInfo_C86
    beqs DECL_DRVR_ENET_3DA
    movel %a3@(8),%d0
    eoriw #1536,%d0
    oriw #-8192,%d0
    movel %d0,%a3@(8)
    exg %a2,%a3
    bsrw DECL_DRVR_ENET_GetInfo_3A8
    movel %a2@(4),%d0
    movel %a3@(406),%d1
    andiw #15,%d1
    eorw %d1,%d0
    movel %a3@(410),%d1
    orw %d1,%d0
    movel %d0,%a2@(4)
    bsrw DECL_DRVR_ENET_GetInfo_374
    exg %a2,%a3
    addqw #8,%sp
    moveal %sp@+,%a1
    lea %a2@(344),%a0
    movew #1,%a0@(4)
    pea %pc@(DECL_DRVR_ENET_4A2_22)
    movel %sp@+,%a0@(6)
    movew #32767,%a0@(10)
    _VInstall
    moveq #0,%d0
    unlk %fp
    rts
DECL_DRVR_ENET_3DA:     /* failed: shut down; error */
    addqw #8,%sp
    bsrw DECL_DRVR_ENET_GetInfo_1A6_1C_1E
    moveal %sp@+,%a1
    moveq #-1,%d0
    jbra DECL_DRVR_Display_Video_Apple_Sonora_Status_74C
DECL_DRVR_ENET_3E6:     /* open failed: free the globals, return the error */
    movew %d0,%d3	| 408FE396
    moveal %sp@+,%a1
    tstl %a2@(338)
    beqs DECL_DRVR_ENET_3E6_10
    moveal %a2@(338),%a0
    _DisposPtr
DECL_DRVR_ENET_3E6_10:
    lea %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a3	| 408FE3A6
    clrl %a3@
    movew %d3,%d0
DECL_DRVR_Display_Video_Apple_Sonora_Status_74C:  /* test #-1,%d0 */
    cmpiw #-1,%d0
    jbne DECL_DRVR_Display_Video_Apple_Sonora_Status_754
    moveq #-23,%d0
DECL_DRVR_Display_Video_Apple_Sonora_Status_754:  /* test %d0 */
    tstw %d0
    unlk %fp
    rts

DECL_DRVR_ENET_40C:     /* reverse the bits of byte d0 */
    moveml %d2,%sp@-
    clrb %d1
    moveq #7,%d2
DECL_DRVR_ENET_40C_8:   /* loop */
    lslb #1,%d1
    lsrb #1,%d0
    jbcc DECL_DRVR_ENET_40C_10
    addqb #1,%d1
DECL_DRVR_ENET_40C_10:  /* next */
    dbf %d2,DECL_DRVR_ENET_40C_8
    moveb %d1,%d0
    moveml %sp@+,%d2
    rts

DECL_DRVR_ENET_428:     /* physical address of a logical one: with VM or +419, GetPhysical */
    linkw %fp,#-16
    movel %fp@(8),%fp@(-16)
    movel %fp@(8),%fp@(-8)
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a0
    btst #5,%a0@(0)@(0x14,%za0)	| 408FE3EC
    jbne DECL_DRVR_ENET_428_24
    tstb %a0@(419)
    jbeq DECL_DRVR_ENET_428_36
DECL_DRVR_ENET_428_24:  /* the address table */
    movel %fp@(12),%fp@(-12)
    lea %fp@(-16),%a0
    lea 0x1,%a1
    moveq #5,%d0
    _MemoryDispatch
DECL_DRVR_ENET_428_36:  /* return it */
    movel %fp@(-8),%d0
    unlk %fp
    rts
DECL_DRVR_ENET_428_36_8:/* disable interrupts (level 6), restore them; install the interrupt handler (slot +418, priority 200) */
    movew %sr,%d0
    movew #9728,%sr
    rts
    movew %sp@(6),%sr
    rts
    lea %pc@(DECL_DRVR_ENET_GetInfo_2E4),%a0
    movel %sp@(4),%a0@
    lea %pc@(DECL_DRVR_ENET_GetInfo_2D4),%a0
    movew #6,%a0@(4)
    pea %pc@(DECL_DRVR_ENET_4A2)
    movel %sp@+,%a0@(8)
    movew #200,%a0@(6)
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a1
    subl %d0,%d0
    moveb %a1@(418),%d0
    _SIntInstall
    rts

DECL_DRVR_ENET_4A2:     /* the slot interrupt: cache off, the handler (E_GetInfo_2E4), cache back; handled */
    moveml %d1-%d3/%a0,%sp@-
    jbsr DECL_DRVR_ENET_GetInfo_2B8
    movel %a0,%sp@-
    jbsr DECL_DRVR_ENET_GetInfo_23A
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2E4),%a1
    jsr %a1@
    addqw #4,%sp
    jbsr DECL_DRVR_ENET_GetInfo_276
    moveml %sp@+,%d1-%d3/%a0
    moveq #-1,%d0
    rts
DECL_DRVR_ENET_4A2_22:  /* the VBL task: stack too low: try next tick; a deferred Control (+342 bit 0)? run it */
    movew #32767,%a0@(10)
    _StackSpace
    tstl %d0
    bmis DECL_DRVR_ENET_4A2_22_14
    cmpil #512,%d0
    bccs DECL_DRVR_ENET_4A2_22_1C
DECL_DRVR_ENET_4A2_22_14:/* come back next tick */
    movew #1,%a0@(10)
DECL_DRVR_ENET_4A2_22_1A:/* return */
    rts
DECL_DRVR_ENET_4A2_22_1C:/* no pending call: return; else the DCE's queued call */
    lea %a0@(-344),%a2
    bclr #0,%a2@(342)
    beqs DECL_DRVR_ENET_4A2_22_1A
    moveal %a2@,%a1
    moveal %a1@(8),%a0
    bras DECL_DRVR_ENET_Control_2C

/* Control: find csCode in the control table and call its routine (ENET). */
DECL_DRVR_ENET_Control: /* Control. An immediate call with little stack: defer to the VBL task */
    movew %a0@(6),%d0
    btst #10,%d0
    jbeq DECL_DRVR_ENET_Control_2C
    _StackSpace
    tstl %d0
    jbmi DECL_DRVR_ENET_Control_18
    cmpil #512,%d0
    jbcc DECL_DRVR_ENET_Control_2C
DECL_DRVR_ENET_Control_18:/* defer */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a2
    bset #0,%a2@(342)
    movew #1,%a2@(354)
DECL_DRVR_ENET_Control_28:/* noErr */
    moveq #0,%d0
    rts
DECL_DRVR_ENET_Control_2C:/* csCode 1 KillIO; 245..253 through the table */
    movew %a0@(26),%d2
    subqw #1,%d2
    jbeq DECL_DRVR_ENET_Control_28
    moveq #-17,%d0
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a2
    subiw #244,%d2
    jblt DECL_DRVR_ENET_SetGeneral_2
    cmpiw #8,%d2
    jbgt DECL_DRVR_ENET_SetGeneral_2
    movew %a0@(28),%d1
    movel %a0@(30),%d3
    movew %pc@(DECL_DRVR_ENET_ControlTable:w,%d2:w:2),%d2	| 408FE4F6
    jmp %pc@(DECL_DRVR_ENET_ControlTable:w,%d2:w)	| 408FE4FC

/* control table: routine offsets by csCode (ENET). */
DECL_DRVR_ENET_ControlTable:/* 245 DelMulti, 246 AddMulti, 247 AttachPH, 248 DetachPH, 249 Write, 250 Read, 251 RdCancel, 252 GetInfo, 253 SetGeneral */
    .short  DECL_DRVR_ENET_DelMulti-DECL_DRVR_ENET_ControlTable	| 408FE502
    .short  DECL_DRVR_ENET_AddMulti-DECL_DRVR_ENET_ControlTable	| 408FE504
    .short  DECL_DRVR_ENET_AttachPH-DECL_DRVR_ENET_ControlTable	| 408FE506
    .short  DECL_DRVR_ENET_DetachPH-DECL_DRVR_ENET_ControlTable	| 408FE508
    .short  DECL_DRVR_ENET_Write-DECL_DRVR_ENET_ControlTable	| 408FE50A
    .short  DECL_DRVR_ENET_Read-DECL_DRVR_ENET_ControlTable	| 408FE50C
    .short  DECL_DRVR_ENET_RdCancel-DECL_DRVR_ENET_ControlTable	| 408FE50E
    .short  DECL_DRVR_ENET_GetInfo-DECL_DRVR_ENET_ControlTable	| 408FE510
    .short  DECL_DRVR_ENET_SetGeneral-DECL_DRVR_ENET_ControlTable	| 408FE512

/* Control ENetAddMulti: add a multicast address (ENET). */
DECL_DRVR_ENET_AddMulti:/* AddMulti: the address's first byte must have its multicast bit (else -91 eMultiErr); known: one more use */
    moveq #-91,%d0
    btst #8,%d1
    jbeq DECL_DRVR_ENET_SetGeneral_2
    jbsr DECL_DRVR_ENET_DelMulti_36
    jbpl DECL_DRVR_ENET_AddMulti_20
    moveq #7,%d2
DECL_DRVR_ENET_AddMulti_12:/* a free entry of the 8 */
    tstb %a2@(0xdc,%d2:w:8)
    dbeq %d2,DECL_DRVR_ENET_AddMulti_12
    jbne DECL_DRVR_ENET_SetGeneral_2
DECL_DRVR_ENET_AddMulti_20:/* store it; the first use: into the CAM */
    movel %d3,%a2@(0xd8,%d2:w:8)
    movew %d1,%a2@(0xd6,%d2:w:8)
    addqb #1,%a2@(0xdc,%d2:w:8)
    cmpib #1,%a2@(0xdc,%d2:w:8)
    jbhi DECL_DRVR_ENET_SetGeneral
    subaw #14,%sp
    movel #-1,%sp@(10)
    .short  0x2F43	| 408FE55E
    .short  0x0006, 0x3F41	| orib #65,%d6
    .short  0x0004, 0x6100	| orib #0,%d4
    bset %d2,%a2@
    movel %a0,%sp@
    jbsr DECL_DRVR_ENET_GetInfo_23A
    jbsr DECL_DRVR_ENET_GetInfo_B4E
    lea %sp@(14),%sp
    jbsr DECL_DRVR_ENET_GetInfo_276
    jbra DECL_DRVR_ENET_SetGeneral

/* Control ENetDelMulti: remove a multicast address (ENET). */
DECL_DRVR_ENET_DelMulti:/* DelMulti: one use less; the last: out of the CAM */
    moveq #-91,%d0
    jbsr DECL_DRVR_ENET_DelMulti_36
    jbmi DECL_DRVR_ENET_SetGeneral_2
    subqb #1,%a2@(0xdc,%d2:w:8)
    jbne DECL_DRVR_ENET_SetGeneral
    subaw #14,%sp
    clrl %sp@(10)
    movel %d3,%sp@(6)
    movew %d1,%sp@(4)
    jbsr DECL_DRVR_ENET_GetInfo_2B8
    movel %a0,%sp@
    jbsr DECL_DRVR_ENET_GetInfo_23A
    jbsr DECL_DRVR_ENET_GetInfo_B4E
    lea %sp@(14),%sp
    jbsr DECL_DRVR_ENET_GetInfo_276
    jbra DECL_DRVR_ENET_SetGeneral

/* subroutine (10 instructions) (mechanical summary) */
DECL_DRVR_ENET_DelMulti_36:/* find multicast address d1/d3 in the table; d2 = entry or -1 */
    moveq #7,%d2
DECL_DRVR_ENET_DelMulti_36_2:/* loop */
    tstb %a2@(0xdc,%d2:w:8)
    jbeq DECL_DRVR_ENET_DelMulti_36_1A
    cmpw %a2@(0xd6,%d2:w:8),%d1
    jbne DECL_DRVR_ENET_DelMulti_36_1A
    cmpl %a2@(0xd8,%d2:w:8),%d3
    jbeq DECL_DRVR_ENET_DelMulti_36_1E
DECL_DRVR_ENET_DelMulti_36_1A:/* next */
    dbf %d2,DECL_DRVR_ENET_DelMulti_36_2
DECL_DRVR_ENET_DelMulti_36_1E:/* N set if not found */
    tstw %d2
    rts

/* Control ENetAttachPH: attach a protocol handler (by Ethernet protocol type) (ENET). */
DECL_DRVR_ENET_AttachPH:/* AttachPH: protocol d1, handler d3 (0: the driver's ERead queue); -94 lapProtErr if attached or no room */
    andl %a2@(358),%d3
    moveq #-94,%d0
    jbsr DECL_DRVR_ENET_SetGeneral_A
    jbpl DECL_DRVR_ENET_SetGeneral_2
    moveq #15,%d2
DECL_DRVR_ENET_AttachPH_C:/* a free one of 16 */
    tstb %a2@(0x26,%d2:w)
    dbeq %d2,DECL_DRVR_ENET_AttachPH_C
    jbne DECL_DRVR_ENET_SetGeneral_2
    movel %d3,%a2@(0x56,%d2:w:4)
    clrl %a2@(0x96,%d2:w:4)
    movew %d1,%a2@(0x36,%d2:w:2)
    st %a2@(0x26,%d2:w)

/* Control ENetSetGeneral: use the general (larger) transmit buffers (ENET). */
DECL_DRVR_ENET_SetGeneral:/* noErr */
    clrw %d0
DECL_DRVR_ENET_SetGeneral_2:/* IODone */
    moveal %a2@,%a1
    movel JIODone,%sp@-
    rts

/* subroutine (8 instructions) (mechanical summary) */
DECL_DRVR_ENET_SetGeneral_A:/* find protocol d1 in the table; d2 = entry or -1 */
    moveq #15,%d2
DECL_DRVR_ENET_SetGeneral_A_2:/* loop */
    tstb %a2@(0x26,%d2:w)
    jbeq DECL_DRVR_ENET_SetGeneral_A_E
    cmpw %a2@(0x36,%d2:w:2),%d1
    jbeq DECL_DRVR_ENET_SetGeneral_A_12
DECL_DRVR_ENET_SetGeneral_A_E:/* next */
    dbf %d2,DECL_DRVR_ENET_SetGeneral_A_2
DECL_DRVR_ENET_SetGeneral_A_12:/* N set if not found */
    tstw %d2
    rts

/* Control ENetDetachPH: detach a protocol handler (ENET). */
DECL_DRVR_ENET_DetachPH:/* DetachPH: unused entry; cancel its pending reads */
    moveq #-94,%d0
    jbsr DECL_DRVR_ENET_SetGeneral_A
    jbmi DECL_DRVR_ENET_SetGeneral_2
    clrb %a2@(0x26,%d2:w)
    tstl %a2@(0x56,%d2:w:4)
    jbne DECL_DRVR_ENET_DetachPH_12
    jbsr DECL_DRVR_ENET_DetachPH_14
DECL_DRVR_ENET_DetachPH_12:/* done */
    jbra DECL_DRVR_ENET_SetGeneral

/* subroutine (8 instructions): calls DECL_DRVR_ENET_RdCancel_4C (mechanical summary) */
DECL_DRVR_ENET_DetachPH_14:/* cancel every read pending on entry d2 */
    movel %a2@(0x96,%d2:w:4),%d1
    jbeq DECL_DRVR_ENET_DetachPH_14_1A
    moveal %d1,%a0
    movel %a0@,%a2@(0x96,%d2:w:4)
    movew #-1105,%d0
    jbsr DECL_DRVR_ENET_RdCancel_4C
    jbra DECL_DRVR_ENET_DetachPH_14
DECL_DRVR_ENET_DetachPH_14_1A:/* return */
    rts

/* Control ENetWrite: send a packet (ENET). */
DECL_DRVR_ENET_Write:   /* Write: a free transmit buffer; none: mark waiting (+374) and return (the completion restarts it) */
    movew %sr,%sp@-
    movew #9216,%sr
    movel %a2@(370),%d2
    jbne DECL_DRVR_ENET_Write_16
    st %a2@(374)
    movew %sp@+,%sr
    moveq #0,%d0
    rts
DECL_DRVR_ENET_Write_16:/* take it; the WDS must start with at least 14 bytes */
    clrb %a2@(374)
    moveal %d2,%a1
    movel %a1@,%a2@(370)
    movew %sp@+,%sr
    movel %a1,%sp@-
    moveal %d3,%a0
    cmpiw #14,%a0@
    jbcs DECL_DRVR_ENET_Write_74
    .short  0x2068	| 408FE67C
    .short  0x0002, 0x216A	| orib #106,%d2
    orib #6,%d4
    movew %a2@(8),%a0@(10)
    movel %a4,%sp@-
    lea %a1@(1518),%a3
    moveq #-14,%d2
    clrw %a3@
    moveal %d3,%a4
DECL_DRVR_ENET_Write_48:/* copy each WDS entry into the buffer; too long or negative: -92 eLenErr */
    moveq #0,%d0
    movew %a4@+,%d0
    jbeq DECL_DRVR_ENET_Write_6E
    jbmi DECL_DRVR_ENET_Write_72
    addw %d0,%d2
    cmpw %a2@(22),%d2
    jbhi DECL_DRVR_ENET_Write_72
    addw %d0,%a3@
    moveal %a4@+,%a0
    moveml %d0/%d2/%a1,%sp@-
    jsr %a2@(0x16a,%za0)@(0)	| 408FE6B0
    moveml %sp@+,%d0/%d2/%a1
    addal %d0,%a1
    jbra DECL_DRVR_ENET_Write_48
DECL_DRVR_ENET_Write_6E:/* end of the WDS */
    moveal %sp@+,%a4
    jbra DECL_DRVR_ENET_Write_8C
DECL_DRVR_ENET_Write_72:/* error */
    moveal %sp@+,%a4
DECL_DRVR_ENET_Write_74:/* buffer back to the free list; -92 */
    moveal %sp@+,%a3
    movew %sr,%sp@-
    movew #9216,%sr
    movel %a2@(370),%a3@
    movel %a3,%a2@(370)
    movew %sp@+,%sr
    moveq #-92,%d0
    jbra DECL_DRVR_ENET_SetGeneral_2
DECL_DRVR_ENET_Write_8C:/* send it (E_GetInfo_A2E); no descriptor free: buffer back, deferred to the VBL task */
    movel %sp@,%sp@-
    addil #1518,%sp@
    jbsr DECL_DRVR_ENET_GetInfo_2B8
    movel %a0,%sp@-
    jbsr DECL_DRVR_ENET_GetInfo_23A
    jbsr DECL_DRVR_ENET_GetInfo_A2E
    addqw #8,%sp
    jbsr DECL_DRVR_ENET_GetInfo_276
    jbeq DECL_DRVR_ENET_Write_CC
    moveal %sp@+,%a3
    movew %sr,%sp@-
    movew #9216,%sr
    movel %a2@(370),%a3@
    movel %a3,%a2@(370)
    movew %sp@+,%sr
    bset #0,%a2@(342)
    movew #1,%a2@(354)
    moveq #0,%d0
    rts
DECL_DRVR_ENET_Write_CC:/* IODone */
    addqw #4,%sp
    moveq #0,%d0
    moveal %a2@,%a1
    moveal JIODone,%a0
    jmp %a0@
DECL_DRVR_ENET_Write_CC_C:/* transmit done (called by the chip code): with VM deferred (DeferUserFn) */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a0
    moveal %a0@,%a1
    btst #5,%a1@(20)
    beqs DECL_DRVR_ENET_Write_CC_34
    moveal %sp@(4),%a1
    bsrs DECL_DRVR_ENET_Write_14A_6
    lea %pc@(DECL_DRVR_ENET_Write_CC_28),%a0
    _DeferUserFn
    rts
DECL_DRVR_ENET_Write_CC_28:/* deferred entry */
    moveal %a0,%a1
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a0
    moveml %d3/%a2-%a3,%sp@-
    bras DECL_DRVR_ENET_Write_CC_40
DECL_DRVR_ENET_Write_CC_34:/* without VM: directly */
    moveal %sp@(4),%a1
    moveml %d3/%a2-%a3,%sp@-
    bsrs DECL_DRVR_ENET_Write_14A_6
    moveal %d0,%a1
DECL_DRVR_ENET_Write_CC_40:/* find the buffer by the descriptor's physical address */
    moveal %a0@(380),%a2
    movel %a0@(376),%d0
    subqw #1,%d0
DECL_DRVR_ENET_Write_116:/* loop over the table; found: back to the free list; a Write was waiting: start it */
    cmpal %a2@,%a1
    addqw #8,%a2
    dbeq %d0,DECL_DRVR_ENET_Write_116
    jbne DECL_DRVR_ENET_Write_14A
    moveal %a2@(-4),%a1
    movew %sr,%sp@-
    movew #9216,%sr
    movel %a0@(370),%a1@
    movel %a1,%a0@(370)
    movew %sp@+,%sr
    tstb %a0@(374)
    jbeq DECL_DRVR_ENET_Write_14A
    moveal %a0,%a2
    moveal %a2@,%a1
    moveal %a1@(8),%a0
    movel %a0@(30),%d3
    jbsr DECL_DRVR_ENET_Write
DECL_DRVR_ENET_Write_14A:/* restore, return */
    moveml %sp@+,%d3/%a2-%a3
    rts
DECL_DRVR_ENET_Write_14A_6:/* the physical address from the two halves of the descriptor */
    movel %a1@(20),%d0
    swap %d0
    movel %a1@(16),%d1
    movew %d1,%d0
    rts

/* Control ENetRead: read a packet (for clients without a protocol handler) (ENET). */
DECL_DRVR_ENET_Read:    /* Read: on a protocol with no handler; at least 14 bytes, else -3101 buf2SmallErr */
    moveq #-94,%d0
    jbsr DECL_DRVR_ENET_SetGeneral_A
    jbmi DECL_DRVR_ENET_SetGeneral_2
    tstl %a2@(0x56,%d2:w:4)
    jbne DECL_DRVR_ENET_SetGeneral_2
    movew #-3101,%d0
    cmpiw #14,%a0@(34)
    jbcs DECL_DRVR_ENET_SetGeneral_2
    lea %a2@(0x96,%d2:w:4),%a3
    movew %sr,%sp@-
    movew #9216,%sr
DECL_DRVR_ENET_Read_2C: /* find the end of the queue */
    tstl %a3@
    jbeq DECL_DRVR_ENET_Read_34
    moveal %a3@,%a3
    jbra DECL_DRVR_ENET_Read_2C
DECL_DRVR_ENET_Read_34: /* append it; an async DCE call waiting? run it next */
    exg %d0,%a0
    andl %a2@(358),%d0
    exg %d0,%a0
    movel %a0,%a3@
    bclr #7,%a1@(5)
    movel %a0@,%a1@(8)
    jbne DECL_DRVR_ENET_Read_4E
    clrl %a1@(12)
DECL_DRVR_ENET_Read_4E: /* unlink; another queued: start it */
    clrl %a0@
    movel %a1@(8),%d0
    jbeq DECL_DRVR_ENET_Read_6A
    bset #7,%a1@(5)
    movew %sp@+,%sr
    moveal %d0,%a0
    moveq #0,%d0
    jbsr DECL_DRVR_ENET_Control
    moveq #0,%d0
    rts
DECL_DRVR_ENET_Read_6A: /* return */
    movew %sp@+,%sr
    rts

/* Control ENetRdCancel: cancel a read (ENET). */
DECL_DRVR_ENET_RdCancel:/* RdCancel: remove the read from its protocol's queue */
    movew #-1102,%d0
    andl %a2@(358),%d3
    moveal %d3,%a1
    movew %a1@(28),%d1
    jbsr DECL_DRVR_ENET_SetGeneral_A
    jbmi DECL_DRVR_ENET_RdCancel_48
    tstl %a2@(0x56,%d2:w:4)
    jbne DECL_DRVR_ENET_RdCancel_48
    lea %a2@(0x96,%d2:w:4),%a3
    movew %sr,%sp@-
    movew #9216,%sr
DECL_DRVR_ENET_RdCancel_26:/* loop: find it */
    movel %a3@,%d3
    andl %a2@(358),%d3
    jbeq DECL_DRVR_ENET_RdCancel_46
    subl %a1,%d3
    jbeq DECL_DRVR_ENET_RdCancel_36
    moveal %a3@,%a3
    jbra DECL_DRVR_ENET_RdCancel_26
DECL_DRVR_ENET_RdCancel_36:/* unlink; complete it with -1105 reqAborted */
    movel %a1@,%a3@
    movew %sp@+,%sr
    moveal %a1,%a0
    movew #-1105,%d0
    jbsr DECL_DRVR_ENET_RdCancel_4C
    jbra DECL_DRVR_ENET_SetGeneral
DECL_DRVR_ENET_RdCancel_46:/* not there */
    movew %sp@+,%sr
DECL_DRVR_ENET_RdCancel_48:/* error */
    jbra DECL_DRVR_ENET_SetGeneral_2

/* subroutine (9 instructions) (mechanical summary) */
DECL_DRVR_ENET_RdCancel_4C:/* complete a read: result; ioCompletion */
    movew %d0,%a0@(16)
    moveml %d1-%d3/%a0-%a3,%sp@-
    movel %a0@(12),%d1
    jbeq DECL_DRVR_ENET_RdCancel_4C_14
    moveal %d1,%a1
    tstw %d0
    jsr %a1@
DECL_DRVR_ENET_RdCancel_4C_14:/* return */
    moveml %sp@+,%d1-%d3/%a0-%a3
    rts

/* Control ENetGetInfo: the Ethernet address and statistics (ENET). */
DECL_DRVR_ENET_GetInfo: /* GetInfo: Ethernet address (18 bytes), then 60 bytes of statistics (+278) */
    andl %a2@(358),%d3
    moveal %a0,%a3
    moveq #0,%d0
    movew %a3@(34),%d0
    cmpiw #18,%d0
    jbls DECL_DRVR_ENET_GetInfo_14
    moveq #18,%d0
DECL_DRVR_ENET_GetInfo_14:/* copy the address block */
    moveal %d3,%a1
    lea %a2@(4),%a0
    pea %a1@(0x0,%d0:l)
    movel %d0,%sp@-
    _BlockMove
    movew %a3@(34),%d0
    subl %sp@+,%d0
    moveal %sp@+,%a1
    jbls DECL_DRVR_ENET_SetGeneral
    cmpil #60,%d0
    jbls DECL_DRVR_ENET_GetInfo_38
    moveq #60,%d0
DECL_DRVR_ENET_GetInfo_38:/* the statistics */
    lea %a2@(278),%a0
    _BlockMove
    jbra DECL_DRVR_ENET_SetGeneral
DECL_DRVR_ENET_GetInfo_38_A:/* receive callback (from the chip code): with VM, queue it and DeferUserFn */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a1
    moveal %a1@,%a1
    btst #5,%a1@(20)
    beqs DECL_DRVR_ENET_GetInfo_92
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a0
    lea %a0@(410),%a1
    moveq #7,%d0
DECL_DRVR_ENET_GetInfo_38_22:/* a free queue slot of 8 */
    lea %a1@(20),%a1
    tstl %a1@
    dbeq %d0,DECL_DRVR_ENET_GetInfo_38_22
    bnes DECL_DRVR_ENET_GetInfo_92
    pea %a1@
    lea %sp@(8),%a0
    moveq #20,%d0
    _BlockMove
    movel %sp@+,%d0
    lea %pc@(DECL_DRVR_ENET_GetInfo_38_42),%a0
    _DeferUserFn
    rts
DECL_DRVR_ENET_GetInfo_38_42:/* deferred entry */
    movel %a0,%sp@-
    subaw #20,%sp
    moveal %sp,%a1
    moveq #20,%d0
    _BlockMove
    bsrs DECL_DRVR_ENET_GetInfo_92
    lea %sp@(20),%sp
    moveal %sp@+,%a0
    clrl %a0@
    rts

DECL_DRVR_ENET_GetInfo_92:/* deliver a packet: the 14-byte header; its protocol's handler */
    linkw %fp,#0
    moveml %d3/%a2-%a5,%sp@-
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a2
    movel %fp@(24),%a2@(366)
    moveal %fp@(16),%a0
    movel %fp@(8),%d1
    btst #0,%d1
    jbeq DECL_DRVR_ENET_GetInfo_92_62
    movel %fp@(12),%d1
    subqw #4,%d1
    lea %a2@(24),%a3
    moveq #6,%d0
DECL_DRVR_ENET_GetInfo_92_2C:/* loop: copy the header */
    movew %a0@+,%a3@+
    dbf %d0,DECL_DRVR_ENET_GetInfo_92_2C
    subiw #14,%d1
    movew %a3@(-2),%d0
    cmpiw #1500,%d0
    jbhi DECL_DRVR_ENET_GetInfo_92_7C
    clrw %d0
    exg %d0,%d1
    jbsr DECL_DRVR_ENET_SetGeneral_A
    exg %d0,%d1
    jbmi DECL_DRVR_ENET_GetInfo_92_62
    movew %a3@(-2),%d0
DECL_DRVR_ENET_GetInfo_92_50:/* its handler, or the default (ERead queue) */
    lea %pc@(DECL_DRVR_ENET_GetInfo_92_A6),%a4
    lea %pc@(DECL_DRVR_ENET_GetInfo_15A),%a5
    movel %a2@(0x56,%d2:w:4),%d3
    jbeq DECL_DRVR_ENET_GetInfo_92_60
    moveal %d3,%a5
DECL_DRVR_ENET_GetInfo_92_60:/* call it */
    jsr %a5@
DECL_DRVR_ENET_GetInfo_92_62:/* free the receive descriptor */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a2
    movel %a2@(366),%d0
    jbeq DECL_DRVR_ENET_GetInfo_92_74
    movel %d0,%sp@-
    jbsr DECL_DRVR_ENET_GetInfo_408
    addqw #4,%sp
DECL_DRVR_ENET_GetInfo_92_74:/* return */
    moveml %sp@+,%d3/%a2-%a5
    unlk %fp
    rts
DECL_DRVR_ENET_GetInfo_92_7C:/* length over 1500: an Ethernet II type, not 802.3 */
    exg %d0,%d1
    jbsr DECL_DRVR_ENET_SetGeneral_A
    exg %d0,%d1
    jbmi DECL_DRVR_ENET_GetInfo_92_62
    jbra DECL_DRVR_ENET_GetInfo_92_50
DECL_DRVR_ENET_GetInfo_92_88:/* the handler's ReadRest: free the descriptor first */
    moveml %d0-%d2/%a2,%sp@-
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a2
    movel %a2@(366),%sp@-
    clrl %a2@(366)
    jbsr DECL_DRVR_ENET_GetInfo_408
    addqw #4,%sp
    moveml %sp@+,%d0-%d2/%a2
    tstw %d0
    rts
DECL_DRVR_ENET_GetInfo_92_A6:/* ReadPacket entry (+0), ReadRest entry (+2) */
    jbra DECL_DRVR_ENET_GetInfo_92_B8
    .long   0x30039041	| 408FE9BC
    tstw %d3
    jbeq DECL_DRVR_ENET_GetInfo_92_B2
    jbsr DECL_DRVR_ENET_GetInfo_1A6
DECL_DRVR_ENET_GetInfo_92_B2:/* done */
    movew %d0,%d3
    moveq #0,%d0
    jbra DECL_DRVR_ENET_GetInfo_92_88
DECL_DRVR_ENET_GetInfo_92_B8:/* ReadPacket: copy d3 bytes */
    cmpw %d3,%d1
    jbcs DECL_DRVR_ENET_GetInfo_92_C2
    jbsr DECL_DRVR_ENET_GetInfo_1A6
    tstw %d3
    jbeq DECL_DRVR_ENET_GetInfo_92_C6
DECL_DRVR_ENET_GetInfo_92_C2:/* too long: -92 */
    moveq #-92,%d0
    jbra DECL_DRVR_ENET_GetInfo_92_88
DECL_DRVR_ENET_GetInfo_92_C6:  /* return */
    rts

DECL_DRVR_ENET_GetInfo_15A:/* default handler: the next read in the queue: header, rest of the packet; length; -3101 if it did not fit */
    movel %a2@(0x96,%d2:w:4),%d0
    jbeq DECL_DRVR_ENET_GetInfo_15A_46
    moveal %d0,%a5
    movel %a5@,%a2@(0x96,%d2:w:4)
    movel %d0,%d2
    moveal %a5@(30),%a3
    movew %a5@(34),%d3
    subiw #14,%d3
    lea %a2@(24),%a5
    movel %a5@+,%a3@+
    movel %a5@+,%a3@+
    movel %a5@+,%a3@+
    movew %a5@+,%a3@+
    jsr %a4@(2)
    moveal %d2,%a0
    movew %a0@(34),%d1
    subw %d3,%d1
    movew %d1,%a0@(36)
    tstw %d3
    jbpl DECL_DRVR_ENET_GetInfo_15A_42
    movew #-3101,%d0
DECL_DRVR_ENET_GetInfo_15A_42:/* complete it */
    jbra DECL_DRVR_ENET_RdCancel_4C
DECL_DRVR_ENET_GetInfo_15A_46:/* no read: discard (ReadRest) */
    moveq #0,%d3
    jmp %a4@(2)

/* subroutine (50 instructions): traps DisposPtr, SIntRemove, VRemove; calls DECL_DRVR_ENET_GetInfo_2B8, DECL_DRVR_ENET_GetInfo_23A, DECL_DRVR_ENET_GetInfo_9F2, DECL_DRVR_ENET_GetInfo_276, DECL_DRVR_ENET_DetachPH_14 (mechanical summary) */
DECL_DRVR_ENET_GetInfo_1A6:/* copy from the packet to the caller (through +362) */
    moveml %d0/%d2/%a1-%a2,%sp@-
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a2
    exg %d0,%a3
    andl %a2@(358),%d0
    exg %d0,%a3
    moveal %a3,%a1
    moveq #0,%d0
    movew %d3,%d0
    cmpw %d1,%d3
    jbls DECL_DRVR_ENET_GetInfo_1A6_1C
    movew %d1,%d0
DECL_DRVR_ENET_GetInfo_1A6_1C:/* copy */
    subw %d0,%d1
    subw %d0,%d3
    addaw %d0,%a3
    movel %d1,%sp@-
    movel %a0,%sp@-
    movel %d0,%sp@-
    jsr %a2@(0x16a,%za0)@(0)	| 408FEA50
    moveal %sp@+,%a0
    addal %sp@+,%a0
    movel %sp@+,%d1
    moveml %sp@+,%d0/%d2/%a1-%a2
    rts
DECL_DRVR_ENET_GetInfo_1A6_1C_1E:/* Close: chip off; pending reads cancelled; interrupt and VBL task removed; the memory disposed of */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a2	| 408FEA62
    jbsr DECL_DRVR_ENET_GetInfo_2B8	| 408FEA66
    movel %a0,%sp@-	| 408FEA6A
    jbsr DECL_DRVR_ENET_GetInfo_23A	| 408FEA6C
    jbsr DECL_DRVR_ENET_GetInfo_9F2	| 408FEA6E
    addqw #4,%sp	| 408FEA72
    jbsr DECL_DRVR_ENET_GetInfo_276	| 408FEA74
    moveal %a2@(338),%a0	| 408FEA78
    _DisposPtr	| 408FEA7C 408FEA7C A-line trap
    moveq #15,%d2	| 408FEA7E
DECL_DRVR_ENET_GetInfo_1FE:/* per protocol: cancel its reads */
    tstb %a2@(0x26,%d2:w)	| 408FEA80 408FEA80 tstb %a2@(26,%d2:w)
    jbeq DECL_DRVR_ENET_GetInfo_20E	| 408FEA84
    tstl %a2@(0x56,%d2:w:4)	| 408FEA86 408FEA86 tstl %a2@(56,%d2:w:4)
    jbne DECL_DRVR_ENET_GetInfo_20E	| 408FEA8A
    jbsr DECL_DRVR_ENET_DetachPH_14	| 408FEA8C
DECL_DRVR_ENET_GetInfo_20E:/* next; SIntRemove, VRemove */
    dbf %d2,DECL_DRVR_ENET_GetInfo_1FE	| 408FEA90
    lea %pc@(DECL_DRVR_ENET_GetInfo_2D4),%a0	| 408FEA94
    moveq #0,%d0	| 408FEA98
    moveb %a2@(418),%d0	| 408FEA9A
    _SIntRemove	| 408FEA9E 408FEA9E A-line trap
    lea %a2@(344),%a0	| 408FEAA0
    tstl %a0@(6)	| 408FEAA4
    jbeq DECL_DRVR_ENET_GetInfo_22A	| 408FEAA8
    _VRemove	| 408FEAAA 408FEAAA A-line trap
DECL_DRVR_ENET_GetInfo_22A:/* free the globals */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a0	| 408FEAAC
    _DisposPtr	| 408FEAB0 408FEAB0 A-line trap
    lea %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a2	| 408FEAB2
    clrl %a2@	| 408FEAB6
    moveq #0,%d0	| 408FEAB8
    rts	| 408FEABA

/* subroutine (16 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_23A:/* 68040 without VM: data cache off (nested; +386 holds the old CACR, +390 the count) */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a0
    tstb %a0@(419)
    jbne DECL_DRVR_ENET_GetInfo_23A_3A
    btst #5,%a0@(0)@(0x14,%za0)	| 408FEAC6
    jbne DECL_DRVR_ENET_GetInfo_23A_3A
    movew %sr,%sp@-
    movew #9216,%sr
    addql #1,%a0@(390)
    tstl %a0@(386)
    jbne DECL_DRVR_ENET_GetInfo_23A_38
    movec %cacr,%d0
    movel %d0,%a0@(386)
    bset #11,%d0
    bclr #8,%d0
    movec %d0,%cacr
DECL_DRVR_ENET_GetInfo_23A_38:/* restore SR */
    movew %sp@+,%sr
DECL_DRVR_ENET_GetInfo_23A_3A:  /* return */
    rts

/* subroutine (17 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_276:/* cache back on at the outermost call */
    moveml %d0/%a0,%sp@-
    movew %ccr,%sp@-
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2D0),%a0
    tstb %a0@(419)
    jbne DECL_DRVR_ENET_GetInfo_276_34
    btst #5,%a0@(0)@(0x14,%za0)	| 408FEB08
    jbne DECL_DRVR_ENET_GetInfo_276_34
    movew %sr,%sp@-
    movew #9216,%sr
    subql #1,%a0@(390)
    jbne DECL_DRVR_ENET_GetInfo_276_32
    movel %a0@(386),%d0
    clrl %a0@(386)
    movec %d0,%cacr
DECL_DRVR_ENET_GetInfo_276_32:/* restore SR */
    movew %sp@+,%sr
DECL_DRVR_ENET_GetInfo_276_34:/* restore, flags kept */
    movew %sp@+,%ccr
    moveml %sp@+,%d0/%a0
    rts
DECL_DRVR_ENET_GetInfo_276_34_8:/* the address of the ROM holding the Ethernet address (+402) */
    moveal %a2@(402),%a0
    rts

/* subroutine (6 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_2B8:/* the chip's registers: 24-bit or 32-bit address */
    lea %pc@(DECL_DRVR_ENET_GetInfo_2D0:w,%za0)@(0x18a),%a0	| 408FEB3A
    tstb MMU32Bit
    jbeq DECL_DRVR_ENET_GetInfo_2B8_14
    moveal %a0@(4),%a0
    rts
DECL_DRVR_ENET_GetInfo_2B8_14:/* 24-bit */
    moveal %a0@,%a0
    rts
DECL_DRVR_ENET_GetInfo_2D0:/* pointer to the globals */
    .byte   0x00, 0x00, 0x00, 0x00	| 408FEB52
DECL_DRVR_ENET_GetInfo_2D4:/* slot interrupt queue element */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408FEB56
    .short  0x0000, 0x0000, 0x0000	| 408FEB60
DECL_DRVR_ENET_GetInfo_2E4:/* the interrupt handler (E_GetInfo_45A) */
    .short  0x0000, 0x0000	| 408FEB66
DECL_DRVR_ENET_GetInfo_2E8:/* transmit descriptor area: list being sent; +4 logical base; +8 physical base */
    .short  0x0000, 0x0000	| 408FEB6A
DECL_DRVR_ENET_GetInfo_2EC:  /* (data) */
    .short  0x0000, 0x0000	| 408FEB6E
DECL_DRVR_ENET_GetInfo_2F0:  /* (data) */
    .short  0x0000, 0x0000	| 408FEB72
DECL_DRVR_ENET_GetInfo_2F4:/* transmit descriptors waiting */
    .short  0x0000, 0x0000	| 408FEB76
DECL_DRVR_ENET_GetInfo_2F8:/* free transmit descriptors */
    .short  0x0000, 0x0000	| 408FEB7A
DECL_DRVR_ENET_GetInfo_2FC:/* CAM descriptor area */
    .short  0x0000, 0x0000	| 408FEB7E
DECL_DRVR_ENET_GetInfo_300:  /* (data) */
    .short  0x0000, 0x0000	| 408FEB82
DECL_DRVR_ENET_GetInfo_304:  /* (data) */
    .short  0x0000, 0x0000	| 408FEB86
DECL_DRVR_ENET_GetInfo_308:/* receive buffer area */
    .short  0x0000, 0x0000	| 408FEB8A
DECL_DRVR_ENET_GetInfo_30C:  /* (data) */
    .short  0x0000, 0x0000	| 408FEB8E
DECL_DRVR_ENET_GetInfo_310:  /* (data) */
    .short  0x0000, 0x0000	| 408FEB92
DECL_DRVR_ENET_GetInfo_314:/* receive descriptor area */
    .short  0x0000, 0x0000	| 408FEB96
DECL_DRVR_ENET_GetInfo_318:  /* (data) */
    .short  0x0000, 0x0000	| 408FEB9A
DECL_DRVR_ENET_GetInfo_31C:  /* (data) */
    .short  0x0000, 0x0000	| 408FEB9E
DECL_DRVR_ENET_GetInfo_320:/* argument of the receive callback */
    .short  0x0000, 0x0000	| 408FEBA2
DECL_DRVR_ENET_GetInfo_324:/* receive callback */
    .short  0x0000, 0x0000	| 408FEBA6
DECL_DRVR_ENET_GetInfo_328:/* argument of the transmit callback */
    .short  0x0000, 0x0000	| 408FEBAA
DECL_DRVR_ENET_GetInfo_32C:/* transmit callback */
    .short  0x0000, 0x0000	| 408FEBAE
DECL_DRVR_ENET_GetInfo_330:/* count of transmit errors in a row */
    .short  0x0000, 0x0000	| 408FEBB2
DECL_DRVR_ENET_GetInfo_334:/* number of receive descriptors */
    .short  0x0000, 0x0000	| 408FEBB6
DECL_DRVR_ENET_GetInfo_338:/* first filled receive descriptor */
    .short  0x0000, 0x0000	| 408FEBBA
DECL_DRVR_ENET_GetInfo_33C:/* last receive descriptor */
    .short  0x0000, 0x0000	| 408FEBBE
DECL_DRVR_ENET_GetInfo_340:/* receive descriptors in use, waiting to be given back */
    .short  0x0000, 0x0000	| 408FEBC2
DECL_DRVR_ENET_GetInfo_344:/* disable interrupts */
    .short  0x0000, 0x0000	| 408FEBC6
DECL_DRVR_ENET_GetInfo_348:/* restore interrupts */
    .short  0x0000, 0x0000	| 408FEBCA
DECL_DRVR_ENET_GetInfo_34C:/* the statistics */
    .short  0x0000, 0x0000	| 408FEBCE
DECL_DRVR_ENET_GetInfo_350:/* received packets being handled: head; +4 tail */
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 408FEBD2

/* subroutine (5 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_358:/* restart the watchdog: WT0, WT1, clear TC in ISR */
    movel #61568,%a2@(164)
    movel #762,%a2@(168)
    movel #128,%d0
    movel %d0,%a2@(20)
    rts

/* subroutine (15 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_374:/* restart: reset off, wait; watchdog; CR = ST and RXEN */
    moveq #0,%d0
    movel %d0,%a2@
DECL_DRVR_ENET_GetInfo_374_4:/* loop: reset done */
    movel %a2@,%d0
    btst #7,%d0
    jbne DECL_DRVR_ENET_GetInfo_374_4
    movel #61568,%a2@(164)
    movel #762,%a2@(168)
    movel #128,%d0
    movel %d0,%a2@(20)
    moveq #40,%d0
    movel %d0,%a2@
DECL_DRVR_ENET_GetInfo_374_2A:/* loop: until RXDIS clears */
    movel %a2@,%d0
    btst #2,%d0
    jbne DECL_DRVR_ENET_GetInfo_374_2A
    rts

/* subroutine (11 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_3A8:/* stop: RXDIS, wait for it, wait for CR = ST + RXDIS, then RST */
    moveq #4,%d0
    movel %d0,%a2@
DECL_DRVR_ENET_GetInfo_3A8_4:/* loop: RXEN clears */
    movel %a2@,%d0
    btst #3,%d0
    jbne DECL_DRVR_ENET_GetInfo_3A8_4
DECL_DRVR_ENET_GetInfo_3A8_C:/* loop */
    movel %a2@,%d0
    eoriw #36,%d0
    jbne DECL_DRVR_ENET_GetInfo_3A8_C
    bset #7,%d0
    movel %d0,%a2@
    rts

/* subroutine (7 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_3C4:/* issue CR command bit d0 and wait until it clears */
    subl %d1,%d1
    bset %d0,%d1
    movel %d1,%a2@
DECL_DRVR_ENET_GetInfo_3C4_6:/* loop */
    movel %a2@,%d1
    btst %d0,%d1
    jbne DECL_DRVR_ENET_GetInfo_3C4_6
    rts

/* subroutine (20 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_3D2:/* give a receive descriptor back: in_use = 1 (chip owns it), EOL; link after the old last one */
    movel %a2,%sp@-
    subl %d0,%d0
    movel %d0,%a1@
    moveq #1,%d0
    movel %d0,%a1@(20)
    moveq #-1,%d0
    movel %d0,%a1@(24)
    lea %pc@(DECL_DRVR_ENET_GetInfo_33C),%a0
    moveal %a0@,%a2
    movel %a1,%a0@
    movel %a1,%d0
    subl %pc@(DECL_DRVR_ENET_GetInfo_318),%d0
    addl %pc@(DECL_DRVR_ENET_GetInfo_31C),%d0
    movel %d0,%a2@(20)
    lea %pc@(DECL_DRVR_ENET_GetInfo_338),%a0
    tstl %a0@
    jbne DECL_DRVR_ENET_GetInfo_3D2_32
    movel %a1,%a0@
DECL_DRVR_ENET_GetInfo_3D2_32:/* return */
    moveal %sp@+,%a2
    rts

/* subroutine (25 instructions): calls DECL_DRVR_ENET_GetInfo_446 (mechanical summary) */
DECL_DRVR_ENET_GetInfo_408:/* packet finished: mark it; the oldest finished ones go back in order */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_344),%a0
    jsr %a0@
    moveal %sp@(4),%a1
    movel %a2,%sp@-
    movel %d0,%sp@-
    st %a1@(4)
    lea %pc@(DECL_DRVR_ENET_GetInfo_350),%a2
    cmpal %a2@,%a1
    jbne DECL_DRVR_ENET_GetInfo_408_32
DECL_DRVR_ENET_GetInfo_408_1A:/* loop */
    tstb %a1@(4)
    jbeq DECL_DRVR_ENET_GetInfo_408_2C
    movel %a1@,%a2@
    jbsr DECL_DRVR_ENET_GetInfo_446
    movel %a2@,%d0
    jbeq DECL_DRVR_ENET_GetInfo_408_2C
    moveal %d0,%a1
    jbra DECL_DRVR_ENET_GetInfo_408_1A
DECL_DRVR_ENET_GetInfo_408_2C:/* list empty: clear the tail */
    tstl %a2@+
    jbne DECL_DRVR_ENET_GetInfo_408_32
    clrl %a2@
DECL_DRVR_ENET_GetInfo_408_32:/* restore interrupts */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_348),%a0
    jsr %a0@
    addqw #4,%sp
    moveal %sp@+,%a2
    rts

/* subroutine (7 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_446:/* give one back unless the chip still owns it; else queue it */
    movel %a1@(24),%d0
    tstw %d0
    beqw DECL_DRVR_ENET_GetInfo_3D2
    lea %pc@(DECL_DRVR_ENET_GetInfo_340),%a0
    movel %a0@,%a1@
    movel %a1,%a0@
    rts

/* subroutine (34 instructions): calls DECL_DRVR_ENET_GetInfo_660, DECL_DRVR_ENET_GetInfo_534 (mechanical summary) */
DECL_DRVR_ENET_GetInfo_45A:/* the chip's interrupt handler: PKTRX first, TXDN next, then the other sources by the table */
    linkw %fp,#0
    moveml %a2-%a3,%sp@-
DECL_DRVR_ENET_GetInfo_45A_8:/* read ISR: PKTRX */
    moveal %fp@(8),%a2
    movel %a2@(20),%d0
    movew %d0,%d1
    movew #1024,%d2
    andw %d2,%d0
    jbeq DECL_DRVR_ENET_GetInfo_45A_24
    movel %d2,%a2@(20)
    jbsr DECL_DRVR_ENET_GetInfo_660
    jbra DECL_DRVR_ENET_GetInfo_45A_8
DECL_DRVR_ENET_GetInfo_45A_24:/* TXDN */
    movew #512,%d2
    andw %d2,%d1
    jbeq DECL_DRVR_ENET_GetInfo_45A_36
    movel %d2,%a2@(20)
    jbsr DECL_DRVR_ENET_GetInfo_534
    jbra DECL_DRVR_ENET_GetInfo_45A_8
DECL_DRVR_ENET_GetInfo_45A_36:/* others in IMR: the highest set bit */
    movel %a2@(20),%d0
    andiw #18097,%d0
    jbeq DECL_DRVR_ENET_GetInfo_45A_5E
    moveq #15,%d1
DECL_DRVR_ENET_GetInfo_45A_42:/* loop: find it */
    btst %d1,%d0
    dbne %d1,DECL_DRVR_ENET_GetInfo_45A_42
    subl %d2,%d2
    bset %d1,%d2
    addw %d1,%d1
    lea %pc@(DECL_DRVR_ENET_GetInfo_4C0),%a0
    addaw %a0@(0x0,%d1:w),%a0
    movel %d2,%a2@(20)
    jsr %a0@
    jbra DECL_DRVR_ENET_GetInfo_45A_8
DECL_DRVR_ENET_GetInfo_45A_5E:/* none left: return */
    moveml %sp@+,%a2-%a3
    unlk %fp
    rts
DECL_DRVR_ENET_GetInfo_4C0:/* by ISR bit: 0 RFO, 4 RBAE, 5 RBE: count; 7 TC: watchdog; 9 TXDN; 10 PKTRX */
    .short  DECL_DRVR_ENET_GetInfo_4E0-DECL_DRVR_ENET_GetInfo_4C0	| 408FED42
    .short  DECL_DRVR_ENET_GetInfo_4EA-DECL_DRVR_ENET_GetInfo_4C0	| 408FED44
    .short  DECL_DRVR_ENET_GetInfo_4EC-DECL_DRVR_ENET_GetInfo_4C0	| 408FED46
    .short  DECL_DRVR_ENET_GetInfo_4EE-DECL_DRVR_ENET_GetInfo_4C0	| 408FED48
    .short  DECL_DRVR_ENET_GetInfo_4F0-DECL_DRVR_ENET_GetInfo_4C0	| 408FED4A
    .short  DECL_DRVR_ENET_GetInfo_4F2-DECL_DRVR_ENET_GetInfo_4C0	| 408FED4C
    .short  DECL_DRVR_ENET_GetInfo_4F4-DECL_DRVR_ENET_GetInfo_4C0	| 408FED4E
    .short  DECL_DRVR_ENET_GetInfo_4F6-DECL_DRVR_ENET_GetInfo_4C0	| 408FED50
    .short  DECL_DRVR_ENET_Control_910-DECL_DRVR_ENET_GetInfo_4C0	| 408FED52
    .short  DECL_DRVR_ENET_GetInfo_534-DECL_DRVR_ENET_GetInfo_4C0	| 408FED54
    .short  DECL_DRVR_ENET_GetInfo_660-DECL_DRVR_ENET_GetInfo_4C0	| 408FED56
    .short  DECL_DRVR_ENET_GetInfo_76E-DECL_DRVR_ENET_GetInfo_4C0	| 408FED58
    .short  DECL_DRVR_ENET_GetInfo_770-DECL_DRVR_ENET_GetInfo_4C0	| 408FED5A
    .short  DECL_DRVR_ENET_GetInfo_772-DECL_DRVR_ENET_GetInfo_4C0	| 408FED5C
    .short  DECL_DRVR_ENET_GetInfo_774-DECL_DRVR_ENET_GetInfo_4C0	| 408FED5E
    .short  DECL_DRVR_ENET_GetInfo_774-DECL_DRVR_ENET_GetInfo_4C0	| 408FED60

/* subroutine (3 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_4E0:/* count a resource error (statistics +56) */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_34C),%a0	| 408FED62
    addql #1,%a0@(56)	| 408FED66
    rts	| 408FED6A

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_4EA:
    rts	| 408FED6C

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_4EC:
    rts	| 408FED6E

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_4EE:
    rts	| 408FED70

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_4F0:
    jbra DECL_DRVR_ENET_GetInfo_4E0	| 408FED72

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_4F2:
    jbra DECL_DRVR_ENET_GetInfo_4E0	| 408FED74

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_4F4:
    rts	| 408FED76

/* subroutine (17 instructions): calls DECL_DRVR_ENET_GetInfo_374 (mechanical summary) */
DECL_DRVR_ENET_GetInfo_4F6:/* watchdog: chip revisions up to 3: receiver stuck (CRDA valid, no PKTRX)? reset it, else rearm */
    movel %a2@(160),%d0	| 408FED78
    cmpiw #3,%d0
    jbhi DECL_DRVR_ENET_Control_90E
    movel %pc@(DECL_DRVR_ENET_GetInfo_338),%d0
    jbeq DECL_DRVR_ENET_GetInfo_358
    movel %a2@(56),%d0
    btst #0,%d0
    jbeq DECL_DRVR_ENET_GetInfo_358
    movel %a2@(20),%d0
    btst #10,%d0
    jbne DECL_DRVR_ENET_GetInfo_358
    movel %a2@,%sp@-
    movel #128,%d0
    movel %d0,%a2@
    jbsr DECL_DRVR_ENET_GetInfo_374
    movel %sp@+,%a2@
DECL_DRVR_ENET_Control_90E:/* return */
    rts

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_Control_910:
    rts	| 408FEDB4

/* subroutine (101 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_534:/* TXDN (and TXER): after 4 errors in a row stop: retransmit */
    lea %pc@(DECL_DRVR_ENET_GetInfo_330),%a0
    movel %a2@(20),%d0
    andiw #256,%d0
    jbeq DECL_DRVR_ENET_GetInfo_534_2C
    movel %d0,%a2@(20)
    addql #1,%a0@
    cmpil #4,%a0@
    jbcs DECL_DRVR_ENET_GetInfo_534_2C
    movel %a2@(28),%d0
    btst #0,%d0
    jbne DECL_DRVR_ENET_GetInfo_534_2C
    moveq #2,%d0
    movel %d0,%a2@
    rts
DECL_DRVR_ENET_GetInfo_534_2C:/* done sending: next pending list goes to the chip (CTDA, TXP) */
    clrl %a0@
    moveal %pc@(DECL_DRVR_ENET_GetInfo_344),%a1
    jsr %a1@
    movel %d0,%sp@-
    lea %pc@(DECL_DRVR_ENET_GetInfo_2E8),%a0
    moveal %a0@,%a3
    lea %pc@(DECL_DRVR_ENET_GetInfo_2F4),%a1
    movel %a1@,%a0@
    jbeq DECL_DRVR_ENET_GetInfo_534_58
    clrl %a1@
    movel %a0@,%d0
    subl %pc@(DECL_DRVR_ENET_GetInfo_2EC),%d0
    addl %pc@(DECL_DRVR_ENET_GetInfo_2F0),%d0
    movel %d0,%a2@(28)
    moveq #2,%d0
    movel %d0,%a2@
DECL_DRVR_ENET_GetInfo_534_58:/* restore interrupts */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_348),%a0
    jsr %a0@
DECL_DRVR_ENET_GetInfo_534_5E:/* per completed descriptor: callback; statistics from its status */
    movel %pc@(DECL_DRVR_ENET_GetInfo_328),%sp@-
    moveml %a3,%sp@-
    moveal %pc@(DECL_DRVR_ENET_GetInfo_32C),%a0
    jsr %a0@
    addqw #8,%sp
    movel %a3@,%d0
    andiw #-2048,%d0
    moveal %pc@(DECL_DRVR_ENET_GetInfo_34C),%a0
    cmpiw #2048,%d0
    jbcs DECL_DRVR_ENET_GetInfo_534_8E
    jbhi DECL_DRVR_ENET_GetInfo_534_86
    addql #1,%a0@(4)
    jbra DECL_DRVR_ENET_GetInfo_534_8A
DECL_DRVR_ENET_GetInfo_534_86:/* 2 or more collisions */
    addql #1,%a0@(8)
DECL_DRVR_ENET_GetInfo_534_8A:/* any collisions */
    addql #1,%a0@(12)
DECL_DRVR_ENET_GetInfo_534_8E:/* status 1: clean */
    movel %a3@,%d1
    cmpiw #1,%d1
    jbne DECL_DRVR_ENET_GetInfo_534_9A
    addql #1,%a0@
    jbra DECL_DRVR_ENET_GetInfo_534_DA
DECL_DRVR_ENET_GetInfo_534_9A:/* bit 0 sent; bit 9 */
    btst #0,%d1
    jbeq DECL_DRVR_ENET_GetInfo_534_AC
    addql #1,%a0@
    btst #9,%d1
    jbeq DECL_DRVR_ENET_GetInfo_534_AC
    addql #1,%a0@(16)
DECL_DRVR_ENET_GetInfo_534_AC:/* bit 5 */
    btst #5,%d1
    jbeq DECL_DRVR_ENET_GetInfo_534_B6
    addql #1,%a0@(20)
DECL_DRVR_ENET_GetInfo_534_B6:/* bit 6 */
    btst #6,%d1
    jbeq DECL_DRVR_ENET_GetInfo_534_C0
    addql #1,%a0@(24)
DECL_DRVR_ENET_GetInfo_534_C0:/* bit 10 */
    btst #10,%d1
    jbeq DECL_DRVR_ENET_GetInfo_534_CA
    addql #1,%a0@(28)
DECL_DRVR_ENET_GetInfo_534_CA:/* bit 2 or 1 */
    btst #2,%d1
    jbne DECL_DRVR_ENET_GetInfo_534_D6
    btst #1,%d1
    jbeq DECL_DRVR_ENET_GetInfo_534_DA
DECL_DRVR_ENET_GetInfo_534_D6:/* count */
    addql #1,%a0@(32)
DECL_DRVR_ENET_GetInfo_534_DA:/* descriptor back to the free list; next one by its link, until EOL */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_344),%a1
    jsr %a1@
    movel %a3@(12),%d0
    addw %d0,%d0
    movew %d0,%sp@-
    addw %d0,%d0
    addw %sp@+,%d0
    addw %d0,%d0
    lea %pc@(DECL_DRVR_ENET_GetInfo_2F8),%a0
    movel %a0@,%a3@
    movel %a3,%a0@
    lea %a3@(16),%a3
    lea %a3@(0x0,%d0:w),%a3
    movel %a3@,%d0
    btst #0,%d0
    jbne DECL_DRVR_ENET_GetInfo_534_122
    movel %a2@(24),%d1
    swap %d1
    movew %d0,%d1
    subl %pc@(DECL_DRVR_ENET_GetInfo_2F0),%d1
    addl %pc@(DECL_DRVR_ENET_GetInfo_2EC),%d1
    moveal %d1,%a3
    moveal %pc@(DECL_DRVR_ENET_GetInfo_348),%a1
    jsr %a1@
    jbra DECL_DRVR_ENET_GetInfo_534_5E
DECL_DRVR_ENET_GetInfo_534_122:/* return */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_348),%a1
    jsr %a1@
    addqw #4,%sp
    rts

/* subroutine (88 instructions): calls DECL_DRVR_ENET_GetInfo_3D2 (mechanical summary) */
DECL_DRVR_ENET_GetInfo_660:/* PKTRX: descriptors the chip has released, back */
    movel %pc@(DECL_DRVR_ENET_GetInfo_340),%d0
    jbeq DECL_DRVR_ENET_GetInfo_660_26
    lea %pc@(DECL_DRVR_ENET_GetInfo_340),%a3
    moveal %d0,%a1
DECL_DRVR_ENET_GetInfo_660_C:/* loop: still owned: keep */
    movel %a1@,%d1
    movel %a1@(24),%d0
    tstw %d0
    jbmi DECL_DRVR_ENET_GetInfo_660_1E
    jbsr DECL_DRVR_ENET_GetInfo_3D2
    movel %d1,%a3@
    moveal %a3,%a1
DECL_DRVR_ENET_GetInfo_660_1E:/* next */
    moveal %a1,%a3
    moveal %d1,%a1
    tstl %d1
    jbne DECL_DRVR_ENET_GetInfo_660_C
DECL_DRVR_ENET_GetInfo_660_26:/* per received packet: pass status, length, buffer to the callback; statistics */
    movel %pc@(DECL_DRVR_ENET_GetInfo_338),%d0
    jbeq DECL_DRVR_ENET_GetInfo_660_F2
    moveal %d0,%a3
    movel %a3@,%d0
    tstw %d0
    jbeq DECL_DRVR_ENET_GetInfo_660_F2
    movel %a3,%sp@-
    movel %pc@(DECL_DRVR_ENET_GetInfo_320),%sp@-
    movel %a3@(12),%d0
    swap %d0
    movel %a3@(8),%d1
    movew %d1,%d0
    subl %pc@(DECL_DRVR_ENET_GetInfo_310),%d0
    addl %pc@(DECL_DRVR_ENET_GetInfo_30C),%d0
    movel %d0,%sp@-
    subl %d0,%d0
    movel %a3@(4),%d0
    movel %d0,%sp@-
    subl %d0,%d0
    movel %a3@,%d0
    movel %d0,%sp@-
    subl %d1,%d1
    movel %a3@(20),%d2
    btst #0,%d2
    jbne DECL_DRVR_ENET_GetInfo_660_7E
    movel %a2@(52),%d1
    swap %d1
    movew %d2,%d1
    subl %pc@(DECL_DRVR_ENET_GetInfo_31C),%d1
    addl %pc@(DECL_DRVR_ENET_GetInfo_318),%d1
DECL_DRVR_ENET_GetInfo_660_7E:/* into the list of packets being handled */
    lea %pc@(DECL_DRVR_ENET_GetInfo_350),%a1
    clrl %a3@
    clrb %a3@(4)
    tstl %a1@+
    jbne DECL_DRVR_ENET_GetInfo_660_92
    movel %a3,%a1@
    movel %a3,%a1@-
    jbra DECL_DRVR_ENET_GetInfo_660_98
DECL_DRVR_ENET_GetInfo_660_92:/* append */
    moveal %a1@,%a0
    movel %a3,%a0@
    movel %a3,%a1@
DECL_DRVR_ENET_GetInfo_660_98:/* call the receive callback */
    moveal %d1,%a3
    lea %pc@(DECL_DRVR_ENET_GetInfo_338),%a0
    movel %a3,%a0@
    moveal %pc@(DECL_DRVR_ENET_GetInfo_324),%a0
    jsr %a0@
    movel %sp@+,%d1
    lea %sp@(16),%sp
    moveal %pc@(DECL_DRVR_ENET_GetInfo_34C),%a0
    movew #1,%d0
    andw %d1,%d0
    jbeq DECL_DRVR_ENET_GetInfo_660_D8
    addql #1,%a0@(36)
    movew #256,%d0
    andw %d1,%d0
    jbeq DECL_DRVR_ENET_GetInfo_660_C8
    addql #1,%a0@(40)
DECL_DRVR_ENET_GetInfo_660_C8:/* count broadcast/multicast */
    andiw #128,%d1
    jbeq DECL_DRVR_ENET_GetInfo_660_26
    addql #1,%a0@(44)
    jbra DECL_DRVR_ENET_GetInfo_660_26
DECL_DRVR_ENET_GetInfo_660_D8:/* CRC error */
    btst #3,%d1
    jbeq DECL_DRVR_ENET_GetInfo_660_E2
    addql #1,%a0@(48)
DECL_DRVR_ENET_GetInfo_660_E2:/* frame alignment error */
    btst #2,%d1
    jbeq DECL_DRVR_ENET_GetInfo_660_26
    addql #1,%a0@(52)
    jbra DECL_DRVR_ENET_GetInfo_660_26
DECL_DRVR_ENET_GetInfo_660_F2:/* rearm the watchdog */
    movel #61568,%a2@(164)
    movel #762,%a2@(168)
    movel #128,%d0
    movel %d0,%a2@(20)
    rts

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_76E:
    rts	| 408FEFF0

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_770:
    rts	| 408FEFF2

/* subroutine (1 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_772:
    rts

/* subroutine (173 instructions): calls DECL_DRVR_ENET_GetInfo_9D0, DECL_DRVR_ENET_GetInfo_358, DECL_DRVR_ENET_GetInfo_3C4, DECL_DRVR_ENET_GetInfo_374 (mechanical summary) */
DECL_DRVR_ENET_GetInfo_774:
    rts

DECL_DRVR_ENET_GetInfo_776:/* chip init (parameters on the stack): reset; handlers; DCR; RCR; TDA (15 descriptors of 212 bytes); CAM; RBA; RDA; RRA; own CAM; start */
    linkw %fp,#0
    movel %a2,%sp@-
    moveq #-1,%d0
    cmpil #6520,%fp@(36)
    jbcs DECL_DRVR_ENET_GetInfo_776_254
    moveal %fp@(8),%a2
    lea %pc@(DECL_DRVR_ENET_GetInfo_324),%a0
    movel %fp@(16),%a0@
    lea %pc@(DECL_DRVR_ENET_GetInfo_320),%a0
    movel %fp@(20),%a0@
    lea %pc@(DECL_DRVR_ENET_GetInfo_32C),%a0
    movel %fp@(24),%a0@
    lea %pc@(DECL_DRVR_ENET_GetInfo_328),%a0
    movel %fp@(28),%a0@
    lea %pc@(DECL_DRVR_ENET_GetInfo_344),%a0
    movel %fp@(44),%a0@
    lea %pc@(DECL_DRVR_ENET_GetInfo_348),%a0
    movel %fp@(48),%a0@
    lea %pc@(DECL_DRVR_ENET_GetInfo_34C),%a0
    movel %fp@(52),%a0@
    subl %d0,%d0
    movel %d0,%a2@(16)
    bset #7,%d0
    movel %d0,%a2@
    pea %pc@(DECL_DRVR_ENET_GetInfo_45A)
    moveal %fp@(12),%a0
    jsr %a0@
    addqw #4,%sp
    movel %fp@(56),%d0
    movel %d0,%a2@(4)
    subl %d0,%d0
    bset #15,%d0
    movel %a2@(160),%d1
    cmpiw #3,%d1
    jbls DECL_DRVR_ENET_GetInfo_776_84
    bset #14,%d0
DECL_DRVR_ENET_GetInfo_776_84:/* RCR: accept broadcast, promiscuous off */
    bset #13,%d0
    movel %d0,%a2@(8)
    movel %fp@(40),%d0
    muluw #28,%d0
    addil #3428,%d0
    addl %fp@(32),%d0
    subql #1,%d0
    clrw %d0
    movel %fp@(32),%d1
    clrw %d1
    cmpl %d1,%d0
    jbeq DECL_DRVR_ENET_GetInfo_776_BE
    addil #65536,%d1
    subl %fp@(32),%d1
    addl %d1,%fp@(32)
    subl %d1,%fp@(36)
DECL_DRVR_ENET_GetInfo_776_BE:/* the transmit descriptor area, within one 64K bank */
    movel #3392,%d0
    lea %pc@(DECL_DRVR_ENET_GetInfo_2F8),%a1
    movel %fp@(32),%a1@
    lea %pc@(DECL_DRVR_ENET_GetInfo_2E8),%a1
    jbsr DECL_DRVR_ENET_GetInfo_9D0
    moveal %fp@(32),%a1
    movel %a1,%d1
    subl %pc@(DECL_DRVR_ENET_GetInfo_2EC),%d1
    addl %pc@(DECL_DRVR_ENET_GetInfo_2F0),%d1
    swap %d1
    movel %d1,%a2@(24)
    addl %d0,%fp@(32)
    subl %d0,%fp@(36)
    moveq #14,%d1
DECL_DRVR_ENET_GetInfo_776_F2:/* loop: link them */
    pea %a1@(212)
    movel %sp@,%a1@
    moveal %sp@+,%a1
    dbf %d1,DECL_DRVR_ENET_GetInfo_776_F2
    moveq #36,%d0
    lea %pc@(DECL_DRVR_ENET_GetInfo_2FC),%a1
    movel %fp@(32),%a1@
    jbsr DECL_DRVR_ENET_GetInfo_9D0
    movel %fp@(32),%d1
    subl %pc@(DECL_DRVR_ENET_GetInfo_300),%d1
    addl %pc@(DECL_DRVR_ENET_GetInfo_304),%d1
    swap %d1
    movel %d1,%a2@(80)
    addl %d0,%fp@(32)
    subl %d0,%fp@(36)
    movel %fp@(36),%d0
    divuw #1546,%d0
    extl %d0
    cmpl %fp@(40),%d0
    jbls DECL_DRVR_ENET_GetInfo_776_13A
    movel %fp@(40),%d0
DECL_DRVR_ENET_GetInfo_776_13A:/* the receive descriptor area: 28 bytes each */
    lea %pc@(DECL_DRVR_ENET_GetInfo_334),%a1
    movel %d0,%a1@
    lea %pc@(DECL_DRVR_ENET_GetInfo_314),%a1
    movel %fp@(32),%a1@
    jbsr DECL_DRVR_ENET_GetInfo_9D0
    lea %pc@(DECL_DRVR_ENET_GetInfo_338),%a1
    movel %fp@(32),%a1@
    movel %pc@(DECL_DRVR_ENET_GetInfo_334),%d0
    movel %d0,%d1
    muluw #28,%d1
    addl %d1,%fp@(32)
    subl %d1,%fp@(36)
    subql #1,%d0
    moveal %pc@(DECL_DRVR_ENET_GetInfo_314),%a0
DECL_DRVR_ENET_GetInfo_776_16C:/* per descriptor: link; the last has EOL */
    tstl %d0
    jbne DECL_DRVR_ENET_GetInfo_776_178
    subl %d1,%d1
    bset #0,%d1
    jbra DECL_DRVR_ENET_GetInfo_776_186
DECL_DRVR_ENET_GetInfo_776_178:/* next */
    pea %a0@(28)
    movel %sp@+,%d1
    subl %pc@(DECL_DRVR_ENET_GetInfo_318),%d1
    addl %pc@(DECL_DRVR_ENET_GetInfo_31C),%d1
DECL_DRVR_ENET_GetInfo_776_186:/* chip owns it */
    movel %d1,%a0@(20)
    moveq #-1,%d1
    movel %d1,%a0@(24)
    lea %a0@(28),%a0
    dbf %d0,DECL_DRVR_ENET_GetInfo_776_16C
    pea %a0@(-28)
    lea %pc@(DECL_DRVR_ENET_GetInfo_33C),%a1
    movel %sp@+,%a1@
    movel %pc@(DECL_DRVR_ENET_GetInfo_334),%d0
    muluw #1518,%d0
    lea %pc@(DECL_DRVR_ENET_GetInfo_308),%a1
    movel %fp@(32),%a1@
    jbsr DECL_DRVR_ENET_GetInfo_9D0
    addl %d0,%fp@(32)
    subl %d0,%fp@(36)
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2FC),%a0
    lea %a0@(20),%a1
    pea %a1@
    movel %a1,%d0
    subl %pc@(DECL_DRVR_ENET_GetInfo_300),%d0
    addl %pc@(DECL_DRVR_ENET_GetInfo_304),%d0
    movel %d0,%a2@(92)
    movel %d0,%a2@(84)
    addiw #16,%d0
    movel %d0,%a2@(88)
    subl %d0,%d0
    movel %d0,%a2@(96)
    movel %pc@(DECL_DRVR_ENET_GetInfo_308),%d0
    subl %pc@(DECL_DRVR_ENET_GetInfo_30C),%d0
    addl %pc@(DECL_DRVR_ENET_GetInfo_310),%d0
    moveal %sp@+,%a1
    movel %d0,%a1@
    swap %d0
    movel %d0,%a1@(4)
    movel %pc@(DECL_DRVR_ENET_GetInfo_334),%d1
    muluw #759,%d1
    movel %d1,%a1@(8)
    swap %d1
    movel %d1,%a1@(12)
    moveq #-1,%d0
    movel %d0,%a2@(20)
    jbsr DECL_DRVR_ENET_GetInfo_358
    subl %d0,%d0
    movel %d0,%a2@
DECL_DRVR_ENET_GetInfo_776_21E:/* wait for reset; RRRA (read the resource table); CRDA, URDA; start; IMR 0x46B1; return the unused memory */
    movel %a2@,%d0
    btst #7,%d0
    jbne DECL_DRVR_ENET_GetInfo_776_21E
    moveq #8,%d0
    jbsr DECL_DRVR_ENET_GetInfo_3C4
    movel %pc@(DECL_DRVR_ENET_GetInfo_314),%d0
    subl %pc@(DECL_DRVR_ENET_GetInfo_318),%d0
    addl %pc@(DECL_DRVR_ENET_GetInfo_31C),%d0
    movel %d0,%a2@(56)
    swap %d0
    movel %d0,%a2@(52)
    jbsr DECL_DRVR_ENET_GetInfo_374
    movel #18097,%d0
    movel %d0,%a2@(16)
    movel %fp@(36),%d0
DECL_DRVR_ENET_GetInfo_776_254:/* return */
    moveal %sp@+,%a2
    unlk %fp
    rts

/* subroutine (12 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_9D0:/* note a block's logical and physical address */
    movel %d0,%sp@-
    movel %a1,%sp@-
    movel %d0,%sp@-
    movel %fp@(32),%sp@-
    moveal %fp@(60),%a0
    jsr %a0@
    addqw #8,%sp
    moveal %sp@+,%a1
    movel %d0,%a1@(8)
    movel %fp@(32),%a1@(4)
    movel %sp@+,%d0
    rts

/* subroutine (22 instructions): calls DECL_DRVR_ENET_GetInfo_3A8 (mechanical summary) */
DECL_DRVR_ENET_GetInfo_9F2:/* chip stop: disable, IMR 0, CE 0 */
    linkw %fp,#0
    movel %a2,%sp@-
    moveal %pc@(DECL_DRVR_ENET_GetInfo_344),%a0
    jsr %a0@
    movel %d0,%sp@-
    moveal %fp@(8),%a2
    jbsr DECL_DRVR_ENET_GetInfo_3A8
    subl %d0,%d0
    movel %d0,%a2@(16)
    movel %d0,%a2@(148)
    moveal %pc@(DECL_DRVR_ENET_GetInfo_348),%a0
    jsr %a0@
    addqw #4,%sp
    moveal %sp@+,%a2
    unlk %fp
    rts
DECL_DRVR_ENET_GetInfo_9F2_2E:/* no descriptor: error */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_348),%a0
    movel %d0,%sp@-
    jsr %a0@
    moveq #-1,%d0
    unlk %fp
    rts

/* subroutine (103 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_A2E:/* send a buffer: take a transmit descriptor; fragment per WDS entry; pad below 60 bytes */
    linkw %fp,#-4
    moveal %pc@(DECL_DRVR_ENET_GetInfo_344),%a0
    jsr %a0@
    movel %pc@(DECL_DRVR_ENET_GetInfo_2F8),%d1
    jbeq DECL_DRVR_ENET_GetInfo_9F2_2E
    movel %a2,%fp@(-4)
    movel %d0,%sp@-
    lea %pc@(DECL_DRVR_ENET_GetInfo_2F8),%a0
    moveal %a0@,%a1
    movel %a1@,%a0@
    exg %a1,%a2
    moveal %pc@(DECL_DRVR_ENET_GetInfo_348),%a0
    jsr %a0@
    exg %a1,%a2
    moveal %fp@(12),%a2
    subl %d0,%d0
    movel %d0,%a1@(12)
    movel %d0,%a1@(8)
    movel %d0,%a1@
    movel %d0,%a1@(4)
    lea %a1@(16),%a0
DECL_DRVR_ENET_GetInfo_A2E_40:/* per entry: address and length */
    subl %d0,%d0
    movew %a2@+,%d0
    jbeq DECL_DRVR_ENET_GetInfo_A2E_5E
    addql #1,%a1@(12)
    addl %d0,%a1@(8)
    movel %d0,%sp@-
    movel %a2@+,%d0
    movel %d0,%a0@+
    swap %d0
    movel %d0,%a0@+
    movel %sp@+,%d0
    movel %d0,%a0@+
    jbra DECL_DRVR_ENET_GetInfo_A2E_40
DECL_DRVR_ENET_GetInfo_A2E_5E:/* pad up to 60 from the padding buffer */
    movel %a1@(8),%d0
    extl %d0
    subil #60,%d0
    jbcc DECL_DRVR_ENET_GetInfo_A2E_8A
    negl %d0
    addql #1,%a1@(12)
    addl %d0,%a1@(8)
    movel %pc@(DECL_DRVR_ENET_GetInfo_308),%d1
    subl %pc@(DECL_DRVR_ENET_GetInfo_30C),%d1
    addl %pc@(DECL_DRVR_ENET_GetInfo_310),%d1
    movel %d1,%a0@+
    swap %d1
    movel %d1,%a0@+
    movel %d0,%a0@+
DECL_DRVR_ENET_GetInfo_A2E_8A:/* EOL; link after the descriptors waiting */
    moveq #1,%d0
    movel %d0,%a0@
    exg %a1,%a2
    moveal %pc@(DECL_DRVR_ENET_GetInfo_344),%a0
    jsr %a0@
    exg %a1,%a2
    moveal %fp@(8),%a2
    movel %pc@(DECL_DRVR_ENET_GetInfo_2F4),%d0
    jbne DECL_DRVR_ENET_GetInfo_A2E_AA
    lea %pc@(DECL_DRVR_ENET_GetInfo_2F4),%a0
    movel %a1,%a0@
    jbra DECL_DRVR_ENET_GetInfo_A2E_EA
DECL_DRVR_ENET_GetInfo_A2E_AA:/* the last one queued */
    moveal %d0,%a0
    movel %a2@(24),%d1
    swap %d1
DECL_DRVR_ENET_GetInfo_A2E_B2:/* loop: to its end */
    movel %a0@(12),%d0
    addw %d0,%d0
    movew %d0,%sp@-
    addw %d0,%d0
    addw %sp@+,%d0
    addw %d0,%d0
    lea %a0@(16),%a0
    lea %a0@(0x0,%d0:w),%a0
    movel %a0@,%d0
    btst #0,%d0
    jbne DECL_DRVR_ENET_GetInfo_A2E_DE
    movew %d0,%d1
    subl %pc@(DECL_DRVR_ENET_GetInfo_2F0),%d1
    addl %pc@(DECL_DRVR_ENET_GetInfo_2EC),%d1
    moveal %d1,%a0
    jbra DECL_DRVR_ENET_GetInfo_A2E_B2
DECL_DRVR_ENET_GetInfo_A2E_DE:/* link */
    movel %a1,%d0
    subl %pc@(DECL_DRVR_ENET_GetInfo_2EC),%d0
    addl %pc@(DECL_DRVR_ENET_GetInfo_2F0),%d0
    movel %d0,%a0@
DECL_DRVR_ENET_GetInfo_A2E_EA:/* chip idle: start it */
    lea %pc@(DECL_DRVR_ENET_GetInfo_2E8),%a0
    tstl %a0@
    jbne DECL_DRVR_ENET_GetInfo_A2E_10E
    lea %pc@(DECL_DRVR_ENET_GetInfo_2F4),%a1
    movel %a1@,%a0@
    moveq #0,%d0
    movel %d0,%a1@
    movel %a0@,%d0
    subl %pc@(DECL_DRVR_ENET_GetInfo_2EC),%d0
    addl %pc@(DECL_DRVR_ENET_GetInfo_2F0),%d0
    movel %d0,%a2@(28)
    moveq #2,%d0
    movel %d0,%a2@
DECL_DRVR_ENET_GetInfo_A2E_10E:/* return */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_348),%a0
    jsr %a0@
    addqw #4,%sp
    moveal %fp@(-4),%a2
    unlk %fp
    subl %d0,%d0
    rts

/* subroutine (78 instructions): calls DECL_DRVR_ENET_GetInfo_C2E, DECL_DRVR_ENET_GetInfo_3A8, DECL_DRVR_ENET_GetInfo_374 (mechanical summary) */
DECL_DRVR_ENET_GetInfo_B4E:/* add (d1,d2 ; nonzero fourth arg) or remove a CAM entry */
    linkw %fp,#0
    moveml %d3-%d4/%a2,%sp@-
    moveal %pc@(DECL_DRVR_ENET_GetInfo_344),%a0
    jsr %a0@
    movel %d0,%sp@-
    moveal %fp@(8),%a2
    movel %fp@(12),%d1
    movew %fp@(16),%d2
    tstl %fp@(18)
    jbeq DECL_DRVR_ENET_GetInfo_B4E_68
DECL_DRVR_ENET_GetInfo_B4E_22:/* wait for ST + RXEN */
    movel %a2@,%d0
    eoriw #40,%d0
    jbne DECL_DRVR_ENET_GetInfo_B4E_22
    movel %a2@(148),%d0
    moveq #15,%d3
DECL_DRVR_ENET_GetInfo_B4E_30:/* a free CAM entry */
    aslw #1,%d0
    dbcc %d3,DECL_DRVR_ENET_GetInfo_B4E_30
    jbcc DECL_DRVR_ENET_GetInfo_B4E_40
    movew %d3,%d0
    extl %d0
    jbra DECL_DRVR_ENET_GetInfo_B4E_D0
DECL_DRVR_ENET_GetInfo_B4E_40:/* write it (byte-swapped), enable bit; LCAM */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2FC),%a0
    rorw #8,%d2
    movel %d2,%a0@(12)
    rorw #8,%d1
    movel %d1,%a0@(8)
    swap %d1
    rorw #8,%d1
    movel %d1,%a0@(4)
    movel %a2@(148),%d0
    bset %d3,%d0
    movel %d0,%a0@(16)
    jbsr DECL_DRVR_ENET_GetInfo_C2E
    movel %d3,%d0
    jbra DECL_DRVR_ENET_GetInfo_B4E_D0
DECL_DRVR_ENET_GetInfo_B4E_68:/* remove: stop the chip; search the enabled entries */
    jbsr DECL_DRVR_ENET_GetInfo_3A8
    moveq #15,%d3
    movel %a2@(148),%d0
DECL_DRVR_ENET_GetInfo_B4E_72:/* loop */
    aslw #1,%d0
    dbcs %d3,DECL_DRVR_ENET_GetInfo_B4E_72
    jbcs DECL_DRVR_ENET_GetInfo_B4E_8A
DECL_DRVR_ENET_GetInfo_B4E_7A:/* not found: restart */
    jbsr DECL_DRVR_ENET_GetInfo_374
    movew %d3,%d0
    extl %d0
    jbra DECL_DRVR_ENET_GetInfo_B4E_D0
DECL_DRVR_ENET_GetInfo_B4E_84:/* next */
    subqw #1,%d3
    jbmi DECL_DRVR_ENET_GetInfo_B4E_7A
    jbra DECL_DRVR_ENET_GetInfo_B4E_72
DECL_DRVR_ENET_GetInfo_B4E_8A:/* read entry d3; compare; clear it; restart; LCAM */
    movel %d3,%a2@(132)
    movel %a2@(140),%d4
    rorw #8,%d4
    movew %d4,%sp@-
    movel %a2@(144),%d4
    rorw #8,%d4
    movew %d4,%sp@-
    cmpl %sp@+,%d1
    jbne DECL_DRVR_ENET_GetInfo_B4E_84
    movel %a2@(136),%d4
    rorw #8,%d4
    cmpw %d4,%d2
    jbne DECL_DRVR_ENET_GetInfo_B4E_84
    moveal %pc@(DECL_DRVR_ENET_GetInfo_2FC),%a0
    subl %d2,%d2
    movel %d2,%a0@(12)
    movel %d2,%a0@(8)
    movel %d2,%a0@(4)
    movel %a2@(148),%d0
    bclr %d3,%d0
    movel %d0,%a0@(16)
    jbsr DECL_DRVR_ENET_GetInfo_374
    jbsr DECL_DRVR_ENET_GetInfo_C2E
    subl %d0,%d0
DECL_DRVR_ENET_GetInfo_B4E_D0:/* restore interrupts */
    moveal %pc@(DECL_DRVR_ENET_GetInfo_348),%a0
    jsr %a0@
    addqw #4,%sp
    moveml %sp@+,%d3-%d4/%a2
    unlk %fp
    rts

/* subroutine (9 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_C2E:/* LCAM with the descriptor */
    movel %d3,%a0@
    movel %a0,%d0
    subl %pc@(DECL_DRVR_ENET_GetInfo_300),%d0
    addl %pc@(DECL_DRVR_ENET_GetInfo_304),%d0
    movel %d0,%a2@(152)
    moveq #1,%d0
    movel %d0,%a2@(156)
    moveq #9,%d0
    jbra DECL_DRVR_ENET_GetInfo_3C4

/* subroutine (155 instructions): calls DECL_DRVR_ENET_GetInfo_E74, DECL_DRVR_ENET_GetInfo_E5A, DECL_DRVR_ENET_GetInfo_C4A, DECL_DRVR_ENET_GetInfo_E6A, DECL_DRVR_ENET_GetInfo_E86; low memory Apple, Computer, MemErr (mechanical summary) */
DECL_DRVR_ENET_GetInfo_C4A:/* undo the loopback test: cancel the read, detach protocol */
    moveml %a3-%a4,%sp@-
    moveal %sp@(16),%a4
    moveal %sp@(12),%a3
    movew #251,%a3@(26)
    movel %a4,%a3@(30)
    subql #2,%sp
    movel %a3,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E74)
    movew #248,%a3@(26)
    subql #2,%sp
    movel %a3,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E74)
    addql #4,%sp
    moveml %sp@+,%a3-%a4
    rts

DECL_DRVR_ENET_GetInfo_C86:/* loopback test: attach protocol 0x809B, read, send the copyright string to ourselves; 3-second timeout; compare */
    linkw %fp,#-264
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    lea %fp@(-56),%a3
    lea %pc@(DECL_DRVR_ENET_GetInfo_E1E),%a0
    lea %fp@(-36),%a1
    moveq #7,%d0
DECL_DRVR_ENET_GetInfo_C86_1A:/* copy the test string */
    movel %a0@+,%a1@+
    dbf %d0,DECL_DRVR_ENET_GetInfo_C86_1A
    movew %a0@+,%a1@+
    moveb %a0@,%a1@
    movew %fp@(10),%fp@(-132)
    moveq #0,%d0
    movel %d0,%fp@(-144)
    movew #247,%fp@(-130)
    movew #-32613,%fp@(-128)
    movel %d0,%fp@(-126)
    subql #2,%sp
    pea %fp@(-156)
    moveq #0,%d1
    moveb %d1,%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E74)
    tstw %sp@+
    jbeq DECL_DRVR_ENET_GetInfo_C86_58
    moveq #0,%d0
    jbra DECL_DRVR_ENET_GetInfo_C86_18E
DECL_DRVR_ENET_GetInfo_C86_58:/* post the read */
    movew #250,%fp@(-130)
    lea %fp@(-264),%a0
    movel %a0,%fp@(-126)
    movew #54,%fp@(-122)
    subql #2,%sp
    pea %fp@(-156)
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E74)
    tstw %sp@+
    jbeq DECL_DRVR_ENET_GetInfo_C86_9A
    movew #248,%fp@(-130)
    subql #2,%sp
    pea %fp@(-156)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E74)
    moveq #0,%d0
    addql #2,%sp
    jbra DECL_DRVR_ENET_GetInfo_C86_18E
DECL_DRVR_ENET_GetInfo_C86_9A:/* send it */
    lea %fp@(-106),%a0
    lea %fp@(-156),%a1
    moveq #11,%d0
DECL_DRVR_ENET_GetInfo_C86_A4:/* loop */
    movel %a1@+,%a0@+
    dbf %d0,DECL_DRVR_ENET_GetInfo_C86_A4
    movew %a1@+,%a0@+
    movew #54,%a3@
    lea %fp@(-210),%a0
    movel %a0,%a3@(2)
    clrw %a3@(6)
    lea %fp@(-210),%a0
    moveal %a4,%a1
    movel %a1@+,%a0@+
    movew %a1@+,%a0@+
    lea %fp@(-204),%a0
    moveal %a4,%a1
    movel %a1@+,%a0@+
    movew %a1@+,%a0@+
    movew #-32613,%fp@(-198)
    pea %fp@(-36)
    pea %fp@(-196)
    moveq #35,%d0
    movel %d0,%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E5A)
    movel %a3,%fp@(-76)
    movew #249,%fp@(-80)
    subql #2,%sp
    pea %fp@(-106)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E74)
    tstw %sp@+
    jbeq DECL_DRVR_ENET_GetInfo_C86_114
    pea %fp@(-156)
    pea %fp@(-106)
    jsr %pc@(DECL_DRVR_ENET_GetInfo_C4A)
    moveq #0,%d0
    addql #8,%sp
    jbra DECL_DRVR_ENET_GetInfo_C86_18E
DECL_DRVR_ENET_GetInfo_C86_114:/* start the timer */
    pea %fp@(-44)
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E6A)
    jbra DECL_DRVR_ENET_GetInfo_C86_146
DECL_DRVR_ENET_GetInfo_C86_11E:/* loop: time up: undo */
    pea %fp@(-40)
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E6A)
    movel %fp@(-40),%d0
    subl %fp@(-44),%d0
    moveq #3,%d1
    cmpl %d0,%d1
    jbcc DECL_DRVR_ENET_GetInfo_C86_146
    pea %fp@(-156)
    pea %fp@(-106)
    jsr %pc@(DECL_DRVR_ENET_GetInfo_C4A)
    moveq #0,%d0
    addql #8,%sp
    jbra DECL_DRVR_ENET_GetInfo_C86_18E
DECL_DRVR_ENET_GetInfo_C86_146:/* read still pending? detach; compare the text */
    moveq #1,%d0
    cmpw %fp@(-140),%d0
    jbeq DECL_DRVR_ENET_GetInfo_C86_11E
    movew #248,%fp@(-80)
    subql #2,%sp
    pea %fp@(-106)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E74)
    movel %d0,%sp@-
    moveq #0,%d1
    movel %d1,%sp@-
    moveq #1,%d2
    movel %d2,%sp@-
    pea %fp@(-196)
    pea %fp@(-250)
    jsr %pc@(DECL_DRVR_ENET_GetInfo_E86)
    lea %sp@(16),%sp
    movel %d0,%d1
    movel %sp@+,%d0
    moveq #0,%d2
    tstb %d1
    seq %d2
    negb %d2
    seq %d0
    negb %d0
    addql #2,%sp
DECL_DRVR_ENET_GetInfo_C86_18E:/* return */
    moveml %fp@(-272),%a3-%a4
    unlk %fp
    rts
DECL_DRVR_ENET_GetInfo_E1E:/* test string; glue routines follow */
    .short  0x2863, 0x2920, 0x3139, 0x3930, 0x2D31	| 408FF6A0
    .ascii  "992 Apple Computer, Inc.\000"
    .byte   0x00, 0x22, 0x5F, 0x20, 0x1F, 0xA0, 0x4C, 0x2E, 0x80, 0x4E, 0x71, 0x70, 0x00	| 408FF6C3
DECL_DRVR_ENET_Control_122C:/* MemErr (BlockMove glue) */
    movel %a1,%sp@-
DECL_DRVR_ENET_Control_122E:  /* loop: move */
    movew %d0,MemErr
    rts
    moveq #0,%d0
    jbra DECL_DRVR_ENET_Control_122E

/* subroutine (7 instructions): traps BlockMove (mechanical summary) */
DECL_DRVR_ENET_GetInfo_E5A:/* BlockMove with stack arguments */
    movel %sp@+,%d1
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _BlockMove
    moveal %d1,%a1
    jmp %pc@(DECL_DRVR_ENET_Control_122C)

/* subroutine (4 instructions): low memory Time (mechanical summary) */
DECL_DRVR_ENET_GetInfo_E6A:/* Time into the argument */
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    movel Time,%a0@
    jmp %a1@

/* subroutine (8 instructions): traps Control (mechanical summary) */
DECL_DRVR_ENET_GetInfo_E74:/* PBControl, sync or async */
    moveal %sp@+,%a1
    moveb %sp@+,%d0
    moveal %sp@+,%a0
    jbne DECL_DRVR_ENET_GetInfo_E74_C
    _Control
    jbra DECL_DRVR_ENET_GetInfo_E74_E
DECL_DRVR_ENET_GetInfo_E74_C:/* async */
    .short  0xA404	| 408FF702 _Control (flags 0x0400)
DECL_DRVR_ENET_GetInfo_E74_E:/* result */
    movew %d0,%sp@
    jmp %a1@

/* subroutine (40 instructions): traps CmpString; calls DECL_DRVR_ENET_GetInfo_EFC, DECL_DRVR_ENET_GetInfo_F2E (mechanical summary) */
DECL_DRVR_ENET_GetInfo_E86:/* compare two C strings (CmpString) */
    linkw %fp,#0
    moveq #1,%d0
    moveal %fp@(8),%a0
    cmpal %fp@(12),%a0
    jbeq DECL_DRVR_ENET_GetInfo_E86_72
    movel %a0,%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_EFC)
    addqw #4,%sp
    movel %fp@(12),%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_EFC)
    addqw #4,%sp
    moveal %fp@(8),%a0
    moveal %fp@(12),%a1
    moveq #0,%d0
    moveb %a0@+,%d0
    swap %d0
    moveb %a1@+,%d0
    tstl %fp@(20)
    jbeq DECL_DRVR_ENET_GetInfo_E86_46
    tstl %fp@(16)
    jbeq DECL_DRVR_ENET_GetInfo_E86_42
    .short  0xA43C	| 408FF746 _CmpString (flags 0x0400)
    jbra DECL_DRVR_ENET_GetInfo_E86_52
DECL_DRVR_ENET_GetInfo_E86_42:  /* _CmpString */
    _CmpString
    jbra DECL_DRVR_ENET_GetInfo_E86_52
DECL_DRVR_ENET_GetInfo_E86_46:  /* test %fp@(16) */
    tstl %fp@(16)
    jbeq DECL_DRVR_ENET_GetInfo_E86_50
    .short  0xA63C	| 408FF754 _CmpString (flags 0x0600)
    jbra DECL_DRVR_ENET_GetInfo_E86_52
DECL_DRVR_ENET_GetInfo_E86_50:  /* (_CmpString (flags 0x0200)) */
    .short  0xA23C	| 408FF758 _CmpString (flags 0x0200)
DECL_DRVR_ENET_GetInfo_E86_52:/* back to C strings; 1 if equal */
    movew %d0,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_F2E)
    addqw #4,%sp
    movel %fp@(12),%sp@-
    jsr %pc@(DECL_DRVR_ENET_GetInfo_F2E)
    addqw #4,%sp
    movew %sp@+,%d0
    eorib #1,%d0
    extw %d0
    extl %d0
DECL_DRVR_ENET_GetInfo_E86_72:/* return */
    unlk %fp
    rts

/* subroutine (19 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_EFC:/* a C string to Pascal in place */
    movel %sp@(4),%d0
    jbeq DECL_DRVR_ENET_GetInfo_EFC_30
    moveal %d0,%a0
    moveal %a0,%a1
    moveb %a1@+,%d0
    jbeq DECL_DRVR_ENET_GetInfo_EFC_2C
DECL_DRVR_ENET_GetInfo_EFC_E:/* loop: shift right */
    moveb %a1@,%d1
    moveb %d0,%a1@+
    moveb %d1,%d0
    jbne DECL_DRVR_ENET_GetInfo_EFC_E
    subal %a0,%a1
    movel %a1,%d0
    subqw #1,%d0
    cmpil #255,%d0
    jble DECL_DRVR_ENET_GetInfo_EFC_2A
    movel #255,%d0
DECL_DRVR_ENET_GetInfo_EFC_2A:/* the length */
    moveb %d0,%a0@
DECL_DRVR_ENET_GetInfo_EFC_2C:/* return it */
    movel %sp@(4),%d0
DECL_DRVR_ENET_GetInfo_EFC_30:/* return */
    rts

/* subroutine (11 instructions) (mechanical summary) */
DECL_DRVR_ENET_GetInfo_F2E:/* a Pascal string to C in place */
    movel %sp@(4),%d0
    jbeq DECL_DRVR_ENET_GetInfo_F2E_18
    moveal %d0,%a0
    moveq #0,%d0
    moveb %a0@,%d0
    jbra DECL_DRVR_ENET_GetInfo_F2E_12
DECL_DRVR_ENET_GetInfo_F2E_E:/* loop: shift left */
    moveb %a0@(1),%a0@+
DECL_DRVR_ENET_GetInfo_F2E_12:/* next; terminator */
    dbf %d0,DECL_DRVR_ENET_GetInfo_F2E_E
    clrb %a0@
DECL_DRVR_ENET_GetInfo_F2E_18:/* return it */
    movel %sp@(4),%d0
    rts
    .fill   0x7E2, 1, 0x00

/*
 Extended format header, just below the format block: an sExec block that chooses the
 sResource directory for this machine, and the list of directories to choose from.
*/

/* SuperInit record (SExecBlock: size, revision, CPU, code offset): code the Slot Manager runs first to choose the sResource directory for this machine. */
DECL_SUPERINIT:  /* SExecBlock (Designing Cards and Drivers, figure 8-3) */
    .long   DECL_SUPERINIT_end-DECL_SUPERINIT  /* physical block size */
    .byte   2, 2                    /* revision level, CPU ID (68020) */
    .short  0                       /* reserved */
    .long   DECL_SUPERINIT_code-.   /* code offset */

/* subroutine (9 instructions) (mechanical summary) */
DECL_SUPERINIT_code:                /* in: a0 = seBlock; out: seStatus low byte = directory id */
    clrw    %a0@(2)                 /* seStatus = 0 */
    moveb   #127,%d0                /* default: directory 0x7F */
    moveal  0xdd8,%a1               /* pointer in low memory at 0xDD8 */
    addal   %a1@(8),%a1             /* follow the offset 8 bytes into that structure */
    cmpaw   #0,%a1
    beqs    DECL_SUPERINIT_code_1A  /* none: keep 0x7F */
    moveb   %a1@(14),%d0            /* the machine's own directory id */
DECL_SUPERINIT_code_1A:
    moveb   %d0,%a0@(3)
    rts

/* subroutine (0 instructions) (mechanical summary) */
DECL_SUPERINIT_end:

/* Extended format header: entry 1 the SuperInit record, entry 0xFE the list of directories; then the test pattern. */
DECL_EXT_HEADER:
    .byte   0x01, 0xFF, 0xFF, 0xD4	| 408FFFDC s24 -> DECL_SUPERINIT
DECL_EXT_HEADER_FE_entry:  /* (408FFFE0 s24 -> DECL_DIRECTORIES) */
    .byte   0xFE, 0xFF, 0x2C, 0xB4	| 408FFFE0 s24 -> DECL_DIRECTORIES
    .long   0xFF000000              /* end of list */
    .long   0x5A932BC7              /* test pattern */

/* Format block: directory offset, length and CRC (0: not checked), revision, format, test pattern 0x5A932BC7, byte lanes 0x0F. */
DECL_FORMAT_BLOCK:  /* format block (Designing Cards and Drivers, chapter 8), the ROM's last 20 bytes */
    .byte   0x00, 0xFF, 0x2C, 0xB8	/* 408FFFEC directory offset, s24 -> DECL_SRSRC_DIR */
    .long   0                       /* length (0: no CRC check) */
    .long   0                       /* CRC */
    .byte   1, 1                    /* revision level, format (Apple) */
    .long   0x5A932BC7              /* test pattern */
    .byte   0, 0x0F                 /* reserved, byte lanes (all four) */
