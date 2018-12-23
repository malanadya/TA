%KNN_MAP Map a dataset on a K-NN based classifier
% 
% 	F = knn_map(A,W)
% 
% Maps the dataset A by the K-NN classfier W on the [0,1] interval 
% for each of the classes W is trained on. The posterior 
% probabilities stored in F sum row-wise to one. W should be trained 
% by a classifier like knnc. This routine is called automatically to 
% solve A*W if W is trained by knnc.
%
% Warning: Class prior probabilities in dataset A are neglected.
% 
% See also mappings, datasets, knnc, testk

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function F = knn_map(T,W)
[a,classlist,type,k,c,v,knn] = mapping(W);
[nlab,lablist,m,k,c] = dataset(a);
[mt,kt] = size(T);
if kt ~= k, error('Wrong feature size'); end

r = sum(expandd(nlab,c));
[num,n] = prmem(mt,m);
F = ones(mt,c);
D = ones(mt,c);
for i = 0:num-1
	if i == num-1
		nn = mt - num*n + n;
	else
		nn = n;
	end
	range = [i*n+1:i*n+nn];
	DD = distm(a,T(range,:));
	[DD,L] = sort(DD);     			% sort distances
	
	L = reshape(nlab(L),size(L));	% find labels

	for j = 1:c     				% find label frequencies
		F(range,j) = sum(L(1:knn,:)==j,1)';
	end
	K = max(F(range,:)');
	for j = 1:c
		K = min(K,r(j));
		J = reshape(find(L==j),r(j),nn); % find the distances to the
		J = J(K+[0:nn-1]*r(j));		% objects of that neighbor
		D(range,j) = DD(J)';		% number for all classes
	end
                                    % estimate posterior probabilities
	if knn > 2                          % use Bayes estimators on frequencies
		F(range,:) = (F(range,:)+1)/(knn+c);
	else                                % use distances
		F(range,:) = sigm(log(sum(D(range,:),2)*ones(1,c)./(D(range,:)+realmin) - 1 + realmin));
	end
	F(range,:) = F(range,:) ./ (sum(F(range,:),2)*ones(1,c));
end
F = invsig(F);
[nlab,lablist,m,k,c,p] = dataset(T);
F = dataset(F,getlab(T),classlist,p,lablist);
