/* ROM resource 'WDEF' 1: map entry at 0x40877130, data at 0x40877160, 1280 bytes

 Window definition 1: the rounded-corner window (window definition IDs 16-23, rDocProc,
 used by desk accessories such as the Calculator). The variation code picks the corner
 size (rsrc_WDEF_1_326). Only messages 0 (draw), 1 (hit test) and 2 (calculate regions)
 do anything; the others return 0. On Color QuickDraw (ROM85) the colours come from the
 window's auxiliary record (its 'wctb'). Comments inferred from the code (and the window
 definition messages in Inside Macintosh).
 Trap words written as numbers here: 0xA8D2 FrameRgn, 0xA8D3 PaintRgn, 0xA8E1 InsetRgn,
 0xA8E8 PtInRgn, 0xA8AD PtInRect, 0xA8A8 OffsetRect, 0xA8A9 InsetRect.
*/

rsrc_WDEF_1_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40877130
    .long   rsrc_WDEF_0_entry-rom_start	| 40877138
    .long   rsrc_WDEF_1-rom_start	| 4087713C
    .ascii  "WDEF"	| 40877140
    .byte   0x00, 0x01, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40877144
    .long   0x00000000, 0xC0A00000, 0x0000050C, 0x0000010C	| 40877150

/* Entry: a branch over the standard header ('WDEF', ID 1). */
rsrc_WDEF_1:
    jbra rsrc_WDEF_1_C
    .short  0x0000, 0x5744, 0x4546, 0x0001, 0x000A	| 40877162

/*
 WindowDefProc(varCode, theWindow, message, param): Pascal entry. Sets up the port (the
 colour Window Manager port, with the window's colours, on Color QuickDraw), the title
 bar height from the font (at least 19), the corner size from the variation, then calls
 the routine for the message (table rsrc_WDEF_1_E4) and restores colours and port.
*/
rsrc_WDEF_1_C:
    linkw %fp,#-30
    moveml %d3-%d5/%a3-%a4,%sp@-
    cmpiw #2,%fp@(12)
    jbgt rsrc_WDEF_1_C_CA
    cmpiw #0,%fp@(12)
    jbmi rsrc_WDEF_1_C_CA
    moveal %a5@,%a0
    movel %a0@,%sp@-
    cmpiw #16383,ROM85
    sls %fp@(-30)
    jbhi rsrc_WDEF_1_C_60
    jbsr rsrc_WDEF_1_F2
    pea %fp@(-28)
    _GetForeColor
    pea %fp@(-22)
    _GetBackColor
    clrl %sp@-
    clrw %sp@-
    movel %fp@(14),%sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    movel %a0,%fp@(-16)
    _HLock
    movel %a0@,%fp@(-12)
    jbra rsrc_WDEF_1_C_66
rsrc_WDEF_1_C_60:       /* no Color QuickDraw: the Window Manager port */
    movel WMgrPort,%sp@-
    _SetPort
rsrc_WDEF_1_C_66:       /* title bar height from the font */
    lea %fp@(-8),%a3
    movel %a3,%sp@-
    _GetFontInfo
    movew %a3@+,%d0
    addw %a3@+,%d0
    addqw #4,%d0
    bset #0,%d0
    moveq #19,%d1
    cmpw %d1,%d0
    jbge rsrc_WDEF_1_C_88
    subw %d0,%d1
    lsrw #1,%d1
    addw %d1,%fp@(-8)
    moveq #19,%d0
rsrc_WDEF_1_C_88:       /* arguments: param d3, window a3, variation d5 */
    movew %d0,%a3@+
    subiw #13,%d0
    lsrw #1,%d0
    movew %d0,%a3@
    lea %fp@(8),%a0
    movel %a0@+,%d3
    movew %a0@+,%d0
    moveal %a0@+,%a3
    movew %a0@+,%d5
    lsrw #1,%d5
    aslw #2,%d5
    clrl %a0@
    cmpiw #3,%d0
    jbge rsrc_WDEF_1_C_B0
    aslw #2,%d0
    jsr %pc@(rsrc_WDEF_1_E4,%d0:w)
rsrc_WDEF_1_C_B0:       /* restore colours (Color QuickDraw) */
    tstb %fp@(-30)
    jbeq rsrc_WDEF_1_C_C8
    pea %fp@(-28)
    _RGBForeColor
    pea %fp@(-22)
    _RGBBackColor
    moveal %fp@(-16),%a0
    _HUnlock
rsrc_WDEF_1_C_C8:       /* restore the port */
    _SetPort
rsrc_WDEF_1_C_CA:       /* return (pops the 12 bytes of arguments) */
    moveml %sp@+,%d3-%d5/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(12),%sp
    jmp %a0@
rsrc_WDEF_1_E4:         /* message table: 0 draw, 1 hit, 2 calculate regions (branches of fixed size) */
    braw rsrc_WDEF_1_160	| 40877244
    braw rsrc_WDEF_1_3D2	| 40877248
    braw rsrc_WDEF_1_45E	| 4087724C
rsrc_WDEF_1_F0:         /* nothing to do */
    rts	| 40877250

/*
 Colour set-up: the colour Window Manager port with the pen and background patterns and
 pen state of the Window Manager port.
*/
rsrc_WDEF_1_F2:
    movel ghost_WMgrCPort,%sp@-
    _SetPort
    moveal WMgrPort,%a0
    moveal ghost_WMgrCPort,%a1
    pea %a0@(32)
    pea %a0@(58)
    lea %a0@(48),%a0
    lea %a1@(48),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movew %a0@+,%a1@+
    addqw #8,%a0
    addqw #8,%a1
    movew #20,%d0
rsrc_WDEF_1_F2_2C:      /* copy the pen state */
    movew %a0@+,%a1@+
    dbf %d0,rsrc_WDEF_1_F2_2C
    _PenPat
    _BackPat
    rts

/*
 Colour of window part d0 from the window's colour table (default entry 0 if the part is
 missing). Out: pointer to its RGB colour on the stack.
*/
rsrc_WDEF_1_12A:
    movel %d1,%sp@-	| 4087728A
    moveal %fp@(-12),%a0	| 4087728C
    movew %a0@(6),%d1	| 40877290
    muluw #8,%d1	| 40877294
rsrc_WDEF_1_138:        /* search the table backwards */
    cmpw %a0@(8,%d1:w),%d0	| 40877298
    jbeq rsrc_WDEF_1_144	| 4087729C
    subqw #8,%d1	| 4087729E
    jbge rsrc_WDEF_1_138	| 408772A0
    moveq #0,%d1	| 408772A2
rsrc_WDEF_1_144:        /* the entry's RGB colour */
    lea %a0@(0xa,%d1:w),%a0	| 408772A4
    movel %a0,%d0	| 408772A8
    movel %sp@+,%d1	| 408772AA
    moveal %sp@+,%a0	| 408772AC
    movel %d0,%sp@-	| 408772AE
    jmp %a0@	| 408772B0

/*
 a0 = the window's port bounds rectangle (through the pixel map handle when the port is a
 colour port).
*/
rsrc_WDEF_1_152:
    addqw #2,%a0
    tstw %a0@(4)
    jbpl rsrc_WDEF_1_152_C
    moveal %a0@,%a0
    moveal %a0@,%a0
rsrc_WDEF_1_152_C:      /* return */
    rts

/*
 Message 0, draw: frame, title bar with the title, go-away box (param 4: only toggle the
 go-away box). Nothing when the window is invisible.
*/
rsrc_WDEF_1_160:
    tstb %a3@(110)	| 408772C0
    jbeq rsrc_WDEF_1_F0	| 408772C4
    cmpiw #4,%d3	| 408772C6
    jbeq rsrc_WDEF_1_25E	| 408772CA
    lea Scratch8,%a0	| 408772CE
    moveal %a3@(114),%a1	| 408772D2
    moveal %a1@,%a1	| 408772D6
    addqw #2,%a1	| 408772D8
    movel %a1@+,%a0@+	| 408772DA
    movel %a1@,%a0@	| 408772DC
    movew %a0@(-4),%d0	| 408772DE
    addw %fp@(-4),%d0	| 408772E2
    movew %d0,%a0@	| 408772E6
    clrl %sp@-	| 408772E8
    _NewRgn	| 408772EA
    moveal %sp@,%a4	| 408772EC
    pea Scratch8	| 408772EE
    jbsr rsrc_WDEF_1_320	| 408772F2
    movel %d0,%sp@-	| 408772F6
    st %sp@-	| 408772F8
    clrw %sp@-	| 408772FA
    jbsr rsrc_WDEF_1_346	| 408772FC
    tstb %fp@(-30)	| 40877300
    jbeq rsrc_WDEF_1_1B2	| 40877304
    movew #1,%d0	| 40877306
    jbsr rsrc_WDEF_1_12A	| 4087730A
    _RGBForeColor	| 4087730E
    _PenNormal
rsrc_WDEF_1_1B2:        /* set %sp@- */
    movel %a4,%sp@-	| 40877312
    .short  0xA8D2	| 40877314 _FrameRgn
    tstb %fp@(-30)	| 40877316
    jbeq rsrc_WDEF_1_1DA	| 4087731A
    tstb %a3@(111)	| 4087731C
    jbne rsrc_WDEF_1_1D2	| 40877320
    moveq #4,%d0	| 40877322
    jbsr rsrc_WDEF_1_12A	| 40877324
    _RGBForeColor	| 40877328
    moveq #1,%d0	| 4087732A
    jbsr rsrc_WDEF_1_12A	| 4087732C
    jbra rsrc_WDEF_1_1D8	| 40877330
rsrc_WDEF_1_1D2:        /* set %d0 */
    moveq #4,%d0	| 40877332
    jbsr rsrc_WDEF_1_12A	| 40877334
rsrc_WDEF_1_1D8:        /* (40877338 A-line trap) */
    _RGBBackColor	| 40877338
rsrc_WDEF_1_1DA:        /* set %sp@- */
    movel %a4,%sp@-	| 4087733A
    movel OneOne,%sp@-	| 4087733C
    .short  0xA8E1	| 40877340 _InsetRgn
    movel %a4,%sp@-	| 40877342
    tstb %fp@(-30)	| 40877344
    jbeq rsrc_WDEF_1_1EE	| 40877348
    .short  0xA8D3	| 4087734A _PaintRgn
    jbra rsrc_WDEF_1_1F0	| 4087734C
rsrc_WDEF_1_1EE:        /* (4087734E A-line trap) */
    _EraseRgn	| 4087734E
rsrc_WDEF_1_1F0:        /* call rsrc_WDEF_1_2BE */
    jbsr rsrc_WDEF_1_2BE	| 40877350
    tstb %a3@(111)	| 40877354
    jbeq rsrc_WDEF_1_222	| 40877358
    tstb %a3@(112)	| 4087735A
    jbeq rsrc_WDEF_1_212	| 4087735E
    tstb %fp@(-30)	| 40877360
    jbeq rsrc_WDEF_1_20A	| 40877364
    moveq #4,%d1	| 40877366
    jbra rsrc_WDEF_1_20C	| 40877368
rsrc_WDEF_1_20A:        /* clear %d1 */
    moveq #0,%d1	| 4087736A
rsrc_WDEF_1_20C:        /* address %pc@(rsrc_WDEF_1_4B6) */
    lea %pc@(rsrc_WDEF_1_4B6),%a1	| 4087736C
    jbsr rsrc_WDEF_1_26A	| 40877370
rsrc_WDEF_1_212:        /* test %fp@(-30) */
    tstb %fp@(-30)	| 40877372
    jbne rsrc_WDEF_1_222	| 40877376
    subqw #1,scratch8_4	| 40877378
    pea Scratch8	| 4087737C
    _InverRect	| 40877380
rsrc_WDEF_1_222:        /* set %sp@- */
    movel %a4,%sp@-	| 40877382
    _DisposRgn	| 40877384
    tstb %fp@(-30)	| 40877386
    jbeq rsrc_WDEF_1_234	| 4087738A
    moveq #1,%d0	| 4087738C
    jbsr rsrc_WDEF_1_12A	| 4087738E
    _RGBForeColor	| 40877392
rsrc_WDEF_1_234:        /* set %sp@- */
    movel %a3@(114),%sp@-	| 40877394
    .short  0xA8D2	| 40877398 _FrameRgn
    rts	| 4087739A

/* Scratch8 = the title bar rectangle (from the structure region's bounds). */
rsrc_WDEF_1_23C:
    lea Scratch8,%a0
    moveal %a3@(114),%a1
    moveal %a1@,%a1
    addqw #2,%a1
    movel %a1@+,%a0@
    movel %a1@,%a0@(4)
    movew %a0@,%d0
    addw %fp@(-4),%d0
    movew %d0,%a0@(4)	| 408773B4
    subqw #1,%a0@(6)
    rts

/* Draw (toggle) the go-away box: the pressed or normal 16x16 image (rsrc_WDEF_1_4B6). */
rsrc_WDEF_1_25E:
    jbsr rsrc_WDEF_1_23C
    lea %pc@(rsrc_WDEF_1_4B6),%a1
    lea %a1@(32),%a1
    moveq #2,%d1

/* Draw a 16x16 image (a1, mode d0) in the go-away box position of the title bar. */
rsrc_WDEF_1_26A:
    lea Scratch8,%a0
    movew %fp@(-2),%d0
    addw %d0,%a0@
    subqw #1,%a0@
    addqw #8,%a0@(2)
    movel %a0@+,%a0@
    moveq #16,%d0
    addw %d0,%a0@+
    addw %d0,%a0@
    movew %d1,%d0
    movel #1048592,%d1
    jbsr rsrc_WDEF_1_290
    jbsr rsrc_WDEF_1_23C
    rts

/* CopyBits of the 16x16 bitmap at a1 to Scratch8. */
rsrc_WDEF_1_290:
    lea IconBitmap,%a0
    movel %a1,%a0@
    movew #2,%a0@(4)
    movel #1048592,%a0@(10)
    movel %a0,%sp@-
    moveal %a5@,%a1
    moveal %a1@,%a1
    pea %a1@(2)
    pea %a0@(6)
    pea Scratch8
    movew %d0,%sp@-
    clrl %sp@-
    _CopyBits
    rts

/*
 Draw the title, centred in the title bar (leaving room for the go-away box), in the
 title colour on Color QuickDraw.
*/
rsrc_WDEF_1_2BE:
    jbsr rsrc_WDEF_1_23C	| 4087741E
    movew scratch8_6,%d3	| 40877422
    subw scratch8_2,%d3	| 40877426
    subw %a3@(138),%d3	| 4087742A
    asrw #1,%d3	| 4087742E
    tstb %a3@(112)	| 40877430
    jbeq rsrc_WDEF_1_2E2	| 40877434
    tstw %d3	| 40877436
    jbmi rsrc_WDEF_1_2E0	| 40877438
    cmpiw #28,%d3	| 4087743A
    jbgt rsrc_WDEF_1_2E2	| 4087743E
rsrc_WDEF_1_2E0:        /* set %d3 */
    moveq #28,%d3	| 40877440
rsrc_WDEF_1_2E2:        /* from here: addw 0x9fc,%d3 */
    addw scratch8_2,%d3	| 40877442
    movew %d3,%sp@-	| 40877446
    movew Scratch8,%d0	| 40877448
    addw %fp@(-8),%d0	| 4087744C
    addqw #2,%d0	| 40877450
    movew %d0,%sp@-	| 40877452
    _MoveTo	| 40877454
    tstb %fp@(-30)	| 40877456
    jbeq rsrc_WDEF_1_306	| 4087745A
    movew %a3@(72),%sp@-	| 4087745C
    movew #4,%sp@-	| 40877460
    _TextMode	| 40877464
rsrc_WDEF_1_306:        /* set %a0 */
    moveal %a3@(134),%a0	| 40877466
    _HLock	| 4087746A
    movel %a0@,%sp@-	| 4087746C
    _DrawString	| 4087746E
    moveal %a3@(134),%a0	| 40877470
    _HUnlock	| 40877474
    tstb %fp@(-30)	| 40877476
    jbeq rsrc_WDEF_1_31E	| 4087747A
    _TextMode	| 4087747C
rsrc_WDEF_1_31E:        /* return */
    rts	| 4087747E

/* d0 = the corner oval size (width and height) for the variation (d5). */
rsrc_WDEF_1_320:
    movel %pc@(rsrc_WDEF_1_326,%d5:w),%d0
    rts
rsrc_WDEF_1_326:        /* corner sizes per variation: 16, 4, 6, 8, 10, 12, 20, 24 pixels */
    .short  0x0010, 0x0010, 0x0004, 0x0004, 0x0006	| 40877486
    .long   0x00060008, 0x0008000A, 0x000A000C, 0x000C0014	| 40877490
    .short  0x0014, 0x0018, 0x0018	| 408774A0

/*
 Region of a rounded rectangle (rect, corner size, flags for square top or bottom
 corners): RectRgn for no rounding, else a framed round rectangle, squared at the top or
 bottom by a union with a rectangle.
*/
rsrc_WDEF_1_346:
    linkw %fp,#0
    movel %a3,%sp@-
    tstl %fp@(8)
    jbeq rsrc_WDEF_1_346_12
    tstl %fp@(12)
    jbne rsrc_WDEF_1_346_1E
rsrc_WDEF_1_346_12:     /* set up and call _RectRgn */
    movel %fp@(20),%sp@-
    movel %fp@(16),%sp@-
    _RectRgn
    jbra rsrc_WDEF_1_346_80
rsrc_WDEF_1_346_1E:     /* _HidePen */
    _HidePen
    _OpenRgn
    movel %fp@(16),%sp@-
    movel %fp@(12),%sp@-
    _FrameRoundRect
    movel %fp@(20),%sp@-
    _CloseRgn
    _ShowPen
    moveal %fp@(16),%a0
    tstw %fp@(8)
    jbne rsrc_WDEF_1_346_48
    movew %a0@(4),%d1
    movew %d1,%d0
    subqw #8,%d0
    jbra rsrc_WDEF_1_346_54
rsrc_WDEF_1_346_48:     /* test %fp@(10) */
    tstw %fp@(10)
    jbne rsrc_WDEF_1_346_80
    movew %a0@,%d0
    movew %d0,%d1
    addqw #8,%d1
rsrc_WDEF_1_346_54:     /* address ToolScratch */
    lea ToolScratch,%a1
    movew %d0,%a1@+
    movew %a0@(2),%a1@+
    movew %d1,%a1@+
    movew %a0@(6),%a1@
    clrl %sp@-
    _NewRgn
    moveal %sp@,%a3
    pea ToolScratch
    _RectRgn
    movel %fp@(20),%sp@-
    movel %a3,%sp@-
    movel %fp@(20),%sp@-
    _UnionRgn
    movel %a3,%sp@-
    _DisposRgn
rsrc_WDEF_1_346_80:     /* set %a3 */
    moveal %sp@+,%a3
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(16),%sp
    jmp %a0@

/*
 Message 1, hit test (param = the point): in the content region 1 (inContent), in the
 title bar 2 (inDrag), in the go-away box 4 (inGoAway), else 0.
*/
rsrc_WDEF_1_3D2:
    moveq #16,%d4	| 40877532
    clrw %sp@-	| 40877534
    movel %d3,%sp@-	| 40877536
    movel %a3@(118),%sp@-	| 40877538
    _PtInRgn	| 4087753C
    tstb %sp@+	| 4087753E
    jbeq rsrc_WDEF_1_3E6	| 40877540
    moveq #1,%d0
    jbra rsrc_WDEF_1_346_112
rsrc_WDEF_1_3E6:        /* clear %sp@- */
    clrw %sp@-	| 40877546
    movel %d3,%sp@-	| 40877548
    movel %a3@(114),%sp@-	| 4087754A
    _PtInRgn	| 4087754E
    tstb %sp@+	| 40877550
    jbeq rsrc_WDEF_1_45C	| 40877552
    clrw %sp@-	| 40877554
    movel %d3,%sp@-	| 40877556
    moveal %a3@(118),%a4	| 40877558
    moveal %a4@,%a4	| 4087755C
    addqw #2,%a4	| 4087755E
    movew %fp@(-4),%d0	| 40877560
    subw %d0,%a4@	| 40877564
    movel %a4,%sp@-	| 40877566
    _PtInRect	| 40877568
    movew %fp@(-4),%d0	| 4087756A
    addw %d0,%a4@	| 4087756E
    tstb %sp@+	| 40877570
    jbeq rsrc_WDEF_1_45C	| 40877572
rsrc_WDEF_1_414:        /* test %a3@(112) */
    tstb %a3@(112)
    jbeq rsrc_WDEF_1_346_110
    tstb %a3@(111)
    jbeq rsrc_WDEF_1_346_110
    movew %d3,%d0
    moveal %a3,%a0
    jbsr rsrc_WDEF_1_152
    addw %a0@(8),%d0
    subw %a3@(18),%d0
    cmpiw #18,%d0
    jbgt rsrc_WDEF_1_346_110
    subqw #8,%d0
    jbmi rsrc_WDEF_1_346_110
    movel %d3,%d0
    swap %d0
    addw %a0@(6),%d0
    subw %a3@(16),%d0
    addw %fp@(-2),%d0
    jbpl rsrc_WDEF_1_346_110
    addiw #11,%d0
    jbmi rsrc_WDEF_1_346_110
    moveq #4,%d0
    jbra rsrc_WDEF_1_346_112
rsrc_WDEF_1_346_110:    /* set %d0 */
    moveq #2,%d0
rsrc_WDEF_1_346_112:    /* set %fp@(20) */
    movel %d0,%fp@(20)
rsrc_WDEF_1_45C:        /* return */
    rts

/*
 Message 2, calculate regions: the content region (the port rectangle in global
 coordinates, rounded) and the structure region (content plus frame and title bar).
*/
rsrc_WDEF_1_45E:
    lea Scratch8,%a0	| 408775BE
    movel %a0,%sp@-	| 408775C2
    movel %a3@(16),%a0@+	| 408775C4
    movel %a3@(20),%a0@	| 408775C8
    moveal %a3,%a0	| 408775CC
    jbsr rsrc_WDEF_1_152	| 408775CE
    movel %a0@(6),%sp@-	| 408775D2
    negw %sp@(2)	| 408775D6
    negw %sp@	| 408775DA
    _OffsetRect	| 408775DC
    moveal %a3@(118),%a0	| 408775DE
    clrw %d1	| 408775E2
    jbsr rsrc_WDEF_1_4A0	| 408775E4
    pea Scratch8	| 408775E6
    movel MinusOne,%sp@-	| 408775EA
    _InsetRect	| 408775EE
    movew %fp@(-4),%d0	| 408775F0
    subqw #1,%d0	| 408775F4
    subw %d0,Scratch8	| 408775F6
    moveq #1,%d1
    moveal %a3@(114),%a0
rsrc_WDEF_1_4A0:        /* set %sp@- */
    movel %a0,%sp@-
    pea Scratch8
    jbsr rsrc_WDEF_1_320
    movel %d0,%sp@-
    movew %d1,%sp@-
    st %sp@-
    jbsr rsrc_WDEF_1_346
    rts
rsrc_WDEF_1_4B6:        /* (data) */
    .short  0x0000, 0x0000, 0x7FF0, 0x4010, 0x4010	| 40877616
    .long   0x40104010, 0x40104010, 0x40104010, 0x40107FF0	| 40877620
    .long   0x00000000, 0x00000000, 0x00007FF0, 0x42105250	| 40877630
    .long   0x4A904010, 0x5DD04010, 0x4A905250, 0x42107FF0	| 40877640
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40877650
