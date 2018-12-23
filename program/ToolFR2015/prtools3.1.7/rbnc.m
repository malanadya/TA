%RBNC Radial basis neural net classifier
% 
% 	W = rbnc(A,n)
% 
% A feedforward neural network classifier with one hidden layer with 
% at most n radial basis units is computed for the labeled dataset 
% A.
% 
% See also datasets, mappings, neurc, bpxnc, lmnc

% This routine calls MATHWORK's solverb routine (NN toolbox) as solvb

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = rbnc(a,n)
[nlab,lablist,m,k,c] = dataset(a);
if nargin < 2 | isempty(n), n = 100; end
				% set targets
T = 0.1*ones(c,c) + 0.8 * eye(c);
T = T(nlab,:)';
				% scale
WP = scalem(a,'variance');
				% compute rbf network
hold off
r = randn(m,k) * 1e-10; % add noise because solvb has sometimes
						% problems with identical inputs
[W1,B1,W2,B2,n,r] = solvb(+(a*WP)'+r',T,[inf n m*0.05 0.5]);
hu = length(B1);
				% compute resulting map
WP = WP*proxm(W1,'d',2);
WP = WP*cmapm(B1'.^2,'scale');
WP = WP*cmapm(hu,'nexp');
w = [W2,B2]';
W = WP*mapping('affine',w,lablist,hu,c,1);
%WT = packd(w(:),[1,hu,c,1],lablist);
%W = classc(WP,WT);
return

