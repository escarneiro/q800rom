/*
 quickdraw/ovals.s - ovals and arcs
 From GSRUNTBL (0x4083B084). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* GSRUNTBL: table. */
trap_GSRUNTBL:
GSRUNTBL:
    .short  0x0000, 0x03AC	| orib #0xac,%d0
    .short  0x0000, 0x043C	| orib #60,%d0
    .short  0x0000, 0x04FC	| orib #0xfc,%d0
    .short  0x0000, 0x059C	| orib #0x9c,%d0
    .short  0x0000, 0x07DC	| orib #0xdc,%d0
    .short  0x0000, 0x091C	| orib #28,%d0

/* GSEXPTBL: table. */
trap_GSEXPTBL:
GSEXPTBL:
    .short  0x0000, 0x02D4	| orib #0xd4,%d0
    .short  0x0000, 0x02E4	| orib #0xe4,%d0
    .short  0x0000, 0x0324	| orib #36,%d0
    .short  0x0000, 0x0344	| orib #68,%d0
    .short  0x0000, 0x0364	| orib #100,%d0
    .short  0x0000, 0x0384	| orib #0x84,%d0

/* GSSEEKTBL: table. */
trap_GSSEEKTBL:
GSSEEKTBL:
    orib #32,%d0
    orib #44,%d0
    orib #108,%d0
    orib #120,%d0
    .short  0x0000, 0x01EC	| orib #0xec,%d0
    .short  0x0000, 0x01EC	| orib #0xec,%d0
    .short  0x0000, 0x010C	| orib #12,%d0
    .short  0x0000, 0x010C	| orib #12,%d0
    movew #32767,%d2
    rts
    .short  0x0000, 0x0000, 0x0000	| 4083B0DA
    moveml %d3-%d5/%a4-%fp,%sp@-
    moveal %fp@(-52),%a1
    movel %fp@(-32),%d0
    movew %fp@(-48),%d1
    movel %fp@(-36),%d5
    moveal %fp@(-8),%a0
    moveal %fp@(-20),%a4
    lea %pc@(GSSEEKTBL_5A),%a5
    moveal %d0,%fp
    moveq #0,%d2
GSSEEKTBL_50:           /* seek procs for one region: each long of the scan, shifted to the destination, through the run builder (a4) */
    bfextu %fp@,%d5,0,%d0
    addqw #4,%fp
    andl %a1@+,%d0
    jmp %a4@
GSSEEKTBL_5A:           /* next long; restore */
    dbf %d1,GSSEEKTBL_50
    moveml %sp@+,%d3-%d5/%a4-%fp
GSSEEKTBL_62:           /* d2 = 1: the mask changed; then the one-region seek: SEEKRGN to the row */
    moveq #1,%d2
    rts
    .short  0x0000, 0x0000, 0x0000	| 4083B11A
    lea %fp@(-60),%a1
    movew %fp@(-4),%d0
    jmp %pc@(trap_SEEKRGN)
    .long   0x302EFFFC	| 4083B12C
    cmpw %fp@(-44),%d0
    jbge GSSEEKTBL_98
    cmpw %fp@(-46),%d0
    jblt GSSEEKTBL_A2
    tstl %fp@(-32)
    jbeq GSSEEKTBL_62
GSSEEKTBL_8E:           /* the scan buffer and its length */
    moveal %fp@(-52),%a1
    movew %fp@(-48),%d1
    jbra GSSEEKTBL_AC
GSSEEKTBL_98:           /* seek down */
    lea %fp@(-60),%a1
    jsr %pc@(SEEKDOWN)
    jbra GSSEEKTBL_8E
GSSEEKTBL_A2:           /* seek up */
    lea %fp@(-60),%a1
    jsr %pc@(SEEKUP)
    jbra GSSEEKTBL_8E
GSSEEKTBL_AC:           /* build the row's runs from the scan: aligned? each long directly */
    movel %fp@(-32),%d0
    jbne GSSEEKTBL_D2
    moveml %d2-%d4/%a4-%a5,%sp@-
    moveal %fp@(-8),%a0
    moveal %fp@(-20),%a4
    lea %pc@(GSSEEKTBL_C8),%a5
    moveq #0,%d2
GSSEEKTBL_C4:           /* each long through the run builder */
    movel %a1@+,%d0
    jmp %a4@
GSSEEKTBL_C8:           /* next long */
    dbf %d1,GSSEEKTBL_C4	| 4083B17C
    moveml %sp@+,%d2-%d4/%a4-%a5	| 4083B180
    rts	| 4083B184

GSSEEKTBL_D2:           /* save registers */
    moveml %d3-%d5/%a4-%fp,%sp@-
    moveal %fp@(-8),%a0
    moveal %fp@(-20),%a4
    lea %pc@(GSSEEKTBL_F4),%a5
    movel %fp@(-36),%d5
    moveal %d0,%fp
    moveq #0,%d2
GSSEEKTBL_EA:           /* unaligned: each long extracted at the bit offset */
    bfextu %fp@,%d5,0,%d0
    addqw #4,%fp
    andl %a1@+,%d0
    jmp %a4@
GSSEEKTBL_F4:           /* next long; then the two-region seek: both regions to the row */
    dbf %d1,GSSEEKTBL_EA	| 4083B1A8
    moveml %sp@+,%d3-%d5/%a4-%fp	| 4083B1AC
    moveq #1,%d2	| 4083B1B0
    rts	| 4083B1B2
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B1B4
    movew %fp@(-4),%d0
    lea %fp@(-60),%a1
    jbsr GSSEEKTBL_170
    movew %d2,%sp@-
    lea %fp@(-84),%a1
    jbsr GSSEEKTBL_170
    movew %sp@+,%d1
    cmpw %d2,%d1
    jbgt GSSEEKTBL_126
    movew %d1,%d2
GSSEEKTBL_126:          /* the two scans; a run builder? */
    moveal %fp@(-52),%a2
    moveal %fp@(-76),%a1
    movew %fp@(-48),%d1
    moveal %fp@(-8),%a0
    movel %fp@(-20),%d0
    jbne GSSEEKTBL_196
GSSEEKTBL_13C:          /* no builder: the mask = scan A and scan B, long by long */
    movel %fp@(-32),%d0
    jbne GSSEEKTBL_14E
    movel %a2@+,%d0
    andl %a1@+,%d0
    movel %d0,%a0@+
    dbf %d1,GSSEEKTBL_13C
    rts
GSSEEKTBL_14E:          /* shifted */
    moveml %d5/%fp,%sp@-
    movel %fp@(-36),%d5
    moveal %d0,%fp
GSSEEKTBL_158:          /* A (shifted) and B */
    bfextu %fp@,%d5,0,%d0
    addqw #4,%fp
    andl %a2@+,%d0
    andl %a1@+,%d0
    movel %d0,%a0@+
    dbf %d1,GSSEEKTBL_158
    moveml %sp@+,%d5/%fp
    moveq #1,%d2
    rts

GSSEEKTBL_170:          /* seek one region state (a1) to row d0, up or down; d2 = whether it changed */
    cmpw %a1@(16),%d0
    jbge SEEKDOWN
    cmpw %a1@(14),%d0
    jblt SEEKUP
    movew %a1@(16),%d2
    subw %d0,%d2
    tstl %fp@(-124)
    jbpl GSSEEKTBL_194
    movew %d0,%d2
    subw %a1@(14),%d2
    addqw #1,%d2
GSSEEKTBL_194:          /* return */
    rts

GSSEEKTBL_196:          /* save registers */
    moveml %d2-%d5/%a4-%fp,%sp@-
    movel %fp@(-32),%d2
    jbne GSSEEKTBL_1B8
    moveal %d0,%a4
    lea %pc@(GSSEEKTBL_1AE),%a5
    moveq #0,%d2
GSSEEKTBL_1A8:          /* A and B through the run builder */
    movel %a2@+,%d0
    andl %a1@+,%d0
    jmp %a4@
GSSEEKTBL_1AE:          /* next long */
    dbf %d1,GSSEEKTBL_1A8
    moveml %sp@+,%d2-%d5/%a4-%fp
    rts
GSSEEKTBL_1B8:          /* shifted */
    moveal %d0,%a4
    lea %pc@(GSSEEKTBL_1D2),%a5
    movel %fp@(-36),%d5
    moveal %d2,%fp
    moveq #0,%d2
GSSEEKTBL_1C6:          /* A (shifted) and B through the run builder */
    bfextu %fp@,%d5,0,%d0
    addqw #4,%fp
    andl %a2@+,%d0
    andl %a1@+,%d0
    jmp %a4@
GSSEEKTBL_1D2:          /* next long; then the three-region version: A and B and C */
    dbf %d1,GSSEEKTBL_1C6	| 4083B286
    moveml %sp@+,%d2-%d5/%a4-%fp	| 4083B28A
    moveq #1,%d2	| 4083B28E
    rts	| 4083B290
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B292
    /* three regions: seek each state to row fp-4 (_170); d2 = the smallest of the three results */
    movew %fp@(-4),%d0
    lea %fp@(-60),%a1
    bsrw GSSEEKTBL_170
    movew %d2,%sp@-
    lea %fp@(-84),%a1
    bsrw GSSEEKTBL_170
    movew %d2,%sp@-
    lea %fp@(-108),%a1
    bsrw GSSEEKTBL_170
    movew %sp@+,%d1
    cmpw %d2,%d1
    bgts GSSEEKTBL_1D2_42
    movew %d1,%d2
GSSEEKTBL_1D2_42:
    movew %sp@+,%d1	| 4083B2C8
    cmpw %d2,%d1
    bgts GSSEEKTBL_1D2+0x4a
    movew %d1,%d2
    moveal %fp@(-52),%a3
    moveal %fp@(-76),%a2
    moveal %fp@(-100),%a1
    moveal %fp@(-8),%a0
    movew %fp@(-96),%d1
    movel %fp@(-20),%d0
    bnew GSSEEKTBL_270
    movel %fp@(-32),%d0
    jbne GSSEEKTBL_24C
GSSEEKTBL_23E:          /* A and B and C into the mask */
    movel %a3@+,%d0
    andl %a2@+,%d0
    andl %a1@+,%d0
    movel %d0,%a0@+
    dbf %d1,GSSEEKTBL_23E
    rts

GSSEEKTBL_24C:          /* save registers */
    moveml %d5/%fp,%sp@-
    movel %fp@(-36),%d5
    moveal %d0,%fp
GSSEEKTBL_256:          /* shifted */
    bfextu %fp@,%d5,0,%d0
    addqw #4,%fp
    andl %a3@+,%d0
    andl %a2@+,%d0
    andl %a1@+,%d0
    movel %d0,%a0@+
    dbf %d1,GSSEEKTBL_256
    moveml %sp@+,%d5/%fp
    moveq #1,%d2
    rts

GSSEEKTBL_270:          /* save registers */
    moveml %d2-%d5/%a4-%fp,%sp@-
    movel %fp@(-32),%d2
    jbne GSSEEKTBL_294
    moveal %d0,%a4
    lea %pc@(GSSEEKTBL_28A),%a5
    moveq #0,%d2
GSSEEKTBL_282:          /* through the run builder */
    movel %a3@+,%d0
    andl %a2@+,%d0
    andl %a1@+,%d0
    jmp %a4@
GSSEEKTBL_28A:          /* next long */
    dbf %d1,GSSEEKTBL_282	| 4083B33E
    moveml %sp@+,%d2-%d5/%a4-%fp	| 4083B342
    rts	| 4083B346
GSSEEKTBL_294:          /* shifted */
    moveal %d0,%a4
    lea %pc@(GSSEEKTBL_2B0),%a5
    movel %fp@(-36),%d5
    moveal %d2,%fp
    moveq #0,%d2
GSSEEKTBL_2A2:          /* shifted, through the run builder */
    bfextu %fp@,%d5,0,%d0
    addqw #4,%fp
    andl %a3@+,%d0
    andl %a2@+,%d0
    andl %a1@+,%d0
    jmp %a4@
GSSEEKTBL_2B0:          /* next long; then the run builders (store a long; expand nibbles) */
    dbf %d1,GSSEEKTBL_2A2	| 4083B364
    moveml %sp@+,%d2-%d5/%a4-%fp	| 4083B368
    moveq #1,%d2	| 4083B36C
    rts	| 4083B36E
    movel %d0,%a0@+
    jmp %a5@
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B374
    /* expand a long of mask through TABLE2 (each byte to a word) into two longs; a5 is kept while it points at the table */
    movel %a5,%sp@-
    lea %pc@(TABLE2),%a5
    clrw %d2
    moveb %d0,%d2
    movew %a5@(0x0,%d2:w:2),%d4
    swap %d0
    moveb %d0,%d2
    movew %a5@(0x0,%d2:w:2),%d3
    lsrl #8,%d0
    moveb %d0,%d2
    swap %d3
    movew %a5@(0x0,%d2:w:2),%d3
    swap %d3
    swap %d0
    moveb %d0,%d2
    swap %d4
    movew %a5@(0x0,%d2:w:2),%d4
    swap %d4
    movel %d3,%a0@+
    movel %d4,%a0@+
    moveal %sp@+,%a5
    jmp %a5@
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B3B6
    /* expand a long of mask through TABLE4 (each byte to a long) */
    moveq #3,%d3	| 4083B3C0
GSSEEKTBL_2B0_5E:
    roll #8,%d0	| 4083B3C2
    moveb %d0,%d2
    movel %pc@(TABLE4,%d2:w:4),%a0@+
    dbf %d3,GSSEEKTBL_2B0_5E
    jmp %a5@
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B3D2
    moveq #3,%d3
GSSEEKTBL_32E:          /* expand a long of 1-bit mask into longs of pixels, a nibble at a time (table GSSEEKTBL_6AC) */
    roll #8,%d0
    moveb %d0,%d2
    lsrw #4,%d2
    movel %pc@(GSSEEKTBL_6AC,%d2:w:4),%a0@+
    moveq #15,%d2
    andw %d0,%d2
    movel %pc@(GSSEEKTBL_6AC,%d2:w:4),%a0@+
    dbf %d3,GSSEEKTBL_32E
    jmp %a5@
    .byte   0x00, 0x00	| 4083B3FE
    moveq #15,%d3
GSSEEKTBL_32E_20:       /* expand each pair of mask bits into a 16-bit pixel mask long */
    addl %d0,%d0
    subxl %d2,%d2
    addl %d0,%d0
    subxw %d2,%d2
    movel %d2,%a0@+
    dbf %d3,GSSEEKTBL_32E_20
    jmp %a5@
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B412
    /* each mask bit to a long of 0 or -1 */
    moveq #31,%d3
GSSEEKTBL_32E_20_20:
    addl %d0,%d0	| 4083B422
    subxl %d2,%d2
    movel %d2,%a0@+
    dbf %d3,GSSEEKTBL_32E_20_20
    jmp %a5@
    .byte   0x00, 0x00	| 4083B42E
    /* run builder for 1-bit pixels, from a mask of longs. A long of 0 is skipped, -1 makes a solid run, anything else is copied. A run long holds the offset in its low word and the count in its high word; bit 30 means the mask longs follow it. fp-120 negative: the row is read from its end */
    moveal %fp@(-8),%a0	| 4083B430
    moveml %d1/%d3-%d6,%sp@-
    moveal %fp@(-12),%a2
    movew %fp@(-16),%d5
    moveq #-1,%d1
    moveq #1,%d4
    swap %d4
    movel %a0@+,%d0
    movew %fp@(-120),%d6
    bpls GSSEEKTBL_32E_20_20_3C
    moveq #0,%d0
    movew %d5,%d0
    asll #2,%d0
    addal %d0,%a0
    movel %d0,%d3
    movel %a0@-,%d0
    addaw %d6,%a0
    bras GSSEEKTBL_32E_20_20_3E
GSSEEKTBL_32E_20_20_3C: /* a new run: the offset is counted from the end of the previous one */
    moveq #0,%d3	| 4083B45E
GSSEEKTBL_32E_20_20_3E: /* this long: 0 skips, -1 is solid, else a run of mask longs with a header at a1 */
    tstl %d0	| 4083B460
    beqs GSSEEKTBL_32E_20_20_78
GSSEEKTBL_32E_20_20_42:
    cmpl %d1,%d0	| 4083B464
    beqs GSSEEKTBL_32E_20_20_8A
    moveal %a2,%a1
    addqw #4,%a2
    bras GSSEEKTBL_32E_20_20_58
GSSEEKTBL_32E_20_20_4C: /* next long of a masked run; 0 or -1 ends it */
    movel %a0@,%d0	| 4083B46E
    addaw %d6,%a0
    beqs GSSEEKTBL_32E_20_20_66
    cmpl %d1,%d0
    beqs GSSEEKTBL_32E_20_20_66
    addl %d4,%d3
GSSEEKTBL_32E_20_20_58: /* store the mask long; end of the row: close the header */
    movel %d0,%a2@+	| 4083B47A
    dbf %d5,GSSEEKTBL_32E_20_20_4C
    bset #30,%d3
    movel %d3,%a1@
    bras GSSEEKTBL_32E_20_20_90
GSSEEKTBL_32E_20_20_66: /* run ended: close its header, test this long again */
    bset #30,%d3	| 4083B488
    movel %d3,%a1@
    bras GSSEEKTBL_32E_20_20_3C
GSSEEKTBL_32E_20_20_6E: /* store the header of a solid run */
    movel %d3,%a2@+	| 4083B490
    bras GSSEEKTBL_32E_20_20_3C
GSSEEKTBL_32E_20_20_72: /* next long while skipping */
    movel %a0@,%d0	| 4083B494
    addaw %d6,%a0
    bnes GSSEEKTBL_32E_20_20_42
GSSEEKTBL_32E_20_20_78: /* advance the offset by the step (d6) */
    addw %d6,%d3	| 4083B49A
    dbf %d5,GSSEEKTBL_32E_20_20_72
    bras GSSEEKTBL_32E_20_20_90
GSSEEKTBL_32E_20_20_80: /* next long while solid */
    movel %a0@,%d0	| 4083B4A2
    addaw %d6,%a0
    cmpl %d1,%d0
    bnes GSSEEKTBL_32E_20_20_6E
    addl %d4,%d3
GSSEEKTBL_32E_20_20_8A: /* count it */
    dbf %d5,GSSEEKTBL_32E_20_20_80	| 4083B4AC
    movel %d3,%a2@+
GSSEEKTBL_32E_20_20_90: /* end marker -1, return */
    movel %d1,%a2@	| 4083B4B2
    moveml %sp@+,%d1/%d3-%d6
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B4BA
    /* the same run builder for 2-bit pixels, from a mask of words: a word of 0 is skipped, -1 is solid, anything else is widened through TABLE2 to a long */
    moveal %fp@(-8),%a0	| 4083B4C0
    moveml %d1-%d7/%a3-%a5,%sp@-
    moveal %fp@(-12),%a2
    movew %fp@(-16),%d5
    lea %pc@(TABLE2),%a4
    moveq #-1,%d1
    moveq #1,%d4
    swap %d4
    moveal %d4,%a5
    moveq #15,%d4
    moveq #0,%d6
    movew %a0@+,%d0
    movew %fp@(-120),%d2
    moveaw %d2,%a3
    asrw #1,%d2
    bpls GSSEEKTBL_32E_20_20_90_52
    addqw #2,%d5
    andiw #-2,%d5
    moveq #0,%d0
    movew %d5,%d0
    addl %d0,%d0
    addal %d0,%a0
    addl %d0,%d0
    movel %d0,%d3
    movew %a0@-,%d0
    subqw #2,%a0
    bras GSSEEKTBL_32E_20_20_90_56
GSSEEKTBL_32E_20_20_90_52:
    moveq #0,%d3	| 4083B504
    tstw %d0
GSSEEKTBL_32E_20_20_90_56:
    beqs GSSEEKTBL_32E_20_20_90_A0	| 4083B508
GSSEEKTBL_32E_20_20_90_58:
    cmpw %d1,%d0	| 4083B50A
    beqs GSSEEKTBL_32E_20_20_90_B2
    moveal %a2,%a1
    addql #4,%a2
    bras GSSEEKTBL_32E_20_20_90_6E
GSSEEKTBL_32E_20_20_90_62:
    movew %a0@,%d0	| 4083B514
    addaw %d2,%a0
    beqs GSSEEKTBL_32E_20_20_90_8E
    cmpw %d1,%d0
    beqs GSSEEKTBL_32E_20_20_90_8E
    addl %a5,%d3
GSSEEKTBL_32E_20_20_90_6E:
    moveb %d0,%d6	| 4083B520
    movew %a4@(0x0,%d6:w:2),%d7
    swap %d7
    rolw #8,%d0
    moveb %d0,%d6
    movew %a4@(0x0,%d6:w:2),%d7
    swap %d7
    movel %d7,%a2@+
    dbf %d5,GSSEEKTBL_32E_20_20_90_62
    bset #30,%d3
    movel %d3,%a1@
    bras GSSEEKTBL_32E_20_20_90_B8
GSSEEKTBL_32E_20_20_90_8E:
    bset #30,%d3	| 4083B540
    movel %d3,%a1@
    bras GSSEEKTBL_32E_20_20_90_52
GSSEEKTBL_32E_20_20_90_96:
    movel %d3,%a2@+	| 4083B548
    bras GSSEEKTBL_32E_20_20_90_52
GSSEEKTBL_32E_20_20_90_9A:
    movew %a0@,%d0	| 4083B54C
    addaw %d2,%a0
    bnes GSSEEKTBL_32E_20_20_90_58
GSSEEKTBL_32E_20_20_90_A0:
    addw %a3,%d3	| 4083B552
    dbf %d5,GSSEEKTBL_32E_20_20_90_9A
    bras GSSEEKTBL_32E_20_20_90_B8
GSSEEKTBL_32E_20_20_90_A8:
    movew %a0@,%d0	| 4083B55A
    addaw %d2,%a0
    cmpw %d1,%d0
    bnes GSSEEKTBL_32E_20_20_90_96
    addl %a5,%d3
GSSEEKTBL_32E_20_20_90_B2:
    dbf %d5,GSSEEKTBL_32E_20_20_90_A8	| 4083B564
    movel %d3,%a2@+
GSSEEKTBL_32E_20_20_90_B8:
    movel %d1,%a2@	| 4083B56A
    moveml %sp@+,%d1-%d7/%a3-%a5
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B572
    /* the same run builder for 4-bit pixels, from a mask of bytes: anything but 0 or -1 goes through TABLE4 to a long */
    moveal %fp@(-8),%a0	| 4083B580
    moveml %d1-%d7/%a3-%a4,%sp@-
    moveal %fp@(-12),%a2
    movew %fp@(-16),%d5
    lea %pc@(TABLE4),%a4
    moveq #-1,%d1
    moveq #1,%d4
    swap %d4
    moveq #0,%d6
    moveb %a0@+,%d0
    movew %fp@(-120),%d2
    moveaw %d2,%a3
    asrw #2,%d2
    bpls GSSEEKTBL_32E_20_20_90_10C
    addqw #4,%d5
    andiw #-4,%d5
    moveq #0,%d0
    movew %d5,%d0
    addal %d0,%a0
    lsll #2,%d0
    movel %d0,%d3
    moveb %a0@-,%d0
    subqw #1,%a0
    bras GSSEEKTBL_32E_20_20_90_110
GSSEEKTBL_32E_20_20_90_10C:
    moveq #0,%d3	| 4083B5BE
    tstb %d0
GSSEEKTBL_32E_20_20_90_110:
    beqs GSSEEKTBL_32E_20_20_90_14C	| 4083B5C2
GSSEEKTBL_32E_20_20_90_112:
    cmpb %d1,%d0	| 4083B5C4
    beqs GSSEEKTBL_32E_20_20_90_15E
    moveal %a2,%a1
    addql #4,%a2
    bras GSSEEKTBL_32E_20_20_90_128
GSSEEKTBL_32E_20_20_90_11C:
    moveb %a0@,%d0	| 4083B5CE
    addaw %d2,%a0
    beqs GSSEEKTBL_32E_20_20_90_13A
    cmpb %d1,%d0
    beqs GSSEEKTBL_32E_20_20_90_13A
    addl %d4,%d3
GSSEEKTBL_32E_20_20_90_128:
    moveb %d0,%d6	| 4083B5DA
    movel %a4@(0x0,%d6:w:4),%a2@+
    dbf %d5,GSSEEKTBL_32E_20_20_90_11C
    bset #30,%d3
    movel %d3,%a1@
    bras GSSEEKTBL_32E_20_20_90_164
GSSEEKTBL_32E_20_20_90_13A:
    bset #30,%d3	| 4083B5EC
    movel %d3,%a1@
    bras GSSEEKTBL_32E_20_20_90_10C
GSSEEKTBL_32E_20_20_90_142:
    movel %d3,%a2@+	| 4083B5F4
    bras GSSEEKTBL_32E_20_20_90_10C
GSSEEKTBL_32E_20_20_90_146:
    moveb %a0@,%d0	| 4083B5F8
    addaw %d2,%a0
    bnes GSSEEKTBL_32E_20_20_90_112
GSSEEKTBL_32E_20_20_90_14C:
    addw %a3,%d3	| 4083B5FE
    dbf %d5,GSSEEKTBL_32E_20_20_90_146
    bras GSSEEKTBL_32E_20_20_90_164
GSSEEKTBL_32E_20_20_90_154:
    moveb %a0@,%d0	| 4083B606
    addaw %d2,%a0
    cmpb %d1,%d0
    bnes GSSEEKTBL_32E_20_20_90_142
    addl %d4,%d3
GSSEEKTBL_32E_20_20_90_15E:
    dbf %d5,GSSEEKTBL_32E_20_20_90_154	| 4083B610
    movel %d3,%a2@+
GSSEEKTBL_32E_20_20_90_164:
    movel %d1,%a2@	| 4083B616
    moveml %sp@+,%d1-%d7/%a3-%a4
    rts
    .byte   0x00, 0x00	| 4083B61E
    tstw %fp@(-120)
    jbmi GSSEEKTBL_60C
    moveal %fp@(-8),%a0
    moveml %d1-%d6/%a4,%sp@-
    moveal %fp@(-12),%a2
    movew %fp@(-16),%d5
    lea %pc@(GSSEEKTBL_6AC),%a4
    lsrw #1,%d5
    moveq #-1,%d1
    moveq #2,%d4
    swap %d4
    moveq #0,%d6
    movel #65536,%d2
    moveb %a0@+,%d0
GSSEEKTBL_59A:          /* byte-mask run builder (8-bit pixels, left to right): a new run */
    movel %d2,%d3
    tstb %d0
    jbeq GSSEEKTBL_5E0
GSSEEKTBL_5A0:          /* all ones: a full run; else a masked run */
    cmpb %d1,%d0
    jbeq GSSEEKTBL_5F0
    moveal %a2,%a1
    addql #4,%a2
    jbra GSSEEKTBL_5B4
GSSEEKTBL_5AA:          /* masked run: next byte; empty or full ends it */
    moveb %a0@+,%d0
    jbeq GSSEEKTBL_5D0
    cmpb %d1,%d0
    jbeq GSSEEKTBL_5D0
    addl %d4,%d3
GSSEEKTBL_5B4:          /* store the expanded mask longs of the byte */
    moveb %d0,%d6
    lsrw #4,%d6
    movel %a4@(0x0,%d6:w:4),%a2@+
    moveq #15,%d6
    andw %d0,%d6
    movel %a4@(0x0,%d6:w:4),%a2@+
    dbf %d5,GSSEEKTBL_5AA
    bset #30,%d3
    movel %d3,%a1@
    jbra GSSEEKTBL_5F6
GSSEEKTBL_5D0:          /* end of a masked run: flag it (bit 30) */
    bset #30,%d3
    movel %d3,%a1@
    jbra GSSEEKTBL_59A
GSSEEKTBL_5D8:          /* end of a full run */
    movel %d3,%a2@+
    jbra GSSEEKTBL_59A
GSSEEKTBL_5DC:          /* skipping empty bytes */
    moveb %a0@+,%d0
    jbne GSSEEKTBL_5A0
GSSEEKTBL_5E0:          /* empty byte: advance the offset */
    addqw #8,%d3
    dbf %d5,GSSEEKTBL_5DC
    jbra GSSEEKTBL_5F6
GSSEEKTBL_5E8:          /* full run: count the full bytes */
    moveb %a0@+,%d0
    cmpb %d1,%d0
    jbne GSSEEKTBL_5D8
    addl %d4,%d3
GSSEEKTBL_5F0:          /* next */
    dbf %d5,GSSEEKTBL_5E8
    movel %d3,%a2@+
GSSEEKTBL_5F6:          /* end of the row (-1) */
    movel %d1,%a2@
    moveml %sp@+,%d1-%d6/%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083B6B2
GSSEEKTBL_60C:          /* the same, right to left */
    moveal %fp@(-8),%a0
    moveml %d1-%d6/%a4,%sp@-
    moveal %fp@(-12),%a2
    movew %fp@(-16),%d5
    lea %pc@(GSSEEKTBL_6AC),%a4
    moveq #-1,%d1
    moveq #2,%d4
    swap %d4
    moveq #0,%d6
    movel #65536,%d2
    movel %d2,%d3
    addqw #8,%d5
    andiw #-8,%d5
    movew %d5,%d3
    asrw #1,%d3
    addaw %d3,%a0
    lslw #3,%d3
    subqw #1,%d5
    subqw #4,%d3
    lsrw #1,%d5
    moveb %a0@-,%d0
    jbra GSSEEKTBL_64A
GSSEEKTBL_648:          /* new run */
    movel %d2,%d3
GSSEEKTBL_64A:          /* empty byte? */
    tstb %d0
    jbeq GSSEEKTBL_68E
GSSEEKTBL_64E:          /* full or masked */
    cmpb %d1,%d0
    jbeq GSSEEKTBL_69E
    moveal %a2,%a1
    addql #4,%a2
    jbra GSSEEKTBL_662
GSSEEKTBL_658:          /* masked run: previous byte */
    moveb %a0@-,%d0
    jbeq GSSEEKTBL_67E
    cmpb %d1,%d0
    jbeq GSSEEKTBL_67E
    addl %d4,%d3
GSSEEKTBL_662:          /* store the expanded mask longs */
    moveq #15,%d6
    andw %d0,%d6
    movel %a4@(0x0,%d6:w:4),%a2@+
    moveb %d0,%d6
    lsrw #4,%d6
    movel %a4@(0x0,%d6:w:4),%a2@+
    dbf %d5,GSSEEKTBL_658
    bset #30,%d3
    movel %d3,%a1@
    jbra GSSEEKTBL_6A4
GSSEEKTBL_67E:          /* end of a masked run */
    bset #30,%d3
    movel %d3,%a1@
    jbra GSSEEKTBL_648
GSSEEKTBL_686:          /* end of a full run */
    movel %d3,%a2@+
    jbra GSSEEKTBL_648
GSSEEKTBL_68A:          /* skipping empty bytes */
    moveb %a0@-,%d0
    jbne GSSEEKTBL_64E
GSSEEKTBL_68E:          /* empty byte */
    subqw #8,%d3
    dbf %d5,GSSEEKTBL_68A
    jbra GSSEEKTBL_6A4
GSSEEKTBL_696:          /* full run */
    moveb %a0@-,%d0
    cmpb %d1,%d0
    jbne GSSEEKTBL_686
    addl %d4,%d3
GSSEEKTBL_69E:          /* next */
    dbf %d5,GSSEEKTBL_696
    movel %d3,%a2@+
GSSEEKTBL_6A4:          /* end of the row */
    movel %d1,%a2@
    moveml %sp@+,%d1-%d6/%a4
    rts
GSSEEKTBL_6AC:          /* nibble to mask long table (data) */
    .long   0x00000000, 0x000000FF, 0x0000FF00, 0x0000FFFF	| 4083B760
    .long   0x00FF0000, 0x00FF00FF, 0x00FFFF00, 0x00FFFFFF	| 4083B770
    .long   0xFF000000, 0xFF0000FF, 0xFF00FF00, 0xFF00FFFF	| 4083B780
    .long   0xFFFF0000 /* number, not a label difference (was trap_RSUBPIN-.) */	| 4083B790
    .byte   0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF	| 4083B794
GSSEEKTBL_6AC_40:       /* bit-mask run builder, 16-bit pixels, left to right: d0 starts as a sentinel bit */
    moveal %fp@(-8),%a0	| 4083B7A0
    moveml %d3-%d5,%sp@-
    moveal %fp@(-12),%a2
    movew %fp@(-16),%d5
    moveq #1,%d4
    swap %d4
    moveq #1,%d0
    rorl #1,%d0
    moveq #0,%d3
GSSEEKTBL_706:          /* bit-mask run builder (16-bit pixels, left to right): next bit */
    addl %d0,%d0
    jbcc GSSEEKTBL_712
    jbne GSSEEKTBL_724
    movel %a0@+,%d0
    addxl %d0,%d0
    jbcs GSSEEKTBL_724
GSSEEKTBL_712:          /* next bit */
    addl %d0,%d0
    jbcc GSSEEKTBL_71C
    moveal %a2,%a1
    addql #4,%a2
    jbra GSSEEKTBL_748
GSSEEKTBL_71C:          /* empty pixel: advance */
    addqw #4,%d3
    dbf %d5,GSSEEKTBL_706
    jbra GSSEEKTBL_798
GSSEEKTBL_724:          /* two set bits: a full run */
    addl %d0,%d0
    jbcs GSSEEKTBL_792
GSSEEKTBL_728:          /* start a full run */
    moveal %a2,%a1
    addql #4,%a2
    jbra GSSEEKTBL_762
GSSEEKTBL_72E:          /* end a masked run before an empty pixel */
    bset #30,%d3
    movel %d3,%a1@
    moveq #0,%d3
    jbra GSSEEKTBL_71C
GSSEEKTBL_738:          /* end a masked run before a full one */
    bset #30,%d3
    movel %d3,%a1@
    moveq #0,%d3
    jbra GSSEEKTBL_792
GSSEEKTBL_742:          /* masked run: next bit */
    addl %d0,%d0
    jbcc GSSEEKTBL_72E
    addl %d4,%d3
GSSEEKTBL_748:          /* first pixel of the pair masked */
    movel #65535,%a2@+
    jbra GSSEEKTBL_768
GSSEEKTBL_750:          /* next pair */
    addl %d0,%d0
    jbcc GSSEEKTBL_742
    jbne GSSEEKTBL_75C
    movel %a0@+,%d0
    addxl %d0,%d0
    jbcc GSSEEKTBL_742
GSSEEKTBL_75C:          /* both set */
    addl %d0,%d0
    jbcs GSSEEKTBL_738
    addl %d4,%d3
GSSEEKTBL_762:          /* second pixel masked */
    movel #-65536,%a2@+
GSSEEKTBL_768:          /* next pair; end of the row */
    dbf %d5,GSSEEKTBL_750
    bset #30,%d3
    movel %d3,%a1@
    jbra GSSEEKTBL_798
GSSEEKTBL_774:          /* end a full run before an empty pixel */
    movel %d3,%a2@+
    moveq #0,%d3
    jbra GSSEEKTBL_712
GSSEEKTBL_77A:          /* end a full run before a masked one */
    movel %d3,%a2@+
    moveq #0,%d3
    jbra GSSEEKTBL_728
GSSEEKTBL_780:          /* full run: next pair */
    addl %d0,%d0
    jbcc GSSEEKTBL_774
    jbne GSSEEKTBL_78C
    movel %a0@+,%d0
    addxl %d0,%d0
    jbcc GSSEEKTBL_774
GSSEEKTBL_78C:          /* both set: longer run */
    addl %d0,%d0
    jbcc GSSEEKTBL_77A
    addl %d4,%d3
GSSEEKTBL_792:          /* next; end of the row */
    dbf %d5,GSSEEKTBL_780
    movel %d3,%a2@+
GSSEEKTBL_798:          /* end marker (-1) */
    moveq #-1,%d3
    movel %d3,%a2@
    moveml %sp@+,%d3-%d5
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B856
    /* the loop entry into fp-24, by the direction of the row (fp-120) */
    lea %pc@(GSSEEKTBL_6AC_40),%a0
    movel %a0,%fp@(-24)
    tstw %fp@(-120)
    bplw GSSEEKTBL_6AC_40
    lea %pc@(GSSEEKTBL_798_2C),%a0
    movel %a0,%fp@(-24)
GSSEEKTBL_798_2C:       /* right to left: the mask width rounded up to 16 bits, start from the end of the row */
    moveal %fp@(-8),%a0	| 4083B878
    moveml %d3-%d5,%sp@-
    moveal %fp@(-12),%a2
    movew %fp@(-16),%d5
    addiw #16,%d5
    andiw #-16,%d5
    moveq #1,%d4
    swap %d4
    movew %d5,%d3
    extl %d3
    asrw #2,%d3
    addaw %d3,%a0
    lslw #4,%d3
    subqw #1,%d5
    subqw #4,%d3
    moveq #1,%d0
GSSEEKTBL_7F0:          /* the same, right to left */
    lsrl #1,%d0
    jbcc GSSEEKTBL_7FC
    jbne GSSEEKTBL_80E
    movel %a0@-,%d0
    roxrl #1,%d0
    jbcs GSSEEKTBL_80E
GSSEEKTBL_7FC:          /* next bit */
    lsrl #1,%d0
    jbcc GSSEEKTBL_806
    moveal %a2,%a1
    addql #4,%a2
    jbra GSSEEKTBL_832
GSSEEKTBL_806:          /* empty pixel */
    subqw #4,%d3
    dbf %d5,GSSEEKTBL_7F0
    jbra GSSEEKTBL_798
GSSEEKTBL_80E:          /* two set bits */
    lsrl #1,%d0
    jbcs GSSEEKTBL_87E
GSSEEKTBL_812:          /* start a full run */
    moveal %a2,%a1
    addql #4,%a2
    jbra GSSEEKTBL_84C
GSSEEKTBL_818:          /* end a masked run before an empty pixel */
    bset #30,%d3
    movel %d3,%a1@
    moveq #0,%d3
    jbra GSSEEKTBL_806
GSSEEKTBL_822:          /* end a masked run before a full one */
    bset #30,%d3
    movel %d3,%a1@
    moveq #0,%d3
    jbra GSSEEKTBL_87E
GSSEEKTBL_82C:          /* masked run: next bit */
    lsrl #1,%d0
    jbcc GSSEEKTBL_818
    addl %d4,%d3
GSSEEKTBL_832:          /* masked pixel */
    movel #-65536,%a2@+
    jbra GSSEEKTBL_852
GSSEEKTBL_83A:          /* next pair */
    lsrl #1,%d0
    jbcc GSSEEKTBL_82C
    jbne GSSEEKTBL_846
    movel %a0@-,%d0
    roxrl #1,%d0
    jbcc GSSEEKTBL_82C
GSSEEKTBL_846:          /* both set */
    lsrl #1,%d0
    jbcs GSSEEKTBL_822
    addl %d4,%d3
GSSEEKTBL_84C:          /* masked pixel */
    movel #65535,%a2@+
GSSEEKTBL_852:          /* end of the row */
    dbf %d5,GSSEEKTBL_83A
    bset #30,%d3
    movel %d3,%a1@
    jbra GSSEEKTBL_798
GSSEEKTBL_860:          /* end a full run before an empty pixel */
    movel %d3,%a2@+
    moveq #0,%d3
    jbra GSSEEKTBL_7FC
GSSEEKTBL_866:          /* end a full run before a masked one */
    movel %d3,%a2@+
    moveq #0,%d3
    jbra GSSEEKTBL_812
GSSEEKTBL_86C:          /* full run: next pair */
    lsrl #1,%d0
    jbcc GSSEEKTBL_860
    jbne GSSEEKTBL_878
    movel %a0@-,%d0
    roxrl #1,%d0
    jbcc GSSEEKTBL_860
GSSEEKTBL_878:          /* longer run */
    lsrl #1,%d0
    jbcc GSSEEKTBL_866
    addl %d4,%d3
GSSEEKTBL_87E:          /* next; end of the row */
    dbf %d5,GSSEEKTBL_86C
    movel %d3,%a2@+
    jbra GSSEEKTBL_798
    .long   0x00000000	| 4083B93C
GSSEEKTBL_88C:          /* 32-bit pixel run builder (one bit per pixel), left to right */
    moveal %fp@(-8),%a0
    moveml %d3-%d5,%sp@-
    moveal %fp@(-12),%a2
    movew %fp@(-16),%d5
    moveq #1,%d4
    swap %d4
    moveq #1,%d0
    rorl #1,%d0
    moveq #0,%d3
GSSEEKTBL_8A6:          /* next bit */
    addl %d0,%d0
    jbcc GSSEEKTBL_8B2
    jbne GSSEEKTBL_8CE
    movel %a0@+,%d0
    addxl %d0,%d0
    jbcs GSSEEKTBL_8CE
GSSEEKTBL_8B2:          /* empty pixel */
    addqw #4,%d3
    dbf %d5,GSSEEKTBL_8A6
    jbra GSSEEKTBL_8D4
GSSEEKTBL_8BA:          /* end of a run */
    movel %d3,%a2@+
    moveq #0,%d3
    jbra GSSEEKTBL_8B2
GSSEEKTBL_8C0:          /* in a run: next bit */
    addl %d0,%d0
    jbcc GSSEEKTBL_8BA
    jbne GSSEEKTBL_8CC
    movel %a0@+,%d0
    addxl %d0,%d0
    jbcc GSSEEKTBL_8BA
GSSEEKTBL_8CC:          /* longer run */
    addl %d4,%d3
GSSEEKTBL_8CE:          /* next; end of the row */
    dbf %d5,GSSEEKTBL_8C0
    movel %d3,%a2@+
GSSEEKTBL_8D4:          /* end marker; then the right-to-left version */
    moveq #-1,%d3
    movel %d3,%a2@
    moveml %sp@+,%d3-%d5
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083B992
    /* the loop entry into fp-24, by the direction of the row (fp-120) */
    lea %pc@(GSSEEKTBL_88C),%a0
    movel %a0,%fp@(-24)
    tstw %fp@(-120)
    jbpl GSSEEKTBL_88C
    lea %pc@(GSSEEKTBL_902),%a0
    movel %a0,%fp@(-24)
GSSEEKTBL_902:          /* right to left */
    moveal %fp@(-8),%a0
    moveml %d3-%d5,%sp@-
    moveal %fp@(-12),%a2
    movew %fp@(-16),%d5
    addiw #32,%d5
    andiw #-32,%d5
    moveq #1,%d4
    swap %d4
    movew %d5,%d3
    extl %d3
    asrw #3,%d3
    addaw %d3,%a0
    lslw #5,%d3
    subqw #1,%d5
    subqw #4,%d3
    moveq #1,%d0
GSSEEKTBL_92E:          /* next bit */
    lsrl #1,%d0
    jbcc GSSEEKTBL_93A
    jbne GSSEEKTBL_956
    movel %a0@-,%d0
    roxrl #1,%d0
    jbcs GSSEEKTBL_956
GSSEEKTBL_93A:          /* empty pixel */
    subqw #4,%d3
    dbf %d5,GSSEEKTBL_92E
    jbra GSSEEKTBL_8D4
GSSEEKTBL_942:          /* end of a run */
    movel %d3,%a2@+
    moveq #0,%d3
    jbra GSSEEKTBL_93A
GSSEEKTBL_948:          /* in a run: next bit */
    lsrl #1,%d0
    jbcc GSSEEKTBL_942
    jbne GSSEEKTBL_954
    movel %a0@-,%d0
    roxrl #1,%d0
    jbcc GSSEEKTBL_942
GSSEEKTBL_954:          /* longer run */
    addl %d4,%d3
GSSEEKTBL_956:          /* next; end of the row */
    dbf %d5,GSSEEKTBL_948
    movel %d3,%a2@+
    jbra GSSEEKTBL_8D4
    .long   0x00000000, 0x00000000, 0x00000000	| 4083BA14

/* STDOVAL: StdOval: the oval bottleneck. */
trap_StdOval:
STDOVAL:
    linkw %fp,#-4
    moveml %d7/%a3-%a4,%sp@-
    moveb %fp@(12),%d7
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x1a3c,%za0)@(0)	| 4083BA2C
    jble STDOVAL_2C
    moveb %d7,%sp@-
    jbsr PUTPICVERB
    moveq #80,%d0
    addw %d7,%d0
    moveb %d0,%sp@-
    movel %fp@(8),%sp@-
    jbsr PUTPICRECT
STDOVAL_2C:             /* draw on each screen: the draw proc (STDOVAL_54) and the rectangle proc (STDOVAL_44) */
    pea %pc@(STDOVAL_54)
    pea %pc@(STDOVAL_44)
    jsr @(0x1aa0,%za0)@(0)	| 4083BA54
    moveml %sp@+,%d7/%a3-%a4
    unlk %fp
    rtd #6
STDOVAL_44:             /* rectangle proc: the oval's rectangle */
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %fp@(8),%a0
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    moveal %d0,%a0
    jmp %a0@
STDOVAL_54:             /* draw proc: frame or fill the oval through DRAWARC (0..360 degrees) with its width and height as the oval size */
    moveal %fp@(8),%a0
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    movew %d0,%fp@(-2)
    movew %a0@(4),%d0
    subw %a0@,%d0
    movew %d0,%fp@(-4)
    movel %a0,%sp@-
    tstb %d7
    jbne STDOVAL_98
    tstl %a3@(96)
    jbeq STDOVAL_92
    movel %a0,%sp@-
    movel %fp@(-4),%sp@-
    movel %a4@(-148),%sp@-
    pea %a4@(-150)
    pea %a4@(-152)
    jsr @(0x1a68,%za0)@(0)	| 4083BAAC
STDOVAL_92:             /* frame */
    moveb #1,%sp@-
    jbra STDOVAL_9A
STDOVAL_98:             /* fill */
    clrb %sp@-
STDOVAL_9A:             /* DrawArc(0, 360) */
    movel %fp@(-4),%sp@-
    jsr @(0x1a60,%za0)@(0)	| 4083BABE
    clrw %sp@-
    movew #360,%sp@-
    jsr @(0x1a24,%za0)@(0)	| 4083BACA
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083BAD2

/* FRAMEOVAL: _FrameOval: frame (outline with the pen) the oval. */
trap_FrameOval:
FRAMEOVAL:
    moveq #0,%d0
    jbra CALLOVAL

/* PAINTOVAL: _PaintOval: paint (fill with the pen pattern) the oval. */
trap_PaintOval:
PAINTOVAL:
    moveq #1,%d0
    jbra CALLOVAL

/* ERASEOVAL: _EraseOval: erase (fill with the background) the oval. */
trap_EraseOval:
ERASEOVAL:
    moveq #2,%d0
    jbra CALLOVAL

/* INVERTOVAL: _InvertOval: invert the oval. */
trap_InvertOval:
INVERTOVAL:
    moveq #3,%d0
    jbra CALLOVAL

/* FILLOVAL: _FillOval: fill with a pattern the oval. */
trap_FillOval:
FILLOVAL:
    moveq #0,%d0
    jbra FILLCOVAL_2

/* FILLCOVAL: _FillCoval: fill with a pattern the oval with a pixel pattern. */
trap_FillCOval:
FILLCOVAL:
    moveq #1,%d0
FILLCOVAL_2:            /* the pixpat, then CALLOVAL with verb 4 (fill) */
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a0,%sp@-
    movel %a1,%sp@-
    jsr @(0x1a8c,%za0)@(0)	| 4083BAFE
    moveq #4,%d0

/* CALLOVAL: call the port's oval bottleneck (grafProcs) or the standard one. */
CALLOVAL:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    moveb %d0,%sp@-
    movel %a1,%sp@-
    movel %a0,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x10d8,%a0
    jbeq CALLOVAL_1E
    moveal %d0,%a0
    moveal %a0@(16),%a0
CALLOVAL_1E:            /* through the port's ovalProc or StdOval */
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083BB26

/* STDARC: StdArc: the arc bottleneck. */
trap_StdArc:
STDARC:
    linkw %fp,#-4
    moveml %d4/%d7/%a3-%a4,%sp@-
    moveb %fp@(16),%d7
    jsr @(0x1a3c,%za0)@(0)	| 4083BB3C
    jble STDARC_40
    moveb %d7,%sp@-
    jbsr PUTPICVERB
    moveq #96,%d0
    addw %d7,%d0
    moveb %d0,%sp@-
    movel %fp@(12),%sp@-
    jbsr PUTPICRECT
    movew %fp@(10),%sp@-
    jbsr PUTPICWORD
    movew %fp@(8),%sp@-
    jbsr PUTPICWORD
STDARC_40:              /* draw on each screen */
    pea %pc@(STDARC_68)
    pea %pc@(STDARC_58)
    jsr @(0x1aa0,%za0)@(0)	| 4083BB78
    moveml %sp@+,%d4/%d7/%a3-%a4
    unlk %fp
    rtd #10
STDARC_58:              /* rectangle proc */
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %fp@(12),%a0
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    moveal %d0,%a0
    jmp %a0@
STDARC_68:              /* draw proc: DRAWARC with the start and arc angles */
    moveal %fp@(12),%a0
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    movew %d0,%fp@(-2)
    movew %a0@(4),%d0
    subw %a0@,%d0
    movew %d0,%fp@(-4)
    movel %a0,%sp@-
    clrb %sp@-
    tstb %d7
    jbne STDARC_8E
    moveb #1,%sp@
STDARC_8E:              /* DrawArc */
    movel %fp@(-4),%sp@-
    jsr @(0x1a60,%za0)@(0)	| 4083BBC2
    movew %fp@(10),%sp@-
    movew %fp@(8),%sp@-
    jsr @(0x1a24,%za0)@(0)	| 4083BBD0
    rts
    .long   0x00000000, 0x00000000	| 4083BBD8

/* FRAMEARC: _FrameArc: frame (outline with the pen) the arc (wedge). */
trap_FrameArc:
FRAMEARC:
    moveq #0,%d0
    jbra CALLARC

/* PAINTARC: _PaintArc: paint (fill with the pen pattern) the arc (wedge). */
trap_PaintArc:
PAINTARC:
    moveq #1,%d0
    jbra CALLARC

/* ERASEARC: _EraseArc: erase (fill with the background) the arc (wedge). */
trap_EraseArc:
ERASEARC:
    moveq #2,%d0
    jbra CALLARC

/* INVERTARC: _InvertArc: invert the arc (wedge). */
trap_InvertArc:
INVERTARC:
    moveq #3,%d0
    jbra CALLARC

/* FILLARC: _FillArc: fill with a pattern the arc (wedge). */
trap_FillArc:
FILLARC:
    moveq #0,%d0
    jbra FILLCARC_2

/* FILLCARC: _FillCarc: fill with a pattern the arc with a pixel pattern. */
trap_FillCArc:
FILLCARC:
    moveq #1,%d0
FILLCARC_2:             /* the pixpat, then CALLARC with verb 4 */
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a0,%sp@-
    movel %a1,%sp@-
    jsr @(0x1a8c,%za0)@(0)	| 4083BBFE
    moveq #4,%d0

/* CALLARC: call the port's arc bottleneck (grafProcs) or the standard one. */
CALLARC:
    moveal %sp@+,%a0
    movel %sp@+,%d1
    moveal %sp@+,%a1
    moveb %d0,%sp@-
    movel %a1,%sp@-
    movel %d1,%sp@-
    movel %a0,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x10f4,%a0
    jbeq CALLARC_22
    moveal %d0,%a0
    moveal %a0@(20),%a0
CALLARC_22:             /* through the port's arcProc or StdArc */
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 4083BC2A

/* SORTPOINTS: SortPoints(count, points): quicksort the 4-byte points of a region being built by (v, h) */
trap_SORTPOINTS:
SORTPOINTS:
    linkw %fp,#0
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveal %fp@(10),%a3
    movew %a3,%d3
    andiw #3,%d3
    moveq #0,%d0
    movew %fp@(8),%d0
    jble SORTPOINTS_86
    lsll #2,%d0
    moveal %a3,%a4
    addal %d0,%a4
    subqw #4,%a4
    movel %sp,%d4
    moveml %a3-%a4,%sp@-
SORTPOINTS_28:          /* restore registers */
    moveml %sp@+,%a3-%a4
SORTPOINTS_2C:          /* quicksort: the middle element as pivot (v, then h) */
    moveal %a3,%a1
    moveal %a4,%a2
    movel %a3,%d0
    addl %a4,%d0
    roxrl #1,%d0
    andiw #-4,%d0
    orw %d3,%d0
    moveal %d0,%a0
    movew %a0@(2),%d1
    movew %a0@,%d2
SORTPOINTS_44:          /* scan up */
    jbra SORTPOINTS_48
SORTPOINTS_46:          /* next */
    addqw #4,%a1
SORTPOINTS_48:          /* below the pivot? keep going */
    cmpw %a1@,%d2
    jbgt SORTPOINTS_46
    jblt SORTPOINTS_54
    cmpw %a1@(2),%d1
    jbgt SORTPOINTS_46
SORTPOINTS_54:          /* scan down */
    jbra SORTPOINTS_58
SORTPOINTS_56:          /* next */
    subqw #4,%a2
SORTPOINTS_58:          /* above the pivot? keep going */
    cmpw %a2@,%d2
    jblt SORTPOINTS_56
    jbgt SORTPOINTS_64
    cmpw %a2@(2),%d1
    jblt SORTPOINTS_56
SORTPOINTS_64:          /* swap */
    cmpal %a2,%a1
    jbgt SORTPOINTS_70
    movel %a1@,%d0
    movel %a2@,%a1@+
    movel %d0,%a2@
    subqw #4,%a2
SORTPOINTS_70:          /* crossed? push the larger part, loop on the smaller */
    cmpal %a2,%a1
    jbls SORTPOINTS_44
    cmpal %a4,%a1
    jbcc SORTPOINTS_7C
    moveml %a1/%a4,%sp@-
SORTPOINTS_7C:          /* next part; stack empty: done */
    moveal %a2,%a4
    cmpal %a4,%a3
    jbcs SORTPOINTS_2C
    cmpal %d4,%sp
    jbne SORTPOINTS_28
SORTPOINTS_86:          /* restore registers, return */
    moveml %sp@+,%d3-%d4/%a2-%a4
    unlk %fp
    rtd #6

/* CULLPOINTS: CullPoints(count, points): remove pairs of equal points (inversions that cancel) */
trap_CULLPOINTS:
CULLPOINTS:
    linkw %fp,#0
    moveml %d0-%d7/%a1-%a5,%sp@-
    moveal %fp@(8),%a0
    movew %a0@,%d0
    jble CULLPOINTS_44
    moveal %fp@(12),%a1
    moveal %a1,%a3
    extl %d0
    lsll #2,%d0
    addal %d0,%a3
    subqw #4,%a3
    movel %a1,%d5
    moveal %a1,%a2
    jbra CULLPOINTS_30
CULLPOINTS_24:          /* equal pair: drop both */
    addqw #4,%a1
    jbra CULLPOINTS_30
CULLPOINTS_28:          /* next point: equal to the following one? */
    movel %a1@+,%d0
    cmpl %a1@,%d0
    jbeq CULLPOINTS_24
    movel %d0,%a2@+
CULLPOINTS_30:          /* until the end; the last one */
    cmpal %a3,%a1
    jblt CULLPOINTS_28
    jbgt CULLPOINTS_38
    movel %a1@+,%a2@+
CULLPOINTS_38:          /* the new count */
    movel %a2,%d0
    subl %d5,%d0
    lsrw #2,%d0
    moveal %fp@(8),%a0
    movew %d0,%a0@
CULLPOINTS_44:          /* restore registers, return */
    moveml %sp@+,%d0-%d7/%a1-%a5
    unlk %fp
    rtd #8
    .short  0x0000	| 4083BD0E

/* PUTRGN: PutRgn: append the sorted, culled inversion points to the region handle as rows (v, h..., 32767) */
trap_PUTRGN:
PUTRGN:
    linkw %fp,#0
    moveml %d7/%a2-%a4,%sp@-
    moveal %fp@(16),%a4
    moveal %fp@(20),%a3
    moveal %fp@(12),%a2
    moveal %a3@,%a0
    moveq #0,%d7
    movew %a0@,%d7
    addl %d7,%d7
    moveq #0,%d0
    movew %a2@,%d0
    addl %d0,%d7
    cmpil #65280,%d7
    jblt PUTRGN_34
    movew #-147,QDErr
    braw PUTRGN_92
PUTRGN_34:              /* room for the region? grow the handle by 256 */
    moveal %fp@(8),%a1
    cmpw %a1@,%d7
    jbls PUTRGN_52
    addiw #256,%d7
    movew %d7,%a1@
    movel %a4,%sp@-
    movew %d7,%sp@-
    jbsr SETHSIZE
    moveal %a3@,%a0
    moveal %fp@(12),%a2
PUTRGN_52:              /* append: a rectangular region as its two rows */
    moveal %a4@,%a1
    moveq #0,%d0
    movew %a2@,%d0
    addal %d0,%a1
    cmpiw #10,%a0@
    jbne PUTRGN_74
    addqw #2,%a0
    movel %a0@,%a1@+
    movew %a0@+,%a1@+
    movew %a0@+,%d0
    movel %a0@,%d1
    movew %d1,%a1@+
    movew %a0@,%a1@+
    movew %d0,%a1@+
    movel %d1,%a1@+
    jbra PUTRGN_8E
PUTRGN_74:              /* else its rows */
    lea %a0@(10),%a0
PUTRGN_78:              /* next row */
    movel %a0@+,%d7
PUTRGN_7A:              /* each point as (v, h) */
    movel %d7,%a1@+
    movew %a0@+,%d7
    movel %d7,%a1@+
    movew %a0@+,%d7
    cmpiw #32767,%d7
    jbne PUTRGN_7A
    cmpiw #32767,%a0@
    jbne PUTRGN_78
PUTRGN_8E:              /* the new size */
    subal %a4@,%a1
    movew %a1,%a2@
PUTRGN_92:              /* restore registers, return */
    moveml %sp@+,%d7/%a2-%a4
    unlk %fp
    rtd #16
    .long   0x00000000	| 4083BDAC

trap_UpdatePixMap:
UPDATEPIXMAP:           /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083BDB2

/* MAKEITABLE: _MakeITable: build an inverse color table. */
trap_MakeITable:
MAKEITABLE:
    linkw %fp,#-22
    moveml %d3-%d7/%a2-%a5,%sp@-
    clrw QDErr
    movew %fp@(8),%d7
    cmpil #-1,TheGDevice
    jbeq MAKEITABLE_4E
    moveal @(TheGDevice,%za0)@(0),%a0	| 4083BDDA
    tstl %fp@(10)
    jbne MAKEITABLE_2C
    movel %a0@(6),%fp@(10)
MAKEITABLE_2C:          /* default: the device's color table */
    tstl %fp@(14)
    jbne MAKEITABLE_3E
    moveal %a0@(0x16,%za0)@(0x0),%a1	| 4083BDF2
    movel %a1@(42),%fp@(14)
MAKEITABLE_3E:          /* default resolution: the device's, else 4 */
    tstw %d7
    jbne MAKEITABLE_4E
    movew %a0@(10),%d7
    jbne MAKEITABLE_4A
    moveq #4,%d7
MAKEITABLE_4A:          /* store it */
    movew %d7,%fp@(8)
MAKEITABLE_4E:          /* resolution 3..5 only: else cMatchErr (-156) */
    cmpiw #2,%d7
    jble MAKEITABLE_5A
    cmpiw #6,%d7
    jblt MAKEITABLE_64
MAKEITABLE_5A:          /* bad resolution */
    movew #-156,QDErr
    jbra MAKEITABLE_36C
MAKEITABLE_64:          /* size the inverse table (2^(3 res) + 6) and the work buffers */
    movew %d7,%d1
    moveq #1,%d0
    lsll %d1,%d0
    lsll %d1,%d0
    lsll %d1,%d0
    addql #6,%d0
    movel %d0,%fp@(-20)
    addil #518,%d0
    moveal %fp@(10),%a0
    tstl %a0@
    jbeq MAKEITABLE_86
    _SetHandleSize
    jbra MAKEITABLE_88
MAKEITABLE_86:          /* _ReallocHandle */
    _ReallocHandle
MAKEITABLE_88:          /* no memory: cNoMemErr */
    jbeq MAKEITABLE_94
    movew #-152,QDErr
    jbra MAKEITABLE_36C
MAKEITABLE_94:          /* all colors gray (R = G = B)? */
    moveal %fp@(14),%a0
    moveal %a0@,%a0
    movew %a0@(6),%d0
    lea %a0@(8),%a1
MAKEITABLE_A2:          /* next color */
    movel %a1@+,%d1
    movel %a1@+,%d2
    cmpw %d1,%d2
    jbne MAKEITABLE_BE
    swap %d2
    cmpw %d1,%d2
    jbne MAKEITABLE_BE
MAKEITABLE_B0:          /* count down (loop) */
    dbf %d0,MAKEITABLE_A2
    jsr @(0x1c6c,%za0)@(0)	| 4083BE74
    jbra MAKEITABLE_36C
MAKEITABLE_BE:          /* no: a real table; the 'mitq' work area resource */
    btst #30,%d1
    jbne MAKEITABLE_B0
    movel TheZone,%fp@(-8)
    movel ApplZone,TheZone
    subqw #4,%sp
    movel #1835627633,%sp@-
    clrw %sp@-
    _RGetResource
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movel %a0@(0xfffffffffffffff4,%d7:w:4),%d0
    movel %d0,%d3
    .short  0xA11E	| 4083BEA6 _NewPtr (flags 0x0100)
    jbne MAKEITABLE_37C
    movel %a0,%fp@(-4)
    addal %d3,%a0
    moveal %a0,%a5
    moveq #1,%d6
    lsll %d7,%d6
    movel %d6,%d5
    addqw #2,%d6
    movel %d6,%d0
    muluw %d6,%d0
    muluw %d6,%d0
    addl %d0,%d0
    movel %d0,%fp@(-16)
    clrb %fp@(-22)
    .short  0xA122	| 4083BECC _NewHandle (flags 0x0100)
    jbeq MAKEITABLE_124
    movel %fp@(-16),%d0
    jsr @(0x1ab4,%za0)@(0)	| 4083BED4
    st %fp@(-22)
    movel %a0,%d0
    jbeq MAKEITABLE_376
MAKEITABLE_124:         /* the cube of distances: a border and the interior */
    movel %a0,%fp@(-12)
    moveal %a0@,%a0
    moveal %a0,%a3
    movel #2147450879,%d1
    movel #-2147450880,%d0
    movew %d6,%d4
    muluw %d6,%d4
    subw %d6,%d4
    subqw #1,%d4
    lsrw #1,%d4
MAKEITABLE_142:         /* front face */
    movel %d1,%a0@+
    dbf %d4,MAKEITABLE_142
    subql #2,%a0
    movew %d5,%d4
    subqw #1,%d4
MAKEITABLE_14E:         /* each slice */
    movel %d6,%d3
    subqw #1,%d3
MAKEITABLE_152:         /* its border */
    movel %d1,%a0@+
    dbf %d3,MAKEITABLE_152
    movel %d5,%d2
    subqw #1,%d2
MAKEITABLE_15C:         /* each row */
    movel %d1,%a0@+
    movew %d5,%d3
    lsrw #1,%d3
    subqw #1,%d3
MAKEITABLE_164:         /* interior (unclaimed) */
    movel %d0,%a0@+
    dbf %d3,MAKEITABLE_164
    dbf %d2,MAKEITABLE_15C
    dbf %d4,MAKEITABLE_14E
    movew %d1,%a0@+
    movew %d6,%d4
    muluw %d6,%d4
    addl %d6,%d4
    subqw #1,%d4
    lsrw #1,%d4
MAKEITABLE_17E:         /* back face; then the color components to cell coordinates */
    movel %d1,%a0@+
    dbf %d4,MAKEITABLE_17E
    movel %d6,%d4
    subqw #3,%d4
    moveq #8,%d3
    subw %fp@(8),%d3
    moveq #1,%d5
    lslw %d3,%d5
    subqw #1,%d5
    movel %d6,%d7
    muluw %d6,%d7
    movel %d7,%d0
    addl %d6,%d0
    addqw #1,%d0
    moveq #0,%d1
    moveq #0,%d2
    moveal %a5,%a0
    subaw #2048,%a0
    moveal %a0,%a2
MAKEITABLE_1AA:         /* per component level */
    movel %d5,%d3
MAKEITABLE_1AC:         /* one level */
    movew %d0,%a0@+
    movew %d1,%a0@+
    movew %d2,%a0@+
    addqw #2,%a0
    dbf %d3,MAKEITABLE_1AC
    addw %d7,%d0
    addw %d6,%d1
    addqw #1,%d2
    dbf %d4,MAKEITABLE_1AA
    moveal %fp@(-4),%a4
    addqw #2,%a4
    moveal %fp@(0xa,%za0)@(0),%a1	| 4083BF88
    addal %fp@(-20),%a1
    clrw %a1@
    clrw %a1@(4)
    clrw %a1@(2)
    moveal %fp@(0xe,%za0)@(0),%a0	| 4083BF9C
    moveq #0,%d5
    jbsr MAKEITABLE_1FE
    movew %a0@(6),%d5
    jbsr MAKEITABLE_1FE
    movel %d5,%d4
    subqw #2,%d4
    jble MAKEITABLE_252
    moveq #1,%d5
MAKEITABLE_1F4:         /* seed the cube with each color (MAKEITABLE_1FE) */
    jbsr MAKEITABLE_1FE
    addqw #1,%d5
    dbf %d4,MAKEITABLE_1F4
    jbra MAKEITABLE_252

MAKEITABLE_1FE:         /* a usable color: its cell; claim it and queue it */
    btst #6,%a0@(0x8,%d5:w:8)
    jbne MAKEITABLE_250
    moveq #0,%d0
    moveq #0,%d1
    moveb %a0@(0xa,%d5:w:8),%d0
    movew %a2@(0x0,%d0:w:8),%d1
    moveb %a0@(0xc,%d5:w:8),%d0
    addw %a2@(0x2,%d0:w:8),%d1
    moveb %a0@(0xe,%d5:w:8),%d0
    addw %a2@(0x4,%d0:w:8),%d1
    movew %a3@(0x0,%d1:l:2),%d2
    jbmi MAKEITABLE_236
    moveb %a1@(0x6,%d2:w),%a1@(0x6,%d5:w)
    moveb %d5,%a1@(0x6,%d2:w)
    addqw #1,%a1@
    jbra MAKEITABLE_250
MAKEITABLE_236:         /* claim the cell */
    moveb %d5,%a1@(0x6,%d5:w)
    movew %d5,%a3@(0x0,%d1:l:2)
    cmpal %a4,%a5
MAKEITABLE_240:         /* queue wrap */
    jbne MAKEITABLE_246
    moveal %fp@(-4),%a4
MAKEITABLE_246:         /* queue it */
    movel %d1,%d0
    addil #0,%d0
    movew %d0,%a4@+
MAKEITABLE_250:         /* return */
    rts

MAKEITABLE_252:         /* grow the claimed regions breadth-first: each queued cell spreads to its 6 neighbours */
    moveal %fp@(-4),%a1
    addql #2,%a1
    moveq #1,%d5
    jbra MAKEITABLE_308
MAKEITABLE_25E:         /* +red: unclaimed? claim and queue */
    lea %a3@(0x0,%d1:l:2),%a0
    movew %a0@,%d4
    btst #7,%a0@(0x0,%d5:l:2)
    jbeq MAKEITABLE_27E
    movew %d4,%a0@(0x0,%d5:l:2)
    cmpal %a4,%a5
    jbne MAKEITABLE_278
    moveal %fp@(-4),%a4
MAKEITABLE_278:         /* queue */
    movel %d1,%d0
    addl %d5,%d0
    movew %d0,%a4@+
MAKEITABLE_27E:         /* -red */
    negl %d5
    btst #7,%a0@(0x0,%d5:l:2)
    jbeq MAKEITABLE_29A
    movew %d4,%a0@(0x0,%d5:l:2)
    cmpal %a4,%a5
    jbne MAKEITABLE_294
    moveal %fp@(-4),%a4
MAKEITABLE_294:         /* queue */
    movel %d1,%d0
    addl %d5,%d0
    movew %d0,%a4@+
MAKEITABLE_29A:         /* +green */
    btst #7,%a0@(0x0,%d6:l:2)
    jbeq MAKEITABLE_2B4
    movew %d4,%a0@(0x0,%d6:l:2)
    cmpal %a4,%a5
    jbne MAKEITABLE_2AE
    moveal %fp@(-4),%a4
MAKEITABLE_2AE:         /* queue */
    movel %d1,%d0
    addl %d6,%d0
    movew %d0,%a4@+
MAKEITABLE_2B4:         /* -green */
    negl %d6
    btst #7,%a0@(0x0,%d6:l:2)
    jbeq MAKEITABLE_2D0
    movew %d4,%a0@(0x0,%d6:l:2)
    cmpal %a4,%a5
    jbne MAKEITABLE_2CA
    moveal %fp@(-4),%a4
MAKEITABLE_2CA:         /* queue */
    movel %d1,%d0
    addl %d6,%d0
    movew %d0,%a4@+
MAKEITABLE_2D0:         /* +blue */
    btst #7,%a0@(0x0,%d7:l:2)
    jbeq MAKEITABLE_2EA
    movew %d4,%a0@(0x0,%d7:l:2)
    cmpal %a4,%a5
    jbne MAKEITABLE_2E4
    moveal %fp@(-4),%a4
MAKEITABLE_2E4:         /* queue */
    movel %d1,%d0
    addl %d7,%d0
    movew %d0,%a4@+
MAKEITABLE_2EA:         /* -blue */
    negl %d7
    btst #7,%a0@(0x0,%d7:l:2)
    jbeq MAKEITABLE_308
    movew %d4,%a0@(0x0,%d7:l:2)
    cmpal %a4,%a5
    jbne MAKEITABLE_300
    moveal %fp@(-4),%a4
MAKEITABLE_300:         /* queue */
    movel %d1,%d0
    addl %d7,%d0
    movew %d0,%a4@+
    moveq #0,%d1
MAKEITABLE_308:         /* queue wrap */
    cmpal %a1,%a5
    jbne MAKEITABLE_310
    moveal %fp@(-4),%a1
MAKEITABLE_310:         /* queue empty? */
    cmpal %a4,%a1
    jbne MAKEITABLE_318
    moveq #0,%d1
    jbra MAKEITABLE_31A
MAKEITABLE_318:         /* next cell */
    movew %a1@+,%d1
MAKEITABLE_31A:         /* more queued? else write the header (seed, resolution) and copy the cube */
    jbne MAKEITABLE_25E
    moveal %fp@(10),%a0
    moveal %a0@,%a0
    moveal %fp@(0xe,%za0)@(0),%a2	| 4083C0E4
    movel %a2@,%a0@+
    movew %fp@(8),%a0@+
    movel %fp@(-16),%d0
    lsrl #1,%d0
    subqw #1,%d0
    moveal %fp@(-12),%a2
    moveal %a2@,%a2
MAKEITABLE_33E:         /* copy the cube's interior into the inverse table */
    movew %a2@+,%d1
    cmpiw #32767,%d1
    jbeq MAKEITABLE_348
    moveb %d1,%a0@+
MAKEITABLE_348:         /* next; release the work area */
    dbf %d0,MAKEITABLE_33E
    moveal %fp@(-12),%a0
    tstb %fp@(-22)
    jbeq MAKEITABLE_35E
    jsr @(0x1a78,%za0)@(0)	| 4083C116
    jbra MAKEITABLE_360
MAKEITABLE_35E:         /* _DisposHandle */
    _DisposHandle
MAKEITABLE_360:         /* free the queue, restore the zone */
    moveal %fp@(-4),%a0
    _DisposPtr
    movel %fp@(-8),TheZone
MAKEITABLE_36C:         /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a5
    unlk %fp
    rtd #10
MAKEITABLE_376:         /* no memory */
    moveal %fp@(-4),%a0
    _DisposPtr
MAKEITABLE_37C:         /* cTempMemErr (-151) */
    movew #-151,QDErr
    jbra MAKEITABLE_36C
