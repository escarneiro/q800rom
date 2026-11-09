/* ROM resource 'PACK' 4: map entry at 0x40873910, data at 0x40873940, 11136 bytes

 The software SANE arithmetic package (PACK 4, FP68K): the Standard Apple Numerics
 Environment's basic operations on single, double, extended, comp and integer operands,
 done in software (no floating-point instructions), for machines without an FPU; the
 machine mask of its map entry selects them. The Quadra 800 uses the FPU version
 (rsrc/E99F0_PACK_4.s). The operation word on the stack selects the routine through
 FP68K_OPTABLE (FP68K_OPTABLE_FMT for operations with a format). Routine names are
 those of the operations; comments from the SANE documentation (Apple Numerics Manual).
*/

rsrc_PACK_4_entry:      /* map entry */
    .long   0x08000000, 0x00000000	| 40873910
    .long   rsrc_clut_1_1BitStd_entry-rom_start	| 40873918
    .long   rsrc_PACK_4-rom_start	| 4087391C
    .ascii  "PACK"	| 40873920
    .short  0x0004, 0x5800	| orib #0,%d4
    .long   0x00000000, 0x00000000	| 40873928
    .long   0x00000000	| 40873930
    andl %a0@-,%d0
    orib #0,%d0
    movel %a4,%a5@(0x0,%d0:w)
    bchg %d0,%a4@+

/* subroutine (98 instructions): calls rsrc_PACK_4_176, rsrc_PACK_4_1E0, rsrc_PACK_4_162 (mechanical summary) */
rsrc_PACK_4:
    subql #4,%sp
    moveml %d0/%a0,%sp@-
rsrc_PACK_4_6:          /* clear %d0 */
    moveq #0,%d0
    movew %sp@(16),%d0
    bftst %d0,18,3
    jbeq rsrc_PACK_4_18
    btst #0,%d0
    jbeq rsrc_PACK_4_30
rsrc_PACK_4_18:         /* from here: andiw #31,%d0 */
    andiw #31,%d0
    addw %d0,%d0
    movew %pc@(FP68K_OPTABLE,%d0:w),%d0
    lea %pc@(rsrc_PACK_4_6,%d0:w),%a0
rsrc_PACK_4_26:         /* loop: move */
    movel %a0,%sp@(8)
    moveml %sp@+,%d0/%a0
    rts
rsrc_PACK_4_30:         /* from here: andiw #30,%d0 */
    andiw #30,%d0
    movew %pc@(FP68K_OPTABLE_FMT,%d0:w),%d0
    lea %pc@(rsrc_PACK_4_6,%d0:w),%a0
    jbra rsrc_PACK_4_26

/* Operation table: offsets of the routines from rsrc_PACK_4_6, by operation code. */
FP68K_OPTABLE:  /* by operation code, offsets from rsrc_PACK_4_6 */
    .short  FP68K_ADD-rsrc_PACK_4_6  /* 00 ADD */
    .short  FP68K_SETENV-rsrc_PACK_4_6  /* 01 SETENV */
    .short  FP68K_SUB-rsrc_PACK_4_6  /* 02 SUB */
    .short  FP68K_GETENV-rsrc_PACK_4_6  /* 03 GETENV */
    .short  FP68K_MUL-rsrc_PACK_4_6  /* 04 MUL */
    .short  FP68K_SETHV-rsrc_PACK_4_6  /* 05 SETHV */
    .short  FP68K_DIV-rsrc_PACK_4_6  /* 06 DIV */
    .short  FP68K_GETHV-rsrc_PACK_4_6  /* 07 GETHV */
    .short  FP68K_CMP_CPX-rsrc_PACK_4_6  /* 08 CMP */
    .short  FP68K_DEC2X-rsrc_PACK_4_6  /* 09 DEC2X */
    .short  FP68K_CMP_CPX-rsrc_PACK_4_6  /* 0A CPX */
    .short  FP68K_X2DEC-rsrc_PACK_4_6  /* 0B X2DEC */
    .short  FP68K_REM-rsrc_PACK_4_6  /* 0C REM */
    .short  FP68K_NEG-rsrc_PACK_4_6  /* 0D NEG */
    .short  FP68K_X2X-rsrc_PACK_4_6  /* 0E Z2X */
    .short  FP68K_ABS-rsrc_PACK_4_6  /* 0F ABS */
    .short  FP68K_X2X-rsrc_PACK_4_6  /* 10 X2Z */
    .short  FP68K_CPYSGN-rsrc_PACK_4_6  /* 11 CPYSGN */
    .short  FP68K_SQRT-rsrc_PACK_4_6  /* 12 SQRT */
    .short  FP68K_NEXT-rsrc_PACK_4_6  /* 13 NEXT */
    .short  FP68K_RINT-rsrc_PACK_4_6  /* 14 RINT */
    .short  FP68K_SETXCP-rsrc_PACK_4_6  /* 15 SETXCP */
    .short  FP68K_TINT-rsrc_PACK_4_6  /* 16 TINT */
    .short  FP68K_PROCENTRY-rsrc_PACK_4_6  /* 17 PROCENTRY */
    .short  FP68K_SCALB-rsrc_PACK_4_6  /* 18 SCALB */
    .short  FP68K_PROCEXIT-rsrc_PACK_4_6  /* 19 PROCEXIT */
    .short  FP68K_LOGB-rsrc_PACK_4_6  /* 1A LOGB */
    .short  FP68K_TESTXCP-rsrc_PACK_4_6  /* 1B TESTXCP */
    .short  FP68K_CLASS-rsrc_PACK_4_6  /* 1C CLASS */

/* The same for operations that take a source format. */
FP68K_OPTABLE_FMT:
    .short  FP68K_ADD_fmt-rsrc_PACK_4_6	| 408739B8
    .short  FP68K_SUB_fmt-rsrc_PACK_4_6	| 408739BA
    .short  FP68K_MUL_fmt-rsrc_PACK_4_6	| 408739BC
    .short  FP68K_DIV_fmt-rsrc_PACK_4_6	| 408739BE
    .short  FP68K_CMP_CPX_fmt-rsrc_PACK_4_6	| 408739C0
    .short  FP68K_CMP_CPX_fmt-rsrc_PACK_4_6	| 408739C2
    .short  FP68K_REM_fmt-rsrc_PACK_4_6	| 408739C4
    .short  FP68K_Z2X_fmt-rsrc_PACK_4_6	| 408739C6
    .short  FP68K_X2Z_fmt-rsrc_PACK_4_6	| 408739C8
    .short  FP68K_SQRT-rsrc_PACK_4_6	| 408739CA
    .short  FP68K_RINT-rsrc_PACK_4_6	| 408739CC
    .short  FP68K_TINT-rsrc_PACK_4_6	| 408739CE
    .short  FP68K_SCALB-rsrc_PACK_4_6	| 408739D0
    .short  FP68K_LOGB-rsrc_PACK_4_6	| 408739D2
    .short  FP68K_CLASS_fmt-rsrc_PACK_4_6	| 408739D4
rsrc_PACK_4_96:         /* loop: move */
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    moveal %fp@(10),%a1
    jbsr rsrc_PACK_4_176
    moveal %a4,%a3
    movel %d4,%d3
    moveal %d5,%a2
    lsrb #1,%d6
    movel %d0,%d1
    clrw %d1
    addl %d0,%d0
    addl %d1,%d0
    moveal %fp@(14),%a1
    jbsr rsrc_PACK_4_176
rsrc_PACK_4_96_2A:      /* loop: as */
    aslb #1,%d6
    jbvc rsrc_PACK_4_96_32
    bset #6,%d6
rsrc_PACK_4_96_32:      /* from here: roxrb #1,%d6 */
    roxrb #1,%d6
    moveq #0,%d7
    tstw %d0
    jbne rsrc_PACK_4_D4_4E
    swap %d0
    jmp %a0@

rsrc_PACK_4_D4:         /* loop: move */
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    moveal %fp@(10),%a1
    jbsr rsrc_PACK_4_176
    moveal %a4,%a3
    movel %d4,%d3
    moveal %d5,%a2
    lsrb #1,%d6
    movel %d0,%d1
    clrw %d1
    addl %d0,%d0
    addl %d1,%d0
    movel %d6,%d1
    clrw %d1
    roll #6,%d1
    andiw #14,%d1
    subqw #2,%d1
    moveal %fp@(14),%a1
    jbsr rsrc_PACK_4_1E0
    jbra rsrc_PACK_4_96_2A
rsrc_PACK_4_D4_38:      /* loop: bset */
    bset #8,%d6
    swap %d0
    bset #30,%d0
    movel %d0,%d4
    moveq #0,%d5
    moveaw #32767,%a4
    jbra rsrc_PACK_4_4FA_8C
rsrc_PACK_4_D4_4E:      /* address %pc@(rsrc_PACK_4_5A4) */
    lea %pc@(rsrc_PACK_4_5A4),%a0
    subqw #2,%d0
    jbeq rsrc_PACK_4_D4_72
    subqw #2,%d0
    jbeq rsrc_PACK_4_D4_6A
    movel %d3,%d7
    movel #16711680,%d1
    andl %d1,%d7
    andl %d4,%d1
    cmpl %d7,%d1
    jbgt rsrc_PACK_4_D4_72
rsrc_PACK_4_D4_6A:      /* from here: addb %d6,%d6 */
    addb %d6,%d6
    moveal %a3,%a4
    movel %d3,%d4
    movel %a2,%d5
rsrc_PACK_4_D4_72:      /* from here: bfextu %d6,11,5,%d1 */
    bfextu %d6,11,5,%d1
    subqw #8,%d1
    jbeq rsrc_PACK_4_D4_82
    subqw #2,%d1
    jbne rsrc_PACK_4_D4_88
    bset #8,%d6
rsrc_PACK_4_D4_82:      /* set %d7 */
    moveq #2,%d7
    jbra rsrc_PACK_4_5A6
rsrc_PACK_4_D4_88:      /* call rsrc_PACK_4_162 (loop) */
    jbsr rsrc_PACK_4_162
    jbra rsrc_PACK_4_4FA_8C

/* subroutine (8 instructions) (mechanical summary) */
rsrc_PACK_4_162:
    movel %d4,%d1
    bclr #30,%d1
    orl %d5,%d1
    jbne rsrc_PACK_4_162_12
    moveq #21,%d4
    swap %d4
    bset #30,%d4
rsrc_PACK_4_162_12:     /* return */
    rts

/* subroutine (41 instructions) (mechanical summary) */
rsrc_PACK_4_176:
    movew %a1@+,%d1
    jbpl rsrc_PACK_4_176_C
    bset #7,%d6
    bclr #15,%d1
rsrc_PACK_4_176_C:      /* test bit 21 of %d6 */
    btst #21,%d6
    jbeq rsrc_PACK_4_176_14
    addqw #2,%a1
rsrc_PACK_4_176_14:     /* set %d4 */
    movel %a1@+,%d4
    movel %a1@,%d5
    cmpiw #32767,%d1
    jbeq rsrc_PACK_4_176_44
    tstl %d4
    jbpl rsrc_PACK_4_176_28
rsrc_PACK_4_176_22:     /* loop: ext */
    extl %d1
    moveal %d1,%a4
    rts
rsrc_PACK_4_176_28:     /* loop: tst */
    tstl %d4
    jbne rsrc_PACK_4_176_3A
    tstl %d5
    jbne rsrc_PACK_4_176_3A
rsrc_PACK_4_1A6:        /* loop: suba */
    subal %a4,%a4
    addil #131072,%d0
    rts
rsrc_PACK_4_176_3A:     /* loop: subq */
    subqw #1,%d1
    addl %d5,%d5
    addxl %d4,%d4
    jbpl rsrc_PACK_4_176_3A
    jbra rsrc_PACK_4_176_22
rsrc_PACK_4_176_44:     /* loop: movea */
    moveaw #32767,%a4
    bclr #31,%d4
    tstl %d4
    jbne rsrc_PACK_4_176_5C
    tstl %d5
    jbne rsrc_PACK_4_176_5C
    addil #262144,%d0
    rts
rsrc_PACK_4_176_5C:     /* set bit 30 of %d4 */
    bset #30,%d4
    jbne rsrc_PACK_4_176_66
    bset #8,%d6
rsrc_PACK_4_176_66:     /* add 2 to %d0 */
    addqw #2,%d0
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_4_1E0:
    movew %pc@(rsrc_PACK_4_1E8,%d1:w),%d1
    jmp %pc@(rsrc_PACK_4_1E0,%d1:w)
rsrc_PACK_4_1E8:        /* (data) */
    .short  rsrc_PACK_4_2A4-rsrc_PACK_4_1E0	| 40873B28
    .short  rsrc_PACK_4_270-rsrc_PACK_4_1E0	| 40873B2A
    .short  rsrc_PACK_4_176-rsrc_PACK_4_1E0	| 40873B2C
    .short  rsrc_PACK_4_1F4-rsrc_PACK_4_1E0	| 40873B2E
    .short  rsrc_PACK_4_202-rsrc_PACK_4_1E0	| 40873B30
    .short  rsrc_PACK_4_222-rsrc_PACK_4_1E0	| 40873B32

/* subroutine (6 instructions) (mechanical summary) */
rsrc_PACK_4_1F4:
    moveq #0,%d4	| 40873B34
    movew #16398,%d1	| 40873B36
    movel %d4,%d5	| 40873B3A
    movew %a1@,%d4	| 40873B3C
    swap %d4	| 40873B3E
    jbra rsrc_PACK_4_20A	| 40873B40

/* subroutine (12 instructions) (mechanical summary) */
rsrc_PACK_4_202:
    movew #16414,%d1	| 40873B42
    moveq #0,%d5	| 40873B46
    movel %a1@,%d4	| 40873B48
rsrc_PACK_4_20A:        /* from here: jbeq rsrc_PACK_4_1A6 */
    jbeq rsrc_PACK_4_1A6	| 40873B4A
    jbpl rsrc_PACK_4_216	| 40873B4C
    bset #7,%d6	| 40873B4E
    negl %d4	| 40873B52
    jbmi rsrc_PACK_4_176_22	| 40873B54
rsrc_PACK_4_216:        /* loop: bfffo */
    bfffo %d4,0,0,%d2	| 40873B56
    subw %d2,%d1	| 40873B5A
    lsll %d2,%d4	| 40873B5C
    jbra rsrc_PACK_4_176_22	| 40873B5E

/* subroutine (29 instructions) (mechanical summary) */
rsrc_PACK_4_222:
    movew #16446,%d1	| 40873B62
    movel %a1@+,%d4	| 40873B66
    movel %a1@,%d5	| 40873B68
    jbne rsrc_PACK_4_250	| 40873B6A
    tstl %d4	| 40873B6C
    jbeq rsrc_PACK_4_1A6	| 40873B6E
    jbpl rsrc_PACK_4_216	| 40873B72
    bset #7,%d6	| 40873B74
    negl %d4	| 40873B78
    jbpl rsrc_PACK_4_216	| 40873B7A
    moveaw #32767,%a4	| 40873B7C
    bclr #7,%d6	| 40873B80
    moveq #20,%d4	| 40873B84
    swap %d4	| 40873B86
    bset #30,%d4	| 40873B88
    addqw #2,%d0	| 40873B8C
    rts	| 40873B8E
rsrc_PACK_4_250:        /* test %d4 */
    tstl %d4	| 40873B90
    jbpl rsrc_PACK_4_25E	| 40873B92
    bset #7,%d6	| 40873B94
    negl %d5	| 40873B98
    negxl %d4	| 40873B9A
    tstl %d4	| 40873B9C
rsrc_PACK_4_25E:        /* from here: jbne rsrc_PACK_4_176_3A */
    jbne rsrc_PACK_4_176_3A	| 40873B9E
    subiw #32,%d1	| 40873BA2
    exg %d4,%d5	| 40873BA6
    tstl %d4	| 40873BA8
    jbpl rsrc_PACK_4_216	| 40873BAA
    jbra rsrc_PACK_4_176_22	| 40873BAC

/* subroutine (15 instructions) (mechanical summary) */
rsrc_PACK_4_270:
    moveq #0,%d5	| 40873BB0
    movel %a1@,%d4	| 40873BB2
    jbpl rsrc_PACK_4_27A	| 40873BB4
    bset #7,%d6	| 40873BB6
rsrc_PACK_4_27A:        /* from here: bfextu %d4,1,8,%d1 */
    bfextu %d4,1,8,%d1	| 40873BBA
    jbeq rsrc_PACK_4_296	| 40873BBE
    lsll #8,%d4	| 40873BC0
    cmpib #0xff,%d1	| 40873BC2
    jbeq rsrc_PACK_4_176_44	| 40873BC6
    addiw #16256,%d1	| 40873BCA
    bset #31,%d4	| 40873BCE
    jbra rsrc_PACK_4_176_22	| 40873BD2
rsrc_PACK_4_296:        /* from here: lsll #8,%d4 */
    lsll #8,%d4	| 40873BD6
    jbeq rsrc_PACK_4_1A6	| 40873BD8
    movew #16257,%d1	| 40873BDC
    jbra rsrc_PACK_4_216	| 40873BE0

/* subroutine (21 instructions) (mechanical summary) */
rsrc_PACK_4_2A4:
    movel %a1@,%d4	| 40873BE4
    jbpl rsrc_PACK_4_2AC	| 40873BE6
    bset #7,%d6	| 40873BE8
rsrc_PACK_4_2AC:        /* set %d5 */
    movel %a1@(4),%d5	| 40873BEC
    bfextu %d4,1,11,%d1	| 40873BF0
    bfextu %d5,0,11,%d2	| 40873BF4
    lsll #8,%d4	| 40873BF8
    lsll #8,%d5	| 40873BFA
    lsll #3,%d4	| 40873BFC
    lsll #3,%d5	| 40873BFE
    orw %d2,%d4	| 40873C00
    bclr #31,%d4	| 40873C02
    tstl %d1	| 40873C06
    jbne rsrc_PACK_4_2D2	| 40873C08
    movew #15361,%d1	| 40873C0A
    jbra rsrc_PACK_4_176_28	| 40873C0E
rsrc_PACK_4_2D2:        /* test #2047,%d1 */
    cmpiw #2047,%d1	| 40873C12
    jbeq rsrc_PACK_4_176_44	| 40873C16
    bset #31,%d4	| 40873C1A
    addiw #15360,%d1	| 40873C1E
    jbra rsrc_PACK_4_176_22	| 40873C22

/* subroutine (50 instructions): calls rsrc_PACK_4_368; low memory FPState (mechanical summary) */
rsrc_PACK_4_2E6:
    cmpiw #66,%d0
    jbls rsrc_PACK_4_2E6_A
    movew #66,%d0
rsrc_PACK_4_2E6_A:      /* loop: cmpi */
    cmpiw #32,%d0
    jblt rsrc_PACK_4_2E6_24
    tstl %d7
    sne %d3
    movel %d5,%d7
    movel %d4,%d5
    orb %d3,%d7
    moveq #0,%d4
    subiw #32,%d0
    jbne rsrc_PACK_4_2E6_A
    rts
rsrc_PACK_4_2E6_24:     /* from here: bfins %d7,%d3,0,%d0 */
    bfins %d7,%d3,0,%d0
    sne %d3
    lsrl %d0,%d7
    bfins %d5,%d7,0,%d0
    lsrl %d0,%d5
    bfins %d4,%d5,0,%d0
    lsrl %d0,%d4
    orb %d3,%d7
    rts
rsrc_PACK_4_2E6_3C:     /* loop: moveq */
    moveq #0,%d7
    tstl %d4
    jbne rsrc_PACK_4_2E6_4C
    tstl %d5
    jbne rsrc_PACK_4_2E6_4C
    subal %a4,%a4
    jbra rsrc_PACK_4_4FA_8C
rsrc_PACK_4_2E6_4C:     /* test %d4 */
    tstl %d4
    jbmi rsrc_PACK_4_4FA
rsrc_PACK_4_2E6_52:     /* loop: subq */
    subql #1,%a4
    addl %d5,%d5
    addxl %d4,%d4
    jbpl rsrc_PACK_4_2E6_52
    jbra rsrc_PACK_4_4FA
rsrc_PACK_4_2E6_5E:     /* loop: tst */
    tstl %d4
    jbmi rsrc_PACK_4_352
rsrc_PACK_4_2E6_62:     /* loop: subq */
    subql #1,%a4
    addl %d7,%d7
    addxl %d5,%d5
    addxl %d4,%d4
    jbpl rsrc_PACK_4_2E6_62

rsrc_PACK_4_352:        /* loop: move */
    movew FPState,%d1
    bftst %d1,25,2
    jbeq rsrc_PACK_4_4FA
    jbpl rsrc_PACK_4_368_AC
rsrc_PACK_4_352_10:     /* call rsrc_PACK_4_368 (loop) */
    jbsr rsrc_PACK_4_368
    jbra rsrc_PACK_4_368_AE

/* subroutine (82 instructions): calls rsrc_PACK_4_2E6, rsrc_PACK_4_43E (mechanical summary) */
rsrc_PACK_4_368:
    movel #16257,%d0
    subl %a4,%d0
    jble rsrc_PACK_4_368_16
    bset #9,%d6
    moveaw #16257,%a4
    jbsr rsrc_PACK_4_2E6
rsrc_PACK_4_368_16:     /* test %d5 */
    tstl %d5
    sne %d0
    orb %d0,%d7
    addb %d4,%d4
    roxrl #1,%d7
    orb %d4,%d7
    moveq #0,%d5
    clrb %d4
    tstl %d7
    jbne rsrc_PACK_4_368_30
    bclr #9,%d6
    jbra rsrc_PACK_4_368_66
rsrc_PACK_4_368_30:     /* set bit 12 of %d6 */
    bset #12,%d6
    bftst %d1,17,2
    jbeq rsrc_PACK_4_368_4E
    jbmi rsrc_PACK_4_368_42
    tstb %d6
    jbpl rsrc_PACK_4_368_5A
    jbra rsrc_PACK_4_368_66
rsrc_PACK_4_368_42:     /* test bit 13 of %d1 */
    btst #13,%d1
    jbne rsrc_PACK_4_368_66
    tstb %d6
    jbpl rsrc_PACK_4_368_66
    jbra rsrc_PACK_4_368_5A
rsrc_PACK_4_368_4E:     /* from here: addl %d7,%d7 */
    addl %d7,%d7
    jbcc rsrc_PACK_4_368_66
    jbne rsrc_PACK_4_368_5A
    btst #8,%d4
    jbeq rsrc_PACK_4_368_66
rsrc_PACK_4_368_5A:     /* from here: addil #256,%d4 */
    addil #256,%d4
    jbcc rsrc_PACK_4_368_66
    roxrl #1,%d4
    addql #1,%a4
rsrc_PACK_4_368_66:     /* set %a3 */
    moveaw #16510,%a3
    cmpal %a4,%a3
    jblt rsrc_PACK_4_368_70
    rts
rsrc_PACK_4_368_70:     /* set bit 10 of %d6 */
    bset #10,%d6
    bset #12,%d6
    moveaw #32767,%a4
    subl %d4,%d4
    subl %d5,%d5
    lsrw #8,%d1
    andib #96,%d1
    jbne rsrc_PACK_4_368_8A
    rts
rsrc_PACK_4_368_8A:     /* test #96,%d1 */
    cmpib #96,%d1
    jbeq rsrc_PACK_4_368_A4
    tstb %d6
    jbmi rsrc_PACK_4_368_9C
    cmpib #32,%d1
    jbne rsrc_PACK_4_368_A4
    rts
rsrc_PACK_4_368_9C:     /* test #64,%d1 */
    cmpib #64,%d1
    jbne rsrc_PACK_4_368_A4
    rts
rsrc_PACK_4_368_A4:     /* set %d4 */
    moveq #-1,%d4
    moveal %a3,%a4
    clrb %d4
    rts
rsrc_PACK_4_368_AC:     /* call rsrc_PACK_4_43E (loop) */
    jbsr rsrc_PACK_4_43E
rsrc_PACK_4_368_AE:     /* test bit 9 of %d6 */
    btst #9,%d6
    jbeq rsrc_PACK_4_4FA_8C
    movew %a4,%d3
    jbeq rsrc_PACK_4_4FA_8C
    tstl %d4
    jbne rsrc_PACK_4_368_D0
    tstl %d5
    jbne rsrc_PACK_4_368_CA
    subal %a4,%a4
    jbra rsrc_PACK_4_4FA_8C
rsrc_PACK_4_368_CA:     /* loop: subq */
    subqw #1,%a4
    addl %d5,%d5
    addxl %d4,%d4
rsrc_PACK_4_368_D0:     /* from here: jbpl rsrc_PACK_4_368_CA */
    jbpl rsrc_PACK_4_368_CA
    jbra rsrc_PACK_4_4FA_8C

/* subroutine (125 instructions): calls rsrc_PACK_4_2E6 (mechanical summary) */
rsrc_PACK_4_43E:
    movel #15361,%d0
    subl %a4,%d0
    jble rsrc_PACK_4_43E_16
    bset #9,%d6
    moveaw #15361,%a4
    jbsr rsrc_PACK_4_2E6
rsrc_PACK_4_43E_16:     /* set %d0 */
    movel #2047,%d0
    andw %d5,%d0
    andiw #-2048,%d5
    lslw #5,%d0
    swap %d0
    tstl %d7
    sne %d0
    movel %d0,%d7
    tstl %d7
    jbne rsrc_PACK_4_43E_36
    bclr #9,%d6
    jbra rsrc_PACK_4_43E_72
rsrc_PACK_4_43E_36:     /* set bit 12 of %d6 */
    bset #12,%d6
    bftst %d1,17,2
    jbeq rsrc_PACK_4_43E_54
    jbmi rsrc_PACK_4_43E_48
    tstb %d6
    jbpl rsrc_PACK_4_43E_60
    jbra rsrc_PACK_4_43E_72
rsrc_PACK_4_43E_48:     /* test bit 13 of %d1 */
    btst #13,%d1
    jbne rsrc_PACK_4_43E_72
    tstb %d6
    jbpl rsrc_PACK_4_43E_72
    jbra rsrc_PACK_4_43E_60
rsrc_PACK_4_43E_54:     /* from here: addl %d7,%d7 */
    addl %d7,%d7
    jbcc rsrc_PACK_4_43E_72
    jbne rsrc_PACK_4_43E_60
    btst #11,%d5
    jbeq rsrc_PACK_4_43E_72
rsrc_PACK_4_43E_60:     /* clear %d0 */
    moveq #0,%d0
    movel #2048,%d2
    addl %d2,%d5
    addxl %d0,%d4
    jbcc rsrc_PACK_4_43E_72
    roxrl #1,%d4
    addql #1,%a4
rsrc_PACK_4_43E_72:     /* set %a3 */
    moveaw #17406,%a3
    cmpal %a4,%a3
    jblt rsrc_PACK_4_43E_7C
    rts
rsrc_PACK_4_43E_7C:     /* set bit 10 of %d6 */
    bset #10,%d6
    bset #12,%d6
    moveaw #32767,%a4
    subl %d4,%d4
    subl %d5,%d5
    lsrw #8,%d1
    andib #96,%d1
    jbne rsrc_PACK_4_43E_96
    rts
rsrc_PACK_4_43E_96:     /* test #96,%d1 */
    cmpib #96,%d1
    jbeq rsrc_PACK_4_43E_B0
    tstb %d6
    jbmi rsrc_PACK_4_43E_A8
    cmpib #32,%d1
    jbne rsrc_PACK_4_43E_B0
    rts
rsrc_PACK_4_43E_A8:     /* test #64,%d1 */
    cmpib #64,%d1
    jbne rsrc_PACK_4_43E_B0
    rts
rsrc_PACK_4_43E_B0:     /* set %d4 */
    moveq #-1,%d4
    moveal %a3,%a4
    movel #-2048,%d5
    rts

rsrc_PACK_4_4FA:        /* loop: move */
    movel %a4,%d0
    jbpl rsrc_PACK_4_4FA_10
    negl %d0
    bset #9,%d6
    subal %a4,%a4
    jbsr rsrc_PACK_4_2E6
rsrc_PACK_4_4FA_10:     /* test %d7 */
    tstl %d7
    jbne rsrc_PACK_4_4FA_1A
    bclr #9,%d6
    jbra rsrc_PACK_4_4FA_50
rsrc_PACK_4_4FA_1A:     /* set bit 12 of %d6 */
    bset #12,%d6
    bftst %d1,17,2
    jbeq rsrc_PACK_4_4FA_38
    jbmi rsrc_PACK_4_4FA_2C
    tstb %d6
    jbpl rsrc_PACK_4_4FA_44
    jbra rsrc_PACK_4_4FA_50
rsrc_PACK_4_4FA_2C:     /* test bit 13 of %d1 */
    btst #13,%d1
    jbne rsrc_PACK_4_4FA_50
    tstb %d6
    jbpl rsrc_PACK_4_4FA_50
    jbra rsrc_PACK_4_4FA_44
rsrc_PACK_4_4FA_38:     /* from here: addl %d7,%d7 */
    addl %d7,%d7
    jbcc rsrc_PACK_4_4FA_50
    jbne rsrc_PACK_4_4FA_44
    btst #0,%d5
    jbeq rsrc_PACK_4_4FA_50
rsrc_PACK_4_4FA_44:     /* clear %d0 */
    moveq #0,%d0
    addql #1,%d5
    addxl %d0,%d4
    jbcc rsrc_PACK_4_4FA_50
    roxrl #1,%d4
    addql #1,%a4
rsrc_PACK_4_4FA_50:     /* set %a3 */
    moveaw #32767,%a3
    cmpal %a3,%a4
    jblt rsrc_PACK_4_4FA_8C
    bset #10,%d6
    bset #12,%d6
    moveaw %a3,%a4
    subl %d4,%d4
    subl %d5,%d5
    lsrw #8,%d1
    andib #96,%d1
    jbeq rsrc_PACK_4_4FA_8C
    cmpib #96,%d1
    jbeq rsrc_PACK_4_4FA_86
    tstb %d6
    jbmi rsrc_PACK_4_4FA_80
    cmpib #32,%d1
    jbeq rsrc_PACK_4_4FA_8C
    jbra rsrc_PACK_4_4FA_86
rsrc_PACK_4_4FA_80:     /* test #64,%d1 */
    cmpib #64,%d1
    jbeq rsrc_PACK_4_4FA_8C
rsrc_PACK_4_4FA_86:     /* subtract 1 to %a4 */
    subqw #1,%a4
    notl %d4
    notl %d5

/* subroutine (51 instructions) (mechanical summary) */
rsrc_PACK_4_4FA_8C:
    movew %a4,%d3
    moveal %fp@(10),%a3
    tstb %d6
    jbpl rsrc_PACK_4_4FA_9A
    bset #15,%d3
rsrc_PACK_4_4FA_9A:     /* set %a3@+ */
    movew %d3,%a3@+
    btst #21,%d6
    jbeq rsrc_PACK_4_4FA_A4
    addqw #2,%a3
rsrc_PACK_4_4FA_A4:     /* set %a3@+ */
    movel %d4,%a3@+
    movel %d5,%a3@
    jmp %a0@

rsrc_PACK_4_5A4:        /* loop: clr */
    clrw %d7

rsrc_PACK_4_5A6:        /* loop: movea */
    moveaw #2634,%a1
    movew %a1@,%d0
    clrb %d6
    orw %d6,%d0
    movew %d0,%a1@+
    lsrw #8,%d6
    andw %d6,%d0
    jbne rsrc_PACK_4_5A6_1E
rsrc_PACK_4_5A6_12:     /* set %ccr */
    movew %d7,%ccr
    moveml %sp@+,%d0-%a4
    unlk %fp
    rtd #10
rsrc_PACK_4_5A6_1E:     /* address %pc@(rsrc_PACK_4_5A6_12) */
    lea %pc@(rsrc_PACK_4_5A6_12),%a4
rsrc_PACK_4_5C8:        /* loop: move */
    movew %d7,%sp@-
    movew %d0,%sp@-
    pea %sp@
    moveml %fp@(6),%d0-%d3
    moveml %d0-%d3,%sp@-
    addqw #2,%sp
    moveal %a1@,%a1
    jsr %a1@
    movel %sp@+,%d7
    jmp %a4@
rsrc_PACK_4_5E2:        /* set %a1 */
    moveaw #2634,%a1	| 40873F22
    clrw %d7	| 40873F26
    movew %a1@,%d0	| 40873F28
    clrb %d6	| 40873F2A
    orw %d6,%d0	| 40873F2C
    movew %d0,%a1@+	| 40873F2E
    rorw #8,%d6	| 40873F30
    andw %d6,%d0	| 40873F32
    jbne rsrc_PACK_4_602	| 40873F34
rsrc_PACK_4_5F6:        /* set %ccr */
    movew %d7,%ccr	| 40873F36
    moveml %sp@+,%d0-%a4	| 40873F38
    unlk %fp	| 40873F3C
    rtd #6	| 40873F3E
rsrc_PACK_4_602:        /* address %pc@(rsrc_PACK_4_5F6) */
    lea %pc@(rsrc_PACK_4_5F6),%a4	| 40873F42
    jbra rsrc_PACK_4_5C8	| 40873F46

/* subroutine (1 instructions) (mechanical summary) */
rsrc_PACK_4_608:
    addb %d6,%d6	| 40873F48

/* subroutine (4 instructions) (mechanical summary) */
rsrc_PACK_4_60A:
    movel %a2,%d5	| 40873F4A
    movel %d3,%d4	| 40873F4C
    moveal %a3,%a4	| 40873F4E
    jbra rsrc_PACK_4_4FA_8C	| 40873F50

/* Add. */
FP68K_ADD:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_658),%a0
    jbra rsrc_PACK_4_96

/* Add (with the operands' format from the operation word). */
FP68K_ADD_fmt:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_658),%a0
    jbra rsrc_PACK_4_D4

/* Subtract. */
FP68K_SUB:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_654),%a0
    jbra rsrc_PACK_4_96

/* Subtract (with the operands' format from the operation word). */
FP68K_SUB_fmt:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_654),%a0
    jbra rsrc_PACK_4_D4
rsrc_PACK_4_654:        /* (40873F94 eorib #-96,%d6) */
    .short  0x0A06, 0x00A0	| 40873F94 eorib #-96,%d6
rsrc_PACK_4_658:        /* address %pc@(rsrc_PACK_4_5A4) */
    lea %pc@(rsrc_PACK_4_5A4),%a0
    movew %pc@(rsrc_PACK_4_664,%d0:w),%d0
    jmp %pc@(rsrc_PACK_4_658,%d0:w)
rsrc_PACK_4_664:        /* (data) */
    .short  rsrc_PACK_4_676-rsrc_PACK_4_658	| 40873FA4
    .short  rsrc_PACK_4_86A-rsrc_PACK_4_658	| 40873FA6
    .short  rsrc_PACK_4_4FA_8C-rsrc_PACK_4_658	| 40873FA8
    .short  rsrc_PACK_4_872-rsrc_PACK_4_658	| 40873FAA
    .short  rsrc_PACK_4_848-rsrc_PACK_4_658	| 40873FAC
    .short  rsrc_PACK_4_4FA_8C-rsrc_PACK_4_658	| 40873FAE
    .short  rsrc_PACK_4_608-rsrc_PACK_4_658	| 40873FB0
    .short  rsrc_PACK_4_608-rsrc_PACK_4_658	| 40873FB2
    .short  rsrc_PACK_4_876-rsrc_PACK_4_658	| 40873FB4

/* subroutine (22 instructions) (mechanical summary) */
rsrc_PACK_4_676:
    exg %d4,%d3	| 40873FB6
    exg %d5,%a2	| 40873FB8
    movew %a4,%d0	| 40873FBA
    subw %a3,%d0	| 40873FBC
    jbeq rsrc_PACK_4_812	| 40873FBE
    jbgt rsrc_PACK_4_690	| 40873FC2
    exg %d5,%a2	| 40873FC4
    exg %d4,%d3	| 40873FC6
    moveal %a3,%a4	| 40873FC8
    addb %d6,%d6	| 40873FCA
    negw %d0	| 40873FCC
    asrb #1,%d6	| 40873FCE
rsrc_PACK_4_690:        /* set %d2 */
    movel %d0,%d2	| 40873FD0
    cmpiw #66,%d0	| 40873FD2
    jbhi rsrc_PACK_4_72A	| 40873FD6
    addw %d2,%d2	| 40873FDA
    movew %pc@(rsrc_PACK_4_6A4,%d2:w),%d2	| 40873FDC
    jmp %pc@(rsrc_PACK_4_676,%d2:w)	| 40873FE0
rsrc_PACK_4_6A4:        /* (data) */
    .short  rsrc_PACK_4_812-rsrc_PACK_4_676	| 40873FE4
    .short  rsrc_PACK_4_80C-rsrc_PACK_4_676	| 40873FE6
    .short  rsrc_PACK_4_7FE-rsrc_PACK_4_676	| 40873FE8
    .short  rsrc_PACK_4_7F0-rsrc_PACK_4_676	| 40873FEA
    .short  rsrc_PACK_4_7E2-rsrc_PACK_4_676	| 40873FEC
    .short  rsrc_PACK_4_7D4-rsrc_PACK_4_676	| 40873FEE
    .short  rsrc_PACK_4_7C6-rsrc_PACK_4_676	| 40873FF0
    .short  rsrc_PACK_4_7B8-rsrc_PACK_4_676	| 40873FF2
    .short  rsrc_PACK_4_7AC-rsrc_PACK_4_676	| 40873FF4
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40873FF6
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40873FF8
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40873FFA
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40873FFC
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40873FFE
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874000
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874002
    .short  rsrc_PACK_4_79E-rsrc_PACK_4_676	| 40874004
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874006
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874008
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 4087400A
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 4087400C
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 4087400E
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874010
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874012
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874014
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874016
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874018
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 4087401A
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 4087401C
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 4087401E
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874020
    .short  rsrc_PACK_4_790-rsrc_PACK_4_676	| 40874022
    .short  rsrc_PACK_4_786-rsrc_PACK_4_676	| 40874024
    .short  rsrc_PACK_4_776-rsrc_PACK_4_676	| 40874026
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874028
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087402A
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087402C
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087402E
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874030
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874032
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874034
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874036
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874038
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087403A
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087403C
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087403E
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874040
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874042
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874044
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874046
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874048
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087404A
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087404C
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087404E
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874050
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874052
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874054
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874056
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874058
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087405A
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087405C
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 4087405E
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874060
    .short  rsrc_PACK_4_756-rsrc_PACK_4_676	| 40874062
    .short  rsrc_PACK_4_748-rsrc_PACK_4_676	| 40874064
    .short  rsrc_PACK_4_73E-rsrc_PACK_4_676	| 40874066
    .short  rsrc_PACK_4_734-rsrc_PACK_4_676	| 40874068
rsrc_PACK_4_72A:        /* clear %d4 */
    moveq #0,%d4
    moveq #0,%d5
    notb %d7
    jbra rsrc_PACK_4_812

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_734:
    orw %d4,%d5	| 40874074
    tstl %d5	| 40874076
    sne %d7	| 40874078
    lsrl #2,%d4	| 4087407A
    jbra rsrc_PACK_4_74C	| 4087407C

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_73E:
    orw %d4,%d5	| 4087407E
    tstl %d5	| 40874080
    sne %d7	| 40874082
    lsrl #1,%d4	| 40874084
    jbra rsrc_PACK_4_74C	| 40874086

/* subroutine (6 instructions) (mechanical summary) */
rsrc_PACK_4_748:
    tstl %d5	| 40874088
    sne %d7	| 4087408A
rsrc_PACK_4_74C:        /* from here: orl %d4,%d7 */
    orl %d4,%d7	| 4087408C
    moveq #0,%d4
    moveq #0,%d5
    jbra rsrc_PACK_4_812

/* subroutine (11 instructions) (mechanical summary) */
rsrc_PACK_4_756:
    movel %d5,%d7	| 40874096
    subiw #32,%d0	| 40874098
    movel %d4,%d5	| 4087409C
    rorl %d0,%d7	| 4087409E
    lsrl %d0,%d5	| 408740A0
    bftst %d7,0,%d0	| 408740A2
    jbeq rsrc_PACK_4_76C	| 408740A6
    oriw #255,%d7	| 408740A8
rsrc_PACK_4_76C:        /* from here: bfins %d4,%d7,0,%d0 */
    bfins %d4,%d7,0,%d0	| 408740AC
    moveq #0,%d4	| 408740B0
    jbra rsrc_PACK_4_812	| 408740B2

/* subroutine (7 instructions) (mechanical summary) */
rsrc_PACK_4_776:
    movel %d5,%d7	| 408740B6
    movel %d4,%d5	| 408740B8
    moveq #0,%d4	| 408740BA
    lsrl #1,%d5	| 408740BC
    roxrl #1,%d7	| 408740BE
    scs %d7	| 408740C0
    jbra rsrc_PACK_4_812	| 408740C2

/* subroutine (4 instructions) (mechanical summary) */
rsrc_PACK_4_786:
    movel %d5,%d7	| 408740C6
    movel %d4,%d5	| 408740C8
    moveq #0,%d4	| 408740CA
    jbra rsrc_PACK_4_812	| 408740CC

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_790:
    bfins %d5,%d7,0,%d0	| 408740D0
    lsrl %d0,%d5	| 408740D4
    bfins %d4,%d5,0,%d0	| 408740D6
    lsrl %d0,%d4	| 408740DA
    jbra rsrc_PACK_4_812	| 408740DC

/* subroutine (7 instructions) (mechanical summary) */
rsrc_PACK_4_79E:
    movew %d5,%d7	| 408740DE
    movew %d4,%d5	| 408740E0
    clrw %d4	| 408740E2
    swap %d5	| 408740E4
    swap %d4	| 408740E6
    swap %d7	| 408740E8
    jbra rsrc_PACK_4_812	| 408740EA

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_7AC:
    bfins %d5,%d7,0,8	| 408740EC
    moveb %d4,%d5	| 408740F0
    lsrl #8,%d4	| 408740F2
    rorl #8,%d5	| 408740F4
    jbra rsrc_PACK_4_812	| 408740F6

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_7B8:
    bfins %d5,%d7,0,7	| 408740F8
    lsrl #7,%d5	| 408740FC
    bfins %d4,%d5,0,7	| 408740FE
    lsrl #7,%d4	| 40874102
    jbra rsrc_PACK_4_812	| 40874104

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_7C6:
    bfins %d5,%d7,0,6	| 40874106
    lsrl #6,%d5	| 4087410A
    bfins %d4,%d5,0,6	| 4087410C
    lsrl #6,%d4	| 40874110
    jbra rsrc_PACK_4_812	| 40874112

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_7D4:
    bfins %d5,%d7,0,5	| 40874114
    lsrl #5,%d5	| 40874118
    bfins %d4,%d5,0,5	| 4087411A
    lsrl #5,%d4	| 4087411E
    jbra rsrc_PACK_4_812	| 40874120

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_7E2:
    bfins %d5,%d7,0,4	| 40874122
    lsrl #4,%d5	| 40874126
    bfins %d4,%d5,0,4	| 40874128
    lsrl #4,%d4	| 4087412C
    jbra rsrc_PACK_4_812	| 4087412E

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_7F0:
    bfins %d5,%d7,0,3	| 40874130
    lsrl #3,%d5	| 40874134
    bfins %d4,%d5,0,3	| 40874136
    lsrl #3,%d4	| 4087413A
    jbra rsrc_PACK_4_812	| 4087413C

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_7FE:
    bfins %d5,%d7,0,2	| 4087413E
    lsrl #2,%d5	| 40874142
    bfins %d4,%d5,0,2	| 40874144
    lsrl #2,%d4	| 40874148
    jbra rsrc_PACK_4_812	| 4087414A

/* subroutine (3 instructions) (mechanical summary) */
rsrc_PACK_4_80C:
    lsrl #1,%d4	| 4087414C
    roxrl #1,%d5	| 4087414E
    roxrl #1,%d7	| 40874150

/* subroutine (22 instructions) (mechanical summary) */
rsrc_PACK_4_812:
    btst #5,%d6
    jbne rsrc_PACK_4_830
    addl %a2,%d5
    addxl %d3,%d4
    jbcc rsrc_PACK_4_352
    roxrl #1,%d4
    roxrl #1,%d5
    roxrl #1,%d7
    scs %d1
    orb %d1,%d7
    addql #1,%a4
    jbra rsrc_PACK_4_352
rsrc_PACK_4_830:        /* from here: notb %d6 */
    notb %d6
    subl %a2,%d5
    subxl %d3,%d4
    jbeq rsrc_PACK_4_850
    jbcc rsrc_PACK_4_2E6_5E
    negl %d7
    negxl %d5
    negxl %d4
    notb %d6
    jbra rsrc_PACK_4_2E6_5E

/* subroutine (11 instructions) (mechanical summary) */
rsrc_PACK_4_848:
    btst #5,%d6	| 40874188
    jbeq rsrc_PACK_4_4FA_8C	| 4087418C
rsrc_PACK_4_850:        /* from here: subal %a4,%a4 */
    subal %a4,%a4
    moveaw #2634,%a1
    clrb %d6
    btst #6,%a1@
    jbeq rsrc_PACK_4_866
    btst #5,%a1@
    jbne rsrc_PACK_4_866
    notb %d6
rsrc_PACK_4_866:        /* continue at rsrc_PACK_4_4FA_8C */
    jbra rsrc_PACK_4_4FA_8C

/* subroutine (4 instructions) (mechanical summary) */
rsrc_PACK_4_86A:
    movel %a2,%d5	| 408741AA
    movel %d3,%d4	| 408741AC
    moveal %a3,%a4	| 408741AE
    addb %d6,%d6	| 408741B0

/* subroutine (1 instructions) (mechanical summary) */
rsrc_PACK_4_872:
    jbra rsrc_PACK_4_352	| 408741B2

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_876:
    btst #5,%d6	| 408741B6
    jbne rsrc_PACK_4_880	| 408741BA
    jbra rsrc_PACK_4_4FA_8C	| 408741BC
rsrc_PACK_4_880:        /* result 2 */
    moveq #2,%d0	| 408741C0
    jbra rsrc_PACK_4_D4_38	| 408741C2

/* Multiply. */
FP68K_MUL:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(FP68K_MUL_fmt_10),%a0
    jbra rsrc_PACK_4_96

/* Multiply (with the operands' format from the operation word). */
FP68K_MUL_fmt:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(FP68K_MUL_fmt_10),%a0
    jbra rsrc_PACK_4_D4
FP68K_MUL_fmt_10:       /* address %pc@(rsrc_PACK_4_5A4) */
    lea %pc@(rsrc_PACK_4_5A4),%a0
    lslb #2,%d6
    movew %pc@(rsrc_PACK_4_8B4,%d0:w),%d0
    jmp %pc@(FP68K_MUL_fmt_10,%d0:w)
rsrc_PACK_4_8B4:        /* (data) */
    .short  rsrc_PACK_4_8C6-FP68K_MUL_fmt_10	| 408741F4
    .short  rsrc_PACK_4_4FA_8C-FP68K_MUL_fmt_10	| 408741F6
    .short  rsrc_PACK_4_4FA_8C-FP68K_MUL_fmt_10	| 408741F8
    .short  rsrc_PACK_4_60A-FP68K_MUL_fmt_10	| 408741FA
    .short  rsrc_PACK_4_4FA_8C-FP68K_MUL_fmt_10	| 408741FC
    .short  rsrc_PACK_4_916-FP68K_MUL_fmt_10	| 408741FE
    .short  rsrc_PACK_4_60A-FP68K_MUL_fmt_10	| 40874200
    .short  rsrc_PACK_4_916-FP68K_MUL_fmt_10	| 40874202
    .short  rsrc_PACK_4_4FA_8C-FP68K_MUL_fmt_10	| 40874204

/* subroutine (34 instructions) (mechanical summary) */
rsrc_PACK_4_8C6:
    addal %a3,%a4	| 40874206
    subaw #16382,%a4	| 40874208
    movel %d3,%d2	| 4087420C
    movel %a2,%d3	| 4087420E
    moveal %d6,%a1	| 40874210
    moveal %d4,%a2	| 40874212
    moveal %d5,%a3	| 40874214
    moveq #0,%d7
    moveq #0,%d6
    movel %a2,%d5
    mulul %d2,%d4,%d5
    movel %a3,%d7
    jbeq rsrc_PACK_4_8EC
    mulul %d2,%d0,%d7
    addl %d0,%d5
    addxl %d6,%d4
rsrc_PACK_4_8EC:        /* set %d0 */
    movel %d3,%d0
    jbeq rsrc_PACK_4_910
    movel %a2,%d1
    mulul %d0,%d0,%d1
    addl %d1,%d7
    addxl %d0,%d5
    addxl %d6,%d4
    movel %a3,%d1
    jbeq rsrc_PACK_4_910
    mulul %d3,%d0,%d1
    addl %d0,%d7
    addxl %d6,%d5
    addxl %d6,%d4
    tstl %d1
    sne %d1
    orb %d1,%d7
rsrc_PACK_4_910:        /* set %d6 */
    movel %a1,%d6
    jbra rsrc_PACK_4_2E6_5E

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_4_916:
    moveq #8,%d0	| 40874256
    jbra rsrc_PACK_4_D4_38	| 40874258

/* Divide. */
FP68K_DIV:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(FP68K_DIV_fmt_10),%a0
    jbra rsrc_PACK_4_96

/* Divide (with the operands' format from the operation word). */
FP68K_DIV_fmt:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(FP68K_DIV_fmt_10),%a0
    jbra rsrc_PACK_4_D4
FP68K_DIV_fmt_10:       /* address %pc@(rsrc_PACK_4_5A4) */
    lea %pc@(rsrc_PACK_4_5A4),%a0
    lslb #2,%d6
    movew %pc@(rsrc_PACK_4_94A,%d0:w),%d0
    jmp %pc@(FP68K_DIV_fmt_10,%d0:w)
rsrc_PACK_4_94A:        /* (data) */
    .short  rsrc_PACK_4_97C-FP68K_DIV_fmt_10	| 4087428A
    .short  rsrc_PACK_4_95C-FP68K_DIV_fmt_10	| 4087428C
    .short  rsrc_PACK_4_96C-FP68K_DIV_fmt_10	| 4087428E
    .short  rsrc_PACK_4_96C-FP68K_DIV_fmt_10	| 40874290
    .short  rsrc_PACK_4_976-FP68K_DIV_fmt_10	| 40874292
    .short  rsrc_PACK_4_96C-FP68K_DIV_fmt_10	| 40874294
    .short  rsrc_PACK_4_60A-FP68K_DIV_fmt_10	| 40874296
    .short  rsrc_PACK_4_60A-FP68K_DIV_fmt_10	| 40874298
    .short  rsrc_PACK_4_976-FP68K_DIV_fmt_10	| 4087429A

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_95C:
    bset #11,%d6	| 4087429C
    moveaw #32767,%a4	| 408742A0
    moveq #0,%d4
    moveq #0,%d5
    jbra rsrc_PACK_4_4FA_8C

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_4_96C:
    .long   0x99CC280C	| 408742AC
    .byte   0x2A, 0x04, 0x60, 0x00, 0xFC, 0x12	| 408742B0

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_4_976:
    .byte   0x70, 0x04, 0x60, 0x00, 0xF7, 0x92	| 408742B6

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_4_97C:
    .byte   0xC7, 0x4C, 0x99, 0xCB	| 408742BC
    lea %a4@(16383),%a4
    moveal %d6,%a3
    movel %d3,%d2
    movel %a2,%d3
    moveq #0,%d1
    movel %d2,%d6
    subl %d5,%d3
    subxl %d4,%d2
    bccs rsrc_PACK_4_97C_1E
    subql #1,%a4
    addl %a2,%d3
    addxl %d6,%d2
rsrc_PACK_4_97C_1E:
    bsrs rsrc_PACK_4_9B8
    moveal %d0,%a2
    bsrs rsrc_PACK_4_9B8
    movel %d0,%d5
    movel %a2,%d4
    movel %a3,%d6
    moveq #1,%d7
    lsrl #1,%d7
    roxrl #1,%d4
    roxrl #1,%d5
    roxrl #1,%d7
    orl %d2,%d3
    sne %d7
    braw rsrc_PACK_4_352

/* subroutine (19 instructions) (mechanical summary) */
rsrc_PACK_4_9B8:
    divul %d4,%d2,%d3
    jbvs rsrc_PACK_4_9B8_20
    movel %d3,%d0
    movel %d3,%d7
    mulul %d5,%d6,%d7
rsrc_PACK_4_9B8_E:      /* loop: move */
    movel %d1,%d3
    subl %d7,%d3
    subxl %d6,%d2
    jbcc rsrc_PACK_4_9B8_1E
rsrc_PACK_4_9B8_16:     /* loop: subq */
    subql #1,%d0
    addl %d5,%d3
    addxl %d4,%d2
    jbcc rsrc_PACK_4_9B8_16
rsrc_PACK_4_9B8_1E:     /* return */
    rts
rsrc_PACK_4_9B8_20:     /* set %d6 */
    movel %d5,%d6
    moveq #0,%d7
    movel %d3,%d2
    moveq #0,%d0
    jbra rsrc_PACK_4_9B8_E

/* Remainder. */
FP68K_REM:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(FP68K_REM_fmt_10),%a0
    jbra rsrc_PACK_4_96

/* Remainder (with the operands' format from the operation word). */
FP68K_REM_fmt:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(FP68K_REM_fmt_10),%a0
    jbra rsrc_PACK_4_D4
FP68K_REM_fmt_10:       /* address %pc@(rsrc_PACK_4_5A4) */
    lea %pc@(rsrc_PACK_4_5A4),%a0
    clrw %sp@(2)
    addb %d6,%d6
    movew %pc@(rsrc_PACK_4_A14,%d0:w),%d0
    jmp %pc@(FP68K_REM_fmt_10,%d0:w)
rsrc_PACK_4_A14:        /* (data) */
    .short  rsrc_PACK_4_A2C-FP68K_REM_fmt_10	| 40874354
    .short  rsrc_PACK_4_A26-FP68K_REM_fmt_10	| 40874356
    .short  rsrc_PACK_4_A34-FP68K_REM_fmt_10	| 40874358
    .short  rsrc_PACK_4_60A-FP68K_REM_fmt_10	| 4087435A
    .short  rsrc_PACK_4_A26-FP68K_REM_fmt_10	| 4087435C
    .short  rsrc_PACK_4_60A-FP68K_REM_fmt_10	| 4087435E
    .short  rsrc_PACK_4_A26-FP68K_REM_fmt_10	| 40874360
    .short  rsrc_PACK_4_A26-FP68K_REM_fmt_10	| 40874362
    .short  rsrc_PACK_4_A26-FP68K_REM_fmt_10	| 40874364

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_4_A26:
    moveq #9,%d0	| 40874366
    jbra rsrc_PACK_4_D4_38	| 40874368

/* subroutine (4 instructions) (mechanical summary) */
rsrc_PACK_4_A2C:
    movel %a3,%d0	| 4087436C
    addql #1,%d0	| 4087436E
    subl %a4,%d0	| 40874370
    jbpl rsrc_PACK_4_A3C	| 40874372

/* subroutine (36 instructions): calls rsrc_PACK_4_A8C (mechanical summary) */
rsrc_PACK_4_A34:
    movel %d3,%d4	| 40874374
    movel %a2,%d5	| 40874376
    moveal %a3,%a4	| 40874378
    jbra rsrc_PACK_4_A88	| 4087437A
rsrc_PACK_4_A3C:        /* subtract 1 to %a4 */
    subql #1,%a4	| 4087437C
    cmpil #9,%d0	| 4087437E
    jbgt rsrc_PACK_4_AB0	| 40874384
    movel %d3,%d1	| 40874386
    movel %a2,%d2	| 40874388
    movel %d4,%d3	| 4087438A
    moveal %d5,%a2	| 4087438C
    addql #1,%d0	| 4087438E
    jbsr rsrc_PACK_4_A8C	| 40874390
rsrc_PACK_4_A52:        /* loop: btst */
    btst #0,%d5
    jbeq rsrc_PACK_4_A74
    tstl %d1
    jbne rsrc_PACK_4_A66
    tstl %d2
    jbne rsrc_PACK_4_A66
    btst #1,%d5
    jbeq rsrc_PACK_4_A6C
rsrc_PACK_4_A66:        /* flip bit 7 of %d6 */
    bchg #7,%d6
    addqw #2,%d5
rsrc_PACK_4_A6C:        /* from here: exg %d2,%a2 */
    exg %d2,%a2
    exg %d1,%d3
    subl %a2,%d2
    subxl %d3,%d1
rsrc_PACK_4_A74:        /* from here: lsrb #1,%d5 */
    lsrb #1,%d5
    btst #6,%d6
    jbeq rsrc_PACK_4_A7E
    negb %d5
rsrc_PACK_4_A7E:        /* from here: extw %d5 */
    extw %d5
    movew %d5,%sp@(2)
    movel %d1,%d4
    movel %d2,%d5
rsrc_PACK_4_A88:        /* continue at rsrc_PACK_4_2E6_3C */
    jbra rsrc_PACK_4_2E6_3C

/* subroutine (46 instructions): calls rsrc_PACK_4_9B8 (mechanical summary) */
rsrc_PACK_4_A8C:
    moveq #0,%d4	| 408743CC
    movel %d4,%d5	| 408743CE
    jbra rsrc_PACK_4_A9C	| 408743D0
rsrc_PACK_4_A92:        /* loop: add */
    addl %d5,%d5	| 408743D2
    addxl %d4,%d4	| 408743D4
    addl %d2,%d2	| 408743D6
    addxl %d1,%d1	| 408743D8
    jbcs rsrc_PACK_4_AA4	| 408743DA
rsrc_PACK_4_A9C:        /* test %d3,%d1 */
    cmpl %d3,%d1	| 408743DC
    jbne rsrc_PACK_4_AA2	| 408743DE
    cmpl %a2,%d2	| 408743E0
rsrc_PACK_4_AA2:        /* from here: jbcs rsrc_PACK_4_AAA */
    jbcs rsrc_PACK_4_AAA	| 408743E2
rsrc_PACK_4_AA4:        /* add 1 to %d5 */
    addqb #1,%d5	| 408743E4
    subl %a2,%d2	| 408743E6
    subxl %d3,%d1	| 408743E8
rsrc_PACK_4_AAA:        /* subtract 1 to %d0 */
    subqw #1,%d0	| 408743EA
    jbne rsrc_PACK_4_A92	| 408743EC
    rts	| 408743EE
rsrc_PACK_4_AB0:        /* set %a3 */
    moveal %d6,%a3	| 408743F0
    movel %a2,%d1	| 408743F2
    moveq #0,%d2	| 408743F4
    moveal %d0,%a2	| 408743F6
    andil #31,%d0	| 408743F8
    jbeq rsrc_PACK_4_ACE	| 408743FE
    bfextu %d3,0,%d0,%d2	| 40874400
    lsll %d0,%d3	| 40874404
    bfextu %d1,0,%d0,%d6	| 40874406
    lsll %d0,%d1	| 4087440A
    orl %d6,%d3	| 4087440C
rsrc_PACK_4_ACE:        /* call rsrc_PACK_4_9B8 */
    jbsr rsrc_PACK_4_9B8	| 4087440E
    movel %a2,%d6	| 40874412
    bfextu %d6,16,11,%d6	| 40874414
    jbeq rsrc_PACK_4_AE8	| 40874418
    moveal %d6,%a1	| 4087441A
    moveq #0,%d1
rsrc_PACK_4_ADE:        /* call rsrc_PACK_4_9B8 (loop) */
    jbsr rsrc_PACK_4_9B8
    subql #1,%a1
    movel %a1,%d6
    jbne rsrc_PACK_4_ADE
rsrc_PACK_4_AE8:        /* set %d1 */
    movel %d2,%d1
    movel %d3,%d2
    movel %d4,%d3
    moveal %d5,%a2
    movel %d0,%d5
    movel %a3,%d6
    jbra rsrc_PACK_4_A52

/* Compare (CMP quiet, CPX signalling on unordered). */
FP68K_CMP_CPX:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(FP68K_CMP_CPX_fmt_10),%a0
    jbra rsrc_PACK_4_96

/* Compare (CMP quiet, CPX signalling on unordered) (with the operands' format from the operation word). */
FP68K_CMP_CPX_fmt:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(FP68K_CMP_CPX_fmt_10),%a0
    jbra rsrc_PACK_4_D4
FP68K_CMP_CPX_fmt_10:   /* set %d0 */
    movew %pc@(rsrc_PACK_4_B20,%d0:w),%d0
    jmp %pc@(FP68K_CMP_CPX_fmt_10,%d0:w)
rsrc_PACK_4_B20:        /* (data) */
    .short  rsrc_PACK_4_B4E-FP68K_CMP_CPX_fmt_10	| 40874460
    .short  rsrc_PACK_4_B32-FP68K_CMP_CPX_fmt_10	| 40874462
    .short  rsrc_PACK_4_B36-FP68K_CMP_CPX_fmt_10	| 40874464
    .short  rsrc_PACK_4_B36-FP68K_CMP_CPX_fmt_10	| 40874466
    .short  rsrc_PACK_4_B48-FP68K_CMP_CPX_fmt_10	| 40874468
    .short  rsrc_PACK_4_B36-FP68K_CMP_CPX_fmt_10	| 4087446A
    .short  rsrc_PACK_4_B32-FP68K_CMP_CPX_fmt_10	| 4087446C
    .short  rsrc_PACK_4_B32-FP68K_CMP_CPX_fmt_10	| 4087446E
    .short  rsrc_PACK_4_B42-FP68K_CMP_CPX_fmt_10	| 40874470

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_4_B32:
    addb %d6,%d6	| 40874472
    notb %d6	| 40874474

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_4_B36:
    moveq #0,%d7	| 40874476
    tstb %d6	| 40874478
    jbmi rsrc_PACK_4_B3E	| 4087447A
    moveq #25,%d7	| 4087447C
rsrc_PACK_4_B3E:        /* continue at rsrc_PACK_4_5A6 */
    jbra rsrc_PACK_4_5A6	| 4087447E

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_4_B42:
    btst #5,%d6	| 40874482
    jbne rsrc_PACK_4_B36	| 40874486

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_4_B48:
    moveq #4,%d7
    jbra rsrc_PACK_4_5A6

/* subroutine (17 instructions) (mechanical summary) */
rsrc_PACK_4_B4E:
    btst #5,%d6	| 4087448E
    jbne rsrc_PACK_4_B36	| 40874492
    cmpal %a4,%a3	| 40874494
    jbgt rsrc_PACK_4_B66	| 40874496
    jblt rsrc_PACK_4_B68	| 40874498
    cmpl %d4,%d3	| 4087449A
    jbhi rsrc_PACK_4_B66	| 4087449C
    jbcs rsrc_PACK_4_B68	| 4087449E
    cmpal %d5,%a2	| 408744A0
    jbeq rsrc_PACK_4_B48	| 408744A2
    jbcs rsrc_PACK_4_B68	| 408744A4
rsrc_PACK_4_B66:        /* from here: notb %d6 */
    notb %d6	| 408744A6
rsrc_PACK_4_B68:        /* set %d7 */
    moveq #25,%d7	| 408744A8
    tstb %d6	| 408744AA
    jbpl rsrc_PACK_4_5A6	| 408744AC
    moveq #0,%d7	| 408744B0
    jbra rsrc_PACK_4_5A6	| 408744B2

/* Convert between formats (to or from extended). */
FP68K_X2X:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_5A4),%a0
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    moveal %fp@(14),%a1
    jbsr rsrc_PACK_4_176
FP68K_X2X_1E:           /* loop: moveq */
    moveq #0,%d7
    tstw %d0
    jbne rsrc_PACK_4_D4_88
    tstl %d0
    jbeq rsrc_PACK_4_352
    jbra rsrc_PACK_4_4FA_8C

/* Convert an integer or comp to extended (with the operands' format from the operation word). */
FP68K_Z2X_fmt:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_5A4),%a0
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    movel %d6,%d1
    clrw %d1
    roll #6,%d1
    andiw #14,%d1
    subqw #2,%d1
    moveal %fp@(14),%a1
    jbsr rsrc_PACK_4_1E0
    jbra FP68K_X2X_1E

/* Square root. */
FP68K_SQRT:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_5E2),%a0
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    moveal %fp@(10),%a1
    jbsr rsrc_PACK_4_176
    tstl %d0
    jbeq FP68K_SQRT_3C
    tstw %d0
    jbne rsrc_PACK_4_D4_88
    btst #17,%d0
    jbne rsrc_PACK_4_4FA_8C
    tstb %d6
    jbpl rsrc_PACK_4_4FA_8C
FP68K_SQRT_36:          /* result 1 */
    moveq #1,%d0
    jbra rsrc_PACK_4_D4_38
FP68K_SQRT_3C:          /* test %d6 */
    tstb %d6
    jbmi FP68K_SQRT_36
    movew %a4,%d0
    asrw #1,%d0
    movew %sr,%d7
    jbcc FP68K_SQRT_4A
    addqw #1,%d0
FP68K_SQRT_4A:          /* from here: addiw #8191,%d0 */
    addiw #8191,%d0
    moveaw %d0,%a4
    moveal %d6,%a3
    movel %d5,%d3
    movel %d4,%d2
    addl %d3,%d3
    addxl %d2,%d2
    moveq #1,%d1
    movew %d7,%ccr
    jbcs FP68K_SQRT_66
    addl %d3,%d3
    addxl %d2,%d2
    addxw %d1,%d1
FP68K_SQRT_66:          /* subtract 1 to %d1 */
    subqw #1,%d1
    moveq #1,%d0
    moveq #0,%d4
    movel %d4,%d5
    movel #1073741824,%d6
    jbra FP68K_SQRT_7C
FP68K_SQRT_76:          /* loop: add */
    addl %d3,%d3
    addxl %d2,%d2
    addxw %d1,%d1
FP68K_SQRT_7C:          /* from here: orl %d6,%d4 */
    orl %d6,%d4
    subl %d4,%d2
    subxw %d0,%d1
    jbcc FP68K_SQRT_8C
    addl %d4,%d2
    addxw %d0,%d1
    eorl %d6,%d4
    jbra FP68K_SQRT_8E
FP68K_SQRT_8C:          /* from here: addl %d6,%d4 */
    addl %d6,%d4
FP68K_SQRT_8E:          /* from here: lsrl #1,%d6 */
    lsrl #1,%d6
    jbcc FP68K_SQRT_76
    movel #-2147483648,%d6
    addl %d3,%d3
    addxl %d2,%d2
    addxw %d1,%d1
    subl %d6,%d3
    subxl %d4,%d2
    subxw %d0,%d1
    jbcc FP68K_SQRT_AE
    addl %d6,%d3
    addxl %d4,%d2
    addxw %d0,%d1
    jbra FP68K_SQRT_B0
FP68K_SQRT_AE:          /* add 1 to %d4 */
    addqw #1,%d4
FP68K_SQRT_B0:          /* set %d7 */
    movel %d3,%d7
    orw %d1,%d7
    orl %d2,%d7
    jbne FP68K_SQRT_C0
    lsrw #1,%d0
    roxrl #1,%d4
    roxrl #1,%d5
    jbra FP68K_SQRT_FC
FP68K_SQRT_C0:          /* from here: rorl #1,%d6 */
    rorl #1,%d6
FP68K_SQRT_C2:          /* loop: add */
    addl %d3,%d3
    addxl %d2,%d2
    addxw %d1,%d1
    orl %d6,%d5
    subl %d5,%d3
    subxl %d4,%d2
    subxw %d0,%d1
    jbcc FP68K_SQRT_DC
    addl %d5,%d3
    addxl %d4,%d2
    addxw %d0,%d1
    eorl %d6,%d5
    jbra FP68K_SQRT_DE
FP68K_SQRT_DC:          /* from here: addl %d6,%d5 */
    addl %d6,%d5
FP68K_SQRT_DE:          /* from here: lsrl #1,%d6 */
    lsrl #1,%d6
    jbcc FP68K_SQRT_C2
    moveq #0,%d7
    addqw #1,%d5
    lsrw #1,%d0
    roxrl #1,%d4
    roxrl #1,%d5
    subxl %d5,%d3
    subxl %d4,%d2
    subxw %d7,%d1
    jbcs FP68K_SQRT_F8
    bset #31,%d7
FP68K_SQRT_F8:          /* from here: addiw #255,%d7 */
    addiw #255,%d7
FP68K_SQRT_FC:          /* set %d6 */
    movel %a3,%d6
    jbra rsrc_PACK_4_352

/* Round to an integral value. */
FP68K_RINT:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_5E2),%a0
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    moveal %fp@(10),%a1
    jbsr rsrc_PACK_4_176
    tstl %d0
    jbeq FP68K_RINT_2C
    tstw %d0
    jbne rsrc_PACK_4_D4_88
    jbra rsrc_PACK_4_4FA_8C
FP68K_RINT_2C:          /* call rsrc_PACK_4_D96 */
    jbsr rsrc_PACK_4_D96
    jbgt FP68K_RINT_42
FP68K_RINT_32:          /* loop: bftst */
    bftst %d1,25,2
    jbeq rsrc_PACK_4_4FA
    jbpl rsrc_PACK_4_368_AC
    jbra rsrc_PACK_4_352_10
FP68K_RINT_42:          /* call rsrc_PACK_4_DD6 */
    jbsr rsrc_PACK_4_DD6
    tstl %d4
    jbmi rsrc_PACK_4_4FA_8C
FP68K_RINT_4C:          /* loop: bfffo */
    bfffo %d4,0,0,%d0
    jbeq FP68K_RINT_62
    subaw %d0,%a4
    lsll %d0,%d4
    bfextu %d5,0,%d0,%d2
    lsll %d0,%d5
    orl %d2,%d4
    jbra rsrc_PACK_4_4FA_8C
FP68K_RINT_62:          /* from here: subaw #32,%a4 */
    subaw #32,%a4
    exg %d4,%d5
    bfffo %d4,0,0,%d0
    jbeq FP68K_RINT_7A
    jbmi rsrc_PACK_4_4FA_8C
    subaw %d0,%a4
    lsll %d0,%d4
    jbra rsrc_PACK_4_4FA_8C
FP68K_RINT_7A:          /* from here: subal %a4,%a4 */
    subal %a4,%a4
    jbra rsrc_PACK_4_4FA_8C

/* Truncate to an integral value. */
FP68K_TINT:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_5E2),%a0
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    moveal %fp@(10),%a1
    jbsr rsrc_PACK_4_176
    tstl %d0
    jbeq FP68K_TINT_2C
    tstw %d0
    jbne rsrc_PACK_4_D4_88
    jbra rsrc_PACK_4_4FA_8C
FP68K_TINT_2C:          /* call rsrc_PACK_4_D96 */
    jbsr rsrc_PACK_4_D96
    jbgt FP68K_TINT_38
    oriw #24576,%d1
    jbra FP68K_RINT_32
FP68K_TINT_38:          /* test %d7 */
    tstl %d7
    jbeq FP68K_RINT_4C
    bset #12,%d6
    jbra FP68K_RINT_4C

/* subroutine (14 instructions): low memory FPState (mechanical summary) */
rsrc_PACK_4_D96:
    movew FPState,%d1
    bftst %d1,25,2
    jbeq rsrc_PACK_4_DBC
    jbmi rsrc_PACK_4_D96_12
    movew #16435,%d0
    jbra rsrc_PACK_4_D96_16
rsrc_PACK_4_D96_12:     /* set %d0 */
    movew #16406,%d0
rsrc_PACK_4_D96_16:     /* clear %d7 */
    moveq #0,%d7
    cmpw %a4,%d0
    jbgt rsrc_PACK_4_D96_1E
    rts
rsrc_PACK_4_D96_1E:     /* set %d0 */
    movew #16446,%d0
    subw %a4,%d0
    jbra rsrc_PACK_4_DC8

/* subroutine (9 instructions): calls rsrc_PACK_4_2E6 (mechanical summary) */
rsrc_PACK_4_DBC:
    movew #16446,%d0
    moveq #0,%d7
    subw %a4,%d0
    jbgt rsrc_PACK_4_DC8
    rts

rsrc_PACK_4_DC8:        /* set %a4 */
    moveaw #16446,%a4
    jbsr rsrc_PACK_4_2E6
    movew #0,%ccr
    rts

/* subroutine (27 instructions) (mechanical summary) */
rsrc_PACK_4_DD6:
    tstl %d7
    jbne rsrc_PACK_4_DD6_6
    rts
rsrc_PACK_4_DD6_6:      /* set bit 12 of %d6 */
    bset #12,%d6
    bftst %d1,17,2
    jbeq rsrc_PACK_4_DD6_26
    jbmi rsrc_PACK_4_DD6_18
    tstb %d6
    jbpl rsrc_PACK_4_DD6_36
    rts
rsrc_PACK_4_DD6_18:     /* test bit 13 of %d1 */
    btst #13,%d1
    jbeq rsrc_PACK_4_DD6_20
    rts
rsrc_PACK_4_DD6_20:     /* test %d6 */
    tstb %d6
    jbmi rsrc_PACK_4_DD6_36
    rts
rsrc_PACK_4_DD6_26:     /* from here: addl %d7,%d7 */
    addl %d7,%d7
    jbcs rsrc_PACK_4_DD6_2C
    rts
rsrc_PACK_4_DD6_2C:     /* from here: jbne rsrc_PACK_4_DD6_36 */
    jbne rsrc_PACK_4_DD6_36
    btst #0,%d5
    jbne rsrc_PACK_4_DD6_36
    rts
rsrc_PACK_4_DD6_36:     /* clear %d0 */
    moveq #0,%d0
    addql #1,%d5
    addxl %d0,%d4
    rts

/* Convert extended to an integer or comp (with the operands' format from the operation word). */
FP68K_X2Z_fmt:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_5A4),%a0
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    moveal %fp@(14),%a1
    jbsr rsrc_PACK_4_176
    moveq #26,%d7
    movel %d6,%d1
    lsrl %d7,%d1
    andiw #14,%d1
    subqw #2,%d1
    moveq #0,%d7
    movew %pc@(rsrc_PACK_4_E48,%d1:w),%d1
    jmp %pc@(FP68K_X2Z_fmt,%d1:w)
rsrc_PACK_4_E48:        /* (data) */
    .short  rsrc_PACK_4_E54-FP68K_X2Z_fmt	| 40874788
    .short  rsrc_PACK_4_EB8-FP68K_X2Z_fmt	| 4087478A
    .short  FP68K_X2X-FP68K_X2Z_fmt	| 4087478C
    .short  rsrc_PACK_4_F88-FP68K_X2Z_fmt	| 4087478E
    .short  rsrc_PACK_4_F44-FP68K_X2Z_fmt	| 40874790
    .short  rsrc_PACK_4_F02-FP68K_X2Z_fmt	| 40874792

/* subroutine (37 instructions): calls rsrc_PACK_4_162, rsrc_PACK_4_368, rsrc_PACK_4_43E; low memory FPState (mechanical summary) */
rsrc_PACK_4_E54:
    moveal %fp@(10),%a2	| 40874794
    tstl %d0
    jbeq rsrc_PACK_4_E6A
    tstw %d0
    jbeq rsrc_PACK_4_E7E
    andiw #-2048,%d5
    jbsr rsrc_PACK_4_162
    jbra rsrc_PACK_4_E7E
rsrc_PACK_4_E6A:        /* set %d1 */
    movew FPState,%d1
    btst #6,%d1
    jbeq rsrc_PACK_4_E7A
    jbsr rsrc_PACK_4_368
    jbra rsrc_PACK_4_E7E
rsrc_PACK_4_E7A:        /* call rsrc_PACK_4_43E */
    jbsr rsrc_PACK_4_43E
rsrc_PACK_4_E7E:        /* set %d3 */
    movew %a4,%d3
    cmpiw #32767,%d3
    jbne rsrc_PACK_4_E8C
    movew #17408,%d3
    jbra rsrc_PACK_4_E94
rsrc_PACK_4_E8C:        /* test %d3 */
    tstw %d3
    jbne rsrc_PACK_4_E94
    movew #15361,%d3
rsrc_PACK_4_E94:        /* from here: subiw #15360,%d3 */
    subiw #15360,%d3
    tstl %d4
    jbmi rsrc_PACK_4_E9E
    subqw #1,%d3
rsrc_PACK_4_E9E:        /* from here: lsrl #8,%d5 */
    lsrl #8,%d5
    lsrl #3,%d5
    bfins %d4,%d5,0,11
    lsrl #8,%d4
    lsrl #2,%d4
    bfins %d3,%d4,0,11
    addb %d6,%d6
    roxrl #1,%d4
    movel %d4,%a2@+
    movel %d5,%a2@
    jmp %a0@

/* subroutine (29 instructions): calls rsrc_PACK_4_162, rsrc_PACK_4_368; low memory FPState (mechanical summary) */
rsrc_PACK_4_EB8:
    moveal %fp@(10),%a2	| 408747F8
    tstl %d0
    jbeq rsrc_PACK_4_ECE
    tstw %d0
    jbeq rsrc_PACK_4_ED6
    moveq #0,%d5
    clrb %d4
    jbsr rsrc_PACK_4_162
    jbra rsrc_PACK_4_ED6
rsrc_PACK_4_ECE:        /* set %d1 */
    movew FPState,%d1
    jbsr rsrc_PACK_4_368
rsrc_PACK_4_ED6:        /* set %d3 */
    movew %a4,%d3
    cmpiw #32767,%d3
    jbne rsrc_PACK_4_EE4
    movew #16512,%d3
    jbra rsrc_PACK_4_EEC
rsrc_PACK_4_EE4:        /* test %d3 */
    tstw %d3
    jbne rsrc_PACK_4_EEC
    movew #16257,%d3
rsrc_PACK_4_EEC:        /* from here: subiw #16256,%d3 */
    subiw #16256,%d3
    addl %d4,%d4
    jbcs rsrc_PACK_4_EF6
    subqw #1,%d3
rsrc_PACK_4_EF6:        /* from here: orw %d3,%d4 */
    orw %d3,%d4
    rorl #8,%d4
    addb %d6,%d6
    roxrl #1,%d4
    movel %d4,%a2@
    jmp %a0@

/* subroutine (26 instructions): calls rsrc_PACK_4_DBC, rsrc_PACK_4_DD6; low memory FPState (mechanical summary) */
rsrc_PACK_4_F02:
    tstl %d0
    jbeq rsrc_PACK_4_F20
    btst #17,%d0
    jbne rsrc_PACK_4_F3A
    tstb %d0
    jbne rsrc_PACK_4_F18
rsrc_PACK_4_F10:        /* loop: bset */
    bset #8,%d6
    bclr #12,%d6
rsrc_PACK_4_F18:        /* set %d4 */
    moveq #1,%d4
    moveq #0,%d5
    rorl #1,%d4
    jbra rsrc_PACK_4_F3A
rsrc_PACK_4_F20:        /* call rsrc_PACK_4_DBC */
    jbsr rsrc_PACK_4_DBC
    jble rsrc_PACK_4_F10
    movew FPState,%d1
    jbsr rsrc_PACK_4_DD6
    tstl %d4
    jbmi rsrc_PACK_4_F10
    tstb %d6
    jbpl rsrc_PACK_4_F3A
    negl %d5
    negxl %d4
rsrc_PACK_4_F3A:        /* set %a2 */
    moveal %fp@(10),%a2
    movel %d4,%a2@+
    movel %d5,%a2@
    jmp %a0@

/* subroutine (27 instructions): calls rsrc_PACK_4_DBC, rsrc_PACK_4_DD6; low memory FPState (mechanical summary) */
rsrc_PACK_4_F44:
    tstl %d0
    jbeq rsrc_PACK_4_F5C
    btst #17,%d0
    jbne rsrc_PACK_4_F80
rsrc_PACK_4_F4E:        /* loop: moveq */
    moveq #1,%d5
    bset #8,%d6
    rorl #1,%d5
    bclr #12,%d6
    jbra rsrc_PACK_4_F80
rsrc_PACK_4_F5C:        /* call rsrc_PACK_4_DBC */
    jbsr rsrc_PACK_4_DBC
    jble rsrc_PACK_4_F4E
    movew FPState,%d1
    jbsr rsrc_PACK_4_DD6
    tstl %d4
    jbne rsrc_PACK_4_F4E
    tstl %d5
    jbpl rsrc_PACK_4_F7A
    negl %d5
    jbpl rsrc_PACK_4_F4E
    tstb %d6
    jbpl rsrc_PACK_4_F4E
rsrc_PACK_4_F7A:        /* test %d6 */
    tstb %d6
    jbpl rsrc_PACK_4_F80
    negl %d5
rsrc_PACK_4_F80:        /* set %a2 */
    moveal %fp@(10),%a2
    movel %d5,%a2@
    jmp %a0@

/* subroutine (25 instructions): calls rsrc_PACK_4_DBC, rsrc_PACK_4_DD6; low memory FPState (mechanical summary) */
rsrc_PACK_4_F88:
    tstl %d0
    jbeq rsrc_PACK_4_FA0
    btst #17,%d0
    jbne rsrc_PACK_4_FC6
rsrc_PACK_4_F92:        /* loop: move */
    movew #-32768,%d5
    bset #8,%d6
    bclr #12,%d6
    jbra rsrc_PACK_4_FC6
rsrc_PACK_4_FA0:        /* call rsrc_PACK_4_DBC */
    jbsr rsrc_PACK_4_DBC
    jble rsrc_PACK_4_F92
    movew FPState,%d1
    jbsr rsrc_PACK_4_DD6
    tstl %d4
    jbne rsrc_PACK_4_F92
    cmpil #32768,%d5
    jbcs rsrc_PACK_4_FC0
    jbhi rsrc_PACK_4_F92
    tstb %d6
    jbpl rsrc_PACK_4_F92
rsrc_PACK_4_FC0:        /* test %d6 */
    tstb %d6
    jbpl rsrc_PACK_4_FC6
    negw %d5
rsrc_PACK_4_FC6:        /* set %a2 */
    moveal %fp@(10),%a2
    movew %d5,%a2@
    jmp %a0@

/* Binary exponent (logb). */
FP68K_LOGB:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_5E2),%a0
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    moveal %fp@(10),%a1
    jbsr rsrc_PACK_4_176
    clrb %d6
    tstl %d0
    jbeq FP68K_LOGB_42
    tstw %d0
    jbne rsrc_PACK_4_D4_88
    btst #17,%d0
    jbeq rsrc_PACK_4_4FA_8C
    oriw #2176,%d6
    moveaw #32767,%a4
    moveq #0,%d4
    movel %d4,%d5
    jbra rsrc_PACK_4_4FA_8C
FP68K_LOGB_42:          /* clear %d5 */
    moveq #0,%d5
    subaw #16383,%a4
    movel %a4,%d4
    jbgt FP68K_LOGB_5C
    jblt FP68K_LOGB_56
    subal %a4,%a4
    movel %d5,%d4
    jbra rsrc_PACK_4_4FA_8C
FP68K_LOGB_56:          /* from here: orib #0x80,%d6 */
    orib #0x80,%d6
    negl %d4
FP68K_LOGB_5C:          /* set %a4 */
    moveaw #16414,%a4
    bfffo %d4,0,0,%d0
    lsll %d0,%d4
    subaw %d0,%a4
    jbra rsrc_PACK_4_4FA_8C

/* Scale by a power of two (scalb). */
FP68K_SCALB:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    lea %pc@(rsrc_PACK_4_5A4),%a0
    movew %fp@(8),%d6
    moveq #0,%d0
    swap %d6
    clrw %d6
    moveal %fp@(10),%a1
    jbsr rsrc_PACK_4_176
    tstl %d0
    jbeq FP68K_SCALB_2C
    tstw %d0
    jbne rsrc_PACK_4_D4_88
    jbra rsrc_PACK_4_4FA_8C
FP68K_SCALB_2C:         /* set %a2 */
    moveal %fp@(14),%a2
    addaw %a2@,%a4
    moveq #0,%d7
    jbra rsrc_PACK_4_352

/* Classify (signalling or quiet NaN, infinite, zero, normal, denormal). */
FP68K_CLASS:
    moveml %d0-%d1/%a0,%sp@-
    moveal %sp@(22),%a0
    movew %a0@+,%d0
    btst #5,%sp@(17)
    beqs FP68K_CLASS_14
    addqw #2,%a0
FP68K_CLASS_14:
    addl %d0,%d0
    lsrw #1,%d0
    bset #31,%d0
    bclr #15,%d0
    cmpiw #32767,%d0
    beqs FP68K_SCALB_6C_E
    movel %a0@+,%d1
    bpls FP68K_SCALB_6C_2C
FP68K_SCALB_62:         /* loop: moveq */
    moveq #5,%d1
FP68K_SCALB_64:         /* loop: btst */
    btst #16,%d0
    jbeq FP68K_SCALB_6C
    negw %d1
FP68K_SCALB_6C:         /* set %a0 */
    moveal %sp@(18),%a0
    movew %d1,%a0@
    moveml %sp@+,%d0-%d1/%a0
    rtd #10
FP68K_SCALB_6C_E:
    movel %a0@+,%d1	| 408749F4
    addl %d1,%d1
    lsrl #1,%d1
    beqs FP68K_SCALB_6C_E_16
    btst #30,%d1
    beqs FP68K_SCALB_6C_E+0x12
    moveq #2,%d1
    jbra FP68K_SCALB_64
    moveq #1,%d1
    jbra FP68K_SCALB_64
FP68K_SCALB_6C_E_16:
    movel %a0@,%d1	| 40874A0A
    bnes FP68K_SCALB_6C_E+0x12
    moveq #3,%d1
    jbra FP68K_SCALB_64
FP68K_SCALB_6C_2C:
    beqs FP68K_SCALB_6C_2C_8+0x8	| 40874A12
FP68K_SCALB_6C_2C_2:
    subqw #1,%d0	| 40874A14
    addl %d1,%d1
    bpls FP68K_SCALB_6C_2C_2
FP68K_SCALB_6C_2C_8:
    tstw %d0
    jbpl FP68K_SCALB_62
    moveq #6,%d1
    jbra FP68K_SCALB_64
    subiw #32,%d0
    movel %a0@,%d1
    beqs FP68K_SCALB_6C_2C_1C
    bpls FP68K_SCALB_6C_2C_2	| 40874A2A
    bras FP68K_SCALB_6C_2C_8
FP68K_SCALB_6C_2C_1C:
    moveq #4,%d1
    jbra FP68K_SCALB_64

/* Classify (signalling or quiet NaN, infinite, zero, normal, denormal) (with the operands' format from the operation word). */
FP68K_CLASS_fmt:
    moveml %d0-%d1/%a0,%sp@-	| 40874A32
    movew %sp@(16),%d0	| 40874A36
    moveal %sp@(22),%a0	| 40874A3A
    btst #11,%d0	| 40874A3E
    jbne FP68K_CLASS_fmt_38	| 40874A42
    btst #13,%d0	| 40874A44
    jbne FP68K_SCALB_13C	| 40874A48
    movel %a0@,%d0	| 40874A4A
    addl %d0,%d0	| 40874A4C
    jbeq FP68K_CLASS_fmt_5E	| 40874A4E
    bfextu %d0,0,8,%d1	| 40874A50
    jbeq FP68K_CLASS_fmt_62	| 40874A54
    cmpib #0xff,%d1	| 40874A56
    jbne FP68K_CLASS_fmt_66	| 40874A5A
    bftst %d0,8,23	| 40874A5C
    jbeq FP68K_SCALB_134	| 40874A60
    btst #23,%d0	| 40874A62
    jbne FP68K_CLASS_fmt_5A	| 40874A66
    jbra FP68K_SCALB_138	| 40874A68
FP68K_CLASS_fmt_38:     /* set %d0 */
    movel %a0@+,%d0	| 40874A6A
    orw %a0@+,%d0	| 40874A6C
    orw %a0@,%d0	| 40874A6E
    addl %d0,%d0	| 40874A70
    jbeq FP68K_CLASS_fmt_5E	| 40874A72
    bfextu %d0,0,11,%d1	| 40874A74
    jbeq FP68K_CLASS_fmt_62	| 40874A78
    cmpiw #2047,%d1	| 40874A7A
    jbne FP68K_CLASS_fmt_66	| 40874A7E
    bftst %d0,11,20	| 40874A80
    jbeq FP68K_SCALB_134	| 40874A84
    btst #20,%d0	| 40874A86
    jbeq FP68K_SCALB_138	| 40874A8A
FP68K_CLASS_fmt_5A:     /* result 2 */
    moveq #2,%d0
    jbra FP68K_SCALB_120
FP68K_CLASS_fmt_5E:     /* result 4 */
    moveq #4,%d0
    jbra FP68K_SCALB_120
FP68K_CLASS_fmt_62:     /* result 6 */
    moveq #6,%d0
    jbra FP68K_SCALB_120
FP68K_CLASS_fmt_66:     /* loop: moveq */
    moveq #5,%d0
FP68K_SCALB_120:        /* loop: movea */
    moveal %sp@(18),%a0
    roxrw #1,%d1
    jbpl FP68K_SCALB_12A
    negw %d0
FP68K_SCALB_12A:        /* set %a0@ */
    movew %d0,%a0@
    moveml %sp@+,%d0-%d1/%a0
    rtd #10
FP68K_SCALB_134:        /* result 3 */
    moveq #3,%d0
    jbra FP68K_SCALB_120
FP68K_SCALB_138:        /* result 1 */
    moveq #1,%d0
    jbra FP68K_SCALB_120
FP68K_SCALB_13C:        /* set %d0 */
    movel %a0@+,%d0	| 40874AB6
    addl %d0,%d0	| 40874AB8
    orl %a0@,%d0	| 40874ABA
    jbne FP68K_CLASS_fmt_66	| 40874ABC
    addxw %d0,%d0	| 40874ABE
    jbeq FP68K_CLASS_fmt_5E	| 40874AC0
    jbra FP68K_CLASS_fmt_5A	| 40874AC2

/* Set the floating-point environment. */
FP68K_SETENV:
    .byte   0x2F, 0x08, 0x20, 0x6F, 0x00, 0x0A, 0x31, 0xD0, 0x0A, 0x4A, 0x20, 0x5F, 0x4E, 0x74, 0x00, 0x06	| 40874AC4

/* Get the environment. */
FP68K_GETENV:
    .byte   0x2F, 0x08, 0x20, 0x6F, 0x00, 0x0A, 0x30, 0xB8, 0x0A, 0x4A, 0x20, 0x5F, 0x4E, 0x74, 0x00, 0x06	| 40874AD4

/* Set the halt vector. */
FP68K_SETHV:
    .byte   0x2F, 0x08, 0x20, 0x6F, 0x00, 0x0A, 0x21, 0xD0, 0x0A, 0x4C, 0x20, 0x5F, 0x4E, 0x74, 0x00, 0x06	| 40874AE4

/* Get the halt vector. */
FP68K_GETHV:
    .byte   0x2F, 0x08, 0x20, 0x6F, 0x00, 0x0A, 0x20, 0xB8, 0x0A, 0x4C, 0x20, 0x5F, 0x4E, 0x74, 0x00, 0x06	| 40874AF4

/* Negate. */
FP68K_NEG:
    .byte   0x2F, 0x08, 0x20, 0x6F, 0x00, 0x0A, 0x08, 0x50, 0x00, 0x07, 0x20, 0x5F, 0x4E, 0x74, 0x00, 0x06	| 40874B04

/* Absolute value. */
FP68K_ABS:
    .byte   0x2F, 0x08, 0x20, 0x6F, 0x00, 0x0A, 0x08, 0x90, 0x00, 0x07, 0x20, 0x5F, 0x4E, 0x74, 0x00, 0x06	| 40874B14

/* Copy the sign. */
FP68K_CPYSGN:
    .byte   0x48, 0xE7, 0x00, 0x80, 0x20, 0x6F, 0x00, 0x0E, 0x08, 0x90, 0x00, 0x07, 0x4A, 0x37, 0x81, 0x61	| 40874B24
    .byte   0x00, 0x0A, 0x6A, 0x04, 0x08, 0xD0, 0x00, 0x07, 0x20, 0x5F, 0x4E, 0x74, 0x00, 0x0A	| 40874B34

/* Procedure entry (save the environment, set the default one). */
FP68K_PROCENTRY:
    .byte   0x2F, 0x08, 0x20, 0x6F, 0x00, 0x0A, 0x30, 0xB8, 0x0A, 0x4A, 0x42, 0x78, 0x0A, 0x4A, 0x20, 0x5F	| 40874B42
    .byte   0x4E, 0x74, 0x00, 0x06	| 40874B52

/* Test an exception flag. */
FP68K_TESTXCP:
    .byte   0x48, 0xE7, 0x80, 0x80, 0x20, 0x6F, 0x00, 0x0E, 0x30, 0x10, 0x01, 0x38, 0x0A, 0x4A, 0x56, 0xC0	| 40874B56
    .byte   0x44, 0x00, 0x10, 0x80, 0x4C, 0xDF, 0x01, 0x01, 0x4E, 0x74, 0x00, 0x06	| 40874B66

/* Set an exception flag (and halt if enabled). */
FP68K_SETXCP:
    .byte   0x48, 0xE7, 0x82, 0x80, 0x3C, 0x3C, 0x00, 0x15, 0x48, 0x46, 0x42, 0x46, 0x20, 0x6F, 0x00, 0x12	| 40874B72
    .byte   0x30, 0x10, 0x50, 0x40, 0x01, 0xC6, 0x30, 0x38, 0x0A, 0x4A, 0x60, 0x18	| 40874B82

/* Procedure exit (restore the environment, signal the exceptions raised). */
FP68K_PROCEXIT:
    .byte   0x48, 0xE7, 0x82, 0x80, 0x20, 0x6F, 0x00, 0x12, 0x3C, 0x3C, 0x00, 0x19, 0x48, 0x46, 0x3C, 0x3C	| 40874B8E
    .byte   0x1F, 0x00, 0xCC, 0x78, 0x0A, 0x4A, 0x30, 0x10, 0x80, 0x46, 0x31, 0xC0, 0x0A, 0x4A, 0xE0, 0x4E	| 40874B9E
    .byte   0xC0, 0x46, 0x66, 0x0A, 0x44, 0xC0, 0x4C, 0xDF, 0x01, 0x41, 0x4E, 0x74, 0x00, 0x06, 0x41, 0xEF	| 40874BAE
    .byte   0x00, 0x12, 0x42, 0x67, 0x3F, 0x00, 0x48, 0x57, 0x2F, 0x28, 0x00, 0x08, 0x2F, 0x28, 0x00, 0x04	| 40874BBE
    .byte   0x2F, 0x10, 0x48, 0x46, 0x3F, 0x06, 0x20, 0x78, 0x0A, 0x4C, 0x4E, 0x90, 0x20, 0x1F, 0x60, 0xD4	| 40874BCE

/* Next representable value (nextafter). */
FP68K_NEXT:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    movew %fp@(8),%d6
    moveml %fp@(10),%a1-%a2
    subaw #22,%sp
    moveal %sp,%a4
    movew FPState,%d3
    clrw FPState
    moveq #0,%d2
    movew %d6,%d5
    andiw #14336,%d5
    jbne FP68K_SCALB_29C
    moveb #32,%d2
    andb %d6,%d2
    jbeq FP68K_SCALB_29C
    movew %a2@,%a2@(2)
    addql #2,%a2
FP68K_SCALB_29C:        /* from here: swap %d6 */
    swap %d6
    clrw %d6
    pea %a2@
    pea %a4@(12)
    moveq #14,%d0
    orw %d5,%d0
    movew %d0,%sp@-
    jbsr rsrc_PACK_4
    tstw %d5
    jbne FP68K_SCALB_2C4
    movel %a4@(12),%a2@
    movel %a4@(16),%a2@(4)
    movew %a4@(20),%a2@(8)
FP68K_SCALB_2C4:        /* from here: bfextu %a4@(12),1,15,%d1 */
    bfextu %a4@(12),1,15,%d1
    orl %a4@(14),%d1
    orl %a4@(18),%d1
    sne %d4
    pea %a1@
    pea %a4@
    orb %d2,%d0
    movew %d0,%sp@-
    jbsr rsrc_PACK_4
    tstb %d2
    jbeq FP68K_SCALB_2F0
    movel %a4@(4),%a4@(2)
    movel %a4@(8),%a4@(6)
FP68K_SCALB_2F0:        /* from here: pea %a4@ */
    pea %a4@
    pea %a4@(12)
    movew #8,%sp@-
    jbsr rsrc_PACK_4
    jbvc FP68K_SCALB_322
    pea %a4@
    pea %a4@(12)
    movew #4,%sp@-
    jbsr rsrc_PACK_4
    pea %a4@(12)
    pea %a2@
    moveq #16,%d0
    orw %d5,%d0
    movew %d0,%sp@-
    jbsr rsrc_PACK_4
    jbra FP68K_SCALB_3A6
FP68K_SCALB_322:        /* from here: jbeq FP68K_SCALB_3A6 */
    jbeq FP68K_SCALB_3A6
    jbcc FP68K_SCALB_332
    btst #7,%a2@
    jbeq FP68K_SCALB_33A
    jbra FP68K_SCALB_3C0
FP68K_SCALB_332:        /* test bit 7 of %a2@ */
    btst #7,%a2@
    jbeq FP68K_SCALB_3C0
FP68K_SCALB_33A:        /* test bit 12 of %d5 */
    btst #12,%d5
    jbeq FP68K_SCALB_344
    addql #1,%a2@
    jbra FP68K_SCALB_378
FP68K_SCALB_344:        /* test bit 11 of %d5 */
    btst #11,%d5
    jbeq FP68K_SCALB_354
    addql #1,%a2@(4)
    jbcc FP68K_SCALB_352
    addql #1,%a2@
FP68K_SCALB_352:        /* continue at FP68K_SCALB_378 */
    jbra FP68K_SCALB_378
FP68K_SCALB_354:        /* add 1 to %a2@(6) */
    addql #1,%a2@(6)
    jbcc FP68K_SCALB_378
    addql #1,%a2@(2)
    jbcc FP68K_SCALB_378
    roxrw %a2@(2)
    addqw #1,%a2@
    cmpiw #32767,%a2@
    jbeq FP68K_SCALB_372
    cmpiw #-1,%a2@
    jbne FP68K_SCALB_378
FP68K_SCALB_372:        /* clear bit 7 of %a2@(2) */
    bclr #7,%a2@(2)
FP68K_SCALB_378:        /* loop: pea */
    pea %a2@
    pea %a4@(10)
    moveq #28,%d0
    orw %d5,%d0
    movew %d0,%sp@-
    jbsr rsrc_PACK_4
    movew %a4@(10),%d1
    jbpl FP68K_SCALB_390
    negw %d1
FP68K_SCALB_390:        /* test #3,%d1 */
    cmpiw #3,%d1
    jbne FP68K_SCALB_39C
    oriw #5120,%d6
    jbra FP68K_SCALB_3A6
FP68K_SCALB_39C:        /* test #5,%d1 */
    cmpiw #5,%d1
    jbeq FP68K_SCALB_3A6
    oriw #4608,%d6
FP68K_SCALB_3A6:        /* address %sp@(22) */
    lea %sp@(22),%sp
    tstb %d2
    jbeq FP68K_SCALB_3B2
    movew %a2@,%a2@(-2)
FP68K_SCALB_3B2:        /* set %d7 */
    movew FPState,%d7
    movew %d3,FPState
    orw %d7,%d6
    jbra rsrc_PACK_4_5A4
FP68K_SCALB_3C0:        /* test bit 12 of %d5 */
    btst #12,%d5
    jbeq FP68K_SCALB_3D6
    tstb %d4
    jbne FP68K_SCALB_3D2
    bchg #7,%a2@
    addql #1,%a2@
    jbra FP68K_SCALB_378
FP68K_SCALB_3D2:        /* subtract 1 to %a2@ */
    subql #1,%a2@
    jbra FP68K_SCALB_378
FP68K_SCALB_3D6:        /* test bit 11 of %d5 */
    btst #11,%d5
    jbeq FP68K_SCALB_3F4
    tstb %d4
    jbne FP68K_SCALB_3EA
    bchg #7,%a2@
    addqw #1,%a2@(6)
    jbra FP68K_SCALB_378
FP68K_SCALB_3EA:        /* subtract 1 to %a2@(4) */
    subql #1,%a2@(4)
    jbcc FP68K_SCALB_3F2
    subql #1,%a2@
FP68K_SCALB_3F2:        /* continue at FP68K_SCALB_378 */
    jbra FP68K_SCALB_378
FP68K_SCALB_3F4:        /* test %d4 */
    tstb %d4
    jbne FP68K_SCALB_404
    bchg #7,%a2@
    addqw #1,%a2@(8)
    jbra FP68K_SCALB_378
FP68K_SCALB_404:        /* subtract 1 to %a2@(6) */
    subql #1,%a2@(6)
    jbcc FP68K_SCALB_426
    subql #1,%a2@(2)
    jbmi FP68K_SCALB_422
    tstw %a2@
    jbeq FP68K_SCALB_426
    cmpiw #-32768,%a2@
    jbeq FP68K_SCALB_426
    addiw #-32768,%a2@(2)
    jbra FP68K_SCALB_424
FP68K_SCALB_422:        /* from here: jbcc FP68K_SCALB_426 */
    jbcc FP68K_SCALB_426
FP68K_SCALB_424:        /* subtract 1 to %a2@ */
    subqw #1,%a2@
FP68K_SCALB_426:        /* continue at FP68K_SCALB_378 */
    jbra FP68K_SCALB_378

/* Convert to a decimal record. */
FP68K_X2DEC:
    moveml %d0-%a4,%sp@-
    linkw %fp,#-16
    movew %fp@(60),%d7
    andiw #14368,%d7
    movew FPState,%d3
    movew %d3,%fp@(-2)
    andiw #24576,%d3
    movew %d3,FPState
    moveal %fp@(66),%a3
    lea %fp@(-16),%a0
    movel %a0,%fp@(66)
    movel %a3,%sp@-
    movel %a0,%sp@-
    movew %d7,%sp@-
    addiw #14,%sp@
    bsrw rsrc_PACK_4
    tstb %d7
    jbeq FP68K_SCALB_474
    movel %fp@(-12),%fp@(-14)
    movel %fp@(-8),%fp@(-10)
FP68K_SCALB_474:        /* set %a1 */
    moveal %fp@(70),%a1
    movel %a1@,%d2
    moveal %fp@(62),%a1
    movew %a0@+,%d0
    clrw %a1@
    bclr #15,%d0
    jbeq FP68K_SCALB_48C
    moveb #1,%a1@
FP68K_SCALB_48C:        /* set %d4 */
    movel %a0@+,%d4
    movel %a0@,%d5
    moveb #1,%a1@(4)
    cmpiw #32767,%d0
    jbne FP68K_SCALB_4B4
    movel %d4,%d0
    andil #2147483647,%d0
    jbne FP68K_SCALB_4C0
    tstl %d5
    jbne FP68K_SCALB_4C0
    moveq #73,%d0
FP68K_SCALB_4AC:        /* loop: move */
    moveb %d0,%a1@(5)
    jbra rsrc_PACK_4_151E_C0
FP68K_SCALB_4B4:        /* test %d4 */
    tstl %d4
    jbne rsrc_PACK_4_151E_1C
    tstl %d5
    jbne rsrc_PACK_4_151E_1C
    moveq #48,%d0
    jbra FP68K_SCALB_4AC
FP68K_SCALB_4C0:        /* set bit 30 of %d4 */
    bset #30,%d4
    jbne FP68K_SCALB_4CC
    bset #0,FPState
FP68K_SCALB_4CC:        /* add 4 to %a1 */
    addql #4,%a1
    moveb #17,%a1@+
    moveb #78,%a1@+
    jbsr rsrc_PACK_4_151E
    movel %d5,%d4
    jbsr rsrc_PACK_4_151E
    subaw #22,%a1
    jbra rsrc_PACK_4_151E_C0

/* subroutine (102 instructions): calls rsrc_PACK_4_1A56; low memory FPState, FPHaltVector (mechanical summary) */
rsrc_PACK_4_151E:
    moveq #8,%d0
rsrc_PACK_4_151E_2:     /* loop: ro */
    roll #4,%d4
    moveq #15,%d1
    andb %d4,%d1
    orib #48,%d1
    cmpib #57,%d1
    jble rsrc_PACK_4_151E_14
    addqb #7,%d1
rsrc_PACK_4_151E_14:    /* set %a1@+ */
    moveb %d1,%a1@+
    subqw #1,%d0
    jbne rsrc_PACK_4_151E_2
    rts
rsrc_PACK_4_151E_1C:    /* test %d4 */
    tstl %d4
    jbmi rsrc_PACK_4_151E_28
rsrc_PACK_4_151E_20:    /* loop: subq */
    subqw #1,%d0
    addl %d5,%d5
    addxl %d4,%d4
    jbpl rsrc_PACK_4_151E_20
rsrc_PACK_4_151E_28:    /* set %d1 */
    movel %d4,%d1
    movew %d0,%d1
    subiw #16383,%d1
    swap %d1
    addw %d1,%d1
    movel #1292913986,%d0
    tstl %d1
    jbpl rsrc_PACK_4_151E_40
    addqw #1,%d0
rsrc_PACK_4_151E_40:    /* set %d4 */
    movel %d0,%d4
    swap %d4
    muluw %d1,%d4
    clrw %d4
    swap %d4
    swap %d1
    movew %d1,%d5
    mulsw %d0,%d5
    swap %d5
    extl %d5
    addl %d5,%d4
    swap %d0
    mulsw %d1,%d0
    addl %d0,%d4
    swap %d4
    movew %d2,%d1
    jbmi rsrc_PACK_4_151E_6E
    cmpiw #8192,%d1
    jblt rsrc_PACK_4_151E_78
    movew #8192,%d1
    jbra rsrc_PACK_4_151E_78
rsrc_PACK_4_151E_6E:    /* test #-8192,%d1 */
    cmpiw #-8192,%d1
    jbgt rsrc_PACK_4_151E_78
    movew #-8192,%d1
rsrc_PACK_4_151E_78:    /* from here: swap %d2 */
    swap %d2
    lsrw #8,%d2
    tstb %d2
    jbne rsrc_PACK_4_151E_86
    tstw %d1
    jbgt rsrc_PACK_4_151E_86
    moveq #1,%d1
rsrc_PACK_4_151E_86:    /* loop: addq */
    addqw #1,%d4
    movew %d1,%d5
    tstb %d2
    jbeq rsrc_PACK_4_151E_90
    addw %d4,%d5
rsrc_PACK_4_151E_90:    /* test #19,%d5 */
    cmpiw #19,%d5
    jble rsrc_PACK_4_151E_9A
    movew #19,%d5
rsrc_PACK_4_151E_9A:    /* set %a1@(2) */
    movew %d5,%a1@(2)
    subw %d4,%a1@(2)
    tstw %d5
    jbgt rsrc_PACK_4_151E_A8
    moveq #1,%d5
rsrc_PACK_4_151E_A8:    /* set %sp@- */
    movel %fp@(66),%sp@-
    movel %a1,%sp@-
    moveb %d5,%a1@(4)
    jsr %pc@(rsrc_PACK_4_1A56)
    cmpb %a1@(4),%d5
    jbcs rsrc_PACK_4_151E_86
    negw %a1@(2)
rsrc_PACK_4_151E_C0:    /* set %d0 */
    movew FPState,%d0
    andiw #7936,%d0
    orw %d0,%fp@(-2)
    movew %fp@(-2),FPState
    lsrw #8,%d0
    andw %fp@(-2),%d0
    jbeq rsrc_PACK_4_151E_100
    movel %fp@(4),%fp@(-8)
    swap %d0
    clrw %d0
    movel %d0,%fp@(-12)
    pea %fp@(-12)
    movel %fp@(70),%sp@-
    movel %a3,%sp@-
    movel %fp@(62),%sp@-
    movew %fp@(60),%sp@-
    moveal FPHaltVector,%a0
    jsr %a0@
rsrc_PACK_4_151E_100:   /* return */
    unlk %fp
    moveml %sp@+,%d0-%a4
    movel %sp@,%sp@(14)
    lea %sp@(14),%sp
    movew #0,%ccr
    rts

/* Convert a decimal record to binary. */
FP68K_DEC2X:
    moveml %d0-%a4,%sp@-
    linkw %fp,#-16
    movew %fp@(60),%d7
    andiw #14336,%d7
    jbeq FP68K_DEC2X_3A
    cmpiw #4096,%d7
    jblt FP68K_DEC2X_26
    jbeq FP68K_DEC2X_20
    movew #24576,%d0
    jbra FP68K_DEC2X_2A
FP68K_DEC2X_20:         /* set %d0 */
    movew #24640,%d0
    jbra FP68K_DEC2X_2A
FP68K_DEC2X_26:         /* set %d0 */
    movew #24672,%d0
FP68K_DEC2X_2A:         /* set %d3 */
    movew FPState,%d3
    movew %d3,%fp@(-2)
    andw %d0,%d3
    oriw #128,%d3
    jbra FP68K_DEC2X_48
FP68K_DEC2X_3A:         /* set %d0 */
    movew #24672,%d0
    movew FPState,%d3
    movew %d3,%fp@(-2)
    andw %d0,%d3
FP68K_DEC2X_48:         /* set FPState */
    movew %d3,FPState
    moveal %fp@(62),%a3
    cmpiw #0,%d7
    jbeq FP68K_DEC2X_5E
    lea %fp@(-16),%a0
    movel %a0,%fp@(62)
FP68K_DEC2X_5E:         /* set %a2 */
    moveal %fp@(66),%a2
    lea %a2@(4),%a4
    moveq #0,%d4
    movel %d4,%d5
    moveb %a4@+,%d6
    jbeq rsrc_PACK_4_16EC_22
    moveb %a4@,%d0
    cmpib #73,%d0
    jbeq rsrc_PACK_4_16EC_16
    cmpib #78,%d0
    jbne rsrc_PACK_4_16EC_1C
    moveb %a4@(-1),%d2
    addql #1,%a4
    subqb #1,%d2
    moveq #8,%d0
    cmpib #4,%d2
    jbge FP68K_DEC2X_90
    subqb #4,%d0
    addb %d2,%d0
FP68K_DEC2X_90:         /* call rsrc_PACK_4_16CE */
    jbsr rsrc_PACK_4_16CE
    movel %d5,%d4
    moveq #0,%d5
    moveq #8,%d0
    jbsr rsrc_PACK_4_16CE
    jbra rsrc_PACK_4_16EC

/* subroutine (93 instructions): calls rsrc_PACK_4_17F4, rsrc_PACK_4; low memory FPState, FPHaltVector (mechanical summary) */
rsrc_PACK_4_16CE:
    roll #4,%d5
    subqb #1,%d2
    jbmi rsrc_PACK_4_16CE_18
    moveb %a4@+,%d1
    cmpib #57,%d1
    jble rsrc_PACK_4_16CE_12
    addib #9,%d1
rsrc_PACK_4_16CE_12:    /* from here: andib #15,%d1 */
    andib #15,%d1
    orb %d1,%d5
rsrc_PACK_4_16CE_18:    /* subtract 1 to %d0 */
    subqw #1,%d0
    jbne rsrc_PACK_4_16CE
    rts

rsrc_PACK_4_16EC:       /* set bit 30 of %d4 */
    bset #30,%d4
    movel %d4,%d0
    swap %d0
    andib #0xff,%d0
    jbne rsrc_PACK_4_16EC_16
    oriw #21,%d0
    swap %d0
    movel %d0,%d4
rsrc_PACK_4_16EC_16:    /* set %d0 */
    movew #32767,%d0
    jbra rsrc_PACK_4_16EC_24
rsrc_PACK_4_16EC_1C:    /* test #48,%d0 */
    cmpib #48,%d0
    jbne rsrc_PACK_4_16EC_5A
rsrc_PACK_4_16EC_22:    /* clear %d0 */
    moveq #0,%d0
rsrc_PACK_4_16EC_24:    /* test %a2@ */
    tstb %a2@
    jbeq rsrc_PACK_4_16EC_2C
    bset #15,%d0
rsrc_PACK_4_16EC_2C:    /* set %a0 */
    moveal %fp@(62),%a0
    movew %d0,%a0@+
    movel %d4,%a0@+
    movel %d5,%a0@
    jbra rsrc_PACK_4_16EC_6C
rsrc_PACK_4_16EC_38:    /* loop: move */
    movew %a2@(2),%sp@-
    moveq #0,%d0
    moveb %d6,%d0
    subiw #19,%d0
    subw %d0,%a2@(2)
    movel %fp@(62),%sp@-
    movel %fp@(66),%sp@-
    jsr %pc@(rsrc_PACK_4_17F4)
    movew %sp@+,%a2@(2)
    jbra rsrc_PACK_4_16EC_6C
rsrc_PACK_4_16EC_5A:    /* test #19,%d6 */
    cmpib #19,%d6
    jbhi rsrc_PACK_4_16EC_38
    movel %fp@(62),%sp@-
    movel %fp@(66),%sp@-
    jsr %pc@(rsrc_PACK_4_17F4)
rsrc_PACK_4_16EC_6C:    /* test #0,%d7 */
    cmpiw #0,%d7
    jbgt rsrc_PACK_4_16EC_88
    btst #5,%fp@(61)
    jbeq rsrc_PACK_4_16EC_B4
    movel %a3@(6),%a3@(8)
    movel %a3@(2),%a3@(4)
    jbra rsrc_PACK_4_16EC_B4
rsrc_PACK_4_16EC_88:    /* from here: pea %fp@(-16) */
    pea %fp@(-16)
    movel %a3,%sp@-
    movew %d7,%sp@-
    addiw #16,%sp@
    jbsr rsrc_PACK_4
    movew FPState,%d0
    btst #8,%d0
    jbeq rsrc_PACK_4_16EC_A8
    andiw #-7681,%d0
    jbra rsrc_PACK_4_16EC_B8
rsrc_PACK_4_16EC_A8:    /* test #4096,%d7 */
    cmpiw #4096,%d7
    jble rsrc_PACK_4_16EC_B8
    bclr #9,%d0
    jbra rsrc_PACK_4_16EC_B8
rsrc_PACK_4_16EC_B4:    /* set %d0 */
    movew FPState,%d0
rsrc_PACK_4_16EC_B8:    /* from here: andiw #7936,%d0 */
    andiw #7936,%d0
    orw %d0,%fp@(-2)
    movew %fp@(-2),FPState
    lsrw #8,%d0
    andw %fp@(-2),%d0
    jbeq rsrc_PACK_4_16EC_F4
    movel %fp@(4),%fp@(-8)
    swap %d0
    clrw %d0
    movel %d0,%fp@(-12)
    pea %fp@(-12)
    movel %fp@(70),%sp@-
    movel %fp@(66),%sp@-
    movel %a3,%sp@-
    movew %fp@(60),%sp@-
    moveal FPHaltVector,%a0
    jsr %a0@
rsrc_PACK_4_16EC_F4:    /* return */
    unlk %fp
    moveml %sp@+,%d0-%a4
    movel %sp@,%sp@(10)
    lea %sp@(10),%sp
    movew #0,%ccr
    rts

/* subroutine (71 instructions): calls rsrc_PACK_4_1E58, rsrc_PACK_4_2018, rsrc_PACK_4_1A08, rsrc_PACK_4_1F26, rsrc_PACK_4_1BF4 ...; low memory FPState (mechanical summary) */
rsrc_PACK_4_17F4:
    moveml %d0-%d7/%a1-%a4,%sp@-
    linkw %fp,#-160
    moveal %fp@(56),%a0
    addqw #2,%a0
    movew %a0@,%d0
    jblt rsrc_PACK_4_18BC_62
    jbsr rsrc_PACK_4_1E58
    jbsr rsrc_PACK_4_2018
    jbsr rsrc_PACK_4_1A08
    movel %fp@(-16),%fp@(-12)
    jbsr rsrc_PACK_4_1F26
    moveal %a1,%a3
    movew #79,%d6
    movew %d1,%d2
    moveal %a3,%a2
rsrc_PACK_4_17F4_34:    /* loop: subi */
    subiw #16,%d6
    movew %a2@+,%d0
    jbne rsrc_PACK_4_17F4_44
    dbf %d2,rsrc_PACK_4_17F4_34
rsrc_PACK_4_17F4_40:    /* loop: addq */
    addqw #1,%d6
    lslw #1,%d0
rsrc_PACK_4_17F4_44:    /* from here: jbpl rsrc_PACK_4_17F4_40 */
    jbpl rsrc_PACK_4_17F4_40
    moveq #-1,%d5
    jbsr rsrc_PACK_4_1BF4
    movew %d1,%d7
    aslw #4,%d7
    moveal %fp@(56),%a0
    addqw #2,%a0
    addw %a0@,%d7
    addiw #16398,%d7
    jbsr rsrc_PACK_4_18BC
    tstl %d4
    jbmi rsrc_PACK_4_17F4_6C
rsrc_PACK_4_17F4_62:    /* loop: subq */
    subqw #1,%d7
    asll #1,%d6
    roxll #1,%d5
    roxll #1,%d4
    jbpl rsrc_PACK_4_17F4_62
rsrc_PACK_4_17F4_6C:    /* set %a0 */
    moveal %fp@(60),%a0
    cmpiw #32767,%d7
    jbcc rsrc_PACK_4_17F4_86
    aslw #1,%d7
rsrc_PACK_4_17F4_78:    /* loop: as */
    aslw %a0@
    roxrw #1,%d7
    movew %d7,%a0@+
    movel %d4,%a0@+
    movel %d5,%a0@
    jbra rsrc_PACK_4_1A94
rsrc_PACK_4_17F4_86:    /* from here: oriw #5120,FPState */
    oriw #5120,FPState
    movew FPState,%d2
    btst #14,%d2
    jbne rsrc_PACK_4_17F4_A6
    btst #13,%d2
    jbeq rsrc_PACK_4_17F4_BE
    moveal %fp@(60),%a4
    movew %a4@,%d2
    jbpl rsrc_PACK_4_17F4_BE
    jbra rsrc_PACK_4_17F4_B4
rsrc_PACK_4_17F4_A6:    /* test bit 13 of %d2 */
    btst #13,%d2
    jbne rsrc_PACK_4_17F4_B4
    moveal %fp@(60),%a4
    movew %a4@,%d2
    jbmi rsrc_PACK_4_17F4_BE
rsrc_PACK_4_17F4_B4:    /* set %d7 */
    movew #-4,%d7
    moveq #-1,%d4
    moveq #-1,%d5
    jbra rsrc_PACK_4_17F4_78
rsrc_PACK_4_17F4_BE:    /* set %d7 */
    movew #-2,%d7
    moveq #0,%d4
    moveq #0,%d5
    jbra rsrc_PACK_4_17F4_78

/* subroutine (92 instructions): calls rsrc_PACK_4_1E44, rsrc_PACK_4_1A08, rsrc_PACK_4_1D00, rsrc_PACK_4_1D66, rsrc_PACK_4_1BF4 ... (mechanical summary) */
rsrc_PACK_4_18BC:
    moveq #0,%d4
    moveq #0,%d5
    moveq #0,%d6
    tstw %d1
    jbgt rsrc_PACK_4_18BC_10
    movew %a3@+,%d4
    swap %d4
    rts
rsrc_PACK_4_18BC_10:    /* set %d4 */
    movel %a3@+,%d4
    subqw #2,%d1
    jbgt rsrc_PACK_4_18BC_20
    jblt rsrc_PACK_4_18BC_B2
    movew %a3@+,%d5
    swap %d5
    rts
rsrc_PACK_4_18BC_20:    /* set %d5 */
    movel %a3@+,%d5
    subqw #2,%d1
    jbgt rsrc_PACK_4_18BC_30
    jblt rsrc_PACK_4_18BC_B2
    movew %a3@+,%d6
    swap %d6
    rts
rsrc_PACK_4_18BC_30:    /* set %d6 */
    movel %a3@+,%d6
    rts
rsrc_PACK_4_18BC_34:    /* loop: move */
    movew %d1,%d4
    cmpw %d3,%d1
    jbge rsrc_PACK_4_18BC_3C
    movew %d3,%d4
rsrc_PACK_4_18BC_3C:    /* test %d4 */
    tstw %d4
    jbeq rsrc_PACK_4_18BC_76
    lea %a1@(2),%a2
    lea %a3@(2),%a4
    moveq #0,%d2
rsrc_PACK_4_18BC_4A:    /* loop: addq */
    addqw #1,%d2
    cmpw %d2,%d1
    jbge rsrc_PACK_4_18BC_52
    clrw %a2@
rsrc_PACK_4_18BC_52:    /* test %d2,%d3 */
    cmpw %d2,%d3
    jbge rsrc_PACK_4_18BC_58
    clrw %a4@
rsrc_PACK_4_18BC_58:    /* test %a4@+,%a2@+ */
    cmpmw %a4@+,%a2@+
    jbne rsrc_PACK_4_18BC_76
    cmpw %d2,%d4
    jbgt rsrc_PACK_4_18BC_4A
    jbra rsrc_PACK_4_18BC_76
rsrc_PACK_4_18BC_62:    /* call rsrc_PACK_4_1E44 */
    jbsr rsrc_PACK_4_1E44
    jbsr rsrc_PACK_4_1A08
    jbsr rsrc_PACK_4_1D00
    moveal %a4,%a3
    moveq #4,%d6
    cmpw %a3@,%d0
    jbeq rsrc_PACK_4_18BC_34
rsrc_PACK_4_18BC_76:    /* from here: jbhi rsrc_PACK_4_18BC_7E */
    jbhi rsrc_PACK_4_18BC_7E
    addqw #1,%d3
    clrw %a3@-
    moveq #5,%d6
rsrc_PACK_4_18BC_7E:    /* set %d2 */
    movew %d3,%d2
    aslw #4,%d2
    subw %d7,%d2
    addiw #16382,%d2
    movew %d2,%sp@-
    jbsr rsrc_PACK_4_1D66
    moveq #0,%d6
    movew %a3@,%d0
    jbra rsrc_PACK_4_18BC_98
rsrc_PACK_4_18BC_94:    /* loop: addq */
    addqw #1,%d6
    lslw #1,%d0
rsrc_PACK_4_18BC_98:    /* from here: jbpl rsrc_PACK_4_18BC_94 */
    jbpl rsrc_PACK_4_18BC_94
    movew %sp@+,%d7
    moveal %d7,%a1
    subw %d6,%d7
    jbmi rsrc_PACK_4_1990_16
    addiw #63,%d6
    moveq #-1,%d5
    jbsr rsrc_PACK_4_1BF4
    movel %a1,%d7
    jbsr rsrc_PACK_4_18BC
rsrc_PACK_4_18BC_B2:    /* test %d4 */
    tstl %d4
    jbmi rsrc_PACK_4_18BC_C0
rsrc_PACK_4_18BC_B6:    /* loop: subq */
    subqw #1,%d7
    asll #1,%d6
    roxll #1,%d5
    roxll #1,%d4
    jbpl rsrc_PACK_4_18BC_B6
rsrc_PACK_4_18BC_C0:    /* set %a0 */
    moveal %fp@(60),%a0
    aslw #1,%d7
    aslw %a0@
    roxrw #1,%d7
    movew %d7,%a0@+
    movel %d4,%a0@+
    movel %d5,%a0@
    jbra rsrc_PACK_4_1A94

/* subroutine (48 instructions): calls rsrc_PACK_4_1990, rsrc_PACK_4_1BF4, rsrc_PACK_4_18BC; low memory FPState (mechanical summary) */
rsrc_PACK_4_1990:
    tstw %d0
    jbge rsrc_PACK_4_1990_14
    clrw %a3@-
    addqw #1,%d1
    addiw #16,%d6
    subiw #16,%d7
    addiw #16,%d0
rsrc_PACK_4_1990_14:    /* return */
    rts
rsrc_PACK_4_1990_16:    /* set %d0 */
    movel %a1,%d0
    cmpiw #-66,%d0
    jbpl rsrc_PACK_4_1990_26
    movew #-66,%d7
    movew %d7,%d0
    subw %d6,%d7
rsrc_PACK_4_1990_26:    /* from here: addw %d7,%d6 */
    addw %d7,%d6
    jbsr rsrc_PACK_4_1990
    jbsr rsrc_PACK_4_1990
    jbsr rsrc_PACK_4_1990
    jbsr rsrc_PACK_4_1990
    jbsr rsrc_PACK_4_1990
    addiw #63,%d6
    movew %d0,%sp@-
    moveq #-1,%d5
    moveal %a3,%a1
    jbsr rsrc_PACK_4_1BF4
    moveal %a1,%a3
    movew %sp@+,%d7
    jbsr rsrc_PACK_4_18BC
    tstl %d4
    jbmi rsrc_PACK_4_1990_5A
rsrc_PACK_4_1990_4C:    /* loop: tst */
    tstw %d7
    jble rsrc_PACK_4_1990_5A
    subqw #1,%d7
    asll #1,%d6
    roxll #1,%d5
    roxll #1,%d4
    jbpl rsrc_PACK_4_1990_4C
rsrc_PACK_4_1990_5A:    /* set %a0 */
    moveal %fp@(60),%a0
    aslw #1,%d7
    aslw %a0@
    roxrw #1,%d7
    movew %d7,%a0@+
    movel %d4,%a0@+
    movel %d5,%a0@
    tstl %d4
    jbmi rsrc_PACK_4_1990_74
    oriw #4608,FPState
rsrc_PACK_4_1990_74:    /* continue at rsrc_PACK_4_1A94 */
    jbra rsrc_PACK_4_1A94

/* subroutine (31 instructions) (mechanical summary) */
rsrc_PACK_4_1A08:
    moveq #0,%d3
    moveal %fp@(-16),%a3
    subql #2,%a3
    clrw %a3@+
    moveal %fp@(56),%a0
    moveal %fp@(60),%a4
    tstb %a0@
    jbeq rsrc_PACK_4_1A08_1C
    bset #7,%a4@
    jbra rsrc_PACK_4_1A08_20
rsrc_PACK_4_1A08_1C:    /* clear bit 7 of %a4@ */
    bclr #7,%a4@
rsrc_PACK_4_1A08_20:    /* add 4 to %a0 */
    addql #4,%a0
    moveq #0,%d0
    moveb %a0@+,%d0
    jbra rsrc_PACK_4_1A08_48
rsrc_PACK_4_1A08_28:    /* loop: moveq */
    moveq #15,%d7
    andb %a0@+,%d7
    moveal %a3,%a4
    movew %d3,%d4
rsrc_PACK_4_1A08_30:    /* loop: move */
    movew %a4@-,%d6
    muluw #10,%d6
    addl %d6,%d7
    movew %d7,%a4@
    clrw %d7
    swap %d7
    dbf %d4,rsrc_PACK_4_1A08_30
    jbeq rsrc_PACK_4_1A08_48
    movew %d7,%a4@-
    addqw #1,%d3
rsrc_PACK_4_1A08_48:    /* count down */
    dbf %d0,rsrc_PACK_4_1A08_28
    rts

/* subroutine (28 instructions): calls rsrc_PACK_4_1E58, rsrc_PACK_4_1B5A, rsrc_PACK_4_1E44, rsrc_PACK_4_1CE2, rsrc_PACK_4_1D2C ...; low memory FPState (mechanical summary) */
rsrc_PACK_4_1A56:
    moveml %d0-%d7/%a1-%a4,%sp@-
    linkw %fp,#-160
    moveal %fp@(56),%a0
    addqw #2,%a0
    movew %a0@,%d0
    jble rsrc_PACK_4_1A56_1C
    jbsr rsrc_PACK_4_1E58
    jbsr rsrc_PACK_4_1B5A
    jbra rsrc_PACK_4_1A56_2E
rsrc_PACK_4_1A56_1C:    /* call rsrc_PACK_4_1E44 */
    jbsr rsrc_PACK_4_1E44
    jbsr rsrc_PACK_4_1CE2
    jbsr rsrc_PACK_4_1D2C
    moveq #0,%d5
    jbsr rsrc_PACK_4_1BF4
rsrc_PACK_4_1A56_2E:    /* call rsrc_PACK_4_1AB0 */
    jbsr rsrc_PACK_4_1AB0
rsrc_PACK_4_1A56_30:    /* return */
    unlk %fp
    moveml %sp@+,%d0-%d7/%a1-%a4
    moveal %sp@+,%a0
    lea %sp@(8),%sp
    jmp %a0@

rsrc_PACK_4_1A94:       /* set %d4 */
    movew FPState,%d4
    andiw #96,%d4
    jbeq rsrc_PACK_4_1A56_30
    pea %pc@(rsrc_PACK_4_202C)
    movel %fp@(60),%sp@-
    movew #8196,%sp@-
    jbsr rsrc_PACK_4
    jbra rsrc_PACK_4_1A56_30

/* subroutine (57 instructions): calls rsrc_PACK_4_1B36 (mechanical summary) */
rsrc_PACK_4_1AB0:
    moveal %fp@(-12),%a1
    clrl %a1@
    moveq #0,%d3
    tstw %d6
    moveal %a1,%a2
    jbmi rsrc_PACK_4_1AB0_7A
    addqw #1,%d1
rsrc_PACK_4_1AB0_10:    /* loop: moveq */
    moveq #15,%d5
    cmpw %d5,%d6
    jbge rsrc_PACK_4_1AB0_18
    movew %d6,%d5
rsrc_PACK_4_1AB0_18:    /* subtract 1 to %d1 */
    subqw #1,%d1
    jblt rsrc_PACK_4_1AB0_1E
    movew %a3@+,%d2
rsrc_PACK_4_1AB0_1E:    /* loop: movea */
    moveal %a1,%a2
    addw %d2,%d2
    movel %d3,%d7
    lea %a2@(4),%a2
rsrc_PACK_4_1AB0_28:    /* loop: move */
    movel %a2@-,%d0
    abcd %d0,%d0
    rorl #8,%d0
    abcd %d0,%d0
    rorl #8,%d0
    abcd %d0,%d0
    rorl #8,%d0
    abcd %d0,%d0
    rorl #8,%d0
    movel %d0,%a2@
    dbf %d7,rsrc_PACK_4_1AB0_28
    moveq #0,%d0
    abcd %d0,%d0
    jbeq rsrc_PACK_4_1AB0_4A
    addql #1,%d3
    movel %d0,%a2@-
rsrc_PACK_4_1AB0_4A:    /* count down */
    dbf %d5,rsrc_PACK_4_1AB0_1E
    subiw #16,%d6
    jbge rsrc_PACK_4_1AB0_10
    moveal %fp@(56),%a0
    addqw #4,%a0
    lea %a0@(1),%a1
    moveq #0,%d5
    moveb %a0@,%d5
rsrc_PACK_4_1AB0_62:    /* call rsrc_PACK_4_1B36 (loop) */
    jbsr rsrc_PACK_4_1B36
    jbsr rsrc_PACK_4_1B36
    jbsr rsrc_PACK_4_1B36
    jbsr rsrc_PACK_4_1B36
    dbf %d3,rsrc_PACK_4_1AB0_62
    movew %a1,%d0
    subw %a0,%d0
    subqb #1,%d0
    jbeq rsrc_PACK_4_1AB0_7A
    moveb %d0,%a0@
    rts
rsrc_PACK_4_1AB0_7A:    /* set %a0 */
    moveal %fp@(56),%a0
    addqw #4,%a0
    movew #304,%a0@
    rts

/* subroutine (5 instructions): calls rsrc_PACK_4_1B40 (mechanical summary) */
rsrc_PACK_4_1B36:
    moveq #0,%d1
    moveb %a2@+,%d1
    rorw #4,%d1
    jbsr rsrc_PACK_4_1B40
    rolw #4,%d1

/* subroutine (12 instructions) (mechanical summary) */
rsrc_PACK_4_1B40:
    tstw %d6
    jbpl rsrc_PACK_4_1B40_A
    tstb %d1
    jbeq rsrc_PACK_4_1B40_18
    moveq #0,%d6
rsrc_PACK_4_1B40_A:     /* subtract 1 to %d5 */
    subql #1,%d5
    jbmi rsrc_PACK_4_1B40_14
    orib #48,%d1
    moveb %d1,%a1@
rsrc_PACK_4_1B40_14:    /* add 1 to %a1 */
    addql #1,%a1
    subb %d1,%d1
rsrc_PACK_4_1B40_18:    /* return */
    rts

/* subroutine (64 instructions) (mechanical summary) */
rsrc_PACK_4_1B5A:
    moveal %fp@(56),%a0
    addqw #2,%a0
    movew %a0@,%d6
    moveal %fp@(60),%a0
    movew %a0@+,%d7
    bclr #15,%d7
    subiw #16447,%d7
    addw %d6,%d7
    movew %a0@+,%d3
    movew %a0@+,%d4
    movew %a0@+,%d5
    movew %a0@+,%d6
    moveal %fp@(-4),%a3
    addaw #16,%a3
    moveal %fp@(-4),%a1
    subql #2,%a1
    moveal %fp@(-12),%a4
    subql #2,%a4
    movew %a1@,%d0
    movew %d0,%d2
    muluw %d6,%d2
    movel %d2,%a3@
    movew %d0,%d2
    muluw %d4,%d2
    movel %d2,%a3@-
    clrw %a3@-
    lea %a3@(4),%a3
    movew %d0,%d2
    muluw %d5,%d2
    addl %d2,%a3@
    muluw %d3,%d0
    movel %d0,%a4@+
    addxl %a4@-,%a3@-
    moveal %d1,%a2
    subqw #1,%d1
    jbmi rsrc_PACK_4_1B5A_8C
rsrc_PACK_4_1B5A_5A:    /* loop: lea */
    lea %a3@(4),%a3
    movew %a1@-,%d0
    movew %d0,%d2
    muluw %d6,%d2
    addl %d2,%a3@
    movew %d0,%d2
    muluw %d4,%d2
    movel %d2,%a4@+
    addxl %a4@-,%a3@-
    jbcc rsrc_PACK_4_1B5A_76
    movew #1,%a3@-
    jbra rsrc_PACK_4_1B5A_78
rsrc_PACK_4_1B5A_76:    /* clear %a3@- */
    clrw %a3@-
rsrc_PACK_4_1B5A_78:    /* address %a3@(4) */
    lea %a3@(4),%a3
    movew %d0,%d2
    muluw %d5,%d2
    addl %d2,%a3@
    muluw %d3,%d0
    movel %d0,%a4@+
    addxl %a4@-,%a3@-
    dbf %d1,rsrc_PACK_4_1B5A_5A
rsrc_PACK_4_1B5A_8C:    /* set %d1 */
    movel %a2,%d1
    addqw #4,%d1
    movew %d1,%d6
    addqw #1,%d6
    aslw #4,%d6
    addw %d7,%d6
    moveq #0,%d5

/* subroutine (64 instructions): calls rsrc_PACK_4_1CA0; low memory FPState (mechanical summary) */
rsrc_PACK_4_1BF4:
    tstw %d6
    jbge rsrc_PACK_4_1BF4_18
    cmpiw #-66,%d6
    jbpl rsrc_PACK_4_1BF4_E
    movew #-66,%d6
rsrc_PACK_4_1BF4_E:     /* loop: clr */
    clrw %a3@-
    addqw #1,%d1
    addiw #16,%d6
    jblt rsrc_PACK_4_1BF4_E
rsrc_PACK_4_1BF4_18:    /* call rsrc_PACK_4_1CA0 */
    jbsr rsrc_PACK_4_1CA0
    tstw %d5
    jbeq rsrc_PACK_4_1BF4_82
    movew %d6,%d2
    lsrw #4,%d2
    lslw #1,%d2
    lea %a3@(0x0,%d2:w),%a2
    movew %a2@,%d4
    movew %d6,%d3
    andiw #15,%d3
    movew #-32768,%d0
    rorw %d3,%d0
    andw %d0,%d4
    jbeq rsrc_PACK_4_1BF4_3E
    addqw #1,%d5
rsrc_PACK_4_1BF4_3E:    /* set bit 4 of FPState */
    bset #4,FPState
    movew FPState,%d2
    movew %d2,%d4
    andiw #224,%d4
    jbeq rsrc_PACK_4_1BF4_54
    orw %d0,%a2@
    jbra rsrc_PACK_4_1BF4_82
rsrc_PACK_4_1BF4_54:    /* test bit 14 of %d2 */
    btst #14,%d2
    jbne rsrc_PACK_4_1BF4_92
    btst #13,%d2
    jbne rsrc_PACK_4_1BF4_A2
    cmpiw #5,%d5
    jblt rsrc_PACK_4_1BF4_82
rsrc_PACK_4_1BF4_66:    /* loop: add */
    addw %d0,%a2@
    jbcc rsrc_PACK_4_1BF4_82
rsrc_PACK_4_1BF4_6A:    /* loop: cmpa */
    cmpal %a2,%a3
    jbeq rsrc_PACK_4_1BF4_74
    addqw #1,%a2@-
    jbcs rsrc_PACK_4_1BF4_6A
    jbra rsrc_PACK_4_1BF4_82
rsrc_PACK_4_1BF4_74:    /* set %a3@- */
    movew #1,%a3@-
    addqw #1,%d1
    addiw #16,%d6
    lea %a1@(16),%a1
rsrc_PACK_4_1BF4_82:    /* loop: tst */
    tstw %a3@
    jbne rsrc_PACK_4_1BF4_90
    lea %a3@(2),%a3
    subqw #1,%d1
    subiw #16,%d6
rsrc_PACK_4_1BF4_90:    /* return */
    rts
rsrc_PACK_4_1BF4_92:    /* test bit 13 of %d2 */
    btst #13,%d2
    jbne rsrc_PACK_4_1BF4_82
    moveal %fp@(60),%a4
    movew %a4@,%d2
    jbmi rsrc_PACK_4_1BF4_66
    jbra rsrc_PACK_4_1BF4_82
rsrc_PACK_4_1BF4_A2:    /* set %a4 */
    moveal %fp@(60),%a4
    movew %a4@,%d2
    jbpl rsrc_PACK_4_1BF4_66
    jbra rsrc_PACK_4_1BF4_82

/* subroutine (29 instructions) (mechanical summary) */
rsrc_PACK_4_1CA0:
    clrw %d5
    movew %d6,%d3
    addqw #1,%d3
    movel %d3,%d4
    lsrw #4,%d4
    cmpw %d1,%d4
    jble rsrc_PACK_4_1CA0_10
    rts
rsrc_PACK_4_1CA0_10:    /* from here: andiw #15,%d3 */
    andiw #15,%d3
    movew #-32768,%d0
    rorw %d3,%d0
    movew %d4,%d2
    lslw #1,%d2
    lea %a3@(0x0,%d2:w),%a2
    andw %a2@,%d0
    jbeq rsrc_PACK_4_1CA0_28
    moveq #4,%d5
rsrc_PACK_4_1CA0_28:    /* set %d0 */
    movew #32767,%d0
    lsrw %d3,%d0
    andw %a2@+,%d0
    jbeq rsrc_PACK_4_1CA0_3A
rsrc_PACK_4_1CA0_32:    /* loop: addq */
    addqw #2,%d5
    rts
rsrc_PACK_4_1CA0_36:    /* loop: tst */
    tstw %a2@+
    jbne rsrc_PACK_4_1CA0_32
rsrc_PACK_4_1CA0_3A:    /* add 1 to %d4 */
    addqw #1,%d4
    cmpw %d1,%d4
    jble rsrc_PACK_4_1CA0_36
    rts

/* subroutine (9 instructions) (mechanical summary) */
rsrc_PACK_4_1CE2:
    moveal %fp@(60),%a0
    movew %a0@+,%d6
    bclr #15,%d6
    subiw #16396,%d6
    moveal %fp@(-16),%a3
    subaw #52,%a3
    movel %a0@+,%a3@
    movel %a0@+,%a3@(4)
    moveq #3,%d3

/* subroutine (18 instructions) (mechanical summary) */
rsrc_PACK_4_1D00:
    movew %d1,%d7
    aslw #4,%d7
    moveal %fp@(56),%a0
    addqw #2,%a0
    subw %a0@,%d7
    movew %d1,%d5
    aslw #1,%d5
    movew %a1@,%d0
    jbmi rsrc_PACK_4_1D00_2A
rsrc_PACK_4_1D00_14:    /* loop: subq */
    subqw #1,%d7
    movew %d1,%d4
    lea %a1@(0x2,%d5:w),%a0
    movew #0,%ccr
rsrc_PACK_4_1D00_20:    /* loop: rox */
    roxlw %a0@-
    dbf %d4,rsrc_PACK_4_1D00_20
    jbpl rsrc_PACK_4_1D00_14
    movew %a1@,%d0
rsrc_PACK_4_1D00_2A:    /* return */
    rts

/* subroutine (22 instructions) (mechanical summary) */
rsrc_PACK_4_1D2C:
    subw %d7,%d6
    jble rsrc_PACK_4_1D66_5A
    movew %d6,%d4
    asrw #4,%d6
    andiw #15,%d4
    jbeq rsrc_PACK_4_1D2C_2E
    addqw #1,%d3
    clrw %a3@-
    subqw #1,%d4
rsrc_PACK_4_1D2C_16:    /* loop: as */
    aslw %a3@(8)
    roxlw %a3@(6)
    roxlw %a3@(4)
    roxlw %a3@(2)
    roxlw %a3@
    dbf %d4,rsrc_PACK_4_1D2C_16
    jbra rsrc_PACK_4_1D66
rsrc_PACK_4_1D2C_2E:    /* test %a3@,%d0 */
    cmpw %a3@,%d0
    jbhi rsrc_PACK_4_1D2C_38
    addqw #1,%d3
    clrw %a3@-
    jbra rsrc_PACK_4_1D66
rsrc_PACK_4_1D2C_38:    /* subtract 1 to %d6 */
    subqw #1,%d6

/* subroutine (42 instructions): calls rsrc_PACK_4_1DC6, rsrc_PACK_4_1DE4, rsrc_PACK_4_1E04 (mechanical summary) */
rsrc_PACK_4_1D66:
    jbsr rsrc_PACK_4_1DC6
    moveal %a3,%a0
rsrc_PACK_4_1D66_4:     /* loop: move */
    movel %a0@,%d2
    divuw %d0,%d2
    jbvs rsrc_PACK_4_1E04_1E
    swap %d2
    movel %d2,%a0@
    swap %d2
    lea %a0@(2),%a0
    cmpiw #2,%d5
    jblt rsrc_PACK_4_1D66_4A
    jbeq rsrc_PACK_4_1D66_36
    movew %d5,%d7
    bclr #1,%d7
    jbsr rsrc_PACK_4_1DE4
    moveq #0,%d4
    movew %a4@-,%d1
    subxw %d4,%d1
    movew %d1,%a4@
    negxw %d7
    tstw %d7
    jbne rsrc_PACK_4_1D66_36
    jbsr rsrc_PACK_4_1E04
rsrc_PACK_4_1D66_36:    /* set %d7 */
    movew %d5,%d7
    btst #1,%d7
    jbne rsrc_PACK_4_1D66_40
    subqw #2,%d7
rsrc_PACK_4_1D66_40:    /* call rsrc_PACK_4_1DE4 */
    jbsr rsrc_PACK_4_1DE4
    negxw %d7
    tstw %d7
    jbne rsrc_PACK_4_1D66_4A
    jbsr rsrc_PACK_4_1E04
rsrc_PACK_4_1D66_4A:    /* count down (loop) */
    dbf %d6,rsrc_PACK_4_1D66_4
rsrc_PACK_4_1D66_4E:    /* loop: suba */
    subal %a3,%a0
    movew %a0,%d6
    movew %d3,%d1
    aslw #3,%d6
    subqw #3,%d6
    rts
rsrc_PACK_4_1D66_5A:    /* set %a0 */
    moveal %a3,%a0
    clrw %a3@-
    jbra rsrc_PACK_4_1D66_4E

/* subroutine (13 instructions) (mechanical summary) */
rsrc_PACK_4_1DC6:
    movew %d1,%d7
    addw %d6,%d7
    addqw #1,%d7
    subw %d3,%d7
    jble rsrc_PACK_4_1DC6_1C
    movew %d3,%d2
    aslw #1,%d2
    lea %a3@(0x2,%d2:w),%a2
    addw %d7,%d3
    asrw #1,%d7
rsrc_PACK_4_1DC6_16:    /* loop: clr */
    clrl %a2@+
    dbf %d7,rsrc_PACK_4_1DC6_16
rsrc_PACK_4_1DC6_1C:    /* return */
    rts

/* subroutine (12 instructions) (mechanical summary) */
rsrc_PACK_4_1DE4:
    lea %a1@(0x2,%d7:w),%a2
    lea %a0@(0x2,%d7:w),%a4
    subqw #2,%d7
    asrw #2,%d7
    movew #0,%ccr
rsrc_PACK_4_1DE4_10:    /* loop: move */
    movel %a2@-,%d4
    muluw %d2,%d4
    movel %a4@-,%d1
    subxl %d4,%d1
    movel %d1,%a4@
    dbf %d7,rsrc_PACK_4_1DE4_10
    rts

/* subroutine (22 instructions): calls rsrc_PACK_4_1E04 (mechanical summary) */
rsrc_PACK_4_1E04:
    subqw #1,%a0@(-2)
    movel %d5,%d1
    lea %a1@(0x2,%d1:w),%a2
    lea %a0@(0x2,%d1:w),%a4
    asrw #1,%d1
    movew #0,%ccr
rsrc_PACK_4_1E04_14:    /* loop: addx */
    addxw %a2@-,%a4@-
    dbf %d1,rsrc_PACK_4_1E04_14
    jbcc rsrc_PACK_4_1E04
    rts
rsrc_PACK_4_1E04_1E:    /* clear %a0@+ */
    clrw %a0@+
    movew %d5,%d7
    jbeq rsrc_PACK_4_1E04
    lea %a1@(0x2,%d7:w),%a2
    lea %a0@(0x0,%d7:w),%a4
    asrw #1,%d7
    subqw #1,%d7
    movew #0,%ccr
rsrc_PACK_4_1E04_34:    /* loop: subx */
    subxw %a2@-,%a4@-
    dbf %d7,rsrc_PACK_4_1E04_34
    jbsr rsrc_PACK_4_1E04
    jbra rsrc_PACK_4_1D66_4A

/* subroutine (8 instructions) (mechanical summary) */
rsrc_PACK_4_1E44:
    negw %d0
    cmpiw #5208,%d0
    jbcs rsrc_PACK_4_1E58_C
    movew #5207,%d0
    movew %d0,%d1
    negw %d1
    movew %d1,%a0@
    jbra rsrc_PACK_4_1E58_C

/* subroutine (75 instructions): traps StackSpace, SysError; calls rsrc_PACK_4_1F7E, rsrc_PACK_4_1F92, rsrc_PACK_4_1F26 (mechanical summary) */
rsrc_PACK_4_1E58:
    cmpiw #5008,%d0
    jbcs rsrc_PACK_4_1E58_C
    movew #5007,%d0
    movew %d0,%a0@
rsrc_PACK_4_1E58_C:     /* clear %d4 */
    moveq #0,%d4
    movew %d0,%d4
    addiw #527,%d4
    andib #0xf8,%d4
    cmpiw #3136,%d4
    jbcs rsrc_PACK_4_1E58_22
    movew #3136,%d4
rsrc_PACK_4_1E58_22:    /* set up and call _StackSpace */
    movew %d4,%d5
    asrw #2,%d5
    movel %d0,%d1
    _StackSpace
    cmpl %d4,%d0
    jbpl rsrc_PACK_4_1E58_32
    moveq #28,%d0
    _SysError
rsrc_PACK_4_1E58_32:    /* set %d0 */
    movel %d1,%d0
    moveal %sp@+,%a1
    subaw %d4,%sp
    movel %a1,%sp@-
    lea %fp@(-40),%a1
    movel %a1,%fp@(-4)
    subaw %d4,%a1
    movel %a1,%fp@(-16)
    addaw %d5,%a1
    movel %a1,%fp@(-12)
    addaw %d5,%a1
    movel %a1,%fp@(-8)
    moveal %fp@(-4),%a1
    moveq #0,%d2
    movew %d0,%d2
    divuw #21,%d2
    movew %d2,%d0
    swap %d2
    cmpiw #7,%d2
    jblt rsrc_PACK_4_1E58_94
    cmpiw #14,%d2
    jbge rsrc_PACK_4_1E58_80
    moveq #1,%d1
    lea %pc@(rsrc_PACK_4_203A),%a2
    subqw #7,%d2
    aslw #2,%d2
    movel %a2@(0x0,%d2:w),%a1@-
    jbra rsrc_PACK_4_1E58_A0
rsrc_PACK_4_1E58_80:    /* set %d1 */
    moveq #2,%d1
    lea %pc@(rsrc_PACK_4_2056),%a2
    subiw #14,%d2
    muluw #6,%d2
    movel %a2@(0x2,%d2:w),%a1@-
    jbra rsrc_PACK_4_1E58_9C
rsrc_PACK_4_1E58_94:    /* clear %d1 */
    moveq #0,%d1
    lea %pc@(rsrc_PACK_4_202C),%a2
    aslw #1,%d2
rsrc_PACK_4_1E58_9C:    /* set %a1@- */
    movew %a2@(0x0,%d2:w),%a1@-
rsrc_PACK_4_1E58_A0:    /* test %d0 */
    tstw %d0
    jbne rsrc_PACK_4_1E58_A6
    rts
rsrc_PACK_4_1E58_A6:    /* call rsrc_PACK_4_1F7E */
    jbsr rsrc_PACK_4_1F7E
    moveq #3,%d2
    moveal %fp@(-8),%a2
    subql #4,%a2
    movel #1299066613,%a2@
    movel #111022,%a2@-
    jbra rsrc_PACK_4_1E58_C2
rsrc_PACK_4_1E58_BE:    /* call rsrc_PACK_4_1F7E (loop) */
    jbsr rsrc_PACK_4_1F7E
rsrc_PACK_4_1E58_C0:    /* call rsrc_PACK_4_1F92 (loop) */
    jbsr rsrc_PACK_4_1F92
rsrc_PACK_4_1E58_C2:    /* from here: asrw #1,%d0 */
    asrw #1,%d0
    jbcc rsrc_PACK_4_1E58_C0
    jbsr rsrc_PACK_4_1F26
    tstw %d0
    jbgt rsrc_PACK_4_1E58_BE
    rts

/* subroutine (36 instructions) (mechanical summary) */
rsrc_PACK_4_1F26:
    movew %d2,%d1
    addw %d3,%d1
    addqw #1,%d1
    movew %d3,%d7
    addqw #1,%d7
    lsrw #1,%d7
    moveal %fp@(-4),%a1
rsrc_PACK_4_1F26_10:    /* loop: clr */
    clrl %a1@-
    dbf %d7,rsrc_PACK_4_1F26_10
    moveal %fp@(-4),%a4
    subql #2,%a4
    moveal %fp@(-8),%a2
    subql #2,%a2
    movew %d2,%d5
    jbra rsrc_PACK_4_1F26_2C
rsrc_PACK_4_1F26_26:    /* loop: clr */
    clrw %a1@-
    subql #2,%a2
    subql #2,%a4
rsrc_PACK_4_1F26_2C:    /* set %a1 */
    moveal %a4,%a1
    moveal %fp@(-12),%a3
    movew %d3,%d6
rsrc_PACK_4_1F26_34:    /* loop: move */
    movew %a3@-,%d7
    muluw %a2@,%d7
    subqw #2,%a1
    addl %d7,%a1@
    jbcc rsrc_PACK_4_1F26_44
    moveal %a1,%a0
rsrc_PACK_4_1F26_40:    /* loop: addq */
    addql #1,%a0@-
    jbcs rsrc_PACK_4_1F26_40
rsrc_PACK_4_1F26_44:    /* count down */
    dbf %d6,rsrc_PACK_4_1F26_34
    dbf %d5,rsrc_PACK_4_1F26_26
    tstw %a1@
    jbne rsrc_PACK_4_1F26_56
    lea %a1@(2),%a1
    subqw #1,%d1
rsrc_PACK_4_1F26_56:    /* return */
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_PACK_4_1F7E:
    movew %d1,%d3
    moveal %fp@(-4),%a1
    moveal %fp@(-12),%a3
    lsrw #1,%d1
rsrc_PACK_4_1F7E_C:     /* loop: move */
    movel %a1@-,%a3@-
    dbf %d1,rsrc_PACK_4_1F7E_C
    rts

/* subroutine (54 instructions) (mechanical summary) */
rsrc_PACK_4_1F92:
    movew %d2,%d1
    movew %d1,%d7
    aslw #1,%d1
    addqw #1,%d1
    moveal %fp@(-4),%a1
rsrc_PACK_4_1F92_C:     /* loop: clr */
    clrl %a1@-
    dbf %d7,rsrc_PACK_4_1F92_C
    movew %d2,%d5
    subqw #1,%d5
    jbmi rsrc_PACK_4_1F92_5A
    moveal %fp@(-4),%a4
    subql #4,%a4
    moveal %fp@(-8),%a2
    subql #2,%a2
    jbra rsrc_PACK_4_1F92_2A
rsrc_PACK_4_1F92_26:    /* loop: subq */
    subqw #2,%a2
    subqw #4,%a4
rsrc_PACK_4_1F92_2A:    /* set %a1 */
    moveal %a4,%a1
    moveal %a2,%a3
    movew %d5,%d6
rsrc_PACK_4_1F92_30:    /* loop: move */
    movew %a3@-,%d7
    muluw %a2@,%d7
    subqw #2,%a1
    addl %d7,%a1@
    jbcc rsrc_PACK_4_1F92_42
    moveal %a1,%a0
rsrc_PACK_4_1F92_3C:    /* loop: addq */
    addql #1,%a1@-
    jbcs rsrc_PACK_4_1F92_3C
    moveal %a0,%a1
rsrc_PACK_4_1F92_42:    /* count down */
    dbf %d6,rsrc_PACK_4_1F92_30
    dbf %d5,rsrc_PACK_4_1F92_26
    moveal %fp@(-4),%a1
    movew #0,%ccr
    movew %d1,%d7
rsrc_PACK_4_1F92_54:    /* loop: rox */
    roxlw %a1@-
    dbf %d7,rsrc_PACK_4_1F92_54
rsrc_PACK_4_1F92_5A:    /* set %a1 */
    moveal %fp@(-4),%a1
    moveal %fp@(-8),%a2
rsrc_PACK_4_1F92_62:    /* loop: move */
    movew %a2@-,%d7
    muluw %d7,%d7
    addl %d7,%a1@-
    jbcc rsrc_PACK_4_1F92_72
    moveal %a1,%a0
rsrc_PACK_4_1F92_6C:    /* loop: addq */
    addql #1,%a1@-
    jbcs rsrc_PACK_4_1F92_6C
    moveal %a0,%a1
rsrc_PACK_4_1F92_72:    /* count down */
    dbf %d2,rsrc_PACK_4_1F92_62
    tstw %a1@
    jbne rsrc_PACK_4_1F92_80
    lea %a1@(2),%a1
    subqw #1,%d1
rsrc_PACK_4_1F92_80:    /* test %d0 */
    tstw %d0
    jbne rsrc_PACK_4_2018
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_PACK_4_2018:
    movew %d1,%d2
    moveal %fp@(-4),%a1
    moveal %fp@(-8),%a2
    lsrw #1,%d1
rsrc_PACK_4_2018_C:     /* loop: move */
    movel %a1@-,%a2@-
    dbf %d1,rsrc_PACK_4_2018_C
    rts

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_4_202C:
    .long   0x00010005	| 4087596C
    .short  0x0019, 0x007D, 0x0271, 0x0C35, 0x3D09	| 40875970
rsrc_PACK_4_203A:       /* (data) */
    .short  0x0001, 0x312D, 0x0005	| 4087597A
    .long   0xF5E1001D, 0xCD650095, 0x02F902E9, 0x0EDD0E8D	| 40875980
    .short  0x4A51, 0x48C2, 0x7395	| 40875990
rsrc_PACK_4_2056:       /* (data) */
    .short  0x0001, 0x6BCC, 0x41E9, 0x0007, 0x1AFD	| 40875996
    .long   0x498D0023, 0x86F26FC1, 0x00B1A2BC, 0x2EC50378	| 408759A0
    .long   0x2DACE9D9, 0x1158E460, 0x913D56BC, 0x75E2D631	| 408759B0
    .fill   0xA1B, 1, 0x00
rsrc_PACK_4_2A9B:       /* (unused, zeros) */
    .fill   0xE5, 1, 0x00
