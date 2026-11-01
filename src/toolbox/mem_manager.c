/**
 * @file mem_manager.c
 * @brief Macintosh Classic Memory Manager Implementation
 *
 * Decompiled from QUADRA800.ROM:
 * - 0x4080D360: _NewPtr
 * - 0x4080D3A0: _DisposPtr
 * - 0x4080D448: _NewHandle
 * - 0x4080D484: _DisposHandle
 * - 0x4080D628: _HLock
 * - 0x4080D64E: _HUnlock
 */

#include "mem_manager.h"
#include "lowmem.h"
#include <string.h>

#include <stdlib.h>

/* Portable / Host Reconstructed Memory Manager Implementation */

Ptr MacNewPtr(int32_t logical_size) {
    if (logical_size <= 0) return NULL;
    /* Physical size = logical size + 8 byte block header */
    uint8_t *raw = (uint8_t *)malloc((size_t)logical_size + 8);
    if (!raw) return NULL;
    BlockHeader *hdr = (BlockHeader *)raw;
    hdr->tag = BLOCK_TAG_NONRELOCATABLE;
    hdr->size_h = (uint8_t)((logical_size + 8) >> 16);
    hdr->size_l = (uint16_t)((logical_size + 8) & 0xFFFF);
    hdr->u.zone_ptr = NULL;
    return (Ptr)(raw + 8);
}

OSErr MacDisposPtr(Ptr p) {
    if (!p) return nilHandleErr;
    uint8_t *raw = (uint8_t *)p - 8;
    free(raw);
    return noErr;
}

Handle MacNewHandle(int32_t logical_size) {
    Ptr p = MacNewPtr(logical_size);
    if (!p) return NULL;
    Handle h = (Handle)malloc(sizeof(Ptr));
    if (!h) {
        MacDisposPtr(p);
        return NULL;
    }
    *h = p;
    BlockHeader *hdr = (BlockHeader *)((uint8_t *)p - 8);
    hdr->tag = BLOCK_TAG_RELOCATABLE;
    hdr->u.master_ptr = h;
    return h;
}

OSErr MacDisposHandle(Handle h) {
    if (!h) return nilHandleErr;
    if (*h) {
        MacDisposPtr(*h);
        *h = NULL;
    }
    free(h);
    return noErr;
}

void MacHLock(Handle h) {
    if (!h || !*h) return;
    BlockHeader *hdr = (BlockHeader *)((uint8_t *)*h - 8);
    hdr->tag |= MP_FLAG_LOCKED;
}

void MacHUnlock(Handle h) {
    if (!h || !*h) return;
    BlockHeader *hdr = (BlockHeader *)((uint8_t *)*h - 8);
    hdr->tag &= ~MP_FLAG_LOCKED;
}

void MacInitZone(THz zone, Ptr limit_ptr, int16_t master_count) {
    if (!zone || !limit_ptr) return;
    memset(zone, 0, sizeof(Zone));
    zone->bkLim = limit_ptr;
    zone->moreMast = master_count;
}

