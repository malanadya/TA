%GENDATT Generation of a test set out of a given data set
% 
% 	X = gendatt(A,n,method,p1,p2)
% 
% Generate from the given dataset A n vectors per class in X using 
% one of the following methods (n may be a vector with one component 
% per class): 
% 
% 	method = 'parzen' : ml parzen density estimation for each of
% 		the classes separately. (use of gendatp)
% 	method = 'knn ' : nearest neighbour generation per class
% 		using gendatk. 
% 
% p1 and p2 are optional parameters tuning the methods (smoothing 
% parameter for parzen and number of neighbours and standard 
% deviation for knn).
% 
% See also datasets, gendatk, gendatp

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [x,labx] = gendatt(a,n,meth,p1,p2)
[nlab,lablist,m,k,c,prob,featlist] = dataset(a);
if nargin < 5, p2 = 1; end
if nargin < 4, p1 = 0; end
if nargin < 3, meth='parzen'; end
if nargin < 2, n = 100; end
if length(n) == 1, n = n(1,ones(1,c)); end
labx = [];
x = [];
for j = 1:c
	J = find(nlab==j);
	if strcmp(meth,'parzen')
		y = gendatp(+a(J,:),n(j),p1);
	elseif strcmp(meth,'knn')
		if p1 == 0, p1 = 1; end
		y = gendatk(+a(J,:),n(j),p1,p2);
	end
	laby = repmat(lablist(j,:),n(j),1);
	x = [x;y];
	labx = [labx;laby];
end
if nargout == 1
	x = dataset(x,labx,featlist,prob);
end
