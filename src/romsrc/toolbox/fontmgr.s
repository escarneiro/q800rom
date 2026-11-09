/*
 toolbox/fontmgr.s - Font Manager
 From FONTMANAGER (0x408263B0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside say what that part does.
*/

/* INITFONTS: _InitFonts: the system font, width table, font globals. */
trap_InitFonts:
FONTMANAGER:
INITFONTS:
    tstb 0xd42
    jbeq FONTMANAGER_A6
    moveq #-1,%d2
    clrw FOutError
    jbsr FMSWAPFONT_D02
    clrw CurFMDevice
    clrb FScaleDisable
    clrb FractEnable
    st FontFlag
    movew SPFont,ApFontID
    addqw #1,ApFontID
    moveb #12,FMDefaultSize
    movel WidthTabHandle,%d0
    jbne FONTMANAGER_52
    movel #1076,%d0
    .short  0xA522	| 408263EE _NewHandle (flags 0x0500)
    bnew FONTMANAGER_B0
    movel %a0,WidthTabHandle
    moveq #48,%d0
    .short  0xA722	| 408263FA _NewHandle (flags 0x0700)
    jbne FONTMANAGER_52
    movel %a0,WidthListHand
FONTMANAGER_52:         /* JSwapFont from the _FMSwapFont trap table entry (0x1204); the synthetic font list back to one entry */
    movel 0x1204,JSwapFont
    moveq #20,%d0
    movel SynListHandle,%d1
    jble FONTMANAGER_66
    moveal %d1,%a0
    _SetHandleSize
    jbra FONTMANAGER_6E
FONTMANAGER_66:         /* first use: a new synthetic font list, system heap, cleared */
    .short  0xA522	| 40826416 _NewHandle (flags 0x0500)
    jbne FONTMANAGER_B0
    movel %a0,SynListHandle
FONTMANAGER_6E:         /* first call: no font handle, no FOND; flush the caches; load the system font */
    moveal %a0@,%a0
    movel %d2,%a0@(4)
    tstb 0xd42
    jbpl FONTMANAGER_A6
    clrb 0xd42
    clrl FOutFontHandle
    clrl LastFOND
    jbsr INITFONTS_B4
    movel OneOne,%sp@-
    movel OneOne,%sp@-
    clrl %sp@-
    clrl %sp@-
    subqw #4,%sp
    pea %sp@(4)
    _FMSwapFont
    lea %sp@(20),%sp
    movel FOutFontHandle,ROMFont0
FONTMANAGER_A6:         /* the script fonts (Script Manager) */
    bigjmp SMGRINITFONTS
FONTMANAGER_B0:         /* no memory: system error 25 (dsMemFullErr) */
    moveq #25,%d0
    _SysError

INITFONTS_B4:           /* flush the font caches: restore the last FOND's state */
    moveal LastFOND,%a0
    moveb FondState,%d0
    cmpib #0xff,%d0
    jbeq FONTMANAGER_C4
    _HSetState
FONTMANAGER_C4:         /* invalidate: no space extra, no FOND; empty the synthetic font list */
    moveq #-1,%d2
    movel %d2,LastSPExtra
    movew %d2,FONDID
    moveal SynListHandle,%a0
    _GetHandleSize
    moveal %a0@,%a1
    movel %d0,%d1
    divuw #20,%d1
    subqw #1,%d1
FONTMANAGER_DE:         /* per used synthetic font entry: dispose of its font, mark it free */
    moveal %a1@+,%a0
    cmpl %a1@,%d2
    jbeq FONTMANAGER_E8
    _DisposHandle
    movel %d2,%a1@
FONTMANAGER_E8:         /* next entry; then every width table in the width list */
    lea %a1@(16),%a1
    dbf %d1,FONTMANAGER_DE
    moveal SynListHandle,%a0
    moveq #20,%d0
    _SetHandleSize
    movel WidthListHand,%d0
    jbeq INITFONTS_11C
    moveal %d0,%a1
    moveal %a1@,%a1
    moveq #11,%d1
FONTMANAGER_104:        /* per cached width table: invalidate (font handle and family -1) */
    movel %a1@+,%d0
    jbeq INITFONTS_11C
    moveal %d0,%a0
    movel %a0@,%d0
    jbeq FONTMANAGER_118
    moveal %a0@,%a0
    movel %d2,%a0@(1024)
    movew %d2,%a0@(1036)
FONTMANAGER_118:        /* loop */
    dbf %d1,FONTMANAGER_104

INITFONTS_11C:          /* invalidate the current width table and CurFMFamily */
    moveq #-1,%d2
    jbsr INITFONTS_12E
    movel %d2,%a0@(1024)
    movew %d2,%a0@(1036)
    movew %d2,CurFMFamily
    rts

INITFONTS_12E:          /* the width table, dereferenced */
    moveal WidthTabHandle,%a0
    moveal %a0@,%a0
    rts

INITFONTS_136:          /* the family and size asked for: 0 = system font and size; 1 = application font */
    moveq #0,%d1
    movew %a3@,%d0
    jbne FONTMANAGER_146
    movew SysFontFam,%d0
    movew SysFontSize,%d1
    jbne FONTMANAGER_158
FONTMANAGER_146:        /* size 0: FMDefaultSize, else 12 */
    moveb FMDefaultSize,%d1
    jbne FONTMANAGER_14E
    moveq #12,%d1
FONTMANAGER_14E:        /* family 1: the application font */
    cmpiw #1,%d0
    jbne FONTMANAGER_158
    movew ApFontID,%d0
FONTMANAGER_158:        /* (family, size) in %d0 */
    swap %d0
    movew %a3@(2),%d0
    jbne FONTMANAGER_162
    movew %d1,%d0
FONTMANAGER_162:        /* return */
    rts

/* FMSWAPFONT: _FMSwapFont: find the font (FOND/NFNT/FONT, size, style), its width table and the output record for QuickDraw. */
trap_FMSwapFont:
FMSWAPFONT:
    lea FOutError,%a0
    movel %a0,%sp@(8)
    moveq #-1,%d2
    cmpl LastSPExtra,%d2
    jbeq FMSWAPFONT_D4
    addqb #1,FontFlag
    jbeq FMSWAPFONT_2E
    jbsr INITFONTS_11C
    cmpib #9,FontFlag
    jbeq FMSWAPFONT_CB6
    jbgt FMSWAPFONT_FE
    moveb #8,FontFlag
FMSWAPFONT_2E:          /* same input as last time? family */
    moveal %sp@(4),%a0
    lea CurFMFamily,%a1
    cmpml %a0@+,%a1@+
    jbeq FMSWAPFONT_58
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    jbsr INITFONTS_136
    movel %d0,%d2
    lea CurFMFamily,%a3
    jbsr INITFONTS_136
    moveal %sp@+,%a3
    cmpl %d2,%d0
    jbne FMSWAPFONT_170
    movel %a0@(-4),%a1@(-4)
FMSWAPFONT_58:          /* size and face (the face may differ only in bits the font has anyway) */
    cmpml %a0@+,%a1@+
    jbeq FMSWAPFONT_6C
    movel %a0@-,%d0
    movel %a1@-,%d1
    eorl %d0,%d1
    andil #-16711681,%d1
    jbne FMSWAPFONT_D4
    movel %a0@+,%a1@+
FMSWAPFONT_6C:          /* device and scaling; the port's text mode, colors and depth */
    cmpml %a0@+,%a1@+
    jbne FMSWAPFONT_D4
    cmpml %a0@+,%a1@+
    jbne FMSWAPFONT_D4
    tstb QDExist
    jbmi FMSWAPFONT_D8
    moveal %a5@,%a0
    movel %a0@,%d0
    jbeq FMSWAPFONT_D8
    moveal %d0,%a0
    movew %a0@(72),%d1
    cmpw 0xd3e,%d1
    jbne FMSWAPFONT_A6
    lea %a0@(80),%a1
    lea 0xd36,%a0
    cmpml %a0@+,%a1@+
    jbne FMSWAPFONT_A6
    cmpml %a0@+,%a1@+
    jbne FMSWAPFONT_A6
    moveal %d0,%a0
    jbsr FMSWAPFONT_380
    cmpw 0xd40,%d0
FMSWAPFONT_A6:          /* depth differs: the shortcut; else done unless the space extra changed */
    jbne FMSWAPFONT_3B6
    moveal %a5@(0,%za0)@(0),%a0	| 408265BE
    movel LastSPExtra,%d0
    cmpl %a0@(76),%d0
    jbeq FMSWAPFONT_D8
    linkw %fp,#-138
    clrw %fp@(-72)
    clrw %fp@(-74)
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveal %fp@(8),%a3
    subqb #2,FontFlag
    jbra FMSWAPFONT_986
FMSWAPFONT_D4:          /* something changed: the full swap */
    jbra FMSWAPFONT_170
FMSWAPFONT_D8:          /* same font: make sure its strike is loaded */
    subqb #2,FontFlag
FMSWAPFONT_DC:          /* reload the purged font */
    moveal FOutFontHandle,%a0
    tstl %a0@
    jbne FMSWAPFONT_FE
    movel %a0,%sp@-
    movew #-1,ROMMapInsert
    _LoadResource
    cmpib #0xff,FontFlag
    jbeq FMSWAPFONT_D4
    tstl %a0@
    jbeq FMSWAPFONT_D4
    jbsr FONTMETRICS_8C
FMSWAPFONT_FE:          /* WidthPtr; return the output record */
    moveal WidthTabHandle,%a0
    movel %a0@,WidthPtr
    st FontFlag
    moveal %sp@+,%a0
    addqw #4,%sp
    jmp %a0@

FMSWAPFONT_110:         /* a direction's numerator and scale factor, from a cached width table */
    lea FOutNumer_h,%a0
    movew %a1@+,%a0@(0x0,%d1:w)
    lea FScaleVFact,%a0
    moveq #0,%d0
    movew %a1@(2),%d0
    asll #8,%d0
    addw %d1,%d1
    negw %d1
    movel %d0,%a0@(0x0,%d1:w)
    rts

FMSWAPFONT_12E:         /* dereference a font handle, loading it if purged */
    tstl %a0@
    jbne FMSWAPFONT_148
    movel %a0,%sp@-
    movew #-1,ROMMapInsert
    _LoadResource
    cmpib #0xff,FontFlag
    jbeq FMSWAPFONT_14C
    tstl %a0@
    jbeq FMSWAPFONT_14C
FMSWAPFONT_148:         /* return the pointer */
    moveal %a0@,%a0
    rts
FMSWAPFONT_14C:         /* could not load: fall back */
    jbra FMSWAPFONT_C3E

FMSWAPFONT_150:         /* the last font, if a height table was added to it (font type bit 0): purgeable again */
    cmpiw #-1,FONDID
    jbeq FMSWAPFONT_16E
    movel FOutFontHandle,%d0
    jbeq FMSWAPFONT_16E
    moveal %d0,%a0
    movel %a0@,%d0
    jbeq FMSWAPFONT_16E
    moveal %d0,%a1
    btst #0,%a1@
    jbeq FMSWAPFONT_16E
    _HPurge
FMSWAPFONT_16E:         /* return */
    rts

FMSWAPFONT_170:         /* the full swap: frame */
    linkw %fp,#-138
    clrw %fp@(-72)
    clrw %fp@(-74)
    moveml %d3-%d7/%a2-%a4,%sp@-
FMSWAPFONT_180:         /* copy the input record; a different device: the device's resolution */
    jbsr FMSWAPFONT_150
    moveal %fp@(8),%a0
    lea %fp@(-16),%a1
    moveq #16,%d0
    _BlockMove
    moveal %a1,%a3
    moveb %a3@(4),FOutUnused
    movew %a3@(6),%d0
    cmpw CurFMDevice,%d0
    jbeq FMSWAPFONT_1A4
    jbsr FMSWAPFONT_CD8
FMSWAPFONT_1A4:         /* family and size resolved; repeated failures: the system font */
    jbsr INITFONTS_136
    movel %d0,%a3@
    clrb %a3@(5)
    lea FontFlag,%a4
    cmpib #6,%a4@
    jblt FMSWAPFONT_1BA
    clrw %a3@
FMSWAPFONT_1BA:         /* caches invalid: flush */
    tstb %a4@
    jbpl FMSWAPFONT_1C4
    jbsr INITFONTS_11C
    clrb %a4@
FMSWAPFONT_1C4:         /* with a width table list: look for a cached width table */
    movel WidthListHand,%d0
    jbeq FMSWAPFONT_1DE
    moveq #-1,%d2
    cmpl LastSPExtra,%d2
    jbeq FMSWAPFONT_1DA
    cmpw CurFMFamily,%d2
    jbne FMSWAPFONT_1E2
    jbra FMSWAPFONT_1DE
FMSWAPFONT_1DA:         /* flush */
    jbsr INITFONTS_B4
FMSWAPFONT_1DE:         /* no list: build into the one width table */
    jbra FMSWAPFONT_30C
FMSWAPFONT_1E2:         /* search the width table list (12 entries) */
    moveal %d0,%a4
    moveal %a4@,%a4
    moveq #-1,%d2
    moveq #-1,%d3
    sf %d4
    moveq #-4,%d5
    sf %d6
    moveq #-1,%d7
FMSWAPFONT_1F2:         /* per entry: a purged handle is a free slot */
    addqw #4,%d5
    movel %a4@,%d1
    jbeq FMSWAPFONT_29E
    moveal %d1,%a0
    movel %a0@,%d0
    jbeq FMSWAPFONT_28E
    movew %d5,%d7
    moveal %d0,%a1
    moveq #3,%d1
    moveal %a3,%a0
    lea %a1@(1036),%a1
    cmpiw #-1,%a1@
    jbne FMSWAPFONT_216
    movew %d5,%d3
FMSWAPFONT_216:         /* compare family, size, face, device, scaling */
    cmpml %a0@+,%a1@+
    dbne %d1,FMSWAPFONT_216
    jbne FMSWAPFONT_290
    st %d6
    movew %a1@,%d0
    cmpw FONDID,%d0
    jbeq FMSWAPFONT_26A
    moveb FondState,%d0
    moveal LastFOND,%a0
    _HSetState
    moveal %a4@,%a0
    _HNoPurge
    movew %a1@+,%d0
    movew %d0,FONDID
    moveal %a1@+,%a0
    movel %a0,LastFOND
    jbeq FMSWAPFONT_26C
    jbsr FMSWAPFONT_12E
    moveb %a0@,GotStrike
    moveal LastFOND,%a0
    _HGetState
    moveb %d0,FondState
    _HNoPurge
    moveal WidthListHand,%a4
    moveal %a4@,%a4
    addaw %d5,%a4
    moveal %a4@,%a1
    moveal %a1@,%a1
    lea %a1@(1058),%a1
    jbra FMSWAPFONT_26C
FMSWAPFONT_26A:         /* found: its font and style information */
    addqw #6,%a1
FMSWAPFONT_26C:         /* take its scale factors and font handle */
    moveb %a1@+,UsedFWidth
    moveb %a1@+,FOutUnused
    moveq #0,%d1
    jbsr FMSWAPFONT_110
    moveq #2,%d1
    jbsr FMSWAPFONT_110
    moveal %a4@,%a0
    moveal %a0@,%a1
    moveal %a1@(1024),%a1
    movel %a1,FOutFontHandle
    jbra FMSWAPFONT_2EE
FMSWAPFONT_28E:         /* free slot */
    movew %d5,%d2
FMSWAPFONT_290:         /* next entry */
    addqw #4,%a4
    cmpiw #44,%d5
    jbcs FMSWAPFONT_1F2
    st %d4
    subqw #4,%a4
FMSWAPFONT_29E:         /* not found: allocate a width table (or reuse the oldest) */
    moveal WidthTabHandle,%a1
    moveal %a1@,%a1
    cmpiw #-1,%a1@(1036)
    jbeq FMSWAPFONT_30C
    exg %d3,%d5
    tstw %d5
    jbpl FMSWAPFONT_2D4
    movel #1076,%d1
    .short  0xA461	| 408267CC _MaxBlock (flags 0x0400)
    cmpl %d1,%d0
    jble FMSWAPFONT_2D0
    movel %d1,%d0
    movew %d2,%d5
    jbpl FMSWAPFONT_2D4
    tstb %d4
    jbne FMSWAPFONT_2D0
    movew %d3,%d5
    .short  0xA522	| 408267DE _NewHandle (flags 0x0500)
    jbne FMSWAPFONT_30C
    jbra FMSWAPFONT_2D4
FMSWAPFONT_2D0:         /* reuse */
    movew %d7,%d5
    jbmi FMSWAPFONT_30C
FMSWAPFONT_2D4:         /* move it to the front of the list */
    moveal WidthListHand,%a4
    moveal %a4@,%a4
    lea %a4@(0x0,%d5:w),%a4
    movel %a4@,%d1
    jbeq FMSWAPFONT_2EE
    moveal %d1,%a0
    tstl %a0@
    jbne FMSWAPFONT_2EE
    _ReallocHandle
    jbne FMSWAPFONT_30C
    jbra FMSWAPFONT_2D4
FMSWAPFONT_2EE:         /* shift the entries down */
    jbra FMSWAPFONT_2F4
FMSWAPFONT_2F0:         /* loop */
    movel %a4@-,%a4@(4)
FMSWAPFONT_2F4:         /* the new width table is current */
    subqw #4,%d5
    jbpl FMSWAPFONT_2F0
    movel WidthTabHandle,%d1
    movel %a0,WidthTabHandle
    _HNoPurge
    movel %d1,%a4@
    moveal %d1,%a0
    _HPurge
    tstb %d6
    jbne FMSWAPFONT_314
FMSWAPFONT_30C:         /* find the font: the FOND and the strike */
    jbsr INITFONTS_11C
    jbsr FMSWAPFONT_A6A
FMSWAPFONT_314:         /* the output record: ascent, descent, widMax, leading as the font has them; with FScaleDisable, scaled (below) */
    moveal FOutFontHandle,%a0
    jbsr FMSWAPFONT_12E
    tstb FScaleDisable
    jbne FMSWAPFONT_358
    lea FOutAscent,%a1
    moveb %a0@(19),%a1@+
    moveb %a0@(21),%a1@+
    moveb %a0@(7),%a1@+
    moveb %a0@(23),%a1@
    jbra FMSWAPFONT_3DE

FMSWAPFONT_33A:         /* vertical scale */
    movel FScaleVFact,%d1

FMSWAPFONT_33E:         /* scale one metric (FixMul, FixRound) */
    extw %d0
    swap %d0
    clrw %d0
    moveml %d0-%d3/%a0-%a1,%sp@-
    _FixMul
    _FixRound
    movew %sp@+,%d0
    addqw #2,%sp
    moveml %sp@+,%a0-%a1
    moveb %d0,%a1@+
    rts
FMSWAPFONT_358:         /* FScaleDisable: the metrics scaled by FScaleVFact and FScaleHFact */
    lea FOutAscent,%a1
    moveb %a0@(19),%d0
    jbsr FMSWAPFONT_33A
    moveb %a0@(21),%d0
    jbsr FMSWAPFONT_33A
    moveb %a0@(7),%d0
    movel FScaleHFact,%d1
    jbsr FMSWAPFONT_33E
    moveb %a0@(23),%d0
    jbsr FMSWAPFONT_33A
    jbra FMSWAPFONT_3DE

FMSWAPFONT_37A:         /* the depth of the port's device: 1 for black and white */
    tstb QDExist
    jbmi FMSWAPFONT_3B2

FMSWAPFONT_380:         /* the port's device pixels */
    moveal %a5@,%a1
    movel %a1@,%d0
    jbeq FMSWAPFONT_3B2
    moveal %d0,%a0
    movel %a1@(-122),%d0
    tstw %a0@(6)
    jbpl FMSWAPFONT_39E
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveal %a0@(2,%za0)@(0),%a0	| 408268A6
    cmpl %a0@,%d0
    jbeq FMSWAPFONT_3A4
    jbra FMSWAPFONT_3AA
FMSWAPFONT_39E:         /* same as the screen */
    cmpl %a0@(2),%d0
    jbne FMSWAPFONT_3B2
FMSWAPFONT_3A4:         /* the device's pixmap */
    bsrl GETDEVPIX
FMSWAPFONT_3AA:         /* its pixel size */
    moveq #0,%d0
    movew %a0@(32),%d0
    rts
FMSWAPFONT_3B2:         /* 1 bit */
    moveq #1,%d0
    rts
FMSWAPFONT_3B6:         /* same font and scaling, other mode, colors or depth: on to the color search */
    linkw %fp,#-138
    clrw %fp@(-72)
    clrw %fp@(-74)
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveal %fp@(8),%a3
    subqb #2,FontFlag
    jbsr FMSWAPFONT_150
    jbsr INITFONTS_12E
    moveal %a0@(1024),%a0
    movel %a0,FOutFontHandle
FMSWAPFONT_3DE:         /* color screen with a 1-bit font: look for a colorized (synthetic) font */
    jbsr FMSWAPFONT_37A
    movel %d0,%d6
    cmpiw #1,%d6
    jbeq FMSWAPFONT_40A
    moveb FOutUnused,%d0
    andib #0x9f,%d0
    jbne FMSWAPFONT_40A
    _StackSpace
    cmpil #3072,%d0
    jblt FMSWAPFONT_40A
    moveal FOutFontHandle,%a0
    jbsr FMSWAPFONT_12E
    btst #6,%a0@
    jbeq FMSWAPFONT_40E
FMSWAPFONT_40A:         /* no */
    jbra FMSWAPFONT_73C
FMSWAPFONT_40E:         /* the depth as log2; the colors of the port */
    bfffo %d6,26,6,%d6
    notw %d6
    andiw #7,%d6
    movew #1,%fp@(-138)
    lea %fp@(-136),%a1
    clrl %a1@+
    clrw %a1@+
    moveq #-1,%d0
    movel %d0,%a1@+
    movew %d0,%a1@
    tstb QDExist
    jbmi FMSWAPFONT_46A
    movel %a5@(0,%za0)@(0),%d0	| 40826946
    jbeq FMSWAPFONT_46A
    moveal %d0,%a0
    movew %a0@(72),%d0
    andiw #-9,%d0
    movew %d0,%fp@(-138)
    cmpiw #50,%d0
    jbeq FMSWAPFONT_40A
    bclr #5,%d0
    jbne FMSWAPFONT_45E
    bclr #2,%d0
    jbne FMSWAPFONT_40A
    subqw #3,%d0
    jbeq FMSWAPFONT_40A
    jbra FMSWAPFONT_46A
FMSWAPFONT_45E:         /* foreground and background */
    pea %fp@(-136)
    _GetForeColor
    pea %fp@(-130)
    _GetBackColor
FMSWAPFONT_46A:         /* search the FOND's style table for a strike of the right depth */
    movel %a3,%sp@-
    moveq #0,%d3
    moveq #0,%d5
    movew %d6,%d7
    movew %d6,%d0
    aslw #8,%d0
    orb %a3@(4),%d0
    moveb FOutUnused,%d1
    eorb %d1,%d0
    jbsr INITFONTS_12E
    movew %a0@(1068),%d2
    movel LastFOND,%d1
    jbeq FMSWAPFONT_530
    moveal %d1,%a0
    moveal %a0@,%a0
    lea %a0@(52),%a0
    movew %a0@+,%d1
FMSWAPFONT_49A:         /* per entry: size, style with depth */
    cmpw %a0@+,%d2
    jblt FMSWAPFONT_4C2
    jbne FMSWAPFONT_4BC
    cmpw %a0@,%d0
    jbeq FMSWAPFONT_4CA
    movew %a0@,%d4
    cmpiw #256,%d4
    jblt FMSWAPFONT_4BC
FMSWAPFONT_4AC:         /* a deeper font for the same style */
    cmpiw #1280,%d4
    jbge FMSWAPFONT_4BC
    addiw #256,%d4
    cmpw %d4,%d0
    jbne FMSWAPFONT_4AC
    movel %a0,%d5
FMSWAPFONT_4BC:         /* next entry */
    addqw #4,%a0
    dbf %d1,FMSWAPFONT_49A
FMSWAPFONT_4C2:         /* best found */
    tstl %d5
    jbeq FMSWAPFONT_530
    moveal %d5,%a0
    moveb %a0@,%d7
FMSWAPFONT_4CA:         /* load it ('NFNT'); not found and the current font is in ROM: look in ROM too */
    movew %a0@(2),%d0
    movew %d0,%d5
    jbsr FMSWAPFONT_D1C
    jbne FMSWAPFONT_4F6
    moveal FOutFontHandle,%a0
    jbsr FMSWAPFONT_12E
    movel %a0,%d0
    _StripAddress
    moveal %d0,%a0
    movel ROMBase,%d0
    _StripAddress
    cmpal %d0,%a0
    jblt FMSWAPFONT_530
    movew %d5,%d0
    jbsr FMSWAPFONT_D16
    jbeq FMSWAPFONT_530
FMSWAPFONT_4F6:         /* use it; its height table */
    movew %d7,%d3
    movel %a0,FOutFontHandle
    moveal %a0,%a2
    jbsr FONTMETRICS_8C
    moveal %a2@,%a0
    cmpw %d6,%d7
    jbne FMSWAPFONT_510
    btst #1,%a0@
    jbeq FMSWAPFONT_71E
FMSWAPFONT_510:         /* colorized: the current colors */
    bclr #5,%fp@(-137)
    cmpiw #2,%fp@(-138)
    jbeq FMSWAPFONT_530
    pea %fp@(-136)
    _GetForeColor
    pea %fp@(-130)
    _GetBackColor
    bset #5,%fp@(-137)
FMSWAPFONT_530:         /* look in the synthetic font list */
    jbsr INITFONTS_12E
    movel %a0@(1070),%d5
    moveal SynListHandle,%a0
    _GetHandleSize
    divuw #20,%d0
    subqw #1,%d0
    moveal %a0@,%a0
FMSWAPFONT_546:         /* per entry: same font, depth and colors? */
    moveal %a0@+,%a2
    movel %a0@+,%d2
    cmpl %d5,%d2
    jbne FMSWAPFONT_580
    tstl %a2@
    jbeq FMSWAPFONT_580
    moveal %a2@,%a3
    movew %a3@,%d2
    lsrw #2,%d2
    andiw #7,%d2
    cmpw %d6,%d2
    jbne FMSWAPFONT_580
    moveal %a0,%a3
    lea %fp@(-136),%a1
    moveq #2,%d4
FMSWAPFONT_568:         /* compare the colors */
    cmpml %a3@+,%a1@+
    dbne %d4,FMSWAPFONT_568
    jbne FMSWAPFONT_580
    moveal %a2@,%a0
    btst #0,%a0@
    jbeq FMSWAPFONT_57C
    moveal %a2,%a0
    _HNoPurge
FMSWAPFONT_57C:         /* found */
    jbra FMSWAPFONT_71E
FMSWAPFONT_580:         /* next; not found: build a synthetic font of the depth, with the font's 'fctb' if it has one */
    lea %a0@(12),%a0
    dbf %d0,FMSWAPFONT_546
    moveal FOutFontHandle,%a0
    _HGetState
    movew %d0,%d7
    _HNoPurge
    moveal %a0@,%a0
    moveq #0,%d5
    tstb %a0@(1)
    jbpl FMSWAPFONT_5B4
    jbsr INITFONTS_12E
    movel %a0@(1070),%d0
    jbpl FMSWAPFONT_5B4
    subqw #4,%sp
    movel #1717793890,%sp@-
    movew %d0,%sp@-
    _GetResource
    movel %sp@+,%d5
FMSWAPFONT_5B4:         /* above 8 bits: only from a color strike, and built at 8 bits */
    movel %d5,%fp@(-82)
    moveal %sp,%a3
    moveal FOutFontHandle,%a0
    cmpiw #3,%d6
    jble FMSWAPFONT_5DA
    tstw %d3
    jbeq FMSWAPFONT_726
    moveal %a0@,%a1
    movew %a1@,%d0
    btst #9,%d0
    jbeq FMSWAPFONT_726
    movew #3,%d6
FMSWAPFONT_5DA:         /* sizes; with 4K to spare: copy the font, grow it for the deeper strike, note the depth in the font type */
    _GetHandleSize
    moveal %a0@,%a1
    movew %a1@(24),%d1
    addw %d1,%d1
    muluw %a1@(14),%d1
    movel %d1,%d5
    asll %d3,%d1
    movel %d1,%d4
    subl %d1,%d0
    movel %d0,%d2
    lsll %d6,%d5
    addl %d5,%d0
    movel %d0,%sp@-
    .short  0xA162	| 40826B0C _PurgeSpace (flags 0x0100)
    movel %sp@+,%d1
    cmpal %d1,%a0
    jbls FMSWAPFONT_726
    subl %d1,%d0
    cmpil #4096,%d0
    jbls FMSWAPFONT_726
    moveal FOutFontHandle,%a0
    moveal %d1,%a2
    movel %d2,%sp@-
    _HandToHand
    movel %sp@+,%d2
    tstw %d0
    jbne FMSWAPFONT_726
    movel %a2,%d0
    _SetHandleSize
    jbne FMSWAPFONT_724
    moveal %a0,%a2
    moveal FOutFontHandle,%a0
    movew %d7,%d0
    _HSetState
    moveal %a2@,%a1
    movew %d6,%d0
    aslw #2,%d0
    bset #8,%d0
    movew %fp@(-138),%d1
    andiw #32,%d1
    lslw #4,%d1
    orw %d1,%d0
    andiw #-29,%a1@
    orw %d0,%a1@
    movew %a1@(10),%d0
    swap %d0
    jbpl FMSWAPFONT_658
    moveq #0,%d0
FMSWAPFONT_658:         /* the new row width and offsets */
    movew %a1@(16),%d0
    addl %d0,%d0
    subl %d4,%d0
    addl %d5,%d0
    asrl #1,%d0
    movew %d0,%a1@(16)
    swap %d0
    movew %d0,%a1@(10)
    moveq #26,%d0
    moveal %a0@,%a0
    addal %d4,%a0
    addal %d0,%a0
    addal %d5,%a1
    addal %d0,%a1
    subl %d0,%d2
    movel %d2,%d0
    _BlockMove
    moveq #1,%d4
    lslw %d3,%d4
    movew %d4,%fp@(-92)
    pea %fp@(-124)
    movew %fp@(-138),%sp@-
    jsr @(0x1a38,%za0)@(0)	| 40826BA4
    moveal FOutFontHandle,%a0
    jbsr FMSWAPFONT_12E
    movew %a0@(24),%d2
    muluw %a0@(14),%d2
    asll #4,%d2
    lea %a0@(26),%a0
    moveal %a2@,%a1
    lea %a1@(26),%a1
    moveq #1,%d5
    lslw %d6,%d5
    moveq #0,%d6
    moveq #0,%d3
FMSWAPFONT_6BA:         /* expand the strike with the color lookup table (bfextu/bfins) */
    bfextu %a0@,%d6,%d4,%d0
    movel %sp@(0x0,%d0:w:4),%d0
    bfins %d0,%a1@,%d3,%d5
    addl %d4,%d6
    addl %d5,%d3
    subql #1,%d2
    jbhi FMSWAPFONT_6BA
    moveal %a3,%sp
    moveal SynListHandle,%a0
    _GetHandleSize
    movel %d0,%d1
    divuw #20,%d1
    subqw #1,%d1
    moveal %a0@,%a1
    moveq #-1,%d2
    jbra FMSWAPFONT_6E8
FMSWAPFONT_6E4:         /* next list entry */
    lea %a1@(20),%a1
FMSWAPFONT_6E8:         /* a free slot in the synthetic font list, else grow it */
    moveal %a1@,%a3
    cmpl %a1@(4),%d2
    jbeq FMSWAPFONT_70C
    tstl %a3@
    dbeq %d1,FMSWAPFONT_6E4
    jbeq FMSWAPFONT_708
    movew %d0,%d3
    addiw #20,%d0
    _SetHandleSize
    jbne FMSWAPFONT_708
    moveal %a0@,%a1
    addaw %d3,%a1
    jbra FMSWAPFONT_70C
FMSWAPFONT_708:         /* dispose of a purged entry */
    moveal %a1@,%a0
    _DisposHandle
FMSWAPFONT_70C:         /* store the new font, its depth and colors */
    movel %a2,%a1@+
    jbsr INITFONTS_12E
    movel %a0@(1070),%a1@+
    lea %fp@(-136),%a0
    moveq #12,%d0
    _BlockMove
FMSWAPFONT_71E:         /* the font to use */
    movel %a2,FOutFontHandle
    jbra FMSWAPFONT_73A
FMSWAPFONT_724:         /* _DisposHandle */
    _DisposHandle
FMSWAPFONT_726:         /* no memory: the 1-bit font */
    moveal FOutFontHandle,%a0
    movew %d7,%d0
    _HSetState
    jbsr INITFONTS_12E
    moveal %a0@(1024),%a0
    movel %a0,FOutFontHandle
FMSWAPFONT_73A:         /* restore %a3 */
    moveal %sp@+,%a3
FMSWAPFONT_73C:         /* style extras from FMStyleTab, per face bit (7 of them) */
    moveb FOutUnused,%d1
    lea FOutBold,%a0
    clrl %a0@+
    clrw %a0@+
    clrb %a0@+
    tstb %d1
    jbeq FMSWAPFONT_782
    moveq #0,%d2
    lea FMStyleTab,%a1
    moveq #6,%d0
    lea FOutBold,%a0
FMSWAPFONT_75A:         /* per style bit: its extra into the output record */
    moveb %a1@+,%d2
    moveb %a1@+,%d3
    moveb %a1@+,%d4
    lsrw #1,%d1
    jbcc FMSWAPFONT_76C
    addb %d3,%a0@(0x0,%d2:w)
    addb %d4,FOutExtra
FMSWAPFONT_76C:         /* next bit; underline offsets */
    dbf %d0,FMSWAPFONT_75A
    btst #2,FOutUnused
    jbeq FMSWAPFONT_782
    lea FOutULOffset,%a0
    moveb %a1@+,%a0@+
    moveb %a1@+,%a0@+
    moveb %a1@+,%a0@+
FMSWAPFONT_782:         /* fractional widths from the FOND's style properties */
    movel LastFOND,%d0
    jbeq FMSWAPFONT_816
    tstb FDevDisable
    jbne FMSWAPFONT_798
    tstb %a3@(6)
    bnew FMSWAPFONT_816
FMSWAPFONT_798:         /* only for an outline-less strike or fractional widths */
    btst #5,GotStrike
    jbne FMSWAPFONT_816
    btst #4,GotStrike
    jbne FMSWAPFONT_7AE
    tstb FractEnable
    jbeq FMSWAPFONT_816
FMSWAPFONT_7AE:         /* the FOND's style extra per face bit */
    moveal %d0,%a0
    jbsr FMSWAPFONT_12E
    tstw %a0@(6)
    jbeq FMSWAPFONT_816
    lea %a0@(28),%a0
    movew %a0@+,%d6
    extl %d6
    moveb FOutUnused,%d1
    jbeq FMSWAPFONT_7F4
    btst #6,GotStrike
    jbne FMSWAPFONT_7D8
    movew %fp@(-74),%d0
    notw %d0
    andw %d0,%d1
FMSWAPFONT_7D8:         /* 8 face bits */
    moveq #7,%d0
FMSWAPFONT_7DA:         /* per bit: its extra (Fixed 4.12) */
    movew %a0@+,%d2
    lsrw #1,%d1
    jbcc FMSWAPFONT_7F0
    cmpiw #-28673,%d2
    jbgt FMSWAPFONT_7EC
    bclr #15,%d2
    negw %d2
FMSWAPFONT_7EC:         /* add it */
    extl %d2
    addl %d2,%d6
FMSWAPFONT_7F0:         /* loop */
    dbf %d0,FMSWAPFONT_7DA
FMSWAPFONT_7F4:         /* scaled by the size */
    asll #4,%d6
    subqw #6,%sp
    clrw %sp@-
    jbsr INITFONTS_12E
    movew %a0@(1068),%sp@-
    movel %d6,%sp@-
    _FixMul
    movel %sp@,%d6
    _FixRound
    movew %sp@+,%d0
    tstb FractEnable
    jbne FMSWAPFONT_820
    moveb %d0,FOutExtra
FMSWAPFONT_816:         /* the style extra as Fixed */
    moveq #0,%d6
    moveb FOutExtra,%d6
    extw %d6
    swap %d6
FMSWAPFONT_820:         /* fill the width table: header */
    jbsr INITFONTS_12E
    cmpiw #-1,%a0@(1036)
    jbne FMSWAPFONT_986
    lea %a0@(1028),%a1
    clrl %a1@+
    movel %d6,%a1@
    lea %a1@(20),%a1
    movew FONDID,%a1@+
    movel LastFOND,%a1@
    moveal FOutFontHandle,%a0
    jbsr FMSWAPFONT_12E
    movemw %a0@,%d2-%d4
    movew %d4,%d5
    subw %d3,%d5
    movew %d5,%d1
    addqw #3,%d5
    addw %d5,%d5
    extl %d5
    movew %a0@(10),%d0
    swap %d0
    jbpl FMSWAPFONT_864
    moveq #0,%d0
FMSWAPFONT_864:         /* widths from the width table of the FOND, the 'NFNT' or the strike's character widths */
    movew %a0@(16),%d0
    addl %d0,%d0
    lea %a0@(0x10,%d0:l),%a1
    moveq #0,%d7
    tstb FractEnable
    jbeq FMSWAPFONT_8A2
    btst #1,%d2
    jbne FMSWAPFONT_8AA
    btst #6,GotStrike
    jbne FMSWAPFONT_8A2
    movel %a4,%d0
    jbeq FMSWAPFONT_8A2
    moveal LastFOND,%a1
    moveal %a1@,%a1
    addal %a4,%a1
    jbsr INITFONTS_12E
    movew %a0@(1068),%d0
    movew %a1@(0xfffffffffffffffc,%d5:w),%d7
    mulsw %d0,%d7
    asll #4,%d7
    jbra FMSWAPFONT_8B2
FMSWAPFONT_8A2:         /* integer widths */
    moveb %a1@(0xfffffffffffffffd,%d5:w),%d7
    swap %d7
    jbra FMSWAPFONT_8B2
FMSWAPFONT_8AA:         /* fractional widths */
    addal %d5,%a1
    movew %a1@(0xfffffffffffffffc,%d5:w),%d7
    asll #8,%d7
FMSWAPFONT_8B2:         /* the missing-character width */
    cmpil #65536,FScaleHFact
    sne %d5
    andb FScaleDisable,%d5
    movel %d7,%d0
    jbsr FMSWAPFONT_940
    movel %d0,%d7
    jbsr INITFONTS_12E
    jbra FMSWAPFONT_8CE
FMSWAPFONT_8CC:         /* characters below firstChar */
    movel %d7,%a0@+
FMSWAPFONT_8CE:         /* loop; fractional widths? */
    dbf %d3,FMSWAPFONT_8CC
    clrb UsedFWidth
    tstb FractEnable
    jbeq FMSWAPFONT_95E
    btst #1,%d2
    jbeq FMSWAPFONT_904
FMSWAPFONT_8E4:         /* from the font's fractional width table */
    moveq #0,%d0
    movew %a1@+,%d3
    cmpiw #-1,%d3
    jbne FMSWAPFONT_8F2
    movel %d7,%d0
    jbra FMSWAPFONT_8F8
FMSWAPFONT_8F2:         /* scaled */
    movew %d3,%d0
    asll #8,%d0
    jbsr FMSWAPFONT_940
FMSWAPFONT_8F8:         /* store; next */
    movel %d0,%a0@+
    dbf %d1,FMSWAPFONT_8E4
    st UsedFWidth
    jbra FMSWAPFONT_978
FMSWAPFONT_904:         /* from the FOND's width table */
    btst #6,GotStrike
    jbne FMSWAPFONT_95E
    movel %a4,%d0
    jbeq FMSWAPFONT_95E
    moveal WidthTabHandle,%a4
    moveal %a4@,%a4
    movew %a4@(1068),%sp@-
    moveal %d0,%a4
FMSWAPFONT_91C:         /* per character */
    moveq #0,%d0
    movew %a1@+,%d3
    cmpiw #-1,%d3
    jbne FMSWAPFONT_92A
    movel %d7,%d0
    jbra FMSWAPFONT_932
FMSWAPFONT_92A:         /* times the size */
    movew %d3,%d0
    muluw %sp@,%d0
    asll #4,%d0
    jbsr FMSWAPFONT_940
FMSWAPFONT_932:         /* store; next */
    movel %d0,%a0@+
    dbf %d1,FMSWAPFONT_91C
    addqw #2,%sp
    st UsedFWidth
    jbra FMSWAPFONT_978

FMSWAPFONT_940:         /* add the style extra; scale horizontally if needed */
    tstl %d0
    jbeq FMSWAPFONT_95C
    addl %d6,%d0
    tstb %d5
    jbeq FMSWAPFONT_95C
    moveml %d1/%a0-%a1,%sp@-
    subqw #4,%sp
    movel %d0,%sp@-
    movel FScaleHFact,%sp@-
    _FixMul
    moveml %sp@+,%d0-%d1/%a0-%a1
FMSWAPFONT_95C:         /* return */
    rts
FMSWAPFONT_95E:         /* from the strike's width/offset table */
    moveq #0,%d0
    movew %a1@+,%d3
    cmpiw #-1,%d3
    jbne FMSWAPFONT_96C
    movel %d7,%d0
    jbra FMSWAPFONT_972
FMSWAPFONT_96C:         /* integer width */
    moveb %d3,%d0
    swap %d0
    jbsr FMSWAPFONT_940
FMSWAPFONT_972:         /* store; next */
    movel %d0,%a0@+
    dbf %d1,FMSWAPFONT_95E
FMSWAPFONT_978:         /* characters above lastChar */
    movew #255,%d0
    subw %d4,%d0
    jbra FMSWAPFONT_982
FMSWAPFONT_980:         /* missing width */
    movel %d7,%a0@+
FMSWAPFONT_982:         /* loop */
    dbf %d0,FMSWAPFONT_980
FMSWAPFONT_986:         /* remember the port's space extra, text mode, colors and depth (0xD36..0xD40) */
    jbsr INITFONTS_12E
    lea %a0@(1028),%a1
    movel %a1@,%d7
    tstb QDExist
    jbmi FMSWAPFONT_9C0
    moveal %a5@,%a0
    movel %a0@,%d0
    jbeq FMSWAPFONT_9C0
    moveal %d0,%a0
    movel %a0@(76),%d7
    movew %a0@(72),0xd3e
    lea %a0@(80),%a0
    lea 0xd36,%a2
    movel %a0@+,%a2@+
    movel %a0@,%a2@
    movel %a1,%sp@-
    jbsr FMSWAPFONT_37A
    moveal %sp@+,%a1
    movew %d0,0xd40
FMSWAPFONT_9C0:         /* changed: adjust the space width */
    movel %d7,LastSPExtra
    subl %a1@,%d7
    jbeq FMSWAPFONT_9F4
    addl %d7,%a1@
    subaw #12,%sp
    movew %a3@(10),%sp@-
    movew %a3@(14),%sp@-
    _FixRatio
    subqw #4,%sp
    movew FOutDenom_v,%sp@-
    movew FOutNumer_v,%sp@-
    _FixRatio
    _FixMul
    movel %d7,%sp@-
    _FixMul
    jbsr INITFONTS_12E
    movel %sp@+,%d0
    addl %d0,%a0@(128)
FMSWAPFONT_9F4:         /* a device with a driver: tell it (Control csCode 8) */
    moveq #-1,%d0
    moveb %a3@(6),%d0
    jbeq FMSWAPFONT_A16
    lea %fp@(-70),%a0
    movew %d0,%a0@(24)
    movew #8,%a0@(26)
    movel %a3,%a0@(28)
    movew %a3@(6),%a0@(32)
    _Control
FMSWAPFONT_A16:         /* remember the input as current */
    moveal %fp@(8),%a3
    moveal %a3,%a0
    lea CurFMFamily,%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    jbsr INITFONTS_12E
    cmpiw #-1,%a0@(1036)
    jbne FMSWAPFONT_A56
    moveb UsedFWidth,%a0@(1058)
    moveb FOutUnused,%a0@(1059)
    lea %a0@(1036),%a1
    jbsr INITFONTS_136
    movel %d0,%a1@+
    addqw #4,%a3
    movel %a3@+,%a1@+
    clrb %a1@(-3)
    movel %a3@+,%a1@+
    movel %a3@,%a1@
FMSWAPFONT_A56:         /* restore registers */
    moveml %sp@+,%d3-%d7/%a2-%a4
    movew %fp@(-72),%d0
    jbeq FMSWAPFONT_A64
    movew %d0,CurMap
FMSWAPFONT_A64:         /* return */
    unlk %fp
    jbra FMSWAPFONT_DC

FMSWAPFONT_A6A:         /* find the font: the size scaled for the device; the family's FOND */
    subal %a4,%a4
    movew %a3@(2),%d5
    movew %a3@,%d3
    subaw #14,%sp
    movew FMDotsPerInch_v,%sp@-
    movew #80,%sp@-
    _FixRatio
    subqw #4,%sp
    movew %a3@(10),%sp@-
    movew %a3@(14),%sp@-
    _FixRatio
    _FixMul
    clrw %sp@-
    movew %d5,%sp@-
    _FixMul
    _FixRound
    cmpw FONDID,%d3
    jbeq FMSWAPFONT_AD4
    moveal LastFOND,%a0
    moveb FondState,%d0
    _HSetState
    movew %d3,%d1
    movew #-1,ROMMapInsert
    jbsr GETFONTNAME_5C
    jbeq FMSWAPFONT_AC2
    moveal %a0@,%a1
    moveb %a1@,GotStrike
    _HGetState
    moveb %d0,FondState
    _HNoPurge
FMSWAPFONT_AC2:         /* the family's FOND */
    cmpib #0xff,FontFlag
    jbeq FMSWAPFONT_C3C
    movew %d3,FONDID
    movel %a0,LastFOND
FMSWAPFONT_AD4:         /* with a FOND: through its font association table */
    movel LastFOND,%d0
    jbne FMSWAPFONT_DB6
    cmpiw #512,%d3
    jbcs FMSWAPFONT_AF6
    jbra FMSWAPFONT_C3C

FMSWAPFONT_AE6:         /* try 'FONT' ID with size %d0 */
    andiw #-128,%d3
    orw %d0,%d3
    jbsr FMSWAPFONT_D4A
    jbvs FMSWAPFONT_C3A
    rts

FMSWAPFONT_AF6:         /* no FOND: old 'FONT' numbering (family * 128 + size) */
    movew %sp@+,%d0
    jbne FMSWAPFONT_AFC
    moveq #1,%d0
FMSWAPFONT_AFC:         /* the exact size; else twice or half the size, then the nearest */
    andiw #127,%d0
    aslw #7,%d3
    orw %d0,%d3
    movew %d0,%d7
    jbsr FMSWAPFONT_D4A
    jbvs FMSWAPFONT_C3E
    jbne FMSWAPFONT_B52
    movew %d3,%d4
    movew %d7,%d0
    cmpiw #64,%d0
    jbge FMSWAPFONT_B20
    addw %d0,%d0
    jbsr FMSWAPFONT_AE6
    jbne FMSWAPFONT_B52
FMSWAPFONT_B20:         /* double or half */
    movew %d7,%d0
    lsrw #1,%d0
    jbcs FMSWAPFONT_B2A
    jbsr FMSWAPFONT_AE6
    jbne FMSWAPFONT_B52
FMSWAPFONT_B2A:         /* nearest size: search up (or down with FScaleDisable) */
    movew %d4,%d3
    moveq #1,%d6
    tstb FScaleDisable
    jbeq FMSWAPFONT_B36
    moveq #-1,%d6
FMSWAPFONT_B36:         /* loop */
    addw %d6,%d3
    andiw #127,%d3
    jbeq FMSWAPFONT_C24
    movew %d4,%d0
    andiw #-128,%d0
    orw %d0,%d3
    jbsr FMSWAPFONT_D4A
    jbvs FMSWAPFONT_C3E
    jbeq FMSWAPFONT_B36
FMSWAPFONT_B52:         /* found: the font's height table; scale factors from size ratio and resolution */
    movel %a0,FOutFontHandle
    jbsr FONTMETRICS_8C
    subqw #4,%sp
    movew %a3@(2),%sp@-
    movew %d3,%sp@-
    andiw #127,%sp@
    _FixRatio
    movel %sp@+,%d6
    jbsr INITFONTS_12E
    movew %d3,%a0@(1068)
    movel FOutFontHandle,%a0@(1024)
    moveq #0,%d5
    jbsr FMSWAPFONT_B7E
    moveq #2,%d5

FMSWAPFONT_B7E:         /* per direction: size ratio times device ratio */
    subaw #12,%sp
    movew %a3@(0x8,%d5:w),%sp@-
    movew %a3@(0xc,%d5:w),%sp@-
    _FixRatio
    subqw #4,%sp
    lea FMDotsPerInch_h,%a0
    movew %a0@(0x0,%d5:w),%sp@-
    movew #80,%sp@-
    _FixRatio
    _FixMul
    movel %d6,%sp@-
    _FixMul
    lea FOutNumer_h,%a0
    movel %sp@+,%d0
    addil #128,%d0
    lsrl #8,%d0
    movew %d0,%a0@(0x0,%d5:w)
    movew #256,%a0@(0x4,%d5:w)
    movel %pc@(FPOINTONE),%d1
    tstb FScaleDisable
    jbeq FMSWAPFONT_C00
    moveq #0,%d1
    movew %d0,%d1
    movew #256,%d0
FMSWAPFONT_BCC:         /* reduce the fraction */
    cmpiw #512,%d1
    jbcs FMSWAPFONT_BD8
    aslw #1,%d0
    asrw #1,%d1
    jbra FMSWAPFONT_BCC
FMSWAPFONT_BD8:         /* keep the denominator in range */
    cmpiw #192,%d1
    jbcc FMSWAPFONT_BE4
    asrw #1,%d0
    aslw #1,%d1
    jbra FMSWAPFONT_BD8
FMSWAPFONT_BE4:         /* below 256: numerator * 3/4, factor * 4/3 */
    cmpiw #256,%d1
    jbcc FMSWAPFONT_BFA
    movew %d0,%d2
    addw %d0,%d0
    addw %d2,%d0
    asrw #2,%d0
    aslw #2,%d1
    divuw #3,%d1
    extl %d1
FMSWAPFONT_BFA:         /* store numerator and denominator */
    movew %d0,%a0@(0x0,%d5:w)
    asll #8,%d1
FMSWAPFONT_C00:         /* horizontal */
    tstw %d5
    jbeq FMSWAPFONT_C0A
    movel %d1,FScaleHFact
    jbra FMSWAPFONT_C0E
FMSWAPFONT_C0A:         /* vertical */
    movel %d1,FScaleVFact
FMSWAPFONT_C0E:         /* into the width table */
    moveal WidthTabHandle,%a1
    moveal %a1@,%a1
    lea %a1@(1060),%a1
    movew %d0,%a1@(0x0,%d5:w)
    asrl #8,%d1
    movew %d1,%a1@(0x4,%d5:w)
    rts
FMSWAPFONT_C24:         /* searched one way: try the other */
    tstb FScaleDisable
    jbeq FMSWAPFONT_C30
    negw %d6
    jbmi FMSWAPFONT_C3E
    jbra FMSWAPFONT_C34
FMSWAPFONT_C30:         /* other direction */
    negw %d6
    jbpl FMSWAPFONT_C3E
FMSWAPFONT_C34:         /* restart */
    movew %d4,%d3
    jbra FMSWAPFONT_B36
FMSWAPFONT_C3A:         /* drop */
    addqw #2,%sp
FMSWAPFONT_C3C:         /* drop */
    addqw #2,%sp
FMSWAPFONT_C3E:         /* not found: the next fallback (by FontFlag): app font, script's font, system font, system file */
    addqw #4,%sp
    movew %a3@,%d3
    moveq #0,%d0
    moveb FontFlag,%d0
    jbpl FMSWAPFONT_C54
    jbsr INITFONTS_11C
    clrb FontFlag
    jbra FMSWAPFONT_C60
FMSWAPFONT_C54:         /* next fallback */
    addqb #2,FontFlag
    movew %pc@(FMSWAPFONT_C70,%d0:w),%d0
    jsr %pc@(FMSWAPFONT_C70,%d0:w)
FMSWAPFONT_C60:         /* retry with it */
    moveal %fp@(8),%a1
    movew %d3,%a3@
    movew %a1@(2),%a3@(2)
    jbra FMSWAPFONT_1A4
FMSWAPFONT_C70:         /* fallbacks */
    .short  FMSWAPFONT_C7A-FMSWAPFONT_C70	| 40827184
    .short  FMSWAPFONT_CA0-FMSWAPFONT_C70	| 40827186
    .short  FMSWAPFONT_CB0-FMSWAPFONT_C70	| 40827188
    .short  FMSWAPFONT_CC8-FMSWAPFONT_C70	| 4082718A
    .short  FMSWAPFONT_CC8-FMSWAPFONT_C70	| 4082718C
FMSWAPFONT_C7A:         /* the application font if in the same script */
    movew ApFontID,%d1	| 4082718E
FMSWAPFONT_C7E:         /* script of the font */
    moveq #9,%d2	| 40827192
    lsrw %d2,%d1	| 40827194
    subiw #31,%d1	| 40827196
    jbpl FMSWAPFONT_C8A	| 4082719A
    moveq #0,%d1	| 4082719C
FMSWAPFONT_C8A:         /* script of the family */
    movew %d3,%d0	| 4082719E
    lsrw %d2,%d0	| 408271A0
    subiw #31,%d0	| 408271A2
    jbpl FMSWAPFONT_C96	| 408271A6
    moveq #0,%d0	| 408271A8
FMSWAPFONT_C96:         /* same: the application font */
    cmpw %d0,%d1	| 408271AA
    jbne FMSWAPFONT_C3E	| 408271AC
    movew ApFontID,%d3	| 408271AE
    rts	| 408271B2
FMSWAPFONT_CA0:         /* the script's base font number */
    cmpiw #16384,%d3	| 408271B4
    jbcs FMSWAPFONT_CAC	| 408271B8
    andiw #-512,%d3	| 408271BA
    rts	| 408271BE
FMSWAPFONT_CAC:         /* Geneva (3) */
    moveq #3,%d3	| 408271C0
    rts	| 408271C2
FMSWAPFONT_CB0:         /* the system font if in the same script */
    movew SysFontFam,%d1	| 408271C4
    jbra FMSWAPFONT_C7E	| 408271C8
FMSWAPFONT_CB6:         /* swap with the System file's resources only */
    linkw %fp,#-138
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveal %fp@(8),%a3
    jbsr FMSWAPFONT_CC8
    jbra FMSWAPFONT_180

FMSWAPFONT_CC8:         /* search the System file */
    movew CurMap,%fp@(-72)
    movew SysMap,CurMap
    moveq #0,%d3
    rts

FMSWAPFONT_CD8:         /* the device's resolution from its driver (Status csCode 8) */
    tstw %d0
    jbeq FMSWAPFONT_D02
    moveq #-1,%d0
    moveb %a3@(6),%d0
    moveq #50,%d1
    subal %d1,%sp
    lea %sp@(24),%a0
    movew %d0,%a0@+
    movew #8,%a0@+
    lea FMDotsPerInch_h,%a1
    movel %a1,%a0@+
    movew %a3@(6),%a0@+
    moveal %sp,%a0
    _Status
    addal %d1,%sp
    rts

FMSWAPFONT_D02:         /* default resolution and style table */
    lea FMDotsPerInch_h,%a1
    lea %pc@(FPOINTONE_4),%a0
    moveq #28,%d0
    _BlockMove
    rts
FMSWAPFONT_D10:         /* from a FOND entry: its font ID */
    movel %a0@,%d0
    movel %d0,%fp@(-20)

FMSWAPFONT_D16:         /* also in ROM */
    movew #-1,ROMMapInsert
FMSWAPFONT_D1C:         /* 'NFNT' ID %d0, else 'FONT' */
    movew %d0,%sp@-
    subqw #4,%sp
    movel #1313230420,%sp@-
    movew %d0,%sp@-
    _GetResource
    movel %sp@+,%d0
    jbeq FMSWAPFONT_D4C
    jbsr INITFONTS_12E
    movew #-32768,%a0@(1070)
    movew %sp@+,%a0@(1072)
    tstl %d0
    jbra FMSWAPFONT_D84

FMSWAPFONT_D40:         /* 'FONT' only, from the ROM too */
    movew #-256,ROMMapInsert
    movew %d1,%sp@-
    jbra FMSWAPFONT_D5E

FMSWAPFONT_D4A:         /* 'FONT' ID %d3 */
    movew %d3,%sp@-
FMSWAPFONT_D4C:         /* remember the ID */
    movew #-1,ROMMapInsert
    moveq #0,%d0
    movew %sp@,%d0
    jbsr INITFONTS_12E
    movel %d0,%a0@(1070)
FMSWAPFONT_D5E:         /* GetResource 'FONT'; one shorter than 36 bytes counts as missing */
    movew %sp@+,%d0
    subqw #4,%sp
    movel #1179602516,%sp@-
    movew %d0,%sp@-
    _GetResource
    movel %sp@+,%d0
    jbeq FMSWAPFONT_D84
    movel %d0,%sp@-
    subqw #4,%sp
    movel %d0,%sp@-
    _MaxSizeRsrc
    cmpil #36,%sp@+
    scs %d0
    moveal %sp@+,%a0
    jbra FMSWAPFONT_D88
FMSWAPFONT_D84:         /* Z: not found */
    moveal %d0,%a0
    seq %d0
FMSWAPFONT_D88:         /* V: give up (fallback exhausted) */
    andiw #4,%d0
    cmpib #0xff,FontFlag
    jbne FMSWAPFONT_D98
    bset #1,%d0
FMSWAPFONT_D98:         /* condition codes */
    movew %d0,%ccr
    rts

FMSWAPFONT_D9C:         /* the FOND's font association table: entry for size %d3 */
    moveal %a2@,%a0
    lea %a0@(52),%a0
    movew %a0@+,%d1
FMSWAPFONT_DA4:         /* loop (sorted by size) */
    cmpw %a0@+,%d3
    jbeq FMSWAPFONT_D10
    jblt FMSWAPFONT_DB2
    addqw #4,%a0
    dbf %d1,FMSWAPFONT_DA4
FMSWAPFONT_DB2:         /* not found */
    moveq #0,%d0
    rts
FMSWAPFONT_DB6:         /* with a FOND: the exact size, else twice or half, else the nearest */
    movew %sp@+,%d5
    moveal %d0,%a2
    movew %d5,%d3
    jbsr FMSWAPFONT_D9C
    jbvs FMSWAPFONT_E26
    jbne FMSWAPFONT_DDA
    tstb FScaleDisable
    jbne FMSWAPFONT_DDC
    addw %d3,%d3
    jbsr FMSWAPFONT_D9C
    jbvs FMSWAPFONT_E26
    jbne FMSWAPFONT_DDA
    movew %d5,%d3
    lsrw #1,%d3
    jbcs FMSWAPFONT_DDC
    jbsr FMSWAPFONT_D9C
    jbvs FMSWAPFONT_E26
FMSWAPFONT_DDA:         /* found */
    jbne FMSWAPFONT_E12
FMSWAPFONT_DDC:         /* the nearest size */
    moveal %a2@,%a0
    lea %a0@(52),%a0
    movew %a0@+,%d4
    moveq #0,%d1
    movew #32767,%d2
FMSWAPFONT_DEA:         /* per entry: the distance */
    movew %d5,%d0
    subw %a0@,%d0
    jbpl FMSWAPFONT_DFC
    tstb FScaleDisable
    jbeq FMSWAPFONT_DFA
    tstw %d1
    jbne FMSWAPFONT_E0A
FMSWAPFONT_DFA:         /* absolute */
    negw %d0
FMSWAPFONT_DFC:         /* closer: remember */
    cmpw %d2,%d0
    jbgt FMSWAPFONT_E04
    movew %d0,%d2
    movew %a0@,%d1
FMSWAPFONT_E04:         /* next */
    addqw #6,%a0
    dbf %d4,FMSWAPFONT_DEA
FMSWAPFONT_E0A:         /* load it */
    movew %d1,%d3
    jbsr FMSWAPFONT_D9C
    jbvs FMSWAPFONT_E26
    jbeq FMSWAPFONT_E26
FMSWAPFONT_E12:         /* the entries of that size: the best style match */
    movel %a0,%d0
    moveal %a2@,%a0
    lea %a0@(52),%a0
    movew %a0@+,%d1
FMSWAPFONT_E1C:         /* find the first one of the size */
    cmpw %a0@,%d3
    jbeq FMSWAPFONT_E36
    addqw #6,%a0
    dbf %d1,FMSWAPFONT_E1C
FMSWAPFONT_E26:         /* nothing: old numbering */
    movew %d5,%sp@-
    movew %a3@,%d3
    jbra FMSWAPFONT_AF6
FMSWAPFONT_E2E:         /* per-bit weights for the best face match */
    .short  0x0408, 0x0103, 0x0302, 0x0100	| 40827342
FMSWAPFONT_E36:         /* per style of the size: exact face? */
    moveq #0,%d2
    addqw #2,%a0
    moveq #-2,%d4
    moveb %a3@(4),%d2
FMSWAPFONT_E40:         /* exact */
    movew %a0@,%d6
    cmpw %d6,%d2
    jbne FMSWAPFONT_E4A
    moveal %a0,%a1
    jbra FMSWAPFONT_E76
FMSWAPFONT_E4A:         /* else score the face bits it has (no extra bits) */
    moveq #-1,%d5
    movew %d2,%d7
    notw %d7
    andw %d6,%d7
    jbne FMSWAPFONT_E66
    moveq #0,%d5
    moveq #7,%d7
    andw %d2,%d6
FMSWAPFONT_E5A:         /* per bit: its weight */
    aslb #1,%d6
    jbcc FMSWAPFONT_E62
    addb %pc@(FMSWAPFONT_E2E,%d7:w),%d5
FMSWAPFONT_E62:         /* loop */
    dbf %d7,FMSWAPFONT_E5A
FMSWAPFONT_E66:         /* best so far */
    cmpw %d5,%d4
    jbge FMSWAPFONT_E6E
    movew %d5,%d4
    moveal %a0,%a1
FMSWAPFONT_E6E:         /* next entry of the size */
    addqw #4,%a0
    cmpw %a0@+,%d3
    dbne %d1,FMSWAPFONT_E40
FMSWAPFONT_E76:         /* load the chosen strike */
    movew %a1@+,%d6
    movew %fp@(-18),%d1
    cmpw %a1@,%d1
    moveal %d0,%a0
    jbeq FMSWAPFONT_E94
    movel %a0,%d4
    movew %a1@,%d0
    jbsr FMSWAPFONT_D16
    jbvs FMSWAPFONT_E26
    jbne FMSWAPFONT_E94
    moveal %d4,%a0
    movew %fp@(-20),%d6
FMSWAPFONT_E94:         /* the face bits it has need not be synthesized; style mapping table */
    notw %d6
    andb %d6,FOutUnused
    moveal %a2@,%a1
    movew %a1@(6),%d1
    jbeq FMSWAPFONT_F0A
    subw %a1@(4),%d1
    addqw #4,%d1
    addw %d1,%d1
    movel %a1@(16),%d0
    jbeq FMSWAPFONT_F0A
    addal %d0,%a1
    movew %a1@+,%d2
    jbmi FMSWAPFONT_F0A
    moveq #-1,%d4
    tstb FractEnable
    jbne FMSWAPFONT_EC4
    notw %d6
    movew %d6,%sp@-
    jbra FMSWAPFONT_ECC
FMSWAPFONT_EC4:         /* the face asked for */
    moveq #0,%d0
    moveb %a3@(4),%d0
    movew %d0,%sp@-
FMSWAPFONT_ECC:         /* per entry: best match */
    movew %sp@,%d0
    cmpw %a1@,%d0
    jbeq FMSWAPFONT_F00
    notw %d0
    andw %a1@,%d0
    jbne FMSWAPFONT_EF4
    moveq #0,%d5
    movew %sp@,%d0
    andw %a1@,%d0
    moveq #7,%d7
FMSWAPFONT_EE0:         /* per bit: its weight */
    aslb #1,%d0
    jbcc FMSWAPFONT_EE8
    addb %pc@(FMSWAPFONT_F0E,%d7:w),%d5
FMSWAPFONT_EE8:         /* loop; best so far */
    dbf %d7,FMSWAPFONT_EE0
    cmpw %d5,%d4
    jbge FMSWAPFONT_EF4
    movew %d5,%d4
    movel %a1,%d6
FMSWAPFONT_EF4:         /* next entry */
    addaw %d1,%a1
    dbf %d2,FMSWAPFONT_ECC
    tstw %d4
    jbmi FMSWAPFONT_F08
    moveal %d6,%a1
FMSWAPFONT_F00:         /* the chosen style table entry */
    movew %a1@+,%fp@(-74)
    subal %a2@,%a1
    moveal %a1,%a4
FMSWAPFONT_F08:         /* drop the face */
    addqw #2,%sp
FMSWAPFONT_F0A:         /* use the font */
    jbra FMSWAPFONT_B52
FMSWAPFONT_F0E:         /* per-bit weights for the best style mapping match */
    .short  0x0103, 0x0504, 0x0402, 0x0200	| 40827422

/* FPOINTONE: Fixed 1.0 constant / helper. */
FPOINTONE:
    .short  0x0001, 0x0000	| 4082742A
FPOINTONE_4:            /* default values copied to FMDotsPerInch (28 bytes): 80 by 80 dpi, the style table */
    .short  0x0050	| 4082742E
    .long   0x00500001, 0x01010800, 0x00000005, 0x01010502	| 40827430
    .long   0x020000FF, 0x00000101, 0x01010077, 0x7A3BC935	| 40827440
    .long   0x301980AF, 0x30187A60, 0x18090060, 0x31980972	| 40827450
    .long   0x7BBA49BF, 0xE09D0102, 0x20BF4088, 0x01F1FE02	| 40827460
    .long   0x0A81BC04, 0x07039A08, 0x040F8099, 0x1FC03760	| 40827470
    .long   0xB90F0403, 0xDF0F9808, 0x37601FC1, 0xA8040F80	| 40827480
    .long   0x02029A01, 0x04870818	| 40827490

/* GETFONTNAME: _GetFontName. */
trap_GetFName:
GETFONTNAME:
    moveal %sp@+,%a1
    movel %sp@+,%d2
    movew %sp@+,%d1
    movew #-256,ROMMapInsert
    jbsr GETFONTNAME_48
    jbne GETFONTNAME_30
    cmpiw #512,%d1
    jbcc GETFONTNAME_42
    aslw #7,%d1
    movew #-256,ROMMapInsert
    subqw #4,%sp
    movel #1179602516,%sp@-
    movew %d1,%sp@-
    _GetResource
    movel %sp@+,%d0
    moveal %d0,%a0
    jbeq GETFONTNAME_42
GETFONTNAME_30:         /* the FOND's name */
    movel %a0,%sp@-
    clrl %sp@-
    clrl %sp@-
    movel %d2,%sp@-
    movew #-256,ROMMapInsert
    _GetResInfo
    jbra GETFONTNAME_46
GETFONTNAME_42:         /* none: empty string */
    moveal %d2,%a0
    clrb %a0@
GETFONTNAME_46:         /* return */
    jmp %a1@

GETFONTNAME_48:         /* the FOND of family %d1 (0 = system, 1 = application font) */
    tstw %d1
    jbne GETFONTNAME_52
    movew SysFontFam,%d1
    jbra GETFONTNAME_5C
GETFONTNAME_52:         /* application font */
    cmpiw #1,%d1
    jbne GETFONTNAME_5C
    movew ApFontID,%d1

GETFONTNAME_5C:         /* GetResource 'FOND' */
    subqw #4,%sp
    movel #1179602500,%sp@-
    movew %d1,%sp@-
    _GetResource
    movel %sp@+,%d0
    moveal %d0,%a0
    rts

/* REALFONT: _RealFont: is that size available without scaling?. */
trap_RealFont:
REALFONT:
    moveal %sp@+,%a1
    movew %sp@+,%d2
    jbne REALFONT_1A
    tstw %sp@
    jbne REALFONT_10
    movew SysFontSize,%d2
    jbne REALFONT_1A
REALFONT_10:            /* size 0: FMDefaultSize, else 12 */
    moveq #0,%d2
    moveb FMDefaultSize,%d2
    jbne REALFONT_1A
    moveq #12,%d2
REALFONT_1A:            /* with a FOND: is the size in its association table? */
    movew %sp@+,%d1
    clrw %sp@
    movew #-1,ROMMapInsert
    jbsr GETFONTNAME_48
    jbeq REALFONT_40
    moveal %a0@,%a0
    lea %a0@(52),%a0
    movew %a0@+,%d0
    jbmi REALFONT_56
REALFONT_32:            /* loop */
    cmpw %a0@,%d2
    jbeq REALFONT_54
    jblt REALFONT_56
    addqw #6,%a0
    dbf %d0,REALFONT_32
    jbra REALFONT_56
REALFONT_40:            /* no FOND: the 'FONT' (family * 128 + size) */
    cmpiw #512,%d1
    jbcc REALFONT_56
    aslw #7,%d1
    andiw #127,%d2
    orw %d2,%d1
    jbsr FMSWAPFONT_D40
    jbeq REALFONT_56
REALFONT_54:            /* true */
    addqb #1,%sp@
REALFONT_56:            /* return */
    jmp %a1@

REALFONT_58:            /* GetNamedResource type %d0, name %d1 */
    subqw #4,%sp
    movel %d0,%sp@-
    movel %d1,%sp@-
    movew #-256,ROMMapInsert
    _GetNamedResource
    movel %sp@+,%d0
    rts

/* GETFNUM: _GetFNum: the font number of a name. */
trap_GetFNum:
GETFNUM:
    movel %sp@(8),%d1
    movel %sp@+,%sp@(4)
    moveal %sp@+,%a1
    movel #1179602500,%d0
    jbsr REALFONT_58
    jbne GETFNUM_22
    movel #1179602516,%d0
    jbsr REALFONT_58
    jbne GETFNUM_26
    clrw %a1@
    jbra GETFNUM_42
GETFNUM_22:             /* a FOND */
    st %d1
    jbra GETFNUM_28
GETFNUM_26:             /* a FONT */
    sf %d1
GETFNUM_28:             /* its ID; a 'FONT' ID is family * 128 */
    movel %d0,%sp@-
    movel %a1,%sp@-
    clrl %sp@-
    clrl %sp@-
    movew #-256,ROMMapInsert
    _GetResInfo
    tstb %d1
    jbne GETFNUM_42
    movew %a1@,%d0
    lsrw #7,%d0
    movew %d0,%a1@
GETFNUM_42:             /* return */
    rts

/* SETFONTLOCK: _SetFontLock. */
trap_SetFontLock:
SETFONTLOCK:
    moveal FOutFontHandle,%a0
    moveal %sp@+,%a1
    tstb %sp@+
    jbeq SETFONTLOCK_1E
    movel %a0,%sp@-
    movew #-1,ROMMapInsert
    _LoadResource
    _HNoPurge
    bclr #6,FondState
    jbra SETFONTLOCK_26
SETFONTLOCK_1E:         /* _HPurge */
    _HPurge
    bset #6,FondState
SETFONTLOCK_26:         /* return */
    jmp %a1@

/* SETFSCALEDISABLE: _SetFScaleDisable. */
trap_SetFScaleDisable:
SETFSCALEDISABLE:
    moveal %sp@+,%a0
    moveb %sp@+,FScaleDisable
SETFSCALEDISABLE_6:     /* invalidate the width table cache; return */
    movel MinusOne,LastSPExtra
    jmp %a0@

/* SETFRACTENABLE: _SetFractEnable. */
trap_SetFractEnable:
SETFRACTENABLE:
    moveal %sp@+,%a0
    moveb %sp@+,FractEnable
    jbra SETFSCALEDISABLE_6

/* FONTMETRICS: _FontMetrics: ascent, descent, leading, widMax as Fixed. */
trap_FontMetrics:
FONTMETRICS:
    subqw #2,%sp
    movew #32,%sp@-
    _CharWidth
    addqw #2,%sp
    movel %a2,%sp@-
    moveal %sp@(8),%a2
    moveal FOutFontHandle,%a1
    moveal %a1@,%a1
    lea %a1@(18),%a0
    pea %a1@(6)
    jbsr FONTMETRICS_58
    jbsr FONTMETRICS_58
    jbsr FONTMETRICS_58
    moveal %sp@+,%a0
    movel FScaleHFact,%d1
    lea FOutNumer_v,%a1
    jbsr FONTMETRICS_60
    moveal WidthTabHandle,%a0
    movel %a0,%a2@
    moveal %sp@(8),%a2
    moveq #0,%d0
    moveb FOutShadow,%d0
    jbeq FONTMETRICS_48
    addqw #1,%a2@
    addw %d0,%a2@(4)
FONTMETRICS_48:         /* widMax from the width table; return */
    moveal %a0@,%a0
    movel %a0@(1032),%d0
    addl %d0,%a2@(12)
    moveal %sp@+,%a2
    movel %sp@+,%sp@
    rts

FONTMETRICS_58:         /* scale a metric by the vertical factor */
    movel FScaleVFact,%d1
    lea FOutNumer_h,%a1

FONTMETRICS_60:         /* factor 1.0 unless FScaleDisable */
    movew %a0@+,%d0
    movel %a0,%sp@-
    tstb FScaleDisable
    jbne FONTMETRICS_6E
    movel %pc@(FPOINTONE),%d1
FONTMETRICS_6E:         /* the metric times the scale, as Fixed */
    subqw #4,%sp
    movel %d1,%sp@-
    subqw #4,%sp
    clrw %sp@-
    movew %d0,%sp@-
    subqw #4,%sp
    movew %a1@,%sp@-
    movew %a1@(4),%sp@-
    _FixRatio
    _FixMul
    _FixMul
    movel %sp@+,%a2@+
    moveal %sp@+,%a0
    rts

FONTMETRICS_8C:         /* build a font's height table (first and last nonblank row per character) if it has none */
    linkw %fp,#-4
    moveml %d3-%d7/%a2-%a5,%sp@-
    moveal %a0,%a3
    _GetMaskTable
    moveal %a0,%a5
    moveal %a3@,%a1
    movew %a1@+,%d0
    lsrw #1,%d0
    jbcs FONTMETRICS_EA
    movew %a1@+,%d0
    moveq #0,%d5
    movew %a1@,%d5
    subw %d0,%d5
    addqw #3,%d5
    addw %d5,%d5
    moveal %a3@,%a1
    movew %a1@,%d0
    asrw #2,%d0
    andiw #7,%d0
    movew %d0,%fp@(-4)
    movew %a1@(10),%d0
    swap %d0
    jbpl FONTMETRICS_C6
    moveq #0,%d0
FONTMETRICS_C6:         /* room for it after the font */
    movew %a1@(16),%d0
    addql #8,%d0
    addl %d0,%d0
    movel %d0,%d1
    subl %d5,%d1
    addl %d5,%d0
    movel %d0,%d2
    addl %d5,%d0
    btst #1,%a1@(1)
    jbeq FONTMETRICS_E4
    addl %d5,%d0
    addl %d5,%d2
FONTMETRICS_E4:         /* grow the font */
    moveal %a3,%a0
    _SetHandleSize
    jbeq FONTMETRICS_F2
FONTMETRICS_EA:         /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a5
    unlk %fp
    rts
FONTMETRICS_F2:         /* mark it as having a height table */
    moveal %a3@,%a2
    oriw #1,%a2@
    movew %a2@(14),%d3
    addal %d1,%a2
    moveal %a3@,%a4
    addal %d2,%a4
    subqw #2,%d5
FONTMETRICS_104:        /* per character: its columns in the strike */
    movew #-256,%a4@
    movew %a2@+,%d7
    movew %a2@,%d6
    subw %d7,%d6
    jbeq FONTMETRICS_19C
    movew %fp@(-4),%d0
    lslw %d0,%d7
    lslw %d0,%d6
FONTMETRICS_11A:        /* per 16-bit column group: the mask of the character's columns */
    movew %d7,%d2
    movew %d7,%d0
    lsrw #4,%d0
    addw %d0,%d0
    moveal %a3@,%a1
    lea %a1@(26),%a1
    addaw %d0,%a1
    andiw #15,%d2
    movew %d2,%d1
    addw %d1,%d1
    moveq #0,%d0
    movew %a5@(0x20,%d1:w),%d0
    swap %d0
    moveq #16,%d4
    movew %d4,%d1
    subw %d2,%d1
    addw %d1,%d7
    subw %d1,%d6
    jbeq FONTMETRICS_16A
    jbpl FONTMETRICS_156
    movew %d6,%d1
    addw %d4,%d1
    addw %d1,%d1
    movel %a5@(0x0,%d1:w),%d2
    andl %d2,%d0
    jbra FONTMETRICS_16A
FONTMETRICS_156:        /* last group */
    movew %d6,%d1
    cmpw %d4,%d1
    jble FONTMETRICS_15E
    movew %d4,%d1
FONTMETRICS_15E:        /* the mask */
    addw %d1,%d1
    movew %a5@(0x0,%d1:w),%d2
    orw %d2,%d0
    subw %d4,%d6
    addw %d4,%d7
FONTMETRICS_16A:        /* scan rows from the top */
    movel %a1,%sp@-
    movew %d3,%d1
    subqw #1,%d1
    moveal %a3@,%a0
    movew %a0@(24),%d4
    movew %fp@(-4),%d2
    lslw %d2,%d4
    addw %d4,%d4
    moveaw %d4,%a0
    jbra FONTMETRICS_188
    .short  0x3068, 0x0018, 0xD0C8	| 40827774
FONTMETRICS_188:        /* row 0 */
    moveq #0,%d4
FONTMETRICS_18A:        /* loop: first row with a set bit */
    movel %a1@,%d2
    andl %d0,%d2
    jbne FONTMETRICS_1A0
    addqw #1,%d4
    addaw %a0,%a1
    dbf %d1,FONTMETRICS_18A
    addql #4,%sp
    moveq #0,%d6
FONTMETRICS_19C:        /* blank character */
    clrw %a4@+
    jbra FONTMETRICS_1D2
FONTMETRICS_1A0:        /* highest so far */
    cmpb %a4@,%d4
    jbcc FONTMETRICS_1A6
    moveb %d4,%a4@
FONTMETRICS_1A6:        /* scan rows from the bottom */
    moveal %sp@+,%a1
    movew %d3,%d2
    subqw #1,%d2
    movew %a0,%d4
    muluw %d4,%d2
    addal %d2,%a1
    movew %d3,%d4
    movew %d3,%d1
    subqw #1,%d1
FONTMETRICS_1B8:        /* loop: last row with a set bit */
    movel %a1@,%d2
    andl %d0,%d2
    jbne FONTMETRICS_1C8
    subqw #1,%d4
    subaw %a0,%a1
    dbf %d1,FONTMETRICS_1B8
    jbra FONTMETRICS_19C
FONTMETRICS_1C8:        /* lowest so far */
    addql #1,%a4
    cmpb %a4@+,%d4
    jbcs FONTMETRICS_1D2
    moveb %d4,%a4@(-1)
FONTMETRICS_1D2:        /* next column group; store first row and row count */
    subql #2,%a4
    tstw %d6
    jbgt FONTMETRICS_11A
    moveb %a4@+,%d0
    subb %d0,%a4@+
    subqw #2,%d5
    jbgt FONTMETRICS_104
    jbra FONTMETRICS_EA

/* FMGREND: end of the Font Manager. */
FMGREND:
    .short  0x0000, 0x0000, 0x0000	| 408277DA
