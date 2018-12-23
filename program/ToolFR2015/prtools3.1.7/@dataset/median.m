%MEDIAN Dataset median
function s = median(a,dim)
if nargin == 1
   s = median(a.d);
else
   if dim == 1
      s = median(a.d,1);
   elseif dim == 2
      s = a;
      s.d = median(a.d,2);
      featlist = 'median';
   else
      error('Dimension should be 1 or 2')
   end
end
return
