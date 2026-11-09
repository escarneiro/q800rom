/*
 quickdraw/drawcore.s - blitters, rectangles, cursor drawing, slabs
 From STEEPBLITTAB (0x4082A018). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 In order: FASTSLANT (1-pixel lines), RGNBLT and its mode loops (R*: boolean, then the
 arithmetic modes), the rectangle routines (StdRect, STDDEVLOOP for drawing on each
 screen, PUSHVERB, RSect, UnionRect...), BITBLT and its loops (B*), the cursor core
 (CRSRCORE: Hide/Show/Shield/Obscure/Set/AllocCursor, BLITCURSOR/UNBLITCURSOR), the bit
 and color utilities (BitAnd.., Random, ForeColor, COLORMAP, GetPixel), and the slab
 loops (DRAWSLAB, SL*: one row segment through a mask, with the 16/32-bit arithmetic slab
 loops in SLARITH16TAB/SLARITH32TAB).

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not
 taken from Apple. Loop labels are described from their instructions.
*/

/*
 STEEPBLITTAB / SHALLOWBLITTAB: FASTSLANT's loops, by pixel size (1..32 bits) for the
 line color, then the same for xor (pattern mode 1). Offsets from the table.
*/
STEEPBLITTAB:
    .long   FASTSLANT_90-STEEPBLITTAB	| 4082A018
    .long   FASTSLANT_D0-STEEPBLITTAB	| 4082A01C
    .long   FASTSLANT_110-STEEPBLITTAB	| 4082A020
    .long   FASTSLANT_150-STEEPBLITTAB	| 4082A024
    .long   FASTSLANT_190-STEEPBLITTAB	| 4082A028
    .long   FASTSLANT_1D0-STEEPBLITTAB	| 4082A02C
    .long   FASTSLANT_210-STEEPBLITTAB	| 4082A030
    .long   FASTSLANT_250-STEEPBLITTAB	| 4082A034
    .long   FASTSLANT_290-STEEPBLITTAB	| 4082A038
    .long   FASTSLANT_2D0-STEEPBLITTAB	| 4082A03C
    .long   FASTSLANT_310-STEEPBLITTAB	| 4082A040
    .long   FASTSLANT_350-STEEPBLITTAB	| 4082A044
SHALLOWBLITTAB:         /* FASTSLANT's loops for shallow lines, by pixel size (data) */
    .long   FASTSLANT_440-SHALLOWBLITTAB	| 4082A048
    .long   FASTSLANT_490-SHALLOWBLITTAB	| 4082A04C
    .long   FASTSLANT_4F0-SHALLOWBLITTAB	| 4082A050
    .long   FASTSLANT_4F0-SHALLOWBLITTAB	| 4082A054
    .long   FASTSLANT_4F0-SHALLOWBLITTAB	| 4082A058
    .long   DRAWLINE_4C6-SHALLOWBLITTAB	| 4082A05C
    .long   FASTSLANT_550-SHALLOWBLITTAB	| 4082A060
    .long   FASTSLANT_5A0-SHALLOWBLITTAB	| 4082A064
    .long   FASTSLANT_600-SHALLOWBLITTAB	| 4082A068
    .long   FASTSLANT_600-SHALLOWBLITTAB	| 4082A06C
    .long   FASTSLANT_600-SHALLOWBLITTAB	| 4082A070
    .long   DRAWLINE_4C6-SHALLOWBLITTAB	| 4082A074
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A078

/*
 FASTSLANT: draw a one-pixel-wide solid line straight into the destination bitmap (no
 pattern, no region clipping needed), from DrawLine's frame (fp: the line's ends, the
 bitmap, its row bytes, the pixel size shift in fp-118). Steep lines (STEEPBLITTAB)
 set one pixel per row; shallow ones (SHALLOWBLITTAB) a run of pixels per row. x
 advances by a 16.16 fixed-point step whose carry (addx) moves to the next pixel.
 Each table has 12 loops: copy for pixel sizes 1, 2, 4, 8, 16, 32 bits, then xor.
 Cases it does not handle go back to DRAWLINE.
*/
trap_FASTSLANT:
FASTSLANT:
    moveal %fp@(-244),%a4
    movew %d1,%d0
    subw %fp@(-238),%d0
    movew %fp@(-240),%d6
    andiw #32767,%d6
    mulsw %d6,%d0
    moveaw %d6,%a3
    addal %d0,%a4
    tstw %a2
    jbeq FASTSLANT_394
    subw %d1,%d3
    moveq #-1,%d6
    addw %d3,%d6
    movel %fp@(-300),%d5
    movel %d5,%d2
    swap %d2
    subw %fp@(-236),%d2
    extl %d2
    movew %fp@(-118),%d3
    lsll %d3,%d2
    movel %d2,%d4
    lsrl #5,%d2
    lsll #2,%d2
    addal %d2,%a4
    andiw #31,%d4
    moveq #1,%d0
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x574,%za0)@(0x0)	| 4082A0C6
    moveb %d0,%fp@(-258)
    tstl %d7
    jbpl FASTSLANT_58
    negw %d7
    notw %d5
FASTSLANT_58:           /* horizontal direction */
    tstw %d7
    jbne FASTSLANT_60
    notw %d7
    movew %d7,%d5
FASTSLANT_60:           /* d1 = the pen color (pattern mode: 1 xor with -1, above 1 the other color) */
    movew %fp@(-212),%d2
    movel %fp@(-160),%d1
    moveq #0,%d0
    lea %pc@(STEEPBLITTAB),%a0
    cmpiw #1,%fp@(-152)
    jblt FASTSLANT_7C
    jbeq FASTSLANT_82
    movel %fp@(-164),%d1
FASTSLANT_7C:           /* jump to the loop for this pixel size */
    addal %a0@(0x0,%d3:w:4),%a0
    jmp %a0@
FASTSLANT_82:           /* xor: all ones */
    moveq #-1,%d1
    addal %a0@(0x18,%d3:w:4),%a0
    jmp %a0@
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A10A
FASTSLANT_90:           /* steep line, 1-bit pixels, set the line color: which way does x go? */
    tstl %d7	| 4082A110
    jbmi FASTSLANT_B0	| 4082A112
FASTSLANT_94:           /* one pixel per row, x increasing */
    bfins %d1,%a4@,%d4,%d2	| 4082A114
    addal %a3,%a4	| 4082A118
    addw %d7,%d5	| 4082A11A
    addxl %d0,%d4	| 4082A11C
    dbf %d6,FASTSLANT_94	| 4082A11E
    braw DRAWLINE_4C6	| 4082A122
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A126
FASTSLANT_B0:           /* one pixel per row, x decreasing */
    bfins %d1,%a4@,%d4,%d2	| 4082A130
    addal %a3,%a4	| 4082A134
    addw %d7,%d5	| 4082A136
    subxl %d0,%d4	| 4082A138
    dbf %d6,FASTSLANT_B0	| 4082A13A
    braw DRAWLINE_4C6	| 4082A13E
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A142
FASTSLANT_D0:           /* steep line, 2-bit pixels, set the line color: which way does x go? */
    tstl %d7	| 4082A150
    jbmi FASTSLANT_F0	| 4082A152
FASTSLANT_D4:           /* one pixel per row, x increasing */
    bfins %d1,%a4@,%d4,2	| 4082A154
    addal %a3,%a4	| 4082A158
    movel %d0,%d2	| 4082A15A
    addw %d7,%d5	| 4082A15C
    addxl %d0,%d2	| 4082A15E
    addl %d2,%d4	| 4082A160
    addl %d2,%d4	| 4082A162
    dbf %d6,FASTSLANT_D4	| 4082A164
    jbra DRAWLINE_4C6	| 4082A168
    .byte   0x00, 0x00, 0x00, 0x00	| 4082A16C
FASTSLANT_F0:           /* one pixel per row, x decreasing */
    bfins %d1,%a4@,%d4,2	| 4082A170
    addal %a3,%a4	| 4082A174
    movel %d0,%d2	| 4082A176
    addw %d7,%d5	| 4082A178
    addxl %d0,%d2	| 4082A17A
    subl %d2,%d4	| 4082A17C
    subl %d2,%d4	| 4082A17E
    dbf %d6,FASTSLANT_F0	| 4082A180
    braw DRAWLINE_4C6	| 4082A184
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A188
FASTSLANT_110:          /* steep line, 4-bit pixels, set the line color: which way does x go? */
    tstl %d7	| 4082A190
    jbmi FASTSLANT_130	| 4082A192
FASTSLANT_114:          /* one pixel per row, x increasing */
    bfins %d1,%a4@,%d4,4	| 4082A194
    addal %a3,%a4	| 4082A198
    movel %d0,%d2	| 4082A19A
    addw %d7,%d5	| 4082A19C
    addxl %d0,%d2	| 4082A19E
    lsll #2,%d2	| 4082A1A0
    addl %d2,%d4	| 4082A1A2
    dbf %d6,FASTSLANT_114	| 4082A1A4
    jbra DRAWLINE_4C6	| 4082A1A8
    .byte   0x00, 0x00, 0x00, 0x00	| 4082A1AC
FASTSLANT_130:          /* one pixel per row, x decreasing */
    bfins %d1,%a4@,%d4,4	| 4082A1B0
    addal %a3,%a4	| 4082A1B4
    movel %d0,%d2	| 4082A1B6
    addw %d7,%d5	| 4082A1B8
    addxl %d0,%d2	| 4082A1BA
    lsll #2,%d2	| 4082A1BC
    subl %d2,%d4	| 4082A1BE
    dbf %d6,FASTSLANT_130	| 4082A1C0
    braw DRAWLINE_4C6	| 4082A1C4
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A1C8
FASTSLANT_150:          /* steep line, 8-bit pixels, set the line color: which way does x go? */
    lsrl #3,%d4
    tstl %d7
    jbmi FASTSLANT_170
FASTSLANT_156:          /* one pixel per row, x increasing */
    moveb %d1,%a4@(0x0,%d4:w)
    addal %a3,%a4
    addw %d7,%d5
    addxl %d0,%d4
    dbf %d6,FASTSLANT_156
    jbra DRAWLINE_4C6
    .long   0x00000000, 0x00000000	| 4082A1E8
FASTSLANT_170:          /* one pixel per row, x decreasing */
    moveb %d1,%a4@(0x0,%d4:w)
    addal %a3,%a4
    addw %d7,%d5
    subxl %d0,%d4
    dbf %d6,FASTSLANT_170
    jbra DRAWLINE_4C6
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A202
FASTSLANT_190:          /* steep line, 16-bit pixels, set the line color: which way does x go? */
    lsrl #4,%d4	| 4082A210
    tstl %d7	| 4082A212
    jbmi FASTSLANT_1B0	| 4082A214
FASTSLANT_196:          /* one pixel per row, x increasing */
    movew %d1,%a4@(0,%d4:w:2)	| 4082A216
    addal %a3,%a4	| 4082A21A
    addw %d7,%d5	| 4082A21C
    addxl %d0,%d4	| 4082A21E
    dbf %d6,FASTSLANT_196	| 4082A220
    braw DRAWLINE_4C6	| 4082A224
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A228
FASTSLANT_1B0:          /* one pixel per row, x decreasing */
    movew %d1,%a4@(0,%d4:w:2)	| 4082A230
    addal %a3,%a4	| 4082A234
    addw %d7,%d5	| 4082A236
    subxl %d0,%d4	| 4082A238
    dbf %d6,FASTSLANT_1B0	| 4082A23A
    braw DRAWLINE_4C6	| 4082A23E
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A242
FASTSLANT_1D0:          /* steep line, 32-bit pixels, set the line color: which way does x go? */
    lsrl #5,%d4	| 4082A250
    tstl %d7	| 4082A252
    jbmi FASTSLANT_1F0	| 4082A254
FASTSLANT_1D6:          /* one pixel per row, x increasing */
    movel %d1,%a4@(0,%d4:w:4)	| 4082A256
    addal %a3,%a4	| 4082A25A
    addw %d7,%d5	| 4082A25C
    addxl %d0,%d4	| 4082A25E
    dbf %d6,FASTSLANT_1D6	| 4082A260
    braw DRAWLINE_4C6	| 4082A264
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A268
FASTSLANT_1F0:          /* one pixel per row, x decreasing */
    movel %d1,%a4@(0,%d4:w:4)	| 4082A270
    addal %a3,%a4	| 4082A274
    addw %d7,%d5	| 4082A276
    subxl %d0,%d4	| 4082A278
    dbf %d6,FASTSLANT_1F0	| 4082A27A
    braw DRAWLINE_4C6	| 4082A27E
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A282
FASTSLANT_210:          /* steep line, 1-bit pixels, xor (invert): which way does x go? */
    tstl %d7	| 4082A290
    jbmi FASTSLANT_230	| 4082A292
FASTSLANT_214:          /* one pixel per row, x increasing */
    bfchg %a4@,%d4,%d2	| 4082A294
    addal %a3,%a4	| 4082A298
    addw %d7,%d5	| 4082A29A
    addxl %d0,%d4	| 4082A29C
    dbf %d6,FASTSLANT_214	| 4082A29E
    braw DRAWLINE_4C6	| 4082A2A2
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A2A6
FASTSLANT_230:          /* one pixel per row, x decreasing */
    bfchg %a4@,%d4,%d2	| 4082A2B0
    addal %a3,%a4	| 4082A2B4
    addw %d7,%d5	| 4082A2B6
    subxl %d0,%d4	| 4082A2B8
    dbf %d6,FASTSLANT_230	| 4082A2BA
    braw DRAWLINE_4C6	| 4082A2BE
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A2C2
FASTSLANT_250:          /* steep line, 2-bit pixels, xor (invert): which way does x go? */
    tstl %d7	| 4082A2D0
    jbmi FASTSLANT_270	| 4082A2D2
FASTSLANT_254:          /* one pixel per row, x increasing */
    bfchg %a4@,%d4,2	| 4082A2D4
    addal %a3,%a4	| 4082A2D8
    movel %d0,%d2	| 4082A2DA
    addw %d7,%d5	| 4082A2DC
    addxl %d0,%d2	| 4082A2DE
    addl %d2,%d4	| 4082A2E0
    addl %d2,%d4	| 4082A2E2
    dbf %d6,FASTSLANT_254	| 4082A2E4
    jbra DRAWLINE_4C6	| 4082A2E8
    .byte   0x00, 0x00, 0x00, 0x00	| 4082A2EC
FASTSLANT_270:          /* one pixel per row, x decreasing */
    bfchg %a4@,%d4,2	| 4082A2F0
    addal %a3,%a4	| 4082A2F4
    movel %d0,%d2	| 4082A2F6
    addw %d7,%d5	| 4082A2F8
    addxl %d0,%d2	| 4082A2FA
    subl %d2,%d4	| 4082A2FC
    subl %d2,%d4	| 4082A2FE
    dbf %d6,FASTSLANT_270	| 4082A300
    braw DRAWLINE_4C6	| 4082A304
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A308
FASTSLANT_290:          /* steep line, 4-bit pixels, xor (invert): which way does x go? */
    tstl %d7	| 4082A310
    jbmi FASTSLANT_2B0	| 4082A312
FASTSLANT_294:          /* one pixel per row, x increasing */
    bfchg %a4@,%d4,4	| 4082A314
    addal %a3,%a4	| 4082A318
    movel %d0,%d2	| 4082A31A
    addw %d7,%d5	| 4082A31C
    addxl %d0,%d2	| 4082A31E
    lsll #2,%d2	| 4082A320
    addl %d2,%d4	| 4082A322
    dbf %d6,FASTSLANT_294	| 4082A324
    jbra DRAWLINE_4C6	| 4082A328
    .byte   0x00, 0x00, 0x00, 0x00	| 4082A32C
FASTSLANT_2B0:          /* one pixel per row, x decreasing */
    bfchg %a4@,%d4,4	| 4082A330
    addal %a3,%a4	| 4082A334
    movel %d0,%d2	| 4082A336
    addw %d7,%d5	| 4082A338
    addxl %d0,%d2	| 4082A33A
    lsll #2,%d2	| 4082A33C
    subl %d2,%d4	| 4082A33E
    dbf %d6,FASTSLANT_2B0	| 4082A340
    braw DRAWLINE_4C6	| 4082A344
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A348
FASTSLANT_2D0:          /* steep line, 8-bit pixels, xor (invert): which way does x go? */
    lsrl #3,%d4	| 4082A350
    tstl %d7	| 4082A352
    jbmi FASTSLANT_2F0	| 4082A354
FASTSLANT_2D6:          /* one pixel per row, x increasing */
    eorb %d1,%a4@(0,%d4:w)	| 4082A356
    addal %a3,%a4	| 4082A35A
    addw %d7,%d5	| 4082A35C
    addxl %d0,%d4	| 4082A35E
    dbf %d6,FASTSLANT_2D6	| 4082A360
    braw DRAWLINE_4C6	| 4082A364
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A368
FASTSLANT_2F0:          /* one pixel per row, x decreasing */
    eorb %d1,%a4@(0,%d4:w)	| 4082A370
    addal %a3,%a4	| 4082A374
    addw %d7,%d5	| 4082A376
    subxl %d0,%d4	| 4082A378
    dbf %d6,FASTSLANT_2F0	| 4082A37A
    braw DRAWLINE_4C6	| 4082A37E
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A382
FASTSLANT_310:          /* steep line, 16-bit pixels, xor (invert): which way does x go? */
    lsrl #4,%d4	| 4082A390
    tstl %d7	| 4082A392
    jbmi FASTSLANT_330	| 4082A394
FASTSLANT_316:          /* one pixel per row, x increasing */
    eorw %d1,%a4@(0,%d4:w:2)	| 4082A396
    addal %a3,%a4	| 4082A39A
    addw %d7,%d5	| 4082A39C
    addxl %d0,%d4	| 4082A39E
    dbf %d6,FASTSLANT_316	| 4082A3A0
    braw DRAWLINE_4C6	| 4082A3A4
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A3A8
FASTSLANT_330:          /* one pixel per row, x decreasing */
    eorw %d1,%a4@(0,%d4:w:2)	| 4082A3B0
    addal %a3,%a4	| 4082A3B4
    addw %d7,%d5	| 4082A3B6
    subxl %d0,%d4	| 4082A3B8
    dbf %d6,FASTSLANT_330	| 4082A3BA
    braw DRAWLINE_4C6	| 4082A3BE
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A3C2
FASTSLANT_350:          /* steep line, 32-bit pixels, xor (invert): which way does x go? */
    lsrl #5,%d4	| 4082A3D0
    tstl %d7	| 4082A3D2
    jbmi FASTSLANT_370	| 4082A3D4
FASTSLANT_356:          /* one pixel per row, x increasing */
    eorl %d1,%a4@(0,%d4:w:4)	| 4082A3D6
    addal %a3,%a4	| 4082A3DA
    addw %d7,%d5	| 4082A3DC
    addxl %d0,%d4	| 4082A3DE
    dbf %d6,FASTSLANT_356	| 4082A3E0
    braw DRAWLINE_4C6	| 4082A3E4
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A3E8
FASTSLANT_370:          /* one pixel per row, x decreasing */
    eorl %d1,%a4@(0,%d4:w:4)	| 4082A3F0
    addal %a3,%a4	| 4082A3F4
    addw %d7,%d5	| 4082A3F6
    subxl %d0,%d4	| 4082A3F8
    dbf %d6,FASTSLANT_370	| 4082A3FA
    braw DRAWLINE_4C6	| 4082A3FE
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A402
FASTSLANT_390:          /* not a case for the fast path: the general line code (DRAWLINE_2D4) */
    jbra DRAWLINE_2D4
FASTSLANT_394:          /* a shallow line: inside the clip rows? the slope in 16.16 fixed point */
    cmpw %fp@(-288),%d1
    jbgt FASTSLANT_390
    cmpw %fp@(-284),%d3
    jblt FASTSLANT_390
    subw %d1,%d3
    moveq #-2,%d6
    addw %d3,%d6
    movew %d2,%d0
    tstl %d7
    jbpl FASTSLANT_3AE
    movew %d4,%d0
FASTSLANT_3AE:          /* the starting pixel's long and bit */
    subw %fp@(-236),%d0
    extl %d0
    movew %fp@(-118),%d3
    lsll %d3,%d0
    movel %d0,%d1
    lsrl #5,%d0
    lsll #2,%d0
    addal %d0,%a4
    andiw #31,%d1
    movel %d7,%d5
    jbpl FASTSLANT_3CC
    negl %d5
FASTSLANT_3CC:          /* too shallow or too wide steps: the general code */
    moveal %d5,%a2
    cmpil #67584,%d5
    jblt FASTSLANT_390
    clrw %d5
    swap %d5
    lsll %d3,%d5
    cmpiw #32,%d5
    jbge FASTSLANT_390
    subw %d2,%d4
    movew %fp@(-302),%d7
    lsll %d3,%d4
    addw %d1,%d4
    moveaw %d4,%a5
    movel %d1,%d4
    tstl %d7
    jbpl FASTSLANT_3F8
    subaw %d1,%a5
    subaw %d1,%a5
FASTSLANT_3F8:          /* the length of the first and last runs */
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 4082A47A
    moveb %d0,%fp@(-258)
    moveq #0,%d0
    movew %fp@(-110),%d0
    subw %fp@(-300),%d0
    tstl %d7
    jbmi FASTSLANT_41A
    movew %fp@(-304),%d0
    subw %fp@(-114),%d0
FASTSLANT_41A:          /* jump to the shallow loop for this pixel size */
    lsll %d3,%d0
    moveq #0,%d2
    movel %fp@(-160),%d1
    lea %pc@(SHALLOWBLITTAB),%a0
    cmpiw #1,%fp@(-152)
    jblt FASTSLANT_434
    jbeq FASTSLANT_43A
    movel %fp@(-164),%d1
FASTSLANT_434:          /* jump into the loop for the pixel size (offset table) */
    addal %a0@(0x0,%d3:w:4),%a0
    jmp %a0@
FASTSLANT_43A:          /* xor table half */
    addal %a0@(0x18,%d3:w:4),%a0
    jmp %a0@
FASTSLANT_440:          /* shallow line, 1-bit pixels, set the line color: which way does x go? */
    tstl %d7	| 4082A4C0
    jbmi FASTSLANT_470	| 4082A4C2
FASTSLANT_444:          /* a run of pixels per row, x increasing */
    bfins %d1,%a4@,%d4,%d0	| 4082A4C4
    addal %a3,%a4	| 4082A4C8
    addl %d0,%d4	| 4082A4CA
    movew %d5,%d0	| 4082A4CC
    addw %a2,%d7	| 4082A4CE
    addxl %d2,%d0	| 4082A4D0
    dbf %d6,FASTSLANT_444	| 4082A4D2
    subaw %d4,%a5	| 4082A4D6
    movew %a5,%d0	| 4082A4D8
    bfins %d1,%a4@,%d4,%d0	| 4082A4DA
    braw DRAWLINE_4C6	| 4082A4DE
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A4E2
FASTSLANT_470:          /* a run of pixels per row, x decreasing */
    subl %d0,%d4	| 4082A4F0
    bfins %d1,%a4@,%d4,%d0	| 4082A4F2
    addal %a3,%a4	| 4082A4F6
    movew %d5,%d0	| 4082A4F8
    addw %a2,%d7	| 4082A4FA
    addxl %d2,%d0	| 4082A4FC
    dbf %d6,FASTSLANT_470	| 4082A4FE
    addaw %d4,%a5	| 4082A502
    movew %a5,%d0	| 4082A504
    subl %d0,%d4	| 4082A506
    bfins %d1,%a4@,%d4,%d0	| 4082A508
    jbra DRAWLINE_4C6	| 4082A50C
FASTSLANT_490:          /* shallow line, 2-bit pixels, set the line color: which way does x go? */
    tstl %d7	| 4082A510
    jbmi FASTSLANT_4C0	| 4082A512
FASTSLANT_494:          /* a run of pixels per row, x increasing */
    bfins %d1,%a4@,%d4,%d0	| 4082A514
    addal %a3,%a4	| 4082A518
    addl %d0,%d4	| 4082A51A
    movel %d2,%d0	| 4082A51C
    addw %a2,%d7	| 4082A51E
    addxl %d2,%d0	| 4082A520
    addl %d0,%d0	| 4082A522
    addl %d5,%d0	| 4082A524
    dbf %d6,FASTSLANT_494	| 4082A526
    subaw %d4,%a5	| 4082A52A
    movew %a5,%d0	| 4082A52C
    bfins %d1,%a4@,%d4,%d0	| 4082A52E
    braw DRAWLINE_4C6	| 4082A532
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A536
FASTSLANT_4C0:          /* a run of pixels per row, x decreasing */
    subl %d0,%d4	| 4082A540
    bfins %d1,%a4@,%d4,%d0	| 4082A542
    addal %a3,%a4	| 4082A546
    movel %d2,%d0	| 4082A548
    addw %a2,%d7	| 4082A54A
    addxl %d2,%d0	| 4082A54C
    addl %d0,%d0	| 4082A54E
    addl %d5,%d0	| 4082A550
    dbf %d6,FASTSLANT_4C0	| 4082A552
    addaw %d4,%a5	| 4082A556
    movew %a5,%d0	| 4082A558
    subl %d0,%d4	| 4082A55A
    bfins %d1,%a4@,%d4,%d0	| 4082A55C
    braw DRAWLINE_4C6	| 4082A560
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A564
FASTSLANT_4F0:          /* shallow line, 4-bit pixels, set the line color: which way does x go? */
    tstl %d7	| 4082A570
    jbmi FASTSLANT_520	| 4082A572
FASTSLANT_4F4:          /* a run of pixels per row, x increasing */
    bfins %d1,%a4@,%d4,%d0	| 4082A574
    addal %a3,%a4	| 4082A578
    addl %d0,%d4	| 4082A57A
    movel %d2,%d0	| 4082A57C
    addw %a2,%d7	| 4082A57E
    addxl %d2,%d0	| 4082A580
    lsll %d3,%d0	| 4082A582
    addl %d5,%d0	| 4082A584
    dbf %d6,FASTSLANT_4F4	| 4082A586
    subaw %d4,%a5	| 4082A58A
    movew %a5,%d0	| 4082A58C
    bfins %d1,%a4@,%d4,%d0	| 4082A58E
    braw DRAWLINE_4C6	| 4082A592
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A596
FASTSLANT_520:          /* a run of pixels per row, x decreasing */
    subl %d0,%d4	| 4082A5A0
    bfins %d1,%a4@,%d4,%d0	| 4082A5A2
    addal %a3,%a4	| 4082A5A6
    movel %d2,%d0	| 4082A5A8
    addw %a2,%d7	| 4082A5AA
    addxl %d2,%d0	| 4082A5AC
    lsll %d3,%d0	| 4082A5AE
    addl %d5,%d0	| 4082A5B0
    dbf %d6,FASTSLANT_520	| 4082A5B2
    addaw %d4,%a5	| 4082A5B6
    movew %a5,%d0	| 4082A5B8
    subl %d0,%d4	| 4082A5BA
    bfins %d1,%a4@,%d4,%d0	| 4082A5BC
    braw DRAWLINE_4C6	| 4082A5C0
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A5C4
FASTSLANT_550:          /* shallow line, 1-bit pixels, xor (invert): which way does x go? */
    tstl %d7	| 4082A5D0
    jbmi FASTSLANT_580	| 4082A5D2
FASTSLANT_554:          /* a run of pixels per row, x increasing */
    bfchg %a4@,%d4,%d0	| 4082A5D4
    addal %a3,%a4	| 4082A5D8
    addl %d0,%d4	| 4082A5DA
    movew %d5,%d0	| 4082A5DC
    addw %a2,%d7	| 4082A5DE
    addxl %d2,%d0	| 4082A5E0
    dbf %d6,FASTSLANT_554	| 4082A5E2
    subaw %d4,%a5	| 4082A5E6
    movew %a5,%d0	| 4082A5E8
    bfchg %a4@,%d4,%d0	| 4082A5EA
    braw DRAWLINE_4C6	| 4082A5EE
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A5F2
FASTSLANT_580:          /* a run of pixels per row, x decreasing */
    subl %d0,%d4	| 4082A600
    bfchg %a4@,%d4,%d0	| 4082A602
    addal %a3,%a4	| 4082A606
    movew %d5,%d0	| 4082A608
    addw %a2,%d7	| 4082A60A
    addxl %d2,%d0	| 4082A60C
    dbf %d6,FASTSLANT_580	| 4082A60E
    addaw %d4,%a5	| 4082A612
    movew %a5,%d0	| 4082A614
    subl %d0,%d4	| 4082A616
    bfchg %a4@,%d4,%d0	| 4082A618
    jbra DRAWLINE_4C6	| 4082A61C
FASTSLANT_5A0:          /* shallow line, 2-bit pixels, xor (invert): which way does x go? */
    tstl %d7	| 4082A620
    jbmi FASTSLANT_5D0	| 4082A622
FASTSLANT_5A4:          /* a run of pixels per row, x increasing */
    bfchg %a4@,%d4,%d0	| 4082A624
    addal %a3,%a4	| 4082A628
    addl %d0,%d4	| 4082A62A
    movel %d2,%d0	| 4082A62C
    addw %a2,%d7	| 4082A62E
    addxl %d2,%d0	| 4082A630
    addl %d0,%d0	| 4082A632
    addl %d5,%d0	| 4082A634
    dbf %d6,FASTSLANT_5A4	| 4082A636
    subaw %d4,%a5	| 4082A63A
    movew %a5,%d0	| 4082A63C
    bfchg %a4@,%d4,%d0	| 4082A63E
    braw DRAWLINE_4C6	| 4082A642
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A646
FASTSLANT_5D0:          /* a run of pixels per row, x decreasing */
    subl %d0,%d4	| 4082A650
    bfchg %a4@,%d4,%d0	| 4082A652
    addal %a3,%a4	| 4082A656
    movel %d2,%d0	| 4082A658
    addw %a2,%d7	| 4082A65A
    addxl %d2,%d0	| 4082A65C
    addl %d0,%d0	| 4082A65E
    addl %d5,%d0	| 4082A660
    dbf %d6,FASTSLANT_5D0	| 4082A662
    addaw %d4,%a5	| 4082A666
    movew %a5,%d0	| 4082A668
    subl %d0,%d4	| 4082A66A
    bfchg %a4@,%d4,%d0	| 4082A66C
    braw DRAWLINE_4C6	| 4082A670
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A674
FASTSLANT_600:          /* shallow line, 4-bit pixels, xor (invert): which way does x go? */
    tstl %d7	| 4082A680
    jbmi FASTSLANT_630	| 4082A682
FASTSLANT_604:          /* a run of pixels per row, x increasing */
    bfchg %a4@,%d4,%d0	| 4082A684
    addal %a3,%a4	| 4082A688
    addl %d0,%d4	| 4082A68A
    movel %d2,%d0	| 4082A68C
    addw %a2,%d7	| 4082A68E
    addxl %d2,%d0	| 4082A690
    lsll %d3,%d0	| 4082A692
    addl %d5,%d0	| 4082A694
    dbf %d6,FASTSLANT_604	| 4082A696
    subaw %d4,%a5	| 4082A69A
    movew %a5,%d0	| 4082A69C
    bfchg %a4@,%d4,%d0	| 4082A69E
    braw DRAWLINE_4C6	| 4082A6A2
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A6A6
FASTSLANT_630:          /* a run of pixels per row, x decreasing */
    subl %d0,%d4	| 4082A6B0
    bfchg %a4@,%d4,%d0	| 4082A6B2
    addal %a3,%a4	| 4082A6B6
    movel %d2,%d0	| 4082A6B8
    addw %a2,%d7	| 4082A6BA
    addxl %d2,%d0	| 4082A6BC
    lsll %d3,%d0	| 4082A6BE
    addl %d5,%d0	| 4082A6C0
    dbf %d6,FASTSLANT_630	| 4082A6C2
    addaw %d4,%a5	| 4082A6C6
    movew %a5,%d0	| 4082A6C8
    subl %d0,%d4	| 4082A6CA
    bfchg %a4@,%d4,%d0	| 4082A6CC
    braw DRAWLINE_4C6	| 4082A6D0
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082A6D4

/*
 RGNBLT: draw a rectangle (the shape's bounding box, a5 = destination bitmap) through the
 clip, vis and shape regions, row by row: the regions are scanned into a run list on
 the stack (one row at a time: skip offset, long count, masked or not), and the mode
 loop picked from the tables in low memory applies the source or pattern to each run.
 Modes: 0-15 boolean (0x1B68 table: RMASK0..RXMASK11, RCMASK for colorized 1-bit
 sources), 32-39 arithmetic (0x1C80 for 16-bit, 0x1C84 for 32-bit pixels), 50 hilite
 (0x1C88). Uses the caller's frame (StdBits, StdRect... locals at fp-114 .. fp-648).
 Overlapping source and destination are drawn bottom-up or right-to-left.
*/
trap_RGNBLT:
RGNBLT:
    movel %sp,%fp@(-600)
    movew %fp@(-114),%d1
    subw %a5@(8),%d1
    extl %d1
    lsll %d4,%d1
    andiw #-32,%d1
    lsrl %d4,%d1
    addw %a5@(8),%d1
    movew %d1,%fp@(-14)
    movew %fp@(-110),%d0
    subw %d1,%d0
    movew %d0,%d1
    extl %d1
    lsll %d4,%d1
    subql #1,%d1
    lsrl #5,%d1
    movew %d1,%fp@(-16)
    lsrw #5,%d0
    addqw #1,%d0
    lslw %d4,%d0
    subqw #1,%d0
RGNBLT_3A:              /* a row buffer on the stack for the region runs */
    clrl %sp@-
    dbf %d0,RGNBLT_3A
    movel %sp,%fp@(-8)
    moveq #-1,%d0
    cmpiw #4,%d4
    jbge RGNBLT_5E
    cmpiw #32,%fp@(-152)
    jblt RGNBLT_5E
    cmpiw #47,%fp@(-152)
    jbgt RGNBLT_5E
    moveq #0,%d0
RGNBLT_5E:              /* arithmetic modes on pixels under 16 bits need the region mask as pixels (fp-12 = 0) */
    movel %d0,%fp@(-12)
    movel %fp@(10),%sp@-
    movel %fp@(14),%sp@-
    movel %fp@(18),%sp@-
    movel #2,%sp@-
    jsr @(0x1a34,%za0)@(0)	| 4082A754
    movew %fp@(-118),%d4
    moveal %fp@(28),%a3
    movew %fp@(-116),%fp@(-582)
    movew %fp@(-112),%fp@(-584)
    movel #262145,%fp@(-588)
    movel %fp@(-8),%fp@(-592)
    movew %fp@(-152),%d2
    movew %d2,%d1
    cmpiw #32,%d2
    jbcs RGNBLT_158
    cmpiw #64,%d2
    jbcc RGNBLT_4C6
    cmpiw #48,%d2
    jblt RGNBLT_106
    cmpiw #50,%d2
    jbeq RGNBLT_106
    cmpiw #58,%d2
    jbne RGNBLT_4C6
    tstw %fp@(-142)
    jbne RGNBLT_106
    moveal %fp@(-136),%a0
    moveq #-1,%d0
    moveq #15,%d3
RGNBLT_D4:              /* hilite with an all-ones pattern? the fast hilite loop */
    cmpl %a0@+,%d0
    dbne %d3,RGNBLT_D4
    jbne RGNBLT_106
    moveal 0x1c88,%a0	/* the hilite loops */
    addal %a0@(0xfffffffffffffffc,%d4:w:4),%a0
    movel %a0,%fp@(-536)
    movew #16,%fp@(-152)
    movew %fp@(-212),%d7
    bfextu %fp@(-280),0,%d7,%d3
    bfextu %fp@(-276),0,%d7,%d6
    clrw %fp@(-142)
    jbra RGNBLT_28E
RGNBLT_106:             /* arithmetic modes (32..47): their table by pixel size */
    andiw #55,%d2
    bclr #4,%d2
    jbne RGNBLT_14E
    cmpiw #4,%d4
    jblt RGNBLT_150
    moveal 0x1c84,%a0
    jbne RGNBLT_120
    moveal 0x1c80,%a0
RGNBLT_120:             /* entry = table + offset of the mode */
    subiw #32,%d2
    jbeq RGNBLT_130
RGNBLT_126:             /* the loop */
    addal %a0@(0x0,%d2:w:4),%a0	/* (0x1C80: 16-bit, 0x1C84: 32-bit) */
    movel %a0,%fp@(-536)
    jbra RGNBLT_18E
RGNBLT_130:             /* blend with equal weights of 50%: the average loop instead */
    lea %fp@(-250),%a1
    movew %a1@+,%d0
    cmpw %a1@+,%d0
    jbne RGNBLT_126
    cmpw %a1@,%d0
    jbne RGNBLT_126
    addqw #1,%d0
    andiw #-2,%d0
    cmpiw #-32768,%d0
    jbne RGNBLT_126
    addqw #8,%d2
    jbra RGNBLT_126
RGNBLT_14E:             /* arithmetic mode on a pattern: its variant */
    addqw #8,%d2
RGNBLT_150:             /* (pattern modes 8..15) the table index */
    addw %d2,%d2
    subiw #40,%d2
    jbra RGNBLT_180
RGNBLT_158:             /* boolean modes: index = (mode & 11) with the not bit folded */
    andiw #11,%d2
    moveq #3,%d0
    andw %d2,%d0
    addw %d0,%d2
    cmpiw #8,%d2
    jbge RGNBLT_178
    cmpiw #4,%d2
    jbeq RGNBLT_180
    tstw %fp@(-260)
    jbeq RGNBLT_180
    addiw #40,%d2
RGNBLT_178:             /* a color pattern: the X variants */
    tstw %fp@(-142)
    jbeq RGNBLT_180
    addqw #8,%d2
RGNBLT_180:             /* the loop from the table at 0x1B68 */
    lea 0x1b68,%a0
    movel %a0@(0x0,%d2:w:2),%fp@(-536)
    movel %fp@(-456),%d7
RGNBLT_18E:             /* a pattern mode? its row and the pattern's start */
    btst #3,%d1
    jbeq RGNBLT_1CE
    movel %fp@(-136),%fp@(-504)
    movew %fp@(-142),%d1
    jbeq RGNBLT_1BE
    moveq #0,%d6
    movew %fp@(-138),%d6
    addqw #1,%d6
    divuw %fp@(-142),%d6
    subqw #1,%d6
    andw %fp@(-116),%d6
    muluw %d1,%d6
    swap %d6
    movew %fp@(-140),%d7
    jbra RGNBLT_28E
RGNBLT_1BE:             /* a 1-bit (8x8) pattern expanded in the frame: this row's long */
    moveq #15,%d7
    andw %fp@(-116),%d7
    movel %fp@(0xffffffffffffff78)@(0x0,%d7:w:4),%d6
    jbra RGNBLT_28E
RGNBLT_1CE:             /* a source mode: overlapping source and destination? */
    moveal %fp@(36),%a2
    lea %fp@(-360),%a4
    movel %a4@,%d0
    cmpl %a5@,%d0
    jbne RGNBLT_234
    movew %a3@,%d0
    subw %a5@(6),%d0
    movew %a2@,%d1
    subw %a4@(6),%d1
    subw %d1,%d0
    jblt RGNBLT_234
    jbgt RGNBLT_214
    movew %a3@(2),%d0
    subw %a5@(8),%d0
    movew %a2@(2),%d1
    subw %a4@(8),%d1
    cmpw %d1,%d0
    jble RGNBLT_234
    movew %a2@(6),%d1
    subw %a4@(8),%d1
    cmpw %d1,%d0
    jbge RGNBLT_234
    negw %fp@(-588)
    jbra RGNBLT_234
RGNBLT_214:             /* source below the destination: go bottom-up (negate the steps) */
    negw %fp@(-586)
    negl %fp@(-444)
    negl %fp@(-124)
    movew %fp@(-112),%fp@(-582)
    subqw #1,%fp@(-582)
    movew %fp@(-116),%fp@(-584)
    subqw #1,%fp@(-584)
RGNBLT_234:             /* the source's starting long and bit offset */
    movew %a3@(2),%d6
    subw %a5@(8),%d6
    extl %d6
    lsll %d4,%d6
    movew %a2@(2),%d1
    subw %a4@(8),%d1
    extl %d1
    lsll %d4,%d1
    subl %d1,%d6
    moveq #31,%d0
    andl %d0,%d6
    negl %d6
    movew %fp@(-582),%d0
    subw %a3@,%d0
    addw %a2@,%d0
    subw %a4@(6),%d0
    movew %a4@(4),%d1
    andiw #32767,%d1
    mulsw %d1,%d0
    moveal %a4@,%a0
    addal %d0,%a0
    movew %fp@(-114),%d0
    subw %a3@(2),%d0
    addw %a2@(2),%d0
    subw %a4@(8),%d0
    extl %d0
    lsll %d4,%d0
    subl %d6,%d0
    asrl #5,%d0
    lsll #2,%d0
    addal %d0,%a0
    movel %a0,%fp@(-504)
RGNBLT_28E:             /* the destination's starting row address */
    movew %fp@(-582),%d0
    subw %a5@(6),%d0
    movew %a5@(4),%d1
    andiw #32767,%d1
    mulsw %d1,%d0
    moveal %a5@,%a0
    addal %d0,%a0
    movew %fp@(-114),%d0
    subw %a5@(8),%d0
    extl %d0
    lsll %d4,%d0
    lsrl #5,%d0
    lsll #2,%d0
    movew %d0,%d1
    addl %a0,%d0
    movel %d0,%fp@(-512)
    tstw %fp@(-142)
    jbeq RGNBLT_2CC
    andw %d7,%d1
    movew %d1,%fp@(-144)
    movew %d1,%d6
    swap %d6
RGNBLT_2CC:             /* d2 = mode; d3/d4/d5 the direction and colors */
    movew %fp@(-152),%d2
    movel %fp@(-280),%d4
    cmpiw #16,%d2
    jbeq RGNBLT_306
    tstl %fp@(-12)
    jbne RGNBLT_2FA
    tstw %fp@(-588)
    jbpl RGNBLT_2FA
    movew %fp@(-16),%d0
    extl %d0
    lsll #2,%d0
    addl %d0,%fp@(-512)
    addl %d0,%fp@(-592)
    addl %d0,%fp@(-504)
RGNBLT_2FA:             /* direction and colors */
    movew %fp@(-588),%d3
    movel %fp@(-160),%d4
    movel %fp@(-164),%d5
RGNBLT_306:             /* arithmetic modes: the pixel loop set-up */
    movew %fp@(-582),%fp@(-4)
    btst #5,%d2
    jbeq RGNBLT_3FA
    movel %fp@(-276),%d5
    moveq #0,%d1
    movew %fp@(-212),%d1
    btst #3,%d2
    jbeq RGNBLT_37E
    tstw %fp@(-142)
    jbeq RGNBLT_35E
    moveb #1,%fp@(-624)
    movew %d6,%fp@(-638)
    moveal %fp@(-504),%a0
    addaw %d6,%a0
    movel %a0,%fp@(-504)
    clrw %d6
    swap %d6
    asll #3,%d6
    movel %d6,%fp@(-636)
    movew %d1,%d3
    subqw #1,%d3
    notw %d3
    movew %fp@(-142),%d0
    aslw #3,%d0
    subqw #1,%d0
    andw %d3,%d0
    movew %d0,%fp@(-140)
    jbra RGNBLT_38C
RGNBLT_35E:             /* an 8x8 pattern */
    clrb %fp@(-624)
    lea %fp@(0xffffffffffffff78)@(0x0,%d7:w:4),%a3
    movel %a3,%fp@(-504)
    movew %d7,%fp@(-638)
    moveq #0,%d6
    movel %d6,%fp@(-636)
    movew #31,%fp@(-140)
    jbra RGNBLT_38C
RGNBLT_37E:             /* a source */
    st %fp@(-624)
    movel %d6,%fp@(-636)
    movew #-1,%fp@(-140)
RGNBLT_38C:             /* 16 or 32-bit pixels: steps in pixels */
    cmpiw #16,%d1
    jblt RGNBLT_3A2
    asrl #3,%d6
    movel %d6,%fp@(-636)
    movew %fp@(-140),%d0
    asrw #3,%d0
    movew %d0,%fp@(-140)
RGNBLT_3A2:             /* the op color, pin or transparent color */
    movew %d1,%d7
    andiw #55,%d2
    cmpiw #36,%d2
    jbeq RGNBLT_3B2
    movew %fp@(-270),%d5
RGNBLT_3B2:             /* hilite: the hilite color */
    cmpiw #50,%d2
    jbne RGNBLT_3BE
    bfextu %fp@(-280),0,%d7,%d5
RGNBLT_3BE:             /* pixels per long, direction */
    moveq #5,%d4
    subw %fp@(-118),%d4
    moveq #1,%d0
    lslw %d4,%d0
    movew %d0,%fp@(-646)
    movew %d0,%d2
    moveq #0,%d4
    movel %d7,%d3
    moveq #32,%d1
    tstw %fp@(-588)
    jbpl RGNBLT_3E4
    negl %d3
    negw %d1
    moveq #32,%d4
    subw %d0,%d4
    addl %d4,%d6
RGNBLT_3E4:             /* right to left: start from the end */
    movew %d4,%fp@(-644)
    movew %d1,%fp@(-648)
    movew %fp@(-16),%d0
    addqw #1,%d0
    muluw %d2,%d0
    subqw #1,%d0
    movew %d0,%fp@(-16)
RGNBLT_3FA:             /* start the loop */
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 4082AADC
    moveb %d0,%fp@(-258)
    tstl %fp@(-12)
    jbne RGNBLT_428
RGNBLT_40C:             /* registers for the loop: a3 source/pattern, a5 destination, a4 region runs, d2 longs per row; jump to it */
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 4082AAEC
    moveal %fp@(-504),%a3
    moveal %fp@(-512),%a5
    moveal %fp@(-592),%a4
    movew %fp@(-16),%d2
    moveal %fp@(-536),%a2
    jmp %a2@
RGNBLT_428:             /* region masks expanded to pixels (small-pixel arithmetic) */
    moveal %fp@(-512),%a5
    moveal %fp@(-12),%a4
    movew %fp@(-588),%fp@(-120)
    btst #5,%fp@(-151)
    jbeq RGNBLT_446
    moveaw %fp@(-588),%a4
    movew %fp@(-140),%d4
RGNBLT_446:             /* the row count */
    tstw %fp@(-124)
    jbpl RGNBLT_464
    addqw #1,%fp@(-4)
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 4082AB30
    subqw #1,%fp@(-4)
    jbra RGNBLT_464

RGNBLT_45C:             /* back from a mode loop: the region changes at this row */
    movew %d0,%fp@(-4)
    movel %a3,%fp@(-504)
RGNBLT_464:             /* build the next row's runs (fp-124: next region change) and jump to the loop */
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 4082AB44
    movew %d2,%d1
    jsr %fp@(0xffffffffffffffe8,%za0)@(0)	| 4082AB4C
    movew %fp@(-4),%d0
    movel %fp@(-124),%d2
    moveal %fp@(-504),%a3
    moveal %fp@(-536),%a2
    jmp %a2@
RGNBLT_484:             /* next pattern/source row */
    movel %fp@(-444),%d0
    addl %d0,%fp@(-504)
    jbra RGNBLT_4AA
    movew %fp@(-144),%d6
    swap %d6
    addw %fp@(-142),%d6
    andw %fp@(-138),%d6
    bras RGNBLT_4AA
    addqw #1,%d7
    andiw #15,%d7
    movel %fp@(0xffffffffffffff78)@(0x0,%d7:w:4),%d6	| 4082AB84
RGNBLT_4AA:             /* next destination row; last row: done */
    movel %fp@(-124),%d0
    addl %d0,%fp@(-512)
    movew %fp@(-4),%d0
    addw %fp@(-586),%d0
    movew %d0,%fp@(-4)
    cmpw %fp@(-584),%d0
    jbne RGNBLT_40C
RGNBLT_4C6:             /* done: the stack back */
    moveal %fp@(-600),%sp
    rts

RGNBLT_4CC:             /* arithmetic loops: next row of the pattern or source */
    movew %fp@(-644),%d4
    movel %fp@(-636),%d6
    tstb %fp@(-624)
    jbeq RGNBLT_4F4
    jbmi RGNBLT_484
    moveq #0,%d0
    movew %fp@(-638),%d0
    subal %d0,%a3
    addw %fp@(-142),%d0
    andw %fp@(-138),%d0
    addal %d0,%a3
    movew %d0,%fp@(-638)
    jbra RGNBLT_508
RGNBLT_4F4:             /* an 8x8 pattern: the next of its 16 rows */
    movew %fp@(-638),%d0
    addqw #1,%d0
    andiw #15,%d0
    lea %fp@(0xffffffffffffff78)@(0x0,%d0:w:4),%a3
    movew %d0,%fp@(-638)
RGNBLT_508:             /* store */
    movel %a3,%fp@(-504)
    jbra RGNBLT_4AA
    .short  0x0000	| 4082ABEE
RGNBLT_510:             /* next row (the arithmetic loops' return) */
    movel %a2,%d1
RGNBLT_512:             /* next pattern row */
    movel %fp@(-636),%d6
    tstb %fp@(-624)
    jbeq RGNBLT_536
    jbmi RGNBLT_54C
    moveq #0,%d0
RGNBLT_520:             /* a color pattern: next row (wrapping) */
    movew %fp@(-638),%d0
    subal %d0,%a3
    addw %fp@(-142),%d0
    andw %fp@(-138),%d0
    addal %d0,%a3
    movew %d0,%fp@(-638)
    jbra RGNBLT_550
RGNBLT_536:             /* an 8x8 pattern: next row */
    movew %fp@(-638),%d0
    addqw #1,%d0
    andiw #15,%d0
    lea %fp@(0xffffffffffffff78)@(0x0,%d0:w:4),%a3
    movew %d0,%fp@(-638)
    jbra RGNBLT_550
RGNBLT_54C:             /* a source: next row */
    addal %fp@(-444),%a3
RGNBLT_550:             /* next destination row; done? region change? else back into the loop */
    moveal %fp@(-512),%a5
    addal %fp@(-124),%a5
    movel %a5,%fp@(-512)
    movew %fp@(-4),%d0
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C
    movew %d0,%fp@(-4)
    moveal %fp@(-536),%a2
    jmp %a2@

/* RARITH16TAB: table. */
trap_RARITH16TAB:
RARITH16TAB:
    .short  0x0000, 0x1134	| orib #52,%d0
    .short  0x0000, 0x0944	| orib #68,%d0
    .short  0x0000, 0x07E4	| orib #0xe4,%d0
    .short  0x0000, 0x0C14	| orib #20,%d0
    .short  0x0000, 0x1484	| orib #0x84,%d0
    .short  0x0000, 0x0D84	| orib #0x84,%d0
    .short  0x0000, 0x0AA4	| orib #0xa4,%d0
    .short  0x0000, 0x0EC4	| orib #0xc4,%d0
    .short  0x0000, 0x1014	| orib #20,%d0

/* RARITH32TAB: table. */
trap_RARITH32TAB:
RARITH32TAB:
    .short  0x0000, 0x1076	| orib #118,%d0
    .short  0x0000, 0x08A0	| orib #0xa0,%d0
    .short  0x0000, 0x0770	| orib #112,%d0
    .short  0x0000, 0x0B70	| orib #112,%d0
    .short  0x0000, 0x1430	| orib #48,%d0
    .short  0x0000, 0x0D10	| orib #16,%d0
    .short  0x0000, 0x0A30	| orib #48,%d0
    .short  0x0000, 0x0E50	| orib #80,%d0
    .short  0x0000, 0x0FA0	| orib #0xa0,%d0

/* RHILITETAB: table. */
trap_RHILITETAB:
RHILITETAB:
    .short  0x0000, 0x11EC	| orib #0xec,%d0
    .short  0x0000, 0x11EC	| orib #0xec,%d0
    .short  0x0000, 0x11EC	| orib #0xec,%d0
    .short  0x0000, 0x11EC	| orib #0xec,%d0
    .short  0x0000, 0x12CC	| orib #0xcc,%d0
    .long   0x00000000, 0x00000000	| 4082ACB8

/* RMASK0: RgnBlt (through the region mask), mode srcCopy (and notSrcCopy: the source inverted through d7). */
trap_RMASK0:
RMASK0:
    tstl %d7
    jbne RMASK0_2A
    tstw %d3
    jbmi RMASK0_2A
    negl %d6
    movew %d6,%d4
    andiw #7,%d4
    jbne RMASK0_20
    asrw #3,%d6
    subaw %d6,%a3
    lea %pc@(RMASK0_118),%a2
RMASK0_1A:              /* store the loop's entry (fp-536) and enter it */
    movel %a2,%fp@(-536)
    jmp %a2@
RMASK0_20:              /* unaligned source: the shift and the shifted loop */
    moveq #32,%d3
    subw %d6,%d3
    lea %pc@(RMASK0_AA),%a2
    jbra RMASK0_1A
RMASK0_2A:              /* aligned source: the plain loop */
    lea %pc@(RMASK0_4A),%a2
    jbra RMASK0_1A
RMASK0_30:              /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    addal %fp@(-444),%a3
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C
RMASK0_4A:              /* start of a row: a2 = destination, a1 = its region runs, a0 = source */
    moveal %a5,%a2
    moveal %a4,%a1
    moveal %a3,%a0
RMASK0_50:              /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d2
    jbmi RMASK0_30
    addaw %d2,%a2
    addaw %d2,%a0
    swap %d2
    bclr #14,%d2
    jbeq RMASK0_7C
RMASK0_60:              /* loop: copy; source (bit field, shifted) (inverted for the not modes); through the region mask */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    movel %a1@+,%d5
    andl %d5,%d4
    notl %d5
    andl %a2@,%d5
    orl %d5,%d4
    movel %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RMASK0_60
    jbra RMASK0_50
RMASK0_7C:              /* loop: copy; source (bit field, shifted) (inverted for the not modes) */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    movel %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RMASK0_7C
    jbra RMASK0_50
    .short  0x0000	| 4082AD4E
RMASK0_90:              /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    addal %fp@(-444),%a3
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C
RMASK0_AA:              /* start of a row: a2 = destination, a1 = its region runs, a0 = source */
    moveal %a5,%a2
    moveal %a4,%a1
    moveal %a3,%a0
RMASK0_B0:              /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d2
    jbmi RMASK0_90
    addaw %d2,%a2
    addaw %d2,%a0
    swap %d2
    bclr #14,%d2
    jbeq RMASK0_E2
    movel %a0@(-4),%d5
RMASK0_C4:              /* loop: copy; source (shifted); through the region mask */
    movel %a0@+,%d4
    lsll %d3,%d5
    movel %d4,%d7
    lsrl %d6,%d7
    orl %d5,%d7
    movel %a1@+,%d5
    andl %d5,%d7
    notl %d5
    andl %a2@,%d5
    orl %d5,%d7
    movel %d7,%a2@+
    movel %d4,%d5
    dbf %d2,RMASK0_C4
    jbra RMASK0_B0
RMASK0_E2:              /* aligned source: the previous long for the shift */
    movel %a0@(-4),%d5
RMASK0_E6:              /* loop: copy; source (shifted) */
    movel %a0@+,%d4
    lsll %d3,%d5
    movel %d4,%d7
    lsrl %d6,%d7
    orl %d5,%d7
    movel %d7,%a2@+
    movel %d4,%d5
    dbf %d2,RMASK0_E6
    jbra RMASK0_B0
    .short  0x0000, 0x0000, 0x0000	| 4082ADBA
RMASK0_100:             /* next row; last row: done; region change: back to RGNBLT */
    addal %d2,%a5
    addal %fp@(-444),%a3
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C
RMASK0_118:             /* start of a row: a2 = destination, a1 = its region runs, a0 = source */
    moveal %a5,%a2
    moveal %a4,%a1
    moveal %a3,%a0
RMASK0_11E:             /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d3
    jbmi RMASK0_100
    addaw %d3,%a2
    addaw %d3,%a0
    swap %d3
    bclr #14,%d3
    jbeq RMASK0_142
RMASK0_12E:             /* loop: copy; source; through the region mask */
    movel %a0@+,%d4
    movel %a1@+,%d5
    andl %d5,%d4
    notl %d5
    andl %a2@,%d5
    orl %d4,%d5
    movel %d5,%a2@+
    dbf %d3,RMASK0_12E
    jbra RMASK0_11E
RMASK0_142:             /* full longs: jump into the 16-long unrolled copy */
    moveq #15,%d4
    andw %d3,%d4
    negw %d4
    lsrw #4,%d3
    jmp %pc@(RMASK0_16E:w,%d4:w:2)	| 4082AE0A
RMASK0_150:             /* unrolled copy, 16 longs per pass */
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
RMASK0_16E:             /* loop: transfer; source */
    movel %a0@+,%a2@+
    dbf %d3,RMASK0_150
    jbra RMASK0_11E
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082AE36
RMASK0_180:             /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    addal %fp@(-444),%a3
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RMASK1: RgnBlt (through the region mask), mode srcOr / notSrcOr. */
trap_RMASK1:
RMASK1:
    moveal %a5,%a2
    moveal %a4,%a1
    moveal %a3,%a0
RMASK1_6:               /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d2
    jbmi RMASK0_180
    addaw %d2,%a2
    addaw %d2,%a0
    swap %d2
    bclr #14,%d2
    jbeq RMASK1_2A
RMASK1_16:              /* loop: or; source (bit field, shifted) (inverted for the not modes); through the region mask */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    andl %a1@+,%d4
    orl %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RMASK1_16
    jbra RMASK1_6
RMASK1_2A:              /* loop: or; source (bit field, shifted) (inverted for the not modes) */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    orl %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RMASK1_2A
    jbra RMASK1_6
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082AE96
RMASK1_46:              /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    addal %fp@(-444),%a3
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RMASK2: RgnBlt (through the region mask), mode srcXor / notSrcXor. */
trap_RMASK2:
RMASK2:
    moveal %a5,%a2
    moveal %a4,%a1
    moveal %a3,%a0
RMASK2_6:               /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d2
    jbmi RMASK1_46
    addaw %d2,%a2
    addaw %d2,%a0
    swap %d2
    bclr #14,%d2
    jbeq RMASK2_2A
RMASK2_16:              /* loop: xor; source (bit field, shifted) (inverted for the not modes); through the region mask */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    andl %a1@+,%d4
    eorl %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RMASK2_16
    jbra RMASK2_6
RMASK2_2A:              /* loop: xor; source (bit field, shifted) (inverted for the not modes) */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    eorl %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RMASK2_2A
    jbra RMASK2_6
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082AEF6
RMASK2_46:              /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    addal %fp@(-444),%a3
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RMASK3: RgnBlt (through the region mask), mode srcBic / notSrcBic. */
trap_RMASK3:
RMASK3:
    moveal %a5,%a2
    moveal %a4,%a1
    moveal %a3,%a0
RMASK3_6:               /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d2
    jbmi RMASK2_46
    addaw %d2,%a2
    addaw %d2,%a0
    swap %d2
    bclr #14,%d2
    jbeq RMASK3_2C
RMASK3_16:              /* loop: bic (clear where set); source (bit field, shifted) (inverted for the not modes); through the region mask */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    andl %a1@+,%d4
    notl %d4
    andl %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RMASK3_16
    jbra RMASK3_6
RMASK3_2C:              /* loop: bic (clear where set); source (bit field, shifted) (inverted for the not modes) */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    notl %d4
    andl %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RMASK3_2C
    jbra RMASK3_6
    .short  0x0000, 0x0000, 0x0000	| 4082AF5A

/* RCMASK0: RgnBlt (through the region mask), mode srcCopy colorized: source 1s take the foreground color, 0s the background. */
trap_RCMASK0:
RCMASK0:
    swap %d0
    movew %d1,%d0
    moveaw %fp@(-588),%a4
    jbra RCMASK0_2A
RCMASK0_A:              /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    addal %fp@(-444),%a3
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    swap %d0
    subqw #1,%d0
    jbgt RCMASK0_2A
    swap %d0
    jbra RGNBLT_45C
RCMASK0_2A:             /* start of a row: destination, region runs, source */
    swap %d0
    moveal %a5,%a2
    moveal %fp@(-12),%a1
    moveal %a3,%a0
RCMASK0_34:             /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d2
    jbmi RCMASK0_A
    addaw %d2,%a2
    addaw %d2,%a0
    swap %d2
    bclr #14,%d2
    jbeq RCMASK0_6A
RCMASK0_44:             /* loop: copy; source (bit field, shifted) (inverted for the not modes); through the region mask */
    bfextu %a0@,%d6,0,%d3
    addaw %a4,%a0
    eorl %d7,%d3
    movel %d3,%d1
    notl %d3
    andl %d5,%d3
    andl %d4,%d1
    orl %d1,%d3
    movel %a1@+,%d1
    andl %d1,%d3
    notl %d1
    andl %a2@,%d1
    orl %d1,%d3
    movel %d3,%a2@
    addaw %a4,%a2
    dbf %d2,RCMASK0_44
    jbra RCMASK0_34
RCMASK0_6A:             /* loop: copy; source (bit field, shifted) (inverted for the not modes) */
    bfextu %a0@,%d6,0,%d3
    addaw %a4,%a0
    eorl %d7,%d3
    movel %d3,%d1
    notl %d3
    andl %d5,%d3
    andl %d4,%d1
    orl %d1,%d3
    movel %d3,%a2@
    addaw %a4,%a2
    dbf %d2,RCMASK0_6A
    jbra RCMASK0_34
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082AFE6
RCMASK0_90:             /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    addal %fp@(-444),%a3
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RCMASK1: RgnBlt (through the region mask), mode srcOr colorized: source 1s become the foreground color. */
trap_RCMASK1:
RCMASK1:
    moveal %a5,%a2
    moveal %a4,%a1
    moveal %a3,%a0
RCMASK1_6:              /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d2
    jbmi RCMASK0_90
    addaw %d2,%a2
    addaw %d2,%a0
    swap %d2
    bclr #14,%d2
    jbeq RCMASK1_32
RCMASK1_16:             /* loop: or; source (bit field, shifted) (inverted for the not modes); through the region mask */
    bfextu %a0@,%d6,0,%d5
    addaw %d3,%a0
    eorl %d7,%d5
    andl %a1@+,%d5
    notl %d5
    andl %d5,%a2@
    notl %d5
    andl %d4,%d5
    orl %d5,%a2@
    addaw %d3,%a2
    dbf %d2,RCMASK1_16
    jbra RCMASK1_6
RCMASK1_32:             /* loop: or; source (bit field, shifted) (inverted for the not modes) */
    bfextu %a0@,%d6,0,%d5
    addaw %d3,%a0
    eorl %d7,%d5
    notl %d5
    andl %d5,%a2@
    notl %d5
    andl %d4,%d5
    orl %d5,%a2@
    addaw %d3,%a2
    dbf %d2,RCMASK1_32
    jbra RCMASK1_6
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082B056
RCMASK1_56:             /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    addal %fp@(-444),%a3
    addw %fp@(-586),%d0
    cmpw %fp@(-584),%d0
    jbeq RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RCMASK3: RgnBlt (through the region mask), mode srcBic colorized: source 1s become the background color. */
trap_RCMASK3:
RCMASK3:
    moveal %a5,%a2
    moveal %a4,%a1
    moveal %a3,%a0
RCMASK3_6:              /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d2
    jbmi RCMASK1_56
    addaw %d2,%a2
    addaw %d2,%a0
    swap %d2
    bclr #14,%d2
    jbeq RCMASK3_32
RCMASK3_16:             /* loop: or; source (bit field, shifted) (inverted for the not modes); through the region mask */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    andl %a1@+,%d4
    notl %d4
    andl %d4,%a2@
    notl %d4
    andl %d5,%d4
    orl %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RCMASK3_16
    jbra RCMASK3_6
RCMASK3_32:             /* loop: or; source (bit field, shifted) (inverted for the not modes) */
    bfextu %a0@,%d6,0,%d4
    addaw %d3,%a0
    eorl %d7,%d4
    notl %d4
    andl %d4,%a2@
    notl %d4
    andl %d5,%d4
    orl %d4,%a2@
    addaw %d3,%a2
    dbf %d2,RCMASK3_32
    jbra RCMASK3_6
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082B0C6
RCMASK3_56:             /* next row; last row: done; region change: back to RGNBLT */
    addqw #1,%d7
    andiw #15,%d7
    movel %a3@(0x0,%d7:w:4),%d6
    addal %d2,%a5
    addqw #1,%d0
    cmpw %fp@(-584),%d0
    jbge RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RMASK8: RgnBlt (through the region mask), mode patCopy (and notPatCopy). */
trap_RMASK8:
RMASK8:
    moveal %a5,%a2
    moveal %a4,%a1
RMASK8_4:               /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d3
    jbmi RCMASK3_56
    addaw %d3,%a2
    swap %d3
    bclr #14,%d3
    jbeq RMASK8_26
RMASK8_12:              /* loop: copy; through the region mask */
    movel %d6,%d5
    movel %a1@+,%d4
    andl %d4,%d5
    notl %d4
    andl %a2@,%d4
    orl %d4,%d5
    movel %d5,%a2@+
    dbf %d3,RMASK8_12
    jbra RMASK8_4
RMASK8_26:              /* full longs: jump into the 16-long unrolled fill */
    moveq #15,%d4
    andw %d3,%d4
    negw %d4
    lsrw #4,%d3
    jmp %pc@(RMASK8_52:w,%d4:w:2)	| 4082B11A
RMASK8_34:              /* unrolled fill with the pattern long */
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
    movel %d6,%a2@+
RMASK8_52:              /* next 16; next run */
    movel %d6,%a2@+
    dbf %d3,RMASK8_34
    jbra RMASK8_4
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082B146
RMASK8_64:              /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    addqw #1,%d7
    andiw #15,%d7
    movel %a3@(0x0,%d7:w:4),%d6
    addal %fp@(-124),%a5
    addqw #1,%d0
    cmpw %fp@(-584),%d0
    jbge RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RMASK9: RgnBlt (through the region mask), mode patOr. */
trap_RMASK9:
RMASK9:
    moveal %a5,%a2
    moveal %a4,%a1
    movel %fp@(-160),%d2
RMASK9_8:               /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d3
    jbmi RMASK8_64
    addaw %d3,%a2
    swap %d3
    bclr #14,%d3
    jbeq RMASK9_2C
RMASK9_16:              /* loop: pattern or: where pattern and region mask are set, the foreground color d2 */
    movel %d6,%d5
    andl %a1@+,%d5
    movel %d5,%d4
    notl %d4
    andl %a2@,%d4
    andl %d2,%d5
    orl %d5,%d4
    movel %d4,%a2@+
    dbf %d3,RMASK9_16
    jbra RMASK9_8
RMASK9_2C:              /* patOr: the mask and its inverse */
    movel %d6,%d5
    notl %d5
    andl %d2,%d6
RMASK9_32:              /* each long: or the pattern through the mask */
    movel %d5,%d4
    andl %a2@,%d4
    orl %d6,%d4
    movel %d4,%a2@+
    dbf %d3,RMASK9_32
    movel %d5,%d6
    notl %d6
    jbra RMASK9_8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082B1B2
RMASK9_52:              /* next row; last row: done; region change: back to RGNBLT */
    addqw #1,%d7
    andiw #15,%d7
    movel %a3@(0x0,%d7:w:4),%d6
    addal %d2,%a5
    addqw #1,%d0
    cmpw %fp@(-584),%d0
    jbge RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RMASK10: RgnBlt (through the region mask), mode patXor. */
trap_RMASK10:
RMASK10:
    moveal %a5,%a2
    moveal %a4,%a1
RMASK10_4:              /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d3
    jbmi RMASK9_52
    addaw %d3,%a2
    swap %d3
    bclr #14,%d3
    jbeq RMASK10_1E
RMASK10_12:             /* loop: xor; through the region mask */
    movel %d6,%d5
    andl %a1@+,%d5
    eorl %d5,%a2@+
    dbf %d3,RMASK10_12
    jbra RMASK10_4
RMASK10_1E:             /* patXor: jump into the unrolled loop */
    moveq #15,%d4
    andw %d3,%d4
    negw %d4
    lsrw #4,%d3
    jmp %pc@(RMASK10_4A:w,%d4:w:2)	| 4082B202
RMASK10_2C:             /* unrolled xor with the pattern long */
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
    eorl %d6,%a2@+
RMASK10_4A:             /* next 16; next run */
    eorl %d6,%a2@+
    dbf %d3,RMASK10_2C
    jbra RMASK10_4

/* RMASK11: RgnBlt (through the region mask), mode patBic. */
trap_RMASK11:
RMASK11:
    movel %fp@(-164),%fp@(-160)
    lea %pc@(trap_RMASK9),%a2
    movel %a2,%fp@(-536)
    jmp %a2@
    .short  0x0000	| 4082B23E
RMASK11_12:             /* next row; last row: done; region change: back to RGNBLT */
    movew %fp@(-144),%d6
    swap %d6
    addw %fp@(-142),%d6
    andw %fp@(-138),%d6
    addal %d2,%a5
    addqw #1,%d0
    cmpw %fp@(-584),%d0
    jbge RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RXMASK8: RgnBlt (through the region mask), mode patCopy with a color (multi-long) pattern. */
trap_RXMASK8:
RXMASK8:
    moveal %a5,%a2
    moveal %a3,%a0
    addaw %d6,%a0
    swap %d6
    moveal %a4,%a1
RXMASK8_A:              /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d3
    jbmi RMASK11_12
    addaw %d3,%a2
    addw %d3,%d6
    andw %d7,%d6
    swap %d3
    bclr #14,%d3
    jbeq RXMASK8_36
RXMASK8_1C:             /* loop: copy; through the region mask */
    movel %a0@(0x0,%d6:w),%d5
    addqw #4,%d6
    andw %d7,%d6
    movel %a1@+,%d4
    andl %d4,%d5
    notl %d4
    andl %a2@,%d4
    orl %d4,%d5
    movel %d5,%a2@+
    dbf %d3,RXMASK8_1C
    jbra RXMASK8_A
RXMASK8_36:             /* color pattern copy: each long from the pattern row */
    movel %a0@(0x0,%d6:w),%a2@+
    addqw #4,%d6
    andw %d7,%d6
    dbf %d3,RXMASK8_36
    jbra RXMASK8_A
    .long   0x00000000, 0x00000000, 0x00000000	| 4082B2A4
RXMASK8_50:             /* next row: advance destination and source; last row: done; region change: back to RGNBLT */
    movew %fp@(-144),%d6
    swap %d6
    addw %fp@(-142),%d6
    andw %fp@(-138),%d6
    addal %fp@(-124),%a5
    addqw #1,%d0
    cmpw %fp@(-584),%d0
    jbge RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RXMASK9: RgnBlt (through the region mask), mode patOr, color pattern. */
trap_RXMASK9:
RXMASK9:
    movel %fp@(-160),%d2
    moveal %a5,%a2
    moveal %a3,%a0
    addaw %d6,%a0
    swap %d6
    moveal %a4,%a1
RXMASK9_E:              /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d3
    jbmi RXMASK8_50
    addaw %d3,%a2
    addw %d3,%d6
    andw %d7,%d6
    swap %d3
    bclr #14,%d3
    jbeq RXMASK9_3C
RXMASK9_20:             /* loop: color pattern or through the region mask */
    movel %a0@(0x0,%d6:w),%d5
    addqw #4,%d6
    andw %d7,%d6
    andl %a1@+,%d5
    movel %d5,%d4
    notl %d4
    andl %a2@,%d4
    andl %d2,%d5
    orl %d4,%d5
    movel %d5,%a2@+
    dbf %d3,RXMASK9_20
    jbra RXMASK9_E
RXMASK9_3C:             /* color pattern or, no region mask */
    movel %a0@(0x0,%d6:w),%d5
    movel %d5,%d4
    notl %d4
    andl %d2,%d5
    andl %a2@,%d4
    addqw #4,%d6
    andw %d7,%d6
    orl %d4,%d5
    movel %d5,%a2@+
    dbf %d3,RXMASK9_3C
    jbra RXMASK9_E
    .long   0x00000000, 0x00000000	| 4082B328
RXMASK9_5E:             /* next row; last row: done; region change: back to RGNBLT */
    movew %fp@(-144),%d6
    swap %d6
    addw %fp@(-142),%d6
    andw %fp@(-138),%d6
    addal %d2,%a5
    addqw #1,%d0
    cmpw %fp@(-584),%d0
    jbge RGNBLT_4C6
    subqw #1,%d1
    jble RGNBLT_45C

/* RXMASK10: RgnBlt (through the region mask), mode patXor, color pattern. */
trap_RXMASK10:
RXMASK10:
    moveal %a5,%a2
    moveal %a3,%a0
    addaw %d6,%a0
    swap %d6
    moveal %a4,%a1
RXMASK10_A:             /* next run of the row: offset (low word), long count (high word), bit 14 masked; negative: end of row */
    movel %a1@+,%d3
    jbmi RXMASK9_5E
    addaw %d3,%a2
    addw %d3,%d6
    andw %d7,%d6
    swap %d3
    bclr #14,%d3
    jbeq RXMASK10_2E
RXMASK10_1C:            /* loop: xor; through the region mask */
    movel %a0@(0x0,%d6:w),%d5
    andl %a1@+,%d5
    addqw #4,%d6
    andw %d7,%d6
    eorl %d5,%a2@+
    dbf %d3,RXMASK10_1C
    jbra RXMASK10_A
RXMASK10_2E:            /* color pattern xor */
    movel %a0@(0x0,%d6:w),%d5
    addqw #4,%d6
    andw %d7,%d6
    eorl %d5,%a2@+
    dbf %d3,RXMASK10_2E
    jbra RXMASK10_A
    .short  0x0000	| 4082B38E

/* RXMASK11: RgnBlt (through the region mask), mode patBic, color pattern. */
trap_RXMASK11:
RXMASK11:
    movel %fp@(-164),%fp@(-160)
    lea %pc@(trap_RXMASK9),%a2
    movel %a2,%fp@(-536)
    jmp %a2@

/* RADDOVER: arithmetic transfer mode addover (RgnBlt). */
trap_RADDOVER:
RADDOVER:
    moveal %fp@(-264),%a0
    movew %fp@(-140),%d1
RADDOVER_8:             /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %d1,%d6
    bfextu %a4@,%d4,%d7,%d0
    jbeq RADDOVER_40
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a2
    bfextu %a5@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a1
    movew %a2@+,%d0
    addw %a1@+,%d0
    asll %d5,%d0
    movew %a2@+,%d0
    addw %a1@+,%d0
    asll %d5,%d0
    movew %a2@+,%d0
    addw %a1@+,%d0
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a5@,%d4,%d7
RADDOVER_40:            /* next pixel; end of the run: next row (RGNBLT_4CC) */
    addl %d3,%d6
    addl %d3,%d4
    dbf %d2,RADDOVER_8
    jbra RGNBLT_4CC
    .byte   0x00, 0x00, 0x00, 0x00	| 4082B3EC
    /* RAddOver, 32-bit direct pixels: run list (fp-12), masks 0x7F7F7F and 0x808080 */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    movel #8355711,%d0
    moveal #8421504,%a2
RADDOVER_62:            /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %fp@(-140),%d6
    swap %d2
RADDOVER_72:            /* 32-bit pixels, one per long: add, wrapping */
    movel %a0@(0x0,%d6:w),%d7
    movel %a2,%d4
    andl %d7,%d4
    andl %d0,%d7
    movel %a5@,%d5
    movel %a2,%d3
    andl %d5,%d3
    andl %d0,%d5
    addl %d7,%d5
    eorl %d4,%d3
    eorl %d3,%d5
    movel %d5,%a5@
    addaw %a4,%a5
    addw %a4,%d6
    andw %fp@(-140),%d6
    dbf %d2,RADDOVER_72
    jbra RADDOVER_62
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082B43A
    /* RAddOver, 16-bit direct pixels: run list (fp-12), masks 0x3DEF and 0x4210 */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    movew #15855,%d0
    moveaw #16912,%a2
RADDOVER_AE:            /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %fp@(-140),%d6
    swap %d2
    bclr #14,%d2
    jbeq RADDOVER_108
RADDOVER_C4:            /* a masked run: this pixel inside the region? */
    tstl %a1@+
    jbmi RADDOVER_DC
    addqw #2,%a5
    addqw #2,%d6
    jbsr RADDOVER_EC
    addqw #2,%a5
    addqw #2,%d6
    andw %fp@(-140),%d6
    dbf %d2,RADDOVER_C4
    jbra RADDOVER_AE
RADDOVER_DC:            /* 32-bit masked run: each pixel inside the mask (RADDOVER_EC) */
    jbsr RADDOVER_EC
    addqw #4,%a5
    addqw #4,%d6
    andw %fp@(-140),%d6
    dbf %d2,RADDOVER_C4
    jbra RADDOVER_AE

RADDOVER_EC:            /* 16-bit pixel: add, wrapping */
    movew %a0@(0x0,%d6:w),%d7
    movew %a2,%d4
    andw %d7,%d4
    andw %d0,%d7
    movew %a5@,%d5
    movew %a2,%d3
    andw %d5,%d3
    andw %d0,%d5
    addw %d7,%d5
    eorw %d4,%d3
    eorw %d3,%d5
    movew %d5,%a5@
    rts
RADDOVER_108:           /* 16-bit masked run: two pixels per long */
    jbsr RADDOVER_EC
    addqw #2,%a5
    addqw #2,%d6
    jbsr RADDOVER_EC
    addqw #2,%a5
    addqw #2,%d6
    andw %fp@(-140),%d6
    dbf %d2,RADDOVER_108
    jbra RADDOVER_AE
    .short  0x0000	| 4082B4BE

/* RADDPIN: arithmetic transfer mode addpin (RgnBlt). */
trap_RADDPIN:
RADDPIN:
    moveal %fp@(-264),%a0
RADDPIN_4:              /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %a4@,%d4,%d7,%d0
    jbeq RADDPIN_48
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a2
    bfextu %a5@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a1
    moveq #2,%d1
RADDPIN_20:             /* each of R, G, B: add, pinned at the pin color */
    movew %a2@+,%d0
    addw %a1@+,%d0
    jbcs RADDPIN_2E
    cmpw %fp@(0xffffffffffffff06,%d1:w:2),%d0
    jbls RADDPIN_34
RADDPIN_2E:             /* pin the component */
    movew %fp@(0xffffffffffffff06,%d1:w:2),%d0
RADDPIN_34:             /* pack the component into the inverse table index */
    asll %d5,%d0
    dbf %d1,RADDPIN_20
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a5@,%d4,%d7
RADDPIN_48:             /* next pixel; end of the run: next row (RGNBLT_4CC) */
    addl %d3,%d6
    addl %d3,%d4
    dbf %d2,RADDPIN_4
    jbra RGNBLT_4CC
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082B514
    /* RAddPin, 32-bit direct pixels: the loop entry into fp-536, the pin value from fp-248/fp-246 into d3 */
    lea %pc@(RADDPIN_48+0x30),%a0
    movel %a0,%fp@(-536)
    moveq #0,%d3
    moveb %fp@(-246),%d3
    swap %d3
    movew %fp@(-248),%d3
    moveb %fp@(-250),%d3
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    moveal %d1,%a2
    movel Lo3Bytes,%d1
RADDPIN_84:             /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_510
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
RADDPIN_92:             /* 32-bit pixels, one per long: add, pinned at the pin color */
    movel %a0@(0x0,%d6:w),%d7
    addw %a4,%d6
    andw %d4,%d6
    andl %d1,%d7
    movel %d7,%d0
    movel %a5@,%d5
    andl %d1,%d5
    clrb %d0
    addw %d5,%d0
    jbcs RADDPIN_AC
    cmpw %d3,%d0
    jbls RADDPIN_AE
RADDPIN_AC:             /* pinned */
    movew %d3,%d0
RADDPIN_AE:             /* next component */
    moveb %d7,%d0
    addb %d5,%d0
    jbcs RADDPIN_B8
    cmpb %d3,%d0
    jbls RADDPIN_BA
RADDPIN_B8:             /* pinned */
    moveb %d3,%d0
RADDPIN_BA:             /* combine the components */
    clrw %d5
    addl %d5,%d0
    cmpl %d3,%d0
    jbls RADDPIN_CC
    swap %d3
    swap %d0
    movew %d3,%d0
    swap %d0
    swap %d3
RADDPIN_CC:             /* store the pixel */
    movel %d0,%a5@
    addaw %a4,%a5
    dbf %d2,RADDPIN_92
    jbra RADDPIN_84
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082B596
    /* RAddPin, 16-bit direct pixels: the same, the pin components cut to 5 bits */
    lea %pc@(RADDPIN_CC+0x32),%a0
    movel %a0,%fp@(-536)
    moveq #0,%d3
    moveb %fp@(-246),%d3
    lsrb #3,%d3
    swap %d3
    movew %fp@(-248),%d3
    lsrw #3,%d3
    moveb %fp@(-250),%d3
    lsrb #3,%d3
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    movew #15855,%d0
    moveaw #16912,%a2
RADDPIN_10C:            /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %fp@(-140),%d6
    swap %d2
    bclr #14,%d2
    jbeq RADDPIN_184
RADDPIN_122:            /* a masked run: this pixel inside the region? */
    tstl %a1@+
    jbmi RADDPIN_138
    addqw #2,%a5
    addqw #2,%d6
    jbsr RADDPIN_146
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RADDPIN_122
    jbra RADDPIN_10C
RADDPIN_138:            /* 32-bit masked run: each pixel (RADDPIN_146) */
    jbsr RADDPIN_146
    addqw #4,%a5
    addqw #4,%d6
    andw %d4,%d6
    dbf %d2,RADDPIN_122
    jbra RADDPIN_10C

RADDPIN_146:            /* one 16-bit pixel: unpack the 5-bit components, add, pin, repack */
    moveq #0,%d7
    movew %a0@(0x0,%d6:w),%d7
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    moveq #0,%d5
    movew %a5@,%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    addl %d5,%d7
    movel %d7,%d0
    cmpl %d3,%d0
    jbls RADDPIN_16A
    movel %d3,%d0
RADDPIN_16A:            /* next component */
    movew %d7,%d0
    cmpw %d3,%d0
    jbls RADDPIN_172
    movew %d3,%d0
RADDPIN_172:            /* next component */
    moveb %d7,%d0
    cmpb %d3,%d0
    jbls RADDPIN_17A
    moveb %d3,%d0
RADDPIN_17A:            /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a5@
    rts
RADDPIN_184:            /* 16-bit masked run: two pixels per long */
    jbsr RADDPIN_146
    addqw #2,%a5
    addqw #2,%d6
    jbsr RADDPIN_146
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RADDPIN_184
    jbra RADDPIN_10C
    .short  0x0000, 0x0000, 0x0000	| 4082B65A

/* RSUBOVER: arithmetic transfer mode subover (RgnBlt). */
trap_RSUBOVER:
RSUBOVER:
    moveal %fp@(-264),%a0
    movew %fp@(-140),%d1
RSUBOVER_8:             /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %d1,%d6
    bfextu %a4@,%d4,%d7,%d0
    jbeq RSUBOVER_40
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a2
    bfextu %a5@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a1
    movew %a1@+,%d0
    subw %a2@+,%d0
    asll %d5,%d0
    movew %a1@+,%d0
    subw %a2@+,%d0
    asll %d5,%d0
    movew %a1@+,%d0
    subw %a2@+,%d0
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a5@,%d4,%d7
RSUBOVER_40:            /* next pixel; end of the run: next row (RGNBLT_4CC) */
    addl %d3,%d6
    addl %d3,%d4
    dbf %d2,RSUBOVER_8
    jbra RGNBLT_4CC
    .byte   0x00, 0x00, 0x00, 0x00	| 4082B6AC
    /* RSubOver, 32-bit direct pixels: run list, masks 0x7F7F7F and 0x808080 (d1 kept in a2) */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    moveal %d1,%a2
    movel #8355711,%d0
    movel #8421504,%d1
RSUBOVER_64:            /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_510
    addaw %d2,%a5
    addw %d2,%d6
    andw %fp@(-140),%d6
    swap %d2
RSUBOVER_74:            /* 32-bit pixels, one per long: subtract, wrapping */
    movel %a0@(0x0,%d6:w),%d7
    movel %d1,%d3
    andl %d7,%d3
    eorl %d1,%d3
    andl %d0,%d7
    movel %a5@,%d5
    movel %d1,%d4
    andl %d5,%d4
    andl %d0,%d5
    orl %d1,%d5
    subl %d7,%d5
    eorl %d3,%d4
    eorl %d4,%d5
    movel %d5,%a5@
    addaw %a4,%a5
    addw %a4,%d6
    andw %fp@(-140),%d6
    dbf %d2,RSUBOVER_74
    jbra RSUBOVER_64
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    moveal %d1,%a2
    movew #15855,%d0
    movew #16912,%d1
RSUBOVER_74_3C:         /* 16-bit subOver: next run of the row (masks 0x3DEF / 0x4210 keep the 5-bit components apart); end of row: next row */
    movel %a1@+,%d2
    bmiw RGNBLT_510
    addaw %d2,%a5
    addw %d2,%d6
    andw %fp@(-140),%d6
    swap %d2
    bclr #14,%d2
    beqs RSUBOVER_74_9A
RSUBOVER_74_52:         /* a masked run: two pixels per long, each inside the region mask? */
    tstl %a1@+
    bmis RSUBOVER_74_6A
    addqw #2,%a5
    addqw #2,%d6
    bsrs RSUBOVER_74_7A
    addqw #2,%a5
    addqw #2,%d6
    andw %fp@(-140),%d6
    dbf %d2,RSUBOVER_74_52
    bras RSUBOVER_74_3C
RSUBOVER_74_6A:         /* one pixel; next long */
    bsrs RSUBOVER_74_7A
    addqw #4,%a5
    addqw #4,%d6
    andw %fp@(-140),%d6
    dbf %d2,RSUBOVER_74_52
    bras RSUBOVER_74_3C
RSUBOVER_74_7A:         /* one 16-bit pixel: subtract each component, borrows dropped */
    movew %d1,%d3
    movew %a0@(0x0,%d6:w),%d7
    andw %d7,%d3
    eorw %d1,%d3
    andw %d0,%d7
    movew %a5@,%d5
    movew %d1,%d4
    andw %d5,%d4
    andw %d0,%d5
    orw %d1,%d5
    subw %d7,%d5
    eorw %d3,%d4
    eorw %d4,%d5
    movew %d5,%a5@
    rts
RSUBOVER_74_9A:         /* an unmasked run: two pixels per long */
    bsrs RSUBOVER_74_7A
    addqw #2,%a5
    addqw #2,%d6
    bsrs RSUBOVER_74_7A
    addqw #2,%a5
    addqw #2,%d6
    andw %fp@(-140),%d6
    dbf %d2,RSUBOVER_74_9A
    bras RSUBOVER_74_3C
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082B784

/* RSUBPIN: arithmetic transfer mode subpin (RgnBlt). */
trap_RSUBPIN:
RSUBPIN:
    moveal %fp@(-264),%a0
RSUBPIN_4:              /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %a4@,%d4,%d7,%d0
    jbeq RSUBPIN_48
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a2
    bfextu %a5@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a1
    moveq #2,%d1
RSUBPIN_20:             /* each of R, G, B: subtract, pinned at the pin color */
    movew %a1@+,%d0
    subw %a2@+,%d0
    jbcs RSUBPIN_2E
    cmpw %fp@(0xffffffffffffff06,%d1:w:2),%d0
    jbcc RSUBPIN_34
RSUBPIN_2E:             /* pin the component */
    movew %fp@(0xffffffffffffff06,%d1:w:2),%d0
RSUBPIN_34:             /* pack the component into the inverse table index */
    asll %d5,%d0
    dbf %d1,RSUBPIN_20
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a5@,%d4,%d7
RSUBPIN_48:             /* next pixel; end of the run: next row (RGNBLT_4CC) */
    addl %d3,%d6
    addl %d3,%d4
    dbf %d2,RSUBPIN_4
    jbra RGNBLT_4CC
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082B7E4
    /* RSubPin, 32-bit direct pixels: the loop entry into fp-536, the pin value into d3 */
    lea %pc@(RSUBPIN_48+0x30),%a0
    movel %a0,%fp@(-536)
    moveq #0,%d3
    moveb %fp@(-246),%d3
    swap %d3
    movew %fp@(-248),%d3
    moveb %fp@(-250),%d3
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    moveal %d1,%a2
    movel Lo3Bytes,%d1
RSUBPIN_84:             /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_510
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
RSUBPIN_92:             /* 32-bit pixels, one per long: subtract, pinned */
    movel %a0@(0x0,%d6:w),%d5
    addw %a4,%d6
    andw %d4,%d6
    andl %d1,%d5
    movel %a5@,%d7
    andl %d1,%d7
    movel %d7,%d0
    st %d0
    subw %d5,%d0
    jbcs RSUBPIN_AC
    cmpw %d3,%d0
    jbcc RSUBPIN_AE
RSUBPIN_AC:             /* pinned */
    movew %d3,%d0
RSUBPIN_AE:             /* next component */
    moveb %d7,%d0
    subb %d5,%d0
    jbcs RSUBPIN_B8
    cmpb %d3,%d0
    jbcc RSUBPIN_BA
RSUBPIN_B8:             /* pinned */
    moveb %d3,%d0
RSUBPIN_BA:             /* combine the components */
    clrw %d5
    subl %d5,%d0
    cmpl %d3,%d0
    jbge RSUBPIN_CC
    swap %d3
    swap %d0
    movew %d3,%d0
    swap %d0
    swap %d3
RSUBPIN_CC:             /* store the pixel */
    movel %d0,%a5@
    addaw %a4,%a5
    dbf %d2,RSUBPIN_92
    jbra RSUBPIN_84
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082B866
    /* RSubPin, 16-bit direct pixels: the same, the pin components cut to 5 bits */
    lea %pc@(RSUBPIN_CC+0x38),%a0
    movel %a0,%fp@(-536)
    moveq #0,%d3
    moveb %fp@(-246),%d3
    lsrb #3,%d3
    swap %d3
    movew %fp@(-248),%d3
    lsrw #3,%d3
    moveb %fp@(-250),%d3
    lsrb #3,%d3
    addil #8421504,%d3
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    moveal %d1,%a2
    movel #8421504,%d1
RSUBPIN_112:            /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_510
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
    bclr #14,%d2
    jbeq RSUBPIN_18A
RSUBPIN_126:            /* a masked run: this pixel inside the region? */
    tstl %a1@+
    jbmi RSUBPIN_13C
    addqw #2,%a5
    addqw #2,%d6
    jbsr RSUBPIN_14A
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RSUBPIN_126
    jbra RSUBPIN_112
RSUBPIN_13C:            /* 32-bit masked run: each pixel */
    jbsr RSUBPIN_14A
    addqw #4,%a5
    addqw #4,%d6
    andw %d4,%d6
    dbf %d2,RSUBPIN_126
    jbra RSUBPIN_112

RSUBPIN_14A:            /* one 16-bit pixel: unpack the 5-bit components, subtract, pin, repack */
    moveq #0,%d5
    movew %a0@(0x0,%d6:w),%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    moveq #0,%d7
    movew %a5@,%d7
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    addl %d1,%d7
    subl %d5,%d7
    movel %d7,%d0
    cmpl %d3,%d0
    jbcc RSUBPIN_170
    movel %d3,%d0
RSUBPIN_170:            /* next component */
    movew %d7,%d0
    cmpw %d3,%d0
    jbcc RSUBPIN_178
    movew %d3,%d0
RSUBPIN_178:            /* next component */
    moveb %d7,%d0
    cmpb %d3,%d0
    jbcc RSUBPIN_180
    moveb %d3,%d0
RSUBPIN_180:            /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a5@
    rts
RSUBPIN_18A:            /* 16-bit masked run: two pixels per long */
    jbsr RSUBPIN_14A
    addqw #2,%a5
    addqw #2,%d6
    jbsr RSUBPIN_14A
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RSUBPIN_18A
    jbra RSUBPIN_112

/* RMAX: arithmetic transfer mode max (RgnBlt). */
trap_RMAX:
RMAX:
    moveal %fp@(-264),%a0
    movew %fp@(-140),%d1
RMAX_8:                 /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %d1,%d6
    bfextu %a4@,%d4,%d7,%d0
    jbeq RMAX_50
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a2
    bfextu %a5@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a1
    movew %a2@+,%d0
    cmpw %a1@,%d0
    jbcc RMAX_28
    movew %a1@,%d0
RMAX_28:                /* next component */
    addqw #2,%a1
    asll %d5,%d0
    movew %a2@+,%d0
    cmpw %a1@,%d0
    jbcc RMAX_34
    movew %a1@,%d0
RMAX_34:                /* next component */
    addqw #2,%a1
    asll %d5,%d0
    movew %a2@+,%d0
    cmpw %a1@,%d0
    jbcc RMAX_40
    movew %a1@,%d0
RMAX_40:                /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a5@,%d4,%d7
RMAX_50:                /* next pixel; end of the run: next row (RGNBLT_4CC) */
    addl %d3,%d6
    addl %d3,%d4
    dbf %d2,RMAX_8
    jbra RGNBLT_4CC
    .byte   0x00, 0x00, 0x00, 0x00	| 4082B98C
    /* RMax, 32-bit direct pixels: run list (fp-12) */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
RMAX_66:                /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
RMAX_74:                /* 32-bit pixels, one per long: the larger */
    movel %a0@(0x0,%d6:w),%d7
    addw %a4,%d6
    andw %d4,%d6
    movel %a5@,%d5
    movel %d5,%d0
    cmpw %d7,%d0
    jbhi RMAX_88
    movew %d7,%d0
    moveb %d5,%d0
RMAX_88:                /* next component: the larger */
    cmpb %d7,%d5
    jbhi RMAX_8E
    moveb %d7,%d0
RMAX_8E:                /* next component */
    swap %d7
    swap %d0
    cmpb %d7,%d0
    jbhi RMAX_98
    moveb %d7,%d0
RMAX_98:                /* next component */
    swap %d0
    movel %d0,%a5@
    addaw %a4,%a5
    dbf %d2,RMAX_74
    jbra RMAX_66
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082B9D4
    /* RMax, 16-bit direct pixels: run list (fp-12) */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
RMAX_B6:                /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
    bclr #14,%d2
    jbeq RMAX_12A
RMAX_CA:                /* a masked run: this pixel inside the region? */
    tstl %a1@+
    jbmi RMAX_E0
    addqw #2,%a5
    addqw #2,%d6
    jbsr RMAX_EE
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RMAX_CA
    jbra RMAX_B6
RMAX_E0:                /* 32-bit masked run: each pixel */
    jbsr RMAX_EE
    addqw #4,%a5
    addqw #4,%d6
    andw %d4,%d6
    dbf %d2,RMAX_CA
    jbra RMAX_B6

RMAX_EE:                /* one 16-bit pixel: unpack the 5-bit components, the larger of each */
    moveq #0,%d7
    movew %a0@(0x0,%d6:w),%d7
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    moveq #0,%d5
    movew %a5@,%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    movel %d7,%d0
    cmpl %d5,%d0
    jbcc RMAX_110
    movel %d5,%d0
RMAX_110:               /* next component */
    movew %d7,%d0
    cmpw %d5,%d0
    jbcc RMAX_118
    movew %d5,%d0
RMAX_118:               /* next component */
    moveb %d7,%d0
    cmpb %d5,%d0
    jbcc RMAX_120
    moveb %d5,%d0
RMAX_120:               /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a5@
    rts
RMAX_12A:               /* 16-bit masked run: two pixels per long */
    jbsr RMAX_EE
    addqw #2,%a5
    addqw #2,%d6
    jbsr RMAX_EE
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RMAX_12A
    jbra RMAX_B6

/* RMIN: arithmetic transfer mode min (RgnBlt). */
trap_RMIN:
RMIN:
    moveal %fp@(-264),%a0
    movew %fp@(-140),%d1
RMIN_8:                 /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %d1,%d6
    bfextu %a4@,%d4,%d7,%d0
    jbeq RMIN_50
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a2
    bfextu %a5@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a1
    movew %a2@+,%d0
    cmpw %a1@,%d0
    jbls RMIN_28
    movew %a1@,%d0
RMIN_28:                /* next component */
    addqw #2,%a1
    asll %d5,%d0
    movew %a2@+,%d0
    cmpw %a1@,%d0
    jbls RMIN_34
    movew %a1@,%d0
RMIN_34:                /* next component */
    addqw #2,%a1
    asll %d5,%d0
    movew %a2@+,%d0
    cmpw %a1@,%d0
    jbls RMIN_40
    movew %a1@,%d0
RMIN_40:                /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a5@,%d4,%d7
RMIN_50:                /* next pixel; end of the run: next row (RGNBLT_4CC) */
    addl %d3,%d6
    addl %d3,%d4
    dbf %d2,RMIN_8
    jbra RGNBLT_4CC
    .byte   0x00, 0x00, 0x00, 0x00	| 4082BACC
    /* RMin, 32-bit direct pixels: run list (fp-12) */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
RMIN_66:                /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
RMIN_74:                /* 32-bit pixels, one per long: the smaller */
    movel %a0@(0x0,%d6:w),%d7
    addw %a4,%d6
    andw %d4,%d6
    movel %a5@,%d5
    movel %d5,%d0
    cmpw %d7,%d0
    jbls RMIN_88
    movew %d7,%d0
    moveb %d5,%d0
RMIN_88:                /* next component: the smaller */
    cmpb %d7,%d5
    jbls RMIN_8E
    moveb %d7,%d0
RMIN_8E:                /* next component */
    swap %d7
    swap %d0
    cmpb %d7,%d0
    jbls RMIN_98
    moveb %d7,%d0
RMIN_98:                /* next component */
    swap %d0
    movel %d0,%a5@
    addaw %a4,%a5
    dbf %d2,RMIN_74
    jbra RMIN_66
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082BB14
    /* RMin, 16-bit direct pixels: run list (fp-12) */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
RMIN_B6:                /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
    bclr #14,%d2
    jbeq RMIN_12A
RMIN_CA:                /* a masked run: this pixel inside the region? */
    tstl %a1@+
    jbmi RMIN_E0
    addqw #2,%a5
    addqw #2,%d6
    jbsr RMIN_EE
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RMIN_CA
    jbra RMIN_B6
RMIN_E0:                /* 32-bit masked run: each pixel */
    jbsr RMIN_EE
    addqw #4,%a5
    addqw #4,%d6
    andw %d4,%d6
    dbf %d2,RMIN_CA
    jbra RMIN_B6

RMIN_EE:                /* one 16-bit pixel: unpack the 5-bit components, the smaller of each */
    moveq #0,%d7
    movew %a0@(0x0,%d6:w),%d7
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    moveq #0,%d5
    movew %a5@,%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    movel %d7,%d0
    cmpl %d5,%d0
    jbls RMIN_110
    movel %d5,%d0
RMIN_110:               /* next component */
    movew %d7,%d0
    cmpw %d5,%d0
    jbls RMIN_118
    movew %d5,%d0
RMIN_118:               /* next component */
    moveb %d7,%d0
    cmpb %d5,%d0
    jbls RMIN_120
    moveb %d5,%d0
RMIN_120:               /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a5@
    rts
RMIN_12A:               /* 16-bit masked run: two pixels per long */
    jbsr RMIN_EE
    addqw #2,%a5
    addqw #2,%d6
    jbsr RMIN_EE
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RMIN_12A
    jbra RMIN_B6

/* RAVG: arithmetic transfer mode avg (RgnBlt). */
trap_RAVG:
RAVG:
    moveal %d3,%a0
RAVG_2:                 /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %a4@,%d4,%d7,%d0
    jbeq RAVG_5E
    bfextu %a3@,%d6,%d7,%d0
    lea %fp@(0xfffffffffffffef8)@(0x0,%d0:w:8),%a2
    bfextu %a5@,%d4,%d7,%d0
    lea %fp@(0xfffffffffffffef8)@(0x0,%d0:w:8),%a1
    moveq #2,%d0
    movew %fp@(-270),%d3
    addw %d3,%d3
    clrw %sp@-
RAVG_2A:                /* each of R, G, B: weighted average (blend) */
    movew %a2@+,%d1
    muluw %fp@(0xffffffffffffff06,%d0:w:2),%d1
    movew %a1@+,%d5
    muluw %fp@(0xffffffffffffff00,%d0:w:2),%d5
    addl %d5,%d1
    swap %d1
    movew %fp@(-272),%d5
    lsrw %d5,%d1
    lslw %d3,%d1
    orw %d1,%sp@
    subw %fp@(-270),%d3
    dbf %d0,RAVG_2A
    movew %sp@+,%d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a5@,%d4,%d7
RAVG_5E:                /* next pixel; end of the run: next row (RGNBLT_4CC) */
    addl %a0,%d6
    addl %a0,%d4
    dbf %d2,RAVG_2
    movel %a0,%d3
    jbra RGNBLT_4CC
    .byte   0x00, 0x00, 0x00, 0x00	| 4082BC1C
    /* RAvg, 32-bit direct pixels: run list, masks 0x7F7F7F and 0x010101 */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    movel #8355711,%d0
    moveal #65793,%a2
RAVG_82:                /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
RAVG_90:                /* 32-bit pixels, one per long: average at 50%: (a >> 1) + (b >> 1) per component plus the carry */
    movel %a0@(0x0,%d6:w),%d7
    addw %a4,%d6
    andw %d4,%d6
    movel %a2,%d3
    andl %d7,%d3
    lsrl #1,%d7
    andl %d0,%d7
    movel %a5@,%d5
    andl %d5,%d3
    lsrl #1,%d5
    andl %d0,%d5
    addl %d5,%d7
    addl %d3,%d7
    movel %d7,%a5@
    addaw %a4,%a5
    dbf %d2,RAVG_90
    jbra RAVG_82
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082BC66
    /* RAvg, 16-bit direct pixels: run list, masks 0x3DEF and 0x0421 */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    movew #15855,%d0
    moveaw #1057,%a2
RAVG_CE:                /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
    bclr #14,%d2
    jbeq RAVG_122
RAVG_E2:                /* a masked run: this pixel inside the region? */
    tstl %a1@+
    jbmi RAVG_F8
    addqw #2,%a5
    addqw #2,%d6
    jbsr RAVG_106
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RAVG_E2
    jbra RAVG_CE
RAVG_F8:                /* 32-bit 50% blend, masked run: each pixel (RAVG_106) */
    jbsr RAVG_106
    addqw #4,%a5
    addqw #4,%d6
    andw %d4,%d6
    dbf %d2,RAVG_E2
    jbra RAVG_CE

RAVG_106:               /* one 16-bit pixel at 50%: (a >> 1) + (b >> 1) per component plus the carry */
    movel %a2,%d3
    movew %a0@(0x0,%d6:w),%d7
    andw %d7,%d3
    lsrw #1,%d7
    andw %d0,%d7
    movew %a5@,%d5
    andw %d5,%d3
    lsrw #1,%d5
    andw %d0,%d5
    addw %d5,%d7
    addw %d3,%d7
    movew %d7,%a5@
    rts
RAVG_122:               /* 16-bit masked run: two pixels per long */
    jbsr RAVG_106
    addqw #2,%a5
    addqw #2,%d6
    jbsr RAVG_106
    addqw #2,%a5
    addqw #2,%d6
    andw %d4,%d6
    dbf %d2,RAVG_122
    jbra RAVG_CE
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082BCE6
RAVG_140:               /* end of the row; then the weighted 16-bit blend */
    movew %sp@+,%d1
    jbra RGNBLT_512
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    movew %d1,%sp@-
    lea %fp@(-250),%a2
    movel %a2@+,%d1
    movew %a2@,%d0
    moveq #0,%d4
    movel %d4,%d3
    moveal %d4,%a2
RAVG_140_1C:            /* 32-bit weighted blend: next run of the row; end of row: next row */
    movel %a1@+,%d2
    bmis RAVG_140
    addaw %d2,%a5
    addw %d2,%d6
    andw %fp@(-140),%d6
    swap %d2
RAVG_140_2A:            /* each pixel: same source and destination as the last? reuse the result */
    movel %a0@(0x0,%d6:w),%d7
    addw %a4,%d6
    andw %fp@(-140),%d6
    movel %a5@,%d5
    cmpl %d3,%d7
    bnes RAVG_140_3E
    cmpl %a2,%d5
    beqs RAVG_140_90
RAVG_140_3E:            /* each component: (src * weight + dst * (1 - weight)) >> 16 */
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
    moveaw %d4,%a2
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
    addaw %d4,%a2
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
    movew %a2,%d4
    swap %d5
    moveal %d5,%a2
    swap %d7
    movel %d7,%d3
RAVG_140_90:            /* store; next pixel */
    movel %d4,%a5@
    addaw %a4,%a5
    dbf %d2,RAVG_140_2A
    bras RAVG_140_1C
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082BD8A
    /* RAvg, 32-bit weighted blend: run list, the weights from the op color (fp-250) */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
    movew %d1,%sp@-
    lea %fp@(-250),%a2
    movel %a2@+,%d1
    movew %a2@,%d0
    moveq #0,%d4
    movel %d4,%d3
    moveal %d4,%a2
RAVG_1F6:               /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RAVG_140
    addaw %d2,%a5
    addw %d2,%d6
    andw %fp@(-140),%d6
    swap %d2
    bclr #14,%d2
    jbeq RAVG_2BE
RAVG_20E:               /* a masked run: this pixel inside the region? */
    tstl %a1@+
    jbmi RAVG_226
    addqw #2,%a5
    addqw #2,%d6
    jbsr RAVG_236
    addqw #2,%a5
    addqw #2,%d6
    andw %fp@(-140),%d6
    dbf %d2,RAVG_20E
    jbra RAVG_1F6
RAVG_226:               /* masked run: each pixel (RAVG_236) */
    jbsr RAVG_236
    addqw #4,%a5
    addqw #4,%d6
    andw %fp@(-140),%d6
    dbf %d2,RAVG_20E
    jbra RAVG_1F6

RAVG_236:               /* next component */
    moveq #0,%d7
    movew %a0@(0x0,%d6:w),%d7
    moveq #0,%d5
    movew %a5@,%d5
    cmpw %d3,%d7
    jbne RAVG_248
    cmpw %a2,%d5
    jbeq RAVG_2BA
RAVG_248:               /* unpack the 5-bit components of both pixels, weight them */
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
    moveal %d4,%a2
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
    addaw %d4,%a2
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
    addw %a2,%d4
    swap %d5
    lslb #3,%d5
    lslw #3,%d5
    lsrl #6,%d5
    moveal %d5,%a2
    swap %d7
    lslb #3,%d7
    lslw #3,%d7
    lsrl #6,%d7
    movel %d7,%d3
RAVG_2BA:               /* store the pixel */
    movew %d4,%a5@
    rts
RAVG_2BE:               /* two pixels per long */
    jbsr RAVG_236
    addqw #2,%a5
    addqw #2,%d6
    jbsr RAVG_236
    addqw #2,%a5
    addqw #2,%d6
    andw %fp@(-140),%d6
    dbf %d2,RAVG_2BE
    jbra RAVG_1F6
    .short  0x0000, 0x0000, 0x0000	| 4082BE8A

/* RHILITE: arithmetic transfer mode hilite (RgnBlt). */
trap_RHILITE:
RHILITE:
    lea %pc@(RHILITE_2C),%a0
    movel %a0,%fp@(-536)
    moveal %fp@(-280),%a3
    movel %fp@(-276),%d5
    jbra RHILITE_2C
RHILITE_12:             /* next row; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    movew %fp@(-4),%d0
    addqw #1,%d0
    cmpw %fp@(-584),%d0
    jbge RGNBLT_4C6
    subqw #1,%a0
    movew %a0,%d1
    jble RGNBLT_45C
RHILITE_2C:             /* start of a row */
    moveaw %d1,%a0
    movew %d0,%fp@(-4)
    moveal %a5,%a2
    moveal %fp@(-12),%a1
RHILITE_38:             /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RHILITE_12
    addaw %d2,%a2
    swap %d2
    bclr #14,%d2
    jbeq RHILITE_9A
RHILITE_46:             /* next long: all background or all hilite? whole long at once */
    movel %a2@,%d4
    cmpl %d4,%d5
    jbne RHILITE_60
RHILITE_4C:             /* store the long (through the region mask) */
    movel %a1@+,%d0
    movel %a3,%d1
    andl %d0,%d1
    notl %d0
    andl %a2@,%d0
    orl %d0,%d1
    movel %d1,%a2@+
    dbf %d2,RHILITE_46
    jbra RHILITE_38
RHILITE_60:             /* all hilite color: swap the two colors */
    cmpl %a3,%d4
    jbne RHILITE_68
    exg %d5,%a3
    jbra RHILITE_4C
RHILITE_68:             /* mixed long: go through it pixel by pixel */
    moveq #32,%d1
    subw %d7,%d1
    moveal %d5,%a4
    movel %a1@+,%d5
RHILITE_70:             /* pixel by pixel: background becomes hilite, hilite becomes background */
    bfextu %d5,%d1,%d7,%d0
    jbeq RHILITE_8C
    bfextu %d4,%d1,%d7,%d0
    cmpl %d6,%d0
    jbne RHILITE_84
    bfins %d3,%d4,%d1,%d7
    jbra RHILITE_8C
RHILITE_84:             /* pixel is the hilite color: make it the background color */
    cmpl %d3,%d0
    jbne RHILITE_8C
    bfins %d6,%d4,%d1,%d7
RHILITE_8C:             /* next pixel of the long */
    subw %d7,%d1
    jbpl RHILITE_70
    movel %d4,%a2@+
    movel %a4,%d5
    dbf %d2,RHILITE_46
    jbra RHILITE_38
RHILITE_9A:             /* next long: all background or all hilite? whole long at once */
    movel %a2@,%d4
    cmpl %d4,%d5
    jbne RHILITE_A8
RHILITE_A0:             /* store the long (through the region mask) */
    movel %a3,%a2@+
    dbf %d2,RHILITE_9A
    jbra RHILITE_38
RHILITE_A8:             /* all hilite color: swap the two colors */
    cmpl %a3,%d4
    jbne RHILITE_B0
    exg %d5,%a3
    jbra RHILITE_A0
RHILITE_B0:             /* mixed long: go through it pixel by pixel */
    moveq #32,%d1
    subw %d7,%d1
RHILITE_B4:             /* pixel by pixel: background becomes hilite, hilite becomes background */
    bfextu %d4,%d1,%d7,%d0
    cmpl %d6,%d0
    jbne RHILITE_C2
    bfins %d3,%d4,%d1,%d7
    jbra RHILITE_CA
RHILITE_C2:             /* pixel is the hilite color: make it the background color */
    cmpl %d3,%d0
    jbne RHILITE_CA
    bfins %d6,%d4,%d1,%d7
RHILITE_CA:             /* next pixel of the long */
    subw %d7,%d1
    jbpl RHILITE_B4
    movel %d4,%a2@+
    dbf %d2,RHILITE_9A
    jbra RHILITE_38
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082BF68
    /* RHilite, 32-bit direct pixels: the loop entry into fp-536, mask 0x00FFFFFF; a pixel equal to fp-276 becomes fp-280 and the other way round */
    lea %pc@(RHILITE_CA_44),%a0
    movel %a0,%fp@(-536)
    moveq #-1,%d3
    lsrl #8,%d3
    moveal %fp@(-280),%a3
    movel %fp@(-276),%d5
    bras RHILITE_CA_44
RHILITE_CA_2C:          /* next row; past the last row: done (RGNBLT_4C6); the region changes here: RGNBLT_45C */
    addal %fp@(-124),%a5	| 4082BF86
    movew %fp@(-4),%d0
    addqw #1,%d0
    cmpw %fp@(-584),%d0
    bgew RGNBLT_4C6
    subqw #1,%d1
    blew RGNBLT_45C
RHILITE_CA_44:          /* row number (fp-4), start of the row, the run list */
    movew %d0,%fp@(-4)	| 4082BF9E
    moveal %a5,%a2
    moveal %fp@(-12),%a1
RHILITE_CA_4E:          /* next run: offset in the low word, count in the high word; end of the row: _2C */
    movel %a1@+,%d2	| 4082BFA8
    bmis RHILITE_CA_2C
    addaw %d2,%a2
    swap %d2
RHILITE_CA_56:          /* next pixel, low 24 bits, against the color to replace */
    movel %d3,%d4	| 4082BFB0
    andl %a2@,%d4
    cmpl %d4,%d5
    bnes RHILITE_CA_66
RHILITE_CA_5E:          /* store the new color */
    movel %a3,%a2@+	| 4082BFB8
    dbf %d2,RHILITE_CA_56
    bras RHILITE_CA_4E
RHILITE_CA_66:          /* the other color? swap the two, so that following pixels of this color take the short path */
    cmpl %a3,%d4	| 4082BFC0
    bnes RHILITE_CA_6E
    exg %d5,%a3
    bras RHILITE_CA_5E
RHILITE_CA_6E:          /* neither color: leave the pixel */
    addql #4,%a2	| 4082BFC8
    dbf %d2,RHILITE_CA_56
    bras RHILITE_CA_4E

/* RSLOWHILITE: arithmetic transfer mode slowhilite (RgnBlt). */
trap_RSLOWHILITE:
RSLOWHILITE:
    jbra RGNBLT_4C6
    moveaw %d1,%a0
    bfextu %fp@(-276),0,%d7,%d1
    moveal %d3,%a0
    movew %fp@(-140),%d3
    bras RSLOWHILITE_2E
RSLOWHILITE_14:         /* (RgnBlt hilite, pixel by pixel) next row; last row: done; region change: back to RGNBLT */
    addal %fp@(-124),%a5
    movew %fp@(-4),%d0
    addqw #1,%d0
    cmpw %fp@(-584),%d0
    bgew RGNBLT_4C6
    subqw #1,%a0
    movew %a0,%d1
    blew RGNBLT_45C
RSLOWHILITE_2E:         /* start of a row */
    movew %d0,%fp@(-4)
    moveal %a5,%a2
    moveal %fp@(-12),%a1
RSLOWHILITE_38:         /* next run of the row; a masked run? */
    movel %a1@+,%d2
    bmis RSLOWHILITE_14
    addaw %d2,%a2
    swap %d2
    bclr #14,%d2
    beqs RSLOWHILITE_5C
RSLOWHILITE_46:         /* full run: each long through the hilite pattern mask */
    movel %a2@,%d4
    movel %a1@+,%d0
    movel %a3,%d1
    andl %d0,%d1
    notl %d0
    andl %a2@,%d0
    orl %d0,%d1
    movel %d1,%a2@+
    dbf %d2,RSLOWHILITE_46
    bras RSLOWHILITE_38
RSLOWHILITE_5C:         /* masked run: each pixel inside the region and the pattern: swap background and hilite */
    andw %d3,%d6
    bfextu %a4@,%d4,%d7,%d0
    beqs RSLOWHILITE_80
    bfextu %a3@,%d6,%d7,%d0
    beqs RSLOWHILITE_80
    bfextu %a5@,%d4,%d7,%d0
    cmpw %d5,%d0
    bnes RSLOWHILITE_78
    bfins %d1,%a5@,%d4,%d7
    bras RSLOWHILITE_80
RSLOWHILITE_78:         /* hilite color: becomes background */
    cmpw %d1,%d0
    bnes RSLOWHILITE_80
    bfins %d5,%a5@,%d4,%d7
RSLOWHILITE_80:         /* next pixel; next run */
    addl %a0,%d6
    addl %a0,%d4
    dbf %d2,RSLOWHILITE_5C
    bras RSLOWHILITE_38
    .short  0x0000, 0x0000, 0x0000	| 4082C05A

/* RTRANSPARENT: arithmetic transfer mode transparent (RgnBlt). */
trap_RTRANSPARENT:
RTRANSPARENT:
    movew %fp@(-140),%d1
    moveaw %fp@(-646),%a0
    moveaw %fp@(-648),%a2
    bfextu %d5,0,%d7,%d0
    moveal %d0,%a1
RTRANSPARENT_12:        /* next pixel: skip it if the pattern pixel is the background color, or outside the region mask */
    andw %d1,%d6
    bfextu %a3@,%d6,0,%d0
    cmpl %d0,%d5
    jbeq RTRANSPARENT_3A
    bfextu %a4@,%d4,%d7,%d0
    jbeq RTRANSPARENT_2E
    bfextu %a3@,%d6,%d7,%d0
    cmpal %d0,%a1
    jbeq RTRANSPARENT_2E
    bfins %d0,%a5@,%d4,%d7
RTRANSPARENT_2E:        /* next pixel; end of the run: next row (RGNBLT_4CC) */
    addl %d3,%d6
    addl %d3,%d4
    dbf %d2,RTRANSPARENT_12
    jbra RGNBLT_4CC
RTRANSPARENT_3A:        /* pattern pixel is the background color: skip it */
    addl %a2,%d6
    addl %a2,%d4
    subw %a0,%d2
    jbge RTRANSPARENT_12
    jbra RGNBLT_4CC
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082C0A6
    /* RTransparent, 32-bit direct pixels: run list (fp-12) */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
RTRANSPARENT_56:        /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
RTRANSPARENT_64:        /* 32-bit pixels, one per long: the source unless it is the background color */
    movel %a0@(0x0,%d6:w),%d7
    addw %a4,%d6
    andw %d4,%d6
    cmpl %d7,%d5
    jbeq RTRANSPARENT_72
    movel %d7,%a5@
RTRANSPARENT_72:        /* next pixel */
    addaw %a4,%a5
    dbf %d2,RTRANSPARENT_64
    jbra RTRANSPARENT_56
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082C0DA
    /* RTransparent, 16-bit direct pixels: run list (fp-12) */
    moveal %a3,%a0
    moveal %fp@(-12),%a1
RTRANSPARENT_86:        /* direct pixels: next run of the row (region runs); end of row: next row */
    movel %a1@+,%d2
    jbmi RGNBLT_512
    addaw %d2,%a5
    addw %d2,%d6
    andw %d4,%d6
    swap %d2
    bclr #14,%d2
    jbeq RTRANSPARENT_CC
RTRANSPARENT_9A:        /* a masked run: this pixel inside the region? */
    tstl %a1@+
    jbmi RTRANSPARENT_B6
    movew %a0@(0x2,%d6:w),%d7
    cmpw %d7,%d5
    jbeq RTRANSPARENT_AA
    movew %d7,%a5@(2)
RTRANSPARENT_AA:        /* next pixel */
    addaw %a4,%a5
    addw %a4,%d6
    andw %d4,%d6
    dbf %d2,RTRANSPARENT_9A
    jbra RTRANSPARENT_86
RTRANSPARENT_B6:        /* 16-bit pixel: the source unless it is the background color */
    movew %a0@(0x0,%d6:w),%d7
    cmpw %d7,%d5
    jbeq RTRANSPARENT_C0
    movew %d7,%a5@
RTRANSPARENT_C0:        /* next pixel */
    addaw %a4,%a5
    addw %a4,%d6
    andw %d4,%d6
    dbf %d2,RTRANSPARENT_9A
    jbra RTRANSPARENT_86
RTRANSPARENT_CC:        /* 32-bit pixels, one per long: the source unless it is the background color */
    movel %a0@(0x0,%d6:w),%d7
    cmpl %d7,%d5
    jbeq RTRANSPARENT_E4
    cmpw %d7,%d5
    jbeq RTRANSPARENT_DC
    movew %d7,%a5@(2)
RTRANSPARENT_DC:        /* the other 16-bit pixel of the long */
    swap %d7
    cmpw %d7,%d5
    jbeq RTRANSPARENT_E4
    movew %d7,%a5@
RTRANSPARENT_E4:        /* next pixel */
    addaw %a4,%a5
    addw %a4,%d6
    andw %d4,%d6
    dbf %d2,RTRANSPARENT_CC
    jbra RTRANSPARENT_86

/* STDRECT: StdRect: the rectangle bottleneck (frame/paint/erase/invert/fill). */
trap_StdRect:
STDRECT:                /* StdRect(verb, rect): record it in an open picture (PUTPICVERB, opcode 0x30 + verb), then draw it on every screen through STDDEVLOOP */
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveb %fp@(12),%d7
    jsr @(0x1a3c,%za0)@(0)	| 4082C15C
    jble STDRECT_28
    moveb %d7,%sp@-
    jsr %pc@(PUTPICVERB)
    moveq #48,%d0
    addw %d7,%d0
    moveb %d0,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(PUTPICRECT)
STDRECT_28:             /* the draw proc (STDRECT_50) and the bounding-rectangle proc (STDRECT_40) */
    pea %pc@(STDRECT_50)
    pea %pc@(STDRECT_40)
    jsr @(0x1aa0,%za0)@(0)	| 4082C180
    moveml %sp@+,%d7/%a3-%a4
    unlk %fp
    rtd #6
STDRECT_40:             /* rectangle proc: the rectangle itself */
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %fp@(8),%a0
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    moveal %d0,%a0
    jmp %a0@
STDRECT_50:             /* draw proc: frame (FRMRECT) or the other verbs (DRAWRECT); framing while a region is open adds the rectangle to it (PUTRECT) */
    movel %fp@(8),%sp@-
    tstb %d7
    jbne STDRECT_78
    tstl %a3@(96)
    jbeq STDRECT_72
    movel %fp@(8),%sp@-
    movel %a4@(-148),%sp@-
    pea %a4@(-150)
    pea %a4@(-152)
    jsr %pc@(PUTRECT)
STDRECT_72:             /* frame */
    jsr %pc@(FRMRECT)
    jbra STDRECT_82
STDRECT_78:             /* paint, erase, invert, fill */
    jsr @(0x1a60,%za0)@(0)	| 4082C1C8
    jsr %pc@(DRAWRECT)
STDRECT_82:             /* done */
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4082C1D4

/*
 STDDEVLOOP(drawProc, rectProc): draw on every screen. With more than one device and the
 port on the main screen, rectProc gives the global bounding rectangle of the drawing; for
 each active device (DeviceList, 0x8A8) whose gdRect it touches, that device becomes
 TheGDevice (0xCC8) and SrcDevice (0x8A0), the port's hilite flag, fill pattern and
 colors are restored, the colors re-matched when the device's color table differs
 (ctSeed), and drawProc runs. Otherwise drawProc runs once. Both procs run in the caller's
 stack frame (fp switched back for the call). Ends with HiliteMode (0x938) bit 7 set
 (hilite off).
*/
trap_STDDEVLOOP:
STDDEVLOOP:             /* run drawProc once per screen touched */
    linkw %fp,#-38
    clrl %fp@(-12)
    moveal DeviceList,%a0
    moveal %a0@,%a0
    tstl %a0@(30)
    jbeq STDDEVLOOP_1A6
    clrw %fp@(-14)
    moveal %a3,%a0
    jsr @(0x1a5c,%za0)@(0)	| 4082C1FC
    movel %a0,%fp@(-34)
    movel %a0@,%d0
    moveal MainDevice,%a0
    moveal %a0@,%a1
    moveal %a1@(22),%a1
    moveal %a1@,%a1
    cmpl %a1@,%d0
    jbne STDDEVLOOP_1A6
    moveb HiliteMode,%fp@(-36)
    movel %a3@(48),%fp@(-18)
    movew %a3@(14),%fp@(-38)
    movel SrcDevice,%sp@-
    movel TheGDevice,%sp@-
    movel %a3@(100),%sp@-
    movel %a3@(96),%sp@-
    moveal %a1@(42),%a0
    moveal %a0@,%a0
    movel %a0@,%fp@(-22)
    movel %a3@(80),%fp@(-26)
    movel %a3@(84),%fp@(-30)
    movel %fp,%sp@-
    moveal %fp@(8),%a0
    pea %fp@(-8)
    moveal %fp@,%fp
    jsr %a0@
    moveal %sp@+,%fp
    lea %fp@(-8),%a0
    moveal %fp@(-34),%a1
    movel %a1@(6),%d0
    movel %d0,%d1
    swap %d1
    subw %d1,%a0@+
    jbvc STDDEVLOOP_9C
    jsr @(0x1a58,%za0)@(0)	| 4082C276
STDDEVLOOP_9C:          /* the rectangle to global coordinates (pinned on overflow) */
    subw %d0,%a0@+
    jbvc STDDEVLOOP_A6
    jsr @(0x1a58,%za0)@(0)	| 4082C280
STDDEVLOOP_A6:          /* bottom */
    subw %d1,%a0@+
    jbvc STDDEVLOOP_B0
    jsr @(0x1a58,%za0)@(0)	| 4082C28A
STDDEVLOOP_B0:          /* right */
    subw %d0,%a0@+
    jbvc STDDEVLOOP_BA
    jsr @(0x1a58,%za0)@(0)	| 4082C294
STDDEVLOOP_BA:          /* for each device */
    moveal DeviceList,%a0
STDDEVLOOP_BE:          /* active? make it current; does the rectangle touch its gdRect? */
    moveal %a0@,%a1
    tstw %a1@(20)
    jbpl STDDEVLOOP_1CA
    movel %a0,TheGDevice
    movel %a0,SrcDevice
    movel %a0,%fp@(-12)
    lea %a1@(34),%a0
    lea %fp@(-8),%a1
    movel %a1@+,%d0
    movel %a1@+,%d1
    swap %d1
    cmpw %a0@+,%d1
    jble STDDEVLOOP_1C4
    swap %d1
    cmpw %a0@+,%d1
    jble STDDEVLOOP_1C4
    swap %d0
    cmpw %a0@+,%d0
    jbge STDDEVLOOP_1C4
    swap %d0
    cmpw %a0@+,%d0
    jbge STDDEVLOOP_1C4
    moveb %fp@(-36),HiliteMode
    movel %fp@(-18),%a3@(48)
    tstw %a3@(6)
    jbpl STDDEVLOOP_1A6
    movew %fp@(-38),%a3@(14)
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    movel %a0@,%d0
    cmpl %fp@(-22),%d0
    jbeq STDDEVLOOP_1A6
    movel %d0,%fp@(-22)
    subqw #6,%sp
    clrl %sp@-
    movel %a3@(8),%d0
    jbeq STDDEVLOOP_16E
    moveal %d0,%a0
    moveal %a0@,%a0
    tstl %a0@(12)
    jbeq STDDEVLOOP_16E
    movew %a0@(24),%d2
    movew %a0@(22),%sp@(2)
    btst #1,%d2
    sne %sp@
    btst #0,%d2
    jbeq STDDEVLOOP_16E
    movew %a0@(16),%sp@-
    jsr @(0x185c,%za0)@(0)	| 4082C346
    jbra STDDEVLOOP_180
STDDEVLOOP_16E:         /* the foreground color for this device */
    pea %sp@(4)
    movel %sp@,%sp@-
    jsr @(0x1664,%za0)@(0x0)	| 4082C354
    jsr @(0x1650,%za0)@(0x0)
STDDEVLOOP_180:         /* the background color */
    tstb %sp@
    jbeq STDDEVLOOP_190
    movew %sp@(2),%sp@-
    jsr @(0x1860,%za0)@(0x0)	| 4082C368
    jbra STDDEVLOOP_1A2
STDDEVLOOP_190:         /* the background color */
    pea %sp@(4)
    movel %sp@,%sp@-
    jsr @(0x1668,%za0)@(0x0)	| 4082C376
    jsr @(0x1654,%za0)@(0x0)
STDDEVLOOP_1A2:         /* done re-matching */
    lea %sp@(10),%sp
STDDEVLOOP_1A6:         /* run drawProc */
    moveal %fp@(12),%a0
    movel %fp,%sp@-
    moveal %fp@,%fp
    jsr %a0@
    moveal %sp@+,%fp
    st %fp@(-14)
    movel %fp@(-12),%d0
    jbeq STDDEVLOOP_1FA
    clrl %a3@(96)
    clrl %a3@(100)
STDDEVLOOP_1C4:         /* the device just drawn */
    moveal %fp@(-12),%a0
    moveal %a0@,%a1
STDDEVLOOP_1CA:         /* next device; at the end restore the devices and the port's colors */
    movel %a1@(30),%d0
    moveal %d0,%a0
    jbne STDDEVLOOP_BE
    clrl %fp@(-12)
    movel %sp@+,%a3@(96)
    movel %sp@+,%a3@(100)
    movel %sp@+,TheGDevice
    movel %sp@+,SrcDevice
    movel %fp@(-26),%a3@(80)
    movel %fp@(-30),%a3@(84)
    tstw %fp@(-14)
    jbeq STDDEVLOOP_1A6
STDDEVLOOP_1FA:         /* done: hilite off */
    bset #7,HiliteMode
    unlk %fp
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082C3E6

trap_PINIT:
PINIT:                  /* set the pin limits at a0-2 to the largest coordinate of the sign */
    tstw %a0@(-2)
    jbpl PINIT_E
    movew #32766,%a0@(-2)
    rts
PINIT_E:                /* negative */
    movew #-32766,%a0@(-2)
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082C406

trap_PUSHVERB:
PUSHVERB:               /* push the mode and pattern for a verb (d7: frame/paint/erase/invert/fill): mode 8 (patCopy) or the pen mode, and the pattern */
    moveal %sp@+,%a0
    movew #8,%sp@-
    cmpib #1,%d7
    jble PUSHVERB_48
    cmpib #3,%d7
    jblt PUSHVERB_26
    jbeq PUSHVERB_2C
    lea %a3@(40),%a1
    tstw %a3@(6)
    jbpl PUSHVERB_22
PUSHVERB_1E:            /* color port: the fill pixpat */
    lea %a3@(62),%a1
PUSHVERB_22:            /* push the pattern */
    movel %a1,%sp@-
    jbra PUSHVERB_52
PUSHVERB_26:            /* erase: the background pattern */
    pea %a3@(32)
    jbra PUSHVERB_52
PUSHVERB_2C:            /* invert: patXor with the black pattern (QuickDraw globals) */
    addqw #2,%sp@
    lea %a4@(-16),%a1
    tstw %a3@(6)
    jbpl PUSHVERB_22
    movel %a0,%sp@-
    movel %a1,%sp@-
    moveq #0,%d0
    jsr @(0x1a8c,%za0)@(0)	| 4082C44E
    moveal %sp@+,%a0
    jbra PUSHVERB_1E
PUSHVERB_48:            /* frame or paint: the pen mode and pen pattern */
    movew %a3@(56),%d0
    orw %d0,%sp@
    pea %a3@(58)
PUSHVERB_52:            /* return */
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 4082C464

/* FILLRECT: _FillRect: fill with a pattern the rectangle. */
trap_FillRect:
FILLRECT:
    moveq #0,%d0
    jbra FILLCRECT_2

/* FILLCRECT: _FillCrect: fill with a pattern the rectangle with a pixel pattern. */
trap_FillCRect:
FILLCRECT:
    moveq #1,%d0
FILLCRECT_2:            /* rearrange the parameters, call CALLRECT with verb 4 (fill) */
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a0,%sp@-
    movel %a1,%sp@-
    jsr @(0x1a8c,%za0)@(0)	| 4082C47E
    moveq #4,%d0
    jbra CALLRECT

/* FRAMERECT: _FrameRect: frame (outline with the pen) the rectangle. */
trap_FrameRect:
FRAMERECT:
    moveq #0,%d0
    jbra CALLRECT

/* PAINTRECT: _PaintRect: paint (fill with the pen pattern) the rectangle. */
trap_PaintRect:
PAINTRECT:
    moveq #1,%d0
    jbra CALLRECT

/* ERASERECT: _EraseRect: erase (fill with the background) the rectangle. */
trap_EraseRect:
ERASERECT:
    moveq #2,%d0
    jbra CALLRECT

/* INVERTRECT: _InvertRect: invert the rectangle. */
trap_InverRect:
INVERTRECT:
    moveq #3,%d0

/* CALLRECT: call the port's rect bottleneck (grafProcs) or the standard one. */
CALLRECT:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    moveb %d0,%sp@-
    movel %a1,%sp@-
    movel %a0,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x1080,%a0
    jbeq CALLRECT_1E
    moveal %d0,%a0
    moveal %a0@(8),%a0
CALLRECT_1E:            /* through the port's rectProc or StdRect */
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082C4B6

DRAWRECT:               /* DrawRect: paint/erase/invert/fill a rectangle with the verb's mode and pattern (pushes the port bits, the rectangle, the mode and pattern for the blitter) */
    linkw %fp,#0
    moveal %a5@,%a0
    moveal %a0@,%a1
    tstw %a1@(66)
    jblt DRAWRECT_42
    pea %a1@(2)
    clrl %sp@-
    pea %a1@(2)
    movel %fp@(14),%sp@-
    clrl %sp@-
    movel %fp@(14),%sp@-
    movew %fp@(12),%sp@-
    oriw #8,%sp@
    movel %fp@(8),%sp@-
    movel %a1@(28),%sp@-
    movel %a1@(24),%sp@-
    movel %a0@(-130),%sp@-
    clrw %sp@-
    jsr @(0x1a9c,%za0)@(0)	| 4082C4FC
DRAWRECT_42:            /* return */
    unlk %fp
    rtd #10
    .long   0x00000000, 0x00000000	| 4082C508

FRMRECT:                /* FrmRect: frame a rectangle with the pen: four edge rectangles */
    linkw %fp,#-28
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(66)
    jblt FRMRECT_106
    moveal %fp@(8),%a1
    movel %a1@+,%fp@(-28)
    movel %a1@+,%fp@(-24)
    lea %fp@(-28),%a1
    movew %a0@(54),%d2
    movew %a1@(2),%d0
    movew %d0,%fp@(-2)
    addw %d2,%d0
    movew %d0,%fp@(-4)
    movew %a1@(6),%d1
    movew %d1,%fp@(-10)
    subw %d2,%d1
    movew %d1,%fp@(-6)
    cmpw %d1,%d0
    jbge FRMRECT_BA
    movew %a0@(52),%d2
    movew %a1@,%d0
    movew %d0,%fp@(-12)
    addw %d2,%d0
    movew %d0,%fp@(-14)
    movew %a1@(4),%d1
    movew %d1,%fp@(-20)
    subw %d2,%d1
    movew %d1,%fp@(-16)
    cmpw %d1,%d0
    jbge FRMRECT_BA
    movew %fp@(-2),%fp@(-26)
    movew %fp@(-6),%fp@(-22)
    movew %fp@(-12),%fp@(-28)
    movew %fp@(-14),%fp@(-24)
    jbsr FRMRECT_BC
    movew %fp@(-6),%fp@(-26)
    movew %fp@(-10),%fp@(-22)
    movew %fp@(-16),%fp@(-24)
    jbsr FRMRECT_BC
    movew %fp@(-4),%fp@(-26)
    movew %fp@(-16),%fp@(-28)
    movew %fp@(-20),%fp@(-24)
    jbsr FRMRECT_BC
    movew %fp@(-2),%fp@(-26)
    movew %fp@(-4),%fp@(-22)
    movew %fp@(-14),%fp@(-28)
FRMRECT_BA:             /* done */
    jbra FRMRECT_FE

FRMRECT_BC:             /* draw the rectangle at fp-28 with the pen pattern and mode (blitter vector 0x1A9C) */
    moveb HiliteMode,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a1
    pea %a1@(2)
    clrl %sp@-
    pea %a1@(2)
    pea %fp@(-28)
    clrl %sp@-
    pea %fp@(-28)
    movew %a1@(56),%sp@-
    oriw #8,%sp@
    pea %a1@(58)
    movel %a1@(28),%sp@-
    movel %a1@(24),%sp@-
    movel %a0@(-130),%sp@-
    clrw %sp@-
    jsr @(0x1a9c,%za0)@(0)	| 4082C602
    moveb %sp@+,HiliteMode
    rts

FRMRECT_FE:             /* draw; hilite off */
    jbsr FRMRECT_BC
    bset #7,HiliteMode
FRMRECT_106:            /* return */
    unlk %fp
    rtd #4
    .long   0x00000000	| 4082C61C

/* SETRECT: _SetRect. */
trap_SetRect:
SETRECT:
    moveal %sp@+,%a0
    movel %sp@+,%d1
    movel %sp@+,%d0
    moveal %sp@+,%a1
    movel %d0,%a1@+
    movel %d1,%a1@+
    jmp %a0@
    .short  0x0000	| 4082C62E

/* EQUALRECT: _EqualRect. */
trap_EqualRect:
EQUALRECT:              /* EqualRect(a, b) */
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    cmpml %a0@+,%a1@+
    jbne EQUALRECT_14
    cmpml %a0@+,%a1@+
    jbne EQUALRECT_14
    moveb #1,%sp@
    jbra EQUALRECT_16
EQUALRECT_14:           /* different */
    clrb %sp@
EQUALRECT_16:           /* return */
    movel %d0,%sp@-
    rts
    .short  0x0000, 0x0000, 0x0000	| 4082C64A

/* EMPTYRECT: _EmptyRect. */
trap_EmptyRect:
EMPTYRECT:              /* EmptyRect(r): bottom <= top or right <= left */
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    movew %a0@+,%d0
    movew %a0@+,%d1
    cmpw %a0@+,%d0
    jbge EMPTYRECT_14
    cmpw %a0@+,%d1
    jbge EMPTYRECT_14
    clrb %sp@
    jbra EMPTYRECT_18
EMPTYRECT_14:           /* empty */
    moveb #1,%sp@
EMPTYRECT_18:           /* return */
    jmp %a1@
    .short  0x0000, 0x0000, 0x0000	| 4082C66A

/* OFFSETRECT: _OffsetRect. */
trap_OffsetRect:
OFFSETRECT:
    moveal %sp@+,%a0
    movew %sp@+,%d1
    movew %sp@+,%d0
    moveal %sp@+,%a1
    addw %d1,%a1@+
    addw %d0,%a1@+
    addw %d1,%a1@+
    addw %d0,%a1@+
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082C682

/* INSETRECT: _InsetRect. */
trap_InsetRect:
INSETRECT:
    moveal %sp@+,%a0
    movew %sp@+,%d1
    movew %sp@+,%d0
    moveal %sp@+,%a1
    addw %d1,%a1@+
    addw %d0,%a1@+
    subw %d1,%a1@+
    subw %d0,%a1@+
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082C6A2

/* SECTRECT: _SectRect. */
trap_SectRect:
SECTRECT:
    linkw %fp,#0
    movel %fp@(16),%sp@-
    movel %fp@(12),%sp@-
    movew #2,%sp@-
    movel %fp@(8),%sp@-
    jbsr trap_RSECT
    sne %fp@(20)
    negb %fp@(20)
    unlk %fp
    rtd #12

/* RSECT: intersection of several rectangles. */
trap_RSECT:
RSECT:                  /* RSect(n, rects..., dst): the intersection of n rectangles; returns Z set (cmp right, left) when empty */
    linkw %fp,#0
    moveml %d1-%d4/%a1,%sp@-
    lea %fp@(12),%a1
    movew %a1@+,%d0
    jble RSECT_4A
    moveal %a1@+,%a0
    movemw %a0@+,%d1-%d4
    subqw #1,%d0
    jbra RSECT_3C
RSECT_1A:               /* next rectangle: the larger top and left, the smaller bottom and right */
    moveal %a1@+,%a0
    cmpw %a0@+,%d1
    jbge RSECT_24
    movew %a0@(-2),%d1
RSECT_24:               /* left */
    cmpw %a0@+,%d2
    jbge RSECT_2C
    movew %a0@(-2),%d2
RSECT_2C:               /* bottom */
    cmpw %a0@+,%d3
    jble RSECT_34
    movew %a0@(-2),%d3
RSECT_34:               /* right */
    cmpw %a0@+,%d4
    jble RSECT_3C
    movew %a0@(-2),%d4
RSECT_3C:               /* empty so far? stop */
    cmpw %d1,%d3
    jble RSECT_4A
    cmpw %d2,%d4
    jble RSECT_4A
    dbf %d0,RSECT_1A
    jbra RSECT_52
RSECT_4A:               /* empty: all zero */
    clrw %d1
    clrw %d2
    clrw %d3
    clrw %d4
RSECT_52:               /* store the result, pop the n rectangles */
    moveal %fp@(8),%a0
    movew %d1,%a0@+
    movew %d2,%a0@+
    movew %d3,%a0@+
    movew %d4,%a0@+
    movew %fp@(12),%d0
    lslw #2,%d0
    addqw #6,%d0
    cmpw %d1,%d3
    moveml %sp@+,%d1-%d4/%a1
    unlk %fp
    moveal %sp@+,%a0
    addaw %d0,%sp
    jmp %a0@
    .long   0x00000000, 0x00000000	| 4082C748

/* UNIONRECT: _UnionRect. */
trap_UnionRect:
UNIONRECT:              /* UnionRect(a, b, dst): the smaller top/left, the larger bottom/right */
    moveal %sp@(12),%a0
    moveal %sp@(8),%a1
    movew %a0@+,%d0
    cmpw %a1@+,%d0
    jble UNIONRECT_12
    movew %a1@(-2),%d0
UNIONRECT_12:           /* left */
    swap %d0
    movew %a0@+,%d0
    cmpw %a1@+,%d0
    jble UNIONRECT_1E
    movew %a1@(-2),%d0
UNIONRECT_1E:           /* bottom */
    movew %a0@+,%d1
    cmpw %a1@+,%d1
    jbge UNIONRECT_28
    movew %a1@(-2),%d1
UNIONRECT_28:           /* right */
    swap %d1
    movew %a0@+,%d1
    cmpw %a1@+,%d1
    jbge UNIONRECT_34
    movew %a1@(-2),%d1
UNIONRECT_34:           /* store; pop the parameters (PT2RECT_2E) */
    moveal %sp@(4),%a0
    movel %d0,%a0@+
    movel %d1,%a0@+
    jbra PT2RECT_2E

/* PT2RECT: _Pt2Rect. */
trap_Pt2Rect:
PT2RECT:                /* Pt2Rect(a, b, dst): the rectangle with the two points as corners */
    moveal %sp@(4),%a0
    movew %sp@(14),%d0
    movew %sp@(10),%d1
    cmpw %d0,%d1
    jbge PT2RECT_12
    exg %d0,%d1
PT2RECT_12:             /* left and right */
    movew %d0,%a0@(2)
    movew %d1,%a0@(6)
    movew %sp@(12),%d0
    movew %sp@(8),%d1
    cmpw %d0,%d1
    jbge PT2RECT_28
    exg %d0,%d1
PT2RECT_28:             /* top and bottom */
    movew %d0,%a0@
    movew %d1,%a0@(4)
PT2RECT_2E:             /* pop the parameters */
    moveal %sp@+,%a0
    lea %sp@(12),%sp
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 4082C7C4

/* PTINRECT: _PtInRect. */
trap_PtInRect:
PTINRECT:
    linkw %fp,#0
    moveal %fp@(8),%a0
    movew %fp@(14),%d0
    movew %fp@(12),%d1
    clrb %fp@(16)
    cmpw %a0@+,%d1
    jblt PTINRECT_28
    cmpw %a0@+,%d0
    jblt PTINRECT_28
    cmpw %a0@+,%d1
    jbge PTINRECT_28
    cmpw %a0@+,%d0
    jbge PTINRECT_28
    addqb #1,%fp@(16)
PTINRECT_28:            /* return */
    unlk %fp
    rtd #8
    .short  0x0000	| 4082C7FE

/* PUTRECT: store a rectangle. */
PUTRECT:                /* append a rectangle to the region being built (handle, size word): 16 bytes per rectangle, growing the handle 1K at a time; past 64K: rgnTooBigErr (-147) in 0xD6E */
    linkw %fp,#0
    moveal %fp@(12),%a0
    cmpiw #-1041,%a0@
    jbls PUTRECT_16
    movew #-147,QDErr
    jbra PUTRECT_64
PUTRECT_16:             /* room left? else grow by 1K (SETHSIZE) */
    moveal %fp@(8),%a1
    moveq #16,%d0
    addw %a0@,%d0
    cmpw %a1@,%d0
    jbls PUTRECT_3C
    addiw #1024,%a1@
    moveml %d3/%a2,%sp@-
    movel %fp@(16),%sp@-
    movew %a1@,%sp@-
    jsr %pc@(SETHSIZE)
    moveml %sp@+,%d3/%a2
    moveal %fp@(12),%a0
PUTRECT_3C:             /* append the rectangle's points */
    moveal %fp@(16),%a1
    moveal %a1@,%a1
    moveq #0,%d0
    movew %a0@,%d0
    addal %d0,%a1
    addiw #16,%a0@
    moveal %fp@(20),%a0
    movel %a0@,%a1@+
    movew %a0@,%a1@+
    movew %a0@(6),%a1@+
    movew %a0@(4),%a1@+
    movew %a0@(2),%a1@+
    movel %a0@(4),%a1@+
PUTRECT_64:             /* return */
    unlk %fp
    rtd #16
    .short  0x0000, 0x0000, 0x0000	| 4082C86A

/*
 BITBLT: copy or draw a rectangle (fp-116: top, left, bottom, right in the destination)
 with no region clipping (the regions are rectangular): source a4 (or the pattern),
 destination a5, row by row, through the mode loops of the table at 0x1AC0 (boolean
 modes: BSETUP/BMAIN/BEND...), 0x1CE0/0x1CE4 (arithmetic, 32/16-bit pixels) or 0x1CE8
 (hilite). A plain aligned srcCopy of whole bytes uses the fast copy at 0x1B60
 (0x1B64 backwards). Overlapping copies go bottom-up or right to left.
*/
trap_BITBLT:
BITBLT:
    lea %fp@(-616),%a0
    movew %fp@(-116),%d0
    subw %a3@,%d0
    addw %a2@,%d0
    movew %d0,%a0@
    movew %fp@(-114),%d0
    subw %a3@(2),%d0
    addw %a2@(2),%d0
    movew %d0,%a0@(2)
    moveal %a0,%a2
    lea %fp@(-116),%a3
    movew %a3@(4),%d0
    subw %a3@,%d0
    jble BITBLT_3F0
    movew %d0,%fp@(-608)
    movew #4,%d3
    movew %a2@,%d0
    subw %a4@(6),%d0
    movew %d0,%fp@(-602)
    movew %a3@,%d0
    subw %a5@(6),%d0
    movew %d0,%fp@(-604)
    movew %fp@(-152),%d2
    btst #3,%d2
    jbeq BITBLT_82
    movew %fp@(-142),%d1
    jbne BITBLT_68
    moveq #15,%d7
    andw %a3@,%d7
    movel %fp@(0xffffffffffffff78)@(0x0,%d7:w:4),%d6
    jbra BITBLT_10E
BITBLT_68:              /* a color pattern: its row */
    moveq #0,%d6
    movew %fp@(-138),%d6
    addqw #1,%d6
    divuw %fp@(-142),%d6
    subqw #1,%d6
    andw %a3@,%d6
    muluw %d1,%d6
    movew %fp@(-140),%d7
    jbra BITBLT_10E
BITBLT_82:              /* a source: same bitmap and overlapping? choose the direction */
    movel %a4@,%d0
    cmpl %a5@,%d0
    jbne BITBLT_D0
    movew %fp@(-602),%d0
    cmpw %fp@(-604),%d0
    jbgt BITBLT_D0
    jblt BITBLT_BA
    movew %a2@(2),%d0
    subw %a4@(8),%d0
    movew %a3@(2),%d1
    subw %a5@(8),%d1
    cmpw %d1,%d0
    jbge BITBLT_D0
    movew %fp@(-110),%d2
    subw %fp@(-114),%d2
    addw %d0,%d2
    cmpw %d1,%d2
    jble BITBLT_D0
    negw %d3
    jbra BITBLT_D0
BITBLT_BA:              /* source above: bottom-up (negate the row steps) */
    movew %fp@(-608),%d0
    subqw #1,%d0
    addw %d0,%fp@(-602)
    addw %d0,%fp@(-604)
    negl %fp@(-444)
    negl %fp@(-124)
BITBLT_D0:              /* the source's first long and bit offset (d6) */
    movew %a3@(2),%d6
    subw %a5@(8),%d6
    extl %d6
    lsll %d4,%d6
    movew %a2@(2),%d1
    subw %a4@(8),%d1
    extl %d1
    movew %fp@(-450),%d0
    lsll %d0,%d1
    subl %d1,%d6
    moveq #31,%d0
    andl %d0,%d6
    negl %d6
    movew %a4@(4),%d0
    andiw #32767,%d0
    mulsw %fp@(-602),%d0
    moveal %a4@,%a4
    addal %d0,%a4
    subl %d6,%d1
    asrl #5,%d1
    addl %d1,%d1
    addl %d1,%d1
    addal %d1,%a4
BITBLT_10E:             /* the destination's first long */
    movew %a3@(2),%d1
    subw %a5@(8),%d1
    extl %d1
    lsll %d4,%d1
    movew %a5@(4),%d0
    andiw #32767,%d0
    mulsw %fp@(-604),%d0
    moveal %a5@,%a5
    addal %d0,%a5
    movel %d1,%d0
    asrl #5,%d1
    lsll #2,%d1
    addal %d1,%a5
    tstw %fp@(-142)
    jbeq BITBLT_148
    moveal %fp@(-136),%a4
    addaw %d6,%a4
    swap %d6
    movew %d1,%d6
    andw %d7,%d6
    movew %d6,%fp@(-144)
BITBLT_148:             /* the left edge mask (d4), the width */
    movel %d4,%d5
    moveq #31,%d2
    andl %d2,%d0
    moveq #-1,%d4
    lsrl %d0,%d4
    movew %a3@(6),%d1
    subw %a3@(2),%d1
    jble BITBLT_3F0
    movew %d1,%fp@(-640)
    extl %d1
    lsll %d5,%d1
    addl %d0,%d1
    moveq #-1,%d5
    andl %d1,%d2
    jbeq BITBLT_172
    lsrl %d2,%d5
    notl %d5
BITBLT_172:             /* the right edge mask (d5), longs per row; right to left: start at the end, swap the edge masks */
    subql #1,%d1
    asrl #5,%d1
    movew %d1,%fp@(-622)
    movel %d1,%d2
    addl %d1,%d1
    addl %d1,%d1
    movel %d1,%d0
    addql #4,%d0
    moveaw %d3,%a0
    tstw %d3
    jbpl BITBLT_192
    negl %d0
    addal %d1,%a5
    addal %d1,%a4
    exg %d4,%d5
BITBLT_192:             /* row steps; a plain copy on a byte boundary: the fast routine (vectors 0x1B60, 0x1B64 by direction) */
    movew %fp@(-442),%fp@(-606)
    subw %d0,%fp@(-606)
    moveaw %fp@(-122),%a3
    subaw %d0,%a3
    movew %fp@(-152),%d0
    jbne BITBLT_1CE
    tstw %fp@(-260)
    jbne BITBLT_1CE
    movew %d6,%d1
    andiw #7,%d1
    jbne BITBLT_1CE
    tstw %d2
    jble BITBLT_1CE
    movew %d6,%d1
    asrw #3,%d1
    addaw %d1,%a4
    moveal 0x1b60,%a1
    tstw %d3
    jbpl BITBLT_1CC
    moveal 0x1b64,%a1
BITBLT_1CC:             /* the fast byte copy (0x1B60 / 0x1B64) */
    jmp %a1@
BITBLT_1CE:             /* arithmetic modes (32..63) */
    cmpiw #32,%d0
    jbcs BITBLT_374
    movel %fp@(-276),%fp@(-164)
    cmpiw #64,%d0
    jbcc BITBLT_3F0
    cmpiw #48,%d0
    jblt BITBLT_210
    cmpiw #50,%d0
    jbeq BITBLT_210
    cmpiw #58,%d0
    jbne BITBLT_3F0
    tstw %fp@(-142)
    jbne BITBLT_210
    moveq #-1,%d2
    moveq #15,%d3
    moveal %fp@(-136),%a1
BITBLT_206:             /* hilite with an all-ones pattern: the fast hilite */
    cmpl %a1@+,%d2
    dbne %d3,BITBLT_206
    jbeq BITBLT_2FE
BITBLT_210:             /* a pattern? a color pattern: its row offsets */
    btst #3,%d0
    jbeq BITBLT_262
    movew %fp@(-142),%d2
    jbeq BITBLT_246
    moveb #1,%fp@(-624)
    swap %d6
    movew %d6,%fp@(-638)
    clrw %d6
    swap %d6
    asll #3,%d6
    movel %d6,%fp@(-636)
    movew %fp@(-212),%d3
    subqw #1,%d3
    notw %d3
    aslw #3,%d2
    subqw #1,%d2
    andw %d3,%d2
    movew %d2,%fp@(-140)
    jbra BITBLT_26C
BITBLT_246:             /* an 8x8 pattern */
    clrb %fp@(-624)
    lea %fp@(0xffffffffffffff78)@(0x0,%d7:w:4),%a4
    movew %d7,%fp@(-638)
    moveq #0,%d6
    movel %d6,%fp@(-636)
    movew #31,%fp@(-140)
    jbra BITBLT_26C
BITBLT_262:             /* a source */
    st %fp@(-624)
    movew #-1,%fp@(-140)
BITBLT_26C:             /* pixels per long, direction */
    andiw #55,%d0
    moveq #32,%d2
    moveq #0,%d7
    movew %fp@(-212),%d7
    divuw %d7,%d2
    movew %d2,%fp@(-632)
    movew %d2,%fp@(-646)
    moveq #0,%d3
    movel %d7,%sp@-
    moveq #32,%d1
    movew %a0,%fp@(-588)
    cmpaw #0,%a0
    jbpl BITBLT_29C
    negl %sp@
    negl %d1
    moveq #32,%d3
    subw %d2,%d3
    addl %d3,%d6
BITBLT_29C:             /* the op color, the pixel steps */
    moveal %d1,%a2
    movel %d5,%fp@(-628)
    moveal %fp@(-268),%a0
    movew %fp@(-270),%d5
    clrb %fp@(-623)
    movew %fp@(-622),%d1
    subqw #1,%d1
    movew %d1,%fp@(-622)
    jbmi BITBLT_2CA
    muluw %fp@(-632),%d1
    subqw #1,%d1
    movew %d1,%fp@(-630)
    subqw #1,%d2
    movew %d2,%fp@(-622)
BITBLT_2CA:             /* the loop: by pixel size (16/32 bits: their own tables) */
    subqw #1,%fp@(-632)
    movel %d3,%fp@(-644)
    cmpiw #48,%d0
    jbgt BITBLT_2F0
    cmpiw #16,%d7
    jbge BITBLT_32C
    addw %d0,%d0
    movew %d0,%d1
    bfextu %fp@(-276),0,%d7,%d0
    moveal %d0,%a3
    movel %d3,%d0
    jbra BITBLT_3A6
BITBLT_2F0:             /* hilite: the hilite color */
    movel %d3,%d0
    moveq #60,%d1
    bfextu %fp@(-280),0,%d7,%d5
    jbra BITBLT_3A6
BITBLT_2FE:             /* the hilite loop (0x1CE8) */
    movew %fp@(-212),%d7
    movel %d5,%fp@(-628)
    moveal %fp@(-280),%a0
    bfextu %fp@(-280),0,%d7,%d5
    lea 0x20,%a2
    subaw %d7,%a2
    bfextu %fp@(-276),0,%d7,%d0
    movew %fp@(-118),%d1
    moveal 0x1ce8,%a1
    addal %a1@(0xfffffffffffffffc,%d1:w:4),%a1
    jbra BITBLT_3AE
BITBLT_32C:             /* 16/32-bit arithmetic: blend at 50%? */
    andiw #7,%d0
    jbeq BITBLT_356
BITBLT_332:             /* the 16-bit (0x1CE4) or 32-bit (0x1CE0) table */
    cmpiw #16,%d7
    jbeq BITBLT_346
    moveal 0x1ce4,%a1
    addal %a1@(0x0,%d0:w:4),%a1
    jmp @(0x1cf0,%za0)@(0)	| 4082CBB0
BITBLT_346:             /* 32-bit */
    moveal 0x1ce0,%a1
    addal %a1@(0x0,%d0:w:4),%a1
    movel %d4,%d1
    jmp @(0x1cec,%za0)@(0)	| 4082CBC0
BITBLT_356:             /* blend weights all equal to 50%: the average loop */
    lea %fp@(-250),%a1
    movew %a1@+,%d1
    cmpw %a1@+,%d1
    jbne BITBLT_332
    cmpw %a1@,%d1
    jbne BITBLT_332
    addqw #1,%d1
    andiw #-2,%d1
    cmpiw #-32768,%d1
    jbne BITBLT_332
    addqw #8,%d0
    jbra BITBLT_332
BITBLT_374:             /* boolean modes: index from the mode, the not bit, a color source, a color pattern */
    andiw #11,%d0
    movew %d0,%d1
    andiw #3,%d0
    addw %d0,%d1
    cmpiw #8,%d1
    jbge BITBLT_396
    cmpiw #4,%d1
    jbeq BITBLT_39E
    tstw %fp@(-260)
    jbeq BITBLT_39E
    addiw #24,%d1
BITBLT_396:             /* a color pattern: the X variants */
    tstw %fp@(-142)
    jbeq BITBLT_39E
    addqw #8,%d1
BITBLT_39E:             /* one long per row: the narrow variants */
    tstw %d2
    jbne BITBLT_3A6
    addiw #32,%d1
BITBLT_3A6:             /* the loop from the table at 0x1AC0 */
    lea 0x1ac0,%a1
    moveal %a1@(0x0,%d1:w:2),%a1
BITBLT_3AE:             /* masks and colors */
    movel %d4,%fp@(-620)
    movel %fp@(-160),%d3
    movel %fp@(-164),%d4
BITBLT_3BA:             /* each row: d1 = left mask, d2 = longs; jump to the loop */
    movel %fp@(-620),%d1
    movew %fp@(-622),%d2
    jmp %a1@

BITBLT_3C4:             /* next row (source and destination); done? */
    addaw %fp@(-606),%a4
    addaw %a3,%a5
    subqw #1,%fp@(-608)
    jbne BITBLT_3BA
    jbra BITBLT_3F0

BITBLT_3D2:             /* a color pattern: next row (wrapping) */
    clrw %d6
    swap %d6
    subal %d6,%a4
    addw %fp@(-142),%d6
    andw %fp@(-138),%d6
    addal %d6,%a4
    swap %d6
    movew %fp@(-144),%d6
    addaw %a3,%a5
    subqw #1,%fp@(-608)
    jbne BITBLT_3BA
BITBLT_3F0:             /* done */
    rts

BITBLT_3F2:             /* an 8x8 pattern: next row */
    addqw #1,%d7
    andiw #15,%d7
    movel %fp@(0xffffffffffffff78)@(0x0,%d7:w:4),%d6
    addaw %a3,%a5
    subqw #1,%fp@(-608)
    jbne BITBLT_3BA
    rts
BITBLT_408:             /* arithmetic loops: next row of the source or pattern */
    tstb %fp@(-624)
    jbeq BITBLT_440
    jbpl BITBLT_428
    addaw %fp@(-606),%a4
    movel %fp@(-636),%d6
    jbra BITBLT_458

BITBLT_41A:             /* next row: bottom-up or top-down, advance source and destination */
    tstb %fp@(-624)
    jbeq BITBLT_440
    jbpl BITBLT_428
    addaw %fp@(-606),%a4
    jbra BITBLT_458
BITBLT_428:             /* a color pattern: next row */
    moveq #0,%d0
    movew %fp@(-638),%d6
    subal %d6,%a4
    addw %fp@(-142),%d6
    andw %fp@(-138),%d6
    addal %d6,%a4
    movew %d6,%fp@(-638)
    jbra BITBLT_454
BITBLT_440:             /* an 8x8 pattern: next row */
    movew %fp@(-638),%d1
    addqw #1,%d1
    andiw #15,%d1
    movew %d1,%fp@(-638)
    lea %fp@(0xffffffffffffff78)@(0x0,%d1:w:4),%a4
BITBLT_454:             /* the bit offset back */
    movel %fp@(-636),%d6
BITBLT_458:             /* next destination row; done? */
    clrb %fp@(-623)
    movel %fp@(-644),%d0
    addaw %fp@(-122),%a5
    subqw #1,%fp@(-608)
    jbne BITBLT_3BA
    addqw #4,%sp
    rts

/* BARITH16TAB: table. */
trap_BARITH16TAB:
BARITH16TAB:
    .short  0x0000, 0x0FA0	| orib #0xa0,%d0
    .short  0x0000, 0x0880	| orib #0x80,%d0
    .short  0x0000, 0x0730	| orib #48,%d0
    .short  0x0000, 0x0B10	| orib #16,%d0
    .short  0x0000, 0x1250	| orib #80,%d0
    .short  0x0000, 0x0C60	| orib #96,%d0
    .short  0x0000, 0x09C0	| orib #0xc0,%d0
    .short  0x0000, 0x0D90	| orib #0x90,%d0
    .short  0x0000, 0x0ED0	| orib #0xd0,%d0

/* BARITH32TAB: table. */
trap_BARITH32TAB:
BARITH32TAB:
    .short  0x0000, 0x0EEC	| orib #0xec,%d0
    .short  0x0000, 0x07EC	| orib #0xec,%d0
    .short  0x0000, 0x06BC	| orib #0xbc,%d0
    .short  0x0000, 0x0A7C	| orib #124,%d0
    .short  0x0000, 0x11FC	| orib #0xfc,%d0
    .short  0x0000, 0x0BFC	| orib #0xfc,%d0
    .short  0x0000, 0x094C	| orib #76,%d0
    .short  0x0000, 0x0D2C	| orib #44,%d0
    .short  0x0000, 0x0E6C	| orib #108,%d0

/* BHILITETAB: table. */
trap_BHILITETAB:
BHILITETAB:
    .short  0x0000, 0x1018	| orib #24,%d0
    .short  0x0000, 0x1018	| orib #24,%d0
    .short  0x0000, 0x1018	| orib #24,%d0
    .short  0x0000, 0x1018	| orib #24,%d0
    .short  0x0000, 0x10A8	| orib #0xa8,%d0
    orib #0,%d0

/* BLEFT0: the first long (left edge), BitBlt (rectangle), mode srcCopy (and notSrcCopy: the source inverted through d7). */
trap_BLEFT0:
BLEFT0:
    movel %d4,%d1
    movew %fp@(-622),%d2
    movel %a4@,%d0
    addaw %a0,%a4
    andl %d1,%d0
    notl %d1
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@
    addaw %a0,%a5
    subqw #1,%d2
    jbeq BLEFT0_2E
    subaw %a0,%a4
    subaw %a0,%a5
    jbra BLEFT0_22
BLEFT0_20:              /* right to left: copy longs backwards */
    movel %a4@-,%a5@-
BLEFT0_22:              /* two at a time */
    movel %a4@-,%a5@-
    subqw #2,%d2
    jbgt BLEFT0_20
    jbeq BLEFT0_22
    addaw %a0,%a4
    addaw %a0,%a5
BLEFT0_2E:              /* the left edge long through its mask; next row */
    movel %d5,%d1
    movel %a4@,%d0
    addaw %a0,%a4
    andl %d1,%d0
    notl %d1
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@
    addaw %a0,%a5
    addaw %fp@(-606),%a4
    addaw %a3,%a5
    subqw #1,%fp@(-608)
    jbne trap_BLEFT0
    jbra BITBLT_3F0

/* BSETUP0: set-up and the fast long loop, BitBlt (rectangle), mode srcCopy (and notSrcCopy: the source inverted through d7). */
trap_BSETUP0:
BSETUP0:
    movew %d2,%d6
    movel %d4,%d2
    notl %d2
    jbne BSETUP0_A
    addqw #1,%d6
BSETUP0_A:              /* srcCopy aligned: the right mask; a full last long counts as a middle long */
    movel %d5,%d3
    notl %d3
    jbne BSETUP0_12
    addqw #1,%d6
BSETUP0_12:             /* rows, steps; the unrolled loop entry by the long count mod 16 */
    movew %fp@(-608),%d7
    subqw #1,%d7
    moveaw %fp@(-606),%a2
    lea %pc@(BSETUP0_66),%a0
    subqw #1,%d6
    jbeq BSETUP0_30
    moveq #15,%d0
    andw %d6,%d0
    negw %d0
    lea %a0@(0xfffffffffffffffc,%d0:w:2),%a0
    lsrw #4,%d6
BSETUP0_30:             /* each row: the first long through the left mask */
    movel %d2,%d1
    jbeq BSETUP0_3E
    movel %a4@+,%d0
    andl %d4,%d0
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@+
BSETUP0_3E:             /* the middle longs (jump into the unrolled copy) */
    movew %d6,%d0
    jmp %a0@
BSETUP0_42:             /* copy whole longs, 16 at a time */
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    movel %a4@+,%a5@+
    dbf %d0,BSETUP0_42
BSETUP0_66:             /* the last long through the right mask */
    movel %d3,%d1
    jbeq BSETUP0_74
    movel %a4@+,%d0
    andl %d5,%d0
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@+
BSETUP0_74:             /* next row */
    addaw %a2,%a4
    addaw %a3,%a5
    dbf %d7,BSETUP0_30
    jbra BITBLT_3F0

/* BEND0: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode srcCopy (and notSrcCopy: the source inverted through d7). */
trap_BEND0:
BEND0:
    andl %d5,%d1

/* BMAIN0: one long per pass, row by row, BitBlt (rectangle), mode srcCopy (and notSrcCopy: the source inverted through d7). */
trap_BMAIN0:
BMAIN0:
    bfextu %a4@,%d6,0,%d0
    addaw %a0,%a4
    eorl %d7,%d0
    andl %d1,%d0
    notl %d1
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@
    addaw %a0,%a5
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BMAIN0
    jbeq trap_BEND0
    jbra BITBLT_3C4
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082CE32

/* BEND1: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode srcOr / notSrcOr. */
trap_BEND1:
BEND1:
    andl %d5,%d1

/* BMAIN1: one long per pass, row by row, BitBlt (rectangle), mode srcOr / notSrcOr. */
trap_BMAIN1:
BMAIN1:
    bfextu %a4@,%d6,0,%d0
    addaw %a0,%a4
    eorl %d7,%d0
    andl %d1,%d0
    orl %d0,%a5@
    addaw %a0,%a5
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BMAIN1
    jbeq trap_BEND1
    jbra BITBLT_3C4
    .long   0x00000000	| 4082CE5C

/* BEND2: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode srcXor / notSrcXor. */
trap_BEND2:
BEND2:
    andl %d5,%d1

/* BMAIN2: one long per pass, row by row, BitBlt (rectangle), mode srcXor / notSrcXor. */
trap_BMAIN2:
BMAIN2:
    bfextu %a4@,%d6,0,%d0
    addaw %a0,%a4
    eorl %d7,%d0
    andl %d1,%d0
    eorl %d0,%a5@
    addaw %a0,%a5
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BMAIN2
    jbeq trap_BEND2
    jbra BITBLT_3C4
    .long   0x00000000	| 4082CE7C

/* BEND3: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode srcBic / notSrcBic. */
trap_BEND3:
BEND3:
    andl %d5,%d1

/* BMAIN3: one long per pass, row by row, BitBlt (rectangle), mode srcBic / notSrcBic. */
trap_BMAIN3:
BMAIN3:
    bfextu %a4@,%d6,0,%d0
    addaw %a0,%a4
    eorl %d7,%d0
    andl %d1,%d0
    notl %d0
    andl %d0,%a5@
    addaw %a0,%a5
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BMAIN3
    jbeq trap_BEND3
    jbra BITBLT_3C4
    .short  0x0000	| 4082CE9E

/* BCEND0: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode srcCopy colorized: source 1s take the foreground color, 0s the background. */
trap_BCEND0:
BCEND0:
    andl %d5,%d1

/* BCMAIN0: one long per pass, row by row, BitBlt (rectangle), mode srcCopy colorized: source 1s take the foreground color, 0s the background. */
trap_BCMAIN0:
BCMAIN0:
    bfextu %a4@,%d6,0,%d0
    addaw %a0,%a4
    eorl %d7,%d0
    movel %d0,%sp@-
    notl %d0
    andl %d4,%d0
    andl %d3,%sp@
    orl %sp@+,%d0
    andl %d1,%d0
    notl %d1
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@
    addaw %a0,%a5
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BCMAIN0
    jbeq trap_BCEND0
    jbra BITBLT_3C4
    .long   0x00000000	| 4082CECC

/* BCEND1: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode srcOr colorized: source 1s become the foreground color. */
trap_BCEND1:
BCEND1:
    andl %d5,%d1

/* BCMAIN1: one long per pass, row by row, BitBlt (rectangle), mode srcOr colorized: source 1s become the foreground color. */
trap_BCMAIN1:
BCMAIN1:
    bfextu %a4@,%d6,0,%d0
    addaw %a0,%a4
    eorl %d7,%d0
    andl %d1,%d0
    notl %d0
    andl %d0,%a5@
    notl %d0
    andl %d3,%d0
    orl %d0,%a5@
    addaw %a0,%a5
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BCMAIN1
    jbeq trap_BCEND1
    jbra BITBLT_3C4
    .long   0x00000000, 0x00000000, 0x00000000	| 4082CEF4

/* BCEND3: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode srcBic colorized: source 1s become the background color. */
trap_BCEND3:
BCEND3:
    andl %d5,%d1

/* BCMAIN3: one long per pass, row by row, BitBlt (rectangle), mode srcBic colorized: source 1s become the background color. */
trap_BCMAIN3:
BCMAIN3:
    bfextu %a4@,%d6,0,%d0
    addaw %a0,%a4
    eorl %d7,%d0
    andl %d1,%d0
    notl %d0
    andl %d0,%a5@
    notl %d0
    andl %d4,%d0
    orl %d0,%a5@
    addaw %a0,%a5
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BCMAIN3
    jbeq trap_BCEND3
    jbra BITBLT_3C4
    .long   0x00000000, 0x00000000, 0x00000000	| 4082CF24

/* BLONG8: whole longs of a row, BitBlt (rectangle), mode patCopy (and notPatCopy). */
trap_BLONG8:
BLONG8:
    movew %fp@(-608),%d3
    moveal %fp@(-136),%a4
    lea %a4@(0x0,%d7:w:4),%a2
    addqw #4,%a3
    subqw #1,%d3
    andl %d5,%d1
    movel %d1,%d5
    moveal %a4,%a1
    movel %a1@+,%d0
    moveq #14,%d2
BLONG8_1A:              /* one long wide pattern copy: is the pattern the same long in every row? */
    cmpl %a1@+,%d0
    dbne %d2,BLONG8_1A
    jbeq BLONG8_60
    notl %d5
    jbeq BLONG8_44
BLONG8_26:              /* varying pattern, partial long: each row through the mask */
    andl %d1,%d6
    movel %a5@,%d0
    andl %d5,%d0
    orl %d6,%d0
    movel %d0,%a5@
    addaw %a3,%a5
    addqw #1,%d7
    andiw #15,%d7
    movel %a4@(0x0,%d7:w:4),%d6
    dbf %d3,BLONG8_26
    jbra BITBLT_3F0
BLONG8_44:              /* full long: each row its pattern long */
    movel %a2@+,%a5@
    addaw %a3,%a5
    addqw #1,%d7
    andiw #15,%d7
    jbne BLONG8_52
    moveal %a4,%a2
BLONG8_52:              /* next row */
    dbf %d3,BLONG8_44
    jbra BITBLT_3F0
    .short  0x0000, 0x0000, 0x0000	| 4082CF8A
BLONG8_60:              /* constant pattern: a partial long */
    notl %d5
    jbeq BLONG8_78
    andl %d1,%d0
BLONG8_66:              /* each row through the mask */
    movel %a5@,%d2
    andl %d5,%d2
    orl %d0,%d2
    movel %d2,%a5@
    addaw %a3,%a5
    dbf %d3,BLONG8_66
    jbra BITBLT_3F0
BLONG8_78:              /* a full long: store it in each row */
    movel %d0,%a5@
    addaw %a3,%a5
    dbf %d3,BLONG8_78
    jbra BITBLT_3F0
    .long   0x00000000, 0x00000000, 0x00000000	| 4082CFB4

/* BSETUP8: set-up and the fast long loop, BitBlt (rectangle), mode patCopy (and notPatCopy). */
trap_BSETUP8:
BSETUP8:
    movew %d2,%d3
    movel %d1,%d4
    notl %d1
    moveal %d1,%a1
    jbne BSETUP8_C
    addqw #1,%d3
BSETUP8_C:              /* patCopy: the right mask; a full last long counts as a middle long */
    movel %d5,%d0
    notl %d0
    moveal %d0,%a2
    jbne BSETUP8_16
    addqw #1,%d3
BSETUP8_16:             /* the expanded pattern, rows, the unrolled loop entry */
    moveal %fp@(-136),%a4
    lea %a4@(0x4,%d7:w:4),%a4
    movew %d7,%d0
    moveq #1,%d7
    lslw %d0,%d7
    movew %fp@(-608),%d2
    subqw #1,%d2
    lea %pc@(BSETUP8_7E),%a0
    subqw #1,%d3
    jbeq BSETUP8_48
    moveq #15,%d0
    andw %d3,%d0
    negw %d0
    lea %a0@(0xfffffffffffffffc,%d0:w:2),%a0
    lsrw #4,%d3
    jbra BSETUP8_48
BSETUP8_40:             /* wrap to the first pattern row */
    moveq #1,%d7
    subaw #64,%a4
BSETUP8_46:             /* the row's pattern long */
    movel %a4@+,%d6
BSETUP8_48:             /* the left long through its mask */
    movel %a1,%d1
    jbeq BSETUP8_56
    movel %d6,%d0
    andl %d4,%d0
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@+
BSETUP8_56:             /* the middle longs */
    movew %d3,%d0
    jmp %a0@
BSETUP8_5A:             /* unrolled store of the pattern long */
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    movel %d6,%a5@+
    dbf %d0,BSETUP8_5A
BSETUP8_7E:             /* the right long through its mask */
    movel %a2,%d0
    jbeq BSETUP8_8A
    andl %a5@,%d0
    andl %d5,%d6
    orl %d6,%d0
    movel %d0,%a5@+
BSETUP8_8A:             /* next row; next pattern row */
    addaw %a3,%a5
    addw %d7,%d7
    dbeq %d2,BSETUP8_46
    dbne %d2,BSETUP8_40
    jbra BITBLT_3F0
    .short  0x0000, 0x0000, 0x0000	| 4082D05A

/* BEND9: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode patOr. */
trap_BEND9:
BEND9:
    andl %d5,%d1

/* BMAIN9: one long per pass, row by row, BitBlt (rectangle), mode patOr. */
trap_BMAIN9:
BMAIN9:
    andl %d6,%d1
    movel %d1,%d0
    andl %d3,%d0
    notl %d1
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@+
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BMAIN9
    jbeq trap_BEND9
    jbra BITBLT_3F2
    .long   0x00000000	| 4082D07C

/* BEND10: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode patXor. */
trap_BEND10:
BEND10:
    movew %fp@(-608),%d3
    moveal %fp@(-136),%a4
    lea %a4@(0x0,%d7:w:4),%a2
    addqw #4,%a3
    subqw #1,%d3
    andl %d5,%d1
BEND10_12:              /* patXor, one long: each row xor its pattern long */
    movel %a2@+,%d6
    andl %d1,%d6
    eorl %d6,%a5@
    addaw %a3,%a5
    addqw #1,%d7
    andiw #15,%d7
    jbne BEND10_24
    moveal %a4,%a2
BEND10_24:              /* next row */
    dbf %d3,BEND10_12
    jbra BITBLT_3F0
    .long   0x00000000	| 4082D0AC

/* BSETUP10: set-up and the fast long loop, BitBlt (rectangle), mode patXor. */
trap_BSETUP10:
BSETUP10:
    movew %d2,%d3
    movel %d1,%d4
    moveal %fp@(-136),%a2
    lea %a2@(0x4,%d7:w:4),%a4
    movew %d7,%d0
    moveq #1,%d7
    lslw %d0,%d7
    movew %fp@(-608),%d2
    subqw #1,%d2
    lea %pc@(BSETUP10_62),%a0
    subqw #1,%d3
    jbeq BSETUP10_34
    moveq #15,%d0
    andw %d3,%d0
    negw %d0
    lea %a0@(0xfffffffffffffffc,%d0:w:2),%a0
    lsrw #4,%d3
    jbra BSETUP10_34
BSETUP10_2E:            /* wrap to the first pattern row */
    moveq #1,%d7
    moveal %a2,%a4
BSETUP10_32:            /* the row's pattern long */
    movel %a4@+,%d6
BSETUP10_34:            /* the left long; the middle ones */
    movel %d6,%d0
    andl %d4,%d0
    eorl %d0,%a5@+
    movew %d3,%d0
    jmp %a0@
BSETUP10_3E:            /* unrolled xor */
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    eorl %d6,%a5@+
    dbf %d0,BSETUP10_3E
BSETUP10_62:            /* the right long; next row */
    andl %d5,%d6
    eorl %d6,%a5@+
    addaw %a3,%a5
    addw %d7,%d7
    dbeq %d2,BSETUP10_32
    dbne %d2,BSETUP10_2E
    jbra BITBLT_3F0
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082D126

/* BEND11: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode patBic. */
trap_BEND11:
BEND11:
    andl %d5,%d1

/* BMAIN11: one long per pass, row by row, BitBlt (rectangle), mode patBic. */
trap_BMAIN11:
BMAIN11:
    andl %d6,%d1
    movel %d1,%d0
    andl %d4,%d0
    notl %d1
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@+
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BMAIN11
    jbeq trap_BEND11
    jbra BITBLT_3F2
    .long   0x00000000	| 4082D14C

/* BXLONG8: whole longs of a row, BitBlt (rectangle), mode patCopy with a color (multi-long) pattern. */
trap_BXLONG8:
BXLONG8:
    moveaw %fp@(-142),%a0
    movew %fp@(-138),%d2
    movew %fp@(-608),%d3
    subqw #1,%d3
    addqw #4,%a3
    andl %d5,%d1
    movel %d1,%d5
    addaw %d6,%a4
    clrw %d6
    swap %d6
    subal %d6,%a4
    notl %d5
    jbeq BXLONG8_3C
BXLONG8_20:             /* color pattern, one partial long: each row through the mask */
    movel %a4@(0x0,%d6:w),%d7
    andl %d1,%d7
    movel %a5@,%d0
    andl %d5,%d0
    orl %d7,%d0
    movel %d0,%a5@
    addaw %a3,%a5
    addw %a0,%d6
    andw %d2,%d6
    dbf %d3,BXLONG8_20
    jbra BITBLT_3F0
BXLONG8_3C:             /* full long: each row its pattern long */
    movel %a4@(0x0,%d6:w),%a5@
    addaw %a3,%a5
    addw %a0,%d6
    andw %d2,%d6
    dbf %d3,BXLONG8_3C
    jbra BITBLT_3F0
    .short  0x0000	| 4082D19E
BXLONG8_50:             /* color pattern copy: the middle longs */
    subqw #1,%d2
BXLONG8_52:             /* each long from the pattern row */
    movel %a4@(0x0,%d6:w),%a5@+
    addqw #4,%d6
    andw %d7,%d6
    dbf %d2,BXLONG8_52
BXLONG8_5E:             /* last long: the right edge mask */
    andl %d5,%d1

/* BXMAIN8: one long per pass, row by row, BitBlt (rectangle), mode patCopy with a color (multi-long) pattern. */
trap_BXMAIN8:
BXMAIN8:
    movel %d1,%d0
    andl %a4@(0x0,%d6:w),%d0
    addqw #4,%d6
    andw %d7,%d6
    notl %d1
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@+
    moveq #-1,%d1
    subqw #1,%d2
    jbgt BXLONG8_50
    jbeq BXLONG8_5E
    clrw %d6
    swap %d6
    subal %d6,%a4
    addw %fp@(-142),%d6
    andw %fp@(-138),%d6
    addal %d6,%a4
    swap %d6
    movew %fp@(-144),%d6
    addaw %a3,%a5
    subqw #1,%fp@(-608)
    jbeq BITBLT_3F0
    movel %fp@(-620),%d1
    movew %fp@(-622),%d2
    jbra trap_BXMAIN8
    .long   0x00000000, 0x00000000, 0x00000000	| 4082D1F4

/* BXEND9: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode patOr, color pattern. */
trap_BXEND9:
BXEND9:
    andl %d5,%d1

/* BXMAIN9: one long per pass, row by row, BitBlt (rectangle), mode patOr, color pattern. */
trap_BXMAIN9:
BXMAIN9:
    andl %a4@(0x0,%d6:w),%d1
    addqw #4,%d6
    andw %d7,%d6
    movel %d1,%d0
    andl %d3,%d0
    notl %d1
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@+
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BXMAIN9
    jbeq trap_BXEND9
    jbra BITBLT_3D2
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082D222

/* BXEND10: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode patXor, color pattern. */
trap_BXEND10:
BXEND10:
    moveaw %fp@(-142),%a0
    movew %fp@(-138),%d2
    movew %fp@(-608),%d3
    subqw #1,%d3
    addqw #4,%a3
    andl %d5,%d1
    addaw %d6,%a4
    clrw %d6
    swap %d6
    subal %d6,%a4
BXEND10_1A:             /* color pattern xor, one long: each row */
    movel %a4@(0x0,%d6:w),%d0
    andl %d1,%d0
    eorl %d0,%a5@
    addaw %a3,%a5
    addw %a0,%d6
    andw %d2,%d6
    dbf %d3,BXEND10_1A
    jbra BITBLT_3F0
BXEND10_30:             /* last long: the right edge mask */
    andl %d5,%d1

/* BXMAIN10: one long per pass, row by row, BitBlt (rectangle), mode patXor, color pattern. */
trap_BXMAIN10:
BXMAIN10:
    andl %a4@(0x0,%d6:w),%d1
    addqw #4,%d6
    andw %d7,%d6
    eorl %d1,%a5@+
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BXMAIN10
    jbeq BXEND10_30
    jbra BITBLT_3D2
    .long   0x00000000, 0x00000000	| 4082D278

/* BXEND11: the last long of a row (right edge mask), then BMAIN, BitBlt (rectangle), mode patBic, color pattern. */
trap_BXEND11:
BXEND11:
    andl %d5,%d1

/* BXMAIN11: one long per pass, row by row, BitBlt (rectangle), mode patBic, color pattern. */
trap_BXMAIN11:
BXMAIN11:
    andl %a4@(0x0,%d6:w),%d1
    addqw #4,%d6
    andw %d7,%d6
    movel %d1,%d0
    andl %d4,%d0
    notl %d1
    andl %a5@,%d1
    orl %d1,%d0
    movel %d0,%a5@+
    moveq #-1,%d1
    subqw #1,%d2
    jbgt trap_BXMAIN11
    jbeq trap_BXEND11
    jbra BITBLT_3D2
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082D2A2

trap_BARITH32SETUP:
BARITH32SETUP:          /* BitBlt arithmetic set-up for 32-bit pixels: middle count, pattern mask, steps */
    movew %fp@(-640),%d2
    subqw #1,%d2
    movew %d2,%fp@(-622)
    moveq #0,%d4
    movew %fp@(-140),%d4
    lsrl #3,%d4
    movew %d4,%fp@(-140)
    tstb %fp@(-624)
    jbpl BARITH32SETUP_1E
    moveq #0,%d6
BARITH32SETUP_1E:       /* source offset, steps; right to left: one more */
    lsrl #3,%d6
    movel %d6,%fp@(-636)
    movew %fp@(-442),%fp@(-606)
    moveaw %fp@(-588),%a3
    movew %a3,%d7
    jbpl BARITH32SETUP_38
    addqw #1,%d2
    movew %d2,%fp@(-622)
BARITH32SETUP_38:       /* enter the loop */
    jmp %a1@
    .short  0x0000, 0x0000, 0x0000	| 4082D2EA

trap_BARITH16SETUP:
BARITH16SETUP:          /* BitBlt arithmetic set-up for 16-bit pixels */
    movew %fp@(-640),%d2
    subqw #1,%d2
    movew %d2,%fp@(-622)
    asrl #3,%d6
    movel %d6,%fp@(-636)
    movew %fp@(-442),%fp@(-606)
    movew %fp@(-588),%d7
    asrw #1,%d7
    moveaw %d7,%a3
    jbpl BARITH16SETUP_26
    addqw #1,%d2
    movew %d2,%fp@(-622)
BARITH16SETUP_26:       /* unaligned 16-bit: start one pixel in */
    tstl %d1
    jbmi BARITH16SETUP_32
    addqw #2,%a5
    addql #2,%d6
    movel %d6,%fp@(-636)
BARITH16SETUP_32:       /* the pattern mask; enter the loop */
    moveq #0,%d4
    movew %fp@(-140),%d4
    lsrl #3,%d4
    bset #1,%d4
    movew %d4,%fp@(-140)
    jmp %a1@
    .long   0x00000000, 0x00000000, 0x00000000	| 4082D334

/* BADDOVER: arithmetic transfer mode addover (BitBlt). */
trap_BADDOVER:
BADDOVER:
    moveal %fp@(-264),%a1
    tstw %d2
    jbgt BADDOVER_16
BADDOVER_8:             /* no middle longs: mark them done */
    orib #3,%fp@(-623)
BADDOVER_E:             /* the last long: its pixel count (fp-632) and the right mask (fp-628) */
    movew %fp@(-632),%d2
    andl %fp@(-628),%d1
BADDOVER_16:            /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %d1,%d0,%d7,%d3
    jbeq BADDOVER_4C
    bfextu %a4@,%d6,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a2
    bfextu %a5@,%d0,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a3
    movew %a2@+,%d3
    addw %a3@+,%d3
    asll %d5,%d3
    movew %a2@+,%d3
    addw %a3@+,%d3
    asll %d5,%d3
    movew %a2@+,%d3
    addw %a3@+,%d3
    asll %d5,%d3
    swap %d3
    moveb %a0@(0x6,%d3:w),%d3
    bfins %d3,%a5@,%d0,%d7
BADDOVER_4C:            /* next pixel; end of this part: the middle longs (fp-630), the last long, then the next row (BITBLT_41A) */
    addl %sp@,%d6
    addl %sp@,%d0
    dbf %d2,BADDOVER_16
    moveq #-1,%d1
    bset #0,%fp@(-623)
    jbne BADDOVER_66
    movew %fp@(-630),%d2
    jbmi BADDOVER_8
    jbra BADDOVER_16
BADDOVER_66:            /* last long done too? next row (BITBLT_41A) */
    bset #1,%fp@(-623)
    jbeq BADDOVER_E
    lea %pc@(trap_BADDOVER),%a1
    jbra BITBLT_41A
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082D3B6
BADDOVER_66_1A:         /* BAddOver, 32-bit pixels: a0 = source at offset d6 of the row, a2 = destination; masks 0x7F7F7F and 0x808080 */
    moveal %a4,%a0	| 4082D3C0
    addaw %d6,%a0
    moveal %a5,%a2
    movel #8355711,%d0
    moveal #8421504,%a1
BADDOVER_66_2C:         /* next pixel: each component added modulo 256. The low 7 bits add, the top bits go by xor, so no carry crosses a component */
    movel %a1,%d3	| 4082D3D2
    movel %a0@,%d7
    andl %d7,%d3
    addaw %a3,%a0
    andl %d0,%d7
    movel %a2@,%d5
    movel %a1,%d1
    andl %d5,%d1
    andl %d0,%d5
    addl %d5,%d7
    eorl %d3,%d1
    eorl %d1,%d7
    movel %d7,%a2@
    addaw %a3,%a2
    addql #4,%d6
    andl %d4,%d6
    bnes BADDOVER_66_50
    moveal %a4,%a0
BADDOVER_66_50:         /* next pixel; end: next row */
    dbf %d2,BADDOVER_66_2C	| 4082D3F6
    lea %pc@(BADDOVER_66_1A),%a1
    braw BITBLT_408
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082D402
BADDOVER_66_50_1A:      /* BAddOver, 16-bit pixels: masks 0x3DEF and 0x4210 */
    moveal %a4,%a0	| 4082D410
    addaw %d6,%a0
    moveal %a5,%a2
    movew #15855,%d0
    moveaw #16912,%a1
BADDOVER_66_50_28:      /* next pixel: each 5-bit component added modulo 32, as above */
    movew %a1,%d3	| 4082D41E
    movew %a0@,%d7
    andw %d7,%d3
    addaw %a3,%a0
    andw %d0,%d7
    movew %a2@,%d5
    movew %a1,%d1
    andw %d5,%d1
    andw %d0,%d5
    addw %d5,%d7
    eorw %d3,%d1
    eorw %d1,%d7
    movew %d7,%a2@
    addaw %a3,%a2
    addql #2,%d6
    andl %d4,%d6
    bnes BADDOVER_66_50_4C
    moveal %a4,%a0
BADDOVER_66_50_4C:      /* next pixel; end: next row */
    dbf %d2,BADDOVER_66_50_28	| 4082D442
    lea %pc@(BADDOVER_66_50_1A),%a1
    braw BITBLT_408
    .byte   0x00, 0x00	| 4082D44E

/* BADDPIN: arithmetic transfer mode addpin (BitBlt). */
trap_BADDPIN:
BADDPIN:
    moveal %fp@(-264),%a1
    tstw %d2
    jbgt BADDPIN_16
BADDPIN_8:              /* no middle longs: mark them done */
    orib #3,%fp@(-623)
BADDPIN_E:              /* the last long: its pixel count (fp-632) and the right mask (fp-628) */
    movew %fp@(-632),%d2
    andl %fp@(-628),%d1
BADDPIN_16:             /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %d1,%d0,%d7,%d3
    jbeq BADDPIN_70
    bfextu %a4@,%d6,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a2
    bfextu %a5@,%d0,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a3
    movew %a2@+,%d3
    addw %a3@+,%d3
    jbcs BADDPIN_3C
    cmpw %fp@(-246),%d3
    jbls BADDPIN_40
BADDPIN_3C:             /* pinned at the pin value */
    movew %fp@(-246),%d3
BADDPIN_40:             /* pack the component into the inverse table index */
    asll %d5,%d3
    movew %a2@+,%d3
    addw %a3@+,%d3
    jbcs BADDPIN_4E
    cmpw %fp@(-248),%d3
    jbls BADDPIN_52
BADDPIN_4E:             /* pinned at the pin value */
    movew %fp@(-248),%d3
BADDPIN_52:             /* pack the component into the inverse table index */
    asll %d5,%d3
    movew %a2@+,%d3
    addw %a3@+,%d3
    jbcs BADDPIN_60
    cmpw %fp@(-250),%d3
    jbls BADDPIN_64
BADDPIN_60:             /* pinned at the pin value */
    movew %fp@(-250),%d3
BADDPIN_64:             /* pack the component into the inverse table index */
    asll %d5,%d3
    swap %d3
    moveb %a0@(0x6,%d3:w),%d3
    bfins %d3,%a5@,%d0,%d7
BADDPIN_70:             /* next pixel; end of this part: the middle longs (fp-630), the last long, then the next row (BITBLT_41A) */
    addl %sp@,%d6
    addl %sp@,%d0
    dbf %d2,BADDPIN_16
    moveq #-1,%d1
    bset #0,%fp@(-623)
    jbne BADDPIN_8A
    movew %fp@(-630),%d2
    jbmi BADDPIN_8
    jbra BADDPIN_16
BADDPIN_8A:             /* last long done too? next row (BITBLT_41A) */
    bset #1,%fp@(-623)
    jbeq BADDPIN_E
    lea %pc@(trap_BADDPIN),%a1
    jbra BITBLT_41A
    .long   0x00000000	| 4082D4EC
    lea %pc@(BADDPIN_B4),%a1
    moveq #0,%d3
    moveb %fp@(-246),%d3
    swap %d3
    movew %fp@(-248),%d3
    moveb %fp@(-250),%d3
BADDPIN_B4:             /* 32-bit addPin: each pixel of the row */
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    movel Lo3Bytes,%d1
BADDPIN_BE:             /* add each component, pin */
    movel %a0@,%d7
    andl %d1,%d7
    movel %d7,%d0
    addaw %a3,%a0
    movel %a2@,%d5
    andl %d1,%d5
    clrb %d0
    addw %d5,%d0
    jbcs BADDPIN_D4
    cmpw %d3,%d0
    jbls BADDPIN_D6
BADDPIN_D4:             /* pinned */
    movew %d3,%d0
BADDPIN_D6:             /* next component */
    moveb %d7,%d0
    addb %d5,%d0
    jbcs BADDPIN_E0
    cmpb %d3,%d0
    jbls BADDPIN_E2
BADDPIN_E0:             /* pinned */
    moveb %d3,%d0
BADDPIN_E2:             /* combine the components */
    clrw %d5
    addl %d5,%d0
    cmpl %d3,%d0
    jbls BADDPIN_F4
    swap %d3
    swap %d0
    movew %d3,%d0
    swap %d0
    swap %d3
BADDPIN_F4:             /* store the pixel */
    movel %d0,%a2@
    addaw %a3,%a2
    addql #4,%d6
    andl %d4,%d6
    jbne BADDPIN_100
    moveal %a4,%a0
BADDPIN_100:            /* next pixel; then the 16-bit version */
    dbf %d2,BADDPIN_BE
    jbra BITBLT_408
    .long   0x00000000, 0x00000000	| 4082D558
    lea %pc@(BADDPIN_12A),%a1
    moveq #0,%d3
    moveb %fp@(-246),%d3
    lsrb #3,%d3
    swap %d3
    movew %fp@(-248),%d3
    lsrw #3,%d3
    moveb %fp@(-250),%d3
    lsrb #3,%d3
BADDPIN_12A:            /* 16-bit addPin: each pixel */
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
BADDPIN_130:            /* unpack the 5-bit components, add, pin, repack */
    moveq #0,%d7
    movew %a0@,%d7
    addaw %a3,%a0
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    moveq #0,%d5
    movew %a2@,%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    addl %d5,%d7
    movel %d7,%d0
    cmpl %d3,%d0
    jbls BADDPIN_154
    movel %d3,%d0
BADDPIN_154:            /* next component */
    movew %d7,%d0
    cmpw %d3,%d0
    jbls BADDPIN_15C
    movew %d3,%d0
BADDPIN_15C:            /* next component */
    moveb %d7,%d0
    cmpb %d3,%d0
    jbls BADDPIN_164
    moveb %d3,%d0
BADDPIN_164:            /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a2@
    addaw %a3,%a2
    addql #2,%d6
    andl %d4,%d6
    jbne BADDPIN_176
    moveal %a4,%a0
BADDPIN_176:            /* next pixel */
    dbf %d2,BADDPIN_130
    jbra BITBLT_408
    .short  0x0000	| 4082D5CE

/* BSUBOVER: arithmetic transfer mode subover (BitBlt). */
trap_BSUBOVER:
BSUBOVER:
    moveal %fp@(-264),%a1
    tstw %d2
    jbgt BSUBOVER_16
BSUBOVER_8:             /* no middle longs: mark them done */
    orib #3,%fp@(-623)
BSUBOVER_E:             /* the last long: its pixel count (fp-632) and the right mask (fp-628) */
    movew %fp@(-632),%d2
    andl %fp@(-628),%d1
BSUBOVER_16:            /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %d1,%d0,%d7,%d3
    jbeq BSUBOVER_4C
    bfextu %a4@,%d6,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a2
    bfextu %a5@,%d0,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a3
    movew %a3@+,%d3
    subw %a2@+,%d3
    asll %d5,%d3
    movew %a3@+,%d3
    subw %a2@+,%d3
    asll %d5,%d3
    movew %a3@+,%d3
    subw %a2@+,%d3
    asll %d5,%d3
    swap %d3
    moveb %a0@(0x6,%d3:w),%d3
    bfins %d3,%a5@,%d0,%d7
BSUBOVER_4C:            /* next pixel; end of this part: the middle longs (fp-630), the last long, then the next row (BITBLT_41A) */
    addl %sp@,%d6
    addl %sp@,%d0
    dbf %d2,BSUBOVER_16
    moveq #-1,%d1
    bset #0,%fp@(-623)
    jbne BSUBOVER_66
    movew %fp@(-630),%d2
    jbmi BSUBOVER_8
    jbra BSUBOVER_16
BSUBOVER_66:            /* last long done too? next row (BITBLT_41A) */
    bset #1,%fp@(-623)
    jbeq BSUBOVER_E
    lea %pc@(trap_BSUBOVER),%a1
    jbra BITBLT_41A
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082D646
    /* BSubOver, 32-bit pixels: a0 = source at offset d6, a2 = destination; masks 0x7F7F7F and 0x808080 */
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    movel #8355711,%d0
    movel #8421504,%d1
BSUBOVER_66_2C:         /* next pixel: destination minus source, each component modulo 256. d4 is used as scratch, so the wrap mask comes from fp-140 */
    movel %d1,%d3	| 4082D662
    movel %a0@,%d7
    andl %d7,%d3
    eorl %d1,%d3
    addaw %a3,%a0
    andl %d0,%d7
    movel %a2@,%d5
    movel %d1,%d4
    andl %d5,%d4
    andl %d0,%d5
    orl %d1,%d5
    subl %d7,%d5
    eorl %d3,%d4
    eorl %d4,%d5
    movel %d5,%a2@
    addaw %a3,%a2
    addql #4,%d6
    andw %fp@(-140),%d6
    bnes BSUBOVER_66_56
    moveal %a4,%a0
BSUBOVER_66_56:         /* next pixel; end: next row */
    dbf %d2,BSUBOVER_66_2C	| 4082D68C
    braw BITBLT_408
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082D694
    /* BSubOver, 16-bit pixels: masks 0x3DEF and 0x4210 */
    moveal %a4,%a0	| 4082D6A0
    addaw %d6,%a0
    moveal %a5,%a2
    movew #15855,%d0
    movew #16912,%d1
BSUBOVER_66_56_22:      /* next pixel: destination minus source, each 5-bit component modulo 32 */
    movew %d1,%d3	| 4082D6AE
    movew %a0@,%d7
    addaw %a3,%a0
    andw %d7,%d3
    eorw %d1,%d3
    andw %d0,%d7
    movel %a2@,%d5
    movew %d1,%d4
    andw %d5,%d4
    andw %d0,%d5
    orw %d1,%d5
    subw %d7,%d5
    eorw %d3,%d4
    eorw %d4,%d5
    movew %d5,%a2@
    addaw %a3,%a2
    addql #2,%d6
    andw %fp@(-140),%d6
    bnes BSUBOVER_66_56_4C
    moveal %a4,%a0
BSUBOVER_66_56_4C:      /* next pixel; end: next row */
    dbf %d2,BSUBOVER_66_56_22	| 4082D6D8
    braw BITBLT_408

/* BSUBPIN: arithmetic transfer mode subpin (BitBlt). */
trap_BSUBPIN:
BSUBPIN:
    moveal %fp@(-264),%a1
    tstw %d2
    jbgt BSUBPIN_16
BSUBPIN_8:              /* no middle longs: mark them done */
    orib #3,%fp@(-623)
BSUBPIN_E:              /* the last long: its pixel count (fp-632) and the right mask (fp-628) */
    movew %fp@(-632),%d2
    andl %fp@(-628),%d1
BSUBPIN_16:             /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %d1,%d0,%d7,%d3
    jbeq BSUBPIN_70
    bfextu %a4@,%d6,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a2
    bfextu %a5@,%d0,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a3
    movew %a3@+,%d3
    subw %a2@+,%d3
    jbcs BSUBPIN_3C
    cmpw %fp@(-246),%d3
    jbcc BSUBPIN_40
BSUBPIN_3C:             /* pinned at the pin value */
    movew %fp@(-246),%d3
BSUBPIN_40:             /* pack the component into the inverse table index */
    asll %d5,%d3
    movew %a3@+,%d3
    subw %a2@+,%d3
    jbcs BSUBPIN_4E
    cmpw %fp@(-248),%d3
    jbcc BSUBPIN_52
BSUBPIN_4E:             /* pinned at the pin value */
    movew %fp@(-248),%d3
BSUBPIN_52:             /* pack the component into the inverse table index */
    asll %d5,%d3
    movew %a3@+,%d3
    subw %a2@+,%d3
    jbcs BSUBPIN_60
    cmpw %fp@(-250),%d3
    jbcc BSUBPIN_64
BSUBPIN_60:             /* pinned at the pin value */
    movew %fp@(-250),%d3
BSUBPIN_64:             /* pack the component into the inverse table index */
    asll %d5,%d3
    swap %d3
    moveb %a0@(0x6,%d3:w),%d3
    bfins %d3,%a5@,%d0,%d7
BSUBPIN_70:             /* next pixel; end of this part: the middle longs (fp-630), the last long, then the next row (BITBLT_41A) */
    addl %sp@,%d6
    addl %sp@,%d0
    dbf %d2,BSUBPIN_16
    moveq #-1,%d1
    bset #0,%fp@(-623)
    jbne BSUBPIN_8A
    movew %fp@(-630),%d2
    jbmi BSUBPIN_8
    jbra BSUBPIN_16
BSUBPIN_8A:             /* last long done too? next row (BITBLT_41A) */
    bset #1,%fp@(-623)
    jbeq BSUBPIN_E
    lea %pc@(trap_BSUBPIN),%a1
    jbra BITBLT_41A
    .long   0x00000000	| 4082D77C
    lea %pc@(BSUBPIN_B4),%a1
    moveq #0,%d3
    moveb %fp@(-246),%d3
    swap %d3
    movew %fp@(-248),%d3
    moveb %fp@(-250),%d3
BSUBPIN_B4:             /* 32-bit subPin: each pixel */
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    movel Lo3Bytes,%d1
BSUBPIN_BE:             /* subtract each component, pin */
    movel %a0@,%d5
    andl %d1,%d5
    addaw %a3,%a0
    movel %a2@,%d7
    andl %d1,%d7
    movel %d7,%d0
    st %d0
    subw %d5,%d0
    jbcs BSUBPIN_D4
    cmpw %d3,%d0
    jbcc BSUBPIN_D6
BSUBPIN_D4:             /* pinned */
    movew %d3,%d0
BSUBPIN_D6:             /* next component */
    moveb %d7,%d0
    subb %d5,%d0
    jbcs BSUBPIN_E0
    cmpb %d3,%d0
    jbcc BSUBPIN_E2
BSUBPIN_E0:             /* pinned */
    moveb %d3,%d0
BSUBPIN_E2:             /* combine the components */
    clrw %d5
    subl %d5,%d0
    cmpl %d3,%d0
    jbge BSUBPIN_F4
    swap %d3
    swap %d0
    movew %d3,%d0
    swap %d0
    swap %d3
BSUBPIN_F4:             /* store the pixel */
    movel %d0,%a2@
    addaw %a3,%a2
    addql #4,%d6
    andl %d4,%d6
    jbne BSUBPIN_100
    moveal %a4,%a0
BSUBPIN_100:            /* next pixel; then the 16-bit version */
    dbf %d2,BSUBPIN_BE
    jbra BITBLT_408
    .long   0x00000000, 0x00000000	| 4082D7E8
    lea %pc@(BSUBPIN_130),%a1
    moveq #0,%d3
    moveb %fp@(-246),%d3
    lsrb #3,%d3
    swap %d3
    movew %fp@(-248),%d3
    lsrw #3,%d3
    moveb %fp@(-250),%d3
    lsrb #3,%d3
    addil #8421504,%d3
BSUBPIN_130:            /* 16-bit subPin: each pixel */
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    movel #8421504,%d1
BSUBPIN_13C:            /* unpack, subtract, pin, repack */
    moveq #0,%d5
    movew %a0@,%d5
    addaw %a3,%a0
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    moveq #0,%d7
    movew %a2@,%d7
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    addl %d1,%d7
    subl %d5,%d7
    movel %d7,%d0
    cmpl %d3,%d0
    jbcc BSUBPIN_162
    movel %d3,%d0
BSUBPIN_162:            /* next component */
    movew %d7,%d0
    cmpw %d3,%d0
    jbcc BSUBPIN_16A
    movew %d3,%d0
BSUBPIN_16A:            /* next component */
    moveb %d7,%d0
    cmpb %d3,%d0
    jbcc BSUBPIN_172
    moveb %d3,%d0
BSUBPIN_172:            /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a2@
    addaw %a3,%a2
    addql #2,%d6
    andl %d4,%d6
    jbne BSUBPIN_184
    moveal %a4,%a0
BSUBPIN_184:            /* next pixel */
    dbf %d2,BSUBPIN_13C
    jbra BITBLT_408
    .long   0x00000000	| 4082D86C

/* BMAX: arithmetic transfer mode max (BitBlt). */
trap_BMAX:
BMAX:
    moveal %fp@(-264),%a1
    tstw %d2
    jbgt BMAX_16
BMAX_8:                 /* no middle longs: mark them done */
    orib #3,%fp@(-623)
BMAX_E:                 /* the last long: its pixel count (fp-632) and the right mask (fp-628) */
    movew %fp@(-632),%d2
    andl %fp@(-628),%d1
BMAX_16:                /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %d1,%d0,%d7,%d3
    jbeq BMAX_5C
    bfextu %a4@,%d6,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a2
    bfextu %a5@,%d0,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a3
    movew %a2@+,%d3
    cmpw %a3@,%d3
    jbcc BMAX_38
    movew %a3@,%d3
BMAX_38:                /* next component */
    addqw #2,%a3
    asll %d5,%d3
    movew %a2@+,%d3
    cmpw %a3@,%d3
    jbcc BMAX_44
    movew %a3@,%d3
BMAX_44:                /* next component */
    addqw #2,%a3
    asll %d5,%d3
    movew %a2@+,%d3
    cmpw %a3@,%d3
    jbcc BMAX_50
    movew %a3@,%d3
BMAX_50:                /* pack the component into the inverse table index */
    asll %d5,%d3
    swap %d3
    moveb %a0@(0x6,%d3:w),%d3
    bfins %d3,%a5@,%d0,%d7
BMAX_5C:                /* next pixel; end of this part: the middle longs (fp-630), the last long, then the next row (BITBLT_41A) */
    addl %sp@,%d6
    addl %sp@,%d0
    dbf %d2,BMAX_16
    moveq #-1,%d1
    bset #0,%fp@(-623)
    jbne BMAX_76
    movew %fp@(-630),%d2
    jbmi BMAX_8
    jbra BMAX_16
BMAX_76:                /* last long done too? next row (BITBLT_41A) */
    bset #1,%fp@(-623)
    jbeq BMAX_E
    lea %pc@(trap_BMAX),%a1
    jbra BITBLT_41A
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082D8F6
    /* BMax, 32-bit pixels: a0 = source at offset d6, a2 = destination */
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
BMAX_76_20:             /* next pixel: the larger of each component. Green by a word compare, blue by a byte compare */
    movel %a0@,%d7	| 4082D906
    addaw %a3,%a0
    movel %a2@,%d5
    movel %d5,%d0
    cmpw %d7,%d0
    bhis BMAX_76_30
    movew %d7,%d0
    moveb %d5,%d0
BMAX_76_30:
    cmpb %d7,%d5	| 4082D916
    bhis BMAX_76_36
    moveb %d7,%d0
BMAX_76_36:             /* red, after swapping the words */
    swap %d7	| 4082D91C
    swap %d0
    cmpb %d7,%d0
    bhis BMAX_76_40
    moveb %d7,%d0
BMAX_76_40:             /* store; the top byte stays the destination's */
    swap %d0	| 4082D926
    movel %d0,%a2@
    addaw %a3,%a2
    addql #4,%d6
    andl %d4,%d6
    bnes BMAX_76_4E
    moveal %a4,%a0
BMAX_76_4E:             /* next pixel; end: next row */
    dbf %d2,BMAX_76_20	| 4082D934
    braw BITBLT_408
    .byte   0x00, 0x00, 0x00, 0x00	| 4082D93C
    /* BMax, 16-bit pixels */
    moveal %a4,%a0	| 4082D940
    addaw %d6,%a0
    moveal %a5,%a2
BMAX_76_4E_12:          /* next pixel: source and destination spread from 5-5-5 to one byte per component */
    moveq #0,%d7	| 4082D946
    movew %a0@,%d7
    addaw %a3,%a0
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    moveq #0,%d5
    movew %a2@,%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    movel %d7,%d0
    cmpl %d5,%d0
    bccs BMAX_76_4E_34
    movel %d5,%d0
BMAX_76_4E_34:          /* green (the red was compared as a long) */
    movew %d7,%d0	| 4082D968
    cmpw %d5,%d0
    bccs BMAX_76_4E_3C
    movew %d5,%d0
BMAX_76_4E_3C:          /* blue */
    moveb %d7,%d0	| 4082D970
    cmpb %d5,%d0
    bccs BMAX_76_4E_44
    moveb %d5,%d0
BMAX_76_4E_44:          /* back to 5-5-5, store */
    lslb #3,%d0	| 4082D978
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a2@
    addaw %a3,%a2
    addql #2,%d6
    andl %d4,%d6
    bnes BMAX_76_4E_56
    moveal %a4,%a0
BMAX_76_4E_56:          /* next pixel; end: next row */
    dbf %d2,BMAX_76_4E_12	| 4082D98A
    braw BITBLT_408
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082D992

/* BMIN: arithmetic transfer mode min (BitBlt). */
trap_BMIN:
BMIN:
    moveal %fp@(-264),%a1
    tstw %d2
    jbgt BMIN_16
BMIN_8:                 /* no middle longs: mark them done */
    orib #3,%fp@(-623)
BMIN_E:                 /* the last long: its pixel count (fp-632) and the right mask (fp-628) */
    movew %fp@(-632),%d2
    andl %fp@(-628),%d1
BMIN_16:                /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %d1,%d0,%d7,%d3
    jbeq BMIN_5C
    bfextu %a4@,%d6,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a2
    bfextu %a5@,%d0,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a3
    movew %a2@+,%d3
    cmpw %a3@,%d3
    jbls BMIN_38
    movew %a3@,%d3
BMIN_38:                /* next component */
    addqw #2,%a3
    asll %d5,%d3
    movew %a2@+,%d3
    cmpw %a3@,%d3
    jbls BMIN_44
    movew %a3@,%d3
BMIN_44:                /* next component */
    addqw #2,%a3
    asll %d5,%d3
    movew %a2@+,%d3
    cmpw %a3@,%d3
    jbls BMIN_50
    movew %a3@,%d3
BMIN_50:                /* pack the component into the inverse table index */
    asll %d5,%d3
    swap %d3
    moveb %a0@(0x6,%d3:w),%d3
    bfins %d3,%a5@,%d0,%d7
BMIN_5C:                /* next pixel; end of this part: the middle longs (fp-630), the last long, then the next row (BITBLT_41A) */
    addl %sp@,%d6
    addl %sp@,%d0
    dbf %d2,BMIN_16
    moveq #-1,%d1
    bset #0,%fp@(-623)
    jbne BMIN_76
    movew %fp@(-630),%d2
    jbmi BMIN_8
    jbra BMIN_16
BMIN_76:                /* last long done too? next row (BITBLT_41A) */
    bset #1,%fp@(-623)
    jbeq BMIN_E
    lea %pc@(trap_BMIN),%a1
    jbra BITBLT_41A
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082DA26
    /* BMin, 32-bit pixels: a0 = source at offset d6, a2 = destination */
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
BMIN_76_20:             /* next pixel: the smaller of each component. Green by a word compare, blue by a byte compare */
    movel %a0@,%d7	| 4082DA36
    addaw %a3,%a0
    movel %a2@,%d5
    movel %d5,%d0
    cmpw %d7,%d0
    blss BMIN_76_30
    movew %d7,%d0
    moveb %d5,%d0
BMIN_76_30:
    cmpb %d7,%d5	| 4082DA46
    blss BMIN_76_36
    moveb %d7,%d0
BMIN_76_36:             /* red, after swapping the words */
    swap %d7	| 4082DA4C
    swap %d0
    cmpb %d7,%d0
    blss BMIN_76_40
    moveb %d7,%d0
BMIN_76_40:             /* store; the top byte stays the destination's */
    swap %d0	| 4082DA56
    movel %d0,%a2@
    addaw %a3,%a2
    addql #4,%d6
    andl %d4,%d6
    bnes BMIN_76_4E
    moveal %a4,%a0
BMIN_76_4E:             /* next pixel; end: next row */
    dbf %d2,BMIN_76_20	| 4082DA64
    braw BITBLT_408
    .byte   0x00, 0x00, 0x00, 0x00	| 4082DA6C
    /* BMin, 16-bit pixels */
    moveal %a4,%a0	| 4082DA70
    addaw %d6,%a0
    moveal %a5,%a2
BMIN_76_4E_12:          /* next pixel: source and destination spread from 5-5-5 to one byte per component */
    moveq #0,%d7	| 4082DA76
    movew %a0@,%d7
    addaw %a3,%a0
    addw %d7,%d7
    lsll #5,%d7
    lsrw #3,%d7
    lsrb #3,%d7
    moveq #0,%d5
    movew %a2@,%d5
    addw %d5,%d5
    lsll #5,%d5
    lsrw #3,%d5
    lsrb #3,%d5
    movel %d7,%d0
    cmpl %d5,%d0
    blss BMIN_76_4E_34
    movel %d5,%d0
BMIN_76_4E_34:          /* green (the red was compared as a long) */
    movew %d7,%d0	| 4082DA98
    cmpw %d5,%d0
    blss BMIN_76_4E_3C
    movew %d5,%d0
BMIN_76_4E_3C:          /* blue */
    moveb %d7,%d0	| 4082DAA0
    cmpb %d5,%d0
    blss BMIN_76_4E_44
    moveb %d5,%d0
BMIN_76_4E_44:          /* back to 5-5-5, store */
    lslb #3,%d0	| 4082DAA8
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a2@
    addaw %a3,%a2
    addql #2,%d6
    andl %d4,%d6
    bnes BMIN_76_4E_56
    moveal %a4,%a0
BMIN_76_4E_56:          /* next pixel; end: next row */
    dbf %d2,BMIN_76_4E_12	| 4082DABA
    braw BITBLT_408
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082DAC2

/* BAVG: arithmetic transfer mode avg (BitBlt). */
trap_BAVG:
BAVG:
    moveal %fp@(-264),%a1
    tstw %d2
    jbgt BAVG_16
BAVG_8:                 /* no middle longs: mark them done */
    orib #3,%fp@(-623)
BAVG_E:                 /* the last long: its pixel count (fp-632) and the right mask (fp-628) */
    movew %fp@(-632),%d2
    andl %fp@(-628),%d1
BAVG_16:                /* next pixel (indexed): inside the region mask? source and destination RGB from the color table */
    andw %fp@(-140),%d6
    bfextu %d1,%d0,%d7,%d3
    jbeq BAVG_6E
    bfextu %a4@,%d6,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a2
    bfextu %a5@,%d0,%d7,%d3
    lea %a1@(0x0,%d3:w:8),%a3
    movew %d0,%sp@-
    moveq #2,%d0
    movew %fp@(-270),%d4
    addw %d4,%d4
    clrw %sp@-
BAVG_3C:                /* each of R, G, B: weighted average (blend) */
    movew %a2@+,%d3
    muluw %fp@(0xffffffffffffff06,%d0:w:2),%d3
    movew %a3@+,%d5
    muluw %fp@(0xffffffffffffff00,%d0:w:2),%d5
    addl %d5,%d3
    swap %d3
    movew %fp@(-272),%d5
    lsrw %d5,%d3
    lslw %d4,%d3
    orw %d3,%sp@
    subw %fp@(-270),%d4
    dbf %d0,BAVG_3C
    movew %sp@+,%d3
    movew %sp@+,%d0
    moveb %a0@(0x6,%d3:w),%d3
    bfins %d3,%a5@,%d0,%d7
BAVG_6E:                /* next pixel; end of this part: the middle longs (fp-630), the last long, then the next row (BITBLT_41A) */
    addl %sp@,%d6
    addl %sp@,%d0
    dbf %d2,BAVG_16
    moveq #-1,%d1
    bset #0,%fp@(-623)
    jbne BAVG_88
    movew %fp@(-630),%d2
    jbmi BAVG_8
    jbra BAVG_16
BAVG_88:                /* last long done too? next row (BITBLT_41A) */
    bset #1,%fp@(-623)
    jbeq BAVG_E
    moveal 0x1b40,%a1
    jbra BITBLT_41A
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082DB6A
    /* BAvg, 32-bit pixels: masks 0x7F7F7F and 0x010101 */
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    movel #8355711,%d0
    movel #65793,%d1
BAVG_88_2A:             /* (BitBlt blend at 50%, 32-bit) each pixel: (a >> 1) + (b >> 1) plus the low-bit carry */
    movel %d1,%d3
    movel %a0@,%d7
    andl %d7,%d3
    addaw %a3,%a0
    lsrl #1,%d7
    andl %d0,%d7
    movel %a2@,%d5
    andl %d5,%d3
    lsrl #1,%d5
    andl %d0,%d5
    addl %d5,%d7
    addl %d3,%d7
    movel %d7,%a2@
    addaw %a3,%a2
    addql #4,%d6
    andl %d4,%d6
    bnes BAVG_88_4E
    moveal %a4,%a0
BAVG_88_4E:             /* next pixel; next row (BITBLT_408); then the 16-bit version */
    dbf %d2,BAVG_88_2A
    braw BITBLT_408
    .byte   0x00, 0x00	| 4082DBAE
    /* BAvg, 16-bit pixels: masks 0x3DEF and 0x0421 */
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    movew #15855,%d0
    movew #1057,%d1
BAVG_88_66:             /* 16-bit blend at 50%: each pixel */
    movel %d1,%d3
    movew %a0@,%d7
    andw %d7,%d3
    addaw %a3,%a0
    lsrw #1,%d7
    andw %d0,%d7
    movew %a2@,%d5
    andw %d5,%d3
    lsrw #1,%d5
    andw %d0,%d5
    addw %d5,%d7
    addw %d3,%d7
    movew %d7,%a2@
    addaw %a3,%a2
    addql #2,%d6
    andl %d4,%d6
    bnes BAVG_88_8A
    moveal %a4,%a0
BAVG_88_8A:             /* next; then the weighted 32-bit blend */
    dbf %d2,BAVG_88_66
    braw BITBLT_408
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082DBEA
BAVG_88_8A_E:           /* BAvg, weighted blend: the weights from the op color (fp-250) */
    lea %fp@(-250),%a0	| 4082DBF0
    movel %a0@+,%d1
    movew %a0@,%d0
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    moveq #0,%d4
    movel %d4,%d3
    moveal %d4,%a1
BAVG_88_AC:             /* each pixel: same as the last? reuse the result */
    movel %a0@,%d7
    addaw %a3,%a0
    movel %a2@,%d5
    cmpl %d3,%d7
    bnes BAVG_88_BA
    cmpl %a1,%d5
    beqs BAVG_88_10C
BAVG_88_BA:             /* each component weighted */
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
    moveaw %d4,%a1
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
    addaw %d4,%a1
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
    movew %a1,%d4
    swap %d5
    moveal %d5,%a1
    swap %d7
    movel %d7,%d3
BAVG_88_10C:            /* store; the pattern/source row wraps */
    movel %d4,%a2@
    addaw %a3,%a2
    addqw #4,%d6
    andw %fp@(-140),%d6
    bnes BAVG_88_11A
    moveal %a4,%a0
BAVG_88_11A:            /* next pixel; then the weighted 16-bit blend */
    dbf %d2,BAVG_88_AC
    lea %pc@(BAVG_88_8A_E),%a1	| 4082DC76
    braw BITBLT_408
    .byte   0x00, 0x00	| 4082DC7E
BAVG_88_11A_E:          /* BAvg, weighted blend: the weights from the op color (fp-250) */
    lea %fp@(-250),%a0	| 4082DC80
    movel %a0@+,%d1
    movew %a0@,%d0
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    moveq #0,%d4
    movel %d4,%d3
    moveal %d4,%a1
BAVG_88_13C:            /* each pixel: same as the last? reuse */
    moveq #0,%d7
    movew %a0@,%d7
    addaw %a3,%a0
    moveq #0,%d5
    movew %a2@,%d5
    cmpw %d3,%d7
    bnes BAVG_88_14E
    cmpw %a1,%d5
    beqs BAVG_88_1C0
BAVG_88_14E:            /* unpack the 5-bit components, weight them */
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
    moveal %d4,%a1
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
    addaw %d4,%a1
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
    addw %a1,%d4
    swap %d5
    lslb #3,%d5
    lslw #3,%d5
    lsrl #6,%d5
    moveal %d5,%a1
    swap %d7
    lslb #3,%d7
    lslw #3,%d7
    lsrl #6,%d7
    movel %d7,%d3
BAVG_88_1C0:            /* store; wrap */
    movew %d4,%a2@
    addaw %a3,%a2
    addqw #2,%d6
    andw %fp@(-140),%d6
    bnes BAVG_88_1CE
    moveal %a4,%a0
BAVG_88_1CE:            /* next pixel; next row */
    dbf %d2,BAVG_88_13C
    lea %pc@(BAVG_88_11A_E),%a1	| 4082DD2A
    braw BITBLT_408
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082DD32

/* BHILITE: arithmetic transfer mode hilite (BitBlt). */
trap_BHILITE:
BHILITE:
    subqw #1,%d2
    jbmi BHILITE_16
    jbsr BHILITE_50
    subqw #1,%d2
    jbmi BHILITE_14
BHILITE_A:              /* a whole long of background? hilite color */
    cmpl %a5@,%d4
    jbne BHILITE_20
BHILITE_E:              /* store */
    movel %a0,%a5@+
BHILITE_10:             /* count down (loop) */
    dbf %d2,BHILITE_A
BHILITE_14:             /* middle longs: full mask; first time: their count (fp-630) */
    moveq #-1,%d1
BHILITE_16:             /* the last long through the right mask */
    andl %fp@(-628),%d1
    jbsr BHILITE_50
    jbra BITBLT_3C4
BHILITE_20:             /* a whole long of hilite? background */
    cmpal %a5@,%a0
    jbeq BHILITE_44
    movel %a2,%d6
BHILITE_26:             /* pixel by pixel */
    bfextu %a5@,%d6,%d7,%d3
    cmpl %d3,%d0
    jbne BHILITE_34
    bfins %d5,%a5@,%d6,%d7
    jbra BHILITE_3C
BHILITE_34:             /* the background color? becomes hilite */
    cmpl %d5,%d3
    jbne BHILITE_3C
    bfins %d0,%a5@,%d6,%d7
BHILITE_3C:             /* next pixel of the long */
    subw %d7,%d6
    jbpl BHILITE_26
    addqw #4,%a5
    jbra BHILITE_10
BHILITE_44:             /* swap the colors for the store */
    bfextu %d4,0,%d7,%d5
    exg %d4,%a0
    bfextu %d4,0,%d7,%d0
    jbra BHILITE_E

BHILITE_50:             /* a masked long: all background or all hilite? */
    movel %d4,%d3
    andl %d1,%d3
    movel %a5@,%d6
    andl %d1,%d6
    cmpl %d3,%d6
    jbne BHILITE_6A
    movel %a0,%d3
    andl %d1,%d3
    notl %d1
    andl %a5@,%d1
    orl %d3,%d1
    movel %d1,%a5@+
    rts
BHILITE_6A:             /* pixel by pixel */
    movel %a2,%d6
BHILITE_6C:             /* inside the mask: swap the colors */
    bfextu %d1,%d6,%d7,%d3
    jbeq BHILITE_88
    bfextu %a5@,%d6,%d7,%d3
    cmpl %d3,%d0
    jbne BHILITE_80
    bfins %d5,%a5@,%d6,%d7
    jbra BHILITE_88
BHILITE_80:             /* the background color? becomes hilite */
    cmpl %d5,%d3
    jbne BHILITE_88
    bfins %d0,%a5@,%d6,%d7
BHILITE_88:             /* next pixel of the long */
    subw %d7,%d6
    jbpl BHILITE_6C
    addqw #4,%a5
    rts
    moveq #-1,%d0
    lsrl #8,%d0
    movew %d2,%d3
BHILITE_88_E:           /* (BitBlt fast hilite) each row */
    movew %d3,%d2
BHILITE_88_10:          /* each long: background? hilite color */
    movel %d0,%d1
    andl %a5@,%d1
    cmpl %d1,%d4
    bnes BHILITE_88_20
BHILITE_88_18:          /* store */
    movel %a0,%a5@+
    dbf %d2,BHILITE_88_10
    bras BHILITE_88_2E
BHILITE_88_20:          /* hilite color? background */
    cmpal %d1,%a0
    bnes BHILITE_88_28
    exg %d4,%a0
    bras BHILITE_88_18
BHILITE_88_28:          /* neither: leave it */
    addqw #4,%a5
    dbf %d2,BHILITE_88_10
BHILITE_88_2E:          /* next row */
    addaw %a3,%a5
    subqw #1,%fp@(-608)
    bnes BHILITE_88_E
    braw BITBLT_3F0
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082DE02

/* BSLOHILITE: arithmetic transfer mode slohilite (BitBlt). */
trap_BSLOHILITE:
BSLOHILITE:
    bfextu %d4,0,%d7,%d4
    cmpiw #32,%d7
    jbeq BSLOHILITE_1C
    tstw %d2
    jbgt BSLOHILITE_1C
BSLOHILITE_E:           /* no middle longs: mark them done */
    orib #3,%fp@(-623)
BSLOHILITE_14:          /* the last long: its pixel count (fp-632) and the right mask (fp-628) */
    movew %fp@(-632),%d2
    andl %fp@(-628),%d1
BSLOHILITE_1C:          /* next pixel: inside the region mask? a source pixel that is not the background: a background destination becomes the hilite color */
    andw %fp@(-140),%d6
    bfextu %d1,%d0,%d7,%d3
    jbeq BSLOHILITE_44
    bfextu %a4@,%d6,%d7,%d3
    cmpl %d3,%d4
    jbeq BSLOHILITE_44
    bfextu %a5@,%d0,%d7,%d3
    cmpl %d3,%d4
    jbne BSLOHILITE_3C
    bfins %d5,%a5@,%d0,%d7
    jbra BSLOHILITE_44
BSLOHILITE_3C:          /* the background color? becomes hilite */
    cmpl %d5,%d3
    jbne BSLOHILITE_44
    bfins %d4,%a5@,%d0,%d7
BSLOHILITE_44:          /* next pixel; end of this part: the middle longs (fp-630), the last long, then the next row (BITBLT_41A) */
    addl %sp@,%d6
    addl %sp@,%d0
    dbf %d2,BSLOHILITE_1C
    moveq #-1,%d1
    bset #0,%fp@(-623)
    jbne BSLOHILITE_5E
    movew %fp@(-630),%d2
    jbmi BSLOHILITE_E
    jbra BSLOHILITE_1C
BSLOHILITE_5E:          /* last long done too? next row (BITBLT_41A) */
    bset #1,%fp@(-623)
    jbeq BSLOHILITE_14
    jbra BITBLT_41A
    .short  0x0000, 0x0000, 0x0000	| 4082DE7A

/* BTRANSPARENT: arithmetic transfer mode transparent (BitBlt). */
trap_BTRANSPARENT:
BTRANSPARENT:
    cmpiw #32,%d7
    jbeq BTRANSPARENT_18
    tstw %d2
    jbgt BTRANSPARENT_18
BTRANSPARENT_A:         /* no middle longs: mark them done */
    orib #3,%fp@(-623)
BTRANSPARENT_10:        /* the last long: its pixel count (fp-632) and the right mask (fp-628) */
    movew %fp@(-632),%d2
    andl %fp@(-628),%d1
BTRANSPARENT_18:        /* next pixel: a whole long of the background color is skipped; inside the region mask and not the background: insert it */
    andw %fp@(-140),%d6
    bfextu %a4@,%d6,0,%d3
    cmpl %d3,%d4
    jbeq BTRANSPARENT_40
    bfextu %d1,%d0,%d7,%d3
    jbeq BTRANSPARENT_36
    bfextu %a4@,%d6,%d7,%d3
    cmpal %d3,%a3
    jbeq BTRANSPARENT_36
    bfins %d3,%a5@,%d0,%d7
BTRANSPARENT_36:        /* next pixel; end of this part: the middle longs (fp-630), the last long, then the next row (BITBLT_41A) */
    addl %sp@,%d6
    addl %sp@,%d0
    dbf %d2,BTRANSPARENT_18
    jbra BTRANSPARENT_4A
BTRANSPARENT_40:        /* pattern pixel is the background color: skip it */
    addl %a2,%d6
    addl %a2,%d0
    subw %fp@(-646),%d2
    jbge BTRANSPARENT_18
BTRANSPARENT_4A:        /* skip back the extra pixels */
    addqw #1,%d2
    jbeq BTRANSPARENT_54
    subl %sp@,%d6
    subl %sp@,%d0
    jbra BTRANSPARENT_4A
BTRANSPARENT_54:        /* middle longs: full mask; first time: their count (fp-630) */
    moveq #-1,%d1
    bset #0,%fp@(-623)
    jbne BTRANSPARENT_66
    movew %fp@(-630),%d2
    jbmi BTRANSPARENT_A
    jbra BTRANSPARENT_18
BTRANSPARENT_66:        /* last long done too? next row (BITBLT_41A) */
    bset #1,%fp@(-623)
    jbeq BTRANSPARENT_10
    jbra BITBLT_41A
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082DEF2
    /* BTransparent, 32-bit pixels: the transparent color (fp-164), mask Lo3Bytes */
    movel %fp@(-164),%d3
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    movel Lo3Bytes,%d0
BTRANSPARENT_66_28:     /* next pixel: stored unless it is the transparent color */
    movel %a0@,%d7	| 4082DF0E
    addaw %a3,%a0
    andl %d0,%d7
    cmpl %d3,%d7
    beqs BTRANSPARENT_66_34
    movel %d7,%a2@
BTRANSPARENT_66_34:     /* next destination pixel; the source offset wraps (d4): back to the start of the row */
    addaw %a3,%a2	| 4082DF1A
    addql #4,%d6
    andl %d4,%d6
    bnes BTRANSPARENT_66_3E
    moveal %a4,%a0
BTRANSPARENT_66_3E:     /* next pixel; end: next row */
    dbf %d2,BTRANSPARENT_66_28	| 4082DF24
    braw BITBLT_408
    .byte   0x00, 0x00, 0x00, 0x00	| 4082DF2C
    /* BTransparent, 16-bit pixels: the transparent color (fp-164), mask 0x7FFF */
    movel %fp@(-164),%d3	| 4082DF30
    moveal %a4,%a0
    addaw %d6,%a0
    moveal %a5,%a2
    moveq #-1,%d0
    lsrw #1,%d0
BTRANSPARENT_66_3E_1A:  /* next pixel: stored unless it is the transparent color */
    movew %a0@,%d7	| 4082DF3E
    addaw %a3,%a0
    andw %d0,%d7
    cmpw %d3,%d7
    beqs BTRANSPARENT_66_3E_26
    movew %d7,%a2@
BTRANSPARENT_66_3E_26:  /* next destination pixel; the source offset wraps (d4): back to the start of the row */
    addaw %a3,%a2	| 4082DF4A
    addql #2,%d6
    andl %d4,%d6
    bnes BTRANSPARENT_66_3E_30
    moveal %a4,%a0
BTRANSPARENT_66_3E_30:  /* next pixel; end: next row */
    dbf %d2,BTRANSPARENT_66_3E_1A	| 4082DF54
    braw BITBLT_408
    .ascii  "(c) Apple Computer Inc., 1983-1989\000\000"

/*
 CRSRCORE: the cursor core. INITCRTABLE holds the offsets from CRSRCORE of the routines
 copied into the cursor jump vectors at 0x800: HideCursor (+0x2F0), ShowCursor (+0x322),
 ShieldCursor (+0x362), ScrnAddress (+0xAC0), ScrnSize (+0xAD0), InitCursor (+0x310),
 SetCursor (+0x52A), ObscureCursor (+0x2E2), AllocCursor (+0x5F0), SetCCursor (+0x3C4).
 Cursor state is in low memory: CrsrBusy (0x8CD, set while the cursor data is being changed
 so the VBL task leaves it alone), CrsrObscure, CrsrState (0 = visible, negative = hidden
 levels), ShieldRect (0xD44) and ShieldDepth (0xD4C), CrsrPtr (0xD62, handle to the cursor
 save record), CrsrDevice (0x89C), CrsrPin, CrsrRect.
*/
CRSRCORE:
INITCRTABLE:
    .long   0x02F00322, 0x03620AC0, 0x0AD00310, 0x052A02E2	| 4082DF80
    .long   0x05F003C4	| 4082DF90

/*
 CRSRVBLTASK: the cursor VBL task: follow the mouse. The first instruction branches to the
 second half (CRSRVBLTASK_12E); the code after it is the original mouse movement with
 acceleration (MickeyBytes table); no branch in this file reaches it. The
 task does not run in the Quadra 800 traces.
*/
thunk_FUN_4082e0c2:
CRSRVBLTASK:
    jbra CRSRVBLTASK_12E
    beqw CRSRVBLTASK_14E_E
    tstb CrsrBusy
    bnew CRSRVBLTASK_14E_E
    tstb CrsrCouple
    beqw CRSRVBLTASK_14E_1C
    movew MTemp_h,%d0
    subw RawMouse_h,%d0
    movew MTemp_v,%d1
    subw RawMouse_v,%d1
    movew %d0,%d2
    bges CRSRVBLTASK_2E
    negw %d2
CRSRVBLTASK_2E:         /* |dv| */
    movew %d1,%d3
    bges CRSRVBLTASK_34
    negw %d3
CRSRVBLTASK_34:         /* the larger and the smaller delta (MickeyBytes block) */
    moveal MickeyBytes,%a0
    cmpw %d2,%d3
    blss CRSRVBLTASK_3E
    exg %d2,%d3
CRSRVBLTASK_3E:         /* distance = larger + smaller / 2; no movement: reset the history, done */
    asrw #1,%d3
    addw %d2,%d3
    bnes CRSRVBLTASK_50
    movew #1,%a0@
    clrw %a0@(18)
    braw CRSRVBLTASK_11A_C
CRSRVBLTASK_50:         /* count the movements in the history (up to its limit, the second word) */
    moveml %d4-%d5,%sp@-
    movew %a0@,%d4
    cmpw %a0@(2),%d4
    bges CRSRVBLTASK_5E
    addqw #1,%a0@
CRSRVBLTASK_5E:         /* shift the history in, through the jump table by its length */
    movew %d3,%d5
    movew %d4,%d2
    subqw #1,%d2
    aslw #1,%d2
    jmp %pc@(CRSRVBLTASK_6A,%d2:w)
CRSRVBLTASK_6A:         /* jump table into the shift chain */
    bras CRSRVBLTASK_B8
    bras CRSRVBLTASK_AE
    bras CRSRVBLTASK_A4
    bras CRSRVBLTASK_9A
    bras CRSRVBLTASK_90
    bras CRSRVBLTASK_86
    .short  0x6004	| bras 4082e010 <CRSRVBLTASK+0x7c>
    .short  0xDA68	| 4082E00C
    .short  0x0004, 0xDA68	| orib #104,%d4
    .short  0x0006, 0x3168	| orib #104,%d6
    orib #4,%d6
CRSRVBLTASK_86:         /* shift and sum */
    addw %a0@(8),%d5
    movew %a0@(8),%a0@(6)
CRSRVBLTASK_90:         /* shift and sum */
    addw %a0@(10),%d5
    movew %a0@(10),%a0@(8)
CRSRVBLTASK_9A:         /* shift and sum */
    addw %a0@(12),%d5
    movew %a0@(12),%a0@(10)
CRSRVBLTASK_A4:         /* shift and sum */
    addw %a0@(14),%d5
    movew %a0@(14),%a0@(12)
CRSRVBLTASK_AE:         /* shift and sum */
    addw %a0@(16),%d5
    movew %a0@(16),%a0@(14)
CRSRVBLTASK_B8:         /* the newest; the average speed, with the rounding error carried */
    movew %d3,%a0@(16)
    movew %d4,%d2
    asrw #1,%d2
    addw %d2,%d5
    extl %d5
    divuw %d4,%d5
    movew %d3,%d4
    subw %d5,%d3
    addw %a0@(18),%d3
    cmpiw #-1,%d3
    jbne CRSRVBLTASK_D6
    clrw %d3
CRSRVBLTASK_D6:         /* the remainder for the next tick */
    asrw #1,%d3
    movew %d3,%a0@(18)
    addw %d5,%d3
    cmpiw #255,%d5
    jbls CRSRVBLTASK_E8
    moveb #0xff,%d5
CRSRVBLTASK_E8:         /* acceleration: look up the speed in the MickeyBytes table */
    moveal MickeyBytes,%a0
    lea %a0@(20),%a0
    clrw %d2
CRSRVBLTASK_F2:         /* count the table entries below the speed */
    addqb #1,%d2
    cmpb %a0@+,%d5
    jbhi CRSRVBLTASK_F2
    mulsw %d2,%d3
    mulsw %d3,%d0
    divsw %d4,%d0
    jbmi CRSRVBLTASK_106
    andiw #127,%d0
    jbra CRSRVBLTASK_10A
CRSRVBLTASK_106:        /* negative delta */
    oriw #-128,%d0
CRSRVBLTASK_10A:        /* vertical delta */
    mulsw %d3,%d1
    divsw %d4,%d1
    jbmi CRSRVBLTASK_116
    andiw #127,%d1
    jbra CRSRVBLTASK_11A
CRSRVBLTASK_116:        /* negative delta */
    oriw #-128,%d1
CRSRVBLTASK_11A:        /* move the raw mouse position; pin it to CrsrPin */
    moveml %sp@+,%d4-%d5
    addw %d0,RawMouse_h
    addw %d1,RawMouse_v
CRSRVBLTASK_11A_C:      /* pin the raw mouse to CrsrPin */
    lea CrsrPin,%a0
    movel RawMouse_v,%d0

CRSRVBLTASK_12E:        /* pin the mouse to the screen; apply MouseMask and MouseOffset; redraw the cursor */
    jbsr CRSRVBLTASK_178
    movel %d0,RawMouse_v
    movel %d0,MTemp_v
    andl MouseMask,%d0
    movel MouseOffset,%d1
    jbeq CRSRVBLTASK_146
    addl %d1,%d0
    jbsr CRSRVBLTASK_178
CRSRVBLTASK_146:        /* the new Mouse position: erase and draw the cursor */
    movel %d0,Mouse_v
CRSRVBLTASK_146_4:      /* erase the cursor, then draw it at the new place */
    jbsr ERASECURSOR
CRSRVBLTASK_14E:        /* clear CrsrNew and CrsrObscure, draw the cursor */
    clrb CrsrNew
    clrb CrsrObscure
    jbsr DRAWCURSOR
    rts
CRSRVBLTASK_14E_E:      /* reset the acceleration history (MickeyBytes) */
    moveal MickeyBytes,%a0
    movew #1,%a0@
    clrw %a0@(18)
    rts
CRSRVBLTASK_14E_1C:     /* reset the history and redraw */
    moveal MickeyBytes,%a0
    movew #1,%a0@
    clrw %a0@(18)
    bras CRSRVBLTASK_146_4

CRSRVBLTASK_178:        /* pin the point d0 to the rectangle at a0; off the edge: try another screen (CRSRVBLTASK_1B6) */
    cmpw %a0@(2),%d0
    jbge CRSRVBLTASK_184
    jbsr CRSRVBLTASK_1B6
    movew %a0@(2),%d0
CRSRVBLTASK_184:        /* bottom edge */
    cmpw %a0@(6),%d0
    jblt CRSRVBLTASK_192
    jbsr CRSRVBLTASK_1B6
    movew %a0@(6),%d0
    subqw #1,%d0
CRSRVBLTASK_192:        /* left edge */
    swap %d0
    cmpw %a0@,%d0
    jbge CRSRVBLTASK_1A0
    swap %d0
    jbsr CRSRVBLTASK_1B6
    swap %d0
    movew %a0@,%d0
CRSRVBLTASK_1A0:        /* right edge */
    cmpw %a0@(4),%d0
    jblt CRSRVBLTASK_1B2
    swap %d0
    jbsr CRSRVBLTASK_1B6
    swap %d0
    movew %a0@(4),%d0
    subqw #1,%d0
CRSRVBLTASK_1B2:        /* done */
    swap %d0
    rts

CRSRVBLTASK_1B6:        /* the mouse left the screen: find the active device (DeviceList, 0x8A8) whose rectangle holds the point */
    movew %d0,%d3
    movel %d0,%d1
    swap %d1
    movel DeviceList,%d2
    jbmi CRSRVBLTASK_1E6
CRSRVBLTASK_1C2:        /* next device: active (bit 15 of flags)? point inside gdRect? */
    moveal %d2,%a3
    moveal %a3@,%a3
    tstw %a3@(20)
    jbpl CRSRVBLTASK_1E0
    lea %a3@(34),%a1
    cmpw %a1@+,%d1
    jblt CRSRVBLTASK_1E0
    cmpw %a1@+,%d3
    jblt CRSRVBLTASK_1E0
    cmpw %a1@+,%d1
    jbge CRSRVBLTASK_1E0
    cmpw %a1@+,%d3
    jblt CRSRVBLTASK_1E8
CRSRVBLTASK_1E0:        /* next device in the list */
    movel %a3@(30),%d2
    jbne CRSRVBLTASK_1C2
CRSRVBLTASK_1E6:        /* none: stay pinned */
    rts
CRSRVBLTASK_1E8:        /* found: move the cursor to that device (CrsrDevice), set its data, re-attach the VBL task to its slot */
    moveal CrsrPtr,%a0
    moveal %a0@,%a0
    moveal CrsrDevice,%a1
    moveal %a1@,%a1
    movew %a0@(58),%a1@(48)
    movew %a0@(76),%a1@(46)
    jbsr ERASECURSOR
    swap %d3
    movew %d1,%d3
    swap %d3
    movel %d3,MTemp_v
    movel %d3,RawMouse_v
    movel %d3,Mouse_v
    movel %d2,CrsrDevice
    moveal %a3,%a1
    jsr %pc@(SETCRSRDATA)
    movew %a3@,%d0
    notw %d0
    aslw #2,%d0
    moveal UTableBase,%a0
    moveal %a0@(0x0,%d0:w),%a3
    moveal %a3@,%a0
    moveq #0,%d0
    moveb %a0@(40),%d0
    _AttachVBL
    addqw #8,%sp
    jbra CRSRVBLTASK_14E

CRSRVBLTASK_23E:        /* pin the point d0 to the rectangle at a0 (PinRect) */
    cmpw %a0@(2),%d0
    jbge CRSRVBLTASK_248
    movew %a0@(2),%d0
CRSRVBLTASK_248:        /* bottom edge */
    cmpw %a0@(6),%d0
    jblt CRSRVBLTASK_254
    movew %a0@(6),%d0
    subqw #1,%d0
CRSRVBLTASK_254:        /* left edge */
    swap %d0
    cmpw %a0@,%d0
    jbge CRSRVBLTASK_25C
    movew %a0@,%d0
CRSRVBLTASK_25C:        /* right edge */
    cmpw %a0@(4),%d0
    jblt CRSRVBLTASK_268
    movew %a0@(4),%d0
    subqw #1,%d0
CRSRVBLTASK_268:        /* done */
    swap %d0
    rts

trap_PinRect:
PINRECT:                /* PinRect(rect, pt): the point pinned inside the rectangle */
    movel %sp@(4),%d0
    moveal %sp@(8),%a0
    jbsr CRSRVBLTASK_23E
    moveal %sp@+,%a0
    addqw #8,%sp
    movel %d0,%sp@
    jmp %a0@

CURSORSECT:             /* does the cursor rectangle (CrsrRect) intersect ShieldRect, in the cursor device's coordinates? d0 = 1 (and Z clear) if so */
    moveml %d0/%a0-%a1,%sp@-
    tstw 0xd4c
    jbeq CURSORSECT_48
    lea CrsrRect,%a0
    moveal CrsrDevice,%a1
    moveal %a1@,%a1
    lea %a1@(34),%a1
    movew 0xd48,%d0
    subw %a1@,%d0
    cmpw %a0@+,%d0
    jblt CURSORSECT_48
    movew 0xd4a,%d0
    subw %a1@(2),%d0
    cmpw %a0@+,%d0
    jble CURSORSECT_48
    movew 0xd44,%d0
    subw %a1@,%d0
    cmpw %a0@+,%d0
    jbge CURSORSECT_48
    movew 0xd46,%d0
    subw %a1@(2),%d0
    cmpw %a0@,%d0
    jbge CURSORSECT_48
    moveq #1,%d0
    jbra CURSORSECT_4A
CURSORSECT_48:          /* no intersection */
    clrw %d0
CURSORSECT_4A:          /* done */
    moveml %sp@+,%d0/%a0-%a1
    rts
    .short  0x11FC, 0x0001, 0x08CD, 0x11FC	| 4082E262
    .short  0x0001, 0x08D2	| orib #0xd2,%d1
    jbra ERASECURSOR
    moveb #1,CrsrBusy	/* HideCursor (0x4082E270): one level more hidden, then erase (ObscureCursor, at 0x4082E262 just before, is in the data above) */
    subqw #1,CrsrState

ERASECURSOR:            /* erase the cursor through the vector at 0x1FBC (UNBLITCURSOR) */
    movel 0x1fbc,%sp@-
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082E280
    /* CrsrBusy cleared */
    clrb CrsrBusy	| 4082E28A
    rts
    moveb #1,CrsrBusy	/* InitCursor (0x4082E290): arrow cursor state, visible, no shield */
    clrb CrsrObscure
    clrw CrsrState
    clrw 0xd4c
    moveb #1,CrsrBusy
    tstw 0xd4c
    jbeq ERASECURSOR_3A
    subqw #1,0xd4c
    jbra DRAWCURSOR
ERASECURSOR_3A:         /* ShowCursor: one level less hidden; at level 0 draw it */
    addqw #1,CrsrState
    clrb CrsrObscure

DRAWCURSOR:             /* draw the cursor through the vector at 0x1FB8 (BLITCURSOR) */
    movel 0x1fb8,%sp@-
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082E2C2
    .long   0x00000000, 0x00000000, 0x00000000	| 4082E2D0
    clrb CrsrBusy
    rts
    tstw 0xd4c	/* ShieldCursor (0x4082E2E2): already shielded? grow ShieldRect to include the new rectangle */
    jbeq DRAWCURSOR_5E
    moveml %d0/%a0,%sp@-
    lea 0xd4a,%a0
    movel %sp@(12),%d0
    cmpw %a0@,%d0
    jble DRAWCURSOR_3E
    movew %d0,%a0@
DRAWCURSOR_3E:          /* top */
    swap %d0
    cmpw %a0@-,%d0
    jble DRAWCURSOR_46
    movew %d0,%a0@
DRAWCURSOR_46:          /* right */
    movel %sp@(16),%d0
    cmpw %a0@-,%d0
    jbge DRAWCURSOR_50
    movew %d0,%a0@
DRAWCURSOR_50:          /* left */
    swap %d0
    cmpw %a0@-,%d0
    jbge DRAWCURSOR_58
    movew %d0,%a0@
DRAWCURSOR_58:          /* done growing */
    moveml %sp@+,%d0/%a0
    jbra DRAWCURSOR_6A
DRAWCURSOR_5E:          /* first shield: ShieldRect = the rectangle (global coordinates) */
    movel %sp@(4),0xd48
    movel %sp@(8),0xd44
DRAWCURSOR_6A:          /* ShieldDepth + 1; hide the cursor if it is inside */
    addqw #1,0xd4c
    moveb #1,CrsrBusy
    jbsr CURSORSECT
    jbeq DRAWCURSOR_7E
    jbsr ERASECURSOR
DRAWCURSOR_7E:          /* done: pop the parameters */
    clrb CrsrBusy
    movel %sp@+,%sp@
    movel %sp@+,%sp@
    rts

DRAWCURSOR_88:          /* SetCCursor(cCrsr): install a color cursor; same seed as the last one: nothing to do */
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveal %sp@(24),%a2
    moveal %a2,%a0
    _HGetState
    movew %d0,%sp@-
    moveal %a2,%a0
    _HLock
    moveal %a2@,%a2
    moveal @(CrsrPtr,%za0)@(0),%a3	| 4082E358
    movel %a2@(92),%d0
    cmpiw #-32767,%a3@
    jbne DRAWCURSOR_B4
    cmpl %a3@(54),%d0
    jbeq DRAWCURSOR_1B4
DRAWCURSOR_B4:          /* copy the 1-bit data and mask into TheCrsr and the save record */
    moveb #1,CrsrBusy
    movel %d0,%a3@(54)
    lea %a2@(20),%a0
    lea TheCrsr_data,%a1
    moveq #16,%d0
DRAWCURSOR_C8:          /* copy TheCrsr (68 bytes) */
    movel %a0@+,%a1@+
    dbf %d0,DRAWCURSOR_C8
    lea %a2@(20),%a0
    lea %a3@(22),%a1
    moveq #7,%d0
DRAWCURSOR_D8:          /* copy the 1-bit data and mask (32 bytes) */
    movel %a0@+,%a1@+
    dbf %d0,DRAWCURSOR_D8
    movew %a2@,%a3@
    movel %a2@(2),%sp@-
    movel %a3@(2),%sp@-
    jsr @(0x1614,%za0)@(0x0)	| 4082E3A4
    movel %a2@(6),%sp@-
    movel %a3@(6),%sp@-
    jsr @(0x1a14,%za0)@(0)	| 4082E3B2
    movel DeviceList,%d4
    moveal %d4,%a4
DRAWCURSOR_102:         /* for each active screen: expand the cursor for its depth */
    moveal %a4@,%a4
    tstw %a4@(20)
    jbpl DRAWCURSOR_1A0
    moveal %a4@(22),%a0
    moveal %a0@,%a0
    movew %a0@(32),%d3
    clrw %a4@(48)
    movew %a2@(14),%d0
    jbeq DRAWCURSOR_138
    cmpw %d3,%d0
    jbne DRAWCURSOR_138
    movew %d0,%a4@(48)
    movel %a2@(10),%sp@-
    movel %a3@(10),%sp@-
    jsr @(0x1a14,%za0)@(0)	| 4082E3EC
    jbra DRAWCURSOR_1A0
DRAWCURSOR_138:         /* color cursor on a screen deeper than 2 bits: expand the color image to the screen depth */
    cmpiw #-32767,%a3@
    jbne DRAWCURSOR_196
    cmpiw #2,%d3
    jble DRAWCURSOR_196
    movew %d3,%a4@(48)
    movel %a4@(50),%a3@(10)
    movel TheGDevice,%sp@-
    movel %d4,TheGDevice
    movel CrsrPtr,%sp@-
    jsr @(0x1a4c,%za0)@(0)	| 4082E416
    movel %sp@+,TheGDevice
    movew %d3,%d0
    moveq #0,%d1
DRAWCURSOR_168:         /* log2 of the depth */
    lsrw #1,%d0
    jbcs DRAWCURSOR_170
    addqw #1,%d1
    jbra DRAWCURSOR_168
DRAWCURSOR_170:         /* expand the mask through the depth expansion table (0x1AAC) */
    lea TheCrsr_mask,%a0
    moveal %a4@(0x36,%za0)@(0x0),%a1	| 4082E430
    moveal %a1,%a2
    movew #32,%d0
    lslw %d1,%d0
    addaw %d0,%a2
    moveal 0x1aac,%a3
    addal %a3@(0x0,%d1:w:4),%a3
    moveq #0,%d0
    jsr %a3@
    moveal @(CrsrPtr,%za0)@(0),%a3	| 4082E44C
DRAWCURSOR_196:         /* the device's cursor depth and row bytes */
    movew %a4@(48),%d0
    addw %d0,%d0
    movew %d0,%a4@(46)
DRAWCURSOR_1A0:         /* next device */
    movel %a4@(30),%d4
    moveal %d4,%a4
    jbne DRAWCURSOR_102
    jbsr GETMAINCRSR
    jbsr ERASECURSOR
    jbsr DRAWCURSOR
DRAWCURSOR_1B4:         /* done: restore the handle state */
    clrb CrsrBusy
    movew %sp@+,%d0
    moveal %sp@(24),%a0
    _HSetState
    moveml %sp@+,%d3-%d4/%a2-%a4
    movel %sp@+,%sp@
    rts

GETMAINCRSR:            /* load the save record from the cursor device (CrsrDevice): expanded image, mask, depth, row bytes */
    moveal CrsrDevice,%a0
    moveal %a0@,%a0
    moveal CrsrPtr,%a1
    moveal %a1@,%a1
    movel %a0@(50),%a1@(10)
    movel %a0@(54),%a1@(14)
    movew %a0@(48),%a1@(58)
    movew %a0@(46),%a1@(76)
    rts
    moveal @(CrsrPtr,%za0)@(0),%a0	| 4082E4AA
    moveb #1,CrsrBusy	/* SetCursor (0x4082E4AA): a 1-bit cursor: copy it into TheCrsr, counting changes */
    movew #-32768,%a0@
    moveal %sp@(8),%a0
    lea TheCrsr_data,%a1
    moveq #15,%d2
    moveq #0,%d1
GETMAINCRSR_42:         /* copy 16 longs, count the ones that changed */
    movel %a0@+,%d0
    cmpl %a1@,%d0
    jbeq GETMAINCRSR_4A
    addqw #1,%d1
GETMAINCRSR_4A:         /* store */
    movel %d0,%a1@+
    dbf %d2,GETMAINCRSR_42
    movel %sp@(14),%d0
    moveq #16,%d2
    cmpw %d2,%d0
    jbls GETMAINCRSR_5C
    movew %d2,%d0
GETMAINCRSR_5C:         /* hot spot, pinned to 0..16 */
    swap %d0
    cmpw %d2,%d0
    jbls GETMAINCRSR_64
    movew %d2,%d0
GETMAINCRSR_64:         /* hot spot changed? */
    swap %d0
    cmpl TheCrsr_hotspot_v,%d0
    jbeq GETMAINCRSR_72
    addqw #1,%d1
    movel %d0,TheCrsr_hotspot_v
GETMAINCRSR_72:         /* anything changed: redraw the cursor */
    clrb CrsrBusy
    tstw %d1
    jbeq GETMAINCRSR_82
    jbsr ERASECURSOR
    jbsr DRAWCURSOR
GETMAINCRSR_82:         /* pop the parameter, return */
    moveal %sp@+,%a0
    lea %sp@(14),%sp
    jmp %a0@
    .short  0x0000	| 4082E50E

SETCRSRDATA:            /* make the device at a1 the cursor device: its expanded cursor, CrsrPin = gdRect, screen base, row bytes, size (0x898, 0x8AC, 0xC20, 0xC22) */
    jbsr SETCRSRDELAY
    movel %a1@(50),%a0@(10)
    movel %a1@(54),%a0@(14)
    movew %a1@(48),%a0@(58)
    movew %a1@(46),%a0@(76)
    lea %a1@(34),%a0
    movel %a0@+,CrsrPin
    movel %a0@,0x838
    moveal %a1@(22),%a0
    moveal %a0@,%a0
    movew %a0@(32),ChunkyDepth
    movel %a0@+,CrsrBase
    movew %a0@+,%d0
    andiw #32767,%d0
    movew %d0,CrsrRow
    movew %a0@(4),%d0
    subw %a0@,%d0
    movew %d0,ColLines
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    movew %d0,RowBits
    rts
    .long   0x00000000	| 4082E56C
ALLOCCRSR:              /* AllocCursor: (re)allocate the cursor save buffers for every screen, in the system heap; the first time also the save record (CrsrPtr, 0xD62) with the arrow */
    moveml %d0-%d6/%a0-%a4/%fp,%sp@-
    movel TheZone,%sp@-
    movel SysZone,TheZone
    jbsr ERASECURSOR
    moveb #1,CrsrBusy
    movel CrsrPtr,%d0
    cmpl MinusOne,%d0
    jbne ALLOCCRSR_80
    clrb CrsrObscure
    clrw CrsrState
    clrw 0xd4c
    moveq #80,%d1
    jbsr ALLOCCRSR_156
    movel %a0,CrsrPtr
    moveal %a0@,%a4
    moveq #50,%d0
    _ResrvMem
    clrl %sp@-
    jsr @(0x160c,%za0)@(0)	| 4082E5B0
    moveal %sp@+,%a0
    movel %a0,%a4@(2)
    _HLock
    moveq #2,%d0
    jsr %pc@(RNEWHANDLE)
    movel %a0,%a4@(6)
    movel #1024,%d1
    jbsr ALLOCCRSR_156
    movel %a0,%a4@(18)
    movew #-32768,%a4@
    clrw %a4@(58)
    moveal %a5@,%a0
    lea %a0@(-108),%a0
    lea TheCrsr_data,%a1
    moveq #16,%d0
ALLOCCRSR_7A:           /* copy the arrow (QuickDraw globals) into TheCrsr */
    movel %a0@+,%a1@+
    dbf %d0,ALLOCCRSR_7A
ALLOCCRSR_80:           /* for each active screen */
    moveal CrsrPtr,%a4
    moveal %a4@,%a4
    movel DeviceList,%d4
    moveal %d4,%fp
ALLOCCRSR_8C:           /* active device? cursor not expanded yet: new 1K buffers for the image and the mask */
    moveal %fp@,%fp
    tstw %fp@(20)
    jbpl ALLOCCRSR_12C
    tstw %fp@(48)
    jbne ALLOCCRSR_BE
    moveal %fp@(50),%a0
    _DisposHandle
    movel #1024,%d1
    jbsr ALLOCCRSR_156
    movel %a0,%fp@(50)
    moveal %fp@(54),%a0
    _DisposHandle
    jbsr ALLOCCRSR_156
    movel %a0,%fp@(54)
ALLOCCRSR_BE:           /* same depth as before: done with this device */
    moveal %fp@(22),%a0
    moveal %a0@,%a0
    movew %a0@(32),%d3
    cmpw %fp@(48),%d3
    jbeq ALLOCCRSR_12C
    movew %d3,%d0
    moveq #0,%d6
ALLOCCRSR_D2:           /* log2 of the depth */
    lsrw #1,%d0
    jbcs ALLOCCRSR_DA
    addqw #1,%d6
    jbra ALLOCCRSR_D2
ALLOCCRSR_DA:           /* a color cursor deeper than 2 bits: expand it for this device */
    cmpiw #-32767,%a4@
    jbne ALLOCCRSR_12C
    cmpiw #2,%d3
    jble ALLOCCRSR_12C
    movel %fp@(50),%a4@(10)
    movel TheGDevice,%sp@-
    movel %d4,TheGDevice
    movel CrsrPtr,%sp@-
    jsr @(0x1a4c,%za0)@(0)	| 4082E668
    movel %sp@+,TheGDevice
    lea TheCrsr_mask,%a0
    moveal %fp@(0x36,%za0)@(0x0),%a1	| 4082E676
    moveal %a1,%a2
    movew #32,%d0
    lslw %d6,%d0
    addaw %d0,%a2
    moveal 0x1aac,%a3
    addal %a3@(0x0,%d6:w:4),%a3
    moveq #0,%d0
    jsr %a3@
    movew %d3,%fp@(48)
    addw %d3,%d3
    movew %d3,%fp@(46)
ALLOCCRSR_12C:          /* next device; then use the cursor device's data and draw */
    movel %fp@(30),%d4
    moveal %d4,%fp
    jbne ALLOCCRSR_8C
    jbsr GETMAINCRSR
    moveal CrsrDevice,%a1
    moveal %a1@,%a1
    jsr %pc@(SETCRSRDATA)
    movel %sp@+,TheZone
    clrb CrsrBusy
    jbsr DRAWCURSOR
    moveml %sp@+,%d0-%d6/%a0-%a4/%fp
    rts

ALLOCCRSR_156:          /* a locked handle of d1 bytes in the system heap; no room: Debugger (error 25) */
    movel %d1,%d0
    _ResrvMem
    jbne ALLOCCRSR_164
    movel %d1,%d0
    .short  0xA322	| 4082E6CE _NewHandle (flags 0x0300)
    _HLock
    rts
ALLOCCRSR_164:          /* out of memory */
    moveq #25,%d0
    jsr @(0x1524,%za0)@(0x0)	| 4082E6D6
    _Debugger
    .short  0x0000	| 4082E6DE

/*
 BLITCURSOR: draw the cursor on the cursor device (vector 0x1FB8): expand it for the depth if
 needed, clip it to the screen, save what is under it in the save buffer, then combine the expanded image and mask with
 the screen: mask set: the image; mask clear: the image inverts the screen.
*/
BLITCURSOR:
    tstl CrsrPtr
    jbmi BLITCURSOR_2F4
    moveml %d0-%fp,%sp@-
    lea TheCrsr_data,%a2
    lea %pc@(SHFTTBL),%a0
    movew ChunkyDepth,%d1
    moveq #0,%d7
    moveb %a0@(0x0,%d1:w),%d7
    moveal @(CrsrPtr,%za0)@(0),%a4	| 4082E6FE
    cmpiw #-32767,%a4@
    jbne BLITCURSOR_3C
    cmpw %a4@(58),%d1
    jbeq BLITCURSOR_CC
    cmpiw #2,%d1
    bgtw BLITCURSOR_AC
    jbra BLITCURSOR_6C
BLITCURSOR_3C:          /* a 1-bit cursor: same data and depth as last time? skip the expansion */
    lea %a4@(22),%a0
    moveal %a2,%a1
    moveq #7,%d0
BLITCURSOR_44:          /* compare the data */
    cmpml %a0@+,%a1@+
    jbne BLITCURSOR_54
    dbf %d0,BLITCURSOR_44
    cmpw %a4@(58),%d1
    beqw BLITCURSOR_CC
BLITCURSOR_54:          /* changed: invalidate every device's expanded cursor */
    moveal DeviceList,%a0
BLITCURSOR_58:          /* next device */
    moveal %a0@,%a0
    tstw %a0@(20)
    jbpl BLITCURSOR_64
    clrw %a0@(48)
BLITCURSOR_64:          /* next device */
    movel %a0@(30),%d0
    moveal %d0,%a0
    jbne BLITCURSOR_58
BLITCURSOR_6C:          /* expand the data to the screen depth (table at 0x1AAC) */
    lea %a4@(22),%a0
    moveal %a2,%a1
    moveq #7,%d0
BLITCURSOR_74:          /* copy the data into the save record */
    movel %a1@+,%a0@+
    dbf %d0,BLITCURSOR_74
    movew %d1,%a4@(58)
    addw %d1,%d1
    movew %d1,%a4@(76)
    moveal %a2,%a0
    moveal %a4@(0xa,%za0)@(0),%a1	| 4082E766
    moveal %a1,%a2
    movew #32,%d5
    lslw %d7,%d5
    addaw %d5,%a2
    movew %d7,%d0
    cmpiw #4,%d0
    jblt BLITCURSOR_A0
    addqw #2,%d0
BLITCURSOR_A0:          /* expand */
    moveal 0x1aac,%a3
    addal %a3@(0x0,%d0:w:4),%a3
    moveq #0,%d0
    jsr %a3@
BLITCURSOR_AC:          /* expand the mask */
    lea TheCrsr_mask,%a0
    moveal %a4@(0xe,%za0)@(0),%a1	| 4082E790
    moveal %a1,%a2
    movew #32,%d5
    lslw %d7,%d5
    addaw %d5,%a2
    moveal 0x1aac,%a3
    addal %a3@(0x0,%d7:w:4),%a3
    moveq #0,%d0
    jsr %a3@
BLITCURSOR_CC:          /* position: rows clipped at the top and bottom of the screen */
    movel %a4@(0xa,%za0)@(0),%d0	| 4082E7AC
    jsr @(0x644,%za0)@(0x0)
    moveal %d0,%a2
    movel %a4@(0xe,%za0)@(0),%d0	| 4082E7BA
    jsr @(0x644,%za0)@(0x0)
    moveal %d0,%a3
    moveq #16,%d5
    movew Mouse_v,%d2
    subw CrsrPin,%d2
    subw TheCrsr_hotspot_v,%d2
    movew %d2,%d3
    addw %d5,%d3
    cmpw %d5,%d3
    jbge BLITCURSOR_110
    negw %d2
    cmpw %d5,%d2
    jbeq BLITCURSOR_2F0
    muluw %a4@(76),%d2
    addal %d2,%a2
    addal %d2,%a3
    moveq #0,%d2
BLITCURSOR_110:         /* bottom */
    movew ColLines,%d4
    cmpw %d4,%d3
    jble BLITCURSOR_11A
    movew %d4,%d3
BLITCURSOR_11A:         /* columns clipped at the left and right */
    moveq #0,%d6
    movew Mouse_h,%d0
    subw 0x836,%d0
    subw TheCrsr_hotspot_h,%d0
    movew %d0,%d1
    addw %d5,%d1
    cmpw %d5,%d1
    jbge BLITCURSOR_134
    subw %d0,%d6
    moveq #0,%d0
BLITCURSOR_134:         /* right */
    movew RowBits,%d4
    cmpw %d4,%d1
    jble BLITCURSOR_13E
    movew %d4,%d1
BLITCURSOR_13E:         /* screen address of the first long; CrsrRect; inside the shield? don't draw */
    moveal CrsrBase,%a5
    moveaw CrsrRow,%a0
    movew %a0,%d4
    muluw %d2,%d4
    addal %d4,%a5
    extl %d0
    lsll %d7,%d0
    movel %d0,%d4
    andil #-32,%d4
    movel %d4,%d5
    asrl #3,%d5
    addal %d5,%a5
    lea CrsrRect,%a1
    movew %d2,%a1@+
    movel %d4,%d5
    lsrl %d7,%d5
    movew %d5,%a1@+
    movew %d3,%a1@+
    movew %d5,%a1@
    andiw #31,%d0
    lslw %d7,%d6
    subw %d0,%d6
    extl %d1
    lsll %d7,%d1
    movel %d1,%d5
    subl %d4,%d5
    jble BLITCURSOR_2F0
    subqw #1,%d5
    lsrl #5,%d5
    subw %d2,%d3
    subqw #1,%d3
    movel %d5,%d2
    addql #1,%d2
    lsll #2,%d2
    subal %d2,%a0
    lsll #3,%d2
    lsrl %d7,%d2
    addw %d2,%a1@
    jbsr CURSORSECT
    jbne BLITCURSOR_2F0
    moveq #-1,%d4
    lsrl %d0,%d4
    moveq #-1,%d2
    andiw #31,%d1
    jbeq BLITCURSOR_1B0
    lsrl %d1,%d2
    notl %d2
BLITCURSOR_1B0:         /* save the screen area and its geometry in the save record */
    lea %a4@(76),%fp
    moveaw %fp@,%a1
    movel %a4@(0x12,%za0)@(0x0),%d0	| 4082E896
    jsr @(0x644,%za0)@(0x0)
    moveal %d0,%a4
    moveml %d3/%d5/%a0/%a5,%fp@-
    moveq #1,%d0
    moveml %a0-%a2,%sp@-
    jsr @(0x574,%za0)@(0x0)	| 4082E8AE
    moveml %sp@+,%a0-%a2
    moveb %d0,%sp@-
    moveal %d5,%fp
    extl %d6
    movel %d6,%sp@-
    movel %d4,%sp@-
    cmpiw #4,%d7
    bgew BLITCURSOR_234
    tstw %d5
    jbra BLITCURSOR_21A
BLITCURSOR_1EE:         /* last long: the right mask */
    andl %d2,%d4
BLITCURSOR_1F0:         /* depth < 16: by bit fields: save the screen long, combine data and mask */
    bfextu %a2@,%d6,0,%d0
    bfextu %a3@,%d6,0,%d1
    addil #32,%d6
    andl %d4,%d0
    andl %d4,%d1
    movel %d0,%d7
    andl %d1,%d7
    notl %d1
    movel %a5@,%d4
    movel %d4,%a4@+
    andl %d1,%d0
    andl %d4,%d1
    orl %d7,%d1
    eorl %d0,%d1
    movel %d1,%a5@+
    moveq #-1,%d4
    subqw #1,%d5
BLITCURSOR_21A:         /* (entry: d5 > 0 middle longs, = 0 last long); next row */
    jbgt BLITCURSOR_1F0
    jbeq BLITCURSOR_1EE
    movel %sp@(4),%d6
    movel %sp@,%d4
    addal %a1,%a3
    addal %a1,%a2
    addal %a0,%a5
    movel %fp,%d5
    dbf %d3,BLITCURSOR_21A
    jbra BLITCURSOR_2DE
BLITCURSOR_234:         /* 16-bit pixels */
    jbgt BLITCURSOR_2A6
    swap %d4
    addqw #1,%d5
    addw %d5,%d5
    movew %d5,%d0
    subqw #2,%d5
    moveaw %d5,%fp
    moveq #-1,%d7
    lsrw #1,%d7
    addw %d0,%d0
    subaw %d0,%a1
    asrw #3,%d6
    addaw %d6,%a2
    addaw %d6,%a3
BLITCURSOR_250:         /* first pixel: outside? just save it */
    tstw %d4
    jbne BLITCURSOR_25C
    movew %a5@+,%a4@+
    addqw #2,%a2
    addqw #2,%a3
    jbra BLITCURSOR_272
BLITCURSOR_25C:         /* each pixel: save it; mask set: the image, else the image xor the screen */
    movew %a2@+,%d0
    movew %a5@,%d1
    movew %d1,%a4@+
    tstw %a3@+
    jbne BLITCURSOR_26E
    notw %d0
    andw %d7,%d0
    jbeq BLITCURSOR_270
    eorw %d1,%d0
BLITCURSOR_26E:         /* store */
    movew %d0,%a5@
BLITCURSOR_270:         /* next pixel */
    addqw #2,%a5
BLITCURSOR_272:         /* next pixel */
    dbf %d5,BLITCURSOR_25C
    tstw %d2
    jbne BLITCURSOR_282
    movew %a5@+,%a4@+
    addqw #2,%a2
    addqw #2,%a3
    jbra BLITCURSOR_298
BLITCURSOR_282:         /* last pixel */
    movew %a2@+,%d0
    movew %a5@,%d1
    movew %d1,%a4@+
    tstw %a3@+
    jbne BLITCURSOR_294
    notw %d0
    andw %d7,%d0
    jbeq BLITCURSOR_296
    eorw %d1,%d0
BLITCURSOR_294:         /* store */
    movew %d0,%a5@
BLITCURSOR_296:         /* next pixel */
    addqw #2,%a5
BLITCURSOR_298:         /* next row */
    addal %a1,%a3
    addal %a1,%a2
    addal %a0,%a5
    movel %fp,%d5
    dbf %d3,BLITCURSOR_250
    jbra BLITCURSOR_2DE
BLITCURSOR_2A6:         /* 32-bit pixels */
    moveq #-1,%d4
    lsrl #8,%d4
    movew %d5,%d0
    addqw #1,%d0
    lslw #2,%d0
    subaw %d0,%a1
    asrw #3,%d6
    addaw %d6,%a2
    addaw %d6,%a3
BLITCURSOR_2B8:         /* each pixel: save it; mask set: the image, else the image xor the screen */
    movel %a2@+,%d0
    movel %a5@,%d1
    movel %d1,%a4@+
    tstl %a3@+
    jbne BLITCURSOR_2CA
    notl %d0
    andl %d4,%d0
    jbeq BLITCURSOR_2CC
    eorl %d1,%d0
BLITCURSOR_2CA:         /* store */
    movel %d0,%a5@
BLITCURSOR_2CC:         /* next pixel; next row */
    addqw #4,%a5
    dbf %d5,BLITCURSOR_2B8
    addal %a1,%a3
    addal %a1,%a2
    addal %a0,%a5
    movel %fp,%d5
    dbf %d3,BLITCURSOR_2B8
BLITCURSOR_2DE:         /* CrsrVis = 1 */
    addqw #8,%sp
    moveb #1,CrsrVis
    moveq #0,%d0
    moveb %sp@+,%d0
    jsr @(0x574,%za0)@(0x0)	| 4082E9CA
BLITCURSOR_2F0:         /* done */
    moveml %sp@+,%d0-%fp
BLITCURSOR_2F4:         /* no cursor allocated: return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082E9D6

UNBLITCURSOR:           /* erase the cursor (vector 0x1FBC): copy the saved screen area back, CrsrVis = 0 */
    tstl CrsrPtr
    jbmi UNBLITCURSOR_54
    moveml %d1-%d4/%a0-%a2,%sp@-
    moveal @(CrsrPtr,%za0)@(0),%a0	| 4082E9EA
    moveal %a0@(18),%a1
    movel %a1@,%d0
    jsr @(0x644,%za0)@(0x0)	| 4082E9F6
    moveal %d0,%a1
    lea %a0@(60),%a0
    moveml %a0@+,%d2-%d4/%a2
    moveq #1,%d0
    moveml %d2/%a1-%a2,%sp@-
    jsr @(0x574,%za0)@(0x0)	| 4082EA0C
    moveml %sp@+,%d2/%a1-%a2
    moveal %d3,%a0
UNBLITCURSOR_38:        /* copy the saved rows back */
    movel %a1@+,%a2@+
    dbf %d3,UNBLITCURSOR_38
    movel %a0,%d3
    addaw %d4,%a2
    dbf %d2,UNBLITCURSOR_38
    jsr @(0x574,%za0)@(0x0)	| 4082EA26
    clrb CrsrVis
    moveml %sp@+,%d1-%d4/%a0-%a2
UNBLITCURSOR_54:        /* done */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082EA36
SCRNADDRESS:            /* ScrnAddress: the screen base (ScrnBase) */
    movel ScrnBase,%sp@(4)
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4082EA48
SCRNSIZE:               /* ScrnSize: the main screen's size */
    movel %sp@+,%d0
    moveal MainDevice,%a0
    moveal %a0@,%a0
    moveal %sp@+,%a1
    movew %a0@(38),%d1
    subw %a0@(34),%d1
    movew %d1,%a1@
    moveal %sp@+,%a1
    movew %a0@(40),%d1
    subw %a0@(36),%d1
    movew %d1,%a1@
    moveal %d0,%a0
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082EA74

trap_ScrnBitMap:
SCRNBITMAP:             /* ScreenBitMap(bm): the main device's pixel map as a bitmap */
    movel %sp@+,%d0
    moveal MainDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %sp@+,%a1
    movel %a0@+,%a1@+
    movew %a0@+,%d1
    andiw #32767,%d1
    movew %d1,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %d0,%a0
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082EAA2

trap_BitNot:
BITNOT:                 /* BitNot(a) */
    moveal %sp@+,%a0
    notl %sp@
    movel %sp@+,%sp@
    jmp %a0@
    .long   0x00000000, 0x00000000	| 4082EAB8

trap_BitAnd:
BITAND:                 /* BitAnd(a, b) */
    moveal %sp@+,%a0
    movel %sp@+,%d0
    andl %sp@+,%d0
    jbra BITSHIFT_12

trap_BitXOr:
BITXOR:                 /* BitXor(a, b) */
    moveal %sp@+,%a0
    movel %sp@+,%d0
    movel %sp@+,%d1
    eorl %d1,%d0
    jbra BITSHIFT_12

trap_BitOr:
BITOR:                  /* BitOr(a, b) */
    moveal %sp@+,%a0
    movel %sp@+,%d0
    orl %sp@+,%d0
    jbra BITSHIFT_12

trap_BitShift:
BITSHIFT:               /* BitShift(value, count): left if positive, right if negative */
    moveal %sp@+,%a0
    movew %sp@+,%d1
    jbpl BITSHIFT_E
    negw %d1
    movel %sp@+,%d0
    lsrl %d1,%d0
    jbra BITSHIFT_12
BITSHIFT_E:             /* left */
    movel %sp@+,%d0
    lsll %d1,%d0
BITSHIFT_12:            /* the result */
    movel %d0,%sp@
    jmp %a0@

trap_BitTst:
BITTST:                 /* BitTst(ptr, bit): bit 0 is the high bit of the first byte */
    jbsr BITCLR_A
    moveal %sp@+,%a1
    btst %d0,%a1@(0x0,%d1:l)
    sne %sp@
    negb %sp@
    jmp %a0@

trap_BitSet:
BITSET:                 /* BitSet(ptr, bit) */
    jbsr BITCLR_A
    moveal %sp@+,%a1
    bset %d0,%a1@(0x0,%d1:l)
    jmp %a0@

trap_BitClr:
BITCLR:                 /* BitClr(ptr, bit) */
    jbsr BITCLR_A
    moveal %sp@+,%a1
    bclr %d0,%a1@(0x0,%d1:l)
    jmp %a0@

BITCLR_A:               /* the byte offset (d1) and bit number (d0) from the bit index */
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    movel %sp@+,%d1
    movew %d1,%d0
    asrl #3,%d1
    notw %d0
    jmp %a1@

trap_Random:
RANDOM:                 /* Random: the next number of the Park-Miller generator (seed * 16807 mod 2^31-1, randSeed in the QuickDraw globals) */
    moveal %a5@,%a0
    movew #16807,%d0
    movew %d0,%d2
    muluw %a0@(-124),%d0
    movel %d0,%d1
    clrw %d1
    swap %d1
    muluw %a0@(-126),%d2
    addl %d1,%d2
    movel %d2,%d1
    addl %d1,%d1
    clrw %d1
    swap %d1
    andil #65535,%d0
    subil #2147483647,%d0
    andil #32767,%d2
    swap %d2
    addl %d1,%d2
    addl %d2,%d0
    jbpl RANDOM_40
    addil #2147483647,%d0
RANDOM_40:              /* store the seed; -32768 becomes 0 */
    movel %d0,%a0@(-126)
    cmpiw #-32768,%d0
    jbne RANDOM_4C
    clrw %d0
RANDOM_4C:              /* the result */
    movew %d0,%sp@(4)
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082EB72

trap_ForeColor:
FORECOLOR:              /* ForeColor(color): old-style color (8 planes); color port: the RGB from the table at 0x8B0 (QDColors) */
    moveq #80,%d0
FORECOLOR_2:            /* color port? */
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(6)
    jbpl PORTLONG
    movew %d0,%sp@-
    movel %sp@(6),%d0
    moveal %a0@(2),%a0
    moveal %a0@,%a0
    lsrl #1,%d0
    jbcs FORECOLOR_20
    oriw #224,%d0
FORECOLOR_20:           /* the color index from the old-style value */
    lsrw #5,%d0
    andiw #7,%d0
    moveal QDColors,%a0
    pea %a0@(0x2,%d0:w:8)
    cmpiw #80,%sp@(4)
    jbne FORECOLOR_3E
    jsr @(0x1650,%za0)@(0x0)	| 4082EBB6
    jbra FORECOLOR_44
FORECOLOR_3E:           /* RGBForeColor / RGBBackColor */
    jsr @(0x1654,%za0)@(0x0)	| 4082EBBE
FORECOLOR_44:           /* done */
    movew %sp@+,%d0
    moveal %sp@+,%a1
    addqw #4,%sp
    jmp %a1@

trap_BackColor:
BACKCOLOR:              /* BackColor(color) */
    moveq #84,%d0
    jbra FORECOLOR_2
PORTLONG:               /* store the long parameter at offset d0 of thePort */
    moveal %sp@+,%a1
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %sp@+,%a0@(0x0,%d0:w)
    jmp %a1@

trap_ColorBit:
COLORBIT:               /* ColorBit(which) */
    moveq #88,%d0
PORTWORD:               /* store the word parameter at offset d0 of thePort */
    moveal %sp@+,%a1
    moveal %a5@,%a0
    moveal %a0@,%a0
    movew %sp@+,%a0@(0x0,%d0:w)
    jmp %a1@
    .short  0x0000, 0x0000, 0x0000	| 4082EBEA

/* GETMASKTAB: table. */
trap_GetMaskTable:
GETMASKTAB:
    lea %pc@(MASKTAB),%a0
    rts
LEFTMASK:               /* LeftMask table (data) */
    andiw #15,%d0
    addw %d0,%d0
    movew %pc@(MASKTAB_20,%d0:w),%d0	| 4082EBFC
    rts
RIGHTMASK:              /* RightMask table (data) */
    andiw #15,%d0
    addw %d0,%d0
    movew %pc@(MASKTAB,%d0:w),%d0
    rts
BITMASK:                /* BitMask table (data) */
    andiw #15,%d0
    addw %d0,%d0
    movew %pc@(MASKTAB_40,%d0:w),%d0	| 4082EC14
    rts

/* MASKTAB: table. */
MASKTAB:
    .byte   0x00, 0x00, 0x80, 0x00, 0xC0, 0x00, 0xE0, 0x00, 0xF0, 0x00, 0xF8, 0x00, 0xFC, 0x00, 0xFE, 0x00	| 4082EC1A
    .byte   0xFF, 0x00, 0xFF, 0x80, 0xFF, 0xC0, 0xFF, 0xE0, 0xFF, 0xF0, 0xFF, 0xF8, 0xFF, 0xFC, 0xFF, 0xFE	| 4082EC2A
MASKTAB_20:
    .byte   0xFF, 0xFF, 0x7F, 0xFF, 0x3F, 0xFF, 0x1F, 0xFF, 0x0F, 0xFF, 0x07, 0xFF, 0x03, 0xFF, 0x01, 0xFF	| 4082EC3A
    .byte   0x00, 0xFF, 0x00, 0x7F, 0x00, 0x3F, 0x00, 0x1F, 0x00, 0x0F, 0x00, 0x07, 0x00, 0x03, 0x00, 0x01	| 4082EC4A
MASKTAB_40:
    .byte   0x80, 0x00, 0x40, 0x00, 0x20, 0x00, 0x10, 0x00, 0x08, 0x00, 0x04, 0x00, 0x02, 0x00, 0x01, 0x00	| 4082EC5A
    .byte   0x00, 0x80, 0x00, 0x40, 0x00, 0x20, 0x00, 0x10, 0x00, 0x08, 0x00, 0x04, 0x00, 0x02, 0x00, 0x01	| 4082EC6A
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082EC7A
ARITHMODE:              /* arithmetic mode to boolean mode for 1-bit destinations (data) */
    .byte   0x00, 0x03, 0x02, 0x01, 0x01, 0x03, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082EC80

/*
 COLORMAP: the colors and mode for a drawing operation (called from the stdproc set-up, inside
 its stack frame): the transfer mode (fp-152) is adjusted for the port and depth, and the
 foreground and background longs (fp-160, fp-164) are the colors replicated across a long.
 Hilite (mode 2 / 50) when HiliteMode (0x938) bit 7 was clear; arithmetic modes at 1 bit
 become boolean modes (ARITHMODE table). For color ports the fg/bk are the port's RGB
 colors; for old-style ports the 8 QuickDraw colors (QDColors, 0x8B0). On a 1-bit
 destination a copy whose colors make it a no-op or an inverse is changed to the cheaper
 mode. Arithmetic modes also get the op color, pin and weight (fp-244..-280) and the
 color table and inverse table for the pixel lookups.
*/
trap_COLORMAP:
COLORMAP:               /* colors and mode for the operation */
    moveml %d3-%d7/%a2-%a3,%sp@-
    moveq #-1,%d4
    moveq #0,%d5
    moveal %a5@,%a2
    moveal %a2@,%a2
    movew %a2@(88),%d2
    movew %fp@(-152),%d3
    movel %a2@(80),%d6
    movel %a2@(84),%d7
    clrw %fp@(-260)
    movew %d3,%d1
    andiw #-9,%d3
    eorw %d3,%d1
    cmpiw #2,%d3
    jbne COLORMAP_3A
    bset #7,HiliteMode
    jbne COLORMAP_3A
    movew #50,%d3
COLORMAP_3A:            /* arithmetic mode on a 1-bit destination: map it to a boolean mode (ARITHMODE) */
    btst #5,%d3
    jbeq COLORMAP_50
    cmpiw #1,%fp@(-212)
    jbne COLORMAP_50
    andiw #7,%d3
    moveb %pc@(ARITHMODE,%d3:w),%d3
COLORMAP_50:            /* hilite, xor and notXor need no colors */
    orw %d1,%d3
    movew %d3,%fp@(-152)
    movew %d3,%d0
    bclr #3,%d0
    cmpiw #50,%d0
    jbeq COLORMAP_194
    cmpiw #2,%d0
    jbeq COLORMAP_194
    cmpiw #6,%d0
    jbeq COLORMAP_194
    tstb %d1
    jbne COLORMAP_82
    tstb %fp@(-257)
    jbne COLORMAP_194
    jbra COLORMAP_96
COLORMAP_82:            /* a pattern mode with a color pattern: colors come from the pattern */
    tstb %fp@(-166)
    jbeq COLORMAP_96
    moveal %fp@(-156),%a0
    moveal %a0@,%a0
    moveal %a0@,%a0
    tstw %a0@
    jbne COLORMAP_194
COLORMAP_96:            /* color port: black foreground and white background? (flags fp-259, fp-260) */
    tstw %a2@(6)
    jbpl COLORMAP_FE
    lea %a2@(36),%a0
    movel %a0@+,%d0
    orw %a0@+,%d0
    tstl %d0
    sne %fp@(-259)
    movew %a0@+,%d1
    andw %a0@+,%d1
    andw %a0@+,%d1
    lsrw #8,%d1
    addqb #1,%d1
    sne %fp@(-260)
    cmpiw #2,%fp@(-212)
    jbgt COLORMAP_12E
    cmpl %d6,%d7
    jbne COLORMAP_12E
    lea %a2@(36),%a0
    lea %a2@(42),%a1
    cmpml %a0@+,%a1@+
    jbne COLORMAP_D4
    cmpmw %a0@+,%a1@+
    jbeq COLORMAP_12E
COLORMAP_D4:            /* foreground equals background: use the inverse of the background */
    tstw %d2
    jbne COLORMAP_12E
    lea %a2@(36),%a0
    subqw #6,%sp
    moveal %sp,%a1
    movel %a0@+,%a1@+
    movew %a0@+,%a1@+
    movel %sp,%sp@-
    jsr @(0x16d4,%za0)@(0)	| 4082ED76
    subqw #4,%sp
    pea %sp@(4)
    jsr @(0x16cc,%za0)@(0)	| 4082ED82
    movel %sp@+,%d6
    addqw #6,%sp
    jbra COLORMAP_12E
COLORMAP_FE:            /* old-style port: indexed and deeper than 1 bit: the old-style colors to RGB and index */
    tstw %d2
    jbmi COLORMAP_194
    jbne COLORMAP_146
    cmpiw #1,%fp@(-212)
    jbeq COLORMAP_146
    cmpiw #33,%d6
    sne %fp@(-259)
    cmpiw #30,%d7
    sne %fp@(-260)
    movel %d7,%d0
    jbsr COLORMAP_2A2
    movel %d0,%d7
    movel %d6,%d0
    jbsr COLORMAP_2A2
    movel %d0,%d6
COLORMAP_12E:           /* replicate fg (d4) and bk (d5) across a long at the pixel size */
    movew %fp@(-212),%d0
    movel %d6,%d4
    movel %d7,%d5
    moveq #32,%d1
COLORMAP_138:           /* replicate */
    subw %d0,%d1
    jble COLORMAP_194
    lsll %d0,%d4
    lsll %d0,%d5
    orl %d6,%d4
    orl %d7,%d5
    jbra COLORMAP_138
COLORMAP_146:           /* one plane (ColorBit): or / bic modes become copy or nothing depending on the plane bit */
    moveq #3,%d0
    andw %d3,%d0
    jbeq COLORMAP_166
    cmpiw #2,%d0
    jbeq COLORMAP_194
    jbgt COLORMAP_160
    movel %d6,%d1
COLORMAP_156:           /* the plane bit decides */
    btst %d2,%d1
    jbne COLORMAP_194
    eoriw #2,%d3
    jbra COLORMAP_190
COLORMAP_160:           /* bic: the background */
    movel %d7,%d1
    notl %d1
    jbra COLORMAP_156
COLORMAP_166:           /* copy: both colors set in this plane: a solid black pattern; both clear: a solid white pattern */
    movel %d6,%d0
    movel %d7,%d1
    btst %d2,%d0
    jbeq COLORMAP_184
    btst %d2,%d1
    jbeq COLORMAP_194
    moveq #8,%d3
COLORMAP_174:           /* use the solid pattern in the QuickDraw globals */
    moveal %a5@,%a0
    lea %a0@(-16),%a0
    movel %a0,%fp@(-156)
    sf %fp@(-166)
    jbra COLORMAP_190
COLORMAP_184:           /* background set in this plane? */
    btst %d2,%d1
    jbne COLORMAP_18C
    moveq #12,%d3
    jbra COLORMAP_174
COLORMAP_18C:           /* the inverse mode */
    eoriw #4,%d3
COLORMAP_190:           /* store the mode */
    movew %d3,%fp@(-152)
COLORMAP_194:           /* store fg and bk; arithmetic modes: the op color, weights, pin and tables */
    movel %d4,%fp@(-160)
    movel %d5,%fp@(-164)
    btst #5,%d3
    jbeq COLORMAP_29C
    movew %fp@(-212),%d7
    movel %a2@(84),%d5
    tstw %a2@(6)
    jbmi COLORMAP_1DA
    movel %d5,%d0
    jbsr COLORMAP_2A2
    movel %d0,%d5
    lea HiliteRGB,%a2
    moveq #7,%d0
    andw %d3,%d0
    subqw #1,%d0
    jbeq COLORMAP_1CE
    jbmi COLORMAP_1D4
    lea %pc@(COLORMAP_2CE),%a0
    jbra COLORMAP_1E4
COLORMAP_1CE:           /* old-style port: default op color */
    lea %pc@(COLORMAP_2D4),%a0
    jbra COLORMAP_1E4
COLORMAP_1D4:           /* old-style port: default op color */
    lea %pc@(COLORMAP_2DA),%a0
    jbra COLORMAP_1E4
COLORMAP_1DA:           /* color port: the op color from the grafVars */
    moveal %a2@(8,%za0)@(0),%a0	| 4082EE6A
    lea %a0@(6),%a2
COLORMAP_1E4:           /* the weights (fp-244) and their negatives (fp-250), 0 taken as 1 */
    moveq #2,%d1
    lea %fp@(-244),%a1
    lea %fp@(-250),%a3
COLORMAP_1EE:           /* each of R, G, B */
    movew %a0@+,%d0
    jbne COLORMAP_1F4
    moveq #1,%d0
COLORMAP_1F4:           /* store */
    movew %d0,%a1@-
    negw %d0
    movew %d0,%a3@-
    dbf %d1,COLORMAP_1EE
    subqw #6,%sp
    subqw #4,%sp
    movel %a2,%sp@-
    jsr @(0x16cc,%za0)@(0)	| 4082EE94
    cmpl %sp@,%d5
    jbne COLORMAP_22C
    lea %sp@(4),%a1
    moveal %a2,%a0
    movel %a0@+,%a1@+
    movew %a0@+,%a1@+
    pea %sp@(4)
    jsr @(0x16d4,%za0)@(0)	| 4082EEAC
    pea %sp@(4)
    jsr @(0x16cc,%za0)@(0)	| 4082EEB6
COLORMAP_22C:           /* the color table (fp-264), the inverse table (fp-268), its resolution (fp-270) and shift (fp-272) */
    moveal @(TheGDevice,%za0)@(0),%a0	| 4082EEBC
    moveal %a0@(0x16,%za0)@(0x0),%a1
    moveal %a0@(6,%za0)@(0),%a0
    movew %a0@(4),%d0
    movew %d0,%fp@(-270)
    moveq #16,%d1
    subw %d0,%d1
    movew %d1,%fp@(-272)
    movel %a0,%d0
    jsr @(0x644,%za0)@(0x0)	| 4082EEE0
    movel %d0,%fp@(-268)
    moveal %a1@(0x2a,%za0)@(0),%a1	| 4082EEEA
    lea %a1@(10),%a1
    movel %a1,%d0
    jsr @(0x644,%za0)@(0x0)	| 4082EEF6
    movel %d0,%fp@(-264)
    movel %d5,%d2
    movel %sp@,%d4
    moveq #32,%d1
COLORMAP_276:           /* replicate the op color and its index across a long */
    subw %d7,%d1
    jble COLORMAP_284
    lsll %d7,%d2
    orl %d5,%d2
    lsll %d7,%d4
    orl %sp@,%d4
    jbra COLORMAP_276
COLORMAP_284:           /* store them (fp-276, fp-280); mode 36 (transparent) has no pin flag */
    movel %d2,%fp@(-276)
    movel %d4,%fp@(-280)
    lea %sp@(10),%sp
    cmpiw #36,%fp@(-152)
    jbne COLORMAP_29C
    clrw %fp@(-260)
COLORMAP_29C:           /* done */
    moveml %sp@+,%d3-%d7/%a2-%a3
    rts

COLORMAP_2A2:           /* an old-style color (d0) to its RGB through QDColors and then to an index */
    lsrw #1,%d0
    jbcs COLORMAP_2AA
    oriw #224,%d0
COLORMAP_2AA:           /* the color number (0..7) */
    lsrw #5,%d0
    andiw #7,%d0
    moveal QDColors,%a0
    movel %a0@(0x4,%d0:w:8),%sp@-
    movew %a0@(0x2,%d0:w:8),%sp@-
    clrl %sp@-
    pea %sp@(4)
    jsr @(0x16cc,%za0)@(0)	| 4082EF52
    movel %sp@+,%d0
    addqw #6,%sp
    rts
COLORMAP_2CE:           /* default op colors (RGB) */
    .short  0x0000	| 4082EF5E
    .long   0x00000000	| 4082EF60
COLORMAP_2D4:           /* default op color (data) */
    .short  0xFFFF, 0xFFFF, 0xFFFF	| 4082EF64
COLORMAP_2DA:           /* default op color (data) */
    .short  0x7FFF, 0x7FFF, 0x7FFF	| 4082EF6A

trap_GetCPixel:
GETCPIXEL:              /* GetCPixel(h, v, &rgb): GETPIXEL with the RGB result */
    movel %sp@(8),%sp@-
    moveq #1,%d2
    jbsr GETPIXEL_2
    rtd #8

trap_GetPixel:
GETPIXEL:               /* GetPixel(h, v): true if the pixel is black (not the background) */
    moveq #0,%d2

GETPIXEL_2:             /* d2 = 1 for GetCPixel. Point in global coordinates; on the screen: shield the cursor and find the device holding the point */
    linkw %fp,#0
    moveml %d4-%d5/%a2-%a3,%sp@-
    movel TheGDevice,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    jsr @(0x1a5c,%za0)@(0)	| 4082EF8E
    movew %fp@(8),%d4
    subw %a0@(6),%d4
    movew %fp@(10),%d5
    subw %a0@(8),%d5
    moveal MainDevice,%a2
    moveal %a2@,%a2
    moveal %a2@(22),%a2
    moveal %a2@,%a2
    movel %a0@,%d1
    cmpl %a2@,%d1
    seq %sp@-
    moveal %a0,%a3
    jbne GETPIXEL_9C
    movew %d5,%sp@-
    movew %d4,%sp@-
    movew %d5,%sp@-
    movew %d4,%sp@-
    moveal JShieldCursor,%a1
    jsr %a1@
    moveal DeviceList,%a3
GETPIXEL_50:            /* next device: active and the point inside its gdRect? */
    moveal %a3@,%a2
    tstw %a2@(20)
    jbpl GETPIXEL_6C
    lea %a2@(34),%a1
    cmpw %a1@+,%d4
    jble GETPIXEL_6C
    cmpw %a1@+,%d5
    jble GETPIXEL_6C
    cmpw %a1@+,%d4
    jbge GETPIXEL_6C
    cmpw %a1@+,%d5
    jblt GETPIXEL_76
GETPIXEL_6C:            /* next device; none: return */
    movel %a2@(30),%d0
    moveal %d0,%a3
    jbne GETPIXEL_50
    jbra GETPIXEL_F4
GETPIXEL_76:            /* found: make it the current device, point relative to it */
    movel %a3,TheGDevice
    lea %a2@(34),%a1
    subw %a1@+,%d4
    subw %a1@+,%d5
    moveal %a2@(22),%a3
    movel %a3@,%d0
    jsr @(0x644,%za0)@(0x0)	| 4082F004
    moveal %d0,%a3
    moveq #1,%d0
    movew %d2,%sp@-
    jsr @(0x574,%za0)@(0x0)	| 4082F010
    movew %sp@+,%d2
GETPIXEL_9C:            /* read the pixel (bfextu at the pixel size) */
    movew %a3@(4),%d1
    andiw #32767,%d1
    muluw %d4,%d1
    moveal %a3@,%a1
    addal %d1,%a1
    moveq #1,%d1
    tstw %a3@(4)
    jbpl GETPIXEL_B6
    movew %a3@(32),%d1
GETPIXEL_B6:            /* the pixel value */
    muluw %d1,%d5
    bfextu %a1@,%d5,%d1,%d4
    tstb %sp@
    jbeq GETPIXEL_CA
    movel %d2,%d5
    jsr @(0x574,%za0)@(0x0)	| 4082F03E
    movel %d5,%d2
GETPIXEL_CA:            /* GetCPixel: its RGB (Index2Color) */
    tstw %d2
    jbeq GETPIXEL_DC
    movel %d4,%sp@-
    movel %fp@(16),%sp@-
    jsr @(0x16d0,%za0)@(0)	| 4082F050
    jbra GETPIXEL_F4
GETPIXEL_DC:            /* direct pixels: black is 0 */
    cmpiw #16,%a3@(30)
    jbne GETPIXEL_EA
    tstl %d4
    seq %d4
    jbra GETPIXEL_EE
GETPIXEL_EA:            /* indexed: black is not 0 */
    tstw %d4
    sne %d4
GETPIXEL_EE:            /* the boolean result */
    negw %d4
    moveb %d4,%fp@(12)
GETPIXEL_F4:            /* on the screen: undo the shield (call through 0xF4C) */
    tstb %sp@+
    jbeq GETPIXEL_FE
    jsr @(0xf4c,%za0)@(0)	| 4082F074
GETPIXEL_FE:            /* restore the current device */
    movel %sp@+,TheGDevice
    moveml %sp@+,%d4-%d5/%a2-%a3
    unlk %fp
    rtd #4
    .long   0x00000000, 0x00000000	| 4082F088

trap_Translate24To32:
TRANSLATE24TO32:        /* Translate24To32(addr): a 24-bit address to 32-bit mode; bit 23 set: a NuBus slot address (Fs00 0000 form) */
    andl Lo3Bytes,%d0
    bclr #23,%d0
    jbne TRANSLATE24TO32_C
    rts
TRANSLATE24TO32_C:      /* NuBus slot space: move the slot nibble (Fs0x xxxx form) */
    movew %d1,%sp@-
    movew #12,%d1
    roll %d1,%d0
    moveb %d0,%d1
    jbeq TRANSLATE24TO32_26
    lsrl #4,%d0
    moveb %pc@(TRANSLATE24TO32_32:w,%d1:w),%d0	| 4082F0AA
    movew %sp@+,%d1
    rorl #8,%d0
    rts
TRANSLATE24TO32_26:     /* the 32-bit slot address */
    oriw #1032,%d0
    rorl #4,%d0
    rorl #8,%d0
    movew %sp@+,%d1
    rts
TRANSLATE24TO32_32:     /* (data) */
    .short  0x40F9, 0xFAFB, 0xFCFD, 0xFE50, 0x0000, 0x0000, 0x0000	| 4082F0C2

trap_StuffHex:
STUFFHEX:               /* StuffHex(ptr, string): the hex digits of the string as bytes at ptr */
    moveal %sp@(4),%a0
    moveal %sp@(8),%a1
    movel %sp@,%sp@(8)
    addqw #8,%sp
    moveb %a0@+,%d2
    andiw #254,%d2
    jbeq STUFFHEX_26
STUFFHEX_16:            /* two digits per byte */
    jbsr STUFFHEX_28
    moveb %d0,%d1
    jbsr STUFFHEX_28
    lslb #4,%d1
    addb %d0,%d1
    moveb %d1,%a1@+
    subqw #2,%d2
    jbne STUFFHEX_16
STUFFHEX_26:            /* done */
    rts

STUFFHEX_28:            /* the next hex digit's value */
    moveb %a0@+,%d0
    cmpib #57,%d0
    jble STUFFHEX_34
    addib #9,%d0
STUFFHEX_34:            /* the digit's value */
    andib #15,%d0
    rts
    .short  0x0000, 0x0000, 0x0000	| 4082F10A

trap_XORSLAB:
XORSLAB:                /* invert the bits d3..d4 (scaled by the pixel shift d0) of the row at a0 */
    extl %d4
    extl %d3
    lsll %d0,%d4
    lsll %d0,%d3
    movel %d4,%d0
    subl %d3,%d0
    jble XORSLAB_1A
    cmpil #32,%d0
    jbgt XORSLAB_1C
    bfchg %a0@,%d3,%d0
XORSLAB_1A:             /* return */
    rts
XORSLAB_1C:             /* more than one long: the edge masks */
    moveq #31,%d1
    movew %d3,%d0
    andw %d1,%d0
    moveq #-1,%d5
    lsrl %d0,%d5
    movew %d4,%d0
    andw %d1,%d0
    moveq #-1,%d6
    lsrl %d0,%d6
    notl %d6
    asrl #5,%d3
    asrl #5,%d4
    subw %d3,%d4
    subqw #1,%d4
    lslw #2,%d3
    addaw %d3,%a0
    eorl %d5,%a0@+
    jbra XORSLAB_42
XORSLAB_40:             /* middle longs */
    notl %a0@+
XORSLAB_42:             /* next long; then the right edge */
    dbf %d4,XORSLAB_40
    eorl %d6,%a0@
    rts
    .short  0x0000, 0x0000, 0x0000	| 4082F15A

trap_DRAWSLAB:
DRAWSLAB:               /* draw a slab of the row from d1 to d2, clipped to the rectangle at a3, through the slab loop at a4 */
    cmpw %a3@(2),%d1
    jbge DRAWSLAB_A
    movew %a3@(2),%d1
DRAWSLAB_A:             /* right edge */
    cmpw %a3@(6),%d2
    jble DRAWSLAB_14
    movew %a3@(6),%d2
DRAWSLAB_14:            /* empty? return; else the edge masks and the first long; enter the loop at a4 */
    cmpw %d2,%d1
    jbge DRAWSLAB_4A
    extl %d1
    extl %d2
    lsll %d0,%d1
    movel %d1,%fp@(-284)
    lsll %d0,%d2
    moveq #31,%d0
    andw %d0,%d1
    moveq #-1,%d3
    lsrl %d1,%d3
    andw %d2,%d0
    moveq #-1,%d1
    lsrl %d0,%d1
    notl %d1
    movel %fp@(-284),%d0
    asrl #5,%d2
    asrl #5,%d0
    subw %d0,%d2
    addw %d0,%d0
    addw %d0,%d0
    addaw %d0,%a1
    addaw %d0,%a2
    tstw %d2
    jmp %a4@
DRAWSLAB_4A:            /* empty slab */
    rts
    .long   0x00000000	| 4082F1AC
DRAWSLAB_50:            /* last long: the right edge mask */
    andl %d1,%d3
DRAWSLAB_52:            /* loop: copy; pattern; through the slab mask */
    movel %d6,%d0
    andl %a2@+,%d3
    andl %d3,%d0
    notl %d3
    andl %a1@,%d3
    orl %d0,%d3
    movel %d3,%a1@+
    moveq #-1,%d3
    subqw #1,%d2

trap_SLMASK8:
SLMASK8:                /* slab patCopy entry: d2 > 0 middle longs, = 0 last long (loop in DRAWSLAB) */
    jbgt DRAWSLAB_52
    jbeq DRAWSLAB_50
    rts
    .short  0x0000, 0x0000, 0x0000	| 4082F1CA
SLMASK8_C:              /* last long: the right edge mask */
    andl %d1,%d3
SLMASK8_E:              /* loop: pattern or: where the edge mask, pattern and slab mask are set, the foreground color d4 */
    andl %d6,%d3
    andl %a2@+,%d3
    movel %d3,%d0
    andl %d4,%d0
    notl %d3
    andl %a1@,%d3
    orl %d3,%d0
    movel %d0,%a1@+
    moveq #-1,%d3
    subqw #1,%d2

trap_SLMASK9:
SLMASK9:                /* slab patOr entry */
    jbgt SLMASK8_E
    jbeq SLMASK8_C
    rts
    .long   0x00000000	| 4082F1EC
SLMASK9_A:              /* last long: the right edge mask */
    andl %d1,%d3
SLMASK9_C:              /* loop: xor; pattern; through the slab mask */
    andl %d6,%d3
    andl %a2@+,%d3
    eorl %d3,%a1@+
    moveq #-1,%d3
    subqw #1,%d2

trap_SLMASK10:
SLMASK10:               /* slab patXor entry */
    jbgt SLMASK9_C
    jbeq SLMASK9_A
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082F202
SLMASK10_14:            /* last long: the right edge mask */
    andl %d1,%d3
SLMASK10_16:            /* loop: copy; pattern; through the slab mask */
    andl %d6,%d3
    andl %a2@+,%d3
    movel %d3,%d0
    andl %d5,%d0
    notl %d3
    andl %a1@,%d3
    orl %d3,%d0
    movel %d0,%a1@+
    moveq #-1,%d3
    subqw #1,%d2

trap_SLMASK11:
SLMASK11:               /* slab patBic entry */
    jbgt SLMASK10_16
    jbeq SLMASK10_14
    rts
    .long   0x00000000	| 4082F22C

trap_SLXMASK8:
SLXMASK8:               /* slab color-pattern copy: pattern row and offset, then the loop */
    movew %d7,%sp@-
    movew %fp@(-140),%d7
    movew %d0,%d6
    addw %fp@(-144),%d6
    andw %d7,%d6
    moveal %fp@(-136),%a3
    addal %fp@(-150),%a3
    tstw %d2
    jbra SLXMASK8_34
SLXMASK8_1A:            /* last long: the right edge mask */
    andl %d1,%d3
SLXMASK8_1C:            /* loop: copy; pattern; through the slab mask */
    movel %a3@(0x0,%d6:w),%d0
    addqw #4,%d6
    andw %d7,%d6
    andl %a2@+,%d3
    andl %d3,%d0
    notl %d3
    andl %a1@,%d3
    orl %d0,%d3
    movel %d3,%a1@+
    moveq #-1,%d3
    subqw #1,%d2
SLXMASK8_34:            /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLXMASK8_1C
    jbeq SLXMASK8_1A
    movew %sp@+,%d7
    rts
    .long   0x00000000	| 4082F26C

trap_SLXMASK9:
SLXMASK9:               /* slab color-pattern or */
    movew %d7,%sp@-
    movew %fp@(-140),%d7
    movew %d0,%d6
    addw %fp@(-144),%d6
    andw %d7,%d6
    moveal %fp@(-136),%a3
    addal %fp@(-150),%a3
    tstw %d2
    jbra SLXMASK9_36
SLXMASK9_1A:            /* last long: the right edge mask */
    andl %d1,%d3
SLXMASK9_1C:            /* loop: color pattern or through the slab mask */
    andl %a3@(0x0,%d6:w),%d3
    addqw #4,%d6
    andw %d7,%d6
    andl %a2@+,%d3
    movel %d3,%d0
    andl %d4,%d0
    notl %d3
    andl %a1@,%d3
    orl %d3,%d0
    movel %d0,%a1@+
    moveq #-1,%d3
    subqw #1,%d2
SLXMASK9_36:            /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLXMASK9_1C
    jbeq SLXMASK9_1A
    movew %sp@+,%d7
    rts
    .short  0x0000	| 4082F2AE

trap_SLXMASK10:
SLXMASK10:              /* slab color-pattern xor */
    movew %d7,%sp@-
    movew %fp@(-140),%d7
    movew %d0,%d6
    addw %fp@(-144),%d6
    andw %d7,%d6
    moveal %fp@(-136),%a3
    addal %fp@(-150),%a3
    tstw %d2
    jbra SLXMASK10_2C
SLXMASK10_1A:           /* last long: the right edge mask */
    andl %d1,%d3
SLXMASK10_1C:           /* loop: xor; pattern; through the slab mask */
    andl %a3@(0x0,%d6:w),%d3
    addqw #4,%d6
    andw %d7,%d6
    andl %a2@+,%d3
    eorl %d3,%a1@+
    moveq #-1,%d3
    subqw #1,%d2
SLXMASK10_2C:           /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLXMASK10_1C
    jbeq SLXMASK10_1A
    movew %sp@+,%d7
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4082F2E4

trap_SLXMASK11:
SLXMASK11:              /* slab color-pattern bic */
    movew %d7,%sp@-
    movew %fp@(-140),%d7
    movew %d0,%d6
    addw %fp@(-144),%d6
    andw %d7,%d6
    moveal %fp@(-136),%a3
    addal %fp@(-150),%a3
    tstw %d2
    jbra SLXMASK11_36
SLXMASK11_1A:           /* last long: the right edge mask */
    andl %d1,%d3
SLXMASK11_1C:           /* loop: copy; pattern; through the slab mask */
    andl %a3@(0x0,%d6:w),%d3
    addqw #4,%d6
    andw %d7,%d6
    andl %a2@+,%d3
    movel %d3,%d0
    andl %d5,%d0
    notl %d3
    andl %a1@,%d3
    orl %d3,%d0
    movel %d0,%a1@+
    moveq #-1,%d3
    subqw #1,%d2
SLXMASK11_36:           /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLXMASK11_1C
    jbeq SLXMASK11_1A
    movew %sp@+,%d7
    rts
    .short  0x0000	| 4082F32E

trap_SLADDOVER:
SLADDOVER:              /* slab addOver (indexed pixels) */
    moveml %d7/%a4-%a5,%sp@-
    jbsr SLADDOVER_70
    tstw %d2
    jbra SLADDOVER_5C
SLADDOVER_A:            /* last long: the right mask */
    andl %d1,%d3
SLADDOVER_C:            /* next pixel: inside the edge and slab masks? the source/pattern pixel's RGB */
    addl %d7,%d6
    andw %fp@(-140),%d6
    bfextu %d3,%d4,%d7,%d0
    jbeq SLADDOVER_4E
    bfextu %a2@,%d4,%d7,%d0
    jbeq SLADDOVER_4E
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a4
    bfextu %a1@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a5
    movew %a4@+,%d0
    addw %a5@+,%d0
    asll %d5,%d0
    movew %a4@+,%d0
    addw %a5@+,%d0
    asll %d5,%d0
    movew %a4@+,%d0
    addw %a5@+,%d0
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a1@,%d4,%d7
SLADDOVER_4E:           /* next pixel; end of the long: next long */
    addl %d7,%d4
    movew %d4,%d0
    andiw #31,%d0
    jbne SLADDOVER_C
    moveq #-1,%d3
    subqw #1,%d2
SLADDOVER_5C:           /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLADDOVER_C
    jbeq SLADDOVER_A
    moveml %sp@+,%d7/%a4-%a5
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082F396

SLADDOVER_70:           /* slab arithmetic set-up: pixel size, inverse table resolution, pattern */
    moveq #0,%d4
    movew %fp@(-270),%d5
    moveq #0,%d6
    moveq #0,%d7
    movew %fp@(-212),%d7
    moveal %a0,%a3
    cmpiw #4,%fp@(-142)
    jble SLADDOVER_A0
    movel %fp@(-284),%d6
    andil #-32,%d6
    moveaw %fp@(-144),%a0
    addl %a0,%d6
    moveal %fp@(-136),%a3
    addal %fp@(-150),%a3
SLADDOVER_A0:           /* the color table */
    subl %d7,%d6
    moveal %fp@(-264),%a0
    rts
    .long   0x00000000, 0x00000000	| 4082F3D8

trap_SLADDPIN:
SLADDPIN:               /* slab addPin */
    moveml %d7/%a4-%a5,%sp@-
    jbsr SLADDOVER_70
    tstw %d2
    jbra SLADDPIN_80
SLADDPIN_A:             /* last long: the right mask */
    andl %d1,%d3
SLADDPIN_C:             /* next pixel: inside the masks? the pixel's RGB */
    addl %d7,%d6
    andw %fp@(-140),%d6
    bfextu %d3,%d4,%d7,%d0
    jbeq SLADDPIN_72
    bfextu %a2@,%d4,%d7,%d0
    jbeq SLADDPIN_72
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a4
    bfextu %a1@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a5
    movew %a4@+,%d0
    addw %a5@+,%d0
    jbcs SLADDPIN_3A
    cmpw %fp@(-246),%d0
    jbls SLADDPIN_3E
SLADDPIN_3A:            /* pinned at the pin value */
    movew %fp@(-246),%d0
SLADDPIN_3E:            /* pack the component into the inverse table index */
    asll %d5,%d0
    movew %a4@+,%d0
    addw %a5@+,%d0
    jbcs SLADDPIN_4C
    cmpw %fp@(-248),%d0
    jbls SLADDPIN_50
SLADDPIN_4C:            /* pinned at the pin value */
    movew %fp@(-248),%d0
SLADDPIN_50:            /* pack the component into the inverse table index */
    asll %d5,%d0
    movew %a4@+,%d0
    addw %a5@+,%d0
    jbcs SLADDPIN_5E
    cmpw %fp@(-250),%d0
    jbls SLADDPIN_62
SLADDPIN_5E:            /* pinned at the pin value */
    movew %fp@(-250),%d0
SLADDPIN_62:            /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a1@,%d4,%d7
SLADDPIN_72:            /* next pixel; end of the long: next long */
    addl %d7,%d4
    movew %d4,%d0
    andiw #31,%d0
    jbne SLADDPIN_C
    moveq #-1,%d3
    subqw #1,%d2
SLADDPIN_80:            /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLADDPIN_C
    jbeq SLADDPIN_A
    moveml %sp@+,%d7/%a4-%a5
    rts
    .short  0x0000, 0x0000, 0x0000	| 4082F46A

trap_SLSUBOVER:
SLSUBOVER:              /* slab subOver */
    moveml %d7/%a4-%a5,%sp@-
    jbsr SLADDOVER_70
    tstw %d2
    jbra SLSUBOVER_5E
SLSUBOVER_C:            /* last long: the right mask */
    andl %d1,%d3
SLSUBOVER_E:            /* next pixel: inside the masks? the pixel's RGB */
    addl %d7,%d6
    andw %fp@(-140),%d6
    bfextu %d3,%d4,%d7,%d0
    jbeq SLSUBOVER_50
    bfextu %a2@,%d4,%d7,%d0
    jbeq SLSUBOVER_50
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a4
    bfextu %a1@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a5
    movew %a5@+,%d0
    subw %a4@+,%d0
    asll %d5,%d0
    movew %a5@+,%d0
    subw %a4@+,%d0
    asll %d5,%d0
    movew %a5@+,%d0
    subw %a4@+,%d0
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a1@,%d4,%d7
SLSUBOVER_50:           /* next pixel; end of the long: next long */
    addl %d7,%d4
    movew %d4,%d0
    andiw #31,%d0
    jbne SLSUBOVER_E
    moveq #-1,%d3
    subqw #1,%d2
SLSUBOVER_5E:           /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLSUBOVER_E
    jbeq SLSUBOVER_C
    moveml %sp@+,%d7/%a4-%a5
    rts
    .long   0x00000000, 0x00000000	| 4082F4D8

trap_SLSUBPIN:
SLSUBPIN:               /* slab subPin */
    moveml %d7/%a4-%a5,%sp@-
    jbsr SLADDOVER_70
    tstw %d2
    jbra SLSUBPIN_82
SLSUBPIN_C:             /* last long: the right mask */
    andl %d1,%d3
SLSUBPIN_E:             /* next pixel: inside the masks? the pixel's RGB */
    addl %d7,%d6
    andw %fp@(-140),%d6
    bfextu %d3,%d4,%d7,%d0
    jbeq SLSUBPIN_74
    bfextu %a2@,%d4,%d7,%d0
    jbeq SLSUBPIN_74
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a4
    bfextu %a1@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a5
    movew %a5@+,%d0
    subw %a4@+,%d0
    jbcs SLSUBPIN_3C
    cmpw %fp@(-246),%d0
    jbcc SLSUBPIN_40
SLSUBPIN_3C:            /* pinned at the pin value */
    movew %fp@(-246),%d0
SLSUBPIN_40:            /* pack the component into the inverse table index */
    asll %d5,%d0
    movew %a5@+,%d0
    subw %a4@+,%d0
    jbcs SLSUBPIN_4E
    cmpw %fp@(-248),%d0
    jbcc SLSUBPIN_52
SLSUBPIN_4E:            /* pinned at the pin value */
    movew %fp@(-248),%d0
SLSUBPIN_52:            /* pack the component into the inverse table index */
    asll %d5,%d0
    movew %a5@+,%d0
    subw %a4@+,%d0
    jbcs SLSUBPIN_60
    cmpw %fp@(-250),%d0
    jbcc SLSUBPIN_64
SLSUBPIN_60:            /* pinned at the pin value */
    movew %fp@(-250),%d0
SLSUBPIN_64:            /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a1@,%d4,%d7
SLSUBPIN_74:            /* next pixel; end of the long: next long */
    addl %d7,%d4
    movew %d4,%d0
    andiw #31,%d0
    jbne SLSUBPIN_E
    moveq #-1,%d3
    subqw #1,%d2
SLSUBPIN_82:            /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLSUBPIN_E
    jbeq SLSUBPIN_C
    moveml %sp@+,%d7/%a4-%a5
    rts
    .long   0x00000000	| 4082F56C

trap_SLMAX:
SLMAX:                  /* slab addMax */
    moveml %d7/%a4-%a5,%sp@-
    jbsr SLADDOVER_70
    tstw %d2
    jbra SLMAX_6E
SLMAX_C:                /* last long: the right mask */
    andl %d1,%d3
SLMAX_E:                /* next pixel: inside the masks? the pixel's RGB */
    addl %d7,%d6
    andw %fp@(-140),%d6
    bfextu %d3,%d4,%d7,%d0
    jbeq SLMAX_60
    bfextu %a2@,%d4,%d7,%d0
    jbeq SLMAX_60
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a4
    bfextu %a1@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a5
    movew %a4@+,%d0
    cmpw %a5@,%d0
    jbcc SLMAX_38
    movew %a5@,%d0
SLMAX_38:               /* next pixel */
    addqw #2,%a5
    asll %d5,%d0
    movew %a4@+,%d0
    cmpw %a5@,%d0
    jbcc SLMAX_44
    movew %a5@,%d0
SLMAX_44:               /* next pixel */
    addqw #2,%a5
    asll %d5,%d0
    movew %a4@+,%d0
    cmpw %a5@,%d0
    jbcc SLMAX_50
    movew %a5@,%d0
SLMAX_50:               /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a1@,%d4,%d7
SLMAX_60:               /* next pixel; end of the long: next long */
    addl %d7,%d4
    movew %d4,%d0
    andiw #31,%d0
    jbne SLMAX_E
    moveq #-1,%d3
    subqw #1,%d2
SLMAX_6E:               /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLMAX_E
    jbeq SLMAX_C
    moveml %sp@+,%d7/%a4-%a5
    rts
    .long   0x00000000, 0x00000000	| 4082F5E8

trap_SLMIN:
SLMIN:                  /* slab adMin */
    moveml %d7/%a4-%a5,%sp@-
    jbsr SLADDOVER_70
    tstw %d2
    jbra SLMIN_6E
SLMIN_C:                /* last long: the right mask */
    andl %d1,%d3
SLMIN_E:                /* next pixel: inside the masks? the pixel's RGB */
    addl %d7,%d6
    andw %fp@(-140),%d6
    bfextu %d3,%d4,%d7,%d0
    jbeq SLMIN_60
    bfextu %a2@,%d4,%d7,%d0
    jbeq SLMIN_60
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a4
    bfextu %a1@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a5
    movew %a4@+,%d0
    cmpw %a5@,%d0
    jbls SLMIN_38
    movew %a5@,%d0
SLMIN_38:               /* next pixel */
    addqw #2,%a5
    asll %d5,%d0
    movew %a4@+,%d0
    cmpw %a5@,%d0
    jbls SLMIN_44
    movew %a5@,%d0
SLMIN_44:               /* next pixel */
    addqw #2,%a5
    asll %d5,%d0
    movew %a4@+,%d0
    cmpw %a5@,%d0
    jbls SLMIN_50
    movew %a5@,%d0
SLMIN_50:               /* pack the component into the inverse table index */
    asll %d5,%d0
    swap %d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a1@,%d4,%d7
SLMIN_60:               /* next pixel; end of the long: next long */
    addl %d7,%d4
    movew %d4,%d0
    andiw #31,%d0
    jbne SLMIN_E
    moveq #-1,%d3
    subqw #1,%d2
SLMIN_6E:               /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLMIN_E
    jbeq SLMIN_C
    moveml %sp@+,%d7/%a4-%a5
    rts
    .long   0x00000000, 0x00000000	| 4082F668

trap_SLAVG:
SLAVG:                  /* slab blend */
    moveml %d7/%a4-%a5,%sp@-
    movel %d1,%sp@-
    jbsr SLADDOVER_70
    tstw %d2
    jbra SLAVG_9E
SLAVG_10:               /* last long: the right mask */
    andl %sp@+,%d3
SLAVG_12:               /* each of R, G, B: weighted average (blend) */
    addl %d7,%d6
    andw %fp@(-140),%d6
    bfextu %d3,%d4,%d7,%d0
    jbeq SLAVG_8E
    bfextu %a2@,%d4,%d7,%d0
    jbeq SLAVG_8E
    bfextu %a3@,%d6,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a4
    bfextu %a1@,%d4,%d7,%d0
    lea %a0@(0x0,%d0:w:8),%a5
    movew %a4@+,%d0
    muluw %fp@(-246),%d0
    movew %a5@+,%d1
    muluw %fp@(-252),%d1
    addl %d1,%d0
    clrw %d0
    swap %d0
    asll %d5,%d0
    swap %d0
    aslw %d5,%d0
    aslw %d5,%d0
    movew %d0,%sp@-
    movew %a4@+,%d0
    muluw %fp@(-248),%d0
    movew %a5@+,%d1
    muluw %fp@(-254),%d1
    addl %d1,%d0
    clrw %d0
    swap %d0
    asll %d5,%d0
    swap %d0
    aslw %d5,%d0
    orw %d0,%sp@
    movew %a4@+,%d0
    muluw %fp@(-250),%d0
    movew %a5@+,%d1
    muluw %fp@(-256),%d1
    addl %d1,%d0
    clrw %d0
    swap %d0
    asll %d5,%d0
    swap %d0
    orw %sp@+,%d0
    moveb %fp@(0xfffffffffffffef4)@(0x6,%d0:w),%d0
    bfins %d0,%a1@,%d4,%d7
SLAVG_8E:               /* next pixel; end of the long: next long */
    addl %d7,%d4
    movew %d4,%d0
    andiw #31,%d0
    jbne SLAVG_12
    moveq #-1,%d3
    subqw #1,%d2
SLAVG_9E:               /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLAVG_12
    jbeq SLAVG_10
    moveml %sp@+,%d7/%a4-%a5
    rts
    .long   0x00000000	| 4082F71C

trap_SLHILITE:
SLHILITE:               /* slab hilite (fp-276 background, fp-280 hilite color): pixels of the background become the hilite color and back, inside the slab where the pattern is set */
    moveml %d7/%a4-%a5,%sp@-
    jbsr SLADDOVER_70
    bfextu %fp@(-276),0,%d7,%d5
    bfextu %fp@(-280),0,%d7,%d0
    moveal %d0,%a0
    tstw %d2
    jbra SLHILITE_5A
SLHILITE_1A:            /* last long: the right mask */
    andl %d1,%d3
SLHILITE_1C:            /* next pixel: inside the edge mask and the slab mask, pattern pixel set? swap background and hilite */
    addl %d7,%d6
    andw %fp@(-140),%d6
    bfextu %d3,%d4,%d7,%d0
    jbeq SLHILITE_4C
    bfextu %a2@,%d4,%d7,%d0
    jbeq SLHILITE_4C
    bfextu %a3@,%d6,%d7,%d0
    jbeq SLHILITE_4C
    bfextu %a1@,%d4,%d7,%d0
    cmpl %d5,%d0
    jbne SLHILITE_44
    movel %a0,%d0
    bfins %d0,%a1@,%d4,%d7
    jbra SLHILITE_4C
SLHILITE_44:            /* hilite color: becomes background */
    cmpl %a0,%d0
    jbne SLHILITE_4C
    bfins %d5,%a1@,%d4,%d7
SLHILITE_4C:            /* next pixel; end of the long: next long */
    addl %d7,%d4
    movew %d4,%d0
    andiw #31,%d0
    jbne SLHILITE_1C
    moveq #-1,%d3
    subqw #1,%d2
SLHILITE_5A:            /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLHILITE_1C
    jbeq SLHILITE_1A
    moveml %sp@+,%d7/%a4-%a5
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4082F784

trap_SLTRANSPARENT:
SLTRANSPARENT:          /* slab transparent (fp-276 background color): every source pixel that is not the background is copied, inside the slab mask */
    moveml %d7/%a4-%a5,%sp@-
    jbsr SLADDOVER_70
    bfextu %fp@(-276),0,%d7,%d5
    tstw %d2
    jbra SLTRANSPARENT_40
SLTRANSPARENT_12:       /* last long: the right mask */
    andl %d1,%d3
SLTRANSPARENT_14:       /* next pixel: inside the edge mask and the slab mask? source not the background? insert it */
    addl %d7,%d6
    andw %fp@(-140),%d6
    bfextu %d3,%d4,%d7,%d0
    jbeq SLTRANSPARENT_32
    bfextu %a2@,%d4,%d7,%d0
    jbeq SLTRANSPARENT_32
    bfextu %a3@,%d6,%d7,%d0
    cmpl %d5,%d0
    jbeq SLTRANSPARENT_32
    bfins %d0,%a1@,%d4,%d7
SLTRANSPARENT_32:       /* next pixel; end of the long: next long */
    addl %d7,%d4
    movew %d4,%d0
    andiw #31,%d0
    jbne SLTRANSPARENT_14
    moveq #-1,%d3
    subqw #1,%d2
SLTRANSPARENT_40:       /* (entry: d2 > 0 middle longs, = 0 last long) */
    jbgt SLTRANSPARENT_14
    jbeq SLTRANSPARENT_12
    moveml %sp@+,%d7/%a4-%a5
    rts
    .short  0x0000, 0x0000, 0x0000	| 4082F7DA
/* 32-bit slab, addOver (SLARITH32TAB): each component added, carries dropped (0x7F7F7F / 0x808080 masks) */
    .short  0x2F07	| 4082F7E0
    bsrw SLTRANSPARENT_90
    movel #8355711,%d0
    moveal #8421504,%a0
SLTRANSPARENT_62:       /* next pixel: inside the slab mask? */
    tstl %a2@+
    jbeq SLTRANSPARENT_80
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
SLTRANSPARENT_80:       /* next pixel; end of the slab: return */
    addql #4,%a1
    addql #4,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_62
    movel %sp@+,%d7
    rts
    .short  0x0000	| 4082F81E

SLTRANSPARENT_90:       /* 32-bit slab set-up: d2 = pixel count - 1, the pattern/source offset (d6) and row (a3) */
    subqw #1,%d2
    movew %fp@(-140),%d4
    movew %d0,%d6
    addw %fp@(-144),%d6
    andw %d4,%d6
    moveal %fp@(-136),%a3
    addal %fp@(-150),%a3
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4082F838
/* 32-bit slab, addPin: each component added and pinned at the pin color */
    .short  0x2047	| 4082F840
    jbsr SLTRANSPARENT_90
    moveq #0,%d3
    moveb %fp@(-246),%d3
    swap %d3
    movew %fp@(-248),%d3
    moveb %fp@(-250),%d3
    movel Lo3Bytes,%d1
SLTRANSPARENT_C8:       /* next pixel: inside the slab mask? */
    tstl %a2@+
    jbeq SLTRANSPARENT_104
    movel %a3@(0x0,%d6:w),%d7
    andl %d1,%d7
    movel %d7,%d0
    movel %a1@,%d5
    andl %d1,%d5
    clrb %d0
    addw %d5,%d0
    jbcs SLTRANSPARENT_E2
    cmpw %d3,%d0
    jbls SLTRANSPARENT_E4
SLTRANSPARENT_E2:       /* pinned */
    movew %d3,%d0
SLTRANSPARENT_E4:       /* next component */
    moveb %d7,%d0
    addb %d5,%d0
    jbcs SLTRANSPARENT_EE
    cmpb %d3,%d0
    jbls SLTRANSPARENT_F0
SLTRANSPARENT_EE:       /* pinned */
    moveb %d3,%d0
SLTRANSPARENT_F0:       /* combine the components */
    clrw %d5
    addl %d5,%d0
    cmpl %d3,%d0
    jbls SLTRANSPARENT_102
    swap %d3
    swap %d0
    movew %d3,%d0
    swap %d0
    swap %d3
SLTRANSPARENT_102:      /* store the pixel */
    movel %d0,%a1@
SLTRANSPARENT_104:      /* next pixel; end of the slab: return */
    addql #4,%a1
    addql #4,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_C8
    movel %a0,%d7
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082F8A2
/* 32-bit slab, subOver: each component subtracted, borrows dropped */
    .short  0x2047	| 4082F8B0
    jbsr SLTRANSPARENT_90
    movel #8355711,%d0
    movel #8421504,%d1
SLTRANSPARENT_132:      /* next pixel: inside the slab mask? */
    tstl %a2@+
    jbeq SLTRANSPARENT_154
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
SLTRANSPARENT_154:      /* next pixel; end of the slab: return */
    addql #4,%a1
    addql #4,%d6
    andw %fp@(-140),%d6
    dbf %d2,SLTRANSPARENT_132
    movel %a0,%d7
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082F8F4
/* 32-bit slab, subPin: each component subtracted and pinned */
    .short  0x2047	| 4082F900
    jbsr SLTRANSPARENT_90
    moveq #0,%d3
    moveb %fp@(-246),%d3
    swap %d3
    movew %fp@(-248),%d3
    moveb %fp@(-250),%d3
    movel Lo3Bytes,%d1
SLTRANSPARENT_18A:      /* next pixel: inside the slab mask? */
    tstl %a2@+
    jbeq SLTRANSPARENT_1C6
    movel %a3@(0x0,%d6:w),%d5
    andl %d1,%d5
    movel %a1@,%d7
    andl %d1,%d7
    movel %d7,%d0
    st %d0
    subw %d5,%d0
    jbcs SLTRANSPARENT_1A4
    cmpw %d3,%d0
    jbcc SLTRANSPARENT_1A6
SLTRANSPARENT_1A4:      /* pinned */
    movew %d3,%d0
SLTRANSPARENT_1A6:      /* next component */
    moveb %d7,%d0
    subb %d5,%d0
    jbcs SLTRANSPARENT_1B0
    cmpb %d3,%d0
    jbcc SLTRANSPARENT_1B2
SLTRANSPARENT_1B0:      /* pinned */
    moveb %d3,%d0
SLTRANSPARENT_1B2:      /* combine the components */
    clrw %d5
    subl %d5,%d0
    cmpl %d3,%d0
    jbge SLTRANSPARENT_1C4
    swap %d3
    swap %d0
    movew %d3,%d0
    swap %d0
    swap %d3
SLTRANSPARENT_1C4:      /* store the pixel */
    movel %d0,%a1@
SLTRANSPARENT_1C6:      /* next pixel; end of the slab: return */
    addql #4,%a1
    addql #4,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_18A
    movel %a0,%d7
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4082F964
/* 32-bit slab, addMax: the larger of each component */
    bsrw SLTRANSPARENT_90
SLTRANSPARENT_1C6_1E:   /* 32-bit slab addMax: next pixel inside the mask: the larger of each component */
    tstl %a2@+
    beqs SLTRANSPARENT_1C6_46
    movel %a3@(0x0,%d6:w),%d1
    movel %a1@,%d5
    movel %d5,%d0
    cmpw %d1,%d0
    bhis SLTRANSPARENT_1C6_32
    movew %d1,%d0
    moveb %d5,%d0
SLTRANSPARENT_1C6_32:   /* green */
    cmpb %d1,%d5
    bhis SLTRANSPARENT_1C6_38
    moveb %d1,%d0
SLTRANSPARENT_1C6_38:   /* red */
    swap %d1
    swap %d0
    cmpb %d1,%d0
    bhis SLTRANSPARENT_1C6_42
    moveb %d1,%d0
SLTRANSPARENT_1C6_42:   /* store */
    swap %d0
    movel %d0,%a1@
SLTRANSPARENT_1C6_46:   /* next pixel; end of the slab: return */
    addql #4,%a1
    addql #4,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_1C6_1E
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4082F9A8
/* 32-bit slab, adMin: the smaller of each component */
    bsrw SLTRANSPARENT_90
SLTRANSPARENT_1C6_5E:   /* 32-bit slab adMin: next pixel inside the mask: the smaller of each component */
    tstl %a2@+
    beqs SLTRANSPARENT_1C6_86
    movel %a3@(0x0,%d6:w),%d1
    movel %a1@,%d5
    movel %d5,%d0
    cmpw %d1,%d0
    blss SLTRANSPARENT_1C6_72
    movew %d1,%d0
    moveb %d5,%d0
SLTRANSPARENT_1C6_72:   /* green */
    cmpb %d1,%d5
    blss SLTRANSPARENT_1C6_78
    moveb %d1,%d0
SLTRANSPARENT_1C6_78:   /* red */
    swap %d1
    swap %d0
    cmpb %d1,%d0
    blss SLTRANSPARENT_1C6_82
    moveb %d1,%d0
SLTRANSPARENT_1C6_82:   /* store */
    swap %d0
    movel %d0,%a1@
SLTRANSPARENT_1C6_86:   /* next pixel; end of the slab: return */
    addql #4,%a1
    addql #4,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_1C6_5E
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4082F9E8
/* 32-bit slab, blend: each component weighted by the op color */
    lea %pc@(SLTRANSPARENT_1C6_86_44),%a4	| 4082F9F0
    lea %fp@(-250),%a0
    movew %a0@+,%d3
    cmpw %a0@+,%d3
    bnes SLTRANSPARENT_1C6_86_44	| 4082F9FC
    cmpw %a0@,%d3
    bnes SLTRANSPARENT_1C6_86_44	| 4082FA00
    addqw #1,%d3
    andiw #-2,%d3
    cmpiw #-32768,%d3
    bnes SLTRANSPARENT_1C6_86_44	| 4082FA0C
    lea %pc@(SLTRANSPARENT_30A_16),%a4
    braw SLTRANSPARENT_30A_16
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082FA16
SLTRANSPARENT_1C6_86_44:
    movel %d7,%sp@-	| 4082FA20
    jbsr SLTRANSPARENT_90
    lea %fp@(-250),%a0
    movel %a0@+,%d1
    movew %a0@,%d0
    moveq #0,%d4
    movel %d4,%d3
    moveal %d4,%a0
SLTRANSPARENT_2A4:      /* next pixel: inside the slab mask? */
    tstl %a2@+
    jbeq SLTRANSPARENT_30A
    movel %a3@(0x0,%d6:w),%d7
    movel %a1@,%d5
    cmpl %d3,%d7
    jbne SLTRANSPARENT_2B6
    cmpl %a0,%d5
    jbeq SLTRANSPARENT_308
SLTRANSPARENT_2B6:      /* each component weighted by the op color */
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
SLTRANSPARENT_308:      /* store the pixel */
    movel %d4,%a1@
SLTRANSPARENT_30A:      /* next pixel; end of the slab: return */
    addql #4,%a1
    addql #4,%d6
    andw %fp@(-140),%d6
    dbf %d2,SLTRANSPARENT_2A4
    movel %sp@+,%d7
    rts
    .short  0x0000, 0x0000, 0x0000	| 4082FAAA
/* 32-bit slab, blend at 50%: (a >> 1) + (b >> 1) per component plus the carry of the low bits */
SLTRANSPARENT_30A_16:
    bsrw SLTRANSPARENT_90
    movel #8355711,%d0
    moveal #65793,%a0
SLTRANSPARENT_30A_26:   /* 32-bit slab blend at 50%: next pixel inside the mask: (a >> 1) + (b >> 1) plus the low-bit carry */
    tstl %a2@+
    beqs SLTRANSPARENT_30A_44
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
SLTRANSPARENT_30A_44:   /* next pixel; end of the slab: return */
    addql #4,%a1
    addql #4,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_30A_26
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 4082FAEE
/* 32-bit slab, transparent: the source unless it is the background color */
    bsrw SLTRANSPARENT_90
    movel %fp@(-276),%d5
SLTRANSPARENT_30A_5E:   /* 32-bit slab transparent: next pixel inside the mask: copy it unless it is the background color */
    tstl %a2@+
    beqs SLTRANSPARENT_30A_6C
    movel %a3@(0x0,%d6:w),%d1
    cmpl %d1,%d5
    beqs SLTRANSPARENT_30A_6C
    movel %d1,%a1@
SLTRANSPARENT_30A_6C:   /* next pixel; end of the slab: return */
    addql #4,%a1
    addql #4,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_30A_5E
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082FB12
/* 16-bit slab, addOver (SLARITH16TAB): each 5-bit component added, carries dropped */
    .short  0x2F07	| 4082FB20
    jbsr SLTRANSPARENT_3D0
    movew #15855,%d0
    moveaw #16912,%a0
SLTRANSPARENT_39C:      /* next pixel: inside the slab mask? */
    tstw %a2@+
    jbeq SLTRANSPARENT_3BA
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
SLTRANSPARENT_3BA:      /* next pixel; end of the slab: return */
    addql #2,%a1
    addql #2,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_39C
    movel %sp@+,%d7
    rts
    .long   0x00000000, 0x00000000	| 4082FB58

SLTRANSPARENT_3D0:      /* 16-bit slab set-up: pixel count from the edge masks (d1, d3); skip a masked-off first pixel */
    aslw #1,%d2
    jbeq SLTRANSPARENT_404
    subqw #1,%d2
    negw %d1
    addw %d1,%d2
    swap %d1
    negw %d1
    addw %d1,%d2
    tstl %d3
    jbmi SLTRANSPARENT_3EE
    subqw #1,%d2
SLTRANSPARENT_3E6:      /* skip the first pixel */
    addqw #2,%a2
    addqw #2,%a3
    addqw #2,%a1
    addqw #2,%d0
SLTRANSPARENT_3EE:      /* the pattern/source offset (d6) and row (a3) */
    movew %fp@(-140),%d4
    movew %d0,%d6
    addw %fp@(-144),%d6
    andw %d4,%d6
    moveal %fp@(-136),%a3
    addal %fp@(-150),%a3
    rts
SLTRANSPARENT_404:      /* one long: a single pixel? */
    andl %d1,%d3
    jbpl SLTRANSPARENT_3E6
    negw %d3
    addw %d3,%d2
    jbra SLTRANSPARENT_3EE
    .short  0x0000	| 4082FB9E
/* 16-bit slab, addPin: each component added and pinned at the pin color */
    .short  0x2F07	| 4082FBA0
    jbsr SLTRANSPARENT_3D0
    moveq #0,%d3
    moveb %fp@(-246),%d3
    lsrb #3,%d3
    swap %d3
    movew %fp@(-248),%d3
    lsrw #3,%d3
    moveb %fp@(-250),%d3
    lsrb #3,%d3
SLTRANSPARENT_42A:      /* next pixel: inside the slab mask? */
    tstw %a2@+
    jbeq SLTRANSPARENT_46A
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
    jbls SLTRANSPARENT_452
    movel %d3,%d0
SLTRANSPARENT_452:      /* next component */
    movew %d7,%d0
    cmpw %d3,%d0
    jbls SLTRANSPARENT_45A
    movew %d3,%d0
SLTRANSPARENT_45A:      /* next component */
    moveb %d7,%d0
    cmpb %d3,%d0
    jbls SLTRANSPARENT_462
    moveb %d3,%d0
SLTRANSPARENT_462:      /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a1@
SLTRANSPARENT_46A:      /* next pixel; end of the slab: return */
    addql #2,%a1
    addql #2,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_42A
    movel %sp@+,%d7
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4082FC08
/* 16-bit slab, subOver: each component subtracted, borrows dropped */
    .short  0x2F07	| 4082FC10
    jbsr SLTRANSPARENT_3D0
    movew #15855,%d0
    movew #16912,%d1
SLTRANSPARENT_48E:      /* next pixel: inside the slab mask? */
    tstw %a2@+
    jbeq SLTRANSPARENT_4B0
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
SLTRANSPARENT_4B0:      /* next pixel; end of the slab: return */
    addql #2,%a1
    addql #2,%d6
    andw %fp@(-140),%d6
    dbf %d2,SLTRANSPARENT_48E
    movel %sp@+,%d7
    rts
/* 16-bit slab, subPin: each component subtracted and pinned */
    .short  0x2F07	| 4082FC50
    jbsr SLTRANSPARENT_3D0
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
SLTRANSPARENT_4E4:      /* next pixel: inside the slab mask? */
    tstw %a2@+
    jbeq SLTRANSPARENT_526
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
    addl %d1,%d5
    subl %d7,%d5
    movel %d5,%d0
    cmpl %d3,%d0
    jbcc SLTRANSPARENT_50E
    movel %d3,%d0
SLTRANSPARENT_50E:      /* next component */
    movew %d5,%d0
    cmpw %d3,%d0
    jbcc SLTRANSPARENT_516
    movew %d3,%d0
SLTRANSPARENT_516:      /* next component */
    moveb %d5,%d0
    cmpb %d3,%d0
    jbcc SLTRANSPARENT_51E
    moveb %d3,%d0
SLTRANSPARENT_51E:      /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a1@
SLTRANSPARENT_526:      /* next pixel; end of the slab: return */
    addql #2,%a1
    addql #2,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_4E4
    movel %sp@+,%d7
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082FCC4
/* 16-bit slab, addMax: the larger of each component */
    .short  0x2F07	| 4082FCD0
    jbsr SLTRANSPARENT_3D0
SLTRANSPARENT_546:      /* next pixel: inside the slab mask? */
    tstw %a2@+
    jbeq SLTRANSPARENT_584
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
    jbcc SLTRANSPARENT_56C
    movel %d5,%d0
SLTRANSPARENT_56C:      /* next component */
    movew %d7,%d0
    cmpw %d5,%d0
    jbcc SLTRANSPARENT_574
    movew %d5,%d0
SLTRANSPARENT_574:      /* next component */
    moveb %d7,%d0
    cmpb %d5,%d0
    jbcc SLTRANSPARENT_57C
    moveb %d5,%d0
SLTRANSPARENT_57C:      /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a1@
SLTRANSPARENT_584:      /* next pixel; end of the slab: return */
    addql #2,%a1
    addql #2,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_546
    movel %sp@+,%d7
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082FD22
/* 16-bit slab, adMin: the smaller of each component */
    .short  0x2F07	| 4082FD30
    jbsr SLTRANSPARENT_3D0
SLTRANSPARENT_5A6:      /* next pixel: inside the slab mask? */
    tstw %a2@+
    jbeq SLTRANSPARENT_5E4
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
    jbls SLTRANSPARENT_5CC
    movel %d5,%d0
SLTRANSPARENT_5CC:      /* next component */
    movew %d7,%d0
    cmpw %d5,%d0
    jbls SLTRANSPARENT_5D4
    movew %d5,%d0
SLTRANSPARENT_5D4:      /* next component */
    moveb %d7,%d0
    cmpb %d5,%d0
    jbls SLTRANSPARENT_5DC
    moveb %d5,%d0
SLTRANSPARENT_5DC:      /* pack the components back into the 5-5-5 pixel */
    lslb #3,%d0
    lslw #3,%d0
    lsrl #6,%d0
    movew %d0,%a1@
SLTRANSPARENT_5E4:      /* next pixel; end of the slab: return */
    addql #2,%a1
    addql #2,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_5A6
    movel %sp@+,%d7
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082FD82
/* 16-bit slab, blend: each component weighted by the op color */
    lea %pc@(SLTRANSPARENT_5E4_4C),%a4	| 4082FD90
    lea %fp@(-250),%a0
    movew %a0@+,%d5
    cmpw %a0@+,%d5
    bnes SLTRANSPARENT_5E4_4C	| 4082FD9C
    cmpw %a0@,%d5
    bnes SLTRANSPARENT_5E4_4C	| 4082FDA0
    addqw #1,%d5
    andiw #-2,%d5
    cmpiw #-32768,%d5
    bnes SLTRANSPARENT_5E4_4C	| 4082FDAC
    lea %pc@(SLTRANSPARENT_6D0_10),%a4
    braw SLTRANSPARENT_6D0_10
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082FDB6
SLTRANSPARENT_5E4_4C:
    movel %d7,%sp@-	| 4082FDC0
    jbsr SLTRANSPARENT_3D0
    lea %fp@(-250),%a0
    movel %a0@+,%d1
    movew %a0@,%d0
    moveq #0,%d4
    movel %d4,%d3
    moveal %d4,%a0
SLTRANSPARENT_644:      /* next pixel: inside the slab mask? */
    tstw %a2@+
    jbeq SLTRANSPARENT_6D0
    moveq #0,%d7
    movew %a3@(0x0,%d6:w),%d7
    moveq #0,%d5
    movew %a1@,%d5
    cmpw %d3,%d7
    jbne SLTRANSPARENT_65C
    cmpw %a0,%d5
    jbeq SLTRANSPARENT_6CE
SLTRANSPARENT_65C:      /* unpack the 5-bit components, weight each one */
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
SLTRANSPARENT_6CE:      /* store the pixel */
    movew %d4,%a1@
SLTRANSPARENT_6D0:      /* next pixel; end of the slab: return */
    addql #2,%a1
    addql #2,%d6
    andw %fp@(-140),%d6
    dbf %d2,SLTRANSPARENT_644
    movel %sp@+,%d7
    rts
/* 16-bit slab, blend at 50%: (a >> 1) + (b >> 1) per component plus the carry of the low bits */
SLTRANSPARENT_6D0_10:
    bsrw SLTRANSPARENT_3D0
    movew #15855,%d0
    moveaw #1057,%a0
SLTRANSPARENT_6D0_1C:   /* 16-bit slab blend at 50%: next pixel inside the mask */
    tstw %a2@+
    beqs SLTRANSPARENT_6D0_3A
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
SLTRANSPARENT_6D0_3A:   /* next pixel; end of the slab: return */
    addql #2,%a1
    addql #2,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_6D0_1C
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082FEA6
/* 16-bit slab, transparent: the source unless it is the background color */
    bsrw SLTRANSPARENT_3D0
    movel %fp@(-276),%d5
SLTRANSPARENT_6D0_58:   /* 16-bit slab transparent: next pixel inside the mask: copy it unless it is the background color */
    tstw %a2@+
    beqs SLTRANSPARENT_6D0_66
    movew %a3@(0x0,%d6:w),%d1
    cmpw %d1,%d5
    beqs SLTRANSPARENT_6D0_66
    movew %d1,%a1@
SLTRANSPARENT_6D0_66:   /* next pixel; end of the slab: return */
    addql #2,%a1
    addql #2,%d6
    andw %d4,%d6
    dbf %d2,SLTRANSPARENT_6D0_58
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4082FED2

trap_SLABMODE:
SLABMODE:               /* the slab loop for a mode (d2): a4 from the table at 0x1C00 (boolean modes), 0x1CF8 (16-bit arithmetic) or 0x1CF4 (32-bit arithmetic) */
    andiw #55,%d2
    bclr #5,%d2
    jbeq SLABMODE_54
    bclr #4,%d2
    jbeq SLABMODE_12
    moveq #8,%d2
SLABMODE_12:            /* arithmetic: at 16/32 bits their own tables; indexed: the pattern row mask from the pixel size */
    cmpiw #16,%fp@(-212)
    jbge SLABMODE_6C
    addqw #8,%d2
    movew #31,%fp@(-140)
    cmpiw #4,%fp@(-142)
    jble SLABMODE_62
    moveml %d2-%d3,%sp@-
    movew %fp@(-212),%d3
    subqw #1,%d3
    notw %d3
    movew %fp@(-142),%d2
    aslw #3,%d2
    subqw #1,%d2
    andw %d3,%d2
    movew %d2,%fp@(-140)
    movew %fp@(-144),%d2
    aslw #3,%d2
    movew %d2,%fp@(-144)
    moveml %sp@+,%d2-%d3
    jbra SLABMODE_62
SLABMODE_54:            /* boolean: a color pattern (fp-142 > 4) uses the next four entries */
    andiw #3,%d2
    cmpiw #4,%fp@(-142)
    jble SLABMODE_62
    addqw #4,%d2
SLABMODE_62:            /* the routine from the 0x1C00 table */
    lea 0x1c00,%a4
    moveal %a4@(0x0,%d2:w:4),%a4
    rts
SLABMODE_6C:            /* 16-bit (0x1CF8) */
    jbeq SLABMODE_78
    moveal 0x1cf8,%a4
    addal %a4@(0x0,%d2:w:4),%a4
    rts
SLABMODE_78:            /* 32-bit (0x1CF4) */
    moveal 0x1cf4,%a4
    addal %a4@(0x0,%d2:w:4),%a4
    movew %fp@(-140),%d2
    bset #1,%d2
    movew %d2,%fp@(-140)
    rts
    .short  0x0000	| 4082FF6E

/* SLARITH16TAB: table. */
trap_SLARITH16TAB:
SLARITH16TAB:
    .long   0xFFFFFE20, 0xFFFFFC30, 0xFFFFFBB0, 0xFFFFFCE0	| 4082FF70
    .long   0xFFFFFF40, 0xFFFFFD60, 0xFFFFFCA0, 0xFFFFFDC0	| 4082FF80
    .long   0xFFFFF7B0	| 4082FF90

/* SLARITH32TAB: table. */
trap_SLARITH32TAB:
SLARITH32TAB:
    .long   0xFFFFFA5C, 0xFFFFF8AC, 0xFFFFF84C	| 4082FF94
    .long   0xFFFFF96C, 0xFFFFFB5C, 0xFFFFF9DC, 0xFFFFF91C	| 4082FFA0
    .long   0xFFFFFA1C, 0xFFFFF78C, 0x00000000, 0x00000000	| 4082FFB0
    jbeq SLARITH32TAB_46
    movel %d3,%d0
    notl %d0
    andl %a1@,%d0
    andl %d4,%d3
    orl %d3,%d0
    movel %d0,%a1@+
    subqw #2,%d2
    jblt SLARITH32TAB_48
SLARITH32TAB_3E:        /* (32-bit slab copy) middle longs */
    movel %d4,%a1@+
    dbf %d2,SLARITH32TAB_3E
    jbra SLARITH32TAB_48
SLARITH32TAB_46:        /* last long: the right mask */
    andl %d3,%d1
SLARITH32TAB_48:        /* store through the mask */
    movel %d1,%d0
    andl %d4,%d0
    notl %d1
    andl %a1@,%d1
    orl %d1,%d0
    movel %d0,%a1@+
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4082FFEA
    /* xor slab, first long: the flags from before this entry say whether only the last long is left */
    beqs SLARITH32TAB_6C
    eorl %d3,%a1@+
    subqw #2,%d2
    blts SLARITH32TAB_6C_2
SLARITH32TAB_48_1C:     /* (xor slab) middle longs */
    notl %a1@+
    dbf %d2,SLARITH32TAB_48_1C
    bras SLARITH32TAB_6C_2


SLARITH32TAB_6C:        /* (xor) last long */
    andl %d3,%d1
SLARITH32TAB_6C_2:      /* last long */
    eorl %d1,%a1@+
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40830006
    jbeq SLARITH32TAB_96
    movel %d3,%d0
    notl %d0
SLARITH32TAB_82:        /* (pattern copy) first long through the mask */
    andl %a1@,%d0
    andl %d5,%d3
    orl %d3,%d0
    movel %d0,%a1@+
    subqw #2,%d2
    jblt SLARITH32TAB_98
SLARITH32TAB_8E:        /* middle longs */
    movel %d5,%a1@+
    dbf %d2,SLARITH32TAB_8E
    jbra SLARITH32TAB_98
SLARITH32TAB_96:        /* last long: the right mask */
    andl %d3,%d1
SLARITH32TAB_98:        /* store through the mask */
    movel %d1,%d0
    andl %d5,%d0
    notl %d1
    andl %a1@,%d1
    orl %d1,%d0
    movel %d0,%a1@+
    rts
    .short  0x0000, 0x0000, 0x0000	| 4083003A

trap_FASTSLABMODE:
FASTSLABMODE:           /* the fast slab loop for a boolean mode */
    andiw #3,%d2
    lea %pc@(FASTSLABMODE_10),%a4
    moveb %a4@(0x0,%d2:w),%d2
    subaw %d2,%a4
    rts
FASTSLABMODE_10:        /* (data) */
    subw %a0@-,%d0	| 40830050
    .short  0x4000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40830052 negxb %d0

trap_COPYHANDLE:
COPYHANDLE:             /* CopyHandle(src, dst): dst resized to src's size, the data copied; either nil: nothing */
    movel %sp@(8),%d0
    jbeq COPYHANDLE_2E
    moveal %d0,%a0
    movel %sp@(4),%d0
    jbeq COPYHANDLE_2E
    moveal %d0,%a1
    _HGetState
    moveb %d0,%sp@-
    _HNoPurge
    _GetHandleSize
    movel %d0,%d1
    exg %a0,%a1
    jsr %pc@(RSETHSIZE)
    exg %a0,%a1
    moveb %sp@+,%d0
    _HSetState
    moveal %a0@,%a0
    moveal %a1@,%a1
    movel %d1,%d0
    _BlockMove
COPYHANDLE_2E:          /* return */
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 40830094

/* ONEBITCTABLE: table. */
ONEBITCTABLE:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    moveq #24,%d0
    jsr %pc@(RSETHSIZE)
    moveal %a0@,%a0
FILLONEBIT:             /* fill the 1-bit pixmap fields at a0 (pixel size 1, one component, no table) */
    moveq #1,%d1
    movel %d1,%a0@+
    movel %d1,%a0@+
    clrw %a0@+
    moveq #-1,%d0
    movel %d0,%a0@+
    movew %d0,%a0@+
    swap %d1
    movel %d1,%a0@+
    clrl %a0@+
    jmp %a1@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408300C2

trap_PORTTOMAP:
PORTTOMAP:              /* the portBits of the port at a0 */
    addqw #2,%a0

trap_BITSTOMAP:
BITSTOMAP:              /* a0 = the bitmap; a color port's pixmap handle (rowBytes bits 15 and 14) is dereferenced to the pixmap */
    tstw %a0@(4)
    jbpl BITSTOMAP_12
    btst #14,%a0@(4)
    jbeq BITSTOMAP_12
    moveal %a0@,%a0
    moveal %a0@,%a0
BITSTOMAP_12:           /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408300E6
