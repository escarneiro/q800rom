/*
 boot/startutil.s - start-up support routines, 0x40800380..0x408007FF

 Patch space, then the small routines STARTINIT calls to set up low memory, the heaps
 and the CPU/board identification. Names in upper case are Apple's (MPW ROM map).
 ROUTINE_offset labels are positions inside an Apple routine. Labels referenced from
 data elsewhere in the ROM (or by .set lines in q800rom.s) keep their generated names.
*/

/*
 --------------------------------------------------------------------------------------
 Patch space: room for ROM patches, mostly zero. The .EDisk driver open patch is at
 its start.
*/
PATCHSPACE1:            /* EDISKPATCH2: open the .EDisk (RAM disk) driver, a0 = its parameter block */
EDISKPATCH2:
    lea     %pc@(edisk_name),%a1
    movel   %a1,%a0@(18)            /* ioNamePtr = ".EDisk" */
PATCHSPACE1_8:          /* _Open, then a1 = the sound driver name for the next open */
    _Open
    lea     %pc@(SNDNAME),%a1
    rts
edisk_name:             /* Pascal string ".EDisk" */
    .byte   6
    .ascii  ".EDisk\000"
    .fill   0x28, 1, 0x00
PATCHSPACE1_40:         /* unused patch space (zeros) */
    .fill   0xB0, 1, 0x00

/*
 --------------------------------------------------------------------------------------
 JMPTBLINIT: build a jump table. %a0 = table of 16-bit offsets (relative to the table),
 %a1 = destination, %d1 = number of entries - 1. JMPTBL2: same with base %d0.
*/
JMPTBLINIT:
    movel   %a0,%d0
JMPTBL2:                /* one entry: base + offset */
    moveq   #0,%d2
    movew   %a0@+,%d2
    addl    %d0,%d2
    movel   %d2,%a1@+
    dbf     %d1,JMPTBL2
NEWTRANSLATE24TO32:                 /* no-op 24-to-32-bit address translation */
    rts

/* FILLWITHONES: fill %a0..%a1 (longs) with 0xFFFFFFFF */
FILLWITHONES:
    movel   %a1,%d0
    subl    %a0,%d0
    lsrl    #2,%d0
    moveq   #-1,%d1
fwo_loop:               /* one long */
    movel   %d1,%a0@+
    subql   #1,%d0
    jbne    fwo_loop
    rts

/*
 COMPBOOTSTACK: %a0 = initial boot stack: halfway between the system heap and BufPtr,
 even, minus 1 KB
*/
COMPBOOTSTACK:
    movel   BufPtr,%d0
    addl    SysZone,%d0
    lsrl    #1,%d0
    bclr    #0,%d0
    subiw   #1024,%d0
    moveal  %d0,%a0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000

/*
 SETUPSYSAPPZONE: create the system heap (InitZone) and make it the application zone
 too; the application limit goes 8 KB below the boot stack
*/
SETUPSYSAPPZONE:
    lea     %pc@(sysheap_params),%a0
    moveb   0x1efc,%sp@-
    btst    #2,0x1efc
    jbeq    ssaz_clear
    bset    #0,0x1efc
    btst    #4,0x1efc
    jbeq    SETUPSYSAPPZONE_2A
    lea     %pc@(sysheap_params_alt),%a0
    jbra    SETUPSYSAPPZONE_2A
ssaz_clear:             /* else bit 0 cleared */
    bclr    #0,0x1efc
SETUPSYSAPPZONE_2A:     /* InitZone, SysZone = RAMBase = ApplZone = the new heap */
    _InitZone
    movel   TheZone,SysZone
    movel   SysZone,RAMBase
    moveal  SysZone,%a0
    movel   %a0,ApplZone
    moveal  %a0@,%a0
    movel   %a0,HeapEnd
    jbsr    COMPBOOTSTACK
    cmpal   %sp,%a0
    jbls    ssaz_limit
    moveal  %sp,%a0
ssaz_limit:             /* application limit 8 KB below the lower of the boot stack and sp */
    subaw   #0x2000,%a0
SETUPSYSAPPZONE_52:     /* SetApplLimit, then restore 0x1EFC */
    _SetApplLimit
    moveb   %sp@+,0x1efc
    rts
/* InitZone parameter blocks: start, limit, master pointer count, grow-zone procedure */
sysheap_params:         /* normal system heap: 0x2000..0x3800, 64 master pointers */
    .long   0x00002000, 0x00003800
    .short  0x0040
    .long   0
sysheap_params_alt:     /* system heap at 0x38000000 (0x1EFC bits 2 and 4 set) */
    .long   0x38000000, 0x38001800
    .short  0x0040
    .long   0
    .fill   10, 1, 0x00

/*
 DRAWBEEPSCREEN: QuickDraw set-up for the start-up screen; DRAWBEEPSCREENRETURN draws
 the rounded box (rectangle at %a0) through Scratch8
*/
DRAWBEEPSCREEN:
    pea     %a5@(-4)
    _InitGraf
    pea     %fp@(-512)
    _OpenCPort
    moveal  %a5@,%a2
    pea     %a2@(-108)
    _SetCursor
    bral    DRAWBEEPSCREENPATCH

DRAWBEEPSCREENRETURN:   /* address Scratch8 */
    lea     Scratch8,%a1
    movel   %a1,%sp@-
    movel   %a1,%sp@-
    movel   %a0@+,%a1@+
    movel   %a0@,%a1@
    movel   #0xFFFDFFFD,%sp@-       /* InsetRect -3, -3 */
    _InsetRect
    movel   #0x00030003,%sp@-       /* PenSize 3, 3 */
    _PenSize
    movel   #0x00160016,%sp@-       /* corner ovals 22 x 22 */
    _FrameRoundRect
    _PenNormal
    movel   #0x00100010,%sp@-       /* corner ovals 16 x 16 */
    pea     %a2@(-24)
    _FillRoundRect
    rts
    .short  0x0000

INITSHUTDOWNMGR:        /* ShutDown(0): initialise the Shutdown Manager queue */
    clrw    %sp@-
    _ShutDown
    rts
    .short  0x0000
INITSHUTDOWNMGR_8:      /* unused (zeros) */
    .long   0x00000000, 0x00000000

/*
 INITHIMEMGLOBALS: globals at the top of RAM: sound and PWM buffers below BufPtr,
 application memory below 8 MB on machines that need it (MMUCLEANUPFOR8MB)
*/
INITHIMEMGLOBALS:
    movew   #-1,PWMValue
    moveal  BufPtr,%a0
    moveal  MemTop,%a1
INITHIMEMGLOBALS_E:     /* 0x1EF8 = top of RAM, 0x1EF4 = BufPtr before the buffers */
    movel   %a1,0x1ef8
    movel   %a0,0x1ef4
/*
 movel @(0xddc)@(-24),0x1ef0 and btst #0,@(0xddc)@(-25): 68020 memory-indirect
 addressing, encoded here exactly as in the ROM
*/
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    movel @(0xddc,%za0)@(0xffffffffffffffe8),0x1ef0	| 408005A6
    moveq   #0,%d1
    btst #0,@(0xddc,%za0)@(0xffffffffffffffe7)	| 408005B2
    jbne    ihmg_buffers
    movel   #0x00800000,%d0         /* 8 MB */
    cmpal   %d0,%a0
    jbls    ihmg_check
    moveal  %d0,%a0
    moveal  %d0,%a1
ihmg_check:             /* RAM above 8 MB (boot globals above it): MMU clean-up needed (d1 = 1) */
    cmpl    0xddc,%d0
    jbgt    ihmg_buffers
    moveq   #1,%d1
ihmg_buffers:           /* PWM (sound) buffer, 767 bytes below BufPtr */
    subaw   #767,%a0
    movel   %a0,PWMBuf1
    movel   %a0,PWMBuf2
    subqw   #1,%a0
INITHIMEMGLOBALS_52:    /* SoundBase, and BufPtr at most 8 KB below the top */
    movel   %a0,SoundBase
    subaw   #0x2000,%a1
    cmpal   %a1,%a0
    jbls    ihmg_bufptr
    moveal  %a1,%a0
ihmg_bufptr:            /* new BufPtr */
    movel   %a0,BufPtr
    tstl    %d1
    jbeq    INITHIMEMGLOBALS_6C
    jbsr    MMUCLEANUPFOR8MB
INITHIMEMGLOBALS_6C:    /* done */
    rts
    nop

/* INITGLOBALVARS: initial values of the low-memory globals */
INITGLOBALVARS:
    lea     %pc@(MYFIRSTPROC),%a0
    movel   %a0,ROMBase
    moveq   #-1,%d0
    movel   %d0,SMGlobals
    moveal  0xdd8,%a0
    movew   %a0@(20),ROM85
    nop
INITGLOBALVARS_1A:      /* OneOne, MinusOne, FSFCBLen, hardware bases, PollProc, DSAlertTab */
    nop
    nop
    movel   #0x00010001,OneOne
    moveq   #-1,%d0
    movel   %d0,MinusOne
    movew   %d0,FSFCBLen
    jbsr    SETUPHWBASES
    clrl    PollProc
    clrl    DSAlertTab
INITGLOBALVARS_3C:      /* I/O core vectors, disk verify, LoadTrap, event mask, keyboard task */
    biglea  IOCORE                  /* JFetch, JStash, JIODone from the IOCORE table */
    lea     JFetch,%a1
    moveq   #2,%d1
    jbsr    JMPTBLINIT
    clrb    DskVerify
    clrb    LoadTrap
    clrb    MmInOK
    clrw    SysEvtMask
    clrl    JKybdTask
    clrl    StackLowPoint
INITGLOBALVARS_68:      /* empty VBL queue */
    lea     VBLQueue,%a1
    bigjsr  INITQUEUE
INITGLOBALVARS_76:      /* Ticks, mouse button state, system font */
    clrl    Ticks
    moveb   #0x80,MBState
    clrl    MBTicks
    clrl    SysFontFam
INITGLOBALVARS_88:      /* font width table, TextEdit justification, misc */
    clrl    WidthTabHandle
    clrw    TESysJust
    clrb    WordRedraw
    clrl    SynListHandle
    movew   MinusOne,0xd42
INITGLOBALVARS_9E:      /* cursor variables, SysVersion, alarm, notification filter, FlEvtMask */
    jsr     %pc@(INITCRSRVARS)
    clrw    SysVersion
    bclr    #0,AlarmState
    biglea  NMGNEFILTER             /* Notification Manager's GetNextEvent filter */
    movel   %a0,GNEFilter
    clrl    IAZNotify
    movew   #-129,FlEvtMask
    moveq   #-1,%d0
    movew   %d0,ChunkyDepth
INITGLOBALVARS_CA:      /* 0xD62, 0xD66, 0xC16 = -1 */
    movel   %d0,CrsrPtr
    movel   %d0,PortList
    lea     RGBWhite,%a0
    movel   %d0,%a0@+
INITGLOBALVARS_D8:      /* 0xC10..0xC15 cleared */
    movew   %d0,%a0@
    lea     RGBBlack,%a0
INITGLOBALVARS_DE:      /* and 0x1FF4 */
    clrl    %a0@+
    clrw    %a0@
    clrl    0x1ff4
    rts
    .long   0x00000000, 0x00000000

/*
 SWITCHGOODIES: low-memory ranges (address, length) that the Switcher saves and
 restores per application; INITSWITCHERTABLE copies the 108 bytes to the system heap.
 The zero entries are filled in at run time (WDCBSWOS and PMSPSWOS are offsets into
 the table).
*/
SWITCHGOODIES:
    .short  0x0400, 0x0400          /* OS trap dispatch table */
    .short  0x0E00, 0x1000          /* Toolbox trap dispatch table */
    .short  0x0B80, 0x0026
    .short  0x0BAE, 0x0052
SWITCHGOODIES_10:       /* (labels inside the table, from references elsewhere) */
    .short  0x0376, 0x0002
    .short  0x0384
SWITCHGOODIES_16:       /* the address-length pairs continue */
    .short  0x0002
    .short  0x0352, 0x0004
    .short  0x02F8, 0x0002
    .short  0x0398, 0x0004
    .short  0x0D54, 0x0004
    .short  0x0100, 0x0002
    .short  0x0108, 0x0014
    .short  0x015C, 0x0004
    .short  0x031E, 0x0022
    .short  0x0800
SWITCHGOODIES_3A:       /* ... */
    .short  0x02FC
    .short  0x0130, 0x0004
    .short  0x02AA, 0x0004          /* ApplZone */
    .short  0x0CD0, 0x0004
    .short  0x0CD4, 0x0004
SWITCHGOODIES_4C:       /* ... */
    .short  0x0B50, 0x0004
    .short  0x0D50, 0x0004
    .short  0x0B54, 0x0008
    .short  0x0CC8, 0x0004
    .short  0x0000, 0x0000
    .short  0x0000, 0x0000
    .short  0x0000, 0x0004
    .short  0x0000, 0x0000
WDCBSWOS:               /* offset in the table of the WDCB entry (filled in by the File Manager) */
    .short  0x005C
PMSPSWOS:               /* offset in the table of the PMSP entry */
    .short  0x0062

INITSWITCHERTABLE:      /* copy SWITCHGOODIES to the system heap, SwitcherTPtr */
    moveq   #108,%d0
    .short  0xA71E	| 40800762 _NewPtr ,SYS,CLEAR
    moveal  %a0,%a1
    lea     %pc@(SWITCHGOODIES),%a0
    moveq   #108,%d0
    _BlockMove
    movel   %a1,SwitcherTPtr
    rts
    .short  0x0000, 0x0000, 0x0000
INITSWITCHERTABLE_1A:   /* unused (zeros) */
    .short  0x0000, 0x0000
INITSWITCHERTABLE_1E:   /* unused (zeros) */
    .short  0x0000

/* GETPRAM: read parameter RAM into low memory and derive the keyboard and mouse timings */
GETPRAM:
    _InitUtil
    moveq   #0,%d1
    moveb   SPKbd,%d1
    moveq   #15,%d0                 /* low nibble: auto-key rate */
    andw    %d1,%d0
    jbne    gp_rate
    moveq   #72,%d0
gp_rate:                /* KeyRepThresh = 2 * rate (default 72 when 0) */
    addw    %d0,%d0
    movew   %d0,KeyRepThresh
    lsrw    #4,%d1                  /* high nibble: auto-key delay */
    jbne    gp_delay
    movew   #0x1FFF,%d1
gp_delay:               /* KeyThresh = 4 * delay (0x1FFF when 0: no auto-key) */
    lslw    #2,%d1
    movew   %d1,KeyThresh
    moveb   SPClikCaret,%d1
    moveq   #15,%d0                 /* low nibble: caret-blink time */
    andb    %d1,%d0
    lslb    #2,%d0
    movel   %d0,CaretTime
    lsrb    #2,%d1                  /* high nibble: double-click time */
    moveq   #60,%d0
    andb    %d1,%d0
    movel   %d0,DoubleTime
    rts
    .short  0x0000

/*
 WHICHCPU: jump table indexed by %d7; entry 2 (STARTINITPATCH) is always taken.
 Entry 1, the old test, sets %d7 to 0 on a 68000 and 1 on later CPUs by measuring the
 stack frame rte removes.
*/
WHICHCPU:
    moveq   #2,%d7
WHICHCPU_2:             /* jump into the table below */
    jmp     %pc@(0,%d7:w:2)
    bras    wc_frame_test           /* %d7 = 1 */
WHICHCPU_8:             /* the jump actually taken */
    jbra    STARTINITPATCH          /* %d7 = 2 */
    .fill   14, 1, 0x00
wc_frame_test:          /* d7 = size difference of the rte frame: 0 on a 68000, 1 later */
    movel   %sp,%d7
    clrw    %sp@-                   /* format word for a 68010 or later */
    jbsr    wc_rte
    exg     %d7,%sp
    subl    %sp,%d7
    addql   #2,%d7
    lsrl    #1,%d7
    rts
wc_rte:                 /* return through rte with a pushed sr */
    movew   %sr,%sp@-
    rte
    .short  0x0000

/*
 WHICHBOARD: board identification byte from the machine description (%a1) into the
 high word of %d7
*/
WHICHBOARD:
    swap    %d7
    clrw    %d7
    moveb   %a1@(18),%d7
    swap    %d7
    rts
    .long   0x00000000
