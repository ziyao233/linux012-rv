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
	j		main
.park:
	wfi
	j		.park

	.bss
stack:	.skip		4096
