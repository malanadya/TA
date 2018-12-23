%CLASSD Classify data using a given classifier
% In output i kmost per ogni pattern
% 	labels = classd(D)
% 
% Finds the labels of the classified dataset D (typically the result 
% of a mapping or classification A*W). For each object in D (a row)
% the feature label or class label (i.e.the column label) of the
% maximum column value is returned. Alternatively
% 
% 	labels = B*W*classd
% 
% may also be used. Not that converting a mapping W into classifier
% by W*classc does not change its classification (labelling).
% 
% See also mappings, datasets, testd, classc, plotd

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function J = classdKmost(a)
if nargin == 0
	labels = mapping('classd');
	return
end
[nlab,lablist,m,k,c,p,featlist] = dataset(a);
if k==1 
   J = 2 - (double(a) >= 0);
   %se >0 app. alla classe 1
else
   [mx,J] = sort(double(a),2);
   
end
return
