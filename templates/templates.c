
#define NUMBER_TYPE float
#define COEFF_ARRAY_A {1, .6, -0.05}
#define COEFF_ARRAY_B {5, 1.25, 0}

typedef NUMBER_TYPE number_t;



#define _TRANSFER_FUNCTION_SUFFIX_ _1
#include "transfer_function.h"

#include <stdio.h>

int main()
{
	number_t x;
	number_t y;

	while(1){
		scanf("%f", &x);
		
		y = transfer_function_1(x);
		
		printf("%f", y);
	};

};

	
