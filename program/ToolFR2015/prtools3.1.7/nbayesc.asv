%NBAYESC Bayes Classifier for given normal densities
% 
% 	W = nbayesc(U,G)
% 
% Computation of the quadratic classifier between a set of classes 
% with given means, labels and prior probabilities defined by the 
% dataset U and with covariance matrices stored in the 3-dimensional 
% matrix G with size (k,k,c).
% 
% If c=1 G is treated as the common covarinace matrix (linear 
% solution). Default G = I (nearest mean solution).
% 
% This routine gives the exact solution comparable with the 
% estimated classifier qdc.
% 
% See also mappings, datasets, qdc, ldc, nmc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function W = nbayesc(U,G);
[nlab,lablist,m,k,c,prob,featlist,imheight] = dataset(U);
if nargin == 1
	G = eye(k);
end
[n,nk,ck] = size(G);
if ck~=1 & ck~=c | n ~= nk | n ~= k
	error('Covariance matrix or mean array has wrong size')
end
if ck == 1
	type = 5;
	G = G(:,:,1);
else
	type = 6;
end
if nargin < 3 | isempty(prob) | prob == 0
	prob = ones(1,c)/c;
end
if nargin < 4
	lablist = setstr([1:c]');
end
if c > 2
	if type == 5
		W = mapping('normal_map',{U,G,prob},lablist,k,c,1,[]);
	else
		W = mapping('normal_map',{U,G,prob},lablist,k,c,1,[]);
	end
else
	pa = prob(1); pb = prob(2);
	ma = U(1,:); mb = U(2,:);
	if type == 5		% linear solution
				% crazy to compute normalization by testset
		a = gauss(1000,U,G);
				% there must be a simple analytic solution
		G = inv(G);
		w1 = (ma-mb)*G; 
		w0 = (mb*G*mb'-ma*G*ma')/2 + log(pa/pb);
		W = mapping('affine',[w1,w0]',lablist,k,1,1,imheight);
		W = cnormc(W,a);
	else
		GA = G(:,:,1); GB = G(:,:,2);
		a = gauss(1000,U,G);
		GA = inv(GA);
		GB = inv(GB);
		w2 = GB - GA;
		w1 = 2*ma*GA-2*mb*GB;
		w0 = (mb*GB*mb'-ma*GA*ma') + 2*log(pa/pb) + log(det(GA)/det(GB));
		W = mapping('quadratic',{w0,w1',w2},lablist,k,1);
		W = cnormc(W,a); 
	end
end
return

