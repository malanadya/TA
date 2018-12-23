function c = or(a,b)
if isa(a,'dataset') & ~isa(b,'dataset')
	c = a.d | b;
elseif ~isa(a,'dataset') & isa(b,'dataset')
	c = a | b.d;
else
	c = a.d | b.d;
end
return
