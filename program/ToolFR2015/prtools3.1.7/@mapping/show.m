%SHOW Display axes of affine mappings as images, if available
%
%	SHOW(W,N)
%
% If W is a affine mapping operating in a space defined by images\
% (i.e. each object in the space is an image) and the image information
% is properly stored in W (imageheight in W.p) or given in N, then
% the images corresponding to the axes defined by W are displayed.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function show(w,n)
if w.p == 0 
	if nargin < 2
		error('Image height not found')
	else
		w.p = n;
	end
end
if ~strcmp(w.m,'affine')
	error('Display for given mapping not possible')
end
[k,c] = size(w);
show(eye(c)*w')


