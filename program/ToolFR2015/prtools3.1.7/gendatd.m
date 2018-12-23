%GENDATD Generation of 'difficult' normally distributed classes
% 
% 	A = gendatd(na,nb,k,d1,d2)
% 
% Generation of two normally distributed classes, na vectors for 
% classs a and nb vectors for b. k is the number of features (k>1). 
% d1 is the difference between the means for x1, d2 is the 
% difference between the means for x2. In all other directions the 
% means are equal. The two covariance matrices are equal with a 
% variance of 1 in all directions exept for x2 which has a variance 
% of 40.
% 
% See also datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function A = gendatd(na,nb,k,d1,d2)
if nargin == 0, na = 10; end
if nargin < 5, d2 = 3; end
if nargin < 4, d1 = 3; end
if nargin < 3,  k = 2; end
if nargin < 2, nb = na; end
if k < 2, error('Number of features should be larger than 1'), end
V = ones(1,k); V(2) = 40; V = sqrt(V);
ma = zeros(1,k);
mb = zeros(1,k); mb(1:2) = [d1, d2];
A = [randn(na,k).*V(ones(1,na),:) + ma(ones(1,na),:); ...
	randn(nb,k).*V(ones(1,nb),:) + mb(ones(1,nb),:)];
lab = genlab([na, nb], ['A'; 'B']);
A = dataset(A,lab);
return
