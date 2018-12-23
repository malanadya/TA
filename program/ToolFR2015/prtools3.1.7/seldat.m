%SELDAT Select subset of dataset
%
%	B = seldat(A,c,f,n)
%
% B is a subset of the dataset A defined by the set of classes (c),
% the set of features(f) and the set of objects (n). In c the desired
% classes have to be supplied. These should be indices to the class
% labels as can be obtained by getlablist(a). n is a vector of object
% numbers applied to each class defined in c separately.
%
% See datasets, gendat, getlab

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function b = seldat(a,clas,feat,n)
[nlab,lablist,m,k,c] = dataset(a);
if nargin < 2 | isempty(clas)
	clas = [1:c]';
end
nlab = renumlab(getlab(a)); 
if nargin < 3 | isempty(feat)
	feat = [1:k];
end
J = [];
for j = clas(:)'
	JC = find(nlab==j);
	if nargin > 3
		if max(n) > length(JC)
			error('Requested objects not available in dataset')
		end
		J = [J JC(n)];
	else
		J = [J JC];
	end
end
if nargin > 2 & ~isempty(feat)
	b = a(J,feat);
else
	b = a(J,:);
end
return
