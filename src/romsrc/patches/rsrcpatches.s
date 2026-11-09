/*
 patches/rsrcpatches.s - memory sizing patch, sound buffer, ROM resource patching
 From HMMMMMM (0x408A0000). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. The first part runs before
 RAM is known (no stack, returns through fp/a2), and parts are still
*/

/*
 SIZEMEMORYPATCH: find and size the RAM. Per decoder kind (jump table below) the
 memory controller is first set to its largest configuration; then each bank range of
 the machine's RAM bank info is probed: the long 'Tina' is written at each step and
 looked for where it wraps, which gives the bank size ('SamB' marks the end of the
 table). The memory controller is then programmed with the sizes found, the bank table
 (start, size pairs) is written at the top of RAM, the sound buffer carved out
 (SIZESOUNDBUFFER), and the rest returns through a2.
*/
VSCDECLROM:
HMMMMMM:
SIZEMEMORYPATCH:
    movel %fp,%d3
    moveq #0,%d2
    lea %pc@(VSCDECLROM_12),%fp
    bigjmp hardware_table_lookup
VSCDECLROM_12:          /* d2 = decoder kind: jump through the table */
    moveal %d3,%a2
    moveq #0,%d3
    moveb %d2,%d3
    addw %d3,%d3
    movew %pc@(VSCDECLROM_22,%d3:w),%d3
    jmp %pc@(VSCDECLROM_22,%d3:w)
VSCDECLROM_22:          /* per decoder: set the memory controller to its maximum (partly raw words) */
    .short  VSCDECLROM_17E-VSCDECLROM_22	| 408A0022
    .short  VSCDECLROM_17E-VSCDECLROM_22	| 408A0024
    .short  VSCDECLROM_17E-VSCDECLROM_22	| 408A0026
    .short  VSCDECLROM_17E-VSCDECLROM_22	| 408A0028
    .short  VSCDECLROM_40-VSCDECLROM_22	| 408A002A
    .short  VSCDECLROM_17E-VSCDECLROM_22	| 408A002C
    .short  VSCDECLROM_4E-VSCDECLROM_22	| 408A002E
    .short  VSCDECLROM_86-VSCDECLROM_22	| 408A0030
    .short  VSCDECLROM_68-VSCDECLROM_22	| 408A0032
    .short  VSCDECLROM_FA-VSCDECLROM_22	| 408A0034
    .short  VSCDECLROM_116-VSCDECLROM_22	| 408A0036
    .short  VSCDECLROM_136-VSCDECLROM_22	| 408A0038
    .short  VSCDECLROM_FA-VSCDECLROM_22	| 408A003A
    .short  VSCDECLROM_142-VSCDECLROM_22	| 408A003C
    .byte   0x00, 0x00	| 408A003E
VSCDECLROM_40:          /* set %a5 */
    moveal %a0@(44),%a5	| 408A0040
    .short  0x002D, 0x00C0, 0x1E00	| 408A0044 orib #-64,%a5@(7680)
    jbra VSCDECLROM_17E	| 408A004A
VSCDECLROM_4E:          /* set %a5 */
    moveal %a0@(76),%a5	| 408A004E
    movew #-3089,%d2	| 408A0052
    moveq #15,%d3	| 408A0056
VSCDECLROM_58:          /* loop: move */
    moveb %d2,%a5@	| 408A0058
    lsrw #1,%d2	| 408A005A
    dbf %d3,VSCDECLROM_58	| 408A005C
    moveb %d2,%a5@(16)	| 408A0060
    jbra VSCDECLROM_17E	| 408A0064
VSCDECLROM_68:          /* set %a5 */
    moveal %a0@(84),%a5	| 408A0068
    lea %a5@,%a0	| 408A006C
    movel #198672,%d3	| 408A006E
    moveq #17,%d2
VSCDECLROM_76:          /* shift a configuration value into the controller, bit by bit */
    movel %d3,%a0@+
    lsrl #1,%d3
    dbf %d2,VSCDECLROM_76
    movel %d2,%a5@(160)
    jbra VSCDECLROM_17E
VSCDECLROM_86:          /* set %a5 */
    moveal %a0@(52),%a5	| 408A0086
    andib #31,%a5@(1)	| 408A008A
    moveal #2097150,%a0	| 408A0090
    movel #1348562500,%a0@	| 408A0096
    cmpil #1348562500,%a0@	| 408A009C
    jbne VSCDECLROM_F0	| 408A00A2
    .short  0x002D, 0x00C0, 0x0001	| 408A00A4 orib #-64,%a5@(1)
    moveal %a5,%sp
    moveal %a1,%a5
    addal %a5@(4),%a5
    addaw #24,%a5
    subal %a0,%a0
    moveal #8388608,%a1
    moveq #0,%d0
    movel #1416195681,%d1
    moveq #0,%d5
    lea %pc@(VSCDECLROM_D0),%fp
    jmp %pc@(VSCDECLROM_1FE)
VSCDECLROM_D0:
    cmpal #8388608,%a0	| 408A00D0
    jblt VSCDECLROM_E0	| 408A00D6
    subaw #24,%a5	| 408A00D8
    jbra VSCDECLROM_184	| 408A00DC
VSCDECLROM_E0:          /* (408A00E0 orib #-128,%sp@(1)) */
    .short  0x002F, 0x0080, 0x0001	| 408A00E0 orib #-128,%sp@(1)
    .short  0x022F, 0x009F, 0x0001	| 408A00E6 andib #-97,%sp@(1)
    jbra VSCDECLROM_184	| 408A00EC
VSCDECLROM_F0:          /* (408A00F0 orib #-32,%a5@(1)) */
    .short  0x002D, 0x00E0, 0x0001	| 408A00F0 orib #-32,%a5@(1)
    jbra VSCDECLROM_17E	| 408A00F6
VSCDECLROM_FA:          /* clear %d0 */
    moveq #0,%d0
    moveal %a0@(88),%a5
    addal #65536,%a5
    moveb %d0,%a5@
    lea %a5@(8192),%a5
    moveb %d0,%a5@
    lea %a5@(8192),%a5
    moveb %d0,%a5@
    jbra VSCDECLROM_17E
VSCDECLROM_116:         /* set %a5 */
    moveal %a0@(52),%a5	| 408A0116
    .short  0x002D, 0x00F0, 0x0010	| 408A011A orib #-16,%a5@(16)
    moveal %a1,%a5	| 408A0120
    addal %a5@(4),%a5	| 408A0122
    jbra VSCDECLROM_12E	| 408A0126
VSCDECLROM_128:         /* loop: movea */
    moveal %d2,%a0	| 408A0128
    tstl %a0@+	| 408A012A
    tstl %a0@+	| 408A012C
VSCDECLROM_12E:         /* add 4 to %a5 */
    addql #4,%a5	| 408A012E
    movel %a5@+,%d2	| 408A0130
    jbpl VSCDECLROM_128	| 408A0132
    jbra VSCDECLROM_17E	| 408A0134
VSCDECLROM_136:         /* set %a5 */
    moveal %a0@(52),%a5	| 408A0136
    .byte   0x00, 0x2D, 0x00, 0x7F	| 408A013A
    .short  0x0001, 0x603C	| orib #60,%d1
VSCDECLROM_142:         /* set %a5 */
    moveal %a0@(8),%a5
    moveq #40,%d1
    moveb %d1,%a5@(1536)
    moveq #0,%d0
    btst #1,%a5@(7680)
    jbne VSCDECLROM_15A
    bset #5,%d0
VSCDECLROM_15A:         /* memory controller registers (0x50F0E000): base and 10 bank registers */
    lea 0x50f0e000,%a5
    movel %d0,%a5@
    moveq #-1,%d0
    movel %d0,%a5@(44)
    movel #256,%d1
    moveq #9,%d0
    lea %a5@(4),%a5
VSCDECLROM_174:         /* bank registers */
    movel %d1,%a5@+
    addiw #16,%d1
    dbf %d0,VSCDECLROM_174
VSCDECLROM_17E:         /* probe the RAM banks of the bank info table */
    moveal %a1,%a5
    addal %a5@(4),%a5
VSCDECLROM_184:         /* clear %d0 */
    moveq #0,%d0
    subal %a3,%a3
    subql #1,%a3
VSCDECLROM_18A:         /* next table */
    moveal %a5,%sp
    addql #4,%sp
    moveq #0,%d5
    moveq #0,%d6
    movel #1416195681,%d1
VSCDECLROM_198:         /* next bank: end ('SamB' or -1)? */
    rorl #4,%d5
    rorl #4,%d6
    moveal %sp@+,%a0
    movel %a0,%d2
    cmpil #1398893890,%d2
    jbeq VSCDECLROM_1D0
    addql #1,%d2
    jbeq VSCDECLROM_1D0
    moveal %sp@+,%a1
    lea %pc@(VSCDECLROM_1B6),%fp
    jmp %pc@(VSCDECLROM_23A)
VSCDECLROM_1B6:         /* which byte lanes work (d6)? all: size it */
    moveq #15,%d3
    andb %d6,%d3
    jbeq VSCDECLROM_1C6
    cmpib #15,%d3
    jbne VSCDECLROM_198
    eorb %d3,%d6
    jbra VSCDECLROM_198
VSCDECLROM_1C6:         /* size this bank */
    lea %pc@(VSCDECLROM_1CE),%fp
    jmp %pc@(VSCDECLROM_1FE)
VSCDECLROM_1CE:         /* next */
    jbra VSCDECLROM_198
VSCDECLROM_1D0:         /* table done: sizes in d5 (4 bits per bank) */
    movel %sp,%d2
    subl %a5,%d2
    subql #8,%d2
    lsrw #1,%d2
    roll %d2,%d5
    roll %d2,%d6
    tstl %d6
    jbne VSCDECLROM_1FC
    movel %a0,%d2
    cmpil #1398893890,%d2
    jbne VSCDECLROM_1F0
    moveal %d5,%a3
    moveal %sp,%a5
    jbra VSCDECLROM_18A
VSCDECLROM_1F0:         /* no RAM in the first table: the second one */
    movel %a3,%d2
    addql #1,%d2
    jbeq VSCDECLROM_26E
    movel %a3,%d6
    exg %d6,%d5
    jbra VSCDECLROM_26E
VSCDECLROM_1FC:         /* failure: return through a2 */
    jmp %a2@
VSCDECLROM_1FE:         /* size a bank: write 'Tina' going down in steps, find where it reads back from the bank start (wrap) */
    movel %a0,%d4
    subql #4,%a1
VSCDECLROM_202:         /* one step */
    movel %a1@,%d2
    movel %d1,%a1@
VSCDECLROM_206:         /* (a bus cycle in between) */
    tstl %pc@(VSCDECLROM_206)
    cmpl %a1@,%d1
    jbeq VSCDECLROM_216
    subal %a5@,%a1
    cmpal %a0,%a1
    jbgt VSCDECLROM_202
    jbra VSCDECLROM_238
VSCDECLROM_216:         /* wrapped: the size is where it appears */
    subql #4,%a0
VSCDECLROM_218:         /* look for the copy */
    addal %a5@,%a0
    cmpl %a0@,%d1
    jbne VSCDECLROM_218
    movel %d2,%a0@+
    subal %d4,%a0
    moveq #0,%d3
    movel %a0,%d2
    jbeq VSCDECLROM_234
    movel %a5@,%d2
VSCDECLROM_22A:         /* size code = log2(size / unit) */
    addqw #1,%d3
    cmpal %d2,%a0
    jbeq VSCDECLROM_234
    addl %d2,%d2
    jbra VSCDECLROM_22A
VSCDECLROM_234:         /* add it to the total */
    orb %d3,%d5
    addl %a0,%d0
VSCDECLROM_238:         /* return through fp */
    jmp %fp@
VSCDECLROM_23A:         /* test the 4 byte lanes of the RAM at a0: d6 bits set for lanes that fail */
    movel %a0@,%d3
    movel %a0@(4),%d4
    movel %d1,%a0@
    moveq #3,%d2
VSCDECLROM_244:         /* one lane */
    movel #-1,%a0@(4)
    cmpb %a0@(0x0,%d2:w),%d1
    jbne VSCDECLROM_25E
    notb %d1
    notb %a0@(0x0,%d2:w)
    cmpb %a0@(0x0,%d2:w),%d1
    jbeq VSCDECLROM_260
VSCDECLROM_25E:         /* lane failed */
    bset %d2,%d6
VSCDECLROM_260:         /* next lane, restore */
    rorl #8,%d1
    dbf %d2,VSCDECLROM_244
    movel %d3,%a0@
    movel %d4,%a0@(4)
    jmp %fp@
VSCDECLROM_26E:         /* program the memory controller for the sizes found (per decoder kind) */
    movel %d0,%d3
    moveq #0,%d2
    moveaw #9728,%sp
    movel %a2,%d4
    lea %pc@(VSCDECLROM_286),%fp
    bigjmp hardware_table_lookup
VSCDECLROM_286:         /* jump through the table */
    moveal %d4,%a2
    addal %a1@(4),%a1
    addb %d2,%d2
    extw %d2
    movew %pc@(VSCDECLROM_29A,%d2:w),%d1
    movel %a1@+,%d2
    jmp %pc@(VSCDECLROM_29A,%d1:w)
VSCDECLROM_29A:         /* offsets per decoder kind (and raw code) */
    .short  VSCDECLROM_2B8-VSCDECLROM_29A	| 408A029A
    .short  VSCDECLROM_2B8-VSCDECLROM_29A	| 408A029C
    .short  VSCDECLROM_2B8-VSCDECLROM_29A	| 408A029E
    .short  VSCDECLROM_2B8-VSCDECLROM_29A	| 408A02A0
    .short  VSCDECLROM_2BE-VSCDECLROM_29A	| 408A02A2
    .short  VSCDECLROM_2E2-VSCDECLROM_29A	| 408A02A4
    .short  VSCDECLROM_31C-VSCDECLROM_29A	| 408A02A6
    .short  VSCDECLROM_40C-VSCDECLROM_29A	| 408A02A8
    .short  VSCDECLROM_35A-VSCDECLROM_29A	| 408A02AA
    .short  VSCDECLROM_43E-VSCDECLROM_29A	| 408A02AC
    .short  VSCDECLROM_4FC-VSCDECLROM_29A	| 408A02AE
    .short  VSCDECLROM_3C0-VSCDECLROM_29A	| 408A02B0
    .short  VSCDECLROM_43E-VSCDECLROM_29A	| 408A02B2
    .short  VSCDECLROM_52A-VSCDECLROM_29A	| 408A02B4
    .byte   0x00, 0x00	| 408A02B6
VSCDECLROM_2B8:         /* set %d1 */
    moveq #20,%d1	| 408A02B8
    jbra VSCDECLROM_5DC	| 408A02BA
VSCDECLROM_2BE:         /* set %d1 */
    moveq #15,%d1	| 408A02BE
    andb %d5,%d1	| 408A02C0
    jbne VSCDECLROM_2C8	| 408A02C2
    addqw #8,%a1	| 408A02C4
    lsrl #4,%d5	| 408A02C6
VSCDECLROM_2C8:         /* set %d0 */
    moveb %pc@(VSCDECLROM_2DA,%d1:w),%d0	| 408A02C8
    moveal %a0@(44),%a5	| 408A02CC
    andb %d0,%a5@(7680)	| 408A02D0
    moveq #28,%d1	| 408A02D4
    jbra VSCDECLROM_5DC	| 408A02D6
VSCDECLROM_2DA:         /* (data) */
    .byte   0xFF, 0x3F, 0xFF, 0x7F, 0xFF, 0xBF, 0xFF, 0xFF	| 408A02DA
VSCDECLROM_2E2:         /* from here: subal %a5,%a5 */
    subal %a5,%a5	| 408A02E2
    lea %a1@(16),%a1	| 408A02E4
VSCDECLROM_2E8:         /* loop: tst */
    tstb %d5	| 408A02E8
    jbeq VSCDECLROM_612	| 408A02EA
    subqw #8,%a1	| 408A02EE
    lsll #4,%d5	| 408A02F0
    movew %d5,%d1	| 408A02F2
    lsrw #8,%d1	| 408A02F4
    andib #15,%d1	| 408A02F6
    jbeq VSCDECLROM_2E8	| 408A02FA
    lea %pc@(VSCDECLROM_304),%fp	| 408A02FC
    jmp %pc@(VSCDECLROM_5CE)	| 408A0300
VSCDECLROM_304:         /* set %d1 */
    movel %a5,%d1	| 408A0304
    jbne VSCDECLROM_316	| 408A0306
    moveal %a1@,%a5	| 408A0308
    addal %d0,%a5	| 408A030A
    clrl %a5@-	| 408A030C
    clrl %a5@-	| 408A030E
    movel #-1,%a5@-	| 408A0310
VSCDECLROM_316:         /* set %a5@- */
    movel %d0,%a5@-	| 408A0316
    movel %a1@,%a5@-	| 408A0318
    jbra VSCDECLROM_2E8	| 408A031A
VSCDECLROM_31C:         /* set %d1 */
    movew #-3089,%d1	| 408A031C
    btst #20,%d0
    jbeq VSCDECLROM_32A
    movew #-3073,%d1
VSCDECLROM_32A:         /* (parity/RAM type bits) */
    movew %d1,%d0
    moveq #15,%d1
    andb %d5,%d1
    jbne VSCDECLROM_336
    addqw #8,%a1
    lsrl #4,%d5
VSCDECLROM_336:         /* value for the controller, shifted out 16 bits */
    andb %pc@(VSCDECLROM_352,%d1:w),%d0
    moveal %a0@(76),%a5
    moveq #15,%d1
VSCDECLROM_340:         /* one bit */
    moveb %d0,%a5@
    lsrw #1,%d0
    dbf %d1,VSCDECLROM_340
    st %a5@(16)
    moveq #28,%d1
    jbra VSCDECLROM_5DC
VSCDECLROM_352:         /* masks per size code */
    .byte   0xFF, 0xFF, 0xFF, 0x3F, 0x7F, 0xBF, 0xFF, 0xFF	| 408A0352
VSCDECLROM_35A:         /* set %d1 */
    movew %d5,%d1	| 408A035A
    swap %d5	| 408A035C
    movew %d1,%d5	| 408A035E
    movel %a1,%d6	| 408A0360
    subal %a3,%a3	| 408A0362
    moveq #0,%d3
    jbra VSCDECLROM_39A
VSCDECLROM_368:         /* loop: move */
    movel %d3,%d1	| 408A0368
    subql #1,%d1	| 408A036A
    .byte   0x4C, 0x3C, 0x10, 0x01	| 408A036C
    orib #6,%d0
    moveal %a0@(84),%a5
    lea %a5@(0x0,%d1:w:4),%a5
    movel %a3,%d1
    moveq #22,%d4
    lsrl %d4,%d1
    movew #5,%d4
VSCDECLROM_386:         /* bank base registers */
    movel %d1,%a5@+
    lsrl #1,%d1
    dbf %d4,VSCDECLROM_386
    moveal %a0@(84),%a5
    lea %a5@(160),%a5
    moveb #0xff,%a5@
VSCDECLROM_39A:         /* next bank */
    moveq #15,%d1
    andb %d5,%d1
    lsrl #4,%d5
    lea %pc@(VSCDECLROM_3A8),%fp
    jmp %pc@(VSCDECLROM_5CE)
VSCDECLROM_3A8:         /* */
    addal %d0,%a3	| 408A03A8
    tstl %a1@(8)	| 408A03AA
    jbmi VSCDECLROM_3B6	| 408A03AE
    addql #8,%a1	| 408A03B0
    addql #1,%d3	| 408A03B2
    jbra VSCDECLROM_368	| 408A03B4
VSCDECLROM_3B6:         /* set %d1 */
    moveq #44,%d1	| 408A03B6
    movel %a3,%d3	| 408A03B8
    moveal %d6,%a1	| 408A03BA
    jbra VSCDECLROM_5DC	| 408A03BC
VSCDECLROM_3C0:         /* set %a5 */
    moveal %d2,%a5	| 408A03C0
    moveq #1,%d4
    moveq #64,%d6
    movel %d5,%d1
    andib #15,%d0
    jbne VSCDECLROM_3D2
    bclr #6,%d6
VSCDECLROM_3D2:         /* size code per bank into the controller register */
    lsrl #4,%d1
VSCDECLROM_3D4:         /* one bank */
    moveb %d1,%d0
    andib #15,%d0
    jbeq VSCDECLROM_3E8
    moveb %d1,%d2
    andib #0xf0,%d2
    jbeq VSCDECLROM_3E6
    addqw #1,%d0
VSCDECLROM_3E6:         /* (bigger bank) */
    orb %d0,%d6
VSCDECLROM_3E8:         /* next */
    rorb #3,%d6
    lsrl #8,%d1
    dbf %d4,VSCDECLROM_3D4
    rorb #2,%d6
    movel %a5,%d2
    moveal %a0@(52),%a5
    moveb %a5@(1),%d0
    andib #0x80,%d0
    orb %d0,%d6
    moveb %d6,%a5@(1)
    moveq #52,%d1
    jbra VSCDECLROM_5DC
VSCDECLROM_40C:         /* set %d1 */
    moveb %d5,%d1	| 408A040C
    andiw #15,%d1	| 408A040E
VSCDECLROM_412:         /* (408A0412 moveb %pc@(VSCDECLROM_438,%d1:w),%d1 (32-) */
    .short  0x123B, 0x1120, VSCDECLROM_438-(VSCDECLROM_412+2)	| 408A0412 moveb %pc@(VSCDECLROM_438,%d1:w),%d1 (32-bit displacement form)
    moveal %a0@(52),%a5	| 408A0418
    .byte   0x02, 0x2D, 0x00, 0x3F	| 408A041C
    .short  0x0001, 0x832D	| orib #45,%d1
    .short  0x0001, 0x082D	| orib #45,%d1
    orib #1,%d5
    jbne VSCDECLROM_432
    addaw #24,%a1
VSCDECLROM_432:         /* (other configuration) */
    moveq #28,%d1
    jbra VSCDECLROM_5DC
VSCDECLROM_438:         /* (data) */
    .short  0x00FF	| 408A0438
    .long   INSTALLRDRIVERS_24	| 408A043A
VSCDECLROM_43E:         /* clear %d4 */
    moveq #0,%d4
    moveq #3,%d1
    cmpl %d1,%d5
    jbne VSCDECLROM_44A
    moveq #0,%d4
    jbra VSCDECLROM_46A
VSCDECLROM_44A:         /* (bank sizes 3 and 0x30000) */
    swap %d1
    cmpl %d1,%d5
    jbne VSCDECLROM_454
    moveq #32,%d4
    jbra VSCDECLROM_46A
VSCDECLROM_454:         /* other sizes: compute the code */
    lea %pc@(VSCDECLROM_45C),%fp
    jmp %pc@(VSCDECLROM_490)
VSCDECLROM_45C:         /* (raw words) */
    lea %pc@(VSCDECLROM_464),%fp	| 408A045C
    jmp %pc@(VSCDECLROM_490)	| 408A0460
VSCDECLROM_464:         /* (data) */
    .byte   0x70, 0x0D, 0xE1, 0x6C, 0xE0, 0xAC	| 408A0464
VSCDECLROM_46A:         /* the configuration value from the table, into three registers */
    moveb %pc@(VSCDECLROM_4BC,%d4:w),%d0
    moveal %a0@(88),%a5
    addal #65536,%a5
    moveb %d0,%a5@
    lsrb #2,%d0
    lea %a5@(8192),%a5
    moveb %d0,%a5@
    lsrb #2,%d0
    lea %a5@(8192),%a5
    moveb %d0,%a5@
    moveq #76,%d1
    jbra VSCDECLROM_5DC
VSCDECLROM_490:         /* total of the bank sizes */
    moveal %fp,%a5
    moveq #3,%d1
VSCDECLROM_494:         /* loop: swap */
    swap %d1
    movew #15,%d1
    roll #4,%d5
    andb %d5,%d1
    lea %pc@(VSCDECLROM_4A6),%fp
    jmp %pc@(VSCDECLROM_5CE)
VSCDECLROM_4A6:
    addl %d0,%d4	| 408A04A6
    swap %d1	| 408A04A8
    dbf %d1,VSCDECLROM_494	| 408A04AA
    swap %d4	| 408A04AE
    lsrw #4,%d4	| 408A04B0
    cmpib #8,%d4	| 408A04B2
    jbne VSCDECLROM_4BA	| 408A04B6
    subqb #1,%d4	| 408A04B8
VSCDECLROM_4BA:         /* jump through %a5@ */
    jmp %a5@	| 408A04BA
VSCDECLROM_4BC:         /* configuration values by bank size combination */
    .byte   0x00, 0x01, 0x01, 0x02, 0x00, 0x00, 0x00, 0x00, 0x1F, 0x13, 0x03, 0x0A, 0x09, 0x00, 0x06, 0x08	| 408A04BC
    .byte   0x1F, 0x07, 0x03, 0x12, 0x09, 0x00, 0x06, 0x08, 0x1D, 0x04, 0x04, 0x19, 0x11, 0x00, 0x0E, 0x18	| 408A04CC
    .byte   0x17, 0x09, 0x05, 0x0F, 0x1B, 0x00, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408A04DC
    .byte   0x17, 0x0B, 0x0B, 0x0C, 0x14, 0x00, 0x1A, 0x00, 0x17, 0x0D, 0x0D, 0x15, 0x17, 0x00, 0x17, 0x00	| 408A04EC
VSCDECLROM_4FC:         /* from here: bfffo %d5,0,31,%d1 */
    bfffo %d5,0,31,%d1	| 408A04FC
    negb %d1	| 408A0500
    addib #32,%d1	| 408A0502
    aslb #3,%d1	| 408A0506
    orib #31,%d1
    moveq #15,%d0
    swap %d0
    andl %d5,%d0
    swap %d0
    subqb #3,%d0
    jbeq VSCDECLROM_51C
    bclr #4,%d1
VSCDECLROM_51C:         /* controller register bits */
    moveal %a0@(52),%a5
    andb %d1,%a5@(16)
    moveq #76,%d1
    jbra VSCDECLROM_5DC
VSCDECLROM_52A:         /* address 0x50f0e004 */
    lea 0x50f0e004,%a0
    moveq #0,%d0
    subal %a3,%a3
    moveq #9,%d1
VSCDECLROM_536:         /* djMEMC-style controller: base register of each of the 10 banks */
    movel %a3,%d4
    swap %d4
    lsrw #6,%d4
    movel %a0@,%d0
    moveb %d4,%d0
    movel %d0,%a0@+
    moveq #15,%d4
    cmpib #1,%d1
    jbhi VSCDECLROM_550
    andb %d6,%d4
    rorl #4,%d6
    jbra VSCDECLROM_554
VSCDECLROM_550:         /* (banks of the second table) */
    andb %d5,%d4
    rorl #4,%d5
VSCDECLROM_554:         /* next base */
    tstb %d4
    jbeq VSCDECLROM_560
    subqw #1,%d4
    movel %d2,%d0
    lsll %d4,%d0
    addal %d0,%a3
VSCDECLROM_560:         /* next bank, then the top of memory register (0x50F0E02C) */
    dbf %d1,VSCDECLROM_536
    roll #8,%d6
    movel %a3,%d0
    swap %d0
    lsrw #6,%d0
    movel %d0,0x50f0e02c
    lea 0x50f0e000,%a0
    moveq #14,%d0
    roll #8,%d0
    andl %a0@,%d0
    jbeq VSCDECLROM_5C8
    movel %d5,%d1
    movel %d1,%d0
    rorl #4,%d0
    eorl %d0,%d1
    andil #252645135,%d1
    moveq #1,%d0
    movel %a0@,%d4
    andiw #-32,%d4
VSCDECLROM_596:         /* interleave bits for pairs of equal banks */
    tstb %d5
    jbeq VSCDECLROM_5A0
    tstb %d1
    jbne VSCDECLROM_5A0
    orw %d0,%d4
VSCDECLROM_5A0:         /* next pair */
    rorl #8,%d5
    rorl #8,%d1
    roll #1,%d0
    cmpib #16,%d0
    jbne VSCDECLROM_596
    tstb %d6
    jbeq VSCDECLROM_5C6
    moveb %d6,%d1
    moveb %d1,%d0
    andib #15,%d1
    rorb #4,%d0
    andib #15,%d0
    cmpb %d0,%d1
    jbne VSCDECLROM_5C6
    orib #16,%d4
VSCDECLROM_5C6:         /* write the configuration register */
    movel %d4,%a0@
VSCDECLROM_5C8:         /* (table entry size) */
    moveq #92,%d1
    braw VSCDECLROM_5DE
VSCDECLROM_5CE:         /* d0 = bank size for size code d1 (0: none) */
    moveq #0,%d0
    tstw %d1
    jbeq VSCDECLROM_5DA
    movel %d2,%d0
    subqw #1,%d1
    lsll %d1,%d0
VSCDECLROM_5DA:         /* return through fp */
    jmp %fp@
VSCDECLROM_5DC:         /* build the bank table (start, size) at the top of the RAM */
    moveq #0,%d6
VSCDECLROM_5DE:         /* (where it goes) */
    moveal %a1@,%a5
    moveal %a5,%a0
    addal %d3,%a5
    subal %d1,%a5
    moveal %a5,%sp
VSCDECLROM_5E8:         /* one bank */
    moveq #15,%d1
    andb %d5,%d1
    jbeq VSCDECLROM_5FC
    lea %pc@(VSCDECLROM_5F6),%fp
    jmp %pc@(VSCDECLROM_5CE)
VSCDECLROM_5F6:         /* store start and size */
    movel %a0,%sp@+
    movel %d0,%sp@+
    addal %d0,%a0
VSCDECLROM_5FC:         /* next */
    lsrl #4,%d5
    jbne VSCDECLROM_5E8
    movel %d6,%d5
    jbeq VSCDECLROM_608
    moveq #0,%d6
    jbra VSCDECLROM_5E8
VSCDECLROM_608:         /* -1 ends the table */
    subql #1,%d5
    movel %d5,%sp@+
VSCDECLROM_60C:         /* clear up to a 64 KB boundary */
    clrl %sp@+
    movew %sp,%d0
    jbne VSCDECLROM_60C
VSCDECLROM_612:         /* set %sp */
    moveal %a1@,%sp
    addal #32768,%sp
    movel %a5,%sp@-
    movel %a2,%d3
    moveq #0,%d2
    lea %pc@(VSCDECLROM_62E),%fp
    bigjmp hardware_table_lookup
VSCDECLROM_62E:         /* sound buffer at the top of the first bank? */
    moveal %sp@,%fp
    lea %pc@(VSCDECLROM_636),%a2
    jbra SIZESOUNDBUFFER
VSCDECLROM_636:         /* yes: move the table below it */
    jbeq VSCDECLROM_642
    subl %d0,%sp@
    subl %fp,%d1
VSCDECLROM_63C:         /* copy */
    moveb %a1@-,%a0@-
    subql #1,%d1
    jbgt VSCDECLROM_63C
VSCDECLROM_642:         /* return through a2 */
    moveal %d3,%a2
    moveq #0,%d6
    jmp %a2@

/*
 SIZESOUNDBUFFER: size of the sound buffer the machine (kind d2) needs at the top of
 RAM, from the table that follows. Out: d0 = size (Z if none), a1/a0 = its end and
 start in the bank table at fp.
*/
SIZESOUNDBUFFER:
    lea %pc@(SIZESOUNDBUFFER_26),%a1
    moveq #0,%d0
SIZESOUNDBUFFER_6:      /* next entry: this machine? */
    addqw #4,%a1
    movew %a1@+,%d0
    jbeq SIZESOUNDBUFFER_26
    cmpb %d2,%d0
    jbne SIZESOUNDBUFFER_6
    movel %a1@+,%d0
    moveal %fp,%a1
    jbra SIZESOUNDBUFFER_18
SIZESOUNDBUFFER_16:     /* find the last bank */
    addqw #8,%a1
SIZESOUNDBUFFER_18:     /* (end of the table: negative) */
    tstl %a1@
    jbpl SIZESOUNDBUFFER_16
    movel %a1@-,%d1
    addl %a1@-,%d1
    moveal %d1,%a1
    moveal %d1,%a0
    subal %d0,%a0
SIZESOUNDBUFFER_26:     /* return through a2 */
    tstl %d0
    jmp %a2@
    .short  0x000A, 0x0000, 0x2000, 0x0000	| 408A0672

/*
 NEWREDOMAP: build the ROM resource map: count the resources (NEWCOUNTCOMBOS), size the
 map, copy its header (RMGR), then add each ROM resource whose combination mask
 includes the one selected in XPRAM 0xAE (the machine's resource combination,
 RSRCMGRPATCH), and those of a patch ROM (ProductInfo +116) which replace ROM ones.
*/
NEWREDOMAP:
    moveml %d6-%d7,%sp@-
    moveb MMU32Bit,%d7
    movel SysMapHndl,%d0
    movel ROMMapHandle,%d1
    cmpl %d0,%d1
    jbeq NEWREDOMAP_18
    jbsr NEWCOUNTCOMBOS_74
NEWREDOMAP_18:          /* count the entries, size the map */
    moveq #0,%d6
    jbsr NEWCOUNTCOMBOS
    movel %d1,%d0
    moveal ROMMapHandle,%a0
    moveal %a0,%a4
    _SetHandleSize
    moveq #30,%d0
    biglea RMGR
    moveal %a4@,%a1
    _BlockMove
    movew #1,%a1@(20)
    clrw %sp@-
    moveal %sp,%a0
    movel #65710,%d0
    _ReadXPRam
    moveb %a0@,%d3
    addqw #2,%sp
    movel ROMBase,%d5
    moveal %d5,%a2
    addal %a2@(26),%a2
NEWREDOMAP_58:          /* walk a resource list (ROM, then the patch ROM) */
    moveq #0,%d2
    moveb %a2@(5),%d2
    movew %a2@(8),%d4
    bigjsr RSRCMGRPATCH, a3
    nop
    nop
    nop
    nop
    moveal %a2@,%a2
    addal %d5,%a2
NEWREDOMAP_78:          /* next resource: in the selected combination? */
    moveal %a2,%a0
    moveq #0,%d0
    moveb %d3,%d0
    lsrb #3,%d0
    addaw %d0,%a0
    moveb %d3,%d0
    eorib #0xff,%d0
    andib #7,%d0
    btst %d0,%a0@
    addaw %d2,%a2
    jbeq NEWREDOMAP_D8
    tstb %d6
    jbeq NEWREDOMAP_A8
    jbsr OVERWRITEROMRSRC_64
    jbsr ISDUPLICATERSRC
    jbne NEWREDOMAP_B0
    jbsr OVERWRITEROMRSRC
    braw NEWREDOMAP_D8
NEWREDOMAP_A8:          /* ROM resource: its data */
    moveal %a2@(4),%a3
    addal ROMBase,%a3
NEWREDOMAP_B0:          /* add it to the map (ADDROMRSRC) */
    moveal ROMMapHandle,%a0
    .short  0xA126	| 408A072E _HandleZone (flags 0x0100)
    movel %a3@(-4),%d0
    _StripAddress
    addal %d0,%a0
    movel %a3,%a0@
    movel %a0,%sp@-
    movel %a2@(8),%sp@-
    movew %a2@(12),%sp@-
    pea %a2@(15)
    bigjsr ADDROMRSRC
NEWREDOMAP_D8:          /* next */
    moveal %a2@,%a2
    movel %a2,%d0
    addal %d5,%a2
    jbne NEWREDOMAP_78
    tstb %d6
    jbne NEWREDOMAP_106
    btst #5,0xdd0
    jbeq NEWREDOMAP_10E
    moveal 0xdd8,%a2
    addal %a2@,%a2
    moveal %a2@(116),%a2
    movel %a2,%d5
    moveq #1,%d6
    moveq #1,%d0
    _SwapMMUMode
    addal %a2@(20),%a2
    jbra NEWREDOMAP_58
NEWREDOMAP_106:         /* patch ROM resources replaced: copy them into RAM */
    jbsr OVERWRITEROMRSRC_74
    moveb %d7,%d0
    _SwapMMUMode
NEWREDOMAP_10E:         /* map attributes, finish */
    moveal ROMMapHandle,%a1
    moveal %a1@,%a1
    movew #1,%a1@(20)
    movel SysMapHndl,%d0
    movel ROMMapHandle,%d1
    cmpl %d0,%d1
    jbeq NEWREDOMAP_12A
    jbsr DOROMENTRYPATCH_2C
NEWREDOMAP_12A:         /* return */
    moveal ROMMapHandle,%a1
    moveal %a1@,%a1
    moveml %sp@+,%d6-%d7
    rts

/*
 NEWCOUNTCOMBOS: count the ROM resources (and the patch ROM's) and the bytes their names
 need. Out: d0 = count, d1 = map size.
*/
NEWCOUNTCOMBOS:
    moveml %d2-%d7,%sp@-
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%d7
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d3
    moveq #0,%d6
    movel ROMBase,%d5
    moveal %d5,%a2
    addal %a2@(26),%a2
NEWCOUNTCOMBOS_1C:      /* walk a list */
    moveq #0,%d2
    moveb %a2@(5),%d2
    moveal %a2@,%a2
    addal %d5,%a2
NEWCOUNTCOMBOS_26:      /* next resource */
    addqw #1,%d0
    addaw %d2,%a2
    moveb %a2@(15),%d3
    addl %d3,%d1
    moveal %a2@,%a2
    movel %a2,%d4
    addal %d5,%a2
    jbne NEWCOUNTCOMBOS_26
    tstb %d6
    jbne NEWCOUNTCOMBOS_5A
    btst #5,0xdd0
    jbeq NEWCOUNTCOMBOS_5A
    moveal 0xdd8,%a2
    addal %a2@,%a2
    moveal %a2@(116),%a2
    movel %a2,%d5
    addal %a2@(20),%a2
    moveb #1,%d6
    jbra NEWCOUNTCOMBOS_1C
NEWCOUNTCOMBOS_5A:      /* map size */
    movel %d0,%d2
    moveb %d7,%d0
    _SwapMMUMode
    movel %d2,%d0
    muluw #20,%d2
    addil #28,%d2
    addl %d2,%d1
    moveml %sp@+,%d2-%d7
    rts

NEWCOUNTCOMBOS_74:      /* forget patch ROM resources that point into the ROM range */
    btst #5,0xdd0
    jbeq NEWCOUNTCOMBOS_E2
    moveml %d0-%d5/%a0-%fp,%sp@-
    moveal ROMMapHandle,%a0
    .short  0xA126	| 408A0834 _HandleZone (flags 0x0100)
    moveal TheZone,%fp
    movel %a0,TheZone
    moveal ROMMapHandle,%a4
    jbsr GETTYPES
    movel %a3,%d3
    moveal ROMBase,%a1
    movel %a1@(64),%d1
    addl %a1,%d1
NEWCOUNTCOMBOS_A4:      /* next type */
    moveq #0,%d4
    subal %a5,%a5
    movew %a2@(4),%d4
    tstw %d4
    jbeq NEWCOUNTCOMBOS_D4
    subqw #1,%d4
    moveaw %a2@(6),%a5
    addal %d3,%a5
NEWCOUNTCOMBOS_B8:      /* next resource of the type */
    moveal %a5@(8),%a4
    moveal %a4@,%a0
    cmpal %a0,%a1
    jblt NEWCOUNTCOMBOS_CC
    cmpl %a0,%d1
    jblt NEWCOUNTCOMBOS_CC
    lea %a0@(-12),%a0
    clrw %a0@
NEWCOUNTCOMBOS_CC:      /* next */
    addaw #12,%a5
    dbf %d4,NEWCOUNTCOMBOS_B8
NEWCOUNTCOMBOS_D4:      /* next type */
    addql #8,%a2
    dbf %d5,NEWCOUNTCOMBOS_A4
    movel %fp,TheZone
    moveml %sp@+,%d0-%d5/%a0-%fp
NEWCOUNTCOMBOS_E2:      /* return */
    rts
GETPATCHROMRSRCSIZE:    /* (data) */
    movel %a0,%sp@-
    moveq #0,%d0
    btst #5,0xdd0
    beqs GETPATCHROMRSRCSIZE_28
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(116),%a0
    movel %a0@(12),%d0
    addl %a0,%d0
    subil #8192,%d0
    addal %a0@(20),%a0
    subl %a0,%d0
GETPATCHROMRSRCSIZE_28:
    moveal %sp@+,%a0
    rts

/*
 ISDUPLICATERSRC: is the resource (type, ID) of the entry at a2 already in the ROM map?
 Out: Z set and a0 = its entry if so.
*/
ISDUPLICATERSRC:
    moveml %d1-%d7/%a1/%a3-%fp,%sp@-
    movel %a2,%sp@-
    moveq #0,%d0
    movel %a2@(8),%d3
    moveal ROMMapHandle,%a4
    jbsr TYPESCAN
    jbmi ISDUPLICATERSRC_38
    jbsr SKIPTOENTRY
    moveal %sp@,%a0
    movew %a0@(12),%d2
    jbsr IDSCAN
    jbne ISDUPLICATERSRC_38
    moveal %a2,%a0
    moveal %sp@+,%a2
    moveml %sp@+,%d1-%d7/%a1/%a3-%fp
    cmpb %d0,%d0
    rts
ISDUPLICATERSRC_38:     /* not there: Z clear */
    moveal %sp@+,%a2
    moveml %sp@+,%d1-%d7/%a1/%a3-%fp
    moveq #1,%d0
    rts

/*
 OVERWRITEROMRSRC: a patch ROM resource replaces the ROM one: new data pointer, and the
 name if it differs.
*/
OVERWRITEROMRSRC:
    moveml %d0-%d1/%a1-%a4,%sp@-
    moveal %a0@(8),%a1
    movel %a3,%a1@
    moveaw %a0@(2),%a1
    subal %a4,%a4
    moveq #0,%d1
    cmpaw #-1,%a1
    jbeq OVERWRITEROMRSRC_40
    moveal ROMMapHandle,%a4
    moveal %a4@,%a4
    addaw %a4@(26),%a4
    addaw %a1,%a4
    moveq #0,%d0
    moveb %a2@(15),%d0
    jbeq OVERWRITEROMRSRC_40
    cmpb %a4@+,%d0
    jbne OVERWRITEROMRSRC_40
    lea %a2@(16),%a1
    jbra OVERWRITEROMRSRC_3A
OVERWRITEROMRSRC_36:    /* compare the names */
    cmpmb %a1@+,%a4@+
    jbne OVERWRITEROMRSRC_40
OVERWRITEROMRSRC_3A:    /* (count) */
    dbf %d0,OVERWRITEROMRSRC_36
    jbra OVERWRITEROMRSRC_5E
OVERWRITEROMRSRC_40:    /* different: replace the name */
    lea %a2@(15),%a2
    movel %a2,%d0
    moveal %a0,%a2
    moveal ROMMapHandle,%a4
    moveal %a4@,%a3
    jbsr RMVENAME
    moveal %a0,%a2
    moveal %d0,%a0
    jbsr ADDNAME
OVERWRITEROMRSRC_5E:    /* return */
    moveml %sp@+,%d0-%d1/%a1-%a4
    rts

OVERWRITEROMRSRC_64:    /* a3 = the data of the patch ROM resource */
    moveal 0xdd8,%a3
    addal %a3@,%a3
    moveal %a3@(116),%a3
    addal %a2@(4),%a3
    rts

OVERWRITEROMRSRC_74:    /* copy the patch ROM's resources into RAM (LOADPATCHROMRSRC) so the map can point to them */
    moveml %d0-%d5/%a0-%a5,%sp@-
    moveal 0xdd8,%a1
    addal %a1@,%a1
    moveal %a1@(116),%a1
    movel %a1@(12),%d1
    addl %a1,%d1
    moveal ROMMapHandle,%a4
    moveq #0,%d5
    jbsr GETTYPES
    movel %a3,%d3
OVERWRITEROMRSRC_96:    /* next type */
    moveq #0,%d4
    subal %a5,%a5
    movew %a2@(4),%d4
    tstw %d4
    jbeq OVERWRITEROMRSRC_D6
    subqw #1,%d4
    moveaw %a2@(6),%a5
    addal %d3,%a5
OVERWRITEROMRSRC_AA:    /* next resource: in the patch ROM? copy it */
    moveal %a5@(8),%a4
    moveal %a4@,%a0
    cmpal %a0,%a1
    jbgt OVERWRITEROMRSRC_CE
    cmpl %a0,%d1
    jblt OVERWRITEROMRSRC_CE
    jbsr LOADPATCHROMRSRC
    movel %a3,%a4@
    moveal ROMMapHandle,%a0
    .short  0xA126	| 408A09C2 _HandleZone (flags 0x0100)
    subal %a0,%a4
    movel %a4,%a3@(-4)
    movew #-32640,%a3@(-12)
OVERWRITEROMRSRC_CE:    /* next */
    addaw #12,%a5
    dbf %d4,OVERWRITEROMRSRC_AA
OVERWRITEROMRSRC_D6:    /* next type */
    addql #8,%a2
    dbf %d5,OVERWRITEROMRSRC_96
    moveml %sp@+,%d0-%d5/%a0-%a5
    rts

OVERWRITEROMRSRC_E2:    /* grow the map and move data into it */
    moveml %d0-%d3/%a0-%a2/%a4,%sp@-
    addal %a1@(20),%a1
    movew %a1@(8),%d3
    movel %a0@(-8),%d0
    movel %d0,%d1
    moveal ROMMapHandle,%a4
    moveal %a4@,%a2
    movel %a2@(12),%d2
    jbsr RESIZEMAP
    movel %a4@,%d0
    addl %d2,%d0
    moveal %d0,%a1
    moveal %a1,%a3
    addal %d3,%a3
    movel %d1,%d0
    subal %d3,%a0
    _BlockMove
    moveml %sp@+,%d0-%d3/%a0-%a2/%a4
    rts

/* LOADPATCHROMRSRC: copy one patch ROM resource's data into the ROM map's heap block. */
LOADPATCHROMRSRC:
    moveml %d0-%d1/%a0-%a1,%sp@-
    moveal %a0,%a3
    movel TheZone,%sp@-
    moveal ROMMapHandle,%a0
    .short  0xA126	| 408A0A2A _HandleZone (flags 0x0100)
    movel %a0,TheZone
    movel %a3@(-8),%d0
    subil #12,%d0
    movel %d0,%d1
    bclr #0,%a0@(22)
    .short  0xA31E	| 408A0A42 _NewPtr (flags 0x0300)
    moveal %a0,%a1
    moveal %a3,%a0
    movel %d1,%d0
    _BlockMove
    moveal TheZone,%a0
    bset #0,%a0@(22)
    moveal %a1,%a3
    movel %sp@+,TheZone
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts

/* ADDPATCHROMSIZE: add the patch ROM's resource space to the map size. */
ADDPATCHROMSIZE:
    btst #5,0xdd0
    jbeq ADDPATCHROMSIZE_24
    movel %d2,%sp@-
    movel %d0,%d2
    moveq #1,%d0
    _SwapMMUMode
    moveal 0xdd8,%a1
    addal %a1@,%a1
    moveal %a1@(116),%a1
    addl %a1@(12),%d2
    _SwapMMUMode
    movel %d2,%d0
    movel %sp@+,%d2
ADDPATCHROMSIZE_24:     /* return */
    addw %d6,%d0
    moveal %d0,%a1
    .short  0xA51E	| 408A0A8A _NewPtr (flags 0x0500)
    rts

/* DOROMENTRYPATCH: entry of a ROM resource: a RAM copy if there is one, else the ROM. */
DOROMENTRYPATCH:
    movel %a1,%sp@-
    moveal %a2@(8),%a0
    tstl %a0
    jbeq DOROMENTRYPATCH_1E
    moveal %a0@,%a0
    moveal ROMBase,%a1
    cmpal %a1,%a0
    jbgt DOROMENTRYPATCH_1E
    moveal %a2@(8),%a0
    moveal %sp@+,%a1
    addqw #4,%sp
    rts
DOROMENTRYPATCH_1E:     /* (ROM data) */
    moveal %sp@+,%a1
    movel %sp@,%sp@-
    movel %a1,%sp@(4)
    movel %a2@(4),%d0
    rts

DOROMENTRYPATCH_2C:     /* compact the ROM map after the patch ROM resources were loaded */
    moveml %d0-%d4/%a0-%a4,%sp@-
    moveal ROMMapHandle,%a4
    moveal %a4,%a0
    .short  0xA126	| 408A0AC4 _HandleZone (flags 0x0100)
    moveal %a0,%a3
    moveal %a4@,%a0
    movel %a0@(12),%d4
    bclr #0,%a3@(22)
    movel %d4,%d0
    moveal %a4,%a0
    _SetHandleSize
    bset #0,%a3@(22)
    btst #5,0xdd0
    jbeq DOROMENTRYPATCH_A4
    moveal %a4,%a1
    moveal %a1@,%a1
    lea %a1@(-12),%a1
DOROMENTRYPATCH_62:     /* find the first free block */
    addal %a1@(4),%a1
    cmpal %a3@,%a1
    jbeq DOROMENTRYPATCH_A4
    tstw %a1@
    jbne DOROMENTRYPATCH_62
    moveal %a1,%a0
DOROMENTRYPATCH_70:     /* move each used block down */
    addal %a0@(4),%a0
    cmpal %a3@,%a0
    jbeq DOROMENTRYPATCH_AE
    tstw %a0@
    jbeq DOROMENTRYPATCH_70
    movel %a0@(4),%d0
    _BlockMove
    cmpil #-2147483648,%a1@
    jbge DOROMENTRYPATCH_8C
    nop
DOROMENTRYPATCH_8C:     /* fix its master pointer */
    moveal %a1@(8),%a2
    addal %a3,%a2
    movel %a1,%d1
    addil #12,%d1
    movel %d1,%a2@
    movel %a0@(4),%d0
    addal %d0,%a1
    jbra DOROMENTRYPATCH_70
DOROMENTRYPATCH_A4:     /* (no patch ROM) */
    moveal %a4@,%a1
    subaw #12,%a1
    addal %a1@(4),%a1
DOROMENTRYPATCH_AE:     /* move the map, shrink the block */
    addaw #16,%a1
    moveal %a3@,%a0
    movel %a0@(4),%d0
    _BlockMove
    movel %a1,%a3@
    clrl %a3@(12)
    movel %a1,%d0
    addl %a1@(4),%d0
    subl %a3,%d0
    moveal %a3,%a0
    _SetPtrSize
    moveml %sp@+,%d0-%d4/%a0-%a4
    rts
