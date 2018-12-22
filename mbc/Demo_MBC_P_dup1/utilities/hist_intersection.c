/** file:        imsmooth.c
 ** author:      Andrea Vedaldi
 ** description: 
 ** first Input  Test_pt=[te1 te2 ...] te is column vector
 ** second Input  Train_pt=[tr1 tr2 ...] tr is column vector
 ** Output Similarity [s11 s12 ...
                       s21 s22 ...
					   .  .  .  . .
					   .  .  .  . .]
					   sxy means the similarity between te x and tr y
 **/

#include"mex.h"
#include<stdlib.h>
#include<string.h>
#include<math.h>
#include<assert.h>

#define greater(a,b) ((a) > (b))
#define min(a,b) (((a)<(b))?(a):(b))
#define max(a,b) (((a)>(b))?(a):(b))

#define PAD_BY_CONTINUITY

const double win_factor = 1.5 ;
const int nbins = 36 ;

void
mexFunction(int nout, mxArray *out[], 
            int nin, const mxArray *in[])
{
  int M,N_test,N_train ;
  double* Test_pt ;
  double* Train_pt ;
  double* J_pt ;
  enum {I=0,H} ;
  enum {J=0} ;

  /* ------------------------------------------------------------------
  **                                                Check the arguments
  ** --------------------------------------------------------------- */ 
  if (nin != 2) {
    mexErrMsgTxt("Exactly two input arguments required.");
  } else if (nout > 1) {
    mexErrMsgTxt("Too many output arguments.");
  }
  
  if (!mxIsDouble(in[I])) {
    mexErrMsgTxt("All arguments must be real.") ;
  }
  
  if(mxGetNumberOfDimensions(in[I]) > 2||
     mxGetNumberOfDimensions(in[H]) > 2) {
    mexErrMsgTxt("Input must be a two dimensional array.") ;
  }
  

  M = mxGetM(in[I]) ;
  N_test = mxGetN(in[I]) ;
  N_train= mxGetN(in[H]);

  out[J] = mxCreateDoubleMatrix(N_test,N_train,mxREAL) ;
  
  Test_pt   = mxGetPr(in[I]) ;
  Train_pt   = mxGetPr(in[H]) ;
  J_pt   = mxGetPr(out[J]) ;
 
  /* ------------------------------------------------------------------
  **                                                         Do the job
  ** --------------------------------------------------------------- */
  {
  int h; int i; int j;int result;
 
  for (i=0;i<N_test;i++)
	  for (j=0;j<N_train;j++)
	  {
          result=0;
		  for (h=0;h<M;h++)
		  {
			  result=result+min(Test_pt[i*M+h],Train_pt[j*M+h]);
		  }
		  J_pt[j*N_test+i]=result;
	  }

  }
}
