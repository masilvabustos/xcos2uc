
#include <string.h>
#include <math.h>

typedef float number_t;

struct nevilles_algorithm_workspace {
	number_t *C;
	number_t *D;
	number_t *e;
};

struct point {
	number_t t;
	number_t x;
};

#define nevilles_algorithm_workspace_size(N) (sizeof(number_t) * (2 * N + 1))

void setup_nevilles_algorithm_workspace(unsigned N, struct nevilles_algorithm_workspace* ws, void * ptr)
{
	ws->C = ptr;
	ws->D = (void*) ws->C + sizeof(number_t)*N;
	ws->e = (void*) ws->D;
}


number_t nevilles_algorithm(unsigned N, number_t _t, number_t t[], number_t x[], struct nevilles_algorithm_workspace ws)
{
	number_t _x, dx;

	float dif, dift;
	int i, m, ns;

	dif=fabs(_t-t[0]);
	for (i=0;i<N;i++) {
		if ( (dift=fabs(_t-t[i])) < dif) {
			ns=i;
			dif=dift;
		}
	}

	memmove(&ws.C[0], &x[0], N);
	memmove(&ws.D[0], &x[0], N);

	_x=x[ns--];

	for (m=1; m<=N-1; m++) {
		for (i=0; i<N-m-1; i++) {
			number_t factor = (ws.C[i+1] - ws.D[i]) / (t[i] - t[i+m+1]);
			ws.C[i] = (t[i] - _t) * factor ;
			ws.D[i]= (t[i+m+1] - _t) * factor;
		}
		dx = (2*ns < (N-m)) ? ws.C[ns+1] : ws.D[ns--];
		_x += dx;
	}
	*ws.e = dx;
	return _x;
};

#include <malloc.h>

number_t f(number_t x)
{
	return x*(x*(x*12 + 5) + 9) + 6;
}

int main()
{
#if 0
	number_t x;
	struct nevilles_algorithm_workspace ws;
	setup_nevilles_algorithm_workspace(5, &ws, malloc(nevilles_algorithm_workspace_size(5)));

	
	
	for(x=-10; x<10; x+=.1) {
		number_t y;
		y = nevilles_algorithm(5, x, 
#endif
	
	return 0;
}
