%REJECT Compute error-reject trade-off curve
% 
% 	e = reject(D)
% 
% Computes the error-reject curve of the classification result
% D = A*W, in which A is a dataset and W a classifier. e is a 
% set of (reject;error) rates. Use plot2(e) for plotting the 
% result
% 
% See also: mappings, plot2, roc, testd

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function e = reject(D)
if nargin == 0 | isempty(D)
	e = mapping('reject','fixed');
	return
end
[e,n] = nstrcmp(classd(D),getlab(D));
if size(D,2) == 1
	D = [D -D];
end
[y,J] = sort(max(+D,[],2));
n = 1-n(J)';
m = length(n);
e = [[0:m]; e e-cumsum(n)]/m;
