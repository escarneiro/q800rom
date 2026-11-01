/**
 * @file lowmem_init.c
 * @brief Low-Memory Globals and Exception Vector Table Initialization
 *
 * Decompiled from QUADRA800.ROM startup sequence:
 * - 0x4080010E to 0x40800176
 */

#include "lowmem_init.h"
#include "lowmem.h"
#include "hw_quadra.h"
#include <string.h>

/* Allocate simulated low memory on host for testing/analysis */
static uint8_t s_simulated_lowmem[0x4000];
#define SIM_LM(addr, type) (*(volatile type *)(s_simulated_lowmem + (addr)))

void InitLowMemoryGlobals(const QuadraSystemConfig *config) {
    uint32_t ram_top = QUADRA_RAM_BASE + config->ram_size_bytes;
    /* Reserve 128KB at top of RAM for screen buffer & sound buffers */
    uint32_t buf_ptr = ram_top - (128 * 1024);

    SIM_LM(LM_ADDR_MemTop, uint32_t) = ram_top;
    SIM_LM(LM_ADDR_BufPtr, uint32_t) = buf_ptr;
    SIM_LM(LM_ADDR_CPUFlag, uint8_t) = 4;
    SIM_LM(LM_ADDR_MMUFlags, uint8_t) = 1;
    SIM_LM(LM_ADDR_ROMBase, uint32_t) = QUADRA_ROM_BASE;
    SIM_LM(LM_ADDR_RAMBase, uint32_t) = QUADRA_RAM_BASE;
    SIM_LM(LM_ADDR_ROMBaseCopy, uint32_t) = QUADRA_ROM_BASE;
    SIM_LM(LM_ADDR_MachineType, uint16_t) = config->machine_id;
    SIM_LM(LM_ADDR_SysZone, uint32_t) = 0x00002800U;
    SIM_LM(LM_ADDR_ApplZone, uint32_t) = 0x00010000U;
}

void InitExceptionVectors(uint32_t trap_dispatcher_address) {
    uint32_t *vectors = (uint32_t *)s_simulated_lowmem;
    for (int i = 2; i < 256; i++) {
        vectors[i] = 0x47617279U;
    }
    vectors[10] = trap_dispatcher_address;
}
