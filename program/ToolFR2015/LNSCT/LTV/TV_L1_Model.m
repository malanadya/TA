function [u,v]=TV_L1_Model(F,lambda)
% TV-L1: [u,v]=tvl1_relaxed(F,lambda)
% F: double matrix, the input image to be decomposed
% lambda: the scale parameter


%% Mosek parameter settings
% 定义一个参数列表param，里面包括有参数
% MSK_IPAR_INTPNT_MAX_ITERATIONS: 设置采用内点法的最大迭代次数
% MSK_DPAR_INTPNT_CO_TOL_PFEAS：
% MSK_DPAR_INTPNT_CO_TOL_DFEAS：
% MSK_DPAR_INTPNT_CO_TOL_REL_GAP：
% MSK_DPAR_INTPNT_CO_TOL_MU_RED：
param=[];                    
	
	%-- Enable the line below for default tolerance settings --%
	%mosekparam;     % the default setting file for all programs

	%-- Enable the lines below for specific tolerance settings --%
% 	fprintf(1,'Use customized parameters.\n');
	param.MSK_IPAR_INTPNT_MAX_ITERATIONS=100;
	param.MSK_DPAR_INTPNT_CO_TOL_PFEAS=1.0e-8;
	param.MSK_DPAR_INTPNT_CO_TOL_DFEAS=1.0e-8;
	param.MSK_DPAR_INTPNT_CO_TOL_REL_GAP=1.0e-8;
	param.MSK_DPAR_INTPNT_CO_TOL_MU_RED=1.0e-8;

%% Generate prob for calling Mosek
prob=rlp_TV_L1_Model(F,lambda);

%% Call Mosek
[r,res] = mosekopt('minimize info',prob,param);

%% Parse Mosek's output
mosekoutput(res.info);
	
%% retrieve u v from res.sol.itr.xx
[M,N]=size(F);
v=reshape(res.sol.itr.xx(1:M*N),M,N);
u=F-v;