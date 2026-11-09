/* ROM resource 'DRVR' 51 ".EDisk": map entry at 0x408E74D0, data at 0x408E7500, 2704 bytes

 The .EDisk driver ('DRVR' 51): a RAM disk (a part of memory used as a volume, e.g. on
 machines that can keep RAM powered). Open adds the drive (AddDrive) and a VBL task;
 Prime copies blocks between the disk's memory and the caller's buffer (BlockMove).
 Control and Status calls are found in csCode tables (rsrc_DRVR_51__EDisk_2A,
 rsrc_DRVR_51__EDisk_1A): Control 1 KillIO, 5 verify, 6 format, 7 eject, 21 drive icon,
 22 media icon, 23 drive information; Status 6 format list, 8 drive status, 'ED' (its own
 information). Comments inferred from the code and the standard disk driver csCodes.
*/

rsrc_DRVR_51__EDisk_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 408E74D0
    .long   rsrc_free_4_Main_entry-rom_start	| 408E74D8
    .long   rsrc_DRVR_51__EDisk-rom_start	| 408E74DC
    .ascii  "DRVR"	| 408E74E0
    .byte   0x00, 0x33, 0x58	| 408E74E4
    .byte   6	/* 408E74E7 Pascal string length */
    .ascii  ".EDisk"	| 408E74E8
    FILL_408E74EE
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x0A, 0x9C, 0x00, 0x00, 0x02, 0x8C	| 408E74F4

/* subroutine (0 instructions): low memory EDisk (mechanical summary) */
rsrc_DRVR_51__EDisk:
    .byte   0x4F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408E7500
rsrc_DRVR_51__EDisk_8:  /* (data) */
    .short  rsrc_DRVR_51__EDisk_open-rsrc_DRVR_51__EDisk	| 408E7508
    .short  rsrc_DRVR_51__EDisk_prime-rsrc_DRVR_51__EDisk	| 408E750A
    .short  rsrc_DRVR_51__EDisk_ctl-rsrc_DRVR_51__EDisk	| 408E750C
    .short  rsrc_DRVR_51__EDisk_status-rsrc_DRVR_51__EDisk	| 408E750E
    .short  rsrc_DRVR_51__EDisk_close-rsrc_DRVR_51__EDisk	| 408E7510
    .byte   0x06	| 408E7512
    .ascii  ".EDisk\000"
rsrc_DRVR_51__EDisk_1A:  /* (data) */
    .short  rsrc_DRVR_51__EDisk_status_114-.-4, 0x0006	| 408E751A
    .short  rsrc_DRVR_51__EDisk_status_134-.-4, 0x0008	| 408E751E
    .short  rsrc_DRVR_51__EDisk_status_146-.-4, 0x4544	| 408E7522
    .byte   0xFF, 0xFF, 0xFF, 0xEE	| 408E7526
rsrc_DRVR_51__EDisk_2A:  /* (data) */
    .short  rsrc_DRVR_51__EDisk_status_28-.-4, 0x0001	| 408E752A
    .short  rsrc_DRVR_51__EDisk_status_D2-.-4, 0x0005	| 408E752E
    .short  rsrc_DRVR_51__EDisk_status_50-.-4, 0x0006	| 408E7532
    .short  rsrc_DRVR_51__EDisk_status_32-.-4, 0x0007	| 408E7536
    .short  rsrc_DRVR_51__EDisk_status_156-.-4, 0x0015	| 408E753A
    .short  rsrc_DRVR_51__EDisk_status_15C-.-4, 0x0016	| 408E753E
    .short  rsrc_DRVR_51__EDisk_status_14C-.-4, 0x0017	| 408E7542
    .byte   0xFF, 0xFF, 0xFF, 0xEF	| 408E7546
rsrc_DRVR_51__EDisk_4A:  /* (data) */
    .short  0x0000, 0x0000, 0x0598	| 408E754A
    .long   0x0860085E, 0x084A0000, 0x84100248, 0x00000000	| 408E7550
    .short  0x05CA, 0x084E, 0x084C, 0x0826, 0x0000, 0x0411, 0x0208	| 408E7560
rsrc_DRVR_51__EDisk_6E:  /* (data) */
    .short  0x0000	| 408E756E
    .long   0x000005B8, 0x083C083A, 0x08140000, 0x0C110208	| 408E7570

/* Open: variables, the RAM disk's memory, the drive queue element, a VBL task. */
rsrc_DRVR_51__EDisk_open:
    jsr %pc@(rsrc_DRVR_51__EDisk_864)
    movel %a0,%sp@-
    movel %a1@(24),%d7
    movew #5,%d7
    movel DrvQHdr_Head,%d0
    jbeq rsrc_DRVR_51__EDisk_open_24
rsrc_DRVR_51__EDisk_open_14:  /* loop: movea */
    moveal %d0,%a0
    cmpw %a0@(6),%d7
    jbcc rsrc_DRVR_51__EDisk_open_20
    movew %a0@(6),%d7
rsrc_DRVR_51__EDisk_open_20:  /* set %d0 */
    movel %a0@,%d0
    jbne rsrc_DRVR_51__EDisk_open_14
rsrc_DRVR_51__EDisk_open_24:  /* add 1 to %d7 */
    addqw #1,%d7
    lea %pc@(rsrc_DRVR_51__EDisk_4A),%fp
    moveb MMU32Bit,%sp@-
    moveq #1,%d0
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(JSwapMMU,%za0)@(0)	| 408E75B0
    moveal 0xddc,%a2
    movel %a2@(-74),%d2
    movel %d2,%d3
    addl %a2@(-70),%d3
    moveb %sp@+,%d0
    jsr @(JSwapMMU,%za0)@(0)	| 408E75C6
    subal %a2,%a2
    movel %d2,%d1
    moveq #0,%d2
    cmpl %d1,%d3
    bsrw rsrc_DRVR_51__EDisk_154
    moveal ROMBase,%a2
rsrc_DRVR_51__EDisk_open_5C:  /* call rsrc_DRVR_51__EDisk_1C0 (loop) */
    jbsr rsrc_DRVR_51__EDisk_1C0
    jbne rsrc_DRVR_51__EDisk_open_6E
    moveq #0,%d1
    movel %a2,%d2
    movel %a2,%d3
    jbsr rsrc_DRVR_51__EDisk_154
    lea %pc@(rsrc_DRVR_51__EDisk_6E),%fp
rsrc_DRVR_51__EDisk_open_6E:  /* from here: addal #65536,%a2 */
    addal #65536,%a2
    cmpal #14680064,%a2
    jbcs rsrc_DRVR_51__EDisk_open_5C
    moveq #-23,%d0
    swap %d7
    lea DrvQHdr_Head,%a0
rsrc_DRVR_51__EDisk_open_84:  /* loop: move */
    movel %a0@,%d1
    jbeq rsrc_DRVR_51__EDisk_open_CC
    moveal %d1,%a0
    cmpw %a0@(8),%d7
    jbne rsrc_DRVR_51__EDisk_open_84
    movel #320,%d0
    .short  0xA71E	| 408E7616 _NewPtr (flags 0x0700)
    moveal %a0,%a2
    movel %a2,%a1@(20)
    movel %a1,%a2@(12)
    movew %pc@(rsrc_DRVR_51__EDisk_open_D2),%a2@
    movew %pc@(rsrc_DRVR_51__EDisk_open_D2),%a2@(6)
    lea %pc@(rsrc_DRVR_51__EDisk_644),%a4
    moveq #7,%d4
rsrc_DRVR_51__EDisk_open_B2:  /* loop: lea */
    lea %a2@(18),%a0
    jsr %a4@
    dbf %d4,rsrc_DRVR_51__EDisk_open_B2
    lea %a2@(18),%a0
    addqw #1,%a0@(4)
    movel %a4,%a0@(6)
    _VInstall
    moveq #0,%d0
rsrc_DRVR_51__EDisk_open_CC:  /* set %a0 */
    moveal %sp@+,%a0
    movew %d0,%a0@(16)
rsrc_DRVR_51__EDisk_open_D2:  /* return */
    rts

/* AddDrive: a drive queue element for the RAM disk. */
rsrc_DRVR_51__EDisk_154:
    jbeq rsrc_DRVR_51__EDisk_154_64
    moveq #76,%d0
    .short  0xA71E	| 408E7658 _NewPtr (flags 0x0700)
    jbne rsrc_DRVR_51__EDisk_154_64
    addaw #60,%a0
    moveal %fp,%a3
    movel %a3@+,%a0@(-60)
    moveaw %a3@+,%a4
    addal %a3,%a4
    movel %a4,%a0@(-56)
    movel %a2,%a0@(-52)
    movel %d1,%a0@(-40)
    movel %d2,%a0@(-36)
    movel %d3,%a0@(-32)
    moveaw %a3@+,%a4
    addal %a3,%a4
    movel %a4,%a0@(-28)
    moveaw %a3@+,%a4
    addal %a3,%a4
    movel %a4,%a0@(-24)
    moveaw %a3@+,%a4
    addal %a3,%a4
    movel %a4,%a0@(-20)
    movel %a3@+,%a0@(-16)
    movew %a3@+,%a0@(-12)
    moveb #85,%a0@(-10)
    subl %d1,%d3
    movel %d3,%a0@(-8)
    addqw #1,%a0@(4)
    addqw #1,%a0@(-2)
    movel %d7,%d0
    swap %d0
    _AddDrive
rsrc_DRVR_51__EDisk_154_64:  /* add 1 to %d7 */
    addqw #1,%d7
    lea %fp@(18),%fp
    rts

/* subroutine (34 instructions): low memory BusErrorVector (mechanical summary) */
rsrc_DRVR_51__EDisk_1C0:
    movew %sr,%sp@-
    oriw #1792,%sr
    movel BusErrorVector,%sp@-
    lea %pc@(rsrc_DRVR_51__EDisk_1C0_24),%a0
    movel %a0,BusErrorVector
    moveal %sp,%a4
    lea %pc@(rsrc_DRVR_51__EDisk_86C),%a3
    lea %a2@(128),%a0
    moveq #3,%d0
rsrc_DRVR_51__EDisk_1C0_1E:  /* loop: cmpm */
    cmpml %a0@+,%a3@+
    dbne %d0,rsrc_DRVR_51__EDisk_1C0_1E
rsrc_DRVR_51__EDisk_1C0_24:  /* set %sp */
    moveal %a4,%sp
    movel %sp@+,BusErrorVector
    movew %sp@+,%sr
    addqw #1,%d0
    jbne rsrc_DRVR_51__EDisk_1C0_5C
    movel %d7,%d1
    swap %d1
    lea DrvQHdr_Head,%a0
rsrc_DRVR_51__EDisk_1C0_38:  /* loop: move */
    movel %a0@,%d0
    jbeq rsrc_DRVR_51__EDisk_1C0_5C
    moveal %d0,%a0
    cmpw %a0@(8),%d1
    jbne rsrc_DRVR_51__EDisk_1C0_38
    cmpib #17,%a0@(-13)
    jbne rsrc_DRVR_51__EDisk_1C0_38
    moveq #127,%d0
    moveal %a2,%a3
    moveal %a0@(-52),%a4
rsrc_DRVR_51__EDisk_1C0_54:  /* loop: cmpm */
    cmpml %a3@+,%a4@+
    dbne %d0,rsrc_DRVR_51__EDisk_1C0_54
    jbne rsrc_DRVR_51__EDisk_1C0_38
rsrc_DRVR_51__EDisk_1C0_5C:  /* test %d0 */
    tstl %d0
    rts

/* Close: nothing to undo (the disk stays). */
rsrc_DRVR_51__EDisk_close:
    moveq #-24,%d0
    rts

/* Prime: read or write blocks (BlockMove between the disk's memory and the buffer). */
rsrc_DRVR_51__EDisk_prime:
    jsr %pc@(rsrc_DRVR_51__EDisk_864)
    movew %a0@(6),%sp@-
    moveq #0,%d4
    moveml %d4/%a0-%a1,%sp@-
    jbsr rsrc_DRVR_51__EDisk_572
    jbne rsrc_DRVR_51__EDisk_prime_C4
    moveq #-50,%d0
    movel %a0@(36),%d1
    jbeq rsrc_DRVR_51__EDisk_prime_C4
    movel %a1@(16),%d2
    moveml %a3@(-40),%a4-%fp
    addal %d2,%a5
    subal %a5,%fp
    cmpal %d1,%fp
    jblt rsrc_DRVR_51__EDisk_prime_C4
    movel %d1,%d7
    orl %d2,%d7
    andiw #511,%d7
    jbne rsrc_DRVR_51__EDisk_prime_C4
    movel %a0@(32),%d6
    moveq #64,%d7
    andw %a0@(44),%d7
    sne %d7
    negb %d7
    movel %d6,%d0
    _StripAddress
    cmpib #3,%a0@(7)
    moveal %a5,%a0
    moveal %d0,%a1
    jbne rsrc_DRVR_51__EDisk_prime_70
    moveq #2,%d7
    exg %a0,%a1
    moveq #-44,%d0
    tstb %a3@(-4)
    jbmi rsrc_DRVR_51__EDisk_prime_C4
    moveq #2,%d0
    jbsr rsrc_DRVR_51__EDisk_5E2
rsrc_DRVR_51__EDisk_prime_70:  /* from here: roxrb #1,%d6 */
    roxrb #1,%d6
    addxb %d7,%d7
    movel %a4,%d6
    subql #1,%d6
    roxlw #2,%d7
    lsrl #7,%d2
    addal %d2,%a4
    lea %pc@(rsrc_DRVR_51__EDisk_3BA),%a5
    addaw %a5@(0x0,%d7:w),%a5
    jsr %a2@(6)
    movel #512,%d3
    moveb MMU32Bit,%sp@-
    moveml %d1/%a0,%sp@-
    moveq #1,%d0
    jsr @(JSwapMMU,%za0)@(0)	| 408E77BE
    moveml %sp@+,%d1/%a0
rsrc_DRVR_51__EDisk_prime_A4:  /* loop: moveq */
    moveq #0,%d5
    moveq #127,%d2
    jmp %a5@
rsrc_DRVR_51__EDisk_prime_AA:  /* loop: add */
    addl %d3,%d4
    subl %d3,%d1
    jbhi rsrc_DRVR_51__EDisk_prime_A4
rsrc_DRVR_51__EDisk_prime_B0:  /* loop: moveq */
    moveq #0,%d0
rsrc_DRVR_51__EDisk_prime_B2:  /* loop: move */
    movel %d0,%d2
    moveb %sp@+,%d0
    jsr @(JSwapMMU,%za0)@(0)	| 408E77DA
    moveq #3,%d0
    jbsr rsrc_DRVR_51__EDisk_5E2
    movel %d2,%d0
rsrc_DRVR_51__EDisk_prime_C4:  /* restore registers */
    moveml %sp@+,%d1/%a0-%a1
    movel %d4,%a0@(40)
    addl %d4,%a1@(16)
    jbra rsrc_DRVR_51__EDisk_5C6

/* subroutine (4 instructions): traps BlockMove (mechanical summary) */
rsrc_DRVR_51__EDisk_prime_D4:
    movel %d1,%d0	| 408E77F8
    _BlockMove	| 408E77FA
    movel %d1,%d4	| 408E77FC
    jbra rsrc_DRVR_51__EDisk_prime_B0	| 408E77FE

/* subroutine (14 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_prime_DC:
    moveq #63,%d2	| 408E7800
rsrc_DRVR_51__EDisk_prime_DE:  /* loop: move */
    movel %a0@+,%d7	| 408E7802
    addl %d5,%d5	| 408E7804
    addxl %d7,%d5	| 408E7806
    movel %d7,%a1@+	| 408E7808
    movel %a0@+,%d7	| 408E780A
    addl %d5,%d5	| 408E780C
    addxl %d7,%d5	| 408E780E
    movel %d7,%a1@+	| 408E7810
    dbf %d2,rsrc_DRVR_51__EDisk_prime_DE	| 408E7812
rsrc_DRVR_51__EDisk_prime_F2:  /* loop: cmp */
    cmpl %a4@+,%d5
    jbeq rsrc_DRVR_51__EDisk_prime_AA
    moveq #-72,%d0
    jbra rsrc_DRVR_51__EDisk_prime_B2

/* subroutine (12 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_prime_FA:
    subql #3,%a1	| 408E781E
    movel %a1@,%d7	| 408E7820
    addql #6,%a5	| 408E7822
rsrc_DRVR_51__EDisk_prime_100:  /* loop: move */
    movel %a0@+,%d6	| 408E7824
    addl %d5,%d5	| 408E7826
    addxl %d6,%d5	| 408E7828
    roll #8,%d6	| 408E782A
    moveb %d6,%d7	| 408E782C
    movel %d7,%a1@+	| 408E782E
    movel %d6,%d7	| 408E7830
    dbf %d2,rsrc_DRVR_51__EDisk_prime_100	| 408E7832
    moveb %a1@(3),%d7	| 408E7836
    movel %d7,%a1@
    jbra rsrc_DRVR_51__EDisk_prime_F2

/* subroutine (1 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_prime_11A:
    lea %sp@(2),%a4	| 408E783E

/* subroutine (8 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_prime_11E:
    movel %a0@+,%d7	| 408E7842
    addl %d5,%d5	| 408E7844
    addxl %d7,%d5	| 408E7846
    cmpl %a1@+,%d7	| 408E7848
    dbne %d2,rsrc_DRVR_51__EDisk_prime_11E	| 408E784A
    jbeq rsrc_DRVR_51__EDisk_prime_158	| 408E784E
rsrc_DRVR_51__EDisk_prime_12C:  /* result -68 */
    moveq #-68,%d0
    jbra rsrc_DRVR_51__EDisk_prime_B2

/* subroutine (5 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_prime_130:
    lea %pc@(rsrc_DRVR_51__EDisk_prime_144),%a5	| 408E7854
rsrc_DRVR_51__EDisk_prime_134:  /* loop: subq */
    subql #1,%a1	| 408E7858
    movel %a1@+,%d6	| 408E785A
    roll #8,%d6	| 408E785C
    jmp %a5@	| 408E785E

/* subroutine (11 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_prime_13C:
    addql #4,%a5	| 408E7860
    jbra rsrc_DRVR_51__EDisk_prime_134	| 408E7862
    .byte   0x49, 0xEF, 0x00, 0x02	| 408E7864
rsrc_DRVR_51__EDisk_prime_144:  /* loop: move */
    movel %d6,%d7	| 408E7868
    movel %a1@+,%d6	| 408E786A
    roll #8,%d6	| 408E786C
    moveb %d6,%d7	| 408E786E
    addl %d5,%d5	| 408E7870
    addxl %d7,%d5	| 408E7872
    cmpl %a0@+,%d7	| 408E7874
    dbne %d2,rsrc_DRVR_51__EDisk_prime_144	| 408E7876
    jbne rsrc_DRVR_51__EDisk_prime_12C	| 408E787A
rsrc_DRVR_51__EDisk_prime_158:  /* (data) */
    movel %d5,%sp@(2)	| 408E787C
    bras rsrc_DRVR_51__EDisk_prime_F2

/* subroutine (12 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_prime_15E:
    moveq #63,%d2
rsrc_DRVR_51__EDisk_prime_160:  /* loop: move */
    movel %a0@+,%d7
    addl %d5,%d5
    addxl %d7,%d5
    movel %d7,%a1@+
    movel %a0@+,%d7
    addl %d5,%d5
    addxl %d7,%d5
    movel %d7,%a1@+
    dbf %d2,rsrc_DRVR_51__EDisk_prime_160
rsrc_DRVR_51__EDisk_prime_174:  /* loop: move */
    movel %d5,%a4@+
    jbra rsrc_DRVR_51__EDisk_prime_AA

/* subroutine (13 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_prime_17A:
    subql #1,%a0	| 408E789E
    movel %a0@+,%d7	| 408E78A0
    roll #8,%d7	| 408E78A2
    addql #8,%a5	| 408E78A4
rsrc_DRVR_51__EDisk_prime_182:  /* loop: move */
    movel %a0@+,%d6	| 408E78A6
    roll #8,%d6	| 408E78A8
    moveb %d6,%d7	| 408E78AA
    addl %d5,%d5	| 408E78AC
    addxl %d7,%d5	| 408E78AE
    movel %d7,%a1@+	| 408E78B0
    movel %d6,%d7	| 408E78B2
    dbf %d2,rsrc_DRVR_51__EDisk_prime_182	| 408E78B4
    jbra rsrc_DRVR_51__EDisk_prime_174	| 408E78B8
rsrc_DRVR_51__EDisk_3BA:  /* (data) */
    .short  rsrc_DRVR_51__EDisk_prime_DC-rsrc_DRVR_51__EDisk_3BA	| 408E78BA
    .short  rsrc_DRVR_51__EDisk_prime_D4-rsrc_DRVR_51__EDisk_3BA	| 408E78BC
    .short  rsrc_DRVR_51__EDisk_prime_FA-rsrc_DRVR_51__EDisk_3BA	| 408E78BE
    .short  rsrc_DRVR_51__EDisk_prime_D4-rsrc_DRVR_51__EDisk_3BA	| 408E78C0
    .short  rsrc_DRVR_51__EDisk_prime_11E-rsrc_DRVR_51__EDisk_3BA	| 408E78C2
    .short  rsrc_DRVR_51__EDisk_prime_11A-rsrc_DRVR_51__EDisk_3BA	| 408E78C4
    .short  rsrc_DRVR_51__EDisk_prime_130-rsrc_DRVR_51__EDisk_3BA	| 408E78C6
    .short  rsrc_DRVR_51__EDisk_prime_13C-rsrc_DRVR_51__EDisk_3BA	| 408E78C8
    .short  rsrc_DRVR_51__EDisk_prime_15E-rsrc_DRVR_51__EDisk_3BA	| 408E78CA
    .short  rsrc_DRVR_51__EDisk_prime_D4-rsrc_DRVR_51__EDisk_3BA	| 408E78CC
    .short  rsrc_DRVR_51__EDisk_prime_17A-rsrc_DRVR_51__EDisk_3BA	| 408E78CE
    .short  rsrc_DRVR_51__EDisk_prime_D4-rsrc_DRVR_51__EDisk_3BA	| 408E78D0

/* Control: dispatch by csCode (rsrc_DRVR_51__EDisk_2A). */
rsrc_DRVR_51__EDisk_ctl:
    jsr %pc@(rsrc_DRVR_51__EDisk_864)
    lea %pc@(rsrc_DRVR_51__EDisk_2A),%a2
    jbra rsrc_DRVR_51__EDisk_status_4

/* Status: dispatch by csCode (rsrc_DRVR_51__EDisk_1A). */
rsrc_DRVR_51__EDisk_status:
    lea %pc@(rsrc_DRVR_51__EDisk_1A),%a2
rsrc_DRVR_51__EDisk_status_4:  /* set %sp@- */
    movew %a0@(6),%sp@-
    pea %pc@(rsrc_DRVR_51__EDisk_5C6)
    movew %a0@(26),%d1
rsrc_DRVR_51__EDisk_status_10:  /* loop: move */
    movel %a2@+,%d0
    jbmi rsrc_DRVR_51__EDisk_status_22
    cmpw %d0,%d1
    jbne rsrc_DRVR_51__EDisk_status_10
    swap %d0
    pea %a2@(0x0,%d0:w)
    jbra rsrc_DRVR_51__EDisk_572
rsrc_DRVR_51__EDisk_status_22:  /* continue at rsrc_DRVR_51__EDisk_9B2 */
    jbra rsrc_DRVR_51__EDisk_9B2
    .byte   0x00, 0x00	| 408E7902

/* subroutine (3 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_status_28:
    movew #512,%sp@(4)	| 408E7904
    moveq #-17,%d0	| 408E790A
    rts	| 408E790C

/* subroutine (11 instructions): calls rsrc_DRVR_51__EDisk_5E2 (mechanical summary) */
rsrc_DRVR_51__EDisk_status_32:
    movel %d1,%d0	| 408E790E
    jbne rsrc_DRVR_51__EDisk_status_4E	| 408E7910
    bclr #0,%a3@(-12)	| 408E7912
    moveb %a3@(-3),%d0	| 408E7918
    jble rsrc_DRVR_51__EDisk_status_4C	| 408E791C
    subqb #8,%d0	| 408E791E
    jbeq rsrc_DRVR_51__EDisk_status_4C	| 408E7920
    moveq #4,%d0
    jbsr rsrc_DRVR_51__EDisk_5E2
rsrc_DRVR_51__EDisk_status_4C:  /* clear %d0 */
    moveq #0,%d0
rsrc_DRVR_51__EDisk_status_4E:  /* return */
    rts

/* subroutine (47 instructions): traps StripAddress, Dequeue; calls rsrc_DRVR_51__EDisk_5E2, rsrc_DRVR_51__EDisk_816 (mechanical summary) */
rsrc_DRVR_51__EDisk_status_50:
    bnew rsrc_DRVR_51__EDisk_status_D0	| 408E792C
    moveq #2,%d0	| 408E7930
    jbsr rsrc_DRVR_51__EDisk_5E2	| 408E7932
    movel %a4,%d0	| 408E7936
    _StripAddress	| 408E7938
    moveal %d0,%a4	| 408E793A
    moveb MMU32Bit,%sp@-	| 408E793C
    moveq #1,%d0	| 408E7940
    jsr @(JSwapMMU,%za0)@(0)	| 408E7942
    moveq #-50,%d0	| 408E7948
    movew %a4@,%d1	| 408E794A
    subqw #1,%d1	| 408E794C
    jbls rsrc_DRVR_51__EDisk_status_8C	| 408E794E
    addqw #2,%d1	| 408E7950
    jbne rsrc_DRVR_51__EDisk_status_BE	| 408E7952
    cmpib #16,%a3@(-13)	| 408E7954
    jbne rsrc_DRVR_51__EDisk_status_BE	| 408E795A
    lea DrvQHdr,%a1	| 408E795C
    moveal %a3,%a0	| 408E7960
    _Dequeue	| 408E7962
    moveq #0,%d6
    jbra rsrc_DRVR_51__EDisk_status_9A
rsrc_DRVR_51__EDisk_status_8C:  /* set %d0 */
    moveq #-44,%d0	| 408E7968
    tstb %a3@(-4)	| 408E796A
    jbmi rsrc_DRVR_51__EDisk_status_BE	| 408E796E
    jbsr rsrc_DRVR_51__EDisk_816
    moveq #0,%d6
rsrc_DRVR_51__EDisk_status_9A:  /* set %a0-%a1/%a4 */
    moveml %a3@(-40),%a0-%a1/%a4
    movel %a0,%d2
    jbne rsrc_DRVR_51__EDisk_status_A6
    moveal %a1,%a0
rsrc_DRVR_51__EDisk_status_A6:  /* clear %d0 */
    moveq #0,%d0
    tstl %d6
    jbeq rsrc_DRVR_51__EDisk_status_BA
    moveq #-82,%d0
    jbra rsrc_DRVR_51__EDisk_status_BE
rsrc_DRVR_51__EDisk_status_B0:  /* loop: moveq */
    moveq #127,%d1
rsrc_DRVR_51__EDisk_status_B2:  /* loop: move */
    movel %d0,%a1@+
    dbf %d1,rsrc_DRVR_51__EDisk_status_B2
    movel %d0,%a0@+
rsrc_DRVR_51__EDisk_status_BA:  /* test %a1,%a4 */
    cmpal %a1,%a4
    jbhi rsrc_DRVR_51__EDisk_status_B0
rsrc_DRVR_51__EDisk_status_BE:  /* set %d2 */
    movel %d0,%d2
    moveb %sp@+,%d0
    jsr @(JSwapMMU,%za0)@(0)	| 408E799E
    moveq #3,%d0
    jbsr rsrc_DRVR_51__EDisk_5E2
    movel %d2,%d0
rsrc_DRVR_51__EDisk_status_D0:  /* return */
    rts

/* subroutine (23 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_status_D2:
    movel %d0,%d2	| 408E79AE
    moveb MMU32Bit,%sp@-	| 408E79B0
    moveq #1,%d0	| 408E79B4
    jsr @(JSwapMMU,%za0)@(0)	| 408E79B6
    movel %d2,%d0	| 408E79BC
    jbne rsrc_DRVR_51__EDisk_status_106	| 408E79BE
    moveml %a3@(-40),%a0-%a1/%a4	| 408E79C0
    movel %a0,%d0	| 408E79C6
    jbeq rsrc_DRVR_51__EDisk_status_106	| 408E79C8
    moveq #0,%d0	| 408E79CA
rsrc_DRVR_51__EDisk_status_F0:  /* loop: cmpa */
    cmpal %a1,%a4	| 408E79CC
    jbls rsrc_DRVR_51__EDisk_status_106	| 408E79CE
    moveq #127,%d1	| 408E79D0
rsrc_DRVR_51__EDisk_status_F6:  /* loop: move */
    movel %a1@+,%d3	| 408E79D2
    addl %d0,%d0	| 408E79D4
    addxl %d3,%d0	| 408E79D6
    dbf %d1,rsrc_DRVR_51__EDisk_status_F6	| 408E79D8
    subl %a0@+,%d0	| 408E79DC
    jbeq rsrc_DRVR_51__EDisk_status_F0	| 408E79DE
    moveq #-84,%d0	| 408E79E0
rsrc_DRVR_51__EDisk_status_106:  /* set %d2 */
    movel %d0,%d2	| 408E79E2
    moveb %sp@+,%d0	| 408E79E4
    jsr @(JSwapMMU,%za0)@(0)	| 408E79E6
    movel %d2,%d0	| 408E79EC
    rts	| 408E79EE

/* subroutine (12 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_status_114:
    jbne rsrc_DRVR_51__EDisk_status_132
    moveq #-50,%d0
    tstw %a4@
    jble rsrc_DRVR_51__EDisk_status_132
    movew #1,%a4@+
    moveal %a4@,%a4
    movel %a3@(12),%d0
    swap %d0
    movel %d0,%a4@+
    movel #1073741824,%a4@
    moveq #0,%d0
rsrc_DRVR_51__EDisk_status_132:  /* return */
    rts

/* subroutine (8 instructions): traps BlockMove (mechanical summary) */
rsrc_DRVR_51__EDisk_status_134:
    movel %d1,%d0	| 408E7A10
    jbne rsrc_DRVR_51__EDisk_status_144	| 408E7A12
    moveal %a4,%a1	| 408E7A14
    clrw %a1@+	| 408E7A16
    lea %a3@(-4),%a0	| 408E7A18
    moveq #20,%d0	| 408E7A1C
    _BlockMove	| 408E7A1E
rsrc_DRVR_51__EDisk_status_144:  /* return */
    rts	| 408E7A20

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_status_146:
    movel %a3@(-8),%a4@	| 408E7A22
    rts	| 408E7A26

/* subroutine (4 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_status_14C:
    movel %d1,%d0	| 408E7A28
    jbne rsrc_DRVR_51__EDisk_status_154	| 408E7A2A
    movel %a3@(-16),%a4@	| 408E7A2C
rsrc_DRVR_51__EDisk_status_154:  /* return */
    rts	| 408E7A30

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_status_156:
    moveal %a3@(-24),%a0	| 408E7A32
    jbra rsrc_DRVR_51__EDisk_status_160	| 408E7A36

/* subroutine (22 instructions): traps BlockMove (mechanical summary) */
rsrc_DRVR_51__EDisk_status_15C:
    moveal %a3@(-28),%a0	| 408E7A38
rsrc_DRVR_51__EDisk_status_160:  /* set %d0 */
    movel %d1,%d0	| 408E7A3C
    jbne rsrc_DRVR_51__EDisk_status_194	| 408E7A3E
    moveq #-17,%d0	| 408E7A40
    movel %a0,%d1	| 408E7A42
    jbeq rsrc_DRVR_51__EDisk_status_194	| 408E7A44
    lea %a2@(32),%a1	| 408E7A46
    movel %a1,%a4@	| 408E7A4A
    movel #256,%d0	| 408E7A4C
    _BlockMove	| 408E7A52
    lea %a2@(288),%a1	| 408E7A54
    clrb %a1@	| 408E7A58
    movel %a3@(-20),%d1	| 408E7A5A
    jbeq rsrc_DRVR_51__EDisk_status_194	| 408E7A5E
    moveal %d1,%a0	| 408E7A60
    moveq #1,%d0	| 408E7A62
    addb %a0@,%d0	| 408E7A64
    cmpiw #32,%d0	| 408E7A66
    jbls rsrc_DRVR_51__EDisk_status_192	| 408E7A6A
    moveq #32,%d0	| 408E7A6C
rsrc_DRVR_51__EDisk_status_192:  /* (408E7A6E A-line trap) */
    _BlockMove	| 408E7A6E
rsrc_DRVR_51__EDisk_status_194:  /* return */
    rts	| 408E7A70

/* subroutine (33 instructions): traps StripAddress; calls rsrc_DRVR_51__EDisk_5E2 (mechanical summary) */
rsrc_DRVR_51__EDisk_572:
    moveal %a1@(20),%a2
    addqb #1,%a2@(16)
    jsr %a2@
    lea DrvQHdr_Head,%a3
    movew %a0@(22),%d2
    jbpl rsrc_DRVR_51__EDisk_572_16
    negw %d2
rsrc_DRVR_51__EDisk_572_16:  /* set up and call _StripAddress (loop) */
    movel %a3@,%d0
    jbeq rsrc_DRVR_51__EDisk_572_4E
    _StripAddress
    moveal %d0,%a3
    cmpw %a3@(6),%d2
    jbne rsrc_DRVR_51__EDisk_572_16
    movew %a1@(24),%d2
    cmpw %a3@(8),%d2
    jbne rsrc_DRVR_51__EDisk_572_16
    moveq #0,%d1
    tstb %a3@(-3)
    jble rsrc_DRVR_51__EDisk_572_4A
    moveq #0,%d0
    jbsr rsrc_DRVR_51__EDisk_5E2
    jbeq rsrc_DRVR_51__EDisk_572_4A
    movel %a0,%d0
    _StripAddress
    moveal %d0,%a0
    moveq #0,%d0
rsrc_DRVR_51__EDisk_572_44:  /* loop: lea */
    lea %a0@(28),%a4
    rts
rsrc_DRVR_51__EDisk_572_4A:  /* result -65 */
    moveq #-65,%d0
    jbra rsrc_DRVR_51__EDisk_572_44
rsrc_DRVR_51__EDisk_572_4E:  /* set %d1 */
    moveq #-56,%d1
    moveq #-56,%d0
    jbra rsrc_DRVR_51__EDisk_572_44

/* subroutine (9 instructions): low memory JIODone, DskErr (mechanical summary) */
rsrc_DRVR_51__EDisk_5C6:
    subqb #1,%a2@(16)
rsrc_DRVR_51__EDisk_5C6_4:  /* loop: movea */
    moveal %a2@(12),%a1
    btst #1,%sp@+
    jbne rsrc_DRVR_51__EDisk_5C6_12
    movel JIODone,%sp@-
rsrc_DRVR_51__EDisk_5C6_12:  /* from here: extl %d0 */
    extl %d0
    jbeq rsrc_DRVR_51__EDisk_5C6_1A
    movew %d0,DskErr
rsrc_DRVR_51__EDisk_5C6_1A:  /* return */
    rts

/* Address of a block in the RAM disk (checks the block number against its size). */
rsrc_DRVR_51__EDisk_5E2:
    movel %a3@(-56),%sp@-
    rts
    .short  0x103B, 0x0006	| moveb %pc@(408e7af0 <rsrc_DRVR_51__EDisk_5E2+0xe>,%d0:w),%d0
    .short  0x4EFB, 0x0002	| jmp %pc@(408e7af0 <rsrc_DRVR_51__EDisk_5E2+0xe>,%d0:w)
    .short  0x060A	| .short 0x060a
    .short  0x0C20, 0x3600	| cmpib #0,%a0@-
    moveq #-1,%d0
    rts
    moveq #0,%d0
    moveml %d1/%a0-%a1,%sp@-
    moveq #8,%d0
    moveal %a3@(-40),%a0
    subal %a1,%a1
    .short  0xA198	| 408E7B08 _HWPriv (flags 0x0100)
    moveml %sp@+,%d1/%a0-%a1
    rts

rsrc_DRVR_51__EDisk_610:  /* save registers */
    moveml %d1/%a0-%a1,%sp@-
    moveq #8,%d0
    moveal %a3@(-40),%a0
    moveaw #1,%a1
    .short  0xA198	| 408E7B1E _HWPriv (flags 0x0100)
    moveml %sp@+,%d1/%a0-%a1
    rts
    .byte   0x42, 0x2B, 0xFF, 0xFD, 0x4E, 0x75, 0x10, 0x3B, 0x00, 0x06, 0x4E, 0xFB, 0x00, 0x02, 0x06, 0x06	| 408E7B26
    .byte   0x08, 0x08, 0x0A, 0x00, 0x70, 0xFF, 0x4E, 0x75, 0x42, 0x2B, 0xFF, 0xFD, 0x4E, 0x75	| 408E7B36
rsrc_DRVR_51__EDisk_644:  /* address %a0@(-18) */
    lea %a0@(-18),%a2	| 408E7B44
    lea DrvQHdr_Head,%a3	| 408E7B48
    moveal %a2@(12),%a1	| 408E7B4C
    movew %a1@(24),%d3	| 408E7B50
    tstb %a2@(16)	| 408E7B54
    jbeq rsrc_DRVR_51__EDisk_668	| 408E7B58
    addqw #1,%a2@(28)	| 408E7B5A
    rts	| 408E7B5E
rsrc_DRVR_51__EDisk_660:  /* loop: movea */
    moveal %d2,%a3	| 408E7B60
    cmpw %a3@(8),%d3	| 408E7B62
    jbeq rsrc_DRVR_51__EDisk_674	| 408E7B66
rsrc_DRVR_51__EDisk_668:  /* loop: move */
    movel %a3@,%d2	| 408E7B68
    jbne rsrc_DRVR_51__EDisk_660	| 408E7B6A
    movew #17,%a2@(28)	| 408E7B6C
    rts	| 408E7B72
rsrc_DRVR_51__EDisk_674:  /* clear %d0 */
    moveq #0,%d0	| 408E7B74
    jbsr rsrc_DRVR_51__EDisk_5E2	| 408E7B76
    addqw #1,%d0	| 408E7B7A
    moveb %a3@(-10),%d1	| 408E7B7C
    addxb %d1,%d1	| 408E7B80
    moveb %d1,%a3@(-10)	| 408E7B82
    moveq #7,%d0	| 408E7B86
    andb %d0,%d1	| 408E7B88
    jbne rsrc_DRVR_51__EDisk_698	| 408E7B8A
    tstb %a3@(-3)	| 408E7B8C
    jbpl rsrc_DRVR_51__EDisk_668	| 408E7B90
    clrb %a3@(-3)	| 408E7B92
    jbra rsrc_DRVR_51__EDisk_668	| 408E7B96
rsrc_DRVR_51__EDisk_698:  /* test %d0,%d1 */
    cmpb %d0,%d1	| 408E7B98
    jbne rsrc_DRVR_51__EDisk_668	| 408E7B9A
    tstb %a3@(-3)	| 408E7B9C
    jbmi rsrc_DRVR_51__EDisk_668	| 408E7BA0
    jbeq rsrc_DRVR_51__EDisk_6C0	| 408E7BA2
rsrc_DRVR_51__EDisk_6A4:  /* loop: btst */
    btst #0,%a3@(-12)	| 408E7BA4
    jbne rsrc_DRVR_51__EDisk_668	| 408E7BAA
    moveq #7,%d0	| 408E7BAC
    moveal %d0,%a0	| 408E7BAE
    movew %a3@(6),%d0	| 408E7BB0
    _PostEvent	| 408E7BB4 408E7BB4 A-line trap
    jbne rsrc_DRVR_51__EDisk_668	| 408E7BB6
    bset #0,%a3@(-12)	| 408E7BB8
    jbra rsrc_DRVR_51__EDisk_668	| 408E7BBE
rsrc_DRVR_51__EDisk_6C0:  /* set %a3@(-3) */
    moveb %a3@(-11),%a3@(-3)	| 408E7BC0
    clrb %a3@(-4)	| 408E7BC6
    movel %a3@(-52),%d0	| 408E7BCA
    jbeq rsrc_DRVR_51__EDisk_70E	| 408E7BCE
    moveal %d0,%a0	| 408E7BD0
    movel %a0@(148),%a3@(-48)	| 408E7BD2
    movel %a0@(152),%a3@(-44)	| 408E7BD8
    moveq #1,%d0	| 408E7BDE
    jbsr rsrc_DRVR_51__EDisk_5E2	| 408E7BE0
    moveb %d0,%a3@(-4)	| 408E7BE4
    jbne rsrc_DRVR_51__EDisk_752	| 408E7BE8
    tstl %a3@(-60)	| 408E7BEA
    jbeq rsrc_DRVR_51__EDisk_70E	| 408E7BEE
    moveq #2,%d0	| 408E7BF0
    jbsr rsrc_DRVR_51__EDisk_5E2	| 408E7BF2
    jbsr rsrc_DRVR_51__EDisk_7A6	| 408E7BF6
    addl %a0,%d0	| 408E7BFA
    movel %d0,%a3@(-32)	| 408E7BFC
    lea %a0@(512),%a0	| 408E7C00
    movel %a0,%a3@(-40)	| 408E7C04
    moveq #3,%d0	| 408E7C08
    jbsr rsrc_DRVR_51__EDisk_5E2	| 408E7C0A
rsrc_DRVR_51__EDisk_70E:  /* set %d0-%d2 */
    moveml %a3@(-40),%d0-%d2	| 408E7C0E
    tstl %d0	| 408E7C14
    jbeq rsrc_DRVR_51__EDisk_71C	| 408E7C16
    movel %d0,%d1	| 408E7C18
    moveq #0,%d0	| 408E7C1A
rsrc_DRVR_51__EDisk_71C:  /* test bit 1 of %a3@(-12) */
    btst #1,%a3@(-12)	| 408E7C1C
    jbeq rsrc_DRVR_51__EDisk_738	| 408E7C22
    movel %d1,%d0	| 408E7C24
    subl %d2,%d1	| 408E7C26
    negl %d1	| 408E7C28
    addil #65535,%d1	| 408E7C2A
    lsrl #7,%d1	| 408E7C30
    andiw #-512,%d1	| 408E7C32
    addl %d0,%d1	| 408E7C36
rsrc_DRVR_51__EDisk_738:  /* loop: movem */
    moveml %d0-%d1,%a3@(-40)	| 408E7C38
rsrc_DRVR_51__EDisk_73E:  /* loop: su */
    subl %d1,%d2	| 408E7C3E
    jbcc rsrc_DRVR_51__EDisk_748	| 408E7C40
    movel %d1,%a3@(-32)	| 408E7C42
    moveq #0,%d2	| 408E7C46
rsrc_DRVR_51__EDisk_748:  /* from here: roll #7,%d2 */
    roll #7,%d2	| 408E7C48
    movel %d2,%a3@(12)	| 408E7C4A
    jbra rsrc_DRVR_51__EDisk_6A4	| 408E7C4E
rsrc_DRVR_51__EDisk_752:  /* set %d0 */
    movel %a0,%d0	| 408E7C52
    lea %pc@(rsrc_DRVR_51__EDisk_86C),%a1	| 408E7C54
    lea %a0@(128),%a0	| 408E7C58
    moveq #3,%d2	| 408E7C5C
rsrc_DRVR_51__EDisk_75E:  /* loop: cmpm */
    cmpml %a0@+,%a1@+	| 408E7C5E
    dbne %d2,rsrc_DRVR_51__EDisk_75E	| 408E7C60
    jbeq rsrc_DRVR_51__EDisk_76C	| 408E7C64
    movel %d0,%d1	| 408E7C66
    movel %d1,%d2	| 408E7C68
    jbra rsrc_DRVR_51__EDisk_738	| 408E7C6A
rsrc_DRVR_51__EDisk_76C:  /* set %d0 */
    movel %a0@+,%d0	| 408E7C6C
    addqw #8,%a0	| 408E7C6E
    lea %a3@(-40),%a1	| 408E7C70
    moveq #2,%d2	| 408E7C74
    tstl %a3@(-60)	| 408E7C76
    jbne rsrc_DRVR_51__EDisk_788	| 408E7C7A
    moveq #5,%d2	| 408E7C7C
    movel %a0@(24),%d1	| 408E7C7E
    jbeq rsrc_DRVR_51__EDisk_788	| 408E7C82
    movel %d1,%a3@(-16)	| 408E7C84
rsrc_DRVR_51__EDisk_788:  /* loop: addq */
    addql #4,%a1	| 408E7C88
    movel %a0@+,%d1	| 408E7C8A
    jbeq rsrc_DRVR_51__EDisk_79A	| 408E7C8C
    cmpl %d0,%d1	| 408E7C8E
    jbhi rsrc_DRVR_51__EDisk_79A	| 408E7C90
    addl %a3@(-52),%d1	| 408E7C92
    movel %d1,%a1@(-4)	| 408E7C96
rsrc_DRVR_51__EDisk_79A:  /* count down */
    dbf %d2,rsrc_DRVR_51__EDisk_788	| 408E7C9A
    moveml %a3@(-36),%d1-%d2	| 408E7C9E
    jbra rsrc_DRVR_51__EDisk_73E	| 408E7CA4

/* subroutine (38 instructions) (mechanical summary) */
rsrc_DRVR_51__EDisk_7A6:
    addal #2097152,%a0	| 408E7CA6
    moveal %a0,%a1	| 408E7CAC
    moveq #0,%d0	| 408E7CAE
    movel #1197568633,%d1	| 408E7CB0
    moveq #3,%d2	| 408E7CB6
rsrc_DRVR_51__EDisk_7B8:  /* loop: suba */
    subal #524288,%a0	| 408E7CB8
    movel %a0@,%sp@-	| 408E7CBE
    roll #8,%d1	| 408E7CC0
    movel %d1,%a0@	| 408E7CC2
    cmpl %a0@,%d1	| 408E7CC4
    jbne rsrc_DRVR_51__EDisk_7D4	| 408E7CC6
    notl %d1	| 408E7CC8
    movel %d1,%a0@	| 408E7CCA
    cmpl %a0@,%d1	| 408E7CCC
    jbne rsrc_DRVR_51__EDisk_7D2	| 408E7CCE
    bset %d2,%d0	| 408E7CD0
rsrc_DRVR_51__EDisk_7D2:  /* from here: notl %d1 */
    notl %d1	| 408E7CD2
rsrc_DRVR_51__EDisk_7D4:  /* count down */
    dbf %d2,rsrc_DRVR_51__EDisk_7B8	| 408E7CD4
    notl %d1	| 408E7CD8
    moveq #3,%d2	| 408E7CDA
rsrc_DRVR_51__EDisk_7DC:  /* loop: suba */
    subal #524288,%a1	| 408E7CDC
    roll #8,%d1	| 408E7CE2
    cmpl %a1@,%d1	| 408E7CE4
    jbeq rsrc_DRVR_51__EDisk_7EA	| 408E7CE6
    bclr %d2,%d0	| 408E7CE8
rsrc_DRVR_51__EDisk_7EA:  /* count down */
    dbf %d2,rsrc_DRVR_51__EDisk_7DC	| 408E7CEA
    moveq #3,%d2	| 408E7CEE
rsrc_DRVR_51__EDisk_7F0:  /* loop: move */
    movel %sp@+,%a1@	| 408E7CF0
    addal #524288,%a1	| 408E7CF2
    dbf %d2,rsrc_DRVR_51__EDisk_7F0	| 408E7CF8
    moveb %pc@(rsrc_DRVR_51__EDisk_806,%d0:w),%d0	| 408E7CFC
    moveq #19,%d1	| 408E7D00
    lsll %d1,%d0	| 408E7D02
    rts	| 408E7D04
rsrc_DRVR_51__EDisk_806:  /* from here: orib #2,%d1 */
    orib #2,%d1
    orib #3,%d0
    orib #0,%d0
    orib #4,%d0

/* subroutine (28 instructions): low memory Time, Ticks (mechanical summary) */
rsrc_DRVR_51__EDisk_816:
    movel %a3@(-52),%d0
    jbeq rsrc_DRVR_51__EDisk_816_4C
    moveal %d0,%a0
    moveq #127,%d3
rsrc_DRVR_51__EDisk_816_A:  /* loop: clr */
    clrl %a0@+
    dbf %d3,rsrc_DRVR_51__EDisk_816_A
    lea %pc@(rsrc_DRVR_51__EDisk_86C),%a1
    lea %a0@(-384),%a0
    moveq #3,%d3
rsrc_DRVR_51__EDisk_816_1A:  /* loop: move */
    movel %a1@+,%a0@+
    dbf %d3,rsrc_DRVR_51__EDisk_816_1A
    movel %a3@(-32),%d2
    subl %d0,%d2
    movel %d2,%a0@+
    lea %a3@(-48),%a1
    movel Time,%a1@
    movel %a1@+,%a0@+
    movel Ticks,%a1@
    movel %a1@+,%a0@+
    moveq #5,%d3
rsrc_DRVR_51__EDisk_816_3A:  /* loop: addq */
    addql #4,%a0
    movel %a1@+,%d1
    subl %d0,%d1
    cmpl %d1,%d2
    jbcs rsrc_DRVR_51__EDisk_816_48
    movel %d1,%a0@(-4)
rsrc_DRVR_51__EDisk_816_48:  /* count down */
    dbf %d3,rsrc_DRVR_51__EDisk_816_3A
rsrc_DRVR_51__EDisk_816_4C:  /* return */
    rts

/* subroutine (7 instructions): traps Translate24To32; low memory Lower, SLIM, Drive, Internal, Disk (mechanical summary) */
rsrc_DRVR_51__EDisk_864:
    movel %sp@,%d0
    _Translate24To32
    movel %d0,%sp@
    rts
rsrc_DRVR_51__EDisk_86C:  /* (data) */
    .long   0x02000001	| 408E7D6C
    .byte   0x45, 0x44, 0x69, 0x73, 0x6B, 0x20, 0x47, 0x61, 0x72, 0x79, 0x20, 0x44, 0x10	| 408E7D70
    .ascii  "Lower SLIM Drive\000"
    .byte   17	/* 408E7D8E Pascal string length */
    .ascii  "Internal ROM Disk"	| 408E7D8F
    .byte   17	/* 408E7DA0 Pascal string length */
    .ascii  "Internal RAM Disk"	| 408E7DA1
    .include "rsrc/icons/edisk.s"

rsrc_DRVR_51__EDisk_9B2:  /* set %a2 */
    moveal %a1@(20),%a2
    addql #4,%sp
    jbra rsrc_DRVR_51__EDisk_5C6_4
    .fill   0xD4, 1, 0x00
