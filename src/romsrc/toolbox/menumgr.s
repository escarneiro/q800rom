/*
 toolbox/menumgr.s - Menu Manager
 From MMGR (0x40816D20). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside say what that part does.
*/

/* INITPROCMENU: _InitProcMenu: the menu bar definition procedure. */
trap_InitProcMenu:
MMGR:
INITPROCMENU:
    subqw #4,%sp
    movel #1296188486,%sp@-
    movew %sp@(12),%sp@-
    _GetResource
    movel %sp@+,0xb58
    jbeq MMGR_24
    jbsr INITMENUS_8
    moveal MenuList,%a1
    moveal %a1@,%a1
    moveal %sp@+,%a0
    movew %sp@+,%a1@(4)
MMGR_22:                /* return through %a0 */
    jmp %a0@
MMGR_24:                /* no such 'MBDF': plain InitMenus */
    moveal %sp@+,%a0
    addqw #2,%sp
    movel %a0,%sp@-
    jbsr trap_InitMenus
    moveal %sp@+,%a0
    jbra MMGR_22

/* INITMENUS: _InitMenus: menu list, menu bar height, draw the empty bar. */
trap_InitMenus:
INITMENUS:
    moveq #0,%d1
    movew #-1,ROMMapInsert
INITMENUS_8:            /* load the 'MBDF' (ID %d1); missing: system error 85 (dsMBarNFnd) */
    subqw #4,%sp
    movel #1296188486,%sp@-
    movew %d1,%sp@-
    _GetResource
    movel %sp@+,0xb58
    jbne INITMENUS_24
    tstw %d1
    jbne trap_InitMenus
    movew #85,%d0
    _SysError
INITMENUS_24:           /* no menu list yet: a new empty one, the menu color table, the MBDF's init message */
    tstl MenuList
    jbgt INITMENUS_70
    movel #-1,0xb68
    jbsr INITMENUS_76
    movel %a0,MenuList
    moveal %a0@,%a0
    movew %d1,%a0@(4)
    clrw TheMenu
    movel %a1,MenuCInfo
    jbsr CALCMBHEIGHT_30
    moveq #12,%d0
    andb SPMisc2,%d0
    lsrw #2,%d0
    movew %d0,MenuFlash
    clrw MBarEnable
    clrl MBarHook
    clrl MenuHook
    moveq #3,%d0
    moveq #0,%d1
    jbsr CALLMBARPROC
    jbsr CALCMBHEIGHT_60
    _ClearMenuBar
    _DrawMenuBar
INITMENUS_70:           /* the keyboard icon's position in the menu bar */
    jsr %pc@(SMGRCALCRECT)
    rts

INITMENUS_76:           /* new menu color table (one end marker -99) and menu list (with room for hierarchical menus) */
    moveq #30,%d0
    .short  0xA122	| 40816DC8 _NewHandle (flags 0x0100)
    moveal %a0@,%a1
    movew #-99,%a1@
    movel %a0,%sp@-
    moveq #12,%d0
    .short  0xA322	| 40816DD4 _NewHandle (flags 0x0300)
    moveal %a0@,%a1
    movew #10,%a1@(2)
    moveal %sp@+,%a1
    rts

/* CALCMBHEIGHT: menu bar height from the system font. */
CALCMBHEIGHT:
    moveq #6,%d0
    jbsr CALLMBARPROC
    rts
    movel %d4,%sp@-
    jsr %pc@(CALCMBHEIGHT_20)
    subqw #8,%sp
    movel %sp,%sp@-
    _GetFontInfo
    jsr %pc@(CALCMBHEIGHT_2A)
    movel %sp@+,%d0
    addqw #4,%sp
    movel %sp@+,%d4
    rts
CALCMBHEIGHT_20:        /* save the port, set the Window Manager port */
    moveal %a5@,%a0
    movel %a0@,%d4
    movel WMgrPort,%a0@
    rts
CALCMBHEIGHT_2A:        /* restore the port */
    movel %d4,%sp@-
    _SetPort
    rts

CALCMBHEIGHT_30:        /* the 'mctb' 0 color table, if any, through _SetMCEntries */
    moveb #1,%sp@-
    _SetResLoad
    subqw #4,%sp
    movel #1835234402,%sp@-
    clrw %sp@-
    _GetResource
    moveal %sp@+,%a0
    movel %a0,%d0
    jbeq CALCMBHEIGHT_5E
    _HGetState
    moveb %d0,%sp@-
    movel %a0,%sp@-
    _HLock
    moveal %a0@,%a0
    movew %a0@+,%sp@-
    movel %a0,%sp@-
    _SetMCEntries
    moveal %sp@+,%a0
    moveb %sp@+,%d0
    _HSetState
CALCMBHEIGHT_5E:        /* return */
    rts

CALCMBHEIGHT_60:        /* the two submenu delays in ticks (MBDF data +14, +15), from parameter RAM 126 and 127 (machines with it) */
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    clrb %a0@(14)
    clrb %a0@(15)
    tstw ROM85
    jbmi CALCMBHEIGHT_9E
    btst #5,HWCfgFlags
    jbeq CALCMBHEIGHT_9E
    lea %a0@(14),%a0
    moveq #1,%d0
    swap %d0
    movew #126,%d0
    _ReadXPRam
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    lea %a0@(15),%a0
    moveq #1,%d0
    swap %d0
    movew #127,%d0
    _ReadXPRam
CALCMBHEIGHT_9E:        /* defaults if zero */
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    tstb %a0@(14)
    jbne CALCMBHEIGHT_B0
    addqb #8,%a0@(14)
    nop
CALCMBHEIGHT_B0:        /* the drag delay (60) */
    tstb %a0@(15)
    jbne CALCMBHEIGHT_BC
    addib #60,%a0@(15)
CALCMBHEIGHT_BC:        /* return */
    rts

/* CLEARMENUBAR: _ClearMenuBar. */
trap_ClearMenuBar:
CLEARMENUBAR:
    jbsr DISABLEITEM_1A
    moveal MenuList,%a0
    _DisposHandle
    moveal MenuCInfo,%a0
    _DisposHandle
    jbsr INITMENUS_76
    movel %a0,MenuList
    movel %a1,MenuCInfo
    jbsr CALCMBHEIGHT_30
    clrw TheMenu
    rts

/* INSERTMENU: _InsertMenu: add a menu to the list (or hierarchical list). */
trap_InsertMenu:
INSERTMENU:
    moveml %d3/%a3-%a4,%sp@-
    cmpiw #-1,%sp@(16)
    jbeq INSERTMENU_30
    jbsr DISABLEITEM_1A
    moveal %a0,%a3
    moveal %sp@(18),%a0
    moveal %a0@,%a0
    movew %a0@,%d1
    jbsr INSERTMENU_DA
    jbne INSERTMENU_98
    movew %sp@(16),%d1
    jbsr INSERTMENU_DA
    jbne INSERTMENU_4E
    movew %a3@,%d0
    addqw #6,%d0
    jbra INSERTMENU_4E
INSERTMENU_30:          /* hierarchical menu (-1): into the second part of the list */
    jbsr DISABLEITEM_36
    moveal %a0,%a3
    moveal %sp@(18),%a0
    moveal %a0@,%a0
    moveq #0,%d1
    movew %a0@,%d1
    jbsr INSERTMENU_A2
    jbne INSERTMENU_98
    addqw #6,%a3@
    movel MinusOne,%d1
    jbsr INSERTMENU_A2
    addqw #6,%d0
INSERTMENU_4E:          /* the new entry (handle, left edge); before menu beforeID, or at the end */
    moveq #0,%d3
    movew %d0,%d3
    clrl Scratch8
    clrl scratch8_4
    lea Scratch8,%a0
    movel %sp@(18),%a0@
    cmpiw #-1,%sp@(16)
    jbeq INSERTMENU_70
    jbsr DISABLEITEM_26
    addqw #6,%a1@
INSERTMENU_70:          /* insert it with _Munger; one more menu */
    subqw #4,%sp
    movel MenuList,%sp@-
    movel %d3,%sp@-
    clrl %sp@-
    clrl %sp@-
    movel %a0,%sp@-
    movel #6,%sp@-
    _Munger
    addqw #4,%sp
    cmpiw #-1,%sp@(16)
    jbeq INSERTMENU_98
    moveq #2,%d0
    moveq #0,%d1
    jbsr CALLMBARPROC
INSERTMENU_98:          /* restore registers */
    moveml %sp@+,%d3/%a3-%a4
INSERTMENU_9C:          /* drop the arguments, return */
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@

INSERTMENU_A2:          /* index of hierarchical menu %d1 in the menu list; 0 if not found */
    movel %d3,%sp@-
    tstl %d1
    jbeq INSERTMENU_D2
    jbsr DISABLEITEM_26
    movew %a1@,%d2
    addqw #6,%d2
    cmpil #-1,%d1
    jbeq INSERTMENU_D4
    movew %a1@(0x0,%d2:w),%d3
    jbeq INSERTMENU_D2
    addw %d2,%d3
    exg %d2,%d3
INSERTMENU_C2:          /* loop over the hierarchical entries */
    moveal %a1@(0x0,%d2:w),%a0
    moveal %a0@,%a0
    cmpw %a0@,%d1
    jbeq INSERTMENU_D4
    subqw #6,%d2
    cmpw %d2,%d3
    jbne INSERTMENU_C2
INSERTMENU_D2:          /* not found */
    moveq #0,%d2
INSERTMENU_D4:          /* return the index */
    movel %sp@+,%d3
    movew %d2,%d0
    rts

INSERTMENU_DA:          /* index of menu %d1 in the menu bar part of the list; 0 if not found */
    tstw %d1
    jbeq INSERTMENU_F6
    jbsr DISABLEITEM_26
    movew %a1@,%d2
    jbeq INSERTMENU_F6
INSERTMENU_E6:          /* loop from the last menu */
    movel %a1@(0x0,%d2:w),%d0
    moveal %d0,%a0
    moveal %a0@,%a0
    cmpw %a0@,%d1
    jbeq INSERTMENU_F8
    subqw #6,%d2
    jbne INSERTMENU_E6
INSERTMENU_F6:          /* not found */
    moveq #0,%d2
INSERTMENU_F8:          /* return the index */
    movew %d2,%d0
    rts

/* DELETEMENU: _DeleteMenu. */
trap_DeleteMenu:
DELETEMENU:
    movew TheMenu,%d0
    cmpw %sp@(4),%d0
    jbne DELETEMENU_E
    clrw %sp@-
    _HiliteMenu
DELETEMENU_E:           /* delete its color entries; find it among the hierarchical, then the bar menus */
    movew %sp@(4),%sp@-
    movew #-98,%sp@-
    _DelMCEntries
    moveq #0,%d1
    movew %sp@(4),%d1
    jbsr INSERTMENU_A2
    jbne DELETEMENU_38
    jbsr INSERTMENU_DA
    jbeq DELETEMENU_6A
    jbsr DISABLEITEM_26
    cmpw %a1@,%d0
    jbne DELETEMENU_34
    movew %a1@(0x4,%d0:w),%a1@(2)
DELETEMENU_34:          /* one bar menu less */
    subqw #6,%a1@
    jbra DELETEMENU_3E
DELETEMENU_38:          /* one hierarchical menu less */
    jbsr DISABLEITEM_3E
    subqw #6,%a1@
DELETEMENU_3E:          /* remove the 6-byte entry with _Munger; recalculate the bar */
    moveq #0,%d1
    movew %d0,%d1
    moveal MenuList,%a0
    moveal %a0@,%a0
    addal %d1,%a0
    subqw #4,%sp
    movel MenuList,%sp@-
    movel %d1,%sp@-
    movel %a0,%sp@-
    moveq #6,%d0
    movel %d0,%sp@-
    moveq #4,%d0
    movel %d0,%sp@-
    clrl %sp@-
    _Munger
    addqw #4,%sp
    moveq #2,%d0
    moveq #0,%d1
    jbsr CALLMBARPROC
DELETEMENU_6A:          /* drop the argument, return */
    moveal %sp@+,%a0
    addqw #2,%sp
    jmp %a0@

/* DELMCENTRIES: _DelMCEntries: remove menu color entries. */
trap_DelMCEntries:
DELMCENTRIES:
    moveml %d2-%d4,%sp@-
    movew %sp@(16),%d3
    movew %sp@(18),%d4
    moveq #0,%d2
DELMCENTRIES_E:         /* per matching entry in the menu color table: remove it (_Munger) */
    movew %d3,%d0
    movew %d4,%d1
    moveal MenuCInfo,%a0
    moveal %a0@,%a0
    jbsr DELMCENTRIES_4C
    jbeq DELMCENTRIES_3E
    subqw #4,%sp
    movel MenuCInfo,%sp@-
    movel %d2,%sp@-
    pea %a0@(0x0,%d2:w)
    movel #30,%sp@-
    moveq #4,%d0
    movel %d0,%sp@-
    clrl %sp@-
    _Munger
    addqw #4,%sp
    cmpiw #-98,%d3
    jbeq DELMCENTRIES_E
DELMCENTRIES_3E:        /* rebuild the color defaults; return */
    jbsr SETMCENTRIES_60
    moveml %sp@+,%d2-%d4
    moveal %sp@+,%a0
    addqw #4,%sp
    jmp %a0@

DELMCENTRIES_4C:        /* find the next entry for menu %d1 / item %d0 from offset %d2 (-97/-98: any); Z set at the end */
    cmpiw #-99,%a0@(0x0,%d2:w)
    jbeq DELMCENTRIES_72
    cmpiw #-97,%d1
    jbeq DELMCENTRIES_60
    cmpw %a0@(0x0,%d2:w),%d1
    jbne DELMCENTRIES_6C
DELMCENTRIES_60:        /* item match */
    cmpiw #-98,%d0
    jbeq DELMCENTRIES_72
    cmpw %a0@(0x2,%d2:w),%d0
    jbeq DELMCENTRIES_72
DELMCENTRIES_6C:        /* next 30-byte entry */
    addiw #30,%d2
    jbra DELMCENTRIES_4C
DELMCENTRIES_72:        /* end marker (-99)? */
    cmpiw #-99,%a0@(0x0,%d2:w)
    rts

/* DRAWMBAR: draw the menu bar (MBDF). */
DRAWMBAR:
    moveq #0,%d0
    moveq #-1,%d1
    jbsr CALLMBARPROC
    rts

/* DRAWMENUBAR: _DrawMenuBar. */
trap_DrawMenuBar:
DRAWMENUBAR:
    movew TheMenu,%sp@-
    clrw %sp@-
    _HiliteMenu
    bset #7,AlarmState
    moveq #0,%d0
    moveq #0,%d1
    jbsr CALLMBARPROC
    _HiliteMenu
    jsr %pc@(SWAPICON)
    rts

/* HILITEMENU: _HiliteMenu: highlight a title. */
trap_HiliteMenu:
HILITEMENU:
    cmpiw #3,MBarHeight
    jbgt HILITEMENU_A
    jbra HILITEMENU_48
HILITEMENU_A:           /* unhilite the current menu title through the MBDF (hilite message 5) */
    movew TheMenu,%d1
    jbeq HILITEMENU_26
    cmpw %sp@(4),%d1
    jbeq HILITEMENU_40
    jbsr INSERTMENU_DA
    jbeq HILITEMENU_26
    moveq #0,%d1
    movew %d0,%d1
    moveq #5,%d0
    jbsr CALLMBARPROC
HILITEMENU_26:          /* hilite the new title */
    movew %sp@(4),%d1
    jbsr INSERTMENU_DA
    jbeq HILITEMENU_48
    swap %d0
    movew #1,%d0
    swap %d0
    movel %d0,%d1
    moveq #5,%d0
    jbsr CALLMBARPROC
HILITEMENU_40:          /* it becomes TheMenu */
    moveal %sp@+,%a0
    movew %sp@+,TheMenu
    jmp %a0@
HILITEMENU_48:          /* no menu bar: TheMenu = 0 */
    moveal %sp@+,%a0
    addql #2,%sp
    clrw TheMenu
    jmp %a0@

/* ENABLEITEM: _EnableItem. */
trap_EnableItem:
ENABLEITEM:
    jbsr ENABLEITEM_12
    cmpiw #31,%d0
    jbhi ENABLEITEM_E
    bset %d0,%d1
ENABLEITEM_A:           /* store the enable flags */
    movel %d1,%a0@(10)
ENABLEITEM_E:           /* return */
    jbra INSERTMENU_9C

ENABLEITEM_12:          /* the menu's enableFlags (+10) and the item number */
    moveal %sp@(10),%a0
    moveal %a0@,%a0
    movew %sp@(8),%d0
    movel %a0@(10),%d1
    rts

/* DISABLEITEM: _DisableItem. */
trap_DisableItem:
DISABLEITEM:
    jbsr ENABLEITEM_12
    cmpiw #31,%d0
    jbhi ENABLEITEM_E
    bclr %d0,%d1
    jbra ENABLEITEM_A

DISABLEITEM_C:          /* the menu handle of menu list entry %d5, dereferenced */
    jbsr DISABLEITEM_1A
    moveal %a0@(0x0,%d5:w),%a1
    tstl %a1@
    jbeq DISABLEITEM_32
    moveal %a1@,%a0
    rts

DISABLEITEM_1A:         /* the menu list, dereferenced; nil: system error 84 (menuPrgErr) */
    moveal MenuList,%a0
    tstl %a0@
    jbeq DISABLEITEM_32
    moveal %a0@,%a0
    rts

DISABLEITEM_26:         /* same, into %a1 */
    moveal MenuList,%a1
    tstl %a1@
    jbeq DISABLEITEM_32
    moveal %a1@,%a1
    rts
DISABLEITEM_32:         /* system error 84 */
    moveq #84,%d0
    _SysError

DISABLEITEM_36:         /* the start of the hierarchical part of the list (%a0) */
    jbsr DISABLEITEM_1A
    addaw %a0@,%a0
    addqw #6,%a0
    rts

DISABLEITEM_3E:         /* same, into %a1 */
    jbsr DISABLEITEM_26
    addaw %a1@,%a1
    addqw #6,%a1
    rts

/* MENUSELECT: _MenuSelect: track the mouse in the menu bar and menus, return the choice. */
trap_MenuSelect:
MENUSELECT:
    linkw %fp,#-40
    moveml %d2-%d7/%a2-%a4,%sp@-
    clrw %sp@-
    _HiliteMenu
    clrl %fp@(12)
    clrl MenuDisable
    pea %fp@(-12)
    _GetPort
    moveal ghost_WMgrCPort,%a2
    movel %a2,%sp@-
    _SetPort
    clrw %d5
    clrw %d4
    clrw %fp@(-14)
    jbsr POPUPMENUSELECT_140
    clrl %fp@(-28)
    clrw %fp@(-30)
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    moveb %a0@(14),%fp@(-23)
    moveb %a0@(15),%fp@(-24)
    movel %fp@(8),%d3
    moveq #20,%d0
    .short  0xA122	| 408171DC _NewHandle (flags 0x0100)
    moveal %a0,%a4
MENUSELECT_52:          /* tracking loop: which menu or item is under the mouse (MBDF hit message 1) */
    moveq #1,%d0
    movel %d3,%d1
    jbsr CALLMBARPROC
    tstl %d0
    jbmi MENUSELECT_7E
    jbeq MENUSELECT_6C
    movew %d0,%d5
    jbsr DISABLEITEM_C
    movew %a0@,%fp@(12)
    jbra MENUSELECT_72
MENUSELECT_6C:          /* none */
    clrw %d5
    clrw %fp@(12)
MENUSELECT_72:          /* a different menu: pull it down */
    cmpw %d5,%d4
    jbeq MENUSELECT_7E
    jbsr POPUPMENUSELECT_180
    jbmi MENUSELECT_FE
MENUSELECT_7E:          /* choose the item under the mouse in the open menu */
    tstw %d5
    jbeq MENUSELECT_8E
    jbsr POPUPMENUSELECT_160
    jbsr POPUPMENUSELECT_1F2
    jbsr POPUPMENUSELECT_21A
MENUSELECT_8E:          /* while the button is down: the mouse, MenuHook */
    clrw %sp@-
    _WaitMouseUp
    tstb %sp@+
    jbeq MENUSELECT_AA
    subqw #4,%sp
    movel %sp,%sp@-
    _GetMouse
    movel %sp@+,%d3
    movel MenuHook,%d0
    jbeq MENUSELECT_A8
    moveal %d0,%a0
    jsr %a0@
MENUSELECT_A8:          /* again */
    jbra MENUSELECT_52
MENUSELECT_AA:          /* released: a hierarchical item counts as nothing */
    tstw %d5
    jbeq MENUSELECT_D2
    jbsr DISABLEITEM_C
    movew %fp@(14),%d0
    jbsr CALLMBARPROC_52
    jbeq MENUSELECT_CA
    cmpib #27,%a1@(1)
    jbne MENUSELECT_CA
    clrw %fp@(14)
    jbra MENUSELECT_CE
MENUSELECT_CA:          /* flash the chosen item (MenuFlash) */
    jbsr POPUPMENUSELECT_4EE
MENUSELECT_CE:          /* close all open menus */
    jbsr POPUPMENUSELECT_3E8
MENUSELECT_D2:          /* nothing chosen: unhilite the title */
    tstw %fp@(14)
    jbne MENUSELECT_EC
    clrw %fp@(12)
    movew %fp@(-30),%d0
    jbeq MENUSELECT_EC
    movew %d5,%d0
    jbsr FLASHMENUBAR_32
    clrw %fp@(-30)
MENUSELECT_EC:          /* desk accessory menu? */
    movew %fp@(-30),TheMenu
    tstw TheMenu
    jbmi MENUSELECT_11C
    tstw MBarEnable
    jbmi MENUSELECT_11C
MENUSELECT_FE:          /* dispose of the open-menu stack; restore the port */
    moveal %a4,%a0
    _DisposHandle
    movel %fp@(-12),%sp@-
    _SetPort
MENUSELECT_108:         /* restore registers, return */
    moveml %sp@+,%d2-%d7/%a2-%a4
    unlk %fp
    movel %sp@+,%sp@
    moveq #0,%d1
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    clrw %a0@
    rts
MENUSELECT_11C:         /* tell the desk accessory (_SystemMenu) */
    tstw MBarEnable
    jbmi MENUSELECT_138
    movew TheMenu,MBarEnable
    movel %fp@(12),%sp@-
    _SystemMenu
    clrl %fp@(12)
    clrw MBarEnable
    jbra MENUSELECT_142
MENUSELECT_138:         /* same */
    movel %fp@(12),%sp@-
    _SystemMenu
    clrl %fp@(12)
MENUSELECT_142:         /* return */
    jbra MENUSELECT_FE

/* POPUPMENUSELECT: _PopUpMenuSelect: track a pop-up menu. */
trap_PopUpMenuSelect:
POPUPMENUSELECT:
    movew %sp@(4),%d0
    movel %sp@(6),%d1
    movel %sp@,%sp@(6)
    addqw #6,%sp
    linkw %fp,#-46
    moveml %d2-%d7/%a2-%a4,%sp@-
    movew %d0,%fp@(-42)
    movel %d1,%fp@(-46)
    clrl %fp@(12)
    clrl MenuDisable
    subqw #2,%sp
    _WaitMouseUp
    tstb %sp@+
    jbeq POPUPMENUSELECT_13C
    pea %fp@(-12)
    _GetPort
    moveal ghost_WMgrCPort,%a2
    movel %a2,%sp@-
    _SetPort
    clrw %d5
    clrw %d4
    clrw %fp@(-14)
    jbsr POPUPMENUSELECT_140
    clrl %fp@(-28)
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    moveb %a0@(14),%fp@(-23)
    moveb %a0@(15),%fp@(-24)
    moveq #20,%d0
    .short  0xA122	| 40817334 _NewHandle (flags 0x0100)
    moveal %a0,%a4
    moveal %fp@(8),%a0
    moveal %a0@,%a0
    movew %a0@,%d1
    jbsr INSERTMENU_A2
    movew %d0,%d4
    jbeq POPUPMENUSELECT_13C
    moveal CrsrDevice,%a1
    moveal %a1@,%a1
    movel %a1@(34),%a2@(16)
    movel %a1@(38),%a2@(20)
    jbsr GETITEM_24
    movel %fp@(8),%sp@-
    _CalcMenuSize
    movew %d4,%d5
    jbsr POPUPMENUSELECT_3F4
    movew MBarHeight,%sp@-
    clrw MBarHeight
POPUPMENUSELECT_A2:     /* tracking loop (as in MenuSelect) */
    moveq #1,%d0
    movel %d3,%d1
    jbsr CALLMBARPROC
    tstl %d0
    jbmi POPUPMENUSELECT_C2
    movew %d0,%d5
    jbsr DISABLEITEM_C
    movew %a0@,%fp@(12)
    cmpw %d5,%d4
    jbeq POPUPMENUSELECT_C2
    jbsr POPUPMENUSELECT_180
    jbmi POPUPMENUSELECT_120
POPUPMENUSELECT_C2:     /* choose the item under the mouse */
    tstw %d5
    jbeq POPUPMENUSELECT_D2
    jbsr POPUPMENUSELECT_160
    jbsr POPUPMENUSELECT_1F2
    jbsr POPUPMENUSELECT_21A
POPUPMENUSELECT_D2:     /* while the button is down */
    clrw %sp@-
    _WaitMouseUp
    tstb %sp@+
    jbeq POPUPMENUSELECT_EE
    subqw #4,%sp
    movel %sp,%sp@-
    _GetMouse
    movel %sp@+,%d3
    movel MenuHook,%d0
    jbeq POPUPMENUSELECT_EC
    moveal %d0,%a0
    jsr %a0@
POPUPMENUSELECT_EC:     /* again */
    jbra POPUPMENUSELECT_A2
POPUPMENUSELECT_EE:     /* released: a hierarchical item counts as nothing */
    tstw %d5
    jbeq POPUPMENUSELECT_116
    jbsr DISABLEITEM_C
    movew %fp@(14),%d0
    jbsr CALLMBARPROC_52
    jbeq POPUPMENUSELECT_10E
    cmpib #27,%a1@(1)
    jbne POPUPMENUSELECT_10E
    clrw %fp@(14)
    jbra POPUPMENUSELECT_112
POPUPMENUSELECT_10E:    /* flash the item */
    jbsr POPUPMENUSELECT_4EE
POPUPMENUSELECT_112:    /* close all open menus */
    jbsr POPUPMENUSELECT_3E8
POPUPMENUSELECT_116:    /* nothing chosen */
    tstw %fp@(14)
    jbne POPUPMENUSELECT_120
    clrw %fp@(12)
POPUPMENUSELECT_120:    /* restore MBarHeight and the port's rectangles; return */
    movew %sp@+,MBarHeight
    moveal WMgrPort,%a0
    movel %a0@(16),%a2@(16)
    movel %a0@(20),%a2@(20)
    jbsr GETITEM_24
    jbra MENUSELECT_FE
POPUPMENUSELECT_13C:    /* return */
    jbra MENUSELECT_108

POPUPMENUSELECT_140:    /* start the two submenu timers: now plus each delay byte */
    subqw #4,%sp
    _TickCount
    movel %sp@,%fp@(-18)
    moveq #0,%d0
    moveb %fp@(-23),%d0
    addl %d0,%fp@(-18)
    movel %sp@+,%fp@(-22)
    moveb %fp@(-24),%d0
    addl %d0,%fp@(-22)
    rts

POPUPMENUSELECT_160:    /* the open menu's rectangle (MBDF message 9), then MBDF message 11 */
    moveq #9,%d0
    moveq #0,%d1
    movew %d5,%d1
    jbsr CALLMBARPROC
    moveal %d0,%a0
    movel %a0@,%fp@(-8)
    movel %a0@(4),%fp@(-4)
    moveq #11,%d0
    movew %d5,%d1
    jbsr CALLMBARPROC
    rts
POPUPMENUSELECT_180:    /* a new menu under the mouse: close the old ones, open the new one */
    clrw %fp@(14)
    tstw %d4
    jbeq POPUPMENUSELECT_1AA
    jbsr DISABLEITEM_1A
    cmpw %a0@,%d5
    jbgt POPUPMENUSELECT_1EE
    tstw %d5
    jbeq POPUPMENUSELECT_196
    jbsr POPUPMENUSELECT_160
POPUPMENUSELECT_196:    /* close back to it; flash the title */
    jbsr POPUPMENUSELECT_3B6
    jbsr POPUPMENUSELECT_140
    cmpiw #4,%fp@(-14)
    jbeq POPUPMENUSELECT_1EE
    movew %d4,%d0
    jbsr FLASHMENUBAR_32
POPUPMENUSELECT_1AA:    /* hilite the title, then pull the menu down (MBarHook may cancel) */
    movew %fp@(12),%fp@(-30)
    tstw %d5
    jbeq POPUPMENUSELECT_1EE
    movew %d5,%d0
    jbsr FLASHMENUBAR_36
    movel MBarHook,%d0
    jbeq POPUPMENUSELECT_1EA
    moveq #9,%d0
    moveq #0,%d1
    movew %d5,%d1
    jbsr CALLMBARPROC
    moveal %d0,%a0
    movel %a0@,%fp@(-8)
    movel %a0@(4),%fp@(-4)
    moveal MBarHook,%a0
    pea %fp@(-8)
    jsr %a0@
    tstw %d0
    jbeq POPUPMENUSELECT_1EA
    movew #-1,%d5
    jbra POPUPMENUSELECT_1EE
POPUPMENUSELECT_1EA:    /* draw it */
    jbsr POPUPMENUSELECT_43E
POPUPMENUSELECT_1EE:    /* the current menu */
    movew %d5,%d4
    rts

POPUPMENUSELECT_1F2:    /* hilite the chosen item through the MDEF, then MBDF message 10 */
    pea %fp@(-8)
    _ClipRect
    jbsr DISABLEITEM_C
    movew #1,%sp@-
    movel %a1,%sp@-
    pea %fp@(-8)
    movel %d3,%sp@-
    pea %fp@(14)
    jbsr POPUPMENUSELECT_4B6
    moveq #10,%d0
    movew %d5,%d1
    jbsr CALLMBARPROC
    rts
POPUPMENUSELECT_21A:    /* a hierarchical item held past the first delay: open its submenu */
    jbsr DISABLEITEM_C
    movew %fp@(14),%d0
    jbeq POPUPMENUSELECT_274
    jbsr CALLMBARPROC_52
    cmpib #27,%a1@(1)
    jbne POPUPMENUSELECT_274
    movew %fp@(12),%d0
    cmpw %fp@(-26),%d0
    jbne POPUPMENUSELECT_274
    movew %fp@(14),%d0
    cmpw %fp@(-28),%d0
    jbne POPUPMENUSELECT_274
    movel %a1,%sp@-
    subqw #4,%sp
    _TickCount
    movel %sp@+,%d0
    moveal %sp@+,%a1
    cmpl %fp@(-18),%d0
    jblt POPUPMENUSELECT_27C
    moveq #0,%d1
    moveb %a1@(2),%d1
    jbsr INSERTMENU_A2
    jbeq POPUPMENUSELECT_274
    movew %d0,%d5
    jbsr POPUPMENUSELECT_43E
    movew %d5,%fp@(-32)
    movew %d4,%d5
    jbsr POPUPMENUSELECT_160
    jbsr POPUPMENUSELECT_28A
    jbra POPUPMENUSELECT_27C
POPUPMENUSELECT_274:    /* close deeper menus */
    jbsr POPUPMENUSELECT_3B6
    jbsr POPUPMENUSELECT_140
POPUPMENUSELECT_27C:    /* remember the item */
    movew %fp@(14),%fp@(-28)
    movew %fp@(12),%fp@(-26)
    rts

POPUPMENUSELECT_28A:    /* moving towards an open submenu: keep it open while the mouse stays inside the triangle */
    moveml %d4,%sp@-
    subqw #4,%sp
    movel %sp,%sp@-
    _GetMouse
    movel %sp@+,%d3
POPUPMENUSELECT_296:    /* outer loop: stop on mouse up or on reaching the submenu; MenuHook */
    clrw %sp@-
    _WaitMouseUp
    tstb %sp@+
    jbeq POPUPMENUSELECT_3A4
    moveq #1,%d0
    movel %d3,%d1
    jbsr CALLMBARPROC
    cmpw %fp@(-32),%d0
    jbeq POPUPMENUSELECT_3A4
    subqw #2,%sp
    subqw #4,%sp
    movel %sp,%sp@-
    _GetMouse
    movel %sp@,%d3
    movel MenuHook,%d0
    jbeq POPUPMENUSELECT_2C4
    moveal %d0,%a0
    jsr %a0@
POPUPMENUSELECT_2C4:    /* still in the rectangle at (0xB5C) +6: keep tracking; else the submenu's two near corners */
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    pea %a0@(6)
    _PtInRect
    moveb %sp@+,%d0
    jbne POPUPMENUSELECT_296
    moveq #9,%d0
    moveq #0,%d1
    movew %fp@(-32),%d1
    jbsr CALLMBARPROC
    moveal %d0,%a0
    movel %a0@,%d4
    movew %a0@(4),%d5
    swap %d5
    movew %a0@(2),%d5
    cmpw %d3,%d4
    jbgt POPUPMENUSELECT_2FA
    movew %a0@(6),%d4
    movew %a0@(6),%d5
POPUPMENUSELECT_2FA:    /* start the delay */
    jbsr POPUPMENUSELECT_140
POPUPMENUSELECT_2FE:    /* inner loop: the same, while the delay runs */
    clrw %sp@-
    _WaitMouseUp
    tstb %sp@+
    jbeq POPUPMENUSELECT_3A4
    subqw #2,%sp
    subqw #4,%sp
    movel %sp,%sp@-
    _GetMouse
    movel %sp@,%d6
    movel MenuHook,%d0
    jbeq POPUPMENUSELECT_31C
    moveal %d0,%a0
    jsr %a0@
POPUPMENUSELECT_31C:    /* in the submenu? else: is the mouse still heading towards it? */
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    pea %a0@(6)
    _PtInRect
    moveb %sp@+,%d0
    jbne POPUPMENUSELECT_296
    moveq #1,%d0
    movel %d6,%d1
    jbsr CALLMBARPROC
    cmpw %fp@(-32),%d0
    jbeq POPUPMENUSELECT_3A4
    cmpw %d3,%d4
    jblt POPUPMENUSELECT_374
    cmpw %d3,%d6
    jblt POPUPMENUSELECT_3A4
    movel %d6,%d1
    movel %d3,%d0
    jbsr POPUPMENUSELECT_362
    movew %d0,%d7
    movel %d4,%d1
    movel %d3,%d0
    jbsr POPUPMENUSELECT_362
    cmpw %d0,%d7
    jblt POPUPMENUSELECT_3A4
    movel %d5,%d1
    movel %d3,%d0
    jbsr POPUPMENUSELECT_362
    cmpw %d0,%d7
    jbgt POPUPMENUSELECT_3A4
    jbra POPUPMENUSELECT_394
POPUPMENUSELECT_362:    /* the angle from point %d0 to point %d1 (_DeltaPoint, _FixRatio, _AngleFromSlope) */
    lea %sp@(-10),%sp
    movel %d1,%sp@-
    movel %d0,%sp@-
    _DeltaPoint
    _FixRatio
    _AngleFromSlope
    movew %sp@+,%d0
    rts
POPUPMENUSELECT_374:    /* submenu to the left: same test mirrored */
    cmpw %d3,%d6
    jbgt POPUPMENUSELECT_3A4
    movel %d3,%d1
    movel %d6,%d0
    jbsr POPUPMENUSELECT_362
    movew %d0,%d7
    movel %d3,%d1
    movel %d4,%d0
    jbsr POPUPMENUSELECT_362
    cmpw %d0,%d7
    jbgt POPUPMENUSELECT_3A4
    movel %d3,%d1
    movel %d5,%d0
    jbsr POPUPMENUSELECT_362
    cmpw %d0,%d7
    jblt POPUPMENUSELECT_3A4
POPUPMENUSELECT_394:    /* until the drag delay runs out */
    subqw #4,%sp
    _TickCount
    movel %sp@+,%d0
    cmpl %fp@(-22),%d0
    jbge POPUPMENUSELECT_3A4
    jbra POPUPMENUSELECT_2FE
POPUPMENUSELECT_3A4:    /* restore registers, return */
    moveml %sp@+,%d4
    movew %d4,%d5
    rts

POPUPMENUSELECT_3AC:    /* close the deepest open menu (MBDF restore message 8) */
    subqw #4,%fp@(-14)
    moveq #8,%d0
    jbra CALLMBARPROC

POPUPMENUSELECT_3B6:    /* close the menus opened after menu %d5 */
    moveal %a4@,%a0
    movew %fp@(-14),%d0
    jbeq POPUPMENUSELECT_3E6
    cmpw %a0@(0xfffffffffffffffc,%d0:w),%d5
    jbeq POPUPMENUSELECT_3E6
POPUPMENUSELECT_3C4:    /* loop */
    moveal %a4@,%a0
    movew %fp@(-14),%d0
    jbeq POPUPMENUSELECT_3E6
    cmpw %a0@(0xfffffffffffffffc,%d0:w),%d5
    jbeq POPUPMENUSELECT_3DC
    movew %a0@(0xfffffffffffffffe,%d0:w),%fp@(14)
    jbsr POPUPMENUSELECT_3AC
    jbra POPUPMENUSELECT_3C4
POPUPMENUSELECT_3DC:    /* re-hilite the item */
    tstw %fp@(-14)
    jbeq POPUPMENUSELECT_3E6
    jbsr POPUPMENUSELECT_1F2
POPUPMENUSELECT_3E6:    /* return */
    rts
POPUPMENUSELECT_3E8:    /* close all open menus */
    tstw %fp@(-14)
    jbeq POPUPMENUSELECT_3F2
    jbsr POPUPMENUSELECT_3AC
    jbra POPUPMENUSELECT_3E8
POPUPMENUSELECT_3F2:    /* return */
    rts
POPUPMENUSELECT_3F4:    /* push the pop-up menu: its rectangle from the MDEF (message 3), save the bits, draw it */
    addqw #4,%fp@(-14)
    movew %fp@(-14),%d0
    moveal %a4@,%a0
    movew %d5,%a0@(0xfffffffffffffffc,%d0:w)
    movew %fp@(14),%a0@(0xfffffffffffffffe,%d0:w)
    movew #3,%sp@-
    jbsr DISABLEITEM_C
    movel %a1,%sp@-
    pea %fp@(-8)
    movel %fp@(-46),%sp@-
    pea %fp@(-42)
    jbsr POPUPMENUSELECT_4B6
    moveq #7,%d0
    swap %d0
    movew %d5,%d0
    swap %d0
    lea %fp@(-8),%a0
    movel %a0,%d1
    jbsr CALLMBARPROC
    movew %fp@(-42),TopMenuItem
    jbsr POPUPMENUSELECT_496
    rts

POPUPMENUSELECT_43E:    /* push a menu (at most 5 deep), save the bits behind it (MBDF save message 7) */
    cmpiw #20,%fp@(-14)
    jbeq POPUPMENUSELECT_494
    addqw #4,%fp@(-14)
    movew %fp@(-14),%d0
    moveal %a4@,%a0
    movew %d5,%a0@(0xfffffffffffffffc,%d0:w)
    movew %fp@(14),%a0@(0xfffffffffffffffe,%d0:w)
    moveq #0,%d1
    cmpiw #4,%fp@(-14)
    jbeq POPUPMENUSELECT_466
    movel %d3,%d1
POPUPMENUSELECT_466:    /* its rectangle */
    moveq #9,%d0
    movew %d5,%d1
    jbsr CALLMBARPROC
    moveal %d0,%a0
    movel %a0@,%fp@(-8)
    movel %a0@(4),%fp@(-4)
    moveq #7,%d0
    swap %d0
    movew %d5,%d0
    swap %d0
    lea %fp@(-8),%a0
    movel %a0,%d1
    jbsr CALLMBARPROC
    movew %fp@(-8),TopMenuItem
    jbsr POPUPMENUSELECT_496
POPUPMENUSELECT_494:    /* return */
    rts

POPUPMENUSELECT_496:    /* draw it (mDrawMsg through the MDEF) */
    pea %fp@(-8)
    _ClipRect
    clrw %sp@-
    jbsr DISABLEITEM_C
    movel %a1,%sp@-
    pea %fp@(-8)
    subqw #8,%sp
    jbsr POPUPMENUSELECT_4B6
    moveq #10,%d0
    movew %d5,%d1
    jbsr CALLMBARPROC
    rts

POPUPMENUSELECT_4B6:    /* call the menu's MDEF (+6) with the message on the stack */
    movel %a0@(6),%d1
    jbeq POPUPMENUSELECT_4E6
    linkw %fp,#0
    movel %a3,%sp@-
    lea %sp@(-18),%sp
    lea %fp@(8),%a0
    moveal %sp,%a1
    moveq #18,%d0
    _BlockMove
    moveal %d1,%a0
    moveal %a0,%a3
    movel %a0,%sp@-
    _LoadResource
    _HLock
    moveal %a0@,%a0
    jsr %a0@
    moveal %a3,%a0
    _HUnlock
    moveal %sp@+,%a3
    unlk %fp
POPUPMENUSELECT_4E6:    /* drop the arguments */
    moveal %sp@+,%a0
    lea %sp@(18),%sp
    jmp %a0@
POPUPMENUSELECT_4EE:    /* flash the chosen item MenuFlash times */
    movew %d4,%sp@-
    movew MenuFlash,%d4
    jbeq POPUPMENUSELECT_512
    movew %fp@(14),ToolScratch
    jbeq POPUPMENUSELECT_512
    pea %fp@(-8)
    _ClipRect
POPUPMENUSELECT_504:    /* loop: unhilite, hilite, with a delay */
    moveq #0,%d1
    jbsr FULLCLIP_A
    movel %d3,%d1
    jbsr FULLCLIP_A
    subqw #1,%d4
    jbne POPUPMENUSELECT_504
    jbsr FULLCLIP
POPUPMENUSELECT_512:    /* return */
    movew %sp@+,%d4
    rts

/* FULLCLIP: clip to the whole screen while drawing menus. */
FULLCLIP:
    moveal %a5@,%a0
    movel %a0@(-130),%sp@-
    _SetClip
    rts

FULLCLIP_A:             /* hilite or unhilite item %d1 through the MDEF, delay 3 ticks */
    movew #1,%sp@-
    jbsr DISABLEITEM_C
    movel %a1,%sp@-
    pea %fp@(-8)
    movel %d1,%sp@-
    pea ToolScratch
    jbsr POPUPMENUSELECT_4B6
    moveaw #3,%a0
    _Delay
    rts

/* MENUCHOICE: _MenuChoice: the last disabled item chosen. */
trap_MenuChoice:
MENUCHOICE:
    movel MenuDisable,%sp@(4)
    rts

/* GETMENUBAR: _GetMenuBar: copy of the menu list. */
trap_GetMenuBar:
GETMENUBAR:
    moveal MenuList,%a0
    movel %a0,%sp@(4)
    jbeq GETMENUBAR_18
    _HandToHand
    movel %a0,%sp@(4)
    moveal %a0@,%a0
    movew %a0@,%d0
    clrl %a0@(0x8,%d0:w)
GETMENUBAR_18:          /* return */
    rts

/* GETMCINFO: _GetMCInfo: copy of the menu color table. */
trap_GetMCInfo:
GETMCINFO:
    moveal MenuCInfo,%a0
    _HandToHand
    jbeq GETMCINFO_A
    subal %a0,%a0
GETMCINFO_A:            /* return the copy (nil on failure) */
    movel %a0,%sp@(4)
    rts

/* SETMENUBAR: _SetMenuBar. */
trap_SetMenuBar:
SETMENUBAR:
    clrw %sp@-
    _HiliteMenu
    moveal MenuList,%a0
    _DisposHandle
    moveal %sp@(4),%a0
    movel %sp@+,%sp@
    _HandToHand
    movel %a0,MenuList
    rts

/* SETMCINFO: _SetMCInfo. */
trap_SetMCInfo:
SETMCINFO:
    moveal %sp@(4),%a0
    movel %sp@+,%sp@
    _HandToHand
    jbne SETMCINFO_1A
    moveal MenuCInfo,%a1
    movel %a0,MenuCInfo
    moveal %a1,%a0
    _DisposHandle
    jbsr SETMCENTRIES_60
SETMCINFO_1A:           /* return */
    rts

/* DISPOSEMENU: _DisposMenu. */
trap_DisposMenu:
DISPOSEMENU:
    moveal %sp@(4),%a0
    _HGetState
    btst #5,%d0
    jbeq DISPOSEMENU_12
    movel %a0,%sp@-
    _ReleaseResource
    jbra DISPOSEMENU_14
DISPOSEMENU_12:         /* _DisposHandle */
    _DisposHandle
DISPOSEMENU_14:         /* drop the argument, return */
    movel %sp@+,%sp@
    rts

/* DISPMCINFO: _DispMCInfo. */
trap_DispMCInfo:
DISPMCINFO:
    moveal %sp@(4),%a0
    _DisposHandle
    movel %sp@+,%sp@
    rts

/* FLASHMENUBAR: _FlashMenuBar: invert a title (or the bar). */
trap_FlashMenuBar:
FLASHMENUBAR:
    tstw %sp@(4)
    jbeq FLASHMENUBAR_2A
    movew TheMenu,%d0
    jbeq FLASHMENUBAR_26
    cmpw %sp@(4),%d0
    jbne FLASHMENUBAR_26
    movew %sp@(4),%d1
    jbsr INSERTMENU_DA
    jbeq FLASHMENUBAR_2E
    jbsr FLASHMENUBAR_32
    clrw TheMenu
    jbra DELETEMENU_6A
FLASHMENUBAR_26:        /* a menu other than the current one: HiliteMenu */
    jbra trap_HiliteMenu
FLASHMENUBAR_2A:        /* menu 0: invert the whole bar */
    moveq #0,%d0
    jbsr FLASHMENUBAR_36
FLASHMENUBAR_2E:        /* return */
    jbra DELETEMENU_6A

FLASHMENUBAR_32:        /* unhilite title %d0 */
    moveq #0,%d1
    jbra FLASHMENUBAR_38

FLASHMENUBAR_36:        /* hilite title %d0 */
    moveq #1,%d1
FLASHMENUBAR_38:        /* MBDF hilite message (5) */
    swap %d1
    movew %d0,%d1
    moveq #5,%d0

/* CALLMBARPROC: call the menu bar definition procedure. */
CALLMBARPROC:
    moveml %d4,%sp@-
    clrl %sp@-
    moveal MenuList,%a0
    moveal %a0@,%a0
    movew %a0@(4),%sp@-
    andiw #7,%sp@
    movew %d0,%sp@-
    swap %d0
    movew %d0,%sp@-
    movel %d1,%sp@-
    subqw #4,%sp
    movel #1296188486,%sp@-
    movew %a0@(4),%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@+,0xb58
    moveal 0xb58,%a0
    _HGetState
    movel %d0,%d4
    _HLock
    moveal %a0@,%a0
    jsr %a0@
    moveal 0xb58,%a0
    movel %d4,%d0
    _HSetState
    movel %sp@+,%d0
    moveml %sp@+,%d4
    rts

CALLMBARPROC_52:        /* find item %d0 in menu %a0: %a0 = its name, %a1 = its attributes; Z set if none */
    tstw %d0
    jble CALLMBARPROC_6E
    moveq #0,%d1
    lea %a0@(14),%a1
    moveb %a1@+,%d1
    addaw %d1,%a1
CALLMBARPROC_60:        /* loop: skip items */
    subqw #1,%d0
    jbeq CALLMBARPROC_78
    moveb %a1@,%d1
    jbeq CALLMBARPROC_6E
    addqw #5,%d1
    addaw %d1,%a1
    jbra CALLMBARPROC_60
CALLMBARPROC_6E:        /* not found: nil */
    movel %a1,%d1
    subal %a0,%a0
    moveal %a0,%a1
    movel %a0,%d0
    rts
CALLMBARPROC_78:        /* the item */
    tstb %a1@
    jbeq CALLMBARPROC_6E
    moveal %a1,%a0
    moveb %a1@+,%d1
    addaw %d1,%a1
    rts

CALLMBARPROC_84:        /* SetItem attribute: byte %d2 of the item's attributes */
    moveal %sp@(8),%a0
    moveal %a0@,%a0
    movew %sp@(6),%d0
    jbsr CALLMBARPROC_52
    jbeq CALLMBARPROC_A4
    moveb %sp@(5),%a1@(0x0,%d2:w)
    subqw #2,%d2
    jbeq CALLMBARPROC_A4
    movel %sp@(8),%sp@-
    jbsr GETITEM_46
CALLMBARPROC_A4:        /* drop the arguments, return */
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

CALLMBARPROC_AA:        /* GetItem attribute: byte %d2 of the item's attributes */
    moveal %sp@(10),%a0
    moveal %a0@,%a0
    movew %sp@(8),%d0
    jbsr CALLMBARPROC_52
    moveal %sp@(4),%a0
    clrb %a0@
    movel %a1,%d0
    jbeq CALLMBARPROC_C6
    moveb %a1@(0x0,%d2:w),%a0@(1)
CALLMBARPROC_C6:        /* drop the arguments, return */
    moveal %sp@+,%a0
    lea %sp@(10),%sp
    jmp %a0@

/* GETITEMICON: _GetItemIcon. */
trap_GetItmIcon:
GETITEMICON:
    moveq #0,%d2
    jbra CALLMBARPROC_AA

/* SETITEMICON: _SetItemIcon. */
trap_SetItmIcon:
SETITEMICON:
    moveq #0,%d2
    jbra CALLMBARPROC_84

/* GETITEMCMD: _GetItemCmd. */
trap_GetItemCmd:
GETITEMCMD:
    moveq #1,%d2
    jbra CALLMBARPROC_AA

/* SETITEMCMD: _SetItemCmd. */
trap_SetItemCmd:
SETITEMCMD:
    moveq #1,%d2
    jbra CALLMBARPROC_84

/* GETITEMSTYLE: _GetItemStyle. */
trap_GetItmStyle:
GETITEMSTYLE:
    moveq #3,%d2
    jbra CALLMBARPROC_AA

/* SETITEMSTYLE: _SetItemStyle. */
trap_SetItmStyle:
SETITEMSTYLE:
    moveq #3,%d2
    jbra CALLMBARPROC_84

/* GETITEMMARK: _GetItemMark. */
trap_GetItmMark:
GETITEMMARK:
    moveq #2,%d2
    jbra CALLMBARPROC_AA

/* SETITEMMARK: _SetItemMark. */
trap_SetItmMark:
SETITEMMARK:
    moveq #2,%d2
    jbra CALLMBARPROC_84

/* CHECKITEM: _CheckItem. */
trap_CheckItem:
CHECKITEM:
    tstb %sp@(4)
    jbeq CHECKITEM_E
    movew #18,%sp@(4)
    jbra trap_SetItmMark
CHECKITEM_E:            /* no mark */
    clrw %sp@(4)
    jbra trap_SetItmMark

CHECKITEM_14:           /* upper-case character %d0 (_UprString) */
    moveb %d0,%sp@-
    moveal %sp,%a0
    moveq #1,%d0
    .short  0xA254	| 408179DE _UprString (flags 0x0200)
    moveb %sp@+,%d0
    rts

/* SETMCENTRIES: _SetMCEntries. */
trap_SetMCEntries:
SETMCENTRIES:
    moveml %d2-%d3,%sp@-
    movew %sp@(16),%d3
    subqw #1,%d3
    muluw #30,%d3
SETMCENTRIES_E:         /* per new entry: replace a matching one, or insert it */
    moveal %sp@(12),%a1
    moveal MenuCInfo,%a0
    moveal %a0@,%a0
    movew %a1@(0x0,%d3:w),%d1
    movew %a1@(0x2,%d3:w),%d0
    moveq #0,%d2
    jbsr DELMCENTRIES_4C
    jbeq SETMCENTRIES_34
    addal %d3,%a1
    addal %d2,%a0
    exg %a0,%a1
    moveq #30,%d0
    _BlockMove
    jbra SETMCENTRIES_4E
SETMCENTRIES_34:        /* insert at the end */
    subqw #4,%sp
    movel MenuCInfo,%sp@-
    movel %d2,%sp@-
    clrl %sp@-
    clrl %sp@-
    pea %a1@(0x0,%d3:w)
    movel #30,%sp@-
    _Munger
    addqw #4,%sp
SETMCENTRIES_4E:        /* next; rebuild the color defaults */
    subiw #30,%d3
    jbge SETMCENTRIES_E
    jbsr SETMCENTRIES_60
    moveml %sp@+,%d2-%d3
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@

SETMCENTRIES_60:        /* propagate the menu bar and title colors to the item entries */
    linkw %fp,#-14
    movel %d2,%sp@-
    jbsr SETMCENTRIES_146
    moveal MenuCInfo,%a0
    moveal %a0@,%a0
    clrw %d0
    clrw %d1
    clrw %d2
    jbsr DELMCENTRIES_4C
    jbne SETMCENTRIES_88
    moveq #-1,%d0
    movel %d0,%fp@(-6)
    movew %d0,%fp@(-2)
    jbra SETMCENTRIES_94
SETMCENTRIES_88:        /* the bar's colors */
    movel %a0@(0x16,%d2:w),%fp@(-6)
    movew %a0@(0x1a,%d2:w),%fp@(-2)
SETMCENTRIES_94:        /* mark it done */
    addqw #1,%a0@(0x1c,%d2:w)
    clrw %fp@(-14)
SETMCENTRIES_9C:        /* per title entry */
    clrw %d0
    movew #-97,%d1
    movew %fp@(-14),%d2
    jbsr DELMCENTRIES_4C
    jbeq SETMCENTRIES_104
    movew %d2,%fp@(-14)
    addiw #30,%fp@(-14)
    addqw #1,%a0@(0x1c,%d2:w)
    tstw %a0@(0x0,%d2:w)
    jbeq SETMCENTRIES_9C
    movel %fp@(-6),%a0@(0xa,%d2:w)
    movew %fp@(-2),%a0@(0xe,%d2:w)
    movel %a0@(0x16,%d2:w),%fp@(-12)
    movew %a0@(0x1a,%d2:w),%fp@(-8)
    movew %a0@(0x0,%d2:w),%d1
    movew #-98,%d0
    clrw %d2
SETMCENTRIES_E2:        /* per item entry of that menu: its default color from the title */
    jbsr DELMCENTRIES_4C
    jbeq SETMCENTRIES_9C
    addqw #1,%a0@(0x1c,%d2:w)
    tstw %a0@(0x2,%d2:w)
    jbeq SETMCENTRIES_FE
    movel %fp@(-12),%a0@(0x16,%d2:w)
    movew %fp@(-8),%a0@(0x1a,%d2:w)
SETMCENTRIES_FE:        /* next */
    addiw #30,%d2
    jbra SETMCENTRIES_E2
SETMCENTRIES_104:       /* the menu bar entry; none: white */
    clrw %d0
    clrw %d1
    clrw %d2
    jbsr DELMCENTRIES_4C
    jbne SETMCENTRIES_11C
    moveq #-1,%d0
    movel %d0,%fp@(-12)
    movew %d0,%fp@(-8)
    jbra SETMCENTRIES_128
SETMCENTRIES_11C:       /* its background */
    movel %a0@(0xa,%d2:w),%fp@(-12)
    movew %a0@(0xe,%d2:w),%fp@(-8)
SETMCENTRIES_128:       /* entries not done: the bar's background */
    clrw %d2
SETMCENTRIES_12A:       /* loop */
    jbsr SETMCENTRIES_162
    jbeq SETMCENTRIES_140
    movel %fp@(-12),%a0@(0x16,%d2:w)
    movew %fp@(-8),%a0@(0x1a,%d2:w)
    addiw #30,%d2
    jbra SETMCENTRIES_12A
SETMCENTRIES_140:       /* return */
    movel %sp@+,%d2
    unlk %fp
    rts

SETMCENTRIES_146:       /* clear the done marks */
    moveal MenuCInfo,%a0
    moveal %a0@,%a0
    clrw %d2
SETMCENTRIES_14E:       /* loop */
    cmpiw #-99,%a0@(0x0,%d2:w)
    jbeq SETMCENTRIES_160
    clrw %a0@(0x1c,%d2:w)
    addiw #30,%d2
    jbra SETMCENTRIES_14E
SETMCENTRIES_160:       /* return */
    rts

SETMCENTRIES_162:       /* the next entry not done; Z set at the end */
    cmpiw #-99,%a0@(0x0,%d2:w)
    jbeq SETMCENTRIES_178
    tstw %a0@(0x1c,%d2:w)
    jbeq SETMCENTRIES_176
    addiw #30,%d2
    jbra SETMCENTRIES_162
SETMCENTRIES_176:       /* found */
    moveq #1,%d0
SETMCENTRIES_178:       /* return */
    rts

/* GETMCENTRY: _GetMCEntry. */
trap_GetMCEntry:
GETMCENTRY:
    movel %d2,%sp@-
    moveal MenuCInfo,%a0
    moveal %a0@,%a0
    movew %sp@(8),%d0
    movew %sp@(10),%d1
    clrw %d2
    jbsr DELMCENTRIES_4C
    jbeq GETMCENTRY_22
    lea %a0@(0x0,%d2:w),%a0
    movel %a0,%sp@(12)
    jbra GETMCENTRY_26
GETMCENTRY_22:          /* not found: nil */
    clrl %sp@(12)
GETMCENTRY_26:          /* return */
    movel %sp@+,%d2
    moveal %sp@+,%a0
    addqw #4,%sp
    jmp %a0@

/* MENUKEY: _MenuKey: the item with this command key. */
trap_MenuKey:
MENUKEY:
    linkw %fp,#-12
    moveml %d3-%d6/%a3,%sp@-
    moveb %fp@(9),%d0
    jbsr CHECKITEM_14
    moveb %d0,%d4
    jbsr DISABLEITEM_1A
    movew %a0@,%d5
    clrw %d6
MENUKEY_1A:             /* per menu from the last: enabled? */
    jbsr DISABLEITEM_C
    moveal %a0,%a3
    btst #0,%a3@(13)
    jbeq MENUKEY_5A
    moveq #1,%d3
MENUKEY_2A:             /* per enabled item: its key equivalent, upper case, against the key (0x1B..0x1F are not keys) */
    movel %a3@(10),%d0
    btst %d3,%d0
    jbeq MENUKEY_56
    moveal %a3,%a0
    movew %d3,%d0
    jbsr CALLMBARPROC_52
    jbeq MENUKEY_5A
    moveb %a1@(1),%d0
    jbsr CHECKITEM_14
    cmpib #27,%d0
    jblt MENUKEY_52
    cmpib #31,%d0
    jbhi MENUKEY_52
    jbra MENUKEY_56
MENUKEY_52:             /* match */
    cmpb %d0,%d4
    jbeq MENUKEY_88
MENUKEY_56:             /* next item */
    addqw #1,%d3
    jbra MENUKEY_2A
MENUKEY_5A:             /* next menu; then the hierarchical menus */
    subqw #6,%d5
    cmpw %d6,%d5
    jbgt MENUKEY_1A
    tstw %d6
    jbne MENUKEY_7A
    jbsr DISABLEITEM_36
    movew %a0@,%d5
    jbeq MENUKEY_7A
    movel MinusOne,%d1
    jbsr INSERTMENU_A2
    addw %d0,%d5
    movew %d0,%d6
    jbra MENUKEY_1A
MENUKEY_7A:             /* none: 0 */
    clrl %fp@(10)
MENUKEY_7E:             /* restore registers, return */
    moveml %sp@+,%d3-%d6/%a3
    unlk %fp
    jbra DELETEMENU_6A
MENUKEY_88:             /* found: menu and item; a submenu: hilite its top-level parent's title */
    jbsr DISABLEITEM_C
    movew %a0@,%fp@(10)
    movew %d3,%fp@(12)
    movew %fp@(10),%fp@(-8)
    tstw %d6
    jbeq MENUKEY_A6
    clrw %fp@(-10)
    moveq #8,%d4
    jbsr MENUKEY_E0
MENUKEY_A6:             /* hilite the title */
    movew %fp@(-8),%sp@-
    _HiliteMenu
    tstw MBarEnable
    jbmi MENUKEY_B8
    tstw TheMenu
    jbpl MENUKEY_7E
MENUKEY_B8:             /* desk accessory menu: _SystemMenu */
    tstw MBarEnable
    jbmi MENUKEY_D4
    movew TheMenu,MBarEnable
    movel %fp@(10),%sp@-
    _SystemMenu
    clrl %fp@(10)
    clrw MBarEnable
    jbra MENUKEY_7E
MENUKEY_D4:             /* same */
    movel %fp@(10),%sp@-
    _SystemMenu
    clrl %fp@(10)
    jbra MENUKEY_7E

MENUKEY_E0:             /* find the parent of a submenu (at most 8 levels) */
    subqw #1,%d4
    jbeq MENUKEY_13A
    jbsr DISABLEITEM_36
    movew %a0@,%d5
    movel MinusOne,%d1
    jbsr INSERTMENU_A2
    addw %d0,%d5
    movew %d0,%d6
MENUKEY_F6:             /* per menu */
    jbsr DISABLEITEM_C
    moveal %a0,%a3
    moveq #1,%d3
MENUKEY_FE:             /* per hierarchical item: does it lead to the menu? */
    moveal %a3,%a0
    movel %d3,%d0
    jbsr CALLMBARPROC_52
    jbeq MENUKEY_12C
    cmpib #27,%a1@(1)
    jbne MENUKEY_128
    moveq #0,%d1
    moveb %a1@(2),%d1
    cmpw %fp@(-8),%d1
    jbne MENUKEY_128
    movew %a3@,%fp@(-8)
    tstw %fp@(-10)
    jbeq MENUKEY_E0
    jbra MENUKEY_14E
MENUKEY_128:            /* next item */
    addqw #1,%d3
    jbra MENUKEY_FE
MENUKEY_12C:            /* next menu */
    subqw #6,%d5
    cmpw %d6,%d5
    jbgt MENUKEY_F6
    tstw %fp@(-10)
    jbeq MENUKEY_140
    jbra MENUKEY_14E
MENUKEY_13A:            /* too deep: system error 86 (hMenuFindErr) */
    movew #86,%d0
    _SysError
MENUKEY_140:            /* try the bar menus */
    addqw #1,%fp@(-10)
    jbsr DISABLEITEM_1A
    movew %a0@,%d5
    clrw %d6
    jbra MENUKEY_F6
MENUKEY_14E:            /* return */
    rts

/* GETITEM: _GetItem: an item's text. */
trap_GetItem:
GETITEM:
    moveal %sp@(10),%a0
    moveal %a0@,%a0
    movew %sp@(8),%d0
    jbsr CALLMBARPROC_52
    moveal %sp@(4),%a1
    jbeq GETITEM_20
    moveq #0,%d0
    moveb %a0@,%d0
    addqw #1,%d0
    _BlockMove
GETITEM_1C:             /* return */
    jbra CALLMBARPROC_C6
GETITEM_20:             /* no such item: empty string */
    clrb %a1@
    jbra GETITEM_1C
GETITEM_24:             /* invalidate the size of every hierarchical menu */
    jbsr DISABLEITEM_36
    movew %a0@,%d5
    movel MinusOne,%d1
    jbsr INSERTMENU_A2
    addw %d0,%d5
    movew %d0,%d6
GETITEM_36:             /* loop */
    jbsr DISABLEITEM_C
    movel %a1,%sp@-
    jbsr GETITEM_46
    subqw #6,%d5
    cmpw %d6,%d5
    jbgt GETITEM_36
    rts

GETITEM_46:             /* mark the size invalid (-1): CalcMenuSize on demand */
    moveal %sp@(4),%a0
    moveal %a0@,%a0
    movel #-1,%a0@(2)
    jbra CALCMENUSIZE_26

/* CALCMENUSIZE: _CalcMenuSize (MDEF). */
trap_CalcMenuSize:
CALCMENUSIZE:
    subql #4,%sp
    movel %sp,%sp@-
    _GetPort
    moveal ghost_WMgrCPort,%a1
    movel %a1,%sp@-
    _SetPort
    movew #2,%sp@-
    moveal %sp@(10),%a0
    movel %a0,%sp@-
    clrl %sp@-
    clrl %sp@-
    clrl %sp@-
    moveal %a0@,%a0
    jbsr POPUPMENUSELECT_4B6
    _SetPort

CALCMENUSIZE_26:        /* drop the argument, return */
    movel %sp@+,%sp@
    rts
    moveal %a3@,%a0
    movel %a0@(10),%d0
    btst %d4,%d0
    beqs CALCMENUSIZE_26_12
    btst #0,%d0
CALCMENUSIZE_26_12:     /* return */
    rts

/* NEWMENU: _NewMenu. */
trap_NewMenu:
NEWMENU:
    moveq #0,%d1
    moveq #16,%d0
    moveal %sp@(4),%a0
    moveb %a0@,%d1
    addw %d1,%d0
    .short  0xA122	| 40817D78 _NewHandle (flags 0x0100)
    movel %a0,%sp@(10)
    moveal %a0@,%a1
    movew %d1,%sp@-
    movew %sp@(10),%a1@+
    clrl %a1@+
    moveq #0,%d0
    subqw #4,%sp
    movel #1296319814,%sp@-
    movew %d0,%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    moveal %sp@+,%a0
    moveal %sp@(12),%a1
    moveal %a1@,%a1
    addqw #6,%a1
    movel %a0,%a1@+
    movel MinusOne,%a1@+
    movew %sp@+,%d1
    moveal %sp@(4),%a0
NEWMENU_46:             /* copy the title */
    moveb %a0@+,%a1@+
    dbf %d1,NEWMENU_46
    clrb %a1@+
    jbra INSERTMENU_9C

/* APPENDMENU: _AppendMenu: add items from a string with metacharacters. */
trap_AppendMenu:
APPENDMENU:
    moveal %sp@+,%a0
    movew #999,%sp@-
    movel %a0,%sp@-

/* INSMENUITEM: _InsMenuItem. */
trap_InsMenuItem:
INSMENUITEM:
    linkw %fp,#-284
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveal %fp@(10),%a4
    moveal %fp@(14),%a3
    movew %fp@(8),%d6
    addqw #1,%d6
    jbsr INSMENUITEM_22
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    jbra CALLMBARPROC_C6

INSMENUITEM_22:         /* parse the item text, one character at a time */
    jbsr INSMENUITEM_50
    moveq #0,%d3
    jbra INSMENUITEM_3E
INSMENUITEM_28:         /* double-byte characters are not metacharacters (CharByte) */
    subql #2,%sp
    movel %a4,%sp@-
    movew %d3,%sp@-
    movel #-2113535984,%sp@-
    _ScriptUtil
    movew %sp@+,%d2
    moveb %a4@(0x0,%d3:w),%d0
    jbsr INSMENUITEM_68
INSMENUITEM_3E:         /* next character; then the last item */
    addql #1,%d3
    cmpb %a4@,%d3
    jbls INSMENUITEM_28
    jbsr INSMENUITEM_FE
    movel %a3,%sp@-
    jbsr GETITEM_46
    rts

INSMENUITEM_50:         /* clear the attributes of the item being built */
    lea %fp@(-280),%a0
    clrl %a0@+
    clrl %a0@
    rts
INSMENUITEM_5A:         /* metacharacters: ^ / ! < return ; ( 0x1B */
    .long   0x5E2F213C, 0x0D3B281B	| 40817E20
INSMENUITEM_62:         /* style characters: B I U O S */
    .short  0x4249, 0x554F, 0x5300	| 40817E28

INSMENUITEM_68:         /* in a metacharacter: the attribute character */
    moveq #0,%d1
    moveb %fp@(-276),%d1
    jbeq INSMENUITEM_BA
    cmpib #1,%d1
    jbne INSMENUITEM_7A
    subiw #48,%d0
INSMENUITEM_7A:         /* style: B I U O S */
    cmpib #4,%d1
    jbne INSMENUITEM_98
    moveq #4,%d2
INSMENUITEM_82:         /* loop */
    cmpb %pc@(INSMENUITEM_62,%d2:w),%d0
    jbeq INSMENUITEM_8E
    dbf %d2,INSMENUITEM_82
    rts
INSMENUITEM_8E:         /* set the style bit */
    lea %fp@(-281),%a0
    moveb %a0@(0x0,%d1:w),%d0
    bset %d2,%d0
INSMENUITEM_98:         /* '/' with 0x1B: hierarchical */
    lea %fp@(-281),%a0
    cmpiw #8,%d1
    jbne INSMENUITEM_B0
    movew #2,%d1
    moveb #27,%a0@(0x0,%d1:w)
    movew #3,%d1
INSMENUITEM_B0:         /* store the attribute */
    moveb %d0,%a0@(0x0,%d1:w)
    clrb %fp@(-276)
    rts
INSMENUITEM_BA:         /* a metacharacter (one of INSMENUITEM_5A)? double-byte characters are not */
    tstw %d2
    jbne INSMENUITEM_CE
    lea %pc@(INSMENUITEM_5A),%a0
    moveq #7,%d1
INSMENUITEM_C4:         /* loop */
    cmpb %a0@(0x0,%d1:w),%d0
    jbeq INSMENUITEM_E0
    dbf %d1,INSMENUITEM_C4
INSMENUITEM_CE:         /* an ordinary character: append it */
    movew %fp@(-274),%d1
    lea %fp@(-272),%a0
    moveb %d0,%a0@(0x0,%d1:w)
    addqw #1,%fp@(-274)
    rts
INSMENUITEM_E0:         /* ^ ! < /: next character is the attribute */
    cmpiw #3,%d1
    jble INSMENUITEM_EC
    cmpiw #7,%d1
    jbne INSMENUITEM_F4
INSMENUITEM_EC:         /* remember which */
    addqw #1,%d1
    moveb %d1,%fp@(-276)
    rts
INSMENUITEM_F4:         /* '(': disabled */
    subqw #6,%d1
    jbne INSMENUITEM_FE
    st %fp@(-275)
    rts

INSMENUITEM_FE:         /* end of an item (';' or end): insert it */
    movew %fp@(-274),%d0
    jbeq INSMENUITEM_10A
    jbsr INSMENUITEM_120
    jbsr INSMENUITEM_50
INSMENUITEM_10A:        /* return */
    rts

INSMENUITEM_10C:        /* where to insert: after item %d6, at most after the last */
    movew %d6,%d5
    subqw #2,%sp
    movel %a3,%sp@-
    _CountMItems
    movew %sp@+,%d0
    addqw #1,%d0
    cmpw %d0,%d5
    jble INSMENUITEM_11E
    movew %d0,%d5
INSMENUITEM_11E:        /* return */
    rts

INSMENUITEM_120:        /* insert the item after item %d5 (_Munger), enable or disable it */
    jbsr INSMENUITEM_10C
    movew %d5,%d0
    moveal %a3@,%a0
    jbsr CALLMBARPROC_52
    jbeq INSMENUITEM_132
    movel %a0,%d1
    moveal %a3@,%a0
    jbsr INSMENUITEM_176
INSMENUITEM_132:        /* append its four attribute bytes */
    lea %fp@(-272),%a0
    moveal %a0,%a2
    movew %fp@(-274),%d2
    addaw %d2,%a0
    lea %fp@(-280),%a1
    moveq #3,%d0
INSMENUITEM_144:        /* loop: the attribute bytes; insert name and attributes (_Munger); '(' disables the item */
    moveb %a1@+,%a0@+
    dbf %d0,INSMENUITEM_144
    subqw #1,%a2
    addqw #5,%d2
    extl %d2
    moveal %d1,%a1
    subal %a3@,%a1
    subqw #4,%sp
    movel %a3,%sp@-
    movel %a1,%sp@-
    clrl %sp@-
    clrl %sp@-
    movel %a2,%sp@-
    movel %d2,%sp@-
    _Munger
    addqw #4,%sp
    tstb %fp@(-275)
    jbeq INSMENUITEM_174
    movel %a3,%sp@-
    movew %d5,%sp@-
    jbsr trap_DisableItem
INSMENUITEM_174:        /* return */
    rts

INSMENUITEM_176:        /* shift the enable flags of the following items */
    cmpiw #31,%d5
    jbhi INSMENUITEM_190
    movel %a0@(10),%d2
    rorl %d5,%d2
    movew %d5,%d0
    subiw #32,%d0
    negw %d0
    roxrl %d0,%d2
    movel %d2,%a0@(10)
INSMENUITEM_190:        /* return */
    rts

/* GETMHANDLE: _GetMHandle: the menu of an ID. */
trap_GetMHandle:
GETMHANDLE:
    clrl %sp@(6)
    moveq #0,%d1
    movew %sp@(4),%d1
    jbsr INSERTMENU_A2
    jbne GETMHANDLE_16
    jbsr INSERTMENU_DA
    jbeq GETMHANDLE_24
GETMHANDLE_16:          /* the handle */
    movew %d5,%sp@-
    movew %d0,%d5
    jbsr DISABLEITEM_C
    movew %sp@+,%d5
    movel %a1,%sp@(6)
GETMHANDLE_24:          /* return */
    jbra DELETEMENU_6A

/* DELMENUITEM: _DelMenuItem. */
trap_DelMenuItem:
DELMENUITEM:
    movel %sp@,%sp@-
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveal %sp@(30),%a3
    moveal %a3@,%a0
    movew %a0@,%sp@-
    movew %sp@(30),%sp@-
    _DelMCEntries
    moveal %sp@(30),%a3
    moveal %a3@,%a0
    movew %sp@(28),%d0
    cmpiw #31,%d0
    jbhi DELMENUITEM_38
    movel %a0@(10),%d1
    movew %d0,%d2
    subiw #32,%d2
    negw %d2
    roxll %d2,%d1
    roll %d0,%d1
    movel %d1,%a0@(10)
DELMENUITEM_38:         /* remove the item's name and attributes */
    jbsr CALLMBARPROC_52
    jbeq SETITEM_3E
    moveq #5,%d4
    moveq #0,%d2
    moveal %d2,%a2
    jbra SETITEM_20

/* SETITEM: _SetItem: an item's text. */
trap_SetItem:
SETITEM:
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveal %sp@(30),%a3
    movew %sp@(28),%d3
    moveal %sp@(24),%a2
    movew %d3,%d0
    moveal %a3@,%a0
    jbsr CALLMBARPROC_52
    jbeq SETITEM_3E
    moveq #1,%d4
    moveq #1,%d2
    addb %a2@,%d2
SETITEM_20:             /* replace the item's name (_Munger) */
    moveal %a0,%a4
    subal %a3@,%a4
    addb %a0@,%d4
    subqw #4,%sp
    movel %a3,%sp@-
    movel %a4,%sp@-
    clrl %sp@-
    movel %d4,%sp@-
    movel %a2,%sp@-
    movel %d2,%sp@-
    _Munger
    addqw #4,%sp
    movel %a3,%sp@-
SETITEM_3A:             /* menu size invalid */
    jbsr GETITEM_46
SETITEM_3E:             /* restore registers */
    moveml %sp@+,%d3-%d4/%a2-%a4
    jbra CALLMBARPROC_C6

/* SETMENUFLASH: _SetMenuFlash: flash count. */
trap_SetMFlash:
SETMENUFLASH:
    movew %sp@(4),MenuFlash
    jbra DELETEMENU_6A

/* ADDRESMENU: _AddResMenu: add the names of resources of a type. */
trap_AddResMenu:
ADDRESMENU:
    moveal %sp@+,%a0
    movew #999,%sp@-
    movel %a0,%sp@-

/* INSRTRESMENU: _InsertResMenu. */
trap_InsertResMenu:
INSRTRESMENU:
    cmpil #1179602516,%sp@(6)
    jbne INSRTRESMENU_10
    moveb #68,%sp@(9)
INSRTRESMENU_10:        /* 'FONT' or 'FOND': font names, sorted */
    clrw %d0
    cmpil #1179602516,%sp@(6)
    jbeq INSRTRESMENU_26
    cmpil #1179602500,%sp@(6)
    jbne INSRTRESMENU_28
INSRTRESMENU_26:        /* fonts */
    moveq #1,%d0
INSRTRESMENU_28:        /* ResLoad off; the item to insert after */
    linkw %fp,#-284
    moveml %d3-%d7/%a2-%a4,%sp@-
    movew %d0,%fp@(-284)
    movew ResLoad,%sp@-
    clrw ResLoad
    jbsr INSMENUITEM_50
    moveal %fp@(14),%a3
    movew %fp@(8),%d6
    addqw #1,%d6
    jbsr INSMENUITEM_10C
    movew %d5,%d7
INSRTRESMENU_50:        /* this resource type: count; none: next pass */
    subqw #2,%sp
    movel %fp@(10),%sp@-
    _CountResources
    movew %sp@+,%d4
    jbeq INSRTRESMENU_136
    moveq #1,%d3
INSRTRESMENU_60:        /* per resource: its name; empty or starting with '.' or '%': skip */
    subqw #4,%sp
    movel %fp@(10),%sp@-
    movew %d3,%sp@-
    _GetIndResource
    lea %fp@(-273),%a4
    clrl %sp@-
    clrl %sp@-
    movel %a4,%sp@-
    _GetResInfo
    tstb %a4@
    jbeq INSRTRESMENU_12E
    cmpib #46,%a4@(1)
    jbeq INSRTRESMENU_12E
    cmpib #37,%a4@(1)
    jbeq INSRTRESMENU_12E
    movew %d5,%d6
    cmpw %d7,%d6
    jbeq INSRTRESMENU_E8
    moveal %a3@,%a0
    movew %d6,%d0
    jbsr CALLMBARPROC_52
    moveal %a0,%a2
INSRTRESMENU_A0:        /* fonts: find the sorted place by name (IUMagString, _Pack6 10); a duplicate is skipped */
    tstb %a2@
    jbeq INSRTRESMENU_E8
    subqw #2,%sp
    moveal %a2,%a0
    moveq #0,%d0
    moveb %a0@+,%d0
    movel %a0,%sp@-
    moveal %a4,%a0
    moveq #0,%d1
    moveb %a0@+,%d1
    movel %a0,%sp@-
    movew %d0,%sp@-
    movew %d1,%sp@-
    moveal %a3,%a0
    _HLock
    movew MinusOne,ResLoad
    movew #10,%sp@-
    _Pack6
    clrw ResLoad
    moveal %a3,%a0
    _HUnlock
    movew %sp@+,%d0
    jbgt INSRTRESMENU_E8
    jbeq INSRTRESMENU_12E
    cmpw %d7,%d6
    jbeq INSRTRESMENU_E8
    moveq #0,%d0
    moveb %a2@,%d0
    addqw #5,%d0
    addal %d0,%a2
    addqw #1,%d6
    jbra INSRTRESMENU_A0
INSRTRESMENU_E8:        /* fonts, with _ScriptUtil implemented: a non-Roman font's item is drawn in its script (key 0x1C, icon = script) */
    tstw %fp@(-284)
    jbeq INSRTRESMENU_124
    movew #159,%d0
    .short  0xA146	| 40818110 _GetTrapAddress (flags 0x0100)
    movel %a0,%d1
    movew #181,%d0
    .short  0xA146	| 40818118 _GetTrapAddress (flags 0x0100)
    cmpl %a0,%d1
    jbeq INSRTRESMENU_124
    movel %a4,%sp@-
    pea %fp@(-282)
    _GetFNum
    clrw %sp@-
    movew %fp@(-282),%sp@-
    movel #-2113798138,%sp@-
    _ScriptUtil
    movew %sp@+,%d0
    jbeq INSRTRESMENU_124
    moveb #28,%fp@(-279)
    moveb %d0,%fp@(-280)
INSRTRESMENU_124:       /* insert the item */
    movew %d5,%sp@-
    jbsr INSMENUITEM_FE
    movew %sp@+,%d5
    addqw #1,%d7
INSRTRESMENU_12E:       /* next resource */
    addqw #1,%d3
    cmpw %d4,%d3
    jble INSRTRESMENU_60
INSRTRESMENU_136:       /* 'FOND's done: now the 'FONT's */
    cmpil #1179602500,%fp@(10)
    jbne INSRTRESMENU_14A
    moveb #84,%fp@(13)
    jbra INSRTRESMENU_50
INSRTRESMENU_14A:       /* CalcMenuSize; restore ResLoad */
    movel %a3,%sp@-
    _CalcMenuSize
    moveal %a3,%a0
    _HUnlock
    _SetResLoad
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    jbra CALLMBARPROC_C6

/* COUNTMITEMS: _CountMItems. */
trap_CountMItems:
COUNTMITEMS:
    moveq #0,%d2
COUNTMITEMS_2:          /* count the items until none */
    addqw #1,%d2
    moveal %sp@(4),%a0
    moveal %a0@,%a0
    movew %d2,%d0
    jbsr CALLMBARPROC_52
    jbne COUNTMITEMS_2
    subqw #1,%d2
    movew %d2,%sp@(8)
    movel %sp@+,%sp@
    rts

/* PLOTICON: _PlotIcon: CopyBits an icon. */
trap_PlotIcon:
PLOTICON:
    lea IconBitmap,%a1
    movel %sp@(4),%d0
    jbeq PLOTICON_38
    moveal %d0,%a0
    movel %a0@,%a1@+
    movew #4,%a1@+
    clrl %a1@+
    movel #2097184,%a1@
    movel %sp@(8),%d1
    lea IconBitmap,%a1
    movel %a1,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    pea %a0@(2)
    pea %a1@(6)
    movel %d1,%sp@-
    clrw %sp@-
    clrl %sp@-
    _CopyBits
PLOTICON_38:            /* return */
    jbra CALLMBARPROC_A4

/* MMGREND: end of the Menu Manager. */
MMGREND:
    .long   0x00000000, 0x00000000, 0x00000000	| 408181D4
