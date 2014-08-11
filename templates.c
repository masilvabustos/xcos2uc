
#define NUMBER_TYPE float
#define COEFF_ARRAY_A {1, .6, -0.05}
#define COEFF_ARRAY_B {5, 1.25, 0}

typedef NUMBER_TYPE number_t;



#define nelem (sizeof(a) > sizeof(b) ? sizeof(a) : sizeof(b))/sizeof(*a)

#define __fastcall__ __attribute__((fastcall))

#include <string.h>

static inline __fastcall__ number_t transfer(number_t x)
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
		
#include <stdio.h>

int main()
{
	number_t x;
	number_t y;

	while(1){
		scanf("%f", &x);
		
		y = transfer(x);
		
		printf("%f", y);
	};

};

	
