/*
 toolbox/resourcemgr.s - Resource Manager
 From RMGR (0x4081AA10). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple.
 Almost all of it runs on the Quadra 800 (QEMU traces: everything but the type
 counting and unique ID calls).

 Resource files: a resource fork holds a 16-byte header (data offset, map offset, data
 length, map length), the data area (each resource: a 4-byte length, then the data)
 and the map. Each open file's map is read into a handle and the maps form a chain
 from TopMapHndl (+16 of each map: the next one down); CurMap is the current file,
 SysMapHndl/SysMap the System file. The ROM's own resources have a map too
 (ROMMapHandle, refNum 1), normally not in the chain: RGetResource and the calls with
 ROMMapInsert set put it under the system map for one call (VRMGRSTDENTRY_30).

 Map in memory (a3 = map, a4 = its handle): +0 a copy of the header, +16 the next map,
 +20 the file's refNum, +22 attributes (bit 7 read-only, 6 compact on update, 5
 changed), +24 offset of the type list, +26 offset of the name list. Type list: count -
 1, then 8-byte entries (type, count - 1, offset of its references from the type
 list). Reference (12 bytes, a2): +0 ID, +2 name offset (-1: none), +4 attributes
 (7 unused, 6 system heap, 5 purgeable, 4 locked, 3 protected, 2 preload, 1 changed)
 and the 3-byte data offset, +8 the handle (0 if not loaded). Names: Pascal strings.

 Every call goes through a common entry (the vector at 0x698: VRMGRSTDENTRY, with a
 50-byte File Manager parameter block in its frame) and exit (0x69C: VRMGRSTDEXIT,
 ResErr, ResErrProc). File access is VCHECKLOAD_11A (read) and _124 (write), whose
 _Read/_Write traps are raw words. The last resource found is remembered (0xB8..,
 RMgrLastResHand) so that a following call on the same handle is quick. Errors:
 -192 resNotFound .. -199 mapReadErr, named where they are set.
*/

/*
 RMGR / NULLRF: the empty resource file image written by CreateResFile: a 16-byte header
 (data at 256, map at 256, data length 0, map length 30) and an empty 30-byte map (type
 list at 28, name list at 30, no types).
*/
RMGR:
NULLRF:
    .long   0x00000100, 0x00000100, 0x00000000, 0x0000001E	| 4081AA10
    .long   0x00000000, 0x00000000, 0x001C001E, 0xFFFF0000	| 4081AA20
    .short  0x0001	| 4081AA30

/*
 _InitResources: set up the resource chain at start-up. Without a System file yet
 (TopMapHndl 0) only the ROM map exists (refNum 1, both top and system map); later
 calls open the System file (SysResName) in the system heap, load its preloaded
 resources, put the ROM map under it, run the 'ROvr' resource (ID 0: ROM override code
 from the System file, which can replace ROM resources), and initialise the Script
 Manager.
*/
trap_InitResources:
INITRESOURCES:
    clrl RMgrLastResHand
    jbsr SKIPTOENTRY_1E
    tstl TopMapHndl
    jbgt INITRESOURCES_2E
    clrl ResErrProc
    jbsr INITRESOURCES_A2
    movel %a0,TopMapHndl
    movel %a0,SysMapHndl
    movel OneOne,SysMap
    jbsr thunk_FUN_408a067a
    clrl %a1@(16)
    jbra INITRESOURCES_86
INITRESOURCES_2E:       /* open the System file in the system heap (VSUPERLOAD_132: the vector at 0x7EC) */
    lea TheZone,%a3
    movel %a3@,%sp@-
    movel SysZone,%a3@
    lea SysResName,%a1
    jbsr VSUPERLOAD_132
    movel %sp@+,%a3@
    movew %d6,%fp@(8)
    tstl %d0
    jble INITRESOURCES_86
    movel %a4,TopMapHndl
    movel %a4,SysMapHndl
    movew %d6,CurMap
    movew %d6,SysMap
    jbsr ADDROMRSRC_4A
    jbsr thunk_FUN_408a067a
    movel SysMapHndl,%a1@(16)
    moveal SysMapHndl,%a1
    moveal %a1@,%a1
    clrl %a1@(16)
    jbsr INITRESOURCES_8A
    movel IntlSpec,%d0
    addqw #1,%d0
    jbne INITRESOURCES_82
    jbsr SMGRINITIALIZE
    jbra INITRESOURCES_86
INITRESOURCES_82:       /* the Script Manager was set up before: fix it up */
    jbsr FIXSMGRWORLD
INITRESOURCES_86:       /* done */
    jbra VRMGRSTDENTRY_B4

INITRESOURCES_8A:       /* GetResource('ROvr', 0): ROM override code; run it */
    subqw #4,%sp
    movel #1380939378,%sp@-
    clrw %sp@-
    _GetResource
    movel %sp@+,%d0
    jbeq INITRESOURCES_A0
    moveal %d0,%a0
    moveal %a0@,%a0
    jsr %a0@
INITRESOURCES_A0:       /* return */
    rts

INITRESOURCES_A2:       /* the ROM map: count the ROM resources (NEWCOUNTCOMBOS), a heap zone for its handles (master pointers, locked), the map in it */
    jbsr thunk_FUN_408a07b0
    movel %d0,%d5
    movel %d1,%d6
    moveq #24,%d0
    addw %d5,%d0
    asll #3,%d0
    jbsr ADDPATCHROMSIZE
    movel TheZone,%sp@-
    clrl %sp@-
    movew #4,%sp@-
    addal %a0,%a1
    movel %a1,%sp@-
    movel %a0,%sp@-
    moveal %a0,%a1
    moveal %sp,%a0
    _InitZone
    bset #0,%a1@(22)
    movel %a1,TheZone
    lea %sp@(14),%sp
    movel %d5,%d0
    asll #3,%d0
    .short  0xA11E	| 4081AB10 _NewPtr (flags 0x0100)
    movew %d6,%d0
    .short  0xA122	| 4081AB14 _NewHandle (flags 0x0100)
    _HLock
    movel %a0,ROMMapHandle
    movel %sp@+,TheZone
    rts

thunk_FUN_408a067a:     /* build the ROM map (NEWREDOMAP) */
    jbra NEWREDOMAP
    .long   0x20780B06, 0x2848A024	| 4081AB28
    .long   0x702041FA, 0xFEDC2254, 0xA02E337C, 0x00010014	| 4081AB30
    .long   0x4267204F, 0x203C0001, 0x00AEA051, 0x1610544F	| 4081AB40
    .long   0x247802AE, 0xD5EA001A, 0x7400142A, 0x0005382A	| 4081AB50
    .long   0x000861FF	| 4081AB60
    .long   RSRCMGRPATCH-.	| 4081AB64
    nop
    nop
    nop
    nop
    nop
    nop
    moveal %a2@,%a2
    addal ROMBase,%a2
INITRESOURCES_A2_A6:
    moveal %a2,%a0
    moveq #0,%d0
    moveb %d3,%d0
    lsrb #3,%d0
    addaw %d0,%a0
    moveb %d3,%d0
    eorib #0xff,%d0	| 4081AB86
    andib #7,%d0
    btst %d0,%a0@
    addaw %d2,%a2
    beqs INITRESOURCES_A2_E8
    moveal %a2@(4),%a3
    addal ROMBase,%a3
    moveal ROMMapHandle,%a0
    .short  0xA126	| 4081ABA0 _HandleZone (flags 0x0100)
    movel %a3@(-4),%d0
    _StripAddress
    addal %d0,%a0
    movel %a3,%a0@
    movel %a0,%sp@-
    movel %a2@(8),%sp@-
    movew %a2@(12),%sp@-
    pea %a2@(15)
    bsrs ADDROMRSRC
INITRESOURCES_A2_E8:
    moveal %a2@,%a2
    movel %a2,%d0
    addal ROMBase,%a2
    bnes INITRESOURCES_A2_A6
    movew #1,%a1@(20)
    rts

thunk_FUN_408a07b0:     /* count the ROM resources (NEWCOUNTCOMBOS) */
    jbra NEWCOUNTCOMBOS
    nop
    addal %a2@(26),%a2
    moveq #0,%d2
    moveb %a2@(5),%d2
    moveal %a2@,%a2
    addal ROMBase,%a2
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d3
INITRESOURCES_A2_118:
    addqw #1,%d0
    addaw %d2,%a2
    moveb %a2@(15),%d3
    addl %d3,%d1
    moveal %a2@,%a2
    movel %a2,%d4
    addal ROMBase,%a2
    bnes INITRESOURCES_A2_118
    movel %d0,%d2
    muluw #20,%d2
    addil #28,%d2
    addl %d2,%d1
    moveml %sp@+,%d2-%d4/%a2
    rts

/* ADDROMRSRC: add a ROM resource to the ROM map. */
ADDROMRSRC:             /* (add a resource that lives in the ROM to the ROM map: its handle points into the ROM, the data offset is from ROMBase, attributes 0x58: system heap, locked, preload) */
    movew #-1,ROMMapInsert
    jbsr SKIPTOENTRY_26
    moveal %fp@(18),%a1
    jbsr GETNAMEDRESOURCE_6A
    movel %fp@(14),%d3
    jbsr ADDRESOURCE_52
    movew %fp@(12),%a2@
    movew #-1,%a2@(2)
    moveal %fp@(8),%a0
    jbsr ADDNAME
    moveal %fp@(18),%a0
    movel %a0,%a2@(8)
    moveal %a0@,%a0
    subal ROMBase,%a0
    movel %a0,%a2@(4)
    moveb #88,%a2@(4)
    moveq #14,%d0
    jbra VRMGRSTDENTRY_B6

ADDROMRSRC_4A:          /* load the map's preloaded resources (ResLoad on) */
    st ResLoad

ADDROMRSRC_4E:          /* every reference of the map: no handle yet */
    jbsr GETNAMEDRESOURCE_6E
    jbmi ADDROMRSRC_80
    jbsr GETTYPES_C
    jbmi ADDROMRSRC_80
ADDROMRSRC_5A:          /* clear the handles */
    addqw #8,%a2
    clrl %a2@+
    dbf %d4,ADDROMRSRC_5A
    tstb ResLoad
    jbeq ADDROMRSRC_80
    jbsr ADDROMRSRC_82
    jbeq ADDROMRSRC_80
    moveq #2,%d1
    jbsr SETRESFILEATTRS_38
    jbmi ADDROMRSRC_80
ADDROMRSRC_74:          /* load each resource with the preload attribute (bit 2), lowest data offset first */
    jbsr VRMGRSTDEXIT_12A
    moveq #2,%d1
    jbsr SETRESFILEATTRS_3E
    jbeq ADDROMRSRC_74
ADDROMRSRC_80:          /* return */
    rts

ADDROMRSRC_82:          /* (the vector at 0x7E4) */
    moveal 0x7e4,%a0
    jmp %a0@

/*
 VSUPERLOAD: load all the preload resources of a newly opened file in one read: a buffer
 as large as possible (up to the whole data area), filled once, then each preload
 resource copied out of it into its own handle. Falls back to loading them one by one.
*/
trap_VSUPERLOAD:
VSUPERLOAD:
    jbsr VSUPERLOAD_AC
    jbmi SKIPTOENTRY_1A
    jbsr GETTYPES_20
    moveal %a4@,%a1
VSUPERLOAD_E:           /* next resource in data order; past the buffer: done */
    movel %a2@(4),%d0
    andl Lo3Bytes,%d0
    cmpl RMgrHiVars_LastResType,%d0
    jbge VSUPERLOAD_7C
    movel TheZone,%sp@-
    btst #6,%a2@(4)
    jbeq VSUPERLOAD_2E
    movel SysZone,TheZone
VSUPERLOAD_2E:          /* its offset; system heap (attribute bit 6)? */
    movel %a2@(4),%d2
    andl Lo3Bytes,%d2
    jbsr VSUPERLOAD_96
    btst #4,%a2@(4)
    subal %a4@,%a2
    subal %a4@,%a3
    jbeq VSUPERLOAD_5A
    movel %d0,%d1
    .short  0xA166	| 4081ACE2 _NewEmptyHandle (flags 0x0100)
    jbmi VSUPERLOAD_8A
    _DisposHandle
    jbmi VSUPERLOAD_8A
    movel %d1,%d0
    .short  0xA11E	| 4081ACEC _NewPtr (flags 0x0100)
    jbmi VSUPERLOAD_8A
    _DisposPtr
    jbmi VSUPERLOAD_8A
    movel %d1,%d0
VSUPERLOAD_5A:          /* a handle of its size, copy from the buffer */
    .short  0xA122	| 4081ACF6 _NewHandle (flags 0x0100)
    jbmi VSUPERLOAD_8A
    movel %a0,%d1
    moveal %a0@,%a1
    jbsr VSUPERLOAD_96
    _BlockMove
    addal %a4@,%a2
    addal %a4@,%a3
    movel %d1,%a2@(8)
    moveal %d1,%a0
    moveb %a2@(4),%d1
    jbsr VCHECKLOAD_82
    movel %sp@+,TheZone
VSUPERLOAD_7C:          /* next */
    jbsr VRMGRSTDEXIT_D4
    jbpl VSUPERLOAD_E
    moveal %d7,%a0
    _DisposHandle
    moveq #0,%d0
    rts
VSUPERLOAD_8A:          /* no memory: give up the buffer */
    movel %sp@+,TheZone
    moveal %d7,%a0
    _DisposHandle
    jbra SKIPTOENTRY_1A

VSUPERLOAD_96:          /* a0 = the resource's data in the buffer, d0 = its length (the 4 bytes before it) */
    moveal %d7,%a0
    moveal %a0@,%a0
    addal %d2,%a0

VSUPERLOAD_9C:          /* read a long byte by byte (unaligned) */
    moveb %a0@+,%d0
    lslw #8,%d0
    moveb %a0@+,%d0
    swap %d0
    moveb %a0@+,%d0
    lslw #8,%d0
    moveb %a0@+,%d0
    rts

VSUPERLOAD_AC:          /* how much may be read at once: the free space up to ApplLimit or MaxBlock */
    tstl RMgrHiVars_LastResType
    jbeq VSUPERLOAD_116
    moveq #0,%d7
    movel %sp,%d0
    _StripAddress
    subl MinStack,%d0
    cmpl ApplLimit,%d0
    jbcs VSUPERLOAD_C6
    movel ApplLimit,%d0
VSUPERLOAD_C6:          /* room between the heap and the stack */
    subl HeapEnd,%d0
    jble VSUPERLOAD_D6
    cmpil #12,%d0
    jbls VSUPERLOAD_D6
    movel %d0,%d7
VSUPERLOAD_D6:          /* or the largest block */
    _MaxBlock
    cmpl %d7,%d0
    jble VSUPERLOAD_DE
    movel %d0,%d7
VSUPERLOAD_DE:          /* try the preload area sizes from the map's header (0xB90, 0xB8C, 0xB88) */
    movel 0xb90,%d0
    jbsr VSUPERLOAD_11A
    jbpl VSUPERLOAD_F6
    movel 0xb8c,%d0
    jbsr VSUPERLOAD_11A
    jbpl VSUPERLOAD_F6
    movel 0xb88,%d0
    jbsr VSUPERLOAD_11A
    jbmi VSUPERLOAD_116
VSUPERLOAD_F6:          /* a buffer: read the area */
    .short  0xA122	| 4081AD92 _NewHandle (flags 0x0100)
    jbmi VSUPERLOAD_116
    _DisposHandle
    movel %d1,%d0
    .short  0xA122	| 4081AD9A _NewHandle (flags 0x0100)
    jbmi VSUPERLOAD_116
    movel %d1,%d0
    movel %a0,%d7
    movel %a0@,%d1
    moveal %a4@,%a0
    movel %a0@,%d2
    jbsr VCHECKLOAD_11A
    jbeq VSUPERLOAD_118
    moveal %d7,%a0
    _DisposHandle
VSUPERLOAD_116:         /* no: -1 */
    moveq #-1,%d0
VSUPERLOAD_118:         /* return */
    rts
VSUPERLOAD_11A:         /* does size d0 fit? */
    movel %d0,RMgrHiVars_LastResType
    jbeq SKIPTOENTRY_1A
    jbmi VSUPERLOAD_130
    movel %d0,%d1
    addl %d0,%d0
    moveal %a4@,%a0
    addl %a0@(12),%d0
    cmpl %d0,%d7
VSUPERLOAD_130:         /* return */
    rts

VSUPERLOAD_132:         /* open a resource file and read its map (the vector at 0x7EC) */
    moveal 0x7ec,%a0
    jmp %a0@

/*
 VNEWMAP: read the resource map of the file just opened (refNum d6): the 16-byte header,
 then the map (its length from the header) into a new handle, checked by
 VCHECKLOAD_242; the map's +16 cleared, +20 = the refNum. d0 = 1 if read, -1 if not
 (mapReadErr in ResErr).
*/
trap_VNEWMAP:
VNEWMAP:
    clrl RMgrHiVars_LastResType
    clrl RMgrLastResHand
    moveq #36,%d0
    .short  0xA122	| 4081ADDE _NewHandle (flags 0x0100)
    movew %d0,ResErr
    jbmi VNEWMAP_C8
    moveal %a0,%a4
    jbsr VCHECKLOAD_100
    bsrw RSRCZONEINIT_44
    beqs VNEWMAP_42
    cmpiw #-49,%d0
    bnew VNEWMAP_BE+0x6	| 4081ADF8
    moveml %d6/%a2-%a4,%sp@-
    bsrw GETNAMEDRESOURCE_6E
    moveml %sp@+,%d6/%a2-%a4
    bnew VNEWMAP_BE+0x6	| 4081AE08
    clrw ResErr
    moveal %a4,%a0
    _DisposHandle
    rts
VNEWMAP_42:
    _GetEOF
    movew #-39,ResErr	/* eofErr */
    tstl %a0@(28)
    jbeq VNEWMAP_BE
    moveq #36,%d0
    moveal %a4@,%a1
    movel %a1,%d1
    moveq #0,%d2
    jbsr VCHECKLOAD_11A
    jbmi VNEWMAP_BE
    moveal %a1,%a0
    addaw #16,%a0
    lea RMgrHiVars_LastResType,%a1
    moveq #20,%d0
    _BlockMove
    moveal %a0,%a1
    subaw #16,%a1
    jbsr VNEWMAP_D6
    moveq #12,%d1
    movel %a1@(4),%d2
    addl %d1,%d2
    movel %a1@(12),%d4
    movel %d4,%d0
    moveal %a4,%a0
    _SetHandleSize
    movew %d0,ResErr
    jbne VNEWMAP_BE
    moveal %a4@,%a1
    movel %d4,%d0
    subl %d1,%d0
    addl %a1,%d1
    jbsr VCHECKLOAD_11A
    jbmi VNEWMAP_BE
    tstl RMgrHiVars_LastResType
    jbeq VNEWMAP_A8
    movel %a1@(12),RMgrHiVars_LastResType
    jbsr VNEWMAP_D6
VNEWMAP_A8:             /* map length, check it */
    movel %d4,%a1@(12)
    jbsr VCHECKLOAD_242
    jbmi VNEWMAP_BE
    clrl %a1@(16)
    movew %d6,%a1@(20)
    moveq #1,%d0
    rts
VNEWMAP_BE:             /* failed: close the file */
    jbsr VCHECKLOAD_100
    _Close
    moveal %a4,%a0
    _DisposHandle
VNEWMAP_C8:             /* -1 */
    clrl RMgrHiVars_LastResType
    clrl RMgrLastResHand
    moveq #-1,%d6
    moveq #-1,%d0
    rts

VNEWMAP_D6:             /* keep the value at 0xB80 only if it is the signature 0x20B7A185 */
    movel RMgrHiVars_LastResType,%d0
    subil #548905349,%d0
    jbeq VNEWMAP_E6
    clrl RMgrHiVars_LastResType
VNEWMAP_E6:             /* return */
    clrl RMgrLastResHand
    rts

/* RSRCZONEINIT: _RsrcZoneInit: release the resources in the application heap. */
trap_RsrcZoneInit:
RSRCZONEINIT:           /* (close every resource file opened above the System file; the system map's resources in the application heap lose their handles) */
    jbsr SKIPTOENTRY_1E
    tstw SysMap
    jbmi RSRCZONEINIT_2A
    jbsr RSRCZONEINIT_2E
    moveal SysMapHndl,%a4
    jbsr GETTYPES_C
    jbmi RSRCZONEINIT_2A
RSRCZONEINIT_16:        /* a resource not in the system heap: forget its handle */
    btst #6,%a2@(4)
    jbne RSRCZONEINIT_22
    clrl %a2@(8)
RSRCZONEINIT_22:        /* next reference */
    lea %a2@(12),%a2
    dbf %d4,RSRCZONEINIT_16
RSRCZONEINIT_2A:        /* done */
    jbra VRMGRSTDENTRY_B4

RSRCZONEINIT_2E:        /* close the files above the system map */
    moveal TopMapHndl,%a0
    cmpal SysMapHndl,%a0
    jbeq RSRCZONEINIT_42
    moveal %a0@,%a0
    movew %a0@(20),%sp@-
    _CloseResFile
    jbra RSRCZONEINIT_2E
RSRCZONEINIT_42:        /* return */
    rts
RSRCZONEINIT_44:        /* open the resource fork (OpenRF) with the permission asked; a name equal to the System file's: on the boot drive */
    movel %a0,%sp@-	| 4081AF04
    movew CurMap,%sp@-	| 4081AF06
    moveb ResLoad,%sp@-	| 4081AF0A
    movew SysMap,CurMap	| 4081AF0E
    sf ResLoad	| 4081AF14
    subqw #4,%sp	| 4081AF18
    movew #-8192,%sp@-	| 4081AF1A
    _GetString	| 4081AF1E
    movel %sp@+,%d0
    moveb %sp@+,ResLoad
    movew %sp@+,CurMap
    moveal %sp@+,%a0
    tstl %d0
    jbeq RSRCZONEINIT_80
    exg %d0,%a1
    moveal %a1@,%a1
    exg %d0,%a1
    cmpal %d0,%a1
    jbne RSRCZONEINIT_80
    movew BootDrive,%a0@(22)
RSRCZONEINIT_80:        /* _OpenRF: d6 = refNum */
    movel %a1,%a0@(18)
    clrl %a0@(28)
    _OpenRF
    movew %a0@(24),%d6
    movew %d0,ResErr
    rts

/* CREATERESFILE: _CreateResFile. */
trap_CreateResFile:
CREATERESFILE:          /* (create the file, open its resource fork; if it is empty write the empty map NULLRF) */
    jbsr SKIPTOENTRY_1E
    moveal %a0@,%a1
    jbsr VCHECKLOAD_100
    bsrs RSRCZONEINIT_44	| 4081AF5E
    beqs CREATERESFILE_20
    cmpiw #-43,%d0
    bnes CREATERESFILE_46
    _Create
    movew %d0,ResErr	| 4081AF6A
    jbmi CREATERESFILE_46	| 4081AF6E
    jbsr RSRCZONEINIT_44	| 4081AF70
    jbmi CREATERESFILE_46	| 4081AF72
CREATERESFILE_20:
    _GetEOF	| 4081AF74
    movew #-48,ResErr	/* dupFNErr */
    tstl %a0@(28)
    jbne CREATERESFILE_44
    moveq #16,%d0
    lea %pc@(RMGR),%a1
    movel %a1,%d1
    jbsr VCHECKLOAD_122
    moveq #30,%d0
    moveq #64,%d2
    aslw #2,%d2
    jbsr VCHECKLOAD_124
CREATERESFILE_44:       /* close it */
    _Close
CREATERESFILE_46:       /* done */
    jbra VRMGRSTDENTRY_AC

/* OPENRESFILE: _OpenResFile. */
trap_OpenResFile:
OPENRESFILE:
    jbsr SKIPTOENTRY_1E
OPENRESFILE_4:          /* open it, read the map; the new map goes on top of the chain and becomes current; preload */
    movel MinusOne,LastSPExtra
    moveal %a0@,%a1
    jbsr VSUPERLOAD_132
    movew %d6,%fp@(12)
    jbmi OPENRESFILE_2C
    movew %d6,CurMap
    tstw %d0
    jbeq OPENRESFILE_2C
    movel TopMapHndl,%a1@(16)
    movel %a4,TopMapHndl
    jbsr ADDROMRSRC_4E
OPENRESFILE_2C:         /* done */
    jbra VRMGRSTDENTRY_AC

/* OPENRFPERM: _OpenRFPerm. */
trap_OpenRFPerm:
OPENRFPERM:             /* (the permission byte, then as OpenResFile) */
    moveal %sp@+,%a0
    moveb %sp@+,RMgrPerm
    movew %sp@+,%d0
    movel %a0,%sp@-
    jbsr SKIPTOENTRY_1E
    movew %d0,%fp@(-28)
    jbra OPENRESFILE_4

/* USERESFILE: _UseResFile. */
trap_UseResFile:
USERESFILE:             /* (CurMap = the file) */
    jbsr SETRESFILEATTRS_18
    movew %d6,CurMap
    jbra VRMGRSTDENTRY_B0

/* GETRESFILEATTRS: _GetResFileAttrs. */
trap_GetResFileAttrs:
GETRESFILEATTRS:        /* (the map's attributes, +22) */
    jbsr SETRESFILEATTRS_18
    moveb %a3@(22),%fp@(11)
    jbra VRMGRSTDENTRY_B0

/* SETRESFILEATTRS: _SetResFileAttrs. */
trap_SetResFileAttrs:
SETRESFILEATTRS:
    jbsr SKIPTOENTRY_1E
    movew %fp@(10),%d6
    jbsr GETNAMEDRESOURCE_6E
    jbmi SETRESFILEATTRS_14
    moveb %fp@(9),%a3@(22)
SETRESFILEATTRS_14:     /* done */
    jbra VRMGRSTDENTRY_AC

SETRESFILEATTRS_18:     /* find the map of the refNum on the stack (resFNotFound) */
    movel %sp@+,%d0
    jbsr SKIPTOENTRY_1E
    movel %d0,%sp@-
    movew %a0@,%d6
    jbsr GETNAMEDRESOURCE_6E
    jbmi SETRESFILEATTRS_2A
    rts
SETRESFILEATTRS_2A:     /* resFNotFound */
    addqw #4,%sp
    movew #-193,ResErr	/* resFNotFound */
    jbra VRMGRSTDENTRY_B0

SETRESFILEATTRS_36:     /* the reference with the lowest data offset (d1 = 0: any) */
    moveq #0,%d1

SETRESFILEATTRS_38:     /* from the start (with attribute bit d1: 1 changed, 2 preload) */
    moveq #-1,%d0
    jbra SETRESFILEATTRS_46

SETRESFILEATTRS_3C:     /* the next one after this reference's offset */
    moveq #0,%d1

SETRESFILEATTRS_3E:     /* (after the offset of a2) */
    movel %a2@(4),%d0
    andl Lo3Bytes,%d0
SETRESFILEATTRS_46:     /* walk all references: the lowest offset above d2 (with the attribute) */
    moveml %d2-%d7/%a3,%sp@-
    movel %d0,%d2
    jbsr GETTYPES_C
    jbmi SETRESFILEATTRS_B0
    lea MinusOne,%a3
    subql #4,%a3
    movel %a3,%d6
    moveq #-1,%d7
    lsrl #1,%d7
    tstw %d1
    jbeq SETRESFILEATTRS_86
SETRESFILEATTRS_62:     /* with the attribute */
    btst %d1,%a2@(4)
    jbeq SETRESFILEATTRS_7C
    movel %a2@(4),%d0
    andl Lo3Bytes,%d0
    cmpl %d0,%d2
    jbge SETRESFILEATTRS_7C
    cmpl %d0,%d7
    jble SETRESFILEATTRS_7C
    movel %d0,%d7
    movel %a2,%d6
SETRESFILEATTRS_7C:     /* next */
    lea %a2@(12),%a2
    dbf %d4,SETRESFILEATTRS_62
    jbra SETRESFILEATTRS_A2
SETRESFILEATTRS_86:     /* any */
    movel %a2@(4),%d0
    andl Lo3Bytes,%d0
    cmpl %d0,%d2
    jbge SETRESFILEATTRS_9A
    cmpl %d0,%d7
    jble SETRESFILEATTRS_9A
    movel %d0,%d7
    movel %a2,%d6
SETRESFILEATTRS_9A:     /* next */
    lea %a2@(12),%a2
    dbf %d4,SETRESFILEATTRS_86
SETRESFILEATTRS_A2:     /* a2 = it (N set if none) */
    moveal %d6,%a2
    movel %d7,%d0
    movel %a2@(4),%d7
    andl Lo3Bytes,%d7
    cmpl %d0,%d7
SETRESFILEATTRS_B0:     /* return */
    moveml %sp@+,%d2-%d7/%a3
    rts

/*
 _UpdateResFile: if the map changed (attribute bit 5), write the changed resources and
 the map. Without compaction (bit 6) each changed resource is written in place;
 with it the data area is rewritten in data order, resources closing up the gaps
 (VCMPFRM), through a buffer, then the header and the map. A read-only map
 (bit 7): mapReadErr.
*/
trap_UpdateResFile:
UPDATERESFILE:
    jbsr SETRESFILEATTRS_18
    jbsr VCHECKLOAD_1F4
    jbeq UPDATERESFILE_14
    movew #-199,ResErr	/* mapReadErr */
    jbra VRMGRSTDENTRY_B0
UPDATERESFILE_14:       /* changed? */
    btst #5,%a0@(22)
    jbeq VRMGRSTDENTRY_B0
    jbsr VCHECKLOAD_14A
    jbmi VRMGRSTDENTRY_B0
    bclr #6,%a3@(22)
    jbne UPDATERESFILE_44
    moveq #1,%d1
    jbsr SETRESFILEATTRS_38
    jbmi UPDATERESFILE_40
UPDATERESFILE_36:       /* write each changed resource where it is */
    jbsr VCHECKLOAD_DE
    jbsr SETRESFILEATTRS_3E
    jbeq UPDATERESFILE_36
UPDATERESFILE_40:       /* then the map */
    jbra VCMPFRM_3C
UPDATERESFILE_44:       /* compact: the data area may start earlier (the map moved down) */
    jbsr SETRESFILEATTRS_36
    jbmi VCMPFRM_3C
    moveal %a4@,%a0
    movel %a0@,%d7
    subl %a0@(4),%d7
    jbcs UPDATERESFILE_6E
    jbsr GETTYPES_C
UPDATERESFILE_5A:       /* shift every offset */
    addl %d7,%a2@(4)
    lea %a2@(12),%a2
    dbf %d4,UPDATERESFILE_5A
    movel %a0@(4),%a0@
    jbsr SETRESFILEATTRS_36
UPDATERESFILE_6E:       /* d7 = the next write position */
    moveq #0,%d7
    jbra UPDATERESFILE_9E
UPDATERESFILE_72:       /* a changed resource: its new size */
    btst #1,%a2@(4)
    jbeq UPDATERESFILE_86
    jbsr VCHECKLOAD_DE
    moveal %a2@(8),%a0
    _GetHandleSize
    jbra UPDATERESFILE_8A
UPDATERESFILE_86:       /* unchanged: its size on disk */
    jbsr VCHECKLOAD_9C
UPDATERESFILE_8A:       /* next position; already there? */
    addql #4,%d0
    movel %a2@(4),%d7
    addl %d0,%d7
    andl Lo3Bytes,%d7
    jbsr SETRESFILEATTRS_3C
    jbmi VCMPFRM_38
UPDATERESFILE_9E:       /* resources already in place need not move */
    movel %d7,%d0
    subl %a2@(4),%d0
    andl Lo3Bytes,%d0
    jbeq UPDATERESFILE_72
    subal %a4@,%a2
    jbsr VCHECKLOAD_15E
    movel %d0,%d3
    _MaxBlock
    cmpl %d3,%d0
    jbge UPDATERESFILE_BA
    exg %d3,%d0
UPDATERESFILE_BA:       /* a buffer: at least 1 KB on the stack, or a locked handle */
    moveq #64,%d0
    aslw #4,%d0
    cmpl %d0,%d3
    jbge UPDATERESFILE_CC
    movel %d0,%d3
    linkw %a3,#-1024
    movel %sp,%a3@
    jbra UPDATERESFILE_D4
UPDATERESFILE_CC:       /* lock it */
    movel %d3,%d0
    .short  0xA122	| 4081B17C _NewHandle (flags 0x0100)
    _HLock
    moveal %a0,%a3
UPDATERESFILE_D4:       /* on to VCMPFRM (the vector at 0x7E8) */
    addal %a4@,%a2
    movel %a3@,%d0
    _StripAddress
    addl %d0,%d3
    moveal %d0,%a1
    movel %a1,%d4
    movel %d7,%d5
    moveal 0x7e8,%a0
    jmp %a0@

/*
 VCMPFRM: compact the resource file: copy each resource, in data order, down to the
 write position (d7), through the buffer (a3, end d3): changed ones from memory,
 others read from the file. Then the map is written after the data and the header
 updated.
*/
trap_VCMPFRM:
VCMPFRM:
    btst #1,%a2@(4)
    jbeq VCMPFRM_C
    jbsr VCMPFRM_66
    jbpl VCMPFRM_10
VCMPFRM_C:              /* from the file */
    jbsr VCMPFRM_EE
VCMPFRM_10:             /* next resource; at the end write what is left in the buffer */
    jbsr SETRESFILEATTRS_3C
    jbeq trap_VCMPFRM
    movel %a1,%d0
    subl %a3@,%d0
    _StripAddress
    movel %a3@,%d1
    moveal %a4@,%a0
    movel %d7,%d2
    addl %a0@,%d2
    jbsr VCHECKLOAD_124
    addl %d0,%d7
    cmpal %sp,%a3
    bhis VCMPFRM_10_24
    moveal %a3,%a0
    _DisposHandle
    bras VCMPFRM_10_26
VCMPFRM_10_24:
    unlk %a3
VCMPFRM_10_26:
    moveal %a4@,%a3
VCMPFRM_38:             /* the data length */
    movel %d7,%a3@(8)
VCMPFRM_3C:             /* map changed? write the map and the header */
    bclr #5,%a3@(22)
    jbeq VCMPFRM_62
    movel %a3@(8),%d2
    addl %a3@,%d2
    movel %d2,%a3@(4)
    movel %a3@(12),%d0
    movel %a3,%d1
    jbsr VCHECKLOAD_124
    moveq #16,%d0
    jbsr VCHECKLOAD_122
    jbsr VCHECKLOAD_14A
VCMPFRM_62:             /* done */
    jbra VRMGRSTDENTRY_B0

VCMPFRM_66:             /* a changed resource: from its handle into the buffer (length first), flushing the buffer when full */
    jbsr VCMPFRM_1AE
    moveal %a2@(8),%a0
    _GetHandleSize
    tstl %d0
    jbmi SKIPTOENTRY_1A
    jbsr VCMPFRM_BE
    jbsr VCMPFRM_DC
    movel %d0,%d2
    addl %a1,%d2
    cmpl %d2,%d4
    moveal %a0@,%a0
    jbge VCMPFRM_A8
    movel %d0,%d2
    moveq #0,%d1
VCMPFRM_88:             /* copy as much as fits */
    moveal %a2@(8),%a0
    moveal %a0@,%a0
    addal %d1,%a0
    movel %d3,%d0
    subl %a1,%d0
    cmpl %d2,%d0
    jbge VCMPFRM_A4
    addl %d0,%d1
    subl %d0,%d2
    jbsr VCMPFRM_A6
    jbsr VCMPFRM_1AE
    jbra VCMPFRM_88
VCMPFRM_A4:             /* the rest */
    movel %d2,%d0

VCMPFRM_A6:             /* d4 = the buffer position */
    movel %a1,%d4

VCMPFRM_A8:             /* copy */
    cmpal %a0,%a1
    jbeq VCMPFRM_B2
    movel %d0,%sp@-
    _BlockMove
    movel %sp@+,%d0

VCMPFRM_B2:             /* advance */
    addl %d0,%d5
    addal %d0,%a1
VCMPFRM_B6:             /* the buffer's high mark */
    cmpl %a1,%d4
    jbge VCMPFRM_BC
    movel %a1,%d4
VCMPFRM_BC:             /* return */
    rts

VCMPFRM_BE:             /* the reference's new data offset */
    moveml %d0-%d1/%a0,%sp@-
    moveq #-3,%d1
    lea %a2@(4),%a0
    andb %a0@,%d1
    movel %a1,%d0
    subl %a3@,%d0
    addl %d7,%d0
    movel %d0,%a0@
    moveb %d1,%a0@
    moveml %sp@+,%d0-%d1/%a0
    rts

VCMPFRM_DA:             /* length 0 */
    moveq #0,%d0

VCMPFRM_DC:             /* a long into the buffer */
    movel %d1,%sp@-
    moveq #3,%d1
VCMPFRM_E0:             /* byte by byte */
    roll #8,%d0
    moveb %d0,%a1@+
    dbf %d1,VCMPFRM_E0
    addql #4,%d5
    movel %sp@+,%d1
    jbra VCMPFRM_B6

VCMPFRM_EE:             /* an unchanged resource: read it from the file into the buffer (in pieces if needed) */
    movel %a2@(4),%d0
    andl Lo3Bytes,%d0
    subl %d5,%d0
    jbge VCMPFRM_102
    jbsr VCMPFRM_1AE
    jbsr VCMPFRM_BE
    jbra VCMPFRM_DA
VCMPFRM_102:            /* fits? */
    addl %a1,%d0
    addql #4,%d0
    cmpl %d0,%d4
    jbge VCMPFRM_11A
    jbsr VCMPFRM_1AE
    movel %a2@(4),%d0
    andl Lo3Bytes,%d0
    movel %d0,%d5
    jbsr VCMPFRM_17C
VCMPFRM_11A:            /* its length; copy */
    movel %a2@(4),%d0
    jbsr VCMPFRM_BE
    subl %d5,%d0
    andl Lo3Bytes,%d0
    moveal %a1,%a0
    addal %d0,%a0
    jbsr VSUPERLOAD_9C
    addql #4,%d0
    subql #4,%a0
    movel %d0,%d2
    addl %a0,%d2
    cmpl %d2,%d4
    jbge VCMPFRM_A8
    addl %a0,%d5
    subl %a1,%d5
    andl Lo3Bytes,%d5
    movel %d0,%d2
    movel %d4,%d0
    subl %a0,%d0
    jbsr VCMPFRM_A8
    movel %a1,%d4
VCMPFRM_150:            /* more to read */
    jbsr VCMPFRM_1AE
    jbsr VCMPFRM_17C
    jbeq VCMPFRM_172
    subl %d0,%d2
    moveal %a1,%a0
    addal %d2,%a0
    cmpl %a0,%d4
    jbge VCMPFRM_16A
    movel %d4,%d0
    subl %a1,%d0
    jbsr VCMPFRM_B2
    jbra VCMPFRM_150
VCMPFRM_16A:            /* the rest */
    movel %a0,%d0
    subl %a1,%d0
    jbra VCMPFRM_B2
VCMPFRM_172:            /* mapReadErr */
    movew #-199,ResErr	/* mapReadErr */
    jbra VCMPFRM_B6

VCMPFRM_17C:            /* read the next piece of the data area into the buffer */
    moveml %d0-%d2/%a0,%sp@-
    jbsr VCHECKLOAD_15E
    moveal %a4@,%a0
    subl %d5,%d0
    subl %a0@,%d0
    andl Lo3Bytes,%d0
    movel %d3,%d1
    subl %a1,%d1
    cmpl %d1,%d0
    jble VCMPFRM_198
    movel %d1,%d0
VCMPFRM_198:            /* read */
    movel %a1,%d1
    movel %d5,%d2
    addl %a0@,%d2
    movel %a1,%d4
    addl %d0,%d4
    jbsr VCHECKLOAD_11A
    tstl %d0
    moveml %sp@+,%d0-%d2/%a0
    rts

VCMPFRM_1AE:            /* write the full 512-byte blocks of the buffer to the file */
    moveml %d0-%d2,%sp@-
    movel %a1,%d0
    subl %a3@,%d0
    andl Lo3Bytes,%d0
    jbeq VCMPFRM_1EC
    moveal %a4@,%a0
    movel %d7,%d2
    addl %a0@,%d2
    addl %d2,%d0
    andiw #-512,%d0
    subl %d2,%d0
    jble VCMPFRM_1EC
    movel %a3@,%d1
    jbsr VCHECKLOAD_124
    addl %d0,%d7	| 4081B368
    subal %d0,%a1
    subl %d0,%d4
    movel %a1,%sp@-
    moveal %a3@,%a1
    moveal %a3@,%a0
    addal %d0,%a0
    addl %d4,%d0
    subl %a0,%d0
    andl Lo3Bytes,%d0
    _BlockMove
    moveal %sp@+,%a1
VCMPFRM_1EC:            /* return */
    moveml %sp@+,%d0-%d2
    rts

/* CLOSERESFILE: _CloseResFile. */
trap_CloseResFile:
CLOSERESFILE:           /* (refNum 0: everything above the System file first; write it, dispose of its loaded resources and the map, unlink it) */
    movel MinusOne,LastSPExtra
    movew RMgrLastResFile,%d0
    cmpw %sp@(4),%d0
    jbne CLOSERESFILE_14
    clrl RMgrLastResHand
CLOSERESFILE_14:        /* refNum 0? */
    tstw %sp@(4)
    jbne CLOSERESFILE_1E
    jbsr RSRCZONEINIT_2E
CLOSERESFILE_1E:        /* update the file; _DisposHandle's address (GetTrapAddress 35), called for each loaded resource */
    jbsr SETRESFILEATTRS_18
    movew %d6,%sp@-
    _UpdateResFile
    moveq #35,%d0
    .short  0xA146	| 4081B3B0 _GetTrapAddress (flags 0x0100)
    jbsr GETTYPES_C
    jbmi CLOSERESFILE_42
    moveal %a0,%a4
    addqw #8,%a2
CLOSERESFILE_34:        /* each handle */
    movel %a2@+,%d0
    jbeq CLOSERESFILE_3C
    moveal %d0,%a0
    jsr %a4@
CLOSERESFILE_3C:        /* next */
    addqw #8,%a2
    dbf %d4,CLOSERESFILE_34
CLOSERESFILE_42:        /* unlink the map */
    jbsr GETNAMEDRESOURCE_6E
    moveal %a3@(16),%a0
    tstl %d0
    jbne CLOSERESFILE_54
    movel %a0,TopMapHndl
    jbra CLOSERESFILE_5C
CLOSERESFILE_54:        /* from the map above it */
    moveal %d0,%a1
    moveal %a1@,%a1
    movel %a0,%a1@(16)
CLOSERESFILE_5C:        /* the System file: only the ROM map is left */
    cmpal SysMapHndl,%a4
    jbne CLOSERESFILE_7E
    lea TopMapHndl,%a0
    movel ROMMapHandle,%a0@+
    movel ROMMapHandle,%a0@+
    movel OneOne,%a0@+
    moveal ROMMapHandle,%a0
    moveal %a0@,%a0
    clrl %a0@(16)
    jbra CLOSERESFILE_8C
CLOSERESFILE_7E:        /* it was current: the next map down becomes current */
    cmpw CurMap,%d6
    jbne CLOSERESFILE_8C
    moveal %a0@,%a0
    movew %a0@(20),CurMap
CLOSERESFILE_8C:        /* close the file */
    jbsr VCHECKLOAD_100
    _Close
    jbeq CLOSERESFILE_98
    movew %d0,ResErr
CLOSERESFILE_98:        /* dispose of the map */
    moveal %a4,%a0
    _DisposHandle
    jbra VRMGRSTDENTRY_B0

/* COUNT1RESOURCES: _Count1Resources. */
trap_Count1Resources:
COUNT1RESOURCES:
    st RMgrCurOnly

/* COUNTRESOURCES: _CountResources. */
trap_CountResources:
COUNTRESOURCES:
    jbsr SKIPTOENTRY_26
    movel %a0@,%d3
    moveq #0,%d1
    jbsr GETNAMEDRESOURCE_56
COUNTRESOURCES_C:       /* each map of the chain (or the current only): the type's count */
    jbsr TYPESCAN
    jbmi COUNTRESOURCES_18
    addw %a2@(4),%d1
    addqw #1,%d1
COUNTRESOURCES_18:      /* next map */
    jbsr GETNAMEDRESOURCE_98
    jbeq COUNTRESOURCES_C
    movew %d1,%fp@(12)
    jbra VRMGRSTDENTRY_AC

/* GET1INDRESOURCE: _Get1IxResource. */
trap_Get1IxResource:
GET1INDRESOURCE:
    st RMgrCurOnly

/* GETINDRESOURCE: _GetIndResource. */
trap_GetIndResource:
GETINDRESOURCE:         /* (d7 = index, d3 = type; the next index of the last call is quick: RMgrNextResIndex) */
    jbsr SKIPTOENTRY_26
    movew %a0@+,%d7
    jble GETINDRESOURCE_8E
    movel %a0@+,%d3
    clrl %a0@+
    moveb RMgrCurOnly,%d0
    cmpb RMgrLastCurOnly,%d0
    jbne GETINDRESOURCE_42
    tstl RMgrLastResHand
    jbeq GETINDRESOURCE_42
    cmpl RMgrHiVars_LastResType,%d3
    jbne GETINDRESOURCE_42
    cmpw RMgrNextResIndex,%d7
    jbne GETINDRESOURCE_42
    addqw #1,RMgrNextResIndex
    jbsr VRMGRSTDEXIT_7E
    tstw %d4
    jbeq GETINDRESOURCE_3E
    subqw #1,%d4
    lea %a2@(12),%a2
    jbra GETINDRESOURCE_7C
GETINDRESOURCE_3E:      /* (the next one is in another map) */
    moveq #0,%d7
    jbra GETINDRESOURCE_74
GETINDRESOURCE_42:      /* from the first map */
    moveb %d0,RMgrLastCurOnly
    movew %d7,RMgrNextResIndex
    addqw #1,RMgrNextResIndex
    subqw #1,%d7
    jbsr GETNAMEDRESOURCE_56
GETINDRESOURCE_54:      /* this map's references of the type: is the index among them? */
    jbsr TYPESCAN
    jbmi GETINDRESOURCE_74
    jbsr SKIPTOENTRY
    cmpw %d7,%d4
    jbmi GETINDRESOURCE_70
    subw %d7,%d4
    addw %d7,%d7
    addw %d7,%d7
    addaw %d7,%a2
    addw %d7,%d7
    addaw %d7,%a2
    jbra GETINDRESOURCE_7C
GETINDRESOURCE_70:      /* no: count them off */
    subw %d4,%d7
    subqw #1,%d7
GETINDRESOURCE_74:      /* next map */
    jbsr GETNAMEDRESOURCE_98
    jbeq GETINDRESOURCE_54
    jbmi GETINDRESOURCE_8E
GETINDRESOURCE_7C:      /* found: load it, remember it */
    jbsr VRMGRSTDEXIT_A2
    jbsr VRMGRSTDEXIT_12A
    movel %a0,%fp@(14)
    movel %a0,RMgrLastResHand
    jbra GETINDRESOURCE_94
GETINDRESOURCE_8E:      /* resNotFound */
    movew #-192,ResErr	/* resNotFound */
GETINDRESOURCE_94:      /* done */
    jbra VRMGRSTDENTRY_A8

/* COUNT1TYPES: _Count1Types. */
trap_Count1Types:
COUNT1TYPES:
    st RMgrCurOnly

/* COUNTTYPES: _CountTypes. */
trap_CountTypes:
COUNTTYPES:             /* (the distinct types of the chain, collected on the stack) */
    jbsr SKIPTOENTRY_26
    jbsr COUNTTYPES_10
    unlk %fp
    movew %d7,%fp@(8)
    jbra VRMGRSTDENTRY_B4

COUNTTYPES_10:          /* collect the types of every map (or the current) on the stack: d7 = count */
    moveal %sp@+,%a0
    linkw %fp,#0
    moveq #0,%d7
    jbsr GETNAMEDRESOURCE_56
COUNTTYPES_1C:          /* next map */
    jbsr GETTYPES
    jbmi COUNTTYPES_3E
COUNTTYPES_22:          /* each type: already collected? */
    movel %a2@,%d3
    moveal %sp,%a1
    movew %d7,%d0
    subqw #1,%d0
    jbmi COUNTTYPES_34
COUNTTYPES_2C:          /* compare */
    cmpl %a1@+,%d3
    dbeq %d0,COUNTTYPES_2C
    jbeq COUNTTYPES_38
COUNTTYPES_34:          /* new: push it */
    movel %d3,%sp@-
    addqw #1,%d7
COUNTTYPES_38:          /* next type */
    addql #8,%a2
    dbf %d5,COUNTTYPES_22
COUNTTYPES_3E:          /* next map */
    jbsr GETNAMEDRESOURCE_98
    jbeq COUNTTYPES_1C
    jmp %a0@

/* GET1INDTYPE: _Get1IxType. */
trap_Get1IxType:
GET1INDTYPE:
    st RMgrCurOnly

/* GETINDTYPE: _GetIndType. */
trap_GetIndType:
GETINDTYPE:
    jbsr SKIPTOENTRY_26
    movew %a0@+,%d2
    movel %a0@,%d1
    jbsr COUNTTYPES_10
    moveal %d1,%a0
    clrl %a0@
    subqw #1,%d2
    jbmi GETINDTYPE_1C
    cmpw %d2,%d7
    jble GETINDTYPE_1C
    aslw #2,%d2
    movel %sp@(0x0,%d2:w),%a0@
GETINDTYPE_1C:          /* the n-th collected type */
    unlk %fp
    jbra VRMGRSTDENTRY_A8

/* UNIQUE1ID: _Unique1ID. */
trap_Unique1ID:
UNIQUE1ID:
    st RMgrCurOnly

/* UNIQUEID: _UniqueID. */
trap_UniqueID:
UNIQUEID:               /* (a random ID (Ticks + Random, positive) not used by the type in any map) */
    jbsr SKIPTOENTRY_26
    movew Ticks_LoWord,%d7
UNIQUEID_8:             /* a new candidate */
    jbsr GETNAMEDRESOURCE_56
    subqw #2,%sp
    _Random
    addw %sp@+,%d7
    andiw #32767,%d7
    movel %fp@(8),%d3
    movew %d7,%d2
UNIQUEID_1C:            /* in use in this map? try another */
    jbsr TYPESCAN
    jbmi UNIQUEID_2C
    jbsr SKIPTOENTRY
    jbsr IDSCAN
    jbeq UNIQUEID_8
UNIQUEID_2C:            /* next map */
    jbsr GETNAMEDRESOURCE_98
    jbeq UNIQUEID_1C
    movew %d2,%fp@(12)
    jbra VRMGRSTDENTRY_AC

/* GET1RESOURCE: _Get1Resource. */
trap_Get1Resource:
GET1RESOURCE:
    st RMgrCurOnly

/* GETRESOURCE: _GetResource: search the resource file chain for type and ID, load it. */
trap_GetResource:
GETRESOURCE:            /* (from the current map down the chain; Get1Resource: the current map only) */
    jbsr SKIPTOENTRY_26
    jbsr GETNAMEDRESOURCE_6A
    jbpl GETRESOURCE_E
    jbsr GETNAMEDRESOURCE_56
GETRESOURCE_E:          /* d2 = ID, d3 = type */
    movew %a0@+,%d2
    movel %a0@+,%d3
    clrl %a0@
GETRESOURCE_14:         /* this map: the type, then the ID */
    jbsr TYPESCAN
    jbmi GETRESOURCE_24
    jbsr SKIPTOENTRY
    jbsr IDSCAN
    jbeq GETRESOURCE_2C
GETRESOURCE_24:         /* next map */
    jbsr GETNAMEDRESOURCE_98
    jbeq GETRESOURCE_14
    jbra GETRESOURCE_3C
GETRESOURCE_2C:         /* found: remember it, load it (CheckLoad) */
    jbsr VRMGRSTDEXIT_9C
    jbsr VRMGRSTDEXIT_12A
    movel %a0,%fp@(14)
    movel %a0,RMgrLastResHand
GETRESOURCE_3C:         /* done */
    jbra VRMGRSTDENTRY_A8

/* GET1NAMEDRESOURCE: _Get1NamedResource. */
trap_Get1NamedResource:
GET1NAMEDRESOURCE:
    st RMgrCurOnly

/* GETNAMEDRESOURCE: _GetNamedResource. */
trap_GetNamedResource:
GETNAMEDRESOURCE:
    jbsr SKIPTOENTRY_26
    jbsr GETNAMEDRESOURCE_6A
    moveal %a0@,%a1
    clrl %fp@(16)
GETNAMEDRESOURCE_C:     /* this map: the type */
    movel %fp@(12),%d3
    jbsr TYPESCAN
    jbmi GETNAMEDRESOURCE_34
    jbsr SKIPTOENTRY
GETNAMEDRESOURCE_1A:    /* each reference: its name equals (CmpString)? */
    jbsr VRMGRSTDEXIT_BA
    jbmi GETNAMEDRESOURCE_2E
    moveq #0,%d0
    moveb %a0@+,%d0
    swap %d0
    moveb %a1@+,%d0
    _CmpString
    subqw #1,%a1
    jbeq GETNAMEDRESOURCE_40
GETNAMEDRESOURCE_2E:    /* next reference */
    jbsr VRMGRSTDEXIT_D4
    jbeq GETNAMEDRESOURCE_1A
GETNAMEDRESOURCE_34:    /* next map; none: resNotFound */
    jbsr GETNAMEDRESOURCE_98
    jbeq GETNAMEDRESOURCE_C
    movew #-192,ResErr	/* resNotFound */
    jbra GETNAMEDRESOURCE_50
GETNAMEDRESOURCE_40:    /* found: load it */
    jbsr VRMGRSTDEXIT_9C
    jbsr VRMGRSTDEXIT_12A
    movel %a0,%fp@(16)
    movel %a0,RMgrLastResHand
GETNAMEDRESOURCE_50:    /* done */
    moveq #8,%d0
    jbra VRMGRSTDENTRY_B6

GETNAMEDRESOURCE_56:    /* the first map to search: the top (or, for Get1..., the current) */
    tstb RMgrCurOnly
    jbne GETNAMEDRESOURCE_6A
    moveal TopMapHndl,%a4
    moveal %a4@,%a3
    movew %a3@(20),%d6
    moveal %a3,%a2
    rts

GETNAMEDRESOURCE_6A:    /* the current map */
    movew CurMap,%d6

GETNAMEDRESOURCE_6E:    /* the map of refNum d6 (0: the System file): a4 = handle, a3 = map */
    tstw %d6
    jbmi SKIPTOENTRY_1A
    jbne GETNAMEDRESOURCE_7A
    movew SysMap,%d6
GETNAMEDRESOURCE_7A:    /* walk the chain */
    moveal TopMapHndl,%a4
    moveq #0,%d0
    jbra GETNAMEDRESOURCE_8C
GETNAMEDRESOURCE_82:    /* next */
    movel %a3@(16),%d0
    jbeq SKIPTOENTRY_1A
    exg %d0,%a4
GETNAMEDRESOURCE_8C:    /* this one? */
    moveal %a4@,%a3
    cmpw %a3@(20),%d6
    jbne GETNAMEDRESOURCE_82
    moveal %a3,%a2
    rts

GETNAMEDRESOURCE_98:    /* the next map down (none for Get1...) */
    tstb RMgrCurOnly
    jbeq GETNAMEDRESOURCE_A2
    subal %a4,%a4
    jbra GETNAMEDRESOURCE_A8
GETNAMEDRESOURCE_A2:    /* next */
    moveal %a4@,%a3
    moveal %a3@(16),%a4
GETNAMEDRESOURCE_A8:    /* d6 = its refNum */
    movel %a4,%d0
    jbeq SKIPTOENTRY_1A
    moveal %a4@,%a3
    movew %a3@(20),%d6
    jbra SKIPTOENTRY_16

/* GETTYPES: the type list of a map. */
GETTYPES:               /* (a3 = the type list, d5 = type count - 1, a2 = the first type) */
    moveal %a4@,%a3
    addaw %a3@(24),%a3
    moveal %a3,%a2
    movew %a2@+,%d5
    rts

GETTYPES_C:             /* all references of the map: a2 = the first, d4 = count - 1 */
    jbsr GETTYPES_20
    jbmi GETTYPES_1E
    addqw #6,%a3
    addw %d5,%d4
    jbra GETTYPES_1A
GETTYPES_16:            /* add each type's count */
    addqw #8,%a3
    addw %a3@,%d4
GETTYPES_1A:            /* count down */
    dbf %d5,GETTYPES_16
GETTYPES_1E:            /* return */
    rts

GETTYPES_20:            /* the first type's references */
    jbsr GETTYPES
    movel %a2@,%d3
    jbsr SKIPTOENTRY
    tstw %d5
    rts

/* IDSCAN: find an ID in a type's references. */
IDSCAN:                 /* (find ID d2 among the d4+1 references at a2) */
    moveq #12,%d0
IDSCAN_2:               /* compare */
    cmpw %a2@,%d2
    addaw %d0,%a2
    dbeq %d4,IDSCAN_2
    jbeq SKIPTOENTRY_14
    jbra SKIPTOENTRY_1A

/* TYPESCAN: find a type in a map. */
TYPESCAN:               /* (find type d3 in the map: a2 = its entry) */
    jbsr GETTYPES
    jbmi SKIPTOENTRY_1A
    moveq #8,%d0
TYPESCAN_6:             /* compare */
    cmpl %a2@,%d3
    addaw %d0,%a2
    dbeq %d5,TYPESCAN_6
    jbeq SKIPTOENTRY_14
    jbra SKIPTOENTRY_1A

/* SKIPTOENTRY: skip to a map entry. */
SKIPTOENTRY:            /* (type entry a2: d4 = its count - 1, a2 = its first reference) */
    movew %a2@(4),%d4
    movel %d0,%sp@-
    moveq #0,%d0
    movew %a2@(6),%d0
    moveal %d0,%a2
    movel %sp@+,%d0
    addal %a3,%a2
    rts
SKIPTOENTRY_14:         /* found: back to it */
    subaw %d0,%a2
SKIPTOENTRY_16:         /* 0 */
    moveq #0,%d0
    rts

SKIPTOENTRY_1A:         /* -1 */
    moveq #-1,%d0
    rts

SKIPTOENTRY_1E:         /* entry, ROM map not inserted */
    clrw ROMMapInsert

SKIPTOENTRY_22:         /* entry, the whole chain */
    clrb RMgrCurOnly

SKIPTOENTRY_26:         /* the common entry (through the vector at 0x698: VRMGRSTDENTRY) */
    moveal 0x698,%a0
    jmp %a0@

/*
 VRMGRSTDENTRY: the common entry of the Resource Manager calls: ResErr = 0, a frame
 with a 50-byte File Manager parameter block (fp-50), registers saved, a0 = the
 caller's parameters (fp+8). With ROMMapInsert set (RGetResource and the 'ROM'
 calls) the ROM map is linked into the chain just under the system map for this call
 (VRMGRSTDENTRY_30), and ResLoad is swapped with TmpResLoad. The exits (_A8.._B6, d0 =
 bytes of parameters) go through the vector at 0x69C (VRMGRSTDEXIT).
*/
trap_VRMGRSTDENTRY:
VRMGRSTDENTRY:
    clrw ResErr
    moveal %sp@+,%a0
    linkw %fp,#-50	/* a 50-byte parameter block for the File Manager */
    clrw %fp@(-28)
    clrw %fp@(-24)
    moveb RMgrPerm,%fp@(-23)
    moveml %d1-%d7/%a1-%a4,%sp@-
    subal %a4,%a4
    movel %a0,%sp@-
    lea %fp@(8),%a0
    tstb ROMMapInsert
    jbeq VRMGRSTDENTRY_2E
    moveq #0,%d1
    jbsr VRMGRSTDENTRY_30
VRMGRSTDENTRY_2E:       /* return */
    rts

VRMGRSTDENTRY_30:       /* insert (d1 = 0) or remove (d1 = -1) the ROM map under the system map; CurMap 1 (the ROM map) stands for the system map */
    moveml %d0/%a0-%a2,%sp@-
    moveal SysMapHndl,%a1
    moveal ROMMapHandle,%a2
    cmpal %a1,%a2
    jbeq VRMGRSTDENTRY_A2
    movew CurMap,%d0
    tstl %d1
    jbeq VRMGRSTDENTRY_58
    exg %a1,%a2
    cmpiw #1,%d0
    jbne VRMGRSTDENTRY_64
    movew SysMap,CurMap
    jbra VRMGRSTDENTRY_64
VRMGRSTDENTRY_58:       /* CurMap was the system map: 1 */
    cmpw SysMap,%d0
    jbne VRMGRSTDENTRY_64
    movew #1,CurMap
VRMGRSTDENTRY_64:       /* find the map that links to the system map */
    moveal TopMapHndl,%a0
VRMGRSTDENTRY_68:       /* next */
    moveal %a0@,%a0
    movel %a0@(16),%d0
    jbeq VRMGRSTDENTRY_7E
    cmpl %a1,%d0
    jbeq VRMGRSTDENTRY_78
    moveal %d0,%a0
    jbra VRMGRSTDENTRY_68
VRMGRSTDENTRY_78:       /* link the ROM map instead */
    movel %a2,%a0@(16)
    jbra VRMGRSTDENTRY_88
VRMGRSTDENTRY_7E:       /* the system map on top? */
    cmpal TopMapHndl,%a1
    jbne VRMGRSTDENTRY_88
    movel %a2,TopMapHndl
VRMGRSTDENTRY_88:       /* the ROM map links to the system map; swap ResLoad / TmpResLoad */
    moveal ROMMapHandle,%a0
    moveal %a0@,%a0
    movel SysMapHndl,%a0@(16)
    moveb ResLoad,%d0
    moveb TmpResLoad,ResLoad
    moveb %d0,TmpResLoad
VRMGRSTDENTRY_A2:       /* restore, return */
    moveml %sp@+,%d0/%a0-%a2
    rts

VRMGRSTDENTRY_A8:       /* exit popping 6 bytes */
    moveq #6,%d0
    jbra VRMGRSTDENTRY_B6

VRMGRSTDENTRY_AC:       /* exit popping 4 bytes */
    moveq #4,%d0
    jbra VRMGRSTDENTRY_B6

VRMGRSTDENTRY_B0:       /* exit popping 2 bytes */
    moveq #2,%d0
    jbra VRMGRSTDENTRY_B6

VRMGRSTDENTRY_B4:       /* exit, no parameters */
    moveq #0,%d0
VRMGRSTDENTRY_B6:       /* exit through 0x69C */
    moveal 0x69c,%a1
    jmp %a1@

/* VRMGRSTDEXIT: vectored: common exit (ResErr). */
trap_VRMGRSTDEXIT:
VRMGRSTDEXIT:           /* (remove the ROM map again, clear the per-call flags, restore, pop d0 bytes; an error calls ResErrProc) */
    tstb ROMMapInsert
    jbeq VRMGRSTDEXIT_C
    moveq #-1,%d1
    jbsr VRMGRSTDENTRY_30
VRMGRSTDEXIT_C:         /* clear the flags */
    clrb RMgrCurOnly
    clrw ROMMapInsert
    clrb RMgrPerm
    moveml %sp@+,%d1-%d7/%a1-%a4
    unlk %fp
    moveal %sp@+,%a0
    addal %d0,%sp
    movel %a0,%sp@-
    subal %a0,%a0
    movew ResErr,%d0
    jbeq VRMGRSTDEXIT_34
    movel ResErrProc,%sp@-
    jbne VRMGRSTDEXIT_34
    addqw #4,%sp
VRMGRSTDEXIT_34:        /* return */
    rts

VRMGRSTDEXIT_36:        /* find the reference of handle a1 (the last one found is checked first) */
    movel %a1,%d0
    jbeq SKIPTOENTRY_1A
    cmpal RMgrLastResHand,%a1
    jbeq VRMGRSTDEXIT_7E
VRMGRSTDEXIT_42:        /* search every map */
    jbsr GETNAMEDRESOURCE_56
    movel %a0,%sp@-
VRMGRSTDEXIT_48:        /* this map's references */
    jbsr GETTYPES_20
    jbmi VRMGRSTDEXIT_66
    moveal %a3,%a0
    addqw #8,%a0
VRMGRSTDEXIT_52:        /* next type */
    addqw #2,%a0
VRMGRSTDEXIT_54:        /* this handle? */
    addqw #8,%a2
    cmpal %a2@+,%a1
    dbeq %d4,VRMGRSTDEXIT_54
    jbeq VRMGRSTDEXIT_72
    movel %a0@+,%d3
    movew %a0@+,%d4
    dbf %d5,VRMGRSTDEXIT_52
VRMGRSTDEXIT_66:        /* next map; none: -1 */
    jbsr GETNAMEDRESOURCE_98
    jbeq VRMGRSTDEXIT_48
    moveal %sp@+,%a0
    jbra SKIPTOENTRY_1A
VRMGRSTDEXIT_72:        /* found */
    subaw #12,%a2
    jbsr VRMGRSTDEXIT_9C
    moveal %sp@+,%a0
    jbra SKIPTOENTRY_16

VRMGRSTDEXIT_7E:        /* the last resource found (saved state at 0xB8.. and 0xB94): still the same? */
    moveml RMgrHiVars_LastResType,%d3/%a1-%a4
    movemw 0xb94,%d4-%d6
    addal %a4@,%a2
    addal %a4@,%a3
    cmpal %a2@(8),%a1
    jbeq SKIPTOENTRY_16
    clrl RMgrLastResHand
    jbra VRMGRSTDEXIT_42

VRMGRSTDEXIT_9C:        /* remember the found resource (no index) */
    movew MinusOne,RMgrNextResIndex

VRMGRSTDEXIT_A2:        /* save the state relative to the map */
    movel %a4@,%d0
    subal %d0,%a2
    subal %d0,%a3
    moveml %d3/%a1-%a4,RMgrHiVars_LastResType
    movemw %d4-%d6,0xb94
    addal %d0,%a2
    addal %d0,%a3
    rts

VRMGRSTDEXIT_BA:        /* a0 = the reference's name (none: -1) */
    movew %a2@(2),%d0
    jbmi VRMGRSTDEXIT_CC
    moveal %a4@,%a0
    addaw %a0@(26),%a0
    addaw %d0,%a0
    jbra SKIPTOENTRY_16
VRMGRSTDEXIT_CC:        /* no name */
    lea %pc@(RMGR),%a0
    jbra SKIPTOENTRY_1A

VRMGRSTDEXIT_D4:        /* next reference, the next type at the end of one (d0 = 1 for a new type) */
    lea %a2@(12),%a2
    subqw #1,%d4
    jbpl SKIPTOENTRY_16
    subqw #1,%d5
    jbmi SKIPTOENTRY_1A
    movew %a3@,%d0
    subw %d5,%d0
    aslw #3,%d0
    movel %a3@(0x2,%d0:w),%d3
    movew %a3@(0x6,%d0:w),%d4
    moveq #1,%d0
    rts
VRMGRSTDEXIT_F6:        /* a ROM resource: its handle points into the ROM map's zone; the data is in the ROM */
    jbsr DOROMENTRYPATCH
    andl Lo3Bytes,%d0
    addl ROMBase,%d0
    moveal %d0,%a1
    moveal ROMMapHandle,%a0
    .short  0xA126	| 4081B8D4 _HandleZone (flags 0x0100)
    movel %a1@(-4),%d0
    andl Lo3Bytes,%d0
    addal %d0,%a0
    movel %a0,%a2@(8)
    tstb ResLoad
    jbeq VRMGRSTDEXIT_126
    movel %a1,%a0@
    jbsr VCHECKLOAD_82
VRMGRSTDEXIT_126:       /* return */
    moveal %sp@+,%a1
    rts

VRMGRSTDEXIT_12A:       /* load it (CheckLoad, through the vector at 0x7F0) */
    moveal 0x7f0,%a0
    jmp %a0@

/*
 VCHECKLOAD (a2 = reference): load the resource if needed: an empty handle is
 reallocated, a new one allocated (in the system heap for attribute bit 6, with
 ResrvMem for bit 4: locked), the data read from the file, the handle's flags set
 from the attributes (locked, purgeable, resource). With ResLoad off only the
 handle is made. Errors to ResErr.
*/
trap_VCHECKLOAD:
VCHECKLOAD:
    moveb %a2@(4),%d1
    cmpal ROMMapHandle,%a4
    jbeq VRMGRSTDEXIT_F6
    movel TheZone,%sp@-
    btst #6,%d1
    jbeq VCHECKLOAD_1A
    movel SysZone,TheZone
VCHECKLOAD_1A:          /* ResLoad? */
    moveal %a2@(8),%a0
    subal %a4@,%a3
    tstb ResLoad
    jbeq VCHECKLOAD_68
    movel %a0,%d0
    jbne VCHECKLOAD_44
    jbsr VCHECKLOAD_32
    .short  0xA122	| 4081B926 _NewHandle (flags 0x0100)
    jbeq VCHECKLOAD_4E
    jbra VCHECKLOAD_60

VCHECKLOAD_32:          /* the size from the file; ResrvMem for a locked resource */
    jbsr VCHECKLOAD_9C
    movel %d0,%d2
    subal %a4@,%a2
    btst #4,%d1
    jbeq VCHECKLOAD_40
    _ResrvMem
VCHECKLOAD_40:          /* d0 = size */
    movel %d2,%d0
    rts
VCHECKLOAD_44:          /* an empty handle: reallocate it */
    tstl %a0@
    jbne VCHECKLOAD_72
    jbsr VCHECKLOAD_32
    _ReallocHandle
    jbmi VCHECKLOAD_60
VCHECKLOAD_4E:          /* read it, set its flags */
    addal %a4@,%a2
    movel %a0,%a2@(8)
    jbsr VCHECKLOAD_B2
    jbsr VCHECKLOAD_82
    movew ResErr,%d0
    jbeq VCHECKLOAD_72
    subal %a4@,%a2
VCHECKLOAD_60:          /* failed: ResErr, no handle */
    movew %d0,ResErr
    subal %a0,%a0
    jbra VCHECKLOAD_70
VCHECKLOAD_68:          /* no loading: only the handle */
    movel %a0,%d0
    jbne VCHECKLOAD_72
    subal %a4@,%a2
    .short  0xA166	| 4081B968 _NewEmptyHandle (flags 0x0100)
VCHECKLOAD_70:          /* (offsets back) */
    addal %a4@,%a2
VCHECKLOAD_72:          /* the reference's handle */
    movel %a0,%d0
    jbeq VCHECKLOAD_7A
    movel %a0,%a2@(8)
VCHECKLOAD_7A:          /* the zone back */
    addal %a4@,%a3
    movel %sp@+,TheZone
    rts

VCHECKLOAD_82:          /* the handle's flags from the attributes: locked (bit 4), purgeable (5), resource */
    lslb #3,%d1
    rolb #1,%d1
    roxrb #2,%d1
    orib #32,%d1
    andib #0xe0,%d1
    _HGetState
    andib #31,%d0
    orb %d1,%d0
    _HSetState
    rts

VCHECKLOAD_9C:          /* d0 = the resource's length on disk (the long before its data) */
    moveml %d1-%d2/%a0-%a1,%sp@-
    jbsr VCHECKLOAD_C6
    subql #4,%sp
    movel %sp,%d1
    moveq #4,%d0
    jbsr VCHECKLOAD_11A
    movel %sp@+,%d0
    moveml %sp@+,%d1-%d2/%a0-%a1
    rts

VCHECKLOAD_B2:          /* read the data into the handle */
    moveml %d0-%d2/%a0-%a1,%sp@-
    movel %d2,%d0
    jbsr VCHECKLOAD_C6
    addql #4,%d2
    movel %a1@,%d1
    jbsr VCHECKLOAD_11A
VCHECKLOAD_B2_E:
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts

VCHECKLOAD_C6:          /* d2 = its file offset (the data area + its offset), a1 = handle; the changed bit cleared */
    andib #0xfd,%a2@(4)
    moveal %a4@,%a0
    movel %a2@(4),%d2
    andl Lo3Bytes,%d2
    addl %a0@,%d2
    moveal %a2@(8),%a1
    rts

VCHECKLOAD_DE:          /* write a changed resource in place (length, then data) */
    moveml %d0-%d2/%a0-%a1,%sp@-
    jbsr VCHECKLOAD_C6
    moveal %a1,%a0
    _GetHandleSize
    tstl %d0
    jbpl VCHECKLOAD_EE
    moveq #0,%d0
VCHECKLOAD_EE:          /* the length long */
    movel %d0,%sp@-
    movel %sp,%d1
    moveq #4,%d0
    jbsr VCHECKLOAD_124
    addql #4,%d2
    movel %a1@,%d1
    movel %sp@+,%d0
    bsrs VCHECKLOAD_124
    bras VCHECKLOAD_B2_E

VCHECKLOAD_100:         /* the parameter block: refNum, buffer, count, from the start at d2 */
    lea %fp@(-26),%a0
    movew %d6,%a0@+
    addqw #6,%a0
    movel %d1,%a0@+
    movel %d0,%a0@+
    addqw #4,%a0
    movew #1,%a0@+
    movel %d2,%a0@+
    lea %fp@(-50),%a0
    rts

VCHECKLOAD_11A:         /* read d0 bytes from offset d2 into d1 */
    jbsr VCHECKLOAD_138
    jbsr VCHECKLOAD_100
    _Read
    jbra VCHECKLOAD_12A

VCHECKLOAD_122:         /* write at offset 0 */
    moveq #0,%d2

VCHECKLOAD_124:         /* write d0 bytes from d1 at offset d2 (_Write) */
    jbsr VCHECKLOAD_138
    jbsr VCHECKLOAD_100
    _Write

VCHECKLOAD_12A:         /* ResErr = d0 */
    movew %d0,ResErr
VCHECKLOAD_12E:         /* map pointers back, return */
    addal %a4@,%a3
    addal %a4@,%a2
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts

VCHECKLOAD_138:         /* offsets relative to the map (it may move while the File Manager works) */
    moveml %d0-%d1/%a0,%sp@-
    moveal %sp@(12),%a0
    movel %a1,%sp@(12)
    subal %a4@,%a3
    subal %a4@,%a2
    jmp %a0@

VCHECKLOAD_14A:         /* write the header and the map (read-only maps excepted) */
    jbsr VCHECKLOAD_138
    jbsr VCHECKLOAD_1F4
    jbne VCHECKLOAD_12E
    jbsr VCHECKLOAD_100
    bsrs VCHECKLOAD_15E
    movel %d0,%a0@(28)
    _SetEOF
    jbra VCHECKLOAD_12A

VCHECKLOAD_15E:         /* d0 = the end of the data area or the map, whichever is later */
    moveml %d1/%a1,%sp@-
    moveal %a4@,%a1
    movel %a1@+,%d0
    movel %a1@+,%d1
    addl %a1@+,%d0
    addl %a1@+,%d1
    cmpl %d1,%d0
    jbpl VCHECKLOAD_172
    movel %d1,%d0
VCHECKLOAD_172:         /* return */
    moveml %sp@+,%d1/%a1
    rts

VCHECKLOAD_178:         /* d0/d1 = the handle's size (+ 4) */
    moveal %a2@(8),%a0
    _GetHandleSize
    addql #4,%d0
    movel %d0,%d1
    rts

VCHECKLOAD_184:         /* d0 = the room the resource has on disk (up to the next resource or the map) */
    moveml %d1/%d7-%a2,%sp@-
    movel %a2@(4),%d7
    andl Lo3Bytes,%d7
    moveal %a4@,%a0
    movel %a0@(4),%d0
    subl %a0@,%d0
    moveal %d0,%a1
    jbmi VCHECKLOAD_1AE
    cmpal %d7,%a1
    jbmi VCHECKLOAD_1AE
    jbsr SETRESFILEATTRS_3C
    jbmi VCHECKLOAD_1AA
    cmpal %d0,%a1
    jbpl VCHECKLOAD_1BE
VCHECKLOAD_1AA:         /* the map follows */
    movel %a1,%d0
    jbra VCHECKLOAD_1B8
VCHECKLOAD_1AE:         /* the last one */
    jbsr SETRESFILEATTRS_3C
    jbpl VCHECKLOAD_1BE
    jbsr VCHECKLOAD_15E
    subl %a0@,%d0
VCHECKLOAD_1B8:         /* room */
    subl %d7,%d0
    moveq #-1,%d7
    jbra VCHECKLOAD_1C0
VCHECKLOAD_1BE:         /* room */
    subl %d7,%d0
VCHECKLOAD_1C0:         /* return */
    moveml %sp@+,%d1/%d7-%a2
    rts

VCHECKLOAD_1C6:         /* a changed resource still fits where it is? write the map; else move it to the end */
    jbsr VCHECKLOAD_178
    jbsr VCHECKLOAD_184
    cmpl %d0,%d1
    jble VCHECKLOAD_14A

VCHECKLOAD_1D0:         /* put it after the data area: its new offset, the data length; the map changed and must be compacted */
    jbsr VCHECKLOAD_178
    jbsr VCHECKLOAD_15E
    moveal %a4@,%a0
    subl %a0@,%d0
    moveb %a2@(4),%sp@-
    movel %d0,%a2@(4)
    moveb %sp@+,%a2@(4)
    addl %d1,%d0
    movel %d0,%a0@(8)
    orib #96,%a0@(22)
    jbra VCHECKLOAD_14A

VCHECKLOAD_1F4:         /* read-only map (attribute bit 7)? */
    moveal %a4@,%a0
    btst #7,%a0@(22)
    rts

VCHECKLOAD_1FE:         /* is there room (memory, disk) for the resource to grow? (the file extended by its size) */
    jbsr VCHECKLOAD_138
    movel %d2,%sp@-
    moveq #70,%d1
    aslw #2,%d1
    moveal %a4,%a0
    _GetHandleSize
    movel %d0,%d2
    addl %d1,%d0
    _SetHandleSize
    exg %d0,%d2
    _SetHandleSize
    movew %d2,%d0
    jbmi VCHECKLOAD_23C
    jbsr VCHECKLOAD_1F4
    jbne VCHECKLOAD_23C
    movel %a1,%d0
    jbeq VCHECKLOAD_22C
    moveal %a1,%a0
    _GetHandleSize
    movel %d0,%d2
    jbmi VCHECKLOAD_23C
    addl %d0,%d1
VCHECKLOAD_22C:         /* extend the file */
    jbsr VCHECKLOAD_100
    lea %a0@(28),%a1
    _GetEOF
    movel %a1@,%d2
    addl %d1,%a1@
    _SetEOF
VCHECKLOAD_23C:         /* restore */
    movel %sp@+,%d2
    jbra VCHECKLOAD_12A

VCHECKLOAD_242:         /* check a map just read: the type list, references and names inside it; else mapReadErr */
    moveml %d0-%d1/%a0-%a1,%sp@-
    moveal %a4@,%a0
    jbsr VCHECKLOAD_15E
    cmpl Lo3Bytes,%d0
    jbge VCHECKLOAD_298
    btst #0,%a0@(25)
    jbne VCHECKLOAD_298
    moveal %a0,%a1
    addaw %a0@(24),%a1
    movew %a1@+,%d0
    jbmi VCHECKLOAD_278
    moveq #0,%d1
VCHECKLOAD_266:         /* count the references */
    addw %a1@(4),%d1
    addqw #1,%d1
    addqw #8,%a1
    dbf %d0,VCHECKLOAD_266
    muluw #12,%d1
    addal %d1,%a1
VCHECKLOAD_278:         /* the name list within the map */
    movew %a0@(26),%d1
    jbgt VCHECKLOAD_28E
    subal %a0,%a1
    movel %a1,%d1
    andl Lo3Bytes,%d1
    cmpl %a0@(12),%d1
    jbgt VCHECKLOAD_298
    jbra VCHECKLOAD_294
VCHECKLOAD_28E:         /* (offset) */
    addaw %d1,%a0
    cmpal %a1,%a0
    jbmi VCHECKLOAD_298
VCHECKLOAD_294:         /* good */
    moveq #0,%d0
    jbra VCHECKLOAD_29E
VCHECKLOAD_298:         /* mapReadErr */
    movew #-199,ResErr	/* mapReadErr */
VCHECKLOAD_29E:         /* return */
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts

/* LOADRESOURCE: _LoadResource. */
trap_LoadResource:
LOADRESOURCE:           /* (an empty resource handle: load it, even with ResLoad off) */
    moveml %d0/%a0,%sp@-
    pea %pc@(LOADRESOURCE_36)
    jbsr SKIPTOENTRY_22
    moveal %fp@(20),%a1
    tstl %a1@
    jbne LOADRESOURCE_32
    jbsr VRMGRSTDEXIT_36
    jbeq LOADRESOURCE_22
    movew #-192,ResErr	/* resNotFound */
    jbra LOADRESOURCE_32
LOADRESOURCE_22:        /* load */
    moveb ResLoad,%sp@-
    st ResLoad
    jbsr VRMGRSTDEXIT_12A
    moveb %sp@+,ResLoad
LOADRESOURCE_32:        /* done */
    jbra VRMGRSTDENTRY_B4
LOADRESOURCE_36:        /* return */
    moveml %sp@+,%d0/%a0
    movel %sp@+,%sp@
    rts

/* RELEASERESOURCE: _ReleaseResource. */
trap_ReleaseResource:
RELEASERESOURCE:        /* (dispose of a resource's data; the reference keeps the place; not for changed ones) */
    jbsr WRITERESOURCE_1E
    btst #1,%a2@(4)
    jbne RELEASERESOURCE_26
    moveal %a1,%a0
    _DisposHandle

RELEASERESOURCE_10:     /* a 'FONT': the font cache is no longer valid (LastSPExtra = -1) */
    cmpil #1179602516,%d3
    jbne RELEASERESOURCE_1E
    movel MinusOne,LastSPExtra
RELEASERESOURCE_1E:     /* no handle */
    clrl %a2@(8)
    clrl RMgrLastResHand
RELEASERESOURCE_26:     /* done */
    jbra VRMGRSTDENTRY_AC

/* DETACHRESOURCE: _DetachResource. */
trap_DetachResource:
DETACHRESOURCE:         /* (the handle is no longer a resource: resAttrErr if changed) */
    jbsr WRITERESOURCE_1E
    btst #1,%a2@(4)
    jbne DETACHRESOURCE_10
    moveal %a1,%a0
    _HClrRBit
    jbra RELEASERESOURCE_10
DETACHRESOURCE_10:      /* resAttrErr */
    movew #-198,ResErr	/* resAttrErr */
    jbra RELEASERESOURCE_26

/* CHANGEDRESOURCE: _ChangedResource. */
trap_ChangedResource:
CHANGEDRESOURCE:        /* (mark it changed; there must be room for it in the file; protected: resAttrErr) */
    jbsr WRITERESOURCE_1E
    moveal %a1,%a0
    _HGetState
    moveb %d0,%d7
    _HNoPurge
    btst #3,%a2@(4)
    jbne CHANGEDRESOURCE_2C
    jbsr VCHECKLOAD_1FE
    jbmi CHANGEDRESOURCE_32
    bset #1,%a2@(4)
    jbsr VCHECKLOAD_1C6
    moveal %a4@,%a0
    bset #5,%a0@(22)
    jbra CHANGEDRESOURCE_32
CHANGEDRESOURCE_2C:     /* resAttrErr */
    movew #-198,ResErr	/* resAttrErr */
CHANGEDRESOURCE_32:     /* the handle's state back */
    moveal %a1,%a0
    moveb %d7,%d0
    _HSetState
    jbra VRMGRSTDENTRY_AC

/* WRITERESOURCE: _WriteResource. */
trap_WriteResource:
WRITERESOURCE:          /* (write it now if changed) */
    jbsr WRITERESOURCE_1E
    jbsr VCHECKLOAD_1F4
    jbne WRITERESOURCE_14
    btst #1,%a2@(4)
    jbeq WRITERESOURCE_14
    jbsr VCHECKLOAD_DE
WRITERESOURCE_14:       /* done */
    jbra VRMGRSTDENTRY_AC

WRITERESOURCE_18:       /* (the caller's result -1) */
    movel MinusOne,%sp@(12)

WRITERESOURCE_1E:       /* the reference of the handle on the stack (resNotFound) */
    movel %sp@+,%d0
    jbsr SKIPTOENTRY_22
    movel %d0,%sp@-
    movel %a0,%d0
    jbeq WRITERESOURCE_32
    moveal %a0@,%a1
    jbsr SETRESATTRS_24
    jbeq WRITERESOURCE_38
WRITERESOURCE_32:       /* not a resource */
    addqw #4,%sp
    jbra VRMGRSTDENTRY_AC
WRITERESOURCE_38:       /* return */
    rts

/* HOMERESFILE: _HomeResFile. */
trap_HomeResFile:
HOMERESFILE:
    movew #-1,%sp@(8)
    jbsr WRITERESOURCE_1E
    cmpw SysMap,%d6
    jbne HOMERESFILE_10
    moveq #0,%d6
HOMERESFILE_10:         /* the System file: 0 */
    movew %d6,%fp@(12)
    jbra VRMGRSTDENTRY_AC
HOMERESFILE_18:         /* the purge warning procedure: a changed resource is written before its block is purged */
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _HGetState
    btst #5,%d0
    beqs HOMERESFILE_18_10
    movel %a0,%sp@-
    .short  0xA9B0	| 4081BCBA _WriteResource
HOMERESFILE_18_10:
    jmp %a1@

/* SETRESPURGE: _SetResPurge. */
trap_SetResPurge:
SETRESPURGE:            /* (on: the zone's purge procedure = HOMERESFILE_18; off: none) */
    moveal TheZone,%a0
    movel %sp@+,%d0
    tstb %sp@+
    pea %pc@(HOMERESFILE_18)
    jbne SETRESPURGE_10
    clrl %sp@
SETRESPURGE_10:         /* TheZone's purge procedure (+40) */
    movel %sp@+,%a0@(40)
    movel %d0,%sp@-
SETRESPURGE_16:         /* clear the per-call flags, return */
    clrb RMgrCurOnly
    clrw ROMMapInsert
    rts

/* SETRESLOAD: _SetResLoad. */
trap_SetResLoad:
SETRESLOAD:
    moveal %sp@+,%a0
    moveb %sp@+,ResLoad
    movel %a0,%sp@-
    jbra SETRESPURGE_16

/* CURRESFILE: _CurResFile. */
trap_CurResFile:
CURRESFILE:
    movew CurMap,%sp@(4)
    jbra SETRESPURGE_16

/* RESERROR: _ResError. */
trap_ResError:
RESERROR:
    movew ResErr,%sp@(4)
    jbra SETRESPURGE_16

/* ADDREFERENCE: _AddReference. */
trap_AddReference:
ADDREFERENCE:           /* (obsolete: addRefFailed) */
    moveal %sp@+,%a0
    lea %sp@(10),%sp
    movel %a0,%sp@-
    movew #-195,ResErr	/* addRefFailed */
    jbra SETRESPURGE_16

/* RMVEREFERENCE: _RmveReference. */
trap_RmveReference:
RMVEREFERENCE:          /* (obsolete: rmvRefFailed) */
    movel %sp@+,%sp@
    movew #-197,ResErr	/* rmvRefFailed */
    jbra SETRESPURGE_16

/* GETRESATTRS: _GetResAttrs. */
trap_GetResAttrs:
GETRESATTRS:
    jbsr SKIPTOENTRY_22
    moveal %a0@,%a1
    jbsr SETRESATTRS_24
    jbmi GETRESATTRS_10
    moveb %a2@(4),%fp@(13)
GETRESATTRS_10:         /* done */
    jbra VRMGRSTDENTRY_AC

/* SETRESATTRS: _SetResAttrs. */
trap_SetResAttrs:
SETRESATTRS:
    jbsr SKIPTOENTRY_22
    moveal %fp@(10),%a1
    jbsr SETRESATTRS_24
    jbmi SETRESATTRS_20
    cmpal ROMMapHandle,%a4	/* not in the ROM map */
    jbeq SETRESATTRS_20
    moveb %fp@(9),%a2@(4)
    moveal %a4@,%a0
    bset #5,%a0@(22)
SETRESATTRS_20:         /* done (not in the ROM map) */
    jbra VRMGRSTDENTRY_A8

SETRESATTRS_24:         /* the reference of handle a1 (resNotFound) */
    jbsr VRMGRSTDEXIT_36
    jbeq SETRESATTRS_30
    movew #-192,ResErr	/* resNotFound */
SETRESATTRS_30:         /* return */
    rts

/* GETRESINFO: _GetResInfo. */
trap_GetResInfo:
GETRESINFO:
    jbsr SKIPTOENTRY_22
    moveal %fp@(20),%a1
    jbsr SETRESATTRS_24
    jbeq GETRESINFO_12
    lea MinusOne,%a2
    moveq #0,%d3
GETRESINFO_12:          /* ID, type and name to the caller's variables (each may be nil) */
    lea %fp@(16),%a0
    moveal %a0@,%a1
    movel %a1,%d0
    jbeq GETRESINFO_1E
    movew %a2@,%a1@
GETRESINFO_1E:          /* type */
    moveal %a0@-,%a1
    movel %a1,%d0
    jbeq GETRESINFO_26
    movel %d3,%a1@
GETRESINFO_26:          /* name */
    moveal %a0@-,%a1
    movel %a1,%d0
    jbeq GETRESINFO_36
    clrb %a1@
    jbsr VRMGRSTDEXIT_BA
    jbmi GETRESINFO_36
    jbsr GETRESINFO_3C
GETRESINFO_36:          /* done */
    moveq #16,%d0
    jbra VRMGRSTDENTRY_B6

GETRESINFO_3C:          /* copy a Pascal string a0 to a1 */
    moveq #0,%d0
    moveb %a0@,%d0
    addqw #1,%d0
    _BlockMove
    rts

/* SETRESINFO: _SetResInfo. */
trap_SetResInfo:
SETRESINFO:
    jbsr SKIPTOENTRY_22
    moveal %fp@(14),%a1
    jbsr SETRESATTRS_24
    jbmi SETRESINFO_44
    btst #3,%a2@(4)
    jbne SETRESINFO_3E
    movel %fp@(8),%d0
    jbeq SETRESINFO_30
    subal %a1,%a1
    jbsr VCHECKLOAD_1FE
    jbmi SETRESINFO_44
    moveal %d0,%a0
    jbsr RMVENAME
    jbsr ADDNAME
    jbsr VCHECKLOAD_14A
SETRESINFO_30:          /* the map changed, the new ID */
    moveal %a4@,%a0
    bset #5,%a0@(22)
    movew %fp@(12),%a2@
    jbra SETRESINFO_44
SETRESINFO_3E:          /* protected: resAttrErr */
    movew #-198,ResErr	/* resAttrErr */
SETRESINFO_44:          /* done */
    moveq #10,%d0
    jbra VRMGRSTDENTRY_B6

/* ADDRESOURCE: _AddResource. */
trap_AddResource:
ADDRESOURCE:            /* (a handle not already a resource; room in the file) */
    jbsr SKIPTOENTRY_1E
    movew #-194,ResErr	/* addResFailed */
    moveal %fp@(18),%a1
    movel %a1,%d0
    jbeq ADDRESOURCE_4C
    jbsr VRMGRSTDEXIT_36
    jbeq ADDRESOURCE_4C
    jbsr GETNAMEDRESOURCE_6A
    jbsr VCHECKLOAD_1FE
    jbmi ADDRESOURCE_4C
    movel %fp@(14),%d3
    jbsr ADDRESOURCE_52
    movew %fp@(12),%a2@+
    movew #-1,%a2@+
    movel #33554432,%a2@+	/* attributes: changed (bit 1), offset 0 */
    moveal %fp@(18),%a0
    _HSetRBit
    movel %a0,%a2@
    subql #8,%a2
    moveal %fp@(8),%a0
    jbsr ADDNAME
    jbsr VCHECKLOAD_1D0
ADDRESOURCE_4C:         /* done */
    moveq #14,%d0
    jbra VRMGRSTDENTRY_B6

ADDRESOURCE_52:         /* a reference for type d3 in map a4 (a new type entry if needed): a2 = it */
    bset #5,%a3@(22)
    jbsr TYPESCAN
    jbeq ADDRESOURCE_9A
    moveq #20,%d0
    jbsr ADDNAME_38
    jbsr GETTYPES
    jbmi ADDRESOURCE_6E
    jbsr SKIPTOENTRY
ADDRESOURCE_6E:         /* a new type: insert its 8-byte entry, shift the reference offsets */
    moveal %a2,%a3
    moveal %a4@,%a2
    addaw %a2@(26),%a2
    subaw #20,%a2
    moveq #8,%d0
    moveal %a3,%a0
    moveal %a2,%a1
    jbsr RESIZEMAP_16
    moveal %a4@,%a0
    addaw %a0@(24),%a0
    addqw #1,%a0@
    movel %d3,%a3@+
    clrw %a3@+
    subal %a0,%a1
    movew %a1,%a3@
    addql #8,%a2
    movew %a0@+,%d5
    jbra ADDRESOURCE_CC
ADDRESOURCE_9A:         /* the type exists: insert a 12-byte reference at the end of its references */
    moveq #12,%d0
    jbsr ADDNAME_38
    moveal %a4@,%a1
    addaw %a1@(26),%a1
    subaw %d0,%a1
    jbsr TYPESCAN
    movel %a2,%sp@-
    addqw #1,%a2@(4)
    moveq #12,%d0
    muluw %a2@(4),%d0
    moveaw %a2@(6),%a2
    addal %a3,%a2
    addaw %d0,%a2
    moveal %a2,%a0
    moveq #12,%d0
    jbsr RESIZEMAP_16
    moveal %sp@+,%a0
    jbra ADDRESOURCE_D0

ADDRESOURCE_CC:         /* shift the following types' reference offsets */
    addw %d0,%a0@(6)
ADDRESOURCE_D0:         /* next type */
    addqw #8,%a0
    dbf %d5,ADDRESOURCE_CC
    rts

/* RMVERESOURCE: _RmveResource. */
trap_RmveResource:
RMVERESOURCE:           /* (from the current file only; not protected) */
    jbsr SKIPTOENTRY_22
    movew #-196,ResErr	/* rmvResFailed */
    moveal %a0@,%a1
    jbsr VRMGRSTDEXIT_36
    jbmi RMVERESOURCE_8A
    btst #3,%a2@(4)
    jbne RMVERESOURCE_8A
    cmpw CurMap,%d6
    jbne RMVERESOURCE_8A
    moveal %a1,%a0
    _HClrRBit
    moveq #96,%d0
    clrl RMgrLastResHand
    moveal %a4@,%a0
    orb %d0,%a0@(22)
    jbsr RMVENAME
    moveq #-12,%d7
    moveal %a2,%a0
    subaw %d7,%a0
    jbsr TYPESCAN
    moveal %a4@,%a1
    addaw %a1@(26),%a1
    movel %d7,%d0
    jbsr RESIZEMAP_16
    moveal %a2,%a0
    addqw #8,%a0
    subqw #1,%d5
    jbmi RMVERESOURCE_54
    jbsr ADDRESOURCE_CC
RMVERESOURCE_54:        /* the type's count; its last reference: remove the type entry */
    subqw #1,%a2@(4)
    jbpl RMVERESOURCE_78
    addqw #8,%a2
    moveal %a2,%a0
    addaw %d0,%a1
    moveq #-8,%d0
    addl %d0,%d7
    jbsr RESIZEMAP_16
    moveal %a4@,%a0
    addaw %a0@(24),%a0
    subqw #1,%a0@
    movew %a0@+,%d5
    jbmi RMVERESOURCE_78
    jbsr ADDRESOURCE_CC
RMVERESOURCE_78:        /* shrink the map; write it (not for the System file's ROM entries) */
    movel %d7,%d0
    jbsr ADDNAME_38
    cmpiw #1,%d6
    jbeq RMVERESOURCE_86
    jbsr VCHECKLOAD_14A
RMVERESOURCE_86:        /* no error */
    clrw ResErr
RMVERESOURCE_8A:        /* done */
    clrl RMgrLastResHand
    jbra VRMGRSTDENTRY_AC

/* ADDNAME: add a name to the map's name list. */
ADDNAME:                /* (name a0 for reference a2, appended to the name list; an empty name: -1) */
    clrl RMgrLastResHand
    moveml %d0-%d2/%a0-%a1,%sp@-
    moveq #-1,%d2
    tstb %a0@
    jbeq ADDNAME_2E
    moveal %a4@,%a1
    movel %a1@(12),%d1
    movel %d1,%d2
    moveq #0,%d0
    moveb %a0@,%d0
    addql #1,%d0
    jbsr RESIZEMAP
    moveq #0,%d0
    moveal %a4@,%a1
    movew %a1@(26),%d0
    subl %d0,%d2
    addal %d1,%a1
    jbsr GETRESINFO_3C
ADDNAME_2E:             /* the reference's name offset */
    movew %d2,%a2@(2)
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts

ADDNAME_38:             /* insert d0 bytes before the name list (negative: remove) */
    moveml %d0-%d1/%d7-%a1,%sp@-
    moveal %a4@,%a0
    movel %a0@(12),%d1
    tstl %d0
    jbmi ADDNAME_4A
    jbsr RESIZEMAP
    moveal %a4@,%a0
ADDNAME_4A:             /* move the name list */
    moveal %a0,%a1
    moveq #0,%d7
    movew %a0@(26),%d7
    addal %d7,%a0
    addw %d0,%a1@(26)
    addal %d1,%a1
    jbsr RESIZEMAP_16
    tstl %d0
    jbpl ADDNAME_62
    jbsr RESIZEMAP
ADDNAME_62:             /* return */
    moveml %sp@+,%d0-%d1/%d7-%a1
    rts

/* RESIZEMAP: resize the map. */
RESIZEMAP:              /* (the map's length += d0, the handle resized) */
    jbsr VCHECKLOAD_138
    moveal %a4@,%a0
    addl %a0@(12),%d0
    movel %d0,%a0@(12)
    moveal %a4,%a0
    _SetHandleSize
    jbra VCHECKLOAD_12E

RESIZEMAP_16:           /* move the bytes from a0 to the end of the map by d0 (insert or remove at a0) */
    moveml %d0/%a0-%a1,%sp@-
    exg %d0,%a1
    subl %a0,%d0
    andl Lo3Bytes,%d0
    addal %a0,%a1
    _BlockMove
    moveml %sp@+,%d0/%a0-%a1
    rts

/* RMVENAME: remove a name. */
RMVENAME:
    moveml %d0-%d2/%a0-%a1,%sp@-
    movew %a2@(2),%d2
    jbmi RMVENAME_4A
    moveal %a4@,%a0
    moveal %a0,%a1
    moveq #0,%d0
    movew %a0@(26),%d0
    addal %d0,%a0
    addaw %d2,%a0
RMVENAME_18:            /* remove the name, shift the name offsets after it */
    addal %a1@(12),%a1
    moveq #0,%d0
    moveb %a0@,%d0
    addql #1,%d0
    addal %d0,%a0
    negl %d0
    movel %d0,%d1
    jbsr RESIZEMAP_16
    jbsr RESIZEMAP
    moveml %d3-%d5/%a2-%a3,%sp@-
    jbsr GETTYPES_C
RMVENAME_34:            /* each reference: a later name? */
    cmpw %a2@(2),%d2
    jbge RMVENAME_3E
    addw %d1,%a2@(2)
RMVENAME_3E:            /* next */
    lea %a2@(12),%a2
    dbf %d4,RMVENAME_34
    moveml %sp@+,%d3-%d5/%a2-%a3
RMVENAME_4A:            /* the reference has no name */
    moveml %sp@+,%d0-%d2/%a0-%a1
    movew MinusOne,%a2@(2)
    rts

/* SIZERESOURCE: _SizeRsrc. */
trap_SizeRsrc:
SIZERESOURCE:           /* (loaded: the handle's size; else from the file) */
    jbsr WRITERESOURCE_18
    tstl %a1@
    jbeq SIZERESOURCE_E
    moveal %a1,%a0
    _GetHandleSize
    jbra SIZERESOURCE_1A
SIZERESOURCE_E:         /* from the file */
    moveb %a2@(4),%sp@-
    jbsr VCHECKLOAD_9C
    moveb %sp@+,%a2@(4)
SIZERESOURCE_1A:        /* the result */
    movel %d0,%fp@(12)
    jbra VRMGRSTDENTRY_AC

/* MAXSIZERSRC: _MaxSizeRsrc. */
trap_MaxSizeRsrc:
MAXSIZERSRC:            /* (the room it has on disk) */
    jbsr WRITERESOURCE_18
    tstl %a1@
    jbne MAXSIZERSRC_E
    jbsr VCHECKLOAD_184
    jbra MAXSIZERSRC_12
MAXSIZERSRC_E:          /* loaded */
    moveal %a1,%a0
    _GetHandleSize
MAXSIZERSRC_12:         /* the result */
    jbra SIZERESOURCE_1A

/* RSRCMAPENTRY: _RsrcMapEntry. */
trap_RsrcMapEntry:
RSRCMAPENTRY:           /* (the reference's offset in the map) */
    jbsr WRITERESOURCE_18
    movel %a2,%d0
    subl %a4@,%d0
    _StripAddress
    jbra SIZERESOURCE_1A

/* RGETRESOURCE: _RGetResource: GetResource including the ROM map. */
trap_RGetResource:
RGETRESOURCE:           /* (GetResource; if not found, again with the ROM map in the chain) */
    clrb ROMMapInsert
    jbsr RGETRESOURCE_14
    jbne RGETRESOURCE_E
    st ROMMapInsert
    jbsr RGETRESOURCE_14
RGETRESOURCE_E:         /* pop the parameters */
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@

RGETRESOURCE_14:        /* GetResource with ResLoad as asked (TmpResLoad) */
    moveb ResLoad,TmpResLoad
    subqw #4,%sp
    movel %sp@(14),%sp@-
    movew %sp@(16),%sp@-
    _GetResource
    movel %sp@+,%sp@(14)
    rts
