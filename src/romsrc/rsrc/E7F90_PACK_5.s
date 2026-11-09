/* ROM resource 'PACK' 5: map entry at 0x408E7F90, data at 0x408E7FC0, 6704 bytes

 The software SANE elementary functions (PACK 5, Elems68K): logarithms, exponentials,
 powers, trigonometric functions, compound interest and annuity, random numbers, on
 extended values through PACK 4; for machines without an FPU (machine mask). The
 Quadra 800 uses the FPU version (rsrc/EDC70_PACK_5.s). Comments inferred; routines
 summarised mechanically.
*/

rsrc_PACK_5_entry:      /* map entry */
    .long   0x08000000, 0x00000000	| 408E7F90
    .long   rsrc_DRVR_51__EDisk_entry-rom_start	| 408E7F98
    .long   rsrc_PACK_5-rom_start	| 408E7F9C
    .ascii  "PACK"	| 408E7FA0
    .byte   0x00, 0x05, 0x58, 0x00	| 408E7FA4
    FILL_408E7FA8
    .byte   0xC0, 0xA0, 0x00, 0x00	| 408E7FB4
    .short  0x0000, 0x1A3C	| orib #60,%d0
    .short  0x0000, 0x0284	| orib #0x84,%d0

/* subroutine (85 instructions): calls rsrc_PACK_5_10C, rsrc_PACK_5_102; low memory FPState (mechanical summary) */
rsrc_PACK_5:
    linkw %fp,#-68
    moveml %d0-%a4,%sp@-
    moveq #0,%d3
    moveal 0x15ac,%a3
    lea %fp@(4),%a2
    lea %fp@(8),%a0
    movew %a0@+,%d3
    jbpl rsrc_PACK_5_86
    moveal %a0@+,%a4
    movel %a0@,%d4
    btst #14,%d3
    jbne rsrc_PACK_5_62
    tstb %d3
    jbpl rsrc_PACK_5_2E
    movew %a4@,%a4@(2)
    addql #2,%a4
rsrc_PACK_5_2E:         /* set %a0@ */
    movel %a2@,%a0@
    movew #10,%a2@
    movel %a4,%d5
    moveq #15,%d2
    moveq #62,%d0
    andw %d3,%d0
    cmpib #16,%d0
    jbeq rsrc_PACK_5_9C
    tstb %d3
    jbpl rsrc_PACK_5_58
rsrc_PACK_5_46:         /* loop: movea */
    moveal %d4,%a0
    lea %fp@(-56),%a1
    movel %a1,%d4
    movew %a0@,%a1@+
    movel %a0@(4),%a1@+
    movel %a0@(8),%a1@
rsrc_PACK_5_58:         /* loop: movea */
    moveal %d4,%a0
    jbsr rsrc_PACK_5_10C
    movew %d0,%d2
    jbra rsrc_PACK_5_9C
rsrc_PACK_5_62:         /* add 4 to %a0 */
    addql #4,%a0
    movel %a0@,%d5
    movel %a2@,%a0@
    movew #14,%a2@
    tstb %d3
    jbpl rsrc_PACK_5_58
    addqw #2,%a4
    moveal %d5,%a0
    lea %fp@(-66),%a1
    movel %a1,%d5
    movew %a0@,%a1@+
    movel %a0@(4),%a1@+
    movel %a0@(8),%a1@
    jbra rsrc_PACK_5_46
rsrc_PACK_5_86:         /* set %d2 */
    moveq #15,%d2
    moveal %a0@,%a4
    tstb %d3
    jbpl rsrc_PACK_5_94
    movew %a4@,%a4@(2)
    addql #2,%a4
rsrc_PACK_5_94:         /* set %a0@ */
    movel %a2@,%a0@
    movew #6,%a2@
    movel %a4,%d5
rsrc_PACK_5_9C:         /* set %a0 */
    moveal %d5,%a0
    jbsr rsrc_PACK_5_10C
    movew %d0,%d1
    movew FPState,%fp@(-2)
    clrw FPState
    subqb #3,%d2
    jbge rsrc_PACK_5_C0
    moveal %d5,%a0
    moveal %a4,%a1
    jbsr rsrc_PACK_5_102
    movel %d4,%sp@-
    pea %a4@
    clrw %sp@-
    jsr %a3@
    jbra rsrc_PACK_5_CE
rsrc_PACK_5_C0:         /* subtract 3 to %d1 */
    subqb #3,%d1
    jbge rsrc_PACK_5_D2
    movel %d5,%sp@-
    pea %a4@
    movew #14,%sp@-
    jsr %a3@
rsrc_PACK_5_CE:         /* continue at rsrc_PACK_5_4FE */
    jbra rsrc_PACK_5_4FE
rsrc_PACK_5_D2:         /* set %d0 */
    movew %d3,%d0
    andiw #62,%d0
    movew %pc@(rsrc_PACK_5_E0,%d0:w),%d0
    jmp %pc@(rsrc_PACK_5_D2,%d0:w)
rsrc_PACK_5_E0:         /* (data) */
    .short  rsrc_PACK_5_2BE-rsrc_PACK_5_D2	| 408E80A0
    .short  rsrc_PACK_5_2BE-rsrc_PACK_5_D2	| 408E80A2
    .short  rsrc_PACK_5_2BE-rsrc_PACK_5_D2	| 408E80A4
    .short  rsrc_PACK_5_2BE-rsrc_PACK_5_D2	| 408E80A6
    .short  rsrc_PACK_5_518-rsrc_PACK_5_D2	| 408E80A8
    .short  rsrc_PACK_5_518-rsrc_PACK_5_D2	| 408E80AA
    .short  rsrc_PACK_5_5D2-rsrc_PACK_5_D2	| 408E80AC
    .short  rsrc_PACK_5_5D2-rsrc_PACK_5_D2	| 408E80AE
    .short  rsrc_PACK_5_6D6-rsrc_PACK_5_D2	| 408E80B0
    .short  rsrc_PACK_5_7F6-rsrc_PACK_5_D2	| 408E80B2
    .short  rsrc_PACK_5_8DE-rsrc_PACK_5_D2	| 408E80B4
    .short  rsrc_PACK_5_972-rsrc_PACK_5_D2	| 408E80B6
    .short  rsrc_PACK_5_ACC-rsrc_PACK_5_D2	| 408E80B8
    .short  rsrc_PACK_5_B0C-rsrc_PACK_5_D2	| 408E80BA
    .short  rsrc_PACK_5_C36-rsrc_PACK_5_D2	| 408E80BC
    .short  rsrc_PACK_5_D2C-rsrc_PACK_5_D2	| 408E80BE
    .short  rsrc_PACK_5_E86-rsrc_PACK_5_D2	| 408E80C0

/* subroutine (5 instructions) (mechanical summary) */
rsrc_PACK_5_102:
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movew %a0@,%a1@
    subql #8,%a1
    rts

/* subroutine (48 instructions) (mechanical summary) */
rsrc_PACK_5_10C:
    movel %d1,%sp@-
    movew %a0@,%d0
    andiw #32767,%d0
    cmpiw #32767,%d0
    jbne rsrc_PACK_5_10C_2A
    moveq #3,%d0
    bfextu %a0@(2),1,31,%d1
    orl %a0@(6),%d1
    jbeq rsrc_PACK_5_10C_32
    subqw #1,%d0
    btst #6,%a0@(2)
    jbne rsrc_PACK_5_10C_32
    subqw #1,%d0
    jbra rsrc_PACK_5_10C_32
rsrc_PACK_5_10C_2A:     /* test %a0@(2) */
    tstw %a0@(2)
    jbpl rsrc_PACK_5_10C_3E
rsrc_PACK_5_10C_30:     /* loop: moveq */
    moveq #5,%d0
rsrc_PACK_5_10C_32:     /* loop: tst */
    tstw %a0@
    jbpl rsrc_PACK_5_10C_3A
    oriw #-32768,%d0
rsrc_PACK_5_10C_3A:     /* set %d1 */
    movel %sp@+,%d1
    rts
rsrc_PACK_5_10C_3E:     /* set %d1 */
    movel %a0@(2),%d1
    orl %a0@(6),%d1
    jbeq rsrc_PACK_5_10C_7A
    tstw %d0
    jbne rsrc_PACK_5_10C_50
rsrc_PACK_5_10C_4C:     /* result 6 */
    moveq #6,%d0
    jbra rsrc_PACK_5_10C_32
rsrc_PACK_5_10C_50:     /* set %sp@- */
    movel %d2,%sp@-
    movel %a0@(2),%d1
    movel %a0@(6),%d2
rsrc_PACK_5_10C_5A:     /* loop: subq */
    subqw #1,%d0
    addl %d2,%d2
    addxl %d1,%d1
    jbmi rsrc_PACK_5_10C_66
    tstw %d0
    jbne rsrc_PACK_5_10C_5A
rsrc_PACK_5_10C_66:     /* from here: bfins %d0,%a0@,1,15 */
    bfins %d0,%a0@,1,15
    movel %d1,%a0@(2)
    movel %d2,%a0@(6)
    movel %sp@+,%d2
    tstl %d1
    jbmi rsrc_PACK_5_10C_30
    jbra rsrc_PACK_5_10C_4C
rsrc_PACK_5_10C_7A:     /* from here: andiw #-32768,%a0@ */
    andiw #-32768,%a0@
    moveq #4,%d0
    jbra rsrc_PACK_5_10C_32

/* subroutine (19 instructions) (mechanical summary) */
rsrc_PACK_5_18E:
    movew %a1@+,%d0
    movel %a1@,%a0@
    movel %a1@(4),%a0@(4)
    movew %a1@(8),%a0@(8)
rsrc_PACK_5_18E_10:     /* loop: pea */
    pea %a2@
    pea %a0@
    movew #4,%sp@-
    jsr %a3@
    addql #8,%a1
    addql #2,%a1
    pea %a1@
    pea %a0@
    clrw %sp@-
    jsr %a3@
    subqw #1,%d0
    jbgt rsrc_PACK_5_18E_10
    addql #8,%a1
    addql #2,%a1
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1BE:
    moveq #1,%d0
    jbra rsrc_PACK_5_1CC

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1C2:
    moveq #2,%d0
    jbra rsrc_PACK_5_1CC

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1C6:
    moveq #0,%d0
    jbra rsrc_PACK_5_1CC

/* subroutine (3 instructions): low memory FPState (mechanical summary) */
rsrc_PACK_5_1CA:
    moveq #4,%d0

rsrc_PACK_5_1CC:        /* from here: bclr %d0,FPState */
    bclr %d0,FPState
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1D2:
    moveq #2,%d0
    jbra rsrc_PACK_5_1E2_2

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1D6:
    moveq #1,%d0
    jbra rsrc_PACK_5_1E2_2

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1DA:
    moveq #3,%d0
    jbra rsrc_PACK_5_1E2_2

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1DE:
    moveq #0,%d0
    jbra rsrc_PACK_5_1E2_2

/* subroutine (3 instructions): low memory FPState (mechanical summary) */
rsrc_PACK_5_1E2:
    moveq #4,%d0
rsrc_PACK_5_1E2_2:      /* from here: bset %d0,FPState */
    bset %d0,FPState
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1EA:
    moveq #3,%d0
    jbra rsrc_PACK_5_1FA_2

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1EE:
    moveq #1,%d0
    jbra rsrc_PACK_5_1FA_2

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1F2:
    moveq #2,%d0
    jbra rsrc_PACK_5_1FA_2

/* subroutine (2 instructions) (mechanical summary) */
rsrc_PACK_5_1F6:
    moveq #0,%d0
    jbra rsrc_PACK_5_1FA_2

/* subroutine (3 instructions): low memory FPState (mechanical summary) */
rsrc_PACK_5_1FA:
    moveq #4,%d0
rsrc_PACK_5_1FA_2:      /* from here: btst %d0,FPState */
    btst %d0,FPState
    rts

/* subroutine (17 instructions) (mechanical summary) */
rsrc_PACK_5_202:
    movel %d1,%sp@-
    bfextu %a1@,1,15,%d0
    movew #16398,%d1
    subw %d0,%d1
    movew %a1@(2),%d0
    jbeq rsrc_PACK_5_202_2A
    lsrw %d1,%d0
    tstw %a1@
    jbpl rsrc_PACK_5_202_1A
    negw %d0
rsrc_PACK_5_202_1A:     /* set %fp@(-6) */
    movew %d0,%fp@(-6)
    pea %fp@(-6)
    pea %a0@
    movew #24,%sp@-
    jsr %a3@
rsrc_PACK_5_202_2A:     /* set %d1 */
    movel %sp@+,%d1
    rts

/* subroutine (23 instructions) (mechanical summary) */
rsrc_PACK_5_230:
    moveml %d0-%d1/%a0,%sp@-
    moveal %sp@(20),%a0
    movew #16398,%d0
    swap %d0
    movew %a0@,%d0
    jbeq rsrc_PACK_5_230_3A
    jbpl rsrc_PACK_5_230_1C
    bset #31,%d0
    negw %d0
    jbmi rsrc_PACK_5_230_28
rsrc_PACK_5_230_1C:     /* from here: swap %d0 */
    swap %d0
    bfffo %d0,0,16,%d1
    subw %d1,%d0
    swap %d0
    lslw %d1,%d0
rsrc_PACK_5_230_28:     /* loop: movea */
    moveal %sp@(16),%a0
    movel %d0,%a0@+
    clrl %a0@+
    clrw %a0@
    moveml %sp@+,%d0-%d1/%a0
    rtd #8
rsrc_PACK_5_230_3A:     /* result 0 */
    moveq #0,%d0
    jbra rsrc_PACK_5_230_28

/* subroutine (28 instructions): low memory FPState, FPHaltVector (mechanical summary) */
rsrc_PACK_5_26E:
    moveml %d0/%d6/%a0,%sp@-
    moveal %sp@(16),%a0
    movew #25,%d6
    swap %d6
    movew #7936,%d6
    andw FPState,%d6
    movew %a0@,%d0
    orw %d6,%d0
    movew %d0,FPState
    lsrw #8,%d6
    andw %d6,%d0
    jbne rsrc_PACK_5_26E_2E
rsrc_PACK_5_26E_24:     /* loop: move */
    movew %d0,%ccr
    moveml %sp@+,%d0/%d6/%a0
    rtd #4
rsrc_PACK_5_26E_2E:     /* address %sp@(16) */
    lea %sp@(16),%a0
    clrw %sp@-
    movew %d0,%sp@-
    pea %sp@
    movel %a0@(8),%sp@-
    movel %a0@(4),%sp@-
    movel %a0@,%sp@-
    swap %d6
    movew %d6,%sp@-
    moveal FPHaltVector,%a0
    jsr %a0@
    movel %sp@+,%d0
    jbra rsrc_PACK_5_26E_24

/* subroutine (119 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5_416, rsrc_PACK_5_1E2 (mechanical summary) */
rsrc_PACK_5_2BE:
    subqb #1,%d1	| 408E827E
    jbpl rsrc_PACK_5_2CE	| 408E8280
    tstw %d1	| 408E8282
    jbpl rsrc_PACK_5_4FE	| 408E8284
rsrc_PACK_5_26E_5A:     /* result 36 */
    moveq #36,%d0
    jbra rsrc_PACK_5_4EC
rsrc_PACK_5_2CE:        /* test bit 2 of %d3 */
    btst #2,%d3	| 408E828E
    jbne rsrc_PACK_5_2DE	| 408E8292
    tstb %d1
    jbeq rsrc_PACK_5_26E_A6
    tstw %d1
    jbmi rsrc_PACK_5_26E_5A
    jbra rsrc_PACK_5_26E_EA
rsrc_PACK_5_2DE:        /* test %d1 */
    tstb %d1	| 408E829E
    jbeq rsrc_PACK_5_4FE	| 408E82A0
    bfextu %a4@,1,15,%d0	| 408E82A4
    cmpiw #16319,%d0	| 408E82A8
    jbge rsrc_PACK_5_304	| 408E82AC
    btst #1,%d3
    jbeq rsrc_PACK_5_26E_92
    pea %pc@(rsrc_PACK_5_1078)
    pea %a4@
    movew #6,%sp@-
    jsr %a3@
rsrc_PACK_5_26E_92:     /* continue at rsrc_PACK_5_416_7A */
    jbra rsrc_PACK_5_416_7A
rsrc_PACK_5_304:        /* from here: pea %a4@ */
    pea %a4@	| 408E82C4
    pea %pc@(rsrc_PACK_5_FC4)	| 408E82C6
    movew #8,%sp@-	| 408E82CA
    jsr %a3@	| 408E82CE
    jbcs rsrc_PACK_5_318	| 408E82D0
    jbhi rsrc_PACK_5_26E_5A	| 408E82D2
rsrc_PACK_5_26E_A6:     /* continue at rsrc_PACK_5_4DC */
    jbra rsrc_PACK_5_4DC
rsrc_PACK_5_318:        /* set %a0 */
    moveal %a4,%a0	| 408E82D8
    lea %fp@(-16),%a1	| 408E82DA
    jbsr rsrc_PACK_5_102	| 408E82DE
    pea %pc@(rsrc_PACK_5_FBA)	| 408E82E2
    pea %a4@	| 408E82E6
    clrw %sp@-	| 408E82E8
    jsr %a3@	| 408E82EA
    pea %pc@(rsrc_PACK_5_1064)	| 408E82EC
    pea %a4@	| 408E82F0
    movew #8,%sp@-	| 408E82F2
    jsr %a3@	| 408E82F6
    jble rsrc_PACK_5_26E_EA	| 408E82F8
    pea %a4@	| 408E82FA
    pea %pc@(rsrc_PACK_5_105A)	| 408E82FC
    movew #8,%sp@-	| 408E8300
    jsr %a3@	| 408E8304
    jbls rsrc_PACK_5_26E_EA	| 408E8306
    moveal %a1,%a0
    moveal %a4,%a1
    jbsr rsrc_PACK_5_102
    jbsr rsrc_PACK_5_416
    jbra rsrc_PACK_5_26E_184
rsrc_PACK_5_26E_EA:     /* address %fp@(-16) */
    lea %fp@(-16),%a1
    bfextu %a4@,1,15,%d0
    movel %d1,%sp@-
    tstw %a4@(2)
    jbmi rsrc_PACK_5_26E_10C
    bfffo %a4@(2),0,0,%d1
    jbne rsrc_PACK_5_26E_10A
    subw %d1,%d0
    bfffo %a4@(6),0,0,%d1
rsrc_PACK_5_26E_10A:    /* from here: subw %d1,%d0 */
    subw %d1,%d0
rsrc_PACK_5_26E_10C:    /* set %d1 */
    movew #16398,%d1
    subiw #16383,%d0
    swap %d1
    movew %d0,%d1
    jbpl rsrc_PACK_5_26E_120
    negw %d1
    bset #31,%d1
rsrc_PACK_5_26E_120:    /* from here: negw %d0 */
    negw %d0
    swap %d1
    movew %d0,%fp@(-6)
    bfffo %d1,0,16,%d0
    jbne rsrc_PACK_5_26E_132
    moveq #0,%d1
    jbra rsrc_PACK_5_26E_138
rsrc_PACK_5_26E_132:    /* from here: subw %d0,%d1 */
    subw %d0,%d1
    swap %d1
    lslw %d0,%d1
rsrc_PACK_5_26E_138:    /* set %a1@ */
    movel %d1,%a1@
    clrl %a1@(4)
    clrw %a1@(8)
    movel %sp@+,%d1
    pea %fp@(-6)
    pea %a4@
    movew #24,%sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_105A)
    pea %a4@
    movew #8,%sp@-
    jsr %a3@
    jble rsrc_PACK_5_26E_16C
    pea %pc@(rsrc_PACK_5_FBA)
    pea %fp@(-16)
    clrw %sp@-
    jsr %a3@
    subqw #1,%a4@
rsrc_PACK_5_26E_16C:    /* from here: pea %pc@(rsrc_PACK_5_FBA) */
    pea %pc@(rsrc_PACK_5_FBA)
    pea %a4@
    movew #2,%sp@-
    jsr %a3@
    jbsr rsrc_PACK_5_416
    pea %fp@(-16)
    pea %a4@
    clrw %sp@-
    jsr %a3@
rsrc_PACK_5_26E_184:    /* test bit 1 of %d3 */
    btst #1,%d3
    jbne rsrc_PACK_5_26E_1A4
    pea %pc@(rsrc_PACK_5_1078)
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
    movel %a4@(2),%d0
    orl %a4@(6),%d0
    jbeq rsrc_PACK_5_26E_1A4
    jbsr rsrc_PACK_5_1E2
rsrc_PACK_5_26E_1A4:    /* continue at rsrc_PACK_5_4FE */
    jbra rsrc_PACK_5_4FE

/* subroutine (83 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5_18E, rsrc_PACK_5_1E2, rsrc_PACK_5_1D6, rsrc_PACK_5_1D2 ... (mechanical summary) */
rsrc_PACK_5_416:
    movel %a4@(2),%d0
    orl %a4@(6),%d0
    jbne rsrc_PACK_5_416_C
    rts
rsrc_PACK_5_416_C:      /* set %a0 */
    moveal %a4,%a0
    lea %fp@(-26),%a1
    jbsr rsrc_PACK_5_102
    pea %pc@(rsrc_PACK_5_FE2)
    pea %a4@
    clrw %sp@-
    jsr %a3@
    pea %a4@
    pea %a1@
    movew #6,%sp@-
    jsr %a3@
    moveal %a1,%a0
    pea %a1@
    pea %a1@
    lea %fp@(-36),%a1
    jbsr rsrc_PACK_5_102
    movew #4,%sp@-
    jsr %a3@
    moveal %a4,%a0
    lea %pc@(rsrc_PACK_5_F12),%a1
    lea %fp@(-26),%a2
    jbsr rsrc_PACK_5_18E
    pea %fp@(-36)
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
    lea %fp@(-36),%a0
    lea %pc@(rsrc_PACK_5_F50),%a1
    lea %fp@(-26),%a2
    jbsr rsrc_PACK_5_18E
    pea %fp@(-36)
    pea %a4@
    movew #6,%sp@-
    jsr %a3@
    jbsr rsrc_PACK_5_1E2
    rts
rsrc_PACK_5_416_7A:     /* loop: tst */
    tstw %a0@(2)
    jbmi rsrc_PACK_5_416_84
    jbsr rsrc_PACK_5_1D6
rsrc_PACK_5_416_84:     /* call rsrc_PACK_5_1E2 */
    jbsr rsrc_PACK_5_1E2
    jbra rsrc_PACK_5_4FE
rsrc_PACK_5_416_8A:     /* call rsrc_PACK_5_1E2 (loop) */
    jbsr rsrc_PACK_5_1E2
    jbsr rsrc_PACK_5_1D6
rsrc_PACK_5_416_92:     /* loop: lea */
    lea %pc@(rsrc_PACK_5_FCE),%a0
    jbra rsrc_PACK_5_4DC_8
rsrc_PACK_5_416_98:     /* loop: lea */
    lea %pc@(rsrc_PACK_5_FD8),%a0
    jbra rsrc_PACK_5_4DC_8
rsrc_PACK_5_416_9E:     /* call rsrc_PACK_5_1E2 (loop) */
    jbsr rsrc_PACK_5_1E2
rsrc_PACK_5_416_A2:     /* loop: lea */
    lea %pc@(rsrc_PACK_5_FBA),%a0
    jbra rsrc_PACK_5_4DC_8
rsrc_PACK_5_416_A8:     /* call rsrc_PACK_5_1E2 (loop) */
    jbsr rsrc_PACK_5_1E2
rsrc_PACK_5_416_AC:     /* loop: lea */
    lea %pc@(rsrc_PACK_5_FC4),%a0
    jbra rsrc_PACK_5_4DC_8

rsrc_PACK_5_4C8:        /* call rsrc_PACK_5_1E2 (loop) */
    jbsr rsrc_PACK_5_1E2
    jbsr rsrc_PACK_5_1D2
    jbra rsrc_PACK_5_4C8_E
rsrc_PACK_5_4D2:        /* call rsrc_PACK_5_1DA (loop) */
    jbsr rsrc_PACK_5_1DA
rsrc_PACK_5_4C8_E:      /* loop: lea */
    lea %pc@(rsrc_PACK_5_FEC),%a0
    jbra rsrc_PACK_5_4DC_8

rsrc_PACK_5_4DC:        /* call rsrc_PACK_5_1DA (loop) */
    jbsr rsrc_PACK_5_1DA
rsrc_PACK_5_4DC_4:      /* loop: lea */
    lea %pc@(rsrc_PACK_5_FF6),%a0
rsrc_PACK_5_4DC_8:      /* set %a1 */
    moveal %a4,%a1
    jbsr rsrc_PACK_5_102
    jbra rsrc_PACK_5_4FE

rsrc_PACK_5_4EC:        /* loop: ori */
    oril #2147434496,%d0
    movel %d0,%a4@+
    clrl %a4@+
    clrw %a4@
    subql #8,%a4
    jbsr rsrc_PACK_5_1DE

rsrc_PACK_5_4FE:        /* loop: tst */
    tstb %d3
    jbpl rsrc_PACK_5_4FE_8
    movew %a4@,%a4@(-2)
rsrc_PACK_5_4FE_8:      /* from here: pea %fp@(-2) */
    pea %fp@(-2)
    jbsr rsrc_PACK_5_26E
    moveml %sp@+,%d0-%a4
    unlk %fp
    addaw %sp@,%sp
    rts

/* subroutine (33 instructions): calls rsrc_PACK_5_576, rsrc_PACK_5_594, rsrc_PACK_5_660, rsrc_PACK_5_202, rsrc_PACK_5_1FA ... (mechanical summary) */
rsrc_PACK_5_518:
    subqb #1,%d1	| 408E84D8
    jbgt rsrc_PACK_5_4FE_26
    jbeq rsrc_PACK_5_416_A2
    tstw %d1
    jbmi rsrc_PACK_5_416_92
    jbra rsrc_PACK_5_4FE
rsrc_PACK_5_4FE_26:     /* from here: bfextu %a4@,1,31,%d0 */
    bfextu %a4@,1,31,%d0
    cmpil #1069514752,%d0
    jblt rsrc_PACK_5_416_9E
    cmpil #1074626686,%d0
    jble rsrc_PACK_5_4FE_42
    tstw %d1
    jbmi rsrc_PACK_5_416_8A
    jbra rsrc_PACK_5_4C8
rsrc_PACK_5_4FE_42:     /* test bit 1 of %d3 */
    btst #1,%d3
    jbeq rsrc_PACK_5_4FE_4C
    jbsr rsrc_PACK_5_576
    jbra rsrc_PACK_5_4FE_4E
rsrc_PACK_5_4FE_4C:     /* call rsrc_PACK_5_594 */
    jbsr rsrc_PACK_5_594
rsrc_PACK_5_4FE_4E:     /* call rsrc_PACK_5_660 */
    jbsr rsrc_PACK_5_660
    pea %pc@(rsrc_PACK_5_FBA)
    pea %a4@
    clrw %sp@-
    jsr %a3@
    moveal %a4,%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_202
    bftst %a4@,1,16
    jbne rsrc_PACK_5_4FE
    jbsr rsrc_PACK_5_1FA
    jbeq rsrc_PACK_5_4FE
    jbsr rsrc_PACK_5_1D6
    jbra rsrc_PACK_5_4FE

/* subroutine (11 instructions): calls rsrc_PACK_5_102 (mechanical summary) */
rsrc_PACK_5_576:
    moveal %a4,%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_102
    pea %a1@
    movew #20,%sp@-
    jsr %a3@
    pea %a1@
    pea %a4@
    movew #2,%sp@-
    jsr %a3@
    rts

/* subroutine (23 instructions): calls rsrc_PACK_5_102 (mechanical summary) */
rsrc_PACK_5_594:
    moveal %a4,%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_102
    pea %pc@(rsrc_PACK_5_1078)
    movel %sp@,%sp@-
    movel %sp@,%sp@-
    pea %a4@
    movew #12,%sp@-
    jsr %a3@
    pea %a4@
    pea %a1@
    movew #2,%sp@-
    jsr %a3@
    pea %a1@
    movew #6,%sp@-
    jsr %a3@
    pea %a1@
    movew #20,%sp@-
    jsr %a3@
    pea %a4@
    movew #6,%sp@-
    jsr %a3@
    rts

/* subroutine (44 instructions): calls rsrc_PACK_5_576, rsrc_PACK_5_594, rsrc_PACK_5_660, rsrc_PACK_5_202 (mechanical summary) */
rsrc_PACK_5_5D2:
    subqb #1,%d1	| 408E8592
    jbgt rsrc_PACK_5_594_4E
    jbeq rsrc_PACK_5_594_4A
    tstw %d1
    jbmi rsrc_PACK_5_416_AC
rsrc_PACK_5_594_4A:     /* continue at rsrc_PACK_5_4FE */
    jbra rsrc_PACK_5_4FE
rsrc_PACK_5_594_4E:     /* from here: bfextu %a4@,1,31,%d0 */
    bfextu %a4@,1,31,%d0
    tstw %d1
    jbpl rsrc_PACK_5_594_62
    cmpil #1074102272,%d0
    jble rsrc_PACK_5_594_6C
    jbra rsrc_PACK_5_416_A8
rsrc_PACK_5_594_62:     /* test #1074626560,%d0 */
    cmpil #1074626560,%d0
    jbgt rsrc_PACK_5_4C8
rsrc_PACK_5_594_6C:     /* test bit 1 of %d3 */
    btst #1,%d3
    jbeq rsrc_PACK_5_594_90
    cmpil #1069514752,%d0
    jbge rsrc_PACK_5_594_8A
    pea %pc@(rsrc_PACK_5_1078)
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
rsrc_PACK_5_594_86:     /* continue at rsrc_PACK_5_416_7A */
    jbra rsrc_PACK_5_416_7A
rsrc_PACK_5_594_8A:     /* call rsrc_PACK_5_576 */
    jbsr rsrc_PACK_5_576
    jbra rsrc_PACK_5_594_9C
rsrc_PACK_5_594_90:     /* test #1069514752,%d0 */
    cmpil #1069514752,%d0
    jblt rsrc_PACK_5_594_86
    jbsr rsrc_PACK_5_594
rsrc_PACK_5_594_9C:     /* call rsrc_PACK_5_660 */
    jbsr rsrc_PACK_5_660
    movel %fp@(-14),%d0
    orl %fp@(-10),%d0
    jbeq rsrc_PACK_5_594_C8
    pea %pc@(rsrc_PACK_5_FBA)
    pea %a4@
    clrw %sp@-
    jsr %a3@
    moveal %a4,%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_202
    pea %pc@(rsrc_PACK_5_FBA)
    pea %a4@
    movew #2,%sp@-
    jsr %a3@
rsrc_PACK_5_594_C8:     /* continue at rsrc_PACK_5_4FE */
    jbra rsrc_PACK_5_4FE

/* subroutine (37 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5_18E, rsrc_PACK_5_1E2 (mechanical summary) */
rsrc_PACK_5_660:
    movel %a4@(2),%d0
    orl %a4@(6),%d0
    jbne rsrc_PACK_5_660_C
    rts
rsrc_PACK_5_660_C:      /* address %fp@(-36) */
    lea %fp@(-36),%a1
    moveal %a4,%a0
    jbsr rsrc_PACK_5_102
    pea %a1@
    pea %a1@
    movew #4,%sp@-
    jsr %a3@
    lea %fp@(-26),%a0
    lea %pc@(rsrc_PACK_5_F70),%a1
    lea %fp@(-36),%a2
    jbsr rsrc_PACK_5_18E
    pea %fp@(-26)
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
    lea %fp@(-26),%a0
    lea %pc@(rsrc_PACK_5_F9A),%a1
    lea %fp@(-36),%a2
    jbsr rsrc_PACK_5_18E
    pea %a4@
    pea %fp@(-26)
    movew #2,%sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_FE2)
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
    pea %fp@(-26)
    pea %a4@
    movew #6,%sp@-
    jsr %a3@
    jbsr rsrc_PACK_5_1E2
    rts

/* subroutine (38 instructions): calls rsrc_PACK_5_740, rsrc_PACK_5_230, rsrc_PACK_5_7C6 (mechanical summary) */
rsrc_PACK_5_6D6:
    moveal %d4,%a0	| 408E8696
    movew %a0@,%d2	| 408E8698
    jbeq rsrc_PACK_5_416_A2	| 408E869A
    subqb #1,%d1	| 408E869E
    jbgt rsrc_PACK_5_708	| 408E86A0
    asrw #1,%d2	| 408E86A2
    jbcs rsrc_PACK_5_6EA	| 408E86A4
    bclr #7,%a4@	| 408E86A6
rsrc_PACK_5_6EA:        /* from here: addxw %d2,%d2 */
    addxw %d2,%d2	| 408E86AA
    jbpl rsrc_PACK_5_4FE	| 408E86AC
    tstb %d1	| 408E86B0
    jbpl rsrc_PACK_5_6FE	| 408E86B2
    tstb %a4@	| 408E86B4
    jbpl rsrc_PACK_5_416_92	| 408E86B6
    jbra rsrc_PACK_5_416_98	| 408E86BA
rsrc_PACK_5_6FE:        /* test %a4@ */
    tstb %a4@	| 408E86BE
    jbpl rsrc_PACK_5_4D2	| 408E86C0
    jbra rsrc_PACK_5_4DC	| 408E86C4
rsrc_PACK_5_708:        /* set %d0 */
    movew %d2,%d0	| 408E86C8
    jbpl rsrc_PACK_5_70E	| 408E86CA
    negw %d0	| 408E86CC
rsrc_PACK_5_70E:        /* test #255,%d0 */
    cmpiw #255,%d0
    jbhi rsrc_PACK_5_660_BA
    jbsr rsrc_PACK_5_740
    jbra rsrc_PACK_5_4FE
rsrc_PACK_5_660_BA:     /* set %sp@- */
    movew %a4@,%sp@-
    bclr #7,%a4@
    movel %d4,%sp@-
    pea %fp@(-16)
    movel %sp@,%d4
    jbsr rsrc_PACK_5_230
    jbsr rsrc_PACK_5_7C6
    movew %sp@+,%d0
    jbpl rsrc_PACK_5_660_DC
    asrw #1,%d2
    jbcc rsrc_PACK_5_660_DC
    bset #7,%a4@
rsrc_PACK_5_660_DC:     /* continue at rsrc_PACK_5_4FE */
    jbra rsrc_PACK_5_4FE

/* subroutine (32 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5_79A, rsrc_PACK_5_1EE, rsrc_PACK_5_1F2, rsrc_PACK_5_1C2 ... (mechanical summary) */
rsrc_PACK_5_740:
    moveal %a4,%a0
    lea %fp@(-26),%a1
    jbsr rsrc_PACK_5_102
    jbsr rsrc_PACK_5_79A
    tstw %d2
    jbmi rsrc_PACK_5_740_18
rsrc_PACK_5_740_10:     /* loop: movea */
    moveal %a1,%a0
    moveal %a4,%a1
    jbra rsrc_PACK_5_102
rsrc_PACK_5_740_18:     /* address %pc@(rsrc_PACK_5_FBA) */
    lea %pc@(rsrc_PACK_5_FBA),%a0
    lea %a4@,%a1
    jbsr rsrc_PACK_5_102
    jbsr rsrc_PACK_5_1EE
    jbne rsrc_PACK_5_740_3C
    jbsr rsrc_PACK_5_1F2
    jbne rsrc_PACK_5_740_3C
    pea %fp@(-16)
    pea %a4@
    movew #6,%sp@-
    jsr %a3@
    rts
rsrc_PACK_5_740_3C:     /* call rsrc_PACK_5_1C2 */
    jbsr rsrc_PACK_5_1C2
    jbsr rsrc_PACK_5_1BE
    pea %fp@(-26)
    pea %a4@
    movew #6,%sp@-
    jsr %a3@
    movew %d2,%d0
    jbpl rsrc_PACK_5_740_56
    negw %d0
rsrc_PACK_5_740_56:     /* call rsrc_PACK_5_79A */
    jbsr rsrc_PACK_5_79A
    jbra rsrc_PACK_5_740_10

/* subroutine (17 instructions): calls rsrc_PACK_5_102 (mechanical summary) */
rsrc_PACK_5_79A:
    lea %pc@(rsrc_PACK_5_FBA),%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_102
    jbra rsrc_PACK_5_79A_18
rsrc_PACK_5_79A_E:      /* loop: pea */
    pea %a4@
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
rsrc_PACK_5_79A_18:     /* from here: lsrw #1,%d0 */
    lsrw #1,%d0
    jbcc rsrc_PACK_5_79A_26
    pea %a4@
    pea %a1@
    movew #4,%sp@-
    jsr %a3@
rsrc_PACK_5_79A_26:     /* test %d0 */
    tstw %d0
    jbne rsrc_PACK_5_79A_E
    rts

/* subroutine (16 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5 (mechanical summary) */
rsrc_PACK_5_7C6:
    moveal %a4,%a0
    lea %fp@(-26),%a1
    jbsr rsrc_PACK_5_102
    pea %a1@
    movew #2,%sp@-
    jbsr rsrc_PACK_5
    movel %d4,%sp@-
    pea %a1@
    movew #4,%sp@-
    jsr %a3@
    pea %a1@
    movew #10,%sp@-
    jbsr rsrc_PACK_5
    moveal %a1,%a0
    moveal %a4,%a1
    jbra rsrc_PACK_5_102

/* subroutine (33 instructions): calls rsrc_PACK_5_85C, rsrc_PACK_5_1CA, rsrc_PACK_5_102, rsrc_PACK_5_1FA; low memory FPState (mechanical summary) */
rsrc_PACK_5_7F6:
    tstw %d1	| 408E87B6
    jbmi rsrc_PACK_5_80C	| 408E87B8
    jbsr rsrc_PACK_5_85C	| 408E87BA
    jbra rsrc_PACK_5_4FE	| 408E87BC

rsrc_PACK_5_800:        /* loop: addq */
    addql #4,%sp
rsrc_PACK_5_800_2:      /* call rsrc_PACK_5_1CA (loop) */
    jbsr rsrc_PACK_5_1CA
    moveq #37,%d0
    jbra rsrc_PACK_5_4EC
rsrc_PACK_5_80C:        /* test %d2 */
    tstb %d2
    jbeq rsrc_PACK_5_800_2
    moveal %d4,%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_102
    pea %a1@
    movew #20,%sp@-
    jsr %a3@
    jbsr rsrc_PACK_5_1FA
    jbne rsrc_PACK_5_800_2
    pea %pc@(rsrc_PACK_5_FE2)
    pea %a1@
    movew #6,%sp@-
    jsr %a3@
    pea %a1@
    movew #20,%sp@-
    jsr %a3@
    movew FPState,%fp@(-6)
    jbsr rsrc_PACK_5_1CA
    bclr #7,%a4@
    jbsr rsrc_PACK_5_85C
    btst #4,%fp@(-6)
    jbeq rsrc_PACK_5_800_58
    bchg #7,%a4@
rsrc_PACK_5_800_58:     /* continue at rsrc_PACK_5_4FE */
    jbra rsrc_PACK_5_4FE

/* subroutine (46 instructions): calls rsrc_PACK_5_1DA, rsrc_PACK_5_1F6, rsrc_PACK_5_1C6, rsrc_PACK_5_1FA, rsrc_PACK_5_1CA ... (mechanical summary) */
rsrc_PACK_5_85C:
    subqb #1,%d1
    jbne rsrc_PACK_5_85C_20
    subqb #1,%d2
    jbeq rsrc_PACK_5_800
    tstw %d2
    jbpl rsrc_PACK_5_85C_16
    jbsr rsrc_PACK_5_1DA
    lea %pc@(rsrc_PACK_5_FEC),%a0
    jbra rsrc_PACK_5_85C_1A
rsrc_PACK_5_85C_16:     /* address %pc@(rsrc_PACK_5_FCE) */
    lea %pc@(rsrc_PACK_5_FCE),%a0
rsrc_PACK_5_85C_1A:     /* set %a1 */
    moveal %a4,%a1
    jbra rsrc_PACK_5_102
rsrc_PACK_5_85C_20:     /* from here: jbpl rsrc_PACK_5_85C_2A */
    jbpl rsrc_PACK_5_85C_2A
    subqb #1,%d2
    jbne rsrc_PACK_5_85C_3E
    jbra rsrc_PACK_5_800
rsrc_PACK_5_85C_2A:     /* subtract 1 to %d2 */
    subqb #1,%d2
    jbpl rsrc_PACK_5_85C_3E
    pea %pc@(rsrc_PACK_5_FBA)
    pea %a4@
    movew #8,%sp@-
    jsr %a3@
    jbeq rsrc_PACK_5_800
rsrc_PACK_5_85C_3E:     /* set %d6 */
    movew %d2,%d6
    movel %d4,%sp@-
    pea %fp@(-4)
    movew #8208,%sp@-
    jsr %a3@
    jbsr rsrc_PACK_5_1F6
    sne %d7
    jbsr rsrc_PACK_5_1C6
    jbsr rsrc_PACK_5_1FA
    sne %d1
    orb %d1,%d7
    jbne rsrc_PACK_5_85C_72
    movew %fp@(-4),%d2
    movew %d2,%d0
    jbpl rsrc_PACK_5_85C_6A
    negw %d0
rsrc_PACK_5_85C_6A:     /* test #255,%d0 */
    cmpiw #255,%d0
    jble rsrc_PACK_5_740
rsrc_PACK_5_85C_72:     /* call rsrc_PACK_5_1CA */
    jbsr rsrc_PACK_5_1CA
    jbsr rsrc_PACK_5_7C6
    tstb %d6
    jbmi rsrc_PACK_5_1CA
    rts

/* subroutine (52 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5, rsrc_PACK_5_1BE (mechanical summary) */
rsrc_PACK_5_8DE:
    pea %pc@(rsrc_PACK_5_FC4)	| 408E889E
    movel %d5,%sp@-	| 408E88A2
    movew #8,%sp@-	| 408E88A4
    jsr %a3@	| 408E88A8
    bltw rsrc_PACK_5_96C	| 408E88AA
    jbgt rsrc_PACK_5_904	| 408E88AE
    subqb #1,%d2	| 408E88B0
    jbne rsrc_PACK_5_8F8	| 408E88B2
rsrc_PACK_5_8F4:        /* continue at rsrc_PACK_5_416_A2 */
    jbra rsrc_PACK_5_416_A2	| 408E88B4
rsrc_PACK_5_8F8:        /* set %a0 */
    moveal %d4,%a0	| 408E88B8
    tstb %a0@	| 408E88BA
    jbmi rsrc_PACK_5_4D2	| 408E88BC
rsrc_PACK_5_900:        /* continue at rsrc_PACK_5_416_92 */
    jbra rsrc_PACK_5_416_92	| 408E88C0
rsrc_PACK_5_904:        /* subtract 1 to %d2 */
    subqb #1,%d2	| 408E88C4
    jbeq rsrc_PACK_5_8F4	| 408E88C6
    jbgt rsrc_PACK_5_916	| 408E88C8
    subqb #1,%d1	| 408E88CA
    jbeq rsrc_PACK_5_96C	| 408E88CC
    eorw %d2,%d1	| 408E88CE
    jbmi rsrc_PACK_5_900	| 408E88D0
    jbra rsrc_PACK_5_4C8_E	| 408E88D2
rsrc_PACK_5_916:        /* address %fp@(-26) */
    lea %fp@(-26),%a1	| 408E88D6
    moveal %d5,%a0	| 408E88DA
    jbsr rsrc_PACK_5_102	| 408E88DC
    movew %a1@,%d0	| 408E88E0
    bclr #15,%d0	| 408E88E2
    cmpiw #16255,%d0	| 408E88E6
    jblt rsrc_PACK_5_948	| 408E88EA
    pea %a1@	| 408E88EC
    movew #6,%sp@-	| 408E88EE
    jbsr rsrc_PACK_5	| 408E88F2
    movel %d4,%sp@-	| 408E88F6
    pea %a1@	| 408E88F8
    movew #4,%sp@-	| 408E88FA
    jsr %a3@	| 408E88FE
    pea %a1@	| 408E8900
    movew #10,%sp@-	| 408E8902
    jbra rsrc_PACK_5_958	| 408E8906
rsrc_PACK_5_948:        /* set %sp@- */
    movel %d4,%sp@-	| 408E8908
    pea %a1@	| 408E890A
    movew #4,%sp@-	| 408E890C
    jsr %a3@	| 408E8910
    pea %a1@	| 408E8912
    movew #8,%sp@-	| 408E8914
rsrc_PACK_5_958:        /* call rsrc_PACK_5_1BE */
    jbsr rsrc_PACK_5_1BE
    jbsr rsrc_PACK_5
    moveal %a1,%a0
    moveal %a4,%a1
    jbsr rsrc_PACK_5_102
    jbra rsrc_PACK_5_4FE
rsrc_PACK_5_96C:        /* result 38 */
    moveq #38,%d0	| 408E892C
    jbra rsrc_PACK_5_4EC	| 408E892E

/* subroutine (115 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5, rsrc_PACK_5_1BE, rsrc_PACK_5_1C2, rsrc_PACK_5_10C ... (mechanical summary) */
rsrc_PACK_5_972:
    pea %pc@(rsrc_PACK_5_FC4)	| 408E8932
    movel %d5,%sp@-	| 408E8936
    movew #8,%sp@-	| 408E8938
    jsr %a3@	| 408E893C
    jblt rsrc_PACK_5_96C	| 408E893E
    jbne rsrc_PACK_5_990	| 408E8940
    subqb #1,%d2	| 408E8942
    jbeq rsrc_PACK_5_85C_138	| 408E8944
    tstw %d2	| 408E8946
    jbpl rsrc_PACK_5_4D2	| 408E8948
rsrc_PACK_5_85C_130:    /* continue at rsrc_PACK_5_416_AC */
    jbra rsrc_PACK_5_416_AC
rsrc_PACK_5_990:        /* subtract 1 to %d2 */
    subqb #1,%d2	| 408E8950
    jbne rsrc_PACK_5_998	| 408E8952
rsrc_PACK_5_85C_138:    /* continue at rsrc_PACK_5_416_92 */
    jbra rsrc_PACK_5_416_92
rsrc_PACK_5_998:        /* subtract 1 to %d1 */
    subqb #1,%d1	| 408E8958
    jbgt rsrc_PACK_5_9C4	| 408E895A
    jblt rsrc_PACK_5_9AA	| 408E895C
rsrc_PACK_5_99E:        /* loop: movea */
    moveal %a4,%a1	| 408E895E
    moveal %d4,%a0	| 408E8960
    jbsr rsrc_PACK_5_102	| 408E8962
    jbra rsrc_PACK_5_4FE	| 408E8966
rsrc_PACK_5_9AA:        /* test %d2 */
    tstw %d2
    jbpl rsrc_PACK_5_85C_138
    pea %pc@(rsrc_PACK_5_FC4)
    movel %d4,%sp@-
    movew #8,%sp@-
    jsr %a3@
    jbeq rsrc_PACK_5_85C_130
    jbgt rsrc_PACK_5_416_98
    jbra rsrc_PACK_5_4DC_4
rsrc_PACK_5_9C4:        /* test %d2 */
    tstb %d2	| 408E8984
    jbpl rsrc_PACK_5_9EE	| 408E8986
    eorw %d2,%d1	| 408E8988
    jbmi rsrc_PACK_5_99E	| 408E898A
    moveal %d5,%a0	| 408E898C
    lea %fp@(-26),%a1	| 408E898E
    jbsr rsrc_PACK_5_102	| 408E8992
    pea %a1@	| 408E8996
    moveal %a4,%a1	| 408E8998
    lea %pc@(rsrc_PACK_5_FBA),%a0	| 408E899A
    jbsr rsrc_PACK_5_102	| 408E899E
    pea %a1@	| 408E89A2
    movew #6,%sp@-	| 408E89A4
    jsr %a3@	| 408E89A8
    jbra rsrc_PACK_5_4FE	| 408E89AA
rsrc_PACK_5_9EE:        /* address %fp@(-26) */
    lea %fp@(-26),%a1	| 408E89AE
    moveal %d5,%a0	| 408E89B2
    jbsr rsrc_PACK_5_102	| 408E89B4
    movew %a1@,%d0	| 408E89B8
    bclr #15,%d0	| 408E89BA
    cmpiw #16255,%d0	| 408E89BE
    jblt rsrc_PACK_5_A32	| 408E89C2
    pea %a1@	| 408E89C4
    movew #6,%sp@-	| 408E89C6
    jbsr rsrc_PACK_5	| 408E89CA
    movel %d4,%sp@-	| 408E89CE
    pea %a1@	| 408E89D0
    movew #4,%sp@-	| 408E89D2
    jsr %a3@	| 408E89D6
    bchg #7,%a1@	| 408E89D8
    cmpiw #16391,%a1@	| 408E89DC
    jblt rsrc_PACK_5_A2A	| 408E89E0
    moveal %d5,%a0	| 408E89E2
    cmpiw #16511,%a0@	| 408E89E4
    jbge rsrc_PACK_5_A86	| 408E89E8
rsrc_PACK_5_A2A:        /* from here: pea %a1@ */
    pea %a1@	| 408E89EA
    movew #14,%sp@-	| 408E89EC
    jbra rsrc_PACK_5_A46	| 408E89F0
rsrc_PACK_5_A32:        /* set %sp@- */
    movel %d4,%sp@-	| 408E89F2
    pea %a1@	| 408E89F4
    movew #4,%sp@-	| 408E89F6
    jsr %a3@	| 408E89FA
    bchg #7,%a1@	| 408E89FC
    pea %a1@	| 408E8A00
    movew #12,%sp@-	| 408E8A02
rsrc_PACK_5_A46:        /* call rsrc_PACK_5 */
    jbsr rsrc_PACK_5	| 408E8A06
    bchg #7,%a1@	| 408E8A0A
    movel %d5,%sp@-	| 408E8A0E
    pea %a1@	| 408E8A10
    movew #6,%sp@-	| 408E8A12
    jsr %a3@
    jbsr rsrc_PACK_5_1BE
    jbsr rsrc_PACK_5_1C2
    moveal %a1,%a0
    jbsr rsrc_PACK_5_10C
    subqb #3,%d0
    jbne rsrc_PACK_5_85C_214
    jbsr rsrc_PACK_5_1D2
    jbra rsrc_PACK_5_85C_21C
rsrc_PACK_5_85C_214:    /* subtract 2 to %d0 */
    subqb #2,%d0
    jbeq rsrc_PACK_5_85C_21C
    jbsr rsrc_PACK_5_1D6
rsrc_PACK_5_85C_21C:    /* address %fp@(-26) */
    lea %fp@(-26),%a0
    moveal %a4,%a1
    jbsr rsrc_PACK_5_102
    jbra rsrc_PACK_5_4FE
rsrc_PACK_5_A86:        /* set %a0 */
    moveal %d5,%a0	| 408E8A46
    jbsr rsrc_PACK_5_102	| 408E8A48
    pea %a1@	| 408E8A4C
    movew #2,%sp@-	| 408E8A4E
    jbsr rsrc_PACK_5	| 408E8A52
    lea %fp@(-36),%a1	| 408E8A56
    moveal %d4,%a0	| 408E8A5A
    jbsr rsrc_PACK_5_102	| 408E8A5C
    pea %pc@(rsrc_PACK_5_FBA)	| 408E8A60
    pea %a1@	| 408E8A64
    clrw %sp@-	| 408E8A66
    jsr %a3@	| 408E8A68
    pea %a1@	| 408E8A6A
    lea %fp@(-26),%a1	| 408E8A6C
    pea %a1@	| 408E8A70
    movew #4,%sp@-	| 408E8A72
    jsr %a3@	| 408E8A76
    bchg #7,%a1@	| 408E8A78
    pea %a1@	| 408E8A7C
    movew #10,%sp@-	| 408E8A7E
    jbsr rsrc_PACK_5	| 408E8A82
    bchg #7,%a1@	| 408E8A86
    bras rsrc_PACK_5_A46+0x12

/* subroutine (21 instructions): calls rsrc_PACK_5_B2A, rsrc_PACK_5_B3A, rsrc_PACK_5_BA0, rsrc_PACK_5_1E2 (mechanical summary) */
rsrc_PACK_5_ACC:
    moveq #33,%d0
    moveq #0,%d2
    subqb #1,%d1
    jbgt rsrc_PACK_5_85C_280
    jbeq rsrc_PACK_5_4FE
    jbmi rsrc_PACK_5_4EC
rsrc_PACK_5_85C_280:    /* from here: bfextu %a0@,1,15,%d0 */
    bfextu %a0@,1,15,%d0
    cmpiw #16351,%d0
    jblt rsrc_PACK_5_416_7A
rsrc_PACK_5_85C_28C:    /* call rsrc_PACK_5_B2A (loop) */
    jbsr rsrc_PACK_5_B2A
    btst #0,%d2
    jbne rsrc_PACK_5_85C_298
    jbsr rsrc_PACK_5_B3A
    jbra rsrc_PACK_5_85C_29C
rsrc_PACK_5_85C_298:    /* call rsrc_PACK_5_BA0 */
    jbsr rsrc_PACK_5_BA0
rsrc_PACK_5_85C_29C:    /* from here: andiw #3,%d2 */
    andiw #3,%d2
    subqw #2,%d2
    jbmi rsrc_PACK_5_85C_2A8
    bchg #7,%a4@
rsrc_PACK_5_85C_2A8:    /* call rsrc_PACK_5_1E2 (loop) */
    jbsr rsrc_PACK_5_1E2
    jbra rsrc_PACK_5_4FE

/* subroutine (10 instructions) (mechanical summary) */
rsrc_PACK_5_B0C:
    moveq #33,%d0
    moveq #1,%d2
    subqb #1,%d1
    jbgt rsrc_PACK_5_85C_2C0
    jbeq rsrc_PACK_5_416_A2
    jbra rsrc_PACK_5_4EC
rsrc_PACK_5_85C_2C0:    /* from here: bfextu %a4@,1,15,%d0 */
    bfextu %a4@,1,15,%d0
    cmpiw #16351,%d0
    jbge rsrc_PACK_5_85C_28C
    jbra rsrc_PACK_5_416_9E

/* subroutine (6 instructions) (mechanical summary) */
rsrc_PACK_5_B2A:
    pea %pc@(rsrc_PACK_5_1032)
    pea %a4@
    movew #12,%sp@-
    jsr %a3@
    addw %d0,%d2
    rts

/* subroutine (15 instructions): calls rsrc_PACK_5_B6E (mechanical summary) */
rsrc_PACK_5_B3A:
    lea %pc@(rsrc_PACK_5_10A0),%a2
    jbsr rsrc_PACK_5_B6E
    pea %a4@
    pea %a2@
    movew #4,%sp@-
    jsr %a3@
    pea %a2@
    pea %a0@
    movew #4,%sp@-
    jsr %a3@
    pea %a0@
    pea %a4@
    movew #2,%sp@-
    jsr %a3@
    rts

/* subroutine (6 instructions): calls rsrc_PACK_5_B6E (mechanical summary) */
rsrc_PACK_5_B60:
    jbsr rsrc_PACK_5_B6E
    pea %a2@
    pea %a0@
    movew #4,%sp@-
    jsr %a3@
    rts

/* subroutine (17 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5_18E (mechanical summary) */
rsrc_PACK_5_B6E:
    moveal %a4,%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_102
    pea %a1@
    pea %a1@
    movew #4,%sp@-
    jsr %a3@
    exg %a1,%a2
    lea %fp@(-36),%a0
    jbsr rsrc_PACK_5_18E
    pea %a0@
    lea %fp@(-26),%a0
    jbsr rsrc_PACK_5_18E
    pea %a0@
    movew #6,%sp@-
    jsr %a3@
    rts

/* subroutine (56 instructions): calls rsrc_PACK_5_B60, rsrc_PACK_5_102 (mechanical summary) */
rsrc_PACK_5_BA0:
    lea %pc@(rsrc_PACK_5_10F4),%a2
    jbsr rsrc_PACK_5_B60
    pea %a2@
    pea %a0@
    movew #4,%sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_100A)
    pea %a2@
    movew #8,%sp@-
    jsr %a3@
    jbgt rsrc_PACK_5_BA0_46
    pea %pc@(DSPTABLE_15C64)
    pea %a2@
    movew #4,%sp@-
    jsr %a3@
    pea %a2@
    pea %a0@
    movew #2,%sp@-
    jsr %a3@
    moveal %a4,%a1
    jbsr rsrc_PACK_5_102
    pea %pc@(rsrc_PACK_5_FBA)
    pea %a4@
    clrw %sp@-
    jsr %a3@
    rts
rsrc_PACK_5_BA0_46:     /* clear bit 7 of %a4@ */
    bclr #7,%a4@
    pea %pc@(DSPTABLE_15C64)
    pea %a4@
    movew #2,%sp@-
    jsr %a3@
    pea %a0@
    moveal %a4,%a0
    moveal %a2,%a1
    jbsr rsrc_PACK_5_102
    pea %pc@(DSPTABLE_15C64)
    pea %a1@
    movew #4,%sp@-
    jsr %a3@
    pea %a1@
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
    pea %a4@
    movew #2,%sp@-
    jsr %a3@
    pea %a1@
    pea %a4@
    clrw %sp@-
    jsr %a3@
    bchg #7,%a4@
    pea %pc@(DSPTABLE_15C78)
    pea %a4@
    clrw %sp@-
    jsr %a3@
    rts

/* subroutine (27 instructions): calls rsrc_PACK_5_B2A, rsrc_PACK_5_C8A, rsrc_PACK_5_102, rsrc_PACK_5_1EA (mechanical summary) */
rsrc_PACK_5_C36:
    moveq #33,%d0
    moveq #0,%d2
    subqb #1,%d1
    jbmi rsrc_PACK_5_4EC
    jbeq rsrc_PACK_5_4FE
    bfextu %a4@,1,15,%d0
    cmpiw #16351,%d0
    jblt rsrc_PACK_5_416_7A
    jbsr rsrc_PACK_5_B2A
    jbsr rsrc_PACK_5_C8A
    rorw #1,%d2
    jbcc rsrc_PACK_5_BA0_E6
    bchg #7,%a4@
    moveal %a4,%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_102
    pea %a1@
    lea %pc@(rsrc_PACK_5_FBA),%a0
    moveal %a4,%a1
    jbsr rsrc_PACK_5_102
    pea %a4@
    movew #6,%sp@-
    jsr %a3@
    jbsr rsrc_PACK_5_1EA
    jbeq rsrc_PACK_5_BA0_E6
    bchg #7,%a4@
rsrc_PACK_5_BA0_E6:     /* continue at rsrc_PACK_5_85C_2A8 */
    jbra rsrc_PACK_5_85C_2A8

/* subroutine (61 instructions): calls rsrc_PACK_5_B60, rsrc_PACK_5_102 (mechanical summary) */
rsrc_PACK_5_C8A:
    lea %pc@(rsrc_PACK_5_1148),%a2
    jbsr rsrc_PACK_5_B60
    moveal %a4,%a0
    lea %fp@(-46),%a1
    jbsr rsrc_PACK_5_102
    pea %a2@
    pea %a1@
    movew #4,%sp@-
    jsr %a3@
    pea %a1@
    lea %fp@(-26),%a0
    pea %a0@
    movew #4,%sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_100A)
    pea %a2@
    movew #8,%sp@-
    jsr %a3@
    jbgt rsrc_PACK_5_C8A_4E
    pea %pc@(DSPTABLE_15C50)
    pea %a1@
    movew #6,%sp@-
    jsr %a3@
    pea %a1@
    pea %a0@
    clrw %sp@-
    jsr %a3@
    jbra rsrc_PACK_5_C8A_98
rsrc_PACK_5_C8A_4E:     /* from here: pea %a0@ */
    pea %a0@
    moveal %a4,%a0
    lea %fp@(-36),%a1
    jbsr rsrc_PACK_5_102
    pea %pc@(rsrc_PACK_5_101E)
    pea %a1@
    movew #2,%sp@-
    jsr %a3@
    pea %pc@(DSPTABLE_15C50)
    pea %a1@
    movew #6,%sp@-
    jsr %a3@
    pea %a2@
    pea %a1@
    movew #4,%sp@-
    jsr %a3@
    pea %a1@
    clrw %sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_100A)
    pea %a2@
    movew #4,%sp@-
    jsr %a3@
    pea %a2@
    pea %a1@
    clrw %sp@-
    jsr %a3@
    moveal %a1,%a0
rsrc_PACK_5_C8A_98:     /* from here: pea %a0@ */
    pea %a0@
    pea %a4@
    clrw %sp@-
    jsr %a3@
    rts

/* subroutine (21 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5_1E2, rsrc_PACK_5_D6A (mechanical summary) */
rsrc_PACK_5_D2C:
    subqb #1,%d1	| 408E8CEC
    jbgt rsrc_PACK_5_C8A_BA
    jbeq rsrc_PACK_5_C8A_B6
rsrc_PACK_5_C8A_A8:     /* loop: lea */
    lea %pc@(rsrc_PACK_5_1032),%a0
    moveal %a4,%a1
    jbsr rsrc_PACK_5_102
    clrb %d1
    orw %d1,%a4@
rsrc_PACK_5_C8A_B6:     /* continue at rsrc_PACK_5_4FE */
    jbra rsrc_PACK_5_4FE
rsrc_PACK_5_C8A_BA:     /* from here: bfextu %a4@,1,15,%d0 */
    bfextu %a4@,1,15,%d0
    cmpiw #16351,%d0
    jblt rsrc_PACK_5_416_7A
    cmpiw #16448,%d0
    jblt rsrc_PACK_5_C8A_D2
    jbsr rsrc_PACK_5_1E2
    jbra rsrc_PACK_5_C8A_A8
rsrc_PACK_5_C8A_D2:     /* clear bit 7 of %a4@ */
    bclr #7,%a4@
    jbsr rsrc_PACK_5_D6A
    clrb %d1
    orw %d1,%a4@
    jbra rsrc_PACK_5_85C_2A8

/* subroutine (101 instructions): calls rsrc_PACK_5_102, rsrc_PACK_5_B6E (mechanical summary) */
rsrc_PACK_5_D6A:
    moveq #0,%d2
    pea %pc@(rsrc_PACK_5_FBA)
    pea %a4@
    movew #8,%sp@-
    jsr %a3@
    jbls rsrc_PACK_5_D6A_30
    moveq #-1,%d2
    moveal %a4,%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_102
    pea %a1@
    lea %pc@(rsrc_PACK_5_FBA),%a0
    moveal %a4,%a1
    jbsr rsrc_PACK_5_102
    pea %a1@
    movew #6,%sp@-
    jsr %a3@
rsrc_PACK_5_D6A_30:     /* set %sp@- */
    movel %a4@+,%sp@-
    movel %a4@+,%sp@-
    movew %a4@,%sp@-
    subql #8,%a4
    pea %pc@(rsrc_PACK_5_1096)
    pea %a4@
    movew #8,%sp@-
    jsr %a3@
    jbgt rsrc_PACK_5_D6A_5C
    lea %pc@(rsrc_PACK_5_119C),%a2
    jbsr rsrc_PACK_5_B6E
    pea %a0@
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
    jbra rsrc_PACK_5_D6A_F2
rsrc_PACK_5_D6A_5C:     /* set %a0 */
    moveal %a4,%a0
    lea %fp@(-16),%a1
    jbsr rsrc_PACK_5_102
    pea %pc@(rsrc_PACK_5_1082)
    pea %a1@
    movew #4,%sp@-
    jsr %a3@
    pea %a1@
    lea %pc@(rsrc_PACK_5_FBA),%a0
    lea %fp@(-36),%a1
    jbsr rsrc_PACK_5_102
    pea %a1@
    movew #6,%sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_FBA)
    pea %a1@
    clrw %sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_FBA)
    pea %fp@(-16)
    clrw %sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_1082)
    pea %a4@
    movew #2,%sp@-
    jsr %a3@
    moveal %a4,%a0
    lea %fp@(-46),%a1
    jbsr rsrc_PACK_5_102
    pea %fp@(-16)
    pea %a4@
    movew #6,%sp@-
    jsr %a3@
    pea %fp@(-36)
    pea %a1@
    movew #6,%sp@-
    jsr %a3@
    lea %pc@(rsrc_PACK_5_119C),%a2
    jbsr rsrc_PACK_5_B6E
    pea %a0@
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_108C)
    pea %a4@
    clrw %sp@-
    jsr %a3@
    pea %fp@(-46)
    pea %a4@
    clrw %sp@-
    jsr %a3@
rsrc_PACK_5_D6A_F2:     /* address %fp@(-8) */
    lea %fp@(-8),%a1
    movew %sp@+,%a1@
    movel %sp@+,%a1@-
    movel %sp@+,%a1@-
    pea %a1@
    pea %a4@
    movew #2,%sp@-
    jsr %a3@
    tstw %d2
    jbne rsrc_PACK_5_D6A_110
    bchg #7,%a4@
    rts
rsrc_PACK_5_D6A_110:    /* from here: pea %pc@(rsrc_PACK_5_1032) */
    pea %pc@(rsrc_PACK_5_1032)
    pea %a4@
    clrw %sp@-
    jsr %a3@
    rts

/* subroutine (44 instructions): low memory FPState (mechanical summary) */
rsrc_PACK_5_E86:
    movew %a4@,%d1	| 408E8E46
    jbmi rsrc_PACK_5_D6A_17E	| 408E8E48
    movel %a4@(2),%d2	| 408E8E4A
    bpls rsrc_PACK_5_D6A_17E
    movel %a4@(6),%d0
    jbne rsrc_PACK_5_D6A_17E
    movel #16414,%d0
    subw %d1,%d0
    jble rsrc_PACK_5_D6A_17E
    cmpiw #31,%d0
    jbgt rsrc_PACK_5_D6A_17E
    bfins %d2,%d1,0,%d0
    jbne rsrc_PACK_5_D6A_17E
    lsrl %d0,%d2
    mulul #16807,%d1,%d2
    divul #2147483647,%d1,%d2
    bfffo %d1,0,0,%d2
    movew #16414,%d0
    lsll %d2,%d1
    subw %d2,%d0
    tstb %d3
    jbpl rsrc_PACK_5_D6A_168
    movew %d0,%a4@(-2)
rsrc_PACK_5_D6A_168:    /* set %a4@+ */
    movew %d0,%a4@+
    movel %d1,%a4@+
    clrl %a4@
    movew %fp@(-2),FPState
    moveml %sp@+,%d0-%a4
    unlk %fp
    addaw %sp@,%sp
    rts
rsrc_PACK_5_D6A_17E:    /* from here: pea %pc@(rsrc_PACK_5_1046) */
    pea %pc@(rsrc_PACK_5_1046)
    pea %a4@
    movew #4,%sp@-
    jsr %a3@
    pea %pc@(rsrc_PACK_5_1050)
    pea %a4@
    movew #12,%sp@-
    jsr %a3@
    tstb %a4@
    jbpl rsrc_PACK_5_D6A_1A4
    pea %pc@(rsrc_PACK_5_1050)
    pea %a4@
    clrw %sp@-
    jsr %a3@
rsrc_PACK_5_D6A_1A4:    /* continue at rsrc_PACK_5_4FE */
    jbra rsrc_PACK_5_4FE
rsrc_PACK_5_F12:        /* (data) */
    .short  0x0005, 0x3FF6, 0xB946, 0x46AF, 0xF6CE, 0x3BFF, 0x3FF9	| 408E8ED2
    .long   0x94F43221, 0x4D61FBEB, 0x3FFBDC97, 0x8903D944	| 408E8EE0
    .long   0x78933FFF, 0x9F9E3946, 0x57CA1D05, 0xC001CD6B	| 408E8EF0
    .long   0xC53A46EC, 0xDC9A4001, 0xB48397E7, 0xBAE6FCE0	| 408E8F00
rsrc_PACK_5_F50:        /* (data) */
    .long   0x00023FFF, 0x80000000, 0x00000000, 0xC000B818	| 408E8F10
    .long   0x35C3CE0A, 0x5E1D3FFF, 0xFA3EDF0E, 0xDDF41A96	| 408E8F20
rsrc_PACK_5_F70:        /* (data) */
    .long   0x0003BFEE, 0xFF8890C8, 0x1B209B79, 0x3FF9DA5C	| 408E8F30
    .long   0x84EFB813, 0x272F4003, 0x97D3BAEA, 0xF80FFD45	| 408E8F40
    .short  0x4009, 0xAB86, 0x71A1, 0x95BE, 0xFF0C	| 408E8F50
rsrc_PACK_5_F9A:        /* (data) */
    .short  0x0002, 0x3FFF, 0x8000	| 408E8F5A
    .long   0x00000000, 0x00004006, 0xD5487002, 0x984B5AB4	| 408E8F60
    .short  0x400A, 0xF775, 0x612E, 0x96B7, 0x0780	| 408E8F70

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_FBA:
    .short  0x3FFF, 0x8000, 0x0000	| 408E8F7A
    .long   0x00000000	| 408E8F80

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_FC4:
    .short  0xBFFF, 0x8000, 0x0000, 0x0000, 0x0000	| 408E8F84
rsrc_PACK_5_FCE:        /* (data) */
    .short  0x0000	| 408E8F8E
    .long   0x00000000, 0x00000000	| 408E8F90
rsrc_PACK_5_FD8:        /* (data) */
    .long   0x80000000, 0x00000000	| 408E8F98
    .short  0x0000	| 408E8FA0

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_FE2:
    .short  0x4000, 0x8000, 0x0000, 0x0000, 0x0000	| 408E8FA2
rsrc_PACK_5_FEC:        /* (data) */
    .long   0x7FFF0000	| 408E8FAC
    .short  0x0000, 0x0000, 0x0000	| 408E8FB0
rsrc_PACK_5_FF6:        /* (data) */
    .short  0xFFFF, 0x0000, 0x0000, 0x0000	| 408E8FB6
rsrc_PACK_5_FFE:        /* (number, not a label difference (was rsrc_PACK_4_40) */
    .long   0x00004000 /* number, not a label difference (was rsrc_PACK_4_408E9A20_359E-.) */	| 408E8FBE
    .short  0xC000, 0x0000, 0x0000, 0x0000	| 408E8FC2

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_100A:
    .short  0x3FFD, 0x8000, 0x0000	| 408E8FCA
    .short  0x0000	| 408E8FD0
rsrc_PACK_5_1012:       /* (number, not an address (F2)) */
    .long   0x00003FFE /* number, not an address (F2) */	| 408E8FD2
    .short  0x8000, 0x0000, 0x0000, 0x0000	| 408E8FD6

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_101E:
    .short  0x3FFE	| 408E8FDE
    .short  0xC000, 0x0000, 0x0000	| 408E8FE0
rsrc_PACK_5_1026:       /* (number, not an address (F2)) */
    .long   0x00003FFE /* number, not an address (F2) */	| 408E8FE6
    .short  0xE000, 0x0000, 0x0000	| 408E8FEA
    .short  0x0000	| 408E8FF0

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_1032:
    .short  0x3FFF, 0xC90F, 0xDAA2, 0x2168, 0xC235, 0x3FFE, 0xC90F	| 408E8FF2
    .short  0xDAA2, 0x2168, 0xC235	| 408E9000

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_1046:
    .short  0x400D, 0x834E, 0x0000, 0x0000, 0x0000	| 408E9006

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_1050:
    .short  0x401D, 0xFFFF, 0xFFFE, 0x0000, 0x0000	| 408E9010

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_105A:
    .short  0x3FFF, 0xB504, 0xF333	| 408E901A
    .byte   0xF9, 0xDE, 0x64, 0x84	| 408E9020

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_1064:
    .byte   0x3F, 0xFE, 0xB5, 0x04, 0xF3, 0x33, 0xF9, 0xDE, 0x64, 0x84, 0x40, 0x00	| 408E9024
    .long   0xADF85458, 0xA2BB4A9B	| 408E9030

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_1078:
    .long   0x3FFEB172, 0x17F7D1CF	| 408E9038
    .short  0x79AC	| 408E9040

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_1082:
    .short  0x3FFE, 0x93CD, 0x3A2C, 0x8198, 0xE26A	| 408E9042

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_108C:
    .long   0x3FFADC2A	| 408E904C
    .short  0x86B1, 0x5FDB, 0x6462	| 408E9050

/* subroutine (0 instructions) (mechanical summary) */
rsrc_PACK_5_1096:
    .short  0x3FFD, 0x8930, 0xA2F4, 0xF66A, 0xB18A	| 408E9056
rsrc_PACK_5_10A0:       /* (data) */
    .long   0x00033FFF, 0x80000000, 0x00000000, 0x400788D8	| 408E9060
    .long   0xB844A6A8, 0x5A30400E, 0x8A158A49, 0x09792320	| 408E9070
    .long   0x4013FAA9, 0xFE26FE63, 0xF22B0003, 0xBFFEC250	| 408E9080
    .long   0x86AE43F5, 0xCBF54006, 0x9E76EC66, 0xBEE76BA2	| 408E9090
    .long   0xC00CAF51, 0xA1D6C4C4, 0xAA014011, 0xA71BFEC4	| 408E90A0
    .long   0xA997F6CE	| 408E90B0
rsrc_PACK_5_10F4:       /* (data) */
    .long   0x00033FFF, 0x80000000, 0x00000000	| 408E90B4
    .long   0x4007A6D9, 0x6A95FBDF, 0x9685400E, 0xC7A7EA65	| 408E90C0
    .long   0xE85D156B, 0x4014D26E, 0x871C7B17, 0x52B20003	| 408E90D0
    .long   0xBFFBD57E, 0x18D7A6F6, 0xD7584003, 0xE364937E	| 408E90E0
    .long   0x32B3D072, 0xC00AA62D, 0x4056586B, 0xC0454010	| 408E90F0
    .long   0x8C49AF68, 0x520F8C7A	| 408E9100
rsrc_PACK_5_1148:       /* (data) */
    .long   0x0003BFFF, 0x80000000	| 408E9108
    .long   0x00000000, 0x4005B513, 0x032483C0, 0x0955C009	| 408E9110
    .long   0xD1FFB242, 0x5762E0CF, 0x400AE190, 0x93099376	| 408E9120
    .long   0x66AB0003, 0xBFE9B1FC, 0x3363D79B, 0x28383FFD	| 408E9130
    .long   0xAA9D71D8, 0x3EC74CD1, 0xC003E9CD, 0x8E24B965	| 408E9140
    .long   0x7DBB4007, 0xF09A3670, 0x9D4B1836	| 408E9150
rsrc_PACK_5_119C:       /* (data) */
    .long   0x00043FFF	| 408E915C
    .long   0x98D31EAE, 0x2AFA5DAD, 0x40038F79, 0x4CD8B3CD	| 408E9160
    .long   0xEFD94005, 0x8E37ED85, 0x70B8B368, 0x4005CDA4	| 408E9170
    .long   0xBEA1AC59, 0xF3B84004, 0xC4059C55, 0x4CF0C656	| 408E9180
    .long   0x00043FFF, 0x80000000, 0x00000000, 0x4002A23B	| 408E9190
    .long   0x6C131F92, 0x0E304003, 0xC3C8593D, 0xFA3A486F	| 408E91A0
    .short  0x4003, 0x82AE, 0x6838, 0xDDF5, 0xD945	| 408E91B0
    .fill   0x836, 1, 0x00
