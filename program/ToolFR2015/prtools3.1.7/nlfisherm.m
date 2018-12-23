%NLFISHERM Non-linear Fisher Mapping
% 
% 	W = nlfisherm(A,n)
% 
% Finds a mapping of the labeled dataset A to a n-dimensional  
% linear subspace emphasizing the class separability for neighboring 
% classes.
% 
% See also datasets, mappings, fisherm, klm

% Copyright: M. Loog, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = nlfisherm(a,n)
if nargin == 1,  n = []; end
if nargin == 0 | isempty(a)
        W = mapping('nlfisherm',n);
        return
end
[nlab,lablist,m,k,c,p,fl,imheight] = dataset(a);
if isempty(n), n = min(k,c)-1; end
if n >= m %| n >= c
        error('Dataset too small or or has too few classes for demanded output dimensionality')
end
w = klms(a);
a = a*w;
k = size(a,2);
if isempty(n), n = k; end
if n >= m
        error('Dataset too small or singular for demanded output dimensionality')
end
u = meancov(a);
d = +distm(u);
e = 0.5*erf(sqrt(d)/(2*sqrt(2)));
G = zeros(k,k);
for j = 1:c
	for i=j+1:c
		G = G + p(i)*p(j)*e(i,j)*(u(j,:)-u(i,:))'*(u(j,:)-u(i,:))/d(i,j); % Marco Loog Mapping (wrong?)
		G = (G + G')/2;
		%G = G + (u(j,:)-u(i,:))'*(u(j,:)-u(i,:)); % about lda
	end
end
[F,V] = eig(G); 
[v,I] = sort(-diag(V)); 
I = I(1:n);
R = [F(:,I);-mean(a*F(:,I))];
W = w*mapping('affine',R,[],k,n,1,imheight);
