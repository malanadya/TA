%LABELIM Construct image from objectlabels in case of feature images
%
%	IM = LABELIM(A)
%	IM = A*LABELIM
%
% If A is a dataset containing images stored as features, so
% each pixel is an object, than IM is the image containing the
% labels of the objects.
% 
% See also DATASETS, CLASSIM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function labels = labelim(a)
if nargin == 0
	labels = mapping('classim','fixed');
	return
end

if ~isfeatim(a)
	error('Input should be a dataset containing images as features')
end

[n,m] = dataimsize(a);
J = getlabn(a);
labels = reshape(J,n,m);
return
