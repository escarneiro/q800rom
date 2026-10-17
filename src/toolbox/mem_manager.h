/**
 * @file mem_manager.h
 * @brief Macintosh Classic Memory Manager (Heap Zones, Pointers, and Handles)
 */

#ifndef MEM_MANAGER_H
#define MEM_MANAGER_H

#include "mac_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Heap Block Flags & Tags */
#define BLOCK_TAG_FREE          0x00U
#define BLOCK_TAG_NONRELOCATABLE 0x40U
#define BLOCK_TAG_RELOCATABLE   0x80U

/* Master Pointer Flags */
#define MP_FLAG_LOCKED          0x80U
#define MP_FLAG_PURGEABLE       0x40U
#define MP_FLAG_RESOURCE        0x20U

/* Block Header */
typedef struct __attribute__((packed)) {
    uint8_t  tag;               /* Tag byte (flags, lock, purge) */
    uint8_t  size_h;            /* 24-bit physical size */
    uint16_t size_l;
    union {
        Handle master_ptr;      /* For relocatable blocks: pointer to master pointer */
        THz    zone_ptr;        /* For free/non-relocatable blocks */
    } u;
} BlockHeader;

/**
 * @brief Allocates a non-relocatable block of memory in the current heap zone.
 * Decompiled from QUADRA800.ROM at 0x4088D360 (_NewPtr / $A01E).
 */
Ptr MacNewPtr(int32_t logical_size);

/**
 * @brief Releases a non-relocatable block.
 * Decompiled from QUADRA800.ROM at 0x4088D3A0 (_DisposPtr / $A01F).
 */
OSErr MacDisposPtr(Ptr p);

/**
 * @brief Allocates a relocatable block and creates a master pointer handle.
 * Decompiled from QUADRA800.ROM at 0x4089D448 (_NewHandle / $A022).
 */
Handle MacNewHandle(int32_t logical_size);

/**
 * @brief Releases a relocatable block and frees its master pointer.
 * Decompiled from QUADRA800.ROM at 0x4089D484 (_DisposHandle / $A023).
 */
OSErr MacDisposHandle(Handle h);

/**
 * @brief Locks a relocatable block so the heap compactor will not move it.
 * Decompiled from QUADRA800.ROM at 0x408BD628 (_HLock / $A029).
 */
void MacHLock(Handle h);

/**
 * @brief Unlocks a relocatable block, permitting compaction.
 * Decompiled from QUADRA800.ROM at 0x408BD64E (_HUnlock / $A02A).
 */
void MacHUnlock(Handle h);

/**
 * @brief Initializes a heap zone header.
 */
void MacInitZone(THz zone, Ptr limit_ptr, int16_t master_count);

#ifdef __cplusplus
}
#endif

#endif /* MEM_MANAGER_H */
