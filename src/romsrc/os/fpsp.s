/*
 os/fpsp.s - 68040 floating-point software package (FPSP)
 From INSTALLFPSP (0x4088D200). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Labels fpsp_*: routine names of Motorola's M68040 Software Package (FPSP; Copyright (c)
 1993, 1994 Motorola Inc., distributed with permission to use, modify and redistribute,
 e.g. in Linux arch/m68k/fpsp040). Matched by code: the first six instructions of each
 routine, with branch targets and displacements ignored, occur once in this ROM.
 Apple's copy is an earlier release, so some routines differ and are not named.

 Routine headers summarise what the Motorola FPSP routines do (their names are
 Motorola's, see above); labels inside them are commented mechanically from the
 instruction that follows. Constant tables (fpsp_*TBL, polynomial coefficients such
 as fpsp_SINA1..5, fpsp_LOG2, fpsp_PI) are extended precision constants.
*/

/* INSTALLFPSP: install the FPSP exception handlers (unimplemented instruction, unsupported data type, BSUN, SNAN, OPERR, OVFL, UNFL, INEX, DZ) in the vector table. */
INSTALLFPSP:
    movec %vbr,%a0
    movel %a0@(44),0x1fc8
    lea %pc@(INSTALLFPSP_7FE),%a1
    movel %a1,%a0@(44)
    lea %pc@(fpsp_bsun),%a1
    movel %a1,%a0@(192)
    lea %pc@(fpsp_snan_1C8),%a1
    movel %a1,%a0@(204)
    lea %pc@(fpsp_operr),%a1
    movel %a1,%a0@(208)
    lea %pc@(fpsp_ovfl),%a1
    movel %a1,%a0@(212)
    lea %pc@(fpsp_snan),%a1
    movel %a1,%a0@(216)
    lea %pc@(fpsp_unsupp),%a1
    movel %a1,%a0@(220)
    rts
INSTALLFPSP_44:         /* (data) */
    .long   0xF27F0000	| 4088D244

INSTALLFPSP_48:         /* loop: subq */
    subql #1,%d0
INSTALLFPSP_4A:         /* loop: move */
    moveb %a0@+,%a1@+
    dbf %d0,INSTALLFPSP_4A
    rts

/* fpsp_bsun: branch/set on unordered exception handler. */
fpsp_bsun:
    linkw %fp,#-192
    fsave %sp@-
    moveml %d0-%d1/%a0-%a1,%fp@(-192)
    fmovemx %fp0-%fp3,%fp@(-176)
    fmoveml %fpiar/%fpsr/%fpcr,%fp@(-128)
    movel %fp@(6),%fp@(-120)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0x1fcc,%sp@-
    rts

/* fpsp_operr: operand error exception handler (fix up the result for integer stores). */
fpsp_operr:
    linkw %fp,#-192
    fsave %sp@-
    moveml %d0-%d1/%a0-%a1,%fp@(-192)
    fmovemx %fp0-%fp3,%fp@(-176)
    fmoveml %fpiar/%fpsr/%fpcr,%fp@(-128)
    btst #4,%fp@(-219)
    jbeq fpsp_operr_end
    movel %fp@(-228),%d0
    bfextu %d0,3,3,%d0
    cmpib #0,%d0
    jbeq fpsp_operr_end_28
    cmpib #4,%d0
    jbeq fpsp_operr_end_B4
    cmpib #6,%d0
    jbeq fpsp_operr_end_102
fpsp_operr_end:         /* set bit 5 of %fp@(-122) */
    bset #5,%fp@(-122)
    bset #7,%fp@(-121)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0x1fd4,%sp@-
    rts
fpsp_operr_end_28:      /* set %d1 */
    moveq #4,%d1
    moveb %fp@(-232),%d0
    andib #0xe0,%d0
    cmpib #96,%d0
    jbeq fpsp_operr_end_14C
    cmpil #-2147483648,%fp@(-208)
    jbne fpsp_operr_end_5A
    jbsr fpsp_operr_end_1E0
    tstl %d0
    jbne fpsp_operr_end_5A
    movel #-2147483648,%d0
    jbsr fpsp_operr_end_194
    jbra fpsp_operr_end_226
fpsp_operr_end_5A:      /* set %d0 */
    movew %fp@(-216),%d0
    andiw #32767,%d0
    cmpiw #16382,%d0
    jbne fpsp_operr_end_74
fpsp_operr_end_68:      /* loop: move */
    movel %fp@(-208),%d0
    jbsr fpsp_operr_end_194
    jbra fpsp_operr_end_226
fpsp_operr_end_74:      /* set %d0 */
    movew %fp@(-216),%d0
    andiw #32767,%d0
    cmpiw #16384,%d0
    jbcc fpsp_operr_end_15E
    movel %fp@(-208),%d0
    andil #2147418112,%d0
    cmpil #2147418112,%d0
    jbeq fpsp_operr_end_68
    tstl %fp@(-208)
    jbpl fpsp_operr_end_AA
    cmpil #-1,%fp@(-212)
    jbeq fpsp_operr_end_68
    jbra fpsp_operr_end_15E
fpsp_operr_end_AA:      /* test %fp@(-212) */
    tstl %fp@(-212)
    jbeq fpsp_operr_end_68
    jbra fpsp_operr_end_15E
fpsp_operr_end_B4:      /* set %d1 */
    moveq #2,%d1
    moveb %fp@(-232),%d0
    andib #0xe0,%d0
    cmpib #96,%d0
    jbeq fpsp_operr_end_14C
    cmpil #-32768,%fp@(-208)
    jbne fpsp_operr_end_E6
    jbsr fpsp_operr_end_1E0
    tstl %d0
    jbne fpsp_operr_end_E6
    movel #-2147483648,%d0
    jbsr fpsp_operr_end_194
    jbra fpsp_operr_end_226
fpsp_operr_end_E6:      /* set %d0 */
    movew %fp@(-216),%d0
    andiw #32767,%d0
    cmpiw #16382,%d0
    jbne fpsp_operr_end_15E
    movel %fp@(-208),%d0
    swap %d0
    jbsr fpsp_operr_end_194
    jbra fpsp_operr_end_226
fpsp_operr_end_102:     /* set %d1 */
    moveq #1,%d1
    moveb %fp@(-232),%d0
    andib #0xe0,%d0
    cmpib #96,%d0
    jbeq fpsp_operr_end_14C
    cmpil #-128,%fp@(-208)
    jbne fpsp_operr_end_130
    jbsr fpsp_operr_end_1E0
    tstl %d0
    jbne fpsp_operr_end_130
    movel #-2147483648,%d0
    jbsr fpsp_operr_end_194
    jbra fpsp_operr_end_226
fpsp_operr_end_130:     /* set %d0 */
    movew %fp@(-216),%d0
    andiw #32767,%d0
    cmpiw #16382,%d0
    jbne fpsp_operr_end_15E
    movel %fp@(-208),%d0
    asll #8,%d0
    swap %d0
    jbsr fpsp_operr_end_194
    jbra fpsp_operr_end_226
fpsp_operr_end_14C:     /* from here: oril #8320,%fp@(-124) */
    oril #8320,%fp@(-124)
    movel %fp@(-200),%d0
    jbsr fpsp_operr_end_194
    jbra fpsp_operr_end_202
fpsp_operr_end_15E:     /* from here: oril #8320,%fp@(-124) */
    oril #8320,%fp@(-124)
    bclr #1,%fp@(-122)
    bclr #3,%fp@(-121)
    fmovel #0,%fpsr
    tstw %fp@(-216)
    jblt fpsp_operr_end_18A
    movel #2147483647,%d0
    jbsr fpsp_operr_end_194
    jbra fpsp_operr_end_202
fpsp_operr_end_18A:     /* set %d0 */
    movel #-2147483648,%d0
    jbsr fpsp_operr_end_194
    jbra fpsp_operr_end_202

fpsp_operr_end_194:     /* set %fp@(-84) */
    movel %d0,%fp@(-84)
    moveal %fp@(-120),%a0
    subl %d0,%d0
    movew %a0@,%d0
    bftst %d0,26,3
    jbne INSTALLFPSP_29A
    andil #7,%d0
    cmpil #4,%d1
    jbeq INSTALLFPSP_28E
    cmpil #2,%d1
    jbne INSTALLFPSP_294
    oril #8,%d0
    jbra INSTALLFPSP_294
INSTALLFPSP_28E:        /* from here: oril #16,%d0 */
    oril #16,%d0
INSTALLFPSP_294:        /* set %d1 */
    movel %d0,%d1
    jbra fpsp_neg_sign_298
INSTALLFPSP_29A:        /* address %fp@(-84) */
    lea %fp@(-84),%a0
    moveal %fp@(12),%a1
    movel %d1,%d0
    jbsr INSTALLFPSP_48
    rts

fpsp_operr_end_1E0:     /* test #-1,%fp@(-212) */
    cmpil #-1,%fp@(-212)
    jbne INSTALLFPSP_2C4
    cmpiw #-16384,%fp@(-216)
    jbeq INSTALLFPSP_2C8
    cmpiw #-16385,%fp@(-216)
    jbeq INSTALLFPSP_2C8
INSTALLFPSP_2C4:        /* result 1 */
    moveq #1,%d0
    rts
INSTALLFPSP_2C8:        /* result 0 */
    moveq #0,%d0
    rts

fpsp_operr_end_202:     /* test bit 5 of %fp@(-126) */
    btst #5,%fp@(-126)
    jbeq fpsp_operr_end_226
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0x1fd4,%sp@-
    rts

fpsp_operr_end_226:     /* set %d0 */
    moveb %fp@(-126),%d0
    andb %fp@(-122),%d0
    andib #3,%d0
    jbeq INSTALLFPSP_32E

/* fpsp_take_inex: take the inexact exception after the operation. */
fpsp_take_inex:
    moveb #0xc4,%fp@(11)
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0xc4,%sp@-
    rts
INSTALLFPSP_32E:        /* restore registers */
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    unlk %fp
    rte

/* fpsp_ovfl: overflow exception handler. */
fpsp_ovfl:
    linkw %fp,#-192
    fsave %sp@-
    moveml %d0-%d1/%a0-%a1,%fp@(-192)
    fmovemx %fp0-%fp3,%fp@(-176)
    fmoveml %fpiar/%fpsr/%fpcr,%fp@(-128)
    bset #3,%fp@(-121)
    jbsr fpsp_ovfl_10A
    btst #4,%fp@(-126)
    jbeq fpsp_ovfl_6A
    btst #1,%fp@(-220)
    jbeq fpsp_ovfl_4E
    bfextu %fp@(-240),6,3,%d0
    bclr %d0,%fp@(-283)
    jbsr fpsp_is_fp2_18
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
fpsp_ovfl_4E:           /* restore registers */
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0x1fd8,%sp@-
    rts
fpsp_ovfl_6A:           /* test bit 1 of %fp@(-126) */
    btst #1,%fp@(-126)
    jbeq fpsp_ovfl_B8
    btst #1,%fp@(-220)
    jbeq fpsp_ovfl_96
    bfextu %fp@(-240),6,3,%d0
    bclr %d0,%fp@(-283)
    jbsr fpsp_is_fp2_18
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
fpsp_ovfl_96:           /* set %fp@(11) */
    moveb #0xc4,%fp@(11)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0xc4,%sp@-
    rts
fpsp_ovfl_B8:           /* clear bit 1 of %fp@(-220) */
    bclr #1,%fp@(-220)
    jbeq fpsp_ovfl_F4
    bfextu %fp@(-240),6,3,%d0
    bclr %d0,%fp@(-283)
    jbsr fpsp_is_fp2_18
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    rte
fpsp_ovfl_F4:           /* restore registers */
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    unlk %fp
    rte

fpsp_ovfl_10A:          /* test bit 1 of %fp@(-220) */
    btst #1,%fp@(-220)
    jbeq INSTALLFPSP_45C
    lea %fp@(-268),%a0
    jbra INSTALLFPSP_460
INSTALLFPSP_45C:        /* address %fp@(-204) */
    lea %fp@(-204),%a0
INSTALLFPSP_460:        /* clear bit 7 of %a0@ */
    bclr #7,%a0@
    sne %a0@(2)
    jbsr fpsp_neg_sign_74
    cmpiw #3,%d0
    jbne INSTALLFPSP_486
    moveb %fp@(-124),%fp@(-84)
    jbsr fpsp_sec_d_11A
    moveb %fp@(-84),%fp@(-124)
    jbra fpsp_pwrten_98
INSTALLFPSP_486:        /* call fpsp_sec_d_BE */
    jbsr fpsp_sec_d_BE
    jbra fpsp_pwrten_98

/* fpsp_snan: signalling NaN exception handler. */
fpsp_snan:
    linkw %fp,#-192
    fsave %sp@-
    moveml %d0-%d1/%a0-%a1,%fp@(-192)
    fmovemx %fp0-%fp3,%fp@(-176)
    fmoveml %fpiar/%fpsr/%fpcr,%fp@(-128)
    btst #6,%fp@(-126)
    jbne INSTALLFPSP_4E2
    jbsr fpsp_snan_FC
    moveb %fp@(-126),%d0
    andb %fp@(-122),%d0
    andib #3,%d0
    jbeq INSTALLFPSP_53C
    moveb #0xc4,%fp@(11)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0xc4,%sp@-
    rts
INSTALLFPSP_4E2:        /* test bit 5 of %fp@(-228) */
    btst #5,%fp@(-228)
    jbeq INSTALLFPSP_624
    jbsr fpsp_snan_FC
INSTALLFPSP_4F0:        /* loop: move */
    moveb %sp@,%fp@(-69)
    cmpib #64,%sp@
    jbne INSTALLFPSP_4FE
    moveq #13,%d0
    jbra INSTALLFPSP_500
INSTALLFPSP_4FE:        /* set %d0 */
    moveq #11,%d0
INSTALLFPSP_500:        /* clear %sp@ */
    clrl %sp@
INSTALLFPSP_502:        /* loop: clr */
    clrl %sp@-
    dbf %d0,INSTALLFPSP_502
    moveb %fp@(-69),%sp@
    moveb #96,%sp@(1)
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0x1fdc,%sp@-
    rts
INSTALLFPSP_53C:        /* clear bit 2 of %fp@(-220) */
    bclr #2,%fp@(-220)
    moveb %sp@,%fp@(-69)
    cmpib #64,%sp@
    jbne INSTALLFPSP_550
    moveq #13,%d0
    jbra INSTALLFPSP_552
INSTALLFPSP_550:        /* set %d0 */
    moveq #11,%d0
INSTALLFPSP_552:        /* clear %sp@ */
    clrl %sp@
INSTALLFPSP_554:        /* loop: clr */
    clrl %sp@-
    dbf %d0,INSTALLFPSP_554
    moveb %fp@(-69),%sp@
    moveb #96,%sp@(1)
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    rte

fpsp_snan_FC:           /* set %a0 */
    moveal %fp@(12),%a0
    bfextu %fp@(-228),3,3,%d0
    cmpil #0,%d0
    jbeq INSTALLFPSP_5AE
    cmpil #4,%d0
    jbeq INSTALLFPSP_5C0
    cmpil #6,%d0
    jbeq INSTALLFPSP_5D6
    rts
INSTALLFPSP_5AE:        /* set %d1 */
    movel %fp@(-200),%d1
    moveq #4,%d0
    bset #30,%d1
    tstl %a0
    jbeq INSTALLFPSP_5EC
    movel %d1,%a0@
    rts
INSTALLFPSP_5C0:        /* set %d1 */
    movel %fp@(-200),%d1
    moveq #2,%d0
    bset #30,%d1
    tstl %a0
    jbeq INSTALLFPSP_5EC
    swap %d1
    movew %d1,%a0@
    swap %d1
    rts
INSTALLFPSP_5D6:        /* set %d1 */
    movel %fp@(-200),%d1
    moveq #1,%d0
    bset #30,%d1
    tstl %a0
    jbeq INSTALLFPSP_5EC
    roll #8,%d1
    moveb %d1,%a0@
    rorl #8,%d1
    rts
INSTALLFPSP_5EC:        /* set %fp@(-84) */
    movel %d1,%fp@(-84)
    moveal %fp@(-120),%a0
    movew %a0@,%d1
    andil #7,%d1
    cmpil #4,%d0
    jbeq INSTALLFPSP_616
    cmpil #2,%d0
    jbne INSTALLFPSP_620
    oril #8,%d1
    jbra fpsp_neg_sign_298
INSTALLFPSP_616:        /* from here: oril #16,%d1 */
    oril #16,%d1
    jbra fpsp_neg_sign_298
INSTALLFPSP_620:        /* continue at fpsp_neg_sign_298 */
    jbra fpsp_neg_sign_298
INSTALLFPSP_624:        /* set %d0 */
    movel %fp@(-224),%d0
    bfextu %d0,0,3,%d0
    cmpib #3,%d0
    jbne INSTALLFPSP_638
    movew %fp@(-216),%d0
    jbra INSTALLFPSP_63C
INSTALLFPSP_638:        /* set %d0 */
    movew %fp@(-204),%d0
INSTALLFPSP_63C:        /* test bit 15 of %d0 */
    btst #15,%d0
    jbeq INSTALLFPSP_64C
    bset #3,%fp@(-124)
    jbra INSTALLFPSP_4F0
INSTALLFPSP_64C:        /* clear bit 3 of %fp@(-124) */
    bclr #3,%fp@(-124)
    jbra INSTALLFPSP_4F0

fpsp_snan_1C8:          /* from here: linkw %fp,#-192 */
    linkw %fp,#-192
    fsave %sp@-
    moveml %d0-%d1/%a0-%a1,%fp@(-192)
    fmovemx %fp0-%fp3,%fp@(-176)
    fmoveml %fpiar/%fpsr/%fpcr,%fp@(-128)
    jbsr fpsp_snan_2D2
    btst #3,%fp@(-126)
    jbeq INSTALLFPSP_6BA
    btst #1,%fp@(-220)
    jbeq INSTALLFPSP_69E
    bfextu %fp@(-240),6,3,%d0
    bclr %d0,%fp@(-283)
    jbsr fpsp_is_fp2_18
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
INSTALLFPSP_69E:        /* restore registers */
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0x1fd0,%sp@-
    rts
INSTALLFPSP_6BA:        /* set %d0 */
    moveb %fp@(-126),%d0
    andb %fp@(-122),%d0
    andib #3,%d0
    jbeq INSTALLFPSP_70E
    btst #1,%fp@(-220)
    jbeq INSTALLFPSP_6EC
    bfextu %fp@(-240),6,3,%d0
    bclr %d0,%fp@(-283)
    jbsr fpsp_is_fp2_18
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
INSTALLFPSP_6EC:        /* set %fp@(11) */
    moveb #0xc4,%fp@(11)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    movel 0xc4,%sp@-
    rts
INSTALLFPSP_70E:        /* clear bit 1 of %fp@(-220) */
    bclr #1,%fp@(-220)
    jbeq INSTALLFPSP_74A
    bfextu %fp@(-240),6,3,%d0
    bclr %d0,%fp@(-283)
    jbsr fpsp_is_fp2_18
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    unlk %fp
    rte
INSTALLFPSP_74A:        /* restore registers */
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    unlk %fp
    rte

fpsp_snan_2D2:          /* call fpsp_neg_sign_18 */
    jbsr fpsp_neg_sign_18
    clrw %sp@-
    movew %d0,%sp@-
    btst #1,%fp@(-220)
    jbeq INSTALLFPSP_790
    lea %fp@(-268),%a0
    movew %fp@(-240),%d1
    andiw #127,%d1
    cmpiw #48,%d1
    jbeq INSTALLFPSP_788
    cmpiw #51,%d1
    jbne INSTALLFPSP_794
INSTALLFPSP_788:        /* clear %d0 */
    moveq #0,%d0
    movew #1,%sp@
    jbra INSTALLFPSP_794
INSTALLFPSP_790:        /* address %fp@(-216) */
    lea %fp@(-216),%a0
INSTALLFPSP_794:        /* clear bit 7 of %a0@ */
    bclr #7,%a0@
    sne %a0@(2)
    jbsr fpsp_lower_20
    bfextu %fp@(-125),2,2,%d1
    addl %sp@+,%d1
    jbsr fpsp_dp_over_152
    jbsr fpsp_neg_sign_74
    cmpib #3,%d0
    jbne INSTALLFPSP_7CC
    jbsr fpsp_neg_sign_8A
    tstb %d0
    jbeq INSTALLFPSP_7C6
    tstb %a0@(4)
    jbmi INSTALLFPSP_7C6
    subqw #1,%a0@
INSTALLFPSP_7C6:        /* call fpsp_pwrten_98 */
    jbsr fpsp_pwrten_98
    jbra INSTALLFPSP_7EE
INSTALLFPSP_7CC:        /* call fpsp_pwrten_98 */
    jbsr fpsp_pwrten_98
    tstl %a0@(4)
    jbne INSTALLFPSP_7E2
    tstl %a0@(8)
    jbne INSTALLFPSP_7E2
    bset #2,%fp@(-124)
INSTALLFPSP_7E2:        /* test bit 7 of %a0@ */
    btst #7,%a0@
    jbeq INSTALLFPSP_7EE
    bset #3,%fp@(-124)
INSTALLFPSP_7EE:        /* test bit 1 of %fp@(-122) */
    btst #1,%fp@(-122)
    jbeq INSTALLFPSP_7FC
    bset #5,%fp@(-121)
INSTALLFPSP_7FC:        /* return */
    rts
INSTALLFPSP_7FE:        /* test #8236,%sp@(6) */
    cmpiw #8236,%sp@(6)
    jbeq fpsp_unimp
    subql #4,%sp
    linkw %fp,#-192
    fsave %sp@-
    moveml %d0-%d1/%a0-%a1,%fp@(-192)
    moveal %fp@(10),%a0
    movel %a0@,%d0
    bfextu %d0,4,3,%d1
    cmpib #1,%d1
    jbne fpsp_fix_con_3A
    bfextu %d0,16,6,%d1
    cmpib #23,%d1
    jbne fpsp_fix_con_3A
    cmpib #64,%sp@
    jbne INSTALLFPSP_84A
    subaw #40,%sp
    moveb #64,%sp@
    moveb #40,%sp@(1)
    clrw %sp@(2)
    jbra fpsp_fix_con
INSTALLFPSP_84A:        /* test #65,%sp@ */
    cmpib #65,%sp@
    jbne INSTALLFPSP_44
    subaw #48,%sp
    moveb #65,%sp@
    moveb #48,%sp@(1)
    clrw %sp@(2)
fpsp_fix_con:           /* set %fp@(4) */
    movew %fp@(8),%fp@(4)
    movel %fp@(10),%fp@(6)
    fmovel %fp@(6),%fpiar
    moveq #4,%d1
    addl %d1,%fp@(6)
    movew #8236,%fp@(10)
    clrl %fp@(12)
    movew %d0,%fp@(-228)
    clrl %fp@(-220)
    bset #5,%fp@(-219)
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    jbra fpsp_uni_2
fpsp_fix_con_3A:        /* restore registers, return */
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    frestore %sp@+
    unlk %fp
    addql #4,%sp
    movel 0x1fc8,%sp@-
    rts

/* fpsp_unsupp: unsupported data type exception (denormalised or unnormalised operands, packed decimal): emulate the instruction. */
fpsp_unsupp:
    linkw %fp,#-192
    fsave %sp@-
    moveml %d0-%d1/%a0-%a1,%fp@(-192)
    fmovemx %fp0-%fp3,%fp@(-176)
    fmoveml %fpiar/%fpsr/%fpcr,%fp@(-128)
    moveb %sp@,%fp@(-69)
    moveb %sp@,%d0
    andib #0xf0,%d0
    cmpib #64,%d0
    jbne INSTALLFPSP_44
    fmovel #0,%fpsr
    fmovel #0,%fpcr
    movel %fp@(-124),%d1
    btst #5,%fp@(-228)
    jbne INSTALLFPSP_8FE
    andil #16711935,%d1
    jbra INSTALLFPSP_904
INSTALLFPSP_8FE:        /* from here: andil #268386559,%d1 */
    andil #268386559,%d1
INSTALLFPSP_904:        /* set %fp@(-124) */
    movel %d1,%fp@(-124)
    st %fp@(-71)
    jbsr GENEXCEPTPATCHRTN_42
    jbsr fpsp_dp_bnds_8
    clrl %sp@-
    moveb %fp@(-69),%sp@
    jbra fpsp_is_fp2_2B4

/* fpsp_unimp: unimplemented floating point instruction (transcendental functions): decode and emulate it. */
fpsp_unimp:
    linkw %fp,#-192
    fsave %sp@-
fpsp_uni_2:             /* set %fp@(-192) */
    moveml %d0-%d1/%a0-%a1,%fp@(-192)
    fmovemx %fp0-%fp3,%fp@(-176)
    fmoveml %fpiar/%fpsr/%fpcr,%fp@(-128)
    moveb %sp@,%d0
    andib #0xf0,%d0
    cmpib #64,%d0
    jbne INSTALLFPSP_44
    movel %fp@(-124),%d0
    andil #16711935,%d0
    movel %d0,%fp@(-124)
    fmovel #0,%fpsr
    fmovel #0,%fpcr
    clrb %fp@(-71)
    jbsr GENEXCEPTPATCHRTN_42
    clrb %fp@(-76)
    jbsr fpsp_end_avun_3C4
    fsave %sp@-
    tstb %fp@(-76)
    jbne fpsp_uni_2_58
    jbsr fpsp_unimp_62
fpsp_uni_2_58:          /* continue at fpsp_is_fp2_2B4 */
    jbra fpsp_is_fp2_2B4

fpsp_unimp_62:          /* from here: bfextu %fp@(-228),6,3,%d0 */
    bfextu %fp@(-228),6,3,%d0
    cmpib #3,%d0
    jble INSTALLFPSP_99E
    fmovemx %fp0,%sp@-
    moveq #7,%d1
    subl %d0,%d1
    moveq #0,%d0
    bset %d1,%d0
    fmovemx %sp@+,%d0
    rts
INSTALLFPSP_99E:        /* test #0,%d0 */
    cmpib #0,%d0
    jbeq fpsp_is_fp2_10
    cmpib #1,%d0
    jbeq fpsp_is_fp2_8
    cmpib #2,%d0
    jbeq fpsp_is_fp2
fpsp_is_fp3:            /* from here: fmovemx %fp0,%fp@(-140) */
    fmovemx %fp0,%fp@(-140)
    rts
fpsp_is_fp2:            /* from here: fmovemx %fp0,%fp@(-152) */
    fmovemx %fp0,%fp@(-152)
    rts
fpsp_is_fp2_8:          /* from here: fmovemx %fp0,%fp@(-164) */
    fmovemx %fp0,%fp@(-164)
    rts
fpsp_is_fp2_10:         /* from here: fmovemx %fp0,%fp@(-176) */
    fmovemx %fp0,%fp@(-176)
    rts

fpsp_is_fp2_18:         /* test #64,%sp@(4) */
    cmpib #64,%sp@(4)
    jbne INSTALLFPSP_C58
    moveb %fp@(-284),%d0
    andib #0xfe,%d0
    jbeq INSTALLFPSP_C58
    movew %fp@(-228),%d0
    andiw #-8192,%d0
    jbne INSTALLFPSP_B2A
    bfextu %fp@(-228),3,3,%d0
    bfextu %fp@(-240),6,3,%d1
    cmpb %d0,%d1
    jbeq INSTALLFPSP_A24
    bfextu %fp@(-228),6,3,%d0
    cmpb %d0,%d1
    jbeq INSTALLFPSP_A24
    bfextu %fp@(-244),6,3,%d1
    cmpb %d0,%d1
    jbeq INSTALLFPSP_A5E
    bfextu %fp@(-228),3,3,%d0
    cmpb %d0,%d1
    jbeq INSTALLFPSP_A5E
    jbne INSTALLFPSP_C58
INSTALLFPSP_A24:        /* from here: bfextu %fp@(-228),3,3,%d0 */
    bfextu %fp@(-228),3,3,%d0
    moveq #7,%d1
    subl %d0,%d1
    moveq #0,%d0
    bset %d1,%d0
    fmovemx %d0,%fp@(-204)
    moveb #18,%d0
    bfins %d0,%fp@(-228),0,6
    btst #6,%fp@(-204)
    jbeq INSTALLFPSP_A54
    bclr #4,%fp@(-232)
    jbra INSTALLFPSP_C58
INSTALLFPSP_A54:        /* set bit 4 of %fp@(-232) */
    bset #4,%fp@(-232)
    jbra INSTALLFPSP_C58
INSTALLFPSP_A5E:        /* set %fp@(-84) */
    movel %fp@(-232),%fp@(-84)
    movel %fp@(-228),%fp@(-80)
    movel %fp@(-224),%fp@(-68)
    andil #-536870912,%fp@(-68)
    clrb %fp@(-284)
    movel %sp@+,%d1
    frestore %sp@+
    fsave %sp@-
    cmpiw #16480,%sp@
    jbeq INSTALLFPSP_B26
    bfextu %fp@(-244),6,3,%d0
    cmpil #3,%d0
    jbgt INSTALLFPSP_AC2
    jbeq INSTALLFPSP_ABC
    cmpil #1,%d0
    jblt INSTALLFPSP_AB4
    jbeq INSTALLFPSP_AAC
    fmovemx %fp2,%fp@(-152)
    jbra INSTALLFPSP_AC2
INSTALLFPSP_AAC:        /* from here: fmovemx %fp1,%fp@(-164) */
    fmovemx %fp1,%fp@(-164)
    jbra INSTALLFPSP_AC2
INSTALLFPSP_AB4:        /* from here: fmovemx %fp0,%fp@(-176) */
    fmovemx %fp0,%fp@(-176)
    jbra INSTALLFPSP_AC2
INSTALLFPSP_ABC:        /* from here: fmovemx %fp3,%fp@(-140) */
    fmovemx %fp3,%fp@(-140)
INSTALLFPSP_AC2:        /* set %d0 */
    moveq #22,%d0
    clrl %sp@
INSTALLFPSP_AC6:        /* loop: clr */
    clrl %sp@-
    dbf %d0,INSTALLFPSP_AC6
    movel #1080033280,%sp@-
    movel %fp@(-84),%fp@(-232)
    movel %fp@(-80),%fp@(-228)
    movel %fp@(-68),%fp@(-224)
    moveb #6,%fp@(-284)
    movel %d1,%sp@-
    bfextu %fp@(-228),3,3,%d0
    moveq #7,%d1
    subl %d0,%d1
    moveq #0,%d0
    bset %d1,%d0
    fmovemx %d0,%fp@(-204)
    moveb #18,%d0
    bfins %d0,%fp@(-228),0,6
    btst #6,%fp@(-204)
    jbeq INSTALLFPSP_B1C
    bclr #4,%fp@(-232)
    jbra INSTALLFPSP_C58
INSTALLFPSP_B1C:        /* set bit 4 of %fp@(-232) */
    bset #4,%fp@(-232)
    jbra INSTALLFPSP_C58
INSTALLFPSP_B26:        /* jump through %pc@(INSTALLFPSP_44) */
    jmp %pc@(INSTALLFPSP_44)
INSTALLFPSP_B2A:        /* set %d0 */
    movew %fp@(-228),%d0
    andiw #-1024,%d0
    cmpiw #17408,%d0
    jbne INSTALLFPSP_C58
    bfextu %fp@(-228),6,3,%d0
    bfextu %fp@(-240),6,3,%d1
    cmpb %d0,%d1
    jbeq INSTALLFPSP_C0A
    bfextu %fp@(-244),6,3,%d1
    cmpb %d0,%d1
    jbne INSTALLFPSP_C58
    movel %fp@(-232),%fp@(-84)
    movel %fp@(-228),%fp@(-80)
    movel %fp@(-224),%fp@(-68)
    andil #-536870912,%fp@(-68)
    clrb %fp@(-284)
    movel %fp@(-204),%fp@(-100)
    movel %fp@(-200),%fp@(-96)
    movel %fp@(-196),%fp@(-92)
    movel %sp@+,%d1
    frestore %sp@+
    fsave %sp@-
    cmpiw #16480,%sp@
    jbeq INSTALLFPSP_C54
    bfextu %fp@(-244),6,3,%d0
    cmpil #3,%d0
    jbgt INSTALLFPSP_BCE
    jbeq INSTALLFPSP_BC8
    cmpil #1,%d0
    jblt INSTALLFPSP_BC0
    jbeq INSTALLFPSP_BB8
    fmovemx %fp2,%fp@(-152)
    jbra INSTALLFPSP_BCE
INSTALLFPSP_BB8:        /* from here: fmovemx %fp1,%fp@(-164) */
    fmovemx %fp1,%fp@(-164)
    jbra INSTALLFPSP_BCE
INSTALLFPSP_BC0:        /* from here: fmovemx %fp0,%fp@(-176) */
    fmovemx %fp0,%fp@(-176)
    jbra INSTALLFPSP_BCE
INSTALLFPSP_BC8:        /* from here: fmovemx %fp3,%fp@(-140) */
    fmovemx %fp3,%fp@(-140)
INSTALLFPSP_BCE:        /* set %d0 */
    moveq #22,%d0
    clrl %sp@
INSTALLFPSP_BD2:        /* loop: clr */
    clrl %sp@-
    dbf %d0,INSTALLFPSP_BD2
    movel #1080033280,%sp@-
    movel %fp@(-84),%fp@(-232)
    movel %fp@(-80),%fp@(-228)
    movel %fp@(-68),%fp@(-224)
    moveb #6,%fp@(-284)
    movel %fp@(-100),%fp@(-204)
    movel %fp@(-96),%fp@(-200)
    movel %fp@(-92),%fp@(-196)
    movel %d1,%sp@-
INSTALLFPSP_C0A:        /* set %d0 */
    moveb #21,%d0
    bfins %d0,%fp@(-228),0,6
    cmpiw #16511,%fp@(-204)
    jbne INSTALLFPSP_C24
    movew #17407,%fp@(-204)
    jbra INSTALLFPSP_C58
INSTALLFPSP_C24:        /* test #-16257,%fp@(-204) */
    cmpiw #-16257,%fp@(-204)
    jbne INSTALLFPSP_C34
    movew #-15361,%fp@(-204)
    jbra INSTALLFPSP_C58
INSTALLFPSP_C34:        /* test #16256,%fp@(-204) */
    cmpiw #16256,%fp@(-204)
    jbne INSTALLFPSP_C44
    movew #15360,%fp@(-204)
    jbra INSTALLFPSP_C58
INSTALLFPSP_C44:        /* test #-16512,%fp@(-204) */
    cmpiw #-16512,%fp@(-204)
    jbne INSTALLFPSP_C58
    movew #-17408,%fp@(-204)
    jbra INSTALLFPSP_C58
INSTALLFPSP_C54:        /* jump through %pc@(INSTALLFPSP_44) */
    jmp %pc@(INSTALLFPSP_44)
INSTALLFPSP_C58:        /* return */
    rts
fpsp_is_fp2_2A2:        /* (data) */
    .short  INSTALLFPSP_D5C-fpsp_is_fp2_2A2	| 4088DE5A
    .short  INSTALLFPSP_D60-fpsp_is_fp2_2A2	| 4088DE5C
    .short  INSTALLFPSP_D60-fpsp_is_fp2_2A2	| 4088DE5E
    .short  INSTALLFPSP_DD8-fpsp_is_fp2_2A2	| 4088DE60
    .short  INSTALLFPSP_DD8-fpsp_is_fp2_2A2	| 4088DE62
    .short  INSTALLFPSP_D60-fpsp_is_fp2_2A2	| 4088DE64
    .short  INSTALLFPSP_D68-fpsp_is_fp2_2A2	| 4088DE66
    .short  INSTALLFPSP_D68-fpsp_is_fp2_2A2	| 4088DE68
    .short  INSTALLFPSP_DA0-fpsp_is_fp2_2A2	| 4088DE6A
fpsp_is_fp2_2B4:        /* test #0,%sp@(1) */
    cmpib #0,%sp@(1)
    jbeq INSTALLFPSP_D16
    cmpib #40,%sp@(1)
    jbeq INSTALLFPSP_CE8
    cmpib #48,%sp@(1)
    jbeq INSTALLFPSP_CE8
    cmpib #96,%sp@(1)
    jbne INSTALLFPSP_44
    lea %sp@(292),%a1
    movel %fp@(-204),%a1@(-204)
    movel %fp@(-200),%a1@(-200)
    movel %fp@(-196),%a1@(-196)
    movel %fp@(-228),%a1@(-228)
    jbsr fpsp_is_fp2_314
    movel %d0,%a1@(-240)
    fmovel %fpsr,%d0
    orl %d0,%fp@(-124)
    movel %fp@(-124),%a1@(-256)
    oril #25165824,%a1@(-220)
    jbra fpsp_busy_fr_3A

fpsp_is_fp2_314:        /* loop: move */
    movel %fp@(-228),%d0
    andil #67043328,%d0
    bfextu %d0,10,4,%d1
    lsrb #1,%d1
    jbcc INSTALLFPSP_CE2
    bset #3,%d1
INSTALLFPSP_CE2:        /* from here: bfins %d1,%d0,10,4 */
    bfins %d1,%d0,10,4
    rts
INSTALLFPSP_CE8:        /* test #40,%sp@(1) */
    cmpib #40,%sp@(1)
    jbne INSTALLFPSP_CF6
    lea %sp@(236),%a1
    jbra INSTALLFPSP_D04
INSTALLFPSP_CF6:        /* test #48,%sp@(1) */
    cmpib #48,%sp@(1)
    jbne INSTALLFPSP_44
    lea %sp@(244),%a1
INSTALLFPSP_D04:        /* set %a1@(-228) */
    movel %fp@(-228),%a1@(-228)
    fmovel %fpsr,%d0
    orl %d0,%fp@(-124)
    jbra fpsp_busy_fr_3A
INSTALLFPSP_D16:        /* add 4 to %sp */
    addql #4,%sp
    fmovel %fpsr,%d0
    orl %d0,%fp@(-124)
    cmpib #96,%sp@(1)
    jbne INSTALLFPSP_D42
    clrw %fp@(-236)
    btst #5,%fp@(-228)
    jbne INSTALLFPSP_D42
    movel %fp@(-124),%fp@(-256)
    oril #25165824,%fp@(-220)
INSTALLFPSP_D42:        /* set %d0 */
    moveb %fp@(-126),%d0
    andb %fp@(-122),%d0
    bfffo %d0,24,8,%d1
    lea %pc@(fpsp_is_fp2_2A2),%a0
    subib #24,%d1
    addaw %a0@(0x0,%d1:w:2),%a0
    jmp %a0@
INSTALLFPSP_D5C:        /* continue at fpsp_busy_fr_3A */
    jbra fpsp_busy_fr_3A	| 4088DF5C
INSTALLFPSP_D60:        /* set bit 2 of %fp@(-220) */
    bset #2,%fp@(-220)	| 4088DF60
    jbra INSTALLFPSP_D96	| 4088DF66
INSTALLFPSP_D68:        /* test %fp@(-71) */
    tstb %fp@(-71)	| 4088DF68
    jbne INSTALLFPSP_D7C	| 4088DF6C
    bset #1,%fp@(-220)	| 4088DF6E
    bclr #2,%fp@(-220)	| 4088DF74
    jbra INSTALLFPSP_D96	| 4088DF7A
INSTALLFPSP_D7C:        /* loop: tst */
    tstb %fp@(-73)	| 4088DF7C
    jbne INSTALLFPSP_D88	| 4088DF80
    bset #1,%fp@(-220)	| 4088DF82
INSTALLFPSP_D88:        /* clear bit 2 of %fp@(-220) */
    bclr #2,%fp@(-220)	| 4088DF88
    jbsr fpsp_is_fp2_314	| 4088DF8E
    movel %d0,%fp@(-240)	| 4088DF92
INSTALLFPSP_D96:        /* clear bit 5 of %fp@(-219) */
    bclr #5,%fp@(-219)	| 4088DF96
    jbra fpsp_busy_fr_3A	| 4088DF9C
INSTALLFPSP_DA0:        /* test bit 1 of %fp@(-126) */
    btst #1,%fp@(-126)	| 4088DFA0
    jbeq INSTALLFPSP_DB2	| 4088DFA6
    btst #4,%fp@(-122)	| 4088DFA8
    jbeq INSTALLFPSP_DB2	| 4088DFAE
    jbra INSTALLFPSP_DD8	| 4088DFB0
INSTALLFPSP_DB2:        /* test %fp@(-71) */
    tstb %fp@(-71)	| 4088DFB2
    jbeq INSTALLFPSP_DC0	| 4088DFB6
    tstb %fp@(-73)	| 4088DFB8
    jbne fpsp_busy_fr_3A	| 4088DFBC
INSTALLFPSP_DC0:        /* restore registers */
    moveml %fp@(-192),%d0-%d1/%a0-%a1	| 4088DFC0
    fmovemx %fp@(-176),%fp0-%fp3	| 4088DFC6
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr	| 4088DFCC
    unlk %fp	| 4088DFD2
    jbra GENEXCEPTPATCHRTN_2	| 4088DFD4
INSTALLFPSP_DD8:        /* test %fp@(-71) */
    tstb %fp@(-71)	| 4088DFD8
    jbeq INSTALLFPSP_E0E	| 4088DFDC
    tstb %fp@(-70)	| 4088DFDE
    jbeq INSTALLFPSP_D7C	| 4088DFE2
    clrb %fp@(-284)	| 4088DFE4
    bset #2,%fp@(-220)	| 4088DFE8
    movew %fp@(-204),%fp@(-216)	| 4088DFEE
    movel %fp@(-200),%fp@(-212)	| 4088DFF4
    movel %fp@(-196),%fp@(-208)	| 4088DFFA
    bset #4,%fp@(-224)	| 4088E000
    bclr #5,%fp@(-219)	| 4088E006
    jbra fpsp_busy_fr_3A	| 4088E00C
INSTALLFPSP_E0E:        /* set %fp@(-69) */
    moveb %sp@,%fp@(-69)	| 4088E00E
    cmpib #96,%sp@(1)	| 4088E012
    jbeq fpsp_busy_fr	| 4088E018
    cmpib #64,%sp@	| 4088E01A
    jbne INSTALLFPSP_E24	| 4088E01E
    moveq #13,%d0	| 4088E020
    jbra INSTALLFPSP_E32	| 4088E022
INSTALLFPSP_E24:        /* test #65,%sp@ */
    cmpib #65,%sp@	| 4088E024
    jbne INSTALLFPSP_44	| 4088E028
    moveq #11,%d0	| 4088E02C
    clrw %fp@(-236)	| 4088E02E
INSTALLFPSP_E32:        /* clear %sp@ */
    clrl %sp@	| 4088E032
INSTALLFPSP_E34:        /* loop: clr */
    clrl %sp@-	| 4088E034
    dbf %d0,INSTALLFPSP_E34	| 4088E036
    moveb %fp@(-69),%sp@	| 4088E03A
    moveb #96,%sp@(1)	| 4088E03E
fpsp_busy_fr:           /* (data) */
    movel %fp@(-116),%fp@(-268)	| 4088E044
    movel %fp@(-112),%fp@(-264)	| 4088E04A
    movel %fp@(-108),%fp@(-260)	| 4088E050
    bset #1,%fp@(-220)	| 4088E056
    bclr #2,%fp@(-220)	| 4088E05C
    bclr #5,%fp@(-219)	| 4088E062
    movel %fp@(-124),%fp@(-256)	| 4088E068
    oril #25165824,%fp@(-220)	| 4088E06E
    jbsr fpsp_is_fp2_314	| 4088E076
    movel %d0,%fp@(-240)	| 4088E07A

fpsp_busy_fr_3A:        /* test #40,%sp@(1) */
    cmpib #40,%sp@(1)
    jbne INSTALLFPSP_E8A
    moveq #13,%d0
    jbra INSTALLFPSP_E98
INSTALLFPSP_E8A:        /* test #48,%sp@(1) */
    cmpib #48,%sp@(1)
    jbne INSTALLFPSP_EF0
    moveq #11,%d0
    clrw %fp@(-236)
INSTALLFPSP_E98:        /* set %fp@(-69) */
    moveb %sp@,%fp@(-69)
    clrl %sp@
INSTALLFPSP_E9E:        /* loop: clr */
    clrl %sp@-
    dbf %d0,INSTALLFPSP_E9E
    lea %sp@(292),%a1
    moveb %fp@(-69),%sp@
    moveb #96,%sp@(1)
    movel %fp@(-116),%a1@(-268)
    movel %fp@(-112),%a1@(-264)
    movel %fp@(-108),%a1@(-260)
    btst #2,%a1@(-220)
    jbne INSTALLFPSP_ED6
    jbsr fpsp_is_fp2_314
    movel %d0,%a1@(-240)
    jbra INSTALLFPSP_EF0
INSTALLFPSP_ED6:        /* from here: bfextu %fp@(-124),17,4,%d0 */
    bfextu %fp@(-124),17,4,%d0
    bfins %d0,%a1@(-235),4,4
    movel %fp@(-124),%a1@(-256)
    oril #25165824,%a1@(-220)
INSTALLFPSP_EF0:        /* restore registers */
    moveml %fp@(-192),%d0-%d1/%a0-%a1
    fmovemx %fp@(-176),%fp0-%fp3
    jbra FPSPPATCH
    .short  0x4E71	| 4088E102

/* GENEXCEPTPATCHRTN: return point of the general exception exit patch (hw/sonic.s FPSPPATCH). */
GENEXCEPTPATCHRTN:
    unlk %fp
GENEXCEPTPATCHRTN_2:    /* test bit 7 of %sp@ */
    btst #7,%sp@
    jbne GENEXCEPTPATCHRTN_10
    btst #6,%sp@
    jbne GENEXCEPTPATCHRTN_10
    rte
GENEXCEPTPATCHRTN_10:   /* from here: bftst %sp@(6),0,4 */
    bftst %sp@(6),0,4
    jbne GENEXCEPTPATCHRTN_36
    subqw #4,%sp
    movel %sp@(4),%sp@
    movel %sp@(8),%sp@(4)
    subaw #100,%sp
    fsave %sp@
    fmovel %fpiar,%sp@(108)
    frestore %sp@
    lea %sp@(100),%sp
GENEXCEPTPATCHRTN_36:   /* set %sp@(6) */
    movew #8228,%sp@(6)
    movel 0x24,%sp@-
    rts

GENEXCEPTPATCHRTN_42:   /* clear %fp@(-72) */
    clrb %fp@(-72)
    tstb %fp@(-71)
    jbeq GENEXCEPTPATCHRTN_80
    btst #5,%fp@(-228)
    jbne fpsp_pos_76
    btst #6,%fp@(-228)
    jbeq GENEXCEPTPATCHRTN_6C
    bfextu %fp@(-228),3,3,%d0
    cmpib #3,%d0
    jbeq fpsp_pos_24
GENEXCEPTPATCHRTN_6C:   /* call fpsp_pos_8A */
    jbsr fpsp_pos_8A
    tstb %fp@(-72)
    jbeq GENEXCEPTPATCHRTN_D0
    btst #7,%fp@(-224)
    jbeq GENEXCEPTPATCHRTN_D0
    jbra GENEXCEPTPATCHRTN_B8
GENEXCEPTPATCHRTN_80:   /* from here: bfextu %fp@(-228),0,6,%d0 */
    bfextu %fp@(-228),0,6,%d0
    cmpil #23,%d0
    jbne GENEXCEPTPATCHRTN_90
    rts
GENEXCEPTPATCHRTN_90:   /* test bit 2 of %fp@(-220) */
    btst #2,%fp@(-220)
    jbne fpsp_pos_24
    moveb %fp@(-232),%d0
    orb %fp@(-224),%d0
    jbmi GENEXCEPTPATCHRTN_A6
    rts
GENEXCEPTPATCHRTN_A6:   /* test bit 7 of %fp@(-224) */
    btst #7,%fp@(-224)
    jbeq GENEXCEPTPATCHRTN_D0
    jbsr fpsp_pos_8A
    tstb %fp@(-72)
    jbeq GENEXCEPTPATCHRTN_D0
GENEXCEPTPATCHRTN_B8:   /* loop: move */
    movew %fp@(-216),%d0
    andiw #32767,%d0
    jbeq GENEXCEPTPATCHRTN_D0
    lea %fp@(-216),%a0
    jbsr fpsp_set_dya_C
    moveb %fp@(-84),%fp@(-224)
GENEXCEPTPATCHRTN_D0:   /* test bit 7 of %fp@(-232) */
    btst #7,%fp@(-232)
    jbeq fpsp_pos_88
    btst #5,%fp@(-232)
    jbne GENEXCEPTPATCHRTN_FE
GENEXCEPTPATCHRTN_E2:   /* loop: move */
    movew %fp@(-204),%d0
    andiw #32767,%d0
    jbeq fpsp_pos_88
    lea %fp@(-204),%a0
    jbsr fpsp_set_dya_C
    moveb %fp@(-84),%fp@(-232)
    rts
GENEXCEPTPATCHRTN_FE:   /* test bit 4 of %fp@(-228) */
    btst #4,%fp@(-228)
    jbne GENEXCEPTPATCHRTN_10C
    movew #16257,%d1
    jbra GENEXCEPTPATCHRTN_110
GENEXCEPTPATCHRTN_10C:  /* set %d1 */
    movew #15361,%d1
GENEXCEPTPATCHRTN_110:  /* test bit 7 of %fp@(-204) */
    btst #7,%fp@(-204)
    jbeq fpsp_pos
    bset #15,%d1
fpsp_pos:               /* set %fp@(-204) */
    movew %d1,%fp@(-204)
    movew %fp@(-228),%d1
    andiw #-7169,%d1
    oriw #2048,%d1
    movew %d1,%fp@(-228)
    lea %fp@(-204),%a0
    jbsr fpsp_set_dya_C
    moveb %fp@(-84),%fp@(-232)
    rts
fpsp_pos_24:            /* set %fp@(-204) */
    movel %fp@(-208),%fp@(-204)
    jbsr fpsp_pos_8A
    jbsr fpsp_set_dya_44
    tstb %fp@(-72)
    jbeq fpsp_pos_88
    bfextu %fp@(-228),6,3,%d0
    moveq #7,%d1
    subl %d0,%d1
    moveq #0,%d0
    bset %d1,%d0
    fmovemx %d0,%fp@(-216)
    btst #7,%fp@(-224)
    jbne GENEXCEPTPATCHRTN_B8
    moveb %fp@(-224),%d0
    andib #0xf0,%d0
    tstb %d0
    jbne fpsp_pos_88
    movew %fp@(-216),%d0
    andiw #32767,%d0
    cmpiw #16383,%d0
    jbge fpsp_pos_88
    orib #16,%fp@(-224)
    jbra fpsp_pos_88
fpsp_pos_76:            /* clear %fp@(-72) */
    clrb %fp@(-72)
    bfextu %fp@(-228),4,2,%d0
    cmpib #3,%d0
    jbne GENEXCEPTPATCHRTN_E2
fpsp_pos_88:            /* return */
    rts

fpsp_pos_8A:            /* set %d0 */
    movew %fp@(-228),%d0
    btst #5,%d0
    jbeq fpsp_set_dya_6
    btst #4,%d0
    jbeq fpsp_set_dya
    andiw #127,%d0
    cmpiw #56,%d0
    jbne fpsp_set_dya_6
fpsp_set_dya:           /* from here: st %fp@(-72) */
    st %fp@(-72)
    rts
fpsp_set_dya_6:         /* clear %fp@(-72) */
    clrb %fp@(-72)
    rts

fpsp_set_dya_C:         /* clear %fp@(-84) */
    clrl %fp@(-84)
    bclr #7,%a0@
    sne %a0@(2)
    jbsr fpsp_dp_over_2C4
    btst #7,%a0@(4)
    jbne GENEXCEPTPATCHRTN_1EA
    orib #0x80,%fp@(-84)
GENEXCEPTPATCHRTN_1EA:  /* test #16383,%a0@ */
    cmpiw #16383,%a0@
    jbgt GENEXCEPTPATCHRTN_1F6
    bset #4,%fp@(-84)
GENEXCEPTPATCHRTN_1F6:  /* from here: bfclr %a0@(2),0,8 */
    bfclr %a0@(2),0,8
    jbeq GENEXCEPTPATCHRTN_202
    bset #7,%a0@
GENEXCEPTPATCHRTN_202:  /* return */
    rts

fpsp_set_dya_44:        /* set %d0 */
    movew %fp@(-228),%d0
    andiw #59,%d0
    jbeq GENEXCEPTPATCHRTN_2AE
    movew %fp@(-204),%d0
    bfextu %d0,20,12,%d1
    cmpiw #4095,%d1
    jbne GENEXCEPTPATCHRTN_24E
    bfextu %d0,17,3,%d1
    cmpiw #7,%d1
    jbne GENEXCEPTPATCHRTN_24E
    tstl %fp@(-200)
    jbne GENEXCEPTPATCHRTN_238
    tstl %fp@(-196)
    jbne GENEXCEPTPATCHRTN_238
    jbra fpsp_finish
GENEXCEPTPATCHRTN_238:  /* test bit 6 of %fp@(-200) */
    btst #6,%fp@(-200)
    jbne fpsp_finish
    oril #16793728,%fp@(-124)
    jbra fpsp_finish
GENEXCEPTPATCHRTN_24E:  /* set %d0 */
    movew %fp@(-202),%d0
    andiw #15,%d0
    tstw %d0
    jbne GENEXCEPTPATCHRTN_290
    tstl %fp@(-200)
    jbne GENEXCEPTPATCHRTN_290
    tstl %fp@(-196)
    jbne GENEXCEPTPATCHRTN_290
    tstl %fp@(-204)
    jbge GENEXCEPTPATCHRTN_280
    movel #-2147483648,%fp@(-204)
    clrl %fp@(-200)
    clrl %fp@(-196)
    jbra fpsp_finish
GENEXCEPTPATCHRTN_280:  /* clear %fp@(-204) */
    clrl %fp@(-204)
    clrl %fp@(-200)
    clrl %fp@(-196)
    jbra fpsp_finish
GENEXCEPTPATCHRTN_290:  /* from here: fmovemx %fp0,%sp@- */
    fmovemx %fp0,%sp@-
    jbsr fpsp_is_inf_4A
    fmovex %fp0,%fp@(-204)
    fmovemx %sp@+,%fp0
    fmovel #0,%fpsr
    jbra fpsp_finish
GENEXCEPTPATCHRTN_2AE:  /* set %d0 */
    movew %fp@(-204),%d0
    bfextu %d0,20,12,%d1
    cmpiw #4095,%d1
    jbne GENEXCEPTPATCHRTN_32A
    bfextu %d0,17,3,%d1
    cmpiw #7,%d1
    jbne GENEXCEPTPATCHRTN_32A
    tstl %fp@(-200)
    jbne GENEXCEPTPATCHRTN_2EE
    tstl %fp@(-196)
    jbne GENEXCEPTPATCHRTN_2EE
    oril #33554432,%fp@(-124)
    tstl %fp@(-204)
    jbge fpsp_finish
    oril #134217728,%fp@(-124)
    jbra fpsp_finish
GENEXCEPTPATCHRTN_2EE:  /* from here: oril #16777216,%fp@(-124) */
    oril #16777216,%fp@(-124)
    moveb #96,%fp@(-232)
    btst #6,%fp@(-200)
    jbne GENEXCEPTPATCHRTN_31A
    oril #16793728,%fp@(-124)
    btst #6,%fp@(-126)
    jbne GENEXCEPTPATCHRTN_31A
    bset #6,%fp@(-200)
GENEXCEPTPATCHRTN_31A:  /* test %fp@(-204) */
    tstl %fp@(-204)
    jbge fpsp_finish
    oril #134217728,%fp@(-124)
    jbra fpsp_finish
GENEXCEPTPATCHRTN_32A:  /* set %d0 */
    movew %fp@(-202),%d0
    andiw #15,%d0
    tstw %d0
    jbne GENEXCEPTPATCHRTN_378
    tstl %fp@(-200)
    jbne GENEXCEPTPATCHRTN_378
    tstl %fp@(-196)
    jbne GENEXCEPTPATCHRTN_378
    tstl %fp@(-204)
    jbge GENEXCEPTPATCHRTN_362
    oril #201326592,%fp@(-124)
    movel #-2147483648,%fp@(-204)
    clrl %fp@(-200)
    clrl %fp@(-196)
    jbra fpsp_finish
GENEXCEPTPATCHRTN_362:  /* from here: oril #67108864,%fp@(-124) */
    oril #67108864,%fp@(-124)
    clrl %fp@(-204)
    clrl %fp@(-200)
    clrl %fp@(-196)
    jbra fpsp_finish
GENEXCEPTPATCHRTN_378:  /* from here: fmovemx %fp0,%sp@- */
    fmovemx %fp0,%sp@-
    bsrw fpsp_is_inf_4A
    fmovex %fp0,%fp@(-204)
    fmovemx %sp@+,%fp0
fpsp_finish:            /* set %d0 */
    movew %fp@(-228),%d0
    andiw #-1025,%d0
    movew %d0,%fp@(-228)
    movew %fp@(-204),%d1
    andiw #32767,%d1
    cmpiw #32767,%d1
    jbne GENEXCEPTPATCHRTN_3C4
    movel %fp@(-200),%d1
    jbne GENEXCEPTPATCHRTN_3BA
    movel %fp@(-196),%d1
    jbne GENEXCEPTPATCHRTN_3BA
fpsp_is_inf:            /* set %fp@(-232) */
    moveb #64,%fp@(-232)
    moveq #64,%d0
    rts
GENEXCEPTPATCHRTN_3BA:  /* set %fp@(-232) */
    moveb #96,%fp@(-232)
    moveq #96,%d0
    rts
GENEXCEPTPATCHRTN_3C4:  /* test %d1 */
    tstw %d1
    jbne GENEXCEPTPATCHRTN_3D2
    moveb #48,%fp@(-232)
    moveq #32,%d0
    rts
GENEXCEPTPATCHRTN_3D2:  /* test #16383,%d1 */
    cmpiw #16383,%d1
    jble GENEXCEPTPATCHRTN_3DE
    clrb %fp@(-232)
    jbra GENEXCEPTPATCHRTN_3E4
GENEXCEPTPATCHRTN_3DE:  /* set %fp@(-232) */
    moveb #16,%fp@(-232)
GENEXCEPTPATCHRTN_3E4:  /* result 0 */
    moveq #0,%d0
    rts
    .short  0x4E75	| 4088E4EC
fpsp_is_inf_3A:         /* (data) */
    .short  0x0000, 0x0000, 0x0203, 0x0203, 0x0203, 0x0302, 0x0302, 0x0203	| 4088E4EE

fpsp_is_inf_4A:         /* from here: fmovel #0,%fpcr */
    fmovel #0,%fpcr

/* fpsp_decbin: convert a packed decimal operand to extended binary. */
fpsp_decbin:
    moveml %d2-%d5,%sp@-
fpsp_calc_e:            /* set %d2 */
    moveq #2,%d2
    moveq #4,%d3
    lea %fp@(-116),%a0
    movel %fp@(-204),%a0@
    movel %fp@(-200),%a0@(4)
    movel %fp@(-196),%a0@(8)
    movel %a0@,%d4
    moveq #0,%d1
GENEXCEPTPATCHRTN_422:  /* (mulul #10,%d1) */
    .short  0x4C3C, 0x1001, 0x0000, 0x000A	| 4088E526 mulul #10,%d1
    bfextu %d4,%d3,4,%d0
    addl %d0,%d1
    addqb #4,%d3
    dbf %d2,GENEXCEPTPATCHRTN_422
    btst #30,%d4
    jbeq GENEXCEPTPATCHRTN_43E
    negl %d1
GENEXCEPTPATCHRTN_43E:  /* from here: subil #16,%d1 */
    subil #16,%d1
    jbge GENEXCEPTPATCHRTN_454
    negl %d1
    oril #1073741824,%d4
    oril #1073741824,%a0@
GENEXCEPTPATCHRTN_454:  /* set %fp@(-84) */
    movel %d1,%fp@(-84)
    moveq #1,%d1
    fmoveb #0,%fp0
    bfextu %a0@,28,4,%d0
    faddb %d0,%fp0
GENEXCEPTPATCHRTN_468:  /* loop: move */
    movel %a0@(0x0,%d1:l:4),%d4
    moveq #0,%d3
    moveq #7,%d2
GENEXCEPTPATCHRTN_470:  /* loop: fmu */
    fmulb #10,%fp0
    bfextu %d4,%d3,4,%d0
    faddb %d0,%fp0
    addqb #4,%d3
    dbf %d2,GENEXCEPTPATCHRTN_470
    addql #1,%d1
    cmpil #2,%d1
    jble GENEXCEPTPATCHRTN_468
    btst #31,%a0@
    jbeq GENEXCEPTPATCHRTN_498
    fnegx %fp0,%fp0
GENEXCEPTPATCHRTN_498:  /* set %d1 */
    movel %fp@(-84),%d1
    cmpil #27,%d1
    jble fpsp_pwrten
    btst #30,%a0@
    jbne GENEXCEPTPATCHRTN_51C
    moveq #0,%d1
    movel %a0@,%d4
    bfextu %d4,28,4,%d0
    jbne GENEXCEPTPATCHRTN_4DA
    addql #1,%d1
    moveq #1,%d5
    movel %a0@(0x0,%d5:l:4),%d4
    jbne GENEXCEPTPATCHRTN_4C8
    addql #8,%d1
    addql #1,%d5
    movel %a0@(0x0,%d5:l:4),%d4
GENEXCEPTPATCHRTN_4C8:  /* clear %d3 */
    moveq #0,%d3
    moveq #7,%d2
GENEXCEPTPATCHRTN_4CC:  /* loop: bfextu */
    bfextu %d4,%d3,4,%d0
    jbne GENEXCEPTPATCHRTN_4DA
    addql #4,%d3
    addql #1,%d1
    dbf %d2,GENEXCEPTPATCHRTN_4CC
GENEXCEPTPATCHRTN_4DA:  /* set %d0 */
    movel %d1,%d0
    movel %fp@(-84),%d1
    subl %d0,%d1
    jbge GENEXCEPTPATCHRTN_4F4
    negl %d1
    movel %a0@,%d4
    oril #1073741824,%d4
    oril #1073741824,%a0@
GENEXCEPTPATCHRTN_4F4:  /* address %pc@(fpsp_SMALRP_60) */
    lea %pc@(fpsp_SMALRP_60),%a1
    moveq #0,%d3
    fmoveb #1,%fp1
    moveq #3,%d2
GENEXCEPTPATCHRTN_502:  /* loop: asr */
    asrl #1,%d0
    jbcc GENEXCEPTPATCHRTN_50C
    fmulx %a1@(0x0,%d3:w),%fp1
GENEXCEPTPATCHRTN_50C:  /* from here: addil #12,%d3 */
    addil #12,%d3
    tstl %d0
    jbne GENEXCEPTPATCHRTN_502
    fmulx %fp1,%fp0
    jbra fpsp_pwrten
GENEXCEPTPATCHRTN_51C:  /* clear %d1 */
    moveq #0,%d1
    moveq #2,%d5
    movel %a0@(0x0,%d5:l:4),%d4
    jbne GENEXCEPTPATCHRTN_52E
    subql #1,%d5
    addql #8,%d1
    movel %a0@(0x0,%d5:l:4),%d4
GENEXCEPTPATCHRTN_52E:  /* set %d3 */
    moveq #28,%d3
    moveq #7,%d2
GENEXCEPTPATCHRTN_532:  /* loop: bfextu */
    bfextu %d4,%d3,4,%d0
    jbne GENEXCEPTPATCHRTN_540
    subql #4,%d3
    addql #1,%d1
    dbf %d2,GENEXCEPTPATCHRTN_532
GENEXCEPTPATCHRTN_540:  /* set %d0 */
    movel %d1,%d0
    movel %fp@(-84),%d1
    subl %d0,%d1
    jbgt GENEXCEPTPATCHRTN_55A
    negl %d1
    movel %a0@,%d4
    andil #-1073741825,%d4
    andil #-1073741825,%a0@
GENEXCEPTPATCHRTN_55A:  /* address %pc@(fpsp_SMALRP_60) */
    lea %pc@(fpsp_SMALRP_60),%a1
    moveq #0,%d3
    fmoveb #1,%fp1
    moveq #3,%d2
GENEXCEPTPATCHRTN_568:  /* loop: asr */
    asrl #1,%d0
    jbcc GENEXCEPTPATCHRTN_572
    fmulx %a1@(0x0,%d3:w),%fp1
GENEXCEPTPATCHRTN_572:  /* from here: addil #12,%d3 */
    addil #12,%d3
    tstl %d0
    jbne GENEXCEPTPATCHRTN_568
    fdivx %fp1,%fp0
fpsp_pwrten:            /* set %d3 */
    movel %fp@(-128),%d3
    bfextu %d3,26,2,%d2
    movel %a0@,%d4
    asll #2,%d2
    bfextu %d4,0,2,%d0
    addl %d0,%d2
    lea %pc@(fpsp_is_inf_3A),%a1
    moveb %a1@(0x0,%d2:w),%d0
    moveq #0,%d3
    bfins %d0,%d3,26,2
    fmovel %d3,%fpcr
    asrl #1,%d0
    jbcc fpsp_pwrten_2E
    lea %pc@(fpsp_BIGRZRM_E4),%a1
    jbra fpsp_pwrten_3C
fpsp_pwrten_2E:         /* from here: asrl #1,%d0 */
    asrl #1,%d0
    jbcc fpsp_pwrten_38
    lea %pc@(fpsp_BIGRZRM_24),%a1
    jbra fpsp_pwrten_3C
fpsp_pwrten_38:         /* address %pc@(fpsp_SMALRP_60) */
    lea %pc@(fpsp_SMALRP_60),%a1
fpsp_pwrten_3C:         /* set %d0 */
    movel %d1,%d0
    jbpl fpsp_pwrten_48
    negl %d0
    oril #1073741824,%a0@
fpsp_pwrten_48:         /* clear %d3 */
    moveq #0,%d3
    fmoveb #1,%fp1
fpsp_pwrten_50:         /* loop: asr */
    asrl #1,%d0
    jbcc fpsp_pwrten_5A
    fmulx %a1@(0x0,%d3:w),%fp1
fpsp_pwrten_5A:         /* from here: addil #12,%d3 */
    addil #12,%d3
    tstl %d0
    jbne fpsp_pwrten_50
    btst #30,%a0@
    jbeq fpsp_pwrten_70
    fdivx %fp1,%fp0
    jbra fpsp_pwrten_74
fpsp_pwrten_70:         /* from here: fmulx %fp1,%fp0 */
    fmulx %fp1,%fp0
fpsp_pwrten_74:         /* from here: fmovel %fpsr,%d0 */
    fmovel %fpsr,%d0
    bclr #9,%d0
    fmovel %d0,%fpsr
    jbeq fpsp_pwrten_8A
    oril #264,%fp@(-124)
fpsp_pwrten_8A:         /* restore registers, return */
    moveml %sp@+,%d2-%d5
    rts
fpsp_pwrten_90:         /* (data) */
    orw %d0,%d0	| 4088E714
    movel %a0@,%d0	| 4088E716
    .short  0x0804, 0x0201	| 4088E718 btst #1,%d4

fpsp_pwrten_98:         /* test bit 1 of %fp@(-220) */
    btst #1,%fp@(-220)
    jbeq GENEXCEPTPATCHRTN_6A2
    movel %fp@(-240),%d0
    bfextu %d0,6,3,%d0
GENEXCEPTPATCHRTN_62A:  /* loop: move */
    movew %a0@,%d1
    andiw #32767,%d1
    jbeq GENEXCEPTPATCHRTN_652
    cmpiw #32767,%d1
    jbeq GENEXCEPTPATCHRTN_652
    tstl %a0@(4)
    jbmi GENEXCEPTPATCHRTN_652
    jbne GENEXCEPTPATCHRTN_64A
    tstl %a0@(8)
    jbne GENEXCEPTPATCHRTN_64A
    clrw %a0@
    jbra GENEXCEPTPATCHRTN_652
GENEXCEPTPATCHRTN_64A:  /* set %sp@- */
    movel %d0,%sp@-
    jbsr fpsp_greater_3E
    movel %sp@+,%d0
GENEXCEPTPATCHRTN_652:  /* address %pc@(fpsp_pwrten_90) */
    lea %pc@(fpsp_pwrten_90),%a1
    moveb %a1@(0x0,%d0:w),%d0
    tstb %a0@(2)
    jbeq GENEXCEPTPATCHRTN_664
    bset #7,%a0@
GENEXCEPTPATCHRTN_664:  /* from here: fmovemx %a0@,%d0 */
    fmovemx %a0@,%d0
    cmpib #0x80,%d0
    jbne GENEXCEPTPATCHRTN_676
    fmovemx %fp0,%fp@(-176)
    rts
GENEXCEPTPATCHRTN_676:  /* test #64,%d0 */
    cmpib #64,%d0
    jbne GENEXCEPTPATCHRTN_684
    fmovemx %fp1,%fp@(-164)
    rts
GENEXCEPTPATCHRTN_684:  /* test #32,%d0 */
    cmpib #32,%d0
    jbne GENEXCEPTPATCHRTN_692
    fmovemx %fp2,%fp@(-152)
    rts
GENEXCEPTPATCHRTN_692:  /* test #16,%d0 */
    cmpib #16,%d0
    jbne GENEXCEPTPATCHRTN_6A0
    fmovemx %fp3,%fp@(-140)
    rts
GENEXCEPTPATCHRTN_6A0:  /* return */
    rts
GENEXCEPTPATCHRTN_6A2:  /* call fpsp_neg_sign_74 */
    jbsr fpsp_neg_sign_74
    cmpib #3,%d0
    jbeq GENEXCEPTPATCHRTN_6B8
    movel %fp@(-228),%d0
    bfextu %d0,6,3,%d0
    jbra GENEXCEPTPATCHRTN_62A
GENEXCEPTPATCHRTN_6B8:  /* call fpsp_neg_sign_8A */
    jbsr fpsp_neg_sign_8A
    moveal %a0,%a1
    moveal %fp@(12),%a0
    tstl %d0
    jbeq fpsp_get_sman_30
    cmpil #1,%d0
    jbeq fpsp_get_mant_2A

fpsp_pwrten_150:        /* loop: moveq */
    moveq #0,%d0
    movew %a1@,%d0
    subiw #16383,%d0
    cmpiw #16384,%d0
    jbeq GENEXCEPTPATCHRTN_6F2
    addiw #1023,%d0
    swap %d0
    lsll #4,%d0
    tstb %a1@(2)
    jbeq fpsp_get_mant
    bset #31,%d0
    jbra fpsp_get_mant
GENEXCEPTPATCHRTN_6F2:  /* set %d0 */
    movel #2146435072,%d0
    clrl %a1@(4)
    tstb %a1@(2)
    jbeq GENEXCEPTPATCHRTN_706
    bset #31,%d0
GENEXCEPTPATCHRTN_706:  /* set %a1@ */
    movel %d0,%a1@
    jbra fpsp_get_mant_24
fpsp_get_mant:          /* set %d1 */
    movel %a1@(4),%d1
    bfextu %d1,1,20,%d1
    orl %d1,%d0
    movel %d0,%a1@
    movel %a1@(4),%d1
    moveq #21,%d0
    lsll %d0,%d1
    movel %d1,%a1@(4)
    movel %a1@(8),%d1
    bfextu %d1,0,21,%d0
    orl %d0,%a1@(4)
fpsp_get_mant_24:       /* set %a0@+ */
    movel %a1@+,%a0@+
    movel %a1@,%a0@
    rts

fpsp_get_mant_2A:       /* loop: moveq */
    moveq #0,%d0
    movew %a1@,%d0
    subiw #16383,%d0
    cmpiw #16384,%d0
    jbeq GENEXCEPTPATCHRTN_756
    addiw #127,%d0
    swap %d0
    lsll #7,%d0
    tstb %a1@(2)
    jbeq fpsp_get_sman
    bset #31,%d0
    jbra fpsp_get_sman
GENEXCEPTPATCHRTN_756:  /* set %d0 */
    movel #2139095040,%d0
    tstb %a1@(2)
    jbeq fpsp_get_sman_A
    bset #31,%d0
    jbra fpsp_get_sman_A
fpsp_get_sman:          /* set %d1 */
    movel %a1@(4),%d1
    bfextu %d1,1,23,%d1
    orl %d1,%d0
fpsp_get_sman_A:        /* set %fp@(-84) */
    movel %d0,%fp@(-84)
    moveq #4,%d0
    tstl %a0
    jbeq fpsp_get_sman_1C
    lea %fp@(-84),%a1
    movel %a1@,%a0@
    rts
fpsp_get_sman_1C:       /* set %a0 */
    moveal %fp@(-120),%a0
    subl %d1,%d1
    movew %a0@,%d1
    andiw #7,%d1
    orib #16,%d1
    jbra fpsp_neg_sign_298

fpsp_get_sman_30:       /* loop: tst */
    tstb %a1@(2)
    jbeq GENEXCEPTPATCHRTN_7A2
    bset #7,%a1@
GENEXCEPTPATCHRTN_7A2:  /* clear %a1@(2) */
    clrb %a1@(2)
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    movel %a1@,%a0@
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4088E8B2
fpsp_get_sman_54:       /* (data) */
    .long   0x3F81407E, 0x3F6A0000	| 4088E8C0
fpsp_dp_bnds:           /* (data) */
    .long   0x3C0143FE, 0x3BCD0000	| 4088E8C8

fpsp_dp_bnds_8:         /* clear %fp@(-74) */
    clrb %fp@(-74)
    clrb %fp@(-73)
    clrb %fp@(-70)
    tstb %fp@(-72)
    jbeq GENEXCEPTPATCHRTN_826
    bfextu %fp@(-224),0,3,%d0
    jbmi GENEXCEPTPATCHRTN_7F4
    cmpib #1,%d0
    jbne GENEXCEPTPATCHRTN_826
    bfclr %fp@(-216),1,15
    jbra GENEXCEPTPATCHRTN_826
GENEXCEPTPATCHRTN_7F4:  /* address %fp@(-216) */
    lea %fp@(-216),%a0
    bclr #7,%a0@
    sne %a0@(2)
    jbsr fpsp_greater_3E
    bclr #7,%a0@
    bfclr %a0@(2),0,8
    jbeq GENEXCEPTPATCHRTN_814
    bset #7,%a0@
GENEXCEPTPATCHRTN_814:  /* from here: bfclr %fp@(-224),0,4 */
    bfclr %fp@(-224),0,4
    bset #4,%fp@(-224)
    orib #15,%fp@(-74)
GENEXCEPTPATCHRTN_826:  /* address %fp@(-204) */
    lea %fp@(-204),%a0
    btst #5,%fp@(-228)
    jbne fpsp_fp0_dst_14
    bfextu %fp@(-232),0,3,%d0
    jbmi GENEXCEPTPATCHRTN_A1C
    cmpib #1,%d0
    jbne GENEXCEPTPATCHRTN_84A
    bfclr %fp@(-204),1,15
GENEXCEPTPATCHRTN_84A:  /* test %fp@(-72) */
    tstb %fp@(-72)
    jbne GENEXCEPTPATCHRTN_A66
    movew %fp@(-228),%d0
    andil #127,%d0
    btst #0,%d0
    jbne GENEXCEPTPATCHRTN_A66
    st %fp@(-70)
    movew %fp@(-228),%d0
    andib #59,%d0
    tstb %d0
    jbeq GENEXCEPTPATCHRTN_8FA
    cmpib #24,%d0
    jbeq GENEXCEPTPATCHRTN_8D8
    cmpib #26,%d0
    jbeq GENEXCEPTPATCHRTN_8EA
    movew %a0@,%d0
    bclr #15,%d0
    sne %a0@(2)
    jbeq GENEXCEPTPATCHRTN_896
    oril #134217728,%fp@(-124)
GENEXCEPTPATCHRTN_896:  /* test #32767,%d0 */
    cmpiw #32767,%d0
    jbne GENEXCEPTPATCHRTN_8C2
    tstl %a0@(4)
    jbne GENEXCEPTPATCHRTN_8B2
    tstl %a0@(8)
    jbne GENEXCEPTPATCHRTN_8B2
    oril #33554432,%fp@(-124)
    rts
GENEXCEPTPATCHRTN_8B2:  /* from here: oril #16777216,%fp@(-124) */
    oril #16777216,%fp@(-124)
    movel %fp@(-204),%fp@(-216)
    rts
GENEXCEPTPATCHRTN_8C2:  /* test %a0@(4) */
    tstl %a0@(4)
    jbne GENEXCEPTPATCHRTN_8D6
    tstl %a0@(8)
    jbne GENEXCEPTPATCHRTN_8D6
    oril #67108864,%fp@(-124)
GENEXCEPTPATCHRTN_8D6:  /* return */
    rts
GENEXCEPTPATCHRTN_8D8:  /* set %d0 */
    moveb %fp@(-232),%d0
    btst #5,%d0
    jbne fpsp_frc1_dst_28
    bclr #7,%a0@
    jbra GENEXCEPTPATCHRTN_8FA
GENEXCEPTPATCHRTN_8EA:  /* set %d0 */
    moveb %fp@(-232),%d0
    btst #5,%d0
    jbne fpsp_frc1_dst_28
    bchg #7,%a0@
GENEXCEPTPATCHRTN_8FA:  /* set %d0 */
    moveb %fp@(-232),%d0
    andib #0xe0,%d0
    jbne fpsp_frc1_dst_28
    btst #2,%fp@(-227)
    jbne GENEXCEPTPATCHRTN_926
    btst #6,%fp@(-227)
    jbne GENEXCEPTPATCHRTN_96A
    bfextu %fp@(-125),0,2,%d0
    jbeq GENEXCEPTPATCHRTN_9F6
    cmpib #1,%d0
    jbeq GENEXCEPTPATCHRTN_96A
GENEXCEPTPATCHRTN_926:  /* from here: bfextu %fp@(-125),2,2,%d1 */
    bfextu %fp@(-125),2,2,%d1
    oril #131072,%d1
    movel %d1,%sp@-
    bclr #7,%a0@
    sne %a0@(2)
    moveq #2,%d0
    movew %a0@,%d1
    cmpiw #15361,%d1
    jblt GENEXCEPTPATCHRTN_9B0
    movel %sp@+,%d1
    moveq #0,%d0
    jbsr fpsp_dp_over_152
    bfclr %a0@(2),0,8
    jbeq GENEXCEPTPATCHRTN_95A
    bset #7,%a0@
GENEXCEPTPATCHRTN_95A:  /* set %d1 */
    movew %a0@,%d1
    andiw #32767,%d1
    cmpiw #17407,%d1
    jbge GENEXCEPTPATCHRTN_9AA
    jbra GENEXCEPTPATCHRTN_9F6
GENEXCEPTPATCHRTN_96A:  /* from here: bfextu %fp@(-125),2,2,%d1 */
    bfextu %fp@(-125),2,2,%d1
    oril #65536,%d1
    movel %d1,%sp@-
    bclr #7,%a0@
    sne %a0@(2)
    moveq #1,%d0
    movew %a0@,%d1
    cmpiw #16257,%d1
    jblt GENEXCEPTPATCHRTN_9B0
    movel %sp@+,%d1
    moveq #0,%d0
    jbsr fpsp_dp_over_152
    bfclr %a0@(2),0,8
    jbeq GENEXCEPTPATCHRTN_99E
    bset #7,%a0@
GENEXCEPTPATCHRTN_99E:  /* set %d1 */
    movew %a0@,%d1
    andiw #32767,%d1
    cmpiw #16511,%d1
    jblt GENEXCEPTPATCHRTN_9F6
GENEXCEPTPATCHRTN_9AA:  /* call fpsp_t_ovfl2_54 */
    jbsr fpsp_t_ovfl2_54
    jbra GENEXCEPTPATCHRTN_9F6
GENEXCEPTPATCHRTN_9B0:  /* call fpsp_lower_20 */
    jbsr fpsp_lower_20
    movel %sp@+,%d1
    jbsr fpsp_dp_over_152
    bfclr %a0@(2),0,8
    jbeq GENEXCEPTPATCHRTN_9C6
    bset #7,%a0@
GENEXCEPTPATCHRTN_9C6:  /* from here: oril #2048,%fp@(-124) */
    oril #2048,%fp@(-124)
    btst #1,%fp@(-122)
    jbeq GENEXCEPTPATCHRTN_9DE
    oril #32,%fp@(-124)
GENEXCEPTPATCHRTN_9DE:  /* test %a0@(4) */
    tstl %a0@(4)
    jbne GENEXCEPTPATCHRTN_9F0
    tstl %a0@(8)
    jbne GENEXCEPTPATCHRTN_9F0
    andiw #-32768,%a0@
    jbra GENEXCEPTPATCHRTN_A02
GENEXCEPTPATCHRTN_9F0:  /* call fpsp_greater_3E */
    jbsr fpsp_greater_3E
    jbra GENEXCEPTPATCHRTN_A0A
GENEXCEPTPATCHRTN_9F6:  /* test %a0@(4) */
    tstl %a0@(4)
    jbne GENEXCEPTPATCHRTN_A0A
    tstl %a0@(8)
    jbne GENEXCEPTPATCHRTN_A0A
GENEXCEPTPATCHRTN_A02:  /* from here: oril #67108864,%fp@(-124) */
    oril #67108864,%fp@(-124)
GENEXCEPTPATCHRTN_A0A:  /* test %a0@ */
    tstw %a0@
    jbpl fpsp_frc1_dst_28
    oril #134217728,%fp@(-124)
    jbra fpsp_frc1_dst_28
GENEXCEPTPATCHRTN_A1C:  /* test %fp@(-72) */
    tstb %fp@(-72)
    jbne GENEXCEPTPATCHRTN_A38
    movew %fp@(-228),%d0
    andil #127,%d0
    btst #0,%d0
    jbne GENEXCEPTPATCHRTN_A38
    st %fp@(-70)
    jbra fpsp_fix_stk_16
GENEXCEPTPATCHRTN_A38:  /* clear bit 7 of %a0@ */
    bclr #7,%a0@
    sne %a0@(2)
    jbsr fpsp_greater_3E
    bclr #7,%a0@
    bfclr %a0@(2),0,8
    jbeq GENEXCEPTPATCHRTN_A54
    bset #7,%a0@
GENEXCEPTPATCHRTN_A54:  /* from here: bfclr %fp@(-232),0,4 */
    bfclr %fp@(-232),0,4
    bset #4,%fp@(-232)
    orib #0xf0,%fp@(-74)
GENEXCEPTPATCHRTN_A66:  /* test %fp@(-74) */
    tstb %fp@(-74)
    jbne fpsp_fix_stk_182
fpsp_fix_stk:           /* loop: move */
    moveb #0xfe,%fp@(-284)
    bclr #2,%fp@(-220)
    clrw %fp@(-236)
    st %fp@(-73)
    rts
fpsp_fix_stk_16:        /* from here: st %fp@(-70) */
    st %fp@(-70)
    movew %fp@(-228),%d0
    andib #59,%d0
    tstb %d0
    jbeq fpsp_fix_stk_92
    cmpib #24,%d0
    jbeq fpsp_fix_stk_88
    cmpib #26,%d0
    jbeq fpsp_fix_stk_8E
    movew %a0@,%d0
    bclr #15,%d0
    sne %a0@(2)
    jbeq fpsp_fix_stk_46
    oril #134217728,%fp@(-124)
fpsp_fix_stk_46:        /* test #32767,%d0 */
    cmpiw #32767,%d0
    jbne fpsp_fix_stk_72
    tstl %a0@(4)
    jbne fpsp_fix_stk_62
    tstl %a0@(8)
    jbne fpsp_fix_stk_62
    oril #33554432,%fp@(-124)
    rts
fpsp_fix_stk_62:        /* from here: oril #16777216,%fp@(-124) */
    oril #16777216,%fp@(-124)
    movel %fp@(-204),%fp@(-216)
    rts
fpsp_fix_stk_72:        /* test %a0@(4) */
    tstl %a0@(4)
    jbne fpsp_fix_stk_86
    tstl %a0@(8)
    jbne fpsp_fix_stk_86
    oril #67108864,%fp@(-124)
fpsp_fix_stk_86:        /* return */
    rts
fpsp_fix_stk_88:        /* clear bit 7 of %a0@ */
    bclr #7,%a0@
    jbra fpsp_fix_stk_92
fpsp_fix_stk_8E:        /* flip bit 7 of %a0@ */
    bchg #7,%a0@
fpsp_fix_stk_92:        /* test bit 2 of %fp@(-227) */
    btst #2,%fp@(-227)
    jbne fpsp_fix_stk_B2
    btst #6,%fp@(-227)
    jbne fpsp_fix_stk_CE
    bfextu %fp@(-125),0,2,%d0
    tstb %d0
    jbeq fpsp_fix_stk_EC
    cmpib #1,%d0
    jbeq fpsp_fix_stk_CE
fpsp_fix_stk_B2:        /* from here: bfextu %fp@(-125),2,2,%d1 */
    bfextu %fp@(-125),2,2,%d1
    tstw %a0@
    jblt fpsp_fix_stk_C4
    cmpib #3,%d1
    jbne fpsp_fix_stk_106
    jbra fpsp_fix_stk_11C
fpsp_fix_stk_C4:        /* test #2,%d1 */
    cmpib #2,%d1
    jbne fpsp_fix_stk_13A
    jbra fpsp_fix_stk_154
fpsp_fix_stk_CE:        /* from here: bfextu %fp@(-125),2,2,%d1 */
    bfextu %fp@(-125),2,2,%d1
    tstw %a0@
    jblt fpsp_fix_stk_E2
    cmpib #3,%d1
    jbne fpsp_fix_stk_106
    jbra fpsp_fix_stk_172
fpsp_fix_stk_E2:        /* test #2,%d1 */
    cmpib #2,%d1
    jbne fpsp_fix_stk_13A
    jbra fpsp_fix_stk_17A
fpsp_fix_stk_EC:        /* from here: oril #2048,%fp@(-124) */
    oril #2048,%fp@(-124)
    tstw %a0@
    jbeq fpsp_frc1_dst_28
    oril #134217728,%fp@(-124)
    jbra fpsp_frc1_dst_28
fpsp_fix_stk_106:       /* clear %a0@ */
    clrl %a0@
    clrl %a0@(4)
    clrl %a0@(8)
    oril #67111464,%fp@(-124)
    jbra fpsp_frc1_dst_28
fpsp_fix_stk_11C:       /* set %a0@ */
    movel #1003290624,%a0@
fpsp_fix_stk_122:       /* loop: move */
    movel #-2147483648,%a0@(4)
    clrl %a0@(8)
    oril #2600,%fp@(-124)
    jbra fpsp_frc1_dst_28
fpsp_fix_stk_13A:       /* set %a0@ */
    movel #-2147483648,%a0@
    clrl %a0@(4)
    clrl %a0@(8)
    oril #201329192,%fp@(-124)
    jbra fpsp_frc1_dst_28
fpsp_fix_stk_154:       /* set %a0@ */
    movel #-1144193024,%a0@
fpsp_fix_stk_15A:       /* loop: move */
    movel #-2147483648,%a0@(4)
    clrl %a0@(8)
    oril #134220328,%fp@(-124)
    jbra fpsp_frc1_dst_28
fpsp_fix_stk_172:       /* set %a0@ */
    movel #1063911424,%a0@
    jbra fpsp_fix_stk_122
fpsp_fix_stk_17A:       /* set %a0@ */
    movel #-1083572224,%a0@
    jbra fpsp_fix_stk_15A
fpsp_fix_stk_182:       /* test %fp@(-72) */
    tstb %fp@(-72)
    jbeq fpsp_fix_stk
    movew %fp@(-228),%d0
    andiw #59,%d0
    cmpiw #34,%d0
    jbeq fpsp_force_ovf_4C
    cmpiw #40,%d0
    jbeq fpsp_force_ovf_294
    cmpiw #35,%d0
    jbeq fpsp_force_ovf_552
    cmpiw #56,%d0
    jbeq fpsp_force_ovf_4E2
    cmpib #0xff,%fp@(-74)
    jbeq fpsp_fix_stk
    cmpib #15,%fp@(-74)
    jbne fpsp_fix_stk_1EA
    bfextu %fp@(-204),1,15,%d0
    bfexts %fp@(-216),1,15,%d1
    subl %d1,%d0
    cmpil #32767,%d0
    jblt fpsp_fix_stk
    btst #6,%fp@(-232)
    jbne fpsp_fix_stk
    jbra fpsp_force_unf
fpsp_fix_stk_1EA:       /* from here: bfextu %fp@(-216),1,15,%d0 */
    bfextu %fp@(-216),1,15,%d0
    bfexts %fp@(-204),1,15,%d1
    subl %d1,%d0
    cmpil #32768,%d0
    jblt fpsp_fix_stk
    btst #6,%fp@(-224)
    jbne fpsp_fix_stk
    clrb %fp@(-266)
    movew %fp@(-204),%d0
    movew %fp@(-216),%d1
    eorw %d1,%d0
    andiw #-32768,%d0
    jbeq fpsp_force_ovf
    st %fp@(-266)
fpsp_force_ovf:         /* clear bit 2 of %fp@(-220) */
    bclr #2,%fp@(-220)
    oril #4168,%fp@(-124)
    clrw %fp@(-236)
    lea %fp@(-268),%a0
    movew %fp@(-228),%d0
    btst #6,%d0
    jbeq fpsp_force_ovf_2E
    btst #2,%d0
    jbne fpsp_force_ovf_2A
    moveq #1,%d0
    jbra fpsp_force_ovf_34
fpsp_force_ovf_2A:      /* result 2 */
    moveq #2,%d0
    jbra fpsp_force_ovf_34
fpsp_force_ovf_2E:      /* from here: bfextu %fp@(-125),0,2,%d0 */
    bfextu %fp@(-125),0,2,%d0
fpsp_force_ovf_34:      /* call fpsp_sec_d_11E */
    jbsr fpsp_sec_d_11E
    bfclr %fp@(-266),0,8
    jbeq fpsp_force_unf_BE
    bset #7,%fp@(-268)
    jbra fpsp_force_unf_BE
fpsp_force_ovf_4C:      /* test #0xff,%fp@(-74) */
    cmpib #0xff,%fp@(-74)
    jbeq fpsp_fix_stk
    cmpib #15,%fp@(-74)
    jbne fpsp_force_ovf_82
    bfextu %fp@(-204),1,15,%d0
    bfexts %fp@(-216),1,15,%d1
    subl %d1,%d0
    cmpil #32768,%d0
    jblt fpsp_fix_stk
    btst #6,%fp@(-232)
    jbne fpsp_fix_stk
    jbra fpsp_force_ovf_A4
fpsp_force_ovf_82:      /* from here: bfextu %fp@(-216),1,15,%d0 */
    bfextu %fp@(-216),1,15,%d0
    bfexts %fp@(-204),1,15,%d1
    subl %d1,%d0
    cmpil #32768,%d0
    jblt fpsp_fix_stk
    btst #6,%fp@(-224)
    jbne fpsp_fix_stk
fpsp_force_ovf_A4:      /* set %d0 */
    movew %fp@(-204),%d0
    movew %fp@(-216),%d1
    eorw %d1,%d0
    andiw #-32768,%d0
    jbeq fpsp_force_ovf_1A2
    cmpib #15,%fp@(-74)
    jbne fpsp_force_ovf_130
    movew %fp@(-216),%d0
    andiw #-32768,%d0
    oriw #16383,%d0
    movew %d0,%fp@(-216)
    movel %fp@(-128),%d0
    andil #48,%d0
    fmovel %d0,%fpcr
    fmovex %fp@(-204),%fp0
    faddx %fp@(-216),%fp0
    lea %fp@(-268),%a0
    fmovel %fpsr,%d1
    orl %d1,%fp@(-124)
    fmovex %fp0,%fp@(-268)
    lsrl #4,%d0
    movel %fp@(-128),%d1
    andil #192,%d1
    lsrl #6,%d1
    swap %d1
    orl %d0,%d1
    moveq #0,%d0
    bclr #7,%fp@(-268)
    sne %fp@(-266)
    jbsr fpsp_dp_over_152
    bfclr %fp@(-266),0,8
    jbeq fpsp_force_unf_78
    bset #7,%fp@(-268)
    jbra fpsp_force_unf_78
fpsp_force_ovf_130:     /* set %d0 */
    movew %fp@(-204),%d0
    andiw #-32768,%d0
    oriw #16383,%d0
    movew %d0,%fp@(-204)
    movel %fp@(-128),%d0
    andil #48,%d0
    fmovel %d0,%fpcr
    fmovex %fp@(-204),%fp0
    faddx %fp@(-216),%fp0
    fmovel %fpsr,%d1
    orl %d1,%fp@(-124)
    lea %fp@(-268),%a0
    fmovex %fp0,%fp@(-268)
    lsrl #4,%d0
    movel %fp@(-128),%d1
    andil #192,%d1
    lsrl #6,%d1
    swap %d1
    orl %d0,%d1
    moveq #0,%d0
    bclr #7,%fp@(-268)
    sne %fp@(-266)
    jbsr fpsp_dp_over_152
    bfclr %fp@(-266),0,8
    jbeq fpsp_force_unf_78
    bset #7,%fp@(-268)
    jbra fpsp_force_unf_78
fpsp_force_ovf_1A2:     /* test #15,%fp@(-74) */
    cmpib #15,%fp@(-74)
    jbne fpsp_force_ovf_210
    lea %fp@(-204),%a0
    movel %fp@(-128),%d0
    andil #48,%d0
    lsrl #4,%d0
    movel %fp@(-128),%d1
    andil #192,%d1
    lsrl #6,%d1
    swap %d1
    orl %d0,%d1
    movel #536870912,%d0
    bclr #7,%fp@(-204)
    sne %fp@(-202)
    jbsr fpsp_dp_over_152
    bfclr %fp@(-202),0,8
    jbeq fpsp_force_ovf_1EC
    bset #7,%fp@(-204)
fpsp_force_ovf_1EC:     /* address %fp@(-268) */
    lea %fp@(-268),%a0
    movel %fp@(-204),%a0@
    movel %fp@(-200),%a0@(4)
    movel %fp@(-196),%a0@(8)
    tstw %fp@(-204)
    jbgt fpsp_force_ovf_274
    oril #134217728,%fp@(-124)
    jbra fpsp_force_ovf_274
fpsp_force_ovf_210:     /* address %fp@(-216) */
    lea %fp@(-216),%a0
    movel %fp@(-128),%d0
    andil #48,%d0
    lsrl #4,%d0
    movel %fp@(-128),%d1
    andil #192,%d1
    lsrl #6,%d1
    swap %d1
    orl %d0,%d1
    movel #536870912,%d0
    bclr #7,%fp@(-216)
    sne %fp@(-214)
    jbsr fpsp_dp_over_152
    bfclr %fp@(-214),0,8
    jbeq fpsp_force_ovf_252
    bset #7,%fp@(-216)
fpsp_force_ovf_252:     /* address %fp@(-268) */
    lea %fp@(-268),%a0
    movel %fp@(-216),%a0@
    movel %fp@(-212),%a0@(4)
    movel %fp@(-208),%a0@(8)
    tstw %fp@(-216)
    jbgt fpsp_force_ovf_274
    oril #134217728,%fp@(-124)
fpsp_force_ovf_274:     /* set %d0 */
    movew %fp@(-268),%d0
    andiw #32767,%d0
    cmpiw #32767,%d0
    jbne fpsp_force_unf_78
    oril #33558600,%fp@(-124)
    clrl %a0@(4)
    jbra fpsp_force_unf_78
fpsp_force_ovf_294:     /* test #0xff,%fp@(-74) */
    cmpib #0xff,%fp@(-74)
    jbeq fpsp_fix_stk
    cmpib #15,%fp@(-74)
    jbne fpsp_force_ovf_2CA
    bfextu %fp@(-204),1,15,%d0
    bfexts %fp@(-216),1,15,%d1
    subl %d1,%d0
    cmpil #32768,%d0
    jblt fpsp_fix_stk
    btst #6,%fp@(-232)
    jbne fpsp_fix_stk
    jbra fpsp_force_ovf_2EC
fpsp_force_ovf_2CA:     /* from here: bfextu %fp@(-216),1,15,%d0 */
    bfextu %fp@(-216),1,15,%d0
    bfexts %fp@(-204),1,15,%d1
    subl %d1,%d0
    cmpil #32768,%d0
    jblt fpsp_fix_stk
    btst #6,%fp@(-224)
    jbne fpsp_fix_stk
fpsp_force_ovf_2EC:     /* set %d0 */
    movew %fp@(-204),%d0
    movew %fp@(-216),%d1
    eorw %d1,%d0
    andiw #-32768,%d0
    jbne fpsp_force_ovf_3EA
    cmpib #15,%fp@(-74)
    jbne fpsp_force_ovf_378
    movew %fp@(-216),%d0
    andiw #-32768,%d0
    oriw #16383,%d0
    movew %d0,%fp@(-216)
    movel %fp@(-128),%d0
    andil #48,%d0
    fmovel %d0,%fpcr
    fmovex %fp@(-216),%fp0
    fsubx %fp@(-204),%fp0
    fmovel %fpsr,%d1
    orl %d1,%fp@(-124)
    lea %fp@(-268),%a0
    fmovex %fp0,%fp@(-268)
    lsrl #4,%d0
    movel %fp@(-128),%d1
    andil #192,%d1
    lsrl #6,%d1
    swap %d1
    orl %d0,%d1
    moveq #0,%d0
    bclr #7,%fp@(-268)
    sne %fp@(-266)
    jbsr fpsp_dp_over_152
    bfclr %fp@(-266),0,8
    jbeq fpsp_force_unf_78
    bset #7,%fp@(-268)
    jbra fpsp_force_unf_78
fpsp_force_ovf_378:     /* set %d0 */
    movew %fp@(-204),%d0
    andiw #-32768,%d0
    oriw #16383,%d0
    movew %d0,%fp@(-204)
    movel %fp@(-128),%d0
    andil #48,%d0
    fmovel %d0,%fpcr
    fmovex %fp@(-216),%fp0
    fsubx %fp@(-204),%fp0
    fmovel %fpsr,%d1
    orl %d1,%fp@(-124)
    lea %fp@(-268),%a0
    fmovex %fp0,%fp@(-268)
    lsrl #4,%d0
    movel %fp@(-128),%d1
    andil #192,%d1
    lsrl #6,%d1
    swap %d1
    orl %d0,%d1
    moveq #0,%d0
    bclr #7,%fp@(-268)
    sne %fp@(-266)
    jbsr fpsp_dp_over_152
    bfclr %fp@(-266),0,8
    jbeq fpsp_force_unf_78
    bset #7,%fp@(-268)
    jbra fpsp_force_unf_78
fpsp_force_ovf_3EA:     /* test #15,%fp@(-74) */
    cmpib #15,%fp@(-74)
    jbne fpsp_force_ovf_45E
    lea %fp@(-204),%a0
    movel %fp@(-128),%d0
    andil #48,%d0
    lsrl #4,%d0
    movel %fp@(-128),%d1
    andil #192,%d1
    lsrl #6,%d1
    swap %d1
    orl %d0,%d1
    movel #536870912,%d0
    eoriw #-32768,%fp@(-204)
    tstw %fp@(-204)
    jbgt fpsp_force_ovf_42C
    oril #134217728,%fp@(-124)
fpsp_force_ovf_42C:     /* clear bit 7 of %fp@(-204) */
    bclr #7,%fp@(-204)
    sne %fp@(-202)
    jbsr fpsp_dp_over_152
    bfclr %fp@(-202),0,8
    jbeq fpsp_force_ovf_448
    bset #7,%fp@(-204)
fpsp_force_ovf_448:     /* address %fp@(-268) */
    lea %fp@(-268),%a0
    movel %fp@(-204),%a0@
    movel %fp@(-200),%a0@(4)
    movel %fp@(-196),%a0@(8)
    jbra fpsp_force_ovf_4C2
fpsp_force_ovf_45E:     /* address %fp@(-216) */
    lea %fp@(-216),%a0
    movel %fp@(-128),%d0
    andil #48,%d0
    lsrl #4,%d0
    movel %fp@(-128),%d1
    andil #192,%d1
    lsrl #6,%d1
    swap %d1
    orl %d0,%d1
    movel #536870912,%d0
    bclr #7,%fp@(-216)
    sne %fp@(-214)
    jbsr fpsp_dp_over_152
    bfclr %fp@(-214),0,8
    jbeq fpsp_force_ovf_4A0
    bset #7,%fp@(-216)
fpsp_force_ovf_4A0:     /* address %fp@(-268) */
    lea %fp@(-268),%a0
    movel %fp@(-216),%a0@
    movel %fp@(-212),%a0@(4)
    movel %fp@(-208),%a0@(8)
    tstw %fp@(-216)
    jbgt fpsp_force_ovf_4C2
    oril #134217728,%fp@(-124)
fpsp_force_ovf_4C2:     /* set %d0 */
    movew %fp@(-268),%d0
    andiw #32767,%d0
    cmpiw #32767,%d0
    jbne fpsp_force_unf_78
    oril #33558600,%fp@(-124)
    clrl %a0@(4)
    jbra fpsp_force_unf_78
fpsp_force_ovf_4E2:     /* test #0xff,%fp@(-74) */
    cmpib #0xff,%fp@(-74)
    jbeq fpsp_fix_stk
    cmpib #15,%fp@(-74)
    jbne fpsp_force_ovf_51E
    bfextu %fp@(-204),1,15,%d0
    bfexts %fp@(-216),1,15,%d1
    subl %d1,%d0
    cmpil #32768,%d0
    jblt fpsp_fix_stk
    btst #6,%fp@(-232)
    jbne fpsp_fix_stk
    tstw %fp@(-204)
    jbge fpsp_force_ovf_548
    rts
fpsp_force_ovf_51E:     /* from here: bfextu %fp@(-216),1,15,%d0 */
    bfextu %fp@(-216),1,15,%d0
    bfexts %fp@(-204),1,15,%d1
    subl %d1,%d0
    cmpil #32768,%d0
    jblt fpsp_fix_stk
    btst #6,%fp@(-224)
    jbne fpsp_fix_stk
    tstw %fp@(-216)
    jblt fpsp_force_ovf_548
    rts
fpsp_force_ovf_548:     /* from here: oril #134217728,%fp@(-124) */
    oril #134217728,%fp@(-124)
    rts
fpsp_force_ovf_552:     /* test #0xff,%fp@(-74) */
    cmpib #0xff,%fp@(-74)
    jbeq fpsp_force_unf
    cmpib #15,%fp@(-74)
    jbne fpsp_force_ovf_580
    bfextu %fp@(-204),1,15,%d0
    bfexts %fp@(-216),1,15,%d1
    addl %d1,%d0
    jbgt fpsp_fix_stk
    btst #5,%fp@(-232)
    jbne fpsp_fix_stk
    jbra fpsp_force_unf
fpsp_force_ovf_580:     /* from here: bfextu %fp@(-216),1,15,%d0 */
    bfextu %fp@(-216),1,15,%d0
    bfexts %fp@(-204),1,15,%d1
    addl %d1,%d0
    jbgt fpsp_fix_stk
    btst #5,%fp@(-224)
    jbne fpsp_fix_stk
fpsp_force_unf:         /* clear bit 2 of %fp@(-220) */
    bclr #2,%fp@(-220)
    oril #2600,%fp@(-124)
    clrw %fp@(-236)
    clrb %fp@(-266)
    movew %fp@(-204),%d0
    movew %fp@(-216),%d1
    eorw %d1,%d0
    andiw #-32768,%d0
    jbeq fpsp_force_unf_2A
    st %fp@(-266)
fpsp_force_unf_2A:      /* address %fp@(-268) */
    lea %fp@(-268),%a0
    movew %fp@(-228),%d0
    btst #6,%d0
    jbeq fpsp_force_unf_46
    btst #2,%d0
    jbne fpsp_force_unf_42
    moveq #1,%d0
    jbra fpsp_force_unf_4C
fpsp_force_unf_42:      /* result 2 */
    moveq #2,%d0
    jbra fpsp_force_unf_4C
fpsp_force_unf_46:      /* from here: bfextu %fp@(-125),0,2,%d0 */
    bfextu %fp@(-125),0,2,%d0
fpsp_force_unf_4C:      /* call fpsp_neg_sign_136 */
    jbsr fpsp_neg_sign_136
    tstw %a0@
    jbeq fpsp_force_unf_68
    tstl %a0@(4)
    jbne fpsp_force_unf_64
    tstl %a0@(8)
    jbne fpsp_force_unf_64
    clrw %a0@
    jbra fpsp_force_unf_68
fpsp_force_unf_64:      /* call fpsp_greater_3E */
    jbsr fpsp_greater_3E
fpsp_force_unf_68:      /* from here: bfclr %fp@(-266),0,8 */
    bfclr %fp@(-266),0,8
    jbeq fpsp_force_unf_BE
    bset #7,%fp@(-268)
    jbra fpsp_force_unf_BE
fpsp_force_unf_78:      /* set %d0 */
    movew %fp@(-228),%d0
    btst #6,%d0
    jbeq fpsp_force_unf_90
    btst #2,%d0
    jbne fpsp_force_unf_8C
    moveq #1,%d0
    jbra fpsp_force_unf_9A
fpsp_force_unf_8C:      /* result 2 */
    moveq #2,%d0
    jbra fpsp_force_unf_9A
fpsp_force_unf_90:      /* from here: bfextu %fp@(-125),0,2,%d0 */
    bfextu %fp@(-125),0,2,%d0
    tstb %d0
    jbeq fpsp_force_unf_BE
fpsp_force_unf_9A:      /* clear bit 7 of %fp@(-268) */
    bclr #7,%fp@(-268)
    sne %fp@(-266)
    jbsr fpsp_sec_d_11E
    bfclr %fp@(-266),0,8
    jbeq fpsp_force_unf_B6
    bset #7,%fp@(-268)
fpsp_force_unf_B6:      /* from here: oril #4680,%fp@(-124) */
    oril #4680,%fp@(-124)
fpsp_force_unf_BE:      /* from here: bfextu %fp@(-228),6,3,%d0 */
    bfextu %fp@(-228),6,3,%d0
    cmpib #3,%d0
    jble fpsp_force_unf_DA
    moveq #7,%d1
    subl %d0,%d1
    moveq #0,%d0
    bset %d1,%d0
    fmovemx %fp@(-268),%d0
    rts
fpsp_force_unf_DA:      /* test #0,%d0 */
    cmpib #0,%d0
    jbeq fpsp_frc1_dst_14
    cmpib #1,%d0
    jbeq fpsp_frc1_dst
    cmpib #2,%d0
    jbeq fpsp_frc2_dst
fpsp_frc3_dst:          /* set %fp@(-140) */
    movel %fp@(-268),%fp@(-140)
    movel %fp@(-264),%fp@(-136)
    movel %fp@(-260),%fp@(-132)
    rts
fpsp_frc2_dst:          /* set %fp@(-152) */
    movel %fp@(-268),%fp@(-152)
    movel %fp@(-264),%fp@(-148)
    movel %fp@(-260),%fp@(-144)
    rts
fpsp_frc1_dst:          /* set %fp@(-164) */
    movel %fp@(-268),%fp@(-164)
    movel %fp@(-264),%fp@(-160)
    movel %fp@(-260),%fp@(-156)
    rts
fpsp_frc1_dst_14:       /* set %fp@(-176) */
    movel %fp@(-268),%fp@(-176)
    movel %fp@(-264),%fp@(-172)
    movel %fp@(-260),%fp@(-168)
    rts
fpsp_frc1_dst_28:       /* test bit 6 of %fp@(-122) */
    btst #6,%fp@(-122)
    jbeq fpsp_snan_neg_A
    btst #6,%fp@(-126)
    jbeq fpsp_snan_neg_A
    movel %fp@(-204),%fp@(-216)
    tstb %fp@(-204)
    jblt fpsp_snan_neg
    rts
fpsp_snan_neg:          /* from here: oril #3,%fp@(-124) */
    oril #3,%fp@(-124)
    rts
fpsp_snan_neg_A:        /* clear %fp@(-236) */
    clrw %fp@(-236)
    bclr #2,%fp@(-220)
    moveb %fp@(-232),%d0
    andib #0xe0,%d0
    cmpib #64,%d0
    jbne fpsp_snan_neg_38
    oril #33554432,%fp@(-124)
    tstw %a0@
    jbge fpsp_snan_neg_74
    oril #134217728,%fp@(-124)
    jbra fpsp_snan_neg_74
fpsp_snan_neg_38:       /* test #96,%d0 */
    cmpib #96,%d0
    jbne fpsp_snan_neg_5A
    oril #16777216,%fp@(-124)
    movel %fp@(-204),%fp@(-216)
    tstw %a0@
    jbge fpsp_snan_neg_74
    oril #134217728,%fp@(-124)
    jbra fpsp_snan_neg_74
fpsp_snan_neg_5A:       /* test #32,%d0 */
    cmpib #32,%d0
    jbne fpsp_snan_neg_74
    oril #67108864,%fp@(-124)
    tstw %a0@
    jbge fpsp_snan_neg_74
    oril #134217728,%fp@(-124)
fpsp_snan_neg_74:       /* from here: bfextu %fp@(-228),6,3,%d0 */
    bfextu %fp@(-228),6,3,%d0
    cmpib #3,%d0
    jble fpsp_snan_neg_90
    moveq #7,%d1
    subl %d0,%d1
    moveq #0,%d0
    bset %d1,%d0
    fmovemx %fp@(-204),%d0
    rts
fpsp_snan_neg_90:       /* test #0,%d0 */
    cmpib #0,%d0
    jbeq fpsp_fp0_dst
    cmpib #1,%d0
    jbeq fpsp_fp1_dst
    cmpib #2,%d0
    jbeq fpsp_fp2_dst
fpsp_fp3_dst:           /* set %fp@(-140) */
    movel %fp@(-204),%fp@(-140)
    movel %fp@(-200),%fp@(-136)
    movel %fp@(-196),%fp@(-132)
    rts
fpsp_fp2_dst:           /* set %fp@(-152) */
    movel %fp@(-204),%fp@(-152)
    movel %fp@(-200),%fp@(-148)
    movel %fp@(-196),%fp@(-144)
    rts
fpsp_fp1_dst:           /* set %fp@(-164) */
    movel %fp@(-204),%fp@(-164)
    movel %fp@(-200),%fp@(-160)
    movel %fp@(-196),%fp@(-156)
    rts
fpsp_fp0_dst:           /* set %fp@(-176) */
    movel %fp@(-204),%fp@(-176)
    movel %fp@(-200),%fp@(-172)
    movel %fp@(-196),%fp@(-168)
    rts
fpsp_fp0_dst_14:        /* from here: st %fp@(-70) */
    st %fp@(-70)
    movew %fp@(-228),%d0
    andiw #3072,%d0
    cmpiw #3072,%d0
    jbeq fpsp_dp_over_A2
    jbra fpsp_fp0_dst_3A
fpsp_fp0_dst_2A:        /* (data) */
    .short  fpsp_fp0_dst_A4-fpsp_fp0_dst_2A	| 4088F594
    .short  fpsp_fp0_dst_2DA-fpsp_fp0_dst_2A	| 4088F596
    .short  fpsp_fp0_dst_2C0-fpsp_fp0_dst_2A	| 4088F598
    .short  fpsp_fp0_dst_4A-fpsp_fp0_dst_2A	| 4088F59A
    .short  TMPEND_4088F620_54_20-fpsp_fp0_dst_2A	| 4088F59C
    .short  fpsp_fp0_dst_308-fpsp_fp0_dst_2A	| 4088F59E
    .short  fpsp_fp0_dst_1B4-fpsp_fp0_dst_2A	| 4088F5A0
    .short  fpsp_fp0_dst_4A-fpsp_fp0_dst_2A	| 4088F5A2
fpsp_fp0_dst_3A:        /* from here: bfextu %fp@(-228),3,3,%d1 */
    bfextu %fp@(-228),3,3,%d1
    lea %pc@(fpsp_fp0_dst_2A),%a0
    addaw %a0@(0x0,%d1:w:2),%a0
    jmp %a0@
fpsp_fp0_dst_4A:        /* loop: btst */
    btst #1,%fp@(-122)
    jbeq fpsp_fp0_dst_60
    btst #3,%fp@(-122)
    jbeq fpsp_fp0_dst_60
    bset #5,%fp@(-121)
fpsp_fp0_dst_60:        /* clear %fp@(-236) */
    clrw %fp@(-236)
    bclr #2,%fp@(-220)
    fmovel #0,%fpsr
    bfclr %fp@(-202),0,8
    jbeq fpsp_fp0_dst_80
    bset #7,%fp@(-204)
fpsp_fp0_dst_80:        /* return */
    rts
fpsp_fp0_dst_82:        /* loop: clr */
    clrw %fp@(-236)
    bclr #2,%fp@(-220)
    fmovel #0,%fpsr
    bfclr %fp@(-202),0,8
    jbeq fpsp_fp0_dst_A2
    bset #7,%fp@(-204)
fpsp_fp0_dst_A2:        /* return */
    rts
fpsp_fp0_dst_A4:        /* set %d0 */
    moveq #4,%d0	| 4088F60E
    btst #7,%fp@(-232)	| 4088F610
    jbne fpsp_fp0_dst_22A	| 4088F616
    fmovemx %fp@(-204),%fp0	| 4088F61A
    fcmpd #0x41dfffffffc00000,%fp0	| 4088F620
    fbge TMPEND_4088F620_34	| 4088F62C
    fcmpd #0xc1e0000000000000,%fp0	| 4088F630
    fble TMPEND_4088F620_54	| 4088F63C
    movel %fp@(-128),%d1	| 4088F640
    andil #48,%d1	| 4088F644
    fmovel %d1,%fpcr	| 4088F64A
    fmovel %fp0,%fp@(-84)	| 4088F64E
    fmovel %fpsr,%d1	| 4088F654
    orl %d1,%fp@(-124)	| 4088F658
    jbra fpsp_fp0_dst_276	| 4088F65C
TMPEND_4088F620_34:     /* set %fp@(-84) */
    movel #2147483647,%fp@(-84)	| 4088F660
    fbeq fpsp_fp0_dst_276	| 4088F668
    fcmpd #0x41dfffffffe00000,%fp0	| 4088F66C
    fbge fpsp_fp0_dst_268	| 4088F678
    jbra fpsp_fp0_dst_25E	| 4088F67C
TMPEND_4088F620_54:     /* set %fp@(-84) */
    movel #-2147483648,%fp@(-84)	| 4088F680
    fbeq fpsp_fp0_dst_276	| 4088F688
    .byte   0xF2, 0x3C, 0x54, 0x38, 0xC1, 0xE0	| 4088F68C
    orib #16,%d0
    .byte   0x00, 0x00	| 4088F696
    fblt fpsp_fp0_dst_268	| 4088F698
    jbra fpsp_fp0_dst_25E	| 4088F69C
TMPEND_4088F620_54_20:  /* set %d0 */
    moveq #2,%d0	| 4088F6A0
    btst #7,%fp@(-232)
    jbne fpsp_fp0_dst_22A
    fmovemx %fp@(-204),%fp0
    fcmps #0e32767,%fp0
    fbge fpsp_fp0_dst_180
    fcmps #0e-32768,%fp0
    fble fpsp_fp0_dst_19A
    movel %fp@(-128),%d1
    andil #48,%d1
    fmovel %d1,%fpcr
    fmovew %fp0,%fp@(-84)
    fmovel %fpsr,%d1
    orl %d1,%fp@(-124)
    jbra fpsp_fp0_dst_276
fpsp_fp0_dst_180:       /* set %fp@(-84) */
    movew #32767,%fp@(-84)
    fbeq fpsp_fp0_dst_276
    fcmps #0e32767.5,%fp0
    fbge fpsp_fp0_dst_268
    jbra fpsp_fp0_dst_25E
fpsp_fp0_dst_19A:       /* set %fp@(-84) */
    movew #-32768,%fp@(-84)
    fbeq fpsp_fp0_dst_276
    fcmps #0e-32768.5,%fp0
    fblt fpsp_fp0_dst_268
    jbra fpsp_fp0_dst_25E
fpsp_fp0_dst_1B4:       /* set %d0 */
    moveq #1,%d0	| 4088F71E
    btst #7,%fp@(-232)	| 4088F720
    jbne fpsp_fp0_dst_22A	| 4088F726
    fmovemx %fp@(-204),%fp0	| 4088F728
    fcmps #0e127,%fp0	| 4088F72E
    fbge fpsp_fp0_dst_1FA	| 4088F736
    fcmps #0e-128,%fp0	| 4088F73A
    fble fpsp_fp0_dst_212	| 4088F742
    movel %fp@(-128),%d1	| 4088F746
    andil #48,%d1	| 4088F74A
    fmovel %d1,%fpcr	| 4088F750
    fmoveb %fp0,%fp@(-84)	| 4088F754
    fmovel %fpsr,%d1	| 4088F75A
    orl %d1,%fp@(-124)	| 4088F75E
    jbra fpsp_fp0_dst_276	| 4088F762
fpsp_fp0_dst_1FA:       /* set %fp@(-84) */
    moveb #127,%fp@(-84)	| 4088F764
    fbeq fpsp_fp0_dst_276	| 4088F76A
    fcmps #0e127.5,%fp0	| 4088F76E
    fbge fpsp_fp0_dst_268	| 4088F776
    jbra fpsp_fp0_dst_25E	| 4088F77A
fpsp_fp0_dst_212:       /* (4088F77C moveb #-128,%fp@(-84)) */
    .short  0x1D7C, 0x0080, 0xFFAC	| 4088F77C moveb #-128,%fp@(-84)
    fbeq fpsp_fp0_dst_276	| 4088F782
    fcmps #0e-128.5,%fp0	| 4088F786
    fblt fpsp_fp0_dst_268	| 4088F78E
    jbra fpsp_fp0_dst_25E	| 4088F792
fpsp_fp0_dst_22A:       /* clear %fp@(-84) */
    clrl %fp@(-84)
    bfextu %fp@(-125),2,2,%d1
    cmpib #2,%d1
    jbmi fpsp_fp0_dst_25E
    jbne fpsp_fp0_dst_24C
    tstw %fp@(-204)
    jbpl fpsp_fp0_dst_25E
    movel #-1,%fp@(-84)
    jbra fpsp_fp0_dst_25E
fpsp_fp0_dst_24C:       /* test %fp@(-204) */
    tstw %fp@(-204)
    jbmi fpsp_fp0_dst_25E
    lea %fp@(-84),%a1
    addal %d0,%a1
    subql #1,%a1
    bset #0,%a1@
fpsp_fp0_dst_25E:       /* from here: oril #520,%fp@(-124) */
    oril #520,%fp@(-124)
    jbra fpsp_fp0_dst_276
fpsp_fp0_dst_268:       /* from here: fmovemx %fp0,%fp@(-216) */
    fmovemx %fp0,%fp@(-216)
    oril #8320,%fp@(-124)
fpsp_fp0_dst_276:       /* set %a1 */
    moveal %fp@(12),%a1
    tstl %a1
    jbeq fpsp_fp0_dst_28A
    lea %fp@(-84),%a0
    jbsr INSTALLFPSP_48
    jbra fpsp_fp0_dst_82
fpsp_fp0_dst_28A:       /* set %d1 */
    movel %d0,%d1
    moveal %fp@(-120),%a0
    subl %d0,%d0
    movew %a0@,%d0
    andiw #7,%d0
    cmpil #4,%d1
    jbeq fpsp_fp0_dst_2B0
    cmpil #2,%d1
    jbne fpsp_fp0_dst_2B6
    oril #8,%d0
    jbra fpsp_fp0_dst_2B6
fpsp_fp0_dst_2B0:       /* from here: oril #16,%d0 */
    oril #16,%d0
fpsp_fp0_dst_2B6:       /* set %d1 */
    movel %d0,%d1
    jbsr fpsp_neg_sign_298
    jbra fpsp_fp0_dst_82
fpsp_fp0_dst_2C0:       /* address %fp@(-204) */
    lea %fp@(-204),%a0	| 4088F82A
    bclr #7,%a0@	| 4088F82E
    sne %a0@(2)
    btst #7,%fp@(-232)
    jbne fpsp_fp0_dst_370
    moveq #0,%d0
    jbra fpsp_fp0_dst_334
fpsp_fp0_dst_2DA:       /* address %fp@(-204) */
    lea %fp@(-204),%a0	| 4088F844
    bclr #7,%a0@	| 4088F848
    sne %a0@(2)
    btst #7,%fp@(-232)
    jbne fpsp_fp0_dst_3DA
    movew %a0@,%d0
    lea %pc@(fpsp_get_sman_54),%a1
    cmpw %a1@,%d0
    jblt fpsp_fp0_dst_38E
    cmpw %a1@(2),%d0
    jbgt fpsp_sp_over
    moveq #1,%d0
    jbra fpsp_fp0_dst_334
fpsp_fp0_dst_308:       /* address %fp@(-204) */
    lea %fp@(-204),%a0	| 4088F872
    bclr #7,%a0@	| 4088F876
    sne %a0@(2)
    btst #7,%fp@(-232)
    jbne fpsp_fp0_dst_402
    movew %a0@,%d0
    lea %pc@(fpsp_dp_bnds),%a1
    cmpw %a1@,%d0
    jblt fpsp_fp0_dst_3B4
    cmpw %a1@(2),%d0
    jbgt fpsp_dp_over
    moveq #2,%d0
fpsp_fp0_dst_334:       /* from here: bfextu %fp@(-125),2,2,%d1 */
    bfextu %fp@(-125),2,2,%d1
    swap %d0
    addl %d0,%d1
    moveq #0,%d0
    jbsr fpsp_dp_over_152
    moveal %a0,%a1
    moveal %fp@(12),%a0
    bfextu %fp@(-228),3,3,%d1
    cmpib #2,%d1
    jbgt fpsp_fp0_dst_368
    jbne fpsp_fp0_dst_360
    jbsr fpsp_get_sman_30
    jbra fpsp_fp0_dst_4A
fpsp_fp0_dst_360:       /* call fpsp_get_mant_2A */
    jbsr fpsp_get_mant_2A
    jbra fpsp_fp0_dst_4A
fpsp_fp0_dst_368:       /* call fpsp_pwrten_150 */
    jbsr fpsp_pwrten_150
    jbra fpsp_fp0_dst_4A
fpsp_fp0_dst_370:       /* call fpsp_dp_over_62 */
    jbsr fpsp_dp_over_62
    bset #4,%fp@(-223)
    moveal %a0,%a1
    moveal %fp@(12),%a0
    jbsr fpsp_get_sman_30
    bset #3,%fp@(-122)
    jbra fpsp_fp0_dst_4A
fpsp_fp0_dst_38E:       /* set bit 4 of %fp@(-232) */
    bset #4,%fp@(-232)
    cmpw %a1@(4),%d0
    jble fpsp_fp0_dst_3DA
    moveq #1,%d0
    movel #16257,%d1
    jbsr fpsp_dp_over_38
    jbsr fpsp_get_mant_2A
    bset #3,%fp@(-122)
    jbra fpsp_fp0_dst_4A
fpsp_fp0_dst_3B4:       /* set bit 4 of %fp@(-232) */
    bset #4,%fp@(-232)
    cmpw %a1@(4),%d0
    jble fpsp_fp0_dst_402
    movel #15361,%d1
    moveq #2,%d0
    jbsr fpsp_dp_over_38
    jbsr fpsp_pwrten_150
    bset #3,%fp@(-122)
    jbra fpsp_fp0_dst_4A
fpsp_fp0_dst_3DA:       /* set %sp@- */
    movel %fp@(-124),%sp@-
    moveq #1,%d0
    jbsr fpsp_neg_sign_136
    movel %sp@+,%fp@(-124)
    moveq #1,%d0
    subw %d0,%a0@
    moveal %a0,%a1
    moveal %fp@(12),%a0
    jbsr fpsp_get_mant_2A
    oril #2600,%fp@(-124)
    jbra fpsp_fp0_dst_4A
fpsp_fp0_dst_402:       /* set %sp@- */
    movel %fp@(-124),%sp@-
    moveq #2,%d0
    jbsr fpsp_neg_sign_136
    movel %sp@+,%fp@(-124)
    moveq #1,%d0
    subw %d0,%a0@
    moveal %a0,%a1
    moveal %fp@(12),%a0
    jbsr fpsp_pwrten_150
    oril #2600,%fp@(-124)
    jbra fpsp_fp0_dst_4A
fpsp_sp_over:           /* set %sp@- */
    movel %fp@(-124),%sp@-
    moveq #1,%d0
    lea %fp@(-116),%a0
    movel %fp@(-204),%a0@
    movel %fp@(-200),%a0@(4)
    movel %fp@(-196),%a0@(8)
    jbsr fpsp_sec_d_11E
    movel %sp@+,%fp@(-124)
    moveal %a0,%a1
    moveal %fp@(12),%a0
    jbsr fpsp_get_mant_2A
    oril #4680,%fp@(-124)
    jbra fpsp_fp0_dst_4A
fpsp_dp_over:           /* set %sp@- */
    movel %fp@(-124),%sp@-
    moveq #2,%d0
    lea %fp@(-116),%a0
    movel %fp@(-204),%a0@
    movel %fp@(-200),%a0@(4)
    movel %fp@(-196),%a0@(8)
    jbsr fpsp_sec_d_11E
    movel %sp@+,%fp@(-124)
    moveal %a0,%a1
    moveal %fp@(12),%a0
    jbsr fpsp_pwrten_150
    oril #4680,%fp@(-124)
    jbra fpsp_fp0_dst_4A

fpsp_dp_over_38:        /* set %sp@- */
    movel %d0,%sp@-
    moveq #0,%d0
    jbsr fpsp_lower_A6
    bfextu %fp@(-125),2,2,%d1
    swap %d1
    movew %sp@(2),%d1
    swap %d1
    jbsr fpsp_dp_over_152
    movew #1,%d0
    subw %d0,%a0@
    moveal %a0,%a1
    moveal %fp@(12),%a0
    addqw #4,%sp
    rts

fpsp_dp_over_62:        /* set %fp@(-268) */
    movel %a0@,%fp@(-268)
    movel %a0@(4),%fp@(-264)
    movel %a0@(8),%fp@(-260)
    bfclr %fp@(-266),0,8
    jbeq fpsp_dp_over_62_1E
    bset #7,%fp@(-268)
fpsp_dp_over_62_1E:     /* from here: bfclr %fp@(-232),5,4 */
    bfclr %fp@(-232),5,4
    rts
fpsp_dp_over_88:        /* (data) */
    .short  fpsp_dp_over_CA-fpsp_dp_over_88	| 4088FA54
    .short  fpsp_dp_over_100-fpsp_dp_over_88	| 4088FA56
    .short  fpsp_dp_over_112-fpsp_dp_over_88	| 4088FA58
    .short  fpsp_dp_over_124-fpsp_dp_over_88	| 4088FA5A
    .short  fpsp_dp_over_CA-fpsp_dp_over_88	| 4088FA5C
fpsp_dp_over_92:        /* (data) */
    .short  fpsp_dp_over_124-fpsp_dp_over_88	| 4088FA5E
    .short  0x00A2, 0x00A8, 0x00AC, 0x00B0, 0x00B4, 0x00B8, 0x00BC	| 4088FA60
fpsp_dp_over_A2:        /* address %pc@(fpsp_dp_over_88) */
    lea %pc@(fpsp_dp_over_88),%a0
    movew %fp@(-232),%d0
    bfextu %d0,16,3,%d0
    addaw %a0@(0x0,%d0:w:2),%a0
    jmp %a0@
fpsp_dp_over_B4:        /* loop: movea */
    moveal %fp@(12),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    clrb %fp@(-284)
    bfclr %fp@(-224),0,3
    rts
fpsp_dp_over_CA:        /* set %d0 */
    movew %fp@(-228),%d0	| 4088FA96
    btst #12,%d0	| 4088FA9A
    jbne fpsp_dp_over_DC	| 4088FA9E
    moveal %fp@(-120),%a0	| 4088FAA0
    movel %a0@,%d0	| 4088FAA4
    jbra fpsp_dp_over_EA	| 4088FAA6
fpsp_dp_over_DC:        /* from here: bfextu %d0,25,3,%d0 */
    bfextu %d0,25,3,%d0	| 4088FAA8
    lea %pc@(fpsp_dp_over_92),%a0	| 4088FAAC
    addaw %a0@(0,%d0:w:2),%a0	| 4088FAB0
    jmp %a0@	| 4088FAB4
fpsp_dp_over_EA:        /* loop: andi */
    andiw #127,%d0
    bfexts %d0,25,7,%d0
    lea %fp@(-204),%a0
    jbsr fpsp_bindec
    lea %fp@(-116),%a0
    jbra fpsp_dp_over_B4
fpsp_dp_over_100:       /* address %fp@(-204) */
    lea %fp@(-204),%a0	| 4088FACC
    clrw %a0@(2)	| 4088FAD0
    clrl %a0@(4)	| 4088FAD4
    clrl %a0@(8)	| 4088FAD8
    jbra fpsp_dp_over_B4	| 4088FADC
fpsp_dp_over_112:       /* from here: fmovel #0,%fpsr */
    fmovel #0,%fpsr	| 4088FADE
    lea %fp@(-204),%a0	| 4088FAE6
    clrw %a0@(2)	| 4088FAEA
    jbra fpsp_dp_over_B4	| 4088FAEE
fpsp_dp_over_124:       /* address %fp@(-204) */
    lea %fp@(-204),%a0	| 4088FAF0
    clrw %a0@(2)	| 4088FAF4
    bras fpsp_dp_over_B4
    movel %fp@(-192),%d0
    jbra fpsp_dp_over_EA
    movel %fp@(-188),%d0	| 4088FB00
    jbra fpsp_dp_over_EA	| 4088FB04
    .byte   0x20, 0x02	| 4088FB06
    jbra fpsp_dp_over_EA	| 4088FB08
    .byte   0x20, 0x03	| 4088FB0A
    jbra fpsp_dp_over_EA	| 4088FB0C
    .byte   0x20, 0x04	| 4088FB0E
    jbra fpsp_dp_over_EA	| 4088FB10
    .byte   0x20, 0x05, 0x60, 0xA0, 0x20, 0x06, 0x60, 0x9C, 0x20, 0x07, 0x60, 0x98	| 4088FB12

fpsp_dp_over_152:       /* call fpsp_dp_over_1BC (loop) */
    jbsr fpsp_dp_over_1BC
    tstl %d0
    jbne fpsp_dp_over_152_C
    swap %d1
    jbra fpsp_dp_over_2B8
fpsp_dp_over_152_C:     /* from here: oril #520,%fp@(-124) */
    oril #520,%fp@(-124)
    lea %pc@(fpsp_dp_over_170),%a1
    addaw %a1@(0x0,%d1:w:2),%a1
    jmp %a1@
fpsp_dp_over_170:       /* (data) */
    .short  fpsp_dp_over_1AA-fpsp_dp_over_170	| 4088FB3C
    .short  fpsp_dp_over_1A4-fpsp_dp_over_170	| 4088FB3E
    .short  fpsp_dp_over_18E-fpsp_dp_over_170	| 4088FB40
    .short  fpsp_dp_over_178-fpsp_dp_over_170	| 4088FB42
fpsp_dp_over_178:       /* from here: swap %d1 */
    swap %d1	| 4088FB44
    tstb %a0@(2)	| 4088FB46
    jbmi fpsp_dp_over_2B8	| 4088FB4A
    moveq #-1,%d0	| 4088FB4E
    lea %pc@(fpsp_dp_over_21C),%a1	| 4088FB50
    addaw %a1@(0,%d1:w:2),%a1	| 4088FB54
    jmp %a1@	| 4088FB58
fpsp_dp_over_18E:       /* from here: swap %d1 */
    swap %d1	| 4088FB5A
    tstb %a0@(2)	| 4088FB5C
    jbpl fpsp_dp_over_2B8	| 4088FB60
    moveq #-1,%d0	| 4088FB64
    lea %pc@(fpsp_dp_over_21C),%a1	| 4088FB66
    addaw %a1@(0,%d1:w:2),%a1	| 4088FB6A
    jmp %a1@	| 4088FB6E
fpsp_dp_over_1A4:       /* from here: swap %d1 */
    swap %d1	| 4088FB70
    jbra fpsp_dp_over_2B8	| 4088FB72
fpsp_dp_over_1AA:       /* from here: swap %d1 */
    swap %d1	| 4088FB76
    asll #1,%d0	| 4088FB78
    jbcc fpsp_dp_over_2B8	| 4088FB7A
    lea %pc@(fpsp_dp_over_21C),%a1	| 4088FB7E
    addaw %a1@(0,%d1:w:2),%a1	| 4088FB82
    jmp %a1@	| 4088FB86

fpsp_dp_over_1BC:       /* from here: swap %d1 */
    swap %d1
    cmpiw #0,%d1
    jbne fpsp_dp_over_1BC_A
    jbra fpsp_dp_over_1BC_5C
fpsp_dp_over_1BC_A:     /* save registers */
    moveml %d2-%d3,%sp@-
    cmpiw #1,%d1
    jbne fpsp_dp_over_1BC_36
    bfextu %a0@(4),24,2,%d3
    moveq #30,%d2
    lsll %d2,%d3
    movel %a0@(4),%d2
    andil #63,%d2
    jbne fpsp_dp_over_1BC_52
    tstl %a0@(8)
    jbne fpsp_dp_over_1BC_52
    tstl %d0
    jbne fpsp_dp_over_1BC_52
    jbra fpsp_dp_over_1BC_56
fpsp_dp_over_1BC_36:    /* from here: bfextu %a0@(8),21,2,%d3 */
    bfextu %a0@(8),21,2,%d3
    moveq #30,%d2
    lsll %d2,%d3
    movel %a0@(8),%d2
    andil #511,%d2
    jbne fpsp_dp_over_1BC_52
    tstl %d0
    jbne fpsp_dp_over_1BC_52
    jbra fpsp_dp_over_1BC_56
fpsp_dp_over_1BC_52:    /* set bit 29 of %d3 */
    bset #29,%d3
fpsp_dp_over_1BC_56:    /* set %d0 */
    movel %d3,%d0
    moveml %sp@+,%d2-%d3
fpsp_dp_over_1BC_5C:    /* from here: swap %d1 */
    swap %d1
    rts
fpsp_dp_over_21C:       /* (data) */
    .byte   0x00, 0x34, 0x00, 0x08, 0x00, 0x5E, 0x00, 0x5E, 0x06, 0xA8, 0x00, 0x00, 0x01, 0x00, 0x00, 0x04	| 4088FBE8
    .byte   0x64, 0x0A, 0xE4, 0xE8, 0x00, 0x04, 0xE4, 0xE8, 0x00, 0x06, 0x52, 0x50, 0x4A, 0x80, 0x66, 0x06	| 4088FBF8
    .byte   0x02, 0x68, 0xFE, 0x00, 0x00, 0x06	| 4088FC08
fpsp_dp_over_242:       /* from here: andil #-256,%a0@(4) */
    andil #-256,%a0@(4)	| 4088FC0E
    clrl %a0@(8)	| 4088FC16
    rts	| 4088FC1A
    .byte   0x52, 0xA8, 0x00, 0x08, 0x64, 0x18, 0x52, 0xA8, 0x00, 0x04, 0x64, 0x12, 0xE4, 0xE8, 0x00, 0x04	| 4088FC1C
    .byte   0xE4, 0xE8, 0x00, 0x06, 0xE4, 0xE8, 0x00, 0x08, 0xE4, 0xE8, 0x00, 0x0A, 0x52, 0x50, 0x4A, 0x80	| 4088FC2C
    .byte   0x66, 0x06, 0x02, 0x28, 0x00, 0xFE, 0x00, 0x0B, 0x4E, 0x75, 0x06, 0xA8, 0x00, 0x00, 0x08, 0x00	| 4088FC3C
    .byte   0x00, 0x08, 0x64, 0x18, 0x52, 0xA8, 0x00, 0x04, 0x64, 0x12, 0xE4, 0xE8, 0x00, 0x04, 0xE4, 0xE8	| 4088FC4C
    .byte   0x00, 0x06, 0xE4, 0xE8, 0x00, 0x08, 0xE4, 0xE8, 0x00, 0x0A, 0x52, 0x50, 0x4A, 0x80, 0x66, 0x06	| 4088FC5C
    .byte   0x02, 0x68, 0xF0, 0x00, 0x00, 0x0A	| 4088FC6C
fpsp_dp_over_2A6:       /* from here: andil #-2048,%a0@(8) */
    andil #-2048,%a0@(8)	| 4088FC72
    rts	| 4088FC7A
fpsp_dp_over_2B0:       /* (data) */
    .short  fpsp_dp_over_2C2-fpsp_dp_over_2B0	| 4088FC7C
    .short  fpsp_dp_over_242-fpsp_dp_over_2B0	| 4088FC7E
    .short  fpsp_dp_over_2A6-fpsp_dp_over_2B0	| 4088FC80
    .short  fpsp_dp_over_2A6-fpsp_dp_over_2B0	| 4088FC82
fpsp_dp_over_2B8:       /* address %pc@(fpsp_dp_over_2B0) */
    lea %pc@(fpsp_dp_over_2B0),%a1
    addaw %a1@(0x0,%d1:w:2),%a1
    jmp %a1@
fpsp_dp_over_2C2:       /* return */
    rts	| 4088FC8E

fpsp_dp_over_2C4:       /* set %d0 */
    movew %a0@,%d0
    cmpiw #64,%d0
    jbmi fpsp_dp_over_2D0
    jbsr fpsp_greater_3E
    rts

fpsp_dp_over_2D0:       /* save registers */
    moveml %d2-%d3/%d5-%d6,%sp@-
    movel %a0@(4),%d1
    movel %a0@(8),%d2
    bfffo %d1,0,0,%d3
    jbeq fpsp_greater_20
    cmpw %d3,%d0
    jbmi fpsp_greater
    jbsr fpsp_greater_3E
    moveml %sp@+,%d2-%d3/%d5-%d6
    rts
fpsp_greater:           /* loop: move */
    movel %d2,%d6
    lsll %d0,%d2
    lsll %d0,%d1
    moveq #32,%d5
    subl %d0,%d5
    lsrl %d5,%d6
    orl %d6,%d1
    moveq #0,%d0
    movew %d0,%a0@
    movel %d1,%a0@(4)
    movel %d2,%a0@(8)
    moveml %sp@+,%d2-%d3/%d5-%d6
    rts
fpsp_greater_20:        /* from here: bfffo %d2,0,0,%d3 */
    bfffo %d2,0,0,%d3
    jbeq fpsp_greater_36
    addiw #32,%d3
    cmpw %d3,%d0
    jbmi fpsp_greater
    jbsr fpsp_greater_3E
    moveml %sp@+,%d2-%d3/%d5-%d6
    rts
fpsp_greater_36:        /* clear %a0@ */
    clrw %a0@
    moveml %sp@+,%d2-%d3/%d5-%d6
    rts

fpsp_greater_3E:        /* loop: move */
    movel %d7,%sp@-
    bfffo %a0@(4),0,0,%d7
    jbeq fpsp_lower
    movel %d6,%sp@-
    subw %d7,%a0@
    movel %a0@(4),%d0
    movel %a0@(8),%d1
    lsll %d7,%d0
    movel %d1,%d6
    lsll %d7,%d6
    movel %d6,%a0@(8)
    moveq #32,%d6
    subl %d7,%d6
    lsrl %d6,%d1
    orl %d1,%d0
    movel %d0,%a0@(4)
    moveml %sp@+,%d6-%d7
    rts
fpsp_lower:             /* set %d0 */
    movew %a0@,%d0
    movel %a0@(8),%d1
    subiw #32,%d0
    bfffo %d1,0,0,%d7
    subw %d7,%d0
    lsll %d7,%d1
    movew %d0,%a0@
    movel %d1,%a0@(4)
    clrl %a0@(8)
    movel %sp@+,%d7
    rts

fpsp_lower_20:          /* test bit 6 of %a0@ */
    btst #6,%a0@
    jbeq fpsp_lower_20_A
    bset #7,%a0@
fpsp_lower_20_A:        /* test #0,%d0 */
    cmpib #0,%d0
    jbne fpsp_lower_20_1C
    moveq #0,%d1
    moveq #0,%d0
    jbsr fpsp_lower_A6
    tstb %d1
    jbeq fpsp_lower_20_84
    jbra fpsp_lower_20_7C
fpsp_lower_20_1C:       /* test #1,%d0 */
    cmpil #1,%d0
    jbeq fpsp_lower_20_3C
    movew #15361,%d1
    movel %d1,%d0
    subw %a0@,%d0
    cmpiw #67,%d0
    jbpl fpsp_lower_20_54
    moveq #0,%d0
    jbsr fpsp_lower_A6
    tstb %d1
    jbeq fpsp_lower_20_84
    jbra fpsp_lower_20_7C
fpsp_lower_20_3C:       /* set %d1 */
    movew #16257,%d1
    movel %d1,%d0
    subw %a0@,%d0
    cmpiw #67,%d0
    jbpl fpsp_lower_20_54
    moveq #0,%d0
    jbsr fpsp_lower_A6
    tstb %d1
    jbeq fpsp_lower_20_84
    jbra fpsp_lower_20_7C
fpsp_lower_20_54:       /* test %a0@(4) */
    tstl %a0@(4)
    jbne fpsp_lower_20_62
    tstl %a0@(8)
    jbne fpsp_lower_20_62
    jbra fpsp_lower_20_70
fpsp_lower_20_62:       /* from here: oril #520,%fp@(-124) */
    oril #520,%fp@(-124)
    movel #536870912,%d0
fpsp_lower_20_70:       /* set %a0@ */
    movew %d1,%a0@
    clrl %a0@(4)
    clrl %a0@(8)
    rts
fpsp_lower_20_7C:       /* from here: oril #520,%fp@(-124) */
    oril #520,%fp@(-124)
fpsp_lower_20_84:       /* return */
    rts

fpsp_lower_A6:          /* loop: move */
    movel %a0@(8),%fp@(-8)
    moveq #0,%d0
    btst #1,%fp@(-220)
    jbeq fpsp_lower_A6_1C
    movel %fp@(-232),%d0
    lsll #6,%d0
    andil #-536870912,%d0
fpsp_lower_A6_1C:       /* set %fp@(-4) */
    movel %d0,%fp@(-4)
    movel %d1,%d0
    subw %a0@,%d1
    jbeq fpsp_lower_A6_36
    cmpiw #32,%d1
    jblt fpsp_lower_E4
    cmpiw #64,%d1
    jblt fpsp_grs_clear_A
    jbra fpsp_grs_clear_56
fpsp_lower_A6_36:       /* clear %d1 */
    clrb %d1
    movel %fp@(-4),%d0
    rts

fpsp_lower_E4:          /* set %sp@- */
    movel %d2,%sp@-
    movew %d0,%a0@
    moveq #32,%d0
    subw %d1,%d0
    bfextu %a0@(4),%d0,0,%d2
    movel %d2,%a0@(8)
    bfextu %a0@(4),0,%d0,%d2
    movel %d2,%a0@(4)
    bfextu %fp@(-4),%d0,%d1,%d2
    bfextu %fp@(-8),%d0,0,%d0
    tstl %d2
    jbeq fpsp_lower_E4_2E
    st %d0
fpsp_lower_E4_2E:       /* clear %d1 */
    clrb %d1
    bftst %d0,2,30
    jbeq fpsp_grs_clear
    bset #29,%d0
    st %d1
fpsp_grs_clear:         /* from here: andil #-536870912,%d0 */
    andil #-536870912,%d0
    movel %sp@+,%d2
    rts

fpsp_grs_clear_A:       /* set %sp@- */
    movel %d2,%sp@-
    movew %d0,%a0@
    subiw #32,%d1
    moveq #32,%d0
    subw %d1,%d0
    bfextu %a0@(4),0,%d0,%d2
    bfextu %a0@(4),%d0,0,%d1
    bftst %d1,2,30
    jbne fpsp_grs_clear_A_32
    bftst %fp@(-8),%d0,0
    jbne fpsp_grs_clear_A_32
    tstl %fp@(-4)
    jbne fpsp_grs_clear_A_32
    movel %d1,%d0
    clrb %d1
    jbra fpsp_grs_clear_A_3A
fpsp_grs_clear_A_32:    /* set %d0 */
    movel %d1,%d0
    bset #29,%d0
    st %d1
fpsp_grs_clear_A_3A:    /* clear %a0@(4) */
    clrl %a0@(4)
    movel %d2,%a0@(8)
    andil #-536870912,%d0
    movel %sp@+,%d2
    rts

fpsp_grs_clear_56:      /* set %a0@ */
    movew %d0,%a0@
    tstw %a0@(2)
    jbge fpsp_grs_clear_56_E
    oril #-2147483648,%a0@
fpsp_grs_clear_56_E:    /* test #64,%d1 */
    cmpiw #64,%d1
    jbeq fpsp_grs_clear_56_2C
    cmpiw #65,%d1
    jbeq fpsp_grs_clear_56_3C
    clrl %a0@(4)
    clrl %a0@(8)
    movel #536870912,%d0
    st %d1
    rts
fpsp_grs_clear_56_2C:   /* set %d0 */
    movel %a0@(4),%d0
    bfextu %d0,2,30,%d1
    andil #-1073741824,%d0
    jbra fpsp_grs_clear_56_4C
fpsp_grs_clear_56_3C:   /* set %d0 */
    movel %a0@(4),%d0
    bfextu %d0,1,31,%d1
    andil #-2147483648,%d0
    lsrl #1,%d0
fpsp_grs_clear_56_4C:   /* test %d1 */
    tstl %d1
    jbne fpsp_grs_clear_56_60
    tstl %a0@(8)
    jbne fpsp_grs_clear_56_60
    tstb %fp@(-4)
    jbne fpsp_grs_clear_56_60
    clrb %d1
    jbra fpsp_grs_clear_56_66
fpsp_grs_clear_56_60:   /* set bit 29 of %d0 */
    bset #29,%d0
    st %d1
fpsp_grs_clear_56_66:   /* clear %a0@(4) */
    clrl %a0@(4)
    clrl %a0@(8)
    rts
fpsp_grs_clear_C6:      /* (data) */
    .long   0x3FFD0000, 0x9A209A84, 0xFBCFF798, 0x00000000	| 4088FF10
fpsp_LOG2UP1:           /* constant(s) LOG2UP1 */
    .long   0x3FFD0000, 0x9A209A84, 0xFBCFF799, 0x00000000	| 4088FF20
fpsp_RBDTBL:            /* constant(s) RBDTBL */
    .long   0x00000000, 0x03030202, 0x03020203, 0x02030302	| 4088FF30

/* fpsp_bindec: convert extended binary to packed decimal (FMOVE to memory, k-factor). */
fpsp_bindec:
    moveml %d2-%d7/%a2,%sp@-
    fmovemx %fp0-%fp2,%sp@-
    fmovel #32,%fpcr
    movel %a0@,%fp@(-80)
    movel %d0,%d7
    clrb %fp@(-75)
    movew %fp@(-232),%d0
    andiw #-8192,%d0
    jbeq fpsp_pos_exp_E
fpsp_un_de_norm:        /* set %d0 */
    movew %a0@,%d0
    andiw #32767,%d0
    movel %a0@(4),%d1
    movel %a0@(8),%d2
fpsp_bindec_32:         /* loop: subq */
    subqw #1,%d0
    lsll #1,%d2
    roxll #1,%d1
    tstl %d1
    jbge fpsp_bindec_32
    tstw %d0
    jbgt fpsp_pos_exp
    st %fp@(-75)
fpsp_pos_exp:           /* from here: andiw #32767,%d0 */
    andiw #32767,%d0
    movew %d0,%a0@
    movel %d1,%a0@(4)
    movel %d2,%a0@(8)
fpsp_pos_exp_E:         /* set %fp@(-100) */
    movel %a0@,%fp@(-100)
    movel %a0@(4),%fp@(-96)
    movel %a0@(8),%fp@(-92)
    andil #2147483647,%fp@(-100)
    tstb %fp@(-75)
    jbeq fpsp_pos_exp_34
    movel #-4933,%d6
    jbra fpsp_pos_exp_6C
fpsp_pos_exp_34:        /* set %d0 */
    movew %fp@(-100),%d0
    movew #16383,%fp@(-100)
    fmovex %fp@(-100),%fp0
    subiw #16383,%d0
    faddw %d0,%fp0
    fsubb #1,%fp0
    fbge fpsp_pos_exp_62
    fmulx %pc@(fpsp_LOG2UP1),%fp0
    fmovel %fp0,%d6
    jbra fpsp_pos_exp_6C
fpsp_pos_exp_62:        /* from here: fmulx %pc@(fpsp_grs_clear_C6),%fp0 */
    fmulx %pc@(fpsp_grs_clear_C6),%fp0
    fmovel %fp0,%d6
fpsp_pos_exp_6C:        /* from here: fmovel #0,%fpsr */
    fmovel #0,%fpsr
    clrw %d5
fpsp_pos_exp_76:        /* loop: tst */
    tstl %d7
    jble fpsp_pos_exp_7E
    movel %d7,%d4

fpsp_pos_exp_7C:        /* continue at fpsp_pos_exp_84 */
    jbra fpsp_pos_exp_84
fpsp_pos_exp_7E:        /* set %d4 */
    movel %d6,%d4
    subl %d7,%d4
    addql #1,%d4
fpsp_pos_exp_84:        /* test %d4 */
    tstl %d4
    jble fpsp_pos_exp_A0
    cmpil #17,%d4
    jble fpsp_pos_exp_A2
    moveq #17,%d4
    tstl %d7
    jble fpsp_pos_exp_A2
    oril #8320,%fp@(-124)
    jbra fpsp_pos_exp_A2
fpsp_pos_exp_A0:        /* set %d4 */
    moveq #1,%d4
fpsp_pos_exp_A2:        /* test %d7 */
    tstl %d7
    jbgt fpsp_k_pos
    cmpl %d6,%d7
    jblt fpsp_k_pos
    movel %d7,%d6
fpsp_k_pos:             /* set %d0 */
    movel %d6,%d0
    addql #1,%d0
    subl %d4,%d0
    swap %d5
    clrw %d5
    clrw %d2
    tstl %d0
    jbge fpsp_k_pos_24
    addqw #1,%d5
    cmpil #-4908,%d0
    jbgt fpsp_k_pos_22
    addil #24,%d0
    moveq #24,%d2
fpsp_k_pos_22:          /* from here: negl %d0 */
    negl %d0
fpsp_k_pos_24:          /* from here: fmoveb #1,%fp1 */
    fmoveb #1,%fp1
    bfextu %fp@(-128),26,2,%d1
    lslw #1,%d1
    addw %d5,%d1
    lslw #1,%d1
    tstl %fp@(-80)
    jbge fpsp_k_pos_3E
    addql #1,%d1
fpsp_k_pos_3E:          /* address %pc@(fpsp_RBDTBL) */
    lea %pc@(fpsp_RBDTBL),%a2
    moveb %a2@(0x0,%d1:w),%d3
    lsll #4,%d3
    fmovel %d3,%fpcr
    lsrl #4,%d3
    tstb %d3
    jbne fpsp_k_pos_58
    lea %pc@(fpsp_SMALRP_60),%a1
    jbra fpsp_k_pos_66
fpsp_k_pos_58:          /* from here: lsrb #1,%d3 */
    lsrb #1,%d3
    jbcc fpsp_k_pos_62
    lea %pc@(fpsp_BIGRZRM_E4),%a1
    jbra fpsp_k_pos_66
fpsp_k_pos_62:          /* address %pc@(fpsp_BIGRZRM_24) */
    lea %pc@(fpsp_BIGRZRM_24),%a1
fpsp_k_pos_66:          /* clear %d3 */
    moveq #0,%d3
fpsp_k_pos_68:          /* loop: lsr */
    lsrl #1,%d0
    jbcc fpsp_k_pos_72
    fmulx %a1@(0x0,%d3:w),%fp1
fpsp_k_pos_72:          /* from here: addil #12,%d3 */
    addil #12,%d3
    tstl %d0
    jbne fpsp_k_pos_68
    fmovel #0,%fpsr
    fmovel #16,%fpcr
    fmovex %a0@,%fp0
    fabsx %fp0,%fp0
    tstw %d5
    jbne fpsp_k_pos_9E
    fdivx %fp1,%fp0
    jbra fpsp_k_pos_FA
fpsp_k_pos_9E:          /* test %fp@(-75) */
    tstb %fp@(-75)
    jbeq fpsp_k_pos_E6
    fmovemx %fp1,%sp@-
    movel %a0@(8),%sp@-
    movel %a0@(4),%sp@-
    movel %a0@,%sp@-
    moveq #18,%d3
fpsp_k_pos_B4:          /* loop: clr */
    clrl %sp@-
    dbf %d3,fpsp_k_pos_B4
    moveb %fp@(-69),%sp@
    moveb #96,%sp@(1)
    moveb #16,%sp@(68)
    movew #35,%sp@(64)
    moveb #0xfe,%sp@(8)
    frestore %sp@+
    fmulx %a1@(36),%fp0
    fmulx %a1@(48),%fp0
    jbra fpsp_k_pos_FA
fpsp_k_pos_E6:          /* test %d2 */
    tstw %d2
    jbeq fpsp_k_pos_F6
    fmulx %a1@(36),%fp0
    fmulx %a1@(48),%fp0
fpsp_k_pos_F6:          /* from here: fmulx %fp1,%fp0 */
    fmulx %fp1,%fp0
fpsp_k_pos_FA:          /* from here: fmovel %fpsr,%d0 */
    fmovel %fpsr,%d0
    fmovex %fp0,%fp@(-100)
    lea %fp@(-100),%a2
    btst #9,%d0
    jbeq fpsp_A11_st
    oril #1,%a2@(8)
    fmovex %fp@(-100),%fp0
fpsp_A11_st:            /* set %fp@(-84) */
    movel %fp@(-128),%fp@(-84)
    andil #48,%fp@(-128)
fpsp_A12_st:            /* save registers */
    moveml %d0-%d1/%a0-%a1,%sp@-
    movel %fp@(-84),%sp@-
    movel %fp@(-80),%sp@-
    lea %fp@(-100),%a0
    fmovex %fp0,%a0@
    tstl %fp@(-80)
    jbge fpsp_A11_st_2E
    oril #-2147483648,%a0@
fpsp_A11_st_2E:         /* set %sp@- */
    movel %fp@(-124),%sp@-
    jbsr fpsp_upper_70
    moveb %sp@,%fp@(-124)
    addql #4,%sp
    movel %sp@+,%fp@(-80)
    movel %sp@+,%fp@(-84)
    moveml %sp@+,%d0-%d1/%a0-%a1
    movel %fp@(-80),%fp@(-100)
    movel %fp@(-84),%fp@(-128)
    swap %d5
    tstw %d5
    bnew fpsp_A11_st_DA
    fmoveb #1,%fp2
    movel %d4,%d0
    subql #1,%d0
    moveq #0,%d3
fpsp_A11_st_68:         /* loop: lsr */
    lsrl #1,%d0
    jbcc fpsp_A11_st_72
    fmulx %a1@(0x0,%d3:w),%fp2
fpsp_A11_st_72:         /* from here: addil #12,%d3 */
    addil #12,%d3
    tstl %d0
    jbne fpsp_A11_st_68
    tstb %fp@(-75)
    jbeq fpsp_A11_st_88
    fabsx %fp0,%fp0
    jbra fpsp_A11_st_AC
fpsp_A11_st_88:         /* from here: fabsx %fp0,%fp0 */
    fabsx %fp0,%fp0
    fcmpx %fp2,%fp0
    fbge fpsp_A11_st_AC
    subql #1,%d6
    movew #1,%d5
    fmovel #32,%fpcr
    fmulb #10,%fp2
    jbra fpsp_pos_exp_76
fpsp_A11_st_AC:         /* from here: fmulb #10,%fp2 */
    fmulb #10,%fp2
    fcmpx %fp2,%fp0
    fblt fpsp_A14_st
    fbgt fpsp_A11_st_C8
    fdivb #10,%fp0
    addql #1,%d6
    jbra fpsp_A14_st
fpsp_A11_st_C8:         /* add 1 to %d6 */
    addql #1,%d6
    movew #1,%d5
    fmovel #32,%fpcr
    jbra fpsp_pos_exp_76
fpsp_A11_st_DA:         /* from here: fmoveb #1,%fp2 */
    fmoveb #1,%fp2
    movel %d4,%d0
    moveq #0,%d3
fpsp_A11_st_E4:         /* loop: lsr */
    lsrl #1,%d0
    jbcc fpsp_A11_st_EE
    fmulx %a1@(0x0,%d3:w),%fp2
fpsp_A11_st_EE:         /* from here: addil #12,%d3 */
    addil #12,%d3
    tstl %d0
    jbne fpsp_A11_st_E4
    fabsx %fp0,%fp0
    fcmpx %fp2,%fp0
    fbne fpsp_A14_st
    fdivb #10,%fp0
    addql #1,%d6
    addql #1,%d4
    fmulb #10,%fp2
fpsp_A14_st:            /* from here: fmovel #16,%fpcr */
    fmovel #16,%fpcr
    fdivx %fp2,%fp0
    lea %fp@(-116),%a0
    fmovex %fp0,%a0@
    movel %a0@(4),%d2
    movel %a0@(8),%d3
    clrl %a0@(4)
    clrl %a0@(8)
    movel %a0@,%d0
    swap %d0
    jbeq fpsp_A14_st_3E
    subil #16381,%d0
    tstl %d0
    jbgt fpsp_A14_st_3E
    negl %d0
fpsp_A14_st_36:         /* loop: lsr */
    lsrl #1,%d2
    roxrl #1,%d3
    dbf %d0,fpsp_A14_st_36
fpsp_A14_st_3E:         /* test %d2 */
    tstl %d2
    jbne fpsp_A14_st_46
    tstl %d3
    jbeq fpsp_A14_st_56
fpsp_A14_st_46:         /* clear %d1 */
    moveq #0,%d1
    addil #128,%d3
    addxl %d1,%d2
    andil #-128,%d3
fpsp_A14_st_56:         /* set %d0 */
    movel %d4,%d0
    addql #3,%a0
    jbsr fpsp_binstr
    tstb %fp@(-75)
    jbeq fpsp_A14_st_8C
    ftstx %fp0
    fbeq fpsp_A14_st_76
    fmovel %d6,%fp0
    fabsx %fp0,%fp0
    jbra fpsp_not_zero_8
fpsp_A14_st_76:         /* test %d7 */
    tstl %d7
    jblt fpsp_A14_st_82
    fmovew #4933,%fp0
    jbra fpsp_not_zero_8
fpsp_A14_st_82:         /* from here: fmovel %d6,%fp0 */
    fmovel %d6,%fp0
    fabsx %fp0,%fp0
    jbra fpsp_not_zero_8
fpsp_A14_st_8C:         /* from here: ftstx %fp0 */
    ftstx %fp0
    fbne fpsp_not_zero
    fmoveb #1,%fp0
    jbra fpsp_not_zero_8
fpsp_not_zero:          /* from here: fmovel %d6,%fp0 */
    fmovel %d6,%fp0
    fabsx %fp0,%fp0
fpsp_not_zero_8:        /* from here: fdivx %a1@(24),%fp0 */
    fdivx %a1@(24),%fp0
    fmovex %fp0,%fp@(-100)
    movel %a2@(4),%d2
    movel %a2@(8),%d3
    movew %a2@,%d0
    jbeq fpsp_not_zero_2E
    subiw #16381,%d0
    negw %d0
fpsp_not_zero_26:       /* loop: lsr */
    lsrl #1,%d2
    roxrl #1,%d3
    dbf %d0,fpsp_not_zero_26
fpsp_not_zero_2E:       /* clear %d1 */
    moveq #0,%d1
    addil #128,%d3
    addxl %d1,%d2
    andil #-128,%d3
    moveq #4,%d0
    lea %fp@(-84),%a0
    jbsr fpsp_binstr
    movel %fp@(-84),%d0
    moveq #12,%d1
    lsrl %d1,%d0
    bfins %d0,%fp@(-116),4,12
    lsrl %d1,%d0
    bfins %d0,%fp@(-116),16,4
    tstb %d0
    jbeq fpsp_not_zero_68
    oril #8320,%fp@(-124)
fpsp_not_zero_68:       /* clear %d0 */
    moveq #0,%d0
    andib #15,%fp@(-116)
    tstl %fp@(-80)
    jbge fpsp_not_zero_78
    moveq #2,%d0
fpsp_not_zero_78:       /* test %d6 */
    tstl %d6
    jbge fpsp_not_zero_7E
    addql #1,%d0
fpsp_not_zero_7E:       /* from here: bfins %d0,%fp@(-116),0,2 */
    bfins %d0,%fp@(-116),0,2
    fmovel #0,%fpsr
    fmovemx %sp@+,%fp0-%fp2
    moveml %sp@+,%d2-%d7/%a2
    rts

/* fpsp_binstr: binary to decimal digit string. */
fpsp_binstr:
    moveml %d0-%d7,%sp@-
    moveq #1,%d7
    subql #1,%d0
fpsp_loop:              /* loop: move */
    movel %d2,%d4
    movel %d3,%d5
    bfextu %d2,0,3,%d1
    asll #3,%d2
    bfextu %d3,0,3,%d6
    asll #3,%d3
    orl %d6,%d2
    asll #1,%d5
    roxll #1,%d4
    swap %d6
    addxw %d6,%d1
    addl %d5,%d3
    nop
    addxl %d4,%d2
    nop
    addxw %d6,%d1
    swap %d6
    tstw %d7
    jbeq fpsp_loop_3C
fpsp_sec_d:             /* from here: swap %d7 */
    swap %d7
    aslw #4,%d7
    addw %d1,%d7
    moveb %d7,%a0@+
    swap %d7
    clrw %d7
    dbf %d0,fpsp_loop
    jbra fpsp_loop_4E
fpsp_loop_3C:           /* from here: swap %d7 */
    swap %d7
    movew %d1,%d7
    swap %d7
    addqw #1,%d7
    dbf %d0,fpsp_loop
    swap %d7
    lslw #4,%d7
    moveb %d7,%a0@+
fpsp_loop_4E:           /* restore registers, return */
    moveml %sp@+,%d0-%d7
    rts
    .short  0x0000	| 408903EE
fpsp_loop_56:           /* (data) */
    .long   0x7FFF0000, 0x00000000, 0x00000000, 0x00000000	| 408903F0
fpsp_loop_66:           /* (data) */
    .long   0x7FFE0000, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000	| 40890400
fpsp_loop_76:           /* (data) */
    .long   0x407E0000, 0xFFFFFF00, 0x00000000, 0x00000000	| 40890410
fpsp_loop_86:           /* (data) */
    .long   0x43FE0000, 0xFFFFFFFF, 0xFFFFF800, 0x00000000	| 40890420
fpsp_sec_d_6C:          /* (data) */
    .short  fpsp_sec_d_132-fpsp_sec_d_6C	| 40890430
    .short  fpsp_sec_d_140-fpsp_sec_d_6C	| 40890432
    .short  fpsp_sec_d_148-fpsp_sec_d_6C	| 40890434
    .short  fpsp_sec_d_166-fpsp_sec_d_6C	| 40890436
    .short  fpsp_sec_d_1D6-fpsp_sec_d_6C	| 40890438
    .short  fpsp_sec_d_1E2-fpsp_sec_d_6C	| 4089043A
    .short  fpsp_sec_d_1E8-fpsp_sec_d_6C	| 4089043C
    .short  fpsp_sec_d_202-fpsp_sec_d_6C	| 4089043E
    .short  fpsp_sec_d_188-fpsp_sec_d_6C	| 40890440
    .short  fpsp_sec_d_196-fpsp_sec_d_6C	| 40890442
    .short  fpsp_sec_d_19E-fpsp_sec_d_6C	| 40890444
    .short  fpsp_sec_d_1B8-fpsp_sec_d_6C	| 40890446
    .short  fpsp_neg_sign_16-fpsp_sec_d_6C	| 40890448
    .short  fpsp_neg_sign_16-fpsp_sec_d_6C	| 4089044A
    .short  fpsp_neg_sign_16-fpsp_sec_d_6C	| 4089044C
    .short  fpsp_neg_sign_16-fpsp_sec_d_6C	| 4089044E
fpsp_sec_d_8C:          /* loop: lea */
    lea %fp@(-204),%a0
    bclr #7,%fp@(-204)
    sne %fp@(-202)
    tstb %fp@(-71)
    jbeq fpsp_sec_d_8C_2A
    btst #6,%fp@(-227)
    jbeq fpsp_sec_d_8C_2A
    moveq #1,%d0
    btst #2,%fp@(-227)
    jbeq fpsp_sec_d_11E
    addql #1,%d0
    jbra fpsp_sec_d_11E
fpsp_sec_d_8C_2A:       /* from here: bfextu %fp@(-125),0,2,%d0 */
    bfextu %fp@(-125),0,2,%d0
    jbra fpsp_sec_d_11E

fpsp_sec_d_BE:          /* test bit 1 of %fp@(-220) */
    btst #1,%fp@(-220)
    jbeq fpsp_sec_d_BE_34
    movew %fp@(-240),%d0
    andiw #127,%d0
    btst #6,%d0
    jbeq fpsp_sec_d_BE_24
    btst #5,%d0
    jbeq fpsp_sec_d_BE_20
    moveq #2,%d0
    jbra fpsp_sec_d_11E
fpsp_sec_d_BE_20:       /* result 1 */
    moveq #1,%d0
    jbra fpsp_sec_d_11E
fpsp_sec_d_BE_24:       /* test #48,%d0 */
    cmpiw #48,%d0
    jbeq fpsp_sec_d_BE_30
    cmpiw #51,%d0
    jbne fpsp_sec_d_BE_54
fpsp_sec_d_BE_30:       /* result 0 */
    moveq #0,%d0
    jbra fpsp_sec_d_11E
fpsp_sec_d_BE_34:       /* set %d0 */
    movew %fp@(-228),%d0
    andil #68,%d0
    btst #6,%d0
    jbeq fpsp_sec_d_BE_54
    addql #1,%d0
    btst #2,%d0
    jbeq fpsp_sec_d_BE_4E
    addql #1,%d0
fpsp_sec_d_BE_4E:       /* from here: andib #3,%d0 */
    andib #3,%d0
    jbra fpsp_sec_d_11E
fpsp_sec_d_BE_54:       /* from here: bfextu %fp@(-125),0,2,%d0 */
    bfextu %fp@(-125),0,2,%d0
    jbra fpsp_sec_d_11E

fpsp_sec_d_11A:         /* call fpsp_neg_sign_8A */
    jbsr fpsp_neg_sign_8A

fpsp_sec_d_11E:         /* from here: lsll #2,%d0 */
    lsll #2,%d0
    bfextu %fp@(-125),2,2,%d1
    orl %d1,%d0
    lea %pc@(fpsp_sec_d_6C),%a1
    addaw %a1@(0x0,%d0:w:2),%a1
    jmp %a1@
fpsp_sec_d_132:         /* address %pc@(fpsp_loop_56) */
    lea %pc@(fpsp_loop_56),%a1	| 408904F6
    bset #1,%fp@(-124)	| 408904FA
    jbra fpsp_sec_d_220	| 40890500
fpsp_sec_d_140:         /* address %pc@(fpsp_loop_66) */
    lea %pc@(fpsp_loop_66),%a1	| 40890504
    jbra fpsp_sec_d_220	| 40890508
fpsp_sec_d_148:         /* test %a0@(2) */
    tstb %a0@(2)	| 4089050C
    jbeq fpsp_sec_d_15E	| 40890510
    lea %pc@(fpsp_loop_56),%a1	| 40890512
    oril #167772160,%fp@(-124)	| 40890516
    jbra fpsp_neg_sign_6	| 4089051E
fpsp_sec_d_15E:         /* address %pc@(fpsp_loop_66) */
    lea %pc@(fpsp_loop_66),%a1	| 40890522
    jbra fpsp_neg_sign_6	| 40890526
fpsp_sec_d_166:         /* test %a0@(2) */
    tstb %a0@(2)	| 4089052A
    jbeq fpsp_sec_d_17A	| 4089052E
    lea %pc@(fpsp_loop_66),%a1	| 40890530
    bset #3,%fp@(-124)	| 40890534
    jbra fpsp_neg_sign_6	| 4089053A
fpsp_sec_d_17A:         /* address %pc@(fpsp_loop_56) */
    lea %pc@(fpsp_loop_56),%a1	| 4089053E
    bset #1,%fp@(-124)	| 40890542
    jbra fpsp_neg_sign_6	| 40890548
fpsp_sec_d_188:         /* address %pc@(fpsp_loop_56) */
    lea %pc@(fpsp_loop_56),%a1	| 4089054C
    bset #1,%fp@(-124)	| 40890550
    jbra fpsp_sec_d_220	| 40890556
fpsp_sec_d_196:         /* address %pc@(fpsp_loop_86) */
    lea %pc@(fpsp_loop_86),%a1	| 4089055A
    jbra fpsp_sec_d_220	| 4089055E
fpsp_sec_d_19E:         /* test %a0@(2) */
    tstb %a0@(2)	| 40890562
    jbeq fpsp_sec_d_1B2	| 40890566
    lea %pc@(fpsp_loop_56),%a1	| 40890568
    oril #167772160,%fp@(-124)	| 4089056C
    jbra fpsp_neg_sign_6	| 40890574
fpsp_sec_d_1B2:         /* address %pc@(fpsp_loop_86) */
    lea %pc@(fpsp_loop_86),%a1	| 40890576
    jbra fpsp_neg_sign_6	| 4089057A
fpsp_sec_d_1B8:         /* test %a0@(2) */
    tstb %a0@(2)	| 4089057C
    jbeq fpsp_sec_d_1CA	| 40890580
    lea %pc@(fpsp_loop_86),%a1	| 40890582
    bset #3,%fp@(-124)	| 40890586
    jbra fpsp_neg_sign_6	| 4089058C
fpsp_sec_d_1CA:         /* address %pc@(fpsp_loop_56) */
    lea %pc@(fpsp_loop_56),%a1	| 4089058E
    bset #1,%fp@(-124)	| 40890592
    jbra fpsp_neg_sign_6	| 40890598
fpsp_sec_d_1D6:         /* address %pc@(fpsp_loop_56) */
    lea %pc@(fpsp_loop_56),%a1	| 4089059A
    bset #1,%fp@(-124)	| 4089059E
    jbra fpsp_sec_d_220	| 408905A4
fpsp_sec_d_1E2:         /* address %pc@(fpsp_loop_76) */
    lea %pc@(fpsp_loop_76),%a1	| 408905A6
    jbra fpsp_sec_d_220	| 408905AA
fpsp_sec_d_1E8:         /* test %a0@(2) */
    tstb %a0@(2)	| 408905AC
    jbeq fpsp_sec_d_1FC	| 408905B0
    lea %pc@(fpsp_loop_56),%a1	| 408905B2
    oril #167772160,%fp@(-124)	| 408905B6
    jbra fpsp_neg_sign_6	| 408905BE
fpsp_sec_d_1FC:         /* address %pc@(fpsp_loop_76) */
    lea %pc@(fpsp_loop_76),%a1	| 408905C0
    jbra fpsp_neg_sign_6	| 408905C4
fpsp_sec_d_202:         /* test %a0@(2) */
    tstb %a0@(2)	| 408905C6
    jbeq fpsp_sec_d_214	| 408905CA
    lea %pc@(fpsp_loop_76),%a1	| 408905CC
    bset #3,%fp@(-124)	| 408905D0
    jbra fpsp_neg_sign_6	| 408905D6
fpsp_sec_d_214:         /* address %pc@(fpsp_loop_56) */
    lea %pc@(fpsp_loop_56),%a1	| 408905D8
    bset #1,%fp@(-124)	| 408905DC
    jbra fpsp_neg_sign_6	| 408905E2
fpsp_sec_d_220:         /* test %a0@(2) */
    tstb %a0@(2)	| 408905E4
    jbeq fpsp_neg_sign_6	| 408905E8
fpsp_neg_sign:          /* (data) */
    bset #3,%fp@(-124)	| 408905EA
fpsp_neg_sign_6:        /* set %a0@ */
    movew %a1@,%a0@	| 408905F0
    movel %a1@(4),%a0@(4)	| 408905F2
    movel %a1@(8),%a0@(8)	| 408905F8
    rts	| 408905FE
fpsp_neg_sign_16:       /* return */
    rts	| 40890600

fpsp_neg_sign_18:       /* call fpsp_neg_sign_74 */
    jbsr fpsp_neg_sign_74
    cmpiw #3,%d0
    jbne fpsp_neg_sign_18_C
    jbsr fpsp_neg_sign_8A
    rts
fpsp_neg_sign_18_C:     /* test bit 1 of %fp@(-220) */
    btst #1,%fp@(-220)
    jbeq fpsp_neg_sign_18_32
    movel %fp@(-240),%d0
    bfextu %d0,9,2,%d0
    btst #1,%d0
    jbeq fpsp_neg_sign_18_52
    cmpil #2,%d0
    jbeq fpsp_neg_sign_18_2E
    moveq #2,%d0
    rts
fpsp_neg_sign_18_2E:    /* result 1 */
    moveq #1,%d0
    rts
fpsp_neg_sign_18_32:    /* set %d0 */
    movew %fp@(-228),%d0
    andil #68,%d0
    btst #6,%d0
    jbeq fpsp_neg_sign_18_52
    addql #1,%d0
    btst #2,%d0
    jbeq fpsp_neg_sign_18_4C
    addql #1,%d0
fpsp_neg_sign_18_4C:    /* from here: andib #3,%d0 */
    andib #3,%d0
    rts
fpsp_neg_sign_18_52:    /* set %d0 */
    movel %fp@(-128),%d0
    bfextu %d0,24,2,%d0
    rts

fpsp_neg_sign_74:       /* test bit 1 of %fp@(-220) */
    btst #1,%fp@(-220)
    jbeq fpsp_neg_sign_74_C
    moveq #0,%d0
    rts
fpsp_neg_sign_74_C:     /* set %d0 */
    movel %fp@(-228),%d0
    bfextu %d0,0,3,%d0
    rts

fpsp_neg_sign_8A:       /* test bit 1 of %fp@(-220) */
    btst #1,%fp@(-220)
    jbeq fpsp_neg_sign_8A_C
    moveq #0,%d0
    rts
fpsp_neg_sign_8A_C:     /* set %d0 */
    movel %fp@(-228),%d0
    bfextu %d0,3,3,%d0
    cmpib #1,%d0
    jbne fpsp_neg_sign_8A_1E
    moveq #1,%d0
    rts
fpsp_neg_sign_8A_1E:    /* test #5,%d0 */
    cmpib #5,%d0
    jbne fpsp_neg_sign_8A_28
    moveq #2,%d0
    rts
fpsp_neg_sign_8A_28:    /* result 0 */
    moveq #0,%d0
    rts
fpsp_neg_sign_B6:       /* (data) */
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408906A0
fpsp_neg_sign_C6:       /* (data) */
    .long   0x3F810000, 0x00000000, 0x00000000, 0x00000000	| 408906B0
fpsp_neg_sign_D6:       /* (data) */
    .long   0x3C010000, 0x00000000, 0x00000000, 0x00000000	| 408906C0
fpsp_neg_sign_E6:       /* (data) */
    .long   0x00000000, 0x00000000, 0x00000001, 0x00000000	| 408906D0
fpsp_neg_sign_F6:       /* (data) */
    .long   0x3F810000, 0x00000100, 0x00000000, 0x00000000	| 408906E0
fpsp_neg_sign_106:      /* (data) */
    .long   0x3C010000, 0x00000000, 0x00000800, 0x00000000	| 408906F0
fpsp_neg_sign_116:      /* (data) */
    .short  fpsp_neg_sign_14A-fpsp_neg_sign_116	| 40890700
    .short  fpsp_neg_sign_158-fpsp_neg_sign_116	| 40890702
    .short  fpsp_neg_sign_166-fpsp_neg_sign_116	| 40890704
    .short  fpsp_neg_sign_188-fpsp_neg_sign_116	| 40890706
    .short  fpsp_neg_sign_1FC-fpsp_neg_sign_116	| 40890708
    .short  fpsp_neg_sign_208-fpsp_neg_sign_116	| 4089070A
    .short  fpsp_neg_sign_214-fpsp_neg_sign_116	| 4089070C
    .short  fpsp_neg_sign_232-fpsp_neg_sign_116	| 4089070E
    .short  fpsp_neg_sign_1A6-fpsp_neg_sign_116	| 40890710
    .short  fpsp_neg_sign_1B4-fpsp_neg_sign_116	| 40890712
    .short  fpsp_neg_sign_1C2-fpsp_neg_sign_116	| 40890714
    .short  fpsp_neg_sign_1E2-fpsp_neg_sign_116	| 40890716
    .short  fpsp_neg_sign_1A6-fpsp_neg_sign_116	| 40890718
    .short  fpsp_neg_sign_1B4-fpsp_neg_sign_116	| 4089071A
    .short  fpsp_neg_sign_1C2-fpsp_neg_sign_116	| 4089071C
    .short  fpsp_neg_sign_1E2-fpsp_neg_sign_116	| 4089071E
fpsp_neg_sign_136:      /* loop: ls */
    lsll #2,%d0
    bfextu %fp@(-125),2,2,%d1
    orl %d1,%d0
    lea %pc@(fpsp_neg_sign_116),%a1
    addaw %a1@(0x0,%d0:w:2),%a1
    jmp %a1@
fpsp_neg_sign_14A:      /* address %pc@(fpsp_neg_sign_B6) */
    lea %pc@(fpsp_neg_sign_B6),%a1	| 40890734
    bset #2,%fp@(-124)	| 40890738
    jbra fpsp_neg_sign_24C	| 4089073E
fpsp_neg_sign_158:      /* address %pc@(fpsp_neg_sign_B6) */
    lea %pc@(fpsp_neg_sign_B6),%a1	| 40890742
    bset #2,%fp@(-124)	| 40890746
    jbra fpsp_neg_sign_24C	| 4089074C
fpsp_neg_sign_166:      /* test %a0@(2) */
    tstb %a0@(2)	| 40890750
    jbeq fpsp_neg_sign_17A	| 40890754
    lea %pc@(fpsp_neg_sign_E6),%a1	| 40890756
    bset #3,%fp@(-124)	| 4089075A
    jbra fpsp_neg_sign_258	| 40890760
fpsp_neg_sign_17A:      /* address %pc@(fpsp_neg_sign_B6) */
    lea %pc@(fpsp_neg_sign_B6),%a1	| 40890764
    bset #2,%fp@(-124)	| 40890768
    jbra fpsp_neg_sign_258	| 4089076E
fpsp_neg_sign_188:      /* test %a0@(2) */
    tstb %a0@(2)	| 40890772
    jbeq fpsp_neg_sign_19E	| 40890776
    lea %pc@(fpsp_neg_sign_B6),%a1	| 40890778
    oril #201326592,%fp@(-124)	| 4089077C
    jbra fpsp_neg_sign_258	| 40890784
fpsp_neg_sign_19E:      /* address %pc@(fpsp_neg_sign_E6) */
    lea %pc@(fpsp_neg_sign_E6),%a1	| 40890788
    jbra fpsp_neg_sign_258	| 4089078C
fpsp_neg_sign_1A6:      /* address %pc@(fpsp_neg_sign_D6) */
    lea %pc@(fpsp_neg_sign_D6),%a1	| 40890790
    bset #2,%fp@(-124)	| 40890794
    jbra fpsp_neg_sign_24C	| 4089079A
fpsp_neg_sign_1B4:      /* address %pc@(fpsp_neg_sign_D6) */
    lea %pc@(fpsp_neg_sign_D6),%a1	| 4089079E
    bset #2,%fp@(-124)	| 408907A2
    jbra fpsp_neg_sign_24C	| 408907A8
fpsp_neg_sign_1C2:      /* test %a0@(2) */
    tstb %a0@(2)	| 408907AC
    jbeq fpsp_neg_sign_1D6	| 408907B0
    lea %pc@(fpsp_neg_sign_106),%a1	| 408907B2
    bset #3,%fp@(-124)	| 408907B6
    jbra fpsp_neg_sign_258	| 408907BC
fpsp_neg_sign_1D6:      /* address %pc@(fpsp_neg_sign_D6) */
    lea %pc@(fpsp_neg_sign_D6),%a1	| 408907C0
    bset #2,%fp@(-124)	| 408907C4
    jbra fpsp_neg_sign_258	| 408907CA
fpsp_neg_sign_1E2:      /* test %a0@(2) */
    tstb %a0@(2)	| 408907CC
    jbeq fpsp_neg_sign_1F6	| 408907D0
    lea %pc@(fpsp_neg_sign_D6),%a1	| 408907D2
    oril #201326592,%fp@(-124)	| 408907D6
    jbra fpsp_neg_sign_258	| 408907DE
fpsp_neg_sign_1F6:      /* address %pc@(fpsp_neg_sign_106) */
    lea %pc@(fpsp_neg_sign_106),%a1	| 408907E0
    jbra fpsp_neg_sign_258	| 408907E4
fpsp_neg_sign_1FC:      /* address %pc@(fpsp_neg_sign_C6) */
    lea %pc@(fpsp_neg_sign_C6),%a1	| 408907E6
    bset #2,%fp@(-124)	| 408907EA
    jbra fpsp_neg_sign_24C	| 408907F0
fpsp_neg_sign_208:      /* address %pc@(fpsp_neg_sign_C6) */
    lea %pc@(fpsp_neg_sign_C6),%a1	| 408907F2
    bset #2,%fp@(-124)	| 408907F6
    jbra fpsp_neg_sign_24C	| 408907FC
fpsp_neg_sign_214:      /* test %a0@(2) */
    tstb %a0@(2)	| 408907FE
    jbeq fpsp_neg_sign_226	| 40890802
    lea %pc@(fpsp_neg_sign_F6),%a1	| 40890804
    bset #3,%fp@(-124)	| 40890808
    jbra fpsp_neg_sign_258	| 4089080E
fpsp_neg_sign_226:      /* address %pc@(fpsp_neg_sign_C6) */
    lea %pc@(fpsp_neg_sign_C6),%a1	| 40890810
    bset #2,%fp@(-124)	| 40890814
    jbra fpsp_neg_sign_258	| 4089081A
fpsp_neg_sign_232:      /* test %a0@(2) */
    tstb %a0@(2)	| 4089081C
    jbeq fpsp_neg_sign_246	| 40890820
    lea %pc@(fpsp_neg_sign_C6),%a1	| 40890822
    oril #201326592,%fp@(-124)	| 40890826
    jbra fpsp_neg_sign_258	| 4089082E
fpsp_neg_sign_246:      /* address %pc@(fpsp_neg_sign_F6) */
    lea %pc@(fpsp_neg_sign_F6),%a1	| 40890830
    jbra fpsp_neg_sign_258	| 40890834
fpsp_neg_sign_24C:      /* test %a0@(2) */
    tstb %a0@(2)	| 40890836
    jbeq fpsp_neg_sign_258	| 4089083A
    bset #3,%fp@(-124)	| 4089083C
fpsp_neg_sign_258:      /* set %a0@ */
    movew %a1@,%a0@	| 40890842
    movel %a1@(4),%a0@(4)	| 40890844
    movel %a1@(8),%a0@(8)	| 4089084A
    rts	| 40890850
fpsp_neg_sign_268:      /* (data) */
    .short  fpsp_byte_d0-fpsp_neg_sign_268	| 40890852
    .short  fpsp_byte_d1-fpsp_neg_sign_268	| 40890854
    .short  fpsp_byte_d2-fpsp_neg_sign_268	| 40890856
    .short  fpsp_byte_d3-fpsp_neg_sign_268	| 40890858
    .short  fpsp_byte_d4-fpsp_neg_sign_268	| 4089085A
    .short  fpsp_byte_d5-fpsp_neg_sign_268	| 4089085C
    .short  fpsp_byte_d6-fpsp_neg_sign_268	| 4089085E
    .short  fpsp_byte_d7-fpsp_neg_sign_268	| 40890860
    .short  fpsp_word_d0-fpsp_neg_sign_268	| 40890862
    .short  fpsp_word_d1-fpsp_neg_sign_268	| 40890864
    .short  fpsp_word_d2-fpsp_neg_sign_268	| 40890866
    .short  fpsp_word_d3-fpsp_neg_sign_268	| 40890868
    .short  fpsp_word_d4-fpsp_neg_sign_268	| 4089086A
    .short  fpsp_word_d5-fpsp_neg_sign_268	| 4089086C
    .short  fpsp_word_d6-fpsp_neg_sign_268	| 4089086E
    .short  fpsp_word_d7-fpsp_neg_sign_268	| 40890870
    .short  fpsp_long_d0-fpsp_neg_sign_268	| 40890872
    .short  fpsp_long_d1-fpsp_neg_sign_268	| 40890874
    .short  fpsp_long_d2-fpsp_neg_sign_268	| 40890876
    .short  fpsp_long_d3-fpsp_neg_sign_268	| 40890878
    .short  fpsp_long_d4-fpsp_neg_sign_268	| 4089087A
    .short  fpsp_long_d5-fpsp_neg_sign_268	| 4089087C
    .short  fpsp_long_d5_6-fpsp_neg_sign_268	| 4089087E
    .short  fpsp_long_d5_C-fpsp_neg_sign_268	| 40890880
fpsp_neg_sign_298:      /* address %pc@(fpsp_neg_sign_268) */
    lea %pc@(fpsp_neg_sign_268),%a0
    addaw %a0@(0x0,%d1:w:2),%a0
    jmp %a0@
fpsp_byte_d0:           /* (data) */
    moveb %fp@(-84),%fp@(-189)	| 4089088C
    rts	| 40890892
fpsp_byte_d1:           /* (data) */
    moveb %fp@(-84),%fp@(-185)	| 40890894
    rts	| 4089089A
fpsp_byte_d2:           /* (data) */
    moveb %fp@(-84),%d2	| 4089089C
    rts	| 408908A0
fpsp_byte_d3:           /* (data) */
    moveb %fp@(-84),%d3	| 408908A2
    rts	| 408908A6
fpsp_byte_d4:           /* (data) */
    moveb %fp@(-84),%d4	| 408908A8
    rts	| 408908AC
fpsp_byte_d5:           /* (data) */
    moveb %fp@(-84),%d5	| 408908AE
    rts	| 408908B2
fpsp_byte_d6:           /* (data) */
    moveb %fp@(-84),%d6	| 408908B4
    rts	| 408908B8
fpsp_byte_d7:           /* (data) */
    moveb %fp@(-84),%d7	| 408908BA
    rts	| 408908BE
fpsp_word_d0:           /* (data) */
    movew %fp@(-84),%fp@(-190)	| 408908C0
    rts	| 408908C6
fpsp_word_d1:           /* (data) */
    movew %fp@(-84),%fp@(-186)	| 408908C8
    rts	| 408908CE
fpsp_word_d2:           /* (data) */
    movew %fp@(-84),%d2	| 408908D0
    rts	| 408908D4
fpsp_word_d3:           /* (data) */
    movew %fp@(-84),%d3	| 408908D6
    rts	| 408908DA
fpsp_word_d4:           /* (data) */
    movew %fp@(-84),%d4	| 408908DC
    rts	| 408908E0
fpsp_word_d5:           /* (data) */
    movew %fp@(-84),%d5	| 408908E2
    rts	| 408908E6
fpsp_word_d6:           /* (data) */
    movew %fp@(-84),%d6	| 408908E8
    rts	| 408908EC
fpsp_word_d7:           /* (data) */
    movew %fp@(-84),%d7	| 408908EE
    rts	| 408908F2
fpsp_long_d0:           /* set %fp@(-192) */
    movel %fp@(-84),%fp@(-192)
    rts
fpsp_long_d1:           /* set %fp@(-188) */
    movel %fp@(-84),%fp@(-188)
    rts
fpsp_long_d2:           /* set %d2 */
    movel %fp@(-84),%d2
    rts
fpsp_long_d3:           /* set %d3 */
    movel %fp@(-84),%d3
    rts
fpsp_long_d4:           /* set %d4 */
    movel %fp@(-84),%d4
    rts
fpsp_long_d5:           /* set %d5 */
    movel %fp@(-84),%d5
    rts
fpsp_long_d5_6:         /* set %d6 */
    movel %fp@(-84),%d6
    rts
fpsp_long_d5_C:         /* set %d7 */
    movel %fp@(-84),%d7
    rts
    .byte   0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7F, 0xFF, 0x00, 0x00	| 40890928
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7F, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF	| 40890938
    .byte   0xFF, 0xFF, 0xFF, 0xFF	| 40890948
fpsp_long_d5_36:        /* set bit 3 of %fp@(-124) */
    bset #3,%fp@(-124)	| 4089094C
    fmovel #0,%fpsr	| 40890952
    btst #2,%fp@(-126)	| 4089095A
    jbne fpsp_long_d5_92	| 40890960
    jbra fpsp_long_d5_66	| 40890962

fpsp_long_d5_4E:        /* loop: fmove */
    fmovel #0,%fpsr
    btst #2,%fp@(-126)
    jbne fpsp_long_d5_84
    btst #7,%fp@(-204)
    jbeq fpsp_long_d5_74
fpsp_long_d5_66:        /* (data) */
    .short  0xF23A	| 4089097C
    addl %d0,%d0
    .short  0xFFA8	| 40890980
    bset #3,%fp@(-124)
    jbra fpsp_long_d5_7A
fpsp_long_d5_74:        /* (data) */
    .short  0xF23A	| 4089098A
    addl %d0,%d0
    .short  0xFFA6	| 4089098E
fpsp_long_d5_7A:        /* from here: oril #33555472,%fp@(-124) */
    oril #33555472,%fp@(-124)
    rts
fpsp_long_d5_84:        /* test bit 7 of %fp@(-204) */
    btst #7,%fp@(-204)
    jbeq fpsp_long_d5_92
    bset #3,%fp@(-124)
fpsp_long_d5_92:        /* from here: oril #33555472,%fp@(-124) */
    oril #33555472,%fp@(-124)
    st %fp@(-76)
    rts

fpsp_long_d5_A0:        /* loop: ori */
    oril #16785536,%fp@(-124)
    btst #5,%fp@(-126)
    jbne fpsp_op_ena
    .short  0xF23A	| 408909C6
    addl %d0,%d0
    .short  0xFF76	| 408909CA
    rts
fpsp_op_ena:            /* from here: st %fp@(-76) */
    st %fp@(-76)
    rts
fpsp_op_ena_6:          /* loop: clr */
    clrl %fp@(-116)
    clrl %fp@(-112)
    clrl %fp@(-108)
    tstb %a0@
    jbpl fpsp_op_ena_1C
    bset #7,%fp@(-116)
fpsp_op_ena_1C:         /* address %fp@(-116) */
    lea %fp@(-116),%a0
    oril #2600,%fp@(-124)
    btst #3,%fp@(-126)
    jbeq fpsp_op_ena_48
fpsp_unfl_ena:          /* from here: bfclr %fp@(-232),5,3 */
    bfclr %fp@(-232),5,3
    bset #4,%fp@(-223)
    bset #7,%fp@(-231)
    bclr #2,%fp@(-220)
fpsp_op_ena_48:         /* from here: bfextu %fp@(-125),0,2,%d0 */
    bfextu %fp@(-125),0,2,%d0
    bclr #7,%a0@
    sne %a0@(2)
    jbsr fpsp_neg_sign_136
    bfclr %a0@(2),0,8
    jbeq fpsp_op_ena_6C
    bset #7,%a0@
    bset #7,%fp@(-116)
fpsp_op_ena_6C:         /* loop: move */
    movew %a0@,%d1
    andiw #32767,%d1
    jbeq fpsp_unfl_fin
    tstl %a0@(4)
    jbmi fpsp_unfl_fin
    jbne fpsp_op_ena_88
    tstl %a0@(8)
    jbne fpsp_op_ena_88
    bfclr %a0@,1,15
    jbra fpsp_unfl_fin
fpsp_op_ena_88:         /* call fpsp_greater_3E */
    jbsr fpsp_greater_3E
fpsp_unfl_fin:          /* from here: fmovemx %a0@,%fp0 */
    fmovemx %a0@,%fp0
    rts
fpsp_t_ovfl2:           /* loop: ori */
    oril #4168,%fp@(-124)
    movel %fp@(-204),%fp@(-116)
    movel %fp@(-200),%fp@(-112)
    movel %fp@(-196),%fp@(-108)
    moveb %fp@(-125),%d0
    andib #0xc0,%d0
    jbeq fpsp_t_ovfl2_54_8
    cmpib #64,%d0
    jbne fpsp_t_ovfl2_3E
    tstb %fp@(-196)
    jbne fpsp_t_ovfl2_4A
    movel %fp@(-200),%d0
    andil #255,%d0
    jbne fpsp_t_ovfl2_4A
    jbra fpsp_t_ovfl2_54_8
fpsp_t_ovfl2_3E:        /* set %d0 */
    movel %fp@(-196),%d0
    andil #2047,%d0
    jbeq fpsp_t_ovfl2_54_8
fpsp_t_ovfl2_4A:        /* from here: oril #512,%fp@(-124) */
    oril #512,%fp@(-124)
    jbra fpsp_t_ovfl2_54_8

fpsp_t_ovfl2_54:        /* loop: ori */
    oril #4680,%fp@(-124)
fpsp_t_ovfl2_54_8:      /* test bit 4 of %fp@(-126) */
    btst #4,%fp@(-126)
    jbeq fpsp_ovf_ena_24
fpsp_ovf_ena:           /* clear %fp@(-116) */
    clrl %fp@(-116)
    clrl %fp@(-112)
    clrl %fp@(-108)
    bfclr %fp@(-232),5,3
    bclr #4,%fp@(-223)
    bset #7,%fp@(-231)
    bclr #2,%fp@(-220)
fpsp_ovf_ena_24:        /* call fpsp_sec_d_8C */
    jbsr fpsp_sec_d_8C
    bfclr %fp@(-202),0,8
    jbeq fpsp_ovf_pos
    bset #7,%fp@(-204)
    bset #7,%fp@(-116)
fpsp_ovf_pos:           /* from here: fmovemx %fp@(-204),%fp0 */
    fmovemx %fp@(-204),%fp0
    rts

fpsp_ovf_pos_8:         /* loop: ori */
    oril #520,%fp@(-124)
    rts

fpsp_ovf_pos_12:        /* loop: ori */
    oril #520,%fp@(-124)
    btst #3,%fp@(-122)
    jbeq fpsp_ovf_pos_12_16
    bset #5,%fp@(-121)
fpsp_ovf_pos_12_16:     /* return */
    rts
fpsp_ovf_pos_12_16_2:
    .short  0x082E, 0x0007, 0xFF28	| 40890B2A
    .long   0x670608EE, 0x0003FF84, 0x082E0006, 0xFF2C672A	| 40890B30
    .long   0xF2019000, 0xF22E4800, 0xFF28102E, 0xFF180200	| 40890B40
    .long   0x00E00C00, 0x00606610, 0x082E0006, 0xFF386608	| 40890B50
    .long   0x00AE0100	| 40890B60
    .long   0x4080FF84 /* number, not an address (F4) */	| 40890B64
    rts
    btst #6,%fp@(-126)
    beqs fpsp_dst_dis
    orib #96,%fp@(-224)
    st %fp@(-76)
    .short  0x00AE, 0x0100	| 40890B7C
    .long   0x4080FF84 /* number, not an address (F4) */	| 40890B80
    .byte   0x4E, 0x75	| 40890B84
fpsp_dst_dis:           /* (data) */
    .byte   0x08, 0xEE, 0x00, 0x06, 0xFF, 0x2C, 0xF2, 0x01, 0x90, 0x00	| 40890B86
    .short  0xF22E, 0x4800, 0xFF28, 0x00AE, 0x0100	| 40890B90
    negxl %d0
    .long   0xFF844E75	| 40890B9C
fpsp_dst_dis_1A:        /* loop: btst */
    btst #7,%fp@(-204)
    jbeq fpsp_dst_dis_28
    bset #3,%fp@(-124)
fpsp_dst_dis_28:        /* test bit 6 of %fp@(-200) */
    btst #6,%fp@(-200)
    jbeq fpsp_dst_dis_3C
    fmovel %d1,%fpcr
    fmovex %fp@(-204),%fp0
    rts
fpsp_dst_dis_3C:        /* test bit 6 of %fp@(-126) */
    btst #6,%fp@(-126)
    jbeq fpsp_src_dis
    orib #96,%fp@(-232)
    st %fp@(-76)
    oril #16793728,%fp@(-124)
    rts
fpsp_src_dis:           /* set bit 6 of %fp@(-200) */
    bset #6,%fp@(-200)
    fmovel %d1,%fpcr
    fmovex %fp@(-204),%fp0
    oril #16793728,%fp@(-124)
    rts
fpsp_src_dis_1A:        /* loop: ori */
    oril #2600,%fp@(-124)	| 40890BF8
    jbra fpsp_src_dis_2C	| 40890C00
fpsp_src_dis_24:        /* loop: ori */
    oril #2048,%fp@(-124)
fpsp_src_dis_2C:        /* test bit 3 of %fp@(-126) */
    btst #3,%fp@(-126)
    jbeq fpsp_xdep_1A
fpsp_xdnrm_ena:         /* set %sp@- */
    movel %a0,%sp@-
    movel %a0@,%fp@(-116)
    movel %a0@(4),%fp@(-112)
    movel %a0@(8),%fp@(-108)
    lea %fp@(-116),%a0
    bclr #7,%a0@
    sne %a0@(2)
    tstw %a0@
    jbeq fpsp_src_dis_5A
    jbsr fpsp_greater_3E
fpsp_src_dis_5A:        /* clear bit 7 of %a0@ */
    bclr #7,%a0@
    bfclr %a0@(2),0,8
    jbeq fpsp_xdep
    bset #7,%a0@
fpsp_xdep:              /* from here: bfclr %fp@(-232),5,3 */
    bfclr %fp@(-232),5,3
    bset #4,%fp@(-223)
    bclr #7,%fp@(-231)
    bclr #2,%fp@(-220)
    moveal %sp@+,%a0
fpsp_xdep_1A:           /* from here: bfextu %fp@(-125),0,2,%d0 */
    bfextu %fp@(-125),0,2,%d0
    jbne fpsp_xdep_30
    btst #7,%a0@
    jbeq fpsp_xdep_50
    bset #3,%fp@(-124)
    jbra fpsp_xdep_50
fpsp_xdep_30:           /* from here: oril #2600,%fp@(-124) */
    oril #2600,%fp@(-124)
    bclr #7,%a0@
    sne %a0@(2)
    jbsr fpsp_neg_sign_136
    bfclr %a0@(2),0,8
    jbeq fpsp_xdep_50
    bset #7,%a0@
fpsp_xdep_50:           /* continue at fpsp_op_ena_6C */
    jbra fpsp_op_ena_6C

fpsp_xdep_54:           /* loop: link */
    linkw %a2,#-192
    fsave %sp@-
    tstb %sp@(1)
    jbeq fpsp_end_avun_6
    btst #2,%a2@(-220)
    jbeq fpsp_end_avun
    btst #7,%a2@(-224)
    jbeq fpsp_xdep_54_4A
    lea %a2@(-216),%a0
    btst #7,%a0@
    sne %a0@(2)
    bclr #7,%a2@(-224)
    jbsr fpsp_greater_3E
    bclr #7,%a0@
    bfclr %a0@(2),0,8
    jbeq fpsp_xdep_54_42
    bset #7,%a0@
fpsp_xdep_54_42:        /* test bit 7 of %a2@(-232) */
    btst #7,%a2@(-232)
    jbeq fpsp_end_avun
fpsp_xdep_54_4A:        /* address %a2@(-204) */
    lea %a2@(-204),%a0
    btst #7,%a0@
    sne %a0@(2)
    bclr #7,%a2@(-232)
    jbsr fpsp_greater_3E
    bclr #7,%a0@
    bfclr %a0@(2),0,8
    jbeq fpsp_den_com
    bset #7,%a0@
fpsp_den_com:           /* set %a2@(-284) */
    moveb #0xfe,%a2@(-284)
    clrw %a2@(-236)
    bclr #2,%a2@(-220)
fpsp_end_avun:          /* from here: frestore %sp@+ */
    frestore %sp@+
    unlk %a2
    rts
fpsp_end_avun_6:        /* add 4 to %sp */
    addql #4,%sp
    unlk %a2
    rts
    .long   0x00000000, 0x00000000	| 40890D28
fpsp_end_avun_14:       /* (data) */
    .long   0x3FFF0000, 0x80000000, 0x00000000	| 40890D30
fpsp_end_avun_20:       /* (data) */
    .long   0x80000000	| 40890D3C
fpsp_end_avun_24:       /* (data) */
    .long   0xBFFF0000, 0xC90FDAA2, 0x2168C235, 0x00000000	| 40890D40
fpsp_end_avun_34:       /* (data) */
    .long   0x7FFF0000, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000	| 40890D50
fpsp_end_avun_44:       /* (data) */
    .short  fpsp_upper_13E-fpsp_end_avun_44	| 40890D60
    .short  fpsp_upper_13E-fpsp_end_avun_44	| 40890D62
    .short  fpsp_upper_13E-fpsp_end_avun_44	| 40890D64
    .short  fpsp_upper_13E-fpsp_end_avun_44	| 40890D66
    .short  fpsp_upper_13E-fpsp_end_avun_44	| 40890D68
    .short  fpsp_upper_13E-fpsp_end_avun_44	| 40890D6A
    .short  fpsp_upper_13E-fpsp_end_avun_44	| 40890D6C
    .short  fpsp_upper_13E-fpsp_end_avun_44	| 40890D6E
    .short  fpsp_upper_1C-fpsp_end_avun_44	| 40890D70
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890D72
    .short  fpsp_end_avun_43E-fpsp_end_avun_44	| 40890D74
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890D76
    .short  fpsp_upper_28-fpsp_end_avun_44	| 40890D78
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890D7A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890D7C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890D7E
    .short  fpsp_ssinh-fpsp_end_avun_44	| 40890D80
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890D82
    .short  fpsp_end_avun_43E-fpsp_end_avun_44	| 40890D84
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890D86
    .short  fpsp_dnrm_pos_1A8-fpsp_end_avun_44	| 40890D88
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890D8A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890D8C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890D8E
    .short  fpsp_upper_66-fpsp_end_avun_44	| 40890D90
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890D92
    .short  fpsp_end_avun_43E-fpsp_end_avun_44	| 40890D94
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890D96
    .short  fpsp_end_avun_41C-fpsp_end_avun_44	| 40890D98
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890D9A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890D9C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890D9E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DA0
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DA2
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DA4
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DA6
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DA8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DAA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DAC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DAE
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DB0
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DB2
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DB4
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DB6
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DB8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DBA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DBC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DBE
    .short  fpsp_end_avun_47A-fpsp_end_avun_44	| 40890DC0
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890DC2
    .short  fpsp_end_avun_46E-fpsp_end_avun_44	| 40890DC4
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890DC6
    .short  fpsp_LP1CONT2_6E-fpsp_end_avun_44	| 40890DC8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DCA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DCC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DCE
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DD0
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DD2
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DD4
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DD6
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DD8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DDA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DDC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DDE
    .short  fpsp_EXPCONT1_148-fpsp_end_avun_44	| 40890DE0
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890DE2
    .short  fpsp_end_avun_498-fpsp_end_avun_44	| 40890DE4
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890DE6
    .short  fpsp_EXPCONT1_144-fpsp_end_avun_44	| 40890DE8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DEA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DEC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DEE
    .short  fpsp_stanh-fpsp_end_avun_44	| 40890DF0
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890DF2
    .short  fpsp_end_avun_44A-fpsp_end_avun_44	| 40890DF4
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890DF6
    .short  fpsp_ssinh_BE-fpsp_end_avun_44	| 40890DF8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DFA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DFC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890DFE
    .short  fpsp_satan-fpsp_end_avun_44	| 40890E00
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890E02
    .short  fpsp_end_avun_456-fpsp_end_avun_44	| 40890E04
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890E06
    .short  fpsp_TENMAIN_220-fpsp_end_avun_44	| 40890E08
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E0A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E0C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E0E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E10
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E12
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E14
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E16
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E18
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E1A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E1C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E1E
    .short  fpsp_TENMAIN_1A0-fpsp_end_avun_44	| 40890E20
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890E22
    .short  fpsp_long_d5_A0-fpsp_end_avun_44	| 40890E24
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890E26
    .short  fpsp_TENMAIN_19C-fpsp_end_avun_44	| 40890E28
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E2A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E2C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E2E
    .short  fpsp_dnrm_pos_94-fpsp_end_avun_44	| 40890E30
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890E32
    .short  fpsp_long_d5_A0-fpsp_end_avun_44	| 40890E34
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890E36
    .short  fpsp_dnrm_pos_90-fpsp_end_avun_44	| 40890E38
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E3A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E3C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E3E
    .short  fpsp_TANHHUGE_44-fpsp_end_avun_44	| 40890E40
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890E42
    .short  fpsp_long_d5_A0-fpsp_end_avun_44	| 40890E44
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890E46
    .short  fpsp_TANHHUGE_2C-fpsp_end_avun_44	| 40890E48
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E4A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E4C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E4E
    .short  fpsp_c_is_fp2_1C-fpsp_end_avun_44	| 40890E50
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890E52
    .short  fpsp_long_d5_A0-fpsp_end_avun_44	| 40890E54
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890E56
    .short  fpsp_c_is_fp2_18-fpsp_end_avun_44	| 40890E58
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E5A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E5C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E5E
    .short  fpsp_setoxd_24-fpsp_end_avun_44	| 40890E60
    .short  fpsp_end_avun_794-fpsp_end_avun_44	| 40890E62
    .short  fpsp_end_avun_462-fpsp_end_avun_44	| 40890E64
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890E66
    .short  fpsp_setoxd-fpsp_end_avun_44	| 40890E68
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E6A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E6C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E6E
    .short  fpsp_EM1POLY_E6-fpsp_end_avun_44	| 40890E70
    .short  fpsp_end_avun_794-fpsp_end_avun_44	| 40890E72
    .short  fpsp_end_avun_462-fpsp_end_avun_44	| 40890E74
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890E76
    .short  fpsp_EM1POLY_CA-fpsp_end_avun_44	| 40890E78
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E7A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E7C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E7E
    .short  fpsp_EM1POLY_24A-fpsp_end_avun_44	| 40890E80
    .short  fpsp_end_avun_794-fpsp_end_avun_44	| 40890E82
    .short  fpsp_end_avun_462-fpsp_end_avun_44	| 40890E84
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890E86
    .short  fpsp_EM1POLY_22E-fpsp_end_avun_44	| 40890E88
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E8A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E8C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E8E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E90
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E92
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E94
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E96
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E98
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E9A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E9C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890E9E
    .short  fpsp_end_avun_4A4-fpsp_end_avun_44	| 40890EA0
    .short  fpsp_long_d5_36-fpsp_end_avun_44	| 40890EA2
    .short  fpsp_end_avun_46E-fpsp_end_avun_44	| 40890EA4
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890EA6
    .short  fpsp_end_avun_4D0-fpsp_end_avun_44	| 40890EA8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EAA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EAC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EAE
    .short  fpsp_end_avun_4DC-fpsp_end_avun_44	| 40890EB0
    .short  fpsp_long_d5_36-fpsp_end_avun_44	| 40890EB2
    .short  fpsp_end_avun_46E-fpsp_end_avun_44	| 40890EB4
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890EB6
    .short  fpsp_end_avun_508-fpsp_end_avun_44	| 40890EB8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EBA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EBC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EBE
    .short  fpsp_end_avun_514-fpsp_end_avun_44	| 40890EC0
    .short  fpsp_long_d5_36-fpsp_end_avun_44	| 40890EC2
    .short  fpsp_end_avun_46E-fpsp_end_avun_44	| 40890EC4
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890EC6
    .short  fpsp_end_avun_540-fpsp_end_avun_44	| 40890EC8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890ECA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890ECC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890ECE
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890ED0
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890ED2
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890ED4
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890ED6
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890ED8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EDA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EDC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EDE
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EE0
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EE2
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EE4
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EE6
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EE8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EEA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EEC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EEE
    .short  fpsp_dnrm_pos_118-fpsp_end_avun_44	| 40890EF0
    .short  fpsp_end_avun_794-fpsp_end_avun_44	| 40890EF2
    .short  fpsp_end_avun_770-fpsp_end_avun_44	| 40890EF4
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890EF6
    .short  fpsp_dnrm_pos_100-fpsp_end_avun_44	| 40890EF8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EFA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EFC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890EFE
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F00
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F02
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F04
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F06
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F08
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F0A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F0C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F0E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F10
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F12
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F14
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F16
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F18
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F1A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F1C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F1E
    .short  fpsp_TENMAIN_10A-fpsp_end_avun_44	| 40890F20
    .short  fpsp_end_avun_754-fpsp_end_avun_44	| 40890F22
    .short  fpsp_long_d5_A0-fpsp_end_avun_44	| 40890F24
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890F26
    .short  fpsp_TENMAIN_FC-fpsp_end_avun_44	| 40890F28
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F2A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F2C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F2E
    .short  fpsp_scos-fpsp_end_avun_44	| 40890F30
    .short  fpsp_end_avun_794-fpsp_end_avun_44	| 40890F32
    .short  fpsp_long_d5_A0-fpsp_end_avun_44	| 40890F34
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890F36
    .short  fpsp_TANHHUGE_30-fpsp_end_avun_44	| 40890F38
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F3A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F3C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F3E
    .short  fpsp_sgetexp-fpsp_end_avun_44	| 40890F40
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890F42
    .short  fpsp_long_d5_A0-fpsp_end_avun_44	| 40890F44
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890F46
    .short  fpsp_sgetexp_10-fpsp_end_avun_44	| 40890F48
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F4A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F4C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F4E
    .short  fpsp_sgetman-fpsp_end_avun_44	| 40890F50
    .short  fpsp_end_avun_432-fpsp_end_avun_44	| 40890F52
    .short  fpsp_long_d5_A0-fpsp_end_avun_44	| 40890F54
    .short  fpsp_dst_dis_1A-fpsp_end_avun_44	| 40890F56
    .short  fpsp_sgetman_20-fpsp_end_avun_44	| 40890F58
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F5A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F5C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F5E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F60
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F62
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F64
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F66
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F68
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F6A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F6C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F6E
    .short  fpsp_end_avun_56C-fpsp_end_avun_44	| 40890F70
    .short  fpsp_end_avun_56C-fpsp_end_avun_44	| 40890F72
    .short  fpsp_end_avun_56C-fpsp_end_avun_44	| 40890F74
    .short  fpsp_end_avun_56C-fpsp_end_avun_44	| 40890F76
    .short  fpsp_end_avun_56C-fpsp_end_avun_44	| 40890F78
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F7A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F7C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F7E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F80
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F82
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F84
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F86
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F88
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F8A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F8C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F8E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F90
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F92
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F94
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F96
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F98
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F9A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F9C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890F9E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FA0
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FA2
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FA4
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FA6
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FA8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FAA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FAC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FAE
    .short  fpsp_end_avun_612-fpsp_end_avun_44	| 40890FB0
    .short  fpsp_end_avun_612-fpsp_end_avun_44	| 40890FB2
    .short  fpsp_end_avun_612-fpsp_end_avun_44	| 40890FB4
    .short  fpsp_end_avun_612-fpsp_end_avun_44	| 40890FB6
    .short  fpsp_end_avun_612-fpsp_end_avun_44	| 40890FB8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FBA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FBC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FBE
    .short  fpsp_end_avun_6B8-fpsp_end_avun_44	| 40890FC0
    .short  fpsp_end_avun_6B8-fpsp_end_avun_44	| 40890FC2
    .short  fpsp_end_avun_6B8-fpsp_end_avun_44	| 40890FC4
    .short  fpsp_end_avun_6B8-fpsp_end_avun_44	| 40890FC6
    .short  fpsp_end_avun_6B8-fpsp_end_avun_44	| 40890FC8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FCA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FCC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FCE
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FD0
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FD2
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FD4
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FD6
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FD8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FDA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FDC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FDE
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FE0
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FE2
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FE4
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FE6
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FE8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FEA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FEC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FEE
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FF0
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FF2
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FF4
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FF6
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FF8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FFA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FFC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40890FFE
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891000
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891002
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891004
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891006
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891008
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089100A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089100C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089100E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891010
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891012
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891014
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891016
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891018
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089101A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089101C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089101E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891020
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891022
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891024
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891026
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891028
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089102A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089102C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089102E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891030
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891032
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891034
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891036
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891038
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089103A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089103C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089103E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891040
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891042
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891044
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891046
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891048
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089104A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089104C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089104E
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891050
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891052
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891054
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891056
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 40891058
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089105A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089105C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089105E
    .short  fpsp_ssincos-fpsp_end_avun_44	| 40891060
    .short  fpsp_end_avun_700-fpsp_end_avun_44	| 40891062
    .short  fpsp_end_avun_720-fpsp_end_avun_44	| 40891064
    .short  fpsp_end_avun_72E-fpsp_end_avun_44	| 40891066
    .short  fpsp_COSPOLY_C2-fpsp_end_avun_44	| 40891068
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089106A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089106C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089106E
    .short  fpsp_ssincos-fpsp_end_avun_44	| 40891070
    .short  fpsp_end_avun_700-fpsp_end_avun_44	| 40891072
    .short  fpsp_end_avun_720-fpsp_end_avun_44	| 40891074
    .short  fpsp_end_avun_72E-fpsp_end_avun_44	| 40891076
    .short  fpsp_COSPOLY_C2-fpsp_end_avun_44	| 40891078
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089107A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089107C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089107E
    .short  fpsp_ssincos-fpsp_end_avun_44	| 40891080
    .short  fpsp_end_avun_700-fpsp_end_avun_44	| 40891082
    .short  fpsp_end_avun_720-fpsp_end_avun_44	| 40891084
    .short  fpsp_end_avun_72E-fpsp_end_avun_44	| 40891086
    .short  fpsp_COSPOLY_C2-fpsp_end_avun_44	| 40891088
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089108A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089108C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089108E
    .short  fpsp_ssincos-fpsp_end_avun_44	| 40891090
    .short  fpsp_end_avun_700-fpsp_end_avun_44	| 40891092
    .short  fpsp_end_avun_720-fpsp_end_avun_44	| 40891094
    .short  fpsp_end_avun_72E-fpsp_end_avun_44	| 40891096
    .short  fpsp_COSPOLY_C2-fpsp_end_avun_44	| 40891098
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089109A
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089109C
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 4089109E
    .short  fpsp_ssincos-fpsp_end_avun_44	| 408910A0
    .short  fpsp_end_avun_700-fpsp_end_avun_44	| 408910A2
    .short  fpsp_end_avun_720-fpsp_end_avun_44	| 408910A4
    .short  fpsp_end_avun_72E-fpsp_end_avun_44	| 408910A6
    .short  fpsp_COSPOLY_C2-fpsp_end_avun_44	| 408910A8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910AA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910AC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910AE
    .short  fpsp_ssincos-fpsp_end_avun_44	| 408910B0
    .short  fpsp_end_avun_700-fpsp_end_avun_44	| 408910B2
    .short  fpsp_end_avun_720-fpsp_end_avun_44	| 408910B4
    .short  fpsp_end_avun_72E-fpsp_end_avun_44	| 408910B6
    .short  fpsp_COSPOLY_C2-fpsp_end_avun_44	| 408910B8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910BA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910BC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910BE
    .short  fpsp_ssincos-fpsp_end_avun_44	| 408910C0
    .short  fpsp_end_avun_700-fpsp_end_avun_44	| 408910C2
    .short  fpsp_end_avun_720-fpsp_end_avun_44	| 408910C4
    .short  fpsp_end_avun_72E-fpsp_end_avun_44	| 408910C6
    .short  fpsp_COSPOLY_C2-fpsp_end_avun_44	| 408910C8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910CA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910CC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910CE
    .short  fpsp_ssincos-fpsp_end_avun_44	| 408910D0
    .short  fpsp_end_avun_700-fpsp_end_avun_44	| 408910D2
    .short  fpsp_end_avun_720-fpsp_end_avun_44	| 408910D4
    .short  fpsp_end_avun_72E-fpsp_end_avun_44	| 408910D6
    .short  fpsp_COSPOLY_C2-fpsp_end_avun_44	| 408910D8
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910DA
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910DC
    .short  fpsp_end_avun_3C4_52-fpsp_end_avun_44	| 408910DE
fpsp_end_avun_3C4:      /* clear %fp@(-70) */
    clrb %fp@(-70)
    bfextu %fp@(-228),0,6,%d0
    cmpil #23,%d0
    jbne fpsp_end_avun_3C4_16
    jbra fpsp_upper_13E
fpsp_end_avun_3C4_16:   /* set %d0 */
    movew %fp@(-228),%d0
    andil #127,%d0
    cmpil #56,%d0
    jbge fpsp_end_avun_3C4_52
    bfextu %fp@(-232),0,3,%d1
    lsll #3,%d0
    addl %d1,%d0
    lea %pc@(fpsp_end_avun_44),%a1
    addaw %a1@(0x0,%d0:w:2),%a1
    lea %fp@(-204),%a0
    movel %fp@(-128),%d1
    andil #255,%d1
    fmovel #0,%fpcr
    jmp %a1@
fpsp_end_avun_3C4_52:   /* from here: st %fp@(-76) */
    st %fp@(-76)
    rts
fpsp_end_avun_41C:      /* (data) */
    btst #7,%a0@	| 40891138
    bnes fpsp_end_avun_41C_E
    jbsr fpsp_end_avun_7AC
    jbra fpsp_ovf_pos_8
fpsp_end_avun_41C_E:
    bsrw fpsp_end_avun_7BC	| 40891146
    braw fpsp_ovf_pos_8
fpsp_end_avun_432:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 4089114E
    jbne fpsp_end_avun_7BC	| 40891152
    jbra fpsp_end_avun_7AC	| 40891156
fpsp_end_avun_43E:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 4089115A
    jbne fpsp_end_avun_782	| 4089115E
    jbra fpsp_end_avun_770	| 40891162
fpsp_end_avun_44A:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 40891166
    jbne fpsp_end_avun_79C	| 4089116A
    jbra fpsp_end_avun_794	| 4089116E
fpsp_end_avun_456:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 40891172
    jbne fpsp_end_avun_75E	| 40891176
    jbra fpsp_end_avun_754	| 4089117A
fpsp_end_avun_462:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 4089117E
    jbne fpsp_end_avun_7AC	| 40891182
    jbra fpsp_end_avun_770	| 40891186
fpsp_end_avun_46E:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 4089118A
    jbne fpsp_long_d5_A0	| 4089118E
    jbra fpsp_end_avun_770	| 40891192
fpsp_end_avun_47A:      /* from here: fmovemx %a0@,%fp0 */
    fmovemx %a0@,%fp0	| 40891196
    .short  0xF23C, 0x5838, 0x00FF	| 4089119A fcmpb #-1,%fp0
    fbgt fpsp_LP1CONT2_72	| 408911A0
    fbeq fpsp_long_d5_36	| 408911A4
    fmovel #0,%fpsr	| 408911A8
    jbra fpsp_long_d5_A0	| 408911B0
fpsp_end_avun_498:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 408911B4
    jbne fpsp_end_avun_79C	| 408911B8
    jbra fpsp_end_avun_770	| 408911BC
fpsp_end_avun_4A4:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 408911C0
    jbne fpsp_long_d5_A0	| 408911C4
    cmpiw #16383,%a0@	| 408911C8
    jbne fpsp_satan_274	| 408911CC
    cmpil #-2147483648,%a0@(4)	| 408911D0
    jbne fpsp_satan_274	| 408911D8
    tstl %a0@(8)	| 408911DC
    jbne fpsp_satan_274	| 408911E0
    fmoveb #0,%fp0	| 408911E4
    rts	| 408911EA
fpsp_end_avun_4D0:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 408911EC
    jbeq fpsp_satan_21E	| 408911F0
    jbra fpsp_long_d5_A0	| 408911F4
fpsp_end_avun_4DC:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 408911F8
    jbne fpsp_long_d5_A0	| 408911FC
    cmpiw #16383,%a0@	| 40891200
    jbne fpsp_LP1CONT2_1BE	| 40891204
    cmpil #-2147483648,%a0@(4)	| 40891208
    jbne fpsp_LP1CONT2_1BE	| 40891210
    tstl %a0@(8)	| 40891214
    jbne fpsp_LP1CONT2_1BE	| 40891218
    fmoveb #0,%fp0	| 4089121C
    rts	| 40891222
fpsp_end_avun_508:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 40891224
    jbeq fpsp_LP1CONT2_1A2	| 40891228
    jbra fpsp_long_d5_A0	| 4089122C
fpsp_end_avun_514:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 40891230
    jbne fpsp_long_d5_A0	| 40891234
    cmpiw #16383,%a0@	| 40891238
    jbne fpsp_LP1CONT2_20E	| 4089123C
    cmpil #-2147483648,%a0@(4)	| 40891240
    jbne fpsp_LP1CONT2_20E	| 40891248
    tstl %a0@(8)	| 4089124C
    jbne fpsp_LP1CONT2_20E	| 40891250
    fmoveb #0,%fp0	| 40891254
    rts	| 4089125A
fpsp_end_avun_540:      /* test bit 7 of %a0@ */
    btst #7,%a0@	| 4089125C
    jbeq fpsp_LP1CONT2_1DA	| 40891260
    jbra fpsp_long_d5_A0	| 40891264
fpsp_end_avun_54C:      /* (data) */
    .byte   0x05, 0x58, 0x00, 0x4E, 0x00, 0x74, 0x00, 0x46, 0x00, 0x52, 0x00, 0x4E, 0x00, 0x52, 0x00, 0x46	| 40891268
    .byte   0x00, 0x4E, 0x00, 0x4E, 0x00, 0x4E, 0x00, 0x46, 0x00, 0x4A, 0x00, 0x4A, 0x00, 0x4A, 0x00, 0x4A	| 40891278
fpsp_end_avun_56C:      /* clear %fp@(-123) */
    clrb %fp@(-123)	| 40891288
    bfextu %fp@(-232),0,3,%d0	| 4089128C
    bfextu %fp@(-224),0,3,%d1	| 40891292
    bclr #2,%d0	| 40891298
    bclr #2,%d1	| 4089129C
    lslb #2,%d1	| 408912A0
    orb %d0,%d1	| 408912A2
    lea %pc@(fpsp_end_avun_54C),%a1	| 408912A4
    addaw %a1@(0,%d1:w:2),%a1	| 408912A8
    jmp %a1@	| 408912AC
    jbra fpsp_dst_dis_1A
    braw fpsp_ovf_pos_12_16_2
    braw fpsp_long_d5_A0
    moveb %fp@(-204),%d1
    moveb %fp@(-216),%d0
    eorb %d0,%d1
    btst #7,%d1
    jbeq fpsp_end_avun_3C4_1F0
    bset #7,%fp@(-123)
fpsp_end_avun_3C4_1F0:  /* test bit 7 of %d0 */
    btst #7,%d0
    jbeq fpsp_end_avun_7AC
    jbra fpsp_end_avun_7BC
    .long   0x122EFF34	| 408912DC
    .short  0x102E, 0xFF28, 0xB101	| 408912E0
    btst #7,%d1
    jbeq fpsp_end_avun_3C4_212
    bset #7,%fp@(-123)
fpsp_end_avun_3C4_212:  /* test %fp@(-224) */
    tstb %fp@(-224)
    jbpl fpsp_end_avun_3C4_220
    lea %fp@(-216),%a0
    jbra fpsp_src_dis_24
fpsp_end_avun_3C4_220:  /* from here: fmovel %fp@(-128),%fpcr */
    fmovel %fp@(-128),%fpcr
    fmovex %fp@(-216),%fp0
    rts
fpsp_end_avun_5F2:      /* (data) */
    .byte   0x04, 0xB8, 0x00, 0x4E, 0x00, 0x74, 0x00, 0x46, 0x00, 0x52, 0x00, 0x4E, 0x00, 0x52, 0x00, 0x46	| 4089130E
    .byte   0x00, 0x4E, 0x00, 0x4E, 0x00, 0x4E, 0x00, 0x46, 0x00, 0x4A, 0x00, 0x4A, 0x00, 0x4A, 0x00, 0x4A	| 4089131E
fpsp_end_avun_612:      /* clear %fp@(-123) */
    clrb %fp@(-123)	| 4089132E
    bfextu %fp@(-232),0,3,%d0	| 40891332
    bfextu %fp@(-224),0,3,%d1	| 40891338
    bclr #2,%d0	| 4089133E
    bclr #2,%d1	| 40891342
    lslb #2,%d1	| 40891346
    orb %d0,%d1	| 40891348
    lea %pc@(fpsp_end_avun_5F2),%a1	| 4089134A
    addaw %a1@(0,%d1:w:2),%a1	| 4089134E
    jmp %a1@	| 40891352
    jbra fpsp_dst_dis_1A
    braw fpsp_ovf_pos_12_16_2
    braw fpsp_long_d5_A0
    moveb %fp@(-204),%d1
    moveb %fp@(-216),%d0
    eorb %d0,%d1
    btst #7,%d1
    jbeq fpsp_end_avun_3C4_296
    bset #7,%fp@(-123)
fpsp_end_avun_3C4_296:  /* test bit 7 of %d0 */
    btst #7,%d0
    jbeq fpsp_end_avun_7AC
    jbra fpsp_end_avun_7BC
    .short  0x122E, 0xFF34, 0x102E, 0xFF28, 0xB101	| 40891382
    btst #7,%d1
    jbeq fpsp_end_avun_3C4_2B8
    bset #7,%fp@(-123)
fpsp_end_avun_3C4_2B8:  /* test %fp@(-224) */
    tstb %fp@(-224)
    jbpl fpsp_end_avun_3C4_2C6
    lea %fp@(-216),%a0
    jbra fpsp_src_dis_24
fpsp_end_avun_3C4_2C6:  /* from here: fmovel %fp@(-128),%fpcr */
    fmovel %fp@(-128),%fpcr
    fmovex %fp@(-216),%fp0
    rts
fpsp_end_avun_698:      /* (data) */
    .byte   0x05, 0xFE, 0x05, 0xFE, 0x00, 0x42, 0x00, 0x64, 0x00, 0x4A, 0x00, 0x4A, 0x00, 0x42, 0x00, 0x64	| 408913B4
    .byte   0x00, 0x58, 0x00, 0x58, 0x00, 0x42, 0x00, 0x64, 0x00, 0x46, 0x00, 0x46, 0x00, 0x46, 0x00, 0x46	| 408913C4
fpsp_end_avun_6B8:      /* from here: bfextu %fp@(-232),0,3,%d0 */
    bfextu %fp@(-232),0,3,%d0	| 408913D4
    bfextu %fp@(-224),0,3,%d1	| 408913DA
    bclr #2,%d0	| 408913E0
    bclr #2,%d1	| 408913E4
    lslb #2,%d1	| 408913E8
    orb %d0,%d1	| 408913EA
    lea %pc@(fpsp_end_avun_698),%a1	| 408913EC
    addaw %a1@(0,%d1:w:2),%a1	| 408913F0
    jmp %a1@	| 408913F4
    .byte   0x60, 0x00, 0xF5, 0xBE, 0x60, 0x00, 0xF7, 0x2E, 0x08, 0x2E, 0x00, 0x07, 0xFF, 0x28, 0x67, 0x00	| 408913F6
    .byte   0x00, 0xC2, 0x60, 0x00, 0x00, 0xCE, 0x08, 0x2E, 0x00, 0x07, 0xFF, 0x28, 0x67, 0x78, 0x60, 0x00	| 40891406
    .byte   0x00, 0x88, 0x60, 0x00, 0xF7, 0x86	| 40891416
fpsp_end_avun_700:      /* test bit 7 of %fp@(-204) */
    btst #7,%fp@(-204)
    jbeq fpsp_end_avun_3C4_34C
    fmoves %pc@(fpsp_end_avun_20),%fp0
    jbra fpsp_end_avun_716
fpsp_end_avun_3C4_34C:  /* from here: fmoveb #0,%fp0 */
    fmoveb #0,%fp0
fpsp_end_avun_716:      /* (data) */
    .short  0xF23A	| 40891432
    addw %d0,%d0
    .short  0xF8FA	| 40891436
    jbra fpsp_NEVEN_11A
fpsp_end_avun_720:      /* from here: fmovex %pc@(fpsp_end_avun_34),%fp1 */
    fmovex %pc@(fpsp_end_avun_34),%fp1	| 4089143C
    jbsr fpsp_NEVEN_11A	| 40891442
    jbra fpsp_long_d5_A0	| 40891446
fpsp_end_avun_72E:      /* set %fp@(-116) */
    movel %fp@(-204),%fp@(-116)	| 4089144A
    movel %fp@(-200),%fp@(-112)	| 40891450
    movel %fp@(-196),%fp@(-108)	| 40891456
    bset #6,%fp@(-112)	| 4089145C
    fmovemx %fp@(-116),%fp1	| 40891462
    jbsr fpsp_NEVEN_11A	| 40891468
    jbra fpsp_dst_dis_1A	| 4089146C
fpsp_end_avun_754:      /* from here: fmovex %pc@(fpsp_PI_10),%fp0 */
    fmovex %pc@(fpsp_PI_10),%fp0	| 40891470
    jbra fpsp_ovf_pos_8	| 40891476
fpsp_end_avun_75E:      /* from here: fmovex %pc@(fpsp_end_avun_24),%fp0 */
    fmovex %pc@(fpsp_end_avun_24),%fp0	| 4089147A
    oril #134217728,%fp@(-124)	| 40891480
    jbra fpsp_ovf_pos_8	| 40891488
fpsp_end_avun_770:      /* from here: fmoves #0einf,%fp0 */
    fmoves #0einf,%fp0	| 4089148C
    oril #33554432,%fp@(-124)	| 40891494
    rts	| 4089149C
fpsp_end_avun_782:      /* from here: fmoves #0e-inf,%fp0 */
    fmoves #0e-inf,%fp0	| 4089149E
    oril #167772160,%fp@(-124)	| 408914A6
    rts	| 408914AE

fpsp_end_avun_794:      /* loop: fmovex */
    fmovex %pc@(fpsp_end_avun_14),%fp0
    rts

fpsp_end_avun_79C:      /* loop: fmove */
    fmoveb #0xff,%fp0
    oril #134217728,%fp@(-124)
    rts

fpsp_end_avun_7AC:      /* loop: fmove */
    fmoveb #0,%fp0
    oril #67108864,%fp@(-124)
    rts

fpsp_end_avun_7BC:      /* loop: fmoves */
    fmoves %pc@(fpsp_end_avun_20),%fp0
    oril #201326592,%fp@(-124)
    rts

/* fpsp_sgetexp: FGETEXP. */
fpsp_sgetexp:
    movew %a0@,%d0	| 408914E8
    bclr #15,%d0	| 408914EA
    subiw #16383,%d0	| 408914EE
    fmovew %d0,%fp0	| 408914F2
    rts	| 408914F6
fpsp_sgetexp_10:        /* clear bit 7 of %a0@ */
    bclr #7,%a0@	| 408914F8
    jbsr fpsp_greater_3E	| 408914FC
    movew %a0@,%d0	| 40891500
    subiw #16383,%d0	| 40891502
    fmovew %d0,%fp0	| 40891506
    rts	| 4089150A

/* fpsp_sgetman: FGETMAN. */
fpsp_sgetman:
    movel %fp@(-128),%d0
    andil #-256,%d0
    fmovel %d0,%fpcr
    movew %a0@,%d0
    oriw #32767,%d0
    bclr #14,%d0
    movew %d0,%a0@
    fmovex %a0@,%fp0
    rts
fpsp_sgetman_20:        /* set %d0 */
    movel %a0@(4),%d0
    movel %a0@(8),%d1
    jbsr fpsp_sgetman_34
    movel %d0,%a0@(4)
    movel %d1,%a0@(8)
    jbra fpsp_sgetman

fpsp_sgetman_34:        /* test %d0 */
    tstl %d0
    jbne fpsp_upper
    tstl %d1
    jbne fpsp_sgetman_34_A
    jbra fpsp_upper_1A
fpsp_sgetman_34_A:      /* set %sp@- */
    movel %d3,%sp@-
    exg %d0,%d1
    bfffo %d0,0,0,%d3
    lsll %d3,%d0
    movel %sp@+,%d3
    jbra fpsp_upper_1A
fpsp_upper:             /* save registers */
    moveml %d3/%d5-%d6,%sp@-
    bfffo %d0,0,0,%d3
    lsll %d3,%d0
    movel %d1,%d6
    lsll %d3,%d1
    moveq #32,%d5
    subl %d3,%d5
    lsrl %d5,%d6
    orl %d6,%d0
    moveml %sp@+,%d3/%d5-%d6
fpsp_upper_1A:          /* return */
    rts
fpsp_upper_1C:          /* from here: bfextu %fp@(-125),2,2,%d1 */
    bfextu %fp@(-125),2,2,%d1	| 40891574
    movel %d1,%fp@(-84)	| 4089157A
    jbra fpsp_upper_70_A	| 4089157E
fpsp_upper_28:          /* test bit 5 of %fp@(-125) */
    btst #5,%fp@(-125)	| 40891580
    jbeq fpsp_end_avun_41C	| 40891586
    btst #4,%fp@(-125)
    jbeq fpsp_upper_48
    btst #7,%a0@
    jbne fpsp_upper_5E
    jbsr fpsp_end_avun_794
    jbra fpsp_ovf_pos_8
fpsp_upper_48:          /* test bit 7 of %a0@ */
    btst #7,%a0@
    jbeq fpsp_upper_56
    jbsr fpsp_end_avun_79C
    jbra fpsp_ovf_pos_8
fpsp_upper_56:          /* call fpsp_end_avun_7AC */
    jbsr fpsp_end_avun_7AC
    jbra fpsp_ovf_pos_8
fpsp_upper_5E:          /* call fpsp_end_avun_7BC */
    jbsr fpsp_end_avun_7BC
    jbra fpsp_ovf_pos_8
fpsp_upper_66:          /* (data) */
    .short  0x2D7C, 0x0000	| 408915BE
    .short  0x0001, 0xFFAC	| orib #0xac,%d1
    jbra fpsp_upper_70_A

fpsp_upper_70:          /* from here: bfextu %fp@(-125),2,2,%d1 */
    bfextu %fp@(-125),2,2,%d1
    movel %d1,%fp@(-84)
fpsp_upper_70_A:        /* clear bit 7 of %a0@ */
    bclr #7,%a0@
    sne %a0@(2)
    cmpiw #16446,%a0@
    jbgt fpsp_upper_70_72
    cmpiw #16381,%a0@
    jbgt fpsp_upper_70_94
    btst #1,%fp@(-81)
    jbeq fpsp_upper_70_5C
    tstb %a0@(2)
    jbne fpsp_upper_70_44
    cmpib #3,%fp@(-81)
    jbeq fpsp_upper_70_3C
    jbsr fpsp_end_avun_7AC
    jbra fpsp_ovf_pos_8
fpsp_upper_70_3C:       /* call fpsp_end_avun_794 */
    jbsr fpsp_end_avun_794
    jbra fpsp_ovf_pos_8
fpsp_upper_70_44:       /* test #2,%fp@(-81) */
    cmpib #2,%fp@(-81)
    jbeq fpsp_upper_70_54
    jbsr fpsp_end_avun_7BC
    jbra fpsp_ovf_pos_8
fpsp_upper_70_54:       /* call fpsp_end_avun_79C */
    jbsr fpsp_end_avun_79C
    jbra fpsp_ovf_pos_8
fpsp_upper_70_5C:       /* test %a0@(2) */
    tstb %a0@(2)
    jbne fpsp_upper_70_6A
    jbsr fpsp_end_avun_7AC
    jbra fpsp_ovf_pos_8
fpsp_upper_70_6A:       /* call fpsp_end_avun_7BC */
    jbsr fpsp_end_avun_7BC
    jbra fpsp_ovf_pos_8
fpsp_upper_70_72:       /* from here: bfclr %a0@(2),0,8 */
    bfclr %a0@(2),0,8
    jbeq fpsp_upper_70_7E
    bset #7,%a0@
fpsp_upper_70_7E:       /* from here: fmovel %fpcr,%sp@- */
    fmovel %fpcr,%sp@-
    fmovel #0,%fpcr
    fmovex %a0@,%fp0
    fmovel %sp@+,%fpcr
    rts
fpsp_upper_70_94:       /* clear %d0 */
    moveq #0,%d0
    movel #16446,%d1
    jbsr fpsp_lower_A6
    movel %fp@(-84),%d1
    jbsr fpsp_dp_over_152
    jbsr fpsp_greater_3E
    bfclr %a0@(2),0,8
    jbeq fpsp_upper_70_B8
    bset #7,%a0@
fpsp_upper_70_B8:       /* from here: fmovel %fpcr,%sp@- */
    fmovel %fpcr,%sp@-
    fmovel #0,%fpcr
    fmovex %a0@,%fp0
    fmovel %sp@+,%fpcr
    rts

fpsp_upper_13E:         /* from here: bfextu %fp@(-228),9,7,%d0 */
    bfextu %fp@(-228),9,7,%d0
    bfextu %fp@(-128),26,2,%d1
    tstb %d0
    jbeq fpsp_upper_13E_30
    cmpib #10,%d0
    jble fpsp_upper_13E_28
    cmpib #14,%d0
    jble fpsp_upper_13E_50
    cmpib #47,%d0
    jble fpsp_upper_13E_28
    cmpib #63,%d0
    jble fpsp_upper_13E_84
fpsp_upper_13E_28:      /* from here: fmoveb #0,%fp0 */
    fmoveb #0,%fp0
    rts
fpsp_upper_13E_30:      /* test %d1 */
    tstb %d1
    jbeq fpsp_upper_13E_42
    cmpib #3,%d1
    jbeq fpsp_upper_13E_4A
    lea %pc@(fpsp_LP1CONT2_258),%a0
    jbra fpsp_upper_13E_C8
fpsp_upper_13E_42:      /* address %pc@(fpsp_LP1CONT2_24C) */
    lea %pc@(fpsp_LP1CONT2_24C),%a0
    braw fpsp_upper_13E_C8
fpsp_upper_13E_4A:      /* address %pc@(fpsp_LP1CONT2_264) */
    lea %pc@(fpsp_LP1CONT2_264),%a0
    jbra fpsp_upper_13E_C8
fpsp_upper_13E_50:      /* from here: subil #11,%d0 */
    subil #11,%d0
    tstb %d1
    jbeq fpsp_upper_13E_6C
    cmpib #3,%d1
    jbeq fpsp_upper_13E_78
    lea %pc@(fpsp_LP1CONT2_2AC),%a0
    cmpib #2,%d0
    jble fpsp_upper_13E_C8
    jbra fpsp_upper_13E_D0
fpsp_upper_13E_6C:      /* address %pc@(fpsp_LP1CONT2_270) */
    lea %pc@(fpsp_LP1CONT2_270),%a0
    cmpib #2,%d0
    jble fpsp_upper_13E_C8
    jbra fpsp_upper_13E_D0
fpsp_upper_13E_78:      /* address %pc@(fpsp_SMALRP) */
    lea %pc@(fpsp_SMALRP),%a0
    cmpib #2,%d0
    jble fpsp_upper_13E_C8
    jbra fpsp_upper_13E_D0
fpsp_upper_13E_84:      /* from here: subil #48,%d0 */
    subil #48,%d0
    tstb %d1
    jbeq fpsp_upper_13E_A6
    cmpib #3,%d1
    jbeq fpsp_upper_13E_B8
    lea %pc@(fpsp_BIGRZRM),%a0
    cmpib #1,%d0
    jble fpsp_upper_13E_C8
    cmpib #7,%d0
    jble fpsp_upper_13E_D0
    jbra fpsp_upper_13E_C8
fpsp_upper_13E_A6:      /* address %pc@(fpsp_SMALRP_3C) */
    lea %pc@(fpsp_SMALRP_3C),%a0
    cmpib #1,%d0
    jble fpsp_upper_13E_C8
    cmpib #7,%d0
    jble fpsp_upper_13E_D0
    jbra fpsp_upper_13E_C8
fpsp_upper_13E_B8:      /* address %pc@(fpsp_BIGRZRM_C0) */
    lea %pc@(fpsp_BIGRZRM_C0),%a0
    cmpib #1,%d0
    jble fpsp_upper_13E_C8
    cmpib #7,%d0
    jble fpsp_upper_13E_D0
fpsp_upper_13E_C8:      /* from here: oril #520,%fp@(-124) */
    oril #520,%fp@(-124)
fpsp_upper_13E_D0:      /* from here: mulul #12,%d0 */
    mulul #12,%d0
    movel %d1,%fp@(-84)
    bfextu %fp@(-128),24,2,%d1
    tstl %d1
    jbne fpsp_upper_13E_EE
    fmovemx %a0@(0x0,%d0:w),%fp0
    rts
fpsp_upper_13E_EE:      /* from here: swap %d1 */
    swap %d1
    addl %fp@(-84),%d1
    movel %a0@(0x0,%d0:w),%fp@(-116)
    movel %a0@(0x4,%d0:w),%fp@(-112)
    movel %a0@(0x8,%d0:w),%fp@(-108)
    moveq #0,%d0
    lea %fp@(-116),%a0
    btst #7,%a0@
    sne %a0@(2)
    jbsr fpsp_dp_over_152
    bfclr %a0@(2),0,8
    jbeq fpsp_upper_13E_124
    bset #7,%a0@
fpsp_upper_13E_124:     /* from here: fmovemx %a0@,%fp0 */
    fmovemx %a0@,%fp0
    rts
    clrl %fp@(-68)
    bras fpsp_upper_13E_124_14
    movel #1,%fp@(-68)
fpsp_upper_13E_124_14:
    moveml %d2-%d7/%a2,%sp@-
    subal %a2,%a2
    bfextu %a0@,1,15,%d3
    movel %a0@(8),%d5
    movel %a0@(4),%d4
    bmis fpsp_upper_13E_124_4E
    bnes fpsp_upper_13E_124_3E
    movel %d5,%d4
    moveq #0,%d5
    subil #32,%d3
    bfffo %d4,0,0,%d6
    lsll %d6,%d4
    subl %d6,%d3
    bras fpsp_upper_13E_124_4E
fpsp_upper_13E_124_3E:
    bfffo %d4,0,0,%d6
    subl %d6,%d3
    lsll %d6,%d4
    bfextu %d5,0,%d6,%d7
    lsll %d6,%d5
    orl %d7,%d4
fpsp_upper_13E_124_4E:
    bfextu %a0@(-12),1,15,%d0
    movel %a0@(-4),%d2
    movel %a0@(-8),%d1
    jbmi fpsp_upper_13E_1A8
    jbne fpsp_upper_13E_198
    movel %d2,%d1
    moveq #0,%d2
    subil #32,%d0
    bfffo %d1,0,0,%d6
    lsll %d6,%d1
    subl %d6,%d0
    jbra fpsp_upper_13E_1A8
fpsp_upper_13E_198:     /* from here: bfffo %d1,0,0,%d6 */
    bfffo %d1,0,0,%d6
    subl %d6,%d0
    lsll %d6,%d1
    bfextu %d2,0,%d6,%d7
    lsll %d6,%d2
    orl %d7,%d1
fpsp_upper_13E_1A8:     /* set %fp@(-60) */
    movel %d3,%fp@(-60)
    subl %d3,%d0
    jbge fpsp_upper_13E_1B6
    addl %d3,%d0
    subal %a1,%a1
    jbra fpsp_upper_13E_226
fpsp_upper_13E_1B6:     /* set %a1 */
    moveal %d0,%a1
    moveq #0,%d3
    andil #31,%d0
    jbeq fpsp_upper_13E_1D0
    bfextu %d1,0,%d0,%d3
    lsll %d0,%d1
    bfextu %d2,0,%d0,%d6
    lsll %d0,%d2
    orl %d6,%d1
fpsp_upper_13E_1D0:     /* call fpsp_upper_42C */
    jbsr fpsp_upper_42C
    movel %a1,%d6
    bfextu %d6,16,11,%d6
    jbeq fpsp_upper_13E_1EA
    moveal %d6,%a1
    moveq #0,%d2
fpsp_upper_13E_1E0:     /* call fpsp_upper_42C (loop) */
    jbsr fpsp_upper_42C
    subql #1,%a1
    movel %a1,%d6
    jbne fpsp_upper_13E_1E0
fpsp_upper_13E_1EA:     /* set %d2 */
    movel %d1,%d2
    movel %d3,%d1
    movel %fp@(-60),%d3
    moveal %d0,%a1
    movel %d3,%d0
    tstl %d1
    jbne fpsp_upper_13E_214
    tstl %d2
    jbeq fpsp_upper_13E_2D6
    movel %d2,%d1
    moveq #0,%d2
    subil #32,%d0
    bfffo %d1,0,0,%d6
    lsll %d6,%d1
    subl %d6,%d0
    jbra fpsp_upper_13E_226
fpsp_upper_13E_214:     /* from here: jbmi fpsp_upper_13E_226 */
    jbmi fpsp_upper_13E_226
    bfffo %d1,0,0,%d6
    subl %d6,%d0
    lsll %d6,%d1
    bfextu %d2,0,%d6,%d7
    lsll %d6,%d2
    orl %d7,%d1
fpsp_upper_13E_226:     /* test #64,%d0 */
    cmpil #64,%d0
    jbge fpsp_upper_13E_23C
    addil #126,%d0
    addil #126,%d3
    addql #1,%a2
fpsp_upper_13E_23C:     /* set %fp@(-100) */
    movew %d0,%fp@(-100)
    clrw %fp@(-98)
    movel %d1,%fp@(-96)
    movel %d2,%fp@(-92)
    movew %d3,%fp@(-116)
    clrw %fp@(-114)
    movel %d4,%fp@(-112)
    movel %d5,%fp@(-108)
    fmovex %fp@(-100),%fp0
    tstl %fp@(-68)
    jbeq fpsp_upper_13E_282
    subql #1,%d3
    cmpl %d3,%d0
    jblt fpsp_upper_13E_282
    jbgt fpsp_upper_13E_27A
    cmpl %d4,%d1
    jbne fpsp_upper_13E_278
    cmpl %d5,%d2
    jbeq fpsp_upper_13E_2DE
fpsp_upper_13E_278:     /* from here: jbcs fpsp_upper_13E_282 */
    jbcs fpsp_upper_13E_282
fpsp_upper_13E_27A:     /* from here: fsubx %fp@(-116),%fp0 */
    fsubx %fp@(-116),%fp0
    addql #1,%a1
fpsp_upper_13E_282:     /* loop: move */
    movew %a0@(-12),%d6
    jbpl fpsp_upper_13E_28C
    fnegx %fp0,%fp0
fpsp_upper_13E_28C:     /* set %d7 */
    movew %a0@,%d7
    eorw %d7,%d6
    lsrl #8,%d6
    andil #128,%d6
    movel %a1,%d7
    andil #127,%d7
    orl %d7,%d6
    swap %d6
    fmovel %fpsr,%d7
    andil #-16711681,%d7
    orl %d6,%d7
    fmovel %d7,%fpsr
    movel %a2,%d0
    moveml %sp@+,%d2-%d7/%a2
    fmovel %fp@(-128),%fpcr
    tstl %d0
    jbeq fpsp_upper_13E_2D0
    fmuls #0x00800000,%fp0	| 4089195A
    jbra fpsp_xdep_54
fpsp_upper_13E_2D0:     /* from here: fmovex %fp0,%fp0 */
    fmovex %fp0,%fp0
    rts
fpsp_upper_13E_2D6:     /* from here: fmoveb #0,%fp0 */
    fmoveb #0,%fp0
    jbra fpsp_upper_13E_282
fpsp_upper_13E_2DE:     /* set %d6 */
    movel %a1,%d6
    andib #1,%d6
    jbeq fpsp_upper_13E_282
    addql #1,%a1
    fnegx %fp0,%fp0
    jbra fpsp_upper_13E_282

fpsp_upper_42C:         /* from here: divul %d4,%d3,%d1 */
    divul %d4,%d3,%d1
    jbvs fpsp_upper_42C_20
    movel %d1,%d0
    movel %d1,%d7
    mulul %d5,%d6,%d7
fpsp_upper_42C_E:       /* loop: move */
    movel %d2,%d1
    subl %d7,%d1
    subxl %d6,%d3
    jbcc fpsp_upper_42C_1E
fpsp_upper_42C_16:      /* loop: subq */
    subql #1,%d0
    addl %d5,%d1
    addxl %d4,%d3
    jbcc fpsp_upper_42C_16
fpsp_upper_42C_1E:      /* return */
    rts
fpsp_upper_42C_20:      /* set %d6 */
    movel %d5,%d6
    moveq #0,%d7
    movel %d1,%d3
    moveq #0,%d0
    jbra fpsp_upper_42C_E
    .short  0x3FFF	| 408919AE
    .long   0x400CF23C, 0x90000000, 0x00007200, 0x322EFF28	| 408919B0
    .long   0x5BEEFFAC, 0x02810000, 0x7FFF302E, 0xFF340240	| 408919C0
    .long   0x7FFF02FA, 0x0000FFD8, 0x642A0C40, 0x400C6C00	| 408919D0
    .short  0x0252, 0x102E, 0xFF20, 0x0200, 0x00E0	| 408919E0
    tstb %d0
    jbeq fpsp_no_denorm
    lea %fp@(-216),%a0
    jbra fpsp_src_dis_24
fpsp_no_denorm:         /* from here: fmovel %fp@(-128),%fpcr */
    fmovel %fp@(-128),%fpcr
    fmovex %fp@(-216),%fp0
    rts
    fmovex %fp@(-204),%fp0
    fmovel #16,%fpcr
    fmovel %fp0,%d0
    fmovel #0,%fpsr
    tstw %fp@(-204)
    bltw fpsp_no_denorm_A2_12
    tstw %d1
    beqw fpsp_no_denorm_1A8_8
    addl %d0,%d1
    beqs fpsp_no_denorm_68_16
    cmpil #32767,%d1
    bges fpsp_no_denorm_5E
    tstb %fp@(-84)
    beqs fpsp_no_denorm_4C
    oriw #-32768,%d1
fpsp_no_denorm_4C:
    movew %d1,%fp@(-216)
    fmovel %fp@(-128),%fpcr
    fmovex %fp@(-216),%fp0
    rts
fpsp_no_denorm_5E:
    tstb %fp@(-84)
    jbeq fpsp_no_denorm_68
    oriw #-32768,%d1
fpsp_no_denorm_68:      /* set %fp@(-204) */
    movew %fp@(-216),%fp@(-204)
    movel %fp@(-212),%fp@(-200)
    movel %fp@(-208),%fp@(-196)
    jbra fpsp_t_ovfl2
fpsp_no_denorm_68_16:
    tstb %fp@(-84)
    jbeq fpsp_no_denorm_88
    oriw #-32768,%d1
fpsp_no_denorm_88:      /* test %fp@(-212) */
    tstl %fp@(-212)
    jblt fpsp_no_denorm_A2
    movew %d1,%fp@(-216)
    oril #2048,%fp@(-124)
    lea %fp@(-216),%a0
    jbra fpsp_src_dis_24
fpsp_no_denorm_A2:      /* set %fp@(-216) */
    movew %d1,%fp@(-216)
    fmovel %fp@(-128),%fpcr
    fmovex %fp@(-216),%fp0
    rts
fpsp_no_denorm_A2_12:
    addl %d0,%d1
    beqs fpsp_no_denorm_68_16
    blts fpsp_no_denorm_A2_34
    tstb %fp@(-84)
    beqs fpsp_no_denorm_A2_22
    oriw #-32768,%d1
fpsp_no_denorm_A2_22:
    movew %d1,%fp@(-216)
    fmovel %fp@(-128),%fpcr
    fmovex %fp@(-216),%fp0
    rts
fpsp_no_denorm_A2_34:
    movew %d1,%d0
    moveml %d2-%d3,%sp@-
    movel %fp@(-212),%d1
    movel %fp@(-208),%d2
    moveq #0,%d3
    cmpiw #-32,%d0
    jbgt fpsp_no_denorm_104
    movel %d2,%d3
    movel %d1,%d2
    moveq #0,%d1
    addiw #32,%d0
    jbeq fpsp_no_denorm_114
    cmpiw #-32,%d0
    jbge fpsp_no_denorm_104
    moveq #0,%d2
    moveq #1,%d3
    jbra fpsp_no_denorm_114
fpsp_no_denorm_104:     /* loop: lsr */
    lsrl #1,%d1
    roxrl #1,%d2
    roxrl #1,%d3
    jbcc fpsp_no_denorm_110
    orib #1,%d3
fpsp_no_denorm_110:     /* add 1 to %d0 */
    addqw #1,%d0
    jbne fpsp_no_denorm_104
fpsp_no_denorm_114:     /* clear %fp@(-216) */
    clrw %fp@(-216)
    tstb %fp@(-84)
    jbeq fpsp_no_denorm_124
    oriw #-32768,%fp@(-216)
fpsp_no_denorm_124:     /* from here: oril #2048,%fp@(-124) */
    oril #2048,%fp@(-124)
    tstl %d3
    jbeq fpsp_no_denorm_172
    oril #2600,%fp@(-124)
    bfextu %fp@(-125),2,2,%d0
    jbeq fpsp_no_denorm_15C
    btst #1,%d0
    jbeq fpsp_no_denorm_172
    btst #0,%d0
    jbne fpsp_no_denorm_154
    tstb %fp@(-84)
    jbne fpsp_no_denorm_16C
    jbra fpsp_no_denorm_172
fpsp_no_denorm_154:     /* test %fp@(-84) */
    tstb %fp@(-84)
    jbeq fpsp_no_denorm_16C
    jbra fpsp_no_denorm_172
fpsp_no_denorm_15C:     /* test %d3 */
    tstl %d3
    jbpl fpsp_no_denorm_172
    bftst %d3,1,31
    jbne fpsp_no_denorm_16C
    btst #0,%d2
    jbeq fpsp_no_denorm_172
fpsp_no_denorm_16C:     /* clear %d0 */
    moveq #0,%d0
    addql #1,%d2
    addxl %d0,%d1
fpsp_no_denorm_172:     /* set %fp@(-212) */
    movel %d1,%fp@(-212)
    movel %d2,%fp@(-208)
    movel %d2,%d0
    moveml %sp@+,%d2-%d3
    orl %d1,%d0
    jbne fpsp_no_denorm_192
    fmovel %fp@(-128),%fpcr
    fmovex %fp@(-216),%fp0
    rts
fpsp_no_denorm_192:     /* from here: oril #2048,%fp@(-124) */
    oril #2048,%fp@(-124)
    tstb %fp@(-84)
    jbeq fpsp_no_denorm_1A8
    oril #134217728,%fp@(-124)
fpsp_no_denorm_1A8:     /* address %fp@(-216) */
    lea %fp@(-216),%a0
    jbra fpsp_src_dis_24
fpsp_no_denorm_1A8_8:
    moveml %d2-%d3,%sp@-
    movew %fp@(-216),%d1
    movel %fp@(-212),%d2
    movel %fp@(-208),%d3
fpsp_no_denorm_1C0:     /* loop: tst */
    tstl %d2
    jblt fpsp_no_denorm_1D0
    tstl %d0
    jbeq fpsp_dnrm_pos_24
    subql #1,%d0
    lsll #1,%d3
    roxll #1,%d2
    jbra fpsp_no_denorm_1C0
fpsp_no_denorm_1D0:     /* from here: addw %d0,%d1 */
    addw %d0,%d1
    tstb %fp@(-84)
    jbeq fpsp_dnrm_pos
    oril #32768,%d1
fpsp_dnrm_pos:          /* set %fp@(-216) */
    movemw %d1,%fp@(-216)
    moveml %d2,%fp@(-212)
    moveml %d3,%fp@(-208)
    fmovel %fp@(-128),%fpcr
    fmovex %fp@(-216),%fp0
    moveml %sp@+,%d2-%d3
    rts
fpsp_dnrm_pos_24:       /* test %fp@(-84) */
    tstb %fp@(-84)
    jbeq fpsp_dnrm_pos_38
    oril #134217728,%fp@(-124)
    oril #32768,%d1
fpsp_dnrm_pos_38:       /* set %fp@(-216) */
    movemw %d1,%fp@(-216)
    moveml %d2,%fp@(-212)
    moveml %d3,%fp@(-208)
    oril #2048,%fp@(-124)
    moveml %sp@+,%d2-%d3
    lea %fp@(-216),%a0
    jbra fpsp_src_dis_24
    tstb %fp@(-84)
    jbeq fpsp_dnrm_pos_6A
    oril #32768,%d1
fpsp_dnrm_pos_6A:       /* set %fp@(-200) */
    movel %fp@(-212),%fp@(-200)
    movel %fp@(-208),%fp@(-196)
    tstw %fp@(-204)
    jblt fpsp_dnrm_pos_84
    movew %d1,%fp@(-204)
    jbra fpsp_t_ovfl2
fpsp_dnrm_pos_84:       /* set %fp@(-204) */
    movew %d1,%fp@(-204)
    lea %fp@(-204),%a0
    jbra fpsp_op_ena_6
fpsp_dnrm_pos_90:       /* continue at fpsp_src_dis_1A */
    jbra fpsp_src_dis_1A	| 40891C64
fpsp_dnrm_pos_94:       /* set %d0 */
    movel %a0@,%d0	| 40891C68
    movew %a0@(4),%d0	| 40891C6A
    andil #2147483647,%d0	| 40891C6E
    cmpil #1073709056,%d0	| 40891C74
    jbge fpsp_dnrm_pos_EC	| 40891C7A
    fabsx %a0@,%fp0	| 40891C7C
    fmovex %fp0,%fp1	| 40891C80
    fnegx %fp1,%fp1	| 40891C84
    faddx %fp0,%fp0	| 40891C88
    fadds #0e1,%fp1	| 40891C8C
    fdivx %fp1,%fp0	| 40891C94
    movel %a0@,%d0	| 40891C98
    andil #-2147483648,%d0	| 40891C9A
    oril #1056964608,%d0	| 40891CA0
    movel %d0,%sp@-	| 40891CA6
    fmovemx %fp0,%a0@	| 40891CA8
    movel %d1,%sp@-
    moveq #0,%d1
    jbsr fpsp_LP1CONT2_72
    fmovel %sp@+,%fpcr
    fmuls %sp@+,%fp0
    jbra fpsp_ovf_pos_12
fpsp_dnrm_pos_EC:       /* from here: fabsx %a0@,%fp0 */
    fabsx %a0@,%fp0	| 40891CC0
    fcmps #0e1,%fp0	| 40891CC4
    fbgt fpsp_long_d5_A0	| 40891CCC
    jbra fpsp_long_d5_4E	| 40891CD0
fpsp_dnrm_pos_100:      /* from here: fmoves #0e1,%fp0 */
    fmoves #0e1,%fp0	| 40891CD4
    fmovel %d1,%fpcr	| 40891CDC
    fadds #0x00800000,%fp0	| 40891CE0
    jbra fpsp_ovf_pos_12	| 40891CE8
fpsp_dnrm_pos_118:      /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0	| 40891CEC
    movel %a0@,%d0	| 40891CF0
    movew %a0@(4),%d0	| 40891CF2
    andil #2147483647,%d0	| 40891CF6
    cmpil #1074573671,%d0	| 40891CFC
    jbgt fpsp_dnrm_pos_162	| 40891D02
    fabsx %fp0,%fp0	| 40891D04
    movel %d1,%sp@-
    moveq #0,%d1
    fmovemx %fp0,%a0@
    jbsr fpsp_setoxd_24
    fmuls #0e0.5,%fp0
    movel %sp@+,%d1
    fmoves #0e0.25,%fp1
    fdivx %fp0,%fp1
    fmovel %d1,%fpcr
    faddx %fp1,%fp0
    jbra fpsp_ovf_pos_12
fpsp_dnrm_pos_162:      /* test #1074574003,%d0 */
    cmpil #1074574003,%d0	| 40891D36
    jbgt fpsp_dnrm_pos_194	| 40891D3C
    fabsx %fp0,%fp0	| 40891D3E
    fsubd %pc@(fpsp_BIGRZRM_188),%fp0	| 40891D42
    fsubd %pc@(fpsp_BIGRZRM_190),%fp0	| 40891D48
    movel %d1,%sp@-
    moveq #0,%d1
    fmovemx %fp0,%a0@
    jbsr fpsp_setoxd_24
    fmovel %sp@+,%fpcr
    fmulx %pc@(fpsp_BIGRZRM_198),%fp0
    jbra fpsp_ovf_pos_12
fpsp_dnrm_pos_194:      /* (data) */
    .short  0xF23C, 0x8800, 0x0000	| 40891D68
    .short  0x0000, 0x0890	| orib #0x90,%d0
    .short  0x0007, 0xF210	| orib #16,%d7
    addl %d0,%d0
    jbra fpsp_t_ovfl2_54
fpsp_dnrm_pos_1A8:      /* continue at fpsp_src_dis_1A */
    jbra fpsp_src_dis_1A	| 40891D7C

/* fpsp_ssinh: hyperbolic sine. */
fpsp_ssinh:
    fmovex %a0@,%fp0	| 40891D80
    movel %a0@,%d0	| 40891D84
    movew %a0@(4),%d0	| 40891D86
    moveal %d0,%a1	| 40891D8A
    andil #2147483647,%d0	| 40891D8C
    cmpil #1074573671,%d0	| 40891D92
    jbgt fpsp_ssinh_6C	| 40891D98
    fabsx %fp0,%fp0	| 40891D9A
    moveml %d1/%a1,%sp@-	| 40891D9E
    fmovemx %fp0,%a0@	| 40891DA2
    moveq #0,%d1
    jbsr fpsp_EXPCONT1_148
    fmovel #0,%fpcr
    moveml %sp@+,%d1/%a1
    fmovex %fp0,%fp1
    fadds #0e1,%fp1
    fmovex %fp0,%sp@-
    fdivx %fp1,%fp0
    movel %a1,%d0
    andil #-2147483648,%d0
    oril #1056964608,%d0
    faddx %sp@+,%fp0
    movel %d0,%sp@-
    fmovel %d1,%fpcr
    fmuls %sp@+,%fp0
    jbra fpsp_ovf_pos_12
fpsp_ssinh_6C:          /* test #1074574003,%d0 */
    cmpil #1074574003,%d0	| 40891DEC
    jbgt fpsp_t_ovfl2_54	| 40891DF2
    fabsx %fp0,%fp0	| 40891DF6
    fsubd %pc@(fpsp_BIGRZRM_188),%fp0	| 40891DFA
    clrl %sp@-	| 40891E00
    movel #-2147483648,%sp@-	| 40891E02
    movel %a1,%d0	| 40891E08
    andil #-2147483648,%d0	| 40891E0A
    oril #2147155968,%d0	| 40891E10
    movel %d0,%sp@-	| 40891E16
    fsubd %pc@(fpsp_BIGRZRM_190),%fp0	| 40891E18
    movel %d1,%sp@-
    moveq #0,%d1
    fmovemx %fp0,%a0@
    jbsr fpsp_setoxd_24
    fmovel %sp@+,%fpcr
    fmulx %sp@+,%fp0
    jbra fpsp_ovf_pos_12
fpsp_ssinh_B6:          /* (data) */
    .byte   0x3F, 0xD7, 0x80, 0x00, 0x3F, 0xFF, 0xDD, 0xCE	| 40891E36
fpsp_ssinh_BE:          /* continue at fpsp_src_dis_1A */
    jbra fpsp_src_dis_1A	| 40891E3E

/* fpsp_stanh: hyperbolic tangent. */
fpsp_stanh:
    fmovex %a0@,%fp0	| 40891E42
    fmovex %fp0,%fp@(-32)	| 40891E46
    movel %a0@,%d0	| 40891E4C
    movew %a0@(4),%d0	| 40891E4E
    movel %d0,%fp@(-32)	| 40891E52
    andil #2147483647,%d0	| 40891E56
    cmp2l %pc@(fpsp_ssinh_B6),%d0	| 40891E5C
    jbcs fpsp_stanh_7E	| 40891E62
    movel %fp@(-32),%d0	| 40891E64
    movel %d0,%fp@(-68)	| 40891E68
    .byte   0x02, 0x80, 0x7F, 0xFF	| 40891E6C
    .short  0x0000, 0x0680	| orib #0x80,%d0
    orib #0,%d1
    movel %d0,%fp@(-32)
    andil #-2147483648,%fp@(-68)
    fmovex %fp@(-32),%fp0
    movel %d1,%sp@-
    moveq #0,%d1
    fmovemx %fp0,%a0@
    jbsr fpsp_EXPCONT1_148
    movel %sp@+,%d1
    fmovex %fp0,%fp1
    fadds #0e2,%fp1
    movel %fp@(-68),%d0
    fmovex %fp1,%fp@(-16)
    eorl %d0,%fp@(-16)
    fmovel %d1,%fpcr
    fdivx %fp@(-16),%fp0
    jbra fpsp_ovf_pos_12
fpsp_stanh_7E:          /* test #1073709056,%d0 */
    cmpil #1073709056,%d0	| 40891EC0
    jblt fpsp_stanh_FC	| 40891EC6
    cmpil #1074039457,%d0	| 40891EC8
    bgtw fpsp_TANHHUGE	| 40891ECE
    movel %fp@(-32),%d0	| 40891ED2
    movel %d0,%fp@(-68)	| 40891ED6
    .byte   0x02, 0x80, 0x7F, 0xFF	| 40891EDA
    .short  0x0000, 0x0680	| orib #0x80,%d0
    orib #0,%d1
    movel %d0,%fp@(-32)
    andil #-2147483648,%fp@(-68)
    movel %fp@(-68),%d0
    fmovex %fp@(-32),%fp0
    movel %d1,%sp@-
    moveq #0,%d1
    fmovemx %fp0,%a0@
    jbsr fpsp_setoxd_24
    movel %sp@+,%d1
    movel %fp@(-68),%d0
    fadds #0e1,%fp0
    eoril #-1073741824,%d0
    fmoves %d0,%fp1
    fdivx %fp0,%fp1
    movel %fp@(-68),%d0
    oril #1065353216,%d0
    fmoves %d0,%fp0
    fmovel %d1,%fpcr
    faddx %fp1,%fp0
    jbra fpsp_ovf_pos_12
fpsp_stanh_FC:          /* clear %fp@(-30) */
    clrw %fp@(-30)	| 40891F3E
    fmovel %d1,%fpcr	| 40891F42
    fmovex %fp@(-32),%fp0	| 40891F46
    jbra fpsp_ovf_pos_12	| 40891F4C
fpsp_TANHHUGE:          /* constant(s) TANHHUGE */
    movel %fp@(-32),%d0	| 40891F50
    andil #-2147483648,%d0	| 40891F54
    oril #1065353216,%d0	| 40891F5A
    fmoves %d0,%fp0	| 40891F60
    andil #-2147483648,%d0	| 40891F64
    eoril #-2139095040,%d0	| 40891F6A
    fmovel %d1,%fpcr	| 40891F70
    fadds %d0,%fp0	| 40891F74
    jbra fpsp_ovf_pos_12
fpsp_TANHHUGE_2C:       /* continue at fpsp_src_dis_1A */
    jbra fpsp_src_dis_1A	| 40891F7C
fpsp_TANHHUGE_30:       /* from here: fmoves #0e1,%fp0 */
    fmoves #0e1,%fp0	| 40891F80
    fmovel #0,%fpsr	| 40891F88
    jbra fpsp_ovf_pos_12	| 40891F90
fpsp_TANHHUGE_44:       /* clear %fp@(-68) */
    clrl %fp@(-68)	| 40891F94
    jbra fpsp_scos_8	| 40891F98

/* fpsp_scos: cosine (with fpsp_ssin, argument reduction by pi/2). */
fpsp_scos:
    movel #1,%fp@(-68)	| 40891F9A
fpsp_scos_8:            /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0	| 40891FA2
    movel %a0@,%d0	| 40891FA6
    movew %a0@(4),%d0	| 40891FA8
    fmovex %fp0,%fp@(-32)	| 40891FAC
    andil #2147483647,%d0	| 40891FB2
    cmpil #1071087616,%d0	| 40891FB8
    jbge fpsp_scos_2A	| 40891FBE
    jbra fpsp_COSPOLY_92	| 40891FC0
fpsp_scos_2A:           /* test #1074052222,%d0 */
    cmpil #1074052222,%d0	| 40891FC4
    jblt fpsp_scos_38	| 40891FCA
    jbsr fpsp_NODD_84	| 40891FCC
    jbra fpsp_scos_5C	| 40891FD0
fpsp_scos_38:           /* from here: fmovex %fp0,%fp1 */
    fmovex %fp0,%fp1	| 40891FD2
    fmuld %pc@(fpsp_COSB5_10),%fp1	| 40891FD6
    lea %pc@(fpsp_PITBL_200),%a1	| 40891FDC
    fmovel %fp1,%fp@(-80)	| 40891FE0
    movel %fp@(-80),%d0	| 40891FE6
    asll #4,%d0	| 40891FEA
    addal %d0,%a1	| 40891FEC
    fsubx %a1@+,%fp0	| 40891FEE
    fsubs %a1@,%fp0	| 40891FF2
fpsp_scos_5C:           /* set %d0 */
    movel %fp@(-80),%d0	| 40891FF6
    addl %fp@(-68),%d0	| 40891FFA
    rorl #1,%d0	| 40891FFE
    jbmi fpsp_COSPOLY	| 40892000
fpsp_SINPOLY:           /* (data) */
    fmovex %fp0,%fp@(-32)	| 40892002
    fmulx %fp0,%fp0	| 40892008
    fmoved %pc@(fpsp_BIGRZRM_1A8),%fp3	| 4089200C
    fmoved %pc@(fpsp_BIGRZRM_1B0),%fp2	| 40892012
    fmovex %fp0,%fp1	| 40892018
    fmulx %fp1,%fp1	| 4089201C
    rorl #1,%d0	| 40892020
    andil #-2147483648,%d0	| 40892022
    eorl %d0,%fp@(-32)	| 40892028
    fmulx %fp1,%fp3	| 4089202C
    fmulx %fp1,%fp2	| 40892030
    faddd %pc@(fpsp_SINA5),%fp3	| 40892034
    faddd %pc@(fpsp_SINA5_8),%fp2	| 4089203A
    fmulx %fp1,%fp3	| 40892040
    fmulx %fp1,%fp2	| 40892044
    faddd %pc@(fpsp_SINA3),%fp3	| 40892048
    faddx %pc@(fpsp_SINA2),%fp2	| 4089204E
    fmulx %fp3,%fp1
    fmulx %fp0,%fp2
    faddx %pc@(fpsp_SINA1),%fp1
    fmulx %fp@(-32),%fp0
    faddx %fp2,%fp1
    fmulx %fp1,%fp0
    fmovel %d1,%fpcr
    faddx %fp@(-32),%fp0
    jbra fpsp_ovf_pos_12
fpsp_COSPOLY:           /* (data) */
    fmulx %fp0,%fp0	| 4089207E
    fmoved %pc@(fpsp_SINA1_10),%fp2	| 40892082
    fmoved %pc@(fpsp_SINA1_18),%fp3
    fmovex %fp0,%fp1
    fmulx %fp1,%fp1
    fmovex %fp0,%fp@(-32)
    rorl #1,%d0
    andil #-2147483648,%d0
    fmulx %fp1,%fp2
    eorl %d0,%fp@(-32)
    andil #-2147483648,%d0
    fmulx %fp1,%fp3
    oril #1065353216,%d0
    movel %d0,%fp@(-84)
    faddd %pc@(fpsp_COSB6),%fp2
    faddd %pc@(fpsp_COSB5),%fp3
    fmulx %fp1,%fp2
    fmulx %fp1,%fp3
    faddd %pc@(fpsp_COSB5_8),%fp2
    faddx %pc@(fpsp_COSB5_18),%fp3
    fmulx %fp1,%fp2
    fmulx %fp3,%fp1
    faddx %pc@(fpsp_COSB5_28),%fp2
    fadds %pc@(fpsp_COSB5_34),%fp1
    fmulx %fp2,%fp0
    faddx %fp1,%fp0
    fmulx %fp@(-32),%fp0
    fmovel %d1,%fpcr
    fadds %fp@(-84),%fp0
    jbra fpsp_ovf_pos_12
fpsp_COSPOLY_92:        /* set %d0 */
    movel %fp@(-68),%d0	| 40892110
    jbgt fpsp_COSPOLY_AA	| 40892114
    clrw %fp@(-30)	| 40892116
    fmovel %d1,%fpcr	| 4089211A
    fmovex %fp@(-32),%fp0	| 4089211E
    jbra fpsp_ovf_pos_12	| 40892124
fpsp_COSPOLY_AA:        /* from here: fmoves #0e1,%fp0 */
    fmoves #0e1,%fp0	| 40892128
    fmovel %d1,%fpcr	| 40892130
    fsubs #0x00800000,%fp0	| 40892134
    jbra fpsp_ovf_pos_12	| 4089213C
fpsp_COSPOLY_C2:        /* from here: fmoves #0e1,%fp1 */
    fmoves #0e1,%fp1	| 40892140
    jbsr fpsp_NEVEN_11A	| 40892148
    jbra fpsp_src_dis_1A	| 4089214C

/* fpsp_ssincos: sine and cosine at once (FSINCOS). */
fpsp_ssincos:
    movel #4,%fp@(-68)	| 40892150
    fmovex %a0@,%fp0	| 40892158
    movel %a0@,%d0	| 4089215C
    movew %a0@(4),%d0	| 4089215E
    fmovex %fp0,%fp@(-32)	| 40892162
    andil #2147483647,%d0	| 40892168
    cmpil #1071087616,%d0	| 4089216E
    jbge fpsp_ssincos_2A	| 40892174
    jbra fpsp_NEVEN_EA	| 40892176
fpsp_ssincos_2A:        /* test #1074052222,%d0 */
    cmpil #1074052222,%d0	| 4089217A
    jblt fpsp_ssincos_38	| 40892180
    jbsr fpsp_NODD_84	| 40892182
    jbra fpsp_ssincos_5C	| 40892186
fpsp_ssincos_38:        /* from here: fmovex %fp0,%fp1 */
    fmovex %fp0,%fp1	| 40892188
    fmuld %pc@(fpsp_COSB5_10),%fp1	| 4089218C
    lea %pc@(fpsp_PITBL_200),%a1	| 40892192
    fmovel %fp1,%fp@(-80)	| 40892196
    movel %fp@(-80),%d0	| 4089219C
    asll #4,%d0	| 408921A0
    addal %d0,%a1	| 408921A2
    fsubx %a1@+,%fp0	| 408921A4
    fsubs %a1@,%fp0	| 408921A8
fpsp_ssincos_5C:        /* set %d0 */
    movel %fp@(-80),%d0	| 408921AC
    rorl #1,%d0	| 408921B0
    jbpl fpsp_NEVEN	| 408921B2
    fmovex %fp0,%fp@(-116)	| 408921B6
    fmulx %fp0,%fp0	| 408921BC
    fmoved %pc@(fpsp_BIGRZRM_1A8),%fp1	| 408921C0
    fmoved %pc@(fpsp_SINA1_10),%fp2	| 408921C6
    fmulx %fp0,%fp1	| 408921CC
    movel %d2,%sp@-	| 408921D0
    movel %d0,%d2	| 408921D2
    fmulx %fp0,%fp2	| 408921D4
    rorl #1,%d2	| 408921D8
    andil #-2147483648,%d2	| 408921DA
    faddd %pc@(fpsp_BIGRZRM_1B0),%fp1	| 408921E0
    eorl %d0,%d2	| 408921E6
    andil #-2147483648,%d2	| 408921E8
    faddd %pc@(fpsp_SINA1_18),%fp2	| 408921EE
    fmulx %fp0,%fp1	| 408921F4
    eorl %d2,%fp@(-116)	| 408921F8
    movel %sp@+,%d2	| 408921FC
    fmulx %fp0,%fp2	| 408921FE
    rorl #1,%d0	| 40892202
    andil #-2147483648,%d0	| 40892204
    faddd %pc@(fpsp_SINA5),%fp1	| 4089220A
    movel #1065353216,%fp@(-84)	| 40892210
    eorl %d0,%fp@(-84)	| 40892218
    faddd %pc@(fpsp_COSB6),%fp2	| 4089221C
    fmulx %fp0,%fp1	| 40892222
    fmulx %fp0,%fp2	| 40892226
    fmovex %fp0,%fp@(-100)	| 4089222A
    faddd %pc@(fpsp_SINA5_8),%fp1	| 40892230
    eorl %d0,%fp@(-100)	| 40892236
    faddd %pc@(fpsp_COSB5),%fp2	| 4089223A
    fmulx %fp0,%fp1	| 40892240
    fmulx %fp0,%fp2	| 40892244
    faddd %pc@(fpsp_SINA3),%fp1
    faddd %pc@(fpsp_COSB5_8),%fp2
    fmulx %fp0,%fp1
    fmulx %fp0,%fp2
    faddx %pc@(fpsp_SINA2),%fp1
    faddx %pc@(fpsp_COSB5_18),%fp2
    fmulx %fp0,%fp1
    fmulx %fp0,%fp2
    faddx %pc@(fpsp_SINA1),%fp1
    faddx %pc@(fpsp_COSB5_28),%fp2
    fmulx %fp0,%fp1
    fmulx %fp2,%fp0
    fmulx %fp@(-116),%fp1
    fadds %pc@(fpsp_COSB5_34),%fp0
    fmulx %fp@(-100),%fp0
    movel %d1,%sp@-
    andil #255,%d1
    fmovel %d1,%fpcr
    faddx %fp@(-116),%fp1
    jbsr fpsp_NEVEN_11A
    fmovel %sp@+,%fpcr
    fadds %fp@(-84),%fp0
    jbra fpsp_ovf_pos_12
fpsp_NEVEN:             /* (data) */
    fmovex %fp0,%fp@(-116)	| 408922BA
    fmulx %fp0,%fp0	| 408922C0
    fmoved %pc@(fpsp_SINA1_10),%fp1	| 408922C4
    fmoved %pc@(fpsp_BIGRZRM_1A8),%fp2	| 408922CA
    fmulx %fp0,%fp1	| 408922D0
    fmovex %fp0,%fp@(-100)	| 408922D4
    fmulx %fp0,%fp2	| 408922DA
    rorl #1,%d0	| 408922DE
    andil #-2147483648,%d0	| 408922E0
    faddd %pc@(fpsp_SINA1_18),%fp1	| 408922E6
    faddd %pc@(fpsp_BIGRZRM_1B0),%fp2	| 408922EC
    eorl %d0,%fp@(-116)	| 408922F2
    eorl %d0,%fp@(-100)	| 408922F6
    fmulx %fp0,%fp1	| 408922FA
    oril #1065353216,%d0	| 408922FE
    movel %d0,%fp@(-84)	| 40892304
    fmulx %fp0,%fp2	| 40892308
    faddd %pc@(fpsp_COSB6),%fp1	| 4089230C
    faddd %pc@(fpsp_SINA5),%fp2	| 40892312
    fmulx %fp0,%fp1	| 40892318
    fmulx %fp0,%fp2	| 4089231C
    faddd %pc@(fpsp_COSB5),%fp1	| 40892320
    faddd %pc@(fpsp_SINA5_8),%fp2	| 40892326
    fmulx %fp0,%fp1	| 4089232C
    fmulx %fp0,%fp2	| 40892330
    faddd %pc@(fpsp_COSB5_8),%fp1	| 40892334
    faddd %pc@(fpsp_SINA3),%fp2	| 4089233A
    fmulx %fp0,%fp1	| 40892340
    fmulx %fp0,%fp2	| 40892344
    faddx %pc@(fpsp_COSB5_18),%fp1	| 40892348
    faddx %pc@(fpsp_SINA2),%fp2	| 4089234E
    fmulx %fp0,%fp1	| 40892354
    fmulx %fp0,%fp2	| 40892358
    faddx %pc@(fpsp_COSB5_28),%fp1	| 4089235C
    faddx %pc@(fpsp_SINA1),%fp2	| 40892362
    fmulx %fp0,%fp1	| 40892368
    fmulx %fp2,%fp0	| 4089236C
    fadds %pc@(fpsp_COSB5_34),%fp1	| 40892370
    fmulx %fp@(-116),%fp0	| 40892376
    fmulx %fp@(-100),%fp1	| 4089237C
    movel %d1,%sp@-	| 40892382
    andil #255,%d1	| 40892384
    fmovel %d1,%fpcr	| 4089238A
    fadds %fp@(-84),%fp1	| 4089238E
    jbsr fpsp_NEVEN_11A	| 40892394
    fmovel %sp@+,%fpcr	| 40892396
    faddx %fp@(-116),%fp0	| 4089239A
    jbra fpsp_ovf_pos_12	| 408923A0
fpsp_NEVEN_EA:          /* clear %fp@(-30) */
    clrw %fp@(-30)	| 408923A4
    fmoves #0e1,%fp1	| 408923A8
    movel %d1,%sp@-	| 408923B0
    andil #255,%d1	| 408923B2
    fmovel %d1,%fpcr	| 408923B8
    fsubs #0x00800000,%fp1	| 408923BC
    jbsr fpsp_NEVEN_11A	| 408923C4
    fmovel %sp@+,%fpcr	| 408923C6
    fmovex %fp@(-32),%fp0	| 408923CA
    jbra fpsp_ovf_pos_12	| 408923D0

fpsp_NEVEN_11A:         /* from here: bfextu %fp@(-228),13,3,%d0 */
    bfextu %fp@(-228),13,3,%d0
    cmpib #3,%d0
    jble fpsp_NEVEN_11A_1E
    fmovemx %fp1,%sp@-
    moveq #7,%d1
    subl %d0,%d1
    moveq #0,%d0
    bset %d1,%d0
    fmovemx %sp@+,%d0
    rts
fpsp_NEVEN_11A_1E:      /* test #0,%d0 */
    cmpib #0,%d0
    jbeq fpsp_c_is_fp2_10
    cmpib #1,%d0
    jbeq fpsp_c_is_fp2_8
    cmpib #2,%d0
    jbeq fpsp_c_is_fp2
fpsp_c_is_fp3:          /* from here: fmovemx %fp1,%fp@(-140) */
    fmovemx %fp1,%fp@(-140)
    rts
fpsp_c_is_fp2:          /* from here: fmovemx %fp1,%fp@(-152) */
    fmovemx %fp1,%fp@(-152)
    rts
fpsp_c_is_fp2_8:        /* from here: fmovemx %fp1,%fp@(-164) */
    fmovemx %fp1,%fp@(-164)
    rts
fpsp_c_is_fp2_10:       /* from here: fmovemx %fp1,%fp@(-176) */
    fmovemx %fp1,%fp@(-176)
    rts
fpsp_c_is_fp2_18:       /* continue at fpsp_src_dis_1A */
    jbra fpsp_src_dis_1A	| 40892424
fpsp_c_is_fp2_1C:       /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0	| 40892428
    movel %a0@,%d0	| 4089242C
    movew %a0@(4),%d0	| 4089242E
    andil #2147483647,%d0	| 40892432
    cmpil #1071087616,%d0	| 40892438
    jbge fpsp_c_is_fp2_38	| 4089243E
    jbra fpsp_NODD_74	| 40892440
fpsp_c_is_fp2_38:       /* test #1074052222,%d0 */
    cmpil #1074052222,%d0	| 40892444
    jblt fpsp_c_is_fp2_4C	| 4089244A
    jbsr fpsp_NODD_84	| 4089244C
    movel %fp@(-80),%d0	| 40892450
    rorl #1,%d0	| 40892454
    jbra fpsp_c_is_fp2_72	| 40892456
fpsp_c_is_fp2_4C:       /* from here: fmovex %fp0,%fp1 */
    fmovex %fp0,%fp1	| 40892458
    fmuld %pc@(fpsp_COSB5_10),%fp1	| 4089245C
    lea %pc@(fpsp_PITBL_200),%a1	| 40892462
    fmovel %fp1,%d0	| 40892466
    asll #4,%d0	| 4089246A
    addal %d0,%a1	| 4089246C
    fsubx %a1@+,%fp0	| 4089246E
    fsubs %a1@,%fp0	| 40892472
    rorl #5,%d0	| 40892476
    andil #-2147483648,%d0	| 40892478
fpsp_c_is_fp2_72:       /* from here: jbmi fpsp_NODD */
    jbmi fpsp_NODD	| 4089247E
    fmovex %fp0,%fp1	| 40892480
    fmulx %fp1,%fp1	| 40892484
    fmoved %pc@(fpsp_COSB5_38),%fp3	| 40892488
    fmoved %pc@(fpsp_TANP3),%fp2	| 4089248E
    fmulx %fp1,%fp3	| 40892494
    fmulx %fp1,%fp2	| 40892498
    faddd %pc@(fpsp_TANQ3),%fp3	| 4089249C
    faddx %pc@(fpsp_TANP2),%fp2	| 408924A2
    fmulx %fp1,%fp3	| 408924A8
    fmulx %fp1,%fp2	| 408924AC
    faddx %pc@(fpsp_TANQ2),%fp3	| 408924B0
    faddx %pc@(fpsp_TANP1),%fp2	| 408924B6
    fmulx %fp1,%fp3	| 408924BC
    fmulx %fp1,%fp2	| 408924C0
    faddx %pc@(fpsp_TANP1_10),%fp3	| 408924C4
    fmulx %fp0,%fp2	| 408924CA
    fmulx %fp3,%fp1	| 408924CE
    faddx %fp2,%fp0	| 408924D2
    fadds #0e1,%fp1	| 408924D6
    fmovel %d1,%fpcr	| 408924DE
    fdivx %fp1,%fp0	| 408924E2
    jbra fpsp_ovf_pos_12	| 408924E6
fpsp_NODD:              /* (data) */
    fmovex %fp0,%fp1	| 408924EA
    fmulx %fp0,%fp0	| 408924EE
    fmoved %pc@(fpsp_COSB5_38),%fp3	| 408924F2
    fmoved %pc@(fpsp_TANP3),%fp2	| 408924F8
    fmulx %fp0,%fp3	| 408924FE
    fmulx %fp0,%fp2	| 40892502
    faddd %pc@(fpsp_TANQ3),%fp3	| 40892506
    faddx %pc@(fpsp_TANP2),%fp2	| 4089250C
    fmulx %fp0,%fp3	| 40892512
    fmulx %fp0,%fp2	| 40892516
    faddx %pc@(fpsp_TANQ2),%fp3	| 4089251A
    faddx %pc@(fpsp_TANP1),%fp2	| 40892520
    fmulx %fp0,%fp3	| 40892526
    fmulx %fp0,%fp2	| 4089252A
    faddx %pc@(fpsp_TANP1_10),%fp3	| 4089252E
    fmulx %fp1,%fp2	| 40892534
    fmulx %fp3,%fp0	| 40892538
    faddx %fp2,%fp1	| 4089253C
    fadds #0e1,%fp0	| 40892540
    fmovex %fp1,%sp@-	| 40892548
    eoril #-2147483648,%sp@	| 4089254C
    fmovel %d1,%fpcr	| 40892552
    fdivx %sp@+,%fp0	| 40892556
    jbra fpsp_ovf_pos_12	| 4089255A
fpsp_NODD_74:           /* from here: fmovex %fp0,%sp@- */
    fmovex %fp0,%sp@-	| 4089255E
    fmovel %d1,%fpcr	| 40892562
    fmovex %sp@+,%fp0	| 40892566
    jbra fpsp_ovf_pos_12	| 4089256A
fpsp_NODD_84:           /* from here: fmovemx %fp2-%fp5,%sp@- */
    fmovemx %fp2-%fp5,%sp@-	| 4089256E
    movel %d2,%sp@-	| 40892572
    fmoves #0e0,%fp1	| 40892574
    cmpil #2147418111,%d0	| 4089257C
    jbne fpsp_LOOP	| 40892582
    movel #2147352576,%fp@(-100)	| 40892584
    movel #-921707870,%fp@(-96)	| 4089258C
    clrl %fp@(-92)	| 40892594
    ftstx %fp0	| 40892598
    movel #2145124352,%fp@(-64)	| 4089259C
    movel #-2052912941,%fp@(-60)	| 408925A4
    clrl %fp@(-56)	| 408925AC
    fblt fpsp_red_neg	| 408925B0
    oriw #-32768,%fp@(-100)	| 408925B4
    oriw #-32768,%fp@(-64)	| 408925BA
fpsp_red_neg:           /* (data) */
    faddx %fp@(-100),%fp0	| 408925C0
    fmovex %fp0,%fp1	| 408925C6
    faddx %fp@(-64),%fp0	| 408925CA
    fsubx %fp0,%fp1	| 408925D0
    faddx %fp@(-64),%fp1	| 408925D4
fpsp_LOOP:              /* (data) */
    fmovex %fp0,%fp@(-48)	| 408925DA
    movew %fp@(-48),%d0	| 408925E0
    moveal %d0,%a1	| 408925E4
    andil #32767,%d0	| 408925E6
    subil #16383,%d0	| 408925EC
    cmpil #28,%d0	| 408925F2
    jble fpsp_LOOP_2C	| 408925F8
    subil #27,%d0	| 408925FA
    clrl %fp@(-80)	| 40892600
    jbra fpsp_WORK	| 40892604
fpsp_LOOP_2C:           /* clear %d0 */
    moveq #0,%d0	| 40892606
    movel #1,%fp@(-80)	| 40892608
fpsp_WORK:              /* (data) */
    movel #16382,%d2	| 40892610
    subl %d0,%d2	| 40892616
    movel #-1560706194,%fp@(-112)	| 40892618
    movel #1313084714,%fp@(-108)	| 40892620
    movew %d2,%fp@(-116)	| 40892628
    fmovex %fp0,%fp2	| 4089262C
    fmulx %fp@(-116),%fp2	| 40892630
    movel %a1,%d2	| 40892636
    swap %d2	| 40892638
    andil #-2147483648,%d2	| 4089263A
    oril #1593835520,%d2	| 40892640
    movel %d2,%fp@(-84)	| 40892646
    movel %d0,%d2	| 4089264A
    addil #16383,%d2	| 4089264C
    fadds %fp@(-84),%fp2	| 40892652
    movew %d2,%fp@(-100)	| 40892658
    clrw %fp@(-98)	| 4089265C
    movel #-921707870,%fp@(-96)	| 40892660
    clrl %fp@(-92)	| 40892668
    fsubs %fp@(-84),%fp2	| 4089266C
    addil #16349,%d0	| 40892672
    movew %d0,%fp@(-64)	| 40892678
    clrw %fp@(-62)	| 4089267C
    movel #-2052912941,%fp@(-60)	| 40892680
    clrl %fp@(-56)	| 40892688
    movel %fp@(-80),%d0	| 4089268C
    fmovex %fp2,%fp4	| 40892690
    fmulx %fp@(-100),%fp4	| 40892694
    fmovex %fp2,%fp5	| 4089269A
    fmulx %fp@(-64),%fp5	| 4089269E
    fmovex %fp4,%fp3	| 408926A4
    faddx %fp5,%fp3	| 408926A8
    fsubx %fp3,%fp4	| 408926AC
    fsubx %fp3,%fp0	| 408926B0
    faddx %fp5,%fp4	| 408926B4
    fmovex %fp0,%fp3	| 408926B8
    fsubx %fp4,%fp1	| 408926BC
    faddx %fp1,%fp0	| 408926C0
    tstl %d0	| 408926C4
    jbgt fpsp_WORK_C4	| 408926C6
    fsubx %fp0,%fp3	| 408926C8
    faddx %fp3,%fp1	| 408926CC
    jbra fpsp_LOOP	| 408926D0
fpsp_WORK_C4:           /* from here: fmovel %fp2,%fp@(-80) */
    fmovel %fp2,%fp@(-80)	| 408926D4
    movel %sp@+,%d2	| 408926DA
    fmovemx %sp@+,%fp2-%fp5	| 408926DC
    rts	| 408926E0

/* fpsp_setoxd: e to the x for a denormalised x. */
fpsp_setoxd:
    movel %a0@,%d0	| 408926E2
    andil #-2147483648,%d0	| 408926E4
    oril #8388608,%d0	| 408926EA
    movel %d0,%sp@-	| 408926F0
    fmoves #0e1,%fp0	| 408926F2
    fmovel %d1,%fpcr	| 408926FA
    fadds %sp@+,%fp0	| 408926FE
    jbra fpsp_ovf_pos_12	| 40892702

fpsp_setoxd_24:         /* set %d0 */
    movel %a0@,%d0
    andil #2147418112,%d0
    cmpil #1069416448,%d0
    jbge fpsp_setoxd_24_14
    jbra fpsp_EXPCONT1_AA
fpsp_setoxd_24_14:      /* loop: move */
    movew %a0@(4),%d0
    cmpil #1074573671,%d0
    jblt fpsp_setoxd_24_24
    jbra fpsp_EXPCONT1_BE
fpsp_setoxd_24_24:      /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0
    fmovex %fp0,%fp1
    fmuls #0x42b8aa3b,%fp0	| 40892732
    fmovemx %fp2-%fp3,%sp@-
    clrl %fp@(-80)
    fmovel %fp0,%d0
    lea %pc@(fpsp_TWON140_8),%a1
    fmovel %d0,%fp0
    movel %d0,%fp@(-84)
    andil #63,%d0
    lsll #4,%d0
    addal %d0,%a1
    movel %fp@(-84),%d0
    asrl #6,%d0
    addiw #16383,%d0
    movew %pc@(fpsp_L2),%fp@(-84)
fpsp_EXPCONT1:          /* loop: fmovex */
    fmovex %fp0,%fp2
    fmuls #0xbc317218,%fp0	| 40892770
    fmulx %pc@(fpsp_L2),%fp2
    faddx %fp1,%fp0
    faddx %fp2,%fp0
    fmovex %fp0,%fp1
    fmulx %fp1,%fp1
    fmoves #0x3ab60b70,%fp2	| 4089278E
    fmulx %fp1,%fp2
    fmovex %fp1,%fp3
    fmuls #0x3c088895,%fp3	| 4089279E
    faddd %pc@(fpsp_L2_10),%fp2
    faddd %pc@(fpsp_L2_18),%fp3
    fmulx %fp1,%fp2
    movew %d0,%fp@(-116)
    clrw %fp@(-114)
    movel #-2147483648,%fp@(-112)
    clrl %fp@(-108)
    fmulx %fp1,%fp3
    fadds #0e0.5,%fp2
    fmulx %fp0,%fp3
    fmulx %fp1,%fp2
    faddx %fp3,%fp0
    fmovex %a1@+,%fp1
    faddx %fp2,%fp0
    fmulx %fp1,%fp0
    fmovemx %sp@+,%fp2-%fp3
    fadds %a1@,%fp0
    faddx %fp1,%fp0
    movel %fp@(-80),%d0
    tstl %d0
    jbeq fpsp_EXPCONT1_9C
    fmulx %fp@(-100),%fp0
fpsp_EXPCONT1_9C:       /* from here: fmovel %d1,%fpcr */
    fmovel %d1,%fpcr
    fmulx %fp@(-116),%fp0
    jbra fpsp_ovf_pos_12
fpsp_EXPCONT1_AA:       /* from here: fmovemx %a0@,%fp0 */
    fmovemx %a0@,%fp0
    fmovel %d1,%fpcr
    fadds #0e1,%fp0
    jbra fpsp_ovf_pos_12
fpsp_EXPCONT1_BE:       /* test #1074573948,%d0 */
    cmpil #1074573948,%d0
    jbgt fpsp_EXPCONT1_130
    fmovex %a0@,%fp0
    fmovex %fp0,%fp1
    fmuls #0x42b8aa3b,%fp0	| 4089283A
    fmovemx %fp2-%fp3,%sp@-
    movel #1,%fp@(-80)
    fmovel %fp0,%d0
    lea %pc@(fpsp_TWON140_8),%a1
    fmovel %d0,%fp0
    movel %d0,%fp@(-84)
    andil #63,%d0
    lsll #4,%d0
    addal %d0,%a1
    movel %fp@(-84),%d0
    asrl #6,%d0
    movel %d0,%fp@(-84)
    asrl #1,%d0
    subl %d0,%fp@(-84)
    addiw #16383,%d0
    movew %d0,%fp@(-100)
    clrw %fp@(-98)
    movel #-2147483648,%fp@(-96)	| 40892884
    clrl %fp@(-92)
    movel %fp@(-84),%d0
    addiw #16383,%d0
    jbra fpsp_EXPCONT1
fpsp_EXPCONT1_130:      /* from here: fmovel %d1,%fpcr */
    fmovel %d1,%fpcr
    movel %a0@,%d0
    bclr #7,%a0@
    tstl %d0
    jbmi fpsp_op_ena_6
    jbra fpsp_t_ovfl2_54
fpsp_EXPCONT1_144:      /* continue at fpsp_src_dis_1A */
    jbra fpsp_src_dis_1A	| 408928B0

fpsp_EXPCONT1_148:      /* set %d0 */
    movel %a0@,%d0
    andil #2147418112,%d0
    cmpil #1073545216,%d0
    jbge fpsp_EXPCONT1_148_14
    jbra fpsp_MGEN3_20
fpsp_EXPCONT1_148_14:   /* set %d0 */
    movew %a0@(4),%d0
    cmpil #1074053653,%d0
    jble fpsp_EM1MAIN
    jbra fpsp_EM1POLY_AA
fpsp_EM1MAIN:           /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0
    fmovex %fp0,%fp1
    fmuls #0x42b8aa3b,%fp0	| 408928E0
    fmovemx %fp2-%fp3,%sp@-
    fmovel %fp0,%d0
    lea %pc@(fpsp_TWON140_8),%a1
    fmovel %d0,%fp0
    movel %d0,%fp@(-84)
    andil #63,%d0
    lsll #4,%d0
    addal %d0,%a1
    movel %fp@(-84),%d0
    asrl #6,%d0
    movel %d0,%fp@(-84)
    fmovex %fp0,%fp2
    fmuls #0xbc317218,%fp0	| 40892914
    fmulx %pc@(fpsp_L2),%fp2
    faddx %fp1,%fp0
    faddx %fp2,%fp0
    addiw #16383,%d0
    fmovex %fp0,%fp1
    fmulx %fp1,%fp1
    fmoves #0x3950097b,%fp2	| 40892936
    fmulx %fp1,%fp2
    fmovex %fp1,%fp3
    fmuls #0e0.00138889,%fp3
    faddd %pc@(fpsp_EM1A4),%fp2
    faddd %pc@(fpsp_EM1A3),%fp3
    movew %d0,%fp@(-64)
    clrw %fp@(-62)
    movel #-2147483648,%fp@(-60)
    clrl %fp@(-56)
    fmulx %fp1,%fp2
    movel %fp@(-84),%d0
    negw %d0
    fmulx %fp1,%fp3
    addiw #16383,%d0
    faddd %pc@(fpsp_EM1A2),%fp2
    fadds #0e0.5,%fp3
    fmulx %fp1,%fp2
    oriw #-32768,%d0
    movew %d0,%fp@(-48)
    clrw %fp@(-46)
    movel #-2147483648,%fp@(-44)
    clrl %fp@(-40)
    fmulx %fp3,%fp1
    fmulx %fp0,%fp2
    faddx %fp1,%fp0
    faddx %fp2,%fp0
    fmovemx %sp@+,%fp2-%fp3
    fmulx %a1@,%fp0
    movel %fp@(-84),%d0
    cmpil #63,%d0
    jble fpsp_EM1MAIN_10C
    fmoves %a1@(12),%fp1
    faddx %fp@(-48),%fp1
    faddx %fp1,%fp0
    faddx %a1@,%fp0
    jbra fpsp_MGEN3_12
fpsp_EM1MAIN_10C:       /* test #-3,%d0 */
    cmpil #-3,%d0
    jbge fpsp_MGEN3
    fadds %a1@(12),%fp0
    faddx %a1@,%fp0
    faddx %fp@(-48),%fp0
    jbra fpsp_MGEN3_12
fpsp_MGEN3:             /* from here: fmovex %a1@+,%fp1 */
    fmovex %a1@+,%fp1
    fadds %a1@,%fp0
    faddx %fp@(-48),%fp1
    faddx %fp1,%fp0
fpsp_MGEN3_12:          /* from here: fmovel %d1,%fpcr */
    fmovel %d1,%fpcr
    fmulx %fp@(-64),%fp0
    jbra fpsp_ovf_pos_12
fpsp_MGEN3_20:          /* test #1069416448,%d0 */
    cmpil #1069416448,%d0
    jbge fpsp_EM1POLY
    cmpil #4653056,%d0
    jblt fpsp_MGEN3_56
    movel #65536,%fp@(-64)
    movel #-2147483648,%fp@(-60)
    clrl %fp@(-56)
    fmovex %a0@,%fp0
    fmovel %d1,%fpcr
    faddx %fp@(-64),%fp0
    jbra fpsp_ovf_pos_12
fpsp_MGEN3_56:          /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0
    fmuld %pc@(fpsp_TWO140),%fp0
    movel #65536,%fp@(-64)
    movel #-2147483648,%fp@(-60)
    clrl %fp@(-56)
    faddx %fp@(-64),%fp0
    fmovel %d1,%fpcr
    fmuld %pc@(fpsp_TWON140),%fp0
    jbra fpsp_ovf_pos_12
fpsp_EM1POLY:           /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0
    fmulx %fp0,%fp0
    fmovemx %fp2-%fp3,%sp@-
    fmoves #0x2f30caa8,%fp1	| 40892A92
    fmulx %fp0,%fp1
    fmoves #0x310f8290,%fp2	| 40892A9E
    fadds #0x32d73220,%fp1
    fmulx %fp0,%fp2
    fmulx %fp0,%fp1
    fadds #0x3493f281,%fp2	| 40892AB6
    faddd %pc@(fpsp_EM1A2_10),%fp1
    fmulx %fp0,%fp2
    fmulx %fp0,%fp1
    faddd %pc@(fpsp_EM1A2_18),%fp2
    faddd %pc@(fpsp_EM1A2_20),%fp1
    fmulx %fp0,%fp2
    fmulx %fp0,%fp1
    faddd %pc@(fpsp_EM1B5),%fp2
    faddd %pc@(fpsp_EM1B4),%fp1
    fmulx %fp0,%fp2
    fmulx %fp0,%fp1
    faddd %pc@(fpsp_EM1B3),%fp2
    faddx %pc@(fpsp_EM1B2),%fp1
    fmulx %fp0,%fp2
    fmulx %fp0,%fp1
    fmulx %fp0,%fp2
    fmulx %a0@,%fp1
    fmuls #0e0.5,%fp0
    faddx %fp2,%fp1
    fmovemx %sp@+,%fp2-%fp3
    faddx %fp1,%fp0
    fmovel %d1,%fpcr
fpsp_EM1POLY_A2:        /* from here: faddx %a0@,%fp0 */
    faddx %a0@,%fp0
    jbra fpsp_ovf_pos_12
fpsp_EM1POLY_AA:        /* set %d0 */
    movel %a0@,%d0
    tstl %d0
    jbgt fpsp_setoxd_24_14
    fmoves #0e-1,%fp0
    fmovel %d1,%fpcr
    .long   0xF23C4422	| 40892B44
    oril #24576,%d0
    addal %d4,%sp
fpsp_EM1POLY_CA:        /* from here: fmovel %d1,%fpcr */
    fmovel %d1,%fpcr
    fmoves #0e1,%fp0
    movel %a0@,%d0
    oril #8388609,%d0
    fadds %d0,%fp0
    jbra fpsp_ovf_pos_12
fpsp_EM1POLY_E6:        /* from here: fmovemx %a0@,%fp0 */
    fmovemx %a0@,%fp0	| 40892B6C
    movel %a0@,%d0	| 40892B70
    movew %a0@(4),%d0	| 40892B72
    fmovex %fp0,%fp@(-116)	| 40892B76
    andil #2147483647,%d0	| 40892B7C
    cmpil #1069121536,%d0	| 40892B82
    jbge fpsp_EM1POLY_108	| 40892B88
    jbra fpsp_EM1POLY_1FE	| 40892B8A
fpsp_EM1POLY_108:       /* test #1074626752,%d0 */
    cmpil #1074626752,%d0	| 40892B8E
    jble fpsp_EM1POLY_114	| 40892B94
    jbra fpsp_EM1POLY_1FE	| 40892B96
fpsp_EM1POLY_114:       /* from here: fmovex %fp0,%fp1 */
    fmovex %fp0,%fp1	| 40892B9A
    .byte   0xF2, 0x3C, 0x44, 0xA3, 0x42, 0x80	| 40892B9E
    .short  0x0000, 0xF22E	| orib #46,%d0
    jbra fpsp_EM1POLY_A4
    .short  0xFFAC	| .short 0xffac
    fmovel %fpsr,%d0
    andiw #512,%d0
    bnes fpsp_EM1POLY_190
    movel %fp@(-84),%d0
    bftst %d0,26,6
    bnes fpsp_EM1POLY_190
    asrl #6,%d0
    addil #16383,%d0
    bmis fpsp_EM1POLY_114_44
    cmpil #32767,%d0
    bges fpsp_EM1POLY_190
    movew %d0,%fp@(-116)
    movew #16383,%fp@(-100)
    bras fpsp_EM1POLY_114_52
fpsp_EM1POLY_114_44:
    addil #16383,%d0
    clrl %fp@(-116)
    movew %d0,%fp@(-100)
fpsp_EM1POLY_114_52:
    movel #-2147483648,%fp@(-112)
    clrl %fp@(-108)
    fmovex %fp@(-116),%fp0
    movel #-2147483648,%fp@(-96)
    clrl %fp@(-92)
    fmovel %d1,%fpcr
    fmulx %fp@(-100),%fp0
    rts

fpsp_EM1POLY_190:       /* set %sp@- */
    movel %d2,%sp@-
    lea %pc@(fpsp_EXPTBL),%a1
    fmovel %fp@(-84),%fp1
    movel %fp@(-84),%d0
    movel %d0,%d2
    andil #63,%d0
    asll #4,%d0
    addal %d0,%a1
    asrl #6,%d2
    movel %d2,%d0
    asrl #1,%d0
    subl %d0,%d2
    addil #16383,%d2
    movew %d2,%fp@(-100)
    movel %sp@+,%d2
    fmuls #0e0.015625,%fp1
    movel %a1@+,%fp@(-64)
    movel %a1@+,%fp@(-60)
    movel %a1@+,%fp@(-56)
    movew %a1@+,%fp@(-48)
    clrw %fp@(-46)
    fsubx %fp1,%fp0
    movew %a1@+,%fp@(-44)
    clrw %fp@(-42)
    clrl %fp@(-40)
    addw %d0,%fp@(-64)
    fmulx %pc@(fpsp_LOG2),%fp0
    addw %d0,%fp@(-48)
    jbra fpsp_TENMAIN_86
fpsp_EM1POLY_1FE:       /* loop: cmpi */
    cmpil #1073709056,%d0	| 40892C84
    jbgt fpsp_EM1POLY_216	| 40892C8A
    fmovel %d1,%fpcr	| 40892C8C
    fadds #0e1,%fp0	| 40892C90
    jbra fpsp_ovf_pos_12	| 40892C98
fpsp_EM1POLY_216:       /* set %d0 */
    movel %fp@(-116),%d0	| 40892C9C
    tstl %d0	| 40892CA0
    jbmi fpsp_EM1POLY_226	| 40892CA2
    bclr #7,%a0@	| 40892CA4
    jbra fpsp_t_ovfl2_54	| 40892CA8
fpsp_EM1POLY_226:       /* clear bit 7 of %a0@ */
    bclr #7,%a0@	| 40892CAC
    jbra fpsp_op_ena_6	| 40892CB0
fpsp_EM1POLY_22E:       /* from here: fmovel %d1,%fpcr */
    fmovel %d1,%fpcr	| 40892CB4
    fmoves #0e1,%fp0
    movel %a0@,%d0
    oril #8388609,%d0
    fadds %d0,%fp0
    jbra fpsp_ovf_pos_12
fpsp_EM1POLY_24A:       /* from here: fmovemx %a0@,%fp0 */
    fmovemx %a0@,%fp0	| 40892CD0
    movel %a0@,%d0	| 40892CD4
    movew %a0@(4),%d0	| 40892CD6
    fmovex %fp0,%fp@(-116)	| 40892CDA
    andil #2147483647,%d0	| 40892CE0
    cmpil #1069121536,%d0	| 40892CE6
    jbge fpsp_EM1POLY_26A	| 40892CEC
    jbra fpsp_EM1POLY_1FE	| 40892CEE
fpsp_EM1POLY_26A:       /* test #1074502407,%d0 */
    cmpil #1074502407,%d0	| 40892CF0
    jble fpsp_TENMAIN	| 40892CF6
    jbra fpsp_EM1POLY_1FE	| 40892CF8
fpsp_TENMAIN:           /* (data) */
    fmovex %fp0,%fp1	| 40892CFA
    fmuld %pc@(fpsp_TWON140_408),%fp1	| 40892CFE
    fmovel %fp1,%fp@(-84)	| 40892D04
    movel %d2,%sp@-	| 40892D0A
    lea %pc@(fpsp_EXPTBL),%a1	| 40892D0C
    fmovel %fp@(-84),%fp1	| 40892D10
    movel %fp@(-84),%d0	| 40892D16
    movel %d0,%d2	| 40892D1A
    andil #63,%d0	| 40892D1C
    asll #4,%d0	| 40892D22
    addal %d0,%a1	| 40892D24
    asrl #6,%d2	| 40892D26
    movel %d2,%d0	| 40892D28
    asrl #1,%d0
    subl %d0,%d2
    addil #16383,%d2
    movew %d2,%fp@(-100)
    movel %sp@+,%d2
    fmovex %fp1,%fp2
    fmuld %pc@(fpsp_L10TWO1),%fp1
    movel %a1@+,%fp@(-64)
    fmulx %pc@(fpsp_L10TWO2),%fp2
    movel %a1@+,%fp@(-60)
    movel %a1@+,%fp@(-56)
    fsubx %fp1,%fp0
    movew %a1@+,%fp@(-48)
    fsubx %fp2,%fp0
    clrw %fp@(-46)
    movew %a1@+,%fp@(-44)
    clrw %fp@(-42)
    clrl %fp@(-40)
    fmulx %pc@(fpsp_LOG10),%fp0
    addw %d0,%fp@(-64)
    addw %d0,%fp@(-48)
fpsp_TENMAIN_86:        /* from here: fmovex %fp0,%fp1 */
    fmovex %fp0,%fp1
    fmulx %fp1,%fp1
    fmoved %pc@(fpsp_LOG2_10),%fp2
    fmoved %pc@(fpsp_LOG2_18),%fp3
    fmulx %fp1,%fp2
    fmulx %fp1,%fp3
    faddd %pc@(fpsp_LOG2_20),%fp2
    faddd %pc@(fpsp_LOG2_28),%fp3
    fmulx %fp1,%fp2
    fmulx %fp1,%fp3
    faddd %pc@(fpsp_LOG2_30),%fp2
    fmulx %fp0,%fp3
    fmulx %fp1,%fp2
    faddx %fp3,%fp0
    faddx %fp2,%fp0
    fmulx %fp@(-64),%fp0
    faddx %fp@(-48),%fp0
    faddx %fp@(-64),%fp0
    fmovel %d1,%fpcr
    clrw %fp@(-98)
    movel #-2147483648,%fp@(-96)
    clrl %fp@(-92)
    fmulx %fp@(-100),%fp0
    jbra fpsp_ovf_pos_12
fpsp_TENMAIN_FC:        /* from here: fmovel %d1,%fpcr */
    fmovel %d1,%fpcr	| 40892DF6
    fmovex %pc@(fpsp_PI_10),%fp0	| 40892DFA
    jbra fpsp_ovf_pos_12	| 40892E00
fpsp_TENMAIN_10A:       /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0	| 40892E04
    movel %a0@,%d0	| 40892E08
    movew %a0@(4),%d0	| 40892E0A
    andil #2147483647,%d0	| 40892E0E
    cmpil #1073709056,%d0	| 40892E14
    jbge fpsp_TENMAIN_15A	| 40892E1A
    fmoves #0e1,%fp1	| 40892E1C
    faddx %fp0,%fp1	| 40892E24
    fnegx %fp0,%fp0	| 40892E28
    fadds #0e1,%fp0	| 40892E2C
    fdivx %fp1,%fp0	| 40892E34
    fsqrtx %fp0,%fp0	| 40892E38
    fmovemx %fp0,%a0@	| 40892E3C
    movel %d1,%sp@-
    moveq #0,%d1
    jbsr fpsp_satan
    fmovel %sp@+,%fpcr
    faddx %fp0,%fp0
    jbra fpsp_ovf_pos_12
fpsp_TENMAIN_15A:       /* from here: fabsx %fp0,%fp0 */
    fabsx %fp0,%fp0	| 40892E54
    fcmps #0e1,%fp0	| 40892E58
    fbgt fpsp_long_d5_A0	| 40892E60
    movel %a0@,%d0	| 40892E64
    .byte   0x30, 0x28	| 40892E66
    .short  0x0004, 0x0C80	| orib #0x80,%d4
    orib #0,%d0
    jbgt fpsp_TENMAIN_18E
    fmovex %pc@(fpsp_PI),%fp0
    fmovel %d1,%fpcr
    fadds #0x00800000,%fp0	| 40892E7C
    jbra fpsp_ovf_pos_12
fpsp_TENMAIN_18E:       /* from here: fmovel %d1,%fpcr */
    fmovel %d1,%fpcr
    fmoves #0e0,%fp0
    rts
fpsp_TENMAIN_19C:       /* continue at fpsp_src_dis_1A */
    jbra fpsp_src_dis_1A	| 40892E96
fpsp_TENMAIN_1A0:       /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0	| 40892E9A
    movel %a0@,%d0	| 40892E9E
    movew %a0@(4),%d0	| 40892EA0
    andil #2147483647,%d0	| 40892EA4
    cmpil #1073709056,%d0	| 40892EAA
    jbge fpsp_TENMAIN_1EE	| 40892EB0
    fmoves #0e1,%fp1	| 40892EB2
    fsubx %fp0,%fp1	| 40892EBA
    fmovemx %fp2,%sp@-	| 40892EBE
    fmoves #0e1,%fp2	| 40892EC2
    faddx %fp0,%fp2	| 40892ECA
    fmulx %fp2,%fp1	| 40892ECE
    fmovemx %sp@+,%fp2	| 40892ED2
    fsqrtx %fp1,%fp1	| 40892ED6
    fdivx %fp1,%fp0	| 40892EDA
    fmovemx %fp0,%a0@	| 40892EDE
    jbsr fpsp_satan	| 40892EE2
    jbra fpsp_ovf_pos_12	| 40892EE4
fpsp_TENMAIN_1EE:       /* from here: fabsx %fp0,%fp0 */
    fabsx %fp0,%fp0	| 40892EE8
    fcmps #0e1,%fp0	| 40892EEC
    fbgt fpsp_long_d5_A0	| 40892EF4
    fmovex %pc@(fpsp_PI_10),%fp0	| 40892EF8
    movel %a0@,%d0	| 40892EFE
    andil #-2147483648,%d0	| 40892F00
    oril #1065353216,%d0	| 40892F06
    movel %d0,%sp@-	| 40892F0C
    fmovel %d1,%fpcr	| 40892F0E
    fmuls %sp@+,%fp0	| 40892F12
    jbra fpsp_ovf_pos_12
fpsp_TENMAIN_220:       /* continue at fpsp_src_dis_1A */
    jbra fpsp_src_dis_1A	| 40892F1A

/* fpsp_satan: arc tangent. */
fpsp_satan:
    fmovex %a0@,%fp0
    movel %a0@,%d0
    movew %a0@(4),%d0
    fmovex %fp0,%fp@(-116)
    andil #2147483647,%d0
    cmpil #1073446912,%d0
    jbge fpsp_satan_22
    jbra fpsp_satan_E6
fpsp_satan_22:          /* test #1073938431,%d0 */
    cmpil #1073938431,%d0
    jble fpsp_satan_2E
    jbra fpsp_satan_164
fpsp_satan_2E:          /* clear %fp@(-114) */
    clrw %fp@(-114)
    andil #-134217728,%fp@(-112)
    oril #67108864,%fp@(-112)
    clrl %fp@(-108)
    fmovex %fp0,%fp1
    fmulx %fp@(-116),%fp1
    fsubx %fp@(-116),%fp0
    fadds #0e1,%fp1
    fdivx %fp1,%fp0
    movel %d2,%sp@-
    movel %d0,%d2
    andil #30720,%d0
    andil #2147418112,%d2
    subil #1073414144,%d2
    asrl #1,%d2
    addl %d2,%d0
    asrl #7,%d0
    lea %pc@(fpsp_ATANTBL),%a1
    addal %d0,%a1
    movel %a1@+,%fp@(-100)
    movel %a1@+,%fp@(-96)
    movel %a1@+,%fp@(-92)
    movel %fp@(-116),%d0
    andil #-2147483648,%d0
    orl %d0,%fp@(-100)
    movel %sp@+,%d2
    fmovex %fp0,%fp1
    fmulx %fp1,%fp1
    fmoved %pc@(fpsp_ATANA3),%fp2
    faddx %fp1,%fp2
    fmulx %fp1,%fp2
    fmulx %fp0,%fp1
    faddd %pc@(fpsp_ATANA2),%fp2
    fmuld %pc@(fpsp_ATANA2_8),%fp1
    fmulx %fp2,%fp1
    faddx %fp1,%fp0
    fmovel %d1,%fpcr
    faddx %fp@(-100),%fp0
    jbra fpsp_ovf_pos_12
    .short  0x0C80, 0x3FFF, 0x8000	| 40892FFA
    .long   0x6E000080	| 40893000
fpsp_satan_E6:          /* test #1071087616,%d0 */
    cmpil #1071087616,%d0
    jblt fpsp_satan_152
    fmulx %fp0,%fp0
    clrw %fp@(-114)
    fmovex %fp0,%fp1
    fmulx %fp1,%fp1
    fmoved %pc@(fpsp_ATANA2_10),%fp2
    fmoved %pc@(fpsp_ATANA2_18),%fp3
    fmulx %fp1,%fp2
    fmulx %fp1,%fp3
    faddd %pc@(fpsp_ATANA2_20),%fp2
    faddd %pc@(fpsp_ATANB3),%fp3
    fmulx %fp1,%fp2
    fmulx %fp3,%fp1
    faddd %pc@(fpsp_ATANB3_8),%fp2
    faddd %pc@(fpsp_ATANB3_10),%fp1
    fmulx %fp0,%fp2
    fmulx %fp@(-116),%fp0
    faddx %fp2,%fp1
    fmulx %fp1,%fp0
    fmovel %d1,%fpcr
    faddx %fp@(-116),%fp0
    jbra fpsp_ovf_pos_12
fpsp_satan_152:         /* clear %fp@(-114) */
    clrw %fp@(-114)
    fmovel %d1,%fpcr
    fmovex %fp@(-116),%fp0
    jbra fpsp_ovf_pos_12
fpsp_satan_164:         /* test #1080262656,%d0 */
    cmpil #1080262656,%d0
    jbgt fpsp_satan_1F0
    fmoves #0e-1,%fp1
    fdivx %fp0,%fp1
    fmovex %fp1,%fp0
    fmulx %fp0,%fp0
    fmovex %fp1,%fp@(-116)
    fmovex %fp0,%fp1
    fmulx %fp1,%fp1
    fmoved %pc@(fpsp_ATANB3_18),%fp3
    fmoved %pc@(fpsp_ATANB3_20),%fp2
    fmulx %fp1,%fp3
    fmulx %fp1,%fp2
    faddd %pc@(fpsp_ATANB3_28),%fp3
    faddd %pc@(fpsp_ATANC2),%fp2
    fmulx %fp3,%fp1
    fmulx %fp0,%fp2
    faddd %pc@(fpsp_ATANC2_8),%fp1
    fmulx %fp@(-116),%fp0
    faddx %fp2,%fp1
    fmulx %fp1,%fp0
    faddx %fp@(-116),%fp0
    fmovel %d1,%fpcr
    btst #7,%a0@
    jbeq fpsp_satan_1E6
    faddx %pc@(fpsp_end_avun_24),%fp0
    jbra fpsp_ovf_pos_12
fpsp_satan_1E6:         /* from here: faddx %pc@(fpsp_PI_10),%fp0 */
    faddx %pc@(fpsp_PI_10),%fp0
    jbra fpsp_ovf_pos_12
fpsp_satan_1F0:         /* test bit 7 of %a0@ */
    btst #7,%a0@
    jbeq fpsp_satan_20A
    fmovex %pc@(fpsp_end_avun_24),%fp0
    fmovel %d1,%fpcr
    faddx %pc@(fpsp_ATANC2_10),%fp0
    jbra fpsp_ovf_pos_12
fpsp_satan_20A:         /* from here: fmovex %pc@(fpsp_PI_10),%fp0 */
    fmovex %pc@(fpsp_PI_10),%fp0
    fmovel %d1,%fpcr
    fsubx %pc@(fpsp_ATANC2_10),%fp0
    jbra fpsp_ovf_pos_12

fpsp_satan_21E:         /* loop: tst */
    tstl %a0@
    jbmi fpsp_long_d5_A0
    jbsr fpsp_satan_228
    jbra fpsp_satan_292

fpsp_satan_228:         /* save registers */
    moveml %d3-%d7,%sp@-
    movel %a0@(4),%d4
    movel %a0@(8),%d5
    moveq #0,%d3
    bfffo %d4,0,0,%d6
    jbne fpsp_satan_228_1E
    movel %d5,%d4
    moveq #0,%d5
    moveq #32,%d3
    bfffo %d4,0,0,%d6
fpsp_satan_228_1E:      /* from here: lsll %d6,%d4 */
    lsll %d6,%d4
    addl %d6,%d3
    movel %d5,%d7
    lsll %d6,%d5
    negb %d6
    addib #32,%d6
    lsrl %d6,%d7
    negl %d3
    orl %d7,%d4
    clrl %fp@(-116)
    movel %d4,%fp@(-112)
    movel %d5,%fp@(-108)
    movel %d3,%fp@(-84)
    moveml %sp@+,%d3-%d7
    lea %fp@(-116),%a0
    rts

fpsp_satan_274:         /* loop: tst */
    tstl %a0@
    jbmi fpsp_long_d5_A0
    clrl %fp@(-84)
    movel %a0@,%fp@(-116)
    movel %a0@(4),%fp@(-112)
    movel %a0@(8),%fp@(-108)
    lea %fp@(-116),%a0

fpsp_satan_292:         /* loop: move */
    movel %a0@,%d0
    movew %a0@(4),%d0
    fmovex %a0@,%fp0
    cmp2l %pc@(fpsp_BOUNDS1),%d0
    jbcc fpsp_LOGNEAR1
fpsp_LOGMAIN:           /* loop: asr */
    asrl #8,%d0
    asrl #8,%d0
    subil #16383,%d0
    addl %fp@(-84),%d0
    lea %pc@(fpsp_LOGTBL),%a0
    fmovel %d0,%fp1
    movel #1073676288,%fp@(-116)
    movel %fp@(-112),%fp@(-96)
    andil #-33554432,%fp@(-96)
    oril #16777216,%fp@(-96)
    movel %fp@(-96),%d0
    andil #2113929216,%d0
    asrl #8,%d0
    asrl #8,%d0
    asrl #4,%d0
    addal %d0,%a0
    fmovex %fp@(-116),%fp0
    movel #1073676288,%fp@(-100)
    clrl %fp@(-92)
    fsubx %fp@(-100),%fp0
    fmovemx %fp2-%fp3,%sp@-
fpsp_LP1CONT1:          /* loop: fmulx */
    fmulx %a0@,%fp0
    fmulx %pc@(fpsp_LOGOF2),%fp1
    fmovex %fp0,%fp2
    fmulx %fp2,%fp2
    fmovex %fp1,%fp@(-64)
    fmovex %fp2,%fp3
    fmovex %fp2,%fp1
    fmuld %pc@(fpsp_zero_C),%fp1
    fmuld %pc@(fpsp_LOGA5),%fp2
    faddd %pc@(fpsp_LOGA5_8),%fp1
    faddd %pc@(fpsp_LOGA5_10),%fp2
    fmulx %fp3,%fp1
    fmulx %fp3,%fp2
    faddd %pc@(fpsp_LOGA2),%fp1
    faddd %pc@(fpsp_LOGA2_8),%fp2
    fmulx %fp3,%fp1
    addaw #16,%a0
    fmulx %fp3,%fp2
    fmulx %fp0,%fp1
    faddx %fp2,%fp0
    faddx %a0@,%fp1
    fmovemx %sp@+,%fp2-%fp3
    faddx %fp1,%fp0
    fmovel %d1,%fpcr
    faddx %fp@(-64),%fp0
    jbra fpsp_ovf_pos_12
fpsp_LOGNEAR1:          /* from here: fmovex %fp0,%fp1 */
    fmovex %fp0,%fp1
    fsubs %pc@(fpsp_one),%fp1
    fadds %pc@(fpsp_one),%fp0
    faddx %fp1,%fp1

fpsp_LP1CONT2:          /* loop: fdivx */
    fdivx %fp0,%fp1
    fmovemx %fp2-%fp3,%sp@-
    fmovex %fp1,%fp0
    fmulx %fp0,%fp0
    fmovex %fp1,%fp@(-48)
    fmovex %fp0,%fp1
    fmulx %fp1,%fp1
    fmoved %pc@(fpsp_LOGB5),%fp3
    fmoved %pc@(fpsp_LOGB4),%fp2
    fmulx %fp1,%fp3
    fmulx %fp1,%fp2
    faddd %pc@(fpsp_LOGB4_8),%fp3
    faddd %pc@(fpsp_LOGB4_10),%fp2
    fmulx %fp3,%fp1
    fmulx %fp0,%fp2
    faddd %pc@(fpsp_LOGB1),%fp1
    fmulx %fp@(-48),%fp0
    faddx %fp2,%fp1
    fmovemx %sp@+,%fp2-%fp3
    fmulx %fp1,%fp0
    fmovel %d1,%fpcr
    faddx %fp@(-48),%fp0
    jbra fpsp_ovf_pos_12
    .byte   0x4E, 0x75	| 40893320
fpsp_LP1CONT2_6E:       /* continue at fpsp_src_dis_1A */
    jbra fpsp_src_dis_1A	| 40893322

fpsp_LP1CONT2_72:       /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0
    fabsx %fp0,%fp0
    fcmpx %pc@(fpsp_LTHOLD),%fp0
    fbgt fpsp_LP1CONT2_72_26
    fmovel #0,%fpsr
    fmovel %d1,%fpcr
    fmovex %a0@,%fp0
    jbra fpsp_ovf_pos_12
fpsp_LP1CONT2_72_26:    /* from here: fmovex %a0@,%fp0 */
    fmovex %a0@,%fp0
    clrl %fp@(-84)
    fmovex %fp0,%fp1
    fadds %pc@(fpsp_one),%fp0
    fmovex %fp0,%fp@(-116)
    movew %fp@(-112),%fp@(-114)
    movel %fp@(-116),%d0
    tstl %d0
    jble fpsp_LP1CONT2_72_110
    cmp2l %pc@(fpsp_BOUNDS2),%d0
    jbcs fpsp_LOGMAIN
    cmp2l %pc@(fpsp_BOUNDS1),%d0
    jbcs fpsp_LP1CONT2_72_6E
    faddx %fp1,%fp1
    fadds %pc@(fpsp_one),%fp0
    jbra fpsp_LP1CONT2
fpsp_LP1CONT2_72_6E:    /* set %fp@(-96) */
    movel %fp@(-112),%fp@(-96)
    andil #-33554432,%fp@(-96)
    oril #16777216,%fp@(-96)
    cmpil #1073709056,%d0
    jbge fpsp_LP1CONT2_72_D0
    fmoves %pc@(fpsp_TWO),%fp0
    movel #1073676288,%fp@(-100)
    clrl %fp@(-92)
    fsubx %fp@(-100),%fp0
    movel %fp@(-96),%d0
    andil #2113929216,%d0
    asrl #8,%d0
    asrl #8,%d0
    asrl #4,%d0
    faddx %fp1,%fp1
    fmovemx %fp2-%fp3,%sp@-
    faddx %fp1,%fp0
    lea %pc@(fpsp_LOGTBL),%a0
    addal %d0,%a0
    fmoves %pc@(fpsp_zero_8),%fp1
    jbra fpsp_LP1CONT1
fpsp_LP1CONT2_72_D0:    /* from here: fmoves %pc@(fpsp_one),%fp0 */
    fmoves %pc@(fpsp_one),%fp0
    movel #1073676288,%fp@(-100)
    clrl %fp@(-92)
    fsubx %fp@(-100),%fp0
    movel %fp@(-96),%d0
    andil #2113929216,%d0
    asrl #8,%d0
    asrl #8,%d0
    asrl #4,%d0
    faddx %fp1,%fp0
    fmovemx %fp2-%fp3,%sp@-
    lea %pc@(fpsp_LOGTBL),%a0
    addal %d0,%a0
    fmoves %pc@(fpsp_zero),%fp1
    jbra fpsp_LP1CONT1
fpsp_LP1CONT2_72_110:   /* test %d0 */
    tstl %d0
    jbmi fpsp_LP1CONT2_72_122
    fmoves %pc@(fpsp_zero_8),%fp0
    fmovel %d1,%fpcr
    jbra fpsp_long_d5_4E
fpsp_LP1CONT2_72_122:   /* from here: fmoves %pc@(fpsp_zero),%fp0 */
    fmoves %pc@(fpsp_zero),%fp0
    fmovel %d1,%fpcr
    jbra fpsp_long_d5_A0
fpsp_LP1CONT2_1A2:      /* test %a0@ */
    tstl %a0@	| 40893456
    jbmi fpsp_long_d5_A0	| 40893458
    movel %d1,%sp@-
    moveq #0,%d1
    jbsr fpsp_satan_21E
    fmovel %sp@+,%fpcr
    fmulx %pc@(fpsp_INV_L10),%fp0
    jbra fpsp_ovf_pos_12
fpsp_LP1CONT2_1BE:      /* test %a0@ */
    tstl %a0@	| 40893472
    jbmi fpsp_long_d5_A0	| 40893474
    movel %d1,%sp@-
    moveq #0,%d1
    jbsr fpsp_satan_274
    fmovel %sp@+,%fpcr
    fmulx %pc@(fpsp_INV_L10),%fp0
    jbra fpsp_ovf_pos_12
fpsp_LP1CONT2_1DA:      /* test %a0@ */
    tstl %a0@	| 4089348E
    jbmi fpsp_long_d5_A0	| 40893490
    jbsr fpsp_satan_228	| 40893494
    tstl %a0@(8)	| 40893498
    jbne fpsp_LP1CONT2_1F8	| 4089349C
    movel %a0@(4),%d0	| 4089349E
    lsll #1,%d0	| 408934A2
    jbne fpsp_LP1CONT2_1F8	| 408934A4
    movel %fp@(-84),%d0	| 408934A6
    jbra fpsp_LP1CONT2_228	| 408934AA
fpsp_LP1CONT2_1F8:      /* set %sp@- */
    movel %d1,%sp@-
    moveq #0,%d1
    jbsr fpsp_satan_292
    fmovel %sp@+,%fpcr
    fmulx %pc@(fpsp_INV_L10_10),%fp0
    jbra fpsp_ovf_pos_12
fpsp_LP1CONT2_20E:      /* test %a0@ */
    tstl %a0@	| 408934C2
    jbmi fpsp_long_d5_A0	| 408934C4
    tstl %a0@(8)	| 408934C8
    jbne fpsp_LP1CONT2_236	| 408934CC
    movel %a0@(4),%d0	| 408934CE
    andil #2147483647,%d0	| 408934D2
    jbne fpsp_LP1CONT2_236	| 408934D8
    movew %a0@,%d0	| 408934DA
fpsp_LP1CONT2_228:      /* from here: subiw #16383,%d0 */
    subiw #16383,%d0	| 408934DC
    fmovel %d1,%fpcr	| 408934E0
    fmovew %d0,%fp0	| 408934E4
    rts	| 408934E8
fpsp_LP1CONT2_236:      /* set %sp@- */
    movel %d1,%sp@-
    moveq #0,%d1
    jbsr fpsp_satan_274
    fmovel %sp@+,%fpcr
    fmulx %pc@(fpsp_INV_L10_10),%fp0
    jbra fpsp_ovf_pos_12
fpsp_LP1CONT2_24C:      /* (data) */
    .long   0x40000000, 0xC90FDAA2, 0x2168C235	| 40893500
fpsp_LP1CONT2_258:      /* (data) */
    .long   0x40000000	| 4089350C
    .long   0xC90FDAA2, 0x2168C234	| 40893510
fpsp_LP1CONT2_264:      /* (data) */
    .long   0x40000000, 0xC90FDAA2	| 40893518
    .long   0x2168C235	| 40893520
fpsp_LP1CONT2_270:      /* (data) */
    .long   0x3FFD0000, 0x9A209A84, 0xFBCFF798	| 40893524
    .long   0x40000000, 0xADF85458, 0xA2BB4A9A, 0x3FFF0000	| 40893530
    .long   0xB8AA3B29, 0x5C17F0BC, 0x3FFD0000, 0xDE5BD8A9	| 40893540
    .long   0x37287195, 0x00000000, 0x00000000, 0x00000000	| 40893550
fpsp_LP1CONT2_2AC:      /* (data) */
    .long   0x3FFD0000, 0x9A209A84, 0xFBCFF798, 0x40000000	| 40893560
    .long   0xADF85458, 0xA2BB4A9A, 0x3FFF0000, 0xB8AA3B29	| 40893570
    .long   0x5C17F0BB, 0x3FFD0000, 0xDE5BD8A9, 0x37287195	| 40893580
    .long   0x00000000, 0x00000000, 0x00000000	| 40893590
fpsp_SMALRP:            /* (data) */
    .long   0x3FFD0000	| 4089359C
    .long   0x9A209A84, 0xFBCFF799, 0x40000000, 0xADF85458	| 408935A0
    .long   0xA2BB4A9B, 0x3FFF0000, 0xB8AA3B29, 0x5C17F0BC	| 408935B0
    .long   0x3FFD0000, 0xDE5BD8A9, 0x37287195, 0x00000000	| 408935C0
    .long   0x00000000, 0x00000000	| 408935D0
fpsp_SMALRP_3C:         /* (data) */
    .long   0x3FFE0000, 0xB17217F7	| 408935D8
    .long   0xD1CF79AC, 0x40000000, 0x935D8DDD, 0xAAA8AC17	| 408935E0
    .short  0x3FFF	| 408935F0
    .long   0x00008000 /* number, not an address (F4) */	| 408935F2
    .short  0x0000, 0x0000	| 408935F6
fpsp_SMALRP_5E:         /* (408935FA  | number, not an address (F4)) */
    .long   0x00004002 /* number, not an address (F4) */	| 408935FA
    .long   0x0000A000 /* number, not an address (F4) */	| 408935FE
    .short  0x0000, 0x0000, 0x0000, 0x4005, 0x0000, 0xC800, 0x0000	| 40893602
    .long   0x00000000, 0x400C0000, 0x9C400000, 0x00000000	| 40893610
    .long   0x40190000, 0xBEBC2000, 0x00000000, 0x40340000	| 40893620
    .long   0x8E1BC9BF, 0x04000000, 0x40690000, 0x9DC5ADA8	| 40893630
    .long   0x2B70B59E, 0x40D30000, 0xC2781F49, 0xFFCFA6D5	| 40893640
    .long   0x41A80000, 0x93BA47C9, 0x80E98CE0, 0x43510000	| 40893650
    .long   0xAA7EEBFB, 0x9DF9DE8E, 0x46A30000, 0xE319A0AE	| 40893660
    .long   0xA60E91C7, 0x4D480000, 0xC9767586, 0x81750C17	| 40893670
    .long   0x5A920000, 0x9E8B3B5D, 0xC53D5DE5, 0x75250000	| 40893680
    .long   0xC4605202, 0x8A20979B	| 40893690
fpsp_BIGRZRM:           /* (data) */
    .long   0x3FFE0000, 0xB17217F7	| 40893698
    .long   0xD1CF79AB, 0x40000000, 0x935D8DDD, 0xAAA8AC16	| 408936A0
    .short  0x3FFF	| 408936B0
    .long   0x00008000 /* number, not an address (F4) */	| 408936B2
    .short  0x0000, 0x0000	| 408936B6
fpsp_BIGRZRM_22:        /* (408936BA  | number, not an address (F4)) */
    .long   0x00004002 /* number, not an address (F4) */	| 408936BA
    .long   0x0000A000 /* number, not an address (F4) */	| 408936BE
    .short  0x0000, 0x0000, 0x0000, 0x4005, 0x0000, 0xC800, 0x0000	| 408936C2
    .long   0x00000000, 0x400C0000, 0x9C400000, 0x00000000	| 408936D0
    .long   0x40190000, 0xBEBC2000	| 408936E0
    orib #0,%d0
    negxb %a4@(0x0,%d0:w)
    orb %a3@+,%d7
    .short  0xC9BF, 0x0400, 0x0000, 0x4069, 0x0000, 0x9DC5, 0xADA8	| 408936F2
    .long   0x2B70B59D, 0x40D30000, 0xC2781F49, 0xFFCFA6D5	| 40893700
    .long   0x41A80000, 0x93BA47C9, 0x80E98CDF, 0x43510000	| 40893710
    .long   0xAA7EEBFB, 0x9DF9DE8D, 0x46A30000, 0xE319A0AE	| 40893720
    .long   0xA60E91C6, 0x4D480000, 0xC9767586, 0x81750C17	| 40893730
    .long   0x5A920000, 0x9E8B3B5D, 0xC53D5DE5, 0x75250000	| 40893740
    .long   0xC4605202, 0x8A20979A	| 40893750
fpsp_BIGRZRM_C0:        /* (data) */
    .long   0x3FFE0000, 0xB17217F7	| 40893758
    .long   0xD1CF79AC, 0x40000000, 0x935D8DDD, 0xAAA8AC17	| 40893760
    .short  0x3FFF	| 40893770
    .long   0x00008000 /* number, not an address (F4) */	| 40893772
    .short  0x0000, 0x0000	| 40893776
fpsp_BIGRZRM_E2:        /* (4089377A  | number, not an address (F4)) */
    .long   0x00004002 /* number, not an address (F4) */	| 4089377A
    .long   0x0000A000 /* number, not an address (F4) */	| 4089377E
    .short  0x0000, 0x0000, 0x0000, 0x4005, 0x0000, 0xC800, 0x0000	| 40893782
    .long   0x00000000, 0x400C0000, 0x9C400000, 0x00000000	| 40893790
    .long   0x40190000, 0xBEBC2000, 0x00000000, 0x40340000	| 408937A0
    .long   0x8E1BC9BF, 0x04000000, 0x40690000, 0x9DC5ADA8	| 408937B0
    .long   0x2B70B59E, 0x40D30000, 0xC2781F49, 0xFFCFA6D6	| 408937C0
    .long   0x41A80000, 0x93BA47C9, 0x80E98CE0, 0x43510000	| 408937D0
    .long   0xAA7EEBFB, 0x9DF9DE8E, 0x46A30000, 0xE319A0AE	| 408937E0
    .long   0xA60E91C7, 0x4D480000, 0xC9767586, 0x81750C18	| 408937F0
    .long   0x5A920000, 0x9E8B3B5D, 0xC53D5DE6, 0x75250000	| 40893800
    .long   0xC4605202, 0x8A20979B, 0x00000000, 0x00000000	| 40893810
fpsp_BIGRZRM_188:       /* (data) */
    .byte   0x40, 0xC6, 0x2D, 0x38, 0xD3, 0xD6, 0x46, 0x34	| 40893820
fpsp_BIGRZRM_190:       /* (data) */
    .byte   0x3D, 0x6F, 0x90, 0xAE, 0xB1, 0xE7, 0x5C, 0xC7	| 40893828
fpsp_BIGRZRM_198:       /* (data) */
    .long   0x7FFB0000, 0x80000000, 0x00000000, 0x00000000	| 40893830
fpsp_BIGRZRM_1A8:       /* (data) */
    .byte   0xBD, 0x6A, 0xAA, 0x77, 0xCC, 0xC9, 0x94, 0xF5	| 40893840
fpsp_BIGRZRM_1B0:       /* (data) */
    .byte   0x3D, 0xE6, 0x12, 0x09, 0x7A, 0xAE, 0x8D, 0xA1	| 40893848
fpsp_SINA5:             /* constant(s) SINA5 */
    .byte   0xBE, 0x5A, 0xE6, 0x45, 0x2A, 0x11, 0x8A, 0xE4	| 40893850
fpsp_SINA5_8:           /* (data) */
    .byte   0x3E, 0xC7, 0x1D, 0xE3, 0xA5, 0x34, 0x15, 0x31	| 40893858
fpsp_SINA3:             /* constant(s) SINA3 */
    .long   0xBF2A01A0, 0x1A018B59, 0x00000000, 0x00000000	| 40893860
fpsp_SINA2:             /* constant(s) SINA2 */
    .long   0x3FF80000, 0x88888888, 0x888859AF, 0x00000000	| 40893870
fpsp_SINA1:             /* constant(s) SINA1 */
    .long   0xBFFC0000, 0xAAAAAAAA, 0xAAAAAA99, 0x00000000	| 40893880
fpsp_SINA1_10:          /* (data) */
    .long   0x3D2AC4D0, 0xD6011EE3	| 40893890
fpsp_SINA1_18:          /* (data) */
    .long   0xBDA9396F, 0x9F45AC19	| 40893898
fpsp_COSB6:             /* constant(s) COSB6 */
    .long   0x3E21EED9, 0x0612C972	| 408938A0
fpsp_COSB5:             /* constant(s) COSB5 */
    .long   0xBE927E4F, 0xB79D9FCF	| 408938A8
fpsp_COSB5_8:           /* (data) */
    .byte   0x3E, 0xFA, 0x01, 0xA0, 0x1A, 0x01, 0xD4, 0x23	| 408938B0
fpsp_COSB5_10:          /* (data) */
    .byte   0x3F, 0xE4, 0x5F, 0x30, 0x6D, 0xC9, 0xC8, 0x83	| 408938B8
fpsp_COSB5_18:          /* (data) */
    cmpal %a5@(0x0,%d0:w),%sp
    .short  0xB60B	| 408938C4
    .short  0x60B6	| bras 4089387e <fpsp_SINA2+0xe>
    bchg %d5,%a1@-
    addb ResetStackPtr,%d2
    .short  0x0000	| 408938CE
fpsp_COSB5_28:          /* (data) */
    .long   0x3FFA0000, 0xAAAAAAAA, 0xAAAAAB5E	| 408938D0
fpsp_COSB5_34:          /* (data) */
    .long   0xBF000000	| 408938DC
fpsp_COSB5_38:          /* (data) */
    .byte   0x3E, 0xA0, 0xB7, 0x59, 0xF5, 0x0F, 0x86, 0x88	| 408938E0
fpsp_TANP3:             /* constant(s) TANP3 */
    .byte   0xBE, 0xF2, 0xBA, 0xA5, 0xA8, 0x92, 0x4F, 0x04	| 408938E8
fpsp_TANQ3:             /* constant(s) TANQ3 */
    .long   0xBF346F59, 0xB39BA65F, 0x00000000, 0x00000000	| 408938F0
fpsp_TANP2:             /* constant(s) TANP2 */
    .long   0x3FF60000, 0xE073D3FC, 0x199C4A00, 0x00000000	| 40893900
fpsp_TANQ2:             /* constant(s) TANQ2 */
    .long   0x3FF90000, 0xD23CD684, 0x15D95FA1, 0x00000000	| 40893910
fpsp_TANP1:             /* constant(s) TANP1 */
    .long   0xBFFC0000, 0x8895A6C5, 0xFB423BCA, 0x00000000	| 40893920
fpsp_TANP1_10:          /* (data) */
    .long   0xBFFD0000, 0xEEF57E0D, 0xA84BC8CE, 0x00000000	| 40893930
fpsp_PITBL:             /* constant(s) PITBL */
    .long   0xC0040000, 0xC90FDAA2, 0x2168C235, 0x21800000	| 40893940
    .long   0xC0040000, 0xC2C75BCD, 0x105D7C23, 0xA0D00000	| 40893950
    .long   0xC0040000, 0xBC7EDCF7, 0xFF523611, 0xA1E80000	| 40893960
    .long   0xC0040000, 0xB6365E22, 0xEE46F000, 0x21480000	| 40893970
    .long   0xC0040000, 0xAFEDDF4D, 0xDD3BA9EE, 0xA1200000	| 40893980
    .long   0xC0040000, 0xA9A56078, 0xCC3063DD, 0x21FC0000	| 40893990
    .long   0xC0040000, 0xA35CE1A3, 0xBB251DCB, 0x21100000	| 408939A0
    .long   0xC0040000, 0x9D1462CE, 0xAA19D7B9, 0xA1580000	| 408939B0
    .long   0xC0040000, 0x96CBE3F9, 0x990E91A8, 0x21E00000	| 408939C0
    .long   0xC0040000, 0x90836524, 0x88034B96, 0x20B00000	| 408939D0
    .long   0xC0040000, 0x8A3AE64F, 0x76F80584, 0xA1880000	| 408939E0
    .long   0xC0040000, 0x83F2677A, 0x65ECBF73, 0x21C40000	| 408939F0
    .long   0xC0030000, 0xFB53D14A, 0xA9C2F2C2, 0x20000000	| 40893A00
    .long   0xC0030000, 0xEEC2D3A0, 0x87AC669F, 0x21380000	| 40893A10
    .long   0xC0030000, 0xE231D5F6, 0x6595DA7B, 0xA1300000	| 40893A20
    .long   0xC0030000, 0xD5A0D84C, 0x437F4E58, 0x9FC00000	| 40893A30
    .long   0xC0030000, 0xC90FDAA2, 0x2168C235, 0x21000000	| 40893A40
    .long   0xC0030000, 0xBC7EDCF7, 0xFF523611, 0xA1680000	| 40893A50
    .long   0xC0030000, 0xAFEDDF4D, 0xDD3BA9EE, 0xA0A00000	| 40893A60
    .long   0xC0030000, 0xA35CE1A3, 0xBB251DCB, 0x20900000	| 40893A70
    .long   0xC0030000, 0x96CBE3F9, 0x990E91A8, 0x21600000	| 40893A80
    .long   0xC0030000, 0x8A3AE64F, 0x76F80584, 0xA1080000	| 40893A90
    .long   0xC0020000, 0xFB53D14A, 0xA9C2F2C2, 0x1F800000	| 40893AA0
    .long   0xC0020000, 0xE231D5F6, 0x6595DA7B, 0xA0B00000	| 40893AB0
    .long   0xC0020000, 0xC90FDAA2, 0x2168C235, 0x20800000	| 40893AC0
    .long   0xC0020000, 0xAFEDDF4D, 0xDD3BA9EE, 0xA0200000	| 40893AD0
    .long   0xC0020000, 0x96CBE3F9, 0x990E91A8, 0x20E00000	| 40893AE0
    .long   0xC0010000, 0xFB53D14A, 0xA9C2F2C2, 0x1F000000	| 40893AF0
    .long   0xC0010000, 0xC90FDAA2, 0x2168C235, 0x20000000	| 40893B00
    .long   0xC0010000, 0x96CBE3F9, 0x990E91A8, 0x20600000	| 40893B10
    .long   0xC0000000, 0xC90FDAA2, 0x2168C235, 0x1F800000	| 40893B20
    .long   0xBFFF0000, 0xC90FDAA2, 0x2168C235, 0x1F000000	| 40893B30
fpsp_PITBL_200:         /* (data) */
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40893B40
    .short  0x3FFF, 0x0000, 0xC90F, 0xDAA2, 0x2168, 0xC235, 0x9F00, 0x0000	| 40893B50
    .short  0x4000, 0x0000, 0xC90F, 0xDAA2, 0x2168, 0xC235, 0x9F80, 0x0000	| 40893B60
    .short  0x4001, 0x0000, 0x96CB, 0xE3F9, 0x990E, 0x91A8, 0xA060, 0x0000	| 40893B70
    .short  0x4001, 0x0000, 0xC90F, 0xDAA2, 0x2168, 0xC235, 0xA000, 0x0000	| 40893B80
    .short  0x4001, 0x0000, 0xFB53, 0xD14A, 0xA9C2, 0xF2C2, 0x9F00, 0x0000	| 40893B90
    .short  0x4002, 0x0000, 0x96CB, 0xE3F9, 0x990E, 0x91A8, 0xA0E0, 0x0000	| 40893BA0
    .short  0x4002, 0x0000, 0xAFED, 0xDF4D, 0xDD3B, 0xA9EE, 0x2020, 0x0000	| 40893BB0
    .short  0x4002, 0x0000, 0xC90F, 0xDAA2, 0x2168, 0xC235, 0xA080, 0x0000	| 40893BC0
    .short  0x4002, 0x0000, 0xE231, 0xD5F6, 0x6595, 0xDA7B, 0x20B0, 0x0000	| 40893BD0
    .short  0x4002, 0x0000, 0xFB53, 0xD14A, 0xA9C2, 0xF2C2, 0x9F80, 0x0000	| 40893BE0
    .short  0x4003, 0x0000, 0x8A3A, 0xE64F, 0x76F8, 0x0584, 0x2108, 0x0000	| 40893BF0
    .short  0x4003, 0x0000, 0x96CB, 0xE3F9, 0x990E, 0x91A8, 0xA160, 0x0000	| 40893C00
    .short  0x4003, 0x0000, 0xA35C, 0xE1A3, 0xBB25, 0x1DCB, 0xA090, 0x0000	| 40893C10
    .short  0x4003, 0x0000, 0xAFED, 0xDF4D, 0xDD3B, 0xA9EE, 0x20A0, 0x0000	| 40893C20
    .short  0x4003, 0x0000, 0xBC7E, 0xDCF7, 0xFF52, 0x3611, 0x2168, 0x0000	| 40893C30
    .short  0x4003, 0x0000, 0xC90F, 0xDAA2, 0x2168, 0xC235, 0xA100, 0x0000	| 40893C40
    .short  0x4003, 0x0000, 0xD5A0, 0xD84C, 0x437F, 0x4E58, 0x1FC0, 0x0000	| 40893C50
    .short  0x4003, 0x0000, 0xE231, 0xD5F6, 0x6595, 0xDA7B, 0x2130, 0x0000	| 40893C60
    .short  0x4003, 0x0000, 0xEEC2, 0xD3A0, 0x87AC, 0x669F, 0xA138, 0x0000	| 40893C70
    .short  0x4003, 0x0000, 0xFB53, 0xD14A, 0xA9C2, 0xF2C2, 0xA000, 0x0000	| 40893C80
    .short  0x4004, 0x0000, 0x83F2, 0x677A, 0x65EC, 0xBF73, 0xA1C4, 0x0000	| 40893C90
    .short  0x4004, 0x0000, 0x8A3A, 0xE64F, 0x76F8, 0x0584, 0x2188, 0x0000	| 40893CA0
    .short  0x4004, 0x0000, 0x9083, 0x6524, 0x8803, 0x4B96, 0xA0B0, 0x0000	| 40893CB0
    .short  0x4004, 0x0000, 0x96CB, 0xE3F9, 0x990E, 0x91A8, 0xA1E0, 0x0000	| 40893CC0
    .short  0x4004, 0x0000, 0x9D14, 0x62CE, 0xAA19, 0xD7B9, 0x2158, 0x0000	| 40893CD0
    .short  0x4004, 0x0000, 0xA35C, 0xE1A3, 0xBB25, 0x1DCB, 0xA110, 0x0000	| 40893CE0
    .short  0x4004, 0x0000, 0xA9A5, 0x6078, 0xCC30, 0x63DD, 0xA1FC, 0x0000	| 40893CF0
    .short  0x4004, 0x0000, 0xAFED, 0xDF4D, 0xDD3B, 0xA9EE, 0x2120, 0x0000	| 40893D00
    .short  0x4004, 0x0000, 0xB636, 0x5E22, 0xEE46, 0xF000, 0xA148, 0x0000	| 40893D10
    .short  0x4004, 0x0000, 0xBC7E, 0xDCF7, 0xFF52, 0x3611, 0x21E8, 0x0000	| 40893D20
    .short  0x4004, 0x0000, 0xC2C7, 0x5BCD, 0x105D, 0x7C23, 0x20D0, 0x0000	| 40893D30
    .short  0x4004, 0x0000, 0xC90F, 0xDAA2, 0x2168, 0xC235, 0xA180, 0x0000	| 40893D40
fpsp_L2:                /* constant(s) L2 */
    .long   0x3FDC0000, 0x82E30865, 0x4361C4C6, 0x00000000	| 40893D50
fpsp_L2_10:             /* (data) */
    .long   0x3FA55555, 0x55554431	| 40893D60
fpsp_L2_18:             /* (data) */
    .long   0x3FC55555, 0x55554018	| 40893D68
fpsp_EM1A4:             /* constant(s) EM1A4 */
    .long   0x3F811111, 0x11174385	| 40893D70
fpsp_EM1A3:             /* constant(s) EM1A3 */
    .long   0x3FA55555, 0x55554F5A	| 40893D78
fpsp_EM1A2:             /* constant(s) EM1A2 */
    .long   0x3FC55555, 0x55555555, 0x00000000, 0x00000000	| 40893D80
fpsp_EM1A2_10:          /* (data) */
    .long   0x3EC71DE3, 0xA5774682	| 40893D90
fpsp_EM1A2_18:          /* (data) */
    .long   0x3EFA01A0, 0x19D7CB68	| 40893D98
fpsp_EM1A2_20:          /* (data) */
    .long   0x3F2A01A0, 0x1A019DF3	| 40893DA0
fpsp_EM1B5:             /* constant(s) EM1B5 */
    .long   0x3F56C16C, 0x16C170E2	| 40893DA8
fpsp_EM1B4:             /* constant(s) EM1B4 */
    .long   0x3F811111, 0x11111111	| 40893DB0
fpsp_EM1B3:             /* constant(s) EM1B3 */
    .long   0x3FA55555, 0x55555555	| 40893DB8
fpsp_EM1B2:             /* constant(s) EM1B2 */
    .long   0x3FFC0000, 0xAAAAAAAA, 0xAAAAAAAB, 0x00000000	| 40893DC0
fpsp_TWO140:            /* constant(s) TWO140 */
    .long   0x48B00000, 0x00000000	| 40893DD0
fpsp_TWON140:           /* constant(s) TWON140 */
    .long   0x37300000, 0x00000000	| 40893DD8
fpsp_TWON140_8:         /* (data) */
    .long   0x3FFF0000, 0x80000000, 0x00000000, 0x00000000	| 40893DE0
    .long   0x3FFF0000, 0x8164D1F3, 0xBC030774, 0x9F841A9B	| 40893DF0
    .long   0x3FFF0000, 0x82CD8698, 0xAC2BA1D8, 0x9FC1D5B9	| 40893E00
    .long   0x3FFF0000, 0x843A28C3, 0xACDE4048, 0xA0728369	| 40893E10
    .long   0x3FFF0000, 0x85AAC367, 0xCC487B14, 0x1FC5C95C	| 40893E20
    .long   0x3FFF0000, 0x871F6196, 0x9E8D1010, 0x1EE85C9F	| 40893E30
    .long   0x3FFF0000, 0x88980E80, 0x92DA8528, 0x9FA20729	| 40893E40
    .short  0x3FFF, 0x0000, 0x8A14, 0xD575, 0x496E	| 40893E50
fpsp_TWON140_82:        /* (data) */
    .short  0xFD9C, 0xA07B, 0xF9AF	| 40893E5A
    .long   0x3FFF0000, 0x8B95C1E3	| 40893E60
    lsrl #5,%d3
    addaw %a0@(-24574),%a3
    movepl %d6,%sp@(16383)
    .short  0x0000, 0x8D1A	| orib #26,%d0
    addw %d7,%a3@+
    moveq #91,%d7
    _HandAndHand
    moveal %a2@+,%a0
    jbls fpsp_TWON140_82
    .long   0x3FFF0000, 0x8EA4398B, 0x45CD53C0, 0x1EB70051	| 40893E80
    .long   0x3FFF0000, 0x9031DC43, 0x1466B1DC, 0x1F6EB029	| 40893E90
    .long   0x3FFF0000, 0x91C3D373, 0xAB11C338, 0xA0781494	| 40893EA0
    .long   0x3FFF0000, 0x935A2B2F, 0x13E6E92C, 0x9EB319B0	| 40893EB0
    .short  0x3FFF, 0x0000, 0x94F4, 0xEFA8, 0xFEF7	| 40893EC0
    bchg %d4,%a0@-
    movel %sp@,%d0
    .short  0x457D	| 40893ECE
    .long   0x3FFF0000, 0x96942D37, 0x20185A00, 0x1F11D537	| 40893ED0
    .long   0x3FFF0000, 0x9837F051, 0x8DB8A970, 0x9FB952DD	| 40893EE0
    .long   0x3FFF0000, 0x99E04593, 0x20B7FA64, 0x1FE43087	| 40893EF0
    .long   0x3FFF0000, 0x9B8D39B9, 0xD54E5538, 0x1FA2A818	| 40893F00
    .long   0x3FFF0000, 0x9D3ED9A7, 0x2CFFB750, 0x1FDE494D	| 40893F10
    .long   0x3FFF0000, 0x9EF53260, 0x91A111AC, 0x20504890	| 40893F20
    .long   0x3FFF0000, 0xA0B0510F, 0xB9714FC4, 0xA073691C	| 40893F30
    .long   0x3FFF0000, 0xA2704303, 0x0C496818, 0x1F9B7A05	| 40893F40
    .short  0x3FFF, 0x0000, 0xA435, 0x15AE, 0x09E6	| 40893F50
    orl %a0@-,%d0
    _GetADBInfo
    .short  0x7126	| 40893F5E
    .long   0x3FFF0000, 0xA5FED6A9, 0xB15138EC, 0xA071A140	| 40893F60
    .long   0x3FFF0000, 0xA7CD93B4	| 40893F70
    aslw %d4,%d5
    movew %a0@(8271),%a2@(25306)
    .long   0x3FFF0000, 0xA9A15AB4, 0xEA7C0EF8, 0x1F283C4A	| 40893F80
    .long   0x3FFF0000, 0xAB7A39B5, 0xA93ED338, 0x9F9A7FDC	| 40893F90
    .long   0x3FFF0000, 0xAD583EEA, 0x42A14AC8, 0xA05B3FAC	| 40893FA0
    .long   0x3FFF0000, 0xAF3B78AD, 0x690A4374, 0x1FDF2610	| 40893FB0
    .long   0x3FFF0000, 0xB123F581, 0xD2AC2590, 0x9F705F90	| 40893FC0
    .long   0x3FFF0000, 0xB311C412, 0xA9112488, 0x201F678A	| 40893FD0
    .long   0x3FFF0000, 0xB504F333, 0xF9DE6484, 0x1F32FB13	| 40893FE0
    .long   0x3FFF0000, 0xB6FD91E3, 0x28D17790, 0x20038B30	| 40893FF0
    .long   0x3FFF0000, 0xB8FBAF47, 0x62FB9EE8, 0x200DC3CC	| 40894000
    .long   0x3FFF0000, 0xBAFF5AB2, 0x133E45FC, 0x9F8B2AE6	| 40894010
    .long   0x3FFF0000, 0xBD08A39F, 0x580C36C0, 0xA02BBF70	| 40894020
    .long   0x3FFF0000, 0xBF1799B6, 0x7A731084, 0xA00BF518	| 40894030
    .long   0x3FFF0000, 0xC12C4CCA, 0x66709458, 0xA041DD41	| 40894040
    .long   0x3FFF0000, 0xC346CCDA, 0x24976408, 0x9FDF137B	| 40894050
    .long   0x3FFF0000, 0xC5672A11, 0x5506DADC, 0x201F1568	| 40894060
    .long   0x3FFF0000, 0xC78D74C8, 0xABB9B15C, 0x1FC13A2E	| 40894070
    .long   0x3FFF0000, 0xC9B9BD86, 0x6E2F27A4, 0xA03F8F03	| 40894080
    .long   0x3FFF0000, 0xCBEC14FE, 0xF2727C5C, 0x1FF4907D	| 40894090
    .long   0x3FFF0000, 0xCE248C15, 0x1F8480E4, 0x9E6E53E4	| 408940A0
    .long   0x3FFF0000, 0xD06333DA, 0xEF2B2594, 0x1FD6D45C	| 408940B0
    .long   0x3FFF0000, 0xD2A81D91, 0xF12AE45C, 0xA076EDB9	| 408940C0
    .long   0x3FFF0000, 0xD4F35AAB, 0xCFEDFA20, 0x9FA6DE21	| 408940D0
    .long   0x3FFF0000, 0xD744FCCA, 0xD69D6AF4, 0x1EE69A2F	| 408940E0
    .long   0x3FFF0000, 0xD99D15C2, 0x78AFD7B4, 0x207F439F	| 408940F0
    .long   0x3FFF0000, 0xDBFBB797, 0xDAF23754, 0x201EC207	| 40894100
    .long   0x3FFF0000, 0xDE60F482, 0x5E0E9124, 0x9E8BE175	| 40894110
    .long   0x3FFF0000, 0xE0CCDEEC, 0x2A94E110, 0x20032C4B	| 40894120
    .long   0x3FFF0000, 0xE33F8972, 0xBE8A5A50, 0x2004DFF5	| 40894130
    .long   0x3FFF0000, 0xE5B906E7, 0x7C8348A8, 0x1E72F47A	| 40894140
    .long   0x3FFF0000, 0xE8396A50, 0x3C4BDC68, 0x1F722F22	| 40894150
    .long   0x3FFF0000, 0xEAC0C6E7, 0xDD243930, 0xA017E945	| 40894160
    .long   0x3FFF0000, 0xED4F301E, 0xD9942B84, 0x1F401A5B	| 40894170
    .long   0x3FFF0000, 0xEFE4B99B, 0xDCDAF5CC, 0x9FB9A9E3	| 40894180
    .long   0x3FFF0000, 0xF281773C, 0x59FFB138, 0x20744C05	| 40894190
    .long   0x3FFF0000, 0xF5257D15, 0x2486CC2C, 0x1F773A19	| 408941A0
    .long   0x3FFF0000, 0xF7D0DF73, 0x0AD13BB8, 0x1FFE90D5	| 408941B0
    .long   0x3FFF0000, 0xFA83B2DB, 0x722A033C, 0xA041ED22	| 408941C0
    .long   0x3FFF0000, 0xFD3E0C0C, 0xF486C174, 0x1F853F3A	| 408941D0
fpsp_TWON140_408:       /* (data) */
    .long   0x406A934F, 0x0979A371	| 408941E0
fpsp_L10TWO1:           /* constant(s) L10TWO1 */
    .long   0x3F734413, 0x509F8000	| 408941E8
fpsp_L10TWO2:           /* constant(s) L10TWO2 */
    .long   0xBFCD0000, 0xC0219DC1, 0xDA994FD2, 0x00000000	| 408941F0
fpsp_LOG10:             /* constant(s) LOG10 */
    .long   0x40000000, 0x935D8DDD, 0xAAA8AC17, 0x00000000	| 40894200
fpsp_LOG2:              /* constant(s) LOG2 */
    .long   0x3FFE0000, 0xB17217F7, 0xD1CF79AC, 0x00000000	| 40894210
fpsp_LOG2_10:           /* (data) */
    .long   0x3F56C16D, 0x6F7BD0B2	| 40894220
fpsp_LOG2_18:           /* (data) */
    .long   0x3F811112, 0x302C712C	| 40894228
fpsp_LOG2_20:           /* (data) */
    .long   0x3FA55555, 0x55554CC1	| 40894230
fpsp_LOG2_28:           /* (data) */
    .long   0x3FC55555, 0x55554A54	| 40894238
fpsp_LOG2_30:           /* (data) */
    .long   0x3FE00000, 0x00000000, 0x00000000, 0x00000000	| 40894240
fpsp_EXPTBL:            /* constant(s) EXPTBL */
    .short  0x3FFF, 0x0000, 0x8000, 0x0000, 0x0000, 0x0000, 0x3F73	| 40894250
    orb %d0,%d0
    .long   0x3FFF0000, 0x8164D1F3, 0xBC030773, 0x3FBEF7CA	| 40894260
    .long   0x3FFF0000, 0x82CD8698, 0xAC2BA1D7, 0x3FBDF8A9	| 40894270
    .long   0x3FFF0000, 0x843A28C3, 0xACDE4046, 0x3FBCD7C9	| 40894280
    .long   0x3FFF0000, 0x85AAC367, 0xCC487B15, 0xBFBDE8DA	| 40894290
    .long   0x3FFF0000, 0x871F6196, 0x9E8D1010, 0x3FBDE85C	| 408942A0
    .long   0x3FFF0000, 0x88980E80, 0x92DA8527, 0x3FBEBBF1	| 408942B0
    .long   0x3FFF0000, 0x8A14D575, 0x496EFD9A, 0x3FBB80CA	| 408942C0
    .long   0x3FFF0000, 0x8B95C1E3, 0xEA8BD6E7, 0xBFBA8373	| 408942D0
    .long   0x3FFF0000, 0x8D1ADF5B, 0x7E5BA9E6, 0xBFBE9670	| 408942E0
    .long   0x3FFF0000, 0x8EA4398B, 0x45CD53C0, 0x3FBDB700	| 408942F0
    .long   0x3FFF0000, 0x9031DC43, 0x1466B1DC, 0x3FBEEEB0	| 40894300
    .long   0x3FFF0000, 0x91C3D373, 0xAB11C336, 0x3FBBFD6D	| 40894310
    .long   0x3FFF0000, 0x935A2B2F, 0x13E6E92C, 0xBFBDB319	| 40894320
    .long   0x3FFF0000, 0x94F4EFA8, 0xFEF70961, 0x3FBDBA2B	| 40894330
    .long   0x3FFF0000, 0x96942D37, 0x20185A00, 0x3FBE91D5	| 40894340
    .long   0x3FFF0000, 0x9837F051, 0x8DB8A96F, 0x3FBE8D5A	| 40894350
    .long   0x3FFF0000, 0x99E04593, 0x20B7FA65, 0xBFBCDE7B	| 40894360
    .long   0x3FFF0000, 0x9B8D39B9, 0xD54E5539, 0xBFBEBAAF	| 40894370
    .long   0x3FFF0000, 0x9D3ED9A7, 0x2CFFB751, 0xBFBD86DA	| 40894380
    .long   0x3FFF0000, 0x9EF53260, 0x91A111AE, 0xBFBEBEDD	| 40894390
    .long   0x3FFF0000, 0xA0B0510F, 0xB9714FC2, 0x3FBCC96E	| 408943A0
    .long   0x3FFF0000, 0xA2704303, 0x0C496819, 0xBFBEC90B	| 408943B0
    .long   0x3FFF0000, 0xA43515AE, 0x09E6809E, 0x3FBBD1DB	| 408943C0
    .long   0x3FFF0000, 0xA5FED6A9, 0xB15138EA, 0x3FBCE5EB	| 408943D0
fpsp_EXPTBL_190:        /* (data) */
    .long   0x3FFF0000, 0xA7CD93B4, 0xE965356A, 0xBFBEC274	| 408943E0
    .long   0x3FFF0000, 0xA9A15AB4, 0xEA7C0EF8, 0x3FBEA83C	| 408943F0
    .long   0x3FFF0000, 0xAB7A39B5, 0xA93ED337, 0x3FBECB00	| 40894400
    .long   0x3FFF0000, 0xAD583EEA, 0x42A14AC6, 0x3FBE9301	| 40894410
    .long   0x3FFF0000, 0xAF3B78AD, 0x690A4375, 0xBFBD8367	| 40894420
    .long   0x3FFF0000, 0xB123F581, 0xD2AC2590, 0xBFBEF05F	| 40894430
    .long   0x3FFF0000, 0xB311C412, 0xA9112489, 0x3FBDFB3C	| 40894440
    .short  0x3FFF, 0x0000, 0xB504, 0xF333, 0xF9DE	| 40894450
    jbcc fpsp_EXPTBL_190
    .long   0x3FBEB2FB	| 4089445C
    .long   0x3FFF0000, 0xB6FD91E3	| 40894460
    movel %a1@,%a4@+
    .short  0x7791, 0x3FBA, 0xE2CB	| 4089446A
    .long   0x3FFF0000, 0xB8FBAF47, 0x62FB9EE9, 0x3FBCDC3C	| 40894470
    .long   0x3FFF0000, 0xBAFF5AB2, 0x133E45FB, 0x3FBEE9AA	| 40894480
    .long   0x3FFF0000, 0xBD08A39F, 0x580C36BF, 0xBFBEAEFD	| 40894490
    .long   0x3FFF0000, 0xBF1799B6, 0x7A731083, 0xBFBCBF51	| 408944A0
    .long   0x3FFF0000, 0xC12C4CCA, 0x66709456, 0x3FBEF88A	| 408944B0
    .long   0x3FFF0000, 0xC346CCDA, 0x24976407, 0x3FBD83B2	| 408944C0
    .long   0x3FFF0000, 0xC5672A11, 0x5506DADD, 0x3FBDF8AB	| 408944D0
    .long   0x3FFF0000, 0xC78D74C8, 0xABB9B15D, 0xBFBDFB17	| 408944E0
    .long   0x3FFF0000, 0xC9B9BD86, 0x6E2F27A3, 0xBFBEFE3C	| 408944F0
    .long   0x3FFF0000, 0xCBEC14FE, 0xF2727C5D, 0xBFBBB6F8	| 40894500
    .long   0x3FFF0000, 0xCE248C15, 0x1F8480E4, 0xBFBCEE53	| 40894510
    .long   0x3FFF0000, 0xD06333DA, 0xEF2B2595, 0xBFBDA4AE	| 40894520
    .long   0x3FFF0000, 0xD2A81D91, 0xF12AE45A, 0x3FBC9124	| 40894530
    .long   0x3FFF0000, 0xD4F35AAB, 0xCFEDFA1F, 0x3FBEB243	| 40894540
fpsp_EXPTBL_300:        /* (data) */
    .short  0x3FFF, 0x0000, 0xD744, 0xFCCA, 0xD69D	| 40894550
    jbpl fpsp_EXPTBL_300
    .long   0x3FBDE69A	| 4089455C
    .short  0x3FFF	| 40894560
    .short  0x0000, 0xD99D	| orib #0x9d,%d0
    .short  0x15C2	| 40894566
    moveq #-81,%d4
    .short  0xD7B6, 0xBFB8, 0xBC61, 0x3FFF	| addl %d3,@(0xffffffffbc613fff,%a3:l:8)
    .short  0x0000, 0xDBFB	| orib #0xfb,%d0
    eorl %d3,%sp@
    .long   0xDAF23755, 0x3FBDF610	| 40894578
    .long   0x3FFF0000	| 40894580
    addw %a0@-,%d7
    .short  0xF482, 0x5E0E	| 40894586
    subb %d0,%a4@-
    .long   0xBFBD8BE1	| 4089458C
    .long   0x3FFF0000, 0xE0CCDEEC, 0x2A94E111, 0x3FBACB12	| 40894590
    .long   0x3FFF0000, 0xE33F8972, 0xBE8A5A51, 0x3FBB9BFE	| 408945A0
    .long   0x3FFF0000, 0xE5B906E7, 0x7C8348A8, 0x3FBCF2F4	| 408945B0
    .long   0x3FFF0000	| 408945C0
    rorb %d4,%d1
    jbpl fpsp_EXPTBL_3C8
    moveaw %a3,%fp
    addw %a0@(16318),%d6
    .short  0xF22F	| 408945CE
    .long   0x3FFF0000, 0xEAC0C6E7, 0xDD24392F, 0xBFBDBF4A	| 408945D0
    .long   0x3FFF0000, 0xED4F301E, 0xD9942B84, 0x3FBEC01A	| 408945E0
    .short  0x3FFF	| 408945F0
    .short  0x0000, 0xEFE4	| orib #0xe4,%d0
    eorl %d4,%a3@+
    addaw %a2@+,%fp
    .short  0xF5CB, 0x3FBE, 0x8CAC	| 408945FA
    .long   0x3FFF0000, 0xF281773C, 0x59FFB13A, 0xBFBCBB3F	| 40894600
    .long   0x3FFF0000, 0xF5257D15	| 40894610
fpsp_EXPTBL_3C8:        /* set %a2@ */
    movel %d6,%a2@
    andb %a4@(16318),%d6
    .short  0xF73A	| 4089461E
    .long   0x3FFF0000, 0xF7D0DF73, 0x0AD13BB9, 0xBFB8B795	| 40894620
    .long   0x3FFF0000, 0xFA83B2DB, 0x722A033A, 0x3FBEF84B	| 40894630
    .long   0x3FFF0000, 0xFD3E0C0C, 0xF486C175, 0xBFBEF581	| 40894640
fpsp_PI:                /* constant(s) PI */
    .long   0x40000000, 0xC90FDAA2, 0x2168C235, 0x00000000	| 40894650
fpsp_PI_10:             /* (data) */
    .long   0x3FFF0000, 0xC90FDAA2, 0x2168C235, 0x00000000	| 40894660
fpsp_ATANA3:            /* constant(s) ATANA3 */
    .long   0xBFF6687E, 0x314987D8	| 40894670
fpsp_ATANA2:            /* constant(s) ATANA2 */
    .long   0x4002AC69, 0x34A26DB3	| 40894678
fpsp_ATANA2_8:          /* (data) */
    .long   0xBFC2476F, 0x4E1DA28E	| 40894680
fpsp_ATANA2_10:         /* (data) */
    .long   0x3FB34444, 0x7F876989	| 40894688
fpsp_ATANA2_18:         /* (data) */
    .long   0xBFB744EE, 0x7FAF45DB	| 40894690
fpsp_ATANA2_20:         /* (data) */
    .long   0x3FBC71C6, 0x46940220	| 40894698
fpsp_ATANB3:            /* constant(s) ATANB3 */
    .long   0xBFC24924, 0x921872F9	| 408946A0
fpsp_ATANB3_8:          /* (data) */
    .long   0x3FC99999, 0x99998FA9	| 408946A8
fpsp_ATANB3_10:         /* (data) */
    .long   0xBFD55555, 0x55555555	| 408946B0
fpsp_ATANB3_18:         /* (data) */
    .long   0xBFB70BF3, 0x98539E6A	| 408946B8
fpsp_ATANB3_20:         /* (data) */
    .long   0x3FBC7187, 0x962D1D7D	| 408946C0
fpsp_ATANB3_28:         /* (data) */
    .long   0xBFC24924, 0x827107B8	| 408946C8
fpsp_ATANC2:            /* constant(s) ATANC2 */
    .long   0x3FC99999, 0x9996263E	| 408946D0
fpsp_ATANC2_8:          /* (data) */
    .long   0xBFD55555, 0x55555536	| 408946D8
fpsp_ATANC2_10:         /* (data) */
    .long   0x00010000, 0x80000000, 0x00000000, 0x00000000	| 408946E0
fpsp_ATANTBL:           /* constant(s) ATANTBL */
    .long   0x3FFB0000, 0x83D152C5, 0x060B7A51, 0x00000000	| 408946F0
    .long   0x3FFB0000, 0x8BC85445, 0x65498B8B, 0x00000000	| 40894700
    .long   0x3FFB0000, 0x93BE4060, 0x17626B0D, 0x00000000	| 40894710
    .long   0x3FFB0000, 0x9BB3078D, 0x35AEC202, 0x00000000	| 40894720
    .long   0x3FFB0000, 0xA3A69A52, 0x5DDCE7DE, 0x00000000	| 40894730
    .long   0x3FFB0000, 0xAB98E943, 0x62765619, 0x00000000	| 40894740
    .long   0x3FFB0000, 0xB389E502, 0xF9C59862, 0x00000000	| 40894750
    .long   0x3FFB0000, 0xBB797E43, 0x6B09E6FB, 0x00000000	| 40894760
    .long   0x3FFB0000, 0xC367A5C7, 0x39E5F446, 0x00000000	| 40894770
    .long   0x3FFB0000, 0xCB544C61, 0xCFF7D5C6, 0x00000000	| 40894780
    .long   0x3FFB0000, 0xD33F62F8, 0x2488533E, 0x00000000	| 40894790
    .long   0x3FFB0000, 0xDB28DA81, 0x62404C77, 0x00000000	| 408947A0
    .long   0x3FFB0000, 0xE310A407, 0x8AD34F18, 0x00000000	| 408947B0
    .long   0x3FFB0000, 0xEAF6B0A8, 0x188EE1EB, 0x00000000	| 408947C0
    .long   0x3FFB0000, 0xF2DAF194, 0x9DBE79D5, 0x00000000	| 408947D0
    .long   0x3FFB0000, 0xFABD5813, 0x61D47E3E, 0x00000000	| 408947E0
    .long   0x3FFC0000, 0x8346AC21, 0x0959ECC4, 0x00000000	| 408947F0
    .long   0x3FFC0000, 0x8B232A08, 0x304282D8, 0x00000000	| 40894800
    .long   0x3FFC0000, 0x92FB70B8, 0xD29AE2F9, 0x00000000	| 40894810
    .short  0x3FFC, 0x0000, 0x9ACF, 0x476F, 0x5CCD, 0x1CB4, 0x0000	| 40894820
    .long   0x00003FFC /* number, not a label difference (was SCSIDOCOMPLETEPATCH-.) */	| 4089482E
    .short  0x0000, 0xA29E, 0x7630, 0x4954, 0xF23F, 0x0000, 0x0000, 0x3FFC	| 40894832
    .short  0x0000, 0xAA68, 0xC5D0, 0x8AB8, 0x5230, 0x0000	| 40894842
    .long   0x00003FFC /* number, not a label difference (was SREADPATCH2-.) */	| 4089484E
    .short  0x0000, 0xB22D, 0xFFFD, 0x9D53, 0x9F83, 0x0000, 0x0000	| 40894852
    .long   0x3FFC0000, 0xB9EDEF45, 0x3E900EA5, 0x00000000	| 40894860
    .long   0x3FFC0000, 0xC1A85F1C, 0xC75E3EA5, 0x00000000	| 40894870
    .long   0x3FFC0000, 0xC95D1BE8, 0x28138DE6, 0x00000000	| 40894880
    .long   0x3FFC0000, 0xD10BF300, 0x840D2DE4, 0x00000000	| 40894890
    .long   0x3FFC0000, 0xD8B4B2BA, 0x6BC05E7A, 0x00000000	| 408948A0
    .short  0x3FFC, 0x0000, 0xE057, 0x2A6B, 0xB423, 0x35F6, 0x0000	| 408948B0
    .long   0x00003FFC /* number, not a label difference (was SREADPATCH2_70-.) */	| 408948BE
    .short  0x0000, 0xE7F3, 0x2A70, 0xEA9C, 0xAA8F, 0x0000, 0x0000	| 408948C2
    .long   0x3FFC0000, 0xEF888432, 0x64ECEFAA, 0x00000000	| 408948D0
    .long   0x3FFC0000, 0xF7170A28, 0xECC06666, 0x00000000	| 408948E0
    .long   0x3FFD0000, 0x812FD288, 0x332DAD32, 0x00000000	| 408948F0
    .long   0x3FFD0000, 0x88A8D1B1, 0x218E4D64, 0x00000000	| 40894900
    .long   0x3FFD0000, 0x9012AB3F, 0x23E4AEE8, 0x00000000	| 40894910
    .long   0x3FFD0000, 0x976CC3D4, 0x11E7F1B9, 0x00000000	| 40894920
    .long   0x3FFD0000, 0x9EB68949, 0x3889A227, 0x00000000	| 40894930
    .long   0x3FFD0000, 0xA5EF72C3, 0x4487361B, 0x00000000	| 40894940
    .long   0x3FFD0000, 0xAD1700BA, 0xF07A7227, 0x00000000	| 40894950
    .long   0x3FFD0000, 0xB42CBCFA, 0xFD37EFB7, 0x00000000	| 40894960
    .long   0x3FFD0000, 0xBB303A94, 0x0BA80F89, 0x00000000	| 40894970
    .long   0x3FFD0000, 0xC22115C6, 0xFCAEBBAF, 0x00000000	| 40894980
    .long   0x3FFD0000, 0xC8FEF3E6, 0x86331221, 0x00000000	| 40894990
    .long   0x3FFD0000, 0xCFC98330, 0xB4000C70, 0x00000000	| 408949A0
    .long   0x3FFD0000, 0xD6807AA1, 0x102C5BF9, 0x00000000	| 408949B0
    .long   0x3FFD0000, 0xDD2399BC, 0x31252AA3, 0x00000000	| 408949C0
    .long   0x3FFD0000, 0xE3B2A855, 0x6B8FC517, 0x00000000	| 408949D0
    .long   0x3FFD0000, 0xEA2D764F, 0x64315989, 0x00000000	| 408949E0
    .long   0x3FFD0000, 0xF3BF5BF8, 0xBAD1A21D, 0x00000000	| 408949F0
    .long   0x3FFE0000, 0x801CE39E, 0x0D205C9A, 0x00000000	| 40894A00
    .long   0x3FFE0000, 0x8630A2DA, 0xDA1ED066, 0x00000000	| 40894A10
    .long   0x3FFE0000, 0x8C1AD445, 0xF3E09B8C, 0x00000000	| 40894A20
    .long   0x3FFE0000, 0x91DB8F16, 0x64F350E2, 0x00000000	| 40894A30
    .long   0x3FFE0000, 0x97731420, 0x365E538C, 0x00000000	| 40894A40
    .short  0x3FFE, 0x0000, 0x9CE1, 0xC8E6, 0xA0B8, 0xCDBA, 0x0000	| 40894A50
    .long   0x00003FFE /* number, not a label difference (was SCSIMGR_96_3C-.) */	| 40894A5E
    .short  0x0000, 0xA228, 0x32DB, 0xCADA, 0xAE09, 0x0000, 0x0000	| 40894A62
    .long   0x3FFE0000, 0xA746F2DD, 0xB7602294, 0x00000000	| 40894A70
    .long   0x3FFE0000, 0xAC3EC0FB, 0x997DD6A2, 0x00000000	| 40894A80
    .long   0x3FFE0000, 0xB110688A, 0xEBDC6F6A, 0x00000000	| 40894A90
    .long   0x3FFE0000, 0xB5BCC490, 0x59ECC4B0, 0x00000000	| 40894AA0
    .long   0x3FFE0000, 0xBA44BC7D, 0xD470782F, 0x00000000	| 40894AB0
    .long   0x3FFE0000, 0xBEA94144, 0xFD049AAC, 0x00000000	| 40894AC0
    .long   0x3FFE0000, 0xC2EB4ABB, 0x661628B6, 0x00000000	| 40894AD0
    .long   0x3FFE0000, 0xC70BD54C, 0xE602EE14, 0x00000000	| 40894AE0
    .long   0x3FFE0000, 0xCD000549, 0xADEC7159, 0x00000000	| 40894AF0
    .long   0x3FFE0000, 0xD48457D2, 0xD8EA4EA3, 0x00000000	| 40894B00
    .long   0x3FFE0000, 0xDB948DA7, 0x12DECE3B, 0x00000000	| 40894B10
    .long   0x3FFE0000, 0xE23855F9, 0x69E8096A, 0x00000000	| 40894B20
    .long   0x3FFE0000, 0xE8771129, 0xC4353259, 0x00000000	| 40894B30
    .long   0x3FFE0000, 0xEE57C16E, 0x0D379C0D, 0x00000000	| 40894B40
    .long   0x3FFE0000, 0xF3E10211, 0xA87C3779, 0x00000000	| 40894B50
    .long   0x3FFE0000, 0xF919039D, 0x758B8D41, 0x00000000	| 40894B60
    .long   0x3FFE0000, 0xFE058B8F, 0x64935FB3, 0x00000000	| 40894B70
    .long   0x3FFF0000, 0x8155FB49, 0x7B685D04, 0x00000000	| 40894B80
    .long   0x3FFF0000, 0x83889E35, 0x49D108E1, 0x00000000	| 40894B90
    .long   0x3FFF0000, 0x859CFA76, 0x511D724B, 0x00000000	| 40894BA0
    .long   0x3FFF0000, 0x87952ECF, 0xFF8131E7, 0x00000000	| 40894BB0
    .long   0x3FFF0000, 0x89732FD1, 0x9557641B, 0x00000000	| 40894BC0
    .long   0x3FFF0000, 0x8B38CAD1, 0x01932A35, 0x00000000	| 40894BD0
    .long   0x3FFF0000, 0x8CE7A8D8, 0x301EE6B5, 0x00000000	| 40894BE0
    .long   0x3FFF0000, 0x8F46A39E, 0x2EAE5281, 0x00000000	| 40894BF0
    .long   0x3FFF0000, 0x922DA7D7, 0x91888487, 0x00000000	| 40894C00
    .long   0x3FFF0000, 0x94D19FCB, 0xDEDF5241, 0x00000000	| 40894C10
    .long   0x3FFF0000, 0x973AB944, 0x19D2A08B, 0x00000000	| 40894C20
    .long   0x3FFF0000, 0x996FF00E, 0x08E10B96, 0x00000000	| 40894C30
    .long   0x3FFF0000, 0x9B773F95, 0x12321DA7, 0x00000000	| 40894C40
    .long   0x3FFF0000, 0x9D55CC32, 0x0F935624, 0x00000000	| 40894C50
    .long   0x3FFF0000, 0x9F100575, 0x006CC571, 0x00000000	| 40894C60
    .long   0x3FFF0000, 0xA0A9C290, 0xD97CC06C, 0x00000000	| 40894C70
    .long   0x3FFF0000, 0xA22659EB, 0xEBC0630A, 0x00000000	| 40894C80
    .long   0x3FFF0000, 0xA388B4AF, 0xF6EF0EC9, 0x00000000	| 40894C90
    .long   0x3FFF0000, 0xA4D35F10, 0x61D292C4, 0x00000000	| 40894CA0
    .long   0x3FFF0000, 0xA60895DC, 0xFBE3187E, 0x00000000	| 40894CB0
    .long   0x3FFF0000, 0xA72A51DC, 0x7367BEAC, 0x00000000	| 40894CC0
    .long   0x3FFF0000, 0xA83A5153, 0x0956168F, 0x00000000	| 40894CD0
    .long   0x3FFF0000, 0xA93A2007, 0x7539546E, 0x00000000	| 40894CE0
    .long   0x3FFF0000, 0xAA9E7245, 0x023B2605, 0x00000000	| 40894CF0
    .long   0x3FFF0000, 0xAC4C84BA, 0x6FE4D58F, 0x00000000	| 40894D00
    .long   0x3FFF0000, 0xADCE4A4A, 0x606B9712, 0x00000000	| 40894D10
    .long   0x3FFF0000, 0xAF2A2DCD, 0x8D263C9C, 0x00000000	| 40894D20
    .long   0x3FFF0000, 0xB0656F81, 0xF22265C7, 0x00000000	| 40894D30
    .long   0x3FFF0000, 0xB1846515, 0x0F71496A, 0x00000000	| 40894D40
    .long   0x3FFF0000, 0xB28AAA15, 0x6F9ADA35, 0x00000000	| 40894D50
    .long   0x3FFF0000, 0xB37B44FF, 0x3766B895, 0x00000000	| 40894D60
    .long   0x3FFF0000, 0xB458C3DC, 0xE9630433, 0x00000000	| 40894D70
    .long   0x3FFF0000, 0xB525529D, 0x562246BD, 0x00000000	| 40894D80
    .long   0x3FFF0000, 0xB5E2CCA9, 0x5F9D88CC, 0x00000000	| 40894D90
    .long   0x3FFF0000, 0xB692CADA, 0x7ACA1ADA, 0x00000000	| 40894DA0
    .long   0x3FFF0000, 0xB736AEA7, 0xA6925838, 0x00000000	| 40894DB0
    .long   0x3FFF0000, 0xB7CFAB28, 0x7E9F7B36, 0x00000000	| 40894DC0
    .long   0x3FFF0000, 0xB85ECC66, 0xCB219835, 0x00000000	| 40894DD0
    .long   0x3FFF0000, 0xB8E4FD5A, 0x20A593DA, 0x00000000	| 40894DE0
    .long   0x3FFF0000, 0xB99F41F6, 0x4AFF9BB5, 0x00000000	| 40894DF0
    .long   0x3FFF0000, 0xBA7F1E17, 0x842BBE7B, 0x00000000	| 40894E00
    .long   0x3FFF0000, 0xBB471285, 0x7637E17D, 0x00000000	| 40894E10
    .short  0x3FFF	| 40894E20
    .long   0x0000BBFA /* number, not a label difference (was LOADPATCHROMRSRC-.) */	| 40894E22
    .short  0xBE8A, 0x4788, 0xDF6F, 0x0000, 0x0000	| 40894E26
    .long   0x3FFF0000, 0xBC9D0FAD, 0x2B689D79, 0x00000000	| 40894E30
    .long   0x3FFF0000, 0xBD306A39, 0x471ECD86, 0x00000000	| 40894E40
    .long   0x3FFF0000, 0xBDB6C731, 0x856AF18A, 0x00000000	| 40894E50
    .long   0x3FFF0000	| 40894E60
    cmpb %a1@(0xffffffffffffffc5,%a4:l:2),%d7
    .short  0x02E8	| 40894E68
    bchg %d6,%a0@(0x0,%d0:w)
    .short  0x0000, 0x3FFF	| orib #0xff,%d0
    .short  0x0000, 0xBEA2	| orib #0xa2,%d0
    addw %d2,%a4@+
    roxlb %d1,%d1
    subaw %a2@-,%a2
    orib #0,%d0
    .long   0x3FFF0000, 0xBF0B10B7, 0xC03128F0, 0x00000000	| 40894E80
    .long   0x3FFF0000, 0xBF6B7A18, 0xDACB778D, 0x00000000	| 40894E90
    .long   0x3FFF0000, 0xBFC4EA46, 0x63FA18F6, 0x00000000	| 40894EA0
    .long   0x3FFF0000, 0xC0181BDE, 0x8B89A454, 0x00000000	| 40894EB0
    .long   0x3FFF0000, 0xC065B066, 0xCFBF6439, 0x00000000	| 40894EC0
    .long   0x3FFF0000, 0xC0AE345F, 0x56340AE6, 0x00000000	| 40894ED0
    .long   0x3FFF0000, 0xC0F22291, 0x9CB9E6A7, 0x00000000	| 40894EE0
fpsp_INV_L10:           /* constant(s) INV_L10 */
    .long   0x3FFD0000, 0xDE5BD8A9, 0x37287195, 0x00000000	| 40894EF0
fpsp_INV_L10_10:        /* (data) */
    .long   0x3FFF0000, 0xB8AA3B29, 0x5C17F0BC, 0x00000000	| 40894F00
fpsp_BOUNDS1:           /* constant(s) BOUNDS1 */
    .long   0x3FFEF07D, 0x3FFF8841	| 40894F10
fpsp_BOUNDS2:           /* constant(s) BOUNDS2 */
    .long   0x3FFE8000, 0x3FFFC000	| 40894F18
fpsp_LOGOF2:            /* constant(s) LOGOF2 */
    .long   0x3FFE0000, 0xB17217F7, 0xD1CF79AC, 0x00000000	| 40894F20
fpsp_one:               /* (data) */
    .long   0x3F800000	| 40894F30
fpsp_zero:              /* (data) */
    .long   0x00000000, 0x7F800000	| 40894F34
fpsp_zero_8:            /* (data) */
    .long   0xBF800000	| 40894F3C
fpsp_zero_C:            /* (data) */
    .long   0x3FC2499A, 0xB5E4040B	| 40894F40
fpsp_LOGA5:             /* constant(s) LOGA5 */
    .long   0xBFC555B5, 0x848CB7DB	| 40894F48
fpsp_LOGA5_8:           /* (data) */
    .long   0x3FC99999, 0x987D8730	| 40894F50
fpsp_LOGA5_10:          /* (data) */
    .long   0xBFCFFFFF, 0xFF6F7E97	| 40894F58
fpsp_LOGA2:             /* constant(s) LOGA2 */
    .long   0x3FD55555, 0x555555A4	| 40894F60
fpsp_LOGA2_8:           /* (data) */
    .long   0xBFE00000, 0x00000008	| 40894F68
fpsp_LOGB5:             /* constant(s) LOGB5 */
    .long   0x3F175496, 0xADD7DAD6	| 40894F70
fpsp_LOGB4:             /* constant(s) LOGB4 */
    .long   0x3F3C71C2, 0xFE80C7E0	| 40894F78
fpsp_LOGB4_8:           /* (data) */
    .long   0x3F624924, 0x928BCCFF	| 40894F80
fpsp_LOGB4_10:          /* (data) */
    .long   0x3F899999, 0x999995EC	| 40894F88
fpsp_LOGB1:             /* constant(s) LOGB1 */
    .long   0x3FB55555, 0x55555555	| 40894F90
fpsp_TWO:               /* constant(s) TWO */
    .long   0x40000000, 0x00000000	| 40894F98
fpsp_LTHOLD:            /* constant(s) LTHOLD */
    .long   0x3F990000, 0x80000000, 0x00000000, 0x00000000	| 40894FA0
fpsp_LOGTBL:            /* constant(s) LOGTBL */
    .long   0x3FFE0000, 0xFE03F80F, 0xE03F80FE, 0x00000000	| 40894FB0
    .long   0x3FF70000, 0xFF015358, 0x833C47E2, 0x00000000	| 40894FC0
    .long   0x3FFE0000, 0xFA232CF2, 0x52138AC0, 0x00000000	| 40894FD0
    .long   0x3FF90000, 0xBDC8D83E, 0xAD88D549, 0x00000000	| 40894FE0
    .long   0x3FFE0000, 0xF6603D98, 0x0F6603DA, 0x00000000	| 40894FF0
    .long   0x3FFA0000, 0x9CF43DCF, 0xF5EAFD48, 0x00000000	| 40895000
    .long   0x3FFE0000, 0xF2B9D648, 0x0F2B9D65, 0x00000000	| 40895010
    .long   0x3FFA0000, 0xDA16EB88, 0xCB8DF614, 0x00000000	| 40895020
    .long   0x3FFE0000, 0xEF2EB71F, 0xC4345238, 0x00000000	| 40895030
    .long   0x3FFB0000, 0x8B29B775, 0x1BD70743, 0x00000000	| 40895040
    .long   0x3FFE0000, 0xEBBDB2A5, 0xC1619C8C, 0x00000000	| 40895050
    .long   0x3FFB0000, 0xA8D839F8, 0x30C1FB49, 0x00000000	| 40895060
    .long   0x3FFE0000, 0xE865AC7B, 0x7603A197, 0x00000000	| 40895070
    .long   0x3FFB0000, 0xC61A2EB1, 0x8CD907AD, 0x00000000	| 40895080
    .long   0x3FFE0000, 0xE525982A, 0xF70C880E, 0x00000000	| 40895090
    .long   0x3FFB0000, 0xE2F2A47A, 0xDE3A18AF, 0x00000000	| 408950A0
    .long   0x3FFE0000, 0xE1FC780E, 0x1FC780E2, 0x00000000	| 408950B0
    .long   0x3FFB0000, 0xFF64898E, 0xDF55D551, 0x00000000	| 408950C0
    .long   0x3FFE0000, 0xDEE95C4C, 0xA037BA57, 0x00000000	| 408950D0
    .long   0x3FFC0000, 0x8DB956A9, 0x7B3D0148, 0x00000000	| 408950E0
    .long   0x3FFE0000, 0xDBEB61EE, 0xD19C5958, 0x00000000	| 408950F0
    .long   0x3FFC0000, 0x9B8FE100, 0xF47BA1DE, 0x00000000	| 40895100
    .long   0x3FFE0000, 0xD901B203, 0x6406C80E, 0x00000000	| 40895110
    .long   0x3FFC0000, 0xA9372F1D, 0x0DA1BD17, 0x00000000	| 40895120
    .long   0x3FFE0000, 0xD62B80D6, 0x2B80D62C, 0x00000000	| 40895130
    .long   0x3FFC0000, 0xB6B07F38, 0xCE90E46B, 0x00000000	| 40895140
    .long   0x3FFE0000, 0xD3680D36, 0x80D3680D, 0x00000000	| 40895150
    .long   0x3FFC0000, 0xC3FD0329, 0x06488481, 0x00000000	| 40895160
    .long   0x3FFE0000, 0xD0B69FCB, 0xD2580D0B, 0x00000000	| 40895170
    .long   0x3FFC0000, 0xD11DE0FF, 0x15AB18CA, 0x00000000	| 40895180
    .long   0x3FFE0000, 0xCE168A77, 0x25080CE1, 0x00000000	| 40895190
    .long   0x3FFC0000, 0xDE1433A1, 0x6C66B150, 0x00000000	| 408951A0
    .long   0x3FFE0000, 0xCB8727C0, 0x65C393E0, 0x00000000	| 408951B0
    .long   0x3FFC0000, 0xEAE10B5A, 0x7DDC8ADD, 0x00000000	| 408951C0
    .long   0x3FFE0000, 0xC907DA4E, 0x871146AD, 0x00000000	| 408951D0
    .long   0x3FFC0000, 0xF7856E5E, 0xE2C9B291, 0x00000000	| 408951E0
    .long   0x3FFE0000, 0xC6980C69, 0x80C6980C, 0x00000000	| 408951F0
    .long   0x3FFD0000, 0x82012CA5, 0xA68206D7, 0x00000000	| 40895200
    .long   0x3FFE0000, 0xC4372F85, 0x5D824CA6, 0x00000000	| 40895210
    .long   0x3FFD0000, 0x882C5FCD, 0x7256A8C5, 0x00000000	| 40895220
    .long   0x3FFE0000, 0xC1E4BBD5, 0x95F6E947, 0x00000000	| 40895230
    .long   0x3FFD0000, 0x8E44C60B, 0x4CCFD7DE, 0x00000000	| 40895240
    .long   0x3FFE0000, 0xBFA02FE8, 0x0BFA02FF, 0x00000000	| 40895250
    .long   0x3FFD0000, 0x944AD09E, 0xF4351AF6, 0x00000000	| 40895260
    .long   0x3FFE0000, 0xBD691047, 0x07661AA3, 0x00000000	| 40895270
    .long   0x3FFD0000, 0x9A3EECD4, 0xC3EAA6B2, 0x00000000	| 40895280
    .long   0x3FFE0000, 0xBB3EE721, 0xA54D880C, 0x00000000	| 40895290
    .long   0x3FFD0000, 0xA0218434, 0x353F1DE8, 0x00000000	| 408952A0
    .long   0x3FFE0000, 0xB92143FA, 0x36F5E02E, 0x00000000	| 408952B0
    .long   0x3FFD0000, 0xA5F2FCAB, 0xBBC506DA, 0x00000000	| 408952C0
    .long   0x3FFE0000, 0xB70FBB5A, 0x19BE3659, 0x00000000	| 408952D0
    .long   0x3FFD0000, 0xABB3B8BA, 0x2AD362A5, 0x00000000	| 408952E0
    .long   0x3FFE0000, 0xB509E68A, 0x9B94821F, 0x00000000	| 408952F0
    .long   0x3FFD0000, 0xB1641795, 0xCE3CA97B, 0x00000000	| 40895300
    .long   0x3FFE0000, 0xB30F6352, 0x8917C80B, 0x00000000	| 40895310
    .long   0x3FFD0000, 0xB7047551, 0x5D0F1C61, 0x00000000	| 40895320
    .long   0x3FFE0000, 0xB11FD3B8, 0x0B11FD3C, 0x00000000	| 40895330
    .long   0x3FFD0000, 0xBC952AFE, 0xEA3D13E1, 0x00000000	| 40895340
    .long   0x3FFE0000, 0xAF3ADDC6, 0x80AF3ADE, 0x00000000	| 40895350
    .long   0x3FFD0000, 0xC2168ED0, 0xF458BA4A, 0x00000000	| 40895360
    .long   0x3FFE0000, 0xAD602B58, 0x0AD602B6, 0x00000000	| 40895370
    .long   0x3FFD0000, 0xC788F439, 0xB3163BF1, 0x00000000	| 40895380
    .long   0x3FFE0000, 0xAB8F69E2, 0x8359CD11, 0x00000000	| 40895390
    .long   0x3FFD0000, 0xCCECAC08, 0xBF04565D, 0x00000000	| 408953A0
    .long   0x3FFE0000, 0xA9C84A47, 0xA07F5638, 0x00000000	| 408953B0
    .long   0x3FFD0000, 0xD2420487, 0x2DD85160, 0x00000000	| 408953C0
    .long   0x3FFE0000, 0xA80A80A8, 0x0A80A80B, 0x00000000	| 408953D0
    .long   0x3FFD0000, 0xD7894992, 0x3BC3588A, 0x00000000	| 408953E0
    .long   0x3FFE0000, 0xA655C439, 0x2D7B73A8, 0x00000000	| 408953F0
    .long   0x3FFD0000, 0xDCC2C4B4, 0x9887DACC, 0x00000000	| 40895400
    .long   0x3FFE0000, 0xA4A9CF1D, 0x96833751, 0x00000000	| 40895410
    .long   0x3FFD0000, 0xE1EEBD3E, 0x6D6A6B9E, 0x00000000	| 40895420
    .long   0x3FFE0000, 0xA3065E3F, 0xAE7CD0E0, 0x00000000	| 40895430
    .long   0x3FFD0000, 0xE70D785C, 0x2F9F5BDC, 0x00000000	| 40895440
    .long   0x3FFE0000, 0xA16B312E, 0xA8FC377D, 0x00000000	| 40895450
    .long   0x3FFD0000, 0xEC1F392C, 0x5179F283, 0x00000000	| 40895460
    .long   0x3FFE0000, 0x9FD809FD, 0x809FD80A, 0x00000000	| 40895470
    .long   0x3FFD0000, 0xF12440D3, 0xE36130E6, 0x00000000	| 40895480
    .long   0x3FFE0000, 0x9E4CAD23, 0xDD5F3A20, 0x00000000	| 40895490
    .long   0x3FFD0000, 0xF61CCE92, 0x346600BB, 0x00000000	| 408954A0
    .long   0x3FFE0000, 0x9CC8E160, 0xC3FB19B9, 0x00000000	| 408954B0
    .long   0x3FFD0000, 0xFB091FD3, 0x8145630A, 0x00000000	| 408954C0
    .long   0x3FFE0000, 0x9B4C6F9E, 0xF03A3CAA, 0x00000000	| 408954D0
    .long   0x3FFD0000, 0xFFE97042, 0xBFA4C2AD, 0x00000000	| 408954E0
    .long   0x3FFE0000, 0x99D722DA, 0xBDE58F06, 0x00000000	| 408954F0
    .long   0x3FFE0000, 0x825EFCED, 0x49369330, 0x00000000	| 40895500
    .long   0x3FFE0000, 0x9868C809, 0x868C8098, 0x00000000	| 40895510
    .long   0x3FFE0000, 0x84C37A7A, 0xB9A905C9, 0x00000000	| 40895520
    .long   0x3FFE0000, 0x97012E02, 0x5C04B809, 0x00000000	| 40895530
    .long   0x3FFE0000, 0x87224C2E, 0x8E645FB7, 0x00000000	| 40895540
    .long   0x3FFE0000, 0x95A02568, 0x095A0257, 0x00000000	| 40895550
    .long   0x3FFE0000, 0x897B8CAC, 0x9F7DE298, 0x00000000	| 40895560
    .long   0x3FFE0000, 0x94458094, 0x45809446, 0x00000000	| 40895570
    .long   0x3FFE0000, 0x8BCF55DE, 0xC4CD05FE, 0x00000000	| 40895580
    .long   0x3FFE0000, 0x92F11384, 0x0497889C, 0x00000000	| 40895590
    .long   0x3FFE0000, 0x8E1DC0FB, 0x89E125E5, 0x00000000	| 408955A0
    .long   0x3FFE0000, 0x91A2B3C4, 0xD5E6F809, 0x00000000	| 408955B0
    .long   0x3FFE0000, 0x9066E68C, 0x955B6C9B, 0x00000000	| 408955C0
    .long   0x3FFE0000, 0x905A3863, 0x3E06C43B, 0x00000000	| 408955D0
    .long   0x3FFE0000, 0x92AADE74, 0xC7BE59E0, 0x00000000	| 408955E0
    .long   0x3FFE0000, 0x8F1779D9, 0xFDC3A219, 0x00000000	| 408955F0
    .long   0x3FFE0000, 0x94E9BFF6, 0x15845643, 0x00000000	| 40895600
    .long   0x3FFE0000, 0x8DDA5202, 0x37694809, 0x00000000	| 40895610
    .long   0x3FFE0000, 0x9723A1B7, 0x20134203, 0x00000000	| 40895620
    .long   0x3FFE0000, 0x8CA29C04, 0x6514E023, 0x00000000	| 40895630
    .long   0x3FFE0000, 0x995899C8, 0x90EB8990, 0x00000000	| 40895640
    .long   0x3FFE0000, 0x8B70344A, 0x139BC75A, 0x00000000	| 40895650
    .long   0x3FFE0000, 0x9B88BDAA, 0x3A3DAE2F, 0x00000000	| 40895660
    .long   0x3FFE0000, 0x8A42F870, 0x5669DB46, 0x00000000	| 40895670
    .long   0x3FFE0000, 0x9DB4224F, 0xFFE1157C, 0x00000000	| 40895680
    .long   0x3FFE0000, 0x891AC73A, 0xE9819B50, 0x00000000	| 40895690
    .long   0x3FFE0000, 0x9FDADC26, 0x8B7A12DA, 0x00000000	| 408956A0
    .long   0x3FFE0000, 0x87F78087, 0xF78087F8, 0x00000000	| 408956B0
    .long   0x3FFE0000, 0xA1FCFF17, 0xCE733BD4, 0x00000000	| 408956C0
    .long   0x3FFE0000, 0x86D90544, 0x7A34ACC6, 0x00000000	| 408956D0
    .long   0x3FFE0000, 0xA41A9E8F, 0x5446FB9F, 0x00000000	| 408956E0
    .long   0x3FFE0000, 0x85BF3761, 0x2CEE3C9B, 0x00000000	| 408956F0
    .long   0x3FFE0000, 0xA633CD7E, 0x6771CD8B, 0x00000000	| 40895700
    .long   0x3FFE0000, 0x84A9F9C8, 0x084A9F9D, 0x00000000	| 40895710
    .long   0x3FFE0000, 0xA8489E60, 0x0B435A5E, 0x00000000	| 40895720
    .long   0x3FFE0000, 0x83993052, 0x3FBE3368, 0x00000000	| 40895730
    .long   0x3FFE0000, 0xAA59233C, 0xCCA4BD49, 0x00000000	| 40895740
    .long   0x3FFE0000, 0x828CBFBE, 0xB9A020A3, 0x00000000	| 40895750
    .long   0x3FFE0000, 0xAC656DAE, 0x6BCC4985, 0x00000000	| 40895760
    .long   0x3FFE0000, 0x81848DA8, 0xFAF0D277, 0x00000000	| 40895770
    .long   0x3FFE0000, 0xAE6D8EE3, 0x60BB2468, 0x00000000	| 40895780
    .long   0x3FFE0000, 0x80808080, 0x80808081, 0x00000000	| 40895790
    .long   0x3FFE0000, 0xB07197A2, 0x3C46C654, 0x00000000	| 408957A0
