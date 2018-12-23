%EDICON Edit and condense training set into support set
% 
% 	J = edicon(D)
% 
% Condensing: If D is the distance dataset then the indices J refer 
% to a minimized set that classifies the original set similarly 
% (leave-one-out for the training / support set) by the 1-NN rule.
% 
% 	J = edicon(D,k,n)
% 
% Before the above condensing the set is edited first by deleting 
% all objects that don't have n neighbours of their own class within 
% their k nearest neighbors.
%
% D can be computed from a dataset A by A*proxm(A).
% 
% See also datasets, knnc, proxm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function J = edicon(D,num1,num2)
[nlab,lablist,m,k,c,p] = dataset(D);
if m ~= k, error('Distance matrix should be square'); end

exact = 0;
if nargin > 1
	if num1 == 0, exact = 1; end
end

if ~exact
	D = D + diag(inf*ones(1,m));
end
				% find all nearest neigbors
[E,K] = sort(D);
R = zeros(1,m);
R(K(1,:)) = ones(1,m);
				% editting
if nargin > 2 & ~exact
	if nargin == 3
		num2 = 1;
	end
	L = reshape(nlab(K),m,m) == nlab(:,ones(1,m))';
	if num1 == 1
		J = L(1,:);
	else
				% find objects that have at least num2 neigbours
				% of their class within the k nearest ones.
		J = sum(L(1:num1,:)) >= num2;
	end
else
	J = ones(1,m);
end
n = inf;
				% start condensing by anding these sets
J = find(R&J);
JJ = find(~R);
for j = JJ
	K(find(K == j)) = []; 
	K = reshape(K,length(K)/m,m);
end
while length(J) < n
	n = length(J);
	JJ = J(randperm(n));
				% delete all objects where the next 
				% neighbor has the same label
	for j = JJ
		N = find(K(1,:) == j);
		nn = N(find(nlab(K(1,N)) ~= nlab(K(2,N))));
		if isempty(nn)
			J(find(J==j)) = [];
			I = find(K == j);
			K(I) = [];
			K = reshape(K,length(K)/m,m);
		end
	end
end

