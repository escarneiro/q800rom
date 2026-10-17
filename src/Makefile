# Makefile for Macintosh Quadra 800 ROM Decompilation & Reconstructed Sources

CC ?= gcc
CFLAGS ?= -Wall -Wextra -O2 -Iinclude -Iboot -Itraps -Itoolbox -Ideclrom -std=c11

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

OBJS = $(SRCS:.c=.o)
TARGET = quadra_rom_harness

.PHONY: all clean run m68k

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET) ../QUADRA800.ROM

# Cross-compilation for m68k if m68k-elf-gcc is installed
M68K_CC = m68k-elf-gcc
M68K_AS = m68k-elf-as
M68K_CFLAGS = -m68040 -m32 -nostdlib -Iinclude -Iboot -Itraps -Itoolbox -Ideclrom -O2

m68k:
	@which $(M68K_CC) >/dev/null 2>&1 || (echo "Note: $(M68K_CC) not found in PATH; skipping bare-metal m68k build." && exit 0)
	$(M68K_AS) -m68040 boot/reset.s -o boot/reset.o
	$(M68K_AS) -m68040 traps/trap_dispatcher.s -o traps/trap_dispatcher.o
	@echo "Bare-metal 68040 assembly objects built successfully."

clean:
	rm -f $(OBJS) $(TARGET) boot/*.o traps/*.o toolbox/*.o declrom/*.o
