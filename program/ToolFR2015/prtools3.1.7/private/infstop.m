%INFSTOP Quinlan's Chi-square test for early stopping
% 
% 	crt = infstop(A,nlabels,j,t)
% 
% Computes the Chi-square test described by Quinlan [1] to be used 
% in maketree for forward pruning (early stopping) using dataset A 
% and its numeric labels. j is the feature used for splitting and t 
% the threshold. 
% 
% See maketree, treec, classt, prune 

% Guido te Brake, TWI/SSOR, TU Delft.
% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function crt = infstop(a,nlab,j,t)
[m,k] = size(a);
c = max(nlab);
aj = a(:,j);
ELAB = expandd(nlab); 
L = sum(ELAB(aj <= t,:),1) + 0.001;
R = sum(ELAB(aj > t,:),1) + 0.001;
LL = (L+R) * sum(L) / m;
RR = (L+R) * sum(R) / m;
crt = sum(((L-LL).^2)./LL + ((R-RR).^2)./RR);
return
