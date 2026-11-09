/*
 os/postusernm.s - user notification message
 From POSTUSERNMMSG (0x408B51A6). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. These are Power Manager
 helpers (PowerBooks).
*/

/*
 POSTUSERNMMSG: post a Notification Manager message (string a0) once, with the Power
 Manager's icon; d0 = 1 removes it after it is seen.
*/
POSTUSERNMMSG:
    moveml %d1/%a0/%a2,%sp@-
    moveal PmgrBase,%a2
    bset #7,%a2@(296)
    jbne POSTUSERNMMSG_46
    movel %a0,%d1
    jbeq POSTUSERNMMSG_46
    lea %a2@(308),%a0
    movel %d1,%a0@(24)
    movew #8,%a0@(4)
    movel #-1,%a0@(20)
    clrw %a0@(14)
    movel %a2@(110),%a0@(16)
    lea %pc@(POSTUSERNMMSG_4A),%a2
    subqw #1,%d0
    jbne POSTUSERNMMSG_40
    lea %pc@(POSTUSERNMMSG_4C),%a2
POSTUSERNMMSG_40:       /* response routine */
    movel %a2,%a0@(28)
    _NMInstall
POSTUSERNMMSG_46:       /* (already posted or no message) */
    moveml %sp@+,%d1/%a0/%a2
POSTUSERNMMSG_4A:       /* return (and the empty response routine) */
    rts
POSTUSERNMMSG_4C:       /* response routine that removes the notification */
    moveal %sp@+,%a1	| 408B51F2
    moveal %sp@+,%a0	| 408B51F4
    _NMRemove	| 408B51F6
    moveal PmgrBase,%a0	| 408B51F8
    bclr #7,%a0@(296)	| 408B51FC
    jmp %a1@	| 408B5202
    .byte   0x00, 0x02, 0x00, 0x00, 0x00, 0xB4, 0x00, 0x00, 0x00, 0xF4	| 408B5204

POSTUSERNMMSG_68:       /* PMgrOp 0x50 with d1 bit 0 clear (power control) */
    bclr #0,%d1
    jbra POSTUSERNMMSG_76

POSTUSERNMMSG_6E:       /* PMgrOp 0x50 with d1 bit 0 set */
    andib #7,%d1
    bset #0,%d1
POSTUSERNMMSG_76:       /* send it */
    moveb %d1,%a0@(12)
    movew #1,%a0@(2)
    movew #80,%a0@
    _PMgrOp
    rts

POSTUSERNMMSG_88:       /* PMgrOp 0x10 (power off a subsystem) 0x08 */
    moveb #8,%a0@(12)
    jbra POSTUSERNMMSG_96

POSTUSERNMMSG_90:       /* PMgrOp 0x10, 0x88 (power on) */
    moveb #0x88,%a0@(12)
POSTUSERNMMSG_96:       /* send it */
    movew #1,%a0@(2)
    movew #16,%a0@
    _PMgrOp
    rts

POSTUSERNMMSG_A4:       /* sound off through the sound primitives (input off, play-through off) */
    movel %a0,%sp@-
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 408B524C
    tstl %a0@(28)
    jbeq POSTUSERNMMSG_BA
    moveal %a0@(28),%a0
    jsr %a0@
POSTUSERNMMSG_BA:       /* (input active?) */
    moveal %sp@+,%a0
    cmpib #2,%d0
    jbne POSTUSERNMMSG_F6
    clrb %d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 408B526C
    tstl %a0@(36)
    jbeq POSTUSERNMMSG_DA
    moveal %a0@(36),%a0
    jsr %a0@
POSTUSERNMMSG_DA:       /* (volume) */
    moveal %sp@+,%a0
    moveq #0,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 408B5286
    tstl %a0@(24)
    jbeq POSTUSERNMMSG_F4
    moveal %a0@(24),%a0
    jsr %a0@
POSTUSERNMMSG_F4:       /* (after the hook) */
    moveal %sp@+,%a0
POSTUSERNMMSG_F6:       /* return */
    rts

POSTUSERNMMSG_F8:       /* wait d0 milliseconds (TimeDBRA loops) */
    moveml %d0-%d1,%sp@-
    movew %d0,%d1
    subqw #1,%d1
POSTUSERNMMSG_100:      /* one millisecond */
    movew TimeDBRA,%d0
POSTUSERNMMSG_104:      /* loop */
    dbf %d0,POSTUSERNMMSG_104
    dbf %d1,POSTUSERNMMSG_100
    moveml %sp@+,%d0-%d1
    rts
    bclr #7,@(ghost_VIA2,%za0)@(0)	| 408B52B8
    jbsr POSTUSERNMMSG_6E
    moveq #3,%d0
    jbsr POSTUSERNMMSG_F8
    bset #7,@(ghost_VIA2,%za0)@(0)	| 408B52C8
    jbsr POSTUSERNMMSG_90
    moveq #8,%d0
    jbsr POSTUSERNMMSG_F8
    bclr #7,@(ghost_VIA2,%za0)@(0)	| 408B52D8
    movel @(PmgrBase,%za0)@(0x102),0x19e
    moveb #0x88,@(VIA,%za0)@(0x1c00)
    moveq #0,%d0
    rts

POSTUSERNMMSG_152:      /* power cycle a subsystem: off, wait 512 ms, on, wait 8 ms */
    moveb #8,@(VIA,%za0)@(0x1c00)	| 408B52F8
    jbsr POSTUSERNMMSG_A4
    jbsr POSTUSERNMMSG_88
    movel #512,%d0
    jbsr POSTUSERNMMSG_F8
    jbsr POSTUSERNMMSG_68
    moveq #8,%d0
    jbsr POSTUSERNMMSG_F8
    moveq #0,%d0
    rts
    .fill   0x10B2, 1, 0x00
