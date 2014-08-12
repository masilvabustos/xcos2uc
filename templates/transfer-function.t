
#if (! defined  _TRANSFER_FUNCTION_PREFIX_) && (! defined _TRANSFER_FUNCTION_SUFFIX_)
#error Neither _TRANSFER_FUNCTION_PREFIX_ or _TRANSFER_FUCTION_SUFFIX_ defined
#endif

#ifndef _TRANSFER_FUNCTION_PREFIX_
#define _TRANSFER_FUNCTION_PREFIX_
#endif

#ifndef _TRANSFER_FUNCTION_SUFFIX_
#define _TRANSFER_FUNCTION_SUFFIX_
#endif

#define nelem (sizeof(a) > sizeof(b) ? sizeof(a) : sizeof(b))/sizeof(a[0])

#define __fastcall__ __attribute__((fastcall))

#include <string.h>

#define NAME2(prefix, suffix) prefix##transfer_function##suffix
#define NAME(prefix, suffix) NAME2(prefix, suffix) /* Macro expansion is done before call */

static inline __fastcall__ number_t 
NAME(_TRANSFER_FUNCTION_PREFIX_,_TRANSFER_FUNCTION_SUFFIX_) 
(number_t x)
{
#define a ((number_t[])COEFF_ARRAY_A)
#define b ((number_t[])COEFF_ARRAY_B)

	static number_t state[nelem];
	register int i;
	register number_t y = 0;

	x *= a[0];

	for (i=1; i<sizeof(state)/sizeof(state[0]); i++){
		register number_t r;
		r = state[i];
		x += r*a[i];
		y += r*b[i];
	}

	state[0] = x;
	y += x*b[0];

	memmove(&state[1], &state[0], sizeof(state));

	return y;
}

#undef _TRANSFER_FUNCTION_SUFFIX_
#undef _TRANSFER_FUNCTION_PREFIX_
