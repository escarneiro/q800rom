/*
 os/segloader.s - Segment Loader, Launch/Chain/ExitToShell
 From LOADER (0x4080BCE0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
*/

/*
 _LoadSeg(seg): load 'CODE' resource seg (called from an unloaded jump table entry),
 lock it (high in the heap if SegHiEnable), fill in its jump table entries
 (LOADSEGPATCH), and return to the entry that called it (now a jmp). Missing
 segment: system error 15.
*/
trap_LoadSeg:
LOADER:
LOADSEG:
    moveml %d0-%d2/%a0-%a1,%sp@-
    jbra LOADER_C
    .short  0x0000, 0x0000, 0x0000	| 4080BCE6
LOADER_C:               /* GetResource('CODE', seg) */
    movew %sp@(24),%d0
    jbsr LOADSEG_7C
    jbeq LOADER_76
    _HGetState
    btst #7,%d0
    jbne LOADER_26
    tstb SegHiEnable
    jbeq LOADER_24
    _MoveHHi
LOADER_24:              /* lock it */
    _HLock
LOADER_26:              /* its jump table entries */
    movel %a0@,%d0
    _StripAddress
    moveal %d0,%a0
    moveal %a5,%a1
    addaw CurJTOffset,%a1
    addaw %a0@,%a1
    cmpiw #20217,%a1@(2)
    jbeq LOADER_5C
    movew %a0@(2),%d0
    jbeq LOADER_5C
    movew %sp@(24),%d1
    moveq #0,%d2
    jbsr LOADSEGPATCH
    jbra LOADER_5C
    .long   0x00000000, 0x00000000, 0x00000000	| 4080BD30
LOADER_5C:              /* return to the jump table entry again (6 bytes back) */
    moveal %sp@(20),%a1
    subql #6,%a1
    movel %a1,%sp@(22)
    moveml %sp@+,%d0-%d2/%a0-%a1
    addqw #2,%sp
    tstb LoadTrap
    jbeq LOADER_74
    _Debugger
LOADER_74:              /* (LoadTrap: break into the debugger first) */
    rts
LOADER_76:              /* no segment: system error 15 */
    moveq #15,%d0
    _SysError
    _Debugger

LOADSEG_7C:             /* GetResource('CODE', d0). Out: a0, Z if none */
    st ResLoad
    subqw #4,%sp
    movel #1129268293,%sp@-
    movew %d0,%sp@-
    _GetResource
    moveal %sp@+,%a0
    movel %a0,%d0
    rts

/* _UnLoadSeg: through UNLOADSEGPATCH. */
trap_UnLoadSeg:
UNLOADSEG:
    jbra UNLOADSEGPATCH
    .fill   0x42, 1, 0x00

/*
 APPZONEADDR: d0 = 0 (Z set) if the address d0 is in the application heap (from
 ApplZone to BufPtr, and ApplZone is not the system zone), else -1.
*/
APPZONEADDR:
    _StripAddress
    movel ApplZone,%sp@-
    movel SysZone,%sp@-
    cmpml %sp@+,%sp@+
    jbeq APPZONEADDR_1E
    cmpl ApplZone,%d0
    jbcs APPZONEADDR_1E
    cmpl BufPtr,%d0
    jbcc APPZONEADDR_1E
    moveq #0,%d0
    rts
APPZONEADDR_1E:         /* not in it */
    moveq #-1,%d0
    rts

/* FLUSHAPPLVBLS: remove the VBL tasks whose code is in the application heap. */
FLUSHAPPLVBLS:
    moveal VBLQueueHdr_Head,%a1
FLUSHAPPLVBLS_4:        /* next task */
    movel %a1,%d0
    jbeq FLUSHAPPLVBLS_18
    moveal %a1,%a0
    moveal %a0@,%a1
    movel %a0@(6),%d0
    jbsr APPZONEADDR
    jbne FLUSHAPPLVBLS_4
    _VRemove
    jbra FLUSHAPPLVBLS_4
FLUSHAPPLVBLS_18:       /* done */
    rts
FLUSHAPPLVBLS_1A:       /* alternate screen buffer: the stack below MemTop - 0x5F00 */
    movel MemTop,%d0
    subil #24320,%d0
    jbra LAUNCH_F0

/* _Chain: like Launch but keeping the application heap set-up (LaunchFlag 0). */
trap_Chain:
CHAIN:
    clrw LaunchFlag
    jbra LAUNCH_40

/*
 _Launch(a0 = name, page option): send the "goodbye" call to the drivers that want
 it, close the previous application's resource file, reset the stack and application
 heap (keeping the Clipboard), open the new application's resource file, get 'CODE' 0
 (the jump table information) and continue through the vector at 0x7E0 (VSEGSTACK).
*/
trap_Launch:
LAUNCH:
    st LaunchFlag
    moveml %d0-%d1/%a0-%a1,%sp@-
    subaw #50,%sp
    movew #-1,%sp@(26)
    moveal UTableBase,%a1
    movew UnitTableEntryCount,%d1
LAUNCH_1A:              /* drivers needing goodbye (dNeedGoodbye) */
    movel %a1@+,%d0
    jbeq LAUNCH_34
    moveal %d0,%a0
    moveal %a0@,%a0
    btst #4,%a0@(4)
    jbeq LAUNCH_34
    movew %a0@(24),%sp@(24)
    moveal %sp,%a0
    _Control
LAUNCH_34:              /* next */
    subqw #1,%d1
    jbne LAUNCH_1A
    lea %sp@(50),%sp
    moveml %sp@+,%d0-%d1/%a0-%a1
LAUNCH_40:              /* (Chain) name, page option, extended 'LC' block? */
    moveal %a0,%a3
    moveal %a3@+,%a0
    movew %a3@+,CurPageOption
    lea CurApName,%a1
    moveq #32,%d0
    _BlockMove
    moveq #0,%d3
    cmpiw #19523,%a3@+
    jbne LAUNCH_5C
    addqw #4,%a3
    movew %a3@+,%d3
LAUNCH_5C:              /* close the old resource file */
    movew CurApRefNum,%d0
    jble LAUNCH_6A
    movew %d0,%sp@-
    _CloseResFile
    clrw CurApRefNum
LAUNCH_6A:              /* stack at BufPtr, Launch: keep the Clipboard through InitApplZone */
    moveal BufPtr,%sp
    clrl StackLowPoint
    tstw LaunchFlag
    jbeq LAUNCH_AE
    movel ScrapHandle,%d0
    jble LAUNCH_92
    moveal %d0,%a0
    _GetHandleSize
    addql #1,%d0
    bclr #0,%d0
    subal %d0,%sp
    moveal %sp,%a1
    moveal %a0@,%a0
    movel %d0,%sp@-
    _BlockMove
LAUNCH_92:              /* new application heap, the Clipboard back into a handle */
    _InitApplZone
    tstl ScrapHandle
    jble LAUNCH_AE
    movel %sp@+,%d1
    movel %d1,%d0
    .short  0xA122	| 4080BEA8 _NewHandle (flags 0x0100)
    movel %a0,ScrapHandle
    movel %d1,%d0
    moveal %a0@,%a1
    moveal %sp,%a0
    _BlockMove
    addal %d1,%sp
LAUNCH_AE:              /* open the application (read-only if flag bit 6) */
    subqw #2,%sp
    pea CurApName
    moveq #0,%d0
    btst #6,%d3
    jbeq LAUNCH_BE
    moveq #1,%d0
LAUNCH_BE:              /* OpenResFile, 'CODE' 0 */
    moveb %d0,RMgrPerm
    _OpenResFile
    movew %sp@+,CurApRefNum
    jble EXITTOSHELL_34
    moveq #0,%d0
    jbsr LOADSEG_7C
    jbeq EXITTOSHELL_34
    movel %a0,SaveSegHandle
    moveal %a0@,%a0
    tstw CurPageOption
    jbeq LAUNCH_F6
    jbpl FLUSHAPPLVBLS_1A
    movel MemTop,%d0
    subil #55552,%d0
LAUNCH_F0:              /* stack below the alternate screen / sound buffers */
    cmpl %sp,%d0
    jbge LAUNCH_F6
    moveal %d0,%sp
LAUNCH_F6:              /* continue through 0x7E0 */
    moveal 0x7e0,%a3
    jmp %a3@

/*
 VSEGSTACK: set up A5 world from 'CODE' 0 (above A5 size, below A5 size, jump table),
 copy the jump table, release 'CODE' 0, the application parameters at 8(A5),
 SetApplLimit below the stack, the launch hook (0x6F0), then jump to the first entry.
*/
trap_VSEGSTACK:
VSEGSTACK:
    subal %a0@+,%sp
    movel %sp,%d0
    andiw #-4,%d0
    moveal %d0,%sp
    moveal %sp,%a5
    subal %a0@+,%sp
    movel %a5,CurrentA5
    movel %sp,CurStackBase
    movel %sp,StackLowPoint
    movel %a0@+,%d0
    moveal %a0@+,%a1
    movew %a1,CurJTOffset
    addal %a5,%a1
    lea %a1@(2),%a3
    _BlockMove
    movel SaveSegHandle,%sp@-
    _ReleaseResource
    lea %a5@(8),%a0
    clrl %a0@+
    clrl %a0@+
    movel AppParmHandle,%a0@+
    clrw %a0@+
    moveal %sp,%a0
    subal DefltStack,%a0
    _SetApplLimit
    moveal 0x6f0,%a0
    jsr %a0@
    jsr %a3@

/*
 _ExitToShell: end the application: palette clean-up, no grow zone, LodeScrap, boot
 volume, Launch the Finder. Failure: system error 26.
*/
trap_ExitToShell:
EXITTOSHELL:
    moveq #12,%d0
    _PaletteDispatch
    subal %a0,%a0
    _SetGrowZone
    subqw #4,%sp
    _LodeScrap
    addqw #4,%sp
    moveq #31,%d0
EXITTOSHELL_10:         /* parameter block on the stack */
    clrw %sp@-
    dbf %d0,EXITTOSHELL_10
    moveal %sp,%a0
    movew BootDrive,%a0@(22)
    _SetVol
    lea %sp@(64),%sp
    lea LoaderPBlock,%a0
    moveal %a0,%a1
    pea FinderName
    movel %sp@+,%a1@+
    clrl %a1@+
    _Launch
EXITTOSHELL_34:         /* cannot launch: system error 26 */
    moveq #26,%d0
    _SysError
    _Debugger

/*
 VLAUNCHINIT: clean registers for the new application, FPU state reset, A0-A2 at
 ROMBase + 64 KB (ResetStackPtr).
*/
trap_VLAUNCHINIT:
VLAUNCHINIT:
    btst #12,HWCfgFlags
    jbeq VLAUNCHINIT_C
    clrl %sp@-
    frestore %sp@+
VLAUNCHINIT_C:          /* clear the registers */
    moveq #0,%d7
    moveq #0,%d6
    moveq #0,%d5
    moveq #0,%d4
    moveq #0,%d3
    moveq #0,%d2
    moveq #0,%d1
    moveq #0,%d0
    moveal ROMBase,%a2
    addal #65536,%a2
    moveal %a2,%a1
    moveal %a2,%a0
    movel %a2,ResetStackPtr
    clrl %a5@
    rts

/*
 _GetAppParms(name, refnum, parms): the application's name, resource file and
 parameter handle.
*/
trap_GetAppParms:
GETAPPPARMS:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a5@(16),%a1@
    moveal %sp@+,%a1
    movew CurApRefNum,%a1@
    moveal %sp@+,%a1
    movel %a0,%sp@-
    lea CurApName,%a0
    moveq #32,%d0
    _BlockMove
    rts

/*
 _RDrvrInstall: after the application heap is reset, clear the DCEs of RAM drivers
 whose code was in it, and the storage pointers into it.
*/
trap_RDrvrInstall:
INSTALLRDRIVERS:
    moveml %d0-%d4/%a0-%a3,%sp@-
    moveal UTableBase,%a3
    movew UnitTableEntryCount,%d3
    moveq #-1,%d4
INSTALLRDRIVERS_E:      /* next unit */
    movel %a3@+,%d0
    jbeq INSTALLRDRIVERS_56
    moveal %d0,%a1
    movel %a1@,%d0
    jbeq INSTALLRDRIVERS_56
    moveal %d0,%a1
    btst #6,%a1@(5)
    jbeq INSTALLRDRIVERS_56
    movel %a1@,%d0
INSTALLRDRIVERS_24:     /* RAM driver: code in the application heap? */
    jbeq INSTALLRDRIVERS_56
    movel %a1@(20),%d1
    jbsr APPZONEADDR
    jbne INSTALLRDRIVERS_44
    moveq #51,%d0
    moveal %a1,%a0
INSTALLRDRIVERS_34:     /* clear its DCE */
    clrb %a0@+
    dbf %d0,INSTALLRDRIVERS_34
    bset #6,%a1@(5)
    movew %d4,%a1@(24)
INSTALLRDRIVERS_44:     /* storage in the application heap? */
    clrl %a1@(30)
    movel %d1,%d0
    jbsr APPZONEADDR
    jbne INSTALLRDRIVERS_52
    moveq #0,%d1
INSTALLRDRIVERS_52:     /* set it */
    movel %d1,%a1@(20)
INSTALLRDRIVERS_56:     /* next */
    subqw #1,%d4
    subqw #1,%d3
    jbne INSTALLRDRIVERS_E
INSTALLRDRIVERS_5C:     /* return */
    moveml %sp@+,%d0-%d4/%a0-%a3
    rts
SGLDREND:               /* end of the Segment Loader */
    .short  0x0000	| 4080C03E
