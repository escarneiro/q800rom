/*
 boot/startinit.s - cold start: from STARTBOOT (0x4080008C) to MYBOOT, 0x4080008C..0x4080037F

 Names in upper case are Apple's (MPW ROM map); ROUTINE_offset labels are positions
 inside an Apple routine. Labels that are referenced from data elsewhere in the ROM
 (most likely numbers mistaken for addresses) keep their generated names for now.
 Most of the work happens in the routines called from here; this file is the order in
 which the ROM brings up the machine.

 Comments in boot/, os/, toolbox/, quickdraw/, sound/, hw/, video/, patches/ and diag/
 were inferred from the code and the Inside Macintosh documentation, not taken from Apple.
 Low memory used here (names where known): 0xDD0/0xDD4 hardware configuration flags
 from the machine tables, 0xDD8 UnivInfoPtr (ProductInfo), 0xDDC the boot globals
 pointer (top of the boot globals area), 0x1EFC MMU/memory mode flags.
*/

reset_startup:          /* cold start (initial PC, and every "restart" jump) */
STARTBOOT:              /* set %sr */
    movew   #0x2700,%sr             /* supervisor mode, all interrupts masked */
    lea     %pc@(hardware_reset),%fp
    jbra    early_cpu_detect        /* DISABLEMMUPATCH: caches and MMU off (returns via %fp) */
    .long   0x00000000

hardware_reset:         /* reset the I/O devices, temporary vectors in ROM */
    reset                           /* reset the external devices */
    lea     %pc@(si_after_vbr),%fp
    jmp     %pc@(setup_early_vbr)   /* JUMPINTOROM: temporary vector table in ROM */
si_after_vbr:           /* power control setup */
    lea     %pc@(si_after_power),%fp
    bigjmp  PWRCNTRLPATCH           /* power control setup (returns via %fp) */
si_after_power:         /* continue in the machine-specific start code */
    jbra    thunk_FUN_40847082

/* Identify the machine and set up the hardware */
STARTINIT1:
    moveq   #0,%d2
    moveml  %d5-%d7/%a5-%fp,%sp@-
    lea     %pc@(si_have_hwinfo),%fp
    jmp     %pc@(hardware_table_lookup) /* GETHARDWAREINFO: %a0 = machine description */
si_have_hwinfo:         /* a4 = VIA 1 base (from the machine description), d4 = its bit 6 */
    moveal  %a0@(8),%a4
    moveq   #0x40,%d4
    andb    %a4@,%d4
    lea     %pc@(si_vias_done),%fp
    jmp     %pc@(INITVIAS)
si_vias_done:           /* machine type 5: keep VIA 1 bit 6 as it was before INITVIAS */
    cmpib   #5,%d2
    jbne    si_validate_pram
    moveq   #-65,%d3                /* clear bit 6, then copy it from %d4 */
    andb    %a4@,%d3
    orb     %d4,%d3
    moveb   %d3,%a4@
si_validate_pram:       /* check parameter RAM, keeping the registers */
    moveml  %d0-%d2/%a0-%a3,%sp@-
    lea     %pc@(si_pram_done),%fp
    bigjmp  VALIDATEPRAM, a5        /* check parameter RAM (returns via %fp) */
si_pram_done:           /* restore the registers */
    moveml  %sp@+,%d0-%d2/%a0-%a3
    moveml  %sp@+,%d5-%d7/%a5-%fp
STARTINIT1_46:          /* CPU, logic board, RAM configuration, machine-specific setup */
    jbsr    WHICHCPU
    jbsr    WHICHBOARD
    jbsr    CONFIGURERAM
    jbsr    thunk_FUN_408814f2

/* Record the memory configuration in low memory */
    moveal  %a4@(-20),%fp           /* top of RAM */
    moveal  %a4,%a5
STARTINIT1_5C:          /* a5 = top of usable RAM below the boot globals (BufPtr) */
    addal   %a4@(-12),%a5
    movel   %d0,0xdd0               /* hardware configuration from the machine tables */
    movel   %d1,0xdd4
STARTINIT1_68:          /* UnivInfoPtr, HWCfgFlags, the hardware base addresses and routines */
    movel   %a1,0xdd8
    swap    %d2
    movew   %d2,HWCfgFlags
    swap    %d2
    jbsr    SETUPHWBASES
    bsrl    INITHWROUTINES
    nop
    nop
    nop
    movel   WarmStart,%sp@-
    movel   0xdd0,%sp@-
    movel   0xdd4,%sp@-
    movel   0xdd8,%sp@-
    jsr     %pc@(FLAGSPATCH)
    movel   %sp@+,0xdd8
STARTINIT1_9C:          /* FLAGSPATCH may have changed the flags on the stack: take them back */
    movel   %sp@+,0xdd4
    movel   %sp@+,0xdd0
    movel   %sp@+,WarmStart
STARTINIT1_A8:          /* base addresses again (with the patched flags) */
    jbsr    SETUPHWBASES
STARTINIT1_AC:          /* CPUFlag, the second WHICHCPU byte, MemTop, BufPtr, boot globals */
    moveb   %d7,CPUFlag
    swap    %d7
    moveb   %d7,0xcb3
    movel   %fp,MemTop
    movel   %a5,BufPtr
    movel   %a4,0xddc

/* Memory management, caches, error handling */
    jbsr    INITMMUGLOBALS
STARTINIT1_C6:          /* system error handler, caches on */
    jbsr    SYSERRINITPATCH
    nop
    nop
    jbsr    ENABLECACHESPATCH
    jbra    si_after_caches
    .long   0x00000000
si_after_caches:        /* cache flushing setup */
    jbsr    caseD_4
    bsrl    cache_flush_setup       /* SETUPTIMEKPATCH */
    jbra    si_hi_globals
    .long   0x00000000
    .short  0x0000
si_hi_globals:          /* globals at the top of memory */
    jbsr    INITHIMEMGLOBALS

/* Restart point: the rest of the system software environment */
BOOTRETRY:              /* also the restart point of a failed boot */
    movew   #0x2700,%sr
    moveq   #1,%d0
    moveal  JSwapMMU,%a0
    jsr     %a0@
    jsr     %pc@(INITGLOBALVARS)
    bigjsr  DISABLEINTSOURCES
    bigjsr  INITINTHANDLER
    bigjsr  init_trap_dispatcher    /* INITDISPATCHER: build the trap tables */
    jbsr    MMUSTUFF
    jbra    INITEGRETPATCH

EGRETPATCHCONT:         /* back from INITEGRETPATCH: Memory Manager */
    jbsr    INITMEMMGRPATCH
EGRETPATCHCONT_4:       /* 0x1EFC bit 0 set: install the 24 to 32 bit translation routine (0x644) */
    btst    #0,0x1efc
    jbeq    si_mmu_mode
    lea     %pc@(NEWTRANSLATE24TO32),%a0
    movel   %a0,0x644
si_mmu_mode:            /* 24-bit mode, system and application zones, switcher table */
    moveq   #0,%d0
    _SwapMMUMode
    jbsr    SETUPSYSAPPZONE
    jbsr    INITSWITCHERTABLE
    jbra    INITEGRETPATCH1

EGRETPATCH1CONT:        /* back from INITEGRETPATCH1: managers, slots, interrupts on */
    lea     (NMINIT-EGRETPATCH1CONT):l,%a0
    jsr     %pc@(EGRETPATCH1CONT,%a0:l)    /* Notification Manager */
    bigjsr  INITTIMEMGR
    jbsr    INITMEMDISPANDSHUTDOWNMGRS
    bigjsr  INITSLOTS
    jbsr    INITDTQUEUE
    bigjsr  ENABLEONESECINTS
    bigjsr  ENABLEPARITYPATCH
    movew   #0x2000,%sr             /* interrupts on */
EGRETPATCH1CONT_3E:     /* video globals, boot stack, application limit below the stack */
    jbsr    INITVIDGLOBALS
    jbsr    COMPBOOTSTACK
    moveal  %a0,%sp
    subaw   #0x2000,%a0
    moveb   0x1efc,%sp@-
    btst    #2,0x1efc
    jbeq    si_clear_flag
    bset    #0,0x1efc
    jbra    si_set_limit
si_clear_flag:          /* 0x1EFC bit 0 = bit 2 while SetApplLimit runs */
    bclr    #0,0x1efc
si_set_limit:           /* then drive queue, SCSI, I/O */
    _SetApplLimit
    moveb   %sp@+,0x1efc
    lea     DrvQHdr,%a1
    bigjsr  INITQUEUE               /* empty drive queue */
    bigjsr  SCSIINIT
    jbsr    INITIOMGR

/* Expanded low memory: 490 bytes, version 0x123 */
    movel   #490,%d0
    .short  0xA71E	| 4080028E _NewPtr ,SYS,CLEAR
    movel   %a0,ExpandMem
    movew   #0x123,%a0@+
    movel   #490,%a0@

    bigjsr  INITCRSRDEV
    jbsr    INITCRSRMGR
    bigjsr  INITGESTALT
    bigjsr  ECLIPSEEGRETPATCHES
EGRETPATCH1CONT_C0:     /* TextEdit globals */
    bigjsr  TEGLOBALINIT

/* Application heap above the system heap */
    moveal  SysZone,%a0
    moveal  %a0@,%a0
    addaw   #0x4000,%a0
    _SetApplBase
    moveal  SysZone,%a0
    movel   %a0,TheZone
    movel   %a0,ApplZone
    movel   %a0@,HeapEnd
    lea     %sp@(1024),%fp
    lea     %sp@(400),%a5
    bigjsr  ENABLESLOTINTS
    jbsr    POWERDWNPTCH
    jbsr    check_zap_pram
    movel   #0x574C5343,WarmStart   /* 'WLSC': started once */
    moveq   #1,%d0
    _SwapMMUMode
    moveal  0xddc,%a0
EGRETPATCH1CONT_10E:    /* 'WLSC' at the boot globals too (32-bit mode) */
    movel   #0x574C5343,%a0@(-4)
    _SwapMMUMode
    bigjsr  SOUNDINITPATCH
SOUNDINITPATCHRTN:      /* sound initialised: boot */
    jbra    MYBOOT                  /* continue with the boot process */

/*
 check_zap_pram: if exactly Command-Option-P-R are held down, reset parameter RAM and
 restart. The 4 bytes of extended parameter RAM at 0xB8 are kept.
*/
check_zap_pram:
    lea     %pc@(zap_pram_keys),%a1
    lea     KeyMap,%a0
SOUNDINITPATCHRTN_C:    /* label inside check_zap_pram */
    moveq   #3,%d0                  /* compare 4 longs = the whole KeyMap */
czp_compare:            /* compare KeyMap with zap_pram_keys */
    cmpml   %a0@+,%a1@+
    dbne    %d0,czp_compare
    jbeq    czp_zap
    rts
czp_zap:                /* they match: reset parameter RAM */
    subqw   #4,%sp
    moveal  %sp,%a0
    movel   #0x000400B8,%d0         /* 4 bytes at XPRAM 0xB8: save them */
    _ReadXPRam
    moveal  %a1,%a0
    movel   %a0@+,%d0               /* 4 bytes at XPRAM 0x0C: "Gone" over the signature */
    _WriteXPRam
    lea     SPValid,%a0
    moveq   #-1,%d0
    moveb   %d0,%a0@                /* parameter RAM copy no longer valid */
    _WriteParam
    _InitUtil                       /* reinitialize parameter RAM */
    moveal  %sp,%a0
    movel   #0x000400B8,%d0         /* restore XPRAM 0xB8 */
    _WriteXPRam
    jmp     %pc@(reset_startup)     /* restart */

/* KeyMap with key codes 15 (R), 35 (P), 55 (Command) and 58 (Option) down */
zap_pram_keys:          /* Command-Option-P-R, then the XPRAM write */
    .byte   0x00, 0x80, 0x00, 0x00, 0x08, 0x00, 0x80, 0x04
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
/* XPRAM write descriptor (count 4, address 0x0C) and the data */
    .long   0x0004000C
    .ascii  "Gone"
    .short  0x0000
