/*
 quickdraw/rgnops.s - region packing and operations, color seed fill
 From PUTOVAL (0x4083D030). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* PUTOVAL: PutOval: add an oval's (or rounded rectangle's) outline to the region being built, row by row (INITOVAL, BUMPOVAL) */
trap_PUTOVAL:
PUTOVAL:
    linkw %fp,#-54
    moveml %d0-%d7/%a1-%a5,%sp@-
    moveal %fp@(24),%a0
    lea %fp@(-46),%a1
    movew %fp@(22),%d2
    movew %fp@(20),%d1
    jbsr INITOVAL
    movew %fp@(-12),%fp@(-52)
    movew %fp@(-8),%fp@(-54)
    movew %fp@(20),%d0
    asrw #1,%d0
    addw %fp@(-46),%d0
    movew %d0,%fp@(-48)
    moveal %fp@(24),%a0
    addw %a0@(4),%d0
    subw %a0@,%d0
    subw %fp@(20),%d0
    movew %d0,%fp@(-50)
    moveal %fp@(16),%a3
    moveal %a3@,%a3
    moveal %a3,%a2
    moveal %fp@(12),%a0
    addaw %a0@,%a3
    moveal %a2,%a1
    moveal %fp@(8),%a0
    addaw %a0@,%a1
    movew %fp@(-46),%d6
    movew %fp@(-52),%d5
    bsrw PUTOVAL_E8
    movew %fp@(-54),%d5
    jbsr PUTOVAL_E8
PUTOVAL_72:             /* each row of the oval: inside its top..bottom? (fp-48, fp-50) */
    cmpw %fp@(-48),%d6
    jblt PUTOVAL_7E
    cmpw %fp@(-50),%d6
    jblt PUTOVAL_C2
PUTOVAL_7E:             /* next row: advance the oval (BUMPOVAL); points where its edges moved */
    moveml %d6/%a1-%a3,%sp@-
    lea %fp@(-46),%a3
    movew %d6,%d0
    jbsr BUMPOVAL
    moveml %sp@+,%d6/%a1-%a3
    movew %fp@(-12),%d5
    cmpw %fp@(-52),%d5
    jbeq PUTOVAL_AA
    jbsr PUTOVAL_E8
    movew %fp@(-52),%d5
    jbsr PUTOVAL_E8
    movew %fp@(-12),%fp@(-52)
PUTOVAL_AA:             /* the right edge moved? add the old and new points */
    movew %fp@(-8),%d5
    cmpw %fp@(-54),%d5
    jbeq PUTOVAL_C2
    jbsr PUTOVAL_E8
    movew %fp@(-54),%d5
    jbsr PUTOVAL_E8
    movew %fp@(-8),%fp@(-54)
PUTOVAL_C2:             /* next row; at the end close both edges and store the region size */
    addqw #1,%d6
    cmpw %fp@(-44),%d6
    jblt PUTOVAL_72
    movew %fp@(-52),%d5
    jbsr PUTOVAL_E8
    movew %fp@(-54),%d5
    jbsr PUTOVAL_E8
    subal %a2,%a3
    moveal %fp@(12),%a0
    movew %a3,%a0@
    moveml %sp@+,%d0-%d7/%a1-%a5
    unlk %fp
    rtd #20

PUTOVAL_E8:             /* add the point (d5, d6): room left? else grow the handle by 1K; past 64K: rgnTooBigErr (-147) */
    cmpal %a1,%a3
    jblt PUTOVAL_12C
    subal %a2,%a3
    subal %a2,%a1
    cmpal #64512,%a1
    jblt PUTOVAL_104
    addal %a2,%a3
    addal %a2,%a1
    movew #-147,QDErr
    rts
PUTOVAL_104:            /* grow by 1K (SETHSIZE), rebase the pointers */
    lea %a1@(1024),%a1
    moveml %d0-%a3,%sp@-
    moveal %fp@(8),%a0
    movew %a1,%a0@
    movel %fp@(16),%sp@-
    movew %a1,%sp@-
    jbsr SETHSIZE
    moveml %sp@+,%d0-%a3
    moveal %fp@(16),%a2
    moveal %a2@,%a2
    addal %a2,%a3
    addal %a2,%a1
PUTOVAL_12C:            /* same point as the last one? cancel both (an inversion undone) */
    cmpal %a2,%a3
    jbeq PUTOVAL_140
    cmpw %a3@(-2),%d5
    jbne PUTOVAL_140
    cmpw %a3@(-4),%d6
    jbne PUTOVAL_140
    subqw #4,%a3
    rts
PUTOVAL_140:            /* store v, h */
    movew %d6,%a3@+
    movew %d5,%a3@+
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083D176

/* PACKRGN: pack a scan line buffer into a region. */
trap_PACKRGN:
PACKRGN:
    linkw %fp,#-8
    moveml %d0-%d7/%a1-%a4,%sp@-
    moveal %fp@(14),%a4
    moveal %fp@(8),%a3
    movew %fp@(12),%d6
    moveal %a3@,%a1
    movew %a1@,%d5
    moveal %a4@,%a0
    moveq #10,%d7
    clrl %fp@(-8)
    clrl %fp@(-4)
    cmpiw #4,%d6
    jbgt PACKRGN_38
    jblt PACKRGN_A4
    movel %a0@,%fp@(-8)
    movel %a0@(12),%fp@(-4)
    jbra PACKRGN_A4
PACKRGN_38:             /* the bounding box: top from the first point, left/right from all points */
    movew %a0@,%fp@(-8)
    movew %a0@(2),%d1
    movew %d1,%d2
    movew %d6,%d3
PACKRGN_44:             /* next point: smaller h? left */
    subqw #1,%d3
    jblt PACKRGN_5A
    movel %a0@+,%d0
    cmpw %d1,%d0
    jbge PACKRGN_52
    movew %d0,%d1
    jbra PACKRGN_44
PACKRGN_52:             /* larger h? right */
    cmpw %d2,%d0
    jble PACKRGN_44
    movew %d0,%d2
    jbra PACKRGN_44
PACKRGN_5A:             /* bottom from the last point; size the region for the worst case */
    movew %d1,%fp@(-6)
    movew %d2,%fp@(-2)
    movew %a0@(-4),%fp@(-4)
    moveq #3,%d5
    addw %d6,%d5
    lslw #2,%d5
    movel %a3,%sp@-
    movew %d5,%sp@-
    jbsr SETHSIZE
    moveal %a4@,%a0
    moveal %a3@,%a1
    addaw %d7,%a1
    subqw #1,%d6
    movew %a0@+,%d0
    movew #32767,%d1
    jbra PACKRGN_92
PACKRGN_88:             /* pack: a new row starts? write the 32767 end of the previous row and the new v */
    cmpw %a0@+,%d0
    jbeq PACKRGN_94
    movew %d1,%a1@+
    movew %a0@(-2),%d0
PACKRGN_92:             /* the row's v */
    movew %d0,%a1@+
PACKRGN_94:             /* the h; next point; at the end the final 32767s and the real size */
    movew %a0@+,%a1@+
    dbf %d6,PACKRGN_88
    movew %d1,%a1@+
    movew %d1,%a1@+
    moveal %a3@,%a0
    subal %a0,%a1
    movew %a1,%d7
PACKRGN_A4:             /* rgnSize and rgnBBox; shrink the handle when smaller (a rectangle: 10 bytes) */
    moveal %a3@,%a0
    movew %d7,%a0@+
    movel %fp@(-8),%a0@+
    movel %fp@(-4),%a0@+
    cmpw %d7,%d5
    jbeq PACKRGN_BE
    movel %a3,%sp@-
    movew %d7,%sp@-
    jbsr SETHSIZE
PACKRGN_BE:             /* restore registers, return */
    moveml %sp@+,%d0-%d7/%a1-%a4
    unlk %fp
    rtd #10
    .long   0x00000000, 0x00000000	| 4083D248

/* RGNOP: RgnOp: the scan line region operation engine. */
trap_RGNOP:
RGNOP:
    linkw %fp,#-86
    moveml %d3-%d7/%a2-%a4,%sp@-
    movel %sp,%fp@(-86)
    lea %fp@(-78),%a2
    lea %fp@(24),%a0
    jbsr RGNOP_1CE
    moveal %a0,%a3
    lea %fp@(20),%a0
    jbsr RGNOP_1CE
    moveal %a0,%a4
    lea %pc@(SECTSCAN),%a0
    movew %fp@(12),%d0
    jbeq RGNOP_4A
    lea %pc@(DIFFSCAN),%a0
    subqw #2,%d0
    jbeq RGNOP_4A
    lea %pc@(UNIONSCAN),%a0
    subqw #2,%d0
    jbeq RGNOP_4A
    lea %pc@(XORSCAN),%a0
    subqw #2,%d0
    jbeq RGNOP_4A
    lea %pc@(INSETSCAN),%a0
RGNOP_4A:               /* scan buffers on the stack: a fifth of the stack left (min 40, max 30000 bytes, even) */
    movel %a0,%fp@(-82)
    moveal 0x594,%a0
    jsr %a0@
    subil #1600,%d0
    cmpil #200,%d0
    jbge RGNOP_68
    movew #40,%d0
    jbra RGNOP_76
RGNOP_68:               /* a fifth */
    divsw #5,%d0
    jbvc RGNOP_72
    movew #30000,%d0
RGNOP_72:               /* even */
    bclr #0,%d0
RGNOP_76:               /* five scan buffers */
    subaw %d0,%sp
    movel %sp,%fp@(-4)
    subaw %d0,%sp
    movel %sp,%fp@(-8)
    subaw %d0,%sp
    movel %sp,%fp@(-12)
    subaw %d0,%sp
    movel %sp,%fp@(-16)
    subaw %d0,%sp
    movel %sp,%fp@(-20)
    moveal %fp@(16),%a0
    moveal %a0@,%a0
    movel %a0,%fp@(-30)
    andiw #-8,%fp@(14)
    moveq #0,%d4
    movew %fp@(14),%d4
    addal %d4,%a0
    movel %a0,%fp@(-34)
    moveal %fp@(-4),%a0
    movel %a0,%d4
    movew #32767,%d0
    movew %d0,%a0@
    moveal %fp@(-8),%a0
    movel %a0,%d5
    movew %d0,%a0@
    moveal %fp@(-12),%a0
    movel %a0,%d6
    movew %d0,%a0@
    moveal %fp@(-16),%a0
    movel %a0,%d7
    movew %a3@+,%fp@(-22)
    movew %a4@+,%fp@(-24)
    cmpiw #8,%fp@(12)
    jbne RGNOP_E6
    movew %d0,%fp@(-24)
RGNOP_E6:               /* next row: from region A, B or both, whichever comes first */
    movew %fp@(-22),%d0
    cmpw %fp@(-24),%d0
    jbeq RGNOP_110
    jbgt RGNOP_11A
    jbsr RGNOP_F6
    jbra RGNOP_132

RGNOP_F6:               /* row change in A: apply its inversion points to A's scan (XORSCAN) */
    movew %fp@(-22),%fp@(-26)
    moveal %a3,%a0
    moveal %d4,%a1
    moveal %d7,%a2
    jsr %pc@(XORSCAN)
    moveal %a0,%a3
    movew %a3@+,%fp@(-22)
    exg %d4,%d7
    rts
RGNOP_110:              /* both: the end (32767)? done */
    cmpiw #32767,%d0
    jbeq RGNOP_21A
    jbsr RGNOP_F6
RGNOP_11A:              /* row change in B: apply its points to B's scan */
    movew %fp@(-24),%fp@(-26)
    moveal %a4,%a0
    moveal %d5,%a1
    moveal %d7,%a2
    jsr %pc@(XORSCAN)
    moveal %a0,%a4
    movew %a4@+,%fp@(-24)
    exg %d7,%d5
RGNOP_132:              /* combine the two scans with the operation (sect/union/diff via fp-82, inset d2) */
    moveal %d4,%a0
    moveal %d5,%a1
    moveal %d7,%a2
    movew %fp@(10),%d2
    pea %pc@(RGNOP_146)
    movel %fp@(-82),%sp@-
    rts
RGNOP_146:              /* the change from the previous result row (XORSCAN) is the new row's points: append them */
    moveal %d7,%a0
    moveal %d6,%a1
    moveal %fp@(-20),%a2
    jsr %pc@(XORSCAN)
    exg %d7,%d6
    moveal %fp@(-20),%a0
    moveal %fp@(-30),%a1
    moveal %fp@(-34),%a2
    movel %fp@(-26),%d0
    jbra RGNOP_16E
RGNOP_166:              /* append a point (v, h) */
    movew %a0@+,%d0
    movel %d0,%a1@+
    movew %a0@+,%d0
    movel %d0,%a1@+
RGNOP_16E:              /* output buffer full? grow the result handle (or just count when only sizing, fp+8) */
    cmpal %a2,%a1
    jbcs RGNOP_1C0
    tstb %fp@(8)
    jbeq RGNOP_216
    movel %a0,%d1
    moveal %fp@(24),%a0
    subal %a0@,%a3
    moveal %fp@(20),%a0
    subal %a0@,%a4
    moveal %fp@(16),%a0
    subal %a0@,%a1
    subal %a0@,%a2
    lea %a2@(256),%a2
    moveml %d0-%d2/%a0-%a2,%sp@-
    movel %a0,%sp@-
    movew %a2,%sp@-
    jbsr SETHSIZE
    moveml %sp@+,%d0-%d2/%a0-%a2
    moveal %fp@(24),%a0
    addal %a0@,%a3
    moveal %fp@(20),%a0
    addal %a0@,%a4
    moveal %fp@(16),%a0
    addal %a0@,%a1
    addal %a0@,%a2
    movel %a2,%fp@(-34)
    moveal %d1,%a0
RGNOP_1C0:              /* end of this row's points? next row */
    cmpiw #32767,%a0@
    jbne RGNOP_166
    movel %a1,%fp@(-30)
    jbra RGNOP_E6

RGNOP_1CE:              /* a rectangular region: build its 2-row form in the temporary buffer a2 */
    moveal %a0@,%a1
    moveal %a1@,%a1
    cmpiw #10,%a1@
    jbne RGNOP_210
    movel %a2,%a0@
    lea %a2@(-6),%a0
    movel %a0,%a2@+
    movel %a1@(2),%a2@+
    movew %a1@(8),%a2@
    movew #32767,%d0
    cmpw %a2@+,%d0
    jbne RGNOP_1F4
    subqw #1,%a2@(-2)
RGNOP_1F4:              /* top row: left, right */
    movew %d0,%a2@+
    movew %a1@(6),%a2@
    cmpw %a2@+,%d0
    jbne RGNOP_202
    subqw #1,%a2@(-2)
RGNOP_202:              /* bottom row; the end markers */
    movew %a1@(4),%a2@+
    movew %a1@(8),%a2@+
    movew %d0,%a2@+
    movew %d0,%a2@+
    moveal %a0,%a1
RGNOP_210:              /* a0 = its first row */
    lea %a1@(10),%a0
    rts
RGNOP_216:              /* end of the result */
    movel %a1,%fp@(-30)
RGNOP_21A:              /* the number of points (result); restore the stack */
    movel %fp@(-30),%d0
    moveal %fp@(16),%a0
    subl %a0@,%d0
    lsrw #2,%d0
    movew %d0,%fp@(28)
    moveal %fp@(-86),%sp
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #20
    .long   0x00000000, 0x00000000	| 4083D488
/* SECTSCAN: SectScan: intersect two region scan lines (lists of inversion points ending with 32767) into a2 */
SECTSCAN:
    clrw %d2
    clrw %d3
    jbra UNIONSCAN_4
/* DIFFSCAN: DiffScan: the difference of two region scan lines */
DIFFSCAN:
    clrw %d2
    jbra UNIONSCAN_2
/* UNIONSCAN: UnionScan: the union of two region scan lines; SECTSCAN and DIFFSCAN enter with other flags (d2, d3) */
UNIONSCAN:              /* union: both inside flags start true (d2, d3 = -1) */
    moveq #-1,%d2
UNIONSCAN_2:            /* difference: d2 = 0 */
    moveq #-1,%d3
UNIONSCAN_4:            /* first point of each scan */
    movew %a0@+,%d0
    movew %a1@+,%d1
UNIONSCAN_8:            /* same position in both: the end? toggle both, output it when the flags agree */
    cmpw %d1,%d0
    jblt UNIONSCAN_24
    jbgt UNIONSCAN_30
    cmpiw #32767,%d0
    jbeq UNIONSCAN_3C
    cmpw %d3,%d2
    jbne UNIONSCAN_1A
    movew %d0,%a2@+
UNIONSCAN_1A:           /* advance both */
    movew %a0@+,%d0
    notw %d2
    movew %a1@+,%d1
    notw %d3
    jbra UNIONSCAN_8
UNIONSCAN_24:           /* A first: output it when B is "in" (d3) */
    tstw %d3
    jbeq UNIONSCAN_2A
    movew %d0,%a2@+
UNIONSCAN_2A:           /* advance A */
    movew %a0@+,%d0
    notw %d2
    jbra UNIONSCAN_8
UNIONSCAN_30:           /* B first: output it when A is "in" (d2) */
    tstw %d2
    jbeq UNIONSCAN_36
    movew %d1,%a2@+
UNIONSCAN_36:           /* advance B */
    movew %a1@+,%d1
    notw %d3
    jbra UNIONSCAN_8
UNIONSCAN_3C:           /* end of the scan (32767) */
    movew #32767,%a2@+
    rts
    .long   0x00000000	| 4083D4DC
/* INSETSCAN: InsetScan: inset a scan line's segments by d2 (negative: outset, merging overlaps) */
INSETSCAN:
    tstw %d2
    jblt INSETSCAN_1C
INSETSCAN_4:            /* inset: each segment shrinks by d2 at both ends; segments that vanish are dropped */
    cmpiw #32767,%a0@
    jbeq INSETSCAN_3E
    movew %a0@+,%d0
    movew %a0@+,%d1
    addw %d2,%d0
    subw %d2,%d1
    cmpw %d1,%d0
    jbge INSETSCAN_4
    movew %d0,%a2@+
    movew %d1,%a2@+
    jbra INSETSCAN_4
INSETSCAN_1C:           /* outset: segments grow and merge with the previous one when they touch */
    moveaw #-32767,%a1
    jbra INSETSCAN_38
INSETSCAN_22:           /* next segment grown by -d2: overlapping the last? merge */
    movew %a0@+,%d0
    movew %a0@+,%d1
    addw %d2,%d0
    subw %d2,%d1
    cmpw %a1,%d0
    jbgt INSETSCAN_32
    subqw #2,%a2
    jbra INSETSCAN_34
INSETSCAN_32:           /* new segment: start */
    movew %d0,%a2@+
INSETSCAN_34:           /* end */
    movew %d1,%a2@+
    moveaw %d1,%a1
INSETSCAN_38:           /* more segments? */
    cmpiw #32767,%a0@
    jbne INSETSCAN_22
INSETSCAN_3E:           /* end marker */
    movew #32767,%a2@+
    rts
INSETSCAN_44:           /* (from XORSCAN) equal points cancel; the end marker ends both */
    cmpiw #32767,%d0
    jbeq INSETSCAN_3E

/* XORSCAN: XorScan: merge two sorted scan lines, dropping points present in both */
XORSCAN:
    movew %a0@+,%d0
    movew %a1@+,%d1
XORSCAN_4:              /* merge the two sorted lists; equal points cancel (INSETSCAN_44) */
    cmpw %d1,%d0
    jbeq INSETSCAN_44
    jblt XORSCAN_10
    movew %d1,%a2@+
    movew %a1@+,%d1
    jbra XORSCAN_4
XORSCAN_10:             /* from A */
    movew %d0,%a2@+
    movew %a0@+,%d0
    jbra XORSCAN_4

/* SEEDCFILL: SeedCFill(src, dst, srcRect, dstRect, seed, matchProc, refCon): the color seed fill; CALCCMASK's body with the seed search */
trap_SeedCFill:
SEEDCFILL:
    linkw %fp,#-30
    movel %fp@(16),%sp@-
    pea %fp@(-10)
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x165c,%za0)@(0)	| 4083D54C
    lea %pc@(CALCCMASK_1A2),%a0
    moveq #-1,%d0
    jbra CALCCMASK_16

/* CALCCMASK: CalcCMask(src, dst, srcRect, dstRect, seedRGB, matchProc, refCon): a 1-bit mask of the source area not reachable from the edges through pixels other than seedRGB; with SEEDCFILL the area reachable from the seed point */
trap_CalcCMask:
CALCCMASK:
    linkw %fp,#-30
    moveal %fp@(16),%a0
    lea %fp@(-10),%a1
    movel %a0@+,%a1@+
    movew %a0@+,%a1@+
    lea %pc@(CALCCMASK_1CE),%a0
    moveq #0,%d0
CALCCMASK_16:           /* save registers */
    moveml %d3-%d5/%a2-%a4,%sp@-
    movel %d0,%d5
    movel %fp@(12),%d0
    jbne CALCCMASK_26
    movel %a0,%fp@(12)
CALCCMASK_26:           /* save the colors, black on white, a temporary 1-bit device and pixmap for the mask, cleared */
    pea %fp@(-24)
    jsr @(0x1664,%za0)@(0x0)	| 4083D584
    movel #33,%sp@-
    jsr @(0xf88,%za0)@(0)	| 4083D590
    pea %fp@(-30)
    jsr @(0x1668,%za0)@(0x0)	| 4083D59A
    movel #30,%sp@-
    jsr @(0xf8c,%za0)@(0)	| 4083D5A6
    clrl %sp@-
    jsr %pc@(GETTEMPDEVICE)
    moveal %sp@+,%a4
    movel TheGDevice,%fp@(-18)
    movel %a4,TheGDevice
    moveal %a4@,%a0
    moveal %a0@(22),%a0
    _HLock
    moveal %a0@,%a3
    moveal %a4@,%a1
    lea %fp@(-10),%a0
    movel %a0,%a1@(26)
    movel %fp@(8),%fp@(-4)
    movel %fp@(12),%sp@-
    jsr @(0x16e8,%za0)@(0)	| 4083D5DC
    moveal %fp@(24),%a0
    movel %a0@+,%d1
    movel %a0@+,%d0
    movew %d0,%d4
    subw %d1,%d4
    extl %d4
    moveq #15,%d2
    addl %d2,%d4
    asrl #4,%d4
    jble CALCCMASK_16C
    addw %d4,%d4
    lea %a3@(4),%a0
    movew %d4,%a0@
    oriw #-32768,%a0@+
    movel %d1,%a0@+
    movel %d0,%a0@+
    swap %d1
    swap %d0
    subw %d1,%d0
    muluw %d0,%d4
    movel %d4,%d0
    moveq #15,%d1
    addl %d1,%d0
    .short  0xA122	| 4083D618 _NewHandle (flags 0x0100)
    jbne CALCCMASK_16C
    moveal %a0@,%a1
    lsrl #4,%d4
    movel %d4,%d0
    swap %d0
CALCCMASK_CC:           /* clear the buffer */
    movel %d5,%a1@+
    movel %d5,%a1@+
    movel %d5,%a1@+
    movel %d5,%a1@+
    dbf %d4,CALCCMASK_CC
    dbf %d0,CALCCMASK_CC
    movel %a0,%fp@(-14)
    _HLock
    movel %a0@,%a3@
    movel %fp@(32),%sp@-
    movel %a3,%sp@-
    movel %fp@(24),%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    clrl %sp@-
    jsr @(0x11b0,%za0)@(0)	| 4083D64E
    moveal %fp@(28),%a0
    movel %a0@+,%d0
    _StripAddress
    moveal %d0,%a1
    movew %a0@+,%d0
    movel %a0@+,%d1
    moveal %fp@(20),%a0
    movel %a0@+,%d2
    movel %a0@,%d3
    movel %fp@(16),%d4
    subw %d2,%d3
    addiw #15,%d3
    asrw #4,%d3
    jble CALCCMASK_166
    subw %d1,%d4
    subw %d1,%d2
    addw %d2,%d4
    asrw #3,%d2
    addaw %d2,%a1
    swap %d1
    swap %d2
    swap %d3
    swap %d4
    subw %d2,%d3
    jble CALCCMASK_166
    subw %d1,%d4
    subw %d1,%d2
    addw %d2,%d4
    swap %d4
    mulsw %d0,%d2
    addal %d2,%a1
    movel %a3@,%sp@-
    movel %a1,%sp@-
    movew %a3@(4),%d1
    andiw #32767,%d1
    movew %d1,%sp@-
    movew %d0,%sp@-
    movel %d3,%sp@-
    tstw %d5
    jbeq CALCCMASK_160
    movel %d4,%sp@-
    jsr @(0xee4,%za0)@(0)	| 4083D6B2
    jbra CALCCMASK_166
CALCCMASK_160:          /* SeedFill / CalcMask on the 1-bit result */
    jsr @(0xee0,%za0)@(0)	| 4083D6BA
CALCCMASK_166:          /* dispose of the buffer */
    moveal %fp@(-14),%a0
    _DisposHandle
CALCCMASK_16C:          /* restore the device, dispose of the temporary one, restore the colors */
    movel %fp@(12),%sp@-
    jsr @(0x1730,%za0)@(0x0)	| 4083D6CA
    movel %fp@(-18),TheGDevice
    movel %a4,%sp@-
    jsr @(0x16c0,%za0)@(0)	| 4083D6D8
    pea %fp@(-24)
    jsr @(0x1650,%za0)@(0x0)	| 4083D6E2
    pea %fp@(-30)
    jsr @(0x1654,%za0)@(0x0)	| 4083D6EC
    moveml %sp@+,%d3-%d5/%a2-%a4
    unlk %fp
    rtd #28
CALCCMASK_1A2:          /* SeedCFill's default match proc: pixels of the seed color are "1" */
    moveq #0,%d1
    moveq #1,%d0
CALCCMASK_1A6:          /* compare the pixel's RGB with the reference; exchange the results for SeedCFill */
    movew #256,%sp@(12)
    moveal %sp@(8),%a0
    moveal TheGDevice,%a1
    moveal %a1@,%a1
    moveal %a1@(26),%a1
    cmpml %a0@+,%a1@+
    jbne CALCCMASK_1C4
    cmpmw %a0@+,%a1@+
    jbne CALCCMASK_1C4
    exg %d0,%d1
CALCCMASK_1C4:          /* store the result */
    moveal %sp@(4),%a0
    movel %d0,%a0@
    rtd #8
CALCCMASK_1CE:          /* CalcCMask's default match proc: pixels of the edge color are "0" */
    moveq #1,%d1
    moveq #0,%d0
    jbra CALCCMASK_1A6
    .short  0x0000	| 4083D72E

/* GETTEMPDEVICE: GetTempDevice: a temporary 1-bit device (NewGDevice with mode -1) for the mask calculation */
GETTEMPDEVICE:
    movel %a4,%sp@-
    clrl %sp@-
    clrw %sp@-
    movel MinusOne,%sp@-
    jsr @(0x16bc,%za0)@(0)	| 4083D73A
    moveal %sp@+,%a4
    moveal %a4,%a0
    _HUnlock
    moveal %a4@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    clrw %a0@(30)
    movew #1,%a0@(32)
    movew #1,%a0@(36)
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    clrl %sp@-
    jsr @(0x16a0,%za0)@(0)	| 4083D766
    movel %sp@,%a0@
    moveal %a4@,%a0
    moveal %a0@(6,%za0)@(0),%a0	| 4083D770
    movel %sp@+,%a0@
    movel %a4,%sp@(8)
    moveal %sp@+,%a4
    rts
