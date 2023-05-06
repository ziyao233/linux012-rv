/*
 *	linux/kernel/entry.S
 *	By GPLv2.
 *	Copyright (c) 2023 Ziyao.
 */

#include<linux/context.h>

	.global		do_exception
	.text

#define save(a) sd a, CONTEXT_##a##(sp)
#define load(a) ld a, CONTEXT_##a##(sp)

	.macro	save_context

	addi		sp,		sp,		CONTEXT_SIZE
	save(ra)
	save(gp)
	save(tp)
	save(t0)
	save(t1)
	save(t2)
	save(s0)
	save(s1)
	save(a0)
	save(a1)
	save(a2)
	save(a3)
	save(a4)
	save(a5)
	save(a6)
	save(a7)
	save(s2)
	save(s3)
	save(s4)
	save(s5)
	save(s6)
	save(s7)
	save(s8)
	save(s9)
	save(s10)
	save(s11)
	save(t3)
	save(t4)
	save(t5)
	save(t6)
	addi		t0,		sp,		-CONTEXT_SIZE
	sd		t0,		CONTEXT_sp(sp)

	.endm

	.macro	restore_context
	load(ra)
	load(gp)
	load(tp)
	load(t0)
	load(t1)
	load(t2)
	load(s0)
	load(s1)
	load(a0)
	load(a1)
	load(a2)
	load(a3)
	load(a4)
	load(a5)
	load(a6)
	load(a7)
	load(s2)
	load(s3)
	load(s4)
	load(s5)
	load(s6)
	load(s7)
	load(s8)
	load(s9)
	load(s10)
	load(s11)
	load(t3)
	load(t4)
	load(t5)
	load(t6)
	.endm

#undef save
#undef load

	.align		4

do_exception:
	save_context
	la		ra,		ret_from_exception
	csrr		a0,		scause
	mv		a1,		sp
	j		exception_handler

ret_from_exception:
	restore_context
	ld		sp,		CONTEXT_sp(sp)
	sret