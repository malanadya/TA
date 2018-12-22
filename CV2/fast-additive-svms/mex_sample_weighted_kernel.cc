/* Author : Subhransu Maji, Date : Feb 2, 2010
 *
 * This paper builds on the code and details of the paper: 
 *
 * Classification Using Intersection Kernel SVMs are Efficient, 
 * Subhransu Maji, Alexander C. Berg, Jitendra Malik, CVPR 2008.
 *
 * Version 3.0
 */
#include <stdio.h>
#include "mex.h"
#include "matrix.h"
#include <math.h>

#if MX_API_VER < 0x07030000
typedef int mwIndex;
#endif

#define MIN(x,y) (x <= y ? x : y)

static void fake_answer(mxArray *plhs[])
{
	plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
}

void exit_with_help()
{
	mexPrintf("Usage: f = mex_sample_weighted_kernel(a,x,y,k)\n");
}
void sample_weighted_kernel(int nlhs, mxArray *plhs[], const mxArray *prhs[])
{
	// pointers to input
	double *a = (double *)mxGetPr(prhs[0]);
	double *x = (double *)mxGetPr(prhs[1]);
	double *y = (double *)mxGetPr(prhs[2]);
	int    KERNEL_TYPE = (int)*mxGetPr(prhs[3]);
	
	if(KERNEL_TYPE != 5 && KERNEL_TYPE != 6 && KERNEL_TYPE != 7){
		mexPrintf("[mex] Unsupported Kernel type (5,6,7) are supported.\n");
		fake_answer(plhs);
		return;
	}
	
	int dim = mxGetM(prhs[2]);
	int nx  = mxGetM(prhs[0]);
	int i,j;
	double fval;
	
	// allocate output 
	plhs[0] = mxCreateNumericMatrix(dim,1,mxDOUBLE_CLASS, mxREAL);
	double *f = mxGetPr(plhs[0]);
	
	for(i = 0; i < dim ; i++){
		fval = 0;
		for(j = 0; j < nx; j++){
			switch (KERNEL_TYPE) {
				case 5:
					fval += a[j]*MIN(x[j],y[i]);
					break;
				case 6: 
					fval += a[j]*2*x[j]*y[i]/(x[j]+y[i]);
					break;
				case 7:
					fval += 0.5*a[j]*(x[j]*log((y[i]+x[j])/x[j]) + y[i]*log((y[i]+x[j])/y[i]));
					break;
				default:
					break; //should not happen
			}
		}
		f[i] = fval;
	}
}

//f = mex_sample_weighted_kernel(a,x,y,k)
void mexFunction( int nlhs, mxArray *plhs[],
				 int nrhs, const mxArray *prhs[] )
{
	if(nrhs != 4 || nlhs != 1)
	{
		exit_with_help();
		fake_answer(plhs);
		return;
	}
	sample_weighted_kernel(nlhs, plhs, prhs);
	return;
}

