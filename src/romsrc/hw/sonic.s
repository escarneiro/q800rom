/*
 hw/sonic.s - SONIC Ethernet
 From SONIC_CAMDMA (0x408CF390). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple.
 Diagnostic tests of the SONIC Ethernet controller (DP83932), compiled C (link/unlk
 frames, arguments on the stack). Called by the test manager with a pointer to its
 service table (a4: +44 run the test, +72/+76 install/remove an interrupt handler,
 +84 set the interrupt level, +100 allocate memory) and the SONIC register addresses.
 Results are small error numbers (0 = passed).
 Note: "pea MemTop" below is the number 0x108 (264 bytes), not the low memory global.
*/

/*
 SONIC_CAMDMA: test the SONIC's CAM (address filter) loading by DMA: reset the chip, set
 the data configuration, give it the CAM descriptor area, issue Load CAM, wait for the
 interrupt (Timeout), then read back every CAM entry and compare.
 Result: 0 passed, 2 interrupt status not cleared, 3 register write failed, 4 interrupt
 mask not cleared, 5 timeout, 6 a CAM word differs (the entry and word index are stored).
*/
SONIC_CAMDMA:
    linkw %fp,#-4
    moveml %d4-%d7/%a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(16),%a3
    moveq #1,%d6
    moveal %a4@,%a0
    moveal %a0@(160),%a0
    moveq #0,%d0
    movew %a0@,%d0
    movel %d0,%a3@
    moveal %a4@,%a0
    moveal %a0@(16),%a0
    clrw %a0@
    moveal %a4@,%a0
    moveal %a0@(16),%a0
    tstw %a0@
    jbeq SONIC_CAMDMA_36
    moveq #2,%d6
    jbra SONIC_CAMDMA_264
SONIC_CAMDMA_36:        /* interrupt status clear: write and read back the data configuration */
    moveal %a4@,%a0
    moveal %a0@,%a0
    movew #148,%a0@
    moveal %a4@,%a0
    moveal %a0@,%a0
    cmpiw #148,%a0@
    jbeq SONIC_CAMDMA_4E
    moveq #3,%d6
    jbra SONIC_CAMDMA_264
SONIC_CAMDMA_4E:        /* clear the interrupt mask (write 0x7FFF, read back) */
    moveal %a4@,%a0
    moveal %a0@(20),%a0
    movew #32767,%a0@
    moveal %a4@,%a0
    moveal %a0@(20),%a0
    moveq #0,%d0
    movew %a0@,%d0
    movel #57343,%d1
    andl %d0,%d1
    jbeq SONIC_CAMDMA_72
    moveq #4,%d6
    jbra SONIC_CAMDMA_264
SONIC_CAMDMA_72:        /* data configuration by chip revision (> 3) and bus width */
    moveq #3,%d0
    cmpl %a3@,%d0
    jbge SONIC_CAMDMA_9E
    moveal %a4@,%a0
    moveal %a0@(252),%a0
    clrw %a0@
    tstl %a4@(4)
    jbeq SONIC_CAMDMA_92
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew #-31956,%a0@
    jbra SONIC_CAMDMA_BA
SONIC_CAMDMA_92:        /* (32-bit bus value) */
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew #-31988,%a0@
    jbra SONIC_CAMDMA_BA
SONIC_CAMDMA_9E:        /* older revision */
    tstl %a4@(4)
    jbeq SONIC_CAMDMA_B0
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew #812,%a0@
    jbra SONIC_CAMDMA_BA
SONIC_CAMDMA_B0:        /* (other bus width) */
    moveal %a4@,%a0
    moveal %a0@(4),%a0
    movew #780,%a0@
SONIC_CAMDMA_BA:        /* CAM enable, descriptor count, descriptor pointer (upper, lower) */
    moveal %a4@(12),%a0
    moveal %a4@,%a1
    moveal %a1@(156),%a1
    movew %a0@(2),%a1@
    moveal %a4@(12),%a0
    movew %a0@(2),%a3@(18)
    moveal %a4@(16),%a0
    addql #4,%a0
    movel %a0,%fp@(-4)
    movel %fp@(-4),%d5
    movel #-65536,%d0
    andl %d5,%d0
    moveq #16,%d1
    lsrl %d1,%d0
    moveal %a4@,%a0
    moveal %a0@(80),%a0
    movew %d0,%a0@
    moveal %a4@,%a0
    moveal %a0@(80),%a0
    movew %a0@,%a3@(20)
    moveal %a4@(16),%a0
    addql #4,%a0
    movel %a0,%fp@(-4)
    movel %fp@(-4),%d5
    movel #65535,%d0
    andl %d5,%d0
    moveal %a4@,%a0
    moveal %a0@(152),%a0
    movew %d0,%a0@
    moveal %a4@,%a0
    moveal %a0@(152),%a0
    movew %a0@,%a3@(22)
    moveal %a4@,%a0
    moveal %a0@,%a0
    movew %a0@,%d4
    moveq #0,%d0
    movew %d4,%d0
    movel #65407,%d1
    andl %d0,%d1
    moveal %a4@,%a0
    moveal %a0@,%a0
    movew %d1,%a0@
    moveal %a4@,%a0
    moveal %a0@,%a0
    movew %a0@,%d4
    movew #512,%d0
    orw %d4,%d0
    moveal %a4@,%a0
    moveal %a0@,%a0
    movew %d0,%a0@
    movel %a4@(24),%sp@-
    pea 0x1000
    moveal %a4@,%a0
    movel %a0@(20),%sp@-
    movel %fp@(8),%sp@-
    moveal %a4@(20),%a0
    jsr %a0@
    moveb %d0,%d6
    lea %sp@(16),%sp
    jbeq SONIC_CAMDMA_180
    moveal %a4@,%a0
    moveal %a0@(20),%a0
    movew %a0@,%a3@(16)
    moveq #5,%d6
    jbra SONIC_CAMDMA_264
SONIC_CAMDMA_180:       /* done: check the configuration register again */
    moveal %a4@,%a0
    moveal %a0@(20),%a0
    movew %a0@,%a3@(16)
    moveal %a4@,%a0
    moveal %a0@,%a0
    movew #148,%a0@
    moveal %a4@,%a0
    moveal %a0@,%a0
    cmpiw #148,%a0@
    jbeq SONIC_CAMDMA_1A2
    moveq #3,%d6
    jbra SONIC_CAMDMA_264
SONIC_CAMDMA_1A2:       /* compare each CAM entry */
    moveq #0,%d7
    jbra SONIC_CAMDMA_258
SONIC_CAMDMA_1A8:       /* entry d7: select it, compare word 0 */
    moveal %a4@(12),%a0
    movel %d7,%d0
    asll #2,%d0
    asll #2,%d0
    moveal %a4@,%a1
    moveal %a1@(132),%a1
    movew %a0@(0x6,%d0:l),%a1@
    moveal %a4@(12),%a0
    movel %d7,%d0
    asll #2,%d0
    asll #2,%d0
    movel %a0@(0x4,%d0:l),%a3@(8)
    moveq #0,%d0
    movel %d0,%a3@(4)
    moveal %a4@(12),%a0
    movel %d7,%d1
    asll #2,%d1
    asll #2,%d1
    movew %a0@(0xa,%d1:l),%a3@(12)
    moveal %a4@,%a0
    moveal %a0@(144),%a0
    movew %a0@,%a3@(14)
    movew %a3@(12),%d1
    cmpw %a3@(14),%d1
    jbeq SONIC_CAMDMA_1FA
    moveq #6,%d6
    jbra SONIC_CAMDMA_264
SONIC_CAMDMA_1FA:       /* word 1 */
    moveq #1,%d0
    movel %d0,%a3@(4)
    moveal %a4@(12),%a0
    movel %d7,%d1
    asll #2,%d1
    asll #2,%d1
    movew %a0@(0xe,%d1:l),%a3@(12)
    moveal %a4@,%a0
    moveal %a0@(140),%a0
    movew %a0@,%a3@(14)
    movew %a3@(12),%d1
    cmpw %a3@(14),%d1
    jbeq SONIC_CAMDMA_228
    moveq #6,%d6
    jbra SONIC_CAMDMA_264
SONIC_CAMDMA_228:       /* word 2 */
    moveq #2,%d0
    movel %d0,%a3@(4)
    moveal %a4@(12),%a0
    movel %d7,%d1
    asll #2,%d1
    asll #2,%d1
    movew %a0@(0x12,%d1:l),%a3@(12)
    moveal %a4@,%a0
    moveal %a0@(136),%a0
    movew %a0@,%a3@(14)
    movew %a3@(12),%d1
    cmpw %a3@(14),%d1
    jbeq SONIC_CAMDMA_256
    moveq #6,%d6
    jbra SONIC_CAMDMA_264
SONIC_CAMDMA_256:       /* next entry */
    addql #1,%d7
SONIC_CAMDMA_258:       /* until all entries are checked: passed */
    moveal %a4@(12),%a0
    cmpl %a0@,%d7
    jblt SONIC_CAMDMA_1A8
    clrb %d6
SONIC_CAMDMA_264:       /* return the result */
    moveq #0,%d0
    moveb %d6,%d0
    moveml %fp@(-28),%d4-%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408CF602

/*
 SONIC_Loopback: transmit and receive test in loopback mode: builds the transmit and receive descriptors and buffers, sends test
 frames, waits, checks the received data and status. Result: an error number.
*/
SONIC_Loopback:
    linkw %fp,#-46
    moveml %d3-%d7/%a3-%a4,%sp@-
    moveal %fp@(16),%a4
    moveal %fp@(12),%a3
    moveq #1,%d5
    moveal %a3@,%a0
    moveal %a0@(160),%a0
    moveq #0,%d0
    movew %a0@,%d0
    movel %d0,%a4@
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew #148,%a0@
    moveal %a3@,%a0
    moveal %a0@,%a0
    cmpiw #148,%a0@
    beqs SONIC_Loopback_36
    moveq #3,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_36:
    moveq #3,%d0
    cmpl %a4@,%d0
    bges SONIC_Loopback_62
    moveal %a3@,%a0
    moveal %a0@(252),%a0
    clrw %a0@
    tstl %a3@(4)
    beqs SONIC_Loopback_56
    moveal %a3@,%a0
    moveal %a0@(4),%a0
    movew #-31959,%a0@
    bras SONIC_Loopback_7E
SONIC_Loopback_56:
    moveal %a3@,%a0
    moveal %a0@(4),%a0
    movew #-31991,%a0@
    bras SONIC_Loopback_7E
SONIC_Loopback_62:
    tstl %a3@(4)
    beqs SONIC_Loopback_74
    moveal %a3@,%a0
    moveal %a0@(4),%a0
    movew #809,%a0@
    bras SONIC_Loopback_7E
SONIC_Loopback_74:
    moveal %a3@,%a0
    moveal %a0@(4),%a0
    movew #777,%a0@
SONIC_Loopback_7E:
    moveal %a3@,%a0
    moveal %a0@(16),%a0
    clrw %a0@
    moveal %a3@,%a0
    moveal %a0@(16),%a0
    tstw %a0@
    beqs SONIC_Loopback_96
    moveq #2,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_96:
    moveal %a3@,%a0
    moveal %a0@(20),%a0
    movew #32767,%a0@
    moveal %a3@,%a0
    moveal %a0@(20),%a0
    tstw %a0@
    beqs SONIC_Loopback_B0
    moveq #4,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_B0:
    tstl %a3@(12)
    beqs SONIC_Loopback_116
    movel %a3,%fp@(-12)
    movel %a4,%fp@(-8)
    moveq #7,%d0
    movel %d0,%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    movel %d0,%fp@(-4)
    pea %fp@(-12)
    pea %fp@(-40)
    movel %fp@(8),%sp@-
    moveal %a3@(40),%a0
    jsr %a0@
    movel %a3@(16),%d0
    subql #1,%d0
    movel %d0,%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    moveal %a3@,%a0
    moveal %a0@(16),%a0
    movew #32767,%a0@
    moveal %a3@,%a0
    moveal %a0@(12),%a0
    andiw #32767,%a0@
    moveal %a3@,%a0
    moveal %a0@(12),%a0
    oriw #-32768,%a0@
    lea %sp@(20),%sp
SONIC_Loopback_116:
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %a0@,%d4
    moveq #0,%d0
    movew %d4,%d0
    movel #65407,%d1
    andl %d0,%d1
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %d1,%a0@
    moveal %a3@,%a0
    moveal %a0@(76),%a0
    movew #760,%a0@
    movel %a3@(52),%d6
    movel #-65536,%d0
    andl %d6,%d0
    moveq #16,%d1
    lsrl %d1,%d0
    moveal %a3@,%a0
    moveal %a0@(52),%a0
    movew %d0,%a0@
    moveal %a3@,%a0
    moveal %a0@(52),%a0
    movew %a0@,%a4@(32)
    movel %a3@(52),%d6
    movel #65535,%d0
    andl %d6,%d0
    moveal %a3@,%a0
    moveal %a0@(56),%a0
    movew %d0,%a0@
    moveal %a3@,%a0
    moveal %a0@(56),%a0
    movew %a0@,%a4@(34)
    movel %a3@(60),%d6
    movel #65534,%d0
    andl %d6,%d0
    moveal %a3@(48),%a0
    movel %d0,%a0@(20)
    moveal %a3@(48),%a0
    movel #65535,%a0@(24)
    moveal %a3@(48),%a0
    moveq #0,%d0
    movel %d0,%a0@
    moveal %a3@(48),%a0
    movel %d0,%a0@(4)
    moveal %a3@(48),%a0
    movel %d0,%a0@(8)
    moveal %a3@(48),%a0
    movel %d0,%a0@(12)
    moveal %a3@(48),%a0
    movel %d0,%a0@(16)
    movel %a3@(68),%d6
    movel #65535,%d1
    andl %d6,%d1
    moveq #1,%d2
    orl %d1,%d2
    moveal %a3@(56),%a0
    movel %d2,%a0@(20)
    moveal %a3@(56),%a0
    movel #65535,%a0@(24)
    moveal %a3@(56),%a0
    movel %d0,%a0@
    moveal %a3@(56),%a0
    movel %d0,%a0@(4)
    moveal %a3@(56),%a0
    movel %d0,%a0@(8)
    moveal %a3@(56),%a0
    movel %d0,%a0@(12)
    moveal %a3@(56),%a0
    movel %d0,%a0@(16)
    movel %a3@(52),%d6
    movel #65535,%d1
    andl %d6,%d1
    moveq #1,%d2
    orl %d1,%d2
    moveal %a3@(64),%a0
    movel %d2,%a0@(20)
    moveal %a3@(64),%a0
    movel #65535,%a0@(24)
    moveal %a3@(64),%a0
    movel %d0,%a0@
    moveal %a3@(64),%a0
    movel %d0,%a0@(4)
    moveal %a3@(64),%a0
    movel %d0,%a0@(8)
    moveal %a3@(64),%a0
    movel %d0,%a0@(12)
    moveal %a3@(64),%a0
    movel %d0,%a0@(16)
    movel %a3@(76),%d6
    movel #-65536,%d1
    andl %d6,%d1
    moveq #16,%d2
    lsrl %d2,%d1
    moveal %a3@,%a0
    moveal %a0@(80),%a0
    movew %d1,%a0@
    movel %a3@(76),%d6
    movel #65535,%d1
    andl %d6,%d1
    moveal %a3@,%a0
    moveal %a0@(84),%a0
    movew %d1,%a0@
    movel #65535,%d1
    andl %d6,%d1
    moveal %a3@,%a0
    moveal %a0@(92),%a0
    movew %d1,%a0@
    movel %a3@(76),%d6
    movel %d6,%d1
    moveq #80,%d2
    addl %d2,%d1
    movel #65535,%d3
    andl %d1,%d3
    moveal %a3@,%a0
    moveal %a0@(88),%a0
    movew %d3,%a0@
    moveal %a3@(76),%a0
    lea %a0@(32),%a0
    movel %a0,%d6
    movel #65535,%d1
    andl %d6,%d1
    moveal %a3@,%a0
    moveal %a0@(96),%a0
    movew %d1,%a0@
    movel %a3@(92),%d6
    movel #-65536,%d1
    andl %d6,%d1
    moveq #16,%d3
    lsrl %d3,%d1
    moveal %a3@(72),%a0
    movel %d1,%a0@(4)
    movel %a3@(92),%d6
    movel #65535,%d1
    andl %d6,%d1
    moveal %a3@(72),%a0
    movel %d1,%a0@
    moveal %a3@(72),%a0
    movel #800,%a0@(8)
    moveal %a3@(72),%a0
    movel %d0,%a0@(12)
    movel %a3@(100),%d6
    movel #-65536,%d1
    andl %d6,%d1
    moveq #16,%d3
    lsrl %d3,%d1
    moveal %a3@(72),%a0
    movel %d1,%a0@(20)
    movel %a3@(100),%d6
    movel #65535,%d1
    andl %d6,%d1
    moveal %a3@(72),%a0
    movel %d1,%a0@(16)
    moveal %a3@(72),%a0
    movel #800,%a0@(24)
    moveal %a3@(72),%a0
    movel %d0,%a0@(28)
    movel %a3@(108),%d6
    movel #-65536,%d1
    andl %d6,%d1
    moveq #16,%d3
    lsrl %d3,%d1
    moveal %a3@(72),%a0
    movel %d1,%a0@(36)
    movel %a3@(108),%d6
    movel #65535,%d1
    andl %d6,%d1
    moveal %a3@(72),%a0
    movel %d1,%a0@(32)
    moveal %a3@(72),%a0
    movel #800,%a0@(40)
    moveal %a3@(72),%a0
    movel %d0,%a0@(44)
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %a0@,%d4
    moveq #0,%d1
    movew %d4,%d1
    movel #65407,%d3
    andl %d1,%d3
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %d3,%a0@
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %a0@,%d4
    movew #256,%d1
    orw %d4,%d1
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %d1,%a0@
    moveal %a3@,%a0
    moveal %a0@(60),%a0
    movew %a0@,%a4@(38)
    moveal %a3@,%a0
    moveal %a0@(64),%a0
    movew %a0@,%a4@(36)
    moveal %a3@,%a0
    moveal %a0@(68),%a0
    movew %a0@,%a4@(42)
    moveal %a3@,%a0
    moveal %a0@(72),%a0
    movew %a0@,%a4@(40)
    moveq #0,%d7
SONIC_Loopback_3D6:
    moveal %a3@(88),%a0
    moveb #0xaa,%a0@(0x0,%d7:l)	| 408CF9EA
    moveal %a3@(96),%a0
    moveb #0xcc,%a0@(0x0,%d7:l)	| 408CF9F4
    addql #1,%d7
    cmpil #1600,%d7
    blts SONIC_Loopback_3D6
    movel %a3@(84),%d6
    movel #-65536,%d0
    andl %d6,%d0
    moveq #16,%d1
    lsrl %d1,%d0
    moveal %a3@,%a0
    moveal %a0@(24),%a0
    movew %d0,%a0@
    movel %a3@(84),%d6
    movel #65535,%d0
    andl %d6,%d0
    moveal %a3@,%a0
    moveal %a0@(28),%a0
    movew %d0,%a0@
    moveal %a3@(80),%a0
    moveq #0,%d0
    movel %d0,%a0@
    moveal %a3@(80),%a0
    movel %d0,%a0@(4)
    moveal %a3@(80),%a0
    movel #1500,%a0@(8)
    moveal %a3@(80),%a0
    moveq #1,%d1
    movel %d1,%a0@(12)
    movel %a3@(116),%d6
    movel #65535,%d2
    andl %d6,%d2
    moveal %a3@(80),%a0
    movel %d2,%a0@(16)
    movel %a3@(116),%d6
    movel #-65536,%d2
    andl %d6,%d2
    moveq #16,%d3
    lsrl %d3,%d2
    moveal %a3@(80),%a0
    movel %d2,%a0@(20)
    moveal %a3@(80),%a0
    movel #1500,%a0@(24)
    moveal %a3@(84),%a0
    lea %a0@(32),%a0
    movel %a0,%d6
    moveq #1,%d2
    cmpl %a3@(8),%d2
    bnes SONIC_Loopback_498
    .short  0x8CBC, 0x0000, 0x0001	| 408CFAA0 orl #1,%d6
    bras SONIC_Loopback_49E
SONIC_Loopback_498:
    .short  0xCCBC, 0x0000, 0xFFFE	| 408CFAA8 andl #65534,%d6
SONIC_Loopback_49E:
    movel #65535,%d0
    andl %d6,%d0
    moveq #0,%d1
    movew %d0,%d1
    moveal %a3@(80),%a0
    movel %d1,%a0@(28)
    moveal %a3@(80),%a0
    moveq #0,%d0
    movel %d0,%a0@(32)
    moveal %a3@(80),%a0
    movel %d0,%a0@(36)
    moveal %a3@(80),%a0
    movel #1500,%a0@(40)
    moveal %a3@(80),%a0
    moveq #2,%d1
    movel %d1,%a0@(44)
    movel %a3@(124),%d6
    movel #65535,%d2
    andl %d6,%d2
    moveal %a3@(80),%a0
    movel %d2,%a0@(48)
    movel %a3@(124),%d6
    movel #-65536,%d2
    andl %d6,%d2
    moveq #16,%d3
    lsrl %d3,%d2
    moveal %a3@(80),%a0
    movel %d2,%a0@(52)
    moveal %a3@(80),%a0
    movel #750,%a0@(56)
    moveal %a3@(124),%a0
    lea %a0@(800),%a0
    movel %a0,%d6
    movel #65535,%d2
    andl %d6,%d2
    moveal %a3@(80),%a0
    movel %d2,%a0@(60)
    moveal %a3@(124),%a0
    lea %a0@(800),%a0
    movel %a0,%d6
    movel #-65536,%d2
    andl %d6,%d2
    moveq #16,%d3
    lsrl %d3,%d2
    moveal %a3@(80),%a0
    movel %d2,%a0@(64)
    moveal %a3@(80),%a0
    movel #750,%a0@(68)
    moveal %a3@(84),%a0
    movel %a0,%d6
    movel #65535,%d2
    andl %d6,%d2
    moveq #1,%d3
    orl %d2,%d3
    moveal %a3@(80),%a0
    movel %d3,%a0@(72)
    moveq #0,%d7
SONIC_Loopback_572:
    moveal %a3@(112),%a0
    moveb #85,%a0@(0x0,%d7:l)
    addql #1,%d7
    cmpil #1500,%d7
    blts SONIC_Loopback_572
    movel #1500,%d7
SONIC_Loopback_58C:
    moveal %a3@(112),%a0
    clrb %a0@(0x0,%d7:l)
    addql #1,%d7
    cmpil #1600,%d7
    blts SONIC_Loopback_58C
    moveq #0,%d7
SONIC_Loopback_5A0:
    moveal %a3@(120),%a0
    moveb #0x99,%a0@(0x0,%d7:l)	| 408CFBB4
    addql #1,%d7
    cmpil #750,%d7
    blts SONIC_Loopback_5A0
    movel #750,%d7
SONIC_Loopback_5BA:
    moveal %a3@(120),%a0
    clrb %a0@(0x0,%d7:l)
    addql #1,%d7
    cmpil #800,%d7
    blts SONIC_Loopback_5BA
    movel #800,%d7
SONIC_Loopback_5D2:
    moveal %a3@(120),%a0
    moveb #51,%a0@(0x0,%d7:l)
    addql #1,%d7
    cmpil #1550,%d7
    blts SONIC_Loopback_5D2
    movel #1550,%d7
SONIC_Loopback_5EC:
    moveal %a3@(120),%a0
    clrb %a0@(0x0,%d7:l)
    addql #1,%d7
    cmpil #1600,%d7
    blts SONIC_Loopback_5EC
    moveal %a3@(24),%a0
    moveal %a3@,%a1
    moveal %a1@(156),%a1
    movew %a0@(2),%a1@
    moveal %a3@(28),%a0
    addql #4,%a0
    movel %a0,%d6
    movel #-65536,%d0
    andl %d6,%d0
    moveq #16,%d1
    lsrl %d1,%d0
    moveal %a3@,%a0
    moveal %a0@(80),%a0
    movew %d0,%a0@
    moveal %a3@(28),%a0
    addql #4,%a0
    movel %a0,%d6
    movel #65535,%d0
    andl %d6,%d0
    moveal %a3@,%a0
    moveal %a0@(152),%a0
    movew %d0,%a0@
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %a0@,%d4
    moveq #0,%d0
    movew %d4,%d0
    movel #65407,%d1
    andl %d0,%d1
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %d1,%a0@
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %a0@,%d4
    movew #512,%d0
    orw %d4,%d0
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew %d0,%a0@
    tstl %a3@(12)
    beqs SONIC_Loopback_67C
    lea %a4@(16),%a0
    movel %a0,%fp@(-44)
    movel %a0,%d0
    bras SONIC_Loopback_688
SONIC_Loopback_67C:
    moveal %a3@,%a0
    movel %a0@(20),%fp@(-44)
    movel %a0@(20),%d0
SONIC_Loopback_688:
    movel %a3@(36),%sp@-
    pea 0x1000
    movel %fp@(-44),%sp@-
    movel %fp@(8),%sp@-
    moveal %a3@(32),%a0
    jsr %a0@
    moveb %d0,%d5
    lea %sp@(16),%sp
    beqs SONIC_Loopback_6B6
    moveq #5,%d5
    moveal %a3@,%a0
    moveal %a0@(20),%a0
    movew %a0@,%a4@(12)
    braw SONIC_Loopback_A34
SONIC_Loopback_6B6:
    moveal %a3@,%a0
    moveal %a0@(20),%a0
    movew %a0@,%a4@(12)
    tstl %a4@(18)
    beqs SONIC_Loopback_6CC
    moveq #16,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_6CC:
    movel %a3@(8),%d0
    subql #1,%d0
    bmis SONIC_Loopback_710
    cmpil #2,%d0
    bgts SONIC_Loopback_710
    addl %d0,%d0
    movew %pc@(SONIC_Loopback_6CC_1A,%d0:l),%d0	| 408CFCEE
    .short  0x4EFB, 0x0000	| 408CFCF2 jmp %pc@(0x408cfcf4,%d0:w)
SONIC_Loopback_6CC_1A:
    .byte   0x00, 0x08	| 408CFCF6
    orib #32,%a4@
    moveal %a3@,%a0
    moveal %a0@(8),%a0
    movew #-1536,%a0@
    bras SONIC_Loopback_716
    moveal %a3@,%a0
    moveal %a0@(8),%a0
    movew #-1024,%a0@
    bras SONIC_Loopback_716
    moveal %a3@,%a0
    moveal %a0@(8),%a0
    movew #-512,%a0@
    bras SONIC_Loopback_716
SONIC_Loopback_710:
    moveq #6,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_716:
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew #8,%a0@
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew #10,%a0@
    moveal %a3@,%a0
    moveal %a0@(60),%a0
    movew %a0@,%a4@(38)
    moveal %a3@,%a0
    moveal %a0@(64),%a0
    movew %a0@,%a4@(36)
    moveal %a3@,%a0
    moveal %a0@(68),%a0
    movew %a0@,%a4@(42)
    moveal %a3@,%a0
    moveal %a0@(72),%a0
    movew %a0@,%a4@(40)
    movew #1,%a4@(6)
    moveal %a3@(48),%a0
    movel %a0,%fp@(-44)
    movel %a3@(36),%sp@-
    moveq #2,%d0
    movel %d0,%sp@-
    movel %fp@(-44),%sp@-
    movel %fp@(8),%sp@-
    moveal %a3@(32),%a0
    jsr %a0@
    moveb %d0,%d5
    lea %sp@(16),%sp
    beqs SONIC_Loopback_794
    moveq #7,%d5
    moveal %a3@(48),%a0
    movew %a0@(2),%a4@(26)
    moveal %a3@(80),%a0
    movew %a0@(2),%a4@(22)
    braw SONIC_Loopback_A34
SONIC_Loopback_794:
    moveal %a3@(48),%a0
    movew %a0@(2),%a4@(26)
    moveal %a3@(80),%a0
    movew %a0@(2),%a4@(22)
    movew #1102,%d0
    andw %a4@(22),%d0
    beqs SONIC_Loopback_7B8
    moveq #8,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_7B8:
    moveq #12,%d0
    andw %a4@(26),%d0
    beqs SONIC_Loopback_7C6
    moveq #9,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_7C6:
    moveq #0,%d7
SONIC_Loopback_7C8:
    moveal %a3@(112),%a0
    moveb %a0@(0x0,%d7:l),%a4@(4)
    moveal %a3@(88),%a0
    moveb %a0@(0x0,%d7:l),%a4@(5)
    movel %d7,%a4@(8)
    moveb %a4@(5),%d0
    cmpb %a4@(4),%d0
    bnes SONIC_Loopback_7F6
    tstb %a4@(5)
    beqs SONIC_Loopback_7F6
    tstb %a4@(4)
    bnes SONIC_Loopback_7FC
SONIC_Loopback_7F6:
    moveq #10,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_7FC:
    addql #1,%d7
    cmpil #1500,%d7
    blts SONIC_Loopback_7C8
    moveq #1,%d0
    cmpl %a3@(8),%d0
    beqw SONIC_Loopback_9A4
    moveal %a3@,%a0
    moveal %a0@(60),%a0
    movew %a0@,%a4@(38)
    moveal %a3@,%a0
    moveal %a0@(64),%a0
    movew %a0@,%a4@(36)
    moveal %a3@,%a0
    moveal %a0@(68),%a0
    movew %a0@,%a4@(42)
    moveal %a3@,%a0
    moveal %a0@(72),%a0
    movew %a0@,%a4@(40)
    movew #2,%a4@(6)
    moveq #0,%d0
    movel %d0,%a4@(8)
    clrb %a4@(4)
    clrb %a4@(5)
    moveal %a3@(56),%a0
    movel %a0,%fp@(-44)
    movel %a3@(36),%sp@-
    moveq #2,%d1
    movel %d1,%sp@-
    movel %fp@(-44),%sp@-
    movel %fp@(8),%sp@-
    moveal %a3@(32),%a0
    jsr %a0@
    moveb %d0,%d5
    lea %sp@(16),%sp
    beqs SONIC_Loopback_88C
    moveq #11,%d5
    moveal %a3@(56),%a0
    movew %a0@(2),%a4@(28)
    moveal %a3@(80),%a0
    movew %a0@(34),%a4@(24)
    braw SONIC_Loopback_A34
SONIC_Loopback_88C:
    moveal %a3@(56),%a0
    movew %a0@(2),%a4@(28)
    moveal %a3@(80),%a0
    movew %a0@(34),%a4@(24)
    movew #1102,%d0
    andw %a4@(24),%d0
    beqs SONIC_Loopback_8B0
    moveq #12,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_8B0:
    moveq #12,%d0
    andw %a4@(28),%d0
    beqs SONIC_Loopback_8BE
    moveq #13,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_8BE:
    moveq #0,%d7
SONIC_Loopback_8C0:
    moveal %a3@(120),%a0
    moveb %a0@(0x0,%d7:l),%a4@(4)
    moveal %a3@(96),%a0
    moveb %a0@(0x0,%d7:l),%a4@(5)
    movel %d7,%a4@(8)
    moveb %a4@(5),%d0
    cmpb %a4@(4),%d0
    bnes SONIC_Loopback_8EE
    tstb %a4@(5)
    beqs SONIC_Loopback_8EE
    tstb %a4@(4)
    bnes SONIC_Loopback_8F4
SONIC_Loopback_8EE:
    moveq #14,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_8F4:
    addql #1,%d7
    cmpil #750,%d7
    blts SONIC_Loopback_8C0
    movel #750,%d7
SONIC_Loopback_904:
    moveal %a3@(120),%a0
    moveb %a0@(0x32,%d7:l),%a4@(4)
    moveal %a3@(96),%a0
    moveb %a0@(0x0,%d7:l),%a4@(5)
    movel %d7,%a4@(8)
    moveb %a4@(5),%d0
    cmpb %a4@(4),%d0
    bnes SONIC_Loopback_932
    tstb %a4@(5)
    beqs SONIC_Loopback_932
    tstb %a4@(4)
    bnes SONIC_Loopback_938
SONIC_Loopback_932:
    moveq #15,%d5
    braw SONIC_Loopback_A34
SONIC_Loopback_938:
    addql #1,%d7
    cmpil #1500,%d7
    blts SONIC_Loopback_904
    moveq #1,%d0
    cmpl %a3@(8),%d0
    sne %d0
    negb %d0
    extbl %d0
    andl %a3@(12),%d0
    beqs SONIC_Loopback_9A4
    moveal %a3@(80),%a0
    moveq #0,%d0
    movel %d0,%a0@
    moveal %a3@(80),%a0
    oril #1,%a0@(28)
    moveal %a3@(80),%a0
    andil #65534,%a0@(72)
    moveal %a3@,%a0
    moveal %a0@,%a0
    movew #10,%a0@
    moveal %a3@,%a0
    moveal %a0@(60),%a0
    movew %a0@,%a4@(38)
    moveal %a3@,%a0
    moveal %a0@(64),%a0
    movew %a0@,%a4@(36)
    moveal %a3@,%a0
    moveal %a0@(68),%a0
    movew %a0@,%a4@(42)
    moveal %a3@,%a0
    moveal %a0@(72),%a0
    movew %a0@,%a4@(40)
SONIC_Loopback_9A4:
    clrb %d5
    tstl %a3@(12)
    beqw SONIC_Loopback_A34
    moveq #7,%d0
    movel %d0,%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    moveal %a3@,%a0
    moveal %a0@(16),%a0
    clrw %a0@
    pea %fp@(-12)
    pea %fp@(-40)
    movel %fp@(8),%sp@-
    moveal %a3@(44),%a0
    jsr %a0@
    movel %fp@(-4),%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    tstl %a4@(18)
    lea %sp@(20),%sp
    beqs SONIC_Loopback_9F2
    moveq #16,%d5

    jbra SONIC_Loopback_A34
SONIC_Loopback_9F2:
    movel %a3@(8),%d0
    subql #1,%d0
    bmis SONIC_Loopback_9F2_40
    cmpil #2,%d0
    bgts SONIC_Loopback_9F2_40
    addl %d0,%d0
    movew %pc@(SONIC_Loopback_9F2_1A,%d0:l),%d0	| 408D0014
    .short  0x4EFB, 0x0000	| 408D0018 jmp %pc@(0x408d001a,%d0:w)
SONIC_Loopback_9F2_1A:
    .byte   0x00, 0x08	| 408D001C
    orib #24,%a0@+
    movew %a4@(16),%d4
    andiw #7680,%d4
    tstw %d4
    bnes SONIC_Loopback_A34
    moveq #17,%d5
    jbra SONIC_Loopback_A34
    .short  0x382C, 0x0010, 0x0244, 0x1E60, 0x4A44, 0x6606	| 408D0032
    moveq #17,%d5
    jbra SONIC_Loopback_A34
SONIC_Loopback_9F2_40:
    moveq #6,%d5
SONIC_Loopback_A34:     /* error found: count of collisions/retries from the status words */
    moveq #0,%d0
    movew %a4@(22),%d0
    movel #63488,%d1
    andl %d0,%d1
    movew %d1,%fp@(-46)
    moveq #0,%d0
    movew %fp@(-46),%d0
    moveq #11,%d1
    lsrl %d1,%d0
    movew %d0,%a4@(30)
    moveq #0,%d0
    movew %a4@(24),%d0
    movel #63488,%d1
    andl %d0,%d1
    movew %d1,%fp@(-46)
    moveq #0,%d0
    movew %fp@(-46),%d0
    moveq #11,%d1
    lsrl %d1,%d0
    addw %d0,%a4@(30)
    tstb %d5
    jbeq SONIC_Loopback_AB8
    tstl %a3@(12)
    jbeq SONIC_Loopback_AB8
    moveq #7,%d0
    movel %d0,%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    moveal %a3@,%a0
    moveal %a0@(16),%a0
    clrw %a0@
    pea %fp@(-12)
    pea %fp@(-40)
    movel %fp@(8),%sp@-
    moveal %a3@(44),%a0
    jsr %a0@
    movel %fp@(-4),%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    lea %sp@(20),%sp
SONIC_Loopback_AB8:     /* return the result */
    moveq #0,%d0
    moveb %d5,%d0
    moveml %fp@(-74),%d3-%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408D00D6

/*
 SONIC_InterruptHandler: interrupt handler during the tests: reads the interrupt status
 register, records each bit set in the test state (+16), stops at the first one that
 ends the test with a result (+18), acknowledges the interrupt.
*/
SONIC_InterruptHandler:
    linkw %fp,#-4
    moveml %d4-%d7/%a3-%a4,%sp@-
    movel %fp@(20),%fp@(-4)
    moveal %fp@(-4),%a0
    moveal %a0@,%a4
    moveal %fp@(-4),%a0
    moveal %a0@(4),%a3
    moveal %a4@,%a0
    moveal %a0@(20),%a0
    movew %a0@,%d6
    moveq #1,%d0
    movel %d0,%a3@(18)
    moveq #0,%d7
SONIC_InterruptHandler_2C:  /* next status bit (0..14) */
    moveq #1,%d5
    movew %d5,%d0
    lslw %d7,%d0
    andw %d6,%d0
    movew %d0,%a3@(14)
    jbeq SONIC_InterruptHandler_190
    subqw #1,%d0
    jbeq SONIC_InterruptHandler_A8
    subqw #1,%d0
    jbeq SONIC_InterruptHandler_B8
    subqw #2,%d0
    jbeq SONIC_InterruptHandler_C2
    subqw #4,%d0
    jbeq SONIC_InterruptHandler_D2
    subqw #8,%d0
    jbeq SONIC_InterruptHandler_DC
    subiw #16,%d0
    jbeq SONIC_InterruptHandler_E6
    subiw #32,%d0
    jbeq SONIC_InterruptHandler_112
    subiw #64,%d0
    jbeq SONIC_InterruptHandler_130
    subiw #128,%d0
    jbeq SONIC_InterruptHandler_138
    subiw #256,%d0
    jbeq SONIC_InterruptHandler_146
    subiw #512,%d0
    jbeq SONIC_InterruptHandler_14E
    subiw #1024,%d0
    jbeq SONIC_InterruptHandler_156
    subiw #2048,%d0
    jbeq SONIC_InterruptHandler_15E
    subiw #4096,%d0
    jbeq SONIC_InterruptHandler_166
    subiw #8192,%d0
    jbeq SONIC_InterruptHandler_16E
    jbra SONIC_InterruptHandler_17C
SONIC_InterruptHandler_A8:  /* bit 0 RFO (receive FIFO overrun): result 3 */
    oriw #1,%a3@(16)
    moveq #3,%d0
    movel %d0,%a3@(18)
    jbra SONIC_InterruptHandler_1A0
SONIC_InterruptHandler_B8:  /* bit 1 MP (missed packet counter rollover) */
    oriw #2,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_C2:  /* bit 2 FAE (frame alignment error counter): result 6 */
    oriw #4,%a3@(16)
    moveq #6,%d0
    movel %d0,%a3@(18)
    jbra SONIC_InterruptHandler_1A0
SONIC_InterruptHandler_D2:  /* bit 3 CRC (CRC error counter) */
    oriw #8,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_DC:  /* bit 4 RBAE (receive buffer area exceeded) */
    oriw #16,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_E6:  /* bit 5 RBE (receive buffers exhausted): move the resource write pointer */
    moveal %a4@(76),%a0
    lea %a0@(48),%a0
    movel %a0,%d4
    movel #65535,%d0
    andl %d4,%d0
    moveal %a4@,%a0
    moveal %a0@(96),%a0
    movew %d0,%a0@
    moveal %a4@,%a0
    moveal %a0@(16),%a0
    andiw #32735,%a0@
    oriw #32,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_112:  /* bit 6 RDE (receive descriptors exhausted): clear the end-of-list bit */
    moveal %a4@(56),%a0
    andil #65534,%a0@(20)
    moveal %a4@,%a0
    moveal %a0@(16),%a0
    andiw #32703,%a0@
    oriw #64,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_130:  /* bit 7 TC (timer complete) */
    oriw #128,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_138:  /* bit 8 TXER (transmit error): result 4 */
    oriw #256,%a3@(16)
    moveq #4,%d0
    movel %d0,%a3@(18)
    jbra SONIC_InterruptHandler_1A0
SONIC_InterruptHandler_146:  /* bit 9 TXDN (transmission done) */
    oriw #512,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_14E:  /* bit 10 PKTRX (packet received) */
    oriw #1024,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_156:  /* bit 11 PINT (programmable interrupt) */
    oriw #2048,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_15E:  /* bit 12 LCD (load CAM done) */
    oriw #4096,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_166:  /* bit 13 HBL (heartbeat lost) */
    oriw #8192,%a3@(16)
    jbra SONIC_InterruptHandler_190
SONIC_InterruptHandler_16E:  /* bit 14 BR (bus retry): result 5 */
    oriw #16384,%a3@(16)
    moveq #5,%d0
    movel %d0,%a3@(18)
    jbra SONIC_InterruptHandler_1A0
SONIC_InterruptHandler_17C:  /* unexpected bit: result 2 */
    moveq #2,%d0
    movel %d0,%a3@(18)
    moveal %a4@,%a0
    moveal %a0@(20),%a0
    movew %d6,%a0@
    movew %d6,%a3@(14)
    jbra SONIC_InterruptHandler_1A0
SONIC_InterruptHandler_190:  /* next bit, result 0 after all */
    addql #1,%d7
    moveq #15,%d0
    cmpl %d7,%d0
    jbgt SONIC_InterruptHandler_2C
    moveq #0,%d0
    movel %d0,%a3@(18)
SONIC_InterruptHandler_1A0:  /* acknowledge the interrupts */
    moveal %a4@,%a0
    moveal %a0@(20),%a0
    movew %d6,%a0@
    moveml %fp@(-28),%d4-%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408D0292

/*
 Timeout(reg, mask, count): poll the 16-bit register until (reg & mask) is nonzero, at
 most count times. Result: 0, or 6 on timeout.
*/
Timeout:
    moveml %d5-%d7/%a3,%sp@-
    movel %sp@(32),%d5
    movew %sp@(30),%d6
    moveal %sp@(24),%a3
    moveq #0,%d7
    jbra Timeout_1C
Timeout_14:             /* reg & mask? */
    movew %d6,%d0
    andw %a3@,%d0
    jbne Timeout_24
    addql #1,%d7
Timeout_1C:             /* count */
    cmpl %d7,%d5
    jbgt Timeout_14
    moveq #6,%d0
    jbra Timeout_26
Timeout_24:             /* 0: the bit came */
    moveq #0,%d0
Timeout_26:             /* return */
    moveml %sp@+,%d5-%d7/%a3
    rts
    .long   0x00000000	| 408D02CC

/*
 GetMyPhysicalAddress(env, &address, size): translate the logical address of a buffer
 to a physical one (through the service table, +100), checking that it is contiguous
 (one range of the requested size). Result: 0, or 2.
*/
GetMyPhysicalAddress:
    linkw %fp,#-72
    moveml %d5-%d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    movel %fp@(16),%d7
    moveal %fp@(12),%a3
    moveq #1,%d5
    movel %a3@,%fp@(-72)
    movel %d7,%fp@(-68)
    moveq #8,%d6
    cmpl %fp@(-60),%d7
    jbne GetMyPhysicalAddress_2C
    movel %fp@(-64),%a3@
    jbra GetMyPhysicalAddress_54
GetMyPhysicalAddress_2C:  /* translate it */
    movel %d7,%sp@-
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@
    movel %a3@,%fp@(-72)
    movel %d7,%fp@(-68)
    moveq #8,%d6
    cmpl %fp@(-60),%d7
    addql #8,%sp
    jbne GetMyPhysicalAddress_50
    movel %fp@(-64),%a3@
    jbra GetMyPhysicalAddress_54
GetMyPhysicalAddress_50:  /* not contiguous: 2 */
    moveq #2,%d0
    jbra GetMyPhysicalAddress_56
GetMyPhysicalAddress_54:  /* 0 */
    moveq #0,%d0
GetMyPhysicalAddress_56:  /* return */
    moveml %fp@(-92),%d5-%d7/%a3-%a4
    unlk %fp
    rts

/*
 SONIC_Init_CAMDMA_params: allocate the CAM descriptor area (264 bytes), get its
 physical address, fill it with the 16 CAM entries from the caller's table, enable mask
 0xFFFF, and set the Timeout routine and its count. Result: 0 or 3 (no memory).
*/
SONIC_Init_CAMDMA_params:
    linkw %fp,#0
    moveml %d3/%d6-%d7/%a3-%a4,%sp@-
    moveal %fp@(16),%a4
    moveal %fp@(12),%a3
    moveq #1,%d6
    pea MemTop
    movel %fp@(8),%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(100),%a0
    jsr %a0@
    movel %d0,%a3@(12)
    addql #8,%sp
    jbne SONIC_Init_CAMDMA_params_32
    moveq #3,%d6
    moveb %d6,%d0
    jbra SONIC_Init_CAMDMA_params_A4
SONIC_Init_CAMDMA_params_32:  /* physical address unless the caller says it is not needed */
    movel %a3@(12),%a3@(16)
    movel #-2147483648,%d0
    andl %fp@(20),%d0
    jbne SONIC_Init_CAMDMA_params_60
    pea MemTop
    pea %a3@(16)
    movel %fp@(8),%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d6
    lea %sp@(12),%sp
    jbeq SONIC_Init_CAMDMA_params_60
    moveb %d6,%d0
    jbra SONIC_Init_CAMDMA_params_A4
SONIC_Init_CAMDMA_params_60:  /* 16 entries, copy the CAM table */
    moveal %a3@(12),%a0
    moveq #16,%d0
    movel %d0,%a0@
    moveq #0,%d7
    moveq #64,%d3
SONIC_Init_CAMDMA_params_6C:  /* copy loop */
    movel %d7,%d0
    asll #2,%d0
    moveal %a3@(12),%a0
    movel %d7,%d1
    asll #2,%d1
    movel %a4@(0x0,%d0:l),%a0@(0x4,%d1:l)
    addql #1,%d7
    cmpl %d7,%d3
    jbgt SONIC_Init_CAMDMA_params_6C
    moveal %a3@(12),%a0
    movel #65535,%a0@(260)
    lea %pc@(Timeout),%a0
    movel %a0,%a3@(20)
    movel #8192,%a3@(24)
    clrb %d6
    moveb %d6,%d0
SONIC_Init_CAMDMA_params_A4:  /* return */
    moveml %fp@(-20),%d3/%d6-%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000	| 408D03DE

/*
 SONIC_Init_Loopback_params: allocate the loopback test structures (CAM area, transmit
 and receive descriptors, receive resource area, 4 receive buffers of 0x640 bytes, the
 frame buffers), get their physical addresses, fill the CAM, set Timeout and its count.
 Result: 0 or 3 (no memory) or the address translation error.
*/
SONIC_Init_Loopback_params:
    linkw %fp,#0
    moveml %d3/%d6-%d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %fp@(12),%a3
    moveq #1,%d7
    pea MemTop
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(24)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_2E
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_2E:  /* transmit descriptor (28 bytes) */
    movel %a3@(24),%a3@(28)
    moveq #28,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(48)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_50
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_50:  /* receive descriptor */
    movel %a3@(48),%a3@(52)
    moveq #28,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(56)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_72
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_72:  /* receive descriptor */
    movel %a3@(56),%a3@(60)
    moveq #28,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(64)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_94
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_94:  /* receive resource area (80 bytes) */
    movel %a3@(64),%a3@(68)
    moveq #80,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(72)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_B6
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_B6:  /* receive descriptor area (76 bytes) */
    movel %a3@(72),%a3@(76)
    moveq #76,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(80)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_D8
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_D8:  /* buffer 1 (0x640 bytes) */
    movel %a3@(80),%a3@(84)
    pea 0x640
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(88)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_FA
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_FA:  /* buffer 2 */
    movel %a3@(88),%a3@(92)
    pea 0x640
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(96)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_11C
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_11C:  /* buffer 3 */
    movel %a3@(96),%a3@(100)
    pea 0x640
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(104)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_13E
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_13E:  /* buffer 4 */
    movel %a3@(104),%a3@(108)
    pea 0x640
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(112)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_160
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_160:  /* buffer 5 */
    movel %a3@(112),%a3@(116)
    pea 0x640
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(120)
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_182
    moveq #3,%d7
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_182:  /* 8 bytes more, then the physical addresses */
    movel %a3@(120),%a3@(124)
    moveq #8,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    moveal %a4@(100),%a0
    jsr %a0@
    movel %d0,%a3@(128)
    movel #-2147483648,%d0
    andl %fp@(20),%d0
    addql #8,%sp
    jbne SONIC_Init_Loopback_params_2BA
    pea MemTop
    pea %a3@(28)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_1C4
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_1C4:  /* physical address of each area */
    moveq #28,%d0
    movel %d0,%sp@-
    pea %a3@(52)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_1E0
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_1E0:  /* ... */
    moveq #28,%d0
    movel %d0,%sp@-
    pea %a3@(60)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_1FC
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_1FC:  /* ... */
    moveq #80,%d0
    movel %d0,%sp@-
    pea %a3@(76)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_218
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_218:  /* ... */
    moveq #76,%d0
    movel %d0,%sp@-
    pea %a3@(84)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_234
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_234:  /* ... */
    pea 0x640
    pea %a3@(92)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_250
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_250:  /* ... */
    pea 0x640
    pea %a3@(100)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_26C
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_26C:  /* ... */
    pea 0x640
    pea %a3@(108)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_286
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_286:  /* ... */
    pea 0x640
    pea %a3@(116)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_2A0
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_2A0:  /* ... */
    pea 0x640
    pea %a3@(124)
    movel %a4,%sp@-
    jsr %pc@(GetMyPhysicalAddress)
    moveb %d0,%d7
    lea %sp@(12),%sp
    jbeq SONIC_Init_Loopback_params_2BA
    moveb %d7,%d0
    jbra SONIC_Init_Loopback_params_302
SONIC_Init_Loopback_params_2BA:  /* 16 CAM entries from the caller's table */
    moveal %a3@(24),%a0
    moveq #16,%d0
    movel %d0,%a0@
    moveq #0,%d6
    moveq #64,%d3
SONIC_Init_Loopback_params_2C6:  /* copy loop */
    moveal %fp@(16),%a0
    movel %d6,%d0
    asll #2,%d0
    moveal %a3@(24),%a1
    movel %d6,%d1
    asll #2,%d1
    movel %a0@(0x0,%d0:l),%a1@(0x4,%d1:l)
    addql #1,%d6
    cmpl %d6,%d3
    jbgt SONIC_Init_Loopback_params_2C6
    moveal %a3@(24),%a0
    movel #65535,%a0@(260)
    lea %pc@(Timeout),%a0
    movel %a0,%a3@(32)
    movel #1048575,%a3@(36)
    clrb %d7
    moveb %d7,%d0
SONIC_Init_Loopback_params_302:  /* return */
    moveml %fp@(-20),%d3/%d6-%d7/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000	| 408D06EC

/*
 Eclipse_SONIC_Install_Interrupt_Handler: on the Quadra 700/900/950 (built-in SONIC):
 save and mask the VIA 1 and VIA 2 interrupt enables and two other interrupt registers,
 enable the Ethernet interrupt, then install SONIC_InterruptHandler (level 3) through
 the service table, interrupts masked meanwhile.
*/
Eclipse_SONIC_Install_Interrupt_Handler:
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(24),%a0
    moveal %a0@,%a4
    moveal #1357913088,%a3
    moveal %a4@(128),%a0
    moveb %a3@,%a0@(2)
    moveb #127,%a3@
    moveal #1357921280,%a3
    moveal %a4@(128),%a0
    moveb %a3@,%a0@(3)
    moveb #127,%a3@
    moveal #1357991689,%a3
    moveal %a4@(128),%a0
    moveb %a3@,%a0@(4)
    orib #1,%a3@
    moveal #1357991721,%a3
    moveal %a4@(128),%a0
    moveb %a3@,%a0@(5)
    orib #1,%a3@
    moveal #1357906944,%a3
    moveal %a4@(128),%a0
    moveb %a3@,%a0@(1)
    orib #64,%a3@
    moveal #1357905920,%a3
    moveal %a4@(128),%a0
    moveb %a3@,%a0@
    andib #0xbf,%a3@
    moveq #7,%d0
    movel %d0,%sp@-
    moveal %sp@(16),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    movel %d0,%d7
    moveq #27,%d0
    movel %d0,%sp@-
    movel %sp@(24),%sp@-
    pea %pc@(SONIC_InterruptHandler)
    movel %sp@(20),%sp@-
    movel %sp@(16),%sp@-
    moveal %sp@(16),%a0
    moveal %a0@(72),%a0
    jsr %a0@
    movel %d7,%sp@-
    moveal %sp@(16),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    lea %sp@(28),%sp
    moveml %sp@+,%d7/%a3-%a4
    rts
    .long   0x00000000, 0x00000000	| 408D07A8

/*
 ci_PDS_SONIC_Install_Interrupt_Handler: the same for a PDS Ethernet card: only installs
 the handler.
*/
ci_PDS_SONIC_Install_Interrupt_Handler:
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a4
    moveal %sp@(16),%a3
    moveq #7,%d0
    movel %d0,%sp@-
    moveal %a3@(84),%a0
    jsr %a0@
    movel %d0,%d7
    moveq #27,%d0
    movel %d0,%sp@-
    movel %sp@(24),%sp@-
    pea %pc@(SONIC_InterruptHandler)
    movel %a4,%sp@-
    movel %a3,%sp@-
    moveal %a3@(72),%a0
    jsr %a0@
    movel %d7,%sp@-
    moveal %a3@(84),%a0
    jsr %a0@
    lea %sp@(28),%sp
    moveml %sp@+,%d7/%a3-%a4
    rts

/*
 Eclipse_SONIC_Remove_Interrupt_Handler: restore the saved interrupt registers and
 remove the handler.
*/
Eclipse_SONIC_Remove_Interrupt_Handler:
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(24),%a0
    moveal %a0@,%a4
    moveq #7,%d0
    movel %d0,%sp@-
    moveal %sp@(16),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    movel %d0,%d7
    moveal #1357906944,%a3
    moveal %a4@(128),%a0
    moveb %a0@(1),%a3@
    moveal #1357905920,%a3
    moveal %a4@(128),%a0
    moveb %a0@,%d0
    .short  0xC03C, 0x0040	| 408D0824 andb #64,%d0
    addql #4,%sp
    jbeq Eclipse_SONIC_Remove_Interrupt_Handler_46
    orib #64,%a3@
    moveq #0,%d0
    moveb %a3@,%d0
    jbra Eclipse_SONIC_Remove_Interrupt_Handler_4E
Eclipse_SONIC_Remove_Interrupt_Handler_46:  /* (other bit value) */
    andib #0xbf,%a3@
    moveq #0,%d0
    moveb %a3@,%d0
Eclipse_SONIC_Remove_Interrupt_Handler_4E:  /* restore the VIA and other registers */
    moveal #1357913088,%a3
    moveal %a4@(128),%a0
    moveb %a0@(2),%a3@
    moveal #1357921280,%a3
    moveal %a4@(128),%a0
    moveb %a0@(3),%a3@
    moveal #1357991689,%a3
    moveal %a4@(128),%a0
    moveb %a0@(4),%a3@
    moveal #1357991721,%a3
    moveal %a4@(128),%a0
    moveb %a0@(5),%a3@
    movel %sp@(20),%sp@-
    movel %sp@(16),%sp@-
    moveal %sp@(16),%a0
    moveal %a0@(76),%a0
    jsr %a0@
    movel %d7,%sp@-
    moveal %sp@(16),%a0
    moveal %a0@(84),%a0
    jsr %a0@
    lea %sp@(12),%sp
    moveml %sp@+,%d7/%a3-%a4
    rts
    .short  0x0000	| 408D089E

/* ci_PDS_SONIC_Remove_Interrupt_Handler: remove the handler (PDS card). */
ci_PDS_SONIC_Remove_Interrupt_Handler:
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a4
    moveal %sp@(16),%a3
    moveq #7,%d0
    movel %d0,%sp@-
    moveal %a3@(84),%a0
    jsr %a0@
    movel %d0,%d7
    movel %a4,%sp@-
    movel %a3,%sp@-
    moveal %a3@(76),%a0
    jsr %a0@
    movel %d7,%sp@-
    moveal %a3@(84),%a0
    jsr %a0@
    lea %sp@(16),%sp
    moveml %sp@+,%d7/%a3-%a4
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408D08D4

/*
 SONIC_Test: entry of the SONIC tests. Builds the CAM test pattern table on the stack,
 turns the 68040 caches off (machine kind 5) while it runs, picks the SONIC's address
 for the machine (0x50F0A000 built in, 0x5000A000, 0x50F2A000, 0x50F32100 on other
 models), then runs test 155 (registers), 156 (CAM by DMA) or 157 (loopback, with the
 interrupt handler routines for the machine). Result: the test's, -13 for an unknown
 test, 0x10001 for an unknown machine.
*/
SONIC_Test:
    linkw %fp,#-526
    moveml %d4-%d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %fp@(20),%a3
    moveq #4,%d4
    moveal %fp@(12),%a0
    movel %a0@(4),%fp@(-264)
    movel #43690,%fp@(-4)
    movel #43690,%fp@(-8)
    movel #43690,%fp@(-12)
    moveq #15,%d0
    movel %d0,%fp@(-16)
    movel #65535,%fp@(-20)
    movel #65535,%fp@(-24)
    movel #65535,%fp@(-28)
    moveq #14,%d1
    movel %d1,%fp@(-32)
    movel #4369,%fp@(-36)
    movel #4369,%fp@(-40)
    movel #4369,%fp@(-44)
    moveq #13,%d0
    movel %d0,%fp@(-48)
    movel #8738,%fp@(-52)
    moveq #0,%d0
    movel %d0,%fp@(-56)
    movel %d0,%fp@(-60)
    moveq #12,%d0
    movel %d0,%fp@(-64)
    moveq #0,%d0
    movel %d0,%fp@(-68)
    movel #24576,%fp@(-72)
    movel #37896,%fp@(-76)
    moveq #11,%d0
    movel %d0,%fp@(-80)
    movel #1544,%fp@(-84)
    movel #1892,%fp@(-88)
    movel #2420,%fp@(-92)
    moveq #10,%d0
    movel %d0,%fp@(-96)
    movel #1032,%fp@(-100)
    movel #6498,%fp@(-104)
    movel #801,%fp@(-108)
    moveq #9,%d0
    movel %d0,%fp@(-112)
    movel #57022,%fp@(-116)
    movel #65259,%fp@(-120)
    movel #48879,%fp@(-124)
    moveq #8,%d0
    movel %d0,%fp@(-128)
    movel #56026,%fp@(-132)
    movel #64206,%fp@(-136)
    movel #26505,%fp@(-140)
    moveq #7,%d0
    movel %d0,%fp@(-144)
    movel #9029,%fp@(-148)
    movel #61185,%fp@(-152)
    movel #43981,%fp@(-156)
    moveq #6,%d0
    movel %d0,%fp@(-160)
    movel #43605,%fp@(-164)
    movel #23130,%fp@(-168)
    movel #21930,%fp@(-172)
    moveq #5,%d0
    movel %d0,%fp@(-176)
    movel #32512,%fp@(-180)
    movel #53183,%fp@(-184)
    movel #63471,%fp@(-188)
    moveq #4,%d0
    movel %d0,%fp@(-192)
    movel #64763,%fp@(-196)
    movel #65534,%fp@(-200)
    movel #16512,%fp@(-204)
    moveq #3,%d0
    movel %d0,%fp@(-208)
    movel #4128,%fp@(-212)
    movel #1032,%fp@(-216)
    movel #258,%fp@(-220)
    moveq #2,%d0
    movel %d0,%fp@(-224)
    movel #1798,%fp@(-228)
    movel #2312,%fp@(-232)
    movel #2826,%fp@(-236)
    moveq #1,%d0
    movel %d0,%fp@(-240)
    movel #256,%fp@(-244)
    movel #770,%fp@(-248)
    movel #1284,%fp@(-252)
    moveq #0,%d0
    movel %d0,%fp@(-256)
    moveq #5,%d2
    cmpl %a4@(4),%d2
    jbne SONIC_Test_216
    pea %fp@(-268)
    movec %cacr,%d0
    moveal %sp@,%a0
    movel %d0,%a0@
    moveq #0,%d0
    movel %d0,%sp@-
    movel %sp@,%d0
    movec %d0,%cacr
    cpusha %bc
    addql #8,%sp
SONIC_Test_216:         /* SONIC address by machine kind */
    movel %fp@(-264),%d0
    subil #20,%d0
    jbeq SONIC_Test_23C
    subql #2,%d0
    jbeq SONIC_Test_244
    subql #4,%d0
    jbeq SONIC_Test_23C
    subql #2,%d0
    jbeq SONIC_Test_24C
    subil #62,%d0
    jbeq SONIC_Test_254
    subql #1,%d0
    jbeq SONIC_Test_25C
    jbra SONIC_Test_264
SONIC_Test_23C:         /* built-in SONIC at 0x50F0A000 */
    movel #1357946880,%d6
    jbra SONIC_Test_26E
SONIC_Test_244:         /* (the same) */
    movel #1357946880,%d6
    jbra SONIC_Test_26E
SONIC_Test_24C:         /* at 0x5000A000 */
    movel #1342218240,%d6
    jbra SONIC_Test_26E
SONIC_Test_254:         /* at 0x50F2A000 */
    movel #1358077952,%d6
    jbra SONIC_Test_26E
SONIC_Test_25C:         /* at 0x50F32100 */
    movel #1358110976,%d6
    jbra SONIC_Test_26E
SONIC_Test_264:         /* unknown machine: 0x10001 */
    movel #65537,%d5
    jbra SONIC_Test_432
SONIC_Test_26E:         /* the register address table: 64 registers, 4 bytes apart */
    lea %fp@(-256),%a0
    movel %a0,%fp@(-260)
    moveq #0,%d7
SONIC_Test_278:         /* register address d7 */
    movel %d4,%d0
    mulsl %d7,%d0
    addl %d6,%d0
    addql #2,%d0
    movel %d7,%d1
    asll #2,%d1
    lea %fp@(-526),%a0
    movel %d0,%a0@(0x0,%d1:l)
    addql #1,%d7
    moveq #64,%d0
    cmpl %d7,%d0
    jbgt SONIC_Test_278
    moveal %fp@(12),%a0
    movel #-2147483648,%d0
    andl %a0@,%d0
    jbne SONIC_Test_2AA
    moveb #1,%fp@(-269)
SONIC_Test_2AA:         /* test number 155..157? */
    movel %fp@(24),%d0
    subil #155,%d0
    jbcs SONIC_Test_430
    cmpil #2,%d0
    jbhi SONIC_Test_430
    addl %d0,%d0
    movew %pc@(SONIC_Test_2CC,%d0:l),%d0
SONIC_Test_2C8:         /* jump through the table */
    jmp %pc@(0,%d0:w)
SONIC_Test_2CC:         /* offsets of the three tests */
    .short  SONIC_Test_2D2-(SONIC_Test_2C8+2)	| 408D0BAC
    .short  SONIC_Test_2FE-(SONIC_Test_2C8+2)	| 408D0BAE
    .short  SONIC_Test_34C-(SONIC_Test_2C8+2)	| 408D0BB0
SONIC_Test_2D2:         /* address %fp@(-526) */
    lea %fp@(-526),%a0
    movel %a0,%a3@
    moveq #1,%d0
    movel %d0,%a3@(4)
    moveal %fp@(12),%a0
    movel #256,%d1
    andl %a0@,%d1
    movel %d1,%a3@(8)
    movel %a4,%sp@-
    moveal %a4@(44),%a0
    jsr %a0@
    movel %d0,%d5
    addql #4,%sp
    jbra SONIC_Test_432
SONIC_Test_2FE:         /* address %fp@(-526) */
    lea %fp@(-526),%a0
    movel %a0,%a3@
    moveq #1,%d0
    movel %d0,%a3@(4)
    moveal %fp@(12),%a0
    movel %a0@,%sp@-
    movel %fp@(-260),%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    jsr %pc@(SONIC_Init_CAMDMA_params)
    moveq #0,%d1
    moveb %d0,%d1
    movel %d1,%d5
    moveal %fp@(12),%a0
    movel #256,%d0
    andl %a0@,%d0
    movel %d0,%a3@(8)
    tstl %d5
    lea %sp@(16),%sp
    jbne SONIC_Test_432
    movel %a4,%sp@-
    moveal %a4@(44),%a0
    jsr %a0@
    movel %d0,%d5
    addql #4,%sp
    jbra SONIC_Test_432
SONIC_Test_34C:         /* address %fp@(-526) */
    lea %fp@(-526),%a0
    movel %a0,%a3@
    moveq #1,%d0
    movel %d0,%a3@(4)
    moveal %fp@(12),%a0
    movel %a0@,%sp@-
    movel %fp@(-260),%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    jsr %pc@(SONIC_Init_Loopback_params)
    moveq #0,%d1
    moveb %d0,%d1
    movel %d1,%d5
    lea %sp@(16),%sp
    jbne SONIC_Test_432
    moveal %fp@(12),%a0
    moveq #3,%d0
    andl %a0@,%d0
    movel %d0,%a3@(8)
    moveal %fp@(12),%a0
    moveq #16,%d0
    andl %a0@,%d0
    movel %d0,%a3@(12)
    moveal %fp@(12),%a0
    movel #768,%d0
    andl %a0@,%d0
    movel %d0,%a3@(20)
    movel %fp@(-264),%d0
    subil #20,%d0
    jbeq SONIC_Test_3C2
    subql #2,%d0
    jbeq SONIC_Test_3DA
    subql #4,%d0
    jbeq SONIC_Test_3C2
    subql #2,%d0
    jbeq SONIC_Test_3F2
    subil #63,%d0
    jbeq SONIC_Test_40A
    jbra SONIC_Test_420
SONIC_Test_3C2:         /* Quadra built-in SONIC: Eclipse interrupt routines */
    lea %pc@(Eclipse_SONIC_Install_Interrupt_Handler),%a0
    movel %a0,%a3@(40)
    lea %pc@(Eclipse_SONIC_Remove_Interrupt_Handler),%a0
    movel %a0,%a3@(44)
    moveq #3,%d0
    movel %d0,%a3@(16)
    jbra SONIC_Test_420
SONIC_Test_3DA:         /* (the same) */
    lea %pc@(Eclipse_SONIC_Install_Interrupt_Handler),%a0
    movel %a0,%a3@(40)
    lea %pc@(Eclipse_SONIC_Remove_Interrupt_Handler),%a0
    movel %a0,%a3@(44)
    moveq #3,%d0
    movel %d0,%a3@(16)
    jbra SONIC_Test_420
SONIC_Test_3F2:         /* PDS card: its interrupt routines */
    lea %pc@(ci_PDS_SONIC_Install_Interrupt_Handler),%a0
    movel %a0,%a3@(40)
    lea %pc@(ci_PDS_SONIC_Remove_Interrupt_Handler),%a0
    movel %a0,%a3@(44)
    moveq #3,%d0
    movel %d0,%a3@(16)
    jbra SONIC_Test_420
SONIC_Test_40A:         /* (the same) */
    lea %pc@(ci_PDS_SONIC_Install_Interrupt_Handler),%a0
    movel %a0,%a3@(40)
    lea %pc@(ci_PDS_SONIC_Remove_Interrupt_Handler),%a0
    movel %a0,%a3@(44)
    moveq #3,%d0
    movel %d0,%a3@(16)
SONIC_Test_420:         /* run the loopback test */
    movel %a4,%sp@-
    moveal %a4@(44),%a0
    jsr %a0@
    movel %d0,%d5
    addql #4,%sp
    jbne SONIC_Test_432
    jbra SONIC_Test_432
SONIC_Test_430:         /* unknown test: -13 */
    moveq #-13,%d5
SONIC_Test_432:         /* caches back on */
    moveq #5,%d0
    cmpl %a4@(4),%d0
    jbne SONIC_Test_446
    movel %fp@(-268),%sp@-
    movel %sp@,%d0
    movec %d0,%cacr
    addql #4,%sp
SONIC_Test_446:         /* return the result */
    movel %d5,%d0
    moveml %fp@(-550),%d4-%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408D0D32

/*
 FPSPPATCH / GENEXCEPTPATCH: patch to the end of the Motorola FPSP general exception
 exit: restore the FPU control registers, and if the saved FPU state frame is not idle
 replace it with a clean one (or clear a flag for a busy frame), then continue in
 GENEXCEPTPATCHRTN.
*/
FPSPPATCH:
GENEXCEPTPATCH:
    fmoveml %fp@(-128),%fpiar/%fpsr/%fpcr
    frestore %sp@+
    fsave %sp@-
    tstb %sp@(1)
    jbne FPSPPATCH_2A
    tstb %sp@
    jbeq FPSPPATCH_30
    clrl %sp@
    moveq #10,%d0
FPSPPATCH_18:           /* build an idle frame */
    clrl %sp@-
    dbf %d0,FPSPPATCH_18
    movel #1093664768,%sp@-
    movel %fp@(-192),%d0
    jbra FPSPPATCH_30
FPSPPATCH_2A:           /* busy frame: clear the flag in the exception frame */
    bclr #4,%fp@(-232)
FPSPPATCH_30:           /* restore the FPU state */
    frestore %sp@+
    jbra GENEXCEPTPATCHRTN
    .fill   0x7C8, 1, 0x00
