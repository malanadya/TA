function w = subsref(v,s)
%error('Routine in error')
if isempty(s.subs{1}) | isempty(s.subs{2})
	w = [];
	return
end
if strcmp(v.t,'affine') 
	v.d = v.d(s.subs{1},s.subs{2});
	if ~isempty(v.l), v.l = v.l(s.subs{2},:); end
	if ~strcmp(s.subs{2},':'), v.c = length(s.subs{2}); end
	if ~strcmp(s.subs{1},':'), v.k = length(s.subs{1}); end
	w = v;
	return
end
if ~strcmp(s.subs{1},':')
	error('Input selection impossible for mapping')
end
if length(s.subs{2}) == 1 &  s.subs{2} == ':'
	w = v;
else
	w = v*cmapm(v.c,s.subs{2});
end
return
	
