function display(a)
[m,k] = size(a);
m = num2str(m);
k = num2str(k);
if isa(a.ll,'cell')
	c = num2str(size(a.ll{1},1));
else
	c = num2str(size(a.ll,1));
end
if a.s
	disp([m ' by ' k ' dataset with ' c ' classes (transposed)'])
else
	disp([m ' by ' k ' dataset with ' c ' classes'])
end
return
