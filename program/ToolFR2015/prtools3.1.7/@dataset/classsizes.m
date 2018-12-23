%CLASSSIZES Get sizes of classes in dataset
%
%	N = classsizes(A)
%
% If A is a dataset then N is a vector containing the numbers of objects
% for each of the classes in A. The order of the classes is identical to
% the list of classlabels that may be retrieved by getlablist(A).
%
% See dataset

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function n = classsizes(a)
c = max(a.l);
n = zeros(c,1);
for j=1:c
	n(j) = sum(a.l==j);
end
