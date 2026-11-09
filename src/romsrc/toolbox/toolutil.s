/*
 toolbox/toolutil.s - Toolbox utilities: Munger, handle/pointer utilities, fixed-point math
 From IAPPEND (0x4081C0AA). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* IAPPEND: append helper. */
IAPPEND:
    .short  0x0000, 0x0000, 0x0000	| 4081C0AA

/* MUNGER: _Munger: search and replace in a handle. */
trap_Munger:
BYTES:
MUNGER:
    linkw %fp,#-8
    moveml %d2-%d7/%a2-%a4,%sp@-
    moveal %fp@(28),%a2
    moveal %a2,%a0
    _GetHandleSize
    movel %d0,%d5
    movel %d0,%fp@(-8)
    clrl %fp@(-4)
    jbsr XMUNGER_28
    movel %d2,%fp@(32)
    moveq #24,%d1
BYTES_22:               /* restore registers, return */
    moveml %sp@+,%d2-%d7/%a2-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw %d1,%sp
    jmp %a0@

trap_XMunger:
XMUNGER:                /* entry: stack frame */
    linkw %fp,#-8
    moveml %d2-%d7/%a2-%a4,%sp@-
    moveal %fp@(28),%a2
    moveal %a2,%a0
    _GetHandleSize
    movel %d0,%fp@(-8)
    movel %fp@(36),%d5
    movel %fp@(32),%fp@(-4)
    jbsr XMUNGER_28
    movel %d2,%fp@(40)
    moveq #32,%d1
    jbra BYTES_22

XMUNGER_28:             /* set %d2 */
    movel %fp@(24),%d2
    moveal %fp@(20),%a3
    moveal %fp@(12),%a4
    movel %fp@(16),%d3
    jbeq XMUNGER_D6
    jbpl XMUNGER_42
XMUNGER_3E:             /* loop: move */
    movel %d5,%d3
    subl %d2,%d3
XMUNGER_42:             /* set %d0 */
    movel %d5,%d0
    subl %d3,%d0
    jblt XMUNGER_78
    subl %d2,%d0
    jblt XMUNGER_3E
    movel %a3,%d0
    jbeq XMUNGER_B6
    movel %a2@,%d6
    movel %d5,%d7
    subl %d3,%d7
    addl %d6,%d7
    addl %d2,%d6
XMUNGER_5A:             /* loop: move */
    movel %d3,%d1
    subql #1,%d1
    moveal %d6,%a0
    moveal %a3,%a1
XMUNGER_62:             /* loop: cmp */
    cmpl %d6,%d7
    jbcs XMUNGER_78
    cmpmb %a0@+,%a1@+
    jbne XMUNGER_74
    dbf %d1,XMUNGER_62
    movel %d6,%d2
    subl %a2@,%d2
    jbra XMUNGER_B2
XMUNGER_74:             /* add 1 to %d6 */
    addql #1,%d6
    jbra XMUNGER_5A
XMUNGER_78:             /* set %d2 */
    moveq #-1,%d2
    jbra XMUNGER_D4

XMUNGER_7C:             /* loop: cmpa */
    cmpal %a0,%a1
    jbeq XMUNGER_8E
    subql #1,%d0
    jble XMUNGER_8A
    addql #1,%d0
    _BlockMove
    rts
XMUNGER_8A:             /* from here: jblt XMUNGER_8E */
    jblt XMUNGER_8E
    moveb %a0@,%a1@
XMUNGER_8E:             /* result 0 */
    moveq #0,%d0
    rts

XMUNGER_92:             /* loop: move */
    movel %d0,%sp@-
    subl %fp@(-8),%d0
    jbeq XMUNGER_A4
    jbgt XMUNGER_A8
    negl %d0
    cmpl %fp@(-4),%d0
    jbgt XMUNGER_A8
XMUNGER_A4:             /* add 4 to %sp */
    addqw #4,%sp
    jbra XMUNGER_8E
XMUNGER_A8:             /* set up and call _SetHandleSize */
    movel %sp@+,%d0
    addl %fp@(-4),%d0
    _SetHandleSize
    rts

XMUNGER_B2:             /* set %d0 */
    movel %a4,%d0
    jbeq XMUNGER_D4
XMUNGER_B6:             /* set %d4 */
    movel %fp@(8),%d4
    jbne XMUNGER_104
    movel %d5,%d0
    subl %d3,%d0
    movel %d0,%d5
    subl %d2,%d0
    moveal %a2@,%a1
    addal %d2,%a1
    moveal %a1,%a0
    addal %d3,%a0
    jbsr XMUNGER_7C
    moveal %a2,%a0
    movel %d5,%d0
    jbsr XMUNGER_92
XMUNGER_D4:             /* continue at XMUNGER_102 */
    jbra XMUNGER_102
XMUNGER_D6:             /* set %d4 */
    movel %fp@(8),%d4
    jbeq XMUNGER_102
    movel %d5,%d0
    addl %d4,%d0
    moveal %a2,%a0
    jbsr XMUNGER_92
    jbne XMUNGER_102
    moveal %a2@,%a1
    addal %d2,%a1
    moveal %a1,%a0
    addal %d4,%a1
    movel %d5,%d0
    subl %d2,%d0
    jbsr XMUNGER_7C
XMUNGER_F4:             /* loop: movea */
    moveal %a2@,%a1
    addal %d2,%a1
    moveal %a4,%a0
    movel %d4,%d0
    jbsr XMUNGER_7C
    addl %d4,%d2
XMUNGER_102:            /* return */
    rts
XMUNGER_104:            /* set %d1 */
    movel %d4,%d1
    subl %d3,%d1
    jbeq XMUNGER_F4
    jbgt XMUNGER_10E
    jbsr XMUNGER_122
XMUNGER_10E:            /* set %a0 */
    moveal %a2,%a0
    movel %d5,%d0
    addl %d1,%d0
    jbsr XMUNGER_92
    jbne XMUNGER_102
    tstl %d1
    jbmi XMUNGER_F4
    jbsr XMUNGER_122
    jbra XMUNGER_F4

XMUNGER_122:            /* set %a1 */
    moveal %a2@,%a1
    addal %d2,%a1
    moveal %a1,%a0
    addal %d3,%a0
    addal %d4,%a1
    movel %d5,%d0
    subl %d3,%d0
    subl %d2,%d0
    jbra XMUNGER_7C

/* HANDTOHAND: _HandToHand. */
trap_HandToHand:
HANDTOHAND:
    .short 0xA069	| 4081C214 _HGetState (flags 0x0000)
    moveb %d0,%sp@-
    movel %a0,%sp@-
    _HNoPurge
    moveal %a0,%a1
    _GetHandleSize
    tstl %d0
    jbmi HANDTOHAND_18
    movel %d0,%d1
    .short  0xA122	| 4081C226 _NewHandle (flags 0x0100)
    moveal %a1@,%a1
    jbsr PTRTOHAND_6
HANDTOHAND_18:          /* set %d1 */
    movel %d0,%d1
    moveal %a0,%a1
    moveal %sp@+,%a0
    moveb %sp@+,%d0
    _HSetState
    movel %d1,%d0
    moveal %a1,%a0
    rts

/* PTRTOXHAND: _PtrToXHand. */
trap_PtrToXHand:
PTRTOXHAND:
    exg %a0,%a1
    movel %d0,%d1
    _SetHandleSize
    jbra PTRTOHAND_6

/* PTRTOHAND: _PtrToHand. */
trap_PtrToHand:
PTRTOHAND:
    moveal %a0,%a1
    movel %d0,%d1
    .short  0xA122	| 4081C248 _NewHandle (flags 0x0100)

PTRTOHAND_6:            /* from here: jbne PTRTOHAND_18 */
    jbne PTRTOHAND_18
    moveq #0,%d2
PTRTOHAND_A:            /* loop: move */
    movel %a0,%sp@-
    moveal %a0@,%a0
    addal %d2,%a0
    exg %a0,%a1
    movel %d1,%d0
    _BlockMove
    moveal %sp@+,%a0
PTRTOHAND_18:           /* return */
    rts

/* HANDANDHAND: _HandAndHand. */
trap_HandAndHand:
HANDANDHAND:
    _HGetState
    moveb %d0,%sp@-
    movel %a0,%sp@-
    _HNoPurge
    _GetHandleSize
    tstl %d0
    bmis HANDTOHAND_18
    movel %d0,%d1
    exg %a1,%a0
    _GetHandleSize
    movel %d0,%d2
    bmis HANDTOHAND_18
    addl %d1,%d0
    _SetHandleSize
    bnes HANDTOHAND_18
    moveal %a1@,%a1
    bsrs PTRTOHAND_A
    bras HANDTOHAND_18

/* PTRANDHAND: _PtrAndHand. */
trap_PtrAndHand:
PTRANDHAND:
    movel %d0,%d1
    exg %a1,%a0
    _GetHandleSize
    movel %d0,%d2
    addl %d1,%d0
    _SetHandleSize
    jbne PTRTOHAND_18
    jbra PTRTOHAND_A

/* METHODDISPATCH: _MethodDispatch (object Pascal). */
trap_MethodDispatch:
METHODDISPATCH:
    moveal %sp@+,%a0
    moveal %sp@(4),%a1
    moveal %a1@,%a1
    movew %a1@,%d0
    movew %a0@+,%d1
    cmpw %a0@,%d0
    jbne METHODDISPATCH_22
METHODDISPATCH_10:      /* loop: move */
    movew %a0@(2),%d0
    bclr #0,%d0
    jbne METHODDISPATCH_1E
    jmp %a5@(0x0,%d0:w)
METHODDISPATCH_1E:      /* jump through %a0@(0x2,%d0:w) */
    jmp %a0@(0x2,%d0:w)
METHODDISPATCH_22:      /* set %a0@ */
    movew %d0,%a0@
    movel %a0,%d2
METHODDISPATCH_26:      /* loop: addq */
    addql #4,%a0
    cmpw %a0@,%d0
    dbcc %d1,METHODDISPATCH_26
    jbeq METHODDISPATCH_52
    moveal MASuperTab,%a1
    moveal %a1@,%a1
    jbra METHODDISPATCH_42
METHODDISPATCH_38:      /* loop: addq */
    addql #4,%a0
METHODDISPATCH_3A:      /* loop: cmp */
    cmpw %a0@,%d0
    dbcc %d1,METHODDISPATCH_38
    jbeq METHODDISPATCH_52
METHODDISPATCH_42:      /* set %d0 */
    movew %a1@(0x0,%d0:w),%d0
    jbne METHODDISPATCH_3A
    moveal %d2,%a1
    clrl %a1@
    moveal MAErrProc,%a1
    jmp %a1@
METHODDISPATCH_52:      /* set %a1 */
    moveal %d2,%a1
    movew %a0@(2),%a1@(2)
    jbra METHODDISPATCH_10

/* LONGMUL: _LongMul. */
trap_LongMul:
LONGMUL:
    moveml %d0-%d1,%sp@-
    movel %sp@(16),%d1
    mulsl %sp@(20),%d0,%d1
    moveal %sp@(12),%a0
    movel %d0,%a0@+
    movel %d1,%a0@+
    moveml %sp@+,%d0-%d1
    rtd #12

/* FRACMUL: _FracMul. */
trap_FracMul:
FRACMUL:
    lea 0x3,%a0
    jbra FIXMUL_18

/* FIXMUL: _FixMul. */
trap_FixMul:
FIXMUL:
    cmpil #65536,%sp@(4)
    jbeq FIXMUL_7E
    cmpil #65536,%sp@(8)
    jbeq FIXMUL_88
    lea 0x11,%a0
FIXMUL_18:              /* save registers */
    moveml %d0-%d2/%a1,%sp@-
    movel %sp@(20),%d1
    smi %d2
    tstl %sp@(24)
    smi %d0
    eorb %d0,%d2
    extbl %d2
    mulsl %sp@(24),%d0,%d1
    movel %d1,%sp@-
    movel %d0,%sp@-
    movel %a0,%d0
    bfexts %sp@,0,%d0,%d1
    cmpw %d1,%d2
    jbeq FIXMUL_4E
    movel %sp@+,%d1
    orl %sp@+,%d1
    jbeq FIXMUL_72
    moveq #-1,%d1
    lsrl #1,%d1
    eorl %d2,%d1
    jbra FIXMUL_72
FIXMUL_4E:              /* subtract 1 to %d0 */
    subqw #1,%d0
    bfexts %sp@,%d0,0,%d1
    addiw #32,%d0
    bfextu %sp@,%d0,1,%d2
    jbeq FIXMUL_70
    tstl %d1
    jbpl FIXMUL_6E
    addqw #1,%d0
    moveq #64,%d2
    subw %d0,%d2
    bfextu %sp@,%d0,%d2,%d0
    jbeq FIXMUL_70
FIXMUL_6E:              /* add 1 to %d1 */
    addql #1,%d1
FIXMUL_70:              /* add 8 to %sp */
    addqw #8,%sp
FIXMUL_72:              /* set %sp@(28) */
    movel %d1,%sp@(28)
    moveml %sp@+,%d0-%d2/%a1
    rtd #8
FIXMUL_7E:              /* set %sp@(12) */
    movel %sp@(8),%sp@(12)
    rtd #8
FIXMUL_88:              /* set %sp@(12) */
    movel %sp@(4),%sp@(12)
    rtd #8

FIXMUL_92:              /* loop: tst */
    tstl %d0
    jbmi FIXMUL_E2
    tstb %d6
    jbeq FIXMUL_9C
    negl %d0
FIXMUL_9C:              /* result 8 */
    movew #8,%fp@(8)
    movel %d0,%fp@(16)
    jbra FIXMUL_B2

FIXMUL_A8:              /* result 4 */
    movew #4,%fp@(8)
    movel %d0,%fp@(12)
FIXMUL_B2:              /* restore registers, return */
    moveml %sp@+,%d0-%d6/%a1
    unlk %fp
    moveal %sp@+,%a0
    addaw %sp@,%sp
    jmp %a0@

FIXMUL_BE:              /* loop: movea */
    moveal %sp@+,%a0
    linkw %fp,#0
    moveml %d0-%d6/%a1,%sp@-
    jmp %a0@

FIXMUL_CA:              /* restore registers */
    moveml %fp@(8),%d1-%d2
    tstl %d1
    smi %d6
    jbpl FIXMUL_D8
    negl %d1
FIXMUL_D8:              /* test %d2 */
    tstl %d2
    jbpl FIXMUL_E0
    negl %d2
    notb %d6
FIXMUL_E0:              /* return */
    rts

FIXMUL_E2:              /* loop: moveq */
    moveq #1,%d0
    rorl #1,%d0
    tstb %d6
    jbne FIXMUL_9C
    subql #1,%d0
    jbra FIXMUL_9C

/* FRACDIV: _FracDiv. */
trap_FracDiv:
FRACDIV:
    jbsr FIXMUL_BE
    moveq #31,%d3
    jbra FIXDIV_4

/* FIXDIV: _FixDiv. */
trap_FixDiv:
FIXDIV:
    jbsr FIXMUL_BE
    moveq #17,%d3
FIXDIV_4:               /* call FIXMUL_CA */
    jbsr FIXMUL_CA
    moveq #0,%d0
    tstl %d1
    jbne FIXDIV_12
    jbra FIXMUL_E2
FIXDIV_E:               /* loop: addq */
    addqw #1,%d3
    addl %d1,%d1
FIXDIV_12:              /* from here: jbpl FIXDIV_E */
    jbpl FIXDIV_E
    tstl %d2
    jbeq FIXMUL_9C
    jbra FIXDIV_1E
FIXDIV_1A:              /* loop: subq */
    subqw #1,%d3
    addl %d2,%d2
FIXDIV_1E:              /* from here: jbpl FIXDIV_1A */
    jbpl FIXDIV_1A
    tstw %d3
    jble FIXMUL_9C
    cmpiw #32,%d3
    jblt FIXDIV_38
    jbgt FIXMUL_E2
    cmpl %d1,%d2
    jbcs FIXDIV_40
    jbra FIXMUL_E2
FIXDIV_32:              /* loop: add */
    addl %d0,%d0
    addl %d2,%d2
    jbcs FIXDIV_3C
FIXDIV_38:              /* test %d1,%d2 */
    cmpl %d1,%d2
    jbcs FIXDIV_40
FIXDIV_3C:              /* from here: subl %d1,%d2 */
    subl %d1,%d2
    addqw #1,%d0
FIXDIV_40:              /* count down */
    dbf %d3,FIXDIV_32
    lsrl #1,%d0
    jbcc FIXMUL_92
    addql #1,%d0
    jbra FIXMUL_92

/* FRACSQRT: _FracSqrt. */
trap_FracSqrt:
FRACSQRT:
    jbsr FIXMUL_BE
    movel %fp@(8),%d3
    moveq #0,%d0
    moveq #1,%d1
    rorl #2,%d1
    moveq #0,%d2
    moveq #31,%d4
FRACSQRT_12:            /* loop: su */
    subl %d1,%d3
    subxl %d0,%d2
    jbcc FRACSQRT_1C
    addl %d1,%d3
    addxl %d0,%d2
FRACSQRT_1C:            /* from here: eorib #16,%ccr */
    eorib #16,%ccr
    addxl %d0,%d0
    addl %d3,%d3
    addxl %d2,%d2
    addl %d3,%d3
    addxl %d2,%d2
    dbf %d4,FRACSQRT_12
    lsrl #1,%d0
    jbcc FIXMUL_A8
    addql #1,%d0
    jbra FIXMUL_A8

/* FIXRATIO: _FixRatio. */
trap_FixRatio:
FIXRATIO:
    movew %sp@(4),%d0
    jbeq FIXRATIO_20
    moveq #0,%d1
    movew %sp@(6),%d1
    cmpw %d0,%d1
    jbeq FIXRATIO_34
    extl %d0
    swap %d1
    divsll %d0,%d1,%d1
    movel %d1,%sp@(8)
    rtd #4
FIXRATIO_20:            /* set %d1 */
    moveq #-1,%d1
    lsrl #1,%d1
    tstw %sp@(6)
    jbpl FIXRATIO_2C
    negl %d1
FIXRATIO_2C:            /* set %sp@(8) */
    movel %d1,%sp@(8)
    rtd #4
FIXRATIO_34:            /* set %d1 */
    moveq #1,%d1
    swap %d1
    movel %d1,%sp@(8)
    rtd #4
    tstb %d6
    jbeq FIXRATIO_46
    negl %d0
FIXRATIO_46:            /* continue at FIXMUL_A8 */
    jbra FIXMUL_A8
    moveq #1,%d0
    swap %d0
    braw FIXMUL_A8

/* LOWORD: _LoWord. */
trap_LoWord:
LOWORD:
    movew %sp@(6),%sp@(8)
    jbra HIWORD_6

/* HIWORD: _HiWord. */
trap_HiWord:
HIWORD:
    movew %sp@(4),%sp@(8)
HIWORD_6:               /* set %sp@ */
    movel %sp@+,%sp@
    rts

/* FIXROUND: _FixRound. */
trap_FixRound:
FIXROUND:
    moveal %sp@+,%a0
    moveq #1,%d1
    rorw #1,%d1
    movel %sp@+,%d0
    jbpl FIXROUND_C
    notw %d1
FIXROUND_C:             /* from here: addl %d1,%d0 */
    addl %d1,%d0
    jbvc FIXROUND_14
    moveq #-2,%d0
    rorl #1,%d0
FIXROUND_14:            /* from here: swap %d0 */
    swap %d0
    movew %d0,%sp@
    jmp %a0@

/* FRACCOS: _FracCos. */
trap_FracCos:
FRACCOS:
    jbsr FIXMUL_BE
    moveq #2,%d6
    jbra FRACSIN_6

/* FRACSIN: _FracSin. */
trap_FracSin:
FRACSIN:
    jbsr FIXMUL_BE
    moveq #0,%d6
FRACSIN_6:              /* set %d3 */
    movel %fp@(8),%d3
    jbpl FRACSIN_14
    tstl %d6
    jbne FRACSIN_12
    addqw #4,%d6
FRACSIN_12:             /* from here: negl %d3 */
    negl %d3
FRACSIN_14:             /* set %d5 */
    movel #51472,%d5
    divuw %d5,%d3
    addl %d3,%d6
    clrw %d3
    swap %d3
    btst #0,%d6
    jbeq FRACSIN_2C
    subw %d5,%d3
    negw %d3
FRACSIN_2C:             /* from here: swap %d3 */
    swap %d3
    lsrl #3,%d3
    movel %a2,%sp@-
    subaw #16,%sp
    movel %d3,%sp@-
    movel %d3,%sp@-
    jbsr trap_FracMul
    movel %sp@+,%d5
    moveb #102,%sp@-
    btst %d6,%sp@+
    jbne FRACSIN_50
    lea %pc@(FRACSIN_8A),%a2
    moveq #4,%d4
    jbra FRACSIN_56
FRACSIN_50:             /* address %pc@(FRACSIN_96) */
    lea %pc@(FRACSIN_96),%a2
    moveq #8,%d4
FRACSIN_56:             /* set %sp@- */
    movel %a2@(0x4,%d4:w),%sp@-
FRACSIN_5A:             /* loop: move */
    movel %d5,%sp@-
    jbsr trap_FracMul
    movel %a2@(0x0,%d4:w),%d0
    addl %d0,%sp@
    subqw #4,%d4
    jbpl FRACSIN_5A
    moveb #102,%sp@-
    btst %d6,%sp@+
    jbne FRACSIN_78
    movel %d3,%sp@-
    jsr %pc@(trap_FracMul)
FRACSIN_78:             /* set %d0 */
    movel %sp@+,%d0
    moveal %sp@+,%a2
    moveb #0xf0,%sp@-
    btst %d6,%sp@+
    jbeq FRACSIN_86
    negl %d0
FRACSIN_86:             /* continue at FIXMUL_A8 */
    jbra FIXMUL_A8
FRACSIN_8A:             /* (data) */
    .long   0x7FFFD609, 0xAAB3314D, 0x10A208E5	| 4081C5A0
FRACSIN_96:             /* (data) */
    .long   0x40000000	| 4081C5AC
    .long   0x800011A7, 0x2AA7F29A, 0xFA6E2A42	| 4081C5B0

/* FIXATAN2: _FixATan2. */
trap_FixATan2:
FIXATAN2:
    jbsr FIXMUL_BE
    moveq #0,%d6
    movel %fp@(12),%d3
    jbpl FIXATAN2_14
    addqw #2,%d6
    negl %d3
    jbpl FIXATAN2_14
    subqw #1,%d3
FIXATAN2_14:            /* set %d0 */
    movel %fp@(8),%d0
    jbpl FIXATAN2_22
    addqw #1,%d6
    negl %d0
    jbpl FIXATAN2_22
    subqw #1,%d0
FIXATAN2_22:            /* set %sp@- */
    movel %a2,%sp@-
    subaw #32,%sp
    cmpl %d3,%d0
    jble FIXATAN2_3E
    addqw #4,%d6
    movel %d3,%sp@-
    jbeq FIXATAN2_36
    movel %d0,%sp@-
    jbra FIXATAN2_44
FIXATAN2_36:            /* set %d0 */
    movel %d3,%d0
FIXATAN2_38:            /* loop: adda */
    addaw #36,%sp
    jbra FIXATAN2_7C
FIXATAN2_3E:            /* set %sp@- */
    movel %d0,%sp@-
    jbeq FIXATAN2_38
    movel %d3,%sp@-
FIXATAN2_44:            /* call trap_FracDiv */
    jbsr trap_FracDiv
    movel %sp@,%d3
    movel %sp@,%sp@-
    jbsr trap_FracMul
    movel %sp@+,%d5
    lea %pc@(FIXATAN2_A6),%a2
    movel %a2@(20),%sp@-
    moveq #16,%d4
FIXATAN2_5C:            /* loop: move */
    movel %d5,%sp@-
    jbsr trap_FracMul
    movel %a2@(0x0,%d4:w),%d0
    addl %d0,%sp@
    subqw #4,%d4
    jbpl FIXATAN2_5C
    movel %d3,%sp@-
    jsr %pc@(trap_FracMul)
    movel %sp@+,%d0
    moveq #14,%d2
    lsrl %d2,%d0
    jbcc FIXATAN2_7C
    addql #1,%d0
FIXATAN2_7C:            /* set %a2 */
    moveal %sp@+,%a2
    movel #102944,%d5
    btst #2,%d6
    jbeq FIXATAN2_8E
    subl %d5,%d0
    negl %d0
FIXATAN2_8E:            /* test bit 1 of %d6 */
    btst #1,%d6
    jbeq FIXATAN2_9A
    lsll #1,%d5
    subl %d5,%d0
    negl %d0
FIXATAN2_9A:            /* test bit 0 of %d6 */
    btst #0,%d6
    jbeq FIXATAN2_A2
    negl %d0
FIXATAN2_A2:            /* continue at FIXMUL_9C */
    jbra FIXMUL_9C
FIXATAN2_A6:            /* (data) */
    .short  0x3FFF, 0xA073, 0xEAB6, 0x4EBE, 0x0C62, 0xF72C, 0xF88C, 0x77F2	| 4081C662
    .short  0x035E, 0x92FE, 0xFF3F, 0xFE62	| 4081C672

/* FIX2X: _Fix2X. */
trap_Fix2X:
FIX2X:
    movew #16398,%d1
    jbra FRAC2X_4

/* FRAC2X: _Frac2X. */
trap_Frac2X:
FRAC2X:
    movew #16384,%d1
FRAC2X_4:               /* set %a0 */
    moveal %sp@+,%a0
    movel %sp@+,%d0
    jbne FRAC2X_E
    moveq #0,%d1
    jbra FRAC2X_1E
FRAC2X_E:               /* from here: jbpl FRAC2X_18 */
    jbpl FRAC2X_18
    addiw #-32768,%d1
    negl %d0
    jbmi FRAC2X_1E
FRAC2X_18:              /* loop: subq */
    subqw #1,%d1
    lsll #1,%d0
    jbpl FRAC2X_18
FRAC2X_1E:              /* set %a1 */
    moveal %sp@,%a1
    movew %d1,%a1@
    movel %d0,%a1@(2)
    clrl %a1@(6)
    jmp %a0@

/* X2FIX: _X2Fix. */
trap_X2Fix:
X2FIX:
    movew #16398,%d1
    jbra X2FRAC_4

/* X2FRAC: _X2Frac. */
trap_X2Frac:
X2FRAC:
    movew #16384,%d1
X2FRAC_4:               /* restore registers */
    moveml %sp@+,%a0-%a1
    movew %a1@,%d0
    bclr #15,%d0
    subw %d0,%d1
    jblt X2FRAC_4C
    movel %a1@(2),%d0
    tstw %d1
    jbne X2FRAC_20
    tstw %a1@(6)
    jbra X2FRAC_2E
X2FRAC_20:              /* test #32,%d1 */
    cmpiw #32,%d1
    jblt X2FRAC_32
    jbne X2FRAC_46
    moveq #0,%d0
    tstw %a1@(2)
X2FRAC_2E:              /* from here: jbmi X2FRAC_36 */
    jbmi X2FRAC_36
    jbra X2FRAC_3A
X2FRAC_32:              /* from here: lsrl %d1,%d0 */
    lsrl %d1,%d0
    jbcc X2FRAC_3A
X2FRAC_36:              /* add 1 to %d0 */
    addql #1,%d0
    jbcs X2FRAC_4C
X2FRAC_3A:              /* test %a1@ */
    tstw %a1@
    jbmi X2FRAC_48
    tstl %d0
    jbmi X2FRAC_4C
X2FRAC_42:              /* loop: move */
    movel %d0,%sp@
    jmp %a0@
X2FRAC_46:              /* clear %d0 */
    moveq #0,%d0
X2FRAC_48:              /* from here: negl %d0 */
    negl %d0
    jble X2FRAC_42
X2FRAC_4C:              /* test %a1@ */
    tstw %a1@
X2FRAC_4E:              /* loop: jbp */
    jbpl X2FRAC_54
    moveq #1,%d0
    jbra X2FRAC_58
X2FRAC_54:              /* clear %d0 */
    moveq #0,%d0
    subql #2,%d0
X2FRAC_58:              /* from here: rorl #1,%d0 */
    rorl #1,%d0
    jbra X2FRAC_42

/* FIX2LONG: _Fix2Long. */
trap_Fix2Long:
FIX2LONG:
    moveq #16,%d1
    jbra FRAC2FIX_2

/* FRAC2FIX: _Frac2Fix. */
trap_Frac2Fix:
FRAC2FIX:
    moveq #14,%d1
FRAC2FIX_2:             /* set %a0 */
    moveal %sp@+,%a0
    movel %sp@+,%d0
    jbpl FRAC2FIX_14
    negl %d0
    lsrl %d1,%d0
    jbcc FRAC2FIX_10
    addql #1,%d0
FRAC2FIX_10:            /* from here: negl %d0 */
    negl %d0
    jbra X2FRAC_42
FRAC2FIX_14:            /* from here: lsrl %d1,%d0 */
    lsrl %d1,%d0
    jbcc X2FRAC_42
    addql #1,%d0
    jbra X2FRAC_42

/* LONG2FIX: _Long2Fix. */
trap_Long2Fix:
LONG2FIX:
    moveq #16,%d1
    jbra FIX2FRAC_2

/* FIX2FRAC: _Fix2Frac. */
trap_Fix2Frac:
FIX2FRAC:
    moveq #14,%d1
FIX2FRAC_2:             /* set %a0 */
    moveal %sp@+,%a0
    movel %sp@+,%sp@
    movel %sp@,%d0
    asll %d1,%d0
    jbvc X2FRAC_42
    movel %sp@,%d1
    jbra X2FRAC_4E
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081C742
