GIT_VERSION := $(shell git describe --abbrev=8 --dirty --always --tags)

build_type ?= runtime
model ?= unknown

ifeq ($(build_type), runtime)
	ifeq ($(model), S60P)
		VECTOR_TABLE_OFFSET := 0x5000
		SRC_LD = src/stm32f103_runtime_s60p.ld
	endif

	ifeq ($(model), S60)
		VECTOR_TABLE_OFFSET := 0x4400
		SRC_LD = src/stm32f103_runtime_s60.ld
	endif

	ifeq ($(model), S99)
		VECTOR_TABLE_OFFSET := 0x4C00
		SRC_LD = src/stm32f103_runtime_s99.ld
	endif

	

	# For MHP30 override the runtime to offset to 32k
	ifeq ($(model),MHP30)
		VECTOR_TABLE_OFFSET := 0x8000
		SRC_LD = src/stm32f103_32k_runtime.ld
	endif
	ifeq ($(model),$(filter $(model), TS100 TS80 TS80P ))
		VECTOR_TABLE_OFFSET := 0x4000
		SRC_LD = src/stm32f103_runtime.ld
	endif
BIN = runtime

else 
	VECTOR_TABLE_OFFSET := 0x0000
	SRC_LD = src/stm32f103.ld
BIN = bootloader

endif



INC = -I src

SRC_C += $(wildcard src/*.c)
# Defines required by included libraries
DEF = -DSTM32F030x8 -DVERSION=\"$(GIT_VERSION)\" -DVECTOR_TABLE_OFFSET=${VECTOR_TABLE_OFFSET} -DMODEL_${model}=1

# OpenOCD setup

JLINK_DEVICE = STM32F103C8

include cm-makefile/config.mk
include cm-makefile/rules.mk
include cm-makefile/jlink.mk

WARNFLAGS += -Wno-undef -Wno-conversion  -Wall -pedantic -Werror 

OPTFLAGS =  -Os -flto -finline-small-functions \
-findirect-inlining -fdiagnostics-color \
-ffunction-sections -fdata-sections -Wno-overlength-strings -ggdb -nostartfiles


ARCHFLAGS = -mcpu=cortex-m3 -mthumb -DSTM32F1 -std=c11 
DBGFLAGS = 

