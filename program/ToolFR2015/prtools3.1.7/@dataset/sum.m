%SUM Dataset sum
function s = sum(a,dim)
if nargin == 1
	dim = 1;
end
s = sum(a.d,dim);
return
