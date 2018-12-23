%SCATTER Dataset overload, call scatterd

function h = scatter(a,s,map)
if nargin == 3
	h = scatterd(a,s,map);
elseif nargin == 2
	h = scatterd(a,s);
else
	h = scatterd(a);
end
return
