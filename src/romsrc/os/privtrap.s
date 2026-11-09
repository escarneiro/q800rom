/*
 os/privtrap.s - privileged instruction traps
 From INSTALLPRIVTRAP (0x408957B0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple.
*/

/*
 INSTALLPRIVTRAP: with an FPU (HWCfgFlags bit 4), install the trap 0xA097 (FPPriv)
 handler for the CPU: the 68881/68882 one or the 68040 one.
*/
INSTALLPRIVTRAP:
    btst #4,HWCfgFlags
    jbeq INSTALLPRIVTRAP_1E
    lea %pc@(PRIVTRAP881),%a0
    cmpib #4,CPUFlag
    jblt INSTALLPRIVTRAP_18
    lea %pc@(trap_PRIVTRAP040),%a0
INSTALLPRIVTRAP_18:     /* SetTrapAddress */
    movew #-24425,%d0
    .short  0xA247	| 408957CC _SetTrapAddress (flags 0x0200)
INSTALLPRIVTRAP_1E:     /* return */
    rts

/*
 PRIVTRAP881: FPPriv for the 68881/68882: 0 set the FPU exception state,
 1 save and 2 restore the FPU control registers and state.
*/
PRIVTRAP881:
    cmpiw #0,%d0	| 408957D0
    jbeq PRIVTRAP881_1A	| 408957D4
    cmpiw #1,%d0	| 408957D6
    jbeq PRIVTRAP881_56	| 408957DA
    cmpiw #2,%d0	| 408957DC
    jbeq PRIVTRAP881_6A	| 408957E0
    movew #-490,%d0	| 408957E2
    _SysError	| 408957E6
    rts	| 408957E8
PRIVTRAP881_1A:         /* from here: fnop */
    fnop	| 408957EA
    movel %a0,%d1	| 408957EE
    fsave %sp@-	| 408957F0
    fmovel %fpsr,%d0	| 408957F2
    andiw #255,%d0	| 408957F6
    orw %d1,%d0	| 408957FA
    fmovel %d0,%fpsr	| 408957FC
    fmovel %fpcr,%d0	| 40895800
    andw %d1,%d0	| 40895804
    andil #65280,%d0	| 40895806
    jbeq PRIVTRAP881_52	| 4089580C
    lea %pc@(PRIVTRAP881_52),%a0	| 4089580E
    fmovel %a0,%fpiar	| 40895812
    moveq #0,%d0	| 40895816
    moveb %sp@(1),%d0	| 40895818
    bclr #3,%sp@(0,%d0:w)	| 4089581C
PRIVTRAP881_52:         /* from here: frestore %sp@+ */
    frestore %sp@+	| 40895822
    rts	| 40895824
PRIVTRAP881_56:         /* set %a1 */
    moveaw #192,%a1	| 40895826
    movel %a1@+,%a0@+	| 4089582A
    movel %a1@+,%a0@+	| 4089582C
    movel %a1@+,%a0@+	| 4089582E
    movel %a1@+,%a0@+	| 40895830
    movel %a1@+,%a0@+	| 40895832
    movel %a1@+,%a0@+	| 40895834
    movel %a1@+,%a0@+	| 40895836
    rts	| 40895838
PRIVTRAP881_6A:         /* set %a1 */
    moveaw #192,%a1	| 4089583A
    movel %a0@+,%a1@+	| 4089583E
    movel %a0@+,%a1@+	| 40895840
    movel %a0@+,%a1@+	| 40895842
    movel %a0@+,%a1@+	| 40895844
    movel %a0@+,%a1@+	| 40895846
    movel %a0@+,%a1@+	| 40895848
    movel %a0@+,%a1@+	| 4089584A
    rts	| 4089584C
    .byte   0x00, 0x00	| 4089584E

/*
 PRIVTRAP040: FPPriv for the 68040: d0 = 0 set the exception state (FPSR bits from
 a0, then raise the enabled exceptions by doing an operation that causes them), 1 save
 and 2 restore the FPU state kept in low memory (0x1FCC..0x1FDC and 196). Others:
 system error -490.
*/
trap_PRIVTRAP040:
PRIVTRAP040:
    cmpiw #0,%d0
    jbeq PRIVTRAP040_56
    cmpiw #1,%d0
    jbeq PRIVTRAP040_1A
    cmpiw #2,%d0
    jbeq PRIVTRAP040_38
    movew #-490,%d0
    _SysError
    rts
PRIVTRAP040_1A:         /* save */
    moveaw #196,%a1
    movel 0x1fcc,%a0@+
    movel %a1@+,%a0@+
    movel %a1@,%a0@+
    movel 0x1fd0,%a0@+
    movel 0x1fd4,%a0@+
    movel 0x1fd8,%a0@+
    movel 0x1fdc,%a0@+
    rts
PRIVTRAP040_38:         /* restore */
    moveaw #196,%a1
    movel %a0@+,0x1fcc
    movel %a0@+,%a1@+
    movel %a0@+,%a1@
    movel %a0@+,0x1fd0
    movel %a0@+,0x1fd4
    movel %a0@+,0x1fd8
    movel %a0@+,0x1fdc
    rts
PRIVTRAP040_56:         /* set FPSR, any enabled exception pending? */
    fnop
    movel %a0,%d1
    fmovel %fpsr,%d0
    andiw #255,%d0
    orw %d1,%d0
    fmovel %d0,%fpsr
    fmovel %fpcr,%d0
    andw %d0,%d1
    andil #65280,%d1
    jbne PRIVTRAP040_7A
    rts
PRIVTRAP040_7A:         /* BSUN: compare with a NaN */
    btst #15,%d1
    jbeq PRIVTRAP040_92
    fmoves #0enan,%fp1
    fbgt PRIVTRAP040_C8
    fnop
    rts
PRIVTRAP040_92:         /* SNAN */
    btst #14,%d1
    jbeq PRIVTRAP040_A2
    fcmps #0x7fbfffff,%fp1	| 408958E8
    jbra PRIVTRAP040_C8
PRIVTRAP040_A2:         /* OPERR: inf - inf */
    btst #13,%d1
    jbeq PRIVTRAP040_B6
    fmoves #0einf,%fp1
    fsubx %fp1,%fp1
    jbra PRIVTRAP040_C8
PRIVTRAP040_B6:         /* OVFL: big x big */
    btst #12,%d1
    jbeq PRIVTRAP040_CE
    fmoves #0x7f000000,%fp1	| 4089590C
    fsmulx %fp1,%fp1
PRIVTRAP040_C8:         /* wait for the FPU, return */
    fnop
    rts
PRIVTRAP040_CE:         /* UNFL: tiny x tiny */
    btst #11,%d1
    jbeq PRIVTRAP040_E2
    fmoves #0x1f000000,%fp1	| 40895924
    fsmulx %fp1,%fp1
    jbra PRIVTRAP040_C8
PRIVTRAP040_E2:         /* DZ: 1 / 0 */
    btst #10,%d1
    jbeq PRIVTRAP040_F6
    fmoveb #1,%fp1
    fdivb #0,%fp1
    jbra PRIVTRAP040_C8
PRIVTRAP040_F6:         /* INEX: 1 + tiny */
    fmoveb #1,%fp1
    fadds #0x00800000,%fp1	| 4089594C
    jbra PRIVTRAP040_C8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40895956
