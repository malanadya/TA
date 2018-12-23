%QUADRC Quadratic Discriminant Classifier
% 
% 	W = quadrc(A,r,s)
% 
% Computation of the quadratic classifier between the classes of the 
% dataset A assuming normal densities. r and s (0 <= r,s <=1) are 
% regularization parameters used for finding the  covariance matrix 
% by 
% 
% 	G = (1-r-s)*G + r*diag(diag(G)) +
% 				s*mean(diag(G))*eye(size(G,1))
% 
% Default: r = 0, s= 0.
%
% This routine differs from qdc by that it is not based on densities,
% but just computes a quadratic classifier based on the class covariances.
% The multi-class problem is solved by a multiple two-class quadratic
% discrimiant.
% 
% See also datasets, mappings, nmc, nmsc, ldc, udc, qdc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = quadrc(a,r,s)
if nargin < 3, s = 0; end
if nargin < 2, r = 0; end
if nargin < 1 | isempty(a)
	W = mapping('quadrc',{r,s});
	return
end
[nlab,lablist,m,k,c,p] = dataset(a);
if min(sum(expandd(nlab,c),1)) < 2
	error('Classes should contain more than one vector')
end
if c == 2
	pa = p(1); pb = p(2);
	JA = find(nlab==1); JB = find(nlab==2);
	ma = mean(a(JA,:)); mb = mean(a(JB,:));
	GA = covm(a(JA,:));  GB = covm(a(JB,:));
	GA = inv((1-r-s) * GA + r * diag(diag(GA)) + s*mean(diag(GA))*eye(size(GA,1)));
	GB = inv((1-r-s) * GB + r * diag(diag(GB)) + s*mean(diag(GB))*eye(size(GB,1)));
	w2 = GB - GA;
	w1 = 2*ma*GA-2*mb*GB;
	w0 = (mb*GB*mb'-ma*GA*ma') + 2*log(pa/pb) + log(det(GA)/det(GB));
   W = mapping('quadratic',{w0,w1',w2},lablist,k,1);
   W = cnormc(W,a);
else
	W = mclassc(a,mapping('quadrc',{r,s}));
end
return
