/**
 * @file rom_symbols.h
 * @brief Macintosh Quadra 800 ROM Symbol Map & Entry Points
 *
 * Generated from comprehensive reverse engineering of QUADRA800.ROM.
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
#define SYM_EARLY_VECTOR_TABLE      0x40803D08U
#define SYM_GARY_HANDLER            0x47617279U
#define SYM_HARDWARE_TABLE_LOOKUP   0x40802F34U
#define SYM_MACHINE_TABLE           0x4080322CU

/* Memory Sizing & System Setup */
#define SYM_MEMORY_SIZING           0x4080010EU
#define SYM_SETUP_ROMBASE_SYSTEM    0x40800176U
#define SYM_VIA_TIMER_CALIBRATE     0x40800800U
#define SYM_CACHE_FLUSH_SETUP       0x40804414U

/* Trap Dispatcher & A-Traps */
#define SYM_TRAP_DISPATCHER         0x408099B0U
#define SYM_INIT_TRAP_DISPATCHER    0x40809A88U
#define SYM_UNIMPLEMENTED_TRAP      0x40809AE6U
#define SYM_COMPRESSED_TRAP_TABLE   0x408D3370U

/* Key OS Traps in ROM */
#define SYM_OS_OPEN                 0x4080B766U /* $A000 */
#define SYM_OS_CLOSE                0x4080BAAAU /* $A001 */
#define SYM_OS_READ                 0x4080BB1CU /* $A002 */
#define SYM_OS_WRITE                0x4080BB9AU /* $A003 */
#define SYM_OS_CONTROL              0x4080BBAEU /* $A004 */
#define SYM_OS_STATUS               0x4080BBBEU /* $A005 */
#define SYM_OS_KILLIO               0x4080BBE4U /* $A006 */
#define SYM_OS_NEWPTR               0x4088D360U /* $A01E */
#define SYM_OS_DISPOSPTR            0x4088D3A0U /* $A01F */
#define SYM_OS_NEWHANDLE            0x4089D448U /* $A022 */
#define SYM_OS_DISPOSHANDLE         0x4089D484U /* $A023 */
#define SYM_OS_HLOCK                0x408BD628U /* $A029 */
#define SYM_OS_HUNLOCK              0x408BD64EU /* $A02A */

/* Key Toolbox Traps in ROM */
#define SYM_TB_INITCURSOR           0x408280A0U /* $A850 */
#define SYM_TB_INITGRAF             0x40841530U /* $A86E */
#define SYM_TB_INITFONTS            0x408263B0U /* $A8FE */
#define SYM_TB_INITWINDOWS          0x4084867AU /* $A912 */
#define SYM_TB_INITMENUS            0x40848B18U /* $A916 */
#define SYM_TB_INITDIALOGS          0x408698CAU /* $A97B */
#define SYM_TB_TEINIT               0x40831F92U /* $A9CC */
#define SYM_TB_CURRESFILE           0x408BBCE8U /* $A994 */
#define SYM_TB_OPENRESFILE          0x408CAF9EU /* $A997 */
#define SYM_TB_CLOSERESFILE         0x408CAFE2U /* $A998 */
#define SYM_TB_GETRESOURCE          0x408DB5A0U /* $A9A0 */
#define SYM_TB_RELEASERESOURCE      0x408DBBDCU /* $A9A3 */

/* NuBus Declaration ROM Structures in ROM */
#define SYM_MOTHERBOARD_FORMAT_BLK  0x408FFFECU
#define SYM_MOTHERBOARD_DIR         0x408F2CA4U
#define SYM_MOTHERBOARD_BOARD_SRES  0x408F2CACU
#define SYM_VIDEO_DIR               0x40899B20U
#define SYM_VIDEO_BOARD_SRES        0x40899B80U
#define SYM_VIDEO_FUNCTIONAL_SRES   0x40899DB0U
#define SYM_VIDEO_DRIVER_CODE       0x4089A2EAU

#ifdef __cplusplus
}
#endif

#endif /* ROM_SYMBOLS_H */
