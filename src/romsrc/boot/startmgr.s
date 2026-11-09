/*
 boot/startmgr.s - start-up device search, default start-up/video/OS, boot icons, timeouts
 From FINDSTARTUPDEVICE (0x40801350). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 Registers kept through the start-up device search: d3 = default startup (OS type in the
 high word), d4 = default startup drive refnum (or slot/sResource), a2 = current drive
 queue element, a3 = the test a candidate must pass, a4 = time of the next icon update,
 d6 = icon state (bit 8 started, bit 9 which icon, bit 10 failure to flash, low byte
 remaining X flashes). fp-1024 = the parameter block used for the boot device.
*/

/*
 FINDSTARTUPDEVICE: find the device to start up from. Loads the drivers (slot device
 first, then SCSI), waits for the internal hard disk, then loops over the drive queue:
 the first pass accepts only the default device or a floppy, later passes anything.
 Each candidate is selected, its boot blocks read, and the first that works is used
 (happy Mac), a failed one is ejected or excluded, while the disk icons blink.
*/
FINDSTARTUPDEVICE:
    jbsr EMBARKONSEARCH
    jbsr LOADSLOTDRVRS
    jbsr LOADDRIVERS
    jbsr WAITFORINTERNAL
    jbra FINDSTARTUPDEVICE_1E
FINDSTARTUPDEVICE_12:   /* no candidate left: widen the search, load drivers again */
    jbsr PLANSTRATEGY
    jbsr LOADDRIVERS
FINDSTARTUPDEVICE_1A:   /* update the disk icon */
    jbsr VISUALUPDATE
FINDSTARTUPDEVICE_1E:   /* next candidate: select it, mouse down ejects it */
    jbsr FINDNEXTCANDIDATE
    jbeq FINDSTARTUPDEVICE_12
    jbsr SELECTDEVICE
    jbsr CHECKMOUSEEJECT
    jbeq FINDSTARTUPDEVICE_1A
    jbsr GETSTARTUPINFO
    jbeq FINDSTARTUPDEVICE_3A
    jbsr REACTTOFAILURE
    jbra FINDSTARTUPDEVICE_1A
FINDSTARTUPDEVICE_3A:   /* found: happy Mac */
    jbra SHOWSUCCESS
    .short  0x0000	| 4080138E

/* _GetDefaultStartup: read the 4-byte default startup device (XPRAM 0x78) to (a0). */
trap_GetDefaultStartup:
GETDEFAULTSTARTUP:
    movel #262264,%d0
    _ReadXPRam
    rts
    .short  0x0000, 0x0000, 0x0000	| 4080139A

/* _SetDefaultStartup: write it. */
trap_SetDefaultStartup:
SETDEFAULTSTARTUP:
    movel #262264,%d0
    _WriteXPRam
    rts
    .short  0x0000, 0x0000, 0x0000	| 408013AA

/* _GetOSDefault: read the 2-byte default OS (XPRAM 0x76) to (a0). */
trap_GetOSDefault:
GETOSDEFAULT:
    movel #131190,%d0
    _ReadXPRam
    rts
    .short  0x0000, 0x0000, 0x0000	| 408013BA

/*
 _SetOSDefault: write it, only if the caller set the key 0x09961010 at 0xCDC first
 (the key is cleared either way). Out: d0 = -1 without the key.
*/
trap_SetOSDefault:
SETOSDEFAULT:
    cmpil #160829456,0xcdc
    jbne SETOSDEFAULT_18
    clrl 0xcdc
    movel #131190,%d0
    _WriteXPRam
    rts
SETOSDEFAULT_18:        /* no key: refused */
    clrl 0xcdc
    moveq #-1,%d0
    rts

/* _GetVideoDefault: read the 2-byte default video device (slot, sResource: XPRAM 0x80). */
trap_GetVideoDefault:
GETVIDEODEFAULT:
    movel #131200,%d0
    _ReadXPRam
    rts
    .short  0x0000, 0x0000, 0x0000	| 408013EA

/* _SetVideoDefault: write it. */
trap_SetVideoDefault:
SETVIDEODEFAULT:
    movel #131200,%d0
    _WriteXPRam
    rts
    .short  0x0000, 0x0000, 0x0000	| 408013FA

/*
 _InternalWait: hard disk start-up wait settings, selector in a0 (0..7): Get/SetTimeout,
 Get/SetWaitFlags, Disable/EnableDynWait, Disable/EnablePermWait. Jumps through the
 table of offsets below.
*/
trap_InternalWait:
INTERNALWAIT:
    movel %a0,%d1
    cmpiw #9,%d1
    jbhi INTERNALWAIT_16
    addw %d1,%d1
    lea %pc@(INTERNALWAIT_18),%a1
    movew %a1@(0x0,%d1:w),%d1
    jsr %a1@(0x0,%d1:w)
INTERNALWAIT_16:        /* selector out of range */
    rts
INTERNALWAIT_18:        /* offsets of IGETTIMEOUT ... IENABLEPERMWAIT */
    .short  IGETTIMEOUT-INTERNALWAIT_18	| 40801418
    .short  ISETTIMEOUT-INTERNALWAIT_18	| 4080141A
    .short  IGETWAITFLAGS-INTERNALWAIT_18	| 4080141C
    .short  ISETWAITFLAGS-INTERNALWAIT_18	| 4080141E
INTERNALWAIT_20:        /* (rest of the table) */
    .short  IDISABLEDYNWAIT-INTERNALWAIT_18	| 40801420
    .short  IENABLEDYNWAIT-INTERNALWAIT_18	| 40801422
    .short  IDISABLEPERMWAIT-INTERNALWAIT_18	| 40801424
    .short  IENABLEPERMWAIT-INTERNALWAIT_18	| 40801426
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40801428

/*
 EMBARKONSEARCH: set up the search: d3/d4 from the default startup and default OS, no
 drive yet, a3 = ISITFLOPORDEF (or ISITANYTHING if there is no default), a4 = now.
*/
EMBARKONSEARCH:
    subqw #4,%sp
    moveal %sp,%a0
    _GetDefaultStartup
    movew %sp@+,%d3
    movew %sp@+,%d4
    subqw #2,%sp
    moveal %sp,%a0
    _GetOSDefault
    swap %d3
    movew %sp@+,%d3
    swap %d3
    subal %a2,%a2
    lea %pc@(ISITFLOPORDEF),%a3
    tstw %d4
    jbne EMBARKONSEARCH_24
    lea %pc@(ISITANYTHING),%a3
EMBARKONSEARCH_24:      /* icon timer, icon state */
    moveal Ticks,%a4
    clrw %d6
    rts
    .long   0x00000000	| 4080145C

/*
 WAITFORINTERNAL: wait for the internal SCSI hard disk (ID in SCSIPoll) to come up,
 unless the wait is disabled or Command-Option-Shift-Delete is held (skip the internal
 disk). Retries every 15 ticks for the timeout (default 20 seconds), loading its driver
 with SCSIBOOTS and looking for its drive queue entry (refnum -33 - ID).
*/
WAITFORINTERNAL:
    moveml %d5/%a2,%sp@-
    moveaw #2,%a0
    _InternalWait
    andib #0x80,%d0
    jbne WAITFORINTERNAL_7E
    subal %a0,%a0
    _InternalWait
    jbne WAITFORINTERNAL_18
    moveq #20,%d0
WAITFORINTERNAL_18:     /* timeout in seconds (0: 20) to ticks */
    muluw #60,%d0
    movel %d0,%d5
    moveaw #6,%a0
    _InternalWait
WAITFORINTERNAL_24:     /* try again: Command-Option-Shift-Delete held? load the driver */
    movew KeyMap_6,%d0
    cmpiw #-30715,%d0
    jbeq WAITFORINTERNAL_7E
    moveq #7,%d1
    andb SCSIPoll,%d1
    moveq #0,%d0
    bset %d1,%d0
    movel %a0,%sp@-
    bigjsr SCSIBOOTS
    moveal %sp@+,%a0
    jbeq WAITFORINTERNAL_78
    subal %a2,%a2
    moveq #-33,%d0
    subw %d1,%d0
    movew %d0,%d1
WAITFORINTERNAL_50:     /* look for the disk's drive queue entry */
    jbsr NEXTDQENTRY
    jbeq WAITFORINTERNAL_5E
    cmpw %a2@(8),%d1
    jbne WAITFORINTERNAL_50
    jbra WAITFORINTERNAL_78
WAITFORINTERNAL_5E:     /* not there yet: timed out? */
    cmpl Ticks,%d5
    jbcs WAITFORINTERNAL_72
    moveq #15,%d0
    addl Ticks,%d0
WAITFORINTERNAL_6A:     /* wait 15 ticks */
    cmpl Ticks,%d0
    jbcc WAITFORINTERNAL_6A
    jbra WAITFORINTERNAL_24
WAITFORINTERNAL_72:     /* timed out: no more dynamic wait */
    moveaw #4,%a0
    _InternalWait
WAITFORINTERNAL_78:     /* done: EnablePermWait */
    moveaw #7,%a0
    _InternalWait
WAITFORINTERNAL_7E:     /* restore and return */
    moveml %sp@+,%d5/%a2
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408014E4

/*
 LOADSLOTDRVRS: if the default startup device is a slot device (d4 > 0: slot and
 sResource), execute its sRsrcBootRec (sExec) with the default OS, which loads the
 driver. Out: d4 = the driver's refnum from the SEBlock, or 0.
*/
LOADSLOTDRVRS:
    tstw %d4
    jble LOADSLOTDRVRS_68
    subaw #56,%sp
    moveal %sp,%a0
    subaw #24,%sp
    moveal %sp,%a1
    movel %a1,%a0@(20)
    moveb %d4,%a0@(50)
    lsrw #8,%d4
    moveb %d4,%a0@(49)
    moveq #48,%d0	/* _SlotManager 48: FINDSRSRCPTR, sFindsRsrcPtr */
    _SlotManager
    jbne LOADSLOTDRVRS_62
    moveb %a0@(49),%a1@
    moveb %a0@(50),%a1@(1)
    movel %d3,%d0
    moveb %d0,%a1@(17)
    lsrl #8,%d0
    moveb %d0,%a1@(16)
    lsrl #8,%d0
    moveb %d0,%a1@(18)
    lsrl #8,%d0
    moveb %d0,%a1@(19)
    clrb %a1@(22)
    moveb #6,%a0@(50)
    moveq #35,%d0	/* _SlotManager 35: SLOTEXEC, sExec */
    _SlotManager
    jbne LOADSLOTDRVRS_62
    tstw %a1@(2)
    jbne LOADSLOTDRVRS_62
    movew %a1@(20),%d4
    jbra LOADSLOTDRVRS_64
LOADSLOTDRVRS_62:       /* failed: no default device */
    clrw %d4
LOADSLOTDRVRS_64:       /* free the parameter blocks */
    lea %sp@(80),%sp
LOADSLOTDRVRS_68:       /* done */
    rts
    .short  0x0000, 0x0000, 0x0000	| 4080155A

/*
 LOADDRIVERS: load the drivers of all SCSI devices (SCSIBOOTS with all IDs), except the
 internal disk when Command-Option-Shift-Delete is held.
*/
LOADDRIVERS:
    moveq #-1,%d0
    cmpiw #-30715,KeyMap_6
    jbne LOADDRIVERS_12
    moveq #7,%d1
    andb SCSIPoll,%d1
    bclr %d1,%d0
LOADDRIVERS_12:         /* SCSIBOOTS with the ID mask in d0 */
    movel %a0,%sp@-
    bigjsr SCSIBOOTS
    moveal %sp@+,%a0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40801582

/* PLANSTRATEGY: after the first pass, accept any device (unless the default is a floppy). */
PLANSTRATEGY:
    cmpiw #-5,%d4
    jbeq PLANSTRATEGY_A
    lea %pc@(ISITANYTHING),%a3
PLANSTRATEGY_A:         /* done */
    rts
    .long   0x00000000	| 4080159C

/*
 FINDNEXTCANDIDATE: next drive queue entry that is not excluded and passes the test in
 a3. Out: a2 = it, Z set when there are no more.
*/
FINDNEXTCANDIDATE:
    bsrw NEXTDQENTRY
    jbeq FINDNEXTCANDIDATE_10
    jbsr ISREJECT
    jbeq FINDNEXTCANDIDATE
    jsr %a3@
    jbne FINDNEXTCANDIDATE
FINDNEXTCANDIDATE_10:   /* Z = no more */
    movel %a2,%d0
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408015B4

/* NEXTDQENTRY: next drive queue element after a2 (the first if a2 = 0). Z set at the end. */
NEXTDQENTRY:
    movel %a2,%d0
    jbne NEXTDQENTRY_A
    moveal DrvQHdr_Head,%a2
    jbra NEXTDQENTRY_C
NEXTDQENTRY_A:          /* a2 = the next one */
    moveal %a2@,%a2
NEXTDQENTRY_C:          /* Z = end of the queue */
    movel %a2,%d0
    rts

/*
 SELECTDEVICE: make a2 the boot device: refnum and drive number into the parameter block
 at fp-1024, BtDskRfn and BootDrive.
*/
SELECTDEVICE:
    lea %fp@(-1024),%a0
    movew %a2@(8),%d0
    movew %d0,%a0@(24)
    movew %d0,BtDskRfn
    movew %a2@(6),%d0
    movew %d0,%a0@(22)
    movew %d0,BootDrive
    rts
    .short  0x0000	| 408015EE

/* CHECKMOUSEEJECT: mouse button down: eject the candidate (Z set, try the next one). */
CHECKMOUSEEJECT:
    tstb MBState
    jbmi CHECKMOUSEEJECT_A
    jbsr EJECTME
CHECKMOUSEEJECT_A:      /* done */
    rts
    .long   0x00000000	| 408015FC

/*
 GETSTARTUPINFO: read the 1024 bytes of boot blocks from the start of the device into the
 buffer at fp (BOOTBLOCKFLUSHPATCH does the _Read and checks them).
 Out: d0 = error, Z set if they are good.
*/
GETSTARTUPINFO:
    movew #1,%a0@(44)
    clrl %a0@(46)
    movel %fp,%a0@(32)
    movel #1024,%a0@(36)
    bral BOOTBLOCKFLUSHPATCH
    .short  0x0200	| 4080161C
BOOTBLOCKFLUSHRETURN:   /* the patch returns here */
    rts

/*
 REACTTOFAILURE: the candidate failed with error d0. No disk (-65): nothing. Not a
 startup disk (-64): exclude it. Otherwise eject it (or exclude it if it cannot be
 ejected) and flash the X icon for a floppy.
*/
REACTTOFAILURE:
    cmpiw #-65,%d0
    jbeq REACTTOFAILURE_1A
    cmpiw #-64,%d0
    jbeq REACTTOFAILURE_12
    jbsr EJECTME
    jbeq REACTTOFAILURE_16
REACTTOFAILURE_12:      /* exclude the drive from the search */
    jbsr NEVERAGAIN
REACTTOFAILURE_16:      /* show the failure */
    bsrw SHOWDEVICEFAIL
REACTTOFAILURE_1A:      /* done */
    rts
    .long   0x00000000	| 4080163C

/*
 VISUALUPDATE: once a second, alternate the disk icon with the "?" disk (or with the X
 disk, 3 times, after a failure).
*/
VISUALUPDATE:
    bset #8,%d6
    jbeq VISUALUPDATE_3A
    cmpal Ticks,%a4
    jbhi VISUALUPDATE_3A
    moveal Ticks,%a4
    lea %a4@(60),%a4
    bclr #10,%d6
    jbeq VISUALUPDATE_1E
    moveb #3,%d6
VISUALUPDATE_1E:        /* failure pending: 3 X flashes */
    bchg #9,%d6
    jbne VISUALUPDATE_2A
    jbsr SHOWPLAINDISK
    jbra VISUALUPDATE_3A
VISUALUPDATE_2A:        /* second icon: X while flashes remain, else ? */
    tstb %d6
    jbeq VISUALUPDATE_36
    jbsr SHOWDISKX
    subqb #1,%d6
    jbra VISUALUPDATE_3A
VISUALUPDATE_36:        /* "?" disk */
    jbsr SHOWDISKQ
VISUALUPDATE_3A:        /* done */
    rts

/* ENABLEXFLASH: flash the X disk icon at the next updates. */
ENABLEXFLASH:
    bset #10,%d6
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40801682

/* SHOWDEVICEFAIL: for a floppy, flash the X disk icon. */
SHOWDEVICEFAIL:
    bsrw ISITFLOPPY
    jbne SHOWDEVICEFAIL_8
    jbsr ENABLEXFLASH
SHOWDEVICEFAIL_8:       /* done */
    rts
    .short  0x0000, 0x0000, 0x0000	| 4080169A

/* SHOWSUCCESS: hide the cursor and draw the happy Mac. */
SHOWSUCCESS:
    _HideCursor
    moveml %a5-%fp,%sp@-
    lea %pc@(SHOWSUCCESS_E),%fp
    jmp %pc@(HAPPYMAC)
SHOWSUCCESS_E:          /* HAPPYMAC returns here (through fp) */
    moveml %sp@+,%a5-%fp
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408016B4

/* EJECTME: Control(csCode 7 = eject) to the boot device. Out: Z = ejected. */
EJECTME:
    lea %fp@(-1024),%a0
    movew #7,%a0@(26)
    _Control
    rts
    .short  0x0000	| 408016CE

/* ISREJECT: Z set if drive a2 is excluded (its bit cleared in BootMask, drives 0..15). */
ISREJECT:
    bsrw INBOOTMASK
    jbne ISREJECT_10
    movew %a2@(6),%d1
    movew BootMask,%d0
    btst %d1,%d0
ISREJECT_10:            /* result in Z */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408016E2

/* ISITFLOPORDEF: test for the first pass: Z if a2 is the default device or a floppy. */
ISITFLOPORDEF:
    cmpw %a2@(8),%d4
    jbne ISITFLOPPY
    rts
    .long   0x00000000, 0x00000000	| 408016F8

/* ISITFLOPPY: Z if a2 is a floppy (.Sony driver, refnum -5). */
ISITFLOPPY:
    cmpiw #-5,%a2@(8)
    rts
    .long   0x00000000, 0x00000000	| 40801708

/* ISITANYTHING: test that accepts any device (Z always set). */
ISITANYTHING:
    cmpw %d0,%d0
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40801714

/* NEVERAGAIN: exclude drive a2 from the search (clear its bit in BootMask). */
NEVERAGAIN:
    bsrw INBOOTMASK
    jbne NEVERAGAIN_14
    movew %a2@(6),%d1
    movew BootMask,%d0
    bclr %d1,%d0
    movew %d0,BootMask
NEVERAGAIN_14:          /* done */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40801736

/* INBOOTMASK: Z set (d0 = 0) if the drive number of a2 fits in BootMask (0..15). */
INBOOTMASK:
    cmpiw #15,%a2@(6)
    jbhi INBOOTMASK_A
    moveq #0,%d0
INBOOTMASK_A:           /* result in Z */
    rts
    .long   0x00000000	| 4080174C

/* HAPPYMAC: replace the disk icon with the happy Mac, return through fp. */
HAPPYMAC:
    jbsr ERASEMYICON
    lea %pc@(BOOTICON_HAPPY),%a0
    jbsr PLOTMYICON
    jmp %fp@

/* SHOWPLAINDISK, SHOWDISKQ, SHOWDISKX: draw the plain, "?" or X disk icon. */
SHOWPLAINDISK:
    lea %pc@(BOOTICON_DISK),%a0
    jbra PLOTMYICON

SHOWDISKQ:              /* address %pc@(BOOTICON_DISKQ) */
    lea %pc@(BOOTICON_DISKQ),%a0
    jbra PLOTMYICON

SHOWDISKX:              /* address %pc@(BOOTICON_DISKX) */
    lea %pc@(BOOTICON_DISKX),%a0

/* PLOTMYICON: draw the icon at a0 (data, then mask at +128) in the centre of the screen. */
PLOTMYICON:
    movel %a0,%sp@-
    jbsr PSHICNRECT
    movel %sp,%sp@-
    movel %sp@(12),%sp@-
    jbsr PLOTICNN
    lea %sp@(12),%sp
    rts

/* PSHICNRECT: push a 32 x 32 rectangle centred in screenBits.bounds (CENTERRECT). */
PSHICNRECT:
    moveal %sp@+,%a1
    movel #2097184,%sp@-
    clrl %sp@-
    moveal %a5@,%a0
    pea %a0@(-116)
    pea %sp@(4)
    movel %a1,%sp@-
    jbra CENTERRECT

/* PLOTICNN: CopyMask the 32 x 32 icon and its mask to the screen at the rectangle. */
PLOTICNN:
    moveml %sp@+,%d0-%d2
    movel %d0,%sp@-
    moveal %sp,%a0
    movel #2097184,%sp@-
    clrl %sp@-
    movew #4,%sp@-
    movel %d1,%sp@-
    movel %a0@-,%sp@-
    movel %a0@-,%sp@-
    movew %a0@-,%sp@-
    moveal %a0@-,%a1
    pea %a1@(128)
    movel %a0,%sp@-
    pea %sp@(4)
    moveal %a5@,%a1
    moveal %a1@,%a1
    pea %a1@(2)
    pea %a0@(6)
    pea %sp@(22)
    movel %d2,%sp@-
    _CopyMask
    lea %sp@(28),%sp
    rts

/* ERASEMYICON: fill the icon rectangle with the grey desktop pattern. */
ERASEMYICON:
    moveml %d0-%d2/%a0-%a1,%sp@-
    jbsr PSHICNRECT
    movel %sp,%sp@-
    moveal %a5@,%a0
    pea %a0@(-24)
    _FillRect
    addqw #8,%sp
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts
    .include "boot/booticons.s"
    .fill   14, 1, 0

/* IGETTIMEOUT: InternalWait 0: the hard disk wait timeout (XPRAM 0x01, low 5 bits). */
IGETTIMEOUT:
    jsr %pc@(GETRAWTIMEOUT)
    andib #31,%d0
    rts
    .short  0x0000, 0x0000, 0x0000	| 40801C0A

/*
 ISETTIMEOUT: InternalWait 1: set the timeout to d0 (at most 31), keeping
 the flags: move.b d0,-(sp), jsr GETRAWTIMEOUT, move.b (sp)+,d1, at most 31,
 andi.b #0xE0,d0, or.b d1,d0, jmp SETRAWTIMEOUT.
*/
ISETTIMEOUT:
    moveb %d0,%sp@-	| 40801C10
    jsr %pc@(GETRAWTIMEOUT)	| 40801C12
    moveb %sp@+,%d1	| 40801C16
    cmpib #31,%d1	| 40801C18
    jbls ISETTIMEOUT_10	| 40801C1C
    moveq #31,%d1	| 40801C1E
ISETTIMEOUT_10:         /* (40801C20 andib #-32,%d0) */
    andib #0xe0,%d0	| 40801C20
    orb %d1,%d0	| 40801C24
    jmp %pc@(SETRAWTIMEOUT)	| 40801C26
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40801C2A

/*
 IGETWAITFLAGS: InternalWait 2: the wait flags (high 3 bits of XPRAM 0x01): bit 7 =
 dynamic wait disabled, bit 6 = permanent wait disabled.
*/
IGETWAITFLAGS:
    jsr %pc@(GETRAWTIMEOUT)
    andib #0xe0,%d0
    rts
    .short  0x0000, 0x0000, 0x0000	| 40801C3A

/* ISETWAITFLAGS: InternalWait 3: set the flags from d0, keeping the timeout. */
ISETWAITFLAGS:
    moveb %d0,%sp@-
    jsr %pc@(GETRAWTIMEOUT)
    moveb %sp@+,%d1
    andib #0xe0,%d1
    andib #31,%d0
    orb %d1,%d0
    jmp %pc@(SETRAWTIMEOUT)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40801C56

/*
 IDISABLEDYNWAIT, IENABLEDYNWAIT, IDISABLEPERMWAIT, IENABLEPERMWAIT: InternalWait 4..7:
 set or clear flag bit 7 (dynamic wait) or 6 (permanent wait).
*/
IDISABLEDYNWAIT:
    moveaw #2,%a0
    _InternalWait
    bset #7,%d0
    moveaw #3,%a0
    _InternalWait
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40801C72

IENABLEDYNWAIT:         /* set up and call _InternalWait */
    moveaw #2,%a0
    _InternalWait
    bclr #7,%d0
    moveaw #3,%a0
    _InternalWait
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40801C92

IDISABLEPERMWAIT:       /* set up and call _InternalWait */
    moveaw #2,%a0
    _InternalWait
    bset #6,%d0
    moveaw #3,%a0
    _InternalWait
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40801CB2

IENABLEPERMWAIT:        /* set up and call _InternalWait */
    moveaw #2,%a0
    _InternalWait
    bclr #6,%d0
    moveaw #3,%a0
    _InternalWait
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40801CD2

/* GETRAWTIMEOUT: read the byte at XPRAM 0x01 (timeout and wait flags). Out: d0. */
GETRAWTIMEOUT:
    clrb %sp@-
    moveal %sp,%a0
    movel #65537,%d0
    _ReadXPRam
    moveq #0,%d0
    moveb %sp@+,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40801CF2

/* SETRAWTIMEOUT: write d0 to XPRAM 0x01. */
SETRAWTIMEOUT:
    moveb %d0,%sp@-
    moveal %sp,%a0
    movel #65537,%d0
    _WriteXPRam
    moveb %sp@+,%d0
    rts
