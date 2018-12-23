%CLASSD Classify data using a given classifier
% 
% 	labels = classd(D)
% 
% Finds the labels of the classified dataset D (typically the result 
% of a mapping or classification A*W). For each object in D (a row)
% the feature label or class label (i.e.the column label) of the
% maximum column value is returned. Alternatively
% 
% 	labels = A*W*classd
% 
% may also be used. Note that converting a mapping W into classifier
% by W*classc does not change its classification (labelling).
% 
% See also mappings, datasets, classim, testd, classc, plotd

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function labels = classd(a)
if nargin == 0
	labels = mapping('classd','fixed');
	return
end
[nlab,lablist,m,k,c,p,featlist] = dataset(a);
if k==1 
	J = 2 - (double(a) >= 0);
else
	[mx,J] = max(double(a),[],2);
end
labels = featlist(J,:);
return
