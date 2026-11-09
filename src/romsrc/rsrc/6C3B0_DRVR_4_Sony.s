/* ROM resource 'DRVR' 4 ".Sony": map entry at 0x4086C3B0, data at 0x4086C3E0, 26816 bytes

 The floppy disk driver .Sony ('DRVR' 4): the SuperDrive (800K and 1.4 MB, GCR and MFM)
 on the SWIM floppy controller, or through the SWIM I/O processor on machines that have
 one. Prime reads and writes sectors (with the track cache); Control and Status calls are
 found by csCode in SONY_CONTROL_TABLE and SONY_STATUS_TABLE, each with a second handler
 for drive numbers 3 and up (HD20 hard disks on the floppy port). Comments inferred from
 the code and the disk driver calls documented in Inside Macintosh; routine headers
 describe each subroutine and the labels inside say what each step does. The Quadra 800
 has no SWIM IOP (bit 0 of 0xDD1 clear): the IOP variant at the start (5E..5FC) is not
 used there.
*/

rsrc_DRVR_4__Sony_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 4086C3B0
    .long   rsrc_SERD_0_entry-rom_start	| 4086C3B8
    .long   rsrc_DRVR_4__Sony-rom_start	| 4086C3BC
    .ascii  "DRVR"	| 4086C3C0
    .byte   0x00, 0x04, 0x58	| 4086C3C4
    .byte   5	/* 4086C3C7 Pascal string length */
    .ascii  ".Sony"	| 4086C3C8
    .byte   0x00, 0x00, 0x00	| 4086C3CD
    .long   0x00000000, 0xC0A00000, 0x000068CC, 0x000001AC	| 4086C3D0

/* the driver: header, then the code */
rsrc_DRVR_4__Sony:
/* driver header: flags, delay, event mask, menu, then the routine offsets */
    .short  0x4F00, 0x0000, 0x0000, 0x0000	| 4086C3E0
    .short  rsrc_DRVR_4__Sony_open-rsrc_DRVR_4__Sony
    .short  rsrc_DRVR_4__Sony_prime-rsrc_DRVR_4__Sony
    .short  rsrc_DRVR_4__Sony_ctl-rsrc_DRVR_4__Sony
    .short  rsrc_DRVR_4__Sony_status-rsrc_DRVR_4__Sony
    .short  rsrc_DRVR_4__Sony_close-rsrc_DRVR_4__Sony
    .byte   5	/* 4086C3F2 Pascal string length */
    .ascii  ".Sony"	| 4086C3F3

/*
 Open: the driver's variables, the drives present (internal, external), a drive queue
 element for each, the interrupt handlers and VBL task for disk insertion.
*/
rsrc_DRVR_4__Sony_open:
    btst #0,0xdd1
    jbeq rsrc_DRVR_4__Sony_64A_E
    braw rsrc_DRVR_4__Sony_5E

/*
 Prime: read or write sectors of the disk in the drive (track cache, retries,
 verification).
*/
rsrc_DRVR_4__Sony_prime:
    movel DiskVars_JDiskPrime,%sp@-
    rts
    .long   0x00000000	| 4086C40C
    .long   0x00000000	| 4086C410

/* Control: find csCode in SONY_CONTROL_TABLE and call its handler. */
rsrc_DRVR_4__Sony_ctl:
    movel DiskVars_JControl,%sp@-
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4086C41A

/* Status: find csCode in SONY_STATUS_TABLE and call its handler. */
rsrc_DRVR_4__Sony_status:
    btst #0,0xdd1
    jbeq rsrc_DRVR_4__Sony_996
    jbra rsrc_DRVR_4__Sony_2FA

/* Close: with the SWIM I/O processor (bit 0 of 0xDD1) the IOP driver's close, otherwise
 closErr (the floppy driver stays open). */
rsrc_DRVR_4__Sony_close:
    btst #0,0xdd1
    jbeq rsrc_DRVR_4__Sony_5FC
    jbra rsrc_DRVR_4__Sony_1C2

rsrc_DRVR_4__Sony_5E:   /* IOP variant Open: SonyVars (770 bytes, the IOP message area before it), the drive table, the icons */
    movel #770,%d0
    .short  0xA71E	| 4086C444 _NewPtr (flags 0x0700)
    lea %a0@(630),%a0
    movel %a0,SonyVars
    movel %a1,%a0@(-4)
    moveb #2,%a1@(7)
    moveal %a0,%a1
    jbsr rsrc_DRVR_4__Sony_1CCA
    movew %a2@,%d0
    jbsr rsrc_DRVR_4__Sony_5E_3E
    movel %a3,%a1@(-8)
    movew %a2@(2),%d0
    jbsr rsrc_DRVR_4__Sony_5E_3E
    movel %a3,%a1@(-12)
    movew %a2@(8),%d0
    jbsr rsrc_DRVR_4__Sony_5E_3E
    movel %a3,%a1@(-16)
    jbra rsrc_DRVR_4__Sony_5E_50

/* rsrc_DRVR_4__Sony_5E_3E: IOP variant (SWIM I/O processor, bit 0 of 0xDD1; not used on the Quadra 800): open: a3 = an icon or table entry from its offset; then register the IOP message handlers, install the Prime/Control vectors, the Control and Status dispatch tables, and AddDrive for each drive the IOP reports */
rsrc_DRVR_4__Sony_5E_3E:/* a3 = an icon: offset from the table (odd offsets: in the ROM icon list) */
    lea %a2@(0x0,%d0:w),%a3
    bclr #0,%d0
    jbeq rsrc_DRVR_4__Sony_5E_4E
    lea %pc@(rsrc_DRVR_4__Sony_1508),%a3
    addaw %d0,%a3
rsrc_DRVR_4__Sony_5E_4E:  /* return */
    rts
rsrc_DRVR_4__Sony_5E_50:/* register the IOP message handlers (receive and send), install the Prime/Control vectors and the dispatch tables */
    lea %a1@(-94),%a0
    movew #258,%a0@+
    movel #35659776,%a0@+
    lea %a1@(-132),%a2
    movel %a2,%a0@+
    movel %a2,%a0@+
    lea %pc@(rsrc_DRVR_4__Sony_5A6),%a2
    movel %a2,%a0@+
    lea %a1@(-100),%a0
    _IOPMsgRequest
    jbne rsrc_DRVR_4__Sony_5E_138
    lea %a1@(-34),%a0
    movew #256,%a0@+
    movel #35659776,%a0@+
    lea %a1@(-72),%a2
    movel %a2,%a0@+
    movel %a2,%a0@+
    lea %pc@(rsrc_DRVR_4__Sony_590),%a2
    movel %a2,%a0@+
    moveb #1,%a1@(-72)
    jbsr rsrc_DRVR_4__Sony_1B0
    lea %pc@(rsrc_DRVR_4__Sony_1CC),%a2
    movel %a2,DiskVars_JDiskPrime
    lea %pc@(rsrc_DRVR_4__Sony_2F4),%a2
    movel %a2,DiskVars_JControl
    lea %a1@(-256),%a2
    lea %pc@(rsrc_DRVR_4__Sony_2AC),%a3
    moveq #-17,%d0
    moveq #10,%d1
    bsrw rsrc_DRVR_4__Sony_5E_13A
    lea %a1@(-336),%a2
    lea %pc@(rsrc_DRVR_4__Sony_28E),%a3
    moveq #-18,%d0
    moveq #4,%d1
    jbsr rsrc_DRVR_4__Sony_5E_13A
    lea %a1@(20),%a2
    lea %a1@,%a3
    lea %a1@(-68),%a4
    moveq #0,%d1
    moveq #6,%d2
    moveq #3,%d3
    movew #3964,%d4
rsrc_DRVR_4__Sony_5E_DE:/* each drive the IOP reports: present? a drive queue element (-5 for the HD20, -2 for floppies with the size) */
    moveb %a4@+,%d5
    btst %d5,%d3
    jbne rsrc_DRVR_4__Sony_5E_114
    movel %a2,%a3@
    moveb #1,%a2@(2)
    moveq #-5,%d0
    btst %d5,%d4
    jbne rsrc_DRVR_4__Sony_5E_104
    moveq #-2,%d0
    movew #1,%a2@(8)
    moveal UTableBase,%a0
    movel %a0@(16),%a0@(4)
rsrc_DRVR_4__Sony_5E_104:/* AddDrive with the drive number */
    swap %d0
    movew %d1,%d0
    swap %d0
    lea %a2@(4),%a0
    _AddDrive
    lea %a2@(20),%a2
rsrc_DRVR_4__Sony_5E_114:/* next drive; tell the IOP to start polling */
    addql #4,%a3
    addqw #1,%d1
    cmpiw #4,%d1
    jbls rsrc_DRVR_4__Sony_5E_DE
    moveb #5,%a1@(-72)
    movel #906,%a1@(-68)
    jbsr rsrc_DRVR_4__Sony_1B0
    moveb #3,%a1@(-72)	| 4086C56C
    jbsr rsrc_DRVR_4__Sony_1B0
    moveq #0,%d0
rsrc_DRVR_4__Sony_5E_138:  /* return */
    rts

/* rsrc_DRVR_4__Sony_5E_13A: IOP variant: build a csCode dispatch table at a2: count, base, then (csCode, handler) pairs made absolute */
rsrc_DRVR_4__Sony_5E_13A:/* the table header: count, base */
    movel %a2,%a2@(-4)
    movew %d1,%a2@+
    movew %d0,%a2@+
rsrc_DRVR_4__Sony_5E_142:/* each (csCode, handler) pair made absolute */
    movel %a3@+,%a2@+
    lea %pc@(rsrc_DRVR_4__Sony),%a4
    addaw %a3@+,%a4
    movel %a4,%a2@+
    dbf %d1,rsrc_DRVR_4__Sony_5E_142
    rts

/* rsrc_DRVR_4__Sony_1B0: IOP variant: send the request message to the SWIM IOP and wait for its reply (1B0_A polls until the reply clears a1-76) */
rsrc_DRVR_4__Sony_1B0:
    pea %pc@(rsrc_DRVR_4__Sony_1B0_A)
    jbsr rsrc_DRVR_4__Sony_584
    rts

/* rsrc_DRVR_4__Sony_1B0_A: IOP variant: wait for the IOP reply; then the Prime path: build the read/write request (drive, block, count, buffer, tags) for the IOP */
rsrc_DRVR_4__Sony_1B0_A:/* wait until the IOP replies (a1-76 cleared) */
    tstl %a1@(-76)
    jbne rsrc_DRVR_4__Sony_1B0_A
    rts

rsrc_DRVR_4__Sony_1C2:  /* closErr (-24): the driver stays open */
    moveq #-24,%d0
    rts
    .byte   0x2F, 0x38, 0x02, 0x26, 0x4E, 0x75	| 4086C5A6
rsrc_DRVR_4__Sony_1CC:  /* IOP Prime: the request message: read (10) or write (11; 12 = verify), drive, block, count, buffer, tags */
    jbsr SONY_ICON_DRIVE17_mask_82	| 4086C5AC
    nop	| 4086C5B0
    moveq #10,%d0	| 4086C5B2
    cmpib #2,%a0@(7)	| 4086C5B4
    bnes rsrc_DRVR_4__Sony_1E8
    moveq #11,%d0
    btst #6,%a0@(45)
    jbeq rsrc_DRVR_4__Sony_1E8
    moveq #12,%d0
rsrc_DRVR_4__Sony_1E8:  /* drive number 1..4 else nsDrvErr; block and count must be whole sectors (paramErr) */
    moveb %d0,%a3@+
    moveq #-56,%d0
    movew %a0@(22),%d1
    cmpiw #4,%d1
    jbhi rsrc_DRVR_4__Sony_28A
    moveb %d1,%a3@+
    clrw %a3@+
    movel %a0@(32),%a3@+
    moveq #-50,%d0
    moveq #9,%d1
    movel %a2@(16),%d2
    rorl %d1,%d2
    movel %d2,%a3@+
    roll %d1,%d2
    andiw #511,%d2
    jbne rsrc_DRVR_4__Sony_28A
    movel %a0@(36),%d2
    rorl %d1,%d2
    movel %d2,%a3@+
    roll %d1,%d2
    andiw #511,%d2
    jbne rsrc_DRVR_4__Sony_28A
    lea BufTgFNum,%a2
    movel %a2@+,%a3@+
    movel %a2@+,%a3@+
    movel %a2@+,%a3@+
    jbsr rsrc_DRVR_4__Sony_584
    lea %a1@(-56),%a0
    lea BufTgFNum,%a2
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    moveq #0,%d1
    moveb %a1@(-71),%d1
    movel %a1@(0x0,%d1:w:4),%d2
    jbeq rsrc_DRVR_4__Sony_270
    moveal %d2,%a3
    cmpib #2,%a3@(1)
    jbeq rsrc_DRVR_4__Sony_270
    movew %a1@(-70),%a1@(-630)
    moveb #6,%a1@(-72)
    jbsr rsrc_DRVR_4__Sony_584
    jbsr rsrc_DRVR_4__Sony_506
    movew %a1@(-630),%a1@(-70)
rsrc_DRVR_4__Sony_270:  /* done: the bytes transferred */
    movew %a1@(-70),%d0
    jbne rsrc_DRVR_4__Sony_28A
    moveal %a1@(-4),%a2
    moveal %a2@(8),%a0
    movel %a0@(36),%d1
    movel %d1,%a0@(40)
    addl %d1,%a2@(16)
rsrc_DRVR_4__Sony_28A:  /* finish */
    jbra rsrc_DRVR_4__Sony_358
rsrc_DRVR_4__Sony_28E:  /* (data) */
    .byte   0x00, 0x06, 0x06, 0xE0, 0x04, 0x80, 0x00, 0x08, 0x06, 0xA0, 0x04, 0xD6, 0x00, 0x0A, 0x06, 0xA0	| 4086C66E
    .byte   0x04, 0xEA, 0x44, 0x56, 0x10, 0x20, 0x04, 0xF2, 0x53, 0x43, 0x10, 0x20, 0x04, 0xFC	| 4086C67E
rsrc_DRVR_4__Sony_2AC:  /* (data) */
    .byte   0x00, 0x01, 0x00, 0x00, 0x03, 0x6A, 0x00, 0x05, 0x09, 0xE0, 0x03, 0x80, 0x00, 0x06, 0x08, 0xC0	| 4086C68C
    .byte   0x03, 0x6E, 0x00, 0x07, 0x07, 0xE0, 0x03, 0x7C, 0x00, 0x08, 0x0E, 0x20, 0x03, 0x80, 0x00, 0x09	| 4086C69C
    .byte   0x0D, 0x20, 0x03, 0x80, 0x00, 0x15, 0x06, 0xE0, 0x03, 0x86, 0x00, 0x16, 0x06, 0xE0, 0x03, 0xA8	| 4086C6AC
    .byte   0x00, 0x17, 0x06, 0xE0, 0x03, 0xDC, 0x53, 0x43, 0x08, 0xC0, 0x03, 0xE8, 0x47, 0x44, 0x11, 0xC0	| 4086C6BC
    .byte   0x04, 0x58, 0x2F, 0x38, 0x02, 0x42, 0x4E, 0x75	| 4086C6CC
rsrc_DRVR_4__Sony_2F4:  /* IOP Control: the control table at -260 */
    moveaw #-260,%a2	| 4086C6D4
    jbra rsrc_DRVR_4__Sony_2FE	| 4086C6D8

rsrc_DRVR_4__Sony_2FA:  /* IOP Status: the status table at -340 */
    moveaw #-340,%a2
rsrc_DRVR_4__Sony_2FE:  /* find the drive */
    jbsr rsrc_DRVR_4__Sony_5566
    jbra rsrc_DRVR_4__Sony_2FA_16
    .long   0x00000000, 0x00000000, 0x00000000	| 4086C6E4
rsrc_DRVR_4__Sony_2FA_16:/* find csCode; not found: controlErr/statusErr */
    cmpw %a2@,%d2
    addql #8,%a2
    dbeq %d1,rsrc_DRVR_4__Sony_2FA_16
    jbne rsrc_DRVR_4__Sony_358
    moveq #0,%d0
    moveal %a2@-,%a3
    movew %a0@(22),%d1
    moveb %a2@-,%d2
    jbpl rsrc_DRVR_4__Sony_2FA_36
    cmpiw #4,%d1
    jbls rsrc_DRVR_4__Sony_2FA_36
    moveq #-56,%d0
    jbra rsrc_DRVR_4__Sony_358
rsrc_DRVR_4__Sony_2FA_36:/* needs a disk? none: offLinErr */
    addb %d2,%d2
    jbpl rsrc_DRVR_4__Sony_2FA_44
    tstl %a1@(0x0,%d1:w:4)
    jbne rsrc_DRVR_4__Sony_2FA_44
    moveq #-64,%d0
    jbra rsrc_DRVR_4__Sony_358
rsrc_DRVR_4__Sony_2FA_44:/* the message: drive, code, parameters; send it, or call a local handler */
    moveb %d1,%a1@(-71)
    moveb %a2@-,%a1@(-72)
    movel %a0@(28),%a1@(-68)
    addb %d2,%d2
    jbpl rsrc_DRVR_4__Sony_2FA_5C
    movel %a3,%sp@-
    jbra rsrc_DRVR_4__Sony_584
rsrc_DRVR_4__Sony_2FA_5C:/* local handler */
    jmp %a3@

rsrc_DRVR_4__Sony_358:  /* IODone (error in DskErr) */
    movel JIODone,%sp@-
    moveal %a1@(-4),%a1
    extl %d0
    jbeq rsrc_DRVR_4__Sony_358_10
    movew %d0,DskErr
rsrc_DRVR_4__Sony_358_10:  /* return */
    rts
    moveq #-17,%d0
    jbra rsrc_DRVR_4__Sony_358
    .short  0x45E9	| 4086C74E
    .long   0xFFBE425A, 0x429A429A	| 4086C750
    jbsr rsrc_DRVR_4__Sony_584
    jbsr rsrc_DRVR_4__Sony_506
rsrc_DRVR_4__Sony_358_28:/* the reply's result */
    movew %a1@(-70),%d0
    jbra rsrc_DRVR_4__Sony_358
    jbsr rsrc_DRVR_4__Sony_506
    moveal %a1@(-12),%a3
    btst #3,%a1@(-56)
    jbeq rsrc_DRVR_4__Sony_358_42
    moveal %a1@(-16),%a3
rsrc_DRVR_4__Sony_358_42:/* icon request: the media or the drive icon */
    movew #1,%a1@(-64)
    btst #1,%a1@(-42)
    jbra rsrc_DRVR_4__Sony_358_62
    jbsr rsrc_DRVR_4__Sony_506
    moveal %a1@(-8),%a3
    clrw %a1@(-64)
    btst #0,%a1@(-42)
rsrc_DRVR_4__Sony_358_62:/* from the ROM or the IOP's buffer */
    jbne rsrc_DRVR_4__Sony_358_68
    movel %a3,%a0@
    jbra rsrc_DRVR_4__Sony_358
rsrc_DRVR_4__Sony_358_68:/* fetch the icon from the IOP (288 bytes) */
    lea %a1@(-628),%a3
    movel %a3,%a0@
    movel %a3,%a1@(-68)
    movew #288,%a1@(-60)
    moveb #15,%a1@(-72)
    jbsr rsrc_DRVR_4__Sony_584
    jbra rsrc_DRVR_4__Sony_358_28
    bsrw rsrc_DRVR_4__Sony_506
    movel %a2@(14),%a0@
    braw rsrc_DRVR_4__Sony_358
    lea %a1@(-66),%a2
    moveb %a0@(38),%a2@+
    clrb %a2@+
    movel %a0@(30),%a2@+
    movel %a0@(34),%a2@+
    jbsr rsrc_DRVR_4__Sony_584
    jbsr rsrc_DRVR_4__Sony_506
    movew %a1@(-70),%d0
    jbne rsrc_DRVR_4__Sony_358_FE
    tstb %a0@(11)
    jbeq rsrc_DRVR_4__Sony_358_FE
    movel %a1@(-46),%a1@(-60)
    moveb #12,%a1@(-72)
    movel %a0@(2),%a1@(-68)
    clrl %a1@(-64)
    jbsr rsrc_DRVR_4__Sony_584
    movew %a1@(-70),%a1@(-630)
    moveb #6,%a1@(-72)
    jbsr rsrc_DRVR_4__Sony_584
    movew %a1@(-630),%d0
    jbne rsrc_DRVR_4__Sony_358_FE
    moveq #0,%d1
    moveb %a1@(-71),%d1
    moveal %a1@(0x0,%d1:w:4),%a2
    moveq #-68,%d0
    movew %a2@(18),%d1
    cmpw %a1@(-60),%d1
    jbne rsrc_DRVR_4__Sony_358_FE
    moveq #0,%d0
rsrc_DRVR_4__Sony_358_FE:/* done */
    jbra rsrc_DRVR_4__Sony_358_124
    .long   0x45E9FFBC, 0x41E8001C	| 4086C838
    .long   0x24D824D8, 0x24D84298, 0x24D834D8, 0x61000116	| 4086C840
    .long   0x3029FFBA, 0x66062169, 0xFFC40028	| 4086C850
rsrc_DRVR_4__Sony_358_124:/* format list: the formats the IOP reported */
    jbra rsrc_DRVR_4__Sony_358
    jbsr rsrc_DRVR_4__Sony_506
    moveq #-65,%d0
    cmpib #2,%a2@(7)
    jblt rsrc_DRVR_4__Sony_358_124
    moveq #-50,%d0
    movew %a0@+,%d2
    jble rsrc_DRVR_4__Sony_358_124
    movew %a2@(24),%d0
    movew %a2@(22),%d1
    moveal %a0@,%a2
    lea %pc@(rsrc_DRVR_4__Sony_548),%a3
    clrw %a0@-
    moveq #0,%d3
rsrc_DRVR_4__Sony_358_14E:/* each format bit: size and flags; current one marked */
    bclr %d3,%d0
    jbeq rsrc_DRVR_4__Sony_358_174
    movel %a3@(0x0,%d3:w:8),%a2@+
    movel %a3@(0x4,%d3:w:8),%a2@+
    bclr %d3,%d1
    jbeq rsrc_DRVR_4__Sony_358_16E
    bset #6,%a2@(-4)
    tstw %d3
    jbne rsrc_DRVR_4__Sony_358_16E
    movel %a1@(-46),%a2@(-8)
rsrc_DRVR_4__Sony_358_16E:/* count; enough? */
    addqw #1,%a0@
    subqw #1,%d2
    jble rsrc_DRVR_4__Sony_358_17A
rsrc_DRVR_4__Sony_358_174:/* next format */
    addqw #1,%d3
    tstw %d0
    jbne rsrc_DRVR_4__Sony_358_14E
rsrc_DRVR_4__Sony_358_17A:/* noErr */
    moveq #0,%d0
    jbra rsrc_DRVR_4__Sony_358_124
    bsrs rsrc_DRVR_4__Sony_506
    addql #4,%a2
    addql #4,%a3
    movew %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a3@+,%a0@+
    movel %a3@+,%a0@+
    movel %a3@+,%a0@+
    movel %a2@+,%a0@+
    bras rsrc_DRVR_4__Sony_358_124
    bsrs rsrc_DRVR_4__Sony_506
    movel %a2@(18),%a0@
    bras rsrc_DRVR_4__Sony_358_124
    movew %a1@(-68),%a0@(28)
    braw rsrc_DRVR_4__Sony_358_28
    moveb %a1@(-66),%a0@(28)
    braw rsrc_DRVR_4__Sony_358_28

/* rsrc_DRVR_4__Sony_506: IOP variant: a2 = the reply message */
rsrc_DRVR_4__Sony_506:  /* a2 = the reply message */
    lea %a1@(-72),%a2

/* rsrc_DRVR_4__Sony_50A: IOP variant: copy a reply's drive status into the drive queue element (disk in place, format), return the parameter block */
rsrc_DRVR_4__Sony_50A:
    moveq #0,%d1
    moveb %a2@(1),%d1
    lea %pc@(rsrc_DRVR_4__Sony_570),%a3
    movel %a1@(0x0,%d1:w:4),%d2
    jbeq rsrc_DRVR_4__Sony_50A_2E
    moveal %d2,%a3
    movel %a2@(6),%a3@
    movel %a2@(10),%a3@(16)
    cmpiw #1,%a3@(8)
    jbne rsrc_DRVR_4__Sony_50A_2E
    movel %a2@(26),%d3
    swap %d3
    movel %d3,%a3@(16)
rsrc_DRVR_4__Sony_50A_2E:/* return the parameter block's csParam */
    moveal %a1@(-4),%a0
    moveal %a0@(8),%a0
    lea %a0@(28),%a0
    moveq #0,%d0
    rts
rsrc_DRVR_4__Sony_548:  /* (data) */
    .long   0x00009835, 0x40000000	| 4086C928
    .long   0x00000320, 0x810A0050, 0x00000640, 0x820A0050	| 4086C930
    .long   0x000005A0, 0x82090050, 0x00000B40, 0x92120050	| 4086C940
rsrc_DRVR_4__Sony_570:  /* (data) */
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4086C950
    .long   0x00000000	| 4086C960

/* rsrc_DRVR_4__Sony_584: IOP variant: send the message at a1-40 (IOPMsgRequest), keeping the return address for the completion routine; also the IOP completion handlers (590, 5A6: disk inserted: PostEvent diskEvt, mount) */
rsrc_DRVR_4__Sony_584:  /* send the message at a1-40 to the IOP, the completion routine saved at a1-76 */
    movel %sp@+,%a1@(-76)
    lea %a1@(-40),%a0
    _IOPMsgRequest
    rts
rsrc_DRVR_4__Sony_590:  /* IOP completion: resume the waiting routine */
    lea %a0@(40),%a1	| 4086C970
    movel %a1@(-76),%sp@-	| 4086C974
    clrl %a1@(-76)	| 4086C978
    moveal %a1@(-4),%a2	| 4086C97C
    moveal %a2@(8),%a0	| 4086C980
    rts	| 4086C984
rsrc_DRVR_4__Sony_5A6:  /* IOP event: disk inserted/ejected for a drive */
    lea %a0@(100),%a1	| 4086C986
    lea %a1@(-132),%a2	| 4086C98A
    clrw %a2@(2)	| 4086C98E
    moveb %a2@,%d2	| 4086C992
    jbsr rsrc_DRVR_4__Sony_55A2	| 4086C994
    jbeq rsrc_DRVR_4__Sony_5C4	| 4086C998
    nop	| 4086C99A
    moveq #-1,%d0	| 4086C99C
    cmpib #2,%d2	| 4086C99E
    jbne rsrc_DRVR_4__Sony_5D6	| 4086C9A2
rsrc_DRVR_4__Sony_5C4:  /* PostEvent diskEvt (7) for the drive */
    moveaw #7,%a0	| 4086C9A4
    clrw %d0	| 4086C9A8
    moveb %a2@(1),%d0	| 4086C9AA
    _PostEvent	| 4086C9AE 4086C9AE A-line trap
    movew %d0,%a2@(2)	| 4086C9B0
    jbne rsrc_DRVR_4__Sony_5DA	| 4086C9B4
rsrc_DRVR_4__Sony_5D6:  /* copy the drive status */
    jbsr rsrc_DRVR_4__Sony_50A	| 4086C9B6
rsrc_DRVR_4__Sony_5DA:  /* acknowledge the event */
    lea %a1@(-100),%a0	| 4086C9BA
    moveb #1,%a0@(7)	| 4086C9BE
    _IOPMsgRequest	| 4086C9C4 4086C9C4 A-line trap
    rts	| 4086C9C6
    FILL_4086C9C8
rsrc_DRVR_4__Sony_5FC:  /* closErr (-24): the driver stays open */
    moveq #-24,%d0
    rts
rsrc_DRVR_4__Sony_600:  /* (data) */
    .long   0x0E0E04B8, 0x17AA189A, 0x1AFE0AD8, 0x17640C08	| 4086C9E0
    .long   0x01DE0B90, 0x07580E00, 0x0A2C0180, 0x1C480D40	| 4086C9F0
    .short  0x3422, 0x39EE, 0x242E, 0x24F0, 0x25C6	| 4086CA00
rsrc_DRVR_4__Sony_62A:  /* (data) */
    .short  0x0800, 0x0200, 0x4000	| 4086CA0A
    .long   0x08000000, 0x03E805DC, 0x0FA00005, 0x00780064	| 4086CA10
    .short  0x001E, 0x1D4C, 0x0000, 0x3840, 0xFC00	| 4086CA20

/* rsrc_DRVR_4__Sony_64A: copy a table of 16-bit routine offsets (a0) as absolute addresses into the vectors at a1; 64A_E is the SWIM (non-IOP) Open: SonyVars (824 bytes), the DiskVars vectors (JFigTrkSpd.., JDiskSel.., 0x680..), the default format table, a VBL task for disk polling, Time Manager task, drive probing */
rsrc_DRVR_4__Sony_64A:  /* copy a table of routine offsets into vectors (d1 + 1 entries) */
    moveq #0,%d2
    movew %a0@+,%d2
    addl %d0,%d2
    movel %d2,%a1@+
    dbf %d1,rsrc_DRVR_4__Sony_64A
    rts
rsrc_DRVR_4__Sony_64A_E:/* Open (no SWIM IOP, the Quadra 800 path): SonyVars, vectors, VBL and Time Manager tasks, drive probing */
    movel #824,%d0
    .short  0xA71E	| 4086CA3E _NewPtr (flags 0x0700)
    movel %a0,SonyVars
    movel %a1,%a0@
    moveal UTableBase,%a2
    movel %a2@(16),%a2@(4)
    moveb #2,%a1@(7)
    jbsr rsrc_DRVR_4__Sony_46F4
    jbsr rsrc_DRVR_4__Sony_1CCA
    movel %a2,%a0@(308)
    moveal %a0,%a2
    lea %pc@(rsrc_DRVR_4__Sony_600),%a0
    lea DiskVars_JFigTrkSpd,%a1
    moveq #14,%d1
    movel %a0,%d0
    jbsr rsrc_DRVR_4__Sony_64A
    lea JDiskSel,%a1
    moveq #2,%d1
    jbsr rsrc_DRVR_4__Sony_64A
    moveq #2,%d1
    lea 0x680,%a1
    jbsr rsrc_DRVR_4__Sony_64A
    st %a2@(24)
    lea %a2@(42),%a1
    lea %pc@(rsrc_DRVR_4__Sony_62A),%a0
    moveq #32,%d0
    _BlockMove
    lea %a2@(4),%a0
    movew #1,%a0@(4)
    lea %pc@(rsrc_DRVR_4__Sony_1412_8),%a1
    movel %a1,%a0@(6)
    movew #30,%a0@(10)
    _VInstall
    jbsr rsrc_DRVR_4__Sony_4702
    nop
    jbsr rsrc_DRVR_4__Sony_26A6

/* rsrc_DRVR_4__Sony_6D6: Open, continued: probe drives 1..4 (internal, external, and the extra SuperDrive positions): drive present? double sided? SuperDrive (MFM capable)? install a drive queue element (AddDrive) for each */
rsrc_DRVR_4__Sony_6D6:  /* probe the drives: the external one first (SEL line), then 1..4 */
    movew #5,%a1@(18)
    jbsr rsrc_DRVR_4__Sony_1336
    jbsr rsrc_DRVR_4__Sony_10B2
    spl %a1@(252)
    moveq #1,%d2
    movel %d2,%d5
rsrc_DRVR_4__Sony_6D6_16:/* each drive: installed? skip */
    movew %d2,%a1@(18)
    jbsr rsrc_DRVR_4__Sony_4748
    jbgt rsrc_DRVR_4__Sony_6D6_9A
    nop
    cmpiw #3,%d2
    jble rsrc_DRVR_4__Sony_6D6_30
    tstb %a1@(252)
    bmiw rsrc_DRVR_4__Sony_6D6_9A
rsrc_DRVR_4__Sony_6D6_30:/* select it; drives 3 and 4 only with the external option (a1+252) */
    jbsr rsrc_DRVR_4__Sony_1336
    cmpiw #3,%d2
    jblt rsrc_DRVR_4__Sony_6D6_4E
    movew %a1@(18),%d5
    jbsr rsrc_DRVR_4__Sony_10B2
    jbmi rsrc_DRVR_4__Sony_6D6_9A
    movew #1,%a1@(0xa,%d1:w)
    moveq #-2,%d3
    jbra rsrc_DRVR_4__Sony_6D6_86
rsrc_DRVR_4__Sony_6D6_4E:/* floppy present (register 13)? sides (9), SuperDrive (15), MFM capable (5) */
    moveq #13,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbmi rsrc_DRVR_4__Sony_6D6_9A
    moveq #9,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    smi %a1@(0x5,%d1:w)
    moveq #15,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    smi %a1@(0x13,%d1:w)
    moveq #5,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbpl rsrc_DRVR_4__Sony_6D6_84
    st %a1@(0x13,%d1:w)
    tstb %a1@(312)
    jbpl rsrc_DRVR_4__Sony_6D6_84
    st %a1@(0x16,%d1:w)
    st %a1@(253)
rsrc_DRVR_4__Sony_6D6_84:/* a floppy: -5 */
    moveq #-5,%d3
rsrc_DRVR_4__Sony_6D6_86:/* AddDrive with drive number and the type */
    movew %d2,%d0
    moveb #1,%a1@(0x4,%d1:w)
    swap %d0
    movew %d3,%d0
    lea %a1@(0x6,%d1:w),%a0
    _AddDrive
    addqw #1,%d5
rsrc_DRVR_4__Sony_6D6_9A:/* next drive; power down; noErr */
    addqw #1,%d2
    cmpiw #4,%d2
    jble rsrc_DRVR_4__Sony_6D6_16
    jbsr rsrc_DRVR_4__Sony_4742
    moveq #0,%d0
    rts
rsrc_DRVR_4__Sony_6D6_AC:/* controlErr */
    moveq #-17,%d0

rsrc_DRVR_4__Sony_784:  /* finish the request (IODone through S_4758) */
    tstw %d0
    jbra rsrc_DRVR_4__Sony_4758
    .short  0x4E71, 0x4E71	| 4086CB6A
SONY_CONTROL_TABLE:  /* csCode, handler, handler for drive type >= 3 (offsets from the table) */
    .short  1, SONY_CTL_KillIO-SONY_CONTROL_TABLE, SONY_CTL_KillIO-SONY_CONTROL_TABLE
    .short  5, SONY_CTL_Verify-SONY_CONTROL_TABLE, SONY_CTL_Verify_type3-SONY_CONTROL_TABLE
    .short  6, SONY_CTL_Format-SONY_CONTROL_TABLE, SONY_CTL_Format_type3-SONY_CONTROL_TABLE
    .short  7, SONY_CTL_Eject-SONY_CONTROL_TABLE, SONY_CTL_Eject_type3-SONY_CONTROL_TABLE
    .short  8, SONY_CTL_SetTagBuffer-SONY_CONTROL_TABLE, SONY_CTL_SetTagBuffer-SONY_CONTROL_TABLE
    .short  9, SONY_CTL_TrackCache-SONY_CONTROL_TABLE, SONY_CTL_TrackCache-SONY_CONTROL_TABLE
    .short  21, SONY_CTL_GetDriveIcon-SONY_CONTROL_TABLE, SONY_CTL_GetDriveIcon_type3-SONY_CONTROL_TABLE
    .short  22, SONY_CTL_GetMediaIcon-SONY_CONTROL_TABLE, SONY_CTL_GetDriveIcon_type3-SONY_CONTROL_TABLE
    .short  23, SONY_CTL_GetDriveInfo-SONY_CONTROL_TABLE, SONY_CTL_GetDriveInfo-SONY_CONTROL_TABLE
    .short  21315, SONY_CTL_csSC-SONY_CONTROL_TABLE, SONY_CTL_KillIO-SONY_CONTROL_TABLE  /* 'SC' */
    .short  18244, SONY_CTL_csGD-SONY_CONTROL_TABLE, SONY_CTL_KillIO-SONY_CONTROL_TABLE  /* 'GD' */
    .short  17232, SONY_CTL_csCP-SONY_CONTROL_TABLE, SONY_CTL_KillIO-SONY_CONTROL_TABLE  /* 'CP' */
    .short  0  | end
    movel DiskVars_JControl,%sp@-
    rts
    jbsr rsrc_DRVR_4__Sony_A88
    jbne rsrc_DRVR_4__Sony_7EC
    tstb %a1@(0x4,%d1:w)
    jbpl rsrc_DRVR_4__Sony_7EC
    moveq #-64,%d0
rsrc_DRVR_4__Sony_7EC:  /* Control: find csCode in SONY_CONTROL_TABLE (no disk needed for some) */
    lea %pc@(SONY_CONTROL_TABLE),%a3
    moveal %a3,%a4
rsrc_DRVR_4__Sony_7F2:  /* next entry: matches? drive numbers 3 and up (HD20) use the second handler */
    movew %a3@+,%d2
    jbeq rsrc_DRVR_4__Sony_810
    cmpw %a0@(26),%d2
    jbne rsrc_DRVR_4__Sony_80C
    cmpiw #3,%a1@(18)
    jblt rsrc_DRVR_4__Sony_806
    addqw #2,%a3
rsrc_DRVR_4__Sony_806:  /* call the handler */
    addaw %a3@,%a4
    tstw %d0
    jmp %a4@
rsrc_DRVR_4__Sony_80C:  /* next entry */
    addqw #4,%a3
    jbra rsrc_DRVR_4__Sony_7F2
rsrc_DRVR_4__Sony_810:  /* not found: controlErr (-17) */
    moveq #-17,%d0
    jbra rsrc_DRVR_4__Sony_784

/* Control 1, KillIO: stop the current request. */
SONY_CTL_KillIO:
    moveq #-1,%d0	| 4086CBF6
    jbra rsrc_DRVR_4__Sony_784	| 4086CBF8

/* Control 6, format the disk. */
SONY_CTL_Format:
    jbne rsrc_DRVR_4__Sony_784	| 4086CBFC

thunk_FUN_4086e684:     /* Control format (csCode 6) */
    jbra rsrc_DRVR_4__Sony_22A4

/* Control 5, verify a formatted disk. */
SONY_CTL_Verify:
    jbne rsrc_DRVR_4__Sony_784	| 4086CC04
    jbra rsrc_DRVR_4__Sony_2584	| 4086CC08

/* Control 8, set the buffer for the sector tags. */
SONY_CTL_SetTagBuffer:
    movel %a0@(28),%a1@(244)	| 4086CC0C
    moveq #0,%d0	| 4086CC12
    jbra rsrc_DRVR_4__Sony_784	| 4086CC14

/* Control 9, turn the track cache on or off. */
SONY_CTL_TrackCache:
    lea %a0@(28),%a0
    moveb %a0@+,%d1
    moveb %a0@+,%d0
    jbeq SONY_CTL_TrackCache_3C
    jbpl SONY_CTL_TrackCache_10
    jbsr rsrc_DRVR_4__Sony_88A
    jbra SONY_CTL_TrackCache_3C
SONY_CTL_TrackCache_10: /* turn it on: allocate the cache (6288 bytes, 9432 for 1.4 MB) if there is room */
    tstl %a1@(266)
    jbne SONY_CTL_TrackCache_3C
    cmpiw #2,MemTop
    nop
    movel #6288,%d0
    tstb %a1@(253)
    nop
    movel #9432,%d0
    .short  0xA71E	| 4086CC48 _NewPtr (flags 0x0700)
    jbne SONY_CTL_TrackCache_3C
    movel %a0,%a1@(266)
    clrw %a1@(258)
SONY_CTL_TrackCache_3C: /* cache on if allocated */
    tstl %a1@(266)
    sne %a1@(257)
    jbeq SONY_CTL_TrackCache_4C
    tstb %d1
    sne %a1@(257)
SONY_CTL_TrackCache_4C: /* noErr */
    moveq #0,%d0
    jbra rsrc_DRVR_4__Sony_784

/* rsrc_DRVR_4__Sony_88A: free the track cache buffer (a1+266) and turn the cache off; returns its size */
rsrc_DRVR_4__Sony_88A:
    clrl %sp@-
    movel %a1@(266),%d0
    jbeq rsrc_DRVR_4__Sony_88A_18
    moveal %d0,%a0
    _GetPtrSize
    movel %d0,%sp@
    _DisposPtr
    clrl %a1@(266)
    clrb %a1@(257)
rsrc_DRVR_4__Sony_88A_18:/* return the size freed */
    movel %sp@+,%d0
    rts

/* Control 7, eject the disk. */
SONY_CTL_Eject:
    jbne rsrc_DRVR_4__Sony_784	| 4086CC86
    jbsr rsrc_DRVR_4__Sony_476E	| 4086CC8A
    jble rsrc_DRVR_4__Sony_8CA	| 4086CC8E
    jbsr rsrc_DRVR_4__Sony_12E0
    moveq #40,%d6
    jbsr rsrc_DRVR_4__Sony_10CE
    jbgt rsrc_DRVR_4__Sony_8CA
    jbeq rsrc_DRVR_4__Sony_8C4
    jbsr rsrc_DRVR_4__Sony_1202
    jbmi rsrc_DRVR_4__Sony_8CA
rsrc_DRVR_4__Sony_8C4:  /* seek to the last track (79) first */
    moveq #79,%d6
    jbsr rsrc_DRVR_4__Sony_10CE
rsrc_DRVR_4__Sony_8CA:  /* forget the cache; motor off timer; still a disk? eject */
    jbsr rsrc_DRVR_4__Sony_12CC
    moveq #0,%d0
    jbsr rsrc_DRVR_4__Sony_12A8
    jbsr rsrc_DRVR_4__Sony_1336
    moveq #2,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbpl rsrc_DRVR_4__Sony_8E8
    moveq #0,%d0
    jbsr rsrc_DRVR_4__Sony_12A8
    jbra rsrc_DRVR_4__Sony_956
rsrc_DRVR_4__Sony_8E8:  /* 2 ms wait; eject command (register 13): ISM or IWM */
    movew #2000,%d0
    jbsr rsrc_DRVR_4__Sony_118A
    moveq #13,%d0
    jbsr rsrc_DRVR_4__Sony_102C
    tstb %a1@(313)
    jbpl rsrc_DRVR_4__Sony_904
    moveb #0xff,%a0@(2048)
    jbra rsrc_DRVR_4__Sony_908
rsrc_DRVR_4__Sony_904:  /* IWM: strobe */
    tstb %a0@(3584)
rsrc_DRVR_4__Sony_908:  /* wait for the eject (longer on 400K drives) */
    tstb %a1@(0x13,%d1:w)
    jbmi rsrc_DRVR_4__Sony_92A
    movew %a1@(66),%d0
    jbsr rsrc_DRVR_4__Sony_118A
    tstb %a1@(313)
    jbpl rsrc_DRVR_4__Sony_924
    moveb #0xf7,%a0@(2048)
    jbra rsrc_DRVR_4__Sony_956
rsrc_DRVR_4__Sony_924:  /* strobe off */
    tstb %a0@(3072)
    jbra rsrc_DRVR_4__Sony_956
rsrc_DRVR_4__Sony_92A:  /* SuperDrive */
    tstb %a1@(313)
    jbpl rsrc_DRVR_4__Sony_938
    moveb #0xf7,%a0@(2048)
    jbra rsrc_DRVR_4__Sony_93C
rsrc_DRVR_4__Sony_938:  /* IWM */
    tstb %a0@(3072)
rsrc_DRVR_4__Sony_93C:  /* wait up to 15 times for the disk to leave */
    moveq #15,%d3
rsrc_DRVR_4__Sony_93E:  /* 1 ms waits */
    movew #1000,%d0
    jbsr rsrc_DRVR_4__Sony_118A
    moveq #2,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    dbmi %d3,rsrc_DRVR_4__Sony_93E
    moveq #10,%d0
    jbsr rsrc_DRVR_4__Sony_118A
rsrc_DRVR_4__Sony_956:  /* the drive's "disk in place" state reset; noErr */
    moveb %a1@(72),%a1@(0x3,%d1:w)
    moveq #0,%d0
    jbra rsrc_DRVR_4__Sony_784
SONY_CTL_Format_type3:  /* Control format, HD20 (drive numbers 3+): command 25 */
    jbne rsrc_DRVR_4__Sony_784	| 4086CD42
    jbra rsrc_DRVR_4__Sony_407A	| 4086CD46
SONY_CTL_Verify_type3:  /* Control verify, HD20: command 26 */
    jbne rsrc_DRVR_4__Sony_784	| 4086CD4A
    jbra rsrc_DRVR_4__Sony_4076	| 4086CD4E
SONY_CTL_Eject_type3:   /* Control eject, HD20: clear the disk-in-place state */
    jbne rsrc_DRVR_4__Sony_784	| 4086CD52
    jbra SONY_CTL_csCP_16	| 4086CD56
    .byte   0x4E, 0x71	| 4086CD5A
SONY_STATUS_TABLE:  /* csCode, handler (offsets from the table) */
    .short  6, SONY_STS_FormatList-SONY_STATUS_TABLE
    .short  8, SONY_STS_DriveStatus-SONY_STATUS_TABLE
    .short  10, SONY_STS_cs10-SONY_STATUS_TABLE
    .short  17494, SONY_STS_csDV-SONY_STATUS_TABLE  /* 'DV' */
    .short  21315, SONY_STS_csSC-SONY_STATUS_TABLE  /* 'SC' */
    .short  17232, SONY_STS_csCP-SONY_STATUS_TABLE  /* 'CP' */
    .short  0  | end
rsrc_DRVR_4__Sony_996:  /* Status: find csCode in SONY_STATUS_TABLE */
    moveq #-18,%d0
    lea %pc@(SONY_STATUS_TABLE),%a3
    moveal %a3,%a4
    jbra rsrc_DRVR_4__Sony_9A2
rsrc_DRVR_4__Sony_9A0:  /* next entry */
    addqw #2,%a3
rsrc_DRVR_4__Sony_9A2:  /* matches? the drive must exist; call it with csParam */
    movew %a3@+,%d2
    jbeq rsrc_DRVR_4__Sony_9C0
    cmpw %a0@(26),%d2
    jbne rsrc_DRVR_4__Sony_9A0
    jbsr rsrc_DRVR_4__Sony_A88
    jbne rsrc_DRVR_4__Sony_9C0
    moveq #-64,%d0
    tstb %a1@(0x4,%d1:w)
    lea %a0@(28),%a0
    addaw %a3@,%a4
    jsr %a4@
rsrc_DRVR_4__Sony_9C0:  /* finish */
    jbra rsrc_DRVR_4__Sony_784

/* Status 8, drive status (track, write protect, disk in place, sides...). */
SONY_STS_DriveStatus:
    moveq #11,%d0	| 4086CDA4
    addaw %d1,%a1	| 4086CDA6
SONY_STS_DriveStatus_4: /* copy the drive's 22 status bytes */
    movew %a1@+,%a0@+	| 4086CDA8
    subqw #1,%d0	| 4086CDAA
    jbgt SONY_STS_DriveStatus_4	| 4086CDAC
    rts	| 4086CDAE

/* Status 6, the list of formats the disk can have. */
SONY_STS_FormatList:
    jble SONY_STS_FormatList_10
    moveq #-65,%d0
    cmpib #2,%a1@(0x3,%d1:w)
    jblt SONY_STS_FormatList_10
    moveq #-50,%d0
    movew %a0@,%d2
SONY_STS_FormatList_10: /* the formats: the MFM drive's own list, or 400K/800K/1.4M by the drive type */
    jble SONY_STS_FormatList_88
    cmpiw #3,%a1@(18)
    jblt SONY_STS_FormatList_30
    movel %a1@(0x12,%d1:w),%d0
    swap %d0
    movew #1,%a0@+
    moveal %a0@,%a0
    movel %d0,%a0@+
    movel #1073741824,%a0@+
    jbra SONY_STS_FormatList_86
SONY_STS_FormatList_30: /* GCR formats; double sided? MFM? */
    lea %pc@(rsrc_DRVR_4__Sony_A5A),%a2
    moveq #1,%d3
    moveq #0,%d0
    tstb %a1@(0x5,%d1:w)
    jbpl SONY_STS_FormatList_64
    moveb %a1@(0x12,%d1:w),%d0
    negb %d0
    moveq #2,%d3
    tstb %a1@(0x16,%d1:w)
    jbpl SONY_STS_FormatList_64
    moveq #3,%d3
    tstb %a1@(0x17,%d1:w)
    jbpl SONY_STS_FormatList_64
    moveq #2,%d0
    tstb %a1@(0x18,%d1:w)
    jbpl SONY_STS_FormatList_64
    lea %pc@(rsrc_DRVR_4__Sony_A72),%a2
    moveq #0,%d0
    moveq #1,%d3
SONY_STS_FormatList_64: /* at most the requested count */
    cmpw %d3,%d2
    jble SONY_STS_FormatList_6A
    movew %d3,%d2
SONY_STS_FormatList_6A: /* the count */
    movew %d2,%a0@+
    subqw #1,%d2
    movew %d2,%d3
    subw %d0,%d3
    moveal %a0@,%a0
SONY_STS_FormatList_74: /* each format: size and flags; the current one marked (bit 30) */
    movel %a2@+,%a0@+
    movel %a2@+,%d0
    cmpw %d2,%d3
    jbne SONY_STS_FormatList_80
    bset #30,%d0
SONY_STS_FormatList_80: /* store */
    movel %d0,%a0@+
    dbf %d2,SONY_STS_FormatList_74
SONY_STS_FormatList_86: /* noErr */
    moveq #0,%d0
SONY_STS_FormatList_88:  /* return */
    rts
rsrc_DRVR_4__Sony_A5A:  /* (data) */
    .byte   0x00, 0x00, 0x03, 0x20, 0x81, 0x0A, 0x00, 0x50, 0x00, 0x00, 0x06, 0x40, 0x82, 0x0A, 0x00, 0x50	| 4086CE3A
    .byte   0x00, 0x00, 0x05, 0xA0, 0x82, 0x09, 0x00, 0x50	| 4086CE4A
rsrc_DRVR_4__Sony_A72:  /* (4086CE52 orib #64,%d0) */
    .short  0x0000, 0x0B40	| 4086CE52 orib #64,%d0
    subb %a2@,%d1	| 4086CE56
    .byte   0x00, 0x50	| 4086CE58
SONY_STS_cs10:          /* (4086CE5A movel %a1@(16,%d1:w),%d0) */
    .short  0x2031, 0x1016	/* 4086CE5A movel %a1@(16,%d1:w),%d0 */
    moveb %a1@(312),%d0	| 4086CE5E
    movel %d0,%a0@	| 4086CE62
    moveq #0,%d0	| 4086CE64
    rts	| 4086CE66

/* rsrc_DRVR_4__Sony_A88: Prime entry for the SWIM: SonyVars, check the drive number (1..4: else nsDrvErr -56), select the drive and go; also the common error exits (offLinErr, paramErr, noNybErr) that deselect and finish through S_784 */
rsrc_DRVR_4__Sony_A88:  /* Prime/Control/Status common entry: SonyVars, busy, the drive number (1..4) selected */
    moveal SonyVars,%a1
    st %a1@(25)
    movew %a0@(22),%d0
    jbeq rsrc_DRVR_4__Sony_A88_26
    cmpiw #4,%d0
    jbhi rsrc_DRVR_4__Sony_A88_26
    movew %a1@(18),%a1@(274)
    jbsr rsrc_DRVR_4__Sony_4678
    jbsr rsrc_DRVR_4__Sony_1010
    moveq #0,%d0
    rts
rsrc_DRVR_4__Sony_A88_26:/* nsDrvErr (-56) */
    moveq #-56,%d0
    rts
    movel DiskVars_JDiskPrime,%sp@-
    rts
    oriw #256,%sr
    movew %a0@(6),%d3
    btst #6,%a0@(45)
    sne DskVerify
    bsrs rsrc_DRVR_4__Sony_A88
    bnew rsrc_DRVR_4__Sony_B62_12
    movew %d3,%a1@(50)
    moveq #-64,%d0
    tstb %a1@(0x4,%d1:w)
    bsrw rsrc_DRVR_4__Sony_4560_36_6
    tstb %a1@(312)
    bpls rsrc_DRVR_4__Sony_A88_26_3A
    bsrw rsrc_DRVR_4__Sony_2716
rsrc_DRVR_4__Sony_A88_26_3A:/* Prime body: select the drive; HD20 drives go to their own Prime; disk in place (register 2)? else offLinErr */
    bsrw rsrc_DRVR_4__Sony_1336
    cmpiw #3,%a1@(18)
    bgew rsrc_DRVR_4__Sony_372C_100	| 4086CED2
    moveq #2,%d0
    bsrw rsrc_DRVR_4__Sony_106E
    bpls rsrc_DRVR_4__Sony_A88_26_62
    clrb %a1@(0x3,%d1:w)
    moveb #0x86,%a0@(3072)	| 4086CEE2
    tstb %a0@(4096)
    moveq #-65,%d0
    jbra rsrc_DRVR_4__Sony_B62_12
rsrc_DRVR_4__Sony_A88_26_62:/* Prime set-up continued: the disk format, write protection */
    cmpib #2,%a1@(0x3,%d1:w)
    beqs rsrc_DRVR_4__Sony_A88_26_62_3E
    clrb %a1@(0x17,%d1:w)
    tstb %a1@(312)
    bpls rsrc_DRVR_4__Sony_A88_26_62_16
    bsrw rsrc_DRVR_4__Sony_2716
rsrc_DRVR_4__Sony_A88_26_62_16:/* power up, recalibrate if needed, select; read the address (format, sides) */
    bsrw rsrc_DRVR_4__Sony_12CC_E_2
    bsrw rsrc_DRVR_4__Sony_1202
    bmis rsrc_DRVR_4__Sony_B62_6
    bsrw rsrc_DRVR_4__Sony_133A_AA_16
    bnes rsrc_DRVR_4__Sony_B62_6
    moveq #6,%d0
    bsrw rsrc_DRVR_4__Sony_106E
    spl %a1@(0x2,%d1:w)	| 4086CF1C
    clrb %a1@(0x12,%d1:w)
    moveb #2,%a1@(0x3,%d1:w)
    braw rsrc_DRVR_4__Sony_2848_30	| 4086CF2A
rsrc_DRVR_4__Sony_A88_26_62_3E:/* 800K disk? write requests: write protected? wPrErr (-44) */
    bsrw rsrc_DRVR_4__Sony_F4E
    beqs rsrc_DRVR_4__Sony_B62_12_8
    movew BufTgFBkNum,%a1@(38)
    tstb %a1@(0x2,%d1:w)
    bpls rsrc_DRVR_4__Sony_B62_12_8
    moveq #-44,%d0

rsrc_DRVR_4__Sony_B62:  /* motor-off time for the drive */
    movew %a1@(58),%d2
    jbra rsrc_DRVR_4__Sony_B62_8
rsrc_DRVR_4__Sony_B62_6:/* error: motor-off time */
    moveq #0,%d2	| 4086CF48
rsrc_DRVR_4__Sony_B62_8:/* set the motor timer */
    movew %d0,%sp@-
    movew %d2,%d0
    jbsr rsrc_DRVR_4__Sony_12A8
    movew %sp@+,%d0
rsrc_DRVR_4__Sony_B62_12:/* interrupts on; finish */
    andiw #-1793,%sr
    jbra rsrc_DRVR_4__Sony_784
rsrc_DRVR_4__Sony_B62_12_8:/* the request: block to track/side/sector, sectors this track */
    movew %a1@(0x0,%d1:w),%d6	| 4086CF5C
    bsrw rsrc_DRVR_4__Sony_12E0
rsrc_DRVR_4__Sony_B62_12_8_8:
    moveal %a1@,%a2	| 4086CF64
    moveal %a2@(8),%a0
    movel %a2@(16),%d0
    moveq #9,%d7
    lsrl %d7,%d0
    tstb %a1@(0x17,%d1:w)
    bmiw rsrc_DRVR_4__Sony_29DE+0x1a
    moveq #0,%d4
    tstb %a1@(0x12,%d1:w)
    beqs rsrc_DRVR_4__Sony_B62_12_8_28
    moveq #1,%d4
rsrc_DRVR_4__Sony_B62_12_8_28:/* d2 = blocks on the disk, 800 or 1600 two-sided; past the end: paramErr */
    moveq #100,%d2	| 4086CF84
    lslw #3,%d2
    lslw %d4,%d2
    cmpl %d2,%d0
    blts rsrc_DRVR_4__Sony_B62_4E_2
rsrc_DRVR_4__Sony_B62_12_3A:/* paramErr */
    moveq #-50,%d0
rsrc_DRVR_4__Sony_B62_4E:/* error exits */
    jbra rsrc_DRVR_4__Sony_B62
rsrc_DRVR_4__Sony_B62_4E_2:/* the zone, from the innermost outward: d3 = blocks in the zone (8 sectors per track, then 9.., 16 tracks) */
    moveq #7,%d3	| 4086CF92
    lslw #4,%d3
    lslw %d4,%d3
    moveq #16,%d5
    lslw %d4,%d5
rsrc_DRVR_4__Sony_B62_4E_C:
    addw %d5,%d3	| 4086CF9C
    subl %d3,%d2
    cmpl %d2,%d0
    blts rsrc_DRVR_4__Sony_B62_4E_C
    /* blocks per cylinder; d5 = cylinder within the zone */
    lsrw #4,%d3
    moveq #-1,%d5
rsrc_DRVR_4__Sony_B62_4E_18:
    addw %d3,%d2	| 4086CFA8
    addqw #1,%d5
    cmpw %d2,%d0
    bges rsrc_DRVR_4__Sony_B62_4E_18
    /* d3 = sectors per track; track = 16 * (12 - sectors) + d5 */
    lsrw %d4,%d3
    moveq #12,%d6
    subw %d3,%d6
    lslw #4,%d6
    addw %d6,%d5
    /* side: the upper half of the cylinder is side 1 */
    movel %d4,%d6
    subw %d3,%d2
    cmpl %d2,%d0
    bges rsrc_DRVR_4__Sony_B62_4E_36
    subw %d3,%d2
    moveq #0,%d6
rsrc_DRVR_4__Sony_B62_4E_36:/* side 1: bit 11 of the track word; on a one-sided drive twoSideErr (-78) */
    tstb %d6	| 4086CFC6
    beqs rsrc_DRVR_4__Sony_B62_4E_48
    bset #11,%d5
    tstb %a1@(0x5,%d1:w)
    bnes rsrc_DRVR_4__Sony_B62_4E_48
    moveq #-78,%d0
    jbra rsrc_DRVR_4__Sony_B62_4E
rsrc_DRVR_4__Sony_B62_4E_48:/* the track word (+22) and sector (+32); blocks still to do, none: paramErr; limited to the sectors left on this track (d6 set if more follow) */
    movew %d5,%a1@(22)	| 4086CFD8
    subw %d2,%d0
    subw %d0,%d3
    movew %d0,%a1@(32)
    movel %a0@(36),%d5
    movel %a0@(40),%d2
    subl %d2,%d5
    lsrl %d7,%d5
    beqs rsrc_DRVR_4__Sony_B62_12_3A
    cmpw %d5,%d3
    slt %d6
    bles rsrc_DRVR_4__Sony_B62_4E_6A
    movew %d5,%d3
rsrc_DRVR_4__Sony_B62_4E_6A:/* mask of the sectors to transfer (+34); buffer address (+28); blocks done (+40) */
    moveq #0,%d5	| 4086CFFA
    movew %d0,%d4
    movew %d3,%sp@-
rsrc_DRVR_4__Sony_B62_4E_70:
    bset %d0,%d5	| 4086D000
    addqw #1,%d0
    subqw #1,%d3
    bnes rsrc_DRVR_4__Sony_B62_4E_70
    movew %sp@+,%d3
    movel %d5,%a1@(34)
    moveal %a0@(32),%a3
    addal %d2,%a3
    movel %a3,%a1@(28)
    lsrl %d7,%d2
    movew %d2,%a1@(40)
    moveb %a1@(44),%a1@(45)
    clrb %a1@(256)
    bsrw rsrc_DRVR_4__Sony_F4E
    beqs rsrc_DRVR_4__Sony_B62_FA+0x4
    jbsr rsrc_DRVR_4__Sony_D32
    jbne rsrc_DRVR_4__Sony_B62_FA
    movel %d5,%d0
    notl %d0
    andl %d0,%a1@(262)
rsrc_DRVR_4__Sony_B62_FA:/* reseek */
    jbra rsrc_DRVR_4__Sony_D52
    tstb DskVerify
    bnes rsrc_DRVR_4__Sony_B62_FA
    bsrw rsrc_DRVR_4__Sony_D32
    bnew rsrc_DRVR_4__Sony_B62_FA_A6
    movel %d5,%d2
    andl %a1@(262),%d2
    beqw rsrc_DRVR_4__Sony_B62_FA_A2
    moveq #2,%d7
    asll #8,%d7
    movew %d4,%d0
    tstb %a1@(0x17,%d1:w)
    bpls rsrc_DRVR_4__Sony_B62_FA_2A
    subqw #1,%d0
rsrc_DRVR_4__Sony_B62_FA_2A:/* read from the track cache: this sector's slot (524 bytes: 12 tags + 512 data) */
    muluw #524,%d0
    moveal %a1@(266),%a4
    addaw %d0,%a4
rsrc_DRVR_4__Sony_B62_FA_34:/* each sector wanted and in the cache: copy it out */
    btst %d4,%d2
    beqs rsrc_DRVR_4__Sony_B62_FA_7C
    bclr %d4,%d5
    moveml %a0-%a1,%sp@-
    tstl %a1@(244)
    beqs rsrc_DRVR_4__Sony_B62_FA_5A
    movew %d4,%d0
    subw %a1@(32),%d0
    addw %a1@(40),%d0
    muluw #12,%d0
    moveal %a1@(244),%a1
    addal %d0,%a1
    bras rsrc_DRVR_4__Sony_B62_FA_5E
rsrc_DRVR_4__Sony_B62_FA_5A:/* the tags into the tag buffer */
    lea BufTgFNum,%a1
rsrc_DRVR_4__Sony_B62_FA_5E:/* tags, then the data (BlockMove); count it */
    moveal %a4,%a0
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %a3,%a1
    movel %d7,%d0
    _BlockMove
    moveml %sp@+,%a0-%a1
    addqw #1,%a1@(272)
    addl %d7,%a2@(16)
    addl %d7,%a0@(40)
rsrc_DRVR_4__Sony_B62_FA_7C:/* next sector; all done? finish, else read the rest from the disk */
    addal %d7,%a3
    addal %d7,%a4
    lea %a4@(12),%a4
    addqw #1,%d4
    subqw #1,%d3
    bnes rsrc_DRVR_4__Sony_B62_FA_34
    movel %d5,%a1@(34)
    bnes rsrc_DRVR_4__Sony_B62_FA_A2
    movel %a0@(40),%d0
    cmpl %a0@(36),%d0
    bltw rsrc_DRVR_4__Sony_B62_12_8_8	| 4086D0D4
    moveq #0,%d0
    braw rsrc_DRVR_4__Sony_B62
rsrc_DRVR_4__Sony_B62_FA_A2:/* cache use for this request; reseek */
    bsrs rsrc_DRVR_4__Sony_D18
    bras rsrc_DRVR_4__Sony_D52
rsrc_DRVR_4__Sony_B62_FA_A6:/* claim the cache for this track */
    jbsr rsrc_DRVR_4__Sony_D18
    jbne rsrc_DRVR_4__Sony_D52
    movew %a1@(18),%a1@(258)
    movew %a1@(22),%a1@(260)
    clrl %a1@(262)
    jbra rsrc_DRVR_4__Sony_D52

/* rsrc_DRVR_4__Sony_D18: track cache: will this request use it? (cache on, not a verify, d6 = 1 for the first pass) */
rsrc_DRVR_4__Sony_D18:  /* track cache in use for this read? */
    tstb %a1@(257)
    jbeq rsrc_DRVR_4__Sony_D18_16
    btst #10,%a1@(50)
    jbne rsrc_DRVR_4__Sony_D18_10
    tstb %d6
rsrc_DRVR_4__Sony_D18_10:/* set the flag */
    seq %a1@(256)
    rts
rsrc_DRVR_4__Sony_D18_16:/* no cache */
    moveq #1,%d6
    jbra rsrc_DRVR_4__Sony_D18_10

/* rsrc_DRVR_4__Sony_D32: track cache: does the cache hold the current track of this drive and side? d0 = 0 if so, -1 otherwise; D52 seeks again through JReSeek */
rsrc_DRVR_4__Sony_D32:  /* is the current track in the cache? */
    tstb %a1@(257)
    jbeq rsrc_DRVR_4__Sony_D32_1C
    movew %a1@(258),%d0
    jbeq rsrc_DRVR_4__Sony_D32_1C
    cmpw %a1@(18),%d0
    jbne rsrc_DRVR_4__Sony_D32_1C
    movew %a1@(22),%d0
    subw %a1@(260),%d0
    jbeq rsrc_DRVR_4__Sony_D32_1E
rsrc_DRVR_4__Sony_D32_1C:/* no */
    moveq #-1,%d0
rsrc_DRVR_4__Sony_D32_1E:  /* return */
    rts

rsrc_DRVR_4__Sony_D52:  /* ReSeek through JReSeek */
    movel DiskVars_JReSeek,%sp@-
    rts
    moveb %a1@(48),%a1@(49)
    movew %a1@(22),%d6
    bsrw rsrc_DRVR_4__Sony_10CE
    bmis rsrc_DRVR_4__Sony_D52_1E
    moveb %a1@(42),%a1@(43)
    bras rsrc_DRVR_4__Sony_D52_22
rsrc_DRVR_4__Sony_D52_1E:/* (ReSeek) give up */
    braw rsrc_DRVR_4__Sony_F56_24_5A
rsrc_DRVR_4__Sony_D52_22:/* (read path) next track: seek, set up */
    moveb %a1@(46),%a1@(47)
rsrc_DRVR_4__Sony_D52_28:/* read an address field: the right track? note the sector and format */
    movew %d1,%d6
    bsrw rsrc_DRVR_4__Sony_1D80
    bmiw rsrc_DRVR_4__Sony_F56_24_A
    cmpw %a1@(22),%d1
    bnew rsrc_DRVR_4__Sony_F56_24_56
    moveb %d3,%a1@(332)
    movew %d2,%a1@(254)
    movew %d2,TagData
    movel %a1@(34),%d0
    btst %d2,%d0
    bnew rsrc_DRVR_4__Sony_D52_FA
    tstb %a1@(256)
    beqw rsrc_DRVR_4__Sony_F56_24_2C
    movel %a1@(262),%d0
    btst %d2,%d0
    bnew rsrc_DRVR_4__Sony_F56_24_2C
    bsrw rsrc_DRVR_4__Sony_4560_36_6_8
    cmpal DiskVars_JRdData,%a0
    sne %a1@(256)
    bnew rsrc_DRVR_4__Sony_F56_24_2C
    movew %d2,%d1
    tstb %a1@(0x17,%d6:w)
    bpls rsrc_DRVR_4__Sony_D52_7C
    subqw #1,%d2
rsrc_DRVR_4__Sony_D52_7C:/* track cache: read the sector into its slot */
    muluw #524,%d2
    moveal %a1@(266),%a0
    addal %d2,%a0
    lea %a0@(12),%a0
    bsrw rsrc_DRVR_4__Sony_1E84
    bsrw rsrc_DRVR_4__Sony_1010
    movew %d1,%d6
    tstw %d0
    spl %a1@(256)	| 4086D1C8
    bmis rsrc_DRVR_4__Sony_D52_CC
    addqw #1,%a1@(270)
    movew %a1@(254),%d2
    moveal %a1@(266),%a0
    movew %d2,%d1
    tstb %a1@(0x17,%d6:w)
    bpls rsrc_DRVR_4__Sony_D52_B2
    subqw #1,%d1
rsrc_DRVR_4__Sony_D52_B2:/* copy the tags into the slot; mark the sector cached */
    muluw #524,%d1
    addal %d1,%a0
    lea BufTgFNum,%a2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a1@(262),%d4
    bset %d2,%d4
    movel %d4,%a1@(262)
rsrc_DRVR_4__Sony_D52_CC:/* interrupts: give the system a turn between sectors (or wait) */
    bset #7,IntFlag
    bnes rsrc_DRVR_4__Sony_D52_EE
    movew %a1@(62),%d0
    tstb %a1@(0x17,%d6:w)
    bpls rsrc_DRVR_4__Sony_D52_E0
    moveq #75,%d0
rsrc_DRVR_4__Sony_D52_E0:/* sleep briefly */
    bsrw rsrc_DRVR_4__Sony_118A_26
    bsrw rsrc_DRVR_4__Sony_F56
    bsrw rsrc_DRVR_4__Sony_118A_14
    bras rsrc_DRVR_4__Sony_D52_F6
rsrc_DRVR_4__Sony_D52_EE:/* poll */
    bsrw rsrc_DRVR_4__Sony_F56
    andiw #-1793,%sr
rsrc_DRVR_4__Sony_D52_F6:/* next */
    braw rsrc_DRVR_4__Sony_D52_22
rsrc_DRVR_4__Sony_D52_FA:/* a wanted sector: its buffer address and position */
    cmpib #31,%d3
    sgt %a1@(0x12,%d6:w)
    subw %a1@(32),%d2
    movew %d2,%d1
    asll #8,%d1
    addl %d1,%d1
    addl %a1@(28),%d1
    moveal %d1,%a0
    movew %a1@(40),%d1
    addw %d2,%d1
    movew %d1,%d0
    addw %d1,%d1
    addw %d0,%d1
    aslw #2,%d1
    movew %d1,%a1@(248)
    bsrw rsrc_DRVR_4__Sony_F4E
    beqs rsrc_DRVR_4__Sony_D52_152
    movel %a1@(244),%d3
    beqs rsrc_DRVR_4__Sony_D52_140
    moveal %d3,%a1
    addaw %d1,%a1
    lea BufTgFNum,%a2
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    bras rsrc_DRVR_4__Sony_D52_148
rsrc_DRVR_4__Sony_D52_140:/* the low-memory sector count */
    addw %a1@(38),%d0
    movew %d0,BufTgFBkNum
rsrc_DRVR_4__Sony_D52_148:/* write or read it */
    bsrw rsrc_DRVR_4__Sony_1E84_1EE_76	| 4086D27A
    bmiw rsrc_DRVR_4__Sony_F56_24_A
    bras rsrc_DRVR_4__Sony_D52_174
rsrc_DRVR_4__Sony_D52_152:/* read; copy the tags to the caller's tag buffer */
    bsrw rsrc_DRVR_4__Sony_1E84
    bmiw rsrc_DRVR_4__Sony_F56_24_A
    moveal SonyVars,%a1
    movel %a1@(244),%d0
    beqs rsrc_DRVR_4__Sony_D52_174
    moveal %d0,%a0
    addaw %a1@(248),%a0
    lea BufTgFNum,%a2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
rsrc_DRVR_4__Sony_D52_174:/* sector done: mark it, advance the counts */
    bsrw rsrc_DRVR_4__Sony_1010
    movel %a1@(34),%d4
    movew %a1@(254),%d2
    bclr %d2,%d4
    movel %d4,%a1@(34)
    moveal %a1@,%a2
    moveal %a2@(8),%a0
    moveq #2,%d3
    asll #8,%d3
    addl %d3,%a2@(16)
    addl %d3,%a0@(40)
    movel %a0@(36),%d3
    subl %a0@(40),%d3
    bset #7,IntFlag
    beqs rsrc_DRVR_4__Sony_D52_1C0
    bsrs rsrc_DRVR_4__Sony_F4E
    beqs rsrc_DRVR_4__Sony_D52_1D8
    tstl %d4
    bnes rsrc_DRVR_4__Sony_D52_1BA
    bsrs rsrc_DRVR_4__Sony_F56
    moveq #7,%d0
    bsrw rsrc_DRVR_4__Sony_118A
    bras rsrc_DRVR_4__Sony_D52_1DE
rsrc_DRVR_4__Sony_D52_1BA:/* more on this track? */
    tstb %a1@(0x13,%d1:w)
    bmis rsrc_DRVR_4__Sony_D52_1D8
rsrc_DRVR_4__Sony_D52_1C0:/* settle time */
    movew %a1@(62),%d0
    tstb %a1@(0x17,%d1:w)
    bpls rsrc_DRVR_4__Sony_D52_1CC
    moveq #75,%d0
rsrc_DRVR_4__Sony_D52_1CC:/* sleep */
    bsrw rsrc_DRVR_4__Sony_118A_26
    bsrs rsrc_DRVR_4__Sony_F56
    bsrw rsrc_DRVR_4__Sony_118A_14
    bras rsrc_DRVR_4__Sony_D52_1DE
rsrc_DRVR_4__Sony_D52_1D8:/* poll */
    bsrs rsrc_DRVR_4__Sony_F56
    andiw #-1793,%sr
rsrc_DRVR_4__Sony_D52_1DE:/* more sectors? next track; side 1 on a single-sided disk: -78 */
    movel %d4,%d0
    bnew rsrc_DRVR_4__Sony_D52_22
    tstl %d3
    bgtw rsrc_DRVR_4__Sony_B62_12_8_8	| 4086D318
    tstb %a1@(0x12,%d1:w)
    beqs rsrc_DRVR_4__Sony_D52_1F8
    tstb %a1@(0x5,%d1:w)
    bnes rsrc_DRVR_4__Sony_D52_1F8
    moveq #-78,%d0
rsrc_DRVR_4__Sony_D52_1F8:/* finish */
    braw rsrc_DRVR_4__Sony_B62

/* rsrc_DRVR_4__Sony_F4E: is the disk 800K/1440K (format code at a1+51 = 2)? */
rsrc_DRVR_4__Sony_F4E:
    cmpib #2,%a1@(51)
    rts

/* rsrc_DRVR_4__Sony_F56: give the interrupts a turn: save the state and return through PollProc (the SCC poll routine) when one is installed, else reset to PollStack */
rsrc_DRVR_4__Sony_F56:
    moveal %sp@+,%a4
    pea %pc@(rsrc_DRVR_4__Sony_F56_18)
    movel PollProc,%sp@-
    jbeq rsrc_DRVR_4__Sony_F56_24
    moveal SonyVars,%a1
    moveml %d0/%d2-%d3/%a0/%a4,%a1@(208)
    rts

/* rsrc_DRVR_4__Sony_F56_18: resume after PollProc: reload the state saved in SonyVars and continue */
rsrc_DRVR_4__Sony_F56_18:
    jbsr rsrc_DRVR_4__Sony_1010
    moveml %a1@(208),%d0/%d2-%d3/%a0/%a4
    jmp %a4@
rsrc_DRVR_4__Sony_F56_24:/* no poll proc: reset the stack */
    moveal PollStack,%sp
    jbsr rsrc_DRVR_4__Sony_1010
    jmp %a4@
rsrc_DRVR_4__Sony_F56_24_A:/* read error: retry count; cache off? recalibrate after too many */
    bsrs rsrc_DRVR_4__Sony_F56
    andiw #-1793,%sr
    bsrw rsrc_DRVR_4__Sony_4560_36_1E_2
    addqw #1,%a1@(0x14,%d1:w)
    tstb %a1@(45)
    beqs rsrc_DRVR_4__Sony_F56_24_22
    bsrs rsrc_DRVR_4__Sony_F4E
    bnes rsrc_DRVR_4__Sony_F56_24_5A
rsrc_DRVR_4__Sony_F56_24_22:/* retry */
    subqb #1,%a1@(43)
    bplw rsrc_DRVR_4__Sony_D52_22
    bras rsrc_DRVR_4__Sony_F56_24_5A
rsrc_DRVR_4__Sony_F56_24_2C:/* sector not found: wait, retry */
    moveal SonyVars,%a1
    movew %a1@(62),%d0
    tstb %a1@(0x17,%d6:w)
    bpls rsrc_DRVR_4__Sony_F56_24_3C
    moveq #75,%d0
rsrc_DRVR_4__Sony_F56_24_3C:/* sleep; count; sectNFErr after too many */
    bsrw rsrc_DRVR_4__Sony_118A_26
    bsrs rsrc_DRVR_4__Sony_F56
    bsrw rsrc_DRVR_4__Sony_118A_14
    addql #1,RndSeed
    moveq #-81,%d0
    subqb #1,%a1@(47)
    bmis rsrc_DRVR_4__Sony_F56_24_5A
    braw rsrc_DRVR_4__Sony_D52_28
rsrc_DRVR_4__Sony_F56_24_56:/* wrong track: seekErr (-80) */
    bsrs rsrc_DRVR_4__Sony_F56
    moveq #-80,%d0
rsrc_DRVR_4__Sony_F56_24_5A:/* retries left? recalibrate and reseek, else fail */
    andiw #-1793,%sr
    subqb #1,%a1@(45)
    bles rsrc_DRVR_4__Sony_F56_24_5A_18	| 4086D3BC
    bsrw rsrc_DRVR_4__Sony_1202
    bmis rsrc_DRVR_4__Sony_F56_24_5A_18	| 4086D3C2
    bsrw rsrc_DRVR_4__Sony_133A_AA_16
    bplw rsrc_DRVR_4__Sony_D52
rsrc_DRVR_4__Sony_F56_24_5A_18:
    .byte   0x60, 0x00	| 4086D3CC
rsrc_DRVR_4__Sony_FEE:  /* (data) */
    .byte   0xFF, 0x5C, 0x00, 0x4A, 0x00, 0x8C	| 4086D3CE
    bchg %d0,%a0@
    bchg %d0,%a4@(8312)
    bset %d0,%a0@-
    moveal VIA,%a2
    bsrs rsrc_DRVR_4__Sony_1018
    movew %pc@(rsrc_DRVR_4__Sony_FEE,%d1:w),%d1
    rts

/* rsrc_DRVR_4__Sony_1008: a0 = the IWM/SWIM base (IWM), a2 = the VIA base */
rsrc_DRVR_4__Sony_1008:
    moveal IWM,%a0
    moveal VIA,%a2

/* rsrc_DRVR_4__Sony_1010: d1 = the current drive's offset in the drive tables (1018), then the offset of its variables from the table at FEE */
rsrc_DRVR_4__Sony_1010:
    jbsr rsrc_DRVR_4__Sony_1018
    movew %pc@(rsrc_DRVR_4__Sony_FEE,%d1:w),%d1
    rts

/* rsrc_DRVR_4__Sony_1018: a1 = SonyVars; d1 = 2 * the current drive number (pinned at 4) */
rsrc_DRVR_4__Sony_1018:
    moveal SonyVars,%a1
    movew %a1@(18),%d1
    cmpiw #4,%d1
    jbls rsrc_DRVR_4__Sony_1018_10
    moveq #4,%d1
rsrc_DRVR_4__Sony_1018_10:/* d1 = 2 * drive */
    addw %d1,%d1
    rts

/* rsrc_DRVR_4__Sony_102C: AdrDisk: put a drive register address (d0, 4 bits: CA0, CA1, CA2 and SEL through VIA bit 5) on the floppy interface; SWIM in ISM mode: S_28EA */
rsrc_DRVR_4__Sony_102C:
    jbsr rsrc_DRVR_4__Sony_1008
    tstb %a1@(313)
    jbmi rsrc_DRVR_4__Sony_28EA
    tstb %a0@(512)
    tstb %a0@(1536)
    lsrb #1,%d0
    jbcc rsrc_DRVR_4__Sony_102C_1C
    tstb %a0@(2560)
    jbra rsrc_DRVR_4__Sony_102C_20
rsrc_DRVR_4__Sony_102C_1C:/* CA1 */
    tstb %a0@(2048)
rsrc_DRVR_4__Sony_102C_20:/* SEL (VIA bit 5) */
    lsrb #1,%d0
    jbcc rsrc_DRVR_4__Sony_102C_2C
    bset #5,%a2@(7680)
    jbra rsrc_DRVR_4__Sony_102C_32
rsrc_DRVR_4__Sony_102C_2C:/* SEL clear */
    bclr #5,%a2@(7680)
rsrc_DRVR_4__Sony_102C_32:/* CA0 */
    lsrb #1,%d0
    jbcs rsrc_DRVR_4__Sony_102C_38
    tstb %a0@
rsrc_DRVR_4__Sony_102C_38:/* CA2 */
    lsrb #1,%d0
    jbcs rsrc_DRVR_4__Sony_102C_40
    tstb %a0@(1024)
rsrc_DRVR_4__Sony_102C_40:  /* return */
    rts

/* rsrc_DRVR_4__Sony_106E: Sense(d0): select register d0 and read its status bit (bit 7 of the IWM status register, Q6 high Q7 low); N set = 1 */
rsrc_DRVR_4__Sony_106E: /* Sense: address the register, then read it */
    jbsr rsrc_DRVR_4__Sony_102C

/* rsrc_DRVR_4__Sony_1070: read the drive status bit already addressed (with interrupts off); ISM mode: S_2920 */
rsrc_DRVR_4__Sony_1070:
    tstb %a1@(313)
    jbmi rsrc_DRVR_4__Sony_2920
    movew %sr,%sp@-
    oriw #1792,%sr
    tstb %a0@(6656)
    moveb %a0@(7168),%d0
    tstb %a0@(6144)
    movew %sp@+,%sr
    tstb %d0
    rts

/* rsrc_DRVR_4__Sony_1090: DiskCmd(d0): select control register d0 and strobe it (LSTRB pulse: ph3 high then low) */
rsrc_DRVR_4__Sony_1090: /* DiskCmd: address the register, then strobe it */
    jbsr rsrc_DRVR_4__Sony_102C

/* rsrc_DRVR_4__Sony_1092: strobe the control register already addressed; ISM mode: S_292C */
rsrc_DRVR_4__Sony_1092:
    tstb %a1@(313)
    jbmi rsrc_DRVR_4__Sony_292C
    movew %sr,%sp@-
    oriw #1792,%sr
    tstb %a0@(3584)
    moveb %a2@(7680),%a2@(7680)
    tstb %a0@(3072)
    movew %sp@+,%sr
    rts

/* rsrc_DRVR_4__Sony_10B2: is there a disk in the drive? (no-disk sense, register 13; for the SWIM2 / external case both lines); d0 = -1 if not */
rsrc_DRVR_4__Sony_10B2:
    jbsr rsrc_DRVR_4__Sony_4664
    jbpl rsrc_DRVR_4__Sony_10B2_18
    tstb %a0@
    jbsr rsrc_DRVR_4__Sony_1070
    jbpl rsrc_DRVR_4__Sony_10B2_18
    tstb %a0@(512)
    tstb %a0@(1024)
    jbsr rsrc_DRVR_4__Sony_1070
    jbra rsrc_DRVR_4__Sony_10B2_1A
rsrc_DRVR_4__Sony_10B2_18:/* no disk */
    moveq #-1,%d0
rsrc_DRVR_4__Sony_10B2_1A:  /* return */
    rts

/* rsrc_DRVR_4__Sony_10CE: Seek(d6 = track): through JSeek; the default steps the head (direction, one step per track, waiting for each step) and records the new track; recalibrates when the track is unknown */
rsrc_DRVR_4__Sony_10CE: /* Seek through JSeek; the default: step the head to track d6 */
    bclr #11,%d6
    movel DiskVars_JSeek,%sp@-
    rts
    moveal %sp@+,%fp	| 4086D4B8
    jbsr rsrc_DRVR_4__Sony_1010	| 4086D4BA
    movew %a1@(0,%d1:w),%d7	| 4086D4BE
    jbpl rsrc_DRVR_4__Sony_10EC	| 4086D4C2
    jbsr rsrc_DRVR_4__Sony_1202	| 4086D4C4
    movew %d0,%d7	| 4086D4C8
    jbra rsrc_DRVR_4__Sony_10CE_44	| 4086D4CA
rsrc_DRVR_4__Sony_10EC: /* steps and direction */
    moveq #0,%d0	| 4086D4CC
    movew %d6,%d5	| 4086D4CE
    subw %d7,%d5	| 4086D4D0
    jbeq rsrc_DRVR_4__Sony_1130	| 4086D4D2
    jbgt rsrc_DRVR_4__Sony_10FA	| 4086D4D4
    moveq #1,%d0	| 4086D4D6
    negw %d5	| 4086D4D8
rsrc_DRVR_4__Sony_10FA: /* set the direction */
    jbsr rsrc_DRVR_4__Sony_1090
    moveq #-75,%d7
    subqw #1,%d5
rsrc_DRVR_4__Sony_10CE_32:/* each step: wait ready, strobe, settle */
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbpl rsrc_DRVR_4__Sony_10CE_44
    jbsr rsrc_DRVR_4__Sony_1092
    jbsr rsrc_DRVR_4__Sony_113C
    dbf %d5,rsrc_DRVR_4__Sony_10CE_32
    movew %d6,%d7
rsrc_DRVR_4__Sony_10CE_44:/* the new track; ISM: check the drive parameters */
    jbsr rsrc_DRVR_4__Sony_1010
    movew %d7,%a1@(0x0,%d1:w)
    tstb %a1@(313)
    jbpl rsrc_DRVR_4__Sony_10CE_5A
    jbsr rsrc_DRVR_4__Sony_27D6
    jbeq rsrc_DRVR_4__Sony_10CE_5A
    movew %d0,%d7
rsrc_DRVR_4__Sony_10CE_5A:/* settle time */
    movew %a1@(52),%d0
    moveq #5,%d2
    jbsr rsrc_DRVR_4__Sony_1168
rsrc_DRVR_4__Sony_1130: /* wait for the drive ready */
    movew %a1@(20),%d0
    moveq #0,%d2
    jbsr rsrc_DRVR_4__Sony_1168
    movew %d7,%d0
    jmp %fp@

/* rsrc_DRVR_4__Sony_113C: wait for a step to complete (sense register 4) and settle (TimeDBRA based delay) */
rsrc_DRVR_4__Sony_113C:
    movew %a1@(60),%d0
    jbsr rsrc_DRVR_4__Sony_115A
    moveq #80,%d2
rsrc_DRVR_4__Sony_113C_8:/* wait for the step to finish (register 4) */
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    dbmi %d2,rsrc_DRVR_4__Sony_113C_8
    movew TimeDBRA,%d2
    lsrw #5,%d2
rsrc_DRVR_4__Sony_113C_18:  /* count down (loop) */
    dbf %d2,rsrc_DRVR_4__Sony_113C_18
    rts

/* rsrc_DRVR_4__Sony_115A: start the motor-on wait when the drive needs it; else return to the caller's caller */
rsrc_DRVR_4__Sony_115A:
    tstb %a1@(0x13,%d1:w)
    jbmi rsrc_DRVR_4__Sony_115A_C
    addqw #4,%sp
    tstw %d0
    jbne rsrc_DRVR_4__Sony_118A
rsrc_DRVR_4__Sony_115A_C:  /* return */
    rts

/* rsrc_DRVR_4__Sony_1168: wait until the drive is ready (register 11) or about 1000 tries, with WakeUp sleeps */
rsrc_DRVR_4__Sony_1168:
    jbsr rsrc_DRVR_4__Sony_115A
    moveal %sp@+,%a4
    movew #1000,%d5
    movew %d2,%d0
    jbeq rsrc_DRVR_4__Sony_1168_E
rsrc_DRVR_4__Sony_1168_C:/* sleep */
    jbsr rsrc_DRVR_4__Sony_118A
rsrc_DRVR_4__Sony_1168_E:/* ready (register 11)? */
    moveq #11,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbpl rsrc_DRVR_4__Sony_1168_1C
    moveq #10,%d0
    dbf %d5,rsrc_DRVR_4__Sony_1168_C
rsrc_DRVR_4__Sony_1168_1C:/* done */
    clrw %a1@(20)
    jmp %a4@

/* rsrc_DRVR_4__Sony_118A: WakeUp(d0 = µs/10): sleep through the Time Manager (JWakeUp, vector 0x568 for the timer), resuming in the interrupt task at 118A_5E */
rsrc_DRVR_4__Sony_118A: /* WakeUp through JWakeUp: Time Manager sleep of d0 / 10 µs */
    movel DiskVars_JWakeUp,%sp@-
    rts
    moveml %d3-%d7/%a3-%fp,%a1@(208)
    movel %sp@+,DskRtnAdr
    bsrs rsrc_DRVR_4__Sony_118A_26
    bras rsrc_DRVR_4__Sony_118A_1E
rsrc_DRVR_4__Sony_118A_14:/* save the state for the wake-up */
    moveml %d3-%d7/%a3-%fp,%a1@(208)
    movel %sp@+,DskRtnAdr
rsrc_DRVR_4__Sony_118A_1E:/* noErr, interrupts on */
    moveq #0,%d0
    andiw #-1793,%sr
    rts
rsrc_DRVR_4__Sony_118A_26:/* WakeUp: shorten the motor-settle countdown by the wait */
    moveal SonyVars,%a1
    subw %d0,%a1@(20)
    bgts rsrc_DRVR_4__Sony_118A_34
    clrw %a1@(20)
rsrc_DRVR_4__Sony_118A_34:/* the Time Manager task: completion routine, delay in milliseconds (at least 10) */
    lea %a1@(280),%a0
    lea %pc@(rsrc_DRVR_4__Sony_118A_5E),%a1
    movel %a1,%a0@(6)
    andil #65535,%d0
    cmpiw #10,%d0
    jbcc rsrc_DRVR_4__Sony_118A_4E
    moveq #10,%d0
rsrc_DRVR_4__Sony_118A_4E:/* prime the timer (vector 0x568) */
    divuw #10,%d0
    extl %d0
    moveal 0x568,%a1
    jsr %a1@
    jbra rsrc_DRVR_4__Sony_1010
rsrc_DRVR_4__Sony_118A_5E:  /* save registers */
    moveml %d0-%fp,%sp@-
    jbsr rsrc_DRVR_4__Sony_1008
    moveml %a1@(208),%d3-%d7/%a3-%fp
    moveq #0,%d0
    jbsr rsrc_DRVR_4__Sony_1412
    moveml %sp@+,%d0-%fp
    rts

/* rsrc_DRVR_4__Sony_1202: Recal: through JRecal: step out to track 0 (up to 80 steps) until the track-0 sense; errors tk0BadErr (-75) / seekErr (-76) */
rsrc_DRVR_4__Sony_1202: /* Recal through JRecal: step out to track 0 */
    movel DiskVars_JRecal,%sp@-
    rts
    .short  0x2A5F	| 4086D5E8
    jbsr rsrc_DRVR_4__Sony_1008
    jbsr rsrc_DRVR_4__Sony_12CC
    jbsr rsrc_DRVR_4__Sony_2716
    jbne rsrc_DRVR_4__Sony_1202_54
    jbsr rsrc_DRVR_4__Sony_12E0
    moveq #80,%d7
    moveq #1,%d0
    jbsr rsrc_DRVR_4__Sony_1090
rsrc_DRVR_4__Sony_1202_22:/* steps */
    jbra rsrc_DRVR_4__Sony_4560_6A
    .long   0x00000000, 0x00000000	| 4086D608
    .long   0x00000000	| 4086D610
rsrc_DRVR_4__Sony_1202_32:/* track 0 (register 10)? step done (4)? */
    moveq #10,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbpl rsrc_DRVR_4__Sony_1202_52
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbpl rsrc_DRVR_4__Sony_1202_4E
    moveq #-76,%d0
    subqw #1,%d7
    jbeq rsrc_DRVR_4__Sony_1202_54
    jbsr rsrc_DRVR_4__Sony_1092
    jbra rsrc_DRVR_4__Sony_1202_22
rsrc_DRVR_4__Sony_1202_4E:/* tk0BadErr (-75) */
    moveq #-75,%d0
    jbra rsrc_DRVR_4__Sony_1202_54
rsrc_DRVR_4__Sony_1202_52:/* noErr */
    moveq #0,%d0
rsrc_DRVR_4__Sony_1202_54:/* store the track (or error) */
    movew %d0,%a1@(0x0,%d1:w)
    jmp %a5@

/* rsrc_DRVR_4__Sony_125C: set the IWM mode register to 0x17 (fast, synchronous, 1-second motor timer off...) and check it; noDriveErr-style -77 when it does not stick */
rsrc_DRVR_4__Sony_125C:
    tstb %a0@(6656)
    moveq #31,%d0
    andb %a0@(7168),%d0
    tstb %a0@(6144)
    cmpib #23,%d0
    jbeq rsrc_DRVR_4__Sony_125C_44
    moveq #8,%d2
    swap %d2
rsrc_DRVR_4__Sony_125C_18:/* set the mode register (0x17), check it took */
    moveq #-77,%d0
    subql #1,%d2
    jbmi rsrc_DRVR_4__Sony_125C_4A
    tstb %a0@(4096)
    tstb %a0@(6656)
    moveq #63,%d0
    andb %a0@(7168),%d0
    bclr #5,%d0
    jbne rsrc_DRVR_4__Sony_125C_18
    cmpib #23,%d0
    jbeq rsrc_DRVR_4__Sony_125C_44
    moveb #23,%a0@(7680)
    tstb %a0@(7168)
    jbra rsrc_DRVR_4__Sony_125C_18
rsrc_DRVR_4__Sony_125C_44:/* noErr */
    tstb %a0@(6144)
    moveq #0,%d0
rsrc_DRVR_4__Sony_125C_4A:  /* return */
    rts

/* rsrc_DRVR_4__Sony_12A8: set the motor-off timer (d0 = ticks, a1+26) or, with 0, turn the motor off now (command 9) and put the IWM back in read mode */
rsrc_DRVR_4__Sony_12A8:
    jbsr rsrc_DRVR_4__Sony_1010
    movew %d0,%a1@(26)
    jbeq rsrc_DRVR_4__Sony_12A8_12
    movew %a1@(18),%a1@(278)
    rts
rsrc_DRVR_4__Sony_12A8_12:/* motor off now */
    moveq #9,%d0
    jbsr rsrc_DRVR_4__Sony_1090
    moveb #0x86,%a0@(3072)
    tstb %a0@(4096)
    rts

/* rsrc_DRVR_4__Sony_12CC: forget the track cache if it belongs to the current drive */
rsrc_DRVR_4__Sony_12CC: /* the cache is this drive's? forget it */
    movew %a1@(258),%d0
    cmpw %a1@(18),%d0
    jbne rsrc_DRVR_4__Sony_12CC_E
    clrw %a1@(258)
rsrc_DRVR_4__Sony_12CC_E:  /* return */
    rts
rsrc_DRVR_4__Sony_12CC_E_2:/* power the drive up with d0 = 0 */
    moveq #0,%d0
    jbra rsrc_DRVR_4__Sony_12E0_4

/* rsrc_DRVR_4__Sony_12E0: power the drive up: select the side/density (MFM capable drives), check the motor; if off, turn it on and wait for it to reach speed (750 ms, longer for 400K drives) */
rsrc_DRVR_4__Sony_12E0: /* drive power-up wait time */
    movew %a1@(56),%d0
rsrc_DRVR_4__Sony_12E0_4:/* select; SuperDrive: set the density (registers 6/7) */
    movew %d0,%d2
    jbsr rsrc_DRVR_4__Sony_1336
    moveb %a1@(0x16,%d1:w),%d5
    jbpl rsrc_DRVR_4__Sony_12E0_28
    moveq #7,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    moveb %d0,%sp@-
    moveq #7,%d0
    moveb %a1@(0x17,%d1:w),%d5
    jbpl rsrc_DRVR_4__Sony_12E0_20
    moveq #6,%d0
rsrc_DRVR_4__Sony_12E0_20:/* density command */
    jbsr rsrc_DRVR_4__Sony_1090
    moveb %sp@+,%d0
    eorb %d0,%d5
rsrc_DRVR_4__Sony_12E0_28:/* motor on (register 8)? else turn it on and wait (750 ms, 6 s on 400K) */
    moveq #8,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    orb %d5,%d0
    jbpl rsrc_DRVR_4__Sony_12E0_54
    jbsr rsrc_DRVR_4__Sony_1092
    movew %d2,%d0
    movew #750,%d2
    movel %sp@+,%d4
    jbsr rsrc_DRVR_4__Sony_1168
    movel %d4,%sp@-
    cmpib #2,%a1@(51)
    jbeq rsrc_DRVR_4__Sony_12E0_54
    movew #6000,%d0
    jbra rsrc_DRVR_4__Sony_118A
rsrc_DRVR_4__Sony_12E0_54:  /* return */
    rts

/* rsrc_DRVR_4__Sony_1336: select the current drive (JDiskSel) */
rsrc_DRVR_4__Sony_1336: /* select the drive */
    jbsr rsrc_DRVR_4__Sony_1008

/* rsrc_DRVR_4__Sony_133A: DiskSel: through JDiskSel: motor timer of the other drive off, then select the internal or external drive (and SEL for the second internal on the IIfx-style configurations); ISM mode: S_2950 */
rsrc_DRVR_4__Sony_133A: /* DiskSel through JDiskSel */
    movel JDiskSel,%sp@-
    rts
    tstw %a1@(26)	| 4086D720
    jbeq rsrc_DRVR_4__Sony_1356	| 4086D724
    movew %a1@(278),%d0	| 4086D726
    cmpw %a1@(18),%d0	| 4086D72A
    jbeq rsrc_DRVR_4__Sony_1356	| 4086D72E
    moveq #0,%d0
    jbsr rsrc_DRVR_4__Sony_12A8
rsrc_DRVR_4__Sony_1356: /* internal or external (and the ISM path) */
    clrw %a1@(26)
    tstb %a1@(313)
    jbmi rsrc_DRVR_4__Sony_2950
    cmpiw #74,%d1
    jbne rsrc_DRVR_4__Sony_133A_38
    tstb %a0@(5120)
    tstb %a0@(4608)
    rts
rsrc_DRVR_4__Sony_133A_38:/* the internal drive: SEL off */
    tstb %a0@(2560)
    tstb %a0@(1536)
    tstb %a0@(512)
    bclr #5,%a2@(7680)
    tstb %a0@(5632)
    tstb %a1@(252)
    jbeq rsrc_DRVR_4__Sony_133A_5A
    tstb %a0@(4608)
    rts
rsrc_DRVR_4__Sony_133A_5A:/* drive 3: pulse the head lines */
    cmpiw #140,%d1
    jbne rsrc_DRVR_4__Sony_133A_AA
    tstb %a0@(4608)
    moveq #2,%d0
rsrc_DRVR_4__Sony_133A_66:/* interrupts off */
    movew %sr,%sp@-
    oriw #1792,%sr
    tstb %a0@(6656)
rsrc_DRVR_4__Sony_133A_70:/* until the line responds */
    tstb %a0@(7168)
    dbpl %d0,rsrc_DRVR_4__Sony_133A_80
    tstb %a0@(6144)
    movew %sp@+,%sr
    rts
rsrc_DRVR_4__Sony_133A_80:/* pulse */
    tstb %a0@(3584)
    moveb %a2@(7680),%a2@(7680)
    tstb %a0@(3072)
    moveb %a2@(7680),%a2@(7680)
    tstb %a0@(1024)
    moveb %a2@(7680),%a2@(7680)
    tstb %a0@(1536)
    moveb %a2@(7680),%a2@(7680)
    jbra rsrc_DRVR_4__Sony_133A_70
rsrc_DRVR_4__Sony_133A_AA:/* drive 4 */
    tstb %a0@(4096)
    movew %a1@(18),%d0
    moveb %a2@(7680),%a2@(7680)
    tstb %a0@(4608)
    subqw #3,%d0
    jbra rsrc_DRVR_4__Sony_133A_66
rsrc_DRVR_4__Sony_133A_AA_16:/* (the vectors at 0x24E) and helpers: wait 8 ms, JFigTrkSpd */
    movel 0x24e,%sp@-
    rts
    movew #8000,%d0
    braw rsrc_DRVR_4__Sony_118A
    movel DiskVars_JFigTrkSpd,%sp@-
    rts
    moveq #-1,%d0
    rts

/* rsrc_DRVR_4__Sony_1412: return to the routine saved in DskRtnAdr with d0 tested; 1412_8 is the disk-polling VBL task: turn the motor off when its timer expires, check each drive for a disk inserted or ejected (1468) */
rsrc_DRVR_4__Sony_1412: /* return to DskRtnAdr */
    movel DskRtnAdr,%sp@-
    tstw %d0
    rts
rsrc_DRVR_4__Sony_1412_8:/* the disk-polling VBL task (also the Time Manager wake-up path) */
    movew %sr,%sp@-
    moveal SonyVars,%a1
    jbsr rsrc_DRVR_4__Sony_45F8
    jbeq rsrc_DRVR_4__Sony_1412_52
    oriw #1792,%sr
    tstb %a1@(25)
    jbne rsrc_DRVR_4__Sony_1412_52
    tstw %a1@(26)
    jbeq rsrc_DRVR_4__Sony_1412_30
    subqw #1,%a1@(26)
    jbne rsrc_DRVR_4__Sony_1412_52
    moveq #9,%d0
    jbsr rsrc_DRVR_4__Sony_1090
rsrc_DRVR_4__Sony_1412_30:/* the VBL: poll each drive for a disk */
    moveq #1,%d3
rsrc_DRVR_4__Sony_1412_32:/* next drive */
    jbsr rsrc_DRVR_4__Sony_1468
    addqw #1,%d3
    cmpiw #4,%d3
    jbgt rsrc_DRVR_4__Sony_1412_48
    tstb %a1@(252)
    jbeq rsrc_DRVR_4__Sony_1412_32
    cmpiw #3,%d3
    jble rsrc_DRVR_4__Sony_1412_32
rsrc_DRVR_4__Sony_1412_48:/* IWM read mode; power */
    moveb #0x86,%a0@(3072)
    jbsr rsrc_DRVR_4__Sony_4614
rsrc_DRVR_4__Sony_1412_52:/* return */
    movew %sp@+,%sr
    rts

/* rsrc_DRVR_4__Sony_1468: poll one drive (d3): newly inserted disk: PostEvent diskEvt (event 7) after checking it; ejected: mark it */
rsrc_DRVR_4__Sony_1468:
    movew %d3,%a1@(18)
    jbsr rsrc_DRVR_4__Sony_1008
    tstb %a1@(0x4,%d1:w)
    jbmi rsrc_DRVR_4__Sony_14E6_8
    tstb %a1@(0x3,%d1:w)
    jbgt rsrc_DRVR_4__Sony_1468_1E
    jbeq rsrc_DRVR_4__Sony_14A4
    jbra rsrc_DRVR_4__Sony_4632
    .short  0x4E71, 0x4E71	| 4086D862
rsrc_DRVR_4__Sony_1468_1E:/* drives 1 and 2: disk ejected? mark it */
    cmpiw #3,%a1@(18)
    jbge rsrc_DRVR_4__Sony_14E6_8
    jbsr rsrc_DRVR_4__Sony_133A
    jbsr rsrc_DRVR_4__Sony_14F0
    jbpl rsrc_DRVR_4__Sony_14E6_8
    moveq #-1,%d0
    movew %a1@(18),%d0
    moveaw #7,%a0
    _PostEvent
    rts

rsrc_DRVR_4__Sony_14A4: /* disk inserted? (SuperDrive: register 2 via ISM) */
    jbsr rsrc_DRVR_4__Sony_133A
    cmpiw #3,%a1@(18)
    jblt rsrc_DRVR_4__Sony_14A4_28
    tstb %a1@(313)
    jbpl rsrc_DRVR_4__Sony_14A4_1A
    moveb #0xf2,%a0@(2048)
    jbra rsrc_DRVR_4__Sony_14A4_20
rsrc_DRVR_4__Sony_14A4_1A:/* IWM */
    tstb %a0@
    tstb %a0@(2048)
rsrc_DRVR_4__Sony_14A4_20:/* sense */
    jbsr rsrc_DRVR_4__Sony_1070
    jbmi rsrc_DRVR_4__Sony_14A4_30
    jbra rsrc_DRVR_4__Sony_14E6_8
rsrc_DRVR_4__Sony_14A4_28:/* register 2: disk in place */
    moveq #2,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbmi rsrc_DRVR_4__Sony_14E6_8
rsrc_DRVR_4__Sony_14A4_30:/* inserted: clear the switch latch, PostEvent diskEvt (7), mark it */
    jbsr rsrc_DRVR_4__Sony_14F0
    moveq #7,%d0
    moveal %d0,%a0
    movew %a1@(18),%d0
    _PostEvent
    jbne rsrc_DRVR_4__Sony_14E6
    addqb #1,%a1@(0x3,%d1:w)

rsrc_DRVR_4__Sony_14E6: /* mark */
    st %a1@(0x0,%d1:w)
    moveal IWM,%a0
rsrc_DRVR_4__Sony_14E6_8:  /* return */
    rts

/* rsrc_DRVR_4__Sony_14F0: is the disk in the drive ejectable / just inserted? on the SuperDrive also the mode; issue command 3 (clear the disk-switched latch) */
rsrc_DRVR_4__Sony_14F0:
    jbsr rsrc_DRVR_4__Sony_4656
    jbpl rsrc_DRVR_4__Sony_14F0_16
    moveq #12,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbpl rsrc_DRVR_4__Sony_14F0_16
    moveq #3,%d0
    jbsr rsrc_DRVR_4__Sony_1090
    moveq #-1,%d0
rsrc_DRVR_4__Sony_14F0_16:  /* return */
    rts
rsrc_DRVR_4__Sony_1508:  /* (data) */
    .long   0x0048034E, 0x00040048	| 4086D8E8
    .long   0x024C0804, 0x00480048, 0x05070048, 0x00480D07	| 4086D8F0
    .long   0x0030053A, 0x00040030, 0x063C0104, 0x00300030	| 4086D900
    .long   0x05070030, 0x00300D07, 0x00180420, 0x00040018	| 4086D910
    .long   0x011A0104, 0x00180018, 0x05070018, 0x00180D07	| 4086D920
    .include "rsrc/icons/sony_a.s"
    jbne rsrc_DRVR_4__Sony_1CB0	| 4086E03E
    jbsr rsrc_DRVR_4__Sony_1CB4
    movew %a3@,%d0
rsrc_DRVR_4__Sony_1C64: /* an icon: ROM or the drive table */
    lea %pc@(rsrc_DRVR_4__Sony_1508),%a3
    bclr #0,%d0
    jbne rsrc_DRVR_4__Sony_1C72
    moveal %a1@(308),%a3
rsrc_DRVR_4__Sony_1C72: /* offset */
    extl %d0
    jbra rsrc_DRVR_4__Sony_1C8C

/* Control 21 / 22, the drive's or the media's icon. */
SONY_CTL_GetDriveIcon:
    jbne rsrc_DRVR_4__Sony_1CB0	| 4086E056
    jbsr rsrc_DRVR_4__Sony_4480
    jbne rsrc_DRVR_4__Sony_1CAA
    jbsr rsrc_DRVR_4__Sony_1CB4
    movew %a3@(2),%d0
    jbra rsrc_DRVR_4__Sony_1C64
    .short  0x4E71, 0x4E71, 0x4E71	| 4086E066
rsrc_DRVR_4__Sony_1C8C: /* its address */
    addl %a3,%d0
    jbra rsrc_DRVR_4__Sony_1CAA

/* Control 23, drive information (type, internal or external). */
SONY_CTL_GetDriveInfo:
    jbne rsrc_DRVR_4__Sony_1CB0	| 4086E070
    jbsr rsrc_DRVR_4__Sony_1CB4	| 4086E072
    .byte   0x30, 0x2B	| 4086E074
    .short  0x0004, 0x0C69	| orib #105,%d4
    orib #18,%d3
    jbge rsrc_DRVR_4__Sony_1CAA
    tstb %a1@(0x16,%d1:w)
    jbpl rsrc_DRVR_4__Sony_1CAA
    moveb #4,%d0
rsrc_DRVR_4__Sony_1CAA: /* return it in csParam; noErr */
    movel %d0,%a0@(28)
    moveq #0,%d0
rsrc_DRVR_4__Sony_1CB0: /* finish */
    jbra rsrc_DRVR_4__Sony_784

/* rsrc_DRVR_4__Sony_1CB4: a3 = the current drive's entry in the drive information table (6 bytes per drive, a1+308) */
rsrc_DRVR_4__Sony_1CB4:
    movew %a1@(18),%d0
    subqw #1,%d0
rsrc_DRVR_4__Sony_1CB4_6:/* entry d0 of the drive information table (6 bytes each) */
    addw %d0,%d0
    moveaw %d0,%a3
    addw %d0,%d0
    addw %a3,%d0
    moveal %a1@(308),%a3
    addaw %d0,%a3
    rts

/* rsrc_DRVR_4__Sony_1CCA: a2 = the drive configuration table for this machine (S_48A6 entries keyed by the box flag at 0xCB3; default S_48AC) */
rsrc_DRVR_4__Sony_1CCA:
    lea %pc@(rsrc_DRVR_4__Sony_48A6),%a2
rsrc_DRVR_4__Sony_1CCA_4:/* next entry: this machine (box flag 0xCB3)? */
    addqw #4,%a2
    movew %a2@+,%d0
    jbmi rsrc_DRVR_4__Sony_1CCA_14
    cmpb 0xcb3,%d0
    jbne rsrc_DRVR_4__Sony_1CCA_4
    addal %a2@,%a2
    rts
rsrc_DRVR_4__Sony_1CCA_14:/* default table */
    lea %pc@(rsrc_DRVR_4__Sony_48AC),%a2
    addal %a2@,%a2
    rts
    .short  0x0000, 0xFFFF, 0xF820, 0x0001, 0xFFFF	| 4086E0C6
    .long   0xF81A0003, 0xFFFFF844, 0x0002FFFF, 0xF8260005	| 4086E0D0
    .long   0xFFFFF820, 0x0007FFFF, 0xF802000C, 0x00002C52	| 4086E0E0
    .long   0x000D0000, 0x2C64000E, 0x00002C76, 0x000F0000	| 4086E0F0
    .long   0x2C880010, 0x00002C9A, 0x00140000, 0x2C640017	| 4086E100
    .long   0x00002CA6, 0x001A0000, 0x2CA00020, 0x00002C9A	| 4086E110
    .long   0x00210000, 0x2C940015, 0x00002C2E, 0xFF000000	| 4086E120
    .long   0x00000000, 0x00000000	| 4086E130
rsrc_DRVR_4__Sony_1D58:  /* (data) */
    .short  0xD5AA, 0x96DE, 0xAAFF	| 4086E138

/* rsrc_DRVR_4__Sony_1D5E: SetUpPoll through JSetUpPoll: prepare for reading/writing with interrupts held except the SCC poll */
rsrc_DRVR_4__Sony_1D5E:
    movel DiskVars_JSetUpPoll,%sp@-
    rts
    bsrw rsrc_DRVR_4__Sony_5880_35E_4
    addql #6,%fp
    moveal VIA,%a5
    lea %a5@(7680),%a5
    oriw #1792,%sr
    movel %sp,PollStack
    addl %d0,PollStack
    rts

/* rsrc_DRVR_4__Sony_1D80: read the next address field: set the side (d0 = 1 or 3 for side 1), then RdAddr (1D94) */
rsrc_DRVR_4__Sony_1D80:
    moveq #8,%d0
    jbsr rsrc_DRVR_4__Sony_1D5E
    moveq #1,%d0
    btst #3,%a1@(22)
    jbeq rsrc_DRVR_4__Sony_1D80_10
    moveq #3,%d0
rsrc_DRVR_4__Sony_1D80_10:/* select the side */
    jbsr rsrc_DRVR_4__Sony_102C

/* rsrc_DRVR_4__Sony_1D94: RdAddr: read the next GCR address field (D5 AA 96, track, sector, side, format, checksum, DE AA) through JRdAddr; MFM disks: S_2A24; errors noNybErr (-66), noAdrMkErr (-67), badCksmErr... */
rsrc_DRVR_4__Sony_1D94:
    jbsr rsrc_DRVR_4__Sony_1010
    tstb %a1@(0x17,%d1:w)
    jbmi rsrc_DRVR_4__Sony_2A24
    lea %pc@(rsrc_DRVR_4__Sony_1D58),%a2
    movel DiskVars_JRdAddr,%sp@-
    rts
    moveq #3,%d3	| 4086E18A
    movew #575,%d2	| 4086E18C
    moveq #0,%d5
    moveal IWM,%a4
    lea %a4@(6144),%a4
    movel %sp@+,DskRtnAdr
rsrc_DRVR_4__Sony_1D94_2A:/* wait for a sync byte (FF... or the address mark), up to 575 bytes; noNybErr (-66) */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    moveb %a4@,%d5
    dbf %d2,rsrc_DRVR_4__Sony_1D94_3C
    moveq #-66,%d0
    jbra rsrc_DRVR_4__Sony_1D94_DE
rsrc_DRVR_4__Sony_1D94_3C:/* three in a row */
    jbpl rsrc_DRVR_4__Sony_1D94_2A
    subqw #1,%d3
    jbne rsrc_DRVR_4__Sony_1D94_2A
    movew #1500,%d0
    tstb %a1@(0x13,%d1:w)
    jbeq rsrc_DRVR_4__Sony_1D94_50
    movew #1468,%d0
rsrc_DRVR_4__Sony_1D94_50:/* the GCR decoding table */
    lea %pc@(rsrc_DRVR_4__Sony_1E84_15C),%a3
rsrc_DRVR_4__Sony_1D94_54:/* look for the mark D5 AA 96 (1500 nibbles; 1468 for 400K) */
    moveal %a2,%a0
    moveq #3,%d1
rsrc_DRVR_4__Sony_1D94_58:/* next nibble; none: noAdrMkErr (-67) */
    moveb %a4@,%d5
    jbpl rsrc_DRVR_4__Sony_1D94_58
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    dbf %d0,rsrc_DRVR_4__Sony_1D94_6A
    moveq #-67,%d0
    jbra rsrc_DRVR_4__Sony_1D94_DE
rsrc_DRVR_4__Sony_1D94_6A:/* compare */
    cmpb %a0@+,%d5
    jbne rsrc_DRVR_4__Sony_1D94_54
    subqw #1,%d1
    jbne rsrc_DRVR_4__Sony_1D94_58
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1D94_78:/* track */
    moveb %a4@,%d5
    jbpl rsrc_DRVR_4__Sony_1D94_78
    moveb %a3@(0x0,%d5:w),%d1
    moveb %d1,%d4
    rorw #6,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1D94_8A:/* sector */
    moveb %a4@,%d5
    jbpl rsrc_DRVR_4__Sony_1D94_8A
    moveq #0,%d2
    moveb %a3@(0x0,%d5:w),%d2
    eorb %d2,%d4
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1D94_9C:/* side */
    moveb %a4@,%d5
    jbpl rsrc_DRVR_4__Sony_1D94_9C
    moveb %a3@(0x0,%d5:w),%d1
    eorb %d1,%d4
    rolw #6,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1D94_AE:/* format */
    moveb %a4@,%d5
    jbpl rsrc_DRVR_4__Sony_1D94_AE
    moveb %a3@(0x0,%d5:w),%d3
    eorb %d3,%d4
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1D94_BE:/* checksum: must be zero, else badCksmErr (-69) */
    moveb %a4@,%d5
    jbpl rsrc_DRVR_4__Sony_1D94_BE
    moveb %a3@(0x0,%d5:w),%d5
    eorb %d5,%d4
    jbne rsrc_DRVR_4__Sony_1D94_E2
    moveq #1,%d4
rsrc_DRVR_4__Sony_1D94_CC:/* the bit-slip marks DE AA */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1D94_D2:/* compare; wrong: badBtSlpErr (-70) */
    moveb %a4@,%d5
    jbpl rsrc_DRVR_4__Sony_1D94_D2
    cmpb %a0@+,%d5
    jbne rsrc_DRVR_4__Sony_1D94_E6
    dbf %d4,rsrc_DRVR_4__Sony_1D94_CC
rsrc_DRVR_4__Sony_1D94_DE:/* return through DskRtnAdr */
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_1D94_E2:/* badCksmErr (-69) */
    moveq #-69,%d0
    jbra rsrc_DRVR_4__Sony_1D94_DE
rsrc_DRVR_4__Sony_1D94_E6:/* badBtSlpErr (-70) */
    moveq #-70,%d0
    jbra rsrc_DRVR_4__Sony_1D94_DE
rsrc_DRVR_4__Sony_1E7E:  /* (data) */
    .short  0xD5AA	| 4086E25E
    .long   0xADDEAAFF	| 4086E260

/* rsrc_DRVR_4__Sony_1E84: RdData: read (or verify, DskVerify) a 512-byte GCR sector with its 12 tag bytes through JRdData: data mark D5 AA AD, 6-and-2 decoding with the running checksum; MFM: S_2AE6 */
rsrc_DRVR_4__Sony_1E84:
    jbsr rsrc_DRVR_4__Sony_1010
    tstb %a1@(0x17,%d1:w)
    jbmi rsrc_DRVR_4__Sony_2AE6
    lea %pc@(rsrc_DRVR_4__Sony_1E7E),%a1
    movel DiskVars_JRdData,%sp@-
    rts
rsrc_DRVR_4__Sony_1E84_16:/* RdData (default, through JRdData): save the return address, set up the decode registers */
    .short  0x21DF, 0x0124	| 4086E27A
    moveq #48,%d2
    moveq #0,%d3
    moveq #-64,%d0
    movel #33423370,%d4
    moveq #0,%d5
    moveq #0,%d6
    moveq #0,%d7
rsrc_DRVR_4__Sony_1E84_2C:/* RdData: find the data mark D5 AA AD (48 nibbles); else noDtaMkErr (-71) */
    moveal %a1,%a2
    moveq #3,%d1
rsrc_DRVR_4__Sony_1E84_30:/* next nibble */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_30
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    dbf %d2,rsrc_DRVR_4__Sony_1E84_42
    moveq #-71,%d0
    jbra rsrc_DRVR_4__Sony_1D94_DE
rsrc_DRVR_4__Sony_1E84_42:/* compare */
    cmpb %a2@+,%d3
    jbne rsrc_DRVR_4__Sony_1E84_2C
    subqw #1,%d1
    jbne rsrc_DRVR_4__Sony_1E84_30
rsrc_DRVR_4__Sony_1E84_4A:/* the sector number nibble; then the 12 tag bytes */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_4A
    lea TagData_1,%a1
    moveb %a3@(0x0,%d3:w),%a1@+
rsrc_DRVR_4__Sony_1E84_56:/* tags: 4 nibbles to 3 bytes (6-and-2), with the running checksum */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_56
    moveb %a3@(0x0,%d3:w),%d1
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_1E84_6A:/* second byte */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_6A
    orb %a3@(0x0,%d3:w),%d2
    moveb %d7,%d3
    addb %d7,%d3
    rolb #1,%d7
    eorb %d7,%d2
    moveb %d2,%a1@+
    addxb %d2,%d5
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_1E84_84:/* third byte */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_84
    orb %a3@(0x0,%d3:w),%d2
    eorb %d5,%d2
    moveb %d2,%a1@+
    addxb %d2,%d6
    rolb #2,%d1
    andb %d0,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_9C:/* next group */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_9C
    orb %a3@(0x0,%d3:w),%d1
    eorb %d6,%d1
    moveb %d1,%a1@+
    addxb %d1,%d7
    subqw #3,%d4
    jbpl rsrc_DRVR_4__Sony_1E84_56
    swap %d4
    tstb DskVerify
    jbeq rsrc_DRVR_4__Sony_1E84_BE
    jbra rsrc_DRVR_4__Sony_1E84_11A
rsrc_DRVR_4__Sony_1E84_B8:/* data: 4 nibbles to 3 bytes into the buffer */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_BE:/* high bits */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_B8
    moveb %a3@(0x0,%d3:w),%d1
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_1E84_CC:/* first byte */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_CC
    orb %a3@(0x0,%d3:w),%d2
    moveb %d7,%d3
    addb %d7,%d3
    rolb #1,%d7
    eorb %d7,%d2
    moveb %d2,%a0@+
    addxb %d2,%d5
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_1E84_E6:/* second byte */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_E6
    orb %a3@(0x0,%d3:w),%d2
    eorb %d5,%d2
    moveb %d2,%a0@+
    addxb %d2,%d6
    tstw %d4
    jbeq rsrc_DRVR_4__Sony_1E84_176
    rolb #2,%d1
    andb %d0,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_102:/* third byte */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_102
    orb %a3@(0x0,%d3:w),%d1
    eorb %d6,%d1
    moveb %d1,%a0@+
    addxb %d1,%d7
    subqw #3,%d4
    jbra rsrc_DRVR_4__Sony_1E84_B8
rsrc_DRVR_4__Sony_1E84_114:/* verify: decode and compare with the buffer */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_11A:/* high bits */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_114
    moveb %a3@(0x0,%d3:w),%d1
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_1E84_128:/* first byte */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_128
    orb %a3@(0x0,%d3:w),%d2
    moveb %d7,%d3
    addb %d7,%d3
    rolb #1,%d7
    eorb %d7,%d2
    cmpb %a0@+,%d2
    jbne rsrc_DRVR_4__Sony_1E84_16E
    addxb %d2,%d5
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_1E84_144:/* second byte */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_144
    orb %a3@(0x0,%d3:w),%d2
    eorb %d5,%d2
    cmpb %a0@+,%d2
    jbne rsrc_DRVR_4__Sony_1E84_1D0
    addxb %d2,%d6
    tstw %d4
    jbeq rsrc_DRVR_4__Sony_1E84_176
    rolb #2,%d1
    andb %d0,%d1
rsrc_DRVR_4__Sony_1E84_15C:/* (poll) */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_162:/* third byte */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_162
    orb %a3@(0x0,%d3:w),%d1
    eorb %d6,%d1
    cmpb %a0@+,%d1
rsrc_DRVR_4__Sony_1E84_16E:/* mismatch: dataVerErr (-68) */
    jbne rsrc_DRVR_4__Sony_1E84_1D0
    addxb %d1,%d7
    subqw #3,%d4
    jbra rsrc_DRVR_4__Sony_1E84_114
rsrc_DRVR_4__Sony_1E84_176:/* the checksum nibbles */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_17C:/* first */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_17C
    moveb %a3@(0x0,%d3:w),%d1
    jbmi rsrc_DRVR_4__Sony_1E84_1CC
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_1E84_18C:/* second */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_18C
    moveb %a3@(0x0,%d3:w),%d3
    jbmi rsrc_DRVR_4__Sony_1E84_1CC
    orb %d3,%d2
    cmpb %d2,%d5
    jbne rsrc_DRVR_4__Sony_1E84_1CC
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_1E84_1A2:/* third */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_1A2
    moveb %a3@(0x0,%d3:w),%d3
    jbmi rsrc_DRVR_4__Sony_1E84_1CC
    orb %d3,%d2
    cmpb %d2,%d6
    jbne rsrc_DRVR_4__Sony_1E84_1CC
    rolb #2,%d1
    andb %d0,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_1BC:/* fourth; must match */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_1BC
    moveb %a3@(0x0,%d3:w),%d3
    jbmi rsrc_DRVR_4__Sony_1E84_1CC
    orb %d3,%d1
    cmpb %d1,%d7
    jbeq rsrc_DRVR_4__Sony_1E84_1D4
rsrc_DRVR_4__Sony_1E84_1CC:/* badDCksum (-72) */
    moveq #-72,%d0
    jbra rsrc_DRVR_4__Sony_1E84_1EA
rsrc_DRVR_4__Sony_1E84_1D0:/* dataVerErr (-68) */
    moveq #-68,%d0
    jbra rsrc_DRVR_4__Sony_1E84_1EA
rsrc_DRVR_4__Sony_1E84_1D4:/* the bit-slip marks */
    moveq #1,%d4
rsrc_DRVR_4__Sony_1E84_1D6:/* compare; noErr */
    moveb %a4@,%d3
    jbpl rsrc_DRVR_4__Sony_1E84_1D6
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    cmpb %a2@+,%d3
    jbne rsrc_DRVR_4__Sony_1E84_1EE
    dbf %d4,rsrc_DRVR_4__Sony_1E84_1D6
    moveq #0,%d0
rsrc_DRVR_4__Sony_1E84_1EA:/* return */
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_1E84_1EE:/* badDBtSlp (-73) */
    moveq #-73,%d0
    jbra rsrc_DRVR_4__Sony_1E84_1EA
    orib #-1,%d1
    .short  0x0203, 0xFF04	| andib #4,%d3
    btst %d2,%d6
    .byte   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x07, 0x08, 0xFF, 0xFF, 0xFF, 0x09, 0x0A, 0x0B, 0x0C, 0x0D	| 4086E460
    .byte   0xFF, 0xFF, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0xFF, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A	| 4086E470
    .byte   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x1B, 0xFF, 0x1C, 0x1D, 0x1E	| 4086E480
    .byte   0xFF, 0xFF, 0xFF, 0x1F, 0xFF, 0xFF, 0x20, 0x21, 0xFF, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28	| 4086E490
    .byte   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x29, 0x2A, 0x2B, 0xFF, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32	| 4086E4A0
    .byte   0xFF, 0xFF, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0xFF, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F	| 4086E4B0
rsrc_DRVR_4__Sony_1E84_1EE_6E:
    .byte   0xFF, 0x3F, 0xCF, 0xF3, 0xFC, 0xFF, 0xD5, 0xAA	| 4086E4C0
rsrc_DRVR_4__Sony_1E84_1EE_76:
    bsrw rsrc_DRVR_4__Sony_1010	| 4086E4C8
    tstb %a1@(0x17,%d1:w)
    bmiw rsrc_DRVR_4__Sony_2AE6_D2+0x4
    lea %pc@(rsrc_DRVR_4__Sony_1E84_1EE_6E),%a2
    movel 0x232,%sp@-
    rts
    .byte   0x21, 0xDF, 0x01, 0x24, 0x43, 0xF8, 0x02, 0xFB, 0x28, 0x3C, 0x02, 0x01, 0x00, 0x09	| 4086E4DE
    moveq #0,%d2
    moveq #0,%d3
    moveq #0,%d5
    moveq #0,%d6
    moveq #0,%d7
    moveq #6,%d0
    jbsr rsrc_DRVR_4__Sony_5BFA
    tstb %a3@(6656)
    moveb %a2@+,%a3@(7680)
    lea %a3@(6656),%a3
rsrc_DRVR_4__Sony_1E84_2A4:/* WrData: the sync bytes and the data mark */
    moveb %a2@+,%d1
rsrc_DRVR_4__Sony_1E84_2A6:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_2A6
    moveb %d1,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    subqw #1,%d0
    jbne rsrc_DRVR_4__Sony_1E84_2A4
    moveb %a2@+,%d1
    lea %pc@(rsrc_DRVR_4__Sony_2248),%a2
rsrc_DRVR_4__Sony_1E84_2BC:/* the sector number; encode the tags then the data */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_2BC
    moveb %d1,%a3@
    moveq #11,%d1
    moveb %a1@+,%d2
    jbra rsrc_DRVR_4__Sony_1E84_2F4
rsrc_DRVR_4__Sony_1E84_2C8:/* the buffer */
    moveal %a0,%a1
rsrc_DRVR_4__Sony_1E84_2CA:/* 3 bytes to 4 nibbles with the running checksum */
    addxb %d2,%d7
    eorb %d6,%d2
    moveb %d2,%d3
    lsrw #6,%d3
rsrc_DRVR_4__Sony_1E84_2D2:/* high bits nibble */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_2D2
    moveb %a2@(0x0,%d3:w),%a3@
    subqw #3,%d4
    moveb %d7,%d3
    addb %d7,%d3
    rolb #1,%d7
    andib #63,%d0
rsrc_DRVR_4__Sony_1E84_2E6:/* first */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_2E6
    moveb %a2@(0x0,%d0:w),%a3@
rsrc_DRVR_4__Sony_1E84_2F4:/* next 3 bytes */
    moveb %a1@+,%d0
    addxb %d0,%d5
    eorb %d7,%d0
    moveb %d0,%d3
    rolw #2,%d3
    andib #63,%d1
rsrc_DRVR_4__Sony_1E84_302:/* second */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_302
    moveb %a2@(0x0,%d1:w),%a3@
    moveb %a1@+,%d1
    addxb %d1,%d6
    eorb %d5,%d1
    moveb %d1,%d3
    rolw #2,%d3
    andib #63,%d2
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_31E:/* third; more? */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_31E
    moveb %a2@(0x0,%d2:w),%a3@
    moveb %a1@+,%d2
    tstw %d4
    jbne rsrc_DRVR_4__Sony_1E84_2CA
    swap %d4
    jbne rsrc_DRVR_4__Sony_1E84_2C8
    clrb %d3
    lsrw #6,%d3
rsrc_DRVR_4__Sony_1E84_334:/* the checksum nibbles */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_334
    moveb %a2@(0x0,%d3:w),%a3@
    moveb %d5,%d3
    rolw #2,%d3
    moveb %d6,%d3
    rolw #2,%d3
    andib #63,%d0
rsrc_DRVR_4__Sony_1E84_348:/* (poll) */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_348
    moveb %a2@(0x0,%d0:w),%a3@
    andib #63,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_35A:/* second */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_35A
    moveb %a2@(0x0,%d1:w),%a3@
    moveb %d7,%d3
    lsrw #6,%d3
rsrc_DRVR_4__Sony_1E84_366:/* third */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_366
    moveb %a2@(0x0,%d3:w),%a3@
    andib #63,%d5
rsrc_DRVR_4__Sony_1E84_372:/* fourth */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_372
    moveb %a2@(0x0,%d5:w),%a3@
    andib #63,%d6
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_1E84_384:/* (poll) */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_384
    moveb %a2@(0x0,%d6:w),%a3@
    andib #63,%d7
rsrc_DRVR_4__Sony_1E84_390:/* then the bit-slip marks (ISM: S_5C44) */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_1E84_390
    moveb %a2@(0x0,%d7:w),%a3@
    jbsr rsrc_DRVR_4__Sony_5C44
    moveq #3,%d2
rsrc_DRVR_4__Sony_1E84_39E:/* trailer bytes; underrun? wrUnderrun (-74) */
    moveb %a4@,%d1
    jbpl rsrc_DRVR_4__Sony_1E84_39E
    moveb %a2@+,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    dbf %d2,rsrc_DRVR_4__Sony_1E84_39E
    moveq #0,%d0
    btst #6,%d1
    jbne rsrc_DRVR_4__Sony_1E84_3B8
    moveq #-74,%d0
rsrc_DRVR_4__Sony_1E84_3B8:/* back to read mode */
    tstb %a3@(512)
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_2244: /* (data) */
    .long   0xDEAAFFFF	| 4086E624
rsrc_DRVR_4__Sony_2248: /* GCR 6-to-8 nibble table (data) */
    .long   0x96979A9B, 0x9D9E9FA6	| 4086E628
    .long   0xA7ABACAD, 0xAEAFB2B3, 0xB4B5B6B7, 0xB9BABBBC	| 4086E630
    .long   0xBDBEBFCB, 0xCDCECFD3, 0xD6D7D9DA, 0xDBDCDDDE	| 4086E640
    .long   0xDFE5E6E7, 0xE9EAEBEC, 0xEDEEEFF2, 0xF3F4F5F6	| 4086E650
    .long   0xF7F9FAFB, 0xFCFDFEFF	| 4086E660
rsrc_DRVR_4__Sony_2288: /* format sector images (data) */
    .long   0xFF3FCFF3, 0xFCFFD5AA	| 4086E668
    .long   0x96000000, 0x0000DEAA, 0xFFFF3FCF, 0xF3FCFFD5	| 4086E670
    .long   0xAAAD0000	| 4086E680

rsrc_DRVR_4__Sony_22A4: /* Control format (csCode 6): format 400K/800K/1.4M by csParam (format number) */
    subaw #512,%sp
    jbsr rsrc_DRVR_4__Sony_4510
    movew %a0@(28),%d4
    jbeq rsrc_DRVR_4__Sony_22A4_3A
    moveq #2,%d3
    moveb %a1@(312),%d0
    andb %a1@(0x16,%d1:w),%d0
    jbpl rsrc_DRVR_4__Sony_22A4_24
    moveq #3,%d3
    tstb %a1@(0x18,%d1:w)
    jbpl rsrc_DRVR_4__Sony_22A4_24
    moveq #1,%d3
rsrc_DRVR_4__Sony_22A4_24:/* the format must be in range; MFM for the 1.4 MB one */
    moveq #-50,%d0
    cmpw %d3,%d4
    jbhi rsrc_DRVR_4__Sony_22A4_DC
    cmpiw #3,%d4
    seq %d0
    orb %a1@(0x18,%d1:w),%d0
    smi %a1@(0x17,%d1:w)
rsrc_DRVR_4__Sony_22A4_3A:/* SuperDrive: controller mode */
    tstb %a1@(312)
    jbpl rsrc_DRVR_4__Sony_22A4_48
    jbsr rsrc_DRVR_4__Sony_2716
    jbne rsrc_DRVR_4__Sony_22A4_DC
rsrc_DRVR_4__Sony_22A4_48:/* select; sides: single for format 1 on a double-sided drive */
    jbsr rsrc_DRVR_4__Sony_1336
    tstb %a1@(0x17,%d1:w)
    smi %a1@(50)
    jbmi rsrc_DRVR_4__Sony_22A4_68
    tstb %a1@(0x5,%d1:w)
    smi %a1@(50)
    jbpl rsrc_DRVR_4__Sony_22A4_68
    subqw #1,%d4
    jbne rsrc_DRVR_4__Sony_22A4_68
    clrb %a1@(50)
rsrc_DRVR_4__Sony_22A4_68:/* power up; write protected? wPrErr (-44) */
    tstb %a1@(50)
    sne %a1@(0x12,%d1:w)
    movew #8,%a1@(34)
    jbsr rsrc_DRVR_4__Sony_26A0
    moveq #6,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbmi rsrc_DRVR_4__Sony_22A4_86
    moveq #-44,%d0
    jbra rsrc_DRVR_4__Sony_22A4_DC
rsrc_DRVR_4__Sony_22A4_86:/* the address-field template for 12 sectors */
    moveal SonyVars,%a1
    moveal %a1@(28),%a0
    lea %pc@(rsrc_DRVR_4__Sony_2288),%a1
    moveq #11,%d0
rsrc_DRVR_4__Sony_22A4_94:/* each sector */
    moveq #26,%d1
    moveal %a1,%a2
rsrc_DRVR_4__Sony_22A4_98:/* copy */
    moveb %a2@+,%a0@+
    dbf %d1,rsrc_DRVR_4__Sony_22A4_98
    dbf %d0,rsrc_DRVR_4__Sony_22A4_94
    jbsr rsrc_DRVR_4__Sony_1010
    clrw %a1@(22)
rsrc_DRVR_4__Sony_22A4_AA:/* each track: seek, format (MFM: S_2C94, GCR: S_23A4) */
    jbsr rsrc_DRVR_4__Sony_2388
    jbne rsrc_DRVR_4__Sony_22A4_DC
    jbsr rsrc_DRVR_4__Sony_1010
    tstb %a1@(0x17,%d1:w)
    jbpl rsrc_DRVR_4__Sony_22A4_BE
    jbsr rsrc_DRVR_4__Sony_2C94
    jbra rsrc_DRVR_4__Sony_22A4_C2
rsrc_DRVR_4__Sony_22A4_BE:/* GCR */
    bsrw rsrc_DRVR_4__Sony_23A4
rsrc_DRVR_4__Sony_22A4_C2:/* next track (both sides), until 80; noErr */
    jbne rsrc_DRVR_4__Sony_22A4_DC
    jbsr rsrc_DRVR_4__Sony_1010
    bclr #3,%a1@(22)
    addqw #1,%a1@(22)
    cmpiw #80,%a1@(22)
    jblt rsrc_DRVR_4__Sony_22A4_AA
    moveq #0,%d0
rsrc_DRVR_4__Sony_22A4_DC:/* free the buffer, set the motor timer, finish */
    lea %sp@(512),%sp
    jbra rsrc_DRVR_4__Sony_B62

/* rsrc_DRVR_4__Sony_2388: seek to the requested track (through the TimeManager-driven completion loop 2686) and return its error */
rsrc_DRVR_4__Sony_2388:
    moveb %a1@(48),%a1@(49)
    movew %a1@(22),%d6
    jbsr rsrc_DRVR_4__Sony_2686
    jbsr rsrc_DRVR_4__Sony_1010
    movew %a1@(0x0,%d1:w),%d6
    jbmi rsrc_DRVR_4__Sony_2388_1A
    moveq #0,%d0
rsrc_DRVR_4__Sony_2388_1A:/* return */
    rts

/* rsrc_DRVR_4__Sony_23A4: write a GCR track (format): sector interleave from the format, write all sectors (243C), then read back and count the sectors to adjust the gap */
rsrc_DRVR_4__Sony_23A4:
    jbsr rsrc_DRVR_4__Sony_1010
    movew %a1@(22),%d6
    movew %d6,%d1
    bclr #11,%d1
    lsrw #4,%d1
    moveq #12,%d0
    subw %d1,%d0
    movew %d0,%a1@(32)
    jbsr rsrc_DRVR_4__Sony_2518
rsrc_DRVR_4__Sony_23A4_1C:/* write the track (S_243C) */
    jbsr rsrc_DRVR_4__Sony_243C
    jbeq rsrc_DRVR_4__Sony_23A4_2C
    jbsr rsrc_DRVR_4__Sony_267E
    andiw #-1793,%sr
    braw rsrc_DRVR_4__Sony_23A4_84
rsrc_DRVR_4__Sony_23A4_2C:/* read back an address field: the right sector? else -82 (spdAdjErr) */
    jbsr rsrc_DRVR_4__Sony_1D94
    jbmi rsrc_DRVR_4__Sony_23A4_38
    tstb %d2
    jbeq rsrc_DRVR_4__Sony_23A4_38
    moveq #-82,%d0
rsrc_DRVR_4__Sony_23A4_38:/* the gap: adjust from how many nibbles are left */
    jbsr rsrc_DRVR_4__Sony_267E
    andiw #-1793,%sr
    lea %a1@(34),%a0
    movew DskErr,%d0
    jbmi rsrc_DRVR_4__Sony_23A4_8E
    movel #1504,%d2
    subw %d0,%d2
    divuw #5,%d2
    movew #-83,DskErr
    subw %a0@,%d2
    jbmi rsrc_DRVR_4__Sony_23A4_8A
    extl %d2
    divuw %a1@(32),%d2
    jbeq rsrc_DRVR_4__Sony_23A4_6E
    subqw #1,%d2
    jbeq rsrc_DRVR_4__Sony_23A4_6E
    addqw #1,%a0@
rsrc_DRVR_4__Sony_23A4_6E:/* side 1 too (double-sided) */
    jbsr rsrc_DRVR_4__Sony_1010
    bset #3,%a1@(22)
    jbne rsrc_DRVR_4__Sony_23A4_80
    tstb %a1@(50)
    jbne rsrc_DRVR_4__Sony_23A4
rsrc_DRVR_4__Sony_23A4_80:/* noErr */
    clrw DskErr
rsrc_DRVR_4__Sony_23A4_84:/* return DskErr */
    movew DskErr,%d0
    rts
rsrc_DRVR_4__Sony_23A4_8A:/* right */
    addqw #1,%d2
    jbeq rsrc_DRVR_4__Sony_23A4_6E
rsrc_DRVR_4__Sony_23A4_8E:/* retry with a smaller gap */
    subqw #1,%a0@
    cmpiw #4,%a0@
    jblt rsrc_DRVR_4__Sony_23A4_84
    jbra rsrc_DRVR_4__Sony_23A4_1C

/* rsrc_DRVR_4__Sony_243C: write a whole GCR track: sync bytes, then for each sector address field and data field from the prepared buffer */
rsrc_DRVR_4__Sony_243C:
    movel %sp@+,DskRtnAdr
    moveq #1,%d0
    moveal SonyVars,%a1
    tstb %a1@(50)
    jbeq rsrc_DRVR_4__Sony_243C_18
    btst #11,%d6
    jbeq rsrc_DRVR_4__Sony_243C_18
    moveq #3,%d0
rsrc_DRVR_4__Sony_243C_18:/* select the side, prepare */
    jbsr rsrc_DRVR_4__Sony_102C
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_1D5E
    moveal IWM,%a4
    lea %a4@(6656),%a3
    moveal %a1@(28),%a0
    movew %a1@(32),%d0
    movew %a1@(34),%d1
    subqw #2,%d1
    movew #199,%d3
    jbsr rsrc_DRVR_4__Sony_4520
    tstb %a3@
    moveb %d3,%a4@(7680)
    lea %a4@(6144),%a4
rsrc_DRVR_4__Sony_243C_4A:/* sync groups */
    moveal %a1,%a2
    moveq #2,%d2
rsrc_DRVR_4__Sony_243C_4E:/* pairs */
    moveb %a2@+,%d4
rsrc_DRVR_4__Sony_243C_50:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_243C_50
    moveb %d4,%a3@
    moveb %a2@+,%d4
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_243C_5E:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_243C_5E
    moveb %d4,%a3@
    dbf %d2,rsrc_DRVR_4__Sony_243C_4E
    dbf %d3,rsrc_DRVR_4__Sony_243C_4A
rsrc_DRVR_4__Sony_243C_6C:/* each sector */
    movew %d1,%d3
rsrc_DRVR_4__Sony_243C_6E:/* sync bytes */
    moveal %a1,%a2
    moveq #5,%d2
rsrc_DRVR_4__Sony_243C_72:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_243C_72
    moveb %a2@+,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    dbf %d2,rsrc_DRVR_4__Sony_243C_72
    dbf %d3,rsrc_DRVR_4__Sony_243C_6E
    moveq #26,%d2
rsrc_DRVR_4__Sony_243C_88:/* the address field */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_243C_88
    moveb %a0@+,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    dbf %d2,rsrc_DRVR_4__Sony_243C_88
    movew #702,%d2
rsrc_DRVR_4__Sony_243C_9C:/* the data field filler (0x96) */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_243C_9C
    moveb #0x96,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    dbf %d2,rsrc_DRVR_4__Sony_243C_9C
    moveq #3,%d2
    addqw #8,%a2
rsrc_DRVR_4__Sony_243C_B2:/* the trailer; check for an underrun */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_243C_B2
    moveb %a2@+,%a3@
    dbf %d2,rsrc_DRVR_4__Sony_243C_B2
    subqw #1,%d0
    jbgt rsrc_DRVR_4__Sony_243C_6C
    jbsr rsrc_DRVR_4__Sony_4560
    btst #6,%d0
    jbne rsrc_DRVR_4__Sony_243C_CE
    moveq #-74,%d0
    jbra rsrc_DRVR_4__Sony_243C_D0
rsrc_DRVR_4__Sony_243C_CE:/* noErr */
    moveq #0,%d0
rsrc_DRVR_4__Sony_243C_D0:/* read mode; return */
    tstb %a3@(512)
    movel DskRtnAdr,%sp@-
    tstw %d0
    rts

/* rsrc_DRVR_4__Sony_2518: prepare the GCR address fields for a whole track in the buffer (track, sector order, side, format, checksum) */
rsrc_DRVR_4__Sony_2518:
    moveml %d0-%a1,%sp@-
    moveal SonyVars,%a1
    moveal %a1@(28),%a0
    moveq #2,%d3
    tstb %a1@(50)
    jbeq rsrc_DRVR_4__Sony_2518_16
    moveq #34,%d3
rsrc_DRVR_4__Sony_2518_16:/* build each address field: track, sector, side/format, checksum (NiblTbl) */
    moveal DiskVars_NiblTbl,%a1
    moveb %a1@(0x0,%d3:w),%d7
    moveb %d3,%d5
    moveq #63,%d3
    andb %d6,%d3
    moveb %a1@(0x0,%d3:w),%d2
    eorb %d3,%d5
    lsrw #6,%d6
    eorb %d6,%d5
    moveb %a1@(0x0,%d6:w),%d6
    movew %d0,%d1
    subqw #1,%d1
    lsrw #1,%d1
    addqw #1,%d1
    swap %d1
    clrw %d1
rsrc_DRVR_4__Sony_2518_3E:/* next sector */
    moveb %a1@(0x0,%d1:w),%d3
    moveq #0,%d4
    moveb %d5,%d4
    eorb %d1,%d4
    lea %a0@(9),%a0
    moveb %d2,%a0@+
    moveb %d3,%a0@+
    moveb %d6,%a0@+
    moveb %d7,%a0@+
    moveb %a1@(0x0,%d4:w),%a0@+
    lea %a0@(12),%a0
    moveb %d3,%a0@+
    addqw #1,%d1
    swap %d1
    subqw #1,%d0
    jbne rsrc_DRVR_4__Sony_2518_3E
    moveml %sp@+,%d0-%a1
    rts
rsrc_DRVR_4__Sony_2584: /* Control verify (csCode 5): read every sector of every track */
    subaw #512,%sp	| 4086E964
    jbsr rsrc_DRVR_4__Sony_4510	| 4086E968
    tstb %a1@(312)	| 4086E96C
    jbpl rsrc_DRVR_4__Sony_259A	| 4086E970
    jbsr rsrc_DRVR_4__Sony_2716	| 4086E972
    jbne rsrc_DRVR_4__Sony_22A4_DC	| 4086E976
rsrc_DRVR_4__Sony_259A: /* power up; 80 tracks, both sides */
    jbsr rsrc_DRVR_4__Sony_26A0
    moveq #4,%d2
    movew #127,%d4
    moveq #79,%d6
rsrc_DRVR_4__Sony_2518_8E:/* next track */
    lslw #1,%d4
    addqw #1,%d4
    moveq #15,%d3
rsrc_DRVR_4__Sony_2518_94:/* seek; MFM: S_2F0C, GCR: S_25E0 */
    moveml %d2-%d6,%sp@-
    jbsr rsrc_DRVR_4__Sony_2686
    moveml %sp@+,%d2-%d6
    jbsr rsrc_DRVR_4__Sony_1010
    movew %a1@(0x0,%d1:w),%d0
    jbmi rsrc_DRVR_4__Sony_2518_C4
    tstb %a1@(0x17,%d1:w)
    jbpl rsrc_DRVR_4__Sony_2518_B6
    jbsr rsrc_DRVR_4__Sony_2F0C
    jbra rsrc_DRVR_4__Sony_2518_B8
rsrc_DRVR_4__Sony_2518_B6:/* GCR */
    jbsr rsrc_DRVR_4__Sony_25E0
rsrc_DRVR_4__Sony_2518_B8:/* next */
    jbne rsrc_DRVR_4__Sony_2518_C4
    subqw #1,%d6
    dbf %d3,rsrc_DRVR_4__Sony_2518_94
    dbf %d2,rsrc_DRVR_4__Sony_2518_8E
rsrc_DRVR_4__Sony_2518_C4:/* finish */
    jbra rsrc_DRVR_4__Sony_22A4_DC

/* rsrc_DRVR_4__Sony_25E0: read a track into the track cache: every sector in the order it comes under the head, until all are in */
rsrc_DRVR_4__Sony_25E0:
    moveml %d2-%d6,%sp@-
    oriw #1792,%sr
    lea %a1@(34),%a0
    movew %d4,%a0@
    moveq #12,%d3
    subw %d2,%d3
    lslw #2,%d3
    movew %d3,%a0@(2)
    movel %a0@+,%a0@+
    bclr #3,%a1@(22)
rsrc_DRVR_4__Sony_25E0_20:/* read the next address field */
    movel %d1,%d6
    jbsr rsrc_DRVR_4__Sony_1D80
    jbpl rsrc_DRVR_4__Sony_25E0_30
    jbsr rsrc_DRVR_4__Sony_267E
    andiw #-1793,%sr
    jbra rsrc_DRVR_4__Sony_25E0_92
rsrc_DRVR_4__Sony_25E0_30:/* a sector still to read? */
    lea %a1@(32),%a0
    movew %d2,%a0@+
    movew %a0@+,%d0
    bclr %d2,%d0
    jbne rsrc_DRVR_4__Sony_25E0_48
    jbsr rsrc_DRVR_4__Sony_267E
    andiw #-1793,%sr
    lea %a1@(36),%a0
    jbra rsrc_DRVR_4__Sony_25E0_70
rsrc_DRVR_4__Sony_25E0_48:/* read it (RdData) */
    cmpib #31,%d3
    sgt %a1@(0x12,%d6:w)
    moveal %a1@(28),%a0
    clrb DskVerify
    jbsr rsrc_DRVR_4__Sony_1E84
    jbsr rsrc_DRVR_4__Sony_267E
    tstw %d0
    jbne rsrc_DRVR_4__Sony_25E0_92
    lea %a1@(32),%a0
    movew %a0@+,%d2
    movew %a0@,%d0
    bclr %d2,%d0
    movew %d0,%a0@+
    jbeq rsrc_DRVR_4__Sony_25E0_78
rsrc_DRVR_4__Sony_25E0_70:/* count down; all missing too long: verErr (-84) */
    subqw #1,%a0@
    jbne rsrc_DRVR_4__Sony_25E0_20
    moveq #-84,%d0
    jbra rsrc_DRVR_4__Sony_25E0_92
rsrc_DRVR_4__Sony_25E0_78:/* side 1 too */
    jbsr rsrc_DRVR_4__Sony_1010
    tstb %a1@(0x12,%d1:w)
    jbeq rsrc_DRVR_4__Sony_25E0_90
    bset #3,%a1@(22)
    jbne rsrc_DRVR_4__Sony_25E0_90
    addqw #2,%a0
    movel %a0@,%a0@-
    jbra rsrc_DRVR_4__Sony_25E0_20
rsrc_DRVR_4__Sony_25E0_90:/* noErr */
    moveq #0,%d0
rsrc_DRVR_4__Sony_25E0_92:/* return */
    andiw #-1793,%sr
    moveml %sp@+,%d2-%d6
    tstw %d0
    rts

/* rsrc_DRVR_4__Sony_267E: store d0 in DskErr and give the interrupts a turn (F56) */
rsrc_DRVR_4__Sony_267E:
    movew %d0,DskErr
    jbra rsrc_DRVR_4__Sony_F56

/* rsrc_DRVR_4__Sony_2686: run a routine (a0, default Seek) that completes asynchronously and wait for DskErr to be set */
rsrc_DRVR_4__Sony_2686:
    lea %pc@(rsrc_DRVR_4__Sony_10CE),%a0
rsrc_DRVR_4__Sony_2686_4:/* run it, wait for DskErr */
    clrb DskErr
    jbsr rsrc_DRVR_4__Sony_2698
rsrc_DRVR_4__Sony_2686_A:/* wait */
    tstb DskErr
    jbeq rsrc_DRVR_4__Sony_2686_A
    rts

/* rsrc_DRVR_4__Sony_2698: call it and mark it done */
rsrc_DRVR_4__Sony_2698:
    jsr %a0@
    st DskErr
    rts

/* rsrc_DRVR_4__Sony_26A0: power the drive up (12E0) and wait for it */
rsrc_DRVR_4__Sony_26A0:
    lea %pc@(rsrc_DRVR_4__Sony_12E0),%a0
    jbra rsrc_DRVR_4__Sony_2686_4

/* rsrc_DRVR_4__Sony_26A6: detect a SWIM: write and read back its parameter registers (0xF5, 0xF6, 0xF7); found: mark it (a1+312) and switch to ISM mode (S_5624) */
rsrc_DRVR_4__Sony_26A6:
    moveal SonyVars,%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal IWM,%a0
    tstb %a0@(5120)
    tstb %a0@(7168)
    tstb %a0@(4096)
    tstb %a0@(6656)
    moveq #87,%d0
    moveb %d0,%a0@(7680)
    moveb #23,%a0@(7680)
    moveb %d0,%a0@(7680)
    moveb %d0,%a0@(7680)
    moveq #-11,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne rsrc_DRVR_4__Sony_26A6_60
    moveq #-10,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne rsrc_DRVR_4__Sony_26A6_60
    moveq #-9,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne rsrc_DRVR_4__Sony_26A6_60
    st %a1@(312)
    moveb #0xf8,%a0@(3072)
rsrc_DRVR_4__Sony_26A6_60:/* back; ISM switch (S_5624) */
    tstb %a0@(7168)
    tstb %a0@(6144)
    tstb %a0@(4608)
    jbra rsrc_DRVR_4__Sony_5624

/* rsrc_DRVR_4__Sony_2716: choose the controller mode for the drive: SWIM in ISM mode for MFM disks, IWM mode (mode register, 125C) for GCR; check the switch worked */
rsrc_DRVR_4__Sony_2716:
    jbsr rsrc_DRVR_4__Sony_1010
    tstb %a1@(312)
    jbpl rsrc_DRVR_4__Sony_125C
    jbsr rsrc_DRVR_4__Sony_5708
    jbeq rsrc_DRVR_4__Sony_2716_8E
    moveq #1,%d2
rsrc_DRVR_4__Sony_2716_14:/* SWIM: check the parameter registers read back (0xF5..0xF7) */
    moveal IWM,%a0
    moveb #56,%a0@(3072)
    moveq #-11,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne rsrc_DRVR_4__Sony_2716_52
    moveq #-10,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne rsrc_DRVR_4__Sony_2716_52
    moveq #-9,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne rsrc_DRVR_4__Sony_2716_52
    tstb %a1@(0x17,%d1:w)
    jbmi rsrc_DRVR_4__Sony_2716_8E
    moveb #0xf8,%a0@(3072)
    tstb %a0@(7168)
rsrc_DRVR_4__Sony_2716_52:/* IWM mode: set the mode register; MFM drive? switch the SWIM to ISM mode */
    clrb %a1@(313)
    movel %d2,%sp@-
    jbsr rsrc_DRVR_4__Sony_125C
    movel %sp@+,%d2
    tstw %d0
    jbne rsrc_DRVR_4__Sony_2716_BA
    tstb %a1@(0x17,%d1:w)
    jbpl rsrc_DRVR_4__Sony_2716_BA
    tstb %a0@(7168)
    tstb %a0@(4096)
    tstb %a0@(6656)
    moveq #87,%d0
    moveb %d0,%a0@(7680)
    moveb #23,%a0@(7680)
    moveb %d0,%a0@(7680)
    moveb %d0,%a0@(7680)
    dbf %d2,rsrc_DRVR_4__Sony_2716_14
    jbra rsrc_DRVR_4__Sony_2716_B0
rsrc_DRVR_4__Sony_2716_8E:/* ISM mode: set it up, check the drive parameters */
    moveb #56,%a0@(3072)
    moveb #0xc0,%a0@(1024)
    moveq #32,%d0
    jbsr rsrc_DRVR_4__Sony_571E
    cmpb %a0@(6656),%d0
    jbne rsrc_DRVR_4__Sony_2716_AA
    jbsr rsrc_DRVR_4__Sony_27D6
    jbeq rsrc_DRVR_4__Sony_2716_B6
rsrc_DRVR_4__Sony_2716_AA:/* back to IWM */
    moveb #0xf8,%a0@(3072)
rsrc_DRVR_4__Sony_2716_B0:/* error -77 */
    tstb %a0@(7168)
    moveq #-77,%d0
rsrc_DRVR_4__Sony_2716_B6:/* ISM active flag */
    seq %a1@(313)
rsrc_DRVR_4__Sony_2716_BA:/* return */
    movew %sp@+,%sr
    tstw %d0
    rts

/* rsrc_DRVR_4__Sony_27D6: check that the drive's media/drive ID matches the expected one (ISM: compare the 16 parameter bytes, else load them); -77 when it fails */
rsrc_DRVR_4__Sony_27D6:
    jbsr rsrc_DRVR_4__Sony_5766
    moveal VIA,%a1
    lea %a1@(7680),%a1
    moveq #4,%d2
rsrc_DRVR_4__Sony_27D6_E:/* compare the parameter bytes */
    moveb #56,%a0@(3072)
    swap %d2
    moveq #15,%d0
rsrc_DRVR_4__Sony_27D6_18:/* each byte */
    moveb %a1@,%a1@
    moveb %a0@(5632),%d2
    cmpb %a2@(0x0,%d0:w),%d2
    dbne %d0,rsrc_DRVR_4__Sony_27D6_18
    jbne rsrc_DRVR_4__Sony_27D6_30
    moveal SonyVars,%a1
    moveq #0,%d0
    rts
rsrc_DRVR_4__Sony_27D6_30:/* load them */
    moveb #56,%a0@(3072)
    moveq #15,%d0
rsrc_DRVR_4__Sony_27D6_38:/* each byte */
    moveb %a1@,%a1@
    moveb %a2@(0x0,%d0:w),%a0@(1536)
    dbf %d0,rsrc_DRVR_4__Sony_27D6_38
    swap %d2
    dbf %d2,rsrc_DRVR_4__Sony_27D6_E
    moveal SonyVars,%a1
    moveq #-77,%d0
    rts
    .byte   0x00, 0x50, 0x00, 0x10	| 4086EC08
    oriw #32,%a0@	| 4086EC0C
    oriw #16,%a0@	| 4086EC10
    oriw #16,%a0@	| 4086EC14
rsrc_DRVR_4__Sony_2838: /* ISM parameter set, GCR (data) */
    movew %sp@,%a5@(7063)	| 4086EC18
    moveb %a1@+,%a4@-	| 4086EC1C
    movel %sp@(6939),%sp@-	| 4086EC1E
    moveb %a0@+,%d4	| 4086EC22
    movel %fp@(16664),%d7	| 4086EC24
rsrc_DRVR_4__Sony_2848: /* ISM parameter set, MFM (data) */
    movew %a0,%fp@	| 4086EC28
    movew %a0,%fp@	| 4086EC2A
    movew #15420,%d6	| 4086EC2C
    movew #15420,%d6	| 4086EC30
    movew #16410,%d6	| 4086EC34
    subqw #1,%sp	| 4086EC38
    movel %fp@(11863),%d7	| 4086EC3A
    swap %d1	| 4086EC3E
    addqb #2,%a0@-	| 4086EC40
    .byte   0x41, 0x52, 0x45, 0x20, 0x59, 0x4F, 0x55, 0x20, 0x53, 0x54, 0x41, 0x52, 0x49, 0x4E, 0x47, 0x20	| 4086EC42
    .byte   0x41, 0x54, 0x3F, 0x20, 0x20, 0x20	| 4086EC52
rsrc_DRVR_4__Sony_2848_30:/* format check, if bit 7 of (+312 and the drive's +0x16) is set: drive status 15 into +0x18 */
    moveb %a1@(312),%d0	| 4086EC58
    andb %a1@(0x16,%d1:w),%d0
    bpls rsrc_DRVR_4__Sony_2848_7E
    moveq #15,%d0
    bsrw rsrc_DRVR_4__Sony_106E
    spl %a1@(0x18,%d1:w)
    bsrs rsrc_DRVR_4__Sony_2848_82
    tstw %d0
    bmis rsrc_DRVR_4__Sony_2848_5E
    moveb %a1@(0x18,%d1:w),%a1@(0x17,%d1:w)
    bpls rsrc_DRVR_4__Sony_2848_7E
    /* wrong format: count it, gcrOnMFMErr (-400) */
    addqb #1,%a1@(0x3,%d1:w)
    movew #-400,%d0
    braw rsrc_DRVR_4__Sony_B62
rsrc_DRVR_4__Sony_2848_5E:
    st %a1@(0x17,%d1:w)	| 4086EC86
    bsrw rsrc_DRVR_4__Sony_1202
    bnes rsrc_DRVR_4__Sony_2848_78
    tstb %a1@(0x18,%d1:w)
    bmis rsrc_DRVR_4__Sony_2848_7E
    bsrs rsrc_DRVR_4__Sony_2848_82
    subib #34,%d3
    orw %d3,%d0
    beqs rsrc_DRVR_4__Sony_2848_7E
rsrc_DRVR_4__Sony_2848_78:
    moveb %a1@(0x18,%d1:w),%a1@(0x17,%d1:w)	| 4086ECA0
rsrc_DRVR_4__Sony_2848_7E:
    braw rsrc_DRVR_4__Sony_A88_26_62_3E	| 4086ECA6
rsrc_DRVR_4__Sony_2848_82:
    moveq #5,%d1	| 4086ECAA
rsrc_DRVR_4__Sony_28CC: /* read address fields until one comes (retry) */
    movew %d1,%sp@-
    movew %sr,%sp@-
    clrw %a1@(22)
    jbsr rsrc_DRVR_4__Sony_1D80
    jbsr rsrc_DRVR_4__Sony_F56
    movew %sp@+,%sr
    movew %sp@+,%d1
    tstw %d0
    dbpl %d1,rsrc_DRVR_4__Sony_28CC
    jbra rsrc_DRVR_4__Sony_1010
rsrc_DRVR_4__Sony_28EA: /* ISM AdrDisk: the phase register */
    moveb #0xf3,%a0@(2048)
    jbsr rsrc_DRVR_4__Sony_573E
    jbeq rsrc_DRVR_4__Sony_28FE
    bset #5,%a2@(7680)
    jbra rsrc_DRVR_4__Sony_2904
rsrc_DRVR_4__Sony_28FE: /* SEL clear */
    bclr #5,%a2@(7680)
rsrc_DRVR_4__Sony_2904: /* the register address through the table */
    moveb %pc@(rsrc_DRVR_4__Sony_290C,%d0:w),%a0@(2048)
    rts
rsrc_DRVR_4__Sony_290C: /* (data) */
    .long   0xF0F4F0F4	| 4086ECEC
    .long   0xF1F5F1F5, 0xF2F6F2F6, 0xF3F7F3F7, 0x53574321	| 4086ECF0
rsrc_DRVR_4__Sony_2920: /* ISM Sense: the status bit */
    btst #3,%a0@(7680)
    sne %d0
    tstb %d0
    rts
rsrc_DRVR_4__Sony_292C: /* ISM DiskCmd: pulse LSTRB through the phase register */
    movew %sr,%sp@-
    oriw #1792,%sr
    movel %d0,%sp@-
    moveq #-8,%d0
    orb %a0@(6144),%d0
    moveb %d0,%a0@(2048)
    moveb %a2@(7680),%a2@(7680)
    subqb #8,%d0
    moveb %d0,%a0@(2048)
    movel %sp@+,%d0
    movew %sp@+,%sr
    rts
rsrc_DRVR_4__Sony_2950: /* ISM DiskSel: drive 2 */
    cmpiw #74,%d1
    jbne rsrc_DRVR_4__Sony_2964
    moveb #4,%a0@(3072)
    moveb #0x82,%a0@(3584)
    rts
rsrc_DRVR_4__Sony_2964: /* drive 1 */
    moveb #0xf7,%a0@(2048)
    jbsr rsrc_DRVR_4__Sony_5758
    nop
    tstb %a1@(252)
    jbeq rsrc_DRVR_4__Sony_2984
    moveb #2,%a0@(3072)
    moveb #0x84,%a0@(3584)
    rts
rsrc_DRVR_4__Sony_2984: /* drive 3 */
    cmpiw #140,%d1
    jbne rsrc_DRVR_4__Sony_29DE
    moveb #2,%a0@(3072)
    moveb #0x84,%a0@(3584)
    moveq #2,%d0
rsrc_DRVR_4__Sony_2998: /* interrupts off */
    movew %sr,%sp@-
    oriw #1792,%sr
    jbra rsrc_DRVR_4__Sony_29D0
rsrc_DRVR_4__Sony_29A0: /* pulse */
    moveb #0xff,%a0@(2048)
    moveb %a2@(7680),%a2@(7680)
    moveb #0xf7,%a0@(2048)
    moveb %a2@(7680),%a2@(7680)
    moveb #0xf5,%a0@(2048)
    moveb %a2@(7680),%a2@(7680)
    moveb #0xf7,%a0@(2048)
    moveb %a2@(7680),%a2@(7680)
rsrc_DRVR_4__Sony_29D0: /* until the line answers */
    btst #3,%a0@(7680)
    dbeq %d0,rsrc_DRVR_4__Sony_29A0
    movew %sp@+,%sr
    rts
rsrc_DRVR_4__Sony_29DE: /* drive 4 */
    moveb #0x86,%a0@(3072)
    movew %a1@(18),%d0
    moveb %a2@(7680),%a2@(7680)
    moveb #0x84,%a0@(3584)
    subqw #3,%d0
    jbra rsrc_DRVR_4__Sony_2998
    moveq #90,%d2
    lslw #4,%d2
    moveq #9,%d3
    tstb %a1@(0x18,%d1:w)
    bpls rsrc_DRVR_4__Sony_29DE_2A
    addw %d2,%d2
    moveq #18,%d3
rsrc_DRVR_4__Sony_29DE_2A:/* the speed from the measured time: per-zone table */
    cmpl %d2,%d0
    bgew rsrc_DRVR_4__Sony_B62_12_3A
    divuw %d3,%d0
    lsrw #1,%d0
    scs %d6
    movew %d0,%d5
    swap %d0
    moveq #-1,%d2
    addqw #1,%d3
    braw rsrc_DRVR_4__Sony_B62_4E_36	| 4086EDFC
rsrc_DRVR_4__Sony_2A20: /* (data) */
    .byte   0xA1, 0xA1, 0xA1, 0xFE	| 4086EE00
rsrc_DRVR_4__Sony_2A24: /* MFM RdAddr through vector 0x680 */
    lea %pc@(rsrc_DRVR_4__Sony_2A20),%a2
    movel 0x680,%sp@-
    rts
    .short  0x21DF	| 4086EE0E
    .long   0x012441F8, 0x02FC4298, 0x42984298, 0x287801E0	| 4086EE10
    .long   0x47EC1E00	| 4086EE20
    lea %a4@(4608),%a4
    moveq #-67,%d0
    movew #20000,%d2
    jbra rsrc_DRVR_4__Sony_5766_A4
    .short  0x4E71, 0x4E71, 0x4E71, 0x4E71, 0x4E71, 0x4E71, 0x4E71	| 4086EE32
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 4086EE40
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 4086EE50
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71	| 4086EE60
rsrc_DRVR_4__Sony_2A8C: /* MFM ID field: track */
    moveq #60,%d0
rsrc_DRVR_4__Sony_2A8E: /* wait for the byte */
    tstb %a3@
    dbmi %d0,rsrc_DRVR_4__Sony_2A8E
    jbpl rsrc_DRVR_4__Sony_2ADE
    moveq #0,%d1
    moveb %a4@,%d1
    lea BufTgFNum,%a0
    moveb %d1,%a0@+
    moveq #60,%d0
rsrc_DRVR_4__Sony_2AA2: /* side */
    tstb %a3@
    dbmi %d0,rsrc_DRVR_4__Sony_2AA2
    jbpl rsrc_DRVR_4__Sony_2ADE
    moveb %a4@,%a0@+
    jbeq rsrc_DRVR_4__Sony_2AB2
    bset #11,%d1
rsrc_DRVR_4__Sony_2AB2: /* sector */
    moveq #60,%d0
    moveq #0,%d2
rsrc_DRVR_4__Sony_2AB6: /* wait */
    tstb %a3@
    dbmi %d0,rsrc_DRVR_4__Sony_2AB6
    jbpl rsrc_DRVR_4__Sony_2ADE
    moveb %a4@,%d2
    moveb %d2,%a0@+
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    moveq #60,%d0
    moveq #32,%d3
rsrc_DRVR_4__Sony_2ACC: /* size; then the CRC */
    tstb %a3@
    dbmi %d0,rsrc_DRVR_4__Sony_2ACC
    jbpl rsrc_DRVR_4__Sony_2ADE
    orb %a4@,%d3
    moveb %d3,%a0@+
    moveq #-69,%d0
    jbra rsrc_DRVR_4__Sony_2AE6_9A
rsrc_DRVR_4__Sony_2ADE: /* timeout */
    jbra rsrc_DRVR_4__Sony_2AE6_CE
rsrc_DRVR_4__Sony_2AE2: /* (data) */
    .short  0xA1A1, 0xA1FB	| 4086EEC2

/* rsrc_DRVR_4__Sony_2AE6: MFM RdData through vector 0x684: read a 512-byte MFM sector (ISM FIFO), with or without verify */
rsrc_DRVR_4__Sony_2AE6: /* MFM RdData through vector 0x684 */
    lea %pc@(rsrc_DRVR_4__Sony_2AE2),%a1
    movel 0x684,%sp@-
    rts
    .long   0x21DF0124, 0x383C0001	| 4086EED0
rsrc_DRVR_4__Sony_2AE6_12:/* no data mark: noDtaMkErr (-71) */
    tstb %a4@(512)
    moveb #24,%a4@(-1536)
    moveb #1,%a4@(-1024)
    moveb #1,%a4@(-1536)
    tstb %a4@(512)
    moveb #8,%a4@(-1024)
    moveq #-71,%d0
    jbra rsrc_DRVR_4__Sony_5766_76
rsrc_DRVR_4__Sony_2AE6_38:/* find the mark */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    tstb %a3@
    dbmi %d2,rsrc_DRVR_4__Sony_2AE6_38
    jbpl rsrc_DRVR_4__Sony_2AE6_74
    moveq #60,%d2
    moveb %a4@,%d5
    cmpb %a1@+,%d5
    dbne %d1,rsrc_DRVR_4__Sony_2AE6_38
    jbra rsrc_DRVR_4__Sony_5766_FA
    .short  0x4E71	| 4086EF1A
rsrc_DRVR_4__Sony_2AE6_56:/* verify? */
    jbne rsrc_DRVR_4__Sony_2AE6_76
rsrc_DRVR_4__Sony_2AE6_58:/* read: each byte from the FIFO */
    tstb %a3@
    jbmi rsrc_DRVR_4__Sony_2AE6_6C
    moveq #60,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2AE6_64:/* wait */
    tstb %a3@
    dbmi %d1,rsrc_DRVR_4__Sony_2AE6_64
    jbpl rsrc_DRVR_4__Sony_2AE6_74
rsrc_DRVR_4__Sony_2AE6_6C:/* store */
    moveb %a4@,%a0@+
    dbf %d4,rsrc_DRVR_4__Sony_2AE6_58
    jbra rsrc_DRVR_4__Sony_2AE6_94
rsrc_DRVR_4__Sony_2AE6_74:/* timeout */
    jbra rsrc_DRVR_4__Sony_2AE6_CE
rsrc_DRVR_4__Sony_2AE6_76:/* verify: compare each byte */
    tstb %a3@
    jbmi rsrc_DRVR_4__Sony_2AE6_8A
    moveq #60,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2AE6_82:/* wait */
    tstb %a3@
    dbmi %d1,rsrc_DRVR_4__Sony_2AE6_82
    jbpl rsrc_DRVR_4__Sony_2AE6_74
rsrc_DRVR_4__Sony_2AE6_8A:/* compare */
    moveb %a4@,%d2
    cmpb %a0@+,%d2
    dbne %d4,rsrc_DRVR_4__Sony_2AE6_76
    jbne rsrc_DRVR_4__Sony_2AE6_D2
rsrc_DRVR_4__Sony_2AE6_94:/* CRC */
    moveq #-72,%d0
    lea BufTgDate,%a0
rsrc_DRVR_4__Sony_2AE6_9A:/* bytes */
    moveq #60,%d4
rsrc_DRVR_4__Sony_2AE6_9C:/* wait */
    tstb %a3@
    dbmi %d4,rsrc_DRVR_4__Sony_2AE6_9C
    jbpl rsrc_DRVR_4__Sony_2AE6_CE
    moveb %a4@,%a0@+
    moveq #60,%d4
rsrc_DRVR_4__Sony_2AE6_A8:/* CRC check */
    tstb %a3@
    dbmi %d4,rsrc_DRVR_4__Sony_2AE6_A8
    jbsr rsrc_DRVR_4__Sony_5880
    moveb %a4@(512),%a0@+
    moveb %d5,%a0@
    andib #34,%d5
    jbne rsrc_DRVR_4__Sony_2AE6_C0
    moveq #0,%d0
rsrc_DRVR_4__Sony_2AE6_C0:/* return */
    moveb #24,%a4@(-1536)
    movel DskRtnAdr,%sp@-
    tstw %d0
    rts
rsrc_DRVR_4__Sony_2AE6_CE:/* noNybErr */
    moveq #-66,%d0
    jbra rsrc_DRVR_4__Sony_2AE6_C0
rsrc_DRVR_4__Sony_2AE6_D2:/* dataVerErr */
    moveq #-68,%d0
    jbra rsrc_DRVR_4__Sony_2AE6_C0
    lea %pc@(rsrc_DRVR_4__Sony_2AE2),%a2
    movel 0x688,%sp@-
    rts
    movel %sp@+,DskRtnAdr
    moveal IWM,%a4
    lea %a4@,%a3
    lea %a4@(7680),%a4
    moveb #0xf5,%a3@(2048)	| 4086EFB4
    tstb %a3@(5120)
    moveb #24,%a3@(3072)
    moveb #16,%a3@(3584)
    moveb #1,%a3@(3584)
    moveb #1,%a3@(3072)
    tstb %a3@(5120)
    movew #18808,%d0
    muluw TimeVIADB,%d0
    swap %d0
rsrc_DRVR_4__Sony_2AE6_D2_4C:/* MFM write: wait for the FIFO to be ready (the SCC polled) */
    btst #7,%a5@
    dbeq %d0,rsrc_DRVR_4__Sony_2AE6_D2_4C
    bnes rsrc_DRVR_4__Sony_2AE6_D2_5C
    moveb %fp@,%sp@-
    subqw #2,%d0
    bpls rsrc_DRVR_4__Sony_2AE6_D2_4C
rsrc_DRVR_4__Sony_2AE6_D2_5C:/* the sync zeros and the write start */
    moveq #9,%d0
    moveq #0,%d1
    moveb %d1,%a3@
    moveb %d1,%a3@
    moveb #8,%a3@(3584)
rsrc_DRVR_4__Sony_2AE6_13C:/* MFM write: sync zeros */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2AE6_142:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2AE6_142
    moveb %d1,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2AE6_13C
    moveq #2,%d0
rsrc_DRVR_4__Sony_2AE6_14E:/* the A1 marks */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2AE6_154:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2AE6_154
    moveb %a2@+,%a3@(512)
    dbf %d0,rsrc_DRVR_4__Sony_2AE6_14E
rsrc_DRVR_4__Sony_2AE6_160:/* the data mark */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2AE6_160
    moveb %a2@,%a3@
    movew #511,%d0
rsrc_DRVR_4__Sony_2AE6_16A:/* 512 bytes */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2AE6_170:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2AE6_170
    moveb %a0@+,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2AE6_16A
rsrc_DRVR_4__Sony_2AE6_17A:/* the CRC */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2AE6_17A
    moveb %d0,%a3@(1024)
    moveq #3,%d0
rsrc_DRVR_4__Sony_2AE6_184:/* the gap */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2AE6_18A:/* write; underrun? */
    moveb %a4@,%d2
    jbpl rsrc_DRVR_4__Sony_2AE6_18A
    moveb #78,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2AE6_184
    moveq #0,%d0
    btst #5,%d2
    jbeq rsrc_DRVR_4__Sony_2AE6_1A0
    moveq #-74,%d0
rsrc_DRVR_4__Sony_2AE6_1A0:/* read mode; return */
    moveb #24,%a3@(3072)
    movel DskRtnAdr,%sp@-
    tstw %d0
    rts

/* rsrc_DRVR_4__Sony_2C94: format a track: GCR or MFM, both sides; d2 = sectors per track; then mark side 1 */
rsrc_DRVR_4__Sony_2C94:
    jbsr rsrc_DRVR_4__Sony_1010
    movew %a1@(22),%d4
    moveq #0,%d5
    bclr #11,%d4
    jbeq rsrc_DRVR_4__Sony_2C94_24
    moveq #1,%d5
    moveq #0,%d2
    movew TimeDBRA,%d2
    movel %d2,%d0
    addl %d2,%d0
    addl %d2,%d0
    lsrl #2,%d0
rsrc_DRVR_4__Sony_2C94_20:  /* count down (loop) */
    dbf %d0,rsrc_DRVR_4__Sony_2C94_20
rsrc_DRVR_4__Sony_2C94_24:/* 9 or 18 sectors per track */
    moveq #8,%d2
    moveb %a1@(0x18,%d1:w),%d0
    jbpl rsrc_DRVR_4__Sony_2C94_32
    moveq #17,%d2
    bset #31,%d2
rsrc_DRVR_4__Sony_2C94_32:/* write the track (S_2CE6); next side */
    jbsr rsrc_DRVR_4__Sony_2CE6
    jbsr rsrc_DRVR_4__Sony_267E
    andiw #-1793,%sr
    movew DskErr,%d0
    jbne rsrc_DRVR_4__Sony_2C94_50
    jbsr rsrc_DRVR_4__Sony_1010
    bset #3,%a1@(22)
    jbeq rsrc_DRVR_4__Sony_2C94
    moveq #0,%d0
rsrc_DRVR_4__Sony_2C94_50:  /* return */
    rts

/* rsrc_DRVR_4__Sony_2CE6: MFM format: write a whole MFM track (gaps 4E, sync, ID and data fields) through the ISM */
rsrc_DRVR_4__Sony_2CE6:
    movel %sp@+,DskRtnAdr
    moveq #1,%d0
    tstw %d5
    jbeq rsrc_DRVR_4__Sony_2CE6_C
    moveq #3,%d0
rsrc_DRVR_4__Sony_2CE6_C:/* select the side */
    jbsr rsrc_DRVR_4__Sony_102C
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_1D5E
    moveal IWM,%a4
    lea %a4@,%a3
    lea %a4@(7680),%a4
    moveb #24,%a3@(3072)
    moveb #16,%a3@(3584)
    moveb #1,%a3@(3584)
    jbsr rsrc_DRVR_4__Sony_43FC
    nop
    moveq #78,%d1
    moveb %d1,%a3@
    moveb %d1,%a3@
    moveb #8,%a3@(3584)
    movew #13500,%d3
rsrc_DRVR_4__Sony_2CE6_48:/* wait for the index pulse */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_4E:/* write filler until the index */
    moveb %a4@,%d0
    jbpl rsrc_DRVR_4__Sony_2CE6_4E
    moveb %d1,%a3@
    btst #3,%d0
    jbeq rsrc_DRVR_4__Sony_2CE6_62
    dbf %d3,rsrc_DRVR_4__Sony_2CE6_48
    jbra rsrc_DRVR_4__Sony_2CE6_20A
rsrc_DRVR_4__Sony_2CE6_62:/* wait */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_68:/* index gone */
    moveb %a4@,%d0
    jbpl rsrc_DRVR_4__Sony_2CE6_68
    moveb %d1,%a3@
    btst #3,%d0
    jbne rsrc_DRVR_4__Sony_2CE6_7C
    dbf %d3,rsrc_DRVR_4__Sony_2CE6_62
    jbra rsrc_DRVR_4__Sony_2CE6_20A
rsrc_DRVR_4__Sony_2CE6_7C:/* gap 4a (0x4E x 80) */
    moveb #0xf5,%a3@(2048)
    moveq #78,%d0
rsrc_DRVR_4__Sony_2CE6_84:/* write */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_8A:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_8A
    moveb %d1,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_84
    moveq #11,%d0
    moveq #0,%d1
rsrc_DRVR_4__Sony_2CE6_98:/* sync zeros */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_9E:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_9E
    moveb %d1,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_98
    moveq #2,%d0
rsrc_DRVR_4__Sony_2CE6_AA:/* the index mark (C2 C2 C2 FC) */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_B0:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_B0
    moveb #0xc2,%a3@(512)
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_AA
rsrc_DRVR_4__Sony_2CE6_BE:/* FC */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_BE
    moveb #0xfc,%a3@
    moveq #49,%d0
rsrc_DRVR_4__Sony_2CE6_C8:/* gap 1 */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_CE:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_CE
    moveb #78,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_C8
    moveq #1,%d6
    jbra rsrc_DRVR_4__Sony_2CE6_F8
rsrc_DRVR_4__Sony_2CE6_DE:/* each sector: gap 3 */
    moveq #79,%d0
    tstl %d2
    jbpl rsrc_DRVR_4__Sony_2CE6_E6
    moveq #100,%d0
rsrc_DRVR_4__Sony_2CE6_E6:/* write */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_EC:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_EC
    moveb #78,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_E6
rsrc_DRVR_4__Sony_2CE6_F8:/* sync */
    moveq #11,%d0
    moveq #0,%d1
rsrc_DRVR_4__Sony_2CE6_FC:/* write */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_102:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_102
    moveb %d1,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_FC
    moveq #2,%d0
rsrc_DRVR_4__Sony_2CE6_10E:/* ID mark (A1 A1 A1 FE) */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_114:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_114
    moveb #0xa1,%a3@(512)
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_10E
rsrc_DRVR_4__Sony_2CE6_122:/* FE */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_122
    moveb #0xfe,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_130:/* track */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_130
    moveb %d4,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_13C:/* side */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_13C
    moveb %d5,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_148:/* sector */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_148
    moveb %d6,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_154:/* size (2 = 512) */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_154
    moveb #2,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_162:/* CRC */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_162
    moveb %d0,%a3@(1024)
    moveq #21,%d0
rsrc_DRVR_4__Sony_2CE6_16C:/* gap 2 */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_172:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_172
    moveb #78,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_16C
    moveq #11,%d0
    moveq #0,%d1
rsrc_DRVR_4__Sony_2CE6_182:/* sync */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_188:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_188
    moveb %d1,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_182
    moveq #2,%d0
rsrc_DRVR_4__Sony_2CE6_194:/* data mark (A1 A1 A1 FB) */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_19A:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_19A
    moveb #0xa1,%a3@(512)
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_194
rsrc_DRVR_4__Sony_2CE6_1A8:/* FB */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_1A8
    moveb #0xfb,%a3@
    movew #511,%d0
rsrc_DRVR_4__Sony_2CE6_1B4:/* 512 bytes of F6 */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_1BA:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_1BA
    moveb #0xf6,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_2CE6_1B4
rsrc_DRVR_4__Sony_2CE6_1C6:/* CRC; next sector; then gap 4b to the index */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_2CE6_1C6
    moveb %d0,%a3@(1024)
    addqw #1,%d6
    dbf %d2,rsrc_DRVR_4__Sony_2CE6_DE
    moveq #4,%d0
    moveq #78,%d1
    movew #1000,%d3
    tstw %d5
    jbne rsrc_DRVR_4__Sony_2CE6_1EA
    moveq #4,%d3
    jbra rsrc_DRVR_4__Sony_2CE6_1EA
rsrc_DRVR_4__Sony_2CE6_1E4:/* filler */
    moveb #0xf4,%a3@(2048)
rsrc_DRVR_4__Sony_2CE6_1EA:/* wait */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_2CE6_1F0:/* until the index */
    moveb %a4@,%d2
    jbpl rsrc_DRVR_4__Sony_2CE6_1F0
    moveb %d1,%a3@
    subqw #1,%d0
    jbgt rsrc_DRVR_4__Sony_2CE6_202
    jbeq rsrc_DRVR_4__Sony_2CE6_1E4
    btst #3,%d2
    jbne rsrc_DRVR_4__Sony_2CE6_20E
rsrc_DRVR_4__Sony_2CE6_202:/* timeout? */
    dbf %d3,rsrc_DRVR_4__Sony_2CE6_1EA
    tstw %d5
    jbeq rsrc_DRVR_4__Sony_2CE6_20E
rsrc_DRVR_4__Sony_2CE6_20A:/* no index: -83 */
    moveq #-83,%d0
    jbra rsrc_DRVR_4__Sony_2CE6_218
rsrc_DRVR_4__Sony_2CE6_20E:/* underrun? */
    moveq #0,%d0
    btst #5,%d2
    jbeq rsrc_DRVR_4__Sony_2CE6_218
    moveq #-74,%d0
rsrc_DRVR_4__Sony_2CE6_218:/* read mode; return */
    moveb #24,%a3@(3072)
    movel DskRtnAdr,%sp@-
    tstw %d0
    rts

/* rsrc_DRVR_4__Sony_2F0C: verify a formatted MFM track: read each sector (18 or 36 per track) and tick it off; -84 (verErr) when some are missing */
rsrc_DRVR_4__Sony_2F0C:
    moveml %d2-%d7,%sp@-
    oriw #1792,%sr
    movew %d6,%a1@(22)
rsrc_DRVR_4__Sony_2F0C_C:/* 18 or 36 sectors to see (720K / 1440K) */
    moveq #36,%d7
    movel #1022,%d6
    tstb %a1@(0x18,%d1:w)
    jbpl rsrc_DRVR_4__Sony_2F0C_22
    moveq #72,%d7
    movel #524286,%d6
rsrc_DRVR_4__Sony_2F0C_22:/* read an ID: on this track and not yet seen? read the sector */
    jbsr rsrc_DRVR_4__Sony_1D80
    jbne rsrc_DRVR_4__Sony_2F0C_44
    btst %d2,%d6
    jbeq rsrc_DRVR_4__Sony_2F0C_44
    cmpw %a1@(22),%d1
    jbne rsrc_DRVR_4__Sony_2F0C_44
    movew %d2,%d3
    moveal %a1@(28),%a0
    clrb DskVerify
    jbsr rsrc_DRVR_4__Sony_2AE6
    jbne rsrc_DRVR_4__Sony_2F0C_44
    bclr %d3,%d6
rsrc_DRVR_4__Sony_2F0C_44:/* next; all seen? else verErr */
    jbsr rsrc_DRVR_4__Sony_267E
    tstl %d6
    dbeq %d7,rsrc_DRVR_4__Sony_2F0C_22
    jbeq rsrc_DRVR_4__Sony_2F0C_54
    moveq #-84,%d0
    jbra rsrc_DRVR_4__Sony_2F0C_5C
rsrc_DRVR_4__Sony_2F0C_54:/* then side 1 */
    bset #3,%a1@(22)
    jbeq rsrc_DRVR_4__Sony_2F0C_C
rsrc_DRVR_4__Sony_2F0C_5C:/* interrupts on, return */
    andiw #-1793,%sr
    moveml %sp@+,%d2-%d7
    tstw %d0
    rts
SONY_STS_csDV:          /* Status: the driver version (0x410) */
    movew #1040,%a0@	| 4086F354
    moveq #0,%d0	| 4086F358
    jbra rsrc_DRVR_4__Sony_784	| 4086F35A
SONY_STS_csSC:          /* Status: the track cache state */
    moveb %a1@(332),%a0@	| 4086F35E
    moveq #0,%d0	| 4086F362
    jbra rsrc_DRVR_4__Sony_784	| 4086F364
SONY_CTL_csSC:          /* Control: format with the track cache image (csParam: the format and its buffer) */
    jbne rsrc_DRVR_4__Sony_784	| 4086F368
    subaw #512,%sp	| 4086F36C
    jbsr rsrc_DRVR_4__Sony_437C	| 4086F370
    lea %a0@(30),%a0	| 4086F374
    movel %a0,%a1@(328)	| 4086F378
    movew %a0@-,%d4	| 4086F37C
    jbeq rsrc_DRVR_4__Sony_2FCC	| 4086F37E
    moveq #2,%d3
    moveb %a1@(312),%d0
    andb %a1@(0x16,%d1:w),%d0
    jbpl rsrc_DRVR_4__Sony_2FB6
    moveq #3,%d3
    tstb %a1@(0x18,%d1:w)
    jbpl rsrc_DRVR_4__Sony_2FB6
    moveq #1,%d3
rsrc_DRVR_4__Sony_2FB6: /* the format must be in range; MFM for 1.4 MB */
    moveq #-50,%d0
    cmpw %d3,%d4
    jbhi rsrc_DRVR_4__Sony_306E
    cmpiw #3,%d4
    seq %d0
    orb %a1@(0x18,%d1:w),%d0
    smi %a1@(0x17,%d1:w)
rsrc_DRVR_4__Sony_2FCC: /* SuperDrive: controller mode */
    tstb %a1@(312)
    jbpl rsrc_DRVR_4__Sony_2FDA
    jbsr rsrc_DRVR_4__Sony_2716
    jbne rsrc_DRVR_4__Sony_306E
rsrc_DRVR_4__Sony_2FDA: /* select; sides */
    jbsr rsrc_DRVR_4__Sony_1336
    tstb %a1@(0x17,%d1:w)
    smi %a1@(50)
    jbmi rsrc_DRVR_4__Sony_2FFA
    tstb %a1@(0x5,%d1:w)
    smi %a1@(50)
    jbpl rsrc_DRVR_4__Sony_2FFA
    subqw #1,%d4
    jbne rsrc_DRVR_4__Sony_2FFA
    clrb %a1@(50)
rsrc_DRVR_4__Sony_2FFA: /* power up; write protected? wPrErr */
    tstb %a1@(50)
    sne %a1@(0x12,%d1:w)
    movew #8,%a1@(34)
    jbsr rsrc_DRVR_4__Sony_26A0
    moveq #6,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbmi rsrc_DRVR_4__Sony_3018
    moveq #-44,%d0
    jbra rsrc_DRVR_4__Sony_306E
rsrc_DRVR_4__Sony_3018: /* the address-field template */
    moveal SonyVars,%a1
    moveal %a1@(28),%a0
    moveq #11,%d0
rsrc_DRVR_4__Sony_3022: /* each sector */
    moveq #35,%d1
    lea %pc@(rsrc_DRVR_4__Sony_2288),%a1
rsrc_DRVR_4__Sony_3028: /* copy */
    moveb %a1@+,%a0@+
    dbf %d1,rsrc_DRVR_4__Sony_3028
    dbf %d0,rsrc_DRVR_4__Sony_3022
    jbsr rsrc_DRVR_4__Sony_1010
    clrw %a1@(22)
rsrc_DRVR_4__Sony_303A: /* each track: seek, write (MFM: S_33B6, GCR: S_3076) */
    jbsr rsrc_DRVR_4__Sony_2388
    jbne rsrc_DRVR_4__Sony_306E
    jbsr rsrc_DRVR_4__Sony_1010
    tstb %a1@(0x17,%d1:w)
    jbpl rsrc_DRVR_4__Sony_3050
    jbsr rsrc_DRVR_4__Sony_33B6
    jbra rsrc_DRVR_4__Sony_3054
rsrc_DRVR_4__Sony_3050: /* GCR */
    bsrw rsrc_DRVR_4__Sony_3076
rsrc_DRVR_4__Sony_3054: /* next track, until 80 */
    jbne rsrc_DRVR_4__Sony_306E
    jbsr rsrc_DRVR_4__Sony_1010
    bclr #3,%a1@(22)
    addqw #1,%a1@(22)
    cmpiw #80,%a1@(22)
    jblt rsrc_DRVR_4__Sony_303A
    moveq #0,%d0
rsrc_DRVR_4__Sony_306E: /* free the buffer, finish */
    lea %sp@(512),%sp
    jbra rsrc_DRVR_4__Sony_B62

/* rsrc_DRVR_4__Sony_3076: write a GCR track from the track cache (format/verify with the cache), then verify */
rsrc_DRVR_4__Sony_3076:
    jbsr rsrc_DRVR_4__Sony_1010
    movew %a1@(22),%d6
    jbsr rsrc_DRVR_4__Sony_3310
rsrc_DRVR_4__Sony_3076_C:/* write the track from the cache (S_3196) */
    jbsr rsrc_DRVR_4__Sony_3196
    jbeq rsrc_DRVR_4__Sony_3076_1A
    andiw #-1793,%sr
    braw rsrc_DRVR_4__Sony_3076_98
rsrc_DRVR_4__Sony_3076_1A:/* read back an address field: the right sector? else -82 */
    jbsr rsrc_DRVR_4__Sony_1010
    jbsr rsrc_DRVR_4__Sony_1D80
    jbmi rsrc_DRVR_4__Sony_3076_2A
    tstb %d2
    jbeq rsrc_DRVR_4__Sony_3076_2A
    moveq #-82,%d0
rsrc_DRVR_4__Sony_3076_2A:/* the gap: adjust */
    jbsr rsrc_DRVR_4__Sony_267E
    andiw #-1793,%sr
    lea %a1@(34),%a0
    movew DskErr,%d0
    jbmi rsrc_DRVR_4__Sony_3076_A0
    movel #1504,%d2
    subw %d0,%d2
    divuw #5,%d2
    moveq #-83,%d0
    subw %a0@,%d2
    jbmi rsrc_DRVR_4__Sony_3076_9C
    extl %d2
    divuw %a1@(32),%d2
    jbeq rsrc_DRVR_4__Sony_3076_5C
    subqw #1,%d2
    jbeq rsrc_DRVR_4__Sony_3076_5C
    addqw #1,%a0@
rsrc_DRVR_4__Sony_3076_5C:/* verify against the cache if asked */
    jbsr rsrc_DRVR_4__Sony_1010
    moveal %a1@(328),%a0
    tstb %a0@(9)
    jbeq rsrc_DRVR_4__Sony_3076_72
    jbsr rsrc_DRVR_4__Sony_3122
    jbne rsrc_DRVR_4__Sony_3076_98
    moveal %a1@(328),%a0
rsrc_DRVR_4__Sony_3076_72:/* advance the buffer pointers */
    moveq #0,%d1
    movew %a1@(32),%d1
    lsll #2,%d1
    movel %d1,%d2
    addl %d1,%d1
    addl %d1,%d2
    lsll #6,%d1
    addl %d1,%a0@+
    addl %d2,%a0@+
    bset #3,%a1@(22)
    jbne rsrc_DRVR_4__Sony_3076_96
    tstb %a1@(50)
    jbne rsrc_DRVR_4__Sony_3076
rsrc_DRVR_4__Sony_3076_96:/* noErr */
    moveq #0,%d0
rsrc_DRVR_4__Sony_3076_98:/* return */
    tstw %d0
    rts
rsrc_DRVR_4__Sony_3076_9C:/* right */
    addqw #1,%d2
    jbeq rsrc_DRVR_4__Sony_3076_5C
rsrc_DRVR_4__Sony_3076_A0:/* retry with a smaller gap */
    subqw #1,%a0@
    cmpiw #4,%a0@
    jblt rsrc_DRVR_4__Sony_3076_98
    jbra rsrc_DRVR_4__Sony_3076_C

/* rsrc_DRVR_4__Sony_3122: verify the GCR track just written against the cache */
rsrc_DRVR_4__Sony_3122:
    oriw #1792,%sr
    lea %a1@(38),%a0
    moveq #0,%d0
    moveb %a1@(23),%d0
    lsrw #4,%d0
    movew #4095,%d2
    lsrw %d0,%d2
    movew %d2,%a0@+
    moveq #12,%d2
    subw %d0,%d2
    lslw #2,%d2
    movew %d2,%a0@
rsrc_DRVR_4__Sony_3122_20:/* read each sector and compare (DskVerify) */
    jbsr rsrc_DRVR_4__Sony_1D80
    jbmi rsrc_DRVR_4__Sony_3122_56
    movew %d2,%a1@(36)
    cmpw %a1@(22),%d1
    jbne rsrc_DRVR_4__Sony_3122_56
    moveal %a1@(328),%a0
    moveal %a0@,%a0
    moveq #9,%d0
    lslw %d0,%d2
    addaw %d2,%a0
    st DskVerify
    jbsr rsrc_DRVR_4__Sony_1E84
    jbmi rsrc_DRVR_4__Sony_3122_56
    jbsr rsrc_DRVR_4__Sony_1010
    lea %a1@(36),%a0
    movew %a0@+,%d2
    movew %a0@,%d3
    bclr %d2,%d3
    movew %d3,%a0@
rsrc_DRVR_4__Sony_3122_56:/* next; too many tries: verErr (-84) */
    jbsr rsrc_DRVR_4__Sony_267E
    lea %a1@(38),%a0
    tstw %a0@+
    jbeq rsrc_DRVR_4__Sony_3122_6A
    subqw #1,%a0@
    jbne rsrc_DRVR_4__Sony_3122_20
    moveq #-84,%d0
    jbra rsrc_DRVR_4__Sony_3122_6C
rsrc_DRVR_4__Sony_3122_6A:/* noErr */
    moveq #0,%d0
rsrc_DRVR_4__Sony_3122_6C:/* return */
    andiw #-1793,%sr
    tstw %d0
    rts

/* rsrc_DRVR_4__Sony_3196: GCR track write through the cache buffer */
rsrc_DRVR_4__Sony_3196:
    oriw #1792,%sr
    moveq #1,%d0
    moveal SonyVars,%a1
    btst #3,%a1@(22)
    jbeq rsrc_DRVR_4__Sony_3196_14
    moveq #3,%d0
rsrc_DRVR_4__Sony_3196_14:/* select the side; write the track with interrupts off */
    jbsr rsrc_DRVR_4__Sony_102C
    moveal IWM,%a4
    lea %a4@(6656),%a3
    lea %a4@(6144),%a4
    moveal %a1@(28),%a5
    lea %pc@(rsrc_DRVR_4__Sony_372C),%a2
    movew %a1@(32),%sp@-
    movew %a1@(34),%d1
    subqw #2,%d1
    movew %d1,DskErr
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d2
    moveq #0,%d3
    movew #199,%d6
    nop
    jbsr rsrc_DRVR_4__Sony_438C
rsrc_DRVR_4__Sony_3196_4C:/* sync groups */
    lea %pc@(rsrc_DRVR_4__Sony_2288),%fp
    moveq #2,%d7
rsrc_DRVR_4__Sony_3196_52:/* pairs */
    moveb %fp@+,%d4
rsrc_DRVR_4__Sony_3196_54:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_54
    moveb %d4,%a3@
    moveb %fp@+,%d4
rsrc_DRVR_4__Sony_3196_5C:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_5C
    moveb %d4,%a3@
    dbf %d7,rsrc_DRVR_4__Sony_3196_52
    dbf %d6,rsrc_DRVR_4__Sony_3196_4C
rsrc_DRVR_4__Sony_3196_6A:/* each sector */
    movew DskErr,%d6
rsrc_DRVR_4__Sony_3196_6E:/* sync bytes */
    lea %pc@(rsrc_DRVR_4__Sony_2288),%fp
    moveq #5,%d7
rsrc_DRVR_4__Sony_3196_74:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_74
    moveb %fp@+,%a3@
    dbf %d7,rsrc_DRVR_4__Sony_3196_74
    dbf %d6,rsrc_DRVR_4__Sony_3196_6E
    moveq #22,%d7
rsrc_DRVR_4__Sony_3196_84:/* the address field */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_84
    moveb %a5@+,%a3@
    dbf %d7,rsrc_DRVR_4__Sony_3196_84
    moveb %a5@+,%d0
    moveb %a5@+,%d3
    moveb %a5@+,%d1
    moveb %a5@+,%d2
rsrc_DRVR_4__Sony_3196_96:/* the data mark and sector number */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_96
    moveb %d0,%a3@
    addqw #1,%a5
    moveal %a5@+,%a1
    moveal %a5@+,%a0
    movel #33619977,%d4
rsrc_DRVR_4__Sony_3196_A8:/* tags then data, 6-and-2 encoded */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_A8
    moveb %d3,%a3@
    moveq #0,%d5
    moveq #0,%d6
    moveq #0,%d7
    jbra rsrc_DRVR_4__Sony_3196_D8
rsrc_DRVR_4__Sony_3196_B6:/* the data buffer */
    moveal %a0,%a1
rsrc_DRVR_4__Sony_3196_B8:/* 3 bytes to 4 nibbles */
    addxb %d2,%d7
    eorb %d6,%d2
    moveb %d2,%d3
    lsrw #6,%d3
rsrc_DRVR_4__Sony_3196_C0:/* high bits */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_C0
    moveb %a2@(0x0,%d3:w),%a3@
    subqw #3,%d4
    moveb %d7,%d3
    addb %d7,%d3
    rolb #1,%d7
rsrc_DRVR_4__Sony_3196_D0:/* first */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_D0
    moveb %a2@(0x0,%d0:w),%a3@
rsrc_DRVR_4__Sony_3196_D8:/* next 3 bytes */
    moveb %a1@+,%d0
    addxb %d0,%d5
    eorb %d7,%d0
    moveb %d0,%d3
    rolw #2,%d3
rsrc_DRVR_4__Sony_3196_E2:/* second */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_E2
    moveb %a2@(0x0,%d1:w),%a3@
    moveb %a1@+,%d1
    addxb %d1,%d6
    eorb %d5,%d1
    moveb %d1,%d3
    rolw #2,%d3
rsrc_DRVR_4__Sony_3196_F4:/* third; more? */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_F4
    moveb %a2@(0x0,%d2:w),%a3@
    moveb %a1@+,%d2
    tstw %d4
    jbne rsrc_DRVR_4__Sony_3196_B8
    swap %d4
    jbne rsrc_DRVR_4__Sony_3196_B6
    clrb %d3
    lsrw #6,%d3
rsrc_DRVR_4__Sony_3196_10A:/* checksum */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_10A
    moveb %a2@(0x0,%d3:w),%a3@
    moveb %d5,%d3
    rolw #2,%d3
    moveb %d6,%d3
    rolw #2,%d3
rsrc_DRVR_4__Sony_3196_11A:/* second */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_11A
    moveb %a2@(0x0,%d0:w),%a3@
rsrc_DRVR_4__Sony_3196_122:/* third */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_122
    moveb %a2@(0x0,%d1:w),%a3@
    moveb %d7,%d3
    lsrw #6,%d3
rsrc_DRVR_4__Sony_3196_12E:/* fourth */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_12E
    moveb %a2@(0x0,%d3:w),%a3@
rsrc_DRVR_4__Sony_3196_136:/* (checksum bytes) */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_136
    moveb %a2@(0x0,%d5:w),%a3@
rsrc_DRVR_4__Sony_3196_13E:/* (checksum bytes) */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_13E
    moveb %a2@(0x0,%d6:w),%a3@
rsrc_DRVR_4__Sony_3196_146:/* the bit-slip marks */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3196_146
    moveb %a2@(0x0,%d7:w),%a3@
    moveq #3,%d7
    addqw #8,%fp
rsrc_DRVR_4__Sony_3196_152:/* next sector; underrun check */
    moveb %a4@,%d1
    jbpl rsrc_DRVR_4__Sony_3196_152
    moveb %fp@+,%a3@
    dbf %d7,rsrc_DRVR_4__Sony_3196_152
    subqw #1,%sp@
    jbgt rsrc_DRVR_4__Sony_3196_6A
    addqw #2,%sp
    moveq #0,%d0
    jbsr rsrc_DRVR_4__Sony_43C8
    jbne rsrc_DRVR_4__Sony_3196_16E
    moveq #-74,%d0
rsrc_DRVR_4__Sony_3196_16E:/* read mode; DskErr */
    tstb %a4@(1024)
    tstb %a4@
    movew %d0,DskErr
    rts

/* rsrc_DRVR_4__Sony_3310: prepare the GCR address fields for a track written from the cache */
rsrc_DRVR_4__Sony_3310:
    moveml %d0-%a4,%sp@-
    moveal %a1@(28),%a0
    moveal %a1@(328),%a2
    moveal %a2@+,%a4
    moveal %a2@+,%a3
    moveq #0,%d3
    moveb %a2@,%d3
    moveq #12,%d0
    moveq #127,%d2
    andw %d6,%d2
    lsrw #4,%d2
    subw %d2,%d0
    movew %d0,%a1@(32)
    lea %pc@(rsrc_DRVR_4__Sony_372C),%a1
    lea %pc@(rsrc_DRVR_4__Sony_36F0),%a2
    moveb %a1@(0x0,%d3:w),%d7
    moveb %d3,%d5
    andib #15,%d3
    subqb #2,%d3
    jbeq rsrc_DRVR_4__Sony_3310_3C
    lea %pc@(rsrc_DRVR_4__Sony_36B4),%a2
rsrc_DRVR_4__Sony_3310_3C:/* the interleave table for the format; track, side */
    muluw #12,%d2
    addaw %d2,%a2
    moveq #63,%d3
    andb %d6,%d3
    moveb %a1@(0x0,%d3:w),%d2
    eorb %d3,%d5
    lsrw #6,%d6
    eorb %d6,%d5
    moveb %a1@(0x0,%d6:w),%d6
rsrc_DRVR_4__Sony_3310_54:/* each sector's address field */
    swap %d0
    moveq #0,%d1
    moveb %a2@(0x0,%d0:w),%d1
    moveb %a1@(0x0,%d1:w),%d3
    moveq #0,%d4
    moveb %d5,%d4
    eorb %d1,%d4
    lea %a0@(9),%a0
    moveb %d2,%a0@+
    moveb %d3,%a0@+
    moveb %d6,%a0@+
    moveb %d7,%a0@+
    moveb %a1@(0x0,%d4:w),%a0@+
    lea %a0@(11),%a0
    moveb #11,%a0@+
    moveb %d1,%a0@+
    clrb %a0@+
    movel %d1,%d4
    addw %d4,%d4
    addw %d1,%d4
    lslw #2,%d4
    addl %a3,%d4
    movel %d4,%a0@+
    moveq #9,%d4
    lslw %d4,%d1
    addl %a4,%d1
    movel %d1,%a0@+
    addqw #1,%d0
    movew %d0,%d1
    swap %d0
    cmpw %d0,%d1
    jblt rsrc_DRVR_4__Sony_3310_54
    moveml %sp@+,%d0-%a4
    rts

/* rsrc_DRVR_4__Sony_33B6: MFM track write from the cache, then verify (3420) */
rsrc_DRVR_4__Sony_33B6:
    jbsr rsrc_DRVR_4__Sony_1010
    movew %a1@(22),%d4
    moveq #0,%d5
    bclr #11,%d4
    jbeq rsrc_DRVR_4__Sony_33B6_24
    moveq #1,%d5
    moveq #0,%d2
    movew TimeDBRA,%d2
    movel %d2,%d0
    addl %d2,%d0
    addl %d2,%d0
    lsrl #2,%d0
rsrc_DRVR_4__Sony_33B6_20:  /* count down (loop) */
    dbf %d0,rsrc_DRVR_4__Sony_33B6_20
rsrc_DRVR_4__Sony_33B6_24:/* 9 or 18 sectors */
    moveq #8,%d2
    moveb %a1@(0x18,%d1:w),%d0
    jbpl rsrc_DRVR_4__Sony_33B6_32
    moveq #17,%d2
    bset #31,%d2
rsrc_DRVR_4__Sony_33B6_32:/* write the MFM track from the cache (S_3486); verify if asked */
    jbsr rsrc_DRVR_4__Sony_3486
    moveal %a1@(328),%a1
    moveal %a1@,%a2
    movel %a0,%a1@
    jbsr rsrc_DRVR_4__Sony_267E
    andiw #-1793,%sr
    movew DskErr,%d0
    jbne rsrc_DRVR_4__Sony_33B6_68
    moveal %a1@(328),%a0
    tstb %a0@(9)
    jbeq rsrc_DRVR_4__Sony_33B6_5E
    jbsr rsrc_DRVR_4__Sony_3420
    jbne rsrc_DRVR_4__Sony_33B6_68
    jbsr rsrc_DRVR_4__Sony_1010
rsrc_DRVR_4__Sony_33B6_5E:/* side 1 too */
    bset #3,%a1@(22)
    jbeq rsrc_DRVR_4__Sony_33B6
    moveq #0,%d0
rsrc_DRVR_4__Sony_33B6_68:  /* return */
    rts

/* rsrc_DRVR_4__Sony_3420: verify an MFM track against the cache */
rsrc_DRVR_4__Sony_3420:
    moveml %d2-%d7,%sp@-
    oriw #1792,%sr
    moveq #18,%d7
    movel #1022,%d6
    jbsr rsrc_DRVR_4__Sony_1010
    tstb %a1@(0x18,%d1:w)
    jbpl rsrc_DRVR_4__Sony_3420_22
    moveq #36,%d7
    movel #524286,%d6
rsrc_DRVR_4__Sony_3420_22:/* read an ID: not yet seen? verify the sector against the cache */
    jbsr rsrc_DRVR_4__Sony_1D80
    jbne rsrc_DRVR_4__Sony_3420_4C
    btst %d2,%d6
    jbeq rsrc_DRVR_4__Sony_3420_4C
    cmpw %a1@(22),%d1
    jbne rsrc_DRVR_4__Sony_3420_4C
    movew %d2,%d3
    subqw #1,%d2
    moveq #9,%d0
    lsll %d0,%d2
    addl %a1@(28),%d2
    moveal %d2,%a0
    st DskVerify
    jbsr rsrc_DRVR_4__Sony_2AE6
    jbne rsrc_DRVR_4__Sony_3420_4C
    bclr %d3,%d6
rsrc_DRVR_4__Sony_3420_4C:/* next; all seen? else verErr */
    jbsr rsrc_DRVR_4__Sony_267E
    tstl %d6
    dbeq %d7,rsrc_DRVR_4__Sony_3420_22
    jbeq rsrc_DRVR_4__Sony_3420_5A
    moveq #-84,%d0
rsrc_DRVR_4__Sony_3420_5A:/* return */
    andiw #-1793,%sr
    moveml %sp@+,%d2-%d7
    tstw %d0
    rts

/* rsrc_DRVR_4__Sony_3486: MFM: write a whole track through the ISM from the cache buffer */
rsrc_DRVR_4__Sony_3486:
    movel %sp@+,DskRtnAdr
    moveq #1,%d0
    tstw %d5
    jbeq rsrc_DRVR_4__Sony_3486_C
    moveq #3,%d0
rsrc_DRVR_4__Sony_3486_C:/* select the side; the cache buffer */
    jbsr rsrc_DRVR_4__Sony_102C
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_1D5E
    moveal %a1@(328),%a0
    moveal %a0@,%a0
    movel %a0,%a1@(28)
    moveal IWM,%a4
    lea %a4@,%a3
    lea %a4@(7680),%a4
    moveb #24,%a3@(3072)
    moveb #16,%a3@(3584)
    moveb #1,%a3@(3584)
    jbsr rsrc_DRVR_4__Sony_43FC
    nop
    moveq #78,%d1
    moveb %d1,%a3@
    moveb %d1,%a3@
    moveb #8,%a3@(3584)
    movew #13500,%d3
rsrc_DRVR_4__Sony_3486_52:/* wait for the index */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_58:/* until the index */
    moveb %a4@,%d0
    jbpl rsrc_DRVR_4__Sony_3486_58
    moveb %d1,%a3@
    btst #3,%d0
    jbeq rsrc_DRVR_4__Sony_3486_6C
    dbf %d3,rsrc_DRVR_4__Sony_3486_52
    jbra rsrc_DRVR_4__Sony_3486_212
rsrc_DRVR_4__Sony_3486_6C:/* wait */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_72:/* index gone */
    moveb %a4@,%d0
    jbpl rsrc_DRVR_4__Sony_3486_72
    moveb %d1,%a3@
    btst #3,%d0
    jbne rsrc_DRVR_4__Sony_3486_86
    dbf %d3,rsrc_DRVR_4__Sony_3486_6C
    jbra rsrc_DRVR_4__Sony_3486_212
rsrc_DRVR_4__Sony_3486_86:/* gap 4a */
    moveb #0xf5,%a3@(2048)
    moveq #78,%d0
rsrc_DRVR_4__Sony_3486_8E:/* write */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_94:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_94
    moveb %d1,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_3486_8E
    moveq #11,%d0
    moveq #0,%d1
rsrc_DRVR_4__Sony_3486_A2:/* sync zeros */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_A8:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_A8
    moveb %d1,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_3486_A2
    moveq #2,%d0
rsrc_DRVR_4__Sony_3486_B4:/* index mark (C2 C2 C2 FC) */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_BA:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_BA
    moveb #0xc2,%a3@(512)
    dbf %d0,rsrc_DRVR_4__Sony_3486_B4
rsrc_DRVR_4__Sony_3486_C8:/* FC */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_C8
    moveb #0xfc,%a3@
    moveq #49,%d0
rsrc_DRVR_4__Sony_3486_D2:/* gap 1 */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_D8:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_D8
    moveb #78,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_3486_D2
    moveq #1,%d6
    jbra rsrc_DRVR_4__Sony_3486_102
rsrc_DRVR_4__Sony_3486_E8:/* each sector: gap 3 */
    moveq #79,%d0
    tstl %d2
    jbpl rsrc_DRVR_4__Sony_3486_F0
    moveq #100,%d0
rsrc_DRVR_4__Sony_3486_F0:/* write */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_F6:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_F6
    moveb #78,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_3486_F0
rsrc_DRVR_4__Sony_3486_102:/* sync */
    moveq #11,%d0
    moveq #0,%d1
rsrc_DRVR_4__Sony_3486_106:/* write */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_10C:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_10C
    moveb %d1,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_3486_106
    moveq #2,%d0
rsrc_DRVR_4__Sony_3486_118:/* ID mark (A1 A1 A1 FE) */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_11E:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_11E
    moveb #0xa1,%a3@(512)
    dbf %d0,rsrc_DRVR_4__Sony_3486_118
rsrc_DRVR_4__Sony_3486_12C:/* FE */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_12C
    moveb #0xfe,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_13A:/* track */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_13A
    moveb %d4,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_146:/* side */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_146
    moveb %d5,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_152:/* sector */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_152
    moveb %d6,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_15E:/* size */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_15E
    moveb #2,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_16C:/* CRC */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_16C
    moveb %d0,%a3@(1024)
    moveq #21,%d0
rsrc_DRVR_4__Sony_3486_176:/* gap 2 */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_17C:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_17C
    moveb #78,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_3486_176
    moveq #11,%d0
    moveq #0,%d1
rsrc_DRVR_4__Sony_3486_18C:/* sync */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_192:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_192
    moveb %d1,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_3486_18C
    moveq #2,%d0
rsrc_DRVR_4__Sony_3486_19E:/* data mark (A1 A1 A1 FB) */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_1A4:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_1A4
    moveb #0xa1,%a3@(512)
    dbf %d0,rsrc_DRVR_4__Sony_3486_19E
rsrc_DRVR_4__Sony_3486_1B2:/* FB */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_1B2
    moveb #0xfb,%a3@
    movew #511,%d0
rsrc_DRVR_4__Sony_3486_1BE:/* 512 bytes from the cache */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_1C4:/* write */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_1C4
    moveb %a0@+,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_3486_1BE
rsrc_DRVR_4__Sony_3486_1CE:/* CRC; next sector; gap 4b to the index */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_3486_1CE
    moveb %d0,%a3@(1024)
    addqw #1,%d6
    dbf %d2,rsrc_DRVR_4__Sony_3486_E8
    moveq #4,%d0
    moveq #78,%d1
    movew #1000,%d3
    tstw %d5
    jbne rsrc_DRVR_4__Sony_3486_1F2
    moveq #4,%d3
    jbra rsrc_DRVR_4__Sony_3486_1F2
rsrc_DRVR_4__Sony_3486_1EC:/* filler */
    moveb #0xf4,%a3@(2048)
rsrc_DRVR_4__Sony_3486_1F2:/* wait */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_3486_1F8:/* until the index */
    moveb %a4@,%d2
    jbpl rsrc_DRVR_4__Sony_3486_1F8
    moveb %d1,%a3@
    subqw #1,%d0
    jbgt rsrc_DRVR_4__Sony_3486_20A
    jbeq rsrc_DRVR_4__Sony_3486_1EC
    btst #3,%d2
    jbne rsrc_DRVR_4__Sony_3486_216
rsrc_DRVR_4__Sony_3486_20A:/* timeout? */
    dbf %d3,rsrc_DRVR_4__Sony_3486_1F2
    tstw %d5
    jbeq rsrc_DRVR_4__Sony_3486_216
rsrc_DRVR_4__Sony_3486_212:/* no index: -83 */
    moveq #-83,%d0
    jbra rsrc_DRVR_4__Sony_3486_220
rsrc_DRVR_4__Sony_3486_216:/* underrun? */
    moveq #0,%d0
    btst #5,%d2
    jbeq rsrc_DRVR_4__Sony_3486_220
    moveq #-74,%d0
rsrc_DRVR_4__Sony_3486_220:/* read mode; return */
    moveb #24,%a3@(3072)
    movel DskRtnAdr,%sp@-
    tstw %d0
    rts
rsrc_DRVR_4__Sony_36B4: /* GCR interleave tables (data) */
    .byte   0x00, 0x03, 0x06, 0x09, 0x01, 0x04, 0x07, 0x0A, 0x02, 0x05, 0x08, 0x0B, 0x00, 0x03, 0x06, 0x09	| 4086FA94
    .byte   0x01, 0x04, 0x07, 0x0A, 0x02, 0x05, 0x08, 0x00, 0x00, 0x05, 0x03, 0x08, 0x01, 0x06, 0x04, 0x09	| 4086FAA4
    .byte   0x02, 0x07, 0x00, 0x00, 0x00, 0x07, 0x05, 0x03, 0x01, 0x08, 0x06, 0x04, 0x02, 0x00, 0x00, 0x00	| 4086FAB4
    .byte   0x00, 0x02, 0x04, 0x06, 0x01, 0x03, 0x05, 0x07, 0x00, 0x00, 0x00, 0x00	| 4086FAC4
rsrc_DRVR_4__Sony_36F0: /* (data) */
    .byte   0x00, 0x06, 0x01, 0x07, 0x02, 0x08, 0x03, 0x09, 0x04, 0x0A, 0x05, 0x0B, 0x00, 0x06, 0x01, 0x07	| 4086FAD0
    .byte   0x02, 0x08, 0x03, 0x09, 0x04, 0x0A, 0x05, 0x00, 0x00, 0x05, 0x01, 0x06, 0x02, 0x07, 0x03, 0x08	| 4086FAE0
    .byte   0x04, 0x09, 0x00, 0x00, 0x00, 0x05, 0x01, 0x06, 0x02, 0x07, 0x03, 0x08, 0x04, 0x00, 0x00, 0x00	| 4086FAF0
    .byte   0x00, 0x04, 0x01, 0x05, 0x02, 0x06, 0x03, 0x07, 0x00, 0x00, 0x00, 0x00	| 4086FB00
rsrc_DRVR_4__Sony_372C: /* GCR encode table (data); then the HD20 (DCD) Prime */
    .byte   0x96, 0x97, 0x9A, 0x9B, 0x9D, 0x9E, 0x9F, 0xA6, 0xA7, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF, 0xB2, 0xB3	| 4086FB0C
    .byte   0xB4, 0xB5, 0xB6, 0xB7, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF, 0xCB, 0xCD, 0xCE, 0xCF, 0xD3	| 4086FB1C
    .byte   0xD6, 0xD7, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF, 0xE5, 0xE6, 0xE7, 0xE9, 0xEA, 0xEB, 0xEC	| 4086FB2C
    .byte   0xED, 0xEE, 0xEF, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF	| 4086FB3C
    .byte   0x96, 0x97, 0x9A, 0x9B, 0x9D, 0x9E, 0x9F, 0xA6, 0xA7, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF, 0xB2, 0xB3	| 4086FB4C
    .byte   0xB4, 0xB5, 0xB6, 0xB7, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF, 0xCB, 0xCD, 0xCE, 0xCF, 0xD3	| 4086FB5C
    .byte   0xD6, 0xD7, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF, 0xE5, 0xE6, 0xE7, 0xE9, 0xEA, 0xEB, 0xEC	| 4086FB6C
    .byte   0xED, 0xEE, 0xEF, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF	| 4086FB7C
    .byte   0x96, 0x97, 0x9A, 0x9B, 0x9D, 0x9E, 0x9F, 0xA6, 0xA7, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF, 0xB2, 0xB3	| 4086FB8C
    .byte   0xB4, 0xB5, 0xB6, 0xB7, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF, 0xCB, 0xCD, 0xCE, 0xCF, 0xD3	| 4086FB9C
    .byte   0xD6, 0xD7, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF, 0xE5, 0xE6, 0xE7, 0xE9, 0xEA, 0xEB, 0xEC	| 4086FBAC
    .byte   0xED, 0xEE, 0xEF, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF	| 4086FBBC
    .byte   0x96, 0x97, 0x9A, 0x9B, 0x9D, 0x9E, 0x9F, 0xA6, 0xA7, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF, 0xB2, 0xB3	| 4086FBCC
    .byte   0xB4, 0xB5, 0xB6, 0xB7, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF, 0xCB, 0xCD, 0xCE, 0xCF, 0xD3	| 4086FBDC
    .byte   0xD6, 0xD7, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF, 0xE5, 0xE6, 0xE7, 0xE9, 0xEA, 0xEB, 0xEC	| 4086FBEC
    .byte   0xED, 0xEE, 0xEF, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF	| 4086FBFC
rsrc_DRVR_4__Sony_372C_100:
    andiw #-1793,%sr	| 4086FC0C
    movew %a1@(274),%d0
    cmpw %a1@(18),%d0
    beqs rsrc_DRVR_4__Sony_372C+0x114
    moveq #10,%d0
    jbsr rsrc_DRVR_4__Sony_118A
    moveal IWM,%a0
    tstb %a0@
    tstb %a0@(2048)
    cmpib #2,%a1@(0x3,%d1:w)
    jbge rsrc_DRVR_4__Sony_389A
    lea %pc@(rsrc_DRVR_4__Sony_385E),%a0
    movel %a0,%a1@(448)
    jbra rsrc_DRVR_4__Sony_4072
rsrc_DRVR_4__Sony_385E: /* HD20 completion: the status */
    jbne rsrc_DRVR_4__Sony_399C	| 4086FC3E
    jbsr rsrc_DRVR_4__Sony_1008	| 4086FC42
    moveb #8,%a1@(3,%d1:w)	| 4086FC46
    movel %a1@(458),%a1@(0x16,%d1:w)	| 4086FC4C
    movel %a1@(462),%d0	| 4086FC52
    swap %d0	| 4086FC56
    movel %d0,%a1@(0x12,%d1:w)	| 4086FC58
    clrb %a1@(0x14,%d1:w)
    lsrw #8,%d0	| 4086FC60
    moveb %d0,%a1@(0x1a,%d1:w)	| 4086FC62
    btst #3,%d0	| 4086FC66
    sne %a1@(2,%d1:w)	| 4086FC6A
    btst #4,%d0
    jbeq rsrc_DRVR_4__Sony_389A
    moveb #2,%a1@(0x3,%d1:w)
rsrc_DRVR_4__Sony_389A: /* HD20 Prime: block number, count, buffer, tags */
    moveal %a1@,%a2
    movel %a2@(16),%d5
    moveq #9,%d1
    lsrl %d1,%d5
    moveal %a2@(8),%a0
    moveal %a1@(244),%a5
    moveal %a0@(32),%a4
    movel %a0@(36),%d3
    moveq #-50,%d0
    andiw #511,%d3
    jbne rsrc_DRVR_4__Sony_399C
    movel %a0@(36),%d3
    tstb DskVerify
    jbeq rsrc_DRVR_4__Sony_38DC
    jbsr rsrc_DRVR_4__Sony_F4E
    jbne rsrc_DRVR_4__Sony_38DC
    movel %d3,%a0@(40)
    addl %d3,%a2@(16)
    moveq #0,%d0
    jbra rsrc_DRVR_4__Sony_399C
rsrc_DRVR_4__Sony_38DC: /* power */
    jbsr rsrc_DRVR_4__Sony_4324
    nop
    nop
rsrc_DRVR_4__Sony_38E4: /* blocks in this command (at most 255) */
    moveq #9,%d1
    lsrl %d1,%d3
    moveq #0,%d0
    subqb #1,%d0
    cmpl %d0,%d3
    jblt rsrc_DRVR_4__Sony_38F2
    movel %d0,%d3
rsrc_DRVR_4__Sony_38F2: /* count; 3 tries */
    movew %d3,%d2
    swap %d3
    movew %d2,%d3
    moveb #3,%a1@(45)
    clrb %a1@(487)
rsrc_DRVR_4__Sony_3902: /* send the command */
    jbsr rsrc_DRVR_4__Sony_39F0
    jbsr rsrc_DRVR_4__Sony_3A1C
    jbne rsrc_DRVR_4__Sony_3930
rsrc_DRVR_4__Sony_390C: /* wait for the drive; timeout: error state */
    jbsr rsrc_DRVR_4__Sony_39AC
    jbpl rsrc_DRVR_4__Sony_3924
    moveb #2,%a1@(486)
    clrl %a1@(482)
    moveb #64,%a1@(482)
    jbra rsrc_DRVR_4__Sony_3930
rsrc_DRVR_4__Sony_3924: /* receive the reply; next block */
    jbsr rsrc_DRVR_4__Sony_3AC6
    jbeq rsrc_DRVR_4__Sony_390C
    addl %d4,%d5
    tstw %d0
    jbeq rsrc_DRVR_4__Sony_396C
rsrc_DRVR_4__Sony_3930: /* error: retry (reset the drive on the second try) */
    subqb #1,%a1@(45)
    jblt rsrc_DRVR_4__Sony_395E
    jbeq rsrc_DRVR_4__Sony_3952
    cmpib #2,%a1@(486)
    jbne rsrc_DRVR_4__Sony_395C
    btst #30,%a1@(482)
    jbne rsrc_DRVR_4__Sony_395C
    tstb %a1@(487)
    jbeq rsrc_DRVR_4__Sony_3952
    clrb %a1@(45)
rsrc_DRVR_4__Sony_3952: /* DCDReset */
    jbsr rsrc_DRVR_4__Sony_3FE8
    jbne rsrc_DRVR_4__Sony_395E
    st %a1@(487)
rsrc_DRVR_4__Sony_395C: /* again */
    jbra rsrc_DRVR_4__Sony_3902
rsrc_DRVR_4__Sony_395E: /* read error (-19) or write error (-20) */
    moveq #-19,%d0
    cmpib #2,%a1@(51)
    jbeq rsrc_DRVR_4__Sony_396A
    moveq #-20,%d0
rsrc_DRVR_4__Sony_396A: /* finish */
    jbra rsrc_DRVR_4__Sony_399C
rsrc_DRVR_4__Sony_396C: /* advance by the blocks done; more? next command */
    moveq #9,%d1
    clrw %d3
    swap %d3
    cmpib #2,%a1@(51)
    jbeq rsrc_DRVR_4__Sony_397E
    addl %d3,BufTgFFlg
rsrc_DRVR_4__Sony_397E: /* update the counts */
    lsll %d1,%d3
    moveal %a1@,%a3
    addl %d3,%a3@(16)
    moveal %a3@(8),%a0
    addl %d3,%a0@(40)
    movel %a0@(36),%d3
    subl %a0@(40),%d3
    jbgt rsrc_DRVR_4__Sony_38E4
    moveq #0,%d0
rsrc_DRVR_4__Sony_399C: /* IWM back to read mode, power off, finish */
    moveal IWM,%a0
    jbsr rsrc_DRVR_4__Sony_4332
    andiw #-1793,%sr
    jbra rsrc_DRVR_4__Sony_784

/* rsrc_DRVR_4__Sony_39AC: wait for the HD20 (DCD) handshake line; give up after a1+490 tries with a1+488 sleeps */
rsrc_DRVR_4__Sony_39AC:
    moveal %sp@+,%a3
rsrc_DRVR_4__Sony_39AC_2:/* wait for the drive's handshake (100 tries, then sleeps) */
    moveq #100,%d0
    moveal VIA,%a2
    lea %a2@(7680),%a2
rsrc_DRVR_4__Sony_39AC_C:/* poll */
    moveb %a2@,%a2@
    tstb %a0@(6656)
    tstb %a0@(7168)
    dbpl %d0,rsrc_DRVR_4__Sony_39AC_C
    jbpl rsrc_DRVR_4__Sony_39AC_2C
    subqw #1,%a1@(490)
    jbmi rsrc_DRVR_4__Sony_39AC_2C
    movew %a1@(488),%d0
    jbsr rsrc_DRVR_4__Sony_118A
    jbra rsrc_DRVR_4__Sony_39AC_2
rsrc_DRVR_4__Sony_39AC_2C:/* return */
    jmp %a3@

/* rsrc_DRVR_4__Sony_39DA: a short delay (17 VIA accesses) */
rsrc_DRVR_4__Sony_39DA:
    movel %a2,%sp@-
    moveal VIA,%a2
    lea %a2@(7680),%a2
    moveq #16,%d0
rsrc_DRVR_4__Sony_39DA_C:/* delay */
    moveb %a2@,%a2@
    dbf %d0,rsrc_DRVR_4__Sony_39DA_C
    moveal %sp@+,%a2
    rts

/* rsrc_DRVR_4__Sony_39F0: set up an HD20 command: block number, count, timeouts */
rsrc_DRVR_4__Sony_39F0:
    movel %d5,%d0
    lsll #8,%d0
    movel %d0,%a1@(454)
    moveb %d3,%a1@(453)
    movew #10,%a1@(488)
    movew #10000,%a1@(490)
    movel #512,%d6
    moveq #0,%d7
    andib #63,%a1@(452)
    jbne rsrc_DRVR_4__Sony_39F0_2A
    exg %d6,%d7
rsrc_DRVR_4__Sony_39F0_2A:/* return */
    rts

/* rsrc_DRVR_4__Sony_3A1C: HD20 (DCD) SendCmd through JSendCmd: send a command block and receive its reply, retrying */
rsrc_DRVR_4__Sony_3A1C:
    movel JSendCmd,%sp@-
    rts
    moveal IWM,%a0
    lea %a0@(6144),%a3
    movel %d6,%a1@(478)
    addl %d7,%a1@(478)
    moveb %a1@(452),%d1
    cmpib #3,%d1
    bges rsrc_DRVR_4__Sony_3A1C_4E
    tstb %d1
    bnes rsrc_DRVR_4__Sony_3A1C_2A
    addiw #20,%d7
    bras rsrc_DRVR_4__Sony_3A1C_4E
rsrc_DRVR_4__Sony_3A1C_2A:/* HD20 write: tags and data counts in 7-byte groups */
    addiw #20,%d6
    movel %a5,%d0
    bnes rsrc_DRVR_4__Sony_3A1C_4E
    lea %a1@(458),%a1
    movel BufTgFNum,%a1@+
    movel BufTgFFlg,%a1@+
    movel BufTgDate,%a1@+
    movel BufTgHD20,%a1@+
    movel BufTgHD20_1,%a1@+
    moveal SonyVars,%a1
rsrc_DRVR_4__Sony_3A1C_4E:/* counts rounded up */
    addqw #6,%d6
    divuw #7,%d6
    andiw #127,%d6
    addqw #6,%d7
    divuw #7,%d7
    andiw #127,%d7
    moveq #0,%d4
    jbra rsrc_DRVR_4__Sony_3A1C_84
rsrc_DRVR_4__Sony_3A1C_66:/* a write: the tag bytes and data follow */
    tstb %d1
    jbeq rsrc_DRVR_4__Sony_3A1C_A8
    orib #64,%a1@(452)
    moveb %d3,%a1@(453)
    addql #1,%a1@(462)
    movew #7,%a1@(488)
    movew #10000,%a1@(490)
rsrc_DRVR_4__Sony_3A1C_84:/* the tags for reads/writes of blocks */
    cmpib #3,%d1
    jbge rsrc_DRVR_4__Sony_3A1C_A0
    tstb %d1
    jbeq rsrc_DRVR_4__Sony_3A1C_A0
    movel %a5,%d0
    jbeq rsrc_DRVR_4__Sony_3A1C_A0
    lea %a1@(458),%a1
    movel %a5@+,%a1@+
    movel %a5@+,%a1@+
    movel %a5@+,%a1@+
    moveal SonyVars,%a1
rsrc_DRVR_4__Sony_3A1C_A0:/* send it */
    jbsr rsrc_DRVR_4__Sony_3DB6
    jbne rsrc_DRVR_4__Sony_3AC6_A6
rsrc_DRVR_4__Sony_3A1C_A8:/* return */
    rts

/* rsrc_DRVR_4__Sony_3AC6: HD20: receive the reply to a command, check it, copy the tags */
rsrc_DRVR_4__Sony_3AC6:
    moveal IWM,%a0
    lea %a0@(6144),%a3
    moveb %a1@(452),%d1
    andib #63,%d1
    jbsr rsrc_DRVR_4__Sony_3B7C
    jbne rsrc_DRVR_4__Sony_3AC6_A6
    movel %a1@(452),%d0
    moveb #48,%d0
    subib #0x80,%a1@(452)
    cmpb %a1@(452),%d1
    jbne rsrc_DRVR_4__Sony_3AC6_A6
    cmpib #3,%d1
    jbge rsrc_DRVR_4__Sony_3AC6_7E
    moveb #49,%d0
    cmpb %a1@(453),%d3
    jbeq rsrc_DRVR_4__Sony_3AC6_4C
    swap %d0
    moveb %d3,%d0
    swap %d0
    rorl #8,%d0
    moveb %a1@(453),%d0
    roll #8,%d0
    jbra rsrc_DRVR_4__Sony_3AC6_A6
rsrc_DRVR_4__Sony_3AC6_4C:/* a read: copy the tags */
    tstb %d1
    jbne rsrc_DRVR_4__Sony_3AC6_7E
    movel %a5,%d0
    jbeq rsrc_DRVR_4__Sony_3AC6_62
    lea %a1@(458),%a1
    movel %a1@+,%a5@+
    movel %a1@+,%a5@+
    movel %a1@+,%a5@+
    moveal SonyVars,%a1
rsrc_DRVR_4__Sony_3AC6_62:/* into the tag buffer */
    lea %a1@(458),%a1
    movel %a1@+,BufTgFNum
    movel %a1@+,BufTgFFlg
    movel %a1@+,BufTgDate
    movel %a1@+,BufTgHD20
    movel %a1@+,BufTgHD20_1
    moveal SonyVars,%a1
rsrc_DRVR_4__Sony_3AC6_7E:/* status: error bit? count the block */
    moveq #1,%d2
    movel %a1@(454),%d0
    btst #24,%d0
    jbne rsrc_DRVR_4__Sony_3AC6_AA
    cmpib #10,%a1@(454)
    jbeq rsrc_DRVR_4__Sony_3AC6_AA
    addal %a1@(478),%a4
    addql #1,%d4
    subqb #1,%d3
    jbne rsrc_DRVR_4__Sony_3A1C_66
    moveq #0,%d0
rsrc_DRVR_4__Sony_3AC6_A0:/* return */
    andiw #-5,%sr
    rts
rsrc_DRVR_4__Sony_3AC6_A6:/* an error */
    moveq #2,%d2
    rorl #8,%d0
rsrc_DRVR_4__Sony_3AC6_AA:/* store it */
    movel %d0,%a1@(482)
    moveb %d2,%a1@(486)
    moveq #1,%d0
    jbra rsrc_DRVR_4__Sony_3AC6_A0

/* rsrc_DRVR_4__Sony_3B7C: HD20: receive a block over the floppy port (handshake, 7-to-8 bit groups, checksum), interrupts off but the SCC polled */
rsrc_DRVR_4__Sony_3B7C:
    movew %sr,%sp@-
    moveml %d1-%d7/%a1-%a2/%a4-%fp,%sp@-
    moveml SCCRd,%a5-%fp
    jbsr rsrc_DRVR_4__Sony_4340
    lea %a1@(452),%a1
    moveq #0,%d5
    tstb %a0@(6656)
    moveq #32,%d0
    tstb %a0@(7168)
    jbmi rsrc_DRVR_4__Sony_3B7C_228
    moveal VIA,%a2
    lea %a2@(7680),%a2
    oriw #1792,%sr
    tstb %a0@(512)
    tstb %a0@(1024)
    tstb %a3@
    moveq #33,%d0
    moveq #8,%d6
    swap %d6
rsrc_DRVR_4__Sony_3B7C_40:/* wait for the AA sync byte */
    subql #1,%d6
    jbeq rsrc_DRVR_4__Sony_3B7C_228
    cmpib #0xaa,%a3@
    jbne rsrc_DRVR_4__Sony_3B7C_40
    movew #64,%d6
rsrc_DRVR_4__Sony_3B7C_50:/* next byte (with the SCC polled) */
    moveb %a2@,%a2@
    moveb %a3@,%d1
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_50
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    cmpib #0xbf,%d1
    jbne rsrc_DRVR_4__Sony_3B7C_64
    moveq #6,%d7
    swap %d7
rsrc_DRVR_4__Sony_3B7C_64:/* second */
    swap %d1
rsrc_DRVR_4__Sony_3B7C_66:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d1
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_66
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d1
rsrc_DRVR_4__Sony_3B7C_72:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d2
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_72
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d2
rsrc_DRVR_4__Sony_3B7C_7E:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d2
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_7E
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d2
rsrc_DRVR_4__Sony_3B7C_8A:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d3
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_8A
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d3
rsrc_DRVR_4__Sony_3B7C_96:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d3
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_96
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d3
rsrc_DRVR_4__Sony_3B7C_A2:/* wait */
    moveb %a2@,%a2@

rsrc_DRVR_4__Sony_3B7C_A4:/* the eighth (low bits) */
    moveb %a3@,%d4
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_A2
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d4
rsrc_DRVR_4__Sony_3B7C_AE:/* wait; groups */
    moveb %a2@,%a2@
    moveb %a3@,%d4
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_AE
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    dbf %d7,rsrc_DRVR_4__Sony_3B7C_C6
    jbra rsrc_DRVR_4__Sony_3B7C_1BA
rsrc_DRVR_4__Sony_3B7C_C0:/* timeout: error 34 */
    moveq #34,%d0
    jbra rsrc_DRVR_4__Sony_3B7C_228
rsrc_DRVR_4__Sony_3B7C_C6:/* each group of 7 bytes: 8 bytes on the wire */
    moveq #3,%d6
    swap %d6
    movew #64,%d6
rsrc_DRVR_4__Sony_3B7C_CE:/* rebuild the byte from the low-bit byte; checksum */
    lsrb #1,%d4
    addxb %d1,%d1
    addb %d1,%d5
    moveb %d1,%a1@+
rsrc_DRVR_4__Sony_3B7C_D6:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d1
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_D6
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d1
    moveb #3,%fp@
    lsrb #1,%d4
    addxb %d1,%d1
    addb %d1,%d5
    moveb %d1,%a1@+
rsrc_DRVR_4__Sony_3B7C_EE:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d1
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_EE
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d1
    tstw %d7
    jbeq rsrc_DRVR_4__Sony_3B7C_100
    tstb %a5@
rsrc_DRVR_4__Sony_3B7C_100:/* next */
    sne %d0
    lsrb #1,%d4
    addxb %d2,%d2
    addb %d2,%d5
    moveb %d2,%a1@+
rsrc_DRVR_4__Sony_3B7C_10A:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d2
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_10A
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d2
    lsrb #1,%d4
    addxb %d2,%d2
    addb %d2,%d5
    moveb %d2,%a1@+
rsrc_DRVR_4__Sony_3B7C_11E:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d2
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_11E
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d2
    tstb %d0
    jbeq rsrc_DRVR_4__Sony_3B7C_130
    tstb %a0@
rsrc_DRVR_4__Sony_3B7C_130:/* next */
    lsrb #1,%d4
    addxb %d3,%d3
    addb %d3,%d5
    moveb %d3,%a1@+
rsrc_DRVR_4__Sony_3B7C_138:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d3
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_138
rsrc_DRVR_4__Sony_3B7C_140:/* timeout or next group */
    jbpl rsrc_DRVR_4__Sony_3B7C_C0
    swap %d3
    swap %d6
    dbf %d6,rsrc_DRVR_4__Sony_3B7C_14E
    moveal %a4,%a1
rsrc_DRVR_4__Sony_3B7C_14E:/* next */
    swap %d6
    lsrb #1,%d4
    addxb %d3,%d3
    addb %d3,%d5
    moveb %d3,%a1@+
rsrc_DRVR_4__Sony_3B7C_158:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d3
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_158
    jbpl rsrc_DRVR_4__Sony_3B7C_140
    swap %d3
    lsrb #1,%d4
    swap %d4
    addxb %d4,%d4
    addb %d4,%d5
    moveb %d4,%a1@+
rsrc_DRVR_4__Sony_3B7C_16E:/* wait */
    moveb %a2@,%a2@
    moveb %a3@,%d4
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_16E
    jbpl rsrc_DRVR_4__Sony_3B7C_140
    swap %d4
    movew #64,%d6
rsrc_DRVR_4__Sony_3B7C_17E:/* wait; next group */
    moveb %a2@,%a2@
    moveb %a3@,%d4
    dbmi %d6,rsrc_DRVR_4__Sony_3B7C_17E
    jbpl rsrc_DRVR_4__Sony_3B7C_140
    tstb %d0
    dbne %d7,rsrc_DRVR_4__Sony_3B7C_CE
    jbeq rsrc_DRVR_4__Sony_3B7C_1BA
    tstb %a5@
    andiw #-1793,%sr
    subqw #1,%d7
    jbsr rsrc_DRVR_4__Sony_39DA
    oriw #1792,%sr
    tstb %a0@(512)
    tstb %a3@
    clrw %d0
rsrc_DRVR_4__Sony_3B7C_1A8:/* resync: AA */
    subqw #1,%d0
    jbeq rsrc_DRVR_4__Sony_3B7C_1B6
    cmpib #0xaa,%a3@
    jbne rsrc_DRVR_4__Sony_3B7C_1A8
    jbra rsrc_DRVR_4__Sony_3B7C_CE
rsrc_DRVR_4__Sony_3B7C_1B6:/* error 36 */
    moveq #36,%d0
    jbra rsrc_DRVR_4__Sony_3B7C_228
rsrc_DRVR_4__Sony_3B7C_1BA:/* the last partial group */
    swap %d7
    lsrb #1,%d4
    addxb %d1,%d1
    addb %d1,%d5
    subqw #1,%d7
    jbmi rsrc_DRVR_4__Sony_3B7C_1C8
    moveb %d1,%a1@+
rsrc_DRVR_4__Sony_3B7C_1C8:/* byte */
    swap %d1
    lsrb #1,%d4
    addxb %d1,%d1
    addb %d1,%d5
    subqw #1,%d7
    jbmi rsrc_DRVR_4__Sony_3B7C_1D6
    moveb %d1,%a1@+
rsrc_DRVR_4__Sony_3B7C_1D6:/* byte */
    lsrb #1,%d4
    addxb %d2,%d2
    addb %d2,%d5
    subqw #1,%d7
    jbmi rsrc_DRVR_4__Sony_3B7C_1E2
    moveb %d2,%a1@+
rsrc_DRVR_4__Sony_3B7C_1E2:/* byte */
    swap %d2
    lsrb #1,%d4
    addxb %d2,%d2
    addb %d2,%d5
    subqw #1,%d7
    jbmi rsrc_DRVR_4__Sony_3B7C_1F0
    moveb %d2,%a1@+
rsrc_DRVR_4__Sony_3B7C_1F0:/* byte */
    lsrb #1,%d4
    addxb %d3,%d3
    addb %d3,%d5
    subqw #1,%d7
    jbmi rsrc_DRVR_4__Sony_3B7C_1FC
    moveb %d3,%a1@+
rsrc_DRVR_4__Sony_3B7C_1FC:/* byte */
    swap %d3
    lsrb #1,%d4
    addxb %d3,%d3
    addb %d3,%d5
    subqw #1,%d7
    jbmi rsrc_DRVR_4__Sony_3B7C_20A
    moveb %d3,%a1@+
rsrc_DRVR_4__Sony_3B7C_20A:/* checksum; the drive's handshake */
    lsrb #1,%d4
    swap %d4
    addxb %d4,%d4
    addb %d4,%d5
    tstb %a0@(1536)
    tstb %a0@(6656)
    moveq #37,%d0
    tstb %a0@(7168)
    jbpl rsrc_DRVR_4__Sony_3B7C_228
    moveb %d5,%d0
    jbeq rsrc_DRVR_4__Sony_3B7C_228
    moveq #38,%d0
rsrc_DRVR_4__Sony_3B7C_228:/* return */
    tstb %a5@
    tstb %a0@(1536)
    tstb %a0@
    moveml %sp@+,%d1-%d7/%a1-%a2/%a4-%fp
    movew %sp@+,%sr
    tstw %d0
    rts

/* rsrc_DRVR_4__Sony_3DB6: HD20: send a block over the floppy port (8-to-7 bit groups, checksum) */
rsrc_DRVR_4__Sony_3DB6:
    movew %sr,%sp@-
    moveml %d1-%d7/%a1/%a4-%fp,%sp@-
    moveml SCCRd,%a5-%fp
    jbsr rsrc_DRVR_4__Sony_4340
    lea %a1@(452),%a1
    moveb %d1,%d4
    swap %d4
    swap %d6
    movew %d7,%d6
    swap %d6
    moveq #-128,%d0
    moveq #0,%d5
    st %d4
    moveb %a1@+,%d1
    addb %d1,%d5
    roxrb #1,%d1
    orb %d0,%d1
    roxrb #1,%d4
    swap %d1
    moveb %a1@+,%d1
    addb %d1,%d5
    roxrb #1,%d1
    orb %d0,%d1
    roxrb #1,%d4
    swap %d1
    moveb %a1@+,%d2
    addb %d2,%d5
    roxrb #1,%d2
    orb %d0,%d2
    roxrb #1,%d4
    swap %d2
    moveb %a1@+,%d2
    addb %d2,%d5
    roxrb #1,%d2
    orb %d0,%d2
    roxrb #1,%d4
    swap %d2
    moveb %a1@+,%d3
    addb %d3,%d5
    roxrb #1,%d3
    orb %d0,%d3
    roxrb #1,%d4
    swap %d3
    moveb %a1@+,%d3
    addb %d3,%d5
    roxrb #1,%d3
    orb %d0,%d3
    roxrb #1,%d4
    swap %d3
    swap %d4
    tstb %a0@(6656)
    moveq #16,%d0
    tstb %a0@(7168)
    jbpl rsrc_DRVR_4__Sony_3DB6_222
    tstb %a0@(512)
    moveq #17,%d0
    moveq #80,%d7
    swap %d7
rsrc_DRVR_4__Sony_3DB6_86:/* wait for the drive ready; interrupts off */
    subql #1,%d7
    jbeq rsrc_DRVR_4__Sony_3DB6_222
    tstb %a0@(7168)
    jbmi rsrc_DRVR_4__Sony_3DB6_86
    tstb %a0@(1024)
    lea %a0@(6656),%a0
    oriw #1792,%sr
    moveq #2,%d7
    cmpib #4,%d4
    jblt rsrc_DRVR_4__Sony_3DB6_AA
    moveq #-1,%d7
    moveal %a4,%a1
rsrc_DRVR_4__Sony_3DB6_AA:/* the AA sync and the header */
    jbsr rsrc_DRVR_4__Sony_39DA
    movel %d6,%d0
    addil #8454273,%d0
    moveb #0xaa,%a0@(1024)
rsrc_DRVR_4__Sony_3DB6_BC:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_BC
    moveb %d0,%a0@
    swap %d0
rsrc_DRVR_4__Sony_3DB6_C4:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_C4
    moveb %d0,%a0@
    moveq #-128,%d0
    jbra rsrc_DRVR_4__Sony_3DB6_182
rsrc_DRVR_4__Sony_3DB6_D0:/* each group of 7 bytes: the high bits gathered into the 8th */
    moveb %a1@+,%d4
    addb %d4,%d5
    roxrb #1,%d4
    orb %d0,%d4
    swap %d4
    roxrb #2,%d4
rsrc_DRVR_4__Sony_3DB6_DC:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_DC
    moveb %d4,%a0@
    st %d4
    moveb #3,%fp@
rsrc_DRVR_4__Sony_3DB6_E8:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_E8
    moveb %d1,%a0@
    moveb %a1@+,%d1
    addb %d1,%d5
    roxrb #1,%d1
    orb %d0,%d1
    roxrb #1,%d4
    swap %d1
    tstb %a5@
    jbeq rsrc_DRVR_4__Sony_3DB6_102
    bset #31,%d6
rsrc_DRVR_4__Sony_3DB6_102:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_102
    moveb %d1,%a0@
    moveb %a1@+,%d1
    addb %d1,%d5
    roxrb #1,%d1
    orb %d0,%d1
    roxrb #1,%d4
    swap %d1
    tstw %d6
    jbne rsrc_DRVR_4__Sony_3DB6_11C
    bclr #31,%d6
rsrc_DRVR_4__Sony_3DB6_11C:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_11C
    moveb %d2,%a0@
    moveb %a1@+,%d2
    addb %d2,%d5
    roxrb #1,%d2
    orb %d0,%d2
    roxrb #1,%d4
    swap %d2
    btst #31,%d6
    jbeq rsrc_DRVR_4__Sony_3DB6_138
    tstb %a0@(-6656)
rsrc_DRVR_4__Sony_3DB6_138:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_138
    moveb %d2,%a0@
    moveb %a1@+,%d2
    addb %d2,%d5
    roxrb #1,%d2
    orb %d0,%d2
    roxrb #1,%d4
    swap %d2
rsrc_DRVR_4__Sony_3DB6_14A:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_14A
    moveb %d3,%a0@
    moveb %a1@+,%d3
    addb %d3,%d5
    roxrb #1,%d3
    orb %d0,%d3
    roxrb #1,%d4
    swap %d3
    dbf %d7,rsrc_DRVR_4__Sony_3DB6_162
    moveal %a4,%a1
rsrc_DRVR_4__Sony_3DB6_162:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_162
    moveb %d3,%a0@
    moveb %a1@+,%d3
    addb %d3,%d5
    roxrb #1,%d3
    orb %d0,%d3
    roxrb #1,%d4
    swap %d3
    swap %d4
rsrc_DRVR_4__Sony_3DB6_176:/* write; a pause? */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_176
    moveb %d4,%a0@
    bclr #31,%d6
    jbne rsrc_DRVR_4__Sony_3DB6_188
rsrc_DRVR_4__Sony_3DB6_182:/* next group */
    dbf %d6,rsrc_DRVR_4__Sony_3DB6_D0
    jbra rsrc_DRVR_4__Sony_3DB6_1BC
rsrc_DRVR_4__Sony_3DB6_188:/* pause: let the SCC in */
    clrb %d0
rsrc_DRVR_4__Sony_3DB6_18A:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_18A
    moveb %d0,%a0@
    andiw #-1793,%sr
    jbsr rsrc_DRVR_4__Sony_39DA
    subqw #1,%d6
    tstb %a0@(512)
    tstb %a0@(-512)
    tstb %a0@
    tstb %a0@(-6144)
    jbsr rsrc_DRVR_4__Sony_39DA
    moveq #-128,%d0
    oriw #1792,%sr
    moveb #0xaa,%a0@(1024)
    jbra rsrc_DRVR_4__Sony_3DB6_D0
rsrc_DRVR_4__Sony_3DB6_1BC:/* the last group and the checksum */
    negb %d5
    roxrb #1,%d5
    orb %d0,%d5
    swap %d4
    roxrb #2,%d4
rsrc_DRVR_4__Sony_3DB6_1C6:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_1C6
    moveb %d4,%a0@
rsrc_DRVR_4__Sony_3DB6_1CC:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_1CC
    moveb %d1,%a0@
    swap %d1
rsrc_DRVR_4__Sony_3DB6_1D4:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_1D4
    moveb %d1,%a0@
rsrc_DRVR_4__Sony_3DB6_1DA:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_1DA
    moveb %d2,%a0@
    swap %d2
rsrc_DRVR_4__Sony_3DB6_1E2:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_1E2
    moveb %d2,%a0@
rsrc_DRVR_4__Sony_3DB6_1E8:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_1E8
    moveb %d3,%a0@
    swap %d3
rsrc_DRVR_4__Sony_3DB6_1F0:/* write */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_1F0
    moveb %d3,%a0@
rsrc_DRVR_4__Sony_3DB6_1F6:/* checksum */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_1F6
    moveb %d5,%a0@
rsrc_DRVR_4__Sony_3DB6_1FC:/* trailer */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_1FC
    moveq #0,%d0
    moveb %d0,%a0@
rsrc_DRVR_4__Sony_3DB6_204:/* wait for the drive's acknowledge */
    tstb %a3@
    jbpl rsrc_DRVR_4__Sony_3DB6_204
    moveb %d0,%a0@
    moveal IWM,%a0
    tstb %a0@(1536)
    moveq #19,%d0
    moveq #-1,%d7
rsrc_DRVR_4__Sony_3DB6_216:/* wait */
    subqw #1,%d7
    jbeq rsrc_DRVR_4__Sony_3DB6_222
    tstb %a0@(7168)
    jbpl rsrc_DRVR_4__Sony_3DB6_216
    moveq #0,%d0
rsrc_DRVR_4__Sony_3DB6_222:/* return */
    tstb %a0@(1536)
    tstb %a0@
    moveml %sp@+,%d1-%d7/%a1/%a4-%fp
    movew %sp@+,%sr
    tstw %d0
    rts

/* rsrc_DRVR_4__Sony_3FE8: HD20 DCDReset through JDCDReset: reset the drive and wait for it to answer (up to 1600 tries) */
rsrc_DRVR_4__Sony_3FE8:
    movel JDCDReset,%sp@-
    rts
    .short  0x265F	| 408703CE
    jbsr rsrc_DRVR_4__Sony_2716
    jbsr rsrc_DRVR_4__Sony_1336
    tstb %a0@(2560)
    tstb %a0@(1024)
    tstb %a0@
    movew #1000,%d0
    jbsr rsrc_DRVR_4__Sony_118A
    tstb %a0@(1536)
    tstb %a0@(2048)
    movew #20000,%d0
    jbsr rsrc_DRVR_4__Sony_118A
    movew #100,%a1@(488)
    movew #1600,%a1@(490)
rsrc_DRVR_4__Sony_3FE8_3E:/* wait for the drive to answer */
    jbsr rsrc_DRVR_4__Sony_1070
    jbmi rsrc_DRVR_4__Sony_3FE8_54
    subqw #1,%a1@(490)
    jbmi rsrc_DRVR_4__Sony_3FE8_58
    movew %a1@(488),%d0
    jbsr rsrc_DRVR_4__Sony_118A
    jbra rsrc_DRVR_4__Sony_3FE8_3E
rsrc_DRVR_4__Sony_3FE8_54:/* ready */
    moveq #0,%d0
    jmp %a3@
rsrc_DRVR_4__Sony_3FE8_58:/* no answer */
    tstb %a0@(6144)
    moveq #-1,%d0
    jmp %a3@
rsrc_DRVR_4__Sony_4048: /* HD20 icon: from the drive's reply */
    jbne rsrc_DRVR_4__Sony_4058	| 40870428
    lea %a1@(536),%a2	| 4087042A
    moveal %a1@,%a0	| 4087042E
    moveal %a0@(8),%a0	| 40870430
    movel %a2,%a0@(28)	| 40870434
rsrc_DRVR_4__Sony_4058: /* finish */
    jbra rsrc_DRVR_4__Sony_399C	| 40870438
SONY_CTL_GetDriveIcon_type3:/* (HD20, drive numbers 3+) the icon from the drive, if it has one */
    jbne rsrc_DRVR_4__Sony_784	| 4087043C
    btst #2,%a1@(0x1a,%d1:w)
    jbeq rsrc_DRVR_4__Sony_6D6_AC
    lea %pc@(rsrc_DRVR_4__Sony_4048),%a0
    movel %a0,%a1@(448)

rsrc_DRVR_4__Sony_4072: /* HD20 command 3 (status) */
    moveq #3,%d3
    jbra rsrc_DRVR_4__Sony_4072_A
rsrc_DRVR_4__Sony_4076: /* command 26 (verify) */
    moveq #26,%d3
    jbra rsrc_DRVR_4__Sony_4072_A
rsrc_DRVR_4__Sony_407A: /* command 25 (format) */
    moveq #25,%d3
rsrc_DRVR_4__Sony_4072_A:/* power, IWM mode; the command */
    jbsr rsrc_DRVR_4__Sony_435C
    tstb %a0@
    tstb %a0@(2048)
    clrb %a1@(487)
    moveb %d3,%a1@(452)
rsrc_DRVR_4__Sony_4072_1C:/* up to 18000 tries */
    moveal SonyVars,%a1
    andib #63,%a1@(452)
    subal %a4,%a4
    subal %a5,%a5
    moveq #1,%d3
    moveq #0,%d6
    moveq #0,%d7
    movew #100,%a1@(488)
    movew #18000,%a1@(490)
    cmpib #3,%a1@(452)
    jbne rsrc_DRVR_4__Sony_4072_5A
    movel #332,%d7
    movew #10,%a1@(488)
    movew #10000,%a1@(490)
    lea %a1@(492),%a4
rsrc_DRVR_4__Sony_4072_5A:/* send it */
    jbsr rsrc_DRVR_4__Sony_3A1C
    jbeq rsrc_DRVR_4__Sony_4072_88
rsrc_DRVR_4__Sony_4072_60:/* error: retry, or reset the drive */
    cmpib #2,%a1@(482)
    jbeq rsrc_DRVR_4__Sony_4072_78
    btst #30,%a1@(482)
    jbeq rsrc_DRVR_4__Sony_4072_78
    bset #1,%a1@(487)
    jbne rsrc_DRVR_4__Sony_4072_1C
rsrc_DRVR_4__Sony_4072_78:/* DCDReset once */
    bset #0,%a1@(487)
    jbne rsrc_DRVR_4__Sony_4072_9A
    jbsr rsrc_DRVR_4__Sony_3FE8
    jbne rsrc_DRVR_4__Sony_4072_9A
    jbra rsrc_DRVR_4__Sony_4072_1C
rsrc_DRVR_4__Sony_4072_88:/* wait, receive the reply */
    jbsr rsrc_DRVR_4__Sony_39AC
    jbmi rsrc_DRVR_4__Sony_4072_60
    jbsr rsrc_DRVR_4__Sony_3AC6
    tstw %d0
    jbne rsrc_DRVR_4__Sony_4072_60
    moveq #0,%d0
    jbra rsrc_DRVR_4__Sony_4072_9C
rsrc_DRVR_4__Sony_4072_9A:/* controlErr */
    moveq #-17,%d0
rsrc_DRVR_4__Sony_4072_9C:/* status: return to the caller's continuation */
    andib #63,%a1@(452)
    cmpib #3,%a1@(452)
    jbne rsrc_DRVR_4__Sony_399C
    moveal %a1@(448),%a0
    tstw %d0
    jmp %a0@
SONY_CTL_csGD:          /* Control: raw track read: the parameters */
    tstw %d0	| 40870506
    jbne rsrc_DRVR_4__Sony_784	| 40870508
    lea %sp@(-512),%sp	| 4087050C
    movel %sp,%a1@(28)	| 40870510
    lea %a0@(28),%a0	| 40870514
    movel %a0,%a1@(34)	| 40870518
    clrl %a0@(12)	| 4087051C
    movel %a0@+,%d0	| 40870520
    orl %a0@+,%d0	| 40870522
    jbeq rsrc_DRVR_4__Sony_416E	| 40870524
    addqw #8,%a0	| 40870526
    moveq #-50,%d0	| 40870528
    movew %a0@+,%d7	| 4087052A
    cmpiw #3,%d7
    jbhi rsrc_DRVR_4__Sony_416E
    jbne rsrc_DRVR_4__Sony_415E
    tstb %a1@(0x17,%d1:w)
    jbmi rsrc_DRVR_4__Sony_415E
    clrw %a0@(-2)
rsrc_DRVR_4__Sony_415E: /* track (< 80), side, ... */
    movew %a0@+,%d2
    cmpiw #80,%d2
    jbcc rsrc_DRVR_4__Sony_416E
    rolw #8,%d2
    moveb %a0@+,%d2
    cmpib #2,%d2
rsrc_DRVR_4__Sony_416E: /* side, sector, count; power up; controller mode */
    jbcc rsrc_DRVR_4__Sony_420E
    aslb #3,%d2
    rolw #8,%d2
    movew %d2,%a1@(22)
    moveq #0,%d2
    moveb %a0@+,%d2
    movew %d2,%a1@(254)
    jbsr rsrc_DRVR_4__Sony_4792
    tstb %a1@(312)
    jbpl rsrc_DRVR_4__Sony_4194
    jbsr rsrc_DRVR_4__Sony_2716
    bnew rsrc_DRVR_4__Sony_420E
rsrc_DRVR_4__Sony_4194: /* select, power up, seek; the request: skip to the sector? */
    jbsr rsrc_DRVR_4__Sony_1336
    jbsr rsrc_DRVR_4__Sony_26A0
    jbsr rsrc_DRVR_4__Sony_2388
    jbne rsrc_DRVR_4__Sony_420E
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_1D5E
    moveal %a1@(34),%a0
    movew %a0@(16),%d7
    cmpiw #3,%d7
    jbne rsrc_DRVR_4__Sony_41BC
    jbsr rsrc_DRVR_4__Sony_4216
    jbeq rsrc_DRVR_4__Sony_41F4
    jbra rsrc_DRVR_4__Sony_4206
rsrc_DRVR_4__Sony_41BC: /* wait for the requested sector's address field (255 tries) */
    tstw %d7
    jbeq rsrc_DRVR_4__Sony_41F4
    movew #255,%d6
rsrc_DRVR_4__Sony_41C4: /* the right track and sector? */
    jbsr rsrc_DRVR_4__Sony_1D80
    jbmi rsrc_DRVR_4__Sony_41D6
    cmpw %a1@(22),%d1
    jbne rsrc_DRVR_4__Sony_41D6
    cmpw %a1@(254),%d2
    jbeq rsrc_DRVR_4__Sony_41E2
rsrc_DRVR_4__Sony_41D6: /* next; not found: sectNFErr (-81) */
    jbsr rsrc_DRVR_4__Sony_267E
    dbf %d6,rsrc_DRVR_4__Sony_41C4
    moveq #-81,%d0
    jbra rsrc_DRVR_4__Sony_420E
rsrc_DRVR_4__Sony_41E2: /* read sectors before it */
    subqw #1,%d7
    jbeq rsrc_DRVR_4__Sony_41F4
    moveal %a1@(28),%a0
    clrb DskVerify
    jbsr rsrc_DRVR_4__Sony_1E84
    jbmi rsrc_DRVR_4__Sony_420E
rsrc_DRVR_4__Sony_41F4: /* the raw read (S_4260) */
    jbsr rsrc_DRVR_4__Sony_4260
    jbne rsrc_DRVR_4__Sony_4206
    moveal SonyVars,%a1
    moveal %a1@(34),%a1
    movel %a1@(8),%a1@(12)
rsrc_DRVR_4__Sony_4206: /* done */
    jbsr rsrc_DRVR_4__Sony_267E
    andiw #-1793,%sr
rsrc_DRVR_4__Sony_420E: /* free the buffer, finish */
    lea %sp@(512),%sp
    jbra rsrc_DRVR_4__Sony_B62

/* rsrc_DRVR_4__Sony_4216: wait for the index pulse (register 14) on a GCR disk; -83 when none */
rsrc_DRVR_4__Sony_4216: /* wait for the index pulse (register 14) with a time limit */
    movel %sp@+,DskRtnAdr
    moveq #14,%d0
    jbsr rsrc_DRVR_4__Sony_102C
    moveq #110,%d2
    tstb %a1@(0x18,%d1:w)
    jbmi rsrc_DRVR_4__Sony_4216_14
    addw %d2,%d2
rsrc_DRVR_4__Sony_4216_14:/* the limit from TimeDBRA */
    muluw TimeDBRA,%d2
    moveal IWM,%a4
    lea %a4@(7680),%a4
    moveq #0,%d0
rsrc_DRVR_4__Sony_4216_22:/* wait for it to go high */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    btst #3,%a4@
    jbeq rsrc_DRVR_4__Sony_4216_34
    subql #1,%d2
    jbgt rsrc_DRVR_4__Sony_4216_22
    jbra rsrc_DRVR_4__Sony_4216_44
rsrc_DRVR_4__Sony_4216_34:/* then low */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    btst #3,%a4@
    jbne rsrc_DRVR_4__Sony_4216_46
    subql #1,%d2
    jbgt rsrc_DRVR_4__Sony_4216_34
rsrc_DRVR_4__Sony_4216_44:/* none: -83 */
    moveq #-83,%d0
rsrc_DRVR_4__Sony_4216_46:/* return */
    jbra rsrc_DRVR_4__Sony_1412

/* rsrc_DRVR_4__Sony_4260: raw track read: select the side, then read bytes (and their timing bits) from the disk into the caller's buffers */
rsrc_DRVR_4__Sony_4260: /* raw read: select the side */
    jbsr rsrc_DRVR_4__Sony_1010
    moveq #1,%d0
    btst #3,%a1@(22)
    jbeq rsrc_DRVR_4__Sony_4260_10
    moveq #3,%d0
rsrc_DRVR_4__Sony_4260_10:/* the buffers and count */
    jbsr rsrc_DRVR_4__Sony_102C
    moveal %a1@(34),%a4
    moveal %a4@+,%a2
    moveal %a4@+,%a0
    movel %a4@+,%d0
    jbra rsrc_DRVR_4__Sony_4408
    .short  0x6A70	| 40870662
rsrc_DRVR_4__Sony_4260_24:/* MFM raw read through the ISM FIFO */
    movel %sp@+,DskRtnAdr
    moveal IWM,%a4
    lea %a4@(7680),%a3
    lea %a4@(4608),%a4
    tstb %a4@(512)
    moveb #24,%a4@(-1536)
    moveb #1,%a4@(-1024)
    moveb #1,%a4@(-1536)
    tstb %a4@(512)
    moveb #8,%a4@(-1024)
    moveq #-1,%d2
    jbra rsrc_DRVR_4__Sony_4260_72
rsrc_DRVR_4__Sony_4260_58:/* each byte and its timing bits */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    tstb %a3@
    dbmi %d2,rsrc_DRVR_4__Sony_4260_58
    jbsr rsrc_DRVR_4__Sony_441C
    moveb %a4@,%a0@+
    lsrb #1,%d3
    addxb %d1,%d1
    jbcc rsrc_DRVR_4__Sony_4260_74
    moveb %d1,%a2@+
rsrc_DRVR_4__Sony_4260_72:/* next timing byte */
    moveq #1,%d1
rsrc_DRVR_4__Sony_4260_74:/* count; flush */
    subql #1,%d0
    jbge rsrc_DRVR_4__Sony_4260_58
    cmpib #1,%d1
    jbeq rsrc_DRVR_4__Sony_4260_84
rsrc_DRVR_4__Sony_4260_7E:/* last partial timing byte */
    addb %d1,%d1
    jbcc rsrc_DRVR_4__Sony_4260_7E
    moveb %d1,%a2@+
rsrc_DRVR_4__Sony_4260_84:/* noErr */
    moveq #0,%d0
rsrc_DRVR_4__Sony_4260_86:/* back to read mode */
    moveb #24,%a4@(-1536)
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_4260_90:/* noNybErr */
    moveq #-66,%d0
    jbra rsrc_DRVR_4__Sony_4260_86

rsrc_DRVR_4__Sony_42F4: /* IWM raw read */
    movel %sp@+,DskRtnAdr
    moveal IWM,%a4
    lea %a4@(6144),%a4
    moveq #-1,%d2
    jbra rsrc_DRVR_4__Sony_42F4_22
rsrc_DRVR_4__Sony_42F4_10:/* each byte */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    moveb %a4@,%d1
    dbmi %d2,rsrc_DRVR_4__Sony_42F4_10
    jbpl rsrc_DRVR_4__Sony_42F4_2C
    moveb %d1,%a0@+
    moveq #60,%d2
rsrc_DRVR_4__Sony_42F4_22:/* count */
    subql #1,%d0
    jbge rsrc_DRVR_4__Sony_42F4_10
    moveq #0,%d0
rsrc_DRVR_4__Sony_42F4_28:/* return */
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_42F4_2C:/* timeout: noNybErr */
    moveq #-66,%d0
    jbra rsrc_DRVR_4__Sony_42F4_28

/* rsrc_DRVR_4__Sony_4324: set the drive format code for the power manager / ISM (a1+51 - 2) then 47C8 */
rsrc_DRVR_4__Sony_4324:
    moveb %a1@(51),%a1@(452)
    subqb #2,%a1@(452)
    jbra rsrc_DRVR_4__Sony_47C8

/* rsrc_DRVR_4__Sony_4332: IWM back to read mode (0x86 to the mode), power off the floppy (4776) */
rsrc_DRVR_4__Sony_4332:
    tstb %a0@(4096)
    moveb #0x86,%a0@(3072)
    jbra rsrc_DRVR_4__Sony_4776

/* rsrc_DRVR_4__Sony_4340: HD20: use the faster SCC poll entry on portables when the modem port is not in use */
rsrc_DRVR_4__Sony_4340:
    addqw #2,%a5
    addqw #2,%fp
    btst #0,HWCfgFlags
    jbeq rsrc_DRVR_4__Sony_4340_18
    moveq #2,%d0
    andb %a1@(314),%d0
    jbne rsrc_DRVR_4__Sony_4340_18
    lea %pc@(rsrc_DRVR_4__Sony_435A),%a5
rsrc_DRVR_4__Sony_4340_18:/* return */
    rts
rsrc_DRVR_4__Sony_435A: /* (data) */
    .short  0x0000	| 4087073A

/* rsrc_DRVR_4__Sony_435C: after a power cycle on portables: power the floppy up, restore the SWIM mode, reselect the drive */
rsrc_DRVR_4__Sony_435C:
    btst #0,HWCfgFlags
    jbeq rsrc_DRVR_4__Sony_435C_10
    jbsr rsrc_DRVR_4__Sony_4792
    jbsr rsrc_DRVR_4__Sony_47C8
rsrc_DRVR_4__Sony_435C_10:/* SWIM: controller mode */
    tstb %a1@(312)
    jbpl rsrc_DRVR_4__Sony_435C_1A
    jbsr rsrc_DRVR_4__Sony_2716
rsrc_DRVR_4__Sony_435C_1A:/* select the drive */
    jbsr rsrc_DRVR_4__Sony_1336
    rts

/* rsrc_DRVR_4__Sony_437C: point the request's buffer (a1+28) at the stack area, then power the floppy up (4792) */
rsrc_DRVR_4__Sony_437C:
    movel %a0,%sp@-	| 4087075C
    lea %sp@(8),%a0	| 4087075E
    movel %a0,%a1@(28)	| 40870762
    moveal %sp@+,%a0	| 40870766
    jbra rsrc_DRVR_4__Sony_4792	| 40870768

/* rsrc_DRVR_4__Sony_438C: start writing: ISM mode: set up the write FIFO (mode bits, first byte d6); IWM: enter write mode with the first byte */
rsrc_DRVR_4__Sony_438C:
    tstb %a1@(313)
    jbpl rsrc_DRVR_4__Sony_438C_34
    lea %a4@(-6144),%a3
    lea %a4@(1536),%a4
    moveb #24,%a3@(3072)
    moveb #16,%a3@(3584)
    moveb #1,%a3@(3584)
    moveb #1,%a3@(3072)
    tstb %a3@(5120)
    moveb %d6,%a3@
    moveb #8,%a3@(3584)
    rts
rsrc_DRVR_4__Sony_438C_34:/* IWM: write mode with the first byte */
    tstb %a3@
    moveb %d6,%a3@(1024)
    rts

/* rsrc_DRVR_4__Sony_43C8: end of a write: ISM mode: flush the FIFO, underrun error -74 in DskErr, back to read mode; IWM: test the underrun bit */
rsrc_DRVR_4__Sony_43C8:
    moveal SonyVars,%a1
    tstb %a1@(313)
    jbpl rsrc_DRVR_4__Sony_43C8_2E
    moveq #2,%d7
rsrc_DRVR_4__Sony_43C8_C:/* flush the FIFO */
    moveb %a4@,%d1
    jbpl rsrc_DRVR_4__Sony_43C8_C
    moveb #0xff,%a3@
    dbf %d7,rsrc_DRVR_4__Sony_43C8_C
    btst #5,%d1
    jbeq rsrc_DRVR_4__Sony_43C8_20
    moveq #-74,%d0
rsrc_DRVR_4__Sony_43C8_20:/* back to read mode; DskErr; pop the return */
    moveb #24,%a3@(3072)
    movew %d0,DskErr
    addqw #4,%sp
    rts
rsrc_DRVR_4__Sony_43C8_2E:/* IWM: underrun bit */
    btst #6,%d1
    rts

/* rsrc_DRVR_4__Sony_43FC: ISM: clear the action bit and read the error register; 4408: raw read entry: MFM, ISM GCR or IWM path */
rsrc_DRVR_4__Sony_43FC:
    moveb #1,%a3@(3072)
    tstb %a3@(5120)
    rts

rsrc_DRVR_4__Sony_4408: /* raw read entry: MFM, ISM GCR or IWM */
    tstb %a1@(0x17,%d1:w)
    jbmi rsrc_DRVR_4__Sony_4260_24
    cmpib #0xfe,%a1@(312)
    jbeq rsrc_DRVR_4__Sony_441C_A
    jbra rsrc_DRVR_4__Sony_42F4

/* rsrc_DRVR_4__Sony_441C: next byte of a raw read (timing byte d3); 441C_A: raw read in ISM mode: bytes into the buffer until the count runs out, -66 on a timeout */
rsrc_DRVR_4__Sony_441C:
    jbpl rsrc_DRVR_4__Sony_4260_90
    moveb %a3@,%d3
    moveq #60,%d2
    rts
rsrc_DRVR_4__Sony_441C_A:/* raw read in ISM mode */
    movel %sp@+,DskRtnAdr
    moveal IWM,%a4
    lea %a4@(7680),%a3
    lea %a4@(4608),%a4
    tstb %a4@(512)
    moveb #24,%a4@(-1536)
    moveb #1,%a4@(-1024)
    moveb #1,%a4@(-1536)
    tstb %a4@(512)
    moveb #8,%a4@(-1024)
    moveq #-1,%d2
    jbra rsrc_DRVR_4__Sony_441C_50
rsrc_DRVR_4__Sony_441C_3E:/* each byte */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    tstb %a3@
    dbmi %d2,rsrc_DRVR_4__Sony_441C_3E
    jbpl rsrc_DRVR_4__Sony_441C_60
    moveq #60,%d2
    moveb %a4@,%a0@+
rsrc_DRVR_4__Sony_441C_50:/* count */
    subql #1,%d0
    jbge rsrc_DRVR_4__Sony_441C_3E
    moveq #0,%d0
rsrc_DRVR_4__Sony_441C_56:/* back to read mode */
    moveb #24,%a4@(-1536)
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_441C_60:/* timeout: noNybErr */
    moveq #-66,%d0
    jbra rsrc_DRVR_4__Sony_441C_56

/* rsrc_DRVR_4__Sony_4480: drive icon on a docking-station (DockingDispatch 'dicn') if the Docking Manager is there */
rsrc_DRVR_4__Sony_4480:
    moveml %d1/%a0-%a1,%sp@-
    movew #-22369,%d0
    .short  0xA746	| 40870868 _GetTrapAddress (flags 0x0700)
    movel %a0,%sp@-
    movew %pc@(rsrc_DRVR_4__Sony_4480_24),%d0
    .short  0xA746	| 40870870 _GetTrapAddress (flags 0x0700)
    cmpal %sp@+,%a0
    jbeq rsrc_DRVR_4__Sony_4480_28
    movew %a1@(18),%d0
    clrl %sp@-
    movel #1684628334,%sp@-
    movel %d0,%sp@-
rsrc_DRVR_4__Sony_4480_24:  /* _DockingDispatch */
    _DockingDispatch
    movel %sp@+,%d0
rsrc_DRVR_4__Sony_4480_28:  /* restore registers, return */
    moveml %sp@+,%d1/%a0-%a1
    rts
    lea %a2@(280),%a0
    _RmvTime
    btst #0,HWCfgFlags
    beqs rsrc_DRVR_4__Sony_4480_28_22
    lea %a2@(316),%a0
    moveal PmgrBase,%a1
    lea %a1@(2),%a1
    _Dequeue
rsrc_DRVR_4__Sony_4480_28_22:/* return; then the Open helpers: SonyVars, power, the Time Manager and sleep tasks */
    rts
    movel %a0,SonyVars
    moveal %a0,%a1
    braw rsrc_DRVR_4__Sony_4792
    lea %a2@(280),%a0
    _InsTime
    btst #0,HWCfgFlags
    beqs rsrc_DRVR_4__Sony_4480_28_5C
    lea %a2@(316),%a0
    clrw %a0@(10)
    movew #16,%a0@(4)
    lea %pc@(rsrc_DRVR_4__Sony_47E6),%a1
    movel %a1,%a0@(6)
    moveal PmgrBase,%a1
    lea %a1@(2),%a1
    _Enqueue
rsrc_DRVR_4__Sony_4480_28_5C:/* return; power off and not busy */
    rts
    bsrw rsrc_DRVR_4__Sony_4776
    clrb %a1@(25)
    rts

/* rsrc_DRVR_4__Sony_4510: power the floppy up with the parameter block on the stack (4792) */
rsrc_DRVR_4__Sony_4510:
    movel %a0,%sp@-
    lea %sp@(8),%a0
    movel %a0,%a1@(28)
    moveal %sp@+,%a0
    jbra rsrc_DRVR_4__Sony_4792

/* rsrc_DRVR_4__Sony_4520: ISM mode: set up the write of a whole track through the FIFO, else return to the IWM code */
rsrc_DRVR_4__Sony_4520:
    tstb %a1@(313)
    lea %pc@(rsrc_DRVR_4__Sony_2288),%a1
    jbpl rsrc_DRVR_4__Sony_4520_3E
    addqw #4,%sp
    lea %a4@,%a3
    lea %a4@(7680),%a4
    tstb %a3@(5120)
    moveb #24,%a3@(3072)
    moveb #16,%a3@(3584)
    moveb #1,%a3@(3584)
    moveb #1,%a3@(3072)
    tstb %a3@(5120)
    moveb %d3,%a3@
    moveb #8,%a3@(3584)
    jbra rsrc_DRVR_4__Sony_243C_4A
rsrc_DRVR_4__Sony_4520_3E:/* IWM: return */
    rts

/* rsrc_DRVR_4__Sony_4560: ISM mode: flush the write FIFO and check for an underrun (-74); also the recalibrate step loop */
rsrc_DRVR_4__Sony_4560:
    moveal SonyVars,%a1
    tstb %a1@(313)
    jbpl rsrc_DRVR_4__Sony_4560_36
    moveq #2,%d2
rsrc_DRVR_4__Sony_4560_C:/* ISM: flush the FIFO */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_4560_C
    moveb #0xff,%a3@
    dbf %d2,rsrc_DRVR_4__Sony_4560_C
    moveb %a4@,%d0
    moveq #0,%d2
    btst #5,%d0
    jbeq rsrc_DRVR_4__Sony_4560_26
    moveq #-74,%d0
    jbra rsrc_DRVR_4__Sony_4560_28
rsrc_DRVR_4__Sony_4560_26:/* noErr */
    moveq #0,%d0
rsrc_DRVR_4__Sony_4560_28:/* read mode; return */
    moveb #24,%a3@(3072)
    movel DskRtnAdr,%sp@
    tstw %d0
    rts
rsrc_DRVR_4__Sony_4560_36:/* IWM */
    moveb %a4@,%d0
    moveq #0,%d2
    rts
rsrc_DRVR_4__Sony_4560_36_6:/* an error ends the request; else power on; the RdData for this controller (ISM or IWM) */
    bmiw rsrc_DRVR_4__Sony_B62_12
    braw rsrc_DRVR_4__Sony_4792
rsrc_DRVR_4__Sony_4560_36_6_8:/* the RdData for this controller (IWM or ISM) */
    lea %pc@(rsrc_DRVR_4__Sony_1E84_16),%a0
    cmpib #0xfe,%a1@(312)	| 40870988
    bnes rsrc_DRVR_4__Sony_4560_36_1E
    lea %pc@(rsrc_DRVR_4__Sony_5880_126),%a0
rsrc_DRVR_4__Sony_4560_36_1E:/* return; count a retry, the cache-permission flag clears the retry state */
    rts
rsrc_DRVR_4__Sony_4560_36_1E_2:/* count a retry; cache-permission flag clears the retry state */
    addqw #1,%a1@(250)
    tstb %a1@(335)
    beqs rsrc_DRVR_4__Sony_4560_36_32
    clrb %a1@(45)
    clrb %a1@(43)
rsrc_DRVR_4__Sony_4560_36_32:/* return */
    rts
rsrc_DRVR_4__Sony_4560_6A:/* recalibrate: 400K drives step with the settle wait */
    tstb %a1@(0x13,%d1:w)
    jbpl rsrc_DRVR_4__Sony_4560_8C
    subqw #1,%d7
rsrc_DRVR_4__Sony_4560_72:/* each step until track 0 */
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_106E
    jbpl rsrc_DRVR_4__Sony_1202_4E
    jbsr rsrc_DRVR_4__Sony_1092
    jbsr rsrc_DRVR_4__Sony_113C
    dbf %d7,rsrc_DRVR_4__Sony_4560_72
    jbra rsrc_DRVR_4__Sony_1202_52
rsrc_DRVR_4__Sony_4560_8C:/* other drives: wait and check (S_1202_32) */
    movew %a1@(60),%d0
    jbsr rsrc_DRVR_4__Sony_118A
    jbra rsrc_DRVR_4__Sony_1202_32

/* rsrc_DRVR_4__Sony_45F8: VBL task helper: reset the motor timers once the controller has been seen */
rsrc_DRVR_4__Sony_45F8:
    movew %a1@(64),%a0@(10)
    jbsr rsrc_DRVR_4__Sony_4792
    moveb %a1@(312),%d0
    subqb #1,%d0
    jbne rsrc_DRVR_4__Sony_45F8_1A
    clrw %a1@(26)
    clrw %a1@(274)
rsrc_DRVR_4__Sony_45F8_1A:/* return */
    rts

/* rsrc_DRVR_4__Sony_4614: portables: release the floppy power when idle */
rsrc_DRVR_4__Sony_4614:
    tstb %a0@(4096)
    btst #0,HWCfgFlags
    jbeq rsrc_DRVR_4__Sony_4614_1C
    tstl %d3
    bmiw rsrc_DRVR_4__Sony_4614_16
    jbra rsrc_DRVR_4__Sony_4776
rsrc_DRVR_4__Sony_4614_16:/* keep the power on */
    addql #4,%sp
    jbra rsrc_DRVR_4__Sony_1412_52
rsrc_DRVR_4__Sony_4614_1C:  /* return */
    rts

/* rsrc_DRVR_4__Sony_4632: count down the drive's "disk just inserted" state */
rsrc_DRVR_4__Sony_4632:
    btst #0,HWCfgFlags
    jbeq rsrc_DRVR_4__Sony_4632_18
    addqb #1,%a1@(0x3,%d1:w)
    jbpl rsrc_DRVR_4__Sony_14A4
    bset #31,%d3
    jbra rsrc_DRVR_4__Sony_14E6
rsrc_DRVR_4__Sony_4632_18:/* count the polls since inserted */
    addqb #1,%a1@(0x3,%d1:w)
    jbmi rsrc_DRVR_4__Sony_14E6
    jbra rsrc_DRVR_4__Sony_14A4

/* rsrc_DRVR_4__Sony_4656: is a disk in place (for a double-sided drive the other sense)? */
rsrc_DRVR_4__Sony_4656:
    tstb %a1@(0x5,%d1:w)
    jbpl rsrc_DRVR_4__Sony_4656_C
    moveb %a1@(0x16,%d1:w),%d0
    notb %d0
rsrc_DRVR_4__Sony_4656_C:/* return */
    rts

/* rsrc_DRVR_4__Sony_4664: no SWIM found? return -1 to the caller's caller; else sense the disk-in-place register */
rsrc_DRVR_4__Sony_4664:
    cmpib #0xfe,%a1@(312)
    jbne rsrc_DRVR_4__Sony_4664_E
    addqw #4,%sp
    moveq #-1,%d0
    rts
rsrc_DRVR_4__Sony_4664_E:/* register 13 */
    moveq #13,%d0
    jbra rsrc_DRVR_4__Sony_106E

/* rsrc_DRVR_4__Sony_4678: select drive d0; no controller found: offLinErr */
rsrc_DRVR_4__Sony_4678:
    movew %d0,%a1@(18)
    moveq #-64,%d0
    tstb %a1@(312)
    jble rsrc_DRVR_4__Sony_4678_E
    addqw #4,%sp
rsrc_DRVR_4__Sony_4678_E:/* return */
    rts

/* rsrc_DRVR_4__Sony_4688: probe the floppy controller with a bus error guard: none (bus error): d0 = -64; IWM or SWIM: check the mode register reads back */
rsrc_DRVR_4__Sony_4688:
    moveml %d2/%a0-%a1,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    movel BusErrorVector,%sp@-
    pea %pc@(rsrc_DRVR_4__Sony_4688_28)
    movel %sp@+,BusErrorVector
    movel %sp,%d2
    moveq #-64,%d0
    moveal IWM,%a0
    moveal ROMBase,%a1
    tstb %a0@(6144)
    moveq #0,%d0

/* rsrc_DRVR_4__Sony_4688_28: after the probe: restore the bus error vector; check the SWIM parameter register and the IWM mode register read back; neither: -64 */
rsrc_DRVR_4__Sony_4688_28:
    moveal %d2,%sp
    movel %sp@+,BusErrorVector
    movew %sp@+,%sr
    tstw %d0
    jbne rsrc_DRVR_4__Sony_4688_66
    moveb #0xf8,%a0@(3072)
    moveq #-11,%d2
    moveb %d2,%a0@(2048)
    tstb %a1@
    cmpb %a0@(6144),%d2
    jbeq rsrc_DRVR_4__Sony_4688_66
    tstb %a0@(7168)
    tstb %a0@(6144)
    moveb %d0,%a0@(7680)
    moveq #63,%d2
    andb %a0@(6144),%d2
    tstb %a0@(7168)
    cmpib #63,%d2
    jbeq rsrc_DRVR_4__Sony_4688_66
    moveq #-64,%d0
rsrc_DRVR_4__Sony_4688_66:  /* restore registers, return */
    moveml %sp@+,%d2/%a0-%a1
    rts

/* rsrc_DRVR_4__Sony_46F4: Open helper: clear the driver's state and power the floppy up */
rsrc_DRVR_4__Sony_46F4:
    st %a0@(25)
    clrb %a0@(335)
    moveal %a0,%a1
    jbra rsrc_DRVR_4__Sony_4792

/* rsrc_DRVR_4__Sony_4702: install the Time Manager task, on portables a sleep queue entry (S_47E6), probe the controller (4688), record it */
rsrc_DRVR_4__Sony_4702:
    lea %a2@(280),%a0
    _InsTime
    btst #0,HWCfgFlags
    jbeq rsrc_DRVR_4__Sony_4702_26
    lea %a2@(316),%a0
    clrw %a0@(10)
    movew #16,%a0@(4)
    lea %pc@(rsrc_DRVR_4__Sony_47E6),%a1
    movel %a1,%a0@(6)
    .short  0xA28A	| 40870B06 _Sleep (flags 0x0200)
rsrc_DRVR_4__Sony_4702_26:/* probe the controller; none: mark it absent */
    jbsr rsrc_DRVR_4__Sony_4688
    jbeq rsrc_DRVR_4__Sony_4702_3E
    addqw #4,%sp
    moveal SonyVars,%a1
    moveb #1,%a1@(312)
    bsrw rsrc_DRVR_4__Sony_4742
    moveq #0,%d0
rsrc_DRVR_4__Sony_4702_3E:  /* return */
    rts

/* rsrc_DRVR_4__Sony_4742: controller present: done with power */
rsrc_DRVR_4__Sony_4742:
    clrb %a1@(25)
    jbra rsrc_DRVR_4__Sony_4776

/* rsrc_DRVR_4__Sony_4748: mark the drive as just installed (a1+4) unless already */
rsrc_DRVR_4__Sony_4748:
    jbsr rsrc_DRVR_4__Sony_1008
    tstb %a1@(0x4,%d1:w)
    jbgt rsrc_DRVR_4__Sony_4748_E
    st %a1@(0x4,%d1:w)
rsrc_DRVR_4__Sony_4748_E:/* return */
    rts

rsrc_DRVR_4__Sony_4758: /* IODone: the error into DskErr */
    jbeq rsrc_DRVR_4__Sony_4758_6
    movew %d0,DskErr
rsrc_DRVR_4__Sony_4758_6:/* not busy; JIODone */
    moveal SonyVars,%a1
    clrb %a1@(25)
    moveal %a1@,%a1
    movel JIODone,%sp@-
    rts

/* rsrc_DRVR_4__Sony_476E: power up and test the drive's "installed" flag */
rsrc_DRVR_4__Sony_476E:
    jbsr rsrc_DRVR_4__Sony_4792	| 40870B4E
    tstb %a1@(3,%d1:w)	| 40870B50
    rts	| 40870B54

/* rsrc_DRVR_4__Sony_4776: portables: turn the floppy power off (PMgrOp) if we turned it on */
rsrc_DRVR_4__Sony_4776: /* turn the power off if we turned it on */
    btst #0,HWCfgFlags
    jbeq rsrc_DRVR_4__Sony_4792_34
    moveml %d0/%a0,%sp@-
    moveq #1,%d0
    andb %a1@(314),%d0
    jbeq rsrc_DRVR_4__Sony_4792_30
    clrb %a1@(314)
    moveq #1,%d0
    jbra rsrc_DRVR_4__Sony_4792_1C

/* rsrc_DRVR_4__Sony_4792: portables (HWCfgFlags bit 0): turn the floppy power on through PMgrOp unless already on */
rsrc_DRVR_4__Sony_4792:
    btst #0,HWCfgFlags
    jbeq rsrc_DRVR_4__Sony_4792_34
    moveml %d0/%a0,%sp@-
    moveq #1,%d0
    andb %a1@(314),%d0
    jbne rsrc_DRVR_4__Sony_4792_30
    movew #129,%d0
    moveb %d0,%a1@(314)
rsrc_DRVR_4__Sony_4792_1C:/* PMgrOp: floppy power (0x1001) */
    moveb %d0,%sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movel #1048577,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(14),%sp
rsrc_DRVR_4__Sony_4792_30:  /* restore registers */
    moveml %sp@+,%d0/%a0
rsrc_DRVR_4__Sony_4792_34:  /* return */
    rts

/* rsrc_DRVR_4__Sony_47C8: portables: tell the Power Manager the floppy's state (PMgrOp); S_47E6 is the sleep queue routine: refuse sleep while busy, power down / restore the SWIM after sleep */
rsrc_DRVR_4__Sony_47C8:
    moveml %d0/%a0,%sp@-
    pea %a1@(314)
    movel %sp@,%sp@-
    movel #1572864,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    moveml %sp@+,%d0/%a0
    rts

rsrc_DRVR_4__Sony_47E6:  /* save registers */
    moveml %d1-%fp,%sp@-
    moveal SonyVars,%a1
    cmpiw #3,%d0
    jbeq rsrc_DRVR_4__Sony_47E6_30
    st %a1@(25)
    tstb %a1@(312)
    jbpl rsrc_DRVR_4__Sony_47E6_2C
    moveq #90,%d1
    addl Ticks,%d1
rsrc_DRVR_4__Sony_47E6_1E:/* wait up to 1.5 s for the drive to go idle */
    cmpl Ticks,%d1
    jbls rsrc_DRVR_4__Sony_47E6_2C
    moveq #1,%d0
    andb %a1@(314),%d0
    jbne rsrc_DRVR_4__Sony_47E6_1E
rsrc_DRVR_4__Sony_47E6_2C:/* allow sleep */
    moveq #0,%d0
    jbra rsrc_DRVR_4__Sony_47E6_84
rsrc_DRVR_4__Sony_47E6_30:/* wake-up: power back on, re-probe the controller */
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #1,%d1
    andb %a1@(314),%d1
    clrb %a1@(314)
    jbsr rsrc_DRVR_4__Sony_4792
    moveal IWM,%a0
    moveb #0xf8,%a0@(3072)
    tstb %a0@(7168)
    moveb #1,%a1@(312)
    jbsr rsrc_DRVR_4__Sony_4688
    jbne rsrc_DRVR_4__Sony_47E6_8A
    clrb %a1@(312)
    jbsr rsrc_DRVR_4__Sony_26A6
    cmpib #0xfe,%a1@(312)
    seq %a1@(313)
    moveb %d1,%sp@-
    jbsr rsrc_DRVR_4__Sony_2716
    jbsr rsrc_DRVR_4__Sony_6D6
    tstb %sp@+
    jbeq rsrc_DRVR_4__Sony_47E6_8A
rsrc_DRVR_4__Sony_47E6_7E:/* not busy */
    clrb %a1@(25)
    movew %sp@+,%sr
rsrc_DRVR_4__Sony_47E6_84:  /* restore registers, return */
    moveml %sp@+,%d1-%fp
    rts
rsrc_DRVR_4__Sony_47E6_8A:/* power off, done */
    jbsr rsrc_DRVR_4__Sony_4776
    jbra rsrc_DRVR_4__Sony_47E6_7E

/* rsrc_DRVR_4__Sony_4876: adjust the saved stack frame after an SCC poll when fp-4 bit 0 is set; followed by the Control handler that sets or clears the flag at a1+335 */
rsrc_DRVR_4__Sony_4876:
    btst #0,%fp@(-4)
    jbeq rsrc_DRVR_4__Sony_4876_12
    subqw #2,%sp
    movel %sp@(2),%sp@
    moveb %fp@,%sp@(4)
rsrc_DRVR_4__Sony_4876_12:/* return */
    rts
SONY_CTL_csCP:          /* Control: track cache permission flag (a1+335) from csParam */
    tstw %a0@(28)	| 40870C6A
    jbne SONY_CTL_csCP_C	| 40870C6E
    st %a1@(335)	| 40870C70
    jbra SONY_CTL_csCP_10	| 40870C74
SONY_CTL_csCP_C:        /* clear */
    clrb %a1@(335)	| 40870C76
SONY_CTL_csCP_10:       /* noErr */
    moveq #0,%d0	| 40870C7A
    jbra rsrc_DRVR_4__Sony_784	| 40870C7C
SONY_CTL_csCP_16:       /* (eject for drive numbers 3+) clear the disk-in-place state */
    clrb %a1@(3,%d1:w)	| 40870C80
    moveq #0,%d0	| 40870C84
rsrc_DRVR_4__Sony_48A6: /* finish; the machine/drive configuration tables follow */
    jbra rsrc_DRVR_4__Sony_784	| 40870C86
    .byte   0x00, 0x00	| 40870C8A
rsrc_DRVR_4__Sony_48AC: /* (data) */
    .byte   0xFF, 0xFF, 0xCC, 0x5C, 0x00, 0x01, 0xFF, 0xFF, 0xCC, 0x56, 0x00, 0x03, 0xFF, 0xFF, 0xCC, 0x80	| 40870C8C
    .byte   0x00, 0x02, 0xFF, 0xFF, 0xCC, 0x62, 0x00, 0x05, 0xFF, 0xFF, 0xCC, 0x5C, 0x00, 0x07, 0xFF, 0xFF	| 40870C9C
    .byte   0xCC, 0x3E, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x8E, 0x00, 0x0D, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x0E	| 40870CAC
    .byte   0x00, 0x00, 0x00, 0xB2, 0x00, 0x0F, 0x00, 0x00, 0x00, 0xC4, 0x00, 0x10, 0x00, 0x00, 0x00, 0xD6	| 40870CBC
    .byte   0x00, 0x14, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x15, 0x00, 0x00, 0x00, 0x82, 0x00, 0x38, 0x00, 0x00	| 40870CCC
    .byte   0x00, 0x7C, 0x00, 0x17, 0x00, 0x00, 0x00, 0xD6, 0x00, 0x1A, 0x00, 0x00, 0x00, 0xD0, 0x00, 0x20	| 40870CDC
    .byte   0x00, 0x00, 0x00, 0xCA, 0x00, 0x21, 0x00, 0x00, 0x00, 0xC4, 0x00, 0x1B, 0x00, 0x00, 0x00, 0x8E	| 40870CEC
    .byte   0x00, 0x1C, 0x00, 0x00, 0x00, 0x88, 0x00, 0x34, 0x00, 0x00, 0x00, 0xCA, 0x00, 0x18, 0x00, 0x00	| 40870CFC
    .byte   0x00, 0xC4, 0x00, 0x1E, 0x00, 0x00, 0x00, 0xBE, 0x00, 0x2D, 0x00, 0x00, 0x00, 0xB8, 0x00, 0x1D	| 40870D0C
    .byte   0x00, 0x00, 0x00, 0xCA, 0x00, 0x35, 0x00, 0x00, 0x00, 0xC4, 0x00, 0x2E, 0x00, 0x00, 0x00, 0xD6	| 40870D1C
    .byte   0x00, 0x2F, 0x00, 0x00, 0x00, 0xD0, 0x00, 0x33, 0x00, 0x00, 0x00, 0xCA, 0xFF, 0x00, 0x00, 0x00	| 40870D2C
    .byte   0x00, 0x00, 0xCB, 0xF2, 0x00, 0xD8, 0x00, 0x03, 0xCB, 0xF2, 0x01, 0xDA, 0x01, 0x03, 0xCB, 0xF2	| 40870D3C
    .byte   0xCB, 0xF2, 0x05, 0x07, 0xCB, 0xF2, 0xCB, 0xF2, 0x0D, 0x07, 0xCB, 0xDA, 0x03, 0xC6, 0x00, 0x04	| 40870D4C
    .byte   0xCB, 0xDA, 0x02, 0xC4, 0x08, 0x04, 0xCB, 0xDA, 0xCB, 0xDA, 0x05, 0x07, 0xCB, 0xDA, 0xCB, 0xDA	| 40870D5C
    .byte   0x0D, 0x07, 0xCB, 0xC2, 0x04, 0xB0, 0x00, 0x04, 0xCB, 0xC2, 0x04, 0xB0, 0x01, 0x04, 0xCB, 0xC2	| 40870D6C
    .byte   0xCB, 0xC2, 0x05, 0x07, 0xCB, 0xC2, 0xCB, 0xC2, 0x0D, 0x07, 0xCB, 0xAA, 0x05, 0x9A, 0x00, 0x04	| 40870D7C
    .byte   0xCB, 0xAA, 0x05, 0x9A, 0x01, 0x04, 0xCB, 0xAA, 0xCB, 0xAA, 0x05, 0x07, 0xCB, 0xAA, 0xCB, 0xAA	| 40870D8C
    .byte   0x0D, 0x07, 0xCB, 0x92, 0x06, 0x84, 0x00, 0x04, 0xCB, 0x92, 0x06, 0x84, 0x01, 0x04, 0xCB, 0x92	| 40870D9C
    .byte   0xCB, 0x92, 0x05, 0x07, 0xCB, 0x92, 0xCB, 0x92, 0x0D, 0x07, 0xCB, 0x7A, 0x07, 0x6E, 0x01, 0x04	| 40870DAC
    .byte   0xCB, 0x7A, 0x07, 0x6E, 0x09, 0x04, 0xCB, 0x7A, 0xCB, 0x7A, 0x05, 0x07, 0xCB, 0x7A, 0xCB, 0x7A	| 40870DBC
    .byte   0x0D, 0x07, 0xCB, 0x62, 0x08, 0x58, 0x00, 0x04, 0xCB, 0x62, 0x08, 0x58, 0x01, 0x04, 0xCB, 0x62	| 40870DCC
    .byte   0xCB, 0x62, 0x05, 0x07, 0xCB, 0x62, 0xCB, 0x62, 0x0D, 0x07, 0xCB, 0x4A, 0x09, 0x42, 0x00, 0x04	| 40870DDC
    .byte   0xCB, 0x4A, 0x09, 0x42, 0x01, 0x04, 0xCB, 0x4A, 0xCB, 0x4A, 0x05, 0x07, 0xCB, 0x4A, 0xCB, 0x4A	| 40870DEC
    .byte   0x0D, 0x07, 0xCB, 0x32, 0x0A, 0x2C, 0x00, 0x04, 0xCB, 0x32, 0x0A, 0x2C, 0x01, 0x04, 0xCB, 0x32	| 40870DFC
    .byte   0xCB, 0x32, 0x05, 0x07, 0xCB, 0x32, 0xCB, 0x32, 0x0D, 0x07	| 40870E0C
    .include "rsrc/icons/sony_b.s"

/* SONY_ICON_DRIVE17_mask_82: (code after the icon data) find the drive: a2 = SonyVars, a3 = its queue element; none: nsDrvErr (-36) */
SONY_ICON_DRIVE17_mask_82:
    moveal %a1,%a2	| 4087192C
    moveal SonyVars,%a1	| 4087192E
    lea %a1@(-72),%a3	| 40871932
    bsrw rsrc_DRVR_4__Sony_558E
    jbne rsrc_DRVR_4__Sony_5564
    moveq #-36,%d0
    addqw #4,%sp
    jbra rsrc_DRVR_4__Sony_358
rsrc_DRVR_4__Sony_5564: /* return */
    rts

/* rsrc_DRVR_4__Sony_5566: find the drive of the parameter block (drive number at +26, 7 = the internal second drive) and its variables: d1 = format, d0 = drive, d2 = the I/O drive */
rsrc_DRVR_4__Sony_5566:
    moveal SonyVars,%a1
    cmpiw #7,%a0@(26)
    jbeq rsrc_DRVR_4__Sony_5566_1A
    bsrw rsrc_DRVR_4__Sony_558E
    jbne rsrc_DRVR_4__Sony_5566_1A
    moveq #-36,%d0
    addqw #4,%sp
    jbra rsrc_DRVR_4__Sony_358
rsrc_DRVR_4__Sony_5566_1A:/* its variables: d1 = format, d0 = drive */
    moveal %a1@(0x0,%a2:l),%a2
    movew %a2@+,%d1
    movew %a2@+,%d0
    movew %a0@(26),%d2
    rts

/* rsrc_DRVR_4__Sony_558E: is the drive slot present on this machine? (5612 on VIA2) */
rsrc_DRVR_4__Sony_558E:
    jbsr rsrc_DRVR_4__Sony_55BA
    jbeq rsrc_DRVR_4__Sony_558E_6
    rts
rsrc_DRVR_4__Sony_558E_6:/* on VIA2 */
    movel %a1,%d0
    moveal ghost_VIA2,%a1
    bsrw rsrc_DRVR_4__Sony_5612
    moveal %d0,%a1
    rts

/* rsrc_DRVR_4__Sony_55A2: IOP variant: status reply for a drive */
rsrc_DRVR_4__Sony_55A2:
    cmpib #1,%d2	| 40871982
    bnes rsrc_DRVR_4__Sony_558E_2A
    jbsr rsrc_DRVR_4__Sony_558E
    jbne rsrc_DRVR_4__Sony_558E_28
    jbsr rsrc_DRVR_4__Sony_50A
    moveb #2,%d2
    jbra rsrc_DRVR_4__Sony_558E_2A
rsrc_DRVR_4__Sony_558E_28:/* no */
    moveq #0,%d0
rsrc_DRVR_4__Sony_558E_2A:  /* return */
    rts

/* rsrc_DRVR_4__Sony_55BA: d0 = test of the hardware flags at 0xDD4 bits 18..19 (machine without the external floppy port) */
rsrc_DRVR_4__Sony_55BA:
    movel %d0,%sp@-
    movel #786432,%d0
    andl 0xdd4,%d0
    subil #262144,%d0
    moveml %sp@+,%d0
    rts

/* rsrc_DRVR_4__Sony_55D2: make sure the SCC is not starved: on machines with the second SCC channel registers, toggle them */
rsrc_DRVR_4__Sony_55D2:
    btst #4,%a1@(6656)
    jbne rsrc_DRVR_4__Sony_55D2_3E
    moveal ASCBase,%a1
    cmpaw #-1,%a1
    jbeq rsrc_DRVR_4__Sony_55D2_3E
    movew %sr,%sp@-
    oriw #1792,%sr
    tstb %a1@(3849)
    jbne rsrc_DRVR_4__Sony_55D2_2A
    moveb #1,%a1@(3849)
    nop
    clrb %a1@(3849)
rsrc_DRVR_4__Sony_55D2_2A:/* second channel */
    tstb %a1@(3881)
    jbne rsrc_DRVR_4__Sony_55D2_3C
    moveb #1,%a1@(3881)
    nop
    clrb %a1@(3881)
rsrc_DRVR_4__Sony_55D2_3C:/* restore interrupts */
    movew %sp@+,%sr
rsrc_DRVR_4__Sony_55D2_3E:  /* return */
    rts

/* rsrc_DRVR_4__Sony_5612: test a VIA2 port bit (drive slot), keeping the SCC fed */
rsrc_DRVR_4__Sony_5612:
    moveml %d0/%a1,%sp@-
    moveb %a1@,%d0
    jbsr rsrc_DRVR_4__Sony_55D2
    btst #0,%d0
    moveml %sp@+,%d0/%a1
    rts

rsrc_DRVR_4__Sony_5624: /* switch a detected SWIM to ISM mode: check its parameter registers, install the ISM RdAddr/RdData, calibrate (S_566E) */
    tstb %a1@(312)
    jbpl rsrc_DRVR_4__Sony_5624_46
    moveq #-11,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne rsrc_DRVR_4__Sony_5624_46
    moveq #-10,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne rsrc_DRVR_4__Sony_5624_46
    moveq #-9,%d0
    moveb %d0,%a0@(2048)
    cmpb %a0@(6144),%d0
    jbne rsrc_DRVR_4__Sony_5624_46
    subqb #1,%a1@(312)
    st %a1@(313)
    lea %pc@(rsrc_DRVR_4__Sony_5880_A),%a0
    movel %a0,DiskVars_JRdAddr
    lea %pc@(rsrc_DRVR_4__Sony_5880_126),%a0
    movel %a0,DiskVars_JRdData
    bsrw rsrc_DRVR_4__Sony_566E
rsrc_DRVR_4__Sony_5624_46:/* return */
    movew %sp@+,%sr
    rts

/* rsrc_DRVR_4__Sony_566E: SWIM in ISM mode: initialise the ISM: parameter RAM, mode, and measure the clock with the VIA timer */
rsrc_DRVR_4__Sony_566E:
    moveml %d0-%d3/%a2-%a4,%sp@-
    moveal IWM,%a4
    moveal VIA,%a2
    lea %a4@,%a3
    lea %a4@(7680),%a4
    moveb #32,%a3@(2560)
    moveb #0x86,%a3@(3072)
    moveb #24,%a3@(3072)
    moveb #16,%a3@(3584)
    moveb #1,%a3@(3584)
    moveb #1,%a3@(3072)
    tstb %a3@(5120)
    moveq #20,%d0
    moveb %d0,%a3@
    moveb %d0,%a3@
    moveb %a2@(4608),%d1
    moveb %a2@(4096),%d3
    cmpb %a2@(4608),%d1
    jbeq rsrc_DRVR_4__Sony_566E_50
    moveq #0,%d3
rsrc_DRVR_4__Sony_566E_50:/* time the ISM FIFO with the VIA timer */
    lslw #8,%d1
    moveb %d3,%d1
    moveb #8,%a3@(3584)
rsrc_DRVR_4__Sony_566E_5A:/* fill */
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_566E_5A
    moveb %d0,%a3@
    dbf %d0,rsrc_DRVR_4__Sony_566E_5A
    moveb #24,%a3@(3072)
    moveb %a2@(4608),%d2
    moveb %a2@(4096),%d3
    cmpb %a2@(4608),%d2
    jbeq rsrc_DRVR_4__Sony_566E_7A
    moveq #0,%d3
rsrc_DRVR_4__Sony_566E_7A:/* elapsed time: a fast or slow clock (a1+334) */
    lslw #8,%d2
    moveb %d3,%d2
    moveb %a2@(4608),%a2@(4608)
    clrb %a1@(334)
    subw %d2,%d1
    jbmi rsrc_DRVR_4__Sony_566E_94
    cmpiw #187,%d1
    slt %a1@(334)
rsrc_DRVR_4__Sony_566E_94:  /* restore registers, return */
    moveml %sp@+,%d0-%d3/%a2-%a4
    rts

/* rsrc_DRVR_4__Sony_5708: interrupts off; a0 = IWM; Z = the controller is a SWIM in ISM mode (a1+312 = 0xFE) */
rsrc_DRVR_4__Sony_5708: /* interrupts off (the return kept); Z = ISM mode */
    movel %sp@+,%d2
    movew %sr,%sp@-
    oriw #1792,%sr
    movel %d2,%sp@-
    moveal IWM,%a0
    cmpib #0xfe,%a1@(312)
    rts

/* rsrc_DRVR_4__Sony_571E: ISM mode register value for the drive (MFM or GCR, fast clock) */
rsrc_DRVR_4__Sony_571E:
    tstb %a1@(0x17,%d1:w)
    jbmi rsrc_DRVR_4__Sony_571E_8
    moveq #68,%d0
rsrc_DRVR_4__Sony_571E_8:/* fast clock? */
    cmpib #0xfe,%a1@(312)
    jbne rsrc_DRVR_4__Sony_571E_1A
    tstb %a1@(334)
    jbeq rsrc_DRVR_4__Sony_571E_1A
    bset #3,%d0
rsrc_DRVR_4__Sony_571E_1A:/* set the mode */
    moveb %d0,%a0@(2560)
    rts

/* rsrc_DRVR_4__Sony_573E: ISM: select side d0 bit 1 */
rsrc_DRVR_4__Sony_573E:
    btst #1,%d0
    jbeq rsrc_DRVR_4__Sony_573E_E
    moveb #32,%a0@(3584)
    jbra rsrc_DRVR_4__Sony_573E_14
rsrc_DRVR_4__Sony_573E_E:/* head 0 */
    moveb #32,%a0@(3072)
rsrc_DRVR_4__Sony_573E_14:/* return */
    btst #1,%d0
    rts

/* rsrc_DRVR_4__Sony_5758: deselect the head select line */
rsrc_DRVR_4__Sony_5758:
    bclr #5,%a2@(7680)
    moveb #32,%a0@(3072)
    rts

/* rsrc_DRVR_4__Sony_5766: check the drive's speed/parameter bytes in ISM mode; reload them when they differ */
rsrc_DRVR_4__Sony_5766:
    lea %pc@(rsrc_DRVR_4__Sony_2838),%a2
    tstb %a1@(0x17,%d1:w)
    jbmi rsrc_DRVR_4__Sony_5766_E
    lea %pc@(rsrc_DRVR_4__Sony_2848),%a2
rsrc_DRVR_4__Sony_5766_E:/* ISM mode? check the parameter bytes (top nibbles) */
    cmpib #0xfe,%a1@(312)
    jbne rsrc_DRVR_4__Sony_5766_74
    movel %d3,%sp@
    moveal VIA,%a1
    lea %a1@(7680),%a1
    moveq #4,%d2
rsrc_DRVR_4__Sony_5766_22:/* compare */
    moveb #56,%a0@(3072)
    swap %d2
    moveq #3,%d0
rsrc_DRVR_4__Sony_5766_2C:/* each byte */
    moveb %a1@,%a1@
    moveb %a0@(5632),%d2
    moveb %a0@(5632),%d3
    moveb %a2@(0x0,%d0:w),%d3
    subqb #1,%d0
    lsrb #4,%d2
    lsrb #4,%d3
    cmpb %d2,%d3
    dbne %d0,rsrc_DRVR_4__Sony_5766_2C
    jbne rsrc_DRVR_4__Sony_5766_52
    moveal SonyVars,%a1
    movel %sp@+,%d3
    moveq #0,%d0
    rts
rsrc_DRVR_4__Sony_5766_52:/* differ: load them */
    moveb #56,%a0@(3072)
    moveq #3,%d0
rsrc_DRVR_4__Sony_5766_5A:/* each byte */
    moveb %a1@,%a1@
    moveb %a2@(0x0,%d0:w),%a0@(1536)
    dbf %d0,rsrc_DRVR_4__Sony_5766_5A
    swap %d2
    dbf %d2,rsrc_DRVR_4__Sony_5766_22
    moveal SonyVars,%a1
    movel %sp@+,%d3
    moveq #-77,%d0
rsrc_DRVR_4__Sony_5766_74:  /* return */
    rts
rsrc_DRVR_4__Sony_5766_76:/* (MFM read) the ID mark, up to 3 tries */
    moveq #3,%d1
    moveq #-1,%d2
    movel %a1,%d5
    moveal SonyVars,%a1
    cmpib #0xfe,%a1@(312)
    moveal %d5,%a1
    jbne rsrc_DRVR_4__Sony_5766_92
    moveb %a4@,%d5
    moveb %a4@,%d5
    tstb %a4@(512)
rsrc_DRVR_4__Sony_5766_92:/* then the sector */
    jbra rsrc_DRVR_4__Sony_2AE6_38
    btst #5,%a4@(3072)
    beqs rsrc_DRVR_4__Sony_5766_92_10
    tstb %a4@(512)
rsrc_DRVR_4__Sony_5766_92_10:/* return */
    rts
rsrc_DRVR_4__Sony_5766_A4:/* ISM: reset the FIFO, start reading */
    tstb %a4@(512)
    moveb #24,%a4@(-1536)
    moveb #1,%a4@(-1024)
    moveb #1,%a4@(-1536)
    btst #5,%a4@(3072)
    jbeq rsrc_DRVR_4__Sony_5766_C6
    tstb %a4@(512)
rsrc_DRVR_4__Sony_5766_C6:/* look for the address mark */
    moveb #8,%a4@(-1024)
    moveal %a2,%a0
    moveq #3,%d1
rsrc_DRVR_4__Sony_5766_D0:/* next byte */
    tstb %a5@
    btst #0,%fp@(-4)
    jbeq rsrc_DRVR_4__Sony_5766_DC
    moveb %fp@,%sp@-
rsrc_DRVR_4__Sony_5766_DC:/* matches? then the ID (S_2A8C) */
    tstb %a3@
    dbmi %d2,rsrc_DRVR_4__Sony_5766_D0
    jbpl rsrc_DRVR_4__Sony_2AE6_C0
    moveb %a4@,%d5
    cmpb %a0@+,%d5
    dbne %d1,rsrc_DRVR_4__Sony_5766_D0
    jbeq rsrc_DRVR_4__Sony_2A8C
    moveb #8,%a4@(-1536)
    jbra rsrc_DRVR_4__Sony_5766_A4
rsrc_DRVR_4__Sony_5766_FA:/* the data mark: read or verify */
    jbeq rsrc_DRVR_4__Sony_5766_10E
    moveb #8,%a4@(-1536)
    lea %pc@(rsrc_DRVR_4__Sony_2AE2),%a1
    dbf %d4,rsrc_DRVR_4__Sony_2AE6_12
    jbra rsrc_DRVR_4__Sony_2AE6_C0
rsrc_DRVR_4__Sony_5766_10E:/* 512 bytes */
    movew #511,%d4
    tstb DskVerify
    jbra rsrc_DRVR_4__Sony_2AE6_56

/* rsrc_DRVR_4__Sony_5880: ISM mode RdAddr / RdData (installed in DiskVars when the SWIM switches to ISM): read MFM/GCR address and data through the ISM FIFO */
rsrc_DRVR_4__Sony_5880: /* next byte */
    jbpl rsrc_DRVR_4__Sony_2AE6_CE
    moveb %a3@,%d5
    moveb %a4@,%a0@+
    rts
rsrc_DRVR_4__Sony_5880_A:/* ISM GCR RdAddr: find sync */
    moveq #3,%d3
    movew #575,%d2
    moveq #0,%d5
    moveal IWM,%a4
    lea %a4@(4096),%a4
    tstb %a4@(1024)
    moveb #24,%a4@(-1024)
    moveb #1,%a4@(-512)
    moveb #1,%a4@(-1024)
    tstb %a4@(1024)
    moveb #8,%a4@(-512)
    movel %sp@+,DskRtnAdr
rsrc_DRVR_4__Sony_5880_3E:/* next byte */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    tstb %a4@(3584)
    dbf %d2,rsrc_DRVR_4__Sony_5880_52
    moveq #-66,%d0
    jbra rsrc_DRVR_4__Sony_5880_114
rsrc_DRVR_4__Sony_5880_52:/* three syncs */
    jbpl rsrc_DRVR_4__Sony_5880_3E
    moveb %a4@,%d5
    subqw #1,%d3
    jbne rsrc_DRVR_4__Sony_5880_3E
    movew #1500,%d0
    tstb %a1@(0x13,%d1:w)
    jbeq rsrc_DRVR_4__Sony_5880_68
    movew #1468,%d0
rsrc_DRVR_4__Sony_5880_68:/* the decoding table */
    lea %pc@(rsrc_DRVR_4__Sony_1E84_15C),%a3
rsrc_DRVR_4__Sony_5880_6C:/* look for D5 AA 96 */
    moveal %a2,%a0
    moveq #3,%d1
rsrc_DRVR_4__Sony_5880_70:/* next nibble */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_70
    moveb %a4@,%d5
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    dbf %d0,rsrc_DRVR_4__Sony_5880_88
    moveq #-67,%d0
    jbra rsrc_DRVR_4__Sony_5880_114
rsrc_DRVR_4__Sony_5880_88:/* compare */
    cmpb %a0@+,%d5
    jbne rsrc_DRVR_4__Sony_5880_6C
    subqw #1,%d1
    jbne rsrc_DRVR_4__Sony_5880_70
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_96:/* track */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_96
    moveb %a4@,%d5
    moveb %a3@(0x0,%d5:w),%d1
    moveb %d1,%d4
    rorw #6,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_AC:/* sector */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_AC
    moveb %a4@,%d5
    moveq #0,%d2
    moveb %a3@(0x0,%d5:w),%d2
    eorb %d2,%d4
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_C2:/* side */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_C2
    moveb %a4@,%d5
    moveb %a3@(0x0,%d5:w),%d1
    eorb %d1,%d4
    rolw #6,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_D8:/* format */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_D8
    moveb %a4@,%d5
    moveb %a3@(0x0,%d5:w),%d3
    eorb %d3,%d4
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_EC:/* checksum */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_EC
    moveb %a4@,%d5
    moveb %a3@(0x0,%d5:w),%d5
    eorb %d5,%d4
    jbne rsrc_DRVR_4__Sony_5880_11E
    moveq #1,%d4
rsrc_DRVR_4__Sony_5880_FE:/* the bit-slip marks */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_104:/* compare */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_104
    moveb %a4@,%d5
    cmpb %a0@+,%d5
    jbne rsrc_DRVR_4__Sony_5880_122
    dbf %d4,rsrc_DRVR_4__Sony_5880_FE
rsrc_DRVR_4__Sony_5880_114:/* read mode; return */
    moveb #24,%a4@(-1024)
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_5880_11E:/* badCksmErr */
    moveq #-69,%d0
    jbra rsrc_DRVR_4__Sony_5880_114
rsrc_DRVR_4__Sony_5880_122:/* badBtSlpErr */
    moveq #-70,%d0
    jbra rsrc_DRVR_4__Sony_5880_114
rsrc_DRVR_4__Sony_5880_126:/* ISM GCR RdData */
    movel %sp@+,DskRtnAdr
    moveq #48,%d2
    moveq #0,%d3
    moveq #-64,%d0
    movel #33423370,%d4
    moveq #0,%d5
    moveq #0,%d6
    moveq #0,%d7
    tstb %a4@(1024)
    moveb #8,%a4@(-512)
rsrc_DRVR_4__Sony_5880_146:/* the data mark */
    moveal %a1,%a2
    moveq #3,%d1
rsrc_DRVR_4__Sony_5880_14A:/* next nibble */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_14A
    moveb %a4@,%d3
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    dbf %d2,rsrc_DRVR_4__Sony_5880_160
    moveq #-71,%d0
    jbra rsrc_DRVR_4__Sony_5880_114
rsrc_DRVR_4__Sony_5880_160:/* compare */
    cmpb %a2@+,%d3
    jbne rsrc_DRVR_4__Sony_5880_146
    subqw #1,%d1
    jbne rsrc_DRVR_4__Sony_5880_14A
rsrc_DRVR_4__Sony_5880_168:/* sector number; tags */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_168
    moveb %a4@,%d3
    lea TagData_1,%a1
    moveb %a3@(0x0,%d3:w),%a1@+
rsrc_DRVR_4__Sony_5880_178:/* 4 nibbles to 3 bytes */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_178
    moveb %a4@,%d3
    moveb %a3@(0x0,%d3:w),%d1
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_5880_190:/* first */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_190
    moveb %a4@,%d3
    orb %a3@(0x0,%d3:w),%d2
    moveb %d7,%d3
    addb %d7,%d3
    rolb #1,%d7
    eorb %d7,%d2
    moveb %d2,%a1@+
    addxb %d2,%d5
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_5880_1AE:/* second */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_1AE
    moveb %a4@,%d3
    orb %a3@(0x0,%d3:w),%d2
    eorb %d5,%d2
    moveb %d2,%a1@+
    addxb %d2,%d6
    rolb #2,%d1
    andb %d0,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_1CA:/* third */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_1CA
    moveb %a4@,%d3
    orb %a3@(0x0,%d3:w),%d1
    eorb %d6,%d1
    moveb %d1,%a1@+
    addxb %d1,%d7
    subqw #3,%d4
    jbpl rsrc_DRVR_4__Sony_5880_178
    swap %d4
    tstb DskVerify
    jbeq rsrc_DRVR_4__Sony_5880_1F0
    jbra rsrc_DRVR_4__Sony_5880_25E
rsrc_DRVR_4__Sony_5880_1EA:/* data */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_1F0:/* high bits */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_1EA
    moveb %a4@,%d3
    moveb %a3@(0x0,%d3:w),%d1
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_5880_202:/* first */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_202
    moveb %a4@,%d3
    orb %a3@(0x0,%d3:w),%d2
    moveb %d7,%d3
    addb %d7,%d3
    rolb #1,%d7
    eorb %d7,%d2
    moveb %d2,%a0@+
    addxb %d2,%d5
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_5880_220:/* second */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_220
    moveb %a4@,%d3
    orb %a3@(0x0,%d3:w),%d2
    eorb %d5,%d2
    moveb %d2,%a0@+
    addxb %d2,%d6
    tstw %d4
    jbeq rsrc_DRVR_4__Sony_5880_2CC
    rolb #2,%d1
    andb %d0,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_242:/* third */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_242
    moveb %a4@,%d3
    orb %a3@(0x0,%d3:w),%d1
    eorb %d6,%d1
    moveb %d1,%a0@+
    addxb %d1,%d7
    subqw #3,%d4
    jbra rsrc_DRVR_4__Sony_5880_1EA
rsrc_DRVR_4__Sony_5880_258:/* verify */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_25E:/* high bits */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_258
    moveb %a4@,%d3
    moveb %a3@(0x0,%d3:w),%d1
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_5880_270:/* first */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_270
    moveb %a4@,%d3
    orb %a3@(0x0,%d3:w),%d2
    moveb %d7,%d3
    addb %d7,%d3
    rolb #1,%d7
    eorb %d7,%d2
    cmpb %a0@+,%d2
    jbne rsrc_DRVR_4__Sony_5880_2C4
    addxb %d2,%d5
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_5880_290:/* second */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_290
    moveb %a4@,%d3
    orb %a3@(0x0,%d3:w),%d2
    eorb %d5,%d2
    cmpb %a0@+,%d2
    jbne rsrc_DRVR_4__Sony_5880_336
    addxb %d2,%d6
    tstw %d4
    jbeq rsrc_DRVR_4__Sony_5880_2CC
    rolb #2,%d1
    andb %d0,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_2B4:/* third */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_2B4
    moveb %a4@,%d3
    orb %a3@(0x0,%d3:w),%d1
    eorb %d6,%d1
    cmpb %a0@+,%d1
rsrc_DRVR_4__Sony_5880_2C4:/* mismatch? */
    jbne rsrc_DRVR_4__Sony_5880_336
    addxb %d1,%d7
    subqw #3,%d4
    jbra rsrc_DRVR_4__Sony_5880_258
rsrc_DRVR_4__Sony_5880_2CC:/* checksum */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_2D2:/* first */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_2D2
    moveb %a4@,%d3
    moveb %a3@(0x0,%d3:w),%d1
    jbmi rsrc_DRVR_4__Sony_5880_332
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_5880_2E6:/* second */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_2E6
    moveb %a4@,%d3
    moveb %a3@(0x0,%d3:w),%d3
    jbmi rsrc_DRVR_4__Sony_5880_332
    orb %d3,%d2
    cmpb %d2,%d5
    jbne rsrc_DRVR_4__Sony_5880_332
    rolb #2,%d1
    moveb %d1,%d2
    andb %d0,%d2
rsrc_DRVR_4__Sony_5880_300:/* third */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_300
    moveb %a4@,%d3
    moveb %a3@(0x0,%d3:w),%d3
    jbmi rsrc_DRVR_4__Sony_5880_332
    orb %d3,%d2
    cmpb %d2,%d6
    jbne rsrc_DRVR_4__Sony_5880_332
    rolb #2,%d1
    andb %d0,%d1
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
rsrc_DRVR_4__Sony_5880_31E:/* fourth */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_31E
    moveb %a4@,%d3
    moveb %a3@(0x0,%d3:w),%d3
    jbmi rsrc_DRVR_4__Sony_5880_332
    orb %d3,%d1
    cmpb %d1,%d7
    jbeq rsrc_DRVR_4__Sony_5880_33A
rsrc_DRVR_4__Sony_5880_332:/* badDCksum */
    moveq #-72,%d0
    jbra rsrc_DRVR_4__Sony_5880_354
rsrc_DRVR_4__Sony_5880_336:/* dataVerErr */
    moveq #-68,%d0
    jbra rsrc_DRVR_4__Sony_5880_354
rsrc_DRVR_4__Sony_5880_33A:/* bit-slip marks */
    moveq #1,%d4
rsrc_DRVR_4__Sony_5880_33C:/* compare */
    tstb %a4@(3584)
    jbpl rsrc_DRVR_4__Sony_5880_33C
    moveb %a4@,%d3
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    cmpb %a2@+,%d3
    jbne rsrc_DRVR_4__Sony_5880_35E
    dbf %d4,rsrc_DRVR_4__Sony_5880_33C
    moveq #0,%d0
rsrc_DRVR_4__Sony_5880_354:/* read mode; return */
    moveb #24,%a4@(-1024)
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_5880_35E:/* badDBtSlp */
    moveq #-73,%d0
    jbra rsrc_DRVR_4__Sony_5880_354
rsrc_DRVR_4__Sony_5880_35E_4:/* the SCC poll entry: PollProc installed? else a dummy */
    tstl PollProc
    beqs rsrc_DRVR_4__Sony_5880_35E_10
    moveal SCCRd,%fp
    bras rsrc_DRVR_4__Sony_5880_35E_14
rsrc_DRVR_4__Sony_5880_35E_10:/* no poll proc: a pointer to an rts */
    lea %pc@(rsrc_DRVR_4__Sony_5880_35E_14_2),%fp	| 40871FCE
rsrc_DRVR_4__Sony_5880_35E_14:/* return */
    rts
rsrc_DRVR_4__Sony_5880_35E_14_2:
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40871FD4

/* rsrc_DRVR_4__Sony_5BFA: ISM mode: start writing a sector through the FIFO, else return to the IWM code */
rsrc_DRVR_4__Sony_5BFA:
    moveal SonyVars,%a3
    tstb %a3@(313)
    moveal IWM,%a3
    jbpl rsrc_DRVR_4__Sony_5BFA_48
    addqw #4,%sp
    lea %a3@(7680),%a4
    lea %a3@,%a3
    moveb #0xf5,%a3@(2048)
    tstb %a3@(5120)
    moveb #24,%a3@(3072)
    moveb #16,%a3@(3584)
    moveb #1,%a3@(3584)
    moveb #1,%a3@(3072)
    tstb %a3@(5120)
    moveb %a2@+,%a3@
    moveb #8,%a3@(3584)
    jbra rsrc_DRVR_4__Sony_1E84_2A4
rsrc_DRVR_4__Sony_5BFA_48:/* IWM: return */
    rts

/* rsrc_DRVR_4__Sony_5C44: ISM mode: write the data mark trailer bytes and check for an underrun (-74), else the IWM trailer */
rsrc_DRVR_4__Sony_5C44:
    moveal SonyVars,%a2
    tstb %a2@(313)
    jbpl rsrc_DRVR_4__Sony_5C80
    addqw #4,%sp
    lea %pc@(rsrc_DRVR_4__Sony_5C7A),%a2
    moveq #5,%d2
rsrc_DRVR_4__Sony_5C44_12:/* the trailer bytes; underrun? */
    moveb %a4@,%d1
    jbpl rsrc_DRVR_4__Sony_5C44_12
    moveb %a2@+,%a3@
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    dbf %d2,rsrc_DRVR_4__Sony_5C44_12
    moveq #0,%d0
    btst #5,%d1
    jbeq rsrc_DRVR_4__Sony_5C44_2C
    moveq #-74,%d0
rsrc_DRVR_4__Sony_5C44_2C:/* read mode; return */
    moveb #24,%a3@(3072)
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_5C7A: /* (data) */
    .short  0xDEAA, 0xFFFF, 0xFFFF	| 4087205A
rsrc_DRVR_4__Sony_5C80: /* IWM: the trailer bytes */
    lea %pc@(rsrc_DRVR_4__Sony_2244),%a2
    rts
SONY_STS_csCP:          /* Status: the drive's rotation speed for a track (csParam) */
    jble rsrc_DRVR_4__Sony_784	| 40872066
    movew %a0@,%a1@(22)	| 4087206A
    movel %a0,%sp@-	| 4087206E
    tstb %a1@(312)	| 40872070
    jbpl SONY_STS_csCP_18	| 40872074
    jbsr rsrc_DRVR_4__Sony_2716	| 40872076
    bnew rsrc_DRVR_4__Sony_5CCE	| 4087207A
SONY_STS_csCP_18:       /* select, power up, seek; measure the speed (MFM: S_5D90) */
    jbsr rsrc_DRVR_4__Sony_1336
    jbsr rsrc_DRVR_4__Sony_26A0
    jbsr rsrc_DRVR_4__Sony_1010
    jbsr rsrc_DRVR_4__Sony_2388
    jbne rsrc_DRVR_4__Sony_5CCE
    jbsr rsrc_DRVR_4__Sony_1010
    tstb %a1@(0x17,%d1:w)
    jbpl rsrc_DRVR_4__Sony_5CC0
    jbsr rsrc_DRVR_4__Sony_5D90
    jbra rsrc_DRVR_4__Sony_5CC4
rsrc_DRVR_4__Sony_5CC0: /* GCR */
    bsrw rsrc_DRVR_4__Sony_5CD4
rsrc_DRVR_4__Sony_5CC4: /* the speed into csParam */
    jbmi rsrc_DRVR_4__Sony_5CCE
    moveal %sp@,%a0
    movew %d0,%a0@(2)
    moveq #0,%d0
rsrc_DRVR_4__Sony_5CCE: /* finish */
    addqw #4,%sp
    jbra rsrc_DRVR_4__Sony_B62

/* rsrc_DRVR_4__Sony_5CD4: measure the drive's rotation speed (index pulses timed with the VIA timer); ISM or IWM sensing */
rsrc_DRVR_4__Sony_5CD4:
    movew %sr,%sp@-
    moveml %d1-%fp,%sp@-
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_1D5E
    moveq #14,%d0
    jbsr rsrc_DRVR_4__Sony_102C
    moveal IWM,%a0
    tstb %a0@(6656)
    moveq #-1,%d1
    moveq #5,%d3
    moveal VIA,%a2
    lea %a2@(6656),%a3
    cmpib #0xfe,%a1@(312)
    jbeq rsrc_DRVR_4__Sony_5CD4_34
    lea %a0@(7168),%a4
    jbra rsrc_DRVR_4__Sony_5CD4_38
rsrc_DRVR_4__Sony_5CD4_34:/* ISM */
    lea %a0@(7680),%a4
rsrc_DRVR_4__Sony_5CD4_38:/* start the timer; wait for an index */
    jbsr rsrc_DRVR_4__Sony_5E1E
    cmpib #0xfe,%a1@(312)
    jbeq rsrc_DRVR_4__Sony_5CD4_4A
    jbsr rsrc_DRVR_4__Sony_5E2C
    jbra rsrc_DRVR_4__Sony_5CD4_50
rsrc_DRVR_4__Sony_5CD4_4A:/* ISM */
    moveq #0,%d4
    jbsr rsrc_DRVR_4__Sony_5E60
rsrc_DRVR_4__Sony_5CD4_50:/* none? */
    jbne rsrc_DRVR_4__Sony_5CD4_54
    jbra rsrc_DRVR_4__Sony_5CD4_70
rsrc_DRVR_4__Sony_5CD4_54:/* timeout: restore, return */
    tstb %a0@(6144)
    jbsr rsrc_DRVR_4__Sony_F56
    moveq #1,%d1
    moveal VIA,%a2
    jbsr rsrc_DRVR_4__Sony_5E1E
    moveml %sp@+,%d1-%fp
    movew %sp@+,%sr
    tstl %d0
    rts
rsrc_DRVR_4__Sony_5CD4_70:/* time 15 revolutions */
    jbsr rsrc_DRVR_4__Sony_5E1E
    moveq #14,%d2
rsrc_DRVR_4__Sony_5CD4_76:/* next index */
    cmpib #0xfe,%a1@(312)
    jbeq rsrc_DRVR_4__Sony_5CD4_84
    jbsr rsrc_DRVR_4__Sony_5E2C
    jbra rsrc_DRVR_4__Sony_5CD4_8A
rsrc_DRVR_4__Sony_5CD4_84:/* ISM */
    moveq #0,%d4
    jbsr rsrc_DRVR_4__Sony_5E60
rsrc_DRVR_4__Sony_5CD4_8A:/* count; read the timer */
    jbne rsrc_DRVR_4__Sony_5CD4_54
    dbf %d2,rsrc_DRVR_4__Sony_5CD4_76
    moveq #0,%d2
    moveb %a2@(4608),%d2
    moveb %a2@(4096),%d1
    cmpb %a2@(4608),%d2
    jbeq rsrc_DRVR_4__Sony_5CD4_A2
    moveq #0,%d1
rsrc_DRVR_4__Sony_5CD4_A2:/* the speed from the elapsed time */
    btst %d3,%a3@
    jbne rsrc_DRVR_4__Sony_5CD4_54
    lslw #8,%d2
    orb %d1,%d2
    notw %d2
    asll #2,%d2
    divull #783,%d2,%d2
    moveq #0,%d0
    movew %d2,%d0
    jbra rsrc_DRVR_4__Sony_5CD4_54

/* rsrc_DRVR_4__Sony_5D90: measure the rotation speed in ISM mode (several index periods) */
rsrc_DRVR_4__Sony_5D90:
    movew %sr,%sp@-
    moveml %d1-%fp,%sp@-
    moveq #4,%d0
    jbsr rsrc_DRVR_4__Sony_1D5E
    moveq #14,%d0
    jbsr rsrc_DRVR_4__Sony_102C
    moveal IWM,%a0
    moveq #-1,%d1
    moveq #5,%d3
    moveal VIA,%a2
    lea %a2@(6656),%a3
    lea %a0@(7680),%a4
    jbsr rsrc_DRVR_4__Sony_5E1E
    moveq #3,%d4
    jbsr rsrc_DRVR_4__Sony_5E60
    jbeq rsrc_DRVR_4__Sony_5D90_46
rsrc_DRVR_4__Sony_5D90_30:/* timeout: restore, return */
    jbsr rsrc_DRVR_4__Sony_F56
    moveq #1,%d1
    moveal VIA,%a2
    jbsr rsrc_DRVR_4__Sony_5E1E
    moveml %sp@+,%d1-%fp
    movew %sp@+,%sr
    tstl %d0
    rts
rsrc_DRVR_4__Sony_5D90_46:/* time 4 index periods */
    jbsr rsrc_DRVR_4__Sony_5E1E
    moveq #3,%d4
    jbsr rsrc_DRVR_4__Sony_5E60
    jbne rsrc_DRVR_4__Sony_5D90_30
    moveq #3,%d2
    subb %d4,%d2
    moveq #0,%d4
    jbra rsrc_DRVR_4__Sony_5D90_5E
rsrc_DRVR_4__Sony_5D90_58:/* timer wraps */
    addil #65535,%d4
rsrc_DRVR_4__Sony_5D90_5E:/* count */
    dbf %d2,rsrc_DRVR_4__Sony_5D90_58
    moveq #0,%d2
    moveb %a2@(4608),%d2
    moveb %a2@(4096),%d1
    cmpb %a2@(4608),%d2
    jbeq rsrc_DRVR_4__Sony_5D90_74
    moveq #0,%d1
rsrc_DRVR_4__Sony_5D90_74:/* the speed from the elapsed time */
    btst %d3,%a3@
    jbne rsrc_DRVR_4__Sony_5D90_30
    lslw #8,%d2
    orb %d1,%d2
    notw %d2
    addl %d4,%d2
    divull #783,%d2,%d2
    moveq #0,%d0
    movew %d2,%d0
    jbra rsrc_DRVR_4__Sony_5D90_30

/* rsrc_DRVR_4__Sony_5E1E: load the VIA timer 1 counter with d1 */
rsrc_DRVR_4__Sony_5E1E:
    moveb %d1,%a2@(4096)
    rorw #8,%d1
    moveb %d1,%a2@(4608)
    rorw #8,%d1
    rts

/* rsrc_DRVR_4__Sony_5E2C: wait for the next index pulse (IWM): until the sense line changes or the timer expires (-64) */
rsrc_DRVR_4__Sony_5E2C:
    movel %sp@+,DskRtnAdr
rsrc_DRVR_4__Sony_5E2C_4:/* wait for the index to start */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    tstb %a4@
    jbmi rsrc_DRVR_4__Sony_5E2C_12
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_5E2C_1C
rsrc_DRVR_4__Sony_5E2C_12:/* timer ran out? */
    btst %d3,%a3@
    jbeq rsrc_DRVR_4__Sony_5E2C_4
rsrc_DRVR_4__Sony_5E2C_16:/* -64 */
    moveq #-64,%d0
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_5E2C_1C:/* wait for it to end */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    btst %d3,%a3@
    jbne rsrc_DRVR_4__Sony_5E2C_16
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_5E2C_1C
    tstb %a4@
    jbpl rsrc_DRVR_4__Sony_5E2C_1C
    moveq #0,%d0
    jbra rsrc_DRVR_4__Sony_1412

/* rsrc_DRVR_4__Sony_5E60: wait for d4 index pulses (ISM), reloading the timer each time */
rsrc_DRVR_4__Sony_5E60:
    movel %sp@+,DskRtnAdr
rsrc_DRVR_4__Sony_5E60_4:/* wait for the index */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    btst #3,%a4@
    jbne rsrc_DRVR_4__Sony_5E60_16
    btst #3,%a4@
    jbeq rsrc_DRVR_4__Sony_5E60_2A
rsrc_DRVR_4__Sony_5E60_16:/* timer ran out? reload while d4 > 0 */
    btst %d3,%a3@
    jbeq rsrc_DRVR_4__Sony_5E60_4
    tstb %d4
    jbeq rsrc_DRVR_4__Sony_5E60_24
    jbsr rsrc_DRVR_4__Sony_5E1E
    subqw #1,%d4
    jbra rsrc_DRVR_4__Sony_5E60_4
rsrc_DRVR_4__Sony_5E60_24:/* -64 */
    moveq #-64,%d0
    jbra rsrc_DRVR_4__Sony_1412
rsrc_DRVR_4__Sony_5E60_2A:/* wait for the end */
    tstb %a5@
    jbsr rsrc_DRVR_4__Sony_4876
    btst %d3,%a3@
    jbeq rsrc_DRVR_4__Sony_5E60_3C
    tstb %d4
    jbeq rsrc_DRVR_4__Sony_5E60_24
    jbsr rsrc_DRVR_4__Sony_5E1E
    subqw #1,%d4
rsrc_DRVR_4__Sony_5E60_3C:/* noErr */
    btst #3,%a4@
    jbeq rsrc_DRVR_4__Sony_5E60_2A
    btst #3,%a4@
    jbeq rsrc_DRVR_4__Sony_5E60_2A
    moveq #0,%d0
    jbra rsrc_DRVR_4__Sony_1412
    .fill   0xA12, 1, 0x00
