function display(w,space)
if nargin < 2, space = ''; end

switch mappingtype(w)
	case 1, s = 'combiner';
	case 2, s = 'fixed';
	case 3, s = 'untrained';
	case 4, s = 'trained';
	otherwise, s = 'unknown';
end

k = num2str(w.k);
c = num2str(w.c);
if isempty(k) | (w.k*w.c) == 0
	;
else
	s = [k ' to ' c ' ' s];
end

map = w.m;

if w.s
	disp([space s ' classifier --> ' map])
else
	disp([space s '  mapping   --> ' map])
end
return
