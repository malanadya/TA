%MAPPINGTYPE Determine mapping type
%
%	n = mappingtype(W)
%
% n = 1 :  combiner
% n = 2 :  fixed
% n = 3 :  untrained
% n = 4 :  trained

function n = mappingtype(w)
if isstr(w.d);
	if strcmp(w.d,'combiner');
		n = 1; return
	elseif strcmp(w.d,'fixed');
		n = 2; return
	end
end

if isa(w.d,'double') & isnan(w.d)
	n = 2; return
end

if strcmp(w.m,'sequential')& mappingtype(w.d{2}) == 3
	n = 3;
elseif strcmp(w.m,'sequential')& mappingtype(w.d{2}) == 2
	n = 2;
else
	if w.c == 0
		n = 3;
	else
		n = 4;
	end
end
