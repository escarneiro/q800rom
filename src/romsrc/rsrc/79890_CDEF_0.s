/* ROM resource 'CDEF' 0: map entry at 0x40879890, data at 0x408798C0, 1264 bytes

 Control definition 0: push buttons, check boxes and radio buttons (control definition IDs
 0-2: pushButProc, checkBoxProc, radioButProc; +8: the window's font), in the control's
 colours ('cctb') on Color QuickDraw. Messages 0-2 index rsrc_CDEF_0_118, 10 and 11 as
 entries 3 and 4. Comments inferred from the code (and Inside Macintosh).
*/

rsrc_CDEF_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40879890
    .long   rsrc_CDEF_1_entry-rom_start	| 40879898
    .long   rsrc_CDEF_0-rom_start	| 4087989C
    .ascii  "CDEF"	| 408798A0
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408798A4
    .long   0x00000000, 0xC0A00000, 0x000004FC, 0x000000EC	| 408798B0

/* Entry: a branch over the standard header ('CDEF', ID 0). */
rsrc_CDEF_0:
    jbra rsrc_CDEF_0_C
    .short  0x0000, 0x4344, 0x4546, 0x0000, 0x000A	| 408798C2

rsrc_CDEF_0_C:          /* from here: linkw %fp,#-56 */
    linkw %fp,#-56
    moveml %d3-%d7/%a1-%a4,%sp@-
    cmpiw #2,%fp@(12)
    jbls rsrc_CDEF_0_C_22
    cmpiw #10,%fp@(12)
    jbeq rsrc_CDEF_0_C_22
    cmpiw #11,%fp@(12)
    jbne rsrc_CDEF_0_C_FE
rsrc_CDEF_0_C_22:       /* set up and call _GetPenState */
    pea %fp@(-20)
    _GetPenState
    _PenNormal
    cmpiw #16383,ROM85
    sls %fp@(-22)
    jbhi rsrc_CDEF_0_C_B2
    moveal %a5@,%a0
    moveal %a0@,%a0
    movew %a0@(72),%sp@-
    movew #1,%sp@-
    _TextMode
    pea %fp@(-50)
    _GetForeColor
    pea %fp@(-56)
    _GetBackColor
    clrl %sp@-
    clrb %sp@-
    movel %fp@(14),%sp@-
    pea %sp@(6)
    _GetAuxCtl
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    movel %a0,%fp@(-34)
    _HLock
    movel %a0@,%fp@(-38)
    clrl %sp@-
    clrb %sp@-
    moveal %fp@(14),%a0
    moveal %a0@,%a0
    movel %a0@(4),%sp@-
rsrc_CDEF_0_C_80:       /* set up and call _GetAuxWin */
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    movew %a0@(6),%d0
    muluw #8,%d0
rsrc_CDEF_0_C_9A:       /* loop: tst */
    tstw %a0@(0x8,%d0:w)
    jbeq rsrc_CDEF_0_C_A6
    subqw #8,%d0
    jbge rsrc_CDEF_0_C_9A
    moveq #0,%d0
rsrc_CDEF_0_C_A6:       /* set %fp@(-44) */
    movel %a0@(0xa,%d0:w),%fp@(-44)
    movew %a0@(0xe,%d0:w),%fp@(-40)
rsrc_CDEF_0_C_B2:       /* address %fp@(8) */
    lea %fp@(8),%a0
    movel %a0@+,%d3
    movew %a0@+,%d0
    moveal %a0@+,%a3
    movew %a0@+,%d6
    movew %d6,%d7
    andiw #7,%d6
    clrl %a0@
    moveal %a3@,%a0
    cmpiw #2,%d0
    blsw rsrc_CDEF_0_C_D2
    subqw #7,%d0
rsrc_CDEF_0_C_D2:       /* from here: addw %d0,%d0 */
    addw %d0,%d0
    lea %pc@(rsrc_CDEF_0_118),%a1
    addaw %a1@(0x0,%d0:w),%a1
    jsr %a1@
    tstb %fp@(-22)
    jbeq rsrc_CDEF_0_C_F8
    moveal %fp@(-34),%a0
    _HUnlock
    pea %fp@(-50)
    _RGBForeColor
    pea %fp@(-56)
    _RGBBackColor
    _TextMode
rsrc_CDEF_0_C_F8:       /* set up and call _SetPenState */
    pea %fp@(-20)
    _SetPenState
rsrc_CDEF_0_C_FE:       /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a1-%a4
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(12),%sp
    jmp %a0@
rsrc_CDEF_0_118:        /* message table (offsets from here): 0 draw, 1 test, 2 calculate regions, 3 (10) and 4 (11): nothing */
    .short  rsrc_CDEF_0_14C-rsrc_CDEF_0_118	| 408799D8
    .short  rsrc_CDEF_0_3A4-rsrc_CDEF_0_118	| 408799DA
    .short  rsrc_CDEF_0_3DC-rsrc_CDEF_0_118	| 408799DC
    .short  rsrc_CDEF_0_3D6-rsrc_CDEF_0_118	| 408799DE
    .short  rsrc_CDEF_0_3D6-rsrc_CDEF_0_118	| 408799E0
rsrc_CDEF_0_122:        /* return */
    rts	| 408799E2

/* subroutine (14 instructions) (mechanical summary) */
rsrc_CDEF_0_124:
    movel %d1,%sp@-	| 408799E4
    moveal %fp@(-38),%a0	| 408799E6
    movew %a0@(6),%d1	| 408799EA
    muluw #8,%d1	| 408799EE
rsrc_CDEF_0_132:        /* loop: cmp */
    cmpw %a0@(8,%d1:w),%d0	| 408799F2
    jbeq rsrc_CDEF_0_13E	| 408799F6
    subqw #8,%d1	| 408799F8
    jbge rsrc_CDEF_0_132	| 408799FA
    moveq #0,%d1	| 408799FC
rsrc_CDEF_0_13E:        /* (408799FE lea %a0@(a,%d1:w),%a0) */
    lea %a0@(0xa,%d1:w),%a0	| 408799FE
    movel %a0,%d0	| 40879A02
    movel %sp@+,%d1	| 40879A04
    moveal %sp@+,%a0	| 40879A06
    movel %d0,%sp@-	| 40879A08
    jmp %a0@	| 40879A0A

/*
 Message 0, draw: a push button (rounded rectangle, title centred, inverted when
 pressed) or a check box / radio button (box or circle with its mark, title to its
 right), dimmed when inactive; clipped to the control rectangle.
*/
rsrc_CDEF_0_14C:
    tstb %a0@(16)	| 40879A0C
    jbeq rsrc_CDEF_0_122	| 40879A10
    jbsr rsrc_CDEF_0_38A	| 40879A12
    tstb %fp@(-22)	| 40879A16
    jbeq rsrc_CDEF_0_180	| 40879A1A
    tstb %d6	| 40879A1C
    jbeq rsrc_CDEF_0_166	| 40879A1E
    pea %fp@(-44)	| 40879A20
    jbra rsrc_CDEF_0_17C	| 40879A24
rsrc_CDEF_0_166:        /* set %a0 */
    moveal %a3@,%a0	| 40879A26
    moveb %a0@(17),%d0	| 40879A28
    subqb #1,%d0	| 40879A2C
    cmpib #0xfd,%d0	| 40879A2E
    jbcc rsrc_CDEF_0_178	| 40879A32
    moveq #2,%d0	| 40879A34
    jbra rsrc_CDEF_0_17A	| 40879A36
rsrc_CDEF_0_178:        /* set %d0 */
    moveq #1,%d0	| 40879A38
rsrc_CDEF_0_17A:        /* call rsrc_CDEF_0_124 */
    jbsr rsrc_CDEF_0_124	| 40879A3A
rsrc_CDEF_0_17C:        /* (40879A3C A-line trap) */
    _RGBBackColor	| 40879A3C
    moveal %a3@,%a0	| 40879A3E
rsrc_CDEF_0_180:        /* address %a0@(8) */
    lea %a0@(8),%a4	| 40879A40
    tstb %d6	| 40879A44
    jbeq rsrc_CDEF_0_18C	| 40879A46
    tstb %d3	| 40879A48
    jbne rsrc_CDEF_0_192	| 40879A4A
rsrc_CDEF_0_18C:        /* set %sp@- */
    movel %a4,%sp@-	| 40879A4C
    movel %d4,%sp@-	| 40879A4E
    .short  0xA8B2	| 40879A50 _EraseRoundRect
rsrc_CDEF_0_192:        /* set %a0 */
    moveal %a5@,%a0	| 40879A52
    moveal %a0@,%a0	| 40879A54
    movel %a0@(68),%sp@-	| 40879A56
    movew %a0@(74),%sp@-	| 40879A5A
    subqw #8,%d7	| 40879A5E
    jbge rsrc_CDEF_0_1BE	| 40879A60
    clrl %a0@(68)	| 40879A62
    movew #12,%d0	| 40879A66
    tstw ROM85	| 40879A6A
rsrc_CDEF_0_1AE:        /* from here: jbmi rsrc_CDEF_0_1BA */
    jbmi rsrc_CDEF_0_1BA	| 40879A6E
    movew SysFontSize,%d0	| 40879A70
    jbne rsrc_CDEF_0_1BA	| 40879A74
    moveb FMDefaultSize,%d0	| 40879A76
rsrc_CDEF_0_1BA:        /* set %a0@(74) */
    movew %d0,%a0@(74)	| 40879A7A
rsrc_CDEF_0_1BE:        /* set %sp@- */
    movel %a0@(28),%sp@-	| 40879A7E
    clrl %sp@-	| 40879A82
    _NewRgn	| 40879A84
    moveal %sp@,%a2	| 40879A86
    _GetClip	| 40879A88
    moveal %a3@,%a0	| 40879A8A
    pea %a0@(8)	| 40879A8C
    _ClipRect	| 40879A90
    movel %a2,%sp@-	| 40879A92
    movel %sp@(4),%sp@-	| 40879A94
    _SectRgn	| 40879A98
    moveml %d4/%a2-%a3,%sp@-	| 40879A9A
    moveal %a3@,%a0	| 40879A9E
    lea %a0@(40),%a2	| 40879AA0
    lea %a0@(8),%a4	| 40879AA4
    moveq #0,%d7	| 40879AA8
    moveb %a2@,%d7	| 40879AAA
    jbeq rsrc_CDEF_0_2C0	| 40879AAC
    moveq #0,%d4	| 40879AB0
rsrc_CDEF_0_1F2:        /* loop: addq */
    addqw #1,%d4	| 40879AB2
    jbsr rsrc_CDEF_0_31C	| 40879AB4
    tstb %d7	| 40879AB8
    jbpl rsrc_CDEF_0_1F2	| 40879ABA
    moveb %a2@,%d7	| 40879ABC
    subqw #8,%sp	| 40879ABE
    moveal %sp,%a3	| 40879AC0
    movel %a3,%sp@-	| 40879AC2
    _GetFontInfo	| 40879AC4
    jbsr rsrc_CDEF_0_334	| 40879AC6
    muluw %d4,%d0	| 40879ACA
    movew %a4@(4),%d1	| 40879ACC
    movew %d1,%d5	| 40879AD0
    subw %a4@,%d1	| 40879AD2
    subw %d0,%d1	| 40879AD4
    asrw #1,%d1	| 40879AD6
    subw %d1,%d5	| 40879AD8
    subw %a3@(6),%d5	| 40879ADA
    subw %a3@(2),%d5	| 40879ADE
rsrc_CDEF_0_222:        /* call rsrc_CDEF_0_31C (loop) */
    jbsr rsrc_CDEF_0_31C	| 40879AE2
    clrw %sp@-	| 40879AE6
    movel %a2,%sp@-	| 40879AE8
    movew %d7,%d0	| 40879AEA
    addqb #2,%d0	| 40879AEC
    movew %d0,%sp@-	| 40879AEE
    movew %d3,%sp@-	| 40879AF0
    _TextWidth	| 40879AF2
    movew %sp@+,%d0	| 40879AF4
    tstb %d6	| 40879AF6
    jbeq rsrc_CDEF_0_264	| 40879AF8
    tstw ROM85	| 40879AFA
    jbmi rsrc_CDEF_0_25A	| 40879AFE
    tstw TESysJust	| 40879B00
    jbeq rsrc_CDEF_0_25A	| 40879B04
    movew %a4@(6),%d1	| 40879B06
    subw %a4@(2),%d1	| 40879B0A
    subw %d0,%d1	| 40879B0E
    subiw #18,%d1	| 40879B10
    addw %a4@(2),%d1	| 40879B14
    jbra rsrc_CDEF_0_274	| 40879B18
rsrc_CDEF_0_25A:        /* set %d1 */
    movew %a4@(2),%d1	| 40879B1A
    addiw #18,%d1	| 40879B1E
    jbra rsrc_CDEF_0_274	| 40879B22
rsrc_CDEF_0_264:        /* set %d1 */
    movew %a4@(6),%d1	| 40879B24
    subw %a4@(2),%d1	| 40879B28
    subw %d0,%d1	| 40879B2C
    asrw #1,%d1	| 40879B2E
    addw %a4@(2),%d1	| 40879B30
rsrc_CDEF_0_274:        /* set %sp@- */
    movew %d1,%sp@-	| 40879B34
    movew %d5,%sp@-	| 40879B36
    _MoveTo	| 40879B38
    tstb %fp@(-22)	| 40879B3A
    jbeq rsrc_CDEF_0_2A6	| 40879B3E
    tstb %d6	| 40879B40
    jbne rsrc_CDEF_0_29C	| 40879B42
    moveal %fp@(14),%a0	| 40879B44
    moveal %a0@,%a0	| 40879B48
    moveb %a0@(17),%d0	| 40879B4A
    subqw #1,%d0	| 40879B4E
    cmpib #0xfd,%d0	| 40879B50
    jbcc rsrc_CDEF_0_29C	| 40879B54
    movew #1,%d0	| 40879B56
    jbra rsrc_CDEF_0_2A0	| 40879B5A
rsrc_CDEF_0_29C:        /* set %d0 */
    movew #2,%d0	| 40879B5C
rsrc_CDEF_0_2A0:        /* call rsrc_CDEF_0_124 */
    jbsr rsrc_CDEF_0_124	| 40879B60
    _RGBForeColor	| 40879B64
rsrc_CDEF_0_2A6:        /* set %sp@- */
    movel %a2,%sp@-	| 40879B66
    movew %d7,%d0	| 40879B68
    addqb #2,%d0	| 40879B6A
    movew %d0,%sp@-	| 40879B6C
    movew %d3,%sp@-	| 40879B6E
    _DrawText	| 40879B70
    bsrw rsrc_CDEF_0_334	| 40879B72
    subw %d0,%d5	| 40879B76
    tstb %d7	| 40879B78
    jbpl rsrc_CDEF_0_222	| 40879B7A
    addqw #8,%sp	| 40879B7E
rsrc_CDEF_0_2C0:        /* restore registers */
    moveml %sp@+,%d4/%a2-%a3	| 40879B80
    moveal %a5@,%a0	| 40879B84
    moveal %a0@,%a0	| 40879B86
    movew %sp@+,%a0@(74)	| 40879B88
    movel %sp@+,%a0@(68)	| 40879B8C
    tstb %fp@(-22)	| 40879B90
    jbeq rsrc_CDEF_0_2DE	| 40879B94
    moveq #0,%d0	| 40879B96
    jbsr rsrc_CDEF_0_124	| 40879B98
    _RGBForeColor	| 40879B9C
rsrc_CDEF_0_2DE:        /* test %d6 */
    tstb %d6	| 40879B9E
    jbne rsrc_CDEF_0_418	| 40879BA0
    movel %a4,%sp@-	| 40879BA4
    movel %d4,%sp@-	| 40879BA6
    _FrameRoundRect	| 40879BA8
    tstb %fp@(-22)	| 40879BAA
    jbeq rsrc_CDEF_0_2FC	| 40879BAE
    moveal %a3@,%a0	| 40879BB0
    cmpib #0xfe,%a0@(17)	| 40879BB2
    jbcc rsrc_CDEF_0_342	| 40879BB8
    jbra rsrc_CDEF_0_310	| 40879BBA
rsrc_CDEF_0_2FC:        /* set %a0 */
    moveal %a3@,%a0	| 40879BBC
    moveb %a0@(17),%d0	| 40879BBE
    jbeq rsrc_CDEF_0_310	| 40879BC2
    cmpib #0xfe,%d0	| 40879BC4
    jbcc rsrc_CDEF_0_342	| 40879BC8
    movel %a4,%sp@-	| 40879BCA
    movel %d4,%sp@-	| 40879BCC
    _InverRoundRect	| 40879BCE
rsrc_CDEF_0_310:        /* (40879BD0 A-line trap) */
    _PenNormal	| 40879BD0
    movel %a2,%sp@-	| 40879BD2
    _SetClip	| 40879BD4
    movel %a2,%sp@-	| 40879BD6
    _DisposRgn	| 40879BD8
    rts	| 40879BDA

/* subroutine (10 instructions) (mechanical summary) */
rsrc_CDEF_0_31C:
    moveq #0,%d3	| 40879BDC
    tstb %d7	| 40879BDE
    jbeq rsrc_CDEF_0_330	| 40879BE0
rsrc_CDEF_0_322:        /* loop: cmpi */
    cmpib #13,%a2@(0,%d7:w)	| 40879BE2
    jbeq rsrc_CDEF_0_330	| 40879BE8
    addqw #1,%d3	| 40879BEA
    subqb #1,%d7	| 40879BEC
    jbne rsrc_CDEF_0_322	| 40879BEE
rsrc_CDEF_0_330:        /* subtract 1 to %d7 */
    subqb #1,%d7	| 40879BF0
    rts	| 40879BF2

/* subroutine (7 instructions): calls rsrc_CDEF_0_346 (mechanical summary) */
rsrc_CDEF_0_334:
    moveq #0,%d0	| 40879BF4
    addw %a3@,%d0	| 40879BF6
    addw %a3@(2),%d0	| 40879BF8
    addw %a3@(6),%d0	| 40879BFC
    rts	| 40879C00
rsrc_CDEF_0_342:        /* call rsrc_CDEF_0_346 */
    jbsr rsrc_CDEF_0_346	| 40879C02
    jbra rsrc_CDEF_0_310	| 40879C04

/* Dim (gray out) the control: paint with a gray pattern in pattern-bic mode. */
rsrc_CDEF_0_346:
    tstb %fp@(-22)	| 40879C06
    jbeq rsrc_CDEF_0_360	| 40879C0A
    tstb %d6	| 40879C0C
    jbne rsrc_CDEF_0_360	| 40879C0E
    moveq #2,%d0	| 40879C10
    jbsr rsrc_CDEF_0_124	| 40879C12
    _RGBForeColor	| 40879C16
    moveq #1,%d0	| 40879C18
    jbsr rsrc_CDEF_0_124	| 40879C1A
    _RGBBackColor	| 40879C1E
rsrc_CDEF_0_360:        /* set %sp@- */
    movel %a4,%sp@-	| 40879C20
    movel #65539,%sp@-	| 40879C22
    _InsetRect	| 40879C28
    movel %a4,%sp@-	| 40879C2A
    moveal %a5@,%a0	| 40879C2C
    pea %a0@(-24)	| 40879C2E
    _PenPat	| 40879C32
    movew #11,%sp@-	| 40879C34
    _PenMode	| 40879C38
    _PaintRect
    _PenNormal
    movel %a4,%sp@-	| 40879C3E
    movel #-3,%sp@-	| 40879C40
    _InsetRect	| 40879C46
    rts	| 40879C48

/* subroutine (11 instructions) (mechanical summary) */
rsrc_CDEF_0_38A:
    tstb %d6	| 40879C4A
    jbne rsrc_CDEF_0_3A0	| 40879C4C
    movew %a0@(12),%d4	| 40879C4E
    subw %a0@(8),%d4	| 40879C52
    lsrw #1,%d4	| 40879C56
    movew %d4,%d0	| 40879C58
    swap %d4	| 40879C5A
    movew %d0,%d4	| 40879C5C
    rts	| 40879C5E
rsrc_CDEF_0_3A0:        /* clear %d4 */
    moveq #0,%d4	| 40879C60
    rts	| 40879C62

/*
 Message 1, test (param = the point): 10 inButton or 11 inCheckBox when the point is in
 the control rectangle and the control is active, else 0.
*/
rsrc_CDEF_0_3A4:
    moveb %a0@(17),%d4	| 40879C64
    addqb #1,%d4	| 40879C68
    jbeq rsrc_CDEF_0_3CC	| 40879C6A
    clrw %sp@-	| 40879C6C
    movel %d3,%sp@-	| 40879C6E
    pea %a0@(8)	| 40879C70
    _PtInRect	| 40879C74
    tstb %sp@+	| 40879C76
    jbeq rsrc_CDEF_0_3CC	| 40879C78
    addqb #1,%d4	| 40879C7A
    jbeq rsrc_CDEF_0_3CE	| 40879C7C
    movew #10,%fp@(22)	| 40879C7E
    tstb %d6	| 40879C84
    jbeq rsrc_CDEF_0_3CC	| 40879C86
    addqw #1,%fp@(22)	| 40879C88
rsrc_CDEF_0_3CC:        /* return */
    rts	| 40879C8C
rsrc_CDEF_0_3CE:        /* result 254 */
    movew #254,%fp@(22)	| 40879C8E
    rts	| 40879C94

/* Messages 3, 4 (and 10, 11): nothing. */
rsrc_CDEF_0_3D6:
    moveb #1,%fp@(23)	| 40879C96

/*
 Message 2, calculate regions: the control's region (a rounded rectangle for a push
 button, the rectangle otherwise).
*/
rsrc_CDEF_0_3DC:
    tstb %d6	| 40879C9C
    jbne rsrc_CDEF_0_40E	| 40879C9E
    jbsr rsrc_CDEF_0_38A	| 40879CA0
    _HidePen	| 40879CA2
    _OpenRgn
    moveal %a3,%a0	| 40879CA6
    _HLock	| 40879CA8
    moveal %a3@,%a0	| 40879CAA
    pea %a0@(8)	| 40879CAC
    movel %d4,%sp@-	| 40879CB0
    _FrameRoundRect	| 40879CB2
    movel %d3,%sp@-	| 40879CB4
    _CloseRgn	| 40879CB6
    _ShowPen
    moveal %a3,%a0	| 40879CBA
    _HUnlock	| 40879CBC
rsrc_CDEF_0_3FE:        /* loop: movea */
    moveal %a5@,%a0
    lea %a0@(-24),%a0
    movel %a0@+,DragPattern
    movel %a0@,DragPattern_1
    rts

rsrc_CDEF_0_40E:        /* set up and call _RectRgn */
    movel %d3,%sp@-
    pea %a0@(8)
    _RectRgn
    jbra rsrc_CDEF_0_3FE
rsrc_CDEF_0_418:        /* test %fp@(-22) */
    tstb %fp@(-22)	| 40879CD8
    jbeq rsrc_CDEF_0_424	| 40879CDC
    pea %fp@(-44)	| 40879CDE
    _RGBBackColor	| 40879CE2
rsrc_CDEF_0_424:        /* subtract 8 to %sp */
    subqw #8,%sp	| 40879CE4
    movew %a4@(4),%d0	| 40879CE6
    movew %d0,%d1	| 40879CEA
    subw %a4@,%d0	| 40879CEC
    subiw #12,%d0	| 40879CEE
    asrw #1,%d0	| 40879CF2
    subw %d0,%d1	| 40879CF4
    movew %d1,%sp@(4)	| 40879CF6
    subiw #12,%d1	| 40879CFA
    movew %d1,%sp@	| 40879CFE
    tstw ROM85	| 40879D00
    jbmi rsrc_CDEF_0_460	| 40879D04
    tstw TESysJust	| 40879D06
    jbeq rsrc_CDEF_0_460	| 40879D0A
    movew %a4@(6),%d1	| 40879D0C
    subqw #2,%d1	| 40879D10
    movew %d1,%sp@(6)	| 40879D12
    subiw #12,%d1	| 40879D16
    movew %d1,%sp@(2)	| 40879D1A
    jbra rsrc_CDEF_0_472	| 40879D1E
rsrc_CDEF_0_460:        /* set %d1 */
    movew %a4@(2),%d1	| 40879D20
    addqw #2,%d1	| 40879D24
    movew %d1,%sp@(2)	| 40879D26
    addiw #12,%d1	| 40879D2A
    movew %d1,%sp@(6)	| 40879D2E
rsrc_CDEF_0_472:        /* set %sp@- */
    movel %sp,%sp@-	| 40879D32
    _EraseRect	| 40879D34
    moveal %a3@,%a0	| 40879D36
    movew %a0@(18),%d5	| 40879D38
    moveb %a0@(17),%d0	| 40879D3C
    jbeq rsrc_CDEF_0_496	| 40879D40
    cmpib #0xfe,%d0	| 40879D42
    jbcs rsrc_CDEF_0_48E	| 40879D46
    jbsr rsrc_CDEF_0_346	| 40879D48
    jbra rsrc_CDEF_0_496	| 40879D4C
rsrc_CDEF_0_48E:        /* set %sp@- */
    movel #131074,%sp@-	| 40879D4E
    _PenSize	| 40879D54
rsrc_CDEF_0_496:        /* set %sp@- */
    movel %sp,%sp@-	| 40879D56
    cmpib #2,%d6	| 40879D58
    jbeq rsrc_CDEF_0_4A2	| 40879D5C
    _FrameRect	| 40879D5E
    jbra rsrc_CDEF_0_4A4	| 40879D60
rsrc_CDEF_0_4A2:        /* (40879D62 A-line trap) */
    .short  0xA8B7	| 40879D62 _FrameOval
rsrc_CDEF_0_4A4:        /* (40879D64 A-line trap) */
    _PenNormal	| 40879D64
    lsrw #1,%d5	| 40879D66
    jbcc rsrc_CDEF_0_4EA	| 40879D68
    cmpiw #2,%d6	| 40879D6A
    jbeq rsrc_CDEF_0_4DC	| 40879D6E
    movel %sp,%sp@-	| 40879D70
    movel OneOne,%sp@-	| 40879D72
    _InsetRect	| 40879D76
    movel %sp@,%sp@-	| 40879D78
    _MoveTo	| 40879D7A
    movel %sp@(4),%sp@-	| 40879D7C
    .short  0xA891	| 40879D80 _LineTo
    movew %sp@(6),%sp@-	| 40879D82
    movew %sp@(2),%sp@-	| 40879D86
    subqw #1,%sp@	| 40879D8A
    _MoveTo	| 40879D8C
    movew %sp@(2),%sp@-	| 40879D8E
    subqw #1,%sp@	| 40879D92
    movew %sp@(6),%sp@-	| 40879D94
    .short  0xA891	| 40879D98 _LineTo
    jbra rsrc_CDEF_0_4EA	| 40879D9A
rsrc_CDEF_0_4DC:        /* set %sp@- */
    movel %sp,%sp@-	| 40879D9C
    movel #196611,%sp@-	| 40879D9E
    _InsetRect	| 40879DA4
    movel %sp,%sp@-	| 40879DA6
    .short  0xA8B8	| 40879DA8 _PaintOval
rsrc_CDEF_0_4EA:        /* add 8 to %sp */
    addqw #8,%sp	| 40879DAA
    jbra rsrc_CDEF_0_310	| 40879DAC
