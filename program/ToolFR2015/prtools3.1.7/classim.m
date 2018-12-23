%CLASSIM Classify image using a given classifier
% 
% 	labels = classim(D,N)
% 
% Returns an image with the labels of the classified datasetimage D 
% (typically the result of a mapping or classification A*W in which A is 
% a set of images stored as features using im2feat). For each object in
% D (a pixel) a numeric class label is returned.
% The image height may be given in N.
%
% Alternatively
% 
% 	labels = A*W*classim
% 
% may also be used. Note that converting a mapping W into classifier
% by W*classc does not change its classification (labelling).
% 
% See also mappings, datasets, im2feat, classd, testd, classc, plotd

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

%RD1 make resistent against missing image information, 22-1-2002

function labels = classim(a,n)
if nargin == 0
	labels = mapping('classim','fixed',n);
	return
end

%RD1 make resistent against missing image information
%if ~isfeatim(a)
if ~isfeatim(a) & nargin < 2
	error('Input should be a dataset containing images as features')
end

[nlab,lablist,m,k,c,p,featlist,imheight] = dataset(a);

%RD1 make resistent against missing image information
if nargin < 2
	n = imheight;
end
if k==1 
	J = 2 - (double(a) >= 0);
else
	[mx,J] = max(double(a),[],2);
end

%RD1 make resistent against missing image information
%labels = reshape(J,dataimsize(a));
labels = reshape(J,n,length(J)/n);
return
