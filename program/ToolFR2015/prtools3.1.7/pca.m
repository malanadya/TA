%PCA Principal Component Analysis
%
% 	[W,alf] = pca(A,n)
% 	[W,n] = pca(A,alf)
%
% A principal component analysis is performed on the joint 
% covarianve matrix of the data in A. If A is a labeled dataset the
% class contributions are weighted according to their posterior
% probabilities.
% The routine finds a rotation of the dataset A to a n-dimensional
% linear subspace such that at least a fraction alf of the total
% variance is preserved.
% If n is given (n>=1), alf is maximized. If alf is given (alf<1) 
% n is minimized. If n < 0 an abs(n)-dimensional subspace is found
% that minimizes the preserved variance. If alf<0 (abs(alf<1)) the
% maximum n is found for which the preserved variance <= abs(alf).
% New objects B can be mapped by B*W, W*B or by A*klm([],n)*B.
% Default: the features are decorrelated and ordered, but no
% feature reduction is made.
%
% 	v = pca(A,0)
% 
% Returns the cummulative fraction of the explained variance. v(n) 
% is the cummulative fraction of the explained variance by using n 
% eigenvectors.
%
% Use klm for a pca of the mean class covariance matrix.
% Use fisherm for optimizing the linear class separability (LDA).
%
% See also mappings, datasets, kljlc, klclc, klm, fisherm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W,q] = pca(a,alf)
if nargin < 2 | isempty(alf), alf = inf; end
% if nargin < 1 | isempty(a)
%    W = mapping('pca',alf); return
% end
[nlab,lablist,m,k,c,p,fl,imheight] = dataset(a);
a = a*scalem(a); % set mean to origin
a = a/max(abs(a(:))); % occasionally necessary to prevent inf's in cov
if m <= k
	u = reducm(a);
	a = a*u;
	korg = k;
	[m,k] = size(a);
else
	u = [];
end

[U,GG] = meancov(a,1); G = zeros(k,k);
for i = 1:c
	G = G + p(i)*GG(:,:,i);
end
G = m*(G + cov(+U,1))/(m-1);
[F V] = eig(G);
[v,I] = sort(-diag(V));
if alf == inf
	n = k;
	q = k;
elseif alf >= 1
	n = alf;
	if n > k
		error('Illegal dimensionality requested');
	end
	q = sum(v(1:n))/sum(v);
	I = I(1:n);
elseif alf > 0
	vv = v'*triu(ones(k,k)) / sum(v) - alf;
	J = find(vv > 0);
	n = J(1); q = n;
	I = I(1:n);
elseif alf == 0
	W = ones(1,k);
	w = v'*triu(ones(k,k)) / sum(v);
	W(1:length(w)) = w;
	return
elseif alf > -1
	alf = abs(alf);
	v = flipud(v); I = flipud(I);
	vv = v'*triu(ones(k,k)) / sum(v) - alf;
	J = find(vv > 0);
	n = J(1)-1; q = n;
	I = I(1:n);
else
	n = abs(alf);
	v = flipud(v); I = flipud(I);
	if n > k
		error('Illegal dimensionality requested');
	end
	q = sum(v(1:n));
	sv = sum(v);
	if sv ~= 0, q = q/sv; end
	I = I(1:n);
end
if ~isempty(u)
	R = double(u)*F(:,I);
	k = korg;
else
	R = [F(:,I); -mean(a*F(:,I))];
end
W = mapping('affine',R,[],k,n,1,imheight);
