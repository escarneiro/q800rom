/**
 * @file os_traps.h
 * @brief Macintosh Operating System Device Manager & File System Traps
 */

#ifndef OS_TRAPS_H
#define OS_TRAPS_H

#include "mac_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* IO Parameter Block */
typedef struct {
    Ptr         qLink;
    int16_t     qType;
    int16_t     ioTrap;
    Ptr         ioCmdAddr;
    Ptr         ioCompletion;
    int16_t     ioResult;
    Ptr         ioNamePtr;
    int16_t     ioVRefNum;
    int16_t     ioRefNum;
    int8_t      ioPermssn;
    int8_t      ioMisc;
    Ptr         ioBuffer;
    int32_t     ioReqCount;
    int32_t     ioActCount;
    int16_t     ioPosMode;
    int32_t     ioPosOffset;
} ParamBlockRec, *ParmBlkPtr;

/**
 * @brief Opens an I/O driver by name (e.g. ".Sony", ".Print", ".AIn", ".AOut").
 * Decompiled from QUADRA800.ROM at 0x4080B766 (_Open / $A000).
 */
OSErr MacOpenDriver(const char *driver_name, int16_t *ref_num_out);

/**
 * @brief Closes an open I/O driver.
 * Decompiled from QUADRA800.ROM at 0x4080BAAA (_Close / $A001).
 */
OSErr MacCloseDriver(int16_t ref_num);

/**
 * @brief Reads data from an open driver or file.
 * Decompiled from QUADRA800.ROM at 0x4080BB1C (_Read / $A002).
 */
OSErr MacRead(int16_t ref_num, void *buf, int32_t count, int32_t *act_count_out);

/**
 * @brief Writes data to an open driver or file.
 * Decompiled from QUADRA800.ROM at 0x4080BB9A (_Write / $A003).
 */
OSErr MacWrite(int16_t ref_num, const void *buf, int32_t count, int32_t *act_count_out);

#ifdef __cplusplus
}
#endif

#endif /* OS_TRAPS_H */
