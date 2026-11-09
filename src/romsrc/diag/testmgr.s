/*
 diag/testmgr.s - Test Manager (serial diagnostics)
 From TESTMANAGER (0x408B93D0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. These are the start-up and factory diagnostic tests (many run before RAM is usable, with return addresses in registers). Routine headers name the job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* USTSTRT1: start of the universal start-up tests (no RAM). */
trap_USTSTRT1:
USTSTRT1:
TESTMANAGER:
    cmpil #65536,%d0
    bgel SETVECTORTABLE_32
    moveml %d1-%d5/%a0-%fp,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    movec %vbr,%a2
    movel %a2,%sp@-
    subaw #256,%sp
    movel %d0,%d3
    moveal %a0,%a3
    moveal %a1,%a4
    moveal %sp,%a1
    lea %pc@(USTSTRT1_30),%fp
    jmp %pc@(SETVECTORTABLE)
USTSTRT1_30:            /* set %d0 */
    movel %d3,%d0
    moveal %a3,%a0
    moveal %a4,%a1
    lea %pc@(USTSTRT1_58),%a2
    cmpw %a2@+,%d0
    jbcc USTSTRT1_46
    addw %d0,%d0
    addaw %a2@(0x0,%d0:w),%a2
    jmp %a2@
USTSTRT1_46:            /* loop: adda */
    addaw #256,%sp
    moveal %sp@+,%a2
    movec %a2,%vbr
    movew %sp@+,%sr
    moveml %sp@+,%d1-%d5/%a0-%fp
    rts
USTSTRT1_58:            /* (data) */
    .byte   0x00, 0x0C	| 408B9428
USTSTRT1_5A:            /* (data) */
    .short  USTSTRT1_7A-(USTSTRT1_58+2)	| 408B942A
    .short  USTSTRT1_78-(USTSTRT1_58+2)	| 408B942C
    .short  USTSTRT1_72-(USTSTRT1_58+2)	| 408B942E
    .short  TMRESTART_E-(USTSTRT1_58+2)	| 408B9430
    .short  USTSTRT1_86-(USTSTRT1_58+2)	| 408B9432
    .short  USTSTRT1_F4-(USTSTRT1_58+2)	| 408B9434
    .short  USTSTRT1_100-(USTSTRT1_58+2)	| 408B9436
    .short  USTSTRT1_46-(USTSTRT1_58+2)	| 408B9438
    .short  USTSTRT1_162-(USTSTRT1_58+2)	| 408B943A
    .short  USTSTRT1_1B6-(USTSTRT1_58+2)	| 408B943C
    .short  USTSTRT1_3AE-(USTSTRT1_58+2)	| 408B943E
    .short  TMENTRY1_674-(USTSTRT1_58+2)	| 408B9440
USTSTRT1_72:            /* from here: oriw #1792,%sp@(260) */
    oriw #1792,%sp@(260)	| 408B9442
USTSTRT1_78:            /* continue at USTSTRT1_46 */
    jbra USTSTRT1_46	| 408B9448
USTSTRT1_7A:            /* clear %d6 */
    moveq #0,%d6	| 408B944A
    movel %a0@,%d7	| 408B944C
    moveal %a0@(8),%a1
    moveal %a0@(4),%a0
USTSTRT1_86:            /* set %d1 */
    movew %d7,%d1
    lsrw #8,%d1
    andil #65535,%d1
    cmpl %pc@(USTSTRT1_418),%d1
    jbge USTSTRT1_46
    moveal 0xdd8,%a2
    movel %a2,%usp
    lsll #2,%d1
    lea %pc@(USTSTRT1_3F0),%a5
    movel %a5@(0x0,%d1:l),%d1
    lea %a5@(0x0,%d1:l),%a5
USTSTRT1_AA:            /* loop: lea */
    lea %pc@(USTSTRT1_B0),%fp
    jmp %a5@
USTSTRT1_B0:            /* test %d6 */
    tstl %d6
    jbeq USTSTRT1_C0
    btst #29,%d7
    jbne USTSTRT1_EE
    btst #28,%d7
    jbne USTSTRT1_C4
USTSTRT1_C0:            /* subtract 1 to %d7 */
    subqb #1,%d7
    jbne USTSTRT1_AA
USTSTRT1_C4:            /* loop: btst */
    btst #30,%d7
    jbeq USTSTRT1_DC
    movel %usp,%a1
    moveal %a1@,%a2
    addal %a1,%a2
    moveal %a2@(8),%a2
    lea %pc@(USTSTRT1_DC),%fp
    jmp %pc@(USTSTRT1_324)
USTSTRT1_DC:            /* test bit 31 of %d7 */
    btst #31,%d7
    jbeq USTSTRT1_46
    bigjmp hdr_jmp_startboot
USTSTRT1_EE:            /* loop: lea */
    lea %pc@(USTSTRT1_EE),%fp
    jmp %a5@
USTSTRT1_F4:            /* clear %d6 */
    moveq #0,%d6	| 408B94C4
    movel %a0@,%d7	| 408B94C6
    moveal %a0@(8),%a1
    moveal %a0@(4),%a0
USTSTRT1_100:           /* loop: moveq */
    moveq #7,%d1
USTSTRT1_102:           /* set %a2 */
    moveal 0xdd8,%a2
    movel %a2,%usp
USTSTRT1_108:           /* loop: addq */
    addql #1,%d1
    cmpiw #15,%d1
    jbgt USTSTRT1_154
    btst %d1,%d7
    jbeq USTSTRT1_108
    lsll #2,%d1
    lea %pc@(USTSTRT1_3F0),%a5
    addal %a5@(0xffffffffffffffe0,%d1:l),%a5
    lea %pc@(USTSTRT1_104,%d1:l),%fp
    jmp %a5@
    moveq #8,%d1
    jbra USTSTRT1_142
    moveq #9,%d1
    jbra USTSTRT1_142
    moveq #10,%d1
    jbra USTSTRT1_142
    moveq #11,%d1
    jbra USTSTRT1_142
    moveq #12,%d1
    jbra USTSTRT1_142
    moveq #13,%d1
    jbra USTSTRT1_142
    moveq #14,%d1
    jbra USTSTRT1_142
    .short  0x720F	| 408B9510
USTSTRT1_142:           /* test %d6 */
    tstl %d6
    jbeq USTSTRT1_108
    btst #29,%d7
    jbne USTSTRT1_EE
    btst #28,%d7
    jbne USTSTRT1_C4
USTSTRT1_154:           /* subtract 1 to %d7 */
    subqb #1,%d7
    jbne USTSTRT1_100
    bclr #15,%d7
    jbne USTSTRT1_100
    jbra USTSTRT1_C4
USTSTRT1_162:           /* clear %d6 */
    moveq #0,%d6	| 408B9532
    movel %a0@,%d7	| 408B9534
USTSTRT1_166:           /* loop: move */
    movel %d7,%d1
    lsrw #8,%d1
    subiw #128,%d1
    andil #65535,%d1
    cmpl %pc@(USTSTRT1_49C),%d1
    jbge USTSTRT1_1B2
    asll #2,%d1
    lea %pc@(USTSTRT1_41C),%a5
    movel %a5@(0x0,%d1:l),%d1
    lea %a5@(0x0,%d1:l),%a5
USTSTRT1_188:           /* loop: movea */
    moveal 0xdd8,%a1
    moveal %a1,%a0
    addal %a0@,%a0
    movel 0xdd0,%d0
    movew %a1@(18),%d2
    lea %pc@(USTSTRT1_19E),%fp
    jmp %a5@
USTSTRT1_19E:           /* test %d6 */
    tstl %d6
    jbeq USTSTRT1_1AE
    btst #29,%d7
    jbne USTSTRT1_188
    btst #28,%d7
    jbne USTSTRT1_1B2
USTSTRT1_1AE:           /* subtract 1 to %d7 */
    subqb #1,%d7
    jbne USTSTRT1_166
USTSTRT1_1B2:           /* continue at USTSTRT1_46 */
    jbra USTSTRT1_46
USTSTRT1_1B6:           /* clear %d6 */
    moveq #0,%d6	| 408B9586
    movel %a0@,%d7	| 408B9588
USTSTRT1_1BA:           /* address 0xfff8d772 */
    lea 0xfff8d772,%a3	| 408B958A
    lea %pc@(USTSTRT1_1BA,%a3:l),%a3	| 408B9590
USTSTRT1_1C4:           /* address 0xfff8daee */
    lea 0xfff8daee,%a4	| 408B9594
    lea %pc@(USTSTRT1_1C4,%a4:l),%a4	| 408B959A
    cmpal %a3@(4),%a4	| 408B959E
    jbeq USTSTRT1_1DE	| 408B95A2
USTSTRT1_1D4:           /* address 0xfff8d858 */
    lea 0xfff8d858,%a3	| 408B95A4
    lea %pc@(USTSTRT1_1D4,%a3:l),%a3	| 408B95AA
USTSTRT1_1DE:           /* set %vbr */
    movec %a3,%vbr	| 408B95AE
    movec %cacr,%d0	| 408B95B2
    movel %d0,%d1	| 408B95B6
    bset #15,%d0	| 408B95B8
    movec %d0,%cacr	| 408B95BC
    movec %cacr,%d0	| 408B95C0
    btst #15,%d0	| 408B95C4
    jbne USTSTRT1_236	| 408B95C8
    bset #13,%d0	| 408B95CA
    movec %d0,%cacr	| 408B95CE
    movec %cacr,%d0	| 408B95D2
    movec %d1,%cacr	| 408B95D6
    btst #13,%d0	| 408B95DA
    jbeq USTSTRT1_228	| 408B95DE
    lea %sp@(-4),%sp	| 408B95E0
    .short  0xF017, 0x4200	| 408B95E4 pmove %tc,%sp@
    movel %sp@,%d0	| 408B95E8
    bclr #31,%d0	| 408B95EA
    movel %d0,%sp@	| 408B95EE
    .short  0xF017, 0x4000	| 408B95F0 pmove %sp@,%tc
    lea %sp@(4),%sp	| 408B95F4
USTSTRT1_228:           /* set %d0 */
    movec %cacr,%d0	| 408B95F8
    bclr #8,%d0	| 408B95FC
    movec %d0,%cacr	| 408B9600
    jbra USTSTRT1_24E	| 408B9604
USTSTRT1_236:           /* set %d0 */
    movec %tc,%d0	| 408B9606
    bclr #15,%d0	| 408B960A
    movec %d0,%tc	| 408B960E
    movec %cacr,%d0	| 408B9612
    bclr #31,%d0	| 408B9616
    movec %d0,%cacr	| 408B961A
USTSTRT1_24E:           /* address %pc@(USTSTRT1_25C) */
    lea %pc@(USTSTRT1_25C),%fp	| 408B961E
USTSTRT1_252:           /* address 0xfff9249e */
    lea 0xfff9249e,%a0	| 408B9622
    jmp %pc@(USTSTRT1_252,%a0:l)	| 408B9628
USTSTRT1_25C:           /* set %sp */
    moveal %sp@,%sp	| 408B962C
    moveal %sp,%a4	| 408B962E
    moveq #0,%d6	| 408B9630
    moveal %a4@+,%a0	| 408B9632
    moveal %a0,%a1	| 408B9634
    addal %a4@+,%a1	| 408B9636
    lea %pc@(USTSTRT1_276),%fp	| 408B9638
USTSTRT1_26C:           /* address 0xfff8e19c */
    lea 0xfff8e19c,%a2	| 408B963C
    jmp %pc@(USTSTRT1_26C,%a2:l)	| 408B9642
USTSTRT1_276:           /* (data) */
    .byte   0x4A, 0x86, 0x66, 0x00, 0x00, 0x48, 0x4D, 0xFA, 0x00, 0x0C, 0x45, 0xF9, 0xFF, 0xF8, 0xE2, 0xA0	| 408B9646
    .byte   0x4E, 0xFB, 0xA8, 0xF8, 0x4A, 0x86, 0x66, 0x00, 0x00, 0x34, 0x4D, 0xFA, 0x00, 0x0C, 0x45, 0xF9	| 408B9656
    .byte   0xFF, 0xF8, 0xE4, 0x20, 0x4E, 0xFB, 0xA8, 0xF8, 0x4A, 0x86, 0x66, 0x00, 0x00, 0x20, 0x4D, 0xFA	| 408B9666
    .byte   0x00, 0x0C, 0x41, 0xF9, 0xFF, 0xF9, 0x24, 0x48, 0x4E, 0xFB, 0x88, 0xF8, 0x2E, 0x57, 0x7C, 0x00	| 408B9676
    .byte   0x0C, 0x94, 0xFF, 0xFF, 0xFF, 0xFF, 0x66, 0xA4, 0x60, 0x00, 0x00, 0x16, 0x08, 0x07, 0x00, 0x1D	| 408B9686
    .byte   0x67, 0x06, 0x4D, 0xFA, 0xFF, 0xFE, 0x4E, 0xD5, 0x08, 0x07, 0x00, 0x1C, 0x66, 0x00, 0x00, 0x10	| 408B9696
    .byte   0x53, 0x07, 0x66, 0x00, 0xFF, 0x74, 0x08, 0x87, 0x00, 0x0F, 0x66, 0x00, 0xFF, 0x6C, 0x08, 0x07	| 408B96A6
    .byte   0x00, 0x1E, 0x67, 0x28, 0x74, 0x00, 0x4D, 0xFA, 0x00, 0x0C, 0x41, 0xF9, 0xFF, 0xF8, 0xDE, 0xA8	| 408B96B6
    .byte   0x4E, 0xFB, 0x88, 0xF8, 0x24, 0x68, 0x00, 0x08, 0x99, 0xCF, 0x24, 0x0C, 0xEB, 0x4A, 0x48, 0x47	| 408B96C6
    .byte   0x3E, 0x02, 0x48, 0x47, 0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x00, 0x14, 0x2F, 0x7C, 0x57, 0x4C	| 408B96D6
    .byte   0x53, 0x43, 0xFF, 0xFC, 0x41, 0xF9, 0xFF, 0xF4, 0x69, 0x20, 0x4E, 0xFB, 0x88, 0xF8	| 408B96E6
USTSTRT1_324:           /* set %usp */
    movel %fp,%usp
    lea %pc@(USTSTRT1_334),%fp
    bigjmp CLKWPOFF, a4
USTSTRT1_334:           /* clear %d4 */
    moveq #0,%d4
    movel #240,%d3
    roll #8,%d7
    moveb %d7,%d2
    moveb %d3,%d1
    lea %pc@(USTSTRT1_34A),%fp
    jmp %pc@(TM_WAIT)
USTSTRT1_34A:           /* (data) */
    lea %pc@(USTSTRT1_352),%fp	| 408B971A
    jmp %pc@(TM_WAIT)	| 408B971E
USTSTRT1_352:           /* (data) */
    .byte   0x4D, 0xFA, 0x00, 0x0C, 0x49, 0xF9, 0xFF, 0xF9, 0x19, 0x86, 0x4E, 0xFB, 0xC8, 0xF8, 0x52, 0x43	| 408B9722
    .byte   0x0C, 0x43, 0x00, 0xF4, 0x6D, 0xD4, 0xE1, 0x9E, 0x14, 0x06, 0x12, 0x03, 0x4D, 0xFA, 0x00, 0x0C	| 408B9732
    .byte   0x49, 0xF9, 0xFF, 0xF9, 0x19, 0x6A, 0x4E, 0xFB, 0xC8, 0xF8, 0x52, 0x43, 0x0C, 0x43, 0x00, 0xF8	| 408B9742
    .byte   0x6D, 0xE4, 0x2A, 0x3C, 0x54, 0x48, 0x00, 0x00, 0x3A, 0x04, 0x28, 0x05, 0xE1, 0x9C, 0x14, 0x04	| 408B9752
    .byte   0x12, 0x03, 0x4D, 0xFA, 0x00, 0x0C, 0x49, 0xF9, 0xFF, 0xF9, 0x19, 0x44, 0x4E, 0xFB, 0xC8, 0xF8	| 408B9762
    .byte   0x52, 0x43, 0x0C, 0x43, 0x00, 0xFC, 0x6D, 0xE4, 0x4E, 0x68, 0x4E, 0xD0	| 408B9772
USTSTRT1_3AE:           /* set %d1 */
    movew %a0@,%d1	| 408B977E
    extl %d1	| 408B9780
USTSTRT1_3B2:           /* address 0xfff8c944 */
    lea 0xfff8c944,%a1	| 408B9782
    lea %pc@(USTSTRT1_3B2,%a1:l),%a1	| 408B9788
    movew #24,%d2	| 408B978C
    tstw %a0@(2)	| 408B9790
    jbeq USTSTRT1_3D4	| 408B9794
USTSTRT1_3C6:           /* address 0xfff8c8aa */
    lea 0xfff8c8aa,%a1	| 408B9796
    lea %pc@(USTSTRT1_3C6,%a1:l),%a1	| 408B979C
    movew #24,%d2	| 408B97A0
USTSTRT1_3D4:           /* set %d6 */
    movel %a1,%d6	| 408B97A4
USTSTRT1_3D6:           /* loop: cmp */
    cmpl %a1@,%d1	| 408B97A6
    jbeq USTSTRT1_3E8	| 408B97A8
    addaw %d2,%a1	| 408B97AA
    cmpil #-1,%a1@	| 408B97AC
    jbne USTSTRT1_3D6	| 408B97B2
    moveq #0,%d6
    jbra USTSTRT1_3EC
USTSTRT1_3E8:           /* from here: addl %a1@(8),%d6 */
    addl %a1@(8),%d6	| 408B97B8
USTSTRT1_3EC:           /* continue at USTSTRT1_46 */
    jbra USTSTRT1_46
USTSTRT1_3F0:           /* start-up test table: offsets from here, indexed by the test number (count below) */
    .long   caseD_0-USTSTRT1_3F0	| 408B97C0
    .long   DATABUSTEST-USTSTRT1_3F0	| 408B97C4
    .long   MOD3TEST-USTSTRT1_3F0	| 408B97C8
    .long   ADDRLINETEST-USTSTRT1_3F0	| 408B97CC
    .long   ROMTEST-USTSTRT1_3F0	| 408B97D0
    .long   REVMOD3TEST-USTSTRT1_3F0	| 408B97D4
    .long   EXTRAMTEST-USTSTRT1_3F0	| 408B97D8
    .long   MOVINVTEST-USTSTRT1_3F0	| 408B97DC
    .long   TM_WAIT_56-USTSTRT1_3F0	| 408B97E0
    .long   NOTEST-USTSTRT1_3F0	| 408B97E4
USTSTRT1_418:           /* number of entries in the table above */
    .long   0x0000000A	| 408B97E8
USTSTRT1_41C:           /* test routine table: offsets from here, one per test */
    .long   MAPRAMDATATEST-USTSTRT1_41C	| 408B97EC
    .long   MAPRAMDATATEST-USTSTRT1_41C	| 408B97F0
    .long   MAPRAMDATATEST-USTSTRT1_41C	| 408B97F4
    .long   MAPRAMDATATEST-USTSTRT1_41C	| 408B97F8
    .long   SCCREGTEST-USTSTRT1_41C	| 408B97FC
    .long   SCCLOOPTEST-USTSTRT1_41C	| 408B9800
    .long   SCCTIMERTEST-USTSTRT1_41C	| 408B9804
    .long   VIATEST-USTSTRT1_41C	| 408B9808
    .long   TESTSCSI-USTSTRT1_41C	| 408B980C
    .long   TESTASC-USTSTRT1_41C	| 408B9810
    .long   PRAMTEST-USTSTRT1_41C	| 408B9814
    .long   TESTRBV-USTSTRT1_41C	| 408B9818
    .long   TESTSWIM-USTSTRT1_41C	| 408B981C
    .long   FLOAT_TEST-USTSTRT1_41C	| 408B9820
    .long   TESTPGC-USTSTRT1_41C	| 408B9824
    .long   FMCREGTEST-USTSTRT1_41C	| 408B9828
    .long   FMCCACHETEST-USTSTRT1_41C	| 408B982C
    .long   OSSREGTEST-USTSTRT1_41C	| 408B9830
    .long   OSSINTTEST-USTSTRT1_41C	| 408B9834
    .long   RPUTEST-USTSTRT1_41C	| 408B9838
    .long   EGRETTEST-USTSTRT1_41C	| 408B983C
    .long   TESTSNDINTS-USTSTRT1_41C	| 408B9840
    .long   TESTCLUT-USTSTRT1_41C	| 408B9844
    .long   TESTVRAM-USTSTRT1_41C	| 408B9848
    .long   USTSTRT1_4A0-USTSTRT1_41C	| 408B984C
    .long   USTSTRT1_4A0-USTSTRT1_41C	| 408B9850
    .long   TESTC96-USTSTRT1_41C	| 408B9854
    .long   SONIC_BitMarch-USTSTRT1_41C	| 408B9858
    .long   SONIC_CAMDMA-USTSTRT1_41C	| 408B985C
    .long   SONIC_Loopback-USTSTRT1_41C	| 408B9860
    .long   TESTGSCREGS-USTSTRT1_41C	| 408B9864
    .long   PGESELFTEST-USTSTRT1_41C	| 408B9868
USTSTRT1_49C:           /* (end of the test table: 0x20) */
    .long   0x00000020	| 408B986C
USTSTRT1_4A0:           /* (data) */
    .long   0x7CFF4ED6	| 408B9870

/* TMRESTART: restart the test manager (after a failed test: sad Mac loop). */
TMRESTART:
    lea %sp@(-256),%sp
    moveal %sp,%a1
    lea %pc@(TMRESTART_E),%fp
    jmp %pc@(SETVECTORTABLE)
TMRESTART_E:            /* (data) */
    moveq #0,%d6	| 408B9882
    moveq #0,%d7	| 408B9884

/* TMENTRY1: test manager entry. */
TMENTRY1:
    moveq #0,%d2
    lea %pc@(TMENTRY1_10),%fp
    bigjmp hardware_table_lookup_40847568
TMENTRY1_10:            /* set %a2 */
    moveal %a0@(8),%a2
    btst #24,%d2
    jbeq TMENTRY1_28
    lea %pc@(TMENTRY1_28),%fp
    bigjmp USTPMGRTURNON, a2
TMENTRY1_28:            /* test bit 26 of %d7 */
    btst #26,%d7
    jbne TMENTRY1_5A
    moveq #0,%d2
    lea %pc@(TMENTRY1_3E),%fp
    bigjmp hardware_table_lookup_40847568
TMENTRY1_3E:            /* test bit 12 of %d0 */
    btst #12,%d0
    jbeq TMENTRY1_5A
    moveal %a0@(48),%a3
    moveal %a0@(8),%a5
    lea %pc@(TMENTRY1_5A),%fp
    bigjmp ERRORBEEP4
TMENTRY1_5A:            /* clear %d5 */
    moveq #0,%d5
    lea %pc@(TMENTRY1_64),%fp
    jmp %pc@(SETUPBASES)
TMENTRY1_64:            /* address %pc@(TMENTRY1_6C) */
    lea %pc@(TMENTRY1_6C),%fp
    jmp %pc@(SETUPBASES_32)
TMENTRY1_6C:            /* loop: lea */
    lea %pc@(TMENTRY1_74),%fp
    jmp %pc@(GETCHAR)
TMENTRY1_74:            /* (data) */
    tstw %d0	| 408B98FA
    jbmi TMENTRY1_192	| 408B98FC
    andib #127,%d0	| 408B9900
    cmpib #42,%d0	| 408B9904
    jbne TMENTRY1_8C	| 408B9908
    bset #19,%d7	| 408B990A
    jbra TMENTRY1_192	| 408B990E
TMENTRY1_8C:            /* test bit 19 of %d7 */
    btst #19,%d7	| 408B9912
    jbne TMENTRY1_C0	| 408B9916
    cmpib #33,%d0	| 408B9918
    jbne TMENTRY1_18A	| 408B991C
    jbsr UTECMD	| 408B9920
    movel %d0,%sp@-	| 408B9924
    lea %pc@(TMENTRY1_A8),%fp	| 408B9926
    jmp %pc@(SETUPBASES)	| 408B992A
TMENTRY1_A8:            /* (data) */
    .byte   0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x06, 0x02, 0x20, 0x1F, 0x4A, 0x80, 0x66, 0x00, 0x00, 0xB8	| 408B992E
    .byte   0x10, 0x3C, 0x00, 0x21, 0x60, 0x00, 0x00, 0xB0	| 408B993E
TMENTRY1_C0:            /* clear bit 19 of %d7 */
    bclr #19,%d7	| 408B9946
    moveq #0,%d1
    moveq #0,%d2
    lea %pc@(TMENTRY1_F4),%a5
TMENTRY1_CC:            /* loop: move */
    movew %a5@+,%d2
    jbeq TMENTRY1_18A
    cmpb %d2,%d0
    jbeq TMENTRY1_DA
    addql #2,%a5
    jbra TMENTRY1_CC
TMENTRY1_DA:            /* set %d5 */
    movel %a5,%d5
    lsrw #8,%d2
    lea %pc@(TMENTRY1_E6),%fp
    jmp %pc@(CVTASCII_1E)
TMENTRY1_E6:            /* set %a5 */
    moveal %d5,%a5
    moveb %a5@(-1),%d5
    swap %d5
    movew %a5@,%d0
    jmp %a5@(0x0,%d0:w)
TMENTRY1_F4:            /* (data) */
    .short  0x0053, 0x0142, 0x044C	| 408B997A
    .long   0x014E0242, 0x016A0044, 0x01840043, 0x01A40447	| 408B9980
    .long   0x01C60430, 0x01DC0431, 0x01F20432, 0x02080033	| 408B9990
    .long   0x02100034, 0x02540035, 0x02580036, 0x02700037	| 408B99A0
    .long   0x02720041, 0x02760048, 0x027A0052, 0x027E004D	| 408B99B0
    .long   0x029A0045, 0x02B80049, 0x02BC0250, 0x02C20454	| 408B99C0
    .long   0x02CA044E, 0x03AC0056, 0x04B0005A, 0x05140000	| 408B99D0
    .short  0x0000	| 408B99E0
TMENTRY1_15C:           /* loop: move */
    moveb #42,%d0
    lea %pc@(TMENTRY1_168),%fp
    jmp %pc@(OUTCHAR)
TMENTRY1_168:           /* from here: swap %d5 */
    swap %d5
    moveb %d5,%d0
    swap %d5
    lea %pc@(TMENTRY1_176),%fp
    jmp %pc@(OUTCHAR)
TMENTRY1_176:           /* set bit 23 of %d7 */
    bset #23,%d7
    moveq #0,%d2
    lea %pc@(TMENTRY1_184),%fp
    jmp %pc@(CVTASCII_68)
TMENTRY1_184:           /* (data) */
    bclr #23,%d7	| 408B9A0A
    jbra TMENTRY1_192	| 408B9A0E
TMENTRY1_18A:           /* loop: lea */
    lea %pc@(TMENTRY1_192),%fp
    jmp %pc@(OUTCHAR)
TMENTRY1_192:           /* (data) */
    btst #16,%d7	| 408B9A18
    jbeq TMENTRY1_234	| 408B9A1C
    btst #22,%d7
    jbeq TMENTRY1_1C6
    btst #5,%a2@(6656)
    jbeq TMENTRY1_234
    moveb #32,%a2@(7168)
    moveb #0xff,%a2@(4096)
    moveb #0xff,%a2@(4608)
    subqw #1,%d4
    bplw TMENTRY1_234
    movew #12,%d4
TMENTRY1_1C6:           /* address %pc@(STR_APPLE) */
    lea %pc@(STR_APPLE),%a1
    lea %pc@(TMENTRY1_1D2),%fp
    jmp %pc@(OUTCHAR_1C)
TMENTRY1_1D2:           /* clear bit 23 of %d7 */
    bclr #23,%d7
    bset #20,%d7
    movel %d6,%d0
    moveq #4,%d2
    lea %pc@(TMENTRY1_1E6),%fp
    jmp %pc@(CVTASCII_68)
TMENTRY1_1E6:           /* set %d0 */
    movew %d7,%d0
    moveq #2,%d2
    lea %pc@(TMENTRY1_1F2),%fp
    jmp %pc@(CVTASCII_68)
TMENTRY1_1F2:           /* clear bit 20 of %d7 */
    bclr #20,%d7
    moveb #42,%d0
    lea %pc@(TMENTRY1_202),%fp
    jmp %pc@(OUTCHAR)
TMENTRY1_202:           /* (data) */
    lea %pc@(TMENTRY1_20A),%fp	| 408B9A88
    jmp %pc@(SETUPBASES)	| 408B9A8C
TMENTRY1_20A:           /* (data) */
    .byte   0x43, 0xFA, 0x05, 0x47, 0xE0, 0x4A, 0x48, 0x82, 0x10, 0x31, 0x20, 0x00, 0x4D, 0xFA, 0x00, 0x06	| 408B9A90
    .byte   0x4E, 0xFA, 0x04, 0xF6, 0x43, 0xFA, 0x05, 0x64, 0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x05, 0x06	| 408B9AA0
    .byte   0x08, 0x07, 0x00, 0x16, 0x66, 0x04, 0x08, 0x87, 0x00, 0x10	| 408B9AB0
TMENTRY1_234:           /* continue at TMENTRY1_6C */
    jbra TMENTRY1_6C
    bclr #16,%d7
    bclr #22,%d7
    lea %pc@(TMENTRY1_15C),%fp
    jmp %pc@(CVTASCII_68)
    moveal %d1,%a4
    swap %d4
    clrw %d4
    swap %d4
    btst #21,%d7
    beqw TMENTRY1_15C
    bclr #23,%d7
    movel %d1,%d0
    moveq #4,%d2
    lea %pc@(TMENTRY1_15C),%fp
    jmp %pc@(CVTASCII_68)
    swap %d4
    movew %d1,%d4
    swap %d4
    btst #21,%d7
    beqw TMENTRY1_15C
    bclr #23,%d7
    movew %d1,%d0
    moveq #2,%d2
    lea %pc@(TMENTRY1_15C),%fp
    jmp %pc@(CVTASCII_68)
    moveq #0,%d6
    swap %d4
    subqw #1,%d4
    blts TMENTRY1_234_70
TMENTRY1_234_5A:
    moveq #1,%d2
    lea %pc@(TMENTRY1_234_64),%fp
    jmp %pc@(CVTASCII_1E)
TMENTRY1_234_64:
    moveb %d1,%a4@+
    moveq #0,%d0
    moveb %d1,%d0
    addl %d0,%d6
    dbf %d4,TMENTRY1_234_5A
TMENTRY1_234_70:
    swap %d4
    braw TMENTRY1_15C
    moveq #0,%d6
    swap %d4
    subqw #1,%d4
    blts TMENTRY1_234_8A
TMENTRY1_234_7E:
    moveb %a4@+,%d1
    moveq #0,%d0
    moveb %d1,%d0
    addl %d0,%d6
    dbf %d4,TMENTRY1_234_7E
TMENTRY1_234_8A:
    swap %d4
    bclr #23,%d7
    movel %d6,%d0
    moveq #4,%d2
    lea %pc@(TMENTRY1_15C),%fp
    jmp %pc@(CVTASCII_68)
    moveal %d1,%a2
    lea %pc@(TMENTRY1_234_A4),%fp
    jmp %a2@
TMENTRY1_234_A4:
    lea %pc@(TMENTRY1_234_AC),%fp
    jmp %pc@(SETUPBASES)
TMENTRY1_234_AC:
    movel #4653056,%d5
    braw TMENTRY1_15C
    moveal %d1,%a0
    btst #21,%d7
    beqw TMENTRY1_15C
    bclr #23,%d7
    movel %d1,%d0
    moveq #4,%d2
    lea %pc@(TMENTRY1_15C),%fp
    jmp %pc@(CVTASCII_68)
    moveal %d1,%a1
    btst #21,%d7
    beqw TMENTRY1_15C
    bclr #23,%d7
    movel %d1,%d0
    moveq #4,%d2
    lea %pc@(TMENTRY1_15C),%fp
    jmp %pc@(CVTASCII_68)
    movec %d1,%cacr
    braw TMENTRY1_15C
TMENTRY1_234_AC_46:
    .byte   0x00, 0x00, 0x00, 0x00	| 408B9BAC
    movec %cacr,%d0
    movel %d0,%d1
    bset #31,%d0
    movec %d0,%cacr
    movec %cacr,%d0
    btst #31,%d0
    bnes TMENTRY1_234_12A
    bset #13,%d0
    movec %d0,%cacr
    movec %cacr,%d0
    btst #13,%d0
    beqs TMENTRY1_234_13A
    lea %pc@(TMENTRY1_234_AC_46),%a0	| 408B9BDA
    .short  0xF010, 0x4000	| 408B9BDE pmove %a0@,%tc
    bras TMENTRY1_234_136
TMENTRY1_234_12A:
    movec %tc,%d0
    bclr #15,%d0
    movec %d0,%tc
TMENTRY1_234_136:
    movec %d1,%cacr
TMENTRY1_234_13A:
    braw TMENTRY1_15C
    clrw %d7
    moveq #0,%d6
    braw TMENTRY1_15C
    bset #22,%d7
    bset #16,%d7
    movew #12,%d4
    lea %pc@(TMENTRY1_234_15A),%fp
    jmp %pc@(STARTTIMER)
TMENTRY1_234_15A:
    lea %pc@(TMENTRY1_15C),%fp
    jmp %pc@(SETUPBASES)
    .short  0x4E70	| 408B9C1C
    braw TMENTRY1_15C
    bset #18,%d7
    braw TMENTRY1_15C
    bset #20,%d7
    braw TMENTRY1_15C
    bclr #20,%d7
    braw TMENTRY1_15C
    bclr #23,%d7
    movel %d6,%d0
    moveq #4,%d2
    lea %pc@(TMENTRY1_234_190),%fp
    jmp %pc@(CVTASCII_68)
TMENTRY1_234_190:
    bclr #23,%d7
    movew %d7,%d0
    moveq #2,%d2
    lea %pc@(TMENTRY1_15C),%fp
    jmp %pc@(CVTASCII_68)
    swap %d4
    subqw #1,%d4
    bges TMENTRY1_234_1A8
    clrw %d4
TMENTRY1_234_1A8:
    bset #23,%d7
TMENTRY1_234_1AC:
    movel %a4@+,%d0
    moveq #4,%d2
    lea %pc@(TMENTRY1_234_1B8),%fp
    jmp %pc@(CVTASCII_68)
TMENTRY1_234_1B8:
    dbf %d4,TMENTRY1_234_1AC
    swap %d4
    braw TMENTRY1_15C
    bset #21,%d7
    braw TMENTRY1_15C
TMENTRY1_234_1CA:
    lea 0xfff46386,%a0	| 408B9C84
    jmp %pc@(TMENTRY1_234_1CA,%a0:l)
    lea %pc@(STR_ERROR),%a1
    lea %pc@(TMENTRY1_15C),%fp
    jmp %pc@(OUTCHAR_1C)
TMENTRY1_234_1E0:
    .short  0x4BF9, 0xFFF8, 0xD062	| lea fff8d062 <__bss_start+0xbf68d062>,%a5
    lea %pc@(TMENTRY1_234_1E0,%a5:l),%a5
TMENTRY1_234_1EA:
    lea 0xfff8d3de,%a4	| 408B9CA4
    lea %pc@(TMENTRY1_234_1EA,%a4:l),%a4
    cmpal %a5@(4),%a4
    beqs TMENTRY1_234_204
TMENTRY1_234_1FA:
    lea 0xfff8d148,%a5	| 408B9CB4
    lea %pc@(TMENTRY1_234_1FA,%a5:l),%a5
TMENTRY1_234_204:
    movec %a5,%vbr
    moveal %d1,%a4
    btst #21,%d7
    jbeq TMENTRY1_450
    movel %d1,%d0
    moveq #4,%d2
    lea %pc@(TMENTRY1_450),%fp
    jmp %pc@(CVTASCII_68)
TMENTRY1_450:           /* set %d2 */
    moveq #2,%d2
    lea %pc@(TMENTRY1_45A),%fp
    jmp %pc@(CVTASCII_1E)
TMENTRY1_45A:           /* set %d0 */
    moveq #-1,%d0
    moveq #28,%d2
    lsll %d2,%d0
    notl %d0
    andl %d0,%d7
    movew %d1,%d0
    lsll %d2,%d1
    orl %d1,%d7
    btst #21,%d7
    jbeq TMENTRY1_47A
    moveq #2,%d2
    lea %pc@(TMENTRY1_47A),%fp
    jmp %pc@(CVTASCII_68)
TMENTRY1_47A:           /* clear %d6 */
    moveq #0,%d6
    movel %a4,%d1
    swap %d1
    moveb #63,%d0
    andil #65535,%d1
    cmpl %pc@(USTSTRT1_418),%d1
    jbge TMENTRY1_18A
    asll #2,%d1
    lea %pc@(USTSTRT1_3F0),%a5
    movel %a5@(0x0,%d1:l),%d1
    lea %a5@(0x0,%d1:l),%a5
    lea %pc@(TMENTRY1_4A6),%fp
    jmp %a5@
TMENTRY1_4A6:           /* (data) */
    moveaw #9728,%sp	| 408B9D2C
    movel %a0,%d4	| 408B9D30
    movel %a1,%d5	| 408B9D32
    lea %pc@(TMENTRY1_4B6),%fp	| 408B9D34
    jmp %pc@(SETUPBASES)	| 408B9D38
TMENTRY1_4B6:           /* (data) */
    .byte   0x20, 0x44, 0x22, 0x45	| 408B9D3C
    tstl %d6
    jbeq TMENTRY1_4DC
    lea %pc@(STR_ERROR),%a1
    lea %pc@(TMENTRY1_4CA),%fp
    jmp %pc@(OUTCHAR_1C)
TMENTRY1_4CA:           /* test bit 29 of %d7 */
    btst #29,%d7
    jbeq TMENTRY1_4D6
TMENTRY1_4D0:           /* address %pc@(TMENTRY1_4D0) */
    lea %pc@(TMENTRY1_4D0),%fp
    jmp %a5@
TMENTRY1_4D6:           /* test bit 28 of %d7 */
    btst #28,%d7
    jbne TMENTRY1_4F0
TMENTRY1_4DC:           /* set %d1 */
    movel %a4,%d1
    subqw #1,%d1
    jbeq TMENTRY1_4F0
    moveal %d1,%a4
    lea %pc@(TMENTRY1_4EC),%fp
    jmp %pc@(GETCHAR)
TMENTRY1_4EC:           /* (data) */
    tstw %d0	| 408B9D72
    jbmi TMENTRY1_47A	| 408B9D74
TMENTRY1_4F0:           /* set %d5 */
    movel #5505024,%d5
    jbra TMENTRY1_15C
    moveal %d1,%a4
    lea %pc@(TMENTRY1_4F0_1A),%fp
TMENTRY1_4F0_10:
    lea 0xfff91d3a,%a0	| 408B9D86
    jmp %pc@(TMENTRY1_4F0_10,%a0:l)
TMENTRY1_4F0_1A:
    moveal %sp@,%a1
    moveal %a1@,%a1
    lea %pc@(TMENTRY1_516),%fp
    jmp %pc@(SETVECTORTABLE)
TMENTRY1_516:           /* (data) */
    lea %pc@(TMENTRY1_51E),%fp	| 408B9D9C
    jmp %pc@(SETUPBASES)	| 408B9DA0
TMENTRY1_51E:           /* test bit 21 of %d7 */
    btst #21,%d7
    jbeq TMENTRY1_530
    movel %a4,%d0
    moveq #4,%d2
    lea %pc@(TMENTRY1_530),%fp
    jmp %pc@(CVTASCII_68)
TMENTRY1_530:           /* set %d2 */
    moveq #2,%d2
    lea %pc@(TMENTRY1_53A),%fp
    jmp %pc@(CVTASCII_1E)
TMENTRY1_53A:           /* set %d0 */
    moveq #-1,%d0
    moveq #28,%d2
    lsll %d2,%d0
    notl %d0
    andl %d0,%d7
    movew %d1,%d0
    lsll %d2,%d1
    orl %d1,%d7
    btst #21,%d7
    jbeq TMENTRY1_55A
    moveq #2,%d2
    lea %pc@(TMENTRY1_55A),%fp
    jmp %pc@(CVTASCII_68)
TMENTRY1_55A:           /* set %d1 */
    movel %a4,%d1
    swap %d1
    subiw #128,%d1
    andil #65535,%d1
    cmpl %pc@(USTSTRT1_49C),%d1
    bltw TMENTRY1_578
    moveb #63,%d0
    jbra TMENTRY1_18A
TMENTRY1_578:           /* from here: asll #2,%d1 */
    asll #2,%d1
    lea %pc@(USTSTRT1_41C),%a5
    movel %a5@(0x0,%d1:l),%d1
    lea %a5@(0x0,%d1:l),%a5
    movew %a4,%sp@-
    movel %a5,%sp@-
    moveq #0,%d2
    lea %pc@(TMENTRY1_59A),%fp
    bigjmp hardware_table_lookup_40847568
TMENTRY1_59A:           /* set %a5 */
    moveal %sp@+,%a5
    moveml %d0-%d2/%a0-%a2/%a5,%sp@-
TMENTRY1_5A0:           /* loop: moveq */
    moveq #0,%d6
    moveml %sp@,%d0-%d2/%a0-%a2/%a5
    lea %pc@(TMENTRY1_5AC),%fp
    jmp %a5@
TMENTRY1_5AC:           /* (data) */
    lea %pc@(TMENTRY1_5B4),%fp	| 408B9E32
    jmp %pc@(SETUPBASES)	| 408B9E36
TMENTRY1_5B4:           /* (data) */
    .byte   0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x00, 0xF6	| 408B9E3A
    tstl %d6
    jbeq TMENTRY1_5E2
    lea %pc@(STR_ERROR),%a1
    lea %pc@(TMENTRY1_5CC),%fp
    jmp %pc@(OUTCHAR_1C)
TMENTRY1_5CC:           /* test bit 29 of %d7 */
    btst #29,%d7
    jbeq TMENTRY1_5DC
TMENTRY1_5D2:           /* address %pc@(TMENTRY1_5D2) */
    lea %pc@(TMENTRY1_5D2),%fp
    moveml %sp@,%d0-%d2/%a0-%a2/%a5
    jmp %a5@
TMENTRY1_5DC:           /* test bit 28 of %d7 */
    btst #28,%d7
    jbne TMENTRY1_5F4
TMENTRY1_5E2:           /* subtract 1 to %sp@(28) */
    subqw #1,%sp@(28)
    jbeq TMENTRY1_5F4
    lea %pc@(TMENTRY1_5F0),%fp
    jmp %pc@(GETCHAR)
TMENTRY1_5F0:           /* (data) */
    tstw %d0	| 408B9E76
    jbmi TMENTRY1_5A0	| 408B9E78
TMENTRY1_5F4:           /* address %sp@(30) */
    lea %sp@(30),%sp
    movel #5111808,%d5
    jbra TMENTRY1_15C
    .byte   0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x00, 0x76, 0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x00, 0xA0	| 408B9E88
    .byte   0x43, 0xFA, 0x01, 0x74, 0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x01, 0x12, 0x28, 0x07, 0x08, 0xC7	| 408B9E98
    .byte   0x00, 0x14, 0x08, 0x87, 0x00, 0x17, 0x41, 0xF9, 0xFF, 0xF4, 0x61, 0x5B, 0x41, 0xFB, 0x88, 0xF8	| 408B9EA8
    .byte   0x10, 0x10, 0x74, 0x01, 0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x02, 0x7E, 0x10, 0x3C, 0x00, 0x20	| 408B9EB8
    .byte   0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x00, 0xCA, 0x41, 0xF9, 0xFF, 0xF4, 0x61, 0x42, 0x41, 0xFB	| 408B9EC8
    .byte   0x88, 0xF8, 0x30, 0x10, 0x74, 0x02, 0x08, 0xC7, 0x00, 0x17, 0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA	| 408B9ED8
    .byte   0x02, 0x58, 0x2E, 0x04, 0x60, 0x00, 0xFA, 0xF4, 0x41, 0xF9, 0x00, 0x00, 0x00, 0x00, 0x4E, 0xFB	| 408B9EE8
    .byte   0x88, 0xF8	| 408B9EF8
TMENTRY1_674:           /* (408B9EFA lea 0x0,%a0) */
    .short  0x41F9, 0x0000, 0x0000	| 408B9EFA lea 0x0,%a0
    jmp %pc@(TMENTRY1_674,%a0:l)	| 408B9F00

/* SETUPBASES: hardware base addresses for the tests. */
SETUPBASES:
    movel %fp,%d3
    moveq #0,%d2
    lea %pc@(SETUPBASES_12),%fp
    bigjmp hardware_table_lookup_40847568
SETUPBASES_12:          /* set %fp */
    moveal %d3,%fp
    moveal %a0@(8),%a2
    btst #17,%d0
    jbeq SETUPBASES_26
    moveal %a0@(68),%a3
    moveq #0,%d3
    jbra SETUPBASES_30
SETUPBASES_26:          /* set %a3 */
    moveal %a0@(12),%a3
    movel %a0@(16),%d3
    subl %a3,%d3
SETUPBASES_30:          /* jump through %fp@ */
    jmp %fp@
SETUPBASES_32:          /* set %a5 */
    moveal %fp,%a5
    btst #17,%d0
    jbeq SETUPBASES_48
    lea %pc@(SETUPBASES_48),%fp
    bigjmp SETSCCIOPBYPASS
SETUPBASES_48:          /* test %a3@(0x0,%d3:l) */
    tstb %a3@(0x0,%d3:l)
    lea %pc@(SETUPBASES_7A),%a1
SETUPBASES_50:          /* loop: move */
    moveb %a1@+,%d0
    jbmi SETUPBASES_5E
    moveb %d0,%a3@(0x2,%d3:l)
    moveb %a1@+,%a3@(0x2,%d3:l)
    jbra SETUPBASES_50
SETUPBASES_5E:          /* set bit 17 of %d7 */
    bset #17,%d7
    moveb %a3@(6),%d0
    bset #3,%a2@(1536)
    moveb %a2@(7680),%d0
    bclr #3,%d0
    moveb %d0,%a2@(7680)
    jmp %a5@
SETUPBASES_7A:          /* (data) */
    .short  0x09C0	| 408B9F7E
    .long   0x0F00044C, 0x0B500E00, 0x0C0A0D00, 0x0E010A00	| 408B9F80
    .long   0x03C105EA, 0x0100FFFF	| 408B9F90

/* OUTCHAR: send a character on the serial port. */
OUTCHAR:
    moveb #48,%a3@(0x2,%d3:l)
    moveb %d0,%a3@(0x6,%d3:l)
OUTCHAR_A:              /* loop: move */
    movew #1,%d0
    moveb %d0,%a3@(0x2,%d3:l)
    btst #0,%a3@(2)
    jbeq OUTCHAR_A
    jmp %fp@

OUTCHAR_1C:             /* set %a0 */
    moveal %fp,%a0
OUTCHAR_1E:             /* loop: move */
    moveb %a1@+,%d0
    jbeq OUTCHAR_2C
    lea %pc@(OUTCHAR_2A),%fp
    jmp %pc@(OUTCHAR)
OUTCHAR_2A:             /* (data) */
    jbra OUTCHAR_1E	| 408B9FC2
OUTCHAR_2C:             /* jump through %a0@ */
    jmp %a0@

/* STR_ERROR: string. */
STR_ERROR:
    .ascii  "*ERROR*\000"

/* STR_APPLE: string. */
STR_APPLE:
    .ascii  "*APPLE*\000"
    .ascii  "03211116788AAABCDEHIJKLMNOPQRSTUVWXYZabcdefghijklmno*\015\012\000"
    .ascii  "STM Version 2.2, Aaron Ludtke \015\012CTE Version 2.1 \015\012ROM Version \000"
    .byte   0x00	| 408BA04D

/* STARTTIMER: start the test timer. */
STARTTIMER:
    moveal %fp,%a3
    moveq #0,%d2
    lea %pc@(STARTTIMER_12),%fp
STARTTIMER_8:
    lea 0xfff8d512,%a0	| 408BA056
    jmp %pc@(STARTTIMER_8,%a0:l)
STARTTIMER_12:
    moveal %a0@(8),%a2
    clrb %a2@(5632)
    moveb #32,%a2@(7168)
    moveb #0xff,%a2@(4096)	| 408BA06E
    moveb #0xff,%a2@(4608)
    jmp %a3@
    moveal %fp,%a5
    bclr #15,%d0
    btst #5,%a2@(6656)
    beqs STARTTIMER_58
    moveb #32,%a2@(7168)
    moveb #0xff,%a2@(4096)	| 408BA090
    moveb #0xff,%a2@(4608)
    subqw #1,%d4
    bpls STARTTIMER_58
    movew %d0,%d4
    bset #15,%d0
STARTTIMER_58:
    jmp %a5@

/* GETCHAR: receive a character. */
GETCHAR:
    movew #-32768,%d0
    btst #17,%d7
    jbeq GETCHAR_2E
    btst #0,%a3@(2)
    jbeq GETCHAR_2E
    moveq #1,%d0
    moveb %d0,%a3@(0x2,%d3:l)
    moveb %a3@(2),%d0
    andib #112,%d0
    jbeq GETCHAR_28
    moveb #48,%a3@(0x2,%d3:l)
GETCHAR_28:             /* from here: lsll #8,%d0 */
    lsll #8,%d0
    moveb %a3@(6),%d0
GETCHAR_2E:             /* jump through %fp@ */
    jmp %fp@

/* CVTASCII: convert to ASCII hex. */
CVTASCII:
    andiw #127,%d0
    subib #48,%d0
    jbmi CVTASCII_1A
    cmpib #22,%d0
    jbgt CVTASCII_1A
    cmpib #9,%d0
    jble CVTASCII_18
    subqb #7,%d0
CVTASCII_18:            /* jump through %fp@ */
    jmp %fp@
CVTASCII_1A:            /* clear %d0 */
    clrw %d0
    jmp %fp@

CVTASCII_1E:            /* set %a5 */
    moveal %fp,%a5
    tstw %d2
    jbeq CVTASCII_58
    moveq #0,%d1
    btst #20,%d7
    jbeq CVTASCII_2E
    aslw #1,%d2
CVTASCII_2E:            /* subtract 1 to %d2 */
    subqw #1,%d2
CVTASCII_30:            /* loop: lea */
    lea %pc@(CVTASCII_38),%fp
    jmp %pc@(GETCHAR)
CVTASCII_38:            /* (data) */
    tstw %d0	| 408BA110
    jbmi CVTASCII_30	| 408BA112
    btst #20,%d7
    jbeq CVTASCII_50
    lea %pc@(CVTASCII_4A),%fp
    jmp %pc@(CVTASCII)
CVTASCII_4A:            /* (data) */
    lsll #4,%d1	| 408BA122
    orb %d0,%d1	| 408BA124
    jbra CVTASCII_54	| 408BA126
CVTASCII_50:            /* from here: lsll #8,%d1 */
    lsll #8,%d1
    moveb %d0,%d1
CVTASCII_54:            /* count down */
    dbf %d2,CVTASCII_30
CVTASCII_58:            /* jump through %a5@ */
    jmp %a5@

CVTASCII_5A:            /* test #10,%d0 */
    cmpib #10,%d0
    jblt CVTASCII_62
    addqb #7,%d0
CVTASCII_62:            /* from here: addib #48,%d0 */
    addib #48,%d0
    jmp %fp@

CVTASCII_68:            /* set %a5 */
    moveal %fp,%a5
    movel %d0,%d1
    tstw %d2
    jbeq CVTASCII_AC
    moveq #4,%d0
    subw %d2,%d0
    muluw #8,%d0
    roll %d0,%d1
    btst #20,%d7
    jbeq CVTASCII_82
    aslw #1,%d2
CVTASCII_82:            /* subtract 1 to %d2 */
    subqw #1,%d2
CVTASCII_84:            /* loop: btst */
    btst #20,%d7
    jbne CVTASCII_90
    roll #8,%d1
    moveb %d1,%d0
    jbra CVTASCII_A0
CVTASCII_90:            /* from here: roll #4,%d1 */
    roll #4,%d1
    moveb %d1,%d0
    andib #15,%d0
    lea %pc@(CVTASCII_A0),%fp
    jmp %pc@(CVTASCII_5A)
CVTASCII_A0:            /* address %pc@(CVTASCII_A8) */
    lea %pc@(CVTASCII_A8),%fp
    jmp %pc@(OUTCHAR)
CVTASCII_A8:            /* (data) */
    dbf %d2,CVTASCII_84	| 408BA180
CVTASCII_AC:            /* test bit 23 of %d7 */
    btst #23,%d7
    jbeq CVTASCII_CA
    moveb #13,%d0
    lea %pc@(CVTASCII_BE),%fp
    jmp %pc@(OUTCHAR)
CVTASCII_BE:            /* set %d0 */
    moveb #10,%d0
    lea %pc@(CVTASCII_CA),%fp
    jmp %pc@(OUTCHAR)
CVTASCII_CA:            /* jump through %a5@ */
    jmp %a5@

/* TM_SENDBYTE: send a byte. */
TM_SENDBYTE:
    .short  0x2A4E, 0x1542, 0x1400, 0x08D2, 0x0004	| 408BA1A4
TM_SENDBYTE_A:          /* loop: btst */
    btst #2,%a2@(6656)
    jbeq TM_SENDBYTE_A
    tstb %a2@(5120)
    bclr #4,%a2@
    moveal %a5,%fp
    jmp %pc@(TM_WAIT)

/* TM_GETBYTE: receive a byte. */
TM_GETBYTE:
    moveal %fp,%a5	| 408BA1C4
    bclr #4,%a2@
TM_GETBYTE_6:           /* loop: btst */
    btst #2,%a2@(6656)
    jbeq TM_GETBYTE_6
    bset #4,%a2@
    moveb %a2@(5120),%d2
    lea %pc@(TM_GETBYTE_1E),%fp
    jmp %pc@(TM_WAIT)
TM_GETBYTE_1E:          /* from here: andiw #255,%d2 */
    andiw #255,%d2
    btst #3,%a2@
    jmp %a5@

/* TM_WAIT: wait. */
TM_WAIT:
    movew #256,%d0
TM_WAIT_4:              /* loop: tst */
    tstb %a2@
    dbf %d0,TM_WAIT_4
    jmp %fp@
    moveal %fp,%a4
    btst #3,%a2@
    bnes TM_WAIT_4_24_A	| 408BA1FE
    lea %pc@(TM_WAIT_4_18),%fp
    jmp %pc@(TM_WAIT)
TM_WAIT_4_18:
    bset #5,%a2@
TM_WAIT_4_1C:
    lea %pc@(TM_WAIT_4_24),%fp
    jmp %pc@(TM_GETBYTE)
TM_WAIT_4_24:
    beqs TM_WAIT_4_1C
    bclr #5,%a2@	| 408BA216
    bclr #4,%a2@
TM_WAIT_4_24_A:
    moveal %a4,%fp	| 408BA21E
    jmp %pc@(TM_WAIT)
    moveal %fp,%a5
    jmp %a5@

caseD_0:                /* set %usp */
    movel %fp,%usp
    lea %pc@(TM_WAIT_4C),%fp
    bigjmp thunk_FUN_408a0000
TM_WAIT_4C:             /* from here: sne %d7 */
    sne %d7
    jbne TM_WAIT_52
    movel %sp@,%d6
TM_WAIT_52:             /* set %fp */
    movel %usp,%fp
    jmp %fp@
TM_WAIT_56:             /* set %a3 */
    moveal %fp,%a3
    moveq #0,%d2
    lea %pc@(TM_WAIT_68),%fp
    bigjmp hardware_table_lookup_40847568
TM_WAIT_68:             /* from here: subal %a2,%a2 */
    subal %a2,%a2
    lea %pc@(TM_WAIT_78),%fp
    bigjmp SIZEV8VRAM, a4
TM_WAIT_78:             /* set %d0 */
    movel %a2,%d0
    jbne TM_WAIT_80
    moveq #-1,%d6
    jbra TM_WAIT_9A
TM_WAIT_80:             /* clear %d6 */
    moveq #0,%d6
    btst #2,%a2@(1)
    jbeq TM_WAIT_9A
    movel #262144,%d6
    btst #1,%a2@(1)
    jbne TM_WAIT_9A
    lsll #1,%d6
TM_WAIT_9A:             /* jump through %a3@ */
    jmp %a3@

/* SETVECTORTABLE: the tests' exception vector table. */
SETVECTORTABLE:
    biglea MYFIRSTPROC
    movel %a0,%d2
    subil #1082130432,%d2
    biglea TMVECTORS
    moveal %a1,%a2
    movew #63,%d0
SETVECTORTABLE_22:      /* loop: move */
    movel %a0@+,%d1
    addl %d2,%d1
    movel %d1,%a1@+
    dbf %d0,SETVECTORTABLE_22
    movec %a2,%vbr
    jmp %fp@
SETVECTORTABLE_32:      /* save registers */
    moveml %d1-%fp,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    linkw %a5,#0
    movel %a0@+,%d1
    jbeq SETVECTORTABLE_50
    lea %a0@(0x0,%d1:l:4),%a0
    subql #1,%d1
SETVECTORTABLE_4A:      /* loop: move */
    movel %a0@-,%sp@-
    dbf %d1,SETVECTORTABLE_4A
SETVECTORTABLE_50:      /* address %pc@(SETVECTORTABLE_74) */
    lea %pc@(SETVECTORTABLE_74),%a0
    movel %d0,%d1
    swap %d1
    cmpiw #1,%d1
    jbne SETVECTORTABLE_62
    lea %pc@(SETVECTORTABLE_7C),%a0
SETVECTORTABLE_62:      /* set %d0 */
    movel %a0@(0x0,%d0:w:4),%d0
    jsr %a0@(0x0,%d0:l)
    unlk %a5
    movew %sp@+,%sr
    moveml %sp@+,%d1-%fp
    rts
SETVECTORTABLE_74:      /* from here: orib #0xf0,%d0 */
    orib #0xf0,%d0
    orib #36,%d0
SETVECTORTABLE_7C:      /* (orib #0xec,%d1) */
    .long   GI_GetVersion-SETVECTORTABLE_7C	| 408BA304
    .long   GI_AllocPermMem-SETVECTORTABLE_7C	| 408BA308
    .long   GI_AllocPermMem_20-SETVECTORTABLE_7C	| 408BA30C
    .long   GI_AllocTempMem_1E_2-SETVECTORTABLE_7C	| 408BA310
    .long   GI_GetCommentary-SETVECTORTABLE_7C	| 408BA314
    .long   GI_GetDefaultExecutionOptions-SETVECTORTABLE_7C	| 408BA318
    .long   GI_ExecuteDTM-SETVECTORTABLE_7C	| 408BA31C
    movel %sp@(16),%d0
    cmpil #20,%d0
    jbge SETVECTORTABLE_AA
    moveq #-5,%d0
    jbra SETVECTORTABLE_162
SETVECTORTABLE_AA:      /* set %d0 */
    movel %sp@(28),%d0
    cmpil #20,%d0
    jbge SETVECTORTABLE_BC
    moveq #-6,%d0
    jbra SETVECTORTABLE_162
SETVECTORTABLE_BC:      /* set %a0 */
    moveal %sp@(4),%a0
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    moveal %a0@(18),%a1
    movel %sp@(8),%d0
    jbeq SETVECTORTABLE_128
SETVECTORTABLE_D0:      /* loop: cmp */
    cmpw %a1@(2),%d0
    jbeq SETVECTORTABLE_E4
    addaw #10,%a1
    cmpiw #-1,%a1@
    jbne SETVECTORTABLE_D0
    moveq #-10,%d0
    jbra SETVECTORTABLE_162
SETVECTORTABLE_E4:      /* set %d1 */
    movew %a1@(4),%d1
    andw %a0@(8),%d1
    jbne SETVECTORTABLE_F2
    moveq #-11,%d0
    jbra SETVECTORTABLE_162
SETVECTORTABLE_F2:      /* from here: biglea USTSUBTESTS, a3 */
    biglea USTSUBTESTS, a3
    movel %a3,%d2
    moveal %sp@(12),%a1
SETVECTORTABLE_102:     /* loop: cmp */
    cmpl %a3@,%d0
    jbeq SETVECTORTABLE_10C
    addaw #24,%a3
    jbra SETVECTORTABLE_102
SETVECTORTABLE_10C:     /* clear %a1@ */
    clrl %a1@
    movel %a3@,%a1@(4)
    movel %a3@(4),%a1@(8)
    addl %d2,%a1@(8)
    movel %a3@(16),%a1@(12)
    movel %a3@(20),%a1@(16)
SETVECTORTABLE_128:     /* set %d0 */
    movel %sp@(20),%d0
    jbeq SETVECTORTABLE_160
    biglea USTSTRT, a3
    movel %a3,%d2
    moveal %sp@(24),%a1
SETVECTORTABLE_13E:     /* loop: cmp */
    cmpl %a3@,%d0
    jbeq SETVECTORTABLE_148
    addaw #24,%a3
    jbra SETVECTORTABLE_13E
SETVECTORTABLE_148:     /* clear %a1@ */
    clrl %a1@
    movel %a3@,%a1@(4)
    movel %a3@(4),%a1@(8)
    addl %d2,%a1@(8)
    clrl %a1@(12)
    clrl %a1@(16)
SETVECTORTABLE_160:     /* clear %d0 */
    moveq #0,%d0
SETVECTORTABLE_162:     /* return */
    rts

SETVECTORTABLE_164:     /* set %a0 */
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
    movel %d0,%sp@-
    pea %a0@
    bigjsr GI_InitInterface
    addql #8,%sp
    moveal %sp@(4),%a0
    movel #154,%d0
    movel %d0,%sp@-
    pea %a0@
    bigjsr GI_AllocPermMem
    addql #8,%sp
    moveal %sp@(4),%a0
    moveal %a0@(8),%a0
    movel %d0,%a0@
    moveal %d0,%a1
    moveal %sp@(4),%a0
    moveml %a0-%a1,%sp@-
    movel #1886547811,%d0
    .short  0xA1AD	| 408BA438 _Gestalt (flags 0x0100)
    tstw %d0
    jbeq SETVECTORTABLE_1B8
    subal %a0,%a0
SETVECTORTABLE_1B8:     /* set %d0 */
    movew %a0,%d0
    moveml %sp@+,%a0-%a1
    movel %d0,%a0@(4)
    moveal 0xdd8,%a2
    moveq #0,%d1
    moveb %a2@(18),%d1
    movew #8,%a1@(8)
    movel %a0,%a1@(22)
    clrl %a1@(26)
    movel %a2,%a1@(38)
    moveal %a2@,%a3
    addal %a2,%a3
    movel %a3,%a1@(34)
    movel 0xdd0,%a1@(42)
    biglea USTCPULIST
    movel %a0,%d3
SETVECTORTABLE_1F8:     /* loop: move */
    movew %a0@,%d2
    cmpib #0xfd,%d2
    jbeq SETVECTORTABLE_208
    cmpb %d2,%d1
    jbeq SETVECTORTABLE_208
    addql #6,%a0
    jbra SETVECTORTABLE_1F8
SETVECTORTABLE_208:     /* set %a0 */
    moveal %a0@(2),%a0
    lea %a0@(0x0,%d3:l),%a0
    movel %a0,%a1@(18)
    moveq #0,%d0
    rts

/* USTMAINTEST: main start-up test sequence. */
USTMAINTEST:
    linkw %fp,#0
    moveml %d1-%a5,%sp@-
    moveal %fp@(8),%a3
    moveal %a3,%a4
    moveal %a3@(16),%a3
    moveal %a3@(8),%a3
    moveal %a4@(8),%a4
    moveal %a4@,%a4
    movel %a4@(42),%d0
    moveal %a4@(34),%a0
    moveal %a4@(38),%a1
    movew %a1@(18),%d2
    moveq #0,%d6
    moveml %fp,%sp@-
    lea %pc@(USTMAINTEST_38),%fp
    jmp %a3@
USTMAINTEST_38:         /* restore registers */
    moveml %sp@+,%fp
    movel %d6,%d0
    moveml %sp@+,%d1-%a5
    unlk %fp
    rts
USTMAINTEST_46:         /* (data) */
    .long   UTECMD_94-USTMAINTEST_46	| 408BA4E6
    .long   UTECMD_1C6-USTMAINTEST_46	| 408BA4EA
    .long   UTECMD_228-USTMAINTEST_46	| 408BA4EE
    .long   UTECMD_27A-USTMAINTEST_46	| 408BA4F2
    .long   UTECMD_2CC-USTMAINTEST_46	| 408BA4F6
    .long   UTECMD_2E0-USTMAINTEST_46	| 408BA4FA
    .long   UTECMD_D4-USTMAINTEST_46	| 408BA4FE
    .long   UTECMD_EA-USTMAINTEST_46	| 408BA502
    .long   UTECMD_150-USTMAINTEST_46	| 408BA506
    .long   UTECMD_2F4-USTMAINTEST_46	| 408BA50A
    .long   UTECMD_372-USTMAINTEST_46	| 408BA50E
USTMAINTEST_72:         /* (orib #0xbe,%d1) */
    .long   GI_InitInterface-USTMAINTEST_72	| 408BA512
    .long   GI_GetVersion-USTMAINTEST_72	| 408BA516
    .long   GI_AllocPermMem-USTMAINTEST_72	| 408BA51A
    .long   GI_AllocPermMem_20-USTMAINTEST_72	| 408BA51E
    .long   GI_AllocTempMem_1E_2-USTMAINTEST_72	| 408BA522
    .long   GI_GetCommentary-USTMAINTEST_72	| 408BA526
    .long   GI_GetDefaultExecutionOptions-USTMAINTEST_72	| 408BA52A
    .long   GI_ExecuteDTM-USTMAINTEST_72	| 408BA52E
UTECMD:                 /* address %sp@(-6) */
    lea %sp@(-6),%sp
    movel %sp,%sp@-
    movel #6,%sp@-
    jbsr UTECMD_3F0
    lea %sp@(8),%sp
    movel %sp@+,%d0
    jbne UTECMD_24
    addql #2,%sp
    moveal %sp@,%fp
    lea %pc@(USTMAINTEST_46),%a0
    addal %a0@,%a0
    jmp %a0@
UTECMD_24:              /* clear %d1 */
    moveq #0,%d1
    movew %sp@+,%d1
    moveal %sp@(4),%a5
    moveml %d3/%a3,%sp@-
    movel %d0,%a5@
    movel %d1,%a5@(4)
    jbeq UTECMD_48
    subal %d1,%sp
    movel %sp,%sp@-
    movel %d1,%sp@-
    jbsr UTECMD_3F0
    lea %sp@(8),%sp
    movel %a5@,%d0
UTECMD_48:              /* address %pc@(USTMAINTEST_46) */
    lea %pc@(USTMAINTEST_46),%a0
    cmpil #65536,%d0
    jblt UTECMD_5E
    lea %pc@(USTMAINTEST_72),%a0
    subil #65536,%d0
UTECMD_5E:              /* set %sp@- */
    movel %a5@(22),%sp@-
    lsll #2,%d0
    movel %a0@(0x0,%d0:l),%d0
    jsr %a0@(0x0,%d0:l)
    addql #4,%sp
    addal %a5@(4),%sp
    moveml %sp@+,%d3/%a3
    movel %d0,%sp@-
    movel %sp,%sp@-
    movel #4,%sp@-
    jbsr UTECMD_45A
    lea %sp@(8),%sp
    moveq #0,%d0
    movel %sp@+,%d6
    jbeq UTECMD_92
    moveb #88,%d0
UTECMD_92:              /* return */
    rts
UTECMD_94:              /* set %usp */
    movel %fp,%usp	| 408BA5C6
    lea %pc@(UTECMD_A4),%fp	| 408BA5C8
UTECMD_9A:              /* address 0xfff8cffc */
    lea 0xfff8cffc,%a0	| 408BA5CC
    jmp %pc@(UTECMD_9A,%a0:l)	| 408BA5D2
UTECMD_A4:              /* set %a5@(8) */
    movew #4,%a5@(8)	| 408BA5D6
    subal #55296,%sp	| 408BA5DC
    movel %sp,%a5@(22)	| 408BA5E2
    movel %a5,%sp@-	| 408BA5E6
    movel %usp,%a0	| 408BA5E8
    movel %a0,%sp@-	| 408BA5EA
    moveal %a5@(22),%a0	| 408BA5EC
    movel #55296,%sp@-	| 408BA5F0
    pea %a0@	| 408BA5F6
UTECMD_C6:              /* address 0x142d8 */
    lea 0x142d8,%a0	| 408BA5F8
    jsr %pc@(UTECMD_C6,%a0:l)	| 408BA5FE
    addql #8,%sp	| 408BA602
    rts	| 408BA604
UTECMD_D4:              /* set %a0 */
    moveal %sp,%a0	| 408BA606
    movel %a0@(8),%sp@-	| 408BA608
    movel %a0@(12),%sp@-	| 408BA60C
    jbsr UTECMD_45A	| 408BA610
    lea %sp@(8),%sp	| 408BA614
    moveq #0,%d0	| 408BA618
    rts	| 408BA61A

UTECMD_EA:              /* entry: stack frame */
    linkw %fp,#0
    moveal %a5@(34),%a0
    moveal %a5@(38),%a1
    moveal %a0@(8),%a2
    subaw %fp@(14),%sp
    moveal %sp,%a4
    moveml %d3/%a3-%a4/%fp,%sp@-
    moveaw %fp@(12),%a3
    movew %fp@(14),%d3
    movel %a3,%sp@-
    movew %a3,%sp@-
    pea %a4@
    movew %d3,%sp@-
    lea %pc@(UTECMD_126),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
UTECMD_126:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    moveml %sp@+,%d3/%a3-%a4/%fp
    moveml %fp,%sp@-
    movel %a4,%sp@-
    movew %fp@(14),%d0
    extl %d0
    movel %d0,%sp@-
    jbsr UTECMD_45A
    lea %sp@(8),%sp
    moveml %sp@+,%fp
    unlk %fp
    moveq #0,%d0
    rts

UTECMD_150:             /* entry: stack frame */
    linkw %fp,#0
    movew %fp@(14),%d0
    extl %d0
    subal %d0,%sp
    moveal %sp,%a4
    moveml %a4/%fp,%sp@-
    movel %a4,%sp@-
    movel %d0,%sp@-
    jbsr UTECMD_3F0
    lea %sp@(8),%sp
    moveml %sp@+,%a4/%fp
    moveal %a5@(34),%a0
    moveal %a5@(38),%a1
    moveal %a0@(8),%a2
    moveml %a4-%fp,%sp@-
    lea %pc@(UTECMD_190),%fp
    bigjmp CLKWPOFF, a4
UTECMD_190:             /* restore registers */
    moveml %sp@+,%a4-%fp
    moveml %fp,%sp@-
    movel %a3,%sp@-
    pea %a4@
    movew %fp@(12),%sp@-
    movew %fp@(14),%sp@-
    lea %pc@(UTECMD_1B6),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
UTECMD_1B6:             /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    moveml %sp@+,%fp
    unlk %fp
    moveq #0,%d0
    rts

UTECMD_1C6:             /* entry: stack frame */
    linkw %fp,#0
    moveml %d1-%d5/%a0-%a5,%sp@-
    movel %fp@(12),%d4
    movel %fp@(16),%d5
    movel %fp,%sp@-
    lea %pc@(UTECMD_1E0),%fp
    jmp %pc@(SETUPFOREXECUTEDTM)
UTECMD_1E0:             /* set %fp */
    moveal %sp@+,%fp
    cmpil #-1,%a5@(90)
    jbeq UTECMD_21C
    cmpil #-1,%a5@(110)
    jbeq UTECMD_21C
    moveal %fp@(8),%a0
    pea %a5@(122)
    pea %a5@(102)
    pea %a5@(82)
    pea %a5@(46)
    pea %a0@
    bigjsr GI_ExecuteDTM
    addaw #20,%sp
    jbra UTECMD_21E
UTECMD_21C:             /* set %d0 */
    moveq #-1,%d0
UTECMD_21E:             /* restore registers, return */
    moveml %sp@+,%d1-%d5/%a0-%a5
    unlk %fp
    movel %d0,%d6
    rts

UTECMD_228:             /* set %a0 */
    moveal %sp@(4),%a0
    movel %sp@(16),%d0
    movel %d0,%sp@-
    pea %a0@
    bigjsr GI_AllocPermMem
    addql #8,%sp
    tstl %d0
    jbne UTECMD_24A
    moveaw #-1,%a0
    jbra UTECMD_276
UTECMD_24A:             /* set %d1 */
    movel %sp@(16),%d1
    movel %d0,%sp@-
    movel %d1,%sp@-
    jbsr UTECMD_3F0
    movel %sp@+,%d1
    moveal %sp@+,%a0
    movel %a0,%a5@(90)
    movel %sp@(8),%a5@(86)
    movel %sp@(24),%a5@(82)
    movel %sp@(28),%a5@(94)
    movel %sp@(32),%a5@(98)
UTECMD_276:             /* set %d0 */
    movel %a0,%d0
    rts

UTECMD_27A:             /* set %a0 */
    moveal %sp@(4),%a0
    movel %sp@(16),%d0
    movel %d0,%sp@-
    pea %a0@
    bigjsr GI_AllocPermMem
    addql #8,%sp
    tstl %d0
    jbne UTECMD_29C
    moveaw #-1,%a0
    jbra UTECMD_2C8
UTECMD_29C:             /* set %d1 */
    movel %sp@(16),%d1
    movel %d0,%sp@-
    movel %d1,%sp@-
    jbsr UTECMD_3F0
    movel %sp@+,%d1
    moveal %sp@+,%a0
    movel %a0,%a5@(110)
    movel %sp@(8),%a5@(106)
    movel %sp@(24),%a5@(102)
    movel %sp@(28),%a5@(114)
    movel %sp@(32),%a5@(118)
UTECMD_2C8:             /* set %d0 */
    movel %a0,%d0
    rts

UTECMD_2CC:             /* set %d1 */
    movel %sp@(8),%d1
    pea %a5@(46)
    movel %d1,%sp@-
    jbsr UTECMD_3F0
    movel %sp@+,%d1
    movel %sp@+,%d0
    rts

UTECMD_2E0:             /* set %d1 */
    movel %sp@(8),%d1
    pea %a5@(122)
    movel %d1,%sp@-
    jbsr UTECMD_3F0
    movel %sp@+,%d1
    movel %sp@+,%d0
    rts

UTECMD_2F4:             /* entry: stack frame */
    linkw %fp,#0
    moveml %d1-%d5/%a0-%a5,%sp@-
    movel %fp@(12),%d5
    biglea USTSTRT, a2
    movel %a2,%d1
UTECMD_30C:             /* loop: cmpi */
    cmpil #-1,%a2@
    jbeq UTECMD_36A
    cmpl %a2@,%d5
    jbeq UTECMD_31E
    addaw #24,%a2
    jbra UTECMD_30C
UTECMD_31E:             /* entry: stack frame */
    linkw %a5,#-24
    moveal %sp,%a1
    movel %a2@,%a5@(-24)
    moveal %a2@(4),%a4
    addal %d1,%a4
    movel %a4,%a5@(-20)
    moveal %a2@(8),%a4
    addal %d1,%a4
    movel %a4,%a5@(-16)
    movel %a2@(12),%a5@(-12)
    movel %a2@(16),%a5@(-8)
    movel %a2@(20),%a5@(-4)
    moveml %a2/%fp,%sp@-
    movel %a1,%sp@-
    movel #24,%sp@-
    jbsr UTECMD_45A
    lea %sp@(8),%sp
    moveml %sp@+,%a2/%fp
    unlk %a5
    moveq #0,%d0
UTECMD_36A:             /* restore registers, return */
    moveml %sp@+,%d1-%d5/%a0-%a5
    unlk %fp
    rts

UTECMD_372:             /* entry: stack frame */
    linkw %fp,#0
    moveml %d1-%d5/%a0-%a5,%sp@-
    movel %fp@(12),%d5
    biglea USTSUBTESTS, a2
    movel %a2,%d1
UTECMD_38A:             /* loop: cmpi */
    cmpil #-1,%a2@
    jbeq UTECMD_3E8
    cmpl %a2@,%d5
    jbeq UTECMD_39C
    addaw #24,%a2
    jbra UTECMD_38A
UTECMD_39C:             /* entry: stack frame */
    linkw %a5,#-24
    moveal %sp,%a1
    movel %a2@,%a5@(-24)
    moveal %a2@(4),%a4
    addal %d1,%a4
    movel %a4,%a5@(-20)
    moveal %a2@(8),%a4
    addal %d1,%a4
    movel %a4,%a5@(-16)
    movel %a2@(12),%a5@(-12)
    movel %a2@(16),%a5@(-8)
    movel %a2@(20),%a5@(-4)
    moveml %a2/%fp,%sp@-
    movel %a1,%sp@-
    movel #24,%sp@-
    bsrw UTECMD_45A
    lea %sp@(8),%sp
    moveml %sp@+,%a2/%fp
    unlk %a5
    moveq #0,%d0
UTECMD_3E8:             /* restore registers, return */
    moveml %sp@+,%d1-%d5/%a0-%a5
    unlk %fp
    rts

UTECMD_3F0:             /* set %d1 */
    movel %sp@(4),%d1
    btst #20,%d7
    jbeq UTECMD_3FC
    lsll #1,%d1
UTECMD_3FC:             /* set %a0 */
    moveal %sp@(8),%a0
UTECMD_400:             /* save registers */
    moveml %d1/%a0/%a5,%sp@-
UTECMD_404:             /* loop: lea */
    lea %pc@(UTECMD_40C),%fp
    jmp %pc@(GETCHAR)
UTECMD_40C:             /* (data) */
    tstw %d0	| 408BA93E
    jbmi UTECMD_404	| 408BA940
    btst #21,%d7
    jbeq UTECMD_422
    movel %d0,%d1
    lea %pc@(UTECMD_420),%fp
    jmp %pc@(OUTCHAR)
UTECMD_420:             /* (data) */
    movel %d1,%d0	| 408BA952
UTECMD_422:             /* test bit 20 of %d7 */
    btst #20,%d7
    jbeq UTECMD_44E
    cmpib #97,%d0
    jblt UTECMD_432
    andib #0xdf,%d0
UTECMD_432:             /* address %pc@(UTECMD_43A) */
    lea %pc@(UTECMD_43A),%fp
    jmp %pc@(CVTASCII)
UTECMD_43A:             /* (data) */
    moveml %sp@+,%d1/%a0/%a5	| 408BA96C
    btst #0,%d1	| 408BA970
    jbne UTECMD_44A	| 408BA974
    lslb #4,%d0	| 408BA976
    moveb %d0,%a0@	| 408BA978
    jbra UTECMD_454	| 408BA97A
UTECMD_44A:             /* from here: orb %d0,%a0@+ */
    orb %d0,%a0@+	| 408BA97C
    jbra UTECMD_454	| 408BA97E
UTECMD_44E:             /* restore registers */
    moveml %sp@+,%d1/%a0/%a5
    moveb %d0,%a0@+
UTECMD_454:             /* subtract 1 to %d1 */
    subql #1,%d1
    jbgt UTECMD_400
    rts

UTECMD_45A:             /* call UTECMD_4C0 */
    bsrw UTECMD_4C0
    movel %sp@(4),%d1
    movel %d1,%d4
    moveal %sp@(8),%a0
UTECMD_468:             /* loop: move */
    moveb %a0@+,%d0
    btst #20,%d7
    jbeq UTECMD_48A
    moveb %d0,%d2
    lsrb #4,%d0
    bsrw UTECMD_4AE
    lea %pc@(UTECMD_480),%fp
    jmp %pc@(OUTCHAR)
UTECMD_480:             /* (data) */
    moveb %d2,%d0	| 408BA9B2
    andib #15,%d0	| 408BA9B4
    bsrw UTECMD_4AE
UTECMD_48A:             /* address %pc@(UTECMD_492) */
    lea %pc@(UTECMD_492),%fp
    jmp %pc@(OUTCHAR)
UTECMD_492:             /* (data) */
    cmpil #4,%d4	| 408BA9C4
    jble UTECMD_4A6	| 408BA9CA
    movel %a0,%d0	| 408BA9CC
    andib #3,%d0	| 408BA9CE
    bnes UTECMD_4A6
    bsrw UTECMD_4C0
UTECMD_4A6:             /* subtract 1 to %d1 */
    subql #1,%d1
    jbgt UTECMD_468
    moveq #0,%d0
    rts

UTECMD_4AE:             /* test #10,%d0 */
    cmpib #10,%d0
    jblt UTECMD_4BA
    addib #55,%d0
    jbra UTECMD_4BE
UTECMD_4BA:             /* from here: addib #48,%d0 */
    addib #48,%d0
UTECMD_4BE:             /* return */
    rts

UTECMD_4C0:             /* set %d0 */
    moveb #13,%d0
    lea %pc@(UTECMD_4CC),%fp
    jmp %pc@(OUTCHAR)
UTECMD_4CC:             /* set %d0 */
    moveb #10,%d0
    lea %pc@(UTECMD_4D8),%fp
    jmp %pc@(OUTCHAR)
UTECMD_4D8:             /* (data) */
    rts	| 408BAA0A

/* DIAGROMENTRY: enter a diagnostic ROM if one is present. */
DIAGROMENTRY:
    tstl %d7
    jbne DIAGROMENTRY_10A
    moveq #0,%d2
    lea %pc@(DIAGROMENTRY_16),%fp
    bigjmp hardware_table_lookup_40847568
DIAGROMENTRY_16:        /* set %a2 */
    moveal %a0@(8),%a2
    moveal %sp,%fp
    moveaw #64,%a3
    moveaw #4,%a5
    movel %a3,%sp@-
    pea %fp@
    movew %a3,%sp@-
    movew %a5,%sp@-
    lea %pc@(DIAGROMENTRY_3E),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
DIAGROMENTRY_3E:        /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    nop
    lea %pc@(DIAGROMENTRY_54),%fp
    bigjmp USTINIT
DIAGROMENTRY_54:        /* set %a5@(8) */
    movew #4,%a5@(8)
    subal #55296,%sp
    movel %sp,%a5@(22)
    moveal %a5@(22),%a0
    movel #55296,%sp@-
    pea %a0@
    bigjsr GI_InitInterface
    addql #8,%sp
    movel %a5,%sp@-
    moveq #0,%d2
    lea %pc@(DIAGROMENTRY_8E),%fp
    bigjmp hardware_table_lookup_40847568
DIAGROMENTRY_8E:        /* set %a2 */
    moveal %a0@(8),%a2
    moveal %sp,%fp
    moveaw #60,%a3
    moveaw #4,%a5
    movel %a3,%sp@-
    pea %fp@
    movew %a3,%sp@-
    movew %a5,%sp@-
    lea %pc@(DIAGROMENTRY_B6),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
DIAGROMENTRY_B6:        /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    lea %sp@(4),%sp
    movel %sp,%sp@-
    moveq #0,%d2
    lea %pc@(DIAGROMENTRY_D2),%fp
    bigjmp hardware_table_lookup_40847568
DIAGROMENTRY_D2:        /* set %a2 */
    moveal %a0@(8),%a2
    moveal %sp,%fp
    moveaw #68,%a3
    moveaw #4,%a5
    movel %a3,%sp@-
    pea %fp@
    movew %a3,%sp@-
    movew %a5,%sp@-
    lea %pc@(DIAGROMENTRY_FA),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
DIAGROMENTRY_FA:        /* (data) */
    lea %sp@(8),%sp	| 408BAB06
    moveal %sp@+,%a3	| 408BAB0A
    lea %sp@(4),%sp	| 408BAB0C
    bral DIAGROMENTRY_200	| 408BAB10
DIAGROMENTRY_10A:       /* set %a4 */
    moveal %sp,%a4
    movel %d7,%d4
    andil #983040,%d4
    cmpil #131072,%d4
    bnel DIAGROMENTRY_24E
    movel %d7,%d4
    andil #255,%d4
    lea %pc@(DIAGROMENTRY_288),%a5
    lslw #2,%d4
    movel %a5@(0x0,%d4:w),%d4
    jmp %a5@(0x0,%d4:w)
    .short  0x4E71, 0x4E71, 0x4E71, 0x4E71	| 408BAB42
DIAGROMENTRY_13E:       /* address %pc@(DIAGROMENTRY_14C) */
    lea %pc@(DIAGROMENTRY_14C),%fp
    bigjmp thunk_FUN_408a0000
DIAGROMENTRY_14C:       /* continue at DIAGROMENTRY_200 */
    bral DIAGROMENTRY_200
DIAGROMENTRY_152:       /* clear %d0 */
    moveq #0,%d0
    lslw #8,%d7
    moveb %d0,%d7
DIAGROMENTRY_158:       /* loop: lea */
    lea %pc@(DIAGROMENTRY_166),%fp
    bigjmp thunk_FUN_408a0000
DIAGROMENTRY_166:       /* test %d6 */
    tstl %d6
    bnel DIAGROMENTRY_200
    moveal %sp@,%a2
    moveq #0,%d0
    moveb %d7,%d0
    lsrw #8,%d7
    moveal %a2@(0x0,%d0:w),%a0
    cmpaw #-1,%a0
    beql DIAGROMENTRY_200
    moveal %a2@(0x0,%d0:w),%a1
    addqw #4,%d0
    addal %a2@(0x0,%d0:w),%a1
    lea %pc@(USTSTRT1_3F0),%a5
    addal %a5@(0x0,%d7:w:4),%a5
    lslw #8,%d7
    moveb %d0,%d7
    lea %pc@(DIAGROMENTRY_1A0),%fp
    jmp %a5@
DIAGROMENTRY_1A0:       /* (data) */
    tstl %d6	| 408BABAC
    bnel DIAGROMENTRY_200	| 408BABAE
    addqb #4,%d7	| 408BABB4
    jbra DIAGROMENTRY_158	| 408BABB6
DIAGROMENTRY_1AC:       /* address %pc@(DIAGROMENTRY_1BA) */
    lea %pc@(DIAGROMENTRY_1BA),%fp
    bigjmp thunk_FUN_408a0000
DIAGROMENTRY_1BA:       /* test %d6 */
    tstl %d6
    bnew DIAGROMENTRY_200
    moveal %sp@,%a0
    lea %pc@(DIAGROMENTRY_1D0),%fp
    bigjmp DATABUSTEST, a1
DIAGROMENTRY_1D0:       /* (data) */
    bral DIAGROMENTRY_200	| 408BABDC
DIAGROMENTRY_1D6:       /* address %pc@(DIAGROMENTRY_1E4) */
    lea %pc@(DIAGROMENTRY_1E4),%fp
    bigjmp thunk_FUN_408a0000
DIAGROMENTRY_1E4:       /* test %d6 */
    tstl %d6
    bnew DIAGROMENTRY_200
    moveal %sp@,%a0
    lea %pc@(DIAGROMENTRY_200),%fp
    lea %pc@(USTSTRT1_3F0),%a5
    andil #255,%d7
    addal %a5@(0x0,%d7:w:4),%a5
    jmp %a5@
DIAGROMENTRY_200:       /* clear %d2 */
    moveq #0,%d2
    lea %pc@(DIAGROMENTRY_210),%fp
    bigjmp hardware_table_lookup_40847568
DIAGROMENTRY_210:       /* set %a2 */
    moveal %a0@(8),%a2
    moveaw #16,%a3
    moveaw #16,%a4
    moveaw #56,%a5
    movel %a3,%sp@-
    movew %a4,%sp@-
    pea %a3@
    movew %a5,%sp@-
    lea %pc@(DIAGROMENTRY_23A),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
DIAGROMENTRY_23A:       /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    moveaw #16,%a3
    moveml %a3@,%d0-%d5/%d7-%a2/%a4-%sp
    lea %pc@(DIAGROMENTRY),%a3
    jmp %fp@
DIAGROMENTRY_24E:       /* set %d0 */
    movel %d7,%d0
    lea %pc@(DIAGROMENTRY_2A4),%a0
    andil #983040,%d7
    cmpil #65536,%d7
    jbne DIAGROMENTRY_26C
    lea %pc@(USTMAINTEST_72),%a0
    subil #65536,%d0
DIAGROMENTRY_26C:       /* set %a5@ */
    movel %sp@+,%a5@
    movel %a5@(22),%sp@-
    lsll #2,%d0
    movel %a0@(0x0,%d0:l),%d0
    jsr %a0@(0x0,%d0:l)
    addql #4,%sp
    movel %d0,%d6
    moveal %a5@,%a0
    lea %pc@(DIAGROMENTRY),%a3
    jmp %a0@
DIAGROMENTRY_288:       /* (data) */
    .long   DIAGROMENTRY_13E-DIAGROMENTRY_288	| 408BAC94
    .long   DIAGROMENTRY_1AC-DIAGROMENTRY_288	| 408BAC98
    .long   DIAGROMENTRY_152-DIAGROMENTRY_288	| 408BAC9C
    .long   DIAGROMENTRY_1D6-DIAGROMENTRY_288	| 408BACA0
    .long   DIAGROMENTRY_1D6-DIAGROMENTRY_288	| 408BACA4
    .long   DIAGROMENTRY_152-DIAGROMENTRY_288	| 408BACA8
    .long   DIAGROMENTRY_152-DIAGROMENTRY_288	| 408BACAC
DIAGROMENTRY_2A4:       /* (data) */
    .long   0x00000000, 0x00000010	| 408BACB0
    .long   DIAGROMENTRY_310-DIAGROMENTRY_2A4	| 408BACB8
    .long   DIAGROMENTRY_354-DIAGROMENTRY_2A4	| 408BACBC
    linkw %fp,#0
    movel %fp@(12),%d4
    movel %fp@(16),%d5
    movel %fp,%sp@-
    lea %pc@(DIAGROMENTRY_2A4_26),%fp
    jmp %pc@(SETUPFOREXECUTEDTM)
DIAGROMENTRY_2A4_26:
    moveal %sp@,%fp
    cmpil #-1,%a5@(90)
    beqs DIAGROMENTRY_2A4_62
    cmpil #-1,%a5@(110)
    beqs DIAGROMENTRY_2A4_62
    moveal %fp@(8),%a3
    pea %a5@(122)
    pea %a5@(102)
    pea %a5@(82)
    pea %a5@(46)
    pea %a3@
DIAGROMENTRY_2A4_52:
    lea 0x13cbe,%a0
    jsr %pc@(DIAGROMENTRY_2A4_52,%a0:l)
    addaw #20,%sp
    bras DIAGROMENTRY_2A4_64
DIAGROMENTRY_2A4_62:
    moveq #-1,%d0
DIAGROMENTRY_2A4_64:
    moveal %sp@+,%fp
    movel %d0,%d6
    unlk %fp
    rts

DIAGROMENTRY_310:       /* entry: stack frame */
    linkw %fp,#0
    moveal %a5@(34),%a0
    moveal %a5@(38),%a1
    moveal %a0@(8),%a2
    moveal %fp@(14),%a3
    moveml %fp,%sp@-
    movel %a3,%sp@-
    movew %fp@(18),%sp@-
    pea %a3@
    movew %fp@(12),%sp@-
    lea %pc@(DIAGROMENTRY_346),%a3
    movel %a3,%sp@-
    biglea COPYPRAMTORAM, a3
    jmp %a3@
DIAGROMENTRY_346:       /* address %sp@(8) */
    lea %sp@(8),%sp
    moveal %sp@+,%a3
    moveml %sp@+,%fp
    unlk %fp
    rts

DIAGROMENTRY_354:       /* entry: stack frame */
    linkw %fp,#0
    moveal %a5@(34),%a0
    moveal %a5@(38),%a1
    moveal %a0@(8),%a2
    moveml %a5-%fp,%sp@-
    lea %pc@(DIAGROMENTRY_376),%fp
    bigjmp CLKWPOFF, a5
DIAGROMENTRY_376:       /* restore registers */
    moveml %sp@+,%a5-%fp
    moveal %fp@(16),%a3
    moveml %fp,%sp@-
    movel %a3,%sp@-
    pea %a3@
    movew %fp@(14),%sp@-
    movew %fp@(12),%sp@-
    lea %pc@(DIAGROMENTRY_3A0),%a3
    movel %a3,%sp@-
    biglea COPYRAMTOPRAM, a3
    jmp %a3@
DIAGROMENTRY_3A0:       /* (data) */
    lea %sp@(8),%sp	| 408BADAC
    moveal %sp@+,%a3	| 408BADB0
    moveml %sp@+,%fp	| 408BADB2
    unlk %fp	| 408BADB6
    rts	| 408BADB8

/* SETUPFOREXECUTEDTM: prepare to run a test module. */
SETUPFOREXECUTEDTM:
    biglea USTSTRT
    movel %a0,%d1
    movel %d5,%d3
SETUPFOREXECUTEDTM_E:   /* loop: cmp */
    cmpl %a0@,%d3
    jbeq SETUPFOREXECUTEDTM_20
    lea %a0@(24),%a0
    cmpil #-1,%a0@
    jbne SETUPFOREXECUTEDTM_E
    jbra SETUPFOREXECUTEDTM_42
SETUPFOREXECUTEDTM_20:  /* set %a1 */
    moveal %a5@(18),%a1
SETUPFOREXECUTEDTM_24:  /* loop: cmp */
    cmpw %a1@(2),%d4
    jbeq SETUPFOREXECUTEDTM_38
    cmpiw #-1,%a1@(2)
    jbeq SETUPFOREXECUTEDTM_42
    addaw #10,%a1
    jbra SETUPFOREXECUTEDTM_24
SETUPFOREXECUTEDTM_38:  /* set %d2 */
    movew %a1@(4),%d2
    andw %a5@(8),%d2
    jbne SETUPFOREXECUTEDTM_50
SETUPFOREXECUTEDTM_42:  /* set %a5@(90) */
    movel #-1,%a5@(90)
    bral SETUPFOREXECUTEDTM_DC
SETUPFOREXECUTEDTM_50:  /* set %a1 */
    moveal %a0@(4),%a1
    addal %d1,%a1
    movel %a1,%a5@(90)
    movel %d5,%a5@(86)
    clrl %a5@(82)
    movel %a0@(16),%a5@(94)
    movel %a0@(20),%a5@(98)
    biglea USTSUBTESTS
    movel %a0,%d1
    movel %d4,%d3
SETUPFOREXECUTEDTM_7C:  /* loop: cmp */
    cmpl %a0@,%d3
    jbeq SETUPFOREXECUTEDTM_96
    lea %a0@(24),%a0
    cmpil #-1,%a0@
    jbne SETUPFOREXECUTEDTM_7C
    movel #-1,%a5@(110)
    jbra SETUPFOREXECUTEDTM_DC
SETUPFOREXECUTEDTM_96:  /* set %a1 */
    moveal %a0@(4),%a1
    addal %d1,%a1
    movel %a1,%a5@(110)
    movel %d4,%a5@(106)
    clrl %a5@(102)
    movel %a0@(16),%a5@(114)
    movel %a0@(20),%a5@(118)
    movel %a5,%a5@(46)
    movel #4,%a5@(50)
    clrl %a5@(54)
    clrl %a5@(58)
    clrl %a5@(62)
    clrl %a5@(66)
    clrl %a5@(70)
    clrl %a5@(74)
    clrl %a5@(78)
SETUPFOREXECUTEDTM_DC:  /* jump through %fp@ */
    jmp %fp@
    .fill   0x23B8, 1, 0x00
