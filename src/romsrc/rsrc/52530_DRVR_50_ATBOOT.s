/* ROM resource 'DRVR' 50 ".ATBOOT": map entry at 0x40852530, data at 0x40852560, 17290 bytes

 The .ATBOOT driver ('DRVR' 50): the AppleTalk network boot protocol used by .netBOOT.
 Opens .MPP (AppleTalk), looks for a boot server ("BootServer", by NBP name lookup),
 requests the boot blocks and the boot image from it with timeouts and retries
 (TickCount), and shows the progress on the start-up screen (icons drawn with
 CopyMask, rsrc/icons/atboot.s). Its settings (server, zone, user) live in extended
 PRAM. Comments inferred from the code (traps used and strings), not verified in depth.
*/

rsrc_DRVR_50__ATBOOT_entry:  /* map entry */
    .long   0x18000000, 0x00000000	| 40852530
    .long   rsrc_DRVR_49__netBOOT_entry-rom_start	| 40852538
    .long   rsrc_DRVR_50__ATBOOT-rom_start	| 4085253C
    .ascii  "DRVR"	| 40852540
    .byte   0x00, 0x32, 0x58	| 40852544
    .byte   7	/* 40852547 Pascal string length */
    .ascii  ".ATBOOT"	| 40852548
    .byte   0x00	| 4085254F
    .long   0x00000000, 0xC0A00000, 0x00004396, 0x00000264	| 40852550

/* subroutine (0 instructions): low memory ATBOOT (mechanical summary) */
rsrc_DRVR_50__ATBOOT:
    .byte   0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40852560
rsrc_DRVR_50__ATBOOT_8:  /* (data) */
    .short  rsrc_DRVR_50__ATBOOT_open-rsrc_DRVR_50__ATBOOT	| 40852568
    .short  rsrc_DRVR_50__ATBOOT_prime-rsrc_DRVR_50__ATBOOT	| 4085256A
    .short  rsrc_DRVR_50__ATBOOT_ctl-rsrc_DRVR_50__ATBOOT	| 4085256C
    .short  rsrc_DRVR_50__ATBOOT_prime-rsrc_DRVR_50__ATBOOT	| 4085256E
    .short  rsrc_DRVR_50__ATBOOT_close-rsrc_DRVR_50__ATBOOT	| 40852570
    .byte   7	/* 40852572 Pascal string length */
    .ascii  ".ATBOOT"	| 40852573
    .byte   0x01, 0x00	| 4085257A

/*
 Open: allocate the variables, open .MPP, patch the traps it needs while booting
 (GetTrapAddress/SetTrapAddress), get its resources.
*/
rsrc_DRVR_50__ATBOOT_open:
    movel %a1@(20),%d3
    jbgt rsrc_DRVR_50__ATBOOT_open_18
    movel #626,%d0
    .short  0xA71E	| 40852588 _NewPtr (flags 0x0700)
    movel %a0,%d3
    jbeq rsrc_DRVR_50__ATBOOT_open_D0
    movel %d3,%a1@(20)
rsrc_DRVR_50__ATBOOT_open_18:  /* from here: subaw #50,%sp */
    subaw #50,%sp
    moveal %sp,%a0
    clrb %a0@(27)
    lea %pc@(PSTR_netBoot),%a1
    movel %a1,%a0@(18)
    _Open
    tstw %a0@(16)
    addaw #50,%sp
    jbgt rsrc_DRVR_50__ATBOOT_open_D0
    moveal %d3,%a3
    movew %a0@(24),%a3@
    btst #3,KeyMap_7
    jbne rsrc_DRVR_50__ATBOOT_open_D0
    moveml %d2-%fp,%sp@-
    moveq #-98,%d1
    moveb SPConfig,%d0
    andib #15,%d0
    subqb #1,%d0
    bgtw rsrc_DRVR_50__ATBOOT_open_C4
    movew #-1,ROMMapInsert
    subqw #4,%sp
    movel #1819109234,%sp@-
    clrw %sp@-
    _GetResource
    movel %sp@+,%d5
    jbeq rsrc_DRVR_50__ATBOOT_open_9C
    moveal %d5,%a0
    moveal %a0@,%a0
    movel #2,%sp@-
    jsr %a0@(2)
    addqw #4,%sp
    tstw %d0
    jbeq rsrc_DRVR_50__ATBOOT_open_8A
    movew %d0,%d1
    jbra rsrc_DRVR_50__ATBOOT_open_C4
rsrc_DRVR_50__ATBOOT_open_8A:  /* set %d0 */
    movew #-24432,%d0
    .short  0xA346	| 4085260A _GetTrapAddress (flags 0x0300)
    moveal %a0,%a5
    movew #-24432,%d0
    lea %pc@(rsrc_DRVR_50__ATBOOT_196),%a0
    .short  0xA247	| 40852616 _SetTrapAddress (flags 0x0200)
rsrc_DRVR_50__ATBOOT_open_9C:  /* from here: subaw #50,%sp */
    subaw #50,%sp
    moveal %sp,%a0
    clrb %a0@(27)
    lea %pc@(PSTR_MPP),%a1
    movel %a1,%a0@(18)
    _Open
    movew %a0@(16),%d1
    lea %sp@(50),%sp
    tstl %d5
    jbeq rsrc_DRVR_50__ATBOOT_open_C4
    moveal %a5,%a0
    movew #-24432,%d0
    .short  0xA247	| 4085263E _SetTrapAddress (flags 0x0200)
rsrc_DRVR_50__ATBOOT_open_C4:  /* restore registers */
    moveml %sp@+,%d2-%fp
    tstw %d1
    jbne rsrc_DRVR_50__ATBOOT_open_D0
    moveq #0,%d0
    rts
rsrc_DRVR_50__ATBOOT_open_D0:  /* set %d0 */
    movew #-23,%d0
    rts
PSTR_MPP:               /* (data) */
    .short  0x042E, 0x4D50, 0x5000	| 40852652
PSTR_netBoot:           /* (data) */
    .byte   0x08	| 40852658
    .ascii  ".netBoot\000"
    .byte   0x0B	| 40852662
    .ascii  "ATBoot Open\000\000"

/* Close: restore the traps, close .MPP, free the variables. */
rsrc_DRVR_50__ATBOOT_close:
    movel %a1@(20),%d3
    jbeq rsrc_DRVR_50__ATBOOT_close_24
    moveal %d3,%a3
    movel %a3@(618),%d0
    jbeq rsrc_DRVR_50__ATBOOT_close_12
    moveal %d0,%a0
    _DisposPtr
rsrc_DRVR_50__ATBOOT_close_12:  /* set up and call _DisposPtr */
    movel %a3@(4),%d0
    jbeq rsrc_DRVR_50__ATBOOT_close_1C
    moveal %d0,%a0
    _DisposPtr
rsrc_DRVR_50__ATBOOT_close_1C:  /* set up and call _DisposPtr */
    moveal %a3,%a0
    _DisposPtr
    clrl %a3@(20)
rsrc_DRVR_50__ATBOOT_close_24:  /* set up and call _Close */
    subaw #50,%sp
    moveal %sp,%a0
    movew #-10,%a0@(24)
    _Close
    lea %sp@(50),%sp
    moveq #0,%d0

/* Prime and Status: nothing. */
rsrc_DRVR_50__ATBOOT_prime:
    rts
    .byte   0x0C	| 408526AA
    .ascii  "ATBoot Close\000"
    .short  0x4E75	| 408526B8

/*
 Control: the requests of .netBOOT (start the boot, get blocks), through the protocol
 code (rsrc_DRVR_50__ATBOOT_3AD2).
*/
rsrc_DRVR_50__ATBOOT_ctl:
    movel %a1,%sp@-
    movel %a0,%sp@-
    moveq #-1,%d0
    movel %a1@(20),%sp@-
    beqw rsrc_DRVR_50__ATBOOT_ctl_14
    movel %a0,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3AD2)
rsrc_DRVR_50__ATBOOT_ctl_14:  /* add 8 to %sp */
    addql #8,%sp
    moveal %sp@+,%a0
    movel #1024,%a0@(40)
    movew %d0,%a0@(16)
    moveal %sp@+,%a1
    moveal JIODone,%a3
    jmp %a3@
    .byte   0x0E	| 408526E6
    .ascii  "ATBoot Control\000"
rsrc_DRVR_50__ATBOOT_196:  /* set %a0@(4) */
    movew #1541,%a0@(4)	| 408526F6
    moveq #0,%d0	| 408526FC
    rts	| 408526FE

/* Read and update the AppleTalk boot settings in extended PRAM. */
rsrc_DRVR_50__ATBOOT_1A0:
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
    jbeq rsrc_DRVR_50__ATBOOT_1A0_E
    jbsr rsrc_DRVR_50__ATBOOT_1C6
    jbra rsrc_DRVR_50__ATBOOT_1A0_10
rsrc_DRVR_50__ATBOOT_1A0_E:  /* call rsrc_DRVR_50__ATBOOT_1E6 */
    jbsr rsrc_DRVR_50__ATBOOT_1E6
rsrc_DRVR_50__ATBOOT_1A0_10:  /* return */
    rts
rsrc_DRVR_50__ATBOOT_1B2:  /* from here: orib #4,%d4 */
    orib #4,%d4	| 40852712
    .short  0x0003, 0x00AB	| 40852716 orib #-85,%d3
    .short  0x0001, 0x00BC	| 4085271A orib #-68,%d1
    orib #32,%a0@-	| 4085271E
    .short  0x0020, 0x008B	| 40852722 orib #-117,%a0@-

/* subroutine (12 instructions): traps ReadXPRam; low memory HWCfgFlags (mechanical summary) */
rsrc_DRVR_50__ATBOOT_1C6:
    moveq #0,%d0
    btst #14,HWCfgFlags
    jbeq rsrc_DRVR_50__ATBOOT_1C6_1E
    lea %pc@(rsrc_DRVR_50__ATBOOT_1B2),%a1
    moveq #4,%d1
rsrc_DRVR_50__ATBOOT_1C6_10:  /* set up and call _ReadXPRam (loop) */
    movel %a1@+,%d0
    movel %d0,%d2
    _ReadXPRam
    swap %d2
    addaw %d2,%a0
    dbf %d1,rsrc_DRVR_50__ATBOOT_1C6_10
rsrc_DRVR_50__ATBOOT_1C6_1E:  /* return */
    rts

/* subroutine (12 instructions): traps WriteXPRam; low memory HWCfgFlags (mechanical summary) */
rsrc_DRVR_50__ATBOOT_1E6:
    moveq #0,%d0
    btst #14,HWCfgFlags
    jbeq rsrc_DRVR_50__ATBOOT_1E6_1E
    lea %pc@(rsrc_DRVR_50__ATBOOT_1B2),%a1
    moveq #4,%d1
rsrc_DRVR_50__ATBOOT_1E6_10:  /* set up and call _WriteXPRam (loop) */
    movel %a1@+,%d0
    movel %d0,%d2
    _WriteXPRam
    swap %d2
    addaw %d2,%a0
    dbf %d1,rsrc_DRVR_50__ATBOOT_1E6_10
rsrc_DRVR_50__ATBOOT_1E6_1E:  /* return */
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_206:
    movel %a5,%d0
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_20A:
    moveal %sp@(4),%a5
    rts

/* subroutine (5 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_210:
    movel %sp@(4),%d0
    lslw #7,%d0
    lea %pc@(ATBOOT_ICON_FRAMES),%a0
    addl %a0,%d0
    rts
    .include "rsrc/icons/atboot.s"

/* Open a port for drawing the progress icons. */
rsrc_DRVR_50__ATBOOT_41E:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    pea %a3@(206)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_20A)
    pea %a3@(202)
    _InitGraf
    pea %a3@(210)
    _OpenPort
    addql #4,%sp
    moveal %sp@+,%a3
    rts

/* subroutine (6 instructions): traps ClosePort (mechanical summary) */
rsrc_DRVR_50__ATBOOT_43E:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    pea %a3@(210)
    _ClosePort
    moveal %sp@+,%a3
    rts

/* subroutine (28 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_44E:
    moveml %d6-%d7/%a3,%sp@-
    movew %sp@(26),%d6
    movew %sp@(22),%d7
    moveal %sp@(16),%a3
    movew %a3@(4),%d0
    subw %a3@,%d0
    extl %d0
    asrl #1,%d0
    extl %d6
    subl %d6,%d0
    addw %d0,%a3@
    movew %a3@(6),%d0
    subw %a3@(2),%d0
    extl %d0
    asrl #1,%d0
    extl %d7
    subl %d7,%d0
    addw %d0,%a3@(2)
    movew %d6,%d0
    addw %a3@,%d0
    addw %d6,%d0
    movew %d0,%a3@(4)
    movew %d7,%d0
    addw %a3@(2),%d0
    addw %d7,%d0
    movew %d0,%a3@(6)
    moveml %sp@+,%d6-%d7/%a3
    rts

/* Draw a progress icon (CopyMask) at its place on the start-up screen. */
rsrc_DRVR_50__ATBOOT_49E:
    linkw %fp,#-36
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(8),%a3
    lea %fp@(-8),%a0
    lea %a3@(226),%a1
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    moveq #16,%d0
    movel %d0,%sp@-
    movel %d0,%sp@-
    pea %fp@(-8)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_44E)
    pea %a3@(210)
    _SetPort
    movel %a4,%fp@(-36)
    movew #4,%fp@(-32)
    pea %fp@(-30)
    moveq #0,%d0
    movew %d0,%sp@-
    movew %d0,%sp@-
    moveq #32,%d1
    movew %d1,%sp@-
    movew %d1,%sp@-
    _SetRect
    lea %pc@(ATBOOT_ICON_MASK),%a0
    movel %a0,%fp@(-22)
    movew #4,%fp@(-18)
    pea %fp@(-16)
    moveq #0,%d0
    movew %d0,%sp@-
    movew %d0,%sp@-
    moveq #32,%d1
    movew %d1,%sp@-
    movew %d1,%sp@-
    _SetRect
    tstl %fp@(16)
    lea %sp@(12),%sp
    jbeq rsrc_DRVR_50__ATBOOT_49E_80
    pea %fp@(-8)
    pea %a3@(178)
    _FillRect
rsrc_DRVR_50__ATBOOT_49E_80:  /* from here: pea %fp@(-36) */
    pea %fp@(-36)
    pea %fp@(-22)
    pea %a3@(212)
    pea %fp@(-30)
    pea %fp@(-16)
    pea %fp@(-8)
    _CopyMask
    moveml %fp@(-44),%a3-%a4
    unlk %fp
    rts

/* subroutine (22 instructions): calls rsrc_DRVR_50__ATBOOT_210, rsrc_DRVR_50__ATBOOT_49E (mechanical summary) */
rsrc_DRVR_50__ATBOOT_542:
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(16),%a3
    moveq #0,%d7
    moveq #3,%d0
    cmpw %a3@(318),%d0
    jble rsrc_DRVR_50__ATBOOT_542_3A
    tstw %a3@(318)
    jbne rsrc_DRVR_50__ATBOOT_542_1A
    moveq #1,%d7
rsrc_DRVR_50__ATBOOT_542_1A:  /* set %d0 */
    movew %a3@(318),%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_210)
    moveal %d0,%a4
    addqw #1,%a3@(318)
    movel %d7,%sp@-
    movel %a4,%sp@-
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_49E)
    lea %sp@(16),%sp
rsrc_DRVR_50__ATBOOT_542_3A:  /* restore registers, return */
    moveml %sp@+,%d7/%a3-%a4
    rts

/* subroutine (25 instructions): traps TickCount; calls rsrc_DRVR_50__ATBOOT_3E84, rsrc_DRVR_50__ATBOOT_3DA0 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_582:
    linkw %fp,#-18
    moveml %a3-%a4,%sp@-
    lea %fp@(-18),%a4
    moveal %fp@(8),%a3
    subql #4,%sp
    _TickCount
    movel %sp@+,%a3@(66)
    pea %a3@(44)
    movel %a4,%sp@-
    pea %a3@(62)
    movel %fp@(12),%sp@-
    moveq #10,%d0
    movew %d0,%sp@-
    moveq #42,%d1
    movew %d1,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3E84)
    subql #2,%sp
    movel %a3,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3DA0)
    movew %sp@+,%d0
    moveml %fp@(-26),%a3-%a4
    unlk %fp
    rts

/* subroutine (25 instructions): calls rsrc_DRVR_50__ATBOOT_3EC8, rsrc_DRVR_50__ATBOOT_3DB0 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_5CC:
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(20),%a4
    lea %a4@(56),%a3
    movel %a4,%sp@-
    movel %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    pea %pc@(rsrc_DRVR_50__ATBOOT_630)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3EC8)
    movel %a4,%a3@(30)
    moveb %fp@(35),%a3@(28)
    moveb %fp@(39),%a3@(29)
    movel %fp@(16),%a3@(34)
    movew #222,%a3@(38)
    movew %fp@(26),%a3@(40)
    moveq #0,%d0
    movel %d0,%a3@(12)
    subql #2,%sp
    pea %a4@(56)
    moveb %fp@(31),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3DB0)
    movew %sp@+,%d0
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    rts

/* subroutine (0 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_630:
    .short  0x012A, 0x0000	| 40852B90 btst %d0,%a2@(0)

/* subroutine (15 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_634:
    moveml %a3-%a4,%sp@-
    moveal %sp@(12),%a4
    moveal %sp@(16),%a3
    moveb #10,%a3@(28)
    clrb %a3@(29)
    lea %a3@(44),%a0
    movel %a0,%a3@(30)
    lea %a3@(62),%a0
    moveal %a4,%a1
    moveq #9,%d0
rsrc_DRVR_50__ATBOOT_634_26:  /* loop: move */
    movel %a1@+,%a0@+
    dbf %d0,rsrc_DRVR_50__ATBOOT_634_26
    movew %a1@+,%a0@+
    moveml %sp@+,%a3-%a4
    rts

/* subroutine (38 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_668:
    moveml %d7/%a3-%a4,%sp@-
    movew %sp@(18),%d7
    moveal %sp@(20),%a3
    lea %pc@(rsrc_DRVR_50__ATBOOT_6C8),%a4
    moveq #15,%d0
    andw %d7,%d0
    extl %d0
    addl %a4,%d0
    moveal %d0,%a0
    moveb %a0@,%a3@(1)
    extl %d7
    movel %d7,%d0
    asrl #4,%d0
    moveq #15,%d1
    andl %d0,%d1
    addl %a4,%d1
    moveal %d1,%a0
    moveb %a0@,%a3@(2)
    extl %d7
    movel %d7,%d0
    asrl #8,%d0
    moveq #15,%d1
    andl %d0,%d1
    addl %a4,%d1
    moveal %d1,%a0
    moveb %a0@,%a3@(3)
    extl %d7
    moveq #12,%d0
    movel %d7,%d1
    asrl %d0,%d1
    moveq #15,%d0
    andl %d1,%d0
    addl %a4,%d0
    moveal %d0,%a0
    moveb %a0@,%a3@(4)
    moveb #4,%a3@
    moveml %sp@+,%d7/%a3-%a4
    rts
rsrc_DRVR_50__ATBOOT_6C8:  /* string "0123456789ABCDEF\000" */
    .ascii  "0123456789ABCDEF\000"
    .byte   0x00	| 40852C39

/* subroutine (121 instructions): traps TickCount; calls rsrc_DRVR_50__ATBOOT_668, rsrc_DRVR_50__ATBOOT_634, rsrc_DRVR_50__ATBOOT_3CF6, rsrc_DRVR_50__ATBOOT_5CC, rsrc_DRVR_50__ATBOOT_582 ... (mechanical summary) */
rsrc_DRVR_50__ATBOOT_6DA:
    linkw %fp,#-574
    moveml %d4-%d7/%a3-%a4,%sp@-
    moveal %fp@(28),%a3
    moveq #0,%d0
    moveal %d0,%a4
    moveq #1,%d5
    movew #-1,%fp@(-366)
    moveb #0xff,%fp@(-364)
    moveb #0xff,%fp@(-363)
    movel %a3,%d1
    jbeq rsrc_DRVR_50__ATBOOT_6DA_13E
    movew #-1,%a3@
    pea %fp@(-256)
    moveq #0,%d0
    movew %fp@(22),%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_668)
    pea %fp@(-570)
    movel %fp@(24),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_634)
    subql #4,%sp
    pea 0xde
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3CF6)
    moveal %sp@+,%a4
    movel %a4,%d0
    lea %sp@(16),%sp
    jbeq rsrc_DRVR_50__ATBOOT_6DA_13E
    moveq #0,%d0
    movew %a3@,%d0
    cmpil #65535,%d0
    jbne rsrc_DRVR_50__ATBOOT_6DA_B0
    moveq #0,%d0
    moveb %fp@(15),%d0
    movel %d0,%sp@-
    moveq #0,%d0
    moveb %fp@(11),%d0
    movel %d0,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #1,%d1
    movel %d1,%sp@-
    pea %fp@(-466)
    movel %a4,%sp@-
    pea %fp@(-256)
    movel %fp@(16),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_5CC)
    tstw %d0
    lea %sp@(32),%sp
    jbne rsrc_DRVR_50__ATBOOT_6DA_13E
    jbra rsrc_DRVR_50__ATBOOT_6DA_B0
rsrc_DRVR_50__ATBOOT_6DA_A2:  /* loop: move */
    movel %fp@(-260),%sp@-
    pea %fp@(-570)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_582)
    addql #8,%sp
rsrc_DRVR_50__ATBOOT_6DA_B0:  /* clear %d0 */
    moveq #0,%d0
    movew %a3@,%d0
    cmpil #65535,%d0
    jbne rsrc_DRVR_50__ATBOOT_6DA_E0
    cmpw %fp@(-368),%d5
    jbgt rsrc_DRVR_50__ATBOOT_6DA_E0
    subql #2,%sp
    movel %a4,%sp@-
    movew %fp@(-368),%sp@-
    movew %d5,%sp@-
    addqw #1,%d5
    pea %fp@(-362)
    pea %fp@(-260)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_42F2)
    movew %sp@+,%fp@(-412)
    jbeq rsrc_DRVR_50__ATBOOT_6DA_A2
rsrc_DRVR_50__ATBOOT_6DA_E0:  /* set up and call _TickCount */
    tstw %fp@(-368)
    jble rsrc_DRVR_50__ATBOOT_6DA_13E
    subql #4,%sp
    _TickCount
    movel %sp@+,%d6
    moveb %fp@(11),%d0
    lslb #4,%d0
    moveq #0,%d1
    moveb %d0,%d1
    movel %d1,%d7
    movel %d6,%d4
    movel %d7,%d0
    lsll #2,%d0
    movel %d0,%fp@(-574)
    jbra rsrc_DRVR_50__ATBOOT_6DA_124
rsrc_DRVR_50__ATBOOT_6DA_104:  /* set up and call _TickCount (loop) */
    subql #4,%sp
    _TickCount
    movel %sp@+,%d0
    subl %d4,%d0
    cmpl %d0,%d7
    jbcc rsrc_DRVR_50__ATBOOT_6DA_124
    subql #4,%sp
    _TickCount
    movel %sp@+,%d4
    movel %fp@(-260),%sp@-
    pea %fp@(-570)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_582)
    addql #8,%sp
rsrc_DRVR_50__ATBOOT_6DA_124:  /* set up and call _TickCount */
    subql #4,%sp
    _TickCount
    movel %sp@+,%d0
    subl %d6,%d0
    cmpl %fp@(-574),%d0
    jbcc rsrc_DRVR_50__ATBOOT_6DA_13E
    moveq #0,%d0
    movew %a3@,%d0
    cmpil #65535,%d0
    jbeq rsrc_DRVR_50__ATBOOT_6DA_104
rsrc_DRVR_50__ATBOOT_6DA_13E:  /* clear %d0 */
    moveq #0,%d0
    movew %a3@,%d0
    cmpil #65535,%d0
    jbeq rsrc_DRVR_50__ATBOOT_6DA_150
    movel %a3@(38),%fp@(-366)
rsrc_DRVR_50__ATBOOT_6DA_150:  /* set %d0 */
    movel %a4,%d0
    jbeq rsrc_DRVR_50__ATBOOT_6DA_15A
    movel %a4,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D0E)
rsrc_DRVR_50__ATBOOT_6DA_15A:  /* set %d0 */
    movel %fp@(-366),%d0
    moveml %fp@(-598),%d4-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (27 instructions): traps TickCount (mechanical summary) */
rsrc_DRVR_50__ATBOOT_842:
    linkw %fp,#0
    movel %a3,%sp@-
    moveal %fp@(12),%a3
    movew %a3@(48),%d0
    cmpw %a3@(2),%d0
    jbne rsrc_DRVR_50__ATBOOT_842_4A
    tstw %a3@(58)
    jbne rsrc_DRVR_50__ATBOOT_842_4A
    movew %a3@(56),%a3@
    movel %fp@(8),%a3@(38)
    subql #4,%sp
    _TickCount
    movel %sp@+,%d0
    subl %a3@(50),%d0
    lsll #2,%d0
    movew %d0,%a3@(30)
    moveq #4,%d0
    cmpw %a3@(30),%d0
    jble rsrc_DRVR_50__ATBOOT_842_40
    moveq #4,%d0
    jbra rsrc_DRVR_50__ATBOOT_842_46
rsrc_DRVR_50__ATBOOT_842_40:  /* set %d0 */
    movew %a3@(30),%d0
    extl %d0
rsrc_DRVR_50__ATBOOT_842_46:  /* set %a3@(30) */
    movew %d0,%a3@(30)
rsrc_DRVR_50__ATBOOT_842_4A:  /* set %a3 */
    moveal %fp@(-4),%a3
    unlk %fp
    rts

/* subroutine (18 instructions): traps TickCount (mechanical summary) */
rsrc_DRVR_50__ATBOOT_894:
    linkw %fp,#0
    moveml %d7/%a3,%sp@-
    moveal %fp@(8),%a3
    subql #4,%sp
    _TickCount
    movel %sp@+,%d7
    tstl %fp@(12)
    jbne rsrc_DRVR_50__ATBOOT_894_2C
    tstl %a3@(34)
    jbeq rsrc_DRVR_50__ATBOOT_894_24
    moveq #0,%d0
    movel %d0,%a3@(34)
rsrc_DRVR_50__ATBOOT_894_24:  /* set %a3@(22) */
    movel %d7,%a3@(22)
    addqw #1,%a3@(10)
rsrc_DRVR_50__ATBOOT_894_2C:  /* set %a3@(18) */
    movel %d7,%a3@(18)
    moveml %fp@(-8),%d7/%a3
    unlk %fp
    rts

/* subroutine (40 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_8CE:
    moveml %d5-%d7/%a3-%a4,%sp@-
    moveal %sp@(28),%a4
    moveal %sp@(24),%a3
    clrw %d5
    moveb #10,%a3@(28)
    clrb %a3@(29)
    lea %a3@(44),%a0
    movel %a0,%a3@(30)
    moveb #3,%a3@(62)
    moveb #1,%a3@(63)
    movew %a4@,%a3@(64)
    clrb %a3@(66)
    clrb %a3@(67)
    moveq #0,%d0
    movew %a4@(8),%d0
    divsw #8,%d0
    movew %d0,%d6
    moveq #0,%d0
    movew %a4@(8),%d0
    movel %d0,%d5
    lsrl #3,%d5
    jbeq rsrc_DRVR_50__ATBOOT_8CE_52
    addqw #1,%d6
rsrc_DRVR_50__ATBOOT_8CE_52:  /* clear %d7 */
    clrw %d7
    jbra rsrc_DRVR_50__ATBOOT_8CE_62
rsrc_DRVR_50__ATBOOT_8CE_56:  /* loop: moveq */
    moveq #0,%d0
    movew %d7,%d0
    moveb #0xff,%a3@(0x46,%d0:l)
    addqw #1,%d7
rsrc_DRVR_50__ATBOOT_8CE_62:  /* test %d7,%d6 */
    cmpw %d7,%d6
    jbhi rsrc_DRVR_50__ATBOOT_8CE_56
    tstw %d5
    jbeq rsrc_DRVR_50__ATBOOT_8CE_78
    movew %d6,%d0
    subqw #1,%d0
    moveq #0,%d1
    movew %d0,%d1
    moveb #0xff,%a3@(0x46,%d1:l)
rsrc_DRVR_50__ATBOOT_8CE_78:  /* restore registers, return */
    moveml %sp@+,%d5-%d7/%a3-%a4
    rts

/* subroutine (25 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_94C:
    moveml %d6-%d7/%a3-%a4,%sp@-
    movew %sp@(30),%d6
    moveal %sp@(24),%a4
    moveal %sp@(20),%a3
    extl %d6
    movel %d6,%d0
    divsw #8,%d0
    movew %d0,%d7
    jbra rsrc_DRVR_50__ATBOOT_94C_22
rsrc_DRVR_50__ATBOOT_94C_1C:  /* loop: move */
    moveb %a3@+,%d0
    notb %d0
    moveb %d0,%a4@+
rsrc_DRVR_50__ATBOOT_94C_22:  /* set %d0 */
    movew %d7,%d0
    subqw #1,%d7
    tstw %d0
    jbne rsrc_DRVR_50__ATBOOT_94C_1C
    extl %d6
    movel %d6,%d0
    asrl #3,%d0
    jbeq rsrc_DRVR_50__ATBOOT_94C_38
    moveb %a3@,%d0
    notb %d0
    moveb %d0,%a4@
rsrc_DRVR_50__ATBOOT_94C_38:  /* restore registers, return */
    moveml %sp@+,%d6-%d7/%a3-%a4
    rts

/* subroutine (35 instructions): calls rsrc_DRVR_50__ATBOOT_3C44, rsrc_DRVR_50__ATBOOT_3E84, rsrc_DRVR_50__ATBOOT_3DA0 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_98A:
    linkw %fp,#-18
    moveml %a3-%a4,%sp@-
    moveal %fp@(16),%a4
    moveal %fp@(8),%a3
    pea %a3@(44)
    pea %fp@(-18)
    pea %a3@(62)
    movel %fp@(12),%sp@-
    moveq #10,%d0
    movew %d0,%sp@-
    moveq #0,%d1
    movew %a4@(8),%d1
    movel %d1,%d0
    moveq #8,%d1
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3C44)
    addql #8,%d0
    moveq #0,%d1
    movew %a4@(8),%d1
    lsrl #3,%d1
    jbeq rsrc_DRVR_50__ATBOOT_98A_42
    moveq #1,%d1
    jbra rsrc_DRVR_50__ATBOOT_98A_44
rsrc_DRVR_50__ATBOOT_98A_42:  /* clear %d1 */
    moveq #0,%d1
rsrc_DRVR_50__ATBOOT_98A_44:  /* from here: addl %d0,%d1 */
    addl %d0,%d1
    movew %d1,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3E84)
    subql #2,%sp
    movel %a3,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3DA0)
    movew %sp@+,%d0
    moveml %fp@(-26),%a3-%a4
    unlk %fp
    rts

/*
 The boot protocol: look up a "BootServer", ask it for the boot image, receive the
 blocks (with timeouts and retries).
*/
rsrc_DRVR_50__ATBOOT_9EE:
    linkw %fp,#-2060
    moveml %d4-%d7/%a3-%a4,%sp@-
    moveal %fp@(16),%a4
    movel %fp@(8),%d5
    lea %fp@(-836),%a3
    clrw %fp@(-1426)
    moveq #0,%d4
    pea 0x140
    moveq #0,%d0
    movel %d0,%sp@-
    pea %fp@(-320)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_4352)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_206)
    movel %d0,%fp@(-324)
    pea %fp@(-320)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_41E)
    movew #-1,%fp@(-2060)
    movew #1,%fp@(-2058)
    movel %a3,%fp@(-2056)
    clrw %fp@(-2052)
    clrw %fp@(-2050)
    moveq #0,%d0
    movel %d0,%fp@(-2048)
    clrw %fp@(-2044)
    movel %d0,%fp@(-2042)
    movel %d0,%fp@(-2038)
    movel %d5,%d1
    asrl #3,%d1
    movel %d1,%fp@(-2034)
    movew #4,%fp@(-2030)
    movew #1,%fp@(-2028)
    movel %d0,%fp@(-2026)
    moveq #-1,%d1
    movel %d1,%fp@(-2022)
    pea %fp@(-2060)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_D42)
    subql #2,%sp
    jsr %pc@(rsrc_DRVR_50__ATBOOT_4054)
    movew %sp@+,%fp@(-1428)
    lea %sp@(20),%sp
    jbeq rsrc_DRVR_50__ATBOOT_9EE_A4
    movew %fp@(-1428),%d0
    extl %d0
    jbra rsrc_DRVR_50__ATBOOT_9EE_33E
rsrc_DRVR_50__ATBOOT_9EE_A4:  /* test %fp@(23) */
    tstb %fp@(23)
    jbeq rsrc_DRVR_50__ATBOOT_9EE_CE
    moveq #15,%d0
    andb %fp@(23),%d0
    moveq #0,%d1
    moveb %d0,%d1
    aslw #2,%d1
    moveb %d1,%fp@(-1420)
    movew #240,%d0
    andb %fp@(23),%d0
    moveq #0,%d1
    moveb %d0,%d1
    lsrl #4,%d1
    moveb %d1,%fp@(-1419)
    jbra rsrc_DRVR_50__ATBOOT_9EE_DA
rsrc_DRVR_50__ATBOOT_9EE_CE:  /* set %fp@(-1420) */
    moveb #4,%fp@(-1420)
    moveb #1,%fp@(-1419)
rsrc_DRVR_50__ATBOOT_9EE_DA:  /* set %fp@(-1426) */
    movew #10,%fp@(-1426)
    subql #2,%sp
    pea %fp@(-1426)
    pea %pc@(rsrc_DRVR_50__ATBOOT_D42_8)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_421A)
    movew %sp@+,%fp@(-1428)
    jbeq rsrc_DRVR_50__ATBOOT_9EE_FE
    movew %fp@(-1428),%d0
    extl %d0
    jbra rsrc_DRVR_50__ATBOOT_9EE_33E
rsrc_DRVR_50__ATBOOT_9EE_FE:  /* set %a4@ */
    moveb #1,%a4@
    moveb #1,%a4@(1)
    moveq #0,%d0
    movel %d0,%a4@(4)
    movew #-1,%fp@(-1424)
    moveb #0xff,%fp@(-1422)
    moveb #0xff,%fp@(-1421)
    pea %fp@(-2060)
    movel %a4,%sp@-
    moveq #0,%d1
    movew %fp@(14),%d1
    movel %d1,%sp@-
    pea %pc@(PSTR_BootServer)
    moveq #0,%d1
    moveb %fp@(-1419),%d1
    movel %d1,%sp@-
    moveq #0,%d1
    moveb %fp@(-1420),%d1
    movel %d1,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_6DA)
    movel %d0,%fp@(-1424)
    moveq #0,%d0
    movew %fp@(-2060),%d0
    cmpil #65535,%d0
    lea %sp@(24),%sp
    jbeq rsrc_DRVR_50__ATBOOT_9EE_2BE
    moveq #-1,%d0
    cmpl %fp@(-1424),%d0
    jbeq rsrc_DRVR_50__ATBOOT_9EE_2BE
    movew %fp@(-2006),%fp@(-2044)
    movel %fp@(-2000),%d0
    subql #1,%d0
    movew %d0,%fp@(-2052)
    moveq #0,%d0
    movew %fp@(-2052),%d0
    moveq #8,%d1
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3C44)
    cmpil #511,%d0
    jbge rsrc_DRVR_50__ATBOOT_9EE_1A8
    movew %fp@(-2044),%d0
    muluw %fp@(-2052),%d0
    movel %d0,%sp@-
    movel BufPtr,%d0
    moveq #4,%d1
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3C44)
    movel %d0,%d1
    movel %sp@+,%d0
    cmpl %d0,%d1
    jbcc rsrc_DRVR_50__ATBOOT_9EE_1AE
rsrc_DRVR_50__ATBOOT_9EE_1A8:  /* set %d4 */
    moveq #-2,%d4
    jbra rsrc_DRVR_50__ATBOOT_9EE_2C0
rsrc_DRVR_50__ATBOOT_9EE_1AE:  /* subtract 4 to %sp */
    subql #4,%sp
    moveq #0,%d0
    movew %fp@(-2006),%d0
    movel %d0,%d1
    movel %fp@(-2000),%d0
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3C1C)
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3CF6)
    movel %sp@+,%fp@(-2048)
    jbne rsrc_DRVR_50__ATBOOT_9EE_1D2
    moveq #-2,%d4
    jbra rsrc_DRVR_50__ATBOOT_9EE_2C0
rsrc_DRVR_50__ATBOOT_9EE_1D2:  /* from here: pea %fp@(-2060) */
    pea %fp@(-2060)
    pea %fp@(-1418)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_8CE)
    clrw %d6
    addql #8,%sp
    jbra rsrc_DRVR_50__ATBOOT_9EE_1EA
rsrc_DRVR_50__ATBOOT_9EE_1E4:  /* loop: clr */
    clrb %a3@(0x0,%d6:w)
    addqw #1,%d6
rsrc_DRVR_50__ATBOOT_9EE_1EA:  /* from here: extl %d6 */
    extl %d6
    moveq #0,%d0
    movew %fp@(-2052),%d0
    moveq #8,%d1
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3C44)
    addql #1,%d0
    cmpl %d6,%d0
    jbgt rsrc_DRVR_50__ATBOOT_9EE_1E4
    jbra rsrc_DRVR_50__ATBOOT_9EE_2AA
rsrc_DRVR_50__ATBOOT_9EE_202:  /* set up and call _TickCount (loop) */
    subql #4,%sp
    _TickCount
    movel %sp@+,%d7
    moveq #0,%d0
    movew %fp@(-2050),%d0
    movel %d0,%d1
    addl %d0,%d0
    addl %d1,%d0
    moveq #0,%d1
    movew %fp@(-2052),%d1
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3C44)
    movew %fp@(-2),%d1
    extl %d1
    cmpl %d0,%d1
    jbgt rsrc_DRVR_50__ATBOOT_9EE_232
    pea %fp@(-320)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_542)
    addql #4,%sp
rsrc_DRVR_50__ATBOOT_9EE_232:  /* set %d0 */
    movel %d7,%d0
    subl %fp@(-2042),%d0
    cmpl %fp@(-2034),%d0
    jbgt rsrc_DRVR_50__ATBOOT_9EE_25E
    movel %d7,%d0
    subl %fp@(-2038),%d0
    movel %fp@(-2034),%d2
    movel %d2,%d1
    muluw #50,%d2
    swap %d1
    muluw #50,%d1
    swap %d1
    clrw %d1
    addl %d1,%d2
    cmpl %d0,%d2
    jbge rsrc_DRVR_50__ATBOOT_9EE_2AA
rsrc_DRVR_50__ATBOOT_9EE_25E:  /* test %fp@(-2026) */
    tstl %fp@(-2026)
    jbeq rsrc_DRVR_50__ATBOOT_9EE_278
    movew %fp@(-2028),%d0
    addw %d0,%fp@(-2028)
    movew %fp@(-2030),%d0
    mulsw %fp@(-2028),%d0
    movel %d0,%fp@(-2034)
rsrc_DRVR_50__ATBOOT_9EE_278:  /* clear %d0 */
    moveq #0,%d0
    movew %fp@(-2052),%d0
    movel %d0,%sp@-
    pea %fp@(-1348)
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_94C)
    movel %d7,%fp@(-2026)
    movel %d7,%fp@(-2038)
    movel %d7,%fp@(-2042)
    pea %fp@(-2060)
    movel %fp@(-1424),%sp@-
    pea %fp@(-1418)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_98A)
    lea %sp@(24),%sp
rsrc_DRVR_50__ATBOOT_9EE_2AA:  /* set %d0 */
    movew %fp@(-2050),%d0
    cmpw %fp@(-2052),%d0
    jbhi rsrc_DRVR_50__ATBOOT_9EE_2C0
    cmpl %fp@(-2034),%d5
    jbgt rsrc_DRVR_50__ATBOOT_9EE_202
    jbra rsrc_DRVR_50__ATBOOT_9EE_2C0
rsrc_DRVR_50__ATBOOT_9EE_2BE:  /* set %d4 */
    moveq #-3,%d4
rsrc_DRVR_50__ATBOOT_9EE_2C0:  /* from here: pea %fp@(-320) */
    pea %fp@(-320)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_43E)
    movel %fp@(-324),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_20A)
    tstw %fp@(-1426)
    addql #8,%sp
    jbeq rsrc_DRVR_50__ATBOOT_9EE_2E6
    subql #2,%sp
    movew %fp@(-1426),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_4292)
    movew %sp@+,%fp@(-1428)
rsrc_DRVR_50__ATBOOT_9EE_2E6:  /* test %fp@(-2048) */
    tstl %fp@(-2048)
    jbeq rsrc_DRVR_50__ATBOOT_9EE_2FA
    tstl %d4
    jbeq rsrc_DRVR_50__ATBOOT_9EE_2FA
    movel %fp@(-2048),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D0E)
    jbra rsrc_DRVR_50__ATBOOT_9EE_302
rsrc_DRVR_50__ATBOOT_9EE_2FA:  /* set %a0 */
    moveal %fp@(24),%a0
    movel %fp@(-2048),%a0@
rsrc_DRVR_50__ATBOOT_9EE_302:  /* test %d4 */
    tstl %d4
    jbeq rsrc_DRVR_50__ATBOOT_9EE_30A
    movel %d4,%d0
    jbra rsrc_DRVR_50__ATBOOT_9EE_33E
rsrc_DRVR_50__ATBOOT_9EE_30A:  /* set %d0 */
    movew %fp@(-2050),%d0
    cmpw %fp@(-2052),%d0
    jbhi rsrc_DRVR_50__ATBOOT_9EE_318
    moveq #-4,%d0
    jbra rsrc_DRVR_50__ATBOOT_9EE_33E
rsrc_DRVR_50__ATBOOT_9EE_318:  /* set %d0 */
    moveq #-1,%d0
    cmpl %fp@(-1424),%d0
    jbne rsrc_DRVR_50__ATBOOT_9EE_324
    moveq #-3,%d0
    jbra rsrc_DRVR_50__ATBOOT_9EE_33E
rsrc_DRVR_50__ATBOOT_9EE_324:  /* set %a0 */
    moveal %fp@(28),%a0
    movel %fp@(-1424),%a0@
    pea %fp@(-2014)
    movel %fp@(32),%sp@-
    pea DiskVars_JReSeek
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D2C)
    movel %d4,%d0
rsrc_DRVR_50__ATBOOT_9EE_33E:  /* restore registers, return */
    moveml %fp@(-2084),%d4-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (0 instructions) (mechanical summary) */
PSTR_BootServer:
    .ascii  "\012BootServer\000"

/* subroutine (3 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_D42:
    moveal %sp@+,%a0
    movel %sp@+,0xb50
    jmp %a0@

/* subroutine (89 instructions): calls rsrc_DRVR_50__ATBOOT_E56, rsrc_DRVR_50__ATBOOT_E48, rsrc_DRVR_50__ATBOOT_E72, rsrc_DRVR_50__ATBOOT_E68, rsrc_DRVR_50__ATBOOT_842 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_D42_8:
    moveml %d4-%d7,%sp@-
    cmpib #10,%a3@(-1)
    jbne rsrc_DRVR_50__ATBOOT_D42_90
    cmpiw #6,%d1
    jbmi rsrc_DRVR_50__ATBOOT_D42_90
    moveal 0xb50,%a5
    cmpib #1,%a2@(3)
    jbne rsrc_DRVR_50__ATBOOT_D42_32
    moveb %a2@(2),%d2
    swap %d2
    movew %a2@(26),%d2
    jbra rsrc_DRVR_50__ATBOOT_D42_3C
rsrc_DRVR_50__ATBOOT_D42_32:  /* set %d2 */
    moveb %a3@(-4),%d2
    swap %d2
    movew %a3@(-7),%d2
rsrc_DRVR_50__ATBOOT_D42_3C:  /* from here: swap %d2 */
    swap %d2
    lslw #8,%d2
    moveb %a3@(-2),%d2
    moveq #6,%d3
    subal %d3,%sp
    moveal %sp,%a3
    jsr %a4@
    movew %sp@+,%d0
    movel %sp@+,%d5
    swap %d5
    tstw %d3
    jbne rsrc_DRVR_50__ATBOOT_D42_100
    moveb %d0,%d3
    cmpib #1,%d3
    jbgt rsrc_DRVR_50__ATBOOT_D42_90
    lsrw #8,%d0
    cmpib #4,%d0
    jbne rsrc_DRVR_50__ATBOOT_D42_C8
    cmpl %a5@(38),%d2
    jbne rsrc_DRVR_50__ATBOOT_D42_90
    cmpw %a5@,%d5
    jbne rsrc_DRVR_50__ATBOOT_D42_90
    swap %d5
    cmpw %a5@(8),%d5
    jbgt rsrc_DRVR_50__ATBOOT_D42_90
    moveal %a5@(4),%a3
    movel %a3,%d6
    movew %d5,%d0
    jbsr rsrc_DRVR_50__ATBOOT_E56
    jbeq rsrc_DRVR_50__ATBOOT_D42_9A
    moveq #-1,%d0
    movel %a5,%d7
    jsr %pc@(rsrc_DRVR_50__ATBOOT_E48)
rsrc_DRVR_50__ATBOOT_D42_90:  /* restore registers */
    moveml %sp@+,%d4-%d7
    moveq #0,%d3
    jmp %a4@(2)
rsrc_DRVR_50__ATBOOT_D42_9A:  /* set %d0 */
    movel %a5@(12),%d0
    jbeq rsrc_DRVR_50__ATBOOT_D42_90
    moveal %d0,%a3
    movew %d5,%d0
    jbsr rsrc_DRVR_50__ATBOOT_E72
    movew %a5@(16),%d3
    movel %a5,%d7
    jsr %a4@(2)
    jbne rsrc_DRVR_50__ATBOOT_D42_100
    tstw %d3
    jbgt rsrc_DRVR_50__ATBOOT_D42_100
    moveal %d6,%a0
    movew %d5,%d0
    jsr %pc@(rsrc_DRVR_50__ATBOOT_E68)
    moveq #0,%d0
    jsr %pc@(rsrc_DRVR_50__ATBOOT_E48)
    jbra rsrc_DRVR_50__ATBOOT_D42_100
rsrc_DRVR_50__ATBOOT_D42_C8:  /* test #7,%d0 */
    cmpib #7,%d0
    jbeq rsrc_DRVR_50__ATBOOT_D42_100
    cmpiw #-1,%a5@
    jbne rsrc_DRVR_50__ATBOOT_D42_90
    cmpib #2,%d0
    jbne rsrc_DRVR_50__ATBOOT_D42_90
    lea %a5@(46),%a3
    moveb %d0,%a3@+
    moveb %d3,%a3@+
    swap %d5
    movel %d5,%a3@+
    movel #586,%d3
    movel %a5,%d7
    jsr %a4@(2)
    jbne rsrc_DRVR_50__ATBOOT_D42_100
    movel %d7,%sp@-
    movel %d2,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_842)
    lea %sp@(8),%sp
rsrc_DRVR_50__ATBOOT_D42_100:  /* restore registers, return */
    moveml %sp@+,%d4-%d7
    rts

/* subroutine (5 instructions): calls rsrc_DRVR_50__ATBOOT_894 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_E48:
    movel %d0,%sp@-
    movel %d7,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_894)
    lea %sp@(8),%sp
    rts

/* subroutine (6 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_E56:
    moveml %d1,%sp@-
    movew %d0,%d1
    lsrw #3,%d0
    btst %d1,%a3@(0x0,%d0:w)
    moveml %sp@+,%d1
    rts

/* subroutine (4 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_E68:
    movew %d0,%d1
    lsrw #3,%d0
    bset %d1,%a0@(0x0,%d0:w)
    rts

/* subroutine (5 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_E72:
    movel %d0,%sp@-
    muluw %a5@(16),%d0
    addal %d0,%a3
    movel %sp@+,%d0
    rts

/* subroutine (554 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_E7E:
    linkw %fp,#-52
    moveml %d4-%d7/%a3-%a4,%sp@-
    moveal %fp@(12),%a0
    movel %a0@,%fp@(-52)
    moveal %fp@(12),%a0
    movel %a0@(4),%fp@(-48)
    moveal %fp@(12),%a0
    movel %a0@(8),%fp@(-44)
    moveal %fp@(12),%a0
    movel %a0@(12),%fp@(-40)
    moveal %fp@(12),%a0
    movel %a0@(16),%fp@(-36)
    moveal %fp@(12),%a0
    movel %a0@(20),%fp@(-32)
    moveal %fp@(12),%a0
    movel %a0@(24),%fp@(-28)
    moveal %fp@(12),%a0
    movel %a0@(28),%fp@(-24)
    moveal %fp@(12),%a0
    movel %a0@(32),%fp@(-20)
    moveal %fp@(12),%a0
    movel %a0@(36),%fp@(-16)
    moveal %fp@(12),%a0
    movel %a0@(40),%fp@(-12)
    moveal %fp@(12),%a0
    movel %a0@(44),%fp@(-8)
    moveal %fp@(12),%a0
    movel %a0@(48),%d4
    moveal %fp@(12),%a0
    movel %a0@(52),%d5
    moveal %fp@(12),%a0
    movel %a0@(56),%d6
    moveal %fp@(12),%a0
    movel %a0@(60),%fp@(-4)
    movel %fp@(16),%d0
    eorl %d0,%fp@(-52)
    movel %fp@(20),%d0
    eorl %d0,%fp@(-48)
    movel %fp@(24),%d0
    eorl %d0,%fp@(-44)
    moveal %fp@(28),%a0
    lea %a0@,%a3
    moveal %a3,%a4
    addal #1024,%a4
    movel #255,%d0
    andl %fp@(-52),%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-48)
    eorl %d7,%fp@(-4)
    movel #255,%d0
    andl %fp@(-48),%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-44)
    eorl %d7,%fp@(-52)
    movel #255,%d0
    andl %fp@(-44),%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-40)
    eorl %d7,%fp@(-48)
    movel #255,%d0
    andl %fp@(-40),%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-36)
    eorl %d7,%fp@(-44)
    movel #255,%d0
    andl %fp@(-36),%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-32)
    eorl %d7,%fp@(-40)
    movel #255,%d0
    andl %fp@(-32),%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-28)
    eorl %d7,%fp@(-36)
    movel #255,%d0
    andl %fp@(-28),%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-24)
    eorl %d7,%fp@(-32)
    movel #255,%d0
    andl %fp@(-24),%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-20)
    eorl %d7,%fp@(-28)
    movel #255,%d0
    andl %fp@(-20),%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-16)
    eorl %d7,%fp@(-24)
    movel #255,%d0
    andl %fp@(-16),%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-12)
    eorl %d7,%fp@(-20)
    movel #255,%d0
    andl %fp@(-12),%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-8)
    eorl %d7,%fp@(-16)
    movel #255,%d0
    andl %fp@(-8),%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%d4
    eorl %d7,%fp@(-12)
    movel #255,%d0
    andl %d4,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%d5
    eorl %d7,%fp@(-8)
    movel #255,%d0
    andl %d5,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%d6
    eorl %d7,%d4
    movel #255,%d0
    andl %d6,%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-4)
    eorl %d7,%d5
    movel #255,%d0
    andl %fp@(-4),%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-52)
    eorl %d7,%d6
    addaw #16384,%a3
    moveal %a3,%a4
    addal #1024,%a4
    moveq #16,%d0
    movel %fp@(-52),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-48)
    eorl %d7,%fp@(-4)
    moveq #16,%d0
    movel %fp@(-48),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-44)
    eorl %d7,%fp@(-52)
    moveq #16,%d0
    movel %fp@(-44),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-40)
    eorl %d7,%fp@(-48)
    moveq #16,%d0
    movel %fp@(-40),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-36)
    eorl %d7,%fp@(-44)
    moveq #16,%d0
    movel %fp@(-36),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-32)
    eorl %d7,%fp@(-40)
    moveq #16,%d0
    movel %fp@(-32),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-28)
    eorl %d7,%fp@(-36)
    moveq #16,%d0
    movel %fp@(-28),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-24)
    eorl %d7,%fp@(-32)
    moveq #16,%d0
    movel %fp@(-24),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-20)
    eorl %d7,%fp@(-28)
    moveq #16,%d0
    movel %fp@(-20),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-16)
    eorl %d7,%fp@(-24)
    moveq #16,%d0
    movel %fp@(-16),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-12)
    eorl %d7,%fp@(-20)
    moveq #16,%d0
    movel %fp@(-12),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-8)
    eorl %d7,%fp@(-16)
    moveq #16,%d0
    movel %fp@(-8),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%d4
    eorl %d7,%fp@(-12)
    moveq #16,%d0
    movel %d4,%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%d5
    eorl %d7,%fp@(-8)
    moveq #16,%d0
    movel %d5,%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a3@(0x0,%d0:l),%d7
    eorl %d7,%d6
    eorl %d7,%d4
    moveq #16,%d0
    movel %d6,%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-4)
    eorl %d7,%d5
    moveq #16,%d0
    movel %fp@(-4),%d1
    lsrl %d0,%d1
    movel #255,%d0
    andl %d1,%d0
    asll #2,%d0
    movel %a4@(0x0,%d0:l),%d7
    eorl %d7,%fp@(-52)
    eorl %d7,%d6
    subaw #8192,%a3
    moveal %a3,%a4
    addal #1024,%a4
    moveq #24,%d0
    movel %fp@(-52),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-48)
    eorl %d7,%fp@(-4)
    moveq #24,%d0
    movel %fp@(-48),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-44)
    eorl %d7,%fp@(-52)
    moveq #24,%d0
    movel %fp@(-44),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-40)
    eorl %d7,%fp@(-48)
    moveq #24,%d0
    movel %fp@(-40),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-36)
    eorl %d7,%fp@(-44)
    moveq #24,%d0
    movel %fp@(-36),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-32)
    eorl %d7,%fp@(-40)
    moveq #24,%d0
    movel %fp@(-32),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-28)
    eorl %d7,%fp@(-36)
    moveq #24,%d0
    movel %fp@(-28),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-24)
    eorl %d7,%fp@(-32)
    moveq #24,%d0
    movel %fp@(-24),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-20)
    eorl %d7,%fp@(-28)
    moveq #24,%d0
    movel %fp@(-20),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-16)
    eorl %d7,%fp@(-24)
    moveq #24,%d0
    movel %fp@(-16),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-12)
    eorl %d7,%fp@(-20)
    moveq #24,%d0
    movel %fp@(-12),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-8)
    eorl %d7,%fp@(-16)
    moveq #24,%d0
    movel %fp@(-8),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%d4
    eorl %d7,%fp@(-12)
    moveq #24,%d0
    movel %d4,%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%d5
    eorl %d7,%fp@(-8)
    moveq #24,%d0
    movel %d5,%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%d6
    eorl %d7,%d4
    moveq #24,%d0
    movel %d6,%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-4)
    eorl %d7,%d5
    moveq #24,%d0
    movel %fp@(-4),%d1
    lsrl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-52)
    eorl %d7,%d6
    addaw #16384,%a3
    moveal %a3,%a4
    addal #1024,%a4
    movel %fp@(-52),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-48)
    eorl %d7,%fp@(-4)
    movel %fp@(-48),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-44)
    eorl %d7,%fp@(-52)
    movel %fp@(-44),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-40)
    movel %fp@(-40),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-36)
    movel %fp@(-36),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-32)
    movel %fp@(-32),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-28)
    movel %fp@(-28),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-24)
    movel %fp@(-24),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-20)
    movel %fp@(-20),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-16)
    movel %fp@(-16),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-12)
    movel %fp@(-12),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-8)
    movel %fp@(-8),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%d4
    movel %d4,%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%d5
    movel %d5,%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a3@(0x0,%d1:l),%d7
    eorl %d7,%d6
    eorl %d7,%d4
    movel %d6,%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%fp@(-4)
    eorl %d7,%d5
    movel %fp@(-4),%d0
    lsrl #8,%d0
    movel #255,%d1
    andl %d0,%d1
    asll #2,%d1
    movel %a4@(0x0,%d1:l),%d7
    eorl %d7,%d6
    movel %fp@(16),%d0
    eorl %d0,%d6
    movel %fp@(20),%d0
    eorl %d0,%d5
    movel %fp@(24),%d0
    eorl %d0,%d4
    moveal %fp@(12),%a0
    movel %fp@(-4),%d0
    movel %a0@,%d1
    eorl %d0,%d1
    moveal %fp@(8),%a0
    movel %d1,%a0@
    moveal %fp@(12),%a0
    movel %d6,%d0
    movel %a0@(4),%d1
    eorl %d0,%d1
    moveal %fp@(8),%a0
    movel %d1,%a0@(4)
    moveal %fp@(12),%a0
    movel %d5,%d0
    movel %a0@(8),%d1
    eorl %d0,%d1
    moveal %fp@(8),%a0
    movel %d1,%a0@(8)
    moveal %fp@(12),%a0
    movel %d4,%d0
    movel %a0@(12),%d1
    eorl %d0,%d1
    moveal %fp@(8),%a0
    movel %d1,%a0@(12)
    moveml %fp@(-76),%d4-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (155 instructions): calls rsrc_DRVR_50__ATBOOT_3CEA; low memory MemErr (mechanical summary) */
rsrc_DRVR_50__ATBOOT_15DA:
    linkw %fp,#0
    moveml %d3-%d7/%a3-%a4,%sp@-
    subql #4,%sp
    movel #32768,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3CEA)
    moveal %fp@(12),%a0
    movel %sp@+,%a0@
    moveal %fp@(12),%a0
    tstl %a0@
    jbne rsrc_DRVR_50__ATBOOT_15DA_2E
    subql #2,%sp
    movew MemErr,%sp@
    movew %sp@+,%d0
    jbra rsrc_DRVR_50__ATBOOT_15DA_192
rsrc_DRVR_50__ATBOOT_15DA_2E:  /* clear %d4 */
    moveq #0,%d4
    moveq #8,%d3
rsrc_DRVR_50__ATBOOT_15DA_32:  /* loop: movea */
    moveal %fp@(8),%a0
    movel %d4,%d0
    movel %d0,%d1
    muluw #1024,%d0
    swap %d1
    muluw #1024,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a0@(0x0,%d0:l),%a3
    moveal %fp@(12),%a0
    moveal %a0@,%a0
    movel %d4,%d0
    movel %d0,%d1
    muluw #1024,%d0
    swap %d1
    muluw #1024,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a0@(0x0,%d0:l),%a4
    clrw %d7
    movew #256,%d2
rsrc_DRVR_50__ATBOOT_15DA_72:  /* loop: move */
    movel %a3@+,%a4@+
    addqw #1,%d7
    cmpw %d7,%d2
    jbgt rsrc_DRVR_50__ATBOOT_15DA_72
    moveal %fp@(8),%a0
    movel %d4,%d0
    movel %d0,%d1
    muluw #1024,%d0
    swap %d1
    muluw #1024,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a0@(0x0,%d0:l),%a3
    moveal %fp@(12),%a0
    moveal %a0@,%a0
    movel %d4,%d0
    movel %d0,%d1
    muluw #1024,%d0
    swap %d1
    muluw #1024,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a0@(8192),%a0
    lea %a0@(0x0,%d0:l),%a4
    moveq #24,%d5
    moveq #8,%d6
    clrw %d7
    movew #256,%d2
rsrc_DRVR_50__ATBOOT_15DA_C2:  /* loop: move */
    movel %a3@,%d0
    lsrl %d6,%d0
    movel %a3@+,%d1
    lsll %d5,%d1
    orl %d0,%d1
    movel %d1,%a4@+
    addqw #1,%d7
    cmpw %d7,%d2
    jbgt rsrc_DRVR_50__ATBOOT_15DA_C2
    moveal %fp@(8),%a0
    movel %d4,%d0
    movel %d0,%d1
    muluw #1024,%d0
    swap %d1
    muluw #1024,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a0@(0x0,%d0:l),%a3
    moveal %fp@(12),%a0
    moveal %a0@,%a0
    movel %d4,%d0
    movel %d0,%d1
    muluw #1024,%d0
    swap %d1
    muluw #1024,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a0@(16384),%a0
    lea %a0@(0x0,%d0:l),%a4
    moveq #16,%d6
    moveb %d6,%d5
    clrw %d7
    movew #256,%d2
rsrc_DRVR_50__ATBOOT_15DA_11C:  /* loop: move */
    movel %a3@,%d0
    lsrl %d6,%d0
    movel %a3@+,%d1
    lsll %d5,%d1
    orl %d0,%d1
    movel %d1,%a4@+
    addqw #1,%d7
    cmpw %d7,%d2
    jbgt rsrc_DRVR_50__ATBOOT_15DA_11C
    moveal %fp@(8),%a0
    movel %d4,%d0
    movel %d0,%d1
    muluw #1024,%d0
    swap %d1
    muluw #1024,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a0@(0x0,%d0:l),%a3
    moveal %fp@(12),%a0
    moveal %a0@,%a0
    movel %d4,%d0
    movel %d0,%d1
    muluw #1024,%d0
    swap %d1
    muluw #1024,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a0@(24576),%a0
    lea %a0@(0x0,%d0:l),%a4
    moveq #8,%d5
    moveq #24,%d6
    clrw %d7
    movew #256,%d2
rsrc_DRVR_50__ATBOOT_15DA_176:  /* loop: move */
    movel %a3@,%d0
    lsrl %d6,%d0
    movel %a3@+,%d1
    lsll %d5,%d1
    orl %d0,%d1
    movel %d1,%a4@+
    addqw #1,%d7
    cmpw %d7,%d2
    jbgt rsrc_DRVR_50__ATBOOT_15DA_176
    addql #1,%d4
    cmpl %d4,%d3
    jbgt rsrc_DRVR_50__ATBOOT_15DA_32
    moveq #0,%d0
rsrc_DRVR_50__ATBOOT_15DA_192:  /* restore registers, return */
    moveml %fp@(-28),%d3-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (74 instructions): calls rsrc_DRVR_50__ATBOOT_15DA, rsrc_DRVR_50__ATBOOT_E7E (mechanical summary) */
rsrc_DRVR_50__ATBOOT_1776:
    linkw %fp,#-64
    moveml %d3-%d7/%a3-%a4,%sp@-
    moveal %fp@(12),%a4
    lea %fp@(-64),%a3
    movel %fp@(24),%d4
    moveq #0,%d4
    moveq #0,%d5
    movel %fp@(24),%d0
    asll #3,%d0
    movel %d0,%d6
    movel #268435392,%d0
    andl %fp@(24),%d0
    movel %d0,%fp@(24)
    tstl %a4@
    jbne rsrc_DRVR_50__ATBOOT_1776_48
    movel %a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_15DA)
    movew %d0,%d7
    addql #8,%sp
    jbeq rsrc_DRVR_50__ATBOOT_1776_48
    movew %d7,%d0
    jbra rsrc_DRVR_50__ATBOOT_1776_CA
rsrc_DRVR_50__ATBOOT_1776_48:  /* clear %d7 */
    moveq #0,%d7
    moveq #16,%d3
rsrc_DRVR_50__ATBOOT_1776_4C:  /* loop: move */
    movel %d7,%d0
    aslw #2,%d0
    moveq #0,%d1
    movel %d1,%a3@(0x0,%d0:w)
    addql #1,%d7
    cmpl %d7,%d3
    jbgt rsrc_DRVR_50__ATBOOT_1776_4C
    moveq #0,%d7
rsrc_DRVR_50__ATBOOT_1776_5E:  /* loop: move */
    movel %a4@,%sp@-
    movel %d6,%sp@-
    movel %d5,%sp@-
    movel %d4,%sp@-
    movel %fp@(16),%sp@-
    movel %d7,%d0
    aslw #2,%d0
    pea %a3@(0x0,%d0:w)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_E7E)
    addql #1,%d6
    subil #64,%fp@(24)
    addil #64,%fp@(16)
    addql #4,%d7
    moveq #16,%d0
    cmpl %d7,%d0
    lea %sp@(24),%sp
    jbgt rsrc_DRVR_50__ATBOOT_1776_AC
    movel %a4@,%sp@-
    movel %d6,%sp@-
    movel %d5,%sp@-
    movel %d4,%sp@-
    movel %a3,%sp@-
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_E7E)
    moveq #4,%d7
    addql #1,%d6
    lea %sp@(24),%sp
rsrc_DRVR_50__ATBOOT_1776_AC:  /* test %fp@(24) */
    tstl %fp@(24)
    jbhi rsrc_DRVR_50__ATBOOT_1776_5E
    movel %a4@,%sp@-
    movel %d6,%sp@-
    movel %d5,%sp@-
    movel %d4,%sp@-
    movel %a3,%sp@-
    movel %fp@(20),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_E7E)
    moveq #0,%d0
    lea %sp@(24),%sp
rsrc_DRVR_50__ATBOOT_1776_CA:  /* restore registers, return */
    moveml %fp@(-92),%d3-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (3 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_184A:
    lea %pc@(rsrc_DRVR_50__ATBOOT_1852),%a0
    movel %a0,%d0
    rts
rsrc_DRVR_50__ATBOOT_1852:  /* (data) */
    .short  0x64F9	| bccs 40853dad <rsrc_DRVR_50__ATBOOT_184A+0x3>
    .short  0x001B, 0xFEDD	| orib #-35,%a3@+
    mulsw %fp@(-113,%d7:l:4),%d6
    .short  0xF1E2	| .short 0xf1e2
    moveb %sp@,0x1514
    unpk %a4@-,%a5@-,#6355
    addal %sp@+,%fp
    orb %fp@+,%d4
    .short  0x6EAB	| bgts 40853d77 <rsrc_DRVR_50__ATBOOT_1776_5E+0x43>
    addqw #8,%fp@
    .short  0x88CE	| .short 0x88ce
    addaw %a1@-,%a4
    chkl %a4@,%d4
    orw %d4,%a1@+
    .short  0x69C5	| bvss 40853d9d <rsrc_DRVR_50__ATBOOT_1776_AC+0x1b>
    .short  0x6FD5	| bles 40853daf <rsrc_DRVR_50__ATBOOT_184A+0x5>
    eorl %d3,%a1@+
    chkl %d3,%d7
    .short  0x0FBC	| .short 0x0fbc
    rorb %d7,%d6
    movew %fp@-,%d6
    .short  0x4940	| .short 0x4940
    movel %a5@,%a0@(32344)
    lslw #8,%d3
    .short  0x3FC2	| .short 0x3fc2
    moveal %a4@+,%sp
    .short  0xF591, 0xDCEF, 0xF8CE, 0x092A, 0x1648, 0xBE81, 0x2936, 0xFF7B	| 40853DF0
    .short  0x0C6A, 0xD525, 0x1037, 0xAFA4, 0x48F1, 0x7DAF, 0xC95A, 0x1EA6	| 40853E00
    .short  0x9C3F, 0xA417, 0xABE7, 0x5890, 0xE423, 0xB0CB, 0x70C0, 0xC850	| 40853E10
    .short  0x25F7, 0x244D, 0x97E3, 0x1FF3, 0x595F, 0xC4EC, 0x6396, 0x5918	| 40853E20
    .short  0x1E17, 0xE635, 0xB477, 0x354E, 0x7DBF, 0x796F, 0x7753, 0x66EB	| 40853E30
    .short  0x52CC, 0x77C3, 0xF995, 0x32E3, 0xA927, 0x80CC, 0xAED6, 0x4E2B	| 40853E40
    .short  0xE89D, 0x375B, 0xBD28, 0xAD1A, 0x3D05, 0x2B1B, 0x42B3, 0x16C4	| 40853E50
    .short  0x4C71, 0x4D54, 0xBFA8, 0xE57D, 0xDC7A, 0xEC6D, 0x8144, 0x5A71	| 40853E60
    .short  0x046B, 0xD822, 0x9650, 0x87FC, 0x8F24, 0xCBC6, 0x0E09, 0xB639	| 40853E70
    .short  0x0366, 0xD9F7, 0x6092, 0xD393, 0xA70B, 0x1D31, 0xA08A, 0x9CD9	| 40853E80
    .short  0x71C9, 0x5C1E, 0xF445, 0x86FA, 0xB694, 0xFDB4, 0x4165, 0x8EAA	| 40853E90
    .short  0xFCBE, 0x4BCA, 0xC6EB, 0xFB7A, 0x94E5, 0x5789, 0xD04E, 0xFA13	| 40853EA0
    .short  0xCF35, 0x236B, 0x8DA9, 0x4133, 0xF000, 0x6224, 0x261C, 0xF412	| 40853EB0
    .short  0xF23B, 0xE75E, 0x56A4, 0x3002, 0x2116, 0xBAF1, 0x7F1F, 0xD098	| 40853EC0
    .short  0x72F9, 0xC1A3, 0x699C, 0xF1E8, 0x02AA, 0x0DD1, 0x45DC, 0x4FDC	| 40853ED0
    .short  0xE093, 0x8D84, 0x12F0, 0x6CD0, 0xF376, 0x3DE6, 0xB73D, 0x84BA	| 40853EE0
    .short  0x737F, 0xB43A, 0x30F2, 0x4456, 0x9F69, 0x00E4, 0xEACA, 0xB58D	| 40853EF0
    .short  0xE3B0, 0x9591, 0x13C8, 0xD62E, 0xFEE9, 0x9086, 0x1F83, 0xCED6	| 40853F00
    .short  0x9874, 0x2F79, 0x3CEE, 0xE857, 0x1C30, 0x4836, 0x65D1, 0xAB07	| 40853F10
    .short  0xB031, 0x914C, 0x844F, 0x15BF, 0x3BE8, 0x2C3F, 0x2A9A, 0x9EB9	| 40853F20
    .short  0x5FD4, 0x92E7, 0x472D, 0x2297, 0xCC5B, 0xEE5F, 0x2782, 0x5377	| 40853F30
    .short  0xB562, 0xDB8E, 0xBBCF, 0xF961, 0xDEDD, 0xC59B, 0x5C60, 0x1BD3	| 40853F40
    .short  0x910D, 0x26D2, 0x06AD, 0xB285, 0x14D8, 0x5ECF, 0x6B52, 0x7FEA	| 40853F50
    .short  0x78BB, 0x5048, 0x79AC, 0xED34, 0xA884, 0x36E5, 0x1D3C, 0x1753	| 40853F60
    .short  0x741D, 0x8C47, 0xCAED, 0x9D0A, 0x40EF, 0x3145, 0xE221, 0xDA27	| 40853F70
    .short  0xEB70, 0xDF73, 0x0BA3, 0x183C, 0x8789, 0x739A, 0xC0A6, 0x9A58	| 40853F80
    .short  0xDFC6, 0x54B1, 0x34C1, 0xAC3E, 0x242E, 0xCC49, 0x3902, 0x7B2D	| 40853F90
    .short  0xDA99, 0x8F15, 0xBC01, 0x29FD, 0x38C7, 0x27D5, 0x318F, 0x604A	| 40853FA0
    .short  0xAFF5, 0xF29C, 0x6818, 0xC38A, 0xA2EC, 0x1019, 0xD4C3, 0xA8FB	| 40853FB0
    .short  0x936E, 0x20ED, 0x7B39, 0x0B68, 0x6119, 0x89A0, 0x906F, 0x1CC7	| 40853FC0
    .short  0x829E, 0x9952, 0xEF4B, 0x850E, 0x9E8C, 0xCD06, 0x3A90, 0x6700	| 40853FD0
    .short  0x2F8E, 0xCFAC, 0x8CB7, 0xEAA2, 0x4B11, 0x988B, 0x4E6C, 0x46F0	| 40853FE0
    .short  0x66DF, 0xCA7E, 0xEC08, 0xC7BB, 0xA664, 0x831D, 0x17BD, 0x63F5	| 40853FF0
    .short  0x75E6, 0x9764, 0x350E, 0x4787, 0x0D42, 0x026C, 0xA4A2, 0x8167	| 40854000
    .short  0xD587, 0x61B6, 0xADAB, 0xAA65, 0x64D2, 0x70DA, 0x237B, 0x25E1	| 40854010
    .short  0xC74A, 0xA1C9, 0x01A0, 0x0EB0, 0xA5DA, 0x7670, 0xF741, 0x51C0	| 40854020
    .short  0x5AEA, 0x933D, 0xFA32, 0x0759, 0xFF1A, 0x5601, 0x0AB8, 0x5FDE	| 40854030
    .short  0xCB78, 0x3F32, 0xEDF8, 0xAEBE, 0xDBB9, 0x39F8, 0x326D, 0xD208	| 40854040
    .short  0x58C5, 0x9B63, 0x8BE4, 0xA572, 0xC80A, 0x28E0, 0xA19F, 0x4320	| 40854050
    .short  0x99FC, 0x3A37, 0xC3CD, 0xBF95, 0xC585, 0xB392, 0xC12A, 0x6AA7	| 40854060
    .short  0x07D7, 0x52F6, 0x6A61, 0x12D4, 0x83B1, 0x9643, 0x5B5E, 0x3E75	| 40854070
    .short  0x802B, 0x3BA5, 0x2B33, 0xA99F, 0x51A5, 0xBDA1, 0xE157, 0x78C2	| 40854080
    .short  0xE70C, 0xFCAE, 0x7CE0, 0xD160, 0x2267, 0x2AFF, 0xAC4D, 0x4A51	| 40854090
    .short  0x0947, 0x0AB2, 0xB83A, 0x7A04, 0xE579, 0x340D, 0xFD80, 0xB916	| 408540A0
    .short  0xE922, 0xE29D, 0x5E9B, 0xF562, 0x4AF4, 0x4CA9, 0xD9AF, 0x6BBD	| 408540B0
    .short  0x2CFE, 0xE3B7, 0xF620, 0xC274, 0x6E07, 0x5B42, 0xB9B6, 0xA069	| 408540C0
    .short  0x19BC, 0xF0F2, 0xC40F, 0x7221, 0x7AB5, 0x14C1, 0x9DF3, 0xF380	| 408540D0
    .short  0x2DAE, 0xE094, 0xBEB4, 0xA210, 0x1AFF, 0x0529, 0x575D, 0x55CD	| 408540E0
    .short  0xB27C, 0xA33B, 0xDDB2, 0x6528, 0xB37D, 0x740C, 0x05DB, 0xE96A	| 408540F0
    .short  0x62C4, 0x4078, 0x2846, 0x6D30, 0xD706, 0xBBF4, 0x8E2C, 0xBCE2	| 40854100
    .short  0xD3DE, 0x049E, 0x37FA, 0x01B5, 0xE634, 0x2D88, 0x6D8D, 0x7E5A	| 40854110
    .short  0x2E7E, 0xD741, 0x2013, 0x06E9, 0x0F97, 0xE45D, 0x3EBA, 0xB8AD	| 40854120
    .short  0x3386, 0x1305, 0x1B25, 0x0C03, 0x5354, 0x71C8, 0x9B75, 0xC638	| 40854130
    .short  0xFBD0, 0x197F, 0x11A1, 0xEF0F, 0x08FB, 0xF844, 0x8651, 0x3840	| 40854140
    .short  0x9563, 0x452F, 0x4443, 0x5D46, 0x4D55, 0x03D8, 0x764C, 0xB1B8	| 40854150
    .short  0xD638, 0xA70B, 0xBA2F, 0x94B3, 0xD210, 0xEB66, 0x92A7, 0xD409	| 40854160
    .short  0xC2D9, 0x6883, 0x8526, 0xA6DB, 0x8A15, 0x751F, 0x6C98, 0xDE76	| 40854170
    .short  0x9A88, 0xC9EE, 0x4668, 0x1A82, 0xA373, 0x0896, 0xAA49, 0x4223	| 40854180
    .short  0x3681, 0xF62C, 0x55CB, 0x9F1C, 0x5404, 0xF74F, 0xB15C, 0xC06E	| 40854190
    .short  0x4312, 0x6FFE, 0x5D72, 0x8AA8, 0x678B, 0x337C, 0xD129, 0x8211	| 408541A0
    .short  0xCEFD, 0x61B0, 0xB02F, 0x00E2, 0x7716, 0xBF32, 0xD884, 0x6FA3	| 408541B0
    .short  0x56FF, 0x3584, 0x2720, 0x5460, 0x7261, 0x7828, 0xC5AE, 0x2942	| 408541C0
    .short  0x11CF, 0x4E81, 0x528B, 0xDD54, 0x57A7, 0x0D9D, 0x32BE, 0xAF55	| 408541D0
    .short  0xB23F, 0x3F86, 0x99A0, 0xDBB4, 0xAF42, 0xD744, 0xDC65, 0x0C93	| 408541E0
    .short  0xECF0, 0xE359, 0x680B, 0x046D, 0xF2EF, 0x1BF2, 0x4487, 0x5951	| 408541F0
    .short  0x46D2, 0x8BDF, 0xD42B, 0x2B0D, 0x38EA, 0xAC18, 0xA09F, 0x73AF	| 40854200
    .short  0x8D78, 0x68AE, 0xBA06, 0xC5FF, 0xA500, 0x8DB3, 0x6B2D, 0xA040	| 40854210
    .short  0xD9B7, 0x8583, 0xC012, 0xB5FC, 0x22E3, 0x2397, 0x14D5, 0xA795	| 40854220
    .short  0xC69A, 0xB43F, 0xBCDB, 0x628D, 0x4AE0, 0x187A, 0x5941, 0xA949	| 40854230
    .short  0x1C34, 0x77CB, 0x9482, 0x1453, 0x0C67, 0x478A, 0x1253, 0x754A	| 40854240
    .short  0xE323, 0x7EA8, 0xC1E7, 0x9087, 0xBFAF, 0xD219, 0xBBE5, 0x6085	| 40854250
    .short  0x00CB, 0x3E69, 0x40A4, 0x3B7D, 0x5F5B, 0xB95E, 0x86F7, 0x08CD	| 40854260
    .short  0xC2E1, 0x02F7, 0xAD77, 0x40B5, 0xDAF1, 0x8E72, 0x5492, 0x740F	| 40854270
    .short  0xA82C, 0x3094, 0xF8E8, 0xC925, 0x810A, 0x89FA, 0x96C6, 0x7C43	| 40854280
    .short  0x75D1, 0x2F36, 0xB383, 0xA461, 0xC74F, 0x4426, 0x906D, 0x2009	| 40854290
    .short  0x3EDA, 0x2C41, 0xDFD8, 0xD8E0, 0x6097, 0xD08B, 0x1A03, 0x5EBB	| 408542A0
    .short  0xEA72, 0xAD56, 0x0825, 0x795B, 0x1388, 0x7D6F, 0x4DFE, 0xE7D9	| 408542B0
    .short  0xF74E, 0xEC89, 0x19A1, 0x82F0, 0xB55F, 0x0B70, 0xFCD4, 0xC433	| 408542C0
    .short  0xD7C7, 0x0305, 0xC3B8, 0x9CCC, 0x826E, 0x9B0A, 0x5848, 0xB3A4	| 408542D0
    .short  0x7130, 0x633D, 0x24ED, 0x3DDC, 0xE217, 0xB837, 0x6E76, 0x0139	| 408542E0
    .short  0xFDAC, 0x5CA2, 0x3769, 0x6BBE, 0x5B59, 0x883B, 0xAEBB, 0x21D6	| 408542F0
    .short  0xE605, 0x53B6, 0x23CD, 0xF5F1, 0xCB80, 0x4ACF, 0x04C2, 0x4C3A	| 40854300
    .short  0x91B4, 0xDA45, 0xE998, 0xB15F, 0x7B24, 0x57A7, 0x4CBC, 0x674E	| 40854310
    .short  0x0B1D, 0xB0D1, 0x8A3D, 0xE9D0, 0x677B, 0x382F, 0x9DC0, 0x3403	| 40854320
    .short  0x1701, 0x1A9B, 0x1B02, 0xE5DE, 0x7DA9, 0x33C4, 0xA173, 0x4D1B	| 40854330
    .short  0x8B0F, 0x376E, 0x2F6F, 0x247E, 0x2EEE, 0x27F6, 0xCFA8, 0x2814	| 40854340
    .short  0xE04D, 0x155A, 0xE77E, 0x2592, 0x483C, 0x1747, 0x3143, 0x9923	| 40854350
    .short  0xCD46, 0xDF1A, 0x06D9, 0x724F, 0x69E6, 0xB76B, 0x70FA, 0xB6A5	| 40854360
    .short  0x36FB, 0xF4EE, 0x0951, 0xEE35, 0x7EEC, 0x874D, 0xB952, 0x5257	| 40854370
    .short  0x9C1F, 0xFEE4, 0x0F32, 0x5D4B, 0x3009, 0xBC71, 0xEF8A, 0xFDAC	| 40854380
    .short  0x884B, 0x4B9C, 0x50CC, 0xF72B, 0xB88E, 0x7B0B, 0x974C, 0xABD3	| 40854390
    .short  0xCC8C, 0x58C9, 0x61C5, 0x2D73, 0x4228, 0x5AFB, 0x05BF, 0xAA76	| 408543A0
    .short  0x6227, 0x76E8, 0xBDF9, 0xC70E, 0x291E, 0xFB48, 0x189D, 0xCAF4	| 408543B0
    .short  0x0A79, 0x0F29, 0x8C9E, 0x9F1C, 0xF3D3, 0x658E, 0x7470, 0xC2CE	| 408543C0
    .short  0x3B26, 0x6D04, 0xD3DF, 0x8CC7, 0x808D, 0x92BD, 0x43C9, 0xA88C	| 408543D0
    .short  0xB490, 0x5B52, 0x840D, 0x32D8, 0xFF58, 0xD9B2, 0x7FC8, 0x0ED2	| 408543E0
    .short  0x2C15, 0x7A63, 0x6F5A, 0x5699, 0x9E18, 0xF050, 0xDBF2, 0x4267	| 408543F0
    .short  0x5129, 0xA23C, 0x2A1A, 0x9866, 0x9B19, 0x1E88, 0x1540, 0xD3F5	| 40854400
    .short  0x89F3, 0xD164, 0xF55C, 0x13CA, 0xD545, 0xF3AA, 0xF0AB, 0x5FA1	| 40854410
    .short  0xD0B6, 0x9AEC, 0x4908, 0xA5E5, 0x3AA2, 0xE212, 0xA254, 0x9D6C	| 40854420
    .short  0xF60E, 0x2E90, 0x1E6B, 0x1279, 0x6C36, 0xC8C2, 0x83AD, 0x411D	| 40854430
    .short  0x2163, 0x07D7, 0xE435, 0x4611, 0xDE74, 0xA696, 0x5A93, 0xE434	| 40854440
    .short  0x2660, 0x26C3, 0xE57F, 0xF110, 0x95F5, 0x93A9, 0x8F91, 0xBA2E	| 40854450
    .short  0xB74A, 0xC365, 0xEE04, 0x5538, 0xA7E9, 0x1D75, 0xDD3E, 0xCC31	| 40854460
    .short  0x53E4, 0xBB77, 0xE821, 0x91B7, 0x0E44, 0x0691, 0xD65E, 0xDE16	| 40854470
    .short  0x5CA6, 0xA378, 0xC968, 0xCD13, 0x34D0, 0xCE00, 0x6694, 0x710C	| 40854480
    .short  0x283A, 0xE62D, 0xC87A, 0x1C1E, 0xF97D, 0xE0AB, 0x92AA, 0xB246	| 40854490
    .short  0x792E, 0x4FB9, 0xFADE, 0x5174, 0xAC1C, 0x6968, 0x2557, 0xE898	| 408544A0
    .short  0x5537, 0x45A6, 0x6DA3, 0x961F, 0x4B99, 0xDC7F, 0x3CF8, 0x4902	| 408544B0
    .short  0x020C, 0x6E17, 0xFB7C, 0xC0FD, 0x8747, 0xCB8F, 0xEB6A, 0x8458	| 408544C0
    .short  0xCEB9, 0x64BC, 0xF196, 0x1021, 0xAAD6, 0x50C0, 0x1FB3, 0xAEC5	| 408544D0
    .short  0xD175, 0x864C, 0x9A22, 0x7FE3, 0x851B, 0x3CB8, 0xAB33, 0x319A	| 408544E0
    .short  0x4EFD, 0xEBC6, 0x6513, 0xE1E9, 0xE164, 0x48B1, 0x3585, 0x8FDD	| 408544F0
    .short  0xA3E2, 0x36D4, 0x1D07, 0x70E1, 0x9F5D, 0xC127, 0x3F39, 0x836A	| 40854500
    .short  0x98B1, 0xA130, 0x3371, 0x3A2C, 0x7881, 0x0A5D, 0x1686, 0xD506	| 40854510
    .short  0x0150, 0x05C8, 0xB68F, 0xBEF8, 0xA6C1, 0x2A82, 0x0311, 0x80BA	| 40854520
    .short  0x4F10, 0xEA9F, 0x76CA, 0xEF80, 0xCA3B, 0xD47C, 0x4755, 0xBD07	| 40854530
    .short  0xED89, 0xFAC1, 0x7A95, 0x399E, 0x2B56, 0x16DA, 0xD26C, 0xCF2A	| 40854540
    .short  0x41A5, 0x6AAD, 0xB1EB, 0x81DB, 0x5EF6, 0x6CE6, 0x2D9B, 0x9EEF	| 40854550
    .short  0x07FC, 0x6662, 0x10BD, 0x9420, 0x2049, 0xF95C, 0x3962, 0x19A0	| 40854560
    .short  0xF4B0, 0xF2F9, 0x63B2, 0x97EB, 0x7314, 0x4308, 0x6466, 0x1FED	| 40854570
    .short  0x0DCE, 0xF83E, 0xFEDC, 0xC6E7, 0xA431, 0x8ABF, 0x8E38, 0x22F3	| 40854580
    .short  0x45B5, 0x957B, 0x5DDD, 0xFC15, 0x93BA, 0x1101, 0xA9C3, 0xF622	| 40854590
    .short  0xBE2A, 0xEDFE, 0x7CC4, 0x09EA, 0x3D9C, 0xFF24, 0xC4D7, 0xD6D5	| 408545A0
    .short  0x6AF4, 0x4876, 0x00CE, 0x425C, 0x8FFA, 0xBEC6, 0x7996, 0xD0CC	| 408545B0
    .short  0x610C, 0xB2A1, 0xD01D, 0xADAE, 0x8C7A, 0x0AB5, 0xD392, 0x020B	| 408545C0
    .short  0x2E45, 0x3032, 0x5588, 0x8B63, 0x0249, 0x9273, 0x20E4, 0x2E98	| 408545D0
    .short  0xA92D, 0xB708, 0x17DF, 0xEB68, 0x58AA, 0x2031, 0x86A6, 0x225D	| 408545E0
    .short  0x0823, 0x3F66, 0xBABE, 0x7E48, 0x53BF, 0x6E96, 0x684E, 0xE63B	| 408545F0
    .short  0xD63D, 0xD46E, 0xC4F8, 0x4B2E, 0x89A7, 0x0CA5, 0xAD9D, 0xF0C3	| 40854600
    .short  0x9E2E, 0x6D86, 0x6DFB, 0x1927, 0xFE8A, 0xA4DB, 0x62D2, 0xF4C0	| 40854610
    .short  0x6E25, 0x8A1D, 0xB2F9, 0xAB7E, 0x0F9E, 0xFBCB, 0x5A79, 0x132B	| 40854620
    .short  0x6A2A, 0x7834, 0x4DA3, 0x0807, 0x7B50, 0xA378, 0xDA3F, 0xB0E5	| 40854630
    .short  0xA681, 0x94EF, 0x414F, 0xAF88, 0x94C2, 0x5237, 0x4B69, 0x4517	| 40854640
    .short  0x3E46, 0x6AA6, 0x6044, 0x2FBF, 0x64FC, 0x9185, 0xFFC3, 0xBC8C	| 40854650
    .short  0x07E2, 0xDC11, 0x196F, 0xC2DE, 0x9B41, 0x76F0, 0x06B9, 0xDB39	| 40854660
    .short  0x3172, 0x6797, 0x50DB, 0xCA65, 0x5204, 0x79B1, 0xAA01, 0x6B7F	| 40854670
    .short  0x1DB1, 0xAA83, 0x4C35, 0x9B12, 0x1507, 0x6959, 0x335A, 0xB66F	| 40854680
    .short  0xC3D5, 0x1F7D, 0x56ED, 0xF274, 0xF294, 0x5D49, 0x1602, 0x77B2	| 40854690
    .short  0xDBE8, 0x3E92, 0xEF61, 0xE0D5, 0xDDA0, 0x14EE, 0xC07F, 0xBB0C	| 408546A0
    .short  0x3B3E, 0xBF9A, 0x46B8, 0xEE51, 0x3ACF, 0xC577, 0xF6BC, 0xD162	| 408546B0
    .short  0xDFD9, 0x0795, 0xB718, 0xEC1A, 0x3895, 0x68A8, 0x1EB7, 0x7C3F	| 408546C0
    .short  0x3C47, 0x9D1F, 0xEC76, 0xC3B6, 0x1132, 0xA733, 0xBDA9, 0x983A	| 408546D0
    .short  0xD434, 0x93D7, 0x99BB, 0x9ED2, 0x6670, 0x00FA, 0xDC1C, 0x56BE	| 408546E0
    .short  0x4843, 0x094C, 0xA491, 0x6FF2, 0xB9C4, 0xA293, 0xC933, 0x2D42	| 408546F0
    .short  0x28EB, 0x1EF4, 0xBB77, 0x069B, 0xB65C, 0xA9A0, 0x2CDA, 0x8F16	| 40854700
    .short  0x91D4, 0xB44F, 0x0E5E, 0x8CE7, 0xA52B, 0x9F61, 0xE45F, 0x492D	| 40854710
    .short  0xEE16, 0xD9D9, 0x27C5, 0xDA71, 0x1A09, 0x47A9, 0x2AC0, 0xA522	| 40854720
    .short  0x7215, 0x1B10, 0x011A, 0xFAEA, 0x5F7D, 0x5419, 0x5DE0, 0x90CE	| 40854730
    .short  0x638D, 0xC4F7, 0x98EA, 0x81D6, 0x2F38, 0x1D14, 0xD521, 0xAE23	| 40854740
    .short  0x1465, 0x38D3, 0xE126, 0x353E, 0xA748, 0xE1C8, 0x75D3, 0x7BBB	| 40854750
    .short  0xB4E7, 0x0FFB, 0xE50E, 0xEF28, 0x9ABA, 0xBA99, 0x7F7C, 0x50C2	| 40854760
    .short  0xD887, 0xC95B, 0x909A, 0x6CB9, 0xFCF0, 0xDDE9, 0xD158, 0x62ED	| 40854770
    .short  0x7156, 0x0455, 0x0467, 0xEA3D, 0x807B, 0xE56A, 0xE7AD, 0xFF57	| 40854780
    .short  0x1C54, 0xE4C1, 0xD2B3, 0x152F, 0xA2FF, 0x2101, 0xA3F3, 0x7A26	| 40854790
    .short  0xF9CC, 0xCFC9, 0x1280, 0x2C67, 0xCBCA, 0xFC24, 0x3224, 0xFE2A	| 408547A0
    .short  0x78D8, 0xB869, 0x37A8, 0x74A2, 0xF0A2, 0x9947, 0x0D8B, 0x18E2	| 408547B0
    .short  0xC8C6, 0xF760, 0x7E0B, 0xF6AD, 0xBC85, 0x58C5, 0x4E74, 0xCBF1	| 408547C0
    .short  0xC214, 0x0E8F, 0xB14A, 0xC0B8, 0x4500, 0xC8A7, 0x5462, 0x645F	| 408547D0
    .short  0xCF5D, 0x4AB4, 0x8466, 0xD6A3, 0xE3FE, 0x95F5, 0x7A20, 0x4C4D	| 408547E0
    .short  0xB0A1, 0x430D, 0xC782, 0x85A4, 0x44BD, 0x885E, 0x7DE9, 0xAC3C	| 408547F0
    .short  0xAFEC, 0x634B, 0x0A39, 0xC1EC, 0x3903, 0xD58A, 0xE2AB, 0x4FF6	| 40854800
    .short  0x5B71, 0xB381, 0x952F, 0x1753, 0x47F6, 0xE752, 0x3F97, 0xE9F9	| 40854810
    .short  0x7C89, 0xDF94, 0x13DD, 0x72B3, 0x692C, 0x9740, 0xCA84, 0x80D1	| 40854820
    .short  0x70F7, 0x0B4E, 0x3012, 0xA056, 0xB39C, 0xCC15, 0x1BE1, 0x37E6	| 40854830
    .short  0xCC60, 0xE29D, 0x6F52, 0x0DBC, 0x8D3C, 0x3C1B, 0x188E, 0x39CA	| 40854840
    .short  0x23AE, 0xD705, 0xB831, 0x89DC, 0xEA36, 0xA8F3, 0x7763, 0x4D4A	| 40854850
    .short  0x51EF, 0x5E02, 0xFDF2, 0x5F09, 0xFAFD, 0x36AA, 0x356C, 0x719E	| 40854860
    .short  0xE617, 0x5AE1, 0x9F1E, 0x3DDF, 0x4973, 0x4EB0, 0xAC83, 0x7F35	| 40854870
    .short  0x97F4, 0x318E, 0xA153, 0x32D0, 0xF8A5, 0x1646, 0x9319, 0xFDAB	| 40854880
    .short  0x74CD, 0x1CFE, 0x8340, 0x2689, 0x1F59, 0x517A, 0x87EE, 0x6687	| 40854890
    .short  0x40DE, 0x44FD, 0xAE4C, 0x55FF, 0xC61B, 0x70F8, 0x8E90, 0xA103	| 408548A0
    .short  0xED29, 0xB18B, 0x9DE6, 0xB9AF, 0x26C8, 0x1284, 0x59F1, 0xCD29	| 408548B0
    .short  0xBF27, 0x4138, 0x039B, 0xF5AC, 0xAB05, 0x4044, 0x43CB, 0xF882	| 408548C0
    .short  0xA010, 0x7572, 0x736A, 0x4650, 0x8811, 0xD270, 0x214D, 0x61E4	| 408548D0
    .short  0x0B55, 0x2390, 0x5ED6, 0x6021, 0x0C22, 0x290A, 0x8568, 0xD8C7	| 408548E0
    .short  0x5CC9, 0xB591, 0x346D, 0x591E, 0xB5E5, 0x1025, 0x2DAF, 0x96EB	| 408548F0
    .short  0x65DC, 0xA61C, 0x3699, 0x8318, 0x6728, 0x1141, 0x7664, 0xDEDA	| 40854900
    .short  0xD7AC, 0x337B, 0x9CB0, 0x87BA, 0x2B8F, 0x735A, 0xF375, 0xC66B	| 40854910
    .short  0xE857, 0xE3DD, 0x296B, 0x3445, 0xC14B, 0xC70E, 0x3D7E, 0x24FC	| 40854920
    .short  0xE03B, 0x86E8, 0xEB08, 0x25CF, 0xFB93, 0xCED4, 0x8A9F, 0xD36D	| 40854930
    .short  0xF5B4, 0x3AD8, 0x10C1, 0x570F, 0x82D0, 0x8EE3, 0xD9C7, 0xBD6C	| 40854940
    .short  0xCD8C, 0x2B20, 0xDE98, 0xE813, 0x4AE3, 0x2880, 0x42B2, 0x2AB7	| 40854950
    .short  0xC530, 0x1A54, 0x9237, 0xF343, 0x8106, 0x0130, 0xBE6E, 0xF900	| 40854960
    .short  0x4F5B, 0x5BBD, 0xF7D7, 0x0358, 0x8B0D, 0xF12C, 0x05B5, 0x8DCD	| 40854970
    .short  0xA842, 0x5336, 0x0913, 0x9A64, 0xF178, 0x2706, 0x6C51, 0x0504	| 40854980
    .short  0x57B6, 0x9CE0, 0xE91F, 0x5C75, 0x9686, 0x659C, 0xCE0F, 0x827C	| 40854990
    .short  0x240A, 0x3BC4, 0x253A, 0xED8D, 0xF4D1, 0x7D79, 0x22A4, 0x849F	| 408549A0
    .short  0x6BF5, 0x3A13, 0xDB47, 0x0FA7, 0x3FED, 0xF597, 0x74B2, 0xA82D	| 408549B0
    .short  0x2E39, 0x1B01, 0xC668, 0xBA41, 0xE59E, 0x696D, 0x3AEE, 0x973F	| 408549C0
    .short  0x5F48, 0xE1E9, 0xE028, 0x9023, 0x7B57, 0x6467, 0xE6C7, 0xE080	| 408549D0
    .short  0xFBA8, 0x3C77, 0x1A13, 0xBF9D, 0xF688, 0x2C3E, 0xB876, 0xE4EA	| 408549E0
    .short  0xC142, 0xD824, 0x0C0F, 0x31CE, 0xFD5C, 0x8BF3, 0x76DA, 0xCDEC	| 408549F0
    .short  0x51AB, 0x4D49, 0x19C6, 0xC35F, 0x2904, 0xEDBF, 0xEB08, 0xDD7C	| 40854A00
    .short  0x0A6F, 0x74D3, 0x3B98, 0xD7D5, 0xB0C0, 0xE300, 0x84FD, 0xB861	| 40854A10
    .short  0xA6D5, 0x3BCC, 0x8C91, 0xBBB7, 0x17A6, 0x575C, 0x5D74, 0xF1DD	| 40854A20
    .short  0xF1A4, 0x4B3D, 0x5C64, 0x1508, 0xDDBB, 0x76ED, 0x5317, 0x52E0	| 40854A30
    .short  0xC463, 0x1014, 0x4197, 0xEB5B, 0xA202, 0x4160, 0xB1F0, 0xBC94	| 40854A40
    .short  0x6A7C, 0xAC4B, 0x70D8, 0x4AB4, 0xA424, 0x9B6A, 0xC0AC, 0x35DC	| 40854A50
    .short  0xD9A5, 0xAA30, 0x2BC9, 0xD6EB, 0xFEEB, 0x065E, 0xEAB7, 0x55B9	| 40854A60
    .short  0x9035, 0x683A, 0x010E, 0x421F, 0x10D0, 0x21C6, 0xA980, 0xC863	| 40854A70
    .short  0x78C1, 0x7DEE, 0xB734, 0xB1C8, 0x301F, 0xC52F, 0x2D2C, 0x862B	| 40854A80
    .short  0xFF7D, 0xA962, 0x9441, 0xA3D9, 0x7F59, 0x1718, 0xBD01, 0xC683	| 40854A90
    .short  0x5582, 0xB0FE, 0x00FF, 0x190C, 0x9F73, 0x5BD7, 0x56EC, 0x8847	| 40854AA0
    .short  0xF2D4, 0x11C4, 0xDF51, 0xB288, 0x068C, 0xAE2E, 0x28B3, 0x56B6	| 40854AB0
    .short  0x3610, 0x5A12, 0x3EBA, 0x6E0F, 0x8906, 0x03BC, 0x6649, 0x2809	| 40854AC0
    .short  0x3C14, 0x7E48, 0x8685, 0x4338, 0xE49F, 0xFBE7, 0x1358, 0xD571	| 40854AD0
    .short  0xE30C, 0x0816, 0x12F1, 0x820A, 0xC972, 0x9999, 0x228F, 0xA633	| 40854AE0
    .short  0xDE9A, 0xC7D2, 0x464C, 0x8452, 0x73BF, 0x7B36, 0x16DB, 0x1FAF	| 40854AF0
    .short  0x02AA, 0xB99C, 0xA0B4, 0xD1D4, 0xF7D9, 0xE7A3, 0xD060, 0x651B	| 40854B00
    .short  0x50F2, 0x7272, 0xAA69, 0xB3DA, 0x9753, 0xEFE4, 0x0D1E, 0x9443	| 40854B10
    .short  0x779D, 0x33FA, 0x8F1A, 0x47BA, 0x8EDD, 0xF789, 0x9965, 0x3F55	| 40854B20
    .short  0x57C2, 0xC99E, 0x3526, 0x44AA, 0xD554, 0x1E10, 0xF3D6, 0xEE9A	| 40854B30
    .short  0x0BB6, 0x8D79, 0x9DD2, 0xB5AC, 0xCF7E, 0x9F21, 0x5E05, 0xD054	| 40854B40
    .short  0x2A5F, 0xF37D, 0xD6FE, 0x6691, 0x6C36, 0x045D, 0x1E4A, 0x9C1E	| 40854B50
    .short  0xEF1B, 0x3757, 0x7120, 0x803C, 0xCB19, 0x96CD, 0x593A, 0xF968	| 40854B60
    .short  0xA7CE, 0x22CB, 0x60EA, 0xEC7B, 0x6803, 0x26A4, 0x1855, 0xD2A5	| 40854B70
    .short  0xCA15, 0xF404, 0x2FA2, 0x1806, 0xCD87, 0x9EAB, 0xBEB1, 0x5840	| 40854B80
    .short  0x95FC, 0x2AB8, 0x4071, 0x38EF, 0xF83F, 0x61A1, 0xC812, 0x142A	| 40854B90
    .short  0x61C5, 0xFFA8, 0x0F8A, 0x4511, 0x8A9C, 0x2965, 0x7262, 0xFDE6	| 40854BA0
    .short  0x2786, 0x50F8, 0xA50A, 0xD94F, 0x7CA1, 0xCA02, 0xE8C4, 0xF06F	| 40854BB0
    .short  0xE9F5, 0x5FE8, 0x1C0B, 0x858A, 0x5277, 0xB4E3, 0x4DA7, 0xE9CF	| 40854BC0
    .short  0xE7CA, 0x8AFC, 0xCCFA, 0x8FE1, 0x7E50, 0xA7BD, 0xB97A, 0x530B	| 40854BD0
    .short  0xC7DE, 0x818C, 0x67E2, 0xA2D8, 0x442D, 0x3646, 0x1D93, 0x91F6	| 40854BE0
    .short  0x982A, 0x0193, 0x3D2B, 0x2D51, 0xBF38, 0xEA87, 0xB678, 0x398B	| 40854BF0
    .short  0x7909, 0x5C2C, 0x0366, 0xCBAE, 0x31FB, 0x6A19, 0x343D, 0xFC1A	| 40854C00
    .short  0x42DF, 0x7856, 0xAF37, 0x7FFF, 0xACCC, 0x6350, 0x26D1, 0x5D84	| 40854C10
    .short  0xFA46, 0xE259, 0x0ECD, 0x62F2, 0xF423, 0xB6BB, 0xBC32, 0x9D8F	| 40854C20
    .short  0x4C96, 0xC464, 0x374E, 0x4E69, 0x838D, 0x5E9B, 0xBB94, 0x02C1	| 40854C30
    .short  0x435A, 0xBEE5, 0x2190, 0xB7DE, 0x246C, 0x40FB, 0x6D99, 0x6FAD	| 40854C40
    .short  0xD84B, 0x3495, 0xE143, 0x6CB3, 0x1B07, 0xCE25, 0x5B5E, 0x798E	| 40854C50
    .short  0x49C3, 0x321D, 0x8B8E, 0x3D53, 0xC3E7, 0xD303, 0xD3E4, 0xDC0D	| 40854C60
    .short  0x936A, 0x30F5, 0x6FDC, 0xC0A2, 0x4ED7, 0x4998, 0x09B9, 0x2774	| 40854C70
    .short  0xB4B5, 0xA1E2, 0x9EE6, 0xA007, 0xDCE0, 0x0E31, 0x4AAD, 0x1D82	| 40854C80
    .short  0xE21C, 0x984E, 0x9B2F, 0xE87A, 0xAD25, 0x6D17, 0xEC2E, 0xAFF1	| 40854C90
    .short  0x116D, 0xC258, 0xCEA3, 0x2B45, 0xA161, 0x87FD, 0x45F9, 0xC190	| 40854CA0
    .short  0x6944, 0x2EB1, 0xD275, 0x4CA0, 0xA392, 0x1CC2, 0xFC29, 0x6B8D	| 40854CB0
    .short  0x1F6E, 0x4F4D, 0x7AC8, 0xDF5A, 0xF9E1, 0x0939, 0x96F8, 0xDA9F	| 40854CC0
    .short  0x87B0, 0xE6BE, 0x80E9, 0x7378, 0x3340, 0x1626, 0x65EF, 0x5428	| 40854CD0
    .short  0xF545, 0x71CA, 0xB55D, 0xAD6B, 0x4B52, 0xF632, 0xB3E5, 0xD43B	| 40854CE0
    .short  0xED3C, 0x92F9, 0xC2AE, 0xA57F, 0x6B1D, 0x0A05, 0x6E84, 0x20F7	| 40854CF0
    .short  0x634D, 0x7CC7, 0xB230, 0x0535, 0x9A33, 0x8976, 0x1522, 0x12D1	| 40854D00
    .short  0x644F, 0xCC27, 0xA883, 0x48B0, 0x8D18, 0x131C, 0xD431, 0x1A4C	| 40854D10
    .short  0xD789, 0x0D70, 0x5ABC, 0x25B2, 0x3879, 0xE5F4, 0x7D56, 0x246C	| 40854D20
    .short  0xBA27, 0x6781, 0x82F7, 0x4644, 0xAB3B, 0x7A15, 0x7595, 0x0729	| 40854D30
    .short  0x540D, 0x23A9, 0x85D3, 0x5166, 0xC55B, 0x0085, 0x4F6B, 0x0B86	| 40854D40
    .short  0xDABD, 0x75F0, 0x0711, 0xF2DF, 0xD1B8, 0xBDC5, 0xEEF4, 0x8EB5	| 40854D50
    .short  0x929B, 0x0C96, 0x08AF, 0xDE75, 0x25CB, 0xFE37, 0x47E8, 0xABDB	| 40854D60
    .short  0x587F, 0x9AD0, 0x48F3, 0xF842, 0x043E, 0x8C73, 0x2070, 0x2F22	| 40854D70
    .short  0x91A9, 0xCFD6, 0x0516, 0xFA34, 0x818B, 0x7720, 0x14A0, 0x3E6E	| 40854D80
    .short  0x3200, 0x83A6, 0x62E3, 0x707E, 0x9C81, 0x600E, 0x2C7B, 0xA44A	| 40854D90
    .short  0x88BE, 0x59C3, 0xF0F6, 0x95C9, 0x2321, 0x9392, 0x39CF, 0xDBC0	| 40854DA0
    .short  0xAE67, 0x7F19, 0xB458, 0xE0C3, 0xEBFB, 0x6D37, 0x05F2, 0x2F95	| 40854DB0
    .short  0xD838, 0x5E6E, 0x1A99, 0xA155, 0x5BA3, 0x35ED, 0x5DB1, 0xE8B8	| 40854DC0
    .short  0x90EC, 0x3E2E, 0x0767, 0x1606, 0x476F, 0x848F, 0xE1AA, 0x8D0E	| 40854DD0
    .short  0xA0C7, 0xF829, 0x8704, 0xFAE6, 0xBCBD, 0x97E1, 0x59D8, 0x82EF	| 40854DE0
    .short  0xB64C, 0xB0D0, 0x76AF, 0x2072, 0x4D94, 0x6B27, 0x2980, 0x6F16	| 40854DF0
    .short  0x8F44, 0x24D6, 0x3BD5, 0x6A3C, 0xA1A4, 0x3F4C, 0x8917, 0xB2A1	| 40854E00
    .short  0x3556, 0xEF26, 0xCAC8, 0xEC02, 0x845F, 0xE6FE, 0xE650, 0x4E77	| 40854E10
    .short  0x387C, 0x142F, 0x85FC, 0xB16F, 0x3DC4, 0x54FC, 0xC6D6, 0x78B0	| 40854E20
    .short  0xA702, 0x4548, 0xD6F5, 0x0A69, 0x4BAD, 0x2BA2, 0x1BE4, 0x680A	| 40854E30
    .short  0xE09B, 0x1E3A, 0xB1F8, 0x6E36, 0x6CE6, 0x9F8D, 0x324F, 0x9B5E	| 40854E40
    .short  0x8C89, 0x395C, 0x06F0, 0xBB53, 0xDA09, 0xE763, 0xD196, 0xDA6A	| 40854E50
    .short  0x0AF1, 0x0870, 0xE477, 0xCB40, 0x5E22, 0xEB44, 0xB890, 0xD13E	| 40854E60
    .short  0x7442, 0x0365, 0x6BD0, 0xC23B, 0x1E23, 0xD9DD, 0x8BDB, 0x4375	| 40854E70
    .short  0x0EB7, 0x0B73, 0x40EE, 0xACA4, 0x4A07, 0x1DE2, 0xA6CA, 0x2AEC	| 40854E80
    .short  0x4E0E, 0xA52B, 0x4927, 0x615A, 0x7A72, 0xCD62, 0x01CF, 0xCEFF	| 40854E90
    .short  0xB3A8, 0x8EC7, 0xE735, 0x918E, 0x4254, 0xEE9F, 0x128C, 0x8820	| 40854EA0
    .short  0x08EA, 0xE21F, 0xF474, 0x0DE5, 0xBEF6, 0x8FC4, 0xABD7, 0xA7DB	| 40854EB0
    .short  0x5830, 0x87C6, 0x0D18, 0x7E9B, 0x0B4A, 0xB3AF, 0x3775, 0x8BD3	| 40854EC0
    .short  0x730F, 0xD6B3, 0x7088, 0x9A7B, 0x9655, 0xF2A8, 0x30C1, 0x8696	| 40854ED0
    .short  0x4161, 0xD7AD, 0xFD3C, 0x2335, 0x5C73, 0x94C1, 0xC25B, 0x1ABA	| 40854EE0
    .short  0x5ADA, 0xD0F1, 0x7D06, 0x9CF8, 0x8081, 0x2E07, 0x7586, 0xA91B	| 40854EF0
    .short  0x036C, 0x119E, 0x7119, 0x80B9, 0x0945, 0xC3D2, 0xB09D, 0xB5A0	| 40854F00
    .short  0xDD66, 0xE1C9, 0xFC1B, 0x3094, 0xA484, 0x2688, 0xEA8E, 0x92A7	| 40854F10
    .short  0x63C0, 0xA62C, 0xF637, 0x2D56, 0x97EB, 0x5C66, 0x025E, 0x17F4	| 40854F20
    .short  0x672C, 0x25BB, 0xED11, 0x3691, 0x52E8, 0xCC4E, 0x3FD4, 0xDDDE	| 40854F30
    .short  0xD33D, 0xB4C0, 0xC34E, 0x4490, 0x6D93, 0x50CF, 0x2DD2, 0x311C	| 40854F40
    .short  0x7EA6, 0x6728, 0xEE1E, 0x60E9, 0x57CC, 0x37B4, 0xA346, 0xED09	| 40854F50
    .short  0xD53F, 0x4014, 0xB9AC, 0xAE41, 0xD047, 0x6311, 0x2CBC, 0xF146	| 40854F60
    .short  0xB700, 0x66F2, 0x9B2B, 0x6C85, 0xAE6E, 0xAB04, 0x78ED, 0x526B	| 40854F70
    .short  0x3EA0, 0x7B7C, 0xC0FE, 0x004F, 0xB260, 0xFECE, 0xBD34, 0xF959	| 40854F80
    .short  0xFBB8, 0xB947, 0x101F, 0x8CC2, 0x39BA, 0xBA74, 0x158F, 0xF31E	| 40854F90
    .short  0x6936, 0xDCF5, 0x3152, 0xE9DA, 0xC810, 0xF023, 0xD4CB, 0x3D30	| 40854FA0
    .short  0xDBCD, 0x997E, 0x4FFA, 0xB8C5, 0xF382, 0xBF08, 0xE9EF, 0xE40B	| 40854FB0
    .short  0x942F, 0x74BC, 0xDC97, 0xFF99, 0x79CE, 0x3CEB, 0xF179, 0x29A5	| 40854FC0
    .short  0x6068, 0xA2E4, 0x6812, 0x2C5B, 0x2EBE, 0xFC86, 0x7239, 0x1952	| 40854FD0
    .short  0xAD71, 0x90B7, 0x1C6D, 0xC6CD, 0xAC03, 0xC539, 0xBFA2, 0xF660	| 40854FE0
    .short  0x20A5, 0xC84A, 0x647B, 0x69DC, 0x1691, 0x5951, 0x191D, 0xD438	| 40854FF0
    .short  0x6670, 0x8576, 0xAF41, 0xE34D, 0x88A9, 0x72E7, 0xA87E, 0xD331	| 40855000
    .short  0x92C6, 0x286C, 0x560D, 0x5D81, 0x1F51, 0x0542, 0xFE85, 0xC0B6	| 40855010
    .short  0x2321, 0x38A3, 0x817F, 0x5B0F, 0x279C, 0x898C, 0x62B4, 0xA317	| 40855020
    .short  0x6F2E, 0x34AA, 0x9595, 0xE51D, 0xD29A, 0x21D5, 0xB5F4, 0xF5F3	| 40855030
    .short  0x24F7, 0x4880, 0xC4B2, 0x9D57, 0xA54B, 0xB600, 0xD7D3, 0xDFF6	| 40855040
    .short  0xE29E, 0x1F93, 0x36F3, 0xAD7A, 0xD9B0, 0x753F, 0x340B, 0xA07F	| 40855050
    .short  0x3CE9, 0x554B, 0x8313, 0xC7B1, 0x2A3E, 0x81F7, 0xE332, 0x0F12	| 40855060
    .short  0x4429, 0x7D25, 0x0CB3, 0x9667, 0x0F8A, 0x7661, 0x33A1, 0x8AAB	| 40855070
    .short  0x9D8B, 0xCA8A, 0xF06B, 0xDB13, 0xCCFF, 0xAF97, 0xE8DE, 0x4110	| 40855080
    .short  0x1DF9, 0x4B01, 0x9125, 0x71DF, 0xF81A, 0x182D, 0xDE87, 0x4245	| 40855090
    .short  0xF7DF, 0xDEEE, 0x7F31, 0x4FBD, 0xFA16, 0x019A, 0x5020, 0x9354	| 408550A0
    .short  0x464D, 0x1518, 0x54E3, 0xFB64, 0x9A62, 0x1CB2, 0x2805, 0xBE84	| 408550B0
    .short  0x8A83, 0x3B49, 0xCD76, 0x770D, 0xAA92, 0x732A, 0xBB24, 0xFDD1	| 408550C0
    .short  0x9E98, 0xD2E8, 0x0043, 0x4789, 0xA92D, 0x5858, 0x7BC9, 0x490C	| 408550D0
    .short  0x3A78, 0x7C9D, 0x453A, 0x7998, 0xBA57, 0xA4B5, 0x6A7D, 0x95E3	| 408550E0
    .short  0x9FB9, 0x27AE, 0xC7D9, 0x9887, 0x4CDC, 0x53AC, 0x7C59, 0x6405	| 408550F0
    .short  0x438D, 0xC424, 0x2149, 0x126D, 0x2226, 0x1B71, 0xCBC2, 0x338B	| 40855100
    .short  0x86B6, 0xC992, 0xF9FD, 0x4CFB, 0xF564, 0xBC9C, 0x8D5A, 0x627D	| 40855110
    .short  0x5FBB, 0xD53D, 0x2B14, 0x5F68, 0x98B5, 0x2221, 0x250A, 0xF4D9	| 40855120
    .short  0x65E1, 0x3AE0, 0x48E0, 0xC1BF, 0x6E9F, 0x02A9, 0x9C2A, 0x4DF9	| 40855130
    .short  0x827A, 0x0CF0, 0x14E7, 0x13D7, 0x180C, 0x5732, 0x2F63, 0x4650	| 40855140
    .short  0xFFAB, 0x0EFD, 0xC5E2, 0x061A, 0x13D1, 0x07FA, 0x55DD, 0xF7CC	| 40855150
    .short  0xC1AE, 0x7A03, 0xEC48, 0x7078, 0x1128, 0xCFCA, 0x9340, 0xBD34	| 40855160
    .short  0x5153, 0x9E83, 0x8EBF, 0x6522, 0x613B, 0x565F, 0x5333, 0x1015	| 40855170
    .short  0xCEC5, 0x4A79, 0xEFC3, 0x5AA6, 0xA25D, 0x0982, 0x2615, 0xD8D8	| 40855180
    .short  0x7765, 0xB75D, 0x9908, 0xA8EA, 0xDF5C, 0x5133, 0x1769, 0xEACB	| 40855190
    .short  0xCFA7, 0x04BE, 0xF26A, 0x32C8, 0x0401, 0xAAD4, 0xC9E5, 0x8343	| 408551A0
    .short  0xE51C, 0xB98F, 0xD895, 0xBD66, 0x8A92, 0xB89A, 0xBB2E, 0xFA0A	| 408551B0
    .short  0x5642, 0xDE5B, 0x9B33, 0x1E37, 0x6359, 0xF33A, 0xFD57, 0xA71E	| 408551C0
    .short  0xB7F9, 0x91AA, 0x4213, 0xE7CE, 0x2415, 0xD0A3, 0x670D, 0xCB80	| 408551D0
    .short  0xA1AE, 0xC43C, 0x6E9A, 0x3452, 0x7F29, 0x9A9F, 0xDA8A, 0x1B88	| 408551E0
    .short  0xA685, 0x0CF9, 0xE49D, 0xE26D, 0x6AA6, 0x1F4E, 0x4CEB, 0xA090	| 408551F0
    .short  0x3CC1, 0x7CCC, 0x43E7, 0x4620, 0x0708, 0x7608, 0x2BB6, 0xDAF5	| 40855200
    .short  0x1132, 0x7E26, 0xB08E, 0x21B5, 0xEE04, 0x3967, 0xD13E, 0x9DD8	| 40855210
    .short  0x46DC, 0x3717, 0xACD9, 0x8A93, 0x7A2C, 0x841F, 0x9452, 0x4B35	| 40855220
    .short  0x146D, 0x5EF1, 0xEB70, 0x3B6B, 0x8490, 0x78A1, 0xBDBC, 0x1DAE	| 40855230
    .short  0x9AB8, 0x075E, 0xA424, 0x2A42, 0x3DFC, 0x7003, 0xB181, 0x9694	| 40855240
    .short  0xD7B1, 0x949B, 0xF531, 0xE64D, 0x2745, 0xB591, 0xC6C2, 0x0989	| 40855250
    .short  0xC23B, 0x25AD, 0xB2DE, 0xFD1C, 0xA88B, 0xCF50, 0x374D, 0xD816	| 40855260
    .short  0x6830, 0x5284, 0x1F00, 0x3EB1, 0x99DA, 0xFC8C, 0x1E26, 0xAD7A	| 40855270
    .short  0xAFBA, 0xF938, 0xCCA7, 0x2912, 0xD5C0, 0x1125, 0x3A79, 0x28F3	| 40855280
    .short  0x93ED, 0x267B, 0x10F8, 0xF406, 0x012A, 0xEA0F, 0x60F5, 0x43A8	| 40855290
    .short  0x3F20, 0x0232, 0x821D, 0x83EA, 0x9893, 0x352A, 0x890C, 0xE8DA	| 408552A0
    .short  0x5734, 0x7A29, 0x5DE6, 0x44EE, 0x6C0F, 0x7D63, 0xF1F1, 0x5A4C	| 408552B0
    .short  0x3E62, 0xCE92, 0x5036, 0x81F7, 0xCF09, 0x54DE, 0x17D4, 0x4DFD	| 408552C0
    .short  0x0D63, 0x03FB, 0x2022, 0x73C1, 0x9676, 0x8E41, 0x4782, 0x3D5A	| 408552D0
    .short  0x8C53, 0xE3CD, 0x09A1, 0x042E, 0x2EFD, 0x1957, 0x0EB0, 0xC3E4	| 408552E0
    .short  0xFBEE, 0xAB14, 0x8384, 0xB2BC, 0x1205, 0x4E5C, 0x778F, 0x5B97	| 408552F0
    .short  0xDFF2, 0xE477, 0x9DFB, 0xFB59, 0xA255, 0x0F76, 0x9E69, 0x4162	| 40855300
    .short  0x4950, 0xF810, 0xE1D3, 0x8515, 0x19D7, 0x2F54, 0xB97E, 0x93E7	| 40855310
    .short  0x855E, 0x599D, 0xAD4C, 0x2D58, 0xF07F, 0xD1CA, 0x26A0, 0x0D2B	| 40855320
    .short  0xC9EF, 0x458E, 0x36A5, 0x6840, 0x9CB3, 0x6F7E, 0xE7A2, 0xF6CF	| 40855330
    .short  0xB3A8, 0x0EDF, 0xF3A4, 0x2CC3, 0x72CE, 0x9F69, 0xDB49, 0x63A0	| 40855340
    .short  0xE87D, 0x7B5D, 0xB888, 0xC547, 0x7171, 0x3605, 0x5F60, 0xA6E5	| 40855350
    .short  0x1516, 0x3171, 0xFF98, 0x12F4, 0x4DC8, 0xCAD7, 0x751F, 0xDFAC	| 40855360
    .short  0xB6CD, 0x7F31, 0x0AB7, 0xD56C, 0x38E3, 0x66D0, 0x41C5, 0x6A18	| 40855370
    .short  0x0BF0, 0x0833, 0xFAEA, 0x47EF, 0x1A6F, 0x1600, 0x2174, 0xA8E1	| 40855380
    .short  0x5C77, 0xF52F, 0x30CA, 0xD621, 0xE99F, 0xE13F, 0x51B9, 0x8BF6	| 40855390
    .short  0x7DF7, 0x487D, 0x9510, 0x4298, 0xECBD, 0x01DD, 0xA7FF, 0xBA3E	| 408553A0
    .short  0x083C, 0xDD3D, 0x32D8, 0xE5B6, 0xD61A, 0x1CDC, 0xD2E4, 0x50D2	| 408553B0
    .short  0xD975, 0x53FF, 0xAAF6, 0xAF68, 0x7BB4, 0x6595, 0x293A, 0x5160	| 408553C0
    .short  0xC7DD, 0x5DF2, 0x86AB, 0xD2A2, 0x97C9, 0x13D5, 0xBAE1, 0x156F	| 408553D0
    .short  0x7007, 0x0A1B, 0x28BB, 0x88B0, 0x4F9C, 0xDC27, 0x4AE9, 0x2349	| 408553E0
    .short  0x64E8, 0x40A9, 0x2D17, 0x6C9C, 0xB561, 0x5CE6, 0x8106, 0x0BFE	| 408553F0
    .short  0x4037, 0xBFB7, 0x8B4B, 0x67CB, 0xDE41, 0xB001, 0x2519, 0xC178	| 40855400
    .short  0x04D1, 0xEB45, 0x1C97, 0x69B2, 0xFC28, 0x33E8, 0x556A, 0xCD09	| 40855410
    .short  0x9265, 0x9579, 0xC49B, 0xE9C4, 0x8ECB, 0xBB4A, 0x9F8D, 0xB16E	| 40855420
    .short  0xEA73, 0xD773, 0xF958, 0x6011, 0xD33F, 0x9E87, 0xA354, 0x182C	| 40855430
    .short  0xB486, 0x9822, 0x5296, 0xA46A, 0xE5FA, 0x3C61, 0x8D5F, 0xBC81	| 40855440
    .short  0x5340, 0x3AD4, 0xBF66, 0xEC70, 0x7EE0, 0x6234, 0x7C1B, 0x5664	| 40855450
    .short  0x06C7, 0xC0AB, 0x5A51, 0x1A1A, 0xDC18, 0xAEC9, 0x45A9, 0x10D1	| 40855460
    .short  0x915B, 0x6D23, 0xCB0E, 0xA5FC, 0xCEB5, 0xFFBE, 0x4899, 0xFEBB	| 40855470
    .short  0xDD1C, 0xB60E, 0x61EC, 0x279E, 0x447B, 0x570B, 0xA0BF, 0x7707	| 40855480
    .short  0x8778, 0x6BC0, 0x1638, 0x4C4B, 0x1802, 0xF0A4, 0x8087, 0x8C3B	| 40855490
    .short  0xE60A, 0xD3E2, 0x5467, 0x5574, 0x1D0B, 0x714F, 0xC59E, 0x4A0C	| 408554A0
    .short  0xE2AF, 0x9B8D, 0x35DF, 0x49D3, 0x3143, 0x38BD, 0x7603, 0x6EED	| 408554B0
    .short  0xF794, 0x2448, 0x5823, 0x89D9, 0x884F, 0x20F0, 0x628C, 0x82F8	| 408554C0
    .short  0xABAA, 0xDB28, 0xD056, 0xEF19, 0x1BE2, 0xEDC8, 0x2F4E, 0xF2EB	| 408554D0
    .short  0x2AD5, 0x9CD6, 0x0C39, 0xAA55, 0x595C, 0xBE86, 0xBE12, 0xA9BF	| 408554E0
    .short  0xF272, 0xE0A5, 0xFE5A, 0x5F82, 0x4B46, 0xC256, 0xC114, 0xF753	| 408554F0
    .short  0x786C, 0x3013, 0xD4FE, 0x79A7, 0x652B, 0x327F, 0xF64A, 0xC7C5	| 40855500
    .short  0xE07A, 0x99C6, 0x4E68, 0x2265, 0xA92D, 0x2E7C, 0x6BC3, 0x61E9	| 40855510
    .short  0x0247, 0x97E0, 0x8FCC, 0x80C7, 0x74D6, 0xB436, 0xA5F3, 0x8FC2	| 40855520
    .short  0x39A3, 0xAC46, 0xF825, 0x06DB, 0x79C4, 0x7583, 0x05D0, 0xF1A6	| 40855530
    .short  0xE37C, 0xB799, 0xBCB2, 0xD430, 0x5E6E, 0x90B8, 0x3B11, 0xC602	| 40855540
    .short  0x66DB, 0x92AF, 0xCA91, 0x648A, 0xC06B, 0xCC51, 0x6948, 0xA143	| 40855550
    .short  0x23F4, 0x5844, 0x7321, 0x3F0D, 0x5B64, 0x7204, 0xCD83, 0xD972	| 40855560
    .short  0x1389, 0xC9B4, 0x2CCF, 0xA375, 0xEF80, 0xA2EC, 0x6D35, 0x17BA	| 40855570
    .short  0xC32F, 0x87E3, 0x03E5, 0x1485, 0x34BE, 0x00B9, 0xAE27, 0x4F1D	| 40855580
    .short  0x903D, 0xEE39, 0xF45D, 0x052D, 0xEDD2, 0x745F, 0x6F44, 0x86FA	| 40855590
    .short  0xC801, 0x8DB3, 0x22AC, 0xB324, 0x0FC6, 0x2B96, 0x33AD, 0xC88B	| 408555A0
    .short  0x001E, 0xD93B, 0x928F, 0x15FC, 0xCA5F, 0x1FEE, 0xC53E, 0x780A	| 408555B0
    .short  0x03EB, 0xC2EA, 0x8AD0, 0x5465, 0xEE0D, 0x483F, 0xEDAA, 0x9DAF	| 408555C0
    .short  0x59F1, 0xB877, 0xB015, 0x595C, 0x8F9B, 0x7CB6, 0x71DB, 0xEB80	| 408555D0
    .short  0x0ECB, 0x0421, 0xC47A, 0x02B9, 0x7B8C, 0xBAB4, 0xD553, 0xADC7	| 408555E0
    .short  0x45BA, 0x7DDA, 0xF8B1, 0xD5CF, 0xB16C, 0x5338, 0xAF82, 0xD047	| 408555F0
    .short  0x8D81, 0x8D9B, 0x344D, 0x4407, 0x4BC5, 0x4CC5, 0x1188, 0x000F	| 40855600
    .short  0x6DA7, 0xBBE4, 0x4DD7, 0x9C4B, 0xD055, 0xB062, 0xB296, 0x5D41	| 40855610
    .short  0x6BAC, 0x9334, 0xEBBF, 0x8A9F, 0xA94F, 0xD625, 0x5C6A, 0x7BF5	| 40855620
    .short  0x88E4, 0xA64E, 0x533C, 0xB958, 0xFAF6, 0x56D5, 0x1E9D, 0x5275	| 40855630
    .short  0xE669, 0x87E6, 0xA8A2, 0x5CC0, 0x1061, 0xBFF2, 0x2B60, 0xC811	| 40855640
    .short  0xBAC4, 0xAC1A, 0x6832, 0xA1B3, 0xD459, 0xE9C2, 0x138E, 0x1B18	| 40855650
    .short  0xEC64, 0xC6FD, 0x1422, 0xDA98, 0x9842, 0xFD30, 0x3658, 0xF7DD	| 40855660
    .short  0x9FA0, 0xC393, 0x2695, 0x9F81, 0xABAE, 0x6039, 0x62C0, 0x6416	| 40855670
    .short  0x6949, 0xA037, 0x0B18, 0x4FF4, 0x38D2, 0x996D, 0x1F00, 0x3D64	| 40855680
    .short  0xDB4C, 0x1E67, 0x5AD6, 0xCFD0, 0x1D47, 0x901E, 0x3F57, 0xC9A5	| 40855690
    .short  0x41E9, 0x9208, 0x8213, 0x756F, 0xFF3A, 0x2151, 0x0AB8, 0x8357	| 408556A0
    .short  0xA4B9, 0x17F3, 0xDE8B, 0x3471, 0x2730, 0xDEBC, 0xE78A, 0xBE2D	| 408556B0
    .short  0x5E20, 0xCEF7, 0xC039, 0x97FB, 0xF79F, 0x0BF9, 0x6197, 0x8682	| 408556C0
    .short  0x4768, 0xAEF8, 0x350B, 0x2988, 0xE1EF, 0x43F0, 0x2D34, 0x4B3E	| 408556D0
    .short  0x8E78, 0xD74A, 0x676D, 0x7F76, 0xF0BE, 0x2FD3, 0x1CFD, 0x7073	| 408556E0
    .short  0xD97C, 0x011F, 0x000F, 0x6E9A, 0xB3C6, 0xB66B, 0x7A09, 0x4D1D	| 408556F0
    .short  0x17AF, 0x57BF, 0x312D, 0x72A2, 0x77FF, 0x4229, 0x568D, 0x5F50	| 40855700
    .short  0xEA26, 0x1CB0, 0xE854, 0xEA95, 0xE9BB, 0x2DEF, 0xE340, 0x207B	| 40855710
    .short  0xB41B, 0x25CA, 0xFC2E, 0x14C4, 0xB602, 0xF179, 0x06BD, 0x3B52	| 40855720
    .short  0xA135, 0x0A89, 0xA094, 0xECB7, 0x7523, 0xF6C8, 0xA648, 0x6F70	| 40855730
    .short  0x8BB4, 0x3CFE, 0x1AE1, 0x0536, 0x1680, 0x58D2, 0x3767, 0x396A	| 40855740
    .short  0x7373, 0x5045, 0x15CF, 0x802A, 0x40A4, 0x4540, 0x9CD8, 0x18E7	| 40855750
    .short  0x707D, 0x6BBB, 0xD2E0, 0xD290, 0x095E, 0xB3B2, 0x2117, 0x66CD	| 40855760
    .short  0x843F, 0x8904, 0x7FB0, 0xA98F, 0x3E71, 0xFAA1, 0xD1DE, 0x0D26	| 40855770
    .short  0xB96E, 0x5159, 0xCC04, 0xF0C3, 0xCEFA, 0x3F0E, 0x6F14, 0xFC94	| 40855780
    .short  0x04C1, 0xF203, 0x95E7, 0x11AB, 0x97ED, 0x76C1, 0xCD19, 0x2620	| 40855790
    .short  0x199E, 0x302B, 0x0711, 0x36FF, 0xFBCE, 0xCB7D, 0x3212, 0x8878	| 408557A0
    .short  0xA2AB, 0xAB24, 0x579C, 0x388D, 0x12DF, 0xDDD8, 0x9601, 0x63C6	| 408557B0
    .short  0xAC90, 0x22E1, 0xBE05, 0x3EAA, 0x054A, 0x9E54, 0x83A1, 0x1AD1	| 408557C0
    .short  0x0CD5, 0x6A19, 0x48B5, 0x4A9E, 0x6C52, 0xB1A9, 0xC843, 0x9431	| 408557D0
    .short  0x20AD, 0x19DB, 0xE5FB, 0xAAA7, 0x661D, 0xF406, 0x24B2, 0xF5AE	| 408557E0
    .short  0x9056, 0xCA1C, 0x65CA, 0x035B, 0x7D46, 0xA722, 0x39E8, 0x072E	| 408557F0
    .short  0x3C29, 0x4E84, 0x2F75, 0xBCAC, 0xA303, 0x162C, 0x9A4B, 0xBDF6	| 40855800
    .short  0x44F3, 0x6C35, 0xDC86, 0x2E92, 0xF536, 0xEF4F, 0x2537, 0x06E8	| 40855810
    .short  0x6EF9, 0x8F68, 0xA5E5, 0xD35A, 0x426B, 0x5BF1, 0x5B50, 0xE33D	| 40855820
    .short  0xBD31, 0xC71B, 0xAAB7, 0x77E5, 0xD76F, 0x98CB, 0x4A91, 0x27EC	| 40855830
    .short  0x28F0, 0x9A17, 0xD3A6, 0x68A3, 0x870E, 0x3515, 0xFD77, 0x914D	| 40855840
    .short  0x3AC3, 0x339D, 0xE425, 0x84FA, 0xBCEC, 0xF999, 0x5F10, 0x0EA8	| 40855850
    .short  0x3D27, 0xFBB1, 0x897E, 0xDB28, 0x552A, 0xC561, 0xC3E3, 0xE710	| 40855860
    .short  0xC993, 0x326E, 0xDF51, 0x1043, 0xD8D1, 0x239C, 0x0DA8, 0x2B55	| 40855870
    .short  0xBB08, 0x2C0C, 0xDD5C, 0x2891, 0x3B5D, 0x553C, 0x0F45, 0xC144	| 40855880
    .short  0x64CC, 0x40AD, 0x79A9, 0x4101, 0x937F, 0x3A97, 0x5D87, 0x0C63	| 40855890
    .short  0xC144, 0x82EB, 0xB5C9, 0x7387, 0x85F2, 0xD469, 0x5466, 0xC0A6	| 408558A0
    .short  0xC6A5, 0xB77A, 0x5838, 0x7AD9, 0x2ADA, 0xB413, 0x4641, 0x6985	| 408558B0
    .short  0x7862, 0xE88B, 0x8CF7, 0x71BD, 0x7C33, 0x5E0D, 0x9EBC, 0xED66	| 408558C0
    .short  0x8192, 0x318C, 0x02FE, 0xA8A4, 0x6306, 0xCD0B, 0x8070, 0x08B8	| 408558D0
    .short  0x4FF5, 0x4912, 0xEFEA, 0x0F32, 0x4C21, 0x5A23, 0x5299, 0xC474	| 408558E0
    .short  0xFEF8, 0x6DD7, 0x1B2B, 0xE5CE, 0x081F, 0xDC46, 0xB72C, 0xE086	| 408558F0
    .short  0xF1DC, 0x7E4C, 0x915A, 0x13DC, 0x5072, 0x8133, 0xF376, 0xA3D6	| 40855900
    .short  0xF4D4, 0x95DE, 0x6A1A, 0xE142, 0x9DE2, 0xA427, 0xF283, 0x79E2	| 40855910
    .short  0x863D, 0x8BD4, 0xE007, 0xCC7F, 0xB824, 0xF3CC, 0x519A, 0xE6DF	| 40855920
    .short  0xF984, 0xB596, 0x2274, 0xB27E, 0x721C, 0x3709, 0x491E, 0x24B5	| 40855930
    .short  0xC7B3, 0x9614, 0xAE98, 0x6256, 0xDACD, 0xA5BA, 0xC2C2, 0xF853	| 40855940
    .short  0xBFD9, 0xFF60, 0x2CDD, 0xD800, 0xF665, 0x47ED, 0xCF28, 0x9B6C	| 40855950
    .short  0x4363, 0x8502, 0xCB79, 0xE248, 0xA7C7, 0xEE05, 0x7EE6, 0x655D	| 40855960
    .short  0x23F4, 0x1DBE, 0xD63B, 0xFE83, 0x29B6, 0x8C7C, 0x990C, 0xAF49	| 40855970
    .short  0x9BFC, 0xDF72, 0x742F, 0x123A, 0x30A3, 0xD12F, 0x76EE, 0xE48E	| 40855980
    .short  0xAD16, 0x46A0, 0xE20A, 0x618A, 0x945B, 0x09E3, 0x604E, 0xA2C9	| 40855990
    .short  0x2ED3, 0x745F, 0x4E7B, 0x675E, 0x3385, 0x8EE9, 0x18C8, 0x2AE0	| 408559A0
    .short  0x0189, 0xE43B, 0xC2FC, 0x1229, 0xED8E, 0x4F74, 0x3AF7, 0xA1D9	| 408559B0
    .short  0x0A44, 0xD51F, 0x3652, 0x6C2B, 0x5151, 0x4845, 0x6E63, 0x608E	| 408559C0
    .short  0x1EE6, 0xCB68, 0x533F, 0x0DF3, 0xFFB6, 0x9806, 0x480E, 0xD4FC	| 408559D0
    .short  0x0B8A, 0x6744, 0xFD20, 0x05A4, 0x1439, 0xAF81, 0xF716, 0x6142	| 408559E0
    .short  0xD23B, 0x86BE, 0xAB77, 0x2480, 0x4C36, 0x3479, 0x31F4, 0xF94F	| 408559F0
    .short  0x39E9, 0xAD0F, 0xC8D4, 0xEC12, 0xFABD, 0xD80D, 0x62FF, 0x7870	| 40855A00
    .short  0x1FFD, 0x6676, 0xD69A, 0x9E8D, 0x43A3, 0x1357, 0x9784, 0x2F95	| 40855A10
    .short  0x4559, 0x58AF, 0x1273, 0x1499, 0xDD05, 0x1AFA, 0xE57C, 0x0F7F	| 40855A20
    .short  0xA44D, 0x09CC, 0xA09E, 0x30A0, 0x9955, 0x51FF, 0xF0DC, 0xBE94	| 40855A30
    .short  0x927D, 0x1831, 0x11BB, 0x4E26, 0x0EDA, 0x97D7, 0x8392, 0x3252	| 40855A40
    .short  0x2899, 0xF47C, 0x3BCD, 0xFFE7, 0xB89F, 0xE8AB, 0x9B7E, 0x6F8A	| 40855A50
    .short  0x4BCF, 0x2BE5, 0xCDA0, 0xD1B1, 0xF9A9, 0x7A16, 0xC13E, 0xB269	| 40855A60
    .short  0xDC5B, 0xB072, 0xD90A, 0xC6A5, 0xF5E5, 0xDBB9, 0xA2F1, 0x7F25	| 40855A70
    .short  0x698C, 0x82B2, 0x6702, 0x72EA, 0x8FD3, 0xB6DF, 0x3C33, 0xBF20	| 40855A80
    .short  0x2C2E, 0xE551, 0x5296, 0xF500, 0x81D7, 0x8F3C, 0x9E62, 0xC487	| 40855A90
    .short  0x1CEB, 0xB1BB, 0x1372, 0x46C8, 0x7A23, 0xEB14, 0xB204, 0x876F	| 40855AA0
    .short  0x9D74, 0x4208, 0x08AD, 0x8D4D, 0xFCF2, 0x93F1, 0x22C0, 0x555B	| 40855AB0
    .short  0xE932, 0x5BB0, 0x6B4E, 0x4190, 0xACC9, 0xA922, 0x754A, 0x1036	| 40855AC0
    .short  0x1AB2, 0xCEED, 0x636E, 0x7418, 0xC40C, 0xBBDE, 0x01FE, 0x11AA	| 40855AD0
    .short  0x09F5, 0x5207, 0x0491, 0x73B6, 0x666A, 0x62CB, 0x8690, 0x3619	| 40855AE0
    .short  0x20D9, 0x164C, 0xA1A1, 0xFD6C, 0xEA08, 0x1D3D, 0x823C, 0x3EC9	| 40855AF0
    .short  0x6AAB, 0x4A1B, 0x7380, 0x6A1A, 0x0F67, 0xA05D, 0xE7FB, 0x83E8	| 40855B00
    .short  0x76E7, 0x759B, 0x5C8F, 0x3728, 0x062A, 0x7ED6, 0x4630, 0x20B4	| 40855B10
    .short  0x16CC, 0x40D3, 0xB6C4, 0x0BBC, 0xE834, 0xC7B8, 0x2454, 0x351C	| 40855B20
    .short  0x9C4F, 0x08A1, 0xF409, 0xFC7B, 0x93D0, 0x3140, 0x8882, 0xB59F	| 40855B30
    .short  0xBAAA, 0xF675, 0x0349, 0x5CD8, 0x5BEF, 0xD2AD, 0x960F, 0x394B	| 40855B40
    .short  0xB9E0, 0x5D9E, 0x5693, 0xBDBA, 0xCFDB, 0x765A, 0xF321, 0xEAEE	| 40855B50
    .short  0xF6B4, 0xAC98, 0xA831, 0x2562, 0x218D, 0x5FC6, 0x405D, 0xE7FD	| 40855B60
    .short  0xEBD8, 0xF2B7, 0x77C5, 0x57B5, 0x2713, 0x5666, 0xC09C, 0x0C2F	| 40855B70
    .short  0x41B3, 0x3DE1, 0x15E8, 0x1CCD, 0x6C41, 0x6867, 0x8D1E, 0x5458	| 40855B80
    .short  0xF271, 0x8A39, 0xE440, 0xBA7A, 0xAF24, 0xDE1E, 0x711F, 0x69EB	| 40855B90
    .short  0x4406, 0x2A96, 0x336C, 0x9954, 0x385E, 0xAAE2, 0x26BA, 0x9238	| 40855BA0
    .short  0x2E60, 0x91E9, 0x57B0, 0x8E88, 0x8CF9, 0x1783, 0x7218, 0x1E85	| 40855BB0
    .short  0x3F12, 0x44D5, 0xBFC3, 0xFAA8, 0x5961, 0xE35E, 0x78D5, 0xC92E	| 40855BC0
    .short  0x3410, 0x9A6A, 0x5DA2, 0xC88B, 0x4F86, 0x6EBD, 0xAD1A, 0x0005	| 40855BD0
    .short  0x4975, 0x94F0, 0xA5BC, 0x23DB, 0x6F07, 0x2749, 0x8498, 0x7013	| 40855BE0
    .short  0xA64C, 0xED5F, 0xE3AE, 0x282C, 0xCC83, 0x77F4, 0x7B88, 0xE6CF	| 40855BF0
    .short  0x29DE, 0xDDE6, 0xD146, 0xC33E, 0xAA2C, 0xF035, 0x0DC7, 0xD633	| 40855C00
    .short  0x2AD2, 0xE053, 0x2343, 0x6402, 0x2BF3, 0x0327, 0xDB94, 0x636D	| 40855C10
    .short  0x05EC, 0x2D84, 0x61ED, 0x066E, 0xFEB5, 0x3F17, 0x60D1, 0xAEC7	| 40855C20
    .short  0xB501, 0xF859, 0x1797, 0x3BA7, 0x5E03, 0xC06B, 0x1D26, 0x659C	| 40855C30
    .short  0x425F, 0x38A9, 0x192B, 0x4BF7, 0xBB22, 0x882D, 0x6427, 0xF724	| 40855C40
    .short  0xD7BE, 0xDC0B, 0x65AC, 0xA837, 0x90E2, 0xCF5C, 0x473A, 0xD909	| 40855C50
    .short  0x9117, 0x15D0, 0x5AC8, 0xB365, 0xD5D6, 0xC201, 0xCEB7, 0x45C3	| 40855C60
    .short  0xDF58, 0x95C4, 0x8BE1, 0x2C86, 0x2D0B, 0xA256, 0x559D, 0x964A	| 40855C70
    .short  0xD376, 0x9D9D, 0xE689, 0x498C, 0x32A8, 0xAB73, 0xB368, 0x02FE	| 40855C80
    .short  0xE0A5, 0x7BC1, 0x10E3, 0x4382, 0xA748, 0x590E, 0x4DAF, 0xA70A	| 40855C90
    .short  0x30EE, 0x47AE, 0x94C1, 0x3355, 0x7D53, 0xFE1D, 0x35FA, 0x1F9A	| 40855CA0
    .short  0x50BF, 0x7DF8, 0xE128, 0x6B30, 0xCB5A, 0x9B03, 0x18CB, 0xF3A2	| 40855CB0
    .short  0x6D81, 0x5321, 0x7450, 0x073A, 0x9F19, 0x8560, 0x4A38, 0xF1F6	| 40855CC0
    .short  0x7CA6, 0x9F4E, 0xAE56, 0x7CEF, 0xEC79, 0x0115, 0xEE70, 0xFBCA	| 40855CD0
    .short  0x25B9, 0xD732, 0xE225, 0x4D47, 0xC6CA, 0x0EE4, 0x0747, 0x2E50	| 40855CE0
    .short  0x2FEA, 0xB477, 0x7FF6, 0x0AFB, 0xD064, 0x5E97, 0x3E1C, 0x0471	| 40855CF0
    .short  0x7E15, 0xCDDA, 0xD8A7, 0xA4DD, 0x5469, 0xDF61, 0xC314, 0x84C5	| 40855D00
    .short  0xC766, 0x22AC, 0x683D, 0x8023, 0x9A6B, 0x71D1, 0x02F8, 0xDA7E	| 40855D10
    .short  0x9587, 0x4C89, 0xC9DF, 0xB70C, 0x0085, 0xCAB3, 0xD411, 0x19A6	| 40855D20
    .short  0x3D57, 0x9CEC, 0x807B, 0x3CDC, 0xDADD, 0x8CE0, 0x8A35, 0xD093	| 40855D30
    .short  0xA98B, 0x5A78, 0x4E45, 0xE13F, 0x87B8, 0xC548, 0xF829, 0x817D	| 40855D40
    .short  0xBD6F, 0xBCBF, 0x707F, 0x7904, 0x79E4, 0x3A11, 0xB437, 0x89CE	| 40855D50
    .short  0x376D, 0xCC10, 0x894B, 0x21F5, 0xA365, 0xC192, 0xBC78, 0xA3A3	| 40855D60
    .short  0x0C9B, 0xB9C0, 0xB12D, 0xE92A, 0xF100, 0xA534, 0x581D, 0xA6F9	| 40855D70
    .short  0xFBCE, 0x8B41, 0xCA1B, 0x50D4, 0x1BC2, 0xEFE3, 0x8E5C, 0x29C2	| 40855D80
    .short  0x5F0D, 0xB864, 0xEFC6, 0x9063, 0xB77A, 0x6D43, 0x98B1, 0xEE91	| 40855D90
    .short  0xDE95, 0x1B46, 0xB0A4, 0xD3D2, 0xC52F, 0x26F2, 0xBEF0, 0xE28F	| 40855DA0
    .short  0x8542	| 40855DB0

/* subroutine (12 instructions): calls rsrc_DRVR_50__ATBOOT_1A0 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3852:
    linkw %fp,#0
    movel %a3,%sp@-
    moveal %fp@(8),%a3
    movew %fp@(14),%d0
    extl %d0
    movel %d0,%sp@-
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_1A0)
    moveq #0,%d0
    moveal %fp@(-4),%a3
    unlk %fp
    rts

/* subroutine (20 instructions): calls rsrc_DRVR_50__ATBOOT_3D02, rsrc_DRVR_50__ATBOOT_3852; low memory MemErr (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3874:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    subql #4,%sp
    moveq #72,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D02)
    movel %sp@+,%a3@
    jbne rsrc_DRVR_50__ATBOOT_3874_1E
    subql #2,%sp
    movew MemErr,%sp@
    movew %sp@+,%d0
    jbra rsrc_DRVR_50__ATBOOT_3874_2C
rsrc_DRVR_50__ATBOOT_3874_1E:  /* set %d0 */
    moveq #1,%d0
    movel %d0,%sp@-
    movel %a3@,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3852)
    moveq #0,%d0
    addql #8,%sp
rsrc_DRVR_50__ATBOOT_3874_2C:  /* set %a3 */
    moveal %sp@+,%a3
    rts

/* subroutine (63 instructions): calls rsrc_DRVR_50__ATBOOT_38A4 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_38A4:
    linkw %fp,#0
    moveml %d6-%d7/%a3-%a4,%sp@-
    movel %fp@(20),%d6
    moveal %fp@(8),%a4
    moveal %fp@(12),%a3
    clrw %d7
    jbra rsrc_DRVR_50__ATBOOT_38A4_1A
rsrc_DRVR_50__ATBOOT_38A4_18:  /* loop: addq */
    addqw #1,%d7
rsrc_DRVR_50__ATBOOT_38A4_1A:  /* test #2,%d7 */
    cmpiw #2,%d7
    jbge rsrc_DRVR_50__ATBOOT_38A4_32
    extl %d7
    movel %d7,%d0
    asll #2,%d0
    addl %a3,%d0
    moveal %d0,%a0
    cmpil #1347896352,%a0@
    jbeq rsrc_DRVR_50__ATBOOT_38A4_18
rsrc_DRVR_50__ATBOOT_38A4_32:  /* test #2,%d7 */
    cmpiw #2,%d7
    jblt rsrc_DRVR_50__ATBOOT_38A4_70
    tstl %fp@(16)
    jbeq rsrc_DRVR_50__ATBOOT_38A4_5C
    movel %d6,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movel %d6,%d1
    addl %fp@(16),%d1
    moveq #16,%d2
    subl %d2,%d1
    movel %d1,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_38A4)
    lea %sp@(16),%sp
    jbra rsrc_DRVR_50__ATBOOT_38A4_A2
rsrc_DRVR_50__ATBOOT_38A4_5C:  /* result -5 */
    moveq #-5,%d0
    jbra rsrc_DRVR_50__ATBOOT_38A4_A2
    .long   0x2F0C2F0B, 0x70082F00, 0x4EBA041E	| 40855E64
    moveq #0,%d0
    jbra rsrc_DRVR_50__ATBOOT_38A4_A2
rsrc_DRVR_50__ATBOOT_38A4_70:  /* clear %d7 */
    clrw %d7
    jbra rsrc_DRVR_50__ATBOOT_38A4_76
rsrc_DRVR_50__ATBOOT_38A4_74:  /* loop: addq */
    addqw #1,%d7
rsrc_DRVR_50__ATBOOT_38A4_76:  /* test #2,%d7 */
    cmpiw #2,%d7
    jbge rsrc_DRVR_50__ATBOOT_38A4_96
    extl %d7
    movel %d7,%d0
    asll #2,%d0
    addl %a3,%d0
    moveal %d0,%a0
    extl %d7
    movel %d7,%d0
    asll #2,%d0
    addl %a4,%d0
    moveal %d0,%a1
    movel %a0@,%d0
    cmpl %a1@,%d0
    jbeq rsrc_DRVR_50__ATBOOT_38A4_74
rsrc_DRVR_50__ATBOOT_38A4_96:  /* test #2,%d7 */
    cmpiw #2,%d7
    jblt rsrc_DRVR_50__ATBOOT_38A4_A0
    moveq #0,%d0
    jbra rsrc_DRVR_50__ATBOOT_38A4_A2
rsrc_DRVR_50__ATBOOT_38A4_A0:  /* set %d0 */
    moveq #-5,%d0
rsrc_DRVR_50__ATBOOT_38A4_A2:  /* restore registers, return */
    moveml %fp@(-16),%d6-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (27 instructions): calls rsrc_DRVR_50__ATBOOT_3D2C (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3950:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    clrb %d7
    moveal %a4,%a3
rsrc_DRVR_50__ATBOOT_3950_10:  /* loop: tst */
    tstb %a4@+
    jbeq rsrc_DRVR_50__ATBOOT_3950_1E
    moveb %d7,%d0
    addqb #1,%d7
    cmpib #31,%d0
    jblt rsrc_DRVR_50__ATBOOT_3950_10
rsrc_DRVR_50__ATBOOT_3950_1E:  /* test #31,%d7 */
    cmpib #31,%d7
    jblt rsrc_DRVR_50__ATBOOT_3950_26
    moveq #31,%d7
rsrc_DRVR_50__ATBOOT_3950_26:  /* set %sp@- */
    movel %a3,%sp@-
    movel %fp@(12),%d0
    addql #1,%d0
    movel %d0,%sp@-
    extw %d7
    extl %d7
    movel %d7,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D2C)
    moveal %fp@(12),%a0
    moveb %d7,%a0@
    moveml %fp@(-12),%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (99 instructions): calls rsrc_DRVR_50__ATBOOT_3950, rsrc_DRVR_50__ATBOOT_9EE, rsrc_DRVR_50__ATBOOT_3D18, rsrc_DRVR_50__ATBOOT_184A, rsrc_DRVR_50__ATBOOT_1776 ... (mechanical summary) */
rsrc_DRVR_50__ATBOOT_399A:
    linkw %fp,#-54
    moveml %d7/%a3,%sp@-
    moveal %fp@(8),%a3
    moveal %a3@(618),%a0
    moveb %a0@,%d0
    extw %d0
    movew %d0,%fp@(-48)
    pea %fp@(-42)
    moveal %a3@(618),%a0
    pea %a0@(22)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3950)
    moveal %a3@(618),%a0
    tstb %a0@(5)
    addql #8,%sp
    jbne rsrc_DRVR_50__ATBOOT_399A_3E
    moveal %a3@(618),%a0
    moveb #2,%a0@(5)
rsrc_DRVR_50__ATBOOT_399A_3E:  /* from here: pea %a3@(28) */
    pea %a3@(28)
    pea %a3@(24)
    pea %a3@(4)
    moveal %a3@(618),%a0
    moveq #0,%d0
    moveb %a0@(4),%d0
    movel %d0,%sp@-
    pea %fp@(-50)
    moveal %a3@(618),%a0
    movew %a0@(62),%d0
    extl %d0
    movel %d0,%sp@-
    moveal %a3@(618),%a0
    moveq #0,%d0
    moveb %a0@(5),%d0
    mulsw #60,%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_9EE)
    movew %d0,%d7
    lea %sp@(28),%sp
    jbne rsrc_DRVR_50__ATBOOT_399A_12C
    moveq #0,%d0
    movel %d0,%fp@(-54)
    subql #4,%sp
    movel %a3@(4),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D18)
    movel %sp@+,%d0
    moveq #64,%d1
    subl %d1,%d0
    movel %d0,%sp@-
    pea %a3@(8)
    movel %a3@(4),%sp@-
    pea %fp@(-54)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_184A)
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_1776)
    movew %d0,%d7
    lea %sp@(20),%sp
    jbeq rsrc_DRVR_50__ATBOOT_399A_C0
    movew %d7,%d0
    jbra rsrc_DRVR_50__ATBOOT_399A_12E
rsrc_DRVR_50__ATBOOT_399A_C0:  /* set %sp@- */
    movel %fp@(-54),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D0E)
    subql #4,%sp
    movel %a3@(4),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D18)
    movel %a3@(4),%sp@-
    moveal %a3@(618),%a0
    pea %a0@(6)
    pea %a3@(8)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_38A4)
    movew %d0,%d7
    lea %sp@(16),%sp
    jbeq rsrc_DRVR_50__ATBOOT_399A_100
    movel %a3@(4),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D0E)
    moveq #0,%d0
    movel %d0,%a3@(4)
    movew %d7,%d0
    jbra rsrc_DRVR_50__ATBOOT_399A_12E
rsrc_DRVR_50__ATBOOT_399A_100:  /* test %a3@(4) */
    tstl %a3@(4)
    jbeq rsrc_DRVR_50__ATBOOT_399A_122
    pea %fp@(-4)
    pea %fp@(-8)
    movel %a3,%sp@-
    moveq #1,%d0
    movel %d0,%sp@-
    moveal %a3@(4),%a0
    jsr %a0@
    movew %d0,%d7
    lea %sp@(16),%sp
    jbra rsrc_DRVR_50__ATBOOT_399A_124
rsrc_DRVR_50__ATBOOT_399A_122:  /* set %d7 */
    moveq #-6,%d7
rsrc_DRVR_50__ATBOOT_399A_124:  /* test %d7 */
    tstw %d7
    jbeq rsrc_DRVR_50__ATBOOT_399A_12C
    movew %d7,%d0
    jbra rsrc_DRVR_50__ATBOOT_399A_12E
rsrc_DRVR_50__ATBOOT_399A_12C:  /* set %d0 */
    movew %d7,%d0
rsrc_DRVR_50__ATBOOT_399A_12E:  /* restore registers, return */
    moveml %fp@(-62),%d7/%a3
    unlk %fp
    rts

/* subroutine (22 instructions): calls rsrc_DRVR_50__ATBOOT_3874 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3AD2:
    linkw %fp,#-8
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %fp@(12),%a3
    movew %a3@(2),%d7
    tstl %a3@(618)
    jbne rsrc_DRVR_50__ATBOOT_3AD2_2E
    pea %a3@(618)
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3874)
    movew %d0,%d7
    addql #4,%sp
    jbeq rsrc_DRVR_50__ATBOOT_3AD2_2E
    movew %d7,%d0
    jbra rsrc_DRVR_50__ATBOOT_3C0A
rsrc_DRVR_50__ATBOOT_3AD2_2E:  /* set %d0 */
    movew %a4@(26),%d0
    subqw #1,%d0
    jbmi rsrc_DRVR_50__ATBOOT_3BA8
    cmpiw #4,%d0
    jbgt rsrc_DRVR_50__ATBOOT_3BA8
    addw %d0,%d0
    movew %pc@(rsrc_DRVR_50__ATBOOT_3B1C,%d0:w),%d0
rsrc_DRVR_50__ATBOOT_3AD2_46:  /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
rsrc_DRVR_50__ATBOOT_3B1C:  /* (data) */
    .short  rsrc_DRVR_50__ATBOOT_3B26-RESTOP_6C5A	| 4085607C
    .short  rsrc_DRVR_50__ATBOOT_3B44-RESTOP_6C5A	| 4085607E
    .short  rsrc_DRVR_50__ATBOOT_3B6A-RESTOP_6C5A	| 40856080
    .short  rsrc_DRVR_50__ATBOOT_3B9E-RESTOP_6C5A	| 40856082
    .short  rsrc_DRVR_50__ATBOOT_3BA2-RESTOP_6C5A	| 40856084

/* subroutine (10 instructions): calls rsrc_DRVR_50__ATBOOT_399A, rsrc_DRVR_50__ATBOOT_3D2C (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3B26:
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_399A)
    movew %d0,%d7
    addql #4,%sp
    jbne rsrc_DRVR_50__ATBOOT_3BAA
    pea %a3@(186)
    movel %a4@(32),%sp@-
    movel %a4@(36),%sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3D2C)
    jbra rsrc_DRVR_50__ATBOOT_3BAA

/* subroutine (14 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3B44:
    tstl %a3@(4)
    jbeq rsrc_DRVR_50__ATBOOT_3B66
    pea %fp@(-4)
    pea %fp@(-8)
    movel %a3,%sp@-
    moveq #2,%d0
    movel %d0,%sp@-
    moveal %a3@(4),%a0
    jsr %a0@
    movew %d0,%d7
    lea %sp@(16),%sp
    jbra rsrc_DRVR_50__ATBOOT_3BAA
rsrc_DRVR_50__ATBOOT_3B66:  /* set %d7 */
    moveq #-6,%d7
    jbra rsrc_DRVR_50__ATBOOT_3BAA

/* subroutine (17 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3B6A:
    tstl %a3@(4)
    jbeq rsrc_DRVR_50__ATBOOT_3B9A
    pea %fp@(-4)
    pea %fp@(-8)
    movel %a3,%sp@-
    moveq #3,%d0
    movel %d0,%sp@-
    moveal %a3@(4),%a0
    jsr %a0@
    movew %d0,%d7
    lea %sp@(16),%sp
    jbne rsrc_DRVR_50__ATBOOT_3BAA
    movel %fp@(-8),%a4@(28)
    movel %fp@(-4),%a4@(32)
    jbra rsrc_DRVR_50__ATBOOT_3BAA
rsrc_DRVR_50__ATBOOT_3B9A:  /* set %d7 */
    moveq #-6,%d7
    jbra rsrc_DRVR_50__ATBOOT_3BAA

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3B9E:
    moveq #-50,%d7
    jbra rsrc_DRVR_50__ATBOOT_3BAA

/* subroutine (35 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3BA2:
    movel %a3,%a4@(28)
    jbra rsrc_DRVR_50__ATBOOT_3BAA
rsrc_DRVR_50__ATBOOT_3BA8:  /* set %d7 */
    moveq #-50,%d7
rsrc_DRVR_50__ATBOOT_3BAA:  /* set %a0 */
    moveal %a3@(618),%a0
    moveq #64,%d0
    andb %a0@(3),%d0
    jbne rsrc_DRVR_50__ATBOOT_3C08
    moveal %a3@(618),%a0
    tstw %a0@(62)
    jbeq rsrc_DRVR_50__ATBOOT_3C08
    tstw %d7
    jbeq rsrc_DRVR_50__ATBOOT_3C08
    movew %a3@(622),%d0
    addqw #1,%a3@(622)
    cmpiw #5,%d0
    jblt rsrc_DRVR_50__ATBOOT_3C08
    moveal %a3@(618),%a0
    addql #6,%a0
    movel %a0,%fp@(-8)
    addql #4,%fp@(-8)
    movel #1347896352,%a0@
    moveal %fp@(-8),%a0
    movel #1347896352,%a0@
    moveal %a3@(618),%a0
    clrw %a0@(62)
    moveal %a3@(618),%a0
    clrb %a0@(22)
    clrw %a3@(622)
    movew %d7,%a3@(624)
rsrc_DRVR_50__ATBOOT_3C08:  /* set %d0 */
    movew %d7,%d0
rsrc_DRVR_50__ATBOOT_3C0A:  /* restore registers, return */
    moveml %fp@(-20),%d7/%a3-%a4
    unlk %fp
    rts

rsrc_DRVR_50__ATBOOT_3C14:  /* set %d0 */
    movel %sp@(4),%d0
    movel %sp@(8),%d1

/* subroutine (18 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3C1C:
    movel %d2,%sp@-
    movel %d0,%d2
    muluw %d1,%d2
    moveal %d2,%a0
    movel %d1,%d2
    swap %d2
    muluw %d0,%d2
    swap %d0
    muluw %d0,%d1
    addw %d1,%d2
    swap %d2
    clrw %d2
    addal %d2,%a0
    movel %a0,%d0
    movel %sp@+,%d2
    rts

rsrc_DRVR_50__ATBOOT_3C3C:  /* set %d1 */
    movel %sp@(4),%d1
    movel %sp@(8),%d0

/* subroutine (5 instructions): calls rsrc_DRVR_50__ATBOOT_3C54 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3C44:
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3C54)
    movel %d1,%d0
    rts

rsrc_DRVR_50__ATBOOT_3C4C:  /* set %d1 */
    movel %sp@(4),%d1
    movel %sp@(8),%d0

/* subroutine (18 instructions): calls rsrc_DRVR_50__ATBOOT_3C82 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3C54:
    moveml %d5-%d6,%sp@-
    movel %d0,%d5
    jbpl rsrc_DRVR_50__ATBOOT_3C54_A
    negl %d0
rsrc_DRVR_50__ATBOOT_3C54_A:  /* set %d6 */
    movel %d1,%d6
    jbpl rsrc_DRVR_50__ATBOOT_3C54_10
    negl %d1
rsrc_DRVR_50__ATBOOT_3C54_10:  /* call rsrc_DRVR_50__ATBOOT_3C82 */
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3C82)
    tstl %d5
    jbpl rsrc_DRVR_50__ATBOOT_3C54_1A
    negl %d0
rsrc_DRVR_50__ATBOOT_3C54_1A:  /* from here: eorl %d5,%d6 */
    eorl %d5,%d6
    jbpl rsrc_DRVR_50__ATBOOT_3C54_20
    negl %d1
rsrc_DRVR_50__ATBOOT_3C54_20:  /* restore registers, return */
    moveml %sp@+,%d5-%d6
    rts

rsrc_DRVR_50__ATBOOT_3C7A:  /* set %d1 */
    movel %sp@(4),%d1
    movel %sp@(8),%d0

/* subroutine (43 instructions): low memory MemErr (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3C82:
    moveml %d2-%d4,%sp@-
    movel %d1,%d2
    swap %d2
    tstw %d2
    jbne rsrc_DRVR_50__ATBOOT_3C82_28
    movew %d0,%d3
    clrw %d0
    swap %d0
    jbeq rsrc_DRVR_50__ATBOOT_3C82_18
    divuw %d1,%d0
    movew %d0,%d2
rsrc_DRVR_50__ATBOOT_3C82_18:  /* from here: swap %d2 */
    swap %d2
    movew %d3,%d0
    divuw %d1,%d0
    movew %d0,%d2
    movel %d2,%d1
    clrw %d0
    swap %d0
    jbra rsrc_DRVR_50__ATBOOT_3C82_4A
rsrc_DRVR_50__ATBOOT_3C82_28:  /* set %d2 */
    movel %d0,%d2
    clrw %d0
    swap %d0
    swap %d2
    clrw %d2
    movel %d1,%d3
    moveq #0,%d1
    moveq #15,%d4
rsrc_DRVR_50__ATBOOT_3C82_38:  /* loop: add */
    addl %d2,%d2
    addxl %d0,%d0
    addl %d1,%d1
    cmpl %d3,%d0
    jblt rsrc_DRVR_50__ATBOOT_3C82_46
    subl %d3,%d0
    addqb #1,%d1
rsrc_DRVR_50__ATBOOT_3C82_46:  /* count down */
    dbf %d4,rsrc_DRVR_50__ATBOOT_3C82_38
rsrc_DRVR_50__ATBOOT_3C82_4A:  /* restore registers, return */
    moveml %sp@+,%d2-%d4
    rts
    .short  0x225F, 0x201F, 0xA04C, 0x2E80, 0x4E71	| 40856232
rsrc_DRVR_50__ATBOOT_3C82_5A:  /* clear %d0 */
    moveq #0,%d0
rsrc_DRVR_50__ATBOOT_3C82_5C:  /* set %sp@- */
    movel %a1,%sp@-
rsrc_DRVR_50__ATBOOT_3C82_5E:  /* loop: move */
    movew %d0,MemErr
    rts
    moveq #0,%d0
    jbra rsrc_DRVR_50__ATBOOT_3C82_5E

/* subroutine (4 instructions): traps NewPtr (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3CEA:
    moveal %sp@+,%a1
    movel %sp@+,%d0
    .short  0xA11E	| 4085624E _NewPtr (flags 0x0100)
    movel %a0,%sp@
    jmp %pc@(rsrc_DRVR_50__ATBOOT_3C82_5C)

/* subroutine (4 instructions): traps NewPtr (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3CF6:
    moveal %sp@+,%a1
    movel %sp@+,%d0
    .short  0xA51E	| 4085625A _NewPtr (flags 0x0500)
    movel %a0,%sp@
    jmp %pc@(rsrc_DRVR_50__ATBOOT_3C82_5C)

/* subroutine (4 instructions): traps NewPtr (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3D02:
    moveal %sp@+,%a1
    movel %sp@+,%d0
    .short  0xA71E	| 40856266 _NewPtr (flags 0x0700)
    movel %a0,%sp@
    jmp %pc@(rsrc_DRVR_50__ATBOOT_3C82_5C)

/* subroutine (4 instructions): traps DisposPtr (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3D0E:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _DisposPtr
    jmp %pc@(rsrc_DRVR_50__ATBOOT_3C82_5C)

/* subroutine (8 instructions): traps GetPtrSize (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3D18:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _GetPtrSize
    movel %d0,%sp@
    jbpl rsrc_DRVR_50__ATBOOT_3D18_10
    clrl %sp@
    jmp %pc@(rsrc_DRVR_50__ATBOOT_3C82_5C)
rsrc_DRVR_50__ATBOOT_3D18_10:  /* jump through %pc@(rsrc_DRVR_50__ATBOOT_3C82_5A) */
    jmp %pc@(rsrc_DRVR_50__ATBOOT_3C82_5A)

/* subroutine (14 instructions): traps BlockMove (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3D2C:
    movel %sp@+,%d1
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _BlockMove
    moveal %d1,%a1
    jmp %pc@(rsrc_DRVR_50__ATBOOT_3C82_5C)
    .long   0x3038028E	| 4085629C
    .short  0x6A10, 0x0838, 0x0005, 0x0291, 0x6708, 0x323C, 0xFFD7	| 408562A0
    moveq #0,%d0
    jbra rsrc_DRVR_50__ATBOOT_3D2C_42
    .short  0x9EFC, 0x0032, 0x204F, 0x43FA, 0x0124, 0x2149, 0x0012, 0x4228	| 408562B2
    .short  0x001B, 0xA000, 0x3228, 0x0018, 0xDEFC, 0x0032	| 408562C2
rsrc_DRVR_50__ATBOOT_3D2C_42:  /* set %a0 */
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movew %d1,%a1@
    movew %d0,%sp@
    jmp %a0@
    movew #245,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #244,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #243,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #248,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #247,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3DA0:
    movew #246,%d0
    jbra rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #253,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0

/* subroutine (15 instructions): traps Control (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3DB0:
    movew #251,%d0
    jbra rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #250,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #252,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #256,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #254,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0
    movew #254,%d0
    braw rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #250,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #255,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #253,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #252,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #251,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #256,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #249,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #248,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #258,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #257,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_A0_C
    movew #255,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_B6
    movew #254,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_B6
    movew #248,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_B6
    movew #249,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_B6
    movew #247,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_B6
    movew #252,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_B6
    movew #253,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_B6
    movew #251,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_B6
    movew #250,%d0
    bras rsrc_DRVR_50__ATBOOT_3DB0_B6
rsrc_DRVR_50__ATBOOT_3DB0_A0:  /* set %a0 */
    moveal %sp@(6),%a0
    movew #-10,%a0@(24)
    jbra rsrc_DRVR_50__ATBOOT_3DB0_B6
rsrc_DRVR_50__ATBOOT_3DB0_A0_C:
    moveal %sp@(6),%a0	| 408563BC
    movew #-11,%a0@(24)
rsrc_DRVR_50__ATBOOT_3DB0_B6:  /* set %a1 */
    moveal %sp@+,%a1
    moveb %sp@+,%d1
    moveal %sp@+,%a0
    movew %d0,%a0@(26)
    tstb %d1
    jbne rsrc_DRVR_50__ATBOOT_3DB0_C8
    _Control
    jbra rsrc_DRVR_50__ATBOOT_3DB0_CA
rsrc_DRVR_50__ATBOOT_3DB0_C8:  /* (_Control (flags 0x0400)) */
    .short  0xA404	| 408563D8 _Control (flags 0x0400)
rsrc_DRVR_50__ATBOOT_3DB0_CA:  /* set %sp@ */
    movew %d0,%sp@
    jmp %a1@
    .short  0x042E	| 408563DE
    .long   0x58505000	| 408563E0

/* subroutine (19 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3E84:
    moveml %d1-%d2/%a0-%a2,%sp@-
    moveml %sp@(24),%d1-%d2/%a0-%a2
    pea %a1@(1)
    movel %sp@+,%a2@(2)
    movel %a0,%a2@(8)
    clrw %a2@(12)
    swap %d2
    movew %d2,%a1@(8)
    swap %d2
    moveb %d2,%a1@(14)
    asrw #8,%d2
    moveb %d2,%a1@(12)
    moveb %d1,%a1@(16)
    swap %d1
    movew %d1,%a2@(6)
    moveml %sp@+,%d1-%d2/%a0-%a2
    movel %sp@,%sp@(20)
    addaw #20,%sp
    rts

/* subroutine (11 instructions): calls rsrc_DRVR_50__ATBOOT_3EEA (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3EC8:
    moveml %d0/%a0-%a1,%sp@-
    moveq #28,%d0
    jbsr rsrc_DRVR_50__ATBOOT_3EEA
    movew #24,%d0
    jbsr rsrc_DRVR_50__ATBOOT_3EEA
    movew #20,%d0
    jbsr rsrc_DRVR_50__ATBOOT_3EEA
    moveml %sp@+,%d0/%a0-%a1
    movel %sp@,%sp@(16)
    addaw #16,%sp
    rts

/* subroutine (8 instructions): traps BlockMove (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3EEA:
    moveal %sp@(0x0,%d0:w),%a0
    moveq #0,%d0
    moveb %a0@,%d0
    addql #1,%d0
    moveal %sp@(32),%a1
    addl %d0,%sp@(32)
    _BlockMove
    rts
rsrc_DRVR_50__ATBOOT_3F00:  /* (data) */
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40856460
    .long   0x00000000, 0x00000000, 0x00000000	| 40856470
rsrc_DRVR_50__ATBOOT_3F1C:  /* (unused, zeros) */
    .fill   0x62, 1, 0x00
PSTR_MPP_408564DE:      /* (data) */
    .short  0x042E, 0x4D50, 0x5020, 0x042E, 0x4154, 0x5020	| 408564DE
    .fill   0x66, 1, 0x00

/* subroutine (20 instructions): traps DisposHandle (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3FF0:
    moveml %a1-%a2,%sp@-
    lea %pc@(rsrc_DRVR_50__ATBOOT_3F00),%a1
rsrc_DRVR_50__ATBOOT_3FF0_8:  /* loop: move */
    movew %sr,%sp@-
    movew #9728,%sr
    moveal %a1@,%a0
    moveal %a0@,%a2
    movel %a0,%d0
    jbeq rsrc_DRVR_50__ATBOOT_3FF0_18
    movel %a2@,%a1@
rsrc_DRVR_50__ATBOOT_3FF0_18:  /* set up and call _DisposHandle */
    movew %sp@+,%sr
    tstl %d0
    jbeq rsrc_DRVR_50__ATBOOT_3FF0_22
    _DisposHandle
    jbra rsrc_DRVR_50__ATBOOT_3FF0_8
rsrc_DRVR_50__ATBOOT_3FF0_22:  /* restore registers, return */
    moveml %sp@+,%a1-%a2
    rts
rsrc_DRVR_50__ATBOOT_3FF0_28:  /* set %d3 */
    movel %sp@+,%d3
    movew %d0,%sp@
    moveal %d2,%a1
    jmp %a1@

/* subroutine (11 instructions): traps HUnlock (mechanical summary) */
rsrc_DRVR_50__ATBOOT_3FF0_30:
    movel %a1,%sp@-
    _HUnlock
    moveal %a0@,%a1
    movew %sr,%sp@-
    movew #9728,%sr
    movel %pc@(rsrc_DRVR_50__ATBOOT_3F00),%a1@
    lea %pc@(rsrc_DRVR_50__ATBOOT_3F00),%a1
    movel %a0,%a1@
    movew %sp@+,%sr
    moveal %sp@+,%a1
    rts

/* subroutine (9 instructions): low memory PortBUse (mechanical summary) */
rsrc_DRVR_50__ATBOOT_403C:
    moveq #0,%d1
    moveb PortBUse,%d0
    jbmi rsrc_DRVR_50__ATBOOT_403C_12
    andib #15,%d0
    subqb #1,%d0
    jbne rsrc_DRVR_50__ATBOOT_403C_12
    moveq #1,%d1
rsrc_DRVR_50__ATBOOT_403C_12:  /* set %sp@(4) */
    moveb %d1,%sp@(4)
    rts

/* subroutine (114 instructions): traps Open, HUnlock, PostEvent; calls rsrc_DRVR_50__ATBOOT_403C, rsrc_DRVR_50__ATBOOT_41D2; low memory PortBUse, SPConfig (mechanical summary) */
rsrc_DRVR_50__ATBOOT_4054:
    clrw %sp@-
    jsr %pc@(rsrc_DRVR_50__ATBOOT_403C)
    clrw %d0
    tstb %sp@+
    jbne rsrc_DRVR_50__ATBOOT_4054_3E
    moveb PortBUse,%d1
    jbmi rsrc_DRVR_50__ATBOOT_4054_16
    moveq #-97,%d0
    jbra rsrc_DRVR_50__ATBOOT_4054_3E
rsrc_DRVR_50__ATBOOT_4054_16:  /* set %d0 */
    moveb SPConfig,%d0
    andib #15,%d0
    subqb #1,%d0
    jble rsrc_DRVR_50__ATBOOT_4054_26
    moveq #-98,%d0
    jbra rsrc_DRVR_50__ATBOOT_4054_3E
rsrc_DRVR_50__ATBOOT_4054_26:  /* from here: subaw #50,%sp */
    subaw #50,%sp
    moveal %sp,%a0
    lea %pc@(PSTR_MPP_408564DE),%a1
    movel %a1,%a0@(18)
    clrb %a0@(27)
    _Open
    addaw #50,%sp
rsrc_DRVR_50__ATBOOT_4054_3E:  /* set %sp@(4) */
    movew %d0,%sp@(4)
    rts
rsrc_DRVR_50__ATBOOT_4098:  /* set %d3 */
    moveq #4,%d3	| 408565F8
    cmpw %d3,%d1	| 408565FA
    jbcc rsrc_DRVR_50__ATBOOT_40A0	| 408565FC
    movew %d1,%d3	| 408565FE
rsrc_DRVR_50__ATBOOT_40A0:  /* (40856600 lea %pc@(0x408564c4),%a5) */
    lea %pc@(rsrc_DRVR_50__ATBOOT_3F1C+0x48),%a5	| 40856600 40856600 lea %pc@(0x408564c4),%a5
    movel %a3,%a5@(2)	| 40856604
    movew %d3,%d2	| 40856608
    swap %d2	| 4085660A
    moveb %d0,%d2	| 4085660C
    tstw %d3	| 4085660E
    jbeq rsrc_DRVR_50__ATBOOT_40B6	| 40856610
    jsr %a4@	| 40856612
    jbne rsrc_DRVR_50__ATBOOT_40EE	| 40856614
rsrc_DRVR_50__ATBOOT_40B6:  /* address %pc@(rsrc_DRVR_50__ATBOOT_3F1C) */
    lea %pc@(rsrc_DRVR_50__ATBOOT_3F1C),%a3	| 40856616
    moveq #11,%d3	| 4085661A
rsrc_DRVR_50__ATBOOT_40BC:  /* loop: cmp */
    cmpb %a3@(0,%d3:w),%d2	| 4085661C
    dbeq %d3,rsrc_DRVR_50__ATBOOT_40BC	| 40856620
    jbne rsrc_DRVR_50__ATBOOT_40F0	| 40856624
    lslw #2,%d3	| 40856626
    movew %d3,%a5@	| 40856628
    moveal %a3@(0x18,%d3:w),%a3	| 4085662A 4085662A moveal %a3@(18,%d3:w),%a3
    movel %a3,%d0	| 4085662E
    jbeq rsrc_DRVR_50__ATBOOT_40F0	| 40856630
    moveal %a3@(4),%a3	| 40856632
    moveal %a3@,%a3	| 40856636
    movew %a3@(16),%d3	| 40856638
    moveal %a3@(20),%a3	| 4085663C
    swap %d2	| 40856640
    addaw %d2,%a3	| 40856642
    subw %d2,%d3	| 40856644
    jsr %a4@(2)	| 40856646
    jbne rsrc_DRVR_50__ATBOOT_40EE	| 4085664A
    jbra rsrc_DRVR_50__ATBOOT_40F6	| 4085664C
rsrc_DRVR_50__ATBOOT_40EE:  /* return */
    rts	| 4085664E
rsrc_DRVR_50__ATBOOT_40F0:  /* clear %d3 */
    moveq #0,%d3	| 40856650
    jmp %a4@(2)	| 40856652
rsrc_DRVR_50__ATBOOT_40F6:  /* test %d3 */
    tstw %d3	| 40856656
    jbge rsrc_DRVR_50__ATBOOT_40FE	| 40856658
    movew #-3101,%d0	| 4085665A
rsrc_DRVR_50__ATBOOT_40FE:  /* set %sp@- */
    movel %a2,%sp@-	| 4085665E
    lea %pc@(rsrc_DRVR_50__ATBOOT_3F1C+0x48),%a1	| 40856660 40856660 lea %pc@(0x408564c4),%a1
    lea %pc@(rsrc_DRVR_50__ATBOOT_3F1C),%a2	| 40856664
    movew %a1@,%d1	| 40856668
    moveal %a2@(0x18,%d1:w),%a2	| 4085666A 4085666A moveal %a2@(18,%d1:w),%a2
    moveal %a2@(4),%a0	| 4085666E
    moveal %a0@,%a0	| 40856672
    movew %a0@(16),%d1	| 40856674
    subw %d3,%d1	| 40856678
    movew %d1,%a0@(18)	| 4085667A
    moveal %a1@(2),%a3	| 4085667E
    moveal %a0@(20),%a2	| 40856682
    cmpw %a0@(16),%d2	| 40856686
    jble rsrc_DRVR_50__ATBOOT_4130	| 4085668A
    movew %a0@(16),%d2	| 4085668C
rsrc_DRVR_50__ATBOOT_4130:  /* loop: subq */
    subqw #1,%d2	| 40856690
    jblt rsrc_DRVR_50__ATBOOT_413C	| 40856692
    moveb %a3@(0,%d2:w),%a2@(0,%d2:w)	| 40856694
    jbra rsrc_DRVR_50__ATBOOT_4130	| 4085669A
rsrc_DRVR_50__ATBOOT_413C:  /* set %a2 */
    moveal %sp@+,%a2	| 4085669C
    movew %d0,%a0@(2)	| 4085669E
    clrb %a0@(8)	| 408566A2
    moveb %a3@(-1),%a0@(9)	| 408566A6
    moveb %a3@(-2),%a0@(15)	| 408566AC
    clrb %a0@(24)	| 408566B2
    moveb %a2@(1),%a0@(25)	| 408566B6
    movew %a1@,%d2	| 408566BC
    movew %d2,%d1	| 408566BE
    lsrw #2,%d1	| 408566C0
    lea %pc@(rsrc_DRVR_50__ATBOOT_3F1C),%a1	| 408566C2
    cmpib #1,%a2@(3)	| 408566C6
    jbne rsrc_DRVR_50__ATBOOT_417E	| 408566CC
    moveb %a2@(2),%a0@(14)	| 408566CE
    clrw %a0@(12)	| 408566D4
    moveal %a1@(0x18,%d2:w),%a3	| 408566D8 408566D8 moveal %a1@(18,%d2:w),%a3
    jbra rsrc_DRVR_50__ATBOOT_41AA	| 408566DC
rsrc_DRVR_50__ATBOOT_417E:  /* set %a0@(14) */
    moveb %a3@(-4),%a0@(14)	| 408566DE
    movew %a3@(-7),%a0@(12)	| 408566E4
    tstw %a3@(-11)	| 408566EA
    moveal %a1@(0x18,%d2:w),%a3	| 408566EE 408566EE moveal %a1@(18,%d2:w),%a3
    jbeq rsrc_DRVR_50__ATBOOT_41AA	| 408566F2
    tstw %d0	| 408566F4
    jbne rsrc_DRVR_50__ATBOOT_41AA	| 408566F6
    bsrw rsrc_DRVR_50__ATBOOT_41D2	| 408566F8
    jbeq rsrc_DRVR_50__ATBOOT_41AA	| 408566FC
    tstb %a3@(9)	| 408566FE
    jbeq rsrc_DRVR_50__ATBOOT_41D0	| 40856702
    movew #-3103,%a0@(2)	| 40856704
rsrc_DRVR_50__ATBOOT_41AA:  /* set %a0 */
    moveal %a3@(4),%a0	| 4085670A
    _HUnlock	| 4085670E 4085670E A-line trap
    tstb %a3@(8)	| 40856710
    jbeq rsrc_DRVR_50__ATBOOT_41C0	| 40856714
    movel %a0,%d0	| 40856716
    moveaw #10,%a0	| 40856718
    _PostEvent	| 4085671C 4085671C A-line trap
    jbra rsrc_DRVR_50__ATBOOT_41C4	| 4085671E
rsrc_DRVR_50__ATBOOT_41C0:  /* (40856720 st %a1@(c,%d1:w)) */
    .short  0x50F1, 0x100C	/* 40856720 st %a1@(c,%d1:w) */
rsrc_DRVR_50__ATBOOT_41C4:
    .short  0x2393, 0x2018	/* 40856724 movel %a3@,%a1@(18,%d2:w) */
    .byte   0x20, 0x6B	| 40856728
    .long   0x000A4EBA /* number, not a label difference (was DECL_DRVR_Display_Video_Apple_V8_GetDefaultMode_150-.) */	| 4085672A
    .byte   0xFE, 0x52	| 4085672E
rsrc_DRVR_50__ATBOOT_41D0:  /* return */
    rts	| 40856730

/* subroutine (14 instructions): calls rsrc_DRVR_50__ATBOOT_41FA (mechanical summary) */
rsrc_DRVR_50__ATBOOT_41D2:
    moveml %d1/%a1,%sp@-
    clrw %d3
    lea %a2@(8),%a1
    moveq #9,%d1
    jbsr rsrc_DRVR_50__ATBOOT_41FA
    moveal %a0@(20),%a1
    movew %a0@(18),%d1
    jbsr rsrc_DRVR_50__ATBOOT_41FA
    tstw %d3
    jbne rsrc_DRVR_50__ATBOOT_41D2_1E
    subqw #1,%d3
rsrc_DRVR_50__ATBOOT_41D2_1E:  /* from here: subw %a2@(6),%d3 */
    subw %a2@(6),%d3
    moveml %sp@+,%d1/%a1
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_41FA:
    clrw %d0
    subqw #1,%d1
rsrc_DRVR_50__ATBOOT_41FA_4:  /* loop: move */
    moveb %a1@+,%d0
    addw %d0,%d3
    rolw #1,%d3
    dbf %d1,rsrc_DRVR_50__ATBOOT_41FA_4
    rts

/* subroutine (5 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_41FA_10:
    lea %pc@(rsrc_DRVR_50__ATBOOT_3F1C),%a1
    moveq #11,%d1
rsrc_DRVR_50__ATBOOT_41FA_16:  /* loop: cmp */
    cmpb %a1@(0x0,%d1:w),%d3
    dbeq %d1,rsrc_DRVR_50__ATBOOT_41FA_16
    rts

/* subroutine (37 instructions): traps Control; calls rsrc_DRVR_50__ATBOOT_3FF0 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_421A:
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3FF0)
    movel %sp@+,%d2
    moveal %sp@+,%a1
    movel %a1,%d1
    jbne rsrc_DRVR_50__ATBOOT_421A_12
    lea %pc@(rsrc_DRVR_50__ATBOOT_4098),%a1
    movel %a1,%d1
rsrc_DRVR_50__ATBOOT_421A_12:  /* set %a1 */
    moveal %sp@+,%a1
    movel %d3,%sp@-
    moveb %a1@(1),%d3
    subaw #50,%sp
    moveal %sp,%a0
    moveb %d3,%a0@(28)
    movel %d1,%a0@(30)
    movew #248,%a0@(26)
    movew #-10,%a0@(24)
    _Control
    tstw %d0
    jbne rsrc_DRVR_50__ATBOOT_421A_70
    moveb %a0@(28),%d3
    moveb %d3,%a1@(1)
    lea %pc@(rsrc_DRVR_50__ATBOOT_4098),%a0
    cmpal %d1,%a0
    jbne rsrc_DRVR_50__ATBOOT_421A_70
    lea %pc@(rsrc_DRVR_50__ATBOOT_3F1C),%a1
    movew #11,%d1
rsrc_DRVR_50__ATBOOT_421A_52:  /* loop: tst */
    tstb %a1@(0x0,%d1:w)
    dbeq %d1,rsrc_DRVR_50__ATBOOT_421A_52
    jbne rsrc_DRVR_50__ATBOOT_421A_6C
    moveb %d3,%a1@(0x0,%d1:w)
    clrb %a1@(0xc,%d1:w)
    lslw #2,%d1
    clrl %a1@(0x18,%d1:w)
    jbra rsrc_DRVR_50__ATBOOT_421A_70
rsrc_DRVR_50__ATBOOT_421A_6C:  /* set %d0 */
    movew #-91,%d0
rsrc_DRVR_50__ATBOOT_421A_70:  /* from here: addaw #50,%sp */
    addaw #50,%sp
    jmp %pc@(rsrc_DRVR_50__ATBOOT_3FF0_28)

/* subroutine (31 instructions): traps Control, HUnlock, RecoverHandle; calls rsrc_DRVR_50__ATBOOT_3FF0, rsrc_DRVR_50__ATBOOT_41FA_10, rsrc_DRVR_50__ATBOOT_3FF0_30 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_4292:
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3FF0)
    movel %sp@+,%d2
    movew %sp@+,%d0
    movel %d3,%sp@-
    moveb %d0,%d3
    subaw #50,%sp
    moveal %sp,%a0
    moveb %d3,%a0@(28)
    movew #247,%a0@(26)
    movew #-10,%a0@(24)
    _Control
    addaw #50,%sp
    tstb %d0
    jbne rsrc_DRVR_50__ATBOOT_4292_5C
    jsr %pc@(rsrc_DRVR_50__ATBOOT_41FA_10)
    jbne rsrc_DRVR_50__ATBOOT_4292_5C
    clrb %a1@(0x0,%d1:w)
    clrb %a1@(0xc,%d1:w)
    lslw #2,%d1
    moveal %a1@(0x18,%d1:w),%a0
    clrl %a1@(0x18,%d1:w)
    moveal %a0,%a1
rsrc_DRVR_50__ATBOOT_4292_46:  /* set up and call _HUnlock (loop) */
    movel %a1,%d0
    jbeq rsrc_DRVR_50__ATBOOT_4292_5C
    moveal %a1@(4),%a0
    _HUnlock
    moveal %a1,%a0
    .short  0xA128	| 40856844 _RecoverHandle (flags 0x0100)
    moveal %a1@,%a1
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3FF0_30)
    jbra rsrc_DRVR_50__ATBOOT_4292_46
rsrc_DRVR_50__ATBOOT_4292_5C:  /* jump through %pc@(rsrc_DRVR_50__ATBOOT_3FF0_28) */
    jmp %pc@(rsrc_DRVR_50__ATBOOT_3FF0_28)

/* subroutine (38 instructions): calls rsrc_DRVR_50__ATBOOT_3FF0 (mechanical summary) */
rsrc_DRVR_50__ATBOOT_42F2:
    jsr %pc@(rsrc_DRVR_50__ATBOOT_3FF0)
    lea %sp@(12),%a0
    movew #-3104,%d2
    movew %a0@+,%d1
    jbeq rsrc_DRVR_50__ATBOOT_42F2_56
    cmpw %a0@+,%d1
    jbhi rsrc_DRVR_50__ATBOOT_42F2_56
    moveal %a0@,%a1
rsrc_DRVR_50__ATBOOT_42F2_16:  /* loop: subq */
    subqw #1,%d1
    jbeq rsrc_DRVR_50__ATBOOT_42F2_2E
    addqw #5,%a1
    clrw %d2
    moveb %a1@,%d2
    addb %a1@(0x1,%d2:w),%d2
    addb %a1@(0x2,%d2:w),%d2
    addqb #3,%d2
    addaw %d2,%a1
    jbra rsrc_DRVR_50__ATBOOT_42F2_16
rsrc_DRVR_50__ATBOOT_42F2_2E:  /* set %a0 */
    moveal %sp@(4),%a0
    moveb %a1@+,%a0@+
    moveb %a1@+,%a0@+
    moveb %a1@+,%a0@+
    moveb %a1@+,%a0@+
    addqw #1,%a1
    moveq #3,%d2
    movel %sp@(8),%d0
rsrc_DRVR_50__ATBOOT_42F2_42:  /* loop: movea */
    moveal %d0,%a0
    moveb %a1@,%d1
rsrc_DRVR_50__ATBOOT_42F2_46:  /* loop: move */
    moveb %a1@+,%a0@+
    subqb #1,%d1
    jbcc rsrc_DRVR_50__ATBOOT_42F2_46
    addil #34,%d0
    subqw #1,%d2
    jbne rsrc_DRVR_50__ATBOOT_42F2_42
rsrc_DRVR_50__ATBOOT_42F2_56:  /* set %a1 */
    moveal %sp@+,%a1
    addaw #16,%sp
    movew %d2,%sp@
    jmp %a1@

/* subroutine (16 instructions) (mechanical summary) */
rsrc_DRVR_50__ATBOOT_4352:
    linkw %fp,#0
    moveml %d6-%d7/%a3-%a4,%sp@-
    movel %fp@(16),%d6
    movel %fp@(12),%d7
    moveal %fp@(8),%a4
    moveal %a4,%a3
    jbra rsrc_DRVR_50__ATBOOT_4352_1A
rsrc_DRVR_50__ATBOOT_4352_18:  /* loop: move */
    moveb %d7,%a4@+
rsrc_DRVR_50__ATBOOT_4352_1A:  /* set %d0 */
    movel %d6,%d0
    subql #1,%d6
    tstl %d0
    jbhi rsrc_DRVR_50__ATBOOT_4352_18
    movel %a3,%d0
    moveml %fp@(-16),%d6-%d7/%a3-%a4
    unlk %fp
    rts
    .byte   0x86	| 408568E0
    .ascii  "memset\000"
    .long   0x00000000, 0x00000000	| 408568E8
