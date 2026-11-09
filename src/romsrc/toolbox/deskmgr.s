/*
 toolbox/deskmgr.s - Desk Manager and Notification Manager
 From DESKMGR (0x4081C750). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* SYSTEMEVENT: _SystemEvent: give desk accessories their events. */
trap_SystemEvent:
DESKMGR:
SYSTEMEVENT:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    clrw %sp@(12)
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    movew %a3@,%d0
    cmpiw #12,%d0
    jbcc DESKMGR_40
    addw %d0,%d0
    lea %pc@(SYSTEMEVENT_24),%a0
    addaw %a0@(0x0,%d0:w),%a0
    jmp %a0@
SYSTEMEVENT_24:         /* (data) */
    .short  DESKMGR_40-SYSTEMEVENT_24	| 4081C774
    .short  DESKMGR_40-SYSTEMEVENT_24	| 4081C776
    .short  DESKMGR_48-SYSTEMEVENT_24	| 4081C778
    .short  DESKMGR_48-SYSTEMEVENT_24	| 4081C77A
    .short  DESKMGR_48-SYSTEMEVENT_24	| 4081C77C
    .short  DESKMGR_48-SYSTEMEVENT_24	| 4081C77E
    .short  SYSTEMEVENT_A0-SYSTEMEVENT_24	| 4081C780
    .short  SYSTEMEVENT_AC-SYSTEMEVENT_24	| 4081C782
    .short  SYSTEMEVENT_A0-SYSTEMEVENT_24	| 4081C784
    .short  DESKMGR_40-SYSTEMEVENT_24	| 4081C786
    .short  DESKMGR_48-SYSTEMEVENT_24	| 4081C788
    .short  DESKMGR_48-SYSTEMEVENT_24	| 4081C78A
SYSTEMEVENT_3C:         /* loop: addq */
    addqb #1,%sp@(16)
DESKMGR_40:             /* _SetPort (loop) */
    _SetPort
    moveal %sp@+,%a3
    movel %sp@+,%sp@
    rts
DESKMGR_48:             /* set up and call _FrontWindow */
    subqw #4,%sp
    _FrontWindow
    movel %sp@+,%d0
    jbeq DESKMGR_40
    moveal %d0,%a0
    jbsr SYSTEMEVENT_64
    jbne DESKMGR_40
    movew %a3@,%d0
    movew %a1@(36),%d1
    btst %d0,%d1
    jbeq DESKMGR_40
    jbsr SYSTEMEVENT_80
    jbra SYSTEMEVENT_3C

SYSTEMEVENT_64:         /* loop: move */
    movew %a0@(108),%d0
    jbpl DESKMGR_7C
    notw %d0
    aslw #2,%d0
    moveal UTableBase,%a0
    moveal %a0@(0x0,%d0:w),%a0
    moveal %a0@,%a1
    moveq #0,%d0
    rts
DESKMGR_7C:             /* result -1 */
    moveq #-1,%d0
    rts

SYSTEMEVENT_80:         /* loop: moveq */
    moveq #64,%d0

SYSTEMEVENT_82:         /* entry: stack frame */
    linkw %fp,#-32
    lea %fp@(-8),%a0
    movew %a1@(24),%a0@+
    movew %d0,%a0@+
    movel %a3,%a0@
    lea %fp@(-32),%a0
    .short  0xA204	| 4081C7E6 _Control (flags 0x0200)
    unlk %fp
    rts

SYSTEMEVENT_9C:         /* result 65 */
    moveq #65,%d0
    jbra SYSTEMEVENT_82
SYSTEMEVENT_A0:         /* set %a0 */
    moveal %a3@(2),%a0
    jbsr SYSTEMEVENT_64
    jbne DESKMGR_40
    jbsr SYSTEMEVENT_80
    jbra SYSTEMEVENT_3C
SYSTEMEVENT_AC:         /* test %a3@(2) */
    tstw %a3@(2)
    jbeq DESKMGR_C2
    moveal 0x7dc,%a0
    movew %a3@(4),%d1
    moveq #1,%d2
    jsr %a0@
    jbra SYSTEMEVENT_3C
DESKMGR_C2:             /* set up and call _MountVol */
    subaw #24,%sp
    moveal %sp,%a0
    movew %a3@(4),%a0@(22)
    _MountVol
    lea %sp@(24),%sp
    movew %d0,%a3@(2)
    jbra DESKMGR_40

/* SYSTEMCLICK: _SystemClick: a click in a desk accessory window. */
trap_SystemClick:
SYSTEMCLICK:
    moveml %d0/%d3-%d4/%a3-%a4,%sp@-
    movel %sp,%sp@-
    _GetPort
    moveal %sp@(24),%a4
    moveal %a4@(126),%a3
    movel %sp@(28),%d4
    movel %a4,%d0
    beqw SYSTEMCLICK_74
    moveal %a4,%a0
    jbsr SYSTEMEVENT_64
    jbne SYSTEMCLICK_68
    movel %a1,%d3
    moveq #0,%d0
    moveb %a4@(126),%d0
    clrl %sp@-
    movew %d0,%sp@-
    movel %a4,%sp@-
    movew #1,%sp@-
    moveal %d4,%a0
    movel %a0@(10),%sp@-
    movel %a3,%sp@-
    _LoadResource
    moveal %a3,%a0
    _HLock
    moveal %a3@,%a0
    jsr %a0@
    moveal %a3,%a0
    _HUnlock
    movel %sp@+,%d0
    jbeq SYSTEMCLICK_68
    subqw #2,%d0
    jbeq SYSTEMCLICK_9C
    subqw #2,%d0
    jbeq SYSTEMCLICK_AE
    clrl %sp@-
    _FrontWindow
    movel %sp@+,%d0
    cmpl %a4,%d0
    jbne SYSTEMCLICK_96
    moveal %d4,%a3
    moveal %d3,%a1
    jbsr SYSTEMEVENT_80
SYSTEMCLICK_68:         /* _SetPort (loop) */
    _SetPort
    moveml %sp@+,%d3-%d4/%a3-%a4
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
SYSTEMCLICK_74:         /* set up and call _SetPort */
    tstl DeskHook
    jbeq SYSTEMCLICK_68
    movel WMgrPort,%sp@-
    _SetPort
    movel GrayRgn,%sp@-
    _SetClip
    clrl %sp@-
    _ClipAbove
    moveal %d4,%a0
    moveal DeskHook,%a1
    moveq #-1,%d0
    jsr %a1@
    jbra SYSTEMCLICK_68
SYSTEMCLICK_96:         /* set up and call _SelectWindow */
    movel %a4,%sp@-
    _SelectWindow
    jbra SYSTEMCLICK_68
SYSTEMCLICK_9C:         /* set %sp@- */
    movel %a4,%sp@-
    moveal %d4,%a0
    movel %a0@(10),%sp@-
    moveal %a5@,%a0
    pea %a0@(-116)
    _DragWindow
    jbra SYSTEMCLICK_68
SYSTEMCLICK_AE:         /* clear %sp@- */
    clrw %sp@-
    movel %a4,%sp@-
    moveal %d4,%a0
    movel %a0@(10),%sp@-
    _TrackGoAway
    tstb %sp@+
    jbeq SYSTEMCLICK_68
    moveal %d3,%a1
    movel CloseOrnHook,%d0
    jbne SYSTEMCLICK_CE
    movew %a1@(24),%sp@-
    _CloseDeskAcc
    jbra SYSTEMCLICK_68
SYSTEMCLICK_CE:         /* set %a0 */
    moveal %d0,%a0
    jsr %a0@
    jbra SYSTEMCLICK_68

/* SYSTEMTASK: _SystemTask: periodic actions for the desk accessories. */
trap_SystemTask:
SYSTEMTASK:
    jsr %pc@(NMTASK)
    moveml %d3/%a3,%sp@-
    bset #7,TaskLock
    bnew SYSTEMTASK_7A
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    clrl %sp@-
    _FrontWindow
    movel %sp@+,%d0
    jbeq SYSTEMTASK_36
    moveal %d0,%a0
    jbsr SYSTEMEVENT_64
    jbne SYSTEMTASK_36
    btst #7,%a1@(5)
    jbne SYSTEMTASK_36
    moveq #66,%d0
    jbsr SYSTEMEVENT_82
SYSTEMTASK_36:          /* set %a3 */
    moveal UTableBase,%a3
    movew UnitTableEntryCount,%d3
SYSTEMTASK_3E:          /* loop: move */
    movel %a3@+,%d0
    jbeq SYSTEMTASK_70
    moveal %d0,%a0
    moveal %a0@,%a1
    movew %a1@(4),%d0
    andiw #8352,%d0
    cmpiw #8224,%d0
    jbne SYSTEMTASK_70
    moveq #0,%d0
    movew %a1@(34),%d0
    jbeq SYSTEMTASK_6C
    addl %a1@(26),%d0
    cmpl Ticks,%d0
    jbgt SYSTEMTASK_70
    movel Ticks,%a1@(26)
SYSTEMTASK_6C:          /* call SYSTEMEVENT_9C */
    jbsr SYSTEMEVENT_9C
SYSTEMTASK_70:          /* set up and call _SetPort */
    subqw #1,%d3
    jbgt SYSTEMTASK_3E
    _SetPort
    clrb TaskLock
SYSTEMTASK_7A:          /* restore registers, return */
    moveml %sp@+,%d3/%a3
    rts

/* SYSTEMMENU: _SystemMenu: a menu choice for a desk accessory. */
trap_SystemMenu:
SYSTEMMENU:
    moveml %a2-%a3,%sp@-
    movel %sp@(12),%d1
    swap %d1
    movew MBarEnable,%d0
    jbeq SYSTEMMENU_12
    movew %d0,%d1
SYSTEMMENU_12:          /* set %a2 */
    moveal UTableBase,%a2
    movew UnitTableEntryCount,%d2
SYSTEMMENU_1A:          /* loop: move */
    movel %a2@+,%d0
    jbeq SYSTEMMENU_3C
    moveal %d0,%a0
    moveal %a0@,%a1
    btst #5,%a1@(5)
    jbeq SYSTEMMENU_3C
    cmpw %a1@(38),%d1
    jbne SYSTEMMENU_3C
    moveal %sp@(12),%a3
    moveq #67,%d0
    jbsr SYSTEMEVENT_82
    jbra SYSTEMMENU_40
SYSTEMMENU_3C:          /* subtract 1 to %d2 */
    subqw #1,%d2
    jbgt SYSTEMMENU_1A
SYSTEMMENU_40:          /* restore registers, return */
    moveml %sp@+,%a2-%a3
    movel %sp@+,%sp@
    rts

/* SYSTEMEDIT: _SystemEdit: an edit command for the active desk accessory. */
trap_SysEdit:
SYSTEMEDIT:
    clrw %sp@(6)
    subqw #8,%sp
    pea %sp@(4)
    _GetPort
    _FrontWindow
    movel %sp@+,%d0
    jbeq SYSTEMEDIT_2A
    moveal %d0,%a0
    jbsr SYSTEMEVENT_64
    jbne SYSTEMEDIT_2A
    movew %sp@(8),%d0
    addiw #68,%d0
    jbsr SYSTEMEVENT_82
    addqb #1,%sp@(10)
SYSTEMEDIT_2A:          /* _SetPort */
    _SetPort
    jbra CLOSEDESKACC_14

/* OPENDESKACC: _OpenDeskAcc: open a desk accessory driver. */
trap_OpenDeskAcc:
OPENDESKACC:
    clrw %sp@(8)
    subaw #32,%sp
    movel %sp@(36),%sp@(18)
    clrw %sp@(22)
    movew #64,%sp@(26)
    clrl %sp@(28)
    moveal %sp,%a0
    _Open
    jbne OPENDESKACC_46
    movew %sp@(24),%d0
    movew %d0,%sp@(40)
    notw %d0
    aslw #2,%d0
    moveal UTableBase,%a1
    moveal %a1@(0x0,%d0:w),%a1
    moveal %a1@,%a1
    movel %a1@(30),%d0
    jbeq OPENDESKACC_46
    movel %d0,%sp@-
    movel %d0,%sp@-
    _SelectWindow
    _ShowWindow
OPENDESKACC_46:         /* address %sp@(32) */
    lea %sp@(32),%sp
    movel %sp@+,%sp@
    rts

/* CLOSEDESKACC: _CloseDeskAcc. */
trap_CloseDeskAcc:
CLOSEDESKACC:
    movew %sp@(4),%d0
    subaw #30,%sp
    movew %d0,%sp@(24)
    moveal %sp,%a0
    _Close
    lea %sp@(30),%sp
CLOSEDESKACC_14:        /* set %a0 */
    moveal %sp@+,%a0
    addqw #2,%sp
    jmp %a0@
    .short  0x0000	| 4081CA5E

GetPID:                 /* subtract 4 to %sp */
    subql #4,%sp
    movew #143,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(NGETTRAPADDRESS)
    subql #4,%sp
    movew #159,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(NGETTRAPADDRESS)
    movel %sp@+,%d0
    cmpl %sp@+,%d0
    jbeq GetPID_2E
    subql #2,%sp
    moveq #19,%d0
    movew %d0,%sp@-
    _OSDispatch
    movew %sp@+,%d0
    jbra GetPID_30
GetPID_2E:              /* set %d0 */
    moveq #-1,%d0
GetPID_30:              /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081CA92

GetFreeAux:             /* save registers */
    moveml %a3-%a4,%sp@-
    moveal %sp@(12),%a4
    moveal %a4@(6),%a3
    movel %a3,%d0
    jbeq GetFreeAux_1A
    tstw %a3@(4)
    jbne GetFreeAux_1A
    movel %a3,%d0
    jbra GetFreeAux_1C
GetFreeAux_1A:          /* clear %d0 */
    moveq #0,%d0
GetFreeAux_1C:          /* restore registers, return */
    moveml %sp@+,%a3-%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081CAC2

AddAuxRec:              /* entry: stack frame */
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    movel %a4,%sp@-
    jsr %pc@(GetFreeAux)
    tstl %d0
    addql #4,%sp
    jbne AddAuxRec_2E
    movel %fp@(8),%sp@-
    jsr %pc@(NewSCPtr)
    moveal %d0,%a3
    movel %a4,%sp@-
    movel %a3,%sp@-
    jsr %pc@(Enqueue)
    lea %sp@(12),%sp
AddAuxRec_2E:           /* restore registers, return */
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000	| 4081CB08

LinkAuxRec:             /* save registers */
    moveml %a3-%a4,%sp@-
    moveal %sp@(12),%a4
    moveal %sp@(16),%a3
    movew #-1,%a3@(4)
    addqw #1,%a3@(6)
    movel %a4@(8),%a3@(8)
    movel %a3,%a4@(8)
    moveml %sp@+,%a3-%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081CB36

UnLinkAuxRecs:          /* save registers */
    moveml %a3-%a4,%sp@-
    moveal %sp@(12),%a4
    moveal %a4@(8),%a3
    moveq #0,%d0
    movel %d0,%a4@(8)
    jbra UnLinkAuxRecs_1C
UnLinkAuxRecs_14:       /* loop: subq */
    subqw #1,%a3@(6)
    moveal %a3@(8),%a3
UnLinkAuxRecs_1C:       /* set %d0 */
    movel %a3,%d0
    jbne UnLinkAuxRecs_14
    moveml %sp@+,%a3-%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081CB66

InsertMarkRec:          /* save registers */
    moveml %d6-%d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a4
    moveal BNMQHd,%a0
    moveal %a0@(12),%a3
    movew %a4@(12),%d6
    movew %a4@(14),%d7
    jbra InsertMarkRec_1C
InsertMarkRec_1A:       /* loop: movea */
    moveal %a3@,%a3
InsertMarkRec_1C:       /* set %d0 */
    movel %a3,%d0
    jbeq InsertMarkRec_32
    cmpw %a3@(14),%d7
    jbne InsertMarkRec_2C
    cmpw %a3@(12),%d6
    jbeq InsertMarkRec_32
InsertMarkRec_2C:       /* test %a3@(4) */
    tstw %a3@(4)
    jbne InsertMarkRec_1A
InsertMarkRec_32:       /* set %d0 */
    movel %a3,%d0
    jbne InsertMarkRec_46
    moveal BNMQHd,%a0
    pea %a0@(10)
    jsr %pc@(GetFreeAux)
    moveal %d0,%a3
    addql #4,%sp
InsertMarkRec_46:       /* set %d0 */
    movel %a3,%d0
    jbeq InsertMarkRec_5C
    movew %d6,%a3@(12)
    movew %d7,%a3@(14)
    movel %a3,%sp@-
    movel %a4,%sp@-
    jsr %pc@(LinkAuxRec)
    addql #8,%sp
InsertMarkRec_5C:       /* set %d0 */
    movel %a3,%d0
    moveml %sp@+,%d6-%d7/%a3-%a4
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4081CBD4

InsertIconRec:          /* save registers */
    moveml %a3-%a4,%sp@-
    moveal %sp@(12),%a4
    moveal BNMQHd,%a0
    pea %a0@(20)
    jsr %pc@(GetFreeAux)
    moveal %d0,%a3
    movel %a3,%d0
    addql #4,%sp
    jbeq InsertIconRec_2C
    movel %a4@(16),%a3@(12)
    movel %a3,%sp@-
    movel %a4,%sp@-
    jsr %pc@(LinkAuxRec)
    addql #8,%sp
InsertIconRec_2C:       /* set %d0 */
    movel %a3,%d0
    moveml %sp@+,%a3-%a4
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4081CC14

ValidIconRec:           /* save registers */
    moveml %a3-%a4,%sp@-
    moveal %sp@(12),%a4
    jbra ValidIconRec_2C
ValidIconRec_A:         /* loop: movea */
    moveal %a4@,%a3
    tstw %a4@(4)
    jbeq ValidIconRec_2A
    moveal BNMQHd,%a0
    pea %a0@(20)
    movel %a4,%sp@-
    jsr %pc@(Dequeue)
    movel %a4,%sp@-
    jsr %pc@(DisposPtr)
    lea %sp@(12),%sp
ValidIconRec_2A:        /* set %a4 */
    moveal %a3,%a4
ValidIconRec_2C:        /* set %d0 */
    movel %a4,%d0
    jbeq ValidIconRec_36
    tstw %a4@(6)
    jbeq ValidIconRec_A
ValidIconRec_36:        /* set %d0 */
    movel %a4,%d0
    moveml %sp@+,%a3-%a4
    rts
    .short  0x0000	| 4081CC5E

/* NMINIT: Notification Manager start-up. */
NMINIT:
    moveq #52,%d0
    movel %d0,%sp@-
    jsr %pc@(NewSCPtr)
    movel %d0,BNMQHd
    moveal BNMQHd,%a0
    moveb #1,%a0@(50)
    moveq #32,%d0
    movel %d0,%sp@-
    jsr %pc@(NewSHandle)
    moveal BNMQHd,%a0
    movel %d0,%a0@(42)
    addql #8,%sp
    rts
    .short  0x0000, 0x0000, 0x0000	| 4081CC8A

_NMInstall:             /* loop: move */
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    moveq #8,%d0
    cmpw %a3@(4),%d0
    jbeq _NMInstall_14
    movew #-299,%d0
    jbra _NMInstall_36
_NMInstall_14:          /* clear %a3@(6) */
    clrw %a3@(6)
    moveq #0,%d0
    movel %d0,%a3@(8)
    jsr %pc@(GetPID)
    movew %d0,%a3@(12)
    moveal BNMQHd,%a0
    movel %a0,%sp@-
    movel %a3,%sp@-
    jsr %pc@(Enqueue)
    moveq #0,%d0
    addql #8,%sp
_NMInstall_36:          /* set %a3 */
    moveal %sp@+,%a3
    rts
    .short  0x0000, 0x0000, 0x0000	| 4081CCCA

_NMRemove:              /* save registers */
    moveml %d7/%a3,%sp@-
    moveal %sp@(12),%a3
    moveq #8,%d0
    cmpw %a3@(4),%d0
    jbeq _NMRemove_16
    movew #-299,%d0
    jbra _NMRemove_46
_NMRemove_16:           /* set %a0 */
    moveal BNMQHd,%a0
    movel %a0,%sp@-
    movel %a3,%sp@-
    jsr %pc@(Dequeue)
    movew %d0,%d7
    addql #8,%sp
    jbne _NMRemove_44
    moveq #48,%d0
    andw %a3@(6),%d0
    cmpiw #16,%d0
    jbne _NMRemove_3C
    moveal BNMQHd,%a0
    oriw #2,%a0@
_NMRemove_3C:           /* set %sp@- */
    movel %a3,%sp@-
    jsr %pc@(UnLinkAuxRecs)
    addql #4,%sp
_NMRemove_44:           /* set %d0 */
    movew %d7,%d0
_NMRemove_46:           /* restore registers, return */
    moveml %sp@+,%d7/%a3
    rts
    .long   0x00000000	| 4081CD1C

AddrInRange:            /* entry: stack frame */
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(8),%a3
    movel %a3,%sp@-
    jsr %pc@(StripAddress)
    moveal %d0,%a3
    moveq #0,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    jsr %pc@(StripAddress)
    addql #4,%sp
    movel %d0,%d1
    movel %sp@+,%d0
    cmpal %d1,%a3
    jbcs AddrInRange_42
    movel %d0,%sp@-
    movel %fp@(16),%sp@-
    jsr %pc@(StripAddress)
    addql #4,%sp
    movel %d0,%d1
    movel %sp@+,%d0
    cmpl %a3,%d1
    jbcs AddrInRange_42
    moveq #1,%d0
AddrInRange_42:         /* restore registers, return */
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts
    .long   0x00000000	| 4081CD6C

COPYSTRING:             /* save registers */
    moveml %a3-%a4,%sp@-
    moveal %sp@(12),%a4
    moveal %sp@(16),%a3
    moveq #0,%d0
    moveb %a3@,%d0
    addql #1,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    movel %a3,%sp@-
    jsr %pc@(BlockMove)
    lea %sp@(12),%sp
    moveml %sp@+,%a3-%a4
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 4081CD9A

FLUSHAPPLNM:            /* save registers */
    moveml %d7/%a3-%a4,%sp@-
    movel SysZone,%d0
    cmpl ApplZone,%d0
    jbeq FLUSHAPPLNM_4C
    jsr %pc@(disable)
    movel %d0,%d7
    moveal BNMQHd,%a0
    moveal %a0@(2),%a3
    jbra FLUSHAPPLNM_40
FLUSHAPPLNM_1E:         /* loop: movea */
    moveal %a3@,%a4
    movel BufPtr,%sp@-
    movel ApplZone,%sp@-
    movel %a3,%sp@-
    jsr %pc@(AddrInRange)
    tstb %d0
    lea %sp@(12),%sp
    jbeq FLUSHAPPLNM_3E
    movel %a3,%sp@-
    jsr %pc@(NMRemove)
    addql #4,%sp
FLUSHAPPLNM_3E:         /* set %a3 */
    moveal %a4,%a3
FLUSHAPPLNM_40:         /* set %d0 */
    movel %a3,%d0
    jbne FLUSHAPPLNM_1E
    movel %d7,%sp@-
    jsr %pc@(spl)
    addql #4,%sp
FLUSHAPPLNM_4C:         /* restore registers, return */
    moveml %sp@+,%d7/%a3-%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081CDF2

/* NMFILTER: Notification Manager GetNextEvent filter. */
NMFILTER:
    linkw %fp,#-14
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(16),%a4
    moveal %fp@(12),%a3
    moveq #3,%d0
    cmpw %a3@,%d0
    bnes NMFILTER_7A
    movel #255,%d7
    andl %a3@(2),%d7
    cmpib #3,%d7
    beqs NMFILTER_2C
    cmpib #13,%d7
    bnes NMFILTER_7A
NMFILTER_2C:
    movel %a4,%sp@-
    moveq #1,%d0
    movew %d0,%sp@-
    pea %fp@(-14)
    pea %fp@(-12)
    pea %fp@(-8)
    _GetDItem
    moveq #4,%d0
    cmpw %fp@(-14),%d0
    bnes NMFILTER_6A
    movel %fp@(-12),%sp@-
    moveq #10,%d0
    movew %d0,%sp@-
    .short  0xA95D	| 4081CE50 _HiliteControl
    pea %fp@(-8)
    moveq #8,%d0
    movel %d0,%sp@-
    jsr %pc@(Delay)
    movel %fp@(-12),%sp@-
    moveq #0,%d0
    movew %d0,%sp@-
    .short  0xA95D	| 4081CE66 _HiliteControl
    addql #8,%sp
NMFILTER_6A:
    moveal %fp@(8),%a0
    movew #1,%a0@
    moveb #1,%fp@(20)
    bras NMFILTER_90
NMFILTER_7A:
    moveal BNMQHd,%a0
    moveq #2,%d0
    andw %a0@,%d0
    beqs NMFILTER_8C
    moveb #1,%fp@(20)
    bras NMFILTER_90
NMFILTER_8C:
    clrb %fp@(20)
NMFILTER_90:
    moveml %fp@(-26),%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw #12,%sp
    jmp %a0@

/* DEFBUTPROC: default response procedure of a notification. */
DEFBUTPROC:
    linkw %fp,#-32	| 4081CEA0
    movel %a3,%sp@-	| 4081CEA4
    moveal %fp@(10),%a3	| 4081CEA6
    pea %fp@(-32)	| 4081CEAA
    _GetPenState	| 4081CEAE
    moveq #3,%d0	| 4081CEB0
    movew %d0,%sp@-	| 4081CEB2
    movew %d0,%sp@-	| 4081CEB4
    _PenSize	| 4081CEB6
    movel %a3,%sp@-	| 4081CEB8
    movew %fp@(8),%sp@-	| 4081CEBA
    pea %fp@(-14)	| 4081CEBE
    pea %fp@(-12)	| 4081CEC2
    pea %fp@(-8)	| 4081CEC6
    _GetDItem	| 4081CECA
    pea %fp@(-8)	| 4081CECC
    moveq #16,%d0	| 4081CED0
    movew %d0,%sp@-	| 4081CED2
    movew %d0,%sp@-	| 4081CED4
    _FrameRoundRect	| 4081CED6
    pea %fp@(-32)	| 4081CED8
    _SetPenState	| 4081CEDC
    moveal %fp@(-36),%a3	| 4081CEDE
    unlk %fp	| 4081CEE2
    moveal %sp@+,%a0	| 4081CEE4
    addqw #6,%sp	| 4081CEE6
    jmp %a0@	| 4081CEE8
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4081CEEA
FindItem:               /* entry: stack frame */
    linkw %fp,#-256
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    lea %fp@(-256),%a3
    subql #2,%sp
    movel %a4,%sp@-
    _CountMItems
    movew %sp@+,%d7
    jbra FindItem_40
FindItem_1A:            /* set up and call _GetItem (loop) */
    movel %a4,%sp@-
    movew %d7,%sp@-
    movel %a3,%sp@-
    _GetItem
    subql #2,%sp
    movel %fp@(12),%sp@-
    movel %a3,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    moveq #1,%d1
    moveb %d1,%sp@-
    jsr %pc@(EQUALSTRING)
    tstb %sp@+
    jbeq FindItem_3E
    movew %d7,%d0
    jbra FindItem_46
FindItem_3E:            /* subtract 1 to %d7 */
    subqw #1,%d7
FindItem_40:            /* test %d7 */
    tstw %d7
    jbgt FindItem_1A
    moveq #0,%d0
FindItem_46:            /* restore registers, return */
    moveml %fp@(-268),%d7/%a3-%a4
    unlk %fp
    rts

GetAppleMenu:           /* entry: stack frame */
    linkw %fp,#-4
    moveml %a3-%a4,%sp@-
    moveq #0,%d0
    moveal %d0,%a3
    movel MenuList,%fp@(-4)
    jbeq GetAppleMenu_34
    moveal %fp@(-4),%a0
    moveal %a0@,%a4
    movel %a4,%d0
    jbeq GetAppleMenu_34
    tstw %a4@
    jbeq GetAppleMenu_34
    moveal %a4@(6),%a3
    moveal %a3@,%a0
    cmpiw #276,%a0@(14)
    jbeq GetAppleMenu_34
    moveq #0,%d0
    moveal %d0,%a3
GetAppleMenu_34:        /* set %d0 */
    movel %a3,%d0
    moveml %fp@(-12),%a3-%a4
    unlk %fp
    rts

/* CallMBarProc: call the menu bar definition procedure. */
CallMBarProc:
    linkw %fp,#0
    moveml %d5-%d7/%a3-%a4,%sp@-
    moveal MenuList,%a3
    movel %a3,%d0
    jbeq CallMBarProc_1C
    moveal %a3@,%a4
    movel %a4,%d0
    jbeq CallMBarProc_1C
    movew %a4@(4),%d7
    jbra CallMBarProc_20
CallMBarProc_1C:        /* result 0 */
    moveq #0,%d0
    jbra CallMBarProc_74
CallMBarProc_20:        /* set ROMMapInsert */
    movew #-1,ROMMapInsert
    subql #4,%sp
    movel #1296188486,%sp@-
    movew %d7,%sp@-
    _GetResource
    moveal %sp@+,%a3
    movel %a3,%d0
    jbeq CallMBarProc_72
    movel %a3,%sp@-
    jsr %pc@(HGetState)
    movew %d0,%d5
    movel %a3,%sp@-
    jsr %pc@(HLock)
    subql #4,%sp
    moveq #7,%d0
    andw %d7,%d0
    movew %d0,%sp@-
    movew %fp@(10),%sp@-
    movew %fp@(14),%sp@-
    movel %fp@(16),%sp@-
    moveal %a3@,%a0
    jsr %a0@
    movel %sp@+,%d6
    extl %d5
    movel %d5,%sp@-
    movel %a3,%sp@-
    jsr %pc@(HSetState)
    movel %d6,%d0
    lea %sp@(16),%sp
    jbra CallMBarProc_74
CallMBarProc_72:        /* clear %d0 */
    moveq #0,%d0
CallMBarProc_74:        /* restore registers, return */
    moveml %fp@(-20),%d5-%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000	| 4081CFFE

SWAPITEMMARKS:          /* entry: stack frame */
    linkw %fp,#-2
    moveml %d7/%a3,%sp@-
    movew %fp@(12),%d7
    moveal %fp@(14),%a3
    movel %a3,%sp@-
    movew %d7,%sp@-
    pea %fp@(-2)
    _GetItmMark
    movew %fp@(-2),%d0
    cmpw %fp@(10),%d0
    jbne SWAPITEMMARKS_2E
    movel %a3,%sp@-
    movew %d7,%sp@-
    movew %fp@(8),%sp@-
    _SetItmMark
SWAPITEMMARKS_2E:       /* restore registers, return */
    moveml %fp@(-10),%d7/%a3
    unlk %fp
    moveal %sp@+,%a0
    addaw #10,%sp
    jmp %a0@
    .short  0x0000	| 4081D03E

ClearMarks:             /* save registers */
    moveml %d7/%a3,%sp@-
    moveal %sp@(12),%a3
    subql #2,%sp
    movel %a3,%sp@-
    _CountMItems
    movew %sp@+,%d7
    jbra ClearMarks_24
ClearMarks_12:          /* loop: move */
    movel %a3,%sp@-
    movew %d7,%sp@-
    subqw #1,%d7
    moveq #19,%d0
    movew %d0,%sp@-
    moveq #0,%d1
    movew %d1,%sp@-
    jsr %pc@(SWAPITEMMARKS)
ClearMarks_24:          /* test %d7 */
    tstw %d7
    jbgt ClearMarks_12
    moveml %sp@+,%d7/%a3
    rts
    .short  0x0000	| 4081D06E

SWAPDAMARK:             /* entry: stack frame */
    linkw %fp,#-342
    moveml %d5-%d7/%a3-%a4,%sp@-
    jsr %pc@(GetAppleMenu)
    moveal %d0,%a4
    movel %a4,%d0
    jbeq SWAPDAMARK_D8
    moveal %fp@(12),%a0
    movew %a0@(12),%d5
    moveal %fp@(12),%a0
    movew %a0@(14),%d6
    jbge SWAPDAMARK_38
    moveal UTableBase,%a0
    movew %d6,%d0
    notw %d0
    extl %d0
    asll #2,%d0
    movel %a0@(0x0,%d0:l),%d0
    jbra SWAPDAMARK_3A
SWAPDAMARK_38:          /* clear %d0 */
    moveq #0,%d0
SWAPDAMARK_3A:          /* set %a3 */
    moveal %d0,%a3
    clrw %d7
    extl %d5
    moveq #-1,%d0
    cmpl %d5,%d0
    jbeq SWAPDAMARK_92
    movel %a3,%d0
    jbeq SWAPDAMARK_70
    moveal SysZone,%a0
    movel %a0@,%sp@-
    movel SysZone,%sp@-
    moveal %a3@,%a0
    movel %a0@,%sp@-
    jsr %pc@(AddrInRange)
    tstb %d0
    lea %sp@(12),%sp
    jbne SWAPDAMARK_70
    jsr %pc@(GetPID)
    cmpw %d5,%d0
    jbeq SWAPDAMARK_70
    moveq #0,%d0
    moveal %d0,%a3
SWAPDAMARK_70:          /* set %d0 */
    movel %a3,%d0
    jbne SWAPDAMARK_92
    subql #4,%sp
    movew %d5,%sp@-
    pea %fp@(-342)
    moveq #23,%d0
    movew %d0,%sp@-
    _OSDispatch
    pea %fp@(-296)
    movel %a4,%sp@-
    jsr %pc@(FindItem)
    movew %d0,%d7
    lea %sp@(12),%sp
SWAPDAMARK_92:          /* set %d0 */
    movel %a3,%d0
    jbeq SWAPDAMARK_C8
    movew #-1,ROMMapInsert
    subql #4,%sp
    movel #1146246738,%sp@-
    movew %d6,%d0
    notw %d0
    movew %d0,%sp@-
    _GetResource
    pea %fp@(-262)
    pea %fp@(-260)
    pea %fp@(-256)
    _GetResInfo
    pea %fp@(-256)
    movel %a4,%sp@-
    jsr %pc@(FindItem)
    movew %d0,%d7
    addql #8,%sp
SWAPDAMARK_C8:          /* test %d7 */
    tstw %d7
    jbeq SWAPDAMARK_D8
    movel %a4,%sp@-
    movew %d7,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(SWAPITEMMARKS)
SWAPDAMARK_D8:          /* restore registers, return */
    moveml %fp@(-362),%d5-%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081D156

MarkItem:               /* entry: stack frame */
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(8),%a4
    tstw %a4@(14)
    jbeq MarkItem_40
    movel %a4,%sp@-
    jsr %pc@(InsertMarkRec)
    moveal %d0,%a3
    movel %a3,%d0
    addql #4,%sp
    jbeq MarkItem_46
    oriw #1,%a4@(6)
    movel %fp@(12),%sp@-
    jsr %pc@(spl)
    movel %a3,%sp@-
    moveq #0,%d0
    movew %d0,%sp@-
    moveq #19,%d1
    movew %d1,%sp@-
    jsr %pc@(SWAPDAMARK)
    addql #4,%sp
    jbra MarkItem_46
MarkItem_40:            /* from here: oriw #1,%a4@(6) */
    oriw #1,%a4@(6)
MarkItem_46:            /* restore registers, return */
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts

RotateIcon:             /* entry: stack frame */
    linkw %fp,#0
    movel %a3,%sp@-
    moveal %fp@(8),%a3
    tstl %a3@(16)
    jbeq RotateIcon_24
    movel %a3,%sp@-
    jsr %pc@(InsertIconRec)
    tstl %d0
    addql #4,%sp
    jbeq RotateIcon_2A
    oriw #2,%a3@(6)
    jbra RotateIcon_2A
RotateIcon_24:          /* from here: oriw #2,%a3@(6) */
    oriw #2,%a3@(6)
RotateIcon_2A:          /* set %a3 */
    moveal %fp@(-4),%a3
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081D1E2

DoSound:                /* entry: stack frame */
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %a4@(20),%a3
    oriw #8,%a4@(6)
    movel %a3,%d0
    jbeq DoSound_44
    movel %fp@(12),%sp@-
    jsr %pc@(spl)
    cmpal #-1,%a3
    addql #4,%sp
    jbne DoSound_34
    moveq #3,%d0
    movew %d0,%sp@-
    _SysBeep
    jbra DoSound_44
DoSound_34:             /* subtract 2 to %sp */
    subql #2,%sp
    moveq #0,%d0
    movel %d0,%sp@-
    movel %a3,%sp@-
    moveq #0,%d1
    moveb %d1,%sp@-
    _SndPlay
    addql #2,%sp
DoSound_44:             /* restore registers, return */
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts
    .short  0x0000	| 4081D23E

DoDialog:               /* entry: stack frame */
    linkw %fp,#-280
    moveml %d5-%d7/%a3-%a4,%sp@-
    movel %fp@(12),%d5
    moveal %fp@(8),%a0
    tstl %a0@(24)
    jbne DoDialog_24
    moveal %fp@(8),%a0
    oriw #48,%a0@(6)
    jbra DoDialog_1D2
DoDialog_24:            /* set %a0 */
    moveal BNMQHd,%a0
    movew %a0@,%d0
    btst #0,%d0
    jbeq DoDialog_3E
    moveal %fp@(8),%a0
    oriw #128,%a0@(6)
    jbra DoDialog_1D2
DoDialog_3E:            /* set %a0 */
    moveal BNMQHd,%a0
    oriw #1,%a0@
    moveal %fp@(8),%a0
    oriw #144,%a0@(6)
    moveal %fp@(8),%a0
    movel %a0@(24),%sp@-
    pea %fp@(-272)
    jsr %pc@(COPYSTRING)
    movel %d5,%sp@-
    jsr %pc@(spl)
    _InitCursor
    pea %fp@(-276)
    _GetPort
    subql #2,%sp
    _CurResFile
    movew %sp@+,%d6
    moveq #0,%d0
    movew %d0,%sp@-
    _UseResFile
    subql #4,%sp
    moveq #1,%d0
    movew %d0,%sp@-
    moveq #0,%d1
    movel %d1,%sp@-
    moveq #-1,%d0
    movel %d0,%sp@-
    _GetNewDialog
    moveal %sp@+,%a3
    movew %d6,%sp@-
    _UseResFile
    movel %a3,%sp@-
    moveq #2,%d0
    movew %d0,%sp@-
    pea %fp@(-16)
    pea %fp@(-12)
    pea %fp@(-8)
    _GetDItem
    movel %a3,%sp@-
    moveq #2,%d0
    movew %d0,%sp@-
    movew %fp@(-16),%sp@-
    pea %pc@(DEFBUTPROC)
    pea %fp@(-8)
    _SetDItem
    movel %a3,%sp@-
    moveq #3,%d0
    movew %d0,%sp@-
    pea %fp@(-16)
    pea %fp@(-12)
    pea %fp@(-8)
    _GetDItem
    movel %fp@(-12),%sp@-
    pea %fp@(-272)
    _SetIText
    moveal WMgrPort,%a0
    lea %a0@(16),%a0
    movel %a0,%fp@(-280)
    movew %a0@,%d0
    extl %d0
    tstw ROM85
    addql #4,%sp
    jbge DoDialog_F2
    moveq #20,%d1
    jbra DoDialog_F8
DoDialog_F2:            /* set %d1 */
    movew MBarHeight,%d1
    extl %d1
DoDialog_F8:            /* set %d7 */
    movel %d1,%d7
    addl %d0,%d7
    lea %a3@(16),%a4
    movel %a3,%sp@-
    moveal %fp@(-280),%a0
    moveal %fp@(-280),%a1
    movew %a1@(2),%d0
    addw %a0@(6),%d0
    subw %a4@(6),%d0
    movew %a4@(2),%d1
    addw %d0,%d1
    extl %d1
    asrl #1,%d1
    movew %d1,%sp@-
    moveal %fp@(-280),%a0
    movew %a0@(4),%d0
    subw %d7,%d0
    subw %a4@(4),%d0
    movew %a4@,%d1
    addw %d0,%d1
    extl %d1
    asrl #2,%d1
    extl %d7
    addl %d7,%d1
    movew %d1,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    _MoveWindow
    movel %a3,%sp@-
    _ShowWindow
    pea %pc@(NMFILTER)
    pea %fp@(-14)
    _ModalDialog
    jsr %pc@(disable)
    movel %d0,%d5
    moveal BNMQHd,%a0
    moveq #2,%d0
    andw %a0@,%d0
    jbne DoDialog_178
    moveal %fp@(8),%a0
    oriw #32,%a0@(6)
    moveal %fp@(8),%a0
    andiw #-129,%a0@(6)
    jbra DoDialog_180
DoDialog_178:           /* set %a0 */
    moveal BNMQHd,%a0
    andiw #-3,%a0@
DoDialog_180:           /* set %a0 */
    moveal BNMQHd,%a0
    movel %a0@(2),%fp@(8)
    jbra DoDialog_1B2
DoDialog_18C:           /* loop: movea */
    moveal %fp@(8),%a0
    movew #144,%d0
    andw %a0@(6),%d0
    cmpiw #128,%d0
    jbne DoDialog_1AA
    moveal %fp@(8),%a0
    andiw #-129,%a0@(6)
    jbra DoDialog_1B8
DoDialog_1AA:           /* set %a0 */
    moveal %fp@(8),%a0
    movel %a0@,%fp@(8)
DoDialog_1B2:           /* test %fp@(8) */
    tstl %fp@(8)
    jbne DoDialog_18C
DoDialog_1B8:           /* set up and call _DisposDialog */
    movel %d5,%sp@-
    jsr %pc@(spl)
    movel %a3,%sp@-
    _DisposDialog
    movel %fp@(-276),%sp@-
    _SetPort
    moveal BNMQHd,%a0
    andiw #-2,%a0@
    addql #4,%sp
DoDialog_1D2:           /* restore registers, return */
    moveml %fp@(-300),%d5-%d7/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000	| 4081D41C

DoRespProc:             /* entry: stack frame */
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %a4@(28),%a3
    oriw #64,%a4@(6)
    movel %a3,%d0
    jbeq DoRespProc_3A
    cmpal #-1,%a3
    jbne DoRespProc_2C
    movel %a4,%sp@-
    jsr %pc@(NMRemove)
    addql #4,%sp
    jbra DoRespProc_3A
DoRespProc_2C:          /* set %sp@- */
    movel %fp@(12),%sp@-
    jsr %pc@(spl)
    movel %a4,%sp@-
    jsr %a3@
    addql #4,%sp
DoRespProc_3A:          /* restore registers, return */
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4081D464

/* NMGNEFILTER: GetNextEvent filter installed in GNEFilter. */
NMGNEFILTER:
    moveml %d7/%a3-%a4,%sp@-
    moveal BNMQHd,%a0
    moveal %a0@(30),%a3
    moveq #3,%d0
    andb AlarmState,%d0
    jbne NMGNEFILTER_8C
    movel %a3,%d0
    jbne NMGNEFILTER_AA
    movew #-1,ROMMapInsert
    subql #4,%sp
    movel #1397310286,%sp@-
    movew #-16385,%sp@-
    _GetResource
    moveal %sp@+,%a4
    movel %a4,%d0
    jbeq NMGNEFILTER_AA
    movel %a4,%sp@-
    jsr %pc@(GetHandleSize)
    movel %d0,%d7
    moveq #36,%d0
    movel %d0,%sp@-
    jsr %pc@(NewSCPtr)
    moveal %d0,%a3
    movel %a3,%d0
    addql #8,%sp
    jbeq NMGNEFILTER_86
    movel %d7,%sp@-
    jsr %pc@(NewSHandle)
    movel %d0,%a3@(16)
    addql #4,%sp
    jbeq NMGNEFILTER_86
    movel %d7,%sp@-
    moveal %a3@(16),%a0
    movel %a0@,%sp@-
    movel %a4@,%sp@-
    jsr %pc@(BlockMove)
    movew #8,%a3@(4)
    moveq #-1,%d0
    movel %d0,%a3@(20)
    movel %a3,%sp@-
    jsr %pc@(NMInstall)
    moveal BNMQHd,%a0
    movel %a3,%a0@(30)
    lea %sp@(16),%sp
NMGNEFILTER_86:         /* set up and call _ReleaseResource */
    movel %a4,%sp@-
    _ReleaseResource
    jbra NMGNEFILTER_AA
NMGNEFILTER_8C:         /* set %d0 */
    movel %a3,%d0
    jbeq NMGNEFILTER_AA
    movel %a3,%sp@-
    jsr %pc@(NMRemove)
    movel %a3@(16),%sp@-
    jsr %pc@(DisposHandle)
    moveal BNMQHd,%a0
    moveq #0,%d0
    movel %d0,%a0@(30)
    addql #8,%sp
NMGNEFILTER_AA:         /* restore registers, return */
    moveml %sp@+,%d7/%a3-%a4
    rts

/* NMTASK: Notification Manager task: rotate icons, play sounds, show the alerts. */
NMTASK:
    linkw %fp,#-4
    moveml %d4-%d7/%a3-%a4,%sp@-
    jsr %pc@(disable)
    movel %d0,%d7
    moveal BNMQHd,%a0
    moveal %a0@(2),%a4
    jbra NMTASK_1A
NMTASK_18:              /* loop: movea */
    moveal %a4@,%a4
NMTASK_1A:              /* set %d0 */
    movel %a4,%d0
    jbeq NMTASK_28
    movew #128,%d0
    andw %a4@(6),%d0
    jbne NMTASK_18
NMTASK_28:              /* set %d0 */
    movel %a4,%d0
    jbeq NMTASK_90
    movew %a4@(6),%d6
    moveq #1,%d0
    andw %d6,%d0
    jbne NMTASK_42
    movel %d7,%sp@-
    movel %a4,%sp@-
    jsr %pc@(MarkItem)
    addql #8,%sp
    jbra NMTASK_90
NMTASK_42:              /* set %d0 */
    moveq #2,%d0
    andw %d6,%d0
    jbne NMTASK_54
    movel %d7,%sp@-
    movel %a4,%sp@-
    jsr %pc@(RotateIcon)
    addql #8,%sp
    jbra NMTASK_90
NMTASK_54:              /* set %d0 */
    moveq #8,%d0
    andw %d6,%d0
    jbne NMTASK_66
    movel %d7,%sp@-
    movel %a4,%sp@-
    jsr %pc@(DoSound)
    addql #8,%sp
    jbra NMTASK_90
NMTASK_66:              /* set %d0 */
    moveq #16,%d0
    andw %d6,%d0
    jbne NMTASK_78
    movel %d7,%sp@-
    movel %a4,%sp@-
    jsr %pc@(DoDialog)
    addql #8,%sp
    jbra NMTASK_90
NMTASK_78:              /* set %d0 */
    moveq #64,%d0
    andw %d6,%d0
    jbne NMTASK_8A
    movel %d7,%sp@-
    movel %a4,%sp@-
    jsr %pc@(DoRespProc)
    addql #8,%sp
    jbra NMTASK_90
NMTASK_8A:              /* from here: oriw #-32640,%a4@(6) */
    oriw #-32640,%a4@(6)
NMTASK_90:              /* set %sp@- */
    movel %d7,%sp@-
    jsr %pc@(spl)
    moveal BNMQHd,%a0
    pea %a0@(10)
    moveq #16,%d0
    movel %d0,%sp@-
    jsr %pc@(AddAuxRec)
    moveal BNMQHd,%a0
    pea %a0@(20)
    moveq #16,%d0
    movel %d0,%sp@-
    jsr %pc@(AddAuxRec)
    jsr %pc@(GetAppleMenu)
    moveal %d0,%a4
    moveal BNMQHd,%a0
    moveal %a0@(12),%a3
    movel %a4,%d0
    lea %sp@(20),%sp
    jbeq NMTASK_138
    moveal BNMQHd,%a0
    cmpal %a0@(34),%a4
    jbeq NMTASK_138
    movel %a4,%sp@-
    jsr %pc@(ClearMarks)
    addql #4,%sp
    jbra NMTASK_138
NMTASK_E0:              /* loop: move */
    movel %a3@,%fp@(-4)
    tstw %a3@(4)
    jbeq NMTASK_134
    tstw %a3@(6)
    jbne NMTASK_118
    movel %a3,%sp@-
    moveq #19,%d0
    movew %d0,%sp@-
    moveq #0,%d1
    movew %d1,%sp@-
    jsr %pc@(SWAPDAMARK)
    moveal BNMQHd,%a0
    pea %a0@(10)
    movel %a3,%sp@-
    jsr %pc@(Dequeue)
    movel %a3,%sp@-
    jsr %pc@(DisposPtr)
    lea %sp@(12),%sp
    jbra NMTASK_134
NMTASK_118:             /* set %d0 */
    movel %a4,%d0
    jbeq NMTASK_134
    moveal BNMQHd,%a0
    cmpal %a0@(34),%a4
    jbeq NMTASK_134
    movel %a3,%sp@-
    moveq #0,%d0
    movew %d0,%sp@-
    moveq #19,%d1
    movew %d1,%sp@-
    jsr %pc@(SWAPDAMARK)
NMTASK_134:             /* set %a3 */
    moveal %fp@(-4),%a3
NMTASK_138:             /* set %d0 */
    movel %a3,%d0
    jbne NMTASK_E0
    moveal BNMQHd,%a0
    movel %a4,%a0@(34)
    movel Ticks,%d4
    moveal BNMQHd,%a0
    movel %d4,%d5
    subl %a0@(46),%d5
    moveq #1,%d0
    cmpl %d5,%d0
    jbgt NMTASK_1EE
    moveal BNMQHd,%a0
    moveal %a0@(38),%a3
    moveal BNMQHd,%a0
    tstb %a0@(50)
    jbeq NMTASK_1BA
    moveq #60,%d0
    cmpl %d5,%d0
    jbgt NMTASK_1EE
    movel %a3,%d0
    jbeq NMTASK_17A
    movel %a3@,%d0
    jbra NMTASK_182
NMTASK_17A:             /* set %a0 */
    moveal BNMQHd,%a0
    movel %a0@(22),%d0
NMTASK_182:             /* set %sp@- */
    movel %d0,%sp@-
    jsr %pc@(ValidIconRec)
    moveal %d0,%a4
    cmpal %a4,%a3
    addql #4,%sp
    jbeq NMTASK_1EE
    moveal %a4,%a3
    moveal BNMQHd,%a0
    movel %a3,%a0@(38)
    movel %a3,%d0
    jbeq NMTASK_1BA
    moveq #32,%d0
    movel %d0,%sp@-
    moveal BNMQHd,%a0
    moveal %a0@(42),%a0
    movel %a0@,%sp@-
    moveal %a3@(12),%a0
    movel %a0@,%sp@-
    jsr %pc@(BlockMove)
    lea %sp@(12),%sp
NMTASK_1BA:             /* set %a0 */
    moveal BNMQHd,%a0
    movel %d4,%a0@(46)
    movel %a3,%d0
    jbeq NMTASK_1D0
    moveal BNMQHd,%a0
    moveal %a0@(42),%a0
    jbra NMTASK_1D4
NMTASK_1D0:             /* set %a0 */
    moveaw #0,%a0
NMTASK_1D4:             /* set %sp@- */
    movel %a0,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #13,%d1
    movel %d1,%sp@-
    jsr %pc@(CallMBarProc)
    moveal BNMQHd,%a0
    moveb %d0,%a0@(50)
    lea %sp@(12),%sp
NMTASK_1EE:             /* restore registers, return */
    moveml %fp@(-28),%d4-%d7/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000	| 4081D718

trap_NMInstall:
__NMINSTALL:            /* set %sp@- */
    movel %a0,%sp@-
    jbsr _NMInstall
    addql #4,%sp
    rts
    .short  0x0000, 0x0000, 0x0000	| 4081D72A

trap_NMRemove:
__NMREMOVE:             /* set %sp@- */
    movel %a0,%sp@-
    jbsr _NMRemove
    addql #4,%sp
    rts
    .short  0x0000, 0x0000, 0x0000	| 4081D73A
NMInstall:              /* set up and call _NMInstall */
    moveal %sp@(4),%a0
    _NMInstall
    rts
    .long   0x00000000, 0x00000000	| 4081D748

NMRemove:               /* set up and call _NMRemove */
    moveal %sp@(4),%a0
    _NMRemove
    rts
    .long   0x00000000, 0x00000000	| 4081D758
NewSPtr:                /* (data) */
    movel %sp@(4),%d0
    .short  0xA51E	| 4081D764 _NewPtr (flags 0x0500)
    movew %d0,MemErr
    movel %a0,%d0
    rts
    .short  0x0000	| 4081D76E

NewCPtr:                /* set %d0 */
    movel %sp@(4),%d0
    .short  0xA31E	| 4081D774 _NewPtr (flags 0x0300)
    movew %d0,MemErr
    movel %a0,%d0
    rts
    .short  0x0000	| 4081D77E

NewSCPtr:               /* set %d0 */
    movel %sp@(4),%d0
    .short  0xA71E	| 4081D784 _NewPtr (flags 0x0700)
    movew %d0,MemErr
    movel %a0,%d0
    rts
    .short  0x0000	| 4081D78E

NewSHandle:             /* set %d0 */
    movel %sp@(4),%d0
    .short  0xA522	| 4081D794 _NewHandle (flags 0x0500)
    movew %d0,MemErr
    movel %a0,%d0
    rts
    .short  0x0000	| 4081D79E

NewCHandle:             /* set %d0 */
    movel %sp@(4),%d0
    .short  0xA322	| 4081D7A4 _NewHandle (flags 0x0300)
    movew %d0,MemErr
    movel %a0,%d0
    rts
    .short  0x0000	| 4081D7AE

NewSCHandle:            /* set %d0 */
    movel %sp@(4),%d0
    .short  0xA722	| 4081D7B4 _NewHandle (flags 0x0700)
    movew %d0,MemErr
    movel %a0,%d0
    rts
    .short  0x0000	| 4081D7BE

EQUALSTRING:            /* entry: stack frame */
    linkw %fp,#0
    moveal %fp@(16),%a0
    moveal %fp@(12),%a1
    moveq #0,%d0
    moveb %a0@+,%d0
    swap %d0
    moveb %a1@+,%d0
    tstb %fp@(8)
    jbeq EQUALSTRING_28
    tstb %fp@(10)
    jbeq EQUALSTRING_24
    .short  0xA43C	| 4081D7E0 _CmpString (flags 0x0400)
    jbra EQUALSTRING_34
EQUALSTRING_24:         /* _CmpString */
    _CmpString
    jbra EQUALSTRING_34
EQUALSTRING_28:         /* test %fp@(10) */
    tstb %fp@(10)
    jbeq EQUALSTRING_32
    .short  0xA63C	| 4081D7EE _CmpString (flags 0x0600)
    jbra EQUALSTRING_34
EQUALSTRING_32:         /* (_CmpString (flags 0x0200)) */
    .short  0xA23C	| 4081D7F2 _CmpString (flags 0x0200)
EQUALSTRING_34:         /* from here: eorib #1,%d0 */
    eorib #1,%d0
    moveb %d0,%fp@(20)
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(12),%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081D806

NGETTRAPADDRESS:        /* set %a1 */
    moveal %sp@+,%a1
    moveb %sp@+,%d1
    movew %sp@+,%d0
    movel %a1,%sp@-
    tstb %d1
    jbeq NGETTRAPADDRESS_10
    .short  0xA746	| 4081D81C _GetTrapAddress (flags 0x0700)
    jbra NGETTRAPADDRESS_12
NGETTRAPADDRESS_10:     /* (_GetTrapAddress (flags 0x0300)) */
    .short  0xA346	| 4081D820 _GetTrapAddress (flags 0x0300)
NGETTRAPADDRESS_12:     /* set %sp@(4) */
    movel %a0,%sp@(4)
    rts
    .long   0x00000000, 0x00000000	| 4081D828

DisposPtr:              /* set up and call _DisposPtr */
    moveal %sp@(4),%a0
    _DisposPtr
    movew %d0,MemErr
    rts
    .long   0x00000000	| 4081D83C

DisposHandle:           /* set up and call _DisposHandle */
    moveal %sp@(4),%a0
    _DisposHandle
    movew %d0,MemErr
    rts
    .long   0x00000000	| 4081D84C
HLock:                  /* set up and call _HLock */
    moveal %sp@(4),%a0
    _HLock
    movew %d0,MemErr
    rts
    .long   0x00000000	| 4081D85C
HUnlock:                /* (data) */
    moveal %sp@(4),%a0
    _HUnlock
    movew %d0,MemErr
    rts
    .short  0x0000, 0x0000	| orib #0,%d0

SetHandleSize:          /* set up and call _SetHandleSize */
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
    _SetHandleSize
    movew %d0,MemErr
    rts

GetHandleSize:          /* set up and call _GetHandleSize */
    moveal %sp@(4),%a0
    _GetHandleSize
    rts
    .long   0x00000000, 0x00000000	| 4081D888

BlockMove:              /* set up and call _BlockMove */
    moveal %sp@(4),%a0
    moveal %sp@(8),%a1
    movel %sp@(12),%d0
    _BlockMove
    movew %d0,MemErr
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4081D8A4
HGetState:              /* set up and call _HGetState */
    moveal %sp@(4),%a0
    _HGetState
    rts
    .long   0x00000000, 0x00000000	| 4081D8B8

HSetState:              /* set up and call _HSetState */
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
    _HSetState
    movew %d0,MemErr
    rts

StripAddress:           /* set up and call _StripAddress */
    movel %sp@(4),%d0
    _StripAddress
    rts
    .long   0x00000000, 0x00000000	| 4081D8D8

Enqueue:                /* set up and call _Enqueue */
    moveal %sp@(4),%a0
    moveal %sp@(8),%a1
    _Enqueue
    rts
    .long   0x00000000	| 4081D8EC

Dequeue:                /* set up and call _Dequeue */
    moveal %sp@(4),%a0
    moveal %sp@(8),%a1
    _Dequeue
    rts
    .long   0x00000000	| 4081D8FC
Delay:                  /* (data) */
    moveal %sp@(4),%a0
    _Delay
    movel %d0,%sp@(8)
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
