/*
 *	setup.S
 *	Copyright (c) 2023 Ziyao.
 *
 *	Suspend all CPUs except the one with mhartid = 0, then
 *	jump to the kernel
 */

#include <linux/config.h>

	.global		_start

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
	csrw		satp,		zero

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

	.bss
stack:	.skip		4096
