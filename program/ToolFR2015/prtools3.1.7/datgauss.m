%DATGAUSS Gaussian filtering of dataset images
%
%	B = datgauss(A,s)
%
% All images stored in, either, the objects (rows) or in the features
% (columns) of the dataset A are Gaussian filtered with standard 
% deviation s and returned in the dataset B. Image borders are mirrorred.
% s may be a vector with different values for each image.
%
% See also datasets, dataim, im2obj, im2fea, datfilt

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function a = datgauss(a,s)
[nlab,lablist,m,k,c,prob,featlist,imheighta] = dataset(a);
s = s(:);
nn = ceil(2*s);
n = 2*nn + 1;
f = exp(-repmat((([1:n] - nn - 1).^2),length(s),1)./repmat((2.*s.*s),1,n));
f = f ./ repmat(sum(f,2),1,n);
im = data2im(a);
[imheight,imwidth,nim] = size(im);
if length(s) ~= 1 & length(s) ~= nim
	error('Wrong mumber of standard deviations')
end
if length(s) == 1
	nn = repmat(nn,nim,1);
	s = repmat(s,nim,1);
	f = repmat(f,nim,1);
end
for i=1:nim
	nnim = nn(i);
	c = bord(im(:,:,i),NaN,nnim);
	for j=1:(imheight+2*nn)
		cc = conv(c(j,:),f(i,:));
		c(j,:) = cc(nnim+1:nnim+imwidth+2*nnim);
	end 
	for j=1:(imwidth+2*nnim)
		cc = conv(c(:,j),f(i,:));
		c(:,j) = cc(nnim+1:nnim+imheight+2*nnim);
	end
	im(:,:,i) = resize(c,nnim,imheight,imwidth);
end
if isfeatim(a)
	a = dataset(im2feat(im),getlab(a),featlist,prob,lablist,imheighta);
else
	a = dataset(im2obj(im),getlab(a),featlist,prob,lablist,imheighta);
end

