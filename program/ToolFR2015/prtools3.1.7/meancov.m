%MEANCOV Means and covariance estimation from multiclass data
% 
% 	[U,G] = meancov(A)
% 
% Computation of a set of mean vectors U and a set of covariance 
% matrices G of the classes in the dataset A. The covariance 
% matrices are stored as a 3-dimensional matrix G with size (k,k,c), 
% the class means as a labeled dataset U with size (c,k).
% 
% See also datasets, gauss, nbayesc, distmaha

% CORRECTIONS:
% PP1 24-01-2002: removing imheight from output dataset

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [U,G] = meancov(a,n)
if nargin < 2, n = 0; end
if n ~= 1 & n ~= 0
	error('Second parameter should be either 0 or 1')
end
[nlab,lablist,m,k,c,p,featlist,imheight] = dataset(a);
U = zeros(c,k);
if nargout > 1
	G = zeros(k,k,c);
end
for i = 1:c     
	J = find(nlab==i);
	U(i,:) = mean(a(J,:),1);
	if nargout > 1
  		G(:,:,i) = covm(a(J,:),n);
	end
end
% PP1: removing imheight
U = dataset(U,lablist,featlist);
%U = dataset(U,lablist,featlist,[],[],imheight);
return
