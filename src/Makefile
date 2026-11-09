# Makefile for the Macintosh Quadra 800 ROM, built from the assembly source in romsrc/

# Motorola 68040 Cross-Toolchain (GNU binutils). Override on the command line for another
# toolchain, e.g. make M68K_AS=m68k-linux-gnu-as ...; the values are exported to the tools.
M68K_AS ?= /usr/m68k-suse-linux/bin/as
M68K_LD ?= /usr/m68k-suse-linux/bin/ld
M68K_NM ?= /usr/m68k-suse-linux/bin/nm
M68K_OBJCOPY ?= /usr/bin/m68k-suse-linux-objcopy
M68K_OBJDUMP ?= /usr/bin/m68k-suse-linux-objdump
export M68K_AS M68K_LD M68K_NM M68K_OBJCOPY M68K_OBJDUMP

BUILD_DIR = ../build

REBUILT_ROM = $(BUILD_DIR)/QUADRA800_REBUILT.ROM
ROMSRC_SRCS = $(shell find romsrc -name '*.s' -o -name '*.inc' -o -name '*.bin' 2>/dev/null)
ROMSRC_OBJ = $(BUILD_DIR)/q800rom.o
ROMSRC_ELF = $(BUILD_DIR)/q800rom.elf

# Media: the ROM's sounds, images and fonts are built from the files in MEDIA.
#   make MEDIA=dir      take all the media from another directory (absolute, or relative
#                       to src/), laid out like ../media; a missing file or directory
#                       leaves that item as it is in romsrc/
# One item can also be given by itself:
#   make CHIME=my.wav   boot chime from a WAV file (tools/wav2snd.py), padded to CHIME_AREA
#                       bytes; a longer sound is cut (about 3.1 s fit)
#   make ALERT=my.wav   alert sound ('snd ' 1) from a WAV file; ALERT_AREA bytes (0.12 s),
#                       cut if longer
#   make BEEPS=file     boot beep and error beeps from a text file (tools/beeps2s.py)
#   make ICONS=dir      icons and cursors from PNGs in dir/boot, sony, edisk, atboot and
#                       cursors (tools/icons2s.py lists the names)
#   make FONTS=dir      bitmap fonts from dir/chicago12.bdf, geneva9.bdf, geneva12.bdf,
#                       monaco9.bdf (tools/fonts2s.py)
#   make PICTURE=f.png  the hidden start-up picture from a PNG (tools/pict2s.py); it must
#                       compress to 5542 bytes or less
#   make PICTS=dir      the 'PICT' resources from dir/<id>.png (tools/picts2s.py)
# All of them keep their size, so nothing else in the ROM moves.
MEDIA ?= ../media
CHIME ?= $(wildcard $(MEDIA)/chime.wav)
ALERT ?= $(wildcard $(MEDIA)/alert.wav)
BEEPS ?= $(wildcard $(MEDIA)/beeps.txt)
ICONS ?= $(wildcard $(MEDIA)/icons)
FONTS ?= $(wildcard $(MEDIA)/fonts)
PICTURE ?= $(wildcard $(MEDIA)/picture.png)
PICTS ?= $(wildcard $(MEDIA)/picts)

MEDIA_DIR = $(BUILD_DIR)/media
MEDIA_CFG = $(BUILD_DIR)/media.cfg
MEDIA_FILES =
MEDIA_INC =
CHIME_AREA ?= 0x10D8C
ifneq ($(CHIME),)
MEDIA_FILES += $(MEDIA_DIR)/chime/sound/bootchime.s
MEDIA_INC += -I $(MEDIA_DIR)/chime
endif
ALERT_AREA ?= 2762
ifneq ($(ALERT),)
MEDIA_FILES += $(MEDIA_DIR)/alert/sound/alertsound.s
MEDIA_INC += -I $(MEDIA_DIR)/alert
endif
ifneq ($(BEEPS),)
MEDIA_FILES += $(MEDIA_DIR)/beeps/sound/beeptable.s
MEDIA_INC += -I $(MEDIA_DIR)/beeps
endif
ifneq ($(ICONS),)
MEDIA_FILES += $(MEDIA_DIR)/icons.stamp
MEDIA_INC += -I $(MEDIA_DIR)/icons
endif
ifneq ($(FONTS),)
MEDIA_FILES += $(MEDIA_DIR)/fonts.stamp
MEDIA_INC += -I $(MEDIA_DIR)/fonts
endif
ifneq ($(PICTURE),)
MEDIA_FILES += $(MEDIA_DIR)/picture/misc/picturedata.s
MEDIA_INC += -I $(MEDIA_DIR)/picture
endif
ifneq ($(PICTS),)
MEDIA_FILES += $(MEDIA_DIR)/picts.stamp
MEDIA_INC += -I $(MEDIA_DIR)/picts
endif
MEDIA_SETTINGS = CHIME=$(CHIME) CHIME_AREA=$(CHIME_AREA) ALERT=$(ALERT) ALERT_AREA=$(ALERT_AREA) \
	BEEPS=$(BEEPS) ICONS=$(ICONS) FONTS=$(FONTS) PICTURE=$(PICTURE) PICTS=$(PICTS)

.PHONY: all clean rom FORCE test-qemu

all: rom

# Records the media options, so that changing them rebuilds the ROM
$(MEDIA_CFG): FORCE
	@mkdir -p $(BUILD_DIR)
	@echo '$(MEDIA_SETTINGS)' | cmp -s - $@ || echo '$(MEDIA_SETTINGS)' > $@
FORCE:

$(MEDIA_DIR)/chime/sound/bootchime.s: $(CHIME) tools/wav2snd.py $(MEDIA_CFG)
	@mkdir -p $(dir $@)
	python3 tools/wav2snd.py $(CHIME) $@ --asm $(CHIME_AREA)

$(MEDIA_DIR)/alert/sound/alertsound.s: $(ALERT) tools/wav2snd.py $(MEDIA_CFG)
	@mkdir -p $(dir $@)
	python3 tools/wav2snd.py $(ALERT) $@ --asm $(ALERT_AREA) --label ALERTSOUND

$(MEDIA_DIR)/beeps/sound/beeptable.s: $(BEEPS) tools/beeps2s.py $(MEDIA_CFG)
	@mkdir -p $(dir $@)
	python3 tools/beeps2s.py $(BEEPS) -o $@

$(MEDIA_DIR)/icons.stamp: $(shell find $(ICONS) -name '*.png' 2>/dev/null) tools/icons2s.py $(MEDIA_CFG)
	rm -rf $(MEDIA_DIR)/icons
	python3 tools/icons2s.py $(ICONS) --romsrc romsrc -o $(MEDIA_DIR)/icons
	@touch $@

$(MEDIA_DIR)/fonts.stamp: $(wildcard $(FONTS)/*.bdf) tools/fonts2s.py $(MEDIA_CFG)
	rm -rf $(MEDIA_DIR)/fonts
	python3 tools/fonts2s.py $(FONTS) -o $(MEDIA_DIR)/fonts
	@touch $@

$(MEDIA_DIR)/picture/misc/picturedata.s: $(PICTURE) romsrc/misc/picturedata.s tools/pict2s.py $(MEDIA_CFG)
	python3 tools/pict2s.py $(PICTURE) --romsrc romsrc -o $(MEDIA_DIR)/picture

$(MEDIA_DIR)/picts.stamp: $(wildcard $(PICTS)/*.png) tools/picts2s.py tools/pict2s.py $(MEDIA_CFG)
	rm -rf $(MEDIA_DIR)/picts
	python3 tools/picts2s.py $(PICTS) --romsrc romsrc -o $(MEDIA_DIR)/picts
	@touch $@

# Assemble the ROM source
$(ROMSRC_OBJ): romsrc/q800rom.s $(ROMSRC_SRCS) $(MEDIA_CFG) $(MEDIA_FILES)
	@mkdir -p $(BUILD_DIR)
	$(M68K_AS) -m68040 $(MEDIA_INC) -I romsrc -I romsrc/include romsrc/q800rom.s -o $@
	@if [ -n "$$($(M68K_NM) -u $@)" ]; then echo "undefined symbols:" >&2; \
		$(M68K_NM) -u $@ >&2; rm -f $@; exit 1; fi

# Linked at ROMBase so that label references resolve to ROM addresses
$(ROMSRC_ELF): $(ROMSRC_OBJ)
	$(M68K_LD) -Ttext=0x40800000 -e 0x40800000 --no-warn-rwx-segments -o $@ $<

# Post-link: the packed trap table is re-encoded from the linked label addresses and the
# checksums are recomputed (both needed once code moves). If a trap table entry has to grow
# (its routine moved too far for its encoding), rom_postlink.py rewrites the entry in the
# source and exits with 3: the ROM is then assembled and linked again.
$(REBUILT_ROM): $(ROMSRC_ELF) romsrc/traptable.lst romsrc/relocs.lst
	$(M68K_OBJCOPY) -O binary --only-section=.text $< $@
	@python3 tools/rom_postlink.py $< $@ romsrc > $(BUILD_DIR)/postlink.log; rc=$$?; \
	if [ $$rc = 3 ]; then rm -f $@; cat $(BUILD_DIR)/postlink.log; exec $(MAKE) --no-print-directory rom; fi; \
	if [ $$rc != 0 ]; then cat $(BUILD_DIR)/postlink.log >&2; rm -f $@; exit $$rc; fi

# Build the 1MB ROM image and check its checksum
rom: $(REBUILT_ROM)
	@python3 tools/rom_checksum.py $(REBUILT_ROM) --verify

# Launch QEMU virtual machine to boot the built ROM
test-qemu: rom
	@echo "Booting $(REBUILT_ROM) in QEMU Macintosh Quadra 800 machine..."
	qemu-system-m68k -M q800 -bios $(REBUILT_ROM) -m 64M

clean:
	rm -rf $(BUILD_DIR)

-include local.mk
