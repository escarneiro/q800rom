/*
 toolbox/dialogmgr.s - Dialog Manager
 From DMGR (0x408198C0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* DMGR: Dialog Manager. */
DMGR:
    .byte   0x00, 0x0A, 0x00, 0x14, 0x00, 0x2A, 0x00, 0x34	| 408198C0
DMGR_8:
    .byte   0x00, 0x00	| 408198C8

/* INITDIALOGS: _InitDialogs: the resume procedure, ParamText strings cleared. */
trap_InitDialogs:
INITDIALOGS:
    jbsr MODALDIALOG_92
    movel %fp@(8),ResumeProc	| 408198CE
    clrw ACount
    st 0xa98
    lea DABeeper,%a0
    lea %pc@(INITDIALOGS_2E),%a1
    movel %a1,%a0@+	| 408198E4
    clrl %a0@+	| 408198E6
    clrl %a0@+	| 408198E8
    clrl %a0@+	| 408198EA
    clrl %a0@+	| 408198EC
    clrw DlgFont	| 408198EE
    moveq #4,%d0	| 408198F2
    jbra MODALDIALOG_9E	| 408198F4
INITDIALOGS_2E:
    .byte   0x22, 0x5F, 0x34, 0x1F, 0x67, 0x10, 0x3F, 0x3C, 0x00, 0x03, 0xA9, 0xC8, 0x30, 0x7C, 0x00, 0x06	| 408198F8
    .byte   0xA0, 0x3B, 0x53, 0x42, 0x60, 0xEE, 0x4E, 0xD1	| 40819908
INITDIALOGS_46:
    .byte   0x61, 0x00, 0x04, 0x64, 0x28, 0x6E, 0x00, 0x10, 0x61, 0x00, 0x04, 0xFA, 0x42, 0x6E, 0x00, 0x14	| 40819910
    .byte   0x20, 0x6E, 0x00, 0x0C, 0x0C, 0x50, 0x00, 0x03, 0x66, 0x4C, 0x0C, 0x28, 0x00, 0x03, 0x00, 0x05	| 40819920
    .byte   0x67, 0x08, 0x0C, 0x28, 0x00, 0x0D, 0x00, 0x05, 0x66, 0x3C, 0x36, 0x2C, 0x00, 0xA8, 0x22, 0x6E	| 40819930
    .byte   0x00, 0x08, 0x32, 0x83, 0x53, 0x43, 0x61, 0x00, 0x10, 0x82, 0x61, 0x00, 0x09, 0x50, 0x02, 0x40	| 40819940
    .byte   0x00, 0x07, 0x0C, 0x40, 0x00, 0x04, 0x66, 0x1A, 0x10, 0x2A, 0x00, 0x0C, 0x6B, 0x18, 0x2F, 0x08	| 40819950
    .byte   0x42, 0x67, 0x2F, 0x08, 0x3F, 0x3C, 0x00, 0x0A, 0xA9, 0x5D, 0x30, 0x7C, 0x00, 0x08, 0xA0, 0x3B	| 40819960
    .byte   0xA9, 0x5D, 0x52, 0x2E, 0x00, 0x14	| 40819970
    jbsr UPDTDIALOG_1C
    moveq #12,%d0
    jbra MODALDIALOG_9E

/* STOPALERT: _StopAlert: alert with the stop icon. */
trap_StopAlert:
STOPALERT:
    moveq #0,%d0
    jbra ALERT_2

/* NOTEALERT: _NoteAlert. */
trap_NoteAlert:
NOTEALERT:
    moveq #1,%d0
    jbra ALERT_2

/* CAUTIONALERT: _CautionAlert. */
trap_CautionAlert:
CAUTIONALERT:
    moveq #2,%d0
    jbra ALERT_2

/* ALERT: _Alert: show the alert of the 'ALRT', play its sound for the stage, run it modally. */
trap_Alert:
ALERT:
    moveq #-1,%d0
ALERT_2:                /* call MODALDIALOG_92 */
    jbsr MODALDIALOG_92
    /* result -1; d3 = the icon; the alert (fp+12), or exit if it cannot be loaded */
    movew #-1,%fp@(14)	| 40819992
    movew %d0,%d3
    movew %fp@(12),%d0
    bsrw COULDALERT_36_2E
    beqw ALERT_D0+0x50
    /* stage: ACount; a new alert (ANumber) starts at 0 */
    movew ACount,%d0
    movew %fp@(12),%d1
    cmpw 0xa98,%d1
    beqs ALERT_2_2C
    movew %d1,0xa98
    moveq #0,%d0
ALERT_2_2C:
    movew %d0,ACount	| 408199BA
    /* the stages word of the ALRT (+10), 4 bits per stage */
    movew %a1@(10),%d4
ALERT_2_34:
    subqw #1,%d0	| 408199C2
    blts ALERT_2_3C
    lsrw #4,%d4
    bras ALERT_2_34
ALERT_2_3C:             /* low 2 bits: the sound (ALERT_156); bit 2 clear: the box is not shown */
    andiw #15,%d4	| 408199CA
    movel %d4,%d0
    andiw #3,%d0
    bsrw ALERT_156
    btst #2,%d4
    beqw ALERT_D0+0x3a
    /* all events flushed; the item list (+8); a new dialog, through GETNEWDIALOG_5E when fp-84 is set, else _NewDialog */
    movel #511,%d0
    _FlushEvents
    movew %a1@(8),%d0
    bsrw ALERT_D0_56
    beqw ALERT_D0+0x3a
    moveal %a2@,%a1
    subqw #4,%sp
    clrl %sp@-
    pea %a1@
    pea %pc@(DMGR_8)
    tstl %fp@(-84)
    seq %d0
    moveb %d0,%sp@-
    movew #1,%sp@-
    movel MinusOne,%sp@-
    clrw %sp@-
    clrl %sp@-
    movel %a0,%sp@-
    tstl %fp@(-84)
    beqs ALERT_2_98
    st %fp@(-86)
    bsrw GETNEWDIALOG_5E
    bras ALERT_2_9A
ALERT_2_98:
    .short  0xA97D	| 40819A26 _NewDialog
ALERT_2_9A:             /* a4 = the dialog; port saved and set. Negative icon: none. A color icon, or a plain one */
    moveal %sp@,%a4	| 40819A28
    pea %fp@(-44)
    _GetPort
    _SetPort
    tstw %d3
    bmis ALERT_D0
    subqw #4,%sp
    movew %d3,%sp@-
    _GetCIcon
    movel %sp@+,%d0
    beqs ALERT_2_BC
    pea %pc@(DMGR)
    movel %d0,%sp@-
    _PlotCIcon
    jbra ALERT_D0	| 40819A48
ALERT_2_BC:
    subqw #4,%sp	| 40819A4A
    movew %d3,%sp@-
    _GetIcon
    movel %sp@+,%d0
    beqs ALERT_D0
    pea %pc@(DMGR)
    movel %d0,%sp@-
    _PlotIcon
ALERT_D0:               /* from here: asrw #3,%d4 */
    asrw #3,%d4	| 40819A5C
    addqw #1,%d4	| 40819A5E
    movew %d4,%a4@(168)	| 40819A60
    movel %a4,%sp@-	| 40819A64
    movew %d4,%sp@-	| 40819A66
    pea %fp@(-60)	| 40819A68
    movel %sp@,%sp@-	| 40819A6C
    pea %fp@(-40)	| 40819A6E
    _GetDItem	| 40819A72
    lea %fp@(-40),%a0	| 40819A74
    moveq #3,%d0	| 40819A78
    moveq #16,%d1	| 40819A7A
    moveq #4,%d2	| 40819A7C
    jbsr FINDDITEM_738	| 40819A7E
    movel %fp@(8),%sp@-	| 40819A82
    pea %fp@(14)	| 40819A86
    _ModalDialog	| 40819A8A
    movel %fp@(-44),%sp@-	| 40819A8C
    _SetPort	| 40819A90
    movel %a4,%sp@-	| 40819A92
    _DisposDialog	| 40819A94
    moveal %a2,%a0	| 40819A96
    _HUnlock	| 40819A98
    movew ACount,%d1	| 40819A9A
    addqw #1,%d1	| 40819A9E
    cmpiw #4,%d1	| 40819AA0
    blts ALERT_D0+0x4c
    moveq #3,%d1
    movew %d1,ACount
    moveq #6,%d0
    jbra MODALDIALOG_9E
ALERT_D0_56:
    subqw #4,%sp
    movel #1145656396,%sp@-
    movew %d0,%sp@-
    bsrw DISPOSDIALOG_4E_E
    movel %fp@(-80),%d0
    beqs ALERT_D0_72
    moveal %d0,%a0
    _HandToHand
    movel %a0,%fp@(-80)
ALERT_D0_72:
    movew #-1,ROMMapInsert
    _GetResource
    moveal %sp@+,%a0
    movel %a0,%d0
    beqs ALERT_D0_84
    _HandToHand
    movel %a0,%d0
ALERT_D0_84:
    rts

ALERT_156:              /* save registers */
    moveml %d0-%d2/%a0-%a2,%sp@-
    movel DABeeper,%d1
    jbeq ALERT_166
    movew %d0,%sp@-
    moveal %d1,%a0
    jsr %a0@
ALERT_166:              /* restore registers, return */
    moveml %sp@+,%d0-%d2/%a0-%a2
    rts

/* GETNEWDIALOG: _GetNewDialog: create a dialog from its 'DLOG' and 'DITL'. */
trap_GetNewDialog:
GETNEWDIALOG:
    jbsr MODALDIALOG_92
    clrl %fp@(18)
    movew %fp@(16),%d0
    bsrw COULDALERT_36_3E	| 40819B04
    beqs GETNEWDIALOG_58
    subqw #4,%sp
    movel %fp@(12),%sp@-
    movel %a1,%sp@-
    pea %a1@(20)
    addql #8,%a1
    movel %a1@+,%sp@-
    tstl %fp@(-84)
    beqs GETNEWDIALOG_32
    moveb %sp@(2),%fp@(-86)
    clrw %sp@(2)
GETNEWDIALOG_32:
    movel %fp@(8),%sp@-
    movew %a1@+,%sp@-
    movel %a1@+,%sp@-
    movew %a1@+,%d0
    bsrw ALERT_D0_56
    beqs GETNEWDIALOG_58
    movel %a0,%sp@-
    tstl %fp@(-84)
    beqs GETNEWDIALOG_4E
    bsrs GETNEWDIALOG_5E
    bras GETNEWDIALOG_50
GETNEWDIALOG_4E:
    .short  0xA97D	| 40819B46 _NewDialog
GETNEWDIALOG_50:
    moveal %a2,%a0
    _HUnlock
    movel %sp@+,%fp@(18)
GETNEWDIALOG_58:
    moveq #10,%d0
    braw MODALDIALOG_9E
GETNEWDIALOG_5E:
    moveal %fp@(-84),%a0
    moveal %a0@,%a1
    cmpiw #-1,%a1@(6)
    beqs GETNEWDIALOG_72
    _HandToHand
    movel %a0,%fp@(-84)
GETNEWDIALOG_72:
    movel %sp@+,%fp@(-90)
    movel %fp,%d1
    bsrs NEWDIALOG_2
    tstb %fp@(-86)
    beqs GETNEWDIALOG_92
    movel %sp@,%sp@-
    moveq #-1,%d0
    cmpl %fp@(8),%d0
    beqs GETNEWDIALOG_90
    st %sp@-
    _ShowHide
    bras GETNEWDIALOG_92
GETNEWDIALOG_90:
    _ShowWindow
GETNEWDIALOG_92:
    moveal %fp@(-90),%a0
    jmp %a0@

/* NEWCDIALOG: _NewCDialog: color dialog. */
trap_NewCDialog:
NEWCDIALOG:
    moveq #-1,%d1
    jbra NEWDIALOG_2

/* NEWDIALOG: _NewDialog: create a dialog window and its items. */
trap_NewDialog:
NEWDIALOG:
    moveq #0,%d1
NEWDIALOG_2:            /* call MODALDIALOG_92 */
    jbsr MODALDIALOG_92
    movel %d1,%d5
    tstl %fp@(34)
    bnes NEWDIALOG_2_18
    movel #170,%d0
    .short  0xA11E	| 40819BA8 _NewPtr (flags 0x0100)
    movel %a0,%fp@(34)
NEWDIALOG_2_18:
    lea %fp@(12),%a0
    moveq #30,%d0
    subal %d0,%sp
    moveal %sp,%a1
    _BlockMove
    tstl %d5
    beqs NEWDIALOG_2_58
    _NewCWindow
    tstl %d5
    bmis NEWDIALOG_2_5A
    movel %fp,%sp@-
    moveal %d5,%fp
    moveal %sp@(4),%a0
    subqw #6,%sp
    movel %a0,%sp@-
    pea %sp@(6)
    movel %a0,%sp@-
    movel %fp@(-84),%sp@-
    _SetWinColor
    _GetAuxWin
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movel %fp@(-80),%a0@(12)
    moveal %sp@+,%fp
    bras NEWDIALOG_2_5A
NEWDIALOG_2_58:
    _NewWindow
NEWDIALOG_2_5A:
    moveal %sp@+,%a4
    movel %a4,%fp@(38)
    moveal %fp@(8),%a3
    movew #2,%a4@(108)
    movel %a3,%a4@(156)
    movew MinusOne,%a4@(164)
    movew DlgFont,%a4@(68)
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    movel %a4,%sp@-
    _SetPort
    movew #1,%a4@(168)
    subqw #4,%sp
    pea %a4@(16)
    movel %sp@,%sp@-
    _TENew
    movel %sp@,%a4@(160)
    moveal %sp@+,%a1
    moveal %a1@,%a2
    moveal %a2@(62),%a0
    _DisposHandle
    _SetPort
    jbsr CLOSEDIALOG_46
    moveq #0,%d4
    jbsr FINDDITEM_34
    jbsr UPDTDIALOG_1C
    moveq #30,%d0
    jbra MODALDIALOG_9E
    movew %a2@,%d3	| 40819C4E
    subqw #6,%d3	| 40819C50
    jbeq NEWDIALOG_CC	| 40819C52
    subqw #2,%d3	| 40819C54
    jbeq NEWDIALOG_CC	| 40819C56
    subqw #4,%sp	| 40819C58
    _FrontWindow	| 40819C5A
    moveal %sp@+,%a4	| 40819C5C
    rts	| 40819C5E
NEWDIALOG_CC:           /* set %a4 */
    moveal %a2@(2),%a4	| 40819C60
    rts	| 40819C64

/* ISDIALOGEVENT: _IsDialogEvent: is the event for a dialog?. */
trap_IsDialogEvent:
ISDIALOGEVENT:
    jbsr MODALDIALOG_92
    clrw %fp@(12)	| 40819C6A
    moveal %fp@(8),%a2
    bsrs NEWDIALOG_2_5A+0x5e
    cmpiw #2,%a4@(108)	| 40819C74
    jbne ISDIALOGEVENT_36	| 40819C7A
    movew %a2@,%d3	| 40819C7C
    subqw #1,%d3	| 40819C7E
    jbne ISDIALOGEVENT_32	| 40819C80
    subqw #2,%sp	| 40819C82
    movel %a2@(10),%sp@-	| 40819C84
    pea %fp@(-20)	| 40819C88
    .short  0xA92C	| 40819C8C _FindWindow
    subqw #3,%sp@+	| 40819C8E
    jbne ISDIALOGEVENT_36	| 40819C90
    cmpal %fp@(-20),%a4	| 40819C92
    jbne ISDIALOGEVENT_36	| 40819C96
ISDIALOGEVENT_32:       /* add 1 to %fp@(12) */
    addqb #1,%fp@(12)	| 40819C98
ISDIALOGEVENT_36:       /* result 4 */
    moveq #4,%d0	| 40819C9C
    jbra MODALDIALOG_9E	| 40819C9E

/* DIALOGSELECT: _DialogSelect: handle an event in a modeless dialog. */
trap_DialogSelect:
DIALOGSELECT:
    jbsr MODALDIALOG_92
    clrw %fp@(20)	| 40819CA6
    moveal %fp@(12),%a3
    clrl %a3@
    moveal %fp@(16),%a2
    bsrs NEWDIALOG_2_5A+0x5e
    movel %a4,%a3@	| 40819CB6
    jbsr CLOSEDIALOG_46	| 40819CB8
    moveal %fp@(16),%a0
    lea %fp@(-76),%a1
    moveq #16,%d0
    _BlockMove
    jbsr FINDDITEM_3A0
    tstw %d3
    jbmi DIALOGSELECT_32
    addqb #1,%fp@(20)
DIALOGSELECT_32:        /* set %a0 */
    moveal %fp@(8),%a0
    movew %d3,%a0@
    jbsr UPDTDIALOG_1C
    moveq #12,%d0
    jbra MODALDIALOG_9E

/* MODALDIALOG: _ModalDialog: run the frontmost dialog until an item is hit. */
trap_ModalDialog:
MODALDIALOG:
    jbsr MODALDIALOG_92
MODALDIALOG_4:          /* idle: _SystemTask; _TEIdle in the front dialog's edit item */
    _SystemTask	| 40819CE8
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    subqw #4,%sp
    _FrontWindow
    movel %sp@,%sp@-
    _SetPort
    moveal %sp@+,%a0
    tstw %a0@(164)
    bmis MODALDIALOG_4_2A
    movew %a0@(164),%d0
    bsrw FINDDITEM_59C
    movel %a0@(160),%sp@-
    _TEIdle
    bsrw FINDDITEM_6C6
MODALDIALOG_4_2A:       /* next event; the filter proc given, or the default one (INITDIALOGS_46) */
    _SetPort	| 40819D12
    subqw #6,%sp
    movew #383,%sp@-
    pea %fp@(-76)
    _GetNextEvent
    movel %fp@(12),%d3
    bnes MODALDIALOG_4_44
    lea %pc@(INITDIALOGS_46),%a0
    movel %a0,%d3
MODALDIALOG_4_44:       /* filter(front window, event, item): true returns; then _IsDialogEvent, _DialogSelect, else again */
    _FrontWindow	| 40819D2C
    pea %fp@(-76)
    movel %fp@(8),%sp@-
    moveal %d3,%a0
    jsr %a0@
    tstb %sp@+
    bnes MODALDIALOG_4+0x76
    subqw #2,%sp
    pea %fp@(-76)
    .short  0xA97F	| _IsDialogEvent
    tstw %sp@+
    beqs MODALDIALOG_4+0x7a
    subqw #2,%sp
    pea %fp@(-76)
    pea %fp@(-28)
    movel %fp@(8),%sp@-
    .short  0xA980	| _DialogSelect
    tstw %sp@+
    bles MODALDIALOG_4
    moveq #8,%d0
    jbra MODALDIALOG_9E
    movew %fp@(-76),%d0
    subqw #1,%d0
    bnew MODALDIALOG_4
    moveq #1,%d0
    bsrw ALERT_156
    braw MODALDIALOG_4

MODALDIALOG_92:         /* loop: movea */
    moveal %sp@+,%a0
    linkw %fp,#-118
    moveml %d3-%d7/%a2-%a4,%sp@-
    jmp %a0@

MODALDIALOG_9E:         /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    moveal %sp@+,%a0
    addal %d0,%sp
    jmp %a0@

/* DRAWDIALOG: _DrawDialog: draw all the items. */
trap_DrawDialog:
DRAWDIALOG:
    jbsr MODALDIALOG_92
    moveal %fp@(8),%a4	| 40819D90
    bsrs CLOSEDIALOG_46
    movel %a4,%sp@-
    _DrawControls
    moveq #1,%d4
    jbsr FINDDITEM_34
    bsrw UPDTDIALOG_1C
    jbra CLOSEDIALOG_30

/* UPDTDIALOG: _UpdtDialog: draw the items in the update region. */
trap_UpdtDialog:
UPDTDIALOG:
    jbsr MODALDIALOG_92
    moveal %fp@(12),%a4	| 40819DA8
    bsrs CLOSEDIALOG_46
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    _UpdtControl
    moveq #3,%d4
    jbsr FINDDITEM_34
    jbsr UPDTDIALOG_1C
    jbra SETITEXT_66

UPDTDIALOG_1C:          /* set up and call _SetPort (loop) */
    movel %fp@(-44),%sp@-
    _SetPort
    moveal %a3,%a0
    _HUnlock
    rts

/* CLOSEDIALOG: _CloseDialog: close it (caller's storage). */
trap_CloseDialog:
CLOSEDIALOG:
    jbsr MODALDIALOG_92
    moveal %fp@(8),%a4	| 40819DD0
    bsrs CLOSEDIALOG_46
    movel %a4@(28),%sp@-
    _SetEmptyRgn
    moveq #2,%d4
    jbsr FINDDITEM_34
    jbsr UPDTDIALOG_1C
    moveal %a4@(160),%a0
    movel %a0,%sp@-
    moveq #0,%d0
    .short  0xA122	| 40819DEC _NewHandle (flags 0x0100)
    movel %a0,%d0
    moveal %sp@,%a0
    moveal %a0@,%a0
    movel %d0,%a0@(62)
    _TEDispose
    movel %a4,%sp@-
    _CloseWindow
CLOSEDIALOG_30:         /* result 4 */
    moveq #4,%d0
    jbra MODALDIALOG_9E

CLOSEDIALOG_34:         /* loop: movea */
    moveal %a4@(156),%a3
    tstl %a3@
    jbne CLOSEDIALOG_40
    movel %a3,%sp@-
    _LoadResource
CLOSEDIALOG_40:         /* set up and call _HLock */
    moveal %a3,%a0
    _HLock
    rts

CLOSEDIALOG_46:         /* set up and call _GetPort */
    pea %fp@(-44)
    _GetPort
    movel %a4,%sp@-
    _SetPort
    jbsr CLOSEDIALOG_34
    jbsr CLOSEDIALOG_5E
    jbeq CLOSEDIALOG_5A
    jbsr FINDDITEM_532
CLOSEDIALOG_5A:         /* set %d1 */
    moveq #26,%d1
    rts

CLOSEDIALOG_5E:         /* loop: move */
    movew %a4@(164),%d3
    jbmi CLOSEDIALOG_6A
    jbsr FINDDITEM_774
    jbra CLOSEDIALOG_80
CLOSEDIALOG_6A:         /* set %d3 */
    moveq #-1,%d3
CLOSEDIALOG_6C:         /* call FINDDITEM_76A (loop) */
    jbsr FINDDITEM_76A
    jbeq CLOSEDIALOG_82
    btst #4,%a2@(12)
    jbeq CLOSEDIALOG_6C
    jbsr FINDDITEM_70A
    jbeq CLOSEDIALOG_6C
CLOSEDIALOG_80:         /* set %d2 */
    moveq #-2,%d2
CLOSEDIALOG_82:         /* return */
    rts

/* DISPOSDIALOG: _DisposDialog: close it and free it. */
trap_DisposDialog:
DISPOSDIALOG:
    subqw #6,%sp
    movel %sp@(10),%sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movel %a0@(12),%d0
    jbeq DISPOSDIALOG_1C
    moveal %d0,%a0
    _DisposHandle
DISPOSDIALOG_1C:        /* set up and call _CloseDialog */
    moveal %sp@(4),%a0
    movel %a0@(156),%sp@-
    movel %a0,%sp@-
    _CloseDialog
    moveal %sp@+,%a0
    _DisposHandle
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _DisposPtr
    jmp %a1@
DISPOSDIALOG_1C_18:
    moveal %a2@,%a0
    movew %a0@(18),%d0
    bras DISPOSDIALOG_1C_26
    moveal %a2@,%a0
    movew %a0@(8),%d0
DISPOSDIALOG_1C_26:
    subqw #4,%sp
    movel #1145656396,%sp@-
    movew %d0,%sp@-
    bsrs DISPOSDIALOG_4E_E
DISPOSDIALOG_4E:        /* set up and call _GetResource (loop) */
    movew #-1,ROMMapInsert
    _GetResource
    moveal %sp@+,%a2
    movel %a2,%d0
    rts
DISPOSDIALOG_4E_E:
    subqw #4,%sp
    movel #1768125538,%sp@-
    movew %d0,%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@+,%fp@(-80)
    rts

/* COULDDIALOG: _CouldDialog: load and lock its resources. */
trap_COULDDIALOG:
COULDDIALOG:
    jbsr MODALDIALOG_92
    lea %pc@(COULDALERT_36_3E),%a2	| 40819ECA
    lea %pc@(DISPOSDIALOG_1C_18),%a4
    bras COULDALERT_C

/* COULDALERT: _CouldAlert. */
trap_COULDALERT:
COULDALERT:
    jbsr MODALDIALOG_92
    lea %pc@(COULDALERT_36_2E),%a2	| 40819ED8
    lea %pc@(DISPOSDIALOG_1C_18+0x8),%a4
COULDALERT_C:
    movew %fp@(8),%d0
    jsr %a2@
    jbeq FREEALERT_3E
    movel %fp@(-84),%d0
    jbeq COULDALERT_20
    moveal %d0,%a0
    _HNoPurge
COULDALERT_20:          /* set up and call _HUnlock */
    moveal %a2,%a0
    _HUnlock
    _HNoPurge
    jsr %a4@
    jbeq FREEALERT_3E
    movel %fp@(-80),%d0
    jbeq COULDALERT_36
    moveal %d0,%a0
    _HNoPurge
COULDALERT_36:          /* set up and call _HNoPurge */
    moveal %a2,%a0
    _HNoPurge
    moveal %a2,%a3
    moveq #-2,%d4
    jbsr FREEALERT_44
    moveal %a2,%a0
    _HNoPurge
    jbra FREEALERT_3E
COULDALERT_36_14:
    movew %d0,%sp@-	| 40819F1E
    subqw #4,%sp
    movel %a0,%sp@-
    movew %d0,%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@,%fp@(-84)	| 40819F2E
    addqw #4,%sp	| 40819F32
    movew %sp@+,%d0	| 40819F34
    rts	| 40819F36
COULDALERT_36_2E:
    moveal #1633907810,%a0	| 40819F38
    bsrs COULDALERT_36_14
    moveal #1095520852,%a0
    bras COULDALERT_36+0x4c
COULDALERT_36_3E:
    moveal #1684239458,%a0	| 40819F48
    bsrs COULDALERT_36_14
    moveal #1145851719,%a0
    subqw #4,%sp
    movel %a0,%sp@-
    movew %d0,%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@,%d0
    moveal %d0,%a2
    jbeq COULDALERT_9C
    moveal %d0,%a0
    _HLock
    moveal %a2@,%a1
COULDALERT_9C:          /* test %sp@+ */
    tstl %sp@+
    rts

COULDALERT_A0:          /* loop: move */
    movel %a2,%sp@-
    moveal %d0,%a2
    jbsr FINDDITEM_D8
    moveal %sp@+,%a2
    rts

/* FREEDIALOG: _FreeDialog: release them. */
trap_FREEDIALOG:
FREEDIALOG:
    jbsr MODALDIALOG_92
    lea %pc@(COULDALERT_36_3E),%a2	| 40819F84
    lea %pc@(DISPOSDIALOG_1C_18),%a4
    bras FREEALERT_C

/* FREEALERT: _FreeAlert. */
trap_FREEALERT:
FREEALERT:
    jbsr MODALDIALOG_92
    lea %pc@(COULDALERT_36_2E),%a2	| 40819F92
    lea %pc@(DISPOSDIALOG_1C_18+0x8),%a4
FREEALERT_C:
    movew %fp@(8),%d0
    jsr %a2@
    jbeq FREEALERT_3E
    movel %fp@(-84),%d0
    jbeq FREEALERT_1C
    jbsr COULDALERT_A0
FREEALERT_1C:           /* set up and call _HUnlock */
    moveal %a2,%a0
    _HUnlock
    jbsr FINDDITEM_D8
    jsr %a4@
    jbeq FREEALERT_3E
    movel %fp@(-80),%d0
    jbeq FREEALERT_30
    jbsr COULDALERT_A0
FREEALERT_30:           /* call FINDDITEM_D8 */
    jbsr FINDDITEM_D8
    moveal %a2,%a3
    moveq #-1,%d4
    jbsr FREEALERT_44
    jbsr FINDDITEM_D8
FREEALERT_3E:           /* result 2 */
    moveq #2,%d0
    jbra MODALDIALOG_9E

FREEALERT_44:           /* set up and call _HLock */
    moveal %a3,%a0
    _HLock
    jbsr FINDDITEM_34
    moveal %a3,%a0
    _HUnlock
    subqw #4,%sp
    movel #1464091974,%sp@-
    clrw %sp@-
    movew #-1,ROMMapInsert
    jbra DISPOSDIALOG_4E

/* PARAMTEXT: _ParamText: the ^0..^3 replacement strings. */
trap_ParamText:
PARAMTEXT:
    lea TEScrpLength,%a1
    moveq #3,%d2
PARAMTEXT_6:            /* loop: move */
    movel %sp@(4),%d1
    moveal %a1@-,%a0
    jbeq PARAMTEXT_1C
    movel %a0,%d0
    jbeq PARAMTEXT_14
    _DisposHandle
PARAMTEXT_14:           /* set %a0 */
    moveal %d1,%a0
    jbsr FINDDITEM_75A
    movel %a0,%a1@
PARAMTEXT_1C:           /* set %sp@ */
    movel %sp@+,%sp@
    dbf %d2,PARAMTEXT_6
    rts

/* ERRORSOUND: _ErrorSound: the sound procedure for alerts. */
trap_ErrorSound:
ERRORSOUND:
    moveal %sp@+,%a0
    movel %sp@+,DABeeper
    jmp %a0@

/* GETDITEM: _GetDItem: type, handle and rectangle of an item. */
trap_GetDItem:
GETDITEM:
    jbsr MODALDIALOG_92
    moveal %fp@(22),%a4	| 4081A022
    bsrw CLOSEDIALOG_46
    movew %fp@(20),%d3
    subqw #1,%d3
    jbsr FINDDITEM_774
    jbeq GETDITEM_3C
    movel %fp@(8),%d0
    jbeq GETDITEM_28
    lea %a2@(4),%a0
    moveal %d0,%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
GETDITEM_28:            /* set %a0 */
    moveal %fp@(16),%a0
    moveq #0,%d0
    moveb %a2@(12),%d0
    movew %d0,%a0@
    movel %a2@,%d5
    moveal %fp@(12),%a0
    movel %d5,%a0@
GETDITEM_3C:            /* call UPDTDIALOG_1C */
    jbsr UPDTDIALOG_1C
    moveq #18,%d0
    jbra MODALDIALOG_9E

/* SETDITEM: _SetDItem. */
trap_SetDItem:
SETDITEM:
    jbsr MODALDIALOG_92
    moveal %fp@(20),%a4	| 4081A068
    bsrw CLOSEDIALOG_46
    movew %fp@(18),%d3
    subqw #1,%d3
    jbsr FINDDITEM_774
    jbeq SETDITEM_2E
    moveal %fp@(8),%a0
    lea %a2@(4),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %fp@(12),%a2@
    moveb %fp@(17),%a2@(12)
SETDITEM_2E:            /* call UPDTDIALOG_1C */
    jbsr UPDTDIALOG_1C
    moveq #16,%d0
    jbra MODALDIALOG_9E

/* GETITEXT: _GetIText: the text of an edit/static item. */
trap_GetIText:
GETITEXT:
    moveq #0,%d1
    subqb #1,%d1
    jbsr MODALDIALOG_92
    moveal %fp@(8),%a1
    moveal %fp@(12),%a0
    _GetHandleSize
    cmpl %d1,%d0
    bles GETITEXT_18
    movel %d1,%d0
GETITEXT_18:
    moveb %d0,%a1@+
    moveal %a0@,%a0
    _BlockMove
    bras SETITEXT_66

/* SETITEXT: _SetIText. */
trap_SetIText:
SETITEXT:
    jbsr MODALDIALOG_92
    moveal %fp@(8),%a0	| 4081A0C0
    moveq #0,%d0
    moveb %a0@+,%d0
    moveal %fp@(12),%a1
    _PtrToXHand
    moveal WindowList,%a4
SETITEXT_16:            /* each window: a dialog (windowKind 2) using this handle is updated */
    cmpiw #2,%a4@(108)	| 4081A0D2
    bnes SETITEXT_5E
    bsrw CLOSEDIALOG_46
    movel %fp@(12),%d6
    moveq #-1,%d3
SETITEXT_28:            /* next item (FINDDITEM_76A); is it this handle? */
    bsrw FINDDITEM_76A	| 4081A0E4
    beqs SETITEXT_5A
    cmpl %a2@,%d6
    bnes SETITEXT_28
    cmpw %a4@(164),%d3
    bnes SETITEXT_46
    bsrw FINDDITEM_5AE
    movel %a4@(160),%sp@-
    _TECalText
    bsrw FINDDITEM_6C6
SETITEXT_46:            /* visible: erase it and redraw */
    tstb %a4@(110)	| 4081A102
    beqs SETITEXT_5A
    pea %fp@(-40)
    movel %sp@,%sp@-
    _EraseRect
    bsrw FINDDITEM_1D6
    _ValidRect
SETITEXT_5A:
    bsrw UPDTDIALOG_1C	| 4081A116
SETITEXT_5E:            /* next window */
    moveal %a4@(144),%a4	| 4081A11A
    movel %a4,%d0
    bnes SETITEXT_16
SETITEXT_66:            /* result 8 */
    moveq #8,%d0
    jbra MODALDIALOG_9E

/* SELITEXT: _SelIText: select text in an edit item. */
trap_SelIText:
SELITEXT:
    jbsr MODALDIALOG_92
    moveal %fp@(14),%a4	| 4081A12C
    bsrw CLOSEDIALOG_46
    movew %fp@(12),%d3
    subqw #1,%d3
    jbsr FINDDITEM_774
    movel %fp@(8),%d2
    swap %d2
    jbsr FINDDITEM_4E8
    jbsr UPDTDIALOG_1C
    moveq #10,%d0
    jbra MODALDIALOG_9E

SELITEXT_2A:            /* loop: moveq */
    moveq #-3,%d7
    moveb %a2@(12),%d1
    btst #4,%d1
    jbne SELITEXT_44
    moveq #-4,%d7
    movew %a4@(168),%d0
    subqw #1,%d0
    cmpw %d0,%d3
    jbeq SELITEXT_44
    moveq #0,%d7
SELITEXT_44:            /* set %a0 */
    moveal %sp@+,%a0
    movel %a2@(8),%sp@-
    movel %a2@(4),%sp@-
    movel %a0,%sp@-
    pea %sp@(4)
    movew %d7,%sp@-
    movew %d7,%sp@-
    _InsetRect
    rts

/* HIDEDITEM: _HideDItem. */
trap_HideDItem:
HIDEDITEM:
    jbsr MODALDIALOG_92
    moveal %fp@(10),%a4	| 4081A188
    bsrw CLOSEDIALOG_46
    movew %fp@(8),%d3
    subqw #1,%d3
    jbsr FINDDITEM_774
    jbeq HIDEDITEM_22
    movew %a2@(6),%d0
    cmpiw #8192,%d0
    jblt HIDEDITEM_2C
HIDEDITEM_22:           /* call UPDTDIALOG_1C (loop) */
    jbsr UPDTDIALOG_1C
    moveq #6,%d0
    jbra MODALDIALOG_9E
HIDEDITEM_2C:           /* call SELITEXT_2A */
    jbsr SELITEXT_2A
    cmpw %a4@(164),%d3
    jbne HIDEDITEM_3A
    moveq #-1,%d3
    jbsr FINDDITEM_4E8
HIDEDITEM_3A:           /* set up and call _EraseRect */
    movel %sp,%sp@-
    _EraseRect
    addiw #16384,%a2@(6)
    addiw #16384,%a2@(10)
    jbsr SHOWDITEM_54
    jbeq HIDEDITEM_56
    movel %a2@,%sp@-
    movel %a2@(4),%sp@-
    _MoveControl

HIDEDITEM_56:           /* set up and call _InvalRect (loop) */
    movel %sp,%sp@-
    _InvalRect
    addqw #8,%sp
HIDEDITEM_5C:           /* continue at HIDEDITEM_22 */
    jbra HIDEDITEM_22

/* SHOWDITEM: _ShowDItem. */
trap_ShowDItem:
SHOWDITEM:
    jbsr MODALDIALOG_92
    moveal %fp@(10),%a4	| 4081A1E6
    bsrw CLOSEDIALOG_46
    movew %fp@(8),%d3
    subqw #1,%d3
    jbsr FINDDITEM_774
    jbeq HIDEDITEM_5C
    movew %a2@(6),%d0
    cmpiw #8192,%d0
    jblt HIDEDITEM_5C
    subiw #16384,%a2@(6)
    subiw #16384,%a2@(10)
    jbsr SELITEXT_2A
    jbsr SHOWDITEM_54
    jbeq SHOWDITEM_52
    moveal %a2@,%a0
    moveal %a0@,%a1
    moveb %a1@(16),%sp@-
    clrb %a1@(16)
    movel %a0,%sp@-
    movel %a2@(4),%sp@-
    _MoveControl
    moveal %a2@,%a0
    moveal %a0@,%a1
    moveb %sp@+,%a1@(16)
SHOWDITEM_52:           /* continue at HIDEDITEM_56 */
    jbra HIDEDITEM_56

SHOWDITEM_54:           /* test %a4@(164) */
    tstw %a4@(164)
    jbpl SHOWDITEM_6A
    movel %a2,%sp@-
    jbsr CLOSEDIALOG_5E
    jbeq SHOWDITEM_68
    moveq #0,%d2
    jbsr FINDDITEM_4E8
SHOWDITEM_68:           /* set %a2 */
    moveal %sp@+,%a2
SHOWDITEM_6A:           /* set %d1 */
    moveb %a2@(12),%d1
    btst #2,%d1
    rts

/* FINDDITEM: _FindDItem: the item at a point. */
trap_FindDItem:
FINDDITEM:
    jbsr MODALDIALOG_92
    moveal %fp@(12),%a4	| 4081A25A
    bsrw CLOSEDIALOG_34
    moveq #-1,%d3
    movew %d3,%fp@(16)
FINDDITEM_12:
    bsrw FINDDITEM_76A	| 4081A268
    beqs FINDDITEM_20+0xc
    subqw #2,%sp
    movel %fp@(8),%sp@-
    .byte   0x48, 0x6E	| 4081A274
FINDDITEM_20:           /* (data) */
    .byte   0xFF, 0xD8	| 4081A276
    _PtInRect
    tstb %sp@+
    beqs FINDDITEM_12	| 4081A27C
    movew %d3,%fp@(16)
    moveal %a3,%a0
    _HUnlock
    braw SETITEXT_66

FINDDITEM_34:           /* save registers */
    moveml %d0-%a4,%sp@-
    moveq #-1,%d3
FINDDITEM_3A:           /* call FINDDITEM_76A */
    jbsr FINDDITEM_76A
    jbne FINDDITEM_4E
    moveml %sp@+,%d0-%a4
    rts

FINDDITEM_46:           /* loop: movea */
    moveal %a2@,%a0
    moveb %a2@(12),%d0
    rts
FINDDITEM_4E:           /* call FINDDITEM_46 */
    jbsr FINDDITEM_46
    pea %pc@(FINDDITEM_3A)
    cmpiw #2,%d4
    jbgt FINDDITEM_1B0
    jbeq FINDDITEM_33E
    tstw %d4
    jbeq FINDDITEM_EC
    jbgt FINDDITEM_1D6
    btst #2,%d0
    jbne FINDDITEM_78
    roxrw #7,%d0
    jbmi FINDDITEM_A0
    jbcs FINDDITEM_B4
FINDDITEM_76:           /* return */
    rts
FINDDITEM_78:           /* from here: andiw #3,%d0 */
    andiw #3,%d0
    cmpiw #3,%d0
    jbne FINDDITEM_98
    pea %pc@(FINDDITEM_8E)
    movel #1129206860,%d1
    jbra FINDDITEM_BE
FINDDITEM_8E:           /* (data) */
    movel %a2,%d0	| 4081A2E4
    jbeq FINDDITEM_76	| 4081A2E6
    moveal %a2@,%a1	| 4081A2E8
    movew %a1@(16),%d0	| 4081A2EA
FINDDITEM_98:           /* set %d1 */
    movel #1128547654,%d1
    jbra FINDDITEM_C2
FINDDITEM_A0:           /* set up and call _GetCIcon */
    moveaw %a2@(14),%a2
    subqw #4,%sp
    movew %a2,%sp@-
    _GetCIcon
    tstl %sp@
    jbne FINDDITEM_CA
    movew %a2,%sp@-
    _GetIcon
    jbra FINDDITEM_CA
FINDDITEM_B4:           /* set up and call _GetPicture */
    subqw #4,%sp
    movew %a2@(14),%sp@-
    _GetPicture
    jbra FINDDITEM_CA
FINDDITEM_BE:           /* set %d0 */
    movew %a2@(14),%d0
FINDDITEM_C2:           /* set up and call _GetResource */
    subqw #4,%sp
    movel %d1,%sp@-
    movew %d0,%sp@-
    _GetResource
FINDDITEM_CA:           /* set %a2 */
    moveal %sp@+,%a2
    cmpiw #-1,%d4
    jbeq FINDDITEM_D8
    moveal %a2,%a0
    _HNoPurge
    rts

FINDDITEM_D8:           /* set up and call _GetResAttrs */
    subqw #2,%sp
    movel %a2,%sp@-
    _GetResAttrs
    movew %sp@+,%d0
    btst #5,%d0
    jbeq FINDDITEM_EA
    moveal %a2,%a0
    _HPurge
FINDDITEM_EA:           /* return */
    rts
FINDDITEM_EC:           /* set %d1 */
    movel %a0,%d1
    jbeq FINDDITEM_F2
    rts
FINDDITEM_F2:           /* test bit 2 of %d0 */
    btst #2,%d0
    jbne FINDDITEM_138
    roxrw #5,%d0
    jbcs FINDDITEM_106
    jbmi FINDDITEM_106
    roxrw #2,%d0
    jbmi FINDDITEM_116
    jbcs FINDDITEM_12E
    rts
FINDDITEM_106:          /* set up and call _PtrToHand */
    lea %a2@(13),%a0
    moveq #0,%d0
    moveb %a0@+,%d0
    _PtrToHand
    movel %a0,%sp@-
    jbra FINDDITEM_1AC
FINDDITEM_116:          /* set up and call _GetCIcon */
    subqw #4,%sp
    movew %a2@(14),%sp@-
    _GetCIcon
    tstl %sp@
    jbne FINDDITEM_1AC
    movew %a2@(14),%sp@-
    _GetIcon
    braw FINDDITEM_1AC
FINDDITEM_12E:          /* set up and call _GetPicture */
    subqw #4,%sp
    movew %a2@(14),%sp@-
    _GetPicture
    jbra FINDDITEM_1AC
FINDDITEM_138:          /* from here: andiw #3,%d0 */
    andiw #3,%d0
    cmpiw #3,%d0
    jbne FINDDITEM_156
    subqw #4,%sp
    movew %a2@(14),%sp@-
    movel %a4,%sp@-
    _GetNewControl
    movel %sp@,%sp@-
    movel %a2@(4),%sp@-
    _MoveControl
    jbra FINDDITEM_170
FINDDITEM_156:          /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a4,%sp@-
    pea %fp@(-40)
    pea %a2@(13)
    st %sp@-
    clrl %sp@-
    movew #1,%sp@-
    movew %d0,%sp@-
    clrl %sp@-
    _NewControl
FINDDITEM_170:          /* set up and call _GetAuxWin */
    subqw #6,%sp
    movel %a4,%sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    movel %sp@+,%d0
    jbeq FINDDITEM_1A6
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@(12),%d1
    jbeq FINDDITEM_1A6
    moveal %d1,%a0
    moveal %a0@,%a0
    moveq #0,%d0
    lea %a0@(0x0,%d3:w:4),%a1
    movew %a1@+,%d0
    jble FINDDITEM_1A6
    addaw %a1@,%a0
    _PtrToHand
    tstw %d0
    jbne FINDDITEM_1A6
    movel %sp@,%sp@-
    movel %a0,%sp@-
    _SetCtlColor
FINDDITEM_1A6:          /* set up and call _ValidRect */
    pea %fp@(-40)
    _ValidRect
FINDDITEM_1AC:          /* set %a2@ */
    movel %sp@+,%a2@
    rts
FINDDITEM_1B0:          /* set %sp@- */
    movel %a2@(8),%sp@-
    movel %a2@(4),%sp@-
    movel %sp,%sp@-
    movel #-196612,%sp@-
    _InsetRect
    subqw #2,%sp
    pea %sp@(2)
    movel %fp@(8),%sp@-
    _RectInRgn
    tstb %sp@+
    addqw #8,%sp
    jbne FINDDITEM_1E6
    rts
FINDDITEM_1D6:          /* call FINDDITEM_46 */
    jbsr FINDDITEM_46
    andib #127,%d0
    jbeq FINDDITEM_1FC
    jbsr FINDDITEM_70E
    jbeq FINDDITEM_234
FINDDITEM_1E6:          /* call FINDDITEM_46 */
    jbsr FINDDITEM_46
    btst #2,%d0
    jbne FINDDITEM_266
    roxrw #5,%d0
    jbcs FINDDITEM_268
    jbmi FINDDITEM_268
    roxrw #2,%d0
    jbmi FINDDITEM_236
    jbcs FINDDITEM_25A
FINDDITEM_1FC:          /* set up and call _SetPort */
    movel %a4,%sp@-
    _SetPort
    jbsr FINDDITEM_694
    movel %a2@,%d0
    jbeq FINDDITEM_234
    movel %a4,%sp@-
    movew %d3,%sp@-
    addqw #1,%sp@
    moveal %d0,%a0
    jsr %a0@
    subqw #6,%sp
    movel %a4,%sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    movel %sp@+,%d0
    jbeq FINDDITEM_234
    moveal %d0,%a0
    moveal %a0@,%a0
    tstl %a0@(12)
    jbeq FINDDITEM_234
    movel %a4,%sp@-
    _SetPort
    jbsr FINDDITEM_6E4
FINDDITEM_234:          /* return */
    rts
FINDDITEM_236:          /* set up and call _LoadResource */
    pea %fp@(-40)
    movel %a2@,%sp@-
    movel %sp@,%sp@-
    _LoadResource
    moveal %sp@,%a0
    _GetHandleSize
    tstl %d0
    jble FINDDITEM_252
    rorl #7,%d0
    subqw #1,%d0
    jbeq FINDDITEM_256
    _PlotCIcon
    rts
FINDDITEM_252:          /* add 8 to %sp */
    addqw #8,%sp
    rts
FINDDITEM_256:          /* _PlotIcon */
    _PlotIcon
    rts
FINDDITEM_25A:          /* set up and call _LoadResource */
    movel %a2@,%sp@-
    movel %sp@,%sp@-
    _LoadResource
    pea %fp@(-40)
    _DrawPicture
FINDDITEM_266:          /* return */
    rts
FINDDITEM_268:          /* from here: smi %d6 */
    smi %d6
    cmpw %a4@(164),%d3
    jbne FINDDITEM_29A
    jbsr FINDDITEM_5AE
    pea %fp@(-40)
    movel %sp@,%sp@-
    _EraseRect
    movel %a4@(160),%sp@-
    _TEUpdate
    jbsr FINDDITEM_6C6
FINDDITEM_286:          /* loop: tst */
    tstb %d6
    jbne FINDDITEM_298
    lea %fp@(-40),%a0
    moveq #1,%d0
    moveq #1,%d1
    moveq #3,%d2
    jbsr FINDDITEM_738
FINDDITEM_298:          /* return */
    rts
FINDDITEM_29A:          /* call FINDDITEM_5A6 */
    jbsr FINDDITEM_5A6
    moveml %d2-%d6/%a2-%a4,%sp@-
    moveal %a2@,%a0
    _HandToHand
    moveal %a0,%a2
    tstb %d6
    jbeq FINDDITEM_2C8
    moveq #0,%d3
FINDDITEM_2AE:          /* set up and call _GetHandleSize (loop) */
    moveal %a2,%a0
    _GetHandleSize
    moveal %a0@,%a4
    addal %d3,%a4
    movel %d0,%d5
    subl %d3,%d5
    jbra FINDDITEM_2C4
FINDDITEM_2BC:          /* loop: cmpi */
    cmpib #94,%a4@+
    jbeq FINDDITEM_2F6
FINDDITEM_2C2:          /* loop: addq */
    addqw #1,%d3
FINDDITEM_2C4:          /* count down */
    dbf %d5,FINDDITEM_2BC
FINDDITEM_2C8:          /* set up and call _HLock */
    moveal %a2,%a0
    _HLock
    movel %a2@,%sp@-
    moveal %a2,%a0
    _GetHandleSize
    movel %d0,%sp@-
    pea %fp@(-40)
    moveal %a5@,%a0
    moveal %a0@,%a0
    moveal %a0@(160),%a0
    moveal %a0@,%a0
    movew %a0@(58),%sp@-
    _TextBox
    jbsr FINDDITEM_6E4
    moveal %a2,%a0
    _DisposHandle
    moveml %sp@+,%d2-%d6/%a2-%a4
    jbra FINDDITEM_286
FINDDITEM_2F6:          /* address DABeeper */
    lea DABeeper,%a3
    moveb #47,%d6
FINDDITEM_2FE:          /* loop: addq */
    addql #4,%a3
    addqw #1,%d6
    cmpib #52,%d6
    jbeq FINDDITEM_2C2
    cmpb %a4@,%d6
    jbne FINDDITEM_2FE
    moveq #0,%d0
    movel %a3@,%d4
    jbeq FINDDITEM_31A
    moveal %d4,%a0
    _HLock
    moveal %a0@,%a0
    moveb %a0@+,%d0
FINDDITEM_31A:          /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a2,%sp@-
    movel %d3,%sp@-
    clrl %sp@-
    movel #2,%sp@-
    movel %a0,%sp@-
    movel %d0,%sp@-
    _Munger
    movel %sp@+,%d0
    tstl %d4
    jbeq FINDDITEM_2AE
    moveal %d4,%a0
    _HUnlock
    jbra FINDDITEM_2AE
FINDDITEM_33E:          /* from here: rorw #3,%d0 */
    rorw #3,%d0
    jbcs FINDDITEM_266
    roxrw #2,%d0
    jbcs FINDDITEM_362
    jbmi FINDDITEM_362
    roxrw #2,%d0
    jbpl FINDDITEM_35E
    _GetHandleSize
    tstl %d0
    jble FINDDITEM_35E
    rorl #7,%d0
    subqw #1,%d0
    jbeq FINDDITEM_35E
    movel %a0,%sp@-
    _DisposCIcon
FINDDITEM_35E:          /* loop: clr */
    clrl %a2@
    rts
FINDDITEM_362:          /* _DisposHandle */
    _DisposHandle
    jbra FINDDITEM_35E
    movel %a0,%sp@-
    _DisposControl
    bras FINDDITEM_35E
FINDDITEM_36C:          /* loop: movea */
    moveal %fp@(-74),%a0
    tstw %a0@(164)
    jbmi FINDDITEM_3D2
    movel %a0@(160),%sp@-
    movew %a0@(164),%sp@-
    movel %a0,%sp@-
    _SetPort
    movew %sp@+,%d0
    jbsr FINDDITEM_59C
    btst #0,%fp@(-61)
    jbeq FINDDITEM_394
    _TEActivate
    jbra FINDDITEM_396
FINDDITEM_394:          /* _TEDeactivate */
    _TEDeactivate
FINDDITEM_396:          /* call FINDDITEM_6C6 */
    jbsr FINDDITEM_6C6
    movel %a4,%sp@-
    _SetPort
    jbra FINDDITEM_3D2
FINDDITEM_3A0:          /* set %d0 */
    movew %fp@(-76),%d0
    subqw #1,%d0
    jbeq FINDDITEM_44A
    subqw #2,%d0
    jbeq FINDDITEM_3E4
    subqw #2,%d0
    jbeq FINDDITEM_3E4
    subqw #1,%d0
    jbeq FINDDITEM_3D6
    subqw #2,%d0
    jbeq FINDDITEM_36C
    tstw %a4@(164)
    jbmi FINDDITEM_3D2
    movew %a4@(164),%d0
    jbsr FINDDITEM_59C
    movel %a4@(160),%sp@-
    _TEIdle
    jbsr FINDDITEM_6C6
FINDDITEM_3D2:          /* loop: moveq */
    moveq #-1,%d3
    rts
FINDDITEM_3D6:          /* set up and call _BeginUpDate */
    movel %a4,%sp@-
    movel %sp@,%sp@-
    movel %sp@,%sp@-
    _BeginUpDate
    _DrawDialog
    _EndUpDate
    jbra FINDDITEM_3D2
FINDDITEM_3E4:          /* set %d1 */
    moveb %fp@(-71),%d1
    cmpib #9,%d1
    jbeq FINDDITEM_408
    movew %a4@(164),%d3
    jbmi FINDDITEM_3D2
    jbsr FINDDITEM_5AE
    movew %d1,%sp@-
    movel %a4@(160),%sp@-
    _TEKey
    jbsr FINDDITEM_6C6
    jbra FINDDITEM_4DA
FINDDITEM_408:          /* clear %d5 */
    clrw %d5
    movew %a4@(164),%d3
    jbsr FINDDITEM_774
FINDDITEM_412:          /* call FINDDITEM_76A (loop) */
    jbsr FINDDITEM_76A
    jbeq FINDDITEM_43A
    cmpw %a4@(164),%d3
    jbeq FINDDITEM_3D2
    btst #4,%a2@(12)
    jbeq FINDDITEM_412
    jbsr FINDDITEM_70A
    jbeq FINDDITEM_412
    movel #32767,%d2
    jbsr FINDDITEM_4E8
    jbra FINDDITEM_4DA
FINDDITEM_43A:          /* test %d5 */
    tstw %d5
    jbmi FINDDITEM_3D2
    moveq #-1,%d5
    moveq #-1,%d3
    tstw %a4@(164)
    jbpl FINDDITEM_412
    jbra FINDDITEM_3D2
FINDDITEM_44A:          /* set up and call _GlobalToLocal */
    movel %fp@(-66),%fp@(-28)
    pea %fp@(-28)
    _GlobalToLocal
    moveq #-1,%d3
FINDDITEM_458:          /* call FINDDITEM_76A (loop) */
    jbsr FINDDITEM_76A
    jbeq FINDDITEM_3D2
    subqw #2,%sp
    movel %fp@(-28),%sp@-
    pea %fp@(-40)
    _PtInRect
    tstb %sp@+
    jbeq FINDDITEM_458
    btst #2,%a2@(12)
    jbeq FINDDITEM_4A4
    subqw #2,%sp
    movel %fp@(-28),%sp@-
    movel %a4,%sp@-
    pea %fp@(-24)
    _FindControl
    movew %sp@+,%d0
    jbeq FINDDITEM_3D2
    subqw #2,%sp
    movel %fp@(-24),%sp@-
    movel %fp@(-28),%sp@-
    movel MinusOne,%sp@-
    _TrackControl
    tstw %sp@+
    jbeq FINDDITEM_3D2
    jbra FINDDITEM_4DA
FINDDITEM_4A4:          /* test bit 4 of %a2@(12) */
    btst #4,%a2@(12)
    jbeq FINDDITEM_4DA
    cmpw %a4@(164),%d3
    jbeq FINDDITEM_4B6
    moveq #0,%d2
    jbsr FINDDITEM_4E8
FINDDITEM_4B6:          /* test %a4@(164) */
    tstw %a4@(164)
    jbmi FINDDITEM_4DA
    movew %a4@(164),%d0
    jbsr FINDDITEM_59C
    movel %fp@(-28),%sp@-
    btst #1,%fp@(-62)
    sne %sp@-
    movel %a4@(160),%sp@-
    _TEClick
    jbsr FINDDITEM_6C6
FINDDITEM_4DA:          /* test bit 7 of %a2@(12) */
    btst #7,%a2@(12)
    jbne FINDDITEM_3D2
    addqw #1,%d3
    rts

FINDDITEM_4E8:          /* test %a4@(164) */
    tstw %a4@(164)
    jbmi FINDDITEM_518
    movew %a4@(164),%d0
    jbsr FINDDITEM_59C
    moveal %a4@(160),%a0
    moveal %a0@,%a0
    movel %a0@(8),%sp@-
    movel %a0@,%sp@-
    pea %sp@(4)
    _SubPt
    movel %a4@(160),%sp@-
    _TEScroll
    movel %a4@(160),%sp@-
    _TEDeactivate
    jbsr FINDDITEM_6C6
FINDDITEM_518:          /* call FINDDITEM_538 */
    jbsr FINDDITEM_538
    tstw %a4@(164)
    jbmi FINDDITEM_530
    movew %a4@(164),%d0
    jbsr FINDDITEM_59C
    movel %a4@(160),%sp@-
    _TEActivate
    jbsr FINDDITEM_6C6
FINDDITEM_530:          /* return */
    rts

FINDDITEM_532:          /* test %a4@(164),%d3 */
    cmpw %a4@(164),%d3
    jbeq FINDDITEM_530

FINDDITEM_538:          /* set %d0 */
    movel %a2@,%d0
    jble FINDDITEM_530
    movew %d3,%a4@(164)
    jbmi FINDDITEM_530
    moveal %a4@(160),%a0
    moveal %a0@,%a1
    movel %d0,%a1@(62)
    moveq #-2,%d0
    cmpl %d0,%d2
    jbeq FINDDITEM_556
    movel %d2,%a1@(32)
FINDDITEM_556:          /* address %a1@ */
    lea %a1@,%a0
    movel %fp@(-40),%a0@+
    movel %fp@(-36),%a0@+
    movel %fp@(-40),%a0@+
    movel %fp@(-36),%a0@+
    st %a1@(50)
    lea %a1@,%a0
    moveq #2,%d0
    addw %a0@+,%d0
    addw %a1@(24),%d0
    movew %a0@+,%d1
    cmpw %a0@+,%d0
    jblt FINDDITEM_586
    tstw TESysJust
    jbmi FINDDITEM_586
    subw %a0@,%d1
    subw %d1,%a0@
FINDDITEM_586:          /* call FINDDITEM_5AE */
    jbsr FINDDITEM_5AE
    st %sp@-
    movel %a4@(160),%sp@-
    _TEAutoView
    movel %a4@(160),%sp@-
    _TECalText
    jbsr FINDDITEM_6C6
    rts

FINDDITEM_59C:          /* set %sp@- */
    movel %d3,%sp@-
    movew %d0,%d3
    jbsr FINDDITEM_5AE
    movel %sp@+,%d3
    rts

FINDDITEM_5A6:          /* save registers */
    moveml %d0-%d5/%a0-%a2/%a4,%sp@-
    sf %d5
    jbra FINDDITEM_5B4

FINDDITEM_5AE:          /* save registers */
    moveml %d0-%d5/%a0-%a2/%a4,%sp@-
    st %d5
FINDDITEM_5B4:          /* call FINDDITEM_694 */
    jbsr FINDDITEM_694
    moveal %a5@,%a0
    moveal %a0@,%a4
    subqw #6,%sp
    movel %a4,%sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    movel %sp@+,%d0
    jbeq FINDDITEM_68E
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@(12),%d0
    jbeq FINDDITEM_68E
    moveal %d0,%a2
    moveal %a2@,%a0
    moveq #0,%d0
    lea %a0@(0x0,%d3:w:4),%a1
    movew %a1@,%d4
    addaw %a1@(2),%a0
    movel %a0,%sp@-
    bclr #15,%a1@
    jbeq FINDDITEM_606
    moveaw %a0@,%a1
    addal %a2@,%a1
    movel %a1,%sp@-
    movel %a0,%sp@-
    moveal %a2,%a0
    _HLock
    _GetFNum
    moveal %a2,%a0
    _HUnlock
    moveal %sp@,%a0
FINDDITEM_606:          /* set %a2 */
    moveal %a4@(160),%a2
    moveal %a2@,%a2
    movew %d4,%d3
    asrw #1,%d3
    jbcc FINDDITEM_61E
    movew %a0@,%a4@(68)
    tstb %d5
    jbeq FINDDITEM_61E
    movew %a0@,%a2@(74)
FINDDITEM_61E:          /* from here: asrw #1,%d3 */
    asrw #1,%d3
    jbcc FINDDITEM_632
    movew %a0@(2),%a4@(70)
    tstb %d5
    jbeq FINDDITEM_632
    movew %a0@(2),%a2@(76)
FINDDITEM_632:          /* test %a4@(74) */
    tstw %a4@(74)
    jbne FINDDITEM_63E
    moveb FMDefaultSize,%a4@(75)
FINDDITEM_63E:          /* test bit 4 of %d4 */
    btst #4,%d4
    jbne FINDDITEM_64C
    asrw #1,%d3
    jbcc FINDDITEM_65E
    clrw %a4@(74)
FINDDITEM_64C:          /* set %d0 */
    movew %a0@(4),%d0
    addw %d0,%a4@(74)
    tstb %d5
    jbeq FINDDITEM_65E
    movew %a4@(74),%a2@(80)
FINDDITEM_65E:          /* test bit 14 of %d4 */
    btst #14,%d4
    jbeq FINDDITEM_674
    movew %a0@(18),%a4@(72)
    tstb %d5
    jbeq FINDDITEM_674
    movew %a0@(18),%a2@(78)
FINDDITEM_674:          /* set up and call _RGBForeColor */
    asrw #1,%d3
    jbcc FINDDITEM_67E
    pea %a0@(6)
    _RGBForeColor
FINDDITEM_67E:          /* test bit 13 of %d4 */
    btst #13,%d4
    jbeq FINDDITEM_68C
    moveal %sp@,%a0
    pea %a0@(12)
    _RGBBackColor
FINDDITEM_68C:          /* add 4 to %sp */
    addqw #4,%sp
FINDDITEM_68E:          /* restore registers, return */
    moveml %sp@+,%d0-%d5/%a0-%a2/%a4
    rts

FINDDITEM_694:          /* set up and call _GetForeColor */
    pea %fp@(-96)
    _GetForeColor
    pea %fp@(-102)
    _GetBackColor
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(160),%d1
    lea %a0@(68),%a0
    lea %fp@(-118),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %d1,%a0
    moveal %a0@,%a0
    lea %a0@(74),%a0
    lea %fp@(-110),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    rts

FINDDITEM_6C6:          /* save registers */
    moveml %d0-%d2/%a0-%a1,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    moveal %a0@(160),%a0
    moveal %a0@,%a0
    lea %a0@(74),%a0
    lea %fp@(-110),%a1
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    subqw #8,%a1
    jbra FINDDITEM_6EC
FINDDITEM_6E4:          /* save registers */
    moveml %d0-%d2/%a0-%a1,%sp@-
    lea %fp@(-118),%a1
FINDDITEM_6EC:          /* set %a0 */
    moveal %a5@,%a0
    moveal %a0@,%a0
    lea %a0@(68),%a0
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    pea %fp@(-102)
    _RGBBackColor
    pea %fp@(-96)
    _RGBForeColor
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts

FINDDITEM_70A:          /* result 0 */
    moveq #0,%d0
    jbra FINDDITEM_714

FINDDITEM_70E:          /* set %d0 */
    movel #-196612,%d0
FINDDITEM_714:          /* set %sp@- */
    movel %a2@(8),%sp@-
    movel %a2@(4),%sp@-
    movel %sp,%sp@-
    movel %d0,%sp@-
    _InsetRect
    clrw %sp@-
    pea %sp@(2)
    pea %a4@(16)
    pea %sp@(10)
    _SectRect
    moveb %sp@+,%d0
    addqw #8,%sp
    rts

FINDDITEM_738:          /* set %sp@- */
    movel %a0,%sp@-
    movew %d2,%sp@-
    movew %d2,%sp@-
    movel %a0,%sp@-
    movew %d1,%sp@-
    movew %d1,%sp@-
    movel %a0,%sp@-
    negw %d2
    movew %d2,%sp@-
    movew %d2,%sp@-
    movew %d0,%sp@-
    movew %d0,%sp@-
    _PenSize
    _InsetRect
    _FrameRoundRect
    _InsetRect
    rts

FINDDITEM_75A:          /* set up and call _NewString */
    moveml %d0-%d2/%a1-%a2,%sp@-
    movel %a0,%sp@-
    _NewString
    moveal %sp@+,%a0
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts

FINDDITEM_76A:          /* add 1 to %d3 */
    addqw #1,%d3
    jbeq FINDDITEM_774
    movel %d2,%sp@-
    moveq #1,%d0
    jbra FINDDITEM_77C

FINDDITEM_774:          /* set %sp@- */
    movel %d2,%sp@-
    moveq #0,%d7
    movew %d3,%d0
    jblt FINDDITEM_78A
FINDDITEM_77C:          /* clear %d2 */
    moveq #0,%d2
    movel %a3,%d1
    jbeq FINDDITEM_78A
    moveal %a3@,%a2
    movew %a2@+,%d1
    cmpw %d3,%d1
    jbge FINDDITEM_79C
FINDDITEM_78A:          /* from here: subal %a2,%a2 */
    subal %a2,%a2
    jbra FINDDITEM_7A4
FINDDITEM_78E:          /* loop: move */
    moveb %a2@(0xd,%d7:w),%d2
    addw %d2,%d7
    addiw #15,%d7
    andiw #-2,%d7
FINDDITEM_79C:          /* count down */
    dbf %d0,FINDDITEM_78E
    addaw %d7,%a2
    jbsr FINDDITEM_7AA
FINDDITEM_7A4:          /* set %d2 */
    movel %sp@+,%d2
    movel %a2,%d0
    rts

FINDDITEM_7AA:          /* address %a2@(4) */
    lea %a2@(4),%a0
    lea %fp@(-40),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    rts

/* DMGREND: end of the Dialog Manager. */
DMGREND:
    .short  0x0000	| 4081AA0E
