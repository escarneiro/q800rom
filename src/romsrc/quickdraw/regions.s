/*
 quickdraw/regions.s - regions
 From NEWRGN (0x40836040). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* NEWRGN: _NewRgn. */
trap_NewRgn:
NEWRGN:
    moveq #10,%d0
    .short  0xA122	| 40836042 _NewHandle (flags 0x0100)
    movel %a0,%sp@(4)
    tstw %d0
    jbne NEWRGN_16
    moveal %a0@,%a0
    movew #10,%a0@+
    clrl %a0@+
    clrl %a0@+
NEWRGN_16:              /* return */
    rts
    .long   0x00000000, 0x00000000	| 40836058

/* DISPOSERGN: _DisposeRgn. */
trap_DisposRgn:
DISPOSERGN:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _DisposHandle
    jmp %a1@
    .long   0x00000000, 0x00000000	| 40836068

/* OPENRGN: _OpenRgn: start recording a region. */
trap_OpenRgn:
OPENRGN:
    moveml %d3/%a2-%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a0
    moveq #1,%d0
    movel %d0,%a0@(96)
    clrw %a4@(-150)
    clrl %sp@-
    movew #256,%sp@-
    movew %sp@,%a4@(-152)
    jsr %pc@(NEWHANDLE)
    movel %sp@+,%a4@(-148)
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x1058,%za0)@(0x0)	| 40836094
    moveml %sp@+,%d3/%a2-%a4
    rts

/* CLOSERGN: _CloseRgn. */
trap_CloseRgn:
CLOSERGN:
    linkw %fp,#-2
    moveml %d3/%a2-%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a0
    tstl %a0@(96)
    jbeq CLOSERGN_62
    clrl %a0@(96)
    jsr @(0x105c,%za0)@(0)	| 408360B6
    movew %a4@(-150),%d0
    cmpiw #-147,QDErr
    jbne CLOSERGN_2E
    moveq #0,%d0
    movew %d0,QDErr
CLOSERGN_2E:            /* the points collected (4 bytes each): sort (SORTPOINTS), cull pairs (CULLPOINTS), pack into the region (PACKRGN); free the buffer, show the pen */
    lsrw #2,%d0
    movew %d0,%fp@(-2)
    moveal %a4@(-148),%a3
    movel %a3@,%sp@-
    movew %d0,%sp@-
    jsr @(0x1a98,%za0)@(0)	| 408360DC
    movel %a3@,%sp@-
    pea %fp@(-2)
    jsr @(0x1a18,%za0)@(0)	| 408360E8
    movel %a3,%sp@-
    movew %fp@(-2),%sp@-
    movel %fp@(8),%sp@-
    jsr @(0x1a48,%za0)@(0)	| 408360F8
    moveal %a3,%a0
    _DisposHandle
CLOSERGN_62:            /* restore registers, return */
    moveml %sp@+,%d3/%a2-%a4
    unlk %fp
    rtd #4
    .long   0x00000000	| 4083610C

/* COPYRGN: _CopyRgn. */
trap_CopyRgn:
COPYRGN:
    linkw %fp,#0
    moveal %fp@(12),%a0
    moveal %fp@(8),%a1
    cmpal %a0,%a1
    jbeq COPYRGN_46
    moveal %a0@,%a0
    moveal %a1@,%a1
    movew %a0@,%d0
    cmpw %a1@,%d0
    jbeq COPYRGN_38
    moveml %d0/%d3/%a2,%sp@-
    movel %fp@(8),%sp@-
    movew %d0,%sp@-
    jsr %pc@(SETHSIZE)
    moveml %sp@+,%d0/%d3/%a2
    moveal %fp@(12),%a0
    moveal %fp@(8),%a1
    moveal %a0@,%a0
    moveal %a1@,%a1
COPYRGN_38:             /* copy the region: longs then a last word */
    lsrw #2,%d0
    jbcc COPYRGN_42
    movew %a0@+,%a1@+
    jbra COPYRGN_42
COPYRGN_40:             /* copy a long */
    movel %a0@+,%a1@+
COPYRGN_42:             /* next */
    dbf %d0,COPYRGN_40
COPYRGN_46:             /* return */
    unlk %fp
    rtd #8
    .long   0x00000000	| 4083615C

/* SETEMPTYRGN: _SetEmptyRgn. */
trap_SetEmptyRgn:
SETEMPTYRGN:
    moveal %sp@+,%a0
    clrl %sp@-
    clrl %sp@-
    movel %a0,%sp@-
    jmp %pc@(trap_SetRecRgn)
    .long   0x00000000	| 4083616C

/* SETRECTRGN: _SetRectRgn. */
trap_SetRecRgn:
SETRECTRGN:
    linkw %fp,#0
    moveml %d3/%a2,%sp@-
    moveal %fp@(16),%a0
    moveal %a0@,%a1
    moveq #10,%d0
    cmpw %a1@,%d0
    jbeq SETRECTRGN_26
    movel %a0,%sp@-
    movew %d0,%sp@-
    jsr %pc@(SETHSIZE)
    moveal %fp@(16),%a0
    moveal %a0@,%a1
    movew #10,%a1@
SETRECTRGN_26:          /* rgnBBox = the rectangle; empty: all zero */
    movel %fp@(12),%a1@(2)
    movel %fp@(8),%a1@(6)
    movew %a1@(4),%d0
    cmpw %a1@(8),%d0
    jbge SETRECTRGN_46
    movew %a1@(2),%d0
    cmpw %a1@(6),%d0
    jblt SETRECTRGN_4E
SETRECTRGN_46:          /* empty */
    clrl %a1@(2)
    clrl %a1@(6)
SETRECTRGN_4E:          /* restore registers, return */
    moveml %sp@+,%d3/%a2
    unlk %fp
    rtd #12
    .long   0x00000000, 0x00000000	| 408361C8

/* RECTRGN: _RectRgn. */
trap_RectRgn:
RECTRGN:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a1@+,%sp@-
    movel %a1@+,%sp@-
    movel %a0,%sp@-
    jmp %pc@(trap_SetRecRgn)
    .short  0x0000	| 408361DE

/* OFFSETRGN: _OffsetRgn. */
trap_OffsetRgn:
OFFSETRGN:
    moveal %sp@+,%a1
    movew %sp@+,%d1
    movew %sp@+,%d0
    moveal %sp@+,%a0
    moveal %a0@,%a0
    addqw #2,%a0
    addw %d1,%a0@+
    addw %d0,%a0@+
    addw %d1,%a0@+
    addw %d0,%a0@+
    cmpiw #10,%a0@(-10)
    jbeq OFFSETRGN_30
OFFSETRGN_1C:           /* next row: its v */
    addw %d1,%a0@+
OFFSETRGN_1E:           /* each h of the row, until 32767; then the next row, until 32767 */
    addw %d0,%a0@+
    addw %d0,%a0@+
    cmpiw #32767,%a0@
    jbne OFFSETRGN_1E
    addqw #2,%a0
    cmpiw #32767,%a0@
    jbne OFFSETRGN_1C
OFFSETRGN_30:           /* return */
    jmp %a1@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40836212

/* INSETRGN: _InsetRgn. */
trap_InsetRgn:
INSETRGN:
    linkw %fp,#0
    moveml %d3-%d7/%a2-%a4,%sp@-
    movel %fp@(8),%d6
    jbeq INSETRGN_3C
    moveal %fp@(12),%a4
    moveal %a4@,%a3
    movew %a3@+,%d7
    cmpiw #10,%d7
    jbne INSETRGN_3E
    movel %a3,%sp@-
    movel %d6,%sp@-
    jsr @(0x10a4,%za0)@(0)	| 40836240
    movew %a3@(2),%d0
    cmpw %a3@(6),%d0
    jbge INSETRGN_38
    movew %a3@,%d0
    cmpw %a3@(4),%d0
    jblt INSETRGN_3C
INSETRGN_38:            /* empty */
    clrl %a3@+
    clrl %a3@+
INSETRGN_3C:            /* done */
    jbra INSETRGN_98
INSETRGN_3E:            /* non-rectangular: inset horizontally (INSETRGN_52), then transposed again for vertical */
    addw %d7,%d7
    clrl %sp@-
    movew %d7,%sp@-
    jsr %pc@(NEWHANDLE)
    moveal %sp@+,%a3
    jbsr INSETRGN_52
    swap %d6
    jbsr INSETRGN_52
    jbra INSETRGN_94

INSETRGN_52:            /* RgnOp inset of each row's scan by d6; transpose the points (h, v swapped), sort and pack */
    clrw %sp@-
    movel %a4,%sp@-
    movel %a4,%sp@-
    movel %a3,%sp@-
    movew %d7,%sp@-
    movew #8,%sp@-
    movew %d6,%sp@-
    st %sp@-
    jsr @(0x1a80,%za0)@(0)	| 40836284
    movew %sp@+,%d5
    moveal %a3@,%a0
    movew %d5,%d1
    jbra INSETRGN_78
INSETRGN_72:            /* swap v and h of each point */
    movel %a0@,%d0
    swap %d0
    movel %d0,%a0@+
INSETRGN_78:            /* next point; sort and pack into the region */
    dbf %d1,INSETRGN_72
    movel %a3@,%sp@-
    movew %d5,%sp@-
    jsr @(0x1a98,%za0)@(0)	| 408362A0
    movel %a3,%sp@-
    movew %d5,%sp@-
    movel %a4,%sp@-
    jsr @(0x1a48,%za0)@(0)	| 408362AC
    rts

INSETRGN_94:            /* dispose of the buffer */
    moveal %a3,%a0
    _DisposHandle

INSETRGN_98:            /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408362C2

/* EMPTYRGN: _EmptyRgn. */
trap_EmptyRgn:
EMPTYRGN:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    moveal %a1@,%a1
    pea %a1@(2)
    movel %a0,%sp@-
    jmp @(0x10b8,%za0)@(0)	| 408362DC
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408362E2

/* EQUALRGN: _EqualRgn. */
trap_EqualRgn:
EQUALRGN:
    moveal %sp@(4),%a0
    moveal %sp@(8),%a1
    cmpal %a0,%a1
    jbeq EQUALRGN_2E
    moveal %a0@,%a0
    moveal %a1@,%a1
    movew %a0@,%d0
    movew %d0,%d1
    lsrw #2,%d1
    subqw #1,%d1
EQUALRGN_18:            /* compare long by long */
    cmpml %a0@+,%a1@+
    dbne %d1,EQUALRGN_18
    jbne EQUALRGN_32
    andiw #3,%d0
    jbeq EQUALRGN_2E
EQUALRGN_26:            /* then the remaining bytes */
    cmpmb %a0@+,%a1@+
    jbne EQUALRGN_32
    subqw #1,%d0
    jbne EQUALRGN_26
EQUALRGN_2E:            /* equal */
    moveq #1,%d0
    jbra EQUALRGN_34
EQUALRGN_32:            /* different */
    moveq #0,%d0
EQUALRGN_34:            /* return the boolean */
    moveb %d0,%sp@(12)
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
    .short  0x0000	| 4083632E

/* SECTRGN: _SectRgn. */
trap_SectRgn:
SECTRGN:
    moveq #0,%d0
    jbra DORGNOP

/* UNIONRGN: _UnionRgn. */
trap_UnionRgn:
UNIONRGN:
    moveq #4,%d0
    jbra DORGNOP

/* DIFFRGN: _DiffRgn. */
trap_DiffRgn:
DIFFRGN:
    moveq #2,%d0
    jbra DORGNOP

/* XORRGN: _XorRgn. */
trap_XOrRgn:
XORRGN:
    moveq #6,%d0

/* DORGNOP: region operation (sect, union, diff, xor) on two regions. */
DORGNOP:
    linkw %fp,#-8
    moveml %d3-%d7/%a2-%a4,%sp@-
    movew %d0,%d5
    moveal %fp@(16),%a2
    moveal %fp@(12),%a3
    moveal %fp@(8),%a4
    moveq #2,%d7
    clrb %sp@-
    movel %a2,%sp@-
    movel %a3,%sp@-
    jsr @(0x118c,%za0)@(0)	| 4083635C
    tstb %sp@+
    jbeq DORGNOP_42
    andw %d7,%d5
    jbne DORGNOP_38
DORGNOP_2C:             /* the result is a copy of a2 (CopyRgn) */
    movel %a2,%sp@-
    movel %a4,%sp@-
    jsr @(0x1170,%za0)@(0x0)	| 4083636E
    jbra DORGNOP_90
DORGNOP_38:             /* the result is empty (SetEmptyRgn) */
    movel %a4,%sp@-
    jsr @(0x1174,%za0)@(0x0)	| 40836378
    jbra DORGNOP_90
DORGNOP_42:             /* shortcuts: rectangles or empty operands by the operation (d5: 0 sect, 2 union, 4 diff, 6 xor) */
    moveal %a2@,%a0
    moveal %a3@,%a1
    cmpw %d7,%d5
    jbgt DORGNOP_92
    jblt DORGNOP_56
    movew %a1@(4),%d0
    cmpw %a1@(8),%d0
    jbge DORGNOP_2C
DORGNOP_56:             /* do the bounding boxes intersect? no: sect gives empty, the others a copy */
    pea %a0@(2)
    pea %a1@(2)
    movew %d7,%sp@-
    pea %fp@(-8)
    jsr @(0x1a84,%za0)@(0)	| 408363A2
    jbne DORGNOP_72
    tstw %d5
    jbeq DORGNOP_38
    jbra DORGNOP_2C
DORGNOP_72:             /* sect of two rectangles: the intersection rectangle */
    moveal %a2@,%a0
    moveal %a3@,%a1
    tstw %d5
    jbne DORGNOP_AA
    moveq #10,%d0
    cmpw %a0@,%d0
    jbne DORGNOP_AA
    cmpw %a1@,%d0
    jbne DORGNOP_AA
    movel %a4,%sp@-
    pea %fp@(-8)
    jsr @(0x117c,%za0)@(0)	| 408363C8
DORGNOP_90:             /* done */
    jbra DORGNOP_E6
DORGNOP_92:             /* diff/xor with an empty operand: a copy of the other */
    movew %a1@(4),%d0
    cmpw %a1@(8),%d0
    jbge DORGNOP_2C
    movew %a0@(4),%d0
    cmpw %a0@(8),%d0
    jblt DORGNOP_AA
    moveal %a3,%a2
    jbra DORGNOP_2C
DORGNOP_AA:             /* general case: a buffer for the points, RGNOP, sort and pack into the result */
    movew %a0@,%d4
    addw %a1@,%d4
    addw %d4,%d4
    clrl %sp@-
    movew %d4,%sp@-
    jsr %pc@(NEWHANDLE)
    moveal %sp@+,%a3
    clrw %sp@-
    movel %fp@(16),%sp@-
    movel %fp@(12),%sp@-
    movel %a3,%sp@-
    movew %d4,%sp@-
    movew %d5,%sp@-
    clrw %sp@-
    st %sp@-
    jsr @(0x1a80,%za0)@(0)	| 4083640C
    movew %sp@+,%d6
    movel %a3,%sp@-
    movew %d6,%sp@-
    movel %a4,%sp@-
    jsr @(0x1a48,%za0)@(0)	| 4083641A
    moveal %a3,%a0
    _DisposHandle
DORGNOP_E6:             /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #12
    .short  0x0000	| 4083642E

/* PTINRGN: _PtInRgn. */
trap_PtInRgn:
PTINRGN:
    linkw %fp,#0
    movel %d3,%sp@-
    movew %fp@(14),%d1
    movew %fp@(12),%d2
    clrw %d3
    moveal %fp@(8),%a0
    moveal %a0@,%a0
    cmpw %a0@(4),%d1
    jblt PTINRGN_50
    cmpw %a0@(8),%d1
    jbge PTINRGN_50
    cmpw %a0@(2),%d2
    jblt PTINRGN_50
    cmpw %a0@(6),%d2
    jbge PTINRGN_50
    cmpiw #10,%a0@
    jbne PTINRGN_38
    notw %d3
    jbra PTINRGN_50
PTINRGN_38:             /* walk the rows above the point */
    lea %a0@(10),%a0
PTINRGN_3C:             /* next row: past the point's v? done */
    cmpw %a0@+,%d2
    jblt PTINRGN_50
PTINRGN_40:             /* each h left of the point toggles inside/outside */
    movew %a0@+,%d0
    cmpiw #32767,%d0
    jbeq PTINRGN_3C
    cmpw %d1,%d0
    jbgt PTINRGN_40
    notw %d3
    jbra PTINRGN_40
PTINRGN_50:             /* return the boolean */
    negb %d3
    moveb %d3,%fp@(16)
    movel %sp@+,%d3
    unlk %fp
    rtd #8
    .short  0x0000	| 4083648E

/* RECTINRGN: _RectInRgn. */
trap_RectInRgn:
RECTINRGN:
    linkw %fp,#-36
    moveml %d0-%d7/%a1-%a5,%sp@-
    movel %sp,%fp@(-12)
    clrb %fp@(16)
    moveal %fp@(8),%a1
    moveal %a1@,%a1
    movel %fp@(12),%sp@-
    pea %a1@(2)
    movew #2,%sp@-
    pea %fp@(-8)
    jsr @(0x1a84,%za0)@(0)	| 408364B6
    jbeq RECTINRGN_7E
    cmpiw #10,%a1@
    jbeq RECTINRGN_7A
    moveal %a1,%a0
    lea %fp@(-36),%a1
    movew %fp@(-6),%d0
    movew %fp@(-2),%d1
    movew %d0,%d2
    jsr @(0x1c54,%za0)@(0)	| 408364D4
    movew %a1@(12),%d5
    movew %fp@(-8),%d0
    jsr @(0x1a88,%za0)@(0)	| 408364E2
    movew %fp@(-4),%d6
RECTINRGN_5C:           /* rows inside the rectangle: any bit set in the region's scan for the rectangle? */
    moveal %a1@(8),%a0
    movew %d5,%d0
RECTINRGN_62:           /* test the scan buffer */
    tstl %a0@+
    dbne %d0,RECTINRGN_62
    jbne RECTINRGN_7A
    movew %a1@(16),%d0
    cmpw %d0,%d6
    jble RECTINRGN_7E
    jsr @(0x1a88,%za0)@(0)	| 40836502
    jbra RECTINRGN_5C
RECTINRGN_7A:           /* yes: true */
    addqb #1,%fp@(16)
RECTINRGN_7E:           /* return */
    moveal %fp@(-12),%sp
    moveml %sp@+,%d0-%d7/%a1-%a5
    unlk %fp
    rtd #8
    .long   0x00000000	| 4083651C

/* TRIMRECT: TrimRect(rgn, rect): clip the rectangle to a rectangular region; returns whether the result is empty; non-rectangular regions are left to the caller */
trap_TRIMRECT:
TRIMRECT:
    linkw %fp,#0
    moveml %d0-%d7/%a1-%a5,%sp@-
    moveal %fp@(10),%a0
    moveml %a0@,%d4-%d5
    movel %d4,%d6
    swap %d6
    moveal %fp@(14),%a3
    moveal %a3@,%a3
    movew %a3@,%d2
    cmpiw #10,%d2
    jbeq TRIMRECT_104
    lea %a3@(10),%a3
    moveal 0x594,%a0
    jsr %a0@
    subil #1600,%d0
    extl %d2
    cmpl %d2,%d0
    jbge TRIMRECT_4A
    movew %d5,%d2
    subw %d4,%d2
    extl %d2
    lsll #2,%d2
    cmpl %d0,%d2
    jble TRIMRECT_4A
    jbra TRIMRECT_104
TRIMRECT_4A:            /* two scan buffers on the stack; walk the region's rows */
    lsrl #1,%d2
    bclr #0,%d2
    moveal %sp,%a0
    subal %d2,%sp
    moveal %sp,%a4
    subal %d2,%sp
    moveal %sp,%a5
    moveq #0,%d2
    movew #32767,%d7
    moveal %a4,%a1
    jbra TRIMRECT_68
TRIMRECT_64:            /* end of a row? */
    cmpw %d7,%d0
    jbne TRIMRECT_74
TRIMRECT_68:            /* next row: past the rectangle's bottom? done */
    movew %d7,%a1@
    cmpw %a3@+,%d6
    jblt TRIMRECT_B0
    moveal %a4,%a2
    moveal %a5,%a1
    exg %a4,%a5
TRIMRECT_74:            /* next point of the old scan */
    movew %a2@+,%d1
TRIMRECT_76:            /* next point of the row */
    movew %a3@+,%d0
TRIMRECT_78:            /* merge the row's points into the scan (equal points cancel) */
    cmpw %d1,%d0
    jbeq TRIMRECT_64
    jblt TRIMRECT_84
    movew %d1,%a1@+
    movew %a2@+,%d1
    jbra TRIMRECT_78
TRIMRECT_84:            /* a point inside the rectangle's width: keep it */
    cmpw %d4,%d0
    jble TRIMRECT_90
    cmpw %d0,%d5
    jble TRIMRECT_76
    movew %d0,%a1@+
    jbra TRIMRECT_76
TRIMRECT_90:            /* left of the rectangle: count it (parity) */
    addqw #1,%d2
    jbra TRIMRECT_76
TRIMRECT_94:            /* rows below the rectangle's top: check the inversions crossing the rectangle */
    movew %a3@+,%d0
    cmpw %d4,%d0
    jble TRIMRECT_A4
    cmpw %d0,%d7
    jbeq TRIMRECT_C8
    cmpw %d0,%d5
    jble TRIMRECT_94
    jbra TRIMRECT_AA
TRIMRECT_A4:            /* skip */
    movew %a3@+,%d0
    cmpw %d4,%d0
    jble TRIMRECT_94
TRIMRECT_AA:            /* not a rectangle inside: Z clear */
    cmpiw #0,%d7
    jbra TRIMRECT_102
TRIMRECT_B0:            /* more than one segment inside: not trimmable */
    subal %a4,%a1
    movew %a1,%d3
    cmpiw #4,%d3
    jbgt TRIMRECT_102
    jblt TRIMRECT_C2
    andiw #1,%d2
    jbne TRIMRECT_AA
TRIMRECT_C2:            /* one segment */
    movel %d5,%d6
    swap %d6
    subqw #2,%a3
TRIMRECT_C8:            /* next row inside the rectangle */
    cmpw %a3@+,%d6
    jbgt TRIMRECT_94
    tstw %fp@(8)
    jbne TRIMRECT_D8
    tstw %d3
    jbeq TRIMRECT_FC
    jbra TRIMRECT_AA
TRIMRECT_D8:            /* trim the rectangle to the segment */
    moveal %fp@(10),%a1
    movew %d2,%d0
    cmpiw #2,%d3
    jblt TRIMRECT_FC
    jbgt TRIMRECT_F2
    btst #0,%d0
    jbne TRIMRECT_F6
    movew %a4@,%a1@(2)
    jbra TRIMRECT_100
TRIMRECT_F2:            /* left */
    movew %a4@+,%a1@(2)
TRIMRECT_F6:            /* right */
    movew %a4@,%a1@(6)
    jbra TRIMRECT_100
TRIMRECT_FC:            /* parity of the points left of it */
    moveq #1,%d0
    andw %d0,%d2
TRIMRECT_100:           /* set the flags */
    cmpw %d0,%d2
TRIMRECT_102:           /* free the buffers */
    moveal %a0,%sp
TRIMRECT_104:           /* restore registers, return */
    moveml %sp@+,%d0-%d7/%a1-%a5
    unlk %fp
    rtd #10
    .short  0x0000	| 4083662E

/* MAPRGN: _MapRgn. */
trap_MapRgn:
MAPRGN:
    linkw %fp,#-6
    moveml %d3/%d6-%d7/%a2-%a4,%sp@-
    moveal %fp@(12),%a0
    moveal %fp@(8),%a1
    cmpml %a0@+,%a1@+
    jbne MAPRGN_18
    cmpml %a0@+,%a1@+
    jbeq MAPRGN_36
MAPRGN_18:              /* a rectangular region: MapRect its box */
    moveal %fp@(16),%a4
    moveal %a4@,%a0
    cmpiw #10,%a0@
    jbne MAPRGN_38
    pea %a0@(2)
    movel %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    jsr @(0x11e8,%za0)@(0)	| 40836660
MAPRGN_36:              /* done */
    jbra MAPRGN_AC
MAPRGN_38:              /* general: the region's points (unpacked into a 256-byte growing buffer), each mapped */
    clrl %sp@-
    movew #256,%sp@-
    movew %sp@,%fp@(-4)
    jsr %pc@(NEWHANDLE)
    moveal %sp@+,%a3
    clrw %fp@(-2)
    movel %a4,%sp@-
    movel %a3,%sp@-
    pea %fp@(-2)
    pea %fp@(-4)
    jsr @(0x1a6c,%za0)@(0)	| 40836688
    movew %fp@(-2),%d7
    lsrw #2,%d7
    movew %d7,%d6
    moveal %a3@,%a2
    jbra MAPRGN_7C
MAPRGN_6A:              /* MapPt each point */
    movel %a2,%sp@-
    movel %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    jsr @(0x11e4,%za0)@(0)	| 408366A4
    addql #4,%a2
MAPRGN_7C:              /* next; sort, cull and pack into the region */
    dbf %d6,MAPRGN_6A
    movel %a3@,%sp@-
    movew %d7,%sp@-
    jsr @(0x1a98,%za0)@(0)	| 408366B4
    movel %a3@,%sp@-
    movew %d7,%fp@(-6)
    pea %fp@(-6)
    jsr @(0x1a18,%za0)@(0)	| 408366C4
    movel %a3,%sp@-
    movew %fp@(-6),%sp@-
    movel %a4,%sp@-
    jsr @(0x1a48,%za0)@(0)	| 408366D2
    moveal %a3,%a0
    _DisposHandle
MAPRGN_AC:              /* restore registers, return */
    moveml %sp@+,%d3/%d6-%d7/%a2-%a4
    unlk %fp
    rtd #12
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408366E6

/* BITMAPRGN: _BitMapToRegion. */
trap_BitMapRgn:
BITMAPRGN:
    linkw %fp,#-30
    moveml %d3-%d7/%a2-%a5,%sp@-
    clrl %fp@(-12)
    clrw %fp@(16)
    moveal %fp@(12),%a0
    moveal %a0@,%a2
    moveq #0,%d0
    movew %a2@,%d0
    movel %d0,%fp@(-26)
    moveal %fp@(8),%a1
    movew %a1@(4),%d0
    jbpl BITMAPRGN_42
    btst #14,%d0
    jbeq BITMAPRGN_32
    moveal %a1@,%a0
    moveal %a0@,%a1
BITMAPRGN_32:           /* only 1-bit bitmaps: else pixmapTooDeepErr (-148) */
    cmpiw #1,%a1@(32)
    jbeq BITMAPRGN_42
    movew #-148,%d0
    jbra BITMAPRGN_298
BITMAPRGN_42:           /* row bytes, bounds; empty: an empty region; buffers for two rows */
    movew %a1@(4),%fp@(-16)
    andiw #32767,%fp@(-16)
    movel %a1@(6),%d2
    movew %a1@(12),%d0
    subw %d2,%d0
    jble BITMAPRGN_29C
    extl %d0
    movel %d0,%d4
    addl %d4,%d4
    addql #6,%d4
    addl %d4,%d4
    movel %d4,%fp@(-30)
    moveq #32,%d7
    divuw %d7,%d0
    movel %d0,%d3
    swap %d3
    moveq #-1,%d1
    tstw %d3
    jbeq BITMAPRGN_7E
    addqw #1,%d0
    subw %d3,%d7
    asll %d7,%d1
BITMAPRGN_7E:           /* the previous-row buffer; the right edge mask */
    movel %d1,%fp@(-8)
    extl %d0
    movel %d0,%fp@(-4)
    asll #2,%d0
    .short  0xA322	| 4083677A _NewHandle (flags 0x0300)
    jbne BITMAPRGN_298
    movel %a0,%fp@(-12)
    movel %d2,%d3
    swap %d3
    movew %a1@(10),%d0
    subw %d3,%d0
    jble BITMAPRGN_29C
    movew %d0,%fp@(-14)
    moveal %a1@,%a4
    movew #10,%d7
BITMAPRGN_AC:           /* the region data */
    moveal %fp@(12),%a2
    moveal %a2@,%a2
BITMAPRGN_B2:           /* next row: room for a worst-case row? grow the region by the step */
    lea %a2@(0x0,%d7:w),%a5
    movel %fp@(-26),%d1
    subw %d7,%d1
    cmpl %fp@(-30),%d1
    jbge BITMAPRGN_DA
    movel %fp@(-26),%d0
    addl %fp@(-30),%d0
    movel %d0,%fp@(-26)
    moveal %fp@(12),%a0
    _SetHandleSize
    jbne BITMAPRGN_298
    jbra BITMAPRGN_AC
BITMAPRGN_DA:           /* start the row: its v; compare with the previous row long by long */
    movew %d2,%d4
    moveq #0,%d6
    moveal %a4,%a1
    movel %fp@(-4),%d5
    moveal %fp@(-12),%a3
    moveal %a3@,%a3
    movew %d3,%d0
    jbsr BITMAPRGN_23A
    movew %d7,%fp@(-18)
    jbra BITMAPRGN_1EA
BITMAPRGN_F8:           /* next long of the bitmap row */
    movel %a1@+,%d0
BITMAPRGN_FA:           /* unchanged from the previous row: no inversion points (a pending one closed) */
    movel %a3@,%d1
    eorl %d0,%d1
    jbne BITMAPRGN_1AE
    tstb %d6
    jbeq BITMAPRGN_10A
    movew %d4,%a5@+
    moveq #0,%d6
BITMAPRGN_10A:          /* next 32 pixels */
    addiw #32,%d4
    addqw #4,%a3
    jbra BITMAPRGN_1EA
BITMAPRGN_114:          /* nibble handlers: one per 4-bit change pattern, emitting an h for each bit that changes */
    addqw #3,%d4	| 40836804
BITMAPRGN_116:          /* emit */
    movew %d4,%a5@+	| 40836806
    addqw #1,%d4	| 40836808
BITMAPRGN_11A:          /* toggle the inside state */
    notb %d6
    rts
BITMAPRGN_11E:          /* pattern */
    addqw #2,%d4	| 4083680E
    movew %d4,%a5@+	| 40836810
BITMAPRGN_122:          /* pattern */
    jbsr BITMAPRGN_14A
BITMAPRGN_124:          /* pattern */
    addqw #1,%d4
    rts
BITMAPRGN_128:          /* pattern */
    addqw #2,%d4	| 40836818
    movew %d4,%a5@+	| 4083681A
    addqw #2,%d4	| 4083681C
    jbra BITMAPRGN_11A	| 4083681E
BITMAPRGN_130:          /* pattern */
    jbsr BITMAPRGN_14A
    jbsr BITMAPRGN_14A
BITMAPRGN_134:          /* pattern */
    addqw #2,%d4
    rts
BITMAPRGN_138:          /* pattern */
    jbsr BITMAPRGN_130	| 40836828
    subqw #1,%d4	| 4083682A
    jbra BITMAPRGN_116	| 4083682C
BITMAPRGN_13E:          /* pattern */
    jbsr BITMAPRGN_14A	| 4083682E
    addqw #1,%d4	| 40836830
    jbra BITMAPRGN_122	| 40836832
BITMAPRGN_144:          /* pattern */
    jbsr BITMAPRGN_14A	| 40836834
    addqw #3,%d4	| 40836836
    jbra BITMAPRGN_11A	| 40836838

BITMAPRGN_14A:          /* emit h + 1 */
    addqw #1,%d4
    movew %d4,%a5@+
    rts
BITMAPRGN_150:          /* pattern */
    movew %d4,%a5@+	| 40836840
    jbsr BITMAPRGN_14A	| 40836842
    addqw #3,%d4	| 40836844
    rts	| 40836846
BITMAPRGN_158:          /* pattern */
    movew %d4,%a5@+	| 40836848
    jbsr BITMAPRGN_14A	| 4083684A
    addqw #2,%d4	| 4083684C
    jbra BITMAPRGN_116	| 4083684E
BITMAPRGN_160:          /* pattern */
    movew %d4,%a5@+	| 40836850
    jbsr BITMAPRGN_14A
    jbsr BITMAPRGN_14A
    jbra BITMAPRGN_122
BITMAPRGN_168:          /* pattern */
    movew %d4,%a5@+	| 40836858
    jbsr BITMAPRGN_14A
    jbsr BITMAPRGN_14A
    addqw #2,%d4
    jbra BITMAPRGN_11A
BITMAPRGN_172:          /* pattern */
    movew %d4,%a5@+	| 40836862
    addqw #2,%d4	| 40836864
    movew %d4,%a5@+	| 40836866
    jbra BITMAPRGN_134	| 40836868
BITMAPRGN_17A:          /* pattern */
    jbsr BITMAPRGN_172	| 4083686A
    subqw #1,%d4	| 4083686C
    jbra BITMAPRGN_116	| 4083686E
BITMAPRGN_180:          /* pattern */
    movew %d4,%a5@+	| 40836870
    addqw #3,%d4	| 40836872
    movew %d4,%a5@+	| 40836874
    jbra BITMAPRGN_124	| 40836876
BITMAPRGN_188:          /* jump table: 16 branches, one per 4-bit value (jsr %pc@(BITMAPRGN_188,%d0:w)) */
    bras BITMAPRGN_1AA	| 40836878
    bras BITMAPRGN_114	| 4083687A
    bras BITMAPRGN_11E	| 4083687C
    bras BITMAPRGN_128	| 4083687E
    bras BITMAPRGN_130	| 40836880
    bras BITMAPRGN_138	| 40836882
    bras BITMAPRGN_13E	| 40836884
    bras BITMAPRGN_144	| 40836886
    bras BITMAPRGN_150	| 40836888
    bras BITMAPRGN_158	| 4083688A
    bras BITMAPRGN_160	| 4083688C
    bras BITMAPRGN_168	| 4083688E
    bras BITMAPRGN_172	| 40836890
    bras BITMAPRGN_17A	| 40836892
    bras BITMAPRGN_180	| 40836894
    movew %d4,%a5@+	| 40836896
    notb %d6	| 40836898
BITMAPRGN_1AA:          /* no change: skip 4 pixels */
    addqw #4,%d4	| 4083689A
    rts	| 4083689C
BITMAPRGN_1AE:          /* changed: save the new long; by byte */
    movel %d0,%a3@+
    moveq #3,%d7
    moveq #0,%d0
BITMAPRGN_1B4:          /* next byte: no change? skip 8 pixels */
    roll #8,%d1
    tstb %d1
    jbne BITMAPRGN_1CC
    tstb %d6
    jbne BITMAPRGN_1CC
    addqw #8,%d4
    jbra BITMAPRGN_1E6
BITMAPRGN_1C2:          /* last long: masked to the right edge */
    movel %a1@,%d0
    andl %fp@(-8),%d0
    jbra BITMAPRGN_FA
BITMAPRGN_1CC:          /* both nibbles through the jump table */
    moveb %d1,%d0
    eorb %d6,%d0
    lsrb #4,%d0
    addw %d0,%d0
    jsr %pc@(BITMAPRGN_188,%d0:w)
    moveb %d1,%d0
    eorb %d6,%d0
    andiw #15,%d0
    addw %d0,%d0
    jsr %pc@(BITMAPRGN_188,%d0:w)
BITMAPRGN_1E6:          /* next byte */
    dbf %d7,BITMAPRGN_1B4
BITMAPRGN_1EA:          /* next long; end of row: no points? drop the v; else close it */
    subqw #1,%d5
    jbgt BITMAPRGN_F8
    jbeq BITMAPRGN_1C2
    movew %a5,%d7
    subw %a2,%d7
    cmpw %fp@(-18),%d7
    jbeq BITMAPRGN_230
    jblt BITMAPRGN_294
    tstb %d6
    jbeq BITMAPRGN_208
    movew %d4,%a5@+
    addqw #2,%d7
BITMAPRGN_208:          /* end of row */
    jbsr BITMAPRGN_236
BITMAPRGN_20A:          /* next row; after the last, one more all-zero row to close everything */
    addqw #1,%d3
    movew %d2,%d4
    addaw %fp@(-16),%a4
    subqw #1,%fp@(-14)
    jbgt BITMAPRGN_B2
    jblt BITMAPRGN_240
    movel %fp@(-4),%d0
    asll #2,%d0
    .short  0xA322	| 40836912 _NewHandle (flags 0x0300)
    jbne BITMAPRGN_298
    movel %a0,%fp@(-22)
    moveal %a0@,%a4
    jbra BITMAPRGN_AC
BITMAPRGN_230:          /* no points: take back the v */
    subql #2,%a5
    subqw #2,%d7
    jbra BITMAPRGN_20A
BITMAPRGN_236:          /* the row end (32767) */
    movew #32767,%d0
BITMAPRGN_23A:          /* store a word */
    movew %d0,%a5@+
    addqw #2,%d7
    rts
BITMAPRGN_240:          /* done: free the buffer; compute the bounding box from the points */
    moveal %fp@(-22),%a0
    _DisposHandle
    cmpiw #10,%d7
    jbeq BITMAPRGN_29C
    jbsr BITMAPRGN_236
    jbmi BITMAPRGN_294
    lea %a2@(10),%a0
    movew #32767,%d4
    movew %d4,%d1
    movew #-32768,%d2
    movew %a0@,%d3
    jbra BITMAPRGN_27A
BITMAPRGN_262:          /* each row: its first h (left) */
    moveal %a0,%a1
    cmpw %a0@+,%d1
    jble BITMAPRGN_26C
    movew %a0@(-2),%d1
BITMAPRGN_26C:          /* its last h (right) */
    cmpw %a0@+,%d4
    jbne BITMAPRGN_26C
    cmpw %a0@(-4),%d2
    jbge BITMAPRGN_27A
    movew %a0@(-4),%d2
BITMAPRGN_27A:          /* next row; a single rectangle (28 bytes) becomes a rectangular region */
    movew %a0@+,%d0
    cmpw %d4,%d0
    jbne BITMAPRGN_262
    swap %d3
    movew %d1,%d3
    movew %a1@(-2),%d4
    swap %d4
    movew %d2,%d4
    cmpiw #28,%d7
    jbeq BITMAPRGN_2A6
    jbra BITMAPRGN_2A8
BITMAPRGN_294:          /* region too big (over 32K): rgnTooBigError (-500) */
    movew #-500,%d0

BITMAPRGN_298:          /* the error */
    movew %d0,%fp@(16)
BITMAPRGN_29C:          /* empty region */
    moveal %fp@(12),%a0
    moveal %a0@,%a2
    moveq #0,%d3
    moveq #0,%d4
BITMAPRGN_2A6:          /* rectangular */
    moveq #10,%d7
BITMAPRGN_2A8:          /* rgnSize, rgnBBox, size the handle; free the row buffer */
    movew %d7,%a2@+
    movel %d3,%a2@+
    movel %d4,%a2@
    movel %d7,%d0
    moveal %fp@(12),%a0
    _SetHandleSize
    moveal %fp@(-12),%a0
    _DisposHandle
    moveml %sp@+,%d3-%d7/%a2-%a5
    unlk %fp
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
    .long   0x00000000, 0x00000000	| 408369B8

/* INITRGN: InitRgn: set up a SEEKRGN state record (a1) for the region at a0: bounds, the scan buffer, the first row */
trap_INITRGN:
INITRGN:
    movew %d0,%a1@(18)
    movew %d1,%a1@(20)
    movew %d2,%a1@(22)
    movel %a0,%d0
    jsr @(0x644,%za0)@(0x0)	| 408369CE
    moveal %d0,%a0
    movel %a0,%a1@
    movew #-32767,%a1@(14)
    movew %a0@(2),%a1@(16)
    lea %a0@(10),%a0
    movel %a0,%a1@(4)
    moveal %sp@+,%a0
    subw %d2,%d1
    subqw #1,%d1
    lsrw #5,%d1
    movew %d1,%a1@(12)
INITRGN_38:             /* the scan buffer on the stack, cleared */
    clrl %sp@-
    dbf %d1,INITRGN_38
    movel %sp,%a1@(8)
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 40836A04

/* SEEKRGN: SeekRgn: the region's scan line at v (for clipping). */
trap_SEEKRGN:
SEEKRGN:
    cmpw %a1@(16),%d0
    jbge SEEKDOWN
    cmpw %a1@(14),%d0
    jblt SEEKUP
    movew %a1@(16),%d1
    subw %d0,%d1
    movew %d0,%d2
    subw %a1@(14),%d2
    cmpw %d1,%d2
    jblt SEEKRGN_1E
    movew %d1,%d2
SEEKRGN_1E:             /* return */
    rts
SEEKRGN_20:             /* restart from the top: clear the scan, back to the first row */
    moveal %a1@(8),%a0
    movew %a1@(12),%d1
SEEKRGN_28:             /* clear */
    clrl %a0@+
    dbf %d1,SEEKRGN_28
    moveal %a1@,%a0
    movew %a0@(2),%a1@(16)
    movew #-32767,%a1@(14)
    lea %a0@(10),%a0
    movel %a0,%a1@(4)
    cmpw %a1@(16),%d0
    jbge SEEKDOWN
    moveq #1,%d2
    jbra SEEKDOWN_3A

/* SEEKDOWN: SeekDown: move a region state down to row d0, applying each row's inversion points to the scan buffer */
SEEKDOWN:
    moveml %d0/%d3-%d7/%a2-%a4,%sp@-
    movew %d0,%d2
    moveal %a1@(4),%a2
    lea %pc@(SEEKDOWN_1A),%a4
    movew %a1@(18),%d6
    movew %a1@(20),%d7
SEEKDOWN_16:            /* next row's v */
    movew %a2@+,%a1@(14)
SEEKDOWN_1A:            /* each point of the row: toggle the scan from h (SEEKUP_5E) */
    movew %a2@+,%d3
    cmpiw #32767,%d3
    jbeq SEEKDOWN_26
    movew %a2@+,%d4
    jbra SEEKUP_5E
SEEKDOWN_26:            /* next row past the target? stop */
    cmpw %a2@,%d2
    jbge SEEKDOWN_16
    subw %a2@,%d2
    negw %d2
    movew %a2@,%a1@(16)
    movel %a2,%a1@(4)
    moveml %sp@+,%d0/%d3-%d7/%a2-%a4
SEEKDOWN_3A:            /* return */
    rts

/* SEEKUP: SeekUp: move a region state up to row d0: start again from the top (SEEKRGN) unless already there */
SEEKUP:
    moveal %a1@,%a0
    movew %a0@(2),%d1
    cmpw %d1,%d0
    jblt SEEKRGN_20
    moveml %d0/%d3-%d7/%a2-%a5,%sp@-
    movew %d0,%d2
    lea %a0@(10),%a5
    lea %pc@(SEEKUP_26),%a4
    movew %a1@(18),%d6
    movew %a1@(20),%d7
SEEKUP_20:              /* back one row */
    moveal %a1@(4),%a2
    subqw #2,%a2
SEEKUP_26:              /* undo the row's points (toggle again) */
    movew %a2@-,%d4
    movew %a2@-,%d3
    cmpiw #32767,%d3
    jbeq SEEKUP_32
    jbra SEEKUP_5E
SEEKUP_32:              /* the row's start */
    movel %a2,%d0
    addql #2,%d0
    movel %d0,%a1@(4)
    movew %d4,%a1@(16)
SEEKUP_3E:              /* find the previous row's start */
    movew %a2@-,%d4
    cmpal %a5,%a2
    jble SEEKUP_4C
    movew %a2@-,%d3
    cmpiw #32767,%d3
    jbne SEEKUP_3E
SEEKUP_4C:              /* up to the target row */
    movew %d4,%a1@(14)
    cmpw %d4,%d2
    jblt SEEKUP_20
    subw %d4,%d2
    addqw #1,%d2
    moveml %sp@+,%d0/%d3-%d7/%a2-%a5
    rts

SEEKUP_5E:              /* toggle the scan between two h's, clipped to the scan's range */
    cmpw %d6,%d4
    jble SEEKUP_A2
    cmpw %d7,%d3
    jbge SEEKUP_A2
    cmpw %d6,%d3
    jbge SEEKUP_6C
    movew %d6,%d3
SEEKUP_6C:              /* right clip */
    cmpw %d7,%d4
    jble SEEKUP_72
    movew %d7,%d4
SEEKUP_72:              /* relative to the scan's left; edge masks */
    subw %a1@(22),%d3
    subw %a1@(22),%d4
    moveq #31,%d0
    movew %d3,%d1
    andw %d0,%d1
    moveq #-1,%d5
    lsrl %d1,%d5
    andw %d4,%d0
    moveq #-1,%d1
    lsrl %d0,%d1
    notl %d1
    lsrw #5,%d3
    moveal %a1@(8),%a3
    movew %d3,%d0
    lslw #2,%d0
    addaw %d0,%a3
    lsrw #5,%d4
    subw %d3,%d4
    jbgt SEEKUP_A4
    andl %d5,%d1
    eorl %d1,%a3@
SEEKUP_A2:              /* return to the caller loop */
    jmp %a4@
SEEKUP_A4:              /* first long */
    eorl %d5,%a3@+
    jbra SEEKUP_AC
SEEKUP_A8:              /* middle longs */
    notl %a3@+
    notl %a3@+
SEEKUP_AC:              /* next */
    subqw #2,%d4
    jbgt SEEKUP_A8
    jblt SEEKUP_B4
    notl %a3@+
SEEKUP_B4:              /* last long */
    eorl %d1,%a3@
    jmp %a4@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40836B52

/* STRETCHBITS: StretchBits: CopyBits with scaling, color translation, dithering and masks. */
trap_STRETCHBITS:
STRETCHBITS:
    linkw %fp,#-712
    moveml %d0-%d7/%a1-%a5,%sp@-
    movel %sp,%fp@(-460)
    movel %a5,%fp@(-464)
    moveb MMU32Bit,%fp@(-258)
    clrl %fp@(-32)
    clrl %fp@(-692)
    movel %sp,%d1
    andib #0xfc,%d1
    moveal %d1,%sp
    movel TheGDevice,%sp@-
    movel SrcDevice,TheGDevice
    moveal %fp@(48),%a1
    lea %fp@(-360),%a2
    jsr @(0x1a08,%za0)@(0)	| 40836B98
    movel %sp@+,TheGDevice
    moveal %fp@(40),%a1
    lea %fp@(-244),%a2
    jsr @(0x1a08,%za0)@(0)	| 40836BAA
    movel %d1,%fp@(-580)
    moveb %d2,%fp@(-576)
    lea %pc@(SHFTTBL),%a0
    movew %fp@(-328),%d0
    moveq #0,%d3
    moveb %a0@(0x0,%d0:w),%d3
    movew %d3,%fp@(-450)
    movew %fp@(-212),%d0
    moveq #0,%d4
    moveb %a0@(0x0,%d0:w),%d4
    movew %d4,%fp@(-118)
    movel %fp@(44),%d0
    jbeq STRETCHBITS_9C
    moveal %d0,%a1
    lea %fp@(-440),%a2
    jsr @(0x1a08,%za0)@(0)	| 40836BE4
    clrw %fp@(-452)
    movew %fp@(-408),%d0
    cmpiw #1,%d0
    jbeq STRETCHBITS_9C
    clrl %fp@(44)
STRETCHBITS_9C:         /* clip the destination rectangle by the three regions' boxes (SectRect) */
    movel %fp@(28),%sp@-
    pea %fp@(-238)
    moveal %fp@(18),%a0
    moveal %a0@,%a0
    pea %a0@(2)
    moveal %fp@(14),%a0
    moveal %a0@,%a0
    pea %a0@(2)
    moveal %fp@(10),%a0
    moveal %a0@,%a0
    pea %a0@(2)
    movew #5,%sp@-
    pea %fp@(-116)
    jsr @(0x1a84,%za0)@(0)	| 40836C2A
    jbeq DONESTRETCH_1E
    movel %fp@(22),%fp@(-156)
    movew %fp@(26),%fp@(-152)
    tstw %fp@(0x28,%za0)@(0x4)	| 40836C40
    smi %fp@(-166)
    bclr #6,%fp@(-151)
    sne %fp@(-165)
    moveb %fp@(8),%fp@(-257)
    jsr @(0x1a10,%za0)@(0)	| 40836C5C
    moveq #0,%d7
    movew %fp@(-152),%d2
    btst #5,%d2
    jbne STRETCHBITS_116
    bclr #2,%d2
    jbeq STRETCHBITS_116
    notl %d7
STRETCHBITS_116:        /* color mapping (COLORMAP when needed) */
    movel %d7,%fp@(-456)
    clrw %fp@(-142)
    btst #3,%d2
    jbeq STRETCHBITS_12A
    jsr @(0x1a54,%za0)@(0)	| 40836C84
STRETCHBITS_12A:        /* on the screen: shield the cursor */
    tstb %fp@(-576)
    jbeq STRETCHBITS_13E
    pea %fp@(-116)
    movel %fp@(-580),%sp@-
    jsr @(0xf54,%za0)@(0)	| 40836C98
STRETCHBITS_13E:        /* row bytes of source, mask and destination; pixel sizes and shifts */
    lea %fp@(-360),%a4
    movew #32767,%d0
    extl %d0
    movew %a4@(4),%d1
    andl %d0,%d1
    movel %d1,%fp@(-444)
    lea %fp@(-440),%a0
    movew %a0@(4),%d1
    andl %d0,%d1
    movel %d1,%fp@(-448)
    lea %fp@(-244),%a5
    movew %a5@(4),%d1
    andl %d0,%d1
    movel %d1,%fp@(-124)
    moveal %fp@(36),%a2
    movel %a2,%d0
    jsr @(0x644,%za0)@(0x0)	| 40836CD4
    movel %d0,%fp@(36)
    moveal %fp@(28),%a3
    movel %a3,%d0
    jsr @(0x644,%za0)@(0x0)	| 40836CE4
    movel %d0,%fp@(28)
    movew %fp@(-152),%d0
    rorw #4,%d0
    jbcs BLITCASE_4E
    movew %a2@(4),%d1
    subw %a2@,%d1
    swap %d1
    movew %a2@(6),%d1
    subw %a2@(2),%d1
    movew %d1,%d0
    subqw #1,%d0
    movew %d0,%fp@(-556)
    movew %a3@(4),%d0
    subw %a3@,%d0
    swap %d0
    movew %a3@(6),%d0
    subw %a3@(2),%d0
    jsr @(0x1c60,%za0)@(0)	| 40836D1E

/* BLITCASE: BlitCase: StretchBits' choice of path: same size and no mask: SCALEBLT or the fast 8/1-bit copies (fp-693); otherwise the general stretch */
trap_BLITCASE:
BLITCASE:
    clrb %fp@(-693)
    tstl %fp@(44)
    jbne BLITCASE_142
    cmpl %d0,%d1
    jbne BLITCASE_142
    cmpw %d3,%d4
    jbeq BLITCASE_32
    cmpiw #16,%fp@(-330)
    jbne BLITCASE_BE
    moveal @(TheGDevice,%za0)@(0),%a0	| 40836D44
    tstl %a0@(12)
    jbne BLITCASE_142
    jbra BLITCASE_BE
BLITCASE_32:            /* same pixel size: same color table? then a plain blit */
    cmpiw #16,%fp@(-214)
    jbeq BLITCASE_4E
    moveal %fp@(-318),%a0
    moveal %a0@,%a0
    movel %a0@,%d2
    moveal %fp@(-202),%a0
    moveal %a0@,%a0
    cmpl %a0@,%d2
    jbeq BLITCASE_4E
    jbne BLITCASE_BE
BLITCASE_4E:            /* the regions: all rectangles? else their intersection */
    moveq #10,%d0
    moveal %fp@(10),%a0
    moveal %a0@,%a0
    cmpw %a0@,%d0
    jbne BLITCASE_120
    moveal %fp@(14),%a0
    moveal %a0@,%a0
    cmpw %a0@,%d0
    jbeq BLITCASE_8C
    movel %fp@(14),%sp@-
    pea %fp@(-116)
    movew #-1,%sp@-
    jsr @(0x1aa4,%za0)@(0)	| 40836D96
    jblt DONESTRETCH
    jbgt BLITCASE_120
    moveal %fp@(-464),%a1
    moveal %a1@,%a1
    movel %a1@(-130),%fp@(14)
BLITCASE_8C:            /* third region */
    moveal %fp@(18),%a0
    moveal %a0@,%a0
    cmpw %a0@,%d0
    jbeq BLITCASE_102
    movel %fp@(18),%sp@-
    pea %fp@(-116)
    movew #-1,%sp@-
    jsr @(0x1aa4,%za0)@(0)	| 40836DC6
    jblt DONESTRETCH
    jbeq BLITCASE_102
    moveal %fp@(18),%a1
    movel %fp@(10),%fp@(18)
    movel %a1,%fp@(10)
    jbra BLITCASE_120
BLITCASE_BE:            /* no mode, no colorize: a fast path? 16 to 32-bit or 32 to 16-bit */
    tstw %fp@(-152)
    jbne BLITCASE_142
    tstw %fp@(-260)
    jbne BLITCASE_142
    tstw %d7
    jbne BLITCASE_142
    st %fp@(-693)
    cmpiw #5,%d4
    jbne BLITCASE_F4
    cmpiw #3,%d3
    jbgt BLITCASE_142
BLITCASE_DE:            /* through the direct-pixel scaler (vector 0x1C58) */
    movel 0x1c5c,%fp@(-128)
    jsr @(0x1c58,%za0)@(0)	| 40836E08
    tstw %d0
    jbeq BLITCASE_4E
    jbra DONESTRETCH
BLITCASE_F4:            /* 32 to 16 */
    cmpiw #5,%d3
    jbne BLITCASE_142
    cmpiw #3,%d4
    jbne BLITCASE_142
    jbra BLITCASE_DE
BLITCASE_102:           /* plain BitBlt (vector 0x1A00) in 32-bit addressing */
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 40836E28
    moveb %d0,%fp@(-258)
    moveal %fp@(36),%a2
    moveal %fp@(28),%a3
    jsr @(0x1a00,%za0)@(0)	| 40836E3A
    jbra DONESTRETCH
BLITCASE_120:           /* RgnBlt (vector 0x1A7C) with the stack left */
    movel 0x1c5c,%fp@(-128)
    moveal 0x594,%a0
    jsr %a0@
    lsrl #2,%d0
    subil #400,%d0
    movel %d0,%fp@(-132)
    jsr @(0x1a7c,%za0)@(0)	| 40836E5C
    jbra DONESTRETCH
BLITCASE_142:           /* set up the horizontal stretch (proc and size); the stack space for the row buffers; too little: error exit */
    moveml %d3-%d4,%sp@-
    movel %d0,%fp@(-520)
    movel %d1,%fp@(-524)
    jsr @(0x1a90,%za0)@(0)	| 40836E72
    movel %a0,%fp@(-540)
    movew %d0,%fp@(-546)
    moveml %sp@+,%d3-%d4
    moveal 0x594,%a0
    jsr %a0@
    lsrl #2,%d0
    subil #400,%d0
    movel %d0,%fp@(-132)
    jbpl BLITCASE_17A
    jsr @(0x1c5c,%za0)@(0)	| 40836E98
BLITCASE_17A:           /* stretching: the horizontal stretch proc (0x1A90); vertical shrink of 32-bit: averaging buffer (fp-682) */
    movel %fp@(-520),%d0
    movel %fp@(-524),%d1
    clrb %fp@(-682)
    cmpl %d1,%d0
    jbeq BLITCASE_1C0
    jblt BLITCASE_190
    cmpw %d1,%d0
    jbge BLITCASE_1C0
BLITCASE_190:           /* 32-bit shrink: sum buffer */
    cmpiw #5,%d3
    jbne BLITCASE_1C0
    seq %fp@(-682)
    moveq #0,%d2
    movew %d1,%d2
    addw %d2,%d2
    addw %d1,%d2
    lsrw #1,%d2
    movew %d2,%fp@(-684)
    subl %d2,%fp@(-132)
    jbpl BLITCASE_1B4
    jsr @(0x1c5c,%za0)@(0)	| 40836ED2
BLITCASE_1B4:           /* sum buffer */
    clrl %sp@-
BLITCASE_1B6:           /* clear it */
    clrl %sp@-
    dbf %d2,BLITCASE_1B6
    movel %sp,%fp@(-688)
BLITCASE_1C0:           /* depth conversion: indexed source: STSEARCHTAB path; 16/32-bit source: pick the converter */
    clrl %fp@(-552)
    movew %fp@(-330),%d0
    jbeq STSEARCHTAB_20
    cmpiw #16,%d0
    jbne DONESTRETCH
    cmpw %d3,%d4
    jbeq ONEBITPROC_4A
    moveq #4,%d0
    movel %d0,%d5
    cmpw %d3,%d5
    jbeq BLITCASE_1E4
    moveq #0,%d5
BLITCASE_1E4:           /* 16-bit */
    cmpw %d4,%d0
    jbne BLITCASE_1EA
    addqw #2,%d5
BLITCASE_1EA:           /* indexed destination: its inverse table (rebuilt if stale) */
    moveal @(TheGDevice,%za0)@(0),%a2	| 40836F0E
    cmpiw #16,%fp@(-214)
    jbeq BLITCASE_2DC
    tstw %d4
    jbne BLITCASE_20E
    moveal %fp@(40),%a1
    tstw %a1@(4)
    jbmi BLITCASE_20E
    addqw #8,%d5
    jbra BLITCASE_2EA
BLITCASE_20E:           /* build the inverse table */
    addqw #1,%d5
    moveal %a2@(0x16,%za0)@(0x0),%a1	| 40836F34
    moveal %a1@(42),%a0
    movel %a0@(0,%za0)@(0),%d1	| 40836F3E
    moveal %a2@(6,%za0)@(0),%a0
    cmpl %a0@,%d1
    jbeq BLITCASE_252
    movel %a1@(42),%sp@-
    movel %a2@(6),%sp@-
    movew %a2@(10),%sp@-
    jsr @(0x16e4,%za0)@(0)	| 40836F58
    tstw QDErr
    jbeq BLITCASE_246
    addqw #4,%sp
    jbra DONESTRETCH_4
BLITCASE_246:           /* the device */
    moveal @(TheGDevice,%za0)@(0),%a2	| 40836F6A
    moveal %a2@(6,%za0)@(0),%a0
BLITCASE_252:           /* the inverse table, its resolution, the color table; search procs? */
    addqw #6,%a0
    movel %a0,%fp@(-652)
    subqw #6,%a0
    movew %a0@(4),%fp@(-670)
    moveal %a2@(0x16,%za0)@(0x0),%a1	| 40836F84
    movel %a1@(0x2a,%za0)@(0),%fp@(-668)
    movel %a2@(12),%d0
    jbne BLITCASE_2E2
    moveq #1,%d0
    movew %a0@(4),%d2
    lsll %d2,%d0
    lsll %d2,%d0
    lsll %d2,%d0
    lea %a0@(0x6,%d0:l),%a1
    tstw %a1@(2)
    jbpl BLITCASE_298
    addqw #6,%a1
    movel %a1,%fp@(-656)
    addqw #8,%d5
    moveq #40,%d0
    cmpl %a0@,%d0
    jbeq BLITCASE_2EA
BLITCASE_298:           /* dither: an error buffer */
    tstb %fp@(-165)
    jbeq BLITCASE_2EA
    addqw #2,%d5
    moveq #0,%d0
    movew %fp@(-518),%d0
    lsll %d4,%d0
    addil #31,%d0
    lsrl %d4,%d0
    btst #3,%d5
    jbne BLITCASE_2BC
    movew %d0,%d1
    addw %d0,%d0
    addw %d1,%d0
BLITCASE_2BC:           /* size */
    lsrw #1,%d0
    subl %d0,%fp@(-132)
    jbpl BLITCASE_2CA
    jsr @(0x1c5c,%za0)@(0)	| 40836FE8
BLITCASE_2CA:           /* buffer */
    clrl %sp@-
BLITCASE_2CC:           /* clear it */
    clrl %sp@-
    dbf %d0,BLITCASE_2CC
    movel %sp,%fp@(-676)
    clrb %fp@(-681)
    jbra BLITCASE_2EA
BLITCASE_2DC:           /* direct destination: search procs? */
    movel %a2@(12),%d0
    jbeq BLITCASE_2EA
BLITCASE_2E2:           /* use them (search variant) */
    movel %d0,%fp@(-660)
    bset #4,%d5
BLITCASE_2EA:           /* the converter from the table at 0x1CA0 */
    movew %d5,%d0
    lsrw #3,%d0
    lea @(0x1ca0,%d0:w:4),%a0
    moveal %a0@,%a0
    andiw #7,%d5
    addal %a0@(0x0,%d5:w:4),%a0
    movel %a0,%fp@(-552)
    jbra ONEBITPROC_4A
    braw DONESTRETCH
    .short  0x0000	| 4083702E
