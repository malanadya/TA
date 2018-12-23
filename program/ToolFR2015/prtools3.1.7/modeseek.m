%MODESEEK Clustering by modeseeking
% 
% 	[labels,J] = modeseek(D,k)
% 
% If D is a n*n distance matrix between object then a k-nn 
% modeseeking method is used to assign each object to its nearest 
% mode. The indices in J point to the modal objects. All objects 
% are labeled accordingly, which is returned in labels.
% 
% 	[labels,J] = modeseek(distmap,A,k)
% 
% Instead of D a distance computing untrained mapping (e.g. 
% proxm([],'d',2)) may be supplied for computing the distances between 
% objects in A. This prevents the computation of large distance 
% matrices.
% 
% See also mappings, datasets, kmeans, hclust, kcentres

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [lab,J] = modeseek(dist,a,k)
if isa(dist,'mapping')
	if nargin < 3, k = 10; end
	[m,n] = size(a);
else
	if nargin < 2, k = 10;
	else k = a; end
	[m,n] = size(dist);
	if m ~= n, error('Distance matrix should be square'); end
end

f = zeros(m,1);	    % densities
J = zeros(k,m);     % neighbors

for i = 1:m
	if isa(dist,'mapping')
		%d = feval(dist,a,a(i,:)); d = d(:);
		d = a(i,:) * dist * a;
	else
		d = dist(:,i);
	end
	[dd,j] = sort(d);
	f(i) = 1/dd(k);
	J(:,i) = j(1:k);
end

[e,j] = max(reshape(f(J),size(J)));
N = J(j+[0:k:k*(m-1)]);
M = N(N);
while any(M~=N)
	N = M;
	M = N(N);
end

[lab,J] = renumlab(M');
