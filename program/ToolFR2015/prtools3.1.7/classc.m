%CLASSC Convert mapping to classifier
%
%	W = classc(W)
%	W = W*classc
%
% The mapping W is converted into a classifier: outputs (distances to the map)
% are converted by the sigmoid function to probabilities and normalized (sum
% equals one). A one-dimensional map is converted into a two-class classifier,
% provided that during the construction a class label was supplied. If not,
% the map cannot be converted and an error is generated.
%
%	D = D*classc
%
% If D = A*W, the result of a mapping, it is converted to probabilities and
% normalized (sum to one). This is similar to D = D*sigm*normm. D should have
% at least two columns (classes).

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function w = classc(w)
if nargin == 0
	w = mapping('classc','combiner');
	return
end
if isa(w,'mapping')
	w = setclass(w,1);
	if size(getlab(w),1) < 2 & istrained(w)
		error('Mapping has not enough labels for converting to classifier')
	end
elseif isa(w,'dataset')	
	w = w*sigm*normm;
else
	error('Input should be mapping or dataset')
end
