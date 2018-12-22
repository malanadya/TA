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
#include <algorithm>

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
	mexPrintf("Usage: f = mex_sample_weighted_int_kernel(a,x,y)\n");
}

using namespace std;
//wrapper for value and indx

class val_indx{
public:
	double val; int indx;
	val_indx(double val, int indx){
		this->val = val; this->indx = indx;
	}
	bool operator<(const val_indx &other) const{
		return this->val < other.val;
	}
};

//returns the index which sorts vals in increasing order
void sort_index(int *index, const double *vals, int dim){
	val_indx *data = (val_indx*)malloc(sizeof(val_indx)*dim);
	for(int i = 0; i < dim;i++)
		data[i] = val_indx(vals[i],i);
	sort(data,data+dim);
	for(int i = 0; i < dim; i++)
		index[i] = data[i].indx;
	free(data);
};

//sample weighted intersection kernel using sorting
void sample_weighted_int_kernel(int nlhs, mxArray *plhs[], const mxArray *prhs[])
{
	// pointers to input
	double *a = (double *)mxGetPr(prhs[0]);
	double *x = (double *)mxGetPr(prhs[1]);
	double *y = (double *)mxGetPr(prhs[2]);
	int dim = mxGetM(prhs[2]);
	int nx  = mxGetM(prhs[0]);

	
	int *sidx = new int[nx];
	
	sort_index(sidx,x,nx);
	
	// allocate output 
	plhs[0] = mxCreateNumericMatrix(dim,1,mxDOUBLE_CLASS, mxREAL);
	double *f = mxGetPr(plhs[0]);
	double suma = 0;
	
	//sum of weights
	int idx, i;
	for(i = 0; i < nx ; i++)
		suma += a[i];

	// loop over the sorted list and compute the sums
	idx = 0;i = 0;	
	double sa = 0, sax = 0;
	while(idx < dim && i < nx){
		if(y[idx] <= x[sidx[i]]){
			f[idx] = sax + (suma - sa)*y[idx];
			idx++;
		}else {
			sax += a[sidx[i]]*x[sidx[i]];
			sa  += a[sidx[i]];
			i++;
		}
	}
	delete [] sidx;
}

//f = mex_sample_weighted_kernel(a,x,y,k)
void mexFunction( int nlhs, mxArray *plhs[],
				 int nrhs, const mxArray *prhs[] )
{
	if(nrhs != 3 || nlhs != 1)
	{
		exit_with_help();
		fake_answer(plhs);
		return;
	}
	sample_weighted_int_kernel(nlhs, plhs, prhs);
	return;
}

