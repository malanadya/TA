
function J = edicon2(D,num1,num2)
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