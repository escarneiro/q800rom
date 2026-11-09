/*
 os/gestalt.s - Gestalt
 From GESTALTTRAP (0x40816500). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the Gestalt chapter of Inside Macintosh),
 not taken from Apple. Gestalt globals (22 bytes, ExpandMem +92): +0 handle of the
 table, +4 entry count, +8 MemTop, +12 the RAM end (0x1EF4), +16 machine type. The
 table holds (selector, routine) pairs sorted by selector, starting with the sentinels
 0x7FFFFFFF and 0x12345678... (as INITGESTALT writes them).
*/

/*
 _Gestalt (trap word in d1): A1AD Gestalt(d0 = selector) -> a0 = answer,
 A3AD NewGestalt and A5AD ReplaceGestalt (d0 = selector, a0 = routine).
*/
trap_Gestalt:
GESTALTTRAP:
    cmpiw #-24147,%d1
    jbeq GESTALTTRAP_30
    movel %a0,%sp@-
    movel %sp,%sp@-
    movel %a0,%sp@-
    movel %d0,%sp@-
    cmpiw #-23635,%d1
    jbeq GESTALTTRAP_22
    cmpiw #-23123,%d1
    jbne GESTALTTRAP_3E
    movel #1,%sp@-
    jbra GESTALTTRAP_24
GESTALTTRAP_22:         /* NewGestalt */
    clrl %sp@-
GESTALTTRAP_24:         /* newGestalt(replace flag, selector, routine, &old) */
    jsr %pc@(newGestalt)
    addaw #16,%sp
    moveal %sp@+,%a0
    jbra GESTALTTRAP_46
GESTALTTRAP_30:         /* Gestalt: look the selector up and call its routine */
    moveml %d3-%d7/%a2-%a4,%sp@-
    jsr %pc@(GESTALTTRAP_48)
    moveml %sp@+,%d3-%d7/%a2-%a4
    jbra GESTALTTRAP_46
GESTALTTRAP_3E:         /* unknown trap word: -50 */
    addaw #16,%sp
    moveq #-50,%d0
    nop
GESTALTTRAP_46:         /* return */
    rts

GESTALTTRAP_48:         /* find the selector, call its routine (Pascal: selector, &answer) */
    movel %d0,%d3
    subql #4,%sp
    movel %sp,%sp@-
    movel %d0,%sp@-
    jsr %pc@(findLong)
    addql #8,%sp
    movel %sp@+,%d2
    tstw %d0
    jbeq GESTALTTRAP_80
    moveal ExpandMem,%a0
    moveal %a0@(92),%a1
    moveal %a1@,%a0
    moveal %a0@,%a1
    lsll #3,%d2
    moveal %a1@(0x4,%d2:l),%a1
    clrl %sp@-
    clrw %sp@-
    movel %d3,%sp@-
    pea %sp@(6)
    jsr %a1@
    movew %sp@+,%d0
    moveal %sp@+,%a0
    jbra GESTALTTRAP_86
GESTALTTRAP_80:         /* not found: -5551 (gestaltUndefSelectorErr) */
    movel #-5551,%d0
GESTALTTRAP_86:         /* return */
    rts

GESTALTTRAP_88:         /* the built-in selector routines ('sysv' first: SysVersion), each storing the answer through GESTALTTRAP_42C (partly raw words) */
    moveal %sp@(4),%a0
    moveq #0,%d0
    movew SysVersion,%d0
    jbra GESTALTTRAP_42C
    .short  0x206F, 0x0004	| 40816596
    moveal ROMBase,%a1
    moveq #0,%d0
    movew %a1@(8),%d0
    jbra GESTALTTRAP_42C
    btst #1,HWCfgFlags
    jbeq GESTALTTRAP_424
    moveq #0,%d0
    movew #272,%d0
    jbra GESTALTTRAP_42C
    moveal ExpandMem,%a1
    moveal %a1@(92),%a1
    moveq #0,%d0
    movew %a1@(16),%d0
    jbra GESTALTTRAP_42C
    moveq #0,%d0
    moveb CPUFlag,%d0
    addqw #1,%d0
    braw GESTALTTRAP_42C
    moveb KbdType,%d0
    lea %pc@(GESTALTTRAP_88_6E),%a0
    moveal %a0,%a1
GESTALTTRAP_88_5C:
    moveb %a0@+,%d1
    beqw GESTALTTRAP_424
    cmpb %d0,%d1
    bnes GESTALTTRAP_88_5C
    subal %a1,%a0
    movel %a0,%d0
    braw GESTALTTRAP_42C
GESTALTTRAP_88_6E:
    btst %d1,%a3@
    btst %d5,%d2
    btst %d0,%d6
    btst %d3,%d4
    btst %d2,%d0
    bral getFPUTypePatch
    beqs GESTALTTRAP_134_4
    moveal %sp,%a0
    fnop
    fsave %sp@-
    movew %sp@,%d0
    moveal %a0,%sp
    cmpiw #7960,%d0
    jbeq GESTALTTRAP_130
    cmpiw #16152,%d0
    jbeq GESTALTTRAP_130
    cmpiw #16184,%d0
    jbeq GESTALTTRAP_134
    cmpiw #7992,%d0
    jbeq GESTALTTRAP_134
    jbra GESTALTTRAP_424
GESTALTTRAP_130:        /* 'fpu ': 68881 */
    moveq #1,%d0
    jbra GESTALTTRAP_13A
GESTALTTRAP_134:        /* 'fpu ': 68882 */
    moveq #2,%d0
    jbra GESTALTTRAP_13A
GESTALTTRAP_134_4:
    clrb %d0	| 40816638
GESTALTTRAP_13A:        /* answer */
    jbra GESTALTTRAP_42C
    moveq #0,%d0
    moveb MMUType,%d0
    cmpib #1,%d0
    beqs GESTALTTRAP_13A_1C
    cmpib #3,%d0
    blts GESTALTTRAP_13A_1A
    subqw #1,%d0
    bras GESTALTTRAP_13A_1C
GESTALTTRAP_13A_1A:
    moveq #0,%d0
GESTALTTRAP_13A_1C:
    braw GESTALTTRAP_42C
    .short  0x60FF, 0x0006, 0xFDA4	| bral 40886400 <DSHOOKPATCH_7E0+0x2>
    bltw GESTALTTRAP_13A_56
    cmpib #3,MMUType
    blts GESTALTTRAP_13A_4C
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    lea %a0@(18),%a0
    .short  0xF010, 0x4200	| 40816678 pmove %tc,%a0@
    bfextu %a0@,8,4,%d1
    moveq #0,%d0
    bset %d1,%d0
    bras GESTALTTRAP_13A_52
GESTALTTRAP_13A_4C:
    movel #32768,%d0
GESTALTTRAP_13A_52:
    jbra GESTALTTRAP_42C
GESTALTTRAP_13A_56:
    braw GESTALTTRAP_424
    movel SysZone,%d0
    braw GESTALTTRAP_42C
    moveal ExpandMem,%a1
    moveal %a1@(92),%a1
    cmpil #1819435373,%sp@(8)
    jbne GESTALTTRAP_1B4
    movel %a1@(12),%d0
    jbra GESTALTTRAP_1B8
GESTALTTRAP_1B4:        /* 'ram ' (MemTop) / 'lram' (RAM end) */
    movel %a1@(8),%d0
GESTALTTRAP_1B8:        /* answer */
    jbra GESTALTTRAP_42C
    moveal ROMBase,%a0
    movel %a0@(64),%d0
    braw GESTALTTRAP_42C
    moveq #2,%d0
    braw GESTALTTRAP_42C
    moveq #0,%d0
    tstb PortBUse
    bmis GESTALTTRAP_1B8_34
    moveb SPConfig,%d1
    andib #15,%d1
    cmpib #1,%d1
    bnes GESTALTTRAP_1B8_34
    moveal ABusVars_dce,%a0
    moveb %a0@(7),%d0
GESTALTTRAP_1B8_34:
    braw GESTALTTRAP_42C
    moveq #0,%d0
    jbra GESTALTTRAP_42C
    bral getAddrModePatch
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x7200, 0x2078, 0x02B6	| 408166FC
    .short  0x2068, 0x005C, 0x0C68, 0x0009, 0x0010, 0x6604, 0x08C1, 0x0001	| 4081670C
    .short  0x203C, 0x6864, 0x7772, 0xA1AD, 0x2008, 0x0800, 0x0003, 0x6738	| 4081671C
    .short  0x08C1, 0x0000, 0x2008, 0x0800	| 4081672C
    .long   0x0001670E /* number, not a label difference (was trap_BMAIN1-.) */	| 40816734
    movel #1986617650,%d0
    .short  0xA1AD	| 4081673E _Gestalt (flags 0x0100)
    btst #6,%a0@
    bras GESTALTTRAP_1B8_34_72	| 40816744
    movel %a0,%d0
    btst #2,%d0
    beqs GESTALTTRAP_1B8_AC
    movel #1919055392,%d0
    .short  0xA1AD	| 40816754 _Gestalt (flags 0x0100)
    addaw #0,%a0
    btst #6,%a0@
GESTALTTRAP_1B8_34_72:
    bnes GESTALTTRAP_1B8_AC	| 4081675E
    bset #2,%d1
GESTALTTRAP_1B8_AC:
    movel %d1,%d0
    jbra GESTALTTRAP_42C
    subaw #14,%sp
    moveal %sp,%a0
    clrl %a0@(10)
    movew #-1,%a0@(4)
    _InsTime
    moveq #1,%d1
    moveb %a0@(4),%d0
    bmis GESTALTTRAP_1B8_D4
    addql #1,%d1
    addb %d0,%d0
    bmis GESTALTTRAP_1B8_D4
    addql #1,%d1
GESTALTTRAP_1B8_D4:
    _RmvTime
    lea %sp@(14),%sp
    movel %d1,%d0
    braw GESTALTTRAP_42C
    movel SCCRd,%d0
    braw GESTALTTRAP_42C
    movel SCCWr,%d0
    braw GESTALTTRAP_42C
    movel #1751414642,%d0
    .short  0xA1AD	| 408167AE _Gestalt (flags 0x0100)
    tstw %d0
    bnew GESTALTTRAP_424
    movel %a0,%d0
    btst #2,%d0
    beqw GESTALTTRAP_424
    movel ghost_VIA2,%d0
    braw GESTALTTRAP_42C
    movel VIA,%d0
    braw GESTALTTRAP_42C
    movel #1751414642,%d0
    .short  0xA1AD	| 408167D6 _Gestalt (flags 0x0100)
    tstw %d0
    bnew GESTALTTRAP_424
    movel %a0,%d0
    btst #1,%d0
    beqw GESTALTTRAP_424
    movel #1357914112,%d0
    braw GESTALTTRAP_42C
    moveq #0,%d0
    jbra GESTALTTRAP_42C
    .long   0x20780DD8, 0xD1E8000C	| 408167F8
    moveq #0,%d0
    moveq #0,%d1
    movel #255,%d2
GESTALTTRAP_30A:        /* 'slot'/'nubs'/'slt1': count the NuBus slots and find the first (NuBus slot info) */
    btst #2,%a0@(0x0,%d0:w)
    jbeq GESTALTTRAP_31A
    addqw #1,%d1
    tstb %d2
    jbpl GESTALTTRAP_31A
    movel %d0,%d2
GESTALTTRAP_31A:        /* next slot */
    addqw #1,%d0
    cmpil #16,%d0
    jbne GESTALTTRAP_30A
    movel %d2,%d0
    cmpil #1936487473,%sp@(8)
    jbeq GESTALTTRAP_42C
    movel %d1,%d0
    cmpil #1853186675,%sp@(8)
    jbeq GESTALTTRAP_42C
    cmpil #1936486260,%sp@(8)
    jbne GESTALTTRAP_424
    moveq #1,%d0
    tstl %d1
    jbeq GESTALTTRAP_42C
    bset #1,%d0
    jbra GESTALTTRAP_42C
    movel #1751414642,%d0
    .short  0xA1AD	| 40816862 _Gestalt (flags 0x0100)
    tstw %d0
    bnew GESTALTTRAP_424
    movel %a0,%d1
    moveq #0,%d0
    btst #15,%d1
    beqw GESTALTTRAP_42C
    bset #0,%d0
    moveal VIA,%a0
    btst #6,%a0@
    bnew GESTALTTRAP_42C
    bset #1,%d0
    braw GESTALTTRAP_42C
    orib #10,%d0
    moveq #0,%d0
    lea %pc@(GESTALTTRAP_3C0),%a0
    movel 0xdd0,%d1
GESTALTTRAP_39C:        /* 'hdwr': hardware attribute bits from the valid flags (table below) */
    moveb %a0@+,%d2
    bmiw GESTALTTRAP_3AC
    moveb %a0@+,%d3
    btst %d3,%d1
    jbeq GESTALTTRAP_39C
    bset %d2,%d0
    jbra GESTALTTRAP_39C
GESTALTTRAP_3AC:        /* (bit 15 from 0xDD4) */
    movel 0xdd4,%d1
    btst #0,%d1
    beqw GESTALTTRAP_42C
    bset #15,%d0
    braw GESTALTTRAP_42C
GESTALTTRAP_3C0:        /* (Gestalt bit, flag bit) pairs, -1 ends */
    .long   0x00020403, 0x0B050C06, 0x0D070708, 0x010B030C	| 408168C0
    .long   0x020D0E0E, 0x060F0810, 0x09110512, 0x0A13FFFF	| 408168D0
    movel %sp@(8),%d0
    cmpil #1986359923,%d0
    jbeq GESTALTTRAP_414
    cmpil #1952539244,%d0
    jbeq GESTALTTRAP_418
    cmpil #13,%d0
    jbeq GESTALTTRAP_40C
    cmpil #7,%d0
    jbne GESTALTTRAP_424
    movel #1667330668,%d0
    jbra GESTALTTRAP_432
GESTALTTRAP_40C:        /* numeric selector 13: answer 'bbmc' (selector 7: 'carl', just above) */
    movel #1650617699,%d0
    jbra GESTALTTRAP_432
GESTALTTRAP_414:        /* 'vers': 1 */
    moveq #1,%d0
    jbra GESTALTTRAP_42C
GESTALTTRAP_418:        /* 'tabl': the table handle */
    moveal ExpandMem,%a0
    moveal %a0@(92),%a1
    movel %a1@,%d0
    jbra GESTALTTRAP_42C
GESTALTTRAP_424:        /* no answer: -5550 (gestaltUnknownErr) */
    movew #-5550,%sp@(12)
    jbra GESTALTTRAP_436
GESTALTTRAP_42C:        /* store the answer */
    moveal %sp@(4),%a0
    movel %d0,%a0@
GESTALTTRAP_432:        /* result 0 */
    clrw %sp@(12)
GESTALTTRAP_436:        /* return, pop the parameters */
    moveal %sp@+,%a0
    addql #8,%sp
    jmp %a0@

/*
 INITGESTALT: create the Gestalt globals and table and install the built-in selectors
 (the list at INITGESTALT_6E: selector, routine offset). Result 0 or -108.
*/
INITGESTALT:
    moveq #22,%d0
    .short  0xA71E	| 4081693E _NewPtr (flags 0x0700)
    movel %a0,%d0
    jbeq INITGESTALT_18A
    moveal ExpandMem,%a1
    movel %a0,%a1@(92)
    moveal %a0,%a2
    moveq #8,%d0
    .short  0xA522	| 40816952 _NewHandle (flags 0x0500)
    movel %a0,%a2@
    jbeq INITGESTALT_18A
    moveal %a0@,%a1
    movel #2147483647,%a1@
    movel #305419896,%a1@(4)
    movel #1,%a2@(4)
    movel 0x1ef4,%a2@(12)
    movel MemTop,%a2@(8)
    jsr %pc@(INITGESTALT_190)
    movew %d0,%a2@(16)
    lea %pc@(INITGESTALT_6E),%a3
    moveal %a3,%a2
INITGESTALT_50:         /* next built-in selector */
    tstl %a3@
    jbeq INITGESTALT_186
    movel %a3@(4),%d0
    addl %a2,%d0
    movel %d0,%sp@-
    movel %a3@,%sp@-
    clrl %sp@-
    jsr %pc@(newGestalt)
    lea %sp@(12),%sp
    addql #8,%a3
    jbra INITGESTALT_50
INITGESTALT_6E:         /* built-in selectors: 'mach' 'sysv' 'proc' 'kbd ' 'atlk' 'fpu ' 'mmu ' 'ram ' 'lram' 'qd  ' 'rom ' 'vm  ' 'powr' 'sccr' 'sccw' 'romv' 'via1' 'via2' 'rbv ' 'vers' 'tabl' 'snd ' 'hdwr' 'slot' 'slt1' 'nubs' 'tmgr' 'addr' 'a/ux' 'pgsz' 'lmem' 'prty', 13, 7 */
    .ascii  "mach"	| 408169AA
    .byte   0xFF, 0xFF	| 408169AE
    .byte   0xFC, 0x12	| 408169B0
    .ascii  "sysv"	| 408169B2
    .long   GESTALTTRAP_88-INITGESTALT_6E	| 408169B6
    .ascii  "proc"	| 408169BA
    .byte   0xFF, 0xFF	| 408169BE
    .byte   0xFC, 0x24	| 408169C0
    .ascii  "kbd "	| 408169C2
    .byte   0xFF, 0xFF, 0xFC, 0x30	| 408169C6
    .ascii  "atlk"	| 408169CA
    .byte   0xFF, 0xFF	| 408169CE
    .byte   0xFD, 0x24	| 408169D0
    .ascii  "fpu "	| 408169D2
    .byte   0xFF, 0xFF, 0xFC, 0x56	| 408169D6
    .ascii  "mmu "	| 408169DA
    .byte   0xFF, 0xFF	| 408169DE
    .byte   0xFC, 0x94	| 408169E0
    .ascii  "ram "	| 408169E2
    .byte   0xFF, 0xFF, 0xFC, 0xF2	| 408169E6
    .ascii  "lram"	| 408169EA
    .byte   0xFF, 0xFF	| 408169EE
    .byte   0xFC, 0xF2	| 408169F0
    .ascii  "qd  "	| 408169F2
    .byte   0xFF, 0xFF, 0xFD, 0x1E	| 408169F6
    .ascii  "rom "	| 408169FA
    .byte   0xFF, 0xFF	| 408169FE
    .byte   0xFD, 0x12	| 40816A00
    .ascii  "vm  "	| 40816A02
    .byte   0xFF, 0xFF, 0xFE, 0x48	| 40816A06
    .ascii  "powr"	| 40816A0A
    .byte   0xFF, 0xFF	| 40816A0E
    .byte   0xFD, 0x46	| 40816A10
    .ascii  "sccr"	| 40816A12
    .byte   0xFF, 0xFF, 0xFD, 0xEE	| 40816A16
    .ascii  "sccw"	| 40816A1A
    .byte   0xFF, 0xFF	| 40816A1E
    .byte   0xFD, 0xF6	| 40816A20
    .ascii  "romv"	| 40816A22
    .byte   0xFF, 0xFF, 0xFB, 0xEC	| 40816A26
    .ascii  "via1"	| 40816A2A
    .byte   0xFF, 0xFF	| 40816A2E
    .byte   0xFE, 0x1E	| 40816A30
    .ascii  "via2"	| 40816A32
    .byte   0xFF, 0xFF, 0xFE, 0x26	| 40816A36
    .ascii  "rbv "	| 40816A3A
    .byte   0xFF, 0xFF	| 40816A3E
    .byte   0xFD, 0xFE	| 40816A40
    .ascii  "vers"	| 40816A42
    .byte   0xFF, 0xFF, 0xFF, 0x36	| 40816A46
    .ascii  "tabl"	| 40816A4A
    .byte   0xFF, 0xFF	| 40816A4E
    .byte   0xFF, 0x36	| 40816A50
    .ascii  "snd "	| 40816A52
    .byte   0xFF, 0xFF, 0xFD, 0x5C	| 40816A56
    .ascii  "hdwr"	| 40816A5A
    .byte   0xFF, 0xFF	| 40816A5E
    .byte   0xFE, 0xE8	| 40816A60
    .ascii  "slot"	| 40816A62
    .byte   0xFF, 0xFF, 0xFE, 0x4E	| 40816A66
    .ascii  "slt1"	| 40816A6A
    .byte   0xFF, 0xFF	| 40816A6E
    .byte   0xFE, 0x4E	| 40816A70
    .ascii  "nubs"	| 40816A72
    .byte   0xFF, 0xFF, 0xFE, 0x4E	| 40816A76
    .ascii  "tmgr"	| 40816A7A
    .byte   0xFF, 0xFF	| 40816A7E
    .byte   0xFD, 0xC0	| 40816A80
    .ascii  "addr"	| 40816A82
    .byte   0xFF, 0xFF, 0xFD, 0x4C	| 40816A86
    .ascii  "a/ux"	| 40816A8A
    .byte   0xFF, 0xFF	| 40816A8E
    .byte   0xFB, 0xFE	| 40816A90
    .ascii  "pgsz"	| 40816A92
    .byte   0xFF, 0xFF, 0xFC, 0xB0	| 40816A96
    .ascii  "lmem"	| 40816A9A
    .byte   0xFF, 0xFF	| 40816A9E
    .byte   0xFC, 0xEA	| 40816AA0
    .ascii  "prty"	| 40816AA2
    .byte   0xFF, 0xFF, 0xFE, 0xB2, 0x00, 0x00, 0x00, 0x0D, 0xFF, 0xFF	| 40816AA6
    .short  0xFF36, 0x0000, 0x0007, 0xFFFF, 0xFF36, 0x0000, 0x0000	| 40816AB0
    .long   trap_Gestalt-INITGESTALT_6E	| 40816ABE
INITGESTALT_186:        /* 0 */
    clrw %d0
INITGESTALT_188:        /* return */
    rts
INITGESTALT_18A:        /* no memory: -108 */
    movew #-108,%d0
    jbra INITGESTALT_188

INITGESTALT_190:        /* the machine type for 'mach': from the ROM version and HWCfgFlags (old machines) or the machine kind + 6 */
    moveal ROMBase,%a0
    moveb %a0@(8),%d0
    jbgt INITGESTALT_1AA
    movew #3,%d0
    tstw HWCfgFlags
    jbpl INITGESTALT_1B2
    movew #4,%d0
    jbra INITGESTALT_1B2
INITGESTALT_1AA:        /* machine kind + 6 */
    moveq #0,%d0
    moveb 0xcb3,%d0
    addqb #6,%d0
INITGESTALT_1B2:        /* return */
    rts

/*
 newGestalt(replace, selector, routine, &old): add (or replace) a selector. The routine
 must be even and in the system heap or the ROM (else -5553). Errors -5551 (replace an
 unknown one), -5552 (add an existing one), -108.
*/
newGestalt:
    linkw %fp,#-4
    moveml %d4-%d7/%a3-%a4,%sp@-
    moveal %fp@(20),%a4
    movel %fp@(8),%d5
    movel %fp@(16),%d6
    btst #0,%d6
    jbeq newGestalt_20
    moveq #-50,%d0
    jbra newGestalt_106
newGestalt_20:          /* address check */
    moveal SysZone,%a0
    cmpl %a0@,%d6
    jbls newGestalt_36
    cmpl ROMBase,%d6
    jbcc newGestalt_36
    movew #-5553,%d0
    jbra newGestalt_106
newGestalt_36:          /* find the selector */
    moveq #1,%d4
    pea %fp@(-4)
    movel %fp@(12),%sp@-
    jsr %pc@(findLong)
    tstl %d0
    addql #8,%sp
    jbne newGestalt_88
    tstl %d5
    jbeq newGestalt_56
    movew #-5551,%d0
    jbra newGestalt_106
newGestalt_56:          /* new: grow the table */
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    movel %a0@(4),%d0
    addql #1,%d0
    asll #3,%d0
    movel %d0,%sp@-
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    movel %a0@,%sp@-
    jsr %pc@(SetHandleSize)
    tstw MemErr
    addql #8,%sp
    jbeq newGestalt_84
    moveq #-108,%d0
    jbra newGestalt_106
newGestalt_84:          /* (inserting) */
    moveq #0,%d4
    jbra newGestalt_92
newGestalt_88:          /* exists: allowed only for replace */
    tstl %d5
    jbne newGestalt_92
    movew #-5552,%d0
    jbra newGestalt_106
newGestalt_92:          /* insert or replace */
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    moveal %a0@,%a0
    moveal %a0@,%a3
    tstl %d4
    jbne newGestalt_EC
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    movel %a0@(4),%d7
    jbra newGestalt_CE
newGestalt_B0:          /* move the entries up */
    movel %d7,%d0
    asll #3,%d0
    movel %d7,%d1
    asll #3,%d1
    movel %a3@(0xfffffffffffffff8,%d0:l),%a3@(0x0,%d1:l)
    movel %d7,%d0
    asll #3,%d0
    movel %d7,%d1
    asll #3,%d1
    movel %a3@(0xfffffffffffffffc,%d0:l),%a3@(0x4,%d1:l)
    subql #1,%d7
newGestalt_CE:          /* (until the place) */
    cmpl %fp@(-4),%d7
    jbgt newGestalt_B0
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    addql #1,%a0@(4)
    movel %fp@(-4),%d0
    asll #3,%d0
    movel %fp@(12),%a3@(0x0,%d0:l)
newGestalt_EC:          /* return the old routine */
    tstl %d5
    jbeq newGestalt_FA
    movel %fp@(-4),%d0
    asll #3,%d0
    movel %a3@(0x4,%d0:l),%a4@
newGestalt_FA:          /* store the routine */
    movel %fp@(-4),%d0
    asll #3,%d0
    movel %d6,%a3@(0x4,%d0:l)
    moveq #0,%d0
newGestalt_106:         /* return */
    moveml %fp@(-28),%d4-%d7/%a3-%a4
    unlk %fp
    rts

/* removeLong(selector, &old): remove a selector from the table. */
removeLong:
    linkw %fp,#-4
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(12),%a4
    pea %fp@(-4)
    movel %fp@(8),%sp@-
    jsr %pc@(findLong)
    tstl %d0
    addql #8,%sp
    jbne removeLong_26
    movel #-5551,%d0
    jbra removeLong_A0
removeLong_26:          /* found: move the entries down */
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    moveal %a0@,%a0
    moveal %a0@,%a3
    movel %fp@(-4),%d0
    asll #3,%d0
    movel %a3@(0x4,%d0:l),%a4@
    movel %fp@(-4),%d7
    jbra removeLong_60
removeLong_42:          /* move */
    movel %d7,%d0
    asll #3,%d0
    movel %d7,%d1
    asll #3,%d1
    movel %a3@(0x8,%d0:l),%a3@(0x0,%d1:l)
    movel %d7,%d0
    asll #3,%d0
    movel %d7,%d1
    asll #3,%d1
    movel %a3@(0xc,%d0:l),%a3@(0x4,%d1:l)
    addql #1,%d7
removeLong_60:          /* (count) */
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    movel %a0@(4),%d0
    subql #1,%d0
    cmpl %d7,%d0
    jbgt removeLong_42
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    subql #1,%a0@(4)
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    movel %a0@(4),%d0
    asll #3,%d0
    movel %d0,%sp@-
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    movel %a0@,%sp@-
    jsr %pc@(SetHandleSize)
    moveq #0,%d0
    addql #8,%sp
removeLong_A0:          /* return */
    moveml %fp@(-16),%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000	| 40816CAA

/*
 findLong(selector, &index): binary search of the table. Result 1 if found (index of
 it), else 0 (index where it would go).
*/
findLong:
    moveml %d4-%d7/%a3-%a4,%sp@-
    moveal %sp@(32),%a4
    movel %sp@(28),%d4
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    moveal %a0@,%a0
    moveal %a0@,%a3
    moveq #0,%d6
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    movel %a0@(4),%d5
    subql #1,%d5
findLong_28:            /* middle entry */
    movel %d5,%d0
    subl %d6,%d0
    moveq #1,%d1
    cmpl %d0,%d1
    slt %d7
    andiw #1,%d7
    extl %d7
    addl %d6,%d7
    movel %d7,%d0
    asll #3,%d0
    cmpl %a3@(0x0,%d0:l),%d4
    jbcc findLong_48
    movel %d7,%d5
    jbra findLong_5E
findLong_48:            /* below? */
    movel %d7,%d0
    asll #3,%d0
    cmpl %a3@(0x0,%d0:l),%d4
    jbls findLong_58
    movel %d7,%d6
    addql #1,%d6
    jbra findLong_5E
findLong_58:            /* found */
    movel %d7,%a4@
    moveq #1,%d0
    jbra findLong_66
findLong_5E:            /* (range not empty?) */
    cmpl %d5,%d6
    jbne findLong_28
    movel %d6,%a4@
    moveq #0,%d0
findLong_66:            /* return */
    moveml %sp@+,%d4-%d7/%a3-%a4
    rts
    .long   0x00000000	| 40816D1C
