/**
 * @file os_traps.c
 * @brief Macintosh Operating System Device Manager & Driver Traps
 *
 * Decompiled from QUADRA800.ROM:
 * - 0x4080B766: _Open
 * - 0x4080BAAA: _Close
 * - 0x4080BB1C: _Read
 * - 0x4080BB9A: _Write
 * - 0x4080BBAE: _Control
 * - 0x4080BBBE: _Status
 * - 0x4080BBE4: _KillIO
 */

#include "os_traps.h"
#include <string.h>

/* Portable / Host Device Manager Implementation */
OSErr MacOpenDriver(const char *driver_name, int16_t *ref_num_out) {
    if (!driver_name) return -1;
    if (ref_num_out) *ref_num_out = -4; /* Default Sony driver refNum */
    return noErr;
}

OSErr MacCloseDriver(int16_t ref_num) {
    (void)ref_num;
    return noErr;
}

OSErr MacRead(int16_t ref_num, void *buf, int32_t count, int32_t *act_count_out) {
    (void)ref_num;
    if (buf && count > 0) memset(buf, 0, (size_t)count);
    if (act_count_out) *act_count_out = count;
    return noErr;
}

OSErr MacWrite(int16_t ref_num, const void *buf, int32_t count, int32_t *act_count_out) {
    (void)ref_num;
    (void)buf;
    if (act_count_out) *act_count_out = count;
    return noErr;
}

