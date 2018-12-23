%GENDATC Generation of two circular classes with different 
% variances
% 
% 	A = gendatc(na,nb,k,ma)
% 
% Generation of two sets of k dimensional Gaussian distributed data 
% vectors. Class a has the identity matrix as covariance matrix and 
% mean ma. Default ma = 0 for all features. If ma is a scalar then 
% [ma,0,0,..]. Class b has also the identity matrix as covariance 
% matrix, but a variance of 4 for the first two features. Its mean 
% is 0. The default means result in a class overlap of 0.16.
% 
% See also datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function A = gendatc(na,nb,k,ma)
if nargin < 1, na=10; end
if nargin < 2, nb=na; end
if nargin < 3, k=2; end
if nargin < 4, ma=0; end
if length(ma) == 1 & k>1, ma=[ma,zeros(1,k-1)]; end
GA = eye(k);
GB = eye(k); GB(1,1) = 9;
if k > 1, GB(2,2) = 9; end
mb = zeros(1,k);
U = dataset([ma;mb],[1 2]');
A = gauss([na,nb],U,cat(3,GA,GB));
return
