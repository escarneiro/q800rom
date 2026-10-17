/**
 * @file slot_mgr.c
 * @brief Macintosh NuBus Slot Manager Implementation
 *
 * Decompiled from QUADRA800.ROM:
 * - 0x40808C252: Slot Format Block Verification
 * - 0x40805F66: sResource validation and test pattern comparison
 */

#include "slot_mgr.h"
#include "hw_quadra.h"
#include <string.h>

#define ERR_SLOT_EMPTY      (-300)
#define ERR_BAD_TEST_PAT    (-301)
#define ERR_RES_NOT_FOUND   (-302)

OSErr MacSGetFormatBlock(uint8_t slot, NuBusFormatBlock *fb_out) {
    if (!fb_out) return -1;
    
    /* Format block resides at the top of slot declaration ROM */
    uint32_t slot_top = QUADRA_NUBUS_SLOT_BASE(slot) + 0x00FFFFFFU;
    const uint8_t *fb_bytes = (const uint8_t *)(uintptr_t)(slot_top - sizeof(NuBusFormatBlock) + 1);

#if defined(__m68k__)
    /* Probe bus memory: if bus error occurs, slot is empty */
#endif

    /* In Quadra 800 ROM, Motherboard Declaration ROM is located at 0x40800000 + 0x0FFFEC */
    if (slot == 0) {
        fb_bytes = (const uint8_t *)(QUADRA_ROM_BASE + QUADRA_ROM_SIZE - 20);
    }

    /* Verify Test Pattern: must equal 0x5A932BC7 */
    uint32_t test_pat = ((uint32_t)fb_bytes[10] << 24) |
                        ((uint32_t)fb_bytes[11] << 16) |
                        ((uint32_t)fb_bytes[12] << 8)  |
                        ((uint32_t)fb_bytes[13]);

    if (test_pat != NUBUS_TEST_PATTERN) {
        return ERR_BAD_TEST_PAT;
    }

    fb_out->testPattern = test_pat;
    fb_out->revisionLevel = fb_bytes[8];
    fb_out->format = fb_bytes[9];
    fb_out->reserved = fb_bytes[14];
    fb_out->byteLanes = fb_bytes[15];
    
    int32_t dir_off = ((int32_t)fb_bytes[0] << 24) |
                      ((int32_t)fb_bytes[1] << 16) |
                      ((int32_t)fb_bytes[2] << 8)  |
                      ((int32_t)fb_bytes[3]);
    /* Sign extend 24-bit */
    if (dir_off & 0x00800000) dir_off |= 0xFF000000;
    fb_out->directoryOffset = dir_off;

    return noErr;
}

OSErr MacSFindStruct(const uint8_t *rom_base, uint32_t sres_offset, uint8_t entry_id, uint32_t *target_offset_out) {
    if (!rom_base || !target_offset_out) return -1;

    const uint8_t *curr = rom_base + sres_offset;
    while (1) {
        uint8_t id = curr[0];
        if (id == EndOfList) break;

        int32_t offset = ((int32_t)curr[1] << 16) |
                         ((int32_t)curr[2] << 8)  |
                         ((int32_t)curr[3]);
        if (offset & 0x00800000) offset |= 0xFF000000;

        if (id == entry_id) {
            *target_offset_out = (uint32_t)((curr - rom_base) + offset);
            return noErr;
        }
        curr += 4;
    }

    return ERR_RES_NOT_FOUND;
}
