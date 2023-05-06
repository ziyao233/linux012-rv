#ifndef _STDARG_H
#define _STDARG_H

typedef __builtin_va_list va_list;

#define va_start(AP, LASTARG) __builtin_va_start(AP, LASTARG)
#define va_end(AP) __builtin_va_end(AP)

#define va_arg(AP, TYPE) __builtin_va_arg(AP, TYPE)

#endif /* _STDARG_H */
