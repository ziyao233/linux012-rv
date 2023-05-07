/*
 *	setup.S
 *	Copyright (c) 2023 Ziyao.
 *
 *	Suspend all CPUs except the one with mhartid = 0, then
 *	jump to the kernel
 */

#include <linux/config.h>

	.global		_start
	.global		pg_dir
	.global		pg_dir_kernel

_start:
	csrr		t0,		mhartid
	bnez		t0,		.park

	la		t0,		__bss_start
	la		t1,		__bss_end

.clear_bss:
	sd		zero,		0(t0)
	add		t0,		t0,		8
	blt		t0,		t1,		.clear_bss

	la		sp,		stack

	csrw		pmpcfg0,	0xf
	li		t0,		0x3fffffffffffff
	csrw		pmpaddr0,	t0

	la		t0,		pg_dir
	la		t1,		pg_dir_kernel
	srli		t1,		t1,		2
	or		t1,		t1,		1
	sd		t1,		16(t0)
	srli		t0,		t0,		12
	li		t1,		1
	slli		t1,		t1,		63
	or		t0,		t1,		t0

	la		t0,		pg_dir
	li		t1,		0x8001e000
	li		t2,		8192
.copy_page_table:
	ld		t3,		0(t0)
	sd		t3,		0(t1)
	addi		t0,		t0,		8
	addi		t1,		t1,		8
	addi		t2,		t2,		-8
	bnez		t2,		.copy_page_table

	li		t0,		0x8001e000
	sfence.vma
	csrw		satp,		t0
	sfence.vma

	li		t0,		0xffff
	csrw		medeleg,	t0
	csrw		mideleg,	t0

	csrr		t0,		mstatus
	li		t1,		~(3 << 11)
	and		t0,		t1,		t0
	li		t1,		1 << 11
	or		t0,		t0,		t1
	csrw		mstatus,	t0
	la		t0,		main
	csrw		mepc,		t0
	mret

.park:
	wfi
	j		.park

	.data
pg_dir:
	.quad		0x7		// 0 + 1G -> 0
	.quad		0x10000007	// 0x40000000 + 1G -> 0x40000000
	.quad		0		// 0x80000000 + 1G
	.zero		4096 - 3 * 8
pg_dir_kernel:
	.quad		0x2000000f	// 0x80000000 + 2MB -> 0x80000000
	.zero		4096 - 8

	.bss
stack:	.skip		4096
