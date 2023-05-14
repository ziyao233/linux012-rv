/*
 *  linux/kernel/traps.c
 *
 *  (C) 1991  Linus Torvalds
 */

/*
 * 'Traps.c' handles hardware traps and faults after we have saved some * state in 'asm.s'. Currently mostly a debugging-aid, will be extended
 * to mainly kill the offending process (probably by giving it a signal,
 * but possibly by killing it outright if necessary).
 */
#include <string.h>

#include <linux/head.h>
#include <linux/sched.h>
#include <linux/kernel.h>
#include <linux/context.h>
#include <asm/system.h>

extern void do_exception(void);

void do_timer(int cpl);

void exception_handler(unsigned long int scause, unsigned long int sepc,
		       unsigned long int stval, unsigned long int sstatus,
		       unsigned long int from, unsigned long int *regs)
{
	(void)regs;
	if (scause == 0x8000000000000001L) {
		jiffies++;
		printk("Timer: %lu\n", jiffies);
		do_timer(from);
		asm volatile("csrc sip, 2");
	} else {
		printk("Unhandled exception with scause = 0x%x\n", scause);
		printk("ra: 0x%016x\tsp: 0x%016x\n", CONTEXT_REG(regs, ra),
		       CONTEXT_REG(regs, sp));
		printk("sepc: 0x%016x\tstval: 0x%016x\n", sepc, stval);
		printk("sstatus: 0x%016x\n", sstatus);
		panic("Unhandled exception.\n");
	}

	return;
}

void trap_init(void)
{
	asm("csrw	stvec,	%0" : : "r" (do_exception));
	return;
}
