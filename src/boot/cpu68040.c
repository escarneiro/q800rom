/**
 * @file cpu68040.c
 * @brief Motorola 68040 CPU Initialization and Cache/MMU Management
 *
 * Decompiled from Macintosh Quadra 800 ROM routines:
 * - 0x40804052: EarlyCpuDetect
 * - 0x40804414: CacheFlushAndSetup
 */

#include "cpu68040.h"
#include "hw_quadra.h"
#include "lowmem.h"

#if defined(__m68k__)

MacCpuType EarlyCpuDetect(void) {
    uint32_t cacr_val = 0;
    
    /* Attempt to set bit 31 (Instruction Cache Enable on 68040) */
    __asm__ __volatile__ (
        "subl   %%d0, %%d0\n\t"
        "bset   #31, %%d0\n\t"
        "movec  %%d0, %%cacr\n\t"
        "movec  %%cacr, %%d0\n\t"
        "movel  %%d0, %0"
        : "=d" (cacr_val)
        :
        : "d0"
    );

    if (cacr_val & 0x80000000U) {
        /* CPU is 68040 */
        InvalidateAllCaches();
        
        /* Clear CACR and TC (disable MMU and caches during boot) */
        __asm__ __volatile__ (
            "subl   %%d0, %%d0\n\t"
            "movec  %%d0, %%cacr\n\t"
            "movec  %%d0, %%tc"
            :
            :
            : "d0"
        );

        /* Configure Transparent Translation Registers */
        ConfigureTransparentTranslation(QUADRA_ROM_DTT0_INIT, QUADRA_ROM_DTT1_INIT);
        return CPU_TYPE_68040;
    }

    return CPU_TYPE_68030;
}

void InvalidateAllCaches(void) {
    __asm__ __volatile__ (".word 0xF4D8" ::: "memory"); /* cinva bc */
}

void PushAndInvalidateCaches(void) {
    __asm__ __volatile__ (".word 0xF4F8" ::: "memory"); /* cpusha bc */
}

void ConfigureTransparentTranslation(uint32_t dtt0_val, uint32_t dtt1_val) {
    __asm__ __volatile__ (
        "movec  %0, %%dtt0\n\t"
        "movec  %1, %%dtt1"
        :
        : "d" (dtt0_val), "d" (dtt1_val)
    );
}

void SetCacheControl(bool enable_icache, bool enable_dcache) {
    uint32_t cacr = 0;
    if (enable_icache) cacr |= M68040_CACR_IEC;
    if (enable_dcache) cacr |= M68040_CACR_DEC;
    __asm__ __volatile__ (
        "movec  %0, %%cacr"
        :
        : "d" (cacr)
    );
}

#else

/* Portable / Host Mock Implementation for Analysis & Testing */
static uint32_t s_mock_cacr = 0;
static uint32_t s_mock_tc = 0;
static uint32_t s_mock_dtt0 = 0;
static uint32_t s_mock_dtt1 = 0;

MacCpuType EarlyCpuDetect(void) {
    s_mock_cacr = 0;
    s_mock_tc = 0;
    s_mock_dtt0 = QUADRA_ROM_DTT0_INIT;
    s_mock_dtt1 = QUADRA_ROM_DTT1_INIT;
    return CPU_TYPE_68040;
}

void InvalidateAllCaches(void) {
    /* No-op on host */
}

void PushAndInvalidateCaches(void) {
    /* No-op on host */
}

void ConfigureTransparentTranslation(uint32_t dtt0_val, uint32_t dtt1_val) {
    s_mock_dtt0 = dtt0_val;
    s_mock_dtt1 = dtt1_val;
}

void SetCacheControl(bool enable_icache, bool enable_dcache) {
    s_mock_cacr = 0;
    if (enable_icache) s_mock_cacr |= M68040_CACR_IEC;
    if (enable_dcache) s_mock_cacr |= M68040_CACR_DEC;
}

#endif
