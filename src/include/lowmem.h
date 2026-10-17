/**
 * @file lowmem.h
 * @brief Macintosh Classic Low-Memory Globals Definitions
 *
 * Defines low-memory RAM global variables (addresses $0000 to $2000).
 * Based on Apple Inside Macintosh and Mac Almanac II.
 */

#ifndef MAC_LOWMEM_H
#define MAC_LOWMEM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Address: 0x0000 | Initial Supervisor Stack Pointer */
#define LM_ADDR_ResetSSP                 0x0000U
#define LM_ResetSSP                      (*(volatile uint32_t *)(uintptr_t)(0x0000U))

/* Address: 0x0004 | Initial Program Counter (Reset Vector) */
#define LM_ADDR_ResetPC                  0x0004U
#define LM_ResetPC                       (*(volatile uint32_t *)(uintptr_t)(0x0004U))

/* Address: 0x0028 | Line 1010 Emulator (A-Line Exception) */
#define LM_ADDR_Line1010Vector           0x0028U
#define LM_Line1010Vector                (*(volatile uint32_t *)(uintptr_t)(0x0028U))

/* Address: 0x0064 | Level 1 Autovector (VIA1 Interrupt) */
#define LM_ADDR_Level1Int                0x0064U
#define LM_Level1Int                     (*(volatile uint32_t *)(uintptr_t)(0x0064U))

/* Address: 0x0068 | Level 2 Autovector (VIA2 / NuBus Slot Interrupt) */
#define LM_ADDR_Level2Int                0x0068U
#define LM_Level2Int                     (*(volatile uint32_t *)(uintptr_t)(0x0068U))

/* Address: 0x006C | Level 3 Autovector */
#define LM_ADDR_Level3Int                0x006CU
#define LM_Level3Int                     (*(volatile uint32_t *)(uintptr_t)(0x006CU))

/* Address: 0x0070 | Level 4 Autovector (SCC Serial Interrupt) */
#define LM_ADDR_Level4Int                0x0070U
#define LM_Level4Int                     (*(volatile uint32_t *)(uintptr_t)(0x0070U))

/* Address: 0x0074 | Level 5 Autovector */
#define LM_ADDR_Level5Int                0x0074U
#define LM_Level5Int                     (*(volatile uint32_t *)(uintptr_t)(0x0074U))

/* Address: 0x0078 | Level 6 Autovector */
#define LM_ADDR_Level6Int                0x0078U
#define LM_Level6Int                     (*(volatile uint32_t *)(uintptr_t)(0x0078U))

/* Address: 0x007C | Level 7 Autovector (NMI / Programmer Switch) */
#define LM_ADDR_Level7Int                0x007CU
#define LM_Level7Int                     (*(volatile uint32_t *)(uintptr_t)(0x007CU))

/* Address: 0x0100 | Start of System communication area */
#define LM_ADDR_SysCom                   0x0100U
#define LM_SysCom                        (*(volatile uint16_t *)(uintptr_t)(0x0100U))

/* Address: 0x0102 | screen vertical dots/inch */
#define LM_ADDR_ScrVRes                  0x0102U
#define LM_ScrVRes                       (*(volatile uint16_t *)(uintptr_t)(0x0102U))

/* Address: 0x0104 | screen horizontal dots/inch */
#define LM_ADDR_ScrHRes                  0x0104U
#define LM_ScrHRes                       (*(volatile uint16_t *)(uintptr_t)(0x0104U))

/* Address: 0x0106 | rowBytes of screen */
#define LM_ADDR_ScreenRow                0x0106U
#define LM_ScreenRow                     (*(volatile uint16_t *)(uintptr_t)(0x0106U))

/* Address: 0x0108 | Pointer to end of RAM */
#define LM_ADDR_MemTop                   0x0108U
#define LM_MemTop                        (*(volatile uint32_t *)(uintptr_t)(0x0108U))

/* Address: 0x010C | Pointer to bottom of sound/screen buffers (top of app memory) */
#define LM_ADDR_BufPtr                   0x010CU
#define LM_BufPtr                        (*(volatile uint32_t *)(uintptr_t)(0x010CU))

/* Address: 0x0110 | lowest stack pointer value as measured in VBL task */
#define LM_ADDR_StkLowPt                 0x0110U
#define LM_StkLowPt                      (*(volatile uint32_t *)(uintptr_t)(0x0110U))

/* Address: 0x0114 | Pointer to end of application heap */
#define LM_ADDR_HeapEnd                  0x0114U
#define LM_HeapEnd                       (*(volatile uint32_t *)(uintptr_t)(0x0114U))

/* Address: 0x0118 | Pointer to current heap zone */
#define LM_ADDR_TheZone                  0x0118U
#define LM_TheZone                       (*(volatile uint32_t *)(uintptr_t)(0x0118U))

/* Address: 0x011C | ptr to unit I/O table */
#define LM_ADDR_UTableBase               0x011CU
#define LM_UTableBase                    (*(volatile uint32_t *)(uintptr_t)(0x011CU))

/* Address: 0x0120 | ptr to jump vector table used by MacsBug */
#define LM_ADDR_MacJmp                   0x0120U
#define LM_MacJmp                        (*(volatile uint32_t *)(uintptr_t)(0x0120U))

/* Address: 0x0124 | temporary pointer used by Disk Driver */
#define LM_ADDR_DskRtnAdr                0x0124U
#define LM_DskRtnAdr                     (*(volatile uint32_t *)(uintptr_t)(0x0124U))

/* Address: 0x0128 | ptr to 'other' driver variables (Lisa 5.25" drive) */
#define LM_ADDR_PollRtnAddr              0x0128U
#define LM_PollRtnAddr                   (*(volatile uint32_t *)(uintptr_t)(0x0128U))

/* Address: 0x012F | CPU identification: 0=68000, 1=68010, 2=68020, 3=68030, 4=68040 */
#define LM_ADDR_CPUFlag                  0x012FU
#define LM_CPUFlag                       (*(volatile uint8_t *)(uintptr_t)(0x012FU))

/* Address: 0x0134 | ptr to Mac 3.5" Disk Driver variables */
#define LM_ADDR_SonyVars                 0x0134U
#define LM_SonyVars                      (*(volatile uint32_t *)(uintptr_t)(0x0134U))

/* Address: 0x0138 | current PWM value */
#define LM_ADDR_PWMValue                 0x0138U
#define LM_PWMValue                      (*(volatile uint16_t *)(uintptr_t)(0x0138U))

/* Address: 0x013A | address of SCC poll data start stack location */
#define LM_ADDR_PollStack                0x013AU
#define LM_PollStack                     (*(volatile uint32_t *)(uintptr_t)(0x013AU))

/* Address: 0x013E | ptr to SCC poll data procedure */
#define LM_ADDR_PollProc                 0x013EU
#define LM_PollProc                      (*(volatile uint32_t *)(uintptr_t)(0x013EU))

/* Address: 0x0142 | disk routine result code */
#define LM_ADDR_DskErr                   0x0142U
#define LM_DskErr                        (*(volatile uint16_t *)(uintptr_t)(0x0142U))

/* Address: 0x0144 | system event mask */
#define LM_ADDR_SysEvtMask               0x0144U
#define LM_SysEvtMask                    (*(volatile uint16_t *)(uintptr_t)(0x0144U))

/* Address: 0x0146 | ptr to system event queue element buffer */
#define LM_ADDR_SysEvtBuf                0x0146U
#define LM_SysEvtBuf                     (*(volatile uint32_t *)(uintptr_t)(0x0146U))

/* Address: 0x0154 | maximum #of events in SysEvtBuf minus 1 */
#define LM_ADDR_EvtBufCnt                0x0154U
#define LM_EvtBufCnt                     (*(volatile uint16_t *)(uintptr_t)(0x0154U))

/* Address: 0x0156 | random number seed */
#define LM_ADDR_RndSeed                  0x0156U
#define LM_RndSeed                       (*(volatile uint32_t *)(uintptr_t)(0x0156U))

/* Address: 0x015A | System file version number (e.g. System 4.1=$0410) */
#define LM_ADDR_SysVersion               0x015AU
#define LM_SysVersion                    (*(volatile uint16_t *)(uintptr_t)(0x015AU))

/* Address: 0x016A | Tick count: time since system startup (tick=1/60 sec) */
#define LM_ADDR_Ticks                    0x016AU
#define LM_Ticks                         (*(volatile uint32_t *)(uintptr_t)(0x016AU))

/* Address: 0x016E | tick count when mouse button was last pressed */
#define LM_ADDR_MBTicks                  0x016EU
#define LM_MBTicks                       (*(volatile uint32_t *)(uintptr_t)(0x016EU))

/* Address: 0x017C | bitmap for numeric keypad (uses 18 bits) */
#define LM_ADDR_KeypadMap                0x017CU
#define LM_KeypadMap                     (*(volatile uint32_t *)(uintptr_t)(0x017CU))

/* Address: 0x0180 | <unknown location> */
#define LM_ADDR_unk_0180                 0x0180U
#define LM_unk_0180                      (*(volatile uint32_t *)(uintptr_t)(0x0180U))

/* Address: 0x0184 | ASCII code for last valid keycode */
#define LM_ADDR_KeyLast                  0x0184U
#define LM_KeyLast                       (*(volatile uint16_t *)(uintptr_t)(0x0184U))

/* Address: 0x0186 | tickcount when KEYLAST was received */
#define LM_ADDR_KeyTime                  0x0186U
#define LM_KeyTime                       (*(volatile uint32_t *)(uintptr_t)(0x0186U))

/* Address: 0x018A | tick count when key was last repeated */
#define LM_ADDR_KeyRepTime               0x018AU
#define LM_KeyRepTime                    (*(volatile uint32_t *)(uintptr_t)(0x018AU))

/* Address: 0x018E | threshold for key repeat */
#define LM_ADDR_KeyThresh                0x018EU
#define LM_KeyThresh                     (*(volatile uint16_t *)(uintptr_t)(0x018EU))

/* Address: 0x0190 | key repeat speed */
#define LM_ADDR_KeyRepThresh             0x0190U
#define LM_KeyRepThresh                  (*(volatile uint16_t *)(uintptr_t)(0x0190U))

/* Address: 0x01D2 | count of entries in unit table */
#define LM_ADDR_UnitNtryCnt              0x01D2U
#define LM_UnitNtryCnt                   (*(volatile uint16_t *)(uintptr_t)(0x01D2U))

/* Address: 0x01D4 | Base pointer to VIA1 I/O space */
#define LM_ADDR_VIA                      0x01D4U
#define LM_VIA                           (*(volatile uint32_t *)(uintptr_t)(0x01D4U))

/* Address: 0x01D8 | address of Z8530 SCC chip (used when reading the chip) */
#define LM_ADDR_SCCRd                    0x01D8U
#define LM_SCCRd                         (*(volatile uint32_t *)(uintptr_t)(0x01D8U))

/* Address: 0x01DC | address of Z8530 SCC chip (used when writing the chip) */
#define LM_ADDR_SCCWr                    0x01DCU
#define LM_SCCWr                         (*(volatile uint32_t *)(uintptr_t)(0x01DCU))

/* Address: 0x01E0 | base address of IWM chip (floppy drive controller) */
#define LM_ADDR_IWM                      0x01E0U
#define LM_IWM                           (*(volatile uint32_t *)(uintptr_t)(0x01E0U))

/* Address: 0x01F8 | -System parameter RAM vars (PRAM info) */
#define LM_ADDR_SysParam                 0x01F8U
#define LM_SysParam                      (*(volatile uint8_t *)(uintptr_t)(0x01F8U))

/* Address: 0x01FC | modem port configuration (baud, parity, bits) */
#define LM_ADDR_SPPortA                  0x01FCU
#define LM_SPPortA                       (*(volatile uint16_t *)(uintptr_t)(0x01FCU))

/* Address: 0x01FE | printer port configuration (baud, parity, bits) */
#define LM_ADDR_SPPortB                  0x01FEU
#define LM_SPPortB                       (*(volatile uint16_t *)(uintptr_t)(0x01FEU))

/* Address: 0x0200 | alarm clock setting */
#define LM_ADDR_SPAlarm                  0x0200U
#define LM_SPAlarm                       (*(volatile uint32_t *)(uintptr_t)(0x0200U))

/* Address: 0x0204 | font number of application font minus 1 */
#define LM_ADDR_SPFont                   0x0204U
#define LM_SPFont                        (*(volatile uint16_t *)(uintptr_t)(0x0204U))

/* Address: 0x020C | current date/time (seconds since midnight 1 JAN 1904) */
#define LM_ADDR_Time                     0x020CU
#define LM_Time                          (*(volatile uint32_t *)(uintptr_t)(0x020CU))

/* Address: 0x0210 | working directory reference number of boot disk */
#define LM_ADDR_BootDrive                0x0210U
#define LM_BootDrive                     (*(volatile uint16_t *)(uintptr_t)(0x0210U))

/* Address: 0x0212 | journaling shell state */
#define LM_ADDR_JShell                   0x0212U
#define LM_JShell                        (*(volatile uint16_t *)(uintptr_t)(0x0212U))

/* Address: 0x0216 | <unknown location> */
#define LM_ADDR_unk_0216                 0x0216U
#define LM_unk_0216                      (*(volatile uint16_t *)(uintptr_t)(0x0216U))

/* Address: 0x021A | ptr to keyboard VBL task hook */
#define LM_ADDR_JKybdTask                0x021AU
#define LM_JKybdTask                     (*(volatile uint32_t *)(uintptr_t)(0x021AU))

/* Address: 0x0220 | Memory Manager error code */
#define LM_ADDR_MemErr                   0x0220U
#define LM_MemErr                        (*(volatile uint16_t *)(uintptr_t)(0x0220U))

/* Address: 0x0222 | -Disk driver variables (60 bytes) */
#define LM_ADDR_DiskVars                 0x0222U
#define LM_DiskVars                      (*(volatile uint8_t *)(uintptr_t)(0x0222U))

/* Address: 0x025E | mask of flushable events (FlushEvents) */
#define LM_ADDR_FlEvtMask                0x025EU
#define LM_FlEvtMask                     (*(volatile uint16_t *)(uintptr_t)(0x025EU))

/* Address: 0x0262 | pointer to 4-voice sound definition (SynthRec) */
#define LM_ADDR_SoundPtr                 0x0262U
#define LM_SoundPtr                      (*(volatile uint32_t *)(uintptr_t)(0x0262U))

/* Address: 0x0266 | ptr to free-form sound definition (SynthRec) */
#define LM_ADDR_SoundBase                0x0266U
#define LM_SoundBase                     (*(volatile uint32_t *)(uintptr_t)(0x0266U))

/* Address: 0x027A | pointer to Sound Driver's device control entry */
#define LM_ADDR_SoundDCE                 0x027AU
#define LM_SoundDCE                      (*(volatile uint32_t *)(uintptr_t)(0x027AU))

/* Address: 0x0280 | current value of COUNT in square-wave SynthRec */
#define LM_ADDR_CurPitch                 0x0280U
#define LM_CurPitch                      (*(volatile uint16_t *)(uintptr_t)(0x0280U))

/* Address: 0x0282 | address past last sound variable */
#define LM_ADDR_SoundLast                0x0282U
#define LM_SoundLast                     (*(volatile uint32_t *)(uintptr_t)(0x0282U))

/* Address: 0x0286 | <unknown location> */
#define LM_ADDR_unk_0286                 0x0286U
#define LM_unk_0286                      (*(volatile uint32_t *)(uintptr_t)(0x0286U))

/* Address: 0x028A | <unknown location> */
#define LM_ADDR_unk_028A                 0x028AU
#define LM_unk_028A                      (*(volatile uint32_t *)(uintptr_t)(0x028AU))

/* Address: 0x028E | holds a positive value if 128K or later ROM in Mac */
#define LM_ADDR_ROM85                    0x028EU
#define LM_ROM85                         (*(volatile uint16_t *)(uintptr_t)(0x028EU))

/* Address: 0x0292 | <unknown location> */
#define LM_ADDR_unk_0292                 0x0292U
#define LM_unk_0292                      (*(volatile uint32_t *)(uintptr_t)(0x0292U))

/* Address: 0x0296 | <unknown location> */
#define LM_ADDR_unk_0296                 0x0296U
#define LM_unk_0296                      (*(volatile uint32_t *)(uintptr_t)(0x0296U))

/* Address: 0x029A | ptr to GetNextEvent filter procedure */
#define LM_ADDR_JGNEFilter               0x029AU
#define LM_JGNEFilter                    (*(volatile uint32_t *)(uintptr_t)(0x029AU))

/* Address: 0x029E | ptr to keyboard translator procedure */
#define LM_ADDR_Key1Trans                0x029EU
#define LM_Key1Trans                     (*(volatile uint32_t *)(uintptr_t)(0x029EU))

/* Address: 0x02A2 | ptr to numeric keypad translator procedure */
#define LM_ADDR_Key2Trans                0x02A2U
#define LM_Key2Trans                     (*(volatile uint32_t *)(uintptr_t)(0x02A2U))

/* Address: 0x02A6 | Pointer to system heap zone header */
#define LM_ADDR_SysZone                  0x02A6U
#define LM_SysZone                       (*(volatile uint32_t *)(uintptr_t)(0x02A6U))

/* Address: 0x02AA | Pointer to application heap zone header */
#define LM_ADDR_ApplZone                 0x02AAU
#define LM_ApplZone                      (*(volatile uint32_t *)(uintptr_t)(0x02AAU))

/* Address: 0x02AE | Base address of ROM (0x40800000 on Quadra 800) */
#define LM_ADDR_ROMBase                  0x02AEU
#define LM_ROMBase                       (*(volatile uint32_t *)(uintptr_t)(0x02AEU))

/* Address: 0x02B2 | Base address of RAM (0x00000000) */
#define LM_ADDR_RAMBase                  0x02B2U
#define LM_RAMBase                       (*(volatile uint32_t *)(uintptr_t)(0x02B2U))

/* Address: 0x02B6 | ptr to BASIC globals */
#define LM_ADDR_BasicGlob                0x02B6U
#define LM_BasicGlob                     (*(volatile uint32_t *)(uintptr_t)(0x02B6U))

/* Address: 0x02BA | ptr to system error alert table in use */
#define LM_ADDR_DSAlertTab               0x02BAU
#define LM_DSAlertTab                    (*(volatile uint32_t *)(uintptr_t)(0x02BAU))

/* Address: 0x02D0 | <unknown location> */
#define LM_ADDR_unk_02D0                 0x02D0U
#define LM_unk_02D0                      (*(volatile uint32_t *)(uintptr_t)(0x02D0U))

/* Address: 0x02D4 | <unknown location> */
#define LM_ADDR_unk_02D4                 0x02D4U
#define LM_unk_02D4                      (*(volatile uint32_t *)(uintptr_t)(0x02D4U))

/* Address: 0x02D8 | ptr to AppleTalk variables */
#define LM_ADDR_ABusVars                 0x02D8U
#define LM_ABusVars                      (*(volatile uint32_t *)(uintptr_t)(0x02D8U))

/* Address: 0x02DC | <unknown location> */
#define LM_ADDR_unk_02DC                 0x02DCU
#define LM_unk_02DC                      (*(volatile uint32_t *)(uintptr_t)(0x02DCU))

/* Address: 0x02F0 | double click interval in ticks */
#define LM_ADDR_DoubleTime               0x02F0U
#define LM_DoubleTime                    (*(volatile uint32_t *)(uintptr_t)(0x02F0U))

/* Address: 0x02F4 | caret blink interval in ticks */
#define LM_ADDR_CaretTime                0x02F4U
#define LM_CaretTime                     (*(volatile uint32_t *)(uintptr_t)(0x02F4U))

/* Address: 0x02FA | <unknown location> */
#define LM_ADDR_unk_02FA                 0x02FAU
#define LM_unk_02FA                      (*(volatile uint16_t *)(uintptr_t)(0x02FAU))

/* Address: 0x02FC | File tags buffer: file number */
#define LM_ADDR_BufTgFNum                0x02FCU
#define LM_BufTgFNum                     (*(volatile uint32_t *)(uintptr_t)(0x02FCU))

/* Address: 0x0300 | File tags buffer: flags (bit1=1 if resource fork) */
#define LM_ADDR_BufTgFFlg                0x0300U
#define LM_BufTgFFlg                     (*(volatile uint16_t *)(uintptr_t)(0x0300U))

/* Address: 0x0302 | File tags buffer: logical block number */
#define LM_ADDR_BufTgFBkNum              0x0302U
#define LM_BufTgFBkNum                   (*(volatile uint16_t *)(uintptr_t)(0x0302U))

/* Address: 0x0304 | File tags buffer: last modification date/time */
#define LM_ADDR_BufTgDate                0x0304U
#define LM_BufTgDate                     (*(volatile uint32_t *)(uintptr_t)(0x0304U))

/* Address: 0x0312 | ptr to PWM buffer 1 (or 2 if sound) */
#define LM_ADDR_PWMBuf2                  0x0312U
#define LM_PWMBuf2                       (*(volatile uint32_t *)(uintptr_t)(0x0312U))

/* Address: 0x0316 | heap check RAM code */
#define LM_ADDR_HpChk                    0x0316U
#define LM_HpChk                         (*(volatile uint32_t *)(uintptr_t)(0x0316U))

/* Address: 0x031A | holds the constant $00FFFFFF */
#define LM_ADDR_Lo3Bytes                 0x031AU
#define LM_Lo3Bytes                      (*(volatile uint32_t *)(uintptr_t)(0x031AU))

/* Address: 0x031E | minimum stack size used in InitApplZone */
#define LM_ADDR_MinStack                 0x031EU
#define LM_MinStack                      (*(volatile uint32_t *)(uintptr_t)(0x031EU))

/* Address: 0x0322 | default size of stack */
#define LM_ADDR_DefltStack               0x0322U
#define LM_DefltStack                    (*(volatile uint32_t *)(uintptr_t)(0x0322U))

/* Address: 0x0326 | default zone flags */
#define LM_ADDR_MMDefFlags               0x0326U
#define LM_MMDefFlags                    (*(volatile uint16_t *)(uintptr_t)(0x0326U))

/* Address: 0x0328 | root handle for GrowZone */
#define LM_ADDR_GZRootHnd                0x0328U
#define LM_GZRootHnd                     (*(volatile uint32_t *)(uintptr_t)(0x0328U))

/* Address: 0x032C | root pointer for GrowZone */
#define LM_ADDR_GZRootPtr                0x032CU
#define LM_GZRootPtr                     (*(volatile uint32_t *)(uintptr_t)(0x032CU))

/* Address: 0x0330 | moving handle for GrowZone */
#define LM_ADDR_GZMoveHnd                0x0330U
#define LM_GZMoveHnd                     (*(volatile uint32_t *)(uintptr_t)(0x0330U))

/* Address: 0x0334 | ptr to alternate system error draw procedure */
#define LM_ADDR_DSDrawProc               0x0334U
#define LM_DSDrawProc                    (*(volatile uint32_t *)(uintptr_t)(0x0334U))

/* Address: 0x0338 | ptr to eject notify procedure */
#define LM_ADDR_EjectNotify              0x0338U
#define LM_EjectNotify                   (*(volatile uint32_t *)(uintptr_t)(0x0338U))

/* Address: 0x033C | ptr to world swaps notify procedure */
#define LM_ADDR_IAZNotify                0x033CU
#define LM_IAZNotify                     (*(volatile uint32_t *)(uintptr_t)(0x033CU))

/* Address: 0x0340 | -file system vars (184 bytes) */
#define LM_ADDR_FileVars                 0x0340U
#define LM_FileVars                      (*(volatile uint8_t *)(uintptr_t)(0x0340U))

/* Address: 0x0342 | <no description available> */
#define LM_ADDR_NxtDB                    0x0342U
#define LM_NxtDB                         (*(volatile uint16_t *)(uintptr_t)(0x0342U))

/* Address: 0x0344 | <no description available> */
#define LM_ADDR_MaxDB                    0x0344U
#define LM_MaxDB                         (*(volatile uint16_t *)(uintptr_t)(0x0344U))

/* Address: 0x0346 | flag used by UnMountVol and FlushVol */
#define LM_ADDR_FlushOnly                0x0346U
#define LM_FlushOnly                     (*(volatile uint8_t *)(uintptr_t)(0x0346U))

/* Address: 0x0347 | flag used by OpenRF and FileOpen */
#define LM_ADDR_RegRsrc                  0x0347U
#define LM_RegRsrc                       (*(volatile uint8_t *)(uintptr_t)(0x0347U))

/* Address: 0x0348 | flag used by SetFilLock and RstFilLock */
#define LM_ADDR_FLckUnlck                0x0348U
#define LM_FLckUnlck                     (*(volatile uint8_t *)(uintptr_t)(0x0348U))

/* Address: 0x0349 | when set, all file system calls are synchronized */
#define LM_ADDR_FrcSync                  0x0349U
#define LM_FrcSync                       (*(volatile uint8_t *)(uintptr_t)(0x0349U))

/* Address: 0x034C | master directory block in a volume */
#define LM_ADDR_DrMstrBlk                0x034CU
#define LM_DrMstrBlk                     (*(volatile uint16_t *)(uintptr_t)(0x034CU))

/* Address: 0x034E | ptr to file control block buffer */
#define LM_ADDR_FCBSPtr                  0x034EU
#define LM_FCBSPtr                       (*(volatile uint32_t *)(uintptr_t)(0x034EU))

/* Address: 0x0352 | ptr to default volume control block */
#define LM_ADDR_DefVCBPtr                0x0352U
#define LM_DefVCBPtr                     (*(volatile uint32_t *)(uintptr_t)(0x0352U))

/* Address: 0x036A | Temp location of stack ptr during async calls */
#define LM_ADDR_HFSStkTop                0x036AU
#define LM_HFSStkTop                     (*(volatile uint32_t *)(uintptr_t)(0x036AU))

/* Address: 0x036E | Temporary location of HFS stack ptr */
#define LM_ADDR_HFSStkPtr                0x036EU
#define LM_HFSStkPtr                     (*(volatile uint32_t *)(uintptr_t)(0x036EU))

/* Address: 0x0372 | Working Directory queue header */
#define LM_ADDR_WDCBsPtr                 0x0372U
#define LM_WDCBsPtr                      (*(volatile uint32_t *)(uintptr_t)(0x0372U))

/* Address: 0x0376 | Internal HFS flags */
#define LM_ADDR_HFSFlags                 0x0376U
#define LM_HFSFlags                      (*(volatile uint8_t *)(uintptr_t)(0x0376U))

/* Address: 0x0377 | system cache usage count now used as cache flag */
#define LM_ADDR_CacheFlag                0x0377U
#define LM_CacheFlag                     (*(volatile uint8_t *)(uintptr_t)(0x0377U))

/* Address: 0x0378 | System-wide bitmap cache pointer */
#define LM_ADDR_SysBMCPtr                0x0378U
#define LM_SysBMCPtr                     (*(volatile uint32_t *)(uintptr_t)(0x0378U))

/* Address: 0x037C | System-wide volume cache pointer */
#define LM_ADDR_SysVolCPtr               0x037CU
#define LM_SysVolCPtr                    (*(volatile uint32_t *)(uintptr_t)(0x037CU))

/* Address: 0x0380 | System-wide control cache pointer */
#define LM_ADDR_SysCtlCPtr               0x0380U
#define LM_SysCtlCPtr                    (*(volatile uint32_t *)(uintptr_t)(0x0380U))

/* Address: 0x0384 | Default volume's VRefNum/WDRefNum */
#define LM_ADDR_DefVRefNum               0x0384U
#define LM_DefVRefNum                    (*(volatile uint16_t *)(uintptr_t)(0x0384U))

/* Address: 0x0386 | ptr to list of directories on PMSP */
#define LM_ADDR_PMSPPtr                  0x0386U
#define LM_PMSPPtr                       (*(volatile uint32_t *)(uintptr_t)(0x0386U))

/* Address: 0x0392 | Final gasp - error that caused IOErr */
#define LM_ADDR_HFSDSErr                 0x0392U
#define LM_HFSDSErr                      (*(volatile uint16_t *)(uintptr_t)(0x0392U))

/* Address: 0x0394 | -End of HFS variable area */
#define LM_ADDR_HFSVarEnd                0x0394U
#define LM_HFSVarEnd                     (*(volatile uint8_t *)(uintptr_t)(0x0394U))

/* Address: 0x0398 | ID of last directory opened */
#define LM_ADDR_CurDirStore              0x0398U
#define LM_CurDirStore                   (*(volatile uint16_t *)(uintptr_t)(0x0398U))

/* Address: 0x039A | <unknown location> */
#define LM_ADDR_unk_039A                 0x039AU
#define LM_unk_039A                      (*(volatile uint16_t *)(uintptr_t)(0x039AU))

/* Address: 0x039C | <no description available> */
#define LM_ADDR_CacheCom                 0x039CU
#define LM_CacheCom                      (*(volatile uint32_t *)(uintptr_t)(0x039CU))

/* Address: 0x03A0 | <unknown location> */
#define LM_ADDR_unk_03A0                 0x03A0U
#define LM_unk_03A0                      (*(volatile uint16_t *)(uintptr_t)(0x03A0U))

/* Address: 0x03A2 | report errors here during async routines */
#define LM_ADDR_ErCode                   0x03A2U
#define LM_ErCode                        (*(volatile uint16_t *)(uintptr_t)(0x03A2U))

/* Address: 0x03A4 | -File Mgr I/O ParamBlock (50 bytes) */
#define LM_ADDR_Params                   0x03A4U
#define LM_Params                        (*(volatile uint8_t *)(uintptr_t)(0x03A4U))

/* Address: 0x03D6 | 8used by Rename */
#define LM_ADDR_FSTemp8                  0x03D6U
#define LM_FSTemp8                       (*(volatile uint8_t *)(uintptr_t)(0x03D6U))

/* Address: 0x03DE | last I/O error */
#define LM_ADDR_FSIOErr                  0x03DEU
#define LM_FSIOErr                       (*(volatile uint16_t *)(uintptr_t)(0x03DEU))

/* Address: 0x03E0 | <unknown location> */
#define LM_ADDR_unk_03E0                 0x03E0U
#define LM_unk_03E0                      (*(volatile uint16_t *)(uintptr_t)(0x03E0U))

/* Address: 0x03E2 | ptr to hook to capture all FS calls */
#define LM_ADDR_FSQueueHook              0x03E2U
#define LM_FSQueueHook                   (*(volatile uint32_t *)(uintptr_t)(0x03E2U))

/* Address: 0x03E6 | ptr to command done hook */
#define LM_ADDR_ExtFSHook                0x03E6U
#define LM_ExtFSHook                     (*(volatile uint32_t *)(uintptr_t)(0x03E6U))

/* Address: 0x03EA | ptr to hook for disk-switch dialog */
#define LM_ADDR_DskSwtchHook             0x03EAU
#define LM_DskSwtchHook                  (*(volatile uint32_t *)(uintptr_t)(0x03EAU))

/* Address: 0x03EE | ptr to offline or external file system volume */
#define LM_ADDR_ReqstVol                 0x03EEU
#define LM_ReqstVol                      (*(volatile uint32_t *)(uintptr_t)(0x03EEU))

/* Address: 0x03F2 | ptr to external file system */
#define LM_ADDR_VCBToExtFS               0x03F2U
#define LM_VCBToExtFS                    (*(volatile uint32_t *)(uintptr_t)(0x03F2U))

/* Address: 0x03F6 | size of file control block; contains -1 on 64K ROM MacsDSAlertRect$3F88rectangle for system error and disk-switch alerts */
#define LM_ADDR_FSFCBLen                 0x03F6U
#define LM_FSFCBLen                      (*(volatile uint16_t *)(uintptr_t)(0x03F6U))

/* Address: 0x0400 | Base of OS Trap dispatch table ($A000-$A7FF) */
#define LM_ADDR_OSTable                  0x0400U
#define LM_OSTable                       (*(volatile uint32_t *)(uintptr_t)(0x0400U))

/* Address: 0x0644 | External boot strap pointer */
#define LM_ADDR_ExtStrap                 0x0644U
#define LM_ExtStrap                      (*(volatile uint32_t *)(uintptr_t)(0x0644U))

/* Address: 0x06B8 | ptr to ADBReInit pre-/post-processing routine */
#define LM_ADDR_JADBProc                 0x06B8U
#define LM_JADBProc                      (*(volatile uint32_t *)(uintptr_t)(0x06B8U))

/* Address: 0x0800 | <no description available> */
#define LM_ADDR_JHideCursor              0x0800U
#define LM_JHideCursor                   (*(volatile uint32_t *)(uintptr_t)(0x0800U))

/* Address: 0x0804 | <no description available> */
#define LM_ADDR_JShowCursor              0x0804U
#define LM_JShowCursor                   (*(volatile uint32_t *)(uintptr_t)(0x0804U))

/* Address: 0x0808 | <no description available> */
#define LM_ADDR_JShieldCursor            0x0808U
#define LM_JShieldCursor                 (*(volatile uint32_t *)(uintptr_t)(0x0808U))

/* Address: 0x080C | <no description available> */
#define LM_ADDR_JScrnAddr                0x080CU
#define LM_JScrnAddr                     (*(volatile uint32_t *)(uintptr_t)(0x080CU))

/* Address: 0x0810 | <no description available> */
#define LM_ADDR_JScrnSize                0x0810U
#define LM_JScrnSize                     (*(volatile uint32_t *)(uintptr_t)(0x0810U))

/* Address: 0x0814 | <no description available> */
#define LM_ADDR_JInitCrsr                0x0814U
#define LM_JInitCrsr                     (*(volatile uint32_t *)(uintptr_t)(0x0814U))

/* Address: 0x0818 | <no description available> */
#define LM_ADDR_JSetCrsr                 0x0818U
#define LM_JSetCrsr                      (*(volatile uint32_t *)(uintptr_t)(0x0818U))

/* Address: 0x081C | <no description available> */
#define LM_ADDR_JCrsrObscure             0x081CU
#define LM_JCrsrObscure                  (*(volatile uint32_t *)(uintptr_t)(0x081CU))

/* Address: 0x0820 | <no description available> */
#define LM_ADDR_JUpdateProc              0x0820U
#define LM_JUpdateProc                   (*(volatile uint32_t *)(uintptr_t)(0x0820U))

/* Address: 0x0824 | base address of main screen */
#define LM_ADDR_ScrnBase                 0x0824U
#define LM_ScrnBase                      (*(volatile uint32_t *)(uintptr_t)(0x0824U))

/* Address: 0x0828 | low-level interrupt mouse location */
#define LM_ADDR_MTemp                    0x0828U
#define LM_MTemp                         (*(volatile uint32_t *)(uintptr_t)(0x0828U))

/* Address: 0x082C | un-jerked mouse coordinates */
#define LM_ADDR_RawMouse                 0x082CU
#define LM_RawMouse                      (*(volatile uint32_t *)(uintptr_t)(0x082CU))

/* Address: 0x0830 | processed mouse coordinate */
#define LM_ADDR_NMouse                   0x0830U
#define LM_NMouse                        (*(volatile uint32_t *)(uintptr_t)(0x0830U))

/* Address: 0x0888 | address of data under cursor */
#define LM_ADDR_CrsrAddr                 0x0888U
#define LM_CrsrAddr                      (*(volatile uint32_t *)(uintptr_t)(0x0888U))

/* Address: 0x088C | ptr to data under the cursor */
#define LM_ADDR_CrsrSave                 0x088CU
#define LM_CrsrSave                      (*(volatile uint32_t *)(uintptr_t)(0x088CU))

/* Address: 0x08A4 | handle to current main device */
#define LM_ADDR_MainDevice               0x08A4U
#define LM_MainDevice                    (*(volatile uint32_t *)(uintptr_t)(0x08A4U))

/* Address: 0x08A8 | handle to first element in device list */
#define LM_ADDR_DeviceList               0x08A8U
#define LM_DeviceList                    (*(volatile uint32_t *)(uintptr_t)(0x08A8U))

/* Address: 0x08AC | <unknown location> */
#define LM_ADDR_unk_08AC                 0x08ACU
#define LM_unk_08AC                      (*(volatile uint32_t *)(uintptr_t)(0x08ACU))

/* Address: 0x08D0 | cursor nesting level */
#define LM_ADDR_CrsrState                0x08D0U
#define LM_CrsrState                     (*(volatile uint16_t *)(uintptr_t)(0x08D0U))

/* Address: 0x08D4 | <unknown location> */
#define LM_ADDR_unk_08D4                 0x08D4U
#define LM_unk_08D4                      (*(volatile uint16_t *)(uintptr_t)(0x08D4U))

/* Address: 0x08D6 | V-H mask for ANDing with mouse */
#define LM_ADDR_MouseMask                0x08D6U
#define LM_MouseMask                     (*(volatile uint32_t *)(uintptr_t)(0x08D6U))

/* Address: 0x08DA | V-H offset for adding after ANDing */
#define LM_ADDR_MouseOffset              0x08DAU
#define LM_MouseOffset                   (*(volatile uint32_t *)(uintptr_t)(0x08DAU))

/* Address: 0x08DE | journaling state */
#define LM_ADDR_JournalFlag              0x08DEU
#define LM_JournalFlag                   (*(volatile uint16_t *)(uintptr_t)(0x08DEU))

/* Address: 0x08E0 | jump entry for FMSwapFont */
#define LM_ADDR_JSwapFont                0x08E0U
#define LM_JSwapFont                     (*(volatile uint32_t *)(uintptr_t)(0x08E0U))

/* Address: 0x08E4 | handle to a list of handles of recently-used width tablesJournalRef$8E8wordJournalling driver's refnum */
#define LM_ADDR_WidthListHand            0x08E4U
#define LM_WidthListHand                 (*(volatile uint32_t *)(uintptr_t)(0x08E4U))

/* Address: 0x08EA | <unknown location> */
#define LM_ADDR_unk_08EA                 0x08EAU
#define LM_unk_08EA                      (*(volatile uint16_t *)(uintptr_t)(0x08EAU))

/* Address: 0x08EC | delta threshold for mouse scaling */
#define LM_ADDR_CrsrThresh               0x08ECU
#define LM_CrsrThresh                    (*(volatile uint16_t *)(uintptr_t)(0x08ECU))

/* Address: 0x08EE | address of CrsrVBLTask */
#define LM_ADDR_JCrsrTask                0x08EEU
#define LM_JCrsrTask                     (*(volatile uint32_t *)(uintptr_t)(0x08EEU))

/* Address: 0x08F2 | -End of graphics globals */
#define LM_ADDR_GRAFEND                  0x08F2U
#define LM_GRAFEND                       (*(volatile uint8_t *)(uintptr_t)(0x08F2U))

/* Address: 0x08F4 | ptr to fetch-a-byte routine for drivers */
#define LM_ADDR_JFetch                   0x08F4U
#define LM_JFetch                        (*(volatile uint32_t *)(uintptr_t)(0x08F4U))

/* Address: 0x08F8 | ptr to stash-a-byte routine for drivers */
#define LM_ADDR_JStash                   0x08F8U
#define LM_JStash                        (*(volatile uint32_t *)(uintptr_t)(0x08F8U))

/* Address: 0x08FC | ptr to IODone routine for drivers */
#define LM_ADDR_JIODone                  0x08FCU
#define LM_JIODone                       (*(volatile uint32_t *)(uintptr_t)(0x08FCU))

/* Address: 0x0900 | refNum of current application's resFile */
#define LM_ADDR_CurApRefNum              0x0900U
#define LM_CurApRefNum                   (*(volatile uint16_t *)(uintptr_t)(0x0900U))

/* Address: 0x0904 | current value of register A5 */
#define LM_ADDR_CurrentA5                0x0904U
#define LM_CurrentA5                     (*(volatile uint32_t *)(uintptr_t)(0x0904U))

/* Address: 0x0908 | ptr to the base (beginning) of the stack */
#define LM_ADDR_CurStackBase             0x0908U
#define LM_CurStackBase                  (*(volatile uint32_t *)(uintptr_t)(0x0908U))

/* Address: 0x090C | <unknown location> */
#define LM_ADDR_unk_090C                 0x090CU
#define LM_unk_090C                      (*(volatile uint32_t *)(uintptr_t)(0x090CU))

/* Address: 0x0930 | handle to segment 0 (CODE 0) */
#define LM_ADDR_SaveSegHandle            0x0930U
#define LM_SaveSegHandle                 (*(volatile uint32_t *)(uintptr_t)(0x0930U))

/* Address: 0x0934 | current jump table offset from register A5 */
#define LM_ADDR_CurJTOffset              0x0934U
#define LM_CurJTOffset                   (*(volatile uint16_t *)(uintptr_t)(0x0934U))

/* Address: 0x0936 | current page 2 configuration (screen/sound buffers) */
#define LM_ADDR_CurPageOption            0x0936U
#define LM_CurPageOption                 (*(volatile uint16_t *)(uintptr_t)(0x0936U))

/* Address: 0x0938 | set to -1 if hilighting mode is on, 0 otherwise */
#define LM_ADDR_HiliteMode               0x0938U
#define LM_HiliteMode                    (*(volatile uint16_t *)(uintptr_t)(0x0938U))

/* Address: 0x0944 | Print Manager error code */
#define LM_ADDR_PrintErr                 0x0944U
#define LM_PrintErr                      (*(volatile uint16_t *)(uintptr_t)(0x0944U))

/* Address: 0x0954 | address of last printer global */
#define LM_ADDR_LastPGlobal              0x0954U
#define LM_LastPGlobal                   (*(volatile uint32_t *)(uintptr_t)(0x0954U))

/* Address: 0x0958 | <unknown location> */
#define LM_ADDR_unk_0958                 0x0958U
#define LM_unk_0958                      (*(volatile uint32_t *)(uintptr_t)(0x0958U))

/* Address: 0x095C | <unknown location> */
#define LM_ADDR_unk_095C                 0x095CU
#define LM_unk_095C                      (*(volatile uint32_t *)(uintptr_t)(0x095CU))

/* Address: 0x0960 | scrap length */
#define LM_ADDR_scrapSize                0x0960U
#define LM_scrapSize                     (*(volatile uint32_t *)(uintptr_t)(0x0960U))

/* Address: 0x0964 | handle to RAM scrap */
#define LM_ADDR_scrapHandle              0x0964U
#define LM_scrapHandle                   (*(volatile uint32_t *)(uintptr_t)(0x0964U))

/* Address: 0x0968 | count changed by ZeroScrap */
#define LM_ADDR_scrapCount               0x0968U
#define LM_scrapCount                    (*(volatile uint16_t *)(uintptr_t)(0x0968U))

/* Address: 0x096A | scrap state: tells if scrap exists in RAM or on disk */
#define LM_ADDR_scrapState               0x096AU
#define LM_scrapState                    (*(volatile uint16_t *)(uintptr_t)(0x096AU))

/* Address: 0x096C | pointer to scrap file name (normally "Clipboard File") */
#define LM_ADDR_scrapName                0x096CU
#define LM_scrapName                     (*(volatile uint32_t *)(uintptr_t)(0x096CU))

/* Address: 0x0980 | handle to system font */
#define LM_ADDR_RomFont0                 0x0980U
#define LM_RomFont0                      (*(volatile uint32_t *)(uintptr_t)(0x0980U))

/* Address: 0x0984 | font number of application font */
#define LM_ADDR_ApFontID                 0x0984U
#define LM_ApFontID                      (*(volatile uint16_t *)(uintptr_t)(0x0984U))

/* Address: 0x0988 | current font family */
#define LM_ADDR_CurFMFamily              0x0988U
#define LM_CurFMFamily                   (*(volatile uint16_t *)(uintptr_t)(0x0988U))

/* Address: 0x098A | current font size */
#define LM_ADDR_CurFMSize                0x098AU
#define LM_CurFMSize                     (*(volatile uint16_t *)(uintptr_t)(0x098AU))

/* Address: 0x098E | current font device */
#define LM_ADDR_CurFMDevice              0x098EU
#define LM_CurFMDevice                   (*(volatile uint16_t *)(uintptr_t)(0x098EU))

/* Address: 0x0990 | current numerator of scale factor */
#define LM_ADDR_CurFMNumer               0x0990U
#define LM_CurFMNumer                    (*(volatile uint32_t *)(uintptr_t)(0x0990U))

/* Address: 0x0994 | current denominator of scale factor */
#define LM_ADDR_CurFMDenom               0x0994U
#define LM_CurFMDenom                    (*(volatile uint32_t *)(uintptr_t)(0x0994U))

/* Address: 0x0998 | Font Manager error code */
#define LM_ADDR_FOutError                0x0998U
#define LM_FOutError                     (*(volatile uint16_t *)(uintptr_t)(0x0998U))

/* Address: 0x099A | handle to font bits */
#define LM_ADDR_TFOutFontHandle          0x099AU
#define LM_TFOutFontHandle               (*(volatile uint32_t *)(uintptr_t)(0x099AU))

/* Address: 0x09AA | point for numerators of scale factor */
#define LM_ADDR_FOutNumer                0x09AAU
#define LM_FOutNumer                     (*(volatile uint32_t *)(uintptr_t)(0x09AAU))

/* Address: 0x09AE | point for denominators of scale factor */
#define LM_ADDR_FOutDenom                0x09AEU
#define LM_FOutDenom                     (*(volatile uint32_t *)(uintptr_t)(0x09AEU))

/* Address: 0x09B2 | h,v dotsPerInch (resolution) of current device */
#define LM_ADDR_FMDotsPerInch            0x09B2U
#define LM_FMDotsPerInch                 (*(volatile uint32_t *)(uintptr_t)(0x09B2U))

/* Address: 0x09D6 | ptr to Z-ordered linked list of windows */
#define LM_ADDR_WindowList               0x09D6U
#define LM_WindowList                    (*(volatile uint32_t *)(uintptr_t)(0x09D6U))

/* Address: 0x09DA | Enable update events? */
#define LM_ADDR_SaveUpdate               0x09DAU
#define LM_SaveUpdate                    (*(volatile uint16_t *)(uintptr_t)(0x09DAU))

/* Address: 0x09DC | erase windows before update event? */
#define LM_ADDR_PaintWhite               0x09DCU
#define LM_PaintWhite                    (*(volatile uint16_t *)(uintptr_t)(0x09DCU))

/* Address: 0x09DE | ptr to window manager's grafport */
#define LM_ADDR_WMgrPort                 0x09DEU
#define LM_WMgrPort                      (*(volatile uint32_t *)(uintptr_t)(0x09DEU))

/* Address: 0x09E2 | ptr to Desk grafPort (Whole screen) */
#define LM_ADDR_DeskPort                 0x09E2U
#define LM_DeskPort                      (*(volatile uint32_t *)(uintptr_t)(0x09E2U))

/* Address: 0x09E6 | handle to saved structure region */
#define LM_ADDR_OldStructure             0x09E6U
#define LM_OldStructure                  (*(volatile uint32_t *)(uintptr_t)(0x09E6U))

/* Address: 0x09EA | handle to saved content region */
#define LM_ADDR_OldContent               0x09EAU
#define LM_OldContent                    (*(volatile uint32_t *)(uintptr_t)(0x09EAU))

/* Address: 0x09EE | handle to rounded-corner region drawn as the desktop */
#define LM_ADDR_GrayRgn                  0x09EEU
#define LM_GrayRgn                       (*(volatile uint32_t *)(uintptr_t)(0x09EEU))

/* Address: 0x09F2 | handle to temporarily saved visRegion */
#define LM_ADDR_SaveVisRgn               0x09F2U
#define LM_SaveVisRgn                    (*(volatile uint32_t *)(uintptr_t)(0x09F2U))

/* Address: 0x09F6 | ptr to user hook called during dragging */
#define LM_ADDR_DragHook                 0x09F6U
#define LM_DragHook                      (*(volatile uint32_t *)(uintptr_t)(0x09F6U))

/* Address: 0x0A02 | holds the constant $00010001 */
#define LM_ADDR_OneOne                   0x0A02U
#define LM_OneOne                        (*(volatile uint32_t *)(uintptr_t)(0x0A02U))

/* Address: 0x0A06 | holds the constant $FFFFFFFF */
#define LM_ADDR_MinusOne                 0x0A06U
#define LM_MinusOne                      (*(volatile uint32_t *)(uintptr_t)(0x0A06U))

/* Address: 0x0A0A | pixel value of top of scrollable menu */
#define LM_ADDR_TopMenuItem              0x0A0AU
#define LM_TopMenuItem                   (*(volatile uint16_t *)(uintptr_t)(0x0A0AU))

/* Address: 0x0A0C | flag for menu scrolling */
#define LM_ADDR_AtMenuBottom             0x0A0CU
#define LM_AtMenuBottom                  (*(volatile uint16_t *)(uintptr_t)(0x0A0CU))

/* Address: 0x0A1C | handle to current menuBar list structure */
#define LM_ADDR_MenuList                 0x0A1CU
#define LM_MenuList                      (*(volatile uint32_t *)(uintptr_t)(0x0A1CU))

/* Address: 0x0A20 | menuBar enable for desk acc's that own the menu bar */
#define LM_ADDR_MBarEnable               0x0A20U
#define LM_MBarEnable                    (*(volatile uint16_t *)(uintptr_t)(0x0A20U))

/* Address: 0x0A22 | window kind of deactivated window */
#define LM_ADDR_CurDeKind                0x0A22U
#define LM_CurDeKind                     (*(volatile uint16_t *)(uintptr_t)(0x0A22U))

/* Address: 0x0A24 | flash feedback count */
#define LM_ADDR_MenuFlash                0x0A24U
#define LM_MenuFlash                     (*(volatile uint16_t *)(uintptr_t)(0x0A24U))

/* Address: 0x0A26 | resource ID of hilited menu */
#define LM_ADDR_TheMenu                  0x0A26U
#define LM_TheMenu                       (*(volatile uint16_t *)(uintptr_t)(0x0A26U))

/* Address: 0x0A28 | handle to data under a menu */
#define LM_ADDR_SavedHandle              0x0A28U
#define LM_SavedHandle                   (*(volatile uint32_t *)(uintptr_t)(0x0A28U))

/* Address: 0x0A2C | ptr to MenuSelect hook called before menu is drawn */
#define LM_ADDR_MBarHook                 0x0A2CU
#define LM_MBarHook                      (*(volatile uint32_t *)(uintptr_t)(0x0A2CU))

/* Address: 0x0A30 | ptr to user hook called during MenuSelect */
#define LM_ADDR_MenuHook                 0x0A30U
#define LM_MenuHook                      (*(volatile uint32_t *)(uintptr_t)(0x0A30U))

/* Address: 0x0A44 | implicit parameter to DragControl */
#define LM_ADDR_DragFlag                 0x0A44U
#define LM_DragFlag                      (*(volatile uint16_t *)(uintptr_t)(0x0A44U))

/* Address: 0x0A46 | ptr to implicit actionProc for dragControl */
#define LM_ADDR_CurDragAction            0x0A46U
#define LM_CurDragAction                 (*(volatile uint32_t *)(uintptr_t)(0x0A46U))

/* Address: 0x0A50 | handle to map of most recently opened resource file */
#define LM_ADDR_TopMapHndl               0x0A50U
#define LM_TopMapHndl                    (*(volatile uint32_t *)(uintptr_t)(0x0A50U))

/* Address: 0x0A54 | handle to map of System resourc file */
#define LM_ADDR_SysMapHndl               0x0A54U
#define LM_SysMapHndl                    (*(volatile uint32_t *)(uintptr_t)(0x0A54U))

/* Address: 0x0A58 | reference number of System resource file */
#define LM_ADDR_SysMap                   0x0A58U
#define LM_SysMap                        (*(volatile uint16_t *)(uintptr_t)(0x0A58U))

/* Address: 0x0A5A | reference number of current resource file */
#define LM_ADDR_CurMap                   0x0A5AU
#define LM_CurMap                        (*(volatile uint16_t *)(uintptr_t)(0x0A5AU))

/* Address: 0x0A5C | Read-only flag */
#define LM_ADDR_ResReadOnly              0x0A5CU
#define LM_ResReadOnly                   (*(volatile uint16_t *)(uintptr_t)(0x0A5CU))

/* Address: 0x0A5E | Auto-load feature */
#define LM_ADDR_ResLoad                  0x0A5EU
#define LM_ResLoad                       (*(volatile uint16_t *)(uintptr_t)(0x0A5EU))

/* Address: 0x0A60 | Resource Manager error code */
#define LM_ADDR_ResErr                   0x0A60U
#define LM_ResErr                        (*(volatile uint16_t *)(uintptr_t)(0x0A60U))

/* Address: 0x0A64 | ptr to window slated for activate event */
#define LM_ADDR_CurActivate              0x0A64U
#define LM_CurActivate                   (*(volatile uint32_t *)(uintptr_t)(0x0A64U))

/* Address: 0x0A68 | ptr to window slated for deactivate event */
#define LM_ADDR_CurDeactive              0x0A68U
#define LM_CurDeactive                   (*(volatile uint32_t *)(uintptr_t)(0x0A68U))

/* Address: 0x0A6C | ptr to hook for painting the desk */
#define LM_ADDR_DeskHook                 0x0A6CU
#define LM_DeskHook                      (*(volatile uint32_t *)(uintptr_t)(0x0A6CU))

/* Address: 0x0A70 | ptr to textEdit doText proc hook */
#define LM_ADDR_TEDoText                 0x0A70U
#define LM_TEDoText                      (*(volatile uint32_t *)(uintptr_t)(0x0A70U))

/* Address: 0x0A74 | ptr to textEdit recalText proc hook */
#define LM_ADDR_TERecal                  0x0A74U
#define LM_TERecal                       (*(volatile uint32_t *)(uintptr_t)(0x0A74U))

/* Address: 0x0A84 | ptr to window never to be considered frontmost */
#define LM_ADDR_GhostWindow              0x0A84U
#define LM_GhostWindow                   (*(volatile uint32_t *)(uintptr_t)(0x0A84U))

/* Address: 0x0A88 | ptr to hook for closing desk ornaments */
#define LM_ADDR_CloseOrnHook             0x0A88U
#define LM_CloseOrnHook                  (*(volatile uint32_t *)(uintptr_t)(0x0A88U))

/* Address: 0x0A8C | ptr to Resume procedure (System error dialog) */
#define LM_ADDR_ResumeProc               0x0A8CU
#define LM_ResumeProc                    (*(volatile uint32_t *)(uintptr_t)(0x0A8CU))

/* Address: 0x0A90 | address of Save failsafe procedure */
#define LM_ADDR_SaveProc                 0x0A90U
#define LM_SaveProc                      (*(volatile uint32_t *)(uintptr_t)(0x0A90U))

/* Address: 0x0A94 | Safe stack ptr for restart or save */
#define LM_ADDR_SaveSP                   0x0A94U
#define LM_SaveSP                        (*(volatile uint32_t *)(uintptr_t)(0x0A94U))

/* Address: 0x0A98 | resID of last alert */
#define LM_ADDR_ANumber                  0x0A98U
#define LM_ANumber                       (*(volatile uint16_t *)(uintptr_t)(0x0A98U))

/* Address: 0x0A9A | number of times last alert was called (0 through 3) */
#define LM_ADDR_ACount                   0x0A9AU
#define LM_ACount                        (*(volatile uint16_t *)(uintptr_t)(0x0A9AU))

/* Address: 0x0A9C | ptr to current beep routine */
#define LM_ADDR_DABeeper                 0x0A9CU
#define LM_DABeeper                      (*(volatile uint32_t *)(uintptr_t)(0x0A9CU))

/* Address: 0x0AB0 | textEdit Scrap Length */
#define LM_ADDR_EScrpLengt               0x0AB0U
#define LM_EScrpLengt                    (*(volatile uint32_t *)(uintptr_t)(0x0AB0U))

/* Address: 0x0AB4 | handle to textEdit Scrap */
#define LM_ADDR_TEScrpHandl              0x0AB4U
#define LM_TEScrpHandl                   (*(volatile uint32_t *)(uintptr_t)(0x0AB4U))

/* Address: 0x0AEC | handle to hold application parameters */
#define LM_ADDR_AppParmHandle            0x0AECU
#define LM_AppParmHandle                 (*(volatile uint32_t *)(uintptr_t)(0x0AECU))

/* Address: 0x0AF0 | last (or current) system error alert ID */
#define LM_ADDR_DSErrCode                0x0AF0U
#define LM_DSErrCode                     (*(volatile uint16_t *)(uintptr_t)(0x0AF0U))

/* Address: 0x0AF2 | ptr to Resource Manager error procedure */
#define LM_ADDR_ResErrProc               0x0AF2U
#define LM_ResErrProc                    (*(volatile uint32_t *)(uintptr_t)(0x0AF2U))

/* Address: 0x0AF6 | ptr to default word break routine */
#define LM_ADDR_TEWdBreak                0x0AF6U
#define LM_TEWdBreak                     (*(volatile uint32_t *)(uintptr_t)(0x0AF6U))

/* Address: 0x0AFA | current font number for dialogs and alerts */
#define LM_ADDR_DlgFont                  0x0AFAU
#define LM_DlgFont                       (*(volatile uint16_t *)(uintptr_t)(0x0AFAU))

/* Address: 0x0AFC | address of last global */
#define LM_ADDR_LastTGLobal              0x0AFCU
#define LM_LastTGLobal                   (*(volatile uint32_t *)(uintptr_t)(0x0AFCU))

/* Address: 0x0B00 | use 4 bytes here for another trap */
#define LM_ADDR_TrapAgain                0x0B00U
#define LM_TrapAgain                     (*(volatile uint32_t *)(uintptr_t)(0x0B00U))

/* Address: 0x0B04 | <unknown location> */
#define LM_ADDR_unk_0B04                 0x0B04U
#define LM_unk_0B04                      (*(volatile uint16_t *)(uintptr_t)(0x0B04U))

/* Address: 0x0B06 | Handle to ROM resource map */
#define LM_ADDR_ROMMapHndl               0x0B06U
#define LM_ROMMapHndl                    (*(volatile uint32_t *)(uintptr_t)(0x0B06U))

/* Address: 0x0B0A | ptr to PWM buffer */
#define LM_ADDR_PWMBuf1                  0x0B0AU
#define LM_PWMBuf1                       (*(volatile uint32_t *)(uintptr_t)(0x0B0AU))

/* Address: 0x0B0E | needed during boot */
#define LM_ADDR_BootMask                 0x0B0EU
#define LM_BootMask                      (*(volatile uint16_t *)(uintptr_t)(0x0B0EU))

/* Address: 0x0B10 | ptr to global width table */
#define LM_ADDR_WidthPtr                 0x0B10U
#define LM_WidthPtr                      (*(volatile uint32_t *)(uintptr_t)(0x0B10U))

/* Address: 0x0B14 | ptr to Appletalk hook 1 */
#define LM_ADDR_AtalkHk1                 0x0B14U
#define LM_AtalkHk1                      (*(volatile uint32_t *)(uintptr_t)(0x0B14U))

/* Address: 0x0B18 | ptr to Appletalk hook 2 */
#define LM_ADDR_AtalkHk2                 0x0B18U
#define LM_AtalkHk2                      (*(volatile uint32_t *)(uintptr_t)(0x0B18U))

/* Address: 0x0B1C | <unknown location> */
#define LM_ADDR_unk_0B1C                 0x0B1CU
#define LM_unk_0B1C                      (*(volatile uint32_t *)(uintptr_t)(0x0B1CU))

/* Address: 0x0B20 | <unknown location> */
#define LM_ADDR_unk_0B20                 0x0B20U
#define LM_unk_0B20                      (*(volatile uint16_t *)(uintptr_t)(0x0B20U))

/* Address: 0x0B22 | Macintosh machine hardware type ID */
#define LM_ADDR_MachineType              0x0B22U
#define LM_MachineType                   (*(volatile uint16_t *)(uintptr_t)(0x0B22U))

/* Address: 0x0B2A | handle to global width table */
#define LM_ADDR_WidthTabHandle           0x0B2AU
#define LM_WidthTabHandle                (*(volatile uint32_t *)(uintptr_t)(0x0B2AU))

/* Address: 0x0B34 | boot drive driver reference number */
#define LM_ADDR_BtDskRfn                 0x0B34U
#define LM_BtDskRfn                      (*(volatile uint16_t *)(uintptr_t)(0x0B34U))

/* Address: 0x0B36 | 8temporary space needed by StartBoot */
#define LM_ADDR_BootTmp8                 0x0B36U
#define LM_BootTmp8                      (*(volatile uint8_t *)(uintptr_t)(0x0B36U))

/* Address: 0x0B3F | holds $FF if Timer T1 up for grabs */
#define LM_ADDR_T1Arbitrate              0x0B3FU
#define LM_T1Arbitrate                   (*(volatile uint8_t *)(uintptr_t)(0x0B3FU))

/* Address: 0x0B54 | resID and menuItem of last chosen menu item */
#define LM_ADDR_MenuDisable              0x0B54U
#define LM_MenuDisable                   (*(volatile uint32_t *)(uintptr_t)(0x0B54U))

/* Address: 0x0B80 | -RMGR variables (32 bytes) */
#define LM_ADDR_RMGRHiVars               0x0B80U
#define LM_RMGRHiVars                    (*(volatile uint8_t *)(uintptr_t)(0x0B80U))

/* Address: 0x0B9E | Flag: 0xFF to search ROM resources first */
#define LM_ADDR_RomMapInsert             0x0B9EU
#define LM_RomMapInsert                  (*(volatile uint8_t *)(uintptr_t)(0x0B9EU))

/* Address: 0x0BA0 | international software installed if not -1 */
#define LM_ADDR_ROMMapInsertIntlSpec     0x0BA0U
#define LM_ROMMapInsertIntlSpec          (*(volatile uint32_t *)(uintptr_t)(0x0BA0U))

/* Address: 0x0BA4 | <unknown location> */
#define LM_ADDR_unk_0BA4                 0x0BA4U
#define LM_unk_0BA4                      (*(volatile uint16_t *)(uintptr_t)(0x0BA4U))

/* Address: 0x0BA6 | if nonzero, the font # for system fontS */
#define LM_ADDR_SysFontFam               0x0BA6U
#define LM_SysFontFam                    (*(volatile uint16_t *)(uintptr_t)(0x0BA6U))

/* Address: 0x0BA8 | if nonzero, the system font size */
#define LM_ADDR_ysFontSize               0x0BA8U
#define LM_ysFontSize                    (*(volatile uint16_t *)(uintptr_t)(0x0BA8U))

/* Address: 0x0BAA | pixel height of menu bar */
#define LM_ADDR_MBarHeight               0x0BAAU
#define LM_MBarHeight                    (*(volatile uint16_t *)(uintptr_t)(0x0BAAU))

/* Address: 0x0BAC | <unknown location> */
#define LM_ADDR_unk_0BAC                 0x0BACU
#define LM_unk_0BAC                      (*(volatile uint32_t *)(uintptr_t)(0x0BACU))

/* Address: 0x0BC0 | formerly FlEvtMask */
#define LM_ADDR_NewUnused                0x0BC0U
#define LM_NewUnused                     (*(volatile uint16_t *)(uintptr_t)(0x0BC0U))

/* Address: 0x0BC2 | handle to last family record used */
#define LM_ADDR_LastFOND                 0x0BC2U
#define LM_LastFOND                      (*(volatile uint32_t *)(uintptr_t)(0x0BC2U))

/* Address: 0x0CB3 | MMU mode flags */
#define LM_ADDR_MMUFlags                 0x0CB3U
#define LM_MMUFlags                      (*(volatile uint8_t *)(uintptr_t)(0x0CB3U))

/* Address: 0x0CC8 | handle to current active device */
#define LM_ADDR_TheGDevice               0x0CC8U
#define LM_TheGDevice                    (*(volatile uint32_t *)(uintptr_t)(0x0CC8U))

/* Address: 0x0CD0 | auxiliary window list header */
#define LM_ADDR_AuxWinHead               0x0CD0U
#define LM_AuxWinHead                    (*(volatile uint32_t *)(uintptr_t)(0x0CD0U))

/* Address: 0x0D28 | jump vector to DoVBLTask routine */
#define LM_ADDR_JVBLTask                 0x0D28U
#define LM_JVBLTask                      (*(volatile uint32_t *)(uintptr_t)(0x0D28U))

/* Address: 0x0D32 | handle to synthetic font list */
#define LM_ADDR_SynListHandle            0x0D32U
#define LM_SynListHandle                 (*(volatile uint32_t *)(uintptr_t)(0x0D32U))

/* Address: 0x0D50 | [??]menu color info table header */
#define LM_ADDR_MenuCInfo                0x0D50U
#define LM_MenuCInfo                     (*(volatile uint8_t *)(uintptr_t)(0x0D50U))

/* Address: 0x0D9C | jump vector to DTInstall routine */
#define LM_ADDR_JDTInstall               0x0D9CU
#define LM_JDTInstall                    (*(volatile uint32_t *)(uintptr_t)(0x0D9CU))

/* Address: 0x0DA0 | [??]default hilighting color */
#define LM_ADDR_HiliteRGB                0x0DA0U
#define LM_HiliteRGB                     (*(volatile uint8_t *)(uintptr_t)(0x0DA0U))

/* Address: 0x0DD0 | Boot global parameter 0 */
#define LM_ADDR_BootGlob                 0x0DD0U
#define LM_BootGlob                      (*(volatile uint32_t *)(uintptr_t)(0x0DD0U))

/* Address: 0x0DD4 | Boot global parameter 1 */
#define LM_ADDR_WarmStart                0x0DD4U
#define LM_WarmStart                     (*(volatile uint32_t *)(uintptr_t)(0x0DD4U))

/* Address: 0x0DD8 | Boot global parameter 2 */
#define LM_ADDR_RomUnit                  0x0DD8U
#define LM_RomUnit                       (*(volatile uint32_t *)(uintptr_t)(0x0DD8U))

/* Address: 0x0DDC | Shadow copy of ROMBase */
#define LM_ADDR_ROMBaseCopy              0x0DDCU
#define LM_ROMBaseCopy                   (*(volatile uint32_t *)(uintptr_t)(0x0DDCU))

/* Address: 0x0E00 | Base of 32-bit Toolbox Trap dispatch table ($A800-$AFFF) */
#define LM_ADDR_ToolboxTable             0x0E00U
#define LM_ToolboxTable                  (*(volatile uint32_t *)(uintptr_t)(0x0E00U))

/* Address: 0x12CB | yteused by Mac 3.5" Disk Driver for read/verify */
#define LM_ADDR_DskVerify                0x12CBU
#define LM_DskVerify                     (*(volatile uint8_t *)(uintptr_t)(0x12CBU))

/* Address: 0x12DB | ytetrap before launch? */
#define LM_ADDR_LoadTrap                 0x12DBU
#define LM_LoadTrap                      (*(volatile uint8_t *)(uintptr_t)(0x12DBU))

/* Address: 0x12EB | yteInitial Memory Manager checks ok? */
#define LM_ADDR_MmInOK                   0x12EBU
#define LM_MmInOK                        (*(volatile uint8_t *)(uintptr_t)(0x12EBU))

/* Address: 0x12FB | ytecode for installed CPU: 0=68000, 1=68010, 2=68020, 3=68030ApplLimit$130longaddress of application heap limit */
#define LM_ADDR_CPUFlag_12FB             0x12FBU
#define LM_CPUFlag_12FB                  (*(volatile uint8_t *)(uintptr_t)(0x12FBU))

/* Address: 0x1400 | -start of system heap (Mac Plus & SE) */
#define LM_ADDR_HeapStart                0x1400U
#define LM_HeapStart                     (*(volatile uint8_t *)(uintptr_t)(0x1400U))

/* Address: 0x15CB | yte0 = SysEvent always returns FALSE */
#define LM_ADDR_SEvtEnb                  0x15CBU
#define LM_SEvtEnb                       (*(volatile uint8_t *)(uintptr_t)(0x15CBU))

/* Address: 0x15DB | yteGetNextEvent not to paint behind System error dialog? */
#define LM_ADDR_DSWndUpdate              0x15DBU
#define LM_DSWndUpdate                   (*(volatile uint8_t *)(uintptr_t)(0x15DBU))

/* Address: 0x15EB | ytefont manager loop flag */
#define LM_ADDR_FontFlag                 0x15EBU
#define LM_FontFlag                      (*(volatile uint8_t *)(uintptr_t)(0x15EBU))

/* Address: 0x15FB | yte1 byte of filler */
#define LM_ADDR_Filler3                  0x15FBU
#define LM_Filler3                       (*(volatile uint8_t *)(uintptr_t)(0x15FBU))

/* Address: 0x172B | ytecurrent mouse button state */
#define LM_ADDR_MBState                  0x172BU
#define LM_MBState                       (*(volatile uint8_t *)(uintptr_t)(0x172BU))

/* Address: 0x173B | yteLisa sub-tick count */
#define LM_ADDR_Tocks                    0x173BU
#define LM_Tocks                         (*(volatile uint8_t *)(uintptr_t)(0x173BU))

/* Address: 0x1C00 | -start of system heap (Mac II series and SE/30) */
#define LM_ADDR_HeapStart_1C00           0x1C00U
#define LM_HeapStart_1C00                (*(volatile uint8_t *)(uintptr_t)(0x1C00U))

/* Address: 0x1F8B | ytevalidation: $A8 if last write to clock chip was good */
#define LM_ADDR_SPValid                  0x1F8BU
#define LM_SPValid                       (*(volatile uint8_t *)(uintptr_t)(0x1F8BU))

/* Address: 0x1F9B | yteAppleTalk node ID for modem port */
#define LM_ADDR_SPATalkA                 0x1F9BU
#define LM_SPATalkA                      (*(volatile uint8_t *)(uintptr_t)(0x1F9BU))

/* Address: 0x1FAB | yteAppleTalk node ID for printer port */
#define LM_ADDR_SPATalkB                 0x1FABU
#define LM_SPATalkB                      (*(volatile uint8_t *)(uintptr_t)(0x1FABU))

/* Address: 0x1FBB | yteserial-port-in-use flags for both ports */
#define LM_ADDR_SPConfig                 0x1FBBU
#define LM_SPConfig                      (*(volatile uint8_t *)(uintptr_t)(0x1FBBU))

#ifdef __cplusplus
}
#endif

#endif /* MAC_LOWMEM_H */
