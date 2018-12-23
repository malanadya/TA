%NMSC Nearest Mean Scaled Classifier
% 
% 	W = nmsc(A)
% 
% Computation of the linear discriminant for the classes in the 
% dataset A assuming zero covariances and equal class variances.
% 
% See also datasets, mappings, nmsc, ldc, fisherc, qdc, udc 

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = nmsc(a)
if nargin < 1 | isempty(a)
	W = mapping('nmsc');
	return
end
[nlab,lablist,m,k,c,p,imheight] = dataset(a);
[U,GG] = meancov(a);
G = zeros(c,k);
for j = 1:c
	G(j,:) = diag(GG(:,:,j))';
end
G = diag(p'*G);
if c == 2
	ua = +U(1,:); ub = +U(2,:);
	G = inv(G);
	w = [(ua - ub)*G, (ub*G*ub' - ua*G*ua')/2 + log(p(1)/p(2))];
	W = mapping('affine',w',lablist,k,1,1,imheight);
	W = cnormc(W,a);
else
	W = mapping('normal_map',{U,G,p},getlab(U),k,c,1,[]);
end
return

