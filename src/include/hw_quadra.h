/**
 * @file hw_quadra.h
 * @brief Macintosh Quadra 800 Hardware Memory Map and Register Definitions
 *
 * Details the Motorola 68040 processor registers and motherboard controllers
 * for the Apple Macintosh Quadra 800 (and Centris 650/Quadra 700/950 family).
 */

#ifndef HW_QUADRA_H
#define HW_QUADRA_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Memory Map Base Addresses */
#define QUADRA_ROM_BASE             0x40800000U
#define QUADRA_ROM_SIZE             0x00100000U /* 1 Megabyte */
#define QUADRA_RAM_BASE             0x00000000U

/* Memory-Mapped I/O Base Addresses */
#define QUADRA_IO_BASE              0x50F00000U
#define QUADRA_VIA1_BASE            0x50F00000U
#define QUADRA_VIA2_BASE            0x50F02000U
#define QUADRA_SCC_READ_BASE        0x50F04000U
#define QUADRA_SCC_WRITE_BASE       0x50F06000U
#define QUADRA_SONIC_ETHERNET_BASE  0x50F0A000U
#define QUADRA_SCSI_53C96_BASE      0x50F10000U
#define QUADRA_SCSI_HANDSHAKE_BASE  0x50F12000U
#define QUADRA_SCSI_DMA_BASE        0x50F14000U
#define QUADRA_DAFB_VIDEO_BASE      0x50F16000U

/* NuBus Standard Slot Space ($Fs000000 - $FsFFFFFF) */
#define QUADRA_NUBUS_SLOT_BASE(s)   (0xF0000000U | ((uint32_t)(s) << 24))

/* Motorola 68040 CACR Bits */
#define M68040_CACR_DEC             0x80000000U /* Data Cache Enable */
#define M68040_CACR_FD              0x40000000U /* Freeze Data Cache */
#define M68040_CACR_CED             0x20000000U /* Clear Entry in Data Cache */
#define M68040_CACR_CD              0x10000000U /* Clear Data Cache */
#define M68040_CACR_DPI             0x08000000U /* Disable CPUSH Invalidation */
#define M68040_CACR_IEC             0x00008000U /* Instruction Cache Enable */
#define M68040_CACR_FI              0x00004000U /* Freeze Instruction Cache */
#define M68040_CACR_CEI             0x00002000U /* Clear Entry in Inst Cache */
#define M68040_CACR_CI              0x00001000U /* Clear Instruction Cache */

/* Motorola 68040 MMU Translation Control (TC) Register */
#define M68040_TC_ENABLE            0x00008000U /* Bit 15: Enable MMU */
#define M68040_TC_PAGE_8K           0x00004000U /* Bit 14: 8KB Page Size (0=4KB) */

/* 68040 Transparent Translation (DTT0/1, ITT0/1) Bitfields */
/* Fields: Base Address [31:24], Address Mask [23:16], Enable [15], Super [14:13], Caching [6:5] */
#define M68040_TT_ENABLE            0x00008000U
#define M68040_TT_SUPER_USER        0x00000000U
#define M68040_TT_CACHE_INHIBIT     0x00000040U
#define M68040_TT_CACHE_NONSER      0x00000020U

/* Standard Early ROM DTT Configurations */
#define QUADRA_ROM_DTT0_INIT        0x807FC040U /* $80000000-$FFFFFFFF Serialized Cache-Inhibited */
#define QUADRA_ROM_DTT1_INIT        0x500FC040U /* $50000000-$50FFFFFF I/O Space Cache-Inhibited */

/* VIA 6522 Register Offsets (stride 0x200 or 0x400 on Mac II/Quadra) */
typedef struct {
    volatile uint8_t orb;       /* 0x00: Output/Input Register B */
    uint8_t _pad0[0x1FF];
    volatile uint8_t ora;       /* 0x200: Output/Input Register A (with handshake) */
    uint8_t _pad1[0x1FF];
    volatile uint8_t ddrb;      /* 0x400: Data Direction Register B */
    uint8_t _pad2[0x1FF];
    volatile uint8_t ddra;      /* 0x600: Data Direction Register A */
    uint8_t _pad3[0x1FF];
    volatile uint8_t t1c_l;     /* 0x800: Timer 1 Counter Low */
    uint8_t _pad4[0x1FF];
    volatile uint8_t t1c_h;     /* 0xA00: Timer 1 Counter High */
    uint8_t _pad5[0x1FF];
    volatile uint8_t t1l_l;     /* 0xC00: Timer 1 Latch Low */
    uint8_t _pad6[0x1FF];
    volatile uint8_t t1l_h;     /* 0xE00: Timer 1 Latch High */
    uint8_t _pad7[0x1FF];
    volatile uint8_t t2c_l;     /* 0x1000: Timer 2 Counter Low */
    uint8_t _pad8[0x1FF];
    volatile uint8_t t2c_h;     /* 0x1200: Timer 2 Counter High */
    uint8_t _pad9[0x1FF];
    volatile uint8_t sr;        /* 0x1400: Shift Register (ADB) */
    uint8_t _pad10[0x1FF];
    volatile uint8_t acr;       /* 0x1600: Auxiliary Control Register */
    uint8_t _pad11[0x1FF];
    volatile uint8_t pcr;       /* 0x1800: Peripheral Control Register */
    uint8_t _pad12[0x1FF];
    volatile uint8_t ifr;       /* 0x1A00: Interrupt Flag Register */
    uint8_t _pad13[0x1FF];
    volatile uint8_t ier;       /* 0x1C00: Interrupt Enable Register */
    uint8_t _pad14[0x1FF];
    volatile uint8_t ora_nh;    /* 0x1E00: Output/Input Register A (no handshake) */
} QuadraVIA;

#ifdef __cplusplus
}
#endif

#endif /* HW_QUADRA_H */
