PREFIX		?= riscv-none-elf-

#
# if you want the ram-disk device, define this to be the
# size in blocks.
#
RAMDISK		= #-DRAMDISK=512
LDSCRIPT	= link.ld
RELEASE		?= 0

LD		= $(PREFIX)ld
LDFLAGS		= -T $(LDSCRIPT)
CC		= $(PREFIX)gcc $(RAMDISK)
CFLAGS		= -Wall -O -march=rv64gc -mcmodel=medany	\
		  -mabi=lp64d -pedantic -Wextra -std=gnu99	\
		  -nostdinc -Iinclude -fno-builtin
ifneq ($(RELEASE), 1)
	CFLAGS	+= -g
	LDFLAGS += -g
else
	LDFLAGS	+= -s -x
endif
QEMU		= qemu-system-riscv64
QFLAGS		= -bios none -kernel kernel.elf -m 128M -nographic	\
		  -machine virt

#
# ROOT_DEV specifies the default root-device when making the image.
# This can be either FLOPPY, /dev/xxxx or empty, in which case the
# default of /dev/hd6 is used by 'build'.
#
ROOT_DEV	= /dev/hd6
SWAP_DEV	= /dev/hd2
SRCS		= boot/setup.S init/main.c mm/memory.c
OBJS		= $(patsubst %.S, %.o, $(patsubst %.c, %.o, $(SRCS)))

.S.o:
	$(CC) $(CFLAGS) -c -o $*.o $<
.c.o:
	$(CC) $(CFLAGS) -c -o $*.o $<

all: kernel

kernel: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o kernel.elf

clean:
	-rm $(OBJS)

dep dep.mk: $(SRC)
	@echo Generating dep.mk
	@$(CC) $(CFLAGS) -MM $(SRCS) > dep.mk

run: kernel
	@echo "Type ^A then x to exit QEMU"
	@$(QEMU) $(QFLAGS)

debug: kernel
	@echo "Type ^A then x to exit QEMU"
	@echo 'Type "target remote localhost:1234" in gdb(-multiarch) to debug'
	@$(QEMU) $(QFLAGS) -S -s

include dep.mk
