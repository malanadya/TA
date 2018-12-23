%GENDATS Generation of a simple classification problem
% 
% 	A = gendats(na,nb,k,d)
% 
% Generation of a two class k dimensional dataset A. Both classes 
% are Gaussian distributed with identy matrix as covariance matrix. 
% Their means are on a distance d. defaults: na =10, nb = na, d = 1, 
% k = 2.
% 
% See also datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function A = gendats(na,nb,k,d)
if nargin < 1, na=10; end
if nargin < 2, nb=na; end
if nargin < 3, k=2; end
if nargin < 4, d=2; end
GA = eye(k);
GB = eye(k);
ma = zeros(1,k);
mb = zeros(1,k); mb(1) = d;
U = dataset([ma;mb],(['A'; 'B']));
A = gauss([na nb],U,cat(3,GA,GB));
return
