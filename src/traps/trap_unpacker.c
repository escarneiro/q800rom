/**
 * @file trap_unpacker.c
 * @brief ROM Compressed Trap Table Unpacker
 *
 * Decompiled from QUADRA800.ROM at 0x40809A88 (InitTrapDispatcher).
 *
 * The Quadra 800 ROM stores its 1,280 system traps in a highly optimized
 * variable-length compressed stream at ROM offset 0x0D3370:
 * - Bit 7 = 0: 2-byte word signed delta from previous routine address.
 * - Bit 7 = 1, byte == 0x80: Unimplemented trap (pointer to 0x40809AE6).
 * - Bit 7 = 1, byte == 0xFF: Full 32-bit absolute offset from ROMBase.
 * - Bit 7 = 1, 0x81..0xFE: Small positive delta (byte & 0x7F) * 2.
 * - 0x0000: Section / table terminator.
 */

#include "trap_unpacker.h"
#include <string.h>

#define UNIMPLEMENTED_HANDLER_OFFSET 0x00009AE6U

static inline uint32_t ReadBE32(const uint8_t *p) {
    return ((uint32_t)p[0] << 24) |
           ((uint32_t)p[1] << 16) |
           ((uint32_t)p[2] << 8)  |
           ((uint32_t)p[3]);
}

bool UnpackRomTrapTable(const uint8_t *rom_bytes,
                        uint32_t rom_base,
                        uint32_t *os_table,
                        uint32_t *tb_table) {
    if (!rom_bytes || !os_table || !tb_table) return false;

    /* Offset 0x22 in ROM header contains relative offset to compressed trap table */
    uint32_t table_rel_offset = ReadBE32(rom_bytes + 0x22);
    if (table_rel_offset >= 0x00100000U) {
        /* Fallback to observed static offset if header is not present */
        table_rel_offset = 0x000D3370U;
    }

    const uint8_t *stream = rom_bytes + table_rel_offset;
    uint32_t current_routine = rom_base;
    uint32_t unimpl_addr = rom_base + UNIMPLEMENTED_HANDLER_OFFSET;

    /* 1. Unpack 1,024 Toolbox Traps ($A800 - $ABFF / $AC00 - $AFFF) */
    for (int i = 0; i < 1024; i++) {
        uint8_t b0 = *stream++;
        if ((b0 & 0x80) == 0) {
            uint8_t b1 = *stream++;
            int16_t delta16 = (int16_t)(((uint16_t)b0 << 8) | b1);
            if (delta16 == 0) break; /* Terminator */
            current_routine += (int32_t)(delta16 * 2);
            tb_table[i] = current_routine;
        } else {
            uint8_t code = b0 & 0x7F;
            if (code == 0) {
                /* 0x80: Unimplemented routine */
                tb_table[i] = unimpl_addr;
            } else if (code == 0x7F) {
                /* 0xFF: Full 32-bit absolute offset */
                uint32_t full_off = ReadBE32(stream);
                stream += 4;
                current_routine = rom_base + full_off;
                tb_table[i] = current_routine;
            } else {
                /* Small positive delta */
                current_routine += (uint32_t)code * 2;
                tb_table[i] = current_routine;
            }
        }
    }

    /* 2. Unpack 256 OS Traps ($A000 - $A0FF) */
    for (int i = 0; i < 256; i++) {
        uint8_t b0 = *stream++;
        if ((b0 & 0x80) == 0) {
            uint8_t b1 = *stream++;
            int16_t delta16 = (int16_t)(((uint16_t)b0 << 8) | b1);
            if (delta16 == 0) break;
            current_routine += (int32_t)(delta16 * 2);
            os_table[i] = current_routine;
        } else {
            uint8_t code = b0 & 0x7F;
            if (code == 0) {
                os_table[i] = unimpl_addr;
            } else if (code == 0x7F) {
                uint32_t full_off = ReadBE32(stream);
                stream += 4;
                current_routine = rom_base + full_off;
                os_table[i] = current_routine;
            } else {
                current_routine += (uint32_t)code * 2;
                os_table[i] = current_routine;
            }
        }
    }

    return true;
}
