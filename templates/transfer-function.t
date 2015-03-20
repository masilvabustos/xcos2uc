
#if 0
#if (! defined  _TRANSFER_FUNCTION_PREFIX_) && (! defined _TRANSFER_FUNCTION_SUFFIX_)
#error Neither _TRANSFER_FUNCTION_PREFIX_ nor _TRANSFER_FUCTION_SUFFIX_ defined
#endif
#endif

#ifndef _TRANSFER_FUNCTION_NAME_
#error _TRANSFER_FUNCTION_NAME_ not defined!
#endif

#ifndef _CONFIG_NUMBER_TYPE
#define _CONFIG_NUMBER_TYPE double
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

#define STATE_NAME(tr_name) __##tr_name##_STATE__

#ifdef _STATIC_INLINE_
static __inline__
#else
#endif

 __fastcall__ _CONFIG_NUMBER_TYPE
_TRANSFER_FUNCTION_NAME_ 
(_CONFIG_NUMBER_TYPE x)
{
#define a ((number_t[])_FEEDBACK_COEFF_ARRAY_)
#define b ((number_t[])_FORWARD_COEFF_ARRAY_)

	register int i;
	register number_t y = 0;
	static number_t state[nelem+1];

	x *= a[0];
	
	for (i=1; i<sizeof(state)/sizeof(state[0]); i++){
		register number_t r;
		r = state[i];
		x += r*a[i];
		y += r*b[i];
	}

	state[0] = x;
	
	y += x*b[0];

	memmove(&state[1], &state[0], sizeof(state) - sizeof(state[0]));

	return y;

	
}

#undef _TRANSFER_FUNCTION_SUFFIX_
#undef _TRANSFER_FUNCTION_PREFIX_
#undef _TRANSFER_FUNCTION_NAME_
