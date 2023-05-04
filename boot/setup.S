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

.park:
	wfi
	j		.park
