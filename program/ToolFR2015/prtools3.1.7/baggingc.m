%BAGGINGC Bootstrapping and aggregation of classifiers
% 
%    W = baggingc(A,classf,n,cclassf,T)
% 
% Computation of a stabilized version of a classifier by 
% bootstrapping and aggregation ('bagging'). In total n bootstrap 
% versions of the dataset A are generated and used for training of 
% the untrained classifier classf. Aggregation is done using the 
% combining classifier specified in cclassf. If cclassf is a 
% trainable classifier it is trained by the dataset T, if given,
% else A is used for training. Default classifier combiner cclassf
% is meanc. Default input classifier classf is nmc.
%
% Note that the classifier combiner meanc averages the coefficients
% of the affine linear input classifiers, e.g. W = baggingc(A,nmc);
% This can be avoided by W = baggingc(A,nmc*classc) for averaging 
% posterior probability outputs. 
% 
% See also mappings, datasets, nmc, meanc, boostingc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = baggingc(a,clasf,n,rule,t);
if nargin < 5, t = []; end
if nargin < 4, rule = meanc; end
if nargin < 3, n = 100; end
if nargin < 2, clasf = nmc; end
if nargin < 1 | isempty(a)
	w = mapping('baggingc',{clasf,n,rule});
	return
end
[nlab,lablist,m,k,cc] = dataset(a);

w = [];
for i = 1:n
	w = [w gendat(a)*clasf]; 
end
if isempty(rule)
	return
end
if isempty(t)
	w = traincc(a,w,rule);
else
	w = traincc(t,w,rule);
end
return
