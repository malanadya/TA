%GETLAB Get labels of dataset or mapping
%
%	labels = getlab(a)
%	labels = getlab(w)
%
% Returns the labels of the objects in the dataset a or the labels
% assigned by the mapping w.
%
% If a (or w) is neither a dataset nor a mapping, a set of dummy
% labels is returned, one for each row in a. All these labels have the
% value 255.
%
% Note that for a mapping w, getlab(w) is effectively the same as getfeat(w).
%
% See datasets, mappings, getfeat

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function labels = getlab(a)
if isa(a,'dataset')
	labels = getlabd(a);
elseif isa(a,'mapping')
	labels = getlabm(a);
else
	labels = 255*ones(size(a,1),1);
end
return
