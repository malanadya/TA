%TESTK Error estimation of K-NN rule
% 
% 	e = testk(A,k,T)
% 
% Tests a dataset T on the training dataset A using the k-NN rule 
% and returns the classification error e. In case no testset T is 
% given the leave-one-out error on A is returned. Default k = 1.
% 
% The advantages of the use of testk over testd are that it is 
% faster and that it enables the leave-one-out error estimation.
% 
% See also datasets, knnc, knn_map, testd 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function e = testk(a,knn,t)
if nargin == 1, [W,knn] = knnc(a); end
[nlab,lablist,m,k,c] = dataset(a);
if nargin <= 2
	d = classk(a,nlab,knn); % why not knn_map??
	[dmax,J] = max(d',[],1);
	e = nstrcmp(J',nlab) / m;
else
	[nlabt,lablistt,n,kt] = dataset(t);
	if k ~= kt 
		error('Data sizes do not match');
	end
	d = classk(a,nlab,knn,t); [dmax,J] = max(d',[],1); % why not knn_map??
	e = nstrcmp(getlab(t),lablist(J,:)) / n;
end
return

function F = classk(a,nlab,knn,t)
[m,k] = size(a);
if nargin < 4
	mt = m;
else
   [mt,kt] = size(t);
end
if knn > m
	error('Training set too small for requested number of neighbours');
end
c = max(nlab);
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
	if nargin <= 3
		DD = +distm(a,a(range,:));
		DD(i*n+1:m+1:i*n+nn*m) = inf*ones(1,nn); % set distances to itself at inf
	else
		DD = +distm(a,t(range,:));
	end
	[DD,L] = sort(DD);     			% sort distances
	
	L = reshape(nlab(L),size(L));		% find labels

	for j = 1:c     				% find label frequencies
		F(range,j) = sum(L(1:knn,:)==j,1)';
	end
	K = max(F(range,:)',[],1);
	for j = 1:c
		J = reshape(find(L==j),r(j),nn); % find the distances to the
		J = J(K+[0:nn-1]*r(j));		% objects of that neighbor
		D(range,j) = DD(J)';		% number for all classes
	end
end
                                    % estimate posterior probabilities
if knn > 2                          % use Bayes estimators on frequencies
	F = (F+1)/(knn+c);
else                                % use distance 
   F = sigm(log((sum(D,2)+realmin)*ones(1,c)./(D+realmin) - 1 + realmin));
end
F = F ./ (sum(F,2)*ones(1,c));
