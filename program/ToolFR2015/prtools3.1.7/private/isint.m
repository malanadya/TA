%ISINT Test on number(s) on integer >= 0
function n = isint(m)
if all(all(m == round(m) & m >= 0.5))
	n = 1;
else
	n = 0;
end
