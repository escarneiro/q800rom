/**
 * @file rom_symbols.h
 * @brief Macintosh Quadra 800 ROM Symbol Map & Entry Points
 *
 * Generated from comprehensive reverse engineering of QUADRA800.ROM.
 *
 * Addresses checked against runtime evidence (see analysis/README.md):
 * trap entry points come from the dispatch tables the ROM installs (QEMU boot),
 * code entries were executed in QEMU traces, and data structures were checked
 * against the bytes in the ROM.
 */

#ifndef ROM_SYMBOLS_H
#define ROM_SYMBOLS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ROM Header and Reset Vectors */
#define SYM_ROM_START               0x40800000U
#define SYM_RESET_PC                0x4080002AU
#define SYM_WARM_RESET              0x4080005CU
#define SYM_RESET_STARTUP           0x4080008CU
#define SYM_HARDWARE_RESET          0x4080009CU

/* Early CPU and Architecture Setup */
#define SYM_EARLY_CPU_DETECT        0x40804052U
#define SYM_SETUP_EARLY_VBR         0x40802E00U
#define SYM_EARLY_VECTOR_TABLE      0x40803D00U /* VBR set at 0x40802E1C (match at 0x40803D08, minus 8) */
#define SYM_GARY_HANDLER            0x47617279U /* NOT an address: ASCII 'Gary' marker value */
#define SYM_HARDWARE_TABLE_LOOKUP   0x40802F34U
#define SYM_MACHINE_TABLE           0x4080322CU

/* Memory Sizing & System Setup */
#define SYM_MEMORY_SIZING           0x4080010EU
#define SYM_SETUP_ROMBASE_SYSTEM    0x40800176U
#define SYM_VIA_TIMER_CALIBRATE     0x40800800U
#define SYM_CACHE_FLUSH_SETUP       0x40804414U

/* Trap Dispatcher & A-Traps */
#define SYM_TRAP_DISPATCHER         0x408099B0U
#define SYM_INIT_TRAP_DISPATCHER    0x40809A96U /* entry executed at boot; also ROM header vector at +0x44 */
#define SYM_UNIMPLEMENTED_TRAP      0x40809AE6U
#define SYM_COMPRESSED_TRAP_TABLE   0x408D3370U

/* Key OS Traps in ROM */
#define SYM_OS_OPEN                 0x4080B766U /* $A000 _Open */
#define SYM_OS_CLOSE                0x4080BAAAU /* $A001 _Close */
#define SYM_OS_READ                 0x4080BB1CU /* $A002 _Read */
#define SYM_OS_WRITE                0x4080BB9AU /* $A003 _Write */
#define SYM_OS_CONTROL              0x4080BBAEU /* $A004 _Control */
#define SYM_OS_STATUS               0x4080BBBEU /* $A005 _Status */
#define SYM_OS_KILLIO               0x4080BBE4U /* $A006 _KillIO */
#define SYM_OS_NEWPTR               0x4080D360U /* $A01E _NewPtr */
#define SYM_OS_DISPOSPTR            0x4080D3A0U /* $A01F _DisposPtr */
#define SYM_OS_NEWHANDLE            0x4080D448U /* $A022 _NewHandle */
#define SYM_OS_DISPOSHANDLE         0x4080D484U /* $A023 _DisposHandle */
#define SYM_OS_HLOCK                0x4080D628U /* $A029 _HLock */
#define SYM_OS_HUNLOCK              0x4080D64EU /* $A02A _HUnlock */

/* Key Toolbox Traps in ROM */
#define SYM_TB_INITCURSOR           0x408280A0U /* $A850 _InitCursor */
#define SYM_TB_INITGRAF             0x40831530U /* $A86E _InitGraf */
#define SYM_TB_INITFONTS            0x408263B0U /* $A8FE _InitFonts */
#define SYM_TB_INITWINDOWS          0x4081867AU /* $A912 _InitWindows */
#define SYM_TB_INITMENUS            0x40816D50U /* $A930 _InitMenus */
#define SYM_TB_INITDIALOGS          0x408198CAU /* $A97B _InitDialogs */
#define SYM_TB_TEINIT               0x40821F92U /* $A9CC _TEInit */
#define SYM_TB_CURRESFILE           0x4081BCE8U /* $A994 _CurResFile */
#define SYM_TB_OPENRESFILE          0x4081AF9EU /* $A997 _OpenResFile */
#define SYM_TB_CLOSERESFILE         0x4081B388U /* $A99A _CloseResFile */
#define SYM_TB_GETRESOURCE          0x4081B5A0U /* $A9A0 _GetResource */
#define SYM_TB_RELEASERESOURCE      0x4081BBDCU /* $A9A3 _ReleaseResource */

/* NuBus Declaration ROM Structures in ROM */
#define SYM_MOTHERBOARD_FORMAT_BLK  0x408FFFECU
#define SYM_MOTHERBOARD_DIR         0x408F2CA4U
#define SYM_MOTHERBOARD_BOARD_SRES  0x408F2CACU
#define SYM_VIDEO_DIR               0x40899B20U
#define SYM_VIDEO_BOARD_SRES        0x40899B80U
#define SYM_VIDEO_FUNCTIONAL_SRES   0x40899DB0U
#define SYM_VIDEO_DRIVER_DIR        0x4089A2EAU /* sRsrcDrvrDir of the video sResource */
#define SYM_VIDEO_DRIVER_CODE       0x4089BCC4U /* DRVR .Display_Video_Apple_ViSC (sBlock at 0x4089BCC0) */

#ifdef __cplusplus
}
#endif

#endif /* ROM_SYMBOLS_H */
