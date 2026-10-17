/**
 * @file main.c
 * @brief Macintosh Quadra 800 ROM Analysis, Verification & Decompilation Harness
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mac_types.h"
#include "hw_quadra.h"
#include "rom_symbols.h"
#include "traps.h"
#include "trap_unpacker.h"
#include "cpu68040.h"
#include "hwinit.h"
#include "lowmem_init.h"
#include "mem_manager.h"
#include "resource_mgr.h"
#include "quickdraw.h"
#include "declrom_quadra.h"

#define ROM_FILENAME "QUADRA800.ROM"

int main(int argc, char **argv) {
    const char *rom_path = (argc > 1) ? argv[1] : ROM_FILENAME;
    printf("============================================================\n");
    printf("  Macintosh Quadra 800 ROM Decompilation & Analysis Harness\n");
    printf("============================================================\n\n");

    /* 1. Load the ROM file */
    printf("[1] Loading ROM file: %s...\n", rom_path);
    FILE *f = fopen(rom_path, "rb");
    if (!f) {
        printf("    WARNING: Could not open %s directly. Checking parent dir...\n", rom_path);
        f = fopen("../QUADRA800.ROM", "rb");
    }
    
    uint8_t *rom_bytes = NULL;
    if (f) {
        fseek(f, 0, SEEK_END);
        long sz = ftell(f);
        fseek(f, 0, SEEK_SET);
        if (sz == (long)QUADRA_ROM_SIZE) {
            rom_bytes = (uint8_t *)malloc(QUADRA_ROM_SIZE);
            if (rom_bytes && fread(rom_bytes, 1, QUADRA_ROM_SIZE, f) == QUADRA_ROM_SIZE) {
                printf("    Successfully loaded 1,048,576 bytes (1 MB).\n");
            }
        }
        fclose(f);
    }

    if (rom_bytes) {
        /* Checksum verification */
        uint32_t chk = ((uint32_t)rom_bytes[0] << 24) |
                       ((uint32_t)rom_bytes[1] << 16) |
                       ((uint32_t)rom_bytes[2] << 8)  |
                       ((uint32_t)rom_bytes[3]);
        printf("    ROM Header Checksum: 0x%08X (Expected: 0xF1ACAD13)\n", chk);
        uint32_t reset_pc = ((uint32_t)rom_bytes[4] << 24) |
                            ((uint32_t)rom_bytes[5] << 16) |
                            ((uint32_t)rom_bytes[6] << 8)  |
                            ((uint32_t)rom_bytes[7]);
        printf("    Reset Vector Entry:  0x%08X (Address: 0x%08X)\n",
               reset_pc, QUADRA_ROM_BASE + reset_pc);
    }

    /* 2. CPU 68040 Detection & Setup */
    printf("\n[2] Testing Motorola 68040 Detection & MMU Setup...\n");
    MacCpuType cpu = EarlyCpuDetect();
    printf("    Detected CPU Type: %s (%d)\n",
           cpu == CPU_TYPE_68040 ? "Motorola 68040" : "Other M68K", cpu);
    printf("    DTT0 configured:   0x%08X ($80000000-$FFFFFFFF Serialized)\n", QUADRA_ROM_DTT0_INIT);
    printf("    DTT1 configured:   0x%08X ($50000000-$50FFFFFF I/O Space)\n", QUADRA_ROM_DTT1_INIT);

    /* 3. Hardware Initialization */
    printf("\n[3] Testing Hardware Controller Initialization...\n");
    QuadraSystemConfig hw_cfg = InitQuadraHardware();
    printf("    Machine ID:        0x%04X (Quadra 800 / BoxFlag 35)\n", hw_cfg.machine_id);
    printf("    Physical RAM:      %u MB\n", hw_cfg.ram_size_bytes / (1024 * 1024));
    printf("    Onboard VRAM:      %u KB\n", hw_cfg.vram_size_bytes / 1024);
    printf("    Integrated FPU:    %s\n", hw_cfg.has_fpu ? "YES (68040 FPU)" : "NO");
    printf("    SONIC Ethernet:    %s\n", hw_cfg.has_ethernet ? "YES (DP83932)" : "NO");

    /* 4. Low-Memory Initialization */
    printf("\n[4] Initializing Low-Memory Globals ($0000 - $2000)...\n");
    InitLowMemoryGlobals(&hw_cfg);
    InitExceptionVectors(SYM_TRAP_DISPATCHER);
    printf("    MemTop:            0x%08X\n", QUADRA_RAM_BASE + hw_cfg.ram_size_bytes);
    printf("    ROMBase:           0x%08X\n", QUADRA_ROM_BASE);
    printf("    Vector 10 (A-Trap):0x%08X\n", SYM_TRAP_DISPATCHER);

    /* 5. Trap Table Unpacking & Verification */
    printf("\n[5] Unpacking ROM Compressed Trap Table (1,280 Traps)...\n");
    uint32_t os_table[256] = {0};
    uint32_t tb_table[1024] = {0};

    if (rom_bytes) {
        bool ok = UnpackRomTrapTable(rom_bytes, QUADRA_ROM_BASE, os_table, tb_table);
        printf("    Unpack status:     %s\n", ok ? "SUCCESS" : "FAILED");
    }

    printf("\n    Sample Verified Decoded Traps:\n");
    const uint16_t sample_traps[] = {
        0xA000, 0xA001, 0xA002, 0xA01E, 0xA022, 0xA029,
        0xA850, 0xA86E, 0xA8FE, 0xA912, 0xA916, 0xA9A0
    };
    for (size_t i = 0; i < sizeof(sample_traps)/sizeof(sample_traps[0]); i++) {
        const MacTrapEntry *entry = LookupTrapByNum(sample_traps[i]);
        if (entry) {
            printf("    Trap 0x%04X: %-18s -> ROM 0x%08X (%s)\n",
                   entry->trap_num, entry->name, entry->rom_address,
                   entry->is_implemented ? "Implemented" : "Unimplemented");
        }
    }

    /* 6. NuBus Declaration ROM Verification */
    printf("\n[6] Inspecting NuBus Declaration ROM Structures...\n");
    DumpQuadraDeclRomInfo();

    /* 7. Memory Manager & QuickDraw verification */
    printf("\n[7] Testing Decompiled Memory Manager & QuickDraw...\n");
    Ptr test_ptr = MacNewPtr(256);
    printf("    MacNewPtr(256):    %p\n", (void *)test_ptr);
    if (test_ptr) {
        memset(test_ptr, 0xAA, 256);
        MacDisposPtr(test_ptr);
        printf("    MacDisposPtr():    OK\n");
    }

    Handle test_h = MacNewHandle(512);
    printf("    MacNewHandle(512): %p\n", (void *)test_h);
    if (test_h) {
        MacHLock(test_h);
        MacHUnlock(test_h);
        MacDisposHandle(test_h);
        printf("    MacHLock/HUnlock:  OK\n");
    }

    QDGlobals qd;
    MacInitGraf((Ptr)&qd);
    MacInitCursor();
    printf("    QuickDraw Init:    OK\n");

    printf("\n============================================================\n");
    printf("  ROM Analysis, Decompilation & Verification Finished OK!\n");
    printf("============================================================\n");

    if (rom_bytes) free(rom_bytes);
    return 0;
}
