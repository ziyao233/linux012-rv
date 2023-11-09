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

	la		sp,		pid0_stack

	csrw		pmpcfg0,	0xf
	li		t0,		0x3fffffffffffff
	csrw		pmpaddr0,	t0

	la		t0,		pg_dir
	li		t1,		0x801fe000
	li		t2,		8192
.copy_page_table:
	ld		t3,		0(t0)
	sd		t3,		0(t1)
	addi		t0,		t0,		8
	addi		t1,		t1,		8
	addi		t2,		t2,		-8
	bnez		t2,		.copy_page_table

	li		t0,		0x80000000000801fe
	sfence.vma
	csrw		satp,		t0
	sfence.vma

	li		t0,		0xffff
	csrw		medeleg,	t0
	csrw		mideleg,	t0

	/*	Initialise machine timer	*/
	la		t0,		machine_timer_handler
	csrw		mtvec,		t0
	li		t0,		0x200BFF8
	ld		t0,		0(t0)
	li		t1,		0x2004000
	ld		t0,		0(t1)
	li		t2,		100000
	add		t0,		t0,		t2
	sd		t0,		0(t1)
	la		t0,		mscratches
	csrw		mscratch,	t0

	/*	Setup exceptions	*/
	csrr		t0,		mie
	li		t1,		(1 << 7)	// MTIE
	or		t0,		t1,		t0
	csrw		mie,		t0

	csrr		t0,		sie
	li		t1,		(1 << 1)	// SSIE
	or		t0,		t1,		t0
	csrw		sie,		t0

	csrr		t0,		mstatus
	li		t1,		~(3 << 11)
	and		t0,		t1,		t0
	li		t1,		(1 << 11)
	or		t0,		t0,		t1
	csrw		mstatus,	t0
	la		t0,		main
	csrw		mepc,		t0
	mret

.park:
	wfi
	j		.park

	.align		4
machine_timer_handler:
	csrrw		t0,		mscratch,		t0
	sd		t1,		0(t0)
	sd		t2,		8(t0)
	sd		t3,		16(t0)

	li		t3,		0x2004000
	ld		t1,		0(t3)
	li		t2,		100000
	add		t1,		t1,			t2
	sd		t1,		0(t3)

	li		t1,		2			// SSIP
	csrw		sip,		t1

	ld		t1,		0(t0)
	ld		t2,		8(t0)
	ld		t3,		16(t0)
	csrrw		t0,		mscratch,		t0
	mret

	.data
pg_dir:
	.quad		0x7		// 0 + 1G -> 0
	.quad		0x10000007	// 0x40000000 + 1G -> 0x40000000
	.quad		0x2000000f	// 0x80000000 + 1G -> 0x80000000
	.quad		0x2000001f	// 0x80000000 + 1G -> 0xc0000000
	.zero		4096 - 4 * 8

	.bss
mscratches:
	.skip		32
	.align		16
	.skip		4096
pid0_stack:
