/*
 boot/patchspace2.s - patch space 2: start-up patches
 From PATCHSPACE2 (0x40801250). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.
*/

/*
 OPENNETBOOTPATCH: install the Sony (floppy) driver, then open the ".netBOOT" driver if
 a 'DRVR' resource of that name exists (a0 = the caller's parameter block).
*/
PATCHSPACE2:
OPENNETBOOTPATCH:
    bsrl INSTALLSONYDRIVERPATCH
    movel %a0,%sp@-
    subqw #4,%sp
    movel #1146246738,%sp@-
    pea %pc@(PSTR_netBOOT)
    _GetNamedResource
    tstl %sp@+
    moveal %sp@+,%a0
    jbeq PATCHSPACE2_26
    lea %pc@(PSTR_netBOOT),%a1
    movel %a1,%a0@(18)
    _Open
PATCHSPACE2_26:         /* not there: nothing to open */
    rts
PSTR_netBOOT:           /* Pascal string ".netBOOT" */
    .byte   0x08	| 40801278
    .ascii  ".netBOOT\000"

/*
 FMCPARITYPATCH: move.w #0xF3EF,%d5, btst #20,%d0, beq +4,
 move.w #0xF3FF,%d5, rts: the FMC configuration value, with the parity bit set or
 not by bit 20 of d0 (the machine's parity flag, presumably).
*/
FMCPARITYPATCH:
    movew #-3089,%d5
    btst #20,%d0
    beqs FMCPARITYPATCH_E
    movew #-3073,%d5
FMCPARITYPATCH_E:
    rts

/* FLAGSPATCH: fill low memory 0x100..0x1FFF with 0xFFFFFFFF, keeping HWCfgFlags. */
FLAGSPATCH:
    movew HWCfgFlags,%sp@-
    lea MonkeyLives,%a0
    lea 0x2000,%a1
    jbsr FILLWITHONES
    movew %sp@+,HWCfgFlags
    rts

/*
 INITEGRETPATCH: if the machine has an Egret (CHECKFOREGRET), set up its early globals in
 a 76-byte block on the stack (INITEGRETALT). Then read parameter RAM (GETPRAM), install
 the Elsie 24 to 32 bit translation if 0xDD7 bit 7 says so, and return to EGRETPATCHCONT.
*/
INITEGRETPATCH:
    jsr %pc@(CHECKFOREGRET)
    jbne INITEGRETPATCH_16
    subaw #76,%sp
    moveal %sp,%a0
    bigjsr INITEGRETALT, a1
INITEGRETPATCH_16:      /* parameter RAM, keyboard and mouse timings */
    jbsr GETPRAM
    btst #7,0xdd7
    jbeq INITEGRETPATCH_30
    biglea ELSIETRANSLATE24TO32
    movel %a0,0x644
INITEGRETPATCH_30:      /* back to the start-up sequence */
    jmp %pc@(EGRETPATCHCONT)
    .long   0x00000000	| 408012DC

/*
 INITEGRETPATCH1: Power Manager, then the Egret Manager (dropping the stack block of
 INITEGRETPATCH), the Resource Manager, and back to EGRETPATCH1CONT.
*/
INITEGRETPATCH1:
    jbsr POWERMNGR
    jsr %pc@(CHECKFOREGRET)
    jbne INITEGRETPATCH1_16
    lea %sp@(76),%sp
    jbsr EGRETMGR
INITEGRETPATCH1_16:     /* Resource Manager */
    jbsr INITRSRCMGR
    jmp %pc@(EGRETPATCH1CONT)
    .short  0x0000	| 408012FE

/* GOTOINITMMU: jump to INITMMU (a 32-bit PC-relative jump). */
thunk_FUN_408814f2:
GOTOINITMMU:
    lea (INITMMU-thunk_FUN_408814f2):l,%a4
    jmp %pc@(thunk_FUN_408814f2,%a4:l)

/*
 CLOSENETBOOTPATCH: close the .netBOOT driver (refnum -50) after a failed network boot,
 forget the AppleTalk hooks and restart the boot (BOOTRETRY).
*/
CLOSENETBOOTPATCH:
    lea %fp@(-1024),%a0
    movew #-50,%a0@(24)
    _Close
    moveq #-1,%d0
    movel %d0,AGBHandle
    movel %d0,ATalkHk2
    jbra BOOTRETRY

/*
 CHECKFOREGRET: Z set if the machine has an Egret (or Cuda): from the hardware
 configuration flags at 0xDD4 (bits 1-3 = 6, or bits 4-6 = 2).
*/
CHECKFOREGRET:
    moveq #14,%d0
    andl 0xdd4,%d0
    subql #6,%d0
    jbeq CHECKFOREGRET_14
    moveq #112,%d0
    andl 0xdd4,%d0
    cmpib #32,%d0
CHECKFOREGRET_14:       /* Z = the result */
    rts
    .short  0x0000, 0x0000, 0x0000	| 4080133A
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40801340
