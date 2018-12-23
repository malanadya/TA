function nvar=EstimateNoiseVariance(Y,k,lamda)
% estimate the noise variance of imput image
% Y: the coefficient of NSCT
% k: using k-th subband of the 1 st level to estimate
% lamda: a parameter to control
%%
if ~exist('lamda', 'var')
    lamda = 0.6745;
end
n=size(Y,2);
subband=Y{n}{k};
nvar=median(abs(subband(:)))/lamda;
nvar=nvar^2;