function c = conj(a)
c = a;
c.d = conj(a.d);
return
