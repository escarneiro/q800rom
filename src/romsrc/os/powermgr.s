/*
 os/powermgr.s - OS Event Manager patches and Power Manager
 From OSEVENTMGRPATCH (0x40888000). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the Power Manager chapter of Inside
 Macintosh), not taken from Apple.

 The Power Manager runs the PowerBooks: a power management microcontroller handles
 the battery, the backlight, sleep, the clock, ADB and power to the subsystems; the
 Mac talks to it with _PMgrOp (a command byte, a count, data, then a reply), over
 VIA 2 port A with a handshake on port B (or a shift register). Its globals are at
 0xD18 (+4 sleep queue, +18 wake-up routine, +22 disk spin-down routine, +26 last
 activity, +84 state bits, +100/+104 battery and environment handlers, +262/+266
 command and reply length tables, +270 the machine's power table, +274 'SARA' while
 asleep). Sleep (_Sleep, GOTOSLEEP) asks the sleep queue procedures, saves the
 hardware state and lets the microcontroller cut the power; start-up (PWRCNTRLPATCH)
 sees 'SARA' and resumes at WAKEUP instead of booting.

 The Quadra 800 has no Power Manager (HWCfgFlags bit 8 clear): in QEMU execution
 traces only POSTEVENTPATCH, OSEVENTAVAILPATCH, the test at the start of INITPMGRVARS,
 PWRCNTRLPATCH's start-up path, BACKLIGHTPATCH and BKLIGHTINSTALL's test run here.

 Labels: many names here come from the nearest routine in Apple's ROM map, not from
 what the code is. SETSUPERVISORMODE_406 is the _PMgrOp implementation,
 RESTORE030_380 a parallel-port variant of it, other SETSUPERVISORMODE_ and RESTORE030_
 labels are sleep helpers; block comments mark where each starts. Several stretches
 are raw words or misaligned data (noted where they are). Power Manager errors:
 -13000 pmBusyErr, -13001 pmReplyTOErr, -13002 pmSendStartErr, -13003 pmSendEndErr,
 -13004 pmRecvStartErr, -13005 pmRecvEndErr.
*/

/*
 POSTEVENTPATCH: PostEvent: on Power Manager machines (0xDD5 bit 0) report user
 activity first (PowerDispatch 1: reset the idle timer).
*/
OSEVENTMGRPATCH:
POSTEVENTPATCH:         /* Power Manager machine (0xDD5 bit 0)? Not the Quadra 800 */
    btst #0,0xdd5
    jbeq OSEVENTMGRPATCH_10
    movel %d0,%sp@-
    moveq #1,%d0
    _PowerDispatch
    movel %sp@+,%d0
OSEVENTMGRPATCH_10:     /* the rest of PostEvent: d2 = SysEvtMask, d1 = the event code */
    movew SysEvtMask,%d2
    movew %a0,%d1
    rts

/* OSEVENTAVAILPATCH: the same for OSEventAvail. */
OSEVENTAVAILPATCH:
    btst #0,0xdd5
    jbeq OSEVENTAVAILPATCH_10
    movel %d0,%sp@-
    moveq #1,%d0
    _PowerDispatch
    movel %sp@+,%d0
OSEVENTAVAILPATCH_10:   /* copy the event record */
    movel %a1@+,%a0@+
    subqw #1,%d0
    jbne OSEVENTAVAILPATCH_10
    rts
    .fill   0x3D0, 1, 0x00

/*
 INITPMGRVARS: create the Power Manager globals (0xD18), install its VBL tasks (every
 second: idle and battery checks, every 10 seconds: battery monitor), the interrupt
 handlers, the sleep queue, read the settings from PRAM.
*/
POWERMNGR:
INITPMGRVARS:           /* no Power Manager (HWCfgFlags bit 8 clear, the Quadra 800): skip it */
    btst #0,HWCfgFlags
    jbne POWERMNGR_24
    lea %pc@(POWERMNGR_1A),%a1
    movew %a1@+,%d0
    .short  0xA746	| 4088840E _GetTrapAddress (flags 0x0700)
POWERMNGR_10:           /* (walk the words of POWERMNGR_1A to a zero) */
    movew %a1@+,%d0
    jbeq POWERMNGR_18
    .short  0xA247	| 40888414 _SetTrapAddress (flags 0x0200)
    jbra POWERMNGR_10
POWERMNGR_18:           /* return */
    rts
POWERMNGR_1A:           /* raw words; the set-up of the globals starts in them (a 358-byte system pointer at 0xD18), partly misaligned below */
    .short  0xA89F, 0xA085, 0xA09F	| 4088841A
    .long   0xA08A0000	| 40888420
POWERMNGR_24:           /* the globals: 0xD18, the activity times (+26, +30), the command tables (SETSUPERVISORMODE_6D2), the machine's power table (SETSUPERVISORMODE_324), the battery and environment interrupt handlers (+100, +104) */
    movel #358,%d0
    .short  0xA71E	| 4088842A _NewPtr (flags 0x0700)
    movel %a0,PmgrBase
    moveal %a0,%a3
    lea %a3@(2),%a1
    .short  0x61FF, 0xFFF8	| 40888436
    moveb %fp@-,%a2@(20715)
    .short  0x0011, 0x7001	| orib #1,%a1@
    movel %d0,%a3@(26)	/* (the three lines above are a misaligned decoding of bsrl, st %a3@(17), moveq #1,%d0) */
    movel %d0,%a3@(30)
    jbsr SETSUPERVISORMODE_6D2
    jbsr SETSUPERVISORMODE_324
    addqw #8,%a3@(40)
    moveq #-1,%d2
    movel %d2,%a3@(56)
    lea %pc@(BATINT),%a1
    movel %a1,%a3@(100)
    lea %pc@(ENVINT),%a1
    movel %a1,%a3@(104)
    movel %a3@(270),%d0
    jbeq POWERMNGR_BC
    moveal %d0,%a1
    movel %a1@(40),%d0
    jbeq POWERMNGR_8C
    addl %a1,%d0
    lea %a3@(140),%a0
    movew #60,%a0@
    movel %d0,%a0@-
    addqw #1,%a0@-
    subqw #4,%a0
    _VInstall
POWERMNGR_8C:           /* the machine's second VBL task (every 600 ticks), if any */
    movel %a1@(44),%d0
    jbeq POWERMNGR_A4
    addl %a1,%d0
    lea %a3@(154),%a0
    movew #600,%a0@
    movel %d0,%a0@-
    addqw #1,%a0@-
    subqw #4,%a0
    _VInstall
POWERMNGR_A4:           /* the third (every 120 ticks), if any */
    movel %a1@(48),%d0
    jbeq POWERMNGR_BC
    addl %a1,%d0
    lea %a3@(292),%a0
    movew #120,%a0@
    movel %d0,%a0@-
    addqw #1,%a0@-
    subqw #4,%a0
    _VInstall
POWERMNGR_BC:           /* PMGRINT is the level 1 interrupt routine at 0x1A2; read the interrupt mask (PMgrOp 0x21), set it (0x60) if the table has one */
    lea %pc@(PMGRINT),%a0
    movel %a0,0x1a2
    clrl %sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #33,%sp@-
    moveal %sp,%a0
    _PMgrOp
    movew %a3@(34),%a0@(12)
    jbeq POWERMNGR_E8
    movew #2,%a0@(2)
    movew #96,%a0@
    _PMgrOp
POWERMNGR_E8:           /* PMgrOp 0x68: the microcontroller's status byte (+15) */
    clrw %a0@(2)
    movew #104,%a0@
    _PMgrOp
    moveal %a0@(8),%a1
    moveb %a1@,%a3@(15)
    btst #0,%a3@(15)
    jbeq POWERMNGR_108
    movew %a3@(354),%a3@(356)
POWERMNGR_108:          /* the Power Manager's PRAM bytes (XPRAM at +85: 6 bytes): settings, sleep and hard disk timeouts (default 0x20, 0x10) */
    moveq #6,%d0
    swap %d0
    moveb %a3@(85),%d0
    _ReadXPRam
    moveb %a0@(5),%a3@(83)
    moveb %a3@(83),NTSC
    bclr #7,NTSC
    tstw %a0@
    jbne POWERMNGR_13C
    moveb #32,%a0@
    moveb #16,%a0@(1)
    moveq #2,%d0
    swap %d0
    moveb %a3@(85),%d0
    _WriteXPRam
POWERMNGR_13C:          /* timeouts, battery tables (+230, +234) and defaults; WAKEUP as the wake-up routine (+18), the real address of the globals (+166), the idle state (+14), GRACEFULSHUTDOWN (+350); enable the VIA interrupts */
    moveb %a0@,%a3@
    moveb %a0@(1),%a3@(1)
    lea %sp@(16),%sp
    moveal %a3@(270),%a0
    moveal %a0,%a1
    addal %a0@(12),%a0
    movel %a0,%a3@(230)
    addal %a1@(16),%a1
    movel %a1,%a3@(234)
    movew #120,%a3@(172)
    movew #3,%a3@(170)
    movew #10,%a3@(174)
    movew #900,%a3@(176)
    movew #10,%a3@(226)
    movew #192,%a3@(228)
    lea %pc@(WAKEUP),%a2
    movel %a2,%a3@(18)
    movel %a3,%d0
    _StripAddress
    moveal %d0,%a0
    bsrl GETREALPROC
    movel %a0,%a3@(166)
    movew #7,%d0
    _PowerDispatch
    moveb %d0,%a3@(14)
    biglea GRACEFULSHUTDOWN, a1
    movel %a1,%a3@(350)
    lea %pc@(RESTORE030_260),%a1
    movel %a1,%a3@(258)
    moveal VIA,%a1
    moveb #0x90,%a1@(6656)
    jbsr SETSUPERVISORMODE_380
    moveb #0x90,%a1@(7168)
    rts
    .short  0x0000	| 408885D0

POWERMNGR_1D2:          /* PMgrOp(d0 = command, d1 = 0 bytes, a0 = reply buffer) */
    moveq #0,%d1

POWERMNGR_1D4:          /* PMgrOp(d0 = command, d1 = byte count, a0 = data): a parameter block on the stack; d1 = the reply count */
    movel %a0,%sp@-
    movel %a0,%sp@-
    movew %d1,%sp@-
    movew %d0,%sp@-
    moveal %sp,%a0
    _PMgrOp
    movew %sp@(2),%d1
    lea %sp@(8),%sp
    moveal %sp@+,%a0
    rts

/*
 PMGRINT: Power Manager interrupt: read what the microcontroller reports (ADB data,
 battery, environment change) and dispatch it.
*/
PMGRINT:
    moveb #0x90,%a1@(6656)
    subaw #12,%sp
    moveal %sp,%a0
    addql #2,%a0
    moveq #120,%d0
    jbsr POWERMNGR_1D2
    tstw %d0
    jbne PMGRINT_58
    moveb %a0@,%d0
    lsrb #4,%d0
    btst #0,%d0
    jbne PMGRINT_40
    btst #1,%d0
    jbne PMGRINT_36
    jbsr SETSUPERVISORMODE_B38
    jbeq PMGRINT_58
    moveal PmgrBase,%a2
    movel %a2@(104),%d0
    jbra PMGRINT_52
PMGRINT_36:             /* battery interrupt: the handler at +100 (BATINT) */
    moveal PmgrBase,%a2
    movel %a2@(100),%d0
    jbra PMGRINT_52
PMGRINT_40:             /* ADB data from the microcontroller: on to the ADB interrupt routine (Lvl1DT+8) with the bytes in ADB's form */
    andib #15,%a0@
    moveb %a0@(1),%a0@-
    subqb #2,%d1
    moveb %d1,%a0@(2)
    movel Lvl1DT_2,%d0
PMGRINT_52:             /* call it */
    jbeq PMGRINT_58
    moveal %d0,%a1
    jsr %a1@
PMGRINT_58:             /* return */
    lea %sp@(12),%sp
    rts
    .short  0x4E71	| 4088864A

/* BATINT: battery interrupt: low battery warnings. */
BATINT:
    moveq #0,%d2
    moveb %a0@(1),%d2
    moveb %d2,%a2@(15)
    btst #5,%d2
    jbeq BATINT_14
    jbsr ENVINT_50
BATINT_14:              /* bit 2: the battery is low: warn (ENVINT_5E) */
    btst #2,%d2
    jbeq BATINT_1E
    jbsr ENVINT_5E
BATINT_1E:              /* return */
    rts
    .fill   0x5C, 1, 0x00

/*
 BATWATCH: VBL task: battery level check, warnings (notifications) and the forced
 sleep when it is too low.
*/
BATWATCH:
    moveal PmgrBase,%a2
    tstb %a2@(12)
    bnes BATWATCH_16
    lea %a2@(130),%a0
    movew #60,%a0@(10)
    rts
BATWATCH_16:
    bsrw GETLEVEL
    bnes BATWATCH_24
    moveb #0xff,%a2@(13)	| 408886E4
    bras BATWATCH_60
BATWATCH_24:
    tstb %d0
    bpls BATWATCH_30
    bsrs BATWATCH_94
    moveb %d0,%a2@(13)
    bras BATWATCH_60
BATWATCH_30:
    beqs BATWATCH_54
    cmpib #2,%d0
    bnes BATWATCH_3A
    moveq #1,%d0
BATWATCH_3A:
    tstb %a2@(13)
    bmis BATWATCH_46
    cmpb %a2@(13),%d0
    blss BATWATCH_54
BATWATCH_46:
    bsrs BATWATCH_94
    bsrs BATWATCH_B0_2
    clrb %a2@(109)
    moveb %d0,%a2@(13)
    bras BATWATCH_60
BATWATCH_54:
    cmpib #4,%a2@(13)
    bnes BATWATCH_60
    addqb #1,%a2@(109)
BATWATCH_60:
    lea %a2@(130),%a0
    movew #60,%a0@(10)
    braw SETSUPERVISORMODE_B4C_6
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40888736
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40888746
    .short  0x0000, 0x0000, 0x0000	| 40888756

BATWATCH_94:            /* remove the low-battery notification if it is posted and no longer needed */
    tstb %a2@(80)
    jbeq BATWATCH_B0
    btst #3,%a2@(84)
    jbne BATWATCH_B0
    movel %d0,%sp@-
    lea %a2@(36),%a0
    _NMRemove
    movel %sp@+,%d0
    clrb %a2@(80)
BATWATCH_B0:            /* return */
    rts
BATWATCH_B0_2:
    btst #3,%a2@(84)	| 4088877A
    jbne BATWATCH_E8	| 40888780
    movel %d0,%sp@-	| 40888782
    lea %a2@(36),%a0	| 40888784
    lea %pc@(BATWATCH_E8),%a1	| 40888788
    movel %a1,%a0@(28)	| 4088878C
    movel %a2@(110),%a0@(16)	| 40888790
    movew %d0,%d2	| 40888796
    subqw #1,%d2	| 40888798
    lslw #2,%d2	| 4088879A
    movel %a2@(0x72,%d2:w),%a0@(24)	| 4088879C
    tstl %a0@(24)	| 408887A2
    jbeq BATWATCH_E6	| 408887A6
    _NMInstall	| 408887A8
    st %a2@(80)	| 408887AA
BATWATCH_E6:            /* post a notification with the battery warning string */
    movel %sp@+,%d0	| 408887AE
BATWATCH_E8:            /* return */
    rts	| 408887B0

/* GETLEVEL: the battery level (and charger state) from the microcontroller. */
GETLEVEL:
    movel %a2@(270),%d0
    jbeq GETLEVEL_E
    moveal %d0,%a0
    addal %a0@(32),%a0
    jmp %a0@
GETLEVEL_E:             /* no power table: return */
    rts
    swap %d0
    moveb %a2@(85),%d0
    rts
    .fill   0xEA, 1, 0x00
GETLEVEL_E_F4:
    .long   0x062E004E, 0x00700092, 0x0366037A	| 408888B4
    .long   0x039803B0, 0x03C603D2, 0x18C60F9C, 0x00000000	| 408888C0
    .long   0x00000000, 0x00000000	| 408888D0

/* _PowerDispatch(d0 = selector): idle control, activity, sleep settings, scaled clock. */
POWERDISPATCH:
    cmpiw #11,%d0
    bhis POWERDISPATCH_E
    movew %pc@(GETLEVEL_E_F4,%d0:w:2),%d0
    jmp %pc@(GETLEVEL_E_F4,%d0:w)
POWERDISPATCH_E:
    movew #-50,%d0
    rts

/*
 _PMgrOp(a0 = command block): send a command and its data to the power management
 microcontroller and read the reply (VIA handshake), interrupts masked meanwhile.
*/
PMGROP:
    andiw #1536,%d1
    beqw RESTORE030_2F0_5A
    cmpiw #1024,%d1
    beqw RESTORE030_7A
    bcss PMGROP_16
    braw RESTORE030_102_24	| 408888FE
PMGROP_16:
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal PmgrBase,%a1
    movel %a1@(26),%d0
    cmpl Ticks,%d0
    jbhi PMGROP_30
    movel Ticks,%a1@(26)
PMGROP_30:              /* (the rest of PMgrOp's entry: the last activity time, +26, at least Ticks) */
    movel %a1@(26),%d0
    movew %sp@+,%sr
    rts
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal PmgrBase,%a1
    moveq #0,%d0
    movew %a1@(176),%d0
    addl Ticks,%d0
    cmpl %a1@(26),%d0
    bles PMGROP_30_26
    movel %d0,%a1@(26)
PMGROP_30_26:
    movew %sp@+,%sr
    rts

/*
 IDLEMIND: idle handling: slow the CPU clock (idle state) when there has been no
 activity, sleep after the user's timeout.
*/
IDLEMIND:
    moveml %d0-%d2/%a0-%a2,%sp@-
    moveal PmgrBase,%a2
    movel %a2@(270),%d0
    beqw IDLEMIND_84
    moveal %d0,%a0
    moveal %a0@(8),%a1
    lea %a0@(0x0,%a1:l),%a1
    st %a2@(12)
    moveal %a1@,%a0
    jsr %a1@(0x0,%a0:l)
    jbne IDLEMIND_68
    tstb %a2@(17)
    jbne IDLEMIND_84
    moveal %a1@(4),%a0
    jsr %a1@(0x0,%a0:l)
    movel %a2@(26),%d0
    cmpl Ticks,%d0
    jbgt IDLEMIND_84
    moveal %a1@(8),%a0
    jsr %a1@(0x0,%a0:l)
    jbne IDLEMIND_64
    moveal %a1@(12),%a0
    jsr %a1@(0x0,%a0:l)
    jbeq IDLEMIND_80
    moveal %a1@(16),%a0
    jsr %a1@(0x0,%a0:l)
    moveal %a1@(20),%a0
    jsr %a1@(0x0,%a0:l)
    jbra IDLEMIND_84
IDLEMIND_64:            /* the machine wants to sleep: 1 (sleep request) */
    moveq #1,%d0
    jbra IDLEMIND_6A
IDLEMIND_68:            /* battery too low: 6 (sleep now) */
    moveq #6,%d0
IDLEMIND_6A:            /* _Sleep, unless docked (+249 bit 0) */
    btst #0,%a2@(249)
    jbne IDLEMIND_74
    _Sleep
IDLEMIND_74:            /* activity time = now */
    bclr #0,%a2@(297)
    movel Ticks,%a2@(26)
IDLEMIND_80:            /* clear the idle counter (+178) */
    clrl %a2@(178)
IDLEMIND_84:            /* restore registers, return */
    moveml %sp@+,%d0-%d2/%a0-%a2
    rts
    .fill   0xCC, 1, 0x00

/*
 POWERCYCLE030: power cycling of the 68030 PowerBooks: stop the CPU clock until the
 next interrupt.
*/
POWERCYCLE030:
    movew %sr,%sp@-
    oriw #1792,%sr
    moveml %d1-%fp,%sp@-
    movec %cacr,%d0
    oriw #2056,%d0
    .short  0x4E7A, 0x1802	| 40888AAE movec %caar,%d1
    movec %vbr,%a0
    movel %usp,%a1
    movec %msp,%a2
    moveml %d0-%d1/%a0-%a2,%sp@-
    moveq #0,%d0
    movec %d0,%vbr
    moveal PmgrBase,%a1
    moveal %a1@(158),%a2
    movel %a1@(234),ResetVector
    movel %sp,%a1@(196)
    .short  0xF029, 0x4200, 0x00CE	| pmove %tc,%a1@(206)
    .short  0xF029, 0x4E00, 0x00D2	| pmove %crp,%a1@(210)
    .short  0xF029	| .short 0xf029
    .short  0x0E00	| .short 0x0e00
    .short  0x00DA, 0xF029, 0x0A00, 0x00DE, 0x2669, 0x00A6, 0x47EB, 0x00C2	| 40888AE8
    .short  0x21CB, 0x0000, 0x21E9, 0x00EA, 0x007C, 0x2678, 0x01D8, 0x0813	| 40888AF8
    .short  0x0000, 0x660A, 0x2180, 0x81E1, 0x02AE, 0x2480	| 40888B08
POWERCYCLE030_78:       /* (wait here for the interrupt that wakes the CPU) */
    jbra POWERCYCLE030_78
    movec %a0,%vbr
    movel %a1@(202),0x7c
    addaw #20,%sp
    moveml %sp@+,%d1-%fp
    movew %sp@+,%sr
    rts
    movew %sr,%sp@-
    oriw #1792,%sr
    moveml %d1-%fp,%sp@-
    movec %cacr,%d0
    oriw #2056,%d0
    .short  0x4E7A, 0x1802	| 40888B3E movec %caar,%d1
    movec %vbr,%a0
    movel %usp,%a1
    movec %msp,%a2
    moveml %d0-%d1/%a0-%a2,%sp@-
    moveq #0,%d0
    movec %d0,%vbr
    moveal PmgrBase,%a1
    moveal %a1@(158),%a2
    movel %a1@(234),ResetVector
    movel %sp,ResetStackPtr
    movel %a1@(234),0x7c
    moveal SCCRd,%a3
    btst #0,%a3@
    bnes POWERCYCLE030_78_6E
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    movel %d0,@(ROMBase,%za0)@(0)	| 40888B78
    movel %d0,%a2@
POWERCYCLE030_78_6C:
    bras POWERCYCLE030_78_6C
POWERCYCLE030_78_6E:
    movec %a0,%vbr
    movel %a1@(202),0x7c
    addaw #20,%sp
    moveml %sp@+,%d1-%fp
    movew %sp@+,%sr
    rts

/* RESTORE030: after power cycling: restore the state. */
RESTORE030:
    oriw #1792,%sr
    moveal ResetStackPtr,%a0
    moveal %a0@(2),%sp
    .short  0xF028	| .short 0xf028
    btst #28,%d0
    .short  0xF028	| .short 0xf028
    cmpib #24,%d0
    .short  0xF028, 0x4C00, 0x0010	| 40888BB0 pmove %a0@(16),%crp
    .short  0xF028, 0x4000, 0x000C	| 40888BB6 pmove %a0@(12),%tc
    moveml %sp@+,%d0-%d1/%a0-%a2
    movec %d0,%cacr
    .short  0x4E7B, 0x1802	| 40888BC4 movec %d1,%caar
    movec %a0,%vbr
    movec %a1,%usp
    movec %a2,%msp
    moveal PmgrBase,%a0
    movel %a0@(202),0x7c
    moveml %sp@+,%d1-%fp
    movew %sp@+,%sr
    rts
    oriw #1792,%sr
    moveml %sp@+,%d0-%d1/%a0-%a2
    movec %d0,%cacr
    .short  0x4E7B, 0x1802	| 40888BF2 movec %d1,%caar
    movec %a0,%vbr
    movel %a1,%usp
    movec %a2,%msp
    moveal PmgrBase,%a0
    movel %a0@(202),0x7c
    moveml %sp@+,%d1-%fp
    movew %sp@+,%sr
    rts
RESTORE030_7A:
    tstl %d0
    bmis RESTORE030_82
    beqs RESTORE030_96
    bras RESTORE030_B4
RESTORE030_82:
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal PmgrBase,%a0
    moveq #0,%d0
    moveb %a0@(14),%d0
    movew %sp@+,%sr
    rts
RESTORE030_96:
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #0,%d0
    moveal PmgrBase,%a0
    subqb #1,%a0@(81)
    bpls RESTORE030_AC
    clrb %a0@(81)
RESTORE030_AC:
    moveb %a0@(81),%d0
    movew %sp@+,%sr
    rts
RESTORE030_B4:
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #0,%d0
    moveal PmgrBase,%a0
    addqb #1,%a0@(81)
    moveb %a0@(81),%d0
    movew %sp@+,%sr
    rts
    moveal PmgrBase,%a2
    movel %a2@(270),%d0
    beqs RESTORE030_E0
    moveal %d0,%a0
    moveal %a0@(4),%a1
    jmp %a0@(0x0,%a1:l)
RESTORE030_E0:
    rts
    moveal PmgrBase,%a2
    moveq #0,%d0
    moveb %a2@(85),%d0
    rts
    moveal PmgrBase,%a2
    movel %a2@(270),%d0
    beqs RESTORE030_102
    moveal %d0,%a0
    moveal %a0@(36),%a1
    jmp %a0@(0x0,%a1:l)
RESTORE030_102:
    rts
    /* d0 for _ReadXPRam: one byte at address 2 plus the offset in PmgrBase +0x55 */
    movel #65538,%d0
    addb @(PmgrBase,%za0)@(0x55),%d0	| 40888CA2
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40888CAC
    .byte   0x00, 0x00	| 40888CBC
RESTORE030_102_24:      /* bit 7 of d0 set: RESTORE030_1BC. Otherwise a0 = a Power Manager command block on the stack */
    bclr #7,%d0	| 40888CBE
    bnew RESTORE030_1BC
    moveml %d0-%d1/%a0-%a2,%sp@-
    subaw #16,%sp
    lea %sp@(12),%a0
    movel %a0,%sp@(8)
    movel %a0,%sp@(4)
    moveal %sp,%a0
    bclr #0,%d0
    bnew RESTORE030_102_9E
    tstb %d0
    beqw RESTORE030_102_9E
    /* Power Manager command 88; bit 3 of the reply clear: _9E */
    movew #88,%a0@
    clrw %a0@(2)
    _PMgrOp
    moveb %a0@(12),%d1
    btst #3,%d1
    beqw RESTORE030_102_9E
    /* parameter RAM bit 2 set: _9E */
    movel #65538,%d0
    addb @(PmgrBase,%za0)@(0x55),%d0
    _ReadXPRam
    btst #2,%a0@
    bnew RESTORE030_102_9E
    /* a hook from the table at PmgrBase +270 (entry +52, code offset at +2); a nonzero result ends here */
    moveal PmgrBase,%a2
    movel %a2@(270),%d0
    beqs RESTORE030_102_9E
    moveal %d0,%a2
    movel %a2@(52),%d0
    beqs RESTORE030_102_9E
    lea %a2@(0x0,%d0:l),%a2
    movel %a2@(2),%d0
    jsr %a2@(0x0,%d0:l)
    bnes RESTORE030_102_B0
RESTORE030_102_9E:      /* Power Manager command 16 with the byte 0x92 */
    moveb #0x92,%a0@(12)	| 40888D38
    movew #1,%a0@(2)
    movew #16,%a0@
    _PMgrOp
RESTORE030_102_B0:
    lea %sp@(16),%sp	| 40888D4A
    moveml %sp@+,%d0-%d1/%a0-%a2
    rts

RESTORE030_1BC:         /* (a sleep queue procedure: on a sleep request/demand turn off the serial port or modem power, PMgrOp 0x58 status, 0x10 power control) */
    moveml %d0-%d3/%a0-%a2,%sp@-
    subaw #16,%sp
    lea %sp@(12),%a0
    movel %a0,%sp@(8)
    movel %a0,%sp@(4)
    moveal %sp,%a0
    movel %d0,%d2
    bclr #0,%d2
    bnew RESTORE030_21A
    btst #2,%d2
    jbeq RESTORE030_21A
    movew #88,%a0@
    clrw %a0@(2)
    _PMgrOp
    moveb %a0@(12),%d1
    andib #7,%d1
    btst #0,%d1
    jbeq RESTORE030_21A
    moveal PmgrBase,%a2
    movel %a2@(270),%d0
    jbeq RESTORE030_21A
    moveal %d0,%a2
    movel %a2@(52),%d0
    jbeq RESTORE030_21A
    lea %a2@(0x0,%d0:l),%a2
    movel %a2@(6),%d0
    jsr %a2@(0x0,%d0:l)
    jbne RESTORE030_23E
RESTORE030_21A:         /* the port's use (PortAUse) */
    moveb PortAUse,%d0
    btst #2,%d2
    jbeq RESTORE030_226
    jbsr RESTORE030_248
RESTORE030_226:         /* free: power the port off (PMgrOp 0x10, 0x12) */
    cmpib #0xff,%d0
    jbne RESTORE030_23E
    moveb #18,%a0@(12)
    movew #1,%a0@(2)
    movew #16,%a0@
    _PMgrOp
RESTORE030_23E:         /* return */
    lea %sp@(16),%sp
    moveml %sp@+,%d0-%d3/%a0-%a2
    rts

RESTORE030_248:         /* ask AppleTalk (ATalkHk2, selector 19) whether the port is in use */
    moveml %d1/%a0,%sp@-
    moveal ATalkHk2,%a0
    movew #19,%d0
    jsr %a0@(2)
    moveb %d1,%d0
    moveml %sp@+,%d1/%a0
    rts
RESTORE030_260:         /* the sound volume hook (0x19E): before sleep, call the sound routines at +36 and +24 with the volume */
    .short  0x11BC, 0x0008, 0x81E2, 0x01D4, 0x1A00	| moveb #8,@(0x1d4)@(0x1a00)
    moveb SdVolume,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 40888E08
    tstl %a0@(36)
    jbeq RESTORE030_284
    moveal %a0@(36),%a0
    jsr %a0@
RESTORE030_284:         /* the second one */
    moveal %sp@+,%a0
    moveq #2,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 40888E22
    tstl %a0@(24)
    jbeq RESTORE030_29E
    moveal %a0@(24),%a0
    jsr %a0@
RESTORE030_29E:         /* next time RESTORE030_2B4 */
    moveal %sp@+,%a0
    bclr #6,@(VIA,%za0)@(0x1800)	| 40888E38
    lea %pc@(RESTORE030_2B4),%a0
    movel %a0,0x19e
    rts
RESTORE030_2B4:         /* after sleep: the same with 0 */
    .short  0x11BC, 0x0008, 0x81E2, 0x01D4, 0x1A00	| moveb #8,@(0x1d4)@(0x1a00)
    moveq #0,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 40888E5A
    tstl %a0@(36)
    jbeq RESTORE030_2D6
    moveal %a0@(36),%a0
    jsr %a0@
RESTORE030_2D6:         /* the second one */
    moveal %sp@+,%a0
    moveq #0,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 40888E74
    tstl %a0@(24)
    jbeq RESTORE030_2F0
    moveal %a0@(24),%a0
    jsr %a0@
RESTORE030_2F0:         /* next time RESTORE030_260 */
    moveal %sp@+,%a0
    bset #6,@(VIA,%za0)@(0x1800)	| 40888E8A
    lea %pc@(RESTORE030_260),%a0
    movel %a0,0x19e
    rts
    .fill   0x44, 1, 0x00
RESTORE030_2F0_5A:      /* supervisor mode; SR kept in d5; bit 4 of the VIA1 interrupt enable turned off, its old state saved; a3 = 48 bytes on the stack, d3 = 7 retries */
    bsrw SETSUPERVISORMODE_BDE+0x2	| 40888EE2
    movew %sr,%d5
    moveal VIA,%a1
    moveal ghost_VIA2,%a4
    lea %a1@(7680),%a5
    moveb %a1@(7168),%d1
    moveb %d1,%sp@-
    andib #16,%d1
    moveb #16,%a1@(7168)
    subql #2,%sp
    moveal PmgrBase,%a2
    subaw #48,%sp
    moveal %sp,%a3
    moveal SCCRd,%fp
    addql #6,%fp
    moveq #7,%d3
/*
 The parallel _PMgrOp transport (a4 = the VIA whose port A carries the data, d3 =
 retries): wait until the microcontroller is ready (port B bit 1), send the command,
 the count and the data bytes, then read the reply (command flag bit 3) with the
 handshake on port B bits 1 (acknowledge, in) and 2 (request, out). While it waits
 it runs the serial poll procedure (PollProc). Errors -13000 (pmBusyErr), -13001
 (pmReplyTOErr), -13002/-13003 (pmSendStartErr/pmSendEndErr), -13004/-13005
 (pmRecvStartErr/pmRecvEndErr).
*/
RESTORE030_380:         /* loop: clr */
    clrb %a4@(1536)
    movew TimeVIADB,%d2
RESTORE030_388:         /* wait for the microcontroller (port B bit 1) */
    btst #1,%a4@
    dbne %d2,RESTORE030_388
    jbne RESTORE030_39C
    movel #-13000,%d0
    jbra RESTORE030_468
RESTORE030_39C:         /* ready */
    jbra ENVINT_28

RESTORE030_3A0:         /* send the command byte; the microcontroller busy: poll the serial port, retry */
    moveb %a1@(1536),%d6
    bclr #7,%a1@(1536)
    lea %a0@(1),%a2
    movew TimeVIADB,%d2
    lslw #3,%d2
    jbsr RESTORE030_4BC
    jbeq RESTORE030_3F4
    movel %a3,PollStack
    cmpal PollStack,%sp
    jbeq RESTORE030_3E2
    movel %a3,%d7
    moveml %d0-%d6/%a0-%a4,%a3@
    movel PollProc,%d2
    jbeq RESTORE030_3DC
    nop
    nop
    pea %pc@(RESTORE030_3DC)
    movel %d2,%sp@-
    rts
RESTORE030_3DC:         /* back from the poll procedure */
    moveal %d7,%a3
    moveml %a3@,%d0-%d6/%a0-%a4
RESTORE030_3E2:         /* wait a little, retry */
    moveq #64,%d2
    moveb %d6,%a1@(1536)
RESTORE030_3E8:         /* (delay with interrupts back) */
    movew %d5,%sr
    dbf %d2,RESTORE030_3E8
    dbf %d3,RESTORE030_380
    jbra RESTORE030_468
RESTORE030_3F4:         /* send the count, then the data bytes */
    moveq #0,%d1
    lea %a0@(3),%a2
    moveb %a2@,%d1
    jbsr RESTORE030_4B8
    jbne RESTORE030_468
    subqw #1,%d1
    jbmi RESTORE030_414
    moveal %a0@(4),%a2
RESTORE030_40A:         /* next byte */
    jbsr RESTORE030_4B8
    jbne RESTORE030_468
    dbf %d1,RESTORE030_40A
RESTORE030_414:         /* a reply expected (command bit 3)? wait for it */
    moveb %a0@(1),%d0
    btst #3,%d0
    jbeq RESTORE030_466
    moveal %a0,%a2
    addql #1,%a2
    movew TimeVIADB,%d2
RESTORE030_426:         /* wait for the microcontroller to start answering */
    btst #1,%a4@
    jbeq RESTORE030_440
    moveb %a5@,%a5@
    jbmi RESTORE030_434
    nop
    moveb %fp@,%sp@-
RESTORE030_434:         /* timeout: -13001 (pmReplyTOErr) */
    dbf %d2,RESTORE030_426
    movel #-13001,%d0
    jbra RESTORE030_468
RESTORE030_440:         /* read the reply command and count, then the data */
    clrl %a0@
    jbsr RESTORE030_514
    jbne RESTORE030_468
    addql #1,%a2
    jbsr RESTORE030_514
    jbne RESTORE030_468
    movew %a0@(2),%d1
    moveal %a0@(8),%a2
    subqw #1,%d1
    jbmi RESTORE030_466
RESTORE030_45C:         /* next byte */
    jbsr RESTORE030_514
    jbne RESTORE030_468
    dbf %d1,RESTORE030_45C
RESTORE030_466:         /* no error */
    moveq #0,%d0

RESTORE030_468:         /* done: port A input, the poll procedure, restore the interrupt state and registers */
    clrb %a4@(1536)
    movel %d0,%d4
    movel %a3,PollStack
    cmpal PollStack,%sp
    jbeq RESTORE030_48A
    movel PollProc,%d2
    jbeq RESTORE030_48A
    nop
    nop
    pea %pc@(RESTORE030_48A)
    movel %d2,%sp@-
    rts
RESTORE030_48A:         /* restore */
    moveal PollStack,%sp
    addaw #48,%sp
    movel %d4,%d0
    moveal VIA,%a1
    moveb %d6,%a1@(1536)
    moveal PmgrBase,%a2
    cmpaw #-1,%a2
    nop
    addql #2,%sp
    moveb %sp@+,%d4
    moveb %d4,%a1@(7168)
    movew %d5,%sr
    moveml %sp@+,%d1-%d6/%a0-%fp
    tstw %d0
    rts

RESTORE030_4B8:         /* send one byte (1024 tries) */
    movew #1024,%d2

RESTORE030_4BC:         /* port A output, the byte, request low; wait for acknowledge */
    moveq #0,%d0
    movel %sp@+,%d4
    moveb #0xff,%a4@(1536)
    moveb %a2@+,%a4@(512)
    bclr #2,%a4@
RESTORE030_4CE:         /* acknowledge? (polling the serial port meanwhile) */
    btst #1,%a4@
    jbeq RESTORE030_4E8
    moveb %a5@,%a5@
    jbmi RESTORE030_4DC
    nop
    moveb %fp@,%sp@-
RESTORE030_4DC:         /* timeout: -13002 (pmSendStartErr) */
    dbf %d2,RESTORE030_4CE
    movel #-13002,%d0
    jbra RESTORE030_506
RESTORE030_4E8:         /* request high; wait for acknowledge to go */
    moveq #64,%d2
    bset #2,%a4@
RESTORE030_4EE:         /* released? */
    btst #1,%a4@
    jbne RESTORE030_506
    moveb %a5@,%a5@
    jbmi RESTORE030_4FC
    nop
    moveb %fp@,%sp@-
RESTORE030_4FC:         /* timeout: -13003 (pmSendEndErr) */
    dbf %d2,RESTORE030_4EE
    movel #-13003,%d0
RESTORE030_506:         /* request high, port A input, return (d0 tested) */
    bset #2,%a4@
    clrb %a4@(1536)
    movel %d4,%sp@-
    tstl %d0
    rts

RESTORE030_514:         /* read one byte: port A input, wait for acknowledge */
    moveq #0,%d0
    movel %sp@+,%d4
    clrb %a4@(1536)
    moveq #64,%d2
RESTORE030_51E:         /* acknowledge? */
    btst #1,%a4@
    jbeq RESTORE030_538
    moveb %a5@,%a5@
    jbmi RESTORE030_52C
    nop
    moveb %fp@,%sp@-
RESTORE030_52C:         /* timeout: -13004 (pmRecvStartErr) */
    dbf %d2,RESTORE030_51E
    movel #-13004,%d0
    jbra RESTORE030_506
RESTORE030_538:         /* request low, read the byte; wait for acknowledge to go */
    moveq #64,%d2
    bclr #2,%a4@
    moveb %a4@(512),%a2@+
RESTORE030_542:         /* released? */
    btst #1,%a4@
    jbne RESTORE030_506
    moveb %a5@,%a5@
    jbmi RESTORE030_550
    nop
    moveb %fp@,%sp@-
RESTORE030_550:         /* timeout: -13005 (pmRecvEndErr) */
    dbf %d2,RESTORE030_542
    movel #-13005,%d0
    jbra RESTORE030_506

/*
 GOTOSLEEP: _Sleep(d0): sleep request, demand, wake-up or sleep now: ask the sleep queue
 procedures, save the hardware state (VIA, SCC, sound, video, MMU), tell the
 microcontroller to sleep; on wake-up restore everything.
*/
GOTOSLEEP:
    btst #9,%d1
    bnew SETSUPERVISORMODE_2BE_34_6
    btst #10,%d1
    bnew SETSUPERVISORMODE_2BE_4E_4
    moveal PmgrBase,%a0
    bset #0,%a0@(84)
    bnes GOTOSLEEP_2E
    movel %d0,%d1
    bsrw SETSUPERVISORMODE
    movew %d0,%a0@(200)
    movel %d1,%d0
    bsrs GOTOSLEEP_30
    movew %a0@(200),%sr
GOTOSLEEP_2E:
    rts

GOTOSLEEP_30:           /* d2 = the sleep message; docked machines ask the dock (DOCKINGSLEEPDENIED) */
    moveml %d1-%fp,%sp@-
    movel %d0,%d2
    btst #0,%a0@(249)
    jbeq GOTOSLEEP_48
    jbsr DOCKINGSLEEPDENIED
    jbeq GOTOSLEEP_A0
    jbra GOTOSLEEP_AA
GOTOSLEEP_48:           /* 1 request, 2 demand, 6 now: sleep; else just tell the queue */
    cmpib #1,%d0
    jbeq GOTOSLEEP_5A
    cmpib #2,%d0
    jbeq GOTOSLEEP_5A
    cmpib #6,%d0
    jbne GOTOSLEEP_A0
GOTOSLEEP_5A:           /* interrupts as saved (+200); a sleep already under way? the machine's own check (+96) or the AppleTalk check (SETSUPERVISORMODE_14) */
    movew %a0@(200),%sr
    bclr #1,%a0@(84)
    jbne GOTOSLEEP_7A
    movel %a0@(96),%d1
    jbeq GOTOSLEEP_74
    moveal %d1,%a1
    jsr %a1@
    jbne GOTOSLEEP_A0
    jbra GOTOSLEEP_7A
GOTOSLEEP_74:           /* may AppleTalk be closed? */
    jbsr SETSUPERVISORMODE_14
    jbne GOTOSLEEP_A0
GOTOSLEEP_7A:           /* "now" is a demand */
    movew %d2,%d0
    cmpiw #6,%d0
    jbne GOTOSLEEP_84
    moveq #2,%d0
GOTOSLEEP_84:           /* ask the sleep queue procedures (SETSUPERVISORMODE_1C0); refused: no sleep */
    jbsr SETSUPERVISORMODE_1C0
    movel %d0,%d1
    jbsr SETSUPERVISORMODE
    tstl %d1
    bnew GOTOSLEEP_A0
    jbsr SETSUPERVISORMODE_10A
    bclr #0,%a0@(84)
    jbra GOTOSLEEP_B2
GOTOSLEEP_A0:           /* no sleep: back to user mode */
    jbsr SETSUPERVISORMODE
    bclr #0,%a0@(84)
GOTOSLEEP_AA:           /* return d0 = the message */
    movew %d2,%d0
    moveml %sp@+,%d1-%fp
    rts
GOTOSLEEP_B2:           /* sleeping: hide the cursor, spin the disk down (+22), the machine's routine (+250) */
    moveal PmgrBase,%a2
    jbsr SETSUPERVISORMODE_3A6
    btst #2,%a2@(84)
    jbeq GOTOSLEEP_CC
    movel %a2@(22),%d0
    jbeq GOTOSLEEP_CC
    moveal %d0,%a0
    jsr %a0@
GOTOSLEEP_CC:           /* interrupts off */
    movel %a2@(250),%d0
    jbeq GOTOSLEEP_D6
    moveal %d0,%a0
    jsr %a0@
GOTOSLEEP_D6:           /* wait until the microcontroller has no pending interrupt */
    bclr #0,%a2@(296)
    oriw #1792,%sr
    lea %sp@(-4),%sp
GOTOSLEEP_E4:           /* PMgrOp 0x58: still busy? */
    moveal %sp,%a0
    moveq #88,%d0
    jbsr POWERMNGR_1D2
    moveb %a0@,%d0
    btst #2,%d0
    jbeq GOTOSLEEP_FA
    btst #4,%d0
    jbne GOTOSLEEP_E4
GOTOSLEEP_FA:           /* run the machine's sleep routines (power table +20: a list of offsets) */
    addqw #4,%sp
GOTOSLEEP_FA_2:
    moveal %a2@(166),%a3
    movel %a2@(270),%d0
    jbeq GOTOSLEEP_11C
    moveal %d0,%a4
    addal %a4@(20),%a4
    lea %pc@(GOTOSLEEP_116),%a1
    jbra GOTOSLEEP_116
GOTOSLEEP_112:          /* the next routine */
    addal %d0,%a0
    jmp %a0@
GOTOSLEEP_116:          /* until a zero offset */
    moveal %a4,%a0
    movel %a4@+,%d0
    jbne GOTOSLEEP_112
GOTOSLEEP_11C:          /* (wait for the power to go off) */
    jbra GOTOSLEEP_11C
    .fill   0xEA, 1, 0x00

/* WAKEUP: wake-up path: restore the saved state, tell the sleep queue procedures. */
WAKEUP:
    oriw #1792,%sr
    movew %a2@(194),%d0
    .short  0x671C, 0x2E6A, 0x00C4, 0xF02A, 0x0800, 0x00DE, 0xF02A, 0x0C00	| 40889304
    .short  0x00DA, 0xF02A, 0x4C00, 0x00D2	| 40889314
    .short  0xF02A, 0x4000, 0x00CE	| pmove %a2@(206),%tc
    movel %a2@(270),%d0
    beqs WAKEUP_42
    moveal %d0,%a4
    addal %a4@(24),%a4
    lea %pc@(WAKEUP_3C),%a1
    bras WAKEUP_3C
WAKEUP_38:
    addal %d0,%a0
    jmp %a0@
WAKEUP_3C:
    moveal %a4,%a0
    movel %a4@+,%d0
    bnes WAKEUP_38
WAKEUP_42:
    moveal VIA,%a1
    moveb #0x90,%a1@(6656)	| 40889342
    lea %sp@(-12),%sp
    moveal %sp,%a0
    addql #2,%a0
    moveq #120,%d0
    bsrw POWERMNGR_1D2
    lea %sp@(12),%sp
    moveal PmgrBase,%a2
    btst #1,%a2@(249)
    beqs WAKEUP_42_3A	| 40889364
    moveml %sp@,%d1-%fp
    moveal PmgrBase,%a2
    bsrl DOCKINGWAKEUPDENIED
    braw GOTOSLEEP_FA_2
WAKEUP_42_3A:
    .byte   0x61, 0xFF	| 40889378
    .long   SCSIDISKWAKEALERT-.	| 4088937A
    .short  0x594F	| 4088937E
    .long   0x204F10BC, 0x00027201, 0x303C0090, 0x6100F246	| 40889380
    .long   0x584F2070, 0x81E202B6, 0x01AA1028, 0xFFFD2F08	| 40889390
    .long   0x207081E2, 0x02B601AA, 0x4AA80004, 0x67062068	| 408893A0
    .long   0x00044E90, 0x205F61FF	| 408893B0
    .long   thunk_FUN_4089863a-.	| 408893B8
    .long   0x41F8020C	| 408893BC
    .long   0xA0396100, 0x03724CD7, 0x7FFE2478, 0x0D184AAA	| 408893C0
    .long   0x00FE6706, 0x206A00FE, 0x4E9046EA, 0x00C8A07B	| 408893D0
    .short  0xA853	| 408893E0
    jbsr SETSUPERVISORMODE_19E
    moveq #3,%d0
    jbsr SETSUPERVISORMODE_236
    moveal PmgrBase,%a2
    jbsr BATWATCH_94
    clrb %a2@(109)
    moveb #0xff,%a2@(13)
    clrl %a2@(72)
    clrl %a2@(76)
    moveb #8,%a2@(95)
    bclr #1,%a2@(296)
    bset #0,%a2@(296)
    jbsr SETSUPERVISORMODE_3C4
    bsrw SETSUPERVISORMODE
    moveml %sp@+,%d1-%fp
    moveq #0,%d0
    rts
    .fill   0x4C, 1, 0x00

/* SETSUPERVISORMODE: enter supervisor mode for the sleep code (through DebugUtil). */
SETSUPERVISORMODE:
    moveal %sp@+,%a1
    moveq #8,%d0
    _DebugUtil
    cmpiw #-50,%d0
    jbne SETSUPERVISORMODE_E
    movew %sr,%d0
SETSUPERVISORMODE_E:    /* interrupts as before, return */
    andiw #-4097,%sr
    jmp %a1@

/*
 Sleep helpers (they follow SETSUPERVISORMODE in the ROM, not part of it).
 SETSUPERVISORMODE_14 (d0 = sleep message): AppleTalk and sleep: if AppleTalk uses the
 modem port (PortBUse 1), a sleep request asks the user (alerts -16386..-16388)
 whether to close it; +108 records what to do on wake-up (1 nothing, 2 reopen .XPP,
 3, 4 AppleTalk turned off). d0 = 0 to sleep, else refused.
*/
SETSUPERVISORMODE_14:   /* save registers */
    moveml %d1-%d2/%a0-%a3,%sp@-
    subaw #50,%sp
    moveal %sp,%a3
    moveal PmgrBase,%a2
    moveq #15,%d1
    andb PortBUse,%d1
    cmpib #1,%d1
    jbne SETSUPERVISORMODE_FC
    movew %d0,%d1
    cmpib #1,%d0
    jbne SETSUPERVISORMODE_70
    btst #6,ChooserBits
    jbeq SETSUPERVISORMODE_FE
    btst #0,%a2@(15)
    jbne SETSUPERVISORMODE_FE
    btst #5,PortBUse
    jbne SETSUPERVISORMODE_5E
    moveb #1,%a2@(108)
    jbra SETSUPERVISORMODE_FC
SETSUPERVISORMODE_5E:   /* close it (SETSUPERVISORMODE_216): reopen on wake-up (2) */
    jbsr SETSUPERVISORMODE_216
    jbne SETSUPERVISORMODE_FE
    moveb #2,%a2@(108)
    jbra SETSUPERVISORMODE_FC
SETSUPERVISORMODE_70:   /* a sleep demand */
    cmpib #2,%d0
    jbne SETSUPERVISORMODE_CE
    btst #6,ChooserBits
    jbne SETSUPERVISORMODE_96
    jbsr SETSUPERVISORMODE_142
    bnew SETSUPERVISORMODE_FE
    moveb #4,%a2@(108)
    bset #6,ChooserBits
    braw SETSUPERVISORMODE_FC
SETSUPERVISORMODE_96:   /* AppleTalk active (ChooserBits bit 6) */
    btst #5,PortBUse
    jbne SETSUPERVISORMODE_AC
    .short  0x6100	| 40889512
    oril #1717179772,%a4@+
    orib #108,%d1
    jbra SETSUPERVISORMODE_FC
SETSUPERVISORMODE_AC:   /* close it, confirm (alert) */
    jbsr SETSUPERVISORMODE_216
    jbne SETSUPERVISORMODE_C0
    jbsr SETSUPERVISORMODE_13C
    jbne SETSUPERVISORMODE_FE
    moveb #2,%a2@(108)
    jbra SETSUPERVISORMODE_FC
SETSUPERVISORMODE_C0:   /* could not close: ask (alert) */
    bsrw SETSUPERVISORMODE_136
    jbne SETSUPERVISORMODE_FE
    moveb #3,%a2@(108)
    jbra SETSUPERVISORMODE_FC
SETSUPERVISORMODE_CE:   /* other messages: note the state */
    moveb #4,%a2@(108)
    bset #6,ChooserBits
    jbeq SETSUPERVISORMODE_FC
    moveb #1,%a2@(108)
    btst #5,PortBUse
    jbne SETSUPERVISORMODE_FC
    moveb #2,%a2@(108)
    jbsr SETSUPERVISORMODE_216
    jbeq SETSUPERVISORMODE_FC
    moveb #3,%a2@(108)
SETSUPERVISORMODE_FC:   /* d0 = 0 */
    moveq #0,%d0
SETSUPERVISORMODE_FE:   /* free the parameter block, return (d0 tested) */
    lea %sp@(50),%sp
    moveml %sp@+,%d1-%d2/%a0-%a3
    tstw %d0
    rts

SETSUPERVISORMODE_10A:  /* after sleep: reopen AppleTalk if it was on the modem port */
    moveml %d1-%d2/%a0-%a3,%sp@-
    subaw #50,%sp
    moveal %sp,%a3
    moveal PmgrBase,%a2
    moveq #15,%d1
    andb PortBUse,%d1
    cmpib #1,%d1
    bnew SETSUPERVISORMODE_12A
    bsrw SETSUPERVISORMODE_178
SETSUPERVISORMODE_12A:  /* return */
    lea %sp@(50),%sp
    moveml %sp@+,%d1-%d2/%a0-%a3
    tstw %d0
    rts

SETSUPERVISORMODE_136:  /* alert -16386 */
    movew #-16386,%d0
    jbra SETSUPERVISORMODE_146

SETSUPERVISORMODE_13C:  /* alert -16387 */
    movew #-16387,%d0
    jbra SETSUPERVISORMODE_146

SETSUPERVISORMODE_142:  /* alert -16388 */
    movew #-16388,%d0
SETSUPERVISORMODE_146:  /* Alert(d0): d0 = the item hit - 1 */
    clrw %sp@-
    movew %d0,%sp@-
    clrl %sp@-
    _Alert
    movew %sp@+,%d0
    subqw #1,%d0
    rts
    moveal %a3,%a0
    movew #-10,%a0@(24)
    _Close
    tstw %d0
    rts
    moveal %a3,%a0
    lea %pc@(PSTR_XPP),%a1
    movel %a1,%a0@(18)
    clrb %a0@(27)
    _Open
    _Close
    tstw %d0
    rts

SETSUPERVISORMODE_178:  /* reopen .XPP, Control 247, close it and .MPP (-10) */
    moveal %a3,%a0
    lea %pc@(PSTR_XPP),%a1
    movel %a1,%a0@(18)
    clrb %a0@(27)
    _Open
    movew #247,%a0@(26)
    _Control
    _Close
    movew #-10,%a0@(24)
    _Close
    tstw %d0
    rts

SETSUPERVISORMODE_19E:  /* on wake-up: the 'lmgr' resource (ENVINT_13C), reopen .MPP */
    moveml %d1-%d2/%a0-%a3,%sp@-
    jbsr ENVINT_13C
    moveal %sp,%a0
    lea %pc@(PSTR_MPP_4088ABF0),%a1
    movel %a1,%a0@(18)
    clrb %a0@(27)
    _Open
    lea %sp@(50),%sp
    moveml %sp@+,%d1-%d2/%a0-%a3
    rts

SETSUPERVISORMODE_1C0:  /* the sleep queue (+4): a request (1) asks every procedure; a refusal sends 4 (sleep revoked) to those already asked */
    moveml %d1/%a0,%sp@-
    moveal %a0@(4),%a0
    cmpiw #1,%d0
    jbne SETSUPERVISORMODE_1D4
    jbsr SETSUPERVISORMODE_1E6
    jbne SETSUPERVISORMODE_1DE
    moveq #2,%d0
SETSUPERVISORMODE_1D4:  /* the message to all */
    jbsr SETSUPERVISORMODE_1E6
    moveq #0,%d0
SETSUPERVISORMODE_1D8:  /* restore, return */
    moveml %sp@+,%d1/%a0
    rts
SETSUPERVISORMODE_1DE:  /* refused: revoke (4) */
    moveq #4,%d0
    jbsr SETSUPERVISORMODE_1E6
    moveq #4,%d0
    jbra SETSUPERVISORMODE_1D8

SETSUPERVISORMODE_1E6:  /* call the queue's procedures (recursively, last first) */
    movel %a0,%d1
    jbeq SETSUPERVISORMODE_212
    movel %d0,%d1
    moveml %d1/%a0,%sp@-
    moveal %a0@,%a0
    jbsr SETSUPERVISORMODE_1E6
    moveml %sp@+,%d1/%a0
    jbne SETSUPERVISORMODE_214
    movel %a0@(6),%d0
    jbeq SETSUPERVISORMODE_212
    moveal %d0,%a1
    movel %d1,%d0
    moveml %d1-%fp,%sp@-
    jsr %a1@
    moveml %sp@+,%d1-%fp
    jbra SETSUPERVISORMODE_BFE
SETSUPERVISORMODE_212:  /* d0 = 0 */
    moveq #0,%d0
SETSUPERVISORMODE_214:  /* return */
    rts

SETSUPERVISORMODE_216:  /* close .XPP (refNum -41) and open it again */
    moveal %a3,%a0
    movew #-41,%a0@(24)
    _Close
    movel %d0,%sp@-
    lea %pc@(PSTR_XPP),%a1
    movel %a1,%a0@(18)
    clrb %a0@(27)
    _Open
    movel %sp@+,%d0
    tstw %d0
    rts

SETSUPERVISORMODE_236:  /* tell the sleep queue (d0 = message); request answered no: revoke */
    cmpiw #6,%d0
    jbeq SETSUPERVISORMODE_292
    cmpiw #2,%d0
    jbeq SETSUPERVISORMODE_292
    cmpiw #3,%d0
    jbeq SETSUPERVISORMODE_292
SETSUPERVISORMODE_248:  /* each procedure (sleepqProc +6) */
    movel %d0,%d7
    moveal PmgrBase,%a1
    moveal %a1@(4),%a0
    movel %a0,%d2
    beqw SETSUPERVISORMODE_2BE
SETSUPERVISORMODE_258:  /* call it; a refusal of a request: revoke for everyone */
    moveal %a0@(6),%a2
    movel %a2,%d2
    jbeq SETSUPERVISORMODE_27C
    movew %d7,%d0
    moveml %a0-%a1,%sp@-
    jsr %a2@
    moveml %sp@+,%a0-%a1
    tstl %d0
    jbeq SETSUPERVISORMODE_27C
    cmpiw #4,%d7
    jbeq SETSUPERVISORMODE_27C
    moveq #4,%d0
    movel %d0,%d7
    jbra SETSUPERVISORMODE_248
SETSUPERVISORMODE_27C:  /* next element, to the last (+8) */
    cmpal %a1@(8),%a0
    jbeq SETSUPERVISORMODE_286
    moveal %a0@,%a0
    jbra SETSUPERVISORMODE_258
SETSUPERVISORMODE_286:  /* 2 (or 5 after a revoke) */
    moveq #2,%d0
    cmpiw #4,%d7
    jbne SETSUPERVISORMODE_292
    moveq #5,%d0
    rts
SETSUPERVISORMODE_292:  /* other messages: to every procedure */
    movew %d0,%d7
    moveal PmgrBase,%a1
    moveal %a1@(4),%a0
    movel %a0,%d2
    jbeq SETSUPERVISORMODE_2BE
SETSUPERVISORMODE_2A0:  /* call it */
    moveal %a0@(6),%a2
    movel %a2,%d2
    jbeq SETSUPERVISORMODE_2B4
    movew %d7,%d0
    moveml %a0-%a1,%sp@-
    jsr %a2@
    moveml %sp@+,%a0-%a1
SETSUPERVISORMODE_2B4:  /* next element */
    cmpal %a1@(8),%a0
    jbeq SETSUPERVISORMODE_2BE
    moveal %a0@,%a0
    jbra SETSUPERVISORMODE_2A0
SETSUPERVISORMODE_2BE:  /* 0 */
    moveq #0,%d0
    rts
SETSUPERVISORMODE_2BE_4:
    lea 0xfff8134e,%a1	| 40889736
    jsr %pc@(SETSUPERVISORMODE_2BE_4,%a1:l)
    moveq #16,%d1
    moveal ADBBase,%a1
    bras SETSUPERVISORMODE_2BE_1A
SETSUPERVISORMODE_2BE_16:
    lea %a1@(12),%a1
SETSUPERVISORMODE_2BE_1A:
    moveq #2,%d0
    cmpb %a1@(1),%d0
    bnes SETSUPERVISORMODE_2BE_34
    moveal %a1@(8),%a0
    lea %a0@(4),%a0
    moveq #0,%d0
    movel %d0,%a0@+
    movel %d0,%a0@+
    movel %d0,%a0@+
    movel %d0,%a0@+
SETSUPERVISORMODE_2BE_34:
    dbf %d1,SETSUPERVISORMODE_2BE_16
    rts
SETSUPERVISORMODE_2BE_34_6:
    cmpiw #16,%a0@(4)
    bnes SETSUPERVISORMODE_2BE_4E
    moveal PmgrBase,%a1
    lea %a1@(2),%a1
    _Enqueue
    rts
SETSUPERVISORMODE_2BE_4E:
    moveq #-5,%d0
    rts
SETSUPERVISORMODE_2BE_4E_4:
    cmpiw #16,%a0@(4)
    bnes SETSUPERVISORMODE_2BE_4E
    moveal PmgrBase,%a1
    lea %a1@(2),%a1
    _Dequeue
    rts

SETSUPERVISORMODE_324:  /* the machine's power table: by the machine's ID (universal info +19) in the list at CLKNOMEM_A16: XPRAM address (+85), timeouts, the microcontroller's settings (+34), more (+246, +354, +158) */
    clrl %a3@(270)
    moveal 0xdd8,%a0
    moveb %a0@(19),%d0
    biglea CLKNOMEM_A16
SETSUPERVISORMODE_33A:  /* next entry */
    addqw #4,%a0
    movew %a0@+,%d1
    jbeq SETSUPERVISORMODE_36C
    cmpb %d1,%d0
    jbne SETSUPERVISORMODE_33A
    addal %a0@,%a0
    movel %a0,%a3@(270)
    addal %a0@,%a0
    moveb %a0@+,%a3@(85)
    moveq #0,%d0
    moveb %a0@+,%d0
    movew %d0,%a3@(246)
    movew %a0@+,%a3@(34)
    movew %a0@+,%d0
    extw %d0
    movew %d0,%a3@(354)
    addqw #2,%a0
    movel %a0@+,%a3@(158)
    rts
SETSUPERVISORMODE_36C:  /* not found: defaults */
    movew #20,%a3@(246)
    moveb #73,%a3@(34)
    moveb #48,%a3@(35)
    rts

SETSUPERVISORMODE_380:  /* 0xDD5 bit 4: PMgrOp 0x78, then 0x71 with 0 */
    btst #4,0xdd5
    jbeq SETSUPERVISORMODE_3A4
    lea %sp@(-12),%sp
    moveal %sp,%a0
    addql #2,%a0
    moveq #120,%d0
    jbsr POWERMNGR_1D2
    clrb %a0@
    moveq #1,%d1
    moveq #113,%d0
    jbsr POWERMNGR_1D4
    lea %sp@(12),%sp
SETSUPERVISORMODE_3A4:  /* return */
    rts

SETSUPERVISORMODE_3A6:  /* save the cursor, show the watch, hide it */
    moveal %a5@,%a0
    lea %a0@(-108),%a0
    movel %a0,%a2@(278)
    subql #4,%sp
    movew #4,%sp@-
    _GetCursor
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movel %a0,%sp@-
    _SetCursor
    _HideCursor
    rts

SETSUPERVISORMODE_3C4:  /* the machine's wake-up routine (+28); the cursor back */
    moveal %a2@(270),%a0
    movel %a0@(28),%d0
    jbeq SETSUPERVISORMODE_3D2
    jsr %a0@(0x0,%d0:l)
SETSUPERVISORMODE_3D2:  /* show it */
    movel %a2@(278),%sp@-
    _SetCursor
    _ShowCursor
    rts
    moveal PmgrBase,%a0
    movew %sr,%d0
    swap %d0
    oriw #1792,%sr
    bset #3,%a0@(296)
    bset #4,%a0@(296)
    tstw %d0
    bnes SETSUPERVISORMODE_3D2_2C
    bclr #4,%a0@(296)
SETSUPERVISORMODE_3D2_2C:
    swap %d0
    movew %d0,%sr
    moveq #0,%d0
    rts

/*
 The _PMgrOp implementation (a0 = parameter block: command word, count, send pointer,
 reply pointer): with interrupts masked and the VIA 1 interrupts saved, special commands
 go to the machine's own routines (the table at +346); otherwise send the command
 byte (up to 512 tries while the microcontroller is busy, polling the serial port),
 the count (unless the command table, +262, gives it) and the data, then read the
 reply count (the reply table, +266) and bytes. VIA 2 port A carries the data (or the
 VIA 1 shift register, on machines with 0xDD5 bit 1), port B bits 1 and 2 handshake.
 Results -13000 .. -13005 as for the parallel transport.
*/
SETSUPERVISORMODE_406:  /* save registers */
    moveml %d1-%fp,%sp@-
    jbsr SETSUPERVISORMODE_6EA
    movew %sr,%d6
    swap %d6
    movew %d1,%d6
    moveal PmgrBase,%a3
    cmpaw #-1,%a3
    jbeq SETSUPERVISORMODE_422
    moveal %a3@(346),%a1
SETSUPERVISORMODE_422:  /* a3 = the table of special commands; a1 = VIA 1, a2 = VIA 2 */
    moveal %a1,%a3
    moveal VIA,%a1
    moveal ghost_VIA2,%a2
    moveq #16,%d1
    andb %a1@(7168),%d1
    moveb %d1,%a1@(7168)
    jbeq SETSUPERVISORMODE_43C
    bset #7,%d1
SETSUPERVISORMODE_43C:  /* save the VIA 1 interrupt enables; d7 = a save area; the serial poll routine */
    moveb %d1,%sp@-
    lea %sp@(-32),%sp
    movel %sp,%d7
    moveal SCCRd,%fp
    addqw #6,%fp
    tstl PollProc
    jbne SETSUPERVISORMODE_454
    lea %pc@(SETSUPERVISORMODE_5D0),%fp
SETSUPERVISORMODE_454:  /* a special command (mask and value)? */
    movel %a0,%d4
    movew %a0@,%d0
SETSUPERVISORMODE_458:  /* next entry */
    addqw #4,%a3
    moveb %a3@+,%d1
    jbeq SETSUPERVISORMODE_478
    andb %d0,%d1
    cmpb %a3@+,%d1
    jbne SETSUPERVISORMODE_458
    moveml %a0-%a2,%sp@-
    oriw #1792,%sr
    addal %a3@,%a3
    jsr %a3@
    moveml %sp@+,%a0-%a2
    jbeq SETSUPERVISORMODE_57C
SETSUPERVISORMODE_478:  /* send: d3 = tries */
    movew TimeVIADB,%d5
    lslw #5,%d5
    movew #511,%d3
    movew %a0@+,%d1
SETSUPERVISORMODE_484:  /* wait for the microcontroller to be idle (pmBusyErr) */
    movew #-13000,%d0
    movew TimeVIADB,%d2
    lslw #2,%d2
    jbsr SETSUPERVISORMODE_5E8
    jbeq SETSUPERVISORMODE_57C
    btst #5,0xdd5
    beqw SETSUPERVISORMODE_4C0
    movew TimeVIADB,%d2
    lslw #4,%d2
    clrb %a2@(1536)
SETSUPERVISORMODE_4AA:  /* (0xDD5 bit 5: wait for port A to read 7) */
    cmpib #7,%a2@(512)
    dbne %d2,SETSUPERVISORMODE_4AA
    jbne SETSUPERVISORMODE_4C0
    movel #-13000,%d0
    jbra RESTORE030_468
SETSUPERVISORMODE_4C0:  /* send the command byte */
    oriw #1792,%sr
    jbsr SETSUPERVISORMODE_660
    jbeq SETSUPERVISORMODE_4E2
    jbsr SETSUPERVISORMODE_6AA
    movew %d5,%d2
    swap %d6
SETSUPERVISORMODE_4D2:  /* refused: wait, try again */
    movew %d6,%sr
    dbf %d2,SETSUPERVISORMODE_4D2
    swap %d6
    dbf %d3,SETSUPERVISORMODE_484
    jbra SETSUPERVISORMODE_57C
SETSUPERVISORMODE_4E2:  /* d3 = the count: sent only if the command table says so */
    movew %a0@+,%d3
    btst #1,0xdd5
    jbeq SETSUPERVISORMODE_504
    lea %pc@(SETSUPERVISORMODE_938),%a3
    moveal PmgrBase,%a4
    cmpaw #-1,%a4
    jbeq SETSUPERVISORMODE_4FE
    moveal %a4@(262),%a3
SETSUPERVISORMODE_4FE:  /* the count, for commands of variable length */
    tstb %a3@(0x0,%d1:w)
    jbpl SETSUPERVISORMODE_50C
SETSUPERVISORMODE_504:  /* send the count */
    movew %d3,%d1
    jbsr SETSUPERVISORMODE_660
    jbne SETSUPERVISORMODE_57C
SETSUPERVISORMODE_50C:  /* the data bytes */
    moveal %a0@,%a3
    moveq #0,%d1
    jbra SETSUPERVISORMODE_518
SETSUPERVISORMODE_512:  /* next byte */
    moveb %a3@+,%d1
    jbsr SETSUPERVISORMODE_660
SETSUPERVISORMODE_518:  /* count down */
    dbne %d3,SETSUPERVISORMODE_512
    jbne SETSUPERVISORMODE_57C
    subqw #4,%a0
    movew %a0@,%d1
    lea %pc@(SETSUPERVISORMODE_A38),%a3
    moveal PmgrBase,%a4
    cmpaw #-1,%a4
    jbeq SETSUPERVISORMODE_534
    moveal %a4@(266),%a3
SETSUPERVISORMODE_534:  /* the reply: its length from the reply table (0: none) */
    moveb %a3@(0x0,%d1:w),%d3
    extw %d3
    movew %d3,%a0@(2)
    jbeq SETSUPERVISORMODE_57C
    btst #1,0xdd5
    jbeq SETSUPERVISORMODE_54C
    subqw #1,%d3
    jbne SETSUPERVISORMODE_552
SETSUPERVISORMODE_54C:  /* read the reply command byte */
    jbsr SETSUPERVISORMODE_602
    jbne SETSUPERVISORMODE_5C6
SETSUPERVISORMODE_552:  /* store it */
    movew %d1,%a0@+
    btst #1,0xdd5
    jbeq SETSUPERVISORMODE_560
    tstw %d3
    jbpl SETSUPERVISORMODE_568
SETSUPERVISORMODE_560:  /* variable length: read the count */
    jbsr SETSUPERVISORMODE_602
    jbne SETSUPERVISORMODE_57C
    movew %d1,%d3
SETSUPERVISORMODE_568:  /* store it; the reply buffer */
    movew %d3,%a0@+
    addqw #4,%a0
    moveal %a0@+,%a3
    jbra SETSUPERVISORMODE_578
SETSUPERVISORMODE_570:  /* read a byte */
    jbsr SETSUPERVISORMODE_602
    jbne SETSUPERVISORMODE_57C
    moveb %d1,%a3@+
SETSUPERVISORMODE_578:  /* count down */
    dbf %d3,SETSUPERVISORMODE_570
SETSUPERVISORMODE_57C:  /* done: a power-off command (0x10 with a value above 0x80) waits a moment first */
    moveal VIA,%a1
    moveal %d4,%a0
    movew %d0,%d4
    jbne SETSUPERVISORMODE_5AC
    cmpiw #16,%a0@
    jbne SETSUPERVISORMODE_5AC
    moveal %a0@(4),%a2
    cmpib #0x80,%a2@
    jbls SETSUPERVISORMODE_5AC
    movew TimeVIADB,%d2
    lsrw #3,%d2
SETSUPERVISORMODE_59C:  /* (polling the serial port while waiting) */
    tstb %a1@
    btst #0,%fp@(-4)
    jbeq SETSUPERVISORMODE_5A8
    moveb %fp@,%sp@-
SETSUPERVISORMODE_5A8:  /* count down */
    dbf %d2,SETSUPERVISORMODE_59C
SETSUPERVISORMODE_5AC:  /* the poll procedure, VIA 1 interrupts and the status register back */
    jbsr SETSUPERVISORMODE_6AA
    lea %sp@(32),%sp
    moveb %sp@+,%a1@(7168)
    swap %d6
    movew %d6,%sr
    movew %d4,%d0
    extl %d0
    moveml %sp@+,%d1-%fp
    rts
SETSUPERVISORMODE_5C6:  /* -13001 (pmReplyTOErr) */
    movew #-13001,%d0
    jbra SETSUPERVISORMODE_57C
    .short  0x0000	| 40889A40

SETSUPERVISORMODE_5CE:  /* wait for acknowledge low (port B bit 1), polling the serial port */
    moveal %sp@+,%a4
SETSUPERVISORMODE_5D0:  /* (no poll routine) */
    jbra SETSUPERVISORMODE_5DE
SETSUPERVISORMODE_5D2:  /* poll the SCC */
    tstb %a1@
    btst #0,%fp@(-4)
    jbeq SETSUPERVISORMODE_5DE
    moveb %fp@,%sp@-
SETSUPERVISORMODE_5DE:  /* acknowledge? */
    btst #1,%a2@
    dbeq %d2,SETSUPERVISORMODE_5D2
    jmp %a4@

SETSUPERVISORMODE_5E8:  /* wait for acknowledge high */
    moveal %sp@+,%a4
    jbra SETSUPERVISORMODE_5F8
SETSUPERVISORMODE_5EC:  /* poll the SCC */
    tstb %a1@
    btst #0,%fp@(-4)
    jbeq SETSUPERVISORMODE_5F8
    moveb %fp@,%sp@-
SETSUPERVISORMODE_5F8:  /* acknowledge? */
    btst #1,%a2@
    dbne %d2,SETSUPERVISORMODE_5EC
    jmp %a4@

SETSUPERVISORMODE_602:  /* read a byte (by the interface type in d6: parallel or the shift register) */
    movew %d5,%d2
    movew #-13004,%d0
    moveal %sp@+,%a5
    jmp %pc@(SETSUPERVISORMODE_60E,%d6:w)
SETSUPERVISORMODE_60E:  /* (shift register variant) */
    bras SETSUPERVISORMODE_638	| 40889A82
    .byte   0x08, 0xA9, 0x00, 0x04, 0x16, 0x00, 0x4A, 0x29, 0x14, 0x00, 0x08, 0x92, 0x00, 0x02	| 40889A84
    jbsr SETSUPERVISORMODE_5CE
    jbne SETSUPERVISORMODE_654
    bset #2,%a2@
    movew #-13005,%d0
    movew %d5,%d2
    jbsr SETSUPERVISORMODE_5E8
    jbeq SETSUPERVISORMODE_654
    moveb %a1@(5120),%d1
    moveq #0,%d0
    jbra SETSUPERVISORMODE_654
SETSUPERVISORMODE_638:  /* parallel: port A input, wait, request, read */
    clrb %a2@(1536)	| 40889AAC
    jbsr SETSUPERVISORMODE_5CE
    jbne SETSUPERVISORMODE_654
    bclr #2,%a2@
    moveb %a2@(512),%d1
    movew #-13005,%d0

SETSUPERVISORMODE_64C:  /* wait for acknowledge to go */
    movew %d5,%d2
    jbsr SETSUPERVISORMODE_5E8
    jbeq SETSUPERVISORMODE_654
    moveq #0,%d0
SETSUPERVISORMODE_654:  /* request high, the interface back, return */
    bset #2,%a2@
    jsr %pc@(SETSUPERVISORMODE_69A,%d6:w)
    tstw %d0
    jmp %a5@

SETSUPERVISORMODE_660:  /* send byte d1 (by interface type), request, wait for acknowledge */
    movel %d5,%d2
    moveal %sp@+,%a5
    jsr %pc@(SETSUPERVISORMODE_680,%d6:w)
    bclr #2,%a2@
    movew #-13002,%d0
    jbsr SETSUPERVISORMODE_5CE
    jbne SETSUPERVISORMODE_654
    bset #2,%a2@
    movew #-13003,%d0
    jbra SETSUPERVISORMODE_64C
SETSUPERVISORMODE_680:  /* (shift register variant) */
    bras SETSUPERVISORMODE_68E	| 40889AF4
    .byte   0x08, 0xE9, 0x00, 0x04, 0x16, 0x00, 0x13, 0x41, 0x14, 0x00, 0x4E, 0x75	| 40889AF6
SETSUPERVISORMODE_68E:  /* parallel: port A = the byte */
    moveb #0xff,%a2@(1536)	| 40889B02
    moveb %d1,%a2@(512)	| 40889B08
    rts	| 40889B0C
SETSUPERVISORMODE_69A:  /* (shift register variant) */
    jbra SETSUPERVISORMODE_6A4	| 40889B0E
    .byte   0x08, 0xE9, 0x00, 0x04, 0x16, 0x00, 0x4E, 0x75	| 40889B10
SETSUPERVISORMODE_6A4:  /* parallel: port A input */
    clrb %a2@(1536)	| 40889B18
    rts	| 40889B1C

SETSUPERVISORMODE_6AA:  /* run the serial poll procedure (PollProc) if data came in meanwhile */
    moveal %sp@+,%a4
    cmpal %d7,%sp
    jbeq SETSUPERVISORMODE_6D0
    movel PollProc,%d0
    jbeq SETSUPERVISORMODE_6CE
    movel %d7,PollStack
    moveal %d7,%a3
    moveml %d3-%d6/%a0-%a2/%a4,%a3@
    lea %a1@(7680),%a5
    moveal %d0,%a3
    jsr %a3@
    moveal %d7,%a3
    moveml %a3@,%d3-%d6/%a0-%a2/%a4
SETSUPERVISORMODE_6CE:  /* the stack back */
    moveal %d7,%sp
SETSUPERVISORMODE_6D0:  /* return */
    jmp %a4@

SETSUPERVISORMODE_6D2:  /* the command and reply tables (+262, +266) and the special commands (+346) */
    lea %pc@(SETSUPERVISORMODE_938),%a0
    movel %a0,%a3@(262)
    lea %pc@(SETSUPERVISORMODE_A38),%a0
    movel %a0,%a3@(266)
    jbsr SETSUPERVISORMODE_6EA
    movel %a1,%a3@(346)
    rts

SETSUPERVISORMODE_6EA:  /* which interface: 0xDD5 bit 4, bit 5, or neither (d1 = its type, a1 = its special commands) */
    btst #4,0xdd5
    jbeq SETSUPERVISORMODE_754
    moveq #2,%d1
SETSUPERVISORMODE_6F4:  /* (table) */
    lea %pc@(SETSUPERVISORMODE_6F6),%a1
    rts
    .short  0xFF10	| 40889B6E
    .long   0x000000FC, 0xFF180000, 0x0184FF1F, 0x000001EC	| 40889B70
    .long   0xFE680000, 0x00A8FF90, 0x000001E4, 0xFF980000	| 40889B80
    .long   0x01FC0000, 0x00000000, 0x00000000, 0x00000000	| 40889B90
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40889BA0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40889BB0
    .long   0x00000000, 0x00000000	| 40889BC0
SETSUPERVISORMODE_754:  /* 0xDD5 bit 5? */
    btst #5,0xdd5
    jbeq SETSUPERVISORMODE_7AC
    moveq #0,%d1
SETSUPERVISORMODE_75E:  /* (table) */
    lea %pc@(SETSUPERVISORMODE_760),%a1
    rts
    .long   0xF0500000, 0x13E2F771	| 40889BD8
    .long   0x000013E6, 0xF0A00000, 0x13E00000, 0x00000000	| 40889BE0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40889BF0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40889C00
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40889C10
SETSUPERVISORMODE_7AC:  /* neither */
    moveq #0,%d1
SETSUPERVISORMODE_7AE:  /* (table) */
    lea %pc@(SETSUPERVISORMODE_7B0),%a1
    rts
    .byte   0x00, 0x00	| 40889C28
    moveal %a0,%a1	| 40889C2A
    subqw #8,%sp
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #107,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    bnes SETSUPERVISORMODE_7B0_42
    moveal %sp,%a0
    movew #3,%a1@(2)
    moveal %a1@(8),%a1
    moveq #11,%d1
    andb %a0@,%d1
    moveb %d1,%a1@+
    moveq #0,%d1
    btst #2,%a0@+
    beqs SETSUPERVISORMODE_7B0_3C
    movew %a0@,%d1
    lsrw #1,%d1
SETSUPERVISORMODE_7B0_3C:
    moveb %d1,%a1@+
    addqw #2,%a0
    moveb %a0@+,%a1@+
SETSUPERVISORMODE_7B0_42:
    addqw #8,%sp
    moveq #0,%d1
    rts
    moveal %a0@(4),%a1
    moveq #0,%d1
    moveb %a1@,%d1
    moveml %d1/%a0,%sp@-
    movew #-22369,%d0
    .short  0xA746	| 40889C7C _GetTrapAddress (flags 0x0700)
    moveal %a0,%a1
    movew %pc@(SETSUPERVISORMODE_7B0_70),%d0
    .short  0xA746	| 40889C84 _GetTrapAddress (flags 0x0700)
    cmpal %a0,%a1
    beqs SETSUPERVISORMODE_7B0_74
    subqw #4,%sp
    pea 0x7063746c	| 40889C8C
    movel %d1,%sp@-
SETSUPERVISORMODE_7B0_70:
    _DockingDispatch
    addqw #4,%sp
SETSUPERVISORMODE_7B0_74:
    moveml %sp@+,%d1/%a0
    moveal ghost_VIA2,%a1
    moveq #18,%d0
    andb %d1,%d0
    beqs SETSUPERVISORMODE_7B0_96
    eorb %d0,%d1
    tstb %d1
    bmis SETSUPERVISORMODE_7B0_90
    bclr #1,%a1@(33)
    bras SETSUPERVISORMODE_7B0_96
SETSUPERVISORMODE_7B0_90:
    bset #1,%a1@(33)
SETSUPERVISORMODE_7B0_96:
    btst #2,%d1
    beqs SETSUPERVISORMODE_7B0_AE
    tstb %d1
    bmis SETSUPERVISORMODE_7B0_A8
    bclr #2,%a1@(33)
    bras SETSUPERVISORMODE_7B0_AE
SETSUPERVISORMODE_7B0_A8:
    bset #2,%a1@(33)
SETSUPERVISORMODE_7B0_AE:
    bclr #5,%d1
    beqs SETSUPERVISORMODE_7B0_C6
    tstb %d1
    bmis SETSUPERVISORMODE_7B0_C0
    bclr #0,%a1@(34)
    bras SETSUPERVISORMODE_7B0_C6
SETSUPERVISORMODE_7B0_C0:
    bset #0,%a1@(34)
SETSUPERVISORMODE_7B0_C6:
    bclr #0,%d1
    moveq #127,%d0
    andb %d1,%d0
    bnes SETSUPERVISORMODE_7B0_D4
    clrw %a0@(2)
SETSUPERVISORMODE_7B0_D4:
    rts
    moveq #0,%d1
    movel %a0,%sp@-
    movew #-22369,%d0
    .short  0xA746	| 40889D02 _GetTrapAddress (flags 0x0700)
    moveal %a0,%a1
    movew %pc@(SETSUPERVISORMODE_7B0_F6),%d0
    .short  0xA746	| 40889D0A _GetTrapAddress (flags 0x0700)
    cmpal %a0,%a1
    beqs SETSUPERVISORMODE_7B0_FC
    subqw #4,%sp
    pea 0x706f7772	| 40889D12
    clrl %sp@-
SETSUPERVISORMODE_7B0_F6:
    _DockingDispatch
    moveq #127,%d1
    andl %sp@+,%d1
SETSUPERVISORMODE_7B0_FC:
    moveal %sp@+,%a1
    clrw %sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #31,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    orb %sp@+,%d1
    tstw %d0
    bnes SETSUPERVISORMODE_7B0_134
    moveal ghost_VIA2,%a0
    btst #1,%a0@(33)
    beqs SETSUPERVISORMODE_7B0_128
    orib #18,%d1
SETSUPERVISORMODE_7B0_128:
    btst #0,%a0@(34)
    beqs SETSUPERVISORMODE_7B0_134
    orib #32,%d1
SETSUPERVISORMODE_7B0_134:
    movew #1,%a1@(2)
    moveal %a1@(8),%a0
    moveb %d1,%a0@
    moveq #0,%d1
    rts
    subqw #7,%a0@
    rts
    clrw %a0@(2)
    moveal %a0@(4),%a1
    moveq #3,%d1
    andb %a1@,%d1
    moveal ghost_VIA2,%a1
    moveb %pc@(SETSUPERVISORMODE_7B0_162,%d1:w),%a1@(34)
    moveq #0,%d0
    rts
SETSUPERVISORMODE_7B0_162:
    .short  0x0001, 0x4041	| orib #65,%d1
    moveal ghost_VIA2,%a1
    moveq #65,%d1
    andb %a1@(34),%d1
    bclr #6,%d1
    beqs SETSUPERVISORMODE_7B0_162_16	| 40889D98
    addqb #2,%d1
SETSUPERVISORMODE_7B0_162_16:
    .byte   0x31, 0x7C, 0x00, 0x01	| 40889D9C
SETSUPERVISORMODE_92C:  /* (data) */
    .byte   0x00, 0x02	| 40889DA0
    moveal %a0@(8),%a1	| 40889DA2
    moveb %d1,%a1@
    moveq #0,%d0
    rts
SETSUPERVISORMODE_938:  /* the command table: per command, the number of bytes to send (-1: a count byte follows) */
    .long   0xFFFFFFFF	| 40889DAC
    .long   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x0101FFFF	| 40889DB0
    .long   0xFFFFFFFF, 0x0000FFFF, 0xFFFFFF00, 0xFF000201	| 40889DC0
    .long   0x01FFFFFF, 0x00FFFFFF, 0xFFFFFFFF, 0x0414FFFF	| 40889DD0
    .long   0xFFFFFFFF, 0x000002FF, 0xFFFFFFFF, 0x0101FFFF	| 40889DE0
    .long   0xFFFFFFFF, 0x0000FFFF, 0xFFFFFFFF, 0x01000202	| 40889DF0
    .long   0xFF010301, 0x00010000, 0x00FFFFFF, 0x02FFFFFF	| 40889E00
    .long   0xFFFFFFFF, 0x00000000, 0x0000FFFF, 0x010101FF	| 40889E10
    .long   0xFFFFFFFF, 0x0000FFFF, 0xFFFF0404, 0x04FF00FF	| 40889E20
    .long   0xFFFFFFFF, 0x00FFFFFF, 0xFFFFFFFF, 0x0102FFFF	| 40889E30
    .long   0xFFFFFFFF, 0x0000FFFF, 0xFFFFFFFF, 0x02020204	| 40889E40
    .long   0xFF00FFFF, 0x01010302, 0xFFFFFFFF, 0xFFFFFFFF	| 40889E50
    .long   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF	| 40889E60
    .long   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00FFFFFF	| 40889E70
    .long   0xFFFFFFFF, 0x0101FFFF	| 40889E80
    .short  0x0000, 0xFFFF	| orib #0xff,%d0
    .long   0xFF0400FF	| 40889E8C
    .short  0xFFFF, 0xFFFF, 0x03FF, 0x00FF, 0x00FF, 0xFF00, 0xFFFF	| 40889E90
SETSUPERVISORMODE_A2A:  /* (data) */
    .byte   0xFF	| 40889E9E
SETSUPERVISORMODE_A2B:  /* (data) */
    .byte   0xFF	| 40889E9F
SETSUPERVISORMODE_A2C:  /* (data) */
    .long   0xFFFFFFFF /* number, not an address (F5) */	| 40889EA0
    .long   0xFFFFFFFF /* number, not an address (F5) */	| 40889EA4
    .long   0xFFFFFFFF /* number, not an address (F5) */	| 40889EA8
SETSUPERVISORMODE_A38:  /* the reply table: per command, the reply length (-1: a count byte comes first) */
    .long   0x00000000	| 40889EAC
    .long   0x00000000, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000	| 40889EB0
    .long   0x00000000, 0x0202FFFF	| 40889EC0
    .long   0xFFFFFF00 /* number, not an address (F5) */	| 40889EC8
    .long   0x00000000	| 40889ECC
    .long   0x00000000	| 40889ED0
    .long   0xFFFFFFFF /* number, not an address (F5) */	| 40889ED4
    .long   0xFFFFFFFF /* number, not an address (F5) */	| 40889ED8
    .long   0x00000000	| 40889EDC
    .long   0x00000000, 0x0515FFFF, 0xFFFFFFFF, 0x00000000	| 40889EE0
    .long   0x00000000, 0x0202FFFF, 0xFFFFFFFF, 0x00000000	| 40889EF0
    .long   0x00000000, 0x02000303, 0xFFFFFFFF, 0x00000000	| 40889F00
    .long   0x00000000, 0x04040309, 0xFFFFFFFF, 0x00000000	| 40889F10
    .long   0x00000000, 0xFFFFFFFF, 0xFFFF0101, 0x00000000	| 40889F20
    .byte   0x00	| 40889F30
SETSUPERVISORMODE_ABD:  /* (data) */
    .byte   0x00	| 40889F31
SETSUPERVISORMODE_ABE:  /* (data) */
    .long   0x000006FF /* number, not an address */	| 40889F32
    .long   0xFFFFFFFF /* number, not an address (F5) */	| 40889F36
    .long   0xFFFF0000 /* number, not an address (F5) */	| 40889F3A
    .short  0x0000	| 40889F3E
    .long   0x00000000, 0x0202FFFF, 0xFFFFFFFF, 0x00000000	| 40889F40
    .short  0x0000, 0x0000, 0x0200, 0x0000, 0xFFFF	| 40889F50
    .long   0xFFFF0000 /* number, not an address (F5) */	| 40889F5A
    .short  0x0000, 0x0000	| 40889F5E
    .long   0x0000FFFF /* number, not an address (F5) */	| 40889F62
    .long   0xFFFFFFFF /* number, not an address (F5) */	| 40889F66
    .long   0xFFFF0000 /* number, not an address (F5) */	| 40889F6A
    .short  0x0000	| 40889F6E
    .long   0x00000000, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000	| 40889F70
    .long   0x00000000, 0x0202FFFF, 0x02FFFFFF, 0x00000100	| 40889F80
    .long   0x00000000, 0xFFFF02FF, 0xFFFFFF00, 0x00000000	| 40889F90
    .long   0x00000000, 0xFFFFFFFF, 0xFFFFFFFF	| 40889FA0

SETSUPERVISORMODE_B38:  /* interrupt status bit 3: an ADB interrupt: to the level 1 dispatcher (Lvl1DT) */
    btst #3,%d0
    jbeq SETSUPERVISORMODE_B4C
    lea %sp@(16),%sp
    moveal VIA,%a1
    moveal Lvl1DT,%a0
    jmp %a0@
SETSUPERVISORMODE_B4C:  /* bit 2: environment */
    btst #2,%d0
    rts
SETSUPERVISORMODE_B4C_6:
    moveal %a2@(270),%a0
    addal %a0@,%a0
    tstb %a2@(13)
    bpls SETSUPERVISORMODE_B4C_20
    bclr #5,%a2@(84)
    beqs SETSUPERVISORMODE_B4C_58
    movew %a0@(2),%d0
    bras SETSUPERVISORMODE_B4C_3C
SETSUPERVISORMODE_B4C_20:
    cmpib #4,%a2@(13)
    bnes SETSUPERVISORMODE_B4C_58
    tstb %a2@(109)
    bnes SETSUPERVISORMODE_B4C_58
    bset #5,%a2@(84)
    movew %a0@(2),%d0
    moveb %a0@(4),%d0
SETSUPERVISORMODE_B4C_3C:
    tstw %d0
    beqs SETSUPERVISORMODE_B4C_58
    swap %d0
    movel %d0,%sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #2,%sp@-
    movew #96,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(16),%sp
SETSUPERVISORMODE_B4C_58:
    tstb %a2@(17)
    beqs SETSUPERVISORMODE_B4C_7C
    clrb %a2@(17)
    subqw #8,%sp
    moveal %sp,%a0
    moveq #6,%d0
    swap %d0
    moveb %a2@(85),%d0
    _ReadXPRam
    moveb %a0@(2),%a2@(16)
    movew %a0@,%a2@
    addqw #8,%sp
    .short  0xA285	| 4088A03A _PMgrOp (flags 0x0200)
SETSUPERVISORMODE_B4C_7C:
    rts

SETSUPERVISORMODE_BCA:  /* remove the low-battery notification if posted */
    tstb %a2@(80)
    jbeq SETSUPERVISORMODE_BDE
    movel %d0,%sp@-
    lea %a2@(36),%a0
    _NMRemove
    movel %sp@+,%d0
    clrb %a2@(80)
SETSUPERVISORMODE_BDE:  /* return */
    rts
    movel %sp@+,%d0
    btst #4,0xdd5
    bnew SETSUPERVISORMODE_406
    btst #5,0xdd5
    bnew SETSUPERVISORMODE_406
    moveml %d1-%d6/%a0-%fp,%sp@-
    movel %d0,%sp@-
    rts

SETSUPERVISORMODE_BFE:  /* a request: d0 is the answer */
    cmpiw #1,%d1
    jbne SETSUPERVISORMODE_C08
    tstl %d0
    rts
SETSUPERVISORMODE_C08:  /* 0 */
    moveq #0,%d0
    rts

/*
 ENVINT: environment interrupt (lid, charger, docking): a notification or a
 shutdown/sleep.
*/
ENVINT:
    btst #5,0xdd5
    beqw ENVINT_26
    .short  0xA285	| 4088A08A _PMgrOp (flags 0x0200)
    btst #7,%a2@(84)
    beqs ENVINT_18
    _PowerOff
ENVINT_16:
    bras ENVINT_16
ENVINT_18:
    btst #0,%a2@(296)
    beqs ENVINT_26
    bset #1,%a2@(296)
ENVINT_26:
    rts

ENVINT_28:              /* (the parallel transport, continued: wait for port A to read 0x7F) */
    movew TimeVIADB,%d2
    lslw #4,%d2
    clrb %a4@(1536)
ENVINT_32:              /* wait */
    cmpib #127,%a4@(512)
    dbne %d2,ENVINT_32
    jbne ENVINT_48
    movel #-13000,%d0
    jbra RESTORE030_468
ENVINT_48:              /* ready: send */
    oriw #1792,%sr
    jbra RESTORE030_3A0

ENVINT_50:              /* bit 0: the charger was plugged in: reset the warning counter */
    btst #0,%d2
    jbeq ENVINT_5C
    movew %a2@(354),%a2@(356)
ENVINT_5C:              /* return */
    rts

ENVINT_5E:              /* low battery: count down the warnings */
    tstw %a2@(356)
    jble ENVINT_6A
    subqw #1,%a2@(356)
    rts
ENVINT_6A:              /* warn: post the notification (one of two messages, +238/+242), tell the microcontroller (PMgrOp 0x21) */
    jbsr SETSUPERVISORMODE_BCA
    bset #3,%a2@(84)
    lea %a2@(238),%a1
    bset #4,%a2@(84)
    jbeq ENVINT_88
    addql #4,%a1
    bclr #4,%a2@(84)
ENVINT_88:              /* the message */
    tstl %a1@
    jbeq ENVINT_C2
    lea %a2@(36),%a0
    movel %a1@,%a0@(24)
    lea %pc@(ENVINT_C4),%a1
    movel %a1,%a0@(28)
    movel %a2@(110),%a0@(16)
    _NMInstall
    subql #4,%sp
    moveal %sp,%a0
    moveb #0xe0,%d0
    moveq #3,%d1
    movew #33,%a0@
    andil #-6,%d2
    moveb %d2,%a0@(2)
    jbsr POWERMNGR_1D4
    addql #4,%sp
ENVINT_C2:              /* return */
    rts
ENVINT_C4:              /* the notification's response procedure: clear the "posted" bit */
    moveal %sp@+,%a1	| 4088A144
    moveal %sp@+,%a0	| 4088A146
    _NMRemove	| 4088A148
    moveal PmgrBase,%a0	| 4088A14A
    bclr #3,%a0@(84)	| 4088A14E
    jmp %a1@	| 4088A154
    .byte   0x00, 0x3E, 0x00, 0x4C, 0x00, 0x54, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4088A156
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4088A166
    .byte   0x00, 0x00, 0x00, 0x00, 0x48, 0x40, 0x24, 0x78, 0x0D, 0x18, 0x0C, 0x40, 0x00, 0x02, 0x62, 0x08	| 4088A176
    .byte   0x30, 0x3B, 0x02, 0xCE, 0x4E, 0xFB, 0x00, 0xCA, 0x30, 0x3C, 0xFF, 0xCE, 0x4E, 0x75, 0x08, 0xAA	| 4088A186
    .byte   0x00, 0x01, 0x01, 0x28, 0x08, 0xEA, 0x00, 0x00, 0x01, 0x28, 0x60, 0x16, 0x08, 0xEA, 0x00, 0x07	| 4088A196
    .byte   0x00, 0x54, 0x60, 0x0E, 0x22, 0x6A, 0x01, 0x0E, 0xD3, 0xD1, 0x10, 0x29, 0x00, 0x06, 0xD1, 0x2A	| 4088A1A6
    .byte   0x00, 0x22, 0x70, 0x00, 0x4E, 0x75	| 4088A1B6

ENVINT_13C:             /* load the 'lmgr' resource (from the ROM map) and call it (6) */
    moveal %sp@+,%a0
    lea %sp@(-50),%sp
    movel %a0,%sp@-
    movew #-1,ROMMapInsert
    subqw #4,%sp
    pea 0x6c6d6772	/* 'lmgr' */
    clrw %sp@-
    _GetResource
    movel %sp@+,%d0
    jbeq ENVINT_172
    moveal %d0,%a0
    movel %a0,%sp@-
    clrl %sp@-
    clrl %sp@-
    pea 0x6
    moveal %a0@,%a0
    jsr %a0@(2)
    lea %sp@(12),%sp
    _ReleaseResource
ENVINT_172:             /* return */
    rts
    FILL_4088A1F4
PSTR_MPP_4088ABF0:      /* ".MPP" */
    .short  0x042E, 0x4D50, 0x5000	| 4088ABF0

/* PSTR_XPP: Pascal string ".XPP". */
PSTR_XPP:
    .short  0x042E, 0x5850, 0x5000, 0x0000, 0x0000	| 4088ABF6

/*
 PWRCNTRLPATCH: power control at start-up (before RAM): turn on the subsystems
 through the microcontroller, return through fp.
*/

/* PORTABLECHECK: Power Manager machine? (globals present) */
PWRCNTRLPATCH:
PORTABLECHECK:
    btst #24,%d2
    jbeq PWRCNTRLPATCH_2B8
    movel PmgrBase,%d0
    blew PWRCNTRLPATCH_26
    moveal %d0,%a2
    cmpil #1396789825,%a2@(274)	/* 'SARA': waking from sleep */
    jbne PWRCNTRLPATCH_26
    clrl %a2@(274)
    moveal %a2@(18),%a0	/* the wake-up routine (WAKEUP) */
    jmp %a0@
PWRCNTRLPATCH_26:       /* normal start-up: initialise the hardware (INITWALLYWORLD), then find the machine (hardware_table_lookup) */
    clrl %a2@(274)
    moveal %fp,%sp
    lea %pc@(PWRCNTRLPATCH_3A),%fp
    bigjmp INITWALLYWORLD, a1
PWRCNTRLPATCH_3A:       /* the machine's tables */
    moveq #0,%d2
    lea %pc@(PWRCNTRLPATCH_4A),%fp
    bigjmp hardware_table_lookup
PWRCNTRLPATCH_4A:       /* read the clock chip's byte 16 (RDXBYTE) */
    moveal %a0,%a4
    movel %d2,%d4
    moveq #16,%d1
    moveal %a0@(8),%a2
    lea %pc@(PWRCNTRLPATCH_62),%fp
    bigjmp RDXBYTE
PWRCNTRLPATCH_62:       /* 0xA8? the machine's power table value (+3) */
    moveq #-88,%d0
    subb %d1,%d0
    moveq #0,%d1
    tstb %d0
    jbne PWRCNTRLPATCH_A2
    moveq #115,%d1
    biglea CLKNOMEM_A16, a2
PWRCNTRLPATCH_78:       /* search the power table list */
    addqw #4,%a2
    movew %a2@+,%d0
    jbeq PWRCNTRLPATCH_8A
    cmpb %d4,%d0
    jbne PWRCNTRLPATCH_78
    addal %a2@,%a2
    addal %a2@,%a2
    moveb %a2@,%d1
    addqb #3,%d1
PWRCNTRLPATCH_8A:       /* read it again */
    moveal %a4,%a0
    moveal %a0@(8),%a2
    lea %pc@(PWRCNTRLPATCH_9E),%fp
    bigjmp RDXBYTE
PWRCNTRLPATCH_9E:       /* keep bit 1 */
    andib #2,%d1	| 4088AC9E
PWRCNTRLPATCH_A2:       /* machine 12 or 9: the power control register (+16384 of its I/O block) */
    movel %d4,%d2
    cmpib #12,%d2
    jbeq PWRCNTRLPATCH_C4
    cmpib #9,%d2
    jbne PWRCNTRLPATCH_F8
    moveal %a4,%a0
    moveal %a0@(88),%a1
    movel #212992,%d0
    btst #0,%a1@(0x0,%d0:l)
    jbeq PWRCNTRLPATCH_F4
PWRCNTRLPATCH_C4:       /* changed? tell the microcontroller (command 0xD0) */
    moveal %a4,%a0
    moveal %a0@(88),%a1
    moveq #2,%d2
    andb %a1@(16384),%d2
    cmpb %d1,%d2
    jbeq PWRCNTRLPATCH_F4
    moveb %d1,%a1@(16384)
    movew #208,%d3
    lea %pc@(PWRCNTRLPATCH_EA),%fp
    bigjmp USTPMGRSENDCOMMAND, a2
PWRCNTRLPATCH_EA:       /* wait */
    movel #262144,%d3	| 4088ACEA
PWRCNTRLPATCH_F0:       /* wait */
    subql #1,%d3	| 4088ACF0
    jbne PWRCNTRLPATCH_F0	| 4088ACF2
PWRCNTRLPATCH_F4:       /* on */
    jbra PWRCNTRLPATCH_1C8
PWRCNTRLPATCH_F8:       /* machine 10 */
    cmpib #10,%d2
    jbne PWRCNTRLPATCH_1C8
    orib #1,%d1
    btst #1,%d1
    jbne PWRCNTRLPATCH_118
    moveq #7,%d2
    andw %a1@(60),%d2
    subqw #5,%d2
    jbne PWRCNTRLPATCH_118
    bclr #0,%d1
PWRCNTRLPATCH_118:      /* its register (+16); command 0x171 */
    moveal %a1,%a0
    addal %a0@,%a0
    moveal %a0@(52),%a1
    moveq #-8,%d2
    andb %a1@(16),%d2
    orb %d2,%d1
    moveb %d1,%a1@(16)
    movel #369,%d3
    lea %pc@(PWRCNTRLPATCH_140),%fp
    bigjmp USTPMGRSENDCOMMAND, a2
PWRCNTRLPATCH_140:      /* then the device check below */
    moveal %sp,%a5
    bset #27,%d7
    lea %pc@(PWRCNTRLPATCH_14E),%fp
    jmp %pc@(PWRCNTRLPATCH_174)
PWRCNTRLPATCH_14E:      /* (raw) */
    bclr #27,%d7	| 4088AD4E
    jbra PWRCNTRLPATCH_1C8	| 4088AD52
PWRCNTRLPATCH_154:      /* (data: register values) */
    .long   0x09C00940, 0x044C0200, 0x03C00F00	| 4088AD54
    .long   0x00100010, 0x01000980, 0x044C03C0, 0x0F000010	| 4088AD60
    .long   0x00100100	| 4088AD70
PWRCNTRLPATCH_174:      /* a device with the signature 'RussSWC!' at 0xFEFFFFE4? set it up: 18 + 14 register writes at 0xFEE08000 */
    cmpil #1383428979,0xfeffffe4
    jbne PWRCNTRLPATCH_1C6
    cmpil #1398227745,0xfeffffe8
    jbne PWRCNTRLPATCH_1C6
    bset #1,0xfee00021
    lea 0xfee08000,%a0
    lea %pc@(PWRCNTRLPATCH_154),%a2
    moveq #18,%d1
    lea %pc@(PWRCNTRLPATCH_1A6),%a1
    jbra PWRCNTRLPATCH_1AE
PWRCNTRLPATCH_1A6:      /* the second set */
    addqw #2,%a0	| 4088ADA6
    moveq #14,%d1	| 4088ADA8
    lea %pc@(PWRCNTRLPATCH_1BE),%a1	| 4088ADAA
PWRCNTRLPATCH_1AE:      /* one register */
    moveb %a0@,%d2
    jbra PWRCNTRLPATCH_1B8
PWRCNTRLPATCH_1B2:      /* write a value (with delays) */
    movel %sp@,%sp@
    movel %sp@,%sp@
    moveb %a2@+,%a0@
PWRCNTRLPATCH_1B8:      /* count down */
    dbf %d1,PWRCNTRLPATCH_1B2
    jmp %a1@
PWRCNTRLPATCH_1BE:      /* (data) */
    .short  0x08B9, 0x0001, 0xFEE0, 0x0021	| 4088ADBE
PWRCNTRLPATCH_1C6:      /* return through a6 */
    jmp %fp@
PWRCNTRLPATCH_1C8:      /* the machine's tables again; machines 12 and 10: more */
    moveal %sp,%fp
    moveal %fp,%sp
    moveq #0,%d2
    lea %pc@(PWRCNTRLPATCH_1DC),%fp
    bigjmp hardware_table_lookup
PWRCNTRLPATCH_1DC:
    cmpib #12,%d2	| 4088ADDC
    jbeq PWRCNTRLPATCH_1F6	| 4088ADE0
    cmpib #10,%d2	| 4088ADE2
    jbne PWRCNTRLPATCH_2B2	| 4088ADE6
    moveal %a0@(52),%a2	| 4088ADEA
    bset #3,%a2@(33)	| 4088ADEE
    jbra PWRCNTRLPATCH_21C	| 4088ADF4
PWRCNTRLPATCH_1F6:
    movel #-369097760,%d3	| 4088ADF6
    lea %pc@(PWRCNTRLPATCH_20A),%fp	| 4088ADFC
PWRCNTRLPATCH_200:      /* (raw) */
    lea 0xfffbc858,%a2	| 4088AE00
    jmp %pc@(PWRCNTRLPATCH_200,%a2:l)	| 4088AE06
PWRCNTRLPATCH_20A:      /* (data) */
    .byte   0x16, 0x3C, 0x00, 0x0A, 0x4B, 0xFA, 0x00, 0x0C, 0x49, 0xF9, 0xFF, 0xFB, 0xC8, 0xC8, 0x4E, 0xFB	| 4088AE0A
    .byte   0xC8, 0xF8	| 4088AE1A
PWRCNTRLPATCH_21C:
    moveal %a0@(56),%a0	| 4088AE1C
    moveal %sp,%a5	| 4088AE20
    bset #27,%d7	| 4088AE22
    lea %pc@(PWRCNTRLPATCH_22E),%fp	| 4088AE26
    jmp %pc@(PWRCNTRLPATCH_252)	| 4088AE2A
PWRCNTRLPATCH_22E:      /* (data) */
    .byte   0x66, 0x00, 0x00, 0x82, 0x70, 0x07, 0xC0, 0x28, 0x00, 0x01, 0xC0, 0xFC, 0x00, 0x0B, 0x45, 0xFA	| 4088AE2E
    .byte   0x00, 0x1C, 0xD5, 0xC0, 0x56, 0x48, 0x20, 0xDA, 0x20, 0xDA, 0x41, 0xE8, 0x00, 0x12, 0x10, 0xDA	| 4088AE3E
    .byte   0x30, 0xDA, 0x60, 0x60	| 4088AE4E
PWRCNTRLPATCH_252:
    moveb %a0@(1),%d0	| 4088AE52
    moveq #0,%d0	| 4088AE56
    jmp %fp@	| 4088AE58
    .byte   0x10, 0x00, 0x64, 0x00, 0x80, 0x02, 0x00, 0xA0, 0x00, 0x00, 0x03, 0x12, 0x00, 0x64, 0x00, 0x80	| 4088AE5A
    .byte   0x02, 0x00, 0xFF, 0x00, 0x00, 0x03, 0x10, 0x00, 0x64, 0x00, 0x80, 0x02, 0x00, 0xFF, 0x00, 0x00	| 4088AE6A
    .byte   0x03, 0x10, 0x00, 0x64, 0x00, 0x80, 0x02, 0x00, 0xA0, 0x00, 0x00, 0x03, 0x10, 0x00, 0x64, 0x00	| 4088AE7A
    .byte   0x80, 0x05, 0x00, 0xA0, 0x00, 0x00, 0x03, 0x10, 0x00, 0x64, 0x00, 0x80, 0x05, 0x00, 0xA0, 0x00	| 4088AE8A
    .byte   0x00, 0x03, 0x10, 0x00, 0x63, 0x00, 0x80, 0x05, 0x00, 0x9C, 0x00, 0x00, 0x03, 0x10, 0x00, 0x64	| 4088AE9A
    .byte   0x00, 0x80, 0x05, 0x00, 0xA0, 0x00, 0x00, 0x03	| 4088AEAA
PWRCNTRLPATCH_2B2:      /* return through a6 */
    bclr #27,%d7	| 4088AEB2
    moveal %sp,%fp	| 4088AEB6
PWRCNTRLPATCH_2B8:      /* return through a6 */
    jmp %fp@

/*
 BACKLIGHTPATCH: at start-up, install the backlight driver ('DRVR' -16511) on
 machines that have one.
*/
BACKLIGHTPATCH:
    jbsr BKLIGHTINSTALL
    moveal %sp@+,%a0
    subqw #4,%sp
    movel #1397051972,%sp@-	/* 'SERD' */
    jmp %a0@

/* BKLIGHTINSTALL: install and open the .Backlight driver. */
BKLIGHTINSTALL:
    moveml %d0-%d3/%a0-%a3,%sp@-
    btst #0,HWCfgFlags
    jbeq BKLIGHTINSTALL_70
    movel #1146246738,%d1	/* 'DRVR' */
    movew #-16511,%d2
    jbsr BKLIGHTINSTALL_76
    jbeq BKLIGHTINSTALL_66
    moveal UTableBase,%a0
    movel #188,%d3
BKLIGHTINSTALL_24:      /* find a free unit table entry (from 48) */
    addql #4,%d3
    tstl %a0@(0x0,%d3:w)
    jbne BKLIGHTINSTALL_24
    movel %d3,%d0
    lsrl #2,%d0
    addql #1,%d0
    negl %d0
    _DrvrInstall
    tstl %d0
    jbne BKLIGHTINSTALL_6C
    moveal %a0@(0x0,%d3:w),%a3
    moveal %a3@,%a3
    movel %a1,%a3@
    moveal %a1@,%a1
    .short  0x3751	| 4088AF0C
    .short  0x0004, 0x3769	| orib #105,%d4
    orib #34,%d2
    movew %a1@(4),%a3@(36)
    movew %a1@(6),%a3@(38)
    bset #6,%a3@(5)
    lea %pc@(PSTR_Backlight),%a1
    jbsr BKLIGHTINSTALL_86
BKLIGHTINSTALL_66:      /* restore registers, return */
    moveml %sp@+,%d0-%d3/%a0-%a3
    rts
BKLIGHTINSTALL_6C:      /* could not install: free it */
    moveal %a1,%a0
    _DisposHandle
BKLIGHTINSTALL_70:      /* restore registers, return */
    moveml %sp@+,%d0-%d3/%a0-%a3
    rts

BKLIGHTINSTALL_76:      /* GetResource(d1, d2), detached: a1 */
    subql #4,%sp
    movel %d1,%sp@-
    movew %d2,%sp@-
    _GetResource
    moveal %sp@,%a1
    _DetachResource
    movel %a1,%d0
    rts

BKLIGHTINSTALL_86:      /* open the driver named at a1 */
    moveml %d1-%d2/%a0-%a3,%sp@-
    subaw #50,%sp
    moveal %sp,%a0
    movel %a1,%a0@(18)
    clrb %a0@(27)
    _Open
    lea %sp@(50),%sp
    moveml %sp@+,%d1-%d2/%a0-%a3
    rts

/* PMGRPOWEROFFPATCH: power off through the microcontroller (PowerBooks). */
PMGRPOWEROFFPATCH:
    btst #0,HWCfgFlags
    jbeq PMGRPOWEROFFPATCH_4E
    clrl %sp@-
    clrl %sp@-
    clrw %sp@-
    movew #33,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    _HideCursor
    clrl WarmStart
    pea 0x4d415454	/* 'MATT' */
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #4,%sp@-
    movew #126,%sp@-	/* command 0x7E (power off) */
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(16),%sp
    jbne PMGRPOWEROFFPATCH_3E
PMGRPOWEROFFPATCH_3C:   /* (wait for the power to go off) */
    jbra PMGRPOWEROFFPATCH_3C
PMGRPOWEROFFPATCH_3E:   /* the command failed: sleep now, then restart */
    movew #6,%d0
    _Sleep
    bigjsr reset_startup
PMGRPOWEROFFPATCH_4E:   /* return */
    rts

/* DARTMODEMCMDS / DARTSPI: internal modem and serial port power commands (Dartanian). */
DARTMODEMCMDS:
    cmpiw #80,%a0@
    bnes DARTSPI
    moveq #1,%d1
    rts
DARTSPI:                /* the entry */
    moveal PmgrBase,%a3
    btst #2,%a3@(296)
    bnes DARTSPI_10
    moveq #1,%d1
    rts

DARTSPI_10:             /* send a command to the microcontroller through the "SPI" lines of the I/O block (+90112): command, count (if needed), data; then read the reply */
    moveml %d1-%d4/%a0-%a3,%sp@-
    moveal 0xdd8,%a2
    addal %a2@,%a2
    moveal %a2@(88),%a2
    addal #90112,%a2
    movew %a0@,%d3
    movew %d3,%d1
    jbsr DARTSPI_DE
    jbne DARTSPI_92
    moveal PmgrBase,%a1
    moveal %a1@(262),%a1
    movew %a0@(2),%d2
    tstb %a1@(0x0,%d3:w)
    jbpl DARTSPI_48
    movew %d2,%d1
    jbsr DARTSPI_DE
    jbne DARTSPI_92
DARTSPI_48:             /* the data bytes */
    moveal %a0@(4),%a3
    moveq #0,%d1
    jbra DARTSPI_56
DARTSPI_50:             /* next byte */
    moveb %a3@+,%d1
    jbsr DARTSPI_DE
DARTSPI_56:             /* count down */
    dbne %d2,DARTSPI_50
    jbne DARTSPI_92
    moveal PmgrBase,%a1
    moveal %a1@(266),%a1
    moveq #0,%d4
    moveb %a1@(0x0,%d3:w),%d4
    jbmi DARTSPI_76
    cmpib #1,%d4
    jble DARTSPI_7E
    subqw #1,%d4
    jbra DARTSPI_7E
DARTSPI_76:             /* variable reply length: read it */
    jbsr DARTSPI_102
    jbne DARTSPI_92
    movew %d1,%d4
DARTSPI_7E:             /* the reply */
    moveal %a0@(8),%a3
    movew %d4,%a0@(2)
    jbra DARTSPI_8E
DARTSPI_88:             /* read a byte */
    jbsr DARTSPI_102
    jbne DARTSPI_92
    moveb %d1,%a3@+
DARTSPI_8E:             /* count down */
    dbf %d4,DARTSPI_88
DARTSPI_92:             /* restore registers, return */
    moveq #0,%d1
    moveml %sp@+,%d1-%d4/%a0-%a3
    rts

DARTSPI_9A:             /* wait for the line (bit 2) to go high */
    moveml %d1-%d2,%sp@-
    movew #32,%d2
DARTSPI_A2:             /* (TimeDBRA loops) */
    movew TimeDBRA,%d1
DARTSPI_A6:             /* wait */
    btst #2,%a2@
    dbne %d1,DARTSPI_A6
    dbne %d2,DARTSPI_A2
    seq %d0
    tstb %d0
    moveml %sp@+,%d1-%d2
    rts

DARTSPI_BC:             /* wait for it to go low */
    moveml %d1-%d2,%sp@-
    movew #32,%d2
DARTSPI_C4:             /* (TimeDBRA loops) */
    movew TimeDBRA,%d1
DARTSPI_C8:             /* wait */
    btst #2,%a2@
    dbeq %d1,DARTSPI_C8
    dbeq %d2,DARTSPI_C4
    sne %d0
    tstb %d0
    moveml %sp@+,%d1-%d2
    rts

DARTSPI_DE:             /* send byte d1 */
    jbsr DARTSPI_9A
    jbne DARTSPI_FC
    bset #4,%a2@(3072)
    moveb %d1,%a2@(2048)
    bclr #3,%a2@
    jbsr DARTSPI_BC
    jbne DARTSPI_FC
    bset #3,%a2@
    clrw %d0
    rts
DARTSPI_FC:             /* -13002 (pmSendStartErr) */
    movew #-13002,%d0
    rts

DARTSPI_102:            /* read a byte into d1 */
    jbsr DARTSPI_9A
    jbne DARTSPI_124
    bclr #4,%a2@(3072)
    bclr #3,%a2@
    jbsr DARTSPI_BC
    jbne DARTSPI_124
    bset #3,%a2@
    jbsr DARTSPI_9A
    jbne DARTSPI_124
    moveb %a2@(2048),%d1
    clrw %d0
    rts
DARTSPI_124:            /* -13004 (pmRecvStartErr) */
    movew #-13004,%d0
    rts
    FILL_4088B0F0

/* PSTR_Backlight: Pascal string ".Backlight". */
PSTR_Backlight:
    .ascii  "\012.Backlight\000"
    .long   0x00000000	| 4088BBFC
