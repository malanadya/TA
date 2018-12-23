%CUMSUM Dataset cumsum
function s = cum(a,dim)
if nargin == 1
	dim = 1;
end
s = cumsum(a.d,dim);
return
