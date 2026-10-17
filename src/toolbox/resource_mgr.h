/**
 * @file resource_mgr.h
 * @brief Macintosh Classic Resource Manager
 */

#ifndef RESOURCE_MGR_H
#define RESOURCE_MGR_H

#include "mac_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Resource Map Header */
typedef struct __attribute__((packed)) {
    uint32_t data_offset;
    uint32_t map_offset;
    uint32_t data_length;
    uint32_t map_length;
} ResourceForkHeader;

/* Resource Reference in Map */
typedef struct __attribute__((packed)) {
    int16_t  res_id;
    int16_t  name_offset;
    uint8_t  attributes;
    uint8_t  data_offset_h;
    uint16_t data_offset_l;
    uint32_t reserved;
} ResourceRefEntry;

/**
 * @brief Initializes the Resource Manager and sets up the ROM Resource Map.
 */
void MacInitResources(void);

/**
 * @brief Finds and loads a resource by 4-character type and ID.
 * Decompiled from QUADRA800.ROM at 0x408DB5A0 (_GetResource / $A9A0).
 */
Handle MacGetResource(ResType the_type, int16_t the_id);

/**
 * @brief Releases a loaded resource handle.
 * Decompiled from QUADRA800.ROM at 0x408DBBDC (_ReleaseResource / $A9A3).
 */
void MacReleaseResource(Handle the_resource);

/**
 * @brief Returns the reference number of the current resource file.
 * Decompiled from QUADRA800.ROM at 0x408BBCE8 (_CurResFile / $A994).
 */
int16_t MacCurResFile(void);

#ifdef __cplusplus
}
#endif

#endif /* RESOURCE_MGR_H */
