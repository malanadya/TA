function c = rdivide(a,b)
sa = size(a);
sb = size(b);
if ~isa(a,'dataset')
	if all(sa == 1), a = ones(sb)*a; sa = sb; end
end
if ~isa(b,'dataset')
   if all(sb == 1), b = ones(sa)*b; sb = sa; end
end
if any(sa ~= sb)
	error('datasets should have equal size')
end
if isa(a,'dataset') & ~isa(b,'dataset')
	c = a;
	c.d = a.d ./ b;
elseif ~isa(a,'dataset') & isa(b,'dataset')
	c = b;
	c.d = a ./ b.d;
else
	c = a;
	c.d = a.d ./ b.d;
end
return
