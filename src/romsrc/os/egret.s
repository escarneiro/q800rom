/*
 os/egret.s - Egret manager and patches, power off, one-second interrupts
 From EGRETMGR (0x408147C0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. Egret is a
 microcontroller (ADB, clock, PRAM, power) talking to the 68040 through the VIA 1
 shift register: port B bit 3 = Egret's transfer request, bit 4 = byte acknowledge,
 bit 5 = system session. Globals (76 bytes, 0xDE0): +0 flags (bit 0 busy, 1 receive
 into the caller's buffer, 2 second byte expected), +2/+4 bytes to send and pointer,
 +8/+10 second part, +14/+16 receive count and bytes received, +18/+20 caller's
 receive buffer, +24 receive buffer, +40 handler of unsolicited packets, +44 packet
 handler, +48/+52 parameter blocks. Packets: type (0 ADB, 1 pseudo command, 2 error),
 command, data.
*/

/*
 INITEGRET: allocate the Egret globals (or INITEGRETALT with a0 = a block on the
 stack, before RAM is set up), install the shift register interrupt handler
 (EGRETDISPATCH_112) and enable the interrupt.
*/
EGRETMGR:
INITEGRET:
    moveq #76,%d0
    .short  0xA71E	| 408147C2 _NewPtr (flags 0x0700)

INITEGRETALT:           /* (with the block in a0) */
    movel %a0,0xde0
    moveal %a0,%a2
    movew %sr,%sp@-
    oriw #1792,%sr
    lea %a2@(56),%a0
    movel %a0,%a2@(48)
    jbsr SETRESPONSEPARAMS
    lea %pc@(EGRETDISPATCH_112),%a0
    movel %a0,Lvl1DT_2
    lea %pc@(SETRESPONSEPARAMS_2E),%a0
INITEGRETALT_24:        /* unsolicited packet handler, SR interrupt on */
    movel %a0,%a2@(40)
    moveal VIA,%a1
    bclr #4,%a1@(5632)
    moveb #0x84,%a1@(7168)
    movew %sp@+,%sr
    rts

/*
 _EgretDispatch(a0 = parameter block: type, command, data count/pointer, receive
 count/pointer, completion): send a packet to Egret. Waits (polling the interrupt when
 interrupts are masked) until Egret is free, starts the transfer, and either waits for
 the completion or returns at once if there is a completion routine.
*/
trap_EgretDispatch:
EGRETDISPATCH:
    bsrw EGRETDISPATCH_86
    bnew EGRETDISPATCH_82
    moveal 0xde0,%a2
    moveal VIA,%a1
    cmpib #0xff,%a0@
    jbsr EGRETPATCHTOO
    nop
    nop
EGRETDISPATCH_1E:       /* Egret busy? (it may be sending to us) */
    movew %sr,%sp@-
    oriw #1792,%sr
    btst #3,%a1@
    jbeq EGRETDISPATCH_30
    bset #0,%a2@
    jbeq EGRETDISPATCH_38
EGRETDISPATCH_30:       /* poll and retry */
    movew %sp@+,%sr
    jbsr EGRETDISPATCH_C4
    jbra EGRETDISPATCH_1E
EGRETDISPATCH_38:       /* start: session, output, first byte, acknowledge */
    bset #5,%a1@
    bset #4,%a1@(5632)
    moveb %a0@,%a1@(5120)
    bset #4,%a1@
EGRETDISPATCH_4A:       /* wait for the shift register */
    btst #2,%a1@(6656)
    jbeq EGRETDISPATCH_4A
    btst #3,%a1@
    jbne EGRETDISPATCH_68
    bclr #4,%a1@(5632)
    bclr #5,%a1@
    jbsr EGRETDISPATCH_E8
    jbra EGRETDISPATCH_30
EGRETDISPATCH_68:       /* Egret took it: set up the rest (EGRETDISPATCH_2F6) */
    jsr %pc@(EGRETDISPATCH_2F6)
    bsrw EGRETDISPATCH_E8
    movew %sp@+,%sr
    tstl %a0@(16)
    jbne EGRETDISPATCH_82
EGRETDISPATCH_78:       /* no completion routine: wait for the end */
    btst #0,%a2@
    jbeq EGRETDISPATCH_82
    jbsr EGRETDISPATCH_C4
    jbra EGRETDISPATCH_78
EGRETDISPATCH_82:       /* return 0 */
    moveq #0,%d0
    rts

EGRETDISPATCH_86:       /* check the packet: type and command valid? (error -50 in the block) */
    jbsr CHECKPACKETPATCH
    cmpib #2,%a0@
    jbhi EGRETDISPATCH_AC
    cmpib #1,%a0@
    jbne EGRETDISPATCH_BE
    cmpib #33,%a0@(1)
    jbls EGRETDISPATCH_BE
    movew #514,%a0@(2)
    movew %a0@,%a0@(4)
    jbra EGRETDISPATCH_B6
EGRETDISPATCH_AC:       /* (bad type) */
    movew #513,%a0@(2)
    movew %a0@,%a0@(4)
EGRETDISPATCH_B6:       /* -50 */
    movew #-50,%a0@(14)
    jbra EGRETDISPATCH_C2
EGRETDISPATCH_BE:       /* valid */
    clrw %a0@(14)
EGRETDISPATCH_C2:       /* return */
    rts

EGRETDISPATCH_C4:       /* interrupts masked: poll the shift register interrupt */
    movew %sr,%d0
    andiw #1792,%d0
    jbeq EGRETDISPATCH_D6
    btst #2,%a1@(6656)
    jbeq EGRETDISPATCH_D6
    jbsr EGRETDISPATCH_E8
EGRETDISPATCH_D6:       /* return */
    rts

EGRETDISPATCH_D8:       /* send byte d0 (acknowledge toggled, short delay) */
    bclr #4,%a1@
    jbsr thunk_FUN_4088542e
    moveb %d0,%a1@(5120)
    bset #4,%a1@
    rts

EGRETDISPATCH_E8:       /* call the shift register handler */
    moveml %d0-%d3/%a0-%a3,%sp@-
    moveal Lvl1DT_2,%a0
    jsr %a0@
    moveml %sp@+,%d0-%d3/%a0-%a3
    rts

EGRETDISPATCH_F8:       /* acknowledge, delay */
    bset #4,%a1@
    jbsr thunk_FUN_4088542e
    rts

thunk_FUN_4088542e:     /* continue at DELAY100PATCH */
    jbra DELAY100PATCH
    lsrw #3,%d1
EGRETDISPATCH_F8_10:
    tstb %a1@
    dbf %d1,EGRETDISPATCH_F8_10
    movel %sp@+,%d1
    rts
EGRETDISPATCH_112:      /* shift register interrupt: send the next byte or receive one */
    movew %sr,%d3
    oriw #1792,%sr
    moveal 0xde0,%a2
    bset #0,%a2@
    btst #4,%a1@(5632)
    jbeq EGRETDISPATCH_170
    tstb %a1@(5120)
    tstw %a2@(2)
    jble EGRETDISPATCH_146
    moveal %a2@(4),%a0
    moveb %a0@+,%d0
    movel %a0,%a2@(4)
    jbsr EGRETDISPATCH_D8
    subqw #1,%a2@(2)
    jbra EGRETDISPATCH_2F4
EGRETDISPATCH_146:      /* (second part of the data) */
    tstw %a2@(8)
    jble EGRETDISPATCH_160
    moveal %a2@(10),%a0
    moveb %a0@+,%d0
    movel %a0,%a2@(10)
    jbsr EGRETDISPATCH_D8
    subqw #1,%a2@(8)
    jbra EGRETDISPATCH_2F4
EGRETDISPATCH_160:      /* all sent: switch to input */
    bclr #4,%a1@(5632)
    andib #0xcf,%a1@
    jbsr thunk_FUN_4088542e
    jbra EGRETDISPATCH_2F4
EGRETDISPATCH_170:      /* receiving: the byte */
    moveb %a1@(5120),%d0
    tstw %a2@(14)
    jble EGRETDISPATCH_1AE
    btst #5,%a1@
    jbne EGRETDISPATCH_186
    jbsr thunk_FUN_4088542e
    jbra EGRETDISPATCH_18A
EGRETDISPATCH_186:      /* (acknowledge) */
    jbsr EGRETDISPATCH_F8
EGRETDISPATCH_18A:      /* into the receive buffer (header) */
    movew %a2@(16),%d1
    lea %a2@(24),%a0
    moveb %d0,%a0@(0x0,%d1:w)
    addqw #1,%a2@(16)
    subqw #1,%a2@(14)
    jble EGRETDISPATCH_1D4
    btst #3,%a1@
    jbne EGRETDISPATCH_204
    bset #5,%a1@
    jbra EGRETDISPATCH_2F0
EGRETDISPATCH_1AE:      /* into the caller's buffer */
    moveal %a2@(20),%a0
    moveb %d0,%a0@+
    movel %a0,%a2@(20)
    subqw #1,%a2@(18)
    jbgt EGRETDISPATCH_1F2
    btst #1,%a2@
    jbeq EGRETDISPATCH_1F2
    jbsr EGRETDISPATCH_F8
    bclr #5,%a1@
EGRETDISPATCH_1CC:      /* wait for the end of the session */
    btst #3,%a1@
    jbeq EGRETDISPATCH_1CC
    jbra EGRETDISPATCH_204
EGRETDISPATCH_1D4:      /* header complete: error packet has one more byte */
    lea %a2@(24),%a0
    cmpib #2,%a0@(1)
    jbne EGRETDISPATCH_1F6
    bclr #2,%a2@
    jbne EGRETDISPATCH_1F6
    addqw #1,%a2@(14)
    bset #2,%a2@
    jbra EGRETDISPATCH_2F0
EGRETDISPATCH_1F2:      /* acknowledge */
    jbsr EGRETDISPATCH_F8
EGRETDISPATCH_1F6:      /* more coming? */
    btst #3,%a1@
    jbne EGRETDISPATCH_204
    tstw %a2@(18)
    jbgt EGRETDISPATCH_2F0
EGRETDISPATCH_204:      /* packet complete: end the session, deliver it */
    bclr #4,%a1@
    bclr #5,%a1@
    jbsr thunk_FUN_4088542e
    moveal %a2@(52),%a0
    lea %a2@(24),%a1
    cmpib #2,%a1@(1)
    jbne EGRETDISPATCH_22C
    movel %a1@(1),%a0@(2)
    movew #-50,%a0@(14)
EGRETDISPATCH_22C:      /* our request's reply or an unsolicited packet? */
    cmpal %a2@(48),%a0
    jbeq EGRETDISPATCH_288
    tstb %a1@(1)
    jbne EGRETDISPATCH_272
    cmpal %a2@(48),%a0
    jbne EGRETDISPATCH_244
    bset #6,%a1@(2)
EGRETDISPATCH_244:      /* reply: result, data count, copy the data */
    btst #6,%a1@(2)
    bnew EGRETDISPATCH_2AE
    moveb %a1@(2),%a0@(12)
    movew %a2@(16),%d0
    subqw #4,%d0
    jbeq EGRETDISPATCH_260
    movew %d0,%a0@(6)
EGRETDISPATCH_260:      /* copy */
    moveal %a0@(8),%a2
    addqw #4,%a1
    jbra EGRETDISPATCH_26A
EGRETDISPATCH_268:      /* one byte */
    moveb %a1@+,%a2@+
EGRETDISPATCH_26A:      /* (count) */
    dbf %d0,EGRETDISPATCH_268
    moveal 0xde0,%a2
EGRETDISPATCH_272:      /* completion routine */
    movel %a0@(16),%d0
    beqw EGRETDISPATCH_2E8
    moveal %d0,%a1
    movel %a0,%sp@-
    jbsr SETRESPONSEPARAMS
    movew %d3,%sr
    moveal %sp@+,%a0
    jmp %a1@
EGRETDISPATCH_288:      /* unsolicited packet (ADB auto-poll data, clock tick, ...) */
    tstb %a1@(1)
    jbeq EGRETDISPATCH_2AE
    cmpib #3,%a1@(1)
    jbeq EGRETDISPATCH_2A6
    cmpib #1,%a1@(1)
    jbsr SHIFTREGIRQPATCH
    nop
    nop
EGRETDISPATCH_2A6:      /* its handler */
    movel %a2@(40),%d2
    jbeq EGRETDISPATCH_2E8
    jbra EGRETDISPATCH_2BE
EGRETDISPATCH_2AE:      /* (flag it) */
    bset #6,%a1@(2)
    tstl %a0
    jbeq EGRETDISPATCH_2E8
    movel %a0@(16),%d2
    jbeq EGRETDISPATCH_2E8
EGRETDISPATCH_2BE:      /* call the handler with a copy of the packet */
    subaw #12,%sp
    moveal %sp,%a2
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    moveal 0xde0,%a2
    movew %a2@(16),%d0
    subqw #4,%d0
    jbsr SETRESPONSEPARAMS
    movew %d3,%sr
    moveal %sp,%a1
    addql #2,%a1
    moveal %d2,%a3
    jsr %a3@
    lea %sp@(12),%sp
    jbra EGRETDISPATCH_2F4
EGRETDISPATCH_2E8:      /* ready for the next packet */
    jbsr SETRESPONSEPARAMS
    movew %d3,%sr
    jbra EGRETDISPATCH_2F4
EGRETDISPATCH_2F0:      /* acknowledge off */
    bclr #4,%a1@
EGRETDISPATCH_2F4:      /* return */
    rts

EGRETDISPATCH_2F6:      /* set up a transfer from the parameter block: lengths from the command table */
    movel %a1,%sp@-
    lea %a0@(1),%a1
    movel %a1,%a2@(4)
    moveq #0,%d0
    moveb %a0@(1),%d0
    tstb %a0@
    jbne EGRETDISPATCH_314
    jbsr SETTRANSFERPARMSPATCH
    nop
    jbra EGRETDISPATCH_338
EGRETDISPATCH_314:      /* command 14 (write data): length from the block */
    cmpib #14,%a0@(1)
    jbne EGRETDISPATCH_334
    movew %a0@(6),%d1
    addqw #1,%d1
    movew %d1,%a2@(2)
    clrw %a2@(8)
    clrw %a2@(8)
    clrl %a2@(10)
    jbra EGRETDISPATCH_36E
EGRETDISPATCH_334:      /* other commands: the table */
    lea %pc@(SETRESPONSEPARAMS_38),%a1
EGRETDISPATCH_338:      /* lengths for the command */
    lslw #1,%d0
    movew %a1@(0x0,%d0:w),%d1
    rorw #8,%d1
    tstb %d1
    jbmi EGRETDISPATCH_358
    moveb %d1,%d0
    extw %d0
    addqb #1,%d0
    movew %d0,%a2@(2)
    clrw %a2@(8)
    clrl %a2@(10)
    jbra EGRETDISPATCH_36E
EGRETDISPATCH_358:      /* (data from the block) */
    moveq #127,%d0
    andw %d1,%d0
    addqw #1,%d0
    movew %d0,%a2@(2)
    movew %a0@(6),%a2@(8)
    movel %a0@(8),%a2@(10)
EGRETDISPATCH_36E:      /* receive set-up */
    clrw %a2@(16)
    movew #4,%a2@(14)
    asrw #8,%d1
    jbmi EGRETDISPATCH_39C
    tstb %a0@
    jbeq EGRETDISPATCH_38E
    lea %a0@(2),%a1
    movel %a1,%a2@(20)
    movew %d1,%a2@(18)
    jbra EGRETDISPATCH_3AC
EGRETDISPATCH_38E:      /* (no data) */
    addw %d1,%a2@(14)
    clrw %a2@(18)
    bclr #1,%a2@
    jbra EGRETDISPATCH_3AC
EGRETDISPATCH_39C:      /* reply into the caller's buffer */
    movew %a0@(6),%a2@(18)
    movel %a0@(8),%a2@(20)
    bset #1,%a2@
EGRETDISPATCH_3AC:      /* current block */
    movel %a0,%a2@(52)
    moveal %sp@+,%a1
    rts

/* SETRESPONSEPARAMS: reset the transfer state to "waiting for a packet from Egret". */
SETRESPONSEPARAMS:
    clrl %a2@(4)
    clrw %a2@(2)
    clrw %a2@(8)
    clrl %a2@(10)
    movew #12,%a2@(14)
    clrw %a2@(16)
    clrw %a2@(18)
    clrl %a2@(20)
    movel %a2@(48),%a2@(52)
    andib #0xfc,%a2@
    rts
SETRESPONSEPARAMS_2E:   /* default unsolicited handler: the level 1 dispatch */
    moveal VIA,%a1
    moveal Lvl1DT,%a0
    jmp %a0@
SETRESPONSEPARAMS_38:   /* send/receive lengths per command */
    .long   0x00000100	| 40814BEC
    .long   0x02FF0004, 0x00020002, 0x000202FF, 0x82000400	| 40814BF0
    .long   0x00000400, 0x82000100, 0x01000002, 0x00010000	| 40814C00
    .long   0x01000100, 0x01000002, 0x00010100, 0x00010200	| 40814C10
    .long   0x00020100, 0x01000100, 0x01000001, 0x80000100	| 40814C20
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40814C30
    .long   0x00000000, 0x00000000, 0x00000000	| 40814C40

/*
 EGRETINIT: talk to Egret before RAM is ready (register-only): reset
 the session, read a PRAM byte, set the one second interrupt mode.
*/
EGRETINIT:
    moveal %a0@(8),%a1
    bclr #5,%a1@
    bclr #4,%a1@
    moveq #40,%d0
EGRETINIT_E:
    lea %pc@(EGRETINIT_16),%a5
    jmp %pc@(SENDEGRETCMD_1D0)
EGRETINIT_16:
    dbf %d0,EGRETINIT_E
    moveal %fp,%a4
    movel #65537,%d0
    moveq #0,%d1
    moveq #1,%d2
    lea %pc@(EGRETINIT_2E),%fp
    jmp %pc@(SENDEGRETCMD)
EGRETINIT_2E:
    tstw %d0
    bnes EGRETINIT_76_2
    movel #1769473,%d0
    moveq #0,%d1
    moveq #1,%d2
    lea %pc@(EGRETINIT_44),%fp
    jmp %pc@(SENDEGRETCMD)
EGRETINIT_44:
    tstw %d0
    bnes EGRETINIT_76_2
    moveq #0,%d2
    lea %pc@(EGRETINIT_58),%fp
EGRETINIT_4E:
    lea 0xfffee29a,%a2	| 40814C9A
    jmp %pc@(EGRETINIT_4E,%a2:l)
EGRETINIT_58:
    btst #7,%a1@(31)
    beqs EGRETINIT_64
    moveq #87,%d1
    jbra EGRETINIT_66
EGRETINIT_64:
    moveq #0,%d1	| 40814CB0
EGRETINIT_66:           /* Egret command 0x0E 01 (d2 = 1 data byte) */
    movel #917505,%d0
    moveq #1,%d2
    lea %pc@(EGRETINIT_76),%fp
    jmp %pc@(SENDEGRETCMD)
EGRETINIT_76:           /* return through a4 */
    tstw %d0
EGRETINIT_76_2:
    moveal %a4,%fp
    jmp %fp@

/*
 SENDEGRETCMD: send a command to Egret and get the reply, without RAM (returns through
 fp, registers only, partly raw words). A timeout is a system error (d7 = 48).
*/
SENDEGRETCMD:
    moveal %a0@(8),%a1
    movel #536871168,%d4
    lea %pc@(SENDEGRETCMD_12),%a5
    jmp %pc@(SENDEGRETCMD_1D0)
SENDEGRETCMD_12:        /* (raw words) */
    .short  0x0811, 0x0005, 0x6718	| 40814CDA
SENDEGRETCMD_18:        /* retry */
    .short  0x0891	| 40814CE0
    .short  0x0005, 0x0891	| orib #0x91,%d5
    .short  0x0004, 0x4BFA	| orib #0xfa,%d4
    .short  0x0006, 0x4EFA	| orib #0xfa,%d6
    bclr %d0,%a2@(19450)
    .short  0x0006, 0x4EFA	| orib #0xfa,%d6
    bclr %d0,%a2@-
    swap %d4
    btst #3,%a1@
    jbeq SENDEGRETCMD_138
    bset #5,%a1@
    lea %pc@(SENDEGRETCMD_46),%a5
    jmp %pc@(SENDEGRETCMD_E0)
SENDEGRETCMD_46:
    jbeq SENDEGRETCMD_134	| 40814D0E
    swap %d0	| 40814D12
    lea %pc@(SENDEGRETCMD_54),%a5	| 40814D14
    jmp %pc@(SENDEGRETCMD_182)	| 40814D18
SENDEGRETCMD_54:        /* (data) */
    .byte   0x4B, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x01, 0x76, 0x20, 0x01, 0x53, 0x42	| 40814D1C
    cmpiw #3,%d2
    jbhi SENDEGRETCMD_7C
    lea %pc@(SENDEGRETCMD_6E),%a5
    jmp %pc@(SENDEGRETCMD_182)
SENDEGRETCMD_6E:        /* (raw words) */
    lea %pc@(SENDEGRETCMD_76),%a5	| 40814D36
    jmp %pc@(SENDEGRETCMD_1D0)	| 40814D3A
SENDEGRETCMD_76:        /* (data) */
    .byte   0xE0, 0x88, 0x51, 0xCA, 0xFF, 0xEC	| 40814D3E
SENDEGRETCMD_7C:        /* switch to input */
    bclr #4,%a1@(5632)
    bclr #5,%a1@
    lea %pc@(SENDEGRETCMD_8E),%a5
    jmp %pc@(SENDEGRETCMD_1D0)
SENDEGRETCMD_8E:        /* wait */
    lea %pc@(SENDEGRETCMD_96),%a5
    jmp %pc@(SENDEGRETCMD_1C2)
SENDEGRETCMD_96:        /* (raw words: reply bytes) */
    lea %pc@(SENDEGRETCMD_9E),%a5	| 40814D5E
    jmp %pc@(SENDEGRETCMD_1D0)	| 40814D62
SENDEGRETCMD_9E:        /* (data) */
    .byte   0x08, 0xD1, 0x00, 0x05, 0x4B, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x00, 0xFA, 0x02, 0x40, 0x00, 0xFF	| 40814D66
    .byte   0x48, 0x40, 0x4B, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x00, 0xEC, 0x02, 0x40, 0x00, 0xFF, 0x48, 0x40	| 40814D76
    .byte   0xC1, 0x41, 0x4B, 0xFA, 0x00, 0x06, 0x4E, 0xFA, 0x00, 0xDC, 0x08, 0x91, 0x00, 0x05, 0x4B, 0xFA	| 40814D86
    .byte   0x00, 0x06, 0x4E, 0xFA, 0x00, 0xFE, 0x20, 0x01, 0x0C, 0x00, 0x00, 0x02, 0x67, 0x02, 0x90, 0x40	| 40814D96
    .byte   0x4E, 0xD6	| 40814DA6
SENDEGRETCMD_E0:        /* send byte d0 */
    bset #4,%a1@(5632)
    btst #3,%a1@
    jbeq SENDEGRETCMD_132
    moveb %d0,%a1@(5120)
    bset #4,%a1@
SENDEGRETCMD_F4:        /* wait for the shift register, with a timeout */
    btst #2,%a1@(6656)
    jbne SENDEGRETCMD_11C
    dbf %d4,SENDEGRETCMD_F4
    movew #8192,%d4
    swap %d4
    subqw #1,%d4
    jbne SENDEGRETCMD_18
    movew #48,%d7
    moveq #1,%d6
    bigjmp ERROR1HANDLER, a3
SENDEGRETCMD_11C:       /* acknowledge, delay */
    tstb %a1@(5120)
    bclr #4,%a1@
    movew #104,%d3
SENDEGRETCMD_128:       /* delay */
    tstb %a1@
    dbf %d3,SENDEGRETCMD_128
    btst #3,%a1@
SENDEGRETCMD_132:       /* return through a5 */
    jmp %a5@
SENDEGRETCMD_134:       /* clear bit 5 of %a1@ */
    bclr #5,%a1@	| 40814DFC
SENDEGRETCMD_138:       /* Egret not ready: abort its transfer */
    lea %pc@(SENDEGRETCMD_140),%a5
    jmp %pc@(SENDEGRETCMD_1D0)
SENDEGRETCMD_140:
    bclr #4,%a1@(5632)	| 40814E08
    tstb %a1@(5120)	| 40814E0E
    bset #5,%a1@	| 40814E12
SENDEGRETCMD_14E:       /* (raw words) */
    .byte   0x08, 0x91	| 40814E16
SENDEGRETCMD_150:       /* (inside raw words) */
    .byte   0x00, 0x04	| 40814E18
    btst #2,%a1@(6656)	| 40814E1A
    jbeq SENDEGRETCMD_152
    bset #4,%a1@
    tstb %a1@(5120)
    movew #104,%d3
SENDEGRETCMD_166:       /* delay */
    tstb %a1@
    dbf %d3,SENDEGRETCMD_166
    jbeq SENDEGRETCMD_14E
    bclr #4,%a1@
    bclr #5,%a1@
    lea %pc@(SENDEGRETCMD_17E),%a5
    jmp %pc@(SENDEGRETCMD_1D0)
SENDEGRETCMD_17E:       /* retry */
    jbra SENDEGRETCMD	| 40814E46
SENDEGRETCMD_182:       /* send one data byte */
    bset #4,%a1@(5632)
    moveb %d0,%a1@(5120)
    bset #4,%a1@
SENDEGRETCMD_190:       /* wait */
    btst #2,%a1@(6656)
    jbeq SENDEGRETCMD_190
    tstb %a1@(5120)
    bclr #4,%a1@
    jmp %a5@
SENDEGRETCMD_190_12:
    btst #2,%a1@(6656)
    beqs SENDEGRETCMD_190_12
    bset #4,%a1@
    moveb %a1@(5120),%d0
    movew #104,%d3
SENDEGRETCMD_190_26:
    tstb %a1@
    dbf %d3,SENDEGRETCMD_190_26
    bclr #4,%a1@
    jmp %a5@
SENDEGRETCMD_1C2:       /* wait for a byte from Egret */
    btst #2,%a1@(6656)
    jbeq SENDEGRETCMD_1C2
    tstb %a1@(5120)
    jmp %a5@
SENDEGRETCMD_1D0:       /* delay (104 VIA reads) */
    movew #104,%d3
SENDEGRETCMD_1D4:       /* loop */
    tstb %a1@
    dbf %d3,SENDEGRETCMD_1D4
    jmp %a5@
    .fill   0x24C, 1, 0x00

/* EGRETPATCHES: patch space (zeros). */
EGRETPATCHES:
    .fill   0x364, 1, 0x00

/* POWEROFFPATCH (raw words): on Egret machines, power off through Egret. */
POWEROFFPATCH:
    .short  0x61FF	| 40815454
    .long   CHECKFOREGRET-.	| 40815456
    bnes EGRETPOWEROFF_24
    bras EGRETPOWEROFF
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4081545E

/* EGRETPOWEROFF: Egret command 0x0A (power down), then wait. */
EGRETPOWEROFF:
    movel %a0,%sp@-
    subaw #20,%sp
    moveal %sp,%a0
    moveb #1,%a0@
    moveb #10,%a0@(1)
    clrb %a0@(2)
    clrl %a0@(16)
    _EgretDispatch
    addaw #20,%sp
    moveal %sp@+,%a0
    jbra EGRETPOWEROFF_4A
EGRETPOWEROFF_24:
    moveal ghost_VIA2,%a0
    btst #3,0xdd2
    bnes EGRETPOWEROFF_38
    btst #5,0xdd2
    beqs EGRETPOWEROFF_40
EGRETPOWEROFF_38:
    moveq #2,%d0
    bset %d0,%a0@(1024)
    bclr %d0,%a0@
EGRETPOWEROFF_40:
    lea 0xffff4984,%a0	| 408154A6
    jmp %pc@(EGRETPOWEROFF_40,%a0:l)
EGRETPOWEROFF_4A:       /* wait (about 500 x TimeDBRA loops) */
    movel #-32768000,%d0
EGRETPOWEROFF_50:       /* one millisecond */
    movew TimeDBRA,%d0
EGRETPOWEROFF_54:       /* loop */
    dbf %d0,EGRETPOWEROFF_54
    addql #1,%d0
    jbne EGRETPOWEROFF_50
    rts

/*
 ENABLEONESECINTS: the one second interrupt: from Egret (command 0x1B, mode 3) on Egret
 machines, else VIA 1 CA2.
*/
ENABLEONESECINTS:
    movel 0xdd4,%d3
    andib #112,%d3
    cmpib #32,%d3
    jbne STARTEGRET1SECIRQ_26

STARTEGRET1SECIRQ:      /* set %sp@- */
    movel %a0,%sp@-
    subaw #20,%sp
    moveal %sp,%a0
    moveb #1,%a0@
    moveb #27,%a0@(1)
    moveb #3,%a0@(2)
    clrl %a0@(16)
    _EgretDispatch
    addaw #20,%sp
    moveal %sp@+,%a0
    rts
STARTEGRET1SECIRQ_26:   /* VIA 1 CA2 interrupt on */
    moveal VIA,%a0
    moveb #0x81,%a0@(7168)
    rts
    .fill   0xFC, 1, 0x00
STARTEGRET1SECIRQ_12E:  /* (zeros) */
    .fill   0x3D0, 1, 0x00
