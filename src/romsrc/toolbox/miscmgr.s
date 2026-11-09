/*
 toolbox/miscmgr.s - Toolbox Event Manager and miscellaneous
 From MISCMGR (0x408159D0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* GETKEYS: _GetKeys: the KeyMap. */
trap_GetKeys:
MISCMGR:
GETKEYS:
    moveal %sp@(4),%a1
    lea KeyMap,%a0
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %sp@(4),%a1
    moveq #3,%d1
    jbsr TICKCOUNT_A
    movel %sp@+,%sp@
    rts

/* BUTTON: _Button: mouse button down?. */
trap_Button:
BUTTON:
    lea %sp@(4),%a1
    clrw %a1@
    tstb MBState
    jbmi BUTTON_E
    addqb #1,%a1@
BUTTON_E:               /* set %d1 */
    moveq #2,%d1
    jbra TICKCOUNT_A

/* TICKCOUNT: _TickCount. */
trap_TickCount:
TICKCOUNT:
    lea %sp@(4),%a1
    movel Ticks,%a1@
    moveq #0,%d1

TICKCOUNT_A:            /* loop: move */
    movew JournalFlag,%d0
    jbeq TICKCOUNT_40
    jbpl TICKCOUNT_16
    moveq #16,%d0
    jbra TICKCOUNT_18
TICKCOUNT_16:           /* set %d0 */
    moveq #17,%d0
TICKCOUNT_18:           /* from here: subaw #40,%sp */
    subaw #40,%sp
    lea %sp@(24),%a0
    movew JournalRef,%a0@+
    movew %d0,%a0@+
    movel %a1,%a0@+
    movew %d1,%a0@+
    movew %d3,%a0@+
    moveal %sp,%a0
    .short  0xA204	| 40815A2C _Control (flags 0x0200)
    lea %sp@(40),%sp
    jbne TICKCOUNT_38
    rts
TICKCOUNT_38:           /* clear JournalFlag */
    clrw JournalFlag
    st CrsrCouple
TICKCOUNT_40:           /* return */
    rts

/* GETMOUSE: _GetMouse: the mouse in local coordinates. */
trap_GetMouse:
GETMOUSE:
    moveal %sp@(4),%a1
    movel Mouse_v,%a1@
    moveq #1,%d1
    jbsr TICKCOUNT_A
    movel %sp@(4),%sp@-
    _GlobalToLocal
    movel %sp@+,%sp@
    rts

/* STILLDOWN: _StillDown: button still down (no event in between)?. */
trap_StillDown:
STILLDOWN:
    linkw %fp,#-20
    clrw %fp@(8)
    subqw #2,%sp
    _Button
    tstw %sp@+
    jbeq STILLDOWN_24
    subqw #2,%sp
    movew #7,%sp@-
    pea %fp@(-20)
    _EventAvail
    tstw %sp@+
    jbne STILLDOWN_24
    addqb #1,%fp@(8)
STILLDOWN_24:           /* return */
    unlk %fp
    rts

/* WAITMOUSEUP: _WaitMouseUp: the same, removing the mouse-up event. */
trap_WaitMouseUp:
WAITMOUSEUP:
    linkw %fp,#-20
    clrw %sp@-
    _StillDown
    movew %sp@+,%fp@(8)
    jbne WAITMOUSEUP_1A
    subqw #2,%sp
    movew #4,%sp@-
    pea %fp@(-20)
    _GetNextEvent
WAITMOUSEUP_1A:         /* return */
    unlk %fp
    rts

/* EVENTAVAIL: _EventAvail: the next event without removing it. */
trap_EventAvail:
EVENTAVAIL:
    moveq #-1,%d0
    jbra GETNEXTEVENT_24

/* GETNEXTEVENT: _GetNextEvent: the next event (update, activate, OS events, disk inserted, filters, SystemEvent). */
trap_GetNextEvent:
GETNEXTEVENT:
    moveml %sp@+,%d0-%d2
    subqw #2,%sp
    movel %d0,%sp@-
    movel %d1,%sp@-
    moveml %d1-%d2,%sp@-
    moveq #0,%d0
    jbsr GETNEXTEVENT_24
    movew %sp@+,%d0
    moveal %sp@+,%a1
    movew %d0,%sp@(4)
    movel GNEFilter,%sp@-
    jbne GETNEXTEVENT_22
    addqw #4,%sp
GETNEXTEVENT_22:        /* return */
    rts

GETNEXTEVENT_24:        /* entry: stack frame */
    linkw %fp,#0
    moveml %d3/%a3,%sp@-
    movel %d0,%d3
    jbne GETNEXTEVENT_64
    bset #7,DSWndUpdate
    jbne GETNEXTEVENT_64
    tstb WWExist
    jbne GETNEXTEVENT_64
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    movel WMgrPort,%sp@-
    _SetPort
    subqw #4,%sp
    _FrontWindow
    subqw #4,%sp
    _NewRgn
    moveal %sp@,%a3
    pea DSAlertRect
    _RectRgn
    movel %a3,%sp@-
    _PaintBehind
    movel %a3,%sp@-
    _DisposRgn
    _SetPort
GETNEXTEVENT_64:        /* clear %fp@(14) */
    clrw %fp@(14)
    moveal %fp@(8),%a3
    movew %fp@(12),%d0
    moveal %a3,%a0
    jbsr GETNEXTEVENT_170
    jbeq GETNEXTEVENT_7E
    addqb #1,%fp@(14)
    jbra GETNEXTEVENT_B4
GETNEXTEVENT_7E:        /* set %d0 */
    movew %fp@(12),%d0
    moveal %a3,%a0
    tstw %d3
    jbpl GETNEXTEVENT_8C
    _OSEventAvail
    jbra GETNEXTEVENT_8E
GETNEXTEVENT_8C:        /* _GetOSEvent */
    _GetOSEvent
GETNEXTEVENT_8E:        /* set %a1 */
    moveal %a3,%a1
    moveq #4,%d1
    jbsr TICKCOUNT_A
    tstw %a3@
    jbeq GETNEXTEVENT_A0
    addqb #1,%fp@(14)
    jbra GETNEXTEVENT_B4
GETNEXTEVENT_A0:        /* set %d0 */
    movew %fp@(12),%d0
    btst #6,%d0
    jbeq GETNEXTEVENT_B4
    clrw %sp@-
    movel %a3,%sp@-
    _CheckUpDate
    movew %sp@+,%fp@(14)
GETNEXTEVENT_B4:        /* test %d3 */
    tstw %d3
    jbmi GETNEXTEVENT_13E
    tstw %fp@(14)
    jbeq GETNEXTEVENT_13E
    moveq #11,%d1
    andb %a3@(14),%d1
    subqb #3,%d1
    jbne GETNEXTEVENT_12A
    moveb %a3@(4),%d0
    cmpib #63,%d0
    jbhi GETNEXTEVENT_12A
    moveb %a3@(5),%d1
    subib #48,%d1
    cmpib #10,%d1
    jbcc GETNEXTEVENT_12A
    movew %a3@,%d0
    subqw #4,%d0
    jbeq GETNEXTEVENT_126
    addqw #1,%d0
    jbne GETNEXTEVENT_12A
    subqw #4,%sp
    movel #1179338073,%sp@-
    movew %d1,%sp@-
    _GetResource
    movel %sp@+,%d0
    jbne GETNEXTEVENT_114
    cmpiw #2,%d1
    jbgt GETNEXTEVENT_126
    tstw %d1
    jbmi GETNEXTEVENT_126
    jbne GETNEXTEVENT_10A
    moveq #3,%d1
GETNEXTEVENT_10A:       /* set %d2 */
    moveq #1,%d2
    moveal 0x7dc,%a0
    jsr %a0@
    jbra GETNEXTEVENT_126
GETNEXTEVENT_114:       /* set up and call _HLock */
    moveal %d0,%a0
    movel %a0@,%d0
    jbeq GETNEXTEVENT_126
    _HLock
    movel %a0,%sp@-
    moveal %a0@,%a0
    jsr %a0@
    moveal %sp@+,%a0
    _HUnlock
GETNEXTEVENT_126:       /* clear %a3@ */
    clrw %a3@
    jbra GETNEXTEVENT_13A
GETNEXTEVENT_12A:       /* test SEvtEnb */
    tstb SEvtEnb
    jbeq GETNEXTEVENT_13E
    subqw #2,%sp
    movel %a3,%sp@-
    _SystemEvent
    tstw %sp@+
    jbeq GETNEXTEVENT_13E
GETNEXTEVENT_13A:       /* clear %fp@(14) */
    clrw %fp@(14)
GETNEXTEVENT_13E:       /* test bit 7 of SCSIPoll */
    btst #7,SCSIPoll
    jbne GETNEXTEVENT_15A
    cmpil #1200,Ticks
    jbcs GETNEXTEVENT_15A
    bset #7,SCSIPoll
    jbsr GETNEXTEVENT_1DA
GETNEXTEVENT_15A:       /* set up and call _GetMouse */
    tstw %a3@
    jbne GETNEXTEVENT_164
    pea Scratch8
    _GetMouse
GETNEXTEVENT_164:       /* restore registers, return */
    moveml %sp@+,%d3/%a3
    unlk %fp
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@

GETNEXTEVENT_170:       /* test bit 8 of %d0 */
    btst #8,%d0
    jbeq GETNEXTEVENT_1CA
    movel CurDeactive,%d1
    jbgt GETNEXTEVENT_1D6
    movel CurActivate,%d1
    jble GETNEXTEVENT_1CA
    moveq #1,%d2
GETNEXTEVENT_184:       /* set up and call _OSEventAvail (loop) */
    moveq #0,%d0
    _OSEventAvail
    movew #8,%a0@+
    movel %d1,%a0@
    movel CurDeactive,%d0
    jbeq GETNEXTEVENT_1AA
    movew CurDeKind,%d0
    movel CurActivate,%d1
    jbeq GETNEXTEVENT_1AA
    moveal %d1,%a0
    movew %a0@(108),%d1
    eorw %d0,%d1
    jbpl GETNEXTEVENT_1AA
    addqw #2,%d2
GETNEXTEVENT_1AA:       /* set %d0 */
    movew %a3@(14),%d0
    andiw #-4,%d0
    orw %d2,%d0
    movew %d0,%a3@(14)
    tstw %d3
    jbne GETNEXTEVENT_1C6
    lsrw #1,%d0
    jbcc GETNEXTEVENT_1CE
    bset #7,CurActivate
GETNEXTEVENT_1C6:       /* loop: moveq */
    moveq #-1,%d1
    rts
GETNEXTEVENT_1CA:       /* clear %d1 */
    moveq #0,%d1
    rts
GETNEXTEVENT_1CE:       /* set bit 7 of CurDeactive */
    bset #7,CurDeactive
    jbra GETNEXTEVENT_1C6
GETNEXTEVENT_1D6:       /* clear %d2 */
    clrw %d2
    jbra GETNEXTEVENT_184

GETNEXTEVENT_1DA:       /* set up and call _SCSIDispatch */
    clrl %sp@-
    clrl %sp@-
    movew #1,%sp@-
    _SCSIDispatch
    tstw %sp@
    jbne GETNEXTEVENT_22A
    moveb SCSIPoll,%d0
    andib #7,%d0
    movew %d0,%sp@-
    movew #2,%sp@-
    _SCSIDispatch
    tstw %sp@
    jbeq GETNEXTEVENT_204
    moveaw #4,%a0
    _InternalWait
    jbra GETNEXTEVENT_22A
GETNEXTEVENT_204:       /* set up and call _SCSIDispatch */
    pea %sp@(2)
    movew #6,%sp@-
    movew #3,%sp@-
    _SCSIDispatch
    pea %sp@(2)
    pea %sp@(8)
    moveq #60,%d0
    movel %d0,%sp@-
    movew #4,%sp@-
    _SCSIDispatch
    moveaw #5,%a0
    _InternalWait
GETNEXTEVENT_22A:       /* add 8 to %sp */
    addql #8,%sp
    rts
    .short  0x0000	| 40815CCE

/* WAITNEXTEVENT: _WaitNextEvent: GetNextEvent with sleep and mouse region. */
trap_WaitNextEvent:
WAITNEXTEVENT:
    linkw %fp,#0
    moveml %d3-%d4/%a2,%sp@-
    moveq #-1,%d4
    movel Ticks,%d3
    addl %fp@(12),%d3
    jbcc WAITNEXTEVENT_16
    moveq #-1,%d3
WAITNEXTEVENT_16:       /* set %a2 */
    moveal %fp@(16),%a2
WAITNEXTEVENT_1A:       /* _SystemTask (loop) */
    _SystemTask
    subqw #2,%sp
    movew %fp@(20),%sp@-
    movel %a2,%sp@-
    _GetNextEvent
    moveb %sp@+,%fp@(22)
    jbne WAITNEXTEVENT_6A
    cmpl %a2@(6),%d3
    jbls WAITNEXTEVENT_6A
    movel %fp@(8),%d0
    jbeq WAITNEXTEVENT_1A
    cmpl %a2@(10),%d4
    jbeq WAITNEXTEVENT_1A
    movel %a2@(10),%d4
    subqw #2,%sp
    movel %a2@(10),%sp@-
    movel %d0,%sp@-
    _PtInRgn
    tstb %sp@+
    jbne WAITNEXTEVENT_1A
    movew %fp@(20),%d0
    btst #15,%d0
    jbeq WAITNEXTEVENT_6A
    movew #15,%a2@
    movel #-100663296,%a2@(2)
    st %fp@(22)
WAITNEXTEVENT_6A:       /* restore registers, return */
    moveml %sp@+,%d3-%d4/%a2
    unlk %fp
    moveal %sp@,%a0
    lea %sp@(18),%sp
    jmp %a0@
    .long   0x00000000, 0x00000000	| 40815D48
