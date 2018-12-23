%GENDATK K-Nearest neighbour data generation
% 
% 	B = gendatk(A,m,k,s)
% 
% Generation of m points using the k-nearest neighbors of objects in 
% the dataset A. First m points of A are chosen in a random order. 
% To each each of these points and for each direction (feature) a 
% Gaussian distributed offset is added with zero mean and with 
% standard deviation: s * the mean signed difference between the 
% point of A under consideration and its n nearest neighbours in A. 
% The result of this procedure is that the generated points follow 
% the local density properties of the point from which they 
% originate.
% 
% See also datasets, gendatp, gendatt

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function B = gendatk(A,m,k,s)

if nargin < 4, s = 1; end
if nargin < 3, k = 1; end

[ma,n] = size(A);
labA=getlab(A);
B = zeros(m,n);

[D,I] = sort(distm(A)); 
I = I(2:k+1,:);
alf = randn(k,m) * s;

nu = ceil(m/ma);
J = randperm(ma);
J = J(ones(1,nu),:)';
J = J(1:m);

for f = 1:n
 B(:,f) = A(J,f) + sum(( ( A(J,f)*ones(1,k) - ...
     reshape(+A(I(:,J),f),k,m)' ) .* alf' )' /k, 1)';
end

B = dataset(B,labA(J,:));

return

