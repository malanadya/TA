%SIZE Dataset size
function [varargout] = size(a,dim)
s = size(a.d);
if nargin == 2
	s = s(dim);
end
if nargout == 0
	s+0
elseif nargout == 1
	varargout{1} = s;
else
	v = ones(1:nargout);
	v(1:2) = s;
	for i=1:nargout
		varargout{i} = v(i);
	end
end
return
