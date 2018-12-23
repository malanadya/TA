function c = mldivide(a,b)
if isa(a,'dataset') & ~isa(b,'dataset')
	c = a;
	c.d = a.d \ b;
elseif ~isa(a,'dataset') & isa(b,'dataset')
	c = b;
	c.d = a \ b.d;
else
	c = a;
	c.d = a.d \ b.d;
end
return
