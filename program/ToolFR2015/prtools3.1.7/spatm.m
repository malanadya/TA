%SPATM Augment image dataset with spatial label information
%
%	E = spatm(D,s)
%
% If D = A*W*classc, the output of a classification of a dataset A
% containing feature images, then E is and augmented version of D:
% E = [D T]. T contains the spatial information in D, such that
% it adds for each class of which the objects in D are assigned to,
% a Gaussian convoluted (std. dev s) 0/1 image with '1'-s on the
% pixel positions (objects) of that class. T is normalized such that
% its row sums are 1. It thereby effectively contains Parzen estimates
% of the posterior class probabilities if the image is considered as a
% feature space. Default: s = 1.
%
% Spatial and feature information can be combined by feeding E into
% a class combiner, e.g: A*W*classc*spatm([],2)*maxc

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

%RD1 make resistent against missing image information, 22-1-2002

function b = spatm(a,s,n)
if nargin < 2, s = 1; end
if nargin < 1 | isempty(a)
	if nargin > 1
		error('Sorry, a*spatm([],s) is not implemented, use spatm(a,s]')
	end
	b = mapping('spatm','fixed');
	return
end

%RD1 make resistent against missing image information
%if ~isfeatim(a)
if ~isfeatim(a) & nargin < 3
	error('No image features found')
end
[nlab,lablist,m,k,c] = dataset(a);

%RD1 make resistent against missing image information
if nargin > 2
	n1 = n; n2 = m/n;
else
	[n1,n2] = dataimsize(a);
end
[labt,x] = renumlab(lablist,classd(a));
y = zeros(n1,n2,max(x));
y((x(:)-1)*n1*n2 + [1:n1*n2]') = ones(n1,n2);
z = im2feat(y);
b = [a datgauss(z,s)];
