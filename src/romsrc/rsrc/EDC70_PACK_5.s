/* ROM resource 'PACK' 5: map entry at 0x408EDC70, data at 0x408EDCA0, 9056 bytes

 The SANE elementary functions for machines with a floating-point unit (PACK 5, FPU
 version; the Quadra 800 uses this one): logarithms, exponentials, powers,
 trigonometric functions, compound interest and annuity, random numbers, computed with
 floating-point instructions. The function code selects the routine through the table
 rsrc_PACK_5_408EDCA0_7C. Comments inferred; routines summarised mechanically.
*/

/* subroutine (1 instructions): low memory PACK (mechanical summary) */
rsrc_PACK_5_entry_408EDC70:
    .long   0x70000000, 0x00000000	| 408EDC70
    .long   rsrc_PACK_4_entry_408E99F0-rom_start	| 408EDC78
    .long   rsrc_PACK_5_408EDCA0-rom_start	| 408EDC7C
    .ascii  "PACK"	| 408EDC80
    .byte   0x00, 0x05, 0x58, 0x00	| 408EDC84
    FILL_408EDC88
    .byte   0xC0, 0xA0, 0x00, 0x00	| 408EDC94
    .short  0x0000, 0x236C	| orib #108,%d0
    .short  0x0000, 0x0274	| orib #116,%d0

/* subroutine (80 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0:
    jbra rsrc_PACK_5_408EDCA0_C
    .short  0x0000, 0x5041, 0x434B, 0x0005, 0x0009	| 408EDCA2

rsrc_PACK_5_408EDCA0_C:  /* save registers */
    moveml %d0-%d1/%a0/%a4,%sp@-
    fmovemx %fp2-%fp3,%sp@-
    fmovel %fpsr,%sp@-
    fmovel %fpcr,%sp@-
    moveq #0,%d1
    fmovel %d1,%fpcr
    fmovel %d1,%fpsr
    moveal %sp@(54),%a0
    movew %sp@(52),%d0
    btst #14,%d0
    jbeq rsrc_PACK_5_408EDCA0_C_3A
    btst #7,%d0
    jbeq rsrc_PACK_5_408EDCA0_C_34
    lea %pc@(rsrc_PACK_5_408EDCA0_B0),%a4
    jbra rsrc_PACK_5_408EDCA0_C_62
rsrc_PACK_5_408EDCA0_C_34:  /* address %pc@(rsrc_PACK_5_408EDCA0_9E) */
    lea %pc@(rsrc_PACK_5_408EDCA0_9E),%a4
    jbra rsrc_PACK_5_408EDCA0_C_62
rsrc_PACK_5_408EDCA0_C_3A:  /* test bit 7 of %d0 */
    btst #7,%d0
    jbeq rsrc_PACK_5_408EDCA0_C_50
    movew %a0@(4),%a0@(2)
    lea %pc@(rsrc_PACK_5_408EDCA0_B0),%a4
    fmovex %a0@,%fp0
    jbra rsrc_PACK_5_408EDCA0_C_62
rsrc_PACK_5_408EDCA0_C_50:  /* address %pc@(rsrc_PACK_5_408EDCA0_9E) */
    lea %pc@(rsrc_PACK_5_408EDCA0_9E),%a4
    addql #6,%a0
    movel %a0@,%sp@-
    movel %a0@-,%sp@-
    subql #2,%a0
    movel %a0@,%sp@-
    fmovex %sp@+,%fp0
rsrc_PACK_5_408EDCA0_C_62:  /* set %d1 */
    movew #62,%d1
    andb %d0,%d1
    movew %pc@(rsrc_PACK_5_408EDCA0_7C,%d1:w),%d1
    jmp %pc@(rsrc_PACK_5_408EDCA0_C_62,%d1:w)
rsrc_PACK_5_408EDCA0_7C:  /* (data) */
    .short  rsrc_PACK_5_408EDCA0_B9C-rsrc_PACK_5_408EDCA0_C_62	| 408EDD1C
    .short  rsrc_PACK_5_408EDCA0_A74_14-rsrc_PACK_5_408EDCA0_C_62	| 408EDD1E
    .short  rsrc_PACK_5_408EDCA0_B3A-rsrc_PACK_5_408EDCA0_C_62	| 408EDD20
    .short  rsrc_PACK_5_408EDCA0_A74_3C-rsrc_PACK_5_408EDCA0_C_62	| 408EDD22
    .short  rsrc_PACK_5_408EDCA0_3A2-rsrc_PACK_5_408EDCA0_C_62	| 408EDD24
    .short  rsrc_PACK_5_408EDCA0_2E0_26-rsrc_PACK_5_408EDCA0_C_62	| 408EDD26
    .short  rsrc_PACK_5_408EDCA0_1DA-rsrc_PACK_5_408EDCA0_C_62	| 408EDD28
    .short  rsrc_PACK_5_408EDCA0_162-rsrc_PACK_5_408EDCA0_C_62	| 408EDD2A
    .short  rsrc_PACK_5_408EDCA0_6EC-rsrc_PACK_5_408EDCA0_C_62	| 408EDD2C
    .short  rsrc_PACK_5_408EDCA0_876-rsrc_PACK_5_408EDCA0_C_62	| 408EDD2E
    .short  rsrc_PACK_5_408EDCA0_3DE-rsrc_PACK_5_408EDCA0_C_62	| 408EDD30
    .short  rsrc_PACK_5_408EDCA0_47E-rsrc_PACK_5_408EDCA0_C_62	| 408EDD32
    .short  rsrc_PACK_5_408EDCA0_F22-rsrc_PACK_5_408EDCA0_C_62	| 408EDD34
    .short  rsrc_PACK_5_408EDCA0_FB2-rsrc_PACK_5_408EDCA0_C_62	| 408EDD36
    .short  rsrc_PACK_5_408EDCA0_CB2-rsrc_PACK_5_408EDCA0_C_62	| 408EDD38
    .short  rsrc_PACK_5_408EDCA0_DB4-rsrc_PACK_5_408EDCA0_C_62	| 408EDD3A
    .short  rsrc_PACK_5_408EDCA0_144-rsrc_PACK_5_408EDCA0_C_62	| 408EDD3C
rsrc_PACK_5_408EDCA0_9E:  /* set %a0 */
    moveal %sp@(54),%a0
    fmovemx %fp0,%sp@-
    movew %sp@+,%a0@+
    addql #2,%sp
    movel %sp@+,%a0@+
    movel %sp@+,%a0@
    jbra rsrc_PACK_5_408EDCA0_B8
rsrc_PACK_5_408EDCA0_B0:  /* set %a0 */
    moveal %sp@(54),%a0
    fmovemx %fp0,%a0@
rsrc_PACK_5_408EDCA0_B8:  /* set %d1 */
    moveq #-1,%d1
    eorb %d1,%d0
    fmovel %fpsr,%d1
    andb %d0,%d1
    swap %d0
    orb %d1,%d0
    orb %d0,%sp@(7)
    moveb %sp@(2),%d1
    fmoveml %sp@+,%fpsr/%fpcr
    bclr #5,%d1
    bftst %d1,24,2
    jbeq rsrc_PACK_5_408EDCA0_E0
    bset #5,%d1
rsrc_PACK_5_408EDCA0_E0:  /* from here: andiw #62,%d1 */
    andiw #62,%d1
    jbeq rsrc_PACK_5_408EDCA0_118
    lslb #2,%d1
    andw %d1,%d0
    jbeq rsrc_PACK_5_408EDCA0_118
    lsrb #3,%d0
    clrl %sp@-
    clrw %sp@-
    moveb %pc@(rsrc_PACK_5_408EDCA0_124,%d0:w),%d0
    movew %d0,%sp@-
    movel %sp,%sp@-
    movel %sp@(66),%sp@-
    movel %sp@(66),%sp@-
    movel %sp@(66),%sp@-
    movew %sp@(68),%sp@-
    bset #7,%sp@
    moveaw #2636,%a0
    moveal %a0@,%a0
    jsr %a0@
    addqw #8,%sp
rsrc_PACK_5_408EDCA0_118:  /* from here: fmovemx %sp@+,%fp2-%fp3 */
    fmovemx %sp@+,%fp2-%fp3
    moveml %sp@+,%d0-%d1/%a0/%a4
    rtd #6
rsrc_PACK_5_408EDCA0_124:  /* (data) */
    .byte   0x00, 0x10, 0x08, 0x18, 0x02, 0x12, 0x0A, 0x1A, 0x04, 0x14, 0x0C, 0x1C, 0x06, 0x16, 0x0E, 0x1E	| 408EDDC4
    .byte   0x01, 0x11, 0x09, 0x19, 0x03, 0x13, 0x0B, 0x1B, 0x05, 0x15, 0x0D, 0x1D, 0x07, 0x17, 0x0F, 0x1F	| 408EDDD4

/* subroutine (7 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0_144:
    fmulw #16807,%fp0	| 408EDDE4
    moveq #0,%d0	| 408EDDEA
    fmovel #2147483647,%fp1	| 408EDDEC
    fremx %fp1,%fp0	| 408EDDF4
    fbge rsrc_PACK_5_408EDCA0_160	| 408EDDF8
    faddx %fp1,%fp0	| 408EDDFC
rsrc_PACK_5_408EDCA0_160:  /* jump through %a4@ */
    jmp %a4@	| 408EDE00

/* subroutine (30 instructions): calls rsrc_PACK_5_408EDCA0_2A8 (mechanical summary) */
rsrc_PACK_5_408EDCA0_162:
    fmovel %fpsr,%d0	| 408EDE02
    andil #251658240,%d0	| 408EDE06
    lsll #5,%d0	| 408EDE0C
    jbne rsrc_PACK_5_408EDCA0_23E	| 408EDE0E
    bfextu %a0@,1,15,%d1	| 408EDE12
    cmpiw #16319,%d1	| 408EDE16
    jblt rsrc_PACK_5_408EDCA0_210	| 408EDE1A
    fcmps #0e16384,%fp0	| 408EDE1E
    fboge rsrc_PACK_5_408EDCA0_260	| 408EDE26
    fcmps #0e-64,%fp0	| 408EDE2A
    fbolt rsrc_PACK_5_408EDCA0_252	| 408EDE32
    fmovew %fp0,%d1	| 408EDE36
    fsubw %d1,%fp0	| 408EDE3A
rsrc_PACK_5_408EDCA0_19E:  /* call rsrc_PACK_5_408EDCA0_2A8 (loop) */
    jbsr rsrc_PACK_5_408EDCA0_2A8
    tstw %d1
    jbeq rsrc_PACK_5_408EDCA0_1D8
    faddw #1,%fp0
    clrl %sp@-
    movel #-2147483648,%sp@-
    subqw #4,%sp
    cmpiw #16384,%d1
    jblt rsrc_PACK_5_408EDCA0_1C8
    movew #32766,%sp@
    fmulx %sp@,%fp0
    subiw #16383,%d1
rsrc_PACK_5_408EDCA0_1C8:  /* from here: addiw #16383,%d1 */
    addiw #16383,%d1
    movew %d1,%sp@
    fmulx %sp@+,%fp0
    fsubw #1,%fp0
rsrc_PACK_5_408EDCA0_1D8:  /* jump through %a4@ */
    jmp %a4@

/* subroutine (50 instructions): calls rsrc_PACK_5_408EDCA0_2E0 (mechanical summary) */
rsrc_PACK_5_408EDCA0_1DA:
    fmovel %fpsr,%d0	| 408EDE7A
    andil #251658240,%d0	| 408EDE7E
    lsll #5,%d0	| 408EDE84
    jbne rsrc_PACK_5_408EDCA0_23E	| 408EDE86
    bfextu %a0@,1,15,%d1	| 408EDE88
    cmpiw #16319,%d1	| 408EDE8C
    jblt rsrc_PACK_5_408EDCA0_21E	| 408EDE90
    fcmps #0x46317218,%fp0	| 408EDE92
    fboge rsrc_PACK_5_408EDCA0_260	| 408EDE9A
    fcmps #0xc2317218,%fp0	| 408EDE9E
    fbole rsrc_PACK_5_408EDCA0_252	| 408EDEA6
    jbsr rsrc_PACK_5_408EDCA0_2E0
    jbra rsrc_PACK_5_408EDCA0_19E
rsrc_PACK_5_408EDCA0_210:  /* from here: fmovemx %fp0,%sp@- */
    fmovemx %fp0,%sp@-	| 408EDEB0
    fmovex %pc@(rsrc_PACK_5_408EDCA0_1246),%fp0	| 408EDEB4
    fmulx %sp@+,%fp0	| 408EDEBA
rsrc_PACK_5_408EDCA0_21E:  /* address %sp@(-12) */
    lea %sp@(-12),%sp	| 408EDEBE
    movel #524288,%d0	| 408EDEC2
    fmovemx %fp0,%sp@	| 408EDEC8
    tstw %sp@(4)	| 408EDECC
    lea %sp@(12),%sp	| 408EDED0
    jbmi rsrc_PACK_5_408EDCA0_23C	| 408EDED4
    oril #2097152,%d0	| 408EDED6
rsrc_PACK_5_408EDCA0_23C:  /* jump through %a4@ */
    jmp %a4@	| 408EDEDC
rsrc_PACK_5_408EDCA0_23E:  /* from here: jbmi rsrc_PACK_5_408EDCA0_24E */
    jbmi rsrc_PACK_5_408EDCA0_24E	| 408EDEDE
    btst #30,%d0	| 408EDEE0
    jbeq rsrc_PACK_5_408EDCA0_24E	| 408EDEE4
    jbcc rsrc_PACK_5_408EDCA0_24E	| 408EDEE6
    fmovew #-1,%fp0	| 408EDEE8
rsrc_PACK_5_408EDCA0_24E:  /* result 0 */
    moveq #0,%d0	| 408EDEEE
    jmp %a4@	| 408EDEF0
rsrc_PACK_5_408EDCA0_252:  /* from here: fmovew #-1,%fp0 */
    fmovew #-1,%fp0	| 408EDEF2
    movel #524288,%d0	| 408EDEF8
    jmp %a4@	| 408EDEFE
rsrc_PACK_5_408EDCA0_260:  /* from here: fmoves #0einf,%fp0 */
    fmoves #0einf,%fp0
    movel #4718592,%d0
    jmp %a4@
rsrc_PACK_5_408EDCA0_270:  /* loop: fmove */
    fmovew #1,%fp0
    movel #524288,%d0
    jmp %a4@
rsrc_PACK_5_408EDCA0_27E:  /* from here: fmovew #0,%fp0 */
    fmovew #0,%fp0
    movel #2621440,%d0
    jmp %a4@
rsrc_PACK_5_408EDCA0_28C:  /* loop: jbp */
    jbpl rsrc_PACK_5_408EDCA0_296
    fmovew #1,%fp0
    jbra rsrc_PACK_5_408EDCA0_2A4
rsrc_PACK_5_408EDCA0_296:  /* test bit 30 of %d0 */
    btst #30,%d0
    jbeq rsrc_PACK_5_408EDCA0_2A4
    jbcc rsrc_PACK_5_408EDCA0_2A4
    fmovew #0,%fp0
rsrc_PACK_5_408EDCA0_2A4:  /* result 0 */
    moveq #0,%d0
    jmp %a4@

/* subroutine (14 instructions): calls rsrc_PACK_5_408EDCA0_A74 (mechanical summary) */
rsrc_PACK_5_408EDCA0_2A8:
    fbeq rsrc_PACK_5_408EDCA0_2A8_36
    fmovex %fp0,%fp2
    fmulx %fp2,%fp0
    lea %pc@(rsrc_PACK_5_408EDCA0_116A),%a0
    jbsr rsrc_PACK_5_408EDCA0_A74
    fmulx %fp1,%fp2
    lea %pc@(rsrc_PACK_5_408EDCA0_119C),%a0
    jbsr rsrc_PACK_5_408EDCA0_A74
    fsubx %fp2,%fp1
    faddx %fp2,%fp2
    fdivx %fp1,%fp2
    fmovex %fp2,%fp0
    oril #524288,%d0
rsrc_PACK_5_408EDCA0_2A8_36:  /* return */
    rts

/* subroutine (9 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0_2E0:
    fmovex %pc@(rsrc_PACK_5_408EDCA0_1246),%fp1
    fmovex %fp0,%fp3
    fremx %fp1,%fp0
    fsubx %fp0,%fp3
    fdivx %fp1,%fp3
    fmovew %fp3,%d1
    fdivx %fp1,%fp0
    oril #524288,%d0
    rts

/* subroutine (40 instructions): calls rsrc_PACK_5_408EDCA0_2A8 (mechanical summary) */
rsrc_PACK_5_408EDCA0_2E0_26:
    fmovel %fpsr,%d0
    andil #251658240,%d0
    lsll #5,%d0
    jbne rsrc_PACK_5_408EDCA0_28C
    bfextu %a0@,1,15,%d1
    cmpiw #16319,%d1
    jblt rsrc_PACK_5_408EDCA0_270
    fcmps #0e16384,%fp0
    fboge rsrc_PACK_5_408EDCA0_260
    fcmps #0e-16447,%fp0
    fbole rsrc_PACK_5_408EDCA0_27E
    fmovew %fp0,%d1
    fsubw %d1,%fp0
rsrc_PACK_5_408EDCA0_342:  /* call rsrc_PACK_5_408EDCA0_2A8 (loop) */
    jbsr rsrc_PACK_5_408EDCA0_2A8
    faddw #1,%fp0
    clrl %sp@-
    movel #-2147483648,%sp@-
    subqw #4,%sp
    cmpiw #16384,%d1
    jblt rsrc_PACK_5_408EDCA0_2E0_8A
    movew #32766,%sp@
    fmulx %sp@,%fp0
    subiw #16383,%d1
    jbra rsrc_PACK_5_408EDCA0_2E0_B6
rsrc_PACK_5_408EDCA0_2E0_8A:  /* test #-16383,%d1 */
    cmpiw #-16383,%d1
    jbgt rsrc_PACK_5_408EDCA0_2E0_B6
    jbne rsrc_PACK_5_408EDCA0_2E0_9E
    fcmpw #1,%fp0
    fboge rsrc_PACK_5_408EDCA0_2E0_B6
    jbra rsrc_PACK_5_408EDCA0_2E0_B0
rsrc_PACK_5_408EDCA0_2E0_9E:  /* set %sp@ */
    movew #1,%sp@
    fmulx %sp@,%fp0
    addiw #16382,%d1
    btst #19,%d0
    jbeq rsrc_PACK_5_408EDCA0_2E0_B6
rsrc_PACK_5_408EDCA0_2E0_B0:  /* from here: oril #2097152,%d0 */
    oril #2097152,%d0
rsrc_PACK_5_408EDCA0_2E0_B6:  /* from here: addiw #16383,%d1 */
    addiw #16383,%d1
    movew %d1,%sp@
    fmulx %sp@+,%fp0
    jmp %a4@

/* subroutine (11 instructions): calls rsrc_PACK_5_408EDCA0_2E0 (mechanical summary) */
rsrc_PACK_5_408EDCA0_3A2:
    fmovel %fpsr,%d0	| 408EE042
    andil #251658240,%d0	| 408EE046
    lsll #5,%d0	| 408EE04C
    jbne rsrc_PACK_5_408EDCA0_28C	| 408EE04E
    bfextu %a0@,1,15,%d1	| 408EE052
    cmpiw #16319,%d1	| 408EE056
    jblt rsrc_PACK_5_408EDCA0_270	| 408EE05A
    fcmps #0x46317218,%fp0	| 408EE05E
    fboge rsrc_PACK_5_408EDCA0_260	| 408EE066
    fcmps #0xc63220c5,%fp0	| 408EE06A
    fbole rsrc_PACK_5_408EDCA0_27E	| 408EE072
    jbsr rsrc_PACK_5_408EDCA0_2E0	| 408EE076
    jbra rsrc_PACK_5_408EDCA0_342	| 408EE07A

/* subroutine (43 instructions): calls rsrc_PACK_5_408EDCA0_5CC, rsrc_PACK_5_408EDCA0_6AE (mechanical summary) */
rsrc_PACK_5_408EDCA0_3DE:
    jbsr rsrc_PACK_5_408EDCA0_5CC	| 408EE07E
    fbne rsrc_PACK_5_408EDCA0_3FA	| 408EE082
    btst #26,%d0	| 408EE086
    jbne rsrc_PACK_5_408EDCA0_666	| 408EE08A
    btst #27,%d0	| 408EE08E
    jbne rsrc_PACK_5_408EDCA0_682	| 408EE092
    jbra rsrc_PACK_5_408EDCA0_66E	| 408EE096
rsrc_PACK_5_408EDCA0_3FA:  /* test bit 26 of %d0 */
    btst #26,%d0	| 408EE09A
    jbne rsrc_PACK_5_408EDCA0_666	| 408EE09E
    btst #25,%d0
    jbeq rsrc_PACK_5_408EDCA0_41E
    btst #26,%d1
    jbne rsrc_PACK_5_408EDCA0_654
    eorl %d1,%d0
    btst #27,%d0
    jbeq rsrc_PACK_5_408EDCA0_688
    jbra rsrc_PACK_5_408EDCA0_66E
rsrc_PACK_5_408EDCA0_41E:  /* save registers */
    moveml %a1/%a4,%sp@-
    bftst %d1,5,2
    jbeq rsrc_PACK_5_408EDCA0_42C
    subal %a0,%a0
    jbra rsrc_PACK_5_408EDCA0_458
rsrc_PACK_5_408EDCA0_42C:  /* from here: fabsx %fp0,%fp3 */
    fabsx %fp0,%fp3
    fcmps #0x1f800000,%fp3	| 408EE0D0
    fbolt rsrc_PACK_5_408EDCA0_458
    lea %pc@(rsrc_PACK_5_408EDCA0_A74_3C),%a1
    jbsr rsrc_PACK_5_408EDCA0_6AE
    fmovel %fpsr,%d0
    moveal %d1,%a0
    fmulx %fp2,%fp0
    lea %pc@(rsrc_PACK_5_408EDCA0_2E0_26),%a1
    jbsr rsrc_PACK_5_408EDCA0_6AE
    jbra rsrc_PACK_5_408EDCA0_464
rsrc_PACK_5_408EDCA0_458:  /* from here: fmulx %fp2,%fp0 */
    fmulx %fp2,%fp0
    lea %pc@(rsrc_PACK_5_408EDCA0_3A2),%a1
    jbsr rsrc_PACK_5_408EDCA0_6AE
rsrc_PACK_5_408EDCA0_464:  /* set %d1 */
    movel %a0,%d1
    btst #3,%d1
    jbeq rsrc_PACK_5_408EDCA0_474
    movel #524288,%d0
    jbra rsrc_PACK_5_408EDCA0_476
rsrc_PACK_5_408EDCA0_474:  /* clear %d0 */
    moveq #0,%d0
rsrc_PACK_5_408EDCA0_476:  /* restore registers */
    moveml %sp@+,%a1/%a4
    jbra rsrc_PACK_5_408EDCA0_69A

/* subroutine (84 instructions): calls rsrc_PACK_5_408EDCA0_5CC, rsrc_PACK_5_408EDCA0_6AE (mechanical summary) */
rsrc_PACK_5_408EDCA0_47E:
    jbsr rsrc_PACK_5_408EDCA0_5CC	| 408EE11E
    fbne rsrc_PACK_5_408EDCA0_49A	| 408EE122
    btst #26,%d0	| 408EE126
    jbne rsrc_PACK_5_408EDCA0_66E	| 408EE12A
    btst #27,%d0	| 408EE12E
    jbne rsrc_PACK_5_408EDCA0_672	| 408EE132
    jbra rsrc_PACK_5_408EDCA0_682	| 408EE136
rsrc_PACK_5_408EDCA0_49A:  /* test bit 26 of %d0 */
    btst #26,%d0	| 408EE13A
    jbne rsrc_PACK_5_408EDCA0_66E	| 408EE13E
    btst #25,%d1	| 408EE142
    jbne rsrc_PACK_5_408EDCA0_4B6	| 408EE146
    btst #26,%d1
    jbeq rsrc_PACK_5_408EDCA0_4CE
rsrc_PACK_5_408EDCA0_4AE:  /* loop: fmovex */
    fmovex %fp2,%fp0
    jbra rsrc_PACK_5_408EDCA0_69A
rsrc_PACK_5_408EDCA0_4B6:  /* test bit 27 of %d0 */
    btst #27,%d0	| 408EE156
    jbeq rsrc_PACK_5_408EDCA0_66E	| 408EE15A
    fcmpx %fp1,%fp2	| 408EE15E
    fbeq rsrc_PACK_5_408EDCA0_672	| 408EE162
    fbogt rsrc_PACK_5_408EDCA0_67A	| 408EE166
    jbra rsrc_PACK_5_408EDCA0_690	| 408EE16A
rsrc_PACK_5_408EDCA0_4CE:  /* from here: fmovex %fp0,%fp3 */
    fmovex %fp0,%fp3
    btst #25,%d0
    jbeq rsrc_PACK_5_408EDCA0_4EE
    eorl %d1,%d0
    btst #27,%d0
    jbne rsrc_PACK_5_408EDCA0_4AE
    fmovew #1,%fp0
    fdivx %fp3,%fp0
    jbra rsrc_PACK_5_408EDCA0_69A
rsrc_PACK_5_408EDCA0_4EE:  /* save registers */
    moveml %a1/%a4,%sp@-
    fabsx %fp3,%fp0
    fcmps #0x1f800000,%fp0	| 408EE196
    fbolt rsrc_PACK_5_408EDCA0_532
    lea %pc@(rsrc_PACK_5_408EDCA0_A74_3C),%a1
    fmovex %fp3,%fp0
    jbsr rsrc_PACK_5_408EDCA0_6AE
    fmulx %fp2,%fp0
    fnegx %fp0,%fp0
    fcmpw #256,%fp0
    fbolt rsrc_PACK_5_408EDCA0_54C
    fmoves #0x7f7fffff,%fp1	| 408EE1C0
    fcmpx %fp1,%fp3
    fbogt rsrc_PACK_5_408EDCA0_598
    jbra rsrc_PACK_5_408EDCA0_54C
rsrc_PACK_5_408EDCA0_532:  /* from here: fmovex %fp3,%fp1 */
    fmovex %fp3,%fp1
    fmulx %fp2,%fp3
    fnegx %fp3,%fp0
    fmovex %fp1,%fp3
    lea %pc@(rsrc_PACK_5_408EDCA0_1DA),%a1
    jbsr rsrc_PACK_5_408EDCA0_6AE
    jbra rsrc_PACK_5_408EDCA0_554
rsrc_PACK_5_408EDCA0_54C:  /* address %pc@(rsrc_PACK_5_408EDCA0_162) */
    lea %pc@(rsrc_PACK_5_408EDCA0_162),%a1
    jbsr rsrc_PACK_5_408EDCA0_6AE
rsrc_PACK_5_408EDCA0_554:  /* from here: fnegx %fp0,%fp0 */
    fnegx %fp0,%fp0
    fdivx %fp3,%fp0
rsrc_PACK_5_408EDCA0_55C:  /* loop: moveq */
    moveq #96,%d0
    fmovel %fpsr,%d1
    btst #11,%d1
    jbeq rsrc_PACK_5_408EDCA0_576
    btst #9,%d1
    jbeq rsrc_PACK_5_408EDCA0_576
    oril #2621440,%d0
    jbra rsrc_PACK_5_408EDCA0_590
rsrc_PACK_5_408EDCA0_576:  /* test bit 25 of %d1 */
    btst #25,%d1
    jbne rsrc_PACK_5_408EDCA0_58A
    btst #26,%d1
    jbeq rsrc_PACK_5_408EDCA0_590
    oril #2097152,%d0
    jbra rsrc_PACK_5_408EDCA0_590
rsrc_PACK_5_408EDCA0_58A:  /* from here: oril #4194304,%d0 */
    oril #4194304,%d0
rsrc_PACK_5_408EDCA0_590:  /* restore registers */
    moveml %sp@+,%a1/%a4
    jbra rsrc_PACK_5_408EDCA0_69A
rsrc_PACK_5_408EDCA0_598:  /* address %pc@(rsrc_PACK_5_408EDCA0_A74_14) */
    lea %pc@(rsrc_PACK_5_408EDCA0_A74_14),%a1
    fmovex %fp3,%fp0
    jbsr rsrc_PACK_5_408EDCA0_6AE
    faddw #1,%fp2
    fmulx %fp2,%fp0
    fnegx %fp0,%fp0
    lea %pc@(rsrc_PACK_5_408EDCA0_2E0_26),%a1
    jbsr rsrc_PACK_5_408EDCA0_6AE
    fnegx %fp0,%fp0
    fmovel %fpsr,%d1
    bset #3,%d1
    fmovel %d1,%fpsr
    jbra rsrc_PACK_5_408EDCA0_55C

/* subroutine (64 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0_5CC:
    moveal %sp@(62),%a0	| 408EE26C
    tstb %sp@(57)	| 408EE270
    jbpl rsrc_PACK_5_408EDCA0_5EC	| 408EE274
    fmovex %a0@,%fp2	| 408EE276
    fmovel %fpsr,%d0	| 408EE27A
    moveal %sp@(66),%a0	| 408EE27E
    fmovex %a0@,%fp0	| 408EE282
    fmovel %fpsr,%d1	| 408EE286
    jbra rsrc_PACK_5_408EDCA0_614	| 408EE28A
rsrc_PACK_5_408EDCA0_5EC:  /* add 6 to %a0 */
    addql #6,%a0	| 408EE28C
    movel %a0@,%sp@-	| 408EE28E
    movel %a0@-,%sp@-	| 408EE290
    subql #2,%a0	| 408EE292
    movel %a0@,%sp@-	| 408EE294
    fmovex %sp@+,%fp2	| 408EE296
    fmovel %fpsr,%d0	| 408EE29A
    moveal %sp@(66),%a0	| 408EE29E
    addql #6,%a0	| 408EE2A2
    movel %a0@,%sp@-	| 408EE2A4
    movel %a0@-,%sp@-	| 408EE2A6
    subql #2,%a0	| 408EE2A8
    movel %a0@,%sp@-	| 408EE2AA
    fmovex %sp@+,%fp0	| 408EE2AC
    fmovel %fpsr,%d1	| 408EE2B0
rsrc_PACK_5_408EDCA0_614:  /* test bit 24 of %d0 */
    btst #24,%d0
    jbeq rsrc_PACK_5_408EDCA0_62C
    fmovex %fp2,%fp0
    btst #14,%d0
    jbeq rsrc_PACK_5_408EDCA0_650
    movel #8388608,%d0
    jbra rsrc_PACK_5_408EDCA0_650
rsrc_PACK_5_408EDCA0_62C:  /* from here: fmovew #-1,%fp1 */
    fmovew #-1,%fp1
    fcmpx %fp1,%fp0
    fbolt rsrc_PACK_5_408EDCA0_640
    fbun rsrc_PACK_5_408EDCA0_644
    rts
rsrc_PACK_5_408EDCA0_640:  /* add 4 to %sp */
    addql #4,%sp
    jbra rsrc_PACK_5_408EDCA0_654
rsrc_PACK_5_408EDCA0_644:  /* test bit 14 of %d1 */
    btst #14,%d1
    jbeq rsrc_PACK_5_408EDCA0_650
    movel #8388608,%d0
rsrc_PACK_5_408EDCA0_650:  /* add 4 to %sp */
    addql #4,%sp
    jbra rsrc_PACK_5_408EDCA0_69A
rsrc_PACK_5_408EDCA0_654:  /* set %d1 */
    moveq #38,%d1
    lsll #8,%d1
    oril #2143289344,%d1
    movel #8388608,%d0
    jbra rsrc_PACK_5_408EDCA0_696
rsrc_PACK_5_408EDCA0_666:  /* (data) */
    movel #1065353216,%d1	| 408EE306
    bras rsrc_PACK_5_408EDCA0_696
rsrc_PACK_5_408EDCA0_66E:  /* clear %d1 */
    moveq #0,%d1
    jbra rsrc_PACK_5_408EDCA0_696
rsrc_PACK_5_408EDCA0_672:  /* set %d1 */
    movel #-1082130432,%d1	| 408EE312
    jbra rsrc_PACK_5_408EDCA0_696	| 408EE318
rsrc_PACK_5_408EDCA0_67A:  /* set %d1 */
    movel #-2147483648,%d1	| 408EE31A
    jbra rsrc_PACK_5_408EDCA0_696	| 408EE320
rsrc_PACK_5_408EDCA0_682:  /* from here: oril #1048576,%d0 */
    oril #1048576,%d0	| 408EE322
rsrc_PACK_5_408EDCA0_688:  /* set %d1 */
    movel #2139095040,%d1
    jbra rsrc_PACK_5_408EDCA0_696
rsrc_PACK_5_408EDCA0_690:  /* set %d1 */
    movel #-8388608,%d1	| 408EE330
rsrc_PACK_5_408EDCA0_696:  /* from here: fmoves %d1,%fp0 */
    fmoves %d1,%fp0
rsrc_PACK_5_408EDCA0_69A:  /* set %sp@(58) */
    movel %sp@(48),%sp@(58)
    lea %pc@(rsrc_PACK_5_408EDCA0_6AA),%a0
    movel %a0,%sp@(48)
    jmp %a4@
rsrc_PACK_5_408EDCA0_6AA:  /* from here: rtd #4 */
    rtd #4	| 408EE34A

/* subroutine (19 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0_6AE:
    fmovemx %fp1-%fp3,%sp@-
    moveml %a0/%a4,%sp@-
    ftstx %fp0
    lea %pc@(rsrc_PACK_5_408EDCA0_6AE_1E),%a4
    fmovemx %fp0,%sp@-
    lea %sp@,%a0
    movew %a0@(4),%a0@(2)
    jmp %a1@
rsrc_PACK_5_408EDCA0_6AE_1E:  /* from here: addaw #12,%sp */
    addaw #12,%sp
    moveml %sp@+,%a0/%a4
    fmovemx %sp@+,%fp1-%fp3
    moveq #-1,%d1
    eorb %d1,%d0
    fmovel %fpsr,%d1
    andb %d0,%d1
    swap %d0
    orb %d0,%d1
    fmovel %d1,%fpsr
    rts

/* subroutine (51 instructions): calls rsrc_PACK_5_408EDCA0_78A, rsrc_PACK_5_408EDCA0_860 (mechanical summary) */
rsrc_PACK_5_408EDCA0_6EC:
    moveml %d2-%d4/%a1,%sp@-
    moveal %sp@(74),%a1
    movew %a1@,%d2
    moveq #0,%d4
    fmovel %fpsr,%d0
    movel #251658240,%d1
    andl %d1,%d0
    movel %d0,%d1
    lsll #5,%d0
    jbeq rsrc_PACK_5_408EDCA0_6EC_66
    btst #29,%d0
    jbne rsrc_PACK_5_408EDCA0_83C_6
    tstw %d2
    jbeq rsrc_PACK_5_408EDCA0_804_10
    btst #0,%d2
    jbne rsrc_PACK_5_408EDCA0_6EC_48
    tstw %d2
    jbmi rsrc_PACK_5_408EDCA0_6EC_3E
    fabsx %fp0,%fp0
    jbra rsrc_PACK_5_408EDCA0_83C_6
rsrc_PACK_5_408EDCA0_6EC_3E:  /* test %d0 */
    tstl %d0
    jbmi rsrc_PACK_5_408EDCA0_828
    jbra rsrc_PACK_5_408EDCA0_81C
rsrc_PACK_5_408EDCA0_6EC_48:  /* test %d2 */
    tstw %d2
    jbpl rsrc_PACK_5_408EDCA0_83C_6
    tstl %d0
    jbmi rsrc_PACK_5_408EDCA0_6EC_5C
    lsll #5,%d1
    jbcc rsrc_PACK_5_408EDCA0_81C
    jbra rsrc_PACK_5_408EDCA0_820
rsrc_PACK_5_408EDCA0_6EC_5C:  /* from here: lsll #5,%d1 */
    lsll #5,%d1
    jbcc rsrc_PACK_5_408EDCA0_828
    jbra rsrc_PACK_5_408EDCA0_832
rsrc_PACK_5_408EDCA0_6EC_66:  /* set %d0 */
    movew %d2,%d0
    jbpl rsrc_PACK_5_408EDCA0_6EC_6C
    negw %d0
rsrc_PACK_5_408EDCA0_6EC_6C:  /* test #255,%d0 */
    cmpiw #255,%d0
    jbhi rsrc_PACK_5_408EDCA0_6EC_7A
    jbsr rsrc_PACK_5_408EDCA0_78A
    moveq #0,%d0
    jbra rsrc_PACK_5_408EDCA0_83C_6
rsrc_PACK_5_408EDCA0_6EC_7A:  /* from here: fabsx %fp0,%fp0 */
    fabsx %fp0,%fp0
    fmovew %d2,%fp3
    jbsr rsrc_PACK_5_408EDCA0_860
    moveq #0,%d0
    tstl %a0@
    jbpl rsrc_PACK_5_408EDCA0_83C_6
    btst #0,%d2
    jbeq rsrc_PACK_5_408EDCA0_83C_6
    fnegx %fp0,%fp0
    jbra rsrc_PACK_5_408EDCA0_83C_6

/* subroutine (24 instructions): calls rsrc_PACK_5_408EDCA0_7D8 (mechanical summary) */
rsrc_PACK_5_408EDCA0_78A:
    fmovex %fp0,%fp1
    jbsr rsrc_PACK_5_408EDCA0_7D8
    tstw %d2
    jbmi rsrc_PACK_5_408EDCA0_78A_10
rsrc_PACK_5_408EDCA0_78A_A:  /* loop: fmovex */
    fmovex %fp2,%fp0
    rts
rsrc_PACK_5_408EDCA0_78A_10:  /* set %d0 */
    movew %d2,%d0
    jbpl rsrc_PACK_5_408EDCA0_78A_16
    negw %d0
rsrc_PACK_5_408EDCA0_78A_16:  /* from here: fmovel %fpsr,%d1 */
    fmovel %fpsr,%d1
    andil #96,%d1
    jbne rsrc_PACK_5_408EDCA0_78A_2E
    fmovew #1,%fp0
    fdivx %fp2,%fp0
    rts
rsrc_PACK_5_408EDCA0_78A_2E:  /* from here: fmovel %fpsr,%d1 */
    fmovel %fpsr,%d1
    moveq #96,%d0
    eoril #-1,%d0
    andl %d0,%d1
    fmovel %d1,%fpsr
    fmovew #1,%fp0
    fdivx %fp1,%fp0
    jbsr rsrc_PACK_5_408EDCA0_7D8
    jbra rsrc_PACK_5_408EDCA0_78A_A

/* subroutine (8 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0_7D8:
    fmovew #1,%fp2
    jbra rsrc_PACK_5_408EDCA0_7D8_C
rsrc_PACK_5_408EDCA0_7D8_8:  /* loop: fmulx */
    fmulx %fp0,%fp0
rsrc_PACK_5_408EDCA0_7D8_C:  /* from here: lsrw #1,%d0 */
    lsrw #1,%d0
    jbcc rsrc_PACK_5_408EDCA0_7D8_14
    fmulx %fp0,%fp2
rsrc_PACK_5_408EDCA0_7D8_14:  /* from here: jbne rsrc_PACK_5_408EDCA0_7D8_8 */
    jbne rsrc_PACK_5_408EDCA0_7D8_8
    rts

/* subroutine (6 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0_7F0:
    fmovel %fpsr,%d1
    moveq #8,%d0
    eoril #-1,%d0
    andl %d0,%d1
    fmovel %d1,%fpsr
    rts

/* subroutine (27 instructions): calls rsrc_PACK_5_408EDCA0_804 (mechanical summary) */
rsrc_PACK_5_408EDCA0_804:
    fmovel %fpsr,%d0
    oril #1048576,%d0
    fmovel %d0,%fpsr
    rts
rsrc_PACK_5_408EDCA0_804_10:  /* set %d1 */
    movel #1065353216,%d1
    jbra rsrc_PACK_5_408EDCA0_83C

rsrc_PACK_5_408EDCA0_81C:  /* clear %d1 */
    moveq #0,%d1
    jbra rsrc_PACK_5_408EDCA0_83C

rsrc_PACK_5_408EDCA0_820:  /* set %d1 */
    movel #-2147483648,%d1
    jbra rsrc_PACK_5_408EDCA0_83C

rsrc_PACK_5_408EDCA0_828:  /* call rsrc_PACK_5_408EDCA0_804 (loop) */
    jbsr rsrc_PACK_5_408EDCA0_804
    movel #2139095040,%d1
    jbra rsrc_PACK_5_408EDCA0_83C_2

rsrc_PACK_5_408EDCA0_832:  /* call rsrc_PACK_5_408EDCA0_804 (loop) */
    jbsr rsrc_PACK_5_408EDCA0_804
    movel #-8388608,%d1
    jbra rsrc_PACK_5_408EDCA0_83C_2

rsrc_PACK_5_408EDCA0_83C:  /* clear %d0 */
    moveq #0,%d0
rsrc_PACK_5_408EDCA0_83C_2:  /* loop: fmoves */
    fmoves %d1,%fp0
rsrc_PACK_5_408EDCA0_83C_6:  /* loop: tst */
    tstb %d4
    jbeq rsrc_PACK_5_408EDCA0_83C_E
    fnegx %fp0,%fp0
rsrc_PACK_5_408EDCA0_83C_E:  /* restore registers */
    moveml %sp@+,%d2-%d4/%a1
    movel %sp@(48),%sp@(58)
    lea %pc@(rsrc_PACK_5_408EDCA0_85E),%a0
    movel %a0,%sp@(48)
    jmp %a4@
rsrc_PACK_5_408EDCA0_85E:  /* return */
    rts	| 408EE4FE

/* subroutine (6 instructions): calls rsrc_PACK_5_408EDCA0_6AE (mechanical summary) */
rsrc_PACK_5_408EDCA0_860:
    lea %pc@(rsrc_PACK_5_408EDCA0_A74_14),%a1
    jbsr rsrc_PACK_5_408EDCA0_6AE
    fmulx %fp3,%fp0
    lea %pc@(rsrc_PACK_5_408EDCA0_2E0_26),%a1
    jbsr rsrc_PACK_5_408EDCA0_6AE
    rts

/* subroutine (121 instructions): calls rsrc_PACK_5_408EDCA0_78A, rsrc_PACK_5_408EDCA0_860, rsrc_PACK_5_408EDCA0_804, rsrc_PACK_5_408EDCA0_A00, rsrc_PACK_5_408EDCA0_7F0 (mechanical summary) */
rsrc_PACK_5_408EDCA0_876:
    fmovel %fpsr,%d0	| 408EE516
    moveml %d2-%d4/%a1,%sp@-	| 408EE51A
    moveal %sp@(74),%a1	| 408EE51E
    moveb %sp@(69),%d1	| 408EE522
    jbpl rsrc_PACK_5_408EDCA0_88E	| 408EE526
    fmovex %a1@,%fp3	| 408EE528
    jbra rsrc_PACK_5_408EDCA0_89C	| 408EE52C
rsrc_PACK_5_408EDCA0_88E:  /* add 6 to %a1 */
    addql #6,%a1	| 408EE52E
    movel %a1@,%sp@-	| 408EE530
    movel %a1@-,%sp@-	| 408EE532
    subql #2,%a1	| 408EE534
    movel %a1@,%sp@-	| 408EE536
    fmovex %sp@+,%fp3	| 408EE538
rsrc_PACK_5_408EDCA0_89C:  /* clear %d4 */
    moveq #0,%d4	| 408EE53C
    fmovel %fpsr,%d1	| 408EE53E
    movel #251658240,%d2	| 408EE542
    movel %d1,%d3	| 408EE548
    andl %d2,%d3	| 408EE54A
    lsll #5,%d3	| 408EE54C
    andl %d2,%d0	| 408EE54E
    lsll #5,%d0	| 408EE550
    jbne rsrc_PACK_5_408EDCA0_910	| 408EE552
    jbcs rsrc_PACK_5_408EDCA0_910	| 408EE554
    tstl %d3	| 408EE556
    jbne rsrc_PACK_5_408EDCA0_910	| 408EE558
rsrc_PACK_5_408EDCA0_860_5A:  /* loop: fmove */
    fmovew %fp3,%d2
    fmovel %fpsr,%d1
    bclr #7,%d1
    sne %d2
    fmovel %d1,%fpsr
    btst #3,%d1
    sne %d0
    orb %d2,%d0
    jbne rsrc_PACK_5_408EDCA0_860_8E
    fmovew %fp3,%d2
    movew %d2,%d0
    jbpl rsrc_PACK_5_408EDCA0_860_80
    negw %d0
rsrc_PACK_5_408EDCA0_860_80:  /* test #255,%d0 */
    cmpiw #255,%d0
    jble rsrc_PACK_5_408EDCA0_860_88
    jbra rsrc_PACK_5_408EDCA0_860_8E
rsrc_PACK_5_408EDCA0_860_88:  /* call rsrc_PACK_5_408EDCA0_78A */
    jbsr rsrc_PACK_5_408EDCA0_78A
    jbra rsrc_PACK_5_408EDCA0_860_9A
rsrc_PACK_5_408EDCA0_860_8E:  /* clear bit 3 of %d1 */
    bclr #3,%d1
    fmovel %d1,%fpsr
    jbsr rsrc_PACK_5_408EDCA0_860
rsrc_PACK_5_408EDCA0_860_9A:  /* clear %d0 */
    moveq #0,%d0
    btst #31,%d3
    jbne rsrc_PACK_5_408EDCA0_860_A8
    btst #30,%d3
    jbeq rsrc_PACK_5_408EDCA0_860_AC
rsrc_PACK_5_408EDCA0_860_A8:  /* set %d0 */
    moveb #8,%d0
rsrc_PACK_5_408EDCA0_860_AC:  /* continue at rsrc_PACK_5_408EDCA0_83C_6 */
    jbra rsrc_PACK_5_408EDCA0_83C_6
rsrc_PACK_5_408EDCA0_910:  /* from here: jbpl rsrc_PACK_5_408EDCA0_972 */
    jbpl rsrc_PACK_5_408EDCA0_972	| 408EE5B0
    jbcc rsrc_PACK_5_408EDCA0_972	| 408EE5B2
    btst #29,%d3	| 408EE5B4
    jbne rsrc_PACK_5_408EDCA0_972	| 408EE5B8
    lsll #5,%d1	| 408EE5BA
    jbne rsrc_PACK_5_408EDCA0_970	| 408EE5BC
    fintx %fp3,%fp3	| 408EE5BE
    fmovel %fpsr,%d2	| 408EE5C2
    btst #3,%d2	| 408EE5C6
    jbne rsrc_PACK_5_408EDCA0_860_13A	| 408EE5CA
    jbcs rsrc_PACK_5_408EDCA0_94E	| 408EE5CC
    fmuls #0e0.5,%fp3	| 408EE5CE
    fintx %fp3,%fp3	| 408EE5D6
    fmovel %fpsr,%d2	| 408EE5DA
    btst #3,%d2	| 408EE5DE
    jbne rsrc_PACK_5_408EDCA0_948	| 408EE5E2
    fabsx %fp0,%fp0	| 408EE5E4
rsrc_PACK_5_408EDCA0_948:  /* result 8 */
    moveq #8,%d0	| 408EE5E8
    jbra rsrc_PACK_5_408EDCA0_83C_6	| 408EE5EA
rsrc_PACK_5_408EDCA0_94E:  /* call rsrc_PACK_5_408EDCA0_804 */
    jbsr rsrc_PACK_5_408EDCA0_804	| 408EE5EE
    fmuls #0e0.5,%fp3	| 408EE5F2
    fintx %fp3,%fp3	| 408EE5FA
    fmovel %fpsr,%d2	| 408EE5FE
    btst #3,%d2	| 408EE602
    jbne rsrc_PACK_5_408EDCA0_96C	| 408EE606
    jbra rsrc_PACK_5_408EDCA0_828
rsrc_PACK_5_408EDCA0_96C:  /* continue at rsrc_PACK_5_408EDCA0_832 */
    jbra rsrc_PACK_5_408EDCA0_832	| 408EE60C
rsrc_PACK_5_408EDCA0_970:  /* continue at rsrc_PACK_5_408EDCA0_860_13A */
    jbra rsrc_PACK_5_408EDCA0_860_13A	| 408EE610
rsrc_PACK_5_408EDCA0_972:  /* test bit 29 of %d0 */
    btst #29,%d0
    jbeq rsrc_PACK_5_408EDCA0_860_11C
    jbra rsrc_PACK_5_408EDCA0_83C_6
rsrc_PACK_5_408EDCA0_860_11C:  /* test bit 29 of %d3 */
    btst #29,%d3
    jbeq rsrc_PACK_5_408EDCA0_860_12A
    fmovex %fp3,%fp0
    jbra rsrc_PACK_5_408EDCA0_83C_6
rsrc_PACK_5_408EDCA0_860_12A:  /* from here: ftstx %fp0 */
    ftstx %fp0
    fblt rsrc_PACK_5_408EDCA0_860_152
    jbsr rsrc_PACK_5_408EDCA0_A00
    jbra rsrc_PACK_5_408EDCA0_83C_6
rsrc_PACK_5_408EDCA0_860_138:  /* loop: addq */
    addql #4,%sp
rsrc_PACK_5_408EDCA0_860_13A:  /* call rsrc_PACK_5_408EDCA0_7F0 (loop) */
    jbsr rsrc_PACK_5_408EDCA0_7F0
    moveq #37,%d1
    lsll #8,%d1
    oril #2143289344,%d1
    movel #8388608,%d0
    jbra rsrc_PACK_5_408EDCA0_83C_2
rsrc_PACK_5_408EDCA0_860_152:  /* test bit 30 of %d3 */
    btst #30,%d3
    jbne rsrc_PACK_5_408EDCA0_860_13A
    btst #30,%d0
    jbeq rsrc_PACK_5_408EDCA0_860_164
    btst #31,%d3
    jbne rsrc_PACK_5_408EDCA0_860_13A
rsrc_PACK_5_408EDCA0_860_164:  /* from here: fintx %fp3,%fp2 */
    fintx %fp3,%fp2
    fmovel %fpsr,%d2
    btst #3,%d2
    jbne rsrc_PACK_5_408EDCA0_860_13A
    fmuls #0e0.5,%fp2
    fintx %fp2,%fp2
    fmovel %fpsr,%d2
    btst #3,%d2
    sne %d4
    jbsr rsrc_PACK_5_408EDCA0_7F0
    fabsx %fp0,%fp0
    jbsr rsrc_PACK_5_408EDCA0_A00
    tstb %d4
    jbeq rsrc_PACK_5_408EDCA0_83C_6
    fnegx %fp0,%fp0
    jbra rsrc_PACK_5_408EDCA0_83C_6

/* subroutine (37 instructions): calls rsrc_PACK_5_408EDCA0_804 (mechanical summary) */
rsrc_PACK_5_408EDCA0_A00:
    fbne rsrc_PACK_5_408EDCA0_A00_30
    btst #30,%d3
    jbne rsrc_PACK_5_408EDCA0_A00_16
    tstl %d3
    jbne rsrc_PACK_5_408EDCA0_860_138
    ftstx %fp3
    fblt rsrc_PACK_5_408EDCA0_A00_20
rsrc_PACK_5_408EDCA0_A00_16:  /* from here: lsll #5,%d1 */
    lsll #5,%d1
    jbcs rsrc_PACK_5_408EDCA0_A00_20
    moveq #0,%d1
    moveq #0,%d0
    jbra rsrc_PACK_5_408EDCA0_A00_2A
rsrc_PACK_5_408EDCA0_A00_20:  /* call rsrc_PACK_5_408EDCA0_804 */
    jbsr rsrc_PACK_5_408EDCA0_804
    movel #2139095040,%d1
rsrc_PACK_5_408EDCA0_A00_2A:  /* from here: fmoves %d1,%fp0 */
    fmoves %d1,%fp0
    rts
rsrc_PACK_5_408EDCA0_A00_30:  /* test bit 30 of %d0 */
    btst #30,%d0
    jbeq rsrc_PACK_5_408EDCA0_A00_58
    tstl %d3
    jbmi rsrc_PACK_5_408EDCA0_A00_3C
    jbra rsrc_PACK_5_408EDCA0_A00_52
rsrc_PACK_5_408EDCA0_A00_3C:  /* test %d0 */
    tstl %d0
    jbpl rsrc_PACK_5_408EDCA0_A00_4E
    fmovew #1,%fp0
    moveq #0,%d0
    addql #4,%sp
    jbra rsrc_PACK_5_408EDCA0_83C_6
rsrc_PACK_5_408EDCA0_A00_4E:  /* continue at rsrc_PACK_5_408EDCA0_860_138 */
    jbra rsrc_PACK_5_408EDCA0_860_138
rsrc_PACK_5_408EDCA0_A00_52:  /* add 4 to %sp */
    addql #4,%sp
    jbra rsrc_PACK_5_408EDCA0_860_5A
rsrc_PACK_5_408EDCA0_A00_58:  /* test bit 30 of %d3 */
    btst #30,%d3
    jbeq rsrc_PACK_5_408EDCA0_A00_6E
    fcmps #0e1,%fp0
    fbne rsrc_PACK_5_408EDCA0_A00_6E
    jbra rsrc_PACK_5_408EDCA0_860_138
rsrc_PACK_5_408EDCA0_A00_6E:  /* add 4 to %sp */
    addql #4,%sp
    jbra rsrc_PACK_5_408EDCA0_860_5A

/* subroutine (6 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0_A74:
    movew %a0@+,%d0
    fmovex %a0@+,%fp1
rsrc_PACK_5_408EDCA0_A74_6:  /* loop: fmulx */
    fmulx %fp0,%fp1
    faddx %a0@+,%fp1
    dbf %d0,rsrc_PACK_5_408EDCA0_A74_6
    rts

/* subroutine (10 instructions): calls rsrc_PACK_5_408EDCA0_BC6, rsrc_PACK_5_408EDCA0_C5E, rsrc_PACK_5_408EDCA0_BD6 (mechanical summary) */
rsrc_PACK_5_408EDCA0_A74_14:
    fmovel %fpsr,%d0
    jbsr rsrc_PACK_5_408EDCA0_BC6
    jbsr rsrc_PACK_5_408EDCA0_C5E
    fsubl #1,%fp0
    fsne %d1
    jbsr rsrc_PACK_5_408EDCA0_BD6
    tstb %d1
    jbeq rsrc_PACK_5_408EDCA0_A74_3A
    movel #524288,%d0
rsrc_PACK_5_408EDCA0_A74_3A:  /* jump through %a4@ */
    jmp %a4@

/* subroutine (34 instructions): calls rsrc_PACK_5_408EDCA0_BC6, rsrc_PACK_5_408EDCA0_C5E, rsrc_PACK_5_408EDCA0_BD6 (mechanical summary) */
rsrc_PACK_5_408EDCA0_A74_3C:
    fmovex %fp0,%fp1
    faddl #1,%fp0
    fmovel %fpsr,%d0
    jbsr rsrc_PACK_5_408EDCA0_BC6
    fmovel %fpsr,%d1
    swap %d1
    fcmpx %pc@(rsrc_PACK_5_408EDCA0_122E),%fp0
    fbgt rsrc_PACK_5_408EDCA0_A74_80
    fcmpx %pc@(rsrc_PACK_5_408EDCA0_123A),%fp0
    fblt rsrc_PACK_5_408EDCA0_A74_80
    fmovel #0,%fp3
    fmovex %fp1,%fp0
    bfextu %a0@,1,16,%d0
    jbeq rsrc_PACK_5_408EDCA0_A74_A6
    moveq #1,%d1
    jbra rsrc_PACK_5_408EDCA0_A74_90
rsrc_PACK_5_408EDCA0_A74_80:  /* call rsrc_PACK_5_408EDCA0_C5E */
    jbsr rsrc_PACK_5_408EDCA0_C5E
    fsubl #1,%fp0
    fsne %d1
rsrc_PACK_5_408EDCA0_A74_90:  /* call rsrc_PACK_5_408EDCA0_BD6 */
    jbsr rsrc_PACK_5_408EDCA0_BD6
    tstb %d1
    jbne rsrc_PACK_5_408EDCA0_A74_9E
    btst #19,%d1
    jbeq rsrc_PACK_5_408EDCA0_A74_A4
rsrc_PACK_5_408EDCA0_A74_9E:  /* set %d0 */
    movel #524288,%d0
rsrc_PACK_5_408EDCA0_A74_A4:  /* jump through %a4@ */
    jmp %a4@
rsrc_PACK_5_408EDCA0_A74_A6:  /* from here: fbeq rsrc_PACK_5_408EDCA0_A74_C4 */
    fbeq rsrc_PACK_5_408EDCA0_A74_C4
    fdivx %pc@(rsrc_PACK_5_408EDCA0_1246),%fp0
    fmovemx %fp0,%sp@-
    tstw %sp@(4)
    lea %sp@(12),%sp
    jbmi rsrc_PACK_5_408EDCA0_A74_C4
    movel #2097152,%d0
rsrc_PACK_5_408EDCA0_A74_C4:  /* jump through %a4@ */
    jmp %a4@

/* subroutine (22 instructions): calls rsrc_PACK_5_408EDCA0_BC6, rsrc_PACK_5_408EDCA0_C5E, rsrc_PACK_5_408EDCA0_BD6 (mechanical summary) */
rsrc_PACK_5_408EDCA0_B3A:
    fmovex %fp0,%fp1	| 408EE7DA
    faddl #1,%fp0	| 408EE7DE
    fmovel %fpsr,%d0	| 408EE7E6
    jbsr rsrc_PACK_5_408EDCA0_BC6	| 408EE7EA
    fcmpx %pc@(rsrc_PACK_5_408EDCA0_122E),%fp0	| 408EE7EC
    fbgt rsrc_PACK_5_408EDCA0_B74	| 408EE7F2
    fcmpx %pc@(rsrc_PACK_5_408EDCA0_123A),%fp0	| 408EE7F6
    fblt rsrc_PACK_5_408EDCA0_B74	| 408EE7FC
    fmovel #0,%fp3	| 408EE800
    fmovex %fp1,%fp0	| 408EE808
    bfextu %a0@,1,16,%d0	| 408EE80C
    jbeq rsrc_PACK_5_408EDCA0_B90	| 408EE810
    jbra rsrc_PACK_5_408EDCA0_B80	| 408EE812
rsrc_PACK_5_408EDCA0_B74:  /* call rsrc_PACK_5_408EDCA0_C5E */
    jbsr rsrc_PACK_5_408EDCA0_C5E	| 408EE814
    .byte   0xF2, 0x3C, 0x40, 0x28	| 408EE818
    orib #1,%d0
rsrc_PACK_5_408EDCA0_B80:  /* call rsrc_PACK_5_408EDCA0_BD6 */
    jbsr rsrc_PACK_5_408EDCA0_BD6
    fmulx %pc@(rsrc_PACK_5_408EDCA0_1246),%fp0
    movel #524288,%d0
    jmp %a4@
rsrc_PACK_5_408EDCA0_B90:  /* from here: fbeq rsrc_PACK_5_408EDCA0_B9A */
    fbeq rsrc_PACK_5_408EDCA0_B9A	| 408EE830
    movel #2097152,%d0	| 408EE834
rsrc_PACK_5_408EDCA0_B9A:  /* jump through %a4@ */
    jmp %a4@	| 408EE83A

/* subroutine (11 instructions): calls rsrc_PACK_5_408EDCA0_BC6, rsrc_PACK_5_408EDCA0_C5E, rsrc_PACK_5_408EDCA0_BD6 (mechanical summary) */
rsrc_PACK_5_408EDCA0_B9C:
    fmovel %fpsr,%d0	| 408EE83C
    jbsr rsrc_PACK_5_408EDCA0_BC6	| 408EE840
    jbsr rsrc_PACK_5_408EDCA0_C5E	| 408EE842
    .byte   0xF2, 0x3C, 0x40, 0x28	| 408EE846
    orib #1,%d0
    jbsr rsrc_PACK_5_408EDCA0_BD6
    fmulx %pc@(rsrc_PACK_5_408EDCA0_1246),%fp0
    fbeq rsrc_PACK_5_408EDCA0_A74_14E
    movel #524288,%d0
    jmp %a4@
rsrc_PACK_5_408EDCA0_A74_14E:  /* result 8 */
    moveq #8,%d0
    jmp %a4@

/* subroutine (6 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0_BC6:
    movel #251658240,%d1
    andl %d1,%d0
    lsll #5,%d0
    jbcs rsrc_PACK_5_408EDCA0_BD6_64
    jbne rsrc_PACK_5_408EDCA0_BD6_46
    rts

/* subroutine (29 instructions): calls rsrc_PACK_5_408EDCA0_A74 (mechanical summary) */
rsrc_PACK_5_408EDCA0_BD6:
    fmovex %fp0,%fp2
    faddl #2,%fp2
    fdivx %fp2,%fp0
    fmovex %fp0,%fp2
    fmulx %fp2,%fp0
    lea %pc@(rsrc_PACK_5_408EDCA0_10FA),%a0
    jbsr rsrc_PACK_5_408EDCA0_A74
    fmulx %fp1,%fp2
    lea %pc@(rsrc_PACK_5_408EDCA0_1144),%a0
    jbsr rsrc_PACK_5_408EDCA0_A74
    fmovel %fpsr,%d0
    bclr #5,%d0
    fmovel %d0,%fpsr
    fdivx %fp1,%fp2
    fmovex %fp2,%fp0
    faddx %fp3,%fp0
    rts
rsrc_PACK_5_408EDCA0_BD6_46:  /* add 4 to %sp */
    addql #4,%sp
    jbmi rsrc_PACK_5_408EDCA0_BD6_4C
    jmp %a4@
rsrc_PACK_5_408EDCA0_BD6_4C:  /* (fmovex #0e-inf,%fp0) */
    fmovex #0xffff00000000000000000000,%fp0	| 408EE8C2
    movel #1048576,%d0
    jmp %a4@
rsrc_PACK_5_408EDCA0_BD6_64:  /* add 4 to %sp */
    addql #4,%sp
    lsll #1,%d0
    jbcs rsrc_PACK_5_408EDCA0_BD6_4C
    btst #30,%d0
    jbne rsrc_PACK_5_408EDCA0_BD6_86
    fmovex #0x7fff00004024000000000000,%fp0	| 408EE8E6
    movel #8388616,%d0
rsrc_PACK_5_408EDCA0_BD6_86:  /* jump through %a4@ */
    jmp %a4@

/* subroutine (28 instructions) (mechanical summary) */
rsrc_PACK_5_408EDCA0_C5E:
    moveml %d0-%d2,%sp@-
    fmovemx %fp0,%sp@-
    moveml %sp@,%d0-%d2
    swap %d0
    movew #16383,%sp@
    subiw #16383,%d0
    tstl %d1
    jbmi rsrc_PACK_5_408EDCA0_C5E_34
    jbne rsrc_PACK_5_408EDCA0_C5E_26
    exg %d1,%d2
    subiw #32,%d0
    tstl %d1
    jbmi rsrc_PACK_5_408EDCA0_C5E_2E
rsrc_PACK_5_408EDCA0_C5E_26:  /* loop: subq */
    subqw #1,%d0
    addl %d2,%d2
    addxl %d1,%d1
    jbpl rsrc_PACK_5_408EDCA0_C5E_26
rsrc_PACK_5_408EDCA0_C5E_2E:  /* set %sp@(4) */
    moveml %d1-%d2,%sp@(4)
rsrc_PACK_5_408EDCA0_C5E_34:  /* test %pc@(rsrc_PACK_5_408EDCA0_1232),%d1 */
    cmpl %pc@(rsrc_PACK_5_408EDCA0_1232),%d1
    jbgt rsrc_PACK_5_408EDCA0_C5E_42
    jbne rsrc_PACK_5_408EDCA0_C5E_46
    cmpl %pc@(rsrc_PACK_5_408EDCA0_1236),%d2
    jbcs rsrc_PACK_5_408EDCA0_C5E_46
rsrc_PACK_5_408EDCA0_C5E_42:  /* add 1 to %d0 */
    addqw #1,%d0
    subqw #1,%sp@
rsrc_PACK_5_408EDCA0_C5E_46:  /* from here: fmovex %sp@+,%fp0 */
    fmovex %sp@+,%fp0
    fmovew %d0,%fp3
    moveml %sp@+,%d0-%d2
    rts	| 408EE950

/* subroutine (58 instructions): calls rsrc_PACK_5_408EDCA0_A74 (mechanical summary) */
rsrc_PACK_5_408EDCA0_CB2:
    fmovel %fpsr,%d0	| 408EE952
    andil #251658240,%d0	| 408EE956
    lsll #5,%d0	| 408EE95C
    jbne rsrc_PACK_5_408EDCA0_D90	| 408EE95E
    bfextu %a0@,1,15,%d0	| 408EE962
    cmpiw #16351,%d0	| 408EE966
    jbge rsrc_PACK_5_408EDCA0_CE0	| 408EE96A
    movel #524288,%d0	| 408EE96C
    bftst %a0@,1,16	| 408EE972
    jbne rsrc_PACK_5_408EDCA0_CDE	| 408EE976
    oril #2097152,%d0	| 408EE978
rsrc_PACK_5_408EDCA0_CDE:  /* jump through %a4@ */
    jmp %a4@	| 408EE97E
rsrc_PACK_5_408EDCA0_CE0:  /* from here: fremx %pc@(rsrc_PACK_5_408EDCA0_1276),%fp0 */
    fremx %pc@(rsrc_PACK_5_408EDCA0_1276),%fp0	| 408EE980
    fmovex %fp0,%fp3	| 408EE986
    fmulx %fp0,%fp0	| 408EE98A
    lea %pc@(rsrc_PACK_5_408EDCA0_137C),%a0	| 408EE98E
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EE992
    fmovex %fp1,%fp2	| 408EE996
    lea %pc@(rsrc_PACK_5_408EDCA0_134A),%a0	| 408EE99A
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EE99E
    fdivx %fp1,%fp2	| 408EE9A2
    fmulx %fp0,%fp2	| 408EE9A6
    fmovex %fp0,%fp1	| 408EE9AA
    fmulx %fp3,%fp1	| 408EE9AE
    fmulx %fp1,%fp2	| 408EE9B2
    fcmps #0e0.25,%fp0	| 408EE9B6
    fbgt rsrc_PACK_5_408EDCA0_D38	| 408EE9BE
    fmulx %fp3,%fp0	| 408EE9C2
    fdivs #0e3,%fp0	| 408EE9C6
    faddx %fp2,%fp0	| 408EE9CE
    faddx %fp3,%fp0	| 408EE9D2
    jbra rsrc_PACK_5_408EDCA0_D64	| 408EE9D6
rsrc_PACK_5_408EDCA0_D38:  /* from here: fmovex %fp3,%fp1 */
    fmovex %fp3,%fp1	| 408EE9D8
    fadds #0e-0.75,%fp1	| 408EE9DC
    fdivs #0e3,%fp1	| 408EE9E4
    fmulx %fp0,%fp1	| 408EE9EC
    faddx %fp2,%fp1	| 408EE9F0
    fmuls #0e0.25,%fp0	| 408EE9F4
    faddx %fp1,%fp0	| 408EE9FC
    faddx %fp3,%fp0	| 408EEA00
rsrc_PACK_5_408EDCA0_D64:  /* from here: fmovel %fpsr,%d0 */
    fmovel %fpsr,%d0	| 408EEA04
    swap %d0	| 408EEA08
    lsrb #1,%d0	| 408EEA0A
    jbcc rsrc_PACK_5_408EDCA0_D88	| 408EEA0C
    fmoves #0e-1,%fp1	| 408EEA0E
    fdivx %fp0,%fp1	| 408EEA16
    fmovex %fp1,%fp0	| 408EEA1A
    btst #10,%d0	| 408EEA1E
    jbeq rsrc_PACK_5_408EDCA0_D88	| 408EEA22
    fnegx %fp0,%fp0	| 408EEA24
rsrc_PACK_5_408EDCA0_D88:  /* set %d0 */
    movel #524288,%d0	| 408EEA28
    jmp %a4@	| 408EEA2E
rsrc_PACK_5_408EDCA0_D90:  /* from here: jbmi rsrc_PACK_5_408EDCA0_DB0 */
    jbmi rsrc_PACK_5_408EDCA0_DB0	| 408EEA30
    btst #29,%d0	| 408EEA32
    jbne rsrc_PACK_5_408EDCA0_DB0	| 408EEA36
    .short  0xF23C, 0x4800, 0x7FFF, 0x0000, 0x4021, 0x0000, 0x0000, 0x0000	| 408EEA38 fmovex #0enan,%fp0
    .byte   0x20, 0x3C	| 408EEA48
    oril #20180,%d0	| 408EEA4A
rsrc_PACK_5_408EDCA0_DB0:  /* result 0 */
    moveq #0,%d0	| 408EEA50
    jmp %a4@	| 408EEA52

/* subroutine (92 instructions): calls rsrc_PACK_5_408EDCA0_A74 (mechanical summary) */
rsrc_PACK_5_408EDCA0_DB4:
    fmovel %fpsr,%d0	| 408EEA54
    moveq #0,%d1	| 408EEA58
    andil #251658240,%d0	| 408EEA5A
    lsll #5,%d0	| 408EEA60
    jbne rsrc_PACK_5_408EDCA0_F08	| 408EEA62
    jbcc rsrc_PACK_5_408EDCA0_DCC	| 408EEA66
    bset #31,%d1	| 408EEA68
rsrc_PACK_5_408EDCA0_DCC:  /* from here: bfextu %a0@,1,15,%d0 */
    bfextu %a0@,1,15,%d0	| 408EEA6C
    cmpiw #16351,%d0	| 408EEA70
    jbge rsrc_PACK_5_408EDCA0_DEA	| 408EEA74
    movel #524288,%d0	| 408EEA76
    bftst %a0@,1,16	| 408EEA7C
    jbne rsrc_PACK_5_408EDCA0_DE8	| 408EEA80
    oril #2097152,%d0	| 408EEA82
rsrc_PACK_5_408EDCA0_DE8:  /* jump through %a4@ */
    jmp %a4@	| 408EEA88
rsrc_PACK_5_408EDCA0_DEA:  /* test #16511,%d0 */
    cmpiw #16511,%d0	| 408EEA8A
    jble rsrc_PACK_5_408EDCA0_E06	| 408EEA8E
    fmovex %pc@(rsrc_PACK_5_408EDCA0_1276),%fp0	| 408EEA90
    tstl %d1	| 408EEA96
    jbpl rsrc_PACK_5_408EDCA0_DFE	| 408EEA98
    fnegx %fp0,%fp0	| 408EEA9A
rsrc_PACK_5_408EDCA0_DFE:  /* set %d0 */
    movel #524288,%d0	| 408EEA9E
    jmp %a4@	| 408EEAA4
rsrc_PACK_5_408EDCA0_E06:  /* from here: fabsx %fp0,%fp0 */
    fabsx %fp0,%fp0	| 408EEAA6
    fcmps #0e1,%fp0	| 408EEAAA
    fble rsrc_PACK_5_408EDCA0_E2A	| 408EEAB2
    addqb #1,%d1	| 408EEAB6
    fmoves #0e1,%fp3	| 408EEAB8
    fdivx %fp0,%fp3	| 408EEAC0
    fmovex %fp3,%fp0	| 408EEAC4
    jbra rsrc_PACK_5_408EDCA0_E2E	| 408EEAC8
rsrc_PACK_5_408EDCA0_E2A:  /* from here: fmovex %fp0,%fp3 */
    fmovex %fp0,%fp3	| 408EEACA
rsrc_PACK_5_408EDCA0_E2E:  /* from here: fcmpx %pc@(rsrc_PACK_5_408EDCA0_126A),%fp0 */
    fcmpx %pc@(rsrc_PACK_5_408EDCA0_126A),%fp0	| 408EEACE
    fbgt rsrc_PACK_5_408EDCA0_E82	| 408EEAD4
    fmulx %fp0,%fp0	| 408EEAD8
    lea %pc@(rsrc_PACK_5_408EDCA0_13EC),%a0	| 408EEADC
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EEAE0
    fmovex %fp1,%fp2	| 408EEAE4
    lea %pc@(rsrc_PACK_5_408EDCA0_13AE),%a0	| 408EEAE8
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EEAEC
    fdivx %fp1,%fp2	| 408EEAF0
    fmulx %fp3,%fp2	| 408EEAF4
    fsubx %fp2,%fp3	| 408EEAF8
    fmovex %fp3,%fp0	| 408EEAFC
rsrc_PACK_5_408EDCA0_E60:  /* loop: tst */
    tstb %d1	| 408EEB00
    jbeq rsrc_PACK_5_408EDCA0_E72	| 408EEB02
    fmovex %pc@(rsrc_PACK_5_408EDCA0_1276),%fp1	| 408EEB04
    fsubx %fp0,%fp1	| 408EEB0A
    fmovex %fp1,%fp0	| 408EEB0E
rsrc_PACK_5_408EDCA0_E72:  /* test %d1 */
    tstl %d1	| 408EEB12
    jbpl rsrc_PACK_5_408EDCA0_E7A	| 408EEB14
    fnegx %fp0,%fp0	| 408EEB16
rsrc_PACK_5_408EDCA0_E7A:  /* set %d0 */
    movel #524288,%d0	| 408EEB1A
    jmp %a4@	| 408EEB20
rsrc_PACK_5_408EDCA0_E82:  /* from here: fmovemx %fp4-%fp5,%sp@- */
    fmovemx %fp4-%fp5,%sp@-	| 408EEB22
    fmulx %pc@(rsrc_PACK_5_408EDCA0_1252),%fp3	| 408EEB26
    fmoves #0e1,%fp2	| 408EEB2C
    fdivx %fp3,%fp2	| 408EEB34
    fadds #0e1,%fp3	| 408EEB38
    fadds #0e1,%fp2	| 408EEB40
    fmovex %fp0,%fp1	| 408EEB48
    fsubx %pc@(rsrc_PACK_5_408EDCA0_1252),%fp1	| 408EEB4C
    fmovex %fp1,%fp4	| 408EEB52
    fdivx %fp3,%fp1	| 408EEB56
    fdivx %fp2,%fp4	| 408EEB5A
    fmovex %fp1,%fp3	| 408EEB5E
    fmulx %fp1,%fp1	| 408EEB62
    fmovex %fp0,%fp2	| 408EEB66
    fmovex %fp1,%fp0	| 408EEB6A
    lea %pc@(rsrc_PACK_5_408EDCA0_13EC),%a0	| 408EEB6E
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EEB72
    fmovex %fp1,%fp5	| 408EEB76
    lea %pc@(rsrc_PACK_5_408EDCA0_13AE),%a0	| 408EEB7A
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EEB7E
    fdivx %fp1,%fp5	| 408EEB82
    fmulx %fp3,%fp5	| 408EEB86
    faddx %pc@(rsrc_PACK_5_408EDCA0_125E),%fp5	| 408EEB8A
    faddx %fp4,%fp5	| 408EEB90
    fsubx %fp2,%fp5	| 408EEB94
    fmovex %fp5,%fp0	| 408EEB98
    fnegx %fp0,%fp0	| 408EEB9C
    fmovemx %sp@+,%fp4-%fp5	| 408EEBA0
    jbra rsrc_PACK_5_408EDCA0_E60	| 408EEBA4
rsrc_PACK_5_408EDCA0_F08:  /* from here: jbmi rsrc_PACK_5_408EDCA0_F1E */
    jbmi rsrc_PACK_5_408EDCA0_F1E	| 408EEBA8
    btst #29,%d0	| 408EEBAA
    jbne rsrc_PACK_5_408EDCA0_F1E	| 408EEBAE
    fmovex %pc@(rsrc_PACK_5_408EDCA0_1276),%fp0	| 408EEBB0
    tstw %a0@	| 408EEBB6
    jbpl rsrc_PACK_5_408EDCA0_F1E	| 408EEBB8
    fnegx %fp0,%fp0	| 408EEBBA
rsrc_PACK_5_408EDCA0_F1E:  /* result 0 */
    moveq #0,%d0	| 408EEBBE
    jmp %a4@	| 408EEBC0

/* subroutine (39 instructions): calls rsrc_PACK_5_408EDCA0_1044, rsrc_PACK_5_408EDCA0_10C8 (mechanical summary) */
rsrc_PACK_5_408EDCA0_F22:
    fmovel %fpsr,%d0	| 408EEBC2
    moveq #0,%d1	| 408EEBC6
    andil #251658240,%d0	| 408EEBC8
    lsll #5,%d0	| 408EEBCE
    jbne rsrc_PACK_5_408EDCA0_F8E	| 408EEBD0
    jbcc rsrc_PACK_5_408EDCA0_F38	| 408EEBD2
    bset #31,%d1	| 408EEBD4
rsrc_PACK_5_408EDCA0_F38:  /* from here: bfextu %a0@,1,15,%d0 */
    bfextu %a0@,1,15,%d0	| 408EEBD8
    cmpiw #16351,%d0	| 408EEBDC
    jbge rsrc_PACK_5_408EDCA0_F56	| 408EEBE0
    movel #524288,%d0	| 408EEBE2
    bftst %a0@,1,16	| 408EEBE8
    jbne rsrc_PACK_5_408EDCA0_F54	| 408EEBEC
    oril #2097152,%d0	| 408EEBEE
rsrc_PACK_5_408EDCA0_F54:  /* jump through %a4@ */
    jmp %a4@	| 408EEBF4
rsrc_PACK_5_408EDCA0_F56:  /* from here: fremx %pc@(rsrc_PACK_5_408EDCA0_1276),%fp0 */
    fremx %pc@(rsrc_PACK_5_408EDCA0_1276),%fp0	| 408EEBF6
    fmovel %fpsr,%d0	| 408EEBFC
    swap %d0	| 408EEC00
    moveb %d0,%d1	| 408EEC02
    lsrb #1,%d0	| 408EEC04
    jbcc rsrc_PACK_5_408EDCA0_F76	| 408EEC06
    jbsr rsrc_PACK_5_408EDCA0_1044	| 408EEC08
    tstl %d1	| 408EEC0C
    jbpl rsrc_PACK_5_408EDCA0_F7A	| 408EEC0E
    fnegx %fp0,%fp0	| 408EEC10
    jbra rsrc_PACK_5_408EDCA0_F7A	| 408EEC14
rsrc_PACK_5_408EDCA0_F76:  /* call rsrc_PACK_5_408EDCA0_10C8 */
    jbsr rsrc_PACK_5_408EDCA0_10C8	| 408EEC16
rsrc_PACK_5_408EDCA0_F7A:  /* from here: andib #3,%d1 */
    andib #3,%d1	| 408EEC1A
    subqb #2,%d1	| 408EEC1E
    jbmi rsrc_PACK_5_408EDCA0_F86	| 408EEC20
    fnegx %fp0,%fp0	| 408EEC22
rsrc_PACK_5_408EDCA0_F86:  /* set %d0 */
    movel #524288,%d0	| 408EEC26
    jmp %a4@	| 408EEC2C
rsrc_PACK_5_408EDCA0_F8E:  /* from here: jbmi rsrc_PACK_5_408EDCA0_FAE */
    jbmi rsrc_PACK_5_408EDCA0_FAE	| 408EEC2E
    btst #29,%d0	| 408EEC30
    jbne rsrc_PACK_5_408EDCA0_FAE	| 408EEC34
    .short  0xF23C, 0x4800, 0x7FFF, 0x0000, 0x4021, 0x0000, 0x0000, 0x0000	| 408EEC36 fmovex #0enan,%fp0
    .byte   0x20, 0x3C	| 408EEC46
    oril #20180,%d0	| 408EEC48
rsrc_PACK_5_408EDCA0_FAE:  /* result 0 */
    moveq #0,%d0	| 408EEC4E
    jmp %a4@	| 408EEC50

/* subroutine (39 instructions): calls rsrc_PACK_5_408EDCA0_1044, rsrc_PACK_5_408EDCA0_10C8 (mechanical summary) */
rsrc_PACK_5_408EDCA0_FB2:
    fmovel %fpsr,%d0	| 408EEC52
    moveq #0,%d1	| 408EEC56
    andil #251658240,%d0	| 408EEC58
    lsll #5,%d0	| 408EEC5E
    jbne rsrc_PACK_5_408EDCA0_101A	| 408EEC60
    jbcc rsrc_PACK_5_408EDCA0_FC8	| 408EEC62
    bset #31,%d1	| 408EEC64
rsrc_PACK_5_408EDCA0_FC8:  /* from here: bfextu %a0@,1,15,%d0 */
    bfextu %a0@,1,15,%d0	| 408EEC68
    cmpiw #16351,%d0	| 408EEC6C
    jbge rsrc_PACK_5_408EDCA0_FE0	| 408EEC70
    fmovew #1,%fp0	| 408EEC72
    movel #524288,%d0	| 408EEC78
    jmp %a4@	| 408EEC7E
rsrc_PACK_5_408EDCA0_FE0:  /* from here: fremx %pc@(rsrc_PACK_5_408EDCA0_1276),%fp0 */
    fremx %pc@(rsrc_PACK_5_408EDCA0_1276),%fp0	| 408EEC80
    fmovel %fpsr,%d0	| 408EEC86
    swap %d0	| 408EEC8A
    moveb %d0,%d1	| 408EEC8C
    lsrb #1,%d0	| 408EEC8E
    jbcs rsrc_PACK_5_408EDCA0_FF6	| 408EEC90
    jbsr rsrc_PACK_5_408EDCA0_1044	| 408EEC92
    jbra rsrc_PACK_5_408EDCA0_1002	| 408EEC94
rsrc_PACK_5_408EDCA0_FF6:  /* call rsrc_PACK_5_408EDCA0_10C8 */
    jbsr rsrc_PACK_5_408EDCA0_10C8	| 408EEC96
    tstl %d1	| 408EEC9A
    jbpl rsrc_PACK_5_408EDCA0_1002	| 408EEC9C
    fnegx %fp0,%fp0	| 408EEC9E
rsrc_PACK_5_408EDCA0_1002:  /* from here: andib #3,%d1 */
    andib #3,%d1	| 408EECA2
    jbeq rsrc_PACK_5_408EDCA0_1012	| 408EECA6
    cmpib #3,%d1	| 408EECA8
    jbeq rsrc_PACK_5_408EDCA0_1012	| 408EECAC
    fnegx %fp0,%fp0	| 408EECAE
rsrc_PACK_5_408EDCA0_1012:  /* set %d0 */
    movel #524288,%d0	| 408EECB2
    jmp %a4@	| 408EECB8
rsrc_PACK_5_408EDCA0_101A:  /* from here: jbmi rsrc_PACK_5_408EDCA0_103A */
    jbmi rsrc_PACK_5_408EDCA0_103A	| 408EECBA
    btst #29,%d0	| 408EECBC
    jbne rsrc_PACK_5_408EDCA0_1040	| 408EECC0
    .short  0xF23C, 0x4800, 0x7FFF, 0x0000, 0x4021, 0x0000, 0x0000, 0x0000	| 408EECC2 fmovex #0enan,%fp0
    .byte   0x20, 0x3C	| 408EECD2
    oril #20180,%d0	| 408EECD4
rsrc_PACK_5_408EDCA0_103A:  /* from here: fmovew #1,%fp0 */
    fmovew #1,%fp0	| 408EECDA
rsrc_PACK_5_408EDCA0_1040:  /* result 0 */
    moveq #0,%d0	| 408EECE0
    jmp %a4@	| 408EECE2

/* subroutine (28 instructions): calls rsrc_PACK_5_408EDCA0_A74 (mechanical summary) */
rsrc_PACK_5_408EDCA0_1044:
    fmovex %fp0,%fp3	| 408EECE4
    fmulx %fp0,%fp0	| 408EECE8
    lea %pc@(rsrc_PACK_5_408EDCA0_1318),%a0	| 408EECEC
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EECF0
    fmovex %fp1,%fp2	| 408EECF4
    lea %pc@(rsrc_PACK_5_408EDCA0_12E6),%a0	| 408EECF8
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EECFC
    fdivx %fp1,%fp2	| 408EED00
    fmulx %fp0,%fp2	| 408EED04
    fmulx %fp0,%fp2	| 408EED08
    fcmps #0e0.25,%fp0	| 408EED0C
    fblt rsrc_PACK_5_408EDCA0_10AE	| 408EED14
    fabsx %fp3,%fp3	| 408EED18
    fsubs #0e0.5,%fp3	| 408EED1C
    fmovex %fp3,%fp1	| 408EED24
    fmuls #0e0.5,%fp1	| 408EED28
    fmulx %fp1,%fp3	| 408EED30
    fsubx %fp2,%fp3	| 408EED34
    faddx %fp1,%fp3	| 408EED38
    fnegx %fp3,%fp3	| 408EED3C
    fadds #0e0.875,%fp3	| 408EED40
    fmovex %fp3,%fp0	| 408EED48
    rts	| 408EED4C
rsrc_PACK_5_408EDCA0_10AE:  /* from here: fmuls #0e0.5,%fp0 */
    fmuls #0e0.5,%fp0	| 408EED4E
    fsubx %fp0,%fp2	| 408EED56
    fadds #0e1,%fp2	| 408EED5A
    fmovex %fp2,%fp0	| 408EED62
    rts	| 408EED66

/* subroutine (13 instructions): calls rsrc_PACK_5_408EDCA0_A74 (mechanical summary) */
rsrc_PACK_5_408EDCA0_10C8:
    fmovex %fp0,%fp3	| 408EED68
    fmulx %fp0,%fp0	| 408EED6C
    lea %pc@(rsrc_PACK_5_408EDCA0_12B4),%a0	| 408EED70
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EED74
    fmovex %fp1,%fp2	| 408EED78
    lea %pc@(rsrc_PACK_5_408EDCA0_1282),%a0	| 408EED7C
    jbsr rsrc_PACK_5_408EDCA0_A74	| 408EED80
    fdivx %fp1,%fp2	| 408EED84
    fmulx %fp3,%fp0	| 408EED88
    fmulx %fp0,%fp2	| 408EED8C
    fsubx %fp2,%fp3	| 408EED90
    fmovex %fp3,%fp0	| 408EED94
    rts	| 408EED98
rsrc_PACK_5_408EDCA0_10FA:  /* (data) */
    .byte   0x00, 0x04, 0x3F, 0xF6, 0x00, 0x00, 0xB9, 0x46, 0x46, 0xAF, 0xF6, 0xCE, 0x3B, 0xFF, 0x3F, 0xF9	| 408EED9A
    .byte   0x00, 0x00, 0x94, 0xF4, 0x32, 0x21, 0x4D, 0x61, 0xFB, 0xEB, 0x3F, 0xFB, 0x00, 0x00, 0xDC, 0x97	| 408EEDAA
    .byte   0x89, 0x03, 0xD9, 0x44, 0x78, 0x93, 0x3F, 0xFF, 0x00, 0x00, 0x9F, 0x9E, 0x39, 0x46, 0x57, 0xCA	| 408EEDBA
    .byte   0x1D, 0x05, 0xC0, 0x01, 0x00, 0x00, 0xCD, 0x6B, 0xC5, 0x3A, 0x46, 0xEC, 0xDC, 0x9A, 0x40, 0x01	| 408EEDCA
    .byte   0x00, 0x00, 0xB4, 0x83, 0x97, 0xE7, 0xBA, 0xE6, 0xFC, 0xE0	| 408EEDDA
rsrc_PACK_5_408EDCA0_1144:  /* (data) */
    .byte   0x00, 0x01, 0x3F, 0xFF	| 408EEDE4
    .long   0x00008000 /* number, not an address (F1) */	| 408EEDE8
    .long   0x00000000	| 408EEDEC
    .long   0x0000C000 /* number, not an address (F1) */	| 408EEDF0
    .long   0x0000B818 /* number, not an address (F1) */	| 408EEDF4
    .long   0x35C3CE0A, 0x5E1D3FFF	| 408EEDF8
    .short  0x0000, 0xFA3E, 0xDF0E, 0xDDF4, 0x1A96	| 408EEE00
rsrc_PACK_5_408EDCA0_116A:  /* (data) */
    .short  0x0002, 0xBFEE, 0x0000	| 408EEE0A
    .long   0xFF8890C8, 0x1B209B79, 0x3FF90000, 0xDA5C84EF	| 408EEE10
    .long   0xB813272F, 0x40030000, 0x97D3BAEA, 0xF80FFD45	| 408EEE20
    .long   0x40090000, 0xAB8671A1, 0x95BEFF0C	| 408EEE30
rsrc_PACK_5_408EDCA0_119C:  /* (data) */
    .long   0x00013FFF	| 408EEE3C
    .long   0x00008000, 0x00000000, 0x00004006, 0x0000D548	| 408EEE40
    .long   0x7002984B, 0x5AB4400A, 0x0000F775, 0x612E96B7	| 408EEE50
    .long   0x0780400D, 0x0000FFFE, 0x00000000, 0x00007FFF	| 408EEE60
    .long   0x00000000, 0x00000000, 0x0000FFFF, 0x00000000	| 408EEE70
    .long   0x00000000, 0x00003FFD, 0x00008000, 0x00000000	| 408EEE80
    .long   0x00003FFE /* number, not an address (F1) */	| 408EEE90
    .long   0x00008000 /* number, not an address (F1) */	| 408EEE94
    .long   0x00000000	| 408EEE98
    .long   0x00003FFE /* number, not an address (F1) */	| 408EEE9C
    .long   0x0000C000 /* number, not an address (F1) */	| 408EEEA0
    .long   0x00000000	| 408EEEA4
    .long   0x00003FFE /* number, not an address (F1) */	| 408EEEA8
    .long   0x0000E000 /* number, not an address (F1) */	| 408EEEAC
    .long   0x00000000, 0x0000400D, 0x0000834E, 0x00000000	| 408EEEB0
    .short  0x0000, 0x401D, 0x0000, 0xFFFF, 0xFFFE, 0x0000, 0x0000	| 408EEEC0
rsrc_PACK_5_408EDCA0_122E:  /* (data) */
    .short  0x3FFF	| 408EEECE
    .short  0x0000	| 408EEED0
rsrc_PACK_5_408EDCA0_1232:  /* (data) */
    .short  0xB504, 0xF333	| 408EEED2
rsrc_PACK_5_408EDCA0_1236:  /* (data) */
    .short  0xF9DE, 0x6484	| 408EEED6
rsrc_PACK_5_408EDCA0_123A:  /* (data) */
    .short  0x3FFE, 0x0000, 0xB504	| 408EEEDA
    .short  0xF333, 0xF9DE, 0x6484	| 408EEEE0
rsrc_PACK_5_408EDCA0_1246:  /* (data) */
    .short  0x3FFE, 0x0000, 0xB172, 0x17F7, 0xD1CF	| 408EEEE6
    .byte   0x79, 0xAC	| 408EEEF0
rsrc_PACK_5_408EDCA0_1252:  /* (data) */
    .byte   0x3F, 0xFE, 0x00, 0x00, 0x93, 0xCD, 0x3A, 0x2C, 0x81, 0x98, 0xE2, 0x6A	| 408EEEF2
rsrc_PACK_5_408EDCA0_125E:  /* (data) */
    .byte   0x3F, 0xFA	| 408EEEFE
    .byte   0x00, 0x00, 0xDC, 0x2A, 0x86, 0xB1, 0x5F, 0xDB, 0x64, 0x62	| 408EEF00
rsrc_PACK_5_408EDCA0_126A:  /* (data) */
    .byte   0x3F, 0xFD, 0x00, 0x00, 0x89, 0x30	| 408EEF0A
    .byte   0xA2, 0xF4, 0xF6, 0x6A, 0xB1, 0x8A	| 408EEF10
rsrc_PACK_5_408EDCA0_1276:  /* (data) */
    .byte   0x3F, 0xFF, 0x00, 0x00, 0xC9, 0x0F, 0xDA, 0xA2, 0x21, 0x68	| 408EEF16
    .byte   0xC2, 0x35	| 408EEF20
rsrc_PACK_5_408EDCA0_1282:  /* (data) */
    .byte   0x00, 0x02, 0x3F, 0xFF, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408EEF22
    .long   0x40070000, 0x88D8B844, 0xA6A85A30, 0x400E0000	| 408EEF30
    .long   0x8A158A49, 0x09792320, 0x40130000, 0xFAA9FE26	| 408EEF40
    .byte   0xFE, 0x63, 0xF2, 0x2B	| 408EEF50
rsrc_PACK_5_408EDCA0_12B4:  /* (data) */
    .byte   0x00, 0x02, 0xBF, 0xFE, 0x00, 0x00, 0xC2, 0x50, 0x86, 0xAE, 0x43, 0xF5	| 408EEF54
    .long   0xCBF54006, 0x00009E76, 0xEC66BEE7, 0x6BA2C00C	| 408EEF60
    .long   0x0000AF51, 0xA1D6C4C4, 0xAA014011, 0x0000A71B	| 408EEF70
    .byte   0xFE, 0xC4, 0xA9, 0x97, 0xF6, 0xCE	| 408EEF80
rsrc_PACK_5_408EDCA0_12E6:  /* (data) */
    .byte   0x00, 0x02, 0x3F, 0xFF, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00	| 408EEF86
    .long   0x00000000, 0x40070000, 0xA6D96A95, 0xFBDF9685	| 408EEF90
    .long   0x400E0000, 0xC7A7EA65, 0xE85D156B, 0x40140000	| 408EEFA0
    .byte   0xD2, 0x6E, 0x87, 0x1C, 0x7B, 0x17, 0x52, 0xB2	| 408EEFB0
rsrc_PACK_5_408EDCA0_1318:  /* (data) */
    .byte   0x00, 0x02, 0xBF, 0xFB, 0x00, 0x00, 0xD5, 0x7E	| 408EEFB8
    .long   0x18D7A6F6, 0xD7584003, 0x0000E364, 0x937E32B3	| 408EEFC0
    .long   0xD072C00A, 0x0000A62D, 0x4056586B, 0xC0454010	| 408EEFD0
    .byte   0x00, 0x00, 0x8C, 0x49, 0xAF, 0x68, 0x52, 0x0F, 0x8C, 0x7A	| 408EEFE0
rsrc_PACK_5_408EDCA0_134A:  /* (data) */
    .byte   0x00, 0x02, 0xBF, 0xFF, 0x00, 0x00	| 408EEFEA
    .long   0x80000000, 0x00000000, 0x40050000, 0xB5130324	| 408EEFF0
    .long   0x83C00955, 0xC0090000, 0xD1FFB242, 0x5762E0CF	| 408EF000
    .byte   0x40, 0x0A, 0x00, 0x00, 0xE1, 0x90, 0x93, 0x09, 0x93, 0x76, 0x66, 0xAB	| 408EF010
rsrc_PACK_5_408EDCA0_137C:  /* (data) */
    .byte   0x00, 0x02, 0xBF, 0xE9	| 408EF01C
    .long   0x0000B1FC, 0x3363D79B, 0x28383FFD, 0x0000AA9D	| 408EF020
    .long   0x71D83EC7, 0x4CD1C003, 0x0000E9CD, 0x8E24B965	| 408EF030
    .byte   0x7D, 0xBB, 0x40, 0x07, 0x00, 0x00, 0xF0, 0x9A, 0x36, 0x70, 0x9D, 0x4B, 0x18, 0x36	| 408EF040
rsrc_PACK_5_408EDCA0_13AE:  /* (data) */
    .byte   0x00, 0x03	| 408EF04E
    .long   0x3FFF0000, 0x98D31EAE, 0x2AFA5DAD, 0x40030000	| 408EF050
    .long   0x8F794CD8, 0xB3CDEFD9, 0x40050000, 0x8E37ED85	| 408EF060
    .long   0x70B8B368, 0x40050000, 0xCDA4BEA1, 0xAC59F3B8	| 408EF070
    .byte   0x40, 0x04, 0x00, 0x00, 0xC4, 0x05, 0x9C, 0x55, 0x4C, 0xF0, 0xC6, 0x56	| 408EF080
rsrc_PACK_5_408EDCA0_13EC:  /* (data) */
    .byte   0x00, 0x03, 0x3F, 0xFF	| 408EF08C
    .long   0x00008000, 0x00000000, 0x00004002, 0x0000A23B	| 408EF090
    .long   0x6C131F92, 0x0E304003, 0x0000C3C8, 0x593DFA3A	| 408EF0A0
    .short  0x486F, 0x4003, 0x0000, 0x82AE, 0x6838, 0xDDF5, 0xD945	| 408EF0B0
