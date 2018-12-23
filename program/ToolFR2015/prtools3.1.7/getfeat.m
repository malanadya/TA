%GETFEAT Get feature labels of dataset or mapping
%
%	labels = getfeat(a)
%	labels = getfeat(w)
%
% Returns the labels of the features in the dataset a or the labels
% assigned by the mapping w.
%
% If a (or w) is neither a dataset nor a mapping, a set of dummy
% labels is returned, one for each column in a. All these labels have the
% value 255.
%
% Note that for a mapping w, getfeat(w) is effectively the same as getlab(w).
%
% See datasets, mappings, getlab

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function labels = getfeat(a)
if isa(a,'dataset')
	labels = getfeatd(a);
elseif isa(a,'mapping')
	labels = getlabm(a);
else
	labels = 255*ones(size(a,2),1);
end
return
