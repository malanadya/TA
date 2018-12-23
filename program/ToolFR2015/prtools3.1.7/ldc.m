%LDC Linear Discriminant Classifier
% 
% 	W = ldc(A,r,s)
% 
% Computation of a linear discriminant between the classes of the 
% dataset A assuming normal densities with equal covariance 
% matrices. The joint covariance matrix is the weighted (by apriori 
% probabilities) average of the class covariance matrices.
% 
% r and s (0 <= r,s <=1) are regularization parameters used for 
% finding the covariance matrix by 
% 	G = inv((1-r-s)*G+r*diag(diag(G)))+
% 		s*mean(diag(G))*eye(size(G,1))
% So,	r = 0 : (default) no regularization
% 	r = 1 : don't use data
% 
% Default: r = 0, s= 0.
%
% The classification A*W is computed by normal_map. See there for details.
% 
% See also mappings, datasets, nmc, fisherc, qdc, uqc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = ldc(a,r,s)
if nargin < 3, s = 0; end
if nargin < 2, r = 0; end
if nargin < 1 | isempty(a)
	W = mapping('ldc',{r,s});
	return
end
[nlab,lablist,m,k,c,p,fl,imheight] = dataset(a);
if min(sum(expandd(nlab,c),1)) < 2
        error('Classes should contain more than one vector')
end

[U,G] = meancov(a);
G = reshape(sum(reshape(G,k*k,c)*p,2),k,k);
G = (1-r-s)*G + r * diag(diag(G)) + s*mean(diag(G))*eye(size(G,1));
W = mapping('normal_map',{U,G,p},getlab(U),k,c,1);
return

