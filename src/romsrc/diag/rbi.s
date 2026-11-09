/*
 diag/rbi.s - RBI manager, PRAM copy, memory sizing
 From RBIMGR (0x4084A7F4). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. These are the start-up and factory diagnostic tests (many run before RAM is usable, with return addresses in registers). Routine headers name the job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* RBIMGR: RAM-based (PRAM/clock) primitives without RAM: RBI manager. */
RBIMGR:
    lea %pc@(RBIMGR_8),%fp	| 4084A7F4
    jmp %pc@(COPYPRAMTORAM_54)	| 4084A7F8
RBIMGR_8:               /* (data) */
    .byte   0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x12, 0xBE, 0x66, 0x00, 0x04, 0x42, 0x3E, 0x3C, 0x00, 0x03	| 4084A7FC
    .byte   0x2E, 0x57, 0x28, 0x4F, 0x20, 0x5C, 0xB0, 0xFC, 0xFF, 0xFF, 0x67, 0x1C, 0x22, 0x5C, 0xD3, 0xC8	| 4084A80C
    .byte   0xBF, 0xC9, 0x62, 0x02, 0x22, 0x4F, 0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0xCF, 0xB0, 0x4A, 0x86	| 4084A81C
    .byte   0x66, 0x00, 0x04, 0x1A, 0x52, 0x47, 0x60, 0xDC, 0x42, 0x47, 0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA	| 4084A82C
    .byte   0xCD, 0x8C, 0x22, 0x6D, 0x00, 0x96, 0x92, 0xFC, 0x01, 0x3E	| 4084A83C
    jbsr COPYPRAMTORAM_2C
    moveal %a5@(34),%a0
    moveal %a5@(38),%a1
    moveal %a0@(8),%a2
    moveml %a0-%a2,%a5@(460)
    jbsr COPYPRAMTORAM_AA
    moveml %a5@(460),%a0-%a2
    jbsr RBIMGR_4E0
    movel %a5,%sp@-
    lea %pc@(RBIMGR_80),%fp
    jmp %pc@(CLKWPOFF)
RBIMGR_80:              /* set %d3 */
    movel #8126716,%d3
    lea %pc@(RBIMGR_8E),%fp
    jmp %pc@(READPRAMSIG)
RBIMGR_8E:              /* set %a5 */
    moveal %sp@+,%a5
    cmpil #1380074057,%d4
    jbeq RBIMGR_A0
    clrw %sp@-
    movew #128,%sp@-
    jbra RBIMGR_BC
RBIMGR_A0:              /* set %d1 */
    movel #8126716,%d1
    swap %d1
    moveq #0,%d2
    movel %a5,%sp@-
    lea %pc@(RBIMGR_B4),%fp
    jmp %pc@(WRXBYTE)
RBIMGR_B4:              /* set %a5 */
    moveal %sp@+,%a5
    movew #128,%sp@-
    clrw %sp@-
RBIMGR_BC:              /* set %sp@- */
    movew #128,%sp@-
    jbsr RBIMGR_4B2
    lea %sp@(6),%sp
    jbsr RBIMGR_45C
    movel %a3,%sp@-
    movew #230,%sp@-
    pea %a5@(154)
    movew #2,%sp@-
    lea %pc@(RBIMGR_EC),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
RBIMGR_EC:              /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    addqw #1,%a5@(154)
    movel %a3,%sp@-
    pea %a5@(154)
    movew #230,%sp@-
    movew #2,%sp@-
    lea %pc@(RBIMGR_116),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
RBIMGR_116:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    jbsr RBIMGR_472
    movel %a3,%sp@-
    movew #242,%sp@-
    pea %a5@(430)
    movew #2,%sp@-
    lea %pc@(RBIMGR_140),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
RBIMGR_140:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    movew #244,%sp@-
    pea %a5@(432)
    movew #4,%sp@-
    lea %pc@(RBIMGR_166),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
RBIMGR_166:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    movew #208,%sp@-
    pea %a5@(436)
    movew #4,%sp@-
    lea %pc@(RBIMGR_18C),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
RBIMGR_18C:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    movew #232,%sp@-
    pea %a5@(440)
    movew #2,%sp@-
    lea %pc@(RBIMGR_1B2),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
RBIMGR_1B2:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    movew #234,%sp@-
    pea %a5@(442)
    movew #2,%sp@-
    lea %pc@(RBIMGR_1D8),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
RBIMGR_1D8:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    movew #224,%sp@-
    pea %a5@(444)
    movew #2,%sp@-
    lea %pc@(RBIMGR_1FE),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
RBIMGR_1FE:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    movew #226,%sp@-
    pea %a5@(446)
    movew #2,%sp@-
    lea %pc@(RBIMGR_224),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
RBIMGR_224:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    movew #128,%sp@-
    pea %a5@(164)
    movew #32,%sp@-
    lea %pc@(RBIMGR_24A),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
RBIMGR_24A:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movew %a5@(440),%d1
    subw %d1,%a5@(430)
RBIMGR_258:             /* loop: clr */
    clrw %a5@(162)
    subqw #1,%a5@(430)
    jbmi RBIMGR_3C8
    addqw #1,%a5@(440)
    movel %a5@(432),%d0
    moveq #31,%d1
RBIMGR_26E:             /* loop: tst */
    tstl %d0
    jbeq RBIMGR_364
    asll #1,%d0
    jbcc RBIMGR_35E
    movew %d1,%d7
    oriw #192,%d7
    moveb #0xa4,%d3
    andiw #15,%d3
    addw %d3,%d1
    moveb %a5@(0x0,%d1:w),%d2
    andiw #255,%d2
    moveq #0,%d5
    bset %d1,%d5
    movel %d5,%a5@(158)
    andil #-536870912,%d5
    jbne RBIMGR_310
    cmpw %a5@(428),%d1
    jbge RBIMGR_35E
    movew %d1,%a5@(154)
    aslw #3,%d1
    addil #196,%d1
    movel %a5@(0x0,%d1:w),%a5@(448)
    movel %a5@(0x4,%d1:w),%a5@(452)
    movew %a5@(154),%d1
    moveml %d0-%d1/%a0/%a5,%sp@-
    lea %pc@(RBIMGR_2D8),%fp
    bigjmp SETUPFOREXECUTEDTM
RBIMGR_2D8:             /* (data) */
    moveml %sp@,%d0-%d1/%a0/%a5	| 4084AACC
    moveal %a5@(22),%a3	| 4084AAD0
RBIMGR_2E0:             /* save registers */
    moveml %d1-%d2/%a3,%sp@-
    pea %a5@(122)
    pea %a5@(102)
    pea %a5@(82)
    pea %a5@(46)
    pea %a3@
    bigjsr GI_ExecuteDTM
    addaw #20,%sp
    moveml %sp@+,%d1-%d2/%a3
    movel %d0,%d6
    dbne %d2,RBIMGR_2E0
    jbra RBIMGR_342
RBIMGR_310:             /* set %a5@(448) */
    movel %d1,%a5@(448)
    movel #1,%a5@(452)
    lea %pc@(COPYPRAMTORAM_21E),%a0
    movew #31,%d5
    subw %d1,%d5
    movel %a0@(0x0,%d5:w:4),%d5
    lea %a0@(0x0,%d5:l),%a0
    moveml %d0-%d1/%a0/%a5,%sp@-
RBIMGR_332:             /* save registers */
    moveml %d2/%a0,%sp@-
    jsr %a0@
    moveml %sp@+,%d2/%a0
    tstl %d6
    dbne %d2,RBIMGR_332
RBIMGR_342:             /* set %d0-%d1/%a0/%a5 */
    moveml %sp@,%d0-%d1/%a0/%a5
    moveml %a5@(460),%a0-%a2
    jbsr RBIMGR_4E0
    movel %d6,%a5@(456)
    jbeq RBIMGR_35A
    jbsr COPYPRAMTORAM_112
RBIMGR_35A:             /* restore registers */
    moveml %sp@+,%d0-%d1/%a0/%a5
RBIMGR_35E:             /* subtract 1 to %d1 */
    subqw #1,%d1
    jbra RBIMGR_26E
RBIMGR_364:             /* call RBIMGR_45C */
    jbsr RBIMGR_45C
    movel %a3,%sp@-
    pea %a5@(440)
    movew #232,%sp@-
    movew #2,%sp@-
    lea %pc@(RBIMGR_388),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
RBIMGR_388:             /* (data) */
    lea %sp@(8),%sp	| 4084AB7C
    moveal %sp@+,%a3	| 4084AB80
    tstw %a5@(162)	| 4084AB82
    bnew RBIMGR_3C0	| 4084AB86
    addqw #1,%a5@(442)	| 4084AB8A
    movel %a3,%sp@-	| 4084AB8E
    pea %a5@(442)	| 4084AB90
    movew #234,%sp@-	| 4084AB94
    movew #2,%sp@-	| 4084AB98
    lea %pc@(RBIMGR_3BA),%a3	| 4084AB9C
    movel %a3,%sp@-	| 4084ABA0
RBIMGR_3AE:             /* (4084ABA2 lea 0x19c,%a3) */
    lea 0x19c:l,%a3	| 4084ABA2
    lea %pc@(RBIMGR_3AE,%a3:l),%a3	| 4084ABA8
    jmp %a3@	| 4084ABAC
RBIMGR_3BA:             /* (data) */
    .byte   0x4F, 0xEF, 0x00, 0x08, 0x26, 0x5F	| 4084ABAE
RBIMGR_3C0:             /* call RBIMGR_472 */
    jbsr RBIMGR_472	| 4084ABB4
    jbra RBIMGR_258	| 4084ABB8
RBIMGR_3C8:             /* clear %d7 */
    clrw %d7
    jbsr RBIMGR_45C
    movel %a3,%sp@-
    pea %pc@(CLKWPOFF_9E0)
    movew #236,%sp@-
    movew #4,%sp@-
    lea %pc@(RBIMGR_3EE),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
RBIMGR_3EE:             /* (data) */
    lea %sp@(8),%sp	| 4084ABE2
    moveal %sp@+,%a3	| 4084ABE6
    bsrw RBIMGR_472	| 4084ABE8
    tstl %a5@(436)	| 4084ABEC
    jbne RBIMGR_454	| 4084ABF0
    movel %a3,%sp@-	| 4084ABF2
    movew #240,%sp@-	| 4084ABF4
    pea %a5@(154)	| 4084ABF8
    movew #1,%sp@-	| 4084ABFC
    lea %pc@(RBIMGR_41E),%a3	| 4084AC00
    movel %a3,%sp@-	| 4084AC04
RBIMGR_412:             /* (4084AC06 lea 0x164,%a3) */
    lea 0x164:l,%a3	| 4084AC06
    lea %pc@(RBIMGR_412,%a3:l),%a3	| 4084AC0C
    jmp %a3@	| 4084AC10
RBIMGR_41E:             /* (data) */
    .byte   0x4F, 0xEF, 0x00, 0x08, 0x26, 0x5F, 0x4A, 0x2D, 0x00, 0x9A, 0x66, 0x2A	| 4084AC12
    jbsr RBIMGR_502
    moveq #0,%d2
RBIMGR_430:             /* loop: move */
    movew #500,%d0
RBIMGR_434:             /* loop: move */
    movew #800,%d1
RBIMGR_438:             /* loop: tst */
    tstb %a2@
    dbf %d1,RBIMGR_438
    dbf %d0,RBIMGR_434
    eorib #1,%d2
    jbeq RBIMGR_44E
    jbsr RBIMGR_4E0
    jbra RBIMGR_430
RBIMGR_44E:             /* call RBIMGR_502 */
    jbsr RBIMGR_502
    jbra RBIMGR_430
RBIMGR_454:             /* call RBIMGR_502 */
    jbsr RBIMGR_502	| 4084AC48
    jbra ERROR1HANDLER	| 4084AC4C

RBIMGR_45C:             /* loop: move */
    movel %a5,%sp@-
    movel #8126716,%d1
    moveq #0,%d2
    lea %pc@(RBIMGR_46E),%fp
    jmp %pc@(WRXBYTE)
RBIMGR_46E:             /* string "*_Nu" */
    .ascii  "*_Nu"
RBIMGR_472:             /* (data) */
    movel %a5,%sp@-	| 4084AC66
    movel #8126716,%d1	| 4084AC68
    movel #1380074057,%d2	| 4084AC6E
    roll #8,%d2	| 4084AC74
    lea %pc@(RBIMGR_48A),%fp	| 4084AC76
    jmp %pc@(WRXBYTE)	| 4084AC7A
RBIMGR_48A:             /* set %d1 */
    movel #8126716,%d1	| 4084AC7E
    swap %d1	| 4084AC84
    moveq #0,%d2	| 4084AC86
    lea %pc@(RBIMGR_49C),%fp	| 4084AC88
    jmp %pc@(WRXBYTE)	| 4084AC8C
RBIMGR_49C:             /* (data) */
    .byte   0x3F, 0x3C, 0x00, 0x80, 0x42, 0x67, 0x3F, 0x3C, 0x00, 0x80, 0x61, 0x00, 0x00, 0x0A, 0x4F, 0xEF	| 4084AC90
    .byte   0x00, 0x06, 0x2A, 0x5F, 0x4E, 0x75	| 4084ACA0

RBIMGR_4B2:             /* set %sp@- */
    movel %a5,%sp@-
RBIMGR_4B4:             /* loop: move */
    movew %sp@(12),%d1
    lea %pc@(RBIMGR_4C0),%fp
    jmp %pc@(RDXBYTE)
RBIMGR_4C0:             /* set %d2 */
    moveb %d1,%d2
    movew %sp@(10),%d1
    lea %pc@(RBIMGR_4CE),%fp
    jmp %pc@(WRXBYTE)
RBIMGR_4CE:             /* (data) */
    addqw #1,%sp@(12)	| 4084ACC2
    addqw #1,%sp@(10)	| 4084ACC6
    subqw #1,%sp@(8)	| 4084ACCA
    jbne RBIMGR_4B4	| 4084ACCE
    moveal %sp@+,%a5	| 4084ACD0
    rts	| 4084ACD2

RBIMGR_4E0:             /* set %d0 */
    movel %a5@(42),%d0
    btst #8,%d0
    jbeq RBIMGR_4F6
    moveal %a0@(32),%a3
    bset #3,%a3@(16)
    rts
RBIMGR_4F6:             /* call RBIMGR_524 */
    bsrw RBIMGR_524
    moveb #34,%a3@(48)
    rts

RBIMGR_502:             /* set %d0 */
    movel %a5@(42),%d0
    btst #8,%d0
    jbeq RBIMGR_518
    moveal %a0@(32),%a3
    bclr #3,%a3@(16)
    rts
RBIMGR_518:             /* call RBIMGR_524 */
    bsrw RBIMGR_524
    moveb #27,%a3@(48)
    rts

RBIMGR_524:             /* set %a3 */
    moveal %a0@(96),%a3
    btst #25,%d0
    jbeq RBIMGR_532
    moveal %a0@(100),%a3
RBIMGR_532:             /* set %a3@(48) */
    moveb #2,%a3@(48)
    clrb %a3@(48)
    moveb #8,%a3@(128)
    moveb #1,%a3@(160)
    rts

/* COPYRAMTOPRAM: copy memory to PRAM. */
COPYRAMTOPRAM:
    movew %sp@(6),%d1
    moveal %sp@(8),%a3
    movew %sp@(4),%d3
    moveq #0,%d2
    subqw #1,%d3
    jblt COPYRAMTOPRAM_2A
COPYRAMTOPRAM_12:       /* loop: move */
    moveb %a3@+,%d2
    moveml %d1/%d3/%a3/%a5,%sp@-
    lea %pc@(COPYRAMTOPRAM_20),%fp
    jmp %pc@(WRXBYTE)
COPYRAMTOPRAM_20:       /* (data) */
    moveml %sp@+,%d1/%d3/%a3/%a5	| 4084AD5E
    addqw #1,%d1	| 4084AD62
    dbf %d3,COPYRAMTOPRAM_12	| 4084AD64
COPYRAMTOPRAM_2A:       /* return */
    rts

/* COPYPRAMTORAM: copy PRAM to memory. */
COPYPRAMTORAM:
    movew %sp@(10),%d2
    moveal %sp@(6),%a3
    movew %sp@(4),%d3
    subqw #1,%d3
    jblt COPYPRAMTORAM_2A
COPYPRAMTORAM_10:       /* loop: move */
    movew %d2,%d1
    moveml %d2-%d3/%a3/%a5,%sp@-
    lea %pc@(COPYPRAMTORAM_1E),%fp
    jmp %pc@(RDXBYTE)
COPYPRAMTORAM_1E:       /* (data) */
    moveml %sp@+,%d2-%d3/%a3/%a5	| 4084AD88
    moveb %d1,%a3@+	| 4084AD8C
    addqw #1,%d2	| 4084AD8E
    dbf %d3,COPYPRAMTORAM_10	| 4084AD90
COPYPRAMTORAM_2A:       /* return */
    rts

COPYPRAMTORAM_2C:       /* address %a5@(154) */
    lea %a5@(154),%a0
    movel %a0,%d0
    subl %sp,%d0
    movel %d0,%d1
    moveal %a1,%a2
    lsrl #2,%d0
    addql #1,%d0
COPYPRAMTORAM_3C:       /* loop: move */
    movel %a0@-,%a1@-
    dbf %d0,COPYPRAMTORAM_3C
    moveal %a2,%a0
    subal %d1,%a0
    moveal %a0,%sp
    addql #4,%a0
    movec %a0,%vbr
    lea %a2@(-154),%a5
    rts
COPYPRAMTORAM_54:       /* from here: subl %d0,%d0 */
    subl %d0,%d0	| 4084ADBE
    bset #31,%d0	| 4084ADC0
    movec %d0,%cacr	| 4084ADC4
    movec %cacr,%d0	| 4084ADC8
    btst #31,%d0	| 4084ADCC
    jbeq COPYPRAMTORAM_8A	| 4084ADD0
    .short  0xF4D8	| 4084ADD2 cinva bc
    subl %d0,%d0	| 4084ADD4
    movec %d0,%cacr	| 4084ADD6
    movec %d0,%tc	| 4084ADDA
    movel #16760896,%d0	| 4084ADDE
    movec %d0,%dtt0	| 4084ADE4
    movel #16760896,%d0	| 4084ADE8
    movec %d0,%dtt1	| 4084ADEE
    jbra COPYPRAMTORAM_A4	| 4084ADF2
COPYPRAMTORAM_8A:       /* set %d0 */
    movel #8192,%d0	| 4084ADF4
    movec %d0,%cacr	| 4084ADFA
    movec %cacr,%d0	| 4084ADFE
    tstl %d0	| 4084AE02
    jbeq COPYPRAMTORAM_A4	| 4084AE04
    lea %pc@(COPYPRAMTORAM_A6),%a0	| 4084AE06
    .short  0xF010, 0x4000	| 4084AE0A pmove %a0@,%tc
COPYPRAMTORAM_A4:       /* jump through %fp@ */
    jmp %fp@	| 4084AE0E
COPYPRAMTORAM_A6:       /* (data) */
    .byte   0x00, 0x00, 0x00, 0x00	| 4084AE10

COPYPRAMTORAM_AA:       /* set %a1 */
    moveal %sp@+,%a1
    subal #55296,%sp
    movel %sp,%a5@(22)
    moveal %sp,%a0
    movel %a1,%sp@-
    movew #16,%a5@(8)
    movel #55296,%sp@-
    pea %a0@
    bigjsr GI_InitInterface
    addql #8,%sp
    moveal %a5@(18),%a0
    lea %a5@(196),%a1
    clrw %a5@(428)
COPYPRAMTORAM_E0:       /* loop: moveq */
    moveq #0,%d0
    movew %a0@(2),%d0
    cmpiw #-1,%d0
    jbeq COPYPRAMTORAM_110
    movew %a0@(4),%d1
    andw %a5@(8),%d1
    jbeq COPYPRAMTORAM_10A
    moveq #0,%d1
    movew %a0@,%d1
    movel %d1,%a1@+
    movel %d0,%a1@+
    addqw #1,%a5@(428)
    cmpiw #29,%a5@(428)
    jbeq COPYPRAMTORAM_110
COPYPRAMTORAM_10A:      /* address %a0@(10) */
    lea %a0@(10),%a0
    jbra COPYPRAMTORAM_E0
COPYPRAMTORAM_110:      /* return */
    rts

COPYPRAMTORAM_112:      /* call RBIMGR_45C */
    jbsr RBIMGR_45C
    addqw #1,%a5@(162)
    movew %a5@(440),%a5@(446)
    movel %a3,%sp@-
    pea %a5@(446)
    movew #226,%sp@-
    movew #2,%sp@-
    lea %pc@(COPYPRAMTORAM_140),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
COPYPRAMTORAM_140:      /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    pea %a5@(448)
    movew #212,%sp@-
    movew #4,%sp@-
    lea %pc@(COPYPRAMTORAM_166),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
COPYPRAMTORAM_166:      /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    pea %a5@(452)
    movew #216,%sp@-
    movew #4,%sp@-
    lea %pc@(COPYPRAMTORAM_18C),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
COPYPRAMTORAM_18C:      /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    movel %a3,%sp@-
    pea %a5@(456)
    movew #220,%sp@-
    movew #4,%sp@-
    lea %pc@(COPYPRAMTORAM_1B2),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
COPYPRAMTORAM_1B2:      /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    tstw %a5@(444)
    jbne COPYPRAMTORAM_1EA
    movew %a5@(440),%a5@(444)
    movel %a3,%sp@-
    pea %a5@(444)
    movew #224,%sp@-
    movew #2,%sp@-
    lea %pc@(COPYPRAMTORAM_1E4),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
COPYPRAMTORAM_1E4:      /* (data) */
    lea %sp@(8),%sp	| 4084AF4E
    moveal %sp@+,%a3	| 4084AF52
COPYPRAMTORAM_1EA:      /* set %d2 */
    movel %a5@(158),%d2
    orl %d2,%a5@(436)
    movel %a3,%sp@-
    pea %a5@(436)
    movew #208,%sp@-
    movew #4,%sp@-
    lea %pc@(COPYPRAMTORAM_212),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
COPYPRAMTORAM_212:      /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    jbsr RBIMGR_472
    rts
COPYPRAMTORAM_21E:      /* from here: orib #16,%d0 */
    orib #16,%d0
    orib #80,%d0
    orib #0xe0,%d0
    orib #0,%d0
    moveq #0,%d6
    movel #1,%a5@(452)
    movel %a5,%sp@-
    lea %pc@(COPYPRAMTORAM_242),%fp
    jmp %pc@(ROMTEST)
COPYPRAMTORAM_242:      /* set %a5 */
    moveal %sp@+,%a5
    tstl %d6
    jbne COPYPRAMTORAM_268
    movel #2,%a5@(452)
    movel %a5,%sp@-
    lea %pc@(COPYPRAMTORAM_25A),%fp
    jmp %pc@(STARTUPROMTEST)
COPYPRAMTORAM_25A:      /* (data) */
    moveal %sp@+,%a5	| 4084AFC4
    tstl %d6	| 4084AFC6
    jbne COPYPRAMTORAM_266	| 4084AFC8
    clrl %a5@(456)	| 4084AFCA
    jbra COPYPRAMTORAM_268	| 4084AFCE
COPYPRAMTORAM_266:      /* set %d6 */
    movel %d1,%d6	| 4084AFD0
COPYPRAMTORAM_268:      /* set %a5@(456) */
    movel %d6,%a5@(456)
    rts
    moveq #0,%d6
    moveal %a5@(150),%a3
    moveal %a3@+,%a0
    cmpaw #-1,%a0
    jbeq COPYPRAMTORAM_2CA
    moveal %a3@+,%a1
    addal %a0,%a1
    cmpal %a1,%sp
    jbhi COPYPRAMTORAM_28C
    movel %sp,%d0
    andib #0xfc,%d0
    moveal %d0,%a1
COPYPRAMTORAM_28C:      /* set %a5@(452) */
    movel #1,%a5@(452)
COPYPRAMTORAM_294:      /* address %pc@(COPYPRAMTORAM_29C) */
    lea %pc@(COPYPRAMTORAM_29C),%fp
    jmp %pc@(caseD_2)
COPYPRAMTORAM_29C:      /* (data) */
    tstl %d6	| 4084B006
    jbne COPYPRAMTORAM_2EA	| 4084B008
    movel #2,%a5@(452)	| 4084B00A
    lea %pc@(COPYPRAMTORAM_2B0),%fp	| 4084B012
    jmp %pc@(REVMOD3TEST)	| 4084B016
COPYPRAMTORAM_2B0:      /* (data) */
    .byte   0x4A, 0x86, 0x66, 0x36, 0x2B, 0x7C, 0x00, 0x00, 0x00, 0x03, 0x01, 0xC4, 0x4D, 0xFA, 0x00, 0x06	| 4084B01A
    .byte   0x4E, 0xFA, 0xCA, 0x58, 0x4A, 0x86, 0x66, 0x22, 0x60, 0xAA	| 4084B02A
COPYPRAMTORAM_2CA:      /* set %a0 */
    moveal %a5@(150),%a0
    moveal %a0@,%a0
    lea %a0@(256),%a0
    movel #4,%a5@(452)
    lea %pc@(COPYPRAMTORAM_2E4),%fp
    jmp %pc@(DATABUSTEST)
COPYPRAMTORAM_2E4:      /* set %a5@(456) */
    movel %d6,%a5@(456)
    rts
COPYPRAMTORAM_2EA:      /* loop: movea */
    moveal %a5@(150),%a1
    subal %a1,%a3
    movel %a3,%d0
    lsll #1,%d0
    orl %d0,%a5@(452)
    movel %d6,%a5@(456)
    rts
    .long   0x2F0D7C00, 0x2B7C0000	| 4084B068
    .short  0x0001, 0x01C4	| orib #0xc4,%d1
    moveal %a5@(150),%a3
COPYPRAMTORAM_30E:      /* loop: movea */
    moveal %a3@+,%a0
    cmpaw #-1,%a0
    jbeq COPYPRAMTORAM_33A
    moveal %a3@+,%a1
    movel %a3,%sp@-
    addal %a0,%a1
    cmpal %a1,%sp
    jbhi COPYPRAMTORAM_328
    movel %sp,%d0
    andib #0xfc,%d0
    moveal %d0,%a1
COPYPRAMTORAM_328:      /* address %pc@(COPYPRAMTORAM_330) */
    lea %pc@(COPYPRAMTORAM_330),%fp
    jmp %pc@(MOVINVTEST)
COPYPRAMTORAM_330:      /* (data) */
    moveal %sp@+,%a3	| 4084B09A
    tstl %d6
    jbeq COPYPRAMTORAM_30E
    moveal %sp@+,%a5
    jbra COPYPRAMTORAM_2EA
COPYPRAMTORAM_33A:      /* set %a5 */
    moveal %sp@+,%a5
    movel %d6,%a5@(456)
    rts

/* WRXBYTE: write an extended PRAM byte (no RAM: registers only). */
WRXBYTE:
    moveal %a1,%a3
    addal %a3@(52),%a3
    movel %a3@(16),%d0
    jbeq WRXBYTE_10
    addal %d0,%a3
    exg %fp,%a3
WRXBYTE_10:             /* jump through %fp@ */
    jmp %fp@

/* RDXBYTE: read an extended PRAM byte (no RAM). */
RDXBYTE:
    moveal %a1,%a3
    addal %a3@(52),%a3
    movel %a3@(12),%d0
    jbeq RDXBYTE_10
    addal %d0,%a3
    exg %fp,%a3
RDXBYTE_10:             /* jump through %fp@ */
    jmp %fp@

/* CLKWPOFF: turn off the clock chip's write protection. */
CLKWPOFF:
    moveal %a1,%a5
    addal %a5@(52),%a5
    movel %a5@(4),%d0
    jbeq CLKWPOFF_10
    addal %d0,%a5
    exg %fp,%a5
CLKWPOFF_10:            /* jump through %fp@ */
    jmp %fp@
    .fill   0x9CE, 1, 0x00
CLKWPOFF_9E0:           /* (data) */
    .long   0x444F4E45, 0x00000000, 0x00000000, 0x00000000	| 4084BAB0

/* SIZEMEMORY: size the RAM banks (start-up tests). */
thunk_FUN_408a0000:
SIZEMEMORY:
    jbra VSCDECLROM
    .fill   0x42A, 1, 0x00
