#ifndef __TRAP_H__
#define __TRAP_H__

#define CONTEXT_SIZE 272

#define CONTEXT_ra		0
#define CONTEXT_sp		8
#define CONTEXT_gp		16
#define CONTEXT_tp		24
#define CONTEXT_t0		32
#define CONTEXT_t1		40
#define CONTEXT_t2		48
#define CONTEXT_s0		56
#define CONTEXT_s1		64
#define CONTEXT_a0		72
#define CONTEXT_a1		80
#define CONTEXT_a2		88
#define CONTEXT_a3		96
#define CONTEXT_a4		104
#define CONTEXT_a5		112
#define CONTEXT_a6		120
#define CONTEXT_a7		128
#define CONTEXT_s2		136
#define CONTEXT_s3		144
#define CONTEXT_s4		152
#define CONTEXT_s5		160
#define CONTEXT_s6		168
#define CONTEXT_s7		176
#define CONTEXT_s8		184
#define CONTEXT_s9		192
#define CONTEXT_s10		200
#define CONTEXT_s11		208
#define CONTEXT_t3		216
#define CONTEXT_t4		224
#define CONTEXT_t5		232
#define CONTEXT_t6		240
#define CONTEXT_SEPC		248
#define CONTEXT_SCAUSE		256
#define CONTEXT_STVAL		264	

#endif	// __TRAP_H__
