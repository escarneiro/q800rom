# Makefile for Macintosh Quadra 800 ROM Decompilation & Reconstructed Sources

HOST_CC ?= gcc
HOST_CFLAGS ?= -Wall -Wextra -O2 -Iinclude -Iboot -Itraps -Itoolbox -Ideclrom -std=c11

SRCS = main.c \
       traps/trap_table.c \
       traps/trap_unpacker.c \
       boot/cpu68040.c \
       boot/hwinit.c \
       boot/lowmem_init.c \
       toolbox/mem_manager.c \
       toolbox/resource_mgr.c \
       toolbox/quickdraw.c \
       toolbox/slot_mgr.c \
       toolbox/os_traps.c \
       declrom/declrom_quadra.c \
       declrom/video_dafb.c

HOST_OBJS = $(SRCS:.c=.o)
TARGET = quadra_rom_harness

# Motorola 68040 Cross-Toolchain
M68K_CC ?= /usr/bin/m68k-suse-linux-gcc
M68K_AS ?= /usr/m68k-suse-linux/bin/as
M68K_LD ?= /usr/m68k-suse-linux/bin/ld
M68K_OBJCOPY ?= /usr/bin/m68k-suse-linux-objcopy

M68K_CFLAGS = -m68040 -nostdlib -ffreestanding -Iinclude -Iboot -Itraps -Itoolbox -Ideclrom -O2
M68K_ASFLAGS = -m68030

BUILD_DIR = ../build
REBUILT_ROM = $(BUILD_DIR)/QUADRA800_REBUILT.ROM
STANDALONE_ROM = $(BUILD_DIR)/QUADRA800_STANDALONE.ROM
ELF_TARGET = $(BUILD_DIR)/q800_rom.elf

M68K_C_SRCS = boot/cpu68040.c \
              boot/hwinit.c \
              boot/lowmem_init.c \
              toolbox/mem_manager.c \
              toolbox/resource_mgr.c \
              toolbox/quickdraw.c \
              toolbox/slot_mgr.c \
              toolbox/os_traps.c \
              declrom/declrom_quadra.c \
              declrom/video_dafb.c \
              traps/trap_unpacker.c \
              traps/trap_table.c

M68K_C_OBJS = $(patsubst %.c,$(BUILD_DIR)/%_m68k.o,$(M68K_C_SRCS))

.PHONY: all clean run m68k rom test-qemu

all: $(TARGET) rom

# Host Verification Harness
$(TARGET): $(HOST_OBJS)
	$(HOST_CC) $(HOST_CFLAGS) -o $@ $(HOST_OBJS)

%.o: %.c
	$(HOST_CC) $(HOST_CFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET) ../QUADRA800.ROM

# Bare-metal M68K compilation
boot/reset.o: boot/reset.s
	$(M68K_AS) $(M68K_ASFLAGS) $< -o $@

traps/trap_dispatcher.o: traps/trap_dispatcher.s
	$(M68K_AS) $(M68K_ASFLAGS) $< -o $@

$(BUILD_DIR)/%_m68k.o: %.c
	@mkdir -p $(dir $@)
	$(M68K_CC) $(M68K_CFLAGS) -c $< -o $@

m68k: boot/reset.o traps/trap_dispatcher.o $(M68K_C_OBJS)
	@echo "All bare-metal 68040 C and assembly objects built successfully."

$(ELF_TARGET): boot/reset.o traps/trap_dispatcher.o $(M68K_C_OBJS) rom.ld
	@mkdir -p $(BUILD_DIR)
	$(M68K_LD) -T rom.ld boot/reset.o traps/trap_dispatcher.o $(M68K_C_OBJS) -o $@

# Build complete 1MB ROM images and compute checksums
rom: $(ELF_TARGET)
	@mkdir -p $(BUILD_DIR)
	python3 tools/build_rom.py standalone $(STANDALONE_ROM) $(ELF_TARGET)
	python3 tools/build_rom.py overlay $(REBUILT_ROM) ../QUADRA800.ROM .
	@python3 tools/rom_checksum.py $(REBUILT_ROM) --verify

# Launch QEMU virtual machine to boot the built ROM
test-qemu: rom
	@echo "Booting $(REBUILT_ROM) in QEMU Macintosh Quadra 800 machine..."
	qemu-system-m68k -M q800 -bios $(REBUILT_ROM) -m 64M

clean:
	rm -f $(HOST_OBJS) $(TARGET) boot/*.o traps/*.o toolbox/*.o declrom/*.o
	rm -rf $(BUILD_DIR)
