function i = isempty(s)
i = prod(size(s)) == 0 & isempty(s.m);
return
