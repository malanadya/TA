%DATA2IM Convert PRTools dataset to image
%
%	IM = data2im(A)
%
% An image, or a set of images stored in the objects or features
% of the dataset A are retrieved and returned as a 3D matrix IM.
%
% See datasets, im2obj, im2feat

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function im = data2im(a)
if ~isa(a,'dataset')
	error('Input should be dataset')
end
as = struct(a);
[m,k] = size(a);
[y,x] = dataimsize(a);
if isfeatim(a)
	im = zeros(y,x,k);
	for j=1:k
		% walk around Matlab bug
		aa = +subsref(a,struct('type',{'()'},'subs',{{':' [j]}}));
		im(:,:,j) = reshape(aa,y,x);
	end
elseif isobjim(a)
	im = zeros(y,x,m);
	for j=1:m
		% walk around Matlab bug
		aa = +subsref(a,struct('type',{'()'},'subs',{{[j] ':'}}));
		im(:,:,j) = reshape(aa,y,x);
	end
else
	error('No regular image stored')
end
	
