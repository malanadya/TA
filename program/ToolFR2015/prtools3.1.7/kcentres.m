%KCENTRES Find k centres objects from distance matrix
% 
% 	[labels,J,dmin] = kcentres(D,k,n)
% 
% If D is a square distance matrix between m objects then J is the 
% set of centre points, i.e. the subset of k objects that minimizes 
% max(dmin), the maximum of the distances over all objects to the 
% nearest median point. For k > 1 the results depend on a random 
% initialisation. The procedure is repeated n times and the best 
% result is returned. In labels a set of m object labels is stored 
% in which for each object the nearest of the centre points is 
% returned. 
% 
% 	J = kcentres(D)
% 	J = kcentres(D,1)
% 
% In case k = 1 just the centre point is returned.
% 
% Default: k = 1, n = 1.
% 
% See also hclust, kmeans, modeseek

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands


function [labels,Jopt,dm] = kcentres(d,k,n);
if nargin < 3, n = 1; end
if nargin < 2, k = 1; end
[m,m] = size(d);
if k == 1
	dmax = max(d);
	[dm,labels] = min(dmax);
	return
end
dopt = inf;
for tri = 1:n
M = randperm(m); M = M(1:k);
J = zeros(1,k);
while 1
	[dm,I] = min(d(M,:));
	for i = 1:k
		JJ = find(I==i);
		if isempty(JJ)
			J(i) = 0;
		else
			j = kcentres(d(JJ,JJ));
			J(i) = JJ(j);
		end
	end
	Jnul = find(J==0);
	J(Jnul) = [];
	k = length(J);
	if length(M) == length(J) & all(M == J)
		[dmin,labs] = min(d(J,:));
		dmin = max(dmin);
		break;
	end
	M = J;
end
if dmin < dopt
	dopt = dmin;
	labels = labs';
	Jopt = J;
end
end
dm = zeros(1,k);
for i=1:k
	L = find(labels==i);
	dm(i) = max(d(Jopt(i),L));
end
