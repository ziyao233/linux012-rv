/*
 *  linux/kernel/printk.c
 *
 *  (C) 1991  Linus Torvalds
 */

/*
 * When in kernel-mode, we cannot use printf, as fs is liable to
 * point to 'interesting' things. Make a printf with fs-saving, and
 * all is well.
 */
#include <stdarg.h>
#include <stddef.h>

#include <linux/kernel.h>

static char buf[1024];

size_t vsprintf(char *buf, const char *fmt, va_list args)
{
	char *p = buf;

	while (*fmt) {
		if (*fmt != '%') {
			*p = *fmt;
			p++;
			fmt++;
			continue;
		}

		fmt++;
		if (*fmt == '%') {
			*p = '%';
			p++;
			fmt++;
		} else if (*fmt == 'd') {
			int n = va_arg(args, int);
			int div = 10;
			while (n / div)
				div *= 10;
			div /= 10;

			while (div) {
				*p = n / div + '0';
				n %= div;
				p++;
			}
			fmt++;
		}
	}

	*p = '\0';

	return p - buf;
}

size_t sprintf(char *buf, const char *fmt, ...)
{
	va_list args;
	va_start(args, fmt);
	size_t s = vsprintf(buf, fmt, args);
	va_end(args);
	return s;
}

size_t printk(const char *fmt, ...)
{
	va_list args;
	int i;

	va_start(args, fmt);
	i=vsprintf(buf,fmt,args);
	va_end(args);
	console_print(buf);
	return i;
}
