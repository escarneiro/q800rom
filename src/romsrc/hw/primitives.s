/*
 hw/primitives.s - ADB, clock/PRAM and Power Manager primitives tables
 From ADBPRIMITIVES (0x408B2BD0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 Hardware primitives selected per machine through the ProductInfo record (+52 clock and
 PRAM, +56 ADB, Power Manager through its own lookup). Each table starts with a count
 word, then offsets of the routines from the table. The labels are named after the last
 Apple name before them (QUADRAADBTABLE_xx, EGRETCLOCKPRAM_xx) and do not say which
 table a routine belongs to: the comments do.
 ADB tables, 6 entries: 0 initialise (sets the transaction routine at ADB globals
 +304), 1..3 machine-specific (autopoll control), 4 poll for a pending ADB interrupt
 (used with interrupts masked), 5 filter called before each service routine.
 VIA ADB (shift register): globals +348 command being sent, +350 state (bit 4 busy,
 5 and 6 status from the transceiver, 7 auto-poll reply), +312 where to continue at the
 next shift register interrupt, +355 receive buffer, +364 auto-poll address.
*/

/* ADBPRIMITIVES: entry count (6) of the first ADB table. */
ADBPRIMITIVES:
    .short  0x0006	| 408B2BD0
VIAADBTABLE:            /* VIA shift register ADB: init _18, poll _206 */
    .long   QUADRAADBTABLE_18-VIAADBTABLE	| 408B2BD2
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408B2BD6
    .long   QUADRAADBTABLE_206-VIAADBTABLE	| 408B2BE2
    .short  0x0000, 0x0000, 0x0006	| 408B2BE6
PMGRADBTABLE:           /* ADB through the Power Manager: init _218, autopoll _22A, poll _338 */
    .long   QUADRAADBTABLE_218-PMGRADBTABLE	| 408B2BEC
    .long   QUADRAADBTABLE_22A-PMGRADBTABLE	| 408B2BF0
    .long   0x00000000, 0x00000000	| 408B2BF4
    .long   QUADRAADBTABLE_338-PMGRADBTABLE	| 408B2BFC
    .short  0x0000, 0x0000, 0x0006	| 408B2C00
EGRETADBTABLE:          /* ADB through Egret: init _34A, autopoll off _466 / on _46A, poll _206 */
    .long   QUADRAADBTABLE_34A-EGRETADBTABLE	| 408B2C06
    .short  0x0000, 0x0000	| 408B2C0A
    .long   QUADRAADBTABLE_466-EGRETADBTABLE	| 408B2C0E
    .long   QUADRAADBTABLE_46A-EGRETADBTABLE	| 408B2C12
    .long   QUADRAADBTABLE_206-EGRETADBTABLE	| 408B2C16
    .short  0x0000, 0x0000, 0x0006	| 408B2C1A
IOPADBTABLE:            /* ADB through the ADB IOP: init _486, poll _57E */
    .long   QUADRAADBTABLE_486-IOPADBTABLE	| 408B2C20
    .long   0x00000000	| 408B2C24
    .long   QUADRAADBTABLE_57E-IOPADBTABLE	| 408B2C28
IOPADBTABLE_C:          /* (inside the table) */
    .long   0x00000000	| 408B2C2C
    .long   QUADRAADBTABLE_57E-IOPADBTABLE	| 408B2C30
    .short  0x0000, 0x0000, 0x0006	| 408B2C34
QUADRAADBTABLE:         /* Quadra ADB (IOP): init _486, poll _57E, power key _58A, filter _594 */
    .long   QUADRAADBTABLE_486-QUADRAADBTABLE	| 408B2C3A
    .short  0x0000, 0x0000	| 408B2C3E
    .long   QUADRAADBTABLE_57E-QUADRAADBTABLE	| 408B2C42
    .short  0x0000, 0x0000	| 408B2C46
    .long   QUADRAADBTABLE_58A-QUADRAADBTABLE	| 408B2C4A
    .long   QUADRAADBTABLE_594-QUADRAADBTABLE	| 408B2C4E
QUADRAADBTABLE_18:      /* VIA ADB init: SR interrupt handler (_1B0), transaction routine _38, SR interrupt on */
    lea %pc@(QUADRAADBTABLE_1B0),%a0
    movel %a0,Lvl1DT_2
    lea %pc@(QUADRAADBTABLE_38),%a0
    movel %a0,%a3@(304)
    moveal VIA,%a0
    oriw #1792,%sr
    moveb #0x84,%a0@(7168)
    rts
QUADRAADBTABLE_38:      /* VIA ADB transaction: d3 = command, or negative for auto-poll of the last address */
    moveal VIA,%a1
    bset #4,%a3@(350)
    jbne QUADRAADBTABLE_84
    tstl %d3
    jbpl QUADRAADBTABLE_96
    moveb %a3@(364),%d3
    lslb #4,%d3
    orib #12,%d3
    jbsr QUADRAADBTABLE_E6
    jbeq QUADRAADBTABLE_A4
    moveb %a3@(348),%a3@(366)
    jbsr QUADRAADBTABLE_86
    btst #2,%a3@(349)
    jbne QUADRAADBTABLE_7E
    movew TimeVIADB,%d0
    lsrw #4,%d0
QUADRAADBTABLE_6E:      /* wait a little (TimeVIADB / 16 loops) */
    btst #0,%a1@
    dbf %d0,QUADRAADBTABLE_6E
    jbsr QUADRAADBTABLE_7E
    jbra RUNADBREQUEST

QUADRAADBTABLE_7E:      /* not busy any more */
    bclr #4,%a3@(350)
QUADRAADBTABLE_84:      /* busy: return */
    rts

QUADRAADBTABLE_86:      /* end the auto-poll: transceiver state to idle, then read the reply */
    moveq #48,%d1
    jbsr QUADRAADBTABLE_11C
    orib #0x90,%a3@(350)
    moveq #32,%d1
    jbra QUADRAADBTABLE_B2
QUADRAADBTABLE_96:      /* explicit command: Listen goes to _156 (send data) */
    moveq #12,%d0
    andb %d3,%d0
    subqb #8,%d0
    jbeq QUADRAADBTABLE_156
    jbsr QUADRAADBTABLE_E6
    jbne QUADRAADBTABLE_B0
QUADRAADBTABLE_A4:      /* auto-poll reply / service request: mark it, restore the command */
    bset #7,%a3@(350)
    moveb %a3@(366),%a3@(348)
QUADRAADBTABLE_B0:      /* Talk or other: state "even byte" */
    moveq #16,%d1
QUADRAADBTABLE_B2:      /* shift in the reply bytes (wait for each SR interrupt) */
    jbsr QUADRAADBTABLE_11C
    jbne QUADRAADBTABLE_BC
    bset #5,%a3@(350)
QUADRAADBTABLE_BC:      /* first reply byte */
    clrb %a3@(355)
    jbsr QUADRAADBTABLE_13C
    jbne QUADRAADBTABLE_CA
    bset #6,%a3@(350)
QUADRAADBTABLE_CA:      /* further bytes, at most 8 */
    jbsr QUADRAADBTABLE_13C
    jbeq QUADRAADBTABLE_D6
    cmpib #8,%a3@(355)
    jbcs QUADRAADBTABLE_CA
QUADRAADBTABLE_D6:      /* timed out (bit 5): reply count 0, then complete (_1BE) */
    btst #5,%a3@(350)
    seq %d0
    andb %d0,%a3@(355)
    jbra QUADRAADBTABLE_1BE

QUADRAADBTABLE_E6:      /* send the command byte d3 through the shift register (state 0) */
    andib #31,%a3@(350)
    movew %sr,%d0
    oriw #1792,%sr
    moveq #48,%d1
    andb %a1@,%d1
    cmpib #48,%d1
    jbne QUADRAADBTABLE_102
    btst #3,%a1@
    jbeq QUADRAADBTABLE_114
QUADRAADBTABLE_102:     /* shift register out, command byte, transceiver state 0 */
    orib #28,%a1@(5632)
    moveb %d3,%a1@(5120)
    moveb %d3,%a3@(348)
    andib #0xcf,%a1@
QUADRAADBTABLE_114:     /* continue at the next SR interrupt (return address saved at +312) */
    movel %sp@+,%a3@(312)
    movew %d0,%sr
    rts

QUADRAADBTABLE_11C:     /* next transceiver state (d1 into VIA port B bits 4-5), wait for SR */
    tstb %a1@
    tstb %a1@
    tstb %a1@
    tstb %a1@
    tstb %a1@
    tstb %a1@
    tstb %a1@
    bclr #4,%a1@(5632)
    tstb %a1@(5120)
    eorb %d1,%a1@
    movel %sp@+,%a3@(312)
    rts

QUADRAADBTABLE_13C:     /* store the byte shifted in, toggle the state, wait for SR */
    lea %a3@(355),%a0
    moveq #1,%d0
    addb %a0@,%d0
    moveb %d0,%a0@
    moveb %a1@(5120),%a0@(0x0,%d0:w)
    eorib #48,%a1@
    movel %sp@+,%a3@(312)
    rts
QUADRAADBTABLE_156:     /* Listen: send the d2 data bytes (2..8) from a2 */
    subqb #2,%d2
    jbcc QUADRAADBTABLE_15C
    moveq #0,%d2
QUADRAADBTABLE_15C:     /* at most 8 bytes */
    subqb #6,%d2
    jbls QUADRAADBTABLE_162
    moveq #0,%d2
QUADRAADBTABLE_162:     /* count, data pointer at +308, send the command */
    addqb #8,%d2
    moveb %d2,%a3@(355)
    movel %a2,%a3@(308)
    jbsr QUADRAADBTABLE_E6
    jbeq QUADRAADBTABLE_A4
    jbsr QUADRAADBTABLE_192
    jbne QUADRAADBTABLE_17E
    bset #5,%a3@(350)
QUADRAADBTABLE_17E:     /* send each data byte */
    jbsr QUADRAADBTABLE_196
    jbne QUADRAADBTABLE_188
    bset #6,%a3@(350)
QUADRAADBTABLE_188:     /* until all are sent, then complete */
    tstb %a3@(355)
    jbeq QUADRAADBTABLE_1BE
    jbsr QUADRAADBTABLE_196
    jbra QUADRAADBTABLE_188

QUADRAADBTABLE_192:     /* send a data byte in state 1 */
    moveq #16,%d1
    jbra QUADRAADBTABLE_198

QUADRAADBTABLE_196:     /* send a data byte in state 3 */
    moveq #48,%d1
QUADRAADBTABLE_198:     /* next byte to the shift register, wait for SR */
    moveal %a3@(308),%a0
    moveb %a0@+,%a1@(5120)
    movel %a0,%a3@(308)
    subqb #1,%a3@(355)
    eorb %d1,%a1@
    movel %sp@+,%a3@(312)
    rts
QUADRAADBTABLE_1B0:     /* VIA SR interrupt handler: continue where the transaction waits */
    moveal ADBBase,%a3
    moveal %a3@(312),%a0
    btst #3,%a1@
    jmp %a0@

QUADRAADBTABLE_1BE:     /* transaction done: next auto-poll address, then the ADB Manager */
    moveb %a3@(350),%d0
    moveb %a3@(348),%d1
    moveq #64,%d3
    andb %d0,%d3
    negl %d3
    moveb %d1,%d3
    lsrb #4,%d1
    tstl %d3
    jbpl QUADRAADBTABLE_1E4
    movew %a3@(334),%d2
    bset %d1,%d2
QUADRAADBTABLE_1DA:     /* (SRQ) next address present in the device map */
    addqb #1,%d1
    andib #15,%d1
    btst %d1,%d2
    jbeq QUADRAADBTABLE_1DA
QUADRAADBTABLE_1E4:     /* d2/a2 = reply, explicit or implicit (auto-poll) completion */
    moveb %d1,%a3@(364)
    lea %a3@(355),%a0
    moveq #0,%d2
    moveb %a0@+,%d2
    moveal %a0,%a2
    clrb %a3@(350)
    btst #7,%d0
    jbne IMPLICITREQUESTDONE
    jbra EXPLICITREQUESTDONE

QUADRAADBTABLE_206:     /* poll: SR interrupt pending in VIA 1? call the handler */
    moveal VIA,%a1
    btst #2,%a1@(6656)
    jbeq QUADRAADBTABLE_216
    movel Lvl1DT_2,%sp@-
QUADRAADBTABLE_216:     /* done */
    rts

QUADRAADBTABLE_218:     /* Power Manager ADB init: transaction routine _24C, interrupt _2C2 */
    lea %pc@(QUADRAADBTABLE_24C),%a0
    movel %a0,%a3@(304)
    lea %pc@(QUADRAADBTABLE_2C2),%a0
    movel %a0,Lvl1DT_2
    rts

QUADRAADBTABLE_22A:     /* Power Manager ADB: PMgrOp 0x24 with one byte (autopoll control) */
    moveml %d0/%a0,%sp@-
    moveb #1,%sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #1,%sp@-
    movew #36,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(14),%sp
    moveml %sp@+,%d0/%a0
    rts
QUADRAADBTABLE_24C:     /* Power Manager ADB transaction (PMgrOp ADB command) */
    moveal VIA,%a1	| 408B2E86
    moveb #16,%a1@(7168)	| 408B2E8A
    lea %sp@(-12),%sp	| 408B2E90
    moveal %sp,%a0	| 408B2E94
    movel %a0,%sp@-	| 408B2E96
    movel %a0,%sp@-	| 408B2E98
    moveq #3,%d0	| 408B2E9A
    addb %d2,%d0	| 408B2E9C
    movew %d0,%sp@-	| 408B2E9E
    movew #32,%sp@-	| 408B2EA0
    moveq #0,%d0	| 408B2EA4
    tstl %d3	| 408B2EA6
    jbmi QUADRAADBTABLE_27A	| 408B2EA8
    bset #1,%a3@(350)	| 408B2EAA
    jbne QUADRAADBTABLE_2B6	| 408B2EB0
    jbra QUADRAADBTABLE_2A4	| 408B2EB2
QUADRAADBTABLE_27A:     /* set %d3 */
    moveb %a3@(364),%d3	| 408B2EB4
    jbmi QUADRAADBTABLE_2B6	| 408B2EB8
    btst #1,0xdd5	| 408B2EBA
    jbeq QUADRAADBTABLE_29C	| 408B2EC0
    moveb #0x86,%d0	| 408B2EC2
    swap %d0	| 408B2EC6
    movew %a3@(334),%d0	| 408B2EC8
    movel %d0,%a0@	| 408B2ECC
    movew #4,%sp@(2)	| 408B2ECE
    jbra QUADRAADBTABLE_2B2	| 408B2ED4
QUADRAADBTABLE_29C:     /* set %d0 */
    moveq #4,%d0	| 408B2ED6
    lslb #4,%d3	| 408B2ED8
    orib #12,%d3	| 408B2EDA
QUADRAADBTABLE_2A4:     /* set %a0@+ */
    moveb %d3,%a0@+	| 408B2EDE
    moveb %d0,%a0@+	| 408B2EE0
    moveb %d2,%a0@+	| 408B2EE2
    jbra QUADRAADBTABLE_2AE	| 408B2EE4
QUADRAADBTABLE_2AC:     /* loop: move */
    moveb %a2@+,%a0@+	| 408B2EE6
QUADRAADBTABLE_2AE:     /* count down */
    dbf %d2,QUADRAADBTABLE_2AC	| 408B2EE8
QUADRAADBTABLE_2B2:     /* set %a0 */
    moveal %sp,%a0	| 408B2EEC
    _PMgrOp	| 408B2EEE
QUADRAADBTABLE_2B6:     /* address %sp@(24) */
    lea %sp@(24),%sp	| 408B2EF0
    moveb #0x90,%a1@(7168)	| 408B2EF4
    rts	| 408B2EFA
QUADRAADBTABLE_2C2:     /* Power Manager ADB interrupt: reply to the ADB Manager */
    moveal ADBBase,%a3	| 408B2EFC
    moveb %a0@+,%d1	| 408B2F00
    moveb %a0@+,%d0	| 408B2F02
    moveq #8,%d3	| 408B2F04
    andb %d0,%d3	| 408B2F06
    negl %d3	| 408B2F08
    moveb %d1,%d3	| 408B2F0A
    moveb %d3,%a3@(348)	| 408B2F0C
    moveb %d3,%a3@(366)	| 408B2F10
    lsrb #4,%d1	| 408B2F14
    bset #7,%d1	| 408B2F16
    btst #1,0xdd5	| 408B2F1A
    jbeq QUADRAADBTABLE_2F4	| 408B2F20
    btst #1,%d0	| 408B2F22
    jbne QUADRAADBTABLE_308	| 408B2F26
    bclr #7,%d1	| 408B2F28
    jbra QUADRAADBTABLE_308	| 408B2F2C
QUADRAADBTABLE_2F4:     /* test %d3 */
    tstl %d3	| 408B2F2E
    jbpl QUADRAADBTABLE_308	| 408B2F30
    movew %a3@(334),%d2	| 408B2F32
    bset %d1,%d2	| 408B2F36
QUADRAADBTABLE_2FE:     /* loop: addq */
    addqb #1,%d1	| 408B2F38
    andib #15,%d1	| 408B2F3A
    btst %d1,%d2	| 408B2F3E
    jbeq QUADRAADBTABLE_2FE	| 408B2F40
QUADRAADBTABLE_308:     /* set %a3@(364) */
    moveb %d1,%a3@(364)	| 408B2F42
    moveq #0,%d2	| 408B2F46
    moveb %a0@+,%d2	| 408B2F48
    moveal %a0,%a2	| 408B2F4A
    btst #2,%d0	| 408B2F4C
    jbne QUADRAADBTABLE_332	| 408B2F50
    btst #1,0xdd5	| 408B2F52
    jbne QUADRAADBTABLE_326	| 408B2F58
    bclr #7,%a3@(364)	| 408B2F5A
QUADRAADBTABLE_326:     /* clear bit 1 of %a3@(350) */
    bclr #1,%a3@(350)	| 408B2F60
    .byte   0x60, 0xFF	| 408B2F66
    .long   EXPLICITREQUESTDONE-.	| 408B2F68
QUADRAADBTABLE_332:     /* continue at IMPLICITREQUESTDONE */
    jbra IMPLICITREQUESTDONE	| 408B2F6C

QUADRAADBTABLE_338:     /* poll: Power Manager interrupt pending? call the level 1 handler */
    moveal VIA,%a1
    btst #4,%a1@(6656)
    jbeq QUADRAADBTABLE_348
    movel 0x1a2,%sp@-
QUADRAADBTABLE_348:     /* done */
    rts

QUADRAADBTABLE_34A:     /* Egret ADB init: transaction routine _35A */
    lea %pc@(QUADRAADBTABLE_35A),%a0
    movel %a0,%a3@(304)
    movew #-255,%a3@(388)
    rts
QUADRAADBTABLE_35A:     /* Egret ADB transaction: auto-poll set-up or an explicit command */
    tstl %d3
    jbpl QUADRAADBTABLE_3BA
    btst #5,%a3@(349)
    jbne QUADRAADBTABLE_3A0
    bset #1,%a3@(350)
    jbne QUADRAADBTABLE_3A0
    lea %a3@(388),%a0
    lea %pc@(QUADRAADBTABLE_3A2),%a1
    movel %a1,%a0@(16)
    jbsr QUADRAADBTABLE_3F4
    movel #18415616,%d0
    movew %a3@(334),%d0
    jbsr QUADRAADBTABLE_38E
    movel #16908032,%d0

QUADRAADBTABLE_38E:     /* send an Egret command (d0) with a 20-byte block on the stack */
    lea %sp@(-20),%sp
    moveal %sp,%a0
    movel %d0,%a0@
    clrl %a0@(16)
    jbsr QUADRAADBTABLE_3F4
    lea %sp@(20),%sp
QUADRAADBTABLE_3A0:     /* done */
    rts
QUADRAADBTABLE_3A2:     /* completion of the auto-poll set-up */
    moveq #1,%d3	| 408B2FDC
    andb %a1@+,%d3	| 408B2FDE
    negl %d3	| 408B2FE0
    moveb %a1@+,%d3	| 408B2FE2
    moveq #0,%d2	| 408B2FE4
    movew %d0,%d2	| 408B2FE6
    moveal %a1,%a2	| 408B2FE8
    jbsr QUADRAADBTABLE_450	| 408B2FEA
    jbra IMPLICITREQUESTDONE	| 408B2FEE
QUADRAADBTABLE_3BA:     /* explicit command: command, count, data to the Egret block */
    bset #2,%a3@(350)
    jbne QUADRAADBTABLE_3A0
    moveb %d3,%a3@(369)
    movew %d2,%a3@(374)
    movel %a2,%a3@(376)
    bset #0,%a3@(350)
    jbne QUADRAADBTABLE_3F0
    lea %pc@(QUADRAADBTABLE_3FC),%a0
    movel %a0,%a3@(384)
    lea %a3@(388),%a0
    clrl %a0@(16)
    jbsr QUADRAADBTABLE_3F4
    movel #16842752,%d0
    jbsr QUADRAADBTABLE_38E
QUADRAADBTABLE_3F0:     /* the parameter block at +368 */
    lea %a3@(368),%a0

QUADRAADBTABLE_3F4:     /* send it through the Egret (vector at 0x648) */
    moveq #0,%d1
    moveal 0x648,%a2
    jmp %a2@
QUADRAADBTABLE_3FC:     /* completion of an explicit Egret command (raw words) */
    .short  0x7601, 0xC628, 0x000C, 0x4483, 0x1628	| 408B3036
    .long   0x00017400, 0x34280006, 0x24680008, 0x613C08AB	| 408B3040
    .long   0x0002015E, 0x322B014E, 0x01016628, 0x4FEFFFEC	| 408B3050
    .long   0x204F42A8, 0x001030BC, 0x01083F3C, 0x3020214F	| 408B3060
    .long   0x0008317C, 0x00B30002, 0x317C0002, 0x0006A092	| 408B3070
    .short  0x4FEF, 0x0016, 0x60FF	| 408B3080
    .long   EXPLICITREQUESTDONE-.	| 408B3086
QUADRAADBTABLE_450:     /* set %a3 */
    moveal ADBBase,%a3	| 408B308A
    moveb %d3,%a3@(348)	| 408B308E
    moveb %d3,%a3@(366)	| 408B3092
    moveb %d3,%d0	| 408B3096
    lsrb #4,%d0	| 408B3098
    moveb %d0,%a3@(364)	| 408B309A
    rts	| 408B309E

QUADRAADBTABLE_466:     /* Egret autopoll off (command 0x011B, 0) */
    moveq #0,%d1
    jbra QUADRAADBTABLE_46C

QUADRAADBTABLE_46A:     /* Egret autopoll on (command 0x011B, 3) */
    moveq #3,%d1
QUADRAADBTABLE_46C:     /* 20-byte Egret parameter block on the stack */
    moveq #9,%d0
QUADRAADBTABLE_46E:     /* clear it */
    clrw %sp@-
    dbf %d0,QUADRAADBTABLE_46E
    moveal %sp,%a0
    movew #283,%a0@
    moveb %d1,%a0@(2)
    _EgretDispatch
    lea %sp@(20),%sp
    rts

QUADRAADBTABLE_486:     /* IOP ADB init: transaction routine _4E0, IOP message blocks, receive request */
    lea %pc@(QUADRAADBTABLE_4E0),%a0
    movel %a0,%a3@(304)
    moveb #1,%a3@(374)
    clrb %a3@(375)
    moveb #3,%a3@(376)
    lea %a3@(416),%a0
    movel %a0,%a3@(380)
    moveb #1,%a3@(398)
    moveb #2,%a3@(399)
    moveb #3,%a3@(400)
    moveb #12,%a3@(401)
    lea %a3@(428),%a0
    movel %a0,%a3@(404)
    movel %a0,%a3@(408)
    lea %pc@(QUADRAADBTABLE_536),%a0
    movel %a0,%a3@(412)
    lea %a3@(392),%a0
    _IOPMsgRequest
    moveb #1,%a3@(399)
    rts
QUADRAADBTABLE_4E0:     /* IOP ADB transaction: build the message to the ADB IOP */
    moveq #5,%d0
    addb %d2,%d0
    bclr #0,%a3@(350)
    jbne QUADRAADBTABLE_4FA
    lea %a3@(368),%a0
    lea %a3@(416),%a1
    moveb %d0,%a0@(9)
    jbra QUADRAADBTABLE_506
QUADRAADBTABLE_4FA:     /* (second message block) */
    lea %a3@(392),%a0
    lea %a3@(428),%a1
    moveb %d0,%a0@(10)
QUADRAADBTABLE_506:     /* message: flags, count, command, data */
    movew #24578,%a1@
    tstl %d3
    jbmi QUADRAADBTABLE_52E
    clrw %a1@
    bset #1,%a3@(350)
    jbne QUADRAADBTABLE_528
    moveb #0x80,%a1@+
    moveb %d2,%a1@+
    moveb %d3,%a1@+
    jbra QUADRAADBTABLE_524
QUADRAADBTABLE_522:     /* copy the data bytes */
    moveb %a2@+,%a1@+
QUADRAADBTABLE_524:     /* next */
    dbf %d2,QUADRAADBTABLE_522
QUADRAADBTABLE_528:     /* send it (vector at 0x61C) */
    moveal 0x61c,%a2
    jmp %a2@
QUADRAADBTABLE_52E:     /* auto-poll: the device map instead */
    movew %a3@(334),%a1@(3)
    jbra QUADRAADBTABLE_528
QUADRAADBTABLE_536:     /* IOP message received: reply to the ADB Manager (raw words) */
    .long   0x26780CF8, 0x102B01AC, 0x7604C600, 0x4483162B	| 408B3170
    .long   0x01AE1743, 0x015C1743, 0x016E1402, 0xE80A1742	| 408B3180
    .long   0x016C7400, 0x142B01AD, 0x45EB01AF, 0x08EB0000	| 408B3190
    .long   0x015E0800, 0x000767FF, 0xFFF572EC, 0x08AB0001	| 408B31A0
    .long   0x015E60FF	| 408B31B0
    .long   EXPLICITREQUESTDONE-.	| 408B31B4

QUADRAADBTABLE_57E:     /* poll: IOP interrupt (IOP 1, ADB) */
    movel #134742017,%d0
    jbra IOPINTERRUPT

QUADRAADBTABLE_58A:     /* power key pressed (VIA 2 bit 2)? then PowerOff */
    moveq #2,%d1
    jbsr QUADRAADBTABLE_596
    jbne QUADRAADBTABLE_57E
QUADRAADBTABLE_590:     /* power off (loop if it returns) */
    _PowerOff
    jbra QUADRAADBTABLE_590

QUADRAADBTABLE_594:     /* filter before service routines: test bit 0 */
    moveq #0,%d1

QUADRAADBTABLE_596:     /* read a VIA 2 register, also toggle 2 registers of the device at 0xCC0 */
    moveal ghost_VIA2,%a1
    moveb %a1@(128),%d0
    btst #4,%a1@(6656)
    jbne QUADRAADBTABLE_5DC
    moveal ASCBase,%a1
    cmpaw #-1,%a1
    jbeq QUADRAADBTABLE_5DC
    movew %sr,%sp@-
    oriw #1792,%sr
    tstb %a1@(3849)
    jbne QUADRAADBTABLE_5C8
    moveb #1,%a1@(3849)
    nop
    clrb %a1@(3849)
QUADRAADBTABLE_5C8:     /* second register */
    tstb %a1@(3881)
    jbne QUADRAADBTABLE_5DA
    moveb #1,%a1@(3881)
    nop
    clrb %a1@(3881)
QUADRAADBTABLE_5DA:     /* restore the interrupt level */
    movew %sp@+,%sr
QUADRAADBTABLE_5DC:     /* Z = bit d1 of the VIA 2 value */
    btst %d1,%d0
    rts
    .fill   0x1B6, 1, 0x00
CLOCKPRAMPRIMITIVES:    /* entry count (9) of the first clock/PRAM table */
    .short  0x0009	| 408B33D0
RTCCLOCKPRAM:           /* clock/PRAM through the RTC chip (VIA serial): 9 routine offsets */
    .long   EGRETCLOCKPRAM_17C-RTCCLOCKPRAM	| 408B33D2
    .long   EGRETCLOCKPRAM_1A2-RTCCLOCKPRAM	| 408B33D6
    .long   EGRETCLOCKPRAM_19A-RTCCLOCKPRAM	| 408B33DA
    .long   EGRETCLOCKPRAM_148-RTCCLOCKPRAM	| 408B33DE
    .long   EGRETCLOCKPRAM_164-RTCCLOCKPRAM	| 408B33E2
    .long   EGRETCLOCKPRAM_24-RTCCLOCKPRAM	| 408B33E6
    .long   EGRETCLOCKPRAM_12A-RTCCLOCKPRAM	| 408B33EA
    .long   EGRETCLOCKPRAM_9C-RTCCLOCKPRAM	| 408B33EE
    .long   EGRETCLOCKPRAM_D0-RTCCLOCKPRAM	| 408B33F2
    .short  0x0009	| 408B33F6
PMGRCLOCKPRAM:          /* clock/PRAM through the Power Manager */
    .long   0x00000000, 0x00000000	| 408B33F8
    .long   0x00000000	| 408B3400
    .long   EGRETCLOCKPRAM_31A-PMGRCLOCKPRAM	| 408B3404
    .long   EGRETCLOCKPRAM_2A4-PMGRCLOCKPRAM	| 408B3408
    .long   EGRETCLOCKPRAM_24-PMGRCLOCKPRAM	| 408B340C
    .long   EGRETCLOCKPRAM_268-PMGRCLOCKPRAM	| 408B3410
    .long   EGRETCLOCKPRAM_23A-PMGRCLOCKPRAM	| 408B3414
    .long   EGRETCLOCKPRAM_250-PMGRCLOCKPRAM	| 408B3418
    .short  0x0009	| 408B341C
EGRETCLOCKPRAM:         /* clock/PRAM through Egret (offsets, partly data) */
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408B341E
    .short  0x0000, 0x03EE	| orib #0xee,%d0
    .short  0x0000, 0x03E4	| orib #0xe4,%d0
    orib #36,%d0
    .short  0x0000, 0x03B8	| orib #0xb8,%d0
    .short  0x0000, 0x0386	| orib #0x86,%d0
    .short  0x0000, 0x03A0	| orib #0xa0,%d0

EGRETCLOCKPRAM_24:      /* RTC: read (or with d3 bit 31 write) d3 PRAM bytes at a3, write-protect handled */
    moveml %d7/%a4-%fp,%sp@-
    moveal %a0@(8),%a2
    bclr #31,%d3
    jbeq EGRETCLOCKPRAM_90
    lea %pc@(EGRETCLOCKPRAM_40),%fp
    bigjmp CLKWPOFF, a5
EGRETCLOCKPRAM_40:      /* write: write-protect off first (CLKWPOFF) */
    jbra EGRETCLOCKPRAM_5C
EGRETCLOCKPRAM_42:      /* write one byte (WRXBYTE) */
    swap %d3
    moveb %d3,%d1
    moveb %a3@+,%d2
    movel %a3,%d7
    lea %pc@(EGRETCLOCKPRAM_58),%fp
    bigjmp WRXBYTE, a5
EGRETCLOCKPRAM_58:      /* next */
    moveal %d7,%a3
    addqw #1,%d3
EGRETCLOCKPRAM_5C:      /* count, then the machine's write-protect-on routine */
    swap %d3
    dbf %d3,EGRETCLOCKPRAM_42
    moveal %a1,%fp
    addal %fp@(52),%fp
    movel %fp@(8),%d0
    jbeq EGRETCLOCKPRAM_96
    addal %d0,%fp
    lea %pc@(EGRETCLOCKPRAM_96),%a5
    jmp %fp@
EGRETCLOCKPRAM_76:      /* read one byte (RDXBYTE) */
    swap %d3
    moveb %d3,%d1
    movel %a3,%d7
    lea %pc@(EGRETCLOCKPRAM_8A),%fp
    bigjmp RDXBYTE, a5
EGRETCLOCKPRAM_8A:      /* store it, next */
    moveal %d7,%a3
    moveb %d1,%a3@+
    addqw #1,%d3
EGRETCLOCKPRAM_90:      /* count */
    swap %d3
    dbf %d3,EGRETCLOCKPRAM_76
EGRETCLOCKPRAM_96:      /* done */
    moveml %sp@+,%d7/%a4-%fp
    rts

EGRETCLOCKPRAM_9C:      /* RTC: read the seconds counter (4 bytes, twice until both agree) */
    moveml %a5-%fp,%sp@-
    moveal VIA,%a2
    moveq #1,%d4
EGRETCLOCKPRAM_A6:      /* read the 4 bytes (commands 0x9D, 0x99, 0x95, 0x91) */
    moveq #-99,%d5
    lea Scratch20,%a0
    moveal %a0,%a3
EGRETCLOCKPRAM_AE:      /* one byte */
    moveb %d5,%d1
    lea %pc@(EGRETCLOCKPRAM_B8),%a5
    jmp %pc@(EGRETCLOCKPRAM_1A8)
EGRETCLOCKPRAM_B8:      /* stored, compare the two readings */
    moveb %d1,%a0@+
    subqb #4,%d5
    jbmi EGRETCLOCKPRAM_AE
    movel %a3@+,%d0
    subl %a3@+,%d0
    dbeq %d4,EGRETCLOCKPRAM_A6
    jbeq EGRETCLOCKPRAM_CA
    moveq #-85,%d0
EGRETCLOCKPRAM_CA:      /* d0 = 0, or -85 (clkRdErr) */
    moveml %sp@+,%a5-%fp
    rts

EGRETCLOCKPRAM_D0:      /* RTC: set the seconds counter (write-protect off, 4 bytes, check) */
    moveml %d6/%a2/%a5-%fp,%sp@-
    moveal VIA,%a2
    lea %pc@(EGRETCLOCKPRAM_E0),%a5
    jmp %pc@(EGRETCLOCKPRAM_1A2)
EGRETCLOCKPRAM_E0:      /* retry count, d3 = the time from 0x20C */
    moveq #1,%d5	| 408B34FE
    movel Time,%d3	| 408B3500
EGRETCLOCKPRAM_E6:      /* write the 4 bytes */
    moveq #1,%d6
    moveq #3,%d4
EGRETCLOCKPRAM_EA:      /* loop: move */
    movel %d3,%d1
    swap %d1
    moveb %d6,%d1
    lea %pc@(EGRETCLOCKPRAM_F8),%a5
    jmp %pc@(EGRETCLOCKPRAM_1A8)
EGRETCLOCKPRAM_F8:      /* (next byte) then read it back */
    addqb #4,%d6	| 408B3516
    rorl #8,%d3	| 408B3518
    dbf %d4,EGRETCLOCKPRAM_EA	| 408B351A
    bigjsr READTIME
    jbne EGRETCLOCKPRAM_118
    cmpl Time,%d3
    dbeq %d5,EGRETCLOCKPRAM_E6
    jbeq EGRETCLOCKPRAM_118
    moveq #-86,%d0
EGRETCLOCKPRAM_118:     /* d0 = 0, or -86 (clkWrErr), write-protect on */
    movel %d0,%d3
    lea %pc@(EGRETCLOCKPRAM_122),%a5
    jmp %pc@(EGRETCLOCKPRAM_19A)
EGRETCLOCKPRAM_122:     /* done */
    movel %d3,%d0
    moveml %sp@+,%d6/%a2/%a5-%fp
    rts
EGRETCLOCKPRAM_12A:     /* RTC: ReadXPRam/WriteXPRam: d0 = count/address, d1 bit 12 = read */
    moveal %a0,%a3
    moveal 0xdd8,%a1
    moveal %a1,%a0
    addal %a0@,%a0
    movel %d0,%d3
    btst #12,%d1
    jbne EGRETCLOCKPRAM_140
    bset #31,%d3
EGRETCLOCKPRAM_140:     /* through _24 */
    jbsr EGRETCLOCKPRAM_24
    moveq #0,%d0
    rts
EGRETCLOCKPRAM_148:     /* RTC: read extended PRAM byte d1 (two-byte command 0xB8) */
    andiw #255,%d1
    aslw #3,%d1
    rorb #1,%d1
    rorw #8,%d1
    orib #0xb8,%d1
    lea %pc@(EGRETCLOCKPRAM_15E),%a5
    jmp %pc@(EGRETCLOCKPRAM_1A8)
EGRETCLOCKPRAM_15E:     /* result in d1 */
    andiw #255,%d1
    jmp %a3@
EGRETCLOCKPRAM_164:     /* RTC: write extended PRAM byte d2 at d1 (command 0x38) */
    swap %d1
    moveb %d2,%d1
    swap %d1
    andiw #255,%d1
    aslw #3,%d1
    rorb #1,%d1
    rorw #8,%d1
    orib #56,%d1
    moveal %a3,%a5
    jbra EGRETCLOCKPRAM_1A8
EGRETCLOCKPRAM_17C:     /* RTC: initialise: write-protect off, test register, write-protect on */
    moveal %fp,%a0
    moveal %a1,%a2
    addal %a2@,%a2
    moveal %a2@(8),%a2
    lea %pc@(EGRETCLOCKPRAM_18E),%a5
    jmp %pc@(EGRETCLOCKPRAM_1A2)
EGRETCLOCKPRAM_18E:     /* test register: 0x31 */
    moveq #49,%d1
    lea %pc@(EGRETCLOCKPRAM_198),%a5
    jmp %pc@(EGRETCLOCKPRAM_1A8)
EGRETCLOCKPRAM_198:     /* then write-protect on */
    moveal %a0,%a5
EGRETCLOCKPRAM_19A:     /* RTC: write-protect on (0xD5 to register 0x35) */
    movel #13959221,%d1
    jbra EGRETCLOCKPRAM_1A8
EGRETCLOCKPRAM_1A2:     /* RTC: write-protect off (0x55 to register 0x35) */
    movel #5570613,%d1
EGRETCLOCKPRAM_1A8:     /* RTC: send command d1 (and data, or read a byte), interrupts masked */
    movew %sr,%d2
    oriw #1792,%sr
    swap %d2
    moveb %d1,%d2
    bclr #2,%a2@
    moveq #120,%d0
    andb %d1,%d0
    cmpib #56,%d0
    jbne EGRETCLOCKPRAM_1CA
    lea %pc@(EGRETCLOCKPRAM_1C8),%fp
    jmp %pc@(EGRETCLOCKPRAM_1FC)
EGRETCLOCKPRAM_1C8:     /* extended command: second byte */
    lsrw #8,%d1
EGRETCLOCKPRAM_1CA:     /* read or write? */
    tstb %d2
    jbmi EGRETCLOCKPRAM_1E2
    lea %pc@(EGRETCLOCKPRAM_1D6),%fp
    jmp %pc@(EGRETCLOCKPRAM_1FC)
EGRETCLOCKPRAM_1D6:     /* write: the data byte */
    swap %d1
    lea %pc@(EGRETCLOCKPRAM_1E0),%fp
    jmp %pc@(EGRETCLOCKPRAM_1FC)
EGRETCLOCKPRAM_1E0:     /* done */
    jbra EGRETCLOCKPRAM_1F2
EGRETCLOCKPRAM_1E2:     /* read: the command, then read the byte */
    lea %pc@(EGRETCLOCKPRAM_1EA),%fp
    jmp %pc@(EGRETCLOCKPRAM_1FC)
EGRETCLOCKPRAM_1EA:     /* read */
    lea %pc@(EGRETCLOCKPRAM_1F2),%fp
    jmp %pc@(EGRETCLOCKPRAM_21A)
EGRETCLOCKPRAM_1F2:     /* chip disabled again, interrupts restored, return through a5 */
    bset #2,%a2@
    swap %d2
    movew %d2,%sr
    jmp %a5@
EGRETCLOCKPRAM_1FC:     /* RTC: shift the 8 bits of d1 out (data bit 0, clock bit 1) */
    moveq #7,%d0
EGRETCLOCKPRAM_1FE:     /* one bit */
    swap %d0
    moveb %a2@,%d0
    rorb #1,%d0
    addxb %d1,%d1
    addxb %d0,%d0
    moveb %d0,%a2@
    bclr #1,%a2@
    bset #1,%a2@
    swap %d0
    dbf %d0,EGRETCLOCKPRAM_1FE
    jmp %fp@
EGRETCLOCKPRAM_21A:     /* RTC: shift 8 bits in to d1 (data line set to input) */
    bclr #0,%a2@(1024)
    moveq #1,%d1
EGRETCLOCKPRAM_222:     /* one bit */
    bclr #1,%a2@
    bset #1,%a2@
    moveb %a2@,%d0
    lsrb #1,%d0
    addxb %d1,%d1
    jbcc EGRETCLOCKPRAM_222
    bset #0,%a2@(1024)
    jmp %fp@

EGRETCLOCKPRAM_23A:     /* Power Manager: read the time (PMgrOp 0x38) to Scratch20 */
    pea Scratch20
    movel %sp@,%sp@-
    clrw %sp@-
    movew #56,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    rts

EGRETCLOCKPRAM_250:     /* Power Manager: set the time (PMgrOp 0x30) from Time */
    pea Time
    movel %sp@,%sp@-
    movew #4,%sp@-
    movew #48,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    rts

EGRETCLOCKPRAM_268:     /* Power Manager: read (0x3A) or write (0x32) extended PRAM */
    moveal %sp,%a2
    movel %d0,%d2
    swap %d2
    addqw #3,%d2
    bclr #0,%d2
    subaw %d2,%sp
    moveal %sp,%a1
    movel %a0,%sp@-
    movel %a1,%sp@-
    moveb %d0,%a1@+
    swap %d0
    moveb %d0,%a1@+
    moveq #58,%d3
    moveq #2,%d2
    btst #12,%d1
    jbne EGRETCLOCKPRAM_298
    moveq #50,%d3
    addw %d0,%d2
    jbra EGRETCLOCKPRAM_294
EGRETCLOCKPRAM_292:     /* copy the data */
    moveb %a0@+,%a1@+
EGRETCLOCKPRAM_294:     /* next */
    dbf %d0,EGRETCLOCKPRAM_292
EGRETCLOCKPRAM_298:     /* PMgrOp */
    movew %d2,%sp@-
    movew %d3,%sp@-
    moveal %sp,%a0
    _PMgrOp
    moveal %a2,%sp
    rts

EGRETCLOCKPRAM_2A4:     /* Power Manager: write an extended PRAM byte (low level, no traps) */
    moveal %a3,%a4
    exg %d3,%d1
    swap %d3
    exg %d4,%d2
    swap %d4
    movel %d6,%d0
    movew #-206,%d3
    moveal %a1,%a0
    addal %a0@,%a0
    lea %pc@(EGRETCLOCKPRAM_2C6),%fp
    bigjmp USTPMGRSENDCOMMAND, a5
EGRETCLOCKPRAM_2C6:     /* command sent? */
    jbne EGRETCLOCKPRAM_312
    moveb #3,%d3
    lea %pc@(EGRETCLOCKPRAM_2DA),%a5
EGRETCLOCKPRAM_2D0:     /* 32-bit PC-relative jump (lea/jmp pair) to the send routine */
    lea 0xfff93fec,%fp
    jmp %pc@(EGRETCLOCKPRAM_2D0,%fp:l)
EGRETCLOCKPRAM_2DA:     /* send the bytes */
    jbne EGRETCLOCKPRAM_312	| 408B36F8
    swap %d3	| 408B36FA
    lea %pc@(EGRETCLOCKPRAM_2EC),%a5	| 408B36FC
EGRETCLOCKPRAM_2E2:     /* address 0xfff93fda */
    lea 0xfff93fda,%fp	| 408B3700
    jmp %pc@(EGRETCLOCKPRAM_2E2,%fp:l)	| 408B3706
EGRETCLOCKPRAM_2EC:     /* (data) */
    .byte   0x66, 0x24, 0x76, 0x01, 0x4B, 0xFA, 0x00, 0x0C, 0x4D, 0xF9, 0xFF, 0xF9, 0x3F, 0xC8, 0x4E, 0xFB	| 408B370A
    .byte   0xE8, 0xF8, 0x66, 0x12, 0x26, 0x04, 0x48, 0x43, 0x4B, 0xFA, 0x00, 0x0C, 0x4D, 0xF9, 0xFF, 0xF9	| 408B371A
    .byte   0x3F, 0xB4, 0x4E, 0xFB, 0xE8, 0xF8	| 408B372A
EGRETCLOCKPRAM_312:     /* restore the registers, return through a4 */
    movel %d1,%d3
    movel %d2,%d4
    movel %d0,%d6
    jmp %a4@

EGRETCLOCKPRAM_31A:     /* Power Manager: read an extended PRAM byte (low level) */
    moveal %a3,%a4
    exg %d3,%d1
    movel %d4,%d0
    movel %d6,%d2
    andil #255,%d3
    oril #37355776,%d3
    swap %d3
    moveal %a1,%a0
    addal %a0@,%a0
    lea %pc@(EGRETCLOCKPRAM_342),%fp
    bigjmp USTPMGRSENDCOMMAND, a5
EGRETCLOCKPRAM_342:     /* command sent? */
    jbne EGRETCLOCKPRAM_37A
    lea %pc@(EGRETCLOCKPRAM_352),%a5
EGRETCLOCKPRAM_348:     /* 32-bit PC-relative jump to the receive routine */
    lea 0xfff93fda,%fp
    jmp %pc@(EGRETCLOCKPRAM_348,%fp:l)
EGRETCLOCKPRAM_352:     /* read the reply */
    jbne EGRETCLOCKPRAM_37A	| 408B3770
    cmpib #58,%d3	| 408B3772
    jbne EGRETCLOCKPRAM_36A	| 408B3776
    lea %pc@(EGRETCLOCKPRAM_368),%a5	| 408B3778
EGRETCLOCKPRAM_35E:     /* address 0xfff93fc4 */
    lea 0xfff93fc4,%fp	| 408B377C
    jmp %pc@(EGRETCLOCKPRAM_35E,%fp:l)	| 408B3782
EGRETCLOCKPRAM_368:     /* (data) */
    .byte   0x66, 0x10	| 408B3786
EGRETCLOCKPRAM_36A:     /* address %pc@(EGRETCLOCKPRAM_378) */
    lea %pc@(EGRETCLOCKPRAM_378),%a5	| 408B3788
EGRETCLOCKPRAM_36E:     /* address 0xfff93fb4 */
    lea 0xfff93fb4,%fp	| 408B378C
    jmp %pc@(EGRETCLOCKPRAM_36E,%fp:l)	| 408B3792
EGRETCLOCKPRAM_378:     /* (data) */
    .byte   0x67, 0x02	| 408B3796
EGRETCLOCKPRAM_37A:     /* result in d1, return through a4 */
    moveq #0,%d3
    exg %d1,%d3
    movel %d0,%d4
    movel %d2,%d6
    tstb %d1
    jmp %a4@
    clrl %sp@-
    lea %sp@(-16),%sp
    movew #259,%sp@
    moveal %sp,%a0
    _EgretDispatch
    movel %a0@(2),Scratch20
    lea %sp@(20),%sp
    rts
    clrl %sp@-
    lea %sp@(-14),%sp
    movel Time,%sp@
    movew #265,%sp@-
    moveal %sp,%a0
    _EgretDispatch
    lea %sp@(20),%sp
    rts
    clrl %sp@-
    subqw #8,%sp
    movel %a0,%sp@
    swap %d0
    movew %d0,%sp@-
    subqw #4,%sp
    swap %d0
    addiw #256,%d0
    movew %d0,%sp@
    movew #258,%sp@-
    btst #12,%d1
    bnes EGRETCLOCKPRAM_37A_60
    movew #264,%sp@
EGRETCLOCKPRAM_37A_60:
    moveal %sp,%a0
    _EgretDispatch
    lea %sp@(20),%sp
    rts
    swap %d1
    moveb %d2,%d1
    swap %d1
    bset #15,%d1
EGRETCLOCKPRAM_3EE:     /* Egret low-level byte exchange through the VIA */
    bclr #5,%a2@
    beqs EGRETCLOCKPRAM_3EE_66
    lea %pc@(EGRETCLOCKPRAM_3EE_E),%a5
    jmp %pc@(EGRETCLOCKPRAM_3EE_17C)
EGRETCLOCKPRAM_3EE_E:
    bclr #4,%a2@
    lea %pc@(EGRETCLOCKPRAM_3EE_1A),%a5
    jmp %pc@(EGRETCLOCKPRAM_3EE_17C)
EGRETCLOCKPRAM_3EE_1A:
    bras EGRETCLOCKPRAM_3EE_66
EGRETCLOCKPRAM_3EE_1C:
    lea %pc@(EGRETCLOCKPRAM_3EE_24),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_188)
EGRETCLOCKPRAM_3EE_24:
    beqs EGRETCLOCKPRAM_3EE_1C
    bras EGRETCLOCKPRAM_3EE_34
EGRETCLOCKPRAM_3EE_28:
    lea %pc@(EGRETCLOCKPRAM_3EE_30),%a5
    jmp %pc@(EGRETCLOCKPRAM_3EE_17C)
EGRETCLOCKPRAM_3EE_30:
    tstb %a2@(5120)
EGRETCLOCKPRAM_3EE_34:
    bclr #5,%a2@
    bclr #4,%a2@
    bclr #4,%a2@(5632)
    lea %pc@(EGRETCLOCKPRAM_3EE_4A),%a5
    jmp %pc@(EGRETCLOCKPRAM_3EE_17C)
EGRETCLOCKPRAM_3EE_4A:
    bras EGRETCLOCKPRAM_3EE_58
EGRETCLOCKPRAM_3EE_4C:
    bset #5,%a2@
    lea %pc@(EGRETCLOCKPRAM_3EE_58),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_188)
EGRETCLOCKPRAM_3EE_58:
    btst #3,%a2@
    beqs EGRETCLOCKPRAM_3EE_4C
    lea %pc@(EGRETCLOCKPRAM_3EE_66),%a5
    jmp %pc@(EGRETCLOCKPRAM_3EE_17C)
EGRETCLOCKPRAM_3EE_66:
    orib #28,%a2@(5632)
    btst #3,%a2@
    beqs EGRETCLOCKPRAM_3EE_28
    bset #5,%a2@
    moveq #1,%d0
    lea %pc@(EGRETCLOCKPRAM_3EE_80),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_15A)
EGRETCLOCKPRAM_3EE_80:
    bmis EGRETCLOCKPRAM_3EE_34
    btst #3,%a2@
    beqs EGRETCLOCKPRAM_3EE_34
    moveq #7,%d0
    tstw %d1
    bpls EGRETCLOCKPRAM_3EE_90
    moveq #12,%d0
EGRETCLOCKPRAM_3EE_90:
    lea %pc@(EGRETCLOCKPRAM_3EE_98),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_15A)
EGRETCLOCKPRAM_3EE_98:
    moveq #0,%d0
    lea %pc@(EGRETCLOCKPRAM_3EE_A2),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_15A)
EGRETCLOCKPRAM_3EE_A2:
    moveb %d1,%d0
    lea %pc@(EGRETCLOCKPRAM_3EE_AC),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_15A)
EGRETCLOCKPRAM_3EE_AC:
    tstw %d1
    bpls EGRETCLOCKPRAM_3EE_BC
    movel %d1,%d0
    swap %d0
    lea %pc@(EGRETCLOCKPRAM_3EE_BC),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_15A)
EGRETCLOCKPRAM_3EE_BC:
    bclr #4,%a2@(5632)
    bclr #5,%a2@
EGRETCLOCKPRAM_3EE_C6:
    btst #2,%a2@(6656)
    beqs EGRETCLOCKPRAM_3EE_C6
    btst #3,%a2@
    bnes EGRETCLOCKPRAM_3EE_C6
    tstb %a2@(5120)
    lea %pc@(EGRETCLOCKPRAM_3EE_E0),%a5
    jmp %pc@(EGRETCLOCKPRAM_3EE_17C)
EGRETCLOCKPRAM_3EE_E0:
    bset #5,%a2@
    lea %pc@(EGRETCLOCKPRAM_3EE_EC),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_188)
EGRETCLOCKPRAM_3EE_EC:
    bnew EGRETCLOCKPRAM_3EE_34
    lea %pc@(EGRETCLOCKPRAM_3EE_F8),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_188)
EGRETCLOCKPRAM_3EE_F8:
    bnew EGRETCLOCKPRAM_3EE_34
    tstw %d1
    bpls EGRETCLOCKPRAM_3EE_126
    lea %pc@(EGRETCLOCKPRAM_3EE_108),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_188)
EGRETCLOCKPRAM_3EE_108:
    beqw EGRETCLOCKPRAM_3EE_1C
    cmpib #12,%d0
    bnew EGRETCLOCKPRAM_3EE_34
    bclr #5,%a2@
    bclr #4,%a2@
    lea %pc@(EGRETCLOCKPRAM_3EE_124),%a5
    jmp %pc@(EGRETCLOCKPRAM_3EE_17C)
EGRETCLOCKPRAM_3EE_124:
    jmp %a3@
EGRETCLOCKPRAM_3EE_126:
    lea %pc@(EGRETCLOCKPRAM_3EE_12E),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_188)
EGRETCLOCKPRAM_3EE_12E:
    bnew EGRETCLOCKPRAM_3EE_34
    subqb #7,%d0
    bnew EGRETCLOCKPRAM_3EE_34
    lea %pc@(EGRETCLOCKPRAM_3EE_140),%fp
    jmp %pc@(EGRETCLOCKPRAM_3EE_188)
EGRETCLOCKPRAM_3EE_140:
    bclr #5,%a2@
EGRETCLOCKPRAM_3EE_144:
    btst #3,%a2@
    beqs EGRETCLOCKPRAM_3EE_144
    bclr #4,%a2@
    lea %pc@(EGRETCLOCKPRAM_3EE_156),%a5
    jmp %pc@(EGRETCLOCKPRAM_3EE_17C)
EGRETCLOCKPRAM_3EE_156:
    moveb %d0,%d1
    jmp %a3@
EGRETCLOCKPRAM_3EE_15A:
    moveal %fp,%a5
    moveb %d0,%a2@(5120)
    bset #4,%a2@
    movew #32767,%d0
EGRETCLOCKPRAM_3EE_168:
    btst #2,%a2@(6656)
    dbne %d0,EGRETCLOCKPRAM_3EE_168
    beqs EGRETCLOCKPRAM_3EE_184
    tstb %a2@(5120)
    bclr #4,%a2@
EGRETCLOCKPRAM_3EE_17C:
    moveq #104,%d2
EGRETCLOCKPRAM_3EE_17E:
    tstb %a2@
    dbf %d2,EGRETCLOCKPRAM_3EE_17E
EGRETCLOCKPRAM_3EE_184:
    tstw %d0
    jmp %a5@
EGRETCLOCKPRAM_3EE_188:
    bclr #4,%a2@
EGRETCLOCKPRAM_3EE_18C:
    btst #2,%a2@(6656)
    beqs EGRETCLOCKPRAM_3EE_18C
    bset #4,%a2@
    moveb %a2@(5120),%d0
    lea %pc@(EGRETCLOCKPRAM_3EE_1A4),%a5
    jmp %pc@(EGRETCLOCKPRAM_3EE_17C)
EGRETCLOCKPRAM_3EE_1A4:
    btst #3,%a2@
    jmp %fp@

/* CLKNOMEM: clock/PRAM primitive for machines without one: return through a5. */
trap_CLKNOMEM:
CLKNOMEM:
    jmp %a5@
    .fill   0xA14, 1, 0x00
CLKNOMEM_A16:           /* unused (zeros) */
    .long   0x00000000	| 408B43CC

/*
 POWERMGRPRIMITIVES: Power Manager primitives for the PowerBooks: a lookup table by
 machine (PMGRPRIMLOOKUP), then per-machine tables of offsets and routines, most of it
 still raw words (no Power Manager in the Quadra 800). NOT RELOCATABLE YET: the offsets in
 these nested tables are left as numbers (some relative to their table, some to themselves;
 the format is not understood well enough to write them as label differences, and the
 Quadra 800 never runs this code, so it cannot be tested). Moving code inside this block
 breaks the PowerBook primitives, nothing else.
*/
POWERMGRPRIMITIVES:
PMGRPRIMLOOKUP:
    .long   0x00090000, 0x0050000A, 0x0000010E, 0x000C0000	| 408B43D0
    .long   0x03300000, 0x00000000, 0x00000000, 0x00000000	| 408B43E0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408B43F0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408B4400
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408B4410
    .long   0x000E0000, 0x00380000, 0x00820000, 0x056CFFFD	| 408B4420
    .short  0x467A, 0xFFFD, 0x4776, 0x0000, 0x0046, 0x0000, 0x006A	| 408B4430
    .long   POWERMGRPRIMITIVES_AD8-.	| 408B443E
    .short  0x0000, 0x0B36	| orib #54,%d0
    .short  0x0000, 0x0CA0	| orib #-96,%d0
    .short  0xFFFD	| .short 0xfffd
    clrl %fp@-
    .short  0x0000, 0x0500	| orib #0,%d0
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000, 0x0DE2	| orib #-30,%d0
    moveq #20,%d0
    .short  0x4930, 0x6100	| chkl %a0@(0,%d6:w),%d4
    .short  0x0000, 0x50FA	| orib #-6,%d0
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000, 0x06E2	| orib #-30,%d0
    .short  0x0000, 0x073E	| orib #62,%d0
    .short  0x0000, 0x07A0	| orib #-96,%d0
    .short  0x0000, 0x06FA	| orib #-6,%d0
    .short  0x0000, 0x07AA	| orib #-86,%d0
    .short  0x0000, 0x0818	| orib #24,%d0
    .short  0x0000, 0x07CE	| orib #-50,%d0
    .short  0x0000, 0x07F6	| orib #-10,%d0
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000, 0x097C	| orib #124,%d0
    .short  0x0000, 0x08D8	| orib #-40,%d0
    .short  0x0000, 0x0962	| orib #98,%d0
    .short  0x0000, 0x08F4	| orib #-12,%d0
    .short  0x0000, 0x089C	| orib #-100,%d0
    .short  0x0000, 0x0000	| orib #0,%d0
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #212992,%a0
    btst #0,%a0@
    addal #-196608,%a0
    beqs PMGRPRIMLOOKUP_102
    movel #1638425,%d0
    btst #1,%a0@
    beqs PMGRPRIMLOOKUP_100
    movew #16,%d0
PMGRPRIMLOOKUP_100:
    rts
PMGRPRIMLOOKUP_102:
    movel #1048592,%d0
    btst #1,%a0@
    beqs PMGRPRIMLOOKUP_112
    movew #8,%d0
PMGRPRIMLOOKUP_112:
    rts
    .short  0x000E	| .short 0x000e
    orib #56,%d0
    .short  0x0000, 0x009A	| orib #-102,%d0
    .short  0x0000, 0x04C0	| orib #-64,%d0
    .short  0xFFFD	| .short 0xfffd
    .short  0x45B6, 0xFFFD, 0x46B2, 0x0000	| chkw @(46b20000)@(0),%d2
    .short  0x0046, 0x0000	| oriw #0,%d6
    .short  0x0076	| 408B4500
    .long   POWERMGRPRIMITIVES_AD8-.	| 408B4502
    .short  0x0000, 0x0B38, 0x0000, 0x0C22, 0xFFFD	| 408B4506
    .long   0x41E20000, 0x01660000, 0x00E20000	| 408B4510
    .long   0x00004614 /* number, not an address (F4) */	| 408B451C
    .long   0x00000000	| 408B4520
    .long   0x000050FA /* number, not an address (F4) */	| 408B4524
    .long   0x00000000	| 408B4528
    .long   0x00003058 /* number, not an address (F4) */	| 408B452C
    .long   0x0000061A /* number, not an address (F4) */	| 408B4530
    .long   0x00000676 /* number, not an address (F4) */	| 408B4534
    .long   0x000006D8 /* number, not an address (F4) */	| 408B4538
    .long   0x0000077A /* number, not an address (F4) */	| 408B453C
    .long   0x00000154 /* number, not an address (F4) */	| 408B4540
    .long   0x000006DE /* number, not an address (F4) */	| 408B4544
    .long   0x0000073C /* number, not an address (F4) */	| 408B4548
    .long   0x00000702 /* number, not an address (F4) */	| 408B454C
    .long   0x0000072A /* number, not an address (F4) */	| 408B4550
    .long   0x00000160 /* number, not an address (F4) */	| 408B4554
    .long   0x00000000	| 408B4558
    .long   0x000008AC /* number, not an address (F4) */	| 408B455C
    .long   0x00000164 /* number, not an address (F4) */	| 408B4560
    .long   0x000008C2 /* number, not an address (F4) */	| 408B4564
    .long   0x0000088E /* number, not an address (F4) */	| 408B4568
    .long   0x00000820 /* number, not an address (F4) */	| 408B456C
    .long   0x000007C8 /* number, not an address (F4) */	| 408B4570
    .long   0x00000162 /* number, not an address (F4) */	| 408B4574
    .long   0x0000302E /* number, not an address (F4) */	| 408B4578
    .short  0x0000, 0x0000	| orib #0,%d0
    moveal 0xdd8,%a0
    moveq #7,%d0
    andw %a0@(60),%d0
    movel %pc@(PMGRPRIMLOOKUP_1D8,%d0:w:4),%d0
    cmpiw #16,%d0
    bles PMGRPRIMLOOKUP_1D6
    addal %a0@,%a0
    moveal %a0@(52),%a0
    btst #1,%a0@(16)
    beqs PMGRPRIMLOOKUP_1D6
    movew #16,%d0
PMGRPRIMLOOKUP_1D6:
    rts
PMGRPRIMLOOKUP_1D8:
    subqw #1,%sp@
    chkl %a1@-,%d1
    .short  0x484A	| 408B45AC bkpt 2
    addqb #1,%a1@-
    .short  0x4147	| .short 0x4147
    movel %a0@-,%a0@-
    orib #20,%a4@
    orib #25,%a1@+
    orib #33,%a1@-
    orib #16,%a0@
    orib #16,%a0@
    movew #120,%a0@(10)
    moveal PmgrBase,%a1
    btst #5,%a1@(16)
    bnes PMGRPRIMLOOKUP_23C
    btst #4,%a1@(249)
    bnes PMGRPRIMLOOKUP_23C
    btst #6,%a1@(84)
    bnes PMGRPRIMLOOKUP_23A
    clrw %sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #220,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    btst #0,%sp@+
    beqs PMGRPRIMLOOKUP_23A
    bset #6,%a1@(84)
PMGRPRIMLOOKUP_23A:
    rts
PMGRPRIMLOOKUP_23C:
    bclr #6,%a1@(84)
    rts
    btst #0,%a2@(84)
    bnes PMGRPRIMLOOKUP_274
    btst #6,%a2@(84)
    beqs PMGRPRIMLOOKUP_274
    moveb %a2@(84),%sp@-
    bset #1,%a2@(84)
    moveq #6,%d0
    _Sleep
    btst #1,%sp@+
    beqs PMGRPRIMLOOKUP_26E
    bset #1,%a2@(84)
PMGRPRIMLOOKUP_26E:
    movel Ticks,%a2@(26)
PMGRPRIMLOOKUP_274:
    bsrw POWERMGRPRIMITIVES_5F2
    braw POWERMGRPRIMITIVES_5EE
    movew #600,%a0@(10)
    moveal ghost_VIA2,%a0
    lea %a0@(34),%a0
    btst #6,%a0@
    bnes PMGRPRIMLOOKUP_2BC
    moveal PmgrBase,%a2
    tstb %a2@(12)
    beqs PMGRPRIMLOOKUP_2B6
    movel %a0,%sp@-
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 408B466C
    tstl %a0@(28)
    beqs PMGRPRIMLOOKUP_2B0
    moveal %a0@(28),%a0
    jsr %a0@
PMGRPRIMLOOKUP_2B0:
    moveal %sp@+,%a0
    tstb %d0
    bnes PMGRPRIMLOOKUP_2C2
PMGRPRIMLOOKUP_2B6:
    bclr #0,%a0@
    rts
PMGRPRIMLOOKUP_2BC:
    bset #0,%a0@
    .short  0xA285	| 408B4690 _PMgrOp (flags 0x0200)
PMGRPRIMLOOKUP_2C2:
    rts
    moveal ghost_VIA2,%a0
    moveq #-128,%d0
    orb %a0@(18),%d0
    moveb %d0,%sp@-
    moveq #-128,%d0
    orb %a0@(19),%d0
    moveb %d0,%sp@-
    bset #0,%a0@(33)
    moveb %a0@(33),%sp@-
    jmp %a1@
    moveal ghost_VIA2,%a0
    addal #499712,%a0
    moveq #-1,%d0
    movel %d0,%a0@
    jmp %a1@
    moveal ghost_VIA2,%a0
    moveb %sp@+,%a0@(33)
    moveb %sp@+,%a0@(19)
    moveb %sp@+,%a0@(18)
    jmp %a1@
    moveal ghost_VIA2,%a0
    bset #1,%a0@(33)
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveml %a0@(12),%a2-%a3
    moveal VIA,%a0
    moveb %a2@,%d0
    tstb %a0@
    moveb #9,%a3@
    tstb %a0@
    moveb #64,%a3@
    tstb %a0@
    moveal ghost_VIA2,%a0
    bclr #1,%a0@(33)
    jmp %a1@
    .short  0x000E	| .short 0x000e
    orib #56,%d0
    .short  0x0000, 0x00BC	| orib #-68,%d0
    .short  0x0000, 0x00A4	| orib #-92,%d0
    .short  0xFFFD	| .short 0xfffd
    .short  0x438E, 0xFFFD, 0x448A, 0x0000, 0x0046, 0x0000, 0x0072	| 408B471C
    .long   POWERMGRPRIMITIVES_AD8-.	| 408B472A
    .short  0x0000	| 408B472E
    .long   0x084A0000, 0x09B4FFFD, 0x3FBA0000, 0x01BC0000	| 408B4730
    .long   0x00000000, 0x009A4614, 0x49306101, 0x0A0050FA	| 408B4740
    .long   0x00000000, 0x000003F6, 0x0000043E, 0x00000496	| 408B4750
    .long   0x000004B0, 0x00000552, 0x00000406, 0x000004B6	| 408B4760
    .long   0x00000524	| 408B4770
    .long   0x000004DA /* number, not an address (F4) */	| 408B4774
    .long   0x00000502 /* number, not an address (F4) */	| 408B4778
    .long   0x00000000	| 408B477C
    .long   0x00000688 /* number, not an address (F4) */	| 408B4780
    .long   0x000005E4 /* number, not an address (F4) */	| 408B4784
    .long   0x0000069E /* number, not an address (F4) */	| 408B4788
    .long   0x0000066A /* number, not an address (F4) */	| 408B478C
    .long   0x000005FC /* number, not an address (F4) */	| 408B4790
    .long   0x00000640 /* number, not an address (F4) */	| 408B4794
    .long   0x000005A0 /* number, not an address (F4) */	| 408B4798
    .long   0x000006CC /* number, not an address (F4) */	| 408B479C
    .long   0x00002E06 /* number, not an address (F4) */	| 408B47A0
    .long   0x00000000	| 408B47A4
    .long   0x00020000 /* number, not an address (F4) */	| 408B47A8
    .short  0x00BE	| .short 0x00be
    .short  0x0000, 0x00FA	| orib #-6,%d0
    .short  0x0000, 0x022A	| orib #42,%d0
    orib #86,%d0
    .short  0x0000, 0x028C	| orib #-116,%d0
    .short  0x0000, 0x02C2	| orib #-62,%d0
    .short  0x0000, 0x0306	| orib #6,%d0
    .short  0x0000, 0x0338	| orib #56,%d0
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #221184,%a0
    moveq #3,%d1
    andb %a0@,%d1
    lslb #2,%d1
    movel %pc@(PMGRPRIMLOOKUP_2C2_164,%d1:w),%d0
    addal #-204800,%a0
    btst #1,%a0@
    bnes PMGRPRIMLOOKUP_2C2_162
    movew %pc@(PMGRPRIMLOOKUP_2C2_164,%d1:w),%d0
PMGRPRIMLOOKUP_2C2_162:
    rts
PMGRPRIMLOOKUP_2C2_164:
    orib #16,%a0@
    orib #16,%a4@
    orib #16,%a1@+
    orib #16,%a1@-
    .byte   0x00, 0x00	| 408B4806
    btst #1,%a2@(296)	| 408B4808
    beqs PMGRPRIMLOOKUP_2C2_18C
    moveal %a2@(350),%a0
    jsr %a0@
    bnes PMGRPRIMLOOKUP_2C2_18C
    bclr #1,%a2@(296)
PMGRPRIMLOOKUP_2C2_18C:
    bclr #6,%a2@(296)
    beqs PMGRPRIMLOOKUP_2C2_19C
    moveal %a2@(300),%a0
    moveq #1,%d0
    jbra POWERMGRPRIMITIVES_474
PMGRPRIMLOOKUP_2C2_19C:
    btst #5,%a2@(296)	| 408B482E
    beqs POWERMGRPRIMITIVES_48E
    btst #0,%a2@(15)
    bnes POWERMGRPRIMITIVES_474_6
    moveal %a2@(304),%a0
    moveq #0,%d0
POWERMGRPRIMITIVES_474:  /* post a user notification (sleep/battery message) */
    jbsr POSTUSERNMMSG
    jbra POWERMGRPRIMITIVES_48E
POWERMGRPRIMITIVES_474_6:
    btst #7,%a2@(296)	| 408B484A
    beqs POWERMGRPRIMITIVES_48E
    lea %a2@(308),%a0
    _NMRemove
    bclr #7,%a2@(296)
POWERMGRPRIMITIVES_48E:  /* then check for a pending sleep request */
    jbsr POWERMGRPRIMITIVES_5F2
    jbra POWERMGRPRIMITIVES_5EE
    .short  0x6100, 0x0A50	| bsrw 408b52b8 <POSTUSERNMMSG_104+0xe>
    movel %a2,%sp@-
    moveal 0xdd8,%a2
    addal %a2@,%a2
    moveal %a2@(88),%a2
    addal #90112,%a2
    bclr #2,@(PmgrBase,%za0)@(0x128)	| 408B487C
    btst #0,%a2@
    beqs POWERMGRPRIMITIVES_48E_40
    bset #2,@(PmgrBase,%za0)@(0x128)	| 408B488C
    bclr #0,%a2@(1024)
    moveq #1,%d0
POWERMGRPRIMITIVES_48E_40:
    moveal %sp@+,%a2
    rts

POWERMGRPRIMITIVES_4D2:  /* clear a bit in the Power Manager globals (+0x128) and set a hardware bit */
    movel %a2,%sp@-
    moveal 0xdd8,%a2
    addal %a2@,%a2
    moveal %a2@(88),%a2
    addal #91136,%a2
    bclr #2,@(PmgrBase,%za0)@(0x128)	| 408B48B4
    bset #0,%a2@
    jbsr POSTUSERNMMSG_152
    moveal %sp@+,%a2
    rts
    movew #600,%a0@(10)
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #91136,%a0
    btst #3,%a0@
    bnes POWERMGRPRIMITIVES_4D2_70
    moveal PmgrBase,%a2
    tstb %a2@(12)
    beqs POWERMGRPRIMITIVES_4D2_6A
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 408B48F2
    tstl %a0@(28)
    beqs POWERMGRPRIMITIVES_4D2_64
    moveal %a0@(28),%a0
    jsr %a0@
POWERMGRPRIMITIVES_4D2_64:
    moveal %sp@+,%a0
    tstb %d0
    bnes POWERMGRPRIMITIVES_4D2_7E
POWERMGRPRIMITIVES_4D2_6A:
    bclr #5,%a0@
    rts
POWERMGRPRIMITIVES_4D2_70:
    bset #5,%a0@
    bset #2,%a0@
    bclr #2,%a0@
    .short  0xA285	| 408B491E _PMgrOp (flags 0x0200)
POWERMGRPRIMITIVES_4D2_7E:
    rts
    movew #600,%a0@(10)
    clrw %sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #152,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    moveb %sp@+,%d0
    beqs POWERMGRPRIMITIVES_4D2_EA
    moveq #3,%d1
    btst #1,%d0
    bnes POWERMGRPRIMITIVES_4D2_CE
    moveal PmgrBase,%a0
    tstb %a0@(12)
    beqs POWERMGRPRIMITIVES_4D2_CC
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 408B4954
    tstl %a0@(28)
    beqs POWERMGRPRIMITIVES_4D2_C6
    moveal %a0@(28),%a0
    jsr %a0@
POWERMGRPRIMITIVES_4D2_C6:
    moveal %sp@+,%a0
    tstb %d0
    bnes POWERMGRPRIMITIVES_4D2_EA
POWERMGRPRIMITIVES_4D2_CC:
    moveq #0,%d1
POWERMGRPRIMITIVES_4D2_CE:
    moveb %d1,%sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #1,%sp@-
    movew #144,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(14),%sp
    tstb %d1
    beqs POWERMGRPRIMITIVES_4D2_EA
    .short  0xA285	| 408B498A _PMgrOp (flags 0x0200)
POWERMGRPRIMITIVES_4D2_EA:
    rts
    orib #78,%d0
    orib #48,%d0
    .short  0x0000, 0x00B0	| orib #-80,%d0
    .short  0x0000, 0x00E6	| orib #-26,%d0
    .short  0x0000, 0x012A	| orib #42,%d0
    .short  0x0000, 0x015C	| orib #92,%d0
    orib #54,%d0
    .short  0xFFFF	| .short 0xffff
    .short  0xFC6E	| .short 0xfc6e
    orib #0x98,%d0
    orib #0xce,%d0
    .short  0x0000, 0x0112	| orib #18,%d0
    .short  0x0000, 0x0144	| orib #68,%d0
POWERMGRPRIMITIVES_5EE:  /* idle check */
    jbsr POWERMGRPRIMITIVES_62A
    rts

POWERMGRPRIMITIVES_5F2:  /* sleep requested (bit 3 of +296)? d0 = 0 or -1 (bit 4): screen */
    bclr #3,%a2@(296)
    jbeq POWERMGRPRIMITIVES_60A
    moveq #0,%d0
    btst #4,%a2@(296)
    jbeq POWERMGRPRIMITIVES_606
    moveq #-1,%d0
POWERMGRPRIMITIVES_606:  /* dim or restore the screens */
    jbra POWERMGRPRIMITIVES_AD8
POWERMGRPRIMITIVES_60A:  /* no */
    rts
    cmpib #4,%a2@(13)
    bnes POWERMGRPRIMITIVES_60A_1C
    cmpib #10,%a2@(109)
    blss POWERMGRPRIMITIVES_60A_1C
    bset #0,%a2@(297)
    moveq #-1,%d0
    rts
POWERMGRPRIMITIVES_60A_1C:
    moveq #0,%d0
    rts

POWERMGRPRIMITIVES_62A:  /* idle timer: call the dim routine after the timeout (minutes x 900 ticks?) */
    movel %a2@(30),%d2
    jbeq POWERMGRPRIMITIVES_66C
    movel %a2@(22),%d0
    jbeq POWERMGRPRIMITIVES_66C
    btst #4,%a2@(249)
    jbne POWERMGRPRIMITIVES_66C
    btst #0,%a2@(15)
    jbeq POWERMGRPRIMITIVES_64E
    btst #1,%a2@(16)
    jbne POWERMGRPRIMITIVES_66C
POWERMGRPRIMITIVES_64E:  /* timeout from +1 (0: 16) */
    moveal %d0,%a0
    moveq #0,%d0
    moveb %a2@(1),%d0
    jbne POWERMGRPRIMITIVES_65C
    moveb #16,%d0
POWERMGRPRIMITIVES_65C:  /* elapsed since +30? */
    muluw #900,%d0
    movel Ticks,%d1
    subl %d2,%d1
    cmpl %d1,%d0
    jbgt POWERMGRPRIMITIVES_66C
    jsr %a0@
POWERMGRPRIMITIVES_66C:  /* done */
    rts
    btst #0,%a2@(15)
    beqs POWERMGRPRIMITIVES_66C_12
    btst #1,%a2@(16)
    bnes POWERMGRPRIMITIVES_66C_34
POWERMGRPRIMITIVES_66C_12:
    moveq #0,%d0
    moveb %a2@,%d0
    bnes POWERMGRPRIMITIVES_66C_1C
    moveb #32,%d0
POWERMGRPRIMITIVES_66C_1C:
    muluw #900,%d0
    addl %a2@(26),%d0
    cmpl Ticks,%d0
    bges POWERMGRPRIMITIVES_66C_34
    tstb %a2@(248)
    bgts POWERMGRPRIMITIVES_66C_34
    moveq #-1,%d0
    rts
POWERMGRPRIMITIVES_66C_34:
    moveq #0,%d0
    rts
    btst #2,%a2@(249)
    bnes POWERMGRPRIMITIVES_66C_78
    tstb MBState
    beqs POWERMGRPRIMITIVES_66C_72
    tstb %a2@(94)
    bnes POWERMGRPRIMITIVES_66C_72
    btst #0,%a2@(16)
    bnes POWERMGRPRIMITIVES_66C_78
    tstb %a2@(81)
    bgts POWERMGRPRIMITIVES_66C_78
    movel Ticks,%d0
    subl %a2@(26),%d0
    bmis POWERMGRPRIMITIVES_66C_78
    moveq #0,%d1
    movew %a2@(172),%d1
    cmpl %d0,%d1
    bges POWERMGRPRIMITIVES_66C_78
    moveq #-1,%d0
    rts
POWERMGRPRIMITIVES_66C_72:
    movel Ticks,%a2@(26)
POWERMGRPRIMITIVES_66C_78:
    moveq #0,%d0
    rts
    movew %a2@(174),%d1
    movel %a2@(26),%d0
    cmpl %a2@(178),%d0
    bnes POWERMGRPRIMITIVES_66C_A4
    movew %a2@(182),%d1
    addw %a2@(226),%d1
    cmpw %a2@(228),%d1
    bccs POWERMGRPRIMITIVES_66C_9E
    movew %d1,%a2@(182)
    rts
POWERMGRPRIMITIVES_66C_9E:
    movew %a2@(228),%d1
    rts
POWERMGRPRIMITIVES_66C_A4:
    movel %d0,%a2@(178)
    movew %d1,%a2@(182)
    rts
    .short  0x61FF	| 408B4AEA
    .long   SETSUPERVISORMODE-.	| 408B4AEC
    movew %d0,%a2@(200)
    movel 0x7c,%a2@(202)
    movel ResetStackPtr,%sp@-
    movel ResetVector,%sp@-
    btst #12,HWCfgFlags
    beqs POWERMGRPRIMITIVES_66C_A4_32
    fmoveml %fpiar/%fpsr/%fpcr,%sp@-
    fmovemx %fp0-%fp7,%sp@-
POWERMGRPRIMITIVES_66C_A4_32:
    movel %a2@(26),%sp@-
    moveal %a2@(230),%a0
    jsr %a0@
    movel %sp@+,%d0
    cmpl %a2@(26),%d0
    dbne %d1,POWERMGRPRIMITIVES_66C_A4_32
    btst #12,HWCfgFlags
    beqs POWERMGRPRIMITIVES_66C_A4_56
    fmovemx %sp@+,%fp0-%fp7
    fmoveml %sp@+,%fpiar/%fpsr/%fpcr
POWERMGRPRIMITIVES_66C_A4_56:
    movel %sp@+,ResetVector
    movel %sp@+,ResetStackPtr
    movew %a2@(200),%sr
    movel %a2@(202),0x7c
    rts
    moveal VIA,%a0
    moveb %a0@,%d0
    moveb %a0@(1024),%d1
    moveb %a0@(7680),%d2
    moveb %a0@(1536),%d3
    moveb %a0@(7168),%d4
    moveb %a0@(5632),%d5
    moveb %a0@(6144),%d6
    movemw %d0-%d6,%sp@-
    jmp %a1@
    moveal ghost_VIA2,%a0
    moveb %a0@,%d0
    moveb %a0@(1024),%d1
    moveb %a0@(7680),%d2
    moveb %a0@(1536),%d3
    moveb %a0@(7168),%d4
    moveb %a0@(5632),%d5
    moveb %a0@(6144),%d6
    movemw %d0-%d6,%sp@-
    bclr #6,%a0@
    jmp %a1@
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #91136,%a0
    bset #4,%a0@
    moveal ASCBase,%a0
    moveb %a0@(2049),%sp@-
    moveb %a0@(2054),%sp@-
    moveb %a0@(2058),%sp@-
    cmpib #0xb0,%a0@(2048)	| 408B4BBA
    bnes POWERMGRPRIMITIVES_81E_2
    moveb %a0@(2063),%sp@-
    movel %a1,%d2
    moveq #0,%d1
POWERMGRPRIMITIVES_7FA:  /* save 18 bytes of a device's registers on the stack (before sleep) */
    lea %a0@(3850),%a1
    addal %d1,%a1
    moveq #9,%d0
POWERMGRPRIMITIVES_802:  /* first 10 */
    moveb %a1@-,%sp@-
    dbf %d0,POWERMGRPRIMITIVES_802
    lea %a0@(3864),%a1
    addal %d1,%a1
    moveq #7,%d0
POWERMGRPRIMITIVES_810:  /* then 8 */
    moveb %a1@-,%sp@-
    dbf %d0,POWERMGRPRIMITIVES_810
    tstl %d1
    jbne POWERMGRPRIMITIVES_81E
    moveq #32,%d1
    jbra POWERMGRPRIMITIVES_7FA
POWERMGRPRIMITIVES_81E:  /* return through d2 */
    moveal %d2,%a1
POWERMGRPRIMITIVES_81E_2:
    jmp %a1@
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #91136,%a0
    bset #2,%a0@
    bclr #2,%a0@
    bclr #5,%a0@
    jmp %a1@
    btst #12,HWCfgFlags
    beqs POWERMGRPRIMITIVES_81E_32
    fmovemx %fp0-%fp7,%sp@-
    fmoveml %fpiar/%fpsr/%fpcr,%sp@-
POWERMGRPRIMITIVES_81E_32:
    jmp %a1@
    movel %usp,%a0
    movel %a0,%sp@-
    movec %msp,%a0
    movel %a0,%sp@-
    movec %vbr,%a0
    movel %a0,%sp@-
    movec %cacr,%d0
    oriw #2056,%d0
    .short  0x4E7A, 0x1802	| 408B4C3A movec %caar,%d1
    moveml %d0-%d1,%sp@-
    moveq #0,%d0
    movec %d0,%vbr
    movel %sp,%a2@(196)
    jmp %a1@
    clrw %a2@(194)
    cmpib #4,MMUType
    .short  0x661E	| bnes 408b4c78 <POWERMGRPRIMITIVES_81E+0x8a>
    .short  0xF02A, 0x4200, 0x00CE	| pmove %tc,%a2@(206)
    .short  0xF02A, 0x4E00, 0x00D2	| pmove %crp,%a2@(210)
    .short  0xF02A	| .short 0xf02a
    .short  0x0E00	| .short 0x0e00
    .short  0x00DA	| .short 0x00da
    .short  0xF02A	| .short 0xf02a
    .short  0x0A00, 0x00DE	| eorib #-34,%d0
    movew #-1,%a2@(194)
    jmp %a1@
    movel #1396789825,%a3@(274)
    jmp %a1@
    .short  0x4879, 0x424F, 0x5247	| pea 424f5247 <__bss_start+0x1bf5247>
    bclr #0,%a2@(297)
    bnes POWERMGRPRIMITIVES_81E_32_7A
    addqw #4,%sp
    pea 0x4d415454	| 408B4C94
POWERMGRPRIMITIVES_81E_32_7A:
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #4,%sp@-
    movew #127,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(16),%sp
    bclr #6,%a2@(84)
    jmp %a1@
    moveq #0,%d1
    lea %sp@(-56),%sp
    moveal %sp,%a0
    movel #196609,%a0@(40)
    movel #65566,%a0@(44)
    clrb %a0@(49)
    clrb %a0@(48)
    clrb %a0@(50)
    clrb %a0@(51)
    clrl %a0@(24)
    moveq #12,%d0
    _SlotManager
    bnew POWERMGRPRIMITIVES_81E_32_CE
    movew %a0@(38),%d1
POWERMGRPRIMITIVES_81E_32_CE:
    lea %sp@(56),%sp
    movew %d1,%sp@-
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(56),%a0
    addqw #2,%a0
    movew %a0@+,%sp@-
    moveq #127,%d0
    andb %a0@+,%d0
    moveb %d0,%sp@-
    movel %a0@+,%sp@-
    movew %a0@+,%sp@-
    tstw %d1
    beqs POWERMGRPRIMITIVES_81E_32_116
    linkw %fp,#-76
    movel %a2,%sp@-
    lea %fp@(-64),%a0
    movew %d1,%a0@(24)
    lea %fp@(-76),%a2
    clrw %a2@(6)
    movel %a2,%a0@(28)
    movew #133,%a0@(26)
    .short  0xA204	| 408B4D30 _Control (flags 0x0200)
    moveal %sp@+,%a2
    unlk %fp
POWERMGRPRIMITIVES_81E_32_116:
    jmp %a1@
    moveal VIA,%a0
    movemw %sp@+,%d0-%d6
    moveb %d0,%a0@
    moveb %d1,%a0@(1024)
    moveb %d2,%a0@(7680)
    moveb %d3,%a0@(1536)
    moveb %d4,%a0@(7168)
    moveb %d5,%a0@(5632)
    moveb %d6,%a0@(6144)
    moveb %a0@(4608),%a0@(4608)
    moveb %a0@(2560),%a0@(2560)
    jmp %a1@
    moveal ghost_VIA2,%a0
    movemw %sp@+,%d0-%d6
    moveb %d0,%a0@
    moveb %d1,%a0@(1024)
    moveb %d2,%a0@(7680)
    moveb %d3,%a0@(1536)
    moveb %d4,%a0@(7168)
    moveb %d5,%a0@(5632)
    moveb %d6,%a0@(6144)
    jmp %a1@
    moveal ASCBase,%a0
    cmpib #0xb0,%a0@(2048)	| 408B4D90
    bnes POWERMGRPRIMITIVES_9F0_6
    movel %a1,%d2
    moveq #32,%d1
POWERMGRPRIMITIVES_9CC:  /* restore them (after wake) */
    lea %a0@(3856),%a1
    addal %d1,%a1
    moveq #7,%d0
POWERMGRPRIMITIVES_9D4:  /* 8 */
    moveb %sp@+,%a1@+
    dbf %d0,POWERMGRPRIMITIVES_9D4
    lea %a0@(3840),%a1
    addal %d1,%a1
    moveq #9,%d0
POWERMGRPRIMITIVES_9E2:  /* 10 */
    moveb %sp@+,%a1@+
    dbf %d0,POWERMGRPRIMITIVES_9E2
    tstl %d1
    jbeq POWERMGRPRIMITIVES_9F0
    moveq #0,%d1
    jbra POWERMGRPRIMITIVES_9CC
POWERMGRPRIMITIVES_9F0:  /* 4 more registers, return through d2 */
    moveb %sp@+,%a0@(2063)
    moveal %d2,%a1
POWERMGRPRIMITIVES_9F0_6:
    moveb %sp@+,%a0@(2058)
    moveb %sp@+,%a0@(2054)
    moveb %sp@+,%a0@(2049)
    jmp %a1@
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #91136,%a0
    bset #2,%a0@
    bclr #2,%a0@
    bclr #5,%a0@
    bclr #4,%a0@
    jmp %a1@
    btst #12,HWCfgFlags
    beqs POWERMGRPRIMITIVES_9F0_46
    fmoveml %sp@+,%fpiar/%fpsr/%fpcr
    fmovemx %sp@+,%fp0-%fp7
POWERMGRPRIMITIVES_9F0_46:
    jmp %a1@
    moveml %sp@+,%d0-%d1
    movec %d0,%cacr
    .short  0x4E7B, 0x1802	| 408B4E10 movec %d1,%caar
    moveal %sp@+,%a0
    movec %a0,%vbr
    moveal %sp@+,%a0
    movec %a0,%msp
    moveal %sp@+,%a0
    movel %a0,%usp
    jmp %a1@
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(56),%a0
    lea %a0@(11),%a0
    movew %sp@+,%a0@-
    movel %sp@+,%a0@-
    moveb #0x80,%a0@-	| 408B4E38
    moveb %sp@+,%a0@
    movew %sp@+,%a0@-
    movew %sp@+,%d1
    beqs POWERMGRPRIMITIVES_9F0_A6
    linkw %fp,#-76
    lea %fp@(-64),%a0
    movew %d1,%a0@(24)
    lea %fp@(-76),%a2
    clrw %a2@(6)
    movel %a2,%a0@(28)
    movew #5,%a0@(26)
    .short  0xA204	| 408B4E62 _Control (flags 0x0200)
    unlk %fp
POWERMGRPRIMITIVES_9F0_A6:
    jmp %a1@
    movel %a1,%sp@-
    clrl %sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #104,%sp@-
    moveal %sp,%a0
    _PMgrOp
    moveal %a0@(8),%a2
    moveal PmgrBase,%a0
    moveb %a2@,%a0@(15)
    lea %sp@(16),%sp
    rts
    tstb WWExist
    bnes POWERMGRPRIMITIVES_9F0_E6
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    subqw #4,%sp
    _FrontWindow
    movel GrayRgn,%sp@-
    _PaintBehind
    _SetPort
    _DrawMenuBar
POWERMGRPRIMITIVES_9F0_E6:
    rts

POWERMGRPRIMITIVES_AD8:  /* dim (d0 nonzero) or restore the screens */
    linkw %fp,#-76
    moveml %d1-%d2/%a0-%a3,%sp@-
    lea %fp@(-64),%a3
    lea %fp@(-76),%a1
    movel %a1,%a3@(28)
    movew #132,%a3@(26)
    movel DeviceList,%d1
    moveq #0,%d2
    tstl %d0
    bnew POWERMGRPRIMITIVES_B4A
    clrw %a1@
POWERMGRPRIMITIVES_B00:  /* restore: each gDevice's colors back (PaletteDispatch 19) */
    moveal %d1,%a2
    moveal %a2@,%a2
    movew %a2@,%a3@(24)
    moveal %a3,%a0
    .short  0xA204	| 408B4EDA _Control (flags 0x0200)
    jbne POWERMGRPRIMITIVES_B24
    oriw #-1,%d2
    movel %d1,%sp@-
    movew %a2@(44),%sp@-
    clrl %a2@(42)
    clrl %sp@-
    movew #19,%d0
    _PaletteDispatch
POWERMGRPRIMITIVES_B24:  /* next device, then a hook of the Power Manager globals */
    movel %a2@(30),%d1
    jbne POWERMGRPRIMITIVES_B00
    tstw %d2
    jbeq POWERMGRPRIMITIVES_B40
    moveal PmgrBase,%a0
    moveal %a0@(270),%a0
    movel %a0@(28),%d0
    jbeq POWERMGRPRIMITIVES_B40
    jsr %a0@(0x0,%d0:l)
POWERMGRPRIMITIVES_B40:  /* show the cursor */
    _ShowCursor
POWERMGRPRIMITIVES_B42:  /* done */
    moveml %sp@+,%d1-%d2/%a0-%a3
    unlk %fp
    rts
POWERMGRPRIMITIVES_B4A:  /* dim: hide the cursor, open .Backlight and turn it down */
    _HideCursor
    movew #-1,%a1@
    moveal %a3,%a0
POWERMGRPRIMITIVES_B52:  /* (for each device) */
    moveal %d1,%a2
    moveal %a2@,%a2
    movew %a2@,%a0@(24)
    .short  0xA204	| 408B4F2A _Control (flags 0x0200)
    movel %a2@(30),%d1
    jbne POWERMGRPRIMITIVES_B52
    lea %pc@(PSTR_Backlight_408B4F4C),%a2
    movel %a2,%a0@(18)
    _Open
    jbne POWERMGRPRIMITIVES_B7A
    movew #17153,%a0@(26)
    clrl %a0@(28)
    .short  0xA204	| 408B4F48 _Control (flags 0x0200)
POWERMGRPRIMITIVES_B7A:  /* done */
    jbra POWERMGRPRIMITIVES_B42
PSTR_Backlight_408B4F4C:  /* Pascal string ".Backlight" */
    .ascii  "\012.Backlight\000"
PSTR_Backlight_408B4F4C_C:
    clrl %sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #105,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    moveal %sp,%a0
    moveq #0,%d3
    moveb %a0@+,%a2@(15)
    moveb %a0@,%d3
    addqw #4,%sp
    btst #5,%a2@(15)
    beqs PSTR_Backlight_408B4F4C_38
    st %a2@(17)
PSTR_Backlight_408B4F4C_38:
    moveq #0,%d0
    moveb %a2@(95),%d0
    subqb #1,%d0
    bpls PSTR_Backlight_408B4F4C_44
    moveq #7,%d0
PSTR_Backlight_408B4F4C_44:
    moveb %d0,%a2@(95)
    moveb %d3,%a2@(0x48,%d0:w)
    tstb %a2@(72)
    beqs PSTR_Backlight_408B4F4C_C
    moveq #0,%d3
    moveb %a2@(72),%d0
    addw %d0,%d3
    moveb %a2@(73),%d0
    addw %d0,%d3
    moveb %a2@(74),%d0
    addw %d0,%d3
    moveb %a2@(75),%d0
    addw %d0,%d3
    moveb %a2@(76),%d0
    addw %d0,%d3
    moveb %a2@(77),%d0
    addw %d0,%d3
    moveb %a2@(78),%d0
    addw %d0,%d3
    moveb %a2@(79),%d0
    addw %d0,%d3
    lsrw #1,%d3
    moveq #0,%d2
    moveb %a2@(34),%d2
    moveq #0,%d1
    moveb %a2@(35),%d1
    subw %d1,%d2
    aslw #2,%d1
    moveq #4,%d0
    addw %d2,%d1
    cmpw %d1,%d3
    blss PSTR_Backlight_408B4F4C_C6
    moveq #3,%d0
    addw %d2,%d1
    cmpw %d1,%d3
    blss PSTR_Backlight_408B4F4C_C6
    moveq #2,%d0
    addw %d2,%d1
    cmpw %d1,%d3
    blss PSTR_Backlight_408B4F4C_C6
    moveq #1,%d0
    addw %d2,%d1
    cmpw %d1,%d3
    blss PSTR_Backlight_408B4F4C_C6
    moveq #0,%d0
    movew %a2@(246),%d2
    aslw #2,%d2
    addw %d2,%d1
    cmpw %d1,%d3
    blss PSTR_Backlight_408B4F4C_C6
    moveq #-1,%d0
PSTR_Backlight_408B4F4C_C6:
    lsrw #2,%d3
    moveb %d3,%a2@(82)
    tstb %a2@(72)
    rts
    clrw %sp@-
    movel %sp,%sp@-	| 408B5020
    movel %sp@,%sp@-
    clrw %sp@-
    movew #106,%sp@-
    .byte   0x20	| 408B502A
POWERMGRPRIMITIVES_C5B:  /* (raw bytes) battery level scaling */
    .byte   0x4F	| 408B502B
    _PMgrOp	| 408B502C
    lea %sp@(12),%sp
    movew %sp@+,%a2@(34)
    clrl %sp@-
    clrl %sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #107,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    moveal %sp,%a0
    moveq #11,%d0
    andb %a0@,%d0
    moveb %a2@(15),%d1
    moveb %d0,%a2@(15)
    moveb %a0@+,%d0
    eorb %d0,%d1
    btst #0,%d1
    beqs POWERMGRPRIMITIVES_C5B_3D
    st %a2@(17)
POWERMGRPRIMITIVES_C5B_3D:
    movew %a0@,%d3
    lsrw #1,%d3
    moveb %d3,%a2@(82)
    addw %a0@+,%d3
    addqw #8,%sp
    btst #0,%d0
    bnes POWERMGRPRIMITIVES_C5B_91
    btst #2,%d0
    beqs POWERMGRPRIMITIVES_C5B_91
    moveq #0,%d2
    moveb %a2@(34),%d2
    moveq #0,%d1
    moveb %a2@(35),%d1
    subw %d1,%d2
    movew %d1,%d0
    addw %d0,%d1
    addw %d0,%d1
    moveq #4,%d0
    addw %d2,%d1
    cmpw %d1,%d3
    blss POWERMGRPRIMITIVES_C5B_93
    moveq #3,%d0
    addw %d2,%d1
    cmpw %d1,%d3
    blss POWERMGRPRIMITIVES_C5B_93
    moveq #1,%d0
    addw %d2,%d1
    cmpw %d1,%d3
    blss POWERMGRPRIMITIVES_C5B_93
    moveq #0,%d0
    movew %a2@(246),%d2
    addw %d2,%d1
    addw %d2,%d1
    addw %d2,%d1
    cmpw %d1,%d3
    blss POWERMGRPRIMITIVES_C5B_93
POWERMGRPRIMITIVES_C5B_91:
    moveq #-1,%d0
POWERMGRPRIMITIVES_C5B_93:
    moveq #1,%d1
    rts
    moveq #3,%d0
    andb %a2@(15),%d0
    moveq #0,%d2
    moveb %pc@(POWERMGRPRIMITIVES_C5B_C7,%d0:w),%d2
    subb %a2@(35),%d2
    addqb #4,%d0
    rorw #3,%d0
    moveq #0,%d1
    moveb %a2@(34),%d1
    subb %a2@(35),%d1
    jbsr POWERMGRPRIMITIVES_D26
    swap %d0
    moveq #0,%d1
    moveb %a2@(82),%d1
    subb %a2@(35),%d1
    jbsr POWERMGRPRIMITIVES_D26
    rts
POWERMGRPRIMITIVES_C5B_C7:
    .short  0x7BBC, 0x7BD0	| 408B50F2

POWERMGRPRIMITIVES_D26:  /* d0 low byte = 256 x d1 / d2, at most 255 */
    asll #8,%d1
    divuw %d2,%d1
    cmpiw #255,%d1
    jbls POWERMGRPRIMITIVES_D34
    moveb #0xff,%d1
POWERMGRPRIMITIVES_D34:  /* done */
    moveb %d1,%d0
    rts

POWERMGRPRIMITIVES_D38:  /* battery state: PMgrOp 0x6D and 0x6B, scaled levels in d0 */
    linkw %fp,#0
    clrw %sp@-
    clrl %sp@-
    clrl %sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #109,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    clrl %sp@-
    clrl %sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #107,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    moveal %sp,%a0
    moveq #71,%d0
    andb %a0@+,%d0
    rorw #3,%d0
    movel %a0@+,%d2
    addqw #1,%a0
    movew %a0@+,%d2
    moveal %a0,%sp
    tstw %d0
    jbpl POWERMGRPRIMITIVES_DD0
    bclr #3,%d0
    jbeq POWERMGRPRIMITIVES_D94
    swap %d0
    moveq #0,%d1
    movew %sp@,%d1
    subw %d2,%d1
    jble POWERMGRPRIMITIVES_DCC
    movew %sp@,%d2
    jbsr POWERMGRPRIMITIVES_D26
    jbra POWERMGRPRIMITIVES_DCC
POWERMGRPRIMITIVES_D94:  /* (other battery kind) */
    lea %sp@(4),%a0
    btst #14,%d0
    jbne POWERMGRPRIMITIVES_DA0
    addqw #4,%a0
POWERMGRPRIMITIVES_DA0:  /* level */
    movew %a0@,%d2
    subw %a0@-,%d2
    jble POWERMGRPRIMITIVES_DD0
    btst #14,%d0
    jbne POWERMGRPRIMITIVES_DBC
    moveq #0,%d1
    moveb %a2@(34),%d1
    addb %d1,%d1
    subw %a0@,%d1
    jble POWERMGRPRIMITIVES_DBC
    jbsr POWERMGRPRIMITIVES_D26
POWERMGRPRIMITIVES_DBC:  /* second level */
    swap %d0
    movel %d2,%d1
    clrw %d1
    swap %d1
    subw %a0@,%d1
    jble POWERMGRPRIMITIVES_DCC
    jbsr POWERMGRPRIMITIVES_D26
POWERMGRPRIMITIVES_DCC:  /* done */
    unlk %fp
    rts
POWERMGRPRIMITIVES_DD0:  /* no battery information */
    clrb %d0
    swap %d0
    jbra POWERMGRPRIMITIVES_DCC
