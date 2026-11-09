/*
 os/osutil.s - OS utilities: parameter RAM, date and time, strings, SysEnvirons, BlockMove
 From SYSUTIL (0x4080C040). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
*/

/* ASYNCPATCH: an empty trap (rts). */
trap_SYSUTIL:
SYSUTIL:
ASYNCPATCH:
    rts

/* READPARAM: copy the parameter RAM bytes selected by the bits of d0 (from SPValid) to a0. */
trap_READPARAM:
READPARAM:
    lea SPValid,%a1
    jbsr READPARAM_A
    moveq #0,%d0
    rts

READPARAM_A:            /* (copy loop over the 20 bytes) */
    moveq #19,%d2
READPARAM_C:            /* next byte: wanted? */
    lsrl #1,%d0
    jbcc READPARAM_12
    moveb %a1@,%a0@+
READPARAM_12:           /* next */
    addql #1,%a1
    dbf %d2,READPARAM_C
    rts

/*
 _WriteParam: write the low memory copy of parameter RAM (SysParam) to the clock chip,
 read it back and compare. Result 0, or -87 (prWrErr).
*/
trap_WriteParam:
WRITEPARAM:
    jbsr READTIME_7C
    lea Scratch20,%a1
    jbsr READPRAM
    lea SPValid,%a0
    moveq #-87,%d0
    moveq #4,%d2
WRITEPARAM_14:          /* compare */
    cmpml %a0@+,%a1@+
    jbne WRITEPARAM_1E
    dbf %d2,WRITEPARAM_14
    moveq #0,%d0
WRITEPARAM_1E:          /* return */
    rts

/* _ReadDateTime: read the clock into Time and (a0). */
trap_ReadDateTime:
READDATETIME:
    jbsr READTIME
    movel Time,%a0@
    rts

/* _SetDateTime: set the clock to d0. */
trap_SetDateTime:
SETDATETIME:
    movel %d0,Time
    jbra READTIME_36

/* _Delay(a0 = ticks): wait, interrupts enabled. Out: d0 = Ticks at the end. */
trap_Delay:
DELAY:
    movew #8192,%sr
    movel Ticks,%d0
    addl %a0,%d0
DELAY_A:                /* wait */
    cmpl Ticks,%d0
    jbgt DELAY_A
    rts

/*
 LwrString / StripText... (_LwrString through the International Utilities, Pack6 2):
 lower case or strip diacriticals of the d0 bytes at a0 using the current script's
 tables ('itl2'). Result 0, or -192 without the tables.
*/
trap_LwrString:
LWRSTRING:
    movel %a2,%sp@-
    moveml %d0-%d1/%a0,%sp@-
    clrl %sp@-
    movew #2,%sp@-
    movew #6,%sp@-
    _Pack6
    moveal %sp@+,%a2
    moveml %sp@+,%d0-%d1/%a0
    movel %a2,%d2
    jbeq LWRSTRING_5A
    moveal %a2@,%a2
    btst #0,%a2@(9)
    jbeq LWRSTRING_5A
    moveal %a2,%a1
    moveq #0,%d2
    movew %a2@(14),%d2
    addal %d2,%a1
    lsrw #8,%d1
    andiw #6,%d1
    movew %pc@(LWRSTRING_60,%d1:w),%d1
    movew %a2@(0x0,%d1:w),%d2
    addal %d2,%a2
    moveq #0,%d1
    jbra LWRSTRING_50
LWRSTRING_44:           /* one byte through the two tables */
    moveb %a0@,%d1
    moveb %a1@(0x0,%d1:w),%d1
    moveb %a2@(0x0,%d1:w),%d1
    addb %d1,%a0@+
LWRSTRING_50:           /* (count) */
    dbf %d0,LWRSTRING_44
    moveq #0,%d0
LWRSTRING_56:           /* return */
    moveal %sp@+,%a2
    rts
LWRSTRING_5A:           /* no tables: -192 (resNotFound) */
    movew #-192,%d0
    jbra LWRSTRING_56
LWRSTRING_60:           /* table offsets for the four operations (by d1 bits) */
    .long   0x0012001A, 0x00100014	| 4080C100

/* _UprString(a0, d0 = length, d1 = flags): upper case (and/or strip diacriticals) in place. */
trap_UprString:
UPRSTRING:
    jbsr RELSTRING_58
    jbra UPRSTRING_C
UPRSTRING_6:            /* one byte */
    moveb %a0@,%d2
    jbsr RELSTRING_46
    moveb %d2,%a0@+
UPRSTRING_C:            /* (count) */
    dbf %d0,UPRSTRING_6
    moveq #0,%d0
    jbra RELSTRING_6E

/*
 _CmpString(a0, a1, d0 = lengths): 0 if the strings are equal (case and diacritical
 sensitivity from the trap bits), else 1.
*/
trap_CmpString:
CMPSTRING:
    movew %d0,%d2
    swap %d0
    cmpw %d0,%d2
    jbne CMPSTRING_12
    swap %d0
    jbsr trap_RelString
    jbpl CMPSTRING_10
    negl %d0
CMPSTRING_10:           /* return */
    rts
CMPSTRING_12:           /* different lengths: 1 */
    moveq #1,%d0
    rts

/* _RelString: compare the strings: -1, 0 or 1 (sort order from the table at RELSTRING_274). */
trap_RelString:
RELSTRING:
    jbsr RELSTRING_58
    moveq #0,%d4
    movew %d0,%d2
    swap %d0
    cmpw %d0,%d2
    jbeq RELSTRING_34
    jbhi RELSTRING_16
    moveq #1,%d4
    movew %d2,%d0
    cmpw %d4,%d4
    jbra RELSTRING_34
RELSTRING_16:           /* (second longer) */
    moveq #-1,%d4
    cmpw %d4,%d4
    jbra RELSTRING_34
RELSTRING_1C:           /* next pair of characters: their sort keys */
    moveq #0,%d2
    moveb %a0@+,%d2
    jbsr RELSTRING_46
    addw %d2,%d2
    movew %a3@(0x0,%d2:w),%d3
    moveq #0,%d2
    moveb %a1@+,%d2
    jbsr RELSTRING_46
    addw %d2,%d2
    cmpw %a3@(0x0,%d2:w),%d3
RELSTRING_34:           /* (until one differs) */
    dbne %d0,RELSTRING_1C
    jbeq RELSTRING_42
    jbhi RELSTRING_40
    moveq #-1,%d0
    jbra RELSTRING_44
RELSTRING_40:           /* greater */
    moveq #1,%d4
RELSTRING_42:           /* result from the lengths */
    movel %d4,%d0
RELSTRING_44:           /* return */
    jbra RELSTRING_6E

RELSTRING_46:           /* map character d2 (strip diacriticals, upper case) by the flags in d1 */
    tstw %d1
    jbpl RELSTRING_4E
    moveb %pc@(RELSTRING_74,%d2:w),%d2
RELSTRING_4E:           /* (upper case) */
    tstb %d1
    jbmi RELSTRING_56
    moveb %a2@(0x0,%d2:w),%d2
RELSTRING_56:           /* return */
    rts

RELSTRING_58:           /* common set-up: save the registers, the tables, flags from the trap word */
    movel %sp@+,%d2
    moveml %d2-%d4/%a2-%a3,%sp@-
    lea %pc@(RELSTRING_174),%a2
    lea %pc@(RELSTRING_274),%a3
    rolw #6,%d1
    rorb #1,%d1
    moveq #0,%d2
    rts

RELSTRING_6E:           /* restore and return */
    moveml %sp@+,%d3-%d4/%a2-%a3
    rts
RELSTRING_74:           /* table: strip diacriticals */
    .long   0x00010203, 0x04050607	| 4080C1A8
    .long   0x08090A0B, 0x0C0D0E0F, 0x10111213, 0x14151617	| 4080C1B0
    .long   0x18191A1B, 0x1C1D1E1F, 0x20212223, 0x24252627	| 4080C1C0
    .long   0x28292A2B, 0x2C2D2E2F, 0x30313233, 0x34353637	| 4080C1D0
    .long   0x38393A3B, 0x3C3D3E3F, 0x40414243, 0x44454647	| 4080C1E0
    .long   0x48494A4B, 0x4C4D4E4F, 0x50515253, 0x54555657	| 4080C1F0
    .long   0x58595A5B, 0x5C5D5E5F, 0x60616263, 0x64656667	| 4080C200
    .long   0x68696A6B, 0x6C6D6E6F, 0x70717273, 0x74757677	| 4080C210
    .byte   0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F	| 4080C220
    .ascii  "AACENOUaaaaaaceeeeiiiinooooouuuu"	| 4080C228
    .byte   0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7	| 4080C248
    .long   0xA8A9AAAB, 0xACADAE4F, 0xB0B1B2B3, 0xB4B5B6B7	| 4080C250
    .long   0xB8B9BA61, 0x6FBDBE6F, 0xC0C1C2C3, 0xC4C5C6C7	| 4080C260
    .long   0xC8C9CA41, 0x414FCECF, 0xD0D1D2D3, 0xD4D5D6D7	| 4080C270
    .long   0x79D9DADB, 0xDCDDDEDF, 0xE0E1E2E3, 0xE4E5E6E7	| 4080C280
    .long   0xE8E9EAEB, 0xECEDEEEF, 0xF0F1F2F3, 0xF4F5F6F7	| 4080C290
    .long   0xF8F9FAFB, 0xFCFDFEFF	| 4080C2A0
RELSTRING_174:          /* table: upper case */
    .long   0x00010203, 0x04050607	| 4080C2A8
    .long   0x08090A0B, 0x0C0D0E0F, 0x10111213, 0x14151617	| 4080C2B0
    .byte   0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F	| 4080C2C0
    .ascii  " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_aABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~"	| 4080C2C8
    .byte   0x7F, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87	| 4080C327
    .long   0xCB8980CC, 0x8182838F, 0x90919293, 0x94958497	| 4080C330
    .long   0x989985CD, 0x9C9D9E86, 0xA0A1A2A3, 0xA4A5A6A7	| 4080C340
    .long   0xA8A9AAAB, 0xACADAEAF, 0xB0B1B2B3, 0xB4B5B6B7	| 4080C350
    .long   0xB8B9BABB, 0xBCBDAEAF, 0xC0C1C2C3, 0xC4C5C6C7	| 4080C360
    .long   0xC8C9CACB, 0xCCCDCECE, 0xD0D1D2D3, 0xD4D5D6D7	| 4080C370
    .long   0xD8D9DADB, 0xDCDDDEDF, 0xE0E1E2E3, 0xE4E5E6E7	| 4080C380
    .long   0xE8E9EAEB, 0xECEDEEEF, 0xF0F1F2F3, 0xF4F5F6F7	| 4080C390
    .long   0xF8F9FAFB, 0xFCFDFEFF	| 4080C3A0
RELSTRING_274:          /* table: sort keys (one word per character) */
    .long   0x00000100, 0x02000300	| 4080C3A8
    .long   0x04000500, 0x06000700, 0x08000900, 0x0A000B00	| 4080C3B0
    .long   0x0C000D00, 0x0E000F00, 0x10001100, 0x12001300	| 4080C3C0
    .long   0x14001500, 0x16001700, 0x18001900, 0x1A001B00	| 4080C3D0
    .long   0x1C001D00, 0x1E001F00, 0x20002100, 0x22002300	| 4080C3E0
    .long   0x24002500, 0x26002700, 0x28002900, 0x2A002B00	| 4080C3F0
    .long   0x2C002D00, 0x2E002F00, 0x30003100, 0x32003300	| 4080C400
    .long   0x34003500, 0x36003700, 0x38003900, 0x3A003B00	| 4080C410
    .long   0x3C003D00, 0x3E003F00, 0x40004100, 0x42004300	| 4080C420
    .long   0x44004500, 0x46004700, 0x48004900, 0x4A004B00	| 4080C430
    .long   0x4C004D00, 0x4E004F00, 0x50005100, 0x52005300	| 4080C440
    .long   0x54005500, 0x56005700, 0x58005900, 0x5A005B00	| 4080C450
    .long   0x5C005D00, 0x5E005F00, 0x61004180, 0x42804380	| 4080C460
    .long   0x44804580, 0x46804780, 0x48804980, 0x4A804B80	| 4080C470
    .long   0x4C804D80, 0x4E804F80, 0x50805180, 0x52805380	| 4080C480
    .long   0x54805580, 0x56805780, 0x58805980, 0x5A807B00	| 4080C490
    .long   0x7C007D00, 0x7E007F00, 0x4108410C, 0x43104502	| 4080C4A0
    .long   0x4E0A4F08, 0x55084182, 0x41844186, 0x4188418A	| 4080C4B0
    .long   0x418C4390, 0x45824584, 0x45864588, 0x49824984	| 4080C4C0
    .long   0x49864988, 0x4E8A4F82, 0x4F844F86, 0x4F884F8A	| 4080C4D0
    .long   0x55825584, 0x55865588, 0xA000A100, 0xA200A300	| 4080C4E0
    .long   0xA400A500, 0xA6005382, 0xA800A900, 0xAA00AB00	| 4080C4F0
    .long   0xAC00AD00, 0x41144F0E, 0xB000B100, 0xB200B300	| 4080C500
    .long   0xB400B500, 0xB600B700, 0xB800B900, 0xBA004192	| 4080C510
    .long   0x4F92BD00, 0x41944F8E, 0xC000C100, 0xC200C300	| 4080C520
    .long   0xC400C500, 0xC6002206, 0x2208C900, 0x20004104	| 4080C530
    .long   0x410A4F0A, 0x4F144F94, 0xD000D100, 0x22022204	| 4080C540
    .long   0x27022704, 0xD600D700, 0x5988D900, 0xDA00DB00	| 4080C550
    .long   0xDC00DD00, 0xDE00DF00, 0xE000E100, 0xE200E300	| 4080C560
    .long   0xE400E500, 0xE600E700, 0xE800E900, 0xEA00EB00	| 4080C570
    .long   0xEC00ED00, 0xEE00EF00, 0xF000F100, 0xF200F300	| 4080C580
    .long   0xF400F500, 0xF600F700, 0xF800F900, 0xFA00FB00	| 4080C590
    .long   0xFC00FD00, 0xFE00FF00	| 4080C5A0

/* READPRAM: read the 20 bytes of parameter RAM (XPRAM 0x10..0x1F and 0x08..0x0B) to a1. */
READPRAM:
    movel %a0,%sp@-
    moveal %a1,%a0
    movel #1048592,%d0
    _ReadXPRam
    lea %a1@(16),%a0
    movel #262152,%d0
    _ReadXPRam
    moveal %sp@+,%a0
    rts
    .long   0x00000000, 0x00000000	| 4080C5C4

/*
 _InitUtil: read parameter RAM into low memory and the clock; if the validity byte is
 not 0xA8 (or the extended PRAM signature 'NuMc' is missing) write the defaults.
 Result 0, or -88 (prInitErr) when it had to be initialised.
*/
trap_InitUtil:
INITUTIL:
    clrw %sp@-
    jbsr READTIME_54
    lea SPValid,%a1
    jbsr READPRAM
    jbsr READTIME
    moveq #0,%d0
    cmpib #0xa8,%a1@
    jbeq INITUTIL_2C
    movew #-88,%sp@
    moveq #4,%d1
    lea %pc@(PRAMINIT),%a0
INITUTIL_22:            /* copy the defaults */
    movel %a0@+,%a1@+
    dbf %d1,INITUTIL_22
    jbsr READTIME_7C
INITUTIL_2C:            /* extended PRAM: signature */
    btst #6,HWCfgFlags
    jbeq INITUTIL_90
    lea Scratch20,%a0
    movel #262156,%d0
    _ReadXPRam
    movel #1316310371,%d1
    cmpl %a0@,%d1
    jbeq INITUTIL_90
    movew #-88,%sp@
    movel %d1,%a0@
    movel #262156,%d0
    _WriteXPRam
    moveq #32,%d1
INITUTIL_5A:            /* clear XPRAM 0x20.. */
    moveq #4,%d0
    swap %d0
    movew %d1,%d0
    clrl %a0@
    _WriteXPRam
    addqb #4,%d1
    cmpib #8,%d1
    jbne INITUTIL_5A
    moveml %a1,%sp@-
    lea %pc@(PRAMINITTBL),%a0
    lea Scratch20,%a1
    moveq #4,%d0
INITUTIL_7A:            /* write the defaults */
    movel %a0@+,%a1@+
    dbf %d0,INITUTIL_7A
    movel #1310838,%d0
    lea Scratch20,%a0
    _WriteXPRam
    moveml %sp@+,%a1
INITUTIL_90:            /* valid? HWCfgFlags bit 5 */
    movew %sp@+,%d0
    jbne INITUTIL_9A
    bset #5,HWCfgFlags
INITUTIL_9A:            /* return */
    extl %d0
    rts
    .short  0x0000, 0x0000, 0x0000	| 4080C66A
    .short  0x0000, 0x0000, 0x0000	| 4080C670
PRAMINIT:               /* default parameter RAM (the 20 bytes) */
    .short  0xA800, 0x0000, 0xCC0A, 0xCC0A, 0x0000	| 4080C676
    .short  0x0000, 0x0002, 0x6300	| 4080C680
PRAMINIT_10:            /* (inside the table) */
    .short  0x1388, 0x00CC	| 4080C686
PRAMINITTBL:            /* default extended parameter RAM */
    .short  0x0001, 0xFFFF, 0xFFDF	| 4080C68A
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4080C690

/*
 READTIME: read the clock through the machine's clock primitive (ProductInfo +52, +28)
 into Time. Result 0 or -85 (clkRdErr).
*/
READTIME:
    moveml %d1-%d2/%d4-%d5/%a0/%a2-%a3,%sp@-
    moveq #-85,%d0
    moveal 0xdd8,%a0
    addal %a0@(52),%a0
    movel %a0@(28),%d1
    jbeq READTIME_1E
    addal %d1,%a0
    jsr %a0@
    movel Scratch20,Time
READTIME_1E:            /* return */
    moveml %sp@+,%d1-%d2/%d4-%d5/%a0/%a2-%a3
    tstw %d0
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4080C6C4
    .long   0x00000000	| 4080C6D0

READTIME_36:            /* set the clock (primitive +32). Result 0 or -86 */
    moveml %d1-%d5/%a0,%sp@-
    moveq #-86,%d0
    moveal 0xdd8,%a0
    addal %a0@(52),%a0
    movel %a0@(32),%d1
    jbeq READTIME_4E
    addal %d1,%a0
    jsr %a0@
READTIME_4E:            /* return */
    moveml %sp@+,%d1-%d5/%a0
    rts

READTIME_54:            /* initialise the clock chip (primitive +0) */
    moveml %a2/%a5-%fp,%sp@-
    moveal 0xdd8,%a1
    moveal %a1,%a0
    addal %a0@(52),%a0
    movel %a0@,%d1
    jbeq READTIME_6E
    lea %pc@(READTIME_6E),%fp
    addal %d1,%a0
    jmp %a0@
READTIME_6E:            /* return */
    moveml %sp@+,%a2/%a5-%fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4080C712

READTIME_7C:            /* write the 20 bytes back */
    movel %a0,%sp@-
    lea SPValid,%a0
    movel #1048592,%d0
    _WriteXPRam
    lea SPVolCtl,%a0
    movel #262152,%d0
    _WriteXPRam
    moveal %sp@+,%a0
    rts
    .long   0x00000000, 0x00000000	| 4080C738
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4080C740

/*
 _SysEnvirons(d0 = version, a0 = record): machine type, system version, processor,
 FPU, Color QuickDraw, keyboard, AppleTalk and the System folder's working directory,
 from Gestalt. Result 0, -5501 (bad version) or -5502 (newer version than known).
*/
trap_SysEnvirons:
SYSENVIRONS:
    moveml %d2/%a0,%sp@-
    moveal %a0,%a2
    movew #-5501,%d2
    tstw %d0
    jble SYSENVIRONS_100
    clrw %d2
    movew %d0,%d1
    cmpiw #2,%d0
    jble SYSENVIRONS_24
    movew #-5502,%d2
    movew #16,%d0
    jbra SYSENVIRONS_28
SYSENVIRONS_24:         /* version 1 or 2 */
    movew #16,%d0
SYSENVIRONS_28:         /* clear the record */
    asrw #1,%d0
    subqw #1,%d0
SYSENVIRONS_2C:         /* clear loop */
    clrw %a0@+
    dbf %d0,SYSENVIRONS_2C
    movew %d1,%a2@
    movel #1835098984,%d0
    .short  0xA1AD	| 4080C78A _Gestalt (flags 0x0100)
    tstw %d0
    jbeq SYSENVIRONS_44
    subal %a0,%a0
    jbra SYSENVIRONS_46
SYSENVIRONS_44:         /* 'mach' */
    subqw #2,%a0
SYSENVIRONS_46:         /* machine type */
    movew %a0,%a2@(2)
    movel #1937339254,%d0
    .short  0xA1AD	| 4080C7A0 _Gestalt (flags 0x0100)
    tstw %d0
    jbeq SYSENVIRONS_58
    subal %a0,%a0
SYSENVIRONS_58:         /* 'sysv' */
    movew %a0,%a2@(4)
    movel #1886547811,%d0
    .short  0xA1AD	| 4080C7B2 _Gestalt (flags 0x0100)
    tstw %d0
    jbeq SYSENVIRONS_6A
    subal %a0,%a0
SYSENVIRONS_6A:         /* 'proc' */
    movew %a0,%a2@(6)
    movel #1718646048,%d0
    .short  0xA1AD	| 4080C7C4 _Gestalt (flags 0x0100)
    tstw %d0
    jbne SYSENVIRONS_84
    movel %a0,%d0
    jbeq SYSENVIRONS_84
    moveb #1,%a2@(8)
SYSENVIRONS_84:         /* 'fpu ' present */
    movel #1902387232,%d0
    .short  0xA1AD	| 4080C7DA _Gestalt (flags 0x0100)
    tstw %d0
    jbne SYSENVIRONS_9A
    movel %a0,%d0
    jbeq SYSENVIRONS_9A
    moveb #1,%a2@(9)
SYSENVIRONS_9A:         /* 'qd  ' color */
    movel #1801610272,%d0
    .short  0xA1AD	| 4080C7F0 _Gestalt (flags 0x0100)
    tstw %d0
    jbeq SYSENVIRONS_A8
    subal %a0,%a0
SYSENVIRONS_A8:         /* 'kbd ' */
    movew %a0,%a2@(10)
    movel #1635019883,%d0
    .short  0xA1AD	| 4080C802 _Gestalt (flags 0x0100)
    tstw %d0
    jbeq SYSENVIRONS_BA
    subal %a0,%a0
SYSENVIRONS_BA:         /* 'atlk' */
    movew %a0,%a2@(12)
    moveq #0,%d0
    movew #60,%d1
SYSENVIRONS_C4:         /* working directory of the System folder (OpenWD) */
    clrw %sp@-
    dbf %d1,SYSENVIRONS_C4
    moveal %sp,%a0
    movew SysMap,%a0@(24)
    moveq #8,%d0
    .short  0xA260	| 4080C824 _FSDispatch (flags 0x0200)
    jbne SYSENVIRONS_FC
    movew %a0@(52),%a0@(22)
    .short  0xA207	| 4080C82E _GetVolInfo (flags 0x0200)
    jbne SYSENVIRONS_FC
    movel %a0@(90),%a0@(48)
    movel #1163020619,%a0@(28)
    moveq #1,%d0
    .short  0xA260	| 4080C842 _FSDispatch (flags 0x0200)
    jbne SYSENVIRONS_FC
    movew %a0@(22),%a2@(14)
SYSENVIRONS_FC:         /* free the parameter block */
    lea %sp@(122),%sp
SYSENVIRONS_100:        /* return */
    movew %d2,%d0
    moveml %sp@+,%d2/%a0
    rts
    .long   0x00000000, 0x00000000	| 4080C858

/*
 INITRELIABILITY: the "reliability" record: record in XPRAM 0xB8 the date the machine
 was first used (in units of 675 x 256 seconds) and start a Time Manager task that
 counts the hours of use (RELTIMETASK, every 5 minutes).
*/
INITRELIABILITY:
    subqw #4,%sp
    movel Time,%d1
    subil #-1612506496,%d1
    jbcs INITRELIABILITY_42
    moveal %sp,%a0
    movel #262328,%d0
    _ReadXPRam
    movel %sp@,%d0
    andil #2146959360,%d0
    jbne INITRELIABILITY_42
    lsrl #8,%d1
    divuw #675,%d1
    moveq #19,%d0
    lsll %d0,%d1
    andil #2146959360,%d1
    andil #-2146959361,%sp@
    orl %d1,%sp@
    movel #262328,%d0
    _WriteXPRam
INITRELIABILITY_42:     /* allocate the record, install the task */
    addqw #4,%sp
    moveq #24,%d0
    moveb %d0,%d1
    .short  0xA71E	| 4080C8A8 _NewPtr (flags 0x0700)
    jbne INITRELIABILITY_7C
    moveal ExpandMem,%a1
    movel %a0,%a1@(132)
    moveb %d1,%a0@(1)
    moveb #1,%a0@
    bclr #7,0xb20
    lea %a0@(2),%a0
    lea %pc@(RELTIMETASK),%a1
    movel %a1,%a0@(6)
    .short  0xA458	| 4080C8CE _InsTime (flags 0x0400)
    movel #300000,%d0
    clrl %a0@(14)
    _PrimeTime
INITRELIABILITY_7C:     /* return */
    rts
    .short  0x0000	| 4080C8DE
RELTIMETASK:            /* the task (raw bytes: count, write XPRAM 0xB8, prime again) */
    .ascii  "YO O <\000"
    .byte   0x04, 0x00, 0xB8, 0xA0, 0x51, 0x20, 0x17, 0x22, 0x00	| 4080C8E7
    andil #524287,%d0
    addql #1,%d0
    andil #524287,%d0
    andil #-524288,%d1
    orl %d0,%d1
    movel %d1,%a0@
    movel #262328,%d0
    _WriteXPRam
    addqw #4,%sp
    moveal %a1,%a0
    movel #300000,%d0
    _PrimeTime
    rts
    .short  0x0000	| 4080C91E

/*
 BLOCKMOVES: tails of BlockMove: copy the last bytes (entered at the right place
 through the table of jumps that follows, by count).
*/
BLOCKMOVES:
    movel %a0@+,%a1@+
BLOCKMOVES_2:           /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_4:           /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_6:           /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_8:           /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_A:           /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_C:           /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_E:           /* copy forwards: (tail entry) */
    movew %a0@+,%a1@+
    moveq #0,%d0
    rts
    jbra BLOCKMOVES_76
    jbra BLOCKMOVES_62
    jbra BLOCKMOVES_E
    jbra BLOCKMOVES_60
    jbra BLOCKMOVES_74
    jbra BLOCKMOVES_86
    jbra BLOCKMOVES_C
    jbra BLOCKMOVES_5E
    jbra BLOCKMOVES_72
    jbra BLOCKMOVES_84
    jbra BLOCKMOVES_A
    jbra BLOCKMOVES_5C
    jbra BLOCKMOVES_70
    jbra BLOCKMOVES_82
    jbra BLOCKMOVES_8
    jbra BLOCKMOVES_5A
    jbra BLOCKMOVES_6E
    jbra BLOCKMOVES_80
    jbra BLOCKMOVES_6
    jbra BLOCKMOVES_58
    jbra BLOCKMOVES_6C
    jbra BLOCKMOVES_7E
    jbra BLOCKMOVES_4
    jbra BLOCKMOVES_56
    jbra BLOCKMOVES_6A
    jbra BLOCKMOVES_7C
    jbra BLOCKMOVES_2
    jbra BLOCKMOVES_54
    jbra BLOCKMOVES_68
    jbra BLOCKMOVES_7A
    jbra BLOCKMOVES
    movel %a0@+,%a1@+
BLOCKMOVES_54:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_56:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_58:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_5A:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_5C:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_5E:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_60:          /* copy forwards: (tail entry) */
    movew %a0@+,%a1@+
BLOCKMOVES_62:          /* copy forwards: (tail entry) */
    moveb %a0@+,%a1@+
    moveq #0,%d0
    rts
BLOCKMOVES_68:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_6A:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_6C:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_6E:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_70:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_72:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_74:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_76:          /* copy forwards: (tail entry) */
    moveq #0,%d0
    rts
BLOCKMOVES_7A:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_7C:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_7E:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_80:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_82:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_84:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
BLOCKMOVES_86:          /* copy forwards: (tail entry) */
    movel %a0@+,%a1@+
    moveb %a0@+,%a1@+
    moveq #0,%d0
    rts
    .short  0x0000	| 4080C9AE
BLOCKMOVES_90:          /* BlockMove of more than 12 bytes: overlap? else longs */
    movel 0x6f4,%sp@-
    movel %a1,%d1
    moveq #-4,%d2
    orl %d1,%d2
    subl %a0,%d1
    andl Lo3Bytes,%d1
    cmpl %d0,%d1
    jbcs BMOVERLAP

/* BMMOVELONGS: forward copy by longs (32-byte unrolled loop), then the tail. */
BMMOVELONGS:
    jmp %pc@(BMMOVELONGS_C,%d2:w:2)
    jbra BMMOVELONGS_E
    moveb %a0@+,%a1@+
    moveb %a0@+,%a1@+
    moveb %a0@+,%a1@+
BMMOVELONGS_C:          /* align the destination */
    addl %d2,%d0
BMMOVELONGS_E:          /* 32 bytes per pass */
    moveq #32,%d2
    subl %d2,%d0
    jbge BMEXIT16_4

/* BMEXIT16: the tail of a forward copy. */
BMEXIT16:
    jmp %pc@(BLOCKMOVES_54,%d0:w:2)
BMEXIT16_4:             /* 8 longs */
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    subl %d2,%d0
    jbge BMEXIT16_4
    jmp %pc@(BLOCKMOVES_54,%d0:w:2)

/* BMOVERLAP: source and destination overlap: copy backwards. */
BMOVERLAP:
    cmpl Lo3Bytes,%d0
    jbhi BMOVERLAP_14
    cmpal %a0,%a1
BMOVERLAP_8:            /* overlapping: copy backwards from the end */
    addal %d0,%a0
    addal %d0,%a1
    jbne BMVERYSHORT_CA
    moveq #0,%d0
    rts
BMOVERLAP_14:           /* (24-bit addresses) */
    cmpal %a0,%a1
    jbcc BMOVERLAP_8
    jmp %pc@(BMMOVELONGS_C,%d2:w:2)

/*
 BLOCKMOVE (68020/68030): up to 12 bytes with bit field moves (BMVERYSHORT), more
 through BLOCKMOVES_90. The cache is flushed afterwards (0x6F4 pushed as return).
*/
BLOCKMOVE68020:
BLOCKMOVE:
    moveq #-12,%d1
    addl %d0,%d1
    jbgt BLOCKMOVES_90

/* BMVERYSHORT: 0 to 12 bytes: bit field extract/insert. */
BMVERYSHORT:
    tstl %d0
    jble BMVERYSHORT_1A
    lslw #3,%d0
    addql #4,%d1
    jble BMVERYSHORT_1E
    addql #8,%a0
    bfextu %a0@,0,%d0,%d2
    movel %a0@-,%d1
    movel %a0@-,%a1@+
BMVERYSHORT_14:         /* (last long) */
    movel %d1,%a1@+
BMVERYSHORT_16:         /* last bytes with bit field insert */
    bfins %d2,%a1@,0,%d0
BMVERYSHORT_1A:         /* 0 */
    moveq #0,%d0
    rts
BMVERYSHORT_1E:         /* 5 to 8 bytes */
    addql #4,%d1
    jble BMVERYSHORT_2A
    movel %a0@+,%d1
    bfextu %a0@,0,%d0,%d2
    jbra BMVERYSHORT_14
BMVERYSHORT_2A:         /* 1 to 4 bytes */
    bfextu %a0@,0,%d0,%d2
    jbra BMVERYSHORT_16
BMVERYSHORT_30:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_32:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_34:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_36:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_38:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_3A:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_3C:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_3E:         /* copy backwards: (tail entry) */
    movew %a0@-,%a1@-
    moveq #0,%d0
    rts
    jbra BMVERYSHORT_A6
    jbra BMVERYSHORT_92
    jbra BMVERYSHORT_3E
    jbra BMVERYSHORT_90
    jbra BMVERYSHORT_A4
    jbra BMVERYSHORT_B6
    jbra BMVERYSHORT_3C
    jbra BMVERYSHORT_8E
    jbra BMVERYSHORT_A2
    jbra BMVERYSHORT_B4
    jbra BMVERYSHORT_3A
    jbra BMVERYSHORT_8C
    jbra BMVERYSHORT_A0
    jbra BMVERYSHORT_B2
    jbra BMVERYSHORT_38
    jbra BMVERYSHORT_8A
    jbra BMVERYSHORT_9E
    jbra BMVERYSHORT_B0
    jbra BMVERYSHORT_36
    jbra BMVERYSHORT_88
    jbra BMVERYSHORT_9C
    jbra BMVERYSHORT_AE
    jbra BMVERYSHORT_34
    jbra BMVERYSHORT_86
    jbra BMVERYSHORT_9A
    jbra BMVERYSHORT_AC
    jbra BMVERYSHORT_32
    jbra BMVERYSHORT_84
    jbra BMVERYSHORT_98
    jbra BMVERYSHORT_AA
    jbra BMVERYSHORT_30
    movel %a0@-,%a1@-
BMVERYSHORT_84:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_86:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_88:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_8A:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_8C:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_8E:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_90:         /* copy backwards: (tail entry) */
    movew %a0@-,%a1@-
BMVERYSHORT_92:         /* copy backwards: (tail entry) */
    moveb %a0@-,%a1@-
    moveq #0,%d0
    rts
BMVERYSHORT_98:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_9A:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_9C:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_9E:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_A0:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_A2:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_A4:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_A6:         /* copy backwards: (tail entry) */
    moveq #0,%d0
    rts
BMVERYSHORT_AA:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_AC:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_AE:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_B0:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_B2:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_B4:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
BMVERYSHORT_B6:         /* copy backwards: (tail entry) */
    movel %a0@-,%a1@-
    moveb %a0@-,%a1@-
    moveq #0,%d0
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4080CAD4
BMVERYSHORT_CA:         /* backwards: align, then 32 bytes per pass */
    movel %a1,%d1
    moveq #3,%d2
    andl %d1,%d2
    jbeq BMVERYSHORT_E0
    negl %d2
    jmp %pc@(BMVERYSHORT_DE,%d2:w:2)
    moveb %a0@-,%a1@-
    moveb %a0@-,%a1@-
    moveb %a0@-,%a1@-
BMVERYSHORT_DE:         /* (aligned) */
    addl %d2,%d0
BMVERYSHORT_E0:         /* 32 bytes per pass */
    moveq #32,%d2
    subl %d2,%d0
    jbge BMVERYSHORT_EA
    jmp %pc@(BMVERYSHORT_84,%d0:w:2)
BMVERYSHORT_EA:         /* 8 longs */
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    subl %d2,%d0
    jbge BMVERYSHORT_EA
    jmp %pc@(BMVERYSHORT_84,%d0:w:2)
    .long   0x00000000, 0x00000000	| 4080CB18
