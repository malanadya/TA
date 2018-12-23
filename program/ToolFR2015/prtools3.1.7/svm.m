%SVM Support vector mapping, kernel PCA
% 
% 	W = svm(A,type,p,n);
% 
% Computes support vector mapping W from the data vectors in A 
% depending on the value of type:
% 	'p': polynomial on inner products with degree p
% 	'e': exponential, scaled by p
% 	'r': Gaussian radial_basis functions with given stand. dev. p
% 	's': sigmoid functions on inner products with given scaling p
% 	'd': Euclidean distance ^ p
% 
% If n is given, the mapping is afterwards reduced to n dimensions 
% by a Karhunen-Loeve reduction (kernel PCA). New objects B can be 
% mapped by B*W, W*B or by A*svm([],...)*B.
% 
% Defaults: type = 'd', p = 1.
% 
% See also datasets, mapppings, proxm, klm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = svm(a,type,p,n);
if nargin < 4; n = []; end
if nargin < 3; p = 1; end
if nargin < 2; type = 'd'; end
if nargin < 1 | isempty(a)
	w = mapping('svm',{type,p,n});
	return
end
[m,k] = size(a);

if strcmp(type,'s') | strcmp(type,'p')
	u = mean(a,1);
	aa = a - ones(m,1)*u;
else
	aa = a;
	u = [];
end
w = mapping('support-vector',{u,aa},getlab(a),k,m,1,{type,p});
if ~isempty(n)
	w = w*klms(a*w,n);
end
return
