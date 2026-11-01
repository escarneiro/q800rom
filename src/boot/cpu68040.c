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

