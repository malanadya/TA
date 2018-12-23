%FISHERM Optimal discrimination mapping (Fisher mapping)
%
%       W = fisherm(A,n)
%
% Finds a mapping of the labeled dataset A to a n-dimensional
% linear subspace such that it maximizes the the between scatter
% over the within scatter (also called Fisher mapping).
%
% See also datasets, mappings, nlfisherm, klm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = fisherm(a,n)
if nargin == 1,  n = []; end
if nargin == 0 | isempty(a)
	W = mapping('fisherm',n);
	return
end
[nlab,lablist,m,k,c,p,featlist,imheight] = dataset(a);
a = a*scalem(a); % set mean to origin
if isempty(n), n = min(k,c)-1; end
if n >= m | n >= c
	error('Dataset too small or or has too few classes for demanded output dimensionality')
end
w = klms(a);
a = a*w;
v = pca(meancov(a),n);
if n == 0
	W = v;
else
	W = w*v;
	W = set(W,'p',imheight);
end
return
