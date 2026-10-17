/**
 * @file declrom_quadra.c
 * @brief Macintosh Quadra 800 Onboard NuBus Declaration ROM Definitions
 *
 * Decompiled from QUADRA800.ROM:
 * - Format Block at offset 0x0FFFEC
 * - Motherboard Directory at offset 0x0F2CA4
 * - Video Board sResource at offset 0x099B80 ("Macintosh A External Video")
 * - ViSC / DAFB Functional sResource at offset 0x099DB0 ("Display_Video_Apple_ViSC")
 */

#include "declrom_quadra.h"
#include <stdio.h>

const NuBusFormatBlock g_quadra_motherboard_format_block = {
    .directoryOffset = -54088,             /* 0xFF2CB8 -> Points to 0x0F2CA4 */
    .length          = 0x00000000,
    .crc             = 0x00000000,
    .revisionLevel   = NUBUS_REVISION_LEVEL,
    .format          = NUBUS_FORMAT_VERSION,
    .testPattern     = NUBUS_TEST_PATTERN, /* 0x5A932BC7 */
    .reserved        = 0x00,
    .byteLanes       = NUBUS_BYTELANES_32BIT
};

const sRsrcTypeRecord g_quadra_video_type = {
    .category = CatDisplay,
    .cType    = TypVideo,
    .drSW     = DrSWApple,
    .drHW     = DrHWViSC                  /* 0x0020: DAFB / ViSC controller */
};

const QuadraVideoMode g_quadra_video_modes[5] = {
    { 512, 384,  1,  64, 0xF9000000U },   /* 1-bit B&W 12" RGB */
    { 640, 480,  4, 320, 0xF9000000U },   /* 4-bit 16-color 13"/14" RGB */
    { 640, 480,  8, 640, 0xF9000000U },   /* 8-bit 256-color 13"/14" RGB */
    { 832, 624,  8, 832, 0xF9000000U },   /* 8-bit 256-color 16" RGB */
    { 640, 480, 16, 1280, 0xF9000000U }   /* 16-bit Thousands of Colors (with 1MB VRAM) */
};

void DumpQuadraDeclRomInfo(void) {
    printf("=== Macintosh Quadra 800 Declaration ROM ===\n");
    printf("Test Pattern:    0x%08X (Valid: %s)\n",
           g_quadra_motherboard_format_block.testPattern,
           g_quadra_motherboard_format_block.testPattern == NUBUS_TEST_PATTERN ? "YES" : "NO");
    printf("Directory Offset: %d bytes (points to 0x408F2CA4)\n",
           g_quadra_motherboard_format_block.directoryOffset);
    printf("Motherboard sResource: 'Unknown Macintosh' (ID 1)\n");
    printf("Onboard Video sResource: 'Display_Video_Apple_ViSC' (ID 0x80)\n");
    printf("Hardware ID:     DrHWViSC (0x%04X)\n", g_quadra_video_type.drHW);
    printf("Supported Modes: 1-bit, 4-bit, 8-bit, 16-bit (DAFB Controller)\n");
}
