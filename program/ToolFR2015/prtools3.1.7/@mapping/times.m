function c = times(a,b)
%disp('times')
sa = size(a);
sb = size(b);
if ~isa(a,'mapping')
	c = b.*a;
	return
end
if ~isa(b,'double')
	error('Illegal data type')
end
if length(sb) > 2 | min(sb) > 1
	error('Second operand should be scalar or vector')
end
c = a;
if strcmp(c.m,'affine')
	if length(b) == 1
		c.d = a.d * b;
	elseif max(sb) == a.c
		c.d = a.d.*repmat(b,size(a.d,1),1);
	else
		error('vector length should equal number of mapping outputs')
	end
else
	if length(b) == 1
		c.v = a.v*b;
	else
		if max(sb) ~= a.c
			error('vector length should equal number of mapping outputs')
		end
		c.v = a.v.*b(:)';
	end
end
return
