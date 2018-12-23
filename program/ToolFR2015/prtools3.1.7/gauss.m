%GAUSS Generation of multivariate Gaussian dataset.
% 
% 	A = gauss(n,U,G)
% 
% Generation of n k-dimensional Gaussian distributed vectors with 
% covariance matrices G (size k*k*c) and with means, labels and 
% prior probabilities defined by the dataset U with size (c*k). 
% Alternatively n can be a vector with length c.
% 
% Default:	G      : eye(k)
% 		U      : zeros(1,k)
% 
% See also datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function X = gauss(n,U,G);
nc = length(n);
if nargin < 2
	U = zeros(1,nc);
end
if nargin < 3
	G = eye(nc);
end
[nlab,lablist,m,k,c,p] = dataset(U);
if c~=m
	U = dataset(U,[1:m]');
	[nlab,lablist,m,k,c,p] = dataset(U);
end
if nc == 1 & c > 1
	n = p.*ones(c,1)*n; 
	if ~isint(n)
		error('Number of requested vectors not possible')
	end
else
	if nc ~= c
		error('Vector with class sizes does not match mean matrix')
	end
end
if nargin < 3 | isempty(G)
	G = eye(k);
end
[k1,k2,cg] = size(G);
if k1 ~= k | k2 ~= k | (cg ~= c & cg ~= 1)
	error('Covariance matrix has wrong size')
end

u = double(U);
if c == 1
	[V D] = eig(+G(:,:,1));
	V = real(V);
	D = real(D);
	X = randn(n,k)*sqrt(D)*V' + ones(n,1) * u;
	labels = ones(n,1)*lablist;
else
	X = [];
	labels = [];
	for i = 1:c
		j = min(i,cg);
		[V D] = eig(+G(:,:,j));
		V = real(V);
		D = real(D);
		X = [X; randn(n(i),k)*sqrt(D)*V' + ones(n(i),1)*u(i,:)];
		labs = ones(n(i),1)*lablist(nlab(i),:);
		if i == 1
			labels = labs;
		else
			labels = abs(str2mat(labels,labs));
		end
	end
end
% cast the labels back to char if necessary (DXD 27-8-2001):
if isa(lablist,'char')
  labels = char(labels);
end
X = dataset(X,labels,[],p,lablist);
return
