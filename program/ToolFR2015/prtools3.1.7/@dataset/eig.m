function [c1,c2] = eig(a,b)
if nargin == 1 & nargout == 1
	c1 = inv(a.d);
elseif nargin == 2 & nargout == 1
	if isa(b,'dataset'), c1 = inv(a.d,b.d);
	else c1 = inv(a.d,b);
	end
elseif nargin == 1 & nargout == 2
	[c1,c2] = eig(a.d);
elseif nargin ==2 & nargout == 2
	if isa(b,'dataset'), c1 = inv(a.d,b.d);
	else c1 = inv(a.d,b);
	end
else
	error('Illegal number of arguments')
end
return
