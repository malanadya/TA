%CHERNOFFM Optimal discrimination mapping using Chernoff criterion
%
%       W = cernoffm(A,n)
%
% Finds a mapping of the labeled dataset A to a n-dimensional
% linear subspace such that it maximizes the the between scatter
% over the within scatter (also called Chernoff mapping).
%
% See also datasets, mappings, nlfisherm, klm, fisherm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = chernoffm(a,n)
if nargin == 1,  n = []; end
if nargin == 0 | isempty(a)
	W = mapping('chernoffm',n);
	return
end
[nlab,lablist,m,k,c,p,featlist,imheight] = dataset(a);
if c > 2
	error('Implementation for two classes only')
end
a = a*scalem(a); % set mean to origin
a = a/max(abs(a(:))); % occasionally necessary to prevent inf's in cov
if m <= k
        u = reducm(a);
        a = a*u;
        korg = k;
        [m,k] = size(a);
else
        u = [];
end

[U,G] = meancov(a,1);
p1 = p(1);
p2 = 1-p1;
m1 = +U(1,:);
m2 = +U(2,:);
M = (m1-m2)'*(m1-m2);
S1 = G(:,:,1);
S2 = G(:,:,2);
S = p1*S1+(1-p2)*S2;
Ss = sqrtmat(S);
Si = inv(S);
Sis = invsqrtmat(S);
Sb = Si*M;

Sc = Si*(Sb - Ss*(p1*logmat(Sis*S1*Sis)+p2*logmat(Sis*S2*Sis))*Ss/(p1*p2));
[F V] = eig(Sc);
[v,I] = sort(-diag(V));
q = sum(v(1:n))/sum(v);
I = I(1:n);

if ~isempty(u)
        R = double(u)*F(:,I);
        k = korg;
else
        R = [F(:,I); -mean(a*F(:,I))];
end
W = mapping('affine',R,[],k,n,1,imheight);


return

function a = logmat(a)
[f v] = eig(a);
v = diag(log(diag(v)));
a = f*v*f';

function a = sqrtmat(a)
[f v] = eig(a);
v = diag(sqrt(diag(v)));
a = f*v*f';

function a = invsqrtmat(a)
[f v] = eig(a);
v = diag(1./sqrt(diag(v)));
a = f*v*f';

