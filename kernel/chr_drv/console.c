/*
 *  linux/kernel/console.c
 *
 *  (C) 1991  Linus Torvalds
 */

/*
 *	console.c
 *
 * This module implements the console io functions
 *	'void con_init(void)'
 *	'void con_write(struct tty_queue * queue)'
 * Hopefully this will be a rather complete VT102 implementation.
 *
 * Beeping thanks to John T Kohl.
 * 
 * Virtual Consoles, Screen Blanking, Screen Dumping, Color, Graphics
 *   Chars, and VT100 enhancements by Peter MacDonald.
 */

/*
 *  NOTE!!! We sometimes disable and enable interrupts for a short while
 * (to put a word in video IO), but this will work even for keyboard
 * interrupts. We know interrupts aren't enabled when getting a keyboard
 * interrupt, as we use trap-gates. Hopefully all is well.
 */

/*
 * Code to check for different video-cards mostly by Galen Hunt,
 * <g-hunt@ee.utah.edu>
 */

#include <linux/sched.h>
#include <linux/tty.h>
#include <linux/config.h>
#include <linux/kernel.h>

#include <asm/system.h>

#include <string.h>
#include <errno.h>

#define DEF_TERMIOS \
(struct termios) { \
	ICRNL, \
	OPOST | ONLCR, \
	0, \
	IXON | ISIG | ICANON | ECHO | ECHOCTL | ECHOKE, \
	0, \
	INIT_C_CC \
}

#define UART_BASE		0x10000000
#define UART_LSR		(UART_BASE + 0x5)
#define UART_LSR_TX_IDLE	0x40
#define UART_THR		(UART_BASE + 0x0)

static void writes(const char *s)
{
	for (; *s; s++) {
		volatile char *lsr = (volatile char*)UART_LSR;
		while (!(*lsr & UART_LSR_TX_IDLE))
			;
		*((char*)UART_THR) = *s;
	}
	return;
}

/*
 *	Always writes to the serial
 */
void con_write(struct tty_struct * tty)
{
	(void)tty;
	return;
}

/*
 *  void con_init(void);
 *
 * This routine initalizes console interrupts, and does nothing
 * else. If you want the screen to clear, call tty_write with
 * the appropriate escape-sequece.
 *
 * Reads the information preserved by setup.s to determine the current display
 * type and sets everything accordingly.
 */
void con_init(void)
{
	return;
}

void update_screen(void)
{
	return;
}


void sysbeepstop(void)
{
	return;
}

int do_screendump(int arg)
{
	(void)arg;
	return 0;
}

void blank_screen()
{
	return;
}

void unblank_screen()
{
	return;
}

void console_print(const char * b)
{
	writes(b);
	return;
}
