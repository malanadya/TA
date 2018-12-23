%DATUNIF Uniform filtering of dataset images
%
%	B = datunif(A,n)
%
% All images stored in, either, the objects (rows) or in the features
% (columns) of the dataset A are n*n uniformly filtered and stored
% in the dataset B. Image borders are mirrorred.
%
% See also datasets, dataim, im2obj, im2feat, datgauss, datfilt

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function a = datunif(a,n)
[nlab,lablist,m,k,c,prob,featlist,imheighta] = dataset(a);
nn = floor(n/2);
f = ones(1,n)/n;
im = data2im(a);
[imheight,imwidth,nim] = size(im);
for i=1:nim
	c = bord(im(:,:,i),NaN,nn);
	for j=1:(imheight+2*nn)
		cc = conv(c(j,:),f);
		c(j,:) = cc(nn+1:nn+imwidth+2*nn);
	end 
	for j=1:(imwidth+2*nn)
		cc = conv(c(:,j),f);
		c(:,j) = cc(nn+1:nn+imheight+2*nn);
	end
	im(:,:,i) = resize(c,nn,imheight,imwidth);
end
if isfeatim(a)
	a = dataset(im2feat(im),getlab(a),featlist,prob,lablist,imheighta);
else
	a = dataset(im2obj(im),getlab(a),featlist,prob,lablist,imheighta);
end
