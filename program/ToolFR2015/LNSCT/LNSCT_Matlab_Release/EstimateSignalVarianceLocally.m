function Yvar= EstimateSignalVarianceLocally(Y,m)
% this function is to compute the variance of signal locally using the
% neighboring coefficients contained in a square window
% input: 
% Y: input signal coefficient matrix
% m: the size of local window (m by m)
% output: 
% Yvar: variance of signal (matrix)
%%
if ~exist('m', 'var')
    m = 5;
end;
Yvar=zeros(size(Y));
K=floor(m/2);
squarem=m^2;

for k1=-K:K                             
    for k2=-K:K
        B=circshift(Y,[k1,k2]);
        Yvar=Yvar+(B.^2)/squarem;
    end
end
