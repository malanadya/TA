%SORT Dataset sort
function [s,I] = sort(a,dim)
s = a;
if nargin == 1
	[s.d,I] = sort(a.d);
else
	[s.d,I] = sort(a.d,dim);
end
return
