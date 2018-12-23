function c = mtimes(a,b)
if ~isa(a,'dataset')
	if length(a) == 1
		c = b; c.d = c.d*a;
		return
	end
	a = dataset(a);
end
if ~isa(b,'dataset')
	if length(b) == 1
		c = a; c.d = c.d*b;
		return
	end
	b = dataset(b);
end
c = a;
c.d = a.d * b.d;
c.s = 0;
if a.s
	c.l = a.f;
	[nlab,c.ll] = renumlab(c.l);
else
	c.l = a.l;
end
if b.s
	c.f = b.l;
else
	c.f = b.f;
end
return
