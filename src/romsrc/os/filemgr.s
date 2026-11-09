/*
 os/filemgr.s - File Manager (TFS/HFS), B-trees, cache
 From TFSDISPATCH (0x4080EF40). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the File Manager chapters of Inside
 Macintosh (HFS), not taken from Apple.

 The File Manager handles both disk formats: HFS (hierarchical: a catalog B-tree of
 files and folders, an extents B-tree, a volume bitmap) and MFS (the flat format of
 400K disks: one directory, a 12-bit block map). Layers, top to bottom:
 - the traps (_Open, _Read, _GetCatInfo... and _HFSDispatch, TFSDISPATCH): each queues
   its parameter block (FSQUEUESYNC); calls run one at a time on the File Manager's
   own stack and end in CMDDONE (result, completion routine, the next call);
 - "determine volume" (VDTRMV1/2/3), the name lookup (VFNDFILNAME), working directories
   (WDCBs) and the FCBs of open paths;
 - the Catalog Manager (CMSVCS), the Extents Manager (FXM), the Volume Space Manager
   (VSM) and the B-tree services (BTSVCS);
 - the block cache (CACHE) and the driver I/O (VBASICIO).
 Most routines X have a vectored entry: X jumps through a low-memory vector (0x6BC..
 0x7DC) to VX, so the System can patch any of them; the source names the vector on
 each such line. In the QEMU traces of the Quadra 800 booting Mac OS 8.1 (analysis/
 executed_pcs.txt), about half of the routines here run (101 of 201): mounting, opening,
 reading, the catalog and B-tree searches, the cache; MFS, renaming, deleting and
 most of the B-tree insertion code do not.
 MFS code is mislabelled in places (GETWDINFO_160.., FILECREATE_B8.., VLG2PHYS_88..,
 TFMOVE_FA..): block comments say where.

 Registers in the internal routines: a0 = the parameter block, a2 = the VCB, a1 + d1 =
 the FCB (the FCB buffer FCBSPtr + offset), a3 = a WDCB, a4 = locals on the File
 Manager's stack (a6, which grows down separately from a7).

 VCB (178 bytes for HFS): +6 flags (bit 7 dirty), +8 signature ('BD' HFS, 0xD2D7 MFS),
 +10 created, +14 modified, +18 attributes (bit 15 locked by software, 7 by hardware,
 8 unmounted cleanly), +20 files in the root, +22 bitmap start, +24 allocation pointer,
 +26 allocation blocks, +28 block size, +32 clump size, +36 first allocation block, +38
 next catalog ID, +42 free blocks, +44 name, +72 drive (0: off line), +74 driver refNum,
 +76 file system ID, +78 vRefNum, +80 bitmap cache (MFS: block map), +84 volume cache,
 +94 backup date, +100 write count, +104/+108 extents/catalog clump sizes, +112 folders
 in the root, +114/+118 file/folder counts, +122 Finder info, +164/+166 the extents and
 catalog FCBs, +168 control cache, +172/+176 the last folder and index enumerated.

 FCB (94 bytes): +0 file number, +4 flags (bit 7 dirty, 1 resource fork, 0 writable),
 +6 MFS start block, +8 EOF, +12 physical length, +16 mark, +20 VCB, +24 buffer, +28
 MFS directory block, +30 clump size, +34 B-tree control block, +38 first extent
 record (3 x start, count), +50 type, +54 catalog hint, +58 parent dir ID, +62 name.
 WDCB (16 bytes): VCB, dir ID, catalog hint, procID; WD refNum = offset - 32767.

 Errors are the File Manager's (-33 dirFulErr .. -127 fsDSIntErr; named where set);
 internal B-tree results are positive (32 not found, 33 exists, 36 bad node...).
*/

/* TURBOFS: the File Manager (HFS): TFSDISPATCH dispatches _HFSDispatch (0xA260) selectors. */
trap_FSDispatch:

/* TFSDISPATCH: _HFSDispatch: the HFS selectors (OpenWD, CloseWD, CatMove, DirCreate, GetWDInfo, GetFCBInfo, GetCatInfo, SetCatInfo...). */
TURBOFS:
TFSDISPATCH:
    tstw %d0
    jblt TURBOFS_A
    cmpiw #17,%d0
    jbls TURBOFS_12
TURBOFS_A:              /* selector out of range: paramErr */
    jbsr FSQUEUESYNC_4
    moveq #-50,%d0	/* paramErr */
    jbra CMDDONE
TURBOFS_12:             /* dispatch through the offset table */
    movew %d0,%d2
    lea %pc@(TURBOFS_20),%a2
    addw %d2,%d2
    addaw %a2@(0x0,%d2:w),%a2
    jmp %a2@
TURBOFS_20:             /* _HFSDispatch selectors 0..17: 0 (version), 1 OpenWD, 2 CloseWD, 3 SetDir, 4 GetDir, 5 CatMove, 6 DirCreate, 7 GetWDInfo, 8 GetFCBInfo, 9 GetCatInfo, 10 SetCatInfo, 11 SetVolInfo, 12..17 lock/unlock range and others */
    .short  TURBOFS_44-TURBOFS_20	| 4080EF60
    .short  OPENWD-TURBOFS_20	| 4080EF62
    .short  CLOSEWD-TURBOFS_20	| 4080EF64
    .short  SETDIR-TURBOFS_20	| 4080EF66
    .short  GETDIR-TURBOFS_20	| 4080EF68
    .short  TFMOVE-TURBOFS_20	| 4080EF6A
    .short  CREATEDIR-TURBOFS_20	| 4080EF6C
    .short  GETWDINFO-TURBOFS_20	| 4080EF6E
    .short  GETFCBINFO-TURBOFS_20	| 4080EF70
    .short  GETCATINFO-TURBOFS_20	| 4080EF72
    .short  SETCATINFO-TURBOFS_20	| 4080EF74
    .short  SETVOLINFO-TURBOFS_20	| 4080EF76
    .short  VDTRMV2_6A-TURBOFS_20	| 4080EF78
    .short  GETWDINFO_116-TURBOFS_20	| 4080EF7A
    .short  GETWDINFO_140-TURBOFS_20	| 4080EF7C
    .short  GETWDINFO_AE-TURBOFS_20	| 4080EF7E
    .short  GETFCBINFO_B8-TURBOFS_20	| 4080EF80
    .short  GETFCBINFO_B8-TURBOFS_20	| 4080EF82
TURBOFS_44:             /* selector 0: ioMisc (+32) = '1.1A' (the File Manager version), no error */
    jbsr FSQUEUESYNC_4
    movel #825111105,%a0@(32)
    moveq #0,%d0
    jbra CMDDONE

/* FSQUEUESYNC: queue the request on the File Manager queue and wait until it is the active one. */
FSQUEUESYNC:
    bclr #10,%d1

FSQUEUESYNC_4:          /* FSQueueHook first, if set */
    movel FSQueueHook,%d2
    jble FSQUEUESYNC_E
    moveal %d2,%a1
    jsr %a1@
FSQUEUESYNC_E:          /* ioResult = 1 (in progress), ioTrap = the trap word; for _HFSDispatch (0x60) the selector in its low byte */
    movew #1,%a0@(16)
    movew %d1,%a0@(6)
    cmpib #96,%d1
    jbne FSQUEUESYNC_28
    andib #15,%a0@(6)
    moveb %d0,%a0@(7)
FSQUEUESYNC_28:         /* ioCmdAddr = the routine (the caller's return address); qType 5; asynchronous (trap bit 10)? */
    movel %sp@+,%a0@(8)
    movew #5,%a0@(4)
    btst #10,%d1
    jbeq FSQUEUESYNC_40
    tstb FrcSync
    jbeq FSQUEUESYNC_6C
    jbra FSQUEUESYNC_44
FSQUEUESYNC_40:         /* synchronous: no completion routine */
    clrl %a0@(12)
FSQUEUESYNC_44:         /* queue it; a synchronous call waits for its result */
    movel %a0,%sp@-
    jbsr FSQUEUESYNC_6C
    moveal %sp@+,%a0
FSQUEUESYNC_4A:         /* wait while ioResult > 0 */
    movew %a0@(16),%d0
    jbgt FSQUEUESYNC_4A
    extl %d0
    cmpiw #-53,%d0
    jbne FSQUEUESYNC_6A
    movel DskSwtchHook,%sp@-
    jbgt FSQUEUESYNC_6A
    addqw #4,%sp
    btst #7,DSAlertRect
    jbne DSHOOK
FSQUEUESYNC_6A:         /* return */
    rts

FSQUEUESYNC_6C:         /* enqueue in the File Manager queue (interrupts off); if the queue was idle start this call now */
    lea FSQHdr_Flags,%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    jsr %pc@(trap_Enqueue)
FSQUEUESYNC_7A:         /* busy (FSQHdr bit 0)? the running call will start it later */
    bset #0,FSQHdr_Flags
    jbeq FSQUEUESYNC_88
    moveq #0,%d0
    movew %sp@+,%sr
    rts
FSQUEUESYNC_88:         /* start the call at the head: its routine (ioCmdAddr) on the File Manager's own stack (HFSStkTop), NxtDB = asynchronous */
    movew %sp@+,%sr
    moveal FSQHdr_Head,%a0
    moveal %a0@(8),%a1
    moveml %d3-%d7/%a2-%fp,%sp@-
    moveal PMSPPtr,%fp
    clrw %fp@(-2)
    btst #10,%a0@(6)
    sne NxtDB
    moveal HFSVars_HFSStkTop,%fp
    jsr %a1@
    moveml %sp@+,%d3-%d7/%a2-%fp
    rts
FSQUEUESYNC_B4:         /* the queue is damaged (head is not a File Manager request): system error 27 (dsFSErr) */
    moveq #27,%d0
    _SysError

/* CMDDONE: end of a File Manager call: result, completion routine, start the next queued call. */
CMDDONE:
    jbsr FILEMGRPATCH
    jble CMDDONE_E
    movew %d0,HFSDSErr	/* a positive error from the patch: the internal error, reported as fsDSIntErr */
    moveq #-127,%d0	/* fsDSIntErr */
CMDDONE_E:              /* d0 = result; fnfErr on a call by name may be retried on other volumes (the path list, PMSPPtr) unless that is disabled (HFSFlags 5, 6) */
    moveal FSQHdr_Head,%a0
    cmpiw #5,%a0@(4)	/* still a File Manager request? */
    jbne FSQUEUESYNC_B4
    cmpiw #-43,%d0
    jbne CMDDONE_84
    btst #9,%a0@(6)
    jbeq CMDDONE_2E
    tstl %a0@(48)
    jbne CMDDONE_84
CMDDONE_2E:             /* try the next volume in the search path */
    btst #6,HFSFlags
    jbne CMDDONE_84
    btst #5,HFSFlags
    jbne CMDDONE_84
    moveal PMSPPtr,%a1
    moveml %d1/%a2,%sp@-
    movew %a1@(-2),%d1
CMDDONE_4A:             /* next path entry: a mounted, on-line volume? */
    addqw #6,%d1
    cmpw %a1@,%d1
    jbge CMDDONE_62
    movew %a1@(0x0,%d1:w),%d0
    jbeq CMDDONE_62
    jbsr GETVCBRFN
    jbne CMDDONE_62
    movew %a2@(72),%d0
    jble CMDDONE_4A
CMDDONE_62:             /* found one: run the call again (ioCmdAddr) on it */
    movew %d1,%a1@(-2)
    movew %d1,%d0
    moveml %sp@+,%d1/%a2
    cmpw %a1@,%d0
    jbge CMDDONE_82
    tstw %a1@(0x0,%d0:w)
    jbeq CMDDONE_82
    moveq #0,%d0
    moveb %a0@(7),%d0
    moveal %a0@(8),%a1
    jmp %a1@
CMDDONE_82:             /* none: fnfErr */
    moveq #-43,%d0	/* fnfErr */
CMDDONE_84:             /* ExtFSHook, then an external file system (ToExtFS) for extFSErr / noMacDskErr */
    bclr #5,HFSFlags
    movel ExtFSHook,%d2
    jble CMDDONE_94
    moveal %d2,%a1
    jsr %a1@
CMDDONE_94:             /* ToExtFS set? */
    movel ToExtFS,%d2
    jble CMDDONE_D4
    moveal %d2,%a1
    cmpiw #-58,%d0
    jbeq CMDDONE_AC
    cmpiw #-57,%d0
    jbne CMDDONE_D4
    clrl ReqstVol
CMDDONE_AC:             /* hand the call to the external file system (the request's trap word marked) */
    moveal FSQHdr_Head,%a0
    cmpiw #5,%a0@(4)
    jbne FSQUEUESYNC_B4
    moveq #-58,%d0	/* extFSErr */
    tstw %a0@(6)
    jblt CMDDONE_D2
    moveq #0,%d0
    moveb %a0@(7),%d0
    clrb %a0@(7)
    oriw #-24480,%a0@(6)
CMDDONE_D2:             /* call it */
    jsr %a1@
CMDDONE_D4:             /* dequeue the call (interrupts off), store ioResult, call the completion routine (d0 = result) */
    movew %sr,%sp@-
    oriw #1792,%sr
    clrw FSQHdr_Flags
    moveal FSQHdr_Head,%a0
    cmpiw #5,%a0@(4)
    jbne FSQUEUESYNC_B4
    movel %a0@,FSQHdr_Head
    jbne CMDDONE_F6
    clrl FSQHdr_Tail
CMDDONE_F6:             /* result, completion routine */
    movew %sp@+,%sr
    movew %d0,%a0@(16)
    movel %a0@(12),%d1
    jbeq CMDDONE_108
    moveal %d1,%a1
    tstw %d0
    jsr %a1@
CMDDONE_108:            /* more calls queued? start the next one */
    movew %sr,%sp@-
    oriw #1792,%sr
    tstl FSQHdr_Head
    jbne FSQUEUESYNC_7A
    movew %sp@+,%sr
    rts

/* FINITQUEUE: empty the File Manager queue. */
trap_FInitQueue:
FINITQUEUE:
    movew %sr,%sp@-
    oriw #1792,%sr
    movel FSQHdr_Head,%d0
    jbeq FINITQUEUE_14
    moveal %d0,%a0
    clrl %a0@
    movel %a0,FSQHdr_Tail
FINITQUEUE_14:          /* no error */
    moveq #0,%d0
    movew %sp@+,%sr
    rts

/* DSHOOK: system error hook for disk errors. */
DSHOOK:
    moveml %d0-%a3/%fp,%sp@-
    lea TrapAgain,%a1
    movew %a0@(6),%a1@+
    movew #20085,%a1@	/* TrapAgain: the trap word, then rts */
    jbsr MAKESTKPB
    movel %a0,%d7
    moveal ReqstVol,%a2
    movew %a2@(74),%d3
    jbpl DSHOOK_30
    negw %d3
    movew %d3,%a0@(22)
    _MountVol
    jbne DSHOOK_30
    moveq #0,%d3
    jbra DSHOOK_180
DSHOOK_30:              /* the disk-switch alert: save the screen under it (if QuickDraw is up and there is room), then system error 30 (dsReinsert: "please insert the disk") */
    movel #5243000,DSAlertRect
    movel #9961877,DSAlertRect_botRight
    moveq #0,%d4
    moveq #0,%d5
    tstb QDExist
    jbne DSHOOK_C0
    moveal %a5@,%a0
    movel %a0@,%d4
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveal @(MainDevice,%za0)@(0),%a0	| 4080F1CE
    moveal %a0@(0x16,%za0)@(0x0),%a0
    cmpiw #1,%a0@(32)
    jbgt DSHOOK_C0
    movel %sp,%d0
    subil #4798,%d0
    moveal ApplZone,%a0
    cmpl %a0@,%d0
    jble DSHOOK_C0
    movel %sp,%d5
    addil #2048,%d0
    moveal %d0,%sp
    movel %d0,%d6
    moveal %sp,%a0
    pea %a0@(14)
    movel %sp@+,%a0@+
    movew #36,%a0@+
    clrl %a0@+
    movel #4718877,%a0@+
    subaw #116,%sp
    moveal %sp,%fp
    bigjsr ALLOCFAKERGNS
    movel %sp,%sp@-
    _InitPort
    moveal %a5@,%a0
    movel %fp,%a0@
    pea %a0@(-122)
    movel %d6,%sp@-
    pea DSAlertRect
    moveal %d6,%a0
    pea %a0@(6)
    clrw %sp@-
    clrl %sp@-
    _CopyBits
DSHOOK_C0:              /* show the alert; then find the drive of the wanted volume */
    moveq #30,%d0
    _SysError
    movel DrvQHdr_Head,%d0
DSHOOK_C8:              /* next drive queue element */
    jbeq DSHOOK_EE
    moveal %d0,%a1
    cmpw %a1@(6),%d3
    jbeq DSHOOK_D6
    movel %a1@,%d0
    jbra DSHOOK_C8
DSHOOK_D6:              /* a floppy (the drive's type byte 1 or 2)? eject what is in it */
    moveb %a1@(-3),%d0
    cmpib #1,%d0
    jbeq DSHOOK_E6
    cmpib #2,%d0
    jbne DSHOOK_EE
DSHOOK_E6:              /* d1 = drive */
    movew %d3,%d1
DSHOOK_E8:              /* eject it */
    moveq #2,%d2
    jbsr trap_DOEJECT
DSHOOK_EE:              /* wait for an event: disk inserted, or Cmd-. / Cmd-Shift-1/2 (eject) */
    subaw #16,%sp
DSHOOK_F2:              /* GetOSEvent (mouse down, key down, disk inserted) */
    movew #136,%d0
    moveal %sp,%a0
    _GetOSEvent
    jbne DSHOOK_F2
    movel %sp@(2),%d0
    movew %sp@,%d3
    movew %sp@(14),%d1
    lea %sp@(16),%sp
    subqw #7,%d3
    jbeq DSHOOK_13E
    cmpib #46,%d0
    jbeq DSHOOK_136
    moveq #11,%d2
    lsrw #8,%d1
    andb %d1,%d2
    subqb #3,%d2
    jbne DSHOOK_EE
    moveq #-51,%d1
    addb %d0,%d1
    addqb #3,%d1
    jbcc DSHOOK_EE
    extw %d1
    jbne DSHOOK_12C
    moveq #3,%d1
DSHOOK_12C:             /* Cmd-Shift-number: eject that drive (through the vector at 0x7DC) */
    moveq #1,%d2
    moveal 0x7dc,%a0
    jsr %a0@
    jbra DSHOOK_EE
DSHOOK_136:             /* Cmd-period: cancel */
    btst #8,%d1
    jbeq DSHOOK_EE
    jbra DSHOOK_152
DSHOOK_13E:             /* disk inserted: mount it; not the wanted one (or not a Mac disk): eject, wait again */
    moveal %d7,%a0
    movew %d0,%a0@(22)
    movew %d0,%d1
    _MountVol
    jbeq DSHOOK_152
    cmpiw #-108,%d0
    jbne DSHOOK_E8
    moveq #-1,%d3
DSHOOK_152:             /* restore the screen under the alert */
    tstl %d5
    jbeq DSHOOK_174
    movel %d6,%sp@-
    moveal %a5@,%a0
    movel %fp,%a0@
    pea %a0@(-122)
    moveal %d6,%a0
    pea %a0@(6)
    pea DSAlertRect
    clrw %sp@-
    clrl %sp@-
    _CopyBits
    moveal %d5,%sp
    jbra DSHOOK_17C
DSHOOK_174:             /* no saved screen: the windows must be updated */
    clrb DSWndUpdate
    tstl %d4
    jbeq DSHOOK_180
DSHOOK_17C:             /* the port back */
    movel %d4,%sp@-
    _SetPort
DSHOOK_180:             /* done: volOffLinErr if cancelled, else retry through DSHOOKPATCH */
    bset #7,DSAlertRect
    lea %sp@(64),%sp
    tstw %d3
    moveml %sp@+,%d0-%a3/%fp
    jbeq DSHOOK_196
    moveq #-53,%d0	/* volOffLinErr */
    rts
DSHOOK_196:             /* retry the call */
    jbra DSHOOKPATCH
    jmp TrapAgain
    .short  0x0038, 0x00A0, 0x0B00	| orib #-96,b00 <TrapAgain>
    moveb #96,TrapAgain_1
    andiw #255,%d0
    jmp TrapAgain

/* DOEJECT: _Eject: eject the disk in drive d0. */
trap_DOEJECT:

/* VDOEJECT: vectored entry: _Eject: eject the disk in drive d0. */
DOEJECT:
VDOEJECT:
    jbsr MAKESTKPB
    movew %d1,%a0@(22)
    movel EjectNotify,%d0
    jble DOEJECT_24
    moveml %d2/%a0-%a2,%sp@-
    clrw %sp@-
    movew %d1,%sp@-
    movew %d2,%sp@-
    moveal %d0,%a0
    jsr %a0@
    tstb %sp@+
    moveml %sp@+,%d2/%a0-%a2
    jbeq DOEJECT_2E
DOEJECT_24:             /* _Eject (a beep if it fails) */
    _Eject
    jbeq DOEJECT_2E
    movew #8,%sp@-
    _SysBeep
DOEJECT_2E:             /* free the parameter block, return */
    lea %sp@(64),%sp
    rts

/* INITFS: _InitFS(d0 = FCB count): File Manager globals, FCB buffer, VCB queue, cache. */
trap_InitFS:
INITFS:
    tstw FSFCBLen
    jbpl INITFS_E6
    movew #94,FSFCBLen	/* FCBs are 94 bytes */
    lea CkdDB,%a0
    moveq #80,%d1
INITFS_14:              /* clear the File Manager globals (CkdDB...) */
    clrw %a0@+
    dbf %d1,INITFS_14
    movew #2,DrMstrBlk
    cmpiw #2,MemTop
    jble INITFS_2A
    lslw #2,%d0
INITFS_2A:              /* the FCB buffer: d0 FCBs of 94 bytes (4 times as many with more than 2 MB of RAM) */
    movew %d0,%d2
    muluw #94,%d0
    addqw #2,%d0
    movew %d0,%d1
    .short  0xA71E	| 4080F39C _NewPtr (flags 0x0700)
    jbne INITFS_EA
    movew %d1,%a0@
    movel %a0,FCBSPtr
    muluw #16,%d2
    movel %d2,%d0
    addqw #2,%d0
    movew %d0,%d1
    .short  0xA71E	| 4080F3B2 _NewPtr (flags 0x0700)
    jbne INITFS_EA
    movew %d1,%a0@
    movel %a0,WDCBsPtr
    biglea WDCBSWOS, a2
    moveaw %a2@,%a2
    addal SwitcherTPtr,%a2
    movel %a0,%a2@
    notl %a2@+
    movew %d1,%a2@
    movel #1296,%d0
    .short  0xA71E	| 4080F3DA _NewPtr (flags 0x0700)
    jbne INITFS_EA
    lea %a0@(1280),%a0
    movel %a0,HFSVars_HFSStkTop
    moveq #56,%d0
    .short  0xA71E	| 4080F3E8 _NewPtr (flags 0x0700)
    jbne INITFS_EA
    biglea PMSPSWOS, a2
    moveaw %a2@,%a2
    addal SwitcherTPtr,%a2
    movel %a0,%a2@
    notl %a2@
    addql #6,%a0
    moveq #50,%d0
    movew %d0,%a0@
    movel %a0,PMSPPtr
    movew #512,%d1
    moveq #1,%d0
    jsr %pc@(INITCACHE)
    jbne INITFS_EA
    movel %a1,SysBMCPtr
    moveq #1,%d0
    cmpiw #2,MemTop
    jble INITFS_BE
    moveq #2,%d0
INITFS_BE:              /* the volume cache (1 block, 2 with more than 2 MB) */
    jsr %pc@(INITCACHE)
    jbne INITFS_EA
    movel %a1,SysVolCPtr
    moveq #4,%d0
    cmpiw #2,MemTop
    jble INITFS_D4
    moveq #16,%d0
INITFS_D4:              /* the control (B-tree) cache: 4 blocks, 16 with more than 2 MB; the disk-switch hook */
    jsr %pc@(INITCACHE)
    jbne INITFS_EA
    movel %a1,SysCtlCPtr
    lea %pc@(DSHOOK),%a0
    movel %a0,DskSwtchHook
INITFS_E6:              /* no error */
    moveq #0,%d0
    rts
INITFS_EA:              /* no memory: -1 */
    moveq #-1,%d0
    rts

/* DIVUP: divide, rounding up. */
DIVUP:
    divuw %d1,%d0
    swap %d0
    tstw %d0
    jbeq DIVUP_10
    clrw %d0
    swap %d0
    addqw #1,%d0
    jbra DIVUP_12
DIVUP_10:               /* no remainder */
    swap %d0
DIVUP_12:               /* return */
    rts

/* ROUNDALLOC: round a byte count up to allocation blocks. */
ROUNDALLOC:
    movel %d1,%sp@-
    movel %d0,%sp@-
    movel %d1,%d0
    movel %a2@(28),%d1
    jbsr DIVUP
    movel %d0,%d1
    movel %sp@+,%d0
    movel %d1,%sp@-
    movel %a2@(28),%d1
    jbsr DIVUP
    movel %sp@+,%d1
    jbsr DIVUP
    muluw %d1,%d0
    movel %sp@+,%d1
    rts

ROUNDALLOC_22:          /* find in queue a0 the element whose word at +d1 is d0 (Z set if found, a0 = it) */
    movel %d2,%sp@-
    movel %a0@(2),%d2
ROUNDALLOC_28:          /* next element */
    jbeq ROUNDALLOC_3E
    moveal %d2,%a0
    cmpw %a0@(0x0,%d1:w),%d0
    jbeq ROUNDALLOC_36
    movel %a0@,%d2
    jbra ROUNDALLOC_28
ROUNDALLOC_36:          /* found */
    moveq #0,%d0
ROUNDALLOC_38:          /* return */
    movel %sp@+,%d2
    tstw %d0
    rts
ROUNDALLOC_3E:          /* not found: -1 */
    moveq #-1,%d0
    jbra ROUNDALLOC_38

/* GETVCBRFN: the VCB of a refnum or name. */
GETVCBRFN:              /* (a VCB by vRefNum: vcbVRefNum, +78) */
    moveml %d1/%a0,%sp@-
    moveq #78,%d1	/* by vcbVRefNum */
    lea VCBQHdr_Flags,%a0
    jbsr ROUNDALLOC_22
    jbne GETVCBRFN_16
    moveal %a0,%a2
GETVCBRFN_10:           /* restore registers, return */
    moveml %sp@+,%d1/%a0
    rts
GETVCBRFN_16:           /* nsvErr */
    moveq #-35,%d0	/* nsvErr */
    jbra GETVCBRFN_10

GETVCBRFN_1A:           /* the VCB of drive d0 (vcbDrvNum +72, or vcbDRefNum +74 = -drive for an off-line volume) */
    moveml %d1-%d2,%sp@-
    movew %d0,%d1
    movew %d0,%d2
    negw %d2
    moveal VCBQHdr_Head,%a2
GETVCBRFN_28:           /* next VCB */
    movel %a2,%d0
    jbeq GETVCBRFN_4A
    cmpw %a2@(72),%d1
    jbeq GETVCBRFN_42
    tstw %a2@(72)
    jbne GETVCBRFN_3E
    cmpw %a2@(74),%d2
    jbeq GETVCBRFN_42
GETVCBRFN_3E:           /* next */
    moveal %a2@,%a2
    jbra GETVCBRFN_28
GETVCBRFN_42:           /* found */
    moveq #0,%d0
GETVCBRFN_44:           /* return */
    moveml %sp@+,%d1-%d2
    rts
GETVCBRFN_4A:           /* nsvErr */
    moveq #-35,%d0	/* nsvErr */
    jbra GETVCBRFN_44

GETVCBRFN_4E:           /* the VCB of working directory d0 (a WDCB, 16 bytes each) */
    moveal WDCBsPtr,%a3
    moveml %d1/%a1,%sp@-
    moveq #0,%d1
    movew %d0,%d1
    jbsr GETWDINFO_E6
    jbne GETVCBRFN_70
    subiw #-32767,%d1
    addaw %d1,%a3
    moveq #-35,%d0	/* nsvErr */
    movel %a3@,%d1
    jbeq GETVCBRFN_70
    moveal %d1,%a2
    moveq #0,%d0
GETVCBRFN_70:           /* return */
    moveml %sp@+,%d1/%a1
    tstw %d0
    rts

/* MARKVCB: mark the VCB dirty. */
MARKVCB:
    jbsr MARKVCBTIME_8

/* MARKVCBTIME: mark the VCB dirty and set its modification time. */
MARKVCBTIME:
    movel Time,%a2@(14)
    rts

MARKVCBTIME_8:          /* vcbFlags: dirty */
    st %a2@(6)
    rts

/* FLUSHMDB: write the master directory block (and its copy) of a volume. */
FLUSHMDB:
    movel 0x6d0,%sp@-	/* through the vector at 0x6D0 (normally VFLUSHMDB; patchable) */
    rts

/*
 VFLUSHMDB: write the volume's master directory block (block 2) if the VCB is dirty:
 the VCB fields from vcbSigWord (162 bytes) and from vcbVolBkUp (66 bytes), and the
 extents and catalog files' first extent records and sizes (from their FCBs). Its
 own a6 stack (the File Manager's).
*/
trap_VFLUSHMDB:
VFLUSHMDB:
    movel %sp@+,%fp@-
    moveml %d0-%d2/%a0-%a1,%fp@-
    tstb %a2@(6)	/* vcbFlags: dirty? */
    jbpl VFLUSHMDB_B8
    moveal %a2@(84),%a1
    movew %a2@(78),%d0
    moveq #0,%d1
    moveq #2,%d2	/* block 2: the MDB */
    jsr %pc@(GETBLOCK)
    jbne VFLUSHMDB_B8
    moveal %a0,%a1
    lea %a2@(8),%a0
    movel #162,%d0	/* the VCB from vcbSigWord, 162 bytes */
    _BlockMove
    lea %a2@(94),%a0
    lea %a1@(64),%a1
    moveq #66,%d0
    _BlockMove
    subaw #64,%a1
    moveal FCBSPtr,%a3
    movew %a2@(164),%d1	/* the extents file's FCB (vcbXTRef) */
    moveml %a0-%a1,%sp@-
    moveq #12,%d0
    lea %a3@(0x26,%d1:w),%a0
    lea %a1@(134),%a1
    _BlockMove
    moveml %sp@+,%a0-%a1
    movel %a3@(0xc,%d1:w),%d0
    movel %d0,%a1@(130)
    bclr #7,%a3@(0x4,%d1:w)
    movel %a2@(28),%d1
    jsr %pc@(DIVUP)
    movew %d0,%a2@(160)
    movew %a2@(166),%d1	/* the catalog file's FCB (vcbCTRef) */
    moveml %a0-%a1,%sp@-
    moveq #12,%d0
    lea %a3@(0x26,%d1:w),%a0
    lea %a1@(150),%a1
    _BlockMove
    moveml %sp@+,%a0-%a1
    movel %a3@(0xc,%d1:w),%d0
    movel %d0,%a1@(146)
    bclr #7,%a3@(0x4,%d1:w)
    movel %a2@(28),%d1
    jsr %pc@(DIVUP)
    movew %d0,%a2@(162)
    moveq #1,%d1
    moveal %a1,%a0
    moveal %a2@(84),%a1
    jsr %pc@(RELBLOCK)
    clrb %a2@(6)
VFLUSHMDB_B8:           /* restore, return */
    moveml %fp@+,%d0-%d2/%a0-%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* MAKESTKPB: a parameter block on the stack. */
MAKESTKPB:
    moveal %sp@+,%a0
    moveq #31,%d0
MAKESTKPB_4:            /* 64 bytes, cleared */
    clrw %sp@-
    dbf %d0,MAKESTKPB_4
    movel %a0,%sp@-
    moveal %sp,%a0
    addqw #4,%a0
    rts

/*
 _MountVol(ioVRefNum = drive): read the master directory block, build the VCB, open
 the extents and catalog B-trees. If there is not enough memory (or FCBs), another
 volume is put off line and the mount tried again.
*/
trap_MountVol:
MOUNTVOL:
    movew %a0@(22),%d2
    moveml %d1-%d2/%a0-%a1,%sp@-
    jbsr MOUNTVOL_50
    moveml %sp@+,%d1-%d2/%a0-%a1
    cmpiw #-108,%d0
    jbeq MOUNTVOL_1C
    cmpiw #-42,%d0
    jbeq MOUNTVOL_1C
    rts
MOUNTVOL_1C:            /* no memory or too many files open: take another volume off line and try again */
    movew %d2,%a0@(22)
MOUNTVOL_20:            /* an on-line volume that is not the boot volume */
    movel VCBQHdr_Head,%d0
MOUNTVOL_24:            /* next VCB */
    jbeq MOUNTVOL_4C
    moveal %d0,%a1
    tstw %a1@(76)
    jbne MOUNTVOL_34
    movew %a1@(72),%d2
    jbne MOUNTVOL_38
MOUNTVOL_34:            /* next */
    movel %a1@,%d0
    jbra MOUNTVOL_24
MOUNTVOL_38:            /* put it off line (frees its buffers) */
    movel %a0,%sp@-
    jbsr MAKESTKPB
    movew %d2,%a0@(22)
    _OffLine
    lea %sp@(64),%sp
    moveal %sp@+,%a0
    jbne MOUNTVOL_20
    jbra trap_MountVol
MOUNTVOL_4C:            /* memFullErr */
    moveq #-108,%d0	/* memFullErr */
    rts

MOUNTVOL_50:            /* the mount itself: queue the call, find the drive */
    jbsr FSQUEUESYNC
    st NewMount
MOUNTVOL_58:            /* (again after making room) */
    moveq #-50,%d0	/* paramErr */
    movew %a0@(22),%d2
    jble MOUNTVOL_70
    movew %d2,%d0
    jbsr GETVCBRFN_1A
    jbne MOUNTVOL_74
    tstw %a2@(72)
    jbeq MOUNTVOL_74
    moveq #-55,%d0	/* volOnLinErr */
MOUNTVOL_70:            /* failed: done */
    jbra VCHECKREMOUNT_12E
MOUNTVOL_74:            /* the drive (FINDDRIVE); a 178-byte VCB; the first volume becomes the default (DefVCBPtr, WDCB 0) */
    jbsr FINDDRIVE
    jbne MOUNTVOL_70
    moveal %a0,%a2
    movel #178,%d0
    .short  0xA71E	| 4080F690 _NewPtr (flags 0x0700)
    jbne MOUNTVOL_70
    lea VCBQHdr_Flags,%a1
    tstl %a1@(2)
    jbne MOUNTVOL_AE
    movel %a0,DefVCBPtr
    moveal WDCBsPtr,%a1
    movel %a0,%a1@(2)
    moveq #2,%d0
    movel %d0,%a1@(6)
    clrl %a1@(10)
    clrl %a1@(14)
    lea VCBQHdr_Flags,%a1
MOUNTVOL_AE:            /* into the VCB queue; drive number (+72), driver refNum (+74), the volume cache */
    jsr %pc@(trap_Enqueue)
    exg %a0,%a2
    movew %d2,%a2@(72)
    movew %d1,%a2@(74)
    moveal SysVolCPtr,%a1
    movel %a1,%a2@(84)
    moveq #0,%d0
MOUNTVOL_C6:            /* a free vRefNum: -1, -2... the first one not in use */
    subqw #1,%d0
    moveml %d0/%a2,%sp@-
    jbsr GETVCBRFN
    moveml %sp@+,%d0/%a2
    jbeq MOUNTVOL_C6
    movew %d0,%a2@(78)
    cmpal DefVCBPtr,%a2
    jbne MOUNTVOL_E4
    movew %d0,DefVRefNum
MOUNTVOL_E4:            /* read the MDB (block 2): 'BD' (HFS); 0xD2D7 (MFS) is noMacDskErr, others too */
    moveq #0,%d1
    moveq #2,%d2
    jsr %pc@(GETBLOCK)
    jbne VCHECKREMOUNT_15A
    moveal %a0,%a5
    moveq #2,%d1
    jsr %pc@(RELBLOCK)
    cmpiw #16964,%a5@
    jbeq MOUNTVOL_108
    moveq #-57,%d0	/* noMacDskErr */
    cmpiw #-11561,%a5@
    jbne VCHECKREMOUNT_15A
MOUNTVOL_108:           /* the allocation block size must be a multiple of 512 (badMDBErr); copy 64 bytes of the MDB into the VCB; the drive's write protection (Status 8) */
    moveq #-60,%d0	/* badMDBErr */
    movel %a5@(20),%d1
    jbeq VCHECKREMOUNT_156
    andiw #511,%d1
    jbne VCHECKREMOUNT_156
    lea %a2@(8),%a1
    moveq #64,%d0
    _BlockMove
    moveal FSQHdr_Head,%a0
    movew %a2@(78),%a0@(22)
    lea Params,%a0
    movew #8,%a0@(26)
    clrb %a0@(30)
    _Status
    moveq #-128,%d0
    andb %a0@(30),%d0
    moveb %d0,%a2@(19)
    jbsr TFSVCBTST
    jbne GETWDINFO_160
    lea %a5@(64),%a0
    lea %a2@(94),%a1
    moveq #66,%d0
    _BlockMove
    movel %a2@(28),%d1
    movel %a5@(130),%d0
    jsr %pc@(DIVUP)
    movew %d0,%a2@(160)
    movel %a5@(146),%d0
    jsr %pc@(DIVUP)
    movew %d0,%a2@(162)
    clrw %a2@(24)
    addql #1,%a2@(100)
    jbsr VBMCHK_8E
    jbne VCHECKREMOUNT_152
    movew %d1,%a2@(164)
    movel %a5@(130),%a1@(0x8,%d1:w)
    movel %a5@(130),%a1@(0xc,%d1:w)
    moveq #12,%d0
    lea %a5@(134),%a0
    lea %a1@(0x26,%d1:w),%a1
    _BlockMove
    jbsr VBMCHK_8E
    jbne VCHECKREMOUNT_152
    movew %d1,%a2@(166)
    movel %a5@(146),%a1@(0x8,%d1:w)
    movel %a5@(146),%a1@(0xc,%d1:w)
    moveq #12,%d0
    lea %a5@(150),%a0
    lea %a1@(0x26,%d1:w),%a1
    _BlockMove
    movel SysBMCPtr,%a2@(80)
    movel SysCtlCPtr,%a2@(168)
    movew %a2@(164),%d0
    moveq #3,%d1
    movel %a2@(104),%d2
    moveal %a2@(168),%a1
    lea %pc@(FXMKEYCMP),%a3
    jbsr VBMCHK_AE
    jbne VCHECKREMOUNT_14C
    movew %a2@(166),%d0
    moveq #4,%d1
MOUNTVOL_1F2:           /* open the extents B-tree (FCB vcbXTRef, file 3) and the catalog B-tree (vcbCTRef, file 4) */
    movel %a2@(108),%d2
    moveal %a2@(168),%a1
    lea %pc@(CMKEYCMP),%a3
    jbsr VBMCHK_AE
    jbne VCHECKREMOUNT_14C
    bclr #8,%a2@(18)
    jbeq VCHECKREMOUNT_184
MOUNTVOL_210:           /* on to the remount check (VCHECKREMOUNT), unless the volume was unmounted cleanly (vcbAtrb bit 8) */
    movel 0x6c0,%sp@-	/* through the vector at 0x6C0 (normally VCHECKREMOUNT; patchable) */
    rts

/*
 VCHECKREMOUNT: is the volume just read an off-line volume already known (same
 signature, creation date and name)? Then its open files must still match (each open
 file's catalog entry or MFS directory entry, same start block and length); if so the
 old VCB takes over (its vRefNum and FCBs kept), the new one is discarded. Then the
 MDB is marked and flushed.
*/
trap_VCHECKREMOUNT:
VCHECKREMOUNT:
    movel VCBQHdr_Head,%d0
VCHECKREMOUNT_4:        /* next VCB: the same volume? */
    jbeq VCHECKREMOUNT_12C
    moveal %d0,%a4
    cmpal %a4,%a2
    jbeq VCHECKREMOUNT_38
    movew %a4@(8),%d0
    cmpw %a2@(8),%d0
    jbne VCHECKREMOUNT_38
    movel %a4@(10),%d0
    cmpl %a2@(10),%d0
    jbne VCHECKREMOUNT_38
    lea %a4@(44),%a1
    lea %a2@(44),%a3
    moveq #13,%d0
VCHECKREMOUNT_2C:       /* compare the names (28 bytes) */
    cmpmw %a1@+,%a3@+
    dbne %d0,VCHECKREMOUNT_2C
    jbne VCHECKREMOUNT_38
    tstw %a1@
    jbeq VCHECKREMOUNT_3C
VCHECKREMOUNT_38:       /* next VCB */
    movel %a4@,%d0
    jbra VCHECKREMOUNT_4
VCHECKREMOUNT_3C:       /* check the old volume's open files */
    jbsr GETWDINFO_3A8
VCHECKREMOUNT_40:       /* an FCB of the old volume */
    cmpal %a1@(0x14,%d1:w),%a4
    jbne VCHECKREMOUNT_CC
    jbsr TFSVCBTST
    jbeq VCHECKREMOUNT_88
    movew %a1@(0x1c,%d1:w),%d3
    jbsr VFILEWRITE_F2
    jbne VCHECKREMOUNT_38
    moveq #0,%d0
    movel %a1@(0x0,%d1:w),%d3
VCHECKREMOUNT_5E:       /* MFS: find the file's directory entry, the same start block? */
    cmpl %a5@(0x12,%d0:w),%d3
    jbeq VCHECKREMOUNT_6C
    jbsr FILECREATE_1A8
    jbcs VCHECKREMOUNT_5E
    jbra VCHECKREMOUNT_38
VCHECKREMOUNT_6C:       /* the fork's start block and length */
    lea %a5@(0x16,%d0:w),%a3
    btst #1,%a1@(0x4,%d1:w)
    jbeq VCHECKREMOUNT_7C
    lea %a5@(0x20,%d0:w),%a3
VCHECKREMOUNT_7C:       /* compare */
    movew %a3@+,%d0
    cmpw %a1@(0x6,%d1:w),%d0
    jbne VCHECKREMOUNT_38
    movel %a3@+,%d0
    jbra VCHECKREMOUNT_C4
VCHECKREMOUNT_88:       /* HFS: the file's catalog record (file ID >= 16) */
    movel %a1@(0x0,%d1:w),%d0
    cmpil #16,%d0
    jbcs VCHECKREMOUNT_CC
    moveml %d2/%a0-%a1,%fp@-
    movel %a1@(0x3a,%d1:w),%d0
    lea %a1@(0x3e,%d1:w),%a0
    moveq #0,%d2
    jsr %pc@(CMGETCN)
    moveal %a1,%a3
    moveml %fp@+,%d2/%a0-%a1
    jbne VCHECKREMOUNT_38
    cmpib #2,%a3@
    jbne VCHECKREMOUNT_38
    movel %a3@(26),%d0
    btst #1,%a1@(0x4,%d1:w)
    jbeq VCHECKREMOUNT_C4
    movel %a3@(36),%d0
VCHECKREMOUNT_C4:       /* same physical length? */
    cmpl %a1@(0x8,%d1:w),%d0
    jbne VCHECKREMOUNT_38
VCHECKREMOUNT_CC:       /* next FCB; all match: remount: copy the new VCB data into the old one */
    jbsr GETWDINFO_3B0
    jbcs VCHECKREMOUNT_40
    clrb NewMount
    movew %a4@(78),%d1
    lea %a2@(8),%a0
    lea %a4@(8),%a1
    moveq #86,%d0
    jbsr TFSVCBTST
    jbne VCHECKREMOUNT_F0
    movew #170,%d0
VCHECKREMOUNT_F0:       /* 86 bytes (MFS) or 170 (HFS) */
    _BlockMove
    movew %d1,%a4@(78)
    jbsr TFSVCBTST
    jbne VCHECKREMOUNT_110
    moveal FCBSPtr,%a1
    movew %a2@(164),%d0
    movel %a4,%a1@(0x14,%d0:w)
    movew %a2@(166),%d0
    movel %a4,%a1@(0x14,%d0:w)
VCHECKREMOUNT_110:      /* the B-tree FCBs point to the old VCB; dispose of the new one */
    jbsr OFFLINE_8
    moveal %a2,%a0
    moveal %a4,%a2
    lea VCBQHdr_Flags,%a1
    jsr %pc@(trap_Dequeue)
    _DisposPtr
    moveal FSQHdr_Head,%a0
    movew %a2@(78),%a0@(22)
VCHECKREMOUNT_12C:      /* no error */
    moveq #0,%d0
VCHECKREMOUNT_12E:      /* write the MDB back (unless write-protected), done */
    tstw %d0
    jbne VCHECKREMOUNT_148
    jbsr TFSVCBTST
    jbne VCHECKREMOUNT_148
    btst #7,%a2@(19)
    jbne VCHECKREMOUNT_148
    jbsr MARKVCBTIME_8
    jbsr FLUSHMDB
VCHECKREMOUNT_148:      /* done */
    jbra CMDDONE
VCHECKREMOUNT_14C:      /* a B-tree error: badMDBErr */
    movew %d0,HFSDSErr
    moveq #-60,%d0	/* badMDBErr */
VCHECKREMOUNT_152:      /* free the B-tree FCBs */
    jbsr VBMCHK_1A
VCHECKREMOUNT_156:      /* drop the cached blocks */
    jbsr VBMCHK_70
VCHECKREMOUNT_15A:      /* a new mount failed: remove the VCB; else leave it off line */
    tstb NewMount
    jbeq VCHECKREMOUNT_172
    jbsr VBMCHK_3C
VCHECKREMOUNT_164:      /* memory or FCB trouble: try again (MOUNTVOL_58) */
    tstw %d0
    jble CMDDONE
    moveal FSQHdr_Head,%a0
    jbra MOUNTVOL_58
VCHECKREMOUNT_172:      /* leave it off line: drive 0, driver refNum = -drive, no buffers */
    lea %a2@(72),%a2
    movew %a2@,%d3
    clrw %a2@+
    movew %d3,%a2@+
    addqw #4,%a2
    clrl %a2@+
    clrl %a2@+
    jbra VCHECKREMOUNT_164
VCHECKREMOUNT_184:      /* on to the consistency check (VMTCHECK) */
    movel 0x6bc,%sp@-	/* through the vector at 0x6BC (normally VMTCHECK; patchable) */
    rts

/*
 VMTCHECK: after an unclean unmount, check and repair the volume: the root folder's name
 equals the volume name (renamed if needed); every extent is marked in the bitmap; the
 catalog is counted (files, folders, those in the root, the largest ID) and the VCB
 counts fixed; then the free block count.
*/
trap_VMTCHECK:
VMTCHECK:
    moveq #2,%d0
    moveq #0,%d2
    moveal %d2,%a0
    jsr %pc@(CMGETCN)
    jbne VCHECKREMOUNT_14C
    moveq #0,%d0
    lea %a0@(6),%a1
    moveb %a1@+,%d0
    swap %d0
    lea %a2@(44),%a0
    moveb %a0@+,%d0
    swap %d0
    .short  0xA63C	| 4080F9CC _CmpString (flags 0x0600)
    jbeq VMTCHECK_64
    subql #1,%a1
    subql #1,%a0
    moveq #0,%d0
    moveb %a0@,%d0
    jbeq VMTCHECK_48
    cmpiw #27,%d0
    jble VMTCHECK_36
    moveb #27,%a0@
VMTCHECK_36:            /* the root folder takes the volume's name */
    moveq #2,%d0
    moveal %a0,%a1
    subal %a0,%a0
    moveq #0,%d2
    jsr %pc@(CMRENAMECN)
    jbne VCHECKREMOUNT_14C
    jbra VMTCHECK_64
VMTCHECK_48:            /* the volume takes the root folder's name (at most 27 characters) */
    moveq #0,%d0
    moveb %a1@,%d0
    jbeq VCHECKREMOUNT_14C
    cmpiw #27,%d0
    jble VMTCHECK_58
    moveq #27,%d0
VMTCHECK_58:            /* copy it */
    moveb %d0,%a0@+
    subqw #1,%d0
    addql #1,%a1
VMTCHECK_5E:            /* copy */
    moveb %a1@+,%a0@+
    dbf %d0,VMTCHECK_5E
VMTCHECK_64:            /* check the B-tree files' extents in the bitmap, then walk the catalog leaves */
    moveal FCBSPtr,%a1
    movew %a2@(164),%d1
    lea %a1@(0x26,%d1:w),%a0
    jbsr VMTCHECK_1D6
    movew %a2@(166),%d1
    lea %a1@(0x26,%d1:w),%a0
    jbsr VMTCHECK_1D6
    moveq #2,%d0
    subal %a0,%a0
    jsr %pc@(CMGETCN)
    jbne VCHECKREMOUNT_14C
    moveal FCBSPtr,%a1
    movew %a2@(166),%d1
    movel %a1@(0xc,%d1:w),%d0
    moveq #70,%d1
    jbsr DIVUP
    movel %d0,%d2
    moveq #15,%d4
    moveq #0,%d3
    moveq #0,%d5
    moveq #0,%d6
    moveq #0,%d7
VMTCHECK_AA:            /* next catalog record (leaf nodes of 70-byte records at most) */
    subql #1,%d2
    jblt VCHECKREMOUNT_14C
    movew %a2@(166),%d0
    moveq #1,%d1
    movel %d2,%fp@-
    jsr %pc@(BTGETRECORD)
    movel %fp@+,%d2
    tstw %d0
    jbne VMTCHECK_116
    cmpib #1,%a1@
    jbne VMTCHECK_E6
    addql #1,%d6
    cmpil #2,%a0@(2)
    jbne VMTCHECK_DA
    swap %d7
    addqw #1,%d7
    swap %d7
VMTCHECK_DA:            /* a folder (1): count it; in the root? the largest ID */
    cmpl %a1@(6),%d4
    jbcc VMTCHECK_AA
    movel %a1@(6),%d4
    jbra VMTCHECK_AA
VMTCHECK_E6:            /* a file (2): count it; in the root? the largest ID; its extents */
    cmpib #2,%a1@
    jbne VMTCHECK_AA
    addql #1,%d5
    cmpil #2,%a0@(2)
    jbne VMTCHECK_FA
    addqw #1,%d7
VMTCHECK_FA:            /* the largest ID */
    cmpl %a1@(20),%d4
    jbcc VMTCHECK_104
    movel %a1@(20),%d4
VMTCHECK_104:           /* the data and resource forks' first extents */
    lea %a1@(74),%a0
    jbsr VMTCHECK_1D6
    lea %a1@(86),%a0
    jbsr VMTCHECK_1D6
    jbra VMTCHECK_AA
VMTCHECK_116:           /* end of the catalog (32): fix the next ID, the counts (vcbAtrb bits record what changed) */
    cmpiw #32,%d0
    jbne VCHECKREMOUNT_14C
    cmpl %a2@(38),%d4
    jbcs VMTCHECK_132
    addql #1,%d4
    movel %d4,%a2@(38)
    bset #0,%a2@(19)
    moveq #-1,%d3
VMTCHECK_132:           /* file count */
    cmpl %a2@(114),%d5
    jbeq VMTCHECK_144
    movel %d5,%a2@(114)
    bset #1,%a2@(19)
    moveq #-1,%d3
VMTCHECK_144:           /* folder count */
    cmpl %a2@(118),%d6
    jbeq VMTCHECK_156
    movel %d6,%a2@(118)
    bset #1,%a2@(19)
    moveq #-1,%d3
VMTCHECK_156:           /* files in the root */
    cmpw %a2@(20),%d7
    jbeq VMTCHECK_168
    movew %d7,%a2@(20)
    bset #1,%a2@(19)
    moveq #-1,%d3
VMTCHECK_168:           /* folders in the root */
    swap %d7
    cmpw %a2@(112),%d7
    jbeq VMTCHECK_17C
    movew %d7,%a2@(112)
    bset #1,%a2@(19)
    moveq #-1,%d3
VMTCHECK_17C:           /* then every extent record of the extents file */
    moveal FCBSPtr,%a1
    movew %a2@(164),%d1
    movel %a1@(0xc,%d1:w),%d0
    moveq #12,%d1
    jbsr DIVUP
    movel %d0,%d5
    movew %a2@(164),%d0
    subqw #8,%fp
    moveal %fp,%a0
    movew #1792,%a0@
    clrl %a0@(2)
    clrw %a0@(6)
    moveq #0,%d2
    jsr %pc@(BTSEARCH)
    addqw #8,%fp
    moveq #0,%d1
VMTCHECK_1AE:           /* next extent record */
    subql #1,%d5
    jblt VCHECKREMOUNT_14C
    movew %a2@(164),%d0
    jsr %pc@(BTGETRECORD)
    jbne VMTCHECK_1C6
    moveal %a1,%a0
    jbsr VMTCHECK_1D6
    moveq #1,%d1
    jbra VMTCHECK_1AE
VMTCHECK_1C6:           /* done: recount the free blocks */
    cmpiw #32,%d0
    jbne VCHECKREMOUNT_14C
    jsr %pc@(UPDATEFREE)
    jbra MOUNTVOL_210

VMTCHECK_1D6:           /* check an extent record (through VBMCHK) */
    movel 0x7c0,%sp@-	/* through the vector at 0x7C0 (normally VBMCHK; patchable) */
    rts

/*
 VBMCHK (a0 = extent record): are its blocks marked in the volume bitmap? If not, mark
 them (vcbAtrb bit 2).
*/
trap_VBMCHK:
VBMCHK:
    movel %sp@+,%fp@-
    jbsr SETVOLINFO_A8
    jbne VBMCHK_16
    jsr %pc@(BLKCHK)
    jbeq VBMCHK_16
    moveq #-1,%d3
    bset #2,%a2@(19)
VBMCHK_16:              /* return */
    movel %fp@+,%sp@-
    rts

VBMCHK_1A:              /* free the B-tree FCBs of the volume */
    moveml %d0-%d1/%a1,%sp@-
    moveal FCBSPtr,%a1
    movew %a2@(164),%d1
    jbeq VBMCHK_2C
    clrl %a1@(0x0,%d1:w)
VBMCHK_2C:              /* catalog FCB */
    movew %a2@(166),%d1
    jbeq VBMCHK_36
    clrl %a1@(0x0,%d1:w)
VBMCHK_36:              /* return */
    moveml %sp@+,%d0-%d1/%a1
    rts

VBMCHK_3C:              /* remove the volume: free its working directories, dequeue and dispose of the VCB */
    movel %d0,%sp@-
    jbsr FILECREATE_1CE
VBMCHK_42:              /* each WDCB of it */
    jbne VBMCHK_52
    clrl %a1@(0x0,%d1:w)
    clrl %a1@(0x4,%d1:w)
    jbsr FILECREATE_1D6
    jbra VBMCHK_42
VBMCHK_52:              /* dequeue the VCB; the default volume? */
    moveal %a2,%a0
    lea VCBQHdr_Flags,%a1
    jsr %pc@(trap_Dequeue)
    cmpal DefVCBPtr,%a2
    jbne VBMCHK_6A
    clrl DefVCBPtr
    clrw DefVRefNum
VBMCHK_6A:              /* dispose of it */
    _DisposPtr
    movel %sp@+,%d0
    rts

VBMCHK_70:              /* drop the volume's blocks from the three caches */
    movel %a1,%sp@-
    moveal SysBMCPtr,%a1
VBMCHK_76:              /* bitmap, volume and control caches */
    jsr %pc@(TRASHVBLKS)
    moveal SysVolCPtr,%a1
    jsr %pc@(TRASHVBLKS)
    moveal SysCtlCPtr,%a1
    jsr %pc@(TRASHVBLKS)
    moveal %sp@+,%a1
    rts

VBMCHK_8E:              /* a free FCB (d1 = its offset), tmfoErr if none */
    jbsr GETWDINFO_3A8
    jbra VBMCHK_A4
VBMCHK_94:              /* free? claim it (-1) */
    tstl %a1@(0x0,%d1:w)
    jbne VBMCHK_A4
    moveq #-1,%d0
    movel %d0,%a1@(0x0,%d1:w)
    moveq #0,%d0
    jbra VBMCHK_AC
VBMCHK_A4:              /* next FCB */
    jbsr GETWDINFO_3B0
    jbcs VBMCHK_94
    moveq #-42,%d0	/* tmfoErr */
VBMCHK_AC:              /* return */
    rts

VBMCHK_AE:              /* open B-tree file d0 (file ID d1, clump size d2, key compare a3) in its FCB */
    movel %sp@+,%fp@-
    moveml %d3/%a0,%fp@-
    moveal FCBSPtr,%a0
    lea %a0@(0x0,%d0:w),%a0
    clrw %a0@(4)
    clrw %a0@(6)
    clrl %a0@(16)
    movel %d1,%a0@
    movel %a2,%a0@(20)
    movel %d2,%a0@(30)
    moveal %a3,%a0
    jsr %pc@(BTOPEN)
    moveml %fp@+,%d3/%a0
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* FINDDRIVE: find the drive queue element of a drive number. */
FINDDRIVE:
    movel 0x6c8,%sp@-	/* through the vector at 0x6C8 (normally VFINDDRIVE; patchable) */
    rts

/* VFINDDRIVE: vectored entry: find the drive queue element of a drive number. */
trap_VFINDDRIVE:
VFINDDRIVE:             /* find drive d2 in the drive queue: a3 = its element, d1 = its driver refNum; extFSErr for another file system's drive (dQFSID) */
    movel %a0,%sp@-
    movew %d2,%d0
    lea DrvQHdr,%a0
    moveq #6,%d1
    jbsr ROUNDALLOC_22
    jbne VFINDDRIVE_22
    moveal %a0,%a3
    movew %a0@(8),%d1
    movew %a0@(10),%d0
    jbeq VFINDDRIVE_1E
    moveq #-58,%d0	/* extFSErr */
VFINDDRIVE_1E:          /* return */
    moveal %sp@+,%a0
    rts
VFINDDRIVE_22:          /* nsDrvErr */
    moveq #-56,%d0	/* nsDrvErr */
    jbra VFINDDRIVE_1E

/* OFFLINE: _Offline: flush the volume and release its buffers. */
trap_OffLine:
OFFLINE:
    st NoEject
    jbra EJECT_4
OFFLINE_8:              /* flush only the caches (for a remount) */
    movel %sp@+,%fp@-
    moveml %d1-%d2/%a1,%fp@-
    clrb FlushOnly
    jbra OFFLINE_66

OFFLINE_14:             /* flush the volume: MDB, close the B-trees (unless only flushing) */
    movel %sp@+,%fp@-
    moveml %d1-%d2/%a1,%fp@-
    jbsr TFSVCBTST
    jbne OFFLINE_66
    tstb FlushOnly
    jbne OFFLINE_36
    jbsr SETVOLINFO_A8
    jbne OFFLINE_36
    bset #8,%a2@(18)
    jbsr MARKVCBTIME_8
OFFLINE_36:             /* write the MDB, close the catalog */
    jsr %pc@(FLUSHMDB)
    moveal FCBSPtr,%a1
    movew %a2@(166),%d1
    jbsr VFILECLOSE_1A
    jbne OFFLINE_9C
    tstb FlushOnly
    jbne OFFLINE_52
    clrw %a2@(166)
OFFLINE_52:             /* and the extents B-tree */
    movew %a2@(164),%d1
    jbsr VFILECLOSE_1A
    jbne OFFLINE_9C
    tstb FlushOnly
    jbne OFFLINE_66
    clrw %a2@(166)
OFFLINE_66:             /* flush its blocks from the three caches */
    moveq #0,%d1
    st SysCRefCnt
    moveal SysBMCPtr,%a1
    movew %a2@(78),%d0
    jsr %pc@(FLUSHCACHE)
    moveal SysCtlCPtr,%a1
    movew %a2@(78),%d0
    jsr %pc@(FLUSHCACHE)
    moveal SysVolCPtr,%a1
    movew %a2@(78),%d0
    jsr %pc@(FLUSHCACHE)
    tstb FlushOnly
    jbne OFFLINE_9A
    jbsr VBMCHK_70
OFFLINE_9A:             /* no error */
    moveq #0,%d0
OFFLINE_9C:             /* return */
    moveml %fp@+,%d1-%d2/%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* EJECT: _Eject. */
trap_Eject:
EJECT:
    clrb NoEject

EJECT_4:                /* flush the volume, put it off line, eject */
    jbsr FSQUEUESYNC
    jbsr VCKEXTFS_A
    jbne EJECT_16
    jbsr FLUSHVOL_3C
    jbne EJECT_28
    jbra EJECT_2C
EJECT_16:               /* no such volume: a drive number? eject that drive */
    movew %a0@(22),%d2
EJECT_1A:               /* find the drive */
    jbsr FINDDRIVE
    jbne EJECT_28
    tstb NoEject
    jbeq EJECT_BE
EJECT_28:               /* done */
    jbra CMDDONE
EJECT_2C:               /* the volume's drive */
    lea %a2@(72),%a1
    movew %a1@,%d2
    jbne EJECT_48
    movew %a1@(2),%d2
    jbpl EJECT_28
    tstb NoEject
    jbne EJECT_28
    negw %d2
    negw %a1@(2)
    jbra EJECT_1A
EJECT_48:               /* a non-ejectable drive (type 8 and up: hard disk) only goes off line */
    jbsr FINDDRIVE
    jbne EJECT_28
    tstb NoEject
    jbne EJECT_6E
    cmpib #8,%a3@(-3)
    jblt EJECT_6E
    st NoEject
    cmpib #64,%a3@(-3)
    jblt EJECT_6E
    moveb #1,NoEject
EJECT_6E:               /* close its files, flush, off line */
    st FlushOnly
    jbsr UNMOUNTVOL_68
    jbsr TFSVCBTST
    jbne EJECT_86
    clrb FlushOnly
    jbsr OFFLINE_14
    jbra EJECT_92
EJECT_86:               /* MFS */
    jbsr GETWDINFO_2B6
    jbsr GETWDINFO_1AC
    jbsr VBMCHK_70
EJECT_92:               /* drive 0, driver refNum = -drive (off line) */
    clrw %a1@+
    tstb NoEject
    jbeq EJECT_9C
    negw %d2
EJECT_9C:               /* off line */
    movew %d2,%a1@+
    tstb NoEject
    jbeq EJECT_BE
    moveal %a2,%a0
    lea VCBQHdr_Flags,%a1
    bsrl trap_Dequeue
    bsrl trap_Enqueue
    tstb NoEject
    jbmi EJECT_28
EJECT_BE:               /* eject: _Control 7 asynchronously to the driver, CMDDONE as completion */
    lea Params,%a0
EJECT_C2:               /* ioVRefNum = drive, ioRefNum, csCode 7 (eject) */
    lea %a0@(22),%a1
    movew %d2,%a1@+
    movew %d1,%a1@+
    movew #7,%a1@
    lea %pc@(CMDDONE),%a1
    movel %a1,%a0@(12)
    .short  0xA404	| 4080FE14 _Control (flags 0x0400)
    rts

/* UNMOUNTVOL: _UnmountVol: flush and close the volume, free its VCB. */
trap_UnmountVol:
UNMOUNTVOL:
    jbsr FSQUEUESYNC
    clrb FlushOnly
    jbsr VCKEXTFS_A
    jbne FLUSHVOL_38
    moveq #0,%d0
    btst #9,%a0@(6)
    jbne FLUSHVOL_C
    moveml %d1-%d2/%a1,%sp@-
    moveal FCBSPtr,%a1
    moveq #2,%d1
UNMOUNTVOL_26:          /* any open file on it (other than the system's B-trees and the 'Gene' file)? fBsyErr */
    movel %a1@(0x0,%d1:w),%d2
    jbeq UNMOUNTVOL_56
    cmpal %a1@(0x14,%d1:w),%a2
    jbne UNMOUNTVOL_56
    cmpiw #-11561,%a2@(8)
    jbeq UNMOUNTVOL_52
    cmpil #16,%d2
    jbcs UNMOUNTVOL_56
    cmpiw #16964,%a2@(8)
    jbne UNMOUNTVOL_52
    cmpil #1196577824,%d2
    jbeq UNMOUNTVOL_56
UNMOUNTVOL_52:          /* fBsyErr */
    moveq #-47,%d0	/* fBsyErr */
    jbra UNMOUNTVOL_5E
UNMOUNTVOL_56:          /* next FCB */
    addw FSFCBLen,%d1
    cmpw %a1@,%d1
    jbcs UNMOUNTVOL_26
UNMOUNTVOL_5E:          /* restore registers */
    moveml %sp@+,%d1-%d2/%a1
    tstw %d0
    jbne FLUSHVOL_38
    jbra FLUSHVOL_C

UNMOUNTVOL_68:          /* close (flush) every open file of the volume */
    movel %sp@+,%fp@-
    moveml %d1-%a5,%fp@-
    jbsr GETWDINFO_3A8
UNMOUNTVOL_72:          /* next FCB of this volume */
    tstl %a1@(0x0,%d1:w)
    jbeq UNMOUNTVOL_94
    cmpal %a1@(0x14,%d1:w),%a2
    jbne UNMOUNTVOL_94
    jbsr TFSVCBTST
    jbne UNMOUNTVOL_8E
    cmpil #16,%a1@(0x0,%d1:w)
    jbcs UNMOUNTVOL_94
UNMOUNTVOL_8E:          /* close it */
    jbsr VFILECLOSE_1A
    jbne UNMOUNTVOL_9C
UNMOUNTVOL_94:          /* next */
    jbsr GETWDINFO_3B0
    jbcs UNMOUNTVOL_72
    moveq #0,%d0
UNMOUNTVOL_9C:          /* return */
    moveml %fp@+,%d1-%a5
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* FLUSHVOL: _FlushVol: write the volume's dirty buffers and MDB. */
trap_FlushVol:
FLUSHVOL:
    jbsr FSQUEUESYNC_4
    st FlushOnly
    jbsr VCKEXTFS_A
    jbne FLUSHVOL_38
FLUSHVOL_C:             /* flush its files, MDB and caches */
    jbsr FLUSHVOL_3C
    jbne FLUSHVOL_38
    jbsr UNMOUNTVOL_68
    jbne FLUSHVOL_38
    jbsr TFSVCBTST
    jbeq FLUSHVOL_20
    jbsr GETWDINFO_2B6
    jbra FLUSHVOL_38
FLUSHVOL_20:            /* on line: flush (OFFLINE_14) */
    tstw %a2@(72)
    jbeq FLUSHVOL_2C
    jbsr OFFLINE_14
    jbne FLUSHVOL_38
FLUSHVOL_2C:            /* unmounting: remove the VCB */
    tstb FlushOnly
    jbne FLUSHVOL_36
    jbsr VBMCHK_3C
FLUSHVOL_36:            /* no error */
    moveq #0,%d0
FLUSHVOL_38:            /* done */
    jbra CMDDONE

FLUSHVOL_3C:            /* external file system? (VCKEXTFS) */
    movel 0x7b8,%sp@-	/* through the vector at 0x7B8 (normally VCKEXTFS; patchable) */
    rts

/*
 VCKEXTFS: extFSErr if the volume belongs to another file system (vcbFSID +76).
 VCKEXTFS_A: find the volume of the call (VDTRMV3).
*/
trap_VCKEXTFS:
VCKEXTFS:
    movew %a2@(76),%d0
    jbeq VCKEXTFS_8
    moveq #-58,%d0	/* extFSErr */
VCKEXTFS_8:             /* return */
    rts

VCKEXTFS_A:             /* the volume of the call (VDTRMV3) */
    movel 0x7bc,%sp@-	/* through the vector at 0x7BC (normally VDTRMV3; patchable) */
    rts

/*
 VDTRMV3 / VDTRMV1 / VDTRMV2 ("determine volume"): which volume a call refers to: a full
 path name ("Volume:...") names it, else ioVRefNum (a drive number, a vRefNum or a
 working directory refNum), else the default. a2 = the VCB, ReqstVol = it; the path's
 search list (PMSPPtr) is set up for name lookups.
*/
trap_VDTRMV3:
VDTRMV3:                /* a full path name ("Volume:...")? by name, else by ioVRefNum */
    movel %a0@(18),%d2
    moveal %d2,%a4
    jbeq VDTRMV3_E
    tstb %a4@
    jbne VDTRMV1_12E

VDTRMV3_E:              /* no volume name in the path: by ioVRefNum */
    movel 0x778,%sp@-	/* through the vector at 0x778 (normally VDTRMV1; patchable) */
    rts

/* VDTRMV1: volume removal hooks for the desktop manager. */
trap_VDTRMV1:
VDTRMV1:
    moveq #0,%d3
    subal %a3,%a3
    movew %a0@(22),%d0
    jbeq VDTRMV1_28
    jbmi VDTRMV1_12
    jbsr GETVCBRFN_1A
    jbra VDTRMV1_22
VDTRMV1_12:             /* negative: a vRefNum, or a working directory (below -4096) */
    cmpiw #-4096,%d0
    jble VDTRMV1_1E
    jbsr GETVCBRFN
    jbra VDTRMV1_22
VDTRMV1_1E:             /* a working directory */
    jbsr GETVCBRFN_4E
VDTRMV1_22:             /* found? */
    jbeq VDTRMV1_36
VDTRMV1_24:             /* nsvErr */
    moveq #-35,%d0	/* nsvErr */
    rts
VDTRMV1_28:             /* 0: the default volume (and the default directory, WDCB 0) */
    movel DefVCBPtr,%d0
    jbeq VDTRMV1_24
    moveal %d0,%a2
    moveal WDCBsPtr,%a3
    addql #2,%a3
VDTRMV1_36:             /* ReqstVol = it; searching disabled (HFSFlags 5, 6)? clear the search list */
    moveq #0,%d0
    movel %a2,ReqstVol
    btst #6,HFSFlags
    jbne VDTRMV1_4C
    btst #5,HFSFlags
    jbeq VDTRMV1_62
VDTRMV1_4C:             /* clear the search list (24 words) */
    movel %a4,%sp@-
    moveal PMSPPtr,%a4
    addql #2,%a4
    moveq #23,%d0
VDTRMV1_56:             /* clear */
    clrw %a4@+
    dbf %d0,VDTRMV1_56
    moveal %sp@+,%a4
VDTRMV1_5E:             /* no error */
    moveq #0,%d0
VDTRMV1_60:             /* return */
    rts
VDTRMV1_62:             /* a call with a directory ID: no search list */
    btst #9,%a0@(6)
    jbeq VDTRMV1_70
    tstl %a0@(48)
    jbne VDTRMV1_5E
VDTRMV1_70:             /* build the search list: the volume, the directory, then others */
    moveml %d2/%d4/%a1/%a4,%sp@-
    moveal PMSPPtr,%a4
    movew %a4@(-2),%d4
    jbgt VDTRMV1_D6
    moveq #2,%d4
    movew %a2@(78),%d2
    movel %a3,%d0
    jbeq VDTRMV1_8E
VDTRMV1_88:             /* the working directory's dir ID */
    movel %a3@(4),%d0
    jbra VDTRMV1_90
VDTRMV1_8E:             /* the root (2) */
    moveq #2,%d0
VDTRMV1_90:             /* add the default directory, then (HFS) the boot volume's System Folder (BootDrive is its WD), then the Finder's blessed folder (vcbFndrInfo, +122) */
    jbsr VDTRMV1_100
    jbsr TFSVCBTST
    jbne VDTRMV1_C2
    movew BootDrive,%d0
    jbge VDTRMV1_B6
    cmpiw #-4096,%d0
    jbgt VDTRMV1_B6
    jbsr GETVCBRFN_4E
    jbne VDTRMV1_B6
    cmpw %a2@(78),%d2
    jbne VDTRMV1_B6
    movel %a3@(4),%d0
    jbsr VDTRMV1_100
VDTRMV1_B6:             /* the blessed folder of the volume */
    moveal ReqstVol,%a2
    movel %a2@(122),%d0
    jbeq VDTRMV1_C2
    jbsr VDTRMV1_100
VDTRMV1_C2:             /* end of list; the search hook (PMSPPtr - 6) if any */
    clrw %a4@(0x0,%d4:w)
    moveq #2,%d4
    movew %d4,%a4@(-2)
    movel %a4@(-6),%d0
    jbeq VDTRMV1_D6
    moveal %d0,%a1
    jsr %a1@
VDTRMV1_D6:             /* the current search entry: its volume */
    movew %a4@(0x0,%d4:w),%d0
VDTRMV1_DA:             /* the working directory used for the lookup (WDCB 1, at +18): this volume and dir ID */
    jbsr GETVCBRFN

    jbne VDTRMV1_FA
    moveal WDCBsPtr,%a3
    lea %a3@(18),%a3
    movel %a2,%a3@
    movel %a4@(0x2,%d4:w),%a3@(4)
    clrl %a3@(8)
    clrl %a3@(12)
    moveq #0,%d0
VDTRMV1_FA:             /* restore registers, return */
    moveml %sp@+,%d2/%d4/%a1/%a4
    rts

VDTRMV1_100:            /* add (vRefNum d2, dir ID d0) to the search list, unless already there */
    movel %d4,%sp@-
    moveq #2,%d4
VDTRMV1_104:            /* next entry (6 bytes) */
    cmpl %sp@,%d4
    jbcc VDTRMV1_11C
    cmpw %a4@(0x0,%d4:w),%d2
    jbne VDTRMV1_114
    cmpl %a4@(0x2,%d4:w),%d0
    jbeq VDTRMV1_11A
VDTRMV1_114:            /* next */
    addqw #6,%d4
    cmpw %a4@,%d4
    jbcs VDTRMV1_104
VDTRMV1_11A:            /* already in it */
    moveq #0,%d0
VDTRMV1_11C:            /* add it */
    movel %sp@+,%d4
    tstl %d0
    jbeq VDTRMV1_12C
    movew %d2,%a4@(0x0,%d4:w)
    movel %d0,%a4@(0x2,%d4:w)
    addqw #6,%d4
VDTRMV1_12C:            /* return */
    rts
VDTRMV1_12E:            /* a full path name */
    movel %a0@(18),%d2

VDTRMV1_132:            /* through VDTRMV2 */
    movel 0x6c4,%sp@-	/* through the vector at 0x6C4 (normally VDTRMV2; patchable) */
    rts

trap_VDTRMV2:
VDTRMV2:                /* the volume from a path name "Volume:...": a4 = the rest of the name, d2 = its length */
    moveml %d4-%d6/%a0-%a1,%sp@-
    tstl %d2
    jbeq VDTRMV2_40
    moveal %d2,%a4
    moveq #0,%d2
    moveal %d2,%a3
    moveb %a4@+,%d2
    jbeq VDTRMV2_40
    moveq #0,%d3
VDTRMV2_14:             /* find the first ':' */
    moveb %a4@(0x0,%d3:w),%d4
    cmpib #58,%d4	/* ':' */
    jbeq VDTRMV2_26
    addqw #1,%d3
    cmpw %d3,%d2
    jbne VDTRMV2_14
    jbra VDTRMV2_34
VDTRMV2_26:             /* "name:..." with a name: look for the volume */
    subl %d3,%d2
    subqw #1,%d2
    moveal %a4,%a1
    addal %d3,%a4
    addql #1,%a4
    tstw %d3
    jbgt VDTRMV2_44
VDTRMV2_34:             /* no volume name: by ioVRefNum */
    jbsr VDTRMV3_E
VDTRMV2_38:             /* restore registers, return (d0 tested) */
    moveml %sp@+,%d4-%d6/%a0-%a1
    tstw %d0
    rts
VDTRMV2_40:             /* no name: bdNamErr */
    moveq #-37,%d0	/* bdNamErr */
    jbra VDTRMV2_38
VDTRMV2_44:             /* the VCB whose name equals it (CmpString, case-insensitive) */
    movel VCBQHdr_Head,%d0
VDTRMV2_48:             /* next VCB */
    jbeq VDTRMV2_66
    moveal %d0,%a2
    lea %a2@(44),%a0
    moveq #0,%d0
    moveb %a0@+,%d0
    swap %d0
    movew %d3,%d0
    _CmpString
    jbne VDTRMV2_62
    movel %a2,ReqstVol
    jbra VDTRMV2_38
VDTRMV2_62:             /* next */
    movel %a2@,%d0
    jbne VDTRMV2_48
VDTRMV2_66:             /* nsvErr */
    moveq #-35,%d0	/* nsvErr */
    jbra VDTRMV2_38
VDTRMV2_6A:             /* _HFSDispatch 12 (SetPMSP?): the search hook (ioMisc +28 if not negative) and whether name searches go beyond the directory (ioParam +26 bit 0: HFSFlags bit 6) */
    jbsr FSQUEUESYNC_4
    movel %a0@(28),%d0
    jbmi VDTRMV2_7C
    moveal PMSPPtr,%a1
    movel %d0,%a1@(-6)
VDTRMV2_7C:             /* the option */
    movew %a0@(26),%d0
    bclr #6,HFSFlags
    btst #0,%d0
    jbne VDTRMV2_92
    bset #6,HFSFlags
VDTRMV2_92:             /* no error */
    moveq #0,%d0
    jbra CMDDONE

/* GETVOLINFO: _GetVolInfo / _HGetVInfo. */
trap_GetVolInfo:
GETVOLINFO:
    jbsr FSQUEUESYNC_4
    movew %a0@(28),%d2
    jbgt GETVOLINFO_1C
GETVOLINFO_A:           /* ioVolIndex 0: by ioVRefNum; negative: by name and ioVRefNum */
    jbeq GETVOLINFO_12
    jbsr VCKEXTFS_A
    jbra GETVOLINFO_16
GETVOLINFO_12:          /* (ioVolIndex 0) */
    jbsr VDTRMV3_E
GETVOLINFO_16:          /* no volume: done */
    jbne GETVOLINFO_1A4
    jbra GETVOLINFO_34
GETVOLINFO_1C:          /* ioVolIndex n: the n-th volume in the queue */
    moveq #0,%d3
    clrw %a0@(22)
    movel VCBQHdr_Head,%d1
GETVOLINFO_26:          /* next */
    jbeq GETVOL_20
    subqw #1,%d2
    moveal %d1,%a2
    jbeq GETVOLINFO_34
    movel %a2@,%d1
    jbra GETVOLINFO_26
GETVOLINFO_34:          /* copy 34 bytes of the VCB (creation date .. free blocks) to the parameter block */
    moveq #32,%d0
GETVOLINFO_36:          /* copy */
    movew %a2@(0xa,%d0:w),%a0@(0x1e,%d0:w)
    subqw #2,%d0
    jbpl GETVOLINFO_36
    bset #6,%a0@(39)
    jbsr GETWDINFO_3A8
GETVOLINFO_4A:          /* any open file on it? (ioVAtrb bit 6: busy) */
    cmpal %a1@(0x14,%d1:w),%a2
    jbne GETVOLINFO_62
    jbsr TFSVCBTST
    jbne GETVOLINFO_6E
    movel %a1@(0x0,%d1:w),%d0
    cmpil #16,%d0
    jbcc GETVOLINFO_6E
GETVOLINFO_62:          /* next FCB; none: not busy */
    jbsr GETWDINFO_3B0
    jbcs GETVOLINFO_4A
    bclr #6,%a0@(39)
GETVOLINFO_6E:          /* ioVAtrb bit 5: the default volume */
    bclr #5,%a0@(39)
    cmpal DefVCBPtr,%a2
    jbne GETVOLINFO_80
    bset #5,%a0@(39)
GETVOLINFO_80:          /* by WD refNum (or 0): ioVNmFls = the directory's valence instead of the volume's file count */
    subal %a3,%a3
    tstw %a0@(28)
    jbgt GETVOLINFO_E0
    tstw %d3
    jbne GETVOLINFO_E0
    movew %a0@(22),%d1
    jbgt GETVOLINFO_E0
    jblt GETVOLINFO_98
    moveq #2,%d1
    jbra GETVOLINFO_A2
GETVOLINFO_98:          /* a working directory? */
    cmpiw #-4096,%d1
    jbgt GETVOLINFO_E0
    subiw #-32767,%d1
GETVOLINFO_A2:          /* its WDCB: the folder's valence */
    moveal WDCBsPtr,%a3
    addaw %d1,%a3
    jbsr VFNDFILNAME_124
    jbne GETVOLINFO_E0
    moveml %a0-%a1,%fp@-
    moveal WDCBsPtr,%a1
    movel %a1@(0x4,%d1:w),%d0
    cmpil #2,%d0
    jbeq GETVOLINFO_DC
    movel %a1@(0x8,%d1:w),%d2
    subal %a0,%a0
    jsr %pc@(CMGETCN)
    jbne GETVOLINFO_DC
    movew %a1@(4),%d0
    moveml %fp@+,%a0-%a1
    movew %d0,%a0@(40)
    jbra GETVOLINFO_E0
GETVOLINFO_DC:          /* done */
    moveml %fp@+,%a0-%a1
GETVOLINFO_E0:          /* ioVRefNum = the volume's vRefNum (unless the caller gave a WD) */
    tstw %d3
    jbne GETVOLINFO_EA
    tstw %a0@(22)
    jblt GETVOLINFO_F0
GETVOLINFO_EA:          /* vRefNum */
    movew %a2@(78),%a0@(22)
GETVOLINFO_F0:          /* the name; HFS: free blocks less the B-trees' */
    jbsr GETVOL_24
    jbsr TFSVCBTST
    jbne GETVOLINFO_10A
    movew %a2@(160),%d0
    subw %d0,%a0@(46)
    movew %a2@(162),%d0
    subw %d0,%a0@(46)
GETVOLINFO_10A:         /* _GetVolInfo (not H): at most 31744 allocation blocks reported (old programs' limit, about 2 GB with...) */
    btst #9,%a0@(6)
    jbne GETVOLINFO_12C
    movew #31744,%d0	/* 31744 blocks at most for _GetVolInfo */
    cmpw %a0@(46),%d0
    jbhi GETVOLINFO_12A
    movew %d0,%a0@(46)
    cmpw %a0@(62),%d0
    jbhi GETVOLINFO_12A
    movew %d0,%a0@(62)
GETVOLINFO_12A:         /* on */
    jbra GETVOLINFO_192
GETVOLINFO_12C:         /* _HGetVInfo: the HFS fields: signature, drive, driver, FSID, backup date, sequence, write count, file and folder counts, Finder info */
    movew %a2@(78),%a0@(22)
    movew %a2@(8),%a0@(64)
    movew %a2@(72),%a0@(66)
    movew %a2@(74),%a0@(68)
    movew %a2@(76),%a0@(70)
    clrl %a0@(82)
    movew %a2@(20),%a0@(84)
    clrl %a0@(86)
    movew #1,%a0@(88)
    jbsr TFSVCBTST
    jbne GETVOLINFO_1A2
    movel %a2@(94),%a0@(72)
    movew %a2@(98),%a0@(76)
    movel %a2@(100),%a0@(78)
    movel %a2@(114),%a0@(82)
    movel %a2@(118),%a0@(86)
    movel %a0,%sp@-
    lea %a0@(90),%a1
    lea %a2@(122),%a0
    moveq #32,%d0
    _BlockMove
    moveal %sp@+,%a0
GETVOLINFO_192:         /* ReqstVol; an external file system's volume? */
    movel %a2,ReqstVol
    jbsr TFSVCBTST
    jbne GETVOLINFO_1A2
    jbsr FLUSHVOL_3C
    jbne GETVOLINFO_1A4
GETVOLINFO_1A2:         /* no error */
    moveq #0,%d0
GETVOLINFO_1A4:         /* done */
    jbra CMDDONE

/* SETVOLINFO: _SetVolInfo. */
SETVOLINFO:
    jbsr FSQUEUESYNC_4
    jbsr VDTRMV3_E
    jbne SETVOLINFO_70
    jbsr SETVOLINFO_A8
    jbne SETVOLINFO_70
    jbsr VFNDFILNAME_124
    jbne SETVOLINFO_70
    movel %a0@(30),%a2@(10)
    movel %a0@(34),%a2@(14)
    movew %a0@(38),%d0
    andiw #-32768,%d0
    movew %a2@(18),%d1
    andiw #32767,%d1
    orw %d0,%d1
    movew %d1,%a2@(18)
    jbsr TFSVCBTST
    jbne SETVOLINFO_60
    movel %a0@(52),%a2@(32)
    movel %a0@(72),%a2@(94)
    movew %a0@(76),%a2@(98)
    movel %a0,%sp@-
    lea %a0@(90),%a0
    lea %a2@(122),%a1
    moveq #32,%d0
    _BlockMove
    moveal %sp@+,%a0
SETVOLINFO_60:          /* a new name? */
    movel %a0@(18),%d0
    jbeq SETVOLINFO_6A
    moveal %d0,%a1
    jbsr SETVOLINFO_74
SETVOLINFO_6A:          /* VCB dirty */
    jbsr MARKVCB
    moveq #0,%d0
SETVOLINFO_70:          /* done */
    jbra CMDDONE

SETVOLINFO_74:          /* the volume name from a1 (up to ':' or 27 characters) */
    moveml %a1-%a2,%sp@-
    lea %a2@(44),%a2
    moveq #1,%d0
SETVOLINFO_7E:          /* next character */
    cmpb %a1@,%d0
    jbgt SETVOLINFO_9A
    cmpib #58,%a1@(0x0,%d0:w)
    jbeq SETVOLINFO_9A
    cmpib #27,%d0
    jbgt SETVOLINFO_9A
    moveb %a1@(0x0,%d0:w),%a2@(0x0,%d0:w)
    addqw #1,%d0
    jbra SETVOLINFO_7E
SETVOLINFO_9A:          /* its length */
    subqw #1,%d0
    moveb %d0,%a2@
    moveml %sp@+,%a1-%a2
    jbsr MARKVCB
    rts

SETVOLINFO_A8:          /* may the volume be changed? vLckdErr (software lock, vcbAtrb bit 15), wPrErr (hardware lock, bit 7) */
    moveq #-46,%d0	/* vLckdErr */
    tstw %a2@(18)
    jbmi SETVOLINFO_BA
    moveq #-44,%d0	/* wPrErr */
    tstb %a2@(19)
    jbmi SETVOLINFO_BA
    moveq #0,%d0
SETVOLINFO_BA:          /* return */
    rts

/* GETVOL: _GetVol / _HGetVol: the default volume and directory. */
trap_GetVol:
GETVOL:
    btst #9,%d1
    jbne GETDIR
    jbsr FSQUEUESYNC_4
    movel DefVCBPtr,%d0
    jbeq GETVOL_20
    moveal %d0,%a2
    movew DefVRefNum,%a0@(22)
    jbsr GETVOL_24
GETVOL_1C:              /* done */
    jbra CMDDONE
GETVOL_20:              /* no default volume: nsvErr */
    moveq #-35,%d0	/* nsvErr */
    jbra GETVOL_1C

GETVOL_24:              /* copy the volume name to ioNamePtr, if any */
    moveml %a1-%a2,%sp@-
    lea %a2@(44),%a2
    movel %a0@(18),%d0
    jbeq GETVOL_40
    _StripAddress
    moveal %d0,%a1
    moveq #0,%d0
    moveb %a2@,%d0
GETVOL_3A:              /* copy */
    moveb %a2@+,%a1@+
    dbf %d0,GETVOL_3A
GETVOL_40:              /* restore, no error */
    moveml %sp@+,%a1-%a2
    moveq #0,%d0
    rts

/* SETVOL: _SetVol / _HSetVol. */
trap_SetVol:
SETVOL:
    btst #9,%d1
    jbne SETDIR
    jbsr FSQUEUESYNC_4
    jbsr VCKEXTFS_A
    jbne SETVOL_3C
    movew %a2@(78),%d0
    tstw %d3
    jbne SETVOL_24
    tstw %a0@(22)
    jbgt SETVOL_24
    movew %a0@(22),%d0
    jbeq SETVOL_28
SETVOL_24:              /* DefVRefNum (the vRefNum or the WD refNum given) */
    movew %d0,DefVRefNum
SETVOL_28:              /* the default directory (WDCB 0): root, or the working directory's */
    moveq #2,%d6
    movel %a3,%d7
    jbeq SETVOL_36
    movel %a3@(4),%d6
    movel %a3@(8),%d7
SETVOL_36:              /* set it */
    jbsr OPENWD_3C
    moveq #0,%d0
SETVOL_3C:              /* done */
    jbra CMDDONE

/* SETDIR: set the default directory. */
SETDIR:
    jbsr FSQUEUESYNC_4
    jbsr SETCATINFO_88
    jbeq SETDIR_18
    cmpiw #-37,%d0
    jbne SETDIR_30
    tstb %d2
    jbne SETDIR_30
    moveq #2,%d6
    jbra SETDIR_24
SETDIR_18:              /* found: a folder? its dir ID */
    moveq #-120,%d0	/* dirNFErr */
    cmpib #1,%a5@
    jbne SETDIR_30
    movel %a5@(6),%d6
SETDIR_24:              /* the default directory (WDCB 0) */
    movew %a2@(78),DefVRefNum
    moveq #0,%d7
    jbsr OPENWD_3C
    moveq #0,%d0
SETDIR_30:              /* done */
    jbra CMDDONE

/* GETDIR: the default directory. */
GETDIR:
    jbsr FSQUEUESYNC_4
    jbsr FILECREATE_1BE
    moveq #-35,%d0	/* nsvErr */
    tstl %a1@(0x0,%d1:w)
    jbeq GETDIR_20
    jbsr GETWDINFO_CA
    jbsr GETVOL_24
    movew DefVRefNum,%a0@(22)
    moveq #0,%d0
GETDIR_20:              /* done */
    jbra CMDDONE

/* OPENWD: _OpenWD: a working directory refnum for a directory. */
OPENWD:
    jbsr FSQUEUESYNC_4
    jbsr SETCATINFO_88
    jbeq OPENWD_16
    cmpiw #-37,%d0
    jbne OPENWD_38
    tstb %d2
    jbne OPENWD_38
    jbra OPENWD_30
OPENWD_16:              /* a folder? its dir ID; the root needs no WD (the vRefNum is returned) */
    moveq #-120,%d0	/* dirNFErr */
    cmpib #1,%a5@
    jbne OPENWD_38
    movel %a5@(6),%d6
    cmpil #2,%d6
    jbeq OPENWD_30
    moveq #0,%d7
    jbsr OPENWD_60
    jbra OPENWD_38
OPENWD_30:              /* the root: ioVRefNum = vRefNum */
    movew %a2@(78),%a0@(22)
    moveq #0,%d0
OPENWD_38:              /* done */
    jbra CMDDONE

OPENWD_3C:              /* WDCB 0, the default directory: volume a2, dir ID d6, hint d7, procID ioWDProcID */
    movel %a2,DefVCBPtr
    moveq #2,%d1

OPENWD_42:              /* fill WDCB d1; d1 = its refNum (offset - 32767) */
    moveal WDCBsPtr,%a1
    movel %a2,%a1@(0x0,%d1:w)
    movel %d6,%a1@(0x4,%d1:w)
    movel %d7,%a1@(0x8,%d1:w)
    movel %a0@(28),%d0
    movel %d0,%a1@(0xc,%d1:w)
    addiw #-32767,%d1
    rts

OPENWD_60:              /* find or make a working directory for (volume a2, dir ID d6, procID) */
    movel %a0@(28),%d3
    moveq #0,%d2
    jbsr FILECREATE_1BE
    jbsr FILECREATE_1C6
OPENWD_6E:              /* next WDCB: remember the first free one */
    jbsr FILECREATE_1C6
    jbcc OPENWD_9A
    tstl %a1@(0x0,%d1:w)
    jbne OPENWD_82
    tstw %d2
    jbne OPENWD_6E
    movew %d1,%d2
    jbra OPENWD_6E
OPENWD_82:              /* the same volume, directory and procID: use it */
    cmpal %a1@(0x0,%d1:w),%a2
    jbne OPENWD_6E
    cmpl %a1@(0x4,%d1:w),%d6
    jbne OPENWD_6E
    cmpl %a1@(0xc,%d1:w),%d3
    jbne OPENWD_6E
    addiw #-32767,%d1
    jbra OPENWD_A0
OPENWD_9A:              /* none: the free one */
    movew %d2,%d1
    jbeq OPENWD_A8
    jbsr OPENWD_42
OPENWD_A0:              /* ioVRefNum = the WD refNum */
    movew %d1,%a0@(22)
    moveq #0,%d0
    rts
OPENWD_A8:              /* tmwdoErr */
    moveq #-121,%d0	/* tmwdoErr */
    rts

/* CLOSEWD: _CloseWD. */
CLOSEWD:
    jbsr FSQUEUESYNC_4
    moveq #0,%d1
    movew %a0@(22),%d1
    jbsr GETWDINFO_E6
    jbeq CLOSEWD_18
    cmpiw #-4096,%d1
    jbhi CLOSEWD_34
    jbra CLOSEWD_36
CLOSEWD_18:             /* a real WD: its volume; another file system's? extFSErr */
    subiw #-32767,%d1
    moveal %a1@(0x0,%d1:w),%a2
    tstw %a2@(76)
    jbeq CLOSEWD_30
    movel %a2,ReqstVol
    addl %a1,%d1
    moveq #-58,%d0	/* extFSErr */
    jbra CLOSEWD_36
CLOSEWD_30:             /* free the WDCB */
    clrl %a1@(0x0,%d1:w)
CLOSEWD_34:             /* (a vRefNum: nothing to close) */
    moveq #0,%d0
CLOSEWD_36:             /* done */
    jbra CMDDONE

/* GETWDINFO: _GetWDInfo. */
GETWDINFO:
    jbsr FSQUEUESYNC_4
    jbsr GETWDINFO_1C
    jbne GETWDINFO_18
    extl %d1
    addl %a1,%d1
    movel %a2,ReqstVol
    jbsr FLUSHVOL_3C
    jbne GETWDINFO_18
    moveq #0,%d0
GETWDINFO_18:           /* done */
    jbra CMDDONE

GETWDINFO_1C:           /* find the WD: ioWDIndex > 0: the n-th (of a volume, of a procID); else by ioVRefNum */
    tstw %a0@(26)
    jbgt GETWDINFO_5C
    moveq #0,%d1
    movew %a0@(22),%d1
    jbsr GETWDINFO_E6
    jbeq GETWDINFO_4E
    jbsr VDTRMV3_E
    jbne GETWDINFO_AA
    clrl %a0@(28)
    moveq #2,%d0
    movel %d0,%a0@(48)
    movew %a2@(78),%a0@(32)
    movew %a2@(78),%a0@(22)
    moveq #0,%d1
    jbra GETWDINFO_A6
GETWDINFO_4E:           /* a WD refNum */
    moveq #-35,%d0	/* nsvErr */
    subiw #-32767,%d1
    tstl %a1@(0x0,%d1:w)
    jbeq GETWDINFO_AA
    jbra GETWDINFO_A4
GETWDINFO_5C:           /* by index */
    moveq #-35,%d0	/* nsvErr */
    moveq #0,%d2
    tstw %a0@(22)
    jbeq GETWDINFO_6E
    jbsr VCKEXTFS_A
    jbne GETWDINFO_AA
    movel %a2,%d2
GETWDINFO_6E:           /* d4 = index, d3 = procID wanted */
    movew %a0@(26),%d4
    movel %a0@(28),%d3
    moveq #-35,%d0	/* nsvErr */
    jbsr FILECREATE_1BE
    jbsr FILECREATE_1C6
GETWDINFO_80:           /* next WDCB in use */
    jbsr FILECREATE_1C6
    jbcc GETWDINFO_AA
    tstl %a1@(0x0,%d1:w)
    jbeq GETWDINFO_80
    tstl %d3
    jbeq GETWDINFO_96
    cmpl %a1@(0xc,%d1:w),%d3
    jbne GETWDINFO_80
GETWDINFO_96:           /* the volume? */
    tstl %d2
    jbeq GETWDINFO_A0
    cmpl %a1@(0x0,%d1:w),%d2
    jbne GETWDINFO_80
GETWDINFO_A0:           /* the n-th */
    subqw #1,%d4
    jbgt GETWDINFO_80
GETWDINFO_A4:           /* its info */
    jbsr GETWDINFO_C4
GETWDINFO_A6:           /* the volume name */
    jbsr GETVOL_24
GETWDINFO_AA:           /* return */
    tstw %d0
    rts
GETWDINFO_AE:           /* GetWDInfo for the File Manager's own use (on its stack) */
    moveml %d3-%d7/%a1-%fp,%sp@-
    moveal HFSVars_HFSStkTop,%fp
    jbsr GETWDINFO_1C
    moveml %sp@+,%d3-%d7/%a1-%fp
    movew %d0,%a0@(16)
    rts

GETWDINFO_C4:           /* ioWDProcID */
    movel %a1@(0xc,%d1:w),%a0@(28)

GETWDINFO_CA:           /* ioWDVRefNum, ioWDDirID, ioVRefNum = the WD refNum */
    moveal %a1@(0x0,%d1:w),%a2
    movew %a2@(78),%a0@(32)
    movel %a1@(0x4,%d1:w),%a0@(48)
    movew %d1,%d0
    addiw #-32767,%d0
    movew %d0,%a0@(22)
    rts

GETWDINFO_E6:           /* is d1 a valid WD refNum in use? rfNumErr if not */
    movel %d1,%sp@-
    moveq #-51,%d0	/* rfNumErr */
    subiw #-32767,%d1
    moveal WDCBsPtr,%a1
    cmpw %a1@,%d1
    jbcc GETWDINFO_110
    subqw #2,%d1
    divuw #16,%d1
    swap %d1
    tstw %d1
    jbne GETWDINFO_110
    movel %sp@,%d1
    subiw #-32767,%d1
    tstl %a1@(0x0,%d1:w)
    jbeq GETWDINFO_110
    moveq #0,%d0
GETWDINFO_110:          /* return */
    movel %sp@+,%d1
    tstw %d0
    rts
GETWDINFO_116:          /* _HFSDispatch 13: OpenWD by dir ID (internal stack) */
    moveml %d3-%d7/%a1-%fp,%sp@-
    moveal HFSVars_HFSStkTop,%fp
    jbsr VDTRMV3_E
    jbne GETWDINFO_136
    movel %a0@(48),%d6
    moveq #0,%d7
    jbsr OPENWD_60
    jbne GETWDINFO_136
    movew %d1,%a0@(22)
GETWDINFO_134:          /* no error */
    moveq #0,%d0
GETWDINFO_136:          /* restore, result */
    moveml %sp@+,%d3-%d7/%a1-%fp
    movew %d0,%a0@(16)
    rts
GETWDINFO_140:          /* _HFSDispatch 14: SetDir by dir ID (internal stack): the default directory */
    moveml %d3-%d7/%a1-%fp,%sp@-
    moveal HFSVars_HFSStkTop,%fp
    jbsr VDTRMV3_E
    jbne GETWDINFO_136
    movew %a2@(78),DefVRefNum
    movel %a0@(48),%d6
    moveq #0,%d7
    jbsr OPENWD_3C
    jbra GETWDINFO_134
/*
 MFS volumes (the flat 400K-disk file system), at mount: the VCB shrinks to 94 bytes,
 the allocation block map (12 bits per block, from the MDB and the blocks after it)
 is read into a buffer (+80, length +88) and checked against the free count; then the
 file directory is scanned for the file count and the next file number. (Mislabelled
 GETWDINFO_: the code follows GetWDInfo in the ROM.)
*/
GETWDINFO_160:          /* MFS: shrink the VCB to 94 bytes, read the block map */
    moveq #94,%d0
    moveal %a2,%a0
    _SetPtrSize
    moveq #3,%d2
    muluw %a2@(26),%d2
    addql #1,%d2
    lsrl #1,%d2
    movew %d2,%a2@(88)
    moveq #64,%d7
    movel %d2,%d0
    .short  0xA51E	| 40810696 _NewPtr (flags 0x0500)
    jbne VCHECKREMOUNT_156
    movel %a0,%a2@(80)
    moveq #2,%d3
GETWDINFO_184:          /* copy the map, block by block */
    movew %a5@(0x0,%d7:w),%a0@+
    addqw #2,%d7
    subqw #2,%d2
    jble GETWDINFO_1A0
    cmpiw #512,%d7
    jbcs GETWDINFO_184
    addqw #1,%d3
    jbsr VFILEWRITE_100
    jbne GETWDINFO_1A6
    moveq #0,%d7
    jbra GETWDINFO_184
GETWDINFO_1A0:          /* count the free blocks: must match the MDB */
    jbsr GETWDINFO_1C0
    jbeq GETWDINFO_1DC
GETWDINFO_1A4:          /* badMDBErr */
    moveq #-60,%d0	/* badMDBErr */
GETWDINFO_1A6:          /* free the map, fail */
    jbsr GETWDINFO_1AC
    jbra VCHECKREMOUNT_156

GETWDINFO_1AC:          /* MFS: dispose of the block map */
    moveml %d0/%a0,%sp@-
    moveal %a2@(80),%a0
    _DisposPtr
    clrl %a2@(80)
    moveml %sp@+,%d0/%a0
    rts

GETWDINFO_1C0:          /* MFS: count the free allocation blocks (map entries 0); Z if = vcbFreeBks */
    moveq #2,%d3
    moveq #0,%d1
GETWDINFO_1C4:          /* next block */
    jbsr VLG2PHYS_88
    jbne GETWDINFO_1CC
    addqw #1,%d1
GETWDINFO_1CC:          /* to the last */
    cmpw %a2@(26),%d3
    jbhi GETWDINFO_1D6
    addqw #1,%d3
    jbra GETWDINFO_1C4
GETWDINFO_1D6:          /* compare with the MDB's count */
    cmpw %a2@(42),%d1
    rts
GETWDINFO_1DC:          /* scan the file directory: count files, the largest file number; check each fork's map chain */
    moveq #0,%d1
    moveq #0,%d2
    moveq #0,%d7
    jbsr VFILEWRITE_D2
    jbne GETWDINFO_1A6
GETWDINFO_1E8:          /* next directory block */
    tstb %a5@
    jbne GETWDINFO_1F8
    moveal %a5,%a0
    exg %d1,%d6
    moveq #2,%d1
    jsr %pc@(RELBLOCK)
    exg %d1,%d6
GETWDINFO_1F8:          /* entries of the block */
    moveq #0,%d0
GETWDINFO_1FA:          /* next entry (used: flags byte non-zero) */
    tstb %a5@(0x0,%d0:w)
    jbeq GETWDINFO_222
    addqw #1,%d1
    cmpl %a5@(0x12,%d0:w),%d2
    jbhi GETWDINFO_20C
    movel %a5@(0x12,%d0:w),%d2
GETWDINFO_20C:          /* the data fork's chain, then the resource fork's */
    lea %a5@(0x16,%d0:w),%a3
    jbsr GETWDINFO_260
    jbne GETWDINFO_1A4
    lea %a5@(0x20,%d0:w),%a3
    jbsr GETWDINFO_260
    jbne GETWDINFO_1A4
    jbsr FILECREATE_1A8
    jbcs GETWDINFO_1FA
GETWDINFO_222:          /* next block; end (dirFulErr): fix the counts if wrong */
    jbsr VFILEWRITE_E2
    jbeq GETWDINFO_1E8
    cmpiw #-33,%d0
    jbne GETWDINFO_1A6
    cmpl %a2@(38),%d2
    jbcs GETWDINFO_23E
    addql #1,%d2
    movel %d2,%a2@(38)
    addqb #1,%d7
GETWDINFO_23E:          /* file count */
    cmpw %a2@(20),%d1
    jbeq GETWDINFO_24A
    movew %d1,%a2@(20)
    addqb #2,%d7
GETWDINFO_24A:          /* write it back if allowed */
    tstb %d7
    jbeq GETWDINFO_258
    jbsr SETVOLINFO_A8
    jbne GETWDINFO_258
    jbsr MARKVCB
GETWDINFO_258:          /* remember what was fixed; on to the remount check */
    orb %d7,%a2@(19)
    jbra MOUNTVOL_210

GETWDINFO_260:          /* MFS: a fork's length from its block chain; fix the entry if it disagrees */
    moveml %d0-%d6,%sp@-
    movew %a2@(26),%d1
    moveq #0,%d6
    movel %a2@(28),%d2
    movew %a3@,%d3
    jbeq GETWDINFO_286
GETWDINFO_272:          /* follow the chain */
    jbsr VLG2PHYS_88
    subqw #1,%d1
    jbcs GETWDINFO_2B0
    movew %d5,%d3
    jbeq GETWDINFO_286
    addl %d2,%d6
    cmpiw #1,%d3
    jbne GETWDINFO_272
GETWDINFO_286:          /* compare with the entry's lengths */
    movew %a3@+,%d3
    movel %a3@+,%d4
    movel %a3@+,%d5
    cmpl %d5,%d6
    jbeq GETWDINFO_2AE
    movel %d6,%a3@-
    jbne GETWDINFO_296
    clrw %d3
GETWDINFO_296:          /* logical at most physical */
    cmpl %d6,%d4
    jbls GETWDINFO_29C
    movel %d6,%d4
GETWDINFO_29C:          /* write the fixed entry */
    movel %d4,%a3@-
    movew %d3,%a3@-
    jbsr SETVOLINFO_A8
    jbne GETWDINFO_2B0
    jsr %pc@(MARKA5BLOCK)
    bset #2,%d7
GETWDINFO_2AE:          /* no error */
    moveq #0,%d1
GETWDINFO_2B0:          /* restore, return */
    moveml %sp@+,%d0-%d6
    rts

GETWDINFO_2B6:          /* MFS flush: if dirty write the MDB and the block map back (block 2 on) */
    movel %sp@+,%fp@-
    moveml %d1-%a5,%fp@-
    tstw %a2@(72)
    jbeq GETWDINFO_32C
    tstb %a2@(6)
    jbpl GETWDINFO_326
    jbsr GETWDINFO_1C0
    jbne GETWDINFO_326
    moveq #2,%d3
    jbsr VFILEWRITE_106
    jbne GETWDINFO_346
    jsr %pc@(MARKA5BLOCK)
    moveq #31,%d0
    moveal %a5,%a1
    lea %a2@(8),%a0
    movel Time,%a2@(14)
GETWDINFO_2E8:          /* the MDB fields (64 bytes), modification date now */
    movew %a0@+,%a1@+
    dbf %d0,GETWDINFO_2E8
    moveal %a2@(80),%a0
    movew %a2@(88),%d2
    moveq #64,%d7
GETWDINFO_2F8:          /* the map after them, block by block */
    movew %a0@+,%a5@(0x0,%d7:w)
    addqw #2,%d7
    subqw #2,%d2
    jble GETWDINFO_318
    cmpiw #512,%d7
    jbcs GETWDINFO_2F8
    addqw #1,%d3
    jbsr VFILEWRITE_106
    jbne GETWDINFO_346
    jsr %pc@(MARKA5BLOCK)
    moveq #0,%d7
    jbra GETWDINFO_2F8
GETWDINFO_318:          /* clear the rest of the last block */
    cmpiw #512,%d7
    jbcc GETWDINFO_326
    clrw %a5@(0x0,%d7:w)
    addqw #2,%d7
    jbra GETWDINFO_318
GETWDINFO_326:          /* flush the caches */
    jbsr OFFLINE_14
    jbne GETWDINFO_346
GETWDINFO_32C:          /* not dirty; unmounting: free the map and the VCB */
    clrb %a2@(6)
    tstb FlushOnly
    jbne GETWDINFO_344
    tstw %a2@(72)
    jbeq GETWDINFO_340
    jbsr GETWDINFO_1AC
GETWDINFO_340:          /* remove the VCB */
    jbsr VBMCHK_3C
GETWDINFO_344:          /* no error */
    moveq #0,%d0
GETWDINFO_346:          /* restore, return */
    moveml %fp@+,%d1-%a5
    movel %fp@+,%sp@-
    tstw %d0
    rts
    bsrw FSQUEUESYNC_4
    movew %a0@(28),%d2
    bgts GETWDINFO_346_24
    beqs GETWDINFO_346_1C
    bsrw VCKEXTFS_A
    bras GETWDINFO_346_20
GETWDINFO_346_1C:
    bsrw VDTRMV3_E
GETWDINFO_346_20:
    bnes GETWDINFO_346_5E
    bras GETWDINFO_346_36
GETWDINFO_346_24:
    movel VCBQHdr_Head,%d1
GETWDINFO_346_28:
    beqw GETVOL_20
    subqw #1,%d2
    moveal %d1,%a2
    beqs GETWDINFO_346_36
    movel %a2@,%d1
    bras GETWDINFO_346_28
GETWDINFO_346_36:
    bset #6,%a2@(19)
    bsrs GETWDINFO_3A8
GETWDINFO_346_3E:
    cmpal %a1@(0x14,%d1:w),%a2
    beqs GETWDINFO_346_4E
    bsrs GETWDINFO_3B0
    bcss GETWDINFO_346_3E
    bclr #6,%a2@(19)
GETWDINFO_346_4E:
    moveq #32,%d0
GETWDINFO_346_50:
    movew %a2@(0xa,%d0:w),%a0@(0x1e,%d0:w)
    subqw #2,%d0
    bpls GETWDINFO_346_50
    bsrw GETVOL_24
GETWDINFO_346_5E:
    braw CMDDONE

GETWDINFO_3A8:          /* FCB loop start: a1 = the FCB buffer, d1 = 2 (the first FCB) */
    moveal FCBSPtr,%a1
    moveq #2,%d1
    rts

GETWDINFO_3B0:          /* next FCB: d1 += 94; C set while inside the buffer */
    addw FSFCBLen,%d1
    cmpw %a1@,%d1
    rts

GETWDINFO_3B8:          /* find an FCB of file number d2 on volume a2 (Z set if found) */
    jbsr GETWDINFO_3A8
GETWDINFO_3BA:          /* this one? */
    cmpl %a1@(0x0,%d1:w),%d2
    jbne GETWDINFO_3C6
    cmpal %a1@(0x14,%d1:w),%a2
    jbeq GETWDINFO_3CE

GETWDINFO_3C6:          /* next; none: Z clear */
    jbsr GETWDINFO_3B0
    jbcs GETWDINFO_3BA
    movew #0,%ccr
GETWDINFO_3CE:          /* return */
    rts

/* OPENRF: _OpenRF: open a resource fork. */
trap_OpenRF:
OPENRF:
    jbsr FSQUEUESYNC_4
    clrb RegRsrc
    jbra VFILEOPEN_8

/* FILEOPEN: _Open of a file: find it in the catalog, allocate an FCB, check the permissions. */
FILEOPEN:
    movel 0x784,%sp@-	/* through the vector at 0x784 (normally VFILEOPEN; patchable) */
    rts

/* VFILEOPEN: vectored entry: _Open of a file: find it in the catalog, allocate an FCB, check the permissions. */
trap_VFILEOPEN:
VFILEOPEN:              /* (sets RegRsrc: the data fork) */
    jbsr FSQUEUESYNC_4
    st RegRsrc
VFILEOPEN_8:            /* a free FCB */
    jbsr GETWDINFO_3A8
VFILEOPEN_A:            /* next FCB */
    tstl %a1@(0x0,%d1:w)
    jbeq VFILEOPEN_1E
    jbsr GETWDINFO_3B0
    jbcs VFILEOPEN_A
    moveq #-42,%d0	/* tmfoErr */
VFILEOPEN_16:           /* failed: ioRefNum = 0 */
    clrw %a0@(24)
VFILEOPEN_1A:           /* done */
    jbra CMDDONE
VFILEOPEN_1E:           /* ioRefNum = the FCB; find the file in the catalog (SETCATINFO_88) */
    movew %d1,%a0@(24)
    addl %a1,%d1
    jbsr SETCATINFO_88
    jbne VFILEOPEN_16
    movel %a0,%sp@-
    moveal %d1,%a0
    moveq #0,%d0
    movew FSFCBLen,%d0
    lsrw #1,%d0
    subqw #1,%d0
VFILEOPEN_38:           /* clear the FCB */
    clrw %a0@+
    dbf %d0,VFILEOPEN_38
    moveal %sp@+,%a0
    jbsr TFSVCBTST
    jbne FILECREATE_B8
    moveq #-43,%d0	/* fnfErr */
    cmpib #2,%a5@	/* a file record? */
    jbne VFILEOPEN_16
    moveal %d1,%a3
    movel %d7,%a3@(54)
    movel %a5@(4),%d0
    movel %d0,%a3@(50)
    movel %d6,%a3@(58)
    moveq #0,%d0
    movew %a5@(72),%d0
    jbeq VFILEOPEN_76
    muluw %a2@(30),%d0
    bset #6,%a3@(4)
    jbra VFILEOPEN_80
VFILEOPEN_76:           /* no clump size in the file: the volume's */
    movel %a2@(32),%d0
    bclr #6,%a3@(4)
VFILEOPEN_80:           /* fcbClmpSize; the fork's first extent record (data +74, resource +86) */
    movel %d0,%a3@(30)
    moveml %a0-%a1,%sp@-
    moveq #12,%d0
    lea %a5@(74),%a0
    tstb RegRsrc
    jbne VFILEOPEN_98
    lea %a5@(86),%a0
VFILEOPEN_98:           /* into fcbExtRec; the name into fcbCName */
    lea %a3@(38),%a1
    _BlockMove
    moveq #0,%d0
    movew %d2,%d0
    moveal %a4,%a0
    lea %a3@(62),%a1
    moveb %d0,%a1@+
    _BlockMove
    moveml %sp@+,%a0-%a1
    movel %a0,%fp@-
    movel %d6,%d0
    movel %d7,%d2
    lea %a3@(62),%a0
    jsr %pc@(CMGETCN)
    beqw VFILEOPEN_CE
    moveal %fp@+,%a0
    jbmi VFILEOPEN_16
    moveq #-43,%d0	/* fnfErr */
    jbra VFILEOPEN_16
VFILEOPEN_CE:           /* the catalog name, exact case */
    moveal %a1,%a5
    lea %a0@(6),%a0
    lea %a3@(62),%a1
    moveq #0,%d0
    moveb %a0@,%d0
    addql #1,%d0
    _BlockMove
    moveal %fp@+,%a0
    clrw %d7
    movew %a5@(2),%d3
    andiw #256,%d3
    jbeq VFILEOPEN_F2
    bset #13,%d3
VFILEOPEN_F2:           /* the fork: start, lengths (data or resource) */
    lea %a5@(20),%a5
    movel %a5@+,%d2
    movew %a5@+,%d4
    movel %a5@+,%d5
    movel %a5@+,%d6
    tstb RegRsrc
    jbne VFILEOPEN_10E
    bset #9,%d3
    movew %a5@+,%d4
    movel %a5@+,%d5
    movel %a5@+,%d6
VFILEOPEN_10E:          /* permission check; refused: clear the FCB */
    jbsr VFILEOPEN_176
    jbeq VFILEOPEN_126
    moveq #0,%d1
    movew FSFCBLen,%d1
    lsrw #1,%d1
    subqw #1,%d1
VFILEOPEN_11C:          /* clear */
    clrw %a3@+
    dbf %d1,VFILEOPEN_11C
    jbra VFILEOPEN_1A

VFILEOPEN_126:          /* fill the FCB: file number, flags, start block, EOF, physical length, position 0, VCB, buffer, catalog hint */
    movel %d2,%a3@+
    movew %d3,%a3@+
    movew %d4,%a3@+
    movel %d5,%a3@+
    movel %d6,%a3@+
    clrl %a3@+
    movel %a2,%a3@+
    subal %a4,%a4
    movel %a4,%d0
    nop
    movel %a4,%a3@+
    movew %d7,%a3@+
    addql #4,%a3
    clrl %a3@+
    bset #7,%a2@(5)
    movew %a0@(24),%d4
    jbsr GETWDINFO_3B8
VFILEOPEN_150:          /* another path to the same fork already open? share its EOF */
    cmpw %d1,%d4
    jbeq VFILEOPEN_160
    moveb %a1@(0x4,%d1:w),%d5
    moveb %d5,%d6
    eorb %d3,%d6
    lsrb #2,%d6
    jbcc VFILEOPEN_168
VFILEOPEN_160:          /* next */
    jbsr GETWDINFO_3C6
    jbeq VFILEOPEN_150
    jbra VFILEOPEN_170
VFILEOPEN_168:          /* take its EOF and lengths */
    jsr %pc@(SETEOF_6A)
    moveb %d5,%a1@(0x4,%d1:w)
VFILEOPEN_170:          /* no error */
    moveq #0,%d0
    jbra CMDDONE

VFILEOPEN_176:          /* permission check (VPERMSSNCHK) */
    movel 0x788,%sp@-	/* through the vector at 0x788 (normally VPERMSSNCHK; patchable) */
    rts

/*
 VPERMSSNCHK: may the fork be opened with ioPermssn (+27: 0 whatever, 1 read, 2 write,
 3 read/write, 4 shared)? A locked file cannot be opened for writing (permErr); a
 second write path is refused (opWrErr, ioRefNum = the existing path) unless both
 are shared.
*/
trap_VPERMSSNCHK:
VPERMSSNCHK:
    cmpib #1,%a0@(27)	/* read only? */
    jbeq VPERMSSNCHK_2A
    bset #8,%d3
    jbeq VPERMSSNCHK_1C
    tstb %a0@(27)
    jbeq VPERMSSNCHK_2A
    clrw %a0@(24)
    moveq #-54,%d0	/* permErr */
    jbra VPERMSSNCHK_30
VPERMSSNCHK_1C:         /* shared write permission (bit 2)? */
    btst #2,%a0@(27)
    jbeq VPERMSSNCHK_28
    bset #12,%d3
VPERMSSNCHK_28:         /* check the other paths */
    jbra VPERMSSNCHK_32
VPERMSSNCHK_2A:         /* read-only: no write bit */
    bclr #8,%d3
    moveq #0,%d0
VPERMSSNCHK_30:         /* return */
    rts
VPERMSSNCHK_32:         /* another FCB for the same file */
    jbsr GETWDINFO_3B8
VPERMSSNCHK_36:         /* the same fork with write access? */
    jbne VPERMSSNCHK_60
    movew %a1@(0x4,%d1:w),%d0
    eorw %d3,%d0
    andiw #768,%d0
    jbne VPERMSSNCHK_52
    btst #12,%d3
    jbeq VPERMSSNCHK_58
    btst #4,%a1@(0x4,%d1:w)
    jbeq VPERMSSNCHK_58
VPERMSSNCHK_52:         /* next */
    jbsr GETWDINFO_3C6
    jbra VPERMSSNCHK_36
VPERMSSNCHK_58:         /* opWrErr: ioRefNum = that path */
    movew %d1,%a0@(24)
    moveq #-49,%d0	/* opWrErr */
    jbra VPERMSSNCHK_62
VPERMSSNCHK_60:         /* none: no error */
    moveq #0,%d0
VPERMSSNCHK_62:         /* return */
    rts

/* CREATEDIR: _DirCreate. */
CREATEDIR:
    jbsr FSQUEUESYNC_4
    bset #1,HFSFlags
    jbra FILECREATE_A

/* FILECREATE: _Create: a new catalog file record. */
trap_Create:
FILECREATE:
    jbsr FSQUEUESYNC_4
    bclr #1,HFSFlags
FILECREATE_A:           /* already exists: dupFNErr */
    jbsr SETCATINFO_88
    jbne FILECREATE_14
    moveq #-48,%d0	/* dupFNErr */
    jbra FILECREATE_78
FILECREATE_14:          /* not found (fnfErr): create it, if the volume may be written */
    cmpiw #-43,%d0
    jbne FILECREATE_78
    jbsr SETVOLINFO_A8
    jbne FILECREATE_78
    jbsr TFSVCBTST
    jbeq FILECREATE_34
    btst #1,HFSFlags
    jbeq FILECREATE_102
    moveq #-123,%d0	/* (DirCreate on MFS) */
    jbra FILECREATE_78
FILECREATE_34:          /* HFS: a file (2) or folder (1) record, ioFVersNum */
    moveb %a0@(26),%d1
    swap %d1
    moveb #2,%d1
    btst #1,HFSFlags
    jbeq FILECREATE_4A
    moveb #1,%d1
FILECREATE_4A:          /* the name in a frame buffer, CMCREATECN */
    movel %a0,%fp@-
    jbsr FILECREATE_7C
    movew %d2,%fp@-
    movel %d6,%d0
    jsr %pc@(CMSVCS)
    movew %fp@+,%d2
    jbsr FILECREATE_AC
    moveal %fp@+,%a0
    tstw %d0
    jbeq FILECREATE_6A
    cmpiw #48,%d0
    jbne FILECREATE_78
    moveq #-120,%d0	/* dirNFErr */
    jbra FILECREATE_78
FILECREATE_6A:          /* DirCreate: the new folder's ID into ioDirID */
    btst #1,HFSFlags
    jbeq FILECREATE_76
    movel %d1,%a0@(48)
FILECREATE_76:          /* no error */
    moveq #0,%d0
FILECREATE_78:          /* done */
    jbra CMDDONE

FILECREATE_7C:          /* copy the name (d2 bytes at a4) onto the a6 stack as a Pascal string (a0) */
    moveml %d0/%a1,%sp@-
    subal %a0,%a0
    tstw %d2
    jbeq FILECREATE_A6
    moveaw %d2,%a0
    addqw #1,%d2
    bclr #0,%d2
    subaw %d2,%fp
    movew %d2,%sp@-
    movew %a0,%d2
    moveal %a4,%a0
    moveal %fp,%a1
    moveq #0,%d0
    movew %d2,%d0
    _BlockMove
    movew %d2,%fp@-
    movew %sp@+,%d2
    moveal %fp,%a0
    addql #1,%a0
FILECREATE_A6:          /* restore, return */
    moveml %sp@+,%d0/%a1
    rts

FILECREATE_AC:          /* pop it */
    tstw %d2
    jbeq FILECREATE_B6
    movew %fp@+,%sp@-
    addaw %d2,%fp
    movew %sp@+,%d2
FILECREATE_B6:          /* return */
    rts
FILECREATE_B8:          /* MFS open: the FCB from the directory entry */
    moveal %d1,%a3
    movew CkdDB,%d7
    movew %a5@,%d3
    andiw #511,%d3
    btst #8,%d3
    jbeq FILECREATE_CE
    bset #13,%d3
FILECREATE_CE:          /* the fork's fields */
    movel %a2@(32),%a3@(30)
    lea %a5@(18),%a5
    movel %a5@+,%d2
    movew %a5@+,%d4
    movel %a5@+,%d5
    movel %a5@+,%d6
    tstb RegRsrc
    jbne FILECREATE_F0
    bset #9,%d3
    movew %a5@+,%d4
    movel %a5@+,%d5
    movel %a5@+,%d6
FILECREATE_F0:          /* permission check, then fill the FCB */
    jbsr VFILEOPEN_176
    jbne FILECREATE_FE
    jbra VFILEOPEN_126
    .long   0x42680018	| 40810BE4
FILECREATE_FE:          /* done */
    jbra CMDDONE
FILECREATE_102:         /* MFS create: no ':' in the name (bdNamErr) */
    tstw %d2
    jbeq FILECREATE_114
    movew %d2,%d0
FILECREATE_108:         /* look for ':' */
    subqw #1,%d0
    jblt FILECREATE_11A
    cmpib #58,%a4@(0x0,%d0:w)
    jbne FILECREATE_108
FILECREATE_114:         /* bdNamErr */
    moveq #-37,%d0	/* bdNamErr */
FILECREATE_116:         /* done */
    jbra CMDDONE
FILECREATE_11A:         /* room for a directory entry */
    jbsr FILECREATE_16C
    jbne FILECREATE_116
    movew %d5,%d0
    moveal %a5,%a1
FILECREATE_122:         /* clear it */
    clrw %a1@+
    subqw #2,%d0
    jbhi FILECREATE_122
    bset #7,%a5@
    moveb %a0@(26),%a5@(1)
    movel %a2@(38),%a5@(18)
    addql #1,%a2@(38)
    lea %a5@(42),%a5
    movel Time,%a5@
    movel %a5@+,%a5@+
    moveb %d2,%a5@+
    jbeq FILECREATE_150
FILECREATE_14A:         /* the name */
    moveb %a4@+,%a5@+
    subqb #1,%d2
    jbhi FILECREATE_14A
FILECREATE_150:         /* one more file; flush the directory */
    jbsr MARKVCB
    addqw #1,%a2@(20)
    jbsr FILECREATE_15E
    moveq #0,%d0
    jbra FILECREATE_116

FILECREATE_15E:         /* flush the volume's control cache */
    movew %a2@(78),%d0
    moveal SysCtlCPtr,%a1
    moveq #0,%d1
    jmp %pc@(FLUSHCACHE)

FILECREATE_16C:         /* MFS: find room for a 52 + name length entry in the directory blocks */
    moveal %sp@+,%a3
    moveq #52,%d5
    addw %d2,%d5
    bclr #0,%d5
    jbsr VFILEWRITE_D2
    jbra FILECREATE_180
FILECREATE_17C:         /* next directory block */
    jbsr VFILEWRITE_E2
FILECREATE_180:         /* none left: error */
    jbne FILECREATE_1A6
    moveq #0,%d0
FILECREATE_184:         /* the end of the block's entries */
    tstb %a5@(0x0,%d0:w)
    jbeq FILECREATE_18E
    jbsr FILECREATE_1A8
    jbcs FILECREATE_184
FILECREATE_18E:         /* fits? */
    movew %d0,%d4
    addw %d5,%d4
    cmpiw #512,%d4
    jbcc FILECREATE_17C
    jsr %pc@(MARKA5BLOCK)
    lea %a5@(0x0,%d0:w),%a5
    clrl %a2@(90)
    moveq #0,%d0
FILECREATE_1A6:         /* return */
    jmp %a3@

FILECREATE_1A8:         /* MFS: the next directory entry (d0 offset; C while below 460) */
    moveq #0,%d6
    moveb %a5@(0x32,%d0:w),%d6
    addw %d6,%d0
    addiw #52,%d0
    bclr #0,%d0
    cmpiw #460,%d0
    rts

FILECREATE_1BE:         /* WDCB loop start: a1 = the WDCB buffer, d1 = 2 */
    moveal WDCBsPtr,%a1
    moveq #2,%d1
    rts

FILECREATE_1C6:         /* next WDCB (16 bytes); C while inside */
    addiw #16,%d1
    cmpw %a1@,%d1
    rts

FILECREATE_1CE:         /* find a WDCB of volume a2 */
    jbsr FILECREATE_1BE
FILECREATE_1D0:         /* this one? */
    cmpal %a1@(0x0,%d1:w),%a2
    jbeq FILECREATE_1DE

FILECREATE_1D6:         /* next; none: Z clear */
    jbsr FILECREATE_1C6
    jbcs FILECREATE_1D0
    movew #0,%ccr
FILECREATE_1DE:         /* return */
    rts

FILECREATE_1E0:         /* is the folder a5 a working directory? fBsyErr if so */
    moveml %d2/%a1,%sp@-
    movel %a5@(6),%d2
    jbsr FILECREATE_1CE
FILECREATE_1EA:         /* next WDCB of the volume */
    jbne FILECREATE_1F6
    cmpl %a1@(0x4,%d1:w),%d2
    jbeq FILECREATE_1FE
    jbsr FILECREATE_1D6
    jbra FILECREATE_1EA
FILECREATE_1F6:         /* no */
    moveq #0,%d0
FILECREATE_1F8:         /* restore, return */
    moveml %sp@+,%d2/%a1
    rts
FILECREATE_1FE:         /* fBsyErr */
    movew %d1,%a0@(24)
    moveq #-47,%d0	/* fBsyErr */
    jbra FILECREATE_1F8

FILECREATE_206:         /* is the file open (an FCB of its number)? fBsyErr, ioRefNum = the path */
    movel %a1,%sp@-
    movel %a5@(20),%d2
    jbsr TFSVCBTST
    jbeq FILECREATE_216
    movel %a5@(18),%d2
FILECREATE_216:         /* find its FCB */
    jbsr GETWDINFO_3B8
    jbeq FILECREATE_222
    moveq #0,%d0
FILECREATE_21E:         /* return */
    moveal %sp@+,%a1
    rts
FILECREATE_222:         /* fBsyErr */
    movew %d1,%a0@(24)
    moveq #-47,%d0	/* fBsyErr */
    jbra FILECREATE_21E

/* FILEDELETE: _Delete: remove the file (or empty directory) and free its blocks. */
trap_Delete:
FILEDELETE:
    jbsr FSQUEUESYNC_4
    jbsr SETCATINFO_72
    jbsr TFSVCBTST
    jbne TFMOVE_FA
    moveq #-45,%d0	/* fLckdErr */
    btst #0,%a5@(2)
    jbne FILEDELETE_7C
    bclr #1,HFSFlags
    cmpib #1,%a5@
    jbne FILEDELETE_30
    bset #1,HFSFlags
    jbsr FILECREATE_1E0
    jbra FILEDELETE_3E
FILEDELETE_30:          /* a folder: not a working directory; a file: not open */
    cmpib #2,%a5@
    jbne FILEDELETE_40
    movel %d2,%fp@-
    jbsr FILECREATE_206
    movel %fp@+,%d2
    tstw %d0
FILEDELETE_3E:          /* busy? */
    jbne FILEDELETE_7C
FILEDELETE_40:          /* a file: drop its cached blocks, free its extents (FXM: DEALLOCFILE) */
    jbsr FILECREATE_7C
    movel %d2,%fp@-
    movel %d7,%d2
    cmpib #2,%a5@
    jbne FILEDELETE_5E
    movel %a5@(20),%d0
    jsr %pc@(TRASHFBLOCKS)
    movel %d6,%d0
    jsr %pc@(FXM)
    jbne FILEDELETE_7C
FILEDELETE_5E:          /* remove the catalog record (CMDELETECN): 50 = folder not empty (fBsyErr), 51 (paramErr) */
    movel %d6,%d0
    jsr %pc@(CMDELETECN)
    movel %fp@+,%d2
    jbsr FILECREATE_AC
    cmpiw #50,%d0
    jbne FILEDELETE_74
    moveq #-47,%d0	/* fBsyErr */
    jbra FILEDELETE_7C
FILEDELETE_74:          /* 51? */
    cmpiw #51,%d0
    jbne FILEDELETE_7C
    moveq #-50,%d0	/* paramErr */
FILEDELETE_7C:          /* done */
    jbra CMDDONE

/* RENAME: _Rename. */
trap_Rename:
RENAME:
    jbsr FSQUEUESYNC_4
    movel %a0@(28),%d2
    jbsr VDTRMV1_132
    jbne RENAME_16A
    tstw %d2
    jbeq RENAME_176
    moveal %a2,%a1
    movew %d3,%d7
    moveml %d2/%a4,FSTemp8
    jbsr VCKEXTFS_A
    jbne RENAME_30
    cmpal %a1,%a2
    jbeq RENAME_3C
    tstw %d7
    jbeq RENAME_3C
RENAME_2E:              /* bdNamErr */
    moveq #-37,%d0	/* bdNamErr */
RENAME_30:              /* B-tree "exists" (33): dupFNErr */
    cmpiw #33,%d0
    jbne RENAME_38
    moveq #-48,%d0	/* dupFNErr */
RENAME_38:              /* done */
    jbra CMDDONE
RENAME_3C:              /* HFS: find the old name; locked (fLckdErr)? */
    jbsr SETVOLINFO_A8
    jbne RENAME_30
    jbsr TFSVCBTST
    jbne TFMOVE_170
    jbsr SETCATINFO_88
    jbne RENAME_30
    moveq #-45,%d0	/* fLckdErr */
    btst #0,%a5@(2)
    jbne RENAME_30
    movel %d6,%d4
    movel %d7,%d5
    moveml %d2/%d4-%d5/%a4,%fp@-
    movel %a0@(18),%fp@-
    movel %a0@(28),%d2
    movel %d2,%a0@(18)
    jbsr SETCATINFO_88
    moveml %d2/%a4,FSTemp8
    movel %fp@+,%a0@(18)
    moveml %fp@+,%d2/%d4-%d5/%a4
    tstw %d0
    jbne RENAME_AA
    movel %a0,%sp@-
    moveml %d2/%a4,%fp@-
    movew %d2,%d0
    moveal %a4,%a0
    swap %d0
    moveml FSTemp8,%d2/%a4
    movew %d2,%d0
    moveal %a4,%a1
    _CmpString
    moveml %fp@+,%d2/%a4
    moveal %sp@+,%a0
    jbne RENAME_A8
    cmpl %d4,%d6
    jbeq RENAME_B6
RENAME_A8:              /* the new name exists (and is not the same entry, different case): dupFNErr */
    moveq #-48,%d0	/* dupFNErr */
RENAME_AA:              /* not found (fnfErr): rename it, unless it would move */
    cmpiw #-43,%d0
    jbne RENAME_30
    cmpl %d4,%d6
    jbne RENAME_2E
RENAME_B6:              /* both names on the a6 stack: CMRENAMECN */
    jbsr FILECREATE_7C
    movel %d2,%sp@-
    moveal %a0,%a1
    moveml FSTemp8,%d2/%a4
    jbsr FILECREATE_7C
    movel %sp@+,%fp@-
    movel %d2,%fp@-
    exg %a0,%a1
    movel %d4,%d0
    movel %d5,%d2
    jsr %pc@(CMRENAMECN)
    movel %d2,%d7
    tstw %d0
    jbne RENAME_FA
    cmpil #1,%d4
    jbeq RENAME_F2
    cmpil #2,%d4
    jbne RENAME_FA
    tstl %fp@(4)
    jbgt RENAME_FA
RENAME_F2:              /* the root folder: the volume takes the name too */
    jbsr SETVOLINFO_74
    moveq #0,%d0
    moveq #1,%d6
RENAME_FA:              /* pop the names; renamed a file? update its open FCBs' names */
    movel %fp@+,%d2
    movel %fp@+,%sp@-
    jbsr FILECREATE_AC
    movel %sp@+,%d2
    jbsr FILECREATE_AC
    tstw %d0
    jbne RENAME_30
    cmpil #1,%d6
    jbeq RENAME_30
    moveml FSTemp8,%d2/%a4
    jbsr FILECREATE_7C
    movel %d2,%fp@-
    movel %d6,%d0
    movel %d7,%d2
    jsr %pc@(CMGETCN)
    movel %fp@+,%d2
    jbsr FILECREATE_AC
    tstw %d0
    jbne RENAME_30
    moveb %d2,%d3
    moveal %a1,%a5
    moveal %a4,%a0
    movel %a5@(20),%d2
    jbsr GETWDINFO_3B8
    jbne RENAME_30
RENAME_14A:             /* each open FCB of the file: catalog hint and name */
    movel %d7,%a1@(0x36,%d1:w)
    lea %a1@(0x3e,%d1:w),%a1
    moveb %d3,%a1@+
    moveq #0,%d0
    moveb %d3,%d0
    _BlockMove
    moveal FCBSPtr,%a1
    jbsr GETWDINFO_3C6
    jbeq RENAME_14A
RENAME_164:             /* no error */
    moveq #0,%d0
RENAME_166:             /* done */
    jbra RENAME_30
RENAME_16A:             /* no such volume: only a volume rename ("Name:") is possible */
    cmpiw #-35,%d0
    jbne RENAME_166
    tstw %d2
    jbne RENAME_2E
RENAME_176:             /* rename the volume */
    tstw %d3
    jbeq RENAME_166
    jbsr VCKEXTFS_A
    jbne RENAME_166
    jbsr SETVOLINFO_A8
    jbne RENAME_166
    cmpiw #16964,%a2@(8)
    jbeq RENAME_196
    tstw %a2@(72)
    jbeq RENAME_166
    jbra RENAME_19C
RENAME_196:             /* HFS: on line */
    jbsr VFNDFILNAME_124
    jbne RENAME_166
RENAME_19C:             /* the new name; HFS: also the root folder's */
    moveal %a0@(28),%a1
    jbsr SETVOLINFO_74
    jbsr TFSVCBTST
    jbne RENAME_164
    moveq #0,%d2
    moveq #2,%d0
    moveal %d2,%a0
    lea %a2@(44),%a1
    jsr %pc@(CMRENAMECN)
    jbra RENAME_30

/* TFMOVE: _CatMove: move a file or directory to another directory. */
TFMOVE:
    jbsr FSQUEUESYNC_4
    movel %a0@(18),%fp@-
    movel %a0@(28),%a0@(18)
    jbsr VCKEXTFS_A
    movel %fp@+,%a0@(18)
    moveal %a2,%a1
    movew %d3,%d7
    jbsr VCKEXTFS_A
    jbne TFMOVE_2A
    cmpal %a1,%a2
    jbeq TFMOVE_2E
    tstw %d7
    jbeq TFMOVE_2E
TFMOVE_28:              /* bdNamErr */
    moveq #-37,%d0	/* bdNamErr */
TFMOVE_2A:              /* done */
    jbra CMDDONE
TFMOVE_2E:              /* HFS only (paramErr on MFS); find the item to move */
    jbsr SETVOLINFO_A8
    jbne TFMOVE_2A
    jbsr VFNDFILNAME_124
    jbne TFMOVE_2A
    moveq #-50,%d0	/* paramErr */
    jbsr TFSVCBTST
    jbne TFMOVE_2A
    jbsr SETCATINFO_88
    jbne TFMOVE_2A
    moveq #0,%d3
    cmpib #2,%a5@
    jbne TFMOVE_54
    movel %a5@(20),%d3
TFMOVE_54:              /* find the destination folder (ioNewName +28, ioNewDirID +36) */
    movel %d6,%d4
    movel %d7,%d5
    moveml %d2/%a4,FSTemp8
    movel %a0@(18),%fp@-
    movel %a0@(48),%fp@-
    movel %a0@(28),%a0@(18)
    movel %a0@(36),%a0@(48)
    moveml %d3-%d5,%fp@-
    jbsr SETCATINFO_88
    moveml %fp@+,%d3-%d5
    movel %fp@+,%a0@(48)
    movel %fp@+,%a0@(18)
    tstw %d0
    jbeq TFMOVE_96
    cmpiw #-37,%d0
    jbne TFMOVE_2A
TFMOVE_90:              /* a name not found */
    tstw %d2
    jbne TFMOVE_28
    jbra TFMOVE_A2
TFMOVE_96:              /* the destination must be a folder */
    cmpib #1,%a5@
    jbne TFMOVE_28
    movel %a5@(6),%d6
    moveq #0,%d7
TFMOVE_A2:              /* move it (CMMOVECN) unless it is already there; 49: a same name there (dupFNErr) */
    moveml FSTemp8,%d2/%a4
    cmpl %d4,%d6
    jbeq TFMOVE_F4
    jbsr FILECREATE_7C
    movel %d2,%fp@-
    movel %d3,%fp@-
    movel %d4,%d0
    movel %d5,%d2
    movel %d6,%d1
    movel %d7,%d3
    subal %a1,%a1
    jsr %pc@(CMMOVECN)
    movel %d2,%d7
    movel %fp@+,%d3
    movel %fp@+,%d2
    jbsr FILECREATE_AC
    tstw %d0
    jbeq TFMOVE_DC
    cmpiw #49,%d0
    jbne TFMOVE_D8
    moveq #-48,%d0	/* dupFNErr */
TFMOVE_D8:              /* done */
    jbra TFMOVE_2A
TFMOVE_DC:              /* a file: its open FCBs get the new parent and hint */
    movel %d3,%d2
    jbeq TFMOVE_F4
    jbsr GETWDINFO_3B8
    jbne TFMOVE_F4
TFMOVE_E6:              /* each FCB */
    movel %d7,%a1@(0x36,%d1:w)
    movel %d6,%a1@(0x3a,%d1:w)
    jbsr GETWDINFO_3C6
    jbeq TFMOVE_E6
TFMOVE_F4:              /* no error */
    moveq #0,%d0
    jbra TFMOVE_2A
TFMOVE_FA:              /* MFS _Delete: not locked, not open; free its blocks, remove its directory entry */
    moveq #-45,%d0	/* fLckdErr */
    btst #0,%a5@
    jbne TFMOVE_130
    jbsr FILECREATE_206
    jbne TFMOVE_130
    subqw #1,%a2@(20)
    jbsr MARKVCB
    movew %a5@(22),%d3
    jbsr VLG2PHYS_1D0
    movew %a5@(32),%d3
    jbsr VLG2PHYS_1D0
    movel %a5@(18),%d0
    jbsr TFMOVE_144
    jsr %pc@(TRASHFBLOCKS)
    jbsr FILECREATE_15E
    moveq #0,%d0
TFMOVE_130:             /* done */
    jbra CMDDONE

TFMOVE_134:             /* MFS: the length of directory entry a5 (52 + name, even) */
    moveq #0,%d0
    moveb %a5@(50),%d0
    addiw #52,%d0
    bclr #0,%d0
    rts

TFMOVE_144:             /* MFS: remove directory entry a5 from its block (shift the rest down) */
    moveml %d0/%a0-%a1/%a5,%sp@-
    moveal %a1,%a0
    jsr %pc@(MARKBLOCK)
    clrl %a2@(90)
    moveal %a5,%a0
    jbsr TFMOVE_134
    addal %d0,%a5
    lea %a1@(512),%a1
TFMOVE_15C:             /* shift */
    cmpal %a1,%a5
    jbcc TFMOVE_164
    movew %a5@+,%a0@+
    jbra TFMOVE_15C
TFMOVE_164:             /* clear the end */
    clrw %a0@+
    cmpal %a1,%a0
    jbcs TFMOVE_164
    moveml %sp@+,%d0/%a0-%a1/%a5
    rts
TFMOVE_170:             /* MFS _Rename: the new name must not exist (unless only the case changes) */
    movel %a0,%sp@-
    movew %d2,%d0
    moveal %a4,%a0
    moveml FSTemp8,%d2/%a4
    swap %d0
    movew %d2,%d0
    moveal %a4,%a1
    _CmpString
    moveal %sp@+,%a0
    jbeq TFMOVE_196
    jbsr VFNDFILNAME_34
    jbne TFMOVE_190
    moveq #-48,%d0	/* dupFNErr */
TFMOVE_190:             /* not found: fine */
    cmpiw #-43,%d0
    jbne TFMOVE_1E4
TFMOVE_196:             /* the old entry, not locked: save it, remove it, insert it with the new name */
    jbsr SETCATINFO_88
    jbne TFMOVE_1E4
    moveq #-45,%d0	/* fLckdErr */
    btst #0,%a5@
    jbne TFMOVE_1E4
    moveal %fp,%a4
    moveal %a5,%a3
    jbsr TFMOVE_134
TFMOVE_1AA:             /* save the entry on the a6 stack */
    movew %a3@(0xfffffffffffffffe,%d0:w),%fp@-
    subqw #2,%d0
    jbgt TFMOVE_1AA
    jbsr TFMOVE_144
    movel FSTemp8,%d2
    jbsr FILECREATE_16C
    jbne TFMOVE_1E8
    moveal %a5,%a3
    moveq #24,%d0
TFMOVE_1C2:             /* back, with the new name */
    movew %fp@+,%a5@+
    dbf %d0,TFMOVE_1C2
    moveal %a4,%fp
    moveml FSTemp8,%d2/%a4
    moveb %d2,%a5@+
TFMOVE_1D2:             /* copy the name */
    moveb %a4@+,%a5@+
    subqw #1,%d2
    jbgt TFMOVE_1D2
    jbsr TFMOVE_206
    jbsr MARKVCBTIME
    jbsr FILECREATE_15E
    moveq #0,%d0
TFMOVE_1E4:             /* done */
    jbra CMDDONE
TFMOVE_1E8:             /* no room: put the old entry back; fsRnErr */
    moveb %fp@(50),%d2
    jbsr FILECREATE_16C
    jbeq TFMOVE_1F8
    moveal %a4,%fp
    moveq #-59,%d0	/* fsRnErr */
    jbra TFMOVE_1E4
TFMOVE_1F8:             /* restore it */
    moveal %a5,%a3
TFMOVE_1FA:             /* copy */
    movew %fp@+,%a5@+
    cmpal %fp,%a4
    jbne TFMOVE_1FA
    jbsr TFMOVE_206
    moveq #-33,%d0	/* dirFulErr */
    jbra TFMOVE_1E4
TFMOVE_206:             /* MFS: open FCBs of the file get its new directory block */
    movel %a3@(18),%d2
    movew CkdDB,%d0
    jbsr GETWDINFO_3B8
    jbne TFMOVE_21E
TFMOVE_214:             /* each */
    movew %d0,%a1@(0x1c,%d1:w)
    jbsr GETWDINFO_3C6
    jbeq TFMOVE_214
TFMOVE_21E:             /* return */
    rts

/* SETFILTYPE: _SetFilType. */
trap_SetFilType:
SETFILTYPE:
    jbsr FSQUEUESYNC_4
    moveb %a0@(26),%d1
    moveb %a0@(28),%a0@(26)
    jbsr SETCATINFO_88
    moveb %d1,%a0@(26)
    tstw %d0
    jbne SETFILTYPE_22
    jbsr TFSVCBTST
    jbeq SETFILTYPE_34
    moveq #-48,%d0	/* dupFNErr */
SETFILTYPE_22:          /* MFS: a new version number; HFS: paramErr */
    cmpiw #-43,%d0
    jbne RSTFILLOCK_3E
    jbsr SETCATINFO_72
    jbsr TFSVCBTST
    jbne GETFILEINFO_28C
SETFILTYPE_34:          /* paramErr */
    moveq #-50,%d0	/* paramErr */
    jbra RSTFILLOCK_3E

/* SETFILLOCK: _SetFilLock. */
trap_SetFilLock:
SETFILLOCK:
    jbsr FSQUEUESYNC_4
    st FLckUnlck
    jbra RSTFILLOCK_8

/* RSTFILLOCK: _RstFilLock. */
trap_RstFilLock:
RSTFILLOCK:
    jbsr FSQUEUESYNC_4
    clrb FLckUnlck
RSTFILLOCK_8:           /* the file's record (writable volume) */
    jbsr SETCATINFO_72
    jbsr TFSVCBTST
    jbne GETFILEINFO_294
    moveq #-43,%d0	/* fnfErr */
    cmpib #2,%a5@
    jbne RSTFILLOCK_3E
    tstb FLckUnlck
    jbeq RSTFILLOCK_2C
    bset #0,%a5@(2)
    jbne RSTFILLOCK_3C
    jbra RSTFILLOCK_34
RSTFILLOCK_2C:          /* unlock */
    bclr #0,%a5@(2)
    jbeq RSTFILLOCK_3C
RSTFILLOCK_34:          /* write the catalog record back (CMUPDATECN) */
    movel %d7,%d2
    jsr %pc@(CMUPDATECN)
    jbra RSTFILLOCK_3E
RSTFILLOCK_3C:          /* unchanged: no error */
    moveq #0,%d0
RSTFILLOCK_3E:          /* done */
    jbra CMDDONE

/* SETFILEINFO: _SetFileInfo. */
trap_SetFileInfo:
SETFILEINFO:
    jbsr FSQUEUESYNC_4
    jbsr SETCATINFO_72
    jbsr TFSVCBTST
    jbne GETFILEINFO_2B8
    moveq #-43,%d0	/* fnfErr */
    cmpib #2,%a5@
    jbne RSTFILLOCK_3E
    moveml %a0@(32),%d1-%d4
    moveml %d1-%d4,%a5@(4)
    moveml %a0@(72),%d1-%d2
    moveml %d1-%d2,%a5@(44)
    jbra RSTFILLOCK_34

/* SETCATINFO: _SetCatInfo. */
SETCATINFO:
    jbsr FSQUEUESYNC_4
    jbsr SETCATINFO_72
    jbsr TFSVCBTST
    jbne GETFILEINFO_2B8
    cmpib #2,%a5@
    jbne SETCATINFO_40
    moveml %a0@(32),%d0-%d3
    moveml %d0-%d3,%a5@(4)
    moveml %a0@(84),%d0-%d3
    moveml %d0-%d3,%a5@(56)
    moveml %a0@(72),%d0-%d1
    moveml %d0-%d1,%a5@(44)
    movel %a0@(80),%a5@(52)
    jbra SETCATINFO_6C
SETCATINFO_40:          /* a folder record: Finder info, dates */
    moveq #-37,%d0	/* bdNamErr */
    cmpib #1,%a5@
    jbne SETCATINFO_6E
    moveml %a0@(32),%d1-%d4
    moveml %d1-%d4,%a5@(22)
    moveml %a0@(84),%d0-%d3
    moveml %d0-%d3,%a5@(38)
    moveml %a0@(72),%d0-%d2
    moveml %d0-%d2,%a5@(10)
SETCATINFO_6C:          /* no error */
    moveq #0,%d0
SETCATINFO_6E:          /* write it back */
    jbra RSTFILLOCK_34

SETCATINFO_72:          /* find the item (VFNDFILNAME) on a writable volume; on error leave the call */
    movel %sp@+,%fp@-
    jbsr SETCATINFO_88
    jbne SETCATINFO_82
    jbsr SETVOLINFO_A8
    jbne SETCATINFO_82
    movel %fp@+,%sp@-
    rts
SETCATINFO_82:          /* error: done */
    addqw #4,%fp
    jbra CMDDONE

SETCATINFO_88:          /* find a file or folder (VFNDFILNAME) */
    movel 0x78c,%sp@-	/* through the vector at 0x78C (normally VFNDFILNAME; patchable) */
    rts

/*
 VFNDFILNAME: find the catalog record of the call's name (ioNamePtr, relative to the
 volume's or working directory's folder, or ioDirID for H calls): each "folder:"
 part of a partial path name is looked up in turn ("::" goes to the parent). Out:
 a5 = the record, d6 = parent dir ID, d7 = catalog hint, d2/a4 = the last name part;
 fnfErr, dirNFErr, bdNamErr (a part over 31 characters).
*/
trap_VFNDFILNAME:
VFNDFILNAME:
    jbsr VCKEXTFS_A
    jbeq VFNDFILNAME_8
VFNDFILNAME_6:          /* return */
    rts
VFNDFILNAME_8:          /* the starting folder: root, the WD's, or ioDirID */
    moveq #2,%d6
    movel %a3,%d7
    jbeq VFNDFILNAME_16
    movel %a3@(4),%d6
    movel %a3@(8),%d7
VFNDFILNAME_16:         /* a name with only a volume part? */
    movel %a4,%d0
    jbeq VFNDFILNAME_22
    subl %a0@(18),%d0
    subql #2,%d0
    jbgt VFNDFILNAME_34
VFNDFILNAME_22:         /* H call: ioDirID */
    btst #9,%a0@(6)
    jbeq VFNDFILNAME_34
    movel %a0@(48),%d0
    jbeq VFNDFILNAME_34
    movel %d0,%d6
    moveq #0,%d7
VFNDFILNAME_34:         /* on line? MFS: its own lookup */
    jbsr VFNDFILNAME_124
    jbne VFNDFILNAME_6
    jbsr TFSVCBTST
    jbne GETFILEINFO_2D2
    movel %sp@+,%fp@-
    moveml %d1/%a0-%a1,%fp@-
    movel %d2,%d1
    movel %d2,%d4
VFNDFILNAME_4C:         /* the next part of the name */
    moveq #-120,%d0	/* dirNFErr */
    moveq #0,%d1
VFNDFILNAME_50:         /* up to ':' */
    moveq #0,%d3
    cmpw %d4,%d1
    jbge VFNDFILNAME_82
    cmpib #58,%a4@(0x0,%d1:w)
    jbeq VFNDFILNAME_6E
    cmpiw #31,%d1
    jblt VFNDFILNAME_6A
    moveq #-37,%d0	/* bdNamErr */
    jbra VFNDFILNAME_11A
VFNDFILNAME_6A:         /* next character */
    addqw #1,%d1
    jbra VFNDFILNAME_50
VFNDFILNAME_6E:         /* a ':' : look up this part as a folder ("::" = the parent) */
    bset #5,HFSFlags
    tstw %d1
    seq %d3
    swap %d3
    movew %d4,%d3
    subw %d1,%d3
    subqw #1,%d3
    jbgt VFNDFILNAME_84
VFNDFILNAME_82:         /* the last part: fnfErr if not found */
    moveq #-43,%d0	/* fnfErr */
VFNDFILNAME_84:         /* the part on the a6 stack, CMGETCN in the current folder */
    swap %d3
    moveml %d6-%d7,%fp@-
    moveml %d0/%a1,%sp@-
    moveal %d1,%a0
    addqw #1,%d1
    lsrw #1,%d1
    lslw #1,%d1
    subal %d1,%fp
    movel %d1,%sp@-
    movel %a0,%d1
    moveal %a4,%a0
    moveal %fp,%a1
    movel %d1,%d0
    _BlockMove
    movew %d1,%fp@-
    movel %sp@+,%d1
    moveal %fp,%a0
    addql #1,%a0
    moveml %sp@+,%d0/%a1
    exg %d6,%d0
    movel %d7,%d2
    jsr %pc@(CMGETCN)
    movew %fp@+,%sp@-
    addal %d1,%fp
    moveq #0,%d1
    movew %sp@+,%d1
    tstw %d0
    jbne VFNDFILNAME_10C
    tstb %d3
    jbeq VFNDFILNAME_E8
    moveq #-120,%d0	/* dirNFErr */
    cmpil #1,%a0@(2)
    jbeq VFNDFILNAME_10C
    movel %a0@(2),%d0
    moveq #0,%d2
    subal %a0,%a0
    jsr %pc@(CMGETCN)
    jbne VFNDFILNAME_10C
    movel %a0@(2),%d0
    moveq #0,%d2
VFNDFILNAME_E8:         /* a folder part: continue in it */
    cmpiw #-43,%d6
    jbeq VFNDFILNAME_102
    moveml %fp@+,%d6-%d7
    movel %a1@(6),%d6
    movel %d2,%d7
    addqw #1,%d1
    addal %d1,%a4
    subw %d1,%d4
    jbra VFNDFILNAME_4C
VFNDFILNAME_102:        /* the last part found */
    moveq #0,%d0
    moveal %a1,%a5
    movel %d2,%fp@(4)
    jbra VFNDFILNAME_114
VFNDFILNAME_10C:        /* B-tree "not found" (48): keep the error */
    cmpiw #48,%d0
    jbne VFNDFILNAME_114
    movel %d6,%d0
VFNDFILNAME_114:        /* restore */
    moveml %fp@+,%d6-%d7
    movel %d1,%d2
VFNDFILNAME_11A:        /* return (d0 tested) */
    moveml %fp@+,%d1/%a0-%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

VFNDFILNAME_124:        /* the volume must be on line (volOffLinErr); ReqstVol = it */
    jbsr FLUSHVOL_3C
    jbne VFNDFILNAME_132
    tstw %a2@(72)
    jbne VFNDFILNAME_132
    moveq #-53,%d0	/* volOffLinErr */
VFNDFILNAME_132:        /* return */
    movel %a2,ReqstVol
    tstw %d0
    rts

/* GETCATINFO: _GetCatInfo. */
GETCATINFO:
    jbsr FSQUEUESYNC_4
    bset #0,HFSFlags
    tstw %a0@(28)
    jbmi GETFILEINFO_3E
    jbra GETFILEINFO_A

/* GETFILEINFO: _GetFileInfo. */
trap_GetFileInfo:
GETFILEINFO:
    jbsr FSQUEUESYNC_4
    bclr #0,HFSFlags
GETFILEINFO_A:          /* ioFDirIndex > 0: by index; else by name */
    movew %a0@(28),%d1
    jbgt GETFILEINFO_40
    jbsr SETCATINFO_88
    jbeq GETFILEINFO_30
    cmpiw #-37,%d0
    jbne GETFILEINFO_156
    tstb %d2
    jbne GETFILEINFO_156
    btst #0,HFSFlags
    jbne GETFILEINFO_8E
    jbra GETFILEINFO_156
GETFILEINFO_30:         /* found: HFS: the record's info */
    jbsr TFSVCBTST
    jbne GETFILEINFO_3A2
    movel %d6,%d1
    jbra GETFILEINFO_18E
GETFILEINFO_3E:         /* _GetCatInfo with ioFDirIndex < 0: the folder itself */
    moveq #0,%d1
GETFILEINFO_40:         /* by index (searching HFSFlags 5 off) */
    bset #5,HFSFlags
    jbsr VDTRMV3_E
    jbne GETFILEINFO_156
    jbsr VFNDFILNAME_124
    jbne GETFILEINFO_156
    moveq #2,%d6
    movel %a3,%d7
    jbeq GETFILEINFO_62
    movel %a3@(4),%d6
    movel %a3@(8),%d7
GETFILEINFO_62:         /* H call: ioDirID */
    btst #9,%a0@(6)
    jbeq GETFILEINFO_76
    tstl %a0@(48)
    jbeq GETFILEINFO_76
    movel %a0@(48),%d6
    moveq #0,%d7
GETFILEINFO_76:         /* MFS: only the root; by index or the root's info */
    jbsr TFSVCBTST
    jbeq GETFILEINFO_DE
    moveq #-120,%d0	/* dirNFErr */
    cmpil #2,%d6
    jbne GETFILEINFO_156
    tstw %d1
    jbgt GETFILEINFO_336
GETFILEINFO_8E:         /* (fills in a folder-like answer for the root: dir ID 2, valence = file count, dates; the volume name if asked) */
    lea %a0@(30),%a1
    moveq #38,%d0
GETFILEINFO_94:         /* clear the answer */
    clrw %a1@+
    dbf %d0,GETFILEINFO_94
    bset #4,%a0@(30)
    movel #2,%a0@(48)
    movel #1,%a0@(100)
    movew %a2@(20),%a0@(52)
    movel %a2@(10),%a0@(72)
    movel %a2@(14),%a0@(76)
    movel %a0@(18),%d0
    jbeq GETFILEINFO_DA
    tstw %a0@(28)
    jbeq GETFILEINFO_DA
    moveal %d0,%a1
    lea %a2@(44),%a0
    moveq #1,%d0
    addb %a0@,%d0
    _BlockMove
GETFILEINFO_DA:         /* no error */
    moveq #0,%d0
    jbra GETFILEINFO_156
GETFILEINFO_DE:         /* HFS: dir ID 1 (the root's parent) is not a valid item: fnfErr */
    moveq #1,%d0
    cmpl %d0,%d6
    jbeq GETFILEINFO_154
    tstw %d1
    jbne GETFILEINFO_FC
    moveml %a0-%a1,%fp@-
    movel %d6,%d0
    movel %d7,%d2
    subal %a0,%a0
    jsr %pc@(CMGETCN)
    jbne GETFILEINFO_14A
    movel %d2,%d7
    jbra GETFILEINFO_170
GETFILEINFO_FC:         /* by index in the folder: _GetCatInfo any record, _GetFileInfo files only; the last index and position are kept in the VCB (+90, +176) to continue */
    btst #0,HFSFlags
    jbne GETFILEINFO_15A
    movew %d1,%d5
    movew %a2@(176),%d1
    cmpl %a2@(172),%d6
    jbne GETFILEINFO_122
    cmpw %a2@(90),%d5
    jbcs GETFILEINFO_122
    movew %a2@(90),%d0
    movew %d5,%a2@(90)
    subw %d0,%d5
    jbra GETFILEINFO_12A
GETFILEINFO_122:        /* start from the folder's first entry */
    moveq #1,%d1
    movew %d5,%a2@(90)
    subqw #1,%d5
GETFILEINFO_12A:        /* step through the folder's records (CMGETOFF): only files count for GetFileInfo */
    moveml %a0-%a1,%fp@-
GETFILEINFO_12E:        /* next record */
    movel %d6,%d0
    movel %d7,%d2
    subal %a0,%a0
    jsr %pc@(CMGETOFF)
    jbne GETFILEINFO_14A
    movel %d2,%d7
    addqw #1,%d1
    cmpib #2,%a1@
    jbne GETFILEINFO_12E
    dbf %d5,GETFILEINFO_12E
    jbra GETFILEINFO_170
GETFILEINFO_14A:        /* end of the folder (48): fnfErr */
    moveml %fp@+,%a0-%a1
    cmpiw #48,%d0
    jbne GETFILEINFO_156
GETFILEINFO_154:        /* fnfErr */
    moveq #-43,%d0	/* fnfErr */
GETFILEINFO_156:        /* done */
    jbra CMDDONE
GETFILEINFO_15A:        /* the first record of the folder (cache reset) */
    moveml %a0-%a1,%fp@-
    movew #-1,%a2@(90)
    movel %d6,%d0
    movel %d7,%d2
    subal %a0,%a0
    jsr %pc@(CMGETOFF)
    jbne GETFILEINFO_14A
GETFILEINFO_170:        /* the record: its name to ioNamePtr */
    lea %a0@(6),%a3
    movel %a0@(2),%d1
    moveal %a1,%a5
    moveml %fp@+,%a0-%a1
    movel %a0@(18),%d0
    jbeq GETFILEINFO_18E
    moveal %d0,%a4
    moveb %a3@,%d0
GETFILEINFO_188:        /* copy the name */
    moveb %a3@+,%a4@+
    subqb #1,%d0
    jbcc GETFILEINFO_188
GETFILEINFO_18E:        /* _GetFileInfo: only files: the file record's attributes, type, Finder info, forks, dates */
    btst #0,HFSFlags
    jbne GETFILEINFO_206
    cmpib #2,%a5@
    jbne GETFILEINFO_154
    lea %a0@(30),%a4
    moveq #24,%d0
    lea %a5@(2),%a3
GETFILEINFO_1A6:        /* copy */
    movew %a3@+,%a4@+
    dbf %d0,GETFILEINFO_1A6
    bclr #4,%a0@(30)
GETFILEINFO_1B2:        /* ioFlAttrib: locked, open bits from the FCBs (2 resource fork open, 3 data fork open, 7 open); ioFRefNum = the first path */
    andib #115,%a0@(30)
    clrw %a0@(24)
    movel %a5@(20),%d2
    jbsr TFSVCBTST
    jbeq GETFILEINFO_1CA
    movel %a5@(18),%d2
GETFILEINFO_1CA:        /* its FCBs */
    jbsr GETWDINFO_3B8
    jbne GETFILEINFO_200
GETFILEINFO_1D0:        /* which fork? */
    btst #1,%a1@(0x4,%d1:w)
    jbeq GETFILEINFO_1E0
    bset #2,%a0@(30)
    jbra GETFILEINFO_1E6
GETFILEINFO_1E0:        /* data fork open */
    bset #3,%a0@(30)
GETFILEINFO_1E6:        /* open; ioFRefNum = the first */
    bset #7,%a0@(30)
    jbne GETFILEINFO_1F2
    movew %d1,%a0@(24)
GETFILEINFO_1F2:        /* the fork's current lengths from the FCB (it may be extended) */
    lea %a0@(52),%a3
    jbsr VFCLOSE_1B2
    jbsr GETWDINFO_3C6
    jbeq GETFILEINFO_1D0
GETFILEINFO_200:        /* no error */
    moveq #0,%d0
    jbra GETFILEINFO_156
GETFILEINFO_206:        /* _GetCatInfo: a file (the whole record, clump size, parent ID) or a folder (valence, dir ID, dates, Finder info; ioFlAttrib bit 4) */
    lea %a0@(30),%a4
    cmpib #2,%a5@
    jbne GETFILEINFO_238
    moveq #34,%d0
    lea %a5@(2),%a3
GETFILEINFO_216:        /* copy */
    movew %a3@+,%a4@+
    dbf %d0,GETFILEINFO_216
    moveq #0,%d0
    movew %a5@(72),%d0
    muluw %a2@(30),%d0
    movel %d0,%a0@(104)
    movel %d1,%a0@(100)
    bclr #4,%a0@(30)
    jbra GETFILEINFO_1B2
GETFILEINFO_238:        /* a folder */
    cmpib #1,%a5@
    jbne GETFILEINFO_154
    movew %a5@(2),%a0@(30)
    movew %a5@(4),%a0@(52)
    movel %a5@(6),%a0@(48)
    movel %d1,%a0@(100)
    moveml %a5@(10),%d0-%d2
    moveml %d0-%d2,%a0@(72)
    moveml %a5@(22),%d0-%d3
    moveml %d0-%d3,%a0@(32)
    moveml %a5@(38),%d0-%d3
    moveml %d0-%d3,%a0@(84)
    bclr #7,%a0@(30)
    bset #4,%a0@(30)
    moveq #0,%d0
    jbra GETFILEINFO_156
GETFILEINFO_28C:        /* MFS SetFilType: the version number */
    moveb %a0@(28),%a5@(1)
    jbra GETFILEINFO_2A8
GETFILEINFO_294:        /* MFS lock / unlock: the entry's flags */
    tstb FLckUnlck
    jbeq GETFILEINFO_2A2
    bset #0,%a5@
    jbne GETFILEINFO_2B2
    jbra GETFILEINFO_2A8
GETFILEINFO_2A2:        /* unlock */
    bclr #0,%a5@
    jbeq GETFILEINFO_2B2
GETFILEINFO_2A8:        /* the directory block dirty, flush */
    moveal %a1,%a0
    jsr %pc@(MARKBLOCK)
    jbsr FILECREATE_15E
GETFILEINFO_2B2:        /* no error */
    moveq #0,%d0
    jbra CMDDONE
GETFILEINFO_2B8:        /* MFS SetFileInfo: Finder info, dates */
    moveml %a0@(32),%d1-%d4
    moveml %d1-%d4,%a5@(2)
    moveml %a0@(72),%d1-%d2
    moveml %d1-%d2,%a5@(42)
    jbra GETFILEINFO_2A8
GETFILEINFO_2D2:        /* MFS: find the directory entry of name d2/a4 (and version), bdNamErr for no name */
    moveal %sp@+,%a3
    tstb %d2
    jbne GETFILEINFO_2DC
    moveq #-37,%d0	/* bdNamErr */
    jbra GETFILEINFO_334
GETFILEINFO_2DC:        /* d7 = files left to look at */
    movew %a2@(20),%d7
    jbeq GETFILEINFO_2EE
    jbsr VFILEWRITE_D2
GETFILEINFO_2E6:        /* next block (dirFulErr at the end: fnfErr) */
    jbeq GETFILEINFO_2F2
    cmpiw #-33,%d0
    jbne GETFILEINFO_334
GETFILEINFO_2EE:        /* fnfErr */
    moveq #-43,%d0	/* fnfErr */
    jbra GETFILEINFO_334
GETFILEINFO_2F2:        /* the entries of the block */
    moveq #0,%d0
    moveal %a4,%a1
GETFILEINFO_2F6:        /* next entry */
    movew %d0,%d4
    tstb %a5@(0x0,%d4:w)
GETFILEINFO_2FC:        /* same version and name (CmpString)? */
    jbeq GETFILEINFO_328
    moveb %a5@(0x1,%d4:w),%d6
    cmpb %a0@(26),%d6
    jbne GETFILEINFO_31C
    movel %a0,%sp@-
    lea %a5@(0x32,%d4:w),%a0
    moveq #0,%d0
    moveb %a0@+,%d0
    swap %d0
    movew %d2,%d0
    _CmpString
    moveal %sp@+,%a0
    jbeq GETFILEINFO_32E
GETFILEINFO_31C:        /* next */
    subqw #1,%d7
    jbeq GETFILEINFO_2EE
    movew %d4,%d0
    jbsr FILECREATE_1A8
    jbcs GETFILEINFO_2F6
GETFILEINFO_328:        /* next block */
    jbsr VFILEWRITE_E2
    jbra GETFILEINFO_2E6
GETFILEINFO_32E:        /* found: a1 = the block, a5 = the entry */
    moveal %a5,%a1
    lea %a5@(0x0,%d4:w),%a5
GETFILEINFO_334:        /* return */
    jmp %a3@
GETFILEINFO_336:        /* MFS by index: the n-th entry, starting from the last position found (+90, +92) when it helps */
    cmpw %a2@(20),%d1
    jbhi GETFILEINFO_384
    movew %a2@(24),%d5
    movew %a2@(22),%d3
    addw %d3,%d5
    movew %a2@(90),%d7
    jbeq GETFILEINFO_356
    cmpw %d7,%d1
    jbcs GETFILEINFO_356
    movew %a2@(92),%d3
    jbra GETFILEINFO_358
GETFILEINFO_356:        /* from the start */
    moveq #1,%d7
GETFILEINFO_358:        /* next directory block */
    cmpw %d5,%d3
    jbcc GETFILEINFO_384
    movew %d3,%a2@(92)
    movew %d7,%a2@(90)
    jbsr VFILEWRITE_F2
    jbne GETFILEINFO_384
    moveq #0,%d0
GETFILEINFO_36C:        /* count the entries */
    moveq #0,%d6
    tstb %a5@(0x0,%d0:w)
    jbeq GETFILEINFO_380
    cmpw %d7,%d1
    jbeq GETFILEINFO_38A
    addqw #1,%d7
    jbsr FILECREATE_1A8
    jbcs GETFILEINFO_36C
GETFILEINFO_380:        /* next block */
    addqw #1,%d3
    jbra GETFILEINFO_358
GETFILEINFO_384:        /* fnfErr */
    moveq #-43,%d0	/* fnfErr */
    jbra CMDDONE
GETFILEINFO_38A:        /* found: its name, its info */
    lea %a5@(0x0,%d0:w),%a5
    lea %a5@(50),%a3
    movel %a0@(18),%d0
    jbeq GETFILEINFO_3A2
    moveal %d0,%a4
    moveb %a3@,%d0
GETFILEINFO_39C:        /* copy the name */
    moveb %a3@+,%a4@+
    subqb #1,%d0
    jbcc GETFILEINFO_39C
GETFILEINFO_3A2:        /* the entry's fields */
    lea %a0@(30),%a4
    moveq #24,%d0
    lea %a5@,%a3
GETFILEINFO_3AA:        /* copy */
    movew %a3@+,%a4@+
    dbf %d0,GETFILEINFO_3AA
    bclr #4,%a0@(30)
    btst #0,HFSFlags
    jbeq GETFILEINFO_3DA
    movel #2,%a0@(100)
    clrl %a0@(80)
    movel %a0,%sp@-
    lea %a0@(84),%a0
    moveq #3,%d0
GETFILEINFO_3D2:        /* (catalog fields empty on MFS) */
    clrl %a0@+
    dbf %d0,GETFILEINFO_3D2
    moveal %sp@+,%a0
GETFILEINFO_3DA:        /* then the open state */
    jbra GETFILEINFO_1B2

GETFILEINFO_3DE:        /* an H call (trap bit 9)? */
    btst #9,%a0@(6)
    rts

GETFILEINFO_3E6:        /* a2 = the FCB's volume */
    moveal %a1@(0x14,%d1:w),%a2

/* TFSVCBTST: is the volume an HFS volume?. */
TFSVCBTST:              /* (vcbSigWord 'BD': Z set for HFS) */
    cmpiw #16964,%a2@(8)
    rts

TFSVCBTST_8:            /* the new position for a read/write: ioPosMode (+44) 0 at mark, 1 from start, 2 from end, 3 from mark + ioPosOffset; posErr if negative; d2 = bytes left to the EOF, d7 = ioReqCount, d5 = the position */
    clrl %a0@(40)
    moveq #-50,%d0	/* paramErr */
    movel %a0@(36),%d7
    jbmi TFSVCBTST_48
    movel %a0@(46),%d2
    movel %a1@(0x10,%d1:w),%d5
    movel %a1@(0x8,%d1:w),%d4
    moveb %a0@(45),%d0
    roxrb #2,%d0
    jbcc TFSVCBTST_30
    jbmi TFSVCBTST_2C
    movel %d4,%d5
TFSVCBTST_2C:           /* from the mark */
    addl %d2,%d5
    jbra TFSVCBTST_34
TFSVCBTST_30:           /* from the start */
    jbpl TFSVCBTST_34
    movel %d2,%d5
TFSVCBTST_34:           /* negative: posErr */
    jbpl TFSVCBTST_3A
    moveq #-40,%d0	/* posErr */
    jbra TFSVCBTST_48
TFSVCBTST_3A:           /* beyond the EOF: at the EOF (d2 > 0: how far beyond) */
    movel %d5,%d2
    subl %d4,%d2
    jble TFSVCBTST_42
    movel %d4,%d5
TFSVCBTST_42:           /* fcbCrPs = it */
    movel %d5,%a1@(0x10,%d1:w)
    moveq #0,%d0
TFSVCBTST_48:           /* return */
    rts

/* GETFPOS: _GetFPos. */
trap_GetFPos:
GETFPOS:                /* (ioPosMode 0, ioReqCount 0: just the mark) */
    clrb %a0@(45)

/* SETFPOS: _SetFPos. */
trap_SetFPos:
SETFPOS:                /* (ioReqCount 0: only move the mark) */
    clrl %a0@(36)

/* FILEREAD: _Read of a file: through the cache, or directly for big transfers. */
FILEREAD:
    movel 0x7a8,%sp@-	/* through the vector at 0x7A8 (normally VFILEREAD; patchable) */
    rts

/* VFILEREAD: vectored entry: _Read of a file: through the cache, or directly for big transfers. */
trap_VFILEREAD:
VFILEREAD:
    jbsr FSQUEUESYNC_4
    jbsr GETEOF_12
    jbne VFILEREAD_94
    jbsr TFSVCBTST_8
    jbne VFILEREAD_8C
    negl %d2
    jbmi VFILEREAD_8A
    cmpl %d2,%d7
    jble VFILEREAD_1A
    movel %d2,%d7
VFILEREAD_1A:           /* newline mode (ioPosMode high byte bit 7)? byte by byte */
    tstl %d7
    jbeq VFILEREAD_7A
    movew %a0@(44),%d2
    lsrw #8,%d2
    jbcs VFILEREAD_98
    btst #6,%a0@(45)
    jbeq VFILEREAD_46
    moveml %d1/%a1,%fp@-
    movew %d1,%d0
    moveq #0,%d1
    moveal %a2@(84),%a1
    st SysCRefCnt
    jsr %pc@(FLUSHCACHE)
    moveml %fp@+,%d1/%a1
VFILEREAD_46:           /* not cached (ioPosMode bit 6)? flush the file's blocks from the cache first */
    movew %d5,%d2
    andiw #511,%d2
    jbeq VFILEREAD_62
VFILEREAD_4E:           /* a partial block: through the cache */
    jbsr VFILEREAD_DA
    jbne VFILEREAD_7C
    btst #6,%a0@(45)
    sne %d0
    jbsr VFILEWRITE_8A
    jbne VFILEREAD_7C
VFILEREAD_62:           /* whole blocks: read directly into the buffer (CACHERDIP) */
    movel %d7,%d4
    jbeq VFILEREAD_7A
    andiw #-512,%d4
    tstl %d4
    jbeq VFILEREAD_4E
    jsr %pc@(CACHERDIP)
    jbne VFILEREAD_7C
    jbsr VFILEWRITE_80
    jbra VFILEREAD_62
VFILEREAD_7A:           /* no error */
    moveq #0,%d0
VFILEREAD_7C:           /* fewer bytes than asked: eofErr */
    tstw %d0
    jbne VFILEREAD_8C
    movel %a0@(40),%d2
    cmpl %a0@(36),%d2
    jbeq VFILEREAD_8C
VFILEREAD_8A:           /* eofErr */
    moveq #-39,%d0	/* eofErr */
VFILEREAD_8C:           /* the mark (fcbCrPs, ioPosOffset) */
    movel %d5,%a1@(0x10,%d1:w)
    movel %d5,%a0@(46)
VFILEREAD_94:           /* done */
    jbra CMDDONE
VFILEREAD_98:           /* newline mode: copy byte by byte until the newline character (ioPosMode low byte) */
    jbsr VFILEREAD_DA
    jbne VFILEREAD_7C
    movel %d5,%d2
    andiw #511,%d2
    moveal %a0@(32),%a3
    movel %a0@(40),%d4
VFILEREAD_AA:           /* one byte */
    moveb %a5@(0x0,%d2:w),%d0
    moveb %d0,%a3@(0x0,%d4:l)
    addql #1,%a0@(40)
    addql #1,%d4
    addqw #1,%d2
    addql #1,%d5
    cmpb %a0@(44),%d0
    jbne VFILEREAD_C6
    moveq #0,%d0
    jbra VFILEREAD_8C
VFILEREAD_C6:           /* next */
    subql #1,%d7
    jbeq VFILEREAD_7A
    cmpw %d6,%d2
    jbcs VFILEREAD_AA
    jbra VFILEREAD_98

VFILEREAD_D0:           /* a block for writing (not read if it will be wholly overwritten) */
    jbsr VFILEREAD_F2
    cmpl %d3,%d5
    jbcs VFILEREAD_E6
    moveq #4,%d1
    jbra VFILEREAD_E6

VFILEREAD_DA:           /* a block for reading */
    jbsr VFILEREAD_F2
    btst #6,%a0@(45)
    jbeq VFILEREAD_E6
    moveq #1,%d1
VFILEREAD_E6:           /* d2 = the file block (position / 512) */
    moveal %a2@(84),%a1
    movel %d5,%d2
    lsrl #8,%d2
    lsrl #1,%d2
    rts

VFILEREAD_F2:           /* the file block's disk block (VMAPFBLOCK), from the cache (GETBLOCK) */
    moveml %d1-%d2/%a0-%a1,%fp@-
    moveal %sp@+,%a1
    movel %sp@+,%fp@-
    movew %d1,%d0
    moveq #0,%d1
    moveq #2,%d6
    lsll #8,%d6
    jsr %a1@
    addqb #8,%d1
    jsr %pc@(GETBLOCK)
    moveal %a0,%a5
    movel %fp@+,%sp@-
    moveml %fp@+,%d1-%d2/%a0-%a1
    tstw %d0
    rts

/* FILEWRITE: _Write of a file: extend it if needed. */
FILEWRITE:
    movel 0x7ac,%sp@-	/* through the vector at 0x7AC (normally VFILEWRITE; patchable) */
    rts

/* VFILEWRITE: vectored entry: _Write of a file: extend it if needed. */
trap_VFILEWRITE:
VFILEWRITE:
    jbsr FSQUEUESYNC_4
    jbsr VRFNCALL_44
    jbne VFILEWRITE_7C
    jbsr TFSVCBTST_8
    jbne VFILEWRITE_36
    tstl %d2
    jbmi VFILEWRITE_16
    addl %d2,%d5
VFILEWRITE_16:          /* the end of the write: beyond the EOF? */
    movel #511,%d3
    addl %d4,%d3
    andiw #-512,%d3
    movel %d5,%d4
    addl %d7,%d4
    cmpl %a1@(0x8,%d1:w),%d4
    jbls VFILEWRITE_40
    subl %a1@(0xc,%d1:w),%d4
    jbls VFILEWRITE_38
    jbsr VADJEOF_88
VFILEWRITE_36:          /* error */
    jbne VFILEWRITE_76
VFILEWRITE_38:          /* the new EOF */
    movel %d5,%d4
    addl %d7,%d4
    movel %d4,%a1@(0x8,%d1:w)
VFILEWRITE_40:          /* a partial first block through the cache */
    movew %d5,%d0
    andiw #511,%d0
    jbeq VFILEWRITE_56
VFILEWRITE_48:          /* copy into the cached block, mark it dirty */
    jbsr VFILEREAD_D0
    jbne VFILEWRITE_6E
    moveq #1,%d0
    jbsr VFILEWRITE_8A
    jsr %pc@(MARKA5BLOCK)
VFILEWRITE_56:          /* whole blocks directly (CACHEWRIP) */
    movel %d7,%d4
    jbeq VFILEWRITE_6C
    andiw #-512,%d4
    tstl %d4
    jbeq VFILEWRITE_48
    jsr %pc@(CACHEWRIP)
    jbne VFILEWRITE_6E
    jbsr VFILEWRITE_80
    jbra VFILEWRITE_56
VFILEWRITE_6C:          /* no error */
    moveq #0,%d0
VFILEWRITE_6E:          /* the EOF of all paths; the mark */
    jbsr SETEOF_6A
    movel %d5,%a1@(0x10,%d1:w)
VFILEWRITE_76:          /* ioPosOffset */
    movel %a1@(0x10,%d1:w),%a0@(46)
VFILEWRITE_7C:          /* done */
    jbra CMDDONE

VFILEWRITE_80:          /* d6 bytes done: advance the count and the mark */
    subl %d6,%d7
    addl %d6,%a0@(40)
    addl %d6,%d5
    rts

VFILEWRITE_8A:          /* copy between the cached block and the buffer (d0 > 0 write, 0 read, < 0 compare: ioErr if different) */
    movel %d5,%d2
    andiw #511,%d2
    subw %d2,%d6
    cmpl %d6,%d7
    jbcc VFILEWRITE_98
    movel %d7,%d6
VFILEWRITE_98:          /* the buffer position; copy through the vector at 0x4B8 */
    moveal %a0@(32),%a3
    addal %a0@(40),%a3
    jbsr VFILEWRITE_80
    moveml %d1/%a0-%a2,%sp@-
    moveal %a3,%a0
    moveal %a5,%a1
    addaw %d2,%a1
    tstb %d0
    jbgt VFILEWRITE_B4
    jbmi VFILEWRITE_C4
    exg %a0,%a1
VFILEWRITE_B4:          /* copy */
    movel %d6,%d0
    moveal 0x4b8,%a2
    jsr %a2@
VFILEWRITE_BC:          /* no error */
    moveq #0,%d0
VFILEWRITE_BE:          /* return */
    moveml %sp@+,%d1/%a0-%a2
    rts
VFILEWRITE_C4:          /* compare (verify): ioErr if different */
    moveq #-36,%d0	/* ioErr */
    subqw #1,%d6
VFILEWRITE_C8:          /* compare */
    cmpmb %a0@+,%a1@+
    dbne %d6,VFILEWRITE_C8
    jbne VFILEWRITE_BE
    jbra VFILEWRITE_BC

VFILEWRITE_D2:          /* MFS: the first directory block */
    movew %a2@(24),%d0
    movew %a2@(22),%d3
    addw %d3,%d0
    movew %d0,MaxDB
    jbra VFILEWRITE_F2

VFILEWRITE_E2:          /* MFS: the next directory block (dirFulErr past the last, MaxDB) */
    movew CkdDB,%d3
    addqw #1,%d3
    cmpw MaxDB,%d3
    jbcs VFILEWRITE_F2
    moveq #-33,%d0	/* dirFulErr */
    rts

VFILEWRITE_F2:          /* MFS: directory block d3 through the control cache (CkdDB = it) */
    movew %d3,CkdDB
    jbsr VFILEREAD_F2
    moveal SysCtlCPtr,%a1
    jbra VFILEWRITE_110

VFILEWRITE_100:         /* through the volume cache */
    jbsr VFILEREAD_F2
    jbra VFILEWRITE_10C

VFILEWRITE_106:         /* through the volume cache, for writing */
    jbsr VFILEREAD_F2
    moveq #4,%d1
VFILEWRITE_10C:         /* the volume cache */
    moveal SysVolCPtr,%a1
VFILEWRITE_110:         /* d2 = the block, d0 = the vRefNum */
    moveq #0,%d2
    movew %d3,%d2
    movew %a2@(78),%d0
    rts

/* FLUSHFILE: _FlushFile. */
trap_FlushFile:
FLUSHFILE:
    jbsr FSQUEUESYNC_4
    st FlushOnly
    jbra VFILECLOSE_8

/* FILECLOSE: _Close of a file: flush it, update the catalog, free the FCB. */
FILECLOSE:
    movel 0x7a4,%sp@-	/* through the vector at 0x7A4 (normally VFILECLOSE; patchable) */
    rts

/* VFILECLOSE: vectored entry: _Close of a file: flush it, update the catalog, free the FCB. */
trap_VFILECLOSE:
VFILECLOSE:
    jbsr FSQUEUESYNC_4
    clrb FlushOnly
VFILECLOSE_8:           /* the path; an off-line volume is still closed */
    jbsr GETEOF_12
    jbeq VFILECLOSE_14
    cmpiw #-53,%d0
    jbne VFILECLOSE_16
VFILECLOSE_14:          /* close it (VFCLOSE) */
    jbsr VFILECLOSE_1A
VFILECLOSE_16:          /* done */
    jbra CMDDONE

VFILECLOSE_1A:          /* close the path (VFCLOSE) */
    movel 0x6cc,%sp@-	/* through the vector at 0x6CC (normally VFCLOSE; patchable) */
    rts

/*
 VFCLOSE (d1 = FCB offset): close or flush (FlushOnly) a path: a B-tree file is flushed
 or closed through the B-tree code; a file whose FCB is dirty (fcbFlags bit 7) gets its
 physical length trimmed to the clump (TRUNCATEFILE) and its catalog record updated
 (extent record, lengths, modification date; the first block of a resource fork's
 header also copied); the file's cached blocks are flushed; closing frees the FCB.
*/
trap_VFCLOSE:
VFCLOSE:
    movel %sp@+,%fp@-
    moveml %d1-%d3/%a0-%a5,%fp@-
    jbsr TFSVCBTST
    jbne VFCLOSE_176
    tstl %a1@(0x22,%d1:w)
    jbeq VFCLOSE_34
    cmpil #16,%a1@(0x0,%d1:w)
    jbcc VFCLOSE_34
    movew %d1,%d0
    tstb FlushOnly
    jbne VFCLOSE_2C
    jsr %pc@(BTSVCS)
    jbra VFCLOSE_30
VFCLOSE_2C:             /* flush only */
    jsr %pc@(BTFLUSH)
VFCLOSE_30:             /* B-tree error? */
    jbne VFCLOSE_16C
VFCLOSE_34:             /* a mounted volume and a user file (ID >= 16)? dirty? */
    moveq #0,%d0
    tstw %a2@(72)
    jbeq VFCLOSE_152
    cmpil #16,%a1@(0x0,%d1:w)
    jbcs VFCLOSE_152
    bclr #7,%a1@(0x4,%d1:w)
    jbeq VFCLOSE_12A
    jbsr VTSTMOD_4
    jbne VFCLOSE_6E
    movel %a1@(0xc,%d1:w),%d3
    moveq #0,%d2
    jsr %pc@(TRUNCATEFILE)
    jbne VFCLOSE_12C
    bclr #7,%a1@(0x4,%d1:w)
VFCLOSE_6E:             /* the catalog record: the fork's extent record, lengths, modification date */
    movel %a1,%fp@-
    movel %a1@(0x3a,%d1:w),%d0
    lea %a1@(0x3e,%d1:w),%a0
    moveq #0,%d2
    jsr %pc@(CMGETCN)
    moveal %a1,%a5
    moveal %fp@+,%a1
    jbne VFCLOSE_12C
    moveml %a0-%a1,%sp@-
    lea %a1@(0x26,%d1:w),%a0
    lea %a5@(74),%a3
    btst #9,%a1@(0x4,%d1:w)
    jbeq VFCLOSE_9E
    lea %a5@(86),%a3
VFCLOSE_9E:             /* data (+74) or resource (+86) extents */
    moveal %a3,%a1
    moveq #12,%d0
    _BlockMove
    moveml %sp@+,%a0-%a1
    lea %a5@(24),%a3
    jbsr VFCLOSE_1B2
    movel Time,%a5@(48)
    jsr %pc@(CMUPDATECN)
    jbne VFCLOSE_12C
    btst #9,%a1@(0x4,%d1:w)
    jbeq VFCLOSE_12A
    cmpil #128,%a1@(0x8,%d1:w)
    jbcs VFCLOSE_12A
    moveml %d1/%a1,%fp@-
    moveal %a0,%a3
    moveal %a2@(84),%a1
    movew %d1,%d0
    moveq #0,%d1
    moveq #0,%d2
    jsr %pc@(GETBLOCK)
    jbne VFCLOSE_126
    movel %a0,%sp@-
    lea %a0@(48),%a1
    lea %a3@(6),%a0
    moveq #32,%d0
    _BlockMove
    moveq #32,%d0
    addal %d0,%a1
    lea %a5@(2),%a0
    moveq #18,%d0
    _BlockMove
    moveq #18,%d0
    addal %d0,%a1
    lea %a5@(56),%a0
    moveq #16,%d0
    _BlockMove
    moveq #16,%d0
    addal %d0,%a1
    movel %a5@(44),%a1@+
    movel %a5@(26),%a1@+
    movel %a5@(36),%a1@+
    moveal %sp@+,%a0
    moveal %a2@(84),%a1
    moveq #4,%d1
    jsr %pc@(RELBLOCK)
VFCLOSE_126:            /* restore */
    moveml %fp@+,%d1/%a1
VFCLOSE_12A:            /* no error */
    moveq #0,%d0
VFCLOSE_12C:            /* flush the file's blocks from the volume cache (and release them when closing) */
    moveml %d0-%d1/%a1,%fp@-
    movew %d1,%d0
    moveq #0,%d1
    tstb FlushOnly
    jbne VFCLOSE_13C
    moveq #1,%d1
VFCLOSE_13C:            /* flush */
    moveal %a2@(84),%a1
    jsr %pc@(FLUSHCACHE)
    jbsr TFSVCBTST
    jbeq VFCLOSE_14E
    jbsr FILECREATE_15E
VFCLOSE_14E:            /* restore */
    moveml %fp@+,%d0-%d1/%a1
VFCLOSE_152:            /* closing: clear the FCB */
    tstb FlushOnly
    jbne VFCLOSE_16C
    lea %a1@(0x0,%d1:w),%a3
    moveq #0,%d2
    movew FSFCBLen,%d2
    lsrw #1,%d2
    subqw #1,%d2
VFCLOSE_166:            /* clear */
    clrw %a3@+
    dbf %d2,VFCLOSE_166
VFCLOSE_16C:            /* restore, return */
    moveml %fp@+,%d1-%d3/%a0-%a5
    movel %fp@+,%sp@-
    tstw %d0
    rts
VFCLOSE_176:            /* MFS: update the directory entry if dirty */
    bclr #7,%a1@(0x4,%d1:w)
    jbeq VFCLOSE_12A
    movew %a1@(0x1c,%d1:w),%d3
    jbsr VFILEWRITE_F2
    jbne VFCLOSE_12C
    moveq #0,%d0
    movel %a1@(0x0,%d1:w),%d3
VFCLOSE_18E:            /* find the file's entry by number */
    cmpl %a5@(0x12,%d0:w),%d3
    jbeq VFCLOSE_19E
    jbsr FILECREATE_1A8
    jbcs VFCLOSE_18E
    moveq #-43,%d0	/* fnfErr */
    jbra VFCLOSE_12C
VFCLOSE_19E:            /* its fork fields, modification date */
    lea %a5@(0x16,%d0:w),%a3
    jbsr VFCLOSE_1B2
    movel Time,%a5@(0x2e,%d0:w)
    jsr %pc@(MARKA5BLOCK)
    jbra VFCLOSE_12A

VFCLOSE_1B2:            /* copy the FCB's start block, EOF and physical length into the entry's data or resource fields */
    movel %a4,%sp@-
    lea %a1@(0x4,%d1:w),%a4
    movew %a4@+,%d3
    lslw #7,%d3
    jbcc VFCLOSE_1C2
    lea %a3@(10),%a3
VFCLOSE_1C2:            /* copy */
    movew %a4@+,%a3@+
    movel %a4@+,%a3@+
    movel %a4@+,%a3@+
    moveal %sp@+,%a4
    rts

/* GETEOF: _GetEOF. */
trap_GetEOF:
GETEOF:
    jbsr FSQUEUESYNC_4
    jbsr GETEOF_12
    jbne GETEOF_E
    movel %a1@(0x8,%d1:w),%a0@(28)
GETEOF_E:               /* done */
    jbra CMDDONE

GETEOF_12:              /* check the refNum (VRFNCALL) */
    movel 0x790,%sp@-	/* through the vector at 0x790 (normally VRFNCALL; patchable) */
    rts

/* VRFNCALL: check and decode a file refnum. */
trap_VRFNCALL:
VRFNCALL:               /* (ioRefNum valid and open: a1 = FCB buffer, d1 = offset, a2 = its VCB, d2 = file number; the volume on line) */
    moveal FCBSPtr,%a1
    moveq #0,%d1
    movew %a0@(24),%d1
    jbsr VRFNCALL_22
    jbne VRFNCALL_1E
    movel %a1@(0x0,%d1:w),%d2
    moveal %a1@(0x14,%d1:w),%a2
    movel %a2,ReqstVol
    jbsr VFNDFILNAME_124
VRFNCALL_1E:            /* return */
    tstw %d0
    rts

VRFNCALL_22:            /* is d1 a valid, open FCB offset? rfNumErr, fnOpnErr */
    moveq #-51,%d0	/* rfNumErr */
    moveq #0,%d2
    movew %d1,%d2
    divuw FSFCBLen,%d2
    swap %d2
    subqw #2,%d2
    jbne VRFNCALL_40
    cmpw %a1@,%d1
    jbcc VRFNCALL_40
    moveq #-38,%d0	/* fnOpnErr */
    tstl %a1@(0x0,%d1:w)
    jbeq VRFNCALL_40
    moveq #0,%d0
VRFNCALL_40:            /* return */
    tstw %d0
    rts

VRFNCALL_44:            /* may the path be written (VTSTMOD)? */
    movel 0x7c4,%sp@-	/* through the vector at 0x7C4 (normally VTSTMOD; patchable) */
    rts

/* VTSTMOD: is the file modified?. */
trap_VTSTMOD:
VTSTMOD:
    jbsr GETEOF_12
    jbne VTSTMOD_12

VTSTMOD_4:              /* opened for writing (fcbFlags bit 0)? wrPermErr; and the volume (locked) */
    moveq #-61,%d0	/* wrPermErr */
    btst #0,%a1@(0x4,%d1:w)
    jbeq VTSTMOD_12
    jbsr SETVOLINFO_A8
VTSTMOD_12:             /* return */
    tstw %d0
    rts

/* GETFCBINFO: _GetFCBInfo. */
GETFCBINFO:
    jbsr FSQUEUESYNC_4
    jbsr GETFCBINFO_54
    jbne GETFCBINFO_50
    movew %d1,%a0@(24)
    lea %a1@(0x0,%d1:w),%a3
    movel %a0,%sp@-
    lea %a0@(32),%a1
    moveal %a3,%a0
    moveq #20,%d0
    _BlockMove
    moveal %sp@+,%a0
    movew %a2@(78),%a0@(52)
    movel %a3@(30),%a0@(54)
    movel %a3@(58),%a0@(58)
    movel %a0@(18),%d0
    jbeq GETFCBINFO_46
    moveal %d0,%a1
    movel %a0,%sp@-
    lea %a3@(62),%a0
    moveq #1,%d0
    addb %a0@,%d0
    _BlockMove
    moveal %sp@+,%a0
GETFCBINFO_46:          /* ReqstVol; an external file system's? */
    movel %a2,ReqstVol
    movel %a3,%d1
    jbsr FLUSHVOL_3C
GETFCBINFO_50:          /* done */
    jbra CMDDONE

GETFCBINFO_54:          /* find the FCB: by ioRefNum, or ioFCBIndx (+28) the n-th open file (of volume ioVRefNum if given) */
    moveal FCBSPtr,%a1
    movew %a0@(24),%d1
    movew %a0@(28),%d0
    jbeq GETFCBINFO_AC
    moveq #0,%d2
    movew %a0@(22),%d2
    jbeq GETFCBINFO_78
    movew %d2,%d0
    jbsr VDTRMV3_E
    jbne GETFCBINFO_B4
    movel %a2,%d2
    movew %a0@(28),%d0
GETFCBINFO_78:          /* by index */
    jbsr GETWDINFO_3A8
GETFCBINFO_7C:          /* next FCB in use (user files only on HFS) */
    movel %a1@(0x0,%d1:w),%d3
    jbeq GETFCBINFO_A2
    moveal %a1@(0x14,%d1:w),%a2
    jbsr TFSVCBTST
    jbne GETFCBINFO_94
    cmpil #16,%d3
    jbcs GETFCBINFO_A2
GETFCBINFO_94:          /* of the volume asked? */
    tstl %d2
    jbeq GETFCBINFO_9E
    cmpl %a1@(0x14,%d1:w),%d2
    jbne GETFCBINFO_A2
GETFCBINFO_9E:          /* the n-th? */
    subqw #1,%d0
    jbeq GETFCBINFO_AC
GETFCBINFO_A2:          /* next; none: fnOpnErr */
    jbsr GETWDINFO_3B0
    jbcs GETFCBINFO_7C
    moveq #-38,%d0	/* fnOpnErr */
    jbra GETFCBINFO_B4
GETFCBINFO_AC:          /* check it */
    jbsr VRFNCALL_22
    moveal %a1@(0x14,%d1:w),%a2
GETFCBINFO_B4:          /* return */
    tstw %d0
    rts
GETFCBINFO_B8:          /* _HFSDispatch 16/17: just check the refNum */
    jbsr FSQUEUESYNC_4
    jbsr GETEOF_12
    jbne GETFCBINFO_C4
    moveq #0,%d0
GETFCBINFO_C4:          /* done */
    jbra CMDDONE

GETFCBINFO_C8:          /* Allocate on HFS: extend the file (AllocContig for H calls: contiguous) */
    moveq #0,%d0
    jbsr TFSVCBTST
    jbne VLG2PHYS_B6
    jbsr GETFILEINFO_3DE
    jbeq GETFCBINFO_DA
    moveq #2,%d0
GETFCBINFO_DA:          /* extend */
    jbra VADJEOF_92

/* FILEALLOC: _Allocate / _AllocContig. */
trap_Allocate:
FILEALLOC:
    jbsr FSQUEUESYNC_4
    jbsr VRFNCALL_44
    jbne FILEALLOC_2C
    moveq #0,%d6
    movel %a0@(36),%d4	/* ioReqCount */
    jbeq FILEALLOC_1C
    tstw %a2@(42)
    jbeq FILEALLOC_1C
    jbsr GETFCBINFO_C8
    jbne FILEALLOC_2C
FILEALLOC_1C:           /* ioActCount = bytes added; fewer than asked: dskFulErr */
    movel %d6,%a0@(40)
    jbsr SETEOF_6A
    moveq #-34,%d0	/* dskFulErr */
    cmpl %a0@(36),%d6
    jbcs FILEALLOC_2C
    moveq #0,%d0
FILEALLOC_2C:           /* done */
    jbra CMDDONE

/* SETEOF: _SetEOF: extend or truncate. */
trap_SetEOF:
SETEOF:
    jbsr FSQUEUESYNC_4
    jbsr VRFNCALL_44
    jbne SETEOF_36
    movel %a0@(28),%d7	/* ioMisc: the new EOF */
    movel %d7,%d4
    subl %a1@(0xc,%d1:w),%d4
    jbhi SETEOF_62
    jbcs SETEOF_3A
SETEOF_18:              /* the new EOF on all paths (positions past it moved back) */
    jbsr GETFILEINFO_3DE
    jbeq SETEOF_24
    cmpl %a1@(0x8,%d1:w),%d7
    jbcc SETEOF_32
SETEOF_24:              /* the mark too */
    movel %d7,%a1@(0x8,%d1:w)
    cmpl %a1@(0x10,%d1:w),%d7
    jbcc SETEOF_32
    movel %d7,%a1@(0x10,%d1:w)
SETEOF_32:              /* no error */
    jbsr SETEOF_6A
    moveq #0,%d0
SETEOF_36:              /* done */
    jbra CMDDONE
SETEOF_3A:              /* smaller: release the blocks past it (TRUNCATEFILE); MFS: VADJEOF_48 */
    jbsr GETFILEINFO_3E6
    jbne VADJEOF_48
    movel %d7,%d4
    movel %d4,%d3
    moveq #1,%d2
    jsr %pc@(TRUNCATEFILE)
    jbne SETEOF_36
SETEOF_4C:              /* drop the cached blocks beyond */
    moveml %d0-%d2,%fp@-
    movew %d1,%d0
    movel %a1@(0xc,%d1:w),%d1
    moveq #-1,%d2
    jsr %pc@(TRASHBLOCKS)
    moveml %fp@+,%d0-%d2
    jbra SETEOF_18
SETEOF_62:              /* larger than the physical length: extend */
    jsr %pc@(VADJEOF_88)
    jbne SETEOF_36
    jbra SETEOF_18

SETEOF_6A:              /* copy the FCB's lengths to every path of the fork (VADJEOF) */
    movel 0x794,%sp@-	/* through the vector at 0x794 (normally VADJEOF; patchable) */
    rts

/*
 VADJEOF: the FCB's fork fields (start block, EOF, physical length, extents) copied into
 every other open path of the same fork; this FCB marked dirty.
*/
trap_VADJEOF:
VADJEOF:
    moveml %d0-%d6/%a0-%a5,%sp@-
    addaw %d1,%a1
    movel %a1@+,%d2
    bset #7,%a1@
    movew %a1@,%d0
    moveml %a1@+,%d3-%d6/%a2
    movew %d0,%d6
    lea %a1@(14),%a1
    moveml %a1@+,%a3-%a5
    jbsr GETWDINFO_3B8
    jbne VADJEOF_42
VADJEOF_22:             /* another path of the same fork? */
    lea %a1@(0x4,%d1:w),%a0
    movew %a0@+,%d0
    eorw %d6,%d0
    lslw #7,%d0
    jbcs VADJEOF_3C
    movew %d3,%a0@+
    movel %d4,%a0@+
    movel %d5,%a0@+
    lea %a0@(34),%a0
    moveml %a3-%a5,%a0@-
VADJEOF_3C:             /* next */
    jbsr GETWDINFO_3C6
    jbeq VADJEOF_22
VADJEOF_42:             /* restore, return */
    moveml %sp@+,%d0-%d6/%a0-%a5
    rts
VADJEOF_48:             /* MFS: shorten the block chain to the new length */
    moveq #0,%d6
    movew %a1@(0x6,%d1:w),%d3
    movel %a2@(28),%d2
    movel %d7,%d4
    jbne VADJEOF_5E
    clrw %a1@(0x6,%d1:w)
    jbra VADJEOF_7A
VADJEOF_5C:             /* next block of the chain */
    movew %d5,%d3
VADJEOF_5E:             /* count */
    addl %d2,%d6
    jbsr VLG2PHYS_88
    subl %d2,%d4
    jbhi VADJEOF_5C
    cmpl %a1@(0xc,%d1:w),%d6
    jbcc SETEOF_18
    movew %d5,%sp@-
    moveq #1,%d5
    jbsr VLG2PHYS_198
    movew %sp@+,%d3
VADJEOF_7A:             /* free the rest of the chain */
    jbsr VLG2PHYS_1D0
    movel %d6,%a1@(0xc,%d1:w)
    movel %d6,%d4
    jbra SETEOF_4C

VADJEOF_88:             /* extend the file by d4 bytes (EXTENDFILE) */
    jbsr GETFILEINFO_3E6
    jbne VLG2PHYS_B4
    moveq #1,%d0
VADJEOF_92:             /* extend */
    movel %sp@+,%fp@-
    movel %d3,%fp@-
    movew %d0,%d3
    jsr %pc@(EXTENDFILE)
    movel %fp@+,%d3
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* LG2PHYS: logical file position to a physical disk block. */
LG2PHYS:
    movel 0x6fc,%sp@-	/* through the vector at 0x6FC (normally VLG2PHYS; patchable) */
    rts

/* VLG2PHYS: vectored entry: logical file position to a physical disk block. */
trap_VLG2PHYS:
VLG2PHYS:
    jbsr GETFILEINFO_3E6
    jbne VLG2PHYS_A
    jmp %pc@(MAPFBLOCK)
VLG2PHYS_A:             /* MFS: follow the file's block chain to the block of position d5 */
    moveml %d1-%d2/%d4-%d5/%d7,%sp@-
    movel %a2@(28),%d7
    movew %a1@(0x6,%d1:w),%d3
    addl %d5,%d4
    subql #1,%d4
    moveq #9,%d1
    moveq #0,%d6
    lsrl %d1,%d4
    lsrl %d1,%d7
    movel %d5,%d2
    lsrl %d1,%d2
    jbra VLG2PHYS_30
VLG2PHYS_28:            /* next block of the chain */
    jbsr VLG2PHYS_88
    movew %d5,%d3
    subw %d7,%d4
    subw %d7,%d2
VLG2PHYS_30:            /* the block containing the position? */
    cmpw %d7,%d2
    jbcc VLG2PHYS_28
    movew %d3,%d0
    subqw #2,%d0
    muluw %d7,%d0
    addw %d2,%d0
    addw %a2@(36),%d0
    movel %d0,%sp@-
VLG2PHYS_42:            /* how many blocks follow contiguously */
    movew %d7,%d0
    subw %d2,%d0
    addw %d0,%d6
    subw %d0,%d4
    jbmi VLG2PHYS_56
    jbsr VLG2PHYS_88
    moveq #0,%d2
    addqw #1,%d3
    cmpw %d3,%d5
    jbeq VLG2PHYS_42
VLG2PHYS_56:            /* d3 = the disk block, d6 = the contiguous bytes; the block must be inside the volume (else 16) */
    movel %sp@+,%d3
    movew %d3,%d0
    addw %d6,%d0
    movew %a2@(36),%d4
    muluw %a2@(26),%d7
    addw %d4,%d7
    cmpw %d7,%d0
    jbhi VLG2PHYS_7E
    cmpw %d4,%d3
    jbcs VLG2PHYS_7E
    asll %d1,%d6
    moveml %sp@+,%d1-%d2/%d4-%d5/%d7
    cmpl %d4,%d6
    jbls VLG2PHYS_7A
    movel %d4,%d6
VLG2PHYS_7A:            /* no error */
    moveq #0,%d0
    rts
VLG2PHYS_7E:            /* outside the volume: 16 */
    moveml %sp@+,%d1-%d2/%d4-%d5/%d7
    movew #16,%d0
    rts

VLG2PHYS_88:            /* MFS: d5 = the block map entry of allocation block d3 (12 bits: next block of the file, 1 = last, 0 = free) */
    moveml %d0/%a2,%sp@-
    moveal %a2@(80),%a2
    movew %d3,%d0
    subqw #2,%d0
    muluw #12,%d0
    rorl #4,%d0
    aslw #1,%d0
    movel %a2@(0x0,%d0:w),%d5
    clrw %d0
    roll #4,%d0
    addiw #12,%d0
    roll %d0,%d5
    andiw #4095,%d5
    moveml %sp@+,%d0/%a2
    rts
VLG2PHYS_B4:            /* MFS: extend the file to d4 bytes (allocate and chain blocks); dskFulErr if not enough */
    movel %d4,%d0
VLG2PHYS_B6:            /* (d0 = bytes needed) */
    moveml %d1-%d5/%d7-%a3,%sp@-
    movel %a2@(28),%d7
    movel %d7,%d6
    muluw %a2@(42),%d6
    cmpl %d6,%d4
    jbls VLG2PHYS_CA
    movel %d6,%d4
VLG2PHYS_CA:            /* enough free space? */
    cmpl %d0,%d4
    jbcc VLG2PHYS_D6
    moveq #-34,%d0	/* dskFulErr */
VLG2PHYS_D0:            /* restore, return */
    moveml %sp@+,%d1-%d5/%d7-%a3
    rts
VLG2PHYS_D6:            /* an empty file: its first block from the largest free run */
    movel %a1@(0xc,%d1:w),%d2
    moveq #0,%d6
    movew %a1@(0x6,%d1:w),%d3
    jbne VLG2PHYS_F4
    jbsr VLG2PHYS_136
    movew %d5,%a1@(0x6,%d1:w)
    movew %d5,%d3
    moveq #1,%d5
    jbsr VLG2PHYS_198
    jbra VLG2PHYS_11A
VLG2PHYS_F2:            /* find the last block of the chain */
    movew %d5,%d3
VLG2PHYS_F4:            /* next */
    jbsr VLG2PHYS_88
    cmpiw #1,%d5
    jbne VLG2PHYS_F2
VLG2PHYS_FC:            /* the next block free? take it, else the largest free run */
    cmpw %a2@(26),%d3
    jbhi VLG2PHYS_132
    addqw #1,%d3
    jbsr VLG2PHYS_88
    subqw #1,%d3
    tstw %d5
    jbne VLG2PHYS_132
    movew %d3,%d5
    addqw #1,%d5
VLG2PHYS_110:           /* chain it, mark it last */
    jbsr VLG2PHYS_198
    movew %d5,%d3
    moveq #1,%d5
    jbsr VLG2PHYS_198
VLG2PHYS_11A:           /* one more block; enough? */
    addl %d7,%d6
    addl %d7,%d2
    subqw #1,%a2@(42)
    cmpl %d6,%d4
    jbhi VLG2PHYS_FC
    movel %d2,%a1@(0xc,%d1:w)
    jbsr MARKVCB
    moveq #0,%d0
    jbra VLG2PHYS_D0
VLG2PHYS_132:           /* not contiguous: the largest free run */
    jbsr VLG2PHYS_136
    jbra VLG2PHYS_110

VLG2PHYS_136:           /* MFS: d5 = the start of the largest run of free blocks (or the first big enough) */
    moveml %d0-%d4/%d6/%a1/%a3,%sp@-
    subl %d6,%d4
    cmpl %a2@(32),%d4
    jbcc VLG2PHYS_146
    movel %a2@(32),%d4
VLG2PHYS_146:           /* walk the map (12-bit entries) */
    moveal %a2@(80),%a1
    moveaw %a2@(26),%a3
    addqw #1,%a3
    moveq #0,%d5
    moveq #2,%d0
    moveq #2,%d2
    moveq #0,%d3
    moveq #0,%d6
    clrw %sp@-
VLG2PHYS_15C:           /* next entry */
    moveb %a1@+,%d1
    lslw #8,%d1
    bchg #0,%d5
    jbne VLG2PHYS_16C
    moveb %a1@,%d1
    lsrw #4,%d1
    jbra VLG2PHYS_172
VLG2PHYS_16C:           /* odd entry */
    moveb %a1@+,%d1
    andiw #4095,%d1
VLG2PHYS_172:           /* free: add to the run */
    jbne VLG2PHYS_186
    addl %d7,%d3
    cmpl %d6,%d3
    jbls VLG2PHYS_182
    movel %d3,%d6
    movew %d2,%sp@
    cmpl %d4,%d3
    jbcc VLG2PHYS_190
VLG2PHYS_182:           /* next */
    addqw #1,%d0
    jbra VLG2PHYS_18C
VLG2PHYS_186:           /* used: a new run starts after it */
    addqw #1,%d0
    movew %d0,%d2
    moveq #0,%d3
VLG2PHYS_18C:           /* to the last block */
    cmpw %a3,%d0
    jbls VLG2PHYS_15C
VLG2PHYS_190:           /* return */
    movew %sp@+,%d5
    moveml %sp@+,%d0-%d4/%d6/%a1/%a3
    rts

VLG2PHYS_198:           /* MFS: set the map entry of block d3 to d5 */
    moveml %d0/%d6/%a2,%sp@-
    moveal %a2@(80),%a2
    movew %d3,%d0
    subqw #2,%d0
    muluw #12,%d0
    rorl #4,%d0
    aslw #1,%d0
    movel %a2@(0x0,%d0:w),%d6
    swap %d0
    lsrw #8,%d0
    lsrw #4,%d0
    addiw #12,%d0
    roll %d0,%d6
    andiw #-4096,%d6
    orw %d5,%d6
    rorl %d0,%d6
    swap %d0
    movel %d6,%a2@(0x0,%d0:w)
    moveml %sp@+,%d0/%d6/%a2
    rts

VLG2PHYS_1D0:           /* MFS: free the chain starting at block d3 */
    tstw %d3
    jbeq VLG2PHYS_1EE
VLG2PHYS_1D4:           /* free it, one more free block, follow the chain */
    jbsr VLG2PHYS_88
    movew %d5,%sp@-
    clrw %d5
    jbsr VLG2PHYS_198
    addqw #1,%a2@(42)
    movew %sp@+,%d3
    cmpiw #1,%d3
    jbne VLG2PHYS_1D4
    jbsr MARKVCB
VLG2PHYS_1EE:           /* return */
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40812104

/* VSM: Volume Space Manager. */

/*
 VSM, the Volume Space Manager: allocation blocks in the HFS volume bitmap (one bit
 per block, read through the bitmap cache). VBLKALLOC (d2 = first block wanted, 0:
 vcbAllocPtr; d3 bit 0 = contiguous; d4 = bytes): out d2 = the first block, d3 =
 the count (dskFulErr if none). VBLKDEALLOC (d2, d3): free them. BLKCHK (a0 = extent
 record): mark its blocks allocated (d0 = -1 if some were not). UPDATEFREE: recount
 vcbFreeBks. VREADBM: the bitmap long holding block d2.
*/
VSM:
BLKALLOC:
    movel 0x77c,%sp@-	/* through the vector at 0x77C (normally VBLKALLOC; patchable) */
    rts

/* VBLKALLOC: vectored entry: allocate blocks in the volume bitmap. */
trap_VBLKALLOC:
VBLKALLOC:
    movel %sp@+,%fp@-
    moveml %d1/%d4-%a1,%fp@-
    tstw %a2@(42)
    jbeq VBLKALLOC_14E
    andiw #1,%d3
    tstw %d2
    jbne VBLKALLOC_1E
    movew %a2@(24),%d2
    bset #7,%d3
VBLKALLOC_1E:           /* d3 high word: where the search started */
    swap %d3
    movew %d2,%d3
    swap %d3
    bclr #15,%d3
VBLKALLOC_28:           /* the bitmap at d2 */
    jbsr UPDATEFREE_2E
    tstw %d1
    jbmi VBLKALLOC_144
    moveaw %a2@(26),%a1
VBLKALLOC_36:           /* past the last block: wrap to block 0 once */
    cmpw %a1,%d2
    jbcs VBLKALLOC_4E
    roll %d1,%d0
    movel %d0,%a0@(0x0,%d6:w)
    clrw %d2
    jbsr UPDATEFREE_2E
    bset #15,%d3
    jbne VBLKALLOC_14E
VBLKALLOC_4E:           /* a free block (bit 31 clear)? else skip the used ones */
    tstw %d1
    jbmi VBLKALLOC_144
    tstl %d0
    jbpl VBLKALLOC_5E
    jbsr VREADBM_3C
    jbra VBLKALLOC_36
VBLKALLOC_5E:           /* contiguous: is the free run long enough (in clumps)? */
    subaw %d2,%a1
    btst #0,%d3
    jbeq VBLKALLOC_DC
    movel %d4,%fp@-
    moveml %d0-%d1,%fp@-
    movel %d4,%d0
    movew %a2@(30),%d1
    jsr %pc@(DIVUP)
    movel %d0,%d4
    moveml %fp@+,%d0-%d1
    clrw %d7
VBLKALLOC_7E:           /* count free blocks */
    cmpw %d7,%d4
    jbls VBLKALLOC_CA
    cmpw %a1,%d7
    jbeq VBLKALLOC_98
    tstl %d0
    jbmi VBLKALLOC_98
    addqw #1,%d7
    jbsr VREADBM_2E
    tstw %d1
    jbmi VBLKALLOC_144
    jbra VBLKALLOC_7E
VBLKALLOC_98:           /* too short: search on from after it */
    movel %fp@+,%d4
    addw %d7,%d2
    cmpw %a1,%d7
    jbcs VBLKALLOC_AC
    btst #15,%d3
    jbne VBLKALLOC_C0
    bset #15,%d3
    clrw %d2
VBLKALLOC_AC:           /* wrapped past the start: none */
    btst #15,%d3
    jbeq VBLKALLOC_28
    swap %d3
    cmpw %d2,%d3
    jbls VBLKALLOC_C0
    swap %d3
    jbra VBLKALLOC_28
VBLKALLOC_C0:           /* none: write the bitmap long back, dskFulErr */
    roll %d1,%d0
    movel %d0,%a0@(0x0,%d6:w)
    jbra VBLKALLOC_14E
VBLKALLOC_CA:           /* found: back to its start */
    movel %fp@+,%d4
    roll %d1,%d0
    movel %d0,%a0@(0x0,%d6:w)
    jbsr UPDATEFREE_2E
    tstw %d1
    bmiw VBLKALLOC_144
VBLKALLOC_DC:           /* allocate up to the bytes asked (in clumps): set the bits */
    moveml %d0-%d1,%fp@-
    movel %d4,%d0
    movel %a3@(30),%d1
    jsr %pc@(ROUNDALLOC)
    movel %d0,%d4
    moveml %fp@+,%d0-%d1
    moveq #0,%d7
VBLKALLOC_F2:           /* next block: free, still wanted? take it */
    tstw %d4
    jbeq VBLKALLOC_122
    cmpw %a1,%d7
    jbcc VBLKALLOC_122
    tstl %d0
    jbmi VBLKALLOC_122
    tstw %a2@(42)
    jbeq VBLKALLOC_122
    subqw #1,%a2@(42)
    jsr %pc@(MARKVCB)
    bset #31,%d0
    addqw #1,%d7
    subqw #1,%d4
    jsr %pc@(MARKBLOCK)
    jbsr VREADBM_2E
    tstw %d1
    jbge VBLKALLOC_F2
    jbra VBLKALLOC_144
VBLKALLOC_122:          /* the next allocation starts after this one (vcbAllocPtr), if from the default */
    btst #7,%d3
    jbeq VBLKALLOC_136
    movew %d2,%d4
    cmpw %a2@(26),%d4
    jbcs VBLKALLOC_132
    clrw %d4
VBLKALLOC_132:          /* vcbAllocPtr */
    movew %d4,%a2@(24)
VBLKALLOC_136:          /* write the bitmap long back, d3 = the count */
    roll %d1,%d0
    movel %d0,%a0@(0x0,%d6:w)
    jsr %pc@(MARKBLOCK)
    movel %d7,%d3
    moveq #0,%d0
VBLKALLOC_144:          /* restore, return */
    moveml %fp@+,%d1/%d4-%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts
VBLKALLOC_14E:          /* dskFulErr, none */
    moveq #0,%d3
    moveq #-34,%d0	/* dskFulErr */
    jbra VBLKALLOC_144

/* BLKDEALLOC: free blocks. */
BLKDEALLOC:
    movel 0x780,%sp@-	/* through the vector at 0x780 (normally VBLKDEALLOC; patchable) */
    rts

/* VBLKDEALLOC: vectored entry: free blocks. */
trap_VBLKDEALLOC:
VBLKDEALLOC:
    movel %sp@+,%fp@-
    moveml %d1-%d6/%a0,%fp@-
    moveq #0,%d0
    tstw %d3
    jbeq VBLKDEALLOC_36
    jbsr UPDATEFREE_2E
VBLKDEALLOC_10:         /* clear the bit of each block, one more free */
    tstw %d1
    jbmi VBLKDEALLOC_36
    bclr #31,%d0
    jsr %pc@(MARKBLOCK)
    addqw #1,%a2@(42)
    jsr %pc@(MARKVCB)
    subqw #1,%d3
    jbeq VBLKDEALLOC_2E
    jbsr VREADBM_2E
    jbra VBLKDEALLOC_10
VBLKDEALLOC_2E:         /* write the long back */
    roll %d1,%d0
    movel %d0,%a0@(0x0,%d6:w)
    moveq #0,%d0
VBLKDEALLOC_36:         /* restore, return */
    moveml %fp@+,%d1-%d6/%a0
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* BLKCHK: check that blocks are allocated. */
BLKCHK:
    movel %sp@+,%fp@-
    moveml %d1-%d7/%a1,%fp@-
    moveal %a0,%a1
    moveq #0,%d3
    moveq #0,%d7
BLKCHK_C:               /* the extent record's three extents */
    movew %a1@(0x0,%d7:w),%d2
    moveq #0,%d4
    movew %a1@(0x2,%d7:w),%d4
    jbeq BLKCHK_4E
    jbsr UPDATEFREE_2E
    jbra BLKCHK_38
BLKCHK_1C:              /* each block: set its bit (d3 = -1 if it was clear) */
    bset #31,%d0
    jbne BLKCHK_28
    moveq #-1,%d3
    jsr %pc@(MARKBLOCK)
BLKCHK_28:              /* next bit */
    addqw #1,%d2
    roll #1,%d0
    subqw #1,%d1
    jbgt BLKCHK_38
    tstw %d4
    jbeq BLKCHK_42
    jbsr VREADBM_56
BLKCHK_38:              /* count down */
    tstw %d1
    jbmi BLKCHK_50
    dbf %d4,BLKCHK_1C
    roll %d1,%d0
BLKCHK_42:              /* write back; next extent */
    movel %d0,%a0@(0x0,%d6:w)
    addqw #4,%d7
    cmpiw #12,%d7
    jbcs BLKCHK_C
BLKCHK_4E:              /* d0 = -1 if anything was fixed */
    movel %d3,%d0
BLKCHK_50:              /* restore, return */
    moveml %fp@+,%d1-%d7/%a1
    movel %fp@+,%sp@-
    tstl %d0
    rts

/* UPDATEFREE: recount the free blocks. */
UPDATEFREE:
    movel %sp@+,%fp@-
    moveml %d0-%d6/%a0-%a1,%fp@-
    moveq #0,%d4
    moveq #0,%d2
    jbsr UPDATEFREE_2E
    movew %a2@(26),%d2
UPDATEFREE_10:          /* count the clear bits */
    tstw %d1
    jbmi UPDATEFREE_26
    tstl %d0
    jbmi UPDATEFREE_1A
    addqw #1,%d4
UPDATEFREE_1A:          /* next block */
    subqw #1,%d2
    jbeq UPDATEFREE_22
    jbsr VREADBM_2E
    jbra UPDATEFREE_10
UPDATEFREE_22:          /* vcbFreeBks = the count */
    movew %d4,%a2@(42)
UPDATEFREE_26:          /* restore, return */
    moveml %fp@+,%d0-%d6/%a0-%a1
    movel %fp@+,%sp@-
    rts

UPDATEFREE_2E:          /* the bitmap at block d2 (VREADBM) */
    movel 0x7d8,%sp@-	/* through the vector at 0x7D8 (normally VREADBM; patchable) */
    rts

/* VREADBM: read a block of the volume bitmap. */
trap_VREADBM:
VREADBM:                /* d5 = the bitmap block, d6 = the long in it, d1 = bits left in the long; d0 = the long rotated so that block d2's bit is bit 31 (d1 = -1 on a read error) */
    movel %sp@+,%fp@-
    movew %d2,%d5
    lsrw #8,%d5
    lsrw #4,%d5
    movew %d2,%d6
    andiw #4064,%d6
    lsrw #3,%d6
    movew %d2,%d1
    andiw #31,%d1
    jbsr VREADBM_7A
    jbeq VREADBM_1E
    moveq #-1,%d1
    jbra VREADBM_2A
VREADBM_1E:             /* rotate */
    movel %a0@(0x0,%d6:w),%d0
    roll %d1,%d0
    negw %d1
    addiw #32,%d1
VREADBM_2A:             /* return */
    movel %fp@+,%sp@-
    rts

VREADBM_2E:             /* next bit (the next long when needed) */
    movel %sp@+,%fp@-
    roll #1,%d0
    subqw #1,%d1
    jbne VREADBM_38
    jbsr VREADBM_56
VREADBM_38:             /* return */
    movel %fp@+,%sp@-
    rts

VREADBM_3C:             /* skip allocated blocks quickly (whole longs of ones) */
    movel %sp@+,%fp@-
    addqw #1,%d2
    jbsr VREADBM_2E
VREADBM_42:             /* a full long: next one */
    cmpl MinusOne,%d0
    jbne VREADBM_38
    addw %d1,%d2
    cmpw %a1,%d2
    jbcc VREADBM_52
    jbsr VREADBM_56
    jbra VREADBM_42
VREADBM_52:             /* back to the current long */
    subw %d1,%d2
    jbra VREADBM_38

VREADBM_56:             /* write the long back, read the next (the next bitmap block when needed) */
    movel %sp@+,%fp@-
    movel %d0,%a0@(0x0,%d6:w)
    addqw #4,%d6
    cmpiw #512,%d6
    jbcs VREADBM_70
    addqw #1,%d5
    jbsr VREADBM_7A
    jbeq VREADBM_6E
    moveq #-1,%d1
    jbra VREADBM_76
VREADBM_6E:             /* start of the block */
    clrw %d6
VREADBM_70:             /* 32 bits */
    movel %a0@(0x0,%d6:w),%d0
    moveq #32,%d1
VREADBM_76:             /* return */
    movel %fp@+,%sp@-
    rts

VREADBM_7A:             /* read bitmap block d5 (vcbVBMSt + d5) through the bitmap cache */
    movel %sp@+,%fp@-
    moveml %d1-%d2/%a1-%a2,%fp@-
    movew %a2@(78),%d0
    moveq #0,%d2
    movew %a2@(22),%d2
    addw %d5,%d2
    moveal %a2@(80),%a1
    moveq #8,%d1
    jsr %pc@(GETBLOCK)
    moveml %fp@+,%d1-%d2/%a1-%a2
    movel %fp@+,%sp@-
    tstw %d0
    rts
    .short  0x0000	| 408123DE

/* FXM: File Extents Manager. */

/*
 FXM, the File Extents Manager: a file's allocation blocks are recorded in extent
 records of three (start, count) pairs: the first in the catalog record and the
 FCB, the rest in the extents B-tree, keyed by fork (0 data, 0xFF resource), file
 ID and the file block they start at. DEALLOCFILE frees all of a file's extents,
 EXTENDFILE adds blocks, MAPFBLOCK maps a file position to disk blocks, TRUNCATEFILE
 releases blocks past the EOF.
*/
FXM:
DEALLOCFILE:
    movel 0x764,%sp@-	/* through the vector at 0x764 (normally VDEALLOCFILE; patchable) */
    rts

/* VDEALLOCFILE: vectored entry: free all the extents of a file. */
trap_VDEALLOCFILE:
VDEALLOCFILE:
    movel %sp@+,%fp@-
    moveml %d1-%a1/%a3-%a4,%fp@-
    jbsr VTRUNCATEFILE_12A
    moveal %a0,%a3
    movel %d0,%d7
    clrb %d6
VDEALLOCFILE_10:        /* the file's catalog record (a file: 2) */
    clrw %d4
    moveal %a3,%a0
    movel %d7,%d0
    moveq #0,%d2
    jsr %pc@(CMGETCN)
    jbne VDEALLOCFILE_C0
    cmpib #2,%a1@
    jbeq VDEALLOCFILE_2C
    moveq #48,%d0
    jbne VDEALLOCFILE_C0
VDEALLOCFILE_2C:        /* its first extent record (data, then resource) */
    movel %a1@(20),%d5
    lea %a4@(2),%a0
    clrw %a0@(6)
    tstb %d6
    jbne VDEALLOCFILE_42
    lea %a1@(74),%a1
    jbra VDEALLOCFILE_70
VDEALLOCFILE_42:        /* resource fork */
    lea %a1@(86),%a1
    jbra VDEALLOCFILE_70
VDEALLOCFILE_48:        /* the next extent record in the extents B-tree (key: 7 bytes, fork, file ID, start block) */
    lea %a4@(2),%a0
    moveb #7,%a0@
    moveb %d6,%a0@(1)
    movel %d5,%a0@(2)
    movew %d4,%a0@(6)
    movew %a2@(164),%d0
    moveq #0,%d2
    jsr %pc@(BTSEARCH)
    jbeq VDEALLOCFILE_70
    cmpiw #32,%d0
    jbeq VDEALLOCFILE_B4
    jbra VDEALLOCFILE_C0
VDEALLOCFILE_70:        /* copy the record */
    lea %a4@(10),%a0
    moveq #2,%d0
VDEALLOCFILE_76:        /* copy */
    movel %a1@+,%a0@+
    dbf %d0,VDEALLOCFILE_76
    lea %a4@(10),%a1
    clrw %d1
VDEALLOCFILE_82:        /* free each extent */
    movew %a1@(0x0,%d1:w),%d2
    movew %a1@(0x2,%d1:w),%d3
    jbeq VDEALLOCFILE_9C
    jsr %pc@(BLKDEALLOC)
    jbne VDEALLOCFILE_C0
    addw %d3,%d4
    addqw #4,%d1
    cmpiw #8,%d1
    jble VDEALLOCFILE_82
VDEALLOCFILE_9C:        /* delete the B-tree record (not the catalog's) */
    lea %a4@(2),%a0
    tstw %a0@(6)
    jbeq VDEALLOCFILE_B0
    movew %a2@(164),%d0
    jsr %pc@(BTDELETE)
    jbne VDEALLOCFILE_C0
VDEALLOCFILE_B0:        /* a full record: there may be more */
    tstw %d3
    jbne VDEALLOCFILE_48
VDEALLOCFILE_B4:        /* then the other fork */
    notb %d6
    jbne VDEALLOCFILE_10
    clrw %d0
    jbsr VTRUNCATEFILE_134
VDEALLOCFILE_C0:        /* return */
    lea %fp@(22),%fp
    moveml %fp@+,%d1-%a1/%a3-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* EXTENDFILE: add extents to a file. */
EXTENDFILE:
    movel 0x768,%sp@-	/* through the vector at 0x768 (normally VEXTENDFILE; patchable) */
    rts

/* VEXTENDFILE: vectored entry: add extents to a file. */
trap_VEXTENDFILE:
VEXTENDFILE:            /* (d4 = bytes to add; d3 bit 0 all or nothing, bit 1 contiguous) */
    movel %sp@+,%fp@-
    moveml %d1-%d5/%d7-%a4,%fp@-
    jbsr VTRUNCATEFILE_12A
    lea %a1@(0x0,%d1:w),%a3
    movel %a3@(12),%fp@-
    btst #0,%d3
    jbeq VEXTENDFILE_2A
    movew %a2@(42),%d0
    muluw %a2@(30),%d0
    cmpl %d4,%d0
    jbcc VEXTENDFILE_2A
    moveq #-34,%d0	/* dskFulErr */
    jbra VEXTENDFILE_160
VEXTENDFILE_2A:         /* contiguous wanted (a4 flag bit 6), or only contiguous (bit 7) */
    bset #6,%a4@
    btst #1,%d3
    jbeq VEXTENDFILE_38
    bset #7,%a4@
VEXTENDFILE_38:         /* round up to allocation blocks; already covered by the file's extents? just the length */
    movel %a2@(28),%d0
    addl %d0,%d4
    subql #1,%d4
    divuw %d0,%d4
    muluw %d0,%d4
    movel %a3@(12),%d0
    addl %d4,%d0
    subql #1,%d0
    jbsr VTRUNCATEFILE_168
    jbne VEXTENDFILE_60
    addl %d4,%a3@(12)
    bset #7,%a3@(4)
    jbra VEXTENDFILE_15A
VEXTENDFILE_60:         /* past the last extent (16): add extents; first use the rest of the last one */
    cmpiw #16,%d0
    jbne VEXTENDFILE_160
    movel %d2,%d7
    movew %d3,%d6
    movew %d6,%d0
    muluw %a2@(30),%d0
    subl %a3@(12),%d0
    jbeq VEXTENDFILE_84
    addl %d0,%a3@(12)
    bset #7,%a3@(4)
    subl %d0,%d4
VEXTENDFILE_84:         /* the next block after the last extent */
    movew %a1@(0x0,%d1:w),%d5
    addw %a1@(0x2,%d1:w),%d5
VEXTENDFILE_8C:         /* allocate (VSM) right after it if possible */
    movew %d5,%d2
    btst #6,%a4@
    sne %d3
    jsr %pc@(VSM)
    jbeq VEXTENDFILE_B4
    cmpiw #-34,%d0
    jbne VEXTENDFILE_160
    bclr #6,%a4@
    jbeq VEXTENDFILE_160
    btst #7,%a4@
    jbne VEXTENDFILE_160
    jbra VEXTENDFILE_8C
VEXTENDFILE_B4:         /* right after: just lengthen the last extent */
    cmpw %d2,%d5
    jbne VEXTENDFILE_BE
    addw %d3,%a1@(0x2,%d1:w)
    jbra VEXTENDFILE_D4
VEXTENDFILE_BE:         /* a new extent in this record, or a new record */
    tstw %a1@(0x2,%d1:w)
    jbeq VEXTENDFILE_CC
    addqw #4,%d1
    cmpiw #8,%d1
    jbgt VEXTENDFILE_E2
VEXTENDFILE_CC:         /* the new extent */
    movew %d2,%a1@(0x0,%d1:w)
    movew %d3,%a1@(0x2,%d1:w)
VEXTENDFILE_D4:         /* write the record back (FCB or B-tree) */
    movel %d7,%d2
    jbsr VXFSEARCH_100
    jbne VEXTENDFILE_160
    movel %d2,%d7
    jbra VEXTENDFILE_140
VEXTENDFILE_E2:         /* the record is full: a new extents B-tree record (not for the extents file itself: 17) */
    movel %a3@,%d5
    cmpil #3,%d5
    jbne VEXTENDFILE_F0
    moveq #17,%d0
    jbra VEXTENDFILE_160
VEXTENDFILE_F0:         /* its key: fork, file ID, start block */
    lea %a4@(2),%a0
    lea %a4@(10),%a1
    moveb #7,%a0@
    clrb %a0@(1)
    btst #1,%a3@(4)
    sne %a0@(1)
    movel %d5,%a0@(2)
    movew %d6,%a0@(6)
    movew #5,%d0
VEXTENDFILE_116:        /* clear the record */
    clrw %a1@+
    dbf %d0,VEXTENDFILE_116
    lea %a4@(10),%a1
    clrw %d1
    movew %d2,%a1@(0x0,%d1:w)
    movew %d3,%a1@(0x2,%d1:w)
    movel %d1,%fp@-
    movew #12,%d1
    movew %a2@(164),%d0
    jsr %pc@(BTINSERT)
    movel %fp@+,%d1
    tstw %d0
    jbne VEXTENDFILE_160
    movel %d2,%d7
VEXTENDFILE_140:        /* the physical length grows; more needed? */
    addw %d3,%d6
    muluw %a2@(30),%d3
    addl %d3,%a3@(12)
    bset #7,%a3@(4)
    subl %d3,%d4
    jbgt VEXTENDFILE_84
    addl %d4,%a3@(12)
VEXTENDFILE_15A:        /* flush the extents B-tree, the MDB */
    clrw %d0
    jbsr VTRUNCATEFILE_134
VEXTENDFILE_160:        /* d6 = bytes added; return */
    movel %a3@(12),%d6
    movel %fp@+,%d1
    subl %d1,%d6
    lea %fp@(22),%fp
    moveml %fp@+,%d1-%d5/%d7-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* FXMKEYCMP: compare two extents keys. */
FXMKEYCMP:              /* (file ID, then fork, then start block: d0 -1, 0, 1) */
    moveml %a0-%a1,%sp@-
    movel %a0@(2),%d0
    cmpl %a1@(2),%d0
    jbhi FXMKEYCMP_32
    jbcs FXMKEYCMP_2C
    moveb %a0@(1),%d0
    cmpb %a1@(1),%d0
    jbhi FXMKEYCMP_32
    jbcs FXMKEYCMP_2C
    movew %a0@(6),%d0
    cmpw %a1@(6),%d0
    jbhi FXMKEYCMP_32
    jbcs FXMKEYCMP_2C
    clrw %d0
    jbra FXMKEYCMP_36
FXMKEYCMP_2C:           /* less */
    movew #-1,%d0
    jbra FXMKEYCMP_36
FXMKEYCMP_32:           /* greater */
    movew #1,%d0
FXMKEYCMP_36:           /* return */
    moveml %sp@+,%a0-%a1
    tstw %d0
    rts

/* MAPFBLOCK: map a file block to a disk block through the extents. */
MAPFBLOCK:
    movel 0x7d0,%sp@-	/* through the vector at 0x7D0 (normally VMAPFBLOCK; patchable) */
    rts

/* VMAPFBLOCK: vectored entry: map a file block to a disk block through the extents. */
trap_VMAPFBLOCK:
VMAPFBLOCK:             /* (d5 = file position, d4 = bytes wanted: d3 = the disk block, d6 = bytes contiguous) */
    movel %sp@+,%fp@-
    moveml %d1-%d2/%d4-%d5/%d7-%a1/%a3-%a4,%fp@-
    jbsr VTRUNCATEFILE_12A
    lea %a1@(0x0,%d1:w),%a3
    movel %d5,%d0
    jbsr VTRUNCATEFILE_168
    jbne VMAPFBLOCK_6E
    lea %a1@(0x0,%d1:w),%a1
    movew %d3,%d1
    subw %a1@(2),%d1
    movew %d3,%d2
    muluw %a2@(30),%d2
    movel %a3@(12),%d0
    cmpl %d0,%d2
    jble VMAPFBLOCK_30
    movel %d0,%d2
VMAPFBLOCK_30:          /* the disk block: (extent start + offset) in 512-byte blocks + vcbAlBlSt */
    divuw %a2@(30),%d2
    movel %a2@(28),%d6
    divuw #512,%d6
    moveq #0,%d7
    movew %a2@(36),%d7
    movel %d5,%d3
    divuw %a2@(30),%d3
    swap %d3
    moveq #0,%d0
    movew %d3,%d0
    lsrl #8,%d0
    lsrl #1,%d0
    swap %d3
    subw %d1,%d3
    addw %a1@,%d3
    muluw %d6,%d3
    addl %d0,%d3
    addl %d7,%d3
    movew %d2,%d6
    muluw %a2@(30),%d6
    subl %d5,%d6
    cmpl %d4,%d6
    jbcs VMAPFBLOCK_6C
    movel %d4,%d6
VMAPFBLOCK_6C:          /* no error */
    moveq #0,%d0
VMAPFBLOCK_6E:          /* return */
    lea %fp@(22),%fp
    moveml %fp@+,%d1-%d2/%d4-%d5/%d7-%a1/%a3-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* TRUNCATEFILE: free the extents past the EOF. */
TRUNCATEFILE:
    movel 0x76c,%sp@-	/* through the vector at 0x76C (normally VTRUNCATEFILE; patchable) */
    rts

/* VTRUNCATEFILE: vectored entry: free the extents past the EOF. */
trap_VTRUNCATEFILE:
VTRUNCATEFILE:          /* (d3 = the new physical length, d2 bit 0: free the whole extent holding the end) */
    movel %sp@+,%fp@-
    moveml %d1-%a4,%fp@-
    jbsr VTRUNCATEFILE_12A
    lea %a1@(0x0,%d1:w),%a3
    moveb %d2,%d6
    movel %d3,%d5
    movel %a2@(28),%d0
    addl %d0,%d5
    subql #1,%d5
    divuw %d0,%d5
    muluw %d0,%d5
    movel %d5,%d0
    subql #1,%d0
    jbge VTRUNCATEFILE_3C
    movel %d5,%a3@(12)
    bset #7,%a3@(4)
    subal %a0,%a0
    moveq #0,%d7
    lea %a3@(38),%a1
    clrw %d4
    jbra VTRUNCATEFILE_D6
VTRUNCATEFILE_3C:       /* the extent holding the last block to keep */
    jbsr VTRUNCATEFILE_168
    jbne VTRUNCATEFILE_11C
    movel %d2,%d7
    movew %d3,%d4
    movel %d5,%a3@(12)
    bset #7,%a3@(4)
    btst #0,%d6
    jbeq VTRUNCATEFILE_60
    movew %a1@(0x2,%d1:w),%d3
    jbra VTRUNCATEFILE_EE
VTRUNCATEFILE_60:       /* free the end of that extent */
    movel %d5,%d0
    subql #1,%d0
    divuw %a2@(30),%d0
    subw %d0,%d3
    subqw #1,%d3
    jbeq VTRUNCATEFILE_80
    movew %a1@(0x0,%d1:w),%d2
    addw %a1@(0x2,%d1:w),%d2
    subw %d3,%d2
    jsr %pc@(BLKDEALLOC)
    jbne VTRUNCATEFILE_11C
VTRUNCATEFILE_80:       /* shorten it (empty: clear it) */
    movew %d3,%d0
    movew %a1@(0x2,%d1:w),%d3
    subw %d0,%a1@(0x2,%d1:w)
    jbne VTRUNCATEFILE_EE
    clrw %a1@(0x0,%d1:w)
    jbra VTRUNCATEFILE_EE
VTRUNCATEFILE_92:       /* the next extent record in the B-tree */
    lea %a4@(2),%a0
    moveb #7,%a0@
    btst #1,%a3@(4)
    sne %a0@(1)
    movel %a3@,%a0@(2)
    movew %d4,%a0@(6)
    movew %a2@(164),%d0
    moveq #0,%d2
    jsr %pc@(BTSEARCH)
    jbeq VTRUNCATEFILE_C0
    cmpiw #32,%d0
    jbeq VTRUNCATEFILE_118
    jbra VTRUNCATEFILE_11C
VTRUNCATEFILE_C0:       /* copy it */
    movel %d2,%d7
    lea %a4@(10),%a0
    moveq #2,%d0
VTRUNCATEFILE_C8:       /* copy */
    movel %a1@+,%a0@+
    dbf %d0,VTRUNCATEFILE_C8
    lea %a4@(2),%a0
    lea %a4@(10),%a1
VTRUNCATEFILE_D6:       /* free its extents */
    clrw %d1
VTRUNCATEFILE_D8:       /* each extent */
    movew %a1@(0x0,%d1:w),%d2
    movew %a1@(0x2,%d1:w),%d3
    jbeq VTRUNCATEFILE_F6
    jsr %pc@(BLKDEALLOC)
    jbne VTRUNCATEFILE_11C
    clrl %a1@(0x0,%d1:w)
    addw %d3,%d4
VTRUNCATEFILE_EE:       /* next */
    addqw #4,%d1
    cmpiw #8,%d1
    jble VTRUNCATEFILE_D8
VTRUNCATEFILE_F6:       /* a record still in use: write it back; empty: delete it */
    tstw %a1@(2)
    jbeq VTRUNCATEFILE_104
    movel %d7,%d2
    jbsr VXFSEARCH_100
    jbra VTRUNCATEFILE_112
VTRUNCATEFILE_104:      /* delete */
    movel %a0,%d0
    jbeq VTRUNCATEFILE_112
    movew %a2@(164),%d0
    jsr %pc@(BTDELETE)
    jbne VTRUNCATEFILE_11C
VTRUNCATEFILE_112:      /* more records? */
    tstw %d3
    jbne VTRUNCATEFILE_92
VTRUNCATEFILE_118:      /* flush */
    clrw %d0
    jbsr VTRUNCATEFILE_134
VTRUNCATEFILE_11C:      /* return */
    lea %fp@(22),%fp
    moveml %fp@+,%d1-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

VTRUNCATEFILE_12A:      /* 22 bytes of locals on the a6 stack (a4): flags, a key, an extent record */
    subaw #22,%fp
    moveal %fp,%a4
    clrb %a4@
    rts

VTRUNCATEFILE_134:      /* flush the extents B-tree; the MDB if its FCB changed */
    movel %sp@+,%fp@-
    moveml %d1/%a1,%fp@-
    movew %a2@(164),%d1
    movew %d1,%d0
    jsr %pc@(BTFLUSH)
    jbne VTRUNCATEFILE_15E
    moveal FCBSPtr,%a1
    btst #7,%a1@(0x4,%d1:w)
    jbeq VTRUNCATEFILE_15C
    jsr %pc@(MARKVCB)
    jsr %pc@(FLUSHMDB)
    jbne VTRUNCATEFILE_15E
VTRUNCATEFILE_15C:      /* no error */
    clrw %d0
VTRUNCATEFILE_15E:      /* return */
    moveml %fp@+,%d1/%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

VTRUNCATEFILE_168:      /* find the extent of a file block (VXFSEARCH) */
    movel 0x7d4,%sp@-	/* through the vector at 0x7D4 (normally VXFSEARCH; patchable) */
    rts

/*
 VXFSEARCH (d0 = byte position, a3 = FCB): the extent holding that allocation block:
 first in the FCB's own record, then the extents B-tree record whose start block is
 at most it. Out: a1 = the record, d1 = the extent in it, d3 = its first file block,
 a0/d2 = the B-tree key and hint (0 for the FCB's record); 16 if beyond the extents.
*/
trap_VXFSEARCH:
VXFSEARCH:
    movel %sp@+,%fp@-
    moveml %d4-%d6,%fp@-
    movel %d0,%d4
    divuw %a2@(30),%d4
    movel %a3@,%d5
    subal %a0,%a0
    moveq #0,%d2
    lea %a3@(38),%a1
    movew %d4,%d0
    clrw %d3
    jbsr VXFSEARCH_D4
    jbeq VXFSEARCH_C8
    cmpiw #8,%d1
    jblt VXFSEARCH_CA
    tstw %a1@(0x2,%d1:w)
    jbeq VXFSEARCH_CA
    cmpil #3,%d5
    jbeq VXFSEARCH_CA
    lea %a4@(2),%a0
    moveb #7,%a0@
    btst #1,%a3@(4)
    sne %d6
    moveb %d6,%a0@(1)
    movel %d5,%a0@(2)
    movew %d4,%a0@(6)
    movew %a2@(164),%d0
    moveq #0,%d2
    jsr %pc@(BTSEARCH)
    jbeq VXFSEARCH_9A
    cmpiw #32,%d0
    jbne VXFSEARCH_CA
    movew %a2@(164),%d0
    moveq #-1,%d1
    jsr %pc@(BTGETRECORD)
    jbeq VXFSEARCH_7E
    cmpiw #32,%d0
    jbeq VXFSEARCH_8A
    jbra VXFSEARCH_CA
VXFSEARCH_7E:           /* the record before: the same file and fork? */
    cmpl %a0@(2),%d5
    jbne VXFSEARCH_8A
    cmpb %a0@(1),%d6
    jbeq VXFSEARCH_9A
VXFSEARCH_8A:           /* no: beyond the extents of the FCB's record (16) */
    subal %a0,%a0
    moveq #0,%d2
    lea %a3@(38),%a1
    movew #8,%d1
    moveq #16,%d0
    jbra VXFSEARCH_CA
VXFSEARCH_9A:           /* copy the key and the record to the locals */
    movel %a1,%sp@-
    lea %a4@(2),%a1
    moveq #1,%d0
VXFSEARCH_A2:           /* key */
    movel %a0@+,%a1@+
    dbf %d0,VXFSEARCH_A2
    moveal %sp@+,%a0
    lea %a4@(10),%a1
    moveq #2,%d0
VXFSEARCH_B0:           /* record */
    movel %a0@+,%a1@+
    dbf %d0,VXFSEARCH_B0
    lea %a4@(2),%a0
    lea %a4@(10),%a1
    movew %a0@(6),%d3
    movew %d4,%d0
    jbsr VXFSEARCH_D4
    jbne VXFSEARCH_CA
VXFSEARCH_C8:           /* found */
    clrw %d0
VXFSEARCH_CA:           /* return */
    moveml %fp@+,%d4-%d6
    movel %fp@+,%sp@-
    tstw %d0
    rts

VXFSEARCH_D4:           /* the extent of record a1 holding block d0 (first file block d3) */
    movel %d2,%sp@-
    movew %d0,%d2
    clrw %d1
VXFSEARCH_DA:           /* next extent */
    movew %a1@(0x2,%d1:w),%d0
    jbeq VXFSEARCH_EE
    addw %d0,%d3
    cmpw %d2,%d3
    jbhi VXFSEARCH_F8
    addqw #4,%d1
    cmpiw #8,%d1
    jble VXFSEARCH_DA
VXFSEARCH_EE:           /* not in this record: the last extent */
    subqw #4,%d1
    jbge VXFSEARCH_F4
    clrw %d1
VXFSEARCH_F4:           /* 16 */
    moveq #16,%d0
    jbra VXFSEARCH_FA
VXFSEARCH_F8:           /* found */
    clrw %d0
VXFSEARCH_FA:           /* return */
    movel %sp@+,%d2
    tstw %d0
    rts

VXFSEARCH_100:          /* write the extent record back: the FCB's (mark it dirty) or the B-tree's (BTUPDATE) */
    movel %sp@+,%fp@-
    moveml %d1/%a0-%a1,%fp@-
    movel %a0,%d0
    jbne VXFSEARCH_112
    bset #7,%a3@(4)
    jbra VXFSEARCH_132
VXFSEARCH_112:          /* the B-tree record */
    movew %a2@(164),%d0
    jsr %pc@(BTSEARCH)
    jbne VXFSEARCH_134
    lea %a4@(10),%a0
    moveq #2,%d0
VXFSEARCH_122:          /* copy */
    movel %a0@+,%a1@+
    dbf %d0,VXFSEARCH_122
    movew %a2@(164),%d0
    jsr %pc@(BTUPDATE)
    jbne VXFSEARCH_134
VXFSEARCH_132:          /* no error */
    clrw %d0
VXFSEARCH_134:          /* return */
    moveml %fp@+,%d1/%a0-%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408129A2

/* CMSVCS: Catalog Manager services. */

/*
 CMSVCS, the Catalog Manager: the catalog B-tree holds a record per file and folder,
 keyed by (parent dir ID, name), plus a thread record per folder keyed by (its own
 ID, empty name) pointing back to its parent and name. Records: type byte 1 folder
 (flags, valence, dir ID, dates, Finder info), 2 file (flags, type, Finder info, file
 ID, the forks' lengths and first extents, dates, clump size), 3 folder thread.
 Routines take d0 = parent ID, a0 = name, d2 = hint; most results are B-tree codes
 (48 not found, 49 exists, 50 folder not empty).
*/
CMSVCS:
CMCREATECN:             /* (d0 = parent ID, a0 = name, d1 = type 1 folder / 2 file, version in the high word: d1 = the new ID, d2 = the hint) */
    movel %sp@+,%fp@-
    moveml %d3-%a4,%fp@-
    jbsr CMUPDATECN_32
    clrl %a2@(172)
    movel %d1,%d5
    movel %d0,%d3
    moveal %a0,%a3
    subal %a0,%a0
    moveq #0,%d2
    jsr %pc@(LOCCREC)
    jbne CMSVCS_138
    movel %d3,%d0
    moveal %a3,%a0
    lea %a4@,%a1
    jsr %pc@(CMMAINT)
    lea %a4@(38),%a1
    moveal %a1,%a0
    movew #50,%d0
CMSVCS_34:              /* build the record in the locals */
    clrw %a0@+
    dbf %d0,CMSVCS_34
    moveb %d5,%a1@
    movel Time,%d2
    cmpib #1,%d5
    jbne CMSVCS_5E
    movel %a2@(38),%d6
    movel %d6,%a1@(6)
    addql #1,%a2@(38)
    movel %d2,%a1@(10)
    movel %d2,%a1@(14)
    moveq #70,%d1
    jbra CMSVCS_7A
CMSVCS_5E:              /* a file: dates, a new file ID, the version */
    movel %d2,%a1@(44)
    movel %d2,%a1@(48)
    movel %a2@(38),%a1@(20)
    addql #1,%a2@(38)
    swap %d5
    moveb %d5,%a1@(3)
    swap %d5
    moveq #102,%d1
CMSVCS_7A:              /* insert it (102 bytes, a folder 70); exists (33): 49 */
    movew %a2@(166),%d0
    lea %a4@,%a0
    jsr %pc@(BTINSERT)
    jbeq CMSVCS_94
    cmpiw #33,%d0
    jbne CMSVCS_138
    moveq #49,%d0
    jbra CMSVCS_138
CMSVCS_94:              /* a folder: also its thread record (46 bytes: type 3, parent ID, name) */
    movel %d2,%d7
    cmpib #1,%d5
    jbne CMSVCS_100
    movel %d6,%d0
    subal %a0,%a0
    lea %a4@,%a1
    jsr %pc@(CMMAINT)
    lea %a4@(38),%a1
    movew #22,%d0
CMSVCS_AE:              /* clear it */
    clrw %a1@+
    dbf %d0,CMSVCS_AE
    lea %a4@(38),%a1
    moveb #3,%a1@
    movel %d3,%a1@(10)
    moveal %a3,%a0
    lea %a1@(14),%a1
    jsr %pc@(UPDCNAME)
    movew %a2@(166),%d0
    movew #46,%d1
    lea %a4@,%a0
    lea %a4@(38),%a1
    jsr %pc@(BTINSERT)
    jbeq CMSVCS_100
    movel %d0,%fp@-
    movel %d3,%d0
    moveal %a3,%a0
    lea %a4@,%a1
    jsr %pc@(CMMAINT)
    moveal %a1,%a0
    movew %a2@(166),%d0
    jsr %pc@(BTDELETE)
    movel %fp@+,%d0
    cmpiw #33,%d0
    jbne CMSVCS_138
    moveq #49,%d0
    jbra CMSVCS_138
CMSVCS_100:             /* the parent's valence + 1 and modification date; the volume's counts */
    movel %d3,%d0
    subal %a0,%a0
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMSVCS_138
    addqw #1,%a1@(4)
    movel Time,%a1@(14)
    movew %a2@(166),%d0
    jsr %pc@(BTUPDATE)
    jbne CMSVCS_138
    moveb %d5,%d0
    movel %d3,%d1
    moveq #1,%d2
    jbsr VCMSETUP_8
    clrw %d0
    movel %d6,%d1
    movel %d7,%d2
    jsr %pc@(MARKVCBTIME)
    jsr %pc@(CMFLUSH)
CMSVCS_138:             /* free the locals, return */
    lea %fp@(140),%fp
    moveml %fp@+,%d3-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* CMDELETECN: delete a catalog node. */
CMDELETECN:             /* (d0 = parent ID, a0 = name) */
    movel %sp@+,%fp@-
    moveml %d1-%d6/%a0-%a1/%a3-%a4,%fp@-
    jbsr CMUPDATECN_32
    clrl %a2@(172)
    movel %d0,%d3
    moveal %a0,%a3
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMDELETECN_9E
    moveb %a1@,%d4
    movel %a0@(2),%d6
    cmpib #1,%d4
    jbne CMDELETECN_42
    movel %a1@(6),%d5
    cmpil #2,%d5
    jbne CMDELETECN_38
    moveq #51,%d0
    jbra CMDELETECN_9E
CMDELETECN_38:          /* a folder must be empty (50); the root cannot be deleted (51) */
    tstw %a1@(4)
    jbeq CMDELETECN_42
    moveq #50,%d0
    jbra CMDELETECN_9E
CMDELETECN_42:          /* delete the record; a folder: its thread too */
    lea %a4@,%a0
    movew %a2@(166),%d0
    jsr %pc@(BTDELETE)
    jbne CMDELETECN_9E
    cmpib #1,%d4
    jbne CMDELETECN_6A
    subal %a0,%a0
    movel %d5,%d0
    lea %a4@,%a1
    jsr %pc@(CMMAINT)
    lea %a4@,%a0
    movew %a2@(166),%d0
    jsr %pc@(BTDELETE)
    jbne CMDELETECN_9E
CMDELETECN_6A:          /* the parent's valence - 1; the volume's counts */
    movel %d6,%d0
    subal %a0,%a0
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMDELETECN_9E
    subqw #1,%a1@(4)
    movel Time,%a1@(14)
    movew %a2@(166),%d0
    jsr %pc@(BTUPDATE)
    jbne CMDELETECN_9E
    moveb %d4,%d0
    movel %d6,%d1
    moveq #-1,%d2
    jbsr VCMSETUP_8
    clrw %d0
    jsr %pc@(MARKVCBTIME)
    jsr %pc@(CMFLUSH)
CMDELETECN_9E:          /* return */
    lea %fp@(140),%fp
    moveml %fp@+,%d1-%d6/%a0-%a1/%a3-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* CMGETCN: get a catalog node by name. */
CMGETCN:                /* (a0 = 0: the folder whose thread is d0) */
    movel %sp@+,%fp@-
    moveml %d1/%d3/%a3-%a4,%fp@-
    jbsr CMUPDATECN_32
    clrl %a2@(172)
    jsr %pc@(LOCCNODE)
    lea %fp@(140),%fp
    moveml %fp@+,%d1/%d3/%a3-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* CMGETOFF: get a catalog node by offset (index). */
CMGETOFF:               /* (d0 = folder ID, d1 = index: the d1-th record of the folder; the VCB keeps the last folder and index, +172, +176, to step forward quickly) */
    movel %sp@+,%fp@-
    moveml %d1/%d3-%d4/%a4,%fp@-
    jbsr CMUPDATECN_32
    movel %d0,%d3
    movew %d1,%d4
    movel %a2@(172),%d1
    jbeq CMGETOFF_18
    cmpl %d3,%d1
    jbeq CMGETOFF_2E
CMGETOFF_18:            /* from the folder's thread record */
    clrl %a2@(172)
    movel %d3,%d0
    subal %a0,%a0
    jsr %pc@(LOCCREC)
    jbne CMGETOFF_56
    movel %d3,%a2@(172)
    clrw %a2@(176)
CMGETOFF_2E:            /* step forward from the last index */
    movew %a2@(166),%d0
    movew %d4,%d1
    subw %a2@(176),%d1
    jsr %pc@(BTGETRECORD)
    jbeq CMGETOFF_4C
CMGETOFF_3E:            /* end of the B-tree: 48 (not found) */
    cmpiw #32,%d0
    jbne CMGETOFF_46
CMGETOFF_44:            /* 48 */
    moveq #48,%d0
CMGETOFF_46:            /* forget the position */
    clrl %a2@(172)
    jbra CMGETOFF_56
CMGETOFF_4C:            /* still in this folder? remember the index */
    cmpl %a0@(2),%d3
    jbne CMGETOFF_44
    movew %d4,%a2@(176)
CMGETOFF_56:            /* return */
    lea %fp@(140),%fp
    moveml %fp@+,%d1/%d3-%d4/%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* CMMOVECN: move a catalog node. */
CMMOVECN:               /* (d0/a0 = the item, d1/a1 = the destination folder) */
    movel %sp@+,%fp@-
    moveml %d1/%d3-%a1/%a3-%a4,%fp@-
    jbsr CMUPDATECN_32
    clrl %a2@(172)
    movel %d1,%d5
    movel %a1,%d6
    movel %d0,%d3
    moveal %a0,%a3
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMMOVECN_198
    moveq #0,%d4
    cmpib #1,%a1@
    jbne CMMOVECN_2C
    movel %a1@(6),%d4
CMMOVECN_2C:            /* the destination must be a folder (badMovErr) */
    movel %d5,%d0
    moveal %d6,%a0
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMMOVECN_198
    cmpib #1,%a1@
    jbeq CMMOVECN_48
    movew #-122,%d0	/* badMovErr */
    jbra CMMOVECN_198
CMMOVECN_48:            /* a folder cannot move into itself or its own descendants (badMovErr) */
    movel %a1@(6),%d7
    tstl %d4
    jbeq CMMOVECN_82
    cmpil #2,%d4
    jbeq CMMOVECN_7A
    cmpl %d4,%d7
    jbeq CMMOVECN_7A
CMMOVECN_5C:            /* walk up from the destination through the parents */
    movel %a0@(2),%d0
    cmpl %d4,%d0
    jbeq CMMOVECN_7A
    cmpil #2,%d0
    jble CMMOVECN_82
    subal %a0,%a0
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMMOVECN_198
    jbra CMMOVECN_5C
CMMOVECN_7A:            /* badMovErr */
    movew #-122,%d0	/* badMovErr */
    jbra CMMOVECN_198
CMMOVECN_82:            /* already in that folder: nothing to do */
    movel %d3,%d0
    moveal %a3,%a0
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMMOVECN_198
    cmpl %a0@(2),%d7
    jbne CMMOVECN_9C
    movel %d2,%d7
    jbra CMMOVECN_18C
CMMOVECN_9C:            /* copy the record, insert it under the new parent */
    movel %a1,%sp@-
    lea %a4@,%a1
    moveq #1,%d0
    addb %a0@,%d0
    _BlockMove
    moveal %sp@+,%a0
    lea %a4@(38),%a1
    movew %d1,%d0
    extl %d0
    _BlockMove
    lea %a4@,%a0
    movel %a0@(2),%d4	| 40812CDA
    movel %d7,%a0@(2)
    lea %a4@(38),%a1
    moveq #102,%d1
    cmpib #2,%a1@
    jbeq CMMOVECN_D0
    moveq #70,%d1
    movel Time,%a1@(14)
CMMOVECN_D0:            /* insert (exists: 49) */
    movew %a2@(166),%d0
    jsr %pc@(BTINSERT)
    jbeq CMMOVECN_E8
    cmpiw #33,%d0
    jbne CMMOVECN_198
    moveq #49,%d0
    jbne CMMOVECN_198
CMMOVECN_E8:            /* the new parent's valence + 1; delete the old record; a folder: its thread's parent */
    movel %d2,%d7
    movel %a0@(2),%d0
    exg %d5,%d0
    moveal %d6,%a0
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMMOVECN_198
    addqw #1,%a1@(4)
    movel Time,%a1@(14)
    movew %a2@(166),%d0
    jsr %pc@(BTUPDATE)
    jbne CMMOVECN_198
    lea %a4@(38),%a1
    moveb %a1@,%d0
    movel %d5,%d1
    moveq #1,%d2
    jbsr VCMSETUP_18
    movel %d3,%d0
    moveal %a3,%a0
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMMOVECN_198
    lea %a4@,%a0
    movew %a2@(166),%d0
    jsr %pc@(BTDELETE)
    jbne CMMOVECN_198
    lea %a4@(38),%a1
    cmpib #1,%a1@
    jbne CMMOVECN_15E
    movel %a1@(6),%d0
    subal %a0,%a0
    moveq #0,%d2
    jsr %pc@(LOCCREC)
    jbne CMMOVECN_198
    movel %d5,%a1@(10)
    movew %a2@(166),%d0
    jsr %pc@(BTUPDATE)
    jbne CMMOVECN_198
CMMOVECN_15E:           /* the old parent's valence - 1 */
    movel %d4,%d0
    subal %a0,%a0
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMMOVECN_198
    subqw #1,%a1@(4)
    movel Time,%a1@(14)
    movew %a2@(166),%d0
    jsr %pc@(BTUPDATE)
    jbne CMMOVECN_198
    lea %a4@(38),%a1
    moveb %a1@,%d0
    movel %d4,%d1
    moveq #-1,%d2
    jbsr VCMSETUP_18
CMMOVECN_18C:           /* flush */
    clrw %d0
    movel %d7,%d2
    jsr %pc@(MARKVCBTIME)
    jsr %pc@(CMFLUSH)
CMMOVECN_198:           /* return */
    lea %fp@(140),%fp
    moveml %fp@+,%d1/%d3-%a1/%a3-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* CMRENAMECN: rename a catalog node. */
CMRENAMECN:             /* (d0/a0 = the item, a1 = the new name) */
    movel %sp@+,%fp@-
    moveml %d1/%d3-%a1/%a3-%a4,%fp@-
    jbsr CMUPDATECN_32
    clrl %a2@(172)
    movel %d0,%d3
    moveal %a0,%a3
    movel %a1,%d5
    jsr %pc@(LOCCNODE)
    jbne CMRENAMECN_FA
    movel %d2,%d4
    movew %d1,%d6
    moveal %a1,%a0
    lea %a4@(38),%a1
    movew %d6,%d0
    extl %d0
    _BlockMove
    lea %a4@,%a1
    movel %a1@(2),%d0
    moveal %d5,%a0
    jsr %pc@(CMMAINT)
    moveal %a1,%a0
    lea %a4@(38),%a1
    movew %d6,%d1
    movew %a2@(166),%d0
    jsr %pc@(BTINSERT)
    jbeq CMRENAMECN_A8
    cmpiw #33,%d0
    jbne CMRENAMECN_FA
    lea %a4@,%a1
    movel %a1@(2),%d0	| 40812E20
    moveal %d5,%a0
    moveq #0,%d2
    jsr %pc@(LOCCNODE)
    jbne CMRENAMECN_FA
    movel %d2,%d7
    movel %a0,%d6
    lea %a4@(38),%a0
    moveb %a0@,%d0
    cmpb %a1@,%d0
    jbne CMRENAMECN_8E
    cmpib #1,%d0
    jbne CMRENAMECN_84
    movel %a1@(6),%d1
    cmpl %a0@(6),%d1
    jbeq CMRENAMECN_92
    jbra CMRENAMECN_8E
CMRENAMECN_84:          /* a file: the same file? */
    movel %a1@(20),%d1
    cmpl %a0@(20),%d1
    jbeq CMRENAMECN_92
CMRENAMECN_8E:          /* another item has that name: 49 */
    moveq #49,%d0
    jbra CMRENAMECN_FA
CMRENAMECN_92:          /* the same item (only the case changes): update the name in place */
    moveal %d6,%a1
    lea %a1@(6),%a1
    moveal %d5,%a0
    jsr %pc@(UPDCNAME)
    movew %a2@(166),%d0
    jsr %pc@(BTUPDATE)
    jbra CMRENAMECN_C4
CMRENAMECN_A8:          /* inserted under the new name: delete the old record */
    movel %d2,%d7
    movel %d3,%d0
    moveal %a3,%a0
    movel %d4,%d2
    jsr %pc@(LOCCNODE)
    jbne CMRENAMECN_FA
    lea %a4@,%a0
    movew %a2@(166),%d0
    moveq #0,%d2
    jsr %pc@(BTDELETE)
    jbne CMRENAMECN_FA
CMRENAMECN_C4:          /* a folder: its thread's name too */
    lea %a4@(38),%a1
    cmpib #1,%a1@
    jbne CMRENAMECN_EE
    movel %a1@(6),%d0
    subal %a0,%a0
    moveq #0,%d2
    jsr %pc@(LOCCREC)
    jbne CMRENAMECN_FA
    moveal %d5,%a0
    lea %a1@(14),%a1
    jsr %pc@(UPDCNAME)
    movew %a2@(166),%d0
    jsr %pc@(BTUPDATE)
CMRENAMECN_EE:          /* flush */
    clrw %d0
    movel %d7,%d2
    jsr %pc@(MARKVCBTIME)
    jsr %pc@(CMFLUSH)
CMRENAMECN_FA:          /* return */
    lea %fp@(140),%fp
    moveml %fp@+,%d1/%d3-%a1/%a3-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* CMUPDATECN: update a catalog node. */
CMUPDATECN:             /* (write back the record found last: BTUPDATE) */
    movel %sp@+,%fp@-
    moveml %d1-%d2/%a0-%a1,%fp@-
    jbsr CMUPDATECN_32
    movew %a2@(166),%d0
    jsr %pc@(BTUPDATE)
    jbeq CMUPDATECN_1C
    cmpiw #32,%d0
    jbne CMUPDATECN_24
    moveq #48,%d0
    jbra CMUPDATECN_24
CMUPDATECN_1C:          /* flush */
    jsr %pc@(MARKVCBTIME)
    jsr %pc@(CMFLUSH)
CMUPDATECN_24:          /* return */
    lea %fp@(140),%fp
    moveml %fp@+,%d1-%d2/%a0-%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

CMUPDATECN_32:          /* the locals (VCMSETUP) */
    movel 0x770,%sp@-	/* through the vector at 0x770 (normally VCMSETUP; patchable) */
    rts

/* VCMSETUP: set up for a catalog operation. */
trap_VCMSETUP:
VCMSETUP:               /* 140 bytes of locals on the a6 stack (a4): a key, a record */
    subaw #140,%fp
    moveal %fp,%a4
    rts

VCMSETUP_8:             /* the volume's file (+114) or folder (+118) count += d2 */
    cmpib #1,%d0
    jbne VCMSETUP_14
    addl %d2,%a2@(118)
    jbra VCMSETUP_18
VCMSETUP_14:            /* files */
    addl %d2,%a2@(114)

VCMSETUP_18:            /* in the root (parent 2): the root's file (+20) or folder (+112) count */
    cmpil #2,%d1
    jbne VCMSETUP_30
    cmpib #1,%d0
    jbne VCMSETUP_2C
    addw %d2,%a2@(112)
    jbra VCMSETUP_30
VCMSETUP_2C:            /* files in the root */
    addw %d2,%a2@(20)
VCMSETUP_30:            /* return */
    rts
    .short  0x0000	| 40812F3E

/* CMMAINT: catalog maintenance. */

/* BUILDKEY: build a catalog key (parent ID, name). */
CMMAINT:
BUILDKEY:               /* (d0 = parent ID, a0 = name or 0, a1 = the key: length, 0, parent ID, name) */
    moveml %d0/%a0-%a1,%sp@-
    moveb #6,%a1@
    clrb %a1@(1)
    movel %d0,%a1@(2)
    clrb %a1@(6)
    movel %a0,%d0
    jbeq CMMAINT_28
    movel %a1,%sp@-
    lea %a1@(6),%a1
    jbsr UPDCNAME
    moveb %a1@,%d0
    moveal %sp@+,%a1
    addb %d0,%a1@
CMMAINT_28:             /* return */
    moveml %sp@+,%d0/%a0-%a1
    rts

/* CMFLUSH: flush the catalog. */
CMFLUSH:
    movel %sp@+,%fp@-
    moveml %d1/%a1,%fp@-
    movew %a2@(166),%d1
    movew %d1,%d0
    jsr %pc@(BTFLUSH)
    jbne CMFLUSH_2A
    moveal FCBSPtr,%a1
    btst #7,%a1@(0x4,%d1:w)
    jbeq CMFLUSH_28
    jsr %pc@(MARKVCB)
    jsr %pc@(FLUSHMDB)
    jbne CMFLUSH_2A
CMFLUSH_28:             /* no error */
    clrw %d0
CMFLUSH_2A:             /* return */
    moveml %fp@+,%d1/%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* CMKEYCMP: compare two catalog keys (case-insensitive names). */
CMKEYCMP:               /* (parent ID, then the names with RelString: d0 -1, 0, 1) */
    moveml %d1-%d2/%a0-%a3,%sp@-
    moveal %a0,%a2
    moveal %a1,%a3
    movel %a2@(2),%d0
    cmpl %a3@(2),%d0
    jbhi CMKEYCMP_32
    jbcs CMKEYCMP_2A
    lea %a2@(6),%a0
    lea %a3@(6),%a1
    moveq #0,%d0
    moveb %a0@+,%d0
    swap %d0
    moveb %a1@+,%d0
    _RelString
    jbeq CMKEYCMP_2E
    jbgt CMKEYCMP_32
CMKEYCMP_2A:            /* less */
    moveq #-1,%d0
    jbra CMKEYCMP_34
CMKEYCMP_2E:            /* equal */
    moveq #0,%d0
    jbra CMKEYCMP_34
CMKEYCMP_32:            /* greater */
    moveq #1,%d0
CMKEYCMP_34:            /* return */
    moveml %sp@+,%d1-%d2/%a0-%a3
    tstw %d0
    rts

/* LOCCNODE: locate a catalog node. */
LOCCNODE:               /* (a thread record leads on to the folder record itself) */
    movel %sp@+,%fp@-
    jsr %pc@(LOCCREC)
    jbne LOCCNODE_1A
    cmpib #3,%a1@
    jbne LOCCNODE_1A
    lea %a1@(14),%a0
    movel %a1@(10),%d0
    bsrw LOCCREC
LOCCNODE_1A:            /* return */
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* LOCCREC: locate a catalog record. */
LOCCREC:
    movel 0x7c8,%sp@-	/* through the vector at 0x7C8 (normally VLOCCREC; patchable) */
    rts

/* VLOCCREC: vectored entry: locate a catalog record. */
trap_VLOCCREC:
VLOCCREC:               /* (d0 = parent ID, a0 = name or 0, d2 = hint: BTSEARCH; not found: 48; a1 = the record, d1 its size) */
    movel %sp@+,%fp@-
    lea %a4@,%a1
    jsr %pc@(CMMAINT)
    movel %a0,%d0
    jbne VLOCCREC_E
    moveq #0,%d2
VLOCCREC_E:             /* search */
    lea %a4@,%a0
    movew %a2@(166),%d0
    jsr %pc@(BTSEARCH)
    jbeq VLOCCREC_22
    cmpiw #32,%d0
    jbne VLOCCREC_22
    moveq #48,%d0
VLOCCREC_22:            /* return */
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* UPDCNAME: update the name in a record. */
UPDCNAME:               /* (a0 = Pascal string, a1 = destination: at most 31 characters) */
    moveml %d0-%d1/%a0-%a1,%sp@-
    moveq #0,%d0
    moveb %a0@+,%d0
    moveq #31,%d1
    cmpw %d1,%d0
    jble UPDCNAME_10
    movew %d1,%d0
UPDCNAME_10:            /* copy */
    moveb %d0,%a1@+
    _BlockMove
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40813046

/* BTSVCS: B-tree services. */

/*
 BTSVCS, the B-tree services, for the extents and catalog files. A B-tree file is made
 of nodes (the node size, 512 bytes here): node 0 is the header node (the header
 record: depth, root, leaf record count, first and last leaf, node size, key length,
 node count, free nodes; then the node bitmap). Every node starts with a descriptor
 (+0 forward link, +4 backward link, +8 type: 0xFF leaf, 0 index, 1 header, 2 map;
 +9 height, +10 record count) and ends with the record offsets. Index nodes hold
 (key, child node) records; leaves hold the data in key order. The control block
 (BTCB, 54 bytes, from the FCB +34; a4 in these routines): +0 flags (bit 7 header
 dirty), +2 the FCB, +4 the key compare routine, +8 the cache, +12 work buffers,
 +16 path length, +18/+22 the current node and record, +24.. a copy of the header
 record. Results: 0, 32 not found / end, 33 already exists, 35 no room, 37 bad
 header.
*/
BTSVCS:
BTCLOSE:
    movel 0x730,%sp@-	/* through the vector at 0x730 (normally VBTCLOSE; patchable) */
    rts

/* VBTCLOSE: vectored entry: close a B-tree file. */
trap_VBTCLOSE:
VBTCLOSE:
    movel %sp@+,%fp@-
    moveml %d1-%d4/%a0-%a4,%fp@-
    movew %d0,%d3
    movew %d3,%d0
    jsr %pc@(LOCBTCB)
    jsr %pc@(BTFLUSH)
    jbne VBTCLOSE_30
    movew %d3,%d0
    moveq #1,%d1
    moveal %a4@(8),%a1
    jsr %pc@(FLUSHCACHE)
    jbne VBTCLOSE_30
    moveal %a4,%a0
    _DisposPtr
    moveal FCBSPtr,%a4
    clrl %a4@(0x22,%d3:w)
    clrw %d0
VBTCLOSE_30:            /* restore, return */
    moveml %fp@+,%d1-%d4/%a0-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* BTDELETE: delete a record. */
BTDELETE:
    movel 0x734,%sp@-	/* through the vector at 0x734 (normally VBTDELETE; patchable) */
    rts

/* VBTDELETE: vectored entry: delete a record. */
trap_VBTDELETE:
VBTDELETE:              /* (d0 = file, a0 = key) */
    movel %sp@+,%fp@-
    moveml %d1-%d5/%a0-%a4,%fp@-
    jbsr VBTUPDATE_34
    clrl %a4@(18)
    subal %a2,%a2
    subal %a3,%a3
    jsr %pc@(TREESEARCH)
    moveal %a1,%a3
    jbne VBTDELETE_192
    movew %d1,%d5
VBTDELETE_1E:           /* delete the record from the node */
    moveal %a3,%a1
    movew %d5,%d1
    jsr %pc@(DELETEREC)
    moveal %a3,%a0
    jsr %pc@(MARKBLOCK)
    tstw %d5
    jbne VBTDELETE_34
    bset #6,%a4@
VBTDELETE_34:           /* a leaf: one record less */
    cmpib #0xff,%a3@(8)
    jbne VBTDELETE_40
    subql #1,%a4@(30)
VBTDELETE_40:           /* the node is now empty: unlink it from its siblings, free it */
    tstw %a3@(10)
    jbgt VBTDELETE_BE
    moveal %a3,%a0
    jsr %pc@(GETLTSIB)
    jbne VBTDELETE_192
    tstl %d1
    jbeq VBTDELETE_5E
    movel %a3@,%a1@
    moveq #4,%d1
    moveal %a1,%a0
    jsr %pc@(RELNODE)
VBTDELETE_5E:           /* the right sibling */
    moveal %a3,%a0
    jsr %pc@(GETRTSIB)
    jbne VBTDELETE_192
    tstl %d1
    jbeq VBTDELETE_7A
    movel %a3@(4),%a1@(4)
    moveq #4,%d1
    moveal %a1,%a0
    jsr %pc@(RELNODE)
VBTDELETE_7A:           /* the first / last leaf may change */
    cmpib #0xff,%a3@(8)
    jbne VBTDELETE_96
    tstl %a3@(4)
    jbne VBTDELETE_8C
    movel %a3@,%a4@(34)
VBTDELETE_8C:           /* last leaf */
    tstl %a3@
    jbne VBTDELETE_96
    movel %a3@(4),%a4@(38)
VBTDELETE_96:           /* free the node; its parent's record must go too */
    moveal %a3,%a0
    jsr %pc@(CLRNODE)
    moveq #4,%d1
    jsr %pc@(RELNODE)
    subal %a3,%a3
    movew %a4@(16),%d0
    jsr %pc@(LOCTPR)
    movel %a0@,%d1
    movew %a4@(2),%d0
    jsr %pc@(FREENODE)
    bset #4,%a4@
    bclr #6,%a4@
VBTDELETE_BE:           /* up one level: the first key changed or a child was freed? */
    subqw #1,%a4@(16)
    jbeq VBTDELETE_136
    btst #6,%a4@
    jbne VBTDELETE_D2
    btst #4,%a4@
    jbeq VBTDELETE_18C
VBTDELETE_D2:           /* the parent node: update its key for this child */
    movew %a4@(16),%d0
    jsr %pc@(LOCTPR)
    movew %a0@(4),%d5
    movel %a0@,%d2
    moveq #0,%d1
    jsr %pc@(GETNODE)
    jbne VBTDELETE_192
    moveal %a0,%a2
    btst #6,%a4@
    jbeq VBTDELETE_118
    movew %d5,%d0
    moveal %a2,%a1
    jsr %pc@(GETRECA)
    movel %a0,%sp@-
    moveal %a3,%a1
    clrw %d0
    jsr %pc@(GETRECA)
    moveal %sp@+,%a1
    jsr %pc@(UPDIKEY)
    moveal %a2,%a0
    jsr %pc@(MARKBLOCK)
    tstw %d5
    jbeq VBTDELETE_118
    bclr #6,%a4@
VBTDELETE_118:          /* continue upward (delete the parent's record if the child was freed) */
    moveq #0,%d1
    moveal %a3,%a0
    jsr %pc@(RELNODE)
    moveal %a2,%a3
    movel %d2,%d3
    bclr #4,%a4@
    jbeq VBTDELETE_12E
    jbra VBTDELETE_1E
VBTDELETE_12E:          /* key change only */
    btst #6,%a4@
    jbne VBTDELETE_BE
    jbra VBTDELETE_18C
VBTDELETE_136:          /* at the root: an empty tree? */
    movel %a3,%d0
    jbne VBTDELETE_144
    clrw %a4@(24)
    clrl %a4@(26)
    jbra VBTDELETE_18C
VBTDELETE_144:          /* a root index node with a single child: the child becomes the root (depth - 1) */
    cmpiw #1,%a3@(10)
    jbgt VBTDELETE_18C
    tstb %a3@(8)
    jbne VBTDELETE_18C
    subqw #1,%a4@(24)
    moveq #0,%d1
    moveal %a3,%a1
    jsr %pc@(LOCREC)
    movel %a1@,%a4@(26)
    moveal %a3,%a0
    jsr %pc@(CLRNODE)
    moveq #4,%d1
    jsr %pc@(RELNODE)
    subal %a3,%a3
    movel %d3,%d1
    movew %a4@(2),%d0
    jsr %pc@(FREENODE)
    movel %a4@(26),%d3
    movel %d3,%d2
    moveq #0,%d1
    jsr %pc@(GETNODE)
    jbne VBTDELETE_192
    moveal %a0,%a3
    jbra VBTDELETE_144
VBTDELETE_18C:          /* the header is dirty */
    bset #7,%a4@
    clrw %d0
VBTDELETE_192:          /* release the node, return */
    movew %d0,%fp@-
    moveal %a3,%a0
    moveq #0,%d1
    jsr %pc@(RELNODE)
    movew %fp@+,%d0
    jbsr VBTUPDATE_26
    moveml %fp@+,%d1-%d5/%a0-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* BTFLUSH: write the B-tree header. */
BTFLUSH:
    movel 0x738,%sp@-	/* through the vector at 0x738 (normally VBTFLUSH; patchable) */
    rts

/* VBTFLUSH: vectored entry: write the B-tree header. */
trap_VBTFLUSH:
VBTFLUSH:               /* (d0 = file: write the header record back into node 0 if dirty, flush the file's nodes) */
    movel %sp@+,%fp@-
    moveml %d1-%d4/%a0-%a4,%fp@-
    movew %d0,%d3
    moveal FCBSPtr,%a1
    moveal %a1@(0x14,%d3:w),%a2
    tstw %a2@(72)
    jbeq VBTFLUSH_54
    jsr %pc@(LOCBTCB)
    bclr #7,%a4@
    jbeq VBTFLUSH_48
    moveq #0,%d1
    moveq #0,%d2
    jsr %pc@(GETNODE)
    jbne VBTFLUSH_54
    moveal %a0,%a3
    movew #29,%d0
    lea %a4@(24),%a0
    lea %a3@(14),%a1
VBTFLUSH_38:            /* copy the header record (30 bytes) */
    moveb %a0@+,%a1@+
    dbf %d0,VBTFLUSH_38
    moveq #4,%d1
    moveal %a3,%a0
    jsr %pc@(RELNODE)
    jbne VBTFLUSH_54
VBTFLUSH_48:            /* flush the cache */
    movew %d3,%d0
    moveq #0,%d1
    moveal %a4@(8),%a1
    jsr %pc@(FLUSHCACHE)
VBTFLUSH_54:            /* restore, return */
    moveml %fp@+,%d1-%d4/%a0-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* BTGETRECORD: next/previous record. */
BTGETRECORD:
    movel 0x73c,%sp@-	/* through the vector at 0x73C (normally VBTGETRECORD; patchable) */
    rts

/* VBTGETRECORD: vectored entry: next/previous record. */
trap_VBTGETRECORD:
VBTGETRECORD:           /* (d1 = -1 previous, 0 current, 1 next, relative to the last record found) */
    movel %sp@+,%fp@-
    moveml %d3-%d5/%a2-%a4,%fp@-
    jbsr VBTUPDATE_34
    movew %d1,%d5
    subal %a3,%a3
    movew %a4@(22),%d4
    movel %a4@(18),%d3
    jbne VBTGETRECORD_1C
    moveq #32,%d0
    jbra VBTGETRECORD_70
VBTGETRECORD_1C:        /* the record wanted */
    addw %d5,%d4
VBTGETRECORD_1E:        /* its node */
    jbsr VBTGETRECORD_8A
    jbne VBTGETRECORD_70
VBTGETRECORD_22:        /* in this node? else the next or previous leaf */
    tstw %d4
    jblt VBTGETRECORD_3E
    movew %a3@(10),%d1
    cmpw %d1,%d4
    jblt VBTGETRECORD_5E
    movel %a3@,%d0
    jbeq VBTGETRECORD_38
    movel %d0,%d3
    subw %d1,%d4
    jbra VBTGETRECORD_1E
VBTGETRECORD_38:        /* past the last leaf */
    movew %d1,%d4
    subqw #1,%d4
    jbra VBTGETRECORD_52
VBTGETRECORD_3E:        /* before this node: the previous leaf */
    movel %a3@(4),%d0
    jbeq VBTGETRECORD_50
    movel %d0,%d3
    jbsr VBTGETRECORD_8A
    jbne VBTGETRECORD_70
    addw %a3@(10),%d4
    jbra VBTGETRECORD_22
VBTGETRECORD_50:        /* before the first */
    moveq #0,%d4
VBTGETRECORD_52:        /* end: 32 */
    movel %d3,%a4@(18)
    movew %d4,%a4@(22)
    moveq #32,%d0
    jbra VBTGETRECORD_70
VBTGETRECORD_5E:        /* found: a0 = key, a1 = data, d1 = size; remember it */
    movew %d4,%d1
    moveal %a3,%a1
    jsr %pc@(LOCREC)
    movel %d3,%a4@(18)
    movew %d4,%a4@(22)
    clrw %d0
VBTGETRECORD_70:        /* release the node, return */
    moveml %d0-%d1/%a0-%a1,%fp@-
    jbsr VBTGETRECORD_A0
    moveml %fp@+,%d0-%d1/%a0-%a1
    movel %d3,%d2
    jbsr VBTUPDATE_26
    moveml %fp@+,%d3-%d5/%a2-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

VBTGETRECORD_8A:        /* get node d3 */
    movel %sp@+,%fp@-
    jbsr VBTGETRECORD_A0
    moveq #0,%d1
    movel %d3,%d2
    jsr %pc@(GETNODE)
    jbne VBTGETRECORD_9A
    moveal %a0,%a3
VBTGETRECORD_9A:        /* return */
    movel %fp@+,%sp@-
    tstw %d0
    rts

VBTGETRECORD_A0:        /* release the current node */
    movel %sp@+,%fp@-
    moveq #0,%d1
    moveal %a3,%a0
    jsr %pc@(RELNODE)
    subal %a3,%a3
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* BTINSERT: insert a record (splitting and rotating nodes). */
BTINSERT:
    movel 0x740,%sp@-	/* through the vector at 0x740 (normally VBTINSERT; patchable) */
    rts

/* VBTINSERT: vectored entry: insert a record (splitting and rotating nodes). */
trap_VBTINSERT:
VBTINSERT:              /* (d0 = file, a0 = key, a1 = data, d1 = its size) */
    movel %sp@+,%fp@-
    moveml %d1/%d3-%a4,%fp@-
    jsr %pc@(LOCBTCB)
    movel %a1,%d7
    movew %d1,%d6
    movel %a0,%d5
    moveq #1,%d3
    addw %a4@(24),%d3
    cmpl %a4@(50),%d3
    jble VBTINSERT_2A
VBTINSERT_1C:           /* make sure there are enough free nodes (depth + 1): extend the file */
    jsr %pc@(EXTBTFILE)
    jbne VBTINSERT_290
    cmpl %a4@(50),%d3
    jbgt VBTINSERT_1C
VBTINSERT_2A:           /* the record (key padded to even + data) in the work buffer */
    movew %a4@(2),%d0
    jbsr VBTUPDATE_34
    moveml %d6-%d7,%fp@-
    moveq #0,%d4
    subal %a2,%a2
    subal %a3,%a3
    clrl %a4@(18)
    moveal %a4@(12),%a1
    lea %a1@(48),%a1
    moveal %d5,%a0
    moveq #0,%d0
    moveb %a0@,%d0
    addql #2,%d0
    lsrl #1,%d0
    lsll #1,%d0
    addw %d0,%d6
    _BlockMove
    addqw #1,%d6
    lsrw #1,%d6
    lslw #1,%d6
    movel %a1,%d7
    jsr %pc@(TREESEARCH)
    moveal %a1,%a3
    jbne VBTINSERT_6E
    moveq #33,%d0
    jbra VBTINSERT_26A
VBTINSERT_6E:           /* not there: insert; an empty tree gets a root leaf */
    cmpiw #32,%d0
    jbne VBTINSERT_26A
    movel %d2,%d3
    movew %d1,%d5
    tstw %a4@(16)
    jbgt VBTINSERT_BA
    movew %a4@(2),%d0
    jsr %pc@(BTALLOC)
    jbne VBTINSERT_26A
    movel %d1,%d3
    jsr %pc@(INITNODE)
    jbne VBTINSERT_26A
    moveal %a0,%a3
    moveb #0xff,%a3@(8)
    moveq #1,%d0
    moveb %d0,%a3@(9)
    movew %d0,%a4@(24)
    movel %d3,%a4@(26)
    movel %d3,%a4@(34)
    movel %d3,%a4@(38)
    movew #1,%a4@(16)
VBTINSERT_BA:           /* insert into the node */
    moveal %d7,%a0
    movew %d6,%d0
    moveal %a3,%a1
    movew %d5,%d1
    jsr %pc@(INSERTREC)
    jbne VBTINSERT_D2
    tstw %d5
    jbne VBTINSERT_114
    bset #6,%a4@
    jbra VBTINSERT_114
VBTINSERT_D2:           /* full: move records to the left sibling (BTMAINT1, ROTATELT) or split it (SPLITLT) */
    moveal %a3,%a0
    jsr %pc@(GETLTSIB)
    jbne VBTINSERT_26A
    tstl %d1
    jbeq VBTINSERT_F2
    movel %d1,%d2
    moveal %a1,%a2
    moveal %d7,%a0
    movew %d6,%d0
    movew %d5,%d1
    jsr %pc@(BTMAINT1)
    jbne VBTINSERT_F2
    jbra VBTINSERT_108
VBTINSERT_F2:           /* split */
    moveal %d7,%a0
    movew %d6,%d0
    movew %d5,%d1
    jsr %pc@(SPLITLT)
    jbeq VBTINSERT_104
    moveq #35,%d0
    jbra VBTINSERT_26A
VBTINSERT_104:          /* split: a new node to link in the parent */
    bset #5,%a4@
VBTINSERT_108:          /* the first key may have changed */
    bset #6,%a4@
    movew %d1,%d5
    moveal %a2,%a0
    jsr %pc@(MARKBLOCK)
VBTINSERT_114:          /* a leaf: one more record; remember where it went */
    moveal %a3,%a0
    jsr %pc@(MARKBLOCK)
    cmpib #0xff,%a1@(8)
    jbne VBTINSERT_13E
    moveml %fp@,%d0/%a0
    jsr %pc@(UPDDREC)
    addql #1,%a4@(30)
    movew %d5,%a4@(22)
    movel %d3,%d0
    cmpal %a3,%a1
    jbeq VBTINSERT_13A
    movel %d2,%d0
VBTINSERT_13A:          /* its node */
    movel %d0,%a4@(18)
VBTINSERT_13E:          /* up the path while keys change or nodes split */
    btst #6,%a4@
    jbne VBTINSERT_14C
    btst #5,%a4@
    jbeq VBTINSERT_264
VBTINSERT_14C:          /* the parent node */
    subqw #1,%a4@(16)
    jbeq VBTINSERT_1E6
    movew %a4@(16),%d0
    jsr %pc@(LOCTPR)
    movew %a0@(4),%d5
    movel %a0@,%d3
    movel %d2,%fp@-
    moveq #0,%d1
    movel %d3,%d2
    jsr %pc@(GETNODE)
    jbne VBTINSERT_26A
    movel %a0,%d4
    movel %fp@+,%d2
    btst #6,%a4@
    jbeq VBTINSERT_1A0
    movew %d5,%d0
    moveal %d4,%a1
    jsr %pc@(GETRECA)
    movel %a0,%sp@-
    moveal %a3,%a1
    clrw %d0
    jsr %pc@(GETRECA)
    moveal %sp@+,%a1
    jsr %pc@(UPDIKEY)
    moveal %d4,%a0
    jsr %pc@(MARKBLOCK)
    tstw %d5
    jbeq VBTINSERT_1A0
    bclr #6,%a4@
VBTINSERT_1A0:          /* insert the new node's key in the parent */
    moveq #0,%d1
    moveal %a3,%a0
    jsr %pc@(RELNODE)
    moveal %d4,%a3
    moveq #0,%d4
    btst #5,%a4@
    jbeq VBTINSERT_1BA
    moveal %a2,%a1
    movel %d2,%d0
    jsr %pc@(BTMAINT2)
VBTINSERT_1BA:          /* on up */
    moveq #0,%d1
    moveal %a2,%a0
    jsr %pc@(RELNODE)
    subal %a2,%a2
    btst #5,%a4@
    jbeq VBTINSERT_13E
    moveal %a4@(12),%a0
    lea %a0@(48),%a0
    movel %a0,%d7
    jsr %pc@(GETMAXKEY)
    addqw #4,%d0
    movew %d0,%d6
    bclr #5,%a4@
    jbra VBTINSERT_BA
VBTINSERT_1E6:          /* the root split: a new root with two records (depth + 1) */
    btst #5,%a4@
    jbeq VBTINSERT_264
    movew %a4@(2),%d0
    jsr %pc@(BTALLOC)
    jbne VBTINSERT_26A
    movel %d1,%d3
    movel %d3,%d1
    jsr %pc@(INITNODE)
    jbne VBTINSERT_26A
    movel %a0,%d4
    clrb %a0@(8)
    moveq #1,%d0
    addw %a4@(24),%d0
    moveb %d0,%a0@(9)
    moveal %a2,%a1
    movel %d2,%d0
    jsr %pc@(BTMAINT2)
    jsr %pc@(GETMAXKEY)
    addqw #4,%d0
    moveal %a4@(12),%a0
    lea %a0@(48),%a0
    moveal %d4,%a1
    clrw %d1
    jsr %pc@(INSERTREC)
    movew #1,%d0
    jsr %pc@(LOCTPR)
    movel %a0@,%d0
    moveal %a3,%a1
    jsr %pc@(BTMAINT2)
    jsr %pc@(GETMAXKEY)
    addqw #4,%d0
    moveal %a4@(12),%a0
    lea %a0@(48),%a0
    moveal %d4,%a1
    movew #1,%d1
    jsr %pc@(INSERTREC)
    moveal %d4,%a0
    jsr %pc@(MARKBLOCK)
    addqw #1,%a4@(24)
    movel %d3,%a4@(26)
VBTINSERT_264:          /* the header is dirty */
    bset #7,%a4@
    clrw %d0
VBTINSERT_26A:          /* release the nodes, return */
    movew %d0,%fp@-
    moveal %a2,%a0
    moveq #0,%d1
    jsr %pc@(RELNODE)
    moveal %a3,%a0
    jsr %pc@(RELNODE)
    moveal %d4,%a0
    jsr %pc@(RELNODE)
    movew %fp@+,%d0
    movel %a4@(18),%d2
    clrl %a4@(18)
    jbsr VBTUPDATE_26
    addql #8,%fp
VBTINSERT_290:          /* return */
    moveml %fp@+,%d1/%d3-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* BTOPEN: open a B-tree file (control block). */
BTOPEN:
    movel 0x744,%sp@-	/* through the vector at 0x744 (normally VBTOPEN; patchable) */
    rts

/* VBTOPEN: vectored entry: open a B-tree file (control block). */
trap_VBTOPEN:
VBTOPEN:                /* (d0 = FCB, a0 = key compare, a1 = cache: a new BTCB, the header record checked and copied) */
    movel %sp@+,%fp@-
    moveml %d1-%d5/%a0-%a4,%fp@-
    movew %d0,%d3
    movel %a0,%d4
    movel %a1,%d5
    moveq #54,%d0	/* a 54-byte BTCB (_NewPtr) */
    .short  0xA71E	| 40813612 _NewPtr (flags 0x0700)
    jbne VBTOPEN_A8
    moveal %a0,%a4
    moveal FCBSPtr,%a3
    movel %a4,%a3@(0x22,%d3:w)
    movew %d3,%a4@(2)
    movel %d4,%a4@(4)
    movel %d5,%a4@(8)
    movew %d3,%d0
    moveal %d5,%a1
    moveq #0,%d1
    moveq #0,%d2
    jsr %pc@(GETBLOCK)
    jbne VBTOPEN_A8
    moveal %a0,%a2
    lea %a2@(14),%a0
    movew %a0@(18),%d0	/* node size: a multiple of 512 */
    jbeq VBTOPEN_7E
    movew %d0,%d1
    andiw #511,%d1
    jbne VBTOPEN_7E
    movel %a3@(0xc,%d3:w),%d2
    divuw %d0,%d2
    swap %d2
    clrw %d2
    swap %d2
    cmpl %a0@(22),%d2
    jbne VBTOPEN_7E
    cmpl %a0@(26),%d2
    jbcs VBTOPEN_7E
    subql #1,%d2
    cmpib #8,%a0@
    jbhi VBTOPEN_7E
    cmpl %a0@(2),%d2
    jbcs VBTOPEN_7E
    cmpl %a0@(10),%d2
    jbcs VBTOPEN_7E
    cmpl %a0@(14),%d2
    jbcc VBTOPEN_82
VBTOPEN_7E:             /* a bad header: 37 */
    moveq #37,%d0
    jbra VBTOPEN_96
VBTOPEN_82:             /* copy the header record (30 bytes) */
    movew #29,%d0
    lea %a2@(14),%a0
    lea %a4@(24),%a1
VBTOPEN_8E:             /* copy */
    moveb %a0@+,%a1@+
    dbf %d0,VBTOPEN_8E
    clrw %d0
VBTOPEN_96:             /* release node 0 */
    movew %d0,%fp@-
    moveal %d5,%a1
    moveq #0,%d1
    moveal %a2,%a0
    jsr %pc@(RELBLOCK)
    jbeq VBTOPEN_A6
    movew %d0,%fp@
VBTOPEN_A6:             /* result */
    movew %fp@+,%d0
VBTOPEN_A8:             /* return */
    moveml %fp@+,%d1-%d5/%a0-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* BTSEARCH: search for a key. */
BTSEARCH:
    movel 0x748,%sp@-	/* through the vector at 0x748 (normally VBTSEARCH; patchable) */
    rts

/* VBTSEARCH: vectored entry: search for a key. */
trap_VBTSEARCH:
VBTSEARCH:              /* (d0 = file, a0 = key, d2 = hint node: out d0 = 0 or 32, a0 = key, a1 = data, d1 = size, d2 = the node; the position is remembered for BTGETRECORD) */
    movel %sp@+,%fp@-
    moveml %d3-%d7/%a2-%a4,%fp@-
    jbsr VBTUPDATE_34
    moveal %a0,%a3
    subal %a2,%a2
    tstl %d2
    jbeq VBTSEARCH_3E
    moveq #0,%d1
    jsr %pc@(GETNODE)
    jbne VBTSEARCH_66
    moveal %a0,%a2
    cmpib #0xff,%a0@(8)
    jbne VBTSEARCH_34
    tstw %a0@(10)
    jble VBTSEARCH_34
    moveal %a3,%a0
    moveal %a2,%a1
    jsr %pc@(SEARCHNODE)
    jbeq VBTSEARCH_4E
VBTSEARCH_34:           /* not in the hinted leaf: release it */
    moveal %a2,%a0
    moveq #0,%d1
    jsr %pc@(RELNODE)
    jbne VBTSEARCH_66
VBTSEARCH_3E:           /* from the root */
    moveal %a3,%a0
VBTSEARCH_40:           /* search the tree */
    jsr %pc@(TREESEARCH)
    moveal %a1,%a2
    jbeq VBTSEARCH_4E
    cmpiw #32,%d0
    jbne VBTSEARCH_78
VBTSEARCH_4E:           /* remember the position; found: locate the record */
    movew %d1,%d5
    movew %d0,%fp@-
    movel %d2,%a4@(18)
    movew %d5,%a4@(22)
    tstw %fp@
    jbne VBTSEARCH_66
    movew %d5,%d0
    moveal %a2,%a1
    jsr %pc@(LOCREC)
VBTSEARCH_66:           /* release the node */
    moveml %d1-%d2/%a0-%a1,%fp@-
    moveal %a2,%a0
    moveq #0,%d1
    jsr %pc@(RELNODE)
    moveml %fp@+,%d1-%d2/%a0-%a1
    movew %fp@+,%d0
VBTSEARCH_78:           /* return */
    jbsr VBTUPDATE_26
    moveml %fp@+,%d3-%d7/%a2-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* BTUPDATE: update a record in place. */
BTUPDATE:
    movel 0x74c,%sp@-	/* through the vector at 0x74C (normally VBTUPDATE; patchable) */
    rts

/* VBTUPDATE: vectored entry: update a record in place. */
trap_VBTUPDATE:
VBTUPDATE:              /* (the record last found: its node marked dirty and released) */
    movel %sp@+,%fp@-
    moveml %d1/%a0-%a1/%a4,%fp@-
    jsr %pc@(LOCBTCB)
    moveq #2,%d1
    jsr %pc@(GETNODE)
    jbne VBTUPDATE_1C
    moveq #4,%d1
    jsr %pc@(RELNODE)
    jbne VBTUPDATE_1C
    clrw %d0
VBTUPDATE_1C:           /* return */
    moveml %fp@+,%d1/%a0-%a1/%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

VBTUPDATE_26:           /* free the work buffers on the a6 stack */
    movel %d0,%sp@-
    jbsr VBTUPDATE_52
    addal %d0,%fp
    clrl %a4@(12)
    movel %sp@+,%d0
    rts

VBTUPDATE_34:           /* the BTCB of file d0; work buffers on the a6 stack (52 + the key length); clear the maintenance flags */
    movel %d0,%sp@-
    jsr %pc@(LOCBTCB)
    jbsr VBTUPDATE_52
    subal %d0,%fp
    movel %fp,%a4@(12)
    bclr #5,%a4@
    bclr #4,%a4@
    bclr #6,%a4@
    movel %sp@+,%d0
    rts

VBTUPDATE_52:           /* d0 = the buffers' size */
    jsr %pc@(GETMAXKEY)
    addiw #52,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408137A2

/* BTALLOC: B-tree node allocation. */

/* ALLOCNODE: allocate a node (in the B-tree bitmap). */
BTALLOC:
ALLOCNODE:
    movel 0x758,%sp@-	/* through the vector at 0x758 (normally VALLOCNODE; patchable) */
    rts

/* VALLOCNODE: vectored entry: allocate a node (in the B-tree bitmap). */
trap_VALLOCNODE:
VALLOCNODE:             /* (a free node from the map records of the header / map nodes: d1 = its number; 34 if the file is full) */
    movel %sp@+,%fp@-
    moveml %d2-%d4/%a2-%a3,%fp@-
    moveq #0,%d4
    subal %a2,%a2
VALLOCNODE_A:           /* next map record */
    jbsr VFREENODE_48
    jbeq VALLOCNODE_1A
    cmpiw #32,%d0
    jbne VALLOCNODE_86
    moveq #34,%d0
    jbra VALLOCNODE_86
VALLOCNODE_1A:          /* a long with a clear bit? */
    movew %d1,%d2
    lsrw #2,%d2
    subqw #1,%d2
    moveal %a1,%a0
VALLOCNODE_22:          /* next long */
    movel %a0@+,%d0
    cmpil #-1,%d0
    jbne VALLOCNODE_38
    dbf %d2,VALLOCNODE_22
    extl %d1
    lsll #3,%d1
    addl %d1,%d4
    jbra VALLOCNODE_A
VALLOCNODE_38:          /* the first clear bit */
    movew #31,%d2
VALLOCNODE_3C:          /* next bit */
    btst %d2,%d0
    jbeq VALLOCNODE_44
    dbf %d2,VALLOCNODE_3C
VALLOCNODE_44:          /* set it: the node number */
    bset %d2,%d0
    movel %d0,%d3
    lea %a0@(-4),%a0
    moveal %a0,%a3
    subal %a1,%a0
    movel %a0,%d1
    lsll #3,%d1
    addil #31,%d1
    extl %d2
    subl %d2,%d1
    addl %d4,%d1
    movel %a4@(46),%d0
    cmpl %d1,%d0
    jbgt VALLOCNODE_70
    jbsr VFREENODE_92
    moveq #34,%d0
    jbra VALLOCNODE_86
VALLOCNODE_70:          /* one free node less; the header dirty */
    movel %d3,%a3@
    moveal %a2,%a0
    jsr %pc@(MARKBLOCK)
    subql #1,%a4@(50)
    bset #7,%a4@
    clrw %d0
    jbsr VFREENODE_92
VALLOCNODE_86:          /* return */
    moveml %fp@+,%d2-%d4/%a2-%a3
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* EXTBTFILE: extend the B-tree file. */
EXTBTFILE:
    movel 0x760,%sp@-	/* through the vector at 0x760 (normally VEXTBTFILE; patchable) */
    rts

/* VEXTBTFILE: vectored entry: extend the B-tree file. */
trap_VEXTBTFILE:
VEXTBTFILE:             /* (extend the B-tree file by its clump; mark the new nodes in the map, adding a map node if the map is too short) */
    movel %sp@+,%fp@-
    moveml %d2-%d6/%a2,%fp@-
    movew %a4@(2),%d1
    moveal FCBSPtr,%a1
    moveal %a1@(0x14,%d1:w),%a2
    moveq #0,%d3
    movel %a1@(0x1e,%d1:w),%d4
    jsr %pc@(EXTENDFILE)
    jbeq VEXTBTFILE_2C
    cmpiw #-34,%d0
    jbne VEXTBTFILE_DE
    tstl %d6
    jbeq VEXTBTFILE_DE
VEXTBTFILE_2C:          /* the new node count */
    movel %a4@(46),%d3
    movel %d3,%d4
    movel %a1@(0xc,%d1:w),%d5
    divuw %a4@(42),%d5
    swap %d5
    clrw %d5
    swap %d5
    movel %d5,%a4@(46)
    subql #1,%d5
    movel %d5,%d6
    subal %a2,%a2
VEXTBTFILE_4A:          /* walk the map records */
    jbsr VFREENODE_48
    jbne VEXTBTFILE_DE
    extl %d1
    lsll #3,%d1
    subl %d1,%d3
    subl %d1,%d5
    jbge VEXTBTFILE_60
    subql #1,%d4
    jbra VEXTBTFILE_C6
VEXTBTFILE_60:          /* the last map node: link a new map node from it */
    tstl %a2@
    jbne VEXTBTFILE_4A
    movel %d4,%a2@
    tstl %d3
    jbge VEXTBTFILE_80
    addl %d1,%d3
    divuw #8,%d3
    movew %d3,%d0
    clrw %d3
    swap %d3
    moveq #7,%d1
    subl %d3,%d1
    bset %d1,%a1@(0x0,%d0:w)
    moveq #-1,%d3
VEXTBTFILE_80:          /* the new map node: type 2, one record */
    moveal %a2,%a0
    jsr %pc@(MARKBLOCK)
    jbsr VFREENODE_92
    jbne VEXTBTFILE_DE
    movel %d4,%d1
    jsr %pc@(INITNODE)
    jbne VEXTBTFILE_DE
    moveal %a0,%a2
    moveb #2,%a2@(8)
    movew #1,%a2@(10)
    movew %a4@(42),%d1
    moveq #-18,%d0
    addw %d1,%d0
    lsrw #2,%d0
    lslw #2,%d0
    addiw #14,%d0
    movew %d0,%a2@(0xfffffffffffffffc,%d1:w)
    tstl %d3
    jblt VEXTBTFILE_C0
    moveb #0x80,%a2@(14)
VEXTBTFILE_C0:          /* mark it dirty */
    moveal %a2,%a0
    jsr %pc@(MARKBLOCK)
VEXTBTFILE_C6:          /* the new free nodes; write the alternate MDB */
    subl %d4,%d6
    addl %d6,%a4@(50)
    bset #7,%a4@
    clrb %d0
    jbsr VFREENODE_92
    st SysCRefCnt
    jbsr VFREENODE_AC
VEXTBTFILE_DE:          /* return */
    moveml %fp@+,%d2-%d6/%a2
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* FREENODE: free a node. */
FREENODE:
    movel 0x75c,%sp@-	/* through the vector at 0x75C (normally VFREENODE; patchable) */
    rts

/* VFREENODE: vectored entry: free a node. */
trap_VFREENODE:
VFREENODE:              /* (node d1 marked free in the map) */
    movel %sp@+,%fp@-
    moveml %d2-%d3/%a2,%fp@-
    movel %d1,%d3
    subal %a2,%a2
VFREENODE_A:            /* the map record holding it */
    jbsr VFREENODE_48
    jbne VFREENODE_3E
    extl %d1
    lsll #3,%d1
    subl %d1,%d3
    jbge VFREENODE_A
    addl %d1,%d3
    divuw #8,%d3
    moveq #0,%d0
    movew %d3,%d0
    clrw %d3
    swap %d3
    moveq #7,%d1
    subl %d3,%d1
    bclr %d1,%a1@(0x0,%d0:w)
    moveal %a2,%a0
    jsr %pc@(MARKBLOCK)
    addql #1,%a4@(50)
    bset #7,%a4@
    clrb %d0
    jbsr VFREENODE_92
VFREENODE_3E:           /* return */
    moveml %fp@+,%d2-%d3/%a2
    movel %fp@+,%sp@-
    tstw %d0
    rts

VFREENODE_48:           /* the next map record: d1 = its size, a1 = it (32 at the end) */
    movel %sp@+,%fp@-
    moveq #0,%d2
    movel %a2,%d0
    jbeq VFREENODE_5E
    movel %a2@,%d2
    jbsr VFREENODE_92
    jbne VFREENODE_8C
    tstl %d2
    jbne VFREENODE_5E
    moveq #32,%d0
    jbra VFREENODE_8C
VFREENODE_5E:           /* the header node (record 2) or a map node (record 0) */
    moveq #0,%d1
    jsr %pc@(GETNODE)
    jbne VFREENODE_8C
    moveal %a0,%a2
    moveq #0,%d0
    cmpib #1,%a2@(8)
    jbne VFREENODE_74
    moveq #2,%d0
VFREENODE_74:           /* its size */
    moveal %a2,%a1
    jsr %pc@(GETRECA)
    movel %a0,%d1
    movew %a2@(10),%d0
    jsr %pc@(GETRECA)
    moveal %d1,%a1
    subal %a1,%a0
    movew %a0,%d1
    clrw %d0
VFREENODE_8C:           /* return */
    movel %fp@+,%sp@-
    tstw %d0
    rts

VFREENODE_92:           /* release the map node */
    movel %sp@+,%fp@-
    moveml %d1/%a0-%a1,%fp@-
    moveq #0,%d1
    moveal %a2,%a0
    jsr %pc@(RELNODE)
    subal %a2,%a2
    moveml %fp@+,%d1/%a0-%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

VFREENODE_AC:           /* update the alternate MDB (VUPDALTMDB) */
    movel 0x7b4,%sp@-	/* through the vector at 0x7B4 (normally VUPDALTMDB; patchable) */
    rts

/*
 VUPDALTMDB: after a B-tree file grows, copy its new size and extents into the alternate
 MDB (the second-to-last block of the volume; its position from the drive's size, or
 the partition information of a SCSI drive).
*/
trap_VUPDALTMDB:
VUPDALTMDB:
    movel %sp@+,%fp@-
    moveml %d0-%d2/%a0-%a3/%a5,%fp@-
    movew %a4@(2),%d1
    moveal FCBSPtr,%a5
    lea %a5@(0x0,%d1:w),%a5
    moveal %a5@(20),%a2
    movew %a2@(72),%d2
    jsr %pc@(FINDDRIVE)
    jbne VUPDALTMDB_EA
    moveml %d0-%d1/%a0/%a2,%sp@-
    subaw #128,%sp
    moveal %sp,%a2
    moveq #24,%d0
VUPDALTMDB_2E:          /* a parameter block on the stack */
    clrw %sp@-
    dbf %d0,VUPDALTMDB_2E
    moveal %sp,%a0
    moveq #0,%d2
    movew %a3@(12),%d2
    cmpiw #-5,%a3@(8)
    jbne VUPDALTMDB_8C
    movew %a3@(6),%a0@(22)
    movew %a3@(8),%a0@(24)
    movew #6,%a0@(26)
    movew #16,%a0@(28)
    movel %a2,%a0@(30)
    _Status
    jbne VUPDALTMDB_80
    movew %a0@(28),%d0
    jbeq VUPDALTMDB_80
    subqw #1,%d0
VUPDALTMDB_6C:          /* (Status 6: partition information) the HFS partition's size */
    btst #6,%a2@(4)
    jbne VUPDALTMDB_7C
    addqw #8,%a2
    dbf %d0,VUPDALTMDB_6C
    jbra VUPDALTMDB_80
VUPDALTMDB_7C:          /* its size */
    movel %a2@,%d2
    jbra VUPDALTMDB_98
VUPDALTMDB_80:          /* a floppy: 800 or 1600 blocks */
    movew #800,%d2
    tstb %a3@(12)
    jbeq VUPDALTMDB_8C
    addl %d2,%d2
VUPDALTMDB_8C:          /* the drive queue's size */
    tstw %a3@(4)
    jbeq VUPDALTMDB_98
    movel %a3@(12),%d2
    swap %d2
VUPDALTMDB_98:          /* block size - 2: the alternate MDB */
    lea %sp@(178),%sp
    moveml %sp@+,%d0-%d1/%a0/%a2
    subql #2,%d2
    movew %a2@(78),%d0
    moveq #1,%d1
    moveal %a4@(8),%a1
    jsr %pc@(GETBLOCK)
    jbne VUPDALTMDB_EA
    moveq #2,%d1
    cmpiw #16964,%a0@
    jbne VUPDALTMDB_E6
    lea %a0@(146),%a3
    moveq #4,%d0
    cmpl %a5@,%d0
    jbeq VUPDALTMDB_CE
    moveq #3,%d0
    cmpl %a5@,%d0
    jbne VUPDALTMDB_E6
    lea %a0@(130),%a3
VUPDALTMDB_CE:          /* the extents file (+130) or catalog file (+146) entries */
    movel %a5@(12),%a3@+
    moveq #2,%d0
    lea %a5@(38),%a1
VUPDALTMDB_D8:          /* copy the extent record */
    movel %a1@+,%a3@+
    dbf %d0,VUPDALTMDB_D8
    movel Time,%a0@(6)
    moveq #1,%d1
VUPDALTMDB_E6:          /* release it */
    jsr %pc@(RELBLOCK)
VUPDALTMDB_EA:          /* return */
    moveml %fp@+,%d0-%d2/%a0-%a3/%a5
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* BTMAINT1: B-tree maintenance. */

/*
 BTMAINT1 / ROTATELT: make room for a record (a0, d0 bytes, at d1 in node a3) by moving
 records into the left sibling (a2), balancing the two nodes; -1 if they cannot hold
 it all. SPLITLT: a new left sibling, then the same.
*/
BTMAINT1:
ROTATELT:
    moveml %d2-%d7/%a2-%a5,%sp@-
    moveal %a0,%a5
    movew %d0,%d5
    moveal %a2,%a1
    jsr %pc@(GETNODESIZ)
    movew %d0,%d2
    moveal %a3,%a1
    jsr %pc@(GETNODESIZ)
    addw %d2,%d0
    addw %d5,%d0
    addqw #2,%d0
    lsrw #1,%d0
    movew %d0,%d6
    movew %a2@(10),%d3
    movew %d1,%d4
    addw %d3,%d4
    moveq #-1,%d7
BTMAINT1_2A:            /* sizes, record by record: where to cut */
    cmpw %d3,%d4
    jbne BTMAINT1_32
    addw %d5,%d2
    jbra BTMAINT1_44
BTMAINT1_32:            /* (the new record) */
    movew %d3,%d0
BTMAINT1_34:            /* a record's size */
    subw %a2@(10),%d0
    cmpw %d4,%d3
    jble BTMAINT1_3E
BTMAINT1_3C:            /* (after the insertion point) */
    subqw #1,%d0
BTMAINT1_3E:            /* its size */
    jsr %pc@(GETRECA)
    addw %d0,%d2
BTMAINT1_44:            /* does the left node still fit? */
    addqw #2,%d2
    movew %a4@(42),%d1
    subiw #16,%d1
    cmpw %d1,%d2
    jble BTMAINT1_5E
    swap %d7
    tstw %d7
    jbge BTMAINT1_94
    moveq #-1,%d0
    jbra BTMAINT1_E8
BTMAINT1_5E:            /* the best cut so far */
    movew %d6,%d0
    lslw #1,%d0
    subw %d2,%d0
    cmpw %d1,%d0
    jbgt BTMAINT1_6A
    movew %d3,%d7
BTMAINT1_6A:            /* half reached? */
    cmpw %d6,%d2
    jblt BTMAINT1_7C
    jbeq BTMAINT1_72
    swap %d7
BTMAINT1_72:            /* cut here */
    tstw %d7
    jbge BTMAINT1_94
    swap %d7
    tstw %d7
    jbge BTMAINT1_94
BTMAINT1_7C:            /* next record */
    swap %d7
    movew #-1,%d7
    addqw #1,%d3
    movew %a2@(10),%d1
    addw %a3@(10),%d1
    cmpw %d1,%d3
    jble BTMAINT1_2A
    moveq #-1,%d0
    jbra BTMAINT1_E8
BTMAINT1_94:            /* move records into the left node */
    movew %a2@(10),%d3
BTMAINT1_98:            /* next one: the new record or one from the right node */
    cmpw %d3,%d4
    jbne BTMAINT1_B2
    moveal %a2,%a1
    moveal %a5,%a0
    movew %d5,%d0
    movew %a1@(10),%d1
    jsr %pc@(INSERTREC)
    jbne BTMAINT1_DE
    moveal %a1,%a5
    movew %d1,%d5
    jbra BTMAINT1_BC
BTMAINT1_B2:            /* move the right node's first record */
    moveal %a2,%a0
    moveal %a3,%a1
    jbsr VTREESEARCH_84
    jbne BTMAINT1_DE
BTMAINT1_BC:            /* up to the cut */
    cmpw %d7,%d3
    jbeq BTMAINT1_C4
    addqw #1,%d3
    jbra BTMAINT1_98
BTMAINT1_C4:            /* the new record into the right node */
    cmpw %d7,%d4
    jble BTMAINT1_E2
    moveal %a3,%a1
    moveal %a5,%a0
    movew %d5,%d0
    movew %d4,%d1
    subw %d7,%d1
    subqw #1,%d1
    jsr %pc@(INSERTREC)
    jbne BTMAINT1_DE
    clrw %d0
    jbra BTMAINT1_E8
BTMAINT1_DE:            /* the B-tree is damaged: system error 64 */
    moveq #64,%d0
    _SysError
BTMAINT1_E2:            /* no error: a1/d1 where the new record went */
    clrw %d0
    moveal %a5,%a1
    movew %d5,%d1
BTMAINT1_E8:            /* return */
    moveml %sp@+,%d2-%d7/%a2-%a5
    tstw %d0
    rts

/* SPLITLT: split a node to the left. */
SPLITLT:
    movel %sp@+,%fp@-
    moveml %d3-%d7/%a3,%fp@-
    movel %a0,%d7
    movew %d0,%d6
    movew %d1,%d5
    movew %a4@(16),%d0
    jsr %pc@(LOCTPR)
    movel %a0@,%d4
    movew %a4@(2),%d0
    jsr %pc@(BTALLOC)
    jbne SPLITLT_80
    movel %d1,%d3
    movel %a2,%d0
    jbeq SPLITLT_32
    movel %d3,%a2@
    moveq #4,%d1
    moveal %a2,%a0
    jsr %pc@(RELNODE)
    jbne SPLITLT_80
SPLITLT_32:             /* a new node, linked to the left of a3, at the same height */
    movel %d3,%d1
    jsr %pc@(INITNODE)
    jbne SPLITLT_80
    moveal %a0,%a2
    moveb %a3@(8),%a2@(8)
    movel %a3@(4),%a2@(4)
    movel %d4,%a2@
    movel %d3,%a3@(4)
    moveq #1,%d0
    addw %a4@(24),%d0
    subw %a4@(16),%d0
    moveb %d0,%a2@(9)
    cmpib #0xff,%a2@(8)
    jbne SPLITLT_6E
    tstl %a2@(4)
    jbne SPLITLT_6E
    movel %d3,%a4@(34)
SPLITLT_6E:             /* the first leaf may change */
    moveal %d7,%a0
    movew %d6,%d0
    movew %d5,%d1
    jsr %pc@(BTMAINT1)
    jbeq SPLITLT_7C
    jbra SPLITLT_80
SPLITLT_7C:             /* no error, d2 = the new node */
    clrw %d0
    movel %d3,%d2
SPLITLT_80:             /* return */
    moveml %fp@+,%d3-%d7/%a3
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* TREESEARCH: search the tree from the root to a leaf. */
TREESEARCH:
    movel 0x7cc,%sp@-	/* through the vector at 0x7CC (normally VTREESEARCH; patchable) */
    rts

/* VTREESEARCH: vectored entry: search the tree from the root to a leaf. */
trap_VTREESEARCH:
VTREESEARCH:            /* (from the root down to a leaf, recording the path; d0 = 0 found, 32 not found, a1 = the leaf, d1 = the record or where it would go, d2 = the node) */
    movel %sp@+,%fp@-
    moveml %d3-%d7/%a2-%a3,%fp@-
    movel %a0,%d7
    tstw %a4@(24)
    jbgt VTREESEARCH_1C
    moveq #32,%d0
    subal %a1,%a1
    moveq #0,%d1
    moveq #0,%d2
    clrw %a4@(16)
    jbra VTREESEARCH_7A
VTREESEARCH_1C:         /* level 1: the root */
    moveq #1,%d6
    movel %a4@(26),%d3
VTREESEARCH_22:         /* search this node */
    moveq #0,%d1
    movel %d3,%d2
    jsr %pc@(GETNODE)
    jbne VTREESEARCH_7A
    moveal %a0,%a1
    moveal %d7,%a0
    jsr %pc@(SEARCHNODE)
    movew %d0,%d5
    movew %d1,%d4
    movew %d6,%d0
    jsr %pc@(LOCTPR)
    moveal %a0,%a3
    movel %d3,%a3@
    movew %d4,%d2
    tstw %d5
    jbeq VTREESEARCH_4E
    subqw #1,%d2
    jbge VTREESEARCH_4E
    movew %d4,%d2
VTREESEARCH_4E:         /* the path entry: node, record; down to the child */
    movew %d2,%a3@(4)
    cmpw %a4@(24),%d6
    jbeq VTREESEARCH_70
    movew %d2,%d1
    movel %a1,%sp@-
    jsr %pc@(LOCREC)
    movel %a1@,%d3
    moveal %sp@+,%a1
    moveq #0,%d1
    moveal %a1,%a0
    jsr %pc@(RELNODE)
    addqw #1,%d6
    jbra VTREESEARCH_22
VTREESEARCH_70:         /* at the leaf */
    movew %d6,%a4@(16)
    movew %d4,%d1
    movew %d5,%d0
    movel %d3,%d2
VTREESEARCH_7A:         /* return */
    moveml %fp@+,%d3-%d7/%a2-%a3
    movel %fp@+,%sp@-
    tstw %d0
    rts

VTREESEARCH_84:         /* move the first record of node a1 to the end of node a0 */
    moveml %a2-%a3,%sp@-
    moveal %a0,%a2
    moveal %a1,%a3
    moveq #0,%d0
    jsr %pc@(GETRECA)
    lea %a1@(14),%a0
    moveal %a2,%a1
    movew %a1@(10),%d1
    jsr %pc@(INSERTREC)
    moveal %a3,%a1
    jbeq VTREESEARCH_A8
    moveq #-1,%d0
    jbra VTREESEARCH_B0
VTREESEARCH_A8:         /* delete it from a1 */
    clrw %d1
    jsr %pc@(DELETEREC)
    clrw %d0
VTREESEARCH_B0:         /* return */
    tstw %d0
    moveml %sp@+,%a2-%a3
    rts
    .long   0x00000000, 0x00000000	| 40813D18

/* BTMAINT2: B-tree node utilities. */

/* BUILDIREC: build an index record. */
BTMAINT2:               /* (BUILDIREC: an index record for node d0: its first key and the node number) */
BUILDIREC:
    movel %d2,%sp@-
    movel %d0,%d2
    clrw %d0
    jbsr GETRECA
    moveal %a4@(12),%a1
    lea %a1@(48),%a1
    jsr %pc@(UPDIKEY)
    jbsr GETMAXKEY
    movel %d2,%a1@(0x0,%d0:w)
    movel %sp@+,%d2
    rts

/* CHKNODE: check a node. */
CHKNODE:                /* (a1 = node: its links within the file, a valid type and height, the record count and offsets sensible; else 36) */
    moveml %d1-%d2/%a0-%a2,%sp@-
    movew %a4@(2),%d1
    moveal FCBSPtr,%a2
    movel %a2@(0xc,%d1:w),%d0
    divuw %a4@(42),%d0
    moveq #0,%d1
    movew %d0,%d1
    cmpl %a1@,%d1
    jbls CHKNODE_76
    cmpl %a1@(4),%d1
    jbls CHKNODE_76
    moveb %a1@(8),%d0
    addqb #1,%d0
    cmpib #3,%d0
    jbhi CHKNODE_76
    moveb %a1@(9),%d0
    cmpb %a4@(25),%d0
    jbhi CHKNODE_76
    moveq #0,%d1
    movew %a4@(42),%d1
    moveq #-14,%d0
    addl %d1,%d0
    divuw #6,%d0
    cmpw %a1@(10),%d0
    jbcs CHKNODE_76
    movew %a1@(10),%d1
    movew %d1,%d0
    jbsr GETOFFSET
    moveq #2,%d2
    addl %a0,%d2
    subl %a1,%d2
CHKNODE_5C:             /* each offset: even, at least 14, decreasing */
    movew %a0@+,%d0
    btst #0,%d0
    jbne CHKNODE_76
    cmpiw #14,%d0
    jbcs CHKNODE_76
    cmpw %d2,%d0
    jbcc CHKNODE_76
    movew %d0,%d2
    dbf %d1,CHKNODE_5C
    jbra CHKNODE_7A
CHKNODE_76:             /* a bad node: 36 */
    moveq #36,%d0
    jbra CHKNODE_7C
CHKNODE_7A:             /* good */
    clrw %d0
CHKNODE_7C:             /* return */
    moveml %sp@+,%d1-%d2/%a0-%a2
    tstw %d0
    rts

/* CLRNODE: clear a node. */
CLRNODE:
    moveml %d0-%d1/%a0,%sp@-
    moveq #3,%d1
    addw %a4@(42),%d1
    lsrw #2,%d1
    subqw #1,%d1
    moveq #0,%d0
CLRNODE_10:             /* clear */
    movel %d0,%a0@+
    dbf %d1,CLRNODE_10
    moveml %sp@+,%d0-%d1/%a0
    rts

/* DELETEREC: delete a record from a node. */
DELETEREC:              /* (record d1 of node a1: move the following records down, fix the offsets) */
    moveml %d2-%d6/%a2-%a5,%sp@-
    movew %d1,%d5
    movew %d1,%d0
    jsr %pc@(GETOFFSET)
    movel %a0,%d6
    movew %d0,%d4
    lea %a0@(-2),%a3
    movew %a3@,%d3
    movew %a1@(10),%d0
    jsr %pc@(GETOFFSET)
    moveal %a0,%a2
    movew %d0,%d2
    moveal %a1,%a5
    lea %a5@(0x0,%d3:w),%a0
    lea %a5@(0x0,%d4:w),%a1
    movew %d2,%d0
    subw %d3,%d0
    jsr %pc@(MOVRECLT)
    subqw #1,%a5@(10)
    moveal %a3,%a0
    moveal %d6,%a1
    movew %a5@(10),%d0
    subw %d5,%d0
    movew %d4,%d1
    subw %d3,%d1
    jsr %pc@(MOVOFFRT)
    moveml %sp@+,%d2-%d6/%a2-%a5
    rts

/* GETLTSIB: left sibling. */
GETLTSIB:
    movel %sp@+,%fp@-
    moveml %d2-%d3,%fp@-
    clrb %d3
    jbra GETRTSIB_8

/* GETRTSIB: right sibling. */
GETRTSIB:
    movel %sp@+,%fp@-
    moveml %d2-%d3,%fp@-
    moveq #1,%d3
GETRTSIB_8:             /* (d3: 0 left, 1 right) the sibling's node number */
    tstb %d3
    jbne GETRTSIB_12
    movel %a0@(4),%d2
    jbra GETRTSIB_14
GETRTSIB_12:            /* right */
    movel %a0@,%d2
GETRTSIB_14:            /* none: d1 = 0 */
    jbne GETRTSIB_1A
    moveq #0,%d1
    jbra GETRTSIB_24
GETRTSIB_1A:            /* get it: a1 = it, d1 = its number */
    moveq #0,%d1
    jbsr GETNODE
    jbne GETRTSIB_26
    movel %d2,%d1
    moveal %a0,%a1
GETRTSIB_24:            /* no error */
    clrw %d0
GETRTSIB_26:            /* return */
    moveml %fp@+,%d2-%d3
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* GETMAXKEY: maximum key length. */
GETMAXKEY:              /* (key length + length byte, even) */
    moveq #2,%d0
    addw %a4@(44),%d0
    lsrw #1,%d0
    lslw #1,%d0
    rts

/* GETNODE: get a node through the cache. */
GETNODE:
    movel 0x750,%sp@-	/* through the vector at 0x750 (normally VGETNODE; patchable) */
    rts

/* VGETNODE: vectored entry: get a node through the cache. */
trap_VGETNODE:
VGETNODE:               /* (d2 = node: through the B-tree's cache, checked by CHKNODE; a bad node is released) */
    movel %sp@+,%fp@-
    moveml %d1/%a1,%fp@-
    movew %a4@(2),%d0
    moveal %a4@(8),%a1
    jsr %pc@(GETBLOCK)
    jbne VGETNODE_2A
    moveal %a0,%a1
    jbsr CHKNODE
    jbeq VGETNODE_2A
    movew %d0,%fp@-
    moveq #2,%d1
    moveal %a4@(8),%a1
    jsr %pc@(RELBLOCK)
    movew %fp@+,%d0
VGETNODE_2A:            /* return */
    moveml %fp@+,%d1/%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* GETNODESIZ: node size. */
GETNODESIZ:             /* (bytes used in node a1: records + offsets) */
    movel %d1,%sp@-
    movew %a1@(10),%d1
    movew %d1,%d0
    jsr %pc@(GETOFFSET)
    subiw #14,%d0
    lslw #1,%d1
    addw %d1,%d0
    movel %sp@+,%d1
    rts

/* GETOFFSET: record offset. */
GETOFFSET:              /* (d0 = offset of record d0 in node a1, a0 = where it is stored) */
    jbsr GETOFFSET_6
    movew %a0@,%d0
    rts

GETOFFSET_6:            /* the offsets are at the end of the node, record 0 last */
    subal %a0,%a0
    moveaw %a4@(42),%a0
    addal %a1,%a0
    lslw #1,%d0
    negw %d0
    lea %a0@(0xfffffffffffffffe,%d0:w),%a0
    rts

/* GETRECA: record address. */
GETRECA:                /* (a0 = record d0 of node a1, d0 = its size) */
    moveml %d1-%d2,%sp@-
    movew %d0,%d1
    jbsr GETOFFSET
    movew %d0,%d2
    movew %d1,%d0
    addqw #1,%d0
    jbsr GETOFFSET
    subw %d2,%d0
    lea %a1@(0x0,%d2:w),%a0
    moveml %sp@+,%d1-%d2
    rts

/* INITNODE: initialise a node. */
INITNODE:               /* (node d1: a cleared block, the first record offset 14) */
    movel %sp@+,%fp@-
    moveml %d1-%d2/%a1,%fp@-
    movel %d1,%d2
    movew %a4@(2),%d0
    moveq #4,%d1
    moveal %a4@(8),%a1
    jsr %pc@(GETBLOCK)
    jbne INITNODE_28
    jbsr CLRNODE
    movew %a4@(42),%d2
    movew #14,%a0@(0xfffffffffffffffe,%d2:w)
    clrw %d0
INITNODE_28:            /* return */
    moveml %fp@+,%d1-%d2/%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* INSERTREC: insert a record into a node. */
INSERTREC:              /* (record a0 of d0 bytes at index d1 of node a1; -1 if it does not fit) */
    moveml %d1-%d7/%a1-%a5,%sp@-
    movew %d0,%d7
    movew %d1,%d6
    movel %a0,%d5
    movew %d1,%d0
    jsr %pc@(GETOFFSET)
    movew %d0,%d4
    movew %a1@(10),%d0
    jsr %pc@(GETOFFSET)
    moveal %a0,%a3
    movew %d0,%d3
    movel %a3,%d1
    moveq #0,%d0
    movew %d3,%d0
    addl %a1,%d0
    subl %d0,%d1
    moveq #2,%d0
    addw %d7,%d0
    cmpw %d0,%d1
    jbge INSERTREC_34
    moveq #-1,%d0
    jbra INSERTREC_6A
INSERTREC_34:           /* make room: move the records and offsets after it */
    moveal %a1,%a5
    lea %a5@(0x0,%d4:w),%a0
    lea %a0@(0x0,%d7:w),%a1
    movew %d3,%d0
    subw %d4,%d0
    jsr %pc@(MOVRECRT)
    moveal %a3,%a0
    lea %a0@(-2),%a1
    movew %a5@(10),%d0
    subw %d6,%d0
    movew %d7,%d1
    jsr %pc@(MOVOFFLT)
    moveal %d5,%a0
    lea %a5@(0x0,%d4:w),%a1
    movew %d7,%d0
    jsr %pc@(MOVRECLT)
    addqw #1,%a5@(10)
    clrw %d0
INSERTREC_6A:           /* return */
    moveml %sp@+,%d1-%d7/%a1-%a5
    tstw %d0
    rts

/* LOCBTCB: locate the B-tree control block. */
LOCBTCB:                /* (a4 = the BTCB of FCB d0) */
    moveal FCBSPtr,%a4
    moveal %a4@(0x22,%d0:w),%a4
    rts

/* LOCREC: locate a record in a node. */
LOCREC:                 /* (record d1 of node a1: a0 = key, a1 = data, d1 = data size) */
    moveml %d0/%d2-%d3,%sp@-
    movew %d1,%d3
    movew %d3,%d0
    jsr %pc@(GETRECA)
    movel %a0,%d2
    movew %d3,%d0
    addqw #1,%d0
    jsr %pc@(GETRECA)
    movel %a0,%d1
    moveal %d2,%a0
    moveq #0,%d0
    moveb %a0@,%d0
    addql #2,%d0
    lsrl #1,%d0
    lsll #1,%d0
    subl %d2,%d1
    subl %d0,%d1
    moveal %a0,%a1
    addal %d0,%a1
    moveml %sp@+,%d0/%d2-%d3
    rts

/* LOCTPR: locate the tree path record. */
LOCTPR:                 /* (a0 = the tree path entry of level d0: node, record; 6 bytes each) */
    subqw #1,%d0
    muluw #6,%d0
    moveal %a4@(12),%a0
    lea %a0@(0x0,%d0:l),%a0
    rts

/* MOVOFFLT: move offsets left. */
MOVOFFLT:
    moveml %d0-%d2/%a0-%a1,%sp@-
MOVOFFLT_4:             /* copy, adding d1 */
    movew %a0@+,%d2
    addw %d1,%d2
    movew %d2,%a1@+
    dbf %d0,MOVOFFLT_4
    jbra MOVOFFRT_10

/* MOVOFFRT: move offsets right. */
MOVOFFRT:
    moveml %d0-%d2/%a0-%a1,%sp@-
    cmpmw %a0@+,%a1@+
MOVOFFRT_6:             /* copy backwards, adding d1 */
    movew %a0@-,%d2
    addw %d1,%d2
    movew %d2,%a1@-
    dbf %d0,MOVOFFRT_6
MOVOFFRT_10:            /* restore, return */
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts

/* MOVRECLT: move records left. */
MOVRECLT:
    moveml %d0-%d1/%a0-%a1,%sp@-
    tstw %d0
    jble MOVRECLT_10
    subqw #1,%d0
MOVRECLT_A:             /* copy */
    moveb %a0@+,%a1@+
    dbf %d0,MOVRECLT_A
MOVRECLT_10:            /* return */
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts

/* MOVRECRT: move records right. */
MOVRECRT:
    moveml %d0-%d1/%a0-%a1,%sp@-
    tstw %d0
    jble MOVRECRT_14
    addaw %d0,%a0
    addaw %d0,%a1
    subqw #1,%d0
MOVRECRT_E:             /* copy backwards */
    moveb %a0@-,%a1@-
    dbf %d0,MOVRECRT_E
MOVRECRT_14:            /* return */
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts

/* RELNODE: release a node. */
RELNODE:
    movel 0x754,%sp@-	/* through the vector at 0x754 (normally VRELNODE; patchable) */
    rts

/* VRELNODE: vectored entry: release a node. */
trap_VRELNODE:
VRELNODE:
    movel %sp@+,%fp@-
    movel %a1,%fp@-
    movel %a0,%d0
    jbeq VRELNODE_C
    jsr %pc@(RELBLOCK)
VRELNODE_C:             /* return */
    moveal %fp@+,%a1
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* SEARCHNODE: search a node (binary search). */
SEARCHNODE:             /* (binary search of key a0 in node a1 with the BTCB's compare routine: d0 = 0 found, 32 not; d1 = the record or where it would go) */
    moveml %d2-%d5/%a1-%a3,%sp@-
    moveal %a0,%a3
    moveal %a1,%a2
    movel %a4@(4),%d5
    clrw %d2
    movew %a2@(10),%d3
    subqw #1,%d3
    cmpw %d3,%d2
    jbgt SEARCHNODE_4E
SEARCHNODE_18:          /* the middle record: compare */
    movew %d2,%d4
    addw %d3,%d4
    lsrw #1,%d4
    movew %d4,%d0
    moveal %a2,%a1
    jsr %pc@(GETRECA)
    moveal %a0,%a1
    moveal %a3,%a0
    movel %a4,%sp@-
    moveal %d5,%a4
    jsr %a4@
    moveal %sp@+,%a4
    tstw %d0
    jbeq SEARCHNODE_42
    jbgt SEARCHNODE_46
    movew %d4,%d3
    subqw #1,%d3
    cmpw %d3,%d2
    jble SEARCHNODE_18
    jbra SEARCHNODE_4E
SEARCHNODE_42:          /* found */
    clrw %d0
    jbra SEARCHNODE_52
SEARCHNODE_46:          /* greater: the upper half */
    movew %d4,%d2
    addqw #1,%d2
    cmpw %d3,%d2
    jble SEARCHNODE_18
SEARCHNODE_4E:          /* not found: insertion point */
    movew %d2,%d4
    moveq #32,%d0
SEARCHNODE_52:          /* return */
    movew %d4,%d1
    moveml %sp@+,%d2-%d5/%a1-%a3
    tstw %d0
    rts

/* UPDDREC: update a data record. */
UPDDREC:                /* (copy d0 bytes from a0 into the data of record d1; a0 = 0 clears it) */
    moveml %d0-%d1/%a0-%a2,%sp@-
    moveal %a0,%a2
    jsr %pc@(LOCREC)
    movel %a2,%d1
    jbeq UPDDREC_18
    moveal %d1,%a0
    extl %d0
    _BlockMove
    jbra UPDDREC_1C
UPDDREC_16:             /* clear */
    clrb %a1@+
UPDDREC_18:             /* count */
    dbf %d0,UPDDREC_16
UPDDREC_1C:             /* return */
    moveml %sp@+,%d0-%d1/%a0-%a2
    rts

/* UPDIKEY: update an index key. */
UPDIKEY:                /* (index key a1 = key a0, padded to the B-tree's key length) */
    moveml %d0-%d1/%a0-%a2,%sp@-
    moveal %a0,%a2
    movew %a4@(44),%d1
    moveb %d1,%a1@+
    moveal %a2,%a0
    moveb %a0@+,%d0
    extw %d0
    subw %d0,%d1
    jbge UPDIKEY_1C
    addw %d1,%d0
    jbra UPDIKEY_1C
UPDIKEY_1A:             /* copy */
    moveb %a0@+,%a1@+
UPDIKEY_1C:             /* count */
    dbf %d0,UPDIKEY_1A
    tstw %d1
    jble UPDIKEY_2C
    jbra UPDIKEY_28
UPDIKEY_26:             /* pad */
    clrb %a1@+
UPDIKEY_28:             /* count */
    dbf %d1,UPDIKEY_26
UPDIKEY_2C:             /* return */
    moveml %sp@+,%d0-%d1/%a0-%a2
    rts
    .short  0x0000	| 4081410E

/*
 CACHE: the File Manager's block cache. Each cache (volume, bitmap, control) is a ring of
 buffers, each with a 28-byte header: +0/+4 links, +8 the VCB, +12 the file number,
 +18 the use stamp (LRU), +22 the block, +26 flags (bit 7 dirty, 6 in use, 5 empty),
 +27 the fork. GETBLOCK finds or reads a block (d1 options: 1 read-only, 2 checked,
 4 do not read), RELBLOCK releases it (d1: 2 dirty, 4 write now, 1 trash),
 FLUSHCACHE writes the dirty blocks of a file or volume, TRASHBLOCKS drops them.
 CACHE itself (a file's own buffer) always answers none here.
*/
CACHE:
    moveq #0,%d0
    jbeq CACHE_A
    moveal %d0,%a4
    subaw #28,%a4
CACHE_A:                /* return */
    rts

CACHE_C:                /* write a file's own dirty buffer (none here) */
    jbsr CACHE
    jbeq CACHE_28
    btst #5,%a4@(26)
    jbne CACHE_28
    bclr #7,%a4@(26)
    jbeq CACHE_28
    movel %sp@+,%fp@-
    jsr %pc@(WRITEOWNBUF)
    movel %fp@+,%sp@-
CACHE_28:               /* return */
    rts

/* FLUSHCACHE: write the dirty blocks. */
FLUSHCACHE:
    movel 0x700,%sp@-	/* through the vector at 0x700 (normally VFLUSHCACHE; patchable) */
    rts

/* VFLUSHCACHE: vectored entry: write the dirty blocks. */
trap_VFLUSHCACHE:
VFLUSHCACHE:            /* (a1 = cache, d0 = FCB or -vRefNum, d1 bit 0: also release them; SysCRefCnt 0: the control cache is only flushed when a quarter of it is dirty) */
    movel %sp@+,%fp@-
    moveml %d1-%d6/%a0-%a4,%fp@-
    cmpal SysCtlCPtr,%a1
    jbne VFLUSHCACHE_46
    tstb SysCRefCnt
    jbne VFLUSHCACHE_46
    moveq #0,%d5
    moveal %a1,%a3
    moveal %a3,%a4
VFLUSHCACHE_18:         /* count the blocks in use */
    moveal %a4@,%a4
    cmpal %a3,%a4
    jbeq VFLUSHCACHE_3A
    btst #5,%a4@(26)
    jbne VFLUSHCACHE_36
    btst #6,%a4@(26)
    jbne VFLUSHCACHE_18
    btst #7,%a4@(26)
    jbne VFLUSHCACHE_18
VFLUSHCACHE_36:         /* one more */
    addqw #1,%d5
    jbra VFLUSHCACHE_18
VFLUSHCACHE_3A:         /* few: not now */
    movew %a3@(8),%d6
    lsrw #2,%d6
    cmpw %d6,%d5
    jbhi VFLUSHCACHE_D8
VFLUSHCACHE_46:         /* a file: its VCB, number and fork */
    moveb %d1,%d5
    moveal %a1,%a3
    movew %d0,%d1
    jble VFLUSHCACHE_64
    moveal FCBSPtr,%a1
    moveal %a1@(0x14,%d1:w),%a2
    jbsr CACHE_C
    movel %a1@(0x0,%d1:w),%d3
    btst #1,%a1@(0x4,%d1:w)
    sne %d6
VFLUSHCACHE_64:         /* write them in block order (lowest first) */
    moveq #0,%d4
VFLUSHCACHE_66:         /* find the next block of the file or volume after d4 */
    moveq #0,%d2
    moveal %a3,%a4
VFLUSHCACHE_6A:         /* next buffer */
    moveal %a4@,%a4
    cmpal %a3,%a4
    jbne VFLUSHCACHE_7C
    tstl %d2
    jbeq VFLUSHCACHE_D8
    moveal %a1,%a4
    movel %a4@(18),%d4
    jbra VFLUSHCACHE_B2
VFLUSHCACHE_7C:         /* ours? */
    btst #5,%a4@(26)
    jbne VFLUSHCACHE_6A
    cmpal %a4@(8),%a2
    jbne VFLUSHCACHE_6A
    tstw %d1
    jblt VFLUSHCACHE_9A
    cmpl %a4@(12),%d3
    jbne VFLUSHCACHE_6A
    cmpb %a4@(27),%d6
    jbne VFLUSHCACHE_6A
VFLUSHCACHE_9A:         /* the lowest block above the last one */
    tstl %d2
    jbeq VFLUSHCACHE_A4
    cmpl %a4@(18),%d2
    jblt VFLUSHCACHE_6A
VFLUSHCACHE_A4:         /* a candidate */
    cmpl %a4@(18),%d4
    jbge VFLUSHCACHE_6A
    movel %a4@(18),%d2
    moveal %a4,%a1
    jbra VFLUSHCACHE_6A
VFLUSHCACHE_B2:         /* dirty: write it */
    btst #7,%a4@(26)
    jbeq VFLUSHCACHE_C4
    jsr %pc@(WRITEBLOCK)
    bclr #7,%a4@(26)
VFLUSHCACHE_C4:         /* release it too? */
    btst #0,%d5
    jbeq VFLUSHCACHE_66
    btst #6,%a4@(26)
    jbne VFLUSHCACHE_66
    jbsr INITCACHE_4E
    jbra VFLUSHCACHE_66
VFLUSHCACHE_D8:         /* no error, return */
    clrw %d0
    moveml %fp@+,%d1-%d6/%a0-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* GETBLOCK: get a block (read it if not cached). */
GETBLOCK:
    movel 0x704,%sp@-	/* through the vector at 0x704 (normally VGETBLOCK; patchable) */
    rts

/* VGETBLOCK: vectored entry: get a block (read it if not cached). */
trap_VGETBLOCK:
VGETBLOCK:              /* (d0 = FCB, or a negative vRefNum for a volume block; d2 = block; a1 = cache; d1 options) */
    movel %sp@+,%fp@-
    moveml %d1-%d7/%a1-%a5,%fp@-
    moveb %d1,%d3
    moveal %a1,%a3
    movew %d0,%d1
    jblt VGETBLOCK_AC
    moveal FCBSPtr,%a1
    moveal %a1@(0x14,%d1:w),%a2
    movel %a1@(0x0,%d1:w),%d7
    btst #1,%a1@(0x4,%d1:w)
    sne %d4
    moveal %a3,%a4
VGETBLOCK_26:           /* look for it in the ring */
    moveal %a4@,%a4
    cmpal %a3,%a4
    jbeq VGETBLOCK_50
    btst #5,%a4@(26)
    jbne VGETBLOCK_26
    cmpal %a4@(8),%a2
    jbne VGETBLOCK_26
    cmpl %a4@(12),%d7
    jbne VGETBLOCK_26
    cmpb %a4@(27),%d4
    jbne VGETBLOCK_26
    cmpl %a4@(22),%d2
    jbeq VGETBLOCK_1AA
    jbra VGETBLOCK_26
VGETBLOCK_50:           /* not cached; the file's own buffer? (none here) */
    jbsr CACHE
    jbeq VGETBLOCK_66
    btst #5,%a4@(26)
    jbne VGETBLOCK_66
    cmpl %a4@(22),%d2
    jbeq VGETBLOCK_1D2
VGETBLOCK_66:           /* a file block: map it to the disk block (LG2PHYS) */
    moveml %d3-%d4,%fp@-
    moveq #0,%d4
    movew %a3@(10),%d4
    movel %d2,%d5
    lsll #8,%d5
    addl %d5,%d5
    jsr %pc@(LG2PHYS)
    movel %d2,%d6
    movel %d3,%d2
    moveml %fp@+,%d3-%d4
    tstw %d0
    jbne VGETBLOCK_1D8
    moveq #0,%d0
    jbeq VGETBLOCK_B4
    jbsr CACHE_C
    movel %d2,%a4@(18)
    movel %d6,%a4@(22)
    clrb %a4@(26)
    jsr %pc@(CACHEIO)
    jbeq VGETBLOCK_1D2
    jbsr INITCACHE_4E
    jbra VGETBLOCK_1D8
VGETBLOCK_AC:           /* a volume block: no file */
    moveq #0,%d1
    moveq #0,%d7
    moveq #-1,%d6
    moveq #0,%d4
VGETBLOCK_B4:           /* find a buffer: an empty one, else the least recently used clean one, else a dirty one (written first) */
    subal %a0,%a0
    subal %a1,%a1
    subal %a5,%a5
    moveal %a3,%a4
VGETBLOCK_BC:           /* next buffer */
    moveal %a4@,%a4
    cmpal %a3,%a4
    jbeq VGETBLOCK_F8
    btst #5,%a4@(26)
    jbeq VGETBLOCK_CE
    moveal %a4,%a0
    jbra VGETBLOCK_BC
VGETBLOCK_CE:           /* a volume block already cached? */
    tstw %d1
    jbne VGETBLOCK_E0
    cmpal %a4@(8),%a2
    jbne VGETBLOCK_E0
    cmpl %a4@(18),%d2
    jbeq VGETBLOCK_1AA
VGETBLOCK_E0:           /* in use: skip; dirty: remember */
    btst #6,%a4@(26)
    jbne VGETBLOCK_BC
    btst #7,%a4@(26)
    jbeq VGETBLOCK_F4
    moveal %a4,%a5
    jbra VGETBLOCK_BC
VGETBLOCK_F4:           /* clean */
    moveal %a4,%a1
    jbra VGETBLOCK_BC
VGETBLOCK_F8:           /* none free and the caller cannot wait (option 2): 3 */
    btst #1,%d3
    jbeq VGETBLOCK_104
    moveq #3,%d0
    jbra VGETBLOCK_1D8
VGETBLOCK_104:          /* the empty one, or the clean one */
    moveal %a0,%a4
    movel %a4,%d0
    jbne VGETBLOCK_150
    moveal %a1,%a4
    movel %a4,%d0
    jbne VGETBLOCK_150
    moveal %a5,%a4
    movel %a4,%d0
    jbne VGETBLOCK_11C
    moveq #1,%d0
    jbra VGETBLOCK_1D8
VGETBLOCK_11C:          /* only dirty ones: flush its file or volume first */
    moveml %d0-%d2/%a1-%a2,%fp@-
    moveb SysCRefCnt,%d2
    st SysCRefCnt
    moveq #0,%d1
    moveal %a3,%a1
    moveal %a4@(8),%a2
    movew %a4@(16),%d0
    jbgt VGETBLOCK_13A
    movew %a2@(78),%d0
VGETBLOCK_13A:          /* flush */
    jsr %pc@(FLUSHCACHE)
    moveb %d2,SysCRefCnt
    moveml %fp@+,%d0-%d2/%a1-%a2
    cmpal SysCtlCPtr,%a3
    jbne VGETBLOCK_150
    st SysCRefCnt
VGETBLOCK_150:          /* claim it: in use, the block, the file, the fork */
    bset #6,%a4@(26)
    bclr #5,%a4@(26)
    bclr #7,%a4@(26)
    movel %a2,%a4@(8)
    movel %d2,%a4@(18)
    movew %d1,%a4@(16)
    movel %d7,%a4@(12)
    moveb %d4,%a4@(27)
    movel %d6,%a4@(22)
    btst #2,%d3
    jbne VGETBLOCK_1BC
VGETBLOCK_180:          /* read it (unless option 4); HFS: the volume's write count follows the tags' date */
    clrl BufTgDate
    jsr %pc@(CACHEIO)
    jbne VGETBLOCK_1A0
    jsr %pc@(TFSVCBTST)
    jbne VGETBLOCK_1BC
    movel BufTgDate,%d0
    cmpl %a2@(100),%d0
    jbls VGETBLOCK_1BC
    movel %d0,%a2@(100)
    jbra VGETBLOCK_1BC
VGETBLOCK_1A0:          /* read error: empty it again */
    clrb %a4@(26)
    jbsr INITCACHE_4E
    jbra VGETBLOCK_1D8
VGETBLOCK_1AA:          /* found in the cache: in use already? 2; re-read if asked (option 1) */
    bset #6,%a4@(26)
    jbeq VGETBLOCK_1B6
    moveq #2,%d0
    jbra VGETBLOCK_1D8
VGETBLOCK_1B6:          /* re-read? */
    btst #0,%d3
    jbne VGETBLOCK_180
VGETBLOCK_1BC:          /* move it to the front of the ring (most recently used); option 8: not left in use */
    jsr %pc@(VCACHEWRIP_28)
    moveal %a3,%a0
    jsr %pc@(VCACHEWRIP_3E)
    btst #3,%d3
    jbeq VGETBLOCK_1D2
    bclr #6,%a4@(26)
VGETBLOCK_1D2:          /* a0 = its data, no error */
    lea %a4@(28),%a0
    moveq #0,%d0
VGETBLOCK_1D8:          /* return */
    moveml %fp@+,%d1-%d7/%a1-%a5
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* INITCACHE: set up the cache. */
INITCACHE:              /* (d0 = buffer count, d1 = block size: a1 = the new cache: ring head, count +8, size +10, then the buffers, all empty) */
    movel %sp@+,%fp@-
    moveml %d1-%d3/%a0/%a4,%fp@-
    movew %d0,%d2
    movew %d1,%d3
    addiw #28,%d1
    moveq #0,%d0
    movew %d2,%d0
    muluw %d1,%d0
    addil #12,%d0
    .short  0xA71E	| 40814426 _NewPtr (flags 0x0700)
    jbne INITCACHE_44
    moveal %a0,%a1
    movel %a1,%a1@
    movel %a1,%a1@(4)
    movew %d2,%a1@(8)
    movew %d3,%a1@(10)
    lea %a1@(12),%a4
    subqw #1,%d2
INITCACHE_34:           /* link each buffer into the ring */
    moveal %a1,%a0
    jsr %pc@(VCACHEWRIP_3E)
    jbsr INITCACHE_4E
    addal %d1,%a4
    dbf %d2,INITCACHE_34
    clrw %d0
INITCACHE_44:           /* return */
    moveml %fp@+,%d1-%d3/%a0/%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

INITCACHE_4E:           /* buffer a4 empty */
    bset #5,%a4@(26)
    clrl %a4@(18)
    rts

/* MARKBLOCK: mark a block dirty. */
MARKBLOCK:
    movel 0x708,%sp@-	/* through the vector at 0x708 (normally VMARKBLOCK; patchable) */
    rts

/* VMARKBLOCK: vectored entry: mark a block dirty. */
trap_VMARKBLOCK:
VMARKBLOCK:             /* (flags of buffer a0: dirty) */
    bset #7,%a0@(-2)
    rts

/* MARKA5BLOCK: mark a block dirty (A5 relative). */
MARKA5BLOCK:            /* (the block at a5) */
    exg %a0,%a5
    jbsr MARKBLOCK
    exg %a0,%a5
    rts

/* RELBLOCK: release a block. */
RELBLOCK:
    movel 0x70c,%sp@-	/* through the vector at 0x70C (normally VRELBLOCK; patchable) */
    rts

/* VRELBLOCK: vectored entry: release a block. */
trap_VRELBLOCK:
VRELBLOCK:              /* (a0 = block, d1: 2 trash, 4 dirty, 1 write now) */
    movel %sp@+,%fp@-
    moveml %d1/%a0-%a1/%a3-%a4,%fp@-
    lea %a0@(-28),%a4
    bclr #6,%a4@(26)
    btst #1,%d1
    jbeq VRELBLOCK_20
    jbsr INITCACHE_4E
    bclr #7,%a4@(26)
    jbra VRELBLOCK_40
VRELBLOCK_20:           /* dirty? */
    btst #2,%d1
    jbeq VRELBLOCK_2C
    bset #7,%a4@(26)
VRELBLOCK_2C:           /* write now? */
    btst #0,%d1
    jbeq VRELBLOCK_40
    moveal %a1,%a3
    jsr %pc@(WRITEBLOCK)
    bclr #7,%a4@(26)
    jbra VRELBLOCK_42
VRELBLOCK_40:           /* no error */
    clrw %d0
VRELBLOCK_42:           /* return */
    moveml %fp@+,%d1/%a0-%a1/%a3-%a4
    movel %fp@+,%sp@-
    tstw %d0
    rts

/* TRASHVBLKS: forget the cached blocks of a volume. */
TRASHVBLKS:
    movel 0x714,%sp@-	/* through the vector at 0x714 (normally VTRASHVBLKS; patchable) */
    rts

/* VTRASHVBLKS: vectored entry: forget the cached blocks of a volume. */
trap_VTRASHVBLKS:
VTRASHVBLKS:
    moveml %a3-%a4,%sp@-
    moveal %a1,%a3
    moveal %a3,%a4
VTRASHVBLKS_8:          /* every buffer of volume a2: empty */
    moveal %a4@,%a4
    cmpal %a3,%a4
    jbeq VTRASHVBLKS_22
    btst #5,%a4@(26)
    jbne VTRASHVBLKS_8
    cmpal %a4@(8),%a2
    jbne VTRASHVBLKS_8
    jbsr INITCACHE_4E
    jbra VTRASHVBLKS_8
VTRASHVBLKS_22:         /* return */
    moveml %sp@+,%a3-%a4
    rts

/* TRASHFBLOCKS: forget the cached blocks of a file. */
TRASHFBLOCKS:           /* (all the blocks of file d0) */
    moveml %d0-%d6/%a0-%a4,%sp@-
    movel %d0,%d3
    moveq #0,%d1
    jbra TRASHBLOCKS_4E

/* TRASHBLOCKS: forget cached blocks. */
TRASHBLOCKS:            /* (FCB d0, bytes from d1 for d2 (-1: to the end): blocks d4..d5) */
    moveml %d0-%d6/%a0-%a4,%sp@-
    moveq #9,%d3
    movel %d1,%d4
    lsrl %d3,%d4
    moveq #-1,%d5
    cmpl %d2,%d5
    jbeq TRASHBLOCKS_16
    movel %d2,%d5
    addl %d1,%d5
    subql #1,%d5
TRASHBLOCKS_16:         /* the file's own buffer (none here) */
    lsrl %d3,%d5
    movew %d0,%d1
    jble VTRASHBLOCKS_3C
    moveal FCBSPtr,%a1
    moveal %a1@(0x14,%d1:w),%a2
    movel %a1@(0x0,%d1:w),%d3
    btst #1,%a1@(0x4,%d1:w)
    sne %d6
    jbsr CACHE
    jbeq TRASHBLOCKS_4E
    btst #5,%a4@(26)
    jbne TRASHBLOCKS_4E
    movel %a4@(22),%d0
    cmpl %d4,%d0
    jblt TRASHBLOCKS_4E
    cmpl %d5,%d0
    jbgt TRASHBLOCKS_4E
    jbsr INITCACHE_4E
TRASHBLOCKS_4E:         /* the volume cache's buffers (VTRASHBLOCKS) */
    movel 0x710,%sp@-	/* through the vector at 0x710 (normally VTRASHBLOCKS; patchable) */
    rts

/* VTRASHBLOCKS: vectored entry: forget cached blocks. */
trap_VTRASHBLOCKS:
VTRASHBLOCKS:
    moveal %a2@(84),%a3
    moveal %a3,%a4
VTRASHBLOCKS_6:         /* next buffer of the file (and fork, and block range) */
    moveal %a4@,%a4
    cmpal %a3,%a4
    jbeq VTRASHBLOCKS_3C
    btst #5,%a4@(26)
    jbne VTRASHBLOCKS_6
    cmpal %a4@(8),%a2
    jbne VTRASHBLOCKS_6
    cmpl %a4@(12),%d3
    jbne VTRASHBLOCKS_6
    tstw %d1
    jbeq VTRASHBLOCKS_36
    cmpb %a4@(27),%d6
    jbne VTRASHBLOCKS_6
    movel %a4@(22),%d0
    cmpl %d4,%d0
    jblt VTRASHBLOCKS_6
    cmpl %d5,%d0
    jbgt VTRASHBLOCKS_6
VTRASHBLOCKS_36:        /* empty it */
    jbsr INITCACHE_4E
    jbra VTRASHBLOCKS_6
VTRASHBLOCKS_3C:        /* restore, return */
    moveml %sp@+,%d0-%d6/%a0-%a4
    rts

/* CACHERDIP: read in place through the cache. */
CACHERDIP:
    movel 0x71c,%sp@-	/* through the vector at 0x71C (normally VCACHERDIP; patchable) */
    rts

/* VCACHERDIP: vectored entry: read in place through the cache. */
trap_VCACHERDIP:
VCACHERDIP:             /* (whole blocks straight into the caller's buffer: flush the file's cached blocks first, map, RDBLOCKS) */
    movel %sp@+,%fp@-
    movel %d3,%fp@-
    moveml %d1/%a1,%fp@-
    movew %d1,%d0
    moveq #0,%d1
    moveal %a2@(84),%a1
    jbsr FLUSHCACHE
    moveml %fp@+,%d1/%a1
    jbne VCACHERDIP_24
    jsr %pc@(LG2PHYS)
    jbne VCACHERDIP_24
    jsr %pc@(RDBLOCKS)
VCACHERDIP_24:          /* done */
    jbra VCACHEWRIP_20

/* CACHEWRIP: write in place through the cache. */
CACHEWRIP:
    movel 0x718,%sp@-	/* through the vector at 0x718 (normally VCACHEWRIP; patchable) */
    rts

/* VCACHEWRIP: vectored entry: write in place through the cache. */
trap_VCACHEWRIP:
VCACHEWRIP:             /* (whole blocks straight from the caller's buffer: map, drop the cached copies, WRBLOCKS) */
    movel %sp@+,%fp@-
    movel %d3,%fp@-
    jsr %pc@(LG2PHYS)
    jbne VCACHEWRIP_20
    moveml %d1-%d2,%fp@-
    movew %d1,%d0
    movel %d5,%d1
    movel %d6,%d2
    jbsr TRASHBLOCKS
    moveml %fp@+,%d1-%d2
    jsr %pc@(WRBLOCKS)
VCACHEWRIP_20:          /* return */
    movel %fp@+,%d3
    movel %fp@+,%sp@-
    tstw %d0
    rts

VCACHEWRIP_28:          /* unlink buffer a4 from the ring */
    moveml %a0-%a1,%sp@-
    moveal %a4@(4),%a0
    moveal %a4@,%a1
    movel %a1,%a0@
    movel %a0,%a1@(4)
    moveml %sp@+,%a0-%a1
    rts

VCACHEWRIP_3E:          /* link it after head a0 */
    movel %a1,%sp@-
    moveal %a0@,%a1
    movel %a1,%a4@
    movel %a4,%a1@(4)
    movel %a4,%a0@
    movel %a0,%a4@(4)
    moveal %sp@+,%a1
    rts

/* CACHEIO: cache input/output. */

/* READOWNBUF: read into the caller's buffer. */
CACHEIO:                /* (READBLOCK / WRITEBLOCK: one 512-byte buffer a4 through the disk driver) */

/* READBLOCK: read a block. */
READOWNBUF:
READBLOCK:
    movel %sp@+,%fp@-
    moveml %d1-%a5,%fp@-
    moveq #0,%d1
    jbra WRITEBLOCK_22

/* WRITEOWNBUF: write from the caller's buffer. */
WRITEOWNBUF:
    movel %sp@+,%fp@-
    moveml %d1-%a5,%fp@-
    jbra WRITEBLOCK_14

/* WRITEBLOCK: write a block. */
WRITEBLOCK:
    movel %sp@+,%fp@-
    moveml %d1-%a5,%fp@-
    moveal %a4@(8),%a2
    movel %a4@(18),%d0
    movew %a4@(16),%d1
    jbeq WRITEBLOCK_1C
WRITEBLOCK_14:          /* a file block: its disk block */
    moveal FCBSPtr,%a1
    movel %a4@(22),%d0
WRITEBLOCK_1C:          /* the tags; d1 = 1: write */
    jbsr VWRBLOCKS_C
    moveq #1,%d1
WRITEBLOCK_22:          /* a parameter block (Params): drive, driver, buffer, 512 bytes, from the start (ioPosMode 1), the offset */
    lea Params,%a0
    movew %a2@(72),%a0@(22)
    movew %a2@(74),%a0@(24)
    lea %a4@(28),%a1
    movel %a1,%a0@(32)
    movew #1,%a0@(44)
    movel #512,%a0@(36)
    movel %a4@(18),%d0
    lsll #8,%d0
    addl %d0,%d0
    movel %d0,%a0@(46)
WRITEBLOCK_54:          /* through VBASICIO */
    movel 0x720,%sp@-	/* through the vector at 0x720 (normally VBASICIO; patchable) */
    rts

/* VBASICIO: basic disk I/O through the driver. */
trap_VBASICIO:
VBASICIO:               /* (_Read or _Write of Params; an asynchronous File Manager call waits for it in the background: the call resumes from the completion routine) */
    movel %fp,HFSStkPtr
    tstb NxtDB
    jbne VBASICIO_16
    tstb %d1
    jbne VBASICIO_12
    _Read
    jbra VBASICIO_50
VBASICIO_12:            /* write */
    _Write
    jbra VBASICIO_50
VBASICIO_16:            /* asynchronous: completion routine VBASICIO_40 */
    lea %pc@(VBASICIO_40),%a1
    movel %a1,%a0@(12)
    bclr #7,HFSFlags
    tstb %d1
    jbne VBASICIO_2C
    .short  0xA402	| 408146B4 _Read (flags 0x0400)
    jbra VBASICIO_2E
VBASICIO_2C:            /* (raw: _Write async) */
    .short  0xA403	| 408146B8 _Write (flags 0x0400)
VBASICIO_2E:            /* (_Read async) done already? */
    jbeq VBASICIO_36
    tstw %a0@(16)
    jble VBASICIO_48
VBASICIO_36:            /* still in progress: return to the caller (the interrupted File Manager call continues later) */
    bset #7,HFSFlags
    jbne VBASICIO_50
VBASICIO_3E:            /* return */
    rts
VBASICIO_40:            /* completion: resume the File Manager call (if it was suspended) */
    bset #7,HFSFlags	| 408146CC
    jbeq VBASICIO_3E	| 408146D2
VBASICIO_48:            /* resume on the File Manager's stack */
    moveml %d4-%d7/%a4-%fp,%sp@-
    pea %pc@(VBASICIO_6E)
VBASICIO_50:            /* d0 = the result: errors other than -65 (offLinErr) become ioErr (the driver's in FSTemp4) */
    moveal HFSStkPtr,%fp
    moveml %fp@+,%d1-%a5
    movel %fp@+,%sp@-
    tstw %d0
    jbeq VBASICIO_6A
    cmpiw #-65,%d0
    jbeq VBASICIO_6A
    movew %d0,FSTemp4
    moveq #-36,%d0	/* ioErr */
VBASICIO_6A:            /* return */
    tstw %d0
    rts
VBASICIO_6E:            /* (back to the interrupted code) */
    moveml %sp@+,%d4-%d7/%a4-%fp	| 408146FA
    rts	| 408146FE

/* RDBLOCKS: read blocks. */
RDBLOCKS:
    movel 0x724,%sp@-	/* through the vector at 0x724 (normally VRDBLOCKS; patchable) */
    rts

/* VRDBLOCKS: vectored entry: read blocks. */
trap_VRDBLOCKS:
VRDBLOCKS:              /* (d3 = first disk block, d6 = bytes, into the caller's buffer at ioBuffer + ioActCount) */
    moveq #0,%d0
VRDBLOCKS_2:            /* Params for the driver (the caller's no-cache bit kept) */
    movel %sp@+,%fp@-
    moveml %d1-%a5,%fp@-
    moveal %a0@(32),%a5
    addal %a0@(40),%a5
    movew %d0,%d1
    moveq #64,%d0
    andb %a0@(45),%d0
    lea Params,%a0
    movew %a2@(74),%a0@(24)
    movew %a2@(72),%a0@(22)
    movel %a5,%a0@(32)
    movel %d6,%a0@(36)
    movew #1,%a0@(44)
    orb %d0,%a0@(45)
    movel %d3,%d0
    lsll #8,%d0
    addl %d0,%d0
    movel %d0,%a0@(46)
    jbra WRITEBLOCK_54

/* WRBLOCKS: write blocks. */
WRBLOCKS:
    movel 0x728,%sp@-	/* through the vector at 0x728 (normally VWRBLOCKS; patchable) */
    rts

/* VWRBLOCKS: vectored entry: write blocks. */
trap_VWRBLOCKS:
VWRBLOCKS:              /* (the tags first) */
    movel %d5,%d0
    lsrl #8,%d0
    lsrl #1,%d0
    jbsr VWRBLOCKS_C
    moveq #1,%d0
    jbra VRDBLOCKS_2

VWRBLOCKS_C:            /* the tag buffer (VSETUPTAGS) */
    movel 0x72c,%sp@-	/* through the vector at 0x72C (normally VSETUPTAGS; patchable) */
    rts

/* VSETUPTAGS: set up the tag buffer. */
trap_VSETUPTAGS:
VSETUPTAGS:             /* (file number, fork and block, parent and catalog info; HFS: the volume write count as the date) */
    tstw %d1
    jbeq VSETUPTAGS_32
    movel %a1@(0x0,%d1:w),BufTgFNum
    movel %d0,BufTgFFlg
    moveb %a1@(0x4,%d1:w),BufTgFFlg
    movel %a1@(0x32,%d1:w),BufTgHD20
    movel %a1@(0x3a,%d1:w),BufTgHD20_1
VSETUPTAGS_20:          /* the date / write count */
    jsr %pc@(TFSVCBTST)
    jbne VSETUPTAGS_46
    movel %a2@(100),BufTgDate
    addql #1,%a2@(100)
    rts
VSETUPTAGS_32:          /* a volume block: file number 1 */
    movel %d0,BufTgFFlg
    moveq #1,%d0
    movel %d0,BufTgFNum
    clrl BufTgHD20
    clrl BufTgHD20_1
    jbra VSETUPTAGS_20
VSETUPTAGS_46:          /* MFS: the time */
    movel Time,BufTgDate
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408147B4
