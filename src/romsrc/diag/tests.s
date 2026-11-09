/*
 diag/tests.s - diagnostic tests (universal test suite)
 From USTSTRT (0x40846040). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. These are the start-up and factory diagnostic tests (many run before RAM is usable, with return addresses in registers). Routine headers name the job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* USTSTRT: universal start-up tests. */
USTSTRT:
USTTESTS:
    .long   0x00000001	| 40846040
    .long   USTMAINTEST-USTSTRT	| 40846044
    .long   0x00000048, 0x00000000	| 40846048
    .long   0x00000000, 0x00000000, 0x00000002, 0x0008A8A0	| 40846050
    .long   0x00000061, 0x00000000, 0x00000000, 0x00000000	| 40846060
    .long   0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000	| 40846070
    .short  0x0000, 0x0000, 0x0000	| 40846080
    .long   caseD_2-.	| 40846086
    .short  0x4F4D, 0x2062, 0x6173	| 4084608A
    .long   0x65642074, 0x65737420, 0x28747970, 0x65203229	| 40846090
    .byte   0x00	| 408460A0
    .ascii  "\"SONIC Ethernet controller CTE Test\000"
    .byte   0x00	| 408460C5

/* USTSUBTESTS: table of subtests. */
USTSUBTESTS:
    .short  0x0000, 0x0080	| 408460C6
    .long   SETSCCIOPBYPASS-.	| 408460CA
    .short  0x0000	| 408460CE
    .long   0x02E80000, 0x00000000, 0x00000000, 0x00000000	| 408460D0
    .long   0x00810000, 0x1C440000, 0x03020000, 0x00000000	| 408460E0
    .long   0x00000000, 0x00000000, 0x00820000, 0x1C440000	| 408460F0
    .long   0x03220000, 0x00000000, 0x00000000, 0x00000000	| 40846100
    .long   0x00830000, 0x1C440000, 0x03360000, 0x00000000	| 40846110
    .long   0x00000000, 0x00000000, 0x00840000, 0x1E200000	| 40846120
    .long   0x034D0000, 0x00000000, 0x00000000, 0x00000000	| 40846130
    .long   0x00850000, 0x1D6C0000, 0x03780000, 0x00000000	| 40846140
    .long   0x00000000, 0x00000000, 0x00860000, 0x1F060000	| 40846150
    .long   0x03AC0000, 0x00000000, 0x00000000, 0x00000000	| 40846160
    .long   0x00870000, 0x20040000, 0x03D40000, 0x00000000	| 40846170
    .long   0x00000000, 0x00000000, 0x00880000, 0x21D20000	| 40846180
    .long   0x03F10000, 0x00000000, 0x00000000, 0x00000000	| 40846190
    .long   0x00890000, 0x22BA0000, 0x04050000, 0x00000000	| 408461A0
    .long   0x00000000, 0x00000000, 0x008A0000, 0x26100000	| 408461B0
    .long   0x041A0000, 0x00000000, 0x00000000, 0x00000000	| 408461C0
    .long   0x008B0000, 0x26EC0000, 0x04290000, 0x00000000	| 408461D0
    .long   0x00000000, 0x00000000, 0x008C0000, 0x286E0000	| 408461E0
    .long   0x044E0000, 0x00000000, 0x00000000, 0x00000000	| 408461F0
    .long   0x008D0000, 0x2CF00000, 0x04660000, 0x00000000	| 40846200
    .long   0x00000000, 0x00000000, 0x008E0000, 0x34C80000	| 40846210
    .long   0x047B0000, 0x00000000, 0x00000000, 0x00000000	| 40846220
    .long   0x008F0000, 0x353E0000, 0x048D0000, 0x00000000	| 40846230
    .long   0x00000000, 0x00000000, 0x00900000, 0x35BC0000	| 40846240
    .long   0x04AE0000, 0x00000000, 0x00000000, 0x00000000	| 40846250
    .long   0x00910000, 0x36C40000, 0x04CC0000, 0x00000000	| 40846260
    .long   0x00000000, 0x00000000, 0x00920000, 0x376E0000	| 40846270
    .long   0x04F40000, 0x00000000, 0x00000000, 0x00000000	| 40846280
    .long   0x00930000, 0x37DC0000, 0x051D0000, 0x00000000	| 40846290
    .long   0x00000000, 0x00000000, 0x00940000, 0x38500000	| 408462A0
    .long   0x052F0000, 0x00000000, 0x00000000, 0x00000000	| 408462B0
    .long   0x00950000, 0x39AE0000, 0x05570000, 0x00000000	| 408462C0
    .long   0x00000000, 0x00000000, 0x00960000, 0x3D520000	| 408462D0
    .long   0x05680000, 0x00000000, 0x00000000, 0x00000000	| 408462E0
    .long   0x00970000, 0x41980000, 0x057C0000, 0x00000000	| 408462F0
    .long   0x00000000, 0x00000000, 0x009A0000, 0x429C0000	| 40846300
    .long   0x05870000, 0x00000000, 0x00000000, 0x00000000	| 40846310
    .long   0x009E0000, 0x44340000, 0x059E0000, 0x00000000	| 40846320
    .long   0x00000000, 0x00000000, 0x009F0000, 0x45140000	| 40846330
    .long   0x05AD0000, 0x00000000, 0x00000000, 0x00000000	| 40846340
    .long   0x009B0008, 0x8DFA0000, 0x05BC0000, 0x00000000	| 40846350
    .long   0x000C0000, 0x002C0000, 0x009C0008, 0x92CA0000	| 40846360
    .long   0x05DE0000, 0x00000000, 0x001C0000, 0x00180000	| 40846370
    .long   0x009D0008, 0x954A0000, 0x05FA0000, 0x00000000	| 40846380
    .long   0x00800000, 0x002CFFFF	| 40846390
    .long   0xFFFF0000 /* number, not an address (F5) */	| 40846398
    .long   0x00000000	| 4084639C
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18	| 408463A0
    .ascii  "Portable mapper RAM data\000"
    .byte   0x1E	| 408463C8
    .ascii  "Portable mapper RAM uniqueness\000"
    .byte   0x12	| 408463E8
    .ascii  "Portable VRAM data\000"
    .byte   0x15	| 408463FC
    .ascii  "Portable VRAM address\000"
    .ascii  ")Serial Communications Controller register\000"
    .ascii  "2Serial Communications Controller internal loopback\000"
    .ascii  "&Serial Communications Controller timer\000"
    .byte   0x1B	| 4084649A
    .ascii  "Versatile Interface Adapter\000"
    .byte   0x12	| 408464B7
    .ascii  "SCSI chip register\000"
    .byte   0x13	| 408464CB
    .ascii  "Sound chip register\000"
    .ascii  "\015Parameter RAM\000"
    .ascii  "#RAM Based Video controller register\000"
    .byte   0x16	| 40846514
    .ascii  "Floppy controller chip\000"
    .byte   0x13	| 4084652C
    .ascii  "Floating point unit\000"
    .byte   0x10	| 40846541
    .ascii  "IIci type parity\000"
    .byte   0x1F	| 40846553
    .ascii  "Fast Memory Controller register\000"
    .byte   0x1C	| 40846574
    .ascii  "Fast Memory Controller cache\000"
    .ascii  "&Operating System Support chip register\000"
    .ascii  "'Operating System Support chip interrupt\000"
    .byte   0x10	| 408465E3
    .ascii  "IIfx type parity\000"
    .ascii  "&Apple Desktop Bus microcontroller self\000"
    .byte   0x0F	| 4084661D
    .ascii  "Sound interrupt\000"
    .byte   0x12	| 4084662E
    .ascii  "Color lookup table\000"
    .ascii  "\011Video RAM\000"
    .byte   0x15	| 4084664D
    .ascii  "53C96 Turbo SCSI chip\000"
    .ascii  "\015GSC registers\000"
    .byte   0x0E	| 40846673
    .ascii  "PG&E self test SONIC Ethernet register bitmarch\000"
    .byte   0x1A	| 408466A4
    .ascii  "SONIC Ethernet on-chip DMA\000"
    .ascii  " SONIC Ethernet protocol loopback\000"

/* USTCPULIST: machine list of the tests. */
USTCPULIST:
    .short  0x000C, 0x0000, 0x00A2, 0x000E, 0x0000, 0x012E, 0x0010	| 408466E2
    .long   0x000001BA, 0x000F0000, 0x0246000D, 0x000002BE	| 408466F0
    .long   0x00140000, 0x012E0017, 0x00000354, 0x001A0000	| 40846700
    .long   0x03540020, 0x00000354, 0x00210000, 0x03540016	| 40846710
    .long   0x000003CC, 0x00230000, 0x03CC0024, 0x000003CC	| 40846720
    .long   0x00150000, 0x04580022, 0x00000458, 0x00340000	| 40846730
    .long   0x04EE0018, 0x000004EE, 0x001E0000, 0x04EE001D	| 40846740
    .long   0x000004EE, 0x002D0000, 0x04EE0035, 0x000004EE	| 40846750
    .long   0x002E0000, 0x04EE002F, 0x000004EE, 0x00330000	| 40846760
    .long   0x04EE001B, 0x0000057A, 0x001C0000, 0x057A00FD	| 40846770
    .long   0x000005E8	| 40846780

/* MACIISITESTS: tests for the Mac IIsi. */
MACIISITESTS:
    .long   0x00010084, 0x001D0000, 0x00000001	| 40846784
    .long   0x0085001D, 0x00000000, 0x00010086, 0x001D0000	| 40846790
    .long   0x00000001, 0x0087001D, 0x00000000, 0x00010088	| 408467A0
    .long   0x001D0000, 0x00000001, 0x0089001D, 0x00000000	| 408467B0
    .long   0x0001008A, 0x001C0000, 0x00000001, 0x008B001D	| 408467C0
    .long   0x00000000, 0x0001008C, 0x001D0000, 0x00000001	| 408467D0
    .long   0x008D001D, 0x00000000, 0x00010094, 0x001C0000	| 408467E0
    .long   0x00000001, 0x0095001C, 0x00000000, 0x00010096	| 408467F0
    .long   0x001D0000, 0x0000FFFF	| 40846800
    .long   0xFFFF0000 /* number, not an address (F5) */	| 40846808
    .long   0x00000000	| 4084680C
    .long   0x00010084, 0x001D0000, 0x00000001, 0x0085001D	| 40846810
    .long   0x00000000, 0x00010086, 0x001D0000, 0x00000001	| 40846820
    .long   0x0087001D, 0x00000000, 0x00010089, 0x001D0000	| 40846830
    .long   0x00000001, 0x0097001C, 0x00000000, 0x00010095	| 40846840
    .long   0x001C0000, 0x00000001, 0x0094001C, 0x00000000	| 40846850
    .long   0x0001008A, 0x001C0000, 0x00000001, 0x009A001C	| 40846860
    .long   0x00000000, 0x0002009B, 0x001C0000, 0x00000002	| 40846870
    .long   0x009C001C, 0x00000000, 0x0002009D, 0x001C0000	| 40846880
    .long   0x0000FFFF, 0xFFFF0000, 0x00000000, 0x00010084	| 40846890
    .long   0x001D0000, 0x00000001, 0x0085001D, 0x00000000	| 408468A0
    .long   0x00010086, 0x001D0000, 0x00000001, 0x0087001D	| 408468B0
    .long   0x00000000, 0x00010089, 0x001D0000, 0x00000001	| 408468C0
    .long   0x008C001D, 0x00000000, 0x00010097, 0x001C0000	| 408468D0
    .long   0x00000001, 0x0095001C, 0x00000000, 0x0001008A	| 408468E0
    .long   0x001C0000, 0x00000001, 0x009A001C, 0x00000000	| 408468F0
    .long   0x0002009B, 0x001C0000, 0x00000002, 0x009C001C	| 40846900
    .long   0x00000000, 0x0002009D, 0x001C0000, 0x0000FFFF	| 40846910
    .long   0xFFFF0000, 0x00000000, 0x00010084, 0x001D0000	| 40846920
    .long   0x00000001, 0x0085001D, 0x00000000, 0x00010086	| 40846930
    .long   0x001D0000, 0x00000001, 0x0087001D, 0x00000000	| 40846940
    .long   0x00010088, 0x001C0000, 0x00000001, 0x0089001D	| 40846950
    .long   0x00000000, 0x0001008D, 0x001D0000, 0x00000001	| 40846960
    .long   0x008C001D, 0x00000000, 0x00010097, 0x001D0000	| 40846970
    .long   0x00000001, 0x0095001C, 0x00000000, 0x0001008A	| 40846980
    .long   0x001C0000, 0x0000FFFF, 0xFFFF0000, 0x00000000	| 40846990

/* MACLCTESTS: tests for the Mac LC. */
MACLCTESTS:
    .long   0x00010084, 0x001D0000, 0x00000001, 0x0085001D	| 408469A0
    .long   0x00000000, 0x00010086, 0x001D0000, 0x00000001	| 408469B0
    .long   0x0087001D, 0x00000000, 0x00010088, 0x001D0000	| 408469C0
    .long   0x00000001, 0x0089001D, 0x00000000, 0x0001008A	| 408469D0
    .long   0x001C0000, 0x00000001, 0x008B001D, 0x00000000	| 408469E0
    .long   0x0001008C, 0x001D0000, 0x00000001, 0x008D001D	| 408469F0
    .long   0x00000000, 0x00010094, 0x001C0000, 0x00000001	| 40846A00
    .long   0x0095001C, 0x00000000, 0x00010096, 0x001D0000	| 40846A10
    .long   0x00000001, 0x0097001F, 0x00000000, 0xFFFFFFFF	| 40846A20
    .short  0x0000, 0x0000, 0x0000	| 40846A30

/* DBLITETESTS: tests for the PowerBook Duo. */
DBLITETESTS:
    .short  0x0001, 0x0084, 0x001D, 0x0000, 0x0000	| 40846A36
    .long   0x00010085, 0x001D0000, 0x00000001, 0x0086001D	| 40846A40
    .long   0x00000000, 0x00010087, 0x001D0000, 0x00000001	| 40846A50
    .long   0x0088001C, 0x00000000, 0x00010089, 0x001D0000	| 40846A60
    .long   0x00000001, 0x009E001C, 0x00000000, 0x0001008D	| 40846A70
    .long   0x001D0000, 0x00000001, 0x0097001D, 0x00000000	| 40846A80
    .long   0x0001009F, 0x001C0000, 0x00000001, 0x0095001C	| 40846A90
    .short  0x0000, 0x0000, 0xFFFF, 0xFFFF, 0x0000, 0x0000, 0x0000	| 40846AA0

/* CARNATIONTESTS: tests for Carnation. */
CARNATIONTESTS:
    .short  0x0001	| 40846AAE
    .long   0x0084001D, 0x00000000, 0x00010085, 0x001D0000	| 40846AB0
    .long   0x00000001, 0x0086001D, 0x00000000, 0x00010087	| 40846AC0
    .long   0x001D0000, 0x00000001, 0x0088001D, 0x00000000	| 40846AD0
    .long   0x00010089, 0x001D0000, 0x00000001, 0x008A001C	| 40846AE0
    .long   0x00000000, 0x0001008B, 0x001D0000, 0x00000001	| 40846AF0
    .long   0x008C001D, 0x00000000, 0x0001008D, 0x001D0000	| 40846B00
    .long   0x00000001, 0x0094001C, 0x00000000, 0x00010095	| 40846B10
    .long   0x001C0000, 0x00000001, 0x0096001D, 0x00000000	| 40846B20
    .short  0xFFFF, 0xFFFF, 0x0000, 0x0000, 0x0000	| 40846B30

/* VAILTESTS: tests for Vail. */
VAILTESTS:
    .short  0x0001, 0x0084, 0x001D	| 40846B3A
    .long   0x00000000, 0x00010085, 0x001D0000, 0x00000001	| 40846B40
    .long   0x0086001D, 0x00000000, 0x00010087, 0x001D0000	| 40846B50
    .long   0x00000001, 0x0088001D, 0x00000000, 0x00010089	| 40846B60
    .long   0x001D0000, 0x00000001, 0x008A001C, 0x00000000	| 40846B70
    .long   0x0001008B, 0x001D0000, 0x00000001, 0x008C001D	| 40846B80
    .long   0x00000000, 0x0001008D, 0x001D0000, 0x00000001	| 40846B90
    .long   0x0094001C, 0x00000000, 0x00010095, 0x001C0000	| 40846BA0
    .long   0x00000001, 0x0096001D, 0x00000000, 0x00010097	| 40846BB0
    .long   0x001F0000, 0x0000FFFF, 0xFFFF0000, 0x00000000	| 40846BC0

/* WOMBATTESTS: tests for Wombat. */
WOMBATTESTS:
    .long   0x00010084, 0x001D0000, 0x00000001, 0x0085001D	| 40846BD0
    .long   0x00000000, 0x00010086, 0x001D0000, 0x00000001	| 40846BE0
    .long   0x0087001D, 0x00000000, 0x00010089, 0x001D0000	| 40846BF0
    .long   0x00000001, 0x008C001D, 0x00000000, 0x00010097	| 40846C00
    .long   0x001C0000, 0x00000001, 0x0095001C, 0x00000000	| 40846C10
    .long   0x0001008A, 0x001C0000, 0x00000001, 0x009A001C	| 40846C20
    .long   0x00000000, 0x0002009B, 0x001C0000, 0x00000002	| 40846C30
    .long   0x009C001C, 0x00000000, 0x0002009D, 0x001C0000	| 40846C40
    .long   0x0000FFFF, 0xFFFF0000, 0x00000000	| 40846C50

/* DARTTESTS: tests for Dartanian. */
DARTTESTS:
    .long   0x00010084	| 40846C5C
    .long   0x001D0000, 0x00000001, 0x0085001D, 0x00000000	| 40846C60
    .long   0x00010086, 0x001D0000, 0x00000001, 0x0087001D	| 40846C70
    .long   0x00000000, 0x00010088, 0x001C0000, 0x00000001	| 40846C80
    .long   0x0089001D, 0x00000000, 0x0001008C, 0x001D0000	| 40846C90
    .long   0x00000001, 0x008D001D, 0x00000000, 0x00010097	| 40846CA0
    .long   0x001D0000, 0x00000001, 0x0095001C, 0x00000000	| 40846CB0
    .short  0xFFFF, 0xFFFF, 0x0000, 0x0000, 0x0000	| 40846CC0

/* UNKNOWNTESTS: tests for unknown machines. */
UNKNOWNTESTS:
    .short  0x0001, 0x0084, 0x001D	| 40846CCA
    .long   0x00000000, 0x00010086, 0x001D0000, 0x00000001	| 40846CD0
    .long   0x0085001D, 0x00000000, 0x00010087, 0x001D0000	| 40846CE0
    .long   0x0000FFFF, 0xFFFF0000, 0x00000000	| 40846CF0

/* ELSIETMVECTORS: test manager vectors (Elsie). */
ELSIETMVECTORS:
    .long   0x00002000	| 40846CFC
    .long   0x40A47082, 0x40A46EFC, 0x40A46F0C, 0x40A46F12	| 40846D00
    .long   0x40A46F18, 0x40A46F1E, 0x40A46F24, 0x40A46F2A	| 40846D10
    .long   0x40A46F30, 0x40A46F36, 0x40A46F3C, 0x40A46F42	| 40846D20
    .long   0x40A46F48, 0x40A46F4E, 0x40A46F54, 0x40A46F42	| 40846D30
    .long   0x40A46F42, 0x40A46F42, 0x40A46F42, 0x40A46F42	| 40846D40
    .long   0x40A46F42, 0x40A46F42, 0x40A46F42, 0x40A46F54	| 40846D50
    .long   0x40A46F60, 0x40A46F66, 0x40A46F6C, 0x40A46F72	| 40846D60
    .long   0x40A46F78, 0x40A46F80, 0x40A46FA0, 0x40A46F5A	| 40846D70
    .long   0x40A46F5A, 0x40A46F5A, 0x40A46F5A, 0x40A46F5A	| 40846D80
    .long   0x40A46F5A, 0x40A46F5A, 0x40A46F5A, 0x40A46F5A	| 40846D90
    .long   0x40A46F5A, 0x40A46F5A, 0x40A46F5A, 0x40A46F5A	| 40846DA0
    .long   0x40A46F5A, 0x40A46F5A, 0x40A46F5A, 0x40A47012	| 40846DB0
    .long   0x40A4701C, 0x40A47026, 0x40A47030, 0x40A4703A	| 40846DC0
    .long   0x40A47044, 0x40A4704E, 0x40A46F42, 0x40A47058	| 40846DD0
    .long   0x40A47062, 0x40A4706C, 0x40A46F42, 0x40A46F42	| 40846DE0
    .long   0x40A46F42, 0x40A46F42, 0x40A46F42	| 40846DF0

/* TMVECTORS: test manager vectors. */
TMVECTORS:
    .long   0x00002000	| 40846DFC
    .long   STARTTEST1	| 40846E00
    .long   TMVECTORS_100	| 40846E04
    .long   TMVECTORS_110	| 40846E08
    .long   TMVECTORS_116	| 40846E0C
    .long   TMVECTORS_11C	| 40846E10
    .long   TMVECTORS_122	| 40846E14
    .long   TMVECTORS_128	| 40846E18
    .long   TMVECTORS_12E	| 40846E1C
    .long   TMVECTORS_134	| 40846E20
    .long   TMVECTORS_13A	| 40846E24
    .long   TMVECTORS_140	| 40846E28
    .long   TMVECTORS_146	| 40846E2C
    .long   TMVECTORS_14C	| 40846E30
    .long   TMVECTORS_152	| 40846E34
    .long   TMVECTORS_158	| 40846E38
    .long   TMVECTORS_146	| 40846E3C
    .long   TMVECTORS_146	| 40846E40
    .long   TMVECTORS_146	| 40846E44
    .long   TMVECTORS_146	| 40846E48
    .long   TMVECTORS_146	| 40846E4C
    .long   TMVECTORS_146	| 40846E50
    .long   TMVECTORS_146	| 40846E54
    .long   TMVECTORS_146	| 40846E58
    .long   TMVECTORS_158	| 40846E5C
    .long   TMVECTORS_164	| 40846E60
    .long   TMVECTORS_16A	| 40846E64
    .long   TMVECTORS_170	| 40846E68
    .long   TMVECTORS_176	| 40846E6C
    .long   TMVECTORS_17C	| 40846E70
    .long   TMVECTORS_184	| 40846E74
    .long   TMVECTORS_1A4	| 40846E78
    .long   TMVECTORS_15E	| 40846E7C
    .long   TMVECTORS_15E	| 40846E80
    .long   TMVECTORS_15E	| 40846E84
    .long   TMVECTORS_15E	| 40846E88
    .long   TMVECTORS_15E	| 40846E8C
    .long   TMVECTORS_15E	| 40846E90
    .long   TMVECTORS_15E	| 40846E94
    .long   TMVECTORS_15E	| 40846E98
    .long   TMVECTORS_15E	| 40846E9C
    .long   TMVECTORS_15E	| 40846EA0
    .long   TMVECTORS_15E	| 40846EA4
    .long   TMVECTORS_15E	| 40846EA8
    .long   TMVECTORS_15E	| 40846EAC
    .long   TMVECTORS_15E	| 40846EB0
    .long   TMVECTORS_15E	| 40846EB4
    .long   TMVECTORS_15E	| 40846EB8
    .long   TMVECTORS_216	| 40846EBC
    .long   TMVECTORS_220	| 40846EC0
    .long   TMVECTORS_22A	| 40846EC4
    .long   TMVECTORS_234	| 40846EC8
    .long   TMVECTORS_23E	| 40846ECC
    .long   TMVECTORS_248	| 40846ED0
    .long   TMVECTORS_252	| 40846ED4
    .long   TMVECTORS_146	| 40846ED8
    .long   TMVECTORS_25C	| 40846EDC
    .long   TMVECTORS_266	| 40846EE0
    .long   TMVECTORS_270	| 40846EE4
    .long   TMVECTORS_146	| 40846EE8
    .long   TMVECTORS_146	| 40846EEC
    .long   TMVECTORS_146	| 40846EF0
    .long   TMVECTORS_146	| 40846EF4
    .long   TMVECTORS_146	| 40846EF8
TMVECTORS_100:          /* test bit 27 of %d7 */
    btst #27,%d7
    jbeq TMVECTORS_10A
    moveal %a5,%sp
    jmp %fp@
TMVECTORS_10A:          /* from here: oriw #256,%d7 */
    oriw #256,%d7
    jbra TMVECTORS_180
TMVECTORS_110:          /* from here: oriw #512,%d7 */
    oriw #512,%d7
    jbra TMVECTORS_180
TMVECTORS_116:          /* from here: oriw #768,%d7 */
    oriw #768,%d7
    jbra TMVECTORS_180
TMVECTORS_11C:          /* from here: oriw #1024,%d7 */
    oriw #1024,%d7
    jbra TMVECTORS_180
TMVECTORS_122:          /* from here: oriw #1280,%d7 */
    oriw #1280,%d7
    jbra TMVECTORS_180
TMVECTORS_128:          /* from here: oriw #1536,%d7 */
    oriw #1536,%d7
    jbra TMVECTORS_180
TMVECTORS_12E:          /* from here: oriw #1792,%d7 */
    oriw #1792,%d7
    jbra TMVECTORS_180
TMVECTORS_134:          /* from here: oriw #2048,%d7 */
    oriw #2048,%d7
    jbra TMVECTORS_180
TMVECTORS_13A:          /* from here: oriw #2304,%d7 */
    oriw #2304,%d7
    jbra TMVECTORS_180
TMVECTORS_140:          /* from here: oriw #2560,%d7 */
    oriw #2560,%d7
    jbra TMVECTORS_180
TMVECTORS_146:          /* from here: oriw #2816,%d7 */
    oriw #2816,%d7
    jbra TMVECTORS_180
TMVECTORS_14C:          /* from here: oriw #3072,%d7 */
    oriw #3072,%d7
    jbra TMVECTORS_180
TMVECTORS_152:          /* from here: oriw #3328,%d7 */
    oriw #3328,%d7
    jbra TMVECTORS_180
TMVECTORS_158:          /* from here: oriw #3584,%d7 */
    oriw #3584,%d7
    jbra TMVECTORS_180
TMVECTORS_15E:          /* from here: oriw #3840,%d7 */
    oriw #3840,%d7
    jbra TMVECTORS_180
TMVECTORS_164:          /* from here: oriw #4096,%d7 */
    oriw #4096,%d7
    jbra TMVECTORS_180
TMVECTORS_16A:          /* from here: oriw #4352,%d7 */
    oriw #4352,%d7
    jbra TMVECTORS_180
TMVECTORS_170:          /* from here: oriw #4608,%d7 */
    oriw #4608,%d7
    jbra TMVECTORS_180
TMVECTORS_176:          /* from here: oriw #4864,%d7 */
    oriw #4864,%d7
    jbra TMVECTORS_180
TMVECTORS_17C:          /* from here: oriw #5120,%d7 */
    oriw #5120,%d7
TMVECTORS_180:          /* continue at TMVECTORS_278 */
    jbra TMVECTORS_278
TMVECTORS_184:          /* from here: oriw #5376,%d7 */
    oriw #5376,%d7
    moveq #0,%d2
    lea %pc@(TMVECTORS_192),%fp
    jmp %pc@(hardware_table_lookup_40847568)
TMVECTORS_192:          /* (data) */
    moveal %a0@(44),%a0	| 40846F8E
    bset #2,%a0@(1024)	| 40846F92
    bclr #2,%a0@	| 40846F98
TMVECTORS_192_E:
    bras TMVECTORS_192_E	| 40846F9C
    jbra TMVECTORS_180
TMVECTORS_1A4:          /* test bit 27 of %d7 */
    btst #27,%d7
    jbeq TMVECTORS_208
    cmpil #1346847600,%d0
    jbne TMVECTORS_1DE
    moveal %a5,%sp
    moveal %a0@(8),%a1
    moveb %a1@,%d1
    bclr #7,%a1@(1024)
    jbeq TMVECTORS_1CA
    moveb %a1@,%d1
    bset #7,%a1@(1024)
TMVECTORS_1CA:          /* test bit 7 of %d1 */
    btst #7,%d1
    jbne TMVECTORS_208
    bset #6,%a1@
    tstb %a1@
    bclr #6,%a1@
    tstb %a1@
    jmp %fp@
TMVECTORS_1DE:          /* test #1380996464,%d0 */
    cmpil #1380996464,%d0
    jbne TMVECTORS_208
    moveal %a5,%sp
    moveal %a0@(72),%a1
    movew %a1@(514),%d1
    btst #14,%d1
    jbeq TMVECTORS_208
    moveal %a0@(80),%a1
    st %a1@(16)
    movel %a1@,%d1
    bset #16,%d1
    movel %d1,%a1@
    jmp %fp@
TMVECTORS_208:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #5632,%d7
    bset #25,%d7
    jbra TMVECTORS_278
TMVECTORS_216:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #5888,%d7
    jbra TMVECTORS_278
TMVECTORS_220:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #6144,%d7
    jbra TMVECTORS_278
TMVECTORS_22A:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #6400,%d7
    jbra TMVECTORS_278
TMVECTORS_234:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #6656,%d7
    jbra TMVECTORS_278
TMVECTORS_23E:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #6912,%d7
    jbra TMVECTORS_278
TMVECTORS_248:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #7168,%d7
    jbra TMVECTORS_278
TMVECTORS_252:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #7424,%d7
    jbra TMVECTORS_278
TMVECTORS_25C:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #7680,%d7
    jbra TMVECTORS_278
TMVECTORS_266:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #7936,%d7
    jbra TMVECTORS_278
TMVECTORS_270:          /* from here: andiw #255,%d7 */
    andiw #255,%d7
    oriw #8192,%d7
TMVECTORS_278:          /* set bit 24 of %d7 */
    bset #24,%d7
    movel %sp,%d6
    moveaw #9728,%sp
    jmp %pc@(ERROR1HANDLER)

/* STARTTEST1: start-up tests at reset: ROM checksum, RAM, then continue the boot or report the failure (sad Mac). */
STARTTEST1:
    moveaw #9728,%sp
    moveq #0,%d7
    moveq #0,%d6
    lea %pc@(ELSIETMVECTORS),%a1
    lea %pc@(STARTTEST1),%a5
    cmpal %a1@(4),%a5
    jbeq STARTTEST1_1A
    lea %pc@(TMVECTORS),%a1
STARTTEST1_1A:          /* set %vbr */
    movec %a1,%vbr
    moveal %sp,%a5
    moveq #0,%d2
    lea %pc@(STARTTEST1_2A),%fp
    jmp %pc@(hardware_table_lookup_40847568)
STARTTEST1_2A:          /* test bit 1 of %d0 */
    btst #1,%d0
    jbeq STARTTEST1_62
    lea %pc@(STARTTEST1_62),%fp
    bset #27,%d7
    moveal %a0@(4),%a1
    moveml %a1@+,%d3/%a0
    cmpil #-1431677611,%d3
    jbne STARTTEST1_62
    lea %pc@(STARTTEST1_58),%a1
    biglea DIAGROMENTRY, a3
    jmp %a0@
STARTTEST1_58:          /* clear %d2 */
    moveq #0,%d2
    lea %pc@(STARTTEST1_62),%fp
    jmp %pc@(hardware_table_lookup_40847568)
STARTTEST1_62:          /* clear bit 27 of %d7 */
    bclr #27,%d7
    btst #17,%d0
    jbeq STARTTEST1_8A
    movew #18,%d7
    lea %pc@(STARTTEST1_7E),%fp
    bigjmp SETUPBASES
STARTTEST1_7E:          /* address %pc@(STARTTEST1_86) */
    lea %pc@(STARTTEST1_86),%fp
    jmp %pc@(SETSCCIOPBYPASS)
STARTTEST1_86:          /* (data) */
    jbne ERROR1HANDLER	| 40847108
STARTTEST1_8A:          /* clear %d2 */
    moveq #0,%d2
    lea %pc@(STARTTEST1_94),%fp
    jmp %pc@(hardware_table_lookup_40847568)
STARTTEST1_94:          /* set %a2 */
    moveal %a0@(8),%a2
    cmpib #6,%d2
    jbne STARTTEST1_B0
    moveal %a0@(72),%a3
    btst #1,%a3@(518)
    jbeq STARTTEST1_182
    jbra STARTTEST1_160
STARTTEST1_B0:          /* from here: asrw #8,%d2 */
    asrw #8,%d2
    cmpib #13,%d2
    jble STARTTEST1_C8
    lea %pc@(USTPMGRRECVBYTE_90),%a3
STARTTEST1_BC:          /* loop: move */
    moveb %a3@+,%d3
    cmpib #0xfd,%d3
    jbeq STARTTEST1_DE
    cmpb %d2,%d3
    jbne STARTTEST1_BC
STARTTEST1_C8:          /* clear bit 0 of %a2@(1536) */
    bclr #0,%a2@(1536)
    bclr #1,%a2@(7680)
    btst #0,%a2@(7680)
    jbeq STARTTEST1_160
STARTTEST1_DE:          /* set %d3 */
    movel #7864568,%d3
STARTTEST1_E4:          /* loop: lea */
    lea %pc@(STARTTEST1_EC),%fp
    jmp %pc@(READPRAMSIG)
STARTTEST1_EC:          /* test #1396916809,%d4 */
    cmpil #1396916809,%d4
    jbeq STARTTEST1_FE
    clrw %d3
    swap %d3
    jbne STARTTEST1_E4
    jbra STARTTEST1_182
STARTTEST1_FE:          /* clear %d2 */
    moveq #0,%d2
    lea %pc@(STARTTEST1_108),%fp
    jmp %pc@(hardware_table_lookup_40847568)
STARTTEST1_108:         /* (data) */
    moveal %a0@(8),%a2	| 4084718A
    btst #8,%d0
    jbeq STARTTEST1_126
    moveal %a0@(32),%a3
    moveb %a3@(64),%d3
    andib #28,%d3
    cmpib #16,%d3
    jbne STARTTEST1_142
    jbra STARTTEST1_160
STARTTEST1_126:         /* set %a3 */
    moveal %a0@(96),%a3
    btst #25,%d0
    jbeq STARTTEST1_134
    moveal %a0@(100),%a3
STARTTEST1_134:         /* set %d3 */
    moveb %a3@(64),%d3
    andib #7,%d3
    cmpib #4,%d3
    jbeq STARTTEST1_160
STARTTEST1_142:         /* address %pc@(STARTTEST1_14A) */
    lea %pc@(STARTTEST1_14A),%fp
    jmp %pc@(CLKWPOFF)
STARTTEST1_14A:         /* (data) */
    movew #255,%d3	| 408471CC
    moveq #0,%d2	| 408471D0
    movew %d3,%d1	| 408471D2
    lea %pc@(STARTTEST1_15A),%fp	| 408471D4
    jmp %pc@(WRXBYTE)	| 408471D8
STARTTEST1_15A:         /* (data) */
    .byte   0x51, 0xCB, 0xFF, 0xF2, 0x60, 0x22	| 408471DC
STARTTEST1_160:         /* set bit 26 of %d7 */
    bset #26,%d7
    movel #8126716,%d3
STARTTEST1_16A:         /* loop: lea */
    lea %pc@(STARTTEST1_172),%fp
    jmp %pc@(READPRAMSIG)
STARTTEST1_172:         /* (data) */
    cmpil #1380074057,%d4	| 408471F4
    jbeq RBIMGR	| 408471FA
    clrw %d3	| 408471FE
    swap %d3	| 40847200
    jbne STARTTEST1_16A	| 40847202
STARTTEST1_182:         /* set %d0 */
    movec %cacr,%d0
    bset #15,%d0
    movec %d0,%cacr
    movec %cacr,%d0
    btst #15,%d0
    jbeq STARTTEST1_19C
    cinva %ic
    jbra STARTTEST1_1AC
STARTTEST1_19C:         /* set %d0 */
    movec %cacr,%d0
    orib #9,%d0
    bclr #8,%d0
    movec %d0,%cacr
STARTTEST1_1AC:         /* clear %d2 */
    moveq #0,%d2
    lea %pc@(STARTTEST1_1B6),%fp
    jmp %pc@(hardware_table_lookup_40847568)
STARTTEST1_1B6:         /* set %d0 */
    moveq #14,%d0
    andl %d1,%d0
    subql #6,%d0
    jbeq STARTTEST1_1F0
    moveq #112,%d0
    andl %d1,%d0
    cmpib #32,%d0
    jbne STARTTEST1_216
    lea %pc@(STARTTEST1_1D6),%fp
    bigjmp EGRETINIT, a1
STARTTEST1_1D6:         /* set %d0 */
    movel #2162689,%d0
    moveq #0,%d1
    moveq #1,%d2
    lea %pc@(STARTTEST1_1EE),%fp
    bigjmp SENDEGRETCMD, a1
STARTTEST1_1EE:         /* (data) */
    jbra STARTTEST1_216	| 40847270
STARTTEST1_1F0:         /* address %pc@(STARTTEST1_1FE) */
    lea %pc@(STARTTEST1_1FE),%fp
    bigjmp EGRETINIT, a1
STARTTEST1_1FE:         /* set %d0 */
    movel #1835009,%d0
    moveq #1,%d1
    moveq #1,%d2
    lea %pc@(STARTTEST1_216),%fp
    bigjmp SENDEGRETCMD, a1
STARTTEST1_216:         /* clear %d2 */
    moveq #0,%d2
    lea %pc@(STARTTEST1_220),%fp
    jmp %pc@(hardware_table_lookup_40847568)
STARTTEST1_220:         /* set %d3 */
    movel %a1@(48),%d3
    jbeq STARTTEST1_236
    lea %a1@(0x0,%d3:l),%a2
    movel %a2@,%d3
    jbeq STARTTEST1_236
    lea %pc@(STARTTEST1_236),%fp
    jmp %a2@(0x0,%d3:l)
STARTTEST1_236:         /* set %d7 */
    movew #1,%d7
    lea %pc@(STARTTEST1_242),%fp
    jmp %pc@(STARTUPROMTEST)
STARTTEST1_242:         /* test %d6 */
    tstl %d6
    jbne ERROR1HANDLER
    clrw %d7
    moveq #0,%d2
    lea %pc@(STARTTEST1_254),%fp
    jmp %pc@(hardware_table_lookup_40847568)
STARTTEST1_254:         /* test bit 24 of %d2 */
    btst #24,%d2
    jbeq STARTTEST1_262
    lea %pc@(STARTTEST1_262),%fp
    jmp %pc@(USTPMGRTURNON)
STARTTEST1_262:         /* set %a3 */
    moveal %a0@(48),%a3
    moveal %a0@(8),%a5
    orib #7,%a5@(1536)
    moveb #1,%a5@(7680)
    moveq #40,%d0
    lea %pc@(STARTTEST1_286),%fp
    bigjmp BOOTBEEP6
STARTTEST1_286:         /* clear %a3@(2052) */
    clrb %a3@(2052)
    moveq #0,%d2
    lea %pc@(STARTTEST1_294),%fp
    jmp %pc@(hardware_table_lookup_40847568)
STARTTEST1_294:         /* address %pc@(STARTTEST1_29C) */
    lea %pc@(STARTTEST1_29C),%fp
    jmp %pc@(SIZEV8VRAM)
STARTTEST1_29C:         /* set %d7 */
    movew #17,%d7
    lea %pc@(STARTTEST1_2A8),%fp
    jmp %pc@(thunk_FUN_408a0000)
STARTTEST1_2A8:         /* from here: jbne ERROR1HANDLER */
    jbne ERROR1HANDLER
    lea %pc@(STARTTEST1_2B4),%fp
    jmp %pc@(STARTTEST1_446)
STARTTEST1_2B4:         /* test %d6 */
    tstl %d6
    jbne STARTTEST1_2CA
    moveal %sp@,%fp
    cmpil #1464619843,%fp@(-4)
    jbne STARTTEST1_2CA
    clrw %d7
    braw STARTTEST1_31A
STARTTEST1_2CA:         /* set %a3 */
    moveaw #-1,%a3
    movew #3,%d7
    moveal %sp@,%a4
    moveal %a4,%a5
STARTTEST1_2D6:         /* loop: movea */
    moveal %a4@+,%a0
    cmpaw #-1,%a0
    jbeq STARTTEST1_304
    movel %a4@+,%d0
    moveal %a0,%a1
    addal %d0,%a1
    cmpal %a1,%a5
    jbhi STARTTEST1_2EA
    moveal %sp@,%a1
STARTTEST1_2EA:         /* test %a1,%a3 */
    cmpal %a1,%a3
    jbhi STARTTEST1_2F0
    moveal %a3,%a1
STARTTEST1_2F0:         /* address %pc@(STARTTEST1_2F8) */
    lea %pc@(STARTTEST1_2F8),%fp
    jmp %pc@(caseD_2)
STARTTEST1_2F8:         /* set %sp@ */
    movel %a5,%sp@
    tstl %d6
    jbne ERROR1HANDLER
    addqw #1,%d7
    jbra STARTTEST1_2D6
STARTTEST1_304:         /* set %d7 */
    movew #19,%d7
    moveal %sp@,%a0
    moveal %a0@,%a0
    lea %pc@(STARTTEST1_314),%fp
    jmp %pc@(DYNAMIC_BUSSIZE_TEST)
STARTTEST1_314:         /* test %d6 */
    tstl %d6
    jbne ERROR1HANDLER
STARTTEST1_31A:         /* address %pc@(STARTTEST1_322) */
    lea %pc@(STARTTEST1_322),%fp
    jmp %pc@(USTINIT)
STARTTEST1_322:         /* set %a1 */
    moveal %a5@(38),%a1
    subal #55296,%sp
    movel %sp,%a5@(22)
    movel %a5,%sp@-
    moveal %a5@(22),%a0
    movel #55296,%sp@-
    pea %a0@
    bigjsr GI_InitInterface
    addql #8,%sp
    moveal %sp@+,%a5
    moveq #2,%d0
    cmpil #1464619843,%a5@(30)
    jbeq STARTTEST1_35C
    bset #0,%d0
STARTTEST1_35C:         /* set %a5@(8) */
    movew %d0,%a5@(8)
    moveal %a5@(18),%a2
    moveal %a5@(34),%a0
STARTTEST1_368:         /* loop: moveq */
    moveq #0,%d5
    movew %a2@,%d5
    cmpiw #-1,%d5
    beql STARTTEST1_3F8
    moveq #0,%d4
    movew %a2@(2),%d4
    moveml %a0-%a3/%a5,%sp@-
    lea %pc@(STARTTEST1_38E),%fp
    bigjmp SETUPFOREXECUTEDTM
STARTTEST1_38E:         /* set %d6 */
    movel %a5@(90),%d6
    cmpil #-1,%d6
    jbeq STARTTEST1_3D2
    movel %a5@(110),%d6
    cmpil #-1,%d6
    jbeq STARTTEST1_3D2
    moveal %a5@(22),%a0
    moveq #0,%d6
    pea %a5@(122)
    pea %a5@(102)
    pea %a5@(82)
    pea %a5@(46)
    pea %a0@
    bigjsr GI_ExecuteDTM
    addaw #20,%sp
    tstl %d0
    jbeq STARTTEST1_3EC
    movel %d0,%d6
STARTTEST1_3D2:         /* set %a0-%a3/%a5 */
    moveml %sp@,%a0-%a3/%a5
    movew %a5@(8),%d0
    btst #0,%d0
    jbeq STARTTEST1_3EC
    jbsr NCERRORHANDLER
    btst #26,%d7
    jbne GOTM
STARTTEST1_3EC:         /* restore registers */
    moveml %sp@+,%a0-%a3/%a5
    addaw #10,%a2
    jbra STARTTEST1_368
STARTTEST1_3F8:         /* from here: addal #55296,%sp */
    addal #55296,%sp
    clrw %d7
    btst #26,%d7
    jbne GOTM
    moveal %a5@(38),%a1
    moveq #14,%d0
    andl %a1@(28),%d0
    cmpiw #6,%d0
    jbne STARTTEST1_438
    moveal %a5@(34),%a0
    movel #1835009,%d0
    moveq #0,%d1
    moveq #1,%d2
    movel %a5,%sp@-
    lea %pc@(STARTTEST1_436),%fp
    bigjmp SENDEGRETCMD, a1
STARTTEST1_436:         /* (data) */
    moveal %sp@+,%a5	| 408474B8
STARTTEST1_438:         /* set %fp */
    moveal %a5@(150),%fp
    bigjmp STARTINIT1
STARTTEST1_446:         /* set %d4 */
    movel %fp,%d4
    moveq #0,%d2
    lea %pc@(STARTTEST1_452),%fp
    jmp %pc@(hardware_table_lookup_40847568)
STARTTEST1_452:         /* set bit 18 of %d7 */
    bset #18,%d7
    bset #27,%d7
    moveal %sp,%a5
    btst #0,%d1
    jbeq STARTTEST1_496
    movel #1346847600,%d0
    moveal %a0@(8),%a2
    bclr #6,%a2@
    tstb %a2@
    lea %pc@(STARTTEST1_490),%fp
    moveal %sp@,%a4
STARTTEST1_478:         /* loop: movea */
    moveal %a4@+,%a3
    cmpaw #-1,%a3
    jbeq STARTTEST1_4B8
    addql #4,%a4
    movel #16843009,%a3@
    tstl %a3@
    clrl %a3@
    tstl %a3@
    jbra STARTTEST1_478
STARTTEST1_490:         /* (data) */
    bset #6,%a1@	| 40847512
    jbra STARTTEST1_4D6	| 40847516
STARTTEST1_496:         /* test bit 20 of %d0 */
    btst #20,%d0
    jbeq STARTTEST1_4D6
    movel #1380996464,%d0
    moveal %a0@(80),%a2
    st %a2@(16)
    clrb %a2@
    st %a2@
    moveal %a0@(72),%a1
    moveb #7,%a1@(14)
STARTTEST1_4B8:         /* address %pc@(STARTTEST1_4D2) */
    lea %pc@(STARTTEST1_4D2),%fp
    moveal %sp@,%a4
STARTTEST1_4BE:         /* loop: movea */
    moveal %a4@+,%a2
    cmpaw #-1,%a2
    jbeq STARTTEST1_4DA
    movel %a4@+,%d5
STARTTEST1_4C8:         /* loop: movem */
    moveml %a2@+,%d1-%d3/%d6
    subql #4,%d5
    jbgt STARTTEST1_4C8
    jbra STARTTEST1_4BE
STARTTEST1_4D2:         /* set %d6 */
    moveq #1,%d6
    jbra STARTTEST1_4DC
STARTTEST1_4D6:         /* clear bit 18 of %d7 */
    bclr #18,%d7
STARTTEST1_4DA:         /* clear %d6 */
    moveq #0,%d6
STARTTEST1_4DC:         /* clear bit 27 of %d7 */
    bclr #27,%d7
    moveq #0,%d0
    moveal %d4,%fp
    jmp %fp@

/* JGETHARDWAREINFO: hardware identification for the tests. */
hardware_table_lookup_40847568:
JGETHARDWAREINFO:
    oriw #1792,%sr
    bigjmp hardware_table_lookup

/* SIZEV8VRAM: size the V8 video RAM. */
SIZEV8VRAM:
    moveb %a1@(18),%d0
    cmpib #13,%d0
    bnew SIZEV8VRAM_50
    moveal %a0@(52),%a2
    movel %a1@(8),%d0
    moveal %a1@(0x0,%d0:l),%a0
    movel #1399350636,%d0
    moveq #-1,%d1
    movel #262144,%d2
    bset #2,%a2@(1)
    bset #1,%a2@(1)
    movel %d0,%a0@
    movel %d1,%a0@(4)
    cmpl %a0@(0x0,%d2:l),%d0
    jbeq SIZEV8VRAM_50
    cmpl %a0@,%d0
    jbeq SIZEV8VRAM_4A
    bclr #2,%a2@(1)
    jbra SIZEV8VRAM_50
SIZEV8VRAM_4A:          /* clear bit 1 of %a2@(1) */
    bclr #1,%a2@(1)
SIZEV8VRAM_50:          /* jump through %fp@ */
    jmp %fp@

/* USTINIT: test initialisation. */
USTINIT:
    moveal %fp,%a4
    lea %pc@(USTINIT_A),%fp
    jmp %pc@(thunk_FUN_408a0000)
USTINIT_A:              /* clear %d2 */
    moveq #0,%d2
    lea %pc@(USTINIT_14),%fp
    jmp %pc@(hardware_table_lookup_40847568)
USTINIT_14:             /* set %a2 */
    moveal %sp@,%a2
    moveal %a2@,%a5
    addal #65536,%a5
    subaw #154,%a5
    movel %a2,%a5@(150)
    moveal %a5,%sp
    movel %a2@(-4),%a5@(30)
    movel %d0,%a5@(42)
    movel %a1,%a5@(38)
    movel %a0,%a5@(34)
    moveb %a1@(18),%d0
    lea %pc@(USTCPULIST),%a0
    movel %a0,%d2
USTINIT_44:             /* loop: move */
    movew %a0@,%d1
    cmpib #0xfd,%d1
    jbeq USTINIT_54
    cmpb %d1,%d0
    jbeq USTINIT_54
    addql #6,%a0
    jbra USTINIT_44
USTINIT_54:             /* set %a0 */
    moveal %a0@(2),%a0
    lea %a0@(0x0,%d2:l),%a0
    movel %a0,%a5@(18)
    subaw #256,%sp
    moveal %sp,%a1
    lea %pc@(USTINIT_74),%fp
    bigjmp SETVECTORTABLE, a2
USTINIT_74:             /* jump through %a4@ */
    jmp %a4@

/* USTPMGRTURNON: turn on subsystems through the Power Manager. */
USTPMGRTURNON:
    movel %a0@(-16),%d3
    btst #20,%d3
    jbeq USTPMGRTURNON_14
    moveal %a0@(52),%a2
    bset #1,%a2@(33)
USTPMGRTURNON_14:       /* set %d3 */
    movel #11731216,%d3

/* USTPMGRSENDCOMMAND: send a Power Manager command (no RAM). */
USTPMGRSENDCOMMAND:
    moveal %a0@(8),%a2
    movel %a0@(44),%d6
    jbne USTPMGRSENDCOMMAND_E
    movel %a0@(52),%d6
USTPMGRSENDCOMMAND_E:   /* set %a3 */
    moveal %d6,%a3
    moveq #1,%d6
    movew #25056,%d4
USTPMGRSENDCOMMAND_16:  /* loop: tst */
    tstb %a2@
    btst #1,%a3@
    dbne %d4,USTPMGRSENDCOMMAND_16
    jbeq USTPMGRSENDCOMMAND_60
    lea %pc@(USTPMGRSENDCOMMAND_2A),%a5
    jmp %pc@(USTPMGRSENDBYTE)
USTPMGRSENDCOMMAND_2A:  /* (data) */
    jbne USTPMGRSENDCOMMAND_60	| 40847682
    asrw #8,%d3	| 40847684
    jbmi USTPMGRSENDCOMMAND_60	| 40847686
    tstl %d4	| 40847688
    jbmi USTPMGRSENDCOMMAND_3E	| 4084768A
    lea %pc@(USTPMGRSENDCOMMAND_3C),%a5	| 4084768C
    jmp %pc@(USTPMGRSENDBYTE)	| 40847690
USTPMGRSENDCOMMAND_3C:  /* (data) */
    .byte   0x66, 0x22	| 40847694
USTPMGRSENDCOMMAND_3E:  /* subtract 1 to %d3 */
    subqb #1,%d3	| 40847696
    jbmi USTPMGRSENDCOMMAND_60	| 40847698
    swap %d3	| 4084769A
    lea %pc@(USTPMGRSENDCOMMAND_4C),%a5	| 4084769C
    jmp %pc@(USTPMGRSENDBYTE)	| 408476A0
USTPMGRSENDCOMMAND_4C:  /* (data) */
    .byte   0x66, 0x12, 0x48, 0x43, 0x53, 0x03, 0x6B, 0x0C, 0x48, 0x43, 0xE0, 0x4B, 0x4B, 0xFA, 0x00, 0x06	| 408476A4
    .byte   0x4E, 0xFA, 0x00, 0x24	| 408476B4
USTPMGRSENDCOMMAND_60:  /* test %d6 */
    tstl %d6
    jmp %fp@

/* READPRAMSIG: read the PRAM signature. */
READPRAMSIG:
    movel %fp,%d5
READPRAMSIG_2:          /* loop: move */
    movew %d3,%d1
    lea %pc@(READPRAMSIG_C),%fp
    jmp %pc@(RDXBYTE)
READPRAMSIG_C:          /* from here: roll #8,%d4 */
    roll #8,%d4
    moveb %d1,%d4
    addqw #1,%d3
    movew %d3,%d1
    andiw #3,%d1
    jbne READPRAMSIG_2
    moveal %d5,%fp
    jmp %fp@

/* USTPMGRSENDBYTE: send a byte to the Power Manager. */
USTPMGRSENDBYTE:
    movew #25056,%d4
    bclr #31,%d4
    btst #1,%a0@(-15)
    jbeq USTPMGRSENDBYTE_24
    moveal %a0@(52),%a3
    bset #31,%d4
    bset #4,%a2@(5632)
    moveb %d3,%a2@(5120)
    jbra USTPMGRSENDBYTE_2E
USTPMGRSENDBYTE_24:     /* set %a3@(1536) */
    moveb #0xff,%a3@(1536)
    moveb %d3,%a3@(512)
USTPMGRSENDBYTE_2E:     /* set %d6 */
    moveq #2,%d6
    bclr #2,%a3@
USTPMGRSENDBYTE_34:     /* loop: tst */
    tstb %a2@
    btst #1,%a3@
    dbeq %d4,USTPMGRSENDBYTE_34
    jbne USTPMGRSENDBYTE_56
    movew #97,%d4
    bset #2,%a3@
USTPMGRSENDBYTE_48:     /* loop: tst */
    tstb %a2@
    btst #1,%a3@
    dbne %d4,USTPMGRSENDBYTE_48
    jbeq USTPMGRSENDBYTE_56
    moveq #0,%d6
USTPMGRSENDBYTE_56:     /* set bit 2 of %a3@ */
    bset #2,%a3@
    tstl %d4
    jbmi USTPMGRSENDBYTE_62
    clrb %a3@(1536)
USTPMGRSENDBYTE_62:     /* test %d6 */
    tstl %d6
    jmp %a5@

/* USTPMGRRECVBYTE: receive a byte. */
USTPMGRRECVBYTE:
    moveq #2,%d6
    movew #25056,%d4
    bclr #31,%d4
    btst #1,%a0@(-15)
    beqs USTPMGRRECVBYTE_4E
    moveal %a0@(52),%a3
    bset #31,%d4
    bclr #4,%a2@(5632)
    tstb %a2@(5120)
    bclr #2,%a3@
USTPMGRRECVBYTE_28:
    tstb %a2@
    btst #1,%a3@
    dbeq %d4,USTPMGRRECVBYTE_28
    bnes USTPMGRRECVBYTE_78
    bset #2,%a3@
    movew #97,%d4
USTPMGRRECVBYTE_3C:
    tstb %a2@
    btst #1,%a3@
    dbne %d4,USTPMGRRECVBYTE_3C
    beqs USTPMGRRECVBYTE_78
    moveb %a2@(5120),%d3
    bras USTPMGRRECVBYTE_76
USTPMGRRECVBYTE_4E:
    clrb %a3@(1536)
USTPMGRRECVBYTE_52:
    tstb %a2@
    btst #1,%a3@
    dbeq %d4,USTPMGRRECVBYTE_52
    bnes USTPMGRRECVBYTE_78
    bclr #2,%a3@
    moveb %a3@(512),%d3
    movew #97,%d4
USTPMGRRECVBYTE_6A:
    tstb %a2@
    btst #1,%a3@
    dbne %d4,USTPMGRRECVBYTE_6A
    beqs USTPMGRRECVBYTE_78
USTPMGRRECVBYTE_76:
    moveq #0,%d6
USTPMGRRECVBYTE_78:
    bset #2,%a3@
    tstl %d4
    bmis USTPMGRRECVBYTE_86
    clrb %a2@(1536)
    bras USTPMGRRECVBYTE_8C
USTPMGRRECVBYTE_86:
    bset #4,%a2@(5632)
USTPMGRRECVBYTE_8C:
    tstl %d6
    jmp %a5@
USTPMGRRECVBYTE_90:     /* (data) */
    .long   0x0E101114, 0xFD000000	| 408477D0

/* MOD3TEST: RAM test: modulo-3 pattern. */
caseD_2:
MOD3TEST:
    moveml %pc@(MOD3TEST_FE),%d0-%d5
    moveal %a0,%a2
    subaw #120,%a1
    jbra MOD3TEST_2E
MOD3TEST_E:             /* loop: movem */
    moveml %d0-%d5,%a2@
    moveml %d0-%d5,%a2@(24)
    moveml %d0-%d5,%a2@(48)
    moveml %d0-%d5,%a2@(72)
    moveml %d0-%d5,%a2@(96)
    lea %a2@(120),%a2
MOD3TEST_2E:            /* test %a1,%a2 */
    cmpal %a1,%a2
    jble MOD3TEST_E
    subaw #-108,%a1
    moveq #12,%d5
    jbra MOD3TEST_40
MOD3TEST_3A:            /* loop: movem */
    moveml %d0-%d2,%a2@
    addaw %d5,%a2
MOD3TEST_40:            /* test %a1,%a2 */
    cmpal %a1,%a2
    jble MOD3TEST_3A
    addaw %d5,%a1
    moveq #4,%d4
    cmpal %a2,%a1
    jbeq MOD3TEST_58
    movel %d0,%a2@+
    moveq #8,%d4
    cmpal %a2,%a1
    jbeq MOD3TEST_58
    movel %d1,%a2@+
    moveq #0,%d4
MOD3TEST_58:            /* loop: movea */
    moveal %a0,%a2
    movel %a1,%d3
    subl %a0,%d3
    subql #4,%d3
    moveq #63,%d2
    andw %d3,%d2
    negw %d2
    lsrl #6,%d3
    eorl %d1,%a2@
    subql #1,%d5
    jmp %pc@(MOD3TEST_B4,%d2:w)
    .long   0x4E714E71	| 40847848
MOD3TEST_74:            /* loop: move */
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
    movel %a2@+,%d2
    eorl %d2,%a2@
MOD3TEST_B4:            /* count down */
    dbf %d3,MOD3TEST_74
    subil #65536,%d3
    jbpl MOD3TEST_74
    cmpiw #21,%d7
    beqw MOD3TEST_FC
    cmpl %d0,%d1
    jbeq MOD3TEST_D0
    movel %d0,%d1
    jbra MOD3TEST_58
MOD3TEST_D0:            /* set %d0-%d2 */
    moveml %a1@(-12),%d0-%d2
    moveml %pc@(MOD3TEST_FE,%d4:w),%d3-%d5
    eorl %d3,%d0
    eorl %d4,%d1
    eorl %d5,%d2
    orl %d2,%d0
    orl %d1,%d0
    orl %d0,%d6
    btst #18,%d7
    jbeq MOD3TEST_FC
    movew #21,%d7
    moveml %pc@(MOD3TEST_102),%d0-%d5
    jbra MOD3TEST_58
MOD3TEST_FC:            /* jump through %fp@ */
    jmp %fp@
MOD3TEST_FE:            /* (data) */
    .short  0x6DB6, 0xDB6D	| 408478D6
MOD3TEST_102:           /* (data) */
    .short  0xB6DB, 0x6DB6, 0xDB6D	| 408478DA
    .long   0xB6DB6DB6, 0xDB6DB6DB, 0x6DB6DB6D, 0xB6DB0000	| 408478E0

/* REVMOD3TEST: RAM test: reverse modulo-3. */
REVMOD3TEST:
    moveml %pc@(REVMOD3TEST_EE),%d0-%d5	| 408478F0
    moveal %a1,%a2	| 408478F6
    lea %a0@(120),%a0	| 408478F8
    jbra REVMOD3TEST_22	| 408478FC
REVMOD3TEST_E:          /* loop: movem */
    moveml %d0-%d5,%a2@-	| 408478FE
    moveml %d0-%d5,%a2@-	| 40847902
    moveml %d0-%d5,%a2@-	| 40847906
    moveml %d0-%d5,%a2@-	| 4084790A
    moveml %d0-%d5,%a2@-	| 4084790E
REVMOD3TEST_22:         /* test %a2,%a0 */
    cmpal %a2,%a0	| 40847912
    jble REVMOD3TEST_E	| 40847914
    lea %a0@(-108),%a0	| 40847916
    jbra REVMOD3TEST_30	| 4084791A
REVMOD3TEST_2C:         /* loop: movem */
    moveml %d0-%d2,%a2@-	| 4084791C
REVMOD3TEST_30:         /* test %a2,%a0 */
    cmpal %a2,%a0	| 40847920
    jble REVMOD3TEST_2C	| 40847922
    subaw #12,%a0	| 40847924
    moveq #8,%d4	| 40847928
    cmpal %a2,%a0	| 4084792A
    jbeq REVMOD3TEST_4A	| 4084792C
    movel %d2,%a2@-	| 4084792E
    moveq #4,%d4	| 40847930
    cmpal %a2,%a0	| 40847932
    jbeq REVMOD3TEST_4A	| 40847934
    movel %d1,%a2@-	| 40847936
    moveq #0,%d4	| 40847938
REVMOD3TEST_4A:         /* loop: movea */
    moveal %a1,%a2	| 4084793A
    subql #4,%a2	| 4084793C
    movel %a2,%d3	| 4084793E
    subl %a0,%d3	| 40847940
    moveq #63,%d0	| 40847942
    andw %d3,%d0	| 40847944
    negw %d0	| 40847946
    lsrl #6,%d3	| 40847948
    eorl %d1,%a2@	| 4084794A
    subql #1,%d5	| 4084794C
    jmp %pc@(REVMOD3TEST_A6,%d0:w)	| 4084794E
    .byte   0x4E, 0x71, 0x4E, 0x71	| 40847952
REVMOD3TEST_66:         /* loop: move */
    movel %a2@,%d0	| 40847956
    eorl %d0,%a2@-	| 40847958
    movel %a2@,%d0	| 4084795A
    eorl %d0,%a2@-	| 4084795C
    movel %a2@,%d0	| 4084795E
    eorl %d0,%a2@-	| 40847960
    movel %a2@,%d0	| 40847962
    eorl %d0,%a2@-	| 40847964
    movel %a2@,%d0	| 40847966
    eorl %d0,%a2@-	| 40847968
    movel %a2@,%d0	| 4084796A
    eorl %d0,%a2@-	| 4084796C
    movel %a2@,%d0	| 4084796E
    eorl %d0,%a2@-	| 40847970
    movel %a2@,%d0	| 40847972
    eorl %d0,%a2@-	| 40847974
    movel %a2@,%d0	| 40847976
    eorl %d0,%a2@-	| 40847978
    movel %a2@,%d0	| 4084797A
    eorl %d0,%a2@-	| 4084797C
    movel %a2@,%d0	| 4084797E
    eorl %d0,%a2@-	| 40847980
    movel %a2@,%d0	| 40847982
    eorl %d0,%a2@-	| 40847984
    movel %a2@,%d0	| 40847986
    eorl %d0,%a2@-	| 40847988
    movel %a2@,%d0	| 4084798A
    eorl %d0,%a2@-	| 4084798C
    movel %a2@,%d0	| 4084798E
    eorl %d0,%a2@-	| 40847990
    movel %a2@,%d0	| 40847992
    eorl %d0,%a2@-	| 40847994
REVMOD3TEST_A6:         /* count down */
    dbf %d3,REVMOD3TEST_66	| 40847996
    subil #65536,%d3	| 4084799A
    jbpl REVMOD3TEST_66	| 408479A0
    cmpiw #21,%d7	| 408479A2
    beqw REVMOD3TEST_EC	| 408479A6
    cmpl %d2,%d1	| 408479AA
    jbeq REVMOD3TEST_C2	| 408479AC
    movel %d2,%d1	| 408479AE
    jbra REVMOD3TEST_4A	| 408479B0
REVMOD3TEST_C2:         /* set %d0-%d2 */
    moveml %a0@,%d0-%d2	| 408479B2
    moveml %pc@(REVMOD3TEST_EE,%d4:w),%d3-%d5	| 408479B6
    eorl %d3,%d0	| 408479BC
    eorl %d4,%d1	| 408479BE
    eorl %d5,%d2	| 408479C0
    orl %d2,%d0	| 408479C2
    orl %d1,%d0	| 408479C4
    orl %d0,%d6	| 408479C6
    btst #18,%d7	| 408479C8
    jbeq REVMOD3TEST_EC	| 408479CC
    movew #21,%d7	| 408479CE
    moveml %pc@(REVMOD3TEST_F2),%d0-%d5	| 408479D2
    jbra REVMOD3TEST_4A	| 408479D8
REVMOD3TEST_EC:         /* jump through %fp@ */
    jmp %fp@	| 408479DC
REVMOD3TEST_EE:         /* (data) */
    .byte   0x6D, 0xB6, 0xDB, 0x6D	| 408479DE
REVMOD3TEST_F2:         /* (data) */
    .byte   0xB6, 0xDB, 0x6D, 0xB6, 0xDB, 0x6D, 0xB6, 0xDB, 0x6D, 0xB6, 0xDB, 0x6D, 0xB6, 0xDB, 0x6D, 0xB6	| 408479E2
    .byte   0xDB, 0x6D, 0xB6, 0xDB	| 408479F2

/* ROMTEST: ROM checksum test (byte lanes). */
ROMTEST:
    biglea MYFIRSTPROC
    lea %a0@(48),%a1
    movel %a0@(64),%d0
    lea %a0@(0x0,%d0:l),%a2
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d2
    moveq #0,%d3
    moveq #0,%d4
    addql #4,%a0
ROMTEST_22:             /* loop: move */
    moveb %a0@+,%d4
    addl %d4,%d0
    moveb %a0@+,%d4
    addl %d4,%d1
    moveb %a0@+,%d4
    addl %d4,%d2
    moveb %a0@+,%d4
    addl %d4,%d3
    cmpal %a0,%a1
    jbne ROMTEST_3C
    addaw #16,%a0
    jbra ROMTEST_22
ROMTEST_3C:             /* test %a0,%a2 */
    cmpal %a0,%a2
    jbgt ROMTEST_22
    cmpl %a1@+,%d0
    jbeq ROMTEST_48
    bset #0,%d6
ROMTEST_48:             /* test %a1@+,%d1 */
    cmpl %a1@+,%d1
    jbeq ROMTEST_50
    bset #1,%d6
ROMTEST_50:             /* test %a1@+,%d2 */
    cmpl %a1@+,%d2
    jbeq ROMTEST_58
    bset #2,%d6
ROMTEST_58:             /* test %a1@+,%d3 */
    cmpl %a1@+,%d3
    jbeq ROMTEST_60
    bset #3,%d6
ROMTEST_60:             /* jump through %fp@ */
    jmp %fp@

/* STARTUPROMTEST: ROM checksum at start-up (the long at +0). */
STARTUPROMTEST:
    moveq #0,%d0
    moveq #0,%d1
    biglea MYFIRSTPROC
    movel %a0@(64),%d3
    subql #4,%d3
    movel %a0@+,%d4
STARTUPROMTEST_16:      /* loop: move */
    movew %a0@+,%d0
    addl %d0,%d1
    subql #2,%d3
    jbne STARTUPROMTEST_16
    nop
    nop
    eorl %d4,%d1
    jbeq STARTUPROMTEST_2A
    movew #-1,%d6
STARTUPROMTEST_2A:      /* jump through %fp@ */
    jmp %fp@

/* EXTRAMTEST: extended RAM test. */
EXTRAMTEST:
    moveq #0,%d0
    moveq #-1,%d1
    moveal %a0,%a2
    movel %a1,%d2
    subl %a0,%d2
    lsrl #2,%d2
    movel %d2,%d3
EXTRAMTEST_E:           /* loop: move */
    movel %d0,%a2@+
    subql #1,%d2
    jbne EXTRAMTEST_E
    movel %d3,%d2
    moveal %a0,%a2
EXTRAMTEST_18:          /* loop: tst */
    tstl %a2@
    jbne EXTRAMTEST_50
    eorl %d1,%a2@+
    subql #1,%d2
    jbne EXTRAMTEST_18
    movel %d3,%d2
EXTRAMTEST_24:          /* loop: eor */
    eorl %d1,%a2@-
    jbne EXTRAMTEST_50
    subql #1,%d2
    jbne EXTRAMTEST_24
    movel %d3,%d2
EXTRAMTEST_2E:          /* loop: tst */
    tstl %a2@
    jbne EXTRAMTEST_50
    eorl %d1,%a2@+
    subql #1,%d2
    jbne EXTRAMTEST_2E
    movel %d3,%d2
EXTRAMTEST_3A:          /* loop: eor */
    eorl %d1,%a2@-
    jbne EXTRAMTEST_50
    subql #1,%d2
    jbne EXTRAMTEST_3A
    movel %d3,%d2
EXTRAMTEST_44:          /* loop: tst */
    tstl %a2@
    jbne EXTRAMTEST_50
    addql #4,%a2
    subql #1,%d2
    jbne EXTRAMTEST_44
    jmp %fp@
EXTRAMTEST_50:          /* from here: orl %a2@,%d6 */
    orl %a2@,%d6
    jmp %fp@

/* ADDRLINETEST: RAM address line test. */
ADDRLINETEST:
    clrb %d7
    movel %a0,%sp@-
ADDRLINETEST_4:         /* loop: addq */
    addqb #1,%d7
    moveal %a0@+,%a1
    cmpaw #-1,%a1
    jbeq ADDRLINETEST_22
    moveal %a0@+,%a2
    movel %a1,%a1@
    moveq #4,%d5
ADDRLINETEST_14:        /* loop: movea */
    moveal %d5,%a3
    addal %a1,%a3
    movel %a3,%a3@
    lsll #1,%d5
    cmpl %a2,%d5
    jblt ADDRLINETEST_14
    jbra ADDRLINETEST_4
ADDRLINETEST_22:        /* address %a0@(-4) */
    lea %a0@(-4),%a0
ADDRLINETEST_26:        /* loop: subq */
    subqb #1,%d7
    moveal %a0@-,%a2
    moveal %a0@-,%a1
    moveq #4,%d5
ADDRLINETEST_2E:        /* loop: ls */
    lsll #1,%d5
    cmpl %a2,%d5
    jblt ADDRLINETEST_2E
ADDRLINETEST_34:        /* loop: lsr */
    lsrl #1,%d5
    movel %d5,%d0
    addl %a1,%d0
    moveal %d0,%a3
    movel %a3@,%d6
    eorl %d0,%d6
    jbne ADDRLINETEST_58
    cmpil #4,%d5
    jbgt ADDRLINETEST_34
    tstl %d5
    jbeq ADDRLINETEST_52
    moveq #0,%d5
    jbra ADDRLINETEST_34
ADDRLINETEST_52:        /* test %sp@,%a0 */
    cmpal %sp@,%a0
    jbgt ADDRLINETEST_26
    clrb %d7
ADDRLINETEST_58:        /* set %a0 */
    moveal %sp@+,%a0
    jmp %fp@

/* DATABUSTEST: data bus test. */
DATABUSTEST:
    moveq #1,%d0
    moveq #-2,%d1
    movew #255,%d2
DATABUSTEST_8:          /* loop: movem */
    moveml %d0-%d1,%a0@
    eorl %d0,%a0@
    orl %a0@,%d6
    eorl %d1,%a0@(4)
    orl %a0@(4),%d6
    roll #1,%d0
    roll #1,%d1
    dbf %d2,DATABUSTEST_8
    jmp %fp@
DATABUSTEST_22:         /* (data) */
    .short  0x0011, 0x2233	| 40847B56
DATABUSTEST_26:         /* (data) */
    .short  0x8888, 0x8888, 0x8800	| 40847B5A
    .long   0x11223388, 0x88888888, 0x00112233, 0x88888888	| 40847B60
    .long   0x88001122, 0x33888888, 0x88880011, 0x22330011	| 40847B70
    .long   0x88888888, 0x88888800, 0x11888888, 0x88888888	| 40847B80
    .long   0x00118888, 0x88888888, 0x88001188, 0x88888888	| 40847B90
    .long   0x88880011, 0x88880088, 0x88888888, 0x88888800	| 40847BA0
    .long   0x88888888, 0x88888888, 0x00888888, 0x88888888	| 40847BB0
    .short  0x8800, 0x8888, 0x8888, 0x8888, 0x8888, 0x0088, 0x8888	| 40847BC0

/* DYNAMIC_BUSSIZE_TEST: dynamic bus sizing test. */
DYNAMIC_BUSSIZE_TEST:
    movel #32767,%d6
    lea %pc@(DATABUSTEST_22),%a1
    lea %pc@(DATABUSTEST_26),%a2
    movel #1122867,%d0
    moveq #0,%d1
DYNAMIC_BUSSIZE_TEST_16:  /* loop: move */
    movel %a2@,%a0@
    movel %a2@,%a0@(4)
    movel %d0,%a0@(0x0,%d1:w)
    moveml %a0@,%d2-%d3
    moveml %a1@+,%d4-%d5
    cmpl %d4,%d2
    jbne DYNAMIC_BUSSIZE_TEST_36
    cmpl %d5,%d3
    jbne DYNAMIC_BUSSIZE_TEST_36
    swap %d1
    bclr %d1,%d6
    swap %d1
DYNAMIC_BUSSIZE_TEST_36:  /* add 1 to %d1 */
    addql #1,%d1
    swap %d1
    addqw #1,%d1
    swap %d1
    cmpib #4,%d1
    jbls DYNAMIC_BUSSIZE_TEST_16
    movew #17,%d0
    clrw %d1
DYNAMIC_BUSSIZE_TEST_4A:  /* loop: move */
    movel %a2@,%a0@
    movel %a2@,%a0@(4)
    movew %d0,%a0@(0x0,%d1:w)
    moveml %a0@,%d2-%d3
    moveml %a1@+,%d4-%d5
    cmpl %d4,%d2
    jbne DYNAMIC_BUSSIZE_TEST_6A
    cmpl %d5,%d3
    jbne DYNAMIC_BUSSIZE_TEST_6A
    swap %d1
    bclr %d1,%d6
    swap %d1
DYNAMIC_BUSSIZE_TEST_6A:  /* add 1 to %d1 */
    addql #1,%d1
    swap %d1
    addqw #1,%d1
    swap %d1
    cmpib #4,%d1
    jbls DYNAMIC_BUSSIZE_TEST_4A
    moveq #0,%d0
    clrw %d1
DYNAMIC_BUSSIZE_TEST_7C:  /* loop: move */
    movel %a2@,%a0@
    movel %a2@,%a0@(4)
    moveb %d0,%a0@(0x0,%d1:w)
    moveml %a0@,%d2-%d3
    moveml %a1@+,%d4-%d5
    cmpl %d4,%d2
    jbne DYNAMIC_BUSSIZE_TEST_9C
    cmpl %d5,%d3
    jbne DYNAMIC_BUSSIZE_TEST_9C
    swap %d1
    bclr %d1,%d6
    swap %d1
DYNAMIC_BUSSIZE_TEST_9C:  /* add 1 to %d1 */
    addql #1,%d1
    swap %d1
    addqw #1,%d1
    swap %d1
    cmpib #4,%d1
    jbls DYNAMIC_BUSSIZE_TEST_7C
    jmp %fp@

/* MOVINVTEST: moving inversions RAM test. */
MOVINVTEST:
    moveal %a0,%a5
    movel %a1,%d3
    subl %a0,%d3
MOVINVTEST_6:           /* loop: clr */
    clrl %a0@+
    subql #4,%d3
    jbne MOVINVTEST_6
    moveq #0,%d1
    movew #4,%d1
MOVINVTEST_12:          /* loop: suba */
    subal %a2,%a2
MOVINVTEST_14:          /* loop: movea */
    moveal %a5,%a0
    addal %a2,%a0
    moveq #0,%d2
    moveq #0,%d4
MOVINVTEST_1C:          /* loop: movea */
    moveal %a0,%a3
MOVINVTEST_1E:          /* loop: move */
    movel %a3@,%d3
    cmpl %d3,%d4
    bnew MOVINVTEST_80
    bset %d2,%d3
    movel %d3,%a3@
    movel %a3@,%d5
    cmpl %d5,%d3
    bnew MOVINVTEST_86
    addal %d1,%a3
    cmpal %a1,%a3
    jbmi MOVINVTEST_1E
    movel %d5,%d4
    addqw #1,%d2
    cmpiw #32,%d2
    jbne MOVINVTEST_1C
    moveq #0,%d2
    moveq #-1,%d4
MOVINVTEST_46:          /* loop: movea */
    moveal %a0,%a3
MOVINVTEST_48:          /* loop: move */
    movel %a3@,%d3
    cmpl %d3,%d4
    bnew MOVINVTEST_80
    bclr %d2,%d3
    movel %d3,%a3@
    movel %a3@,%d5
    cmpl %d5,%d3
    bnew MOVINVTEST_86
    addal %d1,%a3
    cmpal %a1,%a3
    jbmi MOVINVTEST_48
    movel %d5,%d4
    addqw #1,%d2
    cmpiw #32,%d2
    jbne MOVINVTEST_46
    addql #4,%a2
    cmpal %d1,%a2
    jbne MOVINVTEST_14
    asll #1,%d1
    cmpil #524288,%d1
    jbne MOVINVTEST_12
MOVINVTEST_7C:          /* loop: movea */
    moveal %a5,%a0
    jmp %fp@
MOVINVTEST_80:          /* from here: eorl %d3,%d4 */
    eorl %d3,%d4
    movel %d4,%d6
    jbra MOVINVTEST_7C
MOVINVTEST_86:          /* from here: eorl %d5,%d3 */
    eorl %d5,%d3
    movel %d3,%d6
    jbra MOVINVTEST_7C

/* NOTEST: no test. */
NOTEST:
    moveq #0,%d6
    jmp %fp@

/* VRAMDATATEST: video RAM data test. */
VRAMDATATEST:
VRAMADDRTEST:
MAPRAMUNIQTEST:
MAPRAMDATATEST:
    moveq #-1,%d6
    jmp %fp@

/* SETSCCIOPBYPASS: SCC IOP in bypass mode for the tests. */
SETSCCIOPBYPASS:
    moveb #50,%a3@(-28)
    lea %pc@(SETSCCIOPBYPASS_3C),%a0
    moveal %a0,%a1
    movew %a0@+,%d0
    movew %a0@+,%a3@(-31)
SETSCCIOPBYPASS_12:     /* loop: move */
    moveb %a0@+,%a3@(-24)
    dbf %d0,SETSCCIOPBYPASS_12
    movew %a1@+,%d0
    movew %a1@+,%a3@(-31)
SETSCCIOPBYPASS_20:     /* loop: move */
    moveb %a3@(-24),%d1
    cmpb %a1@+,%d1
    jbne SETSCCIOPBYPASS_38
    dbf %d0,SETSCCIOPBYPASS_20
    moveb #54,%a3@(-28)
    lsrw #6,%d0
SETSCCIOPBYPASS_34:     /* count down (loop) */
    dbf %d0,SETSCCIOPBYPASS_34
SETSCCIOPBYPASS_38:     /* add 1 to %d0 */
    addqw #1,%d0
    jmp %fp@
SETSCCIOPBYPASS_3C:     /* (data) */
    .short  0x0011, 0x7FEE, 0xA981	| 40847D4A
    .long   0x8D30F0A9, 0x448D31F0, 0x80FEEE7F, 0xEE7FEE7F	| 40847D50

SETSCCIOPBYPASS_52:     /* loop: movea */
    moveal %a0@(8),%a2
    btst #17,%d0
    jbeq SETSCCIOPBYPASS_64
    moveal %a0@(68),%a3
    moveq #0,%d3
    jbra SETSCCIOPBYPASS_6E
SETSCCIOPBYPASS_64:     /* set %a3 */
    moveal %a0@(12),%a3
    movel %a0@(16),%d3
    subl %a3,%d3
SETSCCIOPBYPASS_6E:     /* clear bit 3 of %a2@(7680) */
    bclr #3,%a2@(7680)
    bset #3,%a2@(1536)
    addqw #2,%a3
    rts

SETSCCIOPBYPASS_7E:     /* loop: lea */
    lea %pc@(SCCTIMERTEST_C2),%a0
    jbsr SETSCCIOPBYPASS_94
    lea %pc@(SCCTIMERTEST_C6),%a0
    jbsr SETSCCIOPBYPASS_94
    subqw #2,%a3
    lea %pc@(SCCTIMERTEST_C6),%a0
    jbsr SETSCCIOPBYPASS_94
    rts

SETSCCIOPBYPASS_94:     /* loop: move */
    movew %a0@+,%d0
    moveb %a3@,%d2
SETSCCIOPBYPASS_98:     /* loop: move */
    movew %sp@,%sp@
    moveb %a0@+,%a3@(0x0,%d3:l)
    dbf %d0,SETSCCIOPBYPASS_98
    rts

SETSCCIOPBYPASS_A4:     /* loop: move */
    movew #1000,%d0
SETSCCIOPBYPASS_A8:     /* loop: tst */
    tstb %a2@
    dbf %d0,SETSCCIOPBYPASS_A8
    tstb %a3@(4)
    movew #128,%d1
SETSCCIOPBYPASS_B6:     /* loop: moveq */
    moveq #-1,%d4
    moveq #0,%d6
    moveb #48,%a3@(0x0,%d3:l)
    moveb %sp@,%sp@
SETSCCIOPBYPASS_C2:     /* loop: btst */
    btst #2,%a3@
    jbne SETSCCIOPBYPASS_D0
    dbf %d4,SETSCCIOPBYPASS_C2
    moveq #1,%d6
    jbra SETSCCIOPBYPASS_122
SETSCCIOPBYPASS_D0:     /* set %d3:l) */
    moveb %d1,%a3@(0x4,%d3:l)
    moveq #-1,%d4
SETSCCIOPBYPASS_D6:     /* loop: move */
    moveb #1,%a3@(0x0,%d3:l)
    movew %sp@,%sp@
    btst #0,%a3@
    jbne SETSCCIOPBYPASS_EC
    dbf %d4,SETSCCIOPBYPASS_D6
    moveq #2,%d6
    jbra SETSCCIOPBYPASS_122
SETSCCIOPBYPASS_EC:     /* set %d4 */
    movew #-1,%d4
SETSCCIOPBYPASS_F0:     /* loop: btst */
    btst #0,%a3@
    jbne SETSCCIOPBYPASS_FE
    dbf %d4,SETSCCIOPBYPASS_F0
    moveq #3,%d6
    jbra SETSCCIOPBYPASS_122
SETSCCIOPBYPASS_FE:     /* set %d2 */
    moveb %a3@(4),%d2
    cmpb %d1,%d2
    jbeq SETSCCIOPBYPASS_10A
    moveq #4,%d6
    jbra SETSCCIOPBYPASS_122
SETSCCIOPBYPASS_10A:    /* set %d3:l) */
    moveb #1,%a3@(0x0,%d3:l)
    movew %sp@,%sp@
    moveb %a3@,%d2
    andib #112,%d2
    jbeq SETSCCIOPBYPASS_11E
    moveq #5,%d6
    jbra SETSCCIOPBYPASS_122
SETSCCIOPBYPASS_11E:    /* from here: lsrb #1,%d1 */
    lsrb #1,%d1
    jbne SETSCCIOPBYPASS_B6
SETSCCIOPBYPASS_122:    /* return */
    rts

/* SCCLOOPTEST: SCC loopback test. */
SCCLOOPTEST:
    movew %sr,%sp@-
    oriw #1792,%sr
    movec %cacr,%d3
    movel %d3,%sp@-
    bclr #15,%d3
    movec %d3,%cacr
    jbsr SETSCCIOPBYPASS_52
    lea %pc@(SCCTIMERTEST_AE),%a0
    jbsr SETSCCIOPBYPASS_94
    lea %pc@(SCCTIMERTEST_D0),%a0
    jbsr SETSCCIOPBYPASS_94
    jbsr SETSCCIOPBYPASS_A4
    jbne SCCLOOPTEST_4E
    jbsr SETSCCIOPBYPASS_94
    lea %pc@(SCCTIMERTEST_AE),%a0
    jbsr SETSCCIOPBYPASS_94
    lea %pc@(SCCTIMERTEST_D0),%a0
    jbsr SETSCCIOPBYPASS_94
    jbsr SETSCCIOPBYPASS_A4
    addqw #2,%a3
    jbeq SCCLOOPTEST_4E
    addiw #16,%d6
SCCLOOPTEST_4E:         /* call SETSCCIOPBYPASS_7E */
    jbsr SETSCCIOPBYPASS_7E
    movel %sp@+,%d3
    movec %d3,%cacr
    movew %sp@+,%sr
    jmp %fp@

SCCLOOPTEST_5C:         /* loop: moveq */
    moveq #0,%d6
    movew #255,%d1
    moveq #0,%d4
    moveb %a3@,%d0
    movel %sp@,%sp@
    moveb %d2,%a3@(0x0,%d3:l)
    movel %sp@,%sp@
    moveb %a3@,%sp@-
    movel %sp@,%sp@
SCCLOOPTEST_72:         /* loop: move */
    moveb %d2,%a3@(0x0,%d3:l)
    movel %sp@,%sp@
    andb %d5,%d4
    moveb %d4,%a3@(0x0,%d3:l)
    movel %sp@,%sp@
    moveb %d2,%a3@(0x0,%d3:l)
    movel %sp@,%sp@
    moveb %a3@,%d0
    andb %d5,%d0
    cmpb %d4,%d0
    jbne SCCLOOPTEST_96
    addql #1,%d4
    dbf %d1,SCCLOOPTEST_72
    jbra SCCLOOPTEST_A6
SCCLOOPTEST_96:         /* set %d6 */
    moveb #0xff,%d6
    asll #8,%d6
    moveb %d2,%d6
    asll #8,%d6
    moveb %d4,%d6
    asll #8,%d6
    moveb %d0,%d6
SCCLOOPTEST_A6:         /* set %d3:l) */
    moveb %d2,%a3@(0x0,%d3:l)
    movel %sp@,%sp@
    moveb %sp@+,%a3@(0x0,%d3:l)
    tstl %d6
    rts

/* SCCREGTEST: SCC register test. */
SCCREGTEST:
    jbsr SETSCCIOPBYPASS_52
    lea %pc@(SCCTIMERTEST_C2),%a0
    jbsr SETSCCIOPBYPASS_94
    lea %pc@(SCCTIMERTEST_EA),%a4
SCCREGTEST_10:          /* loop: move */
    moveb %a4@+,%d2
    jbmi SCCREGTEST_1C
    moveb %a4@+,%d5
    jbsr SCCLOOPTEST_5C
    jbeq SCCREGTEST_10
    jbra SCCREGTEST_30
SCCREGTEST_1C:          /* subtract 2 to %a3 */
    subqw #2,%a3
    lea %pc@(SCCTIMERTEST_F4),%a4
SCCREGTEST_22:          /* loop: move */
    moveb %a4@+,%d2
    jbmi SCCREGTEST_2E
    moveb %a4@+,%d5
    jbsr SCCLOOPTEST_5C
    jbeq SCCREGTEST_22
SCCREGTEST_2E:          /* add 2 to %a3 */
    addqw #2,%a3
SCCREGTEST_30:          /* call SETSCCIOPBYPASS_7E */
    jbsr SETSCCIOPBYPASS_7E
    jmp %fp@

SCCREGTEST_36:          /* loop: movea */
    moveal %sp@+,%a1
    oriw #1792,%sr
    btst #18,%d0
    jbeq SCCREGTEST_54
    moveal %a0@(72),%a2
    moveq #14,%d1
SCCREGTEST_48:          /* loop: move */
    moveb %a2@(0x0,%d1:w),%sp@-
    clrb %a2@(0x0,%d1:w)
    dbf %d1,SCCREGTEST_48
SCCREGTEST_54:          /* set %d1 */
    moveq #127,%d1
    btst #11,%d0
    jbeq SCCREGTEST_68
    moveal %a0@(44),%a2
    moveb %a2@(7168),%sp@-
    moveb %d1,%a2@(7168)
SCCREGTEST_68:          /* test bit 13 of %d0 */
    btst #13,%d0
    jbeq SCCREGTEST_8A
    moveal %a0@(52),%a2
    moveb %a2@(18),%sp@-
    bset #7,%sp@
    moveb %d1,%a2@(18)
    moveb %a2@(19),%sp@-
    bset #7,%sp@
    moveb %d1,%a2@(19)
SCCREGTEST_8A:          /* set %a2 */
    moveal %a0@(8),%a2
    moveb %a2@(7168),%sp@-
    moveb %d1,%a2@(7168)
    jmp %a1@

SCCREGTEST_98:          /* loop: movea */
    moveal %sp@+,%a1
    moveq #127,%d1
    moveal %a0@(8),%a2
    moveb %d1,%a2@(7168)
    moveb %sp@+,%a2@(7168)
    btst #13,%d0
    jbeq SCCREGTEST_BA
    moveal %a0@(52),%a2
    moveb %sp@+,%a2@(19)
    moveb %sp@+,%a2@(18)
SCCREGTEST_BA:          /* test bit 11 of %d0 */
    btst #11,%d0
    jbeq SCCREGTEST_CC
    moveal %a0@(44),%a2
    moveb %d1,%a2@(7168)
    moveb %sp@+,%a2@(7168)
SCCREGTEST_CC:          /* test bit 18 of %d0 */
    btst #18,%d0
    jbeq SCCREGTEST_E4
    moveal %a0@(72),%a2
    moveq #0,%d1
SCCREGTEST_D8:          /* loop: move */
    moveb %sp@+,%a2@(0x0,%d1:w)
    addqb #1,%d1
    cmpib #14,%d1
    jble SCCREGTEST_D8
SCCREGTEST_E4:          /* jump through %a1@ */
    jmp %a1@

/* SCCTIMERTEST: SCC timer test. */
SCCTIMERTEST:
    jbsr SETSCCIOPBYPASS_52
    jbsr SCCREGTEST_36
    movel %d0,%sp@-
    movel %a0,%sp@-
    btst #18,%d0
    jbeq SCCTIMERTEST_1C
    moveal %a0@(72),%a1
    moveb #4,%a1@(7)
SCCTIMERTEST_1C:        /* set %a5 */
    movec %vbr,%a5
    addaw #112,%a5
    movel %a5@,%sp@-
    lea %pc@(SCCTIMERTEST_94),%a1
    movel %a1,%a5@
    lea %pc@(SCCTIMERTEST_D6),%a0
    jbsr SETSCCIOPBYPASS_94
SCCTIMERTEST_34:        /* set %d6 */
    moveq #1,%d6
    moveq #-1,%d1
    movel #327680,%d0
    movew #8960,%sr
SCCTIMERTEST_42:        /* loop: tst */
    tstw %d1
    jbeq SCCTIMERTEST_4C
    subql #1,%d0
    jbne SCCTIMERTEST_42
    jbra SCCTIMERTEST_74
SCCTIMERTEST_4C:        /* loop: tst */
    tstw %d1
    jbne SCCTIMERTEST_58
    subql #1,%d0
    jbne SCCTIMERTEST_4C
    moveq #2,%d6
    jbra SCCTIMERTEST_74
SCCTIMERTEST_58:        /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    subl %d2,%d5
    moveq #3,%d6
    cmpil #65536,%d5
    jbgt SCCTIMERTEST_74
    moveq #4,%d6
    cmpil #256,%d5
    jblt SCCTIMERTEST_74
    moveq #0,%d6
SCCTIMERTEST_74:        /* address %pc@(SCCTIMERTEST_C2) */
    lea %pc@(SCCTIMERTEST_C2),%a0
    jbsr SETSCCIOPBYPASS_94
    oriw #1792,%sr
    movec %vbr,%a5
    addaw #112,%a5
    movel %sp@+,%a5@
    moveal %sp@+,%a0
    movel %sp@+,%d0
    jbsr SCCREGTEST_98
    jmp %fp@
SCCTIMERTEST_94:        /* set %d3:l) */
    moveb #16,%a3@(0x0,%d3:l)
    movel %d0,%d2
    tstw %d1
    jbpl SCCTIMERTEST_A2
    movel %d2,%d5
SCCTIMERTEST_A2:        /* add 1 to %d1 */
    addqw #1,%d1
    tstb %a2@(7168)
    tstb %a2@(6656)
    rte
SCCTIMERTEST_AE:        /* (data) */
    .short  0x0011, 0x09C0, 0x044C, 0x0B50, 0x0F00, 0x0C00, 0x0D00, 0x0E01	| 4084807A
    .short  0x03C1, 0x056A	| 4084808A
SCCTIMERTEST_C2:        /* (data) */
    .short  0x0001, 0x09C0	| 4084808E
SCCTIMERTEST_C6:        /* (data) */
    .short  0x0007, 0x0F08, 0x0010, 0x0101, 0x0908	| 40848092
SCCTIMERTEST_D0:        /* (data) */
    .short  0x0003, 0x0E11	| 4084809C orib #17,%d3
SCCTIMERTEST_D4:        /* from here: bchg %d2,%a0@(17) */
    bchg %d2,%a0@(17)
    bset %d4,%d0
    .short  0x0CFF, 0x0DFF, 0x0E00, 0x0E03, 0x0F02, 0x0010, 0x0101, 0x090A	| 408480A6
SCCTIMERTEST_EA:        /* (data) */
    .short  0x02FF, 0x0CFF, 0x0DFF, 0x0FFA, 0xFFFF	| 408480B6
SCCTIMERTEST_F4:        /* (data) */
    .short  0x0200, 0x0CFF, 0x0DFF, 0x0FFA, 0xFFFF	| 408480C0

/* VIATEST: VIA test. */
VIATEST:
    jbsr SCCREGTEST_36
    btst #18,%d0
    jbeq VIATEST_1A
    moveal %a0@(72),%a1
    moveb #1,%a1@(11)
    moveb #1,%a1@(10)
VIATEST_1A:             /* set %a2 */
    movec %vbr,%a2
    addaw #100,%a2
    movel %a2@,%sp@-
    lea %pc@(VIATEST_18E),%a3
    movel %a3,%a2@
    moveq #0,%d6
    movel %d0,%d1
    moveal %a0@(8),%a2
    andib #31,%a2@(5632)
    orib #64,%a2@(5632)
    moveb #98,%a2@(6656)
    moveb #0xe2,%a2@(7168)
    moveq #0,%d3
    moveq #0,%d4
    moveq #0,%d5
    moveb #0xff,%a2@(2560)
    moveb #0xff,%a2@(4608)
    moveb #0xff,%a2@(2048)
    moveb #0xff,%a2@(4096)
    moveb #2,%a2@(2560)
    moveb #63,%a2@(4608)
    movel #983040,%d0
    movew #8192,%sr
VIATEST_7E:             /* loop: cmpi */
    cmpiw #10,%d3
    jbeq VIATEST_88
    subql #1,%d0
    jbne VIATEST_7E
VIATEST_88:             /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    moveq #1,%d6
    tstw %d3
    jbeq VIATEST_172
    moveq #2,%d6
    cmpiw #10,%d3
    jbne VIATEST_172
    moveq #3,%d6
    tstw %d4
    jbeq VIATEST_172
    moveq #4,%d6
    cmpiw #128,%d4
    jbmi VIATEST_172
    moveq #5,%d6
    cmpiw #208,%d4
    jbpl VIATEST_172
    moveq #6,%d6
    tstw %d5
    jbeq VIATEST_172
    moveq #7,%d6
    cmpiw #1,%d5
    jbne VIATEST_172
    moveq #8,%d6
    moveq #-1,%d0
VIATEST_D0:             /* loop: tst */
    tstb %a2@(2048)
    dbne %d0,VIATEST_D0
    jbeq VIATEST_172
    moveq #9,%d6
    moveq #-1,%d0
VIATEST_E0:             /* loop: tst */
    tstb %a2@(4096)
    dbne %d0,VIATEST_E0
    jbeq VIATEST_172
    andib #31,%a2@(5632)
    moveb #98,%a2@(6656)
    moveb #0xe2,%a2@(7168)
    moveq #0,%d3
    moveq #0,%d4
    moveq #0,%d5
    moveb #0xff,%a2@(2560)
    moveb #0xff,%a2@(4608)
    moveb #0xff,%a2@(2048)
    moveb #0xff,%a2@(4096)
    moveb #4,%a2@(2560)
    moveb #31,%a2@(4608)
    movel #983040,%d0
    movew #8192,%sr
VIATEST_132:            /* loop: cmpi */
    cmpiw #10,%d3
    jbeq VIATEST_13C
    subql #1,%d0
    jbne VIATEST_132
VIATEST_13C:            /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    moveq #10,%d6
    tstw %d3
    jbeq VIATEST_172
    moveq #11,%d6
    tstw %d4
    jbeq VIATEST_172
    moveq #12,%d6
    cmpiw #1,%d4
    jbne VIATEST_172
    moveq #13,%d6
    tstw %d5
    jbeq VIATEST_172
    moveq #14,%d6
    cmpiw #1,%d5
    jbne VIATEST_172
    moveq #15,%d6
    moveq #-1,%d0
VIATEST_166:            /* loop: tst */
    tstb %a2@(4096)
    dbne %d0,VIATEST_166
    jbeq VIATEST_172
    clrw %d6
VIATEST_172:            /* from here: andib #31,%a2@(5632) */
    andib #31,%a2@(5632)
    oriw #1792,%sr
    movec %vbr,%a2
    addaw #100,%a2
    movel %sp@+,%a2@
    movel %d1,%d0
    jbsr SCCREGTEST_98
    jmp %fp@
VIATEST_18E:            /* set %sp@- */
    movel %d0,%sp@-
    moveb %a2@(6656),%d0
    andib #98,%d0
    moveb %d0,%a2@(6656)
    btst #18,%d1
    jbeq VIATEST_1B2
    movew %a1@(514),%d2
    btst #10,%d2
    jbeq VIATEST_1BA
    clrb %a1@(519)
    jbra VIATEST_1B8
VIATEST_1B2:            /* test bit 1 of %d0 */
    btst #1,%d0
    jbeq VIATEST_1BA
VIATEST_1B8:            /* add 1 to %d3 */
    addqw #1,%d3
VIATEST_1BA:            /* test bit 6 of %d0 */
    btst #6,%d0
    jbeq VIATEST_1C2
    addqw #1,%d4
VIATEST_1C2:            /* test bit 5 of %d0 */
    btst #5,%d0
    jbeq VIATEST_1CA
    addqw #1,%d5
VIATEST_1CA:            /* set %d0 */
    movel %sp@+,%d0
    rte

/* TESTSCSI: SCSI chip test. */
TESTSCSI:
    .long   0x08000008, 0x670000DE	| 40848298
    moveal %a0@(8),%a2
    moveal %a0@(32),%a0
    moveal %a0,%a1
    addaw #0,%a1
    moveb #0x80,%a1@(16)
    moveq #0,%d0
    moveb %d0,%a1@(16)
    tstb %a0@(112)
    moveq #1,%d6
    moveb #0x80,%a1@(16)
    moveb %a0@(16),%d1
    cmpib #0x80,%d1
    jbne TESTSCSI_E2
    addqw #1,%d6
    moveb %a0@(64),%d1
    andib #0x80,%d1
    cmpib #0x80,%d1
    jbne TESTSCSI_E2
    clrb %a1@(16)
    addqw #1,%d6
    tstb %a2@(7168)
    tstb %a2@(6656)
    moveb #16,%a1@(16)
    moveb %a0@(16),%d1
    cmpib #16,%d1
    jbne TESTSCSI_E2
    addqw #1,%d6
    moveb %a0@(80),%d1
    andib #1,%d1
    cmpib #1,%d1
    jbne TESTSCSI_E2
    addqw #1,%d6
    moveb #8,%a1@(16)
    moveb %a0@(16),%d1
    cmpib #8,%d1
    jbne TESTSCSI_E2
    addqw #1,%d6
    moveb %a0@(64),%d1
    andib #64,%d1
    cmpib #64,%d1
    jbne TESTSCSI_E2
    addqw #1,%d6
    moveb #4,%a1@(16)
    moveb %a0@(16),%d1
    cmpib #4,%d1
    jbne TESTSCSI_E2
    addqw #1,%d6
    moveb %a0@(64),%d1
    andib #2,%d1
    cmpib #2,%d1
    jbne TESTSCSI_E2
    addqw #1,%d6
    moveb #2,%a1@(16)
    moveb %a0@(16),%d1
    cmpib #2,%d1
    jbne TESTSCSI_E2
    addqw #1,%d6
    moveb %a0@(80),%d1
    andib #2,%d1
    cmpib #2,%d1
    jbne TESTSCSI_E2
    moveq #0,%d6
TESTSCSI_E2:            /* jump through %fp@ */
    jmp %fp@
    moveq #-1,%d6
    jmp %fp@

/* TESTASC: sound chip test. */
TESTASC:
    btst #12,%d0
    jbeq TESTASC_352
    moveml %d0-%d5/%a0-%a4,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #0,%d6
    moveq #0,%d5
    moveq #0,%d4
    moveal %a0@(8),%a2
    moveal %a0@(48),%a1
    moveb %a1@(2048),%d3
    andib #0xf0,%d3
    cmpib #0xe0,%d3
    jbne TESTASC_38
    lea %pc@(TESTASC_2D2),%a4
    lea %pc@(TESTASC_2F0),%a3
    jbra TESTASC_98
TESTASC_38:             /* set %d3 */
    moveb %a1@(2048),%d3
    cmpib #0xb0,%d3
    jbne TESTASC_4C
    lea %pc@(TESTASC_26A),%a4
    lea %pc@(TESTASC_28E),%a3
    jbra TESTASC_98
TESTASC_4C:             /* from here: andib #0xf0,%d3 */
    andib #0xf0,%d3
    cmpib #0xb0,%d3
    jbne TESTASC_60
    lea %pc@(TESTASC_2AE),%a4
    lea %pc@(TESTASC_2C6),%a3
    jbra TESTASC_98
TESTASC_60:             /* set %d3 */
    movew %d2,%d3
    lsrw #8,%d3
    cmpib #12,%d3
    jbne TESTASC_74
    lea %pc@(TESTASC_208),%a4
    lea %pc@(TESTASC_238),%a3
    jbra TESTASC_98
TESTASC_74:             /* address %pc@(TESTASC_300) */
    lea %pc@(TESTASC_300),%a4
    lea %pc@(TESTASC_32A),%a3
    moveb #28,%a1@(2054)
    moveb %a1@(2054),%d3
    andib #28,%d3
    jbne TESTASC_98
    lea %pc@(TESTASC_20E),%a4
    lea %pc@(TESTASC_240),%a3
    jbra TESTASC_98
TESTASC_96:             /* loop: addq */
    addql #2,%a4
TESTASC_98:             /* set %d3 */
    movel %a4@+,%d3
    jbmi TESTASC_C6
    subqw #1,%d3
TESTASC_9E:             /* loop: swap */
    swap %d3
    moveb %a3@+,%d4
    moveb %d4,%a1@(0x0,%d3:w)
    tstb %a2@
    moveb %a1@(0x0,%d3:w),%d5
    andw %a4@,%d5
    swap %d3
    cmpb %d4,%d5
    dbne %d3,TESTASC_9E
    jbeq TESTASC_96
    swap %d3
    movel #65536,%d6
    movew %d3,%d6
    jbra TESTASC_19C
TESTASC_C6:             /* test #7,%d2 */
    cmpib #7,%d2
    jbeq TESTASC_19C
    cmpib #10,%d2
    jbeq TESTASC_19C
    moveb %a1@(2048),%d3
    andib #0xf0,%d3
    cmpib #0xb0,%d3
    jbeq TESTASC_19C
    moveb #2,%a1@(2049)
    clrb %a1@(2058)
    clrb %a1@(2054)
    clrb %d5
TESTASC_F6:             /* loop: move */
    movew #2047,%d4
    moveal %a1,%a2
TESTASC_FC:             /* loop: move */
    moveb %d5,%d3
    eorb %d4,%d3
    moveb %d3,%a2@+
    dbf %d4,TESTASC_FC
    moveal %a1,%a2
    movew #2047,%d4
TESTASC_10C:            /* loop: move */
    moveb %d5,%d3
    eorb %d4,%d3
    moveb %a2@+,%d1
    cmpb %d3,%d1
    jbne TESTASC_126
    dbf %d4,TESTASC_10C
    cmpib #0xff,%d5
    jbeq TESTASC_136
    moveb #0xff,%d5
    jbra TESTASC_F6
TESTASC_126:            /* set %d6 */
    movel #131072,%d6
    movew %a2,%d6
    andiw #2047,%d6
    braw TESTASC_19C
TESTASC_136:            /* set %d3 */
    movew %d2,%d3
    lsrw #8,%d3
    cmpib #12,%d3
    jbne TESTASC_19C
    moveb %a1@(2048),%d3
    andib #0xf0,%d3
    cmpib #0xb0,%d3
    jbeq TESTASC_19C
    moveb #0x81,%a1@(2058)
    moveb #0x80,%a1@(2051)
    clrb %a1@(2051)
    clrb %d5
TESTASC_160:            /* loop: move */
    movew #1023,%d4
    moveal %a1,%a2
TESTASC_166:            /* loop: move */
    moveb %d5,%d3
    eorb %d4,%d3
    moveb %d3,%a2@+
    dbf %d4,TESTASC_166
    moveal %a1,%a2
    movew #1023,%d4
TESTASC_176:            /* loop: move */
    moveb %d5,%d3
    eorb %d4,%d3
    moveb %a2@+,%d1
    cmpb %d3,%d1
    jbne TESTASC_190
    dbf %d4,TESTASC_176
    cmpib #0xff,%d5
    jbeq TESTASC_19C
    moveb #0xff,%d5
    jbra TESTASC_160
TESTASC_190:            /* set %d6 */
    movel #196608,%d6
    movew %a2,%d6
    andiw #1023,%d6
TESTASC_19C:            /* call TESTASC_1C6 */
    jbsr TESTASC_1C6
    btst #11,%d0
    jbeq TESTASC_1AE
    moveal %a0@(44),%a2
    orib #0x90,%a2@(7168)
TESTASC_1AE:            /* test bit 13 of %d0 */
    btst #13,%d0
    jbeq TESTASC_1BE
    moveal %a0@(52),%a2
    orib #0x90,%a2@(3)
TESTASC_1BE:            /* set %sr */
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d5/%a0-%a4
    jmp %fp@

TESTASC_1C6:            /* set %d3 */
    movew %d2,%d3
    lsrw #8,%d3
    cmpib #12,%d3
    jbne TESTASC_1DE
    moveb #1,%a1@(2058)
    tstb %a1@(2052)
    clrb %a1@(2058)
TESTASC_1DE:            /* set %a1@(2049) */
    moveb #1,%a1@(2049)
    clrb %a1@(2050)
    moveb #0x80,%a1@(2051)
    clrb %a1@(2051)
    tstb %a1@(2052)
    clrb %a1@(2053)
    clrb %a1@(2054)
    clrb %a1@(2055)
    clrb %a1@(2063)
    rts
TESTASC_208:            /* (data) */
    .short  0x080A, 0x0008, 0x0083	| 40848588
TESTASC_20E:            /* (data) */
    .short  0x0801	| 4084858E
    .byte   0x00, 0x04, 0x00, 0xFF, 0x08, 0x02	| 40848590
TESTASC_216:            /* (data) */
    .byte   0x00, 0x0D, 0x00, 0x7F, 0x08, 0x03, 0x00, 0x03, 0x00, 0xFF	| 40848596
    .long   0x08040006, 0x00FF0805, 0x000C00FF, 0x08070004	| 408485A0
    .long   0x00FFFFFF, 0xFFFFFFFF	| 408485B0
TESTASC_238:            /* (data) */
    .long   0x00010203, 0x81828300	| 408485B8
TESTASC_240:            /* (data) */
    .byte   0x00, 0x01, 0x02, 0x00, 0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1E, 0x1D	| 408485C0
TESTASC_24C:            /* loop: move */
    moveb %sp@,%a5@-	| 408485CC
    btst %d7,%sp@+	| 408485CE
    .short  0x0000, 0x8000	| 408485D0 orib #0,%d0
    .short  0x0001, 0x0204	| 408485D4 orib #4,%d1
    .short  0x0800, 0x0080	| 408485D8 btst #-128,%d0
    btst %d0,%d2	| 408485DC
    .byte   0x04, 0x08, 0x07, 0x0B, 0x0D, 0x0E, 0x0F, 0x00, 0x00, 0x02, 0x03, 0x00	| 408485DE
TESTASC_26A:            /* (data) */
    .short  0x0801, 0x0003, 0x0003	| 408485EA
    .long   0x08060008, 0x00E0080A, 0x00030001, 0x0F080009	| 408485F0
    .short  0x00FF, 0x0F28, 0x0009, 0x00FF, 0xFFFF, 0xFFFF, 0xFFFF	| 40848600
TESTASC_28E:            /* (data) */
    orib #0,%d1	| 4084860E
    moveal %d0,%a0	| 40848612
    jbra TESTASC_216	| 40848614
    .byte   0xA0, 0xC0, 0xE0, 0x00, 0x01, 0x00, 0x00, 0x01, 0x02, 0x03, 0x80, 0x81, 0x82, 0x83, 0x00, 0x00	| 40848616
    .byte   0x01, 0x02, 0x03, 0x80, 0x81, 0x82, 0x83, 0x00	| 40848626
TESTASC_2AE:            /* (data) */
    .short  0x0801	| 4084862E
    .long   0x00010001, 0x08060008, 0x00E0080A, 0x00030001	| 40848630
    .short  0xFFFF, 0xFFFF, 0xFFFF	| 40848640
TESTASC_2C6:            /* (data) */
    btst %d0,%d0	| 40848646
    moveal %d0,%a0	| 40848648
    jbra TESTASC_24C	| 4084864A
    .byte   0xA0, 0xC0, 0xE0, 0x00, 0x01, 0x00	| 4084864C
TESTASC_2D2:            /* (data) */
    .short  0x0801, 0x0001, 0x00FF, 0x0802, 0x0001, 0x007F, 0x0806	| 40848652
    .long   0x000800FF, 0x080A0005, 0x00FFFFFF, 0xFFFFFFFF	| 40848660
TESTASC_2F0:            /* (data) */
    .long   0x01010020, 0x406080A0, 0xC0E00001, 0x02030000	| 40848670
TESTASC_300:            /* (data) */
    .long   0x08010004, 0x00FF0802, 0x0005007F, 0x08030009	| 40848680
    .long   0x00FF0804, 0x000600FF, 0x0805000C, 0x00FF0807	| 40848690
    .short  0x0004, 0x00FF, 0xFFFF, 0xFFFF, 0xFFFF	| 408486A0
TESTASC_32A:            /* (data) */
    .short  0x0001, 0x0200, 0x0001	| 408486AA
    .long   0x02030000, 0x01028003, 0x81828300, 0x00010204	| 408486B0
    .long   0x08000080, 0x01020408, 0x070B0D0E, 0x0F000002	| 408486C0
    .short  0x0300	| 408486D0
TESTASC_352:            /* set %d6 */
    moveq #-1,%d6
    jmp %fp@

/* PRAMTEST: PRAM test. */
PRAMTEST:
    movel %fp,%sp@-
    moveal %a0@(8),%a2
    movel #255,%d3
    moveal %sp,%a3
    lea %sp@(-256),%sp
PRAMTEST_12:            /* loop: move */
    movel %a3,%sp@-
    movel %d3,%d1
    lea %pc@(PRAMTEST_1E),%fp
    jmp %pc@(RDXBYTE)
PRAMTEST_1E:            /* (data) */
    moveal %sp@+,%a3	| 408486F4
    moveb %d1,%a3@-	| 408486F6
    dbf %d3,PRAMTEST_12	| 408486F8
    lea %pc@(PRAMTEST_2E),%fp	| 408486FC
    jmp %pc@(CLKWPOFF)	| 40848700
PRAMTEST_2E:            /* (data) */
    .byte   0x22, 0x3C, 0x00, 0x7C, 0x00, 0xFC, 0x48, 0x41, 0x74, 0x00, 0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA	| 40848704
    .byte   0x29, 0x98, 0x42, 0x67, 0x3F, 0x3C, 0x00, 0x7F, 0x61, 0x00, 0x00, 0x58, 0x4F, 0xEF, 0x00, 0x04	| 40848714
    .byte   0x4A, 0x86, 0x66, 0x24, 0x61, 0x00, 0x00, 0x2C, 0x22, 0x3C, 0x00, 0x7C, 0x00, 0xFC, 0x74, 0x00	| 40848724
    .byte   0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x29, 0x72, 0x3F, 0x3C, 0x00, 0x80, 0x3F, 0x3C, 0x00, 0xFF	| 40848734
    .byte   0x61, 0x00, 0x00, 0x30, 0x4F, 0xEF, 0x00, 0x04, 0x61, 0x00, 0x00, 0x08, 0x4F, 0xEF, 0x01, 0x00	| 40848744
    .byte   0x4E, 0x75	| 40848754
    lea %sp@(4),%a3
    moveq #0,%d3
PRAMTEST_86:            /* loop: move */
    moveb %a3@+,%d2
    movel %d3,%d1
    movel %a3,%sp@-
    lea %pc@(PRAMTEST_94),%fp
    jmp %pc@(WRXBYTE)
PRAMTEST_94:            /* (data) */
    moveal %sp@+,%a3	| 4084876A
    addqw #1,%d3	| 4084876C
    cmpiw #256,%d3	| 4084876E
    jbne PRAMTEST_86	| 40848772
    rts	| 40848774
    .byte   0x7C, 0x00, 0x36, 0x2F, 0x00, 0x06	| 40848776
PRAMTEST_94_12:
    movew %d3,%d1	| 4084877C
    movew #165,%d2
    lea %pc@(PRAMTEST_94+0x20),%fp
    jmp %pc@(WRXBYTE)
    movew %d3,%d1
    lea %pc@(PRAMTEST_94_2A),%fp
    jmp %pc@(RDXBYTE)
PRAMTEST_94_2A:
    .short  0x0C01, 0x00A5	| cmpib #-91,%d1
    beqs PRAMTEST_94_3E
    moveb %d3,%d6
    roll #8,%d6
    moveb #0xa5,%d6	| 4084879E
    roll #8,%d6
    moveb %d1,%d6
    bras PRAMTEST_94_46
PRAMTEST_94_3E:
    addqw #1,%d3
    cmpw %sp@(4),%d3
    bles PRAMTEST_94_12	| 408487AE
PRAMTEST_94_46:
    rts

/* TESTRBV: RBV test. */
TESTRBV:
    movew #0,%ccr
    moveq #0,%d6
    moveq #0,%d5
    moveq #0,%d4
    btst #13,%d0
    beqw TESTRBV_17E
    moveal %a0@(52),%a0
    lea %pc@(TESTRBV_164),%a2
    lea %pc@(TESTRBV_164_8),%a3	| 408487CC
    movel %a1@(28),%d1
    btst #7,%d1
    beqs TESTRBV_2E
    lea %pc@(TESTRBV_164_E),%a3	| 408487DA
    bras TESTRBV_38
TESTRBV_2E:
    btst #22,%d1
    beqs TESTRBV_38
    lea %pc@(TESTRBV_164_14),%a3	| 408487E6
TESTRBV_38:
    moveq #0,%d1
    moveb %a2@+,%d1
    bmiw TESTRBV_A4
    moveb %a3@+,%d2
    moveq #-1,%d4
    moveb %a0@(0x0,%d1:w),%sp@-
TESTRBV_48:
    moveb %d4,%d3
    tstb %d1
    bnes TESTRBV_52
    orib #13,%d4
TESTRBV_52:
    andb %d2,%d4
    moveb %d4,%a0@(0x0,%d1:w)
    moveb %a0@(0x0,%d1:w),%d5
    andb %d2,%d5
    cmpb %d4,%d5
    bnew TESTRBV_9C
    moveb %d3,%d4
    roxrb #1,%d4
    cmpib #0xff,%d4	| 4084881A
    bnes TESTRBV_48
    roxrb #1,%d4
    clrb %d4
TESTRBV_72:
    moveb %d4,%d3
    tstb %d1
    bnes TESTRBV_7C
    orib #13,%d4
TESTRBV_7C:
    andb %d2,%d4
    moveb %d4,%a0@(0x0,%d1:w)
    moveb %a0@(0x0,%d1:w),%d5
    andb %d2,%d5
    cmpb %d4,%d5
    bnew TESTRBV_9C
    moveb %d3,%d4
    roxrb #1,%d4
    bnes TESTRBV_72
    roxrb #1,%d4
    moveb %sp@+,%a0@(0x0,%d1:w)
    bras TESTRBV_38
TESTRBV_9C:
    moveb %sp@+,%a0@(0x0,%d1:w)
    braw TESTRBV_158
TESTRBV_A4:
    moveb %a2@+,%d1
    bmiw TESTRBV_162
    moveb %a0@(0x0,%d1:w),%sp@-
    moveb %a3@+,%d2
    moveb %d2,%a0@(0x0,%d1:w)
    moveq #1,%d4
TESTRBV_B6:
    addiw #128,%d4
    moveb %d4,%a0@(0x0,%d1:w)
    moveb %a0@(0x0,%d1:w),%d5
    andb %d2,%d5
    bclr #7,%d4
    moveb %d4,%d3
    andb %d2,%d3
    cmpb %d3,%d5
    beqw TESTRBV_D8
    moveb %d3,%d4
    braw TESTRBV_14A
TESTRBV_D8:
    moveb %d4,%a0@(0x0,%d1:w)
    moveb %a0@(0x0,%d1:w),%d5
    andb %d2,%d5
    tstb %d5
    beqw TESTRBV_EE
    clrb %d4
    braw TESTRBV_14A
TESTRBV_EE:
    rolb #1,%d4
    cmpib #0x80,%d4	| 408488A2
    bnes TESTRBV_B6
    moveq #1,%d4
TESTRBV_F8:
    moveb #0xff,%a0@(0x0,%d1:w)	| 408488AA
    moveb %a0@(0x0,%d1:w),%d5
    bclr #7,%d5
    cmpb %d2,%d5
    beqw TESTRBV_112
    moveb %d2,%d4
    braw TESTRBV_14A
TESTRBV_112:
    moveb %d4,%a0@(0x0,%d1:w)
    moveb %a0@(0x0,%d1:w),%d5
    eorib #0xff,%d5	| 408488CC
    andb %d2,%d5
    moveb %d4,%d3
    andb %d2,%d3
    cmpb %d3,%d5
    beqw TESTRBV_130
    moveb %d3,%d4
    braw TESTRBV_14A
TESTRBV_130:
    rolb #1,%d4
    cmpib #0x80,%d4	| 408488E4
    bnes TESTRBV_F8
    moveb %d2,%a0@(0x0,%d1:w)
    moveb %sp@+,%d0
    .short  0x0000, 0x00C0	| orib #-64,%d0
    moveb %d0,%a0@(0x0,%d1:w)
    braw TESTRBV_A4
TESTRBV_14A:
    moveb %d2,%a0@(0x0,%d1:w)
    moveb %sp@+,%d0
    .short  0x0000, 0x00C0	| orib #-64,%d0
    .short  0x1180	| 40848906
    moveb %d0,%d0
TESTRBV_158:
    moveb %d1,%d6
    roll #8,%d6
    moveb %d4,%d6
    roll #8,%d6
    moveb %d5,%d6
TESTRBV_162:
    jmp %fp@
TESTRBV_164:
    .byte   0x00, 0x10, 0x11, 0xFF, 0x12, 0x13, 0xFF, 0x00	| 40848916
TESTRBV_164_8:
    .byte   0x8F, 0xC3, 0xFF, 0x7F, 0x1F, 0x00	| 4084891E
TESTRBV_164_E:
    .byte   0x08, 0x02, 0x00, 0x78, 0x7F, 0x00	| 40848924
TESTRBV_164_14:
    .byte   0x0F, 0x00, 0x00, 0x78, 0x7F, 0x00	| 4084892A
TESTRBV_17E:
    moveq #-1,%d6	| 40848930
    jmp %fp@

/* TESTSWIM: SWIM test. */
TESTSWIM:
    btst #5,%d0
    jbne TESTSWIM_A
    moveq #-1,%d6
    jmp %fp@
TESTSWIM_A:             /* set %sp@- */
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal %a0@(8),%a2
    moveal %a0@(20),%a0
    lea %a2@(7680),%a2
    tstb %a0@(5120)
    tstb %a0@(7168)
    tstb %a0@(4096)
    tstb %a0@(6656)
    moveq #87,%d0
    moveb %d0,%a0@(7680)
    moveb #23,%a0@(7680)
    moveb %d0,%a0@(7680)
    moveb %d0,%a0@(7680)
    moveq #-11,%d0
    moveb %d0,%a0@(2048)
    nop
    cmpb %a0@(6144),%d0
    bnew TESTSWIM_7A
    moveq #-10,%d0
    moveb %d0,%a0@(2048)
    nop
    cmpb %a0@(6144),%d0
    bnew TESTSWIM_7A
    moveq #-9,%d0
    moveb %d0,%a0@(2048)
    nop
    cmpb %a0@(6144),%d0
    bnew TESTSWIM_7A
    moveb #0xbf,%a0@(3072)
    braw TESTSWIM_80
TESTSWIM_7A:            /* set %d6 */
    moveq #-2,%d6
    jbra TESTSWIM_3E0
TESTSWIM_80:            /* clear %d6 */
    moveq #0,%d6
    lea %pc@(TESTSWIM_43E),%a1
    movew #15,%d1
TESTSWIM_8A:            /* loop: move */
    moveb %a1@(0x0,%d1:w),%a0@(2048)
    nop
    moveb %a0@(6144),%d0
    cmpb %a1@(0x0,%d1:w),%d0
    jbne TESTSWIM_30C
    dbf %d1,TESTSWIM_8A
    jbsr TESTSWIM_3EC
    jbeq TESTSWIM_192
    linkw %a4,#-16
    moveb %a0@(6656),%d4
    clrb %a0@(2560)
    moveb #56,%a0@(3072)
    movew #15,%d1
TESTSWIM_C0:            /* loop: move */
    moveb %a2@,%a2@
    moveb %a0@(5632),%sp@(0x0,%d1:w)
    dbf %d1,TESTSWIM_C0
    lea %pc@(TESTSWIM_44E),%a1
    movew #4,%d2
TESTSWIM_D4:            /* loop: move */
    moveb #56,%a0@(3072)
    movew #15,%d1
    moveq #0,%d0
TESTSWIM_E0:            /* loop: move */
    moveb %a2@,%a2@
    moveb %a1@(0x0,%d1:w),%a0@(1536)
    dbf %d1,TESTSWIM_E0
    dbf %d2,TESTSWIM_D4
    lea %pc@(TESTSWIM_45E),%a1
    moveb #56,%a0@(3072)
    moveq #0,%d0
    moveq #0,%d2
    movew #15,%d1
    moveb %a2@,%a2@
TESTSWIM_104:           /* loop: move */
    moveb %a2@,%a2@
    moveb %a0@(5632),%d0
    cmpb %a1@(0x0,%d1:w),%d0
    jbne TESTSWIM_31E
    dbne %d1,TESTSWIM_104
    moveq #0,%d0
    moveq #7,%d2
    moveq #1,%d3
TESTSWIM_11C:           /* loop: move */
    moveb #56,%a0@(3072)
    movew #15,%d1
TESTSWIM_126:           /* loop: move */
    moveb %a2@,%a2@
    moveb %d3,%a0@(1536)
    dbf %d1,TESTSWIM_126
    moveb #56,%a0@(3072)
    movew #15,%d1
TESTSWIM_13A:           /* loop: move */
    moveb %a2@,%a2@
    moveb %a0@(5632),%d0
    cmpb %d3,%d0
    jbne TESTSWIM_34A
    dbf %d1,TESTSWIM_13A
    rolw #1,%d3
    dbf %d2,TESTSWIM_11C
    moveq #0,%d0
    movel #255,%d2
TESTSWIM_158:           /* loop: move */
    moveb #56,%a0@(3072)
    movew #15,%d1
TESTSWIM_162:           /* loop: move */
    moveb %a2@,%a2@
    moveb %d2,%a0@(1536)
    dbf %d1,TESTSWIM_162
    moveb #56,%a0@(3072)
    movew #15,%d1
TESTSWIM_176:           /* loop: move */
    moveb %a2@,%a2@
    moveb %a0@(5632),%d0
    cmpb %d2,%d0
    jbne TESTSWIM_35C
    dbf %d1,TESTSWIM_176
    dbf %d2,TESTSWIM_158
    lea %pc@(TESTSWIM_264),%a5
    jmp %pc@(TESTSWIM_2D0)
TESTSWIM_192:           /* entry: stack frame */
    linkw %a4,#-4
    moveb %a0@(6656),%d4
    clrb %a0@(2560)
    moveb #56,%a0@(3072)
    movew #3,%d1
TESTSWIM_1A8:           /* loop: move */
    moveb %a2@,%a2@
    moveb %a0@(5632),%sp@(0x0,%d1:w)
    dbf %d1,TESTSWIM_1A8
    lea %pc@(TESTSWIM_44E),%a1
    lea %pc@(TESTSWIM_47E),%a3
    movew #4,%d2
TESTSWIM_1C0:           /* loop: move */
    moveb #56,%a0@(3072)
    movew #3,%d1
    moveq #0,%d0
TESTSWIM_1CC:           /* loop: move */
    moveb %a2@,%a2@
    moveb %a1@(0x0,%d1:w),%d0
    andb %a3@(0x0,%d1:w),%d0
    moveb %d0,%a0@(1536)
    dbf %d1,TESTSWIM_1CC
    dbf %d2,TESTSWIM_1C0
    lea %pc@(TESTSWIM_45E),%a1
    moveb #56,%a0@(3072)
    moveq #0,%d0
    moveq #0,%d2
    movew #3,%d1
    moveb %a2@,%a2@
TESTSWIM_1F6:           /* loop: move */
    moveb %a2@,%a2@
    moveb %a0@(5632),%d0
    andb %a3@(0x0,%d1:w),%d0
    moveb %a1@(0x0,%d1:w),%d3
    andb %a3@(0x0,%d1:w),%d3
    cmpb %d3,%d0
    jbne TESTSWIM_334
    dbne %d1,TESTSWIM_1F6
    moveq #0,%d0
    movew #15,%d2
    lea %pc@(TESTSWIM_46E),%a1
TESTSWIM_21C:           /* loop: move */
    moveb #56,%a0@(3072)
    movew #3,%d1
TESTSWIM_226:           /* loop: move */
    moveb %a2@,%a2@
    moveb %a1@(0x0,%d2:w),%a0@(1536)
    dbf %d1,TESTSWIM_226
    moveb #56,%a0@(3072)
    movew #3,%d1
TESTSWIM_23C:           /* loop: move */
    moveb %a2@,%a2@
    moveb %a0@(5632),%d0
    andb %a3@(0x0,%d1:w),%d0
    moveb %a1@(0x0,%d2:w),%d3
    andb %a3@(0x0,%d1:w),%d3
    cmpb %d3,%d0
    jbne TESTSWIM_36E
    dbf %d1,TESTSWIM_23C
    dbf %d2,TESTSWIM_21C
    lea %pc@(TESTSWIM_264),%a5
    jmp %pc@(TESTSWIM_2EE)
TESTSWIM_264:           /* (data) */
    moveb %a0@(6656),%d3	| 40848B98
    movew #7,%d1	| 40848B9C
    moveq #1,%d2	| 40848BA0
TESTSWIM_26E:           /* loop: move */
    moveb %d2,%a0@(2560)	| 40848BA2
    moveb %a0@(6656),%d0	| 40848BA6
    cmpb %d2,%d0	| 40848BAA
    jbne TESTSWIM_380	| 40848BAC
    rolw #1,%d2	| 40848BB0
    dbf %d1,TESTSWIM_26E	| 40848BB2
    moveb %d3,%a0@(2560)	| 40848BB6
    moveb %a0@(7168),%d3	| 40848BBA
    movew #7,%d1	| 40848BBE
    moveb #0xbf,%a0@(3072)	| 40848BC2
    moveb %a0@(7168),%d0	| 40848BC8
    andib #0xbf,%d0	| 40848BCC
    jbne TESTSWIM_392	| 40848BD0
TESTSWIM_2A0:           /* loop: moveq */
    moveq #0,%d2	| 40848BD4
    bset %d1,%d2	| 40848BD6
    moveb %d2,%a0@(3584)	| 40848BD8
    moveb %a0@(7168),%d0	| 40848BDC
    btst %d1,%d0	| 40848BE0
    jbeq TESTSWIM_3A2	| 40848BE2
    cmpib #6,%d1	| 40848BE6
    jbeq TESTSWIM_2C8	| 40848BEA
    moveb %d2,%a0@(3072)	| 40848BEC
    moveb %a0@(7168),%d0	| 40848BF0
    andib #0xbf,%d0	| 40848BF4
    jbne TESTSWIM_392	| 40848BF8
TESTSWIM_2C8:           /* count down */
    dbf %d1,TESTSWIM_2A0	| 40848BFC
    jmp %pc@(TESTSWIM_3C0)	| 40848C00
TESTSWIM_2D0:           /* set %a0@(3072) */
    moveb #56,%a0@(3072)
    movew #15,%d1
TESTSWIM_2DA:           /* loop: move */
    moveb %a2@,%a2@
    moveb %sp@(0x0,%d1:w),%a0@(1536)
    dbf %d1,TESTSWIM_2DA
    moveb %d4,%a0@(2560)
    unlk %a4
    jmp %a5@
TESTSWIM_2EE:           /* set %a0@(3072) */
    moveb #56,%a0@(3072)
    movew #3,%d1
TESTSWIM_2F8:           /* loop: move */
    moveb %a2@,%a2@
    moveb %sp@(0x0,%d1:w),%a0@(1536)
    dbf %d1,TESTSWIM_2F8
    moveb %d4,%a0@(2560)
    unlk %a4
    jmp %a5@
TESTSWIM_30C:           /* set %d6 */
    moveb %a0@(6144),%d6
    oriw #256,%d6
    swap %d6
    orb %a1@(0x0,%d1:w),%d6
    jbra TESTSWIM_3DA
TESTSWIM_31E:           /* set %d2 */
    moveb %a1@(0x0,%d1:w),%d2
    moveb %d0,%d6
    oriw #512,%d6
    swap %d6
    orw %d2,%d6
    lea %pc@(TESTSWIM_3DA),%a5
    jmp %pc@(TESTSWIM_2D0)
TESTSWIM_334:           /* set %d2 */
    moveb %a1@(0x0,%d1:w),%d2
    moveb %d0,%d6
    oriw #2304,%d6
    swap %d6
    orw %d2,%d6
    lea %pc@(TESTSWIM_3E8),%a5
    jmp %pc@(TESTSWIM_2EE)
TESTSWIM_34A:           /* set %d6 */
    moveb %d0,%d6
    oriw #768,%d6
    swap %d6
    orw %d3,%d6
    lea %pc@(TESTSWIM_3DA),%a5
    jmp %pc@(TESTSWIM_2D0)
TESTSWIM_35C:           /* set %d6 */
    moveb %d0,%d6
    oriw #1024,%d6
    swap %d6
    orw %d2,%d6
    lea %pc@(TESTSWIM_3DA),%a5
    jmp %pc@(TESTSWIM_2D0)
TESTSWIM_36E:           /* set %d6 */
    moveb %d0,%d6
    oriw #2560,%d6
    swap %d6
    orw %d2,%d6
    lea %pc@(TESTSWIM_3E8),%a5
    jmp %pc@(TESTSWIM_2EE)
TESTSWIM_380:           /* set %d6 */
    moveb %d0,%d6	| 40848CB4
    oriw #1280,%d6	| 40848CB6
    swap %d6	| 40848CBA
    orw %d2,%d6	| 40848CBC
    moveb %d3,%a0@(2560)	| 40848CBE
    jmp %pc@(TESTSWIM_3DA)	| 40848CC2
TESTSWIM_392:           /* set %d6 */
    moveb %d0,%d6	| 40848CC6
    oriw #1536,%d6	| 40848CC8
    swap %d6	| 40848CCC
    oriw #0,%d6	| 40848CCE
    jmp %pc@(TESTSWIM_3C0)	| 40848CD2
TESTSWIM_3A2:           /* set %d6 */
    moveb %d0,%d6	| 40848CD6
    oriw #1792,%d6	| 40848CD8
    swap %d6	| 40848CDC
    orw %d2,%d6	| 40848CDE
    jmp %pc@(TESTSWIM_3C0)	| 40848CE0
TESTSWIM_3B0:           /* loop: move */
    moveb %a0@(7168),%d6	| 40848CE4
    oriw #2048,%d6	| 40848CE8
    swap %d6	| 40848CEC
    orw %d3,%d6	| 40848CEE
    jmp %pc@(TESTSWIM_3DA)	| 40848CF0
TESTSWIM_3C0:           /* set %d1 */
    movew #7,%d1	| 40848CF4
TESTSWIM_3C4:           /* loop: moveq */
    moveq #0,%d2	| 40848CF8
    btst %d1,%d3	| 40848CFA
    jbeq TESTSWIM_3D0	| 40848CFC
    bset %d1,%d2	| 40848CFE
    moveb %d2,%a0@(3584)	| 40848D00
TESTSWIM_3D0:           /* count down */
    dbf %d1,TESTSWIM_3C4	| 40848D04
    cmpb %a0@(7168),%d3	| 40848D08
    jbne TESTSWIM_3B0	| 40848D0C
TESTSWIM_3DA:           /* set %a0@(3072) */
    moveb #0xf8,%a0@(3072)
TESTSWIM_3E0:           /* test %a0@(7168) */
    tstb %a0@(7168)
    tstb %a0@(6144)
TESTSWIM_3E8:           /* set %sr */
    movew %sp@+,%sr
    jmp %fp@

TESTSWIM_3EC:           /* set %a0@(3072) */
    moveb #0xf8,%a0@(3072)
    moveq #-11,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne TESTSWIM_416
    moveq #-10,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne TESTSWIM_416
    moveq #-9,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    rts
TESTSWIM_416:           /* test %a0@(5120) */
    tstb %a0@(5120)
    tstb %a0@(7168)
    tstb %a0@(4096)
    tstb %a0@(6656)
    moveq #87,%d0
    moveb %d0,%a0@(7680)
TESTSWIM_42C:           /* set %a0@(7680) */
    moveb #23,%a0@(7680)
    moveb %d0,%a0@(7680)
    moveb %d0,%a0@(7680)
    moveq #1,%d0
    rts
TESTSWIM_43E:           /* (data) */
    .short  0xF0F1, 0xF2F3, 0xF4F5, 0xF6F7, 0xF8F9, 0xFAFB, 0xFCFD, 0xFEFF	| 40848D72
TESTSWIM_44E:           /* (data) */
    .short  0xFFEE, 0xDDCC, 0xBBAA, 0x9988, 0x7766, 0x5544, 0x3322, 0x1100	| 40848D82
TESTSWIM_45E:           /* (data) */
    .short  0xFFEC, 0xDDCC, 0xBBAA, 0x9988, 0x7766, 0x5544, 0x3322, 0x1100	| 40848D92
TESTSWIM_46E:           /* (data) */
    .short  0x0010, 0x2030	| 40848DA2 orib #48,%a0@
    negxw %a0@	| 40848DA6
    jbra FLOAT_TEST_64	| 40848DA8
    .byte   0x80, 0x90, 0xA0, 0xB0, 0xC0, 0xD0, 0xE0, 0xF0	| 40848DAA
TESTSWIM_47E:           /* (data) */
    .short  0x00F0, 0x00F0	| 40848DB2

/* FLOAT_TEST: FPU test. */
FLOAT_TEST:
    movew %a1@(16),%d3
    btst #12,%d3
    bnes FLOAT_TEST_E
    moveq #-1,%d6
    jmp %fp@
FLOAT_TEST_E:
    movew %sr,%sp@-
    moveml %d2/%d7,%sp@-
    oriw #1792,%sr
    linkw %fp,#-1600
    moveq #1,%d6
    moveq #0,%d5
    moveq #0,%d7
    movew #255,%d0
    movec %vbr,%a0
FLOAT_TEST_2A:          /* copy the 256 exception vectors to the stack (fp-1024), point vectors 7 and 48..54 at one local handler and 11, 13, 14 at another, and move VBR to the copy */
    moveal %a0,%a5	| 40848DE0
    lea %fp@(-1024),%a1
    moveal %a1,%a2
FLOAT_TEST_2A_8:
    movel %a0@+,%a1@+	| 40848DE8
    dbf %d0,FLOAT_TEST_2A_8
    lea %pc@(FLOAT_TEST_628+0x6),%a0
    movel %a0,%a2@(28)
    movel %a0,%a2@(192)
    movel %a0,%a2@(196)
    movel %a0,%a2@(200)
    movel %a0,%a2@(204)
    movel %a0,%a2@(208)
    movel %a0,%a2@(212)
    movel %a0,%a2@(216)
    lea %pc@(FLOAT_TEST_628_34+0x4),%a0
    movel %a0,%a2@(44)
FLOAT_TEST_64:          /* set %a2@(52) */
    movel %a0,%a2@(52)	| 40848E1A
    movel %a0,%a2@(56)	| 40848E1E
    movec %a2,%vbr	| 40848E22
    addqw #1,%d6	| 40848E26
    lea %pc@(FLOAT_TEST_7C),%a0	| 40848E28
    moveq #11,%d7	| 40848E2C
    fmovel %d0,%fp0	| 40848E2E
FLOAT_TEST_7C:          /* test %d5 */
    tstb %d5	| 40848E32
    jbne FLOAT_TEST_59C	| 40848E34
    moveq #0,%d5	| 40848E38
    moveq #0,%d7	| 40848E3A
    lea %fp@(-1300),%a4	| 40848E3C
    addqw #1,%d6	| 40848E40
    lea %pc@(FLOAT_TEST_744),%a0	| 40848E42
    fmovel %a0@,%fpcr	| 40848E46
    fmovel %fpcr,%a4@	| 40848E4A
    jbsr FLOAT_TEST_614	| 40848E4E
    jbne FLOAT_TEST_59C	| 40848E52
    tstb %d5	| 40848E56
    jbne FLOAT_TEST_59C	| 40848E58
    addqw #1,%d6	| 40848E5C
    .byte   0x41	| 40848E5E
FLOAT_TEST_A9:          /* (data) */
    .byte   0xFA	| 40848E5F
FLOAT_TEST_AA:          /* (data) */
    .long   0x06A0F210, 0x8400F214, 0xA4006100, 0x055E6600	| 40848E60
    .long   0x04E24A05, 0x660004DC, 0x524641FA, 0x068AF210	| 40848E70
    .long   0x8400F214, 0xA4006100, 0x05426600, 0x04C64A05	| 40848E80
    .long   0x660004C0, 0x524641FA, 0x0668F210, 0x4000F214	| 40848E90
    .long   0x60006100, 0x05266600, 0x04AA4A05, 0x660004A4	| 40848EA0
    .long   0x524641FA, 0x0652F210, 0x4000F214, 0x60006100	| 40848EB0
    .long   0x050A6600, 0x048E4A05, 0x66000488, 0x524641FA	| 40848EC0
    .byte   0x06, 0x3C, 0xF2, 0x10, 0x50, 0x80, 0xF2, 0x14, 0x70, 0x80, 0x61, 0x00, 0x04, 0xEE, 0x66	| 40848ED0
FLOAT_TEST_129:         /* (data) */
    .byte   0x00	| 40848EDF
    .long   0x04724A05, 0x6600046C, 0x524641FA, 0x0624F210	| 40848EE0
    .long   0x5900F214, 0x79006100, 0x04D26600, 0x04564A05	| 40848EF0
    .long   0x66000450, 0x524641FA, 0x060CF210, 0x4580F214	| 40848F00
    .long   0x65806100, 0x04B66600, 0x043A4A05, 0x66000434	| 40848F10
    .long   0x524641FA, 0x05F6F210, 0x5600F214, 0x76006100	| 40848F20
    .long   0x049A6600, 0x041E4A05, 0x66000418, 0x524641FA	| 40848F30
    .long   0x05E4F210, 0x4A80F214, 0x6A806100, 0x047E6600	| 40848F40
    .byte   0x04, 0x02, 0x4A, 0x05, 0x66, 0x00, 0x03, 0xFC, 0x52, 0x46, 0x41, 0xFA, 0x05, 0xE2, 0xF2	| 40848F50
FLOAT_TEST_1A9:         /* (data) */
    .byte   0x10	| 40848F5F
    .long   0x4F0041FA, 0x05E8F214, 0x6F036100, 0x045E6600	| 40848F60
    .long   0x03E24A05, 0x660003DC, 0x524674FB, 0x41FA05C0	| 40848F70
    .long   0xF2104F80, 0x41FA05D4, 0xF2147FA0, 0x6100043C	| 40848F80
    .long   0x660003C0, 0x4A056600, 0x03BA5246, 0xF2005C00	| 40848F90
    .long   0x41FA05C6, 0xF2146C79, 0x61000420, 0x660003A4	| 40848FA0
    .long   0x4A056600, 0x039E5246, 0x41FA05BC, 0x244849EE	| 40848FB0
    .long   0xFB04F21A, 0xD021F224, 0xE0846100, 0x03FE6600	| 40848FC0
    .long   0x03824A05, 0x6600037C, 0x524645EE, 0xFAEC42A2	| 40848FD0
    .long   0xF35AF222, 0xBC007002, 0x4A9A56C8, 0xFFFC6600	| 40848FE0
    .long   0x0362F222, 0xE0FF7007, 0x43FA04F2, 0x2049B588	| 40848FF0
    .long   0x6606B588, 0x6602B588, 0x56C8FFF2, 0x66000344	| 40849000
    .long   0x42A2F352, 0xF3224A12, 0x66000338, 0x4A056600	| 40849010
    .long   0x03325246, 0x45EEFAEC, 0xF23A4800, 0x042CF23A	| 40849020
    .long   0x48250432, 0xF32242A2, 0xF35AF35A, 0x41FA04A0	| 40849030
    .long   0x49EEFAEC, 0xF2146800, 0x61000380, 0x66000304	| 40849040
    .long   0x4A056600, 0x02FE5246, 0x45EEFAEC, 0x700B6100	| 40849050
    .long   0x035EF23A	| 40849060

FLOAT_TEST_2AE:         /* from here: extw %d0 */
    extw %d0
    bset %d1,%fp@-
    fsave %a2@-
    fmoveml %fpsr/%fpcr,%a2@-
    clrl %a2@-
    frestore %a2@+
    fnop
    tstb %d5
    jbne FLOAT_TEST_59C
    fmoveml %a2@+,%fpsr/%fpcr
    frestore %a2@+
    tstb %d5
    jbne FLOAT_TEST_59C
    moveq #51,%d7
    fnop
    cmpib #1,%d5
    jbne FLOAT_TEST_59C
    moveq #0,%d5
    moveq #0,%d7
    fmovel %d7,%fpcr
    addqw #1,%d6
    fmovex %pc@(FLOAT_TEST_6BA),%fp0
    faddx %pc@(FLOAT_TEST_6BA),%fp0
    moveq #14,%d0
    jbsr FLOAT_TEST_600
    jbeq FLOAT_TEST_59C
    tstb %d5
    jbne FLOAT_TEST_59C
    addqw #1,%d6
    moveq #15,%d0
    fmovex %pc@(FLOAT_TEST_6BA),%fp1
    fblt FLOAT_TEST_314
FLOAT_TEST_314:         /* call FLOAT_TEST_600 */
    jbsr FLOAT_TEST_600
    jbeq FLOAT_TEST_59C
    tstb %d5
    jbne FLOAT_TEST_59C
    addqw #1,%d6
    moveq #10,%d0
    jbsr FLOAT_TEST_608
    fmovex %pc@(FLOAT_TEST_6D2),%fp2
    fdivx %pc@(FLOAT_TEST_6C6),%fp2
    tstb %d5
    jbne FLOAT_TEST_59C
    moveq #50,%d7
    jbsr FLOAT_TEST_600
    jbeq FLOAT_TEST_59C
    cmpib #1,%d5
    jbne FLOAT_TEST_59C
    moveq #0,%d5
    moveq #0,%d7
    fmovel %d7,%fpcr
    addqw #1,%d6
    moveq #12,%d0
    jbsr FLOAT_TEST_608
    fmovex %pc@(FLOAT_TEST_6F6),%fp3
    fmulx %pc@(FLOAT_TEST_6F6),%fp3
    tstb %d5
    jbne FLOAT_TEST_59C
    moveq #53,%d7
    jbsr FLOAT_TEST_600
    jbeq FLOAT_TEST_59C
    cmpib #1,%d5
    jbne FLOAT_TEST_59C
    moveq #0,%d5
    addqw #1,%d6
    fmovex %pc@(FLOAT_TEST_6EA),%fp3
    tstb %d5
    jbne FLOAT_TEST_59C
    fmoves %fp3,%a4@
    cmpib #1,%d5
    jbne FLOAT_TEST_59C
    jbsr FLOAT_TEST_600
    jbeq FLOAT_TEST_59C
    moveq #0,%d5
    moveq #0,%d7
    fmovel %d7,%fpcr
FLOAT_TEST_3AE:         /* add 1 to %d6 */
    addqw #1,%d6
    moveq #11,%d0
    fmovex %pc@(FLOAT_TEST_702),%fp4
    fmulx %pc@(FLOAT_TEST_702),%fp4
    jbsr FLOAT_TEST_600
    jbeq FLOAT_TEST_59C
    tstb %d5
    jbne FLOAT_TEST_59C
    addqw #1,%d6
    moveq #9,%d0
    fmovex %pc@(FLOAT_TEST_70E),%fp5
    fmulx %pc@(FLOAT_TEST_71A),%fp5
    jbsr FLOAT_TEST_600
    jbeq FLOAT_TEST_59C
    tstb %d5
    jbne FLOAT_TEST_59C
    addqw #1,%d6
    moveq #13,%d0
    jbsr FLOAT_TEST_608
    fsqrtx %pc@(FLOAT_TEST_6DE),%fp6
    tstb %d5
    jbne FLOAT_TEST_59C
    moveq #52,%d7
    jbsr FLOAT_TEST_600
    jbeq FLOAT_TEST_59C
    cmpib #1,%d5
    jbne FLOAT_TEST_59C
    moveq #0,%d5
    moveq #0,%d7
    fmovel %d7,%fpcr
    addqw #1,%d6
    /* test: FTRAPEQ must not trap on constant 12 (e) and must trap on constant 15 (zero); d5 counts the traps */
    fmovecrx #12,%fp0	| 408491D0
    ftrapeq
    tstb %d5
    bnew FLOAT_TEST_59C
    moveq #7,%d7
    fmovecrx #15,%fp1
FLOAT_TEST_42E:         /* (data) */
    ftrapeq	| 408491E4
    cmpib #1,%d5
    bnew FLOAT_TEST_59C
    moveq #0,%d5
    moveq #0,%d7
    fmovel %d7,%fpcr
    addqw #1,%d6
    /* test: pi + pi against pi * 2 */
    fmovecrx #0,%fp0
    fmovex %fp0,%fp1
    faddx %fp1,%fp0
    fmulx #0x400040008000000000000000,%fp1
    fcmpx %fp0,%fp1
    .short  0xF28E, 0x0136	| 4084921A fbne 0x40849352
    tstb %d5
    bnew FLOAT_TEST_59C
    /* test: sin(x*pi/3) against cos(x*pi/6), compared as singles; x is the constant at FLOAT_TEST_6D2. The FSIN is the raw word before FLOAT_TEST_4AD */
    addqw #1,%d6
    fmovecrx #0,%fp0
    fmovex %fp0,%fp1
    fmovex %pc@(FLOAT_TEST_6D2),%fp2
    fmovex %fp2,%fp3
    fdivx #0x40004000c000000000000000,%fp2
    fdivx #0x40014001c000000000000000,%fp3
    fmulx %fp2,%fp0
    fmulx %fp3,%fp1
    .byte   0xF2, 0x00, 0x00	| 40849260
FLOAT_TEST_4AD:         /* (data) */
    .byte   0x0E	| 40849263
FLOAT_TEST_4AE:         /* (data) */
    fcosx %fp1,%fp1	| 40849264
    fmoves %fp0,%d0
    fmoves %fp1,%d1
    fmoves %d0,%fp0
    fmoves %d1,%fp1
    fcmpx %fp0,%fp1
    .short  0xF28E, 0x00D4	| 4084927C fbne 0x40849352
    /* sqrt(3)/2 against that cosine */
    fsqrtx #0x40004000c000000000000000,%fp4
    fdivx #0x400040008000000000000000,%fp4
    fmoves %fp4,%d2
    fmoves %d2,%fp4
    fcmpx %fp1,%fp4
    .short  0xF28E, 0x00A4	| 408492AC fbne 0x40849352
    /* test: tan(x*pi/4) against sin(x*pi/2), compared as singles */
    tstb %d5
    bnew FLOAT_TEST_59C
    addqw #1,%d6
    fmovex %pc@(FLOAT_TEST_6D2),%fp5
    fmovex %fp5,%fp0
    fmovecrx #0,%fp6
    fdivx #0x400140018000000000000000,%fp5
    fmulx %fp6,%fp5
    ftanx %fp5,%fp5
    .byte   0xF2, 0x3C, 0x48, 0x20, 0x40	| 408492DE
FLOAT_TEST_52D:         /* (data) */
    .byte   0x00, 0x40, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408492E3
    fmulx %fp6,%fp0	| 408492EE
    fsinx %fp0,%fp0
    fmoves %fp0,%d0
    fmoves %fp5,%d1
    fmoves %d0,%fp0
    fmoves %d1,%fp5
    fcmpx %fp0,%fp5
    .short  0xF28E, 0x0046	| 4084930A fbne 0x40849352
    tstb %d5
    bnes FLOAT_TEST_59C
    /* test: 10^log10(0.01) against 0.01, compared as singles */
    addqw #1,%d6
    fmovex #0x3ff83ff8a3d70a3d70a3d70a,%fp0
    fmovex %fp0,%fp1
    flog10x %fp1,%fp1
    ftentoxx %fp1,%fp1
    fmoves %fp0,%d0
    fmoves %fp1,%d1
    fmoves %d0,%fp0
    fmoves %d1,%fp1
    fcmpx %fp0,%fp1
    .short  0xF28E, 0x000C	| 40849344 fbne 0x40849352
    tstb %d5
    bnes FLOAT_TEST_59C
    movel %d6,%d0
    moveq #0,%d6
    jbra FLOAT_TEST_59E

FLOAT_TEST_59C:         /* loop: move */
    movel %d6,%d0
FLOAT_TEST_59E:         /* clear %d2 */
    moveq #0,%d2
    cmpib #2,%d0
    jbls FLOAT_TEST_5C2
    lea %fp@(-1300),%a2
    clrl %a2@-
FLOAT_TEST_5AC:         /* from here: frestore %a2@+ */
    frestore %a2@+
    fsave %a2@-
    movew #1,%d2
    moveb %a2@(1),%d1
    cmpib #24,%d1
    jbeq FLOAT_TEST_5C0
    addqw #1,%d2
FLOAT_TEST_5C0:         /* from here: swap %d2 */
    swap %d2
FLOAT_TEST_5C2:         /* from here: orl %d2,%d0 */
    orl %d2,%d0
    moveal %a5,%a0
    movec %a0,%vbr
    unlk %fp
    moveml %sp@+,%d2/%d7
    cmpib #2,%d6
    jbne FLOAT_TEST_5EC
    movew %d2,%d1
    lsrw #8,%d1
    lea %pc@(FLOAT_TEST_5F0),%a0
FLOAT_TEST_5DE:         /* loop: move */
    moveb %a0@+,%d3
    cmpib #0xfd,%d3
    jbeq FLOAT_TEST_5EC
    cmpb %d3,%d1
    jbne FLOAT_TEST_5DE
    moveq #-1,%d6
FLOAT_TEST_5EC:         /* set %sr */
    movew %sp@+,%sr
    jmp %fp@
FLOAT_TEST_5F0:         /* (data) */
    .short  0x0C0D, 0x0F17, 0x1A20, 0x2115, 0x222E, 0x2F33, 0x3418, 0xFD00	| 408493A6

FLOAT_TEST_600:         /* from here: fmovel %fpsr,%d1 */
    fmovel %fpsr,%d1
    btst %d0,%d1
    rts

FLOAT_TEST_608:         /* from here: fmovel %fpcr,%d1 */
    fmovel %fpcr,%d1
    bset %d0,%d1
    fmovel %d1,%fpcr
    rts

FLOAT_TEST_614:         /* save registers */
    moveml %d0/%a4,%sp@-
    movew %a0@(-2),%d0
    subqw #1,%d0
FLOAT_TEST_61E:         /* loop: cmpm */
    cmpmb %a0@+,%a4@+
    dbne %d0,FLOAT_TEST_61E
    jbeq FLOAT_TEST_628
    moveq #1,%d0
FLOAT_TEST_628:         /* restore registers, return */
    moveml %sp@+,%d0/%a4
    rts
    movel %d0,%sp@-
    fsave %sp@-
    moveb %sp@,%d0
    beqw FLOAT_TEST_628_1C
    moveq #0,%d0
    moveb %sp@(1),%d0
    bset #3,%sp@(0x0,%d0:w)
FLOAT_TEST_628_1C:
    frestore %sp@+
    moveq #1,%d5
    tstb %d7
    beqs FLOAT_TEST_628_32
    movew %sp@(10),%d0
    andiw #4095,%d0
    lsrw #2,%d0
    cmpb %d7,%d0
    beqs FLOAT_TEST_628_34
FLOAT_TEST_628_32:
    moveq #2,%d5
FLOAT_TEST_628_34:
    movel %sp@+,%d0
    rte
    moveq #1,%d5
    moveq #10,%d1
    movew %sp@(6),%d0
    lsrw #2,%d0
    cmpb %d0,%d7
    jbne FLOAT_TEST_680
    lsrw %d1,%d0
    tstb %d0
    jbne FLOAT_TEST_67A
    movel %a0,%sp@(2)
    jbra FLOAT_TEST_67E
FLOAT_TEST_67A:         /* set %sp@(8) */
    movel %a0,%sp@(8)
FLOAT_TEST_67E:         /* return from the exception */
    rte
FLOAT_TEST_680:         /* from here: lsrw %d1,%d0 */
    lsrw %d1,%d0
    tstb %d0
    jbne FLOAT_TEST_68A
    addql #8,%sp
    jbra FLOAT_TEST_68E
FLOAT_TEST_68A:         /* from here: addaw #20,%sp */
    addaw #20,%sp
FLOAT_TEST_68E:         /* from here: addiw #4096,%d6 */
    addiw #4096,%d6
    jbra FLOAT_TEST_59C
    .long   0x00000000	| 4084944C
    .long   0x7FFFFFFF, 0xFFFFFFFF, 0x7FFD0000, 0xE35FA931	| 40849450
    .long   0xA0000000, 0x90010000, 0xABCC7711, 0x8461CEFD	| 40849460
FLOAT_TEST_6BA:         /* (data) */
    .long   0x7FFF0000, 0x00A0A0A0, 0x00000000	| 40849470
FLOAT_TEST_6C6:         /* (data) */
    .long   0x00000000	| 4084947C
    .long   0x00000000, 0x00000000	| 40849480
FLOAT_TEST_6D2:         /* (data) */
    .long   0x3FFF3FFF, 0x80000000	| 40849488
    .long   0x00000000	| 40849490
FLOAT_TEST_6DE:         /* (data) */
    .long   0xBFFFBFFF, 0x80000000, 0x00000000	| 40849494
FLOAT_TEST_6EA:         /* (data) */
    .long   0x7FFE0000, 0x89ABCDEF, 0x01234567	| 408494A0
FLOAT_TEST_6F6:         /* (data) */
    .long   0x7FFE0000	| 408494AC
    .long   0x80001020, 0x00000000	| 408494B0
FLOAT_TEST_702:         /* (data) */
    .long   0x00020000, 0x80000001	| 408494B8
    .long   0x00000000	| 408494C0
FLOAT_TEST_70E:         /* (data) */
    .long   0x3FFF0000, 0xC0000000, 0x000173A1	| 408494C4
FLOAT_TEST_71A:         /* (data) */
    .long   0x3FFF0000, 0x80000000, 0x00000001, 0x000C9000	| 408494D0
    .long   0x0000A0AC, 0xF842FB63, 0x6FFC000C, 0x7FFF0000	| 408494E0
    .byte   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x04	| 408494F0
FLOAT_TEST_744:         /* (data) */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x04	| 408494FA
    .long   0x55555555, 0x0004AAAA, 0xAAAA0002, 0x55550001	| 40849500
    .long   0xAA000004, 0x4CEB79A3, 0x0008437B, 0x69B4BACD	| 40849510
    .long   0x05F1000C, 0x40550000, 0xCC3DFBE5, 0xC7633EF5	| 40849520
    .long   0x000C0000, 0x00000000, 0x00000000, 0x00000004	| 40849530
    .long   0x00012345, 0x67876500, 0x0000000C, 0x00040001	| 40849540
    .long   0x23000000, 0x00000000, 0x000C0004, 0x00012345	| 40849550
    .short  0x6787	| 40849560
    moveq #0,%d0
    orib #12,%d0
    orib #3,%d0
    moveb %a5@,%d2
    subw %a0@(0x0,%d0:w),%d1
    orib #24,%d0
    negxw %a5@
    .short  0x0000, 0xCC3D	| orib #61,%d0
    .long   0xFBE5C763	| 4084957C
    .short  0x3EF5, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40849580

/* TESTPGC: parity chip test. */
TESTPGC:
    btst #13,%d0
    jbeq TESTPGC_72
    btst #18,%d7
    jbeq TESTPGC_72
    moveal %a0@(8),%a2
    moveal %a0@(52),%a3
    movel %fp,%sp@-
    moveal %sp,%a5
    bset #27,%d7
    movel #1346847600,%d0
    moveq #31,%d5
    moveq #1,%d4
    lea %sp@(-4),%a4
    bclr #6,%a2@
    lea %pc@(TESTPGC_3E),%fp
    bclr #7,%a3@
    tstb %a2@
    movel %d4,%a4@
    tstl %a4@
    jbra TESTPGC_5E
TESTPGC_3E:             /* (data) */
    lea %pc@(TESTPGC_4C),%fp	| 408495CC
    bset #7,%a3@	| 408495D0
    tstb %a2@	| 408495D4
    tstl %a4@	| 408495D6
    jbra TESTPGC_5E
TESTPGC_4C:             /* (data) */
    .short  0x4DFA, 0x0010, 0x2884	| 408495DA
    .long   0x4A94E39C, 0x51CDFFD6	| 408495E0
    moveq #0,%d6
    jbra TESTPGC_6A
TESTPGC_5E:             /* set %d6 */
    moveq #16,%d6
    bset #6,%a2@
    bset #7,%a3@
    tstb %a2@
TESTPGC_6A:             /* clear %d0 */
    moveq #0,%d0
    bclr #27,%d7
    rts
TESTPGC_72:             /* set %d6 */
    moveq #-1,%d6
    jmp %fp@

/* FMCREGTEST: FMC register test. */
FMCREGTEST:
    btst #19,%d0
    beqw FMCREGTEST_6E_C
    moveal %fp,%a5
    moveal %a0@(76),%a0
    moveq #0,%d6
    lea %pc@(FMCREGTEST_18),%fp
    jmp %pc@(FMCREGTEST_6A)
FMCREGTEST_18:
    movew %d0,%d2
FMCREGTEST_1A:          /* loop: move */
    movew %d6,%d0
    lea %pc@(FMCREGTEST_24),%fp
    jmp %pc@(FMCREGTEST_5E)
FMCREGTEST_24:          /* set %d0 */
    movel %pc@(FMCREGTEST_2A),%d0
    jbra FMCREGTEST_2E
FMCREGTEST_2A:          /* (data) */
    .short  0xFFFF, 0xFFFF	| 4084962E
FMCREGTEST_2E:          /* address %pc@(FMCREGTEST_36) */
    lea %pc@(FMCREGTEST_36),%fp
    jmp %pc@(FMCREGTEST_6A)
FMCREGTEST_36:          /* (data) */
    cmpw %d0,%d6	| 4084963A
    jbne FMCREGTEST_4C	| 4084963C
    cmpiw #-1,%d6
    jbeq FMCREGTEST_48
    aslw #1,%d6
    oriw #1,%d6
    jbra FMCREGTEST_1A
FMCREGTEST_48:          /* clear %d6 */
    moveq #0,%d6
    jbra FMCREGTEST_50
FMCREGTEST_4C:          /* from here: swap %d6 */
    swap %d6	| 40849650
    movew %d0,%d6	| 40849652
FMCREGTEST_50:          /* set %d0 */
    movew %d2,%d0
    lea %pc@(FMCREGTEST_5A),%fp
    jmp %pc@(FMCREGTEST_5E)
FMCREGTEST_5A:          /* set %fp */
    moveal %a5,%fp
    jmp %fp@
FMCREGTEST_5E:          /* set %d1 */
    moveq #15,%d1
FMCREGTEST_60:          /* loop: move */
    moveb %d0,%a0@
    rorw #1,%d0
    dbf %d1,FMCREGTEST_60
    jmp %fp@
FMCREGTEST_6A:          /* clear %d0 */
    moveq #0,%d0
    moveq #15,%d1
FMCREGTEST_6E:          /* loop: move */
    moveb %a0@,%d0
    rorl #1,%d0
    dbf %d1,FMCREGTEST_6E
    swap %d0
    jmp %fp@
FMCREGTEST_6E_C:
    moveq #-1,%d6
    jmp %fp@

/* FMCCACHETEST: FMC cache test. */
FMCCACHETEST:
    btst #19,%d0
    beqw FMCCACHETEST_FE_6
    moveal #32768,%a2
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    lea %a2@(0x40000000,%za0),%a3	| 40849690
    moveal %a0@(72),%a4
    movec %cacr,%d4
    movel #6409,%d1
    movec %d1,%cacr
    movel #32768,%d5
FMCCACHETEST_2E:
    subql #4,%d5
    bmis FMCCACHETEST_3C
    tstl %a3@(0x8000,%d5:l)
    bras FMCCACHETEST_2E
FMCCACHETEST_3C:
    movel #32768,%d5
FMCCACHETEST_42:
    subql #4,%d5
    bmis FMCCACHETEST_52
    movel %a3@(0x0,%d5:l),%d3
    notl %d3
    movel %d3,%a2@(0x0,%d5:l)
    bras FMCCACHETEST_42
FMCCACHETEST_52:
    bclr #3,%a4@(516)
    movel #32768,%d5
FMCCACHETEST_5E:
    subql #4,%d5
    bmis FMCCACHETEST_68
    tstl %a2@(0x0,%d5:l)
    bras FMCCACHETEST_5E
FMCCACHETEST_68:
    andil #-4353,%d1
    movec %d1,%cacr
    bset #3,%a4@(516)
    movel #32768,%d5
FMCCACHETEST_7E:
    subql #4,%d5
    bmis FMCCACHETEST_90
    movel %a3@(0x0,%d5:l),%d3
    cmpl %a2@(0x0,%d5:l),%d3
    bnew FMCCACHETEST_C8
    bras FMCCACHETEST_7E
FMCCACHETEST_90:
    movel #32768,%d5
FMCCACHETEST_96:
    subql #4,%d5
    bmis FMCCACHETEST_A6
    movel %a3@(0x0,%d5:l),%d3
    notl %d3
    movel %d3,%a2@(0x0,%d5:l)
    bras FMCCACHETEST_96
FMCCACHETEST_A6:
    bclr #3,%a4@(516)
    movel #32768,%d5
FMCCACHETEST_B2:
    subql #4,%d5
    bmis FMCCACHETEST_C4
    movel %a3@(0x0,%d5:l),%d3
    notl %d3
    cmpl %a2@(0x0,%d5:l),%d3
    bnes FMCCACHETEST_D0
    bras FMCCACHETEST_B2
FMCCACHETEST_C4:
    moveq #0,%d6
    bras FMCCACHETEST_D6_4	| 40849748
FMCCACHETEST_C8:
    movel #268435456,%d6
    bras FMCCACHETEST_D6
FMCCACHETEST_D0:
    movel #536870912,%d6
FMCCACHETEST_D6:
    movew %d5,%d6
    nop
FMCCACHETEST_D6_4:
    bset #3,%a4@(516)	| 4084975C
    oril #6400,%d1
    movec %d1,%cacr
    movel #32768,%d5
FMCCACHETEST_F0:        /* loop: subq */
    subql #4,%d5
    jbmi FMCCACHETEST_FE
    tstl %a2@(0x0,%d5:l)
    clrl %a2@(0x0,%d5:l)
    jbra FMCCACHETEST_F0
FMCCACHETEST_FE:        /* set %cacr */
    movec %d4,%cacr
    jmp %fp@
FMCCACHETEST_FE_6:
    moveq #-1,%d6
    jmp %fp@

/* OSSREGTEST: OSS register test. */
OSSREGTEST:
    btst #18,%d0
    beqw OSSREGTEST_5E_48
    movew %sr,%d5
    oriw #1792,%sr
    moveal %a0@(72),%a0
    lea %pc@(OSSREGTEST_5E_4),%a1
    moveq #0,%d6
OSSREGTEST_18:
    moveq #0,%d0
    movel %a1@+,%d2
    beqs OSSREGTEST_52
    movew %d2,%d4
    swap %d2
    moveb %a0@(0x0,%d2:w),%d3
OSSREGTEST_26:
    moveb %d0,%a0@(0x0,%d2:w)
    movel %pc@(OSSREGTEST_26_A),%d1	| 408497B4
    bras OSSREGTEST_26_E
OSSREGTEST_26_A:
    .byte   0xFF, 0xFF, 0xFF, 0xFF	| 408497BA
OSSREGTEST_26_E:
    moveb %a0@(0x0,%d2:w),%d1	| 408497BE
    rorw #8,%d4
    andb %d4,%d1
    eorb %d0,%d1
    bnes OSSREGTEST_56
    rorw #8,%d4
    cmpb %d4,%d0
    beqs OSSREGTEST_4A
    addqw #1,%d0
    bras OSSREGTEST_26
OSSREGTEST_4A:
    moveb %d3,%a0@(0x0,%d2:w)
    addqw #1,%d6
    bras OSSREGTEST_18
OSSREGTEST_52:
    moveq #0,%d6
    jbra OSSREGTEST_5E
OSSREGTEST_56:
    movew %d3,%a0@(0x0,%d2:w)	| 408497E0
    swap %d6
    movew %d1,%d6
OSSREGTEST_5E:          /* set %sr */
    movew %d5,%sr
    jmp %fp@
OSSREGTEST_5E_4:
    .long   0x00000706 /* number, not an address (F4) */	| 408497EC
    .long   0x00010706 /* number, not an address (F4) */	| 408497F0
    .long   0x00020706 /* number, not an address (F4) */	| 408497F4
    .long   0x00030706 /* number, not an address (F4) */	| 408497F8
    .long   0x00040706 /* number, not an address (F4) */	| 408497FC
    .long   0x00050706 /* number, not an address (F4) */	| 40849800
    .long   0x00060706 /* number, not an address (F4) */	| 40849804
    .byte   0x00, 0x07, 0x07, 0x06, 0x00, 0x08, 0x07, 0x06, 0x00, 0x09, 0x07, 0x06, 0x00, 0x0A, 0x07, 0x06	| 40849808
    .byte   0x00, 0x0B, 0x07, 0x06, 0x00, 0x0C, 0x07, 0x06, 0x00, 0x0D, 0x07, 0x06, 0x02, 0x04, 0x1F, 0x1F	| 40849818
    .byte   0x02, 0x05, 0x03, 0x03, 0x00, 0x00, 0x00, 0x00	| 40849828
OSSREGTEST_5E_48:
    moveq #-1,%d6	| 40849830
    jmp %fp@

/* OSSINTTEST: OSS interrupt test. */
OSSINTTEST:
    btst #18,%d0
    beqw OSSINTTEST_6A
    movew %sr,%d5
    andiw #-1793,%sr
    moveal %a0@(72),%a0
    lea %pc@(OSSINTTEST_5E),%a3
    moveb %a0@(10),%d2
    moveb #6,%d6
    movec %vbr,%a1
    addaw #120,%a1
OSSINTTEST_26:
    moveal %a1@,%a2
    movel %a3,%a1@
    moveb %d6,%a0@(10)
    movew #-32768,%d1
    moveq #0,%d0
OSSINTTEST_34:
    cmpil #1684365929,%d0
    beqs OSSINTTEST_48
    dbf %d1,OSSINTTEST_34
    clrb %a0@(10)
    movel %a2,%a1@
    bras OSSINTTEST_56
OSSINTTEST_48:
    clrb %a0@(10)
    movel %a2,%a1@
    subqw #1,%d6
    subqw #4,%a1
    tstb %d6
    bnes OSSINTTEST_26
OSSINTTEST_56:
    moveb %d2,%a0@(10)
    movew %d5,%sr
    jmp %fp@
OSSINTTEST_5E:
    clrb %a0@(519)
    movel #1684365929,%d0
    rte
OSSINTTEST_6A:
    moveq #-1,%d6
    jmp %fp@

/* RPUTEST: RPU test. */
RPUTEST:
    btst #20,%d0
    jbeq RPUTEST_70
    btst #18,%d7
    jbeq RPUTEST_70
    moveal %a0@(80),%a3
    movel %fp,%sp@-
    moveal %sp,%a5
    bset #27,%d7
    movel #1380996464,%d0
    moveq #31,%d5
    moveq #1,%d4
    lea %sp@(-4),%a4
    st %a3@(16)
    movel %a3@,%d1
    bset #24,%d1
    movel %d1,%a3@
    lea %pc@(RPUTEST_3C),%fp
    movel %d4,%a4@
    tstl %a4@
    jbra RPUTEST_5E
RPUTEST_3C:             /* (data) */
    movel %a3@,%d1	| 408498DE
    bclr #24,%d1	| 408498E0
    movel %d1,%a3@	| 408498E4
    lea %pc@(RPUTEST_4C),%fp	| 408498E6
    tstl %a4@
    jbra RPUTEST_5E
RPUTEST_4C:             /* (data) */
    .short  0x4DFA	| 408498EE
    .long   0x00102884, 0x4A94E39C, 0x51CDFFCE	| 408498F0
    moveq #0,%d6
    jbra RPUTEST_68
RPUTEST_5E:             /* set %d6 */
    moveq #16,%d6
    movel %a3@,%d1
    bclr #24,%d1
    movel %d1,%a3@
RPUTEST_68:             /* clear %d0 */
    moveq #0,%d0
    bclr #27,%d7
    rts
RPUTEST_70:             /* set %d6 */
    moveq #-1,%d6
    jmp %fp@

/* EGRETTEST: Egret test. */
EGRETTEST:
    .short  0x2F0E, 0x2029, 0x001C, 0x0280, 0x0000	| 40849916
    .long   0x00700C80, 0x00000020, 0x66000146, 0x24680008	| 40849920
    .long   0x7C010812, 0x00036700, 0x013A5286, 0x002A000C	| 40849930
    .short  0x1600, 0x08EA, 0x0004, 0x1600, 0x08D2	| 40849940
    .short  0x0005, 0x157C	| orib #124,%d5
    .short  0x0001, 0x1400	| orib #0,%d1
    bset #4,%a2@
    movew #32767,%d0
EGRETTEST_44:           /* loop: btst */
    btst #2,%a2@(6656)
    dbne %d0,EGRETTEST_44
    tstb %a2@(5120)
    tstw %d0
    jbmi EGRETTEST_142
    addql #1,%d6
    bclr #4,%a2@
    lea %pc@(EGRETTEST_6C),%fp
    bigjmp TM_WAIT, a3
EGRETTEST_6C:           /* (data) */
    btst #3,%a2@	| 40849982
    jbeq EGRETTEST_142	| 40849986
    addql #1,%d6	| 4084998A
    moveq #15,%d2	| 4084998C
    lea %pc@(EGRETTEST_86),%fp	| 4084998E
EGRETTEST_7C:           /* address 0x70812 */
    lea 0x70812,%a3	| 40849992
    jmp %pc@(EGRETTEST_7C,%a3:l)	| 40849998
EGRETTEST_86:           /* (data) */
    .byte   0x08, 0xAA, 0x00, 0x04, 0x16, 0x00, 0x08, 0x92, 0x00, 0x05, 0x30, 0x3C, 0xFF, 0xFF	| 4084999C
EGRETTEST_94:           /* loop: btst */
    btst #2,%a2@(6656)
    jbeq EGRETTEST_A2
    btst #3,%a2@
    jbeq EGRETTEST_AA
EGRETTEST_A2:           /* count down */
    dbf %d0,EGRETTEST_94
    jbra EGRETTEST_142
EGRETTEST_AA:           /* set %d2 */
    moveb %a2@(5120),%d2
    lea %pc@(EGRETTEST_BC),%fp
    bigjmp TM_WAIT, a3
EGRETTEST_BC:           /* set bit 5 of %a2@ */
    bset #5,%a2@
    addql #1,%d6
    swap %d6
    movew #4,%d6
    linkw %fp,#-6
EGRETTEST_CC:           /* save registers */
    moveml %d6/%fp,%sp@-
    lea %pc@(EGRETTEST_DE),%fp
    bigjmp TM_GETBYTE, a3
EGRETTEST_DE:           /* (data) */
    moveml %sp@+,%d6/%fp	| 408499F4
    sne %d0	| 408499F8
    moveb %d2,%fp@(-6,%d6:w)	| 408499FA
    tstb %d0	| 408499FE
    jbne EGRETTEST_F4	| 40849A00
    dbf %d6,EGRETTEST_CC	| 40849A02
    swap %d6	| 40849A06
    jbra EGRETTEST_140	| 40849A08
EGRETTEST_F4:           /* test %d6 */
    tstw %d6
    jbeq EGRETTEST_FC
    swap %d6
    jbra EGRETTEST_140
EGRETTEST_FC:           /* from here: swap %d6 */
    swap %d6
    addql #1,%d6
    cmpib #15,%fp@(-4)
    bnew EGRETTEST_140
    addql #1,%d6
    tstb %fp@(-3)
    jbeq EGRETTEST_13E
    cmpib #3,%fp@(-3)
    jbne EGRETTEST_126
    moveq #14,%d0
    andl %a1@(28),%d0
    cmpiw #6,%d0
    jbne EGRETTEST_13E
EGRETTEST_126:          /* clear %d6 */
    moveq #0,%d6
    moveb %fp@(-3),%d6
    roll #8,%d6
    moveb %fp@(-5),%d6
    roll #8,%d6
    moveb %fp@(-6),%d6
    bset #31,%d6
    jbra EGRETTEST_140
EGRETTEST_13E:          /* clear %d6 */
    moveq #0,%d6
EGRETTEST_140:          /* return */
    unlk %fp
EGRETTEST_142:          /* clear bit 4 of %a2@ */
    bclr #4,%a2@
    bclr #5,%a2@
    lea %pc@(EGRETTEST_158),%fp
    bigjmp TM_WAIT, a3
EGRETTEST_158:          /* continue at EGRETTEST_15C */
    jbra EGRETTEST_15C
    .short  0x7CFF	| 40849A70
EGRETTEST_15C:          /* return */
    rts

/* TESTSNDINTS: sound interrupt test. */
TESTSNDINTS:
    btst #12,%d0
    beqw TESTSNDINTS_390_10
    moveml %d0-%d1/%d3-%d5/%d7-%a4,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #0,%d4
    subal %a3,%a3
    btst #11,%d0
    jbeq TESTSNDINTS_26
    moveal %a0@(44),%a3
    movel #436214784,%d7
TESTSNDINTS_26:         /* test bit 13 of %d0 */
    btst #13,%d0
    jbeq TESTSNDINTS_36
    moveal %a0@(52),%a3
    movel #196627,%d7
TESTSNDINTS_36:         /* set %d6 */
    moveq #-1,%d6
    cmpaw #0,%a3
    jbeq TESTSNDINTS_304
    moveq #0,%d6
    moveal %a3,%a5
    btst #2,%d0
    jbeq TESTSNDINTS_4E
    moveal %a0@(8),%a5
TESTSNDINTS_4E:         /* set %a4 */
    movec %vbr,%a4
    movel %a4@(104),%sp@-
    moveb %a3@(0x0,%d7:w),%sp@-
    orib #0x80,%sp@
    moveb #127,%a3@(0x0,%d7:w)
    swap %d7
    moveb #16,%a3@(0x0,%d7:w)
    lea %pc@(TESTSNDINTS_30C),%a1
    movel %a1,%a4@(104)
    moveal %a0@(48),%a4
    moveb %a4@(2048),%d3
    cmpib #0xb0,%d3
    jbeq TESTSNDINTS_98
    moveb %d3,%d6
    swap %d6
    andib #0xf0,%d3
    cmpib #0xb0,%d3
    jbne TESTSNDINTS_114
    movew #14,%d5
    jbra TESTSNDINTS_A0
TESTSNDINTS_98:         /* set %d6 */
    moveb %d3,%d6
    swap %d6
    movew #15,%d5
TESTSNDINTS_A0:         /* set %d6 */
    movew #-1,%d6
    bset #30,%d6
TESTSNDINTS_A8:         /* loop: tst */
    tstb %a5@
    cmpb %a4@(2052),%d5
    dbeq %d6,TESTSNDINTS_A8
    jbne TESTSNDINTS_2DA
    bclr #30,%d6
    clrw %d6
    moveb #1,%a4@(3849)
    moveb #1,%a4@(3881)
    clrb %a4@(3848)
    clrb %a4@(3880)
    moveb #63,%a4@(3844)
    moveb #0xdb,%a4@(3845)
    moveb #63,%a4@(3876)
    moveb #0xdb,%a4@(3877)
    bset #7,%a4@(3848)
    bset #7,%a4@(3880)
    clrb %a4@(2058)
    clrb %a4@(2059)
    bset #7,%a4@(2051)
    bclr #7,%a4@(2051)
    clrb %a4@(2050)
    moveb #1,%a4@(2049)
    jbra TESTSNDINTS_13E
TESTSNDINTS_114:        /* set %a4@(2049) */
    moveb #1,%a4@(2049)
    clrb %a4@(2058)
    moveb #0x80,%a4@(2051)
    clrb %a4@(2051)
    tstb %a4@(2052)
    moveb #2,%a4@(2050)
    clrb %a4@(2053)
    clrb %a4@(2054)
    clrb %a4@(2055)
TESTSNDINTS_13E:        /* from here: swap %d7 */
    swap %d7
    moveb #0x90,%a3@(0x0,%d7:w)
    moveb #111,%a3@(0x0,%d7:w)
    swap %d7
    moveb #16,%a3@(0x0,%d7:w)
    cmpib #0xe0,%d3
    jbne TESTSNDINTS_162
    bset #31,%d6
    jbra TESTSNDINTS_200
TESTSNDINTS_162:        /* address %a4@(1024) */
    lea %a4@(1024),%a2
TESTSNDINTS_166:        /* loop: move */
    moveb #8,%d6
    cmpib #0xb0,%d3
    jbne TESTSNDINTS_184
    clrb %a4@(3881)
    moveb #16,%a3@(0x0,%d7:w)
    movew #1000,%d5
TESTSNDINTS_17E:        /* loop: move */
    moveb %d0,%a2@
    dbf %d5,TESTSNDINTS_17E
TESTSNDINTS_184:        /* call caseD_21 */
    jbsr caseD_21
    jbpl TESTSNDINTS_192
    cmpib #0xb0,%d3
    jbne TESTSNDINTS_2DA
TESTSNDINTS_192:        /* from here: lsrb #1,%d6 */
    lsrb #1,%d6
    jbsr TESTSNDINTS_38C
    jbmi TESTSNDINTS_2DA
    cmpib #0xb0,%d3
    jbne TESTSNDINTS_200
    lslb #1,%d6
    movew #32767,%d1
TESTSNDINTS_1A8:        /* loop: tst */
    tstb %a5@
    moveb %a4@(2052),%d5
    andb %d6,%d5
    dbne %d1,TESTSNDINTS_1A8
    jbeq TESTSNDINTS_2DA
    moveb %a4@(2048),%d3
    cmpib #0xb0,%d3
    jbeq TESTSNDINTS_1EA
    cmpib #0xbb,%d3
    jbeq TESTSNDINTS_1D6
    andib #0xf0,%d3
    cmpib #0xb0,%d3
    jbeq TESTSNDINTS_276
    jbra TESTSNDINTS_1EA
TESTSNDINTS_1D6:        /* from here: andib #0xf0,%d3 */
    andib #0xf0,%d3
    movel %a2,%d5
    lea %a4@,%a2
    cmpl %a2,%d5
    jbeq TESTSNDINTS_276
    lea %a4@,%a2
    jbra TESTSNDINTS_166
TESTSNDINTS_1EA:        /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    moveb #1,%a4@(3881)
    clrb %a4@(3849)
    moveb #16,%a3@(0x0,%d7:w)
    moveq #0,%d4
TESTSNDINTS_200:        /* address %a4@ */
    lea %a4@,%a2
    moveb #2,%d6
    movew #1000,%d5
TESTSNDINTS_20A:        /* loop: move */
    moveb %d0,%a2@
    dbf %d5,TESTSNDINTS_20A
    jbsr caseD_21
    jbpl TESTSNDINTS_224
    btst #31,%d6
    jbne TESTSNDINTS_224
    cmpib #0xb0,%d3
    jbne TESTSNDINTS_2DA
TESTSNDINTS_224:        /* from here: lsrb #1,%d6 */
    lsrb #1,%d6
    jbsr TESTSNDINTS_38C
    jbmi TESTSNDINTS_2DA
    btst #31,%d6
    jbne TESTSNDINTS_23A
    cmpib #0xb0,%d3
    jbne TESTSNDINTS_254
TESTSNDINTS_23A:        /* from here: lslb #1,%d6 */
    lslb #1,%d6
    jbsr TESTSNDINTS_38C
    jbpl TESTSNDINTS_254
    cmpib #0xb0,%d3
    jbne TESTSNDINTS_2DA
    moveb %a4@(2052),%d5
    andb %d6,%d5
    jbeq TESTSNDINTS_2DA
TESTSNDINTS_254:        /* set bit 7 of %a4@(2051) */
    bset #7,%a4@(2051)
    bclr #7,%a4@(2051)
    cmpib #0xe0,%d3
    jbeq TESTSNDINTS_276
    cmpib #0xb0,%d3
    jbeq TESTSNDINTS_276
    movew %d2,%d1
    lsrw #8,%d1
    cmpib #12,%d1
    jbne TESTSNDINTS_2D8
TESTSNDINTS_276:        /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    clrw %d6
    moveb #1,%a4@(3881)
    swap %d7
    moveb #16,%a3@(0x0,%d7:w)
    swap %d7
    bset #7,%a4@(2051)
    bclr #7,%a4@(2051)
    moveb #16,%a3@(0x0,%d7:w)
    bset #15,%d6
    cmpib #0xb0,%d3
    jbne TESTSNDINTS_2B2
    moveb #1,%a4@(3849)
    clrb %a4@(3849)
TESTSNDINTS_2B2:        /* test %a4@(2052) */
    tstb %a4@(2052)
    swap %d7
    moveb #0x90,%a3@(0x0,%d7:w)
    swap %d7
    moveb #3,%a4@(2058)
    movew #32767,%d5
    movew #8448,%sr
TESTSNDINTS_2CE:        /* loop: tst */
    tstb %a5@
    tstw %d6
    dbeq %d5,TESTSNDINTS_2CE
    jbne TESTSNDINTS_2DA
TESTSNDINTS_2D8:        /* clear %d6 */
    moveq #0,%d6
TESTSNDINTS_2DA:        /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    swap %d7
    moveb #16,%a3@(0x0,%d7:w)
    swap %d7
    moveb #0x80,%a4@(2051)
    clrb %a4@(2051)
    clrb %a4@(2058)
    movec %vbr,%a0
    swap %d7
    moveb %sp@+,%a3@(0x0,%d7:w)
    movel %sp@+,%a0@(104)
TESTSNDINTS_304:        /* set %sr */
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d1/%d3-%d5/%d7-%a4
    jmp %fp@
TESTSNDINTS_30C:        /* set %d0 */
    moveb %a3@(0x0,%d7:w),%d0
    btst #4,%d0
    jbne TESTSNDINTS_31E
    moveb #0xff,%d6
    movew %sr,%sp@
    jbra TESTSNDINTS_366
TESTSNDINTS_31E:        /* set %d4 */
    moveb %a4@(2052),%d4
    btst #15,%d6
    jbne TESTSNDINTS_330
    andib #15,%d4
    movew %sr,%sp@
    jbra TESTSNDINTS_370
TESTSNDINTS_330:        /* test #0xb0,%a4@(2048) */
    cmpib #0xb0,%a4@(2048)
    jbeq TESTSNDINTS_340
    btst #0,%d4
    jbne TESTSNDINTS_346
    jbra TESTSNDINTS_35E
TESTSNDINTS_340:        /* test bit 0 of %d4 */
    btst #0,%d4
    jbne TESTSNDINTS_35E
TESTSNDINTS_346:        /* set %d1 */
    movew #32767,%d1
TESTSNDINTS_34A:        /* loop: tst */
    tstb %a5@
    btst #1,%a4@(2052)
    dbne %d1,TESTSNDINTS_34A
    jbne TESTSNDINTS_364
    moveb #2,%d6
    jbra TESTSNDINTS_366
TESTSNDINTS_35E:        /* set %d6 */
    moveb #1,%d6
    jbra TESTSNDINTS_366
TESTSNDINTS_364:        /* clear %d6 */
    clrw %d6
TESTSNDINTS_366:        /* from here: swap %d7 */
    swap %d7
    moveb #16,%a3@(0x0,%d7:w)
    swap %d7
TESTSNDINTS_370:        /* set %d7:w) */
    moveb #0x90,%a3@(0x0,%d7:w)
    rte

caseD_21:               /* set %d5 */
    movew #2000,%d5
TESTSNDINTS_37C:        /* loop: move */
    movew #8448,%sr
    moveb %d0,%a2@
    andb %d6,%d4
    dbne %d5,TESTSNDINTS_37C
    tstw %d5
    rts

TESTSNDINTS_38C:        /* set %d1 */
    movew #32767,%d1
TESTSNDINTS_390:        /* loop: move */
    movew #8448,%sr
    tstb %a5@
    andb %d6,%d4
    dbne %d1,TESTSNDINTS_390
    tstw %d1
    rts
TESTSNDINTS_390_10:
    moveq #-1,%d6
    jmp %fp@

/* TESTCLUT: color table test. */
TESTCLUT:
    movel %a1@(24),%d0
    btst #14,%d0
    beqw TESTCLUT_18A_2
    moveq #0,%d6
    movel %fp,%sp@-
    moveml %d1-%d3/%a0/%a2-%a4,%sp@-
    moveal %a0,%a4
    moveal %a0@(56),%a0
    moveb %a0@(8),%sp@-
    moveb #0xff,%a0@(8)	| 40849E36
    moveal %a0,%a2
    moveb %a1@(18),%d0
    cmpib #13,%d0
    bnes TESTCLUT_38
    lea %a2@(1),%a3	| 40849E48
    lea %a2@,%a0
    jbra TESTCLUT_98
TESTCLUT_38:
    moveq #0,%d4	| 40849E50
    movel %a1@(28),%d1
    btst #22,%d1
    jbeq TESTCLUT_92
    lea %a2@(1),%a3
    lea %a2@,%a0
    moveal %a4@(8),%a2
    addal #163840,%a2
    moveb %a2@,%d0
    cmpib #0x9f,%d0
    jbne TESTCLUT_98
    moveml %d1-%d5/%a0-%fp,%sp@-
    moveal %a4,%a0
    movel #917505,%d0
    movel #23154,%d1
    oril #1459617792,%d1
    moveq #4,%d2
    lea %pc@(TESTCLUT_84),%fp
    bigjmp SENDEGRETCMD, a1
TESTCLUT_84:            /* (data) */
    moveml %sp@+,%d1-%d5/%a0-%fp	| 40849E9C
    tstw %d0	| 40849EA0
    jbne TESTCLUT_160	| 40849EA2
    moveq #1,%d4
    jbra TESTCLUT_98
TESTCLUT_92:            /* address %a2@(4) */
    lea %a2@(4),%a3
    lea %a2@,%a0
TESTCLUT_98:            /* clear %a0@ */
    clrb %a0@
    jbsr TESTCLUT_170
    linkw %a2,#-768
    moveal %sp,%a2
    movew #255,%d0
TESTCLUT_A8:            /* loop: moveq */
    moveq #2,%d2
TESTCLUT_AA:            /* loop: move */
    moveb %a3@,%a2@+
    dbf %d2,TESTCLUT_AA
    dbf %d0,TESTCLUT_A8
    clrb %a0@
    movew #255,%d0
    moveb #0xff,%d1
TESTCLUT_BE:            /* loop: moveq */
    moveq #2,%d2
TESTCLUT_C0:            /* loop: addq */
    addqb #1,%d1
    moveb %d1,%a3@
    dbf %d2,TESTCLUT_C0
    dbf %d0,TESTCLUT_BE
    clrb %a0@
    jbsr TESTCLUT_170
    movew #255,%d0
    moveb #0xff,%d1
TESTCLUT_DA:            /* loop: moveq */
    moveq #2,%d2
TESTCLUT_DC:            /* loop: addq */
    addqb #1,%d1
    moveb %a3@,%d3
    cmpb %d3,%d1
    dbne %d2,TESTCLUT_DC
    dbne %d0,TESTCLUT_DA
    jbeq TESTCLUT_102
    negb %d0
    subqb #1,%d0
    negb %d2
    addqb #3,%d2
    moveb %d2,%d6
    lsll #8,%d6
    moveb %d0,%d6
    lsll #8,%d6
    moveb %d1,%d6
    lsll #8,%d6
    moveb %d3,%d6
TESTCLUT_102:           /* clear %a0@ */
    clrb %a0@
    movew #255,%d0
    moveal %sp,%a2
TESTCLUT_10A:           /* loop: moveq */
    moveq #2,%d2
TESTCLUT_10C:           /* loop: move */
    moveb %a2@+,%a3@
    dbf %d2,TESTCLUT_10C
    dbf %d0,TESTCLUT_10A
    unlk %a2
    movel %a1@(28),%d0
    btst #22,%d0
    jbeq TESTCLUT_166
    tstl %d4
    jbeq TESTCLUT_166
    moveal %a4@(8),%a2
    addal #163840,%a2
    moveml %d1-%d5/%a0-%fp,%sp@-
    moveal %a4,%a0
    movel #917505,%d0
    movel #65532,%d1
    oril #1459617792,%d1
    moveq #4,%d2
    lea %pc@(TESTCLUT_158),%fp
    bigjmp SENDEGRETCMD, a1
TESTCLUT_158:           /* (data) */
    moveml %sp@+,%d1-%d5/%a0-%fp	| 40849F70
    tstw %d0
    jbeq TESTCLUT_166
TESTCLUT_160:           /* test %d6 */
    tstl %d6
    jbne TESTCLUT_166
    movew %d0,%d6
TESTCLUT_166:           /* set %a0@(8) */
    moveb %sp@+,%a0@(8)
    moveml %sp@+,%d1-%d3/%a0/%a2-%a4
    rts

TESTCLUT_170:           /* set %d0 */
    moveb %a1@(18),%d0
    cmpib #13,%d0
    jbeq TESTCLUT_18A
    movel %a1@(28),%d0
    btst #22,%d0
    jbne TESTCLUT_18A
    tstb %a3@
    tstb %a3@
    tstb %a3@
TESTCLUT_18A:           /* return */
    rts
TESTCLUT_18A_2:
    moveq #-1,%d6
    jmp %fp@

/* SIZEVRAM: size the video RAM. */
SIZEVRAM:
    moveb %a1@(19),%d0
    cmpib #7,%d0
    jbne SIZEVRAM_3A
    moveal %a0@(52),%a2
    moveq #0,%d0
    btst #2,%a2@(1)
    beqw SIZEVRAM_36
    movel #262144,%d0
    btst #1,%a2@(1)
    jbne SIZEVRAM_2A
    addl %d0,%d0
SIZEVRAM_2A:            /* set %d1 */
    movel %a1@(8),%d1
    moveal %a1@(0x0,%d1:l),%a0
    lea %a0@(0x0,%d0:l),%a1
SIZEVRAM_36:            /* clear %d6 */
    moveq #0,%d6
    rts
SIZEVRAM_3A:            /* test #9,%d0 */
    cmpib #9,%d0
    jbne SIZEVRAM_56
    movel #32768,%d0
    movel %a1@(8),%d1
    moveal %a1@(0x0,%d1:l),%a0
    lea %a0@(0x0,%d0:l),%a1
    moveq #0,%d6
    rts
SIZEVRAM_56:            /* test #11,%d0 */
    cmpib #11,%d0
    bnel SIZEVRAM_11A
    moveal %a0@(8),%a3
    addal #155648,%a3
    movel %a1@(8),%d1
    moveal %a1@(0x0,%d1:l),%a0
    moveal %a1,%a2
    addal %a1@(8),%a2
    moveal %a2@(4),%a2
    moveb #6,%a3@(4)
    movel #262144,%d0
    movel #842348107,%a2@
    subql #4,%sp@
    addql #4,%sp@
    cmpil #842348107,%a2@(512)
    addal #524288,%a2
    jbeq SIZEVRAM_A6
    addl %d0,%d0
    jbra SIZEVRAM_E0
SIZEVRAM_A6:            /* set %a2@ */
    movel #892416575,%a2@
    subql #4,%sp@
    addql #4,%sp@
    cmpil #892416575,%a2@
    jbeq SIZEVRAM_BE
    clrb %a3@(4)
    jbra SIZEVRAM_112
SIZEVRAM_BE:            /* from here: addl %d0,%d0 */
    addl %d0,%d0
    cmpil #892416575,%a2@(512)
    jbeq SIZEVRAM_D8
    moveb #2,%a3@(4)
    addil #262144,%d0
    jbra SIZEVRAM_112
SIZEVRAM_D8:            /* set %a3@(4) */
    moveb #1,%a3@(4)
    jbra SIZEVRAM_112
SIZEVRAM_E0:            /* set %a2@ */
    movel #926300223,%a2@
    subql #4,%sp@
    addql #4,%sp@
    cmpil #926300223,%a2@
    jbeq SIZEVRAM_FA
    moveb #4,%a3@(4)
    jbra SIZEVRAM_112
SIZEVRAM_FA:            /* from here: addil #262144,%d0 */
    addil #262144,%d0
    cmpil #926300223,%a2@(512)
    jbeq SIZEVRAM_10C
    jbra SIZEVRAM_112
SIZEVRAM_10C:           /* set %a3@(4) */
    moveb #5,%a3@(4)
SIZEVRAM_112:           /* address %a0@(0x0 */
    lea %a0@(0x0,%d0:l),%a1
    moveq #0,%d6
    rts
SIZEVRAM_11A:           /* test #10,%d0 */
    cmpib #10,%d0
    bnew SIZEVRAM_142
    movel #65536,%d0
    movel %a1@(8),%d1
    moveal %a1@(0x0,%d1:l),%a0
    lea %a0@(0x0,%d0:l),%a1
    addql #1,%a4
    jbeq SIZEVRAM_13E
    addal %d0,%a0
    lea %a0@(0x0,%d0:l),%a1
SIZEVRAM_13E:           /* clear %d6 */
    moveq #0,%d6
    rts
SIZEVRAM_142:           /* test #8,%d0 */
    cmpib #8,%d0
    jbne SIZEVRAM_2B2
    moveal %a0@(104),%a2
    lea %pc@(SIZEVRAM_224),%a3
    moveq #0,%d1
    jbra SIZEVRAM_15C
SIZEVRAM_156:           /* loop: move */
    movew %a3@+,%d1
    movel %d1,%a2@(0x0,%d0:w)
SIZEVRAM_15C:           /* set %d0 */
    movew %a3@+,%d0
    jbpl SIZEVRAM_156
    moveal %a0@(44),%a3
    btst #5,%a3@
    jbeq SIZEVRAM_172
    oril #3840,%a2@(16)
SIZEVRAM_172:           /* address %a2@(768) */
    lea %a2@(768),%a3
    lea %pc@(SIZEVRAM_28E),%a4
    moveq #0,%d0
SIZEVRAM_17C:           /* loop: move */
    moveb %a4@+,%d0
    jbmi SIZEVRAM_188
    movel %d0,%a3@
    lea %a3@(16),%a3
    jbra SIZEVRAM_17C
SIZEVRAM_188:           /* set %a2@(32) */
    movel #3,%a2@(32)
    jbsr SIZEVRAM_2A0
    movel #7,%a2@(32)
    jbsr SIZEVRAM_2A0
    movel #3,%a2@(32)
    jbsr SIZEVRAM_2A0
    movel #2,%a2@(32)
    jbsr SIZEVRAM_2A0
    clrl %a2@(32)
    jbsr SIZEVRAM_2A0
    moveal #-117440512,%a3
    moveq #0,%d0
    movel #1399350636,%d1
    moveq #-1,%d2
    moveq #0,%d6
SIZEVRAM_1D2:           /* loop: lea */
    lea %a3@(0x0,%d0:l),%a4
    movel %d1,%a4@
    movel %d2,%a4@(4)
    movel %d1,%d3
    moveq #0,%d4
    moveq #3,%d5
SIZEVRAM_1E2:           /* loop: cmp */
    cmpb %a4@(0x0,%d5:w),%d3
    jbne SIZEVRAM_1F8
    notb %d3
    notb %a4@(0x0,%d5:w)
    movel %d2,%a4@(4)
    cmpb %a4@(0x0,%d5:w),%d3
    jbeq SIZEVRAM_1FA
SIZEVRAM_1F8:           /* from here: bset %d5,%d4 */
    bset %d5,%d4
SIZEVRAM_1FA:           /* from here: rorl #8,%d3 */
    rorl #8,%d3
    dbf %d5,SIZEVRAM_1E2
    cmpib #15,%d4
    jbeq SIZEVRAM_21C
    roll #4,%d6
    orb %d4,%d6
    movel %d2,%a3@(0x0,%d0:l)
    addil #524288,%d0
    cmpil #2097152,%d0
    jbne SIZEVRAM_1D2
SIZEVRAM_21C:           /* set %a0 */
    moveal %a3,%a0
    lea %a0@(0x0,%d0:l),%a1
    rts
SIZEVRAM_224:           /* (data) */
    .long   0x00200007	| 4084A1CC
    .long   0x00000008, 0x00040000, 0x00080064, 0x000C0602	| 4084A1D0
    .long   0x00100050, 0x01000FF2, 0x0168008E, 0x0124031E	| 4084A1E0
    .long   0x012801B0, 0x012C0020, 0x0130035F, 0x0134003F	| 4084A1F0
    .long   0x0138004B, 0x013C006F, 0x01400098, 0x01440318	| 4084A200
    .long   0x0148035E, 0x014C041A, 0x01500418, 0x01540004	| 4084A210
    .long   0x01580009, 0x015C0052, 0x01600412, 0x01640416	| 4084A220
    .short  0x0220	| 4084A230
SIZEVRAM_28A:           /* from here: oril #-61689,%a0@+ */
    oril #-61689,%a0@+
    .short  0x0000, 0x0501	| orib #1,%d0
    orib #2,%d0
    btst %d2,%d6
    subib #0,%d1
    .short  0xFF00	| 4084A246

SIZEVRAM_2A0:           /* from here: nop */
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rts
SIZEVRAM_2B2:           /* set %d6 */
    moveq #-1,%d6
    rts

/* TESTVRAM: video RAM test. */
TESTVRAM:
    movel %fp,%sp@-
    movel %a4,%sp@-
    cmpib #10,%a1@(19)
    bnes TESTVRAM_22
    moveaw #-1,%a4
    moveal %a0@(56),%a2
    moveb %a2@(4),%d0
    moveb %d0,%sp@-
    andib #0xdf,%d0	| 4084A278
    moveb %d0,%a2@(4)
TESTVRAM_22:
    cmpib #11,%a1@(19)
    bnes TESTVRAM_3A
    moveal %a0@(8),%a3
    addal #155648,%a3
    moveb %a3@(4),%d0
    moveb %d0,%sp@-
TESTVRAM_3A:
    moveml %a0-%a1,%sp@-
    bsrw SIZEVRAM
    moveml %sp@+,%a2-%a3
    cmpil #-1,%d6
    beql TESTVRAM_FA_4
    tstl %d0
    beql TESTVRAM_FA_4
    cmpib #8,%a3@(19)
    bnes TESTVRAM_9E
    moveal %a1,%a2
    moveal %a0,%a1
    moveq #0,%d2
TESTVRAM_68:            /* loop: movea */
    moveal %a1,%a0
    addal #524288,%a1
    rolw #4,%d2
    moveq #0,%d6
    moveml %d2/%a2,%sp@-
    lea %pc@(TESTVRAM_80),%fp
    jmp %pc@(caseD_2)
TESTVRAM_80:            /* (data) */
    moveml %sp@+,%d2/%a2	| 4084A2DE
    tstl %d6
    jbeq TESTVRAM_96
    moveq #3,%d3
TESTVRAM_8A:            /* loop: tst */
    tstb %d6
    jbeq TESTVRAM_90
    bset %d3,%d2
TESTVRAM_90:            /* from here: rorl #8,%d6 */
    rorl #8,%d6
    dbf %d3,TESTVRAM_8A
TESTVRAM_96:            /* test %a1,%a2 */
    cmpal %a1,%a2
    jbne TESTVRAM_68
    movel %d2,%d6
    jbra TESTVRAM_B8
TESTVRAM_9E:            /* save registers */
    moveml %a2-%a3,%sp@-
    moveq #0,%d6
    lea %pc@(TESTVRAM_AC),%fp
    jmp %pc@(caseD_2)
TESTVRAM_AC:            /* (data) */
    tstl %d6	| 4084A30A
    jbne TESTVRAM_B8	| 4084A30C
    lea %pc@(TESTVRAM_B8),%fp	| 4084A30E
    jmp %pc@(REVMOD3TEST)	| 4084A312
TESTVRAM_B8:            /* restore registers */
    moveml %sp@+,%a0-%a1
    cmpib #10,%a1@(19)
    jbne TESTVRAM_E2
    cmpaw #1,%a4
    jbeq TESTVRAM_D8
    moveml %a0-%a1,%sp@-
    jbsr SIZEVRAM
    moveml %sp@+,%a2-%a3
    jbra TESTVRAM_9E
TESTVRAM_D8:            /* set %a5 */
    moveal %a0@(56),%a5
    moveb %sp@+,%a5@(4)
    jbra TESTVRAM_FA
TESTVRAM_E2:            /* test #11,%a1@(19) */
    cmpib #11,%a1@(19)
    jbne TESTVRAM_FA
    moveal %a0@(8),%a3
    addal #155648,%a3
    moveb %sp@+,%d0
    moveb %d0,%a3@(4)
TESTVRAM_FA:            /* set %a4 */
    moveal %sp@+,%a4
    rts
TESTVRAM_FA_4:
    moveq #-1,%d6
    moveal %sp@+,%a4
    rts

/* TESTC96: 53C96 SCSI test. */
TESTC96:
    movel %fp,%sp@-
    btst #24,%d0
    bnes TESTC96_12
    btst #25,%d0
    bnes TESTC96_20
    moveq #-1,%d6
    rts
TESTC96_12:
    moveal %a0@(96),%a2
    jbsr TESTC96_2E
    jbne TESTC96_2C
    btst #25,%d0
    jbeq TESTC96_2C
TESTC96_20:
    moveal %a0@(100),%a2
    jbsr TESTC96_2E
    jbeq TESTC96_2C
    bset #31,%d6
TESTC96_2C:             /* return */
    rts

TESTC96_2E:             /* save registers */
    moveml %d0-%d3,%sp@-
    moveb #2,%a2@(48)
    moveq #0,%d6
    moveq #0,%d0
TESTC96_3C:             /* loop: move */
    moveb %d0,%a2@
    rorw #8,%d0
    moveb %d0,%a2@(16)
    rorw #8,%d0
    moveb #0x80,%a2@(48)
    moveb %a2@(16),%d1
    aslw #8,%d1
    moveb %a2@,%d1
    cmpw %d0,%d1
    jbne TESTC96_134
    addql #5,%d0
    cmpil #65535,%d0
    jble TESTC96_3C
    moveb #3,%d6
    swap %d6
    asll #8,%d6
    moveb %a2@(112),%d0
    andib #31,%d0
    jbne TESTC96_18A
    movew #15,%d0
TESTC96_7C:             /* loop: move */
    moveb %d0,%a2@(32)
    dbf %d0,TESTC96_7C
    moveb #4,%d6
    moveb %a2@(112),%d0
    andib #31,%d0
    cmpib #16,%d0
    jbne TESTC96_14E
    movew #15,%d0
    moveb #5,%d6
TESTC96_A0:             /* loop: move */
    moveb %a2@(32),%d1
    cmpb %d0,%d1
    dbne %d0,TESTC96_A0
    jbne TESTC96_15A
    moveb #6,%d6
    moveb %a2@(112),%d0
    andib #31,%d0
    jbne TESTC96_16A
    movew #15,%d2
    moveq #1,%d0
TESTC96_C4:             /* loop: move */
    moveb %d0,%a2@(32)
    rolb #1,%d0
    dbf %d2,TESTC96_C4
    movew #15,%d2
    moveq #1,%d0
    moveb #7,%d6
TESTC96_D8:             /* loop: move */
    moveb %a2@(32),%d1
    cmpb %d0,%d1
    jbne TESTC96_15A
    rolb #1,%d0
    dbf %d2,TESTC96_D8
    movew #768,%d2
    moveq #0,%d0
TESTC96_EC:             /* loop: move */
    moveb %d0,%a2@(128)
    addql #1,%d0
    moveb %d0,%a2@(176)
    addql #1,%d0
    moveb %d0,%a2@(192)
    subql #2,%d0
    moveb %a2@(128),%d1
    cmpb %d0,%d1
    jbne TESTC96_172
    addql #1,%d0
    moveb %a2@(176),%d1
    moveb %d0,%d3
    andib #0xdf,%d0
    cmpb %d0,%d1
    jbne TESTC96_178
    moveb %d3,%d0
    addql #1,%d0
    moveb %a2@(192),%d1
    moveb %d0,%d3
    andib #7,%d0
    cmpb %d0,%d1
    jbne TESTC96_17E
    moveb %d3,%d0
    addql #1,%d0
    dbf %d2,TESTC96_EC
    moveq #0,%d6
    jbra TESTC96_18A
TESTC96_134:            /* set %d6 */
    moveb #1,%d6
    cmpb %d0,%d1
    jbne TESTC96_144
    moveb #2,%d6
    rorw #8,%d0
    rorw #8,%d1
TESTC96_144:            /* from here: swap %d6 */
    swap %d6
    moveb %d0,%d6
    asll #8,%d6
    moveb %d1,%d6
    jbra TESTC96_18A
TESTC96_14E:            /* from here: swap %d6 */
    swap %d6
    moveb #16,%d6
    asll #8,%d6
    moveb %d0,%d6
    jbra TESTC96_18A
TESTC96_15A:            /* from here: asll #8,%d6 */
    asll #8,%d6
    moveb %a2@(112),%d6
    asll #8,%d6
    moveb %d0,%d6
    asll #8,%d6
    moveb %d1,%d6
    jbra TESTC96_18A
TESTC96_16A:            /* from here: swap %d6 */
    swap %d6
    asll #8,%d6
    moveb %d0,%d6
    jbra TESTC96_18A
TESTC96_172:            /* set %d6 */
    moveb #8,%d6
    jbra TESTC96_182
TESTC96_178:            /* set %d6 */
    moveb #9,%d6
    jbra TESTC96_182
TESTC96_17E:            /* set %d6 */
    moveb #10,%d6
TESTC96_182:            /* from here: swap %d6 */
    swap %d6
    moveb %d0,%d6
    asll #8,%d6
    moveb %d1,%d6
TESTC96_18A:            /* set %a2@(48) */
    moveb #2,%a2@(48)
    moveml %sp@+,%d0-%d3
    tstl %d6
    rts

/* TESTGSCREGS: GSC (gray scale controller) register test. */
TESTGSCREGS:
    .short  0x44FC	| 4084A4FA
    .short  0x0000, 0x7C00	| orib #0,%d0
    moveq #0,%d2
    moveal %a0@(56),%a2
    moveb %a2@(4),%d2
    lsll #8,%d2
    moveb %a2@(9),%d2
    lsll #8,%d2
    moveb %a2@(6),%d2
    movel %d2,%sp@-
    orib #0x80,%a2@(6)
    orib #15,%a2@(9)
    clrb %a2@(4)
    lea %pc@(TESTGSCREGS_D0),%a3
    lea %pc@(TESTGSCREGS_D8),%a4
TESTGSCREGS_36:         /* loop: moveq */
    moveq #0,%d1
    moveb %a3@+,%d1
    bmiw TESTGSCREGS_6C
    moveb %a4@+,%d2
    moveq #-1,%d3
    moveb %a2@(0x0,%d1:w),%sp@-
TESTGSCREGS_46:         /* loop: move */
    moveb %d3,%d4
    andb %d2,%d3
    moveb %d3,%a2@(0x0,%d1:w)
    moveq #0,%d5
    moveb %a2@(0x0,%d1:w),%d5
    andb %d2,%d5
    cmpb %d3,%d5
    bnew TESTGSCREGS_A8
    moveb %d4,%d3
    roxrb #1,%d3
    cmpib #0xff,%d3
    jbne TESTGSCREGS_46
    moveb %sp@+,%a2@(0x0,%d1:w)
    jbra TESTGSCREGS_36
TESTGSCREGS_6C:         /* address %pc@(TESTGSCREGS_D0) */
    lea %pc@(TESTGSCREGS_D0),%a3
    lea %pc@(TESTGSCREGS_D8),%a4
TESTGSCREGS_74:         /* loop: moveq */
    moveq #0,%d1
    moveb %a3@+,%d1
    bmiw TESTGSCREGS_B6
    moveb %a4@+,%d2
    roxrb #1,%d3
    clrb %d3
    moveb %a2@(0x0,%d1:w),%sp@-
TESTGSCREGS_86:         /* loop: move */
    moveb %d3,%d4
    andb %d2,%d3
    moveb %d3,%a2@(0x0,%d1:w)
    moveq #0,%d5
    moveb %a2@(0x0,%d1:w),%d5
    andb %d2,%d5
    cmpb %d3,%d5
    bnew TESTGSCREGS_A8
    moveb %d4,%d3
    roxrb #1,%d3
    jbne TESTGSCREGS_86
    moveb %sp@+,%a2@(0x0,%d1:w)
    jbra TESTGSCREGS_74
TESTGSCREGS_A8:         /* set %d1:w) */
    moveb %sp@+,%a2@(0x0,%d1:w)
    moveb %d1,%d6
    roll #8,%d6
    moveb %d3,%d6
    roll #8,%d6
    moveb %d5,%d6
TESTGSCREGS_B6:         /* set %d2 */
    movel %sp@+,%d2
    moveb %d2,%a2@(6)
    rorl #8,%d2
    moveb %d2,%a2@(9)
    rorl #8,%d2
    moveb #0x80,%a2@(4)
    moveb %d2,%a2@(4)
    jmp %fp@
TESTGSCREGS_D0:         /* (data) */
    .short  0x0205, 0x0607, 0x0809, 0x0AFF	| 4084A5CA
TESTGSCREGS_D8:         /* (data) */
    .short  0x07FF, 0xB8FF, 0x0F0F, 0xFF00	| 4084A5D2

/* PGESELFTEST: PG&E (power manager) self test. */
PGESELFTEST:
    movew %sr,%sp@-
    movel %fp,%sp@-
    oriw #1792,%sr
    moveq #0,%d6
    movew #236,%d3
    lea %pc@(PGESELFTEST_16),%fp
    jmp %pc@(USTPMGRSENDCOMMAND)
PGESELFTEST_16:
    bnes PGESELFTEST_2C
    moveq #65,%d5
PGESELFTEST_1A:
    lea %pc@(PGESELFTEST_22),%a5
    jmp %pc@(USTPMGRRECVBYTE)
PGESELFTEST_22:
    dbeq %d5,PGESELFTEST_1A
    bnes PGESELFTEST_2C
    moveb %d3,%d6
    swap %d6
PGESELFTEST_2C:
    moveal %sp@+,%fp
    movew %sp@+,%sr
    jmp %fp@

/* GOTM: go to the test manager. */
GOTM:
    tstw %d7
    jbne ERROR1HANDLER
    movel #-2023406815,%d6

/* ERROR1HANDLER: error handler: report a failed test (d6/d7 codes) and go to the test manager / sad Mac. */
ERROR1HANDLER:
    moveaw #9728,%sp
    moveq #0,%d2
    lea %pc@(ERROR1HANDLER_E),%fp
    jmp %pc@(hardware_table_lookup_40847568)
ERROR1HANDLER_E:        /* test bit 26 of %d7 */
    btst #26,%d7
    jbne ERROR1HANDLER_30
    moveal %a0@(48),%a3
    moveal %a0@(8),%a5
    lea %pc@(ERROR1HANDLER_2A),%fp
    bigjmp ERRORBEEP1
ERROR1HANDLER_2A:       /* continue at TMENTRY1 */
    jbra TMENTRY1
ERROR1HANDLER_30:       /* test bit 1 of %d0 */
    btst #1,%d0
    jbeq ERROR1HANDLER_54
    lea %pc@(ERROR1HANDLER_54),%fp
    bset #27,%d7
    moveal %a0@(4),%a1
    moveml %a1@+,%d0/%a0
    cmpil #-1431677611,%d0
    jbne ERROR1HANDLER_54
    lea %pc@(ERROR1HANDLER_54),%a1
    jmp %a0@
ERROR1HANDLER_54:       /* clear bit 27 of %d7 */
    bclr #27,%d7
    bset #16,%d7
    bset #22,%d7
    movew #12,%d4
    lea %pc@(ERROR1HANDLER_72),%fp
    bigjmp STARTTIMER
ERROR1HANDLER_72:       /* set %d0 */
    movec %cacr,%d0
    bset #15,%d0
    movec %d0,%cacr
    movec %cacr,%d0
    btst #15,%d0
    jbeq ERROR1HANDLER_8C
    cinva %ic
    jbra ERROR1HANDLER_A4
ERROR1HANDLER_8C:       /* set %d0 */
    movec %cacr,%d0
    bset #3,%d0
    movec %d0,%cacr
    movec %cacr,%d0
    orib #17,%d0
    movec %d0,%cacr
ERROR1HANDLER_A4:       /* continue at TMENTRY1 */
    jbra TMENTRY1

/* ERROR2HANDLER: error handler (other test class). */
ERROR2HANDLER:
    moveq #0,%d2
    lea %pc@(ERROR2HANDLER_A),%fp
    jmp %pc@(hardware_table_lookup_40847568)
ERROR2HANDLER_A:
    moveal %a0@(48),%a3
    moveal %a0@(8),%a2
    btst #26,%d7
    jbne ERROR2HANDLER_32
    moveal %a2,%a5
    lea %pc@(ERROR2HANDLER_28),%fp
    bigjmp ERRORBEEP1
ERROR2HANDLER_28:       /* from here: bigjmp CRITERR */
    bigjmp CRITERR
ERROR2HANDLER_32:       /* continue at TMENTRY1 */
    jbra TMENTRY1

/* ERROR3HANDLER: error handler. */
ERROR3HANDLER:
    moveq #0,%d2
    lea %pc@(ERROR3HANDLER_A),%fp
    jmp %pc@(hardware_table_lookup_40847568)
ERROR3HANDLER_A:
    moveal %a0@(48),%a3
    moveal %a0@(8),%a5
    lea %pc@(ERROR3HANDLER_20),%fp
ERROR3HANDLER_16:
    lea 0xffffb520:l,%a0	| 4084A70E
    jmp %pc@(ERROR3HANDLER_16,%a0:l)
ERROR3HANDLER_20:
    lea 0xfffb7bf8,%a0	| 4084A718
    jmp %pc@(ERROR3HANDLER_20,%a0:l)

/* ERROR4HANDLER: error handler. */
ERROR4HANDLER:
    moveq #0,%d2
    lea %pc@(ERROR4HANDLER_A),%fp
    jmp %pc@(hardware_table_lookup_40847568)
ERROR4HANDLER_A:
    moveal %a0@(48),%a3
    moveal %a0@(8),%a5
    lea %pc@(ERROR4HANDLER_20),%fp
ERROR4HANDLER_16:
    lea 0xffffb508:l,%a0	| 4084A738
    jmp %pc@(ERROR4HANDLER_16,%a0:l)
ERROR4HANDLER_20:
    lea 0xfffb7bce,%a0	| 4084A742
    jmp %pc@(ERROR4HANDLER_20,%a0:l)

/* NCERRORHANDLER: error handler without RAM. */
NCERRORHANDLER:
    cmpil #-1,%d6
    jbeq NCERRORHANDLER_A6
    moveal %a0@(8),%a2
    lea %pc@(NCERRORHANDLER_16),%fp
    jmp %pc@(CLKWPOFF)
NCERRORHANDLER_16:      /* set %d1 */
    movew #249,%d1
    lea %pc@(NCERRORHANDLER_22),%fp
    jmp %pc@(RDXBYTE)
NCERRORHANDLER_22:      /* set bit 0 of %d1 */
    bset #0,%d1
    jbne NCERRORHANDLER_52
    moveb %d1,%d2
    movew #249,%d1
    lea %pc@(NCERRORHANDLER_36),%fp
    jmp %pc@(WRXBYTE)
NCERRORHANDLER_36:      /* set %d4 */
    movel #15728647,%d4
NCERRORHANDLER_3C:      /* loop: swap */
    swap %d4
    movew %d4,%d1
    addqw #1,%d4
    moveq #0,%d2
    lea %pc@(NCERRORHANDLER_4C),%fp
    jmp %pc@(WRXBYTE)
NCERRORHANDLER_4C:      /* from here: swap %d4 */
    swap %d4
    dbf %d4,NCERRORHANDLER_3C
NCERRORHANDLER_52:      /* set %d4 */
    movel #16252934,%d4
NCERRORHANDLER_58:      /* loop: swap */
    swap %d4
    subqw #2,%d4
    movew %d4,%d1
    lea %pc@(NCERRORHANDLER_66),%fp
    jmp %pc@(RDXBYTE)
NCERRORHANDLER_66:      /* set %d2 */
    moveb %d1,%d2
    addqw #1,%d4
    movew %d4,%d1
    lea %pc@(NCERRORHANDLER_74),%fp
    jmp %pc@(WRXBYTE)
NCERRORHANDLER_74:      /* from here: swap %d4 */
    swap %d4
    dbf %d4,NCERRORHANDLER_58
    movew #240,%d1
    moveb %d7,%d2
    lea %pc@(NCERRORHANDLER_88),%fp
    jmp %pc@(WRXBYTE)
NCERRORHANDLER_88:      /* set %d4 */
    movel #16515075,%d4
NCERRORHANDLER_8E:      /* loop: swap */
    swap %d4
    movew %d4,%d1
    addql #1,%d4
    roll #8,%d6
    moveb %d6,%d2
    lea %pc@(NCERRORHANDLER_A0),%fp
    jmp %pc@(WRXBYTE)
NCERRORHANDLER_A0:      /* from here: swap %d4 */
    swap %d4
    dbf %d4,NCERRORHANDLER_8E
NCERRORHANDLER_A6:      /* return */
    rts
