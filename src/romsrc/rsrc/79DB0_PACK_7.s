/* ROM resource 'PACK' 7: map entry at 0x40879DB0, data at 0x40879DE0, 1376 bytes

 The Binary-Decimal Conversion Package (PACK 7): NumToString and StringToNum (long
 integers to and from decimal strings), and the SANE decimal string scanner and formatter
 (Str2Dec, CStr2Dec, Dec2Str: strings to and from SANE decimal records). The routine
 selector on the stack picks the routine. Comments inferred; routines summarised
 mechanically.
*/

rsrc_PACK_7_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40879DB0
    .long   rsrc_CDEF_0_entry-rom_start	| 40879DB8
    .long   rsrc_PACK_7-rom_start	| 40879DBC
    .ascii  "PACK"	| 40879DC0
    .byte   0x00, 0x07, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40879DC4
    .long   0x00000000, 0xC0A00000, 0x0000056C, 0x000000E4	| 40879DD0

/* subroutine (42 instructions): calls rsrc_PACK_7_6E (mechanical summary) */
rsrc_PACK_7:
    jbra rsrc_PACK_7_C
    .short  0x0000, 0x5041, 0x434B, 0x0007, 0x0001	| 40879DE2

rsrc_PACK_7_C:          /* subtract 1 to %sp@(4) */
    subqw #1,%sp@(4)
    jbpl rsrc_PACK_7_74_14
    movel %sp@,%sp@(2)
    addqw #2,%sp
    moveml %d0-%d6/%a1,%sp@-
    moveq #0,%d1
    moveq #0,%d2
    moveq #0,%d3
    moveq #0,%d4
    moveq #0,%d5
    moveq #31,%d6
    lea %a0@(1),%a1
    tstl %d0
    jbgt rsrc_PACK_7_C_32
    jbmi rsrc_PACK_7_C_2C
    moveb #48,%a1@+
    jbra rsrc_PACK_7_C_54
rsrc_PACK_7_C_2C:       /* set %a1@+ */
    moveb #45,%a1@+
    negl %d0
rsrc_PACK_7_C_32:       /* loop: add */
    addl %d0,%d0
    abcd %d5,%d5
    abcd %d4,%d4
    abcd %d3,%d3
    abcd %d2,%d2
    abcd %d1,%d1
    dbf %d6,rsrc_PACK_7_C_32
    jbsr rsrc_PACK_7_6E
    moveb %d2,%d1
    jbsr rsrc_PACK_7_6E
    moveb %d3,%d1
    jbsr rsrc_PACK_7_6E
    moveb %d4,%d1
    jbsr rsrc_PACK_7_6E
    moveb %d5,%d1
    jbsr rsrc_PACK_7_6E
rsrc_PACK_7_C_54:       /* set %d0 */
    movew %a1,%d0
    subw %a0,%d0
    subqb #1,%d0
    moveb %d0,%a0@
    moveml %sp@+,%d0-%d6/%a1
    rts

/* subroutine (3 instructions): calls rsrc_PACK_7_74 (mechanical summary) */
rsrc_PACK_7_6E:
    rorw #4,%d1
    jbsr rsrc_PACK_7_74
    rolw #4,%d1

/* subroutine (119 instructions): traps StripAddress; calls rsrc_PACK_7_1CC, rsrc_PACK_7_1B6 (mechanical summary) */
rsrc_PACK_7_74:
    tstw %d6
    jbpl rsrc_PACK_7_74_A
    tstb %d1
    jbeq rsrc_PACK_7_74_12
    moveq #0,%d6
rsrc_PACK_7_74_A:       /* from here: orib #48,%d1 */
    orib #48,%d1
    moveb %d1,%a1@+
    subb %d1,%d1
rsrc_PACK_7_74_12:      /* return */
    rts
rsrc_PACK_7_74_14:      /* set %d0 */
    movew %sp@(4),%d0
    movel %sp@,%sp@(2)
    addqw #2,%sp
    subqw #1,%d0
    jbpl rsrc_PACK_7_74_60
    moveml %d1-%d3/%a0,%sp@-
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d3
    moveb %a0@+,%d2
    jbeq rsrc_PACK_7_74_5A
    cmpib #43,%a0@
    jbeq rsrc_PACK_7_74_3E
    cmpib #45,%a0@
    jbne rsrc_PACK_7_74_44
    moveq #1,%d3
rsrc_PACK_7_74_3E:      /* add 1 to %a0 */
    addql #1,%a0
    subqb #1,%d2
    jbeq rsrc_PACK_7_74_5A
rsrc_PACK_7_74_44:      /* loop: moveq */
    moveq #15,%d1
    andb %a0@+,%d1
    addl %d0,%d0
    addl %d0,%d1
    lsll #2,%d0
    addl %d1,%d0
    subqb #1,%d2
    jbne rsrc_PACK_7_74_44
    tstb %d3
    jbeq rsrc_PACK_7_74_5A
    negl %d0
rsrc_PACK_7_74_5A:      /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a0
    rts
rsrc_PACK_7_74_60:      /* subtract 1 to %d0 */
    subqw #1,%d0
    jbmi rsrc_PACK_7_74_6E
    jbeq rsrc_PACK_7_74_72
    cmpiw #1,%d0
    jbeq rsrc_PACK_7_74_76
    rts
rsrc_PACK_7_74_6E:      /* jump through %pc@(rsrc_PACK_7_74_82) */
    jmp %pc@(rsrc_PACK_7_74_82)
rsrc_PACK_7_74_72:      /* jump through %pc@(rsrc_PACK_7_3A0) */
    jmp %pc@(rsrc_PACK_7_3A0)
rsrc_PACK_7_74_76:      /* jump through %pc@(rsrc_PACK_7_74_7C) */
    jmp %pc@(rsrc_PACK_7_74_7C)
    .short  0x0000	| 40879ECE
rsrc_PACK_7_74_7C:      /* set %d1 */
    moveq #1,%d1
    rorl #1,%d1
    jbra rsrc_PACK_7_74_84
rsrc_PACK_7_74_82:      /* clear %d1 */
    moveq #0,%d1
rsrc_PACK_7_74_84:      /* from here: linkw %fp,#0 */
    linkw %fp,#0
    moveml %d2-%d7/%a2-%a3,%sp@-
    moveml %fp@(12),%d4-%d6
    movel %d6,%d0
    _StripAddress
    moveal %d0,%a0
    moveal %d5,%a1
    moveq #0,%d6
    moveb %a0@,%d6
    lea %a0@(0x0,%d6:w),%a3
    addaw %a1@,%a0
    movel %a0,%d6
    moveal %d4,%a1
    lea %a1@(4),%a2
    movel %d1,%d4
    addib #48,%d4
    moveq #57,%d7
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d2
    moveq #0,%d3
    moveq #0,%d5
    clrl %a1@
    movel #89010224,%a2@
    movew #12593,%a2@(4)
rsrc_PACK_7_74_CC:      /* call rsrc_PACK_7_1CC (loop) */
    jbsr rsrc_PACK_7_1CC
    cmpib #32,%d0
    jbeq rsrc_PACK_7_74_CC
    cmpib #0xca,%d0
    jbeq rsrc_PACK_7_74_CC
rsrc_PACK_7_74_DC:      /* test #9,%d0 */
    cmpib #9,%d0
    jbeq rsrc_PACK_7_74_CC
    cmpib #43,%d0
    jbeq rsrc_PACK_7_74_F0
    cmpib #45,%d0
    jbne rsrc_PACK_7_74_F2
    addqb #1,%a1@
rsrc_PACK_7_74_F0:      /* call rsrc_PACK_7_1CC */
    jbsr rsrc_PACK_7_1CC
rsrc_PACK_7_74_F2:      /* loop: cmpi */
    cmpib #48,%d0
    jbcs rsrc_PACK_7_74_104
    jbhi rsrc_PACK_7_74_116
    bset #15,%d4
    moveq #-1,%d6
    jbsr rsrc_PACK_7_1CC
    jbra rsrc_PACK_7_74_F2
rsrc_PACK_7_74_104:     /* test #46,%d0 */
    cmpib #46,%d0
    beqw rsrc_PACK_7_1CC_26
    tstw %d4
    jbpl rsrc_PACK_7_1CC_168
    jbra rsrc_PACK_7_1CC_A0
rsrc_PACK_7_74_116:     /* test #57,%d0 */
    cmpib #57,%d0
    jbls rsrc_PACK_7_74_126
    tstw %d4
    jbpl rsrc_PACK_7_1CC_F8
    jbra rsrc_PACK_7_1CC_52
rsrc_PACK_7_74_126:     /* set %d6 */
    moveq #-1,%d6
rsrc_PACK_7_74_128:     /* call rsrc_PACK_7_1B6 (loop) */
    jbsr rsrc_PACK_7_1B6
    jbcs rsrc_PACK_7_74_132
    cmpib #57,%d0
    jbls rsrc_PACK_7_74_128
rsrc_PACK_7_74_132:     /* test #46,%d0 */
    cmpib #46,%d0
    bnew rsrc_PACK_7_1CC_52
    jbsr rsrc_PACK_7_1CC
    jbcs rsrc_PACK_7_1CC_A0
    jbra rsrc_PACK_7_1CC_4C

/* subroutine (10 instructions) (mechanical summary) */
rsrc_PACK_7_1B6:
    cmpib #19,%d2
    jblt rsrc_PACK_7_1B6_A
    jbgt rsrc_PACK_7_1B6_12
    addqw #1,%d1
rsrc_PACK_7_1B6_A:      /* add 1 to %a2 */
    addql #1,%a2
    moveb %d0,%a2@
    addqb #1,%d2
    jbra rsrc_PACK_7_1CC
rsrc_PACK_7_1B6_12:     /* from here: orb %d0,%a2@ */
    orb %d0,%a2@
    addqw #1,%d1

/* subroutine (148 instructions): calls rsrc_PACK_7_1CC, rsrc_PACK_7_1B6, rsrc_PACK_7_366, rsrc_PACK_7_37E (mechanical summary) */
rsrc_PACK_7_1CC:
    tstl %d4
    jbpl rsrc_PACK_7_1CC_A
    moveb %a0@+,%d0
    jbeq rsrc_PACK_7_1CC_18
    jbra rsrc_PACK_7_1CC_10
rsrc_PACK_7_1CC_A:      /* test %a0,%a3 */
    cmpal %a0,%a3
    jblt rsrc_PACK_7_1CC_16
    moveb %a0@+,%d0
rsrc_PACK_7_1CC_10:     /* test #48,%d0 */
    cmpib #48,%d0
    rts
rsrc_PACK_7_1CC_16:     /* add 1 to %a0 */
    addql #1,%a0
rsrc_PACK_7_1CC_18:     /* set bit 16 of %d4 */
    bset #16,%d4
    tstl %d6
    jbpl rsrc_PACK_7_1CC_168
    braw rsrc_PACK_7_1CC_A0
rsrc_PACK_7_1CC_26:     /* call rsrc_PACK_7_1CC (loop) */
    jbsr rsrc_PACK_7_1CC
    jbeq rsrc_PACK_7_1CC_3A
    jbcs rsrc_PACK_7_1CC_32
    cmpib #57,%d0
    jbls rsrc_PACK_7_1CC_44
rsrc_PACK_7_1CC_32:     /* test %d4 */
    tstw %d4
    jbpl rsrc_PACK_7_1CC_168
    jbra rsrc_PACK_7_1CC_52
rsrc_PACK_7_1CC_3A:     /* set bit 15 of %d4 */
    bset #15,%d4
    moveq #-1,%d6
    subqw #1,%d1
    jbra rsrc_PACK_7_1CC_26
rsrc_PACK_7_1CC_44:     /* loop: moveq */
    moveq #-1,%d6
    subqw #1,%d1
    jbsr rsrc_PACK_7_1B6
    jbcs rsrc_PACK_7_1CC_A0
rsrc_PACK_7_1CC_4C:     /* test #57,%d0 */
    cmpib #57,%d0
    jbls rsrc_PACK_7_1CC_44
rsrc_PACK_7_1CC_52:     /* set %d6 */
    movel %a0,%d6
    subql #1,%d6
    cmpib #69,%d0
    jbeq rsrc_PACK_7_1CC_62
    cmpib #101,%d0
    jbne rsrc_PACK_7_1CC_A0
rsrc_PACK_7_1CC_62:     /* call rsrc_PACK_7_1CC */
    jbsr rsrc_PACK_7_1CC
    cmpib #43,%d0
    jbeq rsrc_PACK_7_1CC_74
    cmpib #45,%d0
    jbne rsrc_PACK_7_1CC_76
    bset #31,%d2
rsrc_PACK_7_1CC_74:     /* call rsrc_PACK_7_1CC (loop) */
    jbsr rsrc_PACK_7_1CC
rsrc_PACK_7_1CC_76:     /* test #48,%d0 */
    cmpib #48,%d0
    jbcs rsrc_PACK_7_1CC_9A
    cmpib #57,%d0
    jbhi rsrc_PACK_7_1CC_9A
    moveq #-1,%d6
    andiw #15,%d0
    muluw #10,%d5
    addw %d0,%d5
    cmpiw #8192,%d5
    jbcs rsrc_PACK_7_1CC_98
    movew #8192,%d5
rsrc_PACK_7_1CC_98:     /* continue at rsrc_PACK_7_1CC_74 */
    jbra rsrc_PACK_7_1CC_74
rsrc_PACK_7_1CC_9A:     /* test %d6 */
    tstl %d6
    jbpl rsrc_PACK_7_1CC_168
rsrc_PACK_7_1CC_A0:     /* subtract 1 to %a0 */
    subql #1,%a0
rsrc_PACK_7_1CC_A2:     /* loop: tst */
    tstb %d2
    jbne rsrc_PACK_7_1CC_B0
    tstw %d4
    jbpl rsrc_PACK_7_1CC_D4
    movew #304,%a2@
    jbra rsrc_PACK_7_1CC_D4
rsrc_PACK_7_1CC_B0:     /* test %d2 */
    tstl %d2
    jbpl rsrc_PACK_7_1CC_B6
    negw %d5
rsrc_PACK_7_1CC_B6:     /* loop: cmpi */
    cmpib #48,%a1@(0x4,%d2:w)
    jbne rsrc_PACK_7_1CC_CA
    subqb #1,%d2
    cmpib #19,%d2
    jbeq rsrc_PACK_7_1CC_C8
    addqw #1,%d5
rsrc_PACK_7_1CC_C8:     /* continue at rsrc_PACK_7_1CC_B6 */
    jbra rsrc_PACK_7_1CC_B6
rsrc_PACK_7_1CC_CA:     /* set %a1@(4) */
    moveb %d2,%a1@(4)
    addw %d1,%d5
    movew %d5,%a1@(2)
rsrc_PACK_7_1CC_D4:     /* loop: suba */
    subal %fp@(20),%a0
    moveal %fp@(16),%a1
    movew %a0,%a1@
    moveal %fp@(4),%a0
    moveal %fp@(8),%a1
    swap %d4
    moveb %d4,%a1@
    moveml %fp@(-32),%d2-%d7/%a2-%a3
    unlk %fp
    lea %sp@(20),%sp
    jmp %a0@
rsrc_PACK_7_1CC_F8:     /* test #0xb0,%d0 */
    cmpib #0xb0,%d0
    beqw rsrc_PACK_7_1CC_17A
    subql #1,%a0
    moveq #73,%d3
    jbsr rsrc_PACK_7_366
    beqw rsrc_PACK_7_1CC_16E
    cmpib #78,%d0
    jbne rsrc_PACK_7_1CC_168
    moveq #65,%d3
    bsrw rsrc_PACK_7_366
    jbne rsrc_PACK_7_1CC_168
    moveq #78,%d3
    bsrw rsrc_PACK_7_366
    bnew rsrc_PACK_7_1CC_168
    movel #89011248,%a2@+
    movew #12336,%a2@
    movel %a0,%d6
    jbsr rsrc_PACK_7_1CC
    cmpib #40,%d0
    jbne rsrc_PACK_7_1CC_168
    moveq #0,%d3
rsrc_PACK_7_1CC_13C:    /* call rsrc_PACK_7_1CC (loop) */
    jbsr rsrc_PACK_7_1CC
    jbcs rsrc_PACK_7_1CC_154
    cmpib #57,%d0
    jbhi rsrc_PACK_7_1CC_168
    muluw #10,%d3
    andiw #15,%d0
    addw %d0,%d3
    jbra rsrc_PACK_7_1CC_13C
rsrc_PACK_7_1CC_154:    /* test #41,%d0 */
    cmpib #41,%d0
    jbne rsrc_PACK_7_1CC_168
    jbsr rsrc_PACK_7_37E
    rorw #8,%d0
    rorb #4,%d3
    jbsr rsrc_PACK_7_37E
    rorw #8,%d0
    movew %d0,%a2@
    jbra rsrc_PACK_7_1CC_17E
rsrc_PACK_7_1CC_168:    /* loop: movea */
    moveal %d6,%a0
    jbra rsrc_PACK_7_1CC_A2
rsrc_PACK_7_1CC_16E:    /* set %d3 */
    moveq #78,%d3
    jbsr rsrc_PACK_7_366
    jbne rsrc_PACK_7_1CC_168
    moveq #70,%d3
    jbsr rsrc_PACK_7_366
    jbne rsrc_PACK_7_1CC_168
rsrc_PACK_7_1CC_17A:    /* set %a2@ */
    movew #329,%a2@
rsrc_PACK_7_1CC_17E:    /* set %d6 */
    moveq #-1,%d6
    tstl %d4
    jbpl rsrc_PACK_7_1CC_18C
    moveb %a0@,%d0
    jbne rsrc_PACK_7_1CC_D4
    jbra rsrc_PACK_7_1CC_192
rsrc_PACK_7_1CC_18C:    /* test %a0,%a3 */
    cmpal %a0,%a3
    jbge rsrc_PACK_7_1CC_D4
rsrc_PACK_7_1CC_192:    /* set bit 16 of %d4 */
    bset #16,%d4
    jbra rsrc_PACK_7_1CC_D4

/* subroutine (8 instructions): calls rsrc_PACK_7_1CC (mechanical summary) */
rsrc_PACK_7_366:
    jbsr rsrc_PACK_7_1CC
    cmpib #97,%d0
    jbcs rsrc_PACK_7_366_14
    cmpib #122,%d0
    jbhi rsrc_PACK_7_366_14
    subib #32,%d0
rsrc_PACK_7_366_14:     /* test %d3,%d0 */
    cmpb %d3,%d0
    rts

/* subroutine (52 instructions): calls rsrc_PACK_7_426 (mechanical summary) */
rsrc_PACK_7_37E:
    moveb #15,%d0
    andb %d3,%d0
    cmpib #9,%d0
    jbls rsrc_PACK_7_37E_E
    addqb #7,%d0
rsrc_PACK_7_37E_E:      /* from here: addib #48,%d0 */
    addib #48,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4087A172

rsrc_PACK_7_3A0:        /* save registers */
    moveml %d2-%d5,%sp@-
    linkw %fp,#0
    moveal %fp@(32),%a0
    movel %a0@,%d5
    moveal %fp@(24),%a0
    moveal %fp@(28),%a1
    movel %a1@+,%d4
    addqw #1,%a0
    moveq #-80,%d2
    moveq #0,%d1
    moveb %a1@+,%d1
    jbeq rsrc_PACK_7_3A0_40
    btst #24,%d4
    jbeq rsrc_PACK_7_3A0_2E
    moveb #45,%a0@+
    jbra rsrc_PACK_7_3A0_38
rsrc_PACK_7_3A0_2E:     /* test bit 24 of %d5 */
    btst #24,%d5
    jbne rsrc_PACK_7_3A0_3A
    moveb #32,%a0@+
rsrc_PACK_7_3A0_38:     /* add 1 to %d2 */
    addqw #1,%d2
rsrc_PACK_7_3A0_3A:     /* set %d0 */
    moveb %a1@,%d0
    cmpib #63,%d0
rsrc_PACK_7_3A0_40:     /* from here: jbeq rsrc_PACK_7_4DA_6 */
    jbeq rsrc_PACK_7_4DA_6
    orib #32,%d0
    cmpib #105,%d0
    jbeq rsrc_PACK_7_4DA_64
    cmpib #110,%d0
    jbne rsrc_PACK_7_426_16
    moveb #78,%a0@+
    moveb #65,%a0@+
    moveb #78,%a0@+
    moveb #40,%a0@+
    moveb #41,%a0@(3)
    addqw #5,%d2
    moveq #0,%d3
    cmpib #5,%d1
    jble rsrc_PACK_7_3A0_78
    moveq #5,%d1
rsrc_PACK_7_3A0_78:     /* call rsrc_PACK_7_426 */
    jbsr rsrc_PACK_7_426
    movel %d3,%d0
    jbsr rsrc_PACK_7_426
    aslb #4,%d3
    orl %d0,%d3
rsrc_PACK_7_3A0_82:     /* result 4 */
    moveq #4,%d0
    jbra rsrc_PACK_7_426_68

/* subroutine (59 instructions): calls rsrc_PACK_7_4BA, rsrc_PACK_7_4C8, rsrc_PACK_7_4DA (mechanical summary) */
rsrc_PACK_7_426:
    subqw #1,%d1
    jble rsrc_PACK_7_3A0_82
    moveb %a1@(0x0,%d1:w),%d3
    cmpib #57,%d3
    jble rsrc_PACK_7_426_10
    subqb #7,%d3
rsrc_PACK_7_426_10:     /* from here: andib #15,%d3 */
    andib #15,%d3
    rts
rsrc_PACK_7_426_16:     /* test #48,%a1@ */
    cmpib #48,%a1@
    jbne rsrc_PACK_7_426_20
    moveq #1,%d1
    moveq #0,%d4
rsrc_PACK_7_426_20:     /* test bit 24 of %d5 */
    btst #24,%d5
    jbne rsrc_PACK_7_4DA_10
    tstw %d5
    jbgt rsrc_PACK_7_426_2E
    moveq #1,%d5
rsrc_PACK_7_426_2E:     /* set %d0 */
    moveq #1,%d0
    jbsr rsrc_PACK_7_4BA
    movew %d1,%d3
    extl %d3
    subql #1,%d3
    jbgt rsrc_PACK_7_426_40
    cmpiw #1,%d5
    jble rsrc_PACK_7_426_4C
rsrc_PACK_7_426_40:     /* call rsrc_PACK_7_4C8 */
    jbsr rsrc_PACK_7_4C8
    movew %d3,%d0
    jbsr rsrc_PACK_7_4BA
    movew %d5,%d0
    subw %d1,%d0
    jbsr rsrc_PACK_7_4DA
rsrc_PACK_7_426_4C:     /* add 2 to %d2 */
    addqw #2,%d2
    jbgt rsrc_PACK_7_4DA_6
    moveb #101,%a0@+
    extl %d4
    addl %d4,%d3
    jblt rsrc_PACK_7_426_60
    moveb #43,%a0@+
    jbra rsrc_PACK_7_426_66
rsrc_PACK_7_426_60:     /* set %a0@+ */
    moveb #45,%a0@+
    negl %d3
rsrc_PACK_7_426_66:     /* clear %d0 */
    moveq #0,%d0
rsrc_PACK_7_426_68:     /* address %pc@(rsrc_PACK_7_54E) */
    lea %pc@(rsrc_PACK_7_54E),%a1
rsrc_PACK_7_426_6C:     /* loop: addq */
    addqw #2,%d0
    cmpw %a1@(0xfffffffffffffffe,%d0:w),%d3
    jbcs rsrc_PACK_7_426_8C
    cmpib #8,%d0
    jblt rsrc_PACK_7_426_6C
rsrc_PACK_7_426_7A:     /* loop: divu */
    divuw %a1@(0xfffffffffffffffe,%d0:w),%d3
rsrc_PACK_7_426_7E:     /* loop: addq */
    addqw #1,%d2
    jbgt rsrc_PACK_7_4DA_6
    addiw #48,%d3
    moveb %d3,%a0@+
    swap %d3
    extl %d3
rsrc_PACK_7_426_8C:     /* subtract 2 to %d0 */
    subqw #2,%d0
    jbgt rsrc_PACK_7_426_7A
    jbeq rsrc_PACK_7_426_7E
    jbra rsrc_PACK_7_4DA_4E

/* subroutine (7 instructions) (mechanical summary) */
rsrc_PACK_7_4BA:
    jble rsrc_PACK_7_4BA_C
    addw %d0,%d2
    jbgt rsrc_PACK_7_4DA_6
rsrc_PACK_7_4BA_6:      /* loop: move */
    moveb %a1@+,%a0@+
    subqw #1,%d0
    jbgt rsrc_PACK_7_4BA_6
rsrc_PACK_7_4BA_C:      /* return */
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_PACK_7_4C8:
    addqw #1,%d2
    jbgt rsrc_PACK_7_4DA_6
    moveb #46,%a0@+
    rts
rsrc_PACK_7_4C8_A:      /* loop: addq */
    addqw #1,%d2
    jbgt rsrc_PACK_7_4DA_6
    moveb #48,%a0@+

/* subroutine (49 instructions): calls rsrc_PACK_7_4BA, rsrc_PACK_7_4C8, rsrc_PACK_7_4DA (mechanical summary) */
rsrc_PACK_7_4DA:
    subqw #1,%d0
    jbge rsrc_PACK_7_4C8_A
    rts
rsrc_PACK_7_4DA_6:      /* set %a0 */
    moveal %fp@(24),%a0
    movew #319,%a0@
    jbra rsrc_PACK_7_4DA_58
rsrc_PACK_7_4DA_10:     /* set %d3 */
    movew %d1,%d3
    addw %d4,%d3
    jble rsrc_PACK_7_4DA_38
    tstw %d4
    jbge rsrc_PACK_7_4DA_26
    movew %d3,%d0
    jbsr rsrc_PACK_7_4BA
    jbsr rsrc_PACK_7_4C8
    moveq #0,%d0
    subw %d4,%d0
    jbra rsrc_PACK_7_4DA_46
rsrc_PACK_7_4DA_26:     /* set %d0 */
    movew %d1,%d0
    jbsr rsrc_PACK_7_4BA
    movew %d4,%d0
    jbsr rsrc_PACK_7_4DA
    movew %d5,%d0
    jble rsrc_PACK_7_4DA_4E
    jbsr rsrc_PACK_7_4C8
    jbsr rsrc_PACK_7_4DA
    jbra rsrc_PACK_7_4DA_4E
rsrc_PACK_7_4DA_38:     /* set %d0 */
    moveq #1,%d0
    jbsr rsrc_PACK_7_4DA
    jbsr rsrc_PACK_7_4C8
    moveq #0,%d0
    subw %d3,%d0
    jbsr rsrc_PACK_7_4DA
    movew %d1,%d0
rsrc_PACK_7_4DA_46:     /* call rsrc_PACK_7_4BA */
    jbsr rsrc_PACK_7_4BA
    movew %d4,%d0
    addw %d5,%d0
    jbsr rsrc_PACK_7_4DA
rsrc_PACK_7_4DA_4E:     /* loop: movea */
    moveal %fp@(24),%a0
    addiw #80,%d2
    moveb %d2,%a0@
rsrc_PACK_7_4DA_58:     /* return */
    unlk %fp
    moveml %sp@+,%d2-%d5/%a0
    lea %sp@(12),%sp
    jmp %a0@
rsrc_PACK_7_4DA_64:     /* set %a0@+ */
    moveb #73,%a0@+
    moveb #78,%a0@+
    moveb #70,%a0@
    addqw #3,%d2
    jbra rsrc_PACK_7_4DA_4E
rsrc_PACK_7_54E:        /* (data) */
    .short  0x000A	| 4087A32E
    .long   0x006403E8, 0x27100000, 0x00000000, 0x00000000	| 4087A330
