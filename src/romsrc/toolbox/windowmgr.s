/*
 toolbox/windowmgr.s - Window Manager
 From WMGR (0x408181E0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* WMGR: Window Manager. */
WMGR:
    addqw #2,%a0
    tstw %a0@(4)
    jbpl WMGR_C
    moveal %a0@,%a0
    moveal %a0@,%a0
WMGR_C:                 /* return */
    rts

WMGR_E:                 /* save registers */
    moveml %d1/%d3,%sp@-
    movew %d0,%d3
    subqw #4,%sp
    clrb %sp@-
    movel %a0,%sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    movew %a0@(6),%d1
    muluw #8,%d1
WMGR_34:                /* loop: cmp */
    cmpw %a0@(0x8,%d1:w),%d3
    jbeq WMGR_40
    subqw #8,%d1
    jbge WMGR_34
    moveq #0,%d1
WMGR_40:                /* address %a0@(0xa */
    lea %a0@(0xa,%d1:w),%a0
    movel %a0,%d0
    moveml %sp@+,%d1/%d3
    moveal %sp@+,%a0
    movel %d0,%sp@-
    jmp %a0@

/* NEWSTRING: _NewString. */
trap_NewString:
NEWSTRING:
    jbsr NEWSTRING_C
    _PtrToHand
    movel %a0,%sp@(8)
    movel %sp@+,%sp@
    rts

NEWSTRING_C:            /* loop: movea */
    moveal %sp@(8),%a0
    moveq #0,%d0
    moveb %a0@,%d0
    addqw #1,%d0
    rts

/* SETSTRING: _SetString. */
trap_SetString:
SETSTRING:
    moveal %sp@(8),%a1
    jbsr NEWSTRING_C
    _PtrToXHand
    jbra SETSTRING_56

SETSTRING_A:            /* loop: move */
    movel %d0,%sp@-
    moveal WindowList,%a1
    subal %a0,%a0
SETSTRING_12:           /* loop: cmpa */
    cmpal %sp@,%a1
    jbeq SETSTRING_20
    moveal %a1,%a0
    moveal %a0@(144),%a1
    movel %a1,%d0
    jbne SETSTRING_12
SETSTRING_20:           /* set %d0 */
    movel %sp@+,%d0
    rts

SETSTRING_24:           /* set %d1 */
    movel %sp@(8),%d1
    moveal %d1,%a1
    clrl %a1@(144)
    tstl WindowList
    jbne SETSTRING_3A
    movel %d1,WindowList
    jbra SETSTRING_56
SETSTRING_3A:           /* set %d0 */
    movel %sp@(4),%d0
    jbeq SETSTRING_4E
    moveal %d0,%a0
    movel %a0@(144),%a1@(144)
    movel %a1,%a0@(144)
    jbra SETSTRING_56
SETSTRING_4E:           /* clear %d0 */
    moveq #0,%d0
    jbsr SETSTRING_A
    movel %d1,%a0@(144)

SETSTRING_56:           /* loop: movea */
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* DELETEWINDOW: unlink a window from the window list. */
DELETEWINDOW:
    movel %sp@(4),%d0
    jbsr SETSTRING_A
    movel %a0,%d1
    jbne DELETEWINDOW_E
    lea ChooserBits,%a0
DELETEWINDOW_E:         /* set %a1 */
    moveal %d0,%a1
    movel %a1@(144),%a0@(144)
    jbra CALCVIS_1E

/* CALCVIS: _CalcVis: visible region of a window. */
trap_CalcVis:
CALCVIS:
    moveml %d4/%a2-%a3,%sp@-
    movel %sp@(16),%d0
    jbeq CALCVIS_1A
    moveal %d0,%a2
    movel %a2@(24),%d4
    tstb %a2@(110)
    jbne CALCVIS_22
    movel %d4,%sp@-
    _SetEmptyRgn
CALCVIS_1A:             /* restore registers */
    moveml %sp@+,%d4/%a2-%a3
CALCVIS_1E:             /* set %sp@ */
    movel %sp@+,%sp@
CALCVIS_20:             /* return */
    rts
CALCVIS_22:             /* set up and call _SectRgn */
    movel GrayRgn,%sp@-
    movel %a2@(118),%sp@-
    movel %d4,%sp@-
    _SectRgn
    jbsr CALCVIS_40
    movel %d4,%sp@-
    moveal %a2,%a0
    jbsr WMGR
    movel %a0@(6),%sp@-	| 408182F4
    _OffsetRgn
    jbra CALCVIS_1A

CALCVIS_40:             /* loop: movea */
    moveal WindowList,%a3
CALCVIS_44:             /* loop: cmpa */
    cmpal %a2,%a3
    jbeq CALCVIS_20
    tstb %a3@(110)
    jbeq CALCVIS_58
    movel %d4,%sp@-
    movel %a3@(114),%sp@-
    movel %d4,%sp@-
    _DiffRgn
CALCVIS_58:             /* set %a3 */
    moveal %a3@(144),%a3
    jbra CALCVIS_44

/* CALCVISBEHIND: _CalcVisBehind. */
trap_CalcVBehind:
CALCVISBEHIND:
    movel %a2,%sp@-
    movel %sp@(12),%d0
    jbeq CALCVISBEHIND_3E
    moveal %d0,%a2
CALCVISBEHIND_A:        /* loop: move */
    movel %a2,%sp@-
    jbsr trap_CalcVis
CALCVISBEHIND_E:        /* loop: movea */
    moveal %a2@(144),%a2
    movel %a2,%d0
    jbeq CALCVISBEHIND_3E
    tstb %a2@(110)
    jbeq CALCVISBEHIND_E
    subqw #2,%sp
    moveal %a2@(118),%a0
    moveal %a0@,%a0
    pea %a0@(2)
    moveal %sp@(14),%a0
    moveal %a0@,%a0
    pea %a0@(2)
    pea ToolScratch
    _SectRect
    tstb %sp@+
    jbeq CALCVISBEHIND_E
    jbra CALCVISBEHIND_A
CALCVISBEHIND_3E:       /* set %a2 */
    moveal %sp@+,%a2
    jbra SETSTRING_56

/* CLIPABOVE: _ClipAbove: clip to the desk minus the windows in front. */
trap_ClipAbove:
CLIPABOVE:
    moveml %d4/%a2-%a3,%sp@-
    moveal WMgrPort,%a0
    movel %a0@(28),%d4
    moveal %sp@(16),%a2
    movel %d4,%sp@-
    movel GrayRgn,%sp@-
    movel %d4,%sp@-
    _SectRgn
    jbsr CALCVIS_40
    moveml %sp@+,%d4/%a2-%a3
    movel %sp@+,%sp@
    rts

/* PAINTONE: _PaintOne: paint the frame and content background. */
trap_PaintOne:
PAINTONE:
    moveml %d3-%d4/%a2-%a3,%sp@-
    moveal %sp@(24),%a2
    jbsr thunk_FUN_408185b8
    movel %a2,%d0
    bnes PAINTONE_1A_8	| 40818390
    movel %sp@(20),%sp@-
    _SetClip
    bsrw PAINTONE_BC_6

PAINTONE_1A:            /* restore registers */
    moveml %sp@+,%d3-%d4/%a2-%a3
    jbra SETSTRING_56
PAINTONE_1A_8:
    tstb %a2@(110)	| 408183A4
    beqs PAINTONE_1A
    movel %sp@(20),%sp@-
    movel %a2@(114),%sp@-
    movel %d3,%sp@-
    _SectRgn
    bsrw PAINTONE_B0	| 408183B6
    movel %a2,%sp@-	| 408183BA
    jbsr CLIPABOVE	| 408183BC
    jbsr PAINTONE_B0
    moveal %a2,%a3
    jbsr GETWVARIANT_74
    jbsr GETNEWRGN
    moveal %sp@+,%a3	| 408183CA
    movel %a2@(118),%sp@-
    movel %d3,%sp@-
    movel %a3,%sp@-
    _SectRgn
    tstb PaintWhite	| 408183D6
    jbeq PAINTONE_88	| 408183DA
    btst #15,%a2@(6)
    jbeq PAINTONE_68
    movel ghost_WMgrCPort,%sp@-
    _SetPort
PAINTONE_68:            /* set up and call _GetBackColor */
    subqw #6,%sp
    pea %sp@
    _GetBackColor
    clrw %d0
    moveal %a2,%a0
    jbsr WMGR_E
    _RGBBackColor
    movel %a3,%sp@-
    _EraseRgn
    pea %sp@
    _RGBBackColor
    addqw #6,%sp
    movel WMgrPort,%sp@-
    _SetPort
PAINTONE_88:            /* test SaveUpdate */
    tstb SaveUpdate
    jbeq PAINTONE_9A
    movel %a2@(122),%sp@-
    movel %a3,%sp@-
    movel %a2@(122),%sp@-
    _UnionRgn
PAINTONE_9A:            /* set up and call _DisposRgn */
    movel %a3,%sp@-
    _DisposRgn
    jbra PAINTONE_1A

thunk_FUN_408185b8:     /* call SETWPORT (loop) */
    jbsr SETWPORT
    moveal WMgrPort,%a3
    movel %a3@(28),%d3
    rts

PAINTONE_B0:            /* set up and call _EmptyRgn */
    subqw #2,%sp
    movel %d3,%sp@-
    _EmptyRgn
    tstb %sp@+
    jbne PAINTONE_BC
    rts
PAINTONE_BC:            /* add 4 to %sp */
    addqw #4,%sp
    jbra PAINTONE_1A
PAINTONE_BC_6:
    clrl %sp@-
    _ClipAbove
    movel DeskHook,%d0
    beqs PAINTONE_BC_6_10
    moveal %d0,%a0
    moveq #0,%d0
    jmp %a0@
PAINTONE_BC_6_10:
    tstb SPMisc2
    bpls PAINTONE_BC_6_3A
    subqw #8,%sp
    movel TheZone,%sp@(4)
    pea %sp@
    _GetPort
    movel ghost_WMgrCPort,%sp@-
    _SetPort
    movel GrayRgn,%sp@-
    movel DeskCPat,%sp@-
    .short  0xAA12	| 40818474 _FillCRgn
    _SetPort
    movel %sp@+,TheZone
    bras PAINTONE_BC_6_44
PAINTONE_BC_6_3A:
    movel GrayRgn,%sp@-
    pea DeskPattern
    _FillRgn
PAINTONE_BC_6_44:
    rts

/* PAINTBEHIND: _PaintBehind. */
trap_PaintBehind:
PAINTBEHIND:
    moveml %d3-%d4/%a2-%a3,%sp@-
    jbsr thunk_FUN_408185b8
    movel %sp@(20),%sp@-
    movel %d3,%sp@-
    _CopyRgn
    bsrs GETNEWRGN
    movel %sp@+,%d4
    moveal %sp@(24),%a2
    movel %a2,%sp@-
    _ClipAbove
    movel %d3,%sp@-
    movel %d4,%sp@-
    _CopyRgn
    bsrs PAINTONE_BC_6
    movel %d4,%sp@-
    movel %d3,%sp@-
    movel %d4,%sp@-
    _DiffRgn
    pea %a3@(16)
    _ClipRect
    movel %d4,%sp@-
    _DisposRgn
PAINTBEHIND_34:
    movel %a2,%d0
    beqs PAINTBEHIND_4C
    tstb %a2@(110)
    beqs PAINTBEHIND_46
    movel %a2,%sp@-
    movel %sp@(24),%sp@-
    _PaintOne
PAINTBEHIND_46:
    moveal %a2@(144),%a2
    bras PAINTBEHIND_34
PAINTBEHIND_4C:
    st PaintWhite
    moveml %sp@+,%d3-%d4/%a2-%a3
    braw SETSTRING_56

/* GETNEWRGN: a new region. */
GETNEWRGN:
    subqw #4,%sp
    _NewRgn
    moveal %sp@(4),%a0
    movel %sp@+,%sp@
    jmp %a0@

/* SAVEOLD: _SaveOld: remember the structure regions. */
trap_SaveOld:
SAVEOLD:
    moveml %d3-%d4/%a2,%sp@-
    jbsr GETNEWRGN
    movel %sp@+,%d3
    bsrs GETNEWRGN
    movel %sp@+,%d4
    moveal %sp@(16),%a2
    movel %a2@(114),%sp@-
    movel %d3,%sp@-
    _CopyRgn
    movel %a2@(118),%sp@-
    movel %d4,%sp@-
    _CopyRgn
    moveml %d3-%d4,OldStructure
    moveml %sp@+,%d3-%d4/%a2
    movel %sp@+,%sp@
    rts

/* DRAWNEW: _DrawNew: redraw the changed parts. */
trap_DrawNew:
DRAWNEW:
    moveml %d3-%d4/%a2,%sp@-
    moveal %sp@(18),%a2
    moveml OldStructure,%d3-%d4
    tstb %a2@(110)
    jbeq DRAWNEW_28
    movel %a2@(114),%sp@-
    movel %d3,%sp@-
    movel %d3,%sp@-
    _XOrRgn
    movel %a2@(118),%sp@-
    movel %d4,%sp@-
    movel %d4,%sp@-
    _XOrRgn
DRAWNEW_28:             /* set up and call _UnionRgn */
    movel %d4,%sp@-
    movel %d3,%sp@-
    movel %d3,%sp@-
    _UnionRgn
    moveb %sp@(16),SaveUpdate
    movel %a2,%sp@-
    movel %d3,%sp@-
    _PaintOne
    st SaveUpdate
    movel %a2@(144),%sp@-
    movel %d3,%sp@-
    _PaintBehind
    movel %a2,%sp@-
    movel %d3,%sp@-
    _CalcVBehind
    movel %d3,%sp@-
    _DisposRgn
    movel %d4,%sp@-
    _DisposRgn
    moveml %sp@+,%d3-%d4/%a2
DRAWNEW_5A:             /* loop: movea */
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@

/* SHOWHIDE: _ShowHide. */
trap_ShowHide:
SHOWHIDE:
    moveml %d3-%d4/%a1/%a3,%sp@-
    moveal %sp@(22),%a3
    moveb %sp@(20),%d3
    moveb %a3@(110),%d0
    eorb %d3,%d0
    lsrw #1,%d0
    jbcc SHOWHIDE_36
    jbsr SETWPORT
    movel %a3,%sp@-
    _SaveOld
    moveb %d3,%a3@(110)
    jbsr GETWVARIANT_82
    movel %a3,%sp@-
    st %sp@-
    .short  0xA90F	| 408185A4 _DrawNew
    jbsr RESTOREPORT
    tstb %a3@(110)
    jbeq SHOWHIDE_36
    movel %a3,%sp@-
    _ActivatePalette
SHOWHIDE_36:            /* restore registers */
    moveml %sp@+,%d3-%d4/%a1/%a3
    jbra DRAWNEW_5A

/* SETWPORT: set the Window Manager port. */
SETWPORT:
    moveal %a5@,%a0
    movel %a0@,%d4
    movel WMgrPort,%a0@
    rts

/* RESTOREPORT: restore the port. */
RESTOREPORT:
    movel %d4,%sp@-
    _SetPort
    rts

/* GETWMGRPORT: _GetWMgrPort. */
trap_GetWMgrPort:
GETWMGRPORT:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    movel WMgrPort,%a0@
    jmp %a1@

/* GETCWMGRPORT: _GetCWMgrPort. */
trap_GetCWMgrPort:
GETCWMGRPORT:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    movel ghost_WMgrCPort,%a0@
    jmp %a1@

/* CHECKUPDATE: _CheckUpdate: an update event for a window?. */
trap_CheckUpDate:
CHECKUPDATE:
    linkw %fp,#-8
    movel %a3,%sp@-
    clrw %fp@(12)
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    movel WindowList,%d0
    jbeq CHECKUPDATE_6E
CHECKUPDATE_16:         /* loop: movea */
    moveal %d0,%a3
    tstb %a3@(110)
    jbeq CHECKUPDATE_68
    subqw #2,%sp
    movel %a3@(122),%sp@-
    _EmptyRgn
    tstb %sp@+
    jbne CHECKUPDATE_68
    tstl %a3@(148)
    jbeq CHECKUPDATE_78
    movel %a3,%sp@-
    _SetPort
    subqw #4,%sp
    _NewRgn
    movel %sp@,%fp@(-4)
    _GetClip
    movel %a3@(28),%sp@-
    pea %a3@(16)
    _RectRgn
    movel %a3,%sp@-
    _BeginUpDate
    moveal %a3@(148),%a0
    movel %a0,%sp@-
    moveal %a0@,%a0
    pea %a0@(2)
    _DrawPicture
    movel %a3,%sp@-
    _EndUpDate
    movel %fp@(-4),%sp@-
    movel %sp@,%sp@-
    _SetClip
    _DisposRgn
CHECKUPDATE_68:         /* set %d0 */
    movel %a3@(144),%d0
    jbne CHECKUPDATE_16
CHECKUPDATE_6E:         /* _SetPort (loop) */
    _SetPort
    moveal %sp@+,%a3
    unlk %fp
    movel %sp@+,%sp@
    rts
CHECKUPDATE_78:         /* set %a0 */
    moveal %fp@(8),%a0
    movew #6,%a0@+
    movel %a3,%a0@
    addqb #1,%fp@(12)
    jbra CHECKUPDATE_6E
CHECKUPDATE_88:         /* loop: moveq */
    moveq #108,%d0
    moveq #0,%d1
CHECKUPDATE_8C:         /* (_NewPtr (flags 0x0100)) */
    .short  0xA11E	| 40818668 _NewPtr (flags 0x0100)
CHECKUPDATE_8C_2:
    moveal %a0,%a3
    movel %a0,%sp@-
    tstw %d1
    jbne CHECKUPDATE_9A
    _OpenPort
    rts
CHECKUPDATE_9A:         /* _OpenCPort */
    _OpenCPort
    rts

/* INITWINDOWS: _InitWindows: the Window Manager ports, desktop, gray region, menu bar. */
trap_InitWindows:
INITWINDOWS:
    moveal IntlSpec,%a0
    tstb %a0@(4)
    jbne INITWINDOWS_E
    jbsr FIXSMGRWORLD
INITWINDOWS_E:          /* entry: stack frame */
    linkw %fp,#0
    moveml %d3-%d7/%a3-%a4,%sp@-
    moveq #7,%d0
    bset %d0,DSWndUpdate
    bset %d0,AlarmState
    movel MinusOne,SaveUpdate
    subqw #4,%sp
    movew #16,%sp@-
    _GetPattern
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movel %a0@+,DeskPattern
    movel %a0@,DeskPattern_1
    tstb SPMisc2
    jbpl INITWINDOWS_72
    movel TheZone,%sp@-
    movel SysZone,TheZone
    movel DeskCPat,%d0
    jbeq INITWINDOWS_5A
    cmpl MinusOne,%d0
    jbeq INITWINDOWS_5A
    movel %d0,%sp@-
    _DisposPixPat
INITWINDOWS_5A:         /* set up and call _GetPixPat */
    subqw #4,%sp
    movew #16,%sp@-
    _GetPixPat
    movel %sp@+,DeskCPat
    jbne INITWINDOWS_6E
    bclr #7,SPMisc2
INITWINDOWS_6E:         /* set TheZone */
    movel %sp@+,TheZone
INITWINDOWS_72:         /* call CHECKUPDATE_88 */
    jbsr CHECKUPDATE_88
    movel %a3,WMgrPort
    moveal %a3,%a4
    movel %a4@(24),%d6
    movel %a4@(28),%d7
    moveq #108,%d0
    moveq #-1,%d1
    jbsr CHECKUPDATE_8C
    movel %a3,ghost_WMgrCPort
    movel %a3@(24),%a4@(24)
    movel %a3@(28),%a4@(28)
    moveal %a4,%a3
    movel %a3,%sp@-
    _SetPort
    movel %d7,%sp@-
    _SetEmptyRgn
    moveal DeviceList,%a4
INITWINDOWS_AA:         /* loop: movea */
    moveal %a4@,%a0
    tstw %a0@(20)
    jbpl INITWINDOWS_C6
    movel %d6,%sp@-
    movel %a0@(34),%sp@-
    movel %a0@(38),%sp@-
    _SetRecRgn
    movel %d6,%sp@-
    movel %d7,%sp@-
    movel %d7,%sp@-
    _UnionRgn
INITWINDOWS_C6:         /* set %a0 */
    moveal %a4@,%a0
    movel %a0@(30),%d0
    moveal %d0,%a4
    jbne INITWINDOWS_AA
    movel %d7,%sp@-
    movel %a3@(24),%sp@-
    _CopyRgn
    _InitMenus
    jsr %pc@(CALCMBHEIGHT)
    jsr %pc@(DRAWMBAR)
    moveal %d7,%a0
    moveal %a0@,%a0
    lea %a0@(2),%a0
    lea Scratch8,%a4
    moveal %a4,%a1
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    jbsr GETNEWRGN
    movel %sp@+,%d5
    movel %d5,GrayRgn
    _HidePen
    _OpenRgn
    bral INITWINDOWSRGNPATCH
    .short  0x0000, 0x0000	| 40818782
INITWINDOWSRGNRETURN:   /* (data) */
    movel %d5,%sp@-
    _CloseRgn
    _ShowPen
    movel %d5,%sp@-
    movel %a3@(28),%sp@-
    movel %d5,%sp@-
    _DiffRgn
    movel %d7,%sp@-
    movel %d5,%sp@-
    movel %d5,%sp@-
    _SectRgn
    moveal %a5@,%a0
    movel %a0@(-130),%sp@-
    _SetClip
    bral INITWINDOWSFRAMEPATCH
    .byte   0x00, 0x00, 0x00, 0x00	| 408187AC
INITWINDOWSCRTRETURN:   /* (data) */
    movel #196611,%sp@-	| 408187B0
    _PenSize
    movel %a4,%sp@-
    movel #1441814,%sp@-
    _FrameRoundRect
    _PenNormal
INITWINDOWSLCDRETURN:   /* (data) */
    movel %d5,%sp@-
    tstb SPMisc2
    bpls INITWINDOWSLCDRETURN_1C
    movel ghost_WMgrCPort,%sp@-
    _SetPort
    movel DeskCPat,%sp@-
    .short  0xAA12	| 408187D6 _FillCRgn
    movel WMgrPort,%sp@-
    _SetPort
    bras INITWINDOWSLCDRETURN_22
INITWINDOWSLCDRETURN_1C:
    pea DeskPattern
    _FillRgn
INITWINDOWSLCDRETURN_22:
    movel %d5,%sp@-
    _SetClip
    _ShowCursor
    clrl WindowList
    moveq #28,%d0
    .short  0xA322	| 408187F2 _NewHandle (flags 0x0300)
    moveal %a0,%a4
    _HLock
    movel %a4,ghost_AuxWinHead
    moveal %a4@,%a3
    subqw #4,%sp
    movel #2003006562,%sp@-
    clrw %sp@-
    _RGetResource
    movel %sp@+,%a3@(8)
    moveal %a4,%a0
    _HUnlock
    moveq #22,%d0
    .short  0xA322	| 40818814 _NewHandle (flags 0x0300)
    moveal %a0,%a4
    _HLock
    movel %a4,ghost_AuxCtlHead
    moveal %a4@,%a3
    subqw #4,%sp
    movel #1667462242,%sp@-
    clrw %sp@-
    _RGetResource
    movel %sp@+,%a3@(8)
    moveal %a4,%a0
    _HUnlock
    bsrw GETNEWRGN
    movel %sp@+,SaveVisRgn
    clrl GhostWindow
    lea CurActivate,%a0
    clrl %a0@+
    clrl %a0@+
    clrb WWExist
    movel %d6,%sp@-
    _DisposRgn
    movel %d7,%sp@-
    _DisposRgn
    .short  0xAA90	| .short 0xaa90
    moveml %sp@+,%d3-%d7/%a3-%a4
    unlk %fp
    rts

/* NEWCWINDOW: _NewCWindow. */
trap_NewCWindow:
NEWCWINDOW:
    linkw %fp,#0
    moveq #-1,%d1
    jbra NEWWINDOW_6
NEWCWINDOW_8:
    _StripAddress
    moveal %d0,%a0
    bsrw CHECKUPDATE_8C_2
    bras NEWWINDOW_6_18

/* NEWWINDOW: _NewWindow. */
trap_NewWindow:
NEWWINDOW:
    linkw %fp,#0
    moveq #0,%d1
NEWWINDOW_6:            /* save registers */
    moveml %d3-%d5/%a2-%a4,%sp@-
    jbsr SETWPORT
    movel %fp@(30),%d0
    bnes NEWCWINDOW_8
    moveq #0,%d0
    movew #156,%d0
    bsrw CHECKUPDATE_8C
NEWWINDOW_6_18:
    movel %a3,%fp@(34)
    movew #1,%a3@(68)
    tstb MMU32Bit
    beqs NEWWINDOW_6_36
    sf %a3@(110)
    movel %a3,%sp@-
    movel #-1,%sp@-
    _SetWinColor
NEWWINDOW_6_36:
    moveal %fp@(26),%a2
    movel %a2@,%sp@-
    _MovePortTo
    subqw #4,%sp
    movel %a2@(4),%sp@-
    movel %a2@,%sp@-
    bsrw DELTAPOINT
    .short  0xA876	| 408188C0 _PortSize
    movel WMgrPort,%sp@-
    _SetPort
    lea %a3@(108),%a2
    movew #8,%a2@+
    tstb %fp@(20)
    sne %a2@+
    clrb %a2@+
    tstb %fp@(12)
    sne %a2@+
    clrb %a2@+
    moveq #2,%d3
NEWWINDOW_6_6C:
    bsrw GETNEWRGN
    movel %sp@+,%a2@+
    dbf %d3,NEWWINDOW_6_6C
    movew %fp@(18),%d3
    lsrw #4,%d3
NEWWINDOW_6_7C:
    subqw #4,%sp
    movel #1464091974,%sp@-
    movew %d3,%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    moveq #0,%d3
    movel %sp@+,%a2@
    beqs NEWWINDOW_6_7C
    moveq #15,%d3
    andw %fp@(18),%d3
    tstb MMU32Bit
    beqs NEWWINDOW_6_B6
    subqw #6,%sp
    movel %a3,%sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    moveb %d3,%a0@(16)
    bras NEWWINDOW_6_B8
NEWWINDOW_6_B6:
    moveb %d3,%a2@
NEWWINDOW_6_B8:
    addqw #4,%a2
    clrl %a2@+
    movel %fp@(22),%d3
    clrl %sp@-
    movel %d3,%sp@-
    _NewString
    movel %sp@+,%a2@+
    clrw %sp@-
    movel %d3,%sp@-
    _StringWidth
    movew %sp@+,%a2@+
    clrl %a2@+
    clrl %a2@+
    clrl %a2@+
    movel %fp@(8),%a2@+
    moveq #3,%d0
    bsrw GETWVARIANT_36
    bsrw GETWVARIANT_82
    movel %fp@(14),%d5
    btst #0,%d5
    bnes NEWWINDOW_6_11E
    tstl WindowList
    beqs NEWWINDOW_6_11E
    movel %a3,%sp@-
    movel %d5,%sp@-
    bsrw SETSTRING_24
NEWWINDOW_6_FC:
    movel %a3,%sp@-
    movel %a3@(114),%sp@-
    _PaintOne
    movel %a3,%sp@-
    movel %a3@(114),%sp@-
    _CalcVBehind
    bsrw RESTOREPORT
    moveml %sp@+,%d3-%d5/%a2-%a4
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(26),%sp
    jmp %a0@
NEWWINDOW_6_11E:
    tstb %a3@(110)
    beqs NEWWINDOW_6_13A
    subqw #4,%sp
    _FrontWindow
    movel %sp@+,%d0
    beqs NEWWINDOW_6_130
    bsrw CLOSEWINDOW_EE
NEWWINDOW_6_130:
    moveb #1,%a3@(111)
    movel %a3,CurActivate
NEWWINDOW_6_13A:
    movel WindowList,%a3@(144)
    movel %a3,WindowList
    bras NEWWINDOW_6_FC
    lea CurActivate,%a0
    movel %a3,%d0
    bsrs NEWWINDOW_6_150
    addqw #4,%a0
NEWWINDOW_6_150:
    movel %a0@,%d1
    eorl %d0,%d1
    andl Lo3Bytes,%d1
    bnes NEWWINDOW_6_15E
    bset #7,%a0@
NEWWINDOW_6_15E:
    rts

/* CLOSEWINDOW: _CloseWindow. */
trap_CloseWindow:
CLOSEWINDOW:
    moveml %d3-%d4/%a2-%a3,%sp@-
    moveal %sp@(20),%a3
    jbsr SETWPORT
    bsrs NEWWINDOW_6_13A+0xc	| 408189E2
    subqw #4,%sp
    _FrontWindow
    movel %a3,%sp@-
    _KillControls
    moveq #4,%d0
    jbsr GETWVARIANT_36
    movel %a3,%sp@-
    clrw %sp@-
    _ShowHide
    tstw %a3@(6)
    jbpl CLOSEWINDOW_44
    moveal %a3@(8),%a0
    moveal %a0@,%a0
    movel %a0@(12),%d0
    jbeq CLOSEWINDOW_44
    moveal %d0,%a0
    moveal %a0@,%a0
    btst #12,%a0@(6)
    jbeq CLOSEWINDOW_44
    movel %d0,%sp@-
    _DisposePalette
CLOSEWINDOW_44:         /* set %sp@- */
    movel %a3,%sp@-
    subqw #6,%sp
    clrl %sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movel %a0@(8),%sp@-
    tstb MMU32Bit
    jbeq CLOSEWINDOW_94
    lea ghost_AuxWinHead,%a1
CLOSEWINDOW_64:         /* loop: movea */
    moveal %a1@,%a2
    moveal %a2@,%a0
    cmpal %a0@(4),%a3
    jbeq CLOSEWINDOW_72
    lea %a0@,%a1
    jbra CLOSEWINDOW_64
CLOSEWINDOW_72:         /* set %a1@ */
    movel %a0@,%a1@
    moveal %a2,%a1
    moveal %a1@,%a1
    movel %a1@(8),%d0
    cmpl %sp@+,%d0
    jbeq CLOSEWINDOW_8C
    moveal %d0,%a0
    _HGetState
    btst #5,%d0
    jbne CLOSEWINDOW_8C
    _DisposHandle
CLOSEWINDOW_8C:         /* set up and call _DisposHandle */
    moveal %a2,%a0
    _DisposHandle
    addqw #4,%sp
    jbra CLOSEWINDOW_96
CLOSEWINDOW_94:         /* _SetWinColor */
    _SetWinColor
CLOSEWINDOW_96:         /* set up and call _DisposHandle */
    movel %a3,%sp@-
    jbsr DELETEWINDOW
    moveal %a3@(134),%a0
    _DisposHandle
    movel %a3@(114),%sp@-
    _DisposRgn
    movel %a3@(118),%sp@-
    _DisposRgn
    movel %a3@(122),%sp@-
    _DisposRgn
    movel %a3,%sp@-
    tstw %a3@(6)
    jbpl CLOSEWINDOW_C0
    _ClosePort
    jbra CLOSEWINDOW_C2
CLOSEWINDOW_C0:         /* _ClosePort */
    _ClosePort
CLOSEWINDOW_C2:         /* set up and call _KillPicture */
    movel %a3@(148),%d0
    jbeq CLOSEWINDOW_CC
    movel %d0,%sp@-
    _KillPicture
CLOSEWINDOW_CC:         /* test %sp@+,%a3 */
    cmpal %sp@+,%a3
    jbne CLOSEWINDOW_DE
    movew %a3@(108),CurDeKind
    subqw #4,%sp
    _FrontWindow
    jbsr SELECTWINDOW_1C
CLOSEWINDOW_DE:         /* test %d4,%a3 */
    cmpal %d4,%a3
    jbeq CLOSEWINDOW_E6
    jbsr RESTOREPORT
CLOSEWINDOW_E6:         /* restore registers, return */
    moveml %sp@+,%d3-%d4/%a2-%a3
    movel %sp@+,%sp@
    rts
CLOSEWINDOW_EE:         /* set up and call _HiliteWindow (loop) */
    movel %d0,%sp@-
    movel %d0,%sp@-
    clrw %sp@-
    _HiliteWindow
    movel %sp@+,%d0
    tstl CurDeactive
    jbgt CLOSEWINDOW_10A
    moveal %d0,%a0
    movew %a0@(108),CurDeKind
    movel %d0,CurDeactive
CLOSEWINDOW_10A:        /* return */
    rts

/* DISPOSEWINDOW: _DisposeWindow. */
trap_DisposWindow:
DISPOSEWINDOW:
    movel %sp@(4),%sp@-
    _CloseWindow
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _DisposPtr
    jmp %a1@

/* SHOWWINDOW: _ShowWindow. */
trap_ShowWindow:
SHOWWINDOW:
    moveal WindowList,%a0
SHOWWINDOW_4:           /* loop: tst */
    tstb %a0@(110)
    jbne SHOWWINDOW_18
    cmpal %sp@(4),%a0
    jbeq SHOWWINDOW_22
    moveal %a0@(144),%a0
    movel %a0,%d0
    jbne SHOWWINDOW_4
SHOWWINDOW_18:          /* set up and call _ShowHide (loop) */
    moveal %sp@+,%a1
    moveb #1,%sp@-
    _ShowHide
    jmp %a1@
SHOWWINDOW_22:          /* set up and call _SelectWindow */
    movel %a0,%sp@-
    _SelectWindow
    jbra SHOWWINDOW_18

/* HIDEWINDOW: _HideWindow. */
trap_HideWindow:
HIDEWINDOW:
    subqw #4,%sp
    _FrontWindow
    movel %sp@(8),%sp@-
    clrw %sp@-
    _ShowHide
    movel %sp@+,%d0
    cmpl %sp@(4),%d0
    jbne HIDEWINDOW_22
    jbsr CLOSEWINDOW_EE
    subqw #4,%sp
    _FrontWindow
    movel %sp@,CurActivate
    jbeq HIDEWINDOW_26
    _SelectWindow
HIDEWINDOW_22:          /* loop: move */
    movel %sp@+,%sp@
    rts
HIDEWINDOW_26:          /* add 4 to %sp */
    addqw #4,%sp
    jbra HIDEWINDOW_22

/* GETWREFCON: _GetWRefCon. */
trap_GetWRefCon:
GETWREFCON:
    movew #152,%d1
GETWREFCON_4:           /* loop: movea */
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a1@(0x0,%d1:w),%sp@
    jmp %a0@

/* SETWREFCON: _SetWRefCon. */
trap_SetWRefCon:
SETWREFCON:
    movew #152,%d1
SETWREFCON_4:           /* loop: movea */
    moveal %sp@+,%a0
    movel %sp@+,%d0
    moveal %sp@+,%a1
    movel %d0,%a1@(0x0,%d1:w)
    jmp %a0@

/* SETWINDOWPIC: _SetWindowPic. */
trap_SetWindowPic:
SETWINDOWPIC:
    movew #148,%d1
    jbra SETWREFCON_4

/* GETWINDOWPIC: _GetWindowPic. */
trap_GetWindowPic:
GETWINDOWPIC:
    movew #148,%d1
    jbra GETWREFCON_4

/* GETWTITLE: _GetWTitle. */
trap_GetWTitle:
GETWTITLE:
    moveml %sp@+,%d1/%a0-%a1
    moveal %a1@(134),%a1
    moveal %a1@,%a1
    moveq #0,%d0
    moveb %a1@,%d0
GETWTITLE_E:            /* loop: move */
    moveb %a1@+,%a0@+
    dbf %d0,GETWTITLE_E
    moveal %d1,%a0
    jmp %a0@

/* SETWTITLE: _SetWTitle. */
trap_SetWTitle:
SETWTITLE:
    moveml %d3-%d5/%a2-%a3,%sp@-
    movel %sp@(24),%d5
    moveal %sp@(28),%a3
    jbsr SETWPORT
    moveal %a3@(114),%a0
    _HandToHand
    movel %a0,%d3
    movel %a3@(134),%d0
    jbeq SETWTITLE_62
    movel %d0,%sp@-
    movel %d5,%sp@-
    _SetString
    subqw #2,%sp
    movel %d5,%sp@-
    _StringWidth
    movew %sp@+,%a3@(138)
    jbsr GETWVARIANT_82
    clrw %sp@-
    movel %a3@(114),%sp@-
    movel %d3,%sp@-
    .short  0xA8E3	| 40818BBE _EqualRgn
    movew %sp@+,%d0
    jbeq SETWTITLE_4A
    jbsr SETWTITLE_72
    movel %a3,%sp@-
    movel %d3,%sp@-
    _PaintOne
    jbra SETWTITLE_62
SETWTITLE_4A:           /* set up and call _UnionRgn */
    movel %a3@(114),%sp@-
    movel %d3,%sp@-
    movel %d3,%sp@-
    _UnionRgn
    jbsr SETWTITLE_72
    movel %a3,%sp@-
    movel %d3,%sp@-
    _PaintBehind
    movel %a3,%sp@-
    movel %d3,%sp@-
    _CalcVBehind
SETWTITLE_62:           /* set up and call _DisposRgn */
    movel %d3,%sp@-
    _DisposRgn
    jbsr RESTOREPORT
    moveml %sp@+,%d3-%d5/%a2-%a3
SETWTITLE_6E:           /* continue at SETSTRING_56 */
    jbra SETSTRING_56

SETWTITLE_72:           /* set up and call _DiffRgn */
    movel %d3,%sp@-
    movel %a3@(118),%sp@-
    movel %d3,%sp@-
    _DiffRgn
    rts

/* DELTAPOINT: _DeltaPoint. */
trap_DeltaPoint:
DELTAPOINT:
    movew %sp@(8),%d0
    subw %sp@(4),%d0
    movew %d0,%sp@(12)
    movew %sp@(10),%d0
    subw %sp@(6),%d0
    movew %d0,%sp@(14)
    jbra SETWTITLE_6E

DELTAPOINT_1A:          /* loop: move */
    movel %a4,%sp@-
    subqw #4,%sp
    movel %d0,%sp@-
    subqw #4,%sp
    movel %a3@(16),%sp@-
    moveal %a3,%a0
    jbsr WMGR
    movel %a0@(6),%sp@-
    jbsr trap_DeltaPoint
    jbsr trap_DeltaPoint
    movel %sp@,%d3
    _OffsetRgn
    movel %a3@(118),%sp@-
    movel %d3,%sp@-
    _OffsetRgn
    movel %a3@(122),%sp@-
    movel %d3,%sp@-
    _OffsetRgn
    moveal %a3,%a0
    jbsr WMGR
    pea %a0@(6)
    movel %d3,%sp@-
    jbsr BRINGTOFRONT_98
    _OffsetRect
    rts

/* MOVEWINDOW: _MoveWindow. */
trap_MoveWindow:
MOVEWINDOW:
    moveml %d3-%d6/%a3-%a4,%sp@-
    jbsr SETWPORT
    moveal %sp@(34),%a3
    bsrw HILITEWINDOW_32_8
    bsrw GETNEWRGN
    movel %sp@+,%d5
    moveal %a3@(114),%a4
    movel %a4,%sp@-
    moveal WMgrPort,%a0
    movel %a0@(28),%sp@-
    movel %d5,%sp@-
    _SectRgn
    moveal %a4,%a0
    _HandToHand
    movel %a0,%d6
    movel %sp@(30),%d0
    jbsr DELTAPOINT_1A
    bsrw MOVEWINDOW_B4
    movel %d5,%sp@-
    movel %d3,%sp@-
    _OffsetRgn
    tstb %sp@(28)
    jbeq MOVEWINDOW_4A
    movel GrayRgn,%sp@-
    _SetClip
MOVEWINDOW_4A:          /* set %a0 */
    moveal WMgrPort,%a0
    pea %a0@(2)
    movel %sp@,%sp@-
    moveal %d6,%a0
    moveal %a0@,%a0
    pea %a0@(2)
    moveal %a4@,%a0
    pea %a0@(2)
    clrw %sp@-
    movel %d5,%sp@-
    _CopyBits
    movel %a4,%sp@-
    movel %d5,%sp@-
    movel %d5,%sp@-
    _DiffRgn
    movel %a3@(144),%sp@-
    movel %d6,%sp@-
    _PaintBehind
    tstb %sp@(28)
    jbeq MOVEWINDOW_88
    movel %a3,%sp@-
    st DragFlag
    jbsr SELECTWINDOW_4
MOVEWINDOW_88:          /* set up and call _PaintOne */
    movel %a3,%sp@-
    movel %d5,%sp@-
    _PaintOne
    movel %d6,%sp@-
    movel %a4,%sp@-
    movel %d6,%sp@-
    _UnionRgn
    movel %a3,%sp@-
    movel %d6,%sp@-
    _CalcVBehind
    movel %d5,%sp@-
    _DisposRgn
    movel %d6,%sp@-
    _DisposRgn
    movel %a3,%sp@-
    _ActivatePalette
    jbsr RESTOREPORT
    moveml %sp@+,%d3-%d6/%a3-%a4
    jbra SIZEWINDOW_3A

MOVEWINDOW_B4:          /* save registers */
    moveml %d5-%d7/%a2-%a4,%sp@-
    subqw #8,%sp
    moveal %sp,%a2
    subqw #8,%sp
    _NewRgn
    movel %sp@+,%d7
    _NewRgn
    movel %sp@+,%d6
    moveal DeviceList,%a4
MOVEWINDOW_CA:          /* loop: movea */
    moveal %a4@,%a0
    tstw %a0@(20)
    jbpl MOVEWINDOW_15E
    movel %d7,%sp@-
    pea %a0@(34)
    _RectRgn
    movel %d5,%sp@-
    movel %d7,%sp@-
    movel %d7,%sp@-
    _SectRgn
    clrb %sp@-
    movel %d7,%sp@-
    _EmptyRgn
    tstb %sp@+
    bnew MOVEWINDOW_15E
    moveal DeviceList,%a3
MOVEWINDOW_F4:          /* loop: movea */
    moveal %a3@,%a0
    tstw %a0@(20)
    jbpl MOVEWINDOW_154
    cmpal %a3,%a4
    jbeq MOVEWINDOW_154
    moveal %a4@,%a1
    moveal %a1@(22),%a1
    moveal %a1@,%a1
    moveal %a1@(42),%a1
    moveal %a1@,%a1
    movel %a1@,%d0
    moveal %a0@(22),%a1
    moveal %a1@,%a1
    moveal %a1@(42),%a1
    moveal %a1@,%a1
    cmpl %a1@,%d0
    jbeq MOVEWINDOW_154
    lea %a0@(34),%a0
    moveal %a2,%a1
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    movel %a2,%sp@-
    movel %d3,%sp@-
    jbsr BRINGTOFRONT_98
    _OffsetRect	| 40818D90
    movel %d6,%sp@-
    movel %a2,%sp@-
    _RectRgn
    movel %d6,%sp@-
    movel %d7,%sp@-
    movel %d6,%sp@-
    _SectRgn
    clrb %sp@-
    movel %d6,%sp@-
    _EmptyRgn
    tstb %sp@+
    bnes MOVEWINDOW_154
    movel %d5,%sp@-
    movel %d6,%sp@-
    movel %d5,%sp@-
    _DiffRgn
MOVEWINDOW_154:         /* set %a0 */
    moveal %a3@,%a0
    movel %a0@(30),%d0
    moveal %d0,%a3
    jbne MOVEWINDOW_F4
MOVEWINDOW_15E:         /* set %a0 */
    moveal %a4@,%a0
    movel %a0@(30),%d0
    moveal %d0,%a4
    jbne MOVEWINDOW_CA
    movel %d6,%sp@-
    _DisposRgn
    movel %d7,%sp@-
    _DisposRgn
    addqw #8,%sp
    moveml %sp@+,%d5-%d7/%a2-%a4
    rts

/* GETWVARIANT: _GetWVariant. */
trap_GetWVariant:
GETWVARIANT:
    moveal %sp@(4),%a1
    tstb MMU32Bit
    jbeq GETWVARIANT_22
    subqw #6,%sp
    movel %a1,%sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    clrw %d0
    moveb %a0@(16),%d0
    jbra GETWVARIANT_2C
GETWVARIANT_22:         /* clear %d0 */
    clrw %d0
    moveb %a1@(126),%d0
    andiw #15,%d0
GETWVARIANT_2C:         /* set %sp@(8) */
    movew %d0,%sp@(8)
    moveal %sp@+,%a0
    addqw #4,%sp
    jmp %a0@

GETWVARIANT_36:         /* loop: clr */
    clrl %sp@-
    subqw #2,%sp
    movel %a3,%sp@-
    movew %d0,%sp@-
    movel %d3,%sp@-
    subqw #2,%sp
    movel %a3,%sp@-
    _GetWVariant
    movew %sp@+,%sp@(10)
    moveal %a3@(126),%a0
    tstl %a0@
    jbne GETWVARIANT_64
    movel %a0,%d0
    _StripAddress
    movel %d0,%sp@-
    _LoadResource
    tstl %a0@
    jbne GETWVARIANT_64
    movew #87,%d0
    _SysError
GETWVARIANT_64:         /* _HLock */
    _HLock
    moveal %a0@,%a0
    jsr %a0@
    moveal %a3@(126),%a0
    _HUnlock
    movel %sp@+,%d0
    rts

GETWVARIANT_74:         /* save registers */
    moveml %d3,%sp@-
    moveq #0,%d3
    moveq #0,%d0
    jbsr GETWVARIANT_36
    movel %sp@+,%d3
    rts

GETWVARIANT_82:         /* loop: moveq */
    moveq #2,%d0
    tstb %a3@(110)
    jbeq GETWVARIANT_B2
    lea %a3@(8),%a1
    movel %a1@+,%sp@-
    movel %a1@+,%sp@-
    tstw %a3@(6)
    jbpl GETWVARIANT_A6
    moveal %a3@(2),%a0
    moveal %a0@,%a0
    movel %a0@(10),%a1@-
    movel %a0@(6),%a1@-
GETWVARIANT_A6:         /* call GETWVARIANT_36 */
    jbsr GETWVARIANT_36
    movel %sp@+,%a3@(12)
    movel %sp@+,%a3@(8)
    rts
GETWVARIANT_B2:         /* set up and call _SetEmptyRgn */
    movel %a3@(114),%sp@-
    _SetEmptyRgn
    movel %a3@(118),%sp@-
    _SetEmptyRgn
    movel %a3@(24),%sp@-
    _SetEmptyRgn
    rts

/* HILITEWINDOW: _HiliteWindow. */
trap_HiliteWindow:
HILITEWINDOW:
    moveml %d3-%d4/%a3-%a4,%sp@-
    moveal %sp@(22),%a3
    moveb %sp@(20),%d3
    jbsr SETWPORT
    moveb %a3@(111),%d0
    eorw %d3,%d0
    lsrw #1,%d0
    bccs HILITEWINDOW_22
    moveb %d3,%a3@(111)
    jbsr HILITEWINDOW_2E
    jbsr GETWVARIANT_74
HILITEWINDOW_22:
    jbsr RESTOREPORT
    moveml %sp@+,%d3-%d4/%a3-%a4
    jbra DRAWNEW_5A

HILITEWINDOW_2E:        /* set up and call _SetClip */
    movel %a3@(114),%sp@-
HILITEWINDOW_32:        /* _SetClip (loop) */
    _SetClip
    movel %a3,%sp@-
    _ClipAbove
    rts
HILITEWINDOW_32_8:
    movel GrayRgn,%sp@-	| 40818ED8
    jbra HILITEWINDOW_32	| 40818EDC

/* SIZEWINDOW: _SizeWindow. */
trap_SizeWindow:
SIZEWINDOW:
    moveml %d3-%d4/%a3-%a4,%sp@-
    movel %sp@(22),%d3
    jbeq SIZEWINDOW_36
    moveal %sp@(26),%a3
    movew %sp@(22),%d4
    lea %a3@(16),%a4
    addw %a4@+,%d4
    addw %a4@+,%d3
    movew %d4,%a4@+
    movew %d3,%a4@+
    tstb %a3@(110)
    jbeq SIZEWINDOW_36
    jbsr SETWPORT
    movel %a3,%sp@-	| 40818F06
    _SaveOld
    moveb %sp@(20),%d3
    bsrs SIZEWINDOW_42
    movel %a3,%sp@-
    _ActivatePalette
SIZEWINDOW_36:          /* restore registers */
    moveml %sp@+,%d3-%d4/%a3-%a4
SIZEWINDOW_3A:          /* loop: movea */
    moveal %sp@+,%a0
    lea %sp@(10),%sp
    jmp %a0@
SIZEWINDOW_42:          /* call GETWVARIANT_82 (loop) */
    jbsr GETWVARIANT_82
    bsrs HILITEWINDOW_2E
    bsrw GETWVARIANT_74
    movel %a3,%sp@-
    moveb %d3,%sp@-
    .short  0xA90F	| 40818F2E _DrawNew
    bsrw RESTOREPORT
    rts

/* ZOOMWINDOW: _ZoomWindow. */
trap_ZoomWindow:
ZOOMWINDOW:
    moveml %d3-%d6/%a2-%a4,%sp@-
    jbsr SETWPORT
    moveal %sp@(36),%a3	| 40818F3E
    bsrw GETWVARIANT_82
    movel %a3,%sp@-
    _SaveOld
    moveal %a3@(130),%a2
    moveal %a2@,%a2
    cmpiw #7,%sp@(34)
    jbeq ZOOMWINDOW_24
    addqw #8,%a2
ZOOMWINDOW_24:          /* set %a4 */
    moveal %a3@(114),%a4
    movel %a2@+,%d0
    jbsr DELTAPOINT_1A
    movew %a2@+,%d0
    movew %a2@+,%d1
    subqw #8,%a2
    subw %a2@+,%d0
    subw %a2@+,%d1
    lea %a3@(16),%a0
    addw %a0@+,%d0
    addw %a0@+,%d1
    movew %d0,%a0@+
    movew %d1,%a0@+
    moveq #1,%d3
    jbsr SIZEWINDOW_42
    tstb %sp@(32)
    jbeq ZOOMWINDOW_58
    movel %a3,%sp@-
    st DragFlag
    jbsr SELECTWINDOW_4
ZOOMWINDOW_58:          /* set up and call _InvalRect */
    pea %a3@(16)
    _InvalRect
    moveml %sp@+,%d3-%d6/%a2-%a4
    jbra SETSTRING_56

/* TRACKGOAWAY: _TrackGoAway. */
trap_TrackGoAway:
TRACKGOAWAY:
    moveal %sp@+,%a0
    movew #6,%sp@-
    movel %a0,%sp@-

/* TRACKBOX: _TrackBox. */
trap_TrackBox:
TRACKBOX:
    linkw %fp,#-4
    moveml %d3-%d6/%a3,%sp@-
    jbsr SETWPORT
    lea %fp@(8),%a0	| 40818FB0
    movew %a0@+,%d6
    subqw #2,%d6
    movel %a0@+,%fp@(-4)
    moveal %a0@+,%a3
    clrw %a0@
    moveq #0,%d5	| 40818FC0
    jbsr HILITEWINDOW_2E	| 40818FC2
TRACKBOX_22:            /* loop: moveq */
    moveq #1,%d0	| 40818FC6
    movel %fp@(-4),%d3	| 40818FC8
    jbsr GETWVARIANT_36	| 40818FCC
    cmpw %d6,%d0	| 40818FD0
    jbeq TRACKBOX_32	| 40818FD2
    moveq #0,%d0	| 40818FD4
TRACKBOX_32:            /* test %d0,%d5 */
    cmpw %d0,%d5	| 40818FD6
    jbeq TRACKBOX_3A	| 40818FD8
    movew %d0,%d5	| 40818FDA
    jbsr TRACKBOX_64	| 40818FDC
TRACKBOX_3A:            /* from here: pea %fp@(-4) */
    pea %fp@(-4)	| 40818FDE
    _GetMouse	| 40818FE2
    jbsr DRAGTHERGN_1AC	| 40818FE4
    clrw %sp@-	| 40818FE8
    _WaitMouseUp	| 40818FEA
    tstb %sp@+	| 40818FEC
    jbne TRACKBOX_22	| 40818FEE
    tstw %d5
    jbeq TRACKBOX_56
    addqb #1,%fp@(18)
    jbsr TRACKBOX_64
TRACKBOX_56:            /* call RESTOREPORT */
    jbsr RESTOREPORT
    moveml %sp@+,%d3-%d6/%a3
    unlk %fp
    jbra SIZEWINDOW_3A

TRACKBOX_64:            /* clear %d0 */
    moveq #0,%d0
    moveq #0,%d3
    movew %d6,%d3
    jbsr GETWVARIANT_36
    rts

/* SELECTWINDOW: _SelectWindow. */
trap_SelectWindow:
SELECTWINDOW:
    clrb DragFlag

SELECTWINDOW_4:         /* set up and call _FrontWindow */
    subqw #4,%sp
    _FrontWindow
    movel %sp@(8),%sp@-
    jbsr BRINGTOFRONT_4
    movel %sp@+,%d0
    jbeq SELECTWINDOW_1C
    cmpl %sp@(4),%d0
    jbeq SELECTWINDOW_26
    jbsr CLOSEWINDOW_EE

SELECTWINDOW_1C:        /* set %d0 */
    movel %sp@(4),%d0
    movel %d0,CurActivate
    jbeq SELECTWINDOW_30
SELECTWINDOW_26:        /* set up and call _HiliteWindow */
    movel %d0,%sp@-
    movel %sp@,%sp@-
    st %sp@-
    _HiliteWindow
    _ActivatePalette
SELECTWINDOW_30:        /* set %sp@ */
    movel %sp@+,%sp@
    rts

/* BRINGTOFRONT: _BringToFront. */
trap_BringToFront:
BRINGTOFRONT:
    clrb DragFlag
BRINGTOFRONT_4:         /* save registers */
    moveml %d3-%d6/%a2-%a4,%sp@-
    moveal %sp@(32),%a3
    jbsr SETWPORT
    /* already the front window: done. d3 collects what the windows in front covered */
    lea WindowList,%a2	| 40819058
    cmpal %a2@,%a3
    beqs BRINGTOFRONT_4+0x88
    bsrw GETNEWRGN
    movel %sp@+,%d3
    moveal %a2@,%a4
BRINGTOFRONT_4_1C:      /* each window in front of it: the visible ones add to d3 */
    cmpal %a3,%a4	| 40819068
    beqs BRINGTOFRONT_4_5E
    tstb %a4@(110)
    beqs BRINGTOFRONT_4_56
    moveal %a4,%a0
    bsrw WMGR
    movel %a0@(6),%d6
    movel %a4@(24),%d5
    movel %d5,%sp@-
    movel %d6,%sp@-
    bsrs BRINGTOFRONT_98
    _OffsetRgn
    movel %d5,%sp@-
    movel %a3@(114),%sp@-
    movel %d5,%sp@-
    _DiffRgn
    movel %d5,%sp@-
    movel %d6,%sp@-
    _OffsetRgn
    movel %a4@(114),%sp@-
    movel %d3,%sp@-
    movel %d3,%sp@-
    _UnionRgn
BRINGTOFRONT_4_56:
    moveal %a4@(144),%a4	| 408190A2
    movel %a4,%d0
    bnes BRINGTOFRONT_4_1C
BRINGTOFRONT_4_5E:      /* unlink it, put it first; unless DragFlag, _PaintOne what is uncovered and _CalcVis */
    movel %a3,%sp@-	| 408190AA
    bsrw DELETEWINDOW
    movel %a2@,%a3@(144)
    movel %a3,%a2@
    tstb DragFlag
    bnes BRINGTOFRONT_4+0x80
    movel %a3@(114),%sp@-
    movel %d3,%sp@-
    movel %d3,%sp@-
    _SectRgn
    movel %a3,%sp@-
    movel %d3,%sp@-
    _PaintOne
    movel %a3,%sp@-	| 408190CC
    .short  0xA909	| 408190CE _CalcVis
    movel %d3,%sp@-	| 408190D0
    _DisposRgn	| 408190D2
    jbsr RESTOREPORT	| 408190D4
    moveml %sp@+,%d3-%d6/%a2-%a4	| 408190D8
    movel %sp@+,%sp@	| 408190DC
    rts	| 408190DE

BRINGTOFRONT_98:        /* loop: neg */
    negw %sp@(4)
    negw %sp@(6)
    rts

/* SENDBEHIND: _SendBehind. */
trap_SendBehind:
SENDBEHIND:
    moveml %d3-%d4/%a3,%sp@-
    moveal %sp@(20),%a3
    jbsr SETWPORT
    /* the front window first hands over to the next visible one (_SelectWindow) */
    subqw #4,%sp	| 408190F6
    _FrontWindow
    cmpal %sp@+,%a3
    bnes SENDBEHIND_28
    moveal %a3,%a0
SENDBEHIND_16:
    moveal %a0@(144),%a0	| 40819100
    movel %a0,%d0
    beqs SENDBEHIND_28
    tstb %a0@(110)
    beqs SENDBEHIND_16
    movel %a0,%sp@-
    _SelectWindow
SENDBEHIND_28:          /* unlink; relink behind the given window; _CalcVBehind and _PaintBehind for the area uncovered */
    movel %a3,%sp@-	| 40819112
    bsrw DELETEWINDOW
    movel %a3@(114),%d3
    movel %a3@(144),%sp@-
    movel %sp@,%sp@-
    movel %a3,%sp@-
    movel %sp@(28),%sp@-
    bsrw SETSTRING_24
    movel %d3,%sp@-
    _CalcVBehind
    movel %d3,%sp@-	| 40819130
    _PaintBehind	| 40819132
    jbsr RESTOREPORT	| 40819134
    moveml %sp@+,%d3-%d4/%a3	| 40819138
    jbra SETSTRING_56	| 4081913C

/* BEGINUPDATE: _BeginUpdate. */
trap_BeginUpDate:
BEGINUPDATE:
    moveml %d3-%d4/%a3,%sp@-
    moveal %sp@(16),%a3
    moveal %a3,%a0
    jbsr WMGR
    movel %a0@(6),%d3
    movel %a3@(24),%d4
    movel %d4,%sp@-
    movel %d3,%sp@-
    jbsr BRINGTOFRONT_98
    _OffsetRgn
    movel %d4,%sp@-
    movel SaveVisRgn,%sp@-
    _CopyRgn
    movel %d4,%sp@-
    movel %a3@(122),%sp@-
    movel %d4,%sp@-
    _SectRgn
    movel %d4,%sp@-
    movel %d3,%sp@-
    _OffsetRgn
    movel %a3@(122),%sp@-
    _SetEmptyRgn
    moveml %sp@+,%d3-%d4/%a3
    movel %sp@+,%sp@
    rts

/* ENDUPDATE: _EndUpdate. */
trap_EndUpDate:
ENDUPDATE:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    movel SaveVisRgn,%sp@-
    movel %sp@,%sp@-
    movel %sp@,%sp@-
    moveal %a3,%a0
    jbsr WMGR
    movel %a0@(6),%sp@-
    _OffsetRgn
    movel %a3@(24),%sp@-
    _CopyRgn
    _SetEmptyRgn
    moveal %sp@+,%a3
    movel %sp@+,%sp@
    rts

/* FRONTWINDOW: _FrontWindow. */
trap_FrontWindow:
FRONTWINDOW:
    clrl %sp@(4)
    tstb WWExist
    jbne FRONTWINDOW_28
    moveal WindowList,%a0
FRONTWINDOW_E:          /* loop: move */
    movel %a0,%d0
    jbeq FRONTWINDOW_24
    cmpal GhostWindow,%a0
    jbeq FRONTWINDOW_1E
    tstb %a0@(110)
    jbne FRONTWINDOW_24
FRONTWINDOW_1E:         /* set %a0 */
    moveal %a0@(144),%a0
    jbra FRONTWINDOW_E
FRONTWINDOW_24:         /* set %sp@(4) */
    movel %a0,%sp@(4)
FRONTWINDOW_28:         /* return */
    rts

/* DRAGWINDOW: _DragWindow. */
trap_DragWindow:
DRAGWINDOW:
    linkw %fp,#-36
    moveml %d3-%d6/%a3-%a4,%sp@-
    subqw #2,%sp
    _WaitMouseUp
    tstb %sp@+
    jbeq DRAGWINDOW_A6
    moveal %fp@(8),%a0
    movew %a0@+,%d0
    movew MBarHeight,%d1
    addqw #4,%d1
    cmpw %d1,%d0
    jbcc DRAGWINDOW_24
    movew %d1,%d0
DRAGWINDOW_24:          /* address %fp@(-16) */
    lea %fp@(-16),%a1
    movew %d0,%a1@+
    movew %a0@+,%a1@+
    movel %a0@,%a1@
    movel %fp@(12),%d3
    moveal %fp@(16),%a3
    jbsr SETWPORT
    /* clip to the desktop (GrayRgn); d6 = Command key state (KeyMap, bit 7) */
    movel GrayRgn,%sp@-	| 40819210
    _SetClip
    pea %fp@(-36)
    _GetKeys
    moveb %fp@(-30),%d6
    bpls DRAGWINDOW_24_2C
    bsrw HILITEWINDOW_32_8
DRAGWINDOW_24_2C:       /* a copy of the structure region (a4) for _DragGrayRgn */
    bsrw GETNEWRGN	| 40819226
    moveal %sp@,%a4
    movel %a3@(114),%sp@-
    movel %a4,%sp@-
    _CopyRgn
    movel %a4,%sp@-
    movel %d3,%sp@-
    pea %fp@(-16)
    movel %sp@,%sp@-
    clrw %sp@-
    clrl %sp@-
    .short  0xA905	| _DragGrayRgn
    movel %sp@+,%d5	| 40819244
    jbeq DRAGWINDOW_B0	| 40819246
    cmpiw #-32768,%d5	| 40819248
    jbeq DRAGWINDOW_9E	| 4081924C
    movel %a3,%sp@-	| 4081924E
    movel %a3@(16),%d0	| 40819250
    moveal %a3,%a0	| 40819254
    jbsr WMGR	| 40819256
    subw %a0@(8),%d0	| 4081925A
    addw %d5,%d0	| 4081925E
    movew %d0,%sp@-	| 40819260
    swap %d0	| 40819262
    swap %d5	| 40819264
    subw %a0@(6),%d0	| 40819266
    addw %d5,%d0	| 4081926A
    movew %d0,%sp@-	| 4081926C
    tstb %d6	| 4081926E
    spl %sp@-	| 40819270
    _MoveWindow	| 40819272
DRAGWINDOW_9E:          /* loop: move */
    movel %a4,%sp@-	| 40819274
    _DisposRgn	| 40819276
    jbsr RESTOREPORT	| 40819278
DRAGWINDOW_A6:          /* restore registers, return */
    moveml %sp@+,%d3-%d6/%a3-%a4
    unlk %fp
    jbra GROWWINDOW_AC
DRAGWINDOW_B0:          /* test %d6 */
    tstb %d6	| 40819286
    jbmi DRAGWINDOW_9E	| 40819288
    movel %a3,%sp@-	| 4081928A
    _SelectWindow	| 4081928C
    jbra DRAGWINDOW_9E	| 4081928E

/* WMGRGRAY: the gray pattern. */
WMGRGRAY:
    .long   0xAA55AA55	| 40819290
WMGRGRAY_4:             /* (data) */
    .long   0xAA55AA55	| 40819294

/* DRAGGRAYRGN: _DragGrayRgn. */
trap_DragGrayRgn:
DRAGGRAYRGN:
    movel %pc@(WMGRGRAY),DragPattern
    movel %pc@(WMGRGRAY_4),DragPattern_1

/* DRAGTHERGN: _DragTheRgn. */
trap_DragTheRgn:
DRAGTHERGN:
    linkw %fp,#-44
    moveml %d3-%d7/%a3,%sp@-
    lea %fp@(22),%a0
    movel %a0@+,%d3
    moveal %a0@+,%a3
    clrl %a0@
    pea %fp@(-20)
    movel %sp@,%sp@-
    _GetPenState
    pea DragPattern
    _PenPat
    movew #14,%sp@-
    _PenMode
    jbsr DRAGTHERGN_1DA
    jbeq DRAGTHERGN_4E
    movel %a3,%sp@-
    jbsr GETNEWRGN
    movel %sp@,%d4	| 408192D6
    _CopyRgn
    movel %d4,%sp@-
    movel OneOne,%sp@-
    .short  0xA8E1	| _InsetRgn
    movel %a3,%sp@-
    movel %d4,%sp@-
    movel %a3,%sp@-
    _DiffRgn
    movel %d4,%sp@-
    _DisposRgn
    movel %a3,%sp@-
    .short  0xA8D3	| _PaintRgn
DRAGTHERGN_4E:          /* set %d5 */
    moveq #-1,%d5
    jbsr GETNEWRGN
    /* two regions: d6 = limit, d7 = slop. The screen below the menu bar, 30 more pixels down, inset by 6: if the limit given covers it (_SectRect, _EqualRect), GrayRgn inset by 4 is used for both */
    movel %sp@+,%d6	| 408192F8
    bsrw GETNEWRGN
    movel %sp@+,%d7
    moveal %a5@,%a0
    lea %a0@(-116),%a0
    movel %a0@(4),%sp@-
    movel %a0@,%sp@-
    movew MBarHeight,%d0
    addw %d0,%sp@
    addiw #30,%sp@
    movel %sp,%sp@-
    movel #393222,%sp@-
    _InsetRect
    movel %sp@(4),%sp@-
    movel %sp@(4),%sp@-
    clrb %sp@-
    pea %sp@(2)
    movel %fp@(18),%sp@-
    pea %sp@(10)
    _SectRect
    tstb %sp@+
    clrb %sp@-
    pea %sp@(10)
    pea %sp@(6)
    .short  0xA8A6	| _EqualRect
    tstb %sp@+
    lea %sp@(16),%sp
    beqs DRAGTHERGN_4E_76
    movel GrayRgn,%sp@-
    movel %d7,%sp@-
    _CopyRgn
    movel %d7,%sp@-
    movel #262148,%sp@-
    .short  0xA8E1	| _InsetRgn
    movel %d7,%sp@-
    movel %d6,%sp@-
    _CopyRgn
    bras DRAGTHERGN_4E_86
DRAGTHERGN_4E_76:       /* otherwise the two rectangles: slop (fp+14), limit (fp+18) */
    movel %d7,%sp@-	| 40819368
    movel %fp@(14),%sp@-
    _RectRgn
    movel %d6,%sp@-
    movel %fp@(18),%sp@-
    _RectRgn
DRAGTHERGN_4E_86:       /* next position; outside the limit: _1B6_2 */
    subqw #6,%sp	| 40819378
    movel %sp,%sp@-
    _GetMouse
    movel %sp@,%d4
    movel %d6,%sp@-
    _PtInRgn
    tstb %sp@+
    beqw DRAGTHERGN_1B6_2
DRAGTHERGN_4E_98:       /* moved? The delta, by axis (fp+12: 1 = horizontal only, 2 = vertical only) */
    movel %d4,%d1	| 4081938A
    swap %d1
    cmpl %d4,%d3
    beqs DRAGTHERGN_4E_E4
    movel %d4,%sp@-
    subw %d3,%d4
    swap %d3
    subw %d3,%d1
    movew %fp@(12),%d0
    beqs DRAGTHERGN_4E_B8
    subqw #1,%d0
    bnes DRAGTHERGN_4E_B6
    clrw %d1
    bras DRAGTHERGN_4E_B8
DRAGTHERGN_4E_B6:
    clrw %d4	| 408193A8
DRAGTHERGN_4E_B8:       /* add to the result (fp+30, fp+32); the outline painted out if shown, moved, painted back */
    addw %d1,%fp@(30)	| 408193AA
    addw %d4,%fp@(32)
    movel %a3,%sp@-
    movew %d4,%sp@-
    movew %d1,%sp@-
    tstw %d5
    beqs DRAGTHERGN_4E_D4
    bsrw DRAGTHERGN_1DA
    beqs DRAGTHERGN_4E_D4
    movel %a3,%sp@-
    .short  0xA8D3	| _PaintRgn
DRAGTHERGN_4E_D4:
    _OffsetRgn	| 408193C6
    bsrw DRAGTHERGN_1DA
    beqs DRAGTHERGN_4E_E0
    movel %a3,%sp@-
    .short  0xA8D3	| _PaintRgn
DRAGTHERGN_4E_E0:
    moveq #-1,%d5	| 408193D2
    movel %sp@+,%d3
DRAGTHERGN_4E_E4:       /* the action proc (fp+8) and DragHook; at least 2 ticks; until the mouse is up */
    movel %fp@(8),%d0	| 408193D6
    bsrw DRAGTHERGN_1AC+0x4
    bsrw DRAGTHERGN_1AC
    movel Ticks,%d0
    addql #2,%d0
DRAGTHERGN_4E_F6:
    cmpl Ticks,%d0	| 408193E8
    bhis DRAGTHERGN_4E_F6
    subqw #2,%sp
    _WaitMouseUp
    tstb %sp@+
    bnes DRAGTHERGN_4E_86
    tstw %d5
    beqs DRAGTHERGN_4E_112
    bsrw DRAGTHERGN_1DA
    beqs DRAGTHERGN_4E_112
    movel %a3,%sp@-
    .short  0xA8D3	| _PaintRgn
DRAGTHERGN_4E_112:
    _SetPenState	| 40819404
    moveal %a3@,%a0
    cmpiw #10,%a0@
    bnes DRAGTHERGN_4E_132
    movel %a3,%sp@-
    movel %d6,%sp@-
    _CopyRgn
    movel %d6,%sp@-
    movel OneOne,%sp@-
    .short  0xA8E1	| _InsetRgn
    movel %a3,%sp@-
    movel %d6,%sp@-
    movel %a3,%sp@-
    _DiffRgn
DRAGTHERGN_4E_132:      /* mouse outside the slop: result 0x80008000 */
    subqw #6,%sp	| 40819424
    movel %sp,%sp@-
    _GetMouse
    movel %d7,%sp@-
    _PtInRgn
    tstb %sp@+
    bnes DRAGTHERGN_4E_148
    movel #-2147450880,%fp@(30)
DRAGTHERGN_4E_148:
    movel %d7,%sp@-	| 4081943A
    _DisposRgn
    movel %d6,%sp@-
    _DisposRgn
    moveml %sp@+,%d3-%d7/%a3
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(22),%sp
    jmp %a0@
DRAGTHERGN_1AC:         /* set %d0 */
    movel DragHook,%d0	| 40819450
    jbeq DRAGTHERGN_1B6	| 40819454
    moveal %d0,%a0	| 40819456
    jsr %a0@	| 40819458
DRAGTHERGN_1B6:         /* return */
    rts	| 4081945A
DRAGTHERGN_1B6_2:       /* outside the limit: in the slop, carry on; outside it, paint out the outline once */
    subqw #2,%sp	| 4081945C
    movel %d4,%sp@-
    movel %d7,%sp@-
    _PtInRgn
    tstb %sp@+
    bnes DRAGTHERGN_1F4+0x2
    tstw %d5
    beqw DRAGTHERGN_4E_E4
    moveq #0,%d5
DRAGTHERGN_1B6_16:
    bsrw DRAGTHERGN_1DA	| 40819470
    beqs DRAGTHERGN_1B6_20
    movel %a3,%sp@-
    .short  0xA8D3	| _PaintRgn
DRAGTHERGN_1B6_20:
    braw DRAGTHERGN_4E_E4	| 4081947A
DRAGTHERGN_1DA:         /* set %a0 */
    moveal %a3@,%a0
    cmpiw #10,%a0@
    jbne DRAGTHERGN_1F4
    moveal %a3,%a0
    _HLock
    moveal %a3@,%a0
    pea %a0@(2)
    _FrameRect
    moveal %a3,%a0
    _HUnlock
    moveq #0,%d0
DRAGTHERGN_1F4:         /* return */
    rts
    tstw %d5
    bnes DRAGTHERGN_1F4_A
    moveq #1,%d5
    bras DRAGTHERGN_1B6_16	| 408194A0
DRAGTHERGN_1F4_A:
    subqw #4,%sp
    movel %fp@(18),%sp@-
    movel %d4,%sp@-
    .short  0xA94E	| 408194AA _PinRect
    movel %sp@+,%d4
    braw DRAGTHERGN_4E_98	| 408194AE

/* INVALRGN: _InvalRgn. */
trap_InvalRgn:
INVALRGN:
    moveq #0,%d0
INVALRGN_2:             /* save registers */
    moveml %d3-%d5/%a3,%sp@-
    movew %d0,%d5
    moveal %a5@,%a0
    moveal %a0@,%a3
    movel %sp@(20),%d4
    moveal %a3,%a0
    jbsr WMGR
    movel %a0@(6),%d3
    movel %d4,%sp@-
    movel %d3,%sp@-
    jbsr BRINGTOFRONT_98
    _OffsetRgn
    movel %a3@(122),%sp@-
    movel %d4,%sp@-
    movel %a3@(122),%sp@-
    tstw %d5
    jbne INVALRGN_36
    _UnionRgn
    jbra INVALRGN_38
INVALRGN_36:            /* _DiffRgn */
    _DiffRgn
INVALRGN_38:            /* set up and call _OffsetRgn */
    movel %d4,%sp@-
    movel %d3,%sp@-
    _OffsetRgn
INVALRGN_3E:            /* restore registers, return */
    moveml %sp@+,%d3-%d5/%a3
    movel %sp@+,%sp@
    rts

/* INVALRECT: _InvalRect. */
trap_InvalRect:
INVALRECT:
    moveq #0,%d0
INVALRECT_2:            /* set up and call _NewRgn (loop) */
    moveml %d2-%d5/%a3,%sp@-
    movew %d0,%d5
    _NewRgn
    movel %sp@,%d4
    movel %sp@(24),%sp@-
    _RectRgn
    movel %d4,%sp@-
    movew %d5,%d0
    jbsr INVALRGN_2
    movel %d4,%sp@-
    _DisposRgn
    jbra INVALRGN_3E

/* VALIDRGN: _ValidRgn. */
trap_ValidRgn:
VALIDRGN:
    moveq #-1,%d0
    jbra INVALRGN_2

/* VALIDRECT: _ValidRect. */
trap_ValidRect:
VALIDRECT:
    moveq #-1,%d0
    jbra INVALRECT_2

/* GROWWINDOW: _GrowWindow. */
trap_GrowWindow:
GROWWINDOW:
    linkw %fp,#-92
    moveml %d3-%d7/%a3-%a4,%sp@-
    jbsr SETWPORT
    movel %fp@(12),%d3
    moveal %fp@(16),%a3
    bsrw HILITEWINDOW_32_8
    pea %fp@(-28)
    movel %sp@,%sp@-
    _GetPenState
    _PenNormal
    movew #14,%sp@-
    _PenMode
    pea %pc@(WMGRGRAY)
    _PenPat
    lea %fp@(-8),%a4
    movel %a3@(16),%a4@
    movel %a3@(20),%a4@(4)
    movel %a4,%sp@-
    moveal %a3,%a0
    bsrw WMGR
    movel %a0@(6),%sp@-
    bsrw BRINGTOFRONT_98
    _OffsetRect
    bsrs GROWWINDOW_AC_8
    bsrw GROWWINDOW_AC_16_58	| 4081956E
    movel %d0,%d6
    subqw #4,%sp
    movel %d3,%sp@-
    movel %a4@(4),%sp@-
    bsrw DELTAPOINT
    movel %sp@+,%d5
GROWWINDOW_64:
    movel %d3,%sp@-
    bsrs GROWWINDOW_AC_16
    movel %sp@,%d0
    movel %d3,%sp@-
    movel %d0,%sp@-
    bsrw DELTAPOINT
    movel %sp@+,%d7
    beqs GROWWINDOW_84
    bsrs GROWWINDOW_AC_8
    addw %d7,%a4@(6)
    swap %d7
    addw %d7,%a4@(4)
    bsrs GROWWINDOW_AC_8
GROWWINDOW_84:
    bsrw DRAGTHERGN_1AC
    clrw %sp@-
    _WaitMouseUp
    tstb %sp@+
    bnes GROWWINDOW_64
    bsrs GROWWINDOW_AC_8
    bsrw GROWWINDOW_AC_16_58	| 408195B0
    cmpl %d0,%d6
    bnes GROWWINDOW_9C
    moveq #0,%d0
GROWWINDOW_9C:
    movel %d0,%fp@(20)
    _SetPenState
    bsrw RESTOREPORT
    moveml %sp@+,%d3-%d7/%a3-%a4
    unlk %fp
GROWWINDOW_AC:          /* set %a0 */
    moveal %sp@+,%a0
    lea %sp@(12),%sp
    jmp %a0@
GROWWINDOW_AC_8:
    movel %d3,%sp@-
    moveq #5,%d0
    movel %a4,%d3
    jbsr GETWVARIANT_36
    movel %sp@+,%d3
    rts
GROWWINDOW_AC_16:
    movel %a4@(4),%sp@-
    subqw #8,%sp
    movel %sp,%sp@-
    _GetMouse
    movel %d5,%sp@-
    bsrw DELTAPOINT
    moveal %fp@(8),%a0
    lea %fp@(-36),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    pea %fp@(-72)
    _GetKeys
    tstb %fp@(-66)
    bpls GROWWINDOW_AC_16_30
    movel #2147385342,%fp@(-32)
GROWWINDOW_AC_16_30:
    movel %sp@+,%a4@(4)
    bsrs GROWWINDOW_AC_16_58
    movel %sp@,%a4@(4)
    pea %fp@(-36)
    movel %d0,%sp@-
    .short  0xA94E	| 40819620 _PinRect
    swap %d5
    movew %a4@,%d3
    addw %sp@+,%d3
    addw %d5,%d3
    swap %d3
    swap %d5
    movew %a4@(2),%d3
    addw %sp@+,%d3
    addw %d5,%d3
    rts
GROWWINDOW_AC_16_58:
    subqw #4,%sp
    movel %a4@(4),%sp@-	| 4081963A
    movel %a4@,%sp@-
    jbsr trap_DeltaPoint
    movel %sp@+,%d0
    rts

/* FINDWINDOW: _FindWindow. */
trap_FindWindow:
FINDWINDOW:
    moveml %d1/%d3/%a3,%sp@-
    lea %sp@(16),%a0
    moveal %a0@+,%a1
    clrl %a1@
    movel %a0@+,%d3
    clrw %a0@
    moveq #1,%d0
    movel %d3,%d1
    jsr %pc@(CALLMBARPROC)
    tstl %d0
    jbmi FINDWINDOW_20
    moveq #1,%d0
    jbra FINDWINDOW_5A
FINDWINDOW_20:          /* set %a3 */
    moveal WindowList,%a3
FINDWINDOW_24:          /* loop: move */
    movel %a3,%d0
    jbeq FINDWINDOW_7A
    tstb %a3@(110)
    jbeq FINDWINDOW_46
    clrw %sp@-
    movel %d3,%sp@-
    movel %a3@(114),%sp@-
    _PtInRgn
    tstb %sp@+
    jbeq FINDWINDOW_46
    moveq #1,%d0
    jbsr GETWVARIANT_36
    tstw %d0
    jbne FINDWINDOW_4C
FINDWINDOW_46:          /* set %a3 */
    moveal %a3@(144),%a3
    jbra FINDWINDOW_24
FINDWINDOW_4C:          /* set %a0 */
    moveal %sp@(16),%a0
    movel %a3,%a0@
    tstw %a3@(108)
    jbpl FINDWINDOW_5C
    moveq #2,%d0
FINDWINDOW_5A:          /* continue at FINDWINDOW_6E */
    jbra FINDWINDOW_6E
FINDWINDOW_5C:          /* test #2,%d0 */
    cmpiw #2,%d0
    jblt FINDWINDOW_6C
    jbgt FINDWINDOW_68
    moveq #4,%d0
    jbra FINDWINDOW_6E
FINDWINDOW_68:          /* add 2 to %d0 */
    addqw #2,%d0
    jbra FINDWINDOW_6E
FINDWINDOW_6C:          /* set %d0 */
    moveq #3,%d0
FINDWINDOW_6E:          /* loop: move */
    movew %d0,%sp@(24)
    moveml %sp@+,%d1/%d3/%a3
    jbra SETSTRING_56
FINDWINDOW_7A:          /* set %d0 */
    movel DeskHook,%d0
    jbeq FINDWINDOW_6E
    moveq #2,%d0
    jbra FINDWINDOW_6E

/* DRAWGROWICON: _DrawGrowIcon. */
trap_DrawGrowIcon:
DRAWGROWICON:
    moveml %d4/%a3,%sp@-
    moveal %sp@(12),%a3
    jbsr SETWPORT
    moveq #6,%d0
    jbsr GETWVARIANT_36
    jbsr RESTOREPORT
    moveml %sp@+,%d4/%a3
    movel %sp@+,%sp@
    rts

/* SETDESKCPAT: _SetDeskCPat. */
trap_SetDeskCPat:
SETDESKCPAT:
    tstl %sp@(4)
    jbeq SETDESKCPAT_30
    movel DeskCPat,%d0
    jbeq SETDESKCPAT_16
    cmpl MinusOne,%d0
    jbeq SETDESKCPAT_16
    movel %d0,%sp@-
    _DisposPixPat
SETDESKCPAT_16:         /* set 0xcd8 */
    movel %sp@(4),DeskCPat
    bset #7,SPMisc2
SETDESKCPAT_22:         /* set up and call _PaintOne (loop) */
    clrl %sp@-
    movel GrayRgn,%sp@-
    _PaintOne
    moveal %sp@+,%a0
    addqw #4,%sp
    jmp %a0@
SETDESKCPAT_30:         /* set up and call _GetPattern */
    subqw #4,%sp
    movew #16,%sp@-
    _GetPattern
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movel %a0@+,DeskPattern
    movel %a0@,DeskPattern_1
    bclr #7,SPMisc2
    jbra SETDESKCPAT_22

/* SETWINCOLOR: _SetWinColor. */
trap_SetWinColor:
SETWINCOLOR:
    moveml %a2-%a3,%sp@-
    moveal ghost_AuxWinHead,%a2
    lea ghost_AuxWinHead,%a3
    jbsr SETCTLCOLOR_28
    moveal %sp@(16),%a2
    btst #15,%a2@(6)
    jbeq SETWINCOLOR_48
    subqw #4,%sp
    pea %sp@
    _GetPort
    movel %a2,%sp@-
    _SetPort
    moveal %sp@(16),%a0
    moveal %a0@,%a0
    movew %a0@(6),%d1
    muluw #8,%d1
SETWINCOLOR_32:         /* loop: cmpi */
    cmpiw #0,%a0@(0x8,%d1:w)
    jbeq SETWINCOLOR_40
    subqw #8,%d1
    jbge SETWINCOLOR_32
    moveq #0,%d1
SETWINCOLOR_40:         /* set up and call _RGBBackColor */
    pea %a0@(0xa,%d1:w)
    _RGBBackColor
    _SetPort
SETWINCOLOR_48:         /* test %a2@(110) */
    tstb %a2@(110)
    jbeq SETCTLCOLOR_1E
    movel %a2,%sp@-
    movel %a2@(114),%sp@-
    _PaintOne
    jbra SETCTLCOLOR_1E

/* SETCTLCOLOR: _SetCtlColor. */
trap_SetCtlColor:
SETCTLCOLOR:
    moveml %a2-%a3,%sp@-
    moveal ghost_AuxCtlHead,%a2
    lea ghost_AuxCtlHead,%a3
    jbsr SETCTLCOLOR_28
    moveal %sp@(16),%a0
    moveal %a0@,%a1
    tstb %a1@(16)
    jbeq SETCTLCOLOR_1E
    movel %a0,%sp@-
    _Draw1Control
SETCTLCOLOR_1E:         /* restore registers */
    moveml %sp@+,%a2-%a3
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

SETCTLCOLOR_28:         /* entry: stack frame */
    linkw %fp,#0
    clrl %sp@-
    clrw %sp@-
    clrl %sp@-
    pea %sp@(6)
    moveal %a2,%a1
    jbsr GETAUXCTL_4
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    cmpal %fp@(20),%a0
    jbeq SETCTLCOLOR_AC
    cmpil #-1,%fp@(20)
    jbeq SETCTLCOLOR_8C
    movel %a0,%sp@-
    moveal %fp@(20),%a0
    moveal %a0@,%a0
    cmpiw #-1,%a0@(6)
    moveal %sp@+,%a0
    jbeq SETCTLCOLOR_8C
    clrl %sp@-
    clrw %sp@-
    movel %fp@(24),%sp@-
    pea %sp@(6)
    moveal %a2,%a1
    jbsr GETAUXCTL_4
    moveb %sp@+,%d0
    moveal %sp@+,%a0
    jbeq SETCTLCOLOR_90
    moveal %a0@,%a0
    movel %fp@(20),%a0@(8)
SETCTLCOLOR_88:         /* return */
    unlk %fp
    rts
SETCTLCOLOR_8C:         /* set %fp@(20) */
    movel %a0,%fp@(20)
SETCTLCOLOR_90:         /* set %d0 */
    moveq #28,%d0
    .short  0xA322	| 40819820 _NewHandle (flags 0x0300)
    movel %a0,%a3@
    moveal %a0@,%a0
    movel %a2,%a0@
    movel %fp@(20),%a0@(8)
    movel %fp@(24),%d0
    _StripAddress
    movel %d0,%a0@(4)
    jbra SETCTLCOLOR_88
SETCTLCOLOR_AC:         /* set %a2 */
    moveal %a0,%a2
    moveal %a3,%a1
SETCTLCOLOR_B0:         /* loop: move */
    movel %a1@,%d1
    moveal %d1,%a0
    jbeq SETCTLCOLOR_EE
    moveal %a0@,%a0
    movel %a0@(4),%d0
    cmpl %fp@(24),%d0
    jbeq SETCTLCOLOR_C6
    moveal %a0,%a1
    jbra SETCTLCOLOR_B0
SETCTLCOLOR_C6:         /* set up and call _HGetState */
    movel %a0@,%sp@-
    moveal %a0@(8),%a0
    _HGetState
    btst #5,%d0
    jbne SETCTLCOLOR_D6
    _DisposHandle
SETCTLCOLOR_D6:         /* test 0xcb2 */
    tstb MMU32Bit
    jbeq SETCTLCOLOR_E8
    moveal %d1,%a0
    moveal %a0@,%a0
    movel %a2,%a0@(8)
    addqw #4,%sp
    jbra SETCTLCOLOR_EE
SETCTLCOLOR_E8:         /* set up and call _DisposHandle */
    moveal %d1,%a0
    _DisposHandle
    movel %sp@+,%a1@
SETCTLCOLOR_EE:         /* continue at SETCTLCOLOR_88 */
    jbra SETCTLCOLOR_88

/* GETAUXWIN: _GetAuxWin. */
trap_GetAuxWin:
GETAUXWIN:
    moveal ghost_AuxWinHead,%a1
    jbra GETAUXCTL_4

/* GETAUXCTL: _GetAuxCtl. */
trap_GetAuxCtl:
GETAUXCTL:
    moveal ghost_AuxCtlHead,%a1

GETAUXCTL_4:            /* set up and call _StripAddress */
    moveb #1,%sp@(12)
    movel %sp@(8),%d0
    _StripAddress
GETAUXCTL_10:           /* loop: movea */
    moveal %a1@,%a0
    cmpl %a0@(4),%d0
    jbeq GETAUXCTL_2A
    movel %a1,%d2
    movel %a0@,%d1
    moveal %d1,%a1
    jbne GETAUXCTL_10
    tstl %d0
    jbeq GETAUXCTL_2A
    clrb %sp@(12)
    moveal %d2,%a1
GETAUXCTL_2A:           /* set %a0 */
    moveal %sp@(4),%a0
    movel %a1,%a0@
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* WMGREND: end of the Window Manager. */
WMGREND:
    .short  0x0000, 0x0000, 0x0000	| 408198BA
