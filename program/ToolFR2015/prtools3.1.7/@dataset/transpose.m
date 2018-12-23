function a = transpose(a)
a.d = a.d.';
a.s = 1 - a.s;
return
