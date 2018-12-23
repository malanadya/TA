%UDC Uncorrelated normal based quadratic Bayes classifier
% 
% 	W = udc(A)
% 
% Computation a quadratic classifier between the classes in the 
% dataset A assuming normal densities with uncorrelated features.
%
% The classification A*W is computed by normal_map. See there for details.
% 
% See also mappings, datasets, nmc, nmsc, ldc, qdc, normal_map

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = udc(a)
if nargin == 0
	W = mapping('udc');
	return
end
[nlab,lablist,m,k,c,p] = dataset(a);
if min(sum(expandd(nlab,c),1)) < 2
        error('Classes should contain more than one vector')
end
[U,G] = meancov(a);
for j = 1:c
	G(:,:,j) = diag(diag(G(:,:,j)));
end
W = mapping('normal_map',{U,G,p},getlab(U),k,c,1,[]);
return

