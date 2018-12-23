function c = plus(a,b)
%disp('plus')
sa = size(a);
sb = size(b);
if ~isa(a,'mapping')
	c = b+a;
	return
end
if isa(b,'mapping')
	if any(sa ~= sb)
		error('Mappings should have equal size')
	else
		c = a;
		c.d = c.d + b.d;
	end
elseif isa(b,'double')
	if length(b) == 1
		c = a;
		c.d = c.d + b;
	elseif any(size(a.d) ~= size(b))
		error('Mappings should have equal size')
	else
		c = a;
		c.d = c.d + b;
	end
end
