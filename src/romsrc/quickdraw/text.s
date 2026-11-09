/*
 quickdraw/text.s - QuickDraw text
 From DRTEXT (0x40828150). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* DRTEXT: DrText: draw text through the font (bits from the strike, styles). */
DRTEXT:
    moveal %d0,%a0
    movel %sp,%d0
    asrw #2,%d0
    scs %d0
    jbcc DRTEXT_C
    subqw #2,%sp
DRTEXT_C:               /* frame; the font (FMSwapFont via the stdTxMeas set-up), the strike and the width table */
    linkw %fp,#-440
    andiw #2,%d0
    movew %d0,%fp@(-424)
    movel %a0,%d0
    moveml %d0-%d7/%a1-%a4,%sp@-
    movel %sp,%fp@(-4)
    movel %a5,%fp@(-140)
    moveal %a5@,%a4
    moveal %a4@,%a3
    movew %fp@(-424),%d0
    movel %fp@(0xc,%d0:w),%fp@(-208)
    movel %fp@(0x8,%d0:w),%fp@(-212)
    clrw %fp@(-214)
    movel TheGDevice,LastTxGDevice
    lea %a3@(2),%a1
    lea %fp@(-398),%a2
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x1a08,%za0)@(0)	| 4082819C
    movel %d1,%fp@(-164)
    moveb %d2,%fp@(-427)
DRTEXT_5A:              /* measure the text (StdTxMeas): its width; nothing to draw: done */
    movew %fp@(-424),%d0
    clrw %sp@-
    movew %fp@(0x14,%d0:w),%d1
    movew %d1,%sp@-
    jble DRTEXT_CBE
    movew %d1,%fp@(-426)
    movel %fp@(0x10,%d0:w),%sp@-
    pea %fp@(0xc,%d0:w)
    pea %fp@(0x8,%d0:w)
    pea %fp@(-204)
    moveal 0x11b4,%a0
    jsr %a0@
    addqw #2,%sp
    clrb %fp@(-439)
    movel %a4@(-172),%d1
    moveal %a4@(-176),%a4
    moveal %a4@(2),%a2
    moveal %a2@,%a2
    movew %a2@,%d0
    btst #9,%d0
    sne %fp@(-437)
    lsrw #2,%d0
    andiw #7,%d0
    sne %d2
    movew %d0,%fp@(-432)
    moveq #1,%d3
    lslw %d0,%d3
    movew %d3,%fp@(-410)
    movew %a2@(14),%fp@(-404)
    btst #0,%a2@(1)
    sne %fp@(-402)
    movew %a2@(8),%fp@(-416)
    clrl %fp@(-148)
    movew %a3@(72),%d0
    andiw #-9,%d0
    tstb %fp@(-437)
    jbeq DRTEXT_E6
    cmpiw #1,%d0
    jbne DRTEXT_E6
    moveq #64,%d0
DRTEXT_E6:              /* the mode: bit 6 (srcOr-type mask modes) uses a mask */
    movew %d0,%fp@(-430)
    btst #6,%d0
    sne %d3
    jbeq DRTEXT_FA
    lea %fp@(-306),%a0
    movel %a0,%fp@(-148)
DRTEXT_FA:              /* arithmetic modes on a 1-bit destination: the boolean equivalent */
    btst #5,%d0
    jbeq DRTEXT_118
    cmpiw #1,%fp@(-366)
    jbne DRTEXT_118
    lea %pc@(ARITHMODE),%a0
    andiw #7,%d0
    moveb %a0@(0x0,%d0:w),%d0
    movew %d0,%fp@(-430)
DRTEXT_118:             /* a mask with a color font: the font's own mask */
    andb %d2,%d3
    jbeq DRTEXT_148
    moveal WidthPtr,%a0
    movel %a0@(0x400,%za0)@(0x0),%d0	| 40828270
    sne %d3
    jbeq DRTEXT_148
    moveal %d0,%a0
    moveq #0,%d0
    movew %a0@(24),%d0
    addl %d0,%d0
    movel %d0,%fp@(-96)
    lea %a0@(26),%a0
    movel %a0,%fp@(-92)
    lea %fp@(-320),%a0
    movel %a0,%fp@(-148)
DRTEXT_148:             /* pen position (fixed point h); mode 1 (srcOr) and black text: the fast path */
    moveb %d3,%fp@(-400)
    orb %fp@(-437),%d3
    moveb %d3,%fp@(-435)
    movel %a3@(48),%d2
    movel %d2,%fp@(-116)
    movew %d2,%fp@(-10)
    swap %d2
    movew #-32768,%d2
    cmpiw #1,%fp@(-430)
    seq %fp@(-436)
    bclr #6,%fp@(-429)
    jbeq DRTEXT_180
    tstw %fp@(-430)
    seq %fp@(-436)
DRTEXT_180:             /* color port: the character extra, the fractional pen */
    clrl %fp@(-144)
    tstw %a3@(6)
    jbpl DRTEXT_1C0
    movew %a3@(12),%d0
    jbeq DRTEXT_198
    jbsr CALCCHAREXTRA
    movel %d0,%fp@(-144)
DRTEXT_198:             /* fractional h; foreground and background differ in the depth? */
    movew %a3@(14),%d2
    movew %d2,%fp@(-418)
    movel %a3@(80),%d0
    cmpl %a3@(84),%d0
    jbeq DRTEXT_1B2
    addql #1,%d0
    movew %fp@(-366),%d3
    lsrl %d3,%d0
DRTEXT_1B2:             /* colorize flags */
    sne %d0
    tstb %fp@(-437)
    jbeq DRTEXT_1D6
    tstl %a3@(84)
    jbra DRTEXT_1D4
DRTEXT_1C0:             /* old port: fgColor not black? bkColor not white? */
    btst #5,%a3@(83)
    sne %d0
    tstb %fp@(-437)
    jbeq DRTEXT_1D6
    btst #0,%a3@(87)
DRTEXT_1D4:             /* colorize */
    seq %d0
DRTEXT_1D6:             /* italic: widen by the slant; the text's bounding rectangle */
    andb %d0,%fp@(-436)
    addl %d1,%d2
    swap %d2
    clrw %fp@(-414)
    tstb %a4@(17)
    jbeq DRTEXT_22A
    moveq #0,%d0
    moveb %a4@(7),%d0
    movew %a2@(18),%d3
    subqw #1,%d3
    muluw %d3,%d0
    asrw #4,%d0
    addb %a4@(6),%d0
    subb %a4@(12),%d0
    extw %d0
    moveq #4,%d3
    cmpb %a4@(11),%d3
    jble DRTEXT_212
    moveb %a4@(11),%d3
    jbeq DRTEXT_212
    addqw #1,%d3
DRTEXT_212:             /* italic extra */
    addw %d3,%d0
    movew %d0,%fp@(-414)
    addw %d0,%d2
    moveq #0,%d0
    moveb %a4@(7),%d0
    muluw %a2@(20),%d0
    asrw #4,%d0
    subw %d0,%fp@(-416)
DRTEXT_22A:             /* the rectangle: left from the pen, top/bottom from ascent/descent */
    movew %fp@(-416),%d0
    addw %d0,%fp@(-10)
    movew %d2,%fp@(-6)
    movew %fp@(-116),%d2
    subw %a2@(18),%d2
    movew %d2,%fp@(-12)
    addw %a2@(14),%d2
    movew %d2,%fp@(-8)
    movel %fp@(-12),%fp@(-20)
    movel %fp@(-8),%fp@(-16)
    movew %fp@(-424),%d3
    movel %fp@(0xc,%d3:w),%d0
    cmpl %fp@(0x8,%d3:w),%d0
    sne %fp@(-401)
    jbeq DRTEXT_2C2
    swap %d0
    clrw %d0
    mulul %d0,%d0,%d1
    moveq #0,%d2
    movew %fp@(0xa,%d3:w),%d2
    swap %d2
    divul %d2,%d0,%d1
    movel %fp@(-116),%d0
    movel %d0,%fp@(-112)
    addw %fp@(0xe,%d3:w),%d0
    movew %d0,%fp@(-106)
    swap %d0
    addw %fp@(0xc,%d3:w),%d0
    movew %d0,%fp@(-108)
    movel %fp@(-116),%d0
    movel %d0,%fp@(-104)
    addw %fp@(0xa,%d3:w),%d0
    movew %d0,%fp@(-98)
    swap %d0
    addw %fp@(0x8,%d3:w),%d0
    movew %d0,%fp@(-100)
    pea %fp@(-20)
    pea %fp@(-104)
    pea %fp@(-112)
    jsr @(0x11e8,%za0)@(0)	| 4082840C
DRTEXT_2C2:             /* advance the pen by the width */
    andib #15,%ccr
    tstw %a3@(6)
    jbpl DRTEXT_2D0
    addw %d1,%a3@(14)
DRTEXT_2D0:             /* integer and fraction; pen hidden: done; clip the rectangle to the port's regions */
    swap %d1
    movew %a3@(50),%d0
    addxw %d1,%d0
    movew %d0,%a3@(50)
    tstw %a3@(66)
    jblt DRTEXT_CBE
    movew %fp@(-14),%sp@-
    movew #32000,%fp@(-14)
    pea %fp@(-20)
    pea %fp@(-392)
    moveal %a3@(28),%a0
    moveal %a0@,%a0
    pea %a0@(2)
    moveal %a3@(24),%a0
    moveal %a0@,%a0
    pea %a0@(2)
    movew #4,%sp@-
    pea %fp@(-44)
    jsr @(0x1a84,%za0)@(0)	| 40828462
    jbeq DRTEXT_CBE
    movew %sp@+,%fp@(-14)
    lea %a2@(26),%a0
    movel %a0,%fp@(-80)
    moveq #0,%d1
    movew %a2@(24),%d1
    movew %fp@(-432),%d0
    lsll %d0,%d1
    addl %d1,%d1
    movel %d1,%fp@(-84)
    movew %a2@(14),%fp@(-64)
    tstb %a4@(7)
    jbne DRTEXT_46C
    tstb %a4@(6)
    jbne DRTEXT_46C
    tstb %fp@(-436)
    jbeq DRTEXT_46C
    tstw %a4@(10)
    jbne DRTEXT_46C
    tstb %fp@(-401)
    jbne DRTEXT_46C
    moveal %a3@(0x1c,%za0)@(0),%a0	| 408284B8
    moveq #10,%d0
    cmpw %a0@,%d0
    jbne DRTEXT_46C
    moveq #1,%d0
    movew %fp@(-432),%d1
    lslw %d1,%d0
    cmpw %fp@(-366),%d0
    jbne DRTEXT_46C
    cmpiw #16,%fp@(-368)
    jbne DRTEXT_39A
    seq %fp@(-435)
    clrw %fp@(-430)
    jbra DRTEXT_46C
DRTEXT_39A:             /* a non-rectangular clip: intersect the boxes */
    moveal %a3@(24),%a1
    moveal %a1@,%a0
    cmpiw #10,%a0@
    jbeq DRTEXT_3BE
    movel %a1,%sp@-
    pea %fp@(-44)
    movew #-1,%sp@-
    jsr @(0x1aa4,%za0)@(0)	| 40828500
    jblt DRTEXT_CBE
    jbgt DRTEXT_46C
DRTEXT_3BE:             /* fast path possible: draw straight to the destination (fp-399) */
    st %fp@(-399)
    clrb %fp@(-400)
    clrl %fp@(-152)
    movew %fp@(-44),%d0
    movew %fp@(-40),%d1
    subw %fp@(-12),%d0
    jbne DRTEXT_3DE
    cmpw %fp@(-8),%d1
    jbeq DRTEXT_3EE
DRTEXT_3DE:             /* a partial strike: the vertical clip */
    clrb %fp@(-402)
    moveb %d0,%fp@(-404)
    subw %fp@(-44),%d1
    moveb %d1,%fp@(-403)
DRTEXT_3EE:             /* the destination row geometry */
    movew %fp@(-12),%d0
    subw %fp@(-392),%d0
    movew %fp@(-394),%d1
    andiw #32767,%d1
    mulsw %d1,%d0
    addl %fp@(-398),%d0
    movel %d0,%fp@(-76)
    movew %d1,%fp@(-52)
    movew %fp@(-390),%fp@(-62)
    tstb %fp@(-427)
    jbeq DRTEXT_614
    pea %fp@(-44)
    movel %fp@(-164),%sp@-
    jsr @(0xf54,%za0)@(0)	| 40828572
    movel %fp@(-80),%d0
    jsr @(0x644,%za0)@(0x0)	| 4082857C
    movel %d0,%fp@(-80)
    movel %a2,%d0
    jsr @(0x644,%za0)@(0x0)	| 40828588
    moveal %d0,%a2
    movew %fp@(-424),%d1
    movel %fp@(0x10,%d1:w),%d0
    jsr @(0x644,%za0)@(0x0)	| 40828598
    movel %d0,%fp@(0x10,%d1:w)
    moveq #1,%d0
    movel %a2,%sp@-
    jsr @(0x574,%za0)@(0x0)	| 408285A6
    moveal %sp@+,%a2
    moveb %d0,%fp@(-428)
    moveb #1,%fp@(-439)
    jbra DRTEXT_614
DRTEXT_46C:             /* slow path: a temporary 1-bit (or deeper) buffer for the text */
    sf %fp@(-399)
    sf %fp@(-427)
    movew %fp@(-10),%d0
    subw %fp@(-390),%d0
    andiw #-32,%d0
    addw %fp@(-390),%d0
    movew %d0,%fp@(-62)
    moveq #0,%d1
    movew %fp@(-6),%d1
    subw %d0,%d1
    movew %d1,%d2
    movew %fp@(-432),%d4
    lsll %d4,%d1
    lsrl #5,%d1
    addqw #2,%d1
    movew %fp@(-64),%d3
    muluw %d1,%d3
    cmpil #7168,%d3
    jbgt DRTEXT_51E
    movew %d3,%fp@(-50)
    addw %d1,%d3
    lslw #2,%d1
    movew %d1,%fp@(-52)
    movew %fp@(-14),%d5
    subw %fp@(-18),%d5
    lsrw #5,%d5
    addqw #2,%d5
    movew %d5,%d0
    addw %d0,%d3
    addw %d0,%d3
    lslw %d4,%d0
    addw %d0,%d3
    muluw %fp@(-366),%d5
    addw %d5,%d3
    addw %d5,%d3
    tstb %fp@(-400)
    jbeq DRTEXT_500
    lsrw #5,%d2
    addqw #2,%d2
    addw %d2,%d1
    movew %fp@(-64),%d0
    muluw %d2,%d0
    movew %d0,%fp@(-174)
    lslw #2,%d2
    movew %d2,%fp@(-176)
    addw %d0,%d3
    addw %d2,%d3
    movew %fp@(-14),%d0
    subw %fp@(-18),%d0
    lsrw #5,%d0
    addw %d0,%d3
DRTEXT_500:             /* outline/shadow: extra rows */
    tstb %a4@(11)
    jbeq DRTEXT_50C
    addw %fp@(-50),%d3
    addw %d1,%d3
DRTEXT_50C:             /* does it fit in the stack? else split the string in halves */
    lsll #2,%d3
    addil #2048,%d3
    moveal 0x594,%a0
    jsr %a0@
    cmpl %d0,%d3
    jble DRTEXT_58E
DRTEXT_51E:             /* halve the count */
    movew %fp@(-424),%d6
    movew %fp@(0x14,%d6:w),%d0
    movew %d0,%d7
    lsrw #1,%d7
    jbne DRTEXT_534
    subqw #1,%fp@(-214)
    jbra DRTEXT_CBE
DRTEXT_534:             /* first split: save the hilite state */
    tstw %fp@(-214)
    jbne DRTEXT_544
    moveb HiliteMode,%fp@(-438)
    movew %d0,%fp@(-214)
DRTEXT_544:             /* restore the pen */
    movel %fp@(-116),%a3@(48)
    tstw %a3@(6)
    jbpl DRTEXT_556
    movew %fp@(-418),%a3@(14)
DRTEXT_556:             /* draw the first half */
    movew %d7,%fp@(0x14,%d6:w)
DRTEXT_55A:             /* again with the pen and the hilite state restored */
    moveal %a5@,%a4
    movel %fp@(-208),%fp@(0xc,%d6:w)
    movel %fp@(-212),%fp@(0x8,%d6:w)
    moveb %fp@(-438),HiliteMode
    jmp %pc@(DRTEXT_5A)
DRTEXT_572:             /* the second half */
    moveq #0,%d7
    movew %fp@(-424),%d6
    movew %fp@(0x14,%d6:w),%d7
    movew %fp@(-214),%d0
    cmpw %d0,%d7
    jble DRTEXT_588
    movew %d0,%fp@(0x14,%d6:w)
DRTEXT_588:             /* advance the string pointer */
    addl %d7,%fp@(0x10,%d6:w)
    jbra DRTEXT_55A
DRTEXT_58E:             /* colored text in the buffer: fill it with the background color index */
    moveq #0,%d0
    tstw %fp@(-432)
    jbeq DRTEXT_5DE
    cmpiw #2,%fp@(-430)
    jbeq DRTEXT_5DE
    tstb %fp@(-437)
    jbne DRTEXT_5B4
    cmpiw #50,%fp@(-430)
    jbeq DRTEXT_5DE
    btst #5,%fp@(-429)
    jbeq DRTEXT_5DE
DRTEXT_5B4:             /* the background color's index */
    subqw #6,%sp
    movel %sp,%sp@-
    jsr @(0x1668,%za0)@(0x0)	| 40828708
    clrl %sp@-
    pea %sp@(4)
    jsr @(0x16cc,%za0)@(0)	| 40828714
    moveq #0,%d0
    moveq #32,%d1
    movew %fp@(-410),%d2
DRTEXT_5D2:             /* replicate it across a long */
    asll %d2,%d0
    orl %sp@,%d0
    subw %d2,%d1
    jbgt DRTEXT_5D2
    lea %sp@(10),%sp
DRTEXT_5DE:             /* the buffer on the stack, filled */
    movel %d0,%fp@(-152)
    movew %fp@(-50),%d3
    subqw #1,%d3
    movel %d0,%sp@-
    movel %sp,%fp@(-48)
DRTEXT_5EE:             /* fill */
    movel %d0,%sp@-
    dbf %d3,DRTEXT_5EE
    movel %sp,%fp@(-76)
    movel %d0,%sp@-
    tstb %fp@(-400)
    jbeq DRTEXT_612
    movew %fp@(-174),%d3
    subqw #1,%d3
    clrl %sp@-
DRTEXT_608:             /* the bold/shadow work buffer */
    clrl %sp@-
    dbf %d3,DRTEXT_608
    movel %sp,%fp@(-88)
DRTEXT_612:             /* guard long */
    clrl %sp@-
DRTEXT_614:             /* the strike: bitmap, location table, offset/width table */
    lea %a2@(26),%a0
    moveq #0,%d0
    movew %a2@(14),%d0
    mulul %fp@(-84),%d0
    addal %d0,%a0
    movel %a0,%fp@(-136)
    movew %a2@(10),%d0
    swap %d0
    jbpl DRTEXT_634
    moveq #0,%d0
DRTEXT_634:             /* the first and last character */
    movew %a2@(16),%d0
    lea %a2@(0x10,%d0:l:2),%a1
    movel %a1,%fp@(-132)
    movew %a2@(4),%d0
    movew %a2@(2),%d1
    movew %d1,%fp@(-408)
    subw %d1,%d0
    movew %d0,%fp@(-406)
    addqw #3,%d0
    btst #1,%a2@(1)
    jbeq DRTEXT_65E
    addw %d0,%d0
DRTEXT_65E:             /* the width table; the starting h in the buffer */
    lea %a1@(0x0,%d0:w:2),%a0
    movel %a0,%fp@(-128)
    moveal WidthTabHandle,%a0
    moveal %a0@,%a0
    movel %a0@(128),%fp@(-120)
    movew %fp@(-62),%d1
    movew %fp@(-114),%d0
    addw %fp@(-416),%d0
    subw %d1,%d0
    movew %d0,%fp@(-124)
    tstw %a3@(6)
    jbpl DRTEXT_692
    movew %fp@(-418),%fp@(-122)
    jbra DRTEXT_698
DRTEXT_692:             /* the fraction starts at one half */
    movew #-32768,%fp@(-122)
DRTEXT_698:             /* the clip in buffer coordinates */
    subw %d1,%fp@(-42)
    subw %d1,%fp@(-38)
    movew %fp@(-424),%d0
    moveal %fp@(0x10,%d0:w),%a1
    jbra DRTEXT_6D6
DRTEXT_6AA:             /* a missing character: the missing-symbol glyph */
    movew %fp@(-406),%d0
    addqw #1,%d0
    moveal %fp@(-132),%a0
    movew %a0@(0x0,%d0:w:2),%d3
    cmpiw #-1,%d3
    bnew DRTEXT_70A
    jbra DRTEXT_6D6
DRTEXT_6C2:             /* a space: just advance */
    movel %fp@(-120),%d1
    addl %d1,%fp@(-124)
DRTEXT_6CA:             /* next character; done? */
    subqw #1,%fp@(-214)
    subqw #1,%fp@(-426)
    jble DRTEXT_9F6
DRTEXT_6D6:             /* next character: its width (fixed point) plus the extra */
    clrw %d0
    moveb %a1@+,%d0
    cmpib #32,%d0
    jbeq DRTEXT_6C2
    moveal WidthTabHandle,%a0
    moveal %a0@,%a0
    movew %d0,%d4
    movel %a0@(0x0,%d4:w:4),%d4
    addl %fp@(-144),%d4
    jble DRTEXT_6CA
    subw %fp@(-408),%d0
    cmpw %fp@(-406),%d0
    jbhi DRTEXT_6AA
    moveal %fp@(-132),%a0
    movew %a0@(0x0,%d0:w:2),%d3
    cmpiw #-1,%d3
    jbeq DRTEXT_6AA
DRTEXT_70A:             /* its image offset and width in the strike; empty: skip */
    lsrw #8,%d3
    addw %fp@(-124),%d3
    addl %d4,%fp@(-124)
    moveal %fp@(-136),%a0
    moveq #0,%d1
    movew %a0@(0x0,%d0:w:2),%d1
    movew %a0@(0x2,%d0:w:2),%d2
    subw %d1,%d2
    jble DRTEXT_6CA
    movew %d2,%fp@(-422)
    addw %d3,%d2
    tstb %fp@(-402)
    jbeq DRTEXT_73C
    moveal %fp@(-128),%a0
    movew %a0@(0x0,%d0:w:2),%fp@(-404)
DRTEXT_73C:             /* clip the glyph to the visible columns */
    tstb %fp@(-399)
    jbeq DRTEXT_77C
    cmpw %fp@(-42),%d3
    jbge DRTEXT_762
    cmpw %fp@(-42),%d2
    jble DRTEXT_6CA
    movew %fp@(-42),%d0
    subw %d3,%d0
    addw %d0,%d1
    addw %d0,%d3
    cmpw %fp@(-38),%d2
    jble DRTEXT_774
    jbra DRTEXT_770
DRTEXT_762:             /* right clip */
    cmpw %fp@(-38),%d2
    jble DRTEXT_77C
    cmpw %fp@(-38),%d3
    jbge DRTEXT_9F6
DRTEXT_770:             /* clipped */
    movew %fp@(-38),%d2
DRTEXT_774:             /* width drawn */
    movew %d2,%d0
    subw %d3,%d0
    movew %d0,%fp@(-422)
DRTEXT_77C:             /* blit the glyph: positions by the pixel size */
    movemw %d1-%d3,%fp@(-182)
    moveb %fp@(-435),%fp@(-433)
    st %fp@(-434)
    movew %fp@(-432),%d0
    lslw %d0,%d1
    lslw %d0,%d2
    lslw %d0,%d3
    moveaw %fp@(-52),%a3
    moveml %fp@(-84),%a2/%a4-%a5
DRTEXT_7A0:             /* each row of the glyph (vertical clip) */
    movew #255,%d7
    addb %fp@(-403),%d7
    jbmi DRTEXT_6CA
    moveq #0,%d0
    moveb %fp@(-404),%d0
    movel %a2,%d4
    .short  0x4C00, 0x4004	| 40828904 mulul %d0,%d4
    addal %d4,%a4
    movew %a3,%d4
    muluw %d0,%d4
    addal %d4,%a5
    moveq #31,%d0
    movel %d1,%d5
    movew %d3,%d6
    asrw #5,%d6
    movew %d6,%d4
    lslw #2,%d6
    addaw %d6,%a5
    movew %d2,%d6
    asrw #5,%d6
    subw %d4,%d6
    jbeq DRTEXT_934
    negw %d3
    andw %d0,%d3
    jbne DRTEXT_7E0
    moveq #32,%d3
DRTEXT_7E0:             /* wide glyph: by longs */
    movew %d6,%d4
    lslw #2,%d4
    subaw %d4,%a2
    subaw %d4,%a3
    subqw #1,%d6
    addw %d3,%d1
    moveq #32,%d4
    subl %d4,%d1
    tstb %fp@(-433)
    jbne DRTEXT_834
    andw %d0,%d2
    moveq #1,%d4
    rorl #1,%d4
    asrl %d2,%d4
    asll #1,%d4
    movew %d6,%d2
    moveaw %d6,%a0
    movel %d5,%d6
    addw %d3,%d6
    moveq #32,%d0
    subl %d0,%d6
DRTEXT_80C:             /* first long */
    bfextu %a4@,%d5,%d3,%d0
    jbra DRTEXT_816
DRTEXT_812:             /* middle longs */
    bfextu %a4@,%d6,0,%d0
DRTEXT_816:             /* or into the buffer */
    orl %d0,%a5@+
    addqw #4,%a4
    dbf %d2,DRTEXT_812
    bfextu %a4@,%d1,0,%d0
    andl %d4,%d0
    orl %d0,%a5@
    addal %a2,%a4
    addal %a3,%a5
    movew %a0,%d2
    dbf %d7,DRTEXT_80C
    jbra DRTEXT_9EA
DRTEXT_834:             /* color text: colorize pixels that are not the background */
    movew %d2,%d4
    andw %d0,%d4
    movew %d6,%fp@(-420)
    movew %d6,%d2
    movel %fp@(-152),%d6
    bfextu %d6,0,%d3,%d0
    movel %d0,%fp@(-156)
    bfextu %d6,0,%d4,%d0
    movel %d0,%fp@(-160)
    movew %fp@(-410),%d0
    bfextu %d6,0,%d0,%d0
    movew %d0,%fp@(-412)
    moveq #32,%d6
    subw %d3,%d6
    moveal %d5,%a0
    addaw %d3,%a0
    subaw #32,%a0
DRTEXT_86A:             /* per long: background pixels replaced by the glyph's */
    bfextu %a5@,%d6,%d3,%d0
    cmpl %fp@(-156),%d0
    jbne DRTEXT_8BE
    bfextu %a4@,%d5,%d3,%d0
    bfins %d0,%a5@,%d6,%d3
DRTEXT_87C:             /* swap */
    exg %d5,%a0
DRTEXT_87E:             /* next long */
    addqw #4,%a5
    jbra DRTEXT_890
DRTEXT_882:             /* whole long of background: copy the glyph long */
    movel %fp@(-152),%d0
    cmpl %a5@,%d0
    jbne DRTEXT_8E2
    bfextu %a4@,%d5,0,%d0
    movel %d0,%a5@+
DRTEXT_890:             /* next; the last part */
    addqw #4,%a4
    dbf %d2,DRTEXT_882
    exg %d5,%a0
    tstw %d4
    jbeq DRTEXT_8AE
    bfextu %a5@,0,%d4,%d0
    cmpl %fp@(-160),%d0
    jbne DRTEXT_90C
    bfextu %a4@,%d1,%d4,%d0
    bfins %d0,%a5@,0,%d4
DRTEXT_8AE:             /* next row */
    addal %a2,%a4
    addal %a3,%a5
    movew %fp@(-420),%d2
    dbf %d7,DRTEXT_86A
    jbra DRTEXT_9C6
DRTEXT_8BE:             /* save registers */
    moveml %d1/%d3-%d6,%sp@-
    movemw %fp@(-412),%d0-%d1
DRTEXT_8C8:             /* pixel by pixel: skip background pixels */
    bfextu %a4@,%d5,%d1,%d4
    cmpw %d4,%d0
    jbeq DRTEXT_8D4
    bfins %d4,%a5@,%d6,%d1
DRTEXT_8D4:             /* next pixel */
    addl %d1,%d5
    addw %d1,%d6
    subw %d1,%d3
    jbgt DRTEXT_8C8
    moveml %sp@+,%d1/%d3-%d6
    jbra DRTEXT_87C
DRTEXT_8E2:             /* a whole long pixel by pixel */
    moveq #32,%d0
    moveml %d1/%d3-%d6,%sp@-
    moveq #0,%d6
    movemw %fp@(-412),%d1/%d3
DRTEXT_8F0:             /* skip background pixels */
    bfextu %a4@,%d5,%d3,%d4
    cmpw %d4,%d1
    jbeq DRTEXT_8FC
    bfins %d4,%a5@,%d6,%d3
DRTEXT_8FC:             /* next pixel */
    addl %d3,%d5
    addw %d3,%d6
    subw %d3,%d0
    jbgt DRTEXT_8F0
    moveml %sp@+,%d1/%d3-%d6
    jbra DRTEXT_87E
DRTEXT_90C:             /* the last part pixel by pixel */
    moveml %d1/%d3-%d6,%sp@-
    moveq #0,%d6
    movemw %fp@(-412),%d3/%d5
DRTEXT_918:             /* skip background pixels */
    bfextu %a4@,%d1,%d5,%d0
    cmpw %d0,%d3
    jbeq DRTEXT_924
    bfins %d0,%a5@,%d6,%d5
DRTEXT_924:             /* next pixel */
    addl %d5,%d1
    addw %d5,%d6
    subw %d5,%d4
    jbgt DRTEXT_918
    moveml %sp@+,%d1/%d3-%d6
    jbra DRTEXT_8AE
DRTEXT_934:             /* narrow glyph (one long) */
    movew %fp@(-422),%d3
    tstb %fp@(-434)
    jbeq DRTEXT_944
    movew %fp@(-432),%d4
    lslw %d4,%d3
DRTEXT_944:             /* 1-bit: or the bits */
    tstb %fp@(-433)
    jbne DRTEXT_96E
    movew %d2,%d1
    negw %d1
    andw %d0,%d1
    addw %d1,%d3
    andw %d0,%d2
    moveq #1,%d4
    rorl #1,%d4
    asrl %d2,%d4
    asll #1,%d4
DRTEXT_95C:             /* each row */
    bfextu %a4@,%d5,%d3,%d0
    andl %d4,%d0
    orl %d0,%a5@
    addal %a2,%a4
    addal %a3,%a5
    dbf %d7,DRTEXT_95C
    jbra DRTEXT_9EA
DRTEXT_96E:             /* color: pixel by pixel */
    movew %d2,%d6
    andl %d0,%d6
    subw %d3,%d6
    bfextu %fp@(-152),0,%d3,%d2
    moveml %d5-%d6,%fp@(-172)
    movew %d5,%d0
    addw %d3,%d0
    movew %d0,%fp@(-420)
    movew %fp@(-410),%d4
    bfextu %d2,0,%d4,%d1
DRTEXT_990:             /* each row: all background? copy */
    bfextu %a5@,%d6,%d3,%d0
    cmpl %d2,%d0
    jbeq DRTEXT_9B6
DRTEXT_998:             /* skip background pixels */
    bfextu %a4@,%d5,%d4,%d0
    cmpw %d0,%d1
    jbeq DRTEXT_9A4
    bfins %d0,%a5@,%d6,%d4
DRTEXT_9A4:             /* next pixel */
    addw %d4,%d6
    addw %d4,%d5
    cmpw %fp@(-420),%d5
    jblt DRTEXT_998
    moveml %fp@(-172),%d5-%d6
    jbra DRTEXT_9BE
DRTEXT_9B6:             /* copy */
    bfextu %a4@,%d5,%d3,%d0
    bfins %d0,%a5@,%d6,%d3
DRTEXT_9BE:             /* next row */
    addal %a2,%a4
    addal %a3,%a5
    dbf %d7,DRTEXT_990
DRTEXT_9C6:             /* a mask too: draw the glyph again into the mask buffer */
    tstw %fp@(-432)
    jbeq DRTEXT_9EA
    tstb %fp@(-400)
    jbeq DRTEXT_9EA
    sf %fp@(-433)
    sf %fp@(-434)
    movemw %fp@(-182),%d1-%d3/%a3
    moveml %fp@(-96),%a2/%a4-%a5
    jbra DRTEXT_7A0
DRTEXT_9EA:             /* next character */
    subqw #1,%fp@(-214)
    subqw #1,%fp@(-426)
    jbgt DRTEXT_6D6
DRTEXT_9F6:             /* fast path done: restore the addressing mode, show the cursor */
    moveal %fp@(-140),%a5
    tstb %fp@(-399)
    jbeq DRTEXT_A1A
    tstb %fp@(-427)
    jbeq DRTEXT_A16
    moveb %fp@(-428),%d0
    jsr @(0x574,%za0)@(0x0)	| 40828B5A
    jsr @(0xf4c,%za0)@(0)
DRTEXT_A16:             /* done */
    jbra DRTEXT_CBE
DRTEXT_A1A:             /* styles on the buffer: bold (smear right by the bold amount) */
    moveal %a5@,%a0
    moveal %a0@,%a3
    moveal %a0@(-176),%a4
    moveal %a4@(2),%a2
    moveal %a2@,%a2
    movew %fp@(-124),%d7
    subw %a2@(8),%d7
    clrw %d2
    moveb %a4@(6),%d2
    jbra DRTEXT_A4C
DRTEXT_A38:             /* one pass */
    moveal %fp@(-76),%a0
    movew %fp@(-50),%d1
    subw %d0,%d0
DRTEXT_A42:             /* shift and or */
    movel %a0@,%d0
    roxrl #1,%d0
    orl %d0,%a0@+
    dbf %d1,DRTEXT_A42
DRTEXT_A4C:             /* next pass; italic: shear the rows */
    dbf %d2,DRTEXT_A38
    moveq #0,%d2
    moveb %a4@(7),%d2
    jbeq DRTEXT_A8C
    moveal %fp@(-48),%a1
    movew %fp@(-52),%d3
    subaw %d3,%a1
    lsrw #2,%d3
    subqw #1,%d3
    movew %fp@(-64),%d6
    moveq #0,%d4
    jbra DRTEXT_A88
DRTEXT_A6E:             /* each row up: shift it right by the slope */
    addl %d2,%d4
    movel %d4,%d5
    lsrl #4,%d5
    negl %d5
    moveal %a1,%a0
    subqw #4,%a0
    movew %d3,%d1
DRTEXT_A7C:             /* shift */
    bfextu %a0@,%d5,0,%d0
    subqw #4,%a0
    movel %d0,%a1@-
    dbf %d1,DRTEXT_A7C
DRTEXT_A88:             /* next row */
    dbf %d6,DRTEXT_A6E
DRTEXT_A8C:             /* underline: a line at the baseline, broken around descenders */
    tstb %a4@(10)
    jbeq DRTEXT_AEC
    moveal %fp@(-76),%a0
    movew %fp@(-52),%d1
    movew %a2@(18),%d0
    movew %a2@(20),%d2
    muluw %d1,%d0
    addal %d0,%a0
    moveal %a0,%a1
    moveal %a0,%a2
    addaw %d1,%a1
    cmpiw #2,%d2
    jblt DRTEXT_AEC
    jbeq DRTEXT_AB8
    addaw %d1,%a2
    addaw %d1,%a2
DRTEXT_AB8:             /* a temporary row */
    subaw %d1,%sp
    movel %a3,%sp@-
    lea %sp@(4),%a3
    lsrw #2,%d1
    subqw #1,%d1
    movew %d1,%d2
    subw %d0,%d0
DRTEXT_AC8:             /* the descender pixels below the baseline, widened */
    movel %a0@+,%d0
    orl %a1@+,%d0
    orl %a2@+,%d0
    movel %d0,%a3@
    roxrl #1,%d0
    orl %d0,%a3@+
    dbf %d1,DRTEXT_AC8
    moveal %a1,%a0
    subw %d0,%d0
DRTEXT_ADC:             /* the underline where there are none */
    movel %a3@-,%d0
    roxll #1,%d0
    orl %a3@,%d0
    notl %d0
    orl %d0,%a1@-
    dbf %d2,DRTEXT_ADC
    moveal %sp@+,%a3
DRTEXT_AEC:             /* the buffer as a bitmap; outline/shadow? */
    movew #10,%fp@(-192)
    movel %fp@(-392),%fp@(-190)
    movel %fp@(-388),%fp@(-186)
    lea %fp@(-192),%a0
    movel %a0,%fp@(-196)
    lea %fp@(-228),%a0
    moveal %a0,%a1
    movel %fp@(-76),%a0@+
    movew %fp@(-52),%a0@+
    movew %fp@(-12),%a0@+
    movew %fp@(-62),%a0@+
    movel %fp@(-8),%a0@+
    lea %fp@(-306),%a2
    jsr @(0x1a08,%za0)@(0)	| 40828C74
    tstb %fp@(-400)
    jbeq DRTEXT_B48
    lea %fp@(-320),%a0
    movel %fp@(-88),%a0@+
    movew %fp@(-176),%a0@+
    movew %fp@(-12),%a0@+
    movew %fp@(-62),%a0@+
    movel %fp@(-8),%a0@+
DRTEXT_B48:             /* deep buffer: its pixel size and table */
    tstw %fp@(-432)
    jbeq DRTEXT_B5A
    movew %fp@(-410),%fp@(-274)
    movel %fp@(-356),%fp@(-264)
DRTEXT_B5A:             /* outline/shadow: a widened copy */
    clrw %d3
    moveb %a4@(11),%d3
    jbeq DRTEXT_C8A
    movew %fp@(-52),%d0
    subqw #1,%d0
    clrl %sp@-
    movel %sp,%fp@(-60)
DRTEXT_B70:             /* work buffer */
    clrl %sp@-
    dbf %d0,DRTEXT_B70
    movew %fp@(-50),%d0
    subqw #1,%d0
    moveal %fp@(-48),%a0
DRTEXT_B80:             /* copy the text */
    movel %a0@-,%sp@-
    dbf %d0,DRTEXT_B80
    movel %sp,%fp@(-56)
    clrl %sp@-
    andiw #3,%d3
    movew %d3,%d2
DRTEXT_B92:             /* smear by the shadow amount */
    moveal %fp@(-56),%a0
    movew %fp@(-50),%d1
    subw %d0,%d0
DRTEXT_B9C:             /* shift and or */
    movel %a0@,%d0
    roxrl #1,%d0
    orl %d0,%a0@+
    dbf %d1,DRTEXT_B9C
    dbf %d2,DRTEXT_B92
    moveal %fp@(-56),%a2
DRTEXT_BAE:             /* and down */
    moveal %fp@(-60),%a1
    moveal %a1,%a0
    movew %fp@(-224),%d2
    subaw %d2,%a0
DRTEXT_BBA:             /* or */
    movel %a0@-,%d0
    orl %d0,%a1@-
    cmpal %a2,%a0
    jbgt DRTEXT_BBA
    dbf %d3,DRTEXT_BAE
    movew %fp@(-50),%d1
    moveal %fp@(-76),%a0
    moveal %a2,%a1
    addaw %d2,%a1
    subw %d0,%d0
DRTEXT_BD4:             /* the outline: the smeared image xor the text */
    movel %a0@+,%d0
    roxrl #1,%d0
    eorl %d0,%a1@+
    dbf %d1,DRTEXT_BD4
    movel %a2,%fp@(-228)
    addqw #4,%fp@(-218)
    movel %fp@(-12),%fp@(-28)
    movel %fp@(-8),%fp@(-24)
    addqw #4,%fp@(-24)
    movel %fp@(-28),%fp@(-36)
    movel %fp@(-24),%fp@(-32)
    lea %fp@(-36),%a0
    subqw #1,%a0@+
    subqw #1,%a0@+
    subqw #1,%a0@+
    subqw #1,%a0@+
    tstb %fp@(-401)
    jbeq DRTEXT_C26
    pea %fp@(-36)
    pea %fp@(-104)
    pea %fp@(-112)
    jsr @(0x11e8,%za0)@(0)	| 40828D70
DRTEXT_C26:             /* StretchBits the outline (mode with the mask) */
    pea %fp@(-228)
    movel %fp@(-148),%sp@-
    jbeq DRTEXT_C34
    movel %sp@(4),%sp@
DRTEXT_C34:             /* draw it */
    pea %a3@(2)
    pea %fp@(-28)
    pea %fp@(-28)
    pea %fp@(-36)
    movew %fp@(-430),%sp@-
    clrl %sp@-
    movel %a3@(28),%sp@-
    movel %a3@(24),%sp@-
    pea %fp@(-196)
    clrw %sp@-
    jsr @(0x1a9c,%za0)@(0)	| 40828DA8
    tstw %a3@(6)
    jbmi DRTEXT_CBE
    movew %fp@(-430),%d0
    cmpiw #1,%d0
    jbeq DRTEXT_C74
    cmpiw #3,%d0
    jbne DRTEXT_CBE
DRTEXT_C74:             /* then the text itself in the inverted mode */
    movel %fp@(-76),%fp@(-228)
    subqw #4,%fp@(-218)
    clrl %fp@(-148)
    eoriw #2,%d0
    movew %d0,%fp@(-430)
DRTEXT_C8A:             /* StretchBits the buffer to the port (through the clip and visRgn) */
    pea %fp@(-306)
    movel %fp@(-148),%sp@-
    pea %a3@(2)
    pea %fp@(-12)
    pea %fp@(-12)
    pea %fp@(-20)
    movew %fp@(-430),%sp@-
    clrl %sp@-
    movel %a3@(28),%sp@-
    movel %a3@(24),%sp@-
    pea %fp@(-196)
    moveb %fp@(-437),%sp@-
    jsr @(0x1a9c,%za0)@(0)	| 40828E08
DRTEXT_CBE:             /* more of the string after a split? else hilite off, return */
    moveal %fp@(-4),%sp
    movew %fp@(-214),%d0
    subw %fp@(-426),%d0
    movew %d0,%fp@(-214)
    jbgt DRTEXT_572
    bset #7,HiliteMode
    tstw %fp@(-424)
    moveml %sp@+,%d0-%d7/%a1-%a4
    unlk %fp
    jbeq DRTEXT_CE6
    addqw #2,%sp
DRTEXT_CE6:             /* return */
    rtd #14
    .short  0x0000, 0x0000, 0x0000	| 40828E3A

/* STDTEXT: StdText: the text bottleneck. */
trap_StdText:
STDTEXT:
    linkw %fp,#-4
    moveml %d5-%d7/%a3-%a4,%sp@-
STDTEXT_8:              /* at most 255 characters at a time */
    movew %fp@(20),%d6
    jble STDTEXT_248
    cmpiw #255,%d6
    jble STDTEXT_1A
    movew #255,%d6
STDTEXT_1A:             /* recording a picture: the text state that changed */
    jsr @(0x1a3c,%za0)@(0)	| 40828E5A
    sle %sp@-
    jble STDTEXT_216
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movew %a3@(68),%d7
    cmpw %a4@(24),%d7
    jbeq STDTEXT_50
    moveq #3,%d0
    jbsr trap_DPUTPICOP
    movew %d7,%sp@-
    jbsr PUTPICWORD
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movew %d7,%a4@(24)
STDTEXT_50:             /* face: TxFace (4) */
    moveb %a3@(70),%d7
    cmpb %a4@(26),%d7
    jbeq STDTEXT_74
    moveq #4,%d0
    jbsr trap_DPUTPICOP
    moveb %d7,%d0
    jbsr trap_DPUTPICBYTE
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    moveb %d7,%a4@(26)
STDTEXT_74:             /* mode: TxMode (5); version 1 gets boolean modes */
    movew %a3@(72),%d7
    cmpw %a4@(28),%d7
    jbeq STDTEXT_BE
    cmpiw #1,%a4@(98)
    jbne STDTEXT_9A
    btst #5,%d7
    jbeq STDTEXT_9A
    andiw #7,%d7
    moveb %pc@(STDTEXT_B6,%d7:w),%d7
    cmpw %a4@(28),%d7
    jbeq STDTEXT_BE
STDTEXT_9A:             /* write TxMode */
    moveq #5,%d0
    jbsr trap_DPUTPICOP
    movew %d7,%sp@-
    jbsr PUTPICWORD
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movew %d7,%a4@(28)
    jbra STDTEXT_BE
STDTEXT_B6:             /* arithmetic to boolean map (data) */
    .short  0x0003, 0x0201, 0x0103, 0x0201	| 40828EF6
STDTEXT_BE:             /* size: TxSize (13) */
    movew %a3@(74),%d7
    cmpw %a4@(30),%d7
    jbeq STDTEXT_E2
    moveq #13,%d0
    jbsr trap_DPUTPICOP
    movew %d7,%sp@-
    jbsr PUTPICWORD
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movew %d7,%a4@(30)
STDTEXT_E2:             /* space extra: SpExtra (6) */
    movel %a3@(76),%d7
    cmpl %a4@(32),%d7
    jbeq STDTEXT_106
    moveq #6,%d0
    jbsr trap_DPUTPICOP
    movel %d7,%sp@-
    jbsr PUTPICLONG
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %d7,%a4@(32)
STDTEXT_106:            /* numer/denom: TxRatio (16) */
    movel %fp@(12),%d7
    movel %fp@(8),%d5
    cmpl %a4@(36),%d7
    jbne STDTEXT_11A
    cmpl %a4@(40),%d5
    jbeq STDTEXT_140
STDTEXT_11A:            /* write TxRatio */
    moveq #16,%d0
    jbsr trap_DPUTPICOP
    movel %d7,%sp@-
    jbsr PUTPICLONG
    movel %d5,%sp@-
    jbsr PUTPICLONG
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %d7,%a4@(36)
    movel %d5,%a4@(40)
STDTEXT_140:            /* version 2: fractional pen: PnLocHFrac (21) */
    cmpiw #1,%a4@(98)
    jbeq STDTEXT_18C
    movew %a3@(14),%d7
    cmpiw #-32768,%d7
    jbeq STDTEXT_168
    moveq #21,%d0
    jbsr trap_DPUTPICOP
    movew %d7,%sp@-
    jbsr PUTPICWORD
    moveal %a3@(92),%a4
    moveal %a4@,%a4
STDTEXT_168:            /* character extra: ChExtra (22) */
    movew %a3@(12),%d7
    cmpw %a4@(112),%d7
    jbeq STDTEXT_18C
    moveq #22,%d0
    jbsr trap_DPUTPICOP
    movew %d7,%sp@-
    jbsr PUTPICWORD
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movew %d7,%a4@(112)
STDTEXT_18C:            /* the text opcode: LongText (40) or the relative forms DHText (41), DVText (42), DHDVText (43) */
    movel %a3@(48),%d5
    subw %a4@(46),%d5
    swap %d5
    subw %a4@(44),%d5
    swap %d5
    movel %d5,%d0
    andil #-16711936,%d0
    jbeq STDTEXT_1BA
    moveq #40,%d0
    jbsr trap_DPUTPICOP
    movel %a3@(48),%sp@-
    jbsr PUTPICLONG
    jbra STDTEXT_1F6
STDTEXT_1BA:            /* only h moved */
    movel %d5,%d0
    andil #16711680,%d0
    jbne STDTEXT_1CE
    moveq #41,%d0
    jbsr trap_DPUTPICOP
    jbra STDTEXT_1EE
STDTEXT_1CE:            /* only v moved */
    tstb %d5
    jbne STDTEXT_1DC
    moveq #42,%d0
    jbsr trap_DPUTPICOP
    jbra STDTEXT_1EC
STDTEXT_1DC:            /* both */
    moveq #43,%d0
    jbsr trap_DPUTPICOP
    moveb %d5,%d0
    jbsr trap_DPUTPICBYTE
STDTEXT_1EC:            /* dh */
    swap %d5
STDTEXT_1EE:            /* the offset */
    moveb %d5,%d0
    jbsr trap_DPUTPICBYTE
STDTEXT_1F6:            /* count and characters */
    moveb %d6,%d0
    jbsr trap_DPUTPICBYTE
    movel %fp@(16),%sp@-
    movew %d6,%sp@-
    jbsr PUTPICDATA
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %a3@(48),%a4@(44)
STDTEXT_216:            /* draw on each screen (DRTEXT) */
    pea %pc@(STDTEXT_2B4)
    pea %pc@(STDTEXT_258)
    jsr @(0x1aa0,%za0)@(0)	| 4082905E
    tstb %sp@+
    jbne STDTEXT_234
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movew %a3@(14),%a4@(114)
STDTEXT_234:            /* next 255 characters */
    subw %d6,%fp@(20)
    jble STDTEXT_248
    moveal %fp@(16),%a0
    addaw %d6,%a0
    movel %a0,%fp@(16)
    jbra STDTEXT_8
STDTEXT_248:            /* hilite off, return */
    bset #7,HiliteMode
    moveml %sp@+,%d5-%d7/%a3-%a4
    unlk %fp
    rtd #14
STDTEXT_258:            /* rectangle proc: the text bounding box, measured on the device of the last text drawn (LastTxGDevice) */
    movel %sp@+,%d0
    moveal %sp@+,%a1
    movel %d0,%sp@-
    movel TheGDevice,%sp@-
    movel LastTxGDevice,TheGDevice
    movel %a3@(48),%d0
    movel %d0,%a1@
    movel %d0,%a1@(4)
    movel %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    subqw #8,%sp
    moveal %sp,%a0
    movel %a1,%sp@-
    clrw %sp@-
    movew %d6,%sp@-
    movel %fp@(16),%sp@-
    pea %a0@(12)
    pea %a0@(8)
    movel %a0,%sp@-
    jsr @(0x11b4,%za0)@(0)	| 408290D2
    movew %sp@+,%d0
    moveal %sp@+,%a1
    addw %d0,%a1@(6)
    movew %sp@+,%d0
    subw %d0,%a1@
    movew %sp@+,%d0
    addw %d0,%a1@(4)
    lea %sp@(12),%sp
    movel %sp@+,TheGDevice
    rts
STDTEXT_2B4:            /* draw proc: DRTEXT */
    movew %d6,%sp@-
    movel %fp@(16),%sp@-
    movel %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(DRTEXT)
    rts
    .long   0x00000000, 0x00000000	| 40829108

/* CALLTEXT: call the port's text bottleneck (grafProcs) or the standard one. */
CALLTEXT:
    moveal %sp@+,%a0
    movel #65537,%sp@-
    movel %sp@,%sp@-
    movel %a0,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x1008,%a0
    jbeq CALLTEXT_1E
    moveal %d0,%a0
    moveal %a0@,%a0
CALLTEXT_1E:            /* through the port's textProc or StdText */
    jmp %a0@

/* TEXTFACE: _TextFace. */
trap_TextFace:
TEXTFACE:
    moveal %a5@,%a0
    moveal %a0@,%a0
    moveb %sp@(5),%a0@(70)
    jbra CHARWIDTH_14

/* DRAWCHAR: _DrawChar. */
trap_DrawChar:
DRAWCHAR:
    movew #1,%sp@-
    pea %sp@(7)
    jsr %pc@(CALLTEXT)
    jbra CHARWIDTH_14

/* CHARWIDTH: _CharWidth. */
trap_CharWidth:
CHARWIDTH:
    clrw %sp@-
    movel %sp,%sp@-
    movel #65543,%sp@-
    jsr @(0x1018,%za0)@(0x0)	| 40829154
    movew %sp@+,%sp@(6)
CHARWIDTH_14:           /* pop, return */
    moveal %sp@+,%a0
    addqw #2,%sp
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 40829164

/* TEXTFONT: _TextFont. */
trap_TextFont:
TEXTFONT:
    moveq #68,%d0
    jbra TEXTSIZE_10

/* TEXTMODE: _TextMode. */
trap_TextMode:
TEXTMODE:
    moveq #72,%d0
    jbra TEXTSIZE_10

/* TEXTSIZE: _TextSize. */
trap_TextSize:
TEXTSIZE:
    moveal %a5@(0,%za0)@(0),%a0	| 40829178
    tstw %a0@(6)
    jbpl TEXTSIZE_E
    clrw %a0@(12)
TEXTSIZE_E:             /* txSize field */
    moveq #74,%d0
TEXTSIZE_10:            /* store it */
    jmp %pc@(PORTWORD)
    .long   0x00000000	| 4082918C

/* SPACEEXTRA: _SpaceExtra. */
trap_SpaceExtra:
SPACEEXTRA:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %sp@(4),%a0@(76)
    jbra DRAWTEXT_14

/* DRAWSTRING: _DrawString. */
trap_DrawString:
DRAWSTRING:
    moveal %sp@(4),%a0
    clrw %d0
    moveb %a0@+,%d0
    movew %d0,%sp@-
    movel %a0,%sp@-
    jsr %pc@(CALLTEXT)
    jbra DRAWTEXT_14

/* DRAWTEXT: _DrawText. */
trap_DrawText:
DRAWTEXT:
    moveal %sp@(8),%a0
    addaw %sp@(6),%a0
    movew %sp@(4),%sp@-
    movel %a0,%sp@-
    jsr %pc@(CALLTEXT)
    movel %sp@+,%sp@
DRAWTEXT_14:            /* return */
    movel %sp@+,%sp@
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408291C6

/* STRINGWIDTH: _StringWidth. */
trap_StringWidth:
STRINGWIDTH:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    clrw %d0
    moveb %a0@+,%d0
    movel %a0,%sp@-
    clrw %sp@-
    movew %d0,%sp@-
    movel %a1,%sp@-

/* TEXTWIDTH: _TextWidth. */
trap_TextWidth:
TEXTWIDTH:
    linkw %fp,#-16
    clrw %fp@(16)
    clrw %sp@-
    movew %fp@(8),%sp@-
    jble TEXTWIDTH_60
    moveal %fp@(12),%a0
    addaw %fp@(10),%a0
    movel %a0,%sp@-
    movel #65537,%d0
    movel %d0,%fp@(-12)
    movel %d0,%fp@(-16)
    pea %fp@(-12)
    pea %fp@(-16)
    pea %fp@(-8)
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x11b4,%a0
    jbeq TEXTWIDTH_48
    moveal %d0,%a0
    moveal %a0@(40),%a0
TEXTWIDTH_48:           /* measure (txMeasProc); scale by numer/denom */
    jsr %a0@
    movew %sp@+,%d1
    movew %fp@(-10),%d0
    movew %fp@(-14),%d2
    cmpw %d2,%d0
    jbeq TEXTWIDTH_5C
    muluw %d0,%d1
    divuw %d2,%d1
TEXTWIDTH_5C:           /* the width */
    movew %d1,%fp@(16)
TEXTWIDTH_60:           /* return */
    unlk %fp
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40829246

/* STDTXMEAS: StdTxMeas: the text measuring bottleneck. */
trap_StdTxMeas:
STDTXMEAS:
    linkw %fp,#-20
    movel %a4,%sp@-
    moveal %a5@,%a4
    clrl %fp@(-20)
    moveal %a4@,%a0
    lea %fp@(-16),%a1
    movew %a0@(68),%a1@+
    movew %a0@(74),%a1@+
    moveb %a0@(70),%a1@+
    st %a1@+
    movew %a0@,%a1@+
    moveal %fp@(16),%a0
    movel %a0@,%a1@+
    moveal %fp@(12),%a0
    movel %a0@,%a1@+
    clrl %sp@-
    pea %fp@(-16)
    moveal JSwapFont,%a0
    jsr %a0@
    moveal %sp@+,%a1
    movel %a1,%a4@(-176)
    moveal %a4@,%a0
    tstw %a0@(6)
    jbpl STDTXMEAS_56
    movew %a0@(12),%d0
    jbeq STDTXMEAS_56
    jbsr CALCCHAREXTRA
    movel %d0,%fp@(-20)
STDTXMEAS_56:           /* the font info from FMSwapFont's output */
    moveal %fp@(8),%a0
    clrl %a0@
    clrl %a0@(4)
    moveb %a1@(13),%a0@(1)
    moveb %a1@(14),%a0@(3)
    moveb %a1@(15),%a0@(5)
    moveb %a1@(16),%d0
    extw %d0
    movew %d0,%a0@(6)
    moveal %fp@(16),%a0
    movel %a1@(18),%a0@
    moveal %fp@(12),%a0
    movel %a1@(22),%a0@
    moveal %fp@(20),%a0
    moveal WidthTabHandle,%a1
    moveal %a1@,%a1
    moveq #0,%d1
    movew %fp@(24),%d2
    jbra STDTXMEAS_B2
STDTXMEAS_9E:           /* add the widths */
    clrw %d0
    moveb %a0@+,%d0
    lslw #2,%d0
    addl %a1@(0x0,%d0:w),%d1
    cmpiw #128,%d0
    jbeq STDTXMEAS_B2
    addl %fp@(-20),%d1
STDTXMEAS_B2:           /* next; the fixed-point total, integer result */
    dbf %d2,STDTXMEAS_9E
    movel %d1,%a4@(-172)
    swap %d1
    movew %d1,%fp@(26)
    moveal %sp@+,%a4
    unlk %fp
    rtd #18
    .long   0x00000000, 0x00000000	| 40829318

/* MEASURETEXT: _MeasureText. */
trap_MeasureText:
MEASURETEXT:
    linkw %fp,#-20
    moveml %d3-%d6/%a2-%a4,%sp@-
    moveal %fp@(12),%a2
    moveal %fp@(8),%a3
    movew %fp@(16),%d3
    moveq #0,%d4
    moveal %a5@,%a4
    moveal %a4@,%a0
    clrl %fp@(-20)
    movel %a0@(104),%d0
    jbeq MEASURETEXT_5C
    moveal %d0,%a1
    movel %a1@(40),%d0
    cmpl 0x11b4,%d0
    jbeq MEASURETEXT_5C
    moveq #0,%d6
    moveq #0,%d5
    subqw #2,%sp
MEASURETEXT_36:         /* through the port's measure proc: the width of each prefix */
    movel %a2,%sp@-
    clrw %sp@-
    movew %d4,%sp@-
    jsr @(0x1018,%za0)@(0x0)	| 4082935C
    movew %sp@,%d0
    cmpw %d6,%d0
    jbge MEASURETEXT_4A
    addw %d6,%d5
MEASURETEXT_4A:         /* store */
    addw %d5,%d0
    movew %d0,%a3@+
    movew %sp@,%d6
    addqw #1,%d4
    cmpw %d3,%d4
    jble MEASURETEXT_36
    addqw #2,%sp
    jbra MEASURETEXT_F2
MEASURETEXT_5C:         /* StdTxMeas: swap in the font */
    lea %fp@(-16),%a1
    movew %a0@(68),%a1@+
    movew %a0@(74),%a1@+
    moveb %a0@(70),%a1@+
    st %a1@+
    movew %a0@,%a1@+
    movel #65537,%a1@+
    movel #65537,%a1@+
    clrl %sp@-
    pea %fp@(-16)
    jsr @(0x1204,%za0)@(0x0)	| 408293A2
    moveal %sp@+,%a0
    movew %a0@(20),%d3
    movew %a0@(24),%d4
    moveal %a4@,%a0
    tstw %a0@(6)
    jbpl MEASURETEXT_A8
    movew %a0@(12),%d0
    jbeq MEASURETEXT_A8
    jbsr CALCCHAREXTRA
    movel %d0,%fp@(-20)
MEASURETEXT_A8:         /* from the width table */
    moveal %fp@(12),%a0
    moveal WidthTabHandle,%a1
    moveal %a1@,%a1
    moveal %fp@(8),%a2
    moveq #0,%d1
    movew %fp@(16),%d2
MEASURETEXT_BC:         /* each prefix width */
    swap %d1
    movew %d1,%a2@+
    swap %d1
    clrw %d0
    moveb %a0@+,%d0
    lslw #2,%d0
    addl %a1@(0x0,%d0:w),%d1
    cmpiw #128,%d0
    jbeq MEASURETEXT_D6
    addl %fp@(-20),%d1
MEASURETEXT_D6:         /* next; scale if needed */
    dbf %d2,MEASURETEXT_BC
    cmpw %d3,%d4
    jbeq MEASURETEXT_F2
    moveal %fp@(8),%a2
    movew %fp@(16),%d2
MEASURETEXT_E6:         /* scale */
    movew %a2@,%d0
    muluw %d3,%d0
    divuw %d4,%d0
    movew %d0,%a2@+
    dbf %d2,MEASURETEXT_E6
MEASURETEXT_F2:         /* restore registers, return */
    moveml %sp@+,%d3-%d6/%a2-%a4
    unlk %fp
    rtd #10
    .long   0x00000000	| 4082941C

/* GETFONTINFO: _GetFontInfo. */
trap_GetFontInfo:
GETFONTINFO:
    linkw %fp,#-8
    movel #65537,%fp@(-4)
    movel #65537,%fp@(-8)
    clrl %sp@-
    clrl %sp@-
    pea %fp@(-4)
    pea %fp@(-8)
    movel %fp@(8),%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x11b4,%a0
    jbeq GETFONTINFO_38
    moveal %d0,%a0
    moveal %a0@(40),%a0
GETFONTINFO_38:         /* ascent/descent etc. from the font, plus style extras */
    jsr %a0@
    tstw %sp@+
    moveal %a5@,%a0
    moveal %a0@(-176),%a0
    moveal %fp@(8),%a1
    moveb %a0@(12),%d0
    extw %d0
    addw %d0,%a1@(4)
    clrw %d0
    moveb %a0@(11),%d0
    jbeq GETFONTINFO_5E
    addqw #1,%a1@
    addw %d0,%a1@(2)
GETFONTINFO_5E:         /* scale by numer/denom */
    movel %fp@(-4),%d0
    cmpl %fp@(-8),%d0
    jbeq GETFONTINFO_84
    jbsr GETFONTINFO_8A
    jbsr GETFONTINFO_8A
    movew %a1@,%d0
    muluw %fp@(-2),%d0
    movew %fp@(-6),%d1
    lsrw #1,%d1
    extl %d1
    addl %d1,%d0
    divuw %fp@(-6),%d0
    movew %d0,%a1@+
    jbsr GETFONTINFO_8A
GETFONTINFO_84:         /* return */
    unlk %fp
    rtd #4

GETFONTINFO_8A:         /* scale one field (rounded) */
    movew %a1@,%d0
    muluw %fp@(-4),%d0
    movew %fp@(-8),%d1
    lsrw #1,%d1
    extl %d1
    addl %d1,%d0
    divuw %fp@(-8),%d0
    movew %d0,%a1@+
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408294C2

/* CALCCHAREXTRA: CalcCharExtra(extra): the port's charExtra (fixed point) scaled by the current font's width scale (WidthPtr) */
CALCCHAREXTRA:
    moveml %d1-%d2/%a0-%a1,%sp@-
    subqw #8,%sp
    extl %d0
    asll #4,%d0
    movel %d0,%sp@-
    moveal WidthPtr,%a0
    moveq #0,%d0
    movew %a0@(1038),%d0
    swap %d0
    movel %d0,%sp@-
    jsr @(0xfa0,%za0)@(0)	| 408294EA
    subqw #8,%sp
    movew 0x992,%sp@-
    movew 0x996,%sp@-
    jsr @(0xfa4,%za0)@(0)	| 408294FA
    subqw #4,%sp
    movew FOutDenom_v,%sp@-
    movew FOutNumer_v,%sp@-
    jsr @(0xfa4,%za0)@(0)	| 4082950A
    jsr @(0xfa0,%za0)@(0)
    jsr @(0xfa0,%za0)@(0)
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40829522

/* CHAREXTRA: _CharExtra. */
trap_CharExtra:
CHAREXTRA:
    moveal %a5@(0,%za0)@(0),%a0	| 40829530
    tstw %a0@(6)
    jbpl CHAREXTRA_3E
    subqw #4,%sp
    movel %sp@(8),%sp@-
    movew %a0@(74),%d0
    jbne CHAREXTRA_2A
    tstw %a0@(68)
    jbne CHAREXTRA_22
    movew SysFontSize,%d0
    jbne CHAREXTRA_2A
CHAREXTRA_22:           /* no size: the default (FMDefaultSize, else 12) */
    moveb FMDefaultSize,%d0
    jbne CHAREXTRA_2A
    moveq #12,%d0
CHAREXTRA_2A:           /* extra / size into the port's chExtra */
    swap %d0
    clrw %d0
    movel %d0,%sp@-
    _FixDiv
    movel %sp@+,%d0
    asrl #4,%d0
    moveal %a5@(0,%za0)@(0),%a0	| 40829566
    movew %d0,%a0@(12)
CHAREXTRA_3E:           /* return */
    rtd #4
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40829572

/* STDLINE: StdLine: the line bottleneck. */
trap_StdLine:
STDLINE:
    linkw %fp,#0
    moveml %d5-%d7/%a3-%a4,%sp@-
    jsr @(0x1a3c,%za0)@(0)	| 40829588
    jble STDLINE_8E
    clrb %sp@-
    jbsr PUTPICVERB
    moveq #32,%d7
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %a3@(48),%d0
    cmpl %a4@(48),%d0
    jbne STDLINE_2C
    addqw #1,%d7
STDLINE_2C:             /* recording: Line (32), or ShortLine (34) when dh, dv fit a byte; from the last point: LineFrom / ShortLineFrom */
    movew %fp@(10),%d6
    subw %d0,%d6
    movew %d6,%d0
    extw %d0
    cmpw %d6,%d0
    jbne STDLINE_4C
    movew %fp@(8),%d5
    subw %a3@(48),%d5
    movew %d5,%d0
    extw %d0
    cmpw %d5,%d0
    jbne STDLINE_4C
    addqw #2,%d7
STDLINE_4C:             /* the opcode */
    movew %d7,%sp@-
    jbsr PUTPICOP
    rorw #1,%d7
    jbcs STDLINE_62
    movel %a3@(48),%sp@-
    jbsr PUTPICLONG
STDLINE_62:             /* the end point or the offsets */
    rorw #1,%d7
    jbcs STDLINE_72
    movel %fp@(8),%sp@-
    jbsr PUTPICLONG
    jbra STDLINE_82
STDLINE_72:             /* dh, dv */
    moveb %d6,%sp@-
    jbsr PUTPICBYTE
    moveb %d5,%sp@-
    jbsr PUTPICBYTE
STDLINE_82:             /* remember the pen position */
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %fp@(8),%a4@(48)
STDLINE_8E:             /* draw on each screen */
    pea %pc@(STDLINE_DA)
    pea %pc@(STDLINE_A6)
    jsr @(0x1aa0,%za0)@(0)	| 40829616
    moveml %sp@+,%d5-%d7/%a3-%a4
    unlk %fp
    rtd #4
STDLINE_A6:             /* rectangle proc: the line's box. Left and top are the smaller end, right and bottom the larger plus the pen size; returns through a0 */
    moveal %sp@+,%a0	| 40829626
    moveal %sp@+,%a1
    movel %fp@(8),%d0
    movel %a3@(48),%d1
    cmpw %d0,%d1
    bgts STDLINE_A6_12
    exg %d0,%d1
STDLINE_A6_12:
    movew %d0,%a1@(2)
    addw %a3@(54),%d1
    movew %d1,%a1@(6)
    swap %d0
    swap %d1
    cmpw %d0,%d1
    bgts STDLINE_A6_28
    exg %d0,%d1
STDLINE_A6_28:          /* the line rectangle: from the smaller to the larger point, widened by the pen */
    movew %d0,%a1@
    addw %a3@(52),%d1
    movew %d1,%a1@(4)
    jmp %a0@
STDLINE_DA:             /* draw proc: DRAWLINE */
    movel %fp@(8),%sp@-
    jsr @(0x1a40,%za0)@(0)	| 4082965E
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40829666

/* LINETO: _LineTo. */
trap_LineTo:
LINETO:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x1040,%a0
    jbeq LINETO_14
    moveal %d0,%a0
    moveal %a0@(4),%a0
LINETO_14:              /* through the port's lineProc or StdLine */
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40829686

/* LINE: _Line. */
trap_Line:
LINE:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movew %a0@(50),%d0
    addw %d0,%sp@(6)
    movew %a0@(48),%d0
    addw %d0,%sp@(4)
    jmp %pc@(trap_LineTo)
    .long   0x00000000, 0x00000000	| 408296A8

/* MOVETO: _MoveTo. */
trap_MoveTo:
MOVETO:
    moveal %sp@+,%a0
    moveal %a5@,%a1
    moveal %a1@,%a1
    movel %sp@+,%a1@(48)
/* COMMONMOVEEND: common end of the pen moves: in a color port reset the pen's fractional h position (pnLocHFrac, +14) to 1/2 */
COMMONMOVEEND:
    tstw %a1@(6)
    jbpl COMMONMOVEEND_C
    movew #-32768,%a1@(14)
COMMONMOVEEND_C:        /* return */
    jmp %a0@
    .long   0x00000000, 0x00000000	| 408296C8

/* MOVE: _Move. */
trap_Move:
MOVE:
MOOV:
    moveal %sp@+,%a0
    movew %sp@+,%d0
    movew %sp@+,%d1
    moveal %a5@,%a1
    moveal %a1@,%a1
    addw %d0,%a1@(48)
    addw %d1,%a1@(50)
    jbra COMMONMOVEEND
    .long   0x00000000, 0x00000000, 0x00000000	| 408296E4

/* DOLINE: DoLine(pt): draw a line from the pen to pt through the port's line proc; while a region or polygon is open add it there too */
trap_DOLINE:
DOLINE:
    moveml %d6-%d7/%a3-%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a3
    movel %sp@(20),%d7
    movel %a3@(48),%d6
    tstl %a3@(100)
    jbeq DOLINE_4E
    moveal %a4@(-162),%a1
    moveal %a1@,%a0
    moveq #0,%d0
    movew %a0@,%d0
    cmpiw #10,%d0
    jbne DOLINE_2E
    movel %d6,%a0@(0x0,%d0:l)
    addqw #4,%d0
    jbcs DOLINE_4C
DOLINE_2E:              /* a polygon is open: add the point (grow by 256 bytes) */
    movel %d7,%a0@(0x0,%d0:l)
    addqw #4,%d0
    movew %d0,%a0@
    cmpw %a4@(-164),%d0
    jbcs DOLINE_4C
    addiw #256,%a4@(-164)
    movel %a1,%sp@-
    movew %a4@(-164),%sp@-
    jsr %pc@(SETHSIZE)
DOLINE_4C:              /* draw */
    jbra DOLINE_6A
DOLINE_4E:              /* a region is open: add the line (PUTLINE) */
    tstl %a3@(96)
    jbeq DOLINE_6A
    movel %d6,%sp@-
    movel %d7,%sp@-
    movel %a4@(-148),%sp@-
    pea %a4@(-150)
    pea %a4@(-152)
    jsr @(0x1a64,%za0)@(0)	| 40829754
DOLINE_6A:              /* draw it (LineProc), move the pen */
    movel %d6,%sp@-
    movel %d7,%sp@-
    jsr @(0x1a28,%za0)@(0)	| 4082975E
    movel %d7,%a3@(48)
    tstw %a3@(6)
    jbpl DOLINE_84
    movew #-32768,%a3@(14)
DOLINE_84:              /* restore registers, return */
    moveml %sp@+,%d6-%d7/%a3-%a4
    movel %sp@+,%sp@
    rts
    .long   0x00000000	| 4082977C

/* HIDEPEN: _HidePen. */
trap_HidePen:
HIDEPEN:
    moveq #-1,%d0
    jbra SHOWPEN_2

/* SHOWPEN: _ShowPen. */
trap_ShowPen:
SHOWPEN:
    moveq #1,%d0
SHOWPEN_2:              /* add d0 to pnVis */
    moveal %a5@,%a0
    moveal %a0@,%a0
    addw %d0,%a0@(66)
    rts

/* GETPENSTATE: _GetPenState. */
trap_GetPenState:
GETPENSTATE:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movew %a0@(6),%d1
    lea %a0@(48),%a0
    moveal %sp@(4),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movew %a0@+,%a1@+
    tstw %d1
    jbmi GETPENSTATE_22
GETPENSTATE_1A:         /* the pattern */
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
GETPENSTATE_1E:         /* pop, return */
    movel %sp@+,%sp@
    rts
GETPENSTATE_22:         /* color port: the pixpat handle; a type 0 one carries the old pattern */
    movel %a0@,%a1@
    moveal %a0@,%a0
    moveal %a0@,%a0
    tstw %a0@
    jbeq GETPENSTATE_34
    oriw #-32768,%a1@(-2)
    jbra GETPENSTATE_1E
GETPENSTATE_34:         /* old pattern from the pixpat */
    moveal %a0@(6),%a0
    moveal %a0@,%a0
    jbra GETPENSTATE_1A

/* SETPENSTATE: _SetPenState. */
trap_SetPenState:
SETPENSTATE:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movew %a0@(6),%d1
    lea %a0@(48),%a1
    moveal %sp@(4),%a0
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movew %a0@+,%a1@
    andiw #32767,%a1@+
    tstw %d1
    jbpl GETPENSTATE_1A
    tstw %a0@(-2)
    jbpl SETPENSTATE_2E
    movel %a0@,%sp@-
    jsr @(0x1628,%za0)@(0x0)	| 408297F2
    jbra GETPENSTATE_1E
SETPENSTATE_2E:         /* color port: PenPixPat */
    movel %a0,%sp@-
    jsr @(0x1074,%za0)@(0x0)	| 408297FC
    jbra GETPENSTATE_1E
    .long   0x00000000, 0x00000000, 0x00000000	| 40829804

/* GETPEN: _GetPen. */
trap_GetPen:
GETPEN:
    moveal %a5@,%a0
    moveal %a0@,%a0
    moveal %sp@(4),%a1
    movel %a0@(48),%a1@
    movel %sp@+,%sp@
    rts

/* PENSIZE: _PenSize. */
trap_PenSize:
PENSIZE:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %sp@(4),%a0@(52)
    movel %sp@+,%sp@
    rts
    .short  0x0000	| 4082982E

/* PENMODE: _PenMode. */
trap_PenMode:
PENMODE:
    moveq #56,%d0
    jmp %pc@(PORTWORD)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40829836

/* PENPAT: _PenPat. */
trap_PenPat:
PENPAT:
    moveal %sp@(4),%a1
    moveal %a5@,%a0
    moveal %a0@,%a0
PENPAT_8:               /* old port: copy the pattern */
    tstw %a0@(6)
    jbmi PENPAT_1A
    lea %a0@(58),%a0
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
PENPAT_16:              /* return */
    movel %sp@+,%sp@
    rts
PENPAT_1A:              /* color port: through the pixpat (OldPatToNew) */
    movel %a1,%sp@-
    pea %a0@(58)
    jsr @(0x1a44,%za0)@(0)	| 40829860
    jbra PENPAT_16

/* PENNORMAL: _PenNormal. */
trap_PenNormal:
PENNORMAL:
    moveal %a5@,%a0
    lea %a0@(-16),%a1
    moveal %a0@,%a0
    movel #65537,%a0@(52)
    movew #8,%a0@(56)
    movel %sp@,%sp@-
    jbra PENPAT_8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40829882

/* PUTLINE: PutLine(start, end, rgnBuffer): add a line's edge to the region being built (inversion points per row) */
trap_PUTLINE:
PUTLINE:
    moveml %d3-%d7/%a2-%a4,%sp@-
    movew %sp@(54),%d2
    movew %sp@(50),%d4
    cmpw %d2,%d4
    jbeq PUTLINE_FE
    movew %d2,%d0
    subw %d4,%d0
    jbpl PUTLINE_1A
    negw %d0
PUTLINE_1A:             /* dh */
    movew %sp@(52),%d1
    subw %sp@(48),%d1
    jbpl PUTLINE_26
    negw %d1
PUTLINE_26:             /* the longer */
    cmpw %d1,%d0
    jble PUTLINE_2C
    movew %d1,%d0
PUTLINE_2C:             /* room for the points; too many: rgnTooBigErr */
    addqw #1,%d0
    extl %d0
    lsll #3,%d0
    moveal %sp@(44),%a3
    moveal %sp@(40),%a4
    moveq #0,%d1
    movew %a4@,%d1
    addl %d1,%d0
    cmpil #65024,%d0
    jblt PUTLINE_52
    movew #-147,QDErr
    jbra PUTLINE_FE
PUTLINE_52:             /* grow by 512 */
    moveal %sp@(36),%a0
    cmpw %a0@,%d0
    jbls PUTLINE_6C
    addiw #512,%d0
    movew %d0,%a0@
    movel %a3,%sp@-
    movew %d0,%sp@-
    jsr %pc@(SETHSIZE)
    movew %sp@(54),%d2
PUTLINE_6C:             /* vertical line: just its two ends */
    moveal %a3@,%a3
    moveq #0,%d0
    movew %a4@,%d0
    addal %d0,%a3
    movew %sp@(52),%d1
    movew %sp@(48),%d3
    cmpw %d1,%d3
    jbne PUTLINE_8A
    movew %d1,%a3@+
    movew %d2,%a3@+
    movew %d3,%a3@+
    movew %d4,%a3@+
    jbra PUTLINE_F6
PUTLINE_8A:             /* from the top */
    jbgt PUTLINE_90
    exg %d1,%d3
    exg %d2,%d4
PUTLINE_90:             /* the slope (FixRatio) */
    movew %d1,%d6
    clrl %sp@-
    movew %d4,%sp@-
    subw %d2,%sp@
    movew %d3,%sp@-
    subw %d1,%sp@
    jsr @(0xfa4,%za0)@(0)	| 4082992C
    movel %sp@+,%d7
    movew %d2,%d1
    swap %d1
    movew #-32768,%d1
    movel %d7,%d0
    asrl #1,%d0
    addl %d0,%d1
    movel #65536,%d0
    tstl %d7
    jbmi PUTLINE_C4
    cmpl %d0,%d7
    jbge PUTLINE_CE
    addl %d7,%d1
    jbra PUTLINE_CE
PUTLINE_C4:             /* steep: start half a step in */
    cmpil #-65536,%d7
    jbge PUTLINE_CE
    addl %d0,%d1
PUTLINE_CE:             /* each row: an inversion point where h changes */
    movew %d2,%d5
PUTLINE_D0:             /* h changed: two points */
    swap %d1
    cmpw %d1,%d5
    jbeq PUTLINE_E0
    movew %d6,%a3@+
    movew %d5,%a3@+
    movew %d1,%d5
    movew %d6,%a3@+
    movew %d5,%a3@+
PUTLINE_E0:             /* next row; the end */
    swap %d1
    addqw #1,%d6
    addl %d7,%d1
    cmpw %d6,%d3
    jbne PUTLINE_D0
    cmpw %d4,%d5
    jbeq PUTLINE_F6
    movew %d6,%a3@+
    movew %d5,%a3@+
    movew %d6,%a3@+
    movew %d4,%a3@+
PUTLINE_F6:             /* the new size */
    moveal %sp@(44),%a0
    subal %a0@,%a3
    movew %a3,%a4@
PUTLINE_FE:             /* restore registers */
    moveml %sp@+,%d3-%d7/%a2-%a4
    moveal %sp@+,%a0
    lea %sp@(20),%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 4082999A

/* DRAWLINE: draw a line. */
trap_DRAWLINE:
DRAWLINE:
    linkw %fp,#-332
    moveml %d0-%d7/%a1-%a5,%sp@-
    movel %sp,%fp@(-292)
    movel %a5,%fp@(-316)
    clrl %fp@(-32)
    moveal %a5@,%a0
    movel %a0@(-130),%fp@(-328)
    moveal %a0@,%a3
    tstw %a3@(66)
    jblt DRAWLINE_4E0
    movel %a3,%fp@(-320)
    movel %sp,%d1
    andib #0xfc,%d1
    moveal %d1,%sp
    lea %a3@(2),%a1
    lea %fp@(-244),%a2
    jsr @(0x1a08,%za0)@(0)	| 408299DA
    movel %d1,%fp@(-332)
    moveb %d2,%fp@(-324)
    lea %pc@(SHFTTBL),%a0
    movew %fp@(-212),%d0
    moveq #0,%d1
    moveb %a0@(0x0,%d0:w),%d1
    movew %d1,%fp@(-118)
    lea %a3@(58),%a0
    movel %a0,%fp@(-156)
    movew %a3@(56),%d0
    bset #3,%d0
    moveq #16,%d1
    btst #5,%d0
    jbeq DRAWLINE_7A
    cmpiw #58,%d0
    jbeq DRAWLINE_80
    moveq #48,%d1
DRAWLINE_7A:            /* empty? nothing to draw */
    cmpw %d1,%d0
    jbgt DRAWLINE_4E0
DRAWLINE_80:            /* the mode, the colors (COLORMAP), the pen */
    movew %d0,%fp@(-152)
    tstw %a3@(6)
    smi %fp@(-166)
    moveb HiliteMode,%sp@-
    clrb %fp@(-257)
    jsr @(0x1a10,%za0)@(0)	| 40829A34
    moveb %sp@+,HiliteMode
    moveal %a3,%a5
    moveal %a5@(28),%a2
    moveal %a2@,%a2
    moveal %a5@(24),%a3
    moveal %a3@,%a3
    movemw %fp@(8),%d1-%d4
    cmpw %d3,%d1
    jble DRAWLINE_B8
    exg %d1,%d3
DRAWLINE_B8:            /* the line's bounding box with the pen size */
    cmpw %d4,%d2
    jble DRAWLINE_BE
    exg %d2,%d4
DRAWLINE_BE:            /* clip to the port */
    addw %a5@(54),%d4
    addw %a5@(52),%d3
    movemw %d1-%d4,%fp@(-288)
    pea %fp@(-288)
    pea %fp@(-238)
    pea %a2@(2)
    pea %a3@(2)
    movew #4,%sp@-
    pea %fp@(-116)
    jsr @(0x1a84,%za0)@(0)	| 40829A84
    jbeq DRAWLINE_4E0
    moveal %fp@(-316),%a5
    tstb %fp@(-324)
    jbeq DRAWLINE_106
    pea %fp@(-116)
    movel %fp@(-332),%sp@-
    jsr @(0xf54,%za0)@(0)	| 40829AA0
DRAWLINE_106:           /* rectangular clip? 1-bit solid pattern: simpler mode */
    moveal %fp@(-320),%a5
    clrb %fp@(-322)
    cmpiw #10,%a2@
    jbne DRAWLINE_186
    cmpiw #10,%a3@
    jbeq DRAWLINE_132
    movel %a5@(24),%sp@-
    pea %fp@(-116)
    movew #-1,%sp@-
    jsr @(0x1aa4,%za0)@(0)	| 40829AC6
    jblt DRAWLINE_4D0
    jbgt DRAWLINE_186
DRAWLINE_132:           /* solid pattern? */
    btst #5,%fp@(-151)
    jbne DRAWLINE_186
    moveal %fp@(-156),%a0
    tstb %fp@(-166)
    jbeq DRAWLINE_152
    moveal %a0@,%a0
    moveal %a0@,%a0
    tstw %a0@
    jbne DRAWLINE_186
    moveal %a0@(6),%a0
    moveal %a0@,%a0
DRAWLINE_152:           /* all ones or zeros */
    movel %a0@+,%d0
    cmpl %a0@+,%d0
    jbne DRAWLINE_186
    notl %d0
    jbeq DRAWLINE_166
    notl %d0
    jbne DRAWLINE_186
    eoriw #4,%fp@(-152)
DRAWLINE_166:           /* map the mode; a no-op: done */
    st %fp@(-322)
    moveq #7,%d0
    andw %fp@(-152),%d0
    moveb %pc@(DRAWLINE_17E,%d0:w),%d0
    jbmi DRAWLINE_4D0
    movew %d0,%fp@(-152)
    jbra DRAWLINE_186
DRAWLINE_17E:           /* mode map (data) */
    .short  0x0000	| 40829B1E
    .short  0x0102, 0x02FF, 0xFFFF	| 40829B20
DRAWLINE_186:           /* horizontal or vertical? */
    movemw %fp@(8),%d1-%d4
    cmpw %d2,%d4
    jbeq DRAWLINE_196
    cmpw %d1,%d3
    jbgt DRAWLINE_1EC
    jblt DRAWLINE_1E8
DRAWLINE_196:           /* horizontal: 1-pixel pen, simple: the fast line (vector 0x1C70) */
    tstb %fp@(-322)
    jbeq DRAWLINE_1AC
    cmpil #65537,%a5@(52)
    jbne DRAWLINE_1AC
    jmp @(0x1c70,%za0)@(0)	| 40829B46
DRAWLINE_1AC:           /* else as a rectangle, straight to the blitter (vector 0x1A9C) */
    pea %a5@(2)
    clrl %sp@-
    pea %a5@(2)
    pea %fp@(-116)
    clrl %sp@-
    pea %fp@(-116)
    movew %a5@(56),%sp@-
    oriw #8,%sp@
    pea %a5@(58)
    movel %a5@(28),%sp@-
    movel %a5@(24),%sp@-
    movel %fp@(-328),%sp@-
    moveal %fp@(-316),%a5
    clrw %sp@-
    jsr @(0x1a9c,%za0)@(0)	| 40829B7E
    jbra DRAWLINE_4D0
DRAWLINE_1E8:           /* from the top */
    exg %d1,%d3
    exg %d2,%d4
DRAWLINE_1EC:           /* the slope; outside the clip: done */
    movew %d3,%d0
    addw %a5@(52),%d0
    cmpw %fp@(-116),%d0
    jble DRAWLINE_4D0
    cmpw %fp@(-112),%d1
    jbge DRAWLINE_4D0
    movew %d2,%fp@(-300)
    movew #-32768,%fp@(-298)
    movel %fp@(-300),%fp@(-304)
    movew %a5@(54),%d0
    jble DRAWLINE_4D0
    addw %d0,%fp@(-304)
    movew %a5@(52),%d6
    jble DRAWLINE_4D0
    subw %d2,%d4
    subw %d1,%d3
    extl %d3
    moveq #0,%d7
    movew %d4,%d7
    swap %d7
    divsll %d3,%d7,%d7
    movel %d7,%fp@(-308)
    movel %d7,%d5
    cmpiw #1,%d6
    jbeq DRAWLINE_248
    extl %d6
    .short  0x4C06, 0x5805	| 40829BE4 mulsl %d6,%d5
DRAWLINE_248:           /* the h range of the first row */
    subal %a2,%a2
    movel %d7,%d0
    asrl #1,%d0
    addl %d0,%fp@(-300)
    addl %d0,%fp@(-304)
    tstl %d7
    jbmi DRAWLINE_278
    subl %d5,%fp@(-300)
    cmpil #65536,%d7
    jbgt DRAWLINE_272
    jbeq DRAWLINE_270
    addl %d7,%fp@(-300)
    addqw #1,%a2
    jbra DRAWLINE_290
DRAWLINE_270:           /* steep */
    addqw #1,%a2
DRAWLINE_272:           /* one pixel */
    subqw #1,%fp@(-304)
    jbra DRAWLINE_290
DRAWLINE_278:           /* leftward */
    subl %d5,%fp@(-304)
    cmpil #-65536,%d7
    jblt DRAWLINE_28C
    addl %d7,%fp@(-304)
    subqw #1,%a2
    jbra DRAWLINE_290
DRAWLINE_28C:           /* flat */
    addqw #1,%fp@(-300)
DRAWLINE_290:           /* clip to the top */
    movemw %fp@(-116),%d1-%d4
    cmpw %fp@(-288),%d1
    jbeq DRAWLINE_2B2
    movew %d1,%d0
    subw %fp@(-288),%d0
    extl %d0
    movel %d7,%d5
    .short  0x4C00, 0x5805	| 40829C46 mulsl %d0,%d5
    addl %d5,%fp@(-300)
    addl %d5,%fp@(-304)
DRAWLINE_2B2:           /* unclipped and 1-pixel pen: the fast slanted line (vector 0x1C74) */
    tstb %fp@(-322)
    jbeq DRAWLINE_2D4
    cmpw %fp@(-286),%d2
    jbgt DRAWLINE_2D4
    cmpw %fp@(-282),%d4
    jblt DRAWLINE_2D4
    cmpil #65537,%a5@(52)
    jbne DRAWLINE_2D4
    jmp @(0x1c74,%za0)@(0)	| 40829C6E

DRAWLINE_2D4:           /* the region mask buffer */
    movew %fp@(-118),%d5
    subw %fp@(-236),%d2
    extl %d2
    lsll %d5,%d2
    andil #-32,%d2
    movel %d2,%d1
    lsrl #3,%d1
    movew %d1,%fp@(-144)
    lsrl %d5,%d2
    addw %fp@(-236),%d2
    movew %d2,%fp@(-14)
    tstb %fp@(-322)
    bnew DRAWLINE_34C
    subw %d2,%d4
    movew %d4,%d0
    extl %d4
    lsll %d5,%d4
    subql #1,%d4
    lsrl #5,%d4
    movew %d4,%fp@(-16)
    lsrw #5,%d0
    addqw #1,%d0
    lslw %d5,%d0
    subqw #1,%d0
DRAWLINE_318:           /* clear it */
    clrl %sp@-
    dbf %d0,DRAWLINE_318
    movel %sp,%fp@(-8)
    lea %pc@(DRAWLINE_4D0),%a0
    movel %a0,%fp@(-128)
    movel Lo3Bytes,%fp@(-132)
    clrl %fp@(-124)
    clrl %fp@(-12)
    movel %a5@(24),%sp@-
    movel %a5@(28),%sp@-
    movel #1,%sp@-
    jsr @(0x1a34,%za0)@(0)	| 40829CE6
DRAWLINE_34C:           /* the first row */
    movew %fp@(-116),%d1
    subw %fp@(-238),%d1
    movew %fp@(-240),%d0
    andiw #32767,%d0
    movew %d0,%fp@(-124)
    mulsw %d0,%d1
    addl %fp@(-244),%d1
    movew %fp@(-14),%d2
    subw %fp@(-236),%d2
    movew %fp@(-118),%d7
    lslw %d7,%d2
    lsrw #3,%d2
    extl %d2
    addl %d2,%d1
    movel %d1,%fp@(-312)
    movew %fp@(-14),%d1
    subw %d1,%fp@(-300)
    subw %d1,%fp@(-304)
    subw %d1,%fp@(-114)
    subw %d1,%fp@(-110)
    tstb %fp@(-322)
    jbeq DRAWLINE_3F4
    movew %fp@(-152),%d2
    jsr @(0x1a30,%za0)@(0)	| 40829D3C
    lea %fp@(-116),%a3
    movel %fp@(-308),%d7
    moveal %fp@(-312),%a5
    movel %fp@(-160),%d4
    movel %fp@(-164),%d5
    movew %fp@(-112),%d6
    subw %fp@(-116),%d6
    subqw #1,%d6
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 40829D62
    moveb %d0,%fp@(-258)
DRAWLINE_3CC:           /* the slab of each row (h range) into the mask */
    movew %fp@(-300),%d1
    movew %fp@(-304),%d2
    moveal %a5,%a1
    movew %fp@(-118),%d0
    jsr @(0x1a2c,%za0)@(0)	| 40829D7A
    addaw %fp@(-124),%a5
    addl %d7,%fp@(-300)
    addl %d7,%fp@(-304)
    dbf %d6,DRAWLINE_3CC
    jbra DRAWLINE_4C6
DRAWLINE_3F4:           /* inverting modes */
    moveq #0,%d7
    movew %fp@(-152),%d2
    btst #5,%d2
    jbne DRAWLINE_408
    bclr #2,%d2
    jbeq DRAWLINE_408
    notl %d7
DRAWLINE_408:           /* the pattern */
    moveal %fp@(-316),%a5
    jsr @(0x1a54,%za0)@(0)	| 40829DAC
    movew %fp@(-142),%d1
    jbne DRAWLINE_42E
    moveq #15,%d6
    moveq #4,%d1
    movew %d1,%fp@(-142)
    movew #3,%fp@(-140)
    movew #63,%fp@(-138)
    jbra DRAWLINE_43C
DRAWLINE_42E:           /* pixpat rows */
    moveq #0,%d6
    movew %fp@(-138),%d6
    addqw #1,%d6
    divuw %fp@(-142),%d6
    subqw #1,%d6
DRAWLINE_43C:           /* pattern row, slab loop, 32-bit addressing */
    andw %fp@(-116),%d6
    muluw %d1,%d6
    movel %d6,%fp@(-150)
    movew %fp@(-152),%d2
    jsr @(0x1a94,%za0)@(0)	| 40829DEA
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 40829DF2
    moveb %d0,%fp@(-258)
    movew %fp@(-116),%fp@(-4)
    moveal %fp@(-312),%a5
    movel %fp@(-160),%d4
    movel %fp@(-164),%d5
    movel %fp@(-308),%d7
DRAWLINE_472:           /* each row: region mask, the slab */
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 40829E12
    lea %fp@(-116),%a3
    lea %fp@(0xffffffffffffff78)@(0x0,%d6:l),%a0
    movel %a0@,%d6
    movew %fp@(-300),%d1
    movew %fp@(-304),%d2
    moveal %a5,%a1
    moveal %fp@(-8),%a2
    movew %fp@(-118),%d0
    jsr @(0x1a2c,%za0)@(0)	| 40829E36
    movel %fp@(-150),%d6
    addw %fp@(-142),%d6
    andw %fp@(-138),%d6
    movel %d6,%fp@(-150)
    addaw %fp@(-124),%a5
    addl %d7,%fp@(-300)
    addl %d7,%fp@(-304)
    addqw #1,%fp@(-4)
    movew %fp@(-4),%d0
    cmpw %fp@(-112),%d0
    jblt DRAWLINE_472
DRAWLINE_4C6:           /* restore the addressing mode */
    moveb %fp@(-258),%d0
    jsr @(0x574,%za0)@(0x0)	| 40829E6A
DRAWLINE_4D0:           /* show the cursor */
    moveal %fp@(-316),%a5
    tstb %fp@(-324)
    jbeq DRAWLINE_4E0
    jsr @(0xf4c,%za0)@(0)	| 40829E7A
DRAWLINE_4E0:           /* hilite off, return */
    bset #7,HiliteMode
    moveal %fp@(-292),%sp
    moveml %sp@+,%d0-%d7/%a1-%a5
    unlk %fp
    rtd #8
    .long   0x00000000, 0x00000000, 0x00000000	| 40829E94

/* FASTLINE: fast horizontal/vertical lines. */
trap_FASTLINE:
FASTLINE:
    moveq #1,%d0
    movew %d1,%sp@-
    jsr @(0x574,%za0)@(0x0)	| 40829EA4
    movew %sp@+,%d1
    moveb %d0,%fp@(-258)
    cmpw %d1,%d3
    jbne FASTLINE_C0
    jbsr FASTLINE_140
    moveq #-1,%d6
    lsrl %d0,%d6
    movew %fp@(-110),%d2
    subw %fp@(-236),%d2
    extl %d2
    lsll %d3,%d2
    moveq #31,%d0
    andl %d2,%d0
    moveq #-1,%d3
    lsrl %d0,%d3
    notl %d3
    lsrl #5,%d2
    cmpiw #1,%fp@(-152)
    jblt FASTLINE_46
    jbeq FASTLINE_90
    movel %fp@(-164),%d5
    jbra FASTLINE_4A
FASTLINE_46:            /* horizontal: the color long */
    movel %fp@(-160),%d5
FASTLINE_4A:            /* first long masked */
    subw %d1,%d2
    jbeq FASTLINE_80
    movel %d5,%d1
    andl %d6,%d1
    notl %d6
    andl %a4@,%d6
    orl %d1,%d6
    movel %d6,%a4@+
    subqw #1,%d2
    jbeq FASTLINE_6A
    jbra FASTLINE_62
FASTLINE_60:            /* middle longs */
    movel %d5,%a4@+
FASTLINE_62:            /* two at a time */
    movel %d5,%a4@+
    subqw #2,%d2
    jbgt FASTLINE_60
    jbeq FASTLINE_62
FASTLINE_6A:            /* last long */
    andl %d3,%d5
    notl %d3
    andl %a4@,%d3
    orl %d5,%d3
    movel %d3,%a4@
    jbra DRAWLINE_4C6
    .long   0x00000000, 0x00000000	| 40829F18
FASTLINE_80:            /* within one long */
    andl %d3,%d6
    andl %d6,%d5
    notl %d6
    andl %a4@,%d6
    orl %d5,%d6
    movel %d6,%a4@
    jbra DRAWLINE_4C6
FASTLINE_90:            /* xor mode */
    subw %d1,%d2
    jbeq FASTLINE_AC
    eorl %d6,%a4@+
    subqw #1,%d2
    jbeq FASTLINE_A6
    jbra FASTLINE_9E
FASTLINE_9C:            /* middle longs */
    notl %a4@+
FASTLINE_9E:            /* two at a time */
    notl %a4@+
    subqw #2,%d2
    jbgt FASTLINE_9C
    jbeq FASTLINE_9E
FASTLINE_A6:            /* last long */
    eorl %d3,%a4@
    jbra DRAWLINE_4C6
FASTLINE_AC:            /* one long */
    andl %d3,%d6
    eorl %d6,%a4@
    jbra DRAWLINE_4C6
    .long   0x00000000, 0x00000000, 0x00000000	| 40829F54
FASTLINE_C0:            /* vertical: the pixel's mask */
    jbsr FASTLINE_140
    moveq #-1,%d2
    lsrl %d0,%d2
    movel %d2,%d0
    movew %fp@(-212),%d1
    lsrl %d1,%d0
    notl %d0
    andl %d0,%d2
    movew %fp@(-112),%d1
    subw %fp@(-116),%d1
    subqw #1,%d1
    cmpiw #1,%fp@(-152)
    jblt FASTLINE_EC
    jbeq FASTLINE_110
    movel %fp@(-164),%d5
    jbra FASTLINE_F0
FASTLINE_EC:            /* the color */
    movel %fp@(-160),%d5
FASTLINE_F0:            /* black: or; white: bic; else insert */
    jbeq FASTLINE_130
    movel %d5,%d0
    notl %d0
    jbeq FASTLINE_120
    andl %d2,%d5
    notl %d2
FASTLINE_FC:            /* each row */
    movel %d2,%d3
    andl %a4@,%d3
    orl %d5,%d3
    movel %d3,%a4@
    addaw %d7,%a4
    dbf %d1,FASTLINE_FC
    jbra DRAWLINE_4C6
    .short  0x0000	| 40829FAE
FASTLINE_110:           /* xor */
    eorl %d2,%a4@
    addaw %d7,%a4
    dbf %d1,FASTLINE_110
    jbra DRAWLINE_4C6
    .long   0x00000000	| 40829FBC
FASTLINE_120:           /* or */
    orl %d2,%a4@
    addaw %d7,%a4
    dbf %d1,FASTLINE_120
    jbra DRAWLINE_4C6
    .long   0x00000000	| 40829FCC
FASTLINE_130:           /* bic */
    notl %d2
FASTLINE_132:           /* each row */
    andl %d2,%a4@
    addaw %d7,%a4
    dbf %d1,FASTLINE_132
    jbra DRAWLINE_4C6
    .short  0x0000	| 40829FDE

FASTLINE_140:           /* the address of the first pixel */
    moveal %fp@(-244),%a4
    movew %fp@(-116),%d0
    subw %fp@(-238),%d0
    movew %fp@(-240),%d7
    andiw #32767,%d7
    mulsw %d7,%d0
    addal %d0,%a4
    movew %fp@(-114),%d0
    subw %fp@(-236),%d0
FASTLINE_160:           /* long and bit offset */
    extl %d0
    movew %fp@(-118),%d3
    extl %d3
    lsll %d3,%d0
    movel %d0,%d1
    lsrl #5,%d1
    lea %a4@(0x0,%d1:w:4),%a4
    andiw #31,%d0
    rts
