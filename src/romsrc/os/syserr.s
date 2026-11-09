/*
 os/syserr.s - critical errors, system error handler, debugger entry, exception vectors
 From CRITERR (0x40802310). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 Low memory: 0xC30 the registers saved at the error (d0-a7, 64 bytes), 0xC70/0xC74
 PC and SR, 0xBFF "in the system error handler" flag, 0xC2C NMI flag, MacJmp the
 debugger, DSAlertTab the alert table ('DSAT'), 0xDB0 = 0x5A932BC7 when the video
 globals are valid.
*/

/*
 CRITERR: the "sad Mac" screen for a critical error (d7 = class, d6 = code): find the
 default video's 1-bit mode, switch to it with a black/white color table, paint the
 screen, draw the sad Mac icon in the centre and the two error codes in hexadecimal
 below it (built-in 3x5 digit font), then wait in the start-up test loop (TMRESTART).
 Without video: straight to TMRESTART.
*/
CRITERR:
    moveml %d0-%sp,SEVarBase
    cmpil #1519594439,VideoInfoOK
    jbne CRITERR_15E
    subqw #2,%sp
    moveal %sp,%a0
    _GetVideoDefault
    moveb %a0@+,%d0
    subaw #54,%sp
    moveal %sp,%a0
    moveb %d0,%a0@(49)
    clrw %a0@(50)
    movew #3,%a0@(40)
    movew #1,%a0@(42)
    movew #1,%a0@(44)
    moveb #1,%a0@(48)
    moveq #21,%d0	/* _SlotManager 21: NEXTTYPESRSRC, sNextTypesRsrc */
    _SlotManager
    jbne CRITERR_76
    movel %a0@(4),%sp@-
    movew #128,%d3
CRITERR_4E:             /* next video mode: 1 bit per pixel? */
    moveb %d3,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne CRITERR_74
    moveb #1,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    moveal %a0@,%a1
    cmpiw #1,%a1@(32)
    jbeq CRITERR_7E
    addqw #1,%d3
    movel %sp@,%a0@(4)
    jbra CRITERR_4E
CRITERR_74:             /* none found */
    addqw #4,%sp
CRITERR_76:             /* give up the video */
    lea %sp@(56),%sp
    jbra CRITERR_15E
CRITERR_7E:             /* SetMode to it, SetEntries black and white */
    subaw #16,%sp
    lea %sp@(64),%a0
    movew %d3,%a0@
    clrl %a0@(2)
    clrw %a0@(6)
    movel %a0,%sp@(28)
    moveal %sp,%a0
    clrl %a0@(12)
    clrw %a0@(22)
    moveal DeviceList,%a2
    moveal %a2@,%a2
    movew %a2@,%a0@(24)
    movew #2,%a0@(26)
    _Control
    moveal %a0@(28),%a2
    lea %pc@(CRITERR_168),%a3
    movel %a3,%a2@
    clrw %a2@(4)
    movew #1,%a2@(6)
    movew #3,%a0@(26)
    _Control
    lea %sp@(76),%sp
    movew %a1@(10),%sp@-
    movew %a1@(12),%d1
    movew %a1@(4),%d2
    moveal %a1,%a0
    _DisposPtr
    movew %sp@+,%d0
    moveal ScrnBase,%a2
    movel ScreenBytes,%d3
    moveml %d0-%d1/%a2,%sp@-
    lsrw #1,%d0
CRITERR_F0:             /* icon position, centre of the screen */
    subiw #22,%d0
    bset #0,%d0
    muluw %d2,%d0
    addal %d0,%a2
    lsrw #4,%d1
    subqw #2,%d1
    addaw %d1,%a2
    movel %a2,IconTLAddr
    moveml %sp@+,%d0-%d1/%a2
    moveal %a2,%a3
    lsrw #1,%d0
    muluw %d2,%d0
    addal %d0,%a3
    lsrw #4,%d1
    addaw %d1,%a3
    lsrl #2,%d3
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    moveq #-1,%d0
CRITERR_120:            /* paint the screen (32-bit mode) */
    movel %d0,%a2@+
    subql #1,%d3
    jbhi CRITERR_120
    moveb %sp@+,%d0
    _SwapMMUMode
    moveal %a3,%a2
    moveq #24,%d0
    muluw %d2,%d0
    addal %d0,%a2
    subqw #4,%a2
    movel %d7,%d0
    moveq #7,%d4
    lea %pc@(CRITERR_140),%fp
    jmp %pc@(CRITERR_178)
CRITERR_140:            /* draw the icon and the codes */
    moveal %a3,%a2	| 40802450
    moveq #36,%d0	| 40802452
    muluw %d2,%d0	| 40802454
    addal %d0,%a2	| 40802456
    subqw #4,%a2	| 40802458
    movel %d6,%d0	| 4080245A
    moveq #7,%d4	| 4080245C
    lea %pc@(CRITERR_156),%fp	| 4080245E
    jmp %pc@(CRITERR_178)	| 40802462
CRITERR_156:            /* (data) */
    .byte   0x4D, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x00, 0x92	| 40802466
CRITERR_15E:            /* the test manager's restart (TMRESTART) */
    bigjmp TMRESTART
CRITERR_168:            /* (color table: black, white) */
    .long   0x0000FFFF, 0xFFFFFFFF	| 40802478
    .long   0x00000000, 0x00000000	| 40802480
CRITERR_178:            /* draw the 8 hex digits of d0 at a2 with the 3x5 font */
    moveq #1,%d1
    exg %d1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    exg %d1,%d0
CRITERR_182:            /* next digit */
    roll #4,%d0
    moveq #15,%d5
    andb %d0,%d5
    muluw #3,%d5
    lea %pc@(CRITERR_1BE,%d5:w),%a1
    moveq #-61,%d1
    moveq #2,%d3
CRITERR_194:            /* draw its rows (doubled pixels) */
    moveb %a1@,%d5
    lsrw #2,%d5
    orw %d1,%d5
    moveb %d5,%a2@
    addaw %d2,%a2
    moveb %a1@+,%d5
    lslw #2,%d5
    orw %d1,%d5
    moveb %d5,%a2@
    addaw %d2,%a2
    dbf %d3,CRITERR_194
    moveq #6,%d1
    muluw %d2,%d1
    subal %d1,%a2
    addqw #1,%a2
    dbf %d4,CRITERR_182
    moveb %sp@+,%d0
    _SwapMMUMode
    jmp %fp@
CRITERR_1BE:            /* the digit font: 3 bytes per digit 0-F */
    .short  0x9642	| 408024CE
    .long   0x69B3BBB1, 0x96EDB00E, 0x9E696660, 0xEE071E69	| 408024D0
    .long   0x8716690E, 0xDDBB9696, 0x699668E1, 0x96606616	| 408024E0
    .long   0x16618777, 0x78166661, 0x07177007, 0x177741FA	| 408024F0
    .long   0x00622478, 0x0DAC7001, 0xA05D1F00, 0x7206C2C2	| 40802500
    .long   0xD5C15942, 0x721F24D8, 0xD4C251C9, 0xFFFA101F	| 40802510
    .long   0xA05D4ED6	| 40802520

/*
 PUTICON: draw a packed 32x32 icon (a4) at a2, then XOR it down 30 more rows (sad Mac
 drawing). Returns through fp.
*/
trap_PutIcon:
PUTICON:
    moveq #15,%d3
    moveal %a2,%a0
    moveq #3,%d2
PUTICON_6:              /* next row: mask byte */
    movew #256,%d4
    moveb %a4@+,%d4
PUTICON_C:              /* each byte: from the data or zero */
    lsrw #1,%d4
    jbeq PUTICON_26
    jbcc PUTICON_16
    clrb %a2@+
    jbra PUTICON_18
PUTICON_16:             /* data byte */
    moveb %a4@+,%a2@+
PUTICON_18:             /* (next) */
    dbf %d2,PUTICON_C
    addaw ScreenRow,%a2
    subqw #4,%a2
    moveq #3,%d2
    jbra PUTICON_C
PUTICON_26:             /* next row */
    dbf %d3,PUTICON_6
    moveal %a0,%a1
    moveq #30,%d3
PUTICON_2E:             /* XOR down */
    addaw ScreenRow,%a1
    movel %a0@,%d4
    eorl %d4,%a1@
    moveal %a1,%a0
    dbf %d3,PUTICON_2E
    jmp %fp@
    .byte   0xFF, 0xFF, 0xFF, 0xFF, 0xF8, 0x00, 0x00, 0x3F, 0xF0, 0x00, 0x00, 0x1F, 0xF1, 0xFF, 0xFF, 0x1F	| 40802562
    .byte   0xF2, 0x00, 0x00, 0x9F, 0xF2, 0x00, 0x00, 0x9F, 0xF2, 0x28, 0x28, 0x9F, 0xF2, 0x10, 0x10, 0x9F	| 40802572
    .byte   0xF2, 0x28, 0x28, 0x9F, 0xF2, 0x00, 0x00, 0x9F, 0xF2, 0x04, 0x80, 0x9F, 0xF2, 0x03, 0x00, 0x9F	| 40802582
    .byte   0xF2, 0x00, 0x00, 0x9F, 0xF2, 0x0F, 0xC0, 0x9F, 0xF2, 0x10, 0x30, 0x9F, 0xF2, 0x00, 0x08, 0x9F	| 40802592
    .byte   0xF2, 0x00, 0x00, 0x9F, 0xF1, 0xFF, 0xFF, 0x1F, 0xF0, 0x00, 0x00, 0x1F, 0xF0, 0x00	| 408025A2
    .short  0x001F, 0xF000	| 408025B0 orib #0,%sp@+
    .short  0x001F, 0xF000	| 408025B4 orib #0,%sp@+
    .short  0x001F, 0xF300	| 408025B8 orib #0,%sp@+
    moveb %sp@+,%sp@(0,%sp:w)	| 408025BC
    .short  0x001F, 0xF000	| 408025C0 orib #0,%sp@+
    .short  0x001F, 0xF000	| 408025C4 orib #0,%sp@+
    .short  0x001F, 0xF000	| 408025C8 orib #0,%sp@+
    orib #-1,%sp@+	| 408025CC
    .byte   0xFF, 0xFF, 0xF8, 0x00, 0x00, 0x3F, 0xF8, 0x00, 0x00, 0x3F, 0xF8, 0x00, 0x00, 0x3F, 0xFF, 0xFF	| 408025D0
    .byte   0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408025E0

/*
 SYSERRINIT: exception vectors: VBR 0, vectors 2..11 to GENEXCPS (each its own entry),
 the rest to the general handler, interrupt autovectors to IRQEXCEPTION, NMI to
 NMIEXCP; clear the saved registers and the debugger. Returns through fp.
*/
SYSERRINIT:
    subal %a0,%a0
    movel %a0,%d0
    movec %d0,%vbr
    addqw #8,%a0
    lea %pc@(GENEXCPS),%a1
    moveq #9,%d0
SYSERRINIT_10:          /* vectors 2-11 */
    movel %a1,%a0@+
    addqw #2,%a1
    dbf %d0,SYSERRINIT_10
    moveq #12,%d0
SYSERRINIT_1A:          /* vectors 12-24 */
    movel %a1,%a0@+
    dbf %d0,SYSERRINIT_1A
    lea %pc@(IRQEXCEPTION),%a2
    moveq #5,%d0
SYSERRINIT_26:          /* spurious and autovectors 1-6 */
    movel %a2,%a0@+
    dbf %d0,SYSERRINIT_26
    lea %pc@(NMIEXCP),%a2
    movel %a2,%a0@+
    moveq #31,%d0
SYSERRINIT_34:          /* traps and the rest */
    movel %a1,%a0@+
    dbf %d0,SYSERRINIT_34
    clrb NMIFlag
    lea SEVarBase,%a0
    moveq #31,%d0
SYSERRINIT_44:          /* clear the save area */
    clrl %a0@+
    dbf %d0,SYSERRINIT_44
    clrl MacJmp
    clrb 0xbff
    jmp %fp@
    .long   0x00000000, 0x00000000, 0x00000000	| 40802644

/*
 DEBUGGER: _Debugger / DebugStr: enter the installed debugger (MacJmp) with the
 registers saved; -8 if there is none.
*/
DEBUGGER:
    moveml %d0-%sp,SEVarBase	| 40802650
    bset #7,0xbff
    linkw %fp,#0
    lea %fp@(8),%a0
    movew %a0@+,%d0
    movew %a0@+,0xc7a
    jbsr DEBUGPROLOG
    jble DEBUGGER_3C
    bset #15,%d0
    jsr %a1@
DEBUGGER_24:            /* back: restore the registers, pop the parameters */
    unlk %fp
    moveml SEVarBase,%d0-%sp
    moveal %sp@+,%a0
    addaw 0xc7a,%sp
    addql #4,%sp
    bclr #7,0xbff
    jmp %a0@
DEBUGGER_3C:            /* no debugger */
    moveq #-8,%d0
    jbra DEBUGGER_24

/* DEBUGPROLOG: a1 = the debugger, flags in d3 (N: in the error handler). */
DEBUGPROLOG:
    moveal MacJmp,%a1
    moveb 0xbff,%d3
    addb %d3,%d3
    rts
    .long   0x00000000	| 4080269C

/*
 TODEEPSHIT: an exception with no handler: save the registers, compute the exception
 number from the GENEXCPS entry used, save the access address (68000 bus/address
 error) and SR/PC, then the system error (d0 = the vector number: 1 bus error...).
*/
TODEEPSHIT:
    movew #9984,%sr
    tstb 0xbff
    jbmi TODEEPSHIT_10
    moveml %d0-%sp,SEVarBase
TODEEPSHIT_10:          /* which entry? */
    lea %pc@(GENEXCPS),%a0
    movel %sp@+,%d0
    subl %a0,%d0
    lsrw #1,%d0
    tstb CPUFlag
    jbne TODEEPSHIT_2E
    cmpiw #2,%d0
    jbgt TODEEPSHIT_2E
    movel %sp@+,0xc7c
    movel %sp@+,0xc80
TODEEPSHIT_2E:          /* save SR, PC */
    tstb 0xbff
    jbmi TODEEPSHIT_3E
    movew %sp@+,0xc74
    movel %sp@+,0xc70
    jbra SYSERR2
TODEEPSHIT_3E:          /* (nested: drop them) */
    addqw #6,%sp
    jbra SYSERR2
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408026E2

/* GENEXCPS: one jbsr per exception vector (the return address tells which). */
GENEXCPS:
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT
    jbsr TODEEPSHIT

/* IRQEXCEPTION: unexpected interrupt. */
IRQEXCEPTION:
    jbsr TODEEPSHIT

/* NMIEXCP: NMI (interrupt switch): the debugger the first time, else rte. */
NMIEXCP:
    bset #7,NMIFlag
    jbeq IRQEXCEPTION
    rte
    .long   0x00000000, 0x00000000, 0x00000000	| 40802714

/*
 _SysError(d0): system error: save the registers, enter the debugger if installed, else
 DSERRORHANDLER (the alert). Error 13 (NMI) goes to the debugger or the mini-debugger;
 a parity error (with SEPARITYPATCH) becomes error 101 and forces a cold restart.
*/
trap_SysError:
SYSTEMERROR:
    moveml %d0-%sp,SEVarBase
SYSERR1:                /* save SR, PC (68020+: format word) */
    movew %sr,0xc74
    movel %sp@+,0xc70
    tstb CPUFlag
    jbeq SYSERR2
    clrw %sp@-
SYSERR2:                /* (from the exceptions) */
    tstb 0xbff
    jbmi SYSERR2_A
    movel %sp,0xc6c
SYSERR2_A:              /* in the handler now */
    bset #7,0xbff
    cmpiw #13,%d0
    jbne SYSERR2_50
    jbsr SEPARITYPATCH
    jbeq SYSERR2_50
    jbra SYSERR2_3C
    .short  0x5357, 0x4321, 0x5357, 0x4321, 0x5357	| 40802756
    .long   0x43215357, 0x43215357, 0x43215357, 0x43215357	| 40802760
    .short  0x4321	| 40802770
SYSERR2_3C:             /* parity error: cold start next time */
    moveq #1,%d0
    _SwapMMUMode
    moveal 0xddc,%a1
    clrl %a1@(-4)
    _SwapMMUMode
    clrl WarmStart
    moveq #101,%d0
SYSERR2_50:             /* DSErrCode, debugger? */
    movew %d0,DSErrCode
    jbsr DEBUGPROLOG
    jbpl SYSERR2_5C
    jbne SYSERR2_6A
SYSERR2_5C:             /* no debugger: 13 goes to the mini-debugger */
    cmpiw #13,%d0
    jbne SYSERR2_66
    moveq #0,%d0
    jbra SYSERR2_6A
SYSERR2_66:             /* the alert handler */
    lea %pc@(DSERRORHANDLER),%a1
SYSERR2_6A:             /* call it, back: restore and rte */
    movel %a1,%d1
    jbeq SYSERR2_66
    jsr %a1@
    tstw %d0
    jbne SYSERR2_66
    bclr #7,0xbff
    moveml SEVarBase,%d0-%sp
    movel 0xc70,%sp@-
    movew 0xc74,%sp@-
    rte

/*
 ALLOCFAKERGNS: regions for the alert port without the Memory Manager: fake region
 handles pointing at Scratch20 and the saved low memory.
*/
ALLOCFAKERGNS:
    lea %fp@(24),%a1
    lea %fp@(108),%a0
    movel %a0,%a1@+
    addqw #4,%a0
    movel %a0,%a1@+
    lea Scratch20,%a1
    movel %a1,%a0@
    movel %a1,%a0@-

ALLOCFAKERGNS_16:       /* restore the 10 bytes of low memory at 0x1E4 */
    lea %pc@(ALLOCFAKERGNS_30),%a0
    lea 0x1ee,%a1
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    movew %a0@-,%a1@-
    rts
    .short  0x000A, 0x8001, 0x8001, 0x7FFF, 0x7FFF	| 408027E6
ALLOCFAKERGNS_30:       /* save them (and set up the port rectangle) */
    lea DispatchTab,%a0
    lea 0x1ee,%a1
    movel %a0@-,%a1@-
    movel %a0@-,%a1@-
    movel %a1,%sp@-
    .short  0x0891	| 408027FE

ALLOCFAKERGNS_40:       /* OffsetRect */
    .short  0x0007, 0x2055	| orib #85,%d7
    moveal %a0@,%a0
    movel %a0@(8),%sp@-
    _OffsetRect
    rts

/*
 DSERRORHANDLER: the system error alert: QuickDraw in a private port, the alert from
 DSAlertTab (text, icon, procedure, buttons) for DSErrCode, the buttons tracked with the
 mouse; resume through ResumeProc or restart. No alert table: CRITERR (d7 = 15).
*/
DSERRORHANDLER:
    movew #9472,%sr
    moveq #0,%d6
    movew DSErrCode,%d6
    movel DSAlertTab,%d7
    jbne DSERRORHANDLER_1C
    moveq #15,%d7
    bigjmp CRITERR
DSERRORHANDLER_1C:      /* the port, InitGraf (keeping QDExist), regions */
    movew #8192,%sr
    movew CurMap,%sp@-
    movew SysMap,CurMap
    lea %sp@(-4),%a5
    subaw #346,%sp
    moveal %sp,%fp
    pea %a5@(-4)
    moveb QDExist,%d3
    _InitGraf
    moveb %d3,QDExist
    jbsr ALLOCFAKERGNS
    movel %fp,%sp@-
    _InitPort
    movew %d6,%d0
    jbmi DSERRORHANDLER_5A
    cmpiw #13,%d0
    jbeq DSERRORHANDLER_27E
    jbsr DSERRORHANDLER_142
DSERRORHANDLER_5A:      /* (alert already drawn: move the port) */
    tstb DSAlertRect
    jbpl DSERRORHANDLER_66
    movel DSCtrAdj,%sp@-
    _MovePortTo
DSERRORHANDLER_66:      /* the definition of this error (or the default) */
    jbsr ALLOCFAKERGNS_30
    movew %d6,%d0
    bsrw DSERRORHANDLER_EE
    jbne DSERRORHANDLER_76
    moveal %d7,%a0
    addqw #6,%a0
DSERRORHANDLER_76:      /* two text items */
    moveal %a0,%a3
    jbsr DSERRORHANDLER_10A
    jbsr DSERRORHANDLER_10A
    movew %a3@+,%d0
    jbeq DSERRORHANDLER_BC
    jbsr DSERRORHANDLER_EE
    jbeq DSERRORHANDLER_BC
    cmpiw #30,DSErrCode
    jbcs DSERRORHANDLER_AE
    moveal %a0,%a2
    subqw #4,%sp
    movew %a2@(-4),%sp@-
    _GetCIcon
    tstl %sp@
    jbeq DSERRORHANDLER_AA
    movel %a2,%sp@-
    movel %sp@(4),%sp@-
    _PlotCIcon
    _DisposCIcon
    jbra DSERRORHANDLER_BC
DSERRORHANDLER_AA:      /* no color icon */
    addqw #4,%sp
    moveal %a2,%a0
DSERRORHANDLER_AE:      /* PlotIcon */
    pea %a0@(8)
    movel %a0,%sp@-
    pea %sp@(4)
    _PlotIcon
    addqw #4,%sp
DSERRORHANDLER_BC:      /* procedure item */
    movew %a3@+,%d0
    jbeq DSERRORHANDLER_C6
    jbsr DSERRORHANDLER_EE
    jbeq DSERRORHANDLER_C6
    jsr %a0@
DSERRORHANDLER_C6:      /* buttons (with Resume if ResumeProc) */
    movew %a3@+,%d0
    jbeq DSERRORHANDLER_DE
    tstl ResumeProc
    jbeq DSERRORHANDLER_D2
    addqw #1,%d0
DSERRORHANDLER_D2:      /* draw and track them */
    jbsr DSERRORHANDLER_1DE
    jbeq DSERRORHANDLER_DE
    movel %a0,%sp@-
    jbra ALLOCFAKERGNS_16

DSERRORHANDLER_DE:      /* done: restore, 0 */
    jbsr ALLOCFAKERGNS_16
    lea %sp@(346),%sp
    movew %sp@+,CurMap
    moveq #0,%d0
    rts

DSERRORHANDLER_EE:      /* find item d0 in the alert table. Out: a0, Z clear if found */
    moveal %d7,%a0
    movew %a0@+,%d1
    jbra DSERRORHANDLER_FA
DSERRORHANDLER_F4:      /* next item */
    cmpw %a0@+,%d0
    jbeq DSERRORHANDLER_104
    addaw %a0@+,%a0
DSERRORHANDLER_FA:      /* (count) */
    dbf %d1,DSERRORHANDLER_F4
    subal %a0,%a0
    moveq #0,%d0
    rts
DSERRORHANDLER_104:     /* found */
    addqw #2,%a0
    moveq #-1,%d0
    rts
DSERRORHANDLER_10A:     /* draw a text item: lines separated by '/' */
    movew %a3@+,%d0
    jbeq DSERRORHANDLER_140
    jbsr DSERRORHANDLER_EE
    jbeq DSERRORHANDLER_140
    movel %a0@+,%d3
    moveal %a0,%a2
DSERRORHANDLER_116:     /* find the end of the line */
    moveb %a2@+,%d0
    jbeq DSERRORHANDLER_120
    cmpib #47,%d0
    jbne DSERRORHANDLER_116
DSERRORHANDLER_120:     /* MoveTo, DrawText, next line 14 pixels down */
    moveb %d0,%sp@-
    movel %a2,%d0
    subl %a0,%d0
    subqw #1,%d0
    movel %a0,%sp@-
    clrw %sp@-
    movew %d0,%sp@-
    movel %d3,%sp@-
    _MoveTo
    _DrawText
    addil #917504,%d3
    moveal %a2,%a0
    moveb %sp@+,%d0
    jbne DSERRORHANDLER_116
DSERRORHANDLER_140:     /* return */
    rts
DSERRORHANDLER_142:     /* draw the alert box (DSDrawProc if installed) */
    movel DSDrawProc,%d0
    jble DSERRORHANDLER_152
    movel %d0,%sp@-
    bset #7,DSDrawProc
    rts
DSERRORHANDLER_152:     /* (box position known?) */
    lea DSAlertRect,%a0
    tstb %a0@
    jbpl DSERRORHANDLER_1A8
DSERRORHANDLER_15A:     /* alert rectangle centred on the screen (448 wide, 126 high) */
    moveml %d1/%a1,%sp@-
    moveal %a5@,%a1
    lea %a1@(-112),%a1
    moveq #100,%d0
    muluw %a1@+,%d0
    divuw #534,%d0
    movew %d0,%a0@
    moveq #-64,%d1
    addw %d0,%d1
    movew %d1,DSCtrAdj
    addiw #126,%d0
    movew %d0,%a0@(4)
    movew %a1@,%d0
    lsrw #1,%d0
    subiw #224,%d0
    movew %d0,%a0@(2)
    moveq #-32,%d1
    addw %d0,%d1
    movew %d1,0xdaa
    addiw #448,%d0
    movew %d0,%a0@(6)
    jbsr DSERRORHANDLER_1B2
    bset #7,DSAlertRect
    moveml %sp@+,%d1/%a1
    rts
DSERRORHANDLER_1A8:     /* (move the port there) */
    jbsr DSERRORHANDLER_1B2
    movel DSAlertRect,%sp@-
    _MovePortTo
    rts

DSERRORHANDLER_1B2:     /* erase it, double frame */
    movel %a0,%sp@-
    movel %a0,%sp@-
    movel %a0,%sp@-
    movel %a0,%sp@-
    movel %a0,%sp@-
    _EraseRect
    _FrameRect
    movel #131074,%sp@-
    _PenSize
    movel #196611,%sp@-
    _InsetRect
    _FrameRect
    movel #-131075,%sp@-
    _InsetRect
    _PenNormal
DSERRORHANDLER_1DC:     /* return */
    rts

DSERRORHANDLER_1DE:     /* draw the buttons, track the mouse until one is clicked */
    jbsr DSERRORHANDLER_EE
    jbeq DSERRORHANDLER_1DC
    moveal %a0,%a2
    movew %a0@+,%d3
    moveal %a0,%a3
DSERRORHANDLER_1EA:     /* one button: its title and rounded frame */
    movel %a3@(2),%sp@-
    addil #917508,%sp@
    _MoveTo
    movew %a3@+,%d0
    jbsr DSERRORHANDLER_EE
    subqw #1,%a0
    movel %a0,%sp@-
    _DrawString
    movel %a3,%sp@-
    movel #1048592,%sp@-
    _FrameRoundRect
    lea %a3@(10),%a3
    subqw #1,%d3
    jbne DSERRORHANDLER_1EA
    moveal %a5@,%a0
    pea %a0@(-108)
    _SetCursor
    _ShowCursor
    movew #8192,%sr
    st CrsrCouple
    clrb VBLQueue
DSERRORHANDLER_22A:     /* wait for a click */
    tstb MBState
    jbne DSERRORHANDLER_22A
    moveal %a2,%a3
    movew %a3@+,%d3
    addqw #2,%a3
DSERRORHANDLER_236:     /* in a button? */
    jbsr DSERRORHANDLER_260
    jbne DSERRORHANDLER_24A
    lea %a3@(12),%a3
    subqw #1,%d3
    jbne DSERRORHANDLER_236
    jbra DSERRORHANDLER_22A
DSERRORHANDLER_244:     /* track it while the button is down */
    jbsr DSERRORHANDLER_260
    cmpb %d0,%d3
    jbeq DSERRORHANDLER_24E
DSERRORHANDLER_24A:     /* highlight change */
    moveb %d0,%d3
    jbsr DSERRORHANDLER_272
DSERRORHANDLER_24E:     /* released: in the button? its procedure */
    tstb MBState
    jbeq DSERRORHANDLER_244
    tstb %d3
    jbeq DSERRORHANDLER_22A
    movew %a3@(8),%d0
    jbra DSERRORHANDLER_EE

DSERRORHANDLER_260:     /* mouse in the button rectangle a3? */
    subqw #2,%sp
    movel Mouse_v,%sp@-
    pea %sp@
    _GlobalToLocal
    movel %a3,%sp@-
    _PtInRect
    moveb %sp@+,%d0
    rts

DSERRORHANDLER_272:     /* invert the button */
    movel %a3,%sp@-
    movel #1048592,%sp@-
    _InverRoundRect
    rts
DSERRORHANDLER_27E:     /* error 13 without a debugger: the ROM mini-debugger (">" prompt): G (go) and expressions */
    clrw DSErrCode
    lea DSAlertRect,%a0
    jbsr DSERRORHANDLER_15A
    movel DSCtrAdj,%sp@-
    addil #4587558,%sp@
    _MovePortTo
    jbsr ALLOCFAKERGNS_30
    subaw #16,%sp
    clrw %d7
    clrl 0xca8
    clrl 0xcac
DSERRORHANDLER_2A8:     /* new command line */
    movel #1114544,%sp@-
    clrl %sp@-
    jbsr DSERRORHANDLER_3B8
    lea 0xca6,%fp
    moveq #0,%d6
DSERRORHANDLER_2BA:     /* clear the line buffer */
    movew #32,%fp@-
    addqw #2,%d6
    cmpiw #34,%d6
    jbne DSERRORHANDLER_2BA
    moveal %fp,%a4
    movel #983050,%sp@-
    _MoveTo
    moveq #62,%d0
    movew %d0,%sp@-
    _DrawChar
DSERRORHANDLER_2D6:     /* next key (GetOSEvent keyDown) */
    moveal %sp,%a0
    moveq #8,%d0
    _GetOSEvent
    jbne DSERRORHANDLER_2D6
    bclr #7,NMIFlag
    moveq #127,%d0
    andb %sp@(5),%d0
    cmpib #97,%d0
    jblt DSERRORHANDLER_2F4
    bclr #5,%d0
DSERRORHANDLER_2F4:     /* upper case, Return? */
    cmpib #13,%d0
    jbeq DSERRORHANDLER_346
    cmpib #8,%d0
    jbne DSERRORHANDLER_338
    cmpal %fp,%a4
    jbeq DSERRORHANDLER_2D6
    addqw #1,%d6
    subqw #1,%fp
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPen
    movel %sp@,%sp@-
    subqw #2,%sp
    moveb %fp@,%d0
    movew %d0,%sp@-
    _CharWidth
    movew %sp@+,%d3
    subw %d3,%sp@(2)
    clrw %sp@
    movel %sp,%sp@-
    clrw %sp@-
    movew #2,%sp@-
    _OffsetRect
    jbsr DSERRORHANDLER_3B8
    movew %d3,%sp@-
    negw %sp@
    clrw %sp@-
    _Move
    jbra DSERRORHANDLER_2D6
DSERRORHANDLER_338:     /* other key: add it */
    tstw %d6
    jbeq DSERRORHANDLER_2D6
    subqw #1,%d6
    moveb %d0,%fp@+
    movew %d0,%sp@-
    _DrawChar
    jbra DSERRORHANDLER_2D6
DSERRORHANDLER_346:     /* Return: the command letter, look it up */
    cmpal %a4,%fp
    jbne DSERRORHANDLER_34C
    movew %d7,%fp@+
DSERRORHANDLER_34C:     /* (command) */
    movew %a4@+,%d7
    lea %pc@(DSERRORHANDLER_37C),%a0
DSERRORHANDLER_352:     /* next command in the table */
    movew %a0@+,%d0
    jbmi DSERRORHANDLER_378
    movew %a0@+,%d2
    cmpib #64,%d0
    jbne DSERRORHANDLER_36C
    moveb %d7,%d0
    cmpib #48,%d0
    jbmi DSERRORHANDLER_352
    cmpib #55,%d0
    jbgt DSERRORHANDLER_352
DSERRORHANDLER_36C:     /* match: call it */
    cmpw %d0,%d7
    jbne DSERRORHANDLER_352
    lea %pc@(DSERRORHANDLER_37C),%a0
    jsr %a0@(0x0,%d2:w)
DSERRORHANDLER_378:     /* next line */
    jbra DSERRORHANDLER_2A8
DSERRORHANDLER_37C:     /* command table, then G: resume at the address typed (or where it stopped) */
    .short  0x4720, DSERRORHANDLER_39E-DSERRORHANDLER_37C	| 40802B8A
    .short  0x444D, DSERRORHANDLER_3C2-DSERRORHANDLER_37C	| 40802B8E
    .short  0x534D, DSERRORHANDLER_43E-DSERRORHANDLER_37C	| 40802B92
    .short  0x5444, DSERRORHANDLER_468-DSERRORHANDLER_37C	| 40802B96
    .short  0x4440, DSERRORHANDLER_474-DSERRORHANDLER_37C	| 40802B9A
    .short  0x4140, DSERRORHANDLER_47A-DSERRORHANDLER_37C	| 40802B9E
    .short  0x5043, DSERRORHANDLER_480-DSERRORHANDLER_37C	| 40802BA2
    .short  0x5352, DSERRORHANDLER_486-DSERRORHANDLER_37C	| 40802BA6
    .byte   0xFF, 0xFF	| 40802BAA
DSERRORHANDLER_39E:     /* call DSERRORHANDLER_4E4 */
    jbsr DSERRORHANDLER_4E4
    jbeq DSERRORHANDLER_3AC
    movel %d0,%sp@-
    jbsr ALLOCFAKERGNS_16
    rts
DSERRORHANDLER_3AC:     /* resume */
    lea %sp@(20),%sp
    clrb DSWndUpdate
    jbra DSERRORHANDLER_DE
DSERRORHANDLER_3B8:     /* erase the line rectangle */
    moveal %sp@+,%a2
    movel %sp,%sp@-
    _EraseRect
    addqw #8,%sp
    jmp %a2@
DSERRORHANDLER_3C2:     /* loop: move */
    movel #7340464,%sp@-	| 40802BD0
    clrl %sp@-	| 40802BD6
    jbsr DSERRORHANDLER_3B8	| 40802BD8
    jbsr DSERRORHANDLER_4DA	| 40802BDA
    bclr #0,%d0	| 40802BDE
    moveal %d0,%a3	| 40802BE2
    movel %d0,0xca8	| 40802BE4
    moveq #5,%d6	| 40802BE8
    moveq #15,%d5	| 40802BEA
DSERRORHANDLER_3DE:     /* loop: addi */
    addiw #15,%d5	| 40802BEC
    movew #10,%sp@-	| 40802BF0
    movew %d5,%sp@-	| 40802BF4
    _MoveTo	| 40802BF6
    movel %a3,%d0	| 40802BF8
    jbsr DSERRORHANDLER_40E	| 40802BFA
    moveq #7,%d4	| 40802BFC
    moveq #35,%d3	| 40802BFE
DSERRORHANDLER_3F2:     /* loop: addi */
    addiw #45,%d3	| 40802C00
    movew %d3,%sp@-	| 40802C04
    movew %d5,%sp@-	| 40802C06
    _MoveTo	| 40802C08
    movew %a3@+,%d0	| 40802C0A
    jbsr DSERRORHANDLER_414	| 40802C0C
    dbf %d4,DSERRORHANDLER_3F2	| 40802C0E
    dbf %d6,DSERRORHANDLER_3DE	| 40802C12
    movel %a3,0xcac	| 40802C16
    rts	| 40802C1A
DSERRORHANDLER_40E:     /* from here: swap %d0 */
    swap %d0	| 40802C1C
    jbsr DSERRORHANDLER_41C	| 40802C1E
    swap %d0	| 40802C20
DSERRORHANDLER_414:     /* loop: move */
    movew %d0,%sp@-	| 40802C22
    roxrw #8,%d0	| 40802C24
    jbsr DSERRORHANDLER_41C	| 40802C26
    movew %sp@+,%d0	| 40802C28
DSERRORHANDLER_41C:     /* set %sp@- */
    movew %d0,%sp@-	| 40802C2A
    rorw #4,%d0	| 40802C2C
    jbsr DSERRORHANDLER_424	| 40802C2E
    movew %sp@+,%d0	| 40802C30
DSERRORHANDLER_424:     /* from here: andib #15,%d0 */
    andib #15,%d0	| 40802C32
    orib #48,%d0	| 40802C36
    cmpib #57,%d0	| 40802C3A
    jble DSERRORHANDLER_434	| 40802C3E
    addqw #7,%d0	| 40802C40
DSERRORHANDLER_434:     /* set %sp@- */
    movel %d0,%sp@-	| 40802C42
    movew %d0,%sp@-	| 40802C44
    _DrawChar	| 40802C46
    movel %sp@+,%d0	| 40802C48
    rts	| 40802C4A
DSERRORHANDLER_43E:     /* call DSERRORHANDLER_4DA */
    jbsr DSERRORHANDLER_4DA	| 40802C4C
    moveal %d0,%a1	| 40802C50
    lea 0xca8,%a0	| 40802C52
    movel %d0,%a0@+	| 40802C56
    movel %d0,%a0@+	| 40802C58
    movew #17485,%d7	| 40802C5A
DSERRORHANDLER_450:     /* call DSERRORHANDLER_4E4 (loop) */
    jbsr DSERRORHANDLER_4E4	| 40802C5E
    jbeq DSERRORHANDLER_3C2	| 40802C62
    moveal %a1,%a2	| 40802C66
DSERRORHANDLER_45A:     /* (40802C68 moveb %d0,%a2@(ffffffffffffffff,%d1:w)) */
    moveb %d0,%a2@(-1,%d1:w)	| 40802C68
    asrl #8,%d0	| 40802C6C
    addql #1,%a1	| 40802C6E
    subql #1,%d1	| 40802C70
    jbne DSERRORHANDLER_45A	| 40802C72
    jbra DSERRORHANDLER_450	| 40802C74
DSERRORHANDLER_468:     /* set 0xcac */
    movel #3120,0xcac	| 40802C76
    jbra DSERRORHANDLER_3C2	| 40802C7E
DSERRORHANDLER_474:     /* address 0xc30 */
    lea SEVarBase,%a3	| 40802C82
    jbra DSERRORHANDLER_492	| 40802C86
DSERRORHANDLER_47A:     /* address 0xc50 */
    lea 0xc50,%a3	| 40802C88
    jbra DSERRORHANDLER_492	| 40802C8C
DSERRORHANDLER_480:     /* address 0xc70 */
    lea 0xc70,%a3	| 40802C8E
    jbra DSERRORHANDLER_498	| 40802C92
DSERRORHANDLER_486:     /* address 0xc74 */
    lea 0xc74,%a3	| 40802C94
    jbsr DSERRORHANDLER_4E4	| 40802C98
    jbeq DSERRORHANDLER_4A0	| 40802C9A
    movew %d0,%a3@	| 40802C9C
    rts	| 40802C9E
DSERRORHANDLER_492:     /* call DSERRORHANDLER_4C6 */
    jbsr DSERRORHANDLER_4C6	| 40802CA0
    lsll #2,%d0	| 40802CA2
    addal %d0,%a3	| 40802CA4
DSERRORHANDLER_498:     /* call DSERRORHANDLER_4E4 */
    jbsr DSERRORHANDLER_4E4	| 40802CA6
    jbeq DSERRORHANDLER_4A2	| 40802CA8
    movel %d0,%a3@	| 40802CAA
    rts	| 40802CAC
DSERRORHANDLER_4A0:     /* set %d6 */
    moveq #-1,%d6	| 40802CAE
DSERRORHANDLER_4A2:     /* set %sp@- */
    movel #7340464,%sp@-	| 40802CB0
    clrl %sp@-	| 40802CB6
    jbsr DSERRORHANDLER_3B8	| 40802CB8
    movel #3145744,%sp@-	| 40802CBC
    _MoveTo	| 40802CC2
    movew %a3@+,%d0	| 40802CC4
    tstw %d6	| 40802CC6
    jbne DSERRORHANDLER_4C2	| 40802CC8
    jbsr DSERRORHANDLER_414	| 40802CCA
    movew %a3@+,%d0	| 40802CCE
DSERRORHANDLER_4C2:     /* continue at DSERRORHANDLER_414 */
    jbra DSERRORHANDLER_414	| 40802CD0

DSERRORHANDLER_4C6:     /* hex digit value */
    andil #255,%d0
    cmpib #57,%d0
    jble DSERRORHANDLER_4D4
    subqb #7,%d0
DSERRORHANDLER_4D4:     /* from here: andib #15,%d0 */
    andib #15,%d0
    rts
DSERRORHANDLER_4DA:     /* call DSERRORHANDLER_4E4 */
    jbsr DSERRORHANDLER_4E4
    jbne DSERRORHANDLER_4E2
    movel 0xcac,%d0
DSERRORHANDLER_4E2:     /* return */
    rts

DSERRORHANDLER_4E4:     /* evaluate an expression: $hex, @ (indirect), +/-, '.', PC, RAn, RDn */
    moveq #0,%d4
    moveq #0,%d6
DSERRORHANDLER_4E8:     /* next term */
    moveq #0,%d5
    clrw 0xca6
    moveq #0,%d3
    moveq #0,%d0
    moveq #0,%d1
DSERRORHANDLER_4F4:     /* skip spaces */
    cmpal %fp,%a4
    bgew DSERRORHANDLER_53E
DSERRORHANDLER_4FA:     /* next character */
    moveb %a4@+,%d0
    cmpib #32,%d0
    jble DSERRORHANDLER_4F4
    cmpib #64,%d0
    jbne DSERRORHANDLER_50C
    addqw #1,%d3
    jbra DSERRORHANDLER_4FA
DSERRORHANDLER_50C:     /* '+' */
    cmpib #43,%d0
    jbeq DSERRORHANDLER_4FA
    cmpib #45,%d0
    jbne DSERRORHANDLER_51E
    notb 0xca6
    jbra DSERRORHANDLER_4FA
DSERRORHANDLER_51E:     /* '-': negate, '$': hex number */
    cmpib #36,%d0
    bnew DSERRORHANDLER_584
    moveq #0,%d0
    moveb %a4@+,%d0
DSERRORHANDLER_52A:     /* hex digits */
    jbsr DSERRORHANDLER_4C6
    addqw #1,%d5
    lsll #4,%d1
    addl %d0,%d1
    cmpal %fp,%a4
    jbge DSERRORHANDLER_53E
    moveb %a4@+,%d0
    cmpib #48,%d0
    jbge DSERRORHANDLER_52A
DSERRORHANDLER_53E:     /* indirections (@) */
    tstw %d3
    jbeq DSERRORHANDLER_550
    moveq #8,%d5
DSERRORHANDLER_544:     /* one level */
    bclr #0,%d1
    moveal %d1,%a0
    movel %a0@,%d1
    subqw #1,%d3
    jbne DSERRORHANDLER_544
DSERRORHANDLER_550:     /* sign */
    tstb 0xca6
    jbeq DSERRORHANDLER_558
    negl %d1
DSERRORHANDLER_558:     /* add the term, its size */
    addl %d1,%d4
    addqw #1,%d5
    lsrw #1,%d5
    cmpiw #4,%d5
    jble DSERRORHANDLER_566
    moveq #4,%d5
DSERRORHANDLER_566:     /* (at most a long) */
    cmpw %d6,%d5
    jble DSERRORHANDLER_56C
    movew %d5,%d6
DSERRORHANDLER_56C:     /* more terms? */
    cmpib #43,%d0
    jbeq DSERRORHANDLER_578
    cmpib #45,%d0
    jbne DSERRORHANDLER_57E
DSERRORHANDLER_578:     /* (next) */
    moveb %d0,%a4@-
    jbra DSERRORHANDLER_4E8
DSERRORHANDLER_57E:     /* result in d0, size in d1 */
    movel %d4,%d0
    movel %d6,%d1
    rts
DSERRORHANDLER_584:     /* '.': the last address */
    cmpib #46,%d0
    jbne DSERRORHANDLER_59A
    movel 0xca8,%d1
    moveq #1,%d2
DSERRORHANDLER_590:     /* skip the name */
    moveq #8,%d5
DSERRORHANDLER_592:     /* (skip) */
    moveb %a4@+,%d0
    subqw #1,%d2
    jbne DSERRORHANDLER_592
    jbra DSERRORHANDLER_53E
DSERRORHANDLER_59A:     /* 'PC' */
    movew %d0,%d2
    lslw #8,%d2
    moveb %a4@,%d2
    cmpiw #20547,%d2
    jbne DSERRORHANDLER_5AE
    movel 0xc70,%d1
    moveq #2,%d2
    jbra DSERRORHANDLER_590
DSERRORHANDLER_5AE:     /* 'RA' n */
    cmpib #82,%d0
    jbne DSERRORHANDLER_52A
    cmpib #65,%d2
    jbne DSERRORHANDLER_5E0
    lea 0xc50,%a0
DSERRORHANDLER_5C0:     /* register n of the saved set */
    moveq #0,%d2
    moveb %a4@(1),%d2
    subiw #48,%d2
    jbmi DSERRORHANDLER_52A
    cmpiw #7,%d2
    jbgt DSERRORHANDLER_52A
    lslw #2,%d2
    movel %a0@(0x0,%d2:w),%d1
    moveq #3,%d2
    jbra DSERRORHANDLER_590
DSERRORHANDLER_5E0:     /* 'RD' n */
    cmpib #68,%d2
    jbne DSERRORHANDLER_52A
    lea SEVarBase,%a0
    jbra DSERRORHANDLER_5C0
    .long   0x00000000	| 40802DFC
