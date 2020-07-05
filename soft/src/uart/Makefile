default: all

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/uart/elf
obj = $(wildcard $(src_dir)/uart/*.S) $(wildcard $(src_dir)/uart/*.c)

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -g -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc -T $(src_dir)/uart/link.ld
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -S -Mnumeric,no-aliases --disassemble-all --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/env -I$(src_dir)/uart -I$(src_dir)/common

uart.elf: $(obj)
	echo $(obj)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -DNUMBER_OF_RUNS=$(ITER) -o $(bld_dir)/$@ $(obj) $(RISCV_LINK_OPTS)

%.o: %.c
	echo $<
	$(RISCV_GCC) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) -c $< -o $@

uart.dump: $(bld_dir)/uart.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

uart.bin: $(bld_dir)/uart.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: uart.elf uart.dump uart.bin