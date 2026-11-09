/*
 hw/universal.s - universal ROM support: VIA init, hardware identification, machine features and tables
 From JUMPINTOROM (0x40802E00). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 The "universal" ROM supports many machines: at start-up it identifies the address
 decoder and the machine, then works from that machine's tables.
 ProductInfo record (one per machine, CHECKFORUNKNOWN_44E ... _84E below, pointer kept
 in UnivInfoPtr 0xDD8), fields as used by the code, offsets relative to the record:
   +0 decoder info (base addresses)  +4 RAM bank info  +8 video info
   +12 NuBus slot info  +16 hardware configuration word, machine kind, decoder kind
   +20 ROM85 value, default resources  +24 bases valid flags (to 0xDD0)
   +28 extended features flags  +32/+36 VIA ID mask and value (machine identification)
   +40 VIA 1 init table  +44 VIA 2 init table  +48 sound primitives
   +52 clock/PRAM primitives  +56 ADB primitives
 Decoder info (CHECKFORUNKNOWN_9A, _13E, _1E2, _284, _32A, _3CE): the base address of
 each piece of hardware (ROM 0x40800000, VIA 1 0x50F00000, SCC 0x50F04000, ...), then
 flags. Parts of the identification code are still raw words.
*/

/*
 JUMPINTOROM: early start-up: stack at 0x2600, vector table in ROM (VBR set 8 bytes
 below a ROM long that holds GOTBUSERROR, so the bus error vector points to it), then
 identify the machine (GETHARDWAREINFO, retried until it reports the decoder found)
 and continue in OPTIONALSPATCH_36.
*/
setup_early_vbr:
UNIVERSAL:
JUMPINTOROM:
    moveaw #9728,%sp
    moveal %fp,%a4
UNIVERSAL_6:            /* look back from GOTBUSERROR for a long that points to it */
    lea %pc@(GOTBUSERROR),%a0
    movel %a0,%d0
UNIVERSAL_C:            /* earlier long */
    cmpl %a0@-,%d0
    jbeq UNIVERSAL_1A
    tstl %a0@
    jbne UNIVERSAL_C
    lea BusErrorVector,%a0
    movel %d0,%a0@
UNIVERSAL_1A:           /* VBR = that long - 8 (bus error vector = GOTBUSERROR) */
    subqw #8,%a0
    movec %a0,%vbr
UNIVERSAL_20:           /* identify the hardware */
    moveq #0,%d2
    lea %pc@(UNIVERSAL_2A),%fp
    jmp %pc@(hardware_table_lookup)
UNIVERSAL_2A:           /* bit 0 of the bases valid flags (ROM): identified */
    btst #0,%d0
    jbeq UNIVERSAL_20
    lea %pc@(MYFIRSTPROC),%a2
    jmp %pc@(OPTIONALSPATCH_36)

/* SAVEPATCHRTN: return point of a patch: a4 += d3, continue d3 bytes further. */
SAVEPATCHRTN:
    addal %d3,%a4
    jmp %pc@(SAVEPATCHRTN_6,%d3:l)
SAVEPATCHRTN_6:         /* continue in SCSI96ANDRPUPATCH */
    nop
    nop
    jbra SCSI96ANDRPUPATCH_C

/*
 ROMBERRANDVBRRTN: more hardware set-up from the bases valid flags (d0): bit 18 sets a
 register of the device at decoder +72, bit 19 shifts a 16-bit value out to the device
 at decoder +76, one bit per write. Then MEMORYCTRLINITPATCH.
*/
ROMBERRANDVBRRTN:
    btst #18,%d0
    jbeq ROMBERRANDVBRRTN_10
    moveal %a0@(72),%a3
    moveb #13,%a3@(516)
ROMBERRANDVBRRTN_10:    /* bit 19: shift 0xF3FF out, 16 writes */
    btst #19,%d0
    jbeq ROMBERRANDVBRRTN_2C
    moveal %a0@(76),%a3
    movew #-3073,%d3
    moveq #15,%d4
ROMBERRANDVBRRTN_20:    /* one bit */
    moveb %d3,%a3@
    lsrw #1,%d3
    dbf %d4,ROMBERRANDVBRRTN_20
    moveb %d3,%a3@(16)
ROMBERRANDVBRRTN_2C:    /* memory controller set-up (the raw words after it: jmp (a4), zeros) */
    bral MEMORYCTRLINITPATCH
    .long   0x4ED40000, 0x00000000	| 40802E78
    .long   0x00000000, 0x00000000, 0x00000000	| 40802E80

/*
 INITVIAS: initialise VIA 1 (if bases valid bit 2) and VIA 2 (bit 11) from the
 machine's VIA init tables (ProductInfo +40 / +44): output registers, data directions,
 peripheral and auxiliary control registers, interrupts disabled. Bit 13: the RBV
 (VIA 2 replacement) instead. Returns through fp.
*/
INITVIAS:
    btst #2,%d0
    jbeq INITVIAS_3A
    moveal %a0@(8),%a2
    moveal %a1,%a3
    addal %a3@(40),%a3
    moveb %a3@+,%a2@(7680)
    moveb %a3@+,%a2@(1536)
    moveb #28,%a2@(5632)
    clrb %a2@(5120)
    moveb %a3@+,%a2@
    moveb %a3@+,%a2@(1024)
    moveb %a3@(-2),%a2@
    moveb %a3@+,%a2@(6144)
    moveb %a3@+,%a2@(5632)
    moveb #127,%a2@(7168)
INITVIAS_3A:            /* VIA 2 */
    btst #11,%d0
    jbeq INITVIAS_78
    moveal %a0@(44),%a2
    moveal %a1,%a3
    addal %a3@(44),%a3
    moveb %a2@(7680),%d3
    orb %a3@+,%d3
    moveb %d3,%a2@(7680)
    moveb %a3@+,%a2@(1536)
    moveb %a3@+,%a2@
    moveb %a3@+,%a2@(1024)
    moveb %a3@+,%a2@(6144)
    moveb %a3@+,%a2@(5632)
    moveb #127,%a2@(7168)
    moveb #110,%a2@(2048)
    moveb #25,%a2@(2560)
INITVIAS_78:            /* RBV: interrupts off, then its slot/monitor registers */
    btst #13,%d0
    jbeq INITVIAS_A6
    moveal %a0@(52),%a2
    moveb #127,%a2@(19)
    moveb #0x8f,%a2@
    btst #20,%d1
    jbeq INITVIAS_9A
    moveb #127,%a2@(18)
    jmp %fp@
INITVIAS_9A:            /* (bit 20 of the extended flags clear) */
    moveb #64,%a2@(16)
    moveb #0xff,%a2@(18)
INITVIAS_A6:            /* done */
    jmp %fp@

/*
 GETHARDWAREINFO: identify the machine. Through a patch (OPTIONALSPATCH_A4), then here:
 if d2 holds a machine type, take that ProductInfo, else try each decoder kind in turn
 (CHECKNEXTMAP) and match the machine by its VIA ID bits. Out: a0 = decoder info,
 a1 = ProductInfo, d0/d1 = valid flags, d2 = machine and decoder kind.
*/
hardware_table_lookup:
GETHARDWAREINFO:
    bral OPTIONALSPATCH_A4

GETHARDWARECONT:        /* machine type given in d2? */
    tstb %d2
GETHARDWARECONT_2:      /* no: identify the decoder */
    jbeq FOUNDMATCH_1C
    lea %pc@(CHECKFORUNKNOWN_22),%a0
GETHARDWARECONT_8:      /* find the ProductInfo whose machine kind (+18) = d2 */
    addqw #4,%a0
    movel %a0@,%d0
    jbeq FOUNDMATCH_1C
    lea %a0@(0x0,%d0:l),%a1
    cmpw %a1@(18),%d2
    jbne GETHARDWARECONT_8
FOUNDMATCH:             /* a0 = its decoder info, valid flags */
    nop
    nop
    moveal %a1@,%a0
    addal %a1,%a0
    movel %a1@(24),%d0
    jbeq MAPFOUND_34
FOUNDMATCH_E:           /* d2 = hardware configuration and kinds */
    movel %a1@(16),%d2
    jbra OPTIONALSPATCH_44
    .short  0x0000, 0x0000, 0x0000	| 40802F68
FOUNDMATCH_1C:          /* try each decoder test in the list at CHECKFORUNKNOWN_6 */
    movel %fp,%d0
    lea %pc@(CHECKFORUNKNOWN_6),%a1
CHECKNEXTMAP:           /* call the next decoder test (each returns to MAPFOUND or CHECKNEXTMAP) */
    moveal %a1,%a0
    addal %a1@+,%a0
    moveal %a0@(-8),%a2
    jmp %a0@(0x0,%a2:l)
MAPFOUND:               /* decoder found: read the VIA ID inputs (find the matching ProductInfo) */
    moveal %d0,%a2
    movel %a0@(-20),%d0
    lea %pc@(MAPFOUND_E),%fp
    jmp %pc@(GETVIAINPUTS)
MAPFOUND_E:             /* match the VIA ID against each ProductInfo */
    moveal %a2,%fp	| 40802F8E
    moveb %a0@(-4),%d2	| 40802F90
    lea %pc@(CHECKFORUNKNOWN_26),%a0	| 40802F94
MAPFOUND_18:            /* loop: move */
    movel %a0@+,%d0	| 40802F98
    jbeq FOUNDMATCH_1C	| 40802F9A
    lea %a0@(-4,%d0:l),%a1	| 40802F9C
    cmpb %a1@(19),%d2	| 40802FA0
    jbne MAPFOUND_18	| 40802FA4
    movel %d1,%d0	| 40802FA6
    andl %a1@(32),%d0	| 40802FA8
    cmpl %a1@(36),%d0	| 40802FAC
    jbne MAPFOUND_18	| 40802FB0
    jbra FOUNDMATCH	| 40802FB2
MAPFOUND_34:            /* check optional hardware: RBV present? */
    movel %a0@(-20),%d0
    moveal %fp,%a0
    btst #13,%d0
    jbeq MAPFOUND_5C
    moveal %a1@,%a2
    moveal %a1@(0x34,%a2:l),%a2
    lea %a2@(19),%a2
    lea %pc@(MAPFOUND_52),%fp
    jmp %pc@(TESTFORRVIER)
MAPFOUND_52:            /* clear bits 13/14 if not */
    jbeq MAPFOUND_5C	| 40802FD2
    bclr #13,%d0	| 40802FD4
    bclr #14,%d0	| 40802FD8
MAPFOUND_5C:            /* VIA 2 really there? */
    bclr #11,%d0
    jbeq MAPFOUND_7A
    moveal %a1@,%a2
    moveal %a1@(0x2c,%a2:l),%a2
    lea %a2@(7168),%a2
    lea %pc@(MAPFOUND_74),%fp
    jmp %pc@(TESTFORVIER)
MAPFOUND_74:            /* keep bit 11 if found */
    jbne MAPFOUND_7A	| 40802FF4
    bset #11,%d0	| 40802FF6
MAPFOUND_7A:            /* SWIM IOP present? */
    bclr #16,%d0
    jbeq MAPFOUND_98
MAPFOUND_80:            /* test it */
    moveal %a1@,%a2
    moveal %a1@(0x40,%a2:l),%a2
    lea %pc@(MAPFOUND_8E),%fp
    jmp %pc@(TESTFORIOP)
MAPFOUND_8E:            /* IOP found: bit 16 set, bit 5 cleared */
    jbne MAPFOUND_98	| 4080300E
    bclr #5,%d0	| 40803010
    bset #16,%d0	| 40803014
MAPFOUND_98:            /* SCC IOP present? */
    bclr #17,%d0
    jbeq MAPFOUND_BA
    moveal %a1@,%a2
    moveal %a1@(0x44,%a2:l),%a2
    lea %pc@(MAPFOUND_AC),%fp
    jmp %pc@(TESTFORIOP)
MAPFOUND_AC:            /* bne */
    jbne MAPFOUND_BA	| 4080302C

MAPFOUND_AE:            /* SCC IOP: bit 17 set, plain SCC bits 3/4 cleared */
    bset #17,%d0
    bclr #3,%d0
    bclr #4,%d0
MAPFOUND_BA:            /* SCSI DMA present? */
    bclr #15,%d0
    jbeq MAPFOUND_E0
    moveal %a1@,%a2
    moveal %a1@(0x3c,%a2:l),%a2
    lea %pc@(MAPFOUND_CE),%fp
    jmp %pc@(TESTFORSCSIDMA)
MAPFOUND_CE:            /* found: bit 15 set, bit 8 cleared */
    jbne MAPFOUND_E0	| 4080304E
    bset #15,%d0	| 40803050
    bclr #8,%d0	| 40803054

MAPFOUND_D8:            /* SCSI DMA: the other SCSI bits 9/10 cleared */
    bclr #9,%d0
    bclr #10,%d0
MAPFOUND_E0:            /* then SCSI96ANDRPUPATCH */
    bral SCSI96ANDRPUPATCH_44

/* SCSI96ANDRPURESUME: back from the patch: a0 = the decoder info, finish in FOUNDMATCH_E. */
SCSI96ANDRPURESUME:
    addal %a0@,%a0
    jbra FOUNDMATCH_E

/*
 CHECKFEATURES: extended feature flags: from the ProductInfo (+28), or the decoder's
 default. Then the decoder tests (partly raw words): each probes the hardware of one
 decoder kind (registers that must exist, bus errors) and goes on to MAPFOUND when it
 matches or CHECKNEXTMAP when not.
*/
CHECKFEATURES:
    movel %a1@(28),%d1
    jbne CHECKFEATURES_A
    movel %a0@(-16),%d1
CHECKFEATURES_A:        /* return through fp */
    bclr #27,%d7
    jmp %fp@
    .long   0x24680008	| 4080307C
    .long   0x45EA1C00, 0x243C0002	| 40803080
    .short  0x0000, 0x4DFA	| orib #0xfa,%d0
    .short  0x0006, 0x4EFA	| orib #0xfa,%d6
    moveb %a4@+,%d3
    jbne CHECKNEXTMAP
    jbra MAPFOUND
    moveal %a0@(8),%a2
    lea %a2@(7168),%a2
    movel #262144,%d2
    lea %pc@(CHECKFEATURES_A_3A),%fp
    jmp %pc@(TESTVIERWRAP)
CHECKFEATURES_A_3A:
    bnew CHECKNEXTMAP
    subil #131072,%d2	| 408030B4
    lea %pc@(CHECKFEATURES_A_3A+0x12),%fp
    jmp %pc@(TESTVIERWRAP)
    jbeq CHECKNEXTMAP
    lea %pc@(CHECKNEXTMAP),%fp
    moveal %a0@(52),%a2
    tstb %a2@
    moveal %a0@(56),%a2
    tstb %a2@
    jbra MAPFOUND
    moveal %a0@(8),%a2
    lea %a2@(7168),%a2
    movel #262144,%d2
    lea %pc@(CHECKFEATURES_A_7A),%fp
    jmp %pc@(TESTVIERWRAP)
CHECKFEATURES_A_7A:
    bnew CHECKNEXTMAP
    .short  0x0482, 0x0002	| 408030F4
    .short  0x0000, 0x4DFA	| orib #0xfa,%d0
    .short  0x0006, 0x4EFA	| orib #0xfa,%d6
    moveb %a4@(26368),%a2@(0x70,%sp:l:8)
    lea %pc@(CHECKNEXTMAP),%fp
    moveal %a0@(72),%a2
    moveb %a2@,%d1
    lslw #8,%d1
    moveq #6,%d2
CHECKFEATURES_A8:       /* probe loop: write d2, read it back (a decoder register) */
    moveb %d2,%a2@
    tstl %pc@(GOTBUSERROR_8)
    moveb %a2@,%d1
    nop
    andib #7,%d1
    cmpb %d1,%d2
    dbne %d2,CHECKFEATURES_A8
    lsrw #8,%d1
    moveb %d1,%a2@
    tstw %d2
    jbpl CHECKNEXTMAP
    jbra MAPFOUND
    moveal %a0@(8),%a2
    lea %a2@(7168),%a2
    lea %pc@(CHECKFEATURES_A8_32),%fp
    jmp %pc@(TESTFORVIER)
CHECKFEATURES_A8_32:
    bnew CHECKNEXTMAP
    movel #262144,%d2
    lea %pc@(CHECKFEATURES_A8_44),%fp
    jmp %pc@(TESTVIERWRAP)
CHECKFEATURES_A8_44:
    beqw CHECKNEXTMAP
    lea %pc@(CHECKNEXTMAP),%fp
    moveal %a0@(52),%a2
    tstb %a2@
    moveal %a0@(56),%a2
    tstb %a2@
    braw MAPFOUND
    lea %pc@(CHECKNEXTMAP),%fp
    moveal %a0@(84),%a2
    movel %a2@,%d2
    braw MAPFOUND
    moveal %a0@(8),%a2
    lea %a2@(7168),%a2
    .short  0x243C, 0x0010	| 40803186
    .short  0x0000, 0x4DFA	| orib #0xfa,%d0
    .short  0x0006, 0x4EFA	| orib #0xfa,%d6
    moveb %a2@+,%a2@-
    jbne CHECKNEXTMAP
    lsrl #1,%d2
    lea %pc@(CHECKFEATURES_136),%fp
    jmp %pc@(TESTVIERWRAP)
CHECKFEATURES_136:      /* the rest of this decoder test */
    jbeq CHECKNEXTMAP	| 408031A2
    lsrl #1,%d2	| 408031A6
    lea %pc@(CHECKFEATURES_144),%fp	| 408031A8
    jmp %pc@(TESTVIERWRAP)	| 408031AC
CHECKFEATURES_144:      /* from here: jbeq CHECKNEXTMAP */
    jbeq CHECKNEXTMAP	| 408031B0
    lea %pc@(CHECKNEXTMAP),%fp	| 408031B4
    moveal %a0@(88),%a2	| 408031B8
    tstb %a2@	| 408031BC
    jbra MAPFOUND	| 408031BE

/*
 CHECKFORNIAGRA: decoder test for the Niagra (raw words, partly): probe and check the
 address wrap (TESTVIERWRAP).
*/
CHECKFORNIAGRA:
    .short  0x2468, 0x0008, 0x45EA, 0x1C00, 0x243C, 0xFF20	| 408031C2
    .short  0x0000, 0x4DFA	| orib #0xfa,%d0
    .short  0x0006, 0x4EFA	| orib #0xfa,%d6
    moveb %fp@,%a2@+
    jbeq CHECKNEXTMAP
    movel #524288,%d2
    lea %pc@(CHECKFORNIAGRA_28),%fp
    jmp %pc@(TESTVIERWRAP)
CHECKFORNIAGRA_28:
    jbeq CHECKNEXTMAP	| 408031EA
    lsrl #1,%d2	| 408031EE
    lea %pc@(CHECKFORNIAGRA_36),%fp	| 408031F0
    jmp %pc@(TESTVIERWRAP)	| 408031F4
CHECKFORNIAGRA_36:      /* (data) */
    .byte   0x67, 0x00, 0xFD, 0x7A, 0x4D, 0xFA, 0xFD, 0x76, 0x24, 0x68, 0x00, 0x58, 0x4A, 0x12	| 408031F8
    jbra MAPFOUND

/* CHECKFORUNKNOWN: last decoder test: always "found" (unknown decoder). */
CHECKFORUNKNOWN:
    braw MAPFOUND
    .short  0x0000	| 4080320E
CHECKFORUNKNOWN_6:      /* offsets of the decoder tests, tried in order */
    .long   0x00000280, 0x000CFD7C, 0x000003C0, 0x00000318	| 40803210
    .long   0x00000084, 0x00000124, 0x000001C4	| 40803220
CHECKFORUNKNOWN_22:     /* offsets of the ProductInfo records, one per known machine (0 ends) */
    .long   UNKNOWNDECODERTABLE-.	| 4080322C
CHECKFORUNKNOWN_26:     /* (data) */
    .long   CHECKFORUNKNOWN_44E-.	| 40803230
    .long   CHECKFORUNKNOWN_48E-.	| 40803234
    .long   CHECKFORUNKNOWN_4CE-.	| 40803238
    .long   CHECKFORUNKNOWN_50E-.	| 4080323C
    .long   CHECKFORUNKNOWN_54E-.	| 40803240
    .long   CHECKFORUNKNOWN_58E-.	| 40803244
    .long   CHECKFORUNKNOWN_5CE-.	| 40803248
    .long   CHECKFORUNKNOWN_60E-.	| 4080324C
    .long   CHECKFORUNKNOWN_6CE-.	| 40803250
    .long   CHECKFORUNKNOWN_64E-.	| 40803254
    .long   CHECKFORUNKNOWN_68E-.	| 40803258
    .long   CHECKFORUNKNOWN_70E-.	| 4080325C
    .long   INFODARTANIAN-.	| 40803260
    .long   CHECKFORUNKNOWN_74E-.	| 40803264
    .long   CHECKFORUNKNOWN_78E-.	| 40803268
    .long   CHECKFORUNKNOWN_7CE-.	| 4080326C
    .long   CHECKFORUNKNOWN_80E-.	| 40803270
    .long   CHECKFORUNKNOWN_84E-.	| 40803274
    .long   INFOUNKNOWNUNKNOWN-.	| 40803278
    .long   0x00000000	| 4080327C
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803280
    .long   0x00001F3F, 0x00000000, 0x1000C000, 0xFFFFFDD8	| 40803290
    .long   0x04000000	| 408032A0
CHECKFORUNKNOWN_9A:     /* decoder info (base addresses), decoder kind 4 */
    .long   MYFIRSTPROC	| 408032A4
    .long   0x58000000, 0x50F00000	| 408032A8
    .long   0x50F04000, 0x50F04000, 0x50F16000, 0x00000000	| 408032B0
    .long   0x00000000, 0x50F10000, 0x50F12000, 0x50F06000	| 408032C0
    .byte   0x50, 0xF0, 0x20, 0x00, 0x50, 0xF1, 0x40	| 408032D0
    .fill   0x5E, 1, 0x00
    .byte   0x03, 0xFF, 0x3F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40803335
    .long   0xFFFFFD52, 0x05000000	| 40803340
CHECKFORUNKNOWN_13E:    /* decoder info, decoder kind 5 */
    .long   MYFIRSTPROC	| 40803348
    .long   0x58000000	| 4080334C
    .long   0x50F00000, 0x50F04000, 0x50F04000, 0x50F16000	| 40803350
    .long   0x00000000, 0x00000000, 0x50F10000, 0x50F12000	| 40803360
    .long   0x50F06000, 0x50F02000, 0x50F14000, 0x50F26000	| 40803370
    .long   0x50F24000, 0x50F18000, 0x50F1E020, 0x50F0C020	| 40803380
    .fill   0x49, 1, 0x00
    .byte   0x1F, 0x90, 0x07, 0x00, 0x00, 0x00, 0x04	| 408033D9
    .long   0x00000000, 0xFFFFFCEE, 0x06000000	| 408033E0
CHECKFORUNKNOWN_1E2:    /* decoder info, decoder kind 6 */
    .long   MYFIRSTPROC	| 408033EC
    .long   0x58000000, 0x50F00000, 0x00000000, 0x00000000	| 408033F0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803400
    .long   0x00000000, 0x00000000, 0x00000000, 0x50F10000	| 40803410
    .long   0x00000000, 0x00000000, 0x50F08000, 0x50F12020	| 40803420
    .long   0x50F04020, 0x50F1A000, 0x50F1C000, 0x50F1E000	| 40803430
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803440
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803450
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803460
    .long   0x00000000, 0x00000000, 0x00000000, 0x1000773F	| 40803470
    .short  0x0000, 0x00A6, 0x0000, 0x0000, 0xFFFF, 0xFCA6, 0x0700	| 40803480
CHECKFORUNKNOWN_284:    /* decoder info, decoder kind 7 */
    .long   0x000040A0 /* number, not an address (F4) */	| 4080348E
    .long   0x000050F8 /* number, not an address (F4) */	| 40803492
    .long   0x000050F0 /* number, not an address (F4) */	| 40803496
    .long   0x000050F0 /* number, not an address (F4) */	| 4080349A
    .short  0x4000	| 4080349E
    .long   0x50F04000, 0x50F16000, 0x00000000, 0x00000000	| 408034A0
    .long   0x50F10000, 0x50F12000, 0x50F06000, 0x00000000	| 408034B0
    .long   0x50F14000, 0x50F26000, 0x50F24000, 0x00000000	| 408034C0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408034D0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408034E0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408034F0
    .long   0x00A00000, 0x00000000, 0x00000000, 0x00000000	| 40803500
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803510
    .long   0x07A3181F, 0x00000000, 0x00C00000, 0xFFFFFC3C	| 40803520
    .long   0x08000000	| 40803530
CHECKFORUNKNOWN_32A:    /* decoder info, decoder kind 8 (the Quadra 700/900/950/800 decoders) */
    .long   MYFIRSTPROC	| 40803534
    .long   0x58000000, 0x50F00000	| 40803538
    .long   0x50F0C020, 0x50F0C020, 0x50F1E000, 0x00000000	| 40803540
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803550
    .long   0x50F02000, 0x50F14000, 0x00000000, 0xF9800000	| 40803560
    .long   0x00000000, 0x50F1E020, 0x50F0C020, 0x00000000	| 40803570
    .long   0x00000000, 0x00000000, 0x5000E000, 0x00000000	| 40803580
    .long   0x50F0A000, 0x50F0F000, 0x50F0F402, 0xF9800000	| 40803590
    .long   0x00000000, 0x00000000, 0x00000074, 0x00000000	| 408035A0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408035B0
    .long   0x00000000, 0x00401F3F, 0x00010002, 0x00000000	| 408035C0
    .long   0xFFFFFBA6, 0x09000000	| 408035D0
CHECKFORUNKNOWN_3CE:    /* decoder info, decoder kind 9 */
    .long   MYFIRSTPROC	| 408035D8
    .long   0x58000000	| 408035DC
    .long   0x50F00000, 0x50F04000, 0x50F04000, 0x50F16000	| 408035E0
    .long   0x00000000, 0x00000000, 0x50F10000, 0x50F06000	| 408035F0
    .long   0x50F06000, 0x50F02000, 0x50F14000, 0x00000000	| 40803600
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803610
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803620
    .long   0x50F80000, 0x00000000, 0x00000000, 0x00000000	| 40803630
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803640
    .long   0x00000000, 0x00000000	| 40803650
CHECKFORUNKNOWN_44E:    /* ProductInfo: machine 1 (decoder 4) */
    .long   CHECKFORUNKNOWN_9A-CHECKFORUNKNOWN_44E	| 40803658
    .long   VIA2INITDARTANIAN_6-CHECKFORUNKNOWN_44E	| 4080365C
    .long   0x00000000	| 40803660
    .long   VIDEOINFODAFB_70-CHECKFORUNKNOWN_44E	| 40803664
    .long   0xDC000104, 0x3FFF0100	| 40803668
    .long   0x00001F3F, 0x00000800, 0x40000008, 0x00000000	| 40803670
    .long   CHECKFORUNKNOWN_88E-CHECKFORUNKNOWN_44E	| 40803680
    .long   VIA1INITDARTANIAN_C-CHECKFORUNKNOWN_44E	| 40803684
    .long   0x00000000	| 40803688
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_44E	| 4080368C
    .long   VIAADBTABLE-CHECKFORUNKNOWN_44E	| 40803690
    .long   0x00000000	| 40803694
CHECKFORUNKNOWN_48E:    /* ProductInfo: machine 3 (decoder 4) */
    .long   CHECKFORUNKNOWN_9A-CHECKFORUNKNOWN_48E	| 40803698
    .long   VIA2INITDARTANIAN_6-CHECKFORUNKNOWN_48E	| 4080369C
    .long   0x00000000	| 408036A0
    .long   VIDEOINFODAFB_80-CHECKFORUNKNOWN_48E	| 408036A4
    .long   0xDC000304, 0x3FFF0100	| 408036A8
    .long   0x00001F3F, 0x00001800, 0x40000008, 0x40000000	| 408036B0
    .long   CHECKFORUNKNOWN_88E-CHECKFORUNKNOWN_48E	| 408036C0
    .long   VIA1INITDARTANIAN_C-CHECKFORUNKNOWN_48E	| 408036C4
    .long   0x00000000	| 408036C8
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_48E	| 408036CC
    .long   VIAADBTABLE-CHECKFORUNKNOWN_48E	| 408036D0
    .long   0x00000000	| 408036D4
CHECKFORUNKNOWN_4CE:    /* ProductInfo: machine 2 (decoder 4) */
    .long   CHECKFORUNKNOWN_9A-CHECKFORUNKNOWN_4CE	| 408036D8
    .long   VIA2INITDARTANIAN_6-CHECKFORUNKNOWN_4CE	| 408036DC
    .long   0x00000000	| 408036E0
    .long   VIDEOINFODAFB_90-CHECKFORUNKNOWN_4CE	| 408036E4
    .long   0xDC000204, 0x3FFF0100	| 408036E8
    .long   0x00001F3F, 0x00000800, 0x40000008, 0x40000008	| 408036F0
    .long   CHECKFORUNKNOWN_88E-CHECKFORUNKNOWN_4CE	| 40803700
    .long   VIA1INITDARTANIAN_C-CHECKFORUNKNOWN_4CE	| 40803704
    .long   0x00000000	| 40803708
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_4CE	| 4080370C
    .long   VIAADBTABLE-CHECKFORUNKNOWN_4CE	| 40803710
    .long   0x00000000	| 40803714
CHECKFORUNKNOWN_50E:    /* ProductInfo: machine 5 (decoder 5) */
    .long   CHECKFORUNKNOWN_13E-CHECKFORUNKNOWN_50E	| 40803718
    .long   VIA2INITDARTANIAN_6-CHECKFORUNKNOWN_50E	| 4080371C
    .long   VIA2INITDARTANIAN_B6-CHECKFORUNKNOWN_50E	| 40803720
    .long   VIDEOINFODAFB_A0-CHECKFORUNKNOWN_50E	| 40803724
    .long   0xDC000505, 0x3FFF0100	| 40803728
    .long   0x0000773F, 0x00000800, 0x56000000, 0x46000000	| 40803730
    .long   CHECKFORUNKNOWN_894-CHECKFORUNKNOWN_50E	| 40803740
    .long   0x00000000, 0x00000000	| 40803744
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_50E	| 4080374C
    .long   VIAADBTABLE-CHECKFORUNKNOWN_50E	| 40803750
    .long   0x00000000	| 40803754
CHECKFORUNKNOWN_54E:    /* ProductInfo: machine 5 (decoder 5), other VIA ID */
    .long   CHECKFORUNKNOWN_13E-CHECKFORUNKNOWN_54E	| 40803758
    .long   VIA2INITDARTANIAN_6-CHECKFORUNKNOWN_54E	| 4080375C
    .long   VIA2INITDARTANIAN_B6-CHECKFORUNKNOWN_54E	| 40803760
    .long   VIDEOINFODAFB_A0-CHECKFORUNKNOWN_54E	| 40803764
    .long   0xDC000505, 0x3FFF0100	| 40803768
    .long   0x0000773F, 0x00000801, 0x56000000, 0x56000000	| 40803770
    .long   CHECKFORUNKNOWN_894-CHECKFORUNKNOWN_54E	| 40803780
    .long   0x00000000, 0x00000000	| 40803784
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_54E	| 4080378C
    .long   VIAADBTABLE-CHECKFORUNKNOWN_54E	| 40803790
    .long   0x00000000	| 40803794
CHECKFORUNKNOWN_58E:    /* ProductInfo: machine 7 (decoder 6) */
    .long   CHECKFORUNKNOWN_1E2-CHECKFORUNKNOWN_58E	| 40803798
    .long   VIA2INITDARTANIAN_6-CHECKFORUNKNOWN_58E	| 4080379C
    .long   0x00000000	| 408037A0
    .long   VIDEOINFODAFB_70-CHECKFORUNKNOWN_58E	| 408037A4
    .long   0xDC000706, 0x3FFF0200	| 408037A8
    .long   0x00000000, 0x00000804, 0x56000000, 0x52000000	| 408037B0
    .long   CHECKFORUNKNOWN_8A0-CHECKFORUNKNOWN_58E	| 408037C0
    .long   0x00000000, 0x00000000	| 408037C4
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_58E	| 408037CC
    .long   IOPADBTABLE-CHECKFORUNKNOWN_58E	| 408037D0
    .long   0x00000000	| 408037D4
CHECKFORUNKNOWN_5CE:    /* ProductInfo: machine 12 (decoder 5) */
    .long   0xFFFFFB70, 0x00000314	| 408037D8
    .long   0x000003D4, 0x000004D4, 0xDC000C05, 0x3FFF0400	| 408037E0
    .long   0x0000773F, 0x00003926, 0x56000000, 0x16000000	| 408037F0

CHECKFORUNKNOWN_5F6:    /* (inside the record above) */
    .short  0x0000, 0x02CC	| orib #0xcc,%d0
    .long   0x00000000, 0x00000000, 0x000AFC46	| 40803804
    .long   0x000AF42E, 0x00000000	| 40803810
CHECKFORUNKNOWN_60E:    /* ProductInfo: machine 13 (decoder 7, Egret) */
    .long   CHECKFORUNKNOWN_286-CHECKFORUNKNOWN_60E	| 40803818
    .long   VIA2INITDARTANIAN_1E-CHECKFORUNKNOWN_60E	| 4080381C
    .long   VIA2INITDARTANIAN_D6-CHECKFORUNKNOWN_60E	| 40803820
    .long   VIDEOINFODAFB_D0-CHECKFORUNKNOWN_60E	| 40803824
    .long   0xDC000D07, 0x3FFF0400	| 40803828
    .long   0x0000773F, 0x000001A6, 0x56000000, 0x54000000	| 40803830
    .long   CHECKFORUNKNOWN_89A-CHECKFORUNKNOWN_60E	| 40803840
    .long   0x00000000	| 40803844
    .long   SNDCNTLELSIE-CHECKFORUNKNOWN_60E	| 40803848
    .long   EGRETCLOCKPRAM-CHECKFORUNKNOWN_60E	| 4080384C
    .long   EGRETADBTABLE-CHECKFORUNKNOWN_60E	| 40803850
    .long   0x00000000	| 40803854
CHECKFORUNKNOWN_64E:    /* ProductInfo: machine 14 (decoder 8, Egret) */
    .long   CHECKFORUNKNOWN_32A-CHECKFORUNKNOWN_64E	| 40803858
    .long   VIA2INITDARTANIAN_4E-CHECKFORUNKNOWN_64E	| 4080385C
    .long   VIDEOINFODAFB-CHECKFORUNKNOWN_64E	| 40803860
    .long   VIDEOINFODAFB_E0-CHECKFORUNKNOWN_64E	| 40803864
    .long   0xDC000E08, 0x3FFF0200	| 40803868
    .long   0x27A31807, 0x00043924, 0x56000000, 0x50000000	| 40803870
    .long   CHECKFORUNKNOWN_8AC-CHECKFORUNKNOWN_64E	| 40803880
    .long   VIA1INITDARTANIAN_18-CHECKFORUNKNOWN_64E	| 40803884
    .long   SNDCNTLECLIPSE-CHECKFORUNKNOWN_64E	| 40803888
    .long   EGRETCLOCKPRAM-CHECKFORUNKNOWN_64E	| 4080388C
    .long   QUADRAADBTABLE-CHECKFORUNKNOWN_64E	| 40803890
    .long   0x00000000	| 40803894
CHECKFORUNKNOWN_68E:    /* ProductInfo: machine 20 (decoder 8, Egret) */
    .long   CHECKFORUNKNOWN_32A-CHECKFORUNKNOWN_68E	| 40803898
    .long   VIA2INITDARTANIAN_4E-CHECKFORUNKNOWN_68E	| 4080389C
    .long   VIDEOINFODAFB-CHECKFORUNKNOWN_68E	| 408038A0
    .long   VIDEOINFODAFB_E0-CHECKFORUNKNOWN_68E	| 408038A4
    .long   0xDC001408, 0x3FFF0200	| 408038A8
    .long   0x07A31807, 0x00043924, 0x56000000, 0x10000000	| 408038B0
    .long   CHECKFORUNKNOWN_8AC-CHECKFORUNKNOWN_68E	| 408038C0
    .long   VIA1INITDARTANIAN_18-CHECKFORUNKNOWN_68E	| 408038C4
    .long   SNDCNTLECLIPSE-CHECKFORUNKNOWN_68E	| 408038C8
    .long   EGRETCLOCKPRAM-CHECKFORUNKNOWN_68E	| 408038CC
    .long   QUADRAADBTABLE-CHECKFORUNKNOWN_68E	| 408038D0
    .long   0x00000000	| 408038D4
CHECKFORUNKNOWN_6CE:    /* ProductInfo: machine 16 (decoder 8) */
    .long   CHECKFORUNKNOWN_32A-CHECKFORUNKNOWN_6CE	| 408038D8
    .long   VIA2INITDARTANIAN_76-CHECKFORUNKNOWN_6CE	| 408038DC
    .long   VIDEOINFODAFB-CHECKFORUNKNOWN_6CE	| 408038E0
    .long   VIDEOINFODAFB_F0-CHECKFORUNKNOWN_6CE	| 408038E4
    .long   0xDC001008, 0x3FFF0200	| 408038E8
    .long   0x05A0183F, 0x00003900, 0x56000000, 0x40000000	| 408038F0
    .long   CHECKFORUNKNOWN_8B2-CHECKFORUNKNOWN_6CE	| 40803900
    .long   VIA1INITDARTANIAN_1E-CHECKFORUNKNOWN_6CE	| 40803904
    .long   SNDCNTLSPIKE-CHECKFORUNKNOWN_6CE	| 40803908
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_6CE	| 4080390C
    .long   VIAADBTABLE-CHECKFORUNKNOWN_6CE	| 40803910
    .long   0x00000000	| 40803914
CHECKFORUNKNOWN_70E:    /* ProductInfo: machine 15 (decoder 9, Power Manager) */
    .long   CHECKFORUNKNOWN_3CE-CHECKFORUNKNOWN_70E	| 40803918
    .long   VIA2INITDARTANIAN_8E-CHECKFORUNKNOWN_70E	| 4080391C
    .long   VIA2INITDARTANIAN_F6-CHECKFORUNKNOWN_70E	| 40803920
    .long   VIDEOINFODAFB_100-CHECKFORUNKNOWN_70E	| 40803924
    .long   0xDD000F09, 0x3FFF0400	| 40803928
    .long   0x00401F3F, 0x00013902, 0x56000000, 0x12000000	| 40803930
    .long   VIA1INITDARTANIAN-CHECKFORUNKNOWN_70E	| 40803940
    .long   VIA2INITDARTANIAN-CHECKFORUNKNOWN_70E	| 40803944
    .long   SNDCNTLTIM-CHECKFORUNKNOWN_70E	| 40803948
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_70E	| 4080394C
    .long   PMGRADBTABLE-CHECKFORUNKNOWN_70E	| 40803950
    .long   0x00000000	| 40803954
CHECKFORUNKNOWN_74E:    /* ProductInfo: unknown machine, decoder 4 */
    .long   CHECKFORUNKNOWN_9A-CHECKFORUNKNOWN_74E	| 40803958
    .long   VIA2INITDARTANIAN_6-CHECKFORUNKNOWN_74E	| 4080395C
    .long   0x00000000	| 40803960
    .long   VIDEOINFODAFB_70-CHECKFORUNKNOWN_74E	| 40803964
    .long   0xDC00FD04, 0x3FFF0100	| 40803968
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803970
    .long   CHECKFORUNKNOWN_88E-CHECKFORUNKNOWN_74E	| 40803980
    .long   VIA1INITDARTANIAN_C-CHECKFORUNKNOWN_74E	| 40803984
    .long   0x00000000	| 40803988
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_74E	| 4080398C
    .long   VIAADBTABLE-CHECKFORUNKNOWN_74E	| 40803990
    .long   0x00000000	| 40803994
CHECKFORUNKNOWN_78E:    /* ProductInfo: unknown machine, decoder 5 */
    .long   CHECKFORUNKNOWN_13E-CHECKFORUNKNOWN_78E	| 40803998
    .long   VIA2INITDARTANIAN_6-CHECKFORUNKNOWN_78E	| 4080399C
    .long   VIA2INITDARTANIAN_B6-CHECKFORUNKNOWN_78E	| 408039A0
    .long   VIDEOINFODAFB_70-CHECKFORUNKNOWN_78E	| 408039A4
    .long   0xDC00FD05, 0x3FFF0100	| 408039A8
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408039B0
    .long   CHECKFORUNKNOWN_894-CHECKFORUNKNOWN_78E	| 408039C0
    .long   VIA1INITDARTANIAN_12-CHECKFORUNKNOWN_78E	| 408039C4
    .long   0x00000000	| 408039C8
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_78E	| 408039CC
    .long   VIAADBTABLE-CHECKFORUNKNOWN_78E	| 408039D0
    .long   0x00000000	| 408039D4
CHECKFORUNKNOWN_7CE:    /* ProductInfo: unknown machine, decoder 6 */
    .long   CHECKFORUNKNOWN_1E2-CHECKFORUNKNOWN_7CE	| 408039D8
    .long   VIA2INITDARTANIAN_6-CHECKFORUNKNOWN_7CE	| 408039DC
    .long   0x00000000	| 408039E0
    .long   VIDEOINFODAFB_70-CHECKFORUNKNOWN_7CE	| 408039E4
    .long   0xDC00FD06, 0x3FFF0200	| 408039E8
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408039F0
    .long   CHECKFORUNKNOWN_8A0-CHECKFORUNKNOWN_7CE	| 40803A00
    .long   0x00000000, 0x00000000	| 40803A04
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_7CE	| 40803A0C
    .long   IOPADBTABLE-CHECKFORUNKNOWN_7CE	| 40803A10
    .long   0x00000000	| 40803A14
CHECKFORUNKNOWN_80E:    /* ProductInfo: unknown machine, decoder 7 */
    .long   CHECKFORUNKNOWN_286-CHECKFORUNKNOWN_80E	| 40803A18
    .long   VIA2INITDARTANIAN_1E-CHECKFORUNKNOWN_80E	| 40803A1C
    .long   VIA2INITDARTANIAN_D6-CHECKFORUNKNOWN_80E	| 40803A20
    .long   VIDEOINFODAFB_D0-CHECKFORUNKNOWN_80E	| 40803A24
    .long   0xCC00FD07, 0x7FFF0400	| 40803A28
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40803A30
    .long   CHECKFORUNKNOWN_89A-CHECKFORUNKNOWN_80E	| 40803A40
    .long   0x00000000, 0x00000000	| 40803A44
    .long   EGRETCLOCKPRAM-CHECKFORUNKNOWN_80E	| 40803A4C
    .long   EGRETADBTABLE-CHECKFORUNKNOWN_80E	| 40803A50
    .long   0x00000000	| 40803A54
CHECKFORUNKNOWN_84E:    /* ProductInfo: unknown machine, decoder 9 */
    .long   CHECKFORUNKNOWN_3CE-CHECKFORUNKNOWN_84E	| 40803A58
    .long   VIA2INITDARTANIAN_8E-CHECKFORUNKNOWN_84E	| 40803A5C
    .long   VIA2INITDARTANIAN_F6-CHECKFORUNKNOWN_84E	| 40803A60
    .long   VIDEOINFODAFB_100-CHECKFORUNKNOWN_84E	| 40803A64
    .long   0xDD00FD09, 0x3FFF0200	| 40803A68
    .long   0x00000000, 0x00010002, 0x00000000, 0x00000000	| 40803A70
    .long   VIA1INITDARTANIAN-CHECKFORUNKNOWN_84E	| 40803A80
    .long   VIA2INITDARTANIAN-CHECKFORUNKNOWN_84E	| 40803A84
    .long   0x00000000	| 40803A88
    .long   RTCCLOCKPRAM-CHECKFORUNKNOWN_84E	| 40803A8C
    .long   PMGRADBTABLE-CHECKFORUNKNOWN_84E	| 40803A90
    .long   0x00000000	| 40803A94
CHECKFORUNKNOWN_88E:    /* VIA 1 init table (6 bytes) */
    .short  0x013F, 0x37B7, 0x0000	| 40803A98
CHECKFORUNKNOWN_894:    /* VIA 1 init table */
    .short  0x212F	| 40803A9E
    .long   0xF7F70000	| 40803AA0
CHECKFORUNKNOWN_89A:    /* VIA 1 init table */
    .short  0x262F, 0x4830, 0x001C	| 40803AA4
CHECKFORUNKNOWN_8A0:    /* VIA 1 init tables */
    .short  0x0107, 0x8787, 0x0000, 0x0107, 0x8787, 0x0000	| 40803AAA
CHECKFORUNKNOWN_8AC:    /* VIA 1 init table */
    .short  0x0000, 0xC9F1, 0x221C	| 40803AB6
CHECKFORUNKNOWN_8B2:    /* VIA 1 init table */
    .long   0x2028F7F7	| 40803ABC
    .short  0x2200	| 40803AC0
VIA1INITDARTANIAN:      /* VIA init tables (6 bytes each) */
    .short  0x2128, 0x8787, 0x2200, 0x00C0, 0x0F88, 0x60C0	| 40803AC2
VIA1INITDARTANIAN_C:    /* VIA 2 init table */
    .short  0x00C0	| 40803ACE
    .long   0x078060C0	| 40803AD0
VIA1INITDARTANIAN_12:   /* VIA 2 init table */
    .short  0x00C0, 0x0F89, 0x00C0	| 40803AD4
VIA1INITDARTANIAN_18:   /* VIA 2 init table */
    .short  0x8080, 0x03C8, 0x22C0	| 40803ADA
VIA1INITDARTANIAN_1E:   /* VIA 2 init table */
    .short  0x8080, 0x0699, 0x22C0	| 40803AE0
VIA2INITDARTANIAN:      /* VIA 2 init table */
    .short  0x0000, 0x66BD, 0x2200	| 40803AE6
VIA2INITDARTANIAN_6:    /* RAM bank info: granularity, then bank start/end pairs, -1 ends */
    .long   0x00100000	| 40803AEC
    .long   0x00000000, 0x04000000, 0x04000000, 0x08000000	| 40803AF0
    .long   0xFFFFFFFF	| 40803B00
VIA2INITDARTANIAN_1E:   /* RAM bank info */
    .long   0x00100000, 0x00000000, 0x00800000	| 40803B04
    .short  0x0080, 0x0000, 0x00A0, 0x0000, 0xFFFF, 0xFFFF, 0x0010	| 40803B10
VIA2INITDARTANIAN_38:   /* (inside the table above) */
    .short  0x0000, 0x0000	| 40803B1E
    .long   0x00000040 /* number, not a label difference (was VIA2INITDARTANIAN_78-VIA2INITDARTANIAN_38) */	| 40803B22
    .long   0x00000040 /* number, not a label difference (was VIA2INITDARTANIAN_78-VIA2INITDARTANIAN_38) */	| 40803B26
    .long   0x00000080 /* number, not a label difference (was VIA2INITDARTANIAN_B8-VIA2INITDARTANIAN_38) */	| 40803B2A
    .short  0x0000	| 40803B2E
    .long   0xFFFFFFFF	| 40803B30
VIA2INITDARTANIAN_4E:   /* RAM bank info (Quadra decoder): 4 MB units, four 64 MB banks */
    .long   0x00400000, 0x00000000, 0x04000000	| 40803B34
    .short  0x0400, 0x0000, 0x0800	| 40803B40
    .long   0x00000800 /* number, not a label difference (was INITSNDNORAM_B8-VIA2INITDARTANIAN_38) */	| 40803B46
    .long   0x00000C00 /* number, not a label difference (was TESTFORSCC_A-VIA2INITDARTANIAN_38) */	| 40803B4A
    .long   0x00000C00 /* number, not a label difference (was TESTFORSCC_A-VIA2INITDARTANIAN_38) */	| 40803B4E
    .long   0x00001000 /* number, not a label difference (was OPTIONALSPATCH_BA-VIA2INITDARTANIAN_38) */	| 40803B52
    .long   0x0000FFFF /* number, not an address (F5) */	| 40803B56
    .short  0xFFFF	| 40803B5A
VIA2INITDARTANIAN_76:   /* RAM bank info */
    .short  0x0040	| 40803B5C
VIA2INITDARTANIAN_78:   /* (inside the table above) */
    .short  0x0000, 0x0000	| 40803B5E
    .long   0x00000400 /* number, not a label difference (was MMUCLEANUPFOR8MB_FE-VIA2INITDARTANIAN_78) */	| 40803B62
    .long   0x00000400 /* number, not a label difference (was MMUCLEANUPFOR8MB_FE-VIA2INITDARTANIAN_78) */	| 40803B66
    .long   0x00000800 /* number, not a label difference (was INITSNDNORAM_F8-VIA2INITDARTANIAN_78) */	| 40803B6A
    .short  0x0000	| 40803B6E
    .long   0xFFFFFFFF	| 40803B70
VIA2INITDARTANIAN_8E:   /* RAM bank info */
    .long   0x00080000, 0x00000000, 0x00200000	| 40803B74
    .short  0x0020, 0x0000, 0x0040	| 40803B80
    .long   0x00000040 /* number, not a label difference (was VIA2INITDARTANIAN_B8-VIA2INITDARTANIAN_78) */	| 40803B86
    .long   0x00000060 /* number, not a label difference (was VIA2INITDARTANIAN_D8-VIA2INITDARTANIAN_78) */	| 40803B8A
    .long   0x00000060 /* number, not a label difference (was VIA2INITDARTANIAN_D8-VIA2INITDARTANIAN_78) */	| 40803B8E
    .long   0x00000080 /* number, not a label difference (was VIA2INITDARTANIAN_F8-VIA2INITDARTANIAN_78) */	| 40803B92
    .long   0x0000FFFF /* number, not an address (F5) */	| 40803B96
    .short  0xFFFF	| 40803B9A
VIA2INITDARTANIAN_B6:   /* video info (frame buffer addresses) */
    .short  0x0000	| 40803B9C
VIA2INITDARTANIAN_B8:   /* (inside the table above) */
    .short  0x0000	| 40803B9E
    .long   0xFBB08000, 0xFBB08000, 0x0B567F00, 0x00000000	| 40803BA0
    .long   0xFEE08000, 0xFEE08000, 0x0E6E7F00	| 40803BB0
VIA2INITDARTANIAN_D6:   /* video info */
    .short  0x50F4	| 40803BBC
VIA2INITDARTANIAN_D8:   /* (inside the table above) */
    .long   0x000050F4 /* number, not a label difference (was SCSIINTHND_B6-VIA2INITDARTANIAN_D8) */	| 40803BBE
    .long   0x000050F4 /* number, not a label difference (was SCSIINTHND_B6-VIA2INITDARTANIAN_D8) */	| 40803BC2
    .long   0x00000B56 /* number, not a label difference (was TESTFORSCC-VIA2INITDARTANIAN_D8) */	| 40803BC6
    .short  0x7F00, 0x0000, 0x0000	| 40803BCA
    .long   0x00000000, 0x00000000, 0x00000000	| 40803BD0
VIA2INITDARTANIAN_F6:   /* video info */
    .short  0xFEE0	| 40803BDC
VIA2INITDARTANIAN_F8:   /* (inside the table above) */
    .short  0x8000	| 40803BDE
    .long   0xFEE08000, 0xFEE08000, 0x0B567F00	| 40803BE0
VIDEOINFODAFB:          /* video info: DAFB frame buffer at 0xF9000000 */
    .long   0xF9000000	| 40803BEC
    .long   0xF9000000, 0x00000000, 0x09467F00, 0x00000000	| 40803BF0
VIDEOINFODAFB_14:       /* (zeros) */
    .fill   0x5C, 1, 0x00
VIDEOINFODAFB_70:       /* NuBus slot info: one byte per slot (type of each slot) */
    .long   0x00000000	| 40803C5C
    .long   0x00000000, 0x00070707, 0x07070700	| 40803C60
VIDEOINFODAFB_80:       /* NuBus slot info */
    .long   0x00000000	| 40803C6C
    .long   0x00000000, 0x00131313, 0x01010300	| 40803C70
VIDEOINFODAFB_90:       /* NuBus slot info */
    .long   0x00000000	| 40803C7C
    .long   0x00000000, 0x00070707, 0x01010100	| 40803C80
VIDEOINFODAFB_A0:       /* NuBus slot info */
    .long   0x03000000	| 40803C8C
    .long   0x00000000	| 40803C90
    .long   0x00010108 /* number, not a label difference (was BTMAINT1-CHECKFORUNKNOWN_7CE) */	| 40803C94
    .long   0x07070700, 0x03000000	| 40803C98
    .long   0x00000000	| 40803CA0
    .long   0x00010108 /* number, not a label difference (was BTMAINT1-CHECKFORUNKNOWN_7CE) */	| 40803CA4
    .long   0x13131300, 0x03000000	| 40803CA8
    .long   0x00000000, 0x00131313, 0x01010800	| 40803CB0
VIDEOINFODAFB_D0:       /* NuBus slot info */
    .long   0x03080808	| 40803CBC
    .long   0x08080808, 0x08092120, 0x21211300	| 40803CC0
VIDEOINFODAFB_E0:       /* NuBus slot info (Quadra) */
    .long   0x03000000	| 40803CCC
    .long   0x00000000, 0x000A0707, 0x07070700	| 40803CD0
VIDEOINFODAFB_F0:       /* NuBus slot info */
    .long   0x03000000	| 40803CDC
    .long   0x00000000, 0x000A0000, 0x00070700	| 40803CE0
VIDEOINFODAFB_100:      /* NuBus slot info */
    .long   0x03000000	| 40803CEC
    .long   0x00000000, 0x00080808, 0x08080800, 0x00000000	| 40803CF0
    .long   0x00A03D10, 0x40003D10	| 40803D00
    .long   GOTBUSERROR	| 40803D08
    .long   0x00003D10	| 40803D0C

/*
 GOTBUSERROR: bus error handler while probing hardware: flag it (bit 27 of d7 is
 tested by the caller), restore the stack saved in a5, return through fp.
*/
GOTBUSERROR:
    btst #27,%d7
    moveal %a5,%sp
    jmp %fp@
GOTBUSERROR_8:          /* 0xFFFFFFFF */
    .byte   0xFF, 0xFF, 0xFF, 0xFF	| 40803D18
    FILL_40803D1C
