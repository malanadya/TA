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

#if MX_API_VER < 0x07030000
typedef int mwIndex;
#endif

#define MIN(x,y) (x <= y ? x : y)
#define MAX(x,y) (x <= y ? y : x)

static void fake_answer(mxArray *plhs[])
{
	plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
}

void exit_with_help()
{
	mexPrintf("Usage: fy = mex_linear_interpolate(f,x,y)\n");
}


//sample weighted intersection kernel using sorting
void linear_interpolate(int nlhs, mxArray *plhs[], const mxArray *prhs[])
{
	// pointers to input
	double *fx = (double *)mxGetPr(prhs[0]);
	double *x  = (double *)mxGetPr(prhs[1]);
	double *y  = (double *)mxGetPr(prhs[2]);
	int nx  = mxGetM(prhs[0]);
	int ny  = mxGetM(prhs[2]);
	
	
	// allocate output 
	plhs[0] = mxCreateNumericMatrix(ny,1,mxDOUBLE_CLASS, mxREAL);
	double *fy = mxGetPr(plhs[0]);
	
	double stepsize = (x[nx-1] - x[0])/(nx-1);
	double fidx, alpha; 
	int i, lidx, ridx; 

	for(i = 0; i < ny ; i++){
		fidx  = (y[i]-x[0])/stepsize;
		lidx  = (int)fidx;
		ridx  = lidx+1;
		alpha = fidx-lidx;
		lidx  = MIN(MAX(0,lidx),nx-1);
		ridx  = MIN(MAX(0,ridx),nx-1);
		fy[i] = fx[lidx]*(1-alpha) + fx[ridx]*(alpha);
	}
}

//fy = mex_linear_interpolate(f,x,y)
void mexFunction( int nlhs, mxArray *plhs[],
				 int nrhs, const mxArray *prhs[] )
{
	if(nrhs != 3 || nlhs != 1)
	{
		exit_with_help();
		fake_answer(plhs);
		return;
	}
	linear_interpolate(nlhs, plhs, prhs);
	return;
}

