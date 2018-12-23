%CLASSS Linear mapping by classical scaling
% 
% 	W = classs(D,k)
% 
% Calculates a linear mapping W of a distance matrix D to k dimensions.
% D should be square, size m x m. New objects may be mapped by
% E*W in which E is a n x m distance matrix to the original set of
% m objects. Default k = 2.
% 
% See also: mappings, datasets, mds

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W =classs (D,n)
if nargin < 2, n = 2; end
if nargin < 1 | isempty(D)
	W = mapping('classs',n);
	return
end
[nlab,lablist,m,k,c,prob] = dataset(D);
if m~=k, error('Distance matrix should be square'); end

J = eye(m) - ones (m,m) ./m;
B = - 0.5 .* J * ((+D).^2) * J;
[V,S,U] = svds (B, n);
V = V .* repmat(sign(V(1,:)),m,1); % takes care of reproducability
A = V * sqrt(S);

if rank(+D) < m,
  W = pinv(D)*A;
else
  W = D \ A;
end

W = mapping('mds',W,[],m,n,1);
return


