%KLJLC Linear classifier using KL expansion on the joint data.
% 
% 	W = kljlc(A,n)
% 
% Finds the linear discriminant function W for the dataset A 
% computing the ldc on a projection of the data on the first n  
% eigenvectors of the total dataset (Karhunen Loeve expansion).
% 
% 	W = kljlc(A,alf)
% 
% In this case the number of eigenvalues is chosen such that at 
% least a part alf of the total variance is explained. Default alf = 
% 0.9
% 
% See also mappings, datasets, kljlc, klm, fisherm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = kljlc(a,n)
if nargin == 0, W = mapping('kljlc'); return; end
if isempty(a), W = mapping('kljlc',n); return; end
[nlab,lablist,m,k,c,p,fl,imheight] = dataset(a);

if nargin == 2
	if n >= m, n = m-1; end
	if n >= k
		W = ldc(a);
		return
	end
end
	
[U,GG] = meancov(a,1); G = zeros(k,k);
for i = 1:c
        G = G + p(i)*GG(:,:,i);
end
G = m*(G + cov(+U,1))/(m-1);

[F V] = eig(G);
[v I] = sort(-diag(V));
R = F(:,I);
u = +mean(U);
b = (a-ones(m,1)*u)*R;
v = -v';

alf = 0;			% find alf
if nargin < 2
	alf = 0.9;
elseif n < 1
	alf = n;
	if alf <= 0
		error('alf should be > 0')
	end
end
				% find dimensionality n
if alf > 0
	vv = v*triu(ones(k,k)) / sum(v) - alf;
	I = find(vv > 0);
	n = I(1);
end
				% compute w in subspace
				
[w,labl,type] = mapping(ldc(b(:,1:n)));
U = w{1}*R(:,1:n)'+ones(c,1)*u;
G = w{2};
if n < k     % make G non-singular
	G = [[G,zeros(n,k-n)];[zeros(k-n,n),eye(k-n)]];
end
G = R * G * R';
W = mapping('normal_map',{U,G,w{3}},lablist,k,c,1);
return

