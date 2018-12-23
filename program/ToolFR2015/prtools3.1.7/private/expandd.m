%EXPANDD Expand integer vector to matrix occurance table
% 
% 	A = expandd(x,m)
% 
% The vector x containing just integers > 0 (e.g. numeric labels 
% obtained from renumlab) is expanded to a matrix A with size 
% (length(x),m) such that A(i,j) = 1 if x(i) = j and A(i,j) = 0 if 
% x(i) = j.
% 
% As a result sum(A) is a frequency table of j in x. max(A) is a 0-1 
% vector indicating the occurance of some j in x. find(max(A)) gives 
% all j that occur in x.
% 
% See also renumlab

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function a = expandd(x,m)
x = x(:);
n = length(x);
if nargin == 1, m = max(x); end
a = (x(:,ones(1,m)) == ones(n,1) * linspace(1,m,m));
return
