%DATFILT Filtering of dataset images
%
%	B = datfilt(A,f)
%
% All images stored in the feature vectors of the dataset A are horizontally
% and vertically convoluted by the 1-d filter f. A uniform n*n filter is
% thereby realised by datfilt(A,ones(1,n)/n).
% If the images are stored as features (columns) then call this function as
%
%	B = datfilt(A',f)'
%
% See also datasets, dataim, im2obj, im2feat, datgauss

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function a = datfilt(a,f)
[nlab,lablist,m,k,c,prob,featlist,imheighta] = dataset(a);
n = length(f);
nn = floor(n/2);
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
