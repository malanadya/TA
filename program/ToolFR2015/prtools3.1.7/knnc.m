%KNNC K-Nearest Neighbor Classifier
% 
% 	[W,k,e] = knnc(A,k)
% 
% Computation of the k-nearest neigbor classifier for the dataset A. 
% Default k: optimize leave-one-out error e. W is a mapping and
% will be converted to a classifier by W*classc. 
% Warning: class prior probabilities in A are neglected.
% 
% See also mappings, datasets, knn_map

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [W,knn,e,ek] = knnc(a,knn)
if nargin == 0, W = mapping('knnc'); return; end
% if isempty(a), W = mapping('knnc',knn); return; end
[nlab,lablist,m,k,c] = dataset(a);
if nargin < 2
	knn = [];
end
if isempty(knn)
	[num,bat] = prmem(m,m);
	z = zeros(1,m);
	N = zeros(c,m);
	for i = 0:num-1
		if i == num-1
			nn = m - num*bat + bat;
		else
			nn = bat;
		end
		I = [i*bat+1:i*bat+nn];
		D=+distm(a,a(I,:));
		[Y,L] = sort(D);
		L = nlab(L)';
		Ymax = zeros(nn,m);
		Yc = zeros(nn,m);
		for j = 1:c
			Y = (L == j);
			for n = 3:m
				Y(:,n) = Y(:,n-1) + Y(:,n);
			end
			Y(:,1) = zeros(nn,1);
			J = Y > Ymax;
			Ymax(J) = Y(J);
			Yc(J) = j*ones(size(Yc(J)));
		end
		z = z + sum(Yc == nlab(I)*ones(1,m),1);
	end
	[e,knn]=max(z);
	knn=knn-1;
	e = 1 - e/m;
	ek = 1 - z/m;
	ek(1) = []; 
else
	e = testk(a,knn);
end
W = mapping('knn_map',a,lablist,k,c,1,knn);
return

