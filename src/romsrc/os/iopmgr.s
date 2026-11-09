/*
 os/iopmgr.s - I/O processor (IOP) manager, SCC IOP
 From IOPMGR (0x40804CC0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the IOP Manager description in Inside
 Macintosh), not taken from Apple. IOPs are 6502-based I/O processors (SCC IOP 0,
 SWIM IOP 1) sharing RAM with the 68040 through an address/data register pair; the
 messages are in mailboxes in that RAM. Globals: 0xC28, per IOP 168 bytes (+0 address
 register, +4 data register, +8 control register, message queues and handlers).
*/

/*
 IOPINFOACCESS: _IOPInfoAccess: 0 get the IOP's information, 1 set it,
 2 install a new IOP with its code (download the 6502 code in an 'iopc' resource,
 reset and start the IOP).
*/
IOPMGR:
IOPINFOACCESS:
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveq #0,%d0
    moveq #0,%d1
    moveb %a0@,%d1
    cmpib #2,%d1
    bhis IOPINFOACCESS_2E
    movew %pc@(IOPINFOACCESS_28,%d1:w:2),%d2
    moveb %a0@(1),%d1
    cmpib #7,%d1
    bhis IOPINFOACCESS_2E
    lea @(0xc28)@(0x0,%d1:w:4),%a1	| 40804CDE
    jmp %pc@(IOPINFOACCESS_28,%d2:w)
IOPINFOACCESS_28:
    orib #10,%a4@+
    .short  0x0014	| 40804CEC
IOPINFOACCESS_2E:
    moveq #-50,%d0
    jbra IOPMGR_36
    .short  0x2151, 0x0004	| 40804CF2
IOPMGR_36:              /* return */
    moveml %sp@+,%d3-%d4/%a2-%a4
    rts
    .short  0x2151	| 40804CFC
    .short  0x0004, 0x4291	| orib #0x91,%d4
    jbra IOPMGR_36
    tstl %a1@
    bnes IOPINFOACCESS_2E
    moveal %a0@(4),%a4
    movel %d1,%d3
    subql #4,%sp
    movel #1768910947,%sp@-
    movew %d3,%sp@-
    _RGetResource
    movel %sp@+,%d0
    beqs IOPINFOACCESS_2E
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal %a4@+,%a2
    moveal %a4@+,%a3
    moveal %a4@,%a1
    moveb #50,%a1@
    movew #32767,%d0
    moveq #-1,%d1
IOPMGR_36_42:
    movew %d0,%a2@
    moveb %d1,%a3@
    dbf %d0,IOPMGR_36_42
    movew #32767,%d0
IOPMGR_36_4E:
    movew %d0,%a2@
    moveb %a3@,%d1
    notb %d1
    movew %d0,%a2@
    moveb %d1,%a3@
    dbne %d0,IOPMGR_36_4E
    bnes IOPMGR_36_A6
    movew #32767,%d0
IOPMGR_36_62:
    movew %d0,%a2@
    moveb %a3@,%d1
    dbne %d0,IOPMGR_36_62
    bnes IOPMGR_36_A6
    moveal %a0,%a1
IOPMGR_36_6E:
    moveb %a0@+,%d0
    beqs IOPMGR_36_8A
    movew %a0@+,%a2@
IOPMGR_36_74:
    moveb %a0@+,%a3@
    subqb #1,%d0
    bnes IOPMGR_36_74
    moveb %a1@+,%d0
    movew %a1@+,%a2@
IOPMGR_36_7E:
    moveb %a3@,%d1
    cmpb %a1@+,%d1
    bnes IOPMGR_36_A6
    subqb #1,%d0
    bnes IOPMGR_36_7E
    bras IOPMGR_36_6E
IOPMGR_36_8A:
    movew #799,%a2@
    clrb %a3@
    moveal %a4@,%a1
    moveb #54,%a1@
    moveq #-1,%d0
IOPMGR_36_98:
    movew #799,%a2@
    cmpib #0xff,%a3@	| 40804D92
    dbeq %d0,IOPMGR_36_98
    beqs IOPMGR_36_AC
IOPMGR_36_A6:
    movew %sp@+,%sr
    braw IOPINFOACCESS_2E
IOPMGR_36_AC:
    movew #512,%a2@
    addql #8,%a4
    moveb %a3@,%a4@+
    movew #768,%a2@
    moveb %a3@,%a4@
    subaw #17,%a4
    movel %a4,@(0xc28)@(0x0,%d3:w:4)	| 40804DB4
    lea %a4@(20),%a0
    lea %a0@(6),%a1
    moveb %d3,%a1@+
    moveb #2,%a1@+
    movel #17566720,%a1@+
    lea %a4@(44),%a2
    movel %a2,%a1@+
    movel %a2,%a1@+
    lea %pc@(MOVEREQHANDLER),%a2
    movel %a2,%a1@+
    _IOPMsgRequest
    movew %sp@+,%sr
    braw IOPMGR_36

/*
 IOPMSGREQUEST (raw words partly): _IOPMsgRequest(a0 = message request): send a message
 to an IOP mailbox (0/1 = transmit, wait for the reply, 2 = install a receive handler,
 3 = remove it). The message is copied into the IOP's RAM and its mailbox state set.
*/
IOPMSGREQUEST:
    moveml %d3-%d4/%a2-%a3,%sp@-
    moveq #-50,%d0
    moveq #0,%d2
    lea %a0@(6),%a1
    moveb %a1@+,%d2
    cmpiw #7,%d2
    bhis IOPMSGREQUEST_3C
    moveal 0xc28,%a2
    moveal %a2@(0x0,%d2:w:4),%a2
    movel %a2,%d3
    beqs IOPMSGREQUEST_38
    moveb %a2@(16),%d3
    moveb %a1@+,%d2
    beqs IOPMSGREQUEST_2C
    moveb %a2@(17),%d3
IOPMSGREQUEST_2C:
    cmpiw #3,%d2
    bhis IOPMSGREQUEST_3C
    movew %pc@(IOPMSGREQUEST_3C_18,%d2:w:2),%d1	| 40804E16
    moveb %a1@+,%d2
IOPMSGREQUEST_38:
    beqs IOPMSGREQUEST_8C_26
    cmpb %d3,%d2
IOPMSGREQUEST_3C:
    bhis IOPMSGREQUEST_8C_26
    movew %d2,%d3
    lslw #4,%d2
    moveq #32,%d4
    cmpb %a1@+,%d4
    bcss IOPMSGREQUEST_8C_26
    cmpb %a1@+,%d4
    bcss IOPMSGREQUEST_8C_26
    lea %a2@(0x28,%d2:w),%a3
    jmp %pc@(IOPMSGREQUEST_3C_18,%d1:w)	| 40804E34
IOPMSGREQUEST_3C_18:
    .byte   0x00, 0x08	| 40804E38
    oriw #134,%a0@(144)
    st %a1@
    lea %a3@(6),%a1
    movew %sr,%d2
    oriw #1792,%sr
    cmpal %a1@(2),%a0
    beqs IOPMSGREQUEST_78
    jsr %pc@(ENQUEUE)
    cmpal %a1@(2),%a0
    bnes IOPMSGREQUEST_8C_2C
IOPMSGREQUEST_78:
    movew %d2,%sr
    moveq #0,%d0
    moveb %a0@(9),%d0
    moveal %a0@(12),%a1
    moveb #1,%sp@-
    oriw #512,%d3
IOPMSGREQUEST_8C:       /* copy the message to the IOP RAM (IOPMOVEDATA_CE), set the state, interrupt the IOP */
    movew %d3,%sp@-
    lslb #5,%d3
    movel %a2@(8),%sp@-
    moveal %a2@(4),%a3
    moveal %a2@,%a2
    movew %a2@,%sp@-
    movew %d3,%a2@
    jbsr IOPMOVEDATA_CE
    movew %sp@+,%d0
    moveal %sp@+,%a1
    movew %sp@+,%a2@
    moveb %sp@+,%a3@
    movew %d0,%a2@
    moveb #14,%a1@
IOPMSGREQUEST_8C_24:
    moveq #0,%d0
IOPMSGREQUEST_8C_26:
    moveml %sp@+,%d3-%d4/%a2-%a3
    rts
IOPMSGREQUEST_8C_2C:
    movew %d2,%sr
    bras IOPMSGREQUEST_8C_24
    cmpal %a3@,%a0
    bnes IOPMSGREQUEST_8C_26
    tstb %a1@
    bnes IOPMSGREQUEST_8C_26
    st %a1@
    moveq #0,%d0
    moveb %a0@(10),%d0
    moveal %a0@(16),%a1
    moveb #3,%sp@-
    oriw #768,%d3
    jbra IOPMSGREQUEST_8C
    tstl %a3@
    bnes IOPMSGREQUEST_8C_26
    st %a1@
    movel %a0,%a3@
    bras IOPMSGREQUEST_8C_24
    cmpal %a3@,%a0
    bnes IOPMSGREQUEST_8C_26
    clrb %a1@
    clrl %a3@
    bras IOPMSGREQUEST_8C_24

/* IOPMOVEDATA (raw words partly): _IOPMoveData: copy to, from, or compare with IOP RAM. */
IOPMOVEDATA:
    moveml %a2-%a3,%sp@-
    moveq #-50,%d0
    moveq #0,%d2
    moveb %a0@+,%d2
    cmpiw #3,%d2
    bhis IOPMOVEDATA_40
    movew %pc@(IOPMOVEDATA_46,%d2:w:2),%d1
    moveb %a0@+,%d2
    cmpiw #7,%d2
    bhis IOPMOVEDATA_40
    moveal 0xc28,%a1
    moveal %a1@(0x0,%d2:w:4),%a2
    movel %a2,%d2
    beqs IOPMOVEDATA_40
    moveal %a2@(4),%a3
    moveal %a2@,%a2
    moveq #0,%d0
    movew %a0@+,%d0
    moveal %a0@+,%a1
    movew %a2@,%sp@-
    movew %a0@+,%a2@
    jsr %pc@(IOPMOVEDATA_46,%d1:w)
    movew %sp@+,%a2@
    moveq #0,%d0
IOPMOVEDATA_40:
    moveml %sp@+,%a2-%a3
    rts
IOPMOVEDATA_46:
    .short  0x0034, 0x0088, 0x00DC	| orib #-120,%a4@(ffffffffffffffdc,%d0:w)
    .short  0x0008	| .short 0x0008
    movew %sr,%d2
    oriw #1792,%sr
    movew #543,%d1
    movew %d1,%a2@
    moveq #1,%d0
    moveb %d0,%a3@
IOPMOVEDATA_5E:
    movew %d1,%a2@
    cmpb %a3@,%d0
    beqs IOPMOVEDATA_5E
IOPMOVEDATA_64:
    moveb %a1@+,%d0
    beqs IOPMOVEDATA_72
    movew %a1@+,%a2@
IOPMOVEDATA_6A:
    moveb %a1@+,%a3@
    subqb #1,%d0
    bnes IOPMOVEDATA_6A
    bras IOPMOVEDATA_64
IOPMOVEDATA_72:
    movew %d1,%a2@
    clrb %a3@
    movew %d2,%sr
    rts

IOPMOVEDATA_7A:         /* from the IOP data register (auto-increment) to RAM at a1, d0 bytes: align, then longs (unrolled by 8) */
    cmpiw #3,%d0
    jbls IOPMOVEDATA_C2
    movel %a1,%d1
    andiw #3,%d1
    jbeq IOPMOVEDATA_96
    subqw #4,%d1
    addw %d1,%d0
    jmp %pc@(IOPMOVEDATA_96,%d1:w:2)
    moveb %a3@,%a1@+
    moveb %a3@,%a1@+
    moveb %a3@,%a1@+
IOPMOVEDATA_96:         /* longs */
    rorl #2,%d0
    moveq #7,%d1
    andw %d0,%d1
    negw %d1
    lsrw #3,%d0
    jmp %pc@(IOPMOVEDATA_B4,%d1:w:2)
IOPMOVEDATA_A4:         /* 8 longs */
    movel %a3@,%a1@+
    movel %a3@,%a1@+
    movel %a3@,%a1@+
    movel %a3@,%a1@+
    movel %a3@,%a1@+
    movel %a3@,%a1@+
    movel %a3@,%a1@+
    movel %a3@,%a1@+
IOPMOVEDATA_B4:         /* count */
    dbf %d0,IOPMOVEDATA_A4
    addl %d0,%d0
    jbcs IOPMOVEDATA_C6
IOPMOVEDATA_BC:         /* last byte */
    jbpl IOPMOVEDATA_C0
    moveb %a3@,%a1@
IOPMOVEDATA_C0:         /* return */
    rts
IOPMOVEDATA_C2:         /* (less than 4 bytes) */
    roxrl #2,%d0
    jbcc IOPMOVEDATA_BC
IOPMOVEDATA_C6:         /* last word / byte */
    jbpl IOPMOVEDATA_CA
    moveb %a3@,%a1@+
IOPMOVEDATA_CA:         /* last word */
    movew %a3@,%a1@
    rts

IOPMOVEDATA_CE:         /* from RAM at a1 to the IOP: the same, the other way */
    cmpiw #3,%d0
    jbls IOPMOVEDATA_116
    movel %a1,%d1
    andiw #3,%d1
    jbeq IOPMOVEDATA_EA
    subqw #4,%d1
    addw %d1,%d0
    jmp %pc@(IOPMOVEDATA_EA,%d1:w:2)
    moveb %a1@+,%a3@
    moveb %a1@+,%a3@
    moveb %a1@+,%a3@
IOPMOVEDATA_EA:         /* longs */
    rorl #2,%d0
    moveq #7,%d1
    andw %d0,%d1
    negw %d1
    lsrw #3,%d0
    jmp %pc@(IOPMOVEDATA_108,%d1:w:2)
IOPMOVEDATA_F8:         /* 8 longs */
    movel %a1@+,%a3@
    movel %a1@+,%a3@
    movel %a1@+,%a3@
    movel %a1@+,%a3@
    movel %a1@+,%a3@
    movel %a1@+,%a3@
    movel %a1@+,%a3@
    movel %a1@+,%a3@
IOPMOVEDATA_108:        /* count */
    dbf %d0,IOPMOVEDATA_F8
    addl %d0,%d0
    jbcs IOPMOVEDATA_11A
IOPMOVEDATA_110:        /* last byte */
    jbpl IOPMOVEDATA_114
    moveb %a1@,%a3@
IOPMOVEDATA_114:        /* return */
    rts
IOPMOVEDATA_116:        /* (less than 4 bytes) */
    roxrl #2,%d0
    jbcc IOPMOVEDATA_110
IOPMOVEDATA_11A:        /* last word / byte */
    jbpl IOPMOVEDATA_11E
    moveb %a1@+,%a3@
IOPMOVEDATA_11E:        /* last word */
    movew %a1@,%a3@
    rts
    .long   0x0C400003, 0x63182209, 0x02410003	| 40804FF4

IOPMOVEDATA_12E:        /* compare RAM with the IOP's: result -1, 0, 1 at (a0) */
    jbeq IOPMOVEDATA_140
    subqw #4,%d1
    addw %d1,%d0
    notw %d1
IOPMOVEDATA_136:        /* leading bytes */
    moveb %a3@,%d2
    cmpb %a1@+,%d2
    dbne %d1,IOPMOVEDATA_136
    jbne IOPMOVEDATA_15C
IOPMOVEDATA_140:        /* longs */
    moveq #3,%d1
    andw %d0,%d1
    lsrw #2,%d0
    jbeq IOPMOVEDATA_158
    subqw #1,%d0
IOPMOVEDATA_14A:        /* compare longs */
    movel %a3@,%d2
    cmpl %a1@+,%d2
    dbne %d0,IOPMOVEDATA_14A
    jbra IOPMOVEDATA_158
IOPMOVEDATA_154:        /* trailing bytes */
    moveb %a3@,%d2
    cmpb %a1@+,%d2
IOPMOVEDATA_158:        /* (count) */
    dbne %d1,IOPMOVEDATA_154
IOPMOVEDATA_15C:        /* result */
    sne %a0@
    jbls IOPMOVEDATA_162
    negb %a0@
IOPMOVEDATA_162:        /* return */
    rts

/*
 IOPINTERRUPT(d0 = IOP number): IOP interrupt: through the handler vector in the
 globals (IOPINTERRUPT_A normally): for each IOP with a pending interrupt, handle the
 transmit mailboxes whose reply arrived and the receive mailboxes with a new message.
*/
IOPINTERRUPT:
    moveal 0xc28,%a0
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jmp %a0@(0xfffffffffffffffc,%za0)@(0)	| 4080503A
IOPINTERRUPT_A:         /* the IOP's globals */
    movel %a0@(0,%d0:w:4),%d1	| 40805040
    jbeq IOPINTERRUPT_38	| 40805044
    moveal %d1,%a0	| 40805046
    moveal %a0@+,%a2
    moveal %a0@+,%a3
    movew %sr,%d2
    moveb %d0,%d2
    movel %a0,%sp@-
IOPINTERRUPT_1C:        /* interrupt cause bits in the IOP's control register */
    moveal %a0@+,%a1
    moveb %a1@,%d1
    lsrb #5,%d1
    jbcs IOPINTERRUPT_6E
    lsrb #1,%d1
    jbcs IOPINTERRUPT_52
    lsrb #1,%d1
    jbcs IOPINTERRUPT_42
IOPINTERRUPT_2C:        /* done (more IOPs?) */
    movew %d2,%sr
    addql #4,%sp
    lsrl #8,%d0
    jbne IOPINTERRUPT_14A
    rts
IOPINTERRUPT_38:        /* test #0,%d0 */
    cmpiw #0,%d0	| 4080506E
    jbeq SCCIOPBYPASSINT	| 40805072
    rts	| 40805076
IOPINTERRUPT_42:        /* IOP's own interrupt handler (if any) */
    movel %a0@,%d1
    jbeq IOPINTERRUPT_2C
    movew %d2,%sr
    movel %d0,%sp@
    moveal %d1,%a0
    jsr %a0@
    movel %sp@+,%d0
    jbra IOPINTERRUPT
IOPINTERRUPT_52:        /* receive mailboxes with a new message */
    moveb #38,%a1@
    movew #513,%d1
    movew #769,%d3
    lea %pc@(IOPINTERRUPT_116),%a1
    moveb %a0@(5),%d0
    lea %a0@(28),%a0
    movew %a2@,%sp@-
    jbra IOPINTERRUPT_AA
IOPINTERRUPT_6E:        /* transmit mailboxes with a reply */
    moveb #22,%a1@
    moveq #3,%d1
    movew #513,%d3
    lea %pc@(IOPINTERRUPT_E8),%a1
    moveb %a0@(4),%d0
    lea %a0@(28),%a0
    movew %a2@,%sp@-
    jbra IOPINTERRUPT_AA
IOPINTERRUPT_88:        /* next mailbox in that state */
    lea %a0@(16),%a0
    cmpb %a3@,%d1
    dbeq %d0,IOPINTERRUPT_88
    jbne IOPINTERRUPT_B4
    movew %a2@,%d3
    moveml %d0-%d3/%a0-%a1,%sp@-
    subqw #1,%d3
    movew %d3,%a2@
    lsrw #8,%d1
    moveb %d1,%a3@
    movew %d2,%sr
    jsr %a1@
    moveml %sp@+,%d0-%d3/%a0-%a1
IOPINTERRUPT_AA:        /* (IOP address register) */
    oriw #1792,%sr
    movew %d3,%a2@
    dbf %d0,IOPINTERRUPT_88
IOPINTERRUPT_B4:        /* done */
    movew %sp@+,%a2@
    clrw %d0
    moveb %d2,%d0
IOPINTERRUPT_BA:        /* run the completion routines through a deferred task */
    moveal 0xc28,%a1
    tstb %a1@(-15)
IOPINTERRUPT_C2:        /* (already scheduled) */
    jbne IOPINTERRUPT_E0
IOPINTERRUPT_C4:        /* install the deferred task */
    tstl %a1@(-12)
    jbeq IOPINTERRUPT_E0
    st %a1@(-15)
    lea %a1@(-36),%a0
    moveml %d0/%d2/%a2,%sp@-
    jsr @(JDTInstall,%za0)@(0)	| 4080510C
    moveml %sp@+,%d0/%d2/%a2
IOPINTERRUPT_E0:        /* next */
    movew %d2,%sr
    moveal %sp@,%a0
    jbra IOPINTERRUPT_1C

IOPINTERRUPT_E8:        /* reply received: dequeue the request, copy the reply, complete it, send the next one */
    lea %a0@(8),%a1
    movel %a1@,%d1
    jbeq IOPINTERRUPT_114
    movel %a1,%sp@-
    moveal %d1,%a0
    subql #2,%a1
    jsr %pc@(trap_Dequeue)
    moveal %a0@(16),%a1
    moveq #0,%d0
    moveb %a0@(10),%d0
    jbsr IOPINTERRUPT_126
    moveal %sp@+,%a1
    movel %a1@,%d1
    jbeq IOPINTERRUPT_114
    moveal %d1,%a0
    jmp @(0x61c,%za0)@(0)	| 40805144
IOPINTERRUPT_114:       /* return */
    rts
IOPINTERRUPT_116:       /* message received: copy it to the handler's buffer */
    movel %a0@,%d1	| 4080514C
    jbeq IOPINTERRUPT_114	| 4080514E
    moveal %d1,%a0	| 40805150
    moveal %a0@(12),%a1	| 40805152
    moveq #0,%d0
    moveb %a0@(9),%d0

IOPINTERRUPT_126:       /* copy d0 bytes from the IOP */
    jbeq IOPINTERRUPT_132
    movew %d3,%d1
    lslb #5,%d1
    movew %d1,%a2@
    jbsr IOPMOVEDATA_7A
IOPINTERRUPT_132:       /* to the completion queue (or done) */
    moveal 0xc28,%a1
    lea %a1@(-14),%a1
    tstl %a0@(20)
    jbeq IOPINTERRUPT_144
    jmp %pc@(trap_Enqueue)
IOPINTERRUPT_144:       /* done flag */
    clrb %a0@(11)
    rts
IOPINTERRUPT_14A:       /* requests waiting on the mailboxes that changed */
    movel %d0,%d3
    lsrl #8,%d3
    moveal 0xc28,%a1
    lea %a1@(-14),%a1
    lea %a1@(2),%a0
    oriw #1792,%sr

IOPINTERRUPT_15E:       /* next request: this IOP and mailbox? */
    movel %a0@,%d0
    jbeq IOPINTERRUPT_192
    moveal %d0,%a0
    cmpb %a0@(6),%d2
    jbne IOPINTERRUPT_15E
    moveb %a0@(8),%d0
    tstb %a0@(7)
    jbne IOPINTERRUPT_176
    addqb #8,%d0
IOPINTERRUPT_176:       /* (mailbox bit) */
    btst %d0,%d3
    jbeq IOPINTERRUPT_15E
    jsr %pc@(trap_Dequeue)
    movel %a0,%sp@-
    jbsr IOPINTERRUPT_15E
    moveal %sp@+,%a0
    clrb %a0@(11)
    movel %a0@(20),%d0
    jbeq IOPINTERRUPT_194
    moveal %d0,%a1
    jmp %a1@
IOPINTERRUPT_192:       /* restore sr */
    movew %d2,%sr
IOPINTERRUPT_194:       /* return */
    rts
IOPINTERRUPT_196:       /* deferred task: run the queued completion routines */
    movew %sp@+,%sr
    moveal %d0,%a0
    jsr %pc@(trap_Dequeue)
    clrb %a0@(11)
    movel %a0@(20),%d0
    jbeq IOPINTERRUPT_1B0
    movel %a1,%sp@-
    moveal %d0,%a1
    jsr %a1@
    moveal %sp@+,%a1
IOPINTERRUPT_1B0:       /* next completion */
    movew %sr,%sp@-
    oriw #1792,%sr
    movel %a1@(2),%d0
    jbne IOPINTERRUPT_196
    clrb %a1@-
    movew %sp@+,%sr
    rts

/* MOVEREQHANDLER: handler of an IOP's move request (data copy for the IOP). */
MOVEREQHANDLER:
    moveal %a0,%a2
    moveal %a0@(12),%a0
    moveb %a2@(6),%a0@(1)
    jsr @(0x620,%za0)@(0x0)	| 40805204
    moveal %a2,%a0
    moveb #1,%a0@(7)
    jmp @(0x61c,%za0)@(0)	| 40805212

/*
 INITIOPMGR: allocate the IOP globals for the IOPs this machine has (SCC IOP 0xDD1
 bit 1, SWIM IOP bit 0), and register them (_IOPInfoAccess). Without IOPs, the IOP
 traps are made unimplemented.
*/
INITIOPMGR:
    moveml %d0/%a0-%a3,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #0,%d0
    btst #1,0xdd1
    jbeq INITIOPMGR_18
    addiw #168,%d0
INITIOPMGR_18:          /* SWIM IOP */
    btst #0,0xdd1
    jbeq INITIOPMGR_24
    addiw #168,%d0
INITIOPMGR_24:          /* none? */
    tstw %d0
    jbeq INITIOPMGR_86
    addiw #68,%d0
    .short  0xA71E	| 40805244 _NewPtr (flags 0x0700)
    lea %a0@(36),%a2
    movel %a2,0xc28
    movew #7,%a2@(-32)
    lea %pc@(IOPINTERRUPT_1B0),%a0
    movel %a0,%a2@(-28)
    lea %a2@(-14),%a0
    movel %a0,%a2@(-24)
    lea %pc@(IOPINTERRUPT_A),%a0
    movel %a0,%a2@(-4)
    lea %a2@(32),%a2
    btst #1,0xdd1
    jbeq INITIOPMGR_6C
    moveq #0,%d0
    moveal SCCRd,%a1
    lea %pc@(SCCIOPBYPASSINT),%a3
    jbsr INITIOPMGR_A0
INITIOPMGR_6C:          /* register the SWIM IOP */
    btst #0,0xdd1
    jbeq INITIOPMGR_7E
    moveq #1,%d0
    moveal IWM,%a1
    subal %a3,%a3
    jbsr INITIOPMGR_A0
INITIOPMGR_7E:          /* return */
    movew %sp@+,%sr
    moveml %sp@+,%d0/%a0-%a3
    rts
INITIOPMGR_86:          /* no IOP: the IOP traps (0xA086-0xA088) become unimplemented */
    lea %pc@(INITIOPMGR_96),%a1
    movew %a1@+,%d0
    .short  0xA746	| 408052A4 _GetTrapAddress (flags 0x0700)
INITIOPMGR_8E:          /* next trap */
    movew %a1@+,%d0
    jbeq INITIOPMGR_7E
    .short  0xA247	| 408052AA _SetTrapAddress (flags 0x0200)
    jbra INITIOPMGR_8E
INITIOPMGR_96:          /* the traps */
    .short  0xA89F	| 408052AE
    .long   0xA086A087, 0xA0880000	| 408052B0

INITIOPMGR_A0:          /* register an IOP: its register addresses (from the chip base a1) and interrupt handler */
    moveal %a2,%a0
    movel %a0,%sp@-
    clrw %sp@-
    movew %d0,%sp@-
    lea %a1@(-31),%a1
    movel %a1,%a0@+
    addqw #7,%a1
    movel %a1,%a0@+
    subqw #4,%a1
    movel %a1,%a0@+
    movel %a3,%a0@+
    moveal %sp,%a0
    _IOPInfoAccess
    addql #8,%sp
    lea %a2@(168),%a2
    rts

/*
 SCCIOPBYPASS: put the SCC IOP in bypass mode (the 68040 drives the SCC directly)
 unless XPRAM 0x89 asks for IOP mode: send it the bypass message and wait.
*/
SCCIOPBYPASS:
    moveml %d0/%a0-%a2,%sp@-
    movel #65673,%d0
    clrb %sp@-
    moveal %sp,%a0
    _ReadXPRam
    jbsr SCCIOPHWINIT_40
    andb %sp@+,%d0
    jbne SCCIOPBYPASS_3E
    clrl %sp@-
    clrl %sp@-
    pea %sp@(4)
    pea %pc@(SCCIOPBYPASS_44)
    movel #16974335,%sp@-
    clrl %sp@-
    clrl %sp@-
    moveal %sp,%a0
    _IOPMsgRequest
    jbne SCCIOPBYPASS_38
SCCIOPBYPASS_32:        /* wait for the reply */
    tstb %sp@(11)
    jbne SCCIOPBYPASS_32
SCCIOPBYPASS_38:        /* done */
    lea %sp@(28),%sp
    jbsr SCCIOPHWINIT_4A
SCCIOPBYPASS_3E:        /* return */
    moveml %sp@+,%d0/%a0-%a2
    rts
SCCIOPBYPASS_44:        /* the message */
    .short  0x0400, 0xFF00	| 40805320 subib #0,%d0

/*
 SCCIOPHWINIT: reset the SCC IOP and load a small 6502 program into its RAM (the table
 below), then let it run.
*/
SCCIOPHWINIT:
    moveal SCCRd,%a1
    moveb #50,%a1@(-28)
    lea %pc@(SCCIOPHWINIT_2A),%a0
    movew %a0@+,%d0
    movew %a0@+,%a1@(-31)
SCCIOPHWINIT_14:        /* copy loop */
    moveb %a0@+,%a1@(-24)
    dbf %d0,SCCIOPHWINIT_14
    moveb #54,%a1@(-28)
    lsrw #6,%d0
SCCIOPHWINIT_24:        /* delay */
    dbf %d0,SCCIOPHWINIT_24
    rts
SCCIOPHWINIT_2A:        /* count, address, the 6502 code */
    .short  0x0011, 0x7FEE	| 4080534E orib #-18,%a1@
    .short 0xA981	| 40805352 _DrawDialog
    .short  0x8D30, 0xF0A9	| 40805354 orb %d6,%a0@(ffffffffffffffa9,%sp:w)
    .short  0x238D, 0x31F0, 0x80FE, 0xEE7F	| 40805358 movel %a5,@(ffffffff80feee7f)
    rorw %d7,%d7	| 40805360
    rorw %d7,%d7	| 40805362
SCCIOPHWINIT_40:        /* remember the XPRAM byte (0xBFE)... Z clear */
    moveb %sp@(4),0xbfe
    moveq #1,%d0
    rts
SCCIOPHWINIT_4A:        /* bypass mode on: 0xBFE bit 0 */
    jbeq SCCIOPHWINIT_52
    bset #0,0xbfe
SCCIOPHWINIT_52:        /* return */
    rts
    FILL_40805378
