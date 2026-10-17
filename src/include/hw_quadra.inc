; Macintosh Quadra 800 Hardware Equates for M68K Assembler

QUADRA_ROM_BASE             EQU $40800000
QUADRA_ROM_SIZE             EQU $00100000
QUADRA_RAM_BASE             EQU $00000000

QUADRA_IO_BASE              EQU $50F00000
QUADRA_VIA1_BASE            EQU $50F00000
QUADRA_VIA2_BASE            EQU $50F02000
QUADRA_SCC_READ_BASE        EQU $50F04000
QUADRA_SCC_WRITE_BASE       EQU $50F06000
QUADRA_SONIC_BASE           EQU $50F0A000
QUADRA_SCSI_53C96_BASE      EQU $50F10000
QUADRA_SCSI_HANDSHAKE_BASE  EQU $50F12000
QUADRA_SCSI_DMA_BASE        EQU $50F14000
QUADRA_DAFB_VIDEO_BASE      EQU $50F16000

; Motorola 68040 Control Register Equates
M68040_CACR_DEC             EQU $80000000  ; Data Cache Enable
M68040_CACR_IEC             EQU $00008000  ; Instruction Cache Enable
M68040_TC_ENABLE            EQU $00008000  ; MMU Enable
M68040_ROM_DTT0_INIT        EQU $807FC040
M68040_ROM_DTT1_INIT        EQU $500FC040

; VIA Register Offsets
VIA_ORB                     EQU $0000
VIA_ORA                     EQU $0200
VIA_DDRB                    EQU $0400
VIA_DDRA                    EQU $0600
VIA_T1C_L                   EQU $0800
VIA_T1C_H                   EQU $0A00
VIA_T1L_L                   EQU $0C00
VIA_T1L_H                   EQU $0E00
VIA_T2C_L                   EQU $1000
VIA_T2C_H                   EQU $1200
VIA_SR                      EQU $1400
VIA_ACR                     EQU $1600
VIA_PCR                     EQU $1800
VIA_IFR                     EQU $1A00
VIA_IER                     EQU $1C00
VIA_ORA_NH                  EQU $1E00
