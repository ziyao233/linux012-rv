#ifndef _STRING_H_
#define _STRING_H_

#ifndef NULL
#define NULL ((void *) 0)
#endif

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned int size_t;
#endif

extern char * strerror(int errno);

/*
 * This string-include defines all string functions as inline
 * functions. Use gcc. It also assumes ds=es=data space, this should be
 * normal. Most of the string-functions are rather heavily hand-optimized,
 * see especially strtok,strstr,str[c]spn. They should work, but are not
 * very easy to understand. Everything is done entirely within the register
 * set, making the functions fast and clean. String instructions have been
 * used through-out, making for "slightly" unclear code :-)
 *
 *		(C) 1991 Linus Torvalds
 */
 
extern inline char * strcpy(char * dest, const char *src)
{
	char *t = dest;
	while (*src)
		*(dest++) = *(src++);
	*dest = '\0';
	return t;
}

extern inline char * strncpy(char * dest, const char *src, int count)
{
	char *t = dest;
	while (*src) {
		if (!(count--))
			goto end;
		*(dest++) = *(src++);
	}
	*dest = '\0';
end:
	return t;
}

extern inline char * strcat(char * dest,const char * src)
{
	char *t = dest;
	while (*dest)
		dest++;
	while (*src)
		*(dest++) = *(src++);
	*dest = '\0';
	return t;
}

extern inline char * strncat(char * dest,const char * src,int count)
{
	char *t = dest;
	while (*dest)
		dest++;

	while (*src) {
		if (!(count--))
			goto end;
		*(dest++) = *(src++);
	}
	*dest = '\0';
end:
	return t;
}

extern inline int strcmp(const char * cs,const char * ct)
{
	while (*cs || *ct) {
		if (*cs != *ct)
			return *cs - *ct;
		cs++;
		ct++;
	}
	return 0;
}

extern inline int strncmp(const char * cs,const char * ct,int count)
{
	while ((*cs || *ct) && (count--)) {
		count--;
		if (*cs != *ct)
			return *cs - *ct;
		cs++;
		ct++;
	}
	return 0;
}

extern inline char * strchr(const char * s,char c)
{
	while (*s && *s != c)
		s++;
	return (char*)(*s ? s : NULL);
}

extern inline char * strrchr(const char * s,char c)
{
	const char *t = s;
	while (*s)
		s++;

	while (*(s - 1) != c && s > t)
		s--;

	return (char*)(s > t ? s : NULL);
}

static int __occur(char c, const char *ct)
{
	for (const char *p = ct; *p; p++) {
		if (c == *p)
			return 1;
	}
	return 0;
}

extern inline size_t strspn(const char * cs, const char * ct)
{
	const char *t = cs;

	while (*cs && __occur(*cs, ct))
		cs++;
	return cs - t;
}

extern inline int strcspn(const char * cs, const char * ct)
{
	const char *t = cs;

	while (*cs && !__occur(*cs, ct))
		cs++;
	return cs - t;
}

extern inline char * strpbrk(const char * cs,const char * ct)
{
	while (*cs) {
		if (__occur(*cs, ct))
			return (char*)cs;
		cs++;
	}
	return NULL;
}

extern inline size_t strlen(const char * s)
{
	size_t size = 0;
	while (*(s++))
		size++;
	return size;
}

extern char * ___strtok;

extern inline void * memcpy(void * dest,const void * src, int n)
{
	char *p1 = dest;
	const char *p2 = src;
	while (n) {
		*(p1++) = *(p2++);
		n--;
	}
	return dest;
}

extern inline void * memmove(void * dest,const void * src, int n)
{
	return memcpy(dest, src, n);
}

extern inline int memcmp(const void * cs,const void * ct,int count)
{
	const char *p1 = cs, *p2 = ct;
	while (count-- && *p1 == *p2) {
		p1++;
		p2++;
	}
	return *p1 - *p2;
}

extern inline void * memchr(const void * cs,char c,int count)
{
	char *p = (char*)cs;
	while (count-- && *p != c)
		p++;
	return *p ? p : NULL;
}

extern inline void * memset(void * s,char c,int count)
{
	char *p = s;
	while (count--)
		*(p++) = c;
	return s;
}

#endif
