%FEATSELM Feature selection map
% 
% 	W = featselm(A,crit,method,k,T)
% 
% Computation of a mapping W selecting k features.
% 	A		- dataset used for training
% 	crit		- criterion, 'maha', 'NN', 'nerr', 'perr'
% 			(see feateval) or an untrained classifier V.
% 			default 'NN'
% 	method		- 'forward' : selection by featself (default)
% 			- 'float'   : selection by featselp
% 			- 'backward': selection by featselb
% 			- 'b&b'     : branch and bound selection by
% 			              featselo
% 			- 'ind'     : individual
% 	k		- desired number of features.
% 			  k=0 selects the optimal set (default).
% 	T		- testset to be used in feateval.
% 
% W can be used for selecting features by B*W
% 
% See also mappings, datasets, feateval, featself, featselp, 
% featselb, featselo, featseli

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = featselm(a,crit,method,k,t)
if nargin < 2, crit = 'NN'; end
if nargin < 3, method = 'forward'; end
if nargin < 4, k = 0; end
if nargin < 5, t = []; end
if nargin == 0 | isempty(a)
	W = mapping('featselm',{crit,method,k,t});
	return
end

[m,kk] = size(a);

if strcmp(method,'forward')
	W = featself(a,crit,k,t);
elseif strcmp(method,'float')
	W = featselp(a,crit,k,t);
elseif strcmp(method,'backward')
	W = featselb(a,crit,k,t);
elseif strcmp(method,'b&b')
	W = featselo(a,crit,k,t);
elseif strcmp(method,'ind')
	W = featseli(a,crit,k,t);
else
	error('Method unknown')
end
return

 
	  
