#define move_to_user_mode(f)	\
asm volatile("csrc	sstatus, %0\n\t"		\
	     "csrw	sepc, %1\n\t"			\
	     "add	sp, sp, %2\n\t"			\
	     "sret" :					\
	     : "r" (1 << 8), "r" (f), "r" (0x200000))

#define sti() \
asm volatile("csrs sstatus, 1 << 1\n\t")
#define cli() \
asm volatile("csrc sstatus, 1 << 1\n\t")
#define nop() __asm__ ("nop"::)
