/*
 os/mmu.s - MMU set-up and globals
 From MMUSTUFF (0x40803E00). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. Low memory: 0xCB0 MMU
 flags, 0xCB1 MMU type (the code tests 3 or more for a paged MMU, 5 for the 68040),
 0xCB2 current addressing mode (1 = 32-bit), 0xCB4/0xCB8 the 24-bit and 32-bit MMU
 configurations (from the boot globals), 0xDBC the SwapMMUMode routine for this MMU.
*/

/* INITMMUTRAP: install the machine's SwapMMUMode routine (0xDBC) as trap 0xA05D. */
MMUSTUFF:
INITMMUTRAP:
    moveal JSwapMMU,%a0
    movew #-24483,%d0
    .short  0xA247	| 40803E08 _SetTrapAddress (flags 0x0200)
    rts

/*
 INITMMUGLOBALS: MMU globals from the boot globals (0xDDC): 32-bit mode, the two MMU
 configurations, the MMU type, and the SwapMMUMode routine for it (a "nothing to do"
 one for 32-bit-only RAM above 8 MB).
*/
INITMMUGLOBALS:
    moveal 0xddc,%a1
    clrb MMUFlags
    moveb #1,MMU32Bit
    lea %a1@(-66),%a0
    movel %a0,0xcb8
    lea %a1@(-46),%a0
    movel %a0,0xcb4
    moveq #0,%d0
    moveb %a1@(-26),%d0
    moveb %d0,MMUType
    btst #0,%a1@(-25)
    jbeq INITMMUGLOBALS_36
    lea %pc@(MMUCLEANUPFOR8MB_24),%a0
    jbra INITMMUGLOBALS_3E
INITMMUGLOBALS_36:      /* SwapMMUMode routine by MMU type (table below) */
    movew %pc@(INITMMUGLOBALS_44,%d0:w:2),%d0
    lea %pc@(INITMMUGLOBALS_44,%d0:w),%a0
INITMMUGLOBALS_3E:      /* set 0xDBC */
    movel %a0,JSwapMMU
INITMMUGLOBALS_42:      /* (no MMU: rts) */
    rts
INITMMUGLOBALS_44:      /* offsets of the SwapMMUMode routines by MMU type */
    .short  INITMMUGLOBALS_42-INITMMUGLOBALS_44	| 40803E50
    .short  MMUCLEANUPFOR8MB_126-INITMMUGLOBALS_44	| 40803E52
    .short  INITMMUGLOBALS_42-INITMMUGLOBALS_44	| 40803E54
    .short  MMUCLEANUPFOR8MB_28-INITMMUGLOBALS_44	| 40803E56
    .short  MMUCLEANUPFOR8MB_78-INITMMUGLOBALS_44	| 40803E58
    .short  trap_SwapMMUMode-INITMMUGLOBALS_44	| 40803E5A
    .short  INITMMUGLOBALS_42-INITMMUGLOBALS_44	| 40803E5C
    .short  INITMMUGLOBALS_42-INITMMUGLOBALS_44	| 40803E5E
MMUCLEANUPFOR8MB:       /* set %a0 */
    moveal BufPtr,%a0
    subaw #40,%a0
    movel %a0,BufPtr
    lea 0xcb8,%a1
    jbsr MMUCLEANUPFOR8MB_16
    lea 0xcb4,%a1

MMUCLEANUPFOR8MB_16:    /* copy the configuration at (a1) to a0, update the pointer */
    moveal %a1@,%a2
    movel %a0,%a1@
    moveq #19,%d0
MMUCLEANUPFOR8MB_1C:    /* copy loop */
    moveb %a2@+,%a0@+
    dbf %d0,MMUCLEANUPFOR8MB_1C
    rts
MMUCLEANUPFOR8MB_24:    /* SwapMMUMode for machines that stay in 32-bit mode: d0 = 1. Then the 68030 PMMU and AMU versions */
    moveq #1,%d0
    rts
MMUCLEANUPFOR8MB_28:    /* set %d1 */
    moveb %d0,%d1	| 40803E88
    jbne MMUCLEANUPFOR8MB_40	| 40803E8A
    moveq #0,%d0	| 40803E8C
    moveb MMU32Bit,%d0	| 40803E8E
    jbeq MMUCLEANUPFOR8MB_76	| 40803E92
    movew %sr,%sp@-	| 40803E94
    oriw #1792,%sr	| 40803E96
    moveal 0xcb4,%a0	| 40803E9A
    jbra MMUCLEANUPFOR8MB_52	| 40803E9E
MMUCLEANUPFOR8MB_40:    /* clear %d0 */
    moveq #0,%d0	| 40803EA0
    moveb MMU32Bit,%d0	| 40803EA2
    jbne MMUCLEANUPFOR8MB_76	| 40803EA6
    movew %sr,%sp@-	| 40803EA8
    oriw #1792,%sr	| 40803EAA
    moveal 0xcb8,%a0	| 40803EAE
MMUCLEANUPFOR8MB_52:    /* (40803EB2 pmove %a0@,%tc) */
    .short  0xF010, 0x4000	| 40803EB2 pmove %a0@,%tc
    .short  0xF010, 0x4C00	| 40803EB6 pmove %a0@,%crp
    .short  0xF028, 0x4000, 0x0008	| 40803EBA pmove %a0@(8),%tc
    .short  0xF000, 0x2400	| 40803EC0 pflusha
    moveb %d1,MMU32Bit	| 40803EC4
    movec %cacr,%d1	| 40803EC8
    oriw #8,%d1	| 40803ECC
    movec %d1,%cacr	| 40803ED0
    movew %sp@+,%sr	| 40803ED4
MMUCLEANUPFOR8MB_76:    /* return */
    rts	| 40803ED6
MMUCLEANUPFOR8MB_78:    /* set %d1 */
    moveb %d0,%d1	| 40803ED8
    jbne MMUCLEANUPFOR8MB_8A	| 40803EDA
    moveq #0,%d0	| 40803EDC
    moveb MMU32Bit,%d0	| 40803EDE
    jbeq MMUCLEANUPFOR8MB_CE	| 40803EE2
    moveal 0xcb4,%a0	| 40803EE4
    jbra MMUCLEANUPFOR8MB_96	| 40803EE8
MMUCLEANUPFOR8MB_8A:    /* clear %d0 */
    moveq #0,%d0	| 40803EEA
    moveb MMU32Bit,%d0	| 40803EEC
    jbne MMUCLEANUPFOR8MB_CE	| 40803EF0
    moveal 0xcb8,%a0	| 40803EF2
MMUCLEANUPFOR8MB_96:    /* set %sp@- */
    movew %sr,%sp@-	| 40803EF6
    oriw #1792,%sr	| 40803EF8
    .short  0xF028, 0x2215, 0x0008	| 40803EFC ploadr #5,%a0@(8)
    .byte   0xF0, 0x28, 0x09, 0x00, 0x00, 0x0C, 0xF0, 0x28, 0x0D, 0x00, 0x00, 0x10, 0xF0, 0x10, 0x4D, 0x00	| 40803F02
    .byte   0xF0, 0x28, 0x40, 0x00, 0x00, 0x08, 0x11, 0xC1, 0x0C, 0xB2, 0x4E, 0x7A, 0x10, 0x02, 0x00, 0x41	| 40803F12
    .byte   0x08, 0x08, 0x4E, 0x7B, 0x10, 0x02, 0xF0, 0x00, 0x24, 0x00, 0x46, 0xDF	| 40803F22
MMUCLEANUPFOR8MB_CE:    /* return */
    rts	| 40803F2E

/* _SwapMMUMode for the 68040: d0 = 0 (24-bit) or 1 (32-bit); returns the old mode in d0. */
trap_SwapMMUMode:
    moveb %d0,%d1
    jbne MMUCLEANUPFOR8MB_E2
    moveq #0,%d0
    moveb MMU32Bit,%d0
    jbeq MMUCLEANUPFOR8MB_124
    moveal 0xcb4,%a0
    jbra MMUCLEANUPFOR8MB_EE
MMUCLEANUPFOR8MB_E2:    /* to 32-bit: already? */
    moveq #0,%d0
    moveb MMU32Bit,%d0
    jbne MMUCLEANUPFOR8MB_124
    moveal 0xcb8,%a0
MMUCLEANUPFOR8MB_EE:    /* load the configuration: TT registers, SRP, TC, flush the ATC */
    movew %sr,%sp@-
    oriw #1792,%sr
    moveb %d1,MMU32Bit
    movel %a0@(12),%d1
MMUCLEANUPFOR8MB_FC:    /* (68040 registers) */
    movec %d1,%itt0
    movec %d1,%dtt0
    movel %a0@(16),%d1
    movec %d1,%itt1
    movec %d1,%dtt1
    movel %a0@(8),%d1
    moveal %a0@(4),%a0
    movec %a0,%srp
    movec %d1,%tc
    pflusha
    movew %sp@+,%sr
MMUCLEANUPFOR8MB_124:   /* return (d0 = the previous mode). Then the versions for other decoders */
    rts
MMUCLEANUPFOR8MB_126:   /* set %d1 */
    moveb %d0,%d1	| 40803F86
    jbne MMUCLEANUPFOR8MB_142	| 40803F88
    moveq #0,%d0	| 40803F8A
    moveb MMU32Bit,%d0	| 40803F8C
    jbeq MMUCLEANUPFOR8MB_178	| 40803F90
    movew %sr,%sp@-	| 40803F92
    oriw #1792,%sr	| 40803F94
    moveal ghost_VIA2,%a0	| 40803F98
    bclr #3,%a0@	| 40803F9C
    jbra MMUCLEANUPFOR8MB_158	| 40803FA0
MMUCLEANUPFOR8MB_142:   /* clear %d0 */
    moveq #0,%d0	| 40803FA2
    moveb MMU32Bit,%d0	| 40803FA4
    jbne MMUCLEANUPFOR8MB_178	| 40803FA8
    movew %sr,%sp@-	| 40803FAA
    oriw #1792,%sr	| 40803FAC
    moveal ghost_VIA2,%a0	| 40803FB0
    bset #3,%a0@	| 40803FB4
MMUCLEANUPFOR8MB_158:   /* set 0xcb2 */
    moveb %d1,MMU32Bit	| 40803FB8
    movec %cacr,%d1	| 40803FBC
    bset #3,%d1	| 40803FC0
    movec %d1,%cacr	| 40803FC4
    moveal ASCBase,%a0	| 40803FC8
    lea %a0@(2052),%a0	| 40803FCC
    moveb %a0@,%d1	| 40803FD0
    jbeq MMUCLEANUPFOR8MB_176	| 40803FD2
    orb %d1,%a0@	| 40803FD4
MMUCLEANUPFOR8MB_176:   /* set %sr */
    movew %sp@+,%sr	| 40803FD6
MMUCLEANUPFOR8MB_178:   /* (data) */
    rts	| 40803FD8
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40803FDA
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40803FEA
    .byte   0x00, 0x00, 0x00, 0x00	| 40803FFA
MMUCLEANUPFOR8MB_19E:   /* (end) */
    .byte   0x00, 0x00	| 40803FFE
