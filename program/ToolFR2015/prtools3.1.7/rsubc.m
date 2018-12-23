%RSUBC Random Subspace Classifier
%
%    W = rsubc(A,classf,r,n,cclassf,T)
% 
% Computation of a combined classifier by selecting n random subsets
% of r features. For each of these subsets the base classifier classf
% is trained. Classifiers are combined by cclassf. If cclassf is a 
% trainable classifier it is trained by the dataset T, if given,
% else A is used for training. Default classifier combiner cclassf
% is meanc. Default base classifier classf is nmc.
%
% If n = [], or n = 0 random feature sets of size r are rotated,
% in which case all features are selected once and never twice.
%
% Note that the classifier combiner meanc averages the coefficients
% of the affine linear input classifiers, e.g. W = rsubc(A,nmc);
% This can be avoided by W = baggingc(A,nmc*classc) for averaging 
% posterior probability outputs. 
%
% Deafults: classf = nmc, r = 2, n = [], cclassf = meanc, T = [];
% 
% See also mappings, datasets, baggingc, boostingc

% Copyright: M.Skurichina, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = rsubc(a,clasf,r,n,rule,t);
if nargin < 6, t = []; end
if nargin < 5, rule = meanc; end
if nargin < 4, n = 0; end
if nargin < 3, r = 2; end
if nargin < 2, clasf = nmc; end
if nargin < 1 | isempty(a)
	w = mapping('randsubc',{clasf,r,n,rule,t});
	return
end
[nlab,lablist,m,k,cc] = dataset(a);

w = [];

if n == 0 | isempty(n)
	K = randperm(k);
	n = ceil(k/r);
else
	K = [];
end

v = zeros(k+1,1);
vv = [];
for i = 1:n
	if isempty(K)
		R = randperm(k);
		R = R(1:r);
	else
		R = K((i-1)*r+1:min(i*r,k));
	end
	ww = a(:,R)*clasf;
	if ~isclassifier(ww) & strcmp(getmap(ww),'affine') ...
			& strcmp(getmap(rule),'meanc') & cc == 2
		vv = +ww/n;
		v(R) = v(R) + vv(1:end-1);
		v(end) = v(end) + vv(end);
	else
		w = [w cmapm(k,R)*(a(:,R)*clasf)];
	end
end
if isempty(t) & isempty(vv)
	w = traincc(a,w,rule);
elseif isempty(vv)
	w = traincc(t,w,rule);
else
	w = mapping('affine',v,lablist,k,1,1,getimheight(a));
end
return

