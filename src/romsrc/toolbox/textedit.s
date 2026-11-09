/*
 toolbox/textedit.s - TextEdit
 From TEXTEDIT (0x40821EE0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the TextEdit chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what that part does.
*/

/* TEXTEDIT: TextEdit. */
TEXTEDIT:
    .short  TEPASTE_5C-TEXTEDIT	| 40821EE0
    .short  ITESETSTYLE-TEXTEDIT	| 40821EE2
    .short  ITESETSTYLE_410-TEXTEDIT	| 40821EE4
    .short  ITESETSTYLE_25C-TEXTEDIT	| 40821EE6
    .short  trap_TEGetOffset_1A-TEXTEDIT	| 40821EE8
    .short  TEGETOFFSET_2C-TEXTEDIT	| 40821EEA
    .short  TEGETOFFSET_C4-TEXTEDIT	| 40821EEC
    .short  TEGETOFFSET_1D2-TEXTEDIT	| 40821EEE
    .short  TEGETOFFSET_42-TEXTEDIT	| 40821EF0
    .short  TEGETOFFSET_252-TEXTEDIT	| 40821EF2
    .short  TEGETOFFSET_2D8-TEXTEDIT	| 40821EF4
    .short  TEGETOFFSET_112-TEXTEDIT	| 40821EF6
    .short  TEGETOFFSET_28C-TEXTEDIT	| 40821EF8
    .short  TEGETOFFSET_2A6-TEXTEDIT	| 40821EFA
    .short  ITEFEATUREFLAG-TEXTEDIT	| 40821EFC
TEXTEDIT_1E:            /* (ExpandMem offset, routine offset) pairs for the vectored routines; 0 ends */
    .short  0x0090, XDOERASE-TEXTEDIT_1E	| 40821EFE
    .short  0x0094, XCARETDISPLAY-TEXTEDIT_1E	| 40821F02
    .short  0x0098, XCARETDISPLAY_12E-TEXTEDIT_1E	| 40821F06
    .short  0x009C, XGETRLPOSITION-TEXTEDIT_1E	| 40821F0A
    .short  0x00A0, XGETRLPOSITION_118-TEXTEDIT_1E	| 40821F0E
    .short  0x00A4, XGETRLPOSITION_1EC-TEXTEDIT_1E	| 40821F12
    .short  0x00A8, XGETRLPOSITION_2B0-TEXTEDIT_1E	| 40821F16
    .short  0x00AC, XGETRLPOSITION_2E6-TEXTEDIT_1E	| 40821F1A
    .short  0x00B0, XGETRLPOSITION_360-TEXTEDIT_1E	| 40821F1E
    .short  0x00B4, XTEGETFORMATORDER-TEXTEDIT_1E	| 40821F22
    .short  0x00B8, XGETWIDTH-TEXTEDIT_1E	| 40821F26
    .short  0x00BC, TEDELETE_168-TEXTEDIT_1E	| 40821F2A
    .short  0x00C0, XONSAMELINE-TEXTEDIT_1E	| 40821F2E
    .short  0x00C4, XONSAMELINE_182-TEXTEDIT_1E	| 40821F32
    .short  0x00C8, XONSAMELINE_24C-TEXTEDIT_1E	| 40821F36
    .short  0x00CC, XONSAMELINE_2E0-TEXTEDIT_1E	| 40821F3A
    .short  0x00D0, XONSAMELINE_39A-TEXTEDIT_1E	| 40821F3E
    .short  0x00D4, XONSAMELINE_406-TEXTEDIT_1E	| 40821F42
    .short  0x00D8, XTEBUFFERTEXT-TEXTEDIT_1E	| 40821F46
    .short  0x00DC, XDUMPBUFFER-TEXTEDIT_1E	| 40821F4A
    .short  0x00E0, XCURSORMOVEMENT-TEXTEDIT_1E	| 40821F4E
    .short  0x00E4, XCURSORMOVEMENT_200-TEXTEDIT_1E	| 40821F52
    .short  0x00E8, XCURSORMOVEMENT_26A-TEXTEDIT_1E	| 40821F56
    .short  0x00EC, XSETFONT2KEYBOARD-TEXTEDIT_1E	| 40821F5A
    .short  0x00F0, XSETKEYBOARD2FONT-TEXTEDIT_1E	| 40821F5E
    .short  0x00F4, ITESETSTYLE_9A-TEXTEDIT_1E	| 40821F62
    .short  0x00F8, ITESETSTYLE_368-TEXTEDIT_1E	| 40821F66
    .byte   0x00, 0x00, 0x00, 0x00	| 40821F6A

/* TEGLOBALINIT: TextEdit globals at start-up. */
TEGLOBALINIT:
    moveml %a2-%a3,%sp@-
    lea %pc@(TEXTEDIT_1E),%a0
    moveal %a0,%a1
    moveal ExpandMem,%a2
TEGLOBALINIT_E:         /* (ExpandMem offset, routine) pairs: install the TextEdit vectors in ExpandMem; 0 ends */
    movel %a1@+,%d0
    jbeq TEGLOBALINIT_1E
    lea %a0@(0x0,%d0:w),%a3
    swap %d0
    movel %a3,%a2@(0x0,%d0:w)
    jbra TEGLOBALINIT_E
TEGLOBALINIT_1E:        /* restore registers, return */
    moveml %sp@+,%a2-%a3
    rts

/* TEINIT: _TEInit. */
trap_TEInit:
TEINIT:
    moveq #0,%d0
    movew %d0,TEScrpLength
    .short  0xA122	| 40821F98 _NewHandle (flags 0x0100)
    movel %a0,TEScrpHandle
    lea %pc@(DOTEXT_6),%a0
    movel %a0,TEDoText
    lea %pc@(XRECALLINES),%a0
    movel %a0,TERecal
    lea %pc@(XFINDWORD_17A),%a0
    movel %a0,TEWdBreak
    moveal IntlSpec,%a0
    tstb %a0@(4)
    jbeq TEINIT_A2
TEINIT_2E:              /* TESysJust from the system script's direction; WordRedraw from the scripts */
    movew %a0@(38),%d0
    lslw #2,%d0
    moveal %a0@(0x72,%d0:w),%a0
    moveb %a0@(6),%d0
    extw %d0
    movew %d0,TESysJust
    moveal ExpandMem,%a0
    lea %a0@(70),%a0
    moveb #0xff,%a0@
    movew #1,%a0@(6)
    clrb WordRedraw
    moveq #0,%d1
TEINIT_5A:              /* per installed script: OR its redraw flag into WordRedraw (GetScript smScriptRedraw) */
    clrl %sp@-
    movew %d1,%sp@-
    movew #10,%sp@-
    movel #-2080112628,%sp@-
    _ScriptUtil
    movel %sp@+,%d0
    orb %d0,WordRedraw
    jbmi TEINIT_7A
    addqw #4,%d1
    cmpiw #128,%d1
    jbls TEINIT_5A
TEINIT_7A:              /* the number of enabled scripts (GetEnvirons smEnabled) into ExpandMem +44; the default word-break address into +64 */
    clrl %sp@-
    movew #4,%sp@-
    movel #-2080243704,%sp@-
    _ScriptUtil
    movel %sp@+,%d0
    moveal ExpandMem,%a0
    moveb %d0,%a0@(44)
    lea %pc@(XFINDWORD_17A),%a1
    movel %a1,%d0
    _StripAddress
    moveal ExpandMem,%a0
    movel %d0,%a0@(64)
TEINIT_A2:              /* return */
    rts
    .short  0xA9C9	| 40822036

/* TEGETTEXT: _TEGetText. */
trap_TEGetText:
TEGETTEXT:
    jbsr DOMEASURE_186
    movel %a3@(62),%a2@	| 4082203C
    jbra TECALTEXT_6	| 40822040

/* TEDISPOSE: _TEDispose. */
trap_TEDispose:
TEDISPOSE:
    linkw %fp,#0
    moveml %d2-%d7/%a2-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %a4@,%a3
    moveal %a3@(62),%a0
    _DisposHandle
    moveal %a3@(66),%a0
    _DisposHandle
    tstw %a3@(80)
    jbpl TEDISPOSE_3A
    moveal %a3@(74),%a2
    moveal %a2@,%a2
    moveal %a2@(4),%a0
    _DisposHandle
    moveal %a2@(8),%a0
    _DisposHandle
    jbsr TEDISPOSE_44
    moveal %a3@(74),%a0
    _DisposHandle
TEDISPOSE_3A:           /* dispose of the record itself */
    moveal %a4,%a0
    _DisposHandle
    moveq #4,%d0
    jbra TECALTEXT_58
TEDISPOSE_44:           /* styled: dispose of the null-style record and its scrap */
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(16),%a0
    movel %a0,%sp@-
    moveal %a0@,%a0
    moveal %a0@(4),%a0
    _DisposHandle
    moveal %sp@+,%a0
    _DisposHandle
    rts

/* TEXTBOX: _TextBox: draw text in a rectangle with a justification. */
trap_TextBox:
TEXTBOX:
    linkw %fp,#0
    moveml %d2-%d7/%a2-%a4,%sp@-
    tstw %fp@(8)
    jbne TEXTBOX_14
    movew TESysJust,%fp@(8)
TEXTBOX_14:             /* just -2 (teForceLeft): left */
    cmpiw #-2,%fp@(8)
    jbne TEXTBOX_20
    clrw %fp@(8)
TEXTBOX_20:             /* no return in the text: draw it as one line with _DrawText */
    moveal %fp@(18),%a0
    movel %fp@(14),%d0
    jblt TEXTBOX_A4
    jbeq TEXTBOX_36
TEXTBOX_2C:             /* loop: look for a return */
    cmpib #13,%a0@+
    jbeq TEXTBOX_A6
    subql #1,%d0
    jbne TEXTBOX_2C
TEXTBOX_36:             /* one line: its width, and where it starts for the justification */
    subqw #2,%sp
    movel %fp@(18),%sp@-
    clrw %sp@-
    movew %fp@(16),%sp@-
    _TextWidth
    movew %sp@+,%d3
    moveal %fp@(10),%a0
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    subqw #2,%d0
    cmpw %d3,%d0
    jble TEXTBOX_A6
    movel %a0,%sp@-
    _EraseRect
    subqw #8,%sp
    movel %sp,%sp@-
    _GetFontInfo
    movew %sp@+,%d0
    addqw #6,%sp
    moveal %fp@(10),%a0
    movel %a0@,%sp@-
    addw %d0,%sp@
    addqw #1,%sp@(2)
    _MoveTo
    tstw %fp@(8)
    jbeq TEXTBOX_98
    moveal %fp@(10),%a0
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    subw %d3,%d0
    subqw #1,%d0
    tstw %fp@(8)
    jbmi TEXTBOX_92
    asrw #1,%d0
TEXTBOX_92:             /* move to it */
    movew %d0,%sp@-
    clrw %sp@-
    _Move
TEXTBOX_98:             /* draw the text */
    movel %fp@(18),%sp@-
    clrw %sp@-
    movew %fp@(16),%sp@-
    _DrawText
TEXTBOX_A4:             /* done */
    jbra TEXTBOX_DA
TEXTBOX_A6:             /* several lines: erase the box, a temporary TERec (TENew), TESetText, TEUpdate */
    subqw #4,%sp
    movel %fp@(10),%sp@-
    movel %sp@,%sp@-
    movel %sp@,%sp@-
    _EraseRect
    _TENew
    moveal %sp@+,%a4
    moveal %a4@,%a0
    movew %fp@(8),%a0@(58)
    movel %fp@(14),%d0
    jbeq TEXTBOX_D6
    movel %fp@(18),%sp@-
    movel %d0,%sp@-
    movel %a4,%sp@-
    _TESetText
    movel %fp@(10),%sp@-
    movel %a4,%sp@-
    _TEUpdate
TEXTBOX_D6:             /* dispose of the TERec */
    movel %a4,%sp@-
    _TEDispose
TEXTBOX_DA:             /* return */
    moveq #14,%d0
    jbra TECALTEXT_58

/* TESETTEXT: _TESetText. */
trap_TESetText:
TESETTEXT:
    jbsr DOMEASURE_186
    movel %a2@+,%d0	| 40822186
    movew %d0,%a3@(32)	| 40822188
    movew %d0,%a3@(34)	| 4082218C
    movew %d0,%a3@(60)	| 40822190
    moveal %a3@(62),%a0	| 40822194
    movel %d0,%sp@-	| 40822198
    _HUnlock	| 4082219A
    movel %sp@+,%d0
    moveal %a2@+,%a0
    moveal %a3@(62),%a1
    _PtrToXHand
    moveal %a3@(62),%a0
    _HLock
    jbsr TESETTEXT_34
    jbsr TESETTEXT_FE
TESETTEXT_30:           /* copy the text in */
    jbra TEINSERT_28

TESETTEXT_34:           /* styled: one style run for the whole text */
    tstw %a3@(80)
    jbpl TESETTEXT_5A
    moveal %a3@(74),%a0
    moveq #28,%d0
    jbsr TESETTEXT_5C
    moveal %a0@,%a0
    moveal %a0@(4),%a0
    moveq #18,%d0
    jbsr TESETTEXT_5C
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    movew %a3@(60),%d0
    addqw #1,%d0
    jbsr TESETTEXT_84
TESETTEXT_5A:           /* return */
    rts

TESETTEXT_5C:           /* _SetHandleSize with hText unlocked; failure: system error 25 */
    moveml %d0/%a0,%sp@-
    moveal %a3@(62),%a0
    _HUnlock
    moveml %sp@+,%d0/%a0
    _SetHandleSize
    jbne TESETTEXT_7E
    moveml %d0/%a0,%sp@-
    moveal %a3@(62),%a0
    _HLock
    moveml %sp@+,%d0/%a0
    rts
TESETTEXT_7E:           /* out of memory: system error 25 */
    movew #25,%d0
    _SysError

TESETTEXT_84:           /* one run, one style: the first entry from the port */
    movew #1,%a0@
    movew #1,%a0@(2)
    lea %a0@(20),%a1
    clrl %a1@+
    movew %d0,%a1@+
    movew #-1,%a1@
    moveal %a0@(4),%a0
    moveal %a0@,%a0
    movew #1,%a0@
    jbsr TESETTEXT_E8
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(4),%a0
    moveal %a0@,%a0
    movew %d0,%a0@(4)
    movew %d1,%a0@(2)
    moveal %a3@(82),%a1
    movew %a1@(68),%a0@(6)
    movew %a1@(70),%a0@(8)
    movel %a0,%sp@-
    movew %a0@(6),%d1
    lea %a0@(9),%a0
    jbsr XGETRLPOSITION_2A2
    moveal %sp@+,%a0
    movew %a1@(74),%a0@(10)
    pea %a0@(12)
    _GetForeColor
    rts

TESETTEXT_E8:           /* ascent (%d0) and line height (%d1) of the port's font */
    movel %a0,%sp@-
    subqw #8,%sp
    movel %sp,%sp@-
    _GetFontInfo
    movew %sp@+,%d0
    movew %d0,%d1
    addw %sp@+,%d1
    addqw #2,%sp
    addw %sp@+,%d1
    moveal %sp@+,%a0
    rts

TESETTEXT_FE:           /* recalculate all line starts from 0 (TERecal) */
    movel %a3@(32),%sp@-
    clrw %a3@(32)
    movew #-32767,%d7
    clrl %a3@(96)
    jbsr XFINDLINE_268
    movel %sp@+,%a3@(32)
    rts

/* TECALTEXT: _TECalText: line starts. */
trap_TECalText:
TECALTEXT:
    jbsr DOMEASURE_186
    jbsr TESETTEXT_FE	| 4082229E
TECALTEXT_6:            /* common exit: argument bytes 4 */
    moveq #4,%d0
TECALTEXT_8:            /* TE handle at %fp+8 */
    moveal %fp@(8),%a4
    jbra TECALTEXT_12
TECALTEXT_E:            /* TE handle at %fp+10 */
    moveal %fp@(10),%a4	| 408222A8
TECALTEXT_12:           /* restore the hText and TE handle state, the clip region and the port */
    moveal %a4@,%a3
    movew %d0,%d4
    moveal %a3@(62),%a0
    moveb %fp@(-12),%d0
    _HSetState
    movel %fp@(-10),%sp@-
    movel %sp@,%sp@-
    _SetClip
    _DisposRgn
    moveal %a4,%a0
    moveb %fp@(-2),%d0
    _HSetState
    pea %fp@(-24)
    _RGBForeColor
    moveal %a4@,%a3
    moveal %a3@(82),%a0
    movew %fp@(-18),%a0@(74)
    movew %fp@(-16),%a0@(70)
    movew %fp@(-14),%a0@(68)
    movel %fp@(-6),%sp@-
    _SetPort
    movew %d4,%d0
TECALTEXT_58:           /* restore registers, return */
    moveml %sp@+,%d2-%d7/%a2-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw %d0,%sp
    jmp %a0@

/* TESETSELECT: _TESetSelect. */
trap_TESetSelect:
TESETSELECT:
    jbsr DOMEASURE_186
    bsrw TENEW_8C	| 40822302
    bsrw HIDECARET
    bsrw TEUPDATE_1C
    movew %fp@(14),%a3@(34)
    movew %fp@(18),%a3@(32)
    bsrw DOMEASURE_204+0x36
    tstw %a3@(80)
    bpls TESETSELECT+0x36
    movew %a3@(32),%d0
    bsrw ITEFEATUREFLAG_9E
    bsrw ITESETSTYLE_2C0
    bsrw XSETFONT2KEYBOARD_7C
    jbsr XRECALLINES_2D8	| 40822334
    jbsr TEUPDATE_1C	| 40822338
    jbsr TESELVIEW_A	| 4082233C
    jbra TESETTEXT_30	| 40822340

/* TENEW: _TENew. */
trap_TENew:
TENEW:
    linkw %fp,#0
    moveml %d2-%d7/%a2-%a4,%sp@-
    clrl %fp@(16)
    moveq #104,%d0
    .short  0xA322	| 40822352 _NewHandle (flags 0x0300)
    jbne TESETTEXT_7E
    moveal %a0,%a4
    _HLock
    moveal %a4@,%a3
    moveq #0,%d0
    .short  0xA122	| 40822360 _NewHandle (flags 0x0100)
    jbne TESETTEXT_7E
    movel %a0,%a3@(62)
    lea %a3@,%a0
    moveal %fp@(12),%a2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    moveal %fp@(8),%a2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    jbsr TESETTEXT_E8
    movew %d0,%a3@(26)
    movew %d1,%a3@(24)
    moveal %a5@,%a2
    moveal %a2@,%a2
    movel %a2,%a3@(82)
    movel %a2@(68),%a3@(74)
    movel %a2@(72),%a3@(78)
    movel %a0,%sp@-
    movew %a3@(74),%d1
    lea %a3@(77),%a0
    jbsr XGETRLPOSITION_2A2
    moveal %sp@+,%a0
    movel TEWdBreak,%a3@(38)
    lea %pc@(ITEFEATUREFLAG_2A),%a0
    movel %a0,%a3@(42)
    jbsr TENEW_A8
    moveal %a3@(62),%a0
    _HUnlock
    moveal %a4,%a0
    _HUnlock
    movel %a4,%fp@(16)
    moveq #8,%d0
    jbra TECALTEXT_58

TENEW_8C:               /* styled: empty the null style */
    tstw %a3@(80)
    jbpl TENEW_A6
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(16),%a0
    moveal %a0@,%a0
    moveal %a0@(4),%a0
    moveal %a0@,%a0
    clrw %a0@
TENEW_A6:               /* return */
    rts
TENEW_A8:               /* the dispatch record: end-of-line, draw, width and hit-test hooks */
    moveq #20,%d0
    jbsr TESTYLNEW_F4
    movel %a0,%a3@(66)
    moveal %a0@,%a0
    lea %pc@(DOSEARCH_15C),%a1
    movel %a1,%a0@
    lea %pc@(DOSEARCH_186),%a1
    movel %a1,%a0@(4)
    lea %pc@(XGETWIDTH_60),%a1
    movel %a1,%a0@(8)
    lea %pc@(DOFIND_28),%a1
    movel %a1,%a0@(12)
    clrl %a0@(16)
    rts

/* TESTYLNEW: _TEStylNew. */
trap_TEStyleNew:
TESTYLNEW:
    linkw %fp,#0
    moveml %d2-%d7/%a2-%a4,%sp@-
    clrl %fp@(16)
    moveq #104,%d0
    .short  0xA322	| 4082242A _NewHandle (flags 0x0300)
    jbne TESETTEXT_7E
    moveal %a0,%a4
    _HLock
    moveal %a4@,%a3
    moveq #0,%d0
    .short  0xA122	| 40822438 _NewHandle (flags 0x0100)
    jbne TESETTEXT_7E
    movel %a0,%a3@(62)
    lea %a3@,%a0
    moveal %fp@(12),%a2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    moveal %fp@(8),%a2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movew #-1,%a3@(80)
    moveq #28,%d0
    jbsr TESTYLNEW_F4
    movel %a0,%a3@(74)
    moveq #18,%d0
    jbsr TESTYLNEW_F4
    moveal %a3@(74),%a2
    moveal %a2@,%a2
    movel %a0,%a2@(4)
    moveq #4,%d0
    jbsr TESTYLNEW_F4
    moveal %a0,%a1
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    movel %a1,%a0@(8)
    moveal %a5@,%a1
    moveal %a1@,%a1
    movel %a1,%a3@(82)
    movew %a1@(72),%a3@(78)
    moveq #1,%d0
    jbsr TESETTEXT_84
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a1
    moveal %a1@,%a1
    moveal %a0@(4),%a0
    moveal %a0@,%a0
    movew %a0@(4),%a1@(2)
    movew %a0@(2),%a1@
    movew #-1,%a3@(26)
    movew #-1,%a3@(24)
    movel TEWdBreak,%a3@(38)
    lea %pc@(ITEFEATUREFLAG_2A),%a0
    movel %a0,%a3@(42)
    jbsr TENEW_A8
    jbsr TESTYLNEW_CE
    moveal %a3@(62),%a0
    _HUnlock
    moveal %a4,%a0
    _HUnlock
    movel %a4,%fp@(16)
    moveq #8,%d0
    jbra TECALTEXT_58
TESTYLNEW_CE:           /* the null-style record and its scrap */
    movel %a2,%sp@-
    moveq #8,%d0
    jbsr TESTYLNEW_F4
    moveal %a3@(74),%a2
    moveal %a2@,%a2
    movel %a0,%a2@(16)
    movel %a0,%sp@-
    moveq #22,%d0
    jbsr TESTYLNEW_F4
    moveal %sp@+,%a2
    moveal %a2@,%a2
    movel %a0,%a2@(4)
    moveal %a0@,%a0
    clrw %a0@
    moveal %sp@+,%a2
    rts

TESTYLNEW_F4:           /* a new handle of %d0 bytes, with the TE record and hText unlocked while allocating */
    movel %d0,%sp@-
    moveal %a3@(62),%a0
    _HUnlock
    moveal %a4,%a0
    _HUnlock
    movel %sp@+,%d0
    .short  0xA122	| 4082251E _NewHandle (flags 0x0100)
    jbne TESETTEXT_7E
    movel %a0,%sp@-
    moveal %a4,%a0
    _HLock
    moveal %a4@,%a3
    moveal %a3@(62),%a0
    _HLock
    moveal %sp@+,%a0
    rts

/* TEUPDATE: _TEUpdate. */
trap_TEUpdate:
TEUPDATE:
    jbsr DOMEASURE_186
    moveal %a2@+,%a0	| 4082253A
    bsrw TESETJUST+0xc
    braw TESCROLL_C
TEUPDATE_E:             /* the word around %d6 after a double click (%d5 negative), else just %d6 */
    movew %d6,%d0	| 40822544
    movew %d6,%d1	| 40822546
    tstl %d5	| 40822548
    jbpl TEUPDATE_1A	| 4082254A
    jbsr TEDELETE_234	| 4082254C
TEUPDATE_1A:            /* return */
    rts

TEUPDATE_1C:            /* active and a selection: hilite it */
    tstb %a3@(36)
    jbeq TEUPDATE_1A
    movemw %a3@(32),%d3-%d4
    moveq #1,%d7
    jbra DOTEXT

/* TECLICK: _TEClick. */
trap_TEClick:
TECLICK:
    jbsr DOMEASURE_186
    bsrw TENEW_8C
    movel %fp@(14),%a3@(28)
    bsrw DOFIND
    bsrw HIDECARET
    subqw #4,%sp
    _TickCount
    movel %sp@+,%d0
    subl %a3@(46),%d0
    cmpl DoubleTime,%d0
    sle %d5
    cmpw %a3@(50),%d6
    seq %d1
    andb %d1,%d5
    rorl #8,%d5
    movew %d6,%a3@(50)
    tstw %a3@(80)
    bpls TECLICK_48
    movew %d6,%d0
    bsrw ITEFEATUREFLAG_9E
    bsrw ITESETSTYLE_2C0
    bsrw XSETFONT2KEYBOARD_7C
TECLICK_48:             /* shift-click: extend the selection from its far end */
    tstb %fp@(12)
    beqs TECLICK_66
    movemw %a3@(32),%d0-%d1
    cmpw %d6,%d0
    bccs TECLICK_5E
    moveaw %d0,%a2
    moveaw %d0,%a4
    bras TECLICK_62
TECLICK_5E:             /* anchor at the end */
    moveaw %d1,%a2
    moveaw %d1,%a4
TECLICK_62:             /* track */
    movew %d6,%d5
    bras TECLICK_AC
TECLICK_66:             /* plain click: unhilite, put the caret at the click */
    bsrs TEUPDATE_1C
    moveq #4,%d2
    bsrw TEUPDATE_E
    movemw %d0-%d1,%a3@(32)
    moveaw %d0,%a2
    moveaw %d1,%a4
    movew %d6,%d5
    moveb %a3@(70),%a3@(71)
    bsrw XRECALLINES_2D8
    bsrw TEUPDATE_1C
TECLICK_88:             /* per mouse movement: the click loop routine (clikLoop); false: stop */
    movel %a3@(42),%d0
    beqs TECLICK_94
    moveal %d0,%a0
    jsr %a0@
    beqs TECLICK_F2
TECLICK_94:             /* while the button is down: hit-test the mouse position */
    clrw %sp@-
    _WaitMouseUp
    tstw %sp@+
    beqs TECLICK_F2
    pea %a3@(28)
    _GetMouse
    bsrs DOFIND
    cmpw %d6,%d5
    beqs TECLICK_88
    bsrw HIDECARET
TECLICK_AC:             /* extend to the mouse (whole words after a double click); hilite the change */
    moveq #8,%d2
    bsrw TEUPDATE_E
    lea %a3@(34),%a0
    cmpaw %d6,%a4
    bcss TECLICK_CC
    movew %a0@-,%d3
    movew %d0,%a0@+
    movew %d0,%d4
    swap %d3
    swap %d4
    movew %a4,%d3
    movew %a0@+,%d4
    movew %a4,%a0@-
    bras TECLICK_E0
TECLICK_CC:             /* extending the other way */
    cmpaw %d6,%a2
    bhis TECLICK_EE
    movew %a0@+,%d3
    movew %d1,%a0@-
    movew %d1,%d4
    swap %d3
    swap %d4
    movew %a0@-,%d3
    movew %a2,%d4
    movew %a2,%a0@+
TECLICK_E0:             /* hilite the difference (both ends) */
    moveq #1,%d7
    bsrw DOTEXT
    swap %d3
    swap %d4
    bsrw DOTEXT
TECLICK_EE:             /* next movement */
    movew %d6,%d5
    bras TECLICK_88
TECLICK_F2:             /* mouse up: show the caret, remember the click time */
    bsrw XRECALLINES_2D8
    subqw #4,%sp
    _TickCount
    movel %sp@+,%a3@(46)
    moveq #10,%d0
    braw TECALTEXT_8

/* DOFIND: find the character at a point. */
DOFIND:
    movew %a3@(28),%d0	| 40822668
    bsrw DOMEASURE_114
    jbge DOFIND_12	| 40822670
    addw %d0,%d0	| 40822672
    jbpl DOFIND_18	| 40822674
    moveq #0,%d6	| 40822676
    rts	| 40822678
DOFIND_12:              /* after the end: the text length */
    movew %a3@(60),%d6	| 4082267A
    rts	| 4082267E
DOFIND_18:              /* in a line: hit-test it (DOTEXT, find mode) */
    movemw %a3@(0x60,%d0:w),%d3-%d4	| 40822680
    moveq #0,%d7
    jbsr DOTEXT
    movew %d0,%d6
    rts
DOFIND_28:              /* through the low-memory vector at 0x798 */
    movel 0x798,%sp@-
    rts

/* VPIXEL2CHAR: vectored: the character offset at a pixel position in a line. */
trap_VPIXEL2CHAR:
VPIXEL2CHAR:
    linkw %fp,#-14
    movew %d0,%fp@(-4)
    movel %a0,%fp@(-8)
    movew %d1,%fp@(-10)
    movew %d2,%fp@(-12)
    subql #2,%sp
    movel %a0,%sp@-
    clrw %sp@-
    movew %d0,%sp@-
    _TextWidth
    moveq #0,%d0
    movew %sp@+,%d0
    moveq #0,%d2
    movew %fp@(-4),%d1
    cmpw %fp@(-10),%d0
    jbls VPIXEL2CHAR_64
    movew %d0,%fp@(-14)
    clrw %sp@-
    movel %fp@(-8),%sp@-
    movew %fp@(-4),%sp@-
    movew %fp@(-12),%sp@-
    movew %fp@(-10),%sp@-
    pea %fp@(-2)
    movel #-2113011692,%sp@-
    _ScriptUtil
    movew %sp@+,%d1
    movew %fp@(-14),%d0
    bset #16,%d0
    clrw %d2
    moveb %fp@(-2),%d2
    jbeq VPIXEL2CHAR_64
    addqw #1,%d1
VPIXEL2CHAR_64:         /* return */
    unlk %fp
    rts

/* DOSEARCH: search the lines. */
DOSEARCH:
    jbsr PREPLINE_14
    movew %a2@,%d3
    movew %d3,%d4
    jbsr LINERECT
    movew %a2@,%d7
    sf %a3@(70)
    movew %a3@(30),%d5
    subw %a3@(18),%d5
    jble DOSEARCH_F8
    movew %a3@(18),%a3@(22)
    movew #-32766,%a3@(18)
    movew %a2@(2),%d6
    tstw %a3@(80)
    jbmi DOSEARCH_40
    st %fp@(-6)
    moveq #1,%d2
    movew %d3,%d1
    movew %d6,%d0
    jbra DOSEARCH_B2
DOSEARCH_40:            /* per style run of the line, in display order */
    sf %fp@(-6)
    tstb WordRedraw
    jbge DOSEARCH_7C
    movew %d3,%d0
    movew %d6,%d1
    jbsr XGETRLPOSITION_356
    jbge DOSEARCH_8E
    jbra DOSEARCH_E6
DOSEARCH_58:            /* next run in display order */
    moveal %fp@(-12),%a0
    movew %fp@(-8),%d0
    lslw #1,%d0
    lea %fp@(-16),%a1
    moveal %a1@,%a1
    movew %a1@(0x0,%d0:w),%d0
    lslw #2,%d0
    lea %a0@(0x0,%d0:w),%a0
    addqw #1,%fp@(-8)
    subqw #1,%d2
    jbge DOSEARCH_8E
    jbra DOSEARCH_E6
DOSEARCH_7C:            /* plain order: the runs in the range */
    st %fp@(-6)
    movew %d3,%d0
    movew %d6,%d1
    jbsr ITEFEATUREFLAG_9E
    jbsr ITEFEATUREFLAG_EC
    movew %d0,%d2
DOSEARCH_8E:            /* lock the style handle */
    moveal %a0,%a2
    moveal %a3@(74),%a0
    _HLock
    moveal %a2,%a0
DOSEARCH_98:            /* per run: set its style; clip the run to the line */
    moveal %a0,%a2
    jbsr ITESETSTYLE_2C0
    movew %a0@,%d1
    addql #4,%a0
    movew %a0@,%d0
    cmpw %d3,%d1
    jbcc DOSEARCH_AA
    movew %d3,%d1
DOSEARCH_AA:            /* run end */
    movew %d1,%d7
    cmpw %d0,%d6
    jbcc DOSEARCH_B2
    movew %d6,%d0
DOSEARCH_B2:            /* hit-test the run (the dispatch record's hit-test hook) */
    movew %d2,%sp@-
    subw %d1,%d0
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    addaw %d1,%a0
    movew %d5,%d1
    moveq #0,%d2
    jbsr DOSEARCH_16E
    addw %d0,%a3@(22)
    addw %d1,%d7
    subw %d0,%d5
    jble DOSEARCH_110
    moveal %a2,%a0
    movew %sp@+,%d2
    jbne DOSEARCH_D8
    jbra DOSEARCH_E6
DOSEARCH_D8:            /* next run */
    tstb %fp@(-6)
    jbeq DOSEARCH_58
    addql #4,%a0
    subqw #1,%d2
    jbne DOSEARCH_98
DOSEARCH_E6:            /* not found in the line: after its end */
    movew #32766,%a3@(22)
    movew %d3,%d0
    lea %a3@(96),%a2
    jbsr PREPLINE_42
    jbra DOSEARCH_FA
DOSEARCH_F8:            /* left of the line */
    st %d2
DOSEARCH_FA:            /* which side of the character, by direction */
    movew %a2@(2),%d7
    cmpb TESysJust,%d2
    jbeq DOSEARCH_122
    movew %a2@,%d7
    st %a3@(70)
    tstb %d2
    jbne DOSEARCH_14C
    jbra DOSEARCH_13C
DOSEARCH_110:           /* hit the trailing half: back one */
    addql #2,%sp
    tstw %d2
    jbeq DOSEARCH_13C
    subqw #1,%d7
    st %a3@(70)
    cmpw %a2@(2),%d7
    jbne DOSEARCH_130
DOSEARCH_122:           /* end of line: a return counts as before it */
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    moveb %a0@(0xffffffffffffffff,%d7:w),%d0
    jbsr DOSEARCH_152
    jbeq DOSEARCH_136
DOSEARCH_130:           /* past the right edge */
    tstw %d5
    jble DOSEARCH_14C
    jbra DOSEARCH_13C
DOSEARCH_136:           /* before the return */
    subqw #1,%d7
    st %a3@(70)
DOSEARCH_13C:           /* styled: unlock */
    tstw %a3@(80)
    jbpl DOSEARCH_14C
    moveal %a3@(74),%a0
    _HUnlock
    jbsr XTEGETFORMATORDER_112
DOSEARCH_14C:           /* return the offset */
    movew %d7,%d0
    jbra DODRAW_112

DOSEARCH_152:           /* the end-of-line hook (dispatch record +0) */
    moveal %a3@(66),%a0
    moveal %a0@,%a0
    moveal %a0@,%a0
    jmp %a0@
DOSEARCH_15C:           /* default end-of-line test: a return */
    cmpib #13,%d0
    rts

DOSEARCH_162:           /* the width hook (+8) */
    moveal %a3@(66),%a1
    moveal %a1@,%a1
    moveal %a1@(8),%a1
    jmp %a1@

DOSEARCH_16E:           /* the hit-test hook (+12) */
    moveal %a3@(66),%a1
    moveal %a1@,%a1
    moveal %a1@(12),%a1
    jmp %a1@
DOSEARCH_17A:           /* the draw hook (+4) */
    moveal %a3@(66),%a1
    moveal %a1@,%a1
    moveal %a1@(4),%a1
    jmp %a1@
DOSEARCH_186:           /* default draw hook: _DrawText */
    movel %a0,%sp@-
    movew %d0,%sp@-
    movew %d1,%sp@-
    _DrawText
    rts

/* DODRAW: draw the text. */
DODRAW:
    jbsr DOMEASURE_C6
    jbsr PREPLINE_14
    jbsr LINERECT
DODRAW_C:               /* per line in the range */
    jbsr PREPLINE
    jbls DODRAW_10E
    jbsr CHKBOUNDS
    tstw TESysJust
    jbeq DODRAW_24
    movew #-32766,%a3@(18)
DODRAW_24:              /* the pen position from the justification */
    movew %d4,%d6
    jbsr DODRAW_11E
    movew %fp@(-2),%sp@-
    movew %a3@(16),%sp@-
    movew %a3@(26),%d0
    tstw %a3@(80)
    jbmi DODRAW_54
    addw %d0,%sp@
    _MoveTo
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    addal %d3,%a0
    clrw %d0
    movew %d4,%d1
    subw %d3,%d1
    jbsr DOSEARCH_17A
    jbra DODRAW_FE
DODRAW_54:              /* styled: the line's ascent from the line-height table */
    tstw %d0
    jbpl DODRAW_70
    jbsr CHKBOUNDS_8E
    extl %d0
    lsll #2,%d0
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    movew %a0@(0x2,%d0:l),%d0
DODRAW_70:              /* move the pen; the style runs of the line */
    addw %d0,%sp@
    _MoveTo
    sf %fp@(-6)
    tstb WordRedraw
    jbge DODRAW_98
    movew %d3,%d0
    movew %d4,%d1
    jbsr XGETRLPOSITION_356
    jbge DODRAW_AA
    jbra DODRAW_FE
DODRAW_8A:              /* next run in display order */
    jbsr XTEGETFORMATORDER_7E
    addqw #1,%fp@(-8)
    subqw #1,%d2
    jbge DODRAW_AA
    jbra DODRAW_FE
DODRAW_98:              /* plain order */
    st %fp@(-6)
    movew %d3,%d0
    movew %d4,%d1
    jbsr ITEFEATUREFLAG_9E
    jbsr ITEFEATUREFLAG_EC
    movew %d0,%d2
DODRAW_AA:              /* per run: set its style; clip to the range */
    movel %a0,%sp@-
    jbsr ITESETSTYLE_2C0
    movew %a0@,%d0
    addqw #4,%a0
    movew %d6,%d4
    cmpw %a0@,%d6
    jbcs DODRAW_BC
    movew %a0@,%d4
DODRAW_BC:              /* draw the run (the draw hook) */
    movew %d2,%sp@-
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    cmpw %d3,%d0
    jbcc DODRAW_CA
    movew %d3,%d0
DODRAW_CA:              /* through the dispatch record's draw hook */
    addaw %d0,%a0
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    movel %a1,%d1
    subl %d1,%sp@(2)
    movew %d4,%d1
    subw %d0,%d1
    clrw %d0
    jbsr DOSEARCH_17A
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    movel %a1,%d1
    addl %d1,%sp@(2)
    movew %sp@+,%d2
    moveal %sp@+,%a0
    tstb %fp@(-6)
    jbeq DODRAW_8A
    addql #4,%a0
    subqw #1,%d2
    jbne DODRAW_AA
DODRAW_FE:              /* next line */
    jbsr CHKBOUNDS_8E
    addqw #1,%d0
    jbsr CHKBOUNDS_70
    movew %a2@,%d3
    jbra DODRAW_C
DODRAW_10E:             /* done: free the format order */
    jbsr XTEGETFORMATORDER_112
DODRAW_112:             /* restore registers, return */
    moveml %sp@+,%d2-%d7/%a2-%a4
    unlk %fp
    moveal %a5@,%a0
    moveal %a0@,%a0
    rts

DODRAW_11E:             /* vectored line justification (ExpandMem +144) */
    moveal ExpandMem,%a0
    moveal %a0@(144),%a0
    jmp %a0@

/* XDOERASE: erase the background of a line part. */
XDOERASE:
    movew %a3@(18),%sp@-	| 408229B6
    cmpw %a2@,%d3	| 408229BA
    jbeq XDOERASE_52	| 408229BC
    cmpiw #2,%a3@(78)	| 408229BE
    jbeq XDOERASE_52	| 408229C4
    tstw %a3@(80)	| 408229C6
    jbpl XDOERASE_36	| 408229CA
    tstb WordRedraw	| 408229CC
    jbge XDOERASE_26	| 408229D0
    movew %d3,%d0	| 408229D2
    movew %d4,%d1	| 408229D4
    jbsr XGETRLPOSITION_356	| 408229D6
    jbra XDOERASE_32	| 408229DA
XDOERASE_26:            /* style of the first character of the range */
    movew %d3,%d0	| 408229DC
    movew %d0,%d1	| 408229DE
    jbsr ITEFEATUREFLAG_9E	| 408229E0
    jbsr ITEFEATUREFLAG_EC	| 408229E4
XDOERASE_32:            /* set it */
    jbsr ITESETSTYLE_2C0	| 408229E8
XDOERASE_36:            /* the width of the character at %d3, less one pixel, past the left edge */
    subql #2,%sp	| 408229EC
    moveal %a3@(62),%a0	| 408229EE
    movel %a0@,%sp@-	| 408229F2
    movew %d3,%sp@-	| 408229F4
    movew #1,%sp@-	| 408229F6
    _TextWidth	| 408229FA
    movew %sp@+,%d0	| 408229FC
    tstw %d0	| 408229FE
    jbeq XDOERASE_4E	| 40822A00
    subqw #1,%d0	| 40822A02
XDOERASE_4E:            /* from there */
    addw %d0,%a3@(18)	| 40822A04
XDOERASE_52:            /* erase the rectangle */
    pea %a3@(16)
    _EraseRect
    movew %sp@+,%a3@(18)
    jbsr XTEGETFORMATORDER_112
    rts

/* PREPLINE: prepare a line for drawing. */
PREPLINE:
    movew %d5,%d4
    cmpw %a2@(2),%d4
    jbcs PREPLINE_C
    movew %a2@(2),%d4
PREPLINE_C:             /* the line's rectangle */
    jbsr RANGERECT
    cmpw %d3,%d5
    rts

PREPLINE_14:            /* entry: save registers; %d3..%d4 ordered and pinned to the text */
    moveal %sp@+,%a0
    moveml %d2-%d7/%a2-%a4,%sp@-
    movel %a0,%sp@-
    cmpw %d3,%d4
    jbcc PREPLINE_22
    exg %d4,%d3
PREPLINE_22:            /* pin the end */
    cmpw %a3@(60),%d4
    jbcs PREPLINE_2C
    movew %a3@(60),%d4
PREPLINE_2C:            /* the line starts; find the line of %d3 */
    lea %a3@(96),%a2
    andl %pc@(XFINDWORD_17C),%d4
    movew %d4,%d5
    andl %pc@(XFINDWORD_17C),%d3
    jbeq PREPLINE_40
    movew %d3,%d0
    jbsr PREPLINE_42
PREPLINE_40:            /* return */
    rts

PREPLINE_42:            /* the line containing offset %d0 */
    cmpw %a2@(2),%d0
    jbls PREPLINE_4C
    addqw #2,%a2
    jbra PREPLINE_42
PREPLINE_4C:            /* past the start: next line */
    jbne PREPLINE_50
    addqw #2,%a2
PREPLINE_50:            /* return */
    rts

/* DOTEXT: common text routine (measure, draw, hilite, find). */
DOTEXT:
    movel TEDoText,%sp@-
    rts

DOTEXT_6:               /* by mode in %d7: 0 find, >0 hilite, -1 draw, else caret */
    linkw %fp,#-50
    tstw %d7
    jbeq DOSEARCH
    jbgt DOHILITE
    cmpiw #-1,%d7
    jbeq DODRAW

/* DOCARET: draw the caret. */
DOCARET:
    jbsr PREPLINE_14
    tstw %d3
    jbeq DOCARET_2E
    cmpw %a2@,%d3
    jbne DOCARET_2E
    movew %a3@(60),%d0
    jbeq DOCARET_2E
    cmpw %d0,%d3
    jbcs DOCARET_26
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    moveb %a0@(0xffffffffffffffff,%d3:w),%d0
    jbsr DOSEARCH_152
    jbeq DOCARET_2E
    jbra DOCARET_2C
DOCARET_26:             /* at a line start: caret at the end of the previous line? */
    tstb %a3@(71)
    jbne DOCARET_2E
DOCARET_2C:             /* the previous line */
    subqw #2,%a2
DOCARET_2E:             /* right-to-left or mixed text: the dual caret */
    jbsr LINERECT
    tstw %a3@(80)
    jbmi DOCARET_44
    tstb WordRedraw
    jbmi DOCARET_44
    tstb TESysJust
    jbeq DOCARET_50
DOCARET_44:             /* the caret position(s) */
    jbsr DOCARET_66
    movew %a3@(18),%d0
    movew %d0,%fp@(-2)
    jbra DOCARET_5C
DOCARET_50:             /* plain: the width up to the caret */
    jbsr PREPLINE
    movew %fp@(-2),%d0
    movew %d0,%a3@(22)
DOCARET_5C:             /* one pixel wide */
    subqw #1,%d0
    movew %d0,%a3@(18)
    jbra DODRAW_112

DOCARET_66:             /* vectored caret display (ExpandMem +148) */
    moveal ExpandMem,%a0
    moveal %a0@(148),%a0
    jmp %a0@

/* XCARETDISPLAY: draw the caret (dual caret for mixed directions). */
XCARETDISPLAY:
    linkw %fp,#-114
    moveal ExpandMem,%a0
    sf %a0@(46)
    sf %a0@(56)
    sf %fp@(-42)
    clrw %fp@(-72)
    sf %fp@(-69)
    clrw %d5
    jbsr XGETRLPOSITION_30E
XCARETDISPLAY_22:       /* per style run in display order */
    jbsr XTEGETFORMATORDER_7E
    addqw #1,%fp@(-8)
XCARETDISPLAY_2A:       /* the caret before, at or after this run */
    cmpw %a0@,%d3
    jbhi XCARETDISPLAY_34
    jbeq XCARETDISPLAY_4C
    braw XCARETDISPLAY_B2
XCARETDISPLAY_34:       /* inside the run */
    jbsr XCURSORMOVEMENT_234
    cmpw %d0,%d3
    jbhi XCARETDISPLAY_B2
    jblt XCARETDISPLAY_5C
    tstb %fp@(-72)
    jbne XCARETDISPLAY_D4
    st %fp@(-70)
    jbra XCARETDISPLAY_58
XCARETDISPLAY_4C:       /* at its start */
    tstb %fp@(-72)
    bnew XCARETDISPLAY_D4
    sf %fp@(-70)
XCARETDISPLAY_58:       /* on a run boundary */
    st %fp@(-71)
XCARETDISPLAY_5C:       /* set the run's style */
    tstw %a3@(80)
    jbpl XCARETDISPLAY_66
    jbsr ITESETSTYLE_2C0
XCARETDISPLAY_66:       /* one run on a left-to-right line: the width up to the caret; done */
    tstb %fp@(-42)
    jbeq XCARETDISPLAY_86
    tstb TESysJust
    jbne XCARETDISPLAY_86
    moveq #0,%d2
    jbsr XCARETDISPLAY_124
    addw %d1,%d5
    addw %d5,%a3@(18)
    addw %d5,%a3@(22)
    jbra XCARETDISPLAY_11C
XCARETDISPLAY_86:       /* the caret within the run */
    movew %d2,%sp@-
    jbsr XCARETDISPLAY_174
    movew %sp@+,%d2
    tstb %fp@(-6)
    jbne XCARETDISPLAY_100
    tstb %fp@(-73)
    jbne XCARETDISPLAY_B2
    tstb %fp@(-69)
    jbne XCARETDISPLAY_AA
    tstb %fp@(-70)
    bnew XCARETDISPLAY_22
    jbra XCARETDISPLAY_B2
XCARETDISPLAY_AA:       /* next run */
    tstb %fp@(-70)
    jbeq XCARETDISPLAY_22
XCARETDISPLAY_B2:       /* add the run's width */
    movew %d1,%sp@-
    jbsr XONSAMELINE_242
    addw %d0,%d5
    movew %sp@+,%d1
    tstb %fp@(-42)
    jbne XCARETDISPLAY_CA
    subqw #1,%d2
    jbeq XCARETDISPLAY_100
    jbra XCARETDISPLAY_22
XCARETDISPLAY_CA:       /* next run */
    addql #4,%a0
    subqw #1,%d2
    jbne XCARETDISPLAY_2A
    jbra XCARETDISPLAY_100
XCARETDISPLAY_D4:       /* on a boundary: which run's direction? */
    tstb %fp@(-70)
    jbne XCARETDISPLAY_E0
    moveb %fp@(-68),%d0
    jbra XCARETDISPLAY_E4
XCARETDISPLAY_E0:       /* the following run */
    moveb %fp@(-67),%d0
XCARETDISPLAY_E4:       /* same direction as the line */
    jbne XCARETDISPLAY_EE
    tstb %fp@(-70)
    jbeq XCARETDISPLAY_F6
    jbra XCARETDISPLAY_106
XCARETDISPLAY_EE:       /* different */
    tstb %fp@(-70)
    jbne XCARETDISPLAY_F6
    jbra XCARETDISPLAY_106
XCARETDISPLAY_F6:       /* add the run's width */
    movew %d5,%sp@-
    jbsr XONSAMELINE_242
    addw %d0,%d5
    jbra XCARETDISPLAY_106
XCARETDISPLAY_100:      /* second caret needed? */
    tstb %fp@(-73)
    jbeq XCARETDISPLAY_11C
XCARETDISPLAY_106:      /* the split caret position into ExpandMem */
    moveal ExpandMem,%a0
    lea %a0@(48),%a0
    addqw #2,%a0
    addw %fp@(-64),%d5
    movew %d5,%a0@
    subqw #1,%a0@+
    addqw #2,%a0
    movew %d5,%a0@
XCARETDISPLAY_11C:      /* free the format order */
    jbsr XTEGETFORMATORDER_112
    unlk %fp
    rts

XCARETDISPLAY_124:      /* vectored (ExpandMem +152) */
    moveal ExpandMem,%a1
    moveal %a1@(152),%a1
    jmp %a1@
XCARETDISPLAY_12E:      /* the width of the run up to the caret */
    movel %a0,%sp@-
    moveal %a3@(62),%a1
    moveal %a1@,%a1
    addaw %a0@,%a1
    exg %a1,%a0
    moveq #0,%d4
    movew %a2@,%d0
    cmpw %a1@,%d0
    jbls XCARETDISPLAY_14E
    subw %a1@,%d0
    addaw %d0,%a0
    movew %d0,%d4
    movew %d3,%d1
    subw %a2@,%d1
    jbra XCARETDISPLAY_152
XCARETDISPLAY_14E:      /* from the run start */
    movew %d3,%d1
    subw %a1@,%d1
XCARETDISPLAY_152:      /* the run end, pinned to the line */
    movel %a0,%sp@-
    moveal %a1,%a0
    jbsr XCURSORMOVEMENT_234
    moveal %sp@+,%a0
    cmpw %a2@(2),%d0
    jbls XCARETDISPLAY_166
    movew %a2@(2),%d0
XCARETDISPLAY_166:      /* its width (width hook) */
    subw %a1@,%d0
    subw %d4,%d0
    swap %d2
    jbsr DOSEARCH_162
    moveal %sp@+,%a0
    rts

XCARETDISPLAY_174:      /* vectored caret position in a run (ExpandMem +156) */
    moveal ExpandMem,%a1
    moveal %a1@(156),%a1
    jmp %a1@

/* XGETRLPOSITION: position in right-to-left text. */
XGETRLPOSITION:
    moveml %a0,%sp@-	| 40822C74
    sf %fp@(-6)	| 40822C78
    clrw %fp@(-74)	| 40822C7C
    st %fp@(-72)	| 40822C80
    moveq #0,%d2	| 40822C84
    movel %a2,%sp@-
    lea %a3@(16),%a1
    lea %fp@(-66),%a2
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    moveal %sp@+,%a2
    tstb %fp@(-71)
    jbeq XGETRLPOSITION_B6
    tstw %a3@(80)
    jbpl XGETRLPOSITION_B6
    jbsr XGETRLPOSITION_2DC
    tstb %fp@(-70)
    jbeq XGETRLPOSITION_4C
    moveb %d1,%fp@(-68)
    cmpw %a2@(2),%d3
    jbeq XGETRLPOSITION_B2
    movel %a0,%sp@-
    addql #4,%a0
    jbra XGETRLPOSITION_58
XGETRLPOSITION_4C:      /* at the line start: the leading-edge caret */
    moveb %d1,%fp@(-67)
    cmpw %a2@,%d3
    jbeq XGETRLPOSITION_B2
    movel %a0,%sp@-
    subql #4,%a0
XGETRLPOSITION_58:      /* direction of the previous run */
    jbsr XGETRLPOSITION_2DC
    tstb %fp@(-70)
    jbeq XGETRLPOSITION_68
    moveb %d1,%fp@(-67)
    jbra XGETRLPOSITION_6C
XGETRLPOSITION_68:      /* direction of this run */
    moveb %d1,%fp@(-68)
XGETRLPOSITION_6C:      /* same direction on both sides: one caret */
    moveal %sp@+,%a0
    moveb %fp@(-67),%d0
    cmpb %fp@(-68),%d0
    jbne XGETRLPOSITION_7E
    jbsr XGETRLPOSITION_276
    jbra XGETRLPOSITION_BA
XGETRLPOSITION_7E:      /* different: which run the caret belongs to */
    tstb %fp@(-70)
    jbeq XGETRLPOSITION_88
    moveb %fp@(-68),%d0
XGETRLPOSITION_88:      /* the caret's run goes with the line direction: primary caret */
    moveb %d0,%fp@(-69)
    cmpb TESysJust,%d0
    jbne XGETRLPOSITION_96
    st %fp@(-74)
XGETRLPOSITION_96:      /* left-to-right run */
    tstb %d0
    jbne XGETRLPOSITION_A2
    tstb %fp@(-70)
    jbne XGETRLPOSITION_A8
    jbra XGETRLPOSITION_AE
XGETRLPOSITION_A2:      /* right-to-left run */
    tstb %fp@(-70)
    jbne XGETRLPOSITION_AE
XGETRLPOSITION_A8:      /* add the run's width */
    jbsr XONSAMELINE_242
    addw %d0,%d5
XGETRLPOSITION_AE:      /* set up the split caret */
    jbsr XGETRLPOSITION_C0
    jbra XGETRLPOSITION_BA
XGETRLPOSITION_B2:      /* at a line start */
    jbsr XGETRLPOSITION_10E
    jbra XGETRLPOSITION_BA
XGETRLPOSITION_B6:      /* at a line end */
    jbsr XGETRLPOSITION_1E2
XGETRLPOSITION_BA:      /* restore registers, return */
    moveml %sp@+,%a0
    rts

XGETRLPOSITION_C0:      /* split caret: the caret rectangle at the position, upper or lower half */
    addw %d5,%a3@(18)
    addw %d5,%a3@(22)
    movew %a3@(20),%d2
    addw %a3@(16),%d2
    lsrw #1,%d2
    moveal ExpandMem,%a0
    st %a0@(46)
    lea %a0@(48),%a0
    tstb %fp@(-74)
    jbeq XGETRLPOSITION_F4
    movew %d2,%a3@(20)
    movew %a3@(20),%a0@+
    addqw #2,%a0
    movew %fp@(-62),%a0@
    jbra XGETRLPOSITION_10C
XGETRLPOSITION_F4:      /* store the second caret's position in ExpandMem */
    movew %d2,%a3@(16)
    movew %fp@(-66),%a0@+
    addqw #2,%a0
    movew %a3@(16),%a0@
    moveal ExpandMem,%a0
    oriw #255,%a0@(46)
XGETRLPOSITION_10C:     /* return */
    rts

XGETRLPOSITION_10E:     /* vectored line-start caret (ExpandMem +160) */
    moveal ExpandMem,%a1
    moveal %a1@(160),%a1
    jmp %a1@
XGETRLPOSITION_118:     /* line start: run direction against the line direction */
    jbsr XGETRLPOSITION_2DC	| 40822D8C
    cmpb TESysJust,%d1	| 40822D90
    jbne XGETRLPOSITION_14A	| 40822D94
    st %fp@(-6)	| 40822D96
    tstb %d1	| 40822D9A
    jbne XGETRLPOSITION_136	| 40822D9C
    tstb %fp@(-70)	| 40822D9E
    jbne XGETRLPOSITION_1D2	| 40822DA2
    jbra XGETRLPOSITION_1E0	| 40822DA6
XGETRLPOSITION_136:     /* right-to-left run */
    tstb %fp@(-70)	| 40822DAA
    jbeq XGETRLPOSITION_1D2	| 40822DAE
    tstb TESysJust	| 40822DB2
    jbeq XGETRLPOSITION_1D2	| 40822DB6
    jbra XGETRLPOSITION_1E0	| 40822DBA
XGETRLPOSITION_14A:     /* different direction */
    tstb %d1
    jbeq XGETRLPOSITION_156
    cmpw %a2@(2),%d3
    jbeq XGETRLPOSITION_19A
    jbra XGETRLPOSITION_15A
XGETRLPOSITION_156:     /* at the line start */
    cmpw %a2@,%d3
    jbeq XGETRLPOSITION_19A
XGETRLPOSITION_15A:     /* the caret at the run's far edge, split */
    movew %fp@(-64),%a3@(18)
    movew %fp@(-64),%a3@(22)
    jbsr XONSAMELINE_242
    addw %d0,%d5
    st %fp@(-6)
    st %fp@(-73)
    movew %a3@(20),%d2
    addw %a3@(16),%d2
    lsrw #1,%d2
    movew %d2,%a3@(20)
    moveal ExpandMem,%a0
    st %a0@(46)
    lea %a0@(48),%a0
    movew %a3@(20),%a0@+
    addqw #2,%a0
    movew %fp@(-62),%a0@
    jbra XGETRLPOSITION_1E0
XGETRLPOSITION_19A:     /* split caret at the position */
    addw %d5,%a3@(18)
    addw %d5,%a3@(22)
    st %fp@(-73)
    movew %a3@(20),%d2
    addw %a3@(16),%d2
    lsrw #1,%d2
    movew %d2,%a3@(16)
    moveal ExpandMem,%a0
    st %a0@(46)
    oriw #255,%a0@(46)
    lea %a0@(48),%a0
    movew %fp@(-66),%a0@+
    addqw #2,%a0
    movew %a3@(16),%a0@
    jbra XGETRLPOSITION_1E0
XGETRLPOSITION_1D2:     /* add the run's width */
    jbsr XONSAMELINE_242	| 40822E46
    addw %d0,%d5	| 40822E4A
    addw %d5,%a3@(18)	| 40822E4C
    addw %d5,%a3@(22)	| 40822E50
XGETRLPOSITION_1E0:     /* return */
    rts

XGETRLPOSITION_1E2:     /* vectored line-end caret (ExpandMem +164) */
    moveal ExpandMem,%a1
    moveal %a1@(164),%a1
    jmp %a1@
XGETRLPOSITION_1EC:     /* line end: the caret positions on either side of the offset */
    st %fp@(-6)	| 40822E60
    movew #-1,%d2	| 40822E64
    swap %d2	| 40822E68
    clrw %d2	| 40822E6A
    moveal %a0,%a1	| 40822E6C
    movew %d5,%sp@-	| 40822E6E
    movew %d3,%d0	| 40822E70
    subw %a1@,%d0	| 40822E72
    movew %a2@,%d1	| 40822E74
    cmpw %a1@,%d1	| 40822E76
    jbls XGETRLPOSITION_20A	| 40822E78
    subw %a1@,%d1	| 40822E7A
    subw %d1,%d0	| 40822E7C
XGETRLPOSITION_20A:     /* measure; right-to-left line or a direction change */
    movew %d0,%d1	| 40822E7E
    jbsr XONSAMELINE_3FC	| 40822E80
    tstb TESysJust
    jbeq XGETRLPOSITION_22E
    jbsr XGETRLPOSITION_2DC
    cmpb TESysJust,%d1
    jbeq XGETRLPOSITION_230
    cmpw %d5,%d6
    jbeq XGETRLPOSITION_230
    tstw %d5
    jbeq XGETRLPOSITION_22A
    exg %d5,%d6
XGETRLPOSITION_22A:     /* second edge */
    addw %sp@,%d6
    jbra XGETRLPOSITION_240
XGETRLPOSITION_22E:     /* left-to-right line: swap */
    exg %d5,%d6
XGETRLPOSITION_230:     /* both positions; equal: one caret */
    addw %sp@,%d5
    addw %d5,%a3@(18)
    addw %d5,%a3@(22)
    addw %sp@,%d6
    cmpw %d5,%d6
    jbeq XGETRLPOSITION_272
XGETRLPOSITION_240:     /* split caret: the two half-height rectangles, the second into ExpandMem */
    movew %a3@(20),%d2
    addw %a3@(16),%d2
    lsrw #1,%d2
    movew %d2,%a3@(20)
    moveal ExpandMem,%a0
    st %a0@(46)
    andiw #-256,%a0@(46)
    lea %a0@(48),%a0
    movew %a3@(20),%a0@+
    addw %fp@(-64),%d6
    movew %d6,%a0@
    subqw #1,%a0@+
    movew %fp@(-62),%a0@+
    movew %d6,%a0@
XGETRLPOSITION_272:     /* drop the saved word */
    addql #2,%sp
    rts

XGETRLPOSITION_276:     /* same direction: a single caret */
    st %fp@(-6)
    jbsr XGETRLPOSITION_2DC
    jbne XGETRLPOSITION_286
    tstb %fp@(-70)
    jbne XGETRLPOSITION_292
    jbra XGETRLPOSITION_2A0
XGETRLPOSITION_286:     /* right-to-left run */
    tstb %fp@(-70)
    jbeq XGETRLPOSITION_292
    tstb TESysJust
    jbne XGETRLPOSITION_2A0
XGETRLPOSITION_292:     /* add the run's width */
    jbsr XONSAMELINE_242
    addw %d0,%d5
    addw %d5,%a3@(18)
    addw %d5,%a3@(22)
XGETRLPOSITION_2A0:     /* return */
    rts

XGETRLPOSITION_2A2:     /* vectored: the direction of font %d1's script into bit 7 of (%a0) (ExpandMem +168) */
    moveml %d0/%d2/%a0-%a1,%sp@-
    moveal ExpandMem,%a0
    moveal %a0@(168),%a0
    jmp %a0@
XGETRLPOSITION_2B0:     /* right-to-left flag of the font's script (Font2Script, GetScript smScriptRight) */
    subqw #6,%sp
    movew %d1,%sp@-
    movel #-2113798138,%sp@-
    _ScriptUtil
    movew #6,%sp@-
    movel #-2080112628,%sp@-
    _ScriptUtil
    movel %sp@+,%d1
    moveml %sp@+,%d0/%d2/%a0-%a1
    bclr #7,%a0@
    tstb %d1
    jbeq XGETRLPOSITION_2DA
    bset #7,%a0@
XGETRLPOSITION_2DA:     /* return */
    rts

XGETRLPOSITION_2DC:     /* vectored run direction (ExpandMem +172) */
    moveal ExpandMem,%a1
    moveal %a1@(172),%a1
    jmp %a1@
XGETRLPOSITION_2E6:     /* the direction of a run: the cached byte of its style (+9) or of the record (+77), as a flag */
    moveml %d0/%a0,%sp@-	| 40822F5A
    tstw %a3@(80)
    jbpl XGETRLPOSITION_300
    movew %a0@(2),%d0
    jbsr ITEFEATUREFLAG_112
    clrw %d1
    moveb %a0@(9),%d1
    jbra XGETRLPOSITION_304
XGETRLPOSITION_300:     /* unstyled: the record's direction byte */
    moveb %a3@(77),%d1
XGETRLPOSITION_304:     /* as a flag */
    jbeq XGETRLPOSITION_308
    st %d1
XGETRLPOSITION_308:     /* restore registers, return */
    moveml %sp@+,%d0/%a0
    rts

XGETRLPOSITION_30E:     /* unstyled: one pseudo run for the whole text */
    tstw %a3@(80)
    jbmi XGETRLPOSITION_34C
    clrl %fp@(-58)
    clrl %fp@(-54)
    movew %a3@(60),%fp@(-54)
    lea %fp@(-58),%a0
    movel %a0,%fp@(-12)
    movew #1,%d2
    movew %d2,%fp@(-40)
    tstb WordRedraw
    jblt XGETRLPOSITION_33C
    st %fp@(-42)
XGETRLPOSITION_33C:     /* one entry in the order array */
    lea %fp@(-36),%a1
    movel %a1,%fp@(-16)
    clrw %fp@(-8)
    clrw %a1@
    jbra XGETRLPOSITION_354
XGETRLPOSITION_34C:     /* styled: the runs of the line */
    movew %a2@,%d0
    movew %a2@(2),%d1
    jbsr XGETRLPOSITION_36E
XGETRLPOSITION_354:     /* return */
    rts

XGETRLPOSITION_356:     /* vectored (ExpandMem +176) */
    moveal ExpandMem,%a0
    moveal %a0@(176),%a0
    jmp %a0@
XGETRLPOSITION_360:     /* format order, then the first run in display order */
    jbsr XGETRLPOSITION_36E	| 40822FD4
    jbsr XTEGETFORMATORDER_7E	| 40822FD6
    addqw #1,%fp@(-8)	| 40822FDA
    subqw #1,%d2	| 40822FDE
    rts	| 40822FE0

XGETRLPOSITION_36E:     /* vectored format order of a range (ExpandMem +180) */
    moveal ExpandMem,%a0
    moveal %a0@(180),%a0
    jmp %a0@

/* XTEGETFORMATORDER: the display order of style runs (bidirectional text). */
XTEGETFORMATORDER:
    moveq #0,%d2	| 40822FEC
    jbsr ITEFEATUREFLAG_9E	| 40822FEE
    movel %a0,%fp@(-12)	| 40822FF2
    jbsr ITEFEATUREFLAG_EC	| 40822FF6
    movew %d0,%d2	| 40822FFA
    movew %d2,%fp@(-40)	| 40822FFC
    jbsr XTEGETFORMATORDER_9C	| 40823000
    moveq #0,%d0	| 40823004
    jbra XTEGETFORMATORDER_20	| 40823006
XTEGETFORMATORDER_1C:   /* identity order first */
    movew %d0,%a1@+	| 40823008
    addqw #1,%d0	| 4082300A
XTEGETFORMATORDER_20:   /* loop; mixed directions: _FormatOrder through the Script Manager */
    dbf %d2,XTEGETFORMATORDER_1C	| 4082300C
    movew %fp@(-40),%d2	| 40823010
    clrw %fp@(-8)	| 40823014
    st %fp@(-42)	| 40823018
    tstb WordRedraw	| 4082301C
    jbge XTEGETFORMATORDER_7C	| 40823020
    sf %fp@(-42)	| 40823022
    movel %a0,%sp@-	| 40823026
    moveal %a3@(74),%a0	| 40823028
    moveal %a0@,%a0	| 4082302C
    cmpiw #1,%a0@	| 4082302E
    jbeq XTEGETFORMATORDER_7A	| 40823032
    moveal %sp@+,%a0	| 40823034
    moveml %d2-%d4,%sp@-	| 40823036
    movel %fp@(-16),%sp@-	| 4082303A
    clrw %sp@-	| 4082303E
    subqw #1,%d0	| 40823040
    movew %d0,%sp@-	| 40823042
    moveb TESysJust,%sp@-	| 40823044
    pea %pc@(XTEGETFORMATORDER_E2)	| 40823048
    movel %a0,%fp@(-50)	| 4082304C
    movel %a3,%fp@(-46)	| 40823050
    pea %fp@(-50)	| 40823054
    movel #-2146238468,%sp@-	| 40823058
    _ScriptUtil	| 4082305E
    moveml %sp@+,%d2-%d4	| 40823060
    jbra XTEGETFORMATORDER_7C	| 40823064
XTEGETFORMATORDER_7A:   /* restore %a0 */
    moveal %sp@+,%a0	| 40823066
XTEGETFORMATORDER_7C:   /* return */
    rts	| 40823068

XTEGETFORMATORDER_7E:   /* the next run in display order: its style run entry */
    moveal %fp@(-12),%a0
    movew %fp@(-8),%d0
    lslw #1,%d0
    moveal %fp@(-16),%a1
    movew %a1@(0x0,%d0:w),%d0
    movew %d0,%fp@(-38)
    lslw #2,%d0
    lea %a0@(0x0,%d0:w),%a0
    rts

XTEGETFORMATORDER_9C:   /* the order array: on the stack up to 10 runs, else a locked handle (flag at ExpandMem +56) */
    moveml %d2/%a0,%sp@-
    moveal ExpandMem,%a0
    sf %a0@(56)
    lea %fp@(-36),%a1
    movel %a1,%fp@(-16)
    cmpiw #10,%d2
    jbls XTEGETFORMATORDER_D4
    moveal ExpandMem,%a0
    st %a0@(56)
    lslw #1,%d2
    movel %d2,%d0
    .short  0xA322	| 408230AE _NewHandle (flags 0x0300)
    jbne XTEGETFORMATORDER_E0
    _HLock
    jbne XTEGETFORMATORDER_DA
    moveal %a0@,%a1
    movel %a0,%fp@(-36)
    movel %a0@,%fp@(-16)
XTEGETFORMATORDER_D4:   /* restore registers, return */
    moveml %sp@+,%d2/%a0
    rts
XTEGETFORMATORDER_DA:   /* dispose and fail: system error */
    movel %d0,%sp@-
    _DisposHandle
    movel %sp@+,%d0
XTEGETFORMATORDER_E0:   /* _SysError */
    _SysError
XTEGETFORMATORDER_E2:   /* DirProc for FormatOrder: the direction of run %d0 */
    linkw %fp,#0
    moveml %d0-%d1/%a1/%a3,%sp@-
    moveal %fp@(8),%a0
    moveal %a0@+,%a1
    moveal %a0@,%a3
    movew %fp@(12),%d0
    lslw #2,%d0
    moveal %a1,%a0
    addaw %d0,%a0
    jbsr XGETRLPOSITION_2DC
    moveb %d1,%fp@(14)
    moveml %sp@+,%d0-%d1/%a1/%a3
    unlk %fp
    moveal %sp@+,%a0
    addql #6,%sp
    jmp %a0@
    .short  0x4E75	| 408230FC

XTEGETFORMATORDER_112:  /* free the order array if it was allocated */
    moveal ExpandMem,%a0
    tstb %a0@(56)
    jbeq XTEGETFORMATORDER_126
    sf %a0@(56)
    moveal %fp@(-36),%a0
    _DisposHandle
XTEGETFORMATORDER_126:  /* return */
    rts

/* DOHILITE: highlight a range. */
DOHILITE:
    jbsr DOMEASURE_C6
    jbsr PREPLINE_14
    jbsr LINERECT
    movel %a4,%sp@-
    linkw %fp,#-10
    moveal %a2,%a1
    cmpw %d3,%d4
    jbeq DOHILITE_9C
    jbhi DOHILITE_2A
    exg %d3,%d4
    movew %d3,%d0
    lea %a3@(96),%a2
    jbsr PREPLINE_42
    jbra DOHILITE_36
DOHILITE_2A:            /* the line of the end */
    cmpw %a2@(2),%d4
    jbeq DOHILITE_36
    movew %d4,%d0
    jbsr PREPLINE_42
DOHILITE_36:            /* one line: hilite it */
    exg %a1,%a2
    cmpal %a1,%a2
    jbne DOHILITE_40
    jbsr DOHILITE_A4
    jbra DOHILITE_9C
DOHILITE_40:            /* several lines: first line to its end, last line, then the block of lines between */
    movel %a1,%fp@(-10)
    movel %a2,%fp@(-6)
    movew %d4,%fp@(-2)
    movew %a2@(2),%d4
    jbsr DOHILITE_A4
    movew %fp@(-2),%d4
    moveal %fp@(-10),%a2
    movew %a2@,%d3
    moveal %fp@(-6),%a1
    unlk %fp
    movew %a3@(20),%sp@-
    movel %a1,%sp@-
    jbsr LINERECT
    jbsr DOHILITE_A4
    moveal %sp@+,%a1
    movew %a1@(2),%d2
    cmpw %a2@,%d2
    jbeq DOHILITE_98
    movew %a3@(16),%a3@(20)
    movew %sp@+,%a3@(16)
    movew #-32766,%a3@(18)
    movew #32766,%a3@(22)
    movel %a3@(86),%d0
    jbsr DOMEASURE_162
    jbra DOHILITE_9E
DOHILITE_98:            /* drop the saved word */
    addqw #2,%sp
    jbra DOHILITE_9E
DOHILITE_9C:            /* return */
    unlk %fp
DOHILITE_9E:            /* return */
    moveal %sp@+,%a4
    jbra DODRAW_112

DOHILITE_A4:            /* vectored hilite of a line part (ExpandMem +192) */
    moveal ExpandMem,%a4
    moveal %a4@(192),%a4
    jmp %a4@

/* XONSAMELINE: are two offsets on the same line?. */
XONSAMELINE:
    linkw %fp,#-114	| 408231C2
    moveml %d3-%d4/%d7-%a1,%sp@-	| 408231C6
    moveq #0,%d5
    moveq #0,%d2
    clrw %fp@(-84)
    sf %fp@(-42)
    clrw %fp@(-92)
    sf %fp@(-6)
    clrw %fp@(-86)
    clrl %fp@(-90)
    clrl %fp@(-114)
    movew %a3@(18),%fp@(-64)
    movew %a3@(22),%fp@(-60)
    movew %fp@(-64),%fp@(-98)
    movew %fp@(-60),%fp@(-100)
    tstw %a3@(80)
    jbpl XONSAMELINE_F0
    movew %d3,%d0
    jbsr ITEFEATUREFLAG_9E
    movel %a0,%fp@(-78)
    jbsr XCURSORMOVEMENT_234
    cmpw %d0,%d4
    jbhi XONSAMELINE_60
    movel %a0,%fp@(-82)
    jbra XONSAMELINE_72
XONSAMELINE_60:         /* run of the end offset */
    movew %d4,%d0
    jbsr ITEFEATUREFLAG_9E
    movel %a0,%fp@(-82)
    cmpw %a0@,%d4
    jbne XONSAMELINE_72
    subql #4,%fp@(-82)
XONSAMELINE_72:         /* the format order of the line */
    movew %a2@,%d0
    movew %a2@(2),%d1
    jbsr XGETRLPOSITION_36E
XONSAMELINE_7C:         /* find the display positions of the start and end runs */
    jbsr XTEGETFORMATORDER_7E
    addqw #1,%fp@(-8)
    subqw #1,%d2
    cmpal %fp@(-78),%a0
    jbne XONSAMELINE_9C
    movew %fp@(-38),%fp@(-88)
    tstb %fp@(-86)
    jbne XONSAMELINE_B4
    st %fp@(-85)
XONSAMELINE_9C:         /* the end run */
    cmpal %fp@(-82),%a0
    jbne XONSAMELINE_7C
    movew %fp@(-38),%fp@(-90)
    tstb %fp@(-85)
    jbne XONSAMELINE_B4
    st %fp@(-86)
    jbra XONSAMELINE_7C
XONSAMELINE_B4:         /* both found; same run? */
    movew %fp@(-40),%d2
    clrw %fp@(-8)
    movew %fp@(-88),%d0
    cmpw %fp@(-90),%d0
    jbne XONSAMELINE_CA
    st %fp@(-91)
XONSAMELINE_CA:         /* per run in display order: hilite its part of the range */
    jbsr XTEGETFORMATORDER_7E
    jbsr XONSAMELINE_178
    tstb %fp@(-6)
    jbne XONSAMELINE_106
    addqw #1,%fp@(-8)
    tstb %fp@(-42)
    jbne XONSAMELINE_E8
    subqw #1,%d2
    jbeq XONSAMELINE_106
    jbra XONSAMELINE_CA
XONSAMELINE_E8:         /* next run */
    addql #4,%a0
    subqw #1,%d2
    jbne XONSAMELINE_CA
    jbra XONSAMELINE_106
XONSAMELINE_F0:         /* unstyled: one pseudo run */
    clrl %fp@(-58)
    clrw %fp@(-54)
    movew %a3@(60),%fp@(-54)
    lea %fp@(-58),%a0
    jbsr XONSAMELINE_316
XONSAMELINE_106:        /* flush a pending rectangle */
    tstb %fp@(-92)
    jbeq XONSAMELINE_114
    jbsr XONSAMELINE_2A4
    sf %fp@(-92)
XONSAMELINE_114:        /* hilite out to the left edge */
    tstb %fp@(-113)
    jbeq XONSAMELINE_136
    movew %fp@(-64),%a3@(22)
    movew #-32766,%a3@(18)
    movel %a0,%sp@-
    movel %a3@(86),%d0
    jbsr DOMEASURE_162
    sf %fp@(-113)
    moveal %sp@+,%a0
XONSAMELINE_136:        /* hilite out to the right edge */
    tstb %fp@(-114)
    jbeq XONSAMELINE_16C
    tstw %a3@(80)
    jbmi XONSAMELINE_14C
    jbsr XONSAMELINE_242
    movew %d0,%a3@(18)
    jbra XONSAMELINE_152
XONSAMELINE_14C:        /* from the last run's end */
    movew %fp@(-100),%a3@(18)
XONSAMELINE_152:        /* to the right edge */
    movew %fp@(-64),%d0
    addw %d0,%a3@(18)
    movew #32766,%a3@(22)
    movel %a3@(86),%d0
    jbsr DOMEASURE_162
    sf %fp@(-114)
XONSAMELINE_16C:        /* free the format order */
    jbsr XTEGETFORMATORDER_112
    moveml %sp@+,%d3-%d4/%d7-%a1
    unlk %fp
    rts

XONSAMELINE_178:        /* vectored per-run hilite (ExpandMem +196) */
    moveal ExpandMem,%a1
    moveal %a1@(196),%a1
    jmp %a1@
XONSAMELINE_182:        /* per run: before, inside or after the selected runs */
    movew %fp@(-38),%d0	| 40823344
    cmpw %fp@(-88),%d0	| 40823348
    jbeq XONSAMELINE_1A0	| 4082334C
    tstb %fp@(-91)	| 4082334E
    jbne XONSAMELINE_230	| 40823352
    cmpw %fp@(-90),%d0	| 40823356
    jbeq XONSAMELINE_1B6	| 4082335A
    jblt XONSAMELINE_1D8	| 4082335C
    jbra XONSAMELINE_230	| 4082335E
XONSAMELINE_1A0:        /* the start run */
    movew %d3,%fp@(-94)	| 40823362
    movew %d4,%fp@(-96)	| 40823366
    tstb %fp@(-91)	| 4082336A
    jbne XONSAMELINE_1C0	| 4082336E
    jbsr XCURSORMOVEMENT_234	| 40823370
    movew %d0,%d4	| 40823374
    jbra XONSAMELINE_1CC	| 40823376
XONSAMELINE_1B6:        /* the end run */
    movew %d3,%fp@(-94)	| 40823378
    movew %d4,%fp@(-96)	| 4082337C
    movew %a0@,%d3	| 40823380
XONSAMELINE_1C0:        /* last run */
    tstb %fp@(-42)	| 40823382
    jbne XONSAMELINE_1C8	| 40823386
    jbra XONSAMELINE_1CC	| 40823388
XONSAMELINE_1C8:        /* done */
    st %fp@(-6)	| 4082338A
XONSAMELINE_1CC:        /* flush the pending rectangle */
    tstb %fp@(-92)
    jbeq XONSAMELINE_224
    jbsr XONSAMELINE_2A4
    jbra XONSAMELINE_224
XONSAMELINE_1D8:        /* a whole run inside the range */
    cmpw %fp@(-88),%d0	| 4082339A
    jbhi XONSAMELINE_1F8	| 4082339E
    jbsr XONSAMELINE_242	| 408233A0
    addw %d0,%fp@(-84)	| 408233A2
    tstb %fp@(-92)
    jbeq XONSAMELINE_23C
    jbsr XONSAMELINE_2A4
    movew %fp@(-84),%d0
    addw %d0,%fp@(-98)
    jbra XONSAMELINE_23C
XONSAMELINE_1F8:        /* merge it into the pending rectangle */
    movew %a0@,%d0	| 408233BA
    movew %a0@(4),%d1	| 408233BC
    jbsr XONSAMELINE_2D6	| 408233C0
    tstb %fp@(-92)	| 408233C4
    jbne XONSAMELINE_218	| 408233C8
    st %fp@(-92)	| 408233CA
    movew %fp@(-84),%fp@(-98)	| 408233CE
    movew %fp@(-84),%fp@(-100)	| 408233D4
XONSAMELINE_218:        /* extend */
    jbsr XONSAMELINE_242	| 408233DA
    addw %d0,%fp@(-84)	| 408233DC
    addw %d0,%fp@(-100)	| 408233E0
    jbra XONSAMELINE_23C	| 408233E4
XONSAMELINE_224:        /* hilite the partial run */
    jbsr XONSAMELINE_316
    movew %fp@(-94),%d3
    movew %fp@(-96),%d4
XONSAMELINE_230:        /* outside: skip its width */
    jbsr XONSAMELINE_242
    addw %d0,%fp@(-84)
    movew %fp@(-84),%fp@(-100)
XONSAMELINE_23C:        /* running width */
    movew %fp@(-84),%d5
    rts

XONSAMELINE_242:        /* vectored run width (ExpandMem +200) */
    moveal ExpandMem,%a1
    moveal %a1@(200),%a1
    jmp %a1@
XONSAMELINE_24C:        /* the width of the part of run %a0 that lies on the line */
    moveml %d2/%a0/%a4,%sp@-	| 4082340E
    moveal %a0,%a1	| 40823412
    moveal %a3@(62),%a0	| 40823414
    moveal %a0@,%a0	| 40823418
    addaw %a1@,%a0	| 4082341A
    moveal %a0,%a4	| 4082341C
    moveal %a1,%a0	| 4082341E
    moveq #0,%d1	| 40823420
    movew %a2@,%d0	| 40823422
    cmpw %a0@,%d0	| 40823424
    jbls XONSAMELINE_26C	| 40823426
    subw %a0@,%d0	| 40823428
    addaw %d0,%a4	| 4082342A
    movew %d0,%d1	| 4082342C
XONSAMELINE_26C:        /* the run end, pinned to the line */
    jbsr XCURSORMOVEMENT_234	| 4082342E
    cmpw %a2@(2),%d0	| 40823432
    jbls XONSAMELINE_27A	| 40823436
    movew %a2@(2),%d0	| 40823438
XONSAMELINE_27A:        /* styled: set the run's style */
    subw %a0@,%d0	| 4082343C
    subw %d1,%d0	| 4082343E
    tstw %a3@(80)	| 40823440
    jbpl XONSAMELINE_290	| 40823444
    moveml %d0-%d1,%sp@-	| 40823446
    jbsr ITESETSTYLE_2C0	| 4082344A
    moveml %sp@+,%d0-%d1	| 4082344E
XONSAMELINE_290:        /* its width (_TextWidth) */
    subql #2,%sp	| 40823452
    movel %a4,%sp@-	| 40823454
    clrw %sp@-	| 40823456
    movew %d0,%sp@-	| 40823458
    _TextWidth	| 4082345A
    moveq #0,%d0	| 4082345C
    movew %sp@+,%d0	| 4082345E
    moveml %sp@+,%d2/%a0/%a4	| 40823460
    rts	| 40823464

XONSAMELINE_2A4:        /* hilite the pending rectangle through the hilite hook */
    moveml %d0/%a0,%sp@-
    movew %fp@(-64),%a3@(18)
    movew %fp@(-98),%d0
    addw %d0,%a3@(18)
    movew %fp@(-60),%a3@(22)
    movew %fp@(-100),%d0
    addw %d0,%a3@(22)
    movel %a3@(86),%d0
    jbsr DOMEASURE_162
    sf %fp@(-92)
    moveml %sp@+,%d0/%a0
    rts
XONSAMELINE_2D6:        /* vectored: mark line-end hilites (ExpandMem +204) */
    moveal ExpandMem,%a1	| 40823498
    moveal %a1@(204),%a1	| 4082349C
    jmp %a1@	| 408234A0
XONSAMELINE_2E0:        /* range reaches the line start: hilite to that edge */
    cmpw %a2@,%d0	| 408234A2
    jbhi XONSAMELINE_2F8	| 408234A4
    cmpw %a2@,%d1	| 408234A6
    jbcs XONSAMELINE_2F8	| 408234A8
    tstb TESysJust	| 408234AA
    jbne XONSAMELINE_2F4	| 408234AE
    st %fp@(-113)	| 408234B0
    jbra XONSAMELINE_2F8	| 408234B4
XONSAMELINE_2F4:        /* right edge */
    st %fp@(-114)	| 408234B6
XONSAMELINE_2F8:        /* range reaches the line end */
    cmpw %a2@(2),%d0	| 408234BA
    jbhi XONSAMELINE_314	| 408234BE
    cmpw %a2@(2),%d1	| 408234C0
    jbcs XONSAMELINE_314	| 408234C4
    tstb TESysJust	| 408234C6
    jbne XONSAMELINE_310	| 408234CA
    st %fp@(-114)	| 408234CC
    jbra XONSAMELINE_314	| 408234D0
XONSAMELINE_310:        /* left edge */
    st %fp@(-113)	| 408234D2
XONSAMELINE_314:        /* return */
    rts	| 408234D6

XONSAMELINE_316:        /* partial run: set the style */
    tstw %a3@(80)
    jbpl XONSAMELINE_320
    jbsr ITESETSTYLE_2C0
XONSAMELINE_320:        /* the run's text, its part of the range */
    movel %a4,%sp@-
    lea %fp@(-112),%a4
    moveml %d2-%d4/%a0-%a1,%sp@-
    moveal %a0,%a1
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    addaw %a1@,%a0
    moveq #0,%d1
    movew %a2@,%d0
    cmpw %a1@,%d0
    jbls XONSAMELINE_342
    subw %a1@,%d0
    addaw %d0,%a0
    movew %d0,%d1
XONSAMELINE_342:        /* run end, pinned to the line */
    movel %a0,%sp@-
    movel %a0,%sp@-
    moveal %a1,%a0
    jbsr XCURSORMOVEMENT_234
    moveal %sp@+,%a0
    cmpw %a2@(2),%d0
    jbls XONSAMELINE_358
    movew %a2@(2),%d0
XONSAMELINE_358:        /* offsets within the run; the script's HiliteText for the pixel ranges */
    subw %a1@,%d0
    subw %d1,%d0
    movew %d0,%sp@-
    subw %a1@,%d3
    subw %d1,%d3
    movew %d3,%sp@-
    subw %a1@,%d4
    subw %d1,%d4
    movew %d4,%sp@-
    movel %a4,%sp@-
    movel #-2146566116,%sp@-
    _ScriptUtil
    moveml %sp@+,%d2-%d4/%a0-%a1
    moveq #2,%d7
XONSAMELINE_37A:        /* hilite each non-empty range */
    movew %a4@+,%d0
    movew %a4@+,%d1
    cmpw %d0,%d1
    jbeq XONSAMELINE_388
    movel %a4,%sp@-
    jbsr XONSAMELINE_390
    moveal %sp@+,%a4
XONSAMELINE_388:        /* loop */
    dbf %d7,XONSAMELINE_37A
    moveal %sp@+,%a4
    rts

XONSAMELINE_390:        /* vectored range hilite (ExpandMem +208) */
    moveal ExpandMem,%a4
    moveal %a4@(208),%a4
    jmp %a4@
XONSAMELINE_39A:        /* hilite between two offsets of a run */
    movew %d2,%sp@-	| 4082355C
    moveml %d0-%d1/%a0-%a1,%sp@-	| 4082355E
    movew %d5,%sp@-	| 40823562
    movew #1,%d2	| 40823564
    swap %d2	| 40823568
    movew #1,%d2	| 4082356A
    jbsr XONSAMELINE_3FC	| 4082356E
    cmpw %d5,%d6	| 40823570
    jbcs XONSAMELINE_3C0	| 40823572
    addw %fp@(-60),%d5	| 40823574
    addw %sp@,%d5	| 40823578
    addw %fp@(-60),%d6	| 4082357A
    addw %sp@,%d6	| 4082357E
    jbra XONSAMELINE_3CE	| 40823580
XONSAMELINE_3C0:        /* order them */
    addw %fp@(-64),%d5	| 40823582
    addw %sp@,%d5	| 40823586
    addw %fp@(-64),%d6	| 40823588
    addw %sp@,%d6	| 4082358C
    exg %d5,%d6	| 4082358E
XONSAMELINE_3CE:        /* the rectangle; call the hilite hook */
    movew %d5,%a3@(18)	| 40823590
    movew %d6,%a3@(22)	| 40823594
    movel %a3@(86),%d0	| 40823598
    jbsr DOMEASURE_162	| 4082359C
    movew %sp@+,%d5	| 408235A0
    moveml %sp@+,%d0-%d1/%a0-%a1	| 408235A2
    movew %a2@,%d2	| 408235A6
    cmpw %a0@,%d2	| 408235A8
    jbls XONSAMELINE_3F0	| 408235AA
    addw %d2,%d0	| 408235AC
    addw %d2,%d1	| 408235AE
    jbra XONSAMELINE_3F4	| 408235B0
XONSAMELINE_3F0:        /* offsets relative to the run */
    addw %a0@,%d0	| 408235B2
    addw %a0@,%d1	| 408235B4
XONSAMELINE_3F4:        /* line-end checks */
    jbsr XONSAMELINE_2D6	| 408235B6
    movew %sp@+,%d2	| 408235BA
    rts	| 408235BC
XONSAMELINE_3FC:        /* vectored offset-to-pixel in a run (ExpandMem +212) */
    moveal ExpandMem,%a1	| 408235BE
    moveal %a1@(212),%a1	| 408235C2
    jmp %a1@	| 408235C6
XONSAMELINE_406:        /* pixel positions of two offsets in a run, through the width hook */
    moveml %d0-%d4/%a0-%a2/%a4,%sp@-	| 408235C8
    moveal ExpandMem,%a4	| 408235CC
    movel %d2,%a4@(58)	| 408235D0
    moveal %a0,%a1	| 408235D4
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    addaw %a1@,%a0
    movew %d1,%sp@-
    movew %d0,%d1
    moveq #0,%d4
    movew %a2@,%d0
    cmpw %a1@,%d0
    jbls XONSAMELINE_42E
    subw %a1@,%d0
    addaw %d0,%a0
    movew %d0,%d4
XONSAMELINE_42E:        /* run end, pinned to the line */
    movel %a0,%sp@-
    moveal %a1,%a0
    jbsr XCURSORMOVEMENT_234
    moveal %sp@+,%a0
    cmpw %a2@(2),%d0
    jbls XONSAMELINE_442
    movew %a2@(2),%d0
XONSAMELINE_442:        /* pixel position through the width hook */
    subw %a1@,%d0
    subw %d4,%d0
    moveq #0,%d2
    moveal ExpandMem,%a4
    lea %a4@(58),%a4
    movew %a4@+,%d2
    swap %d2
    moveml %d0/%a0-%a1/%a4,%sp@-
    jbsr DOSEARCH_162
    movew %d1,%d5
    moveml %sp@+,%d0/%a0-%a1/%a4
    movew %sp@+,%d1
    moveq #0,%d2
    movew %a4@,%d2
    swap %d2
    jbsr DOSEARCH_162
    movew %d1,%d6
    moveml %sp@+,%d0-%d4/%a0-%a2/%a4
    rts

/* CHKBOUNDS: pin a position to the text. */
CHKBOUNDS:
    movew %a2@,%d0
    movew %a2@(2),%d1
    tstw %a3@(80)
    jbpl CHKBOUNDS_56
    tstw TESysJust
    jbeq CHKBOUNDS_56
    tstb WordRedraw
    jbge CHKBOUNDS_30
    jbsr XGETRLPOSITION_356
    jbeq CHKBOUNDS_3C
    subqw #1,%d2
    movew %d2,%fp@(-8)
    movel %a0,%sp@-
    jbsr XTEGETFORMATORDER_7E
    movew %a0@,%d1
    moveal %sp@+,%a0
    jbra CHKBOUNDS_4E
CHKBOUNDS_30:           /* the runs of the line; the first and last */
    jbsr ITEFEATUREFLAG_9E
    jbsr ITEFEATUREFLAG_EC
    subqw #1,%d0
    jbne CHKBOUNDS_44
CHKBOUNDS_3C:           /* one run */
    movew %a2@,%d0
    movew %a2@(2),%d1
    jbra CHKBOUNDS_56
CHKBOUNDS_44:           /* the last run's start */
    subqw #1,%d0
    lslw #2,%d0
    negw %d0
    movew %a0@(0x0,%d0:w),%d1
CHKBOUNDS_4E:           /* the first run's start */
    movew %a2@,%d0
    cmpw %a0@,%d0
    jbcc CHKBOUNDS_56
    movew %a0@,%d0
CHKBOUNDS_56:           /* range starts at the line start: from the far left */
    cmpw %d0,%d3
    jbne CHKBOUNDS_60
    movew #-32766,%a3@(18)
CHKBOUNDS_60:           /* ends at the line end: to the far right */
    cmpw %d1,%d4
    jbne CHKBOUNDS_6A
    movew #32766,%a3@(22)
CHKBOUNDS_6A:           /* free the format order */
    jbsr XTEGETFORMATORDER_112
    rts
CHKBOUNDS_70:           /* next line: move the line rectangle down by its height */
    movew %a3@(20),%a3@(16)
    jbsr LINERECT_A4
    addw %d1,%a3@(20)
    addw %d0,%d0
    lea %a3@(0x60,%d0:w),%a2
    movew %a3@(2),%a3@(18)
    jbsr LINERECT_24
    rts

CHKBOUNDS_8E:           /* the line index of %a2 */
    lea %a3@(96),%a0
    movel %a2,%d0
    subl %a0,%d0
    asrl #1,%d0
    rts

/* LINERECT: the rectangle of a line. */
LINERECT:
    jbsr CHKBOUNDS_8E
    movew %d0,%d1
    moveq #0,%d0
    jbsr LINERECT_64
    lea %a3@(8),%a0
    lea %a3@(24),%a1
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    addw %d0,%a1@
    movew %a1@,%a1@(4)
    movew %d1,%d0
    jbsr LINERECT_A4
    addw %d1,%a1@(4)

LINERECT_24:            /* the left edge for the justification */
    movew %a3@(58),%sp@-
    jbne LINERECT_30
    movew TESysJust,%sp@
    jbeq LINERECT_50
LINERECT_30:            /* centered or right: the width of the line */
    cmpiw #-2,%sp@
    jbeq LINERECT_50
    jbsr LINERECT_CA
    movew %a3@(6),%d1
    subw %a3@(2),%d1
    subw %d0,%d1
    subqw #1,%d1
    tstw %sp@
    jbmi LINERECT_4C
    asrw #1,%d1
LINERECT_4C:            /* right */
    addw %d1,%a3@(18)
LINERECT_50:            /* the caret one pixel in; return */
    addqw #1,%a3@(18)
    movew %a3@(18),%a3@(22)
    movew %a3@(18),%fp@(-4)
    addql #2,%sp
    rts

LINERECT_64:            /* the height of lines %d0..%d1: fixed line height times count */
    moveml %d1-%d2,%sp@-
    subw %d0,%d1
    jbeq LINERECT_78
    movew %a3@(24),%d2
    jbpl LINERECT_78
    tstw %a3@(80)
    jbmi LINERECT_7C
LINERECT_78:            /* fixed */
    muluw %d1,%d2
    jbra LINERECT_9C
LINERECT_7C:            /* variable: add the line heights from the line-height table */
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    lslw #2,%d0
    addaw %d0,%a0
    moveq #0,%d2
LINERECT_8E:            /* loop */
    movew %a0@,%d0
    andiw #32767,%d0
    addw %d0,%d2
    addqw #4,%a0
    subqw #1,%d1
    jbne LINERECT_8E
LINERECT_9C:            /* return it */
    movel %d2,%d0
    moveml %sp@+,%d1-%d2
    rts

LINERECT_A4:            /* one line's height */
    movew %a3@(24),%d1
    jbpl LINERECT_C8
    tstw %a3@(80)
    jbpl LINERECT_C8
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    movew %d0,%d1
    lslw #2,%d1
    movew %a0@(0x0,%d1:w),%d1
    andiw #32767,%d1
LINERECT_C8:            /* return */
    rts

LINERECT_CA:            /* the line width (low-memory vector 0x7F4) */
    movew %a2@,%d6
    movew %a2@(2),%d7
    moveal ExpandMem,%a0
    st %a0@(62)
    movel 0x7f4,%sp@-
    rts

/* XTRIMMEASURE: width without trailing spaces. */
trap_XTRIMMEASURE:
XTRIMMEASURE:
    tstb WordRedraw
    jbmi MEASUREIT
    cmpw %a3@(60),%d6
    jbeq MEASUREIT_52
    cmpw %d6,%d7
    jbls MEASUREIT_52
    moveal %a3@(62),%a0
    moveal %a0@,%a0
XTRIMMEASURE_16:        /* back over trailing spaces and control characters */
    subqw #1,%d7
    cmpw %d6,%d7
    jbeq XTRIMMEASURE_24
    cmpib #32,%a0@(0x0,%d7:w)
    jbls XTRIMMEASURE_16
XTRIMMEASURE_24:        /* the last visible character */
    addqw #1,%d7

/* MEASUREIT: measure text. */
MEASUREIT:
    cmpw %d6,%d7
    jbls MEASUREIT_52
    moveml %d2/%d4/%d6,%sp@-
    andl %pc@(XFINDWORD_17C),%d6
    tstw %a3@(80)
    jbmi MEASUREIT_1A
    movew %d7,%d0
    jbsr MEASUREIT_56
    movew %d1,%d0
    jbra MEASUREIT_44
MEASUREIT_1A:           /* styled: per style run of the range */
    moveq #0,%d4
    movew %d6,%d0
    jbsr ITEFEATUREFLAG_9E
    movew %d7,%d1
    jbsr ITEFEATUREFLAG_EC
    movew %d0,%d2
MEASUREIT_2A:           /* set the run's style, measure it, add */
    jbsr ITESETSTYLE_2C0
    jbsr XCURSORMOVEMENT_234
    addqw #4,%a0
    movew %d2,%sp@-
    jbsr MEASUREIT_56
    addw %d1,%d4
    movew %sp@+,%d2
    movew %a0@,%d6
    subqw #1,%d2
    jbne MEASUREIT_2A
    movew %d4,%d0
MEASUREIT_44:           /* restore registers */
    moveml %sp@+,%d2/%d4/%d6
    moveal ExpandMem,%a1
    sf %a1@(62)
    rts
MEASUREIT_52:           /* empty: 0 */
    moveq #0,%d0
    rts

MEASUREIT_56:           /* vectored measure (ExpandMem +184) */
    moveal ExpandMem,%a1
    moveal %a1@(184),%a1
    jmp %a1@

/* XGETWIDTH: width of a text range. */
XGETWIDTH:
    tstw %a3@(80)	| 40823836
    jbpl XGETWIDTH_E	| 4082383A
    moveal %a3@(74),%a1	| 4082383C
    moveal %a1@,%a1	| 40823840
    subal %a1,%a0	| 40823842
XGETWIDTH_E:            /* the run's text, clipped to the line */
    movel %a0,%sp@-	| 40823844
    moveal %a3@(62),%a0	| 40823846
    moveal %a0@,%a0	| 4082384A
    addaw %d6,%a0	| 4082384C
    movew %d7,%d1	| 4082384E
    cmpw %a2@(2),%d0	| 40823850
    jbls XGETWIDTH_24	| 40823854
    movew %a2@(2),%d0	| 40823856
XGETWIDTH_24:           /* offsets within the run; whole run or a plain measure: _TextWidth */
    subw %d6,%d0	| 4082385A
    subw %d6,%d1	| 4082385C
    jblt XGETWIDTH_38	| 4082385E
    cmpw %d0,%d1	| 40823860
    jbcc XGETWIDTH_38	| 40823862
    moveal ExpandMem,%a1	| 40823864
    tstb %a1@(62)	| 40823868
    jbeq XGETWIDTH_46	| 4082386C
XGETWIDTH_38:           /* _TextWidth of the part */
    clrw %sp@-	| 4082386E
    movel %a0,%sp@-	| 40823870
    clrw %sp@-	| 40823872
    movew %d0,%sp@-	| 40823874
    _TextWidth	| 40823876
    movew %sp@+,%d1	| 40823878
    jbra XGETWIDTH_4E	| 4082387A
XGETWIDTH_46:           /* else the script's Char2Pixel (width hook) */
    moveq #1,%d2	| 4082387C
    swap %d2	| 4082387E
    jbsr DOSEARCH_162	| 40823880
XGETWIDTH_4E:           /* styled: the run pointer back to an absolute address */
    moveal %sp@+,%a0	| 40823884
    tstw %a3@(80)	| 40823886
    jbpl XGETWIDTH_5E	| 4082388A
    moveal %a3@(74),%a1	| 4082388C
    moveal %a1@,%a1	| 40823890
    addal %a1,%a0	| 40823892
XGETWIDTH_5E:           /* return */
    rts	| 40823894
XGETWIDTH_60:           /* through the low-memory vector at 0x79C */
    movel 0x79c,%sp@-
    rts

/* VCHAR2PIXEL: vectored: the pixel position of a character offset. */
trap_VCHAR2PIXEL:
VCHAR2PIXEL:
    movel %d3,%sp@-
    tstb TESysJust
    jbeq VCHAR2PIXEL_8C
    moveml %d0/%d2/%a0-%a1,%sp@-
    movew %d1,%sp@-
    tstb %a3@(80)
    jbpl VCHAR2PIXEL_2E
    moveal %a3@(62),%a1
    moveal %a1@,%a1
    subal %a1,%a0
    movew %a0,%d0
    addw %sp@,%d0
    movew %d0,%d3
    jbsr ITEFEATUREFLAG_9E
    jbsr XGETRLPOSITION_2DC
    jbra VCHAR2PIXEL_4A
VCHAR2PIXEL_2E:         /* the script of the character's font (FontScript, GetScript smScriptRight) */
    movew %d1,%d3
    addw %a2@,%d3
    subqw #6,%sp
    movel #-2113929216,%sp@-
    _ScriptUtil
    movew #6,%sp@-
    movel #-2080112628,%sp@-
    _ScriptUtil
    movel %sp@+,%d1
VCHAR2PIXEL_4A:         /* run direction differs from the line: at either end of the line? */
    cmpb TESysJust,%d1
    jbeq VCHAR2PIXEL_86
    movew %sp@+,%d1
    moveml %sp@+,%d0/%d2/%a0-%a1
    cmpw %a2@,%d3
    jbeq VCHAR2PIXEL_60
    cmpw %a2@(2),%d3
    jbne VCHAR2PIXEL_8C
VCHAR2PIXEL_60:         /* leading or trailing edge */
    swap %d2
    cmpiw #0,%d2
    jbne VCHAR2PIXEL_6E
    cmpw %a2@,%d3
    jbeq VCHAR2PIXEL_72
    jbra VCHAR2PIXEL_82
VCHAR2PIXEL_6E:         /* trailing edge at the line start */
    cmpw %a2@,%d3
    jbeq VCHAR2PIXEL_82
VCHAR2PIXEL_72:         /* the full width */
    subql #2,%sp
    movel %a0,%sp@-
    clrw %sp@-
    movew %d0,%sp@-
    _TextWidth
    moveq #0,%d1
    movew %sp@+,%d1
    jbra VCHAR2PIXEL_A4
VCHAR2PIXEL_82:         /* 0 */
    moveq #0,%d1
    jbra VCHAR2PIXEL_A4
VCHAR2PIXEL_86:         /* same direction */
    movew %sp@+,%d1
    moveml %sp@+,%d0/%d2/%a0-%a1
VCHAR2PIXEL_8C:         /* the script's Char2Pixel */
    clrw %sp@-
    movel %a0,%sp@-
    movew %d0,%sp@-
    movew %d2,%sp@-
    movew %d1,%sp@-
    swap %d2
    movew %d2,%sp@-
    movel #-2113142762,%sp@-
    _ScriptUtil
    movew %sp@+,%d1
VCHAR2PIXEL_A4:         /* return the position */
    movel %sp@+,%d3
    rts

/* RANGERECT: rectangle of a range. */
RANGERECT:
    cmpw %a2@,%d3
    jbhi RANGERECT_18
    cmpw %a2@(2),%d4
    jbcs RANGERECT_18
    movew %a2@,%d6
    movew %d4,%d7
    jbsr MEASUREIT
    addw %d0,%a3@(22)
    jbra RANGERECT_28
RANGERECT_18:           /* range inside the line: measure both ends */
    movew %d3,%d7
    jbsr DOMEASURE
    addw %d0,%a3@(18)
    movew %d4,%d7
    jbsr DOMEASURE
    addw %d0,%a3@(22)
RANGERECT_28:           /* the rectangle; unstyled: from the baseline */
    lea %a3@(16),%a1
    movew %a1@(2),%fp@(-2)
    movew %a1@(2),Scratch8
    movel %a1@(4),%sp@-
    tstw %a3@(80)
    jbmi RANGERECT_4C
    movew %a3@(24),%d0
    subw %a3@(26),%d0
    subw %d0,%sp@
RANGERECT_4C:           /* _MoveTo */
    _MoveTo
    rts

/* DOMEASURE: measure. */
DOMEASURE:
    moveml %d3/%d5-%d6,%sp@-
    moveq #0,%d5
    movew %a2@,%d6
    sf %d3
    cmpw %d6,%d7
    jbcs DOMEASURE_BA
    tstw %a3@(80)
    jbpl DOMEASURE_AC
    tstb WordRedraw
    jbpl DOMEASURE_AC
    sf %fp@(-6)
    movew %a2@,%d0
    movew %a2@(2),%d1
    tstb WordRedraw
    jbge DOMEASURE_48
    jbsr XGETRLPOSITION_356
    jbge DOMEASURE_54
    jbra DOMEASURE_BA
DOMEASURE_3A:           /* next run in display order */
    jbsr XTEGETFORMATORDER_7E
    addqw #1,%fp@(-8)
    subqw #1,%d2
    jbge DOMEASURE_54
    jbra DOMEASURE_BA
DOMEASURE_48:           /* plain order: the runs from the line start */
    st %fp@(-6)
    jbsr ITEFEATUREFLAG_9E
    jbsr ITEFEATUREFLAG_EC
DOMEASURE_54:           /* the run, clipped to the line */
    movew %a0@,%d6
    jbsr XCURSORMOVEMENT_234
    cmpw %a2@,%d6
    jbhi DOMEASURE_60
    movew %a2@,%d6
DOMEASURE_60:           /* run end, clipped */
    cmpw %a2@(2),%d0
    jbls DOMEASURE_6A
    movew %a2@(2),%d0
DOMEASURE_6A:           /* is the offset in this run? */
    tstb %d3
    jbne DOMEASURE_AC
    cmpw %d6,%d7
    jbcs DOMEASURE_88
    jbeq DOMEASURE_7A
    cmpw %d0,%d7
    jbhi DOMEASURE_88
    jbne DOMEASURE_AC
DOMEASURE_7A:           /* on a direction boundary: measure the rest normally */
    jbsr XGETRLPOSITION_2DC
    cmpb TESysJust,%d1
    jbeq DOMEASURE_AC
    st %d3
    jbra DOMEASURE_90
DOMEASURE_88:           /* set the run's style */
    movew %d0,%sp@-
    jbsr ITESETSTYLE_2C0
    movew %sp@+,%d0
DOMEASURE_90:           /* measure the run, add; next run */
    moveal ExpandMem,%a1
    st %a1@(62)
    movew %d2,%sp@-
    jbsr MEASUREIT_56
    addw %d1,%d5
    movew %sp@+,%d2
    tstb %fp@(-6)
    jbeq DOMEASURE_3A
    subql #4,%a0
    jbra DOMEASURE_54
DOMEASURE_AC:           /* the offset's own run: measure up to it */
    moveal ExpandMem,%a1
    sf %a1@(62)
    jbsr MEASUREIT
    addw %d0,%d5
DOMEASURE_BA:           /* return the width */
    movew %d5,%d0
    jbsr XTEGETFORMATORDER_112
    moveml %sp@+,%d3/%d5-%d6
    rts

DOMEASURE_C6:           /* the lines that intersect the view rectangle (+8) */
    lea %a3@(8),%a0

DOMEASURE_CA:           /* the line at the top: widen %d3..%d4 to include its start */
    movew %a0@,%d0
    jbsr DOMEASURE_114
    jbge DOMEASURE_110
    addw %d0,%d0
    jblt DOMEASURE_E8
    cmpw %a3@(0x60,%d0:w),%d3
    jbcc DOMEASURE_DE
    movew %a3@(0x60,%d0:w),%d3
DOMEASURE_DE:           /* and the end */
    cmpw %a3@(0x60,%d0:w),%d4
    jbcc DOMEASURE_E8
    movew %a3@(0x60,%d0:w),%d4
DOMEASURE_E8:           /* the line at the bottom */
    movew %a0@(4),%d0
    subqw #1,%d0
    jbsr DOMEASURE_114
    addqw #1,%d0
    cmpw %a3@(94),%d0
    jbhi DOMEASURE_10E
    addw %d0,%d0
    cmpw %a3@(0x60,%d0:w),%d3
    jbcs DOMEASURE_104
    movew %a3@(0x60,%d0:w),%d3
DOMEASURE_104:          /* widen the end */
    cmpw %a3@(0x60,%d0:w),%d4
    jbcs DOMEASURE_10E
    movew %a3@(0x60,%d0:w),%d4
DOMEASURE_10E:          /* return */
    rts
DOMEASURE_110:          /* empty: no lines */
    movew %d3,%d4
    rts

DOMEASURE_114:          /* the line at vertical position %d0, compared with the line count */
    moveml %d2/%d6-%a0,%sp@-
    subw %a3@,%d0
    extl %d0
    movew %a3@(94),%d7
    jbeq DOMEASURE_15A
    movew %a3@(24),%d1
    tstw %a3@(80)
    jbpl DOMEASURE_130
    tstw %d1
    jbmi DOMEASURE_134
DOMEASURE_130:          /* fixed line height: line = offset / height */
    divsw %d1,%d0
    jbra DOMEASURE_15A
DOMEASURE_134:          /* variable: walk the line-height table */
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    moveq #0,%d1
    movew %d7,%d2
DOMEASURE_144:          /* loop: add heights until past the offset */
    movew %a0@,%d6
    andiw #32767,%d6
    addw %d6,%d1
    addqw #4,%a0
    cmpw %d1,%d0
    jblt DOMEASURE_156
    subqw #1,%d2
    jbne DOMEASURE_144
DOMEASURE_156:          /* the line number */
    movew %d7,%d0
    subw %d2,%d0
DOMEASURE_15A:          /* compare with the line count */
    cmpw %d7,%d0
    moveml %sp@+,%d2/%d6-%a0
    rts

DOMEASURE_162:          /* call the hilite hook (+86) with selRect; none: InvertRect with HiliteMode */
    pea %a3@(16)
    jbne DOMEASURE_172
    lea HiliteMode,%a0
    bclr #7,%a0@
    jbra DOMEASURE_176
DOMEASURE_172:          /* through the hook */
    moveal %d0,%a0
    jmp %a0@
DOMEASURE_176:          /* _InverRect (loop) */
    _InverRect
    rts

DOMEASURE_17A:          /* call the caret hook (+90) with selRect; none: InvertRect */
    pea %a3@(16)
    tstl %d0
    jbeq DOMEASURE_176
    moveal %d0,%a0
    jmp %a0@

DOMEASURE_186:          /* entry for TE traps: TE handle at %fp+8 */
    moveq #0,%d0

DOMEASURE_188:          /* entry: link, save registers; %d0 <> 0: TEDispatch selector, TE handle at %fp+10 */
    moveal %sp@+,%a0
    linkw %fp,#-24
    moveml %d2-%d7/%a2-%a4,%sp@-
    movel %a0,%sp@-
    tstw %d0
    jbeq DOMEASURE_1B2
    movew %fp@(8),%d0
    lea %pc@(TEXTEDIT),%a0
    addw %d0,%d0
    movew %a0@(0x0,%d0:w),%d0
    lea %a0@(0x0,%d0:w),%a0
    movel %a0,%d3
    moveal %fp@(10),%a4
    jbra DOMEASURE_1B8
DOMEASURE_1B2:          /* no selector */
    moveq #0,%d3
    moveal %fp@(8),%a4
DOMEASURE_1B8:          /* lock the TE handle, save the port, set the TE's port and clip to the view */
    moveal %a4,%a0
    _HGetState
    moveb %d0,%fp@(-2)
    pea %fp@(-6)
    _GetPort
    moveal %a4,%a0
    _HLock
    moveal %a4@,%a3
    moveal %a3@(82),%a2
    movel %a2,%sp@-
    _SetPort
    subqw #4,%sp
    _NewRgn
    movel %sp@,%fp@(-10)
    movel %sp@,%sp@-
    _GetClip
    pea %a3@(8)
    _ClipRect
    movel %a2@(28),%sp@-
    movel %sp@,%sp@-
    _SectRgn
    moveal %a3@(82),%a0
    tstw %a3@(80)
    jbmi DOMEASURE_204
    movel %a3@(74),%a0@(68)
    movel %a3@(78),%a0@(72)
DOMEASURE_204:          /* save the port's text settings, set the TE's */
    movew %a0@(68),%fp@(-14)
    bclr #7,%a0@(71)
    movew %a0@(70),%fp@(-16)
    movew %a0@(74),%fp@(-18)
    pea %fp@(-24)
    movew %a3@(78),%a0@(72)
    _GetForeColor
    moveal %a3@(62),%a0
    _HGetState
    moveb %d0,%fp@(-12)
    _HLock
    _GetHandleSize
    movew %d0,%a3@(60)
    movew %a3@(60),%d0
    movew %a3@(34),%d1
    subw %d0,%d1
    jbls DOMEASURE_24A
    movew %d0,%a3@(34)
DOMEASURE_24A:          /* order the selection */
    movew %a3@(32),%d1
    subw %a3@(34),%d1
    jbls DOMEASURE_258
    subw %d1,%a3@(32)
DOMEASURE_258:          /* the selection in %d0; the argument pointer */
    jbsr TEDISPATCH_8
    tstl %d3
    jbeq DOMEASURE_266
    moveal %d3,%a0
    lea %fp@(14),%a2
    jbra DOMEASURE_26A
DOMEASURE_266:          /* TE trap: arguments at %fp+12 */
    lea %fp@(12),%a2
DOMEASURE_26A:          /* return */
    rts

/* TEDISPATCH: _TEDispatch: the styled TextEdit selectors. */
trap_TEDispatch:
TEDISPATCH:
    moveq #1,%d0
    jbsr DOMEASURE_188
    jmp %a0@

TEDISPATCH_8:           /* the selection (%a2 -> selStart), ordered */
    lea %a3@(32),%a2
    movel %a2@,%d0
    cmpw %a2@,%d0
    jbcc TEDISPATCH_16
    swap %d0
    movel %d0,%a2@
TEDISPATCH_16:          /* return */
    rts

/* TECOPY: _TECopy. */
trap_TECopy:
TECOPY:
    jbsr DOMEASURE_186
    jbsr TEDISPATCH_8	| 40823C1C
    subw %a2@,%d0	| 40823C1E
    movew %d0,TEScrpLength	| 40823C20
    moveal %a3@(62),%a0	| 40823C24
    moveal %a0@,%a0	| 40823C28
    moveq #0,%d0	| 40823C2A
    movew %a2@,%d0	| 40823C2C
    addal %d0,%a0	| 40823C2E
    moveal TEScrpHandle,%a1	| 40823C30
    movew TEScrpLength,%d0	| 40823C34
    _PtrToXHand	| 40823C38
    tstw %a3@(80)	| 40823C3A
    jbpl TECOPY_56	| 40823C3E
    subqw #4,%sp	| 40823C40
    _ZeroScrap	| 40823C42
    addql #4,%sp	| 40823C44
    jbsr TEDISPATCH_8	| 40823C46
    jbsr TECOPY_5A	| 40823C48
    moveal %a3@(62),%a0	| 40823C4A
    moveal %a0@,%a0	| 40823C4E
    moveq #0,%d0	| 40823C50
    lea %a3@(32),%a2	| 40823C52
    movew %a2@,%d0	| 40823C56
    addaw %d0,%a0	| 40823C58
    subqw #4,%sp	| 40823C5A
    movew TEScrpLength,%d0	| 40823C5C
    movel %d0,%sp@-	| 40823C60
    movel #1413830740,%sp@-	| 40823C62
    movel %a0,%sp@-	| 40823C68
    .short  0xA9FE	| 40823C6A _PutScrap
    addql #4,%sp	| 40823C6C
TECOPY_56:              /* return */
    jbra TECALTEXT_6	| 40823C6E
TECOPY_5A:              /* styled copy: the selection's styles into the desk scrap as 'styl' */
    moveml %d0/%d2-%d5/%a2/%a5,%sp@-	| 40823C72
    movew %d0,%d1	| 40823C76
    swap %d0	| 40823C78
    cmpw %d0,%d1	| 40823C7A
    jbeq TECOPY_80	| 40823C7C
    jbsr TECOPY_86	| 40823C7E
    moveal %a4,%a0	| 40823C80
    _HLock	| 40823C82
    subql #4,%sp	| 40823C84
    movel %d4,%sp@-	| 40823C86
    movel #1937013100,%sp@-	| 40823C88
    movel %a4@,%sp@-	| 40823C8E
    .short  0xA9FE	| 40823C90 _PutScrap
    addql #4,%sp	| 40823C92
    moveal %a4,%a0	| 40823C94
    _DisposHandle	| 40823C96
TECOPY_80:              /* restore registers, return */
    moveml %sp@+,%d0/%d2-%d5/%a2/%a5	| 40823C98
    rts	| 40823C9C
TECOPY_86:              /* styled copy: the runs of the selection into a new 'styl' scrap handle */
    movew %d0,%d5	| 40823C9E
    jbsr ITEFEATUREFLAG_9E	| 40823CA0
    jbsr ITEFEATUREFLAG_EC	| 40823CA4
    movew %d0,%d2	| 40823CA8
    muluw #20,%d0	| 40823CAA
    addql #2,%d0	| 40823CAE
    movel %d0,%d4	| 40823CB0
    jbsr TESTYLNEW_F4	| 40823CB2
    moveal %a0,%a4	| 40823CB6
    moveal %a0@,%a0	| 40823CB8
    movew %d2,%a0@	| 40823CBA
    lea %a0@(2),%a1	| 40823CBC
    movew %d5,%d0	| 40823CC0
    jbsr ITEFEATUREFLAG_9E	| 40823CC2
    moveal %a0,%a2	| 40823CC6
TECOPY_B0:              /* per run: start relative to the selection, its height, ascent and text style */
    addql #4,%a1	| 40823CC8
    movew %a2@(2),%d0	| 40823CCA
    jbsr ITEFEATUREFLAG_112	| 40823CCE
    addql #2,%a0	| 40823CD2
    moveq #16,%d0	| 40823CD4
    _BlockMove	| 40823CD6
    moveq #0,%d0	| 40823CD8
    movew %a2@,%d0	| 40823CDA
    subw %d5,%d0	| 40823CDC
    jbcc TECOPY_CA	| 40823CDE
    moveq #0,%d0	| 40823CE0
TECOPY_CA:              /* next run */
    movel %d0,%a1@-	| 40823CE2
    addaw #20,%a1	| 40823CE4
    addql #4,%a2	| 40823CE8
    subqw #1,%d2	| 40823CEA
    jbne TECOPY_B0	| 40823CEC
    rts	| 40823CEE

/* TECUT: _TECut. */
trap_TECut:
TECUT:
    jbsr DOMEASURE_186
    movel %a4,%sp@-	| 40823CF4
    .short  0xA9D5	| 40823CF6 _TECopy
    movel %a4,%sp@-	| 40823CF8
    .short  0xA9D7	| 40823CFA _TEDelete
    jbra TECOPY_56	| 40823CFC

/* TEDELETE: _TEDelete. */
trap_TEDelete:
TEDELETE:
    jbsr DOMEASURE_186
    bsrw HIDECARET	| 40823D04
    bsrs TEDELETE_1A
    jbsr TEDELETE_118	| 40823D0A
    jbsr XRECALLINES_2D8	| 40823D0E
    jbsr TESELVIEW_A	| 40823D12
    jbra TECOPY_56	| 40823D16
TEDELETE_1A:            /* delete the selection's text; %d7 = its length, nothing if 0 */
    bsrw TEDISPATCH_8	| 40823D1A
    movew %d0,%d7
    subw %a2@,%d7
    beqs TEDELETE_88
    tstw %a3@(80)
    bpls TEDELETE_62
    moveml %d0/%d7/%a2,%sp@-
    movew %a3@(32),%d0
    bsrw ITEFEATUREFLAG_9E
    movew %a3@(32),%d0
    cmpw %a0@,%d0
    beqs TEDELETE_44
    bsrw TENEW_8C
    bras TEDELETE_5E
TEDELETE_44:            /* selection starts a style run: that run's style becomes the null style, for the next character typed */
    movew %a0@(2),%d0	| 40823D44
    bsrw ITEFEATUREFLAG_112
    movew #15,%sp@-
    pea %a0@(6)
    clrb %sp@-
    moveal %sp,%a2
    bsrw ITEFEATUREFLAG_148
    addqw #8,%sp
TEDELETE_5E:            /* restore registers */
    moveml %sp@+,%d0/%d7/%a2	| 40823D5E
TEDELETE_62:            /* adjust the style runs; Munger: remove %d7 bytes at selStart; teLength; selEnd = selStart */
    movew %d0,%d1	| 40823D62
    swap %d0
    bsrs TEDELETE_8A
    bsrw TEPASTE_2FE
    movew %d7,%sp@-
    clrw %sp@-
    clrl %sp@-
    clrl %sp@-
    _Munger
    addql #4,%sp
    moveal %a3@(62),%a0
    _HLock
    subw %d7,%a3@(60)
    movew %a2@+,%a2@
    bsrw ITESETSTYLE_35E
TEDELETE_88:            /* return */
    rts	| 40823D88

TEDELETE_8A:            /* styled: adjust the style runs for the deletion of range %d0..%d1 */
    moveml %d0/%d2-%d6/%a2,%sp@-
    tstw %a3@(80)
    jbpl TEDELETE_F8
    movew %d0,%d5
    subw %d1,%d5
    jbeq TEDELETE_F8
    movew %d0,%d3
    subqw #1,%d0
    jbsr ITEFEATUREFLAG_9E
    moveal %a0,%a2
    movew %d0,%d6
    addqw #1,%d1
    jbsr ITEFEATUREFLAG_EC
    subqw #1,%d0
    movew %d0,%d2
    addw %d6,%d0
    movew %d0,%d6
    moveq #0,%d4
    movew %d2,%d4
    lsll #2,%d4
    addal %d4,%a0
    tstw %d2
    jbne TEDELETE_C6
    jbsr ITEFEATUREFLAG_126
    jbra TEDELETE_F8
TEDELETE_C6:            /* shift the run starts after the deleted range */
    movew %d3,%a0@
    jbsr ITEFEATUREFLAG_126
    cmpw %a2@,%d3
    jbeq TEDELETE_D8
    addql #4,%a2
    subqw #4,%d4
    subqw #1,%d2
    jbeq TEDELETE_F8
TEDELETE_D8:            /* decrement the use counts of the deleted runs; remove them */
    moveal %a2,%a0
    movew %d2,%d0
    jbsr TEDELETE_FE
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveq #0,%d0
    movew %a0@,%d0
    addqw #1,%d0
    subw %d6,%d0
    lsll #2,%d0
    subw %d2,%a0@
    moveal %a2,%a1
    moveal %a2,%a0
    addal %d4,%a0
    _BlockMove
TEDELETE_F8:            /* restore registers, return */
    moveml %sp@+,%d0/%d2-%d6/%a2
    rts

TEDELETE_FE:            /* decrement the use counts of %d0 runs from %a0 */
    moveal %a0,%a1
    movew %d0,%d1
TEDELETE_102:           /* loop: the run's style entry */
    movew %a1@(2),%d0
    jbsr ITEFEATUREFLAG_112
    tstw %a0@
    jbeq TEDELETE_110
    subqw #1,%a0@
TEDELETE_110:           /* next run */
    addql #4,%a1
    subqw #1,%d1
    jbne TEDELETE_102
    rts

TEDELETE_118:           /* redraw after an edit: recalculate the lines and redraw the changed ones */
    moveq #0,%d0
    movew %a3@(94),%d1
    jbsr LINERECT_64
    movew %d0,%sp@-
    jbsr XFINDLINE_268
    movew %d2,%d3
    moveq #0,%d0
    movew %a3@(94),%d1
    jbsr LINERECT_64
    movew %sp@+,%d1
    cmpw %d0,%d1
    jbcs TEDELETE_158
    lea %a3@(16),%a0
    addw %a3@,%d1
    movew %d1,%a0@(4)
    addw %a3@,%d0
    movew %d0,%a0@
    movew #-32766,%a0@(2)
    movew #32752,%a0@(6)
    movel %a0,%sp@-
    _EraseRect
TEDELETE_158:           /* draw */
    moveq #-1,%d7
    jbra DOTEXT

TEDELETE_15E:           /* vectored (ExpandMem +188) */
    moveal ExpandMem,%a0
    moveal %a0@(188),%a0
    jmp %a0@
TEDELETE_168:           /* the script run around offset %d0: neighbouring style runs whose fonts have the same script */
    linkw %fp,#-6	| 40823E68
    moveml %d2-%d7/%a2/%a4-%a5,%sp@-	| 40823E6C
    jbsr ITEFEATUREFLAG_9E	| 40823E70
    moveal %a0,%a2	| 40823E74
    movew %d0,%d4	| 40823E76
    moveal %a3@(74),%a5	| 40823E78
    moveal %a5@,%a5	| 40823E7C
    moveal %a5@(4),%a4	| 40823E7E
    moveal %a4@,%a4	| 40823E82
    moveq #0,%d5	| 40823E84
    moveq #0,%d6	| 40823E86
    movew %a2@(2),%d6	| 40823E88
    addw %d6,%d6	| 40823E8C
    movew %d6,%d1	| 40823E8E
    lslw #3,%d6	| 40823E90
    addw %d1,%d6	| 40823E92
    clrw %sp@-	| 40823E94
    movew %a4@(6,%d6:l),%sp@-	| 40823E96
    movel #-2113798138,%sp@-	| 40823E9A
    _ScriptUtil	| 40823EA0
    movew %sp@+,%d7	| 40823EA2
    moveml %d4/%a2,%sp@-	| 40823EA4
TEDELETE_1A8:           /* the run's length */
    addw %a2@(4),%d5	| 40823EA8
    subw %a2@,%d5	| 40823EAC
    movel %a2,%fp@(-4)	| 40823EAE
    movew %d4,%fp@(-6)	| 40823EB2
    addqw #1,%d4	| 40823EB6
    cmpw %a5@,%d4	| 40823EB8
    jbne TEDELETE_1BE	| 40823EBA
    subqw #1,%d5	| 40823EBC
TEDELETE_1BE:           /* the previous run */
    subqw #1,%d4	| 40823EBE
    jbeq TEDELETE_1E6	| 40823EC0
    subql #4,%a2	| 40823EC2
    subqw #1,%d4	| 40823EC4
    moveq #0,%d6	| 40823EC6
    movew %a2@(2),%d6	| 40823EC8
    addw %d6,%d6	| 40823ECC
    movew %d6,%d1	| 40823ECE
    lslw #3,%d6	| 40823ED0
    addw %d1,%d6	| 40823ED2
    clrw %sp@-	| 40823ED4
    movew %a4@(6,%d6:l),%sp@-	| 40823ED6
    movel #-2113798138,%sp@-	| 40823EDA
    _ScriptUtil	| 40823EE0
    cmpw %sp@+,%d7	| 40823EE2
    jbeq TEDELETE_1A8	| 40823EE4
TEDELETE_1E6:           /* restore registers */
    moveml %sp@+,%d4/%a2	| 40823EE6
    addqw #1,%d4	| 40823EEA
TEDELETE_1EC:           /* the next run */
    addql #4,%a2	| 40823EEC
    moveq #0,%d6	| 40823EEE
    movew %a2@(2),%d6	| 40823EF0
    addw %d6,%d6	| 40823EF4
    movew %d6,%d1	| 40823EF6
    lslw #3,%d6	| 40823EF8
    addw %d1,%d6	| 40823EFA
    cmpw %a5@,%d4	| 40823EFC
    jbeq TEDELETE_220	| 40823EFE
    clrw %sp@-	| 40823F00
    movew %a4@(6,%d6:l),%sp@-	| 40823F02
    movel #-2113798138,%sp@-	| 40823F06
    _ScriptUtil	| 40823F0C
    cmpw %sp@+,%d7	| 40823F0E
    jbne TEDELETE_220	| 40823F10
    addw %a2@(4),%d5	| 40823F12
    subw %a2@,%d5	| 40823F16
    addqw #1,%d4	| 40823F18
    cmpw %a5@,%d4	| 40823F1A
    jbne TEDELETE_1EC	| 40823F1C
    subqw #1,%d5	| 40823F1E
TEDELETE_220:           /* return */
    moveal %fp@(-4),%a0	| 40823F20
    moveaw %fp@(-6),%a1	| 40823F24
    movew %d5,%d0	| 40823F28
    movew %d7,%d1	| 40823F2A
    moveml %sp@+,%d2-%d7/%a2/%a4-%a5	| 40823F2C
    unlk %fp	| 40823F30
    rts	| 40823F32

TEDELETE_234:           /* through the low-memory vector at 0x7F8 (word break) */
    movel TEFindWord,%sp@-
    rts

/* XFINDWORD: word boundaries (through the Script Manager). */
trap_TEFindWord:
XFINDWORD:
    movel %d0,%sp@-
    movel %a3@(38),%d0
    _StripAddress
    moveal ExpandMem,%a0
    cmpl %a0@(64),%d0
    jbeq XFINDWORD_18
    movel %sp@+,%d0
    jbra XFINDWORD_12C
XFINDWORD_18:           /* Script Manager break: not for returns (13) */
    movel %sp@+,%d0
    cmpiw #13,%d2
    jbeq XFINDWORD_128
    linkw %fp,#-36
    moveml %d3-%d5/%a0-%a2,%sp@-
    moveq #0,%d1
    cmpiw #12,%d2
    jbne XFINDWORD_34
    notl %d1
XFINDWORD_34:           /* leading or trailing edge */
    movew %d1,%fp@(-26)
    cmpiw #12,%d2
    jbcc XFINDWORD_48
    moveb %a3@(71),%d1
    extw %d1
    movew %d1,%fp@(-26)
XFINDWORD_48:           /* word or line break */
    moveq #0,%d1
    cmpiw #12,%d2
    jbcs XFINDWORD_52
    notl %d1
XFINDWORD_52:           /* styled: the run containing the offset */
    movel %d1,%fp@(-16)
    swap %d2
    movew %d0,%d2
    movel %d2,%fp@(-24)
    movew %d0,%d5
    tstw %a3@(80)
    jbpl XFINDWORD_B2
    jbsr TEDELETE_15E
    movew %d5,%d3
    subw %a0@,%d3
    jbne XFINDWORD_86
    tstw %d5
    jbeq XFINDWORD_86
    tstw %fp@(-26)
    jbne XFINDWORD_86
    movew %d5,%d0
    subqw #1,%d0
    jbsr TEDELETE_15E
    movew %d5,%d3
    subw %a0@,%d3
XFINDWORD_86:           /* the run's text and range */
    movew %d3,%fp@(-28)
    movew %d0,%fp@(-30)
    moveal %a3@(62),%a2
    moveal %a2@,%a2
    addaw %a0@,%a2
    movel %a2,%fp@(-20)
    movew %a1,%fp@(-34)
    movew %a0@,%fp@(-36)
    movew %a0@(2),%d0
    jbsr ITEFEATUREFLAG_112
    movew %a0@(6),%fp@(-32)
    jbra XFINDWORD_D2
XFINDWORD_B2:           /* unstyled: the whole text */
    clrw %fp@(-36)
    movew %d5,%fp@(-28)
    movew %a3@(60),%fp@(-30)
    moveal %a3@(62),%a2
    movel %a2@,%fp@(-20)
    moveal %a3@(82),%a0
    movew %a0@(68),%fp@(-32)
XFINDWORD_D2:           /* _FindWord through the Script Manager */
    moveal %a3@(82),%a0
    movel %fp@(-20),%sp@-
    movew %fp@(-30),%sp@-
    movew %fp@(-28),%sp@-
    movew %fp@(-32),%a0@(68)
    movew %fp@(-26),%sp@-
    movel %fp@(-16),%sp@-
    pea %fp@(-12)
    movel #-2146303974,%sp@-
    _ScriptUtil
    moveal %a3@(82),%a0
    movew %fp@(-32),%a0@(68)
    movel %fp@(-12),%d0
    movel %d0,%d1
    swap %d1
    cmpw %d0,%d1
    jbcc XFINDWORD_114
    exg %d0,%d1
XFINDWORD_114:          /* add the run offset back; return */
    addw %fp@(-36),%d0
    addw %fp@(-36),%d1
    movel %fp@(-24),%d2
    moveml %sp@+,%d3-%d5/%a0-%a2
    unlk %fp
    rts
XFINDWORD_128:          /* return: treat as a plain break */
    andib #0xfe,%d2
XFINDWORD_12C:          /* default break: scan with the wordBreak routine */
    swap %d2
    movew %d0,%d2
    movew %d0,%d1
    jbeq XFINDWORD_136
    jbsr XFINDWORD_14C
XFINDWORD_136:          /* forwards */
    bclr #17,%d2
XFINDWORD_13A:          /* loop: until a break character */
    cmpw %a3@(60),%d1
    jbcc XFINDWORD_14A
    moveaw %d1,%a1
    jbsr XFINDWORD_162
    jbne XFINDWORD_14A
    addqw #1,%d1
    jbra XFINDWORD_13A
XFINDWORD_14A:          /* return */
    rts
XFINDWORD_14C:          /* backwards */
    bset #17,%d2
XFINDWORD_150:          /* loop: until a break character or the start */
    subqw #1,%d0
    moveaw %d0,%a1
    jbsr XFINDWORD_162
    jbne XFINDWORD_15E
    tstw %d0
    jbeq XFINDWORD_160
    jbra XFINDWORD_150
XFINDWORD_15E:          /* after it */
    addqw #1,%d0
XFINDWORD_160:          /* return */
    rts

XFINDWORD_162:          /* call the record's wordBreak routine (+38) at offset %a1 */
    moveml %d0/%a0-%a1,%sp@-
    movew %a1,%d0
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    moveal %a3@(38),%a1
    jsr %a1@
    moveml %sp@+,%d0/%a0-%a1
    rts
XFINDWORD_17A:          /* default wordBreak: space and control characters break */
    andil #65535,%d0
    cmpib #32,%a0@(0x0,%d0:l)
    sls %d0
    tstb %d0
    rts

XFINDWORD_18C:          /* the offset where the width in %d4 runs out, in %d6..%d7 */
    moveml %d2-%d3/%d5/%a2,%sp@-
    tstw %a3@(80)
    jbmi XFINDWORD_1A0
    movew %d7,%d0
    movew %d6,%d1
    jbsr XFINDWORD_1EE
    addw %d6,%d1
    jbra XFINDWORD_1E8
XFINDWORD_1A0:          /* styled line break: per run, measure until the width is used up */
    movew %d6,%d5
    movew %d6,%d3
    movew %d3,%d0
    jbsr ITEFEATUREFLAG_9E
    moveal %a0,%a2
    movew %d7,%d1
    jbsr ITEFEATUREFLAG_EC
    movew %d0,%d2
XFINDWORD_1B4:          /* set the run's style; the run end, clipped */
    moveal %a2,%a0
    jbsr ITESETSTYLE_2C0
    addql #4,%a2
    moveal %a2,%a0
    movew %a0@,%d0
    cmpw %d0,%d7
    jbcc XFINDWORD_1C6
    movew %d7,%d0
XFINDWORD_1C6:          /* measure the run */
    movew %d3,%d1
    movew %d0,%d3
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    subal %a0,%a2
    jbsr XFINDWORD_1EE
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    addal %a0,%a2
    addw %d1,%d5
    tstw %d0
    jbne XFINDWORD_1E6
    subqw #1,%d2
    jbne XFINDWORD_1B4
XFINDWORD_1E6:          /* the start */
    movew %d5,%d1
XFINDWORD_1E8:          /* restore registers, return */
    moveml %sp@+,%d2-%d3/%d5/%a2
    rts

XFINDWORD_1EE:          /* hit-test the run for the remaining width */
    movew %d2,%sp@-
    subw %d1,%d0
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    addaw %d1,%a0
    movew %d4,%d1
    moveq #0,%d2
    jbsr DOSEARCH_16E
    subw %d0,%d4
    swap %d0
    movew %sp@+,%d2
    rts

XFINDWORD_20A:          /* through the low-memory vector at 0x7FC (line break) */
    movel 0x7fc,%sp@-
    rts

/* XFINDLINE: the line containing an offset. */
trap_TEFindLine:
XFINDLINE:
    moveal ExpandMem,%a0
    cmpib #1,%a0@(44)
    jbeq XFINDLINE_1CC
    moveml %d1-%a2,%sp@-
    linkw %fp,#-44
    moveq #0,%d7
    movew %d6,%fp@(-40)
    movew %d6,%fp@(-42)
    clrw %fp@(-38)
    moveq #0,%d0
    movew %a3@(6),%d0
    subw %a3@(2),%d0
    subqw #1,%d0
    swap %d0
    movel %d0,%fp@(-8)
    moveq #0,%d1
    movew %a3@(60),%d1
    subw %d6,%d1
    movel %d1,%fp@(-4)
    moveal %a3@(62),%a2
    moveal %a2@,%a2
    addaw %d6,%a2
    addqw #1,%d1
    tstb %a3@(72)
    jbge XFINDLINE_74
    jbra XFINDLINE_5A
XFINDLINE_54:           /* crOnly: scan for the end-of-line character */
    moveb %a2@+,%d0
    jbsr DOSEARCH_152
XFINDLINE_5A:           /* loop */
    dbeq %d1,XFINDLINE_54
    jbeq XFINDLINE_68
    movew %a3@(60),%d0
    jbra XFINDLINE_1C4
XFINDLINE_68:           /* after the return */
    movew %a3@(60),%d0
    subl %d1,%d0
    addqw #1,%d0
    jbra XFINDLINE_1C4
XFINDLINE_74:           /* word wrap: StyledLineBreak, per run if there are several (%d7) */
    subqw #1,%d1
    movel %a2,%fp@(-32)
    movel %a2,%fp@(-36)
    tstw %a3@(80)
    jbpl XFINDLINE_134
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    cmpiw #1,%a1@
    jbeq XFINDLINE_94
    moveq #1,%d7
XFINDLINE_94:           /* the run of the line start */
    moveq #0,%d0
    movew %d6,%d0
    jbsr ITEFEATUREFLAG_9E
    addqw #1,%d0
    movew %d0,%fp@(-44)
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    cmpw %a1@,%d0
    jbcs XFINDLINE_AE
    moveq #0,%d7
XFINDLINE_AE:           /* set the run's style; StyledLineBreak for the run */
    lea %a0@(4),%a1
    movel %a0,%fp@(-24)
    movel %a1,%fp@(-28)
    jbsr ITESETSTYLE_2C0
    movew %d6,%d0
    jbsr TEDELETE_15E
    clrl %fp@(-12)
    movew %a0@,%d1
    cmpw %fp@(-40),%d1
    jbcs XFINDLINE_E6
    jbeq XFINDLINE_EE
    subw %fp@(-40),%d1
    moveal %fp@(-36),%a0
    addaw %d1,%a0
    movel %a0,%fp@(-32)
    movew %d1,%fp@(-38)
    jbra XFINDLINE_F6
XFINDLINE_E6:           /* part of the run */
    movew %fp@(-40),%d2
    subw %d1,%d2
    subw %d2,%d0
XFINDLINE_EE:           /* first run of the line */
    movel #1,%fp@(-12)
XFINDLINE_F6:           /* the run's text range */
    movew %d0,%sp@-
    moveq #0,%d0
    movew %sp@+,%d0
    movel %d0,%fp@(-4)
    moveq #0,%d1
    moveal %fp@(-24),%a0
    movew %a0@,%d1
    cmpw %fp@(-40),%d1
    jbcc XFINDLINE_110
    movew %d6,%d1
XFINDLINE_110:          /* offsets for StyledLineBreak */
    movel %d1,%fp@(-16)
    movew %fp@(-40),%d0
    addw %fp@(-38),%d0
    subl %d0,%fp@(-16)
    movew %a0@(4),%d1
    subl %d0,%d1
    movel %d1,%fp@(-20)
    tstw %d7
    jbne XFINDLINE_142
    subql #1,%fp@(-20)
    jbra XFINDLINE_142
XFINDLINE_134:          /* unstyled */
    clrw %fp@(-24)
    clrl %fp@(-16)
    movel %fp@(-4),%fp@(-20)
XFINDLINE_142:          /* _StyledLineBreak */
    clrw %sp@-
    movel %fp@(-32),%sp@-
    movel %fp@(-4),%sp@-
    movel %fp@(-16),%sp@-
    movel %fp@(-20),%sp@-
    clrl %sp@-
    pea %fp@(-8)
    pea %fp@(-12)
    movel #-2112028674,%sp@-
    _ScriptUtil
    clrw %d1
    moveb %sp@+,%d1
    cmpiw #2,%d1
    jbeq XFINDLINE_172
    jbra XFINDLINE_1B6
XFINDLINE_172:          /* smBreakOverflow: next run */
    tstw %d7
    jbeq XFINDLINE_1B6
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    movew %fp@(-44),%d0
    addqw #1,%d0
    movew %d0,%fp@(-44)
    cmpw %a1@,%d0
    jbne XFINDLINE_19A
    moveq #0,%d7
    moveal %fp@(-28),%a0
    movew %a0@(4),%d6
    subw %a0@,%d6
    subqw #1,%d6
    jbeq XFINDLINE_1B6
XFINDLINE_19A:          /* continue with the next run */
    moveq #0,%d0
    movew %fp@(-10),%d1
    subl %fp@(-16),%d1
    addw %d1,%fp@(-42)
    moveal %fp@(-28),%a0
    lea %a0@(4),%a1
    movew %a0@,%d6
    jbra XFINDLINE_AE
XFINDLINE_1B6:          /* the break offset */
    moveq #0,%d0
    movew %fp@(-10),%d0
    subl %fp@(-16),%d0
    addw %fp@(-42),%d0
XFINDLINE_1C4:          /* return */
    unlk %fp
    moveml %sp@+,%d1-%a2
    rts
XFINDLINE_1CC:          /* one enabled script: the classic line break from offset %d6, the view width in %d4 */
    moveml %d1-%a2,%sp@-
    movew %a3@(6),%d4
    subw %a3@(2),%d4
    subqw #1,%d4
    subal %a2,%a2
    movew %d6,%d7
    moveq #0,%d3
    moveq #0,%d5
XFINDLINE_1E2:          /* classic break: next word; crOnly: no word wrap */
    movew %d7,%d0
    moveq #13,%d2
    jbsr TEDELETE_234
    movew %d1,%d7
    tstb %a3@(72)
    jbne XFINDLINE_1FA
    jbsr XFINDWORD_18C
    tstw %d0
    jbne XFINDLINE_22A
XFINDLINE_1FA:          /* a return ends the line */
    movew %d7,%d5
    addqw #1,%a2
    cmpw %a3@(60),%d7
    jbeq XFINDLINE_260
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    andl %pc@(XFINDWORD_17C),%d7
    moveb %a0@(0x0,%d7:l),%d0
    moveml %d1,%sp@-
    jbsr DOSEARCH_152
    moveml %sp@+,%d1
    jbne XFINDLINE_224
    addqw #1,%d5
    jbra XFINDLINE_260
XFINDLINE_224:          /* next character */
    movew %d7,%d6
    addqw #1,%d7
    jbra XFINDLINE_1E2
XFINDLINE_22A:          /* word wrap: back to the start of the last word */
    movew %a2,%d0
    jbeq XFINDLINE_25C
    moveal %a3@(62),%a0
    moveal %a0@,%a0
XFINDLINE_234:          /* skip trailing spaces after the break */
    addqw #1,%d5
    cmpw %a3@(60),%d5
    jbcc XFINDLINE_260
    moveb %a0@(0x0,%d5:w),%d0
    moveml %d1/%a0,%sp@-
    jbsr DOSEARCH_152
    moveml %sp@+,%d1/%a0
    jbne XFINDLINE_252
    addqw #1,%d5
    jbra XFINDLINE_260
XFINDLINE_252:          /* spaces stay on the line */
    cmpib #32,%a0@(0x0,%d5:w)
    jbeq XFINDLINE_234
    jbra XFINDLINE_260
XFINDLINE_25C:          /* a word too long for the line: break inside it */
    subqw #1,%d1
    movew %d1,%d5
XFINDLINE_260:          /* return the break */
    movew %d5,%d0
    moveml %sp@+,%d1-%a2
    rts

XFINDLINE_268:          /* through TERecal */
    movel TERecal,%sp@-
    rts

/* XRECALLINES: recalculate the line starts after an edit. */
XRECALLINES:
    linkw %fp,#-14
    moveml %d3/%d5-%d6/%a2,%sp@-
    movew %a3@(94),%fp@(-14)
    clrw %a3@(94)
    clrw %fp@(-4)
    movew %a3@(60),%fp@(-2)
    tstw %a3@(60)
    jbeq XRECALLINES_8A
    lea %a3@(96),%a2
    moveq #16,%d2
    movew %a3@(32),%d0
    jbsr TEDELETE_234
    movew %d0,%d3
XRECALLINES_32:         /* find the line of the change */
    movew %a2@+,%d6
    movew %d6,%fp@(-4)
    cmpw %a2@,%d3
    jbcs XRECALLINES_44
    jbeq XRECALLINES_76
    addqw #1,%a3@(94)
    jbra XRECALLINES_32
XRECALLINES_44:         /* where its break falls now */
    jbsr XFINDWORD_20A
    cmpw %d0,%d3
    jbcc XRECALLINES_58
XRECALLINES_4C:         /* word redraw: from the previous line */
    tstb WordRedraw
    jbgt XRECALLINES_58
    jblt XRECALLINES_84
    movew %a3@(32),%d3
XRECALLINES_58:         /* left aligned, no redraw flags: the redraw starts one character earlier */
    tstw %a3@(58)
    jbne XRECALLINES_84
    tstw TESysJust
    jbne XRECALLINES_84
    tstb WordRedraw
    jbne XRECALLINES_84
    movew %d3,%fp@(-4)
    jbeq XRECALLINES_84
    subqw #1,%fp@(-4)
    jbra XRECALLINES_84
XRECALLINES_76:         /* same break: start here */
    jbsr XFINDWORD_20A
    cmpw %d0,%d3
    jbne XRECALLINES_58
    movew %d3,%fp@(-4)
    jbra XRECALLINES_4C
XRECALLINES_84:         /* recalculate from there */
    movew %d0,%d3
    jbsr XRECALLINES_DC
    jbra XRECALLINES_8E
XRECALLINES_8A:         /* empty text: one line start */
    clrl %a3@(96)
XRECALLINES_8E:         /* shrink the record if lines were removed */
    jbsr XRECALLINES_1FE
    movew %fp@(-2),%d4
    movew %fp@(-4),%d2
    moveal %a4,%a0
    _GetHandleSize
    tstl %d0
    jbpl XRECALLINES_A4
    _SysError
XRECALLINES_A4:         /* 8 or more spare line starts in the record: shrink it */
    subil #104,%d0
    lsrl #1,%d0
    andil #32767,%d0
    subw %a3@(94),%d0
    jbeq XRECALLINES_D4
    jbmi XRECALLINES_D4
    cmpiw #8,%d0
    jbcs XRECALLINES_D4
    moveq #0,%d0
    movew %a3@(94),%d0
    lsll #1,%d0
    addil #104,%d0
    moveal %a4,%a0
    jbsr TESETTEXT_5C
XRECALLINES_D4:         /* restore registers, return */
    moveml %sp@+,%d3/%d5-%d6/%a2
    unlk %fp
    rts

XRECALLINES_DC:         /* recalculate the line starts: end of the changed range from selEnd and the size change %d7 */
    moveml %d2/%d4,%sp@-
    moveq #0,%d5
    movew %a3@(34),%d4
    tstw %d7
    jbpl XRECALLINES_EC
    subw %d7,%d4
XRECALLINES_EC:         /* a temporary buffer for the new line starts */
    subal %a3,%a2
    movel #256,%d0
    movel %d0,%d2
    jbsr TESTYLNEW_F4
    _HLock
    moveal %a0@,%a1
    movel %a0,%fp@(-8)
    addal %a3,%a2
    movel %a2,%fp@(-12)
XRECALLINES_108:        /* no progress: one character */
    cmpw %d6,%d3
    jbne XRECALLINES_10E
    addqw #1,%d3
XRECALLINES_10E:        /* past the end of the change: are the old breaks valid again? */
    cmpw %d4,%d3
    jbls XRECALLINES_150
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    moveb %a0@(0xffffffffffffffff,%d3:w),%d0
    jbsr DOSEARCH_152
    jbne XRECALLINES_134
    moveal %a2,%a0
    movew %d3,%d0
    addw %d7,%d0
XRECALLINES_128:        /* find the old line start */
    cmpw %a0@+,%d0
    jbhi XRECALLINES_128
    subqw #2,%a0
    movel %a0,%fp@(-12)
    jbra XRECALLINES_198
XRECALLINES_134:        /* same break as before: the rest is unchanged */
    moveq #0,%d0
    movew %fp@(-14),%d0
    addw %d0,%d0
    cmpl %d0,%d5
    jbcc XRECALLINES_150
    movew %a2@(0x0,%d5:l),%d0
    subw %d3,%d0
    cmpw %d0,%d7
    jbne XRECALLINES_150
    addl %d5,%fp@(-12)
    jbra XRECALLINES_198
XRECALLINES_150:        /* buffer full: grow it */
    cmpl %d5,%d2
    jbgt XRECALLINES_16C
    moveal %fp@(-8),%a0
    _HUnlock
    addil #256,%d2
    movel %d2,%d0
    subal %a0@,%a1
    jbsr TESETTEXT_5C
    _HLock
    addal %a0@,%a1
XRECALLINES_16C:        /* store the line start */
    movew %d3,%a1@+
    movew %d3,%d6
    addqw #1,%a3@(94)
    addql #2,%d5
    cmpw %a3@(60),%d6
    jbcs XRECALLINES_18E
    movew %fp@(-14),%d0
    addqw #1,%d0
    addw %d0,%d0
    lea %a3@(0x60,%d0:w),%a0
    movel %a0,%fp@(-12)
    jbra XRECALLINES_1AA
XRECALLINES_18E:        /* next line break */
    jbsr XFINDWORD_20A
    movew %d0,%d3
    jbra XRECALLINES_108
XRECALLINES_198:        /* stop */
    movew %d3,%fp@(-2)
    movel %fp@(-12),%d0
    subl %a2,%d0
    subl %d5,%d0
    jbeq XRECALLINES_1AA
    movew %a3@(60),%d3
XRECALLINES_1AA:        /* copy the new line starts into the record (Munger) */
    movew %d3,%fp@(-2)
    moveal %a4,%a0
    _HUnlock
    subql #4,%sp
    movel %a4,%sp@-
    movel %a2,%d0
    subl %a3,%d0
    movel %d0,%sp@-
    clrl %sp@-
    movel %fp@(-12),%d0
    subl %a2,%d0
    movel %d0,%sp@-
    moveal %fp@(-8),%a0
    movel %a0@,%sp@-
    movel %d5,%sp@-
    subal %a3,%a2
    _Munger
    addql #4,%sp
    moveal %a4,%a0
    _HLock
    moveal %a4@,%a3
    addal %a3,%a2
    addal %d5,%a2
    moveal %fp@(-8),%a0
    _DisposHandle
    cmpw %a3@(60),%d6
    jbcc XRECALLINES_1F8
XRECALLINES_1EA:        /* shift the following line starts */
    addqw #1,%a3@(94)
    subw %d7,%a2@
    movew %a2@+,%d6
    cmpw %a3@(60),%d6
    jbcs XRECALLINES_1EA
XRECALLINES_1F8:        /* restore registers, return */
    moveml %sp@+,%d2/%d4
    rts

XRECALLINES_1FE:        /* styled: rebuild the line-height table (nLines + 1 entries) */
    moveml %d2-%d5/%a2/%a4,%sp@-
    tstw %a3@(80)
    jbpl XRECALLINES_2D2
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    _GetHandleSize
    movew %d0,%d3
    asrw #2,%d3
    moveq #0,%d0
    movew %a3@(94),%d0
    addql #1,%d0
    lsll #2,%d0
    jbsr TESETTEXT_5C
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    moveal %a1@(8),%a4
    moveal %a4@,%a4
    tstw %a3@(60)
    jbne XRECALLINES_24E
    movew %a1@(22),%d0
    jbsr ITEFEATUREFLAG_112
    movew %a0@(2),%a4@+
    movew %a0@(4),%a4@
    jbra XRECALLINES_2D2
XRECALLINES_24E:        /* styled: rebuild the line-height table */
    moveal %a1@(4),%a0
    moveal %a0@,%a0
    lea %a1@(20),%a1
    lea %a3@(96),%a2
    moveq #0,%d1
    moveq #0,%d2
    moveq #-1,%d4
    movew %a4@,%d5
XRECALLINES_264:        /* per run in the line: the largest height and its ascent */
    movew %a1@(2),%d0
    muluw #18,%d0
    cmpw %a0@(0x2,%d0:l),%d1
    jbge XRECALLINES_286
    movew %a0@(0x2,%d0:l),%d1
    cmpw %d2,%d3
    jble XRECALLINES_27E
    tstw %a4@
    jbmi XRECALLINES_286
XRECALLINES_27E:        /* store it */
    movew %d1,%a4@
    movew %a0@(0x4,%d0:l),%a4@(2)
XRECALLINES_286:        /* run past the line end: next run */
    movew %a2@(2),%d0
    cmpw %a1@(4),%d0
    jbcs XRECALLINES_298
    jbeq XRECALLINES_296
    addql #4,%a1
    jbra XRECALLINES_264
XRECALLINES_296:        /* next run */
    addql #4,%a1
XRECALLINES_298:        /* next line */
    addql #2,%a2
    tstl %d4
    jbpl XRECALLINES_2A6
    cmpw %a4@,%d5
    jbeq XRECALLINES_2A6
    moveq #0,%d4
    movew %d2,%d4
XRECALLINES_2A6:        /* next entry */
    addql #4,%a4
    movew %a4@,%d5
    moveq #0,%d1
    addqw #1,%d2
    cmpw %a3@(94),%d2
    jbcs XRECALLINES_264
    movel %a4@(-4),%a4@
    tstl %d4
    jbmi XRECALLINES_2D2
    movew %a3@(60),%fp@(-2)
    addw %d4,%d4
    movew %a3@(0x60,%d4:w),%d0
    cmpw %fp@(-4),%d0
    jbcc XRECALLINES_2D2
    movew %d0,%fp@(-4)
XRECALLINES_2D2:        /* restore registers, return */
    moveml %sp@+,%d2-%d5/%a2/%a4
    rts

XRECALLINES_2D8:        /* show the caret (active, no selection, not shown) */
    tstb %a3@(36)
    jbeq HIDECARET_68
    movew %a3@(32),%d0
    cmpw %a3@(34),%d0
    bnew HIDECARET_68
    st %a3@(57)
    tstb %a3@(56)
    jbne HIDECARET_68
    st %a3@(56)
XRECALLINES_2FA:        /* draw it */
    jbra HIDECARET_14

/* HIDECARET: hide the caret. */
HIDECARET:
    tstb %a3@(36)
    jbeq HIDECARET_68
    sf %a3@(57)
    tstb %a3@(56)
    jbeq HIDECARET_68
    sf %a3@(56)
HIDECARET_14:           /* draw the caret: DOTEXT mode -2 at selStart */
    moveml %d0-%d7,%sp@-
    movew %a3@(32),%d3
    movew %d3,%d4
    moveq #-2,%d7
    jbsr DOTEXT
HIDECARET_24:           /* invert the caret through the caret hook */
    movel %a3@(90),%d0
    jbsr DOMEASURE_17A
    tstw %a3@(80)
    jbmi HIDECARET_3E
    tstb WordRedraw
    jbmi HIDECARET_3E
    tstb TESysJust
    jbeq HIDECARET_64
HIDECARET_3E:           /* a split caret: the second one too */
    moveal ExpandMem,%a0
    tstb %a0@(46)
    jbeq HIDECARET_64
    moveal ExpandMem,%a0
    lea %a0@(48),%a0
    movel %a0@+,%a3@(16)
    movel %a0@,%a3@(20)
    moveal ExpandMem,%a0
    sf %a0@(46)
    sf %a0@
    jbra HIDECARET_24
HIDECARET_64:           /* restore registers */
    moveml %sp@+,%d0-%d7
HIDECARET_68:           /* return */
    rts

/* TEACTIVATE: _TEActivate. */
trap_TEActivate:
TEACTIVATE:
    jbsr DOMEASURE_186
    tstb %a3@(36)
    bnes TEACTIVATE_20
    movew %a3@(32),%d0
    cmpw %a3@(34),%d0
    bnes TEACTIVATE_18
    st %a3@(57)
TEACTIVATE_18:          /* active; hilite the selection */
    st %a3@(36)
    bsrw TEUPDATE_1C
TEACTIVATE_20:          /* return */
    bras TEIDLE_3A

/* TEDEACTIVATE: _TEDeactivate. */
trap_TEDeactivate:
TEDEACTIVATE:
    jbsr DOMEASURE_186
    tstb %a3@(36)
    beqs TEIDLE_3A
    bsrw HIDECARET
    bsrw TEUPDATE_1C
    sf %a3@(36)
    bras TEIDLE_3A

/* TEIDLE: _TEIdle: blink the caret. */
trap_TEIdle:
TEIDLE:
    jbsr DOMEASURE_186
    moveal %a3@(66),%a0	| 4082475C
    moveal %a0@,%a0
    movel %a0@(16),%d0
    btst #1,%d0
    beqs TEIDLE_18
    bsrw XTEBUFFERTEXT_4A
TEIDLE_18:              /* blink: if active (caretState low byte) and caretTime has passed, invert the caret and set the next time */
    tstb %a3@(57)	| 40824770
    beqs TEIDLE_3A
    subqw #4,%sp
    _TickCount
    moveal %sp@+,%a0
    cmpal %a3@(52),%a0
    bcss TEIDLE_3A
    addal CaretTime,%a0
    movel %a0,%a3@(52)
    bsrw HIDECARET_14
    notb %a3@(56)
TEIDLE_3A:              /* return */
    jbra TECALTEXT_6	| 40824792

/* TEPASTE: _TEPaste. */
trap_TEPaste:
TEPASTE:
    jbsr DOMEASURE_186
    moveq #0,%d7	| 4082479A
    jbsr TEPASTE_A	| 4082479C
    jbra TEIDLE_3A	| 4082479E
TEPASTE_A:              /* styled paste: the 'TEXT' from the desk scrap */
    tstw %a3@(80)	| 408247A0
    jbpl TEPASTE_44	| 408247A4
    moveq #0,%d0	| 408247A6
    jbsr TESTYLNEW_F4	| 408247A8
    movel %a0,%d6	| 408247AC
    movel %a0,%sp@-	| 408247AE
    subql #4,%sp	| 408247B0
    moveal %sp,%a1	| 408247B2
    subql #4,%sp	| 408247B4
    movel %a0,%sp@-	| 408247B6
    movel #1413830740,%sp@-	| 408247B8
    movel %a1,%sp@-	| 408247BE
    .short  0xA9FD	| 408247C0 _GetScrap
    movel %sp@+,%d0	| 408247C2
    addql #4,%sp	| 408247C4
    tstl %d0	| 408247C6
    jble TEPASTE_3E	| 408247C8
    movel %d0,%d5	| 408247CA
    moveal %d6,%a0	| 408247CC
    _HLock	| 408247CE
    movel %a0@,%d6	| 408247D0
    jbsr TEPASTE_A2	| 408247D2
TEPASTE_3E:             /* release it */
    moveal %sp@+,%a0	| 408247D4
    _DisposHandle	| 408247D6
    jbra TEPASTE_5A	| 408247D8
TEPASTE_44:             /* unstyled: insert the TextEdit scrap (TEScrpHandle, TEScrpLength) */
    moveal TEScrpHandle,%a0	| 408247DA
    _HLock	| 408247DE
    movel %a0@,%d6	| 408247E0
    moveq #0,%d5	| 408247E2
    movew TEScrpLength,%d5	| 408247E4
    jbsr TEPASTE_A2	| 408247E8
    moveal TEScrpHandle,%a0	| 408247EA
    _HUnlock	| 408247EE
TEPASTE_5A:             /* return */
    rts	| 408247F0
/* TESTYLPASTE (TEPASTE_5C): TEDispatch: TEStylPaste: paste the text and the styles of the scrap. */
TEPASTE_5C:             /* TEStylPaste */
    moveq #1,%d7	| 408247F2
    jbsr TEPASTE_A	| 408247F4
    moveq #6,%d0	| 408247F6
    jbra TECALTEXT_E	| 408247F8
TEPASTE_66:             /* no 'styl' scrap: insert with the null style, or the style at the caret */
    moveal %a3@(74),%a0	| 408247FC
    moveal %a0@,%a0	| 40824800
    moveal %a0@(16),%a0	| 40824802
    moveal %a0@,%a0	| 40824806
    moveal %a0@(4),%a1	| 40824808
    movel %a1,%sp@-	| 4082480C
    moveal %a1@,%a0	| 4082480E
    tstw %a0@	| 40824810
    jbeq TEPASTE_98	| 40824812
    moveml %d3/%a4,%sp@-	| 40824814
    moveal %a1,%a4	| 40824818
    moveal %a1,%a0	| 4082481A
    _HLock	| 4082481C
    moveq #0,%d3	| 4082481E
    movew %a3@(32),%d3	| 40824820
    jbsr TEPASTE_158	| 40824824
    moveml %sp@+,%d3/%a4	| 40824828
    jbra TEPASTE_9C	| 4082482C
TEPASTE_98:             /* set it */
    jbsr XCURSORMOVEMENT_2E0	| 4082482E
TEPASTE_9C:             /* release */
    moveal %sp@+,%a0	| 40824832
    _HUnlock	| 40824834
    rts	| 40824836
TEPASTE_A2:             /* replace the selection with the text at %d6 (length %d5): hide the caret, unhilite */
    movew %d7,%sp@-	| 40824838
    jbsr HIDECARET	| 4082483A
    jbsr TEUPDATE_1C	| 4082483E
    tstw %a3@(80)	| 40824842
    jbpl TEPASTE_BC	| 40824846
    tstw %sp@	| 40824848
    jbeq TEPASTE_BA	| 4082484A
    jbsr TEPASTE_100	| 4082484C
    jbra TEPASTE_BC	| 4082484E
TEPASTE_BA:             /* styles for the inserted text */
    jbsr TEPASTE_66	| 40824850
TEPASTE_BC:             /* delete the selection, insert the text */
    jbsr TEDISPATCH_8	| 40824852
    movew %d0,%d7	| 40824856
    subw %a2@,%d7	| 40824858
    jbsr TEPASTE_2FE	| 4082485A
    movew %d7,%sp@-	| 4082485E
    clrw %sp@-	| 40824860
    movel %d6,%sp@-	| 40824862
    movel %d5,%sp@-	| 40824864
    _Munger	| 40824866
    addql #4,%sp	| 40824868
    moveal %a3@(62),%a0	| 4082486A
    _HLock	| 4082486E
    subw %d7,%a3@(60)	| 40824870
    addw %d5,%a3@(60)	| 40824874
    subw %d5,%d7	| 40824878
    jbsr TEDELETE_118
    jbsr ITESETSTYLE_35E
    lea %a3@(32),%a0
    addw %d5,%a0@
    movew %a0@+,%a0@
    jbsr XRECALLINES_2D8
    jbsr TESELVIEW_A
    addql #2,%sp
    rts
TEPASTE_100:            /* styled: insert the scrap's style runs at the insertion point */
    tstw %a3@(80)	| 40824896
    jbpl TEPASTE_156	| 4082489A
    moveml %d2-%d6/%a2/%a4,%sp@-	| 4082489C
    jbsr TEDISPATCH_8	| 408248A0
    movew %d0,%d4	| 408248A4
    swap %d0	| 408248A6
    moveq #0,%d3	| 408248A8
    movew %d0,%d3	| 408248AA
    moveq #0,%d0	| 408248AC
    jbsr TESTYLNEW_F4	| 408248AE
    moveal %a0,%a4	| 408248B2
    movel %a0,%sp@-	| 408248B4
    subql #4,%sp	| 408248B6
    moveal %sp,%a1	| 408248B8
    subql #4,%sp	| 408248BA
    movel %a0,%sp@-	| 408248BC
    movel #1937013100,%sp@-	| 408248BE
    movel %a1,%sp@-	| 408248C4
    .short  0xA9FD	| 408248C6 _GetScrap
    movel %sp@+,%d0	| 408248C8
    addql #4,%sp	| 408248CA
    tstl %d0	| 408248CC
    jbpl TEPASTE_140	| 408248CE
    jbsr TEPASTE_66	| 408248D0
    jbra TEPASTE_14E	| 408248D4
TEPASTE_140:            /* release; set the run array */
    moveal %a4,%a0	| 408248D6
    _HLock	| 408248D8
    movew %d3,%d0	| 408248DA
    movew %d4,%d1	| 408248DC
    jbsr TEDELETE_8A	| 408248DE
    jbsr TEPASTE_158	| 408248E2
TEPASTE_14E:            /* restore registers */
    moveal %sp@+,%a0	| 408248E4
    _DisposHandle	| 408248E6
    moveml %sp@+,%d2-%d6/%a2/%a4	| 408248E8
TEPASTE_156:            /* return */
    rts	| 408248EC

TEPASTE_158:            /* the run before the insertion point */
    movew %d3,%d0
    subqw #1,%d0
    jbsr ITEFEATUREFLAG_9E
    movew %d0,%d4
    moveal %a4@,%a4
    movew %a4@,%d2
    lea %a4@(2),%a4
    movew %d3,%d0
    jbne TEPASTE_176
    tstw %d2
    jbeq TEPASTE_17C
    subqw #1,%d4
    jbra TEPASTE_17C
TEPASTE_176:            /* split the run there */
    jbsr TEPASTE_220
    addql #4,%a0
TEPASTE_17C:            /* room for the new runs */
    addw %d2,%d4
    jbsr TEPASTE_1D6
    moveal %a0,%a2
    moveal %a3@(74),%a0
    _HLock
TEPASTE_188:            /* per scrap run: its start (pinned), its style (added to the style table) */
    movel %a4@,%d1
    addl %d3,%d1
    cmpil #65535,%d1
    jbhi TEPASTE_1B4
    movew %d1,%sp@-
    moveal %a4,%a0
    addql #2,%a0
    jbsr TEPASTE_258
    tstl %d0
    jbne TEPASTE_1AE
    moveal %a4,%a0
    addql #2,%a0
    jbsr TEPASTE_2AC
    movew #1,%a1@
TEPASTE_1AE:            /* store the run */
    movew %sp@+,%d1
    movew %d1,%a2@+
    movew %d0,%a2@+
TEPASTE_1B4:            /* next run; shift the following runs, merge equal neighbours */
    addaw #20,%a4
    subqw #1,%d2
    jbne TEPASTE_188
    subqw #4,%a2
    moveal %a3@(74),%a0
    _HUnlock
    moveal %a2,%a0
    movew %d4,%d0
    jbsr ITEFEATUREFLAG_126
    jbsr ITESETSTYLE_304
    jbsr TENEW_8C
    rts

TEPASTE_1D6:            /* make room for %d2 more entries in the run array at %a0 */
    moveml %d2-%d3/%a2,%sp@-
    moveal %a0,%a2
    moveal %a3@(74),%a0
    _HUnlock
    moveal %a0@,%a1
    moveq #1,%d0
    addw %a1@,%d0
    addw %d2,%a1@
    lsll #2,%d0
    movel %d0,%d3
    addil #20,%d0
    lea %a1@(20),%a1
    subal %a1,%a2
    subl %a2,%d3
    extl %d2
    lsll #2,%d2
    addl %d2,%d0
    jbsr TESETTEXT_5C
    moveal %a0@,%a1
    lea %a1@(20),%a1
    addal %a2,%a1
    _HLock
    moveal %a1,%a0
    addal %d2,%a1
    movel %d3,%d0
    _StripAddress
    _BlockMove
    moveml %sp@+,%d2-%d3/%a2
    rts

TEPASTE_220:            /* split the run at %a0 at offset %d0 */
    movel %d2,%sp@-
    moveal %a0,%a1
    addql #4,%a0
    movew %d0,%d2
    movew %a0@,%d0
    cmpw %a3@(60),%d0
    jbls TEPASTE_232
    subqw #1,%d0
TEPASTE_232:            /* not on a boundary: insert a run entry */
    exg %d0,%d2
    cmpw %d0,%d2
    jbeq TEPASTE_252
    movew %d0,%sp@-
    moveq #1,%d2
    jbsr TEPASTE_1D6
    moveal %a0,%a1
    subqw #4,%a1
    movew %sp@+,%a0@
    movew %a1@(2),%d0
    movew %d0,%a0@(2)
    jbsr ITEFEATUREFLAG_112
    addqw #1,%a0@
TEPASTE_252:            /* return */
    movel %sp@+,%d2
    moveal %a1,%a0
    rts

TEPASTE_258:            /* find a style table entry equal to the style at %a0; add a use if found */
    movel %d2,%sp@-
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    movew %a1@(2),%d2
    moveal %a1@(4),%a1
    moveal %a1@,%a1
    lea %a0@(6),%a0
    movew %d2,%d1
TEPASTE_270:            /* per used entry: compare */
    tstw %a1@
    jbeq TEPASTE_278
    jbsr TEPASTE_294
    jbeq TEPASTE_284
TEPASTE_278:            /* next entry; none: 0 */
    addaw #18,%a1
    subqw #1,%d1
    jbne TEPASTE_270
    moveq #0,%d0
    jbra TEPASTE_290
TEPASTE_284:            /* found: its index, one more use */
    moveq #1,%d0
    swap %d0
    subw %d1,%d2
    movew %d2,%d0
    addqw #1,%a1@
    moveal %a1,%a0
TEPASTE_290:            /* return */
    movel %sp@+,%d2
    rts

TEPASTE_294:            /* compare the 12 style bytes at %a0 with the table entry at %a1+6 */
    moveml %a0-%a1,%sp@-
    lea %a1@(6),%a1
    moveq #12,%d0
TEPASTE_29E:            /* compare 12 bytes */
    cmpmb %a0@+,%a1@+
    jbne TEPASTE_2A6
    subqw #1,%d0
    jbne TEPASTE_29E
TEPASTE_2A6:            /* restore registers, return */
    moveml %sp@+,%a0-%a1
    rts

TEPASTE_2AC:            /* add the style at %a0 to the style table */
    moveml %d2-%d3/%a2,%sp@-
    moveal %a3@(74),%a1
    moveal %a1@,%a2
    movew %a2@(2),%d0
    movew %d0,%d3
    moveal %a2@(4),%a1
    moveal %a1@,%a1
TEPASTE_2C2:            /* add a new entry: a free one, else grow the table */
    tstw %a1@
    jbeq TEPASTE_2F0
    addaw #18,%a1
    subqw #1,%d0
    jbne TEPASTE_2C2
    movel %a0,%sp@-
    addqw #1,%a2@(2)
    moveal %a2@(4),%a0
    _GetHandleSize
    movel %d0,%d2
    addil #18,%d0
    moveal %a0,%a2
    jbsr TESETTEXT_5C
    moveal %sp@+,%a0
    moveal %a2@,%a1
    addal %d2,%a1
    moveq #0,%d0
TEPASTE_2F0:            /* copy the 18-byte style in */
    subw %d0,%d3
    moveq #18,%d0
    _BlockMove
    movew %d3,%d0
    moveml %sp@+,%d2-%d3/%a2
    rts
TEPASTE_2FE:            /* Munger on hText at selStart (shared setup) */
    moveal %sp@+,%a1	| 40824A94
    moveal %a3@(62),%a0	| 40824A96
    _HUnlock	| 40824A9A
    subql #4,%sp	| 40824A9C
    movel %a0,%sp@-	| 40824A9E
    movew %a3@(32),%sp@-	| 40824AA0
    clrw %sp@-	| 40824AA4
    clrl %sp@-	| 40824AA6
    jmp %a1@	| 40824AA8

TEPASTE_314:            /* insert: styles for the inserted text */
    tstw %d5
    jbeq TEPASTE_35A
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(16),%a0
    moveal %a0@,%a0
    moveal %a0@(4),%a1
    moveal %a1@,%a0
    tstw %a0@
    jbeq TEPASTE_34C
    moveml %d3/%a4,%sp@-
    moveal %a1,%a4
    moveq #0,%d3
    movew %a3@(32),%d3
    jbsr TEPASTE_158
    moveml %sp@+,%d3/%a4
    jbsr TENEW_8C
    jbsr ITESETSTYLE_35E
    jbra TEPASTE_35A
TEPASTE_34C:            /* from the run before the caret */
    movew %a3@(32),%d0
    subqw #1,%d0
    jbsr ITEFEATUREFLAG_9E
    jbsr ITEFEATUREFLAG_126
TEPASTE_35A:            /* return */
    rts
TEPASTE_35C:            /* insert the text into hText (Munger), update the length */
    jbsr TEPASTE_2FE	| 40824AF2
    clrl %sp@-	| 40824AF4
    movel %d6,%sp@-	| 40824AF6
    movel %d5,%sp@-	| 40824AF8
    _Munger	| 40824AFA
    addql #4,%sp	| 40824AFC
    moveal %a3@(62),%a0	| 40824AFE
    _HLock	| 40824B02
    addw %d5,%a3@(60)	| 40824B04
    subw %d5,%d7	| 40824B08
    tstw %a3@(80)
    jbpl TEPASTE_37C
    jbsr TEPASTE_314
TEPASTE_37C:            /* return */
    rts

/* TEINSERT: _TEInsert. */
trap_TEInsert:
TEINSERT:
    jbsr DOMEASURE_186
    bsrw HIDECARET	| 40824B18
    bsrw TEUPDATE_1C
    moveq #0,%d7
    moveml %a2@+,%d5-%d6
    bsrs TEPASTE_35C
    jbsr TEDELETE_118	| 40824B28
    addw %d5,%a3@(32)	| 40824B2C
    addw %d5,%a3@(34)	| 40824B30
    jbsr XRECALLINES_2D8	| 40824B34
    jbsr TEUPDATE_1C	| 40824B38

TEINSERT_28:            /* return */
    moveq #12,%d0
    jbra TECALTEXT_8

/* TEKEY: _TEKey. */
trap_TEKey:
TEKEY:
    jbsr DOMEASURE_186
    st %a3@(71)	| 40824B46
    .short  0xA856	| 40824B4A _ObscureCursor
    movew %a2@,%d1
    cmpib #8,%d1
    beqw TEKEY_D0
    moveq #1,%d2
    moveq #31,%d0
    subb %d1,%d0
    blts TEKEY_2A
    beqs TEKEY_44
    subqb #1,%d0
    beqs TEKEY_42
    subqb #1,%d0
    beqs TEKEY_6E
    subqb #1,%d0
    beqs TEKEY_76
TEKEY_2A:               /* other characters: text buffering (feature bit 1) goes through the buffer vector, else _A4 */
    moveal %a3@(66),%a0	| 40824B6C
    moveal %a0@,%a0
    movel %a0@(16),%d0
    btst #1,%d0
    beqs TEKEY_A4
    bsrw TEKEY_F4_6
    braw TEKEY_F4
TEKEY_42:               /* up arrow (30): one line up */
    moveq #-1,%d2	| 40824B84
TEKEY_44:               /* down arrow (31) with %d2 = +1: caret position, one line height away, find that offset in %d6 */
    movew %d2,%sp@-	| 40824B86
    movew %a3@(32),%d3
    movew %d3,%d4
    moveq #-2,%d7
    bsrw DOTEXT
    movew %sp@+,%d2
    bsrw XSETKEYBOARD2FONT_24
    mulsw %d1,%d2
    movel %a3@(16),%a3@(28)
    addw %d2,%a3@(28)
    bsrw DOFIND
    st %a3@(71)
    bras TEKEY_94
TEKEY_6E:               /* right arrow (29): from selEnd */
    movew %a3@(34),%d6	| 40824BB0
    moveq #1,%d3
    bras TEKEY_7E
TEKEY_76:               /* left arrow (28): from selStart, stays at 0 */
    movew %a3@(32),%d6	| 40824BB8
    beqs TEKEY_7E
    moveq #-1,%d3
TEKEY_7E:               /* mixed directions or right-to-left: the full cursor movement vector */
    tstb WordRedraw	| 40824BC0
    blts TEKEY_8A
    tstb TESysJust
    beqs TEKEY_90
TEKEY_8A:               /* vector */
    bsrw XDUMPBUFFER_74_6	| 40824BCC
    bras TEKEY_94
TEKEY_90:               /* otherwise one character by %d3 */
    bsrw XCURSORMOVEMENT_2B2+0x2	| 40824BD2
TEKEY_94:               /* TESetSelect(%d6, %d6), show the caret */
    extl %d6	| 40824BD6
    movel %d6,%sp@-
    movel %d6,%sp@-
    movel %a4,%sp@-
    .short  0xA9D1	| 40824BDE _TESetSelect
    bsrw XRECALLINES_2D8+0x18
    bras TEKEY_F4
TEKEY_A4:               /* insert the character (a double-byte first byte is only kept for the next key) */
    movel %a2,%d6	| 40824BE6
    addqw #1,%d6
    moveq #1,%d5
    bsrw XCURSORMOVEMENT_25E_2
    bcss TEKEY_F4
    tstw %a3@(80)
    bpls TEKEY_C0
    movew %a3@(32),%d0
    subqw #1,%d0
    bsrw XCURSORMOVEMENT_30E
TEKEY_C0:               /* replace the selection with it; the double-byte holder (ExpandMem +82) cleared */
    moveq #0,%d7	| 40824C02
    bsrw TEPASTE_A2
    moveal ExpandMem,%a0
    clrw %a0@(82)
    bras TEKEY_F4
TEKEY_D0:               /* backspace: with no selection, select the character before the caret (none at 0) */
    movew %a3@(32),%d0	| 40824C12
    cmpw %a3@(34),%d0
    bnes TEKEY_F0
    tstw %d0
    beqs TEKEY_F4
    bsrw HIDECARET
    movew %a3@(32),%d6
    moveq #-1,%d3
    bsrw XCURSORMOVEMENT_2B2+0x2
    movew %d6,%a3@(32)
TEKEY_F0:               /* TEDelete */
    movel %a4,%sp@-	| 40824C32
    .short  0xA9D7	| 40824C34 _TEDelete
TEKEY_F4:               /* return */
    moveq #6,%d0	| 40824C36
    jbra TECALTEXT_8	| 40824C38
TEKEY_F4_6:             /* vector XTEBUFFERTEXT (ExpandMem +216) */
    moveal ExpandMem,%a0	| 40824C3C
    moveal %a0@(216),%a0
    jmp %a0@

/* XTEBUFFERTEXT: buffer typed characters. */
XTEBUFFERTEXT:
    moveal ExpandMem,%a1	| 40824C46
    tstl %a1@(82)	| 40824C4A
    jbne XTEBUFFERTEXT_1C	| 40824C4E
    movew #50,%d0	| 40824C50
    jbsr XTEBUFFERTEXT_38	| 40824C54
    moveal ExpandMem,%a1	| 40824C56
    movel %a0,%a1@(78)	| 40824C5A
    movel %a0@,%a1@(82)	| 40824C5E
XTEBUFFERTEXT_1C:       /* buffer full (50): flush it first */
    moveal %a1@(82),%a0
    movew %a1@(86),%d0
    cmpiw #50,%d0
    jbne XTEBUFFERTEXT_2C
    jbsr XTEBUFFERTEXT_4A
XTEBUFFERTEXT_2C:       /* append the character */
    moveb %a2@(1),%a0@(0x0,%d0:l)
    addqw #1,%a1@(86)
    rts
XTEBUFFERTEXT_38:       /* _NewHandle, locked; failure: system error */
    .short  0xA322	| 40824C7E _NewHandle (flags 0x0300)
    jbne XTEBUFFERTEXT_48	| 40824C80
    _HLock	| 40824C82
    jbne XTEBUFFERTEXT_42	| 40824C84
    rts	| 40824C86
XTEBUFFERTEXT_42:       /* dispose of the buffer */
    movel %d0,%sp@-	| 40824C88
    _DisposHandle	| 40824C8A
    movel %sp@+,%d0	| 40824C8C
XTEBUFFERTEXT_48:       /* _SysError */
    _SysError	| 40824C8E

XTEBUFFERTEXT_4A:       /* vectored flush (ExpandMem +220) */
    moveal ExpandMem,%a0
    moveal %a0@(220),%a0
    jmp %a0@

/* XDUMPBUFFER: insert the buffered characters. */
XDUMPBUFFER:
    moveml %d0-%d7/%a1-%a4,%sp@-	| 40824C9A
    moveq #0,%d3	| 40824C9E
    moveal ExpandMem,%a2	| 40824CA0
    lea %a2@(86),%a2	| 40824CA4
    movew %a2@,%d2	| 40824CA8
    tstb %d2	| 40824CAA
    jbeq XDUMPBUFFER_74	| 40824CAC
    subqw #1,%d2	| 40824CAE
    moveal ExpandMem,%a1	| 40824CB0
    lea %a1@(82),%a1	| 40824CB4
    movel %a1,%sp@-	| 40824CB8
    clrw %sp@-	| 40824CBA
    movel %a1@,%sp@-	| 40824CBC
    movew %d2,%sp@-	| 40824CBE
    movel #-2113535984,%sp@-	| 40824CC0
    _ScriptUtil	| 40824CC6
    movew %sp@+,%d7	| 40824CC8
    moveal %sp@+,%a1	| 40824CCA
    tstw %d7	| 40824CCC
    jbge XDUMPBUFFER_3C	| 40824CCE
    movew %a1@(0,%d2:l),%d3	| 40824CD0
    subqw #1,%a2@	| 40824CD4
XDUMPBUFFER_3C:         /* insert the buffered text at the selection */
    movel %a1@,%d6	| 40824CD6
    movew %a2@,%d5	| 40824CD8
    moveml %d3/%a1-%a2,%sp@-	| 40824CDA
    tstw %a3@(80)	| 40824CDE
    jbpl XDUMPBUFFER_52	| 40824CE2
    movew %a3@(32),%d0	| 40824CE4
    jbsr XCURSORMOVEMENT_30E	| 40824CE8
XDUMPBUFFER_52:         /* replace the selection with it */
    moveq #0,%d7	| 40824CEC
    jbsr TEPASTE_A2	| 40824CEE
    moveml %sp@+,%d3/%a1-%a2	| 40824CF2
    tstb %d3	| 40824CF6
    jbeq XDUMPBUFFER_68	| 40824CF8
    movew %d3,%a1@	| 40824CFA
    movew #1,%a2@	| 40824CFC
    jbra XDUMPBUFFER_74	| 40824D00
XDUMPBUFFER_68:         /* dispose of the buffer, count 0 */
    moveal ExpandMem,%a0	| 40824D02
    lea %a0@(78),%a0	| 40824D06
    _DisposHandle	| 40824D0A
    clrw %a2@	| 40824D0C
XDUMPBUFFER_74:         /* restore registers, return */
    moveml %sp@+,%d0-%d7/%a1-%a4	| 40824D0E
    rts	| 40824D12
XDUMPBUFFER_74_6:       /* vector XCURSORMOVEMENT (ExpandMem +224) */
    moveal ExpandMem,%a1	| 40824D14
    moveal %a1@(224),%a1
    jmp %a1@

/* XCURSORMOVEMENT: arrow keys. */
XCURSORMOVEMENT:
    linkw %fp,#-54	| 40824D1E
    moveml %d2-%d5/%d7/%a2,%sp@-	| 40824D22
    sf %fp@(-51)	| 40824D26
    cmpiw #28,%d1
    jbeq XCURSORMOVEMENT_22
    moveb #0xff,%d0
    movew #1,%d7
    moveb #1,%d2
    moveq #0,%d1
    jbra XCURSORMOVEMENT_2E
XCURSORMOVEMENT_22:     /* left arrow: backwards */
    moveq #0,%d0
    movew #-1,%d7
    moveq #0,%d2
    moveb #1,%d1
XCURSORMOVEMENT_2E:     /* the line direction decides which way is forward */
    cmpb TESysJust,%d0
    jbeq XCURSORMOVEMENT_40
    movew #-1,%d5
    moveb #1,%d3
    moveq #0,%d4
    jbra XCURSORMOVEMENT_4A
XCURSORMOVEMENT_40:     /* left to right */
    movew #1,%d5
    moveq #0,%d3
    moveb #1,%d4
XCURSORMOVEMENT_4A:     /* the line of the caret */
    movew %d6,%d0
    lea %a3@(96),%a2
    moveal %a2,%a0
    jbsr PREPLINE_42
    movew %a3@(94),%d0
    lslw #1,%d0
    addaw %d0,%a0
    cmpal %a0,%a2
    jbne XCURSORMOVEMENT_68
    tstb %d5
    jblt XCURSORMOVEMENT_1C0
XCURSORMOVEMENT_68:     /* at a line start moving back: the previous line */
    cmpw %a2@,%d6
    jbne XCURSORMOVEMENT_78
    cmpiw #0,%d6
    jbeq XCURSORMOVEMENT_78
    tstb %d5
    jblt XCURSORMOVEMENT_78
    subqw #2,%a2
XCURSORMOVEMENT_78:     /* the runs of the line in display order; at a line end? */
    movemw %d1-%d2,%sp@-
    jbsr XGETRLPOSITION_30E
    movemw %sp@+,%d1-%d2
    moveb %d3,%d0
    jbsr XCURSORMOVEMENT_1C8
    jbne XCURSORMOVEMENT_1C0
    moveb %d4,%d0
    jbsr XCURSORMOVEMENT_1C8
    jbeq XCURSORMOVEMENT_A6
    jbsr XCURSORMOVEMENT_1E6
    jbsr XCURSORMOVEMENT_1F6
    jbne XCURSORMOVEMENT_1BA
    jbra XCURSORMOVEMENT_17E
XCURSORMOVEMENT_A6:     /* the run of the caret */
    jbsr XCURSORMOVEMENT_244
    cmpw %a0@,%d6
    jbeq XCURSORMOVEMENT_BA
    jbsr XCURSORMOVEMENT_234
    cmpw %d0,%d6
    jbcs XCURSORMOVEMENT_120
    st %fp@(-51)
XCURSORMOVEMENT_BA:     /* the run's direction differs from the line: look at the neighbouring run */
    moveml %d1-%d2,%sp@-
    jbsr XGETRLPOSITION_2DC
    moveb %d1,%d0
    moveml %sp@+,%d1-%d2
    cmpb TESysJust,%d0
    jbeq XCURSORMOVEMENT_15A
    moveb %d0,%fp@(-54)
    tstb %fp@(-51)
    jbne XCURSORMOVEMENT_DE
    subql #4,%a0
    jbra XCURSORMOVEMENT_E0
XCURSORMOVEMENT_DE:     /* next run */
    addql #4,%a0
XCURSORMOVEMENT_E0:     /* the neighbouring run: same direction as the remembered one? */
    moveml %d1-%d2,%sp@-
    jbsr XGETRLPOSITION_2DC
    moveb %d1,%d0
    moveml %sp@+,%d1-%d2
    cmpb %fp@(-54),%d0
    jbne XCURSORMOVEMENT_11A
    tstb %fp@(-51)
    jbne XCURSORMOVEMENT_FE
    addql #4,%a0
    jbra XCURSORMOVEMENT_100
XCURSORMOVEMENT_FE:     /* previous run */
    subql #4,%a0
XCURSORMOVEMENT_100:    /* at the run edge: move into the neighbouring run */
    movew %d1,%sp@-
    moveb %d4,%d1
    movew %d6,%d0
    jbsr XCURSORMOVEMENT_222
    movew %sp@+,%d1
    exg %d6,%d0
    cmpw %d0,%d6
    jbeq XCURSORMOVEMENT_116
    jbsr XCURSORMOVEMENT_244
XCURSORMOVEMENT_116:    /* next display position */
    addw %d7,%d1
    jbra XCURSORMOVEMENT_14C
XCURSORMOVEMENT_11A:    /* the run of the caret */
    jbsr XCURSORMOVEMENT_244
    jbra XCURSORMOVEMENT_15A
XCURSORMOVEMENT_120:    /* inside a run: one character in the run's direction */
    jbsr XCURSORMOVEMENT_1F6
    jbne XCURSORMOVEMENT_15A
    movew %d1,%sp@-
    moveb %d4,%d1
    movew %d6,%d0
    jbsr XCURSORMOVEMENT_222
    movew %sp@+,%d1
    exg %d6,%d0
    subw %d5,%d0
    cmpw %d0,%d6
    jbne XCURSORMOVEMENT_1BE
    movew %d1,%d0
    moveb %d2,%d1
    jbsr XCURSORMOVEMENT_1E6
    cmpw %d0,%d1
    jbeq XCURSORMOVEMENT_1AA
    addw %d7,%d0
    movew %d0,%d1
XCURSORMOVEMENT_14C:    /* run direction against the line: step the other way */
    jbsr XCURSORMOVEMENT_1F6
    jbeq XCURSORMOVEMENT_1BE
    moveb %d4,%d1
    jbsr XCURSORMOVEMENT_222
    jbra XCURSORMOVEMENT_1C0
XCURSORMOVEMENT_15A:    /* at the run's edge? */
    tstb %d3
    jbne XCURSORMOVEMENT_164
    cmpw %a0@,%d6
    jbne XCURSORMOVEMENT_1BA
    jbra XCURSORMOVEMENT_16C
XCURSORMOVEMENT_164:    /* at its end */
    jbsr XCURSORMOVEMENT_234
    cmpw %d0,%d6
    jbne XCURSORMOVEMENT_1BA
XCURSORMOVEMENT_16C:    /* the neighbouring run in display order */
    movew %d1,%d0
    moveb %d2,%d1
    jbsr XCURSORMOVEMENT_1E6
    cmpw %d0,%d1
    jbeq XCURSORMOVEMENT_1C0
    addw %d7,%d0
    movew %d0,%d1
    jbsr XCURSORMOVEMENT_1F6
    jbne XCURSORMOVEMENT_1BA
XCURSORMOVEMENT_17E:    /* a one-character run: skip it */
    jbsr XCURSORMOVEMENT_234
    subw %a0@,%d0
    cmpiw #1,%d0
    jbhi XCURSORMOVEMENT_1A4
    movew %d1,%d0
    moveb %d2,%d1
    jbsr XCURSORMOVEMENT_1E6
    cmpw %d0,%d1
    jbeq XCURSORMOVEMENT_19C
    addw %d7,%d0
    movew %d0,%d1
    jbsr XCURSORMOVEMENT_1F6
    jbeq XCURSORMOVEMENT_1A4
XCURSORMOVEMENT_19C:    /* its edge */
    moveb %d3,%d1
    jbsr XCURSORMOVEMENT_222
    jbra XCURSORMOVEMENT_1C0
XCURSORMOVEMENT_1A4:    /* its edge, then one more */
    moveb %d3,%d1
    jbsr XCURSORMOVEMENT_222
    jbra XCURSORMOVEMENT_1BE
XCURSORMOVEMENT_1AA:    /* line start or end */
    moveb %d3,%d1
    tstb %d1
    jbne XCURSORMOVEMENT_1B4
    movew %a2@,%d6
    jbra XCURSORMOVEMENT_1C0
XCURSORMOVEMENT_1B4:    /* line end */
    movew %a2@(2),%d6
    jbra XCURSORMOVEMENT_1C0
XCURSORMOVEMENT_1BA:    /* one character back */
    subw %d5,%d6
    jbra XCURSORMOVEMENT_1C0
XCURSORMOVEMENT_1BE:    /* one character forward */
    addw %d5,%d6
XCURSORMOVEMENT_1C0:    /* restore registers, return */
    moveml %sp@+,%d2-%d5/%d7/%a2
    unlk %fp
    rts

XCURSORMOVEMENT_1C8:    /* at the line start (%d0 = 0) or the line end? */
    cmpib #0,%d0
    jbne XCURSORMOVEMENT_1D8
    clrb %d0
    cmpw %a2@,%d6
    jbne XCURSORMOVEMENT_1E2
    st %d0
    jbra XCURSORMOVEMENT_1E2
XCURSORMOVEMENT_1D8:    /* line end */
    clrb %d0
    cmpw %a2@(2),%d6
    jbne XCURSORMOVEMENT_1E2
    st %d0
XCURSORMOVEMENT_1E2:    /* return the flag */
    tstb %d0
    rts

XCURSORMOVEMENT_1E6:    /* first or last run in display order */
    tstb %d1
    jbne XCURSORMOVEMENT_1EE
    moveq #0,%d1
    jbra XCURSORMOVEMENT_1F4
XCURSORMOVEMENT_1EE:    /* last */
    movew %fp@(-40),%d1
    subqw #1,%d1
XCURSORMOVEMENT_1F4:    /* return */
    rts

XCURSORMOVEMENT_1F6:    /* vectored: is the run with the line direction? (ExpandMem +228) */
    moveal ExpandMem,%a1
    moveal %a1@(228),%a1
    jmp %a1@
XCURSORMOVEMENT_200:    /* the run's direction against the line's */
    movemw %d1-%d2,%sp@-	| 40824F1E
    movew %d1,%fp@(-8)	| 40824F22
    jbsr XTEGETFORMATORDER_7E	| 40824F26
    clrw %d0	| 40824F2A
    jbsr XGETRLPOSITION_2DC	| 40824F2C
    cmpb TESysJust,%d1	| 40824F30
    jbne XCURSORMOVEMENT_21A	| 40824F34
    st %d0	| 40824F36
XCURSORMOVEMENT_21A:    /* return */
    movemw %sp@+,%d1-%d2	| 40824F38
    tstb %d0	| 40824F3C
    rts	| 40824F3E

XCURSORMOVEMENT_222:    /* the caret at the run's start (%d1 = 0) or end */
    movew %d0,%sp@-
    tstb %d1
    jbne XCURSORMOVEMENT_22C
    movew %a0@,%d6
    jbra XCURSORMOVEMENT_230
XCURSORMOVEMENT_22C:    /* end */
    jbsr XCURSORMOVEMENT_234
    movew %d0,%d6
XCURSORMOVEMENT_230:    /* return */
    movew %sp@+,%d0
    rts

XCURSORMOVEMENT_234:    /* run end (next run's start), pinned to the text length */
    movew %a0@(4),%d0
    cmpw %a3@(60),%d0
    jbls XCURSORMOVEMENT_242
    movew %a3@(60),%d0
XCURSORMOVEMENT_242:    /* return */
    rts

XCURSORMOVEMENT_244:    /* find the run of the caret in display order */
    jbsr XTEGETFORMATORDER_7E
    movew %fp@(-8),%d1
    addqw #1,%fp@(-8)
    cmpw %a0@,%d6
    jbhi XCURSORMOVEMENT_258
    jbeq XCURSORMOVEMENT_25E
    jbra XCURSORMOVEMENT_244
XCURSORMOVEMENT_258:    /* inside it? */
    jbsr XCURSORMOVEMENT_234
    cmpw %d0,%d6
    jbhi XCURSORMOVEMENT_244
XCURSORMOVEMENT_25E:    /* return */
    rts
XCURSORMOVEMENT_25E_2:  /* vector XCURSORMOVEMENT_26A (ExpandMem +232): double-byte characters */
    moveal ExpandMem,%a0	| 40824F7E
    moveal %a0@(232),%a0
    jmp %a0@
XCURSORMOVEMENT_26A:    /* TEKey: second byte of a double-byte character */
    moveal ExpandMem,%a0	| 40824F88
    lea %a0@(82),%a0	| 40824F8C
    tstw %a0@	| 40824F90
    jbeq XCURSORMOVEMENT_282	| 40824F92
    moveb %a2@(1),%a0@(1)	| 40824F94
    movel %a0,%d6	| 40824F9A
    addqw #1,%d5	| 40824F9C
    jbra XCURSORMOVEMENT_2B2	| 40824F9E
XCURSORMOVEMENT_282:    /* first byte; styled: the style at the caret */
    moveb %a2@(1),%a0@	| 40824FA0
    tstw %a3@(80)	| 40824FA4
    jbpl XCURSORMOVEMENT_2A2	| 40824FA8
    movew %a3@(32),%d0	| 40824FAA
    jbeq XCURSORMOVEMENT_29A	| 40824FAE
    cmpw %a3@(60),%d0	| 40824FB0
    jbne XCURSORMOVEMENT_29A	| 40824FB4
    subqw #1,%d0	| 40824FB6
XCURSORMOVEMENT_29A:    /* set it */
    jbsr ITEFEATUREFLAG_9E	| 40824FB8
    jbsr ITESETSTYLE_2C0	| 40824FBC
XCURSORMOVEMENT_2A2:    /* a double-byte first byte? (CharByte) */
    clrw %sp@-	| 40824FC0
    movel %d6,%sp@-	| 40824FC2
    clrw %sp@-	| 40824FC4
    movel #-2113535984,%sp@-	| 40824FC6
    _ScriptUtil	| 40824FCC
    tstw %sp@+	| 40824FCE
XCURSORMOVEMENT_2B2:    /* return */
    rts	| 40824FD0
    addw %d3,%d6
    tstw %a3@(80)
    jbpl XCURSORMOVEMENT_2C6
    movew %d6,%d0
    jbsr ITEFEATUREFLAG_9E
    jbsr ITESETSTYLE_2C0
XCURSORMOVEMENT_2C6:    /* backspace over a double-byte character: two bytes */
    clrw %sp@-
    moveal %a3@(62),%a0
    movel %a0@,%sp@-
    movew %d6,%sp@-
    movel #-2113535984,%sp@-
    _ScriptUtil
    tstw %sp@+
    jble XCURSORMOVEMENT_2DE
    addw %d3,%d6
XCURSORMOVEMENT_2DE:    /* return */
    rts
XCURSORMOVEMENT_2E0:    /* styled delete: drop runs that become empty */
    movew %d5,%sp@-	| 40824FFE
    tstw %a3@(80)
    jbpl XCURSORMOVEMENT_30A
    jbsr TEDISPATCH_8
    movew %d0,%d1
    swap %d0
    cmpw %d0,%d1
    jbeq XCURSORMOVEMENT_2FC
    subqw #1,%d5
    addqw #1,%d0
    jbsr TEDELETE_8A
XCURSORMOVEMENT_2FC:    /* shift the following runs */
    tstw %d5
    jbeq XCURSORMOVEMENT_30A
    subqw #1,%d0
    jbsr ITEFEATUREFLAG_9E
    jbsr ITEFEATUREFLAG_126
XCURSORMOVEMENT_30A:    /* return */
    movew %sp@+,%d5
    rts
XCURSORMOVEMENT_30E:    /* vectored (ExpandMem +236) */
    moveal ExpandMem,%a0	| 4082502C
    moveal %a0@(236),%a0	| 40825030
    jmp %a0@	| 40825034

/* XSETFONT2KEYBOARD: keyboard script from the font. */
XSETFONT2KEYBOARD:
    jbsr ITEFEATUREFLAG_9E	| 40825036
    moveal ExpandMem,%a1	| 4082503A
    cmpib #1,%a1@(44)	| 4082503E
    jbeq XSETFONT2KEYBOARD_7A	| 40825044
    movel %a0,%sp@-	| 40825046
    clrl %sp@-	| 40825048
    movew #22,%sp@-	| 4082504A
    movel #-2080243704,%sp@-	| 4082504E
    _ScriptUtil	| 40825054
    movel %sp@+,%d0	| 40825056
    moveal %sp@+,%a0	| 40825058
    movew %d0,%sp@-	| 4082505A
    jbsr ITESETSTYLE_2C0	| 4082505C
    subqw #2,%sp	| 40825060
    movel #-2113929216,%sp@-	| 40825062
    _ScriptUtil	| 40825068
    movew %sp@+,%d1	| 4082506A
    movew %sp@+,%d0	| 4082506C
    cmpw %d0,%d1	| 4082506E
    jbeq XSETFONT2KEYBOARD_7A	| 40825070
    clrl %sp@-	| 40825072
    movew %d0,%sp@-	| 40825074
    movew #12,%sp@-	| 40825076
    movel #-2080112628,%sp@-	| 4082507A
    _ScriptUtil	| 40825080
    movel %sp@+,%d0	| 40825082
    jbsr ITESETSTYLE_222
    jbeq XSETFONT2KEYBOARD_5C
    lea %a0@(2),%a0
    movew %a0@(8),%d0
XSETFONT2KEYBOARD_5C:   /* the font for the keyboard script into the null style */
    moveal ExpandMem,%a0
    movew %d0,%a0@(68)
    moveal %a0,%a2
    lea %a2@(70),%a2
    lea %a0@(68),%a0
    movel %a0,%a2@(2)
    movew %a3@(32),%d0
    jbsr ITEFEATUREFLAG_148
XSETFONT2KEYBOARD_7A:   /* return */
    rts
XSETFONT2KEYBOARD_7C:   /* vectored (ExpandMem +240) */
    moveal ExpandMem,%a1	| 408250B2
    moveal %a1@(240),%a1	| 408250B6
    jmp %a1@	| 408250BA

/* XSETKEYBOARD2FONT: font from the keyboard script. */
XSETKEYBOARD2FONT:
    movel %a0,%sp@-	| 408250BC
    moveal ExpandMem,%a1	| 408250BE
    cmpib #1,%a1@(44)	| 408250C2
    jbeq XSETKEYBOARD2FONT_20	| 408250C8
    subqw #2,%sp	| 408250CA
    movel #-2113929216,%sp@-	| 408250CC
    _ScriptUtil	| 408250D2
    movel #-2147352572,%sp@-	| 408250D4
    _ScriptUtil	| 408250DA
XSETKEYBOARD2FONT_20:   /* return */
    moveal %sp@+,%a0	| 408250DC
    rts	| 408250DE

XSETKEYBOARD2FONT_24:   /* the line of offset %d3 and its height */
    movel %a2,%sp@-
    lea %a3@(96),%a2
    movew %d3,%d0
    jbsr PREPLINE_42
    jbsr CHKBOUNDS_8E
    jbsr LINERECT_A4
    moveal %sp@+,%a2
    rts

/* TESETJUST: _TESetJust. */
trap_TESetJust:
TESETJUST:
    jbsr DOMEASURE_186
    movew %a2@,%a3@(58)	| 408250FC
    jbra TEKEY_F4	| 40825100
    moveq #0,%d3
    moveq #-1,%d4
    jbsr DOMEASURE_CA
    moveq #-1,%d7
    jbsr DOTEXT
    jbsr TEUPDATE_1C
    tstb %a3@(56)
    jbeq TESCROLL_3E
    jbra XRECALLINES_2FA

/* TESCROLL: _TEScroll. */
trap_TEScroll:
TESCROLL:
    jbsr DOMEASURE_186
    bsrw HIDECARET	| 40825124
    movel %a2@+,%d3
    bsrs TESCROLL_12
TESCROLL_C:             /* return */
    moveq #8,%d0
    jbra TECALTEXT_8
TESCROLL_12:            /* scroll by %d3: OffsetRect destRect, ScrollRect the view, redraw the exposed region */
    tstl %d3	| 40825132
    beqs TESCROLL_3E_2
    pea %a3@
    movel %d3,%sp@-
    _OffsetRect
    subqw #4,%sp
    _NewRgn
    moveal %sp@+,%a2
    pea %a3@(8)
    movel %d3,%sp@-
    movel %a2,%sp@-
    _ScrollRect
    bsrs TESCROLL_3E_2
    movel %a2,%sp@-
    _SetClip
    moveal %a2@,%a0
    lea %a0@(2),%a0
    bsrs TESETJUST+0xc
    movel %a2,%sp@-
    _DisposRgn
TESCROLL_3E:            /* return */
    rts
TESCROLL_3E_2:          /* caret should show if active with no selection */
    tstb %a3@(36)
    beqs TESCROLL_3E_16
    movew %a3@(32),%d0
    cmpw %a3@(34),%d0
    bnes TESCROLL_3E_16
    st %a3@(57)
TESCROLL_3E_16:         /* return */
    rts

/* TEPINSCROLL: _TEPinScroll. */
trap_TEPinScroll:
TEPINSCROLL:
    jbsr DOMEASURE_186
    bsrw HIDECARET
    movew %a2@,%d0
    bpls TEPINSCROLL_40
    movew %a3@(94),%d1
    movew %a3@(60),%d0
    tstw %d0
    beqs TEPINSCROLL_28
    moveal %a3@(62),%a0
    moveal %a0@,%a0
    cmpib #13,%a0@(-1,%d0:w)
    bnes TEPINSCROLL_28
    addqw #1,%d1
TEPINSCROLL_28:         /* vertical: not past the last line */
    moveq #0,%d0
    bsrw LINERECT_64
    movew %d0,%d1
    movew %a2@,%d0
    addw %a3@,%d1
    subw %a3@(12),%d1
    bles TEPINSCROLL_4C
    addw %d1,%d0
    bpls TEPINSCROLL_4E
    bras TEPINSCROLL_4C
TEPINSCROLL_40:         /* not past the first line */
    movew %a3@,%d1
    subw %a3@(8),%d1
    bpls TEPINSCROLL_4C
    addw %d1,%d0
    bmis TEPINSCROLL_4E
TEPINSCROLL_4C:         /* adjust */
    subw %d0,%a2@
TEPINSCROLL_4E:         /* horizontal: right edge */
    movew %a2@(2),%d0
    bpls TEPINSCROLL_68
    movew %a3@(6),%d1
    subw %a3@(14),%d1
    bles TEPINSCROLL_76
    addw %d1,%d0
    bpls TEPINSCROLL_7A
    subw %d0,%a2@(2)
    bras TEPINSCROLL_7A
TEPINSCROLL_68:         /* left edge */
    movew %a3@(2),%d1
    subw %a3@(10),%d1
    bpls TEPINSCROLL_76
    addw %d1,%d0
    bmis TEPINSCROLL_7A
TEPINSCROLL_76:         /* adjust */
    subw %d0,%a2@(2)
TEPINSCROLL_7A:         /* scroll, show the caret */
    movel %a2@+,%d3
    bsrw TESCROLL_12
    bsrw TESCROLL_3E_2
    braw TESCROLL_C

/* TESELVIEW: _TESelView. */
trap_TESelView:
TESELVIEW:
    jbsr DOMEASURE_186
    jbsr TESELVIEW_A	| 40825202
    jbra TECALTEXT_6	| 40825204

TESELVIEW_A:            /* auto-view on: scroll the selection into view */
    moveal %a3@(66),%a0
    moveal %a0@,%a0
    movel %a0@(16),%d0
    btst #0,%d0
    jbeq TESELVIEW_88
    jbsr TEDISPATCH_8
    movew %a3@(32),%d3
    movew %d3,%d4
    moveq #-2,%d7
    jbsr DOTEXT
    moveal ExpandMem,%a0
    cmpiw #-1,%a0@(46)
    jbne TESELVIEW_3E
    lea %a0@(48),%a0
    movel %a0@,%d7
    jbra TESELVIEW_42
TESELVIEW_3E:           /* the selection rectangle */
    movel %a3@(16),%d7
TESELVIEW_42:           /* the rectangle of the selection's line; scroll if it is outside the view */
    lea OneOne,%a2
    lea %a3@(16),%a0
    movel %a0@-,%a2@-
    movel %a0@-,%a2@-
    movew %a3@(32),%d3
    jbsr XSETKEYBOARD2FONT_24
    subw %d1,%a2@(4)
    subqw #1,%a2@(6)
    subqw #2,%sp
    movel %d7,%sp@-
    movel %a2,%sp@-
    _PtInRect
    tstb %sp@+
    jbne TESELVIEW_88
    movel %a2@+,%sp@-
    movel %a2@,%sp@-
    movel %a2@-,%sp@-
    pea %sp@(4)
    _SubPt
    pea %sp@(4)
    _AddPt
    movel %d7,%sp@-
    pea %sp@(4)
    _SubPt
    movel %a4,%sp@-
    _TEPinScroll
TESELVIEW_88:           /* return */
    rts

/* TEAUTOVIEW: _TEAutoView. */
trap_TEAutoView:
TEAUTOVIEW:
    jbsr DOMEASURE_186
    moveal %a3@(66),%a0	| 4082528C
    moveal %a0@,%a0	| 40825290
    movel %a0@(16),%d0	| 40825292
    tstb %a2@+	| 40825296
    jbeq TEAUTOVIEW_18	| 40825298
    bset #0,%d0	| 4082529A
    jbra TEAUTOVIEW_1C	| 4082529E
TEAUTOVIEW_18:          /* off */
    bclr #0,%d0	| 408252A0
TEAUTOVIEW_1C:          /* store the flags */
    movel %d0,%a0@(16)	| 408252A4
    jbra TEKEY_F4	| 408252A8

/* ITEFEATUREFLAG: _TEFeatureFlag. */
ITEFEATUREFLAG:
    moveq #0,%d0	| 408252AC
    moveq #0,%d1	| 408252AE
    movew %a2@+,%d0	| 408252B0
    movew %a2@+,%d1	| 408252B2
    moveal %a3@(66),%a0	| 408252B4
    moveal %a0@,%a0	| 408252B8
    btst %d1,%a0@(16)	| 408252BA
    sne %a2@	| 408252BE
    tstw %d0	| 408252C0
    jblt ITEFEATUREFLAG_24	| 408252C2
    jbeq ITEFEATUREFLAG_20	| 408252C4
    bset %d1,%a0@(16)	| 408252C6
    jbra ITEFEATUREFLAG_24	| 408252CA
ITEFEATUREFLAG_20:      /* clear the feature */
    bclr %d1,%a0@(16)	| 408252CC
ITEFEATUREFLAG_24:      /* return */
    moveq #10,%d0	| 408252D0
    jbra TECALTEXT_E	| 408252D2
ITEFEATUREFLAG_2A:      /* the default click loop (+42): with auto-view on, scroll when the mouse leaves the view */
    moveml %d0-%a4,%sp@-	| 408252D6
    moveal %a3@(66),%a0	| 408252DA
    moveal %a0@,%a0	| 408252DE
    movel %a0@(16),%d0	| 408252E0
    btst #0,%d0	| 408252E4
    jbeq ITEFEATUREFLAG_82	| 408252E8
    lea %a3@(16),%a0	| 408252EA
    lea OneOne,%a2	| 408252EE
    movel %a0@-,%a2@-	| 408252F2
    movel %a0@-,%a2@-	| 408252F4
    subqw #4,%sp	| 408252F6
    movel %sp,%sp@-	| 408252F8
    _GetMouse	| 408252FA
    movew %sp@+,%d6	| 408252FC
    movew %sp@+,%d7	| 408252FE
    moveq #0,%d4	| 40825300
    movew %a3@(24),%d1	| 40825302
    jbpl ITEFEATUREFLAG_72	| 40825306
    movew %d6,%d0	| 40825308
    cmpw %a3@(4),%d0	| 4082530A
    jble ITEFEATUREFLAG_68	| 4082530E
    movew %a3@(4),%d0	| 40825310
ITEFEATUREFLAG_68:      /* the click-loop hook: auto-scroll when the mouse leaves the view */
    jbsr DOMEASURE_114	| 40825314
    jbge ITEFEATUREFLAG_82	| 40825318
    jbsr LINERECT_A4	| 4082531A
ITEFEATUREFLAG_72:      /* which side of the view is the mouse on? */
    cmpw %a2@+,%d6	| 4082531E
    jblt ITEFEATUREFLAG_8C	| 40825320
    cmpw %a2@+,%d7	| 40825322
    jblt ITEFEATUREFLAG_90	| 40825324
    cmpw %a2@+,%d6	| 40825326
    jbgt ITEFEATUREFLAG_8A	| 40825328
    cmpw %a2@+,%d7	| 4082532A
    jbgt ITEFEATUREFLAG_8E	| 4082532C
ITEFEATUREFLAG_82:      /* return true */
    moveq #1,%d0	| 4082532E
    moveml %sp@+,%d0-%a4	| 40825330
    rts	| 40825334
ITEFEATUREFLAG_8A:      /* right: scroll left */
    negw %d1	| 40825336
ITEFEATUREFLAG_8C:      /* scroll */
    jbra ITEFEATUREFLAG_92	| 40825338
ITEFEATUREFLAG_8E:      /* below: scroll up */
    negw %d1	| 4082533A
ITEFEATUREFLAG_90:      /* vertical */
    exg %d4,%d1	| 4082533C
ITEFEATUREFLAG_92:      /* TEScroll */
    movew %d4,%sp@-	| 4082533E
    movew %d1,%sp@-	| 40825340
    movel %fp@(8),%sp@-	| 40825342
    _TEPinScroll	| 40825346
    jbra ITEFEATUREFLAG_82	| 40825348

ITEFEATUREFLAG_9E:      /* the run array entry containing offset %d0 (binary search); %d0 = its index */
    moveml %d1-%d4,%sp@-
    addqw #1,%d0
    movew %d0,%d2
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    movew %a0@,%d1
    lea %a0@(20),%a0
    moveq #0,%d0
ITEFEATUREFLAG_B4:      /* binary search the run starts */
    cmpw %d0,%d1
    jbeq ITEFEATUREFLAG_D8
    movew %d1,%d3
    addw %d0,%d3
    lsrw #1,%d3
    moveq #0,%d4
    movew %d3,%d4
    lsll #2,%d4
    cmpw %a0@(0x0,%d4:w),%d2
    jbeq ITEFEATUREFLAG_D6
    jbls ITEFEATUREFLAG_D2
    movew %d3,%d0
    addqw #1,%d0
    jbra ITEFEATUREFLAG_B4
ITEFEATUREFLAG_D2:      /* upper half */
    movew %d3,%d1
    jbra ITEFEATUREFLAG_B4
ITEFEATUREFLAG_D6:      /* lower half */
    movew %d3,%d0
ITEFEATUREFLAG_D8:      /* the run before */
    tstw %d0
    jbeq ITEFEATUREFLAG_DE
    subqw #1,%d0
ITEFEATUREFLAG_DE:      /* its entry */
    moveq #0,%d1
    movew %d0,%d1
    lsll #2,%d1
    addal %d1,%a0
    moveml %sp@+,%d1-%d4
    rts

ITEFEATUREFLAG_EC:      /* the number of runs from %a0 up to offset %d1 */
    movel %a0,%sp@-
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    moveq #0,%d0
    movew %a1@,%d0
    lea %a1@(20),%a1
    lsll #2,%d0
    addal %d0,%a1
    moveq #0,%d0
ITEFEATUREFLAG_102:     /* loop: count the runs up to offset %d1 */
    addql #4,%a0
    addqw #1,%d0
    cmpal %a0,%a1
    jbeq ITEFEATUREFLAG_10E
    cmpw %a0@,%d1
    jbhi ITEFEATUREFLAG_102
ITEFEATUREFLAG_10E:     /* return */
    moveal %sp@+,%a0
    rts

ITEFEATUREFLAG_112:     /* the style table entry of index %d0 (18 bytes each) */
    muluw #18,%d0
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(4),%a0
    moveal %a0@,%a0
    addal %d0,%a0
    rts

ITEFEATUREFLAG_126:     /* add %d5 to the starts of the runs after %a0 */
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    movew %a1@,%d1
    subw %d0,%d1
    jbls ITEFEATUREFLAG_13A
ITEFEATUREFLAG_132:     /* loop */
    addql #4,%a0
    addw %d5,%a0@
    subqw #1,%d1
    jbne ITEFEATUREFLAG_132
ITEFEATUREFLAG_13A:     /* return */
    rts
ITEFEATUREFLAG_13C:     /* no selection: change the null style instead */
    movew %a3@(32),%d0	| 408253E8
    cmpw %a3@(34),%d0	| 408253EC
    jbne ITEFEATUREFLAG_240	| 408253F0

ITEFEATUREFLAG_148:     /* the null style: from the scrap style, or the style at the caret */
    moveal %a3@(74),%a1
    moveal %a1@,%a1
    moveal %a1@(16),%a1
    moveal %a1@,%a1
    moveal %a1@(4),%a1
    movel %a1,%sp@-
    moveal %a1@,%a1
    tstw %a1@
    jbeq ITEFEATUREFLAG_166
    lea %a1@(2),%a1
    jbra ITEFEATUREFLAG_18C
ITEFEATUREFLAG_166:     /* the caret's style as the null style */
    subqw #1,%d0
    jbsr ITEFEATUREFLAG_9E
    movew %a0@(2),%d0
    jbsr ITEFEATUREFLAG_112
    movew #1,%a1@
    lea %a1@(2),%a1
    clrl %a1@
    lea %a0@(6),%a0
    movel %a0@+,%a1@(8)
    movel %a0@+,%a1@(12)
    movel %a0@+,%a1@(16)
ITEFEATUREFLAG_18C:     /* apply the mode bits: font */
    movew %a2@(6),%d2
    moveal %a2@(2),%a0
    btst #0,%d2
    jbeq ITEFEATUREFLAG_1AC
    movew %a0@,%a1@(8)
    movel %a0,%sp@-
    movew %a0@,%d1
    lea %a1@(11),%a0
    jbsr XGETRLPOSITION_2A2
    moveal %sp@+,%a0
ITEFEATUREFLAG_1AC:     /* face (toggle with doToggle) */
    btst #1,%d2
    jbeq ITEFEATUREFLAG_1CE
    moveb %a0@(2),%d0
    btst #5,%d2
    jbeq ITEFEATUREFLAG_1C2
    eorb %d0,%a1@(10)
    jbra ITEFEATUREFLAG_1CE
ITEFEATUREFLAG_1C2:     /* plain */
    tstb %d0
    jbne ITEFEATUREFLAG_1CA
    clrb %a1@(10)
ITEFEATUREFLAG_1CA:     /* add the faces */
    orb %d0,%a1@(10)
ITEFEATUREFLAG_1CE:     /* size */
    btst #2,%d2
    jbeq ITEFEATUREFLAG_1E0
    btst #4,%d2
    jbne ITEFEATUREFLAG_1E0
    movew %a0@(4),%a1@(12)
ITEFEATUREFLAG_1E0:     /* color */
    btst #3,%d2
    jbeq ITEFEATUREFLAG_1F2
    movel %a0@(6),%a1@(14)
    movew %a0@(10),%a1@(18)
ITEFEATUREFLAG_1F2:     /* addSize: add to the size, at least 1 */
    btst #4,%d2
    jbeq ITEFEATUREFLAG_210
    movew %a1@(12),%d0
    jbne ITEFEATUREFLAG_202
    moveb FMDefaultSize,%d0
ITEFEATUREFLAG_202:     /* add */
    addw %a0@(4),%d0
    jbgt ITEFEATUREFLAG_20C
    movew #1,%d0
ITEFEATUREFLAG_20C:     /* store */
    movew %d0,%a1@(12)
ITEFEATUREFLAG_210:     /* the line height and ascent of the new style */
    moveal %a3@(82),%a0
    movew %a1@(8),%a0@(68)
    movew %a1@(10),%a0@(70)
    bclr #7,%a0@(71)
    movew %a1@(12),%a0@(74)
    jbsr TESETTEXT_E8
    moveal %sp@+,%a0
    moveal %a0@,%a0
    lea %a0@(2),%a0
    movew %d0,%a0@(6)
    movew %d1,%a0@(4)
ITEFEATUREFLAG_240:     /* return */
    rts

/* ITESETSTYLE: _TESetStyle. */
ITESETSTYLE:
    tstw %a3@(80)	| 408254EE
    jbpl ITESETSTYLE_42	| 408254F2
    jbsr ITEFEATUREFLAG_13C	| 408254F4
    cmpiw #1,%a2@(6)	| 408254F8
    jbne ITESETSTYLE_16	| 408254FE
    jbsr XSETFONT2KEYBOARD_7C	| 40825500
ITESETSTYLE_16:         /* no redraw: just set the style */
    movew %a2@+,%d0	| 40825504
    andiw #-256,%d0	| 40825506
    jbne ITESETSTYLE_22	| 4082550A
    jbsr ITESETSTYLE_48	| 4082550C
    jbra ITESETSTYLE_42	| 4082550E
ITESETSTYLE_22:         /* redraw: unhilite, set the style, recalculate and redraw */
    movel %a2,%sp@-	| 40825510
    jbsr HIDECARET	| 40825512
    jbsr TEUPDATE_1C	| 40825516
    moveal %sp@+,%a2	| 4082551A
    jbsr ITESETSTYLE_48	| 4082551C
    moveq #0,%d7	| 4082551E
    jbsr TEDELETE_118	| 40825520
    jbsr XRECALLINES_2D8	| 40825524
    jbsr TEUPDATE_1C	| 40825528
    jbsr TESELVIEW_A	| 4082552C
ITESETSTYLE_42:         /* return */
    moveq #14,%d0	| 40825530
    jbra TECALTEXT_E	| 40825532
ITESETSTYLE_48:         /* TESetStyle body: with doToggle and face (mode bits 34), the continuous faces first */
    moveml %d2-%d7/%a2/%a4/%fp,%sp@-	| 40825536
    moveal %a2@+,%a4	| 4082553A
    movew %a2@+,%d7	| 4082553C
    subal %fp,%fp	| 4082553E
    andiw #63,%d7	| 40825540
    movew %d7,%d0	| 40825544
    andiw #34,%d0	| 40825546
    cmpiw #34,%d0	| 4082554A
    jbne ITESETSTYLE_88	| 4082554E
    subqw #1,%fp	| 40825550
    movew #2,%sp@-	| 40825552
    subaw #14,%sp	| 40825556
    pea %sp@(14)	| 4082555A
    pea %sp@(6)	| 4082555E
    moveal %sp,%a2
    jbsr TEGETOFFSET_2FE
    lea %sp@(10),%sp
    moveb %sp@(2),%d5
    swap %d5
    lea %sp@(14),%sp
ITESETSTYLE_88:         /* restore registers, return */
    jbsr ITESETSTYLE_90
    moveml %sp@+,%d2-%d7/%a2/%a4/%fp
    rts

ITESETSTYLE_90:         /* vectored (ExpandMem +244) */
    moveal ExpandMem,%a0
    moveal %a0@(244),%a0
    jmp %a0@
ITESETSTYLE_9A:         /* per run of the selection: apply the style */
    tstw %d7	| 40825588
    jbeq ITESETSTYLE_1F2	| 4082558A
    jbsr TEDISPATCH_8	| 4082558E
    movew %d0,%d1	| 40825592
    movew %d0,%d4	| 40825594
    swap %d0	| 40825596
    movew %d0,%d3	| 40825598
    subw %d3,%d1	| 4082559A
    jbeq ITESETSTYLE_1F2	| 4082559C
    subaw #18,%sp	| 408255A0
    moveal %sp,%a2	| 408255A4
    jbsr ITEFEATUREFLAG_9E	| 408255A6
    movew %d4,%d1	| 408255AA
    jbsr ITEFEATUREFLAG_EC	| 408255AC
    movew %d0,%d2	| 408255B0
    swap %d3	| 408255B2
    movew %d4,%d3	| 408255B4
    moveb %a4@(2),%d4	| 408255B6
    swap %d4	| 408255BA
    movew %a4@,%d4	| 408255BC
    movew %a4@(4),%d5	| 408255BE
    movel %a4@(6),%d6	| 408255C2
    swap %d7	| 408255C6
    movew %a4@(10),%d7	| 408255C8
    swap %d7	| 408255CC
    moveal %a2,%a4	| 408255CE
    moveal %a0,%a2	| 408255D0
    moveal %a3@(74),%a0	| 408255D2
    _HLock	| 408255D6
ITESETSTYLE_EA:         /* copy the run's style, change it */
    movew %a2@(2),%d0	| 408255D8
    jbsr ITEFEATUREFLAG_112	| 408255DC
    jbsr ITESETSTYLE_3B6	| 408255E0
    tstw %d0	| 408255E4
    jbeq ITESETSTYLE_1DC	| 408255E6
    moveq #18,%d0	| 408255EA
    moveal %a4,%a1	| 408255EC
    _BlockMove	| 408255EE
    moveal %a2,%a0	| 408255F0
    movel %d3,%d0	| 408255F2
    swap %d0	| 408255F4
    cmpw %a2@,%d0	| 408255F6
    jbls ITESETSTYLE_114	| 408255F8
    jbsr TEPASTE_220	| 408255FA
    addqw #4,%a0	| 408255FE
    moveal %a0,%a2	| 40825600
ITESETSTYLE_114:        /* split at the selection start */
    cmpiw #1,%d2	| 40825602
    jbne ITESETSTYLE_12A	| 40825606
    addqw #4,%a0	| 40825608
    cmpw %a0@,%d3	| 4082560A
    jbeq ITESETSTYLE_12A	| 4082560C
    movew %d3,%d0	| 4082560E
    moveal %a2,%a0	| 40825610
    jbsr TEPASTE_220	| 40825612
    moveal %a0,%a2	| 40825616
ITESETSTYLE_12A:        /* one use less of the old style; font */
    moveq #1,%d0	| 40825618
    moveal %a2,%a0	| 4082561A
    jbsr TEDELETE_FE	| 4082561C
    btst #0,%d7	| 40825620
    jbeq ITESETSTYLE_14A	| 40825624
    movew %d4,%a4@(6)	| 40825626
    movel %a0,%sp@-	| 4082562A
    movew %d4,%d1	| 4082562C
    lea %a4@(9),%a0	| 4082562E
    jbsr XGETRLPOSITION_2A2	| 40825632
    moveal %sp@+,%a0	| 40825636
ITESETSTYLE_14A:        /* face */
    btst #1,%d7	| 40825638
    jbeq ITESETSTYLE_180	| 4082563C
    movel %d4,%d0	| 4082563E
    swap %d0	| 40825640
    movel %fp,%d1	| 40825642
    jbeq ITESETSTYLE_174	| 40825644
    addql #1,%d1	| 40825646
    jbeq ITESETSTYLE_162	| 40825648
    moveb %d0,%a4@(8)	| 4082564A
    jbra ITESETSTYLE_180	| 4082564E
ITESETSTYLE_162:        /* toggle */
    movel %d5,%d1	| 40825650
    swap %d1	| 40825652
    andb %d0,%d1	| 40825654
    eorb %d1,%d0	| 40825656
    orb %d0,%a4@(8)	| 40825658
    eorb %d1,%a4@(8)	| 4082565C
    jbra ITESETSTYLE_180	| 40825660
ITESETSTYLE_174:        /* plain */
    tstb %d0	| 40825662
    jbne ITESETSTYLE_17C	| 40825664
    clrb %a4@(8)	| 40825666
ITESETSTYLE_17C:        /* add the faces */
    orb %d0,%a4@(8)	| 4082566A
ITESETSTYLE_180:        /* size */
    btst #2,%d7	| 4082566E
    jbeq ITESETSTYLE_190	| 40825672
    btst #4,%d7	| 40825674
    jbne ITESETSTYLE_190	| 40825678
    movew %d5,%a4@(10)	| 4082567A
ITESETSTYLE_190:        /* color */
    btst #3,%d7	| 4082567E
    jbeq ITESETSTYLE_1A2	| 40825682
    movel %d6,%a4@(12)	| 40825684
    swap %d7	| 40825688
    movew %d7,%a4@(16)	| 4082568A
    swap %d7	| 4082568E
ITESETSTYLE_1A2:        /* addSize: add to the size, at least 1 */
    btst #4,%d7	| 40825690
    jbeq ITESETSTYLE_1C2	| 40825694
    movew %a4@(10),%d0	| 40825696
    jbne ITESETSTYLE_1B6	| 4082569A
    moveb FMDefaultSize,%d0	| 4082569C
    movew %d0,%a4@(10)	| 408256A0
ITESETSTYLE_1B6:        /* add */
    addw %d5,%d0	| 408256A4
    jbgt ITESETSTYLE_1BE	| 408256A6
    movew #1,%d0	| 408256A8
ITESETSTYLE_1BE:        /* store */
    movew %d0,%a4@(10)	| 408256AC
ITESETSTYLE_1C2:        /* find or add the new style in the style table */
    moveal %a4,%a0	| 408256B0
    jbsr TEPASTE_258	| 408256B2
    tstl %d0	| 408256B6
    jbne ITESETSTYLE_1D8	| 408256B8
    moveal %a4,%a0	| 408256BA
    jbsr ITESETSTYLE_1F4	| 408256BC
    movew #1,%a0@	| 408256BE
    jbsr TEPASTE_2AC	| 408256C2
ITESETSTYLE_1D8:        /* the run takes it */
    movew %d0,%a2@(2)	| 408256C6
ITESETSTYLE_1DC:        /* next run; merge equal neighbours, fix the line heights */
    addqw #4,%a2	| 408256CA
    subqw #1,%d2	| 408256CC
    jbne ITESETSTYLE_EA	| 408256CE
    moveal %a3@(74),%a0	| 408256D2
    _HUnlock	| 408256D6
    jbsr ITESETSTYLE_304	| 408256D8
    addaw #18,%sp	| 408256DC
ITESETSTYLE_1F2:        /* return */
    rts	| 408256E0

ITESETSTYLE_1F4:        /* the line height and ascent of a style entry (from the font) */
    movel %d2,%sp@-
    moveal %a3@(82),%a1
    movew %a0@(6),%a1@(68)
    movew %a0@(8),%a1@(70)
    bclr #7,%a1@(71)
    movew %a0@(10),%a1@(74)
    jbsr TESETTEXT_E8
    movew %d0,%a0@(4)
    movew %d1,%a0@(2)
    movel %sp@+,%d2
    rts

ITESETSTYLE_222:        /* the null-style scrap: Z set if it holds no style */
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(16),%a0
    moveal %a0@,%a0
    moveal %a0@(4),%a0
    moveal %a0@,%a0
    tstw %a0@
    rts

ITESETSTYLE_238:        /* the style entry at offset %d0; at an insertion point: the null style if set */
    cmpw %a3@(32),%d0
    jbne ITESETSTYLE_24E
    cmpw %a3@(34),%d0
    jbne ITESETSTYLE_24E
    jbsr ITESETSTYLE_222
    jbeq ITESETSTYLE_24E
    lea %a0@(4),%a0
    rts
ITESETSTYLE_24E:        /* the style entry of the run containing %d0 */
    jbsr ITEFEATUREFLAG_9E
    movew %a0@(2),%d0
    jbsr ITEFEATUREFLAG_112
    rts
/* TEGETSTYLE (ITESETSTYLE_25C): TEDispatch: TEGetStyle: the style, line height and ascent at an offset. */
ITESETSTYLE_25C:        /* TEGetStyle */
    tstw %a3@(80)	| 4082574A
    jbpl ITESETSTYLE_298	| 4082574E
    movel %a2@+,%sp@-	| 40825750
    movel %a2@+,%sp@-	| 40825752
    movel %a2@+,%sp@-	| 40825754
    movew %a2@,%d0	| 40825756
    jbsr ITESETSTYLE_24E	| 40825758
    moveal %sp@+,%a1	| 4082575A
    movew %a0@(6),%a1@+	| 4082575C
    movew %a0@(8),%a1@+	| 40825760
    clrb %a1@(-1)	| 40825764
    movew %a0@(10),%a1@+	| 40825768
    moveal %a0,%a2	| 4082576C
    lea %a0@(12),%a0	| 4082576E
    movew %a0@+,%a1@+	| 40825772
    movew %a0@+,%a1@+	| 40825774
    movew %a0@,%a1@	| 40825776
    moveal %sp@+,%a1	| 40825778
    movew %a2@(2),%a1@	| 4082577A
    moveal %sp@+,%a1	| 4082577E
    movew %a2@(4),%a1@	| 40825780
    jbra ITESETSTYLE_2BA	| 40825784
ITESETSTYLE_298:        /* unstyled: the port's text settings and the record's height and ascent */
    jbsr TESETTEXT_E8	| 40825786
    moveal %a2@+,%a0	| 4082578A
    movew %d0,%a0@	| 4082578C
    moveal %a2@+,%a0	| 4082578E
    movew %d1,%a0@	| 40825790
    moveal %a2@,%a0	| 40825792
    moveal %a3@(82),%a1	| 40825794
    movew %a1@(68),%a0@+	| 40825798
    movew %a1@(70),%a0@+	| 4082579C
    movew %a1@(74),%a0@+	| 408257A0
    pea %a0@	| 408257A4
    _GetForeColor	| 408257A6
ITESETSTYLE_2BA:        /* return */
    moveq #20,%d0	| 408257A8
    jbra TECALTEXT_E	| 408257AA

ITESETSTYLE_2C0:        /* set the port's text font, face, size and color from the style of run %a0 */
    movel %a0,%sp@-
    movew %a0@(2),%d0
    jbsr ITEFEATUREFLAG_112
    moveal %a3@(82),%a1
    movew %a0@(6),%a1@(68)
    movew %a0@(8),%a1@(70)
    bclr #7,%a1@(71)
    movew %a0@(10),%a1@(74)
    moveal %a3@(74),%a1
    movel %a1@,%d0
    subl %d0,%sp@
    movew %d2,%sp@-
    pea %a0@(12)
    _RGBForeColor
    movew %sp@+,%d2
    moveal %a3@(74),%a1
    movel %a1@,%d0
    addl %d0,%sp@
    moveal %sp@+,%a0
    rts

ITESETSTYLE_304:        /* merge neighbouring runs with the same style; fix the run count */
    moveml %d2-%d3/%a2,%sp@-
    moveal %a3@(74),%a0
    moveal %a0@,%a0
    moveal %a0@(4),%a2
ITESETSTYLE_312:        /* merge neighbouring runs with the same style */
    moveal %a2@,%a2
    movew %a0@,%d0
    addqw #1,%d0
    lea %a0@(20),%a0
    moveal %a0,%a1
    moveq #0,%d2
    movew %a0@(2),%d1
ITESETSTYLE_324:        /* loop over the runs */
    subqw #1,%d0
    jbeq ITESETSTYLE_34A
    addqw #1,%d2
    addql #4,%a1
    cmpw %a1@(2),%d1
    jbeq ITESETSTYLE_324
    subqw #1,%d2
    jbeq ITESETSTYLE_340
    muluw #18,%d1
    subw %d2,%a2@(0x0,%d1:l)
    moveq #0,%d2
ITESETSTYLE_340:        /* keep this run */
    addql #4,%a0
    movel %a1@,%a0@
    movew %a0@(2),%d1
    jbra ITESETSTYLE_324
ITESETSTYLE_34A:        /* the new run count; return */
    subal %a0,%a1
    movel %a1,%d0
    moveal %a3@(74),%a0
    moveal %a0@,%a1
    asrl #2,%d0
    subw %d0,%a1@
    moveml %sp@+,%d2-%d3/%a2
    rts

ITESETSTYLE_35E:        /* vectored (ExpandMem +248) */
    moveal ExpandMem,%a0
    moveal %a0@(248),%a0
    jmp %a0@
ITESETSTYLE_368:        /* a last run that starts at or after the end of the text: remove it */
    tstw %a3@(80)	| 40825856
    jbpl ITESETSTYLE_3B4	| 4082585A
    movel %a2,%sp@-	| 4082585C
    moveal %a3@(74),%a0	| 4082585E
    moveal %a0@,%a0	| 40825862
    moveal %a0@(4),%a2	| 40825864
    moveal %a2@,%a2	| 40825868
    movew %a0@,%d0	| 4082586A
    jbeq ITESETSTYLE_3B2	| 4082586C
    subqw #1,%d0	| 4082586E
    jbeq ITESETSTYLE_3B2	| 40825870
    lslw #2,%d0	| 40825872
    lea %a0@(0x14,%d0:w),%a0	| 40825874
    movew %a3@(60),%d0	| 40825878
    cmpw %a0@,%d0	| 4082587C
    jbgt ITESETSTYLE_3B2	| 4082587E
    moveq #0,%d1	| 40825880
    movew %a0@(2),%d1	| 40825882
    muluw #18,%d1	| 40825886
    subqw #1,%a2@(0,%d1:l)	| 4082588A
    addqw #1,%d0	| 4082588E
    movew %d0,%a0@	| 40825890
    movew #-1,%a0@(2)	| 40825892
    moveal %a3@(74),%a0	| 40825898
    moveal %a0@,%a0	| 4082589C
    subqw #1,%a0@	| 4082589E
ITESETSTYLE_3B2:        /* restore %a2 */
    moveal %sp@+,%a2	| 408258A0
ITESETSTYLE_3B4:        /* return */
    rts	| 408258A2
ITESETSTYLE_3B6:        /* does the style at %a0 match the one being replaced (by the mode bits)? font */
    moveq #1,%d0	| 408258A4
    cmpaw #0,%fp	| 408258A6
    jbeq ITESETSTYLE_40E	| 408258AA
    cmpaw #-1,%fp	| 408258AC
    jbeq ITESETSTYLE_40E	| 408258B0
    btst #0,%d7	| 408258B2
    jbeq ITESETSTYLE_3D2	| 408258B6
    movew %fp@,%d1	| 408258B8
    cmpw %a0@(6),%d1	| 408258BA
    jbne ITESETSTYLE_40C	| 408258BE
ITESETSTYLE_3D2:        /* face */
    btst #1,%d7	| 408258C0
    jbeq ITESETSTYLE_3E2	| 408258C4
    moveb %fp@(2),%d1	| 408258C6
    cmpb %a0@(8),%d1	| 408258CA
    jbne ITESETSTYLE_40C	| 408258CE
ITESETSTYLE_3E2:        /* size */
    btst #2,%d7	| 408258D0
    jbeq ITESETSTYLE_3F2	| 408258D4
    movew %fp@(4),%d1	| 408258D6
    cmpw %a0@(10),%d1	| 408258DA
    jbne ITESETSTYLE_40C	| 408258DE
ITESETSTYLE_3F2:        /* color */
    btst #3,%d7	| 408258E0
    jbeq ITESETSTYLE_40E	| 408258E4
    movel %fp@(6),%d1	| 408258E6
    cmpl %a0@(12),%d1	| 408258EA
    jbne ITESETSTYLE_40C	| 408258EE
    movew %fp@(10),%d1	| 408258F0
    cmpw %a0@(16),%d1	| 408258F4
    jbeq ITESETSTYLE_40E	| 408258F8
ITESETSTYLE_40C:        /* no match */
    moveq #0,%d0	| 408258FA
ITESETSTYLE_40E:        /* return */
    rts	| 408258FC
/* TEREPLACESTYLE (ITESETSTYLE_410): TEDispatch: TEReplaceStyle: in the selection, replace one
 style by another. */
ITESETSTYLE_410:        /* TEReplaceStyle */
    tstw %a3@(80)	| 408258FE
    jbpl ITESETSTYLE_442	| 40825902
    movew %a2@+,%d0	| 40825904
    andiw #-256,%d0	| 40825906
    jbne ITESETSTYLE_422	| 4082590A
    jbsr ITESETSTYLE_448	| 4082590C
    jbra ITESETSTYLE_442	| 4082590E
ITESETSTYLE_422:        /* redraw: unhilite, replace, recalculate and redraw */
    movel %a2,%sp@-	| 40825910
    jbsr HIDECARET	| 40825912
    jbsr TEUPDATE_1C	| 40825916
    moveal %sp@+,%a2	| 4082591A
    jbsr ITESETSTYLE_448	| 4082591C
    moveq #0,%d7	| 4082591E
    jbsr TEDELETE_118	| 40825920
    jbsr XRECALLINES_2D8	| 40825924
    jbsr TEUPDATE_1C	| 40825928
    jbsr TESELVIEW_A	| 4082592C
ITESETSTYLE_442:        /* return */
    moveq #18,%d0	| 40825930
    jbra TECALTEXT_E	| 40825932
ITESETSTYLE_448:        /* TEReplaceStyle body: old style %fp, new style %a4, mode %d7 (low 5 bits) */
    moveml %d2-%d7/%a2/%a4/%fp,%sp@-	| 40825936
    moveal %a2@+,%a4
    moveal %a2@+,%fp
    movew %a2@+,%d7
    andiw #31,%d7
    jbsr ITESETSTYLE_90
    moveml %sp@+,%d2-%d7/%a2/%a4/%fp
    rts

/* TEGETOFFSET: _TEGetOffset. */
trap_TEGetOffset:
TEGETOFFSET:
    jbsr DOMEASURE_186
    movel %a3@(28),%sp@-	| 40825952
    movel %a2@+,%a3@(28)
    bsrw DOFIND
    movew %d6,%a2@
    movel %sp@+,%a3@(28)
    braw TESCROLL_C
/* GETSTYLHANDLE (trap_TEGetOffset_1A): TEDispatch: GetStylHandle: the style handle, or nil. */
trap_TEGetOffset_1A:    /* GetStylHandle */
    clrl %a2@	| 40825968
    tstw %a3@(80)	| 4082596A
    jbpl TEGETOFFSET_26	| 4082596E
    movel %a3@(74),%a2@	| 40825970
TEGETOFFSET_26:         /* return */
    moveq #6,%d0	| 40825974
    jbra TECALTEXT_E	| 40825976
/* SETSTYLHANDLE (TEGETOFFSET_2C): TEDispatch: SetStylHandle: install a style handle. */
TEGETOFFSET_2C:         /* SetStylHandle */
    tstw %a3@(80)	| 4082597A
    jbpl TEGETOFFSET_3C	| 4082597E
    moveal %a3@(74),%a0	| 40825980
    _DisposHandle	| 40825984
    movel %a2@,%a3@(74)	| 40825986
TEGETOFFSET_3C:         /* return */
    moveq #10,%d0	| 4082598A
    jbra TECALTEXT_E	| 4082598C
/* TEGETPOINT (TEGETOFFSET_42): TEDispatch: TEGetPoint: the point (baseline, left edge) of an offset. */
TEGETOFFSET_42:         /* TEGetPoint */
    movew %a2@+,%d0	| 40825990
    movel %a2,%sp@-	| 40825992
    movew %d0,%sp@-	| 40825994
    cmpw %a3@(60),%d0	| 40825996
    jbcs TEGETOFFSET_56	| 4082599A
    movew %a3@(60),%d0	| 4082599C
    movew %d0,%sp@	| 408259A0
    subqw #1,%d0	| 408259A2
TEGETOFFSET_56:         /* its line; past the end: the end of the last line, or a new line after a return */
    lea %a3@(96),%a2	| 408259A4
    jbsr PREPLINE_42	| 408259A8
    movew %fp@(-4),%sp@-	| 408259AC
    jbsr LINERECT	| 408259B0
    movew %sp@+,%fp@(-4)	| 408259B4
    movew %a2@,%d6	| 408259B8
    movew %sp@+,%d7	| 408259BA
    cmpw %a3@(60),%d7	| 408259BC
    jbne TEGETOFFSET_AE	| 408259C0
    moveal %a3@(62),%a0	| 408259C2
    moveal %a0@,%a0	| 408259C6
    cmpib #13,%a0@(-1,%d7:w)	| 408259C8
    jbne TEGETOFFSET_AE	| 408259CE
    movew %a3@(18),%d0	| 408259D0
    movew %a3@(58),%d1	| 408259D4
    jbne TEGETOFFSET_98	| 408259D8
    movew TESysJust,%d1	| 408259DA
    jbeq TEGETOFFSET_B6	| 408259DE
    cmpiw #-2,%d1	| 408259E0
    jbeq TEGETOFFSET_B6	| 408259E4
TEGETOFFSET_98:         /* justified empty line: centre or right */
    movew %a3@(6),%d0	| 408259E6
    subqw #1,%d0	| 408259EA
    tstw %d1	| 408259EC
    jbmi TEGETOFFSET_B6	| 408259EE
    subw %a3@(2),%d0	| 408259F0
    asrw #1,%d0	| 408259F4
    addw %a3@(2),%d0	| 408259F6
    jbra TEGETOFFSET_B6	| 408259FA
TEGETOFFSET_AE:         /* the width up to the offset */
    jbsr MEASUREIT	| 408259FC
    addw %a3@(18),%d0	| 40825A00
TEGETOFFSET_B6:         /* store the point; return */
    moveal %sp@+,%a2	| 40825A04
    movew %a3@(20),%a2@+	| 40825A06
    movew %d0,%a2@	| 40825A0A
    moveq #8,%d0	| 40825A0C
    jbra TECALTEXT_E	| 40825A0E
/* GETSTYLSCRAP (TEGETOFFSET_C4): TEDispatch: GetStylScrap: the styles of the selection as a
 'styl' scrap handle (the null style at an insertion point). */
TEGETOFFSET_C4:         /* GetStylScrap */
    clrl %a2@	| 40825A12
    tstw %a3@(80)	| 40825A14
    jbpl TEGETOFFSET_10C	| 40825A18
    movew %a3@(32),%d0	| 40825A1A
    movew %a3@(34),%d1	| 40825A1E
    cmpw %d0,%d1	| 40825A22
    jbne TEGETOFFSET_FA	| 40825A24
    moveq #22,%d0	| 40825A26
    jbsr TESTYLNEW_F4	| 40825A28
    movel %a0,%a2@	| 40825A2C
    moveal %a0@,%a1	| 40825A2E
    movew #1,%a1@+	| 40825A30
    clrl %a1@+	| 40825A34
    movew %a3@(32),%d0	| 40825A36
    jbsr ITESETSTYLE_238	| 40825A3A
    lea %a0@(2),%a0	| 40825A3E
    moveq #16,%d0	| 40825A42
    _BlockMove	| 40825A44
    jbra TEGETOFFSET_10C	| 40825A46
TEGETOFFSET_FA:         /* order the selection */
    jbcc TEGETOFFSET_FE	| 40825A48
    exg %d0,%d1	| 40825A4A
TEGETOFFSET_FE:         /* the selection's 'styl' scrap, stored in the result */
    moveml %d2-%d5/%a2/%a5,%sp@-	| 40825A4C
    jbsr TECOPY_86	| 40825A50
    moveml %sp@+,%d2-%d5/%a2/%a5	| 40825A54
    movel %a4,%a2@	| 40825A58
TEGETOFFSET_10C:        /* return */
    moveq #6,%d0	| 40825A5A
    jbra TECALTEXT_E	| 40825A5C
/* SETSTYLSCRAP (TEGETOFFSET_112): TEDispatch: SetStylScrap: apply a 'styl' scrap to a range. */
TEGETOFFSET_112:        /* SetStylScrap */
    tstw %a3@(80)	| 40825A60
    jbpl TEGETOFFSET_1CC	| 40825A64
    movew %a2@+,%d5	| 40825A68
    andiw #-256,%d5	| 40825A6A
    sne %d5	| 40825A6E
    jbeq TEGETOFFSET_12C	| 40825A70
    jbsr HIDECARET	| 40825A72
    jbsr TEUPDATE_1C	| 40825A76
TEGETOFFSET_12C:        /* lock the scrap; the range */
    moveal %a2@+,%a1	| 40825A7A
    movel %a1,%sp@-	| 40825A7C
    moveal %a1,%a0	| 40825A7E
    _HGetState	| 40825A80
    moveb %d0,%sp@-	| 40825A82
    moveal %a1,%a0	| 40825A84
    _HLock	| 40825A86
    moveal %a1@,%a1	| 40825A88
    movel %a2@+,%d7	| 40825A8A
    movel %a2@,%d6	| 40825A8C
    cmpl %d6,%d7	| 40825A8E
    jbcc TEGETOFFSET_146	| 40825A90
    exg %d6,%d7	| 40825A92
TEGETOFFSET_146:        /* pin the range to the text */
    moveq #0,%d0	| 40825A94
    movew %a3@(60),%d0	| 40825A96
    cmpl %d0,%d6	| 40825A9A
    jbls TEGETOFFSET_152	| 40825A9C
    movel %d0,%d6	| 40825A9E
TEGETOFFSET_152:        /* end */
    cmpl %d0,%d7	| 40825AA0
    jbls TEGETOFFSET_158	| 40825AA2
    movel %d0,%d7	| 40825AA4
TEGETOFFSET_158:        /* per scrap run */
    movel %d6,%d3	| 40825AA6
    movel %a3@(32),%sp@-	| 40825AA8
    movew %a1@+,%d4	| 40825AAC
    jbra TEGETOFFSET_1A8	| 40825AAE
TEGETOFFSET_162:        /* the run's range as the selection */
    cmpl %d3,%d7	| 40825AB0
    jbls TEGETOFFSET_1AC	| 40825AB2
    movew %d3,%a3@(32)	| 40825AB4
    tstw %d4	| 40825AB8
    jbne TEGETOFFSET_172	| 40825ABA
    movel %d7,%d0	| 40825ABC
    jbra TEGETOFFSET_17C	| 40825ABE
TEGETOFFSET_172:        /* up to the next run */
    movel %d6,%d0	| 40825AC0
    addl %a1@(20),%d0	| 40825AC2
    cmpl %d7,%d0	| 40825AC6
    jbls TEGETOFFSET_17E	| 40825AC8
TEGETOFFSET_17C:        /* up to the end */
    movel %d7,%d0	| 40825ACA
TEGETOFFSET_17E:        /* apply the run's style (all attributes) */
    movew %d0,%a3@(34)	| 40825ACC
    movel %d0,%d3	| 40825AD0
    moveml %d3-%d7/%a1/%a4/%fp,%sp@-	| 40825AD2
    movew %a3@(32),%d0	| 40825AD6
    jbsr ITESETSTYLE_24E	| 40825ADA
    lea %a0@(6),%fp	| 40825ADE
    lea %a1@(8),%a4	| 40825AE2
    movew #15,%d7	| 40825AE6
    jbsr ITESETSTYLE_90	| 40825AEA
    moveml %sp@+,%d3-%d7/%a1/%a4/%fp	| 40825AEE
    lea %a1@(20),%a1	| 40825AF2
TEGETOFFSET_1A8:        /* next run */
    dbf %d4,TEGETOFFSET_162	| 40825AF6
TEGETOFFSET_1AC:        /* restore the selection and the scrap's state; redraw */
    movel %sp@+,%a3@(32)	| 40825AFA
    moveb %sp@+,%d0	| 40825AFE
    moveal %sp@+,%a0	| 40825B00
    _HSetState	| 40825B02
    tstb %d5	| 40825B04
    jbeq TEGETOFFSET_1CC	| 40825B06
    moveq #0,%d7	| 40825B08
    jbsr TEDELETE_118	| 40825B0A
    jbsr XRECALLINES_2D8	| 40825B0E
    jbsr TEUPDATE_1C	| 40825B12
    jbsr TESELVIEW_A	| 40825B16
TEGETOFFSET_1CC:        /* return */
    moveq #20,%d0	| 40825B1A
    jbra TECALTEXT_E	| 40825B1C
/* TESTYLINSERT (TEGETOFFSET_1D2): TEDispatch: TEStylInsert: insert text with its styles. */
TEGETOFFSET_1D2:        /* TEStylInsert */
    jbsr HIDECARET	| 40825B20
    jbsr TEUPDATE_1C	| 40825B24
    movel %a2@+,%d0	| 40825B28
    moveq #0,%d7	| 40825B2A
    moveml %a2@+,%d5-%d6	| 40825B2C
    tstl %d5	| 40825B30
    jbeq TEGETOFFSET_244	| 40825B32
    tstl %d0	| 40825B34
    jbeq TEGETOFFSET_234	| 40825B36
    moveal %d0,%a2	| 40825B38
    tstw %a3@(80)	| 40825B3A
    jbpl TEGETOFFSET_234	| 40825B3E
    jbsr TEPASTE_2FE	| 40825B40
    clrl %sp@-	| 40825B44
    movel %d6,%sp@-	| 40825B46
    movel %d5,%sp@-	| 40825B48
    _Munger	| 40825B4A
    addql #4,%sp	| 40825B4C
    addw %d5,%a3@(60)	| 40825B4E
    moveal %a3@(62),%a0	| 40825B52
    _HLock	| 40825B56
    moveal %a2,%a0	| 40825B58
    _HGetState	| 40825B5A
    moveb %d0,%sp@-	| 40825B5C
    _HLock	| 40825B5E
    moveml %d2-%d6/%a2/%a4,%sp@-	| 40825B60
    moveal %a2,%a4	| 40825B64
    moveq #0,%d3	| 40825B66
    movew %a3@(32),%d3	| 40825B68
    jbsr TEPASTE_158	| 40825B6C
    moveml %sp@+,%d2-%d6/%a2/%a4	| 40825B70
    moveb %sp@+,%d0	| 40825B74
    moveal %a2,%a0	| 40825B76
    _HSetState	| 40825B78
    jbsr ITESETSTYLE_35E	| 40825B7A
    subw %d5,%d7	| 40825B7E
    jbra TEGETOFFSET_238	| 40825B80
TEGETOFFSET_234:        /* insert the text */
    jbsr TEPASTE_35C	| 40825B82
TEGETOFFSET_238:        /* recalculate, move the selection past it */
    jbsr TEDELETE_118	| 40825B86
    addw %d5,%a3@(32)	| 40825B8A
    addw %d5,%a3@(34)	| 40825B8E
TEGETOFFSET_244:        /* show the caret; return */
    jbsr XRECALLINES_2D8	| 40825B92
    jbsr TEUPDATE_1C	| 40825B96
    moveq #18,%d0	| 40825B9A
    jbra TECALTEXT_E	| 40825B9C
/* TEGETHEIGHT (TEGETOFFSET_252): TEDispatch: TEGetHeight: the total height of lines startLine..endLine. */
TEGETOFFSET_252:        /* TEGetHeight */
    moveml %a2@+,%d0-%d1	| 40825BA0
    cmpl %d0,%d1	| 40825BA4
    jbcc TEGETOFFSET_25C	| 40825BA6
    exg %d0,%d1	| 40825BA8
TEGETOFFSET_25C:        /* lines from 1 */
    tstl %d0	| 40825BAA
    jbne TEGETOFFSET_262	| 40825BAC
    moveq #1,%d0	| 40825BAE
TEGETOFFSET_262:        /* end line at least 1 */
    subql #1,%d0	| 40825BB0
    tstl %d1	| 40825BB2
    jbne TEGETOFFSET_26A	| 40825BB4
    moveq #1,%d1	| 40825BB6
TEGETOFFSET_26A:        /* the line count */
    moveq #0,%d2	| 40825BB8
    movew %a3@(94),%d2	| 40825BBA
    jbne TEGETOFFSET_274	| 40825BBE
    moveq #1,%d2	| 40825BC0
TEGETOFFSET_274:        /* pin the start */
    cmpl %d2,%d0	| 40825BC2
    jbls TEGETOFFSET_27A	| 40825BC4
    movel %d2,%d0	| 40825BC6
TEGETOFFSET_27A:        /* pin the end */
    cmpl %d2,%d1	| 40825BC8
    jbls TEGETOFFSET_280	| 40825BCA
    movel %d2,%d1	| 40825BCC
TEGETOFFSET_280:        /* the height of the lines; return */
    jbsr LINERECT_64	| 40825BCE
    movel %d0,%a2@	| 40825BD2
    moveq #14,%d0	| 40825BD4
    jbra TECALTEXT_E	| 40825BD6
/* TECUSTOMHOOK (TEGETOFFSET_28C): TEDispatch: TECustomHook: swap a hook in the dispatch record. */
TEGETOFFSET_28C:        /* TECustomHook */
    moveal %a2@+,%a1	| 40825BDA
    movew %a2@,%d0	| 40825BDC
    lslw #2,%d0	| 40825BDE
    moveal %a3@(66),%a0	| 40825BE0
    moveal %a0@,%a0	| 40825BE4
    addaw %d0,%a0	| 40825BE6
    movel %a0@,%d0	| 40825BE8
    movel %a1@,%a0@	| 40825BEA
    movel %d0,%a1@	| 40825BEC
    moveq #12,%d0	| 40825BEE
    jbra TECALTEXT_E	| 40825BF0
/* TENUMSTYLES (TEGETOFFSET_2A6): TEDispatch: TENumStyles: the number of style changes in a range. */
TEGETOFFSET_2A6:        /* TENumStyles */
    movel %a2@+,%d1	| 40825BF4
    movel %a2@+,%d0	| 40825BF6
    cmpl %d0,%d1	| 40825BF8
    jbhi TEGETOFFSET_2B2	| 40825BFA
    jbeq TEGETOFFSET_2B8	| 40825BFC
    exg %d0,%d1	| 40825BFE
TEGETOFFSET_2B2:        /* unstyled */
    tstw %a3@(80)	| 40825C00
    jbmi TEGETOFFSET_2BC	| 40825C04
TEGETOFFSET_2B8:        /* one style */
    moveq #1,%d0	| 40825C06
    jbra TEGETOFFSET_2D0	| 40825C08
TEGETOFFSET_2BC:        /* pin the end */
    moveq #0,%d2	| 40825C0A
    movew %a3@(34),%d2	| 40825C0C
    cmpl %d2,%d1	| 40825C10
    jbls TEGETOFFSET_2C8	| 40825C12
    movel %d2,%d1	| 40825C14
TEGETOFFSET_2C8:        /* count the runs */
    jbsr ITEFEATUREFLAG_9E	| 40825C16
    jbsr ITEFEATUREFLAG_EC	| 40825C1A
TEGETOFFSET_2D0:        /* return the count */
    movel %d0,%a2@	| 40825C1E
    moveq #14,%d0	| 40825C20
    jbra TECALTEXT_E	| 40825C22
/* TECONTINUOUSSTYLE (TEGETOFFSET_2D8): TEDispatch: TEContinuousStyle: which attributes are the
 same over the whole selection. */
TEGETOFFSET_2D8:        /* TEContinuousStyle */
    tstw %a3@(80)	| 40825C26
    jbmi TEGETOFFSET_2F6	| 40825C2A
    moveal %a2@,%a0	| 40825C2C
    moveal %a3@(82),%a1	| 40825C2E
    movel %a1@(68),%a0@+	| 40825C32
    movew %a1@(74),%a0@+	| 40825C36
    pea %a0@	| 40825C3A
    _GetForeColor	| 40825C3C
    st %a2@(8)	| 40825C3E
    jbra TEGETOFFSET_2F8	| 40825C42
TEGETOFFSET_2F6:        /* styled */
    jbsr TEGETOFFSET_2FE	| 40825C44
TEGETOFFSET_2F8:        /* return */
    moveq #14,%d0	| 40825C46
    jbra TECALTEXT_E	| 40825C48

TEGETOFFSET_2FE:        /* TEContinuousStyle body: the style at the start of the selection */
    moveml %d3-%d7/%a4,%sp@-
    movew %a3@(32),%d0
    cmpw %a3@(34),%d0
    seq %d5
    jbne TEGETOFFSET_31A
    jbsr ITESETSTYLE_222
    jbne TEGETOFFSET_31A
    tstw %d0
    jbeq TEGETOFFSET_31A
    subqw #1,%d0
TEGETOFFSET_31A:        /* the first run's style; then compare the others */
    jbsr ITESETSTYLE_238
    moveal %a2@,%a1
    movel %a0@(6),%a1@
    movel %a0@(10),%a1@(4)
    movel %a0@(14),%a1@(8)
    moveb %a0@(8),%d7
    moveb %d7,%d6
    moveal %a2@(4),%a0
    movew %a0@,%d0
    andiw #15,%d0
    movew %d0,%d4
    movew %d0,%d3
    tstb %d5
    jbne TEGETOFFSET_3DE
    movew %a3@(32),%d0
    jbsr ITEFEATUREFLAG_9E
    moveal %a0,%a4
TEGETOFFSET_354:        /* per later run in the selection */
    addqw #4,%a4
    tstw %d4
    jbeq TEGETOFFSET_3C6
    movew %a4@,%d0
    jbmi TEGETOFFSET_3C6
    cmpw %a3@(34),%d0
    jbcc TEGETOFFSET_3C6
    movew %a4@(2),%d0
    jbsr ITEFEATUREFLAG_112
    btst #0,%d4
    jbeq TEGETOFFSET_37E
    movew %a1@,%d0
    cmpw %a0@(6),%d0
    jbeq TEGETOFFSET_37E
    bclr #0,%d4
TEGETOFFSET_37E:        /* size differs: clear the size bit */
    btst #2,%d4
    jbeq TEGETOFFSET_392
    movew %a1@(4),%d0
    cmpw %a0@(10),%d0
    jbeq TEGETOFFSET_392
    bclr #2,%d4
TEGETOFFSET_392:        /* color */
    btst #3,%d4
    jbeq TEGETOFFSET_3B0
    movel %a1@(6),%d0
    cmpl %a0@(12),%d0
    jbne TEGETOFFSET_3AC
    movew %a1@(10),%d0
    cmpw %a0@(16),%d0
    jbeq TEGETOFFSET_3B0
TEGETOFFSET_3AC:        /* clear the color bit */
    bclr #3,%d4
TEGETOFFSET_3B0:        /* faces: collect the common ones */
    btst #1,%d4
    jbeq TEGETOFFSET_354
    tstb %d7
    jbne TEGETOFFSET_3C0
    orb %a0@(8),%d6
    jbra TEGETOFFSET_354
TEGETOFFSET_3C0:        /* and */
    andb %a0@(8),%d6
    jbra TEGETOFFSET_354
TEGETOFFSET_3C6:        /* no common face: clear the face bit */
    btst #1,%d4
    jbeq TEGETOFFSET_3E2
    tstb %d7
    jbne TEGETOFFSET_3DA
    tstb %d6
    jbeq TEGETOFFSET_3DE
TEGETOFFSET_3D4:        /* clear it */
    bclr #1,%d4
    jbra TEGETOFFSET_3E2
TEGETOFFSET_3DA:        /* plain everywhere */
    tstb %d6
    jbeq TEGETOFFSET_3D4
TEGETOFFSET_3DE:        /* the common faces */
    moveb %d6,%a1@(2)
TEGETOFFSET_3E2:        /* the mode back; true if all asked attributes are continuous */
    moveal %a2@(4),%a0
    movew %d4,%a0@
    cmpw %d4,%d3
    seq %d0
    negb %d0
    moveb %d0,%a2@(8)
    moveml %sp@+,%d3-%d7/%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40825D46
