%FEATSELO Branch and bound feature selection
% 
% 	W = featselo(A,crit,k,T)
% 
% Backward selection of k features by baktracking using the branch 
% and bound procedure on the data set A. crit sets the criterion 
% used by the feature evaluation routine feateval. If the data set T 
% is given, it is used as test set for feateval. For k=0 the optimal 
% feature set (maximum value of feateval) is returned. The result W 
% can be used for selecting features by B*W. 
% 
% This procedure finds the optimum feature set if a monotoneous 
% criterion is used. The use of a testset does not guarantee that.
% 
% Defaults: crit='NN', k=2.
% 
% See also mappings, datasets, feateval, featselm, featself, 
% featselb, featselp, featseli

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = featself(A,crit,kmin,T)
if nargin < 2, crit = 'NN'; end
if nargin < 3, kmin = 2; end
if nargin < 4, T = []; end

if nargin == 0 | isempty(A)
	W = mapping('featselo',{crit,kmin,T});
    return
end

[nlaba,lablist,m,k,c,prob,featlist] = dataset(A);

if ~isempty(T)
	[mt,kt] = size(T);
	if kt ~= k
		error('Data sizes do not match')
	end
end

feat = zeros(1,k);

if isempty(T)
	for j=1:k
		feat(j) = feateval(A(:,j),crit);
	end
else
	for j=1:k
		feat(j) = feateval(A(:,j),crit,T(:,j));
	end
end

[F,S] = sort(feat);
Iopt = [k-kmin+1:k];

I = [1:k];
J = [zeros(1,kmin),1:(k-kmin-1),k-kmin+1,k+1];
level = k;

if ~isempty(T)
	bound = feateval(A(:,S(Iopt)),crit,T(:,S(Iopt)));
else
	bound = feateval(A(:,S(Iopt)),crit);
end

C = inf;
	
while length(I) > 0 & J(k+1) == k+1;
if J(level) == J(level+1) | level <= kmin | C <= bound
	J(level) = level - kmin;
	level = level + 1;
	I = sort([I,J(level)]);
	J(level) = J(level) + 1;
	C = inf;
else
	I(J(level)) = [];
	level = level - 1;
	if J(level+1) < 3 & level == kmin+1 & 0
		;
	else
		if ~isempty(T)
			C = feateval(A(:,S(I)),crit,T(:,S(I)));
		else
			C = feateval(A(:,S(I)),crit);
		end
		if level == kmin & C > bound
			bound = C;
			Iopt = I;
		end
	end
end
end

W = mapping('featsel',S(Iopt),featlist(S(Iopt),:),k,length(Iopt));
return

