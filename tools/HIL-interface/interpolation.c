
#include <string.h>
#include <math.h>
#include <stdio.h>

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
	ws->D = (void*) &ws->C[N];
	ws->e = (void*) &ws->D[N];
}


number_t nevilles_algorithm(unsigned N, number_t _t, number_t t[], number_t x[], struct nevilles_algorithm_workspace ws)
{
	number_t _x, dx;

	float dif, dift;
	int i, m, ns;

	dif=fabs(_t-t[0]);
	for (ns=i=0;i<N;i++) {
		if ( (dift=fabs(_t-t[i])) < dif) {
			ns=i;
			dif=dift;
		}
		
	}

	memmove(&ws.C[0], &x[0], sizeof(number_t)*N);
	memmove(&ws.D[0], &x[0], sizeof(number_t)*N);

	_x=x[ns--];
	printf("\n\nx=(%f)\n", _x);
	//_x=x[0];

	for (m=1; m<=N-1; m++) {
		for (i=0; i<N-m; i++) {
			number_t factor = (ws.C[i+1] - ws.D[i]) / (t[i] - t[i+m]);
			ws.C[i] = (t[i] - _t) * factor ;		
			ws.D[i]= (t[i+m] - _t) * factor;
			printf("C[%d]=%f D[%d]=%f\n", i, ws.C[i], i, ws.D[i]);		
		}
		dx = (2*(ns+1) < (N-m)) ? ws.C[ns+1] : ws.D[ns--];
		printf("x = %f + %f\n\n", _x, dx);	
		_x += dx;

	}

	*ws.e = dx;
     
	return _x;
};
#ifdef MINITEST
#include <malloc.h>
#include <stdio.h>
float *vector(int i, unsigned n)
{
	return malloc(sizeof(float)*n+1);
}

void free_vector(float* v, int i, int j)
{
	free(v);
}

void polint(float xa[], float ya[], int n, float x, float *y, float *dy)
{
	int i,m,ns=1;
	float den,dif,dift,ho,hp,w;

	float *c,*d;

	dif=fabs(x-xa[1-1]);
	c=vector(1,n);
	d=vector(1,n);
	for (i=1;i<=n;i++) {

		if ( (dift=fabs(x-xa[i-1])) < dif) {
			ns=i-1;
			dif=dift;
		}
		c[i-1]=ya[i-1];

		d[i-1]=ya[i-1];
	}
	*y=ya[ns--];
	//*y = ya[1-1];

	for (m=1;m<n;m++) {

		for (i=0;i<n-m;i++) {
#if 0
			ho=xa[i]-x;

			hp=xa[i+m]-x;
			w=c[i+1]-d[i];
			if ( (den=ho-hp) == 0.0) fprintf(stderr, "Error in routine polint");

			den=w/den;
			d[i]=hp*den;

			c[i]=ho*den;
#endif
			number_t factor = (c[i+1] - d[i]) / (xa[i] - xa[i+m]);
			c[i] = (xa[i] - x) * factor ;
			
			d[i]= (xa[i+m] - x) * factor;
		}
		*y += (*dy=(2*(ns+1) < (n-m) ? c[ns+1] : d[ns--]));
		//*y += c[1-1];

	}
	free_vector(d,1,n);
	free_vector(c,1,n);
}



number_t f(number_t x)
{
	return x*(x*5 + 2) - 6;
}

int main()
{

	number_t x, xa[5], ya[5];
	int i;
	
	struct nevilles_algorithm_workspace ws;
	setup_nevilles_algorithm_workspace(5, &ws, malloc(nevilles_algorithm_workspace_size(5)));

	for(i=0; i<5; i++){
		xa[i]=-10.0+i*4.0;
		ya[i]=f(xa[i]);
	}
	
	for(x=-10; x<10; x+=.1) {
		number_t y, dy;
		//polint(xa, ya, 3, x, &y, &dy);
		y = nevilles_algorithm(4, x, xa, ya, ws); dy=*ws.e;
		printf("%lf %lf %lf %lf %lf\n", x, f(x), y, y - f(x), dy);
	}

	
	return 0;
}
#endif
