/*
 diag/dtm.s - diagnostic test manager core
 From SetInterruptLevel (0x408CE250). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. These are the start-up and factory diagnostic tests (many run before RAM is usable, with return addresses in registers). Routine headers name the job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* SetInterruptLevel: set the interrupt level (diagnostic test environment). */
SetInterruptLevel:
    jsr %pc@(GetInterruptLevel)
    movel %sp@(4),%d1
    lslw #8,%d1
    movew %sr,%d2
    andiw #-1793,%d2
    orw %d1,%d2
    movew %d2,%sr
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408CE266

/* GetInterruptLevel: the interrupt level. */
GetInterruptLevel:
    movew %sr,%d0
    lsrw #8,%d0
    andiw #7,%d0
    rts
    .short  0x0000, 0x0000, 0x0000	| 408CE27A

/* InstallExceptionVector: install an exception vector for a test. */
InstallExceptionVector:
    movel %sp@(8),%d0
    jsr %pc@(FindVectorEntry)
    movel %a0@,%d0
    movel %sp@(4),%a0@
    rts

/* ExceptionHandlerStub: exception stub: pass the exception to the installed handler. */
ExceptionHandlerStub:
    moveml %d0-%d3/%a0-%a1,%sp@-
    moveal %sp@(24),%a1
    movew %sp@(34),%d3
    rolw #4,%d3
    andil #15,%d3
    movel %a1@(8),%sp@-
    pea %sp@(32)
    movel %d3,%sp@-
    movel %a1@,%sp@-
    moveal %a1@(4),%a0
    jsr %a0@
    lea %sp@(16),%sp
    moveml %sp@+,%d0-%d3/%a0-%a1
    addql #4,%sp
    rte
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408CE2C2

/* FakeExceptionCall: call a handler as if from an exception. */
FakeExceptionCall:
    movel %sp@(4),%d0
    jsr %pc@(FindVectorEntry)
    moveal %a0@,%a0
    movel %sp@(4),%d1
    aslw #2,%d1
    movew %d1,%sp@-
    pea %pc@(FakeExceptionCall_1A)
    movew %sr,%sp@-
    jmp %a0@
FakeExceptionCall_1A:   /* (data) */
    rts	| 408CE2EA
    .byte   0x00, 0x00, 0x00, 0x00	| 408CE2EC

/* FindVectorEntry: find a vector table entry. */
FindVectorEntry:
    movec %vbr,%a0

/* CalcVectorEntry: compute a vector address. */
CalcVectorEntry:
    lslw #2,%d0
    lea %a0@(0x0,%d0:w),%a0
    rts
    .long   0x00000000	| 408CE2FC

/* GetCTEGlobals: the CTE (diagnostic test engine) globals. */
GetCTEGlobals:
    movel %a5@(22),%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408CE306

/* BitWalk8: walking-bit test of a byte register. */
BitWalk8:
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(16),%a3
    clrb %a3@(5)
    jbra BitWalk8_D6
BitWalk8_18:            /* loop: tst */
    tstb %a3@(5)
    jbne BitWalk8_26
    moveq #0,%d0
    moveb %a4@(7),%d0
    jbra BitWalk8_32
BitWalk8_26:            /* set %d0 */
    moveb %a4@(7),%d0
    notb %d0
    moveq #0,%d1
    moveb %d0,%d1
    movel %d1,%d0
BitWalk8_32:            /* set %a3@ */
    moveb %d0,%a3@
    clrb %a3@(4)
    jbra BitWalk8_C8
BitWalk8_3C:            /* loop: move */
    moveb %a4@(4),%d0
    notb %d0
    moveb %a4@(5),%d1
    andb %d0,%d1
    moveb %a3@,%d0
    andb %a4@(4),%d0
    orb %d1,%d0
    moveb %d0,%a3@(1)
    tstl %a4@(12)
    jbeq BitWalk8_74
    moveq #0,%d0
    moveb %a3@(1),%d0
    movel %d0,%sp@-
    movel %a4@,%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(12),%a0
    jsr %a0@
    lea %sp@(12),%sp
    jbra BitWalk8_7A
BitWalk8_74:            /* set %a0 */
    moveal %a4@,%a0
    moveb %a3@(1),%a0@
BitWalk8_7A:            /* test %a4@(16) */
    tstl %a4@(16)
    jbeq BitWalk8_94
    movel %a4@,%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(16),%a0
    jsr %a0@
    moveb %d0,%a3@(2)
    addql #8,%sp
    jbra BitWalk8_9A
BitWalk8_94:            /* set %a0 */
    moveal %a4@,%a0
    moveb %a0@,%a3@(2)
BitWalk8_9A:            /* set %d0 */
    moveb %a3@(2),%d0
    moveb %a3@(1),%d1
    eorb %d0,%d1
    andb %a4@(6),%d1
    moveb %d1,%a3@(3)
    jbne BitWalk8_106
    moveq #1,%d0
    movel %d0,%sp@-
    moveq #0,%d1
    moveb %a3@,%d1
    movel %d1,%sp@-
    movel %sp@,%d0
    movel %sp@(4),%d1
    rolb %d1,%d0
    moveb %d0,%a3@
    addql #8,%sp
    addqb #1,%a3@(4)
BitWalk8_C8:            /* set %d0 */
    moveq #8,%d0
    cmpb %a3@(4),%d0
    jbhi BitWalk8_3C
    addqb #1,%a3@(5)
BitWalk8_D6:            /* set %d0 */
    moveq #1,%d0
    cmpb %a3@(5),%d0
    jbge BitWalk8_18
    tstl %a4@(12)
    jbeq BitWalk8_100
    moveq #0,%d0
    moveb %a4@(8),%d0
    movel %d0,%sp@-
    movel %a4@,%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(12),%a0
    jsr %a0@
    lea %sp@(12),%sp
    jbra BitWalk8_106
BitWalk8_100:           /* set %a0 */
    moveal %a4@,%a0
    moveb %a4@(8),%a0@
BitWalk8_106:           /* set %d0 */
    moveb %a3@(3),%d0
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408CE424

/* BitWalk16: walking-bit test of a word register. */
BitWalk16:
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(16),%a3
    clrb %a3@(8)
    jbra BitWalk16_D6
BitWalk16_18:           /* loop: tst */
    tstb %a3@(8)
    jbne BitWalk16_26
    moveq #0,%d0
    movew %a4@(10),%d0
    jbra BitWalk16_32
BitWalk16_26:           /* set %d0 */
    movew %a4@(10),%d0
    notw %d0
    moveq #0,%d1
    movew %d0,%d1
    movel %d1,%d0
BitWalk16_32:           /* set %a3@ */
    movew %d0,%a3@
    clrw %a3@(10)
    jbra BitWalk16_C8
BitWalk16_3C:           /* loop: move */
    movew %a4@(4),%d0
    notw %d0
    movew %a4@(6),%d1
    andw %d0,%d1
    movew %a3@,%d0
    andw %a4@(4),%d0
    orw %d1,%d0
    movew %d0,%a3@(2)
    tstl %a4@(16)
    jbeq BitWalk16_74
    moveq #0,%d0
    movew %a3@(2),%d0
    movel %d0,%sp@-
    movel %a4@,%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(16),%a0
    jsr %a0@
    lea %sp@(12),%sp
    jbra BitWalk16_7A
BitWalk16_74:           /* set %a0 */
    moveal %a4@,%a0
    movew %a3@(2),%a0@
BitWalk16_7A:           /* test %a4@(20) */
    tstl %a4@(20)
    jbeq BitWalk16_94
    movel %a4@,%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(20),%a0
    jsr %a0@
    movew %d0,%a3@(4)
    addql #8,%sp
    jbra BitWalk16_9A
BitWalk16_94:           /* set %a0 */
    moveal %a4@,%a0
    movew %a0@,%a3@(4)
BitWalk16_9A:           /* set %d0 */
    movew %a3@(4),%d0
    movew %a3@(2),%d1
    eorw %d0,%d1
    andw %a4@(8),%d1
    movew %d1,%a3@(6)
    jbne BitWalk16_106
    moveq #1,%d0
    movel %d0,%sp@-
    moveq #0,%d1
    movew %a3@,%d1
    movel %d1,%sp@-
    movel %sp@,%d0
    movel %sp@(4),%d1
    rolw %d1,%d0
    movew %d0,%a3@
    addql #8,%sp
    addqw #1,%a3@(10)
BitWalk16_C8:           /* set %d0 */
    moveq #16,%d0
    cmpw %a3@(10),%d0
    jbhi BitWalk16_3C
    addqb #1,%a3@(8)
BitWalk16_D6:           /* set %d0 */
    moveq #1,%d0
    cmpb %a3@(8),%d0
    jbge BitWalk16_18
    tstl %a4@(16)
    jbeq BitWalk16_100
    moveq #0,%d0
    movew %a4@(12),%d0
    movel %d0,%sp@-
    movel %a4@,%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(16),%a0
    jsr %a0@
    lea %sp@(12),%sp
    jbra BitWalk16_106
BitWalk16_100:          /* set %a0 */
    moveal %a4@,%a0
    movew %a4@(12),%a0@
BitWalk16_106:          /* set %d0 */
    movew %a3@(6),%d0
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408CE544

/* BitWalk32: walking-bit test of a long register. */
BitWalk32:
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(16),%a3
    clrb %a3@(16)
    jbra BitWalk32_C8
BitWalk32_18:           /* loop: tst */
    tstb %a3@(16)
    jbne BitWalk32_24
    movel %a4@(16),%d0
    jbra BitWalk32_2A
BitWalk32_24:           /* set %d0 */
    movel %a4@(16),%d0
    notl %d0
BitWalk32_2A:           /* set %a3@ */
    movel %d0,%a3@
    moveq #0,%d0
    movel %d0,%a3@(20)
    jbra BitWalk32_BA
BitWalk32_36:           /* loop: move */
    movel %a4@(4),%d0
    notl %d0
    movel %a4@(8),%d1
    andl %d0,%d1
    movel %a3@,%d0
    andl %a4@(4),%d0
    orl %d1,%d0
    movel %d0,%a3@(4)
    tstl %a4@(24)
    jbeq BitWalk32_6A
    movel %a3@(4),%sp@-
    movel %a4@,%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(24),%a0
    jsr %a0@
    lea %sp@(12),%sp
    jbra BitWalk32_70
BitWalk32_6A:           /* set %a0 */
    moveal %a4@,%a0
    movel %a3@(4),%a0@
BitWalk32_70:           /* test %a4@(28) */
    tstl %a4@(28)
    jbeq BitWalk32_8A
    movel %a4@,%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(28),%a0
    jsr %a0@
    movel %d0,%a3@(8)
    addql #8,%sp
    jbra BitWalk32_90
BitWalk32_8A:           /* set %a0 */
    moveal %a4@,%a0
    movel %a0@,%a3@(8)
BitWalk32_90:           /* set %d0 */
    movel %a3@(8),%d0
    movel %a3@(4),%d1
    eorl %d0,%d1
    andl %a4@(12),%d1
    movel %d1,%a3@(12)
    jbne BitWalk32_F4
    moveq #1,%d0
    movel %d0,%sp@-
    movel %a3@,%sp@-
    movel %sp@,%d0
    movel %sp@(4),%d1
    roll %d1,%d0
    movel %d0,%a3@
    addql #8,%sp
    addql #1,%a3@(20)
BitWalk32_BA:           /* set %d0 */
    moveq #32,%d0
    cmpl %a3@(20),%d0
    jbhi BitWalk32_36
    addqb #1,%a3@(16)
BitWalk32_C8:           /* set %d0 */
    moveq #1,%d0
    cmpb %a3@(16),%d0
    jbge BitWalk32_18
    tstl %a4@(24)
    jbeq BitWalk32_EE
    movel %a4@(20),%sp@-
    movel %a4@,%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(24),%a0
    jsr %a0@
    lea %sp@(12),%sp
    jbra BitWalk32_F4
BitWalk32_EE:           /* set %a0 */
    moveal %a4@,%a0
    movel %a4@(20),%a0@
BitWalk32_F4:           /* set %d0 */
    movel %a3@(12),%d0
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408CE652

/* InstallExceptionHandler: install a test's exception handler. */
InstallExceptionHandler:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    movel %fp@(24),%d7
    moveal %fp@(8),%a4
    moveal %fp@(12),%a3
    movew #20153,%a3@
    lea %pc@(ExceptionHandlerStub),%a0
    movel %a0,%a3@(2)
    movel %a4,%a3@(6)
    movel %fp@(16),%a3@(10)
    movel %fp@(20),%a3@(14)
    movew %d7,%a3@(26)
    moveq #5,%d0
    cmpl %a4@(4),%d0
    jbne InstallExceptionHandler_4A
    movel %a3,%sp@-
    cpushl %bc,%a0@
    addql #2,%a0
    cpushl %bc,%a0@
    addql #2,%a0
    cpushl %bc,%a0@
    addql #4,%sp
InstallExceptionHandler_4A:  /* set %d0 */
    movel %d7,%d0
    asll #2,%d0
    movel %a4@(0x68,%d0:l),%a3@(22)
    movel %d7,%d0
    asll #2,%d0
    movel %a3,%a4@(0x68,%d0:l)
    movel %d7,%sp@-
    movel %a3,%sp@-
    jsr %pc@(InstallExceptionVector)
    movel %d0,%a3@(18)
    addql #8,%sp
    moveml %fp@(-12),%d7/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408CE6D4

/* RemoveExceptionHandler: remove it. */
RemoveExceptionHandler:
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(16),%a4
    moveal %sp@(20),%a3
    movew %a3@(26),%d7
    moveq #0,%d0
    movew %d7,%d0
    movel %d0,%sp@-
    movel %a3@(18),%sp@-
    jsr %pc@(InstallExceptionVector)
    moveq #0,%d0
    movew %d7,%d0
    asll #2,%d0
    movel %a3@(22),%a4@(0x68,%d0:l)
    addql #8,%sp
    moveml %sp@+,%d7/%a3-%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408CE712

/* ExecuteDTM: run a diagnostic test module (DTM): its test and subtests. */
ExecuteDTM:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(24),%a4
    moveal %fp@(8),%a3
    movel %a3,%sp@-
    jsr %pc@(FreeTempMem)
    moveal %fp@(12),%a0
    movel %a0@(4),%a3@(4)
    movel %fp@(12),%a3@(8)
    movel %fp@(16),%a3@(12)
    movel %fp@(20),%a3@(16)
    movel %a4,%a3@(20)
    moveal %fp@(12),%a0
    movel %a0@(12),%a4@(4)
    moveal %fp@(16),%a0
    movel %a0@(16),%sp@-
    moveal %fp@(12),%a0
    movel %a0@(16),%sp@-
    movel %a3,%sp@-
    jsr %pc@(AllocateBlock)
    movel %d0,%a4@(8)
    lea %sp@(16),%sp
    jbne ExecuteDTM_66
    moveq #-9,%d7
    jbra ExecuteDTM_FE
ExecuteDTM_66:          /* set %a0 */
    moveal %fp@(20),%a0
    movel %a0@(12),%sp@-
    moveal %fp@(12),%a0
    movel %a0@(20),%sp@-
    movel %a3,%sp@-
    jsr %pc@(AllocateBlock)
    movel %d0,%a4@(12)
    lea %sp@(12),%sp
    jbne ExecuteDTM_8A
    moveq #-9,%d7
    jbra ExecuteDTM_FE
ExecuteDTM_8A:          /* set %a0 */
    moveal %fp@(20),%a0
    movel %a0@(16),%sp@-
    moveal %fp@(12),%a0
    movel %a0@(24),%sp@-
    movel %a3,%sp@-
    jsr %pc@(AllocateBlock)
    movel %d0,%a4@(16)
    lea %sp@(12),%sp
    jbne ExecuteDTM_AE
    moveq #-10,%d7
    jbra ExecuteDTM_FE
ExecuteDTM_AE:          /* set %a0 */
    moveal %fp@(12),%a0
    movel %a0@(8),%d0
    jbcs ExecuteDTM_FC
    cmpil #2,%d0
    jbhi ExecuteDTM_FC
    addl %d0,%d0
    movew %pc@(ExecuteDTM_CA,%d0:l),%d0
ExecuteDTM_C6:          /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
ExecuteDTM_CA:          /* (data) */
    .short  ExecuteDTM_D0-(ExecuteDTM_C6+2)	| 408CE7EA
    .short  ExecuteDTM_D0-(ExecuteDTM_C6+2)	| 408CE7EC
    .short  ExecuteDTM_F8-(ExecuteDTM_C6+2)	| 408CE7EE
ExecuteDTM_D0:          /* set %a0 */
    moveal %fp@(20),%a0
    movel %a0@(4),%sp@-
    movel %a4@(12),%sp@-
    movel %a4@(8),%sp@-
    movel %a4@(4),%sp@-
    movel %a3,%sp@-
    moveal %fp@(16),%a0
    moveal %a0@(8),%a0
    jsr %a0@
    movel %d0,%d7
    lea %sp@(20),%sp
    jbra ExecuteDTM_FE
ExecuteDTM_F8:          /* set %d7 */
    moveq #-3,%d7
    jbra ExecuteDTM_FE
ExecuteDTM_FC:          /* set %d7 */
    moveq #-1,%d7
ExecuteDTM_FE:          /* set %a4@ */
    movel %d7,%a4@
    movel %d7,%d0
    moveml %fp@(-12),%d7/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000	| 408CE82C

/* AllocateBlock: allocate memory for a test. */
AllocateBlock:
    linkw %fp,#0
    moveml %d6-%d7/%a3-%a4,%sp@-
    movel %fp@(16),%d6
    moveal %fp@(12),%a4
    movel %a4,%d0
    jbeq AllocateBlock_26
    moveal %a4,%a3
    movel %d6,%d7
    jbra AllocateBlock_1E
AllocateBlock_1A:       /* loop: clr */
    clrb %a3@+
    subql #1,%d7
AllocateBlock_1E:       /* test %d7 */
    tstl %d7
    jbhi AllocateBlock_1A
    moveal %a4,%a3
    jbra AllocateBlock_34
AllocateBlock_26:       /* set %sp@- */
    movel %d6,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(AllocTempMem)
    moveal %d0,%a3
    addql #8,%sp
AllocateBlock_34:       /* set %d0 */
    movel %a3,%d0
    moveml %fp@(-16),%d6-%d7/%a3-%a4
    unlk %fp
    rts

/* ExecuteSubtest: run one subtest. */
ExecuteSubtest:
    moveml %d7/%a3,%sp@-
    moveal %sp@(12),%a3
    moveal %a3@(8),%a0
    movel %a0@(8),%d0
    jbcs ExecuteSubtest_50
    cmpil #1,%d0
    jbhi ExecuteSubtest_50
    addl %d0,%d0
    movew %pc@(ExecuteSubtest_24,%d0:l),%d0
ExecuteSubtest_20:      /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
ExecuteSubtest_24:      /* (data) */
    .short  ExecuteSubtest_2C-(ExecuteSubtest_20+2)	| 408CE894
    .short  ExecuteSubtest_28-(ExecuteSubtest_20+2)	| 408CE896
ExecuteSubtest_28:      /* set %d7 */
    moveq #-2,%d7
    jbra ExecuteSubtest_52
ExecuteSubtest_2C:      /* set %a0 */
    moveal %a3@(20),%a0
    movel %a0@(16),%sp@-
    moveal %a3@(20),%a0
    movel %a0@(12),%sp@-
    movel %a3,%sp@-
    moveal %a3@(16),%a0
    moveal %a0@(8),%a0
    jsr %a0@
    movel %d0,%d7
    lea %sp@(12),%sp
    jbra ExecuteSubtest_52
ExecuteSubtest_50:      /* set %d7 */
    moveq #-1,%d7
ExecuteSubtest_52:      /* set %d0 */
    movel %d7,%d0
    moveml %sp@+,%d7/%a3
    rts
    .short  0x0000, 0x0000, 0x0000	| 408CE8CA

/* GI_InitInterface: CTE interface: initialise. */
GI_InitInterface:
    linkw %fp,#0
    moveml %d7/%a3,%sp@-
    moveal %fp@(8),%a3
    moveq #0,%d7
    movel %fp@(12),%sp@-
    movel %a3,%sp@-
    movel %a3,%sp@-
    jsr %pc@(InitHeap)
    pea 0x46c
    movel %a3,%sp@-
    jsr %pc@(AllocPermMem)
    tstl %d0
    lea %sp@(20),%sp
    jbne GI_InitInterface_30
    moveq #-6,%d7
    jbra GI_InitInterface_A6
GI_InitInterface_30:    /* set %a3@ */
    movel #34635776,%a3@
    lea %pc@(ExecuteSubtest),%a0
    movel %a0,%a3@(44)
    lea %pc@(CTEDoIdle),%a0
    movel %a0,%a3@(48)
    lea %pc@(BitWalk8),%a0
    movel %a0,%a3@(60)
    lea %pc@(BitWalk16),%a0
    movel %a0,%a3@(64)
    lea %pc@(BitWalk32),%a0
    movel %a0,%a3@(68)
    lea %pc@(InstallExceptionHandler),%a0
    movel %a0,%a3@(72)
    lea %pc@(RemoveExceptionHandler),%a0
    movel %a0,%a3@(76)
    lea %pc@(FakeExceptionCall),%a0
    movel %a0,%a3@(80)
    lea %pc@(SetInterruptLevel),%a0
    movel %a0,%a3@(84)
    lea %pc@(GetInterruptLevel),%a0
    movel %a0,%a3@(88)
    lea %pc@(InstallExceptionVector),%a0
    movel %a0,%a3@(92)
    lea %pc@(AllocPermMem),%a0
    movel %a0,%a3@(96)
    lea %pc@(AllocTempMem),%a0
    movel %a0,%a3@(100)
    lea %pc@(STR_v2_1_Rules_Long_Live_M_Appleman_S_Willia),%a0
    movel %a0,%a3@(1128)
GI_InitInterface_A6:    /* set %d0 */
    movel %d7,%d0
    moveml %fp@(-8),%d7/%a3
    unlk %fp
    rts
STR_v2_1_Rules_Long_Live_M_Appleman_S_Willia:  /* string "v2.1 Rules! Long Live M. Appleman, S. W */
    .ascii  "v2.1 Rules! Long Live M. Appleman, S. Williams, A. Ludtke\000"
    .long   0x00000000	| 408CE9BC

/* GI_ExecuteDTM: CTE interface: run a test module. */
GI_ExecuteDTM:
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(8),%a3
    movel %fp@(24),%sp@-
    movel %fp@(20),%sp@-
    movel %fp@(16),%sp@-
    movel %a4,%sp@-
    movel %a3,%sp@-
    jsr %pc@(ExecuteDTM)
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts
    .short  0x0000	| 408CE9EE

/* GI_GetVersion: CTE interface: version. */
GI_GetVersion:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    movel %a3,%d0
    moveal %sp@+,%a3
    rts
    .long   0x00000000	| 408CE9FC

/* GI_AllocPermMem: CTE interface: permanent memory. */
GI_AllocPermMem:
    linkw %fp,#0
    movel %a3,%sp@-
    moveal %fp@(8),%a3
    movel %fp@(12),%sp@-
    movel %a3,%sp@-
    jsr %pc@(AllocPermMem)
    moveal %fp@(-4),%a3
    unlk %fp
    rts
    .byte   0x00, 0x00	| 408CEA1C
GI_AllocPermMem_1E:     /* (padding, the routine starts 2 bytes on) */
    .byte   0x00, 0x00	| 408CEA1E
GI_AllocPermMem_20:     /* from here: linkw %fp,#0 */
    linkw %fp,#0	| 408CEA20
    movel %a3,%sp@-	| 408CEA24
    moveal %fp@(8),%a3
    movel %fp@(12),%sp@-
    movel %a3,%sp@-
    jsr %pc@(AllocTempMem)
    moveal %fp@(-4),%a3
    unlk %fp
    rts
    .byte   0x00, 0x00	| 408CEA3C
GI_AllocTempMem_1E:     /* (padding) */
    .byte   0x00, 0x00	| 408CEA3E
GI_AllocTempMem_1E_2:   /* set %sp@- */
    movel %a3,%sp@-	| 408CEA40
    moveal %sp@(8),%a3
    movel %a3,%sp@-
    jsr %pc@(FreeTempMem)
    addql #4,%sp
    moveal %sp@+,%a3
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408CEA52

/* GI_GetCommentary: CTE interface: a test's description. */
GI_GetCommentary:
    movel %a3,%sp@-	| 408CEA60
    moveal %sp@(8),%a3	| 408CEA62
    movel %a3@(1128),%d0	| 408CEA66
    moveal %sp@+,%a3	| 408CEA6A
    rts	| 408CEA6C
    .byte   0x00, 0x00	| 408CEA6E

/* GI_GetDefaultExecutionOptions: CTE interface: default options. */
GI_GetDefaultExecutionOptions:
    linkw %fp,#-36
    moveq #1,%d0
    movel %d0,%fp@(-32)
    moveq #0,%d1
    movel %d1,%fp@(-28)
    movel %d1,%fp@(-24)
    movel %d1,%fp@(-20)
    movel %d1,%fp@(-16)
    movel %d1,%fp@(-12)
    movel %d1,%fp@(-8)
    movel %d1,%fp@(-4)
    movel %d1,%fp@(-36)
    moveal %fp@(8),%a0
    lea %fp@(-36),%a1
    moveq #8,%d2
GI_GetDefaultExecutionOptions_36:  /* loop: move */
    movel %a1@+,%a0@+
    dbf %d2,GI_GetDefaultExecutionOptions_36
    unlk %fp
    rts

/* InitHeap: the test heap. */
InitHeap:
    moveml %a3-%a4,%sp@-
    moveal %sp@(16),%a4
    moveal %sp@(12),%a3
    movel %a4,%d0
    negl %d0
    moveq #-4,%d1
    andl %d0,%d1
    negl %d1
    movel %d1,%a3@(24)
    movel %d1,%a3@(36)
    movel %sp@(20),%d0
    addl %a4,%d0
    moveq #-4,%d1
    andl %d0,%d1
    movel %d1,%a3@(28)
    movel %d1,%a3@(40)
    movel %a3@(24),%d0
    moveml %sp@+,%a3-%a4
    rts
    .short  0x0000, 0x0000, 0x0000	| 408CEAEA

/* AllocPermMem: allocate permanent test memory. */
AllocPermMem:
    linkw %fp,#-4
    moveml %d7/%a3-%a4,%sp@-
    movel %fp@(12),%d7
    moveal %fp@(8),%a3
    movel %d7,%d0
    negl %d0
    moveq #-4,%d1
    andl %d0,%d1
    negl %d1
    movel %d1,%d7
    movel %d7,%d0
    addl %a3@(36),%d0
    movel %d0,%fp@(-4)
    cmpl %a3@(40),%d0
    jbls AllocPermMem_32
    moveq #0,%d0
    moveal %d0,%a4
    jbra AllocPermMem_3C
AllocPermMem_32:        /* set %a4 */
    moveal %a3@(36),%a4
    movel %fp@(-4),%a3@(36)
AllocPermMem_3C:        /* set %d0 */
    movel %a4,%d0
    moveml %fp@(-16),%d7/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000	| 408CEB38

/* AllocTempMem: allocate temporary test memory. */
AllocTempMem:
    linkw %fp,#-4
    moveml %d6-%d7/%a3-%a4,%sp@-
    movel %fp@(12),%d6
    moveal %fp@(8),%a4
    movel %d6,%d0
    negl %d0
    moveq #-4,%d1
    andl %d0,%d1
    negl %d1
    movel %d1,%d6
    moveal %a4@(40),%a3
    subal %d6,%a3
    cmpal %a4@(36),%a3
    jbcc AllocTempMem_30
    moveq #0,%d0
    movel %d0,%fp@(-4)
    jbra AllocTempMem_4E
AllocTempMem_30:        /* set %a4@(40) */
    movel %a3,%a4@(40)
    movel %a4@(40),%fp@(-4)
    moveal %fp@(-4),%a3
    movel %d6,%d7
    asrl #2,%d7
    jbra AllocTempMem_4A
AllocTempMem_44:        /* loop: moveq */
    moveq #0,%d0
    movel %d0,%a3@+
    subql #1,%d7
AllocTempMem_4A:        /* test %d7 */
    tstl %d7
    jbgt AllocTempMem_44
AllocTempMem_4E:        /* set %d0 */
    movel %fp@(-4),%d0
    moveml %fp@(-20),%d6-%d7/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000	| 408CEB9C

/* FreeTempMem: free it. */
FreeTempMem:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    movel %a3@(28),%a3@(40)
    moveal %sp@+,%a3
    rts

/* CTEDoIdle: idle routine of the test engine. */
CTEDoIdle:
    moveml %a3-%a4,%sp@-
    moveal %sp@(12),%a4
    moveal %a4@(8),%a0
    moveal %a0@(28),%a3
    movel %a3,%d0
    jbeq CTEDoIdle_20
    moveal %a4@(8),%a0
    movel %a0@(32),%sp@-
    jsr %a3@
    addql #4,%sp
CTEDoIdle_20:           /* restore registers, return */
    moveml %sp@+,%a3-%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408CEBD6

/* USTUTEPADDING: padding. */
USTUTEPADDING:
    .fill   0xB0, 1, 0x00

BitWalk_a_No_By_Law_register:  /* save registers */
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(16),%a4
    movel %sp@(28),%d7
    moveal %sp@(24),%a3
    movel %d7,%a3@(4)
    moveal %sp@(20),%a0
    moveal %a0@,%a0
    movel %d7,%d0
    asll #2,%d0
    movel %a0@(0x0,%d0:l),%a3@(8)
    movew #-1,%a3@(12)
    clrw %a3@(14)
    movew #-1,%a3@(16)
    movew #1,%a3@(18)
    moveal %sp@(20),%a0
    moveal %a0@,%a0
    movel %d7,%d0
    asll #2,%d0
    moveal %a0@(0x0,%d0:l),%a0
    movew %a0@,%a3@(20)
    moveq #0,%d0
    movel %d0,%a3@(24)
    movel %d0,%a3@(28)
    pea %a3@(32)
    pea %a3@(8)
    movel %a4,%sp@-
    moveal %a4@(64),%a0
    jsr %a0@
    lea %sp@(12),%sp
    moveml %sp@+,%d7/%a3-%a4
    rts

BitWalk_a_bit0_equals_0_register:  /* save registers */
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(16),%a4
    movel %sp@(28),%d7
    moveal %sp@(24),%a3
    movel %d7,%a3@(4)
    moveal %sp@(20),%a0
    moveal %a0@,%a0
    movel %d7,%d0
    asll #2,%d0
    movel %a0@(0x0,%d0:l),%a3@(8)
    movew #-2,%a3@(12)
    clrw %a3@(14)
    movew #-1,%a3@(16)
    movew #1,%a3@(18)
    moveal %sp@(20),%a0
    moveal %a0@,%a0
    movel %d7,%d0
    asll #2,%d0
    moveal %a0@(0x0,%d0:l),%a0
    movew %a0@,%a3@(20)
    moveq #0,%d0
    movel %d0,%a3@(24)
    movel %d0,%a3@(28)
    pea %a3@(32)
    pea %a3@(8)
    movel %a4,%sp@-
    moveal %a4@(64),%a0
    jsr %a0@
    lea %sp@(12),%sp
    moveml %sp@+,%d7/%a3-%a4
    rts

Read_and_Invert:        /* set %sp@- */
    movel %a3,%sp@-
    moveal %sp@(12),%a3
    movew %a3@,%d0
    notw %d0
    moveal %sp@+,%a3
    rts
    .short  0x0000	| 408CED7E

BitWalk_data_inverted_register:  /* entry: stack frame */
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    movel %fp@(20),%d7
    moveal %fp@(8),%a4
    moveal %fp@(16),%a3
    movel %d7,%a3@(4)
    moveal %fp@(12),%a0
    moveal %a0@,%a0
    movel %d7,%d0
    asll #2,%d0
    movel %a0@(0x0,%d0:l),%a3@(8)
    movew #-1,%a3@(12)
    clrw %a3@(14)
    movew #-1,%a3@(16)
    movew #1,%a3@(18)
    moveal %fp@(12),%a0
    moveal %a0@,%a0
    movel %d7,%d0
    asll #2,%d0
    movel %a0@(0x0,%d0:l),%sp@-
    movel %a4,%sp@-
    jsr %pc@(Read_and_Invert)
    movew %d0,%a3@(20)
    moveq #0,%d0
    movel %d0,%a3@(24)
    lea %pc@(Read_and_Invert),%a0
    movel %a0,%a3@(28)
    pea %a3@(32)
    pea %a3@(8)
    movel %a4,%sp@-
    moveal %a4@(64),%a0
    jsr %a0@
    moveml %fp@(-12),%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000	| 408CEDFE

Read_and_shift_left_once:  /* set %sp@- */
    movel %a3,%sp@-
    moveal %sp@(12),%a3
    movew %a3@,%d0
    lslw #1,%d0
    moveal %sp@+,%a3
    rts
    .short  0x0000	| 408CEE0E

Read_and_shift_left_twice:  /* set %sp@- */
    movel %a3,%sp@-
    moveal %sp@(12),%a3
    movew %a3@,%d0
    lslw #2,%d0
    moveal %sp@+,%a3
    rts
    .short  0x0000	| 408CEE1E

BitWalk_data_shifted_register:  /* save registers */
    moveml %d7/%a3-%a4,%sp@-
    movel %sp@(28),%d7
    moveal %sp@(20),%a4
    moveal %sp@(24),%a3
    movel %d7,%a3@(4)
    moveal %a4@,%a0
    movel %d7,%d0
    asll #2,%d0
    movel %a0@(0x0,%d0:l),%a3@(8)
    movew #-1,%a3@(12)
    clrw %a3@(14)
    tstl %a4@(4)
    jbeq BitWalk_data_shifted_register_38
    movel #65532,%d0
    jbra BitWalk_data_shifted_register_3E
BitWalk_data_shifted_register_38:  /* set %d0 */
    movel #65534,%d0
BitWalk_data_shifted_register_3E:  /* set %a3@(16) */
    movew %d0,%a3@(16)
    movew #1,%a3@(18)
    moveal %a4@,%a0
    movel %d7,%d0
    asll #2,%d0
    moveal %a0@(0x0,%d0:l),%a0
    movel %a4@(4),%d0
    addql #1,%d0
    movew %a0@,%d1
    lslw %d0,%d1
    movew %d1,%a3@(20)
    moveq #0,%d0
    movel %d0,%a3@(24)
    tstl %a4@(4)
    jbeq BitWalk_data_shifted_register_74
    lea %pc@(Read_and_shift_left_twice),%a0
    movel %a0,%d1
    jbra BitWalk_data_shifted_register_7A
BitWalk_data_shifted_register_74:  /* address %pc@(Read_and_shift_left_once) */
    lea %pc@(Read_and_shift_left_once),%a0
    movel %a0,%d1
BitWalk_data_shifted_register_7A:  /* set %a3@(28) */
    movel %d1,%a3@(28)
    pea %a3@(32)
    pea %a3@(8)
    movel %sp@(16),%sp@-
    moveal %sp@(16),%a0
    moveal %a0@(64),%a0
    jsr %a0@
    lea %sp@(12),%sp
    moveml %sp@+,%d7/%a3-%a4
    rts
    .short  0x0000	| 408CEEBE

/* SONIC_BitMarch: SONIC register bit march test. */
SONIC_BitMarch:
    linkw %fp,#0
    moveml %d5-%d7/%a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(16),%a3
    moveq #1,%d6
    moveal %a4@,%a0
    moveal %a0@(160),%a0
    moveq #0,%d0
    movew %a0@,%d0
    movel %d0,%a3@
    moveq #0,%d0
    movel %d0,%a3@(4)
    moveal %a4@,%a0
    moveal %a0@,%a0
    movew #148,%a0@
    moveal %a4@,%a0
    moveal %a0@,%a0
    cmpiw #148,%a0@
    jbeq SONIC_BitMarch_3C
    moveq #3,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_3C:      /* set %d0 */
    moveq #3,%d0
    cmpl %a3@,%d0
    jbge SONIC_BitMarch_68
    moveal %a4@,%a0
    moveal %a0@(252),%a0
    clrw %a0@
    tstl %a4@(4)
    jbeq SONIC_BitMarch_5C
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew #-31956,%a0@
    jbra SONIC_BitMarch_84
SONIC_BitMarch_5C:      /* set %a0 */
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew #-31988,%a0@
    jbra SONIC_BitMarch_84
SONIC_BitMarch_68:      /* test %a4@(4) */
    tstl %a4@(4)
    jbeq SONIC_BitMarch_7A
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew #812,%a0@
    jbra SONIC_BitMarch_84
SONIC_BitMarch_7A:      /* set %a0 */
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew #780,%a0@
SONIC_BitMarch_84:      /* set %a0 */
    moveal %a4@,%a0
    moveal %a0@(16),%a0
    clrw %a0@
    moveal %a4@,%a0
    moveal %a0@(16),%a0
    movew %a0@,%a3@(38)
    jbeq SONIC_BitMarch_A4
    moveq #4,%d0
    movel %d0,%a3@(4)
    moveq #2,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_A4:      /* set %d0 */
    moveq #2,%d0
    movel %d0,%a3@(4)
    moveal %a4@,%a0
    movel %a0@(8),%a3@(8)
    movew #-512,%a3@(12)
    clrw %a3@(14)
    movew #-512,%a3@(16)
    movew #1,%a3@(18)
    moveal %a4@,%a0
    moveal %a0@(8),%a0
    movew %a0@,%a3@(20)
    moveq #0,%d1
    movel %d1,%a3@(24)
    movel %d1,%a3@(28)
    pea %a3@(32)
    pea %a3@(8)
    movel %fp@(8),%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(64),%a0
    jsr %a0@
    tstw %d0
    lea %sp@(12),%sp
    jbeq SONIC_BitMarch_100
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_100:     /* set %d0 */
    moveq #3,%d0
    movel %d0,%a3@(4)
    moveal %a4@,%a0
    movel %a0@(12),%a3@(8)
    movew #-4096,%a3@(12)
    clrw %a3@(14)
    movew #-4096,%a3@(16)
    movew #1,%a3@(18)
    moveal %a4@,%a0
    moveal %a0@(12),%a0
    movew %a0@,%a3@(20)
    moveq #0,%d1
    movel %d1,%a3@(24)
    movel %d1,%a3@(28)
    pea %a3@(32)
    pea %a3@(8)
    movel %fp@(8),%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(64),%a0
    jsr %a0@
    tstw %d0
    lea %sp@(12),%sp
    jbeq SONIC_BitMarch_15C
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_15C:     /* set %d0 */
    moveq #5,%d0
    movel %d0,%a3@(4)
    moveal %a4@,%a0
    movel %a0@(20),%a3@(8)
    clrw %a3@(12)
    movew #32767,%a3@(14)
    movew #32767,%a3@(16)
    movew #1,%a3@(18)
    clrw %a3@(20)
    moveq #0,%d1
    movel %d1,%a3@(24)
    movel %d1,%a3@(28)
    moveal %a4@,%a0
    moveal %a0@(20),%a0
    movew #32767,%a0@
    moveal %a4@,%a0
    moveal %a0@(20),%a0
    tstw %a0@
    jbeq SONIC_BitMarch_1A8
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_1A8:     /* set %d7 */
    moveq #6,%d7
SONIC_BitMarch_1AA:     /* loop: move */
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_No_By_Law_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_1C6
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_1C6:     /* add 1 to %d7 */
    addql #1,%d7
    moveq #8,%d0
    cmpl %d7,%d0
    jbgt SONIC_BitMarch_1AA
    moveq #8,%d0
    movel %d0,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_data_inverted_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_1EC
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_1EC:     /* set %d7 */
    moveq #9,%d7
SONIC_BitMarch_1EE:     /* loop: move */
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_No_By_Law_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_20A
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_20A:     /* add 1 to %d7 */
    addql #1,%d7
    moveq #12,%d0
    cmpl %d7,%d0
    jbgt SONIC_BitMarch_1EE
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew %a0@,%d5
    tstl %a4@(4)
    jbeq SONIC_BitMarch_22A
    moveq #32,%d0
    orw %d5,%d0
    moveq #0,%d1
    movew %d0,%d1
    jbra SONIC_BitMarch_236
SONIC_BitMarch_22A:     /* clear %d0 */
    moveq #0,%d0
    movew %d5,%d0
    movel #65503,%d1
    andl %d0,%d1
SONIC_BitMarch_236:     /* set %d5 */
    movew %d1,%d5
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew %d5,%a0@
    moveq #12,%d0
    movel %d0,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_data_shifted_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_25E
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_25E:     /* set %d7 */
    moveq #13,%d7
SONIC_BitMarch_260:     /* loop: move */
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_No_By_Law_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_27C
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_27C:     /* add 1 to %d7 */
    addql #1,%d7
    moveq #19,%d0
    cmpl %d7,%d0
    jbgt SONIC_BitMarch_260
    moveq #19,%d7
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_bit0_equals_0_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_2A2
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_2A2:     /* set %d7 */
    moveq #20,%d7
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_No_By_Law_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_2C0
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_2C0:     /* set %d7 */
    moveq #21,%d7
SONIC_BitMarch_2C2:     /* loop: move */
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_bit0_equals_0_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_2DE
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_2DE:     /* add 1 to %d7 */
    addql #1,%d7
    moveq #25,%d0
    cmpl %d7,%d0
    jbgt SONIC_BitMarch_2C2
    moveq #25,%d7
SONIC_BitMarch_2E8:     /* loop: moveq */
    moveq #27,%d0
    cmpl %d7,%d0
    seq %d0
    negb %d0
    extbl %d0
    jbeq SONIC_BitMarch_30C
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_bit0_equals_0_register)
    moveq #0,%d1
    movew %d0,%d1
    lea %sp@(16),%sp
    jbra SONIC_BitMarch_322
SONIC_BitMarch_30C:     /* set %sp@- */
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_No_By_Law_register)
    moveq #0,%d1
    movew %d0,%d1
    lea %sp@(16),%sp
SONIC_BitMarch_322:     /* from here: jbeq SONIC_BitMarch_32A */
    jbeq SONIC_BitMarch_32A
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_32A:     /* add 1 to %d7 */
    addql #1,%d7
    moveq #29,%d0
    cmpl %d7,%d0
    jbgt SONIC_BitMarch_2E8
    moveq #29,%d7
    jbra SONIC_BitMarch_354
SONIC_BitMarch_336:     /* loop: move */
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_bit0_equals_0_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_352
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_352:     /* add 1 to %d7 */
    addql #1,%d7
SONIC_BitMarch_354:     /* set %d0 */
    moveq #21,%d0
    cmpl %d7,%d0
    jbgt SONIC_BitMarch_336
    moveq #31,%d7
SONIC_BitMarch_35C:     /* loop: move */
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_No_By_Law_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_378
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_378:     /* add 1 to %d7 */
    addql #1,%d7
    moveq #33,%d0
    cmpl %d7,%d0
    jbgt SONIC_BitMarch_35C
    moveq #33,%d0
    movel %d0,%a3@(4)
    moveal %a4@,%a0
    movel %a0@(132),%a3@(8)
    movew #15,%a3@(12)
    clrw %a3@(14)
    movew #15,%a3@(16)
    movew #1,%a3@(18)
    moveal %a4@,%a0
    moveal %a0@(132),%a0
    movew %a0@,%a3@(20)
    moveq #0,%d1
    movel %d1,%a3@(24)
    movel %d1,%a3@(28)
    pea %a3@(32)
    pea %a3@(8)
    movel %fp@(8),%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(64),%a0
    jsr %a0@
    tstw %d0
    lea %sp@(12),%sp
    jbeq SONIC_BitMarch_3DC
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_3DC:     /* set %d7 */
    moveq #37,%d7
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_No_By_Law_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_3FA
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_3FA:     /* set %d7 */
    moveq #38,%d7
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_bit0_equals_0_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_418
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_418:     /* set %d0 */
    moveq #39,%d0
    movel %d0,%a3@(4)
    moveal %a4@,%a0
    movel %a0@(152),%a3@(8)
    movew #31,%a3@(12)
    clrw %a3@(14)
    movew #31,%a3@(16)
    movew #1,%a3@(18)
    moveal %a4@,%a0
    moveal %a0@(156),%a0
    movew %a0@,%a3@(20)
    moveq #0,%d1
    movel %d1,%a3@(24)
    movel %d1,%a3@(28)
    pea %a3@(32)
    pea %a3@(8)
    movel %fp@(8),%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(64),%a0
    jsr %a0@
    tstw %d0
    lea %sp@(12),%sp
    jbeq SONIC_BitMarch_472
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_472:     /* set %d7 */
    moveq #41,%d7
SONIC_BitMarch_474:     /* loop: move */
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_a_No_By_Law_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_48E
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_48E:     /* add 1 to %d7 */
    addql #1,%d7
    moveq #44,%d0
    cmpl %d7,%d0
    jbgt SONIC_BitMarch_474
    moveq #44,%d7
SONIC_BitMarch_498:     /* loop: move */
    movel %d7,%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(BitWalk_data_inverted_register)
    tstw %d0
    lea %sp@(16),%sp
    jbeq SONIC_BitMarch_4B2
    moveq #4,%d6
    jbra SONIC_BitMarch_4BC
SONIC_BitMarch_4B2:     /* add 1 to %d7 */
    addql #1,%d7
    moveq #47,%d0
    cmpl %d7,%d0
    jbgt SONIC_BitMarch_498
    clrb %d6
SONIC_BitMarch_4BC:     /* clear %d0 */
    moveq #0,%d0
    moveb %d6,%d0
    moveml %fp@(-20),%d5-%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000	| 408CF38A
