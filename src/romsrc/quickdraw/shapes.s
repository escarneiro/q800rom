/*
 quickdraw/shapes.s - polygons, round rectangles, arcs, bits (CopyBits), seed fill, scrolling, packing
 From DRAWPOLY (0x40834410). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* DRAWPOLY: DrawPoly(verb, poly): a rectangle-shaped polygon (10 + 4 points, closed) is drawn as a rectangle; else framed (FRPOLY) or filled through its sorted edges (XDRAWPOLY, PAINTVECTOR) */
DRAWPOLY:
    linkw %fp,#-8
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveal %fp@(0xe,%za0)@(0),%a0	| 40834414
    movew %a0@+,%d0
    cmpiw #30,%d0
    jbne DRAWPOLY_1E
    movel %a0@(24),%d1
    cmpl %a0@(8),%d1
    jbne DRAWPOLY_6A
    jbra DRAWPOLY_24
DRAWPOLY_1E:            /* 4 points (26 bytes)? */
    cmpiw #26,%d0
    jbne DRAWPOLY_6A
DRAWPOLY_24:            /* is it an axis-aligned rectangle (each edge horizontal or vertical)? */
    moveq #2,%d0
    addqw #8,%a0
    lea %a0@(4),%a1
DRAWPOLY_2C:            /* compare consecutive corners */
    cmpmw %a0@+,%a1@+
    seq %d1
    cmpmw %a0@+,%a1@+
    seq %d2
    orb %d1,%d2
    jbeq DRAWPOLY_6A
    dbf %d0,DRAWPOLY_2C
    lea %a0@(-12),%a1
    cmpmw %a0@+,%a1@+
    seq %d1
    cmpmw %a0@+,%a1@+
    seq %d2
    orb %d1,%d2
    jbeq DRAWPOLY_6A
    lea %fp@(-8),%a0
    movel %a0,%sp@-
    movel %a1@(-12),%a0@+
    movel %a1@(-8),%a0@
    movew %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    jbsr DRAWRECT
    jbra DRAWPOLY_150
DRAWPOLY_6A:            /* lock the polygon; a handle for its edges (8 bytes per point); then each pair of points */
    moveml %d3-%d5/%a2,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(66)
    jbmi DRAWPOLY_14C
    moveal %fp@(14),%a0
    movel %a0,%d0
    jbeq DRAWPOLY_14C
    _HLock
    moveal %a0@,%a0
    movel %a0@(2),%fp@(-8)
    movel %a0@(6),%fp@(-4)
    movew %a0@,%d4
    subiw #10,%d4
    lsrw #2,%d4
    moveq #0,%d0
    movew %d4,%d0
    addql #1,%d0
    asll #3,%d0
    .short  0xA122	| 408344B4 _NewHandle (flags 0x0100)
    tstw %d0
    jbne DRAWPOLY_146
    moveal %a0,%a2
    _HLock
    moveq #0,%d3
    moveal %fp@(14),%a1
    moveal %a1@,%a1
    addaw #10,%a1
    movel %a1@+,%d5
    movew %d4,%d2
    subql #1,%d2
    moveal %a2@,%a0
    jbra DRAWPOLY_E6
DRAWPOLY_C6:            /* build the edge vectors (start point, dv/dh) from consecutive points, skipping horizontal ones */
    movel %d5,%d4
    movel %a1@+,%d5
    movel %d4,%d0
    movel %d5,%d1
    subw %d0,%d1
    swap %d0
    swap %d1
    subw %d0,%d1
    jbeq DRAWPOLY_E6
    jbmi DRAWPOLY_DE
    movel %d4,%a0@+
    jbra DRAWPOLY_E0
DRAWPOLY_DE:            /* store the start */
    movel %d5,%a0@+
DRAWPOLY_E0:            /* count it, store the delta */
    addqw #1,%d3
    swap %d1
    movel %d1,%a0@+
DRAWPOLY_E6:            /* next point; close the polygon with the edge back to the first point */
    dbf %d2,DRAWPOLY_C6
    movel %d5,%d4
    moveal %fp@(14),%a1
    moveal %a1@,%a1
    movel %a1@(10),%d5
    cmpl %d4,%d5
    jbeq DRAWPOLY_116
    movel %d4,%d0
    movel %d5,%d1
    subw %d0,%d1
    swap %d0
    swap %d1
    subw %d0,%d1
    jbeq DRAWPOLY_116
    jbmi DRAWPOLY_10E
    movel %d4,%a0@+
    jbra DRAWPOLY_110
DRAWPOLY_10E:           /* store the start */
    movel %d5,%a0@+
DRAWPOLY_110:           /* count it, store the delta */
    addqw #1,%d3
    swap %d1
    movel %d1,%a0@+
DRAWPOLY_116:           /* sort the edges (XDRAWPOLY) and paint them (PAINTVECTOR) */
    moveal %fp@(14),%a0
    _HUnlock
    movel %a2@,%sp@-
    movew %d3,%sp@-
    jsr %pc@(XDRAWPOLY)
    movel %a2@,%sp@-
    movew %d3,%sp@-
    st %sp@-
    pea %fp@(-8)
    movew %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(PAINTVECTOR)
    moveal %a2,%a0
    _HUnlock
    moveal %a2,%a0
    _DisposHandle
    moveq #0,%d0
    jbra DRAWPOLY_14C
DRAWPOLY_146:           /* unlock */
    moveal %fp@(14),%a0
    _HUnlock
DRAWPOLY_14C:           /* restore registers */
    moveml %sp@+,%d3-%d5/%a2
DRAWPOLY_150:           /* return */
    unlk %fp
    rtd #10
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40834566

/* STDRRECT: StdRRect: the rounded rectangle bottleneck. */
trap_StdRRect:
STDRRECT:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveb %fp@(16),%d7
    jsr @(0x1a3c,%za0)@(0)	| 4083457C
    jble STDRRECT_48
    moveb %d7,%sp@-
    jsr %pc@(PUTPICVERB)
    moveal %a3@(92),%a0
    moveal %a0@,%a0
    movel %fp@(8),%d0
    cmpl %a0@(82),%d0
    jbeq STDRRECT_3A
    movel %d0,%a0@(82)
    movel %d0,%sp@-
    moveq #11,%d0
    jsr %pc@(trap_DPUTPICOP)
    jsr %pc@(PUTPICLONG)
STDRRECT_3A:            /* picture: opcode 0x40 + verb and the rectangle */
    moveq #64,%d0
    addw %d7,%d0
    moveb %d0,%sp@-
    movel %fp@(12),%sp@-
    jsr %pc@(PUTPICRECT)
STDRRECT_48:            /* draw on each screen */
    pea %pc@(STDRRECT_70)
    pea %pc@(STDRRECT_60)
    jsr @(0x1aa0,%za0)@(0)	| 408345C0
    moveml %sp@+,%d7/%a3-%a4
    unlk %fp
    rtd #10
STDRRECT_60:            /* rectangle proc */
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %fp@(12),%a0
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    moveal %d0,%a0
    jmp %a0@
STDRRECT_70:            /* draw proc: DRAWARC with the oval size; framing while a region is open adds it there */
    movel %fp@(12),%sp@-
    clrb %sp@-
    tstb %d7
    jbne STDRRECT_9E
    tstl %a3@(96)
    jbeq STDRRECT_9A
    movel %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    movel %a4@(-148),%sp@-
    pea %a4@(-150)
    pea %a4@(-152)
    jsr @(0x1a68,%za0)@(0)	| 40834604
STDRRECT_9A:            /* frame */
    moveb #1,%sp@
STDRRECT_9E:            /* DrawArc(0, 360) */
    movel %fp@(8),%sp@-
    jsr @(0x1a60,%za0)@(0)	| 40834612
    clrw %sp@-
    movew #360,%sp@-
    jsr @(0x1a24,%za0)@(0)	| 4083461E
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40834626

/* FRAMEROUNDRECT: _FrameRoundrect: frame (outline with the pen) the rounded rectangle. */
trap_FrameRoundRect:
FRAMEROUNDRECT:
    moveq #0,%d0
    jbra CALLRRECT

/* PAINTROUNDRECT: _PaintRoundrect: paint (fill with the pen pattern) the rounded rectangle. */
trap_PaintRoundRect:
PAINTROUNDRECT:
    moveq #1,%d0
    jbra CALLRRECT

/* ERASEROUNDRECT: _EraseRoundrect: erase (fill with the background) the rounded rectangle. */
trap_EraseRoundRect:
ERASEROUNDRECT:
    moveq #2,%d0
    jbra CALLRRECT

/* INVERTROUNDRECT: _InvertRoundrect: invert the rounded rectangle. */
trap_InverRoundRect:
INVERTROUNDRECT:
    moveq #3,%d0
    jbra CALLRRECT

/* FILLROUNDRECT: _FillRoundrect: fill with a pattern the rounded rectangle. */
trap_FillRoundRect:
FILLROUNDRECT:
    moveq #0,%d0
    jbra FILLCROUNDRECT_2

/* FILLCROUNDRECT: _FillCroundrect: fill with a pattern the rounded rectangle with a pixel pattern. */
trap_FillCRoundRect:
FILLCROUNDRECT:
    moveq #1,%d0
FILLCROUNDRECT_2:       /* the pixpat, then CALLRRECT with verb 4 */
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a0,%sp@-
    movel %a1,%sp@-
    jsr @(0x1a8c,%za0)@(0)	| 4083464E
    moveq #4,%d0

/* CALLRRECT: call the port's rrect bottleneck (grafProcs) or the standard one. */
CALLRRECT:
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
    moveal 0x10bc,%a0
    jbeq CALLRRECT_22
    moveal %d0,%a0
    moveal %a0@(12),%a0
CALLRRECT_22:           /* through the port's rRectProc or StdRRect */
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 4083467A

/* DRAWARC: DrawArc(verb, rect, oval, start, arc): draw an oval, rounded rectangle or arc as slabs row by row, through STDDEVLOOP-style per-device drawing */
trap_DRAWARC:
DRAWARC:
    linkw %fp,#-452
    moveml %d0-%d7/%a1-%a4,%sp@-
    movel %sp,%fp@(-292)
    clrl %fp@(-32)
    moveal %a5@,%a0
    moveal %a0@,%a4
    tstw %a4@(66)
    jblt DRAWARC_6F6
    lea %fp@(-136),%a0
    movel %a0,%a0@
    clrl %fp@(-150)
    clrw %fp@(-138)
    movew #1,%fp@(-142)
    movel %sp,%d1
    andib #0xfc,%d1
    moveal %d1,%sp
    lea %a4@(2),%a1
    lea %fp@(-244),%a2
    jsr @(0x1a08,%za0)@(0)	| 408346C0
    movel %d1,%fp@(-452)
    moveb %d2,%fp@(-358)
    lea %pc@(SHFTTBL),%a0
    movew %fp@(-212),%d0
    moveq #0,%d1
    moveb %a0@(0x0,%d0:w),%d1
    movew %d1,%fp@(-118)
    movel %fp@(12),%fp@(-156)
    movew %fp@(16),%d0
    bset #3,%d0
    moveq #16,%d1
    btst #5,%d0
    jbeq DRAWARC_7E
    cmpiw #58,%d0
    jbeq DRAWARC_84
    moveq #48,%d1
DRAWARC_7E:             /* empty? nothing to draw */
    cmpw %d1,%d0
    jbgt DRAWARC_6F6
DRAWARC_84:             /* the mode, the colors (COLORMAP), the destination and clip regions */
    movew %d0,%fp@(-152)
    tstw %a4@(6)
    smi %fp@(-166)
    clrb %fp@(-257)
    jsr @(0x1a10,%za0)@(0)	| 40834714
    moveal %a4@(28),%a2
    moveal %a2@,%a2
    moveal %a4@(24),%a3
    moveal %a3@,%a3
    movel %fp@(24),%sp@-
    pea %fp@(-238)
    pea %a2@(2)
    pea %a3@(2)
    movew #4,%sp@-
    pea %fp@(-116)
    jsr @(0x1a84,%za0)@(0)	| 4083473E
    jbeq DRAWARC_6F6
    clrb %fp@(-310)
    cmpiw #10,%a2@
    jbne DRAWARC_144
    cmpiw #10,%a3@
    jbeq DRAWARC_F0
    movel %a4@(24),%sp@-
    pea %fp@(-116)
    movew #-1,%sp@-
    jsr @(0x1aa4,%za0)@(0)	| 40834764
    jblt DRAWARC_6F6
    jbgt DRAWARC_144
DRAWARC_F0:             /* 1-bit: a solid pattern makes the mode simpler */
    btst #5,%fp@(-151)
    jbne DRAWARC_144
    moveal %fp@(-156),%a0
    tstb %fp@(-166)
    jbeq DRAWARC_110
    moveal %a0@,%a0
    moveal %a0@,%a0
    tstw %a0@
    jbne DRAWARC_144
    moveal %a0@(6),%a0
    moveal %a0@,%a0
DRAWARC_110:            /* all ones or all zeros? */
    movel %a0@+,%d0
    cmpl %a0@+,%d0
    jbne DRAWARC_144
    notl %d0
    jbeq DRAWARC_124
    notl %d0
    jbne DRAWARC_144
    eoriw #4,%fp@(-152)
DRAWARC_124:            /* map the mode; a no-op: done */
    st %fp@(-310)
    moveq #7,%d0
    andw %fp@(-152),%d0
    moveb %pc@(DRAWARC_13C,%d0:w),%d0
    jbmi DRAWARC_6F6
    movew %d0,%fp@(-152)
    jbra DRAWARC_144
DRAWARC_13C:            /* mode map (data) */
    .long   0x00000102	| 408347BC
    .long   0x02FFFFFF	| 408347C0
DRAWARC_144:            /* the arc: arcAngle 0: nothing; negative: from start + arc, positive */
    clrb %fp@(-410)
    movew %fp@(8),%d0
    jbeq DRAWARC_6F6
    jbpl DRAWARC_15C
    addw %d0,%fp@(10)
    negw %d0
    movew %d0,%fp@(8)
DRAWARC_15C:            /* less than 360: an arc (fp-409); start angle mod 360 */
    cmpiw #360,%d0
    slt %fp@(-409)
    jbge DRAWARC_2B4
    movew %fp@(10),%d0
    extl %d0
    divsw #360,%d0
    swap %d0
    tstw %d0
    jbpl DRAWARC_17C
    addiw #360,%d0
DRAWARC_17C:            /* end angle */
    movew %d0,%fp@(10)
    addw %fp@(8),%d0
    cmpiw #360,%d0
    jblt DRAWARC_18E
    subiw #360,%d0
DRAWARC_18E:            /* the center and the slopes of the two edges of the wedge */
    movew %d0,%fp@(-412)
    moveal %fp@(24),%a0
    movew %a0@,%d0
    addw %a0@(4),%d0
    asrw #1,%d0
    movew %d0,%fp@(-414)
    movew %a0@(2),%d0
    addw %a0@(6),%d0
    asrw #1,%d0
    movew %d0,%fp@(-416)
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    movew %d0,%fp@(-418)
    movew %a0@(4),%d0
    subw %a0@,%d0
    movew %d0,%fp@(-420)
    clrl %sp@-
    movew %fp@(-418),%sp@-
    movew %fp@(-420),%sp@-
    jsr @(0xfa4,%za0)@(0)	| 40834850
    movel %sp@+,%d7
    clrl %sp@-
    movew %fp@(10),%sp@-
    jsr @(0x10f0,%za0)@(0)	| 4083485E
    movel %sp@+,%d0
    clrl %sp@-
    movel %d0,%sp@-
    movel %d7,%sp@-
    jsr @(0xfa0,%za0)@(0)	| 4083486C
    movel %sp@+,%fp@(-424)
    clrl %sp@-
    movew %fp@(-412),%sp@-
    jsr @(0x10f0,%za0)@(0)	| 4083487C
    movel %sp@+,%d0
    clrl %sp@-
    movel %d0,%sp@-
    movel %d7,%sp@-
    jsr @(0xfa0,%za0)@(0)	| 4083488A
    movel %sp@+,%fp@(-428)
    movew %fp@(-416),%d6
    swap %d6
    clrw %d6
    movew %fp@(-420),%d7
    lsrw #1,%d7
    movew %fp@(-422),%d0
    muluw %d7,%d0
    movel %d0,%fp@(-432)
    movew %fp@(-424),%d0
    mulsw %d7,%d0
    addw %d0,%fp@(-432)
    movel %d6,%d0
    subl %fp@(-432),%d0
    movel %d0,%fp@(-432)
    movew %fp@(-426),%d0
    muluw %d7,%d0
    movel %d0,%fp@(-436)
    movew %fp@(-428),%d0
    mulsw %d7,%d0
    addw %d0,%fp@(-436)
    subl %fp@(-436),%d6
    movel %d6,%fp@(-436)
    movew %fp@(10),%d0
    cmpiw #180,%d0
    jbge DRAWARC_26C
    subiw #90,%d0
    jbra DRAWARC_272
DRAWARC_26C:            /* start edge in the other half */
    subiw #270,%d0
    negw %d0
DRAWARC_272:            /* the end edge's side */
    movew %d0,%fp@(-438)
    movew %fp@(-412),%d0
    cmpiw #180,%d0
    jbge DRAWARC_286
    subiw #90,%d0
    jbra DRAWARC_28C
DRAWARC_286:            /* other half */
    subiw #270,%d0
    negw %d0
DRAWARC_28C:            /* arcs of 180: a half; smaller: a convex wedge (fp-410) */
    movew %d0,%fp@(-440)
    movew %fp@(8),%d0
    cmpiw #180,%d0
    jbgt DRAWARC_2B4
    jblt DRAWARC_2A8
    cmpiw #90,%fp@(10)
    seq %fp@(-410)
    jbra DRAWARC_2B4
DRAWARC_2A8:            /* convex if both edges are on the same side */
    movew %fp@(-438),%d0
    orw %fp@(-440),%d0
    spl %fp@(-410)
DRAWARC_2B4:            /* the oval edges (INITOVAL) outer and, for framing, inner (pen size) */
    moveal %fp@(24),%a0
    lea %fp@(-404),%a1
    movew %fp@(18),%d1
    movew %fp@(20),%d2
    jsr %pc@(INITOVAL)
    movew %fp@(18),%d0
    asrw #1,%d0
    addw %fp@(-404),%d0
    movew %d0,%fp@(-406)
    moveal %fp@(24),%a0
    addw %a0@(4),%d0
    subw %a0@,%d0
    subw %fp@(18),%d0
    movew %d0,%fp@(-408)
    movew #32767,%fp@(-356)
    tstb %fp@(22)
    jbeq DRAWARC_336
    moveal %fp@(24),%a0
    movemw %a0@,%d0-%d3
    movel %a4@(52),%d4
    addw %d4,%d1
    subw %d4,%d3
    cmpw %d3,%d1
    jbge DRAWARC_336
    swap %d4
    addw %d4,%d0
    subw %d4,%d2
    cmpw %d2,%d0
    jbge DRAWARC_336
    movemw %d0-%d3,%fp@(-308)
    lea %fp@(-308),%a0
    lea %fp@(-356),%a1
    movew %fp@(18),%d1
    subw %d4,%d1
    subw %d4,%d1
    movew %fp@(20),%d2
    swap %d4
    subw %d4,%d2
    subw %d4,%d2
    jsr %pc@(INITOVAL)
DRAWARC_336:            /* on the screen: shield the cursor */
    tstb %fp@(-358)
    jbeq DRAWARC_34A
    pea %fp@(-116)
    movel %fp@(-452),%sp@-
    jsr @(0xf54,%za0)@(0)	| 408349C4
DRAWARC_34A:            /* the destination row geometry; the region mask buffer */
    movew %fp@(-118),%d5
    movew %fp@(-114),%d2
    subw %fp@(-236),%d2
    extl %d2
    lsll %d5,%d2
    andil #-32,%d2
    movel %d2,%d0
    lsrl #3,%d0
    movew %d0,%fp@(-144)
    lsrl %d5,%d2
    addw %fp@(-236),%d2
    movew %d2,%fp@(-14)
    tstb %fp@(-310)
    bnew DRAWARC_3CA
    movew %fp@(-110),%d0
    subw %d2,%d0
    movew %d0,%d1
    extl %d1
    lsll %d5,%d1
    subql #1,%d1
    lsrl #5,%d1
    movew %d1,%fp@(-16)
    lsrw #5,%d0
    addqw #1,%d0
    lslw %d5,%d0
    subqw #1,%d0
DRAWARC_396:            /* clear it */
    clrl %sp@-
    dbf %d0,DRAWARC_396
    movel %sp,%fp@(-8)
    lea %pc@(DRAWARC_6EA),%a0
    movel %a0,%fp@(-128)
    movel Lo3Bytes,%fp@(-132)
    clrl %fp@(-124)
    clrl %fp@(-12)
    movel %a4@(24),%sp@-
    movel %a4@(28),%sp@-
    movel #1,%sp@-
    jsr @(0x1a34,%za0)@(0)	| 40834A44
DRAWARC_3CA:            /* the first destination row */
    movew %fp@(-116),%d1
    subw %fp@(-238),%d1
    movew %fp@(-240),%d0
    andiw #32767,%d0
    extl %d0
    movel %d0,%fp@(-124)
    mulsw %d0,%d1
    addl %fp@(-244),%d1
    movew %fp@(-14),%d2
    subw %fp@(-236),%d2
    movew %fp@(-118),%d7
    lslw %d7,%d2
    lsrw #3,%d2
    extl %d2
    addl %d2,%d1
    movel %d1,%fp@(-300)
    movew %fp@(-14),%d1
    subw %d1,%fp@(-114)
    subw %d1,%fp@(-110)
    subw %d1,%fp@(-370)
    subw %d1,%fp@(-366)
    subw %d1,%fp@(-322)
    subw %d1,%fp@(-318)
    subw %d1,%fp@(-432)
    subw %d1,%fp@(-436)
    movew %fp@(-152),%d2
    tstb %fp@(-310)
    jbeq DRAWARC_438
    jsr @(0x1a30,%za0)@(0)	| 40834AAC
    movel %a4,%fp@(-296)
    jbra DRAWARC_494
DRAWARC_438:            /* inverting modes: d7 = -1 */
    moveq #0,%d7
    movew %fp@(-152),%d2
    btst #5,%d2
    jbne DRAWARC_44C
    bclr #2,%d2
    jbeq DRAWARC_44C
    notl %d7
DRAWARC_44C:            /* the pattern (PATEXPAND); old patterns: 8 rows of 4 bytes */
    jsr @(0x1a54,%za0)@(0)	| 40834ACC
    movew %fp@(-142),%d1
    jbne DRAWARC_46E
    moveq #15,%d0
    moveq #4,%d1
    movew %d1,%fp@(-142)
    movew #3,%fp@(-140)
    movew #63,%fp@(-138)
    jbra DRAWARC_47C
DRAWARC_46E:            /* pixpat: its row count */
    moveq #0,%d0
    movew %fp@(-138),%d0
    addqw #1,%d0
    divuw %fp@(-142),%d0
    subqw #1,%d0
DRAWARC_47C:            /* the pattern row for the first line; the slab loop (SLABMODE) */
    andw %fp@(-116),%d0
    muluw %d1,%d0
    movel %d0,%fp@(-150)
    movew %fp@(-152),%d2
    jsr @(0x1a94,%za0)@(0)	| 40834B0A
    movel %a4,%fp@(-296)
DRAWARC_494:            /* 32-bit addressing; first row */
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 40834B16
    moveb %d0,%fp@(-258)
    movew %fp@(-404),%d7
    movew %d7,%fp@(-4)
DRAWARC_4A8:            /* each row: advance the oval edges (BUMPOVAL) inside them */
    cmpw %fp@(-406),%d7
    jblt DRAWARC_4B4
    cmpw %fp@(-408),%d7
    jblt DRAWARC_4CC
DRAWARC_4B4:            /* outer and inner ovals */
    movew %d7,%sp@-
    movew %d7,%d0
    lea %fp@(-404),%a3
    jsr %pc@(BUMPOVAL)
    movew %sp@,%d0
    lea %fp@(-356),%a3
    jsr %pc@(BUMPOVAL)
    movew %sp@+,%d7
DRAWARC_4CC:            /* at the center row the wedge edges change sides */
    cmpw %fp@(-414),%d7
    jbne DRAWARC_532
    tstb %fp@(-409)
    jbeq DRAWARC_532
    negw %fp@(-438)
    negw %fp@(-440)
    clrb %fp@(-410)
    movew %fp@(8),%d0
    cmpiw #180,%d0
    jbgt DRAWARC_508
    jblt DRAWARC_4FC
    cmpiw #270,%fp@(10)
    jbne DRAWARC_508
    jbra DRAWARC_6E0
DRAWARC_4FC:            /* still convex? */
    movew %fp@(-438),%d0
    orw %fp@(-440),%d0
    jbpl DRAWARC_6E0
DRAWARC_508:            /* swap the two edges */
    movew %fp@(-438),%d0
    movew %fp@(-440),%fp@(-438)
    movew %d0,%fp@(-440)
    movel %fp@(-432),%d0
    movel %fp@(-436),%fp@(-432)
    movel %d0,%fp@(-436)
    movel %fp@(-424),%d0
    movel %fp@(-428),%fp@(-424)
    movel %d0,%fp@(-428)
DRAWARC_532:            /* visible row: the region mask (seek proc) */
    cmpw %fp@(-116),%d7
    jblt DRAWARC_6C2
    tstb %fp@(-410)
    jbne DRAWARC_6AA
    tstb %fp@(-310)
    jbne DRAWARC_54E
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 40834BC8
DRAWARC_54E:            /* full oval: between the inner and outer edges, or the whole row */
    tstb %fp@(-409)
    jbne DRAWARC_568
    cmpw %fp@(-356),%d7
    jblt DRAWARC_6A0
    cmpw %fp@(-354),%d7
    jbge DRAWARC_6A0
    jbra DRAWARC_68A
DRAWARC_568:            /* an arc: clip the outer span to the wedge */
    movew %fp@(-370),%d1
    tstw %fp@(-438)
    jbpl DRAWARC_57C
    cmpw %fp@(-432),%d1
    jbge DRAWARC_57C
    movew %fp@(-432),%d1
DRAWARC_57C:            /* right end */
    movew %d1,%fp@(-442)
    movew %fp@(-366),%d2
    tstw %fp@(-440)
    jbpl DRAWARC_594
    cmpw %fp@(-436),%d2
    jble DRAWARC_594
    movew %fp@(-436),%d2
DRAWARC_594:            /* framing: the inner span clipped too */
    movew %d2,%fp@(-444)
    cmpw %fp@(-356),%d7
    jblt DRAWARC_664
    cmpw %fp@(-354),%d7
    jbge DRAWARC_664
    movew %fp@(-322),%d0
    tstw %fp@(-440)
    jbpl DRAWARC_5BC
    cmpw %fp@(-436),%d0
    jble DRAWARC_5BC
    movew %fp@(-436),%d0
DRAWARC_5BC:            /* its right end */
    movew %d0,%fp@(-446)
    movew %fp@(-318),%d0
    tstw %fp@(-438)
    jbpl DRAWARC_5D4
    cmpw %fp@(-432),%d0
    jbge DRAWARC_5D4
    movew %fp@(-432),%d0
DRAWARC_5D4:            /* two slabs (left and right of the hole) */
    movew %d0,%fp@(-448)
    cmpw %d2,%d1
    jbge DRAWARC_5EE
    movew %fp@(-446),%d2
    jbsr DRAWARC_638
    movew %fp@(-448),%d1
    movew %fp@(-444),%d2
    jbra DRAWARC_6A8
DRAWARC_5EE:            /* a wedge over 180 degrees: the two pieces either side */
    movew %fp@(-438),%d0
    andw %fp@(-440),%d0
    jbpl DRAWARC_6AA
    cmpiw #180,%fp@(8)
    jble DRAWARC_6AA
    cmpw %fp@(-446),%d2
    jbne DRAWARC_610
    movew %fp@(-322),%d2
    jbra DRAWARC_622
DRAWARC_610:            /* other side */
    movew %fp@(-442),%d0
    cmpw %fp@(-448),%d0
    jbne DRAWARC_624
    movew %fp@(-318),%d1
    movew %fp@(-444),%d2
DRAWARC_622:            /* draw */
    jbsr DRAWARC_638
DRAWARC_624:            /* both pieces */
    movew %fp@(-370),%d1
    movew %fp@(-446),%d2
    jbsr DRAWARC_638
    movew %fp@(-448),%d1
    movew %fp@(-366),%d2
    jbra DRAWARC_6A8

DRAWARC_638:            /* draw a slab from d1 to d2 (DRAWSLAB with the pattern row) */
    movel %fp@(-150),%d6
    lea %fp@(0xffffffffffffff78)@(0x0,%d6:l),%a0
    movel %a0@,%d6
    moveal %fp@(-300),%a1
    moveal %fp@(-8),%a2
    lea %fp@(-116),%a3
    movew %fp@(-118),%d0
    movel %fp@(-160),%d4
    movel %fp@(-164),%d5
    jsr @(0x1a2c,%za0)@(0)	| 40834CDC
    rts
DRAWARC_664:            /* filling a wedge over 180 */
    cmpw %d2,%d1
    jblt DRAWARC_6A8
    movew %fp@(-438),%d0
    andw %fp@(-440),%d0
    jbpl DRAWARC_6AA
    cmpiw #180,%fp@(8)
    jble DRAWARC_6AA
    movew %fp@(-370),%d1
    jbsr DRAWARC_638
    movew %fp@(-442),%d1
    movew %fp@(-366),%d2
    jbra DRAWARC_6A8

DRAWARC_68A:            /* frame: left and right parts of the ring */
    movew %fp@(-370),%d1
    movew %fp@(-322),%d2
    jbsr DRAWARC_638
    movew %fp@(-318),%d1
    movew %fp@(-366),%d2
    jbsr DRAWARC_638
    jbra DRAWARC_6AA
DRAWARC_6A0:            /* the whole span */
    movew %fp@(-370),%d1
    movew %fp@(-366),%d2
DRAWARC_6A8:            /* draw */
    jbsr DRAWARC_638
DRAWARC_6AA:            /* next pattern row and destination row */
    movel %fp@(-150),%d0
    addw %fp@(-142),%d0
    andw %fp@(-138),%d0
    movel %d0,%fp@(-150)
    movel %fp@(-124),%d0
    addl %d0,%fp@(-300)
DRAWARC_6C2:            /* step the wedge edges; next row until the bottom */
    movel %fp@(-424),%d0
    addl %d0,%fp@(-432)
    movel %fp@(-428),%d0
    addl %d0,%fp@(-436)
    addqw #1,%d7
    movew %d7,%fp@(-4)
    cmpw %fp@(-112),%d7
    jblt DRAWARC_4A8
DRAWARC_6E0:            /* restore the addressing mode */
    moveb %fp@(-258),%d0
    jsr @(0x574,%za0)@(0x0)	| 40834D64
DRAWARC_6EA:            /* show the cursor */
    tstb %fp@(-358)
    jbeq DRAWARC_6F6
    jsr @(0xf4c,%za0)@(0)	| 40834D70
DRAWARC_6F6:            /* hilite off, return */
    bset #7,HiliteMode
    moveal %fp@(-292),%sp
    moveml %sp@+,%d0-%d7/%a1-%a4
    unlk %fp
    rtd #20
    .short  0x0000, 0x0000, 0x0000	| 40834D8A

/* INITOVAL: InitOval(rect, ovalWidth, ovalHeight): the state of an oval's row-by-row edge (rounded rectangle corners), widths pinned to the rectangle */
INITOVAL:
    movew %a0@,%a1@
    movew %a0@(4),%a1@(2)
    tstw %d2
    jbpl INITOVAL_E
    clrw %d2
INITOVAL_E:             /* oval sizes pinned at 0 */
    tstw %d1
    jbpl INITOVAL_14
    clrw %d1
INITOVAL_14:            /* and at the rectangle's size */
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    cmpw %d0,%d2
    jble INITOVAL_22
    movew %d0,%d2
INITOVAL_22:            /* height */
    movew %a0@(4),%d0
    subw %a0@,%d0
    cmpw %d0,%d1
    jble INITOVAL_2E
    movew %d0,%d1
INITOVAL_2E:            /* the edge state: the corners' ellipse parameters in fixed point */
    movew %a0@(6),%a1@(38)
    clrw %a1@(40)
    movew %a0@(2),%a1@(34)
    clrw %a1@(36)
    movew %d2,%d0
    swap %d0
    clrw %d0
    lsrl #1,%d0
    addl %d0,%a1@(34)
    subl %d0,%a1@(38)
    movel #32768,%d0
    movel %d0,%a1@(42)
    addl %d0,%a1@(38)
    moveq #1,%d0
    subw %d1,%d0
    movew %d0,%a1@(4)
    movew %d1,%d0
    extl %d0
    addl %d0,%d0
    subql #1,%d0
    movel %d0,%a1@(6)
    clrl %a1@(10)
    clrl %a1@(14)
    clrl %sp@-
    movew %d1,%sp@-
    movew %d2,%sp@-
    jsr @(0xfa4,%za0)@(0)	| 40834E12
    movel %sp@,%sp@-
    pea %a1@(18)
    jsr @(0xf9c,%za0)@(0)	| 40834E1E
    movel %a1@(22),%d0
    addl %d0,%d0
    movel %d0,%a1@(30)
    movel %a1@(18),%d0
    addxl %d0,%d0
    movel %d0,%a1@(26)
    rts
    .short  0x0000, 0x0000, 0x0000	| 40834E3A

/* BUMPOVAL: BumpOval: the oval's edges for the next row */
BUMPOVAL:
    cmpw %a3@+,%d0
    jblt BUMPOVAL_40
    cmpw %a3@+,%d0
    jbge BUMPOVAL_40
    movew %a3@,%d0
    addqw #2,%a3@+
    moveml %a3@,%d1-%a2
    jbra BUMPOVAL_1E
BUMPOVAL_12:            /* move the edges in */
    addal %a2,%a1
    subal %a2,%a0
    addl %d5,%d3
    addxl %d4,%d2
    addl %d7,%d5
    addxl %d6,%d4
BUMPOVAL_1E:            /* while inside the ellipse */
    cmpl %d1,%d2
    jblt BUMPOVAL_12
    jbra BUMPOVAL_30
BUMPOVAL_24:            /* move the edges out */
    subal %a2,%a1
    addal %a2,%a0
    subl %d7,%d5
    subxl %d6,%d4
    subl %d5,%d3
    subxl %d4,%d2
BUMPOVAL_30:            /* while outside; store the new state */
    cmpl %d1,%d2
    jbgt BUMPOVAL_24
    addqw #1,%d0
    extl %d0
    asll #2,%d0
    subl %d0,%d1
    moveml %d1-%a2,%a3@
BUMPOVAL_40:            /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40834E82

/* STDBITS: StdBits: the bits bottleneck (CopyBits). */
trap_StdBits:
STDBITS:
    linkw %fp,#-246
    moveml %d3-%d7/%a2-%a4,%sp@-
    jsr @(0x1a3c,%za0)@(0)	| 40834E98
    jble STDBITS_33E
    moveal %a3@(92),%a0
    moveal %a0@,%a0
    cmpiw #1,%a0@(98)
    seq %fp@(-246)
    moveal %fp@(22),%a1
    tstw %a1@(4)
    spl %d7
    orb %fp@(-246),%d7
    lea %fp@(-78),%a2
    jsr @(0x1a08,%za0)@(0)	| 40834EC4
    lea %pc@(SHFTTBL),%a0
    movew %fp@(-46),%d0
    moveq #0,%d3
    moveb %a0@(0x0,%d0:w),%d3
    clrl %fp@(-172)
    tstb %d2
    jbeq STDBITS_186
    moveal %fp@(18),%a0
    lea %fp@(-156),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    pea %fp@(-156)
    moveal %fp@(22),%a0
    movel %a0@(6),%d0
    negw %d0
    swap %d0
    negw %d0
    swap %d0
    movel %d0,%sp@-
    jsr @(0x10a0,%za0)@(0)	| 40834F04
    clrl %sp@-
    pea %fp@(-156)
    jsr @(0x169c,%za0)@(0)	| 40834F10
    movel %sp@+,%d0
    jbeq STDBITS_33C
    movel TheGDevice,%sp@-
    movel %d0,TheGDevice
    moveal %d0,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    lea %fp@(-128),%a1
    moveq #24,%d0
STDBITS_A4:             /* copy the source bitmap/pixmap */
    movew %a0@+,%a1@+
    dbf %d0,STDBITS_A4
    clrw %fp@(-114)
    moveal %fp@(18),%a0
    lea %fp@(-122),%a1
    movel %a0@+,%d1
    movel %d1,%a1@+
    movel %a0@+,%d0
    movel %d0,%a1@+
    movew %d0,%d5
    subw %d1,%d5
    extl %d5
    moveq #0,%d3
    tstb %d7
    jbne STDBITS_D6
    lea %pc@(SHFTTBL),%a0
    movew %fp@(-96),%d2
    moveb %a0@(0x0,%d2:w),%d3
STDBITS_D6:             /* row bytes of the recorded image (rounded to words); empty: nothing */
    lsll %d3,%d5
    moveq #15,%d2
    addl %d2,%d5
    asrl #4,%d5
    jble STDBITS_33C
    addw %d5,%d5
    movew %d5,%fp@(-124)
    movew %d5,%d4
    tstb %d7
    jbne STDBITS_F4
    oriw #-32768,%fp@(-124)
STDBITS_F4:             /* deep pixmaps are recorded at the destination's depth: a temporary copy (NewHandle, temp memory if needed) */
    swap %d1
    swap %d0
    subw %d1,%d0
    muluw %d5,%d0
    movel %d0,%d5
    clrb %fp@(-245)
    .short  0xA122	| 40834F92 _NewHandle (flags 0x0100)
    jbeq STDBITS_124
    st %fp@(-245)
    movel %d5,%d0
    jsr @(0x1ab4,%za0)@(0)	| 40834F9C
    cmpl %d5,%d0
    jbge STDBITS_124
    movel %sp@+,TheGDevice
    movew #-143,QDErr
    jbra STDBITS_33C
STDBITS_124:            /* CopyBits the area into it (picture recording off meanwhile) */
    movel %a0,%fp@(-172)
    _HLock
    moveal %a0@,%a0
    movel %a0,%fp@(-128)
    movel %a3@(92),%sp@-
    clrl %a3@(92)
    subqw #6,%sp
    movel %sp,%sp@-
    jsr @(0x1664,%za0)@(0x0)	| 40834FCC
    moveq #33,%d0
    movel %d0,%sp@-
    jsr @(0xf88,%za0)@(0)	| 40834FD6
    pea %fp@(-78)
    pea %fp@(-128)
    movel %fp@(18),%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    clrl %sp@-
    jsr @(0x11b0,%za0)@(0)	| 40834FEE
    movel %sp,%sp@-
    jsr @(0x1650,%za0)@(0x0)	| 40834FF6
    addqw #6,%sp
    movel %sp@+,%a3@(92)
    movel %sp@+,TheGDevice
    lea %fp@(-128),%a0
    lea %fp@(-78),%a1
    moveq #24,%d0
STDBITS_180:            /* copy the pixmap fields */
    movew %a0@+,%a1@+
    dbf %d0,STDBITS_180
STDBITS_186:            /* trim the source rectangle to the bounds, keep the base aligned */
    lea %fp@(-78),%a1
    moveal %a1@,%a3
    movew %a1@(4),%d4
    andiw #32767,%d4
    moveal %fp@(18),%a0
    movew %a0@,%d0
    subw %a1@(6),%d0
    jble STDBITS_1A8
    addw %d0,%a1@(6)
    muluw %d4,%d0
    addal %d0,%a3
STDBITS_1A8:            /* bottom */
    movew %a0@(4),%d0
    cmpw %a1@(10),%d0
    jbge STDBITS_1B6
    movew %d0,%a1@(10)
STDBITS_1B6:            /* left: advance the base */
    movew %a0@(2),%d0
    subw %a1@(8),%d0
    jble STDBITS_1D0
    extl %d0
    lsll %d3,%d0
    asrl #3,%d0
    addal %d0,%a3
    lsll #3,%d0
    asrl %d3,%d0
    addw %d0,%a1@(8)
STDBITS_1D0:            /* right */
    movew %a0@(6),%d0
    subw %a1@(8),%d0
    extl %d0
    addql #7,%d0
    lsll %d3,%d0
    andiw #-8,%d0
    asrl %d3,%d0
    addw %a1@(8),%d0
    cmpw %a1@(12),%d0
    jbge STDBITS_1F2
    movew %d0,%a1@(12)
STDBITS_1F2:            /* row bytes */
    movew %a1@(12),%d5
    subw %a1@(8),%d5
    extl %d5
    lsll %d3,%d5
    moveq #15,%d0
    addl %d0,%d5
    asrl #4,%d5
    jble STDBITS_33C
    addw %d5,%d5
    movew %d5,%a1@(4)
    oriw #-32768,%a1@(4)
    clrw %fp@(-64)
    moveq #8,%d6
STDBITS_21A:            /* opcode 0x90 (BitsRect) / 0x91 (BitsRgn) + 8 when packed */
    movew #144,%sp@-
    tstl %fp@(8)
    jbeq STDBITS_226
    addqw #1,%sp@
STDBITS_226:            /* rowBytes < 8: unpacked */
    cmpw %d6,%d5
    jbge STDBITS_232
    movew #1,%fp@(-62)
    jbra STDBITS_234
STDBITS_232:            /* packed */
    addqw #8,%sp@
STDBITS_234:            /* version 2 direct pixmaps: DirectBitsRect (0x9A/0x9B), base 0xFF; packType 1 stays, 16-bit pixels use 3 */
    tstb %d7
    jbne STDBITS_296
    movew %fp@(-48),%d2
    cmpiw #16,%d2
    jbne STDBITS_296
    oriw #10,%sp@
    jbsr PUTPICOP
    movel #255,%sp@-
    jbsr PUTPICLONG
    lea %fp@(-62),%a0
    cmpiw #1,%a0@
    jbeq STDBITS_276
    cmpiw #16,%fp@(-46)
    jbne STDBITS_26C
    movew #3,%a0@
    jbra STDBITS_276
STDBITS_26C:            /* packType */
    cmpiw #2,%a0@
    jbeq STDBITS_276
    movew #4,%a0@
STDBITS_276:            /* the pixmap record */
    movew %fp@(-68),%d1
    subw %fp@(-72),%d1
    muluw %d1,%d5
    pea %fp@(-74)
    movew #46,%sp@-
    jbsr PUTPICDATA
    jbra STDBITS_2BE
STDBITS_28E:            /* data */
    .short  0x0003	| 4083511E
    .short  0x0201, 0x0103, 0x0201	| 40835120
STDBITS_296:            /* the opcode; old bitmaps: 10 bytes, else the pixmap and its color table */
    jbsr PUTPICOP
    moveq #46,%d0
    tstb %d7
    jbeq STDBITS_2A8
    andiw #32767,%fp@(-74)
    moveq #10,%d0
STDBITS_2A8:            /* the record */
    pea %fp@(-74)
    movew %d0,%sp@-
    jbsr PUTPICDATA
    tstb %d7
    jbne STDBITS_2BE
    movel %fp@(-36),%sp@-
    jbsr PUTPICTABLE
STDBITS_2BE:            /* source and destination rectangles, the mode (version 1: boolean) */
    movel %fp@(18),%sp@-
    movew %d6,%sp@-
    jbsr PUTPICDATA
    movel %fp@(14),%sp@-
    movew %d6,%sp@-
    jbsr PUTPICDATA
    movew %fp@(12),%d0
    tstb %fp@(-246)
    jbeq STDBITS_2EA
    btst #5,%d0
    jbeq STDBITS_2EA
    andiw #7,%d0
    moveb %pc@(STDBITS_28E,%d0:w),%d0
STDBITS_2EA:            /* the mode; BitsRgn: the mask region */
    movew %d0,%sp@-
    jbsr PUTPICWORD
    tstl %fp@(8)
    jbeq STDBITS_2FE
    movel %fp@(8),%sp@-
    jbsr PUTPICRGN
STDBITS_2FE:            /* the pixel data: direct or indexed packing */
    cmpiw #16,%fp@(-48)
    jbne STDBITS_316
    lea %fp@(-78),%a0
    movel %a0,%sp@-
    movel %a3,%sp@-
    movew %d4,%sp@-
    jbsr PUTDIRECTPMDATA
    jbra STDBITS_324
STDBITS_316:            /* indexed */
    lea %fp@(-78),%a0
    movel %a0,%sp@-
    movel %a3,%sp@-
    movew %d4,%sp@-
    jbsr PUTPMDATA
STDBITS_324:            /* dispose of the temporary copy */
    movel %fp@(-172),%d0
    jbeq STDBITS_33C
    moveal %d0,%a0
    tstb %fp@(-245)
    jbeq STDBITS_33A
    jsr @(0x1a78,%za0)@(0)	| 408351C2
    jbra STDBITS_33C
STDBITS_33A:            /* _DisposHandle */
    _DisposHandle
STDBITS_33C:            /* thePort */
    moveal %a4@,%a3
STDBITS_33E:            /* visible: draw through the device loop (vector 0x1C78) */
    tstw %a3@(66)
    jblt STDBITS_366
    lea %a3@(2),%a0
    movel %a0,%fp@(-132)
    movel %a3@(24),%fp@(-232)
    movel %a3@(28),%fp@(-236)
    clrl %fp@(-240)
    clrl %fp@(-244)
    jsr @(0x1c78,%za0)@(0)	| 408351F0
STDBITS_366:            /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #18

/* BITSDEVLOOP: BitsDevLoop: CopyBits/StretchBits across every screen device touched: one device: STRETCHBITS directly; else per device through the device loop */
trap_BITSDEVLOOP:
BITSDEVLOOP:
    moveal DeviceList,%a0
    moveal %a0@,%a0
    movel %a0@(30),%d0
    jbne BITSDEVLOOP_4C
    movel %fp@(22),%sp@-
    movel %fp@(-240),%sp@-
    movel %fp@(-132),%sp@-
    movel %fp@(18),%sp@-
    movel %fp@(-244),%sp@-
    movel %fp@(14),%sp@-
    movew %fp@(12),%sp@-
    andiw #-9,%sp@
    clrl %sp@-
    movel %fp@(-232),%sp@-
    movel %fp@(-236),%sp@-
    movel %fp@(8),%sp@-
    jbne BITSDEVLOOP_42
    moveal %a5@,%a0
    movel %a0@(-130),%sp@
BITSDEVLOOP_42:         /* a single device: STRETCHBITS */
    clrw %sp@-
    jsr @(0x1a9c,%za0)@(0)	| 40835244
    rts
BITSDEVLOOP_4C:         /* several: a list of the devices the source and the destination touch, ordered so overlapping copies read before they write */
    movel %sp,%fp@(-214)
    lea %fp@(-202),%a1
    movel %a1,%fp@(-210)
    moveal TheGDevice,%a0
    movel %a0,%a1@+
    clrl %a1@+
    movel %a1,%fp@(-206)
    lea %fp@(-186),%a2
    movel %a2,%a1@+
    clrl %a1@+
    movel %a0,%a2@(2)
    moveal MainDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    movel %a0@,%d0
    moveal %fp@(-132),%a0
    jsr @(0x1a04,%za0)@(0)	| 40835282
    moveal %a0,%a1
    moveal %fp@(22),%a0
    jsr @(0x1a04,%za0)@(0)	| 4083528E
    moveal %a0,%a2
    cmpl %a0@,%d0
    seq %d6
    cmpl %a1@,%d0
    seq %d7
    moveq #6,%d2
    moveb %d6,%d5
    andb %d7,%d5
    jbeq BITSDEVLOOP_D4
    moveq #0,%d2
    movel %fp@(0x12,%za0)@(0x0),%d0	| 408352A8
    subw %a0@(8),%d0
    movel %fp@(0xe,%za0)@(0),%d1	| 408352B2
    subw %a1@(8),%d1
    cmpw %d1,%d0
    jble BITSDEVLOOP_C2
    addqw #2,%d2
BITSDEVLOOP_C2:         /* direction of the copy (up/down, left/right) picks the compare routine */
    swap %d0
    swap %d1
    subw %a0@(6),%d0
    subw %a1@(6),%d1
    cmpw %d1,%d0
    jble BITSDEVLOOP_D4
    addqw #4,%d2
BITSDEVLOOP_D4:         /* the destination's global rectangle */
    lea %pc@(BITSDEVLOOP_458),%a4
    addaw %a4@(0x0,%d2:w),%a4
    tstb %d6
    jbeq BITSDEVLOOP_18E
    moveal %fp@(18),%a1
    lea %fp@(-140),%a0
    movel %a1@+,%a0@
    movel %a1@+,%a0@(4)
    movel %a2@(6),%d0
    movel %d0,%d1
    swap %d1
    subw %d1,%a0@+
    jbvc BITSDEVLOOP_102
    jsr @(0x1a58,%za0)@(0)	| 408352FC
BITSDEVLOOP_102:        /* to global (pinned) */
    subw %d0,%a0@+
    jbvc BITSDEVLOOP_10C
    jsr @(0x1a58,%za0)@(0)	| 40835306
BITSDEVLOOP_10C:        /* top */
    subw %d1,%a0@+
    jbvc BITSDEVLOOP_116
    jsr @(0x1a58,%za0)@(0)	| 40835310
BITSDEVLOOP_116:        /* right */
    subw %d0,%a0@+
    jbvc BITSDEVLOOP_120
    jsr @(0x1a58,%za0)@(0)	| 4083531A
BITSDEVLOOP_120:        /* devices it touches */
    moveal DeviceList,%a2
    clrw %sp@-
BITSDEVLOOP_126:        /* active and intersecting? push it */
    moveal %a2@,%a0
    tstw %a0@(20)
    jbpl BITSDEVLOOP_156
    clrb %sp@-
    pea %fp@(-140)
    pea %a0@(34)
    pea %fp@(-172)
    jsr @(0x10a8,%za0)@(0)	| 4083533C
    tstb %sp@+
    jbeq BITSDEVLOOP_156
    lea %fp@(-172),%a0
    movel %a0@(4),%sp@-
    movel %a0@,%sp@-
    movel %a2,%sp@-
    movew #1,%sp@-
BITSDEVLOOP_156:        /* next device; sort the list by the copy direction */
    moveal %a2@,%a0
    movel %a0@(30),%d0
    moveal %d0,%a2
    jbne BITSDEVLOOP_126
    moveal %sp,%a2
    clrl %sp@-
    moveq #0,%d1
BITSDEVLOOP_166:        /* selection sort */
    moveal %a2,%a0
    moveal %d1,%a1
BITSDEVLOOP_16A:        /* compare */
    tstw %a0@
    jbmi BITSDEVLOOP_17A
    jbeq BITSDEVLOOP_180
    cmpl %a1,%d1
    jbeq BITSDEVLOOP_178
    jsr %a4@
    jbeq BITSDEVLOOP_17A
BITSDEVLOOP_178:        /* new best */
    moveal %a0,%a1
BITSDEVLOOP_17A:        /* next */
    lea %a0@(14),%a0
    jbra BITSDEVLOOP_16A
BITSDEVLOOP_180:        /* take the best */
    cmpl %a1,%d1
    jbeq BITSDEVLOOP_18A
    st %a1@
    movel %a1,%sp@-
    jbra BITSDEVLOOP_166
BITSDEVLOOP_18A:        /* the destination device list */
    movel %sp,%fp@(-206)
BITSDEVLOOP_18E:        /* the source on the screen too: the same for it */
    tstb %d7
    jbeq BITSDEVLOOP_24C
    moveal %fp@(14),%a0
    lea %fp@(-148),%a1
    movel %a0@+,%a1@
    movel %a0@+,%a1@(4)
    moveal %fp@(-132),%a0
    jsr @(0x1a04,%za0)@(0)	| 408353A6
    movel %a0@(6),%d0
    movel %d0,%d1
    swap %d1
    subw %d1,%a1@+
    jbvc BITSDEVLOOP_1BE
    jsr @(0x1a58,%za0)@(0)	| 408353B8
BITSDEVLOOP_1BE:        /* to global */
    subw %d0,%a1@+
    jbvc BITSDEVLOOP_1C8
    jsr @(0x1a58,%za0)@(0)	| 408353C2
BITSDEVLOOP_1C8:        /* top */
    subw %d1,%a1@+
    jbvc BITSDEVLOOP_1D2
    jsr @(0x1a58,%za0)@(0)	| 408353CC
BITSDEVLOOP_1D2:        /* right */
    subw %d0,%a1@+
    jbvc BITSDEVLOOP_1DC
    jsr @(0x1a58,%za0)@(0)	| 408353D6
BITSDEVLOOP_1DC:        /* devices it touches */
    moveal DeviceList,%a2
    clrw %sp@-
BITSDEVLOOP_1E2:        /* active and intersecting? push it */
    moveal %a2@,%a0
    tstw %a0@(20)
    jbpl BITSDEVLOOP_212
    clrb %sp@-
    pea %fp@(-148)
    pea %a0@(34)
    pea %fp@(-172)
    jsr @(0x10a8,%za0)@(0)	| 408353F8
    tstb %sp@+
    jbeq BITSDEVLOOP_212
    lea %fp@(-172),%a0
    movel %a0@(4),%sp@-
    movel %a0@,%sp@-
    movel %a2,%sp@-
    movew #1,%sp@-
BITSDEVLOOP_212:        /* next; sort */
    moveal %a2@,%a0
    movel %a0@(30),%d0
    moveal %d0,%a2
    jbne BITSDEVLOOP_1E2
    moveal %sp,%a2
    clrl %sp@-
    moveq #0,%d1
BITSDEVLOOP_222:        /* selection sort */
    moveal %a2,%a0
    moveal %d1,%a1
BITSDEVLOOP_226:        /* compare */
    tstw %a0@
    jbmi BITSDEVLOOP_236
    jbeq BITSDEVLOOP_23C
    cmpl %a1,%d1
    jbeq BITSDEVLOOP_234
    jsr %a4@
    jbeq BITSDEVLOOP_236
BITSDEVLOOP_234:        /* new best */
    moveal %a0,%a1
BITSDEVLOOP_236:        /* next */
    lea %a0@(14),%a0
    jbra BITSDEVLOOP_226
BITSDEVLOOP_23C:        /* take the best */
    cmpl %a1,%d1
    jbeq BITSDEVLOOP_248
    st %a1@
    movel %a1@(2),%sp@-
    jbra BITSDEVLOOP_222
BITSDEVLOOP_248:        /* the source device list */
    movel %sp,%fp@(-210)
BITSDEVLOOP_24C:        /* save the devices and colors */
    movel TheGDevice,%sp@-
    movel SrcDevice,%sp@-
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    movel %a0@,%fp@(-218)
    movel %a3@(80),%fp@(-222)
    movel %a3@(84),%fp@(-226)
    moveb HiliteMode,%fp@(-228)
    lea %fp@(-164),%a1
    moveal %fp@(14),%a0
    movel %a0@+,%d0
    movel %d0,%a1@+
    movel %a0@+,%d7
    movel %d7,%a1@+
    subw %d0,%d7
    swap %d0
    swap %d7
    subw %d0,%d7
    moveal %fp@(18),%a0
    movel %a0@+,%d0
    movel %d0,%a1@+
    movel %a0@+,%d1
    movel %d1,%a1@+
    swap %d7
    addw %d0,%d7
    subw %d1,%d7
    swap %d7
    swap %d0
    swap %d1
    addw %d0,%d7
    subw %d1,%d7
    moveal %fp@(-206),%a2
BITSDEVLOOP_2B4:        /* each source device */
    moveal %fp@(-210),%a4
    movel %a2@+,%d0
    moveal %d0,%a0
    jbeq BITSDEVLOOP_438
    movel %a0@(2),SrcDevice
BITSDEVLOOP_2C6:        /* each destination device: make it current */
    movel %a4@+,%d1
    jbeq BITSDEVLOOP_2B4
    movel %d1,TheGDevice
    tstb %d6
    jbeq BITSDEVLOOP_35C
    moveal %a2@(-4),%a0
    addqw #6,%a0
    movel %a0@+,%d0
    movel %a0@+,%d1
    cmpl %fp@(-140),%d0
    jbne BITSDEVLOOP_2EA
    cmpl %fp@(-136),%d1
    jbeq BITSDEVLOOP_35C
BITSDEVLOOP_2EA:        /* clip both rectangles to the device pieces */
    moveal %fp@(14),%a0
    lea %fp@(-164),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %fp@(18),%a0
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    subw %fp@(-138),%d0
    jble BITSDEVLOOP_30C
    addw %d0,%fp@(-154)
    addw %d0,%fp@(-162)
BITSDEVLOOP_30C:        /* left */
    swap %d0
    subw %fp@(-140),%d0
    jble BITSDEVLOOP_31C
    addw %d0,%fp@(-156)
    addw %d0,%fp@(-164)
BITSDEVLOOP_31C:        /* bottom */
    subw %fp@(-134),%d1
    jbpl BITSDEVLOOP_32A
    addw %d1,%fp@(-150)
    addw %d1,%fp@(-158)
BITSDEVLOOP_32A:        /* right */
    swap %d1
    subw %fp@(-136),%d1
    jbpl BITSDEVLOOP_33A
    addw %d1,%fp@(-152)
    addw %d1,%fp@(-160)
BITSDEVLOOP_33A:        /* scaled copies: map the clipped rectangle back */
    tstl %d7
    jbeq BITSDEVLOOP_35C
    lea %fp@(-156),%a0
    lea %fp@(-164),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    pea %fp@(-164)
    movel %fp@(18),%sp@-
    movel %fp@(14),%sp@-
    jsr @(0x11e8,%za0)@(0)	| 40835556
BITSDEVLOOP_35C:        /* re-match the colors for the device */
    moveb %fp@(-228),HiliteMode
    tstw %a3@(6)
    jbpl BITSDEVLOOP_3F6
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    movel %a0@,%d0
    cmpl %fp@(-218),%d0
    jbeq BITSDEVLOOP_3F6
    movel %d0,%fp@(-218)
    subqw #6,%sp
    clrl %sp@-
    movel %a3@(8),%d0
    jbeq BITSDEVLOOP_3BE
    moveal %d0,%a0
    moveal %a0@,%a0
    tstl %a0@(12)
    jbeq BITSDEVLOOP_3BE
    movew %a0@(24),%d2
    movew %a0@(22),%sp@(2)
    btst #1,%d2
    sne %sp@
    btst #0,%d2
    jbeq BITSDEVLOOP_3BE
    movew %a0@(16),%sp@-
    jsr @(0x185c,%za0)@(0)	| 408355B6
    jbra BITSDEVLOOP_3D0
BITSDEVLOOP_3BE:        /* RGB foreground */
    pea %sp@(4)
    movel %sp@,%sp@-
    jsr @(0x1664,%za0)@(0x0)	| 408355C4
    jsr @(0x1650,%za0)@(0x0)
BITSDEVLOOP_3D0:        /* background */
    tstb %sp@
    jbeq BITSDEVLOOP_3E0
    movew %sp@(2),%sp@-
    jsr @(0x1860,%za0)@(0x0)	| 408355D8
    jbra BITSDEVLOOP_3F2
BITSDEVLOOP_3E0:        /* RGB background */
    pea %sp@(4)
    movel %sp@,%sp@-
    jsr @(0x1668,%za0)@(0x0)	| 408355E6
    jsr @(0x1654,%za0)@(0x0)
BITSDEVLOOP_3F2:        /* pop */
    lea %sp@(10),%sp
BITSDEVLOOP_3F6:        /* STRETCHBITS for this pair */
    movel %fp@(22),%sp@-
    movel %fp@(-240),%sp@-
    movel %fp@(-132),%sp@-
    pea %fp@(-156)
    movel %fp@(-244),%sp@-
    pea %fp@(-164)
    movew %fp@(12),%sp@-
    andiw #-9,%sp@
    clrl %sp@-
    movel %fp@(-232),%sp@-
    movel %fp@(-236),%sp@-
    movel %fp@(8),%sp@-
    jbne BITSDEVLOOP_42C
    moveal %a5@,%a0
    movel %a0@(-130),%sp@
BITSDEVLOOP_42C:        /* next */
    clrw %sp@-
    jsr @(0x1a9c,%za0)@(0)	| 4083562E
    jbra BITSDEVLOOP_2C6
BITSDEVLOOP_438:        /* restore the devices and colors */
    movel %sp@+,SrcDevice
    movel %sp@+,TheGDevice
    movel %fp@(-222),%a3@(80)
    movel %fp@(-226),%a3@(84)
    bset #7,HiliteMode
    moveal %fp@(-214),%sp
    rts
BITSDEVLOOP_458:        /* compare routines by direction (data) */
    .short  BITSDEVLOOP_460-BITSDEVLOOP_458	| 40835658
    .short  BITSDEVLOOP_492-BITSDEVLOOP_458	| 4083565A
    .short  BITSDEVLOOP_47C-BITSDEVLOOP_458	| 4083565C
    .short  BITSDEVLOOP_4A8-BITSDEVLOOP_458	| 4083565E
BITSDEVLOOP_460:        /* device a0 before a1? */
    movew %a0@(10),%d0	| 40835660
    cmpw %a1@(6),%d0	| 40835664
    jble BITSDEVLOOP_478	| 40835668
    movew %a0@(12),%d0	| 4083566A
    cmpw %a1@(8),%d0	| 4083566E
    jble BITSDEVLOOP_478	| 40835672

BITSDEVLOOP_474:        /* no */
    moveq #0,%d0
    rts
BITSDEVLOOP_478:        /* yes */
    moveq #1,%d0
    rts
BITSDEVLOOP_47C:        /* other direction */
    movew %a0@(6),%d0	| 4083567C
    cmpw %a1@(10),%d0
    jbge BITSDEVLOOP_478
    movew %a0@(12),%d0
    cmpw %a1@(8),%d0
    jble BITSDEVLOOP_478
    jbra BITSDEVLOOP_474
BITSDEVLOOP_492:        /* other direction */
    movew %a0@(10),%d0	| 40835692
    cmpw %a1@(6),%d0	| 40835696
    jble BITSDEVLOOP_478	| 4083569A
    movew %a0@(8),%d0	| 4083569C
    cmpw %a1@(12),%d0
    jbge BITSDEVLOOP_478
    jbra BITSDEVLOOP_474

BITSDEVLOOP_4A8:        /* other direction */
    movew %a0@(6),%d0
    cmpw %a1@(10),%d0
    jbge BITSDEVLOOP_478
    movew %a0@(8),%d0
    cmpw %a1@(12),%d0
    jbge BITSDEVLOOP_478
    jbra BITSDEVLOOP_474
    .short  0x0000	| 408356BE

/* COPYBITS: _CopyBits: copy (and scale) a rectangle between bit/pixel maps with a mode and a mask region. */
trap_CopyBits:
COPYBITS:
    linkw %fp,#-16
    moveml %d2/%d6-%d7/%a2-%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a3
    moveal %fp@(26),%a0
    jsr @(0x1a04,%za0)@(0)	| 408356D0
    moveal %a0,%a2
    movel %a4@(-122),%d6
    movel %a2@,%d7
    cmpl %d6,%d7
    jbne COPYBITS_30
    movel %fp@(18),%sp@-
    movel %a2@(6),%sp@-
    jsr @(0xf54,%za0)@(0)	| 408356EA
COPYBITS_30:            /* the destination; a pixmap port drawing into its own bits? */
    moveal %fp@(22),%a0
    jsr @(0x1a04,%za0)@(0)	| 408356F4
    moveal %a0,%a1
    movel %a3,%d0
    jbeq COPYBITS_70
    btst #0,%d0
    jbne COPYBITS_70
    moveal %a3,%a0
    jsr @(0x1a5c,%za0)@(0)	| 40835708
    movel %a1@,%d1
    cmpl %a0@,%d1
    jbeq COPYBITS_64
    cmpl %d6,%d1
    jbne COPYBITS_70
    movel ROMBase,%d0
    cmpl %a0@,%d0
    jbne COPYBITS_70
    jbra COPYBITS_108
COPYBITS_64:            /* same base address: the port's own bits */
    movel %a0@(6),%d0
    cmpl %a1@(6),%d0
    jbeq COPYBITS_108
COPYBITS_70:            /* source on the screen: shield the cursor over the source rectangle */
    cmpl %d6,%d7
    beqw COPYBITS_E8
    moveml %d1/%a1,%sp@-
    subqw #6,%sp
    clrl %sp@-
    pea %sp@(4)
    movel %sp@,%sp@-
    jsr @(0x1664,%za0)@(0x0)	| 40835744
    jsr @(0x1650,%za0)@(0x0)
    pea %sp@(4)
    movel %sp@,%sp@-
    jsr @(0x1668,%za0)@(0x0)	| 40835756
    jsr @(0x1654,%za0)@(0x0)
    lea %sp@(10),%sp
    moveml %sp@+,%d1/%a1
    cmpl %d6,%d1
    jbeq COPYBITS_E8
    movel %fp@(26),%sp@-
    clrl %sp@-
    movel %fp@(22),%sp@-
    movel %fp@(18),%sp@-
    clrl %sp@-
    movel %fp@(14),%sp@-
    movew %fp@(12),%sp@-
    andiw #-9,%sp@
    clrl %sp@-
    movel %a4@(-130),%sp@-
    movel %sp@,%sp@-
    movel %fp@(8),%sp@-
    jbne COPYBITS_DC
    movel %a4@(-130),%sp@
COPYBITS_DC:            /* STRETCHBITS */
    clrw %sp@-
    jsr @(0x1a9c,%za0)@(0)	| 4083579E
    jbra COPYBITS_208
COPYBITS_E8:            /* through the device loop */
    movel %fp@(26),%sp@-
    moveal %fp@(22),%a1
    movel %fp@(18),%sp@-
    movel %fp@(14),%sp@-
    movew %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(GODEVLOOP)
    jbra COPYBITS_208
COPYBITS_108:           /* an old port with a custom bitsProc and a color source: the source converted to a 1-bit bitmap first */
    movew %a2@(4),%d1
    jbpl COPYBITS_1E4
    tstw %a3@(6)
    jbmi COPYBITS_1E4
    movel %a3@(104),%d0
    jbeq COPYBITS_1E4
    moveal 0x11ac,%a1
    exg %d0,%a1
    cmpl %a1@(32),%d0
    jbeq COPYBITS_1E4
    movel %a0,%sp@-
    subaw #18,%sp
    moveq #0,%d0
    movew %d1,%d0
    lslw #3,%d0
    movew %a2@(32),%d1
    divuw %d1,%d0
    moveq #15,%d2
    addl %d2,%d0
    asrl #4,%d0
    jble COPYBITS_1DC
    addw %d0,%d0
    movew %d0,%sp@(4)
    movel %a2@(6),%d1
    movel %a2@(10),%d2
    movel %d1,%sp@(6)
    movel %d2,%sp@(10)
    swap %d1
    swap %d2
    subw %d1,%d2
    muluw %d2,%d0
    .short  0xA122	| 40835828 _NewHandle (flags 0x0100)
    jbne COPYBITS_1DC
    movel %a0,%sp@(14)
    _HLock
    moveal %a0@,%a0
    movel %a0,%sp@
    movel %a3@(92),%sp@-
    clrl %a3@(92)
    subqw #6,%sp
    movel %sp,%sp@-
    jsr @(0x1664,%za0)@(0x0)	| 40835842
    moveq #33,%d0
    movel %d0,%sp@-
    jsr @(0xf88,%za0)@(0)	| 4083584C
    movel %fp@(26),%sp@-
    pea %sp@(14)
    movel %fp@(18),%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    clrl %sp@-
    jsr @(0x11b0,%za0)@(0)	| 40835864
    movel %sp,%sp@-
    jsr @(0x1650,%za0)@(0x0)	| 4083586C
    addqw #6,%sp
    movel %sp@+,%a3@(92)
    movel %sp,%sp@-
    movel %fp@(18),%sp@-
    movel %fp@(14),%sp@-
    movew %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    movel %a3@(104),%d0
    moveal %d0,%a0
    moveal %a0@(32),%a0
    jsr %a0@
    moveal %sp@(14),%a0
    _DisposHandle
COPYBITS_1DC:           /* return */
    lea %sp@(18),%sp
    moveal %sp@+,%a0
    jbra COPYBITS_208
COPYBITS_1E4:           /* call the port's bitsProc or StdBits (0x11AC) */
    movel %a2,%sp@-
    movel %fp@(18),%sp@-
    movel %fp@(14),%sp@-
    movew %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    movel %a3@(104),%d0
    moveal 0x11ac,%a0
    jbeq COPYBITS_206
    moveal %d0,%a0
    moveal %a0@(32),%a0
COPYBITS_206:           /* call */
    jsr %a0@
COPYBITS_208:           /* show the cursor */
    cmpl %d6,%d7
    jbne COPYBITS_212
    jsr @(0xf4c,%za0)@(0)	| 408358CC
COPYBITS_212:           /* restore registers, return */
    moveml %sp@+,%d2/%d6-%d7/%a2-%a4
    unlk %fp
    rtd #22
    .long   0x00000000	| 408358DC

/* GODEVLOOP: GoDevLoop: run the device loop (vector 0x1C78) with no colors to map */
GODEVLOOP:              /* run the device loop (0x1C78) with no colors to map */
    linkw %fp,#-244
    moveml %d3-%d7,%sp@-
    movel %a1,%fp@(-132)
    movel %a4@(-130),%fp@(-232)
    movel %a4@(-130),%fp@(-236)
    clrl %fp@(-240)
    clrl %fp@(-244)
    jsr @(0x1c78,%za0)@(0)	| 40835900
    moveml %sp@+,%d3-%d7
    unlk %fp
    rtd #18
COPYCICON:              /* CopyMask with a0 = the color icon mask entry (from PlotCIcon) */
    jbra COPYMASK_2

/* COPYMASK: _CopyMask: copy through a mask bitmap. */
trap_CopyMask:
COPYMASK:
    subal %a0,%a0
COPYMASK_2:             /* the source, mask and destination rectangles, mode 0, the mask region if one is given */
    linkw %fp,#0
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveal %fp@(20),%a1
    movel %fp@(24),%d0
    movel %fp@(12),%d1
    moveal %a5@,%a4
    moveal %a4@,%a3
    movel %a4@(-130),%d2
    movel %d2,%d3
    movel %fp@(28),%sp@-
    movel %fp@(16),%sp@-
    movel %fp@(8),%sp@-
    clrw %sp@-
    movel %d2,%sp@-
    tstl %a0
    jbeq COPYMASK_36
    movel %a0,%sp@
COPYMASK_36:            /* the destination */
    moveal %fp@(20),%a0
    jsr @(0x1a04,%za0)@(0)	| 4083594C
    moveal %a0,%a1
    movel %a3,%d4
    jbeq COPYMASK_6C
    btst #0,%d4
    jbne COPYMASK_6C
    moveal %d4,%a0
    jsr @(0x1a5c,%za0)@(0)	| 40835960
    movel %a0@,%d4
    cmpl %a1@,%d4
    jbne COPYMASK_6C
    movel %a0@(6),%d4
    cmpl %a1@(6),%d4
    jbne COPYMASK_6C
    movel %a3@(28),%d2
    movel %a3@(24),%d3
COPYMASK_6C:            /* through the device loop with the mask */
    moveal %fp@(20),%a1
    jsr %pc@(CMDEVLOOP)
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #24

/* CMDEVLOOP: CMDevLoop: run the device loop (vector 0x1C78) with color mapping (fg, bk, op colors) */
CMDEVLOOP:
    linkw %fp,#-244
    movel %a1,%fp@(-132)
    movel %d0,%fp@(-240)
    movel %d1,%fp@(-244)
    movel %d2,%fp@(-232)
    movel %d3,%fp@(-236)
    jsr @(0x1c78,%za0)@(0)	| 408359A8
    unlk %fp
    rtd #18
    .long   0x00000000, 0x00000000, 0x00000000	| 408359B4

/* SEEDFILL: _SeedFill: fill area from a seed point. */
trap_SeedFill:
SEEDFILL:
    moveal %sp@+,%a0
    moveq #-1,%d0
    movel %d0,%sp@-
    jbra CALCMASK_8

/* CALCMASK: _CalcMask: mask of the area reachable from the edges. */
trap_CalcMask:
CALCMASK:
    moveal %sp@+,%a0
    moveq #-1,%d0
    movel %d0,%sp@-
    clrl %sp@-
CALCMASK_8:             /* CalcMask(src, dst, srcRow, dstRow, height, words): start with the edge pixels set in the work area */
    movel %a0,%sp@-
    linkw %fp,#-6
    moveml %d3-%d7/%a2-%a4,%sp@-
    movel %sp,%fp@(-6)
    movew %fp@(16),%d5
    jble CALCMASK_142
    subqw #1,%d5
    subqw #1,%fp@(18)
    jblt CALCMASK_142
    movew %fp@(16),%d0
    addw %d0,%d0
    movew %fp@(20),%d1
    subw %d0,%d1
    movew %d1,%fp@(-2)
    moveal %fp@(24),%a2
    moveq #-1,%d0
    movew %fp@(18),%d3
CALCMASK_42:            /* each row */
    movew %d5,%d2
CALCMASK_44:            /* fill the edge row */
    movew %d0,%a2@+
    dbf %d2,CALCMASK_44
    addaw %d1,%a2
    dbf %d3,CALCMASK_42
    movew %fp@(12),%d0
    jblt CALCMASK_6E
    muluw %fp@(20),%d0
    moveal %fp@(24),%a0
    addal %d0,%a0
    movew %fp@(14),%d0
    movew %d0,%d1
    asrw #3,%d0
    notw %d1
    bclr %d1,%a0@(0x0,%d0:w)
CALCMASK_6E:            /* a row of ones on the stack */
    movel %fp@(8),%d6
    movew %d5,%d1
CALCMASK_74:            /* build it */
    movew %d6,%sp@-
    dbf %d1,CALCMASK_74
    moveal %fp@(28),%a0
    moveal %fp@(24),%a2
CALCMASK_82:            /* pass: until nothing changes */
    sf %d7
    movew %fp@(18),%d4
    moveal %sp,%a1
CALCMASK_8A:            /* each row */
    movel %d6,%d1
    movew %d5,%d3
CALCMASK_8E:            /* left to right: spread the fill through the white pixels */
    movew %a2@,%d1
    jbne CALCMASK_A0
    addqw #2,%a0
    addqw #2,%a1
    addqw #2,%a2
    swap %d1
    dbf %d3,CALCMASK_8E
    jbra CALCMASK_C4
CALCMASK_A0:            /* from above and the left */
    movew %a0@+,%d2
    andw %a1@+,%d1
    orw %d2,%d1
    jbra CALCMASK_AA
CALCMASK_A8:            /* again */
    movew %d0,%d1
CALCMASK_AA:            /* spread right until stable; changed? another pass */
    movel %d1,%d0
    lsrl #1,%d0
    andw %d1,%d0
    orw %d2,%d0
    cmpw %d1,%d0
    jbne CALCMASK_A8
    cmpw %a2@,%d1
    jbeq CALCMASK_BC
    st %d7
CALCMASK_BC:            /* store */
    movew %d1,%a2@+
    swap %d1
    dbf %d3,CALCMASK_8E
CALCMASK_C4:            /* right to left */
    movel %d6,%d1
    movew %d5,%d3
CALCMASK_C8:            /* next word */
    movew %a2@-,%d1
    jbne CALCMASK_D8
    subqw #2,%a0
    subqw #2,%a1
    swap %d1
    dbf %d3,CALCMASK_C8
    jbra CALCMASK_FC
CALCMASK_D8:            /* spread left */
    movew %a0@-,%d2
    andw %a1@-,%d1
    orw %d2,%d1
    jbra CALCMASK_E2
CALCMASK_E0:            /* again */
    movew %d0,%d1
CALCMASK_E2:            /* until stable */
    movel %d1,%d0
    roll #1,%d0
    andw %d1,%d0
    orw %d2,%d0
    cmpw %d1,%d0
    jbne CALCMASK_E0
    cmpw %a2@,%d1
    jbeq CALCMASK_F6
    st %d7
    movew %d1,%a2@
CALCMASK_F6:            /* next word */
    swap %d1
    dbf %d3,CALCMASK_C8
CALCMASK_FC:            /* next row; then the other direction (bottom up) */
    addaw %fp@(22),%a0
    addaw %fp@(20),%a2
    moveal %a2,%a1
    subaw %fp@(20),%a1
    dbf %d4,CALCMASK_8A
    negw %fp@(22)
    negw %fp@(20)
    addaw %fp@(22),%a0
    addaw %fp@(20),%a2
    tstb %d7
    jbne CALCMASK_82
    tstw %d6
    jbpl CALCMASK_142
    movew %fp@(-2),%d1
    moveal %fp@(24),%a2
    movew %fp@(18),%d3
CALCMASK_134:           /* invert the result: the mask is what the fill did not reach */
    movew %d5,%d2
CALCMASK_136:           /* invert */
    notw %a2@+
    dbf %d2,CALCMASK_136
    addaw %d1,%a2
    dbf %d3,CALCMASK_134
CALCMASK_142:           /* return */
    moveal %fp@(-6),%sp
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #24
    .long   0x00000000, 0x00000000	| 40835B18

/* SCROLLRECT: _ScrollRect: scroll the bits in a rectangle, the vacated area into a region. */
trap_ScrollRect:
SCROLLRECT:
    linkw %fp,#-8
    moveml %d6-%d7/%a3-%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a3
    movel %a3@(92),%sp@-
    clrl %a3@(92)
    tstw %a3@(66)
    jblt SCROLLRECT_11E
    tstl %fp@(12)
    jbeq SCROLLRECT_11E
    subqw #6,%sp
    movel %sp,%sp@-
    jsr @(0x1664,%za0)@(0x0)	| 40835B48
    movel #33,%sp@-
    jsr @(0xf88,%za0)@(0)	| 40835B54
    subqw #6,%sp
    movel %sp,%sp@-
    jsr @(0x1668,%za0)@(0x0)	| 40835B5E
    movel #30,%sp@-
    jsr @(0xf8c,%za0)@(0)	| 40835B6A
    subqw #8,%sp
    jsr @(0x1160,%za0)@(0x0)	| 40835B72
    movel %sp@+,%d7
    jsr @(0x1160,%za0)@(0x0)	| 40835B7A
    movel %sp@+,%d6
    movel %d7,%sp@-
    movel %fp@(16),%sp@-
    jsr @(0x117c,%za0)@(0)	| 40835B88
    movel %d7,%sp@-
    movel %a3@(24),%sp@-
    movel %d7,%sp@-
    jsr @(0x1190,%za0)@(0x0)	| 40835B96
    movel %d7,%sp@-
    movel %a3@(28),%sp@-
    movel %d7,%sp@-
    jsr @(0x1190,%za0)@(0x0)	| 40835BA4
    movel %d7,%sp@-
    movel %d6,%sp@-
    jsr @(0x1170,%za0)@(0x0)	| 40835BAE
    movel %d6,%sp@-
    movel %fp@(12),%sp@-
    jsr @(0x1180,%za0)@(0x0)	| 40835BBA
    moveal %fp@(16),%a0
    movel %a0@+,%fp@(-8)
    movel %a0@+,%fp@(-4)
    movel %fp@(12),%d0
    addw %d0,%fp@(-6)
    addw %d0,%fp@(-2)
    swap %d0
    addw %d0,%fp@(-8)
    addw %d0,%fp@(-4)
    movel %d7,%sp@-
    movel %d6,%sp@-
    movel %d6,%sp@-
    jsr @(0x1190,%za0)@(0x0)	| 40835BE8
    pea %a3@(2)
    movel %sp@,%sp@-
    movel %fp@(16),%sp@-
    pea %fp@(-8)
    clrw %sp@-
    movel %d6,%sp@-
    jsr @(0x11b0,%za0)@(0)	| 40835C00
    movel %sp,%sp@-
    jsr @(0x1654,%za0)@(0x0)	| 40835C08
    addqw #6,%sp
    movel %sp,%sp@-
    jsr @(0x1650,%za0)@(0x0)	| 40835C12
    addqw #6,%sp
    movel %fp@(8),%d0
    jbeq SCROLLRECT_114
    movel %d0,%sp@-
    movel %d7,%sp@-
    movel %d6,%sp@-
    movel %d0,%sp@-
    jsr @(0x1198,%za0)@(0x0)	| 40835C28
    jsr @(0x1150,%za0)@(0x0)
SCROLLRECT_114:         /* dispose of the regions */
    moveal %d7,%a0
    _DisposHandle
    moveal %d6,%a0
    _DisposHandle
    jbra SCROLLRECT_12C
SCROLLRECT_11E:         /* hidden port: the update region is empty */
    movel %fp@(8),%d0
    jbeq SCROLLRECT_12C
    movel %d0,%sp@-
    jsr @(0x1174,%za0)@(0x0)	| 40835C46
SCROLLRECT_12C:         /* restore picture recording, return */
    movel %sp@+,%a3@(92)
    moveml %sp@+,%d6-%d7/%a3-%a4
    unlk %fp
    rtd #12
    .short  0x0000, 0x0000, 0x0000	| 40835C5A

/* PACKBITS: _PackBits: run-length compress. */
trap_PackBits:
PACKBITS:
    moveml %d3-%d4/%a2,%sp@-
    movew #128,%d4
    moveal %sp@(22),%a0
    moveal %a0@,%a0
    moveal %sp@(18),%a1
    moveal %a1@,%a1
    movew %sp@(16),%d3
    subqw #1,%d3
    jblt PACKBITS_96
PACKBITS_1C:            /* next run */
    moveb %a0@+,%d0
    jbra PACKBITS_2C
PACKBITS_20:            /* end a literal run before a repeat */
    moveb %a0@(-1),%d0
    subw %a0,%d2
    addw %d2,%d3
    addqw #1,%d2
    moveb %d2,%a2@
PACKBITS_2C:            /* at most 128 bytes per run */
    moveq #127,%d1
    cmpw %d4,%d3
    jbge PACKBITS_34
    movew %d3,%d1
PACKBITS_34:            /* three equal bytes? a repeat run */
    movew %a0,%d2
    moveal %a1,%a2
    clrb %a1@+
    cmpb %a0@,%d0
    jbne PACKBITS_52
    cmpb %a0@(1),%d0
    jbne PACKBITS_52
    jbra PACKBITS_7E
PACKBITS_46:            /* literal run: next byte */
    moveb %a0@+,%d0
    cmpb %a0@,%d0
    jbne PACKBITS_52
    cmpb %a0@(1),%d0
    jbeq PACKBITS_64
PACKBITS_52:            /* append it */
    moveb %d0,%a1@+
    dbf %d1,PACKBITS_46
    subw %a0,%d2
    negw %d2
    moveb %d2,%a2@
    subw %d4,%d3
    jbpl PACKBITS_1C
    jbra PACKBITS_96
PACKBITS_64:            /* a repeat starts: close the literal run */
    tstw %d1
    jbeq PACKBITS_52
    subw %a0,%d2
    addw %d2,%d3
    notw %d2
    moveb %d2,%a2@
    moveq #127,%d1
    cmpw %d4,%d3
    jbge PACKBITS_78
    movew %d3,%d1
PACKBITS_78:            /* start the repeat */
    movel %a0,%d2
    moveal %a1,%a2
    clrb %a1@+
PACKBITS_7E:            /* the repeated byte */
    moveb %d0,%a1@+
PACKBITS_80:            /* count the repeats */
    cmpb %a0@+,%d0
    dbne %d1,PACKBITS_80
    jbeq PACKBITS_8C
    subqw #1,%d1
    jbge PACKBITS_20
PACKBITS_8C:            /* the run's count (negative) */
    subqw #1,%a0
    subw %a0,%d2
    moveb %d2,%a2@
    subw %d4,%d3
    jbpl PACKBITS_1C
PACKBITS_96:            /* update the pointers */
    moveq #0,%d0
    movew %sp@(16),%d0
    moveal %sp@(22),%a0
    addl %d0,%a0@
    moveal %sp@(18),%a2
    movel %a1,%a2@
    moveml %sp@+,%d3-%d4/%a2
PACKBITS_AC:            /* pop the parameters */
    moveal %sp@+,%a0
    lea %sp@(10),%sp
    jmp %a0@

/* UNPACKBITS: _UnpackBits: expand. */
trap_UnpackBits:
UNPACKBITS:
    moveal %sp@(10),%a0
    moveal %a0@,%a0
    moveal %sp@(6),%a1
    moveal %a1@,%a1
    movew %sp@(4),%d2
    extl %d2
    addl %a1,%d2
    jbra UNPACKBITS_1E
UNPACKBITS_16:          /* literal run */
    extw %d1
UNPACKBITS_18:          /* copy */
    moveb %a0@+,%a1@+
    dbf %d1,UNPACKBITS_18
UNPACKBITS_1E:          /* until the destination is full: next flag byte (-128: no-op) */
    cmpal %d2,%a1
    jbcc UNPACKBITS_36
    moveb %a0@+,%d1
    jbpl UNPACKBITS_16
    negb %d1
    jbvs UNPACKBITS_1E
    extw %d1
    moveb %a0@+,%d0
UNPACKBITS_2E:          /* repeat */
    moveb %d0,%a1@+
    dbf %d1,UNPACKBITS_2E
    jbra UNPACKBITS_1E
UNPACKBITS_36:          /* update the pointers */
    movel %a0,%d0
    moveal %sp@(10),%a0
    movel %d0,%a0@
    moveal %sp@(6),%a0
    movel %a1,%a0@
    jbra PACKBITS_AC
    .short  0x0000, 0x0000, 0x0000	| 40835D5A

/* PACKWORDS: pack 16-bit pixels. */
PACKWORDS:
    moveml %d3-%d4/%a2,%sp@-
    movew #128,%d4
    moveal %sp@(22),%a0
    moveal %a0@,%a0
    moveal %sp@(18),%a1
    moveal %a1@,%a1
    movew %sp@(16),%d3
    lsrw #1,%d3
    subqw #1,%d3
    jblt PACKWORDS_A4
PACKWORDS_20:           /* next run */
    movew %a0@+,%d0
    jbra PACKWORDS_32
PACKWORDS_24:           /* end a literal run before a repeat */
    movew %a0@(-2),%d0
    subw %a0,%d2
    asrw #1,%d2
    addw %d2,%d3
    addqw #1,%d2
    moveb %d2,%a2@
PACKWORDS_32:           /* at most 128 words per run */
    moveq #127,%d1
    cmpw %d4,%d3
    jbge PACKWORDS_3A
    movew %d3,%d1
PACKWORDS_3A:           /* three equal words? a repeat run */
    movew %a0,%d2
    moveal %a1,%a2
    clrb %a1@+
    cmpw %a0@,%d0
    jbne PACKWORDS_58
    cmpw %a0@(2),%d0
    jbne PACKWORDS_58
    jbra PACKWORDS_88
PACKWORDS_4C:           /* literal run: next word */
    movew %a0@+,%d0
    cmpw %a0@,%d0
    jbne PACKWORDS_58
    cmpw %a0@(2),%d0
    jbeq PACKWORDS_6C
PACKWORDS_58:           /* append it */
    movew %d0,%a1@+
    dbf %d1,PACKWORDS_4C
    subw %a0,%d2
    negw %d2
    asrw #1,%d2
    moveb %d2,%a2@
    subw %d4,%d3
    jbpl PACKWORDS_20
    jbra PACKWORDS_A4
PACKWORDS_6C:           /* a repeat starts: close the literal run */
    tstw %d1
    jbeq PACKWORDS_58
    subw %a0,%d2
    asrw #1,%d2
    addw %d2,%d3
    notw %d2
    moveb %d2,%a2@
    moveq #127,%d1
    cmpw %d4,%d3
    jbge PACKWORDS_82
    movew %d3,%d1
PACKWORDS_82:           /* start the repeat */
    movel %a0,%d2
    moveal %a1,%a2
    clrb %a1@+
PACKWORDS_88:           /* the repeated word */
    movew %d0,%a1@+
PACKWORDS_8A:           /* count the repeats */
    cmpw %a0@+,%d0
    dbne %d1,PACKWORDS_8A
    jbeq PACKWORDS_96
    subqw #1,%d1
    jbge PACKWORDS_24
PACKWORDS_96:           /* the run's count */
    subqw #2,%a0
    subw %a0,%d2
    asrw #1,%d2
    moveb %d2,%a2@
    subw %d4,%d3
    jbpl PACKWORDS_20
PACKWORDS_A4:           /* update the pointers */
    moveq #0,%d0
    movew %sp@(16),%d0
    moveal %sp@(22),%a0
    addl %d0,%a0@
    moveal %sp@(18),%a2
    movel %a1,%a2@
    moveml %sp@+,%d3-%d4/%a2
PACKWORDS_BA:           /* pop the parameters */
    moveal %sp@+,%a0
    lea %sp@(10),%sp
    jmp %a0@

/* UNPACKWORDS: unpack 16-bit pixels. */
UNPACKWORDS:
    moveal %sp@(10),%a0
    moveal %a0@,%a0
    moveal %sp@(6),%a1
    moveal %a1@,%a1
    movew %sp@(4),%d2
    extl %d2
    addl %a1,%d2
    jbra UNPACKWORDS_1E
UNPACKWORDS_16:         /* literal run */
    extw %d1
UNPACKWORDS_18:         /* copy */
    movew %a0@+,%a1@+
    dbf %d1,UNPACKWORDS_18
UNPACKWORDS_1E:         /* until full: next flag byte */
    cmpal %d2,%a1
    jbcc UNPACKWORDS_36
    moveb %a0@+,%d1
    jbpl UNPACKWORDS_16
    negb %d1
    jbvs UNPACKWORDS_1E
    extw %d1
    movew %a0@+,%d0
UNPACKWORDS_2E:         /* repeat */
    movew %d0,%a1@+
    dbf %d1,UNPACKWORDS_2E
    jbra UNPACKWORDS_1E
UNPACKWORDS_36:         /* update the pointers */
    movel %a0,%d0
    moveal %sp@(10),%a0
    movel %d0,%a0@
    moveal %sp@(6),%a0
    movel %a1,%a0@
    jbra PACKWORDS_BA
    .long   0x00000000, 0x00000000	| 40835E68

/* STDRGN: StdRgn: the region bottleneck. */
trap_StdRgn:
STDRGN:
    linkw %fp,#0
    moveml %d6-%d7/%a2-%a4,%sp@-
    moveq #0,%d7
    moveb %fp@(12),%d7
    jsr @(0x1a3c,%za0)@(0)	| 40835E7E
    jble STDRGN_2E
    moveb %d7,%sp@-
    jsr %pc@(PUTPICVERB)
    movew #128,%d0
    addw %d7,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %fp@(8),%sp@-
    jsr %pc@(PUTPICRGN)
STDRGN_2E:              /* draw on each screen */
    pea %pc@(STDRGN_5C)
    pea %pc@(STDRGN_46)
    jsr @(0x1aa0,%za0)@(0)	| 40835EA6
    moveml %sp@+,%d6-%d7/%a2-%a4
    unlk %fp
    rtd #6
STDRGN_46:              /* rectangle proc: the region's box */
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %fp@(8),%a0
    moveal %a0@,%a0
    lea %a0@(2),%a0
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    moveal %d0,%a0
    jmp %a0@
STDRGN_5C:              /* draw proc: frame (FRRGN) or the other verbs (DRAWRGN); framing while a region is open adds it there */
    movel %fp@(8),%sp@-
    jsr @(0x1a60,%za0)@(0)	| 40835ED0
    tstb %d7
    jbne STDRGN_8C
    tstl %a3@(96)
    jbeq STDRGN_86
    movel %fp@(8),%sp@-
    movel %a4@(-148),%sp@-
    pea %a4@(-150)
    pea %a4@(-152)
    jsr @(0x1a6c,%za0)@(0)	| 40835EF0
STDRGN_86:              /* frame */
    jsr %pc@(FRRGN)
    jbra STDRGN_90
STDRGN_8C:              /* paint, erase, invert, fill */
    jsr %pc@(DRAWRGN)
STDRGN_90:              /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40835F02

/* FRAMERGN: _FrameRgn: frame (outline with the pen) the region. */
trap_FrameRgn:
FRAMERGN:
    moveq #0,%d0
    jbra CALLRGN

/* PAINTRGN: _PaintRgn: paint (fill with the pen pattern) the region. */
trap_PaintRgn:
PAINTRGN:
    moveq #1,%d0
    jbra CALLRGN

/* ERASERGN: _EraseRgn: erase (fill with the background) the region. */
trap_EraseRgn:
ERASERGN:
    moveq #2,%d0
    jbra CALLRGN

/* INVERTRGN: _InvertRgn: invert the region. */
trap_InverRgn:
INVERTRGN:
    moveq #3,%d0
    jbra CALLRGN

/* FILLRGN: _FillRgn: fill with a pattern the region. */
trap_FillRgn:
FILLRGN:
    moveq #0,%d0
    jbra FILLCRGN_2

/* FILLCRGN: _FillCrgn: fill with a pattern the region with a pixel pattern. */
trap_FillCRgn:
FILLCRGN:
    moveq #1,%d0
FILLCRGN_2:             /* the pixpat, then CALLRGN with verb 4 */
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a0,%sp@-
    movel %a1,%sp@-
    jsr @(0x1a8c,%za0)@(0)	| 40835F2E
    moveq #4,%d0

/* CALLRGN: call the port's rgn bottleneck (grafProcs) or the standard one. */
CALLRGN:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    moveb %d0,%sp@-
    movel %a1,%sp@-
    movel %a0,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x1144,%a0
    jbeq CALLRGN_1E
    moveal %d0,%a0
    moveal %a0@(28),%a0
CALLRGN_1E:             /* through the port's rgnProc or StdRgn */
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40835F56

/* DRAWRGN: DrawRgn(verb, rgn): paint, erase, invert or fill a region (through STDDEVLOOP); empty regions are skipped */
DRAWRGN:
    linkw %fp,#-8
    moveal %fp@(14),%a0
    moveal %a0@,%a0
    movel %a0@(2),%fp@(-8)
    movel %a0@(6),%fp@(-4)
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(66)
    jbmi DRAWRGN_58
    moveal %a0,%a1
    jsr @(0x1a5c,%za0)@(0)	| 40835F82
    movel %a0,%sp@-
    clrl %sp@-
    movel %a0,%sp@-
    pea %fp@(-8)
    clrl %sp@-
    pea %fp@(-8)
    movew %fp@(12),%sp@-
    oriw #8,%sp@
    movel %fp@(8),%sp@-
    movel %a1@(28),%sp@-
    movel %a1@(24),%sp@-
    movel %fp@(14),%sp@-
    clrw %sp@-
    jsr @(0x1a9c,%za0)@(0)	| 40835FB2
DRAWRGN_58:             /* return */
    unlk %fp
    rtd #10
    .short  0x0000	| 40835FBE

/* FRRGN: FrRgn(rgn): frame a region: the region minus its inset by the pen size, painted; rectangles as FrameRect */
FRRGN:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a3
    tstw %a3@(66)
    jbmi FRRGN_6C
    moveal %fp@(14),%a0
    moveal %a0@,%a0
    cmpiw #10,%a0@
    jbne FRRGN_2A
    pea %a0@(2)
    jbsr FRMRECT
    jbra FRRGN_6C
FRRGN_2A:               /* non-rectangular: a temporary region = rgn minus rgn inset by the pen; paint it */
    clrl %sp@-
    jsr @(0x1160,%za0)@(0x0)	| 40835FEC
    movel %sp@+,%d7
    movel %fp@(14),%sp@-
    movel %d7,%sp@-
    jsr @(0x1170,%za0)@(0x0)	| 40835FFA
    movel %d7,%sp@-
    movel %a3@(52),%sp@-
    jsr @(0x1184,%za0)@(0x0)	| 40836006
    movel %fp@(14),%sp@-
    movel %d7,%sp@-
    movel %d7,%sp@-
    jsr @(0x1198,%za0)@(0x0)	| 40836014
    movel %d7,%sp@-
    movew %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(DRAWRGN)
    moveal %d7,%a0
    _DisposHandle
FRRGN_6C:               /* restore registers, return */
    moveml %sp@+,%d7/%a3-%a4
    unlk %fp
    rtd #10
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40836036
