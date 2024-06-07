# Makefile for nRF9160 bare metal programming                 PVH, October 2022

# Arm GNU toolchain can be found here (look for gcc-arm-none-eabi)
# https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain
# nrfx is available at https://github.com/NordicSemiconductor/nrfx
# CMSIS can be found at https://github.com/ARM-software/CMSIS_5

# Path to Toolchain
TOOLCHAINPATH = /usr

# Path to mergehex command
MERGEHEX = /usr/bin/mergehex

# Paths to 3rd party dependencies
NRFXPATH = ${PWD}/3rd_party/nrfx
CMSISPATH = ${PWD}/3rd_party/CMSIS_5/CMSIS

# Specify project name, object files, headers (DEPS) and linker script
PROJECT = secure_blinky
S_LDSCRIPT = secure/secure.ld
NS_LDSCRIPT = non-secure/non-secure.ld
BUILDDIR = ./build
NSC_LIB = ${BUILDDIR}/nsc_lib.o
NS_INCLUDES = -Inon-secure

# Startup and system code
S_SOURCES = \
	${NRFXPATH}/mdk/gcc_startup_nrf9160.S \
	${NRFXPATH}/mdk/system_nrf9160.c \
	secure/main_s.c \
	secure/non_secure_entry.c \

NS_SOURCES = \
	${NRFXPATH}/mdk/gcc_startup_nrf9160.S \
	${NRFXPATH}/mdk/system_nrf9160.c \
	non-secure/main_ns.c \

# Common flags for CC, AS and LD
FLAGS = -mcpu=cortex-m33 -mthumb -mfloat-abi=hard -mabi=aapcs
FLAGS += -mfpu=fpv5-sp-d16 -DNRF9160_XXAA
FLAGS += -DCONFIG_GPIO_AS_PINRESET -DFLOAT_ABI_HARD

# Shortcuts for various tools
CC = ${TOOLCHAINPATH}/bin/arm-none-eabi-gcc
AS = ${TOOLCHAINPATH}/bin/arm-none-eabi-gcc
LD = ${TOOLCHAINPATH}/bin/arm-none-eabi-gcc
OBJCOPY = ${TOOLCHAINPATH}/bin/arm-none-eabi-objcopy
SIZETOOL = ${TOOLCHAINPATH}/bin/arm-none-eabi-size

# Compiler flags
CFLAGS = ${FLAGS} -std=c99 -Wall -Werror
CFLAGS += -I${CMSISPATH}/Core/Include
CFLAGS += -I${NRFXPATH}
CFLAGS += -I${NRFXPATH}/templates
CFLAGS += -I${NRFXPATH}/mdk
CFLAGS += -I${NRFXPATH}/hal
CFLAGS += -I${NRFXPATH}/drivers/include

# Common flags for secure code
SFLAGS = -mcmse

# Common flags for non-secure code
NSFLAGS = -DNRF_TRUSTZONE_NONSECURE

# Assembler flags
AFLAGS = ${FLAGS} -x assembler-with-cpp

# Linker flags
S_LDFLAGS = ${FLAGS} -T "$(S_LDSCRIPT)" -Xlinker
S_LDFLAGS += --cmse-implib -Xlinker --out-implib=$(NSC_LIB) -Xlinker
S_LDFLAGS += --gc-sections -Xlinker -Map="$(BUILDDIR)/$(PROJECT).map"
S_LDFLAGS += --specs=nano.specs
S_LDFLAGS += -L"${NRFXPATH}/mdk/"

# Linker flags
NS_LDFLAGS = ${FLAGS} -T "$(NS_LDSCRIPT)" -Xlinker
NS_LDFLAGS += --gc-sections -Xlinker -Map="$(BUILDDIR)/$(PROJECT).map"
NS_LDFLAGS += --specs=nano.specs
NS_LDFLAGS += -L"${NRFXPATH}/mdk/"

LIBS = -Wl,--start-group -lgcc -lc -lnosys -Wl,--end-group

# Check whether to optimize or build for debugging
DEBUG ?= 0
ifeq ($(DEBUG), 1)
	CFLAGS += -O0 -g3 -gdwarf-2
	AFLAGS += -g3 -gdwarf-2
	LDFLAGS += -g3
else
	CFLAGS += -O3
endif

# Substitute the correct path for the object filenames
# _OBJ = $(patsubst %,$(BUILDDIR)/%,$(OBJ))
NS_OBJECTS := $(addsuffix .o,$(NS_SOURCES))

# Replace NRFX paths since objects here are going to be build in the build dir.
NS_OBJECTS := $(subst $(NRFXPATH),non-secure/nrfx,$(NS_OBJECTS))

# Finally, add build directory prefix
NS_OBJECTS := $(addprefix $(BUILDDIR)/,$(NS_OBJECTS))

# And we to the same to the secure image
S_OBJECTS := $(addsuffix .o,$(S_SOURCES))
S_OBJECTS := $(subst $(NRFXPATH),secure/nrfx,$(S_OBJECTS))
S_OBJECTS := $(addprefix $(BUILDDIR)/,$(S_OBJECTS))

# Build the project
all: $(BUILDDIR)/$(PROJECT).hex

$(BUILDDIR)/$(PROJECT).hex: $(BUILDDIR)/$(PROJECT)_s.axf $(BUILDDIR)/$(PROJECT)_ns.axf
	@echo "[MERGEHEX] $^ -> $@"
	@$(MERGEHEX) -m $^ -o $@
	@echo "[OBJCOPY] $@ -> $(BUILDDIR)/$(PROJECT).bin"
	@objcopy -I ihex -O binary $@ $(BUILDDIR)/$(PROJECT).bin

$(BUILDDIR)/$(PROJECT)_s.axf: $(S_OBJECTS)
	@echo "[LD] Linking boot image $@"
	@$(LD) $(S_LDFLAGS) -o $@ $(S_OBJECTS) $(LIBS)
	@echo "[OBJCOPY] $@ -> $(BUILDDIR)/$(PROJECT)_s.hex"
	@objcopy -O ihex $@ $(BUILDDIR)/$(PROJECT)_s.hex
	@echo "[OBJCOPY] $@ -> $(BUILDDIR)/$(PROJECT)_s.bin"
	@objcopy -I ihex -O binary $(BUILDDIR)/$(PROJECT)_s.hex $(BUILDDIR)/$(PROJECT)_s.bin
	@$(SIZETOOL) $@

$(BUILDDIR)/$(PROJECT)_ns.axf: $(NS_OBJECTS)
	@echo "[LD] Linking app image $@"
	@$(LD) $(NS_LDFLAGS) -DNRF_TRUSTZONE_NONSECURE -o $@ $(NS_OBJECTS) $(NSC_LIB) $(LIBS)
	@echo "[OBJCOPY] $@ -> $(BUILDDIR)/$(PROJECT)_ns.hex"
	@objcopy -O ihex $@ $(BUILDDIR)/$(PROJECT)_ns.hex
	@echo "[OBJCOPY] $@ -> $(BUILDDIR)/$(PROJECT)_ns.bin"
	@objcopy -I ihex -O binary $(BUILDDIR)/$(PROJECT)_ns.hex $(BUILDDIR)/$(PROJECT)_ns.bin
	@$(SIZETOOL) $@

# Recipe for building C objects in the secure imaga
$(BUILDDIR)/secure/%.c.o: secure/%.c
	@echo "[CC] $< -> $@"
	@mkdir -p $(@D)
	$(CC) $(SFLAGS) $(CFLAGS) -c $< -o $@

# Recipe for assembling C objects in the secure imaga
$(BUILDDIR)/secure/%.S.o: /secure/%.S
	@echo "[AS] $< -> $@"
	@mkdir -p $(@D)
	@$(AS) $(SFLAGS) $(S_INCLUDES) $(AFLAGS) -c $< -o $@

# Recipe for building C objects in $(NRFXPATH) for the secure image
$(BUILDDIR)/secure/nrfx/%.c.o: $(NRFXPATH)/%.c
	@echo "[CC] $< -> $@"
	@mkdir -p $(@D)
	@$(CC) $(SFLAGS) $(CFLAGS) -c $< -o $@

# Recipe for assembling objects in $(NRFXPATH) for the secure image
$(BUILDDIR)/secure/nrfx/%.S.o: $(NRFXPATH)/%.S
	@echo "[AS] $< -> $@"
	@mkdir -p $(@D)
	@$(AS) $(SFLAGS) $(AFLAGS) -c $< -o $@

# Recipe for building C objects in the non-secure application
$(BUILDDIR)/non-secure/%.c.o: non-secure/%.c
	@echo "[CC] $< -> $@"
	@mkdir -p $(@D)
	@$(CC) $(NSFLAGS) $(NS_INCLUDES) $(CFLAGS) -c $< -o $@

# Recipe for assembling objects in the non-secure application
$(BUILDDIR)/non-secure/%.S.o: non-secure/%.S
	@echo "[AS] $< -> $@"
	@mkdir -p $(@D)
	@$(AS) $(NSFLAGS) $(AFLAGS) -c $< -o $@

# Recipe for building C objects in $(NRFXPATH) in the non-secure application
$(BUILDDIR)/non-secure/nrfx/%.c.o: $(NRFXPATH)/%.c
	@echo "[CC] $< -> $@"
	@mkdir -p $(@D)
	@$(CC) $(NSFLAGS) $(CFLAGS) -c $< -o $@

# Recipe for assembling objects in $(NRFXPATH) in the non-secure application
$(BUILDDIR)/non-secure/nrfx/%.S.o: $(NRFXPATH)/%.S
	@echo "[AS] $< -> $@"
	@mkdir -p $(@D)
	@$(AS) $(NSFLAGS) $(AFLAGS) -c $< -o $@

# Remove build folder
clean:
	rm -dfr $(BUILDDIR)

# Flash the program
flash: $(BUILDDIR)/$(PROJECT).hex
	@echo Flashing $(BUILDDIR)/$(PROJECT).hex
	@nrfjprog -f nrf91 --program $(BUILDDIR)/$(PROJECT).hex --sectorerase \
	--verify --reset

erase:
	@echo Erasing all flash
	@nrfjprog -f nrf91 --eraseall
