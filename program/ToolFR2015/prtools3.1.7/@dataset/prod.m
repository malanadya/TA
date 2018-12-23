%PROD Dataset prod
function s = sum(a,dim)
if nargin == 1
	dim = 1;
end
s = prod(a.d,dim);
return
