/*
 *	linux/kernel/entry.S
 *	By GPLv2.
 *	Copyright (c) 2023 Ziyao.
 */

#include<linux/context.h>

	.global		do_exception
	.global		ret_from_exception
	.global		switch_to
	.global		do_user_exception
	.text

#define save(a) sd a, CONTEXT_##a##(sp)
#define load(a) ld a, CONTEXT_##a##(sp)

	.macro	save_context

	addi		sp,		sp,		-CONTEXT_SIZE
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
	addi		t0,		sp,		CONTEXT_SIZE
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

// TODO: Switch to kernel stack when dealing with an exception from userspace
do_exception:
	save_context
	la		ra,		ret_from_exception
	csrr		a0,		scause
	csrr		a1,		sepc
	csrr		a2,		stval
	csrr		a3,		sstatus
	csrr		a4,		sscratch
	mv		a5,		zero
	mv		a6,		sp
	j		exception_handler

ret_from_exception:
	restore_context
	ld		sp,		CONTEXT_sp(sp)
	sret

	/*
	 *	sscratch: current->kstack
	 */
do_user_exception:
	csrrw		sp,		sscratch,		sp
	save_context
	la		t0,		do_exception
	csrw		stvec,		t0
	la		ra,		ret_from_user_exception
	csrr		a0,		scause
	csrr		a1,		sepc
	csrr		a2,		stval
	csrr		a3,		sstatus
	csrr		a4,		sscratch
	li		a5,		1
	mv		a6,		sp
	j		exception_handler

ret_from_user_exception:
	la		t0,		do_user_exception
	csrw		stvec,		t0
	restore_context
	ld		sp,		CONTEXT_sp(sp)
	csrrw		sp,		sscratch,		sp
	sret

switch_to:
	sd		ra,		0(a0)
	sd		s0,		8(a0)
	sd		s1,		16(a0)
	sd		s2,		24(a0)
	sd		s3,		32(a0)
	sd		s4,		40(a0)
	sd		s5,		48(a0)
	sd		s6,		56(a0)
	sd		s7,		64(a0)
	sd		s8,		72(a0)
	sd		s9,		80(a0)
	sd		s10,		88(a0)
	sd		s11,		96(a0)
	sd		sp,		104(a0)
	csrr		t0,		satp
	sd		t0,		112(a0)

	ld		ra,		0(a1)
	ld		s0,		8(a1)
	ld		s1,		16(a1)
	ld		s2,		24(a1)
	ld		s3,		32(a1)
	ld		s4,		40(a1)
	ld		s5,		48(a1)
	ld		s6,		56(a1)
	ld		s7,		64(a1)
	ld		s8,		72(a1)
	ld		s9,		80(a1)
	ld		s10,		88(a1)
	ld		s11,		96(a1)
	ld		sp,		104(a1)
	ld		t0,		112(a1)
	csrw		satp,		t0
	sfence.vma

	jr		ra
