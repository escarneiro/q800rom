/*
 boot/boot.s - MYBOOT: open boot drivers and slots, mouse, events
 From MYBOOT (0x40801D10). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 fp = the 1024 bytes of boot blocks read from the startup disk: +2 entry point, +6
 version, +10 System file name, +26 Finder name, +42 and +58 debugger file names,
 +74 startup screen file name, +90 startup application name, +106 Clipboard file name,
 +122 number of FCBs, +124 event queue size, +134 system heap size, +140/+144 extra
 heap and fraction of memory (new-style boot blocks). fp-1024 = parameter block.
*/

/*
 MYBOOT: boot from the startup device. Finds it, runs the boot block code if the boot
 blocks ask for it, starts the event queue and the File Manager, mounts the volume, opens
 the System file, shows the startup screen (or "Welcome to Macintosh"), loads the
 debuggers, opens the ADB and slot drivers, runs the 'INIT' resources 0..35, sizes the
 heaps, and launches the startup application or the Finder.
*/
MYBOOT:
BOOTME:
    jbsr FINDSTARTUPDEVICE
    moveal SysZone,%a0
    movel %a0,TheZone
    movel %a0,ApplZone
    movel %a0@,HeapEnd
    moveb %fp@(6),%d1
    cmpib #68,%d1
    jbeq MYBOOT_28
    andib #0xc0,%d1
    cmpib #0xc0,%d1
    jbne MYBOOT_2C
MYBOOT_28:              /* boot blocks with executable code: run it */
    jsr %fp@(2)
MYBOOT_2C:              /* event queue, File Manager, mount the boot volume */
    movew %fp@(124),%d0
    _InitEvents
    movew %fp@(122),%d0
    _InitFS
    lea %fp@(-1024),%a0
    movew BootDrive,%a0@(22)
    _MountVol
    jbne MYBOOT_32E
    clrl %a0@(18)
    clrw %a0@(28)
    .short  0xA207	| 40801D60 _GetVolInfo (flags 0x0200)
    jbne MYBOOT_60
    moveal %a0@(94),%a4
    movel %a0@(90),%d0
    jbsr MYBOOT_432
MYBOOT_60:              /* blessed folder (from the volume's Finder info) is the default */
    lea SysResName,%a1
    lea %fp@(10),%a0
    moveq #16,%d0
    _BlockMove
    subqw #2,%sp
    clrl ResErrProc
    _InitResources
    tstw %sp@+
    jbpl MYBOOT_86
    lea %fp@(-1024),%a0
    clrl %a0@(18)
    _UnmountVol
    jmp %pc@(MYBOOT_32E)
MYBOOT_86:              /* the System file is open: system error alert table DSAT 0 */
    moveq #0,%d0
    jbsr MYBOOT_39C
    movel %d0,%d5
    jbne MYBOOT_94
    moveq #0,%d7
    jbra MYBOOT_9A
MYBOOT_94:              /* use it */
    moveal %d5,%a0
    movel %a0@,DSAlertTab
MYBOOT_9A:              /* fonts, then the startup screen file: its picture 0 if it is a resource file */
    _InitFonts
    subqw #2,%sp
    pea %fp@(74)
    _OpenResFile
    movew %sp@+,%d3
    cmpiw #-1,%d3
    jbeq MYBOOT_F8
    subqw #4,%sp
    clrw %sp@-
    _GetPicture
    movel %sp@+,%d0
    jbeq MYBOOT_F0
    moveal %d0,%a2
    moveal %d0,%a0
    _HLock
    moveal %a0@,%a0
    movel %a0@(6),%sp@-
    movel %a0@(2),%sp@-
    lea %fp@(-510),%a0
    tstw %a0@(4)
    jbpl MYBOOT_D4
    moveal %a0@,%a0
    moveal %a0@,%a0
MYBOOT_D4:              /* draw the picture centred on the screen */
    pea %a0@(6)
    pea %sp@(4)
    jbsr CENTERRECT
    jbsr ERASEMYICON
    movel %a2,%sp@-
    pea %sp@(4)
    _DrawPicture
    addqw #8,%sp
    moveq #0,%d7
MYBOOT_F0:              /* close the file (d7 = 0: a startup screen is shown) */
    movew %d3,%sp@-
    _CloseResFile
    tstb %d7
    jbeq MYBOOT_144
MYBOOT_F8:              /* else load the file's data as a 512 x 342 bitmap and CopyBits it */
    lea %fp@(74),%a1
    moveq #1,%d3
    jbsr MYBOOT_3C2
    sne %d7
    jbne MYBOOT_144
    lea %fp@(-510),%a2
    tstw %a2@(4)
    jbpl MYBOOT_114
    moveal %a2@,%a2
    moveal %a2@,%a2
MYBOOT_114:             /* centre a 512 x 342 rectangle */
    movel #22413824,%sp@-
    clrl %sp@-
    pea %a2@(6)
    pea %sp@(4)
    jbsr CENTERRECT
    movew #64,%sp@-
    pea %fp@(2048)
    movel %sp,%sp@-
    movel %a2,%sp@-
    pea %sp@(14)
    movel %sp@,%sp@-
    clrw %sp@-
    clrl %sp@-
    _CopyBits
    lea %sp@(14),%sp
MYBOOT_144:             /* no startup screen: erase the icon */
    tstb %d7
    jbeq MYBOOT_14C
    jbsr ERASEMYICON
MYBOOT_14C:             /* "Welcome to Macintosh" alert (40) if no startup screen, then the debugger */
    moveq #40,%d0
    jbsr MYBOOT_394
    subil #1024,BufPtr
    lea %fp@(42),%a1
    jbsr MYBOOT_3C0
    jbeq MYBOOT_16E
    addil #1024,BufPtr
    jbra MYBOOT_188
MYBOOT_16E:             /* run the debugger, alert -10, the second debugger, alert -11 */
    jsr %a1@
    moveq #-10,%d0
    jbsr MYBOOT_394
    lea %fp@(58),%a1
    jbsr MYBOOT_3C0
    jbne MYBOOT_188
    jsr %a1@
    moveq #-11,%d0
    jbsr MYBOOT_394
MYBOOT_188:             /* run the code in the System file's data fork, if any */
    lea SysResName,%a1
    moveq #-1,%d3
    jbsr MYBOOT_3C2
    jbne MYBOOT_196
    jsr %a1@
MYBOOT_196:             /* slots (Slot Manager 50), ADB drivers, mouse, slot drivers, DSAT 2 */
    subaw #56,%sp
    moveal %sp,%a0
    moveq #50,%d0	/* _SlotManager 50: INITSECONDARY */
    _SlotManager
    lea %sp@(56),%sp
    bigjsr INITADBDRVR
    jbsr MOUSEINIT
    jbsr OPENSLOTS
    moveq #2,%d0
    jbsr MYBOOT_39C
    jbeq MYBOOT_1C8
    moveal %d0,%a0
    movel %a0@,DSAlertTab
    movel %a0,%sp@-
    _DetachResource
MYBOOT_1C8:             /* AppParmHandle, Sony driver Control 9, application zone, RAM drivers */
    movel %d5,%sp@-
    _ReleaseResource
    moveq #12,%d0
    .short  0xA722	| 40801EDE _NewHandle (flags 0x0700)
    movel %a0,AppParmHandle
    lea %fp@(-1024),%a0
    movew #-5,%a0@(24)
    movew #9,%a0@(26)
    movew #-255,%a0@(28)
    _Control
    _InitApplZone
    _RDrvrInstall
MYBOOT_1F0:             /* run the 'INIT' resources 0..35, from the ROM, then from the System file */
    moveq #0,%d6
MYBOOT_1F2:             /* keep at least 16 KB free in the application zone */
    moveml %a5-%fp,BootTmp8
    .short  0xA41C	| 40801F08 _FreeMem (flags 0x0400)
    subil #16384,%d0
    negl %d0
    jble MYBOOT_21A
    addil #1023,%d0
    andiw #-1024,%d0
    moveal SysZone,%a0
    moveal %a0@,%a0
    addal %d0,%a0
    _SetApplBase
    _InitApplZone
MYBOOT_21A:             /* d5: 0xFF = look in the ROM map, 0 = in the System file */
    moveq #0,%d5
MYBOOT_21C:             /* GetResource('INIT', d6), detach it and call it */
    notb %d5
    jbeq MYBOOT_244
    moveb %d5,ROMMapInsert
    moveb ResLoad,TmpResLoad
    subqw #4,%sp
    movel #1229867348,%sp@-
    movew %d6,%sp@-
    _GetResource
    movel %sp@+,%d7
    jbeq MYBOOT_21C
    movel %d7,%sp@-
    _DetachResource
    moveal %d7,%a0
    moveal %a0@,%a0
    jsr %a0@
MYBOOT_244:             /* next ID */
    moveml BootTmp8,%a5-%fp
    addqw #1,%d6
    cmpiw #36,%d6
    jblt MYBOOT_1F2
    pea %fp@(-512)
    _ClosePort
    moveq #64,%d0
    swap %d0
    .short  0xA44D	| 40801F6C _PurgeMem (flags 0x0400)
    moveal SysZone,%a0
    movel #98304,%d0
    movew %fp@(6),%d1
    cmpiw #20,%d1
    jbls MYBOOT_29A
    movel %fp@(134),%d0
    btst #15,%d1
    jbeq MYBOOT_29A
    btst #13,%d1
    jbeq MYBOOT_29A
    subqw #4,%sp
    movel BufPtr,%sp@-
    movel %fp@(144),%sp@-
    _FracMul
    movel %sp@+,%d0
    addl %fp@(140),%d0
    moveal SysZone,%a0
    moveal %a0@,%a0
MYBOOT_29A:             /* system heap size: 96 KB, or from the boot blocks */
    addal %d0,%a0
    .short  0xA41C	| 40801FAC _FreeMem (flags 0x0400)
    subil #16384,%d0
    negl %d0
    jbpl MYBOOT_2AA
    moveq #0,%d0
MYBOOT_2AA:             /* at least 16 KB free */
    moveal SysZone,%a1
    addl %a1@,%d0
    cmpal %d0,%a0
    jbcc MYBOOT_2B6
    moveal %d0,%a0
MYBOOT_2B6:             /* and at least 8 KB below BufPtr */
    moveal BufPtr,%a1
    subaw #8192,%a1
    cmpal %a1,%a0
    jbls MYBOOT_2C4
    moveal %a1,%a0
MYBOOT_2C4:             /* new application zone, Clipboard and Finder names */
    _SetApplBase
    _InitApplZone
    moveal PortList,%a0
    moveq #2,%d0
    _SetHandleSize
    moveal %a0@,%a0
    clrw %a0@
    lea %fp@(106),%a0
    lea ScrapTag,%a1
    movel %a1,ScrapName
MYBOOT_2E0:             /* copy the names */
    moveq #16,%d0
    _BlockMove
    lea %fp@(26),%a0
    lea FinderName,%a1
    moveq #16,%d0
    _BlockMove
MYBOOT_2F0:             /* boot volume, blessed folder, startup application or Finder */
    clrw CurApRefNum
    lea %fp@(-1024),%a0
    clrl %a0@(18)
    _GetVol
    movew %a0@(22),BootDrive
    movel %a4,%d0
    jbsr MYBOOT_432
    lea %fp@(90),%a3
    jbsr MYBOOT_3AC
    jbeq MYBOOT_31E
    lea %fp@(26),%a3
    jbsr MYBOOT_3AC
    jbne MYBOOT_328
MYBOOT_31E:             /* Launch it */
    clrw %sp@-
    clrl %sp@-
    movel %a3,%sp@-
    moveal %sp,%a0
    _Launch
MYBOOT_328:             /* could not launch: system error 41 (cannot load the Finder) */
    moveq #41,%d0
    _SysError
    _Debugger
MYBOOT_32E:             /* no usable volume: eject the disk if it is ejectable, exclude it, retry */
    movew BootDrive,%d3
    movew BtDskRfn,%d1
    jbsr MYBOOT_378
    cmpib #8,%d0
    jbeq MYBOOT_36A
    moveb %d0,%sp@-
    lea %fp@(-1024),%a0
    movew BtDskRfn,%a0@(24)
    movew #7,%a0@(26)
    movew %d3,%a0@(22)
    _Control
    jbne MYBOOT_36A
    moveb %sp@+,%d0
    cmpib #8,%d0
    bgew MYBOOT_36A
    cmpiw #-2,BtDskRfn
    jbne MYBOOT_374
MYBOOT_36A:             /* exclude the drive from BootMask */
    movew BootMask,%d0
    bclr %d3,%d0
    movew %d0,BootMask
MYBOOT_374:             /* retry the boot */
    jbra CLOSENETBOOTPATCH
MYBOOT_378:             /* drive queue entry for drive d3, refnum d1: d0 = its flag byte (-3) */
    lea DrvQHdr_Head,%a0
MYBOOT_37C:             /* next entry */
    movel %a0@,%d0
    jbeq MYBOOT_392
    moveal %d0,%a0
    cmpw %a0@(6),%d3
    jbne MYBOOT_37C
    cmpw %a0@(8),%d1
    jbne MYBOOT_37C
    moveb %a0@(-3),%d0
MYBOOT_392:             /* done */
    rts
MYBOOT_394:             /* system error alert d0 (only when there is no startup screen) */
    tstb %d7
    jbeq MYBOOT_39A
    _SysError
MYBOOT_39A:             /* done */
    rts
MYBOOT_39C:             /* GetResource('DSAT', d0) */
    clrl %sp@-
    movel #1146306900,%sp@-
    movew %d0,%sp@-
    _GetResource
    movel %sp@+,%d0
    rts
MYBOOT_3AC:             /* GetFileInfo of the file named at a3 (Z = it exists) */
    lea %fp@(-1024),%a0
    clrw %a0@(22)
    clrl %a0@(26)
    movel %a3,%a0@(18)
    _GetFileInfo
    rts
MYBOOT_3C0:             /* load file a1 below BufPtr (debuggers) */
    moveq #0,%d3
MYBOOT_3C2:             /* load file a1's data from offset 512: d3 = 0 below BufPtr, 1 at fp+2048, -1 in a new pointer */
    lea %fp@(-1024),%a0
    moveq #-1,%d2
    lea %a0@(18),%a2
    movel %a1,%a2@+
    clrl %a2@+
    clrb %a2@+
    moveb #1,%a2@+
    pea %fp@(1024)
    movel %sp@+,%a2@
    _Open
    jbne MYBOOT_418
    _GetEOF
    jbne MYBOOT_412
    movel %a2@+,%d4
    moveq #64,%d6
    aslw #3,%d6
    subl %d6,%d4
    tstw %d3
    jbmi MYBOOT_426
    jbne MYBOOT_41C
    moveal BufPtr,%a1
    subal %d4,%a1
MYBOOT_3F8:             /* read it to a1 */
    lea %fp@(-1024),%a0
    lea %a0@(32),%a2
    movel %a1,%a2@+
    movel %d4,%a2@+
    addqw #4,%a2
    movew #1,%a2@+
    movel %d6,%a2@
    _Read
    jbne MYBOOT_412
    moveq #0,%d2
MYBOOT_412:             /* close it */
    lea %fp@(-1024),%a0
    _Close
MYBOOT_418:             /* d0 = error */
    movew %d2,%d0
    rts
MYBOOT_41C:             /* d3 = 1: whole file at fp+2048 (startup screen bitmap) */
    lea %fp@(2048),%a1
    addl %d6,%d4
    moveq #0,%d6
    jbra MYBOOT_3F8
MYBOOT_426:             /* d3 < 0: in a new system pointer */
    movel %d4,%d0
    .short  0xA51E	| 40802138 _NewPtr (flags 0x0500)
    movew %d0,%d2
    jbne MYBOOT_412
    moveal %a0,%a1
    jbra MYBOOT_3F8
MYBOOT_432:             /* OpenWD for directory d0 (procID 'ERIK') and SetVol to it */
    tstl %d0
    jbeq MYBOOT_452
    lea %fp@(-1024),%a0
    movel %d0,%a0@(48)
    clrl %a0@(18)
    movel #1163020619,%a0@(28)
    moveq #1,%d0
    .short  0xA260	| 4080215C _FSDispatch (flags 0x0200)
    jbne MYBOOT_452
    _SetVol
MYBOOT_452:             /* done */
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40802164

/*
 CENTERRECT(inner, outer): centre the rectangle inner in outer (horizontally and
 vertically). Pascal-style: the two pointers are popped.
*/
CENTERRECT:
    movel %sp@+,%d2
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    jbsr CENTERRECT_E
    jbsr CENTERRECT_E
    moveal %d2,%a0
    jmp %a0@

CENTERRECT_E:           /* one dimension */
    movew %a0@(4),%d0
    subw %a0@,%d0
    movew %a1@(4),%d1
    subw %a1@,%d1
    subw %d1,%d0
    asrw #1,%d0
    addw %a0@+,%d0
    movew %d0,%a1@+
    addw %d1,%d0
    movew %d0,%a1@(2)
    rts
    .short  0x0000, 0x0000, 0x0000	| 4080219A

/*
 MOUSEINIT: mouse tracking speed from parameter RAM (SPVolCtl bits 3-6, at most 4, else
 reset to 2): the 'mcky' resource of that number gives the 8 bytes copied into the
 MickeyBytes block.
*/
MOUSEINIT:
    moveq #120,%d0
    andb SPVolCtl,%d0
    lsrb #3,%d0
    cmpib #4,%d0
    jble MOUSEINIT_1C
    andib #87,SPVolCtl
    orib #16,SPVolCtl
    moveq #2,%d0
MOUSEINIT_1C:           /* GetResource('mcky', speed) */
    subqw #4,%sp
    movel #1835232121,%sp@-
    movew %d0,%sp@-
    _GetResource
    movel %sp@+,%d0
    jbeq MOUSEINIT_3C
    moveal %d0,%a0
    moveal %a0@,%a0
    moveal MickeyBytes,%a1
    lea %a1@(20),%a1
    movel %a0@+,%a1@+
    movel %a0@,%a1@
MOUSEINIT_3C:           /* done */
    rts
    .short  0x0000	| 408021DE

/*
 OPENBDRVRS: execute the sRsrcBootRec of sResource a0 (sExec) with the default OS and
 seFlags 1: lets a card's boot record install its drivers.
*/
OPENBDRVRS:
    moveb %a0@(49),%sp@-
    moveb %a0@(50),%sp@-
    moveml %d0-%d3/%a0-%a1,%sp@-
    subaw #24,%sp
    moveal %sp,%a1
    movel %a1,%a0@(20)
    movel %a0,%d3
    subql #2,%sp
    moveal %sp,%a0
    _GetOSDefault
    movew %sp@+,%d2
    moveal %d3,%a0
    moveb %a0@(49),%a1@
    moveb %a0@(50),%a1@(1)
    clrb %a1@(17)
    clrb %a1@(16)
    moveb %d2,%a1@(18)
    lsrl #8,%d2
    moveb %d2,%a1@(19)
    moveb #1,%a1@(22)
    moveb #6,%a0@(50)
    moveq #35,%d0	/* _SlotManager 35: SLOTEXEC, sExec */
    _SlotManager
    lea %sp@(24),%sp
    moveml %sp@+,%d0-%d3/%a0-%a1
    moveb %sp@+,%a0@(50)
    moveb %sp@+,%a0@(49)
    rts

/*
 OPENSLOTS: open the drivers of all sResources marked fOpenAtStart (sRsrcFlags bit 1, or
 no flags): through the sRsrcBootRec if there is one, else the sResource's driver, and
 add a gDevice for each video card.
*/
OPENSLOTS:
    moveml %d0-%d4/%a0-%a1,%sp@-
    subaw #50,%sp
    moveal %sp,%a1
    clrb %a1@(27)
    subaw #56,%sp
    moveal %sp,%a0
    clrb %a0@(49)
    clrb %a0@(51)
    clrb %d3
OPENSLOTS_1E:           /* next sResource (sNextsRsrc) */
    moveb %d3,%a0@(50)
    moveq #20,%d0	/* _SlotManager 20: NEXTSRSRC, sNextsRsrc */
    _SlotManager
    jbne OPENSLOTS_82
    moveb %a0@(50),%d3
    movel %a0@(4),%d4
    moveb #7,%a0@(50)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    jbne OPENSLOTS_46
    movew %a0@(2),%d0
    btst #1,%d0
    jbeq OPENSLOTS_1E
OPENSLOTS_46:           /* has an sRsrcBootRec? run it */
    moveb #6,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne OPENSLOTS_60
    moveb %d3,%a0@(50)
    movel %d4,%a0@(4)
    jbsr OPENBDRVRS
    jbra OPENSLOTS_1E
OPENSLOTS_60:           /* no: open its driver, video devices get a gDevice */
    moveb %d3,%a0@(50)
    jbsr OPENSDRVR
    jbne OPENSLOTS_1E
    cmpil #196609,%a0@(40)
    jbne OPENSLOTS_1E
    cmpiw #1,%a0@(44)
    jbne OPENSLOTS_1E
    jbsr ADDVIDDEVICE
    jbra OPENSLOTS_1E
OPENSLOTS_82:           /* done: clear bit 12 of the first gDevice's flags */
    lea %sp@(106),%sp
    moveal DeviceList,%a0
    moveal %a0@,%a0
    bclr #12,%a0@(20)
    moveml %sp@+,%d0-%d4/%a0-%a1
    rts
    .long   0x00000000, 0x00000000	| 408022D8

/*
 _InitEvents: event queue of d0 entries (22 bytes each, system heap, all marked free),
 SysEvtMask = everything but keyUp, KeyLast = 0.
*/
trap_InitEvents:
INITEVENTS:
    movew %d0,%d2
    moveq #22,%d0
    muluw %d2,%d0
    movel %d0,%d1
    .short  0xA71E	| 408022E8 _NewPtr (flags 0x0700)
    lea EvtBufCnt,%a1
    subqw #1,%d2
    movew %d2,%a1@
    clrl %a1@-
    clrl %a1@-
    clrw %a1@-
    movel %a0,%a1@-
INITEVENTS_1A:          /* fill the buffer with 0xFF */
    notw %a0@+
    subqw #2,%d1
    jbne INITEVENTS_1A
    movew #-17,%a1@-
    clrw KeyLast
    rts
    .short  0x0000, 0x0000, 0x0000	| 4080230A
