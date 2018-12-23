%SCALEM Compute scaling map
% 
% 	W = scalem(A)
% 
% W is a map that shifts the origin to the mean of the dataset A.
% 
% 	W = scalem(A,'variance')
% 
% The origin is shifted to the mean of A and the variances of all 
% features is scaled to 1. 
% 
% 	W = scalem(A,'c-variance')
% 
% Instead of the overal variance, now the mean class variance 
% (within-scatter) is normalized.
% 
% 	W = scalem(A,'domain')
% 
% W is a map that sets the domain for all features in the dataset A 
% to (0,1).
%
%	W = scalem(A,'2-sigma')
%
% W is a map that rescales the 2-sigma interval for each feature
% to the [0,1] interval and clips values outside this domain.
% 
% Scaling by variance and mean is weighted by the class 
% probabilities if A is a labeled dataset.
% 
% A map may be applied on a new dataset B by B*W.
% 
% See also mappings, datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = scalem(a,t)
if nargin < 2, t = []; end
% if nargin < 1 | isempty(a)
% 	W = mapping('scalem',t);
% 	return
% end
[nlab,lablist,m,k,c,p] = dataset(a);
if nargin == 1 | isempty(t)
	U = meancov(a);
	s = ones(1,k);
	u = p'*double(U);
	clip = 0;
elseif strcmp(t,'variance')
	U = meancov(a);
	G = zeros(c,k);
	for j = 1:c
		J = find(nlab==j);
		G(j,:) = std(a(J,:),1).^2;
	end
	u = p'*double(U);
	uu = double(U) - repmat(u,c,1);
	G = G + uu.^2;
	s = sqrt(p'*G);
	clip = 0;
elseif strcmp(t,'c-variance')
	U = meancov(a);
	G = zeros(c,k);
	for j = 1:c
		J = find(nlab==j);
		G(j,:) = std(+a(J,:),1).^2;
	end
	u = p'*double(U);
	s = sqrt(p'*G);
	clip = 0;
elseif strcmp(t,'domain')
	mx = max(a,[],1)+eps; mn = min(a,[],1)-eps;
	u = mn; s = (mx - mn)*(1+eps);
	clip = 0;
elseif strcmp(t,'2-sigma')
	U = meancov(a);
	G = zeros(c,k);
	for j = 1:c
		J = find(nlab==j);
		G(j,:) = std(a(J,:),1).^2;
	end
	u = p'*double(U);
	uu = double(U) - repmat(u,c,1);
	G = G + uu.^2;
	s = 4*sqrt(p'*G);
	u = u-0.5*s;
	clip = 1;
elseif strcmp(t,'clip')
	s = ones(1,k); u = zeros(1,k); clip = 1;
else
	error('Unknown option')
end
J = find(s==0);
s(J) = realmin*ones(size(J));
ss = 1./s;
W = mapping('normalize',{u,ss,clip},getfeat(a),k,k);
return
