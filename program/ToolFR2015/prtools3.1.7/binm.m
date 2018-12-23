%BINM Binary mapping for classifier outcomes
% 
% 	W = W*binm
% 
% Binary transformation of a map or a classifier.
%
% binm transforms the outcomes of the classifier or map
% to binary using the maximum selector.
% Just the class with maximum posterior probability or
% yielding the largest positive distance is set to one,
% the others to zero.
%
% Warning: If W is a dataset instead of a classifier, it
% is assumed that this dataset is a classification result,
% e.g. b*ldc(a). This, however, cannot be verified. The
% result of binm for an arbitrary dataset has no sensible
% meaning. It just indicates the maximum feature values for
% each object.
%
% See also datasets, mappings, classc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = binm(a)
if nargin == 0
	w = mapping('binm','fixed');
else
	[m,k] = size(a);
	if k == 1
		b = (a >= 0);
	else
		[aa,J] = max(+a,[],2);
		b(:,:) = zeros(m,k);
		for i = 1:m
			b(i,J(i)) = 1;
		end
	end
	a(:,:) = b;
	w = a;
end
return

