%GETLABD Get labels of dataset
%
%	labels = getlabd(a)
%
% Returns the labels of all objects in the dataset a.

function labels = getlabd(a)
if isa(a.ll,'cell') & ~isa(a.l,'dataset')
	labels = a.ll{1}(a.l,:);
else
	labels = a.l;
end
return
