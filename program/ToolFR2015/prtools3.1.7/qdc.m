%QDC Quadratic Bayes Normal Classifier
%
% 	W = qdc(A,r,s)
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
% The classification A*W is computed by normal_map. See there for details.
% 
% See also datasets, mappings, nmc, nmsc, ldc, udc, quadrc, normal_map

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = qdc(a,r,s)
if nargin < 3, s = 0; end
if nargin < 2, r = 0; end
if nargin < 1 | isempty(a)
	W = mapping('qdc',{r,s});
	return
end

[nlab,lablist,m,k,c,p] = dataset(a);
if min(sum(expandd(nlab,c),1)) < 2
	error('Classes should contain more than one vector')
end

[U,G] = meancov(a);
GG = [];
for j = 1:c
	F = G(:,:,j);
	F = (1-r-s) * F + r * diag(diag(F)) +s*mean(diag(F))*eye(size(F,1));
	GG(:,:,j) = F;
end
W = mapping('normal_map',{U,GG,p},getlab(U),k,c,1,[]);
return
