%DISTM Distance matrix between two datasets.
% 
% 	D = distm(A,B)
% 
% Computation of the distance matrix D between two datasets A and B. 
% Distances are computed as squared Euclidean. If A has m objects 
% and B has n objects then D has size m*n.
% 
% 	D = distm(A)
% 
% Computes the symmetric distance matrix between all objects in A.
% 
% distm(A,B) is equivalent with double(proxm(A,B,'d',2)).
% 
% See also datasets, proxm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function D = distm(A,B)
[ma,ka] = size(A);
global PRMEMORY
if (nargin == 1) 
	D = distm(+A,+A);
	D = (D + D')/2;
	D([1:ma+1:ma*ma]) = zeros(1,ma);
else
	[mb,kb] = size(B);
	if ka ~= kb, error('Matrices should have equal numbers of columns'); end
	D = ones(ma,1)*sum(B'.*B',1);
	D = D + sum(A'.*A',1)'*ones(1,mb);
	D = D - 2 .* (+A)*(+B)';
end
J = find(D<0); 
D(J) = zeros(size(J));
if isa(A,'dataset')
	if nargin > 1 & isa(B,'dataset')
		D = dataset(D,getlab(A),getlab(B),getprob(A),[],getimheight(A));
	elseif nargin == 1 & isa(A,'dataset')
		D = dataset(D,getlab(A),getlab(A),getprob(A),[],getimheight(A));
	else
		D = dataset(D,getlab(A),[],getprob(A),[],getimheight(A));
	end
end
return
