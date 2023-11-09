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
CFLAGS		= -Wall -O0 -g -march=rv64gc -mcmodel=medany	\
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
BOOT_SRC	= boot/setup.S
INIT_SRC	= init/main.c
MM_SRC		= mm/memory.c mm/swap.c
FS_SRC		= fs/buffer.c
CHR_DEV_SRC	= kernel/chr_drv/console.c kernel/chr_drv/tty_io.c 
BLK_DEV_SRC	= kernel/blk_drv/ll_rw_blk.c
KERNEL_SRC	= kernel/printk.c kernel/vsprintf.c kernel/traps.c
KERNEL_SRC     += kernel/entry.S kernel/sched.c kernel/panic.c
KERNEL_SRC     += kernel/sys.c
KERNEL_SRC     += $(CHR_DEV_SRC) $(BLK_DEV_SRC)
LIB_SRC		= lib/ctype.c lib/string.c
SRCS		= $(BOOT_SRC) $(MM_SRC) $(KERNEL_SRC) $(INIT_SRC) $(FS_SRC)   \
		  $(LIB_SRC)
OBJS		= $(patsubst %.S, %.o, $(patsubst %.c, %.o, $(SRCS)))

.S.o:
	$(CC) $(CFLAGS) -c -o $*.o $<
.c.o:
	$(CC) $(CFLAGS) -c -o $*.o $<

all: kernel.elf

kernel.elf: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o kernel.elf

clean:
	-rm $(OBJS)

run: kernel
	@echo "Type ^A then x to exit QEMU"
	@$(QEMU) $(QFLAGS)

debug: kernel
	@echo "Type ^A then x to exit QEMU"
	@echo 'Type "target remote localhost:1234" in gdb(-multiarch) to debug'
	@$(QEMU) $(QFLAGS) -S -s
