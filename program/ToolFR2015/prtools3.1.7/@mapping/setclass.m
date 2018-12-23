%SETCLASS Set classifier bit of mapping
function w = setclass(w,classbit)
if classbit ~= 0 & classbit ~= 1
	error('Mapping classifier bit should be 0 or 1')
end
w.s = classbit;
if classbit & (w.c) == 1
	w.c = 2;
end
return
