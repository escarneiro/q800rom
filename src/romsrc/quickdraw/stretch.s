/*
 quickdraw/stretch.s - stretching, scaling and dithering
 From STCOLORTAB (0x40837030). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 The second half of StretchBits (its start, STRETCHBITS, is in regions.s): the converter
 tables (STCOLORTAB, STGRAYTAB, STSEARCHTAB), buffer set-up, the row loop STSCANLOOP with
 its fast paths (CB8TO8CLIP, ANDY = CB1TO8CLIP, CB8TO1CLIP), the StretchBits mode loops
 (STMASK0..3, ST arithmetic modes, the 16/32-bit ones in STARITH16TAB/STARITH32TAB), the
 depth expansion tables (EXTBL, PATEXTBL, TABLE2/4/8), the pixel converters
 (SCALE.., DITHER.., SEARCH..) and SCALEBLT (same-size copy with a depth change).

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not
 taken from Apple.
*/

/* STCOLORTAB: table. */
trap_STCOLORTAB:
STCOLORTAB:
    .long   0xFFFFFFFA, 0x00002790, 0x00002A30, 0x00002390	| 40837030
    .long   0x00002C50, 0x00002B00, 0xFFFFFFFA, 0x000024A0	| 40837040

/* STGRAYTAB: table. */
trap_STGRAYTAB:
STGRAYTAB:
    .short  0x0000, 0x2830	| orib #48,%d0
    .short  0x0000, 0x27D0	| orib #0xd0,%d0
    .long   0xFFFFFFDA, 0x00002590	| 40837058
    .long   0x000028F0, 0x00002880, 0xFFFFFFDA, 0x00002670	| 40837060

/* STSEARCHTAB: table. */
trap_STSEARCHTAB:
STSEARCHTAB:
    .long   0xFFFFFFBA, 0x00002940, 0x00002A20, 0xFFFFFFBA	| 40837070
    .long   0x00002CB0, 0x00002B30, 0xFFFFFFBA, 0xFFFFFFBA	| 40837080
STSEARCHTAB_20:         /* (StretchBits) indexed source: same color table as the destination? */
    moveal %fp@(-318),%a0
    moveal %a0@,%a0
    movel %a0@,%d0
    moveal %fp@(-202),%a0
    cmpiw #16,%fp@(-214)
    jbeq STSEARCHTAB_40
    moveal %a0@,%a0
    cmpl %a0@,%d0
    jbne STSEARCHTAB_40
    cmpw %d3,%d4
    jbeq ONEBITPROC_4A
STSEARCHTAB_40:         /* same depth and table: no conversion; 1-bit: the plain expansion */
    tstw %d3
    jbne STSEARCHTAB_4C
    moveq #1,%d1
    cmpl %d0,%d1
    jbeq ONEBITPROC_3C
STSEARCHTAB_4C:         /* the translation table on the stack (one long per source color) */
    movew %fp@(-328),%d1
    moveq #1,%d0
    lslw %d1,%d0
    subl %d0,%fp@(-132)
    jbpl STSEARCHTAB_60
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x1c5c,%za0)@(0)	| 408370CA
STSEARCHTAB_60:         /* 1-bit destination from a pixmap: the luminance search proc (ONEBITPROC) */
    moveq #0,%d7
    cmpiw #1,%fp@(-212)
    jbne STSEARCHTAB_80
    moveal %fp@(40),%a1
    tstw %a1@(4)
    jbmi STSEARCHTAB_80
    moveq #1,%d7
    pea %pc@(ONEBITPROC)
    jsr @(0x16e8,%za0)@(0)	| 408370EA
STSEARCHTAB_80:         /* build the table (MakeScaleTbl); same depth: is it the identity? */
    moveal %fp@(-464),%a5
    movel %a4,%sp@-
    movew #32,%sp@-
    jsr @(0x1a38,%za0)@(0)	| 408370FA
    movew %fp@(-328),%d1
    cmpw %fp@(-212),%d1
    jbne STSEARCHTAB_DE
    moveq #1,%d0
    lslw %d1,%d0
    movew %d0,%d1
    lslw #2,%d1
    subqw #1,%d0
    moveal %sp,%a0
    addaw %d1,%a0
STSEARCHTAB_A8:         /* identity? */
    cmpl %a0@-,%d0
    dbne %d0,STSEARCHTAB_A8
    jbne STSEARCHTAB_DE
    tstw %d7
    jbeq STSEARCHTAB_BE
    pea %pc@(ONEBITPROC)
    jsr @(0x1730,%za0)@(0x0)	| 40837128
STSEARCHTAB_BE:         /* identity: no conversion; same size and no mask: BLITCASE's fast path */
    lea %fp@(-244),%a5
    tstl %fp@(44)
    bnew ONEBITPROC_4A
    movel %fp@(-520),%d0
    cmpl %fp@(-524),%d0
    bnew ONEBITPROC_4A
    movel %fp@(-456),%d7
    jbra BLITCASE_4E
STSEARCHTAB_DE:         /* the table (fp-572) */
    movel %sp,%fp@(-572)
    lea %fp@(-244),%a5
    tstw %d7
    jbeq STSEARCHTAB_F4
    pea %pc@(ONEBITPROC)
    jsr @(0x1730,%za0)@(0x0)	| 4083715E
STSEARCHTAB_F4:         /* the indexed converter (0x1CAC) */
    moveal 0x1cac,%a0
    movel %a0,%fp@(-552)
    jbra ONEBITPROC_4A
    .short  0x0000	| 4083716E
ONEBITPROC:             /* color search proc for 1-bit destinations: an RGB is black (1) when its luminance, about (5R + 9G + 2B) / 16, is below half */
    st %sp@(12)
    moveal %sp@(8),%a0
    moveq #0,%d0
    moveq #0,%d1
    movew %a0@,%d0
    moveal %d0,%a1
    movew %a0@(2),%d1
    addl %d0,%d1
    movew %a0@(4),%d0
    addl %d0,%d1
    addl %d0,%d1
    lsrl #2,%d1
    addl %a1,%d1
    movew %a0@(2),%d0
    addl %d0,%d1
    addl %d0,%d1
    lsrl #2,%d1
    moveal %sp@(4),%a1
    clrl %a1@
    tstw %d1
    jbmi ONEBITPROC_38
    addql #1,%a1@
ONEBITPROC_38:          /* return */
    rtd #8
ONEBITPROC_3C:          /* (StretchBits, continued) the depth conversion proc from the expansion table (0x1AAC) */
    moveal 0x1aac,%a0
    addal %a0@(0x0,%d4:w:4),%a0
    movel %a0,%fp@(-552)
    jbra ONEBITPROC_62

ONEBITPROC_4A:          /* foreground not black: fg long all ones; background not white: bk long zero */
    tstb %fp@(-259)
    jbne ONEBITPROC_58
    movel #-1,%fp@(-160)
ONEBITPROC_58:          /* background */
    tstb %fp@(-260)
    jbne ONEBITPROC_62
    clrl %fp@(-164)
ONEBITPROC_62:          /* allocate the row buffers on the stack (fp-132 counts the stack left): the source row */
    moveq #0,%d0
    movew %fp@(-522),%d0
    lsll %d3,%d0
    subql #1,%d0
    lsrl #5,%d0
    movew %d0,%fp@(-492)
    subl %d0,%fp@(-132)
    jbpl ONEBITPROC_7E
    jsr @(0x1c5c,%za0)@(0)	| 408371E8
ONEBITPROC_7E:          /* source buffer */
    clrl %sp@-
ONEBITPROC_80:          /* clear it */
    clrl %sp@-
    dbf %d0,ONEBITPROC_80
    movel %sp,%fp@(-468)
    movel %sp,%fp@(-472)
    movel %sp,%fp@(-476)
    moveq #0,%d0
    movew %fp@(-518),%d0
    cmpw %fp@(-522),%d0
    jbeq ONEBITPROC_C4
    lsll %d3,%d0
    subql #1,%d0
    lsrl #5,%d0
    movew %d0,%fp@(-498)
    subl %d0,%fp@(-132)
    jbpl ONEBITPROC_B4
    jsr @(0x1c5c,%za0)@(0)	| 4083721E
ONEBITPROC_B4:          /* horizontal stretch buffer (source and destination widths differ) */
    clrl %sp@-
ONEBITPROC_B6:          /* clear it */
    clrl %sp@-
    dbf %d0,ONEBITPROC_B6
    movel %sp,%fp@(-472)
    movel %sp,%fp@(-476)
ONEBITPROC_C4:          /* a mask bitmap (fp+44)? its sizes and buffers */
    clrl %fp@(-528)
    clrl %fp@(-532)
    movel %fp@(44),%d0
    jbeq ONEBITPROC_16C
    moveal %fp@(32),%a0
    movew %a0@(4),%d1
    subw %a0@,%d1
    swap %d1
    movew %a0@(6),%d1
    subw %a0@(2),%d1
    movew %a3@(4),%d0
    subw %a3@,%d0
    swap %d0
    movew %a3@(6),%d0
    subw %a3@(2),%d0
    moveml %d3-%d4,%sp@-
    movel %d0,%fp@(-528)
    movel %d1,%fp@(-532)
    jsr @(0x1a90,%za0)@(0)	| 40837274
    movel %a0,%fp@(-544)
    movew %d0,%fp@(-548)
    moveml %sp@+,%d3-%d4
    moveq #0,%d0
    movew %fp@(-530),%d0
    subqw #1,%d0
    lsrw #5,%d0
    movew %d0,%fp@(-494)
    subl %d0,%fp@(-132)
    jbpl ONEBITPROC_130
    jsr @(0x1c5c,%za0)@(0)	| 4083729A
ONEBITPROC_130:         /* mask source row buffer */
    clrl %sp@-
ONEBITPROC_132:         /* clear it */
    clrl %sp@-
    dbf %d0,ONEBITPROC_132
    movel %sp,%fp@(-488)
    movel %sp,%fp@(-32)
    moveq #0,%d0
    movew %fp@(-526),%d0
    cmpw %fp@(-530),%d0
    jbeq ONEBITPROC_16C
    subqw #1,%d0
    lsrw #5,%d0
    movew %d0,%fp@(-496)
    subl %d0,%fp@(-132)
    jbpl ONEBITPROC_160
    jsr @(0x1c5c,%za0)@(0)	| 408372CA
ONEBITPROC_160:         /* mask stretch buffer */
    clrl %sp@-
ONEBITPROC_162:         /* clear it */
    clrl %sp@-
    dbf %d0,ONEBITPROC_162
    movel %sp,%fp@(-32)
ONEBITPROC_16C:         /* a depth conversion? its buffer */
    tstl %fp@(-552)
    jbeq ONEBITPROC_19C
    moveq #0,%d0
    movew %fp@(-518),%d0
    subql #1,%d0
    lsll %d4,%d0
    lsrl #5,%d0
    movew %d0,%fp@(-500)
    subl %d0,%fp@(-132)
    jbpl ONEBITPROC_18E
    jsr @(0x1c5c,%za0)@(0)	| 408372F8
ONEBITPROC_18E:         /* conversion buffer */
    clrl %sp@-
    clrl %sp@-
ONEBITPROC_192:         /* clear it */
    clrl %sp@-
    dbf %d0,ONEBITPROC_192
    movel %sp,%fp@(-476)
ONEBITPROC_19C:         /* the destination row: first long aligned, width in longs (fp-16) */
    moveal %fp@(28),%a0
    movew %a0@(2),%d1
    subw %a5@(8),%d1
    lsll %d4,%d1
    andiw #-32,%d1
    asrl %d4,%d1
    addw %a5@(8),%d1
    movew %d1,%fp@(-14)
    moveq #0,%d0
    movew %fp@(-110),%d0
    subw %d1,%d0
    movew %d0,%fp@(-16)
    movew %d0,%d1
    extl %d1
    lsll %d4,%d1
    subql #1,%d1
    lsrl #5,%d1
    addql #1,%d1
    btst #5,%fp@(-151)
    jbne ONEBITPROC_1DC
    movew %d1,%fp@(-16)
ONEBITPROC_1DC:         /* the region mask buffer */
    lsrw #5,%d0
    addqw #1,%d0
    lslw %d4,%d0
    subl %d0,%fp@(-132)
    jbpl ONEBITPROC_1EE
    jsr @(0x1c5c,%za0)@(0)	| 40837358
ONEBITPROC_1EE:         /* region buffer */
    clrl %sp@-
    clrl %sp@-
ONEBITPROC_1F2:         /* clear it */
    clrl %sp@-
    dbf %d0,ONEBITPROC_1F2
    movel %sp,%fp@(-8)
    movel 0x1c5c,%fp@(-128)
    clrl %fp@(-12)
    movel %fp@(10),%sp@-
    movel %fp@(14),%sp@-
    movel %fp@(18),%sp@-
    movel #2,%sp@-
    jsr @(0x1a34,%za0)@(0)	| 40837388
    movew %fp@(-152),%d0
    btst #5,%d0
    jbeq ONEBITPROC_270
    cmpiw #64,%d0
    jbgt DONESTRETCH
    btst #3,%d0
    jbne DONESTRETCH
    andiw #23,%d0
    bclr #4,%d0
    jbeq ONEBITPROC_24A
    subqw #2,%d0
    jbne DONESTRETCH
    addqw #8,%d0
ONEBITPROC_24A:         /* arithmetic modes: indexed destinations use the 0x1BCC table (+4); 16-bit 0x1C98, 32-bit 0x1C9C */
    cmpiw #16,%fp@(-212)
    jbge ONEBITPROC_256
    addqw #4,%d0
    jbra ONEBITPROC_280
ONEBITPROC_256:         /* 16-bit */
    jbne ONEBITPROC_26A
    moveal 0x1c98,%a0
ONEBITPROC_25C:         /* the mode loop (fp-536) */
    bclr #4,%d0
    addal %a0@(0x0,%d0:w:4),%a0
    movel %a0,%fp@(-536)
    jbra ONEBITPROC_28A
ONEBITPROC_26A:         /* 32-bit */
    moveal 0x1c9c,%a0
    jbra ONEBITPROC_25C
ONEBITPROC_270:         /* boolean modes 0..7 */
    movel %fp@(-456),%d7
    bclr #2,%d0
    cmpiw #7,%d0
    jbgt DONESTRETCH
ONEBITPROC_280:         /* the mode loop from the 0x1BCC table */
    lea 0x1bcc,%a0
    movel %a0@(0x0,%d0:w:4),%fp@(-536)
ONEBITPROC_28A:         /* a mask: its first long and bit offset */
    tstl %fp@(44)
    jbeq ONEBITPROC_2C6
    movew %fp@(-452),%d3
    lea %fp@(-440),%a2
    movel %fp@(-448),%d2
    moveal %fp@(32),%a0
    movew %a0@(2),%d1
    subw %a2@(8),%d1
    extl %d1
    moveq #31,%d5
    andl %d1,%d5
    movel %d5,%fp@(-568)
    movew %a0@,%d0
    subw %a2@(6),%d0
    mulsw %d2,%d0
    addl %a2@,%d0
    subl %d5,%d1
    asrl #3,%d1
    addl %d1,%d0
    movel %d0,%fp@(-508)
ONEBITPROC_2C6:         /* the source: rows to do (fp-554), first long and bit offset; the destination's first long (fp-512) */
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 40837438
    moveb %d0,%fp@(-258)
    movew %fp@(-450),%d3
    lea %fp@(-360),%a2
    movel %fp@(-444),%d2
    movew %a2@(10),%d1
    subw %a2@(6),%d1
    movew %d1,%fp@(-554)
    moveal %fp@(36),%a0
    movew %a0@(2),%d1
    subw %a2@(8),%d1
    extl %d1
    lsll %d3,%d1
    moveq #31,%d5
    andl %d1,%d5
    movel %d5,%fp@(-560)
    movew %a0@,%d0
    subw %a2@(6),%d0
    mulsw %d2,%d0
    addl %a2@,%d0
    subl %d5,%d1
    asrl #3,%d1
    addl %d1,%d0
    movel %d0,%fp@(-504)
    movew %fp@(-118),%d4
    movel %fp@(-124),%d2
    moveal %fp@(28),%a0
    movew %a0@,%fp@(-4)
    movew %a0@(2),%d1
    subw %a5@(8),%d1
    extl %d1
    lsll %d4,%d1
    moveq #31,%d6
    andl %d1,%d6
    negl %d6
    movel %d6,%fp@(-564)
    movel %d6,%d0
    asrl %d4,%d0
    movel %d0,%fp@(-36)
    movew %fp@(-116),%d0
    subw %a5@(6),%d0
    mulsw %d2,%d0
    addl %a5@,%d0
    asrl #5,%d1
    lsll #2,%d1
    addl %d1,%d0
    movel %d0,%fp@(-512)
    jsr @(0x1c64,%za0)@(0)	| 408374CA

/*
 STSCANLOOP: StretchBits' row loop. For each destination row: read the source row(s) into the
 buffer (several source rows per destination row when shrinking vertically: combined by or
 for 1-bit, by the larger pixel for indexed, averaged for 32-bit when fp-682 is set), the
 mask rows likewise, then stretch horizontally (proc at fp-540, mask at fp-544), convert
 the depth (fp-552), colorize, and draw through the mode loop (fp-536) inside the region
 mask. 8-bit to 8-bit and 8-bit to 1-bit copies with clipping have fast paths (CB8TO8CLIP,
 ANDY, CB8TO1CLIP).
*/
trap_STSCANLOOP:
STSCANLOOP:
    tstb %fp@(-693)
    jbeq STSCANLOOP_44
    cmpiw #8,%fp@(-212)
    jbne STSCANLOOP_32
    cmpiw #8,%fp@(-328)
    jbeq CB8TO8CLIP
    cmpiw #1,%fp@(-328)
    jbne STSCANLOOP_44
    moveal 0x1aac,%a0
    addal %a0@(12),%a0
    cmpal %fp@(-552),%a0
    jbne STSCANLOOP_44
    jbra ANDY
STSCANLOOP_32:          /* 1-bit destination from 8-bit: CB8TO1CLIP */
    cmpiw #1,%fp@(-212)
    jbne STSCANLOOP_44
    cmpiw #8,%fp@(-328)
    jbeq CB8TO1CLIP
STSCANLOOP_44:          /* the vertical error term (fp-574): minus half the source height */
    movew %fp@(-524),%d0
    lsrw #1,%d0
    negw %d0
    movew %d0,%fp@(-574)
STSCANLOOP_50:          /* next source row: none left: done; averaging? STSCANLOOP_160 */
    tstw %fp@(-554)
    jble DONESTRETCH
    tstb %fp@(-682)
    jbne STSCANLOOP_160
    moveal %fp@(-504),%a0
    moveal %fp@(-468),%a1
    movew %fp@(-492),%d1
    movel %fp@(-560),%d5
STSCANLOOP_70:          /* copy the source row into the buffer, aligned */
    bfextu %a0@,%d5,0,%d0
    addqw #4,%a0
    movel %d0,%a1@+
    dbf %d1,STSCANLOOP_70
    tstl %fp@(44)
    jbeq STSCANLOOP_A6
    moveal %fp@(-508),%a0
    moveal %fp@(-488),%a1
    movew %fp@(-494),%d1
    movel %fp@(-568),%d3
STSCANLOOP_92:          /* the mask row likewise */
    bfextu %a0@,%d3,0,%d0
    addqw #4,%a0
    movel %d0,%a1@+
    dbf %d1,STSCANLOOP_92
    movel %fp@(-448),%d0
    addl %d0,%fp@(-508)
STSCANLOOP_A6:          /* next source row; more source rows for this destination row? combine them */
    movel %fp@(-444),%d2
    addl %d2,%fp@(-504)
    subqw #1,%fp@(-554)
    movew %fp@(-520),%d0
    addw %d0,%fp@(-574)
    jbgt STSCANLOOP_2DA
    tstw %fp@(-450)
    jbeq STSCANLOOP_280
STSCANLOOP_C6:          /* indexed shrink: keep the larger pixel value of the rows */
    tstw %fp@(-554)
    jble STSCANLOOP_2DA
    moveal %fp@(-504),%a0
    moveal %fp@(-468),%a1
    movew %fp@(-492),%d6
    movew %fp@(-328),%d3
    moveq #0,%d4
STSCANLOOP_E0:          /* next long */
    bfextu %a0@,%d5,0,%d0
    movel %a1@,%d1
STSCANLOOP_E6:          /* each pixel: the larger */
    bfextu %d0,%d4,%d3,%d2
    bfextu %d1,%d4,%d3,%d7
    cmpl %d7,%d2
    jble STSCANLOOP_F6
    bfins %d2,%d1,%d4,%d3
STSCANLOOP_F6:          /* next pixel */
    addw %d3,%d4
    andiw #31,%d4
    jbne STSCANLOOP_E6
    addqw #4,%a0
    movel %d1,%a1@+
    dbf %d6,STSCANLOOP_E0
    tstl %fp@(44)
    jbeq STSCANLOOP_130
    moveal %fp@(-508),%a0
    moveal %fp@(-488),%a1
    movew %fp@(-494),%d1
    movel %fp@(-568),%d2
STSCANLOOP_11C:         /* the mask row: or */
    bfextu %a0@,%d2,0,%d0
    addqw #4,%a0
    orl %d0,%a1@+
    dbf %d1,STSCANLOOP_11C
    movel %fp@(-448),%d0
    addl %d0,%fp@(-508)
STSCANLOOP_130:         /* next source row */
    movel %fp@(-444),%d0
    addl %d0,%fp@(-504)
    subqw #1,%fp@(-554)
    movew %fp@(-520),%d0
    addw %d0,%fp@(-574)
    jble STSCANLOOP_C6
    movel %fp@(-560),%d5
    movel %fp@(-564),%d6
    movel %fp@(-456),%d7
    jbra STSCANLOOP_2DA
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40837626
STSCANLOOP_160:         /* averaging (32-bit shrink): clear the mask buffer */
    moveq #0,%d1
    tstl %fp@(44)
    jbeq STSCANLOOP_176
    moveal %fp@(-488),%a0
    movew %fp@(-494),%d0
STSCANLOOP_170:         /* clear */
    movel %d1,%a0@+
    dbf %d0,STSCANLOOP_170
STSCANLOOP_176:         /* d4 = rows summed; one row only: copy it */
    moveq #0,%d4
    movew %fp@(-574),%d0
    addw %fp@(-520),%d0
    jbgt STSCANLOOP_1CA
    cmpiw #1,%fp@(-554)
    jbeq STSCANLOOP_1CA
    movew %fp@(-684),%d0
    moveal %fp@(-688),%a0
STSCANLOOP_192:         /* clear the sum buffer (16 bits per component) */
    movel %d1,%a0@+
    dbf %d0,STSCANLOOP_192
STSCANLOOP_198:         /* add the source row's R, G, B to the sums */
    tstw %fp@(-554)
    blew STSCANLOOP_20A
    moveal %fp@(-504),%a0
    moveal %fp@(-688),%a1
    movew %fp@(-492),%d6
    addqw #1,%d4
    moveq #0,%d1
    moveq #0,%d2
    moveq #0,%d3
STSCANLOOP_1B4:         /* each pixel */
    movel %a0@+,%d0
    moveb %d0,%d3
    lsrl #8,%d0
    moveb %d0,%d2
    lsrl #8,%d0
    moveb %d0,%d1
    addw %d1,%a1@+
    addw %d2,%a1@+
    addw %d3,%a1@+
    dbf %d6,STSCANLOOP_1B4
STSCANLOOP_1CA:         /* the mask row: or */
    tstl %fp@(44)
    jbeq STSCANLOOP_1F4
    moveal %fp@(-508),%a0
    moveal %fp@(-488),%a1
    movew %fp@(-494),%d1
    movel %fp@(-568),%d2
STSCANLOOP_1E0:         /* or */
    bfextu %a0@,%d2,0,%d0
    addqw #4,%a0
    orl %d0,%a1@+
    dbf %d1,STSCANLOOP_1E0
    movel %fp@(-448),%d0
    addl %d0,%fp@(-508)
STSCANLOOP_1F4:         /* next source row */
    movel %fp@(-444),%d0
    addl %d0,%fp@(-504)
    subqw #1,%fp@(-554)
    movew %fp@(-520),%d0
    addw %d0,%fp@(-574)
    jble STSCANLOOP_198
STSCANLOOP_20A:         /* the sums divided by the row count */
    moveal %fp@(-468),%a1
    moveal %fp@(-688),%a0
    movew %fp@(-492),%d6
    cmpiw #2,%d4
    jblt STSCANLOOP_260
    jbeq STSCANLOOP_242
STSCANLOOP_21E:         /* three or more rows: divide */
    moveq #0,%d1
    movew %a0@+,%d1
    divuw %d4,%d1
    movew %d1,%d0
    lsll #8,%d0
    moveq #0,%d1
    movew %a0@+,%d1
    divuw %d4,%d1
    moveb %d1,%d0
    lsll #8,%d0
    moveq #0,%d1
    movew %a0@+,%d1
    divuw %d4,%d1
    moveb %d1,%d0
    movel %d0,%a1@+
    dbf %d6,STSCANLOOP_21E
    jbra STSCANLOOP_270
STSCANLOOP_242:         /* two rows: halve */
    movew %a0@+,%d1
    lsrw #1,%d1
    movew %d1,%d0
    lsll #8,%d0
    movew %a0@+,%d1
    lsrw #1,%d1
    moveb %d1,%d0
    lsll #8,%d0
    movew %a0@+,%d1
    lsrw #1,%d1
    moveb %d1,%d0
    movel %d0,%a1@+
    dbf %d6,STSCANLOOP_242
    jbra STSCANLOOP_270
STSCANLOOP_260:         /* one row: copy it */
    movel %fp@(-444),%d0
    moveal %fp@(-504),%a0
    subal %d0,%a0
STSCANLOOP_26A:         /* copy */
    movel %a0@+,%a1@+
    dbf %d6,STSCANLOOP_26A
STSCANLOOP_270:         /* restore the loop registers */
    movel %fp@(-560),%d5
    movel %fp@(-564),%d6
    movel %fp@(-456),%d7
    jbra STSCANLOOP_2DA
    .short  0x0000	| 4083774E
STSCANLOOP_280:         /* 1-bit shrink: or the rows together */
    tstw %fp@(-554)
    jble STSCANLOOP_2DA
    moveal %fp@(-504),%a0
    moveal %fp@(-468),%a1
    movew %fp@(-492),%d1
STSCANLOOP_292:         /* or */
    bfextu %a0@,%d5,0,%d0
    addqw #4,%a0
    orl %d0,%a1@+
    dbf %d1,STSCANLOOP_292
    tstl %fp@(44)
    jbeq STSCANLOOP_2C8
    moveal %fp@(-508),%a0
    moveal %fp@(-488),%a1
    movew %fp@(-494),%d1
    movel %fp@(-568),%d3
STSCANLOOP_2B4:         /* the mask row: or */
    bfextu %a0@,%d3,0,%d0
    addqw #4,%a0
    orl %d0,%a1@+
    dbf %d1,STSCANLOOP_2B4
    movel %fp@(-448),%d0
    addl %d0,%fp@(-508)
STSCANLOOP_2C8:         /* next source row */
    addl %d2,%fp@(-504)
    subqw #1,%fp@(-554)
    movew %fp@(-520),%d0
    addw %d0,%fp@(-574)
    jble STSCANLOOP_280
STSCANLOOP_2DA:         /* rows above the destination's visible part are skipped */
    movew %fp@(-4),%d0
    cmpw %fp@(-116),%d0
    jbge STSCANLOOP_2F6
    addqw #1,%fp@(-4)
    movew %fp@(-524),%d0
    subw %d0,%fp@(-574)
    jbge STSCANLOOP_2DA
    jblt STSCANLOOP_50
STSCANLOOP_2F6:         /* stretch the row horizontally (fp-540) */
    movew %fp@(-518),%d0
    cmpw %fp@(-522),%d0
    jbeq STSCANLOOP_320
    movew %fp@(-498),%d0
    moveal %fp@(-468),%a0
    moveal %fp@(-472),%a1
    lea %a1@(0x4,%d0:w:4),%a2
    movew %fp@(-546),%d4
    movew %fp@(-328),%d5
    moveal %fp@(-540),%a3
    moveq #0,%d0
    jsr %a3@
STSCANLOOP_320:         /* stretch the mask row (fp-544) */
    movew %fp@(-526),%d0
    cmpw %fp@(-530),%d0
    jbeq STSCANLOOP_348
    movew %fp@(-496),%d0
    moveal %fp@(-488),%a0
    moveal %fp@(-32),%a1
    lea %a1@(0x4,%d0:w:4),%a2
    movew %fp@(-548),%d4
    moveq #1,%d5
    moveal %fp@(-544),%a3
    moveq #0,%d0
    jsr %a3@
STSCANLOOP_348:         /* convert the depth (fp-552) with the color search table (fp-572) */
    movel %fp@(-552),%d1
    jbeq STSCANLOOP_370
    movew %fp@(-328),%d3
    movew %fp@(-212),%d4
    moveal %fp@(-472),%a0
    moveal %fp@(-476),%a1
    movew %fp@(-500),%d0
    lea %a1@(0x4,%d0:w:4),%a2
    moveal %d1,%a3
    moveal %fp@(-572),%a4
    moveq #0,%d0
    jsr %a3@
STSCANLOOP_370:         /* colorize: arithmetic modes with fg/bk: the row through the fg/bk longs */
    movel %fp@(-160),%d3
    movel %fp@(-164),%d4
    btst #5,%fp@(-151)
    jbeq STSCANLOOP_3BA
    moveq #0,%d7
    movew %fp@(-212),%d7
    moveq #32,%d5
    divuw %d7,%d5
    tstw %fp@(-260)
    jbeq STSCANLOOP_3A6
    moveal %fp@(-476),%a3
    movew %fp@(-16),%d2
STSCANLOOP_398:         /* colorize */
    movel %a3@,%d0
    andl %d3,%d0
    notl %a3@
    andl %d4,%a3@
    orl %d0,%a3@+
    subw %d5,%d2
    jbge STSCANLOOP_398
STSCANLOOP_3A6:         /* the color table for the mode loop; transparent: the background color */
    moveal %fp@(-264),%a5
    cmpiw #36,%fp@(-152)
    jbne STSCANLOOP_3BA
    bfextu %fp@(-276),0,%d7,%d0
    moveal %d0,%a5
STSCANLOOP_3BA:         /* above the visible rows? skip; else set up the mode loop registers */
    movew %fp@(-4),%d0
    cmpw %fp@(-116),%d0
    jblt STSCANLOOP_40E
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 40837894
    moveal %fp@(-476),%a3
    moveal %fp@(-512),%a4
    moveal %fp@(-8),%a2
    movew %fp@(-16),%d2
    moveal %fp@(-536),%a0
    btst #5,%fp@(-151)
    jbeq STSCANLOOP_3FE
    movel %fp@(-276),%d4
    cmpiw #36,%fp@(-152)
    jbeq STSCANLOOP_3F6
    movew %fp@(-270),%d5
STSCANLOOP_3F6:         /* arithmetic: pixel offsets */
    moveq #0,%d3
    movel %fp@(-564),%d6
    subl %d7,%d6
STSCANLOOP_3FE:         /* the region's first row long below the destination? skip to it */
    cmpal %fp@(-244),%a4
    jbcs STSCANLOOP_432
STSCANLOOP_404:         /* run the mode loop (returns to STSCANLOOP_406) */
    jmp %a0@

STSCANLOOP_406:         /* next destination row */
    movel %fp@(-124),%d0
    addl %d0,%fp@(-512)
STSCANLOOP_40E:         /* last row: done; else next source row(s), or repeat the same row when stretching */
    addqw #1,%fp@(-4)
    movew %fp@(-4),%d0
    cmpw %fp@(-112),%d0
    jbeq DONESTRETCH
    movew %fp@(-524),%d0
    subw %d0,%fp@(-574)
    jblt STSCANLOOP_50
    tstb %fp@(-165)
    jbne STSCANLOOP_348
    jbra STSCANLOOP_3BA
STSCANLOOP_432:         /* skip the longs left of the region */
    movel %fp@(-244),%d1
    btst #5,%fp@(-151)
    jbeq STSCANLOOP_450
STSCANLOOP_43E:         /* arithmetic: by pixel */
    lea %a4@(0x0,%d3:w),%a1
    cmpl %a1,%d1
    jbls STSCANLOOP_404
    subqw #1,%d2
    jbmi STSCANLOOP_406
    addl %d7,%d6
    addl %d7,%d3
    jbra STSCANLOOP_43E
STSCANLOOP_450:         /* boolean: by long */
    lea %a4@(4),%a1
    cmpl %a1,%d1
    jbls STSCANLOOP_404
    subqw #1,%d2
    jbmi STSCANLOOP_406
    addql #4,%a2
    addql #4,%a3
    addql #4,%a4
    jbra STSCANLOOP_450

DONESTRETCH:            /* done: QDErr (0xD6E) = 0 */
    clrw QDErr
DONESTRETCH_4:          /* the result */
    moveb %fp@(-258),%d0
    jsr @(0x574,%za0)@(0x0)	| 4083793C
DONESTRETCH_E:          /* restore a5; hilite off; the stack; a borrowed stack handle: restore StackLowPoint and HighHeapMark */
    moveal %fp@(-464),%a5
    tstb %fp@(-576)
    jbeq DONESTRETCH_1E
    jsr @(0xf4c,%za0)@(0)	| 4083794C
DONESTRETCH_1E:         /* hilite off, restore the stack */
    bset #7,HiliteMode
    moveal %fp@(-460),%sp
    movel %fp@(-692),%d0
    jbeq DONESTRETCH_40
    moveal %d0,%a0
    jsr @(0x1a78,%za0)@(0)	| 40837964
    movel %sp,StackLowPoint
    movel %fp@(-708),HighHeapMark
DONESTRETCH_40:         /* return */
    moveml %sp@+,%d0-%d7/%a1-%a5
    unlk %fp
    rtd #44
    .short  0x0000	| 4083797E

trap_STNOSTACK:
STNOSTACK:              /* called when a buffer did not fit on the stack: use a 64K block as the stack (StackLowPoint, HighHeapMark moved), or fail with QDErr -149 */
    tstl %fp@(-132)
    jbpl DONESTRETCH_E
    moveml %d0-%d3/%a0-%a2,%sp@-
    tstl %fp@(-692)
    jbne STNOSTACK_58
    moveq #1,%d0
    swap %d0
    jsr @(0x1a70,%za0)@(0)	| 40837994
    movel %d0,%d2
    jbeq STNOSTACK_58
    movel %a0,%fp@(-692)
    subil #1600,%d2
    asrl #2,%d2
    addl %d2,%fp@(-132)
    jbmi STNOSTACK_58
    clrl StackLowPoint
    moveal %sp,%a2
    movel HighHeapMark,%fp@(-708)
    moveal %a0@,%a0
    exg %d0,%a0
    jsr @(0x644,%za0)@(0x0)	| 408379C0
    movel %d0,HighHeapMark
    addal %d0,%a0
    movel %sp@(28),%a0@-
    moveal %a0,%sp
    moveml %a2@,%d0-%d3/%a0-%a2
    rts
STNOSTACK_58:           /* no memory: QDErr -149, give up */
    movew #-149,QDErr
    jbra DONESTRETCH_E
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408379E2

trap_STMASK0:
STMASK0:                /* StretchBits srcCopy through the mask: each long (source shifted, inverted for not modes) */
    bfextu %a3@,%d6,0,%d0
    addqw #4,%a3
    movel %a2@+,%d1
    eorl %d7,%d0
    movel %d0,%d5
    andl %d3,%d0
    notl %d5
    andl %d4,%d5
    orl %d5,%d0
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    dbf %d2,trap_STMASK0
    jbra STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40837A16

trap_STMASK1:
STMASK1:                /* StretchBits srcOr through the mask */
    bfextu %a3@,%d6,0,%d0
    addqw #4,%a3
    eorl %d7,%d0
    movel %a2@+,%d1
    andl %d1,%d0
    movel %d0,%d1
    andl %d3,%d1
    notl %d0
    andl %a4@,%d0
    orl %d1,%d0
    movel %d0,%a4@+
    dbf %d2,trap_STMASK1
    jbra STSCANLOOP_406

trap_STMASK2:
STMASK2:                /* StretchBits srcXor through the mask */
    bfextu %a3@,%d6,0,%d0
    addqw #4,%a3
    eorl %d7,%d0
    andl %a2@+,%d0
    eorl %d0,%a4@+
    dbf %d2,trap_STMASK2
    jbra STSCANLOOP_406
    .long   0x00000000, 0x00000000, 0x00000000	| 40837A54

trap_STMASK3:
STMASK3:                /* StretchBits srcBic through the mask */
    bfextu %a3@,%d6,0,%d0
    addqw #4,%a3
    eorl %d7,%d0
    movel %a2@+,%d1
    andl %d1,%d0
    movel %d0,%d1
    andl %d4,%d1
    notl %d0
    andl %a4@,%d0
    orl %d1,%d0
    movel %d0,%a4@+
    dbf %d2,trap_STMASK3
    jbra STSCANLOOP_406

/* STADDOVER: arithmetic transfer mode addover (StretchBits). */
trap_STADDOVER:
STADDOVER:
    addl %d7,%d6
    bfextu %a2@,%d3,%d7,%d0
    jbeq STADDOVER_38
    bfextu %a3@,%d6,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a0
    bfextu %a4@,%d3,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a1
    movew %a0@+,%d0
    addw %a1@+,%d0
    asll %d5,%d0
    movew %a0@+,%d0
    addw %a1@+,%d0
    asll %d5,%d0
    movew %a0@+,%d0
    addw %a1@+,%d0
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a4@,%d3,%d7
STADDOVER_38:           /* next pixel; end of the row: back to STSCANLOOP */
    addl %d7,%d3
    dbf %d2,trap_STADDOVER
    jbra STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40837AC2

/* STADDPIN: arithmetic transfer mode addpin (StretchBits). */
trap_STADDPIN:
STADDPIN:
    addl %d7,%d6
    bfextu %a2@,%d3,%d7,%d0
    jbeq STADDPIN_5C
    bfextu %a3@,%d6,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a0
    bfextu %a4@,%d3,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a1
    movew %a0@+,%d0
    addw %a1@+,%d0
    jbcs STADDPIN_24
    cmpw %fp@(-246),%d0
    jbls STADDPIN_28
STADDPIN_24:            /* pinned at the pin value */
    movew %fp@(-246),%d0
STADDPIN_28:            /* pack the component into the inverse table index */
    asll %d5,%d0
    movew %a0@+,%d0
    addw %a1@+,%d0
    jbcs STADDPIN_36
    cmpw %fp@(-248),%d0
    jbls STADDPIN_3A
STADDPIN_36:            /* pinned at the pin value */
    movew %fp@(-248),%d0
STADDPIN_3A:            /* pack the component into the inverse table index */
    asll %d5,%d0
    movew %a0@+,%d0
    addw %a1@+,%d0
    jbcs STADDPIN_48
    cmpw %fp@(-250),%d0
    jbls STADDPIN_4C
STADDPIN_48:            /* pinned at the pin value */
    movew %fp@(-250),%d0
STADDPIN_4C:            /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a4@,%d3,%d7
STADDPIN_5C:            /* next pixel; end of the row: back to STSCANLOOP */
    addl %d7,%d3
    dbf %d2,trap_STADDPIN
    jbra STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40837B36

/* STSUBOVER: arithmetic transfer mode subover (StretchBits). */
trap_STSUBOVER:
STSUBOVER:
    addl %d7,%d6
    bfextu %a2@,%d3,%d7,%d0
    jbeq STSUBOVER_38
    bfextu %a3@,%d6,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a0
    bfextu %a4@,%d3,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a1
    movew %a1@+,%d0
    subw %a0@+,%d0
    asll %d5,%d0
    movew %a1@+,%d0
    subw %a0@+,%d0
    asll %d5,%d0
    movew %a1@+,%d0
    subw %a0@+,%d0
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a4@,%d3,%d7
STSUBOVER_38:           /* next pixel; end of the row: back to STSCANLOOP */
    addl %d7,%d3
    dbf %d2,trap_STSUBOVER
    jbra STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40837B82

/* STSUBPIN: arithmetic transfer mode subpin (StretchBits). */
trap_STSUBPIN:
STSUBPIN:
    addl %d7,%d6
    bfextu %a2@,%d3,%d7,%d0
    jbeq STSUBPIN_5C
    bfextu %a3@,%d6,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a0
    bfextu %a4@,%d3,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a1
    movew %a1@+,%d0
    subw %a0@+,%d0
    jbcs STSUBPIN_24
    cmpw %fp@(-246),%d0
    jbcc STSUBPIN_28
STSUBPIN_24:            /* pinned at the pin value */
    movew %fp@(-246),%d0
STSUBPIN_28:            /* pack the component into the inverse table index */
    asll %d5,%d0
    movew %a1@+,%d0
    subw %a0@+,%d0
    jbcs STSUBPIN_36
    cmpw %fp@(-248),%d0
    jbcc STSUBPIN_3A
STSUBPIN_36:            /* pinned at the pin value */
    movew %fp@(-248),%d0
STSUBPIN_3A:            /* pack the component into the inverse table index */
    asll %d5,%d0
    movew %a1@+,%d0
    subw %a0@+,%d0
    jbcs STSUBPIN_48
    cmpw %fp@(-250),%d0
    jbcc STSUBPIN_4C
STSUBPIN_48:            /* pinned at the pin value */
    movew %fp@(-250),%d0
STSUBPIN_4C:            /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a4@,%d3,%d7
STSUBPIN_5C:            /* next pixel; end of the row: back to STSCANLOOP */
    addl %d7,%d3
    dbf %d2,trap_STSUBPIN
    jbra STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40837BF6

/* STMAX: arithmetic transfer mode max (StretchBits). */
trap_STMAX:
STMAX:
    addl %d7,%d6
    bfextu %a2@,%d3,%d7,%d0
    jbeq STMAX_48
    bfextu %a3@,%d6,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a0
    bfextu %a4@,%d3,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a1
    movew %a0@+,%d0
    cmpw %a1@,%d0
    jbcc STMAX_20
    movew %a1@,%d0
STMAX_20:               /* next component */
    addqw #2,%a1
    asll %d5,%d0
    movew %a0@+,%d0
    cmpw %a1@,%d0
    jbcc STMAX_2C
    movew %a1@,%d0
STMAX_2C:               /* next component */
    addqw #2,%a1
    asll %d5,%d0
    movew %a0@+,%d0
    cmpw %a1@,%d0
    jbcc STMAX_38
    movew %a1@,%d0
STMAX_38:               /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a4@,%d3,%d7
STMAX_48:               /* next pixel; end of the row: back to STSCANLOOP */
    addl %d7,%d3
    dbf %d2,trap_STMAX
    jbra STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40837C52

/* STMIN: arithmetic transfer mode min (StretchBits). */
trap_STMIN:
STMIN:
    addl %d7,%d6
    bfextu %a2@,%d3,%d7,%d0
    jbeq STMIN_48
    bfextu %a3@,%d6,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a0
    bfextu %a4@,%d3,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a1
    movew %a0@+,%d0
    cmpw %a1@,%d0
    jbls STMIN_20
    movew %a1@,%d0
STMIN_20:               /* next component */
    addqw #2,%a1
    asll %d5,%d0
    movew %a0@+,%d0
    cmpw %a1@,%d0
    jbls STMIN_2C
    movew %a1@,%d0
STMIN_2C:               /* next component */
    addqw #2,%a1
    asll %d5,%d0
    movew %a0@+,%d0
    cmpw %a1@,%d0
    jbls STMIN_38
    movew %a1@,%d0
STMIN_38:               /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a4@,%d3,%d7
STMIN_48:               /* next pixel; end of the row: back to STSCANLOOP */
    addl %d7,%d3
    dbf %d2,trap_STMIN
    jbra STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40837CB2

/* STAVG: arithmetic transfer mode avg (StretchBits). */
trap_STAVG:
STAVG:
    addl %d7,%d6
    bfextu %a2@,%d3,%d7,%d0
    jbeq STAVG_56
    bfextu %a3@,%d6,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a0
    bfextu %a4@,%d3,%d7,%d0
    lea %a5@(0x0,%d0:w:8),%a1
    moveq #2,%d1
    movew %fp@(-270),%d5
    addw %d5,%d5
    clrw %sp@-
STAVG_22:               /* each of R, G, B: weighted average */
    movew %a0@+,%d0
    muluw %fp@(0xffffffffffffff06,%d1:w:2),%d0
    movew %a1@+,%d4
    muluw %fp@(0xffffffffffffff00,%d1:w:2),%d4
    addl %d4,%d0
    swap %d0
    movew %fp@(-272),%d4
    lsrw %d4,%d0
    lslw %d5,%d0
    orw %d0,%sp@
    subw %fp@(-270),%d5
    dbf %d1,STAVG_22
    movew %sp@+,%d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a4@,%d3,%d7
STAVG_56:               /* next pixel; end of the row: back to STSCANLOOP */
    addl %d7,%d3
    dbf %d2,trap_STAVG
    jbra STSCANLOOP_406

/* STTRANSPARENT: arithmetic transfer mode transparent (StretchBits). */
trap_STTRANSPARENT:
STTRANSPARENT:
    addl %d7,%d6
STTRANSPARENT_2:        /* next pixel: the source pixel; the background color is skipped */
    bfextu %a3@,%d6,0,%d0
    cmpl %d0,%d4
    jbeq STTRANSPARENT_26
    bfextu %a2@,%d3,%d7,%d0
    jbeq STTRANSPARENT_1C
    bfextu %a3@,%d6,%d7,%d0
    cmpal %d0,%a5
    jbeq STTRANSPARENT_1C
    bfins %d0,%a4@,%d3,%d7
STTRANSPARENT_1C:       /* next pixel; end of the row: back to STSCANLOOP */
    addl %d7,%d3
    dbf %d2,trap_STTRANSPARENT
    jbra STSCANLOOP_406
STTRANSPARENT_26:       /* next source long */
    addqw #4,%a3
    addiw #32,%d3
    subw %d5,%d2
    jbge STTRANSPARENT_2
    movel %fp@(-164),%d4
    jbra STSCANLOOP_406
    .long   0x00000000, 0x00000000	| 40837D58

/* STHILITE: arithmetic transfer mode hilite (StretchBits). */
trap_STHILITE:
STHILITE:               /* hilite (StretchBits): background pixels (d4) become the hilite color (d5, fp-280) and back, where the mask and the source are set */
    bfextu %d4,0,%d7,%d4
    bfextu %fp@(-280),0,%d7,%d5
STHILITE_A:             /* next pixel: mask and source set? swap background and hilite */
    addl %d7,%d6
    bfextu %a2@,%d3,%d7,%d0
    jbeq STHILITE_2E
    bfextu %a3@,%d6,%d7,%d0
    jbeq STHILITE_2E
    bfextu %a4@,%d3,%d7,%d0
    cmpl %d4,%d0
    jbne STHILITE_26
    bfins %d5,%a4@,%d3,%d7
    jbra STHILITE_2E
STHILITE_26:            /* hilite color: becomes background */
    cmpl %d5,%d0
    jbne STHILITE_2E
    bfins %d4,%a4@,%d3,%d7
STHILITE_2E:            /* next pixel; end of the row: back to STSCANLOOP */
    addl %d7,%d3
    dbf %d2,STHILITE_A
    jbra STSCANLOOP_406
    .long   0x00000000, 0x00000000	| 40837D98
/* 32-bit StretchBits addOver (STARITH32TAB): each component added, carries dropped */
    bsrw STHILITE_80
    movel #8355711,%d0
    moveal #8421504,%a0
STHILITE_2E_22:         /* (StretchBits 32-bit addOver) next pixel inside the mask */
    tstl %a2@+
    beqs STHILITE_2E_40
    movel %a3@(0x0,%d6:w),%d1
    movel %a0,%d7
    andl %d1,%d7
    andl %d0,%d1
    movel %a1@,%d5
    movel %a0,%d3
    andl %d5,%d3
    andl %d0,%d5
    addl %d1,%d5
    eorl %d7,%d3
    eorl %d3,%d5
    movel %d5,%a1@
STHILITE_2E_40:         /* next pixel; end of row */
    addql #4,%a1
    addql #4,%d6
    dbf %d2,STHILITE_2E_22
    braw STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000	| 40837DDA

STHILITE_80:            /* row set-up: destination a1, source offset 0 */
    moveal %a4,%a1
    moveq #0,%d6
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40837DE6
/* 32-bit StretchBits addPin: each component added and pinned at the pin color */
    .short  0x61EE	| 40837DF0
    moveq #0,%d3
    moveb %fp@(-246),%d3
    swap %d3
    movew %fp@(-248),%d3
    moveb %fp@(-250),%d3
    movel Lo3Bytes,%d1
STHILITE_A6:            /* next pixel: inside the mask? */
    tstl %a2@+
    jbeq STHILITE_E2
    movel %a3@(0x0,%d6:w),%d7
    andl %d1,%d7
    movel %d7,%d0
    movel %a1@,%d5
    andl %d1,%d5
    clrb %d0
    addw %d5,%d0
    jbcs STHILITE_C0
    cmpw %d3,%d0
    jbls STHILITE_C2
STHILITE_C0:            /* pinned */
    movew %d3,%d0
STHILITE_C2:            /* next component */
    moveb %d7,%d0
    addb %d5,%d0
    jbcs STHILITE_CC
    cmpb %d3,%d0
    jbls STHILITE_CE
STHILITE_CC:            /* pinned */
    moveb %d3,%d0
STHILITE_CE:            /* (32-bit addPin) combine the components, pin the result */
    clrw %d5
    addl %d5,%d0
    cmpl %d3,%d0
    jbls STHILITE_E0
    swap %d3
    swap %d0
    movew %d3,%d0
    swap %d0
    swap %d3
STHILITE_E0:            /* store the pixel */
    movel %d0,%a1@
STHILITE_E2:            /* next pixel; end of the row: back to STSCANLOOP */
    addql #4,%a1
    addql #4,%d6
    dbf %d2,STHILITE_A6
    jbra STSCANLOOP_406
    .short  0x0000	| 40837E4E
/* 32-bit StretchBits subOver: each component subtracted, borrows dropped */
    .short  0x618E	| 40837E50
    movel #8355711,%d0
    movel #8421504,%d1
STHILITE_FE:            /* next pixel: inside the mask? */
    tstl %a2@+
    jbeq STHILITE_120
    movel %a3@(0x0,%d6:w),%d7
    movel %d1,%d3
    andl %d7,%d3
    eorl %d1,%d3
    andl %d0,%d7
    movel %a1@,%d5
    movel %d1,%d4
    andl %d5,%d4
    andl %d0,%d5
    orl %d1,%d5
    subl %d7,%d5
    eorl %d3,%d4
    eorl %d4,%d5
    movel %d5,%a1@
STHILITE_120:           /* next pixel; end of the row: back to STSCANLOOP */
    addql #4,%a1
    addql #4,%d6
    dbf %d2,STHILITE_FE
    jbra STSCANLOOP_406
    .long   0x00000000	| 40837E8C
/* 32-bit StretchBits subPin: each component subtracted and pinned */
    jbsr STHILITE_80
    moveq #0,%d3
    moveb %fp@(-246),%d3
    swap %d3
    movew %fp@(-248),%d3
    moveb %fp@(-250),%d3
    movel Lo3Bytes,%d1
STHILITE_148:           /* next pixel: inside the mask? */
    tstl %a2@+
    jbeq STHILITE_184
    movel %a3@(0x0,%d6:w),%d5
    andl %d1,%d5
    movel %a1@,%d7
    andl %d1,%d7
    movel %d7,%d0
    st %d0
    subw %d5,%d0
    jbcs STHILITE_162
    cmpw %d3,%d0
    jbcc STHILITE_164
STHILITE_162:           /* pinned */
    movew %d3,%d0
STHILITE_164:           /* next component */
    moveb %d7,%d0
    subb %d5,%d0
    jbcs STHILITE_16E
    cmpb %d3,%d0
    jbcc STHILITE_170
STHILITE_16E:           /* pinned */
    moveb %d3,%d0
STHILITE_170:           /* (32-bit subPin) combine, pin */
    clrw %d5
    subl %d5,%d0
    cmpl %d3,%d0
    jbge STHILITE_182
    swap %d3
    swap %d0
    movew %d3,%d0
    swap %d0
    swap %d3
STHILITE_182:           /* store the pixel */
    movel %d0,%a1@
STHILITE_184:           /* next pixel; end of the row: back to STSCANLOOP */
    addql #4,%a1
    addql #4,%d6
    dbf %d2,STHILITE_148
    jbra STSCANLOOP_406
/* 32-bit StretchBits addMax: the larger of each component */
    bsrw STHILITE_80
STHILITE_184_10:        /* (32-bit addMax) next pixel inside the mask: the larger of each component */
    tstl %a2@+
    beqs STHILITE_184_38
    movel %a3@(0x0,%d6:w),%d1
    movel %a1@,%d5
    movel %d5,%d0
    cmpw %d1,%d0
    bhis STHILITE_184_24
    movew %d1,%d0
    moveb %d5,%d0
STHILITE_184_24:        /* green */
    cmpb %d1,%d5
    bhis STHILITE_184_2A
    moveb %d1,%d0
STHILITE_184_2A:        /* red */
    swap %d1
    swap %d0
    cmpb %d1,%d0
    bhis STHILITE_184_34
    moveb %d1,%d0
STHILITE_184_34:        /* store */
    swap %d0
    movel %d0,%a1@
STHILITE_184_38:        /* next pixel; end of row */
    addql #4,%a1
    addql #4,%d6
    dbf %d2,STHILITE_184_10
    braw STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40837F28
/* 32-bit StretchBits adMin: the smaller of each component */
    bsrw STHILITE_80
STHILITE_184_50:        /* (32-bit adMin) next pixel inside the mask: the smaller of each component */
    tstl %a2@+
    beqs STHILITE_184_78
    movel %a3@(0x0,%d6:w),%d1
    movel %a1@,%d5
    movel %d5,%d0
    cmpw %d1,%d0
    blss STHILITE_184_64
    movew %d1,%d0
    moveb %d5,%d0
STHILITE_184_64:        /* green */
    cmpb %d1,%d5
    blss STHILITE_184_6A
    moveb %d1,%d0
STHILITE_184_6A:        /* red */
    swap %d1
    swap %d0
    cmpb %d1,%d0
    blss STHILITE_184_74
    moveb %d1,%d0
STHILITE_184_74:        /* store */
    swap %d0
    movel %d0,%a1@
STHILITE_184_78:        /* next pixel; end of row; then the blend set-up */
    addql #4,%a1
    addql #4,%d6
    dbf %d2,STHILITE_184_50
    braw STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40837F68
/* 32-bit StretchBits blend: each component weighted by the op color */
    lea %pc@(STHILITE_184_BA),%a0
    movel %a0,%fp@(-536)
    lea %fp@(-250),%a0
    movew %a0@+,%d3
    cmpw %a0@+,%d3
    bnes STHILITE_184_BA
    cmpw %a0@,%d3
    bnes STHILITE_184_BA
    addqw #1,%d3
    andiw #-2,%d3
    cmpiw #-32768,%d3
    bnes STHILITE_184_BA
    lea %pc@(STHILITE_184_132_1A),%a0	| 40837F92
    movel %a0,%fp@(-536)
    braw STHILITE_184_132_1A	| 40837F9A
STHILITE_184_BA:        /* (32-bit blend) the weights */
    bsrw STHILITE_80
    lea %fp@(-250),%a0
    movel %a0@+,%d1
    movew %a0@,%d0
    moveq #0,%d4
    movel %d4,%d3
    moveal %d4,%a0
STHILITE_184_CC:        /* next pixel inside the mask: same as the last? reuse */
    tstl %a2@+
    beqs STHILITE_184_132
    movel %a3@(0x0,%d6:w),%d7
    movel %a1@,%d5
    cmpl %d3,%d7
    bnes STHILITE_184_DE
    cmpl %a0,%d5
    beqs STHILITE_184_130
STHILITE_184_DE:        /* each component weighted */
    moveq #0,%d3
    moveb %d7,%d3
    swap %d1
    muluw %d1,%d3
    moveq #0,%d4
    moveb %d5,%d4
    negw %d1
    muluw %d1,%d4
    negw %d1
    addl %d3,%d4
    swap %d4
    moveaw %d4,%a0
    movew %d7,%d3
    lsrw #8,%d3
    swap %d1
    muluw %d1,%d3
    movew %d5,%d4
    lsrw #8,%d4
    negw %d1
    muluw %d1,%d4
    negw %d1
    addl %d3,%d4
    swap %d4
    lslw #8,%d4
    addaw %d4,%a0
    moveq #0,%d3
    swap %d7
    moveb %d7,%d3
    muluw %d0,%d3
    moveq #0,%d4
    swap %d5
    moveb %d5,%d4
    negw %d0
    muluw %d0,%d4
    negw %d0
    addl %d3,%d4
    movew %a0,%d4
    swap %d5
    moveal %d5,%a0
    swap %d7
    movel %d7,%d3
STHILITE_184_130:       /* store */
    movel %d4,%a1@
STHILITE_184_132:       /* next pixel; end of row */
    addql #4,%a1
    addql #4,%d6
    dbf %d2,STHILITE_184_CC
    braw STSCANLOOP_406
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40838022
STHILITE_184_132_1A:
    bsrw STHILITE_80	| 40838030
    movel #8355711,%d0
    moveal #65793,%a0
STHILITE_184_132_2A:
    tstl %a2@+	| 40838040
    beqs STHILITE_184_132_48
    movel %a3@(0x0,%d6:w),%d1
    movel %a0,%d3
    andl %d1,%d3
    lsrl #1,%d1
    andl %d0,%d1
    movel %a1@,%d5
    andl %d5,%d3
    lsrl #1,%d5
    andl %d0,%d5
    addl %d5,%d1
    addl %d3,%d1
    movel %d1,%a1@
STHILITE_184_132_48:
    addql #4,%a1	| 4083805E
    addql #4,%d6
    dbf %d2,STHILITE_184_132_2A
    braw STSCANLOOP_406
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083806A
/* 32-bit StretchBits transparent: the source unless it is the background color */
    bsrw STHILITE_80
    movel %fp@(-276),%d5
STHILITE_184_194:       /* (32-bit transparent) next pixel inside the mask: copy unless background */
    tstl %a2@+
    beqs STHILITE_184_1A2
    movel %a3@(0x0,%d6:w),%d1
    cmpl %d1,%d5
    beqs STHILITE_184_1A2
    movel %d1,%a1@
STHILITE_184_1A2:       /* next pixel; end of row */
    addql #4,%a1
    addql #4,%d6
    dbf %d2,STHILITE_184_194
    braw STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40838092
/* 16-bit StretchBits addOver (STARITH16TAB): each 5-bit component added, carries dropped */
    bsrs STHILITE_380
    movew #15855,%d0
    moveaw #16912,%a0
STHILITE_184_1C6:       /* (16-bit addOver) next pixel inside the mask */
    tstw %a2@+
    beqs STHILITE_184_1E4
    movew %a3@(0x0,%d6:w),%d1
    movew %a0,%d7
    andw %d1,%d7
    andw %d0,%d1
    movew %a1@,%d5
    movew %a0,%d3
    andw %d5,%d3
    andw %d0,%d5
    addw %d1,%d5
    eorw %d7,%d3
    eorw %d3,%d5
    movew %d5,%a1@
STHILITE_184_1E4:       /* next pixel; end of row */
    addql #2,%a1
    addql #2,%d6
    dbf %d2,STHILITE_184_1C6
    braw STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408380D4

STHILITE_380:           /* row set-up: destination a1, source offset 0 */
    moveal %a4,%a1
    moveq #0,%d6
    tstw %fp@(-564)
    jbeq STHILITE_38C
    subqw #2,%a3
STHILITE_38C:           /* return */
    rts
    .short  0x0000	| 408380EE
/* 16-bit StretchBits addPin: each component added and pinned at the pin color */
    .short  0x61EE	| 408380F0
    moveq #0,%d3
    moveb %fp@(-246),%d3
    lsrb #3,%d3
    swap %d3
    movew %fp@(-248),%d3
    lsrw #3,%d3
    moveb %fp@(-250),%d3
    lsrb #3,%d3
STHILITE_3A8:           /* next pixel: inside the mask? */
    tstw %a2@+
    jbeq STHILITE_3E8
    moveq #0,%d7
    movew %a3@(0x0,%d6:w),%d7
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    moveq #0,%d5
    movew %a1@,%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    addl %d5,%d7
    movel %d7,%d0
    cmpl %d3,%d0
    jbls STHILITE_3D0
    movel %d3,%d0
STHILITE_3D0:           /* next component */
    movew %d7,%d0
    cmpw %d3,%d0
    jbls STHILITE_3D8
    movew %d3,%d0
STHILITE_3D8:           /* next component */
    moveb %d7,%d0
    cmpb %d3,%d0
    jbls STHILITE_3E0
    moveb %d3,%d0
STHILITE_3E0:           /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a1@
STHILITE_3E8:           /* next pixel; end of the row: back to STSCANLOOP */
    addql #2,%a1
    addql #2,%d6
    dbf %d2,STHILITE_3A8
    jbra STSCANLOOP_406
    .long   0x00000000, 0x00000000, 0x00000000	| 40838154
/* 16-bit StretchBits subOver: each component subtracted, borrows dropped */
    bsrw STHILITE_380
    movew #15855,%d0
    movew #16912,%d1
STHILITE_3E8_24:        /* (16-bit subOver) next pixel inside the mask */
    tstw %a2@+
    beqs STHILITE_3E8_46
    movew %a3@(0x0,%d6:w),%d7
    movew %d1,%d3
    andw %d7,%d3
    eorw %d1,%d3
    andw %d0,%d7
    movew %a1@,%d5
    movew %d1,%d4
    andw %d5,%d4
    andw %d0,%d5
    orw %d1,%d5
    subw %d7,%d5
    eorw %d3,%d4
    eorw %d4,%d5
    movew %d5,%a1@
STHILITE_3E8_46:        /* next pixel; end of row */
    addql #2,%a1
    addql #2,%d6
    dbf %d2,STHILITE_3E8_24
    braw STSCANLOOP_406
    .short  0x0000, 0x0000, 0x0000	| 4083819A
/* 16-bit StretchBits subPin: each component subtracted and pinned */
    jbsr STHILITE_380
    moveq #0,%d3
    moveb %fp@(-246),%d3
    lsrb #3,%d3
    swap %d3
    movew %fp@(-248),%d3
    lsrw #3,%d3
    moveb %fp@(-250),%d3
    lsrb #3,%d3
    movel #8421504,%d1
    addl %d1,%d3
STHILITE_462:           /* next pixel: inside the mask? */
    tstw %a2@+
    jbeq STHILITE_4A4
    moveq #0,%d5
    movew %a3@(0x0,%d6:w),%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    moveq #0,%d7
    movew %a1@,%d7
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    addl %d1,%d7
    subl %d5,%d7
    movel %d7,%d0
    cmpl %d3,%d0
    jbcc STHILITE_48C
    movel %d3,%d0
STHILITE_48C:           /* next component */
    movew %d7,%d0
    cmpw %d3,%d0
    jbcc STHILITE_494
    movew %d3,%d0
STHILITE_494:           /* next component */
    moveb %d7,%d0
    cmpb %d3,%d0
    jbcc STHILITE_49C
    moveb %d3,%d0
STHILITE_49C:           /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a1@
STHILITE_4A4:           /* next pixel; end of the row: back to STSCANLOOP */
    addql #2,%a1
    addql #2,%d6
    dbf %d2,STHILITE_462
    jbra STSCANLOOP_406
/* 16-bit StretchBits addMax: the larger of each component */
    bsrw STHILITE_380
STHILITE_4A4_10:        /* (16-bit addMax) next pixel inside the mask: unpack the components */
    tstw %a2@+
    beqs STHILITE_4A4_4E
    moveq #0,%d7
    movew %a3@(0x0,%d6:w),%d7
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    moveq #0,%d5
    movew %a1@,%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    movel %d7,%d0
    cmpl %d5,%d0
    bccs STHILITE_4A4_36
    movel %d5,%d0
STHILITE_4A4_36:        /* the larger */
    movew %d7,%d0
    cmpw %d5,%d0
    bccs STHILITE_4A4_3E
    movew %d5,%d0
STHILITE_4A4_3E:        /* the larger */
    moveb %d7,%d0
    cmpb %d5,%d0
    bccs STHILITE_4A4_46
    moveb %d5,%d0
STHILITE_4A4_46:        /* repack, store */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a1@
STHILITE_4A4_4E:        /* next pixel; end of row */
    addql #2,%a1
    addql #2,%d6
    dbf %d2,STHILITE_4A4_10
    braw STSCANLOOP_406
    .short  0x0000	| 4083825E
/* 16-bit StretchBits adMin: the smaller of each component */
    bsrw STHILITE_380
STHILITE_4A4_60:        /* (16-bit adMin) next pixel inside the mask */
    tstw %a2@+
    beqs STHILITE_4A4_9E
    moveq #0,%d7
    movew %a3@(0x0,%d6:w),%d7
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    moveq #0,%d5
    movew %a1@,%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    movel %d7,%d0
    cmpl %d5,%d0
    blss STHILITE_4A4_86
    movel %d5,%d0
STHILITE_4A4_86:        /* the smaller */
    movew %d7,%d0
    cmpw %d5,%d0
    blss STHILITE_4A4_8E
    movew %d5,%d0
STHILITE_4A4_8E:        /* the smaller */
    moveb %d7,%d0
    cmpb %d5,%d0
    blss STHILITE_4A4_96
    moveb %d5,%d0
STHILITE_4A4_96:        /* repack, store */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a1@
STHILITE_4A4_9E:        /* next pixel; end of row; then the blend set-up */
    addql #2,%a1
    addql #2,%d6
    dbf %d2,STHILITE_4A4_60
    braw STSCANLOOP_406
    .short  0x0000	| 408382AE
/* 16-bit StretchBits blend: each component weighted by the op color */
    lea %pc@(STHILITE_4A4_DA),%a0
    movel %a0,%fp@(-536)
    lea %fp@(-250),%a0
    movew %a0@+,%d3
    cmpw %a0@+,%d3
    bnes STHILITE_4A4_DA
    cmpw %a0@,%d3
    bnes STHILITE_4A4_DA
    addqw #1,%d3
    andiw #-2,%d3
    cmpiw #-32768,%d3
    bnes STHILITE_4A4_DA
    lea %pc@(STHILITE_4A4_178_14),%a0	| 408382D2
    movel %a0,%fp@(-536)
    braw STHILITE_4A4_178_14	| 408382DA
STHILITE_4A4_DA:        /* (16-bit blend) the weights */
    bsrw STHILITE_380
    lea %fp@(-250),%a0
    movel %a0@+,%d1
    movew %a0@,%d0
    moveq #0,%d4
    movel %d4,%d3
    moveal %d4,%a0
STHILITE_4A4_EC:        /* next pixel inside the mask: same as the last? reuse */
    tstw %a2@+
    beqw STHILITE_4A4_178
    moveq #0,%d7
    movew %a3@(0x0,%d6:w),%d7
    moveq #0,%d5
    movew %a1@,%d5
    cmpw %d3,%d7
    bnes STHILITE_4A4_104
    cmpw %a0,%d5
    beqs STHILITE_4A4_176
STHILITE_4A4_104:       /* unpack, weight each component */
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    moveq #0,%d3
    moveb %d7,%d3
    swap %d1
    muluw %d1,%d3
    moveq #0,%d4
    moveb %d5,%d4
    negw %d1
    muluw %d1,%d4
    negw %d1
    addl %d3,%d4
    swap %d4
    moveal %d4,%a0
    movew %d7,%d3
    lsrw #8,%d3
    swap %d1
    muluw %d1,%d3
    movew %d5,%d4
    lsrw #8,%d4
    negw %d1
    muluw %d1,%d4
    negw %d1
    addl %d3,%d4
    swap %d4
    lslw #5,%d4
    addaw %d4,%a0
    moveq #0,%d3
    swap %d7
    moveb %d7,%d3
    muluw %d0,%d3
    moveq #0,%d4
    swap %d5
    moveb %d5,%d4
    negw %d0
    muluw %d0,%d4
    negw %d0
    addl %d3,%d4
    clrw %d4
    lsrl #6,%d4
    addw %a0,%d4
    swap %d5
    lslb #3,%d5
    lslw #3,%d5
    lsrl #6,%d5
    moveal %d5,%a0
    swap %d7
    lslb #3,%d7
    lslw #3,%d7
    lsrl #6,%d7
    movel %d7,%d3
STHILITE_4A4_176:       /* store */
    movew %d4,%a1@
STHILITE_4A4_178:       /* next pixel; end of row */
    addql #2,%a1
    addql #2,%d6
    dbf %d2,STHILITE_4A4_EC
    braw STSCANLOOP_406
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40838388
STHILITE_4A4_178_14:
    bsrw STHILITE_380	| 40838390
    movew #15855,%d0
    moveaw #1057,%a0
STHILITE_4A4_178_20:
    tstw %a2@+	| 4083839C
    beqs STHILITE_4A4_178_3E
    movew %a3@(0x0,%d6:w),%d1
    movew %a0,%d3
    andw %d1,%d3
    lsrw #1,%d1
    andw %d0,%d1
    movew %a1@,%d5
    andw %d5,%d3
    lsrw #1,%d5
    andw %d0,%d5
    addw %d5,%d1
    addw %d3,%d1
    movew %d1,%a1@
STHILITE_4A4_178_3E:
    addql #2,%a1	| 408383BA
    addql #2,%d6
    dbf %d2,STHILITE_4A4_178_20
    braw STSCANLOOP_406
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408383C6
/* 16-bit StretchBits transparent: the source unless it is the background color */
    bsrw STHILITE_380
    movel %fp@(-276),%d5
STHILITE_4A4_1D4:       /* (16-bit transparent) next pixel inside the mask: copy unless background */
    tstw %a2@+
    beqs STHILITE_4A4_1E2
    movew %a3@(0x0,%d6:w),%d1
    cmpw %d1,%d5
    beqs STHILITE_4A4_1E2
    movew %d1,%a1@
STHILITE_4A4_1E2:       /* next pixel; end of row */
    addql #2,%a1
    addql #2,%d6
    dbf %d2,STHILITE_4A4_1D4
    braw STSCANLOOP_406
    .short  0x0000	| 408383F2

/* STARITH16TAB: table. */
trap_STARITH16TAB:
STARITH16TAB:
    .long   0xFFFFFEBC, 0xFFFFFCFC, 0xFFFFFCAC	| 408383F4
    .long   0xFFFFFDAC, 0xFFFFFFDC, 0xFFFFFE1C, 0xFFFFFD6C	| 40838400
    .long   0xFFFFFE6C, 0xFFFFF96C	| 40838410

/* STARITH32TAB: table. */
trap_STARITH32TAB:
STARITH32TAB:
    .long   0xFFFFFB58, 0xFFFFF9D8	| 40838418
    .long   0xFFFFF988, 0xFFFFFA78, 0xFFFFFC58, 0xFFFFFAD8	| 40838420
    .long   0xFFFFFA38, 0xFFFFFB18, 0xFFFFF948, 0x00000000	| 40838430

trap_SETUPSTRETCH:
SETUPSTRETCH:           /* the horizontal stretch proc for source width d0, destination width d1 (a0) */
    movew %d3,%sp@-
    lea %pc@(DONESTRETCH),%a0
    tstw %d0
    jble SETUPSTRETCH_A4
    tstw %d1
    jble SETUPSTRETCH_A4
    lea %pc@(PATEXTBL_24),%a0
    cmpw %d1,%d0
    jbeq SETUPSTRETCH_A4
    jblt SETUPSTRETCH_A8
    movew %d0,%d3
    movew %d1,%d4
    clrl %sp@-
    movew %d1,%sp@-
    movew %d0,%sp@-
    jsr @(0xfa4,%za0)@(0)	| 4083846A
    movel %sp@+,%d0
    lea %pc@(TABLE8_34C),%a0
    tstw %sp@
    jbne SETUPSTRETCH_A4
    lea %pc@(PATEXTBL_2E4),%a0
    cmpiw #-32768,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(TABLE2_25A),%a0
    cmpiw #16384,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(TABLE8_4C),%a0
    cmpiw #8192,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(TABLE8_6C),%a0
    cmpiw #4096,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(TABLE8_14C),%a0
    cmpiw #2048,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(PATEXTBL_254),%a0
    cmpiw #-21846,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(TABLE2_20A),%a0
    cmpiw #21845,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(TABLE4_408),%a0
    cmpiw #10922,%d0
    jbeq SETUPSTRETCH_A4
    extl %d3
    divuw %d4,%d3
    movew %d3,%d1
    andil #-65529,%d3
    jbne SETUPSTRETCH_A0
    movew %d1,%d0
    lea %pc@(TABLE8_1EC),%a0
    jbra SETUPSTRETCH_A4
SETUPSTRETCH_A0:        /* shrinking: the shrink proc */
    lea %pc@(TABLE8_23C),%a0
SETUPSTRETCH_A4:        /* return the proc in a0 */
    addqw #2,%sp
    rts
SETUPSTRETCH_A8:        /* stretching: the ratio (FixRatio); integer ratios have their own procs */
    clrl %sp@-
    movew %d0,%sp@-
    movew %d1,%sp@-
    jsr @(0xfa4,%za0)@(0)	| 408384EE
    movel %sp@+,%d0
    lea %pc@(TABLE8_2FC),%a0
    tstw %sp@
    jbne SETUPSTRETCH_A4
    lea %pc@(PATEXTBL_224),%a0
    cmpiw #8192,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(PATEXTBL_204),%a0
    cmpiw #16384,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(PATEXTBL_A4),%a0
    cmpiw #-32768,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(PATEXTBL_74),%a0
    cmpiw #-16384,%d0
    jbeq SETUPSTRETCH_A4
    lea %pc@(TABLE8_20C),%a0
    jbra SETUPSTRETCH_A4

/* EXTBL: table. */
trap_EXTBL:
EXTBL:
    orib #68,%d0
    .short  0x0000, 0x0304	| orib #4,%d0
    .short  0x0000, 0x0574	| orib #116,%d0
    .short  0x0000, 0x0B14	| orib #20,%d0
    .short  0x0000, 0x0B34	| orib #52,%d0
    .short  0x0000, 0x0C14	| orib #20,%d0
    .short  0x0000, 0x0C34	| orib #52,%d0
    .short  0x0000, 0x0C74	| orib #116,%d0

/* PATEXTBL: table. */
trap_PATEXTBL:
PATEXTBL:
    orib #52,%d0
    .short  0x0000, 0x02A4	| orib #0xa4,%d0
    .short  0x0000, 0x0568	| orib #104,%d0
    .short  0x0000, 0x0A14	| orib #20,%d0
    .short  0x0000, 0x0B34	| orib #52,%d0
    .short  0x0000, 0x0B94	| orib #0x94,%d0
    .long   0x00000000, 0x00000000, 0x00000000	| 40838564
PATEXTBL_24:            /* same width: copy the row */
    subal %a1,%a2
    movel %a2,%d0
    lsrl #2,%d0
    subqw #1,%d0
PATEXTBL_2C:            /* copy */
    movel %a0@+,%a1@+
    dbf %d0,PATEXTBL_2C
    rts
    clrw %a1@+
    clrl %a1@+
    moveal %a1@,%a1
    moveb %a0@+,%d0
    bras PATEXTBL_2C_18
PATEXTBL_2C_12:         /* (8-bit pattern) next pattern byte: same as the last? reuse */
    moveb %a0@+,%d0
    cmpb %d5,%d0
    beqs PATEXTBL_2C_34
PATEXTBL_2C_18:         /* the byte rotated to the origin, replicated across a long */
    moveb %d0,%d5
    eorb %d7,%d0
    rolb %d2,%d0
    moveb %d0,%d1
    lsll #8,%d1
    moveb %d0,%d1
    movew %d1,%d0
    swap %d1
    movew %d0,%d1
    movel %d1,%d0
    andl %d3,%d0
    notl %d1
    andl %d4,%d1
    orl %d0,%d1
PATEXTBL_2C_34:         /* store the row (twice, for the 8-row buffer); next row */
    movel %d1,%a1@+
    movel %d1,%a1@(28)
    dbf %d6,PATEXTBL_2C_12
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 408385B8
PATEXTBL_74:            /* (1-bit to 2-bit and others: bit doubling) */
    moveq #3,%d3
    rorl #2,%d3
PATEXTBL_78:            /* each long */
    movel %a0@+,%d0
    moveq #7,%d2
PATEXTBL_7C:            /* shift the bits out and in, doubled */
    addl %d0,%d0
    addxl %d1,%d1
    addl %d3,%d0
    addxl %d1,%d1
    lsll #3,%d0
    addxl %d1,%d1
    dbf %d2,PATEXTBL_7C
    bfins %d1,%a1@,0,24
    addqw #3,%a1
    cmpal %a2,%a1
    jbcs PATEXTBL_78
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408385E4
PATEXTBL_A4:            /* halve 1-bit: or adjacent bit pairs */
    movel %a2,%d3
    subl %a1,%d3
    lsrw #2,%d3
    subqw #1,%d3
    movel #1431655765,%d2
    movel #16711935,%d5
PATEXTBL_B8:            /* each long: fold pairs, look up the packed byte */
    movel %a0@+,%d0
    movel %d0,%d1
    lsrl #1,%d1
    orl %d0,%d1
    andl %d2,%d1
    movel %d1,%d0
    lsrl #7,%d0
    orl %d1,%d0
    andl %d5,%d0
    swap %d0
    moveb %pc@(PATEXTBL_102,%d0:w),%d4
    lslw #8,%d4
    swap %d0
    moveb %pc@(PATEXTBL_102,%d0:w),%d4
    swap %d4
    movel %a0@+,%d0
    movel %d0,%d1
    lsrl #1,%d1
    orl %d0,%d1
    andl %d2,%d1
    movel %d1,%d0
    lsrl #7,%d0
    orl %d1,%d0
    andl %d5,%d0
    swap %d0
    moveb %pc@(PATEXTBL_102,%d0:w),%d4
    lslw #8,%d4
    swap %d0
    moveb %pc@(PATEXTBL_102,%d0:w),%d4
    movel %d4,%a1@+
    dbf %d3,PATEXTBL_B8
    rts
PATEXTBL_102:           /* (data) */
    .short  0x0001	| 4083864E
    .long   0x10110203, 0x12132021, 0x30312223, 0x32330405	| 40838650
    .long   0x14150607, 0x16172425, 0x34352627, 0x36374041	| 40838660
    .long   0x50514243, 0x52536061, 0x70716263, 0x72734445	| 40838670
    .long   0x54554647, 0x56576465, 0x74756667, 0x76770809	| 40838680
    .long   0x18190A0B, 0x1A1B2829, 0x38392A2B, 0x3A3B0C0D	| 40838690
    .long   0x1C1D0E0F, 0x1E1F2C2D, 0x3C3D2E2F, 0x3E3F4849	| 408386A0
    .long   0x58594A4B, 0x5A5B6869, 0x78796A6B, 0x7A7B4C4D	| 408386B0
    .long   0x5C5D4E4F, 0x5E5F6C6D, 0x7C7D6E6F, 0x7E7F8081	| 408386C0
    .long   0x90918283, 0x9293A0A1, 0xB0B1A2A3, 0xB2B38485	| 408386D0
    .long   0x94958687, 0x9697A4A5, 0xB4B5A6A7, 0xB6B7C0C1	| 408386E0
    .long   0xD0D1C2C3, 0xD2D3E0E1, 0xF0F1E2E3, 0xF2F3C4C5	| 408386F0
    .long   0xD4D5C6C7, 0xD6D7E4E5, 0xF4F5E6E7, 0xF6F78889	| 40838700
    .long   0x98998A8B, 0x9A9BA8A9, 0xB8B9AAAB, 0xBABB8C8D	| 40838710
    .long   0x9C9D8E8F, 0x9E9FACAD, 0xBCBDAEAF, 0xBEBFC8C9	| 40838720
    .long   0xD8D9CACB, 0xDADBE8E9, 0xF8F9EAEB, 0xFAFBCCCD	| 40838730
    .long   0xDCDDCECF, 0xDEDFECED, 0xFCFDEEEF, 0xFEFF0000	| 40838740
PATEXTBL_204:           /* reduce by 4 (or of each nibble) */
    movel #-268435456,%d3
PATEXTBL_20A:           /* each long */
    movel %a0@+,%d0
    moveq #7,%d2
PATEXTBL_20E:           /* one bit per nibble */
    addl %d3,%d0
    addxl %d1,%d1
    lsll #4,%d0
    dbf %d2,PATEXTBL_20E
    moveb %d1,%a1@+
    cmpal %a2,%a1
    jbcs PATEXTBL_20A
    rts
    .long   0x00000000	| 4083876C
PATEXTBL_224:           /* reduce by 8 (or of each byte) */
    movel #-16777216,%d3
PATEXTBL_22A:           /* each long */
    movel %a0@+,%d0
    moveq #3,%d2
PATEXTBL_22E:           /* one bit per byte */
    addl %d3,%d0
    addxl %d1,%d1
    lsll #8,%d0
    dbf %d2,PATEXTBL_22E
    movel %a0@+,%d0
    moveq #3,%d2
PATEXTBL_23C:           /* one bit per byte */
    addl %d3,%d0
    addxl %d1,%d1
    lsll #8,%d0
    dbf %d2,PATEXTBL_23C
    moveb %d1,%a1@+
    cmpal %a2,%a1
    jbcs PATEXTBL_22A
    rts
    .short  0x0000, 0x0000, 0x0000	| 4083879A
PATEXTBL_254:           /* stretch by 3/2: each nibble through the table to 6 bits, two bytes to three */
    moveb %a0@+,%d0
    movew %d0,%d1
    lsrb #4,%d1
    moveb %pc@(PATEXTBL_294,%d1:w),%d2
    lsll #6,%d2
    andiw #15,%d0
    moveb %pc@(PATEXTBL_294,%d0:w),%d2
    lsll #6,%d2
    moveb %a0@+,%d0
    movew %d0,%d1
    lsrb #4,%d1
    moveb %pc@(PATEXTBL_294,%d1:w),%d2
    lsll #6,%d2
    andiw #15,%d0
    moveb %pc@(PATEXTBL_294,%d0:w),%d2
    lsrl #2,%d2
    swap %d2
    moveb %d2,%a1@+
    swap %d2
    movew %d2,%d1
    rorw #8,%d1
    moveb %d1,%a1@+
    moveb %d2,%a1@+
    cmpal %a2,%a1
    jbcs PATEXTBL_254
    rts
PATEXTBL_294:           /* (data) */
    .short  0x000C	| .short 0x000c
    moveb %a4@+,%d0
    bras TABLE2_C	| 408387E4
    moveq #124,%d0
    .short  0x808C	| .short 0x808c
    subl %a4@+,%d0
    asrw %a4@(-3844)
    clrw %a1@+
    clrl %a1@+
    moveal %a1@,%a1
    moveq #0,%d0
    moveb %a0@+,%d0
    bras PATEXTBL_294_24
PATEXTBL_294_1C:        /* (2-bit pattern) next pattern byte: same as the last? reuse */
    moveq #0,%d0
    moveb %a0@+,%d0
    cmpb %d5,%d0
    beqs PATEXTBL_294_40
PATEXTBL_294_24:        /* expand through TABLE2 with the fg/bk colors, replicated */
    moveb %d0,%d5
    eorb %d7,%d0
    rolb %d2,%d0
    movew %d0,%d1
    movew %pc@(TABLE2,%d1:w:2),%d1
    movew %d1,%d0
    swap %d1
    movew %d0,%d1
    movel %d1,%d0
    andl %d3,%d0
    notl %d1
    andl %d4,%d1
    orl %d0,%d1
PATEXTBL_294_40:        /* store the row (twice); next row */
    movel %d1,%a1@(32)
    movel %d1,%a1@+
    dbf %d6,PATEXTBL_294_1C
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
PATEXTBL_2E4:           /* 1-bit to 2-bit: each byte to a word (TABLE2) */
    clrw %d0
    movel %a2,%d3
    subl %a1,%d3
    lsrw #1,%d3
    subqw #1,%d3
PATEXTBL_2EE:           /* through TABLE2 */
    moveb %a0@+,%d0
    movew %pc@(TABLE2,%d0:w:2),%a1@+
    dbf %d3,PATEXTBL_2EE
    rts

/* TABLE2: table. */
TABLE2:
    orib #3,%d0	| 40838846
    .byte   0x00, 0x0C, 0x00, 0x0F, 0x00, 0x30, 0x00, 0x33	| 4083884A
TABLE2_C:
    .byte   0x00, 0x3C, 0x00, 0x3F, 0x00, 0xC0, 0x00, 0xC3, 0x00, 0xCC, 0x00, 0xCF, 0x00, 0xF0, 0x00, 0xF3	| 40838852
    .byte   0x00, 0xFC, 0x00, 0xFF, 0x03, 0x00, 0x03, 0x03, 0x03, 0x0C, 0x03, 0x0F, 0x03, 0x30, 0x03, 0x33	| 40838862
    .byte   0x03, 0x3C, 0x03, 0x3F, 0x03, 0xC0, 0x03, 0xC3, 0x03, 0xCC, 0x03, 0xCF, 0x03, 0xF0, 0x03, 0xF3	| 40838872
    .byte   0x03, 0xFC, 0x03, 0xFF, 0x0C, 0x00, 0x0C, 0x03, 0x0C, 0x0C, 0x0C, 0x0F, 0x0C, 0x30, 0x0C, 0x33	| 40838882
    .byte   0x0C, 0x3C, 0x0C, 0x3F, 0x0C, 0xC0, 0x0C, 0xC3, 0x0C, 0xCC, 0x0C, 0xCF, 0x0C, 0xF0, 0x0C, 0xF3	| 40838892
    .byte   0x0C, 0xFC, 0x0C, 0xFF, 0x0F, 0x00, 0x0F, 0x03, 0x0F, 0x0C, 0x0F, 0x0F, 0x0F, 0x30, 0x0F, 0x33	| 408388A2
    .byte   0x0F, 0x3C, 0x0F, 0x3F, 0x0F, 0xC0, 0x0F, 0xC3, 0x0F, 0xCC, 0x0F, 0xCF, 0x0F, 0xF0, 0x0F, 0xF3	| 408388B2
    .byte   0x0F, 0xFC, 0x0F, 0xFF, 0x30, 0x00, 0x30, 0x03, 0x30, 0x0C, 0x30, 0x0F, 0x30, 0x30, 0x30, 0x33	| 408388C2
    .byte   0x30, 0x3C, 0x30, 0x3F, 0x30, 0xC0, 0x30, 0xC3, 0x30, 0xCC, 0x30, 0xCF, 0x30, 0xF0, 0x30, 0xF3	| 408388D2
    .byte   0x30, 0xFC, 0x30, 0xFF, 0x33, 0x00, 0x33, 0x03, 0x33, 0x0C, 0x33, 0x0F, 0x33, 0x30, 0x33, 0x33	| 408388E2
    .byte   0x33, 0x3C, 0x33, 0x3F, 0x33, 0xC0, 0x33, 0xC3, 0x33, 0xCC, 0x33, 0xCF, 0x33, 0xF0, 0x33, 0xF3	| 408388F2
    .byte   0x33, 0xFC, 0x33, 0xFF, 0x3C, 0x00, 0x3C, 0x03, 0x3C, 0x0C, 0x3C, 0x0F, 0x3C, 0x30, 0x3C, 0x33	| 40838902
    .byte   0x3C, 0x3C, 0x3C, 0x3F, 0x3C, 0xC0, 0x3C, 0xC3, 0x3C, 0xCC, 0x3C, 0xCF, 0x3C, 0xF0, 0x3C, 0xF3	| 40838912
    .byte   0x3C, 0xFC, 0x3C, 0xFF, 0x3F, 0x00, 0x3F, 0x03, 0x3F, 0x0C, 0x3F, 0x0F, 0x3F, 0x30, 0x3F, 0x33	| 40838922
    .byte   0x3F, 0x3C, 0x3F, 0x3F, 0x3F, 0xC0, 0x3F, 0xC3, 0x3F, 0xCC, 0x3F, 0xCF, 0x3F, 0xF0, 0x3F, 0xF3	| 40838932
    .byte   0x3F, 0xFC, 0x3F, 0xFF, 0xC0, 0x00, 0xC0, 0x03, 0xC0, 0x0C, 0xC0, 0x0F, 0xC0, 0x30, 0xC0, 0x33	| 40838942
    .byte   0xC0, 0x3C, 0xC0, 0x3F, 0xC0, 0xC0, 0xC0, 0xC3, 0xC0, 0xCC, 0xC0, 0xCF, 0xC0, 0xF0, 0xC0, 0xF3	| 40838952
    .byte   0xC0, 0xFC, 0xC0, 0xFF, 0xC3, 0x00, 0xC3, 0x03, 0xC3, 0x0C, 0xC3, 0x0F, 0xC3, 0x30, 0xC3, 0x33	| 40838962
    .byte   0xC3, 0x3C, 0xC3, 0x3F, 0xC3, 0xC0, 0xC3, 0xC3, 0xC3, 0xCC, 0xC3, 0xCF, 0xC3, 0xF0, 0xC3, 0xF3	| 40838972
    .byte   0xC3, 0xFC, 0xC3, 0xFF, 0xCC, 0x00, 0xCC, 0x03, 0xCC, 0x0C, 0xCC, 0x0F, 0xCC, 0x30, 0xCC, 0x33	| 40838982
    .byte   0xCC, 0x3C, 0xCC, 0x3F, 0xCC, 0xC0, 0xCC, 0xC3, 0xCC, 0xCC, 0xCC, 0xCF, 0xCC, 0xF0, 0xCC, 0xF3	| 40838992
    .byte   0xCC, 0xFC, 0xCC, 0xFF, 0xCF, 0x00, 0xCF, 0x03, 0xCF, 0x0C, 0xCF, 0x0F, 0xCF, 0x30, 0xCF, 0x33	| 408389A2
    .byte   0xCF, 0x3C, 0xCF, 0x3F, 0xCF, 0xC0, 0xCF, 0xC3, 0xCF, 0xCC, 0xCF, 0xCF, 0xCF, 0xF0, 0xCF, 0xF3	| 408389B2
    .byte   0xCF, 0xFC, 0xCF, 0xFF, 0xF0, 0x00, 0xF0, 0x03, 0xF0, 0x0C, 0xF0, 0x0F, 0xF0, 0x30, 0xF0, 0x33	| 408389C2
    .byte   0xF0, 0x3C, 0xF0, 0x3F, 0xF0, 0xC0, 0xF0, 0xC3, 0xF0, 0xCC, 0xF0, 0xCF, 0xF0, 0xF0, 0xF0, 0xF3	| 408389D2
    .byte   0xF0, 0xFC, 0xF0, 0xFF, 0xF3, 0x00, 0xF3, 0x03, 0xF3, 0x0C, 0xF3, 0x0F, 0xF3, 0x30, 0xF3, 0x33	| 408389E2
    .byte   0xF3, 0x3C, 0xF3, 0x3F, 0xF3, 0xC0, 0xF3, 0xC3, 0xF3, 0xCC, 0xF3, 0xCF, 0xF3, 0xF0, 0xF3, 0xF3	| 408389F2
    .byte   0xF3, 0xFC, 0xF3, 0xFF, 0xFC, 0x00, 0xFC, 0x03, 0xFC, 0x0C, 0xFC, 0x0F, 0xFC, 0x30, 0xFC, 0x33	| 40838A02
    .byte   0xFC, 0x3C, 0xFC, 0x3F, 0xFC, 0xC0, 0xFC, 0xC3, 0xFC, 0xCC, 0xFC, 0xCF, 0xFC, 0xF0, 0xFC, 0xF3	| 40838A12
    .byte   0xFC, 0xFC, 0xFC, 0xFF, 0xFF, 0x00, 0xFF, 0x03, 0xFF, 0x0C, 0xFF, 0x0F, 0xFF, 0x30, 0xFF, 0x33	| 40838A22
    .byte   0xFF, 0x3C, 0xFF, 0x3F, 0xFF, 0xC0, 0xFF, 0xC3, 0xFF, 0xCC, 0xFF, 0xCF, 0xFF, 0xF0, 0xFF, 0xF3	| 40838A32
    .byte   0xFF, 0xFC, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40838A42
TABLE2_20A:             /* 1-bit to 3-times: each byte through two tables */
    moveb %a0@+,%d0
    movew %d0,%d1
    movew %d0,%d2
    lsrb #5,%d2
    moveb %pc@(TABLE2_22E,%d2:w),%a1@+
    lsrb #2,%d1
    andiw #15,%d1
    moveb %pc@(TABLE2_236,%d1:w),%a1@+
    andiw #7,%d0
    moveb %pc@(TABLE2_246,%d0:w),%a1@+
    cmpal %a2,%a1
    jbcs TABLE2_20A
    rts
TABLE2_22E:             /* (data) */
    .long   0x00031C1F, 0xE0E3FCFF	| 40838A74
TABLE2_236:             /* (data) */
    .long   0x00010E0F	| 40838A7C
    .long   0x70717E7F, 0x80818E8F, 0xF0F1FEFF	| 40838A80
TABLE2_246:             /* (data) */
    .long   0x0007383F	| 40838A8C
    .long   0xC0C7F8FF, 0x00000000, 0x00000000, 0x00000000	| 40838A90
TABLE2_25A:             /* 1-bit to 4-bit: each byte to a long (TABLE4) */
    subal %a1,%a2
    movel %a2,%d1
    lsrl #2,%d1
    subqw #1,%d1
TABLE2_262:             /* through TABLE4 */
    moveb %a0@+,%d0
    movel %pc@(TABLE4,%d0:w:4),%a1@+
    dbf %d1,TABLE2_262
    rts
    clrw %a1@+
    clrl %a1@+
    moveal %a1@,%a1
    moveq #0,%d0
    moveb %a0@+,%d0
    bras TABLE2_262_20
TABLE2_262_18:          /* (4-bit pattern) next pattern byte: same as the last? reuse */
    moveq #0,%d0
    moveb %a0@+,%d0
    cmpb %d5,%d0
    beqs TABLE2_262_34
TABLE2_262_20:          /* expand through TABLE4 with the fg/bk colors */
    moveb %d0,%d5
    eorb %d7,%d0
    rolb %d2,%d0
    movel %pc@(TABLE4,%d0:w:4),%d1
    movel %d1,%d0
    andl %d3,%d0
    notl %d1
    andl %d4,%d1
    orl %d0,%d1
TABLE2_262_34:          /* store the row (twice); next row */
    movel %d1,%a1@+
    movel %d1,%a1@(28)
    dbf %d6,TABLE2_262_18
    rts

/* TABLE4: table. */
TABLE4:
    orib #0,%d0	| 40838AE8
    orib #15,%d0	| 40838AEC
    .short  0x0000, 0x00F0	| 40838AF0 orib #-16,%d0
    .short  0x0000, 0x00FF	| 40838AF4 orib #-1,%d0
    .short  0x0000, 0x0F00	| 40838AF8 orib #0,%d0
    .short  0x0000, 0x0F0F	| 40838AFC orib #15,%d0
    .short  0x0000, 0x0FF0	| 40838B00 orib #-16,%d0
    .short  0x0000, 0x0FFF	| 40838B04 orib #-1,%d0
    .short  0x0000, 0xF000	| 40838B08 orib #0,%d0
    .short  0x0000, 0xF00F	| 40838B0C orib #15,%d0
    .short  0x0000, 0xF0F0	| 40838B10 orib #-16,%d0
    .short  0x0000, 0xF0FF	| 40838B14 orib #-1,%d0
    .short  0x0000, 0xFF00	| 40838B18 orib #0,%d0
    .short  0x0000, 0xFF0F	| 40838B1C orib #15,%d0
    orib #-16,%d0	| 40838B20
    orib #-1,%d0	| 40838B24
    .byte   0x00, 0x0F, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x0F, 0x00, 0x0F, 0x00, 0xF0, 0x00, 0x0F, 0x00, 0xFF	| 40838B28
    .byte   0x00, 0x0F, 0x0F, 0x00, 0x00, 0x0F, 0x0F, 0x0F, 0x00, 0x0F, 0x0F, 0xF0, 0x00, 0x0F, 0x0F, 0xFF	| 40838B38
    .byte   0x00, 0x0F, 0xF0, 0x00, 0x00, 0x0F, 0xF0, 0x0F, 0x00, 0x0F, 0xF0, 0xF0, 0x00, 0x0F, 0xF0, 0xFF	| 40838B48
    .byte   0x00, 0x0F, 0xFF, 0x00, 0x00, 0x0F, 0xFF, 0x0F, 0x00, 0x0F, 0xFF, 0xF0, 0x00, 0x0F, 0xFF, 0xFF	| 40838B58
    .byte   0x00, 0xF0, 0x00, 0x00, 0x00, 0xF0, 0x00, 0x0F, 0x00, 0xF0, 0x00, 0xF0, 0x00, 0xF0, 0x00, 0xFF	| 40838B68
    .byte   0x00, 0xF0, 0x0F, 0x00, 0x00, 0xF0, 0x0F, 0x0F, 0x00, 0xF0, 0x0F, 0xF0, 0x00, 0xF0, 0x0F, 0xFF	| 40838B78
    .byte   0x00, 0xF0, 0xF0, 0x00, 0x00, 0xF0, 0xF0, 0x0F, 0x00, 0xF0, 0xF0, 0xF0, 0x00, 0xF0, 0xF0, 0xFF	| 40838B88
    .byte   0x00, 0xF0, 0xFF, 0x00, 0x00, 0xF0, 0xFF, 0x0F, 0x00, 0xF0, 0xFF, 0xF0, 0x00, 0xF0, 0xFF, 0xFF	| 40838B98
    .byte   0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x0F, 0x00, 0xFF, 0x00, 0xF0, 0x00, 0xFF, 0x00, 0xFF	| 40838BA8
    .byte   0x00, 0xFF, 0x0F, 0x00, 0x00, 0xFF, 0x0F, 0x0F, 0x00, 0xFF, 0x0F, 0xF0, 0x00, 0xFF, 0x0F, 0xFF	| 40838BB8
    .byte   0x00, 0xFF, 0xF0, 0x00, 0x00, 0xFF, 0xF0, 0x0F, 0x00, 0xFF, 0xF0, 0xF0, 0x00, 0xFF, 0xF0, 0xFF	| 40838BC8
    .byte   0x00, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x0F, 0x00, 0xFF, 0xFF, 0xF0, 0x00, 0xFF, 0xFF, 0xFF	| 40838BD8
    .byte   0x0F, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x00, 0x0F, 0x0F, 0x00, 0x00, 0xF0, 0x0F, 0x00, 0x00, 0xFF	| 40838BE8
    .byte   0x0F, 0x00, 0x0F, 0x00, 0x0F, 0x00, 0x0F, 0x0F, 0x0F, 0x00, 0x0F, 0xF0, 0x0F, 0x00, 0x0F, 0xFF	| 40838BF8
    .byte   0x0F, 0x00, 0xF0, 0x00, 0x0F, 0x00, 0xF0, 0x0F, 0x0F, 0x00, 0xF0, 0xF0, 0x0F, 0x00, 0xF0, 0xFF	| 40838C08
    .byte   0x0F, 0x00, 0xFF, 0x00, 0x0F, 0x00, 0xFF, 0x0F, 0x0F, 0x00, 0xFF, 0xF0, 0x0F, 0x00, 0xFF, 0xFF	| 40838C18
    .byte   0x0F, 0x0F, 0x00, 0x00, 0x0F, 0x0F, 0x00, 0x0F, 0x0F, 0x0F, 0x00, 0xF0, 0x0F, 0x0F, 0x00, 0xFF	| 40838C28
    .byte   0x0F, 0x0F, 0x0F, 0x00, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0xF0, 0x0F, 0x0F, 0x0F, 0xFF	| 40838C38
    .byte   0x0F, 0x0F, 0xF0, 0x00, 0x0F, 0x0F, 0xF0, 0x0F, 0x0F, 0x0F, 0xF0, 0xF0, 0x0F, 0x0F, 0xF0, 0xFF	| 40838C48
    .byte   0x0F, 0x0F, 0xFF, 0x00, 0x0F, 0x0F, 0xFF, 0x0F, 0x0F, 0x0F, 0xFF, 0xF0, 0x0F, 0x0F, 0xFF, 0xFF	| 40838C58
    .byte   0x0F, 0xF0, 0x00, 0x00, 0x0F, 0xF0, 0x00, 0x0F, 0x0F, 0xF0, 0x00, 0xF0, 0x0F, 0xF0, 0x00, 0xFF	| 40838C68
    .byte   0x0F, 0xF0, 0x0F, 0x00, 0x0F, 0xF0, 0x0F, 0x0F, 0x0F, 0xF0, 0x0F, 0xF0, 0x0F, 0xF0, 0x0F, 0xFF	| 40838C78
    .byte   0x0F, 0xF0, 0xF0, 0x00, 0x0F, 0xF0, 0xF0, 0x0F, 0x0F, 0xF0, 0xF0, 0xF0, 0x0F, 0xF0, 0xF0, 0xFF	| 40838C88
    .byte   0x0F, 0xF0, 0xFF, 0x00, 0x0F, 0xF0, 0xFF, 0x0F, 0x0F, 0xF0, 0xFF, 0xF0, 0x0F, 0xF0, 0xFF, 0xFF	| 40838C98
    .byte   0x0F, 0xFF, 0x00, 0x00, 0x0F, 0xFF, 0x00, 0x0F, 0x0F, 0xFF, 0x00, 0xF0, 0x0F, 0xFF, 0x00, 0xFF	| 40838CA8
    .byte   0x0F, 0xFF, 0x0F, 0x00, 0x0F, 0xFF, 0x0F, 0x0F, 0x0F, 0xFF, 0x0F, 0xF0, 0x0F, 0xFF, 0x0F, 0xFF	| 40838CB8
    .byte   0x0F, 0xFF, 0xF0, 0x00, 0x0F, 0xFF, 0xF0, 0x0F, 0x0F, 0xFF, 0xF0, 0xF0, 0x0F, 0xFF, 0xF0, 0xFF	| 40838CC8
    .byte   0x0F, 0xFF, 0xFF, 0x00, 0x0F, 0xFF, 0xFF, 0x0F, 0x0F, 0xFF, 0xFF, 0xF0, 0x0F, 0xFF, 0xFF, 0xFF	| 40838CD8
    .byte   0xF0, 0x00, 0x00, 0x00, 0xF0, 0x00, 0x00, 0x0F, 0xF0, 0x00, 0x00, 0xF0, 0xF0, 0x00, 0x00, 0xFF	| 40838CE8
    .byte   0xF0, 0x00, 0x0F, 0x00, 0xF0, 0x00, 0x0F, 0x0F, 0xF0, 0x00, 0x0F, 0xF0, 0xF0, 0x00, 0x0F, 0xFF	| 40838CF8
    .byte   0xF0, 0x00, 0xF0, 0x00, 0xF0, 0x00, 0xF0, 0x0F, 0xF0, 0x00, 0xF0, 0xF0, 0xF0, 0x00, 0xF0, 0xFF	| 40838D08
    .byte   0xF0, 0x00, 0xFF, 0x00, 0xF0, 0x00, 0xFF, 0x0F, 0xF0, 0x00, 0xFF, 0xF0, 0xF0, 0x00, 0xFF, 0xFF	| 40838D18
    .byte   0xF0, 0x0F, 0x00, 0x00, 0xF0, 0x0F, 0x00, 0x0F, 0xF0, 0x0F, 0x00, 0xF0, 0xF0, 0x0F, 0x00, 0xFF	| 40838D28
    .byte   0xF0, 0x0F, 0x0F, 0x00, 0xF0, 0x0F, 0x0F, 0x0F, 0xF0, 0x0F, 0x0F, 0xF0, 0xF0, 0x0F, 0x0F, 0xFF	| 40838D38
    .byte   0xF0, 0x0F, 0xF0, 0x00, 0xF0, 0x0F, 0xF0, 0x0F, 0xF0, 0x0F, 0xF0, 0xF0, 0xF0, 0x0F, 0xF0, 0xFF	| 40838D48
    .byte   0xF0, 0x0F, 0xFF, 0x00, 0xF0, 0x0F, 0xFF, 0x0F, 0xF0, 0x0F, 0xFF, 0xF0, 0xF0, 0x0F, 0xFF, 0xFF	| 40838D58
    .byte   0xF0, 0xF0, 0x00, 0x00, 0xF0, 0xF0, 0x00, 0x0F, 0xF0, 0xF0, 0x00, 0xF0, 0xF0, 0xF0, 0x00, 0xFF	| 40838D68
    .byte   0xF0, 0xF0, 0x0F, 0x00, 0xF0, 0xF0, 0x0F, 0x0F, 0xF0, 0xF0, 0x0F, 0xF0, 0xF0, 0xF0, 0x0F, 0xFF	| 40838D78
    .byte   0xF0, 0xF0, 0xF0, 0x00, 0xF0, 0xF0, 0xF0, 0x0F, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xFF	| 40838D88
    .byte   0xF0, 0xF0, 0xFF, 0x00, 0xF0, 0xF0, 0xFF, 0x0F, 0xF0, 0xF0, 0xFF, 0xF0, 0xF0, 0xF0, 0xFF, 0xFF	| 40838D98
    .byte   0xF0, 0xFF, 0x00, 0x00, 0xF0, 0xFF, 0x00, 0x0F, 0xF0, 0xFF, 0x00, 0xF0, 0xF0, 0xFF, 0x00, 0xFF	| 40838DA8
    .byte   0xF0, 0xFF, 0x0F, 0x00, 0xF0, 0xFF, 0x0F, 0x0F, 0xF0, 0xFF, 0x0F, 0xF0, 0xF0, 0xFF, 0x0F, 0xFF	| 40838DB8
    .byte   0xF0, 0xFF, 0xF0, 0x00, 0xF0, 0xFF, 0xF0, 0x0F, 0xF0, 0xFF, 0xF0, 0xF0, 0xF0, 0xFF, 0xF0, 0xFF	| 40838DC8
    .byte   0xF0, 0xFF, 0xFF, 0x00, 0xF0, 0xFF, 0xFF, 0x0F, 0xF0, 0xFF, 0xFF, 0xF0, 0xF0, 0xFF, 0xFF, 0xFF	| 40838DD8
    .byte   0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x0F, 0xFF, 0x00, 0x00, 0xF0, 0xFF, 0x00, 0x00, 0xFF	| 40838DE8
    .byte   0xFF, 0x00, 0x0F, 0x00, 0xFF, 0x00, 0x0F, 0x0F, 0xFF, 0x00, 0x0F, 0xF0, 0xFF, 0x00, 0x0F, 0xFF	| 40838DF8
    .byte   0xFF, 0x00, 0xF0, 0x00, 0xFF, 0x00, 0xF0, 0x0F, 0xFF, 0x00, 0xF0, 0xF0, 0xFF, 0x00, 0xF0, 0xFF	| 40838E08
    .byte   0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x0F, 0xFF, 0x00, 0xFF, 0xF0, 0xFF, 0x00, 0xFF, 0xFF	| 40838E18
    .byte   0xFF, 0x0F, 0x00, 0x00, 0xFF, 0x0F, 0x00, 0x0F, 0xFF, 0x0F, 0x00, 0xF0, 0xFF, 0x0F, 0x00, 0xFF	| 40838E28
    .byte   0xFF, 0x0F, 0x0F, 0x00, 0xFF, 0x0F, 0x0F, 0x0F, 0xFF, 0x0F, 0x0F, 0xF0, 0xFF, 0x0F, 0x0F, 0xFF	| 40838E38
    .byte   0xFF, 0x0F, 0xF0, 0x00, 0xFF, 0x0F, 0xF0, 0x0F, 0xFF, 0x0F, 0xF0, 0xF0, 0xFF, 0x0F, 0xF0, 0xFF	| 40838E48
    .byte   0xFF, 0x0F, 0xFF, 0x00, 0xFF, 0x0F, 0xFF, 0x0F, 0xFF, 0x0F, 0xFF, 0xF0, 0xFF, 0x0F, 0xFF, 0xFF	| 40838E58
    .byte   0xFF, 0xF0, 0x00, 0x00, 0xFF, 0xF0, 0x00, 0x0F, 0xFF, 0xF0, 0x00, 0xF0, 0xFF, 0xF0, 0x00, 0xFF	| 40838E68
    .byte   0xFF, 0xF0, 0x0F, 0x00, 0xFF, 0xF0, 0x0F, 0x0F, 0xFF, 0xF0, 0x0F, 0xF0, 0xFF, 0xF0, 0x0F, 0xFF	| 40838E78
    .byte   0xFF, 0xF0, 0xF0, 0x00, 0xFF, 0xF0, 0xF0, 0x0F, 0xFF, 0xF0, 0xF0, 0xF0, 0xFF, 0xF0, 0xF0, 0xFF	| 40838E88
    .byte   0xFF, 0xF0, 0xFF, 0x00, 0xFF, 0xF0, 0xFF, 0x0F, 0xFF, 0xF0, 0xFF, 0xF0, 0xFF, 0xF0, 0xFF, 0xFF	| 40838E98
    .byte   0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x0F, 0xFF, 0xFF, 0x00, 0xF0, 0xFF, 0xFF, 0x00, 0xFF	| 40838EA8
    .byte   0xFF, 0xFF, 0x0F, 0x00, 0xFF, 0xFF, 0x0F, 0x0F, 0xFF, 0xFF, 0x0F, 0xF0, 0xFF, 0xFF, 0x0F, 0xFF	| 40838EB8
    .byte   0xFF, 0xFF, 0xF0, 0x00, 0xFF, 0xFF, 0xF0, 0x0F, 0xFF, 0xFF, 0xF0, 0xF0, 0xFF, 0xFF, 0xF0, 0xFF	| 40838EC8
    .byte   0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x0F, 0xFF, 0xFF, 0xFF, 0xF0, 0xFF, 0xFF, 0xFF, 0xFF	| 40838ED8
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40838EE8
TABLE4_408:             /* (expansion by tables) */
    moveb %a0@+,%d0
    movew %d0,%d1
    andiw #224,%d1
    lsrb #4,%d1
    movew %pc@(TABLE4_434,%d1:w),%a1@+
    movew %d0,%d1
    andiw #60,%d1
    lsrb #1,%d1
    movew %pc@(TABLE4_444,%d1:w),%a1@+
    movew %d0,%d1
    andiw #7,%d1
    addw %d1,%d1
    movew %pc@(TABLE4_464,%d1:w),%a1@+
    cmpal %a2,%a1
    jbcs TABLE4_408
    rts
TABLE4_434:             /* (data) */
    .long   0x0000000F	| 40838F1C
    .long   0x03F003FF, 0xFC00FC0F, 0xFFF0FFFF	| 40838F20
TABLE4_444:             /* (data) */
    .long   0x00000003	| 40838F2C
    .long   0x00FC00FF, 0x3F003F03, 0x3FFC3FFF, 0xC000C003	| 40838F30
    .long   0xC0FCC0FF, 0xFF00FF03, 0xFFFCFFFF	| 40838F40
TABLE4_464:             /* (data) */
    .long   0x0000003F	| 40838F4C
    .long   0x0FC00FFF, 0xF000F03F, 0xFFC0FFFF, 0x00000000	| 40838F50
    movew #8,%a1@+
    movew #4,%a1@+
    movew #63,%a1@+
    moveal %a0,%a2
    moveq #7,%d0
TABLE4_488:             /* pattern expansion: all rows the same nibble? */
    moveb %a2@,%d1
    rorb #4,%d1
    cmpb %a2@+,%d1
    dbne %d0,TABLE4_488
    jbne TABLE4_49A
    clrw %a1@(-6)
    jbra TABLE4_4D6
TABLE4_49A:             /* the pattern rows */
    moveal %a1@,%a1
TABLE4_49C:             /* each row: bits through TABLE8 with the fg/bk colors */
    moveq #0,%d1
    moveb %a0@+,%d1
    eorb %d7,%d1
    rolb %d2,%d1
    movew %d1,%d5
    andiw #240,%d1
    lsrw #2,%d1
    movel %pc@(TABLE8,%d1:w),%d1
    movel %d1,%d0
    andl %d3,%d0
    notl %d1
    andl %d4,%d1
    orl %d0,%d1
    movel %d1,%a1@+
    andiw #15,%d5
    movel %pc@(TABLE8,%d5:w:4),%d1
    movel %d1,%d0
    andl %d3,%d0
    notl %d1
    andl %d4,%d1
    orl %d0,%d1
    movel %d1,%a1@+
    dbf %d6,TABLE4_49C
    rts
TABLE4_4D6:             /* identical rows */
    moveal %a1@,%a1
    moveq #0,%d0
    moveb %a0@+,%d0
    jbra TABLE4_4E6
TABLE4_4DE:             /* same byte as the last? reuse */
    moveq #0,%d0
    moveb %a0@+,%d0
    cmpb %d5,%d0
    jbeq TABLE4_500
TABLE4_4E6:             /* expand through TABLE8 with the colors */
    moveb %d0,%d5
    eorb %d7,%d0
    rolb %d2,%d0
    andiw #240,%d0
    lsrw #2,%d0
    movel %pc@(TABLE8,%d0:w),%d1
    movel %d1,%d0
    andl %d3,%d0
    notl %d1
    andl %d4,%d1
    orl %d0,%d1
TABLE4_500:             /* store (twice, for the 8-row buffer) */
    movel %d1,%a1@+
    movel %d1,%a1@(28)
    dbf %d6,TABLE4_4DE
    rts

/* TABLE8: table. */
TABLE8:
    orib #0,%d0	| 40838FF4
    .short  0x0000, 0x00FF	| 40838FF8 orib #-1,%d0
    .short  0x0000, 0xFF00	| 40838FFC orib #0,%d0
    orib #-1,%d0	| 40839000
    .byte   0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0xFF	| 40839004
    .byte   0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0xFF	| 40839014
    .byte   0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF	| 40839024
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40839034
TABLE8_4C:              /* 1-bit to 8-bit: each nibble to a long (TABLE8) */
    moveb %a0@+,%d0
    movew %d0,%d1
    andiw #240,%d1
    lsrw #2,%d1
    movel %pc@(TABLE8,%d1:w),%a1@+
    andiw #15,%d0
    movel %pc@(TABLE8,%d0:w:4),%a1@+
    cmpal %a2,%a1
    jbcs TABLE8_4C
    rts
    .long   0x00000000	| 4083905C
TABLE8_6C:              /* 1-bit to 16-bit: each bit to a word of 0 or -1 */
    moveq #15,%d2
    movel %a0@+,%d0
TABLE8_70:              /* each bit */
    addl %d0,%d0
    subxl %d1,%d1
    addl %d0,%d0
    subxw %d1,%d1
    movel %d1,%a1@+
    cmpal %a2,%a1
    dbcc %d2,TABLE8_70
    jbcs TABLE8_6C
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40839078
    /* 1-bit pattern to 16-bit pixels: three header words (16, 12, 127), then look at the eight rows */
    movew #16,%a1@+
    movew #12,%a1@+
    movew #127,%a1@+
    moveal %a0,%a2
    moveq #7,%d0
TABLE8_70_2C:           /* a row whose byte equals itself rotated is all 0 or all 1. All eight so: first header word cleared, bit 31 of d6 set */
    moveb %a2@+,%d1	| 40839090
    moveb %d1,%d5
    rorb #1,%d1
    eorb %d1,%d5
    bnes TABLE8_70_42
    dbf %d0,TABLE8_70_2C
    bset #31,%d6
    clrw %a1@(-6)
TABLE8_70_42:
    moveal %a1@,%a1	| 408390A6
TABLE8_70_44:           /* each row: inverted by d7, rotated by d2 */
    moveb %a0@+,%d0	| 408390A8
    eorb %d7,%d0
    rolb %d2,%d0
    moveq #7,%d1
TABLE8_70_4C:           /* each bit, 0: d4. In the solid case also stored 32 bytes on, and three bits skipped */
    addb %d0,%d0	| 408390B0
    bcss TABLE8_70_66
    movew %d4,%a1@+
    tstl %d6
    bpls TABLE8_70_5C
    movew %d4,%a1@(30)
    subqw #3,%d1
TABLE8_70_5C:
    dbf %d1,TABLE8_70_4C	| 408390C0
    dbf %d6,TABLE8_70_44
    rts
TABLE8_70_66:           /* a 1: d3, the same way */
    movew %d3,%a1@+	| 408390CA
    tstl %d6
    bpls TABLE8_70_72
    movew %d3,%a1@(30)
    subqw #3,%d1
TABLE8_70_72:
    dbf %d1,TABLE8_70_4C	| 408390D6
    dbf %d6,TABLE8_70_44
    rts
    /* 1-bit pattern to 32-bit pixels: three header words (32, 28, 255), then the eight rows */
    movew #32,%a1@+	| 408390E0
    movew #28,%a1@+
    movew #255,%a1@+
    movel %a1,%d5
    moveal %a1@,%a1
    moveal %a0,%a2
    moveq #7,%d0
TABLE8_70_72_1E:        /* next row: all d7 stores d4, its complement stores d3, each as two longs 32 bytes apart. Any other row: start again, bit by bit */
    moveb %a2@+,%d1	| 408390F4
    eorb %d7,%d1
    bnes TABLE8_70_72_2C
    movel %d4,%a1@+
    movel %d4,%a1@(28)
    bras TABLE8_70_72_36
TABLE8_70_72_2C:
    addqb #1,%d1	| 40839102
    bnes TABLE8_70_72_42
    movel %d3,%a1@+
    movel %d3,%a1@(28)
TABLE8_70_72_36:
    dbf %d0,TABLE8_70_72_1E	| 4083910C
    moveal %d5,%a1
    clrw %a1@(-6)
    rts
TABLE8_70_72_42:        /* the pattern is not solid: each row bit by bit */
    moveal %d5,%a1	| 40839118
    moveal %a1@,%a1
TABLE8_70_72_46:
    moveb %a0@+,%d0	| 4083911C
    eorb %d7,%d0
    rolb %d2,%d0
    moveq #7,%d1
TABLE8_70_72_4E:        /* each bit: a 0 stores d4, a 1 stores d3 */
    addb %d0,%d0	| 40839124
    bcss TABLE8_70_72_5E
    movel %d4,%a1@+
    dbf %d1,TABLE8_70_72_4E
    dbf %d6,TABLE8_70_72_46
    rts
TABLE8_70_72_5E:
    movel %d3,%a1@+	| 40839134
    dbf %d1,TABLE8_70_72_4E
    dbf %d6,TABLE8_70_72_46
    rts
TABLE8_14C:             /* 1-bit to 32-bit: each bit to a long */
    moveq #31,%d2
    movel %a0@+,%d0
TABLE8_150:             /* each bit */
    addl %d0,%d0
    subxl %d1,%d1
    movel %d1,%a1@+
    cmpal %a2,%a1
    dbcc %d2,TABLE8_150
    jbcs TABLE8_14C
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40839154
    /* 1 bits to 16-bit pixels up to a2: 1 is black (0), 0 is white (0x7FFF). d3 = groups of 32 pixels, the remainder rotated into its high bits */
    movew #32767,%d2
    movel %a2,%d3
    subl %a1,%d3
    rorl #6,%d3
    bras TABLE8_150_3A
TABLE8_150_28:          /* next long of 32 pixels */
    moveq #31,%d4	| 4083916C
    movel %a0@+,%d0
    notl %d0
TABLE8_150_2E:          /* each bit */
    addl %d0,%d0	| 40839172
    subxw %d1,%d1
    andw %d2,%d1
    movew %d1,%a1@+
    dbf %d4,TABLE8_150_2E
TABLE8_150_3A:          /* next group; then the remaining pixels */
    dbf %d3,TABLE8_150_28	| 4083917E
    clrw %d3
    roll #5,%d3
    movel %a0@+,%d0
    notl %d0
    bras TABLE8_150_50
TABLE8_150_48:          /* each remaining pixel */
    addl %d0,%d0	| 4083918C
    subxw %d1,%d1
    andw %d2,%d1
    movew %d1,%a1@+
TABLE8_150_50:
    dbf %d3,TABLE8_150_48	| 40839194
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4083919A
    /* 1 bits to 32-bit pixels up to a2: 1 is black, 0 is white (Lo3Bytes). d3 = groups of 32 pixels, the remainder rotated into its high bits */
    movel Lo3Bytes,%d2	| 408391A0
    movel %a2,%d3
    subl %a1,%d3
    rorl #7,%d3
    bras TABLE8_150_50_2A
TABLE8_150_50_18:       /* next long of 32 pixels */
    moveq #31,%d4	| 408391AC
    movel %a0@+,%d0
    notl %d0
TABLE8_150_50_1E:       /* each bit */
    addl %d0,%d0	| 408391B2
    subxl %d1,%d1
    andl %d2,%d1
    movel %d1,%a1@+
    dbf %d4,TABLE8_150_50_1E
TABLE8_150_50_2A:       /* next group; then the remaining pixels */
    dbf %d3,TABLE8_150_50_18	| 408391BE
    clrw %d3
    roll #5,%d3
    movel %a0@+,%d0
    notl %d0
    bras TABLE8_150_50_40
TABLE8_150_50_38:       /* each remaining pixel */
    addl %d0,%d0	| 408391CC
    subxl %d1,%d1
    andl %d2,%d1
    movel %d1,%a1@+
TABLE8_150_50_40:
    dbf %d3,TABLE8_150_50_38	| 408391D4
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408391DA
TABLE8_1EC:             /* 1-bit stretch to bytes by an integer factor */
    lsrw #3,%d4
    subqw #1,%d4
    movew #-32768,%d0
TABLE8_1F4:             /* next bit */
    addw %d0,%d0
    jbne TABLE8_1FC
    movew %a0@+,%d0
    addxw %d0,%d0
TABLE8_1FC:             /* the byte value */
    scs %d1
    movew %d4,%d2
TABLE8_200:             /* repeat it */
    moveb %d1,%a1@+
    cmpal %a2,%a1
    dbhi %d2,TABLE8_200
    jbls TABLE8_1F4
    rts
TABLE8_20C:             /* 1-bit stretch by a fraction (DDA) */
    clrw %d1
    movew #-32768,%d0
    movew %d0,%d2
    movew %d4,%d3
    lsrw #1,%d3
TABLE8_218:             /* next bit */
    addw %d0,%d0
    jbcc TABLE8_226
TABLE8_21C:             /* refill */
    jbne TABLE8_224
    movew %a0@+,%d0
    addxw %d0,%d0
    jbcc TABLE8_226
TABLE8_224:             /* set */
    orw %d2,%d1
TABLE8_226:             /* step the destination; store each word */
    addw %d4,%d3
    jbcc TABLE8_218
    rorw #1,%d2
    jbcc TABLE8_218
    movew %d1,%a1@+
    clrw %d1
    cmpal %a2,%a1
    jbcs TABLE8_218
    rts
    .long   0x00000000	| 4083922C
TABLE8_23C:             /* 1-bit shrink by a fraction (or of the bits that fold together) */
    clrw %d1
    movew #-32768,%d0
    movew %d0,%d2
    movew %d4,%d3
    lsrw #1,%d3
TABLE8_248:             /* next bit */
    addw %d0,%d0
    jbcc TABLE8_26E
    jbne TABLE8_25A
    movew %a0@+,%d0
    addxw %d0,%d0
    jbcc TABLE8_26E
    jbra TABLE8_25A
TABLE8_256:             /* step */
    addw %d4,%d3
    jbcs TABLE8_248
TABLE8_25A:             /* set; next destination bit */
    orw %d2,%d1
    rorw #1,%d2
    jbcc TABLE8_256
    movew %d1,%a1@+
    clrw %d1
    cmpal %a2,%a1
    jbcs TABLE8_256
    rts
TABLE8_26A:             /* step */
    addw %d4,%d3
    jbcs TABLE8_248
TABLE8_26E:             /* next destination bit; store each word */
    rorw #1,%d2
    jbcc TABLE8_26A
    movew %d1,%a1@+
    clrw %d1
    cmpal %a2,%a1
    jbcs TABLE8_26A
    rts

TABLE8_27C:             /* save registers */
    moveml %d5/%a5,%sp@-
    movew %d4,%d2
    movew %d4,%d3
    lsrw #1,%d3
    moveq #0,%d5
    jbra TABLE8_290
TABLE8_28A:             /* 32-bit shrink: copy */
    movel %a0@+,%a1@+
    cmpal %a2,%a1
    jbcc TABLE8_2F6
TABLE8_290:             /* average the pixels that fold together */
    addw %d2,%d3
    jbcs TABLE8_28A
    movel %a0@+,%d0
    moveb %d0,%d5
    moveaw %d5,%a5
    lsrw #8,%d0
    moveaw %d0,%a4
    swap %d0
    moveb %d0,%d5
    moveaw %d5,%a3
    moveq #1,%d4
TABLE8_2A6:             /* sum the components */
    movel %a0@+,%d0
    addqw #1,%d4
    moveb %d0,%d5
    addaw %d5,%a5
    lsrw #8,%d0
    addaw %d0,%a4
    swap %d0
    moveb %d0,%d5
    addaw %d5,%a3
    addw %d2,%d3
    jbcc TABLE8_2A6
    cmpiw #2,%d4
    jblt TABLE8_2F0
    jbeq TABLE8_2DE
    moveq #0,%d1
    movel %a3,%d0
    divuw %d4,%d0
    moveb %d0,%d1
    lsll #8,%d1
    movel %a4,%d0
    divuw %d4,%d0
    moveb %d0,%d1
    lsll #8,%d1
    movel %a5,%d0
    divuw %d4,%d0
    moveb %d0,%d1
    jbra TABLE8_2F0
TABLE8_2DE:             /* the average */
    movel %a3,%d1
    lslw #7,%d1
    movel %a4,%d0
    lsrw #1,%d0
    moveb %d0,%d1
    lsll #8,%d1
    movel %a5,%d0
    lsrw #1,%d0
    moveb %d0,%d1
TABLE8_2F0:             /* store */
    movel %d1,%a1@+
    cmpal %a2,%a1
    jbcs TABLE8_290
TABLE8_2F6:             /* restore registers, return */
    moveml %sp@+,%d5/%a5
    rts
TABLE8_2FC:             /* indexed stretch/shrink by a fraction, keeping the larger pixel when shrinking */
    cmpiw #32,%d5
    jbeq TABLE8_27C
    moveml %d6-%d7,%sp@-
    moveaw %d4,%a3
    movew %d4,%d3
    lsrw #1,%d3
    moveq #0,%d2
    moveq #0,%d6
    moveq #31,%d7
    extl %d5
    movel %a0@+,%d0
    moveq #0,%d1
TABLE8_31A:             /* next destination pixel */
    subal %a4,%a4
TABLE8_31C:             /* the larger source pixel */
    bfextu %d0,%d2,%d5,%d4
    cmpl %a4,%d4
    jbls TABLE8_32A
    bfins %d4,%d1,%d6,%d5
    moveal %d4,%a4
TABLE8_32A:             /* next source pixel */
    addl %d5,%d2
    andw %d7,%d2
    jbne TABLE8_332
    movel %a0@+,%d0
TABLE8_332:             /* step; store each long */
    addw %a3,%d3
    jbcc TABLE8_31C
    addl %d5,%d6
    andw %d7,%d6
    jbne TABLE8_31A
    movel %d1,%a1@+
    moveq #0,%d1
    cmpal %a2,%a1
    jbcs TABLE8_31A
    moveml %sp@+,%d6-%d7
    rts
    .short  0x0000	| 4083933E

TABLE8_34C:             /* save registers */
    moveml %d6-%d7,%sp@-
    moveaw %d4,%a3
    movew %d4,%d3
    lsrw #1,%d3
    moveq #0,%d2
    moveq #0,%d6
    moveq #31,%d7
    extl %d5
TABLE8_35E:             /* stretch: next source long */
    movel %a0@+,%d0
TABLE8_360:             /* the source pixel */
    bfextu %d0,%d2,%d5,%d4
TABLE8_364:             /* repeat it */
    bfins %d4,%d1,%d6,%d5
    addl %d5,%d6
    andw %d7,%d6
    jbne TABLE8_374
    movel %d1,%a1@+
    cmpal %a2,%a1
    jbcc TABLE8_380
TABLE8_374:             /* step */
    addw %a3,%d3
    jbcc TABLE8_364
    addl %d5,%d2
    andw %d7,%d2
    jbne TABLE8_360
    jbra TABLE8_35E
TABLE8_380:             /* restore registers, return */
    moveml %sp@+,%d6-%d7
    rts
    .short  0x0000, 0x0000, 0x0000	| 4083937A

/* SCALEINDEXEDTOINDEXED: StretchBits pixel converter: scale indexed to indexed. */
trap_SCALEINDEXEDTOINDEXED:
SCALEINDEXEDTOINDEXED:
    moveml %d6-%d7,%sp@-
    moveq #0,%d1
    moveq #0,%d2
    moveq #31,%d7
    jbra SCALEINDEXEDTOINDEXED_12
SCALEINDEXEDTOINDEXED_C:/* next source pixel */
    addw %d3,%d1
    andw %d7,%d1
    jbne SCALEINDEXEDTOINDEXED_14
SCALEINDEXEDTOINDEXED_12:/* next source long */
    movel %a0@+,%d5
SCALEINDEXEDTOINDEXED_14:/* through the table into the destination long; store each long */
    bfextu %d5,%d1,%d3,%d0
    movel %a4@(0x0,%d0:w:4),%d0
    bfins %d0,%d6,%d2,%d4
    addw %d4,%d2
    andw %d7,%d2
    jbne SCALEINDEXEDTOINDEXED_C
    movel %d6,%a1@+
    cmpal %a2,%a1
    jbcs SCALEINDEXEDTOINDEXED_C
    moveml %sp@+,%d6-%d7
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408393B2

/* DITHER32TOINDEXED: StretchBits pixel converter: dither 32 to indexed. */
DITHER32TOINDEXED:      /* a4 = error buffer (fp-676), three words per pixel; fp-681 flips each row, so rows go in alternate directions */
    moveml %d6-%d7/%a3/%a5,%sp@-	| 408393C0
    moveal %fp@(-676),%a4
    moveq #0,%d2
    movel %d2,%d5
    movel %d2,%d6
    movel %d2,%d7
    notb %fp@(-681)
    bnes DITHER32TOINDEXED_46
    /* right to left, from fp-680: a long of output at a time */
    moveal %fp@(-680),%a0
    moveq #32,%d2
DITHER32TOINDEXED_1C:
    subw %d4,%d2	| 408393DC
DITHER32TOINDEXED_1E:   /* next pixel (the routine at +0x72); the three errors halved and kept in the buffer */
    subqw #6,%a4	| 408393DE
    movel %a0@-,%d0
    bsrs DITHER32TOINDEXED+0x72
    asrw #1,%d5
    movew %d5,%a4@
    asrw #1,%d6
    movew %d6,%a4@(2)
    asrw #1,%d7
    movew %d7,%a4@(4)
    subw %d4,%d2
    bges DITHER32TOINDEXED_1E
    moveq #32,%d2
    movel %d1,%a2@-
    cmpal %a2,%a1
    bcss DITHER32TOINDEXED_1C
    movel %a4,%fp@(-676)
    bras DITHER32TOINDEXED_6C
DITHER32TOINDEXED_46:   /* left to right, the same */
    movel %a0@+,%d0	| 40839406
    bsrs DITHER32TOINDEXED+0x72
    asrw #1,%d5
    movew %d5,%a4@+
    asrw #1,%d6
    movew %d6,%a4@+
    asrw #1,%d7
    movew %d7,%a4@+
    addw %d4,%d2
    andiw #31,%d2
    bnes DITHER32TOINDEXED_46
    movel %d1,%a1@+
    cmpal %a2,%a1
    bcss DITHER32TOINDEXED_46
    movel %a4,%fp@(-676)
    movel %a0,%fp@(-680)
DITHER32TOINDEXED_6C:
    moveml %sp@+,%d6-%d7/%a3/%a5	| 4083942C
    rts
    /* one pixel: first the stored errors are added to d5, d6, d7 */
    addw %a4@,%d5	| 40839432
    addw %a4@(2),%d6	| 40839434
    addw %a4@(4),%d7	| 40839438
    moveq #0,%d3	| 4083943C
    moveb %d0,%d3	| 4083943E
    addw %d3,%d7	| 40839440
    lsrw #8,%d0	| 40839442
    addw %d0,%d6	| 40839444
    swap %d0	| 40839446
    moveb %d0,%d3	| 40839448
    addw %d3,%d5	| 4083944A
    swap %d4	| 4083944C
    movew %fp@(-670),%d0	| 4083944E
    tstw %d5	| 40839452
    spl %d3	| 40839454
    cmpw %d3,%d5	| 40839456
    sgt %d4	| 40839458
    andb %d5,%d3	| 4083945A
    orb %d4,%d3	| 4083945C
    moveq #0,%d5	| 4083945E
    moveb %d3,%d5	| 40839460
    lsll %d0,%d3	| 40839462
    tstw %d6	| 40839464
    spl %d3	| 40839466
    cmpiw #255,%d6	| 40839468
    sgt %d4	| 4083946C
    andb %d6,%d3	| 4083946E
    orb %d4,%d3	| 40839470
    moveq #0,%d6	| 40839472
    moveb %d3,%d6	| 40839474
    lsll %d0,%d3	| 40839476
    tstw %d7	| 40839478
    spl %d3	| 4083947A
    cmpiw #255,%d7	| 4083947C
    sgt %d4	| 40839480
    andb %d7,%d3	| 40839482
    orb %d4,%d3	| 40839484
    negw %d0	| 40839486
    addqw #8,%d0	| 40839488
    moveq #0,%d7	| 4083948A
    moveb %d3,%d7	| 4083948C
    lsrl %d0,%d3	| 4083948E
    swap %d4	| 40839490
    moveq #0,%d0	| 40839492
    moveal %fp@(-652),%a3	| 40839494
    moveb %a3@(0,%d3:l),%d0	| 40839498
    bfins %d0,%d1,%d2,%d4	| 4083949C
    moveal %fp@(-668),%a3	| 408394A0
    lea %a3@(0xa,%d0:l:8),%a5	| 408394A4
    movel %a5@+,%d0	| 408394A8
    moveq #0,%d3	| 408394AA
    lsrl #8,%d0	| 408394AC
    moveb %d0,%d3	| 408394AE
    subw %d3,%d6	| 408394B0
    swap %d0	| 408394B2
    moveb %d0,%d3	| 408394B4
    subw %d3,%d5	| 408394B6
    movew %a5@+,%d0	| 408394B8
    lsrw #8,%d0	| 408394BA
    moveb %d0,%d3	| 408394BC
    subw %d3,%d7	| 408394BE
    rts	| 408394C0
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408394C2

/* DITHER16TOINDEXED: StretchBits pixel converter: dither 16 to indexed. */
DITHER16TOINDEXED:
    moveml %d6-%d7/%a3/%a5,%sp@-
    moveal %fp@(-676),%a4
    moveq #0,%d2
    movel %d2,%d5
    movel %d2,%d6
    movel %d2,%d7
    notb %fp@(-681)
    bnes DITHER16TOINDEXED_46
    moveal %fp@(-680),%a0
    moveq #32,%d2
DITHER16TOINDEXED_1C:   /* right to left: step back */
    subw %d4,%d2
DITHER16TOINDEXED_1E:   /* each pixel right to left: index with the carried error; half the new error to the next row */
    subqw #6,%a4
    movew %a0@-,%d0
    bsrs DITHER16TOINDEXED_72
    asrw #1,%d5
    movew %d5,%a4@
    asrw #1,%d6
    movew %d6,%a4@(2)
    asrw #1,%d7
    movew %d7,%a4@(4)
    subw %d4,%d2
    bges DITHER16TOINDEXED_1E
    moveq #32,%d2
    movel %d1,%a2@-
    cmpal %a2,%a1
    bcss DITHER16TOINDEXED_1C
    movel %a4,%fp@(-676)
    bras DITHER16TOINDEXED_6C
DITHER16TOINDEXED_46:   /* each pixel left to right */
    movew %a0@+,%d0
    bsrs DITHER16TOINDEXED_72
    asrw #1,%d5
    movew %d5,%a4@+
    asrw #1,%d6
    movew %d6,%a4@+
    asrw #1,%d7
    movew %d7,%a4@+
    addw %d4,%d2
    andiw #31,%d2
    bnes DITHER16TOINDEXED_46
    movel %d1,%a1@+
    cmpal %a2,%a1
    bcss DITHER16TOINDEXED_46
    movel %a4,%fp@(-676)
    movel %a0,%fp@(-680)
DITHER16TOINDEXED_6C:   /* return */
    moveml %sp@+,%d6-%d7/%a3/%a5
    rts
DITHER16TOINDEXED_72:   /* one pixel: add the carried error to each component, look up the index, the new error */
    addw %a4@,%d5
    addw %a4@(2),%d6
    addw %a4@(4),%d7
    moveq #0,%d3
    moveb %d0,%d3
    lslb #3,%d3
    addw %d3,%d7
    lsrl #5,%d0
    moveb %d0,%d3
    lslb #3,%d3
    addw %d3,%d6
    lsrl #5,%d0
    moveb %d0,%d3
    lslb #3,%d3
    addw %d3,%d5
    swap %d4
    movew %fp@(-670),%d0
    tstw %d5
    spl %d3
    cmpw %d3,%d5
    sgt %d4
    andb %d5,%d3
    orb %d4,%d3
    moveq #0,%d5
    moveb %d3,%d5
    lsll %d0,%d3
    tstw %d6
    spl %d3
    cmpiw #255,%d6
    sgt %d4
    andb %d6,%d3
    orb %d4,%d3
    moveq #0,%d6
    moveb %d3,%d6
    lsll %d0,%d3
    tstw %d7
    spl %d3
    cmpiw #255,%d7
    sgt %d4
    andb %d7,%d3
    orb %d4,%d3
    negw %d0
    addqw #8,%d0
    moveq #0,%d7
    moveb %d3,%d7
    lsrl %d0,%d3
    swap %d4
    moveq #0,%d0
    moveal %fp@(-652),%a3
    moveb %a3@(0x0,%d3:l),%d0
    bfins %d0,%d1,%d2,%d4
    moveal %fp@(-668),%a3
    lea %a3@(0xa,%d0:l:8),%a5
    movel %a5@+,%d0
    moveq #0,%d3
    lsrl #8,%d0
    moveb %d0,%d3
    subw %d3,%d6
    swap %d0
    moveb %d0,%d3
    subw %d3,%d5
    movew %a5@,%d0
    lsrw #8,%d0
    moveb %d0,%d3
    subw %d3,%d7
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 408395DE

/* DITHER32TOGRAY: StretchBits pixel converter: dither 32 to gray. */
DITHER32TOGRAY:
    moveml %d6-%d7/%a3/%a5,%sp@-
    moveal %fp@(-656),%a3
    lea %a3@(256),%a5
    moveal %fp@(-676),%a4
    moveq #0,%d5
    movel %d5,%d0
    movel %d5,%d1
    movel %d5,%d2
    notb %fp@(-681)
    bnes DITHER32TOGRAY_78
    moveal %fp@(-680),%a0
    moveq #32,%d5
DITHER32TOGRAY_24:      /* right to left: step back */
    subw %d4,%d5
DITHER32TOGRAY_26:      /* each pixel right to left: luminance (5R + 9G + 2B) / 16 plus the error; the gray index; new error */
    subqw #2,%a4
    movel %a0@-,%d3
    moveb %d3,%d2
    lsrl #8,%d3
    moveb %d3,%d1
    lsrw #8,%d3
    moveb %d3,%d0
    addw %d1,%d3
    addw %d2,%d3
    addw %d2,%d3
    lsrw #2,%d3
    addw %d0,%d3
    addw %d1,%d3
    addw %d1,%d3
    lsrw #2,%d3
    addw %d3,%d7
    addw %a4@,%d7
    spl %d2
    cmpw %d2,%d7
    sgt %d1
    andb %d2,%d7
    orb %d1,%d7
    moveb %d7,%d1
    moveb %a3@(0x0,%d1:w),%d0
    bfins %d0,%d6,%d5,%d4
    subb %a5@(0x0,%d1:w),%d7
    extw %d7
    asrw #1,%d7
    movew %d7,%a4@
    subw %d4,%d5
    bges DITHER32TOGRAY_26
    moveq #32,%d5
    movel %d6,%a2@-
    cmpal %a2,%a1
    bcss DITHER32TOGRAY_24
    movel %a4,%fp@(-676)
    bras DITHER32TOGRAY_CC
DITHER32TOGRAY_78:      /* each pixel left to right */
    movel %a0@+,%d3
    moveb %d3,%d2
    lsrl #8,%d3
    moveb %d3,%d1
    lsrw #8,%d3
    moveb %d3,%d0
    addw %d1,%d3
    addw %d2,%d3
    addw %d2,%d3
    lsrw #2,%d3
    addw %d0,%d3
    addw %d1,%d3
    addw %d1,%d3
    lsrw #2,%d3
    addw %d3,%d7
    addw %a4@,%d7
    spl %d2
    cmpw %d2,%d7
    sgt %d1
    andb %d2,%d7
    orb %d1,%d7
    moveb %d7,%d1
    moveb %a3@(0x0,%d1:w),%d0
    bfins %d0,%d6,%d5,%d4
    subb %a5@(0x0,%d1:w),%d7
    extw %d7
    asrw #1,%d7
    movew %d7,%a4@+
    addw %d4,%d5
    andiw #31,%d5
    bnes DITHER32TOGRAY_78
    movel %d6,%a1@+
    cmpal %a2,%a1
    bcss DITHER32TOGRAY_78
    movel %a4,%fp@(-676)
    movel %a0,%fp@(-680)
DITHER32TOGRAY_CC:      /* return */
    moveml %sp@+,%d6-%d7/%a3/%a5
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408396B2

/* DITHER16TOGRAY: StretchBits pixel converter: dither 16 to gray. */
DITHER16TOGRAY:
    moveml %d6-%d7/%a3/%a5,%sp@-
    moveq #0,%d3
    moveal %fp@(-656),%a3
    lea %a3@(256),%a5
    moveal %fp@(-676),%a4
    moveq #0,%d5
    movel %d5,%d0
    movel %d5,%d1
    movel %d5,%d2
    notb %fp@(-681)
    bnes DITHER16TOGRAY_90
    moveal %fp@(-680),%a0
    moveq #32,%d5
DITHER16TOGRAY_26:      /* right to left: step back */
    subw %d4,%d5
DITHER16TOGRAY_28:      /* each pixel right to left: expand the 5-bit components, luminance plus the error */
    subqw #2,%a4
    movew %a0@-,%d3
    lsll #3,%d3
    moveb %d3,%d2
    lslw #5,%d2
    moveb %d3,%d2
    lsrw #5,%d2
    lsrl #5,%d3
    moveb %d3,%d1
    lslw #5,%d1
    moveb %d3,%d1
    lsrw #5,%d1
    lsrl #5,%d3
    moveb %d3,%d0
    lslw #5,%d0
    moveb %d3,%d0
    lsrw #5,%d0
    movew %d0,%d3
    addw %d1,%d3
    addw %d2,%d3
    addw %d2,%d3
    lsrw #2,%d3
    addw %d0,%d3
    addw %d1,%d3
    addw %d1,%d3
    lsrw #2,%d3
    addw %d3,%d7
    addw %a4@,%d7
    spl %d2
    cmpw %d2,%d7
    sgt %d1
    andb %d2,%d7
    orb %d1,%d7
    moveb %d7,%d1
    moveb %a3@(0x0,%d1:w),%d0
    bfins %d0,%d6,%d5,%d4
    subb %a5@(0x0,%d1:w),%d7
    extw %d7
    asrw #1,%d7
    movew %d7,%a4@
    subw %d4,%d5
    bges DITHER16TOGRAY_28
    moveq #32,%d5
    movel %d6,%a2@-
    cmpal %a2,%a1
    bcss DITHER16TOGRAY_26
    movel %a4,%fp@(-676)
    bras DITHER16TOGRAY_FA
DITHER16TOGRAY_90:      /* each pixel left to right */
    movew %a0@+,%d3
    lsll #3,%d3
    moveb %d3,%d2
    lslw #5,%d2
    moveb %d3,%d2
    lsrw #5,%d2
    lsrl #5,%d3
    moveb %d3,%d1
    lslw #5,%d1
    moveb %d3,%d1
    lsrw #5,%d1
    lsrl #5,%d3
    moveb %d3,%d0
    lslw #5,%d0
    moveb %d3,%d0
    lsrw #5,%d0
    movew %d0,%d3
    addw %d1,%d3
    addw %d2,%d3
    addw %d2,%d3
    lsrw #2,%d3
    addw %d0,%d3
    addw %d1,%d3
    addw %d1,%d3
    lsrw #2,%d3
    addw %d3,%d7
    addw %a4@,%d7
    spl %d2
    cmpw %d2,%d7
    sgt %d1
    andb %d2,%d7
    orb %d1,%d7
    moveb %d7,%d1
    moveb %a3@(0x0,%d1:w),%d0
    bfins %d0,%d6,%d5,%d4
    subb %a5@(0x0,%d1:w),%d7
    extw %d7
    asrw #1,%d7
    movew %d7,%a4@+
    addw %d4,%d5
    andiw #31,%d5
    bnes DITHER16TOGRAY_90
    movel %d6,%a1@+
    cmpal %a2,%a1
    bcss DITHER16TOGRAY_90
    movel %a4,%fp@(-676)
    movel %a0,%fp@(-680)
DITHER16TOGRAY_FA:      /* return */
    moveml %sp@+,%d6-%d7/%a3/%a5
    rts

/* SCALE32TOINDEXED: StretchBits pixel converter: scale 32 to indexed. */
SCALE32TOINDEXED:
    moveml %d6-%d7/%a3/%a5,%sp@-
    moveq #0,%d2
    moveal %fp@(-652),%a3
    movew %fp@(-670),%d1
    moveq #8,%d3
    movew %d3,%d7
    subw %d1,%d7
    movel %a0@+,%d5
    jbra SCALE32TOINDEXED_1E
SCALE32TOINDEXED_18:    /* next pixel: same as the last? reuse the index */
    movel %a0@+,%d5
    cmpal %d5,%a5
    jbeq SCALE32TOINDEXED_3A
SCALE32TOINDEXED_1E:    /* the inverse table index from the high bits of R, G, B */
    moveal %d5,%a5
    moveq #0,%d0
    movew %d5,%d3
    swap %d5
    moveb %d5,%d0
    lsll %d1,%d0
    lsrl #8,%d3
    moveb %d3,%d0
    lsll %d1,%d0
    swap %d5
    moveb %d5,%d0
    lsrl %d7,%d0
    moveb %a3@(0x0,%d0:w),%d0
SCALE32TOINDEXED_3A:    /* insert; store each long */
    bfins %d0,%d6,%d2,%d4
    addw %d4,%d2
    andiw #31,%d2
    jbne SCALE32TOINDEXED_18
    movel %d6,%a1@+
    cmpal %a2,%a1
    jbcs SCALE32TOINDEXED_18
    moveml %sp@+,%d6-%d7/%a3/%a5
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40839812

/* SCALE32TOGRAY: StretchBits pixel converter: scale 32 to gray. */
SCALE32TOGRAY:
    moveml %d6/%a3/%a5,%sp@-
    moveq #0,%d5
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d2
    moveal %fp@(-656),%a3
    movel %a0@+,%d3
    bras SCALE32TOGRAY_1A
SCALE32TOGRAY_14:       /* next pixel: same as the last? reuse */
    movel %a0@+,%d3
    cmpal %d3,%a5
    beqs SCALE32TOGRAY_3A
SCALE32TOGRAY_1A:       /* luminance (5R + 9G + 2B) / 16 to the gray index */
    moveal %d3,%a5
    moveb %d3,%d2
    lsrl #8,%d3
    moveb %d3,%d1
    lsrw #8,%d3
    moveb %d3,%d0
    addw %d1,%d3
    addw %d2,%d3
    addw %d2,%d3
    lsrw #2,%d3
    addw %d0,%d3
    addw %d1,%d3
    addw %d1,%d3
    lsrw #2,%d3
    moveb %a3@(0x0,%d3:w),%d0
SCALE32TOGRAY_3A:       /* insert; store each long */
    bfins %d0,%d6,%d5,%d4
    addw %d4,%d5
    andiw #31,%d5
    bnes SCALE32TOGRAY_14
    movel %d6,%a1@+
    cmpal %a2,%a1
    bcss SCALE32TOGRAY_14
    moveml %sp@+,%d6/%a3/%a5
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40839872

/* SCALE32TOBITMAP: StretchBits pixel converter: scale 32 to bitmap. */
SCALE32TOBITMAP:
    moveml %d6/%a3/%a5,%sp@-
    moveq #0,%d5
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d2
    movel %a0@+,%d3
    bras SCALE32TOBITMAP_16
SCALE32TOBITMAP_10:     /* next pixel: same as the last? reuse */
    movel %a0@+,%d3
    cmpal %d3,%a5
    beqs SCALE32TOBITMAP_36
SCALE32TOBITMAP_16:     /* luminance: dark is black */
    moveal %d3,%a5
    moveb %d3,%d2
    lsrl #8,%d3
    moveb %d3,%d1
    lsrw #8,%d3
    moveb %d3,%d0
    addw %d1,%d3
    addw %d2,%d3
    addw %d2,%d3
    lsrw #2,%d3
    addw %d0,%d3
    addw %d1,%d3
    addw %d1,%d3
    lsrw #2,%d3
    tstb %d3
    spl %d0
SCALE32TOBITMAP_36:     /* insert the bit; store each long */
    bfins %d0,%d6,%d5,%d4
    addw %d4,%d5
    andiw #31,%d5
    bnes SCALE32TOBITMAP_10
    movel %d6,%a1@+
    cmpal %a2,%a1
    bcss SCALE32TOBITMAP_10
    moveml %sp@+,%d6/%a3/%a5
    rts
    .short  0x0000	| 408398CE

/* SCALE16TOGRAY: StretchBits pixel converter: scale 16 to gray. */
SCALE16TOGRAY:
    moveml %d6/%a3/%a5,%sp@-
    moveq #0,%d5
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d2
    moveal %fp@(-656),%a3
    movew %a0@+,%d3
    jbra SCALE16TOGRAY_1A
SCALE16TOGRAY_14:       /* next pixel: same as the last? */
    movew %a0@+,%d3
    cmpaw %d3,%a5
    jbeq SCALE16TOGRAY_50
SCALE16TOGRAY_1A:       /* its luminance from the 5-bit components */
    moveaw %d3,%a5
    lsll #3,%d3
    moveb %d3,%d2
    lslw #5,%d2
    moveb %d3,%d2
    lsrw #5,%d2
    lsrl #5,%d3
    moveb %d3,%d1
    lslw #5,%d1
    moveb %d3,%d1
    lsrw #5,%d1
    lsrl #5,%d3
    moveb %d3,%d0
    lslw #5,%d0
    moveb %d3,%d0
    lsrw #5,%d0
    movew %d0,%d3
    addw %d1,%d3
    addw %d2,%d3
    addw %d2,%d3
    lsrw #2,%d3
    addw %d0,%d3
    addw %d1,%d3
    addw %d1,%d3
    lsrw #2,%d3
    moveb %a3@(0x0,%d3:w),%d0
SCALE16TOGRAY_50:       /* insert; store each long */
    bfins %d0,%d6,%d5,%d4
    addw %d4,%d5
    andiw #31,%d5
    jbne SCALE16TOGRAY_14
    movel %d6,%a1@+
    cmpal %a2,%a1
    jbcs SCALE16TOGRAY_14
    moveml %sp@+,%d6/%a3/%a5
    rts
    .long   0x00000000, 0x00000000	| 40839938

/* SCALE16TOBITMAP: StretchBits pixel converter: scale 16 to bitmap. */
SCALE16TOBITMAP:
    moveml %d6/%a3/%a5,%sp@-
    moveq #0,%d5
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d2
    movew %a0@+,%d3
    bras SCALE16TOBITMAP_16
SCALE16TOBITMAP_10:     /* next pixel: same as the last? reuse */
    movew %a0@+,%d3
    cmpaw %d3,%a5
    beqs SCALE16TOBITMAP_4C
SCALE16TOBITMAP_16:     /* expand the 5-bit components; luminance: dark is black */
    moveaw %d3,%a5
    lsll #3,%d3
    moveb %d3,%d2
    lslw #5,%d2
    moveb %d3,%d2
    lsrw #5,%d2
    lsrl #5,%d3
    moveb %d3,%d1
    lslw #5,%d1
    moveb %d3,%d1
    lsrw #5,%d1
    lsrl #5,%d3
    moveb %d3,%d0
    lslw #5,%d0
    moveb %d3,%d0
    lsrw #5,%d0
    movew %d0,%d3
    addw %d1,%d3
    addw %d2,%d3
    addw %d2,%d3
    lsrw #2,%d3
    addw %d0,%d3
    addw %d1,%d3
    addw %d1,%d3
    lsrw #2,%d3
    tstb %d3
    spl %d0
SCALE16TOBITMAP_4C:     /* insert the bit; store each long */
    bfins %d0,%d6,%d5,%d4
    addw %d4,%d5
    andiw #31,%d5
    bnes SCALE16TOBITMAP_10
    movel %d6,%a1@+
    cmpal %a2,%a1
    bcss SCALE16TOBITMAP_10
    moveml %sp@+,%d6/%a3/%a5
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408399A4

/* SEARCH32TOINDEXED: StretchBits pixel converter: search 32 to indexed. */
SEARCH32TOINDEXED:
    moveml %d6-%d7/%a3-%a5,%sp@-
    moveal %a0,%a4
    moveal %a1,%a3
    moveal %fp@(-464),%a5
    moveq #0,%d0
    movel %a2,%d7
    jsr @(0x574,%za0)@(0x0)	| 408399C0
    moveal %d7,%a2
    moveq #0,%d7
    clrl %sp@-
    clrl %sp@-
    clrw %sp@-
SEARCH32TOINDEXED_20:   /* next pixel: its RGB (bytes doubled to 16 bits) */
    movel %a4@+,%d5
    moveb %d5,%sp@(4)
    moveb %d5,%sp@(5)
    rorl #8,%d5
    moveb %d5,%sp@(2)
    moveb %d5,%sp@(3)
    rorl #8,%d5
    moveb %d5,%sp@
    moveb %d5,%sp@(1)
    movel %fp@(-660),%fp@(-664)
SEARCH32TOINDEXED_42:   /* each search proc: does it answer? */
    movel %fp@(-664),%d0
    beqs SEARCH32TOINDEXED_6A
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@,%fp@(-664)
    clrb %sp@-
    pea %sp@(2)
    pea %sp@(12)
    moveal %a0@(4),%a0
    jsr %a0@
    tstb %sp@+
    beqs SEARCH32TOINDEXED_42
    movel %sp@(6),%d3
    bras SEARCH32TOINDEXED_8A
SEARCH32TOINDEXED_6A:   /* none: the inverse table index */
    moveal %fp@(-652),%a0
    movew %fp@(-670),%d1
    bfextu %d5,8,%d1,%d0
    lsll %d1,%d0
    bfextu %d5,16,%d1,%d3
    orl %d3,%d0
    lsll %d1,%d0
    bfextu %d5,24,%d1,%d3
    orl %d3,%d0
    moveb %a0@(0x0,%d0:l),%d3
SEARCH32TOINDEXED_8A:   /* insert; store each long; restore the addressing mode */
    bfins %d3,%d6,%d7,%d4
    addw %d4,%d7
    andiw #31,%d7
    bnes SEARCH32TOINDEXED_20
    movel %d6,%a3@+
    cmpal %a2,%a3
    bcss SEARCH32TOINDEXED_20
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 40839A4E
    lea %sp@(10),%sp
    moveml %sp@+,%d6-%d7/%a3-%a5
    rts
    .short  0x0000	| 40839A5E

/* SCALE32TO16: StretchBits pixel converter: scale 32 to 16. */
SCALE32TO16:
    movel %a2,%d2
    subl %a1,%d2
    lsrl #2,%d2
    subqw #1,%d2
SCALE32TO16_8:          /* two pixels: 8-bit components to 5 bits, packed into one long */
    movel %a0@+,%d0
    rorl #8,%d0
    lsrw #3,%d0
    rorl #5,%d0
    lsrw #3,%d0
    rorl #6,%d0
    movel %a0@+,%d1
    rorl #8,%d1
    lsrw #3,%d1
    rorl #5,%d1
    lsrw #3,%d1
    rorl #6,%d1
    swap %d1
    movew %d1,%d0
    movel %d0,%a1@+
    dbf %d2,SCALE32TO16_8
    rts
    .short  0x0000, 0x0000	| orib #0,%d0

/* SEARCH32TO16: StretchBits pixel converter: search 32 to 16. */
SEARCH32TO16:
    .long   0x48E7011C	| 40839A90
    moveal %a0,%a4
    moveal %a1,%a3
    moveal %fp@(-464),%a5
    moveq #0,%d0
    movel %a2,%d7
    jsr @(0x574,%za0)@(0x0)	| 40839AA0
    moveal %d7,%a2
    clrl %sp@-
    clrl %sp@-
    clrw %sp@-
    jbra SEARCH32TO16_72

SEARCH32TO16_20:        /* one pixel through the search procs */
    movel %a4@+,%d5
    moveb %d5,%sp@(8)
    rorl #8,%d5
    moveb %d5,%sp@(6)
    rorl #8,%d5
    moveb %d5,%sp@(4)
    movel %fp@(-660),%fp@(-664)
SEARCH32TO16_38:        /* each proc: does it answer? */
    movel %fp@(-664),%d0
    jbeq SEARCH32TO16_60
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@,%fp@(-664)
    clrb %sp@-
    pea %sp@(6)
    pea %sp@(16)
    moveal %a0@(4),%a0
    jsr %a0@
    tstb %sp@+
    jbeq SEARCH32TO16_38
    movel %sp@(10),%d0
    rts
SEARCH32TO16_60:        /* none: the 16-bit value from the components */
    movel %a4@(-4),%d0
    rorl #8,%d0
    lsrw #3,%d0
    rorl #5,%d0
    lsrw #3,%d0
    rorl #6,%d0
    swap %d0
    rts

SEARCH32TO16_72:        /* two pixels per long */
    jbsr SEARCH32TO16_20
    movew %d0,%d7
    swap %d7
    jbsr SEARCH32TO16_20
    movew %d0,%d7
    movel %d7,%a3@+
    cmpal %a2,%a3
    jbcs SEARCH32TO16_72
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 40839B14
    lea %sp@(10),%sp
    moveml %sp@+,%d7/%a3-%a5
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40839B24

/* SCALE16TOINDEXED: StretchBits pixel converter: scale 16 to indexed. */
SCALE16TOINDEXED:
    moveml %d6-%d7/%a3/%a5,%sp@-
    moveq #0,%d2
    moveal %fp@(-652),%a3
    movew %fp@(-670),%d1
    movel %a0@+,%d5
    bras SCALE16TOINDEXED_18
SCALE16TOINDEXED_12:    /* two pixels: same pair as the last? reuse */
    movel %a0@+,%d5
    cmpal %d5,%a5
    beqs SCALE16TOINDEXED_4A
SCALE16TOINDEXED_18:    /* inverse table index of each from its 5-bit components */
    moveal %d5,%a5
    bfextu %d5,1,%d1,%d0
    lsll %d1,%d0
    bfextu %d5,6,%d1,%d3
    orl %d3,%d0
    lsll %d1,%d0
    bfextu %d5,11,%d1,%d3
    orl %d3,%d0
    moveb %a3@(0x0,%d0:w),%d0
    bfextu %d5,17,%d1,%d7
    lsll %d1,%d7
    bfextu %d5,22,%d1,%d3
    orl %d3,%d7
    lsll %d1,%d7
    bfextu %d5,27,%d1,%d3
    orl %d3,%d7
    moveb %a3@(0x0,%d7:w),%d7
SCALE16TOINDEXED_4A:    /* insert both; store each long */
    bfins %d0,%d6,%d2,%d4
    addw %d4,%d2
    bfins %d7,%d6,%d2,%d4
    addw %d4,%d2
    andiw #31,%d2
    bnes SCALE16TOINDEXED_12
    movel %d6,%a1@+
    cmpal %a2,%a1
    bcss SCALE16TOINDEXED_12
    moveml %sp@+,%d6-%d7/%a3/%a5
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40839B98

/* SEARCH16TOINDEXED: StretchBits pixel converter: search 16 to indexed. */
SEARCH16TOINDEXED:
    moveml %d6-%d7/%a3-%a5,%sp@-
    moveal %a0,%a4
    moveal %a1,%a3
    moveal %fp@(-464),%a5
    moveq #0,%d0
    movel %a2,%d7
    jsr @(0x574,%za0)@(0x0)	| 40839BB0
    moveal %d7,%a2
    moveq #0,%d7
    clrl %sp@-
    clrl %sp@-
    clrw %sp@-
SEARCH16TOINDEXED_20:   /* next pixel: its RGB from the 5-bit components */
    movew %a4@+,%d5
    lsll #3,%d5
    moveb %d5,%d0
    lsll #5,%d0
    moveb %d5,%d0
    lsll #5,%d0
    moveb %d5,%d0
    lsll #5,%d0
    moveb %d5,%d0
    lsrl #7,%d0
    movew %d0,%sp@(4)
    lsrl #5,%d5
    moveb %d5,%d0
    lsll #5,%d0
    moveb %d5,%d0
    lsll #5,%d0
    moveb %d5,%d0
    lsll #5,%d0
    moveb %d5,%d0
    lsrl #7,%d0
    movew %d0,%sp@(2)
    lsrl #5,%d5
    moveb %d5,%d0
    lsll #5,%d0
    moveb %d5,%d0
    lsll #5,%d0
    moveb %d5,%d0
    lsll #5,%d0
    moveb %d5,%d0
    lsrl #7,%d0
    movew %d0,%sp@
    movel %fp@(-660),%fp@(-664)
SEARCH16TOINDEXED_68:   /* each search proc: does it answer? */
    movel %fp@(-664),%d0
    beqs SEARCH16TOINDEXED_90
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@,%fp@(-664)
    clrb %sp@-
    pea %sp@(2)
    pea %sp@(12)
    moveal %a0@(4),%a0
    jsr %a0@
    tstb %sp@+
    beqs SEARCH16TOINDEXED_68
    movel %sp@(6),%d3
    bras SEARCH16TOINDEXED_B0
SEARCH16TOINDEXED_90:   /* none: the inverse table index */
    moveal %fp@(-652),%a0
    movew %fp@(-670),%d1
    bfextu %d5,17,%d1,%d0
    lsll %d1,%d0
    bfextu %d5,22,%d1,%d3
    orl %d3,%d0
    lsll %d1,%d0
    bfextu %d5,27,%d1,%d3
    orl %d3,%d0
    moveb %a0@(0x0,%d0:w),%d0
SEARCH16TOINDEXED_B0:   /* insert; store each long; restore the addressing mode */
    bfins %d0,%d6,%d7,%d4
    addw %d4,%d7
    andiw #31,%d7
    bnew SEARCH16TOINDEXED_20
    movel %d6,%a3@+
    cmpal %a2,%a3
    bcsw SEARCH16TOINDEXED_20
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 40839C68
    lea %sp@(10),%sp
    moveml %sp@+,%d6-%d7/%a3-%a5
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40839C78

/* SCALE16TO32: StretchBits pixel converter: scale 16 to 32. */
SCALE16TO32:
    movel %a2,%d4	| 40839C80
    subl %a1,%d4	| 40839C82
    lsrl #3,%d4	| 40839C84
    subqw #1,%d4	| 40839C86
    jbmi SCALE16TO32_70	| 40839C88
    movel %a0@+,%d5	| 40839C8A
    jbra SCALE16TO32_14	| 40839C8C
SCALE16TO32_E:          /* two pixels: same as the last? reuse */
    movel %a0@+,%d5	| 40839C8E
    cmpl %d0,%d5	| 40839C90
    jbeq SCALE16TO32_62	| 40839C92
SCALE16TO32_14:         /* expand each 5-bit component to 8 bits */
    movel %d5,%d0	| 40839C94
    moveq #0,%d3	| 40839C96
    movew %d5,%d1	| 40839C98
    lsrw #7,%d1	| 40839C9A
    moveb %d1,%d3	| 40839C9C
    lsll #5,%d3	| 40839C9E
    moveb %d1,%d3	| 40839CA0
    lsll #3,%d3	| 40839CA2
    movew %d5,%d1	| 40839CA4
    lsrw #2,%d1	| 40839CA6
    moveb %d1,%d3	| 40839CA8
    lsll #5,%d3	| 40839CAA
    moveb %d1,%d3	| 40839CAC
    lsll #3,%d3	| 40839CAE
    moveb %d5,%d1	| 40839CB0
    lslb #3,%d1	| 40839CB2
    moveb %d1,%d3	| 40839CB4
    lsll #5,%d3	| 40839CB6
    moveb %d1,%d3	| 40839CB8
    lsrl #5,%d3	| 40839CBA
    swap %d5	| 40839CBC
    moveq #0,%d2	| 40839CBE
    movew %d5,%d1	| 40839CC0
    lsrw #7,%d1	| 40839CC2
    moveb %d1,%d2	| 40839CC4
    lsll #5,%d2	| 40839CC6
    moveb %d1,%d2	| 40839CC8
    lsll #3,%d2	| 40839CCA
    movew %d5,%d1	| 40839CCC
    lsrw #2,%d1	| 40839CCE
    moveb %d1,%d2	| 40839CD0
    lsll #5,%d2	| 40839CD2
    moveb %d1,%d2	| 40839CD4
    lsll #3,%d2	| 40839CD6
    lslb #3,%d5	| 40839CD8
    moveb %d5,%d2	| 40839CDA
    lsll #5,%d2	| 40839CDC
    moveb %d5,%d2	| 40839CDE
    lsrl #5,%d2	| 40839CE0
SCALE16TO32_62:         /* store; next */
    movel %d2,%a1@+	| 40839CE2
    movel %d3,%a1@+	| 40839CE4
    dbf %d4,SCALE16TO32_E	| 40839CE6
    cmpal %a1,%a2	| 40839CEA
    jbne SCALE16TO32_70	| 40839CEC
    rts	| 40839CEE
SCALE16TO32_70:         /* an odd last pixel */
    movew %a0@+,%d5	| 40839CF0
    moveq #0,%d2	| 40839CF2
    movew %d5,%d1	| 40839CF4
    lsrw #7,%d1	| 40839CF6
    moveb %d1,%d2	| 40839CF8
    lsll #5,%d2	| 40839CFA
    moveb %d1,%d2	| 40839CFC
    lsll #3,%d2	| 40839CFE
    movew %d5,%d1	| 40839D00
    lsrw #2,%d1	| 40839D02
    moveb %d1,%d2	| 40839D04
    lsll #5,%d2	| 40839D06
    moveb %d1,%d2	| 40839D08
    lsll #3,%d2	| 40839D0A
    lslb #3,%d5	| 40839D0C
    moveb %d5,%d2	| 40839D0E
    lsll #5,%d2	| 40839D10
    moveb %d5,%d2	| 40839D12
    lsrl #5,%d2	| 40839D14
    movel %d2,%a1@	| 40839D16
    rts	| 40839D18
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40839D1A

/* SEARCH16TO32: StretchBits pixel converter: search 16 to 32. */
SEARCH16TO32:
    moveml %d7/%a3-%a5,%sp@-
    moveal %a0,%a4
    moveal %a1,%a3
    moveal %fp@(-464),%a5
    moveq #0,%d0
    movel %a2,%d7
    jsr @(0x574,%za0)@(0x0)	| 40839D30
    moveal %d7,%a2
    clrl %sp@-
    clrl %sp@-
    clrw %sp@-
SEARCH16TO32_1E:        /* next pixel: its RGB from the 5-bit components */
    movew %a4@+,%d5
    movew %d5,%d0
    lsll #3,%d0
    moveb %d0,%sp@(4)
    clrb %d0
    lsrl #5,%d0
    moveb %d0,%sp@(2)
    clrb %d0
    lsrl #5,%d0
    moveb %d0,%sp@
    movel %fp@(-660),%fp@(-664)
SEARCH16TO32_3C:        /* each search proc: does it answer? */
    movel %fp@(-664),%d0
    beqs SEARCH16TO32_64
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@,%fp@(-664)
    clrb %sp@-
    pea %sp@(2)
    pea %sp@(12)
    moveal %a0@(4),%a0
    jsr %a0@
    tstb %sp@+
    beqs SEARCH16TO32_3C
    movel %sp@(6),%d3
    bras SEARCH16TO32_8A
SEARCH16TO32_64:        /* none: expand the components to 8 bits */
    moveq #0,%d3
    movew %d5,%d1
    lsrw #7,%d1
    moveb %d1,%d3
    lsll #5,%d3
    moveb %d1,%d3
    lsll #3,%d3
    movew %d5,%d1
    lsrw #2,%d1
    moveb %d1,%d3
    lsll #5,%d3
    moveb %d1,%d3
    lsll #3,%d3
    moveb %d5,%d1
    lslb #3,%d1
    moveb %d1,%d3
    lsll #5,%d3
    moveb %d1,%d3
    lsrl #5,%d3
SEARCH16TO32_8A:        /* store; next; restore the addressing mode */
    movel %d3,%a3@+
    cmpal %a2,%a3
    bcss SEARCH16TO32_1E
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 40839DB2
    lea %sp@(10),%sp
    moveml %sp@+,%d7/%a3-%a5
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40839DC2

/*
 SCALEBLT: CopyBits without stretching but with a depth change (called from StretchBits'
 set-up): the source pixels go through a conversion loop picked from the tables at 0x1CB0
 (indexed to indexed, through a translation table built on the stack) or 0x1CC8 (direct
 sources: 16/32-bit to indexed by the inverse table, dithered when fp-165 asks for it, or
 to the other direct depth), row by row inside the region's runs (SEEKRGN builds the run
 list at fp-12). Returns d0 = 0 when done, 1 when it cannot do it (StretchBits then takes
 the general path). The stack left for buffers is counted in fp-132 (StackSpace - 1600).
*/
trap_SCALEBLT:
SCALEBLT:
    movel %sp,%fp@(-600)
    movel %d0,%fp@(-520)
    movel %d1,%fp@(-524)
    moveal 0x594,%a0
    jsr %a0@
    lsrl #2,%d0
    subil #1600,%d0
    movel %d0,%fp@(-132)
    jbpl SCALEBLT_26
    jsr @(0x1c5c,%za0)@(0)	| 40839DF0
SCALEBLT_26:            /* a direct source (pixel type 16)? else indexed (SCALEBLT_138) */
    movew %fp@(-330),%d0
    jbeq SCALEBLT_138
    cmpiw #16,%d0
    jbne SCALEBLT_3C2
    clrl %fp@(-676)
    movew %d4,%d5
    lslw #3,%d5
    cmpiw #4,%d3
    jbeq SCALEBLT_48
    bset #2,%d5
SCALEBLT_48:            /* 16-bit destination: no table needed; else the destination's inverse table */
    moveal @(TheGDevice,%za0)@(0),%a2	| 40839E18
    cmpiw #16,%fp@(-214)
    jbeq SCALEBLT_11C
    moveal %a2@(0x16,%za0)@(0x0),%a1	| 40839E28
    moveal %a1@(42),%a0
    movel %a0@(0,%za0)@(0),%d1	| 40839E32
    moveal %a2@(6,%za0)@(0),%a0
    cmpl %a0@,%d1
    jbeq SCALEBLT_9A
    movel %a1@(42),%sp@-
    movel %a2@(6),%sp@-
    movew %a2@(10),%sp@-
    jsr @(0x16e4,%za0)@(0)	| 40839E4C
    tstw QDErr
    jbeq SCALEBLT_8E
    addqw #4,%sp
    jbra SCALEBLT_3C2
SCALEBLT_8E:            /* (inverse table built) */
    moveal @(TheGDevice,%za0)@(0),%a2	| 40839E5E
    moveal %a2@(6,%za0)@(0),%a0
SCALEBLT_9A:            /* the inverse table, its resolution; with hidden colors (Ask), the extra table */
    addqw #6,%a0
    movel %a0,%fp@(-652)
    subqw #6,%a0
    movew %a0@(4),%fp@(-670)
    moveal %a2@(0x16,%za0)@(0x0),%a1	| 40839E78
    movel %a1@(0x2a,%za0)@(0),%fp@(-668)
    moveq #1,%d0
    movew %a0@(4),%d2
    lsll %d2,%d0
    lsll %d2,%d0
    lsll %d2,%d0
    lea %a0@(0x6,%d0:l),%a1
    tstw %a1@(2)
    jbpl SCALEBLT_DA
    addqw #6,%a1
    movel %a1,%fp@(-656)
    addqw #2,%d5
    moveq #40,%d0
    cmpl %a0@,%d0
    jbeq SCALEBLT_11C
SCALEBLT_DA:            /* dither? the error buffer on the stack */
    tstb %fp@(-165)
    jbeq SCALEBLT_11C
    addqw #1,%d5
    moveq #0,%d0
    movew %fp@(-518),%d0
    lsll %d4,%d0
    addil #128,%d0
    lsrl %d4,%d0
    btst #1,%d5
    jbne SCALEBLT_FE
    movew %d0,%d1
    addw %d0,%d0
    addw %d1,%d0
SCALEBLT_FE:            /* buffer size */
    lsrw #1,%d0
    subl %d0,%fp@(-132)
    jbpl SCALEBLT_10C
    jsr @(0x1c5c,%za0)@(0)	| 40839ED6
SCALEBLT_10C:           /* error buffer */
    clrl %sp@-
SCALEBLT_10E:           /* clear it */
    clrl %sp@-
    dbf %d0,SCALEBLT_10E
    movel %sp,%fp@(-676)
    clrb %fp@(-681)
SCALEBLT_11C:           /* the conversion loop from the 0x1CC8 table */
    movew %d5,%d0
    lsrw #3,%d0
    lea @(0x1cc8,%d0:w:4),%a0
    moveal %a0@,%a0
    andiw #7,%d5
    addal %a0@(0x0,%d5:w:4),%a0
    movel %a0,%fp@(-552)
    jbra SCALEBLT_1EC
SCALEBLT_138:           /* indexed source: the translation table on the stack (one long per source color) */
    movew %d4,%d5
    lslw #2,%d5
    orw %d3,%d5
    movew %fp@(-328),%d1
    moveq #1,%d0
    lslw %d1,%d0
    subl %d0,%fp@(-132)
    jbpl SCALEBLT_152
    jsr @(0x1c5c,%za0)@(0)	| 40839F1C
SCALEBLT_152:           /* 1-bit destination with a pixmap mask? search by luminance (ONEBITPROC) */
    moveq #0,%d7
    cmpiw #1,%fp@(-212)
    jbne SCALEBLT_172
    moveal %fp@(40),%a1
    tstw %a1@(4)
    jbmi SCALEBLT_172
    moveq #1,%d7
    pea %pc@(ONEBITPROC)
    jsr @(0x16e8,%za0)@(0)	| 40839F3C
SCALEBLT_172:           /* build the table; same depth and an identity table: plain copy */
    moveal %fp@(-464),%a5
    movel %a4,%sp@-
    movew #32,%sp@-
    jsr @(0x1a38,%za0)@(0)	| 40839F4C
    movew %fp@(-328),%d1
    cmpw %fp@(-212),%d1
    jbne SCALEBLT_1BE
    moveq #1,%d0
    lslw %d1,%d0
    movew %d0,%d1
    lslw #2,%d1
    subqw #1,%d0
    moveal %sp,%a0
    addaw %d1,%a0
SCALEBLT_19A:           /* identity table? */
    cmpl %a0@-,%d0
    dbne %d0,SCALEBLT_19A
    jbne SCALEBLT_1BE
    tstw %d7
    jbeq SCALEBLT_1B0
    pea %pc@(ONEBITPROC)
    jsr @(0x1730,%za0)@(0x0)	| 40839F7A
SCALEBLT_1B0:           /* identity: nothing to convert (d0 = 0 path) */
    lea %fp@(-244),%a5
    movel %fp@(-456),%d7
    moveq #0,%d0
    jbra SCALEBLT_3C4
SCALEBLT_1BE:           /* the conversion loop from the 0x1CB0 table */
    movel %sp,%fp@(-572)
    lea %fp@(-244),%a5
    tstw %d7
    jbeq SCALEBLT_1D4
    pea %pc@(ONEBITPROC)
    jsr @(0x1730,%za0)@(0x0)	| 40839F9E
SCALEBLT_1D4:           /* by source and destination depth */
    movew %d5,%d0
    lsrw #2,%d0
    lea @(0x1cb0,%d0:w:4),%a0
    moveal %a0@,%a0
    andiw #3,%d5
    addal %a0@(0x0,%d5:w:4),%a0
    movel %a0,%fp@(-552)
SCALEBLT_1EC:           /* the three clip regions: not rectangles? intersect them into a scratch region */
    moveq #10,%d0
    moveal %fp@(10),%a0
    moveal %a0@,%a0
    cmpw %a0@,%d0
    beqw SCALEBLT_21E
    movel %fp@(10),%sp@-
    pea %fp@(-116)
    movew #-1,%sp@-
    jsr @(0x1aa4,%za0)@(0)	| 40839FD6
    jblt SCALEBLT_3C2
    jbgt SCALEBLT_21E
    moveal %fp@(-464),%a1
    moveal %a1@,%a1
    movel %a1@(-130),%fp@(10)
SCALEBLT_21E:           /* second region */
    moveal %fp@(14),%a0
    moveal %a0@,%a0
    cmpw %a0@,%d0
    jbeq SCALEBLT_24E
    movel %fp@(14),%sp@-
    pea %fp@(-116)
    movew #-1,%sp@-
    jsr @(0x1aa4,%za0)@(0)	| 4083A004
    jblt SCALEBLT_3C2
    bgtw SCALEBLT_24E
    moveal %fp@(-464),%a1
    moveal %a1@,%a1
    movel %a1@(-130),%fp@(14)
SCALEBLT_24E:           /* third region */
    moveal %fp@(18),%a0
    moveal %a0@,%a0
    cmpw %a0@,%d0
    jbeq SCALEBLT_27C
    movel %fp@(18),%sp@-
    pea %fp@(-116)
    movew #-1,%sp@-
    jsr @(0x1aa4,%za0)@(0)	| 4083A034
    jblt SCALEBLT_3C2
    jbgt SCALEBLT_27C
    moveal %fp@(-464),%a1
    moveal %a1@,%a1
    movel %a1@(-130),%fp@(18)
SCALEBLT_27C:           /* the region run buffer on the stack */
    movew %fp@(-114),%d1
    subw %a5@(8),%d1
    extl %d1
    lsll %d4,%d1
    andiw #-32,%d1
    asrl %d4,%d1
    addw %a5@(8),%d1
    movew %d1,%fp@(-14)
    moveq #0,%d0
    movew %fp@(-110),%d0
    subw %d1,%d0
    movel %d0,%d1
    lsll %d4,%d1
    subql #1,%d1
    lsrl #5,%d1
    movew %d1,%fp@(-16)
    lsrl #5,%d0
    addql #1,%d0
    subl %d0,%fp@(-132)
    jbpl SCALEBLT_2BA
    jsr @(0x1c5c,%za0)@(0)	| 4083A084
SCALEBLT_2BA:           /* run buffer */
    clrl %sp@-
    clrl %sp@-
SCALEBLT_2BE:           /* clear it */
    clrl %sp@-
    dbf %d0,SCALEBLT_2BE
    movel %sp,%fp@(-8)
    moveq #-1,%d0
    movel %d0,%fp@(-12)
    movel %fp@(10),%sp@-
    movel %fp@(14),%sp@-
    movel %fp@(18),%sp@-
    movel #2,%sp@-
    jsr @(0x1a34,%za0)@(0)	| 4083A0B0
    tstl %fp@(-676)
    jbeq SCALEBLT_2F6
    jsr @(0x1c50,%za0)@(0)	| 4083A0BC
    movel %a0,%fp@(-704)
SCALEBLT_2F6:           /* first source long and bit offset (fp-504, fp-560); first destination long (fp-512) */
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 4083A0C8
    moveb %d0,%fp@(-258)
    movew %fp@(-450),%d3
    moveal %fp@(36),%a2
    moveal %fp@(28),%a3
    movel %fp@(-444),%d2
    movew %fp@(-114),%d1
    subw %a3@(2),%d1
    addw %a2@(2),%d1
    subw %fp@(-352),%d1
    extl %d1
    lsll %d3,%d1
    moveq #31,%d5
    andl %d1,%d5
    movel %d5,%fp@(-560)
    movew %fp@(-116),%d0
    subw %a3@,%d0
    addw %a2@,%d0
    subw %fp@(-354),%d0
    mulsw %d2,%d0
    addl %fp@(-360),%d0
    subl %d5,%d1
    asrl #3,%d1
    addl %d1,%d0
    movel %d0,%fp@(-504)
    movew %fp@(-118),%d4
    movel %fp@(-124),%d2
    movew %fp@(-114),%d1
    subw %a5@(8),%d1
    extl %d1
    lsll %d4,%d1
    moveq #31,%d6
    andl %d1,%d6
    negl %d6
    movel %d6,%fp@(-564)
    movew %fp@(-116),%d0
    movew %d0,%fp@(-4)
    subw %a5@(6),%d0
    mulsw %d2,%d0
    addl %a5@,%d0
    asrl #5,%d1
    lsll #2,%d1
    addl %d1,%d0
    movel %d0,%fp@(-512)
    moveal %fp@(-512),%a5
    moveal %fp@(-504),%a4
    movew #4,%fp@(-120)
    movew %fp@(-328),%d4
    movew %fp@(-212),%d5
SCALEBLT_398:           /* next band of rows: rows left (fp-112 - fp-4); none: return */
    movew %fp@(-112),%d2
    subw %fp@(-4),%d2
    jble SCALEBLT_3C2
    movew %d2,%d3
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 4083A174
    movew %d2,%d1
    cmpw %d3,%d1
    jble SCALEBLT_3B2
    movew %d3,%d1
SCALEBLT_3B2:           /* run the conversion loop (a2) with the table (a3) */
    jsr %fp@(0xffffffffffffffe8,%za0)@(0)	| 4083A182
    moveal %fp@(-700),%a3
    moveal %fp@(-552),%a2
    jmp %a2@
SCALEBLT_3C2:           /* cannot: d0 = 1 */
    moveq #1,%d0
SCALEBLT_3C4:           /* restore the stack, return */
    moveal %fp@(-600),%sp
    rts
    movew %fp@(-450),%d7
    moveal %fp@(-572),%a3
    lea %pc@(SCALEBLT_3E0_14),%a0
    movel %a3,%fp@(-700)
    movel %a0,%fp@(-552)
    bras SCALEBLT_3E0_14
SCALEBLT_3E0:           /* indexed to 32-bit: next row */
    movel %fp@(-124),%d2
    addal %d2,%a5
    movel %fp@(-444),%d2
    addal %d2,%a4
    addqw #1,%fp@(-4)
    subqw #1,%d1
    jble SCALEBLT_398
SCALEBLT_3E0_14:        /* start of the row: source, destination, runs */
    movel %fp@(-560),%d6
    moveal %a4,%a0
    moveal %a5,%a2
    moveal %fp@(-12),%a1
SCALEBLT_400:           /* next run of the row: offset and count; negative: end of row */
    movel %a1@+,%d3
    jbmi SCALEBLT_3E0
    addaw %d3,%a2
    lsrw #2,%d3
    lslw %d7,%d3
    addw %d3,%d6
    movew %d6,%d3
    lsrw #5,%d3
    lea %a0@(0x0,%d3:w:4),%a0
    swap %d3
SCALEBLT_416:           /* next source long */
    movel %a0@+,%d5
SCALEBLT_418:           /* each pixel through the table */
    bfextu %d5,%d6,%d4,%d0
    movel %a3@(0x0,%d0:w:4),%a2@+
    addw %d4,%d6
    andiw #31,%d6
    dbeq %d3,SCALEBLT_418
    dbne %d3,SCALEBLT_416
    jbeq SCALEBLT_400
    subqw #4,%a0
    jbra SCALEBLT_400
    movew %fp@(-670),%d6
    moveq #8,%d7
    subw %d6,%d7
    movel %fp@(-564),%d0
    asrl #1,%d0
    addal %d0,%a4
    moveal %fp@(-652),%a3
    lea %pc@(SCALEBLT_456_18),%a0
    movel %a3,%fp@(-700)
    movel %a0,%fp@(-552)
    bras SCALEBLT_456_18
SCALEBLT_456:           /* 32-bit to 8-bit: next row */
    movel %fp@(-124),%d2
    addal %d2,%a5
    movel %fp@(-444),%d2
    addal %d2,%a4
    addqw #1,%fp@(-4)
    swap %d1
    subqw #1,%d1
    jble SCALEBLT_398
SCALEBLT_456_18:        /* start of the row */
    moveal %a4,%a0
    moveal %a5,%a2
    moveal %fp@(-12),%a1
    swap %d1
SCALEBLT_478:           /* next run of the row */
    movew #3,%d1
    movel %a1@+,%d3
    jbmi SCALEBLT_456
    addaw %d3,%a2
    lea %a0@(0x0,%d3:w:4),%a0
    swap %d3
    bclr #14,%d3
    jbeq SCALEBLT_4D2
    movel %a0@+,%d5
    jbra SCALEBLT_49C
SCALEBLT_492:           /* four pixels into one destination long */
    movew #3,%d1
SCALEBLT_496:           /* same source pixel as the last one? reuse the index */
    movel %a0@+,%d5
    cmpl %d5,%d4
    jbeq SCALEBLT_4B8
SCALEBLT_49C:           /* the inverse table index from the high bits of R, G, B */
    moveq #0,%d2
    movew %d5,%d4
    swap %d5
    moveb %d5,%d2
    lsll %d6,%d2
    lsrl #8,%d4
    moveb %d4,%d2
    lsll %d6,%d2
    swap %d5
    moveb %d5,%d2
    lsrl %d7,%d2
    movel %d5,%d4
    moveb %a3@(0x0,%d2:w),%d2
SCALEBLT_4B8:           /* append the index */
    lsll #8,%d0
    moveb %d2,%d0
    dbf %d1,SCALEBLT_496
    movel %a1@+,%d5
    andl %d5,%d0
    notl %d5
    andl %a2@,%d5
    orl %d5,%d0
    movel %d0,%a2@+
    dbf %d3,SCALEBLT_492
    jbra SCALEBLT_478
SCALEBLT_4D2:           /* first long of a run */
    movel %a0@+,%d5
    jbra SCALEBLT_4E0
SCALEBLT_4D6:           /* four pixels into one destination long */
    movew #3,%d1
SCALEBLT_4DA:           /* same source pixel as the last one? reuse the index */
    movel %a0@+,%d5
    cmpl %d5,%d4
    jbeq SCALEBLT_4FC
SCALEBLT_4E0:           /* the inverse table index from the high bits of R, G, B */
    moveq #0,%d2
    movew %d5,%d4
    swap %d5
    moveb %d5,%d2
    lsll %d6,%d2
    lsrl #8,%d4
    moveb %d4,%d2
    lsll %d6,%d2
    swap %d5
    moveb %d5,%d2
    lsrl %d7,%d2
    movel %d5,%d4
    moveb %a3@(0x0,%d2:w),%d2
SCALEBLT_4FC:           /* append the index */
    lsll #8,%d0
    moveb %d2,%d0
    dbf %d1,SCALEBLT_4DA
    movel %d0,%a2@+
    dbf %d3,SCALEBLT_4D6
    jbra SCALEBLT_478
    moveq #0,%d4
    movel %d4,%d6
    movel %d4,%d7
    movel %fp@(-564),%d0
    asrl #1,%d0
    addal %d0,%a4
    moveal %fp@(-656),%a3
    lea %pc@(SCALEBLT_52E_18),%a0
    movel %a3,%fp@(-700)
    movel %a0,%fp@(-552)
    bras SCALEBLT_52E_18
SCALEBLT_52E:           /* 16-bit to 8-bit: next row */
    movel %fp@(-124),%d2
    addal %d2,%a5
    movel %fp@(-444),%d2
    addal %d2,%a4
    addqw #1,%fp@(-4)
    swap %d1
    subqw #1,%d1
    jble SCALEBLT_398
SCALEBLT_52E_18:        /* start of the row */
    moveal %a4,%a0
    moveal %a5,%a2
    moveal %fp@(-12),%a1
    swap %d1
SCALEBLT_550:           /* next run of the row */
    movew #3,%d1
    movel %a1@+,%d3
    jbmi SCALEBLT_52E
    addaw %d3,%a2
    lslw #2,%d3
    addaw %d3,%a0
    swap %d3
    bclr #14,%d3
    jbeq SCALEBLT_5AE
    movel %a0@+,%d5
    jbra SCALEBLT_574
SCALEBLT_56A:           /* four pixels into one destination long */
    movew #3,%d1
SCALEBLT_56E:           /* same source pair as the last one? reuse the indexes */
    movel %a0@+,%d5
    cmpl %d5,%d2
    jbeq SCALEBLT_594
SCALEBLT_574:           /* luminance (5R + 9G + 2B) / 16 through the gray table */
    movel %d5,%d2
    moveb %d5,%d6
    lsrl #8,%d5
    moveb %d5,%d4
    lsrw #8,%d5
    moveb %d5,%d7
    addw %d4,%d5
    addw %d6,%d5
    addw %d6,%d5
    lsrw #2,%d5
    addw %d7,%d5
    addw %d4,%d5
    addw %d4,%d5
    lsrw #2,%d5
    moveb %a3@(0x0,%d5:w),%d7
SCALEBLT_594:           /* append the index */
    lsll #8,%d0
    moveb %d7,%d0
    dbf %d1,SCALEBLT_56E
    movel %a1@+,%d5
    andl %d5,%d0
    notl %d5
    andl %a2@,%d5
    orl %d5,%d0
    movel %d0,%a2@+
    dbf %d3,SCALEBLT_56A
    jbra SCALEBLT_550
SCALEBLT_5AE:           /* first long of a run */
    movel %a0@+,%d5
    jbra SCALEBLT_5BC
SCALEBLT_5B2:           /* four pixels into one destination long */
    movew #3,%d1
SCALEBLT_5B6:           /* same source pair as the last one? reuse the indexes */
    movel %a0@+,%d5
    cmpl %d5,%d2
    jbeq SCALEBLT_5DC
SCALEBLT_5BC:           /* the inverse table indexes from the 5-bit components */
    movel %d5,%d2
    moveb %d5,%d6
    lsrl #8,%d5
    moveb %d5,%d4
    lsrw #8,%d5
    moveb %d5,%d7
    addw %d4,%d5
    addw %d6,%d5
    addw %d6,%d5
    lsrw #2,%d5
    addw %d7,%d5
    addw %d4,%d5
    addw %d4,%d5
    lsrw #2,%d5
    moveb %a3@(0x0,%d5:w),%d7
SCALEBLT_5DC:           /* append the index */
    lsll #8,%d0
    moveb %d7,%d0
    dbf %d1,SCALEBLT_5B6
    movel %d0,%a2@+
    dbf %d3,SCALEBLT_5B2
    jbra SCALEBLT_550
SCALEBLT_5EE:           /* dithered: next band of rows */
    movew %fp@(-112),%d2
    subw %fp@(-4),%d2
    jble SCALEBLT_3C2
    movew %d2,%d3
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 4083A3CC
    movew %d2,%d1
    cmpw %d3,%d1
    jble SCALEBLT_60A
    movew %d3,%d1
SCALEBLT_60A:           /* alternate the direction of the error diffusion each row */
    movel %fp@(-12),%d3
    movew #-4,%fp@(-120)
    movel %fp@(-704),%fp@(-12)
    jsr %fp@(0xffffffffffffffe8,%za0)@(0)	| 4083A3EA
    movel %d3,%fp@(-12)
    movew #4,%fp@(-120)
    jsr %fp@(0xffffffffffffffe8,%za0)@(0)	| 4083A3FA
    moveal %fp@(-700),%a3
    moveal %fp@(-552),%a2
    jmp %a2@
    .short  0x594F, 0x202E, 0xFDCC	| 4083A40A
    .long   0xE280D9C0, 0x2D4CFE08	| 4083A410
    moveal %fp@(-652),%a3
    moveal %fp@(-668),%a5
    moveq #0,%d4
    lea %pc@(SCALEBLT_67C),%a0
    movel %a3,%fp@(-700)
    movel %a0,%fp@(-552)
    jbra SCALEBLT_5EE
SCALEBLT_660:           /* dithered: next row */
    movel %fp@(-124),%d2
    addl %d2,%fp@(-512)
    movel %fp@(-444),%d2
    addl %d2,%fp@(-504)
    addqw #1,%fp@(-4)
    subqw #1,%sp@
    movew %sp@,%d1
    jble SCALEBLT_5EE
SCALEBLT_67C:           /* start of a row */
    moveal %fp@(-504),%a0
    moveal %fp@(-512),%a2
    moveal %fp@(-12),%a1
    movew %d1,%sp@
    moveal %fp@(-676),%a4
    moveq #0,%d5
    movel %d5,%d6
    movel %d5,%d7
    movew %fp@(-670),%d7
    swap %d7
    notb %fp@(-681)
    jbne SCALEBLT_6A4
    moveal %fp@(-704),%a1
SCALEBLT_6A4:           /* next run of the row */
    movel %a1@+,%d3
    jbmi SCALEBLT_660
    addaw %d3,%a2
    addw %d3,%d3
    addaw %d3,%a4
    addw %d3,%d3
    addaw %d3,%a0
    addaw %d3,%a4
    swap %d3
    lsll #2,%d3
    lsrw #2,%d3
    tstb %fp@(-681)
    jbne SCALEBLT_6E4
SCALEBLT_6C0:           /* right to left: four pixels per long */
    jbsr SCALEBLT_6FE
    subaw #48,%a4
    subaw #32,%a0
    btst #16,%d3
    jbeq SCALEBLT_6DA
    movel %a1@+,%d0
    andl %d0,%d2
    notl %d0
    andl %a2@,%d0
    orl %d0,%d2
SCALEBLT_6DA:           /* store */
    movel %d2,%a2@
    subqw #4,%a2
    dbf %d3,SCALEBLT_6C0
    jbra SCALEBLT_6A4
SCALEBLT_6E4:           /* left to right: four pixels per long */
    jbsr SCALEBLT_6FE
    btst #16,%d3
    jbeq SCALEBLT_6F6
    movel %a1@+,%d0
    andl %d0,%d2
    notl %d0
    andl %a2@,%d0
    orl %d0,%d2
SCALEBLT_6F6:           /* store */
    movel %d2,%a2@+
    dbf %d3,SCALEBLT_6E4
    jbra SCALEBLT_6A4

SCALEBLT_6FE:           /* four 32-bit pixels: add the carried error to each component (clamped 0..255), look up the index, keep the new error */
    moveq #3,%d1
SCALEBLT_700:           /* one pixel: error added, clamped, the index; the new error */
    swap %d1
    movel %a0@+,%d0
    moveb %d0,%d4
    addw %a4@(4),%d7
    addw %d4,%d7
    spl %d4
    cmpw %d4,%d7
    sgt %d1
    andw %d4,%d7
    orw %d1,%d7
    lsrw #8,%d0
    addw %a4@(2),%d6
    addw %d0,%d6
    spl %d4
    cmpw %d4,%d6
    sgt %d1
    andw %d4,%d6
    orw %d1,%d6
    swap %d0
    moveb %d0,%d4
    addw %a4@,%d5
    addw %d4,%d5
    spl %d4
    cmpw %d4,%d5
    sgt %d1
    andw %d4,%d5
    orw %d1,%d5
    movel %d7,%d0
    swap %d0
    moveb %d5,%d4
    lsll %d0,%d4
    moveb %d6,%d4
    lsll %d0,%d4
    moveb %d7,%d4
    negw %d0
    addqw #8,%d0
    lsrl %d0,%d4
    moveb %a3@(0x0,%d4:l),%d1
    lsll #8,%d2
    moveb %d1,%d2
    movel %a5@(0xa,%d1:w:8),%d0
    moveq #0,%d4
    lsrl #8,%d0
    moveb %d0,%d4
    subw %d4,%d6
    swap %d0
    subw %d0,%d5
    moveb %a5@(0xe,%d1:w:8),%d4
    subw %d4,%d7
    asrw #1,%d5
    movew %d5,%a4@+
    asrw #1,%d6
    movew %d6,%a4@+
    asrw #1,%d7
    movew %d7,%a4@+
    swap %d1
    dbf %d1,SCALEBLT_700
    rts
    braw SCALEBLT_3C2

/* SCDIRTAB1: table. */
trap_SCDIRTAB1:
SCDIRTAB1:
    .long   0xFFFFFFFC, 0xFFFFFFFC, 0xFFFFFFFC	| 4083A554
    .long   0xFFFFFFFC, 0xFFFFFFFC, 0xFFFFFFFC, 0xFFFFFFFC	| 4083A560
    .long   0xFFFFFFFC	| 4083A570

/* SCDIRTAB2: table. */
trap_SCDIRTAB2:
SCDIRTAB2:
    .long   0xFFFFFFDC, 0xFFFFFFDC, 0xFFFFFFDC	| 4083A574
    .long   0xFFFFFFDC, 0xFFFFFFDC, 0xFFFFFFDC, 0xFFFFFFDC	| 4083A580
    .long   0xFFFFFFDC	| 4083A590

/* SCDIRTAB4: table. */
trap_SCDIRTAB4:
SCDIRTAB4:
    .long   0xFFFFFFBC, 0xFFFFFFBC, 0xFFFFFFBC	| 4083A594
    .long   0xFFFFFFBC, 0xFFFFFFBC, 0xFFFFFFBC, 0xFFFFFFBC	| 4083A5A0
    .long   0xFFFFFFBC	| 4083A5B0

/* SCDIRTAB8: table. */
trap_SCDIRTAB8:
SCDIRTAB8:
    .long   0xFFFFFF9C, 0xFFFFFF9C, 0xFFFFFF9C	| 4083A5B4
    .long   0xFFFFFF9C, 0xFFFFFC50, 0xFFFFFE56, 0xFFFFFD2A	| 4083A5C0
    .long   0xFFFFFD2A	| 4083A5D0

/* SCDIRTAB16: table. */
trap_SCDIRTAB16:
SCDIRTAB16:
    .long   0xFFFFFF7C, 0xFFFFFF7C, 0xFFFFFF7C	| 4083A5D4
    .long   0xFFFFFF7C, 0xFFFFFF7C, 0xFFFFFF7C, 0xFFFFFF7C	| 4083A5E0
    .long   0xFFFFFF7C	| 4083A5F0

/* SCDIRTAB32: table. */
trap_SCDIRTAB32:
SCDIRTAB32:
    .long   0xFFFFFF5C, 0xFFFFFF5C, 0xFFFFFF5C	| 4083A5F4
    .long   0xFFFFFF5C, 0xFFFFFF5C, 0xFFFFFF5C, 0xFFFFFF5C	| 4083A600
    .long   0xFFFFFF5C	| 4083A610

/* SCINDTAB1: table. */
trap_SCINDTAB1:
SCINDTAB1:
    .long   0xFFFFFF3C, 0xFFFFFF3C, 0xFFFFFF3C	| 4083A614
    .long   0xFFFFFF3C	| 4083A620

/* SCINDTAB2: table. */
trap_SCINDTAB2:
SCINDTAB2:
    .long   0xFFFFFF2C, 0xFFFFFF2C, 0xFFFFFF2C	| 4083A624
    .long   0xFFFFFF2C	| 4083A630

/* SCINDTAB4: table. */
trap_SCINDTAB4:
SCINDTAB4:
    .long   0xFFFFFF1C, 0xFFFFFF1C, 0xFFFFFF1C	| 4083A634
    .long   0xFFFFFF1C	| 4083A640

/* SCINDTAB8: table. */
trap_SCINDTAB8:
SCINDTAB8:
    .long   0xFFFFFF0C, 0xFFFFFF0C, 0xFFFFFF0C	| 4083A644
    .long   0xFFFFFF0C	| 4083A650

/* SCINDTAB16: table. */
trap_SCINDTAB16:
SCINDTAB16:
    .long   0xFFFFFEFC, 0xFFFFFEFC, 0xFFFFFEFC	| 4083A654
    .long   0xFFFFFEFC	| 4083A660

/* SCINDTAB32: table. */
trap_SCINDTAB32:
SCINDTAB32:
    .long   0xFFFFFB36, 0xFFFFFB36, 0xFFFFFB36	| 4083A664
    .long   0xFFFFFB36, 0x00000000, 0x00000000, 0x00000000	| 4083A670

/*
 ANDY: CB1TO8CLIP: StretchBits fast path for an unstretched 1-bit to 8-bit copy: each
 source nibble becomes four destination bytes through TABLE8, with the fg/bk colors,
 clipped by the region mask (fp-8).
*/
ANDY:
CB1TO8CLIP:
    movew %fp@(-4),%d0
    cmpw %fp@(-116),%d0
    jblt ANDY_1A
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 4083A68A
    jbra ANDY_34
    .short  0x202E, 0xFF84, 0xD1AE, 0xFE00	| 4083A692
ANDY_1A:                /* skip a row: last row: done */
    addqw #1,%fp@(-4)
    movew %fp@(-4),%d0
    cmpw %fp@(-112),%d0
    jbeq DONESTRETCH
    movel %fp@(-444),%d2
    addl %d2,%fp@(-504)
    jbra ANDY
ANDY_34:                /* set up: width in longs, destination (a4), region mask (a2) */
    subqw #1,%fp@(-16)
    moveq #0,%d7
    moveal %fp@(-512),%a4
    moveal %fp@(-8),%a2
ANDY_42:                /* next row: the source bit offset */
    movel %fp@(-564),%d0
    asrl #3,%d0
    moveq #15,%d3
    moveq #-1,%d6
    lea %pc@(TABLE8),%a1
    moveal %fp@(-504),%a3
    movel %fp@(-560),%d5
    addl %d0,%d5
    bfextu %a3@,%d5,16,%d4
    addql #4,%d5
    rolw #4,%d4
    movel %a2@+,%d1
    movew %d4,%d0
    andw %d3,%d0
    movel %a1@(0x0,%d0:w:4),%d0
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    movew %fp@(-16),%d2
    cmpiw #4,%d2
    blew ANDY_100
    movew %d2,%d0
    andiw #3,%d0
    jbne ANDY_8C
    subqw #1,%d2
ANDY_8C:                /* the row in longs; first time through: all-background check */
    lsrw #2,%d2
    subqw #1,%d2
    tstb %d7
    jbne ANDY_206
    st %d7
ANDY_98:                /* each source word (16 pixels): all zero? fast fill */
    bfextu %a3@,%d5,16,%d4
    addqw #2,%a3
    jbeq ANDY_146
    rolw #4,%d4
    lea %pc@(ANDY_BA),%a5
    movel %a2@+,%d1
    movew %d4,%d0
    andw %d3,%d0
    movel %a1@(0x0,%d0:w:4),%d0
    cmpl %d6,%d1
    bnew ANDY_134
    movel %d0,%a4@+
ANDY_BA:                /* second nibble */
    lea %pc@(ANDY_D0),%a5
    rolw #4,%d4
    movel %a2@+,%d1
    movew %d4,%d0
    andw %d3,%d0
    movel %a1@(0x0,%d0:w:4),%d0
    cmpl %d6,%d1
    jbne ANDY_134
    movel %d0,%a4@+
ANDY_D0:                /* third nibble */
    lea %pc@(ANDY_E6),%a5
    rolw #4,%d4
    movel %a2@+,%d1
    movew %d4,%d0
    andw %d3,%d0
    movel %a1@(0x0,%d0:w:4),%d0
    cmpl %d6,%d1
    jbne ANDY_134
    movel %d0,%a4@+
ANDY_E6:                /* fourth nibble */
    lea %pc@(ANDY_FC),%a5
    rolw #4,%d4
    movel %a2@+,%d1
    movew %d4,%d0
    andw %d3,%d0
    movel %a1@(0x0,%d0:w:4),%d0
    cmpl %d6,%d1
    jbne ANDY_134
    movel %d0,%a4@+
ANDY_FC:                /* count down (loop) */
    dbf %d2,ANDY_98
ANDY_100:               /* the last partial word */
    bfextu %a3@,%d5,16,%d4
    lea %pc@(ANDY_12A),%a5
    movew %fp@(-16),%d2
    jbeq ANDY_1AC
    andiw #3,%d2
    jbne ANDY_12A
    moveq #3,%d2
ANDY_118:               /* each nibble: four destination bytes through the table */
    rolw #4,%d4
    movel %a2@+,%d1
    movew %d4,%d0
    andw %d3,%d0
    movel %a1@(0x0,%d0:w:4),%d0
    cmpl %d6,%d1
    jbne ANDY_136
    movel %d0,%a4@+
ANDY_12A:               /* next */
    dbf %d2,ANDY_118
    jbra ANDY_1AC
ANDY_130:               /* skipped long */
    addql #4,%a4
    jmp %a5@
ANDY_134:               /* masked */
    moveq #0,%d7
ANDY_136:               /* masked by the region: through the mask */
    tstl %d1
    jbeq ANDY_130
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    jmp %a5@
ANDY_146:               /* zero source word: four longs of background, masked */
    movel %a2@+,%d1
    jbeq ANDY_170
    cmpl %d6,%d1
    jbne ANDY_18A
    clrl %a4@+
ANDY_150:               /* second */
    movel %a2@+,%d1
    jbeq ANDY_176
    cmpl %d6,%d1
    jbne ANDY_192
    clrl %a4@+
ANDY_15A:               /* third */
    movel %a2@+,%d1
    jbeq ANDY_17C
    cmpl %d6,%d1
    jbne ANDY_19A
    clrl %a4@+
ANDY_164:               /* fourth */
    movel %a2@+,%d1
    jbeq ANDY_182
    cmpl %d6,%d1
    jbne ANDY_1A2
    clrl %a4@+
    jbra ANDY_FC
ANDY_170:               /* outside: skip */
    moveq #0,%d7
    addqw #4,%a4
    jbra ANDY_150
ANDY_176:               /* skip */
    moveq #0,%d7
    addqw #4,%a4
    jbra ANDY_15A
ANDY_17C:               /* skip */
    moveq #0,%d7
    addqw #4,%a4
    jbra ANDY_164
ANDY_182:               /* skip */
    moveq #0,%d7
    addqw #4,%a4
    jbra ANDY_FC
ANDY_18A:               /* partly masked: clear through the mask */
    moveq #0,%d7
    notl %d1
    andl %d1,%a4@+
    jbra ANDY_150
ANDY_192:               /* masked */
    moveq #0,%d7
    notl %d1
    andl %d1,%a4@+
    jbra ANDY_15A
ANDY_19A:               /* masked */
    moveq #0,%d7
    notl %d1
    andl %d1,%a4@+
    jbra ANDY_164
ANDY_1A2:               /* masked */
    moveq #0,%d7
    notl %d1
    andl %d1,%a4@+
    jbra ANDY_FC
ANDY_1AC:               /* next row: advance; last: done; the region mask for the row */
    movel %fp@(-124),%d0
    addl %d0,%fp@(-512)
    movel %fp@(-444),%d0
    addl %d0,%fp@(-504)
    movew %fp@(-4),%d0
    addqw #1,%d0
    movew %d0,%fp@(-4)
    cmpw %fp@(-112),%d0
    jbeq DONESTRETCH
    cmpw %fp@(-68),%d0
    jbge ANDY_1F2
    cmpw %fp@(-70),%d0
    jblt ANDY_1F2
    cmpw %fp@(-92),%d0
    jbge ANDY_1F2
    cmpw %fp@(-94),%d0
    jblt ANDY_1F2
    cmpw %fp@(-44),%d0
    jbge ANDY_1F2
    cmpw %fp@(-46),%d0
    jbge ANDY_1FA
ANDY_1F2:               /* seek the region */
    moveq #0,%d7
    moveal %fp@(-28),%a0
    jsr %a0@
ANDY_1FA:               /* restart the row */
    moveal %fp@(-8),%a2
    moveal %fp@(-512),%a4
    jbra ANDY_42
ANDY_206:               /* fast path (no mask): each word */
    movew %d2,%d7
ANDY_208:               /* all zero? all ones? else through the table */
    bfextu %a3@,%d5,16,%d4
    addqw #2,%a3
    jbeq ANDY_244
    cmpw %d4,%d6
    jbeq ANDY_24E
    swap %d4
    roll #4,%d4
    andw %d3,%d4
    movel %a1@(0x0,%d4:w:4),%a4@+
    roll #4,%d4
    andw %d3,%d4
    movel %a1@(0x0,%d4:w:4),%a4@+
    roll #4,%d4
    andw %d3,%d4
    movel %a1@(0x0,%d4:w:4),%a4@+
    roll #4,%d4
    andw %d3,%d4
    movel %a1@(0x0,%d4:w:4),%a4@+
ANDY_236:               /* count down (loop) */
    dbf %d2,ANDY_208
    addqw #1,%d7
    lslw #4,%d7
    addaw %d7,%a2
    jbra ANDY_100
ANDY_244:               /* four longs of background */
    clrl %a4@+
    clrl %a4@+
    clrl %a4@+
    clrl %a4@+
    jbra ANDY_236
ANDY_24E:               /* four longs of foreground */
    movel %d6,%a4@+
    movel %d6,%a4@+
    movel %d6,%a4@+
    movel %d6,%a4@+
    jbra ANDY_236
ANDY_258:               /* (end of a row; CB8TO8CLIP's loops follow) */
    addqw #4,%a3
    addqw #4,%a4
    jbra CB8TO8CLIP_B2
/*
 CB8TO8CLIP: StretchBits fast path for an unstretched 8-bit to 8-bit copy through a color
 translation table (fp-572), clipped by the region mask (fp-8); rows above the
 destination's visible part are skipped first.
*/
CB8TO8CLIP:
    movew %fp@(-4),%d0
    cmpw %fp@(-116),%d0
    jblt CB8TO8CLIP_1A
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 4083A8EA
    jbra CB8TO8CLIP_34
    .short  0x202E, 0xFF84, 0xD1AE, 0xFE00	| 4083A8F2
CB8TO8CLIP_1A:          /* skip a row: last row: done */
    addqw #1,%fp@(-4)
    movew %fp@(-4),%d0
    cmpw %fp@(-112),%d0
    jbeq DONESTRETCH
    movel %fp@(-444),%d2
    addl %d2,%fp@(-504)
    jbra CB8TO8CLIP
CB8TO8CLIP_34:          /* set up: width in longs, the table, the first table entry replicated */
    subqw #1,%fp@(-16)
    moveq #-1,%d6
    moveq #0,%d4
    moveq #0,%d3
    moveal %fp@(-572),%a5
    subal %a1,%a1
    movel %a5@,%d0
    moveb %d0,%d7
    lsll #8,%d7
    moveb %d0,%d7
    movew %d7,%d0
    swap %d7
    movew %d0,%d7
CB8TO8CLIP_52:          /* set up: region mask, source, destination, the translation table */
    moveal %fp@(-8),%a2
    moveal %fp@(-504),%a3
    moveal %fp@(-512),%a4
    moveal %fp@(-572),%a5
    movel %fp@(-564),%d0
    asrl #3,%d0
    movel %fp@(-560),%d1
    asrl #3,%d1
    addl %d1,%d0
    addal %d0,%a3
    movew %fp@(-16),%d2
    moveq #0,%d5
    movel %a2@+,%d1
    jbeq ANDY_258
    movel %a3@+,%d0
    moveal %d0,%a1
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    movel %d0,%d7
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    subqw #1,%d2
    jbmi CB8TO8CLIP_108
CB8TO8CLIP_B2:          /* the mask's run state: a full-mask run? */
    tstw %d4
    jbne CB8TO8CLIP_2A2
    moveq #-1,%d4
    moveq #0,%d3
    movel %a2@+,%d1
    jbeq CB8TO8CLIP_168
    cmpl %d6,%d1
    jbne CB8TO8CLIP_174
    jbra CB8TO8CLIP_D2
CB8TO8CLIP_CA:          /* next mask long: still full? */
    movel %a2@+,%d1
    cmpl %d6,%d1
    jbne CB8TO8CLIP_174
CB8TO8CLIP_D2:          /* translate four pixels (same as the last long? reuse) */
    addqw #1,%d3
    movel %a3@+,%d0
    cmpal %d0,%a1
    jbne CB8TO8CLIP_DE
    movel %d7,%d0
    jbra CB8TO8CLIP_102
CB8TO8CLIP_DE:          /* through the table */
    moveal %d0,%a1
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    movel %d0,%d7
CB8TO8CLIP_102:         /* store */
    movel %d0,%a4@+
    dbf %d2,CB8TO8CLIP_CA
CB8TO8CLIP_108:         /* next row: advance; last: done */
    movel %fp@(-124),%d0
    addl %d0,%fp@(-512)
    movel %fp@(-444),%d0
    addl %d0,%fp@(-504)
    movew %fp@(-4),%d0
    addqw #1,%d0
    movew %d0,%fp@(-4)
    cmpw %fp@(-112),%d0
    jbeq DONESTRETCH
    cmpw %fp@(-68),%d0
    jbge CB8TO8CLIP_150
    cmpw %fp@(-70),%d0
    jblt CB8TO8CLIP_150
    cmpw %fp@(-92),%d0
    jbge CB8TO8CLIP_150
    cmpw %fp@(-94),%d0
    jblt CB8TO8CLIP_150
    cmpw %fp@(-44),%d0
    jbge CB8TO8CLIP_150
    cmpw %fp@(-46),%d0
    jbge CB8TO8CLIP_52
CB8TO8CLIP_150:         /* seek the region for the next row */
    moveq #0,%d4
    movel %a1,%sp@-
    moveal %fp@(-28),%a0
    jsr %a0@
    moveal %sp@+,%a1
    jbra CB8TO8CLIP_52
    addqw #4,%a4
    bras CB8TO8CLIP_108
CB8TO8CLIP_164:         /* empty mask run */
    movel %a2@+,%d1
    jbne CB8TO8CLIP_174
CB8TO8CLIP_168:         /* skip */
    subqw #1,%d3
    addqw #4,%a3
    addqw #4,%a4
    dbf %d2,CB8TO8CLIP_164
    jbra CB8TO8CLIP_108
CB8TO8CLIP_174:         /* partly masked: translate and merge */
    swap %d3
    movel %a3@+,%d0
    cmpal %d0,%a1
    jbne CB8TO8CLIP_180
    movel %d7,%d0
    jbra CB8TO8CLIP_1A4
CB8TO8CLIP_180:         /* through the table */
    moveal %d0,%a1
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    movel %d0,%d7
CB8TO8CLIP_1A4:         /* through the mask */
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    subqw #1,%d2
    jbmi CB8TO8CLIP_1F8
    movel %a2@+,%d1
    jbeq CB8TO8CLIP_202
    cmpl %d6,%d1
    jbne CB8TO8CLIP_20E
    jbra CB8TO8CLIP_1C2
CB8TO8CLIP_1BC:         /* full run */
    movel %a2@+,%d1
    cmpl %d6,%d1
    jbne CB8TO8CLIP_20E
CB8TO8CLIP_1C2:         /* translate */
    addqw #1,%d3
    movel %a3@+,%d0
    cmpal %d0,%a1
    jbne CB8TO8CLIP_1CE
    movel %d7,%d0
    jbra CB8TO8CLIP_1F2
CB8TO8CLIP_1CE:         /* through the table */
    moveal %d0,%a1
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    movel %d0,%d7
CB8TO8CLIP_1F2:         /* store */
    movel %d0,%a4@+
    dbf %d2,CB8TO8CLIP_1BC
CB8TO8CLIP_1F8:         /* end of row */
    swap %d3
    jbra CB8TO8CLIP_108
CB8TO8CLIP_1FE:         /* empty run */
    movel %a2@+,%d1
    jbne CB8TO8CLIP_20E
CB8TO8CLIP_202:         /* skip */
    subqw #1,%d3
    addqw #4,%a3
    addqw #4,%a4
    dbf %d2,CB8TO8CLIP_1FE
    jbra CB8TO8CLIP_1F8
CB8TO8CLIP_20E:         /* mixed */
    swap %d3
    tstl %d1
    jbeq CB8TO8CLIP_256
    jbra CB8TO8CLIP_21A
CB8TO8CLIP_216:         /* next mask long */
    movel %a2@+,%d1
    jbeq CB8TO8CLIP_256
CB8TO8CLIP_21A:         /* full: translate */
    cmpl %d6,%d1
    jbne CB8TO8CLIP_262
    movel %a3@+,%d0
    cmpal %d0,%a1
    jbne CB8TO8CLIP_228
    movel %d7,%d0
    jbra CB8TO8CLIP_24C
CB8TO8CLIP_228:         /* through the table */
    moveal %d0,%a1
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    movel %d0,%d7
CB8TO8CLIP_24C:         /* store */
    movel %d0,%a4@+
    dbf %d2,CB8TO8CLIP_216
    jbra CB8TO8CLIP_108
CB8TO8CLIP_256:         /* empty: skip */
    addqw #4,%a4
    addqw #4,%a3
    dbf %d2,CB8TO8CLIP_216
    jbra CB8TO8CLIP_108
CB8TO8CLIP_262:         /* partial: translate */
    movel %a3@+,%d0
    cmpal %d0,%a1
    jbne CB8TO8CLIP_26C
    movel %d7,%d0
    jbra CB8TO8CLIP_290
CB8TO8CLIP_26C:         /* through the table */
    moveal %d0,%a1
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    movel %d0,%d7
CB8TO8CLIP_290:         /* through the mask */
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    dbf %d2,CB8TO8CLIP_216
    jbra CB8TO8CLIP_108
CB8TO8CLIP_2A2:         /* repeated rows: use the run lengths found on the first row */
    tstw %d3
    jbpl CB8TO8CLIP_2E2
    jbeq CB8TO8CLIP_33A
    movew %d3,%d0
    negw %d0
    lslw #2,%d0
    addaw %d0,%a2
    addaw %d0,%a3
    addaw %d0,%a4
    addw %d3,%d2
    jbmi CB8TO8CLIP_108
CB8TO8CLIP_2BC:         /* next run */
    lea %pc@(CB8TO8CLIP_2C4),%a0
    jbra CB8TO8CLIP_344
CB8TO8CLIP_2C4:         /* the same with the run count in the high word of d3: skip that many longs */
    movel %d3,%d0	| 4083ABA4
    jbpl CB8TO8CLIP_2F2	| 4083ABA6
    jbeq CB8TO8CLIP_340	| 4083ABA8
    swap %d0	| 4083ABAA
    negw %d0	| 4083ABAC
    subw %d0,%d2	| 4083ABAE
    lslw #2,%d0	| 4083ABB0
    addaw %d0,%a2	| 4083ABB2
    addaw %d0,%a3	| 4083ABB4
    addaw %d0,%a4	| 4083ABB6
    tstw %d2	| 4083ABB8
    jbmi CB8TO8CLIP_108	| 4083ABBA
    jbra CB8TO8CLIP_216	| 4083ABBE
CB8TO8CLIP_2E2:         /* a full run */
    movew %d3,%d0
    movew %d0,%d1
    lslw #2,%d1
    addaw %d1,%a2
    subw %d0,%d2
    lea %pc@(CB8TO8CLIP_2BC),%a0
    jbra CB8TO8CLIP_32E
CB8TO8CLIP_2F2:         /* its length */
    swap %d0	| 4083ABD2
    movew %d0,%d1	| 4083ABD4
    lslw #2,%d1	| 4083ABD6
    addaw %d1,%a2	| 4083ABD8
    subw %d0,%d2	| 4083ABDA
    lea %pc@(CB8TO8CLIP_216),%a0	| 4083ABDC
    jbra CB8TO8CLIP_32E	| 4083ABE0
CB8TO8CLIP_302:         /* translate */
    movel %a3@+,%d1
    cmpal %d1,%a1
    jbeq CB8TO8CLIP_32C
    moveal %d1,%a1
    moveb %d1,%d5
    moveb %a5@(0x3,%d5:w:4),%d1
    roll #8,%d1
    moveb %d1,%d5
    moveb %a5@(0x3,%d5:w:4),%d1
    roll #8,%d1
    moveb %d1,%d5
    moveb %a5@(0x3,%d5:w:4),%d1
    roll #8,%d1
    moveb %d1,%d5
    moveb %a5@(0x3,%d5:w:4),%d1
    roll #8,%d1
    movel %d1,%d7
CB8TO8CLIP_32C:         /* store */
    movel %d7,%a4@+
CB8TO8CLIP_32E:         /* next */
    dbf %d0,CB8TO8CLIP_302
    tstw %d2
    jbmi CB8TO8CLIP_108
    jmp %a0@
CB8TO8CLIP_33A:         /* masked run */
    lea %pc@(CB8TO8CLIP_2BC),%a0
    jbra CB8TO8CLIP_344
CB8TO8CLIP_340:         /* masked run */
    lea %pc@(CB8TO8CLIP_216),%a0	| 4083AC20
CB8TO8CLIP_344:         /* translate and merge */
    movel %a2@+,%d1
    movel %a3@+,%d0
    cmpal %d0,%a1
    jbne CB8TO8CLIP_350
    movel %d7,%d0
    jbra CB8TO8CLIP_374
CB8TO8CLIP_350:         /* through the table */
    moveal %d0,%a1
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    moveb %d0,%d5
    moveb %a5@(0x3,%d5:w:4),%d0
    roll #8,%d0
    movel %d0,%d7
CB8TO8CLIP_374:         /* through the mask */
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    subqw #1,%d2
    jbmi CB8TO8CLIP_108
    jmp %a0@
CB8TO8CLIP_386:         /* (end; CB8TO1CLIP's loops follow) */
    lea %a3@(32),%a3
    addqw #4,%a4
    jbra CB8TO1CLIP_7E
/*
 CB8TO1CLIP: StretchBits fast path for an unstretched 8-bit to 1-bit copy through the
 translation table, clipped by the region mask (fp-8).
*/
CB8TO1CLIP:
    movew %fp@(-4),%d0
    cmpw %fp@(-116),%d0
    jblt CB8TO1CLIP_1A
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 4083AC78
    jbra CB8TO1CLIP_34
    .long   0x202EFF84, 0xD1AEFE00	| 4083AC80
CB8TO1CLIP_1A:          /* skip a row: last row: done */
    addqw #1,%fp@(-4)
    movew %fp@(-4),%d0
    cmpw %fp@(-112),%d0
    jbeq DONESTRETCH
    movel %fp@(-444),%d2
    addl %d2,%fp@(-504)
    jbra CB8TO1CLIP
CB8TO1CLIP_34:          /* set up: width in longs */
    subqw #1,%fp@(-16)
    moveq #-1,%d6
    moveq #0,%d4
    moveq #0,%d3
    subal %a1,%a1
    subql #1,%a1
    moveq #-1,%d7
CB8TO1CLIP_44:          /* next row: region mask, source, destination */
    moveal %fp@(-8),%a2
    moveal %fp@(-504),%a3
    moveal %fp@(-512),%a4
    moveal %fp@(-572),%a5
    movel %fp@(-564),%d0
    movel %fp@(-560),%d1
    asrl #3,%d1
    addl %d1,%d0
    addal %d0,%a3
    movew %fp@(-16),%d2
    moveq #0,%d5
    movel %a2@+,%d1
    jbeq CB8TO8CLIP_386
    jbsr CB8TO1CLIP_230
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    subqw #1,%d2
    jbmi CB8TO1CLIP_A6
CB8TO1CLIP_7E:          /* the mask's run state: a full-mask run? */
    tstw %d4
    jbne CB8TO1CLIP_19E
    moveq #-1,%d4
    moveq #0,%d3
    movel %a2@+,%d1
    jbeq CB8TO1CLIP_106
    cmpl %d6,%d1
    jbne CB8TO1CLIP_114
    jbra CB8TO1CLIP_9A
CB8TO1CLIP_94:          /* next mask long: still full? */
    movel %a2@+,%d1
    cmpl %d6,%d1
    jbne CB8TO1CLIP_114
CB8TO1CLIP_9A:          /* 32 pixels to one long (CB8TO1CLIP_230) */
    addqw #1,%d3
    jbsr CB8TO1CLIP_230
    movel %d0,%a4@+
    dbf %d2,CB8TO1CLIP_94
CB8TO1CLIP_A6:          /* next row; last: done */
    movel %fp@(-124),%d0
    addl %d0,%fp@(-512)
    movel %fp@(-444),%d0
    addl %d0,%fp@(-504)
    movew %fp@(-4),%d0
    addqw #1,%d0
    movew %d0,%fp@(-4)
    cmpw %fp@(-112),%d0
    jbeq DONESTRETCH
    cmpw %fp@(-68),%d0
    jbge CB8TO1CLIP_EE
    cmpw %fp@(-70),%d0
    jblt CB8TO1CLIP_EE
    cmpw %fp@(-92),%d0
    jbge CB8TO1CLIP_EE
    cmpw %fp@(-94),%d0
    jblt CB8TO1CLIP_EE
    cmpw %fp@(-44),%d0
    jbge CB8TO1CLIP_EE
    cmpw %fp@(-46),%d0
    jbge CB8TO1CLIP_44
CB8TO1CLIP_EE:          /* seek the region */
    moveq #0,%d4
    movel %a1,%sp@-
    moveal %fp@(-28),%a0
    jsr %a0@
    moveal %sp@+,%a1
    jbra CB8TO1CLIP_44
    addqw #4,%a4
    bras CB8TO1CLIP_A6
CB8TO1CLIP_102:         /* empty run */
    movel %a2@+,%d1
    jbne CB8TO1CLIP_114
CB8TO1CLIP_106:         /* skip */
    subqw #1,%d3
    lea %a3@(32),%a3
    addqw #4,%a4
    dbf %d2,CB8TO1CLIP_102
    jbra CB8TO1CLIP_A6
CB8TO1CLIP_114:         /* partial: through the mask */
    swap %d3
    jbsr CB8TO1CLIP_230
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    subqw #1,%d2
    jbmi CB8TO1CLIP_144
    movel %a2@+,%d1
    jbeq CB8TO1CLIP_14E
    cmpl %d6,%d1
    jbne CB8TO1CLIP_15C
    jbra CB8TO1CLIP_138
CB8TO1CLIP_132:         /* full run */
    movel %a2@+,%d1
    cmpl %d6,%d1
    jbne CB8TO1CLIP_15C
CB8TO1CLIP_138:         /* store */
    addqw #1,%d3
    jbsr CB8TO1CLIP_230
    movel %d0,%a4@+
    dbf %d2,CB8TO1CLIP_132
CB8TO1CLIP_144:         /* end of row */
    swap %d3
    jbra CB8TO1CLIP_A6
CB8TO1CLIP_14A:         /* empty run */
    movel %a2@+,%d1
    jbne CB8TO1CLIP_15C
CB8TO1CLIP_14E:         /* skip */
    subqw #1,%d3
    lea %a3@(32),%a3
    addqw #4,%a4
    dbf %d2,CB8TO1CLIP_14A
    jbra CB8TO1CLIP_144
CB8TO1CLIP_15C:         /* mixed */
    swap %d3
    tstl %d1
    jbeq CB8TO1CLIP_17A
    jbra CB8TO1CLIP_168
CB8TO1CLIP_164:         /* next mask long */
    movel %a2@+,%d1
    jbeq CB8TO1CLIP_17A
CB8TO1CLIP_168:         /* full: store */
    cmpl %d6,%d1
    jbne CB8TO1CLIP_188
    jbsr CB8TO1CLIP_230
    movel %d0,%a4@+
    dbf %d2,CB8TO1CLIP_164
    jbra CB8TO1CLIP_A6
CB8TO1CLIP_17A:         /* empty: skip */
    addqw #4,%a4
    lea %a3@(32),%a3
    dbf %d2,CB8TO1CLIP_164
    jbra CB8TO1CLIP_A6
CB8TO1CLIP_188:         /* partial: through the mask */
    jbsr CB8TO1CLIP_230
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    dbf %d2,CB8TO1CLIP_164
    jbra CB8TO1CLIP_A6
CB8TO1CLIP_19E:         /* repeated rows: use the first row's run lengths */
    tstw %d3
    jbpl CB8TO1CLIP_1DC
    jbeq CB8TO1CLIP_210
    movew %d3,%d0
    negw %d0
    lslw #2,%d0
    addaw %d0,%a2
    addaw %d0,%a4
    lslw #3,%d0
    addaw %d0,%a3
    addw %d3,%d2
    jbmi CB8TO1CLIP_A6
CB8TO1CLIP_1B8:         /* next run */
    lea %pc@(CB8TO1CLIP_1BE),%a0
    jbra CB8TO1CLIP_21A
CB8TO1CLIP_1BE:         /* the same with the run count in the high word of d3: skip that many longs */
    movel %d3,%d0	| 4083AE2C
    jbpl CB8TO1CLIP_1EE	| 4083AE2E
    jbeq CB8TO1CLIP_216	| 4083AE30
    swap %d0	| 4083AE32
    negw %d0	| 4083AE34
    subw %d0,%d2	| 4083AE36
    lslw #2,%d0	| 4083AE38
    addaw %d0,%a2	| 4083AE3A
    addaw %d0,%a4	| 4083AE3C
    lslw #3,%d0	| 4083AE3E
    addaw %d0,%a3	| 4083AE40
    tstw %d2	| 4083AE42
    jbmi CB8TO1CLIP_A6	| 4083AE44
    jbra CB8TO1CLIP_164	| 4083AE48
CB8TO1CLIP_1DC:         /* a full run */
    movew %d3,%d0
    movew %d0,%d1
    lslw #2,%d1
    addaw %d1,%a2
    subw %d0,%d2
    movew %d0,%d1
    lea %pc@(CB8TO1CLIP_1B8),%a0
    jbra CB8TO1CLIP_204
CB8TO1CLIP_1EE:         /* its length */
    swap %d0	| 4083AE5C
    movew %d0,%d1	| 4083AE5E
    lslw #2,%d1	| 4083AE60
    addaw %d1,%a2	| 4083AE62
    subw %d0,%d2	| 4083AE64
    movew %d0,%d1	| 4083AE66
    lea %pc@(CB8TO1CLIP_164),%a0	| 4083AE68
    jbra CB8TO1CLIP_204	| 4083AE6C
CB8TO1CLIP_200:         /* store */
    jbsr CB8TO1CLIP_230
    movel %d0,%a4@+
CB8TO1CLIP_204:         /* next */
    dbf %d1,CB8TO1CLIP_200
    tstw %d2
    jbmi CB8TO1CLIP_A6
    jmp %a0@
CB8TO1CLIP_210:         /* masked run */
    lea %pc@(CB8TO1CLIP_1B8),%a0
    jbra CB8TO1CLIP_21A
CB8TO1CLIP_216:         /* masked run */
    lea %pc@(CB8TO1CLIP_164),%a0	| 4083AE84
CB8TO1CLIP_21A:         /* through the mask */
    movel %a2@+,%d1
    jbsr CB8TO1CLIP_230
    andl %d1,%d0
    notl %d1
    andl %a4@,%d1
    orl %d1,%d0
    movel %d0,%a4@+
    subqw #1,%d2
    jbmi CB8TO1CLIP_A6
    jmp %a0@

CB8TO1CLIP_230:         /* 32 source bytes to one 1-bit long through the table */
    movel %a5@,%d0
    jbeq CB8TO1CLIP_236
    moveq #15,%d0
CB8TO1CLIP_236:         /* eight longs */
    moveq #7,%d7
    subal %a1,%a1
CB8TO1CLIP_23A:         /* same as the last long? reuse; else four bits */
    movel %a3@+,%d6
    cmpl %a1,%d6
    jbeq CB8TO1CLIP_276
    moveal %d6,%a1
    swap %d6
    moveb %d6,%d5
    lsrw #8,%d6
    moveb %a5@(0x3,%d6:w:4),%d6
    lsrw #1,%d6
    addxl %d0,%d0
    moveb %a5@(0x3,%d5:w:4),%d5
    lsrw #1,%d5
    addxl %d0,%d0
    swap %d6
    moveb %d6,%d5
    lsrw #8,%d6
    moveb %a5@(0x3,%d6:w:4),%d6
    lsrw #1,%d6
    addxl %d0,%d0
    moveb %a5@(0x3,%d5:w:4),%d5
    lsrw #1,%d5
    addxl %d0,%d0
    dbf %d7,CB8TO1CLIP_23A
    moveq #-1,%d6
    rts
CB8TO1CLIP_276:         /* shift in; next */
    moveq #15,%d5
    andb %d0,%d5
    lsll #4,%d0
    orb %d5,%d0
    dbf %d7,CB8TO1CLIP_23A
    moveq #-1,%d6
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4083AEF4
XGETSEEK:               /* out of stack: STNOSTACK through fp-128 */
    clrl %fp@(-132)

XGETSEEK_4:             /* out of stack: STNOSTACK (fp-128) */
    jmp %fp@(0xffffffffffffff80,%za0)@(0)	| 4083AF04

trap_ALLOCRUNBUF:
ALLOCRUNBUF:            /* a run buffer on the stack for the region runs; return through d2 */
    movel %sp@+,%d2
    moveq #0,%d1
    movew %fp@(-16),%d1
    addql #2,%d1
    cmpiw #5,%fp@(-118)
    jbeq ALLOCRUNBUF_18
    movel %d1,%d0
    addl %d1,%d1
    addl %d0,%d1
ALLOCRUNBUF_18:         /* the run buffer size: 1.5 longs per long (3 for 32-bit) */
    lsrl #1,%d1
    addql #3,%d1
    subl %d1,%fp@(-132)
    jbpl ALLOCRUNBUF_24
    jbsr XGETSEEK_4
ALLOCRUNBUF_24:         /* on the stack; return */
    lsll #2,%d1
    subal %d1,%sp
    moveal %sp,%a0
    addqw #4,%a0
    jmp @(0x0,%d2:l)
    .short  0x0000, 0x0000, 0x0000	| 4083AF3A

trap_GETSEEK:
GETSEEK:                /* set up the region masks for StretchBits: of the n regions on the stack, the non-rectangular ones go to SEEKRGN state blocks (fp-60...); several of them: combined row by row */
    movel %sp@(4),%d3
    lea %sp@(0xc,%d3:w:4),%a3
    lea %fp@(-60),%a1
    clrw %d4
    tstl %fp@(-12)
    jbeq GETSEEK_1E
    jsr @(0x1c50,%za0)@(0)	| 4083AF54
    movel %a0,%fp@(-12)
GETSEEK_1E:             /* next region: a rectangle needs no state */
    moveq #10,%d0
    moveal %a3@-,%a0
    moveal %a0@,%a0
    cmpw %a0@,%d0
    jbeq GETSEEK_70
    cmpiw #2,%d3
    jbeq GETSEEK_44
    movel %a3@,%sp@-
    pea %fp@(-116)
    clrw %sp@-
    jsr @(0x1aa4,%za0)@(0)	| 4083AF76
    jblt XGETSEEK
    jbeq GETSEEK_70
    moveal %a3@,%a0
    moveal %a0@,%a0
GETSEEK_44:             /* one more region to seek */
    addqw #1,%d4
    addw %d4,%d4
    movew %fp@(-110),%d1
    movew %fp@(-14),%d2
    moveq #0,%d0
    movew %d1,%d0
    subw %d2,%d0
    lsrw #5,%d0
    subl %d0,%fp@(-132)
    jbpl GETSEEK_62
    jbsr XGETSEEK_4
GETSEEK_62:             /* seek it to the first row */
    movew %fp@(-114),%d0
    jsr @(0x1c54,%za0)@(0)	| 4083AFA6
    subaw #24,%a1
GETSEEK_70:             /* next region; more than one: combine; one: the seek proc for it */
    dbf %d3,GETSEEK_1E
    tstl %fp@(-32)
    jbeq GETSEEK_B2
    addqw #1,%d4
    movew %d4,%fp@(-2)
    cmpiw #1,%d4
    jbgt GETSEEK_F8
    movew %fp@(-110),%d1
    movew %fp@(-14),%d2
    moveq #0,%d0
    movew %d1,%d0
    subw %d2,%d0
    lsrw #5,%d0
    subl %d0,%fp@(-132)
    jbpl GETSEEK_A0
    jbsr XGETSEEK_4
GETSEEK_A0:             /* one region: seek to the top */
    movew %fp@(-114),%d0
    jsr @(0x1c54,%za0)@(0)	| 4083AFE4
    moveq #0,%d0
    moveal %fp@(-52),%a0
    jbra GETSEEK_C8
GETSEEK_B2:             /* none or one: the run builder */
    movew %fp@(-118),%d0
    tstl %fp@(-12)
    jbeq GETSEEK_BE
    moveq #0,%d0
GETSEEK_BE:             /* plain rectangle: the full-mask buffer */
    movew %d4,%fp@(-2)
    jbne GETSEEK_E0
    moveal %fp@(-8),%a0
GETSEEK_C8:             /* build the runs for the rectangle (0x1AA8) */
    movew %fp@(-114),%d3
    subw %fp@(-14),%d3
    movew %fp@(-110),%d4
    subw %fp@(-14),%d4
    jsr @(0x1aa8,%za0)@(0)	| 4083B018
    jbra GETSEEK_F8
GETSEEK_E0:             /* two regions: the second's buffer */
    tstw %d0
    jbne GETSEEK_F2
    cmpiw #2,%d4
    jbne GETSEEK_F8
    movel %fp@(-8),%fp@(-52)
    jbra GETSEEK_F8
GETSEEK_F2:             /* shifted */
    oriw #1,%fp@(-2)
GETSEEK_F8:             /* the run builder for the depth (0x1C8C) */
    movew %fp@(-118),%d0
    moveal 0x1c8c,%a0
    addal %a0@(0x0,%d0:w:4),%a0
    movel %a0,%fp@(-24)
    tstl %fp@(-12)
    jbeq GETSEEK_110
    moveq #0,%d0
GETSEEK_110:            /* the seek proc by the number of regions (0x1C90) */
    subal %a0,%a0
    subql #8,%a3
    moveal %a3@,%a1
    movew %fp@(-2),%d1
    movew %d0,%d2
    orw %d1,%d2
    jbeq GETSEEK_128
    moveal 0x1c90,%a0
    addal %a0@(0x0,%d0:w:4),%a0
GETSEEK_128:            /* the mask builder (0x1C94) */
    movel %a0,%fp@(-20)
    moveal 0x1c94,%a0
    cmpiw #7,%d1
    jble GETSEEK_13A
    subiw #10,%d1
GETSEEK_13A:            /* return through it */
    addal %a0@(0x0,%d1:w:4),%a0
    movel %a0,%fp@(-28)
    jmp %a1@
