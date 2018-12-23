function [s1,s2] = size(w,dim)
s = [w.k w.c];
if nargin == 2
	s = s(dim);
end
if nargout < 2 
	s1 = s;
else
	s1 = s(1); s2 = s(2);
end
return
