%DISTMAHA Mahalanobis distance
% 
% 	D = distmaha(A,U,G)
% 
% Computation of the Mahanalobis distances of all vectors in the 
% dataset A to a dataset of points U, using the covariance matrix G. 
% G should be either a 2-dimensional square matrix of the right size 
% or a 3-dimensional matrix containing a covariance matrix for each 
% point in U. If A contains m vectors and U n vectors, the size of D 
% is m*n.
% 
% 	D = distmaha(A)
% 
% Estimation of the Mahalanobis distance matrix between all classes 
% in the set of data vectors in A defined by labels.
% 
% See also datasets


% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function D = distmaha(X,U,G);
[nlab,lablist,m,k,c,p] = dataset(X);

if nargin == 1     % distance matrix between data classes
	U = zeros(c,k);
	for i = 1:c
		J = find(nlab == i);
		U(i,:) = mean(X(J,:));
		X(J,:) = X(J,:) - ones(length(J),1)*U(i,:);
	end 
	[E,V] = eig(covm(X));
	U = U*E*sqrt(inv(V));
	D = distm(U);
elseif nargin == 2
	D = distm(U,X);
elseif nargin == 3     % distance between data and distribution
	[k1,k2,cg] = size(G);
	[cu,k3] = size(U);
	if isa(U,'dataset')
		labels = getlab(U);
	else
		labels = [1:cu]';
	end
	if any([k1,k2,k3] ~= k) | (cu ~= cg & cg ~= 1)
		error('Data size do not match')
	end	
	D = zeros(m,cu);
	if cg == 1, F = inv(G); end
	for j=1:cu
		if cg ~=1, F = inv(G(:,:,j)); end
		D(:,j) = sum((X-repmat(+U(j,:),m,1))'.*(F*(X-repmat(+U(j,:),m,1))'),1)';
	end
        D = dataset(D,getlab(X),labels,p,lablist);
else
	error('Wrong number of arguments')
end

