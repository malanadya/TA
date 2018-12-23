%IM2FEAT Convert Matlab image to PRTools dataset feature
%
%	A = im2feat(image,A)
%
% This adds a standard Matlab image as a feature to an existing
% dataset A. Multi-band images are added as a set of features.
% If A is not given a new dataset is created.
%
% uint8 images are converted to doubles and divided by 256.
%
% See datasets, im2obj, data2im

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function a = im2feat(im,a)
if isa(im,'cell')
	if nargin < 2, a = []; end
	im = im(:);
	for i=1:length(im)
		a = [a im2feat(im{i})];
	end
else
	imheight = size(im,1);
	n = size(im,3);
	mm = length(im(:))/n;
	im = reshape(im,mm,n);
	if isa(im,'uint8') im = double(im)/256; end
	if nargin > 1
		if ~isa(a,'dataset')
			error('Input not dataset')
		end
		if mm ~= size(a,1)
			error('Sizes of image and dataset do not match')
		end
		a = [a im];
	else
		a = dataset(im,[],[],[],[],-imheight);
	end
end
