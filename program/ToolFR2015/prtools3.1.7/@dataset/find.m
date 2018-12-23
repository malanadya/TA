%FIND Find nonzero elements in dataset
%
function [i,j,v] = find(a)
if nargout == 1
	i = find(a.d);
elseif nargout == 2
	[i,j] = find(a.d);
else
	[i,j,v] = find(a.d);
end
