%PFSVC Pseudo-Fisher Support Vector  Classifier
% 
%    W = pfsvc(A,S,type,p)
% 
% Computes a (pseudo)Fisher classifier for a given support set S.
% The kernel can be of one of the types as defined by proxm.
% Default is Euclidean distances. Default S = A.
% 
% See also mappings, datasets, svc, proxm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = pfsvc(a,s,type,p)
if nargin < 4, p = 1; end
if nargin < 3, type = 'd'; end
if nargin < 2, s = []; end
if nargin < 1 | isempty(a)
	w = mapping('pfsvc',{s,type,p});
	return
end
[nlab,lablist,m,k,c] = dataset(a);
if isempty(s)
	v = proxm(a,type,p);
else
	v = proxm(s,type,p);
end
w = v*fisherc(a*v);
return
