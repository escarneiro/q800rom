/*
 toolbox/controlmgr.s - Control Manager
 From CMGR (0x40815D50). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the Control Manager chapter of Inside Macintosh, not taken from Apple. Routine headers name the trap each routine implements, labels inside are commented mechanically from the instruction that follows.
*/

/* NEWCONTROL: _NewControl: create a control (CDEF from its procID), link it to the window, draw it if visible. */
trap_NewControl:
CMGR:
NEWCONTROL:
    linkw %fp,#0
    moveml %d1/%a2-%a4,%sp@-
    lea %fp@(34),%a4
    moveq #41,%d0
    moveq #0,%d1
    moveal %fp@(22),%a0
    moveb %a0@,%d1
    addl %d1,%d0
    .short  0xA122	| 40815D68 _NewHandle (flags 0x0100)
    moveal %a0,%a3
    movel %a0,%a4@
    moveal %a3@,%a2
    tstb MMU32Bit
    jbeq CMGR_34
    sf %a2@(16)
    movel %a3,%sp@-
    movel #-1,%sp@-
    _SetCtlColor
CMGR_34:                /* set %a1 */
    moveal %a4@-,%a1
    movel %a1,%a2@(4)
    movel %a1@(140),%a2@
    movel %a3,%a1@(140)
    lea %a2@(8),%a1
    moveal %a4@-,%a0
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    clrb %a2@(16)
    movel %a3,%sp@-
    movel %a4@-,%sp@-
    _SetCTitle
    moveal %a3@,%a2
    lea %a2@(16),%a0
    subqw #2,%a4
    tstb %a4@
    sne %a0@+
    clrb %a0@+
    movew %a4@-,%a0@+
    movew %a4@-,%a0@+
    movew %a4@-,%a0@+
    movew %a4@-,%d0
    lsrw #4,%d0
CMGR_6E:                /* loop: subq */
    subqw #4,%sp
    movel #1128547654,%sp@-
    movew %d0,%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    moveq #0,%d0
    moveal %a3@,%a0
    lea %a0@(24),%a0
    movel %sp@+,%a0@
    jbeq CMGR_6E
    movew %a4@,%d0
    andiw #15,%d0
    tstb MMU32Bit
    jbeq CMGR_B6
    movel %a0,%sp@-
    movel %d0,%sp@-
    subqw #6,%sp
    movel %a3,%sp@-
    pea %sp@(6)
    _GetAuxCtl
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movel %sp@+,%d0
    moveb %d0,%a0@(14)
    moveal %sp@+,%a0
    jbra CMGR_B8
CMGR_B6:                /* set %a0@ */
    moveb %d0,%a0@
CMGR_B8:                /* add 4 to %a0 */
    addqw #4,%a0
    clrl %a0@+
    clrl %a0@+
    movel %a4@-,%a0@+
    moveq #3,%d0
    jbsr thunk_FUN_40816218
    tstb %fp@(20)
    jbeq CMGR_CE
    moveq #0,%d1
    jbsr NEWCONTROL_DC
CMGR_CE:                /* restore registers, return */
    moveml %sp@+,%d1/%a2-%a4
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(26),%sp
    jmp %a0@

NEWCONTROL_DC:          /* loop: moveq */
    moveq #0,%d0
    moveal %a3@,%a0
    tstb %a0@(16)
    jbeq CMGR_132

thunk_FUN_40816218:     /* call DRAGCONTROL_AC (loop) */
    jbsr DRAGCONTROL_AC
    clrl %sp@-	| 40815E3A
    clrw %sp@-
    movel %a3,%sp@-
    movew %d0,%sp@-
    movel %d1,%sp@-
    subqw #2,%sp
    movel %a3,%sp@-
    .short  0xA809	| _GetCVariant
    movew %sp@+,%sp@(10)
    moveal %a3@,%a0
    movel %a0@(24),%d0
    _StripAddress
    moveal %d0,%a0
    tstl %a0@
    jbne CMGR_120
    movel %a0,%sp@-
    movew #-1,ROMMapInsert
    _LoadResource
    tstl %a0@
    jbne CMGR_120
    movew #88,%d0
    _SysError
CMGR_120:               /* _HLock */
    _HLock
    moveal %a0@,%a0
    jsr %a0@
    moveal %a3@,%a0
    moveal %a0@(24),%a0
    _HUnlock
    movel %sp@+,%d0
CMGR_130:               /* _SetPort (loop) */
    _SetPort
CMGR_132:               /* return */
    rts

/* GETCVARIANT: _GetCVariant: the variant of the control's definition procedure. */
trap_GetCVariant:
GETCVARIANT:
    moveal %sp@(4),%a0
    tstb MMU32Bit
    jbeq GETCVARIANT_22
    subqw #6,%sp
    movel %a0,%sp@-
    pea %sp@(6)
    _GetAuxCtl
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    clrw %d0
    moveb %a0@(14),%d0
    jbra GETCVARIANT_2C
GETCVARIANT_22:         /* set %a0 */
    moveal %a0@,%a0
    moveb %a0@(24),%d0
    andiw #15,%d0
GETCVARIANT_2C:         /* set %sp@(8) */
    movew %d0,%sp@(8)
    moveal %sp@+,%a0
    addqw #4,%sp
    jmp %a0@

thunk_FUN_40816218_40815EBA:  /* call DRAGCONTROL_AC (loop) */
    jbsr DRAGCONTROL_AC
    moveml %a1-%a4,%sp@-
    _NewRgn
    moveal %sp@,%a4
    tstb MMU32Bit
    jbeq GETCVARIANT_52
    moveq #10,%d0
    movel %a4,%d1
    jbsr thunk_FUN_40816218
    bras GETCVARIANT_52_C
GETCVARIANT_52:         /* set %d0 */
    moveq #2,%d0
    movel %a4,%d1
    bclr #31,%d1
    jbsr thunk_FUN_40816218
GETCVARIANT_52_C:
    _EraseRgn
    movel %a4,%sp@-
    _InvalRgn
    movel %a4,%sp@-
    _DisposRgn
    moveal %a3@,%a0
    clrb %a0@(16)
    moveml %sp@+,%a2-%a4
    jbra CMGR_130

/* DISPOSECONTROL: _DisposeControl: erase, unlink and free a control. */
trap_DisposControl:
DISPOSECONTROL:
    moveml %a2-%a3,%sp@-
    moveal %sp@(12),%a3
    jbsr thunk_FUN_40816218_40815EBA
    movel %a3,%sp@-	| 40815F02
    clrl %sp@-	| 40815F04
    clrb %sp@-	| 40815F06
    clrl %sp@-	| 40815F08
    pea %sp@(6)	| 40815F0A
    _GetAuxCtl	| 40815F0E
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movel %a0@(8),%sp@-
    tstb MMU32Bit
    jbeq DISPOSECONTROL_5C
    lea ghost_AuxCtlHead,%a1
DISPOSECONTROL_2C:      /* loop: movea */
    moveal %a1@,%a2
    moveal %a2@,%a0
    cmpal %a0@(4),%a3
    jbeq DISPOSECONTROL_3A
    lea %a0@,%a1
    jbra DISPOSECONTROL_2C
DISPOSECONTROL_3A:      /* set %a1@ */
    movel %a0@,%a1@
    moveal %a2,%a1
    moveal %a1@,%a1
    movel %a1@(8),%d0
    cmpl %sp@+,%d0
    jbeq DISPOSECONTROL_54
    moveal %d0,%a0
    _HGetState
    btst #5,%d0
    jbne DISPOSECONTROL_54
    _DisposHandle
DISPOSECONTROL_54:      /* set up and call _DisposHandle */
    moveal %a2,%a0
    _DisposHandle
    addqw #4,%sp
    jbra DISPOSECONTROL_5E
DISPOSECONTROL_5C:      /* _SetCtlColor */
    _SetCtlColor
DISPOSECONTROL_5E:      /* set %a0 */
    moveal %a3,%a0
    moveal %a3@,%a1
    moveal %a1@(4),%a1
    lea %a1@(140),%a1
    jbsr DRAWCONTROLS_60
    moveq #4,%d0
    jbsr thunk_FUN_40816218
    moveal %a3,%a0
    _DisposHandle
    moveml %sp@+,%a2-%a3
    movel %sp@+,%sp@
    rts

/* KILLCONTROLS: _KillControls: dispose of all of a window's controls. */
trap_KillControls:
KILLCONTROLS:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
KILLCONTROLS_6:         /* set up and call _DisposControl (loop) */
    movel %a3@(140),%d0
    jbeq SHOWCONTROL_18
    movel %d0,%sp@-
    _DisposControl
    jbra KILLCONTROLS_6

/* DRAWONECONTROL: _Draw1Control: draw one control. */
trap_Draw1Control:
DRAWONECONTROL:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    moveal %a3@,%a0
    tstb %a0@(16)
    jbeq SHOWCONTROL_18
    jbra SHOWCONTROL_12

/* SHOWCONTROL: _ShowControl: make a control visible and draw it. */
trap_ShowControl:
SHOWCONTROL:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    moveal %a3@,%a0
    tstb %a0@(16)
    jbne SHOWCONTROL_18
    st %a0@(16)
SHOWCONTROL_12:         /* clear %d1 */
    moveq #0,%d1
    jbsr NEWCONTROL_DC
SHOWCONTROL_18:         /* loop: movea */
    moveal %sp@+,%a3
    movel %sp@+,%sp@
    rts

/* HIDECONTROL: _HideControl: make it invisible and erase it. */
trap_HideControl:
HIDECONTROL:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    moveal %a3@,%a0
    tstb %a0@(16)
    jbeq SHOWCONTROL_18
    jbsr thunk_FUN_40816218_40815EBA
    bras SHOWCONTROL_18

/* MOVECONTROL: _MoveControl: move it to (h, v). */
trap_MoveControl:
MOVECONTROL:
    moveml %d3/%a3,%sp@-
    moveal %sp@(16),%a3
    moveal %a3@,%a0
    moveb %a0@(16),%d3
    movel %a3,%sp@-
    _HideControl
    moveal %a3@,%a0
    addqw #8,%a0
    movew %sp@(12),%d0
    subw %a0@,%d0
    movew %sp@(14),%d1
    subw %a0@(2),%d1
    movel %a0,%sp@-
    movew %d1,%sp@-
    movew %d0,%sp@-
    _OffsetRect
MOVECONTROL_2C:         /* set up and call _ShowControl (loop) */
    tstb %d3
    jbeq MOVECONTROL_34
    movel %a3,%sp@-
    _ShowControl
MOVECONTROL_34:         /* restore registers */
    moveml %sp@+,%d3/%a3

MOVECONTROL_38:         /* loop: movea */
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* GETCREFCON: _GetCRefCon. */
trap_GetCRefCon:
GETCREFCON:
    moveq #36,%d1
GETCREFCON_2:           /* loop: movea */
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    moveal %a1@,%a1
    movel %a1@(0x0,%d1:w),%sp@
    jmp %a0@

/* SETCREFCON: _SetCRefCon. */
trap_SetCRefCon:
SETCREFCON:
    moveq #36,%d1
SETCREFCON_2:           /* loop: movea */
    moveal %sp@+,%a0
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %a1@,%a1
    movel %d0,%a1@(0x0,%d1:w)
    jmp %a0@

/* GETCTLACTION: _GetCtlAction. */
trap_GetCtlAction:
GETCTLACTION:
    moveq #32,%d1
    jbra GETCREFCON_2

/* SETCTLACTION: _SetCtlAction. */
trap_SetCtlAction:
SETCTLACTION:
    moveq #32,%d1
    jbra SETCREFCON_2

/* SIZECONTROL: _SizeControl. */
trap_SizeControl:
SIZECONTROL:
    moveml %d3/%a3,%sp@-
    moveal %sp@(16),%a3
    moveal %a3@,%a0
    moveb %a0@(16),%d3
    movel %a3,%sp@-
    _HideControl
    movew %sp@(12),%d0
    movew %sp@(14),%d1
    moveal %a3@,%a0
    addqw #8,%a0
    addw %a0@+,%d0
    addw %a0@+,%d1
    movew %d0,%a0@+
    movew %d1,%a0@+
    jbra MOVECONTROL_2C

/* HILITECONTROL: _HiliteControl: highlight state (part, 0, 255 inactive). */
trap_HiliteControl:
HILITECONTROL:
    movel %a3,%sp@-
    moveal %sp@(10),%a3
    moveal %a3@,%a0
    moveq #0,%d1
    moveq #0,%d0
    moveb %sp@(9),%d1
    moveb %a0@(17),%d0
    cmpb %d0,%d1
    jbeq HILITECONTROL_24
    moveb %d1,%a0@(17)
    jbne HILITECONTROL_20
    movew %d0,%d1
HILITECONTROL_20:       /* call NEWCONTROL_DC */
    jbsr NEWCONTROL_DC
HILITECONTROL_24:       /* set %a3 */
    moveal %sp@+,%a3
HILITECONTROL_26:       /* loop: movea */
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@

/* GETCTITLE: _GetCTitle. */
trap_GetCTitle:
GETCTITLE:
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    movel %d0,%sp@-
    moveal %a0@,%a0
    lea %a0@(40),%a0
    moveq #0,%d0
    moveb %a0@,%d0
    addql #1,%d0
    _BlockMove
    rts

/* SETCTITLE: _SetCTitle: set the title and redraw. */
trap_SetCTitle:
SETCTITLE:
    moveml %d3/%a3-%a4,%sp@-
    moveal %sp@(20),%a3
    moveal %a3@,%a0
    moveb %a0@(16),%d3
    movel %a3,%sp@-
    _HideControl
    moveal %sp@(16),%a4
    moveq #0,%d0
    moveb %a4@,%d0
    movel %d0,%sp@-
    addiw #41,%d0
    moveal %a3,%a0
    _SetHandleSize
    movel %sp@+,%d0
    moveal %a4,%a0
    moveal %a3@,%a1
    lea %a1@(40),%a1
    addqw #1,%d0
    _BlockMove
    tstb %d3
    jbeq SETCTITLE_3A
    movel %a3,%sp@-
    _ShowControl
SETCTITLE_3A:           /* restore registers */
    moveml %sp@+,%d3/%a3-%a4
    jbra MOVECONTROL_38

/* GETCTLVALUE: _GetCtlValue. */
trap_GetCtlValue:
GETCTLVALUE:
    moveq #18,%d0
GETCTLVALUE_2:          /* loop: movea */
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movew %a0@(0x0,%d0:w),%sp@
    jmp %a1@

/* GETCTLMIN: _GetCtlMin. */
trap_GetMinCtl:
GETCTLMIN:
    moveq #20,%d0
    jbra GETCTLVALUE_2

/* GETCTLMAX: _GetCtlMax. */
trap_GetMaxCtl:
GETCTLMAX:
    moveq #22,%d0
    jbra GETCTLVALUE_2

/* SETCTLVALUE: _SetCtlValue: pinned between min and max, redraw. */
trap_SetCtlValue:
SETCTLVALUE:
    moveq #18,%d0
SETCTLVALUE_2:          /* loop: move */
    movel %a3,%sp@-
    moveal %sp@(10),%a3
    movew %sp@(8),%d1
    moveal %a3@,%a0
    cmpw %a0@(0x0,%d0:w),%d1
    jbeq SETCTLVALUE_3C
    movew %d1,%a0@(0x0,%d0:w)
    movew %a0@(18),%d1
    cmpw %a0@(20),%d1
    jbge SETCTLVALUE_26
    movew %a0@(20),%d1
SETCTLVALUE_26:         /* test %a0@(22),%d1 */
    cmpw %a0@(22),%d1
    jble SETCTLVALUE_30
    movew %a0@(22),%d1
SETCTLVALUE_30:         /* set %a0@(18) */
    movew %d1,%a0@(18)
    movew #129,%d1
    jbsr NEWCONTROL_DC
SETCTLVALUE_3C:         /* set %a3 */
    moveal %sp@+,%a3
    jbra HILITECONTROL_26

/* SETCTLMIN: _SetCtlMin. */
trap_SetMinCtl:
SETCTLMIN:
    moveq #20,%d0
    jbra SETCTLVALUE_2

/* SETCTLMAX: _SetCtlMax. */
trap_SetMaxCtl:
SETCTLMAX:
    moveq #22,%d0
    jbra SETCTLVALUE_2

/* TESTCONTROL: _TestControl: which part of the control is at the point (CDEF testCntl). */
trap_TestControl:
TESTCONTROL:
    movel %a3,%sp@-
    moveal %sp@(12),%a3
    moveal %a3@,%a0
    clrw %sp@(16)
    moveb %a0@(16),%d1
    jbeq TESTCONTROL_28
    cmpib #0xff,%a0@(17)
    jbeq TESTCONTROL_28
    movel %sp@(8),%d1
    moveq #1,%d0
    jbsr thunk_FUN_40816218
    movew %d0,%sp@(16)	| 40816162
TESTCONTROL_28:         /* set %a3 */
    moveal %sp@+,%a3
    jbra MOVECONTROL_38

/* DRAGCONTROL: _DragControl: drag the control's outline. */
trap_DragControl:
DRAGCONTROL:
    clrw DragFlag
DRAGCONTROL_4:
    linkw %fp,#0
    moveml %d3-%d4/%a3-%a4,%sp@-
    moveml %fp@(14),%d3-%d4/%a3
    jbsr DRAGCONTROL_AC
    movew DragFlag,%d1	| 40816182
    moveq #7,%d0
    bsrw thunk_FUN_40816218
    tstw %d0
    bnes DRAGCONTROL_6A+0x10
    jsr %pc@(GETNEWRGN)
    tstb MMU32Bit
    jbeq DRAGCONTROL_40
    moveq #10,%d0
    tstw DragFlag
    jbeq DRAGCONTROL_38
    moveq #11,%d0
DRAGCONTROL_38:         /* set %d1 */
    movel %sp@,%d1
    jbsr thunk_FUN_40816218
    bras DRAGCONTROL_40+0x10	| 408161AA
DRAGCONTROL_40:         /* test DragFlag */
    tstw DragFlag
    sne %sp@
    movel %sp@,%d1
    moveq #2,%d0
    jbsr thunk_FUN_40816218
    clrb %sp@	| 408161BA
    moveal %sp@+,%a4
    moveml %d3-%d4/%a4-%a5,%sp@-
    movel %fp@(10),%sp@-
    movew %fp@(8),%sp@-
    movel CurDragAction,%sp@-
    tstw DragFlag
    jbne DRAGCONTROL_6A
    clrl %sp@
DRAGCONTROL_6A:         /* _DragTheRgn */
    _DragTheRgn
    movel %a4,%sp@-
    _DisposRgn
    movel %sp@+,%d3
    jbeq DRAGCONTROL_9A
    cmpiw #-32768,%d3
    jbne DRAGCONTROL_7E
    moveq #0,%d3
    jbra DRAGCONTROL_9A
DRAGCONTROL_7E:         /* test DragFlag */
    tstw DragFlag
    jbne DRAGCONTROL_9A
    moveal %a3@,%a0
    movel %a0@(8),%d0
    addw %d3,%d0
    swap %d0
    swap %d3
    addw %d3,%d0
    swap %d0
    movel %a3,%sp@-
    movel %d0,%sp@-
    _MoveControl
DRAGCONTROL_9A:         /* _SetPort */
    _SetPort
    movel %d3,%d1
    moveml %sp@+,%d3-%d4/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(18),%sp
    jmp %a0@

DRAGCONTROL_AC:         /* loop: move */
    movel %sp@+,%d2
    subqw #4,%sp
    movel %d2,%sp@-
    moveml %d0-%d1,%sp@-
    pea %sp@(12)
    _GetPort
    moveal %a3@,%a0
    movel %a0@(4),%sp@-
    _SetPort
    moveml %sp@+,%d0-%d1
    rts

/* TRACKCONTROL: _TrackControl: follow the mouse in a control part, calling the action procedure. */
trap_TrackControl:
TRACKCONTROL:
    linkw %fp,#-28
    moveml %d3/%a3,%sp@-
    moveal %fp@(16),%a3
    movel %fp@(12),%fp@(-8)
    jbsr DRAGCONTROL_AC
    moveq #0,%d3
TRACKCONTROL_16:
    movel %a3,%sp@-
    clrw %sp@-
    movel %a3,%sp@-
    movel %fp@(-8),%sp@-
    _TestControl
    tstw %d3
    bnes TRACKCONTROL_2E
    movew %sp@,%d3
    tstb %d3
    bpls TRACKCONTROL_34
    bras TRACKCONTROL_7E_10
TRACKCONTROL_2E:
    cmpw %sp@,%d3
    beqs TRACKCONTROL_34
    clrw %sp@
TRACKCONTROL_34:
    movew %sp@,%fp@(20)
    .short  0xA95D	| 4081626E _HiliteControl
    movel %fp@(8),%d0
    beqs TRACKCONTROL_6A
    btst #0,%d0
    beqs TRACKCONTROL_60
    moveal %a3@,%a0
    movel %a0@(32),%d0
    beqs TRACKCONTROL_6A
    btst #0,%d0
    beqs TRACKCONTROL_60
    moveq #8,%d0
    movew %fp@(20),%d1
    bsrw thunk_FUN_40816218
    bras TRACKCONTROL_6A
TRACKCONTROL_60:
    movel %a3,%sp@-
    movew %fp@(20),%sp@-
    moveal %d0,%a0
    jsr %a0@
TRACKCONTROL_6A:
    pea %fp@(-8)
    _GetMouse
    clrw %sp@-
    _WaitMouseUp
    tstb %sp@+
    bnes TRACKCONTROL_16
    movel %a3,%sp@-
    clrw %sp@-
    .short  0xA95D	| 408162B2 _HiliteControl
TRACKCONTROL_7E:        /* _SetPort (loop) */
    _SetPort
    moveml %sp@+,%d3/%a3
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(12),%sp
    jmp %a0@
TRACKCONTROL_7E_10:
    movew %sp@+,%fp@(20)
    addqw #4,%sp
    lea %fp@(-28),%a0
    movel %fp@(12),%a0@
    movel %a0,%d1
    moveq #6,%d0
    bsrw thunk_FUN_40816218
    st DragFlag
    movel %fp@(8),%d0
    btst #0,%d0
    beqs TRACKCONTROL_7E_42
    moveal %a3@,%a0
    movel %a0@(32),%d0
    btst #0,%d0
    beqs TRACKCONTROL_7E_42
    moveq #0,%d0
TRACKCONTROL_7E_42:
    movel %d0,CurDragAction
    movel %a3,%sp@-
    movel %fp@(12),%sp@-
    lea %fp@(-28),%a0
    movel %a0,%sp@-
    pea %a0@(8)
    movew %a0@(16),%sp@-
    bsrw DRAGCONTROL_4
    tstl %d1
    beqs TRACKCONTROL_7E_6A
    moveq #5,%d0
    bsrw thunk_FUN_40816218
    bras TRACKCONTROL_7E
TRACKCONTROL_7E_6A:
    clrw %fp@(20)
    bras TRACKCONTROL_7E

/* UPDTCONTROLS: _UpdtControl: draw the controls in the update region. */
trap_UpdtControl:
UPDTCONTROLS:
    linkw %fp,#-24
    moveml %d7/%a3,%sp@-
    moveal %fp@(12),%a3
    moveq #8,%d7
    jbra DRAWCONTROLS_E

/* DRAWCONTROLS: _DrawControls: draw all of a window's controls. */
trap_DrawControls:
DRAWCONTROLS:
    linkw %fp,#-24
    moveml %d7/%a3,%sp@-
    moveal %fp@(8),%a3
    moveq #4,%d7
DRAWCONTROLS_E:         /* set up and call _GetPort */
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    movel %a3,%sp@-
    _SetPort
    pea %fp@(-24)
    movel %sp@,%sp@-
    _GetPenState
    _PenNormal
    movel %a3@(140),%d0
    jbeq DRAWCONTROLS_4E
DRAWCONTROLS_28:        /* loop: movea */
    moveal %d0,%a3
    cmpiw #8,%d7
    jbne DRAWCONTROLS_42
    subqw #2,%sp
    moveal %a3@,%a0
    pea %a0@(8)
    movel %fp@(8),%sp@-
    _RectInRgn
    tstb %sp@+
    jbeq DRAWCONTROLS_48
DRAWCONTROLS_42:        /* clear %d1 */
    moveq #0,%d1
    jbsr NEWCONTROL_DC
DRAWCONTROLS_48:        /* set %a0 */
    moveal %a3@,%a0
    movel %a0@,%d0
    jbne DRAWCONTROLS_28
DRAWCONTROLS_4E:        /* _SetPenState */
    _SetPenState
    _SetPort
    movel %d7,%d0
    moveml %sp@+,%d7/%a3
    unlk %fp
    moveal %sp@+,%a0
    addal %d0,%sp
    jmp %a0@

DRAWCONTROLS_60:        /* save registers */
    moveml %d1/%a2-%a3,%sp@-
    moveq #-1,%d0
    tstl %a1@
    jbeq DRAWCONTROLS_82
    moveal %a1@,%a2
    moveal %a1,%a3
    jbra DRAWCONTROLS_78
DRAWCONTROLS_70:        /* loop: movea */
    moveal %a2@,%a3
    moveal %a3@,%a2
    movel %a2,%d1
    jbeq DRAWCONTROLS_82
DRAWCONTROLS_78:        /* test %a0,%a2 */
    cmpal %a0,%a2
    jbne DRAWCONTROLS_70
    moveal %a2@,%a2
    movel %a2@,%a3@
    moveq #0,%d0
DRAWCONTROLS_82:        /* restore registers, return */
    moveml %sp@+,%d1/%a2-%a3
    rts

/* FINDCONTROL: _FindControl: the control and part at a point in a window. */
trap_FindControl:
FINDCONTROL:
    linkw %fp,#-4
    moveml %d2-%d3/%a3,%sp@-
    lea %fp@(8),%a0
    moveal %a0@+,%a1
    clrl %a1@
    moveal %a0@+,%a3
    movel %a0@+,%d3
    clrw %a0@
    movel %sp,%sp@-
    _GetPort
    movel %a3,%sp@-
    _SetPort
    tstb %a3@(110)
    jbeq TRACKCONTROL_7E
    clrw %sp@-
    movel %d3,%sp@-
    pea %a3@(16)
    _PtInRect
    tstb %sp@+
    jbeq TRACKCONTROL_7E
    movel %a3@(140),%d0
    jbeq TRACKCONTROL_7E
    moveal %d0,%a3
FINDCONTROL_40:         /* loop: movea */
    moveal %a3@,%a0
    cmpib #0xff,%a0@(17)
    jbeq FINDCONTROL_56
    clrw %sp@-
    movel %a3,%sp@-
    movel %d3,%sp@-
    _TestControl
    movew %sp@+,%d0
    jbne FINDCONTROL_62
FINDCONTROL_56:         /* loop: movea */
    moveal %a3@,%a0
    moveal %a0@,%a3
    movel %a3,%d0
    jbne FINDCONTROL_40
    jbra TRACKCONTROL_7E
FINDCONTROL_62:         /* set %a0 */
    moveal %fp@(8),%a0
    movel %a3,%a0@
    movew %d0,%fp@(20)
    jbra FINDCONTROL_56

/* CMGREND: end of the Control Manager. */
CMGREND:
    .short  0x0000, 0x0000, 0x0000	| 4081642A

/* _FC2X: Fixed to Extended conversion helper. */
_FC2X:
    moveml %d0-%d1,%sp@-
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveml %sp@(0x10,%za0)@(0x0),%d0-%d1	| 40816434
    tstl %d1
    bgts _FC2X_14
    beqs _FC2X_3A
    addql #1,%d0
_FC2X_14:
    fmovel %d0,%fp0
    fscalew #32,%fp0
    faddl %d1,%fp0
    bvcs _FC2X_2C
    fadds #0x5f800000,%fp0	| 40816454
_FC2X_2C:
    moveml %sp@+,%d0-%d1
    fmovex %fp0,%sp@(4,%za0)@(0)	| 40816460
    rts
_FC2X_3A:
    negl %d0
    bvss _FC2X_42
    negl %d0
    bras _FC2X_14
_FC2X_42:
    fmoves #0x7fc01400,%fp0	| 40816472
    bras _FC2X_2C
    .short  0x0000, 0x0000	| orib #0,%d0

/* _fprocENTRYsp: floating point procedure entry helper. */
_fprocENTRYsp:
    fmovel %sp@+,%fpiar
    clrl %sp@-
    fmovemx %sp@,%fp0
    fmoveml %fpsr/%fpcr,%sp@-
    clrl %sp@-
    movel %sp@(4),%sp@-
    andil #255,%sp@
    fmoveml %sp@+,%fpsr/%fpcr
    fmovemx %fp0,%sp@-
    clrl %sp@+
    fmovel %fpiar,%sp@-
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 408164AE

/* _fprocEXITsp: floating point procedure exit helper. */
_fprocEXITsp:
    fmovew %d1,%fp1
    fmovel %fpsr,%sp@-
    movew %sp@(2),%d1
    clrl %sp@+
    fmoveml %sp@(4),%fpsr/%fpcr
    orw %d1,%sp@(10)
    andw %sp@(5),%d1
    fmovel %sp@(8),%fpsr
    tstb %d1
    beqs _fprocEXITsp_3A
    fnop
    nop
    fsave %sp@-
    bclr #27,%sp@(24)
    frestore %sp@+
    fnop
_fprocEXITsp_3A:
    fmovew %fp1,%d1
    movel %sp@,%sp@(20)
    lea %sp@(20),%sp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 408164F8
