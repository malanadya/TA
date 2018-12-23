%KNNM Estimate K-Nearest Neighbour densities
%
%	W = KNNM(A,KNN)
%
%	D = B*W
%
% For each of the classes in the dataset A a NN density
% is estimated. The result is stored as a K*C mapping in W, in which
% K is the dimensionality of the input space and C is the number
% of classes. The desired numbur of neighbours should be stored in
% the KNN.
%
% The mapping W may be applied to a new K-dimensional dataset B,
% resulting in a C-dimensional dataset D. The values in D are not
% properly scaled.
%
% See also datasets, mappings, normalm, parzenc

function w = knnm(a,knn)
if nargin < 2, knn = 1; end
if nargin < 1 | isempty(a)
	w = mapping(mfilename,knn);
	return
end
if ~isa(knn,'mapping')
	[nlab,lablist,m,k,c,p] = dataset(a);
	w = mapping(mfilename,a,lablist,k,c,1,knn);
else 
	w = knn_map(a,knn);
end

function F = knn_map(b,w)
[a,classlist,type,k,c,v,knn] = mapping(w);
[nlab,lablist,m,k,cb,p] = dataset(b);
F = zeros(m,c);
for j=1:c
	aa = seldat(a,j);
	d = sqrt(distm(+b,+aa));
	[s,J] = sort(d,2);
	F(:,j) = knn./(s(:,knn).^k); % to be normalized
end

F = dataset(F,getlab(b),classlist,p,lablist);
return
