
#include <string.h>
#include <math.h>

typedef float number_t;

number_t lagrange_polynomials[][];

struct nevilles_algorithm_workspace {
	number_t *C;
	number_t *D;
	number_t *e;
};

struct nevilles_algorithm_parameters {
	number_t t[];
	number_t x[];
};


number_t nevilles_algorithm(unsigned N, number_t t, struct nevilles_algorithm_parameters p, struct nevilles_algorithm_workspace ws)
{
	number_t x;

	float dif, dift;
	int i, m, ns;

	dif=fabs(t-p.t[0]);
	for (i=0;i<N;i++) {
		if ( (dift=fabs(t-t[i])) < dif) {
			ns=i;
			dif=dift;
		}
	}

	memmove(&ws.C[0], &p.x[0], N);
	memmove(&ws.D[0], &p.x[0], N);

	x=p.x[ns--];

	for (m=1; m<=N-1; m++) {
		for (i=0; i<N-m-1; i++) {
			number_t factor = (ws.C[i+1] - ws.D[i]) / (p.t[i] - p.t[i+m+1]);
			ws.C[i] = (p.t[i] - t) * factor ;
			ws.D[i]= (p.t[i+m+1] - t) * factor;
		}
		dx = (2*ns < (N-m)) ? ws.C[ns+1] : ws.D[ns--];
		x += dx;
	}
	ws.e = dx;
	return x;
};

int main()
{
	return 0;
}
