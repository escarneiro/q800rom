/**
 * @file trap_unpacker.h
 * @brief ROM Compressed Trap Table Unpacker
 */

#ifndef TRAP_UNPACKER_H
#define TRAP_UNPACKER_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Unpacks the compressed ROM trap table into memory.
 * Decompiled from QUADRA800.ROM at 0x40809A88.
 *
 * @param rom_bytes Pointer to 1MB ROM binary image
 * @param rom_base Virtual base address of the ROM (0x40800000)
 * @param os_table Destination buffer for 256 OS Trap pointers (0x0400)
 * @param tb_table Destination buffer for 1024 Toolbox Trap pointers (0x0E00)
 * @return true if unpacking completed successfully, false otherwise.
 */
bool UnpackRomTrapTable(const uint8_t *rom_bytes,
                        uint32_t rom_base,
                        uint32_t *os_table,
                        uint32_t *tb_table);

#ifdef __cplusplus
}
#endif

#endif /* TRAP_UNPACKER_H */
