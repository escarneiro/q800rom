/*
 patches/beeppatches.s - boot beep patches (and the data that follows)
 From BOOTBEEPPATCH (0x408BD250). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple.
*/

/*
 BOOTBEEPPATCH: the boot sound, before RAM is usable (registers only, return through
 fp). With an ASC-family sound chip (a3 = its base; version at +0x800), the chime is a
 'snd ' format 1 resource played sample by sample into the chip's FIFO: BOOTCHIME_PLAIN,
 or on the 0xB0 chip version BOOTCHIME (BOOTCHIME_ALT when bit 1 of XPRAM 0x89 is set
 and XPRAM 0x10 is 0xA8). Without a sound chip version: the old square beep
 (ORIGBOOTBEEP6). Handles standard, extended (0xFF) and compressed (0xFE) headers, and
 22 kHz, 11 kHz or other rates.
*/
BOOTBEEPPATCH:
    moveq #0,%d0
    moveb %a3@(2048),%d1
    jbeq ORIGBOOTBEEP6
    movel %fp,%d5
    biglea BOOTCHIME_PLAIN
    cmpib #0xb0,%d1
    jbne BOOTBEEPPATCH_6E
    moveq #0,%d2
    lea %pc@(BOOTBEEPPATCH_2E),%fp
    bigjmp hardware_table_lookup
BOOTBEEPPATCH_2E:       /* 0xB0 chip: decoder info, read XPRAM 0x10 (RDXBYTE) */
    moveal %a0@(8),%a2
    movew #16,%d1
    lea %pc@(BOOTBEEPPATCH_44),%fp
    bigjmp RDXBYTE
BOOTBEEPPATCH_44:       /* 0xA8? then XPRAM 0x89 */
    cmpib #0xa8,%d1
    jbeq BOOTBEEPPATCH_4E
    moveq #0,%d1
    jbra BOOTBEEPPATCH_60
BOOTBEEPPATCH_4E:       /* read XPRAM 0x89 */
    movew #137,%d1
    lea %pc@(BOOTBEEPPATCH_60),%fp
    bigjmp RDXBYTE
BOOTBEEPPATCH_60:       /* the chime: BOOTCHIME, or BOOTCHIME_ALT if bit 1 */
    lea %pc@(BOOTCHIME),%a0
    btst #1,%d1
    jbeq BOOTBEEPPATCH_6E
    lea %pc@(BOOTCHIME_ALT),%a0
BOOTBEEPPATCH_6E:       /* initialise the sound chip without RAM (INITSNDNORAM) */
    movel %a0,%d6
    lea %pc@(BOOTBEEPPATCH_7E),%a5
    bigjmp INITSNDNORAM
BOOTBEEPPATCH_7E:       /* format 1? the sound header after the command */
    moveal %d6,%a0
    moveal %a3,%fp
    cmpiw #1,%a0@
    jbne BOOTBEEPPATCH_198
    lea %a0@(20),%a0
    cmpib #0,%a0@(20)
    jbne BOOTBEEPPATCH_A6
    movel %a0@(4),%d1
    movel %a0@(8),%d2
    moveq #0,%d3
    lea %a0@(22),%a0
    jbra BOOTBEEPPATCH_E4
BOOTBEEPPATCH_A6:       /* extended header (0xFF): length, rate, data at +64 */
    cmpib #0xff,%a0@(20)
    jbne BOOTBEEPPATCH_BE
    movel %a0@(22),%d1
    movel %a0@(8),%d2
    moveq #0,%d3
    lea %a0@(64),%a0
    jbra BOOTBEEPPATCH_E4
BOOTBEEPPATCH_BE:       /* compressed header (0xFE): frames x bytes per frame, compression */
    cmpib #0xfe,%a0@(20)
    jbne BOOTBEEPPATCH_198
    moveq #0,%d0
    movew %a0@(58),%d0
    lsrw #3,%d0
    movel %a0@(22),%d1
    .short  0x4C00, 0x1001	| 408BD324 mulul %d0,%d1
    movel %a0@(8),%d2
    movew %a0@(56),%d3
    lea %a0@(64),%a0
BOOTBEEPPATCH_E4:       /* 0xB0 chip: program its sample rate and format registers */
    movel %d2,%d4
    moveq #-16,%d6
    andb %fp@(2048),%d6
    cmpib #0xb0,%d6
    jbne BOOTBEEPPATCH_12C
    mulul #65535,%d0,%d2
    divul #-1404829696,%d0,%d2
    movew %d2,%fp@(3844)
    movew %d2,%fp@(3876)
    cmpiw #5,%d3
    jbne BOOTBEEPPATCH_114
    moveq #1,%d3
    jbra BOOTBEEPPATCH_120
BOOTBEEPPATCH_114:      /* MACE 6:1 (format 6): 2 */
    cmpiw #6,%d3
    jbne BOOTBEEPPATCH_11E
    moveq #2,%d3
    jbra BOOTBEEPPATCH_120
BOOTBEEPPATCH_11E:      /* uncompressed: 0 */
    moveq #0,%d3
BOOTBEEPPATCH_120:      /* format registers (both channels) */
    orib #0x80,%d3
    moveb %d3,%fp@(3848)
    moveb %d3,%fp@(3880)
BOOTBEEPPATCH_12C:      /* other chips: rate code from the rate (22254 Hz 0, 11127 Hz 1, else 2) */
    moveq #0,%d2
    cmpib #0xb0,%d6
    jbne BOOTBEEPPATCH_13A
    cmpb %fp@(3848),%d3
    jbeq BOOTBEEPPATCH_14E
BOOTBEEPPATCH_13A:      /* compare the rates */
    cmpil #1458473891,%d4
    jbeq BOOTBEEPPATCH_14E
    moveq #1,%d2
    cmpil #729236945,%d4
    jbeq BOOTBEEPPATCH_14E
    moveq #2,%d2
BOOTBEEPPATCH_14E:      /* FIFO status bit to wait on (chip dependent) */
    moveq #2,%d3
    cmpib #0xe0,%d6
    jbne BOOTBEEPPATCH_158
    moveq #0,%d3
BOOTBEEPPATCH_158:      /* repeat each sample d4 times (lower rates) */
    movel %d2,%d4
    movel %d1,%d2
    swap %d2
    movel %d4,%d6
    jbra BOOTBEEPPATCH_178
BOOTBEEPPATCH_162:      /* wait for room in the FIFO, next sample */
    moveb %fp@(2052),%d0
    btst %d3,%d0
    jbeq BOOTBEEPPATCH_162
    moveb %a0@+,%d0
BOOTBEEPPATCH_16C:      /* write it to both FIFOs (left and right) */
    moveb %d0,%fp@
    moveb %d0,%fp@(1024)
    dbf %d4,BOOTBEEPPATCH_16C
    movel %d6,%d4
BOOTBEEPPATCH_178:      /* next sample (32-bit count) */
    dbf %d1,BOOTBEEPPATCH_162
    dbf %d2,BOOTBEEPPATCH_162
    addqw #1,%d3
BOOTBEEPPATCH_182:      /* wait for the FIFO to empty, sound chip off */
    moveb %fp@(2052),%d0
    btst %d3,%d0
    jbeq BOOTBEEPPATCH_182
    lea %pc@(BOOTBEEPPATCH_198),%a5
    bigjmp INITSNDNORAM
BOOTBEEPPATCH_198:      /* return through the saved fp */
    moveal %d5,%fp
    jmp %fp@

/*
 BEEPMIXERPATCH, SPINBEEPPATCH, BATMANCHECK1..5, SPINEMPTYPATCH: patches
 called from sound/bootbeep.s: test the sound chip version (+0x800: 0xB0 "Batman",
 0xBB/0xBC) and its FIFO status (+0x804) and return to the matching place.
*/
BEEPMIXERPATCH:
    moveb %fp@(2048),%d0
    cmpib #0xbc,%d0	| 408BD3F0
    beqs BEEPMIXERPATCH_10
    cmpib #0xbb,%d0	| 408BD3F6
    bnes BEEPMIXERPATCH_24
BEEPMIXERPATCH_10:
    moveb %fp@(2052),%d0
    andib #8,%d0
    beql BEEPERLOOP
    bral BEEPMIXERDONE
BEEPMIXERPATCH_24:
    moveb %fp@(2052),%d0
    andib #2,%d0
    bral BEEPMIXERPATCHRETURN
SPINBEEPPATCH:          /* wait for the FIFO (status bits) */
    moveb %fp@(2052),%d0
    andib #4,%d0
    bnel SPINBEEPRETURN
    moveb %fp@(2052),%d0
    andib #1,%d0
    bral SPINBEEPPATCHRETURN
BATMANCHECK1:           /* is the chip 0xB0? (version & 0xF0) */
    moveb %fp@(2048),%d0
    andib #0xf0,%d0	| 408BD43E
    cmpib #0xb0,%d0
    bral BATMANCHECK1RETURN
BATMANCHECK2:           /* (same check) */
    moveb %fp@(2048),%d0
    andib #0xf0,%d0	| 408BD450
    cmpib #0xb0,%d0
    bral BATMANCHECK2RETURN
BATMANCHECK3:           /* (same check) */
    moveb %fp@(2048),%d0
    andib #0xf0,%d0	| 408BD462
    cmpib #0xb0,%d0
    bral BATMANCHECK3RETURN
BATMANCHECK4:           /* (same check) */
    moveb %fp@(2048),%d0
    andib #0xf0,%d0	| 408BD474
    cmpib #0xb0,%d0
    bral BATMANCHECK4RETURN
BATMANCHECK5:           /* (same check) */
    moveb %fp@(2048),%d0
    andib #0xf0,%d0	| 408BD486
    cmpib #0xb0,%d0
    bral BATMANCHECK5RETURN
SPINEMPTYPATCH:         /* wait for the FIFO to be empty (status bits by chip version) */
    moveb %fp@(2048),%d0
    cmpib #0xbc,%d0	| 408BD498
    beqs SPINEMPTYPATCH_10
    cmpib #0xbb,%d0	| 408BD49E
    bnes SPINEMPTYPATCH_22
SPINEMPTYPATCH_10:
    moveb %fp@(2052),%d0
    andib #12,%d0
    cmpib #12,%d0
    beql ISNTBATMAN2
SPINEMPTYPATCH_22:
    moveb %fp@(2052),%d0
    andib #3,%d0
    bral SPINEMPTYPATCHRETURN
