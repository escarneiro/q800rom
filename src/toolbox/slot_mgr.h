/**
 * @file slot_mgr.h
 * @brief Macintosh NuBus Slot Manager
 */

#ifndef SLOT_MGR_H
#define SLOT_MGR_H

#include "declrom.h"
#include "mac_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Slot Manager Parameter Block */
typedef struct {
    int32_t     spsPointer;
    int32_t     spsCalType;
    int32_t     spsBlock;
    int32_t     spsOffset;
    int32_t     spsCurOffset;
    int16_t     spsCount;
    int8_t      spsSlot;
    int8_t      spsId;
    int16_t     spsStatus;
    uint32_t    spsFlags;
} SpBlock;

/**
 * @brief Reads and validates the NuBus Format Block from slot space.
 * Decompiled from QUADRA800.ROM at 0x40808C252.
 */
OSErr MacSGetFormatBlock(uint8_t slot, NuBusFormatBlock *fb_out);

/**
 * @brief Searches a slot declaration ROM for an sResource with matching type.
 */
OSErr MacSGetTypeSRsrc(uint8_t slot, const sRsrcTypeRecord *type_rec, SpBlock *sp_out);

/**
 * @brief Finds an sResource entry by ID within an sResource directory.
 */
OSErr MacSFindStruct(const uint8_t *rom_base, uint32_t sres_offset, uint8_t entry_id, uint32_t *target_offset_out);

#ifdef __cplusplus
}
#endif

#endif /* SLOT_MGR_H */
