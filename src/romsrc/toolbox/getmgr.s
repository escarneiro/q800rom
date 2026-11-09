/*
 toolbox/getmgr.s - Get* resource utilities (GetPattern, GetCursor, ...)
 From GMGR (0x40821C50). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* GETPATTERN: _GetPattern: 'PAT ' resource. */
trap_GetPattern:
GMGR:
GETPATTERN:
    movel #1346458656,%d0
GMGR_6:                 /* set up and call _GetResource (loop) */
    subqw #4,%sp
    movel %d0,%sp@-
    movew %sp@(12),%sp@-
    _GetResource
    movel %sp@+,%d0
    moveal %sp@+,%a0
    addqw #2,%sp
    movel %d0,%sp@
    jmp %a0@

/* GETCURSOR: _GetCursor: 'CURS' resource. */
trap_GetCursor:
GETCURSOR:
    movel #1129665107,%d0
    movew #-1,ROMMapInsert
    jbra GMGR_6

/* GETSTRING: _GetString: 'STR ' resource. */
trap_GetString:
GETSTRING:
    movel #1398034976,%d0
    jbra GMGR_6

/* GETICON: _GetIcon: 'ICON' resource. */
trap_GetIcon:
GETICON:
    movel #1229147982,%d0
    jbra GMGR_6

/* GETPICTURE: _GetPicture: 'PICT' resource. */
trap_GetPicture:
GETPICTURE:
    movel #1346978644,%d0
    jbra GMGR_6

/* GETNEWCWINDOW: _GetNewCWindow: color window from 'WIND' (and 'wctb'). */
trap_GetNewCWindow:
GETNEWCWINDOW:
    linkw %fp,#-4
    movew #-1,%fp@(-4)
    jbra GETNEWWINDOW_8

/* GETNEWWINDOW: _GetNewWindow. */
trap_GetNewWindow:
GETNEWWINDOW:
    linkw %fp,#-4
    clrw %fp@(-4)
GETNEWWINDOW_8:         /* set %sp@- */
    movel %a3,%sp@-
    clrl %fp@(18)
    subqw #4,%sp
    movel #1464421956,%sp@-
    movew %fp@(16),%sp@-
    _GetResource
    moveal %sp@+,%a3
    movel %a3,%d0
    beqw GETNEWWINDOW_9C
    moveal %a3@,%a0
    subqw #4,%sp
    movel %fp@(12),%sp@-
    movel %a0,%sp@-
    pea %a0@(18)
    moveb %a0@(10),%fp@(-1)
    clrw %sp@-
    movew %a0@(8),%sp@-
    movel %fp@(8),%sp@-
    movew %a0@(12),%sp@-
    movel %a0@(14),%sp@-
    moveal %a3,%a0
    _HLock
    tstw %fp@(-4)
    jbeq GETNEWWINDOW_58
    _NewCWindow
    jbra GETNEWWINDOW_5A
GETNEWWINDOW_58:        /* _NewWindow */
    _NewWindow
GETNEWWINDOW_5A:        /* set up and call _HUnlock */
    movel %sp@+,%fp@(18)
    moveal %a3,%a0
    _HUnlock
    _HPurge
    subqw #4,%sp
    movel #2003006562,%sp@-
    movew %fp@(16),%sp@-
    _GetResource
    movel %sp@+,%d0
    jbeq GETNEWWINDOW_7E
    movel %fp@(18),%sp@-
    movel %d0,%sp@-
    _SetWinColor
GETNEWWINDOW_7E:        /* test %fp@(-1) */
    tstb %fp@(-1)
    jbeq GETNEWWINDOW_9C
    movel %fp@(18),%sp@-
    cmpil #-1,%fp@(8)
    jbeq GETNEWWINDOW_9A
    moveb #1,%sp@-
    _ShowHide
    jbra GETNEWWINDOW_9C
GETNEWWINDOW_9A:        /* _ShowWindow */
    _ShowWindow
GETNEWWINDOW_9C:        /* set %a3 */
    moveal %sp@+,%a3
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(10),%sp
    jmp %a0@

/* GETNEWCONTROL: _GetNewControl: control from 'CNTL' (and 'cctb'). */
trap_GetNewControl:
GETNEWCONTROL:
    linkw %fp,#-2
    movel %a3,%sp@-
    clrl %fp@(14)
    subqw #4,%sp
    movel #1129206860,%sp@-
    movew %fp@(12),%sp@-
    _GetResource
    moveal %sp@+,%a3
    movel %a3,%d0
    jbeq GETNEWCONTROL_78
    moveal %a3@,%a0
    subqw #4,%sp
    movel %fp@(8),%sp@-
    movel %a0,%sp@-
    pea %a0@(22)
    lea %a0@(8),%a1
    moveb %a1@(2),%fp@(-2)
    clrb %sp@-
    movew %a1@,%sp@-
    addqw #4,%a1
    movel %a1@+,%sp@-
    movew %a1@+,%sp@-
    movel %a1@+,%sp@-
    moveal %a3,%a0
    _HLock
    _NewControl
    movel %sp@+,%fp@(14)
    moveal %a3,%a0
    _HUnlock
    _HPurge
    subqw #4,%sp
    movel #1667462242,%sp@-
    movew %fp@(12),%sp@-
    _GetResource
    movel %sp@+,%d0
    jbeq GETNEWCONTROL_6C
    movel %fp@(14),%sp@-
    movel %d0,%sp@-
    _SetCtlColor
GETNEWCONTROL_6C:       /* set up and call _ShowControl */
    tstb %fp@(-2)
    jbeq GETNEWCONTROL_78
    movel %fp@(14),%sp@-
    _ShowControl
GETNEWCONTROL_78:       /* set %a3 */
    moveal %sp@+,%a3
    unlk %fp
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@

/* GETMENU: _GetMenu: 'MENU' resource (and its colors). */
trap_GetRMenu:
GETMENU:
    linkw %fp,#0
    movel %a3,%sp@-
    movew ResLoad,%sp@-
    moveq #0,%d0
    jbsr GETMENU_A0
    jbeq GETMENU_94
    movel %a3@,%d0
    jbeq GETMENU_3C
    clrl %sp@-
    moveal %a3@,%a0
    movel %a0@(6),%sp@-
    clrl %sp@-
    pea %sp@(8)
    clrl %sp@-
    movew #-1,ROMMapInsert
    _GetResInfo
    movel %sp@+,%d0
    cmpil #1296319814,%d0
    jbeq GETMENU_94
    jbra GETMENU_42
GETMENU_3C:             /* set %d0 */
    moveq #1,%d0
    jbsr GETMENU_A0
    jbeq GETMENU_94
GETMENU_42:             /* subtract 4 to %sp */
    subqw #4,%sp
    movel #1296319814,%sp@-
    moveal %a3@,%a0
    movew %a0@(6),%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    moveal %a3@,%a0
    movel %sp@+,%a0@(6)
    movel %a3,%sp@-
    _CalcMenuSize
    moveb #1,%sp@-
    _SetResLoad
    subqw #4,%sp
    movel #1835234402,%sp@-
    movew %fp@(8),%sp@-
    _GetResource
    moveal %sp@+,%a3
    movel %a3,%d0
    jbeq GETMENU_94
    moveal %a3,%a0
    _HGetState
    moveb %d0,%sp@-
    _HLock
    moveal %a3@,%a0
    movew %a0@,%sp@-
    addqw #2,%a0
    movel %a0,%sp@-
    _SetMCEntries
    moveal %a3,%a0
    moveb %sp@+,%d0
    _HSetState
GETMENU_94:             /* _SetResLoad */
    _SetResLoad
    moveal %sp@+,%a3
    unlk %fp
    moveal %sp@+,%a0
    addqw #2,%sp
    jmp %a0@

GETMENU_A0:             /* set up and call _SetResLoad */
    moveb %d0,%sp@-
    _SetResLoad
    subqw #4,%sp
    movel #1296387669,%sp@-
    movew %fp@(8),%sp@-
    _GetResource
    moveal %sp@+,%a3
    movel %a3,%fp@(10)
    rts

/* GETNEWMBAR: _GetNewMBar: menu list from 'MBAR'. */
trap_GetNewMBar:
GETNEWMBAR:
    linkw %fp,#0
    moveml %d3/%a3,%sp@-
    clrl %fp@(10)
    subqw #4,%sp
    _GetMenuBar
    _ClearMenuBar
    subqw #4,%sp
    movel #1296187730,%sp@-
    movew %fp@(8),%sp@-
    _GetResource
    moveal %sp@+,%a3
    movel %a3,%d0
    jbeq GETNEWMBAR_4A
    moveq #0,%d3
GETNEWMBAR_28:          /* loop: subq */
    subqw #4,%sp
    moveal %a3@,%a0
    movew %d3,%d0
    addw %d0,%d0
    movew %a0@(0x2,%d0:w),%sp@-
    _GetRMenu
    clrw %sp@-
    _InsertMenu
    moveal %a3@,%a0
    addqw #1,%d3
    cmpw %a0@,%d3
    jblt GETNEWMBAR_28
    subqw #4,%sp
    _GetMenuBar
    movel %sp@+,%fp@(10)
GETNEWMBAR_4A:          /* set up and call _SetMenuBar */
    movel %sp@,%sp@-
    _SetMenuBar
    moveal %sp@+,%a0
    _DisposHandle
    moveml %sp@+,%d3/%a3
    unlk %fp
    moveal %sp@+,%a0
    addqw #2,%sp
    jmp %a0@

/* GETMGREND: end. */
GETMGREND:
    .short  0x0000	| 40821EDE
