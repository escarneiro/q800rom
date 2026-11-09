/*
 patches/overpatches.s - ROM patches
 From OVERPATCH (0x4084BEF0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple.
*/

/*
 FINDDEVBASEPATCH: sFindDevBase: with sRsrcFlags bit 2 (32-bit base), combine the
 slot's base (top byte of d2) with the offset d1.
*/
OVERPATCH:
FINDDEVBASEPATCH:
    movew %a0@(2),%d0
    btst #2,%d0
    jbeq OVERPATCH_12
    andil #-16777216,%d2
    orl %d1,%d2
OVERPATCH_12:           /* return */
    rts

/*
 SEPARITYPATCH: was the interrupt a parity error? On machines with parity in VIA 1
 (0xDD2 bit 5, 0xDD7 bit 0) check and acknowledge the VIA bits; on those with an RPU
 (0xDD1 bit 4) check its status, reset it. Out: d1 = 1 if it was parity.
*/
SEPARITYPATCH:
    btst #5,0xdd2
    jbeq SEPARITYPATCH_34
    btst #0,0xdd7
    jbeq SEPARITYPATCH_68
    moveal VIA,%a0
    btst #6,%a0@
    jbne SEPARITYPATCH_68
    bclr #7,%a0@(1024)
    moveb %a0@,%d1
    bset #7,%a0@(1024)
    btst #7,%d1
    jbne SEPARITYPATCH_68
    bset #6,%a0@
    jbra SEPARITYPATCH_64
SEPARITYPATCH_34:       /* RPU machines */
    btst #4,0xdd1
    jbeq SEPARITYPATCH_68
    moveal ghost_VIA2,%a0
    movew %a0@(514),%d1
    btst #14,%d1
    jbeq SEPARITYPATCH_68
    clrb %a0@(14)
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(80),%a0
    st %a0@(16)
    movel %a0@,%d1
    bset #16,%d1
    movel %d1,%a0@
SEPARITYPATCH_64:       /* parity error: 1 */
    moveq #1,%d1
    rts
SEPARITYPATCH_68:       /* not parity: 0 */
    moveq #0,%d1
    rts

/* ENABLEPARITYPATCH: enable the 60 Hz and the parity interrupts. */
ENABLEPARITYPATCH:
    bigjsr ENABLE60HZINTS
    bigjsr ENABLEPARITYINTS
    rts

/*
 RSRCMGRPATCH: which set of ROM resources to use (the "default resources" number of
 ProductInfo +22 when the caller gives none or a higher one; 4 becomes 3 on machines
 with HWCfgFlags bit 4).
*/
RSRCMGRPATCH:
    tstb %d3
    jbeq RSRCMGRPATCH_A
    cmpb %a2@(4),%d3
    jble RSRCMGRPATCH_12
RSRCMGRPATCH_A:         /* the machine's default */
    moveal 0xdd8,%a0
    moveb %a0@(22),%d3
RSRCMGRPATCH_12:        /* 4 with HWCfgFlags bit 4: 3 */
    cmpib #4,%d3
    jbne RSRCMGRPATCH_22
    btst #4,HWCfgFlags
    jbeq RSRCMGRPATCH_22
    moveq #3,%d3
RSRCMGRPATCH_22:        /* return */
    rts

/*
 DELSEARCHPATCH / DELCOMPPATCH: translate the 24-bit address to 32 bits (vector 0x644),
 then the search / compare procedure of the main device's color table (MainDevice
 +12 / +16).
*/
DELSEARCHPATCH:
    movel %sp@(8),%d1
    exg %d0,%d1
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x644,%za0)@(0x0)	| 4084BFB0
    exg %d0,%d1
    moveal @(TheGDevice,%za0)@(0),%a1	| 4084BFB8
    lea %a1@(12),%a1
    movel %a1@,%d2
    rts

DELCOMPPATCH:           /* set %d1 */
    movel %sp@(8),%d1
    exg %d0,%d1
    jsr @(0x644,%za0)@(0x0)	| 4084BFCC
    exg %d0,%d1
    moveal @(TheGDevice,%za0)@(0),%a1	| 4084BFD4
    lea %a1@(16),%a1
    movel %a1@,%d2
    rts

/*
 OPENPATCH: _Open: drivers opened with permission 0x40, or when FSFCBLen is negative
 (no File Manager yet), go to the driver open; others to the file open.
*/
OPENPATCH:
    moveml %sp@+,%d3-%d5/%a2-%a4
    cmpib #64,%a0@(27)
    jbeq OPENPATCH_1C
    tstw FSFCBLen
    jbmi OPENPATCH_1C
    bigjmp OPENPATCHRTN, a1
OPENPATCH_1C:           /* driver open */
    bigjmp OPENPATCHRTN1, a1

/*
 SOUNDINITPATCH: start the Sound Manager (globals, interrupts, _SoundDispatch, MACE),
 compute 0x1EF8 from the boot globals in 32-bit mode, install the 68040 BlockMove
 (cache-safe) as _BlockMove, the docking and SCSI disk mode set-up, and continue the
 start-up (SOUNDINITPATCHRTN).
*/
SOUNDINITPATCH:
    moveml %d0-%d2/%a0-%a2/%fp,%sp@-
    bigjsr INITGLOBALS, a1
    bigjsr SOUNDINTERRUPTS, a1
    bigjsr INITSNDDISPATCH, a1
    bigjsr INITMACEDISPATCH, a1
    moveml %sp@+,%d0-%d2/%a0-%a2/%fp
    moveb #1,%d0
    _SwapMMUMode
    .short  0x2230, 0x81E2, 0x0DDC, 0xFFBA	| movel @(0xddc)@(0xffffffffffffffba),%d1
    .short  0xD2B0, 0x81E2, 0x0DDC, 0xFFEC	| addl @(0xddc)@(0xffffffffffffffec),%d1
    movel %d1,0x1ef8
    _SwapMMUMode
    cmpib #4,CPUFlag
    jblt SOUNDINITPATCH_64
    movew #-24530,%d0
    biglea trap_BlockMove
    _SetTrapAddress
SOUNDINITPATCH_64:      /* then UNLOADSEGPATCH_62 */
    jbsr UNLOADSEGPATCH_62
    bigjmp SOUNDINITPATCHRTN

/*
 VISACONFIGURERAMPATCH: RAM configuration for the VISA decoder machines: compute the
 RAM size code for the decoder's register from the bank sizes and move the pointers
 that are in the remapped RAM range (partly raw words).
*/
VISACONFIGURERAMPATCH:
    cmpil #-1,%d3
    beqw VISACONFIGURERAMPATCH_9C
    movel %a3,%d5
    cmpil #-1,%d4
    beqs VISACONFIGURERAMPATCH_24
    addl %a4,%d5
    movel %d5,%fp@(4)
    movel #-1,%fp@(8)
    bras VISACONFIGURERAMPATCH_2C
VISACONFIGURERAMPATCH_24:
    movel %d3,%d4
    moveal %a3,%a4
    subal %a3,%a3
    movel %a3,%fp@
VISACONFIGURERAMPATCH_2C:
    swap %d5
    cmpiw #160,%d5
    jbhi VISACONFIGURERAMPATCH_9C
    lsrw #4,%d5
    moveb %pc@(VISACONFIGURERAMPATCH_80+0x1:w,%d5:w),%d3	| 4084C0B0
    cmpib #0xff,%d3
    jbne VISACONFIGURERAMPATCH_4A
    movel #-1,%fp@
    jbra VISACONFIGURERAMPATCH_9C
VISACONFIGURERAMPATCH_4A:  /* move fp, the stack, the return address into the new map */
    moveal %fp,%a2
    jbsr VISACONFIGURERAMPATCH_8C
    moveal %a2,%fp
    lea %pc@(VISACONFIGURERAMPATCH_9C),%a2
    jbsr VISACONFIGURERAMPATCH_8C
    moveal %a2,%a5
    moveal %sp@,%a2
    jbsr VISACONFIGURERAMPATCH_8C
    movel %a2,%sp@
    moveal %sp,%a2
    subqw #2,%sp
    jbsr VISACONFIGURERAMPATCH_8C
    exg %a2,%sp
    lea %pc@(VISACONFIGURERAMPATCH_6C),%a3
    jbra VISACONFIGURERAMPATCH_76
VISACONFIGURERAMPATCH_6C:
    moveal %a0@(52),%a2	| 4084C0E6
    lea %a2@(1),%a2	| 4084C0EA
    moveal %a5,%a3	| 4084C0EE
VISACONFIGURERAMPATCH_76:  /* write the size code into the decoder register */
    moveb %a2@,%d5
    andib #31,%d5
    orb %d3,%d5
    moveb %d5,%a2@
VISACONFIGURERAMPATCH_80:  /* return through a3 */
    jmp %a3@
    .long   0x00204060	| 4084C0FC
    .short  0x80A0, 0xFFFF, 0xC0E0	| 4084C100

VISACONFIGURERAMPATCH_8C:  /* relocate the address a2 if it falls in the moved range */
    cmpl %a2,%d4
    jbhi VISACONFIGURERAMPATCH_9C
    movel %a2,%d6
    subl %d4,%d6
    cmpal %d6,%a4
    jbls VISACONFIGURERAMPATCH_9C
    addl %a3,%d6
    moveal %d6,%a2
VISACONFIGURERAMPATCH_9C:  /* return */
    rts

/*
 ELSIETRANSLATE24TO32: 24 to 32 bit address translation for the Elsie (LC) machines:
 addresses with bit 23 set map to I/O and slot space through the table.
*/
ELSIETRANSLATE24TO32:
    andl Lo3Bytes,%d0
    bclr #23,%d0
    jbne ELSIETRANSLATE24TO32_C
    rts
ELSIETRANSLATE24TO32_C:  /* translate the high nibble */
    movew %d1,%sp@-
    swap %d0
    movew %d0,%d1
    lsrw #4,%d1
    addw %pc@(ELSIETRANSLATE24TO32_20:w,%d1:w:2),%d0	| 4084C12C
    swap %d0
    movew %sp@+,%d1
    rts
ELSIETRANSLATE24TO32_20:  /* 32-bit bases for each 1 MB of the high 8 MB */
    .long   0x00800080, 0x40804080	| 4084C138
    .long   0x40804080, 0xFDA05080	| 4084C140

/*
 SHUTRESTARTANNEX: at shut down / restart on machine kind 13: send Control 128 to the
 built-in video (category 3, type 1, DrSW 1, DrHW 0x1A) so it can shut down, then run
 the shutdown procedures. Out: a0 = ROMBase.
*/
SHUTRESTARTANNEX:
    cmpib #13,0xcb3
    jbne SHUTRESTARTANNEX_54
    linkw %fp,#-120
    lea %fp@(-56),%a0
    movel #196609,%a0@(40)
    movel #65562,%a0@(44)
    clrb %a0@(48)
    clrb %a0@(49)
    clrb %a0@(50)
    clrb %a0@(51)
    clrl %a0@(24)
    bset #1,%a0@(27)
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */
    _SlotManager
    jbne SHUTRESTARTANNEX_52
    lea %fp@(-120),%a0
    movew %fp@(-18),%a0@(24)
    movew #128,%a0@(26)
    .short  0xA204	| 4084C198 _Control (flags 0x0200)
SHUTRESTARTANNEX_52:    /* done */
    unlk %fp
SHUTRESTARTANNEX_54:    /* shutdown procedures */
    moveq #1,%d0
    bigjsr CALLROUTINES
    moveal ROMBase,%a0
    rts

/* SLOTMGRPATCH1: PrimaryInit status into the sInfo record. */
SLOTMGRPATCH1:
    moveal %sp@+,%a2
    movel %a3,%a0@(4)
    moveb %d1,%a2@
    moveb %a0@(54),%a2@(4)
    moveq #35,%d0
    _SlotManager
    moveb #3,%a1@(8)
    movew %a2@(2),%a1@(6)
    bpls SLOTMGRPATCH1_26
    movew #-316,%a1@(4)
SLOTMGRPATCH1_26:
    rts

/*
 SLOTBUSEXCPTNPTCH: bus error during a slot access: turn the exception frame
 into a return to the Slot Manager's error path (rte).
*/
SLOTBUSEXCPTNPTCH:
    moveal %sp@+,%a0
    movel %sp@,%d0
    movel %a2,%sp@(90)
    movew %sp@(4),%sp@(88)
    clrw %sp@(94)
    lea %sp@(88),%sp
    rte

/*
 LOADSEGPATCH: build the jump table entries of a loaded segment (jmp abs.l, 0x4EF9) and
 flush the instruction cache over them (68040).
*/
LOADSEGPATCH:
    movel %a2,%sp@-
    moveal %a1,%a2
LOADSEGPATCH_4:         /* one entry */
    movew %a1@+,%d2
    movew %d1,%a1@(-2)
    movew #20217,%a1@+
    pea %a0@(0x4,%d2:l)
    movel %sp@+,%a1@+
    subqw #1,%d0
    jbne LOADSEGPATCH_4
    subal %a2,%a1
    moveal %a2,%a0
    jbsr FLUSHCRANGE
    moveal %sp@+,%a2
    rts

/*
 UNLOADSEGPATCH: _UnloadSeg: turn the segment's jump table entries back into "move.w
 #seg,-(sp), _LoadSeg" and flush the cache over them, unlock the 'CODE' resource.
*/
UNLOADSEGPATCH:
    moveal %sp@(4),%a0
    cmpiw #20217,%a0@
    jbne UNLOADSEGPATCH_5E
    st ResLoad
    subqw #4,%sp
    movel #1129268293,%sp@-
    movew %a0@(-2),%sp@-
    _GetResource
    moveal %sp@+,%a0
    _HUnlock
    moveal %a0@,%a0
    moveal %a5,%a1
    addaw CurJTOffset,%a1
    addaw %a0@,%a1
    movew %a0@(2),%d0
    jbeq UNLOADSEGPATCH_5E
    moveml %d1/%a2,%sp@-
    moveal %a1,%a2
UNLOADSEGPATCH_36:      /* one entry */
    movew %a1@,%d1
    movel %a1@(4),%d2
    subl %a0,%d2
    subql #4,%d2
    movew %d2,%a1@+
    movew #16188,%a1@+
    movew %d1,%a1@+
    movew #-22032,%a1@+
    subqw #1,%d0
    jbne UNLOADSEGPATCH_36
    subal %a2,%a1
    moveal %a2,%a0
    jbsr FLUSHCRANGE
    moveml %sp@+,%d1/%a2
UNLOADSEGPATCH_5E:      /* return, pop the parameter */
    movel %sp@+,%sp@
    rts

UNLOADSEGPATCH_62:      /* docking bases, SCSI disk mode, INITOVERPATCH */
    jbsr SETUPDOCKBASES
    jbsr SCSIDISKMODE
    jsr %pc@(INITOVERPATCH)
    rts

/*
 GETDEVPIXMAPPATCH: the color table seed of a device: a new one (GetCTSeed) if it is 0
 or one of the reserved values (below 1024).
*/
GETDEVPIXMAPPATCH:
    movel %a1@,%d0
    jbeq GETDEVPIXMAPPATCH_C
    cmpil #1023,%d0
    jble GETDEVPIXMAPPATCH_12
GETDEVPIXMAPPATCH_C:    /* new seed */
    subqw #4,%sp
    _GetCTSeed
    movel %sp@+,%d0
GETDEVPIXMAPPATCH_12:   /* return */
    rts
    .fill   0x2E50, 1, 0x00
    .ascii  "Copyright "	| 4084F0EC
    .byte   0xA9	| 4084F0F6
    .ascii  " 1981-1992 by Apple Computer, Inc.  All rights reserved.\000"

/*
 INITOVERPATCH: last start-up patch: with a 24-bit MMU mode... (MMUType 0 or 1) make
 the unimplemented trap the one for 0xA05C. Then a hidden picture: if Esc is held and
 L, F and W are down within a second (INITOVERPATCH_24), show the picture in PICTUREDATA
 with a fade of the colors (INITOVERPATCH_6C). Replace the picture with make PICTURE=
 (tools/pict2s.py).
*/
INITOVERPATCH:
    cmpib #0,MMUType
    jbeq INITOVERPATCH_10
    cmpib #1,MMUType
    jbne INITOVERPATCH_1C
INITOVERPATCH_10:       /* no MemoryDispatch on these MMUs */
    movew #-22369,%d0
    .short  0xA746	| 4084F144 _GetTrapAddress (flags 0x0700)
    movew #-24484,%d0
    .short  0xA247	| 4084F14A _SetTrapAddress (flags 0x0200)
INITOVERPATCH_1C:       /* key combination held? */
    jbsr INITOVERPATCH_24
    jbeq INITOVERPATCH_22
    jbsr INITOVERPATCH_6C
INITOVERPATCH_22:       /* return */
    rts

INITOVERPATCH_24:       /* Esc (KeyMap_6 bit 5) held, then the keys of the table (bit, byte in KeyMap) within 60 ticks */
    btst #5,KeyMap_6
    jbeq INITOVERPATCH_5C
    moveq #2,%d0
    lea %pc@(INITOVERPATCH_60),%a0
    moveq #60,%d1
    addl Ticks,%d1
INITOVERPATCH_38:       /* each key down? */
    cmpl Ticks,%d1
    jblt INITOVERPATCH_5C
    lea KeyMap,%a1
    addaw %a0@(2),%a1
    movew %a0@,%d2
    btst %d2,%a1@
    jbeq INITOVERPATCH_38
    btst #5,KeyMap_6
    jbeq INITOVERPATCH_5C
    tstl %a0@+
    dbf %d0,INITOVERPATCH_38
    rts
INITOVERPATCH_5C:       /* not held: Z set */
    moveq #0,%d0
    rts
INITOVERPATCH_60:       /* the keys (bit, KeyMap byte): L (0x25), F (0x03), W (0x0D) */
    orib #4,%d5	| 4084F190
    orib #0,%d3	| 4084F194
    orib #1,%d5	| 4084F198

INITOVERPATCH_6C:       /* show the picture: fade out, paint the screen, draw it centred with a double frame, fade in, wait for a click */
    moveml %d3-%d4/%a2-%a4/%fp,%sp@-
    subaw #64,%sp
    moveal %sp,%fp
    moveal %a5@,%a2
    jbsr INITOVERPATCH_188
    pea %a2@(-116)
    _PaintRect
    jbsr INITOVERPATCH_150
    jbeq INITOVERPATCH_E8
    movel %a0,%sp@-
    moveal %a0@,%a1
    movel %a1@(6),%sp@-
    movel %a1@(2),%sp@-
    moveal %sp,%a1
    movel %a0,%sp@-
    movel %a2@(-112),%d0
    movel %a1,%sp@-
    subl %a1@(4),%d0
    lsrw #1,%d0
    swap %d0
    lsrw #1,%d0
    swap %d0
    addl %d0,%a1@+
    addl %d0,%a1@
    _DrawPicture
    pea %a2@(-8)
    _PenPat
    movel #131074,%sp@-
    _PenSize
    movel %sp,%sp@-
    movel #-131075,%sp@-
    _InsetRect
    movel %sp,%sp@-
    _FrameRect
    movel #65537,%sp@-
    _PenSize
    movel %sp,%sp@-
    movel #-131075,%sp@-
    _InsetRect
    movel %sp,%sp@-
    _FrameRect
    addql #8,%sp
    moveal %sp@+,%a0
    _DisposHandle
INITOVERPATCH_E8:       /* fade the colors back */
    jbsr INITOVERPATCH_208
INITOVERPATCH_EC:       /* wait for the mouse button */
    tstb MBState
    jbmi INITOVERPATCH_EC
    moveb 0xcb3,%d0
    cmpib #15,%d0
    jbne INITOVERPATCH_108
    lea %a2@(-116),%a0
    movel %a0,%sp@-
    pea %a2@(-24)
    _FillRect
INITOVERPATCH_108:      /* back to the grey start-up screen with its rounded box */
    lea %a2@(-116),%a0
    movel %a0,%sp@-
    lea Scratch8,%a1
    movel %a1,%sp@-
    movel %a1,%sp@-
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    movel #-131075,%sp@-
    _InsetRect
    pea %a2@(-16)
    _PenPat
    movel #196611,%sp@-
    _PenSize
    movel #1441814,%sp@-
    _FrameRoundRect
    _PenNormal
    movel #1048592,%sp@-
    pea %a2@(-24)
    _FillRoundRect
    lea %sp@(64),%sp
    moveml %sp@+,%d3-%d4/%a2-%a4/%fp
    rts
INITOVERPATCH_150:      /* expand PICTUREDATA (packed bytes: 5-bit codes into a table, or 4-bit literal) into a new handle */
    biglea PICTUREDATA, a1
    movel %a1@,%d0
    .short  0xA122	| 4084F28C _NewHandle (flags 0x0100)
    movel %a0,%sp@-
    jbeq INITOVERPATCH_17C
    moveal %a0@,%a0
    movel %a1@+,%d0
    addaw %a1@,%a1
    moveq #0,%d1
INITOVERPATCH_16A:      /* next code */
    bfexts %a1@,%d1,9,%d2
    jbpl INITOVERPATCH_182
    asrw #4,%d2
    moveb %a1@(0x0,%d2:w),%a0@+
INITOVERPATCH_176:      /* next */
    addql #5,%d1
    subql #1,%d0
    jbgt INITOVERPATCH_16A
INITOVERPATCH_17C:      /* return the handle (0 if no memory) */
    moveal %sp@+,%a0
    movel %a0,%d0
    rts
INITOVERPATCH_182:      /* literal byte */
    moveb %d2,%a0@+
    addql #4,%d1
    jbra INITOVERPATCH_176

INITOVERPATCH_188:      /* fade out: halve the main device's colors 8 times (SetEntries) */
    moveal MainDevice,%a0
    moveal %a0@,%a0
    tstw %a0@(4)
    jbne INITOVERPATCH_206
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    _HandToHand
    moveal %a0,%a3
    _HandToHand
    moveal %a0,%a4
    moveal MainDevice,%a0
    moveal %a0@,%a0
    movew %a0@,%fp@(24)
    clrl %fp@(12)
    clrw %fp@(22)
    lea %fp@(64),%a0
    movel %a0,%fp@(28)
    clrw %a0@(4)
    moveal %a3@,%a1
    movew %a1@(6),%d3
    movew %d3,%a0@(6)
    lea %a1@(8),%a1
    movel %a1,%a0@
    movew #3,%fp@(26)
    moveal %fp,%a0
    movew #7,%d2
INITOVERPATCH_1E0:      /* one step */
    moveal %a3@,%a1
    lea %a1@(8),%a1
    movew %d3,%d0
INITOVERPATCH_1E8:      /* each color */
    addqw #2,%a1
    movew %a1@,%d1
    lsrw #1,%d1
    movew %d1,%a1@+
    movew %a1@,%d1
    lsrw #1,%d1
    movew %d1,%a1@+
    movew %a1@,%d1
    lsrw #1,%d1
    movew %d1,%a1@+
    dbf %d0,INITOVERPATCH_1E8
    _Control
    dbf %d2,INITOVERPATCH_1E0
INITOVERPATCH_206:      /* return */
    rts
INITOVERPATCH_208:      /* fade in: add the original colors back in steps */
    moveal MainDevice,%a0
    moveal %a0@,%a0
    tstw %a0@(4)
    jbne INITOVERPATCH_27C
    jbsr INITOVERPATCH_27E
    moveal %a3@,%a0
    lea %a0@(8),%a0
    lea %fp@(64),%a1
    movel %a0,%a1@
    movew #255,%d2
    lsrw %d4,%d2
INITOVERPATCH_228:      /* one step */
    moveal %a3@,%a0
    lea %a0@(8),%a0
    moveal %a4@,%a1
    lea %a1@(8),%a1
    movew %d3,%d0
INITOVERPATCH_236:      /* each color */
    addqw #2,%a0
    addqw #2,%a1
    clrw %d1
    moveb %a1@,%d1
    lslw %d4,%d1
    addqw #2,%a1
    addw %d1,%a0@+
    clrw %d1
    moveb %a1@,%d1
    lslw %d4,%d1
    addqw #2,%a1
    addw %d1,%a0@+
    clrw %d1
    moveb %a1@,%d1
    lslw %d4,%d1
    addqw #2,%a1
    addw %d1,%a0@+
    dbf %d0,INITOVERPATCH_236
    moveal %fp,%a0
    _Control
    dbf %d2,INITOVERPATCH_228
    moveal %a4@,%a1
    lea %a1@(8),%a1
    lea %fp@(64),%a0
    movel %a1,%a0@
    moveal %fp,%a0
    _Control
    moveal %a3,%a0
    _DisposHandle
    moveal %a4,%a0
    _DisposHandle
INITOVERPATCH_27C:      /* return */
    rts
INITOVERPATCH_27E:      /* steps for the main device: its sResource's ID 32 value (9 or 26: 16 steps... d4 = 4), else d4 = 0 */
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    movew %a0@,%d0
    notw %d0
    moveal UTableBase,%a1
    moveal %a1@(0x0,%d0:w:4),%a1
    moveal %a1@,%a1
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(50)
    clrb %a0@(48)
    movew #1,%a0@(40)
    clrw %a0@(42)
    clrw %a0@(44)
    clrw %a0@(46)
    moveq #21,%d0	/* _SlotManager 21: NEXTTYPESRSRC, sNextTypesRsrc */
    _SlotManager
    moveb #32,%a0@(50)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    movew %a0@(2),%d0
    lea %sp@(56),%sp
    cmpiw #9,%d0
    jbeq INITOVERPATCH_2DE
    cmpiw #26,%d0
    jbeq INITOVERPATCH_2DE
    moveq #0,%d4
    rts
INITOVERPATCH_2DE:      /* d4 = 4 */
    moveq #4,%d4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4084F412
