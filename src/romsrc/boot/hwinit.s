/*
 boot/hwinit.s - hardware set-up called from STARTINIT:
    timing, hardware bases, SCSI/IWM/SCC, RAM, video defaults, manager initialization
 From SETUPTIMEK (0x40800800). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

-- Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 VIA registers are 0x200 apart:
    +0x1000/+0x1200 timer 2 low/high,
    +0x1600 ACR,
    +0x1C00 IER.
  Slot Manager selectors used:
    2 sReadLong,
    5 sGetBlock,
    6 sFindStruct,
    7 sReadStruct,
    17/18 sReadPRAMRec/sPutPRAMRec,
    21 sNextTypesRsrc,
    22 sRsrcInfo,
    23 sDisposePtr,
    25 sReadDrvrName,
    27 sFindDevBase,
    38 sReadPBSize.

 SETUPTIMEK: calibrate the timing loops. For each entry of the table at SETUPTIMEK_6E,
 the timing routine is run once to warm up, then with VIA 1 timer 2 set to 0x030C counts
 (about 1 ms) and its interrupt enabled: the routine counts a dbra loop down from -1 until
 the interrupt (SETUPTIMEK_66) stops it. The number of iterations is stored in the low
 memory word given in the table: TimeDBRA (0xD00), TimeSCCDB (0xD02), TimeSCSIDB (0xB24),
 TimeVIADB (0xCEA): loop iterations per millisecond, used for delays everywhere.

*/
via_timer_calibrate:
SETUPTIMEK:
    movel Lev1AutoVector,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal VIA,%a1
    bclr #5,%a1@(5632)
    moveb #0xff,%a1@(4608)
    moveb #0xa0,%a1@(7168)
SETUPTIMEK_20:          /* timer value 0x030C, our level 1 interrupt handler */
    moveq #12,%d1
    moveq #3,%d2
    moveal %sp,%a3
    lea %pc@(SETUPTIMEK_66),%a0
    movel %a0,Lev1AutoVector
    lea %pc@(SETUPTIMEK_6E),%a4
SETUPTIMEK_32:          /* warm-up run of the next timing routine (2 iterations) */
    moveal %a4,%a0
    addaw %a4@,%a0
    moveq #2,%d0
    lea %pc@(SETUPTIMEK_3E),%a2
    jmp %a0@
SETUPTIMEK_3E:          /* measured run: interrupts on, count from -1 */
    moveal %a4,%a0
    addaw %a4@+,%a0
    moveq #-1,%d0
    lea %pc@(SETUPTIMEK_4E),%a2
    andiw #-1793,%sr
    jmp %a0@
SETUPTIMEK_4E:          /* iterations = NOT count: store them, next entry until offset 0 */
    notw %d0
    moveaw %a4@+,%a0
    movew %d0,%a0@
    tstw %a4@
    jbne SETUPTIMEK_32
    moveb #32,%a1@(7168)
    movew %sp@+,%sr
    movel %sp@+,Lev1AutoVector
    rts
SETUPTIMEK_66:          /* timer interrupt: clear it, drop the exception frame, continue at a2 */
    tstb %a1@(4096)
    moveal %a3,%sp
    jmp %a2@
SETUPTIMEK_6E:          /* table: routine offset (from the entry), low memory word to set */
    .short  SETUPTIMEK_80-., 0x0D00	| 4080086E
    .short  SETUPTIMEK_8E-., 0x0D02	| 40800872
    .short  SETUPTIMEK_A4-., 0x0B24	| 40800876
    .short  SETUPTIMEK_BC-., 0x0CEA	| 4080087A
    .byte   0x00, 0x00	| 4080087E
SETUPTIMEK_80:          /* set %a1@(4096) */
    moveb %d1,%a1@(4096)
    moveb %d2,%a1@(4608)
SETUPTIMEK_88:          /* TimeDBRA routine: plain dbra loop */
    dbf %d0,SETUPTIMEK_88
    jmp %a2@
SETUPTIMEK_8E:          /* TimeSCCDB routine: dbra loop reading the SCC */
    moveal SCCRd,%a0
    moveb %d1,%a1@(4096)
    moveb %d2,%a1@(4608)
SETUPTIMEK_9A:          /* loop */
    btst #0,%a0@
    dbf %d0,SETUPTIMEK_9A
    jmp %a2@
SETUPTIMEK_A4:          /* continue at SETUPSCSITIME */
    bral SETUPSCSITIME
    .short  0x0000	| 408008AA
SETUPTIMEK_AC:          /* unused (zeros) */
    .long   0x00000000	| 408008AC
    .long   0x00000000, 0x00000000, 0x00000000	| 408008B0
SETUPTIMEK_BC:          /* address %a1@(7168) */
    lea %a1@(7168),%a0
SETUPTIMEK_C0:          /* TimeVIADB routine (entered just above): dbra loop reading the VIA */
    moveb %d1,%a1@(4096)
    moveb %d2,%a1@(4608)
    nop
SETUPTIMEK_CA:          /* loop */
    btst #0,%a0@
    dbf %d0,SETUPTIMEK_CA
    jmp %a2@
    .long   0x00000000, 0x00000000, 0x00000000	| 408008D4

/* RUNDIAGS: jump to the start-up diagnostics (STARTTEST1). */
thunk_FUN_40847082:
RUNDIAGS:
    lea (STARTTEST1-thunk_FUN_40847082):l,%a0
    jmp %pc@(thunk_FUN_40847082,%a0:l)
    .short  0x0000, 0x0000, 0x0000	| 408008EA
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408008F0
RUNDIAGS_20:            /* unused (zeros) */
    .long   0x00000000, 0x00000000	| 40800900
STARTTESTFLAGS:         /* test flags (zeros) */
    .long   0x00000000, 0x00000000	| 40800908

/*
 SETUPHWBASES: set the low memory base address variables of the hardware this machine
 has. The table at SETUPHWBASES_3A has pairs (bit number in the 0xDD0 flags, low memory
 address): if the bit is set, the address is set from the decoder's base address table
 (UnivInfoPtr -> +0, entry = bit number). Then SETUPMISCSCSI.
*/
SETUPHWBASES:
    movel 0xdd0,%d0
    moveal 0xdd8,%a0
    addal %a0@,%a0
    lea %pc@(SETUPHWBASES_3A),%a2
SETUPHWBASES_E:         /* next pair (end at -1) */
    movew %a2@+,%d3
    jbmi SETUPHWBASES_20
    moveaw %a2@+,%a3
    btst %d3,%d0
    jbeq SETUPHWBASES_E
    lslw #2,%d3
    movel %a0@(0x0,%d3:w),%a3@
    jbra SETUPHWBASES_E
SETUPHWBASES_20:        /* done */
    bral SETUPMISCSCSI
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40800936
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40800940
SETUPHWBASES_3A:        /* (bit, low memory variable): VIA, SCC, IWM, SCSI, sound, VIA 2... */
    .short  0x0002, 0x01D4, 0x0003	| 4080094A
    .long   0x01D80004, 0x01DC0011, 0x01D80011, 0x01DC0005	| 40800950
    .long   0x01E00010, 0x01E00006, 0x0B0A0006, 0x03120007	| 40800960
    .long   0x02660008, 0x0C000009, 0x0C04000A, 0x0C08000B	| 40800970
    .long   0x0CEC000C, 0x0CC0000D, 0x0CEC000F, 0x0C00000F	| 40800980
    .long   0x0C04000F, 0x0C080012, 0x0CECFFFF, 0x00000000	| 40800990

/* INITSCSI: initialise the SCSI hardware (INITSCSIHW). */
thunk_FUN_4089863a:
INITSCSI:
    jbra INITSCSIHW
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408009A6
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408009B0

/*
 INITIWM: if the machine has a floppy controller (0xDD3 bit 5), set the IWM/SWIM chip to
 the mode wanted (INITSWIM2 is the patch that does it on this machine and returns to
 INITIWMRETURN).
*/
INITIWM:
    btst #5,0xdd3
    jbeq INITIWMRETURN_2C
    moveal IWM,%a0
INITIWM_C:              /* through the SWIM patch */
    bral INITSWIM2
    .short  0x0000, 0x0000, 0x0000	| 408009D2
INITIWMRETURN:          /* IWM: read the status, set the mode register to 0x17 if needed */
    moveq #23,%d0
    tstb %a0@(7168)
    tstb %a0@(4096)
    tstb %a0@(6656)
    moveb %a0@(7168),%d2
    btst #5,%d2
    jbne INITIWM_C
    andb %d0,%d2
    cmpb %d0,%d2
    jbeq INITIWMRETURN_28
    moveb %d0,%a0@(7680)
    tstb %a0@(7168)
    jbra INITIWM_C
INITIWMRETURN_28:       /* motor off */
    tstb %a0@(6144)
INITIWMRETURN_2C:       /* no floppy controller */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40800A06
INITIWMRETURN_38:       /* SCC initialisation data: register/value pairs (channel A, B) */
    .long   0x09C00940, 0x044C0200, 0x03C00F00, 0x00100010	| 40800A10
    .long   0x01000980, 0x044C03C0, 0x0F000010, 0x00100100	| 40800A20

/*
 INITSCC: initialise the two SCC (serial) channels from the table above, through the SCC
 IOP first if the machine has one (0xDD1 bit 1).
*/
INITSCC:
    btst #1,0xdd1
    jbeq INITSCC_C
    jsr %pc@(SCCIOPHWINIT)
INITSCC_C:              /* channel A: 18 bytes, then channel B: 14 bytes */
    moveal SCCWr,%a0
    moveal SCCRd,%a1
    nop
    lea %pc@(INITIWMRETURN_38),%a2
    moveq #18,%d1
    jbsr INITSCC_24
    addqw #2,%a0
    addqw #2,%a1
    moveq #14,%d1

INITSCC_24:             /* write d1 bytes from a2 to the SCC (reading it first to reset its pointer) */
    moveb %a1@,%d2
    jbra INITSCC_2E
INITSCC_28:             /* one byte, with a delay for the SCC's recovery time */
    movel %sp@,%sp@
    movel %sp@,%sp@
    moveb %a2@+,%a0@
INITSCC_2E:             /* next */
    dbf %d1,INITSCC_28
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40800A64

/*
 CONFIGURERAM: on entry fp = the RAM bank table (start, size pairs, ending with -1).
 Moves the stack into the first bank (at 3/4 of its size, at most 1.5 MB in), merges
 banks that are contiguous, clears the rest of the table up to a 64 KB boundary and
 stores its length at fp-8.
*/
CONFIGURERAM:
    moveal %sp@+,%sp
    movel %fp@(4),%d3
    cmpil #2097152,%d3
    jbge CONFIGURERAM_1A
    lsrl #2,%d3
    .short  0x4C3C, 0x3003, 0x0000, 0x0003	| 40800A80 mulul #3,%d3
    jbra CONFIGURERAM_20
CONFIGURERAM_1A:        /* big first bank: 1.5 MB */
    movel #1572864,%d3
CONFIGURERAM_20:        /* new stack, the return address moved onto it */
    exg %d3,%sp
    addal %fp@,%sp
    movel %d3,%sp@-
    moveal %fp,%a3
CONFIGURERAM_28:        /* next bank: add following banks while they are contiguous */
    moveal %a3,%a2
    movel %a3@+,%d3
CONFIGURERAM_2C:        /* merge */
    addl %a3@+,%d3
    cmpl %a3@+,%d3
    jbeq CONFIGURERAM_2C
    subl %a2@+,%d3
    movel %d3,%a2@+
    subql #4,%a3
    cmpil #-1,%a3@
    jbne CONFIGURERAM_28
    movel %a3@,%a2@+
CONFIGURERAM_42:        /* clear the rest of the table */
    clrl %a2@+
    movew %a2,%d3
    jbne CONFIGURERAM_42
    subal %fp,%a2
    movel %a2,%fp@(-8)
    rts
    .fill   0x120, 1, 0x00

/* INITVIDGLOBALS: nothing to do on this machine. */
INITVIDGLOBALS:
    rts
    .short  0x4E75, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40800BE2

/*
 RDVIDPARAM: read the video parameters of the sResource in the slot parameter block a0
 (spSlot, spID) and set the screen globals: ScrnBase (sFindDevBase), ScreenBytes (0xC24,
 from MinorLength), the default mode (GETDEFVIDMODE), then the mode's mVidParams block:
 RowBits/ColLines (0xC22/0xC20), ScreenRow and CrsrRow (0x8AC), ScrVRes, ScrHRes
 (0x104), CrsrBase (0x898). Attaches the slot VBL, marks 0xDB0 valid (0x5A932BC7).
 Out: d0 = 0 (Z) if it worked, else 1.
*/
RDVIDPARAM:
    moveml %d3/%a1-%a2,%sp@-
    moveb %a0@(50),%d3
    clrb %a0@(51)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    jbne RDVIDPARAM_A2
    moveq #27,%d0	/* _SlotManager 27: FINDDEVBASE, sFindDevBase */
    _SlotManager
    jbne RDVIDPARAM_A2
    movel %a0@,ScrnBase
    moveb #11,%a0@(50)
    moveq #2,%d0	/* _SlotManager 2: READSLOTLONG, sReadLong */
    _SlotManager
    bnew RDVIDPARAM_A2
    movel %a0@,ScreenBytes
    moveb %d3,%a0@(50)
    jbsr GETDEFVIDMODE
    moveb %d0,%a0@(50)
    moveq #6,%d0
    _SlotManager
    bnew RDVIDPARAM_A2
    moveb #1,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    bnew RDVIDPARAM_A2
    moveal %a0@,%a1
    movew %a1@(10),ColLines
    movew %a1@(12),RowBits
    movew %a1@(4),%d0
    movew %d0,ScreenRow
    movew %d0,CrsrRow
    movew %a1@(26),ScrVRes
    movew %a1@(22),ScrHRes
    movel %a1@,%d0
    addl %d0,ScrnBase
    movel ScrnBase,CrsrBase
    moveq #0,%d0
    moveb %a0@(49),%d0
    _AttachVBL
    movel #1519594439,VideoInfoOK
    movel %a1,%a0@(4)
    moveq #23,%d0	/* _SlotManager 23: SLOTDISPOSPTR, sDisposePtr */
    _SlotManager
    moveq #0,%d0
    jbra RDVIDPARAM_A4
RDVIDPARAM_A2:          /* failed */
    moveq #1,%d0
RDVIDPARAM_A4:          /* restore spID, Z = result */
    moveb %d3,%a0@(50)
    moveml %sp@+,%d3/%a1-%a2
    tstw %d0
    rts

/*
 OPENSDRVR: open the driver of the sResource in a0 (slot parameter block), with the
 device manager parameter block a1: the driver name from sReadDrvrName, slot and ID in
 an SEBlock on the stack, _Open (immediate). Out: d0, Z = no error.
*/
OPENSDRVR:
    movel %a2,%sp@-
    subaw #24,%sp
    moveal %sp,%a2
    movel %a2,%a0@(20)
    subaw #256,%sp
    movel %sp,%a0@
    moveq #25,%d0	/* _SlotManager 25: READSLOTDRVRNAME, sReadDrvrName */
    _SlotManager
    jbne OPENSDRVR_4C
    movel %a0@,%a2@(12)
    moveb %a0@(49),%a2@
    moveb %a0@(50),%a2@(1)
    clrb %a2@(16)
    movel %a2@(12),%a1@(18)
    clrl %a1@(28)
    clrw %a1@(32)
    bset #0,%a1@(33)
    movel %a2,%a1@(34)
    clrb %a1@(27)
    exg %a0,%a1
    .short  0xA200	| 40800CE8 _Open (flags 0x0200)
    exg %a0,%a1
OPENSDRVR_4C:           /* free the buffers */
    lea %sp@(280),%sp
    moveal %sp@+,%a2
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40800CF4

/*
 OPNVIDDEFLT: open the default video device from parameter RAM (GetVideoDefault): if its
 sResource is a video device (category 3, type 1, DrSW 1), read its parameters, open its
 driver and make it the main screen (INITVIDDEFLT). Out: Z = opened.
*/
OPNVIDDEFLT:
    moveal %a0,%a2
    subqw #2,%sp
    moveal %sp,%a0
    _GetVideoDefault
    moveb %a0@+,%a2@(49)
    moveb %a0@+,%a2@(50)
    addqw #2,%sp
    moveal %a2,%a0
    clrb %a0@(51)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    jbne OPNVIDDEFLT_40
    cmpil #196609,%a0@(40)
    jbne OPNVIDDEFLT_40
    cmpiw #1,%a0@(44)
    jbne OPNVIDDEFLT_40
    jbsr RDVIDPARAM
    jbne OPNVIDDEFLT_40
    jbsr OPENSDRVR
    jbne OPNVIDDEFLT_40
    bsrw INITVIDDEFLT
OPNVIDDEFLT_40:         /* Z = result */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40800D42

/*
 INITVIDDEFLT: make the device just opened the main screen: NewGDevice
 (move.l d0,-(sp) with the default mode, _NewGDevice), set it as MainDevice (0xCC8),
 DeviceList, TheGDevice and SrcDevice/the cursor device (0x8A0..0x8A8), its flags
 (main screen, screen device, active) and its default gamma table.
*/
INITVIDDEFLT:
    moveml %d1-%d2/%a0-%a1,%sp@-
    clrl %sp@-
    movew %a1@(24),%sp@-
    jbsr GETDEFVIDMODE
    movel %d0,%sp@-
    _NewGDevice
    moveal %sp@+,%a0
    movel %a0,TheGDevice
    movel %a0,DeviceList
    movel %a0,MainDevice
    movel %a0,SrcDevice
    movel %a0,CrsrDevice
    moveal %a0@,%a1
    oriw #-18432,%a1@(20)
    jsr %pc@(INITDEFGAMMA)
    moveml %sp@+,%d1-%d2/%a0-%a1
    moveq #0,%d0
    rts
    .long   0x00000000	| 40800D8C

/*
 ADDVIDDEVICE: add a gDevice for another video device (a1 = its open parameter block)
 unless the device list already has one for that driver: NewGDevice, link it at the end
 of the list, mark it active, default gamma.
*/
ADDVIDDEVICE:
    moveml %d1-%d2/%a0-%a3,%sp@-
    movew %a1@(24),%d1
    movel DeviceList,%d0
ADDVIDDEVICE_C:         /* walk the device list (gdNextGD at +30) */
    moveal %d0,%a2
    moveal %a2@,%a3
    cmpw %a3@,%d1
    jbeq ADDVIDDEVICE_3E
    movel %a3@(30),%d0
    jbne ADDVIDDEVICE_C
    clrl %sp@-
    movew %a1@(24),%sp@-
    bsrw GETDEFVIDMODE
    movel %d0,%sp@-	| 40800DB4
    _NewGDevice
    moveal %a2@,%a0
    movel %sp@,%a0@(30)
    moveal %sp@,%a0
    moveal %a0@,%a0
    oriw #8192,%a0@(20)
    moveal %sp@+,%a0
    jsr %pc@(INITDEFGAMMA)
ADDVIDDEVICE_3E:        /* done */
    moveml %sp@+,%d1-%d2/%a0-%a3
    moveq #0,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40800DD6

/*
 GETDEFVIDMODE: the default video mode for the slot: from the slot's PRAM record
 (sReadPRAMRec) if that mode exists for the sResource, else 0x80 (the first mode), which
 is then saved in the PRAM record (sPutPRAMRec). Out: d0 = mode.
*/
GETDEFVIDMODE:
    movel %a0@(4),%sp@-
    moveb %a0@(50),%sp@-
    movel %a1,%sp@-
    subqw #8,%sp
    moveal %sp,%a1
    movel %a1,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    jbne GETDEFVIDMODE_36
    clrb %a0@(51)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
GETDEFVIDMODE_1E:       /* does the saved mode exist (sFindStruct)? */
    bnew GETDEFVIDMODE_36
    moveb %a1@(2),%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne GETDEFVIDMODE_36
    moveq #0,%d0
    moveb %a1@(2),%d0
    jbra GETDEFVIDMODE_4A
GETDEFVIDMODE_36:       /* no: mode 0x80, and save it */
    moveb #0x80,%a1@(2)
    movel %a1,%a0@(4)
GETDEFVIDMODE_40:       /* sPutPRAMRec */
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */
    _SlotManager
    movel #128,%d0
GETDEFVIDMODE_4A:       /* restore the parameter block */
    addqw #8,%sp
    moveal %sp@+,%a1
    moveb %sp@+,%a0@(50)
    movel %sp@+,%a0@(4)
    rts
    .long   0x00000000, 0x00000000	| 40800E38

/*
 INITDEFGAMMA: give the gDevice handle in a0 its default gamma table. Finds the video
 sResource of its driver's slot: an Apple built-in video (DrHW 1) uses the ROM's 'gama'
 resource 0, otherwise the sResource's sGammaDir entry 0x80 is read into a new handle and
 its name skipped. Then Control(cscSetGamma = 4) to the driver, and the copy disposed.
*/
INITDEFGAMMA:
    linkw %fp,#-76
    moveml %a2-%a3,%sp@-
    moveal %a0,%a2
    moveal %a2@,%a0
    movew %a0@,%d0
    notw %d0
    moveal UTableBase,%a0
    moveal %a0@(0x0,%d0:w:4),%a0
    moveal %a0@,%a0
    subaw #56,%sp
    moveb %a0@(40),%sp@(49)
    moveal %sp,%a0
    clrw %a0@(50)
    movew #3,%a0@(40)
    movew #1,%a0@(42)
    movew #1,%a0@(44)
    moveb #1,%a0@(48)
    moveq #21,%d0	/* _SlotManager 21: NEXTTYPESRSRC, sNextTypesRsrc */
    _SlotManager
    jbne INITDEFGAMMA_E6
    cmpiw #1,%a0@(46)
    beqw INITDEFGAMMA_9E
    moveb #64,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne INITDEFGAMMA_E6
    moveb #0x80,%a0@(50)
    moveq #38,%d0	/* _SlotManager 38: READPBSIZE, sReadPBSize */
    _SlotManager
    jbne INITDEFGAMMA_E6
    moveal %a0,%a3
    movel %a0@(8),%d0
    .short  0xA122	| 40800EB4 _NewHandle (flags 0x0100)
    jbne INITDEFGAMMA_E6
    _HLock
    exg %a0,%a3
    moveal %a3@,%a1
    movel %a1,%a0@
    subqw #4,%a0@(8)
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */
    _SlotManager
    jbne INITDEFGAMMA_E6
    moveal %a0@,%a0
    addqw #2,%a0
INITDEFGAMMA_8E:        /* skip the gamma table name (C string, even aligned) */
    tstb %a0@+
    jbne INITDEFGAMMA_8E
    movel %a0,%d0
    addql #1,%d0
    andib #0xfe,%d0
    moveal %d0,%a0
    jbra INITDEFGAMMA_BC
INITDEFGAMMA_9E:        /* built-in video: the ROM's 'gama' 0 */
    subqw #4,%sp
    movel #1734438241,%sp@-
    clrw %sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@,%sp@-
    _DetachResource
    moveal %sp@+,%a0
    _HLock
    moveal %a0,%a3
    moveal %a0@,%a0
INITDEFGAMMA_BC:        /* SetGamma control call (0xA204: _Control, immediate) */
    lea %fp@(-76),%a1
INITDEFGAMMA_C0:        /* csParam -> the gamma table pointer */
    movel %a0,%a1@
    lea %fp@(-64),%a0
    movel %a1,%a0@(28)
    movew #4,%a0@(26)
    clrl %a0@(12)
    clrw %a0@(22)
    moveal %a2@,%a1
    movew %a1@,%a0@(24)
    .short  0xA204	| 40800F1E _Control (flags 0x0200)
    moveal %a3,%a0
    _HUnlock
    _DisposHandle
INITDEFGAMMA_E6:        /* done */
    lea %sp@(56),%sp
    moveml %sp@+,%a2-%a3
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40800F32

/*
 INITDUMMYSCREEN: no usable video: a 32 x 32 pixel, 1 bit screen in memory (_NewPtr of
 128 bytes, raw word 0xA11E), with its gDevice, pixel map (72 dpi) and color table, so
 that QuickDraw can work without a display.
*/
INITDUMMYSCREEN:
    moveq #32,%d0
    movew %d0,ColLines
    movew %d0,RowBits
    moveq #4,%d1
    movew %d1,ScreenRow
    movew %d1,CrsrRow
    muluw %d1,%d0
    movel %d0,ScreenBytes
    .short  0xA11E	| 40800F5A _NewPtr (flags 0x0100)
    movel %a0,ScrnBase
    movel %a0,IconTLAddr
    movel %a0,CrsrBase
    moveq #72,%d0
    movew %d0,ScrHRes
    movew %d0,ScrVRes
    clrl %sp@-
    clrw %sp@-
    moveq #-1,%d0
    movel %d0,%sp@-
    _NewGDevice
    moveal %sp@+,%a0
    movel %a0,TheGDevice
    movel %a0,DeviceList
    movel %a0,MainDevice
    movel %a0,SrcDevice
    movel %a0,CrsrDevice
    moveal %a0@,%a1
    movew #-1024,%a1@(20)
    movew #4,%a1@(10)
    moveal %a1@(22),%a0
    moveal %a0@,%a0
    movel ScrnBase,%a0@
    movew ScreenRow,%a0@(4)
    moveq #32,%d0
    movew %d0,%a0@(12)
    movew %d0,%a0@(10)
    movew %d0,%a1@(40)
    movew %d0,%a1@(38)
    moveq #72,%d0
    swap %d0
    movel %d0,%a0@(22)
    movel %d0,%a0@(26)
    moveq #1,%d0
    movew %d0,%a0@(32)
    movew %d0,%a0@(34)
    movew %d0,%a0@(36)
    moveal %a0@(42),%a0
INITDUMMYSCREEN_A0:     /* 2-entry color table */
    moveal %a0@,%a0
    moveq #1,%d1
    movel %d1,%a0@+
    movel %d1,%a0@+
    clrw %a0@+
    moveq #-1,%d0
    movel %d0,%a0@+
    movew %d0,%a0@+
    swap %d1
    movel %d1,%a0@+
    clrl %a0@+
    rts
INITDUMMYSCREEN_B8:     /* unused (zeros) */
    .long   0x00000000, 0x00000000	| 40800FF8

/*
 FROVIDEO: find and open the video. a0 = a device manager parameter block. The default
 video from parameter RAM first, otherwise every video sResource in turn
 (sNextTypesRsrc) until one can be opened, otherwise the dummy screen.
*/
FROVIDEO:
    moveal %a0,%a1
    linkw %fp,#-56
    moveal %sp,%a0
    jbsr OPNVIDDEFLT
    jbeq FROVIDEO_4C
    movel #196609,%a0@(40)
    movew #1,%a0@(44)
FROVIDEO_1C:            /* search from slot 0, ID 0 */
    moveb #1,%a0@(48)
    clrb %a0@(49)
    clrb %a0@(50)
    clrb %a0@(51)
FROVIDEO_2E:            /* next video sResource (none: dummy screen) */
    moveq #21,%d0	/* _SlotManager 21: NEXTTYPESRSRC, sNextTypesRsrc */
    _SlotManager
    jbeq FROVIDEO_3A
    jbsr INITDUMMYSCREEN
    jbra FROVIDEO_4C
FROVIDEO_3A:            /* try it */
    jbsr RDVIDPARAM
    jbne FROVIDEO_2E
    jbsr OPENSDRVR
    jbne FROVIDEO_2E
    jbsr INITVIDDEFLT
    jbne FROVIDEO_2E
FROVIDEO_4C:            /* done */
    unlk %fp
    rts

/* INITCRSRVARS: clear the cursor globals, from JHideCursor up to WWExist. */
INITCRSRVARS:
    lea GrafBegin_JHideCursor,%a0
    lea WWExist,%a1
INITCRSRVARS_8:         /* clear loop */
    clrw %a0@+
    cmpal %a1,%a0
    jbcs INITCRSRVARS_8
    rts

/*
 INITCRSRMGR: cursor manager start-up. Mouse position 15,15 (MTemp, RawMouse, Mouse),
 CrsrPin = the screen, the mouse tracking (MickeyBytes) block of 28 bytes, the cursor
 VBL task and jump vectors (JHideCursor... from CRSRCORE, CrsrSave), mouse settings
 from XPRAM 0x82 (6 bytes to 0xDA0), CrsrNew and MouseMask = -1.
*/
INITCRSRMGR:
    movel #983055,%d0
    lea MTemp_v,%a0
    movel %d0,%a0@+
    movel %d0,%a0@+
    movel %d0,%a0@+
    clrl %a0@+
    movew ColLines,%a0@+
    movew RowBits,%a0@
    moveq #28,%d0
    .short  0xA51E	| 4080107C _NewPtr (flags 0x0500)
    movel %a0,MickeyBytes
    movew #1,%a0@
    movew #8,%a0@(2)
    clrw %a0@(18)
    lea %pc@(INITCRSRMGR_86),%a1
    lea %a0@(20),%a0
    movel %a1@+,%a0@+
    movel %a1@,%a0@
    lea WWExist,%a1
    biglea CRSRDEVHANDLEVBL
    movel %a0,%a1@-
    movew #6,%a1@-
    biglea CRSRCORE
    lea GrafBegin_JHideCursor,%a1
    moveq #7,%d1
    jbsr JMPTBLINIT
    lea CrsrSave,%a1
    moveq #1,%d1
    jbsr JMPTBL2
    lea HiliteRGB,%a0
    movel #393346,%d0
    _ReadXPRam
    moveq #-1,%d0
    movew %d0,CrsrNew
    movel %d0,MouseMask
    rts
INITCRSRMGR_86:         /* 8 bytes copied into the MickeyBytes block (tracking parameters) */
    .short  0x040A, 0x0FFF, 0xFF53, 0x4D48, 0x0000	| 408010E6

/*
 INITIOMGR: start the I/O system: the IOP Manager, SWIM IOP interrupts and SCC IOP
 bypass when there are IOPs, the unit table (64 entries, 512 bytes allocated), then
 opens the .Sony floppy driver (and, through the patch spaces, .netBOOT and .EDisk),
 finds and opens the video (FROVIDEO), backlight, and runs a code resource from the ROM
 if present (the type comes from BACKLIGHTPATCH).
*/
INITIOMGR:
    jbsr INITIOPMGR
    btst #0,0xdd1
    jbeq INITIOMGR_16
    bigjsr ENABLESWIMIOPINTS
INITIOMGR_16:           /* SCC IOP in bypass mode */
    btst #1,0xdd1
    jbeq INITIOMGR_22
    jbsr SCCIOPBYPASS
INITIOMGR_22:           /* unit table, then open the drivers */
    moveq #64,%d0
    movew %d0,UnitTableEntryCount
    movel #128,%d0
    asll #2,%d0
    .short  0xA71E	| 40801120 _NewPtr (flags 0x0700)
    movel %a0,UTableBase
    subaw #50,%sp
    moveal %sp,%a0
    clrb %a0@(27)
    lea %pc@(PSTR_Sony),%a1
    jsr %pc@(PATCHSPACE2)
    nop
    jsr %pc@(PATCHSPACE1)
    movel %a1,%a0@(18)
    _Open
    moveal SonyVars,%a1
    movel %a1@(304),%sp@-
    jbsr FROVIDEO
    movel %sp@+,%d0
    cmpib #3,0xcb3
    jbne INITIOMGR_72
    moveal SonyVars,%a1
    movel %d0,%a1@(304)
INITIOMGR_72:           /* video done */
    lea %sp@(50),%sp
    jbsr BACKLIGHTPATCH
    nop
    clrw %sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@+,%d0
    jbeq INITIOMGR_92
    moveal %d0,%a0
    moveal %a0@,%a0
    jsr %a0@
INITIOMGR_92:           /* done */
    rts
PSTR_Sony:              /* Pascal string ".Sony" */
    .byte   5	/* 40801184 Pascal string length */
    .ascii  ".Sony"	| 40801185
SNDNAME:                /* Pascal string ".Sound" */
    .byte   0x06	| 4080118A
    .ascii  ".Sound \000\000"
    .long   0x00000000, 0x00000000, 0x00000000	| 40801194

/*
 INITMEMMGR: Memory Manager globals (Lo3Bytes, MinStack 1 KB, DefltStack 24 KB) and its
 trap vectors.
*/
INITMEMMGR:
    movel #16777215,Lo3Bytes
    movel #1024,MinStack
    movel #24576,DefltStack
    clrw MMDefFlags
    bigjsr INITMEMVECT
    rts
    .long   0x00000000, 0x00000000	| 408011C8

/*
 INITRSRCMGR: start the Resource Manager (InitResources) with the ROM map, 0x1EFC bit 0
 set while it runs.
*/
INITRSRCMGR:
    st SysMap
    clrl TopMapHndl
    moveb 0x1efc,%sp@-
    bset #0,0x1efc
    clrw %sp@-
    _InitResources
    addqw #2,%sp
    moveb %sp@+,0x1efc
    rts
    .short  0x0000	| 408011EE

/* INITDTQUEUE: empty Deferred Task queue (DTQueue 0xD92), JDTInstall (0xD9C). */
INITDTQUEUE:
    lea 0xd92,%a1
    bigjsr INITQUEUE
    biglea trap_DTInstall, a1
    movel %a1,JDTInstall
    rts
    .short  0x0000	| 4080120E

/*
 INITSLOTS: Slot Manager start-up: slot interrupt and VBL queues, then the Slot
 Declaration Manager. A failure is a critical error (d7 = 31: sad Mac).
*/
INITSLOTS:
    bigjsr INITSDTBL
    bigjsr INITVBLQS
    jsr %pc@(STARTSDECLMGR)
    jbeq INITSLOTS_22
    movel %d0,%d6
    moveq #31,%d7
    jbra CRITICAL
INITSLOTS_22:           /* done */
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40801234

/* GOOFYDOEJECT: _Eject (A0F7) entry: jump to DOEJECT. */
trap_OSTrap_A0F7:
GOOFYDOEJECT:
    lea (trap_DOEJECT-trap_OSTrap_A0F7):l,%a0
    jmp %pc@(trap_OSTrap_A0F7,%a0:l)
    .short  0x0000, 0x0000, 0x0000	| 4080124A
