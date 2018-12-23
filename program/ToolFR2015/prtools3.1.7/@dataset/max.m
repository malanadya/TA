%MAX Dataset max
function [s,I] = max(a,b,dim)
if nargin == 1
   [s,I] = max(a.d);
elseif nargin == 2
   if ~isa(a,'dataset')
      s = b;
      s.d = max(a,b.d);
   elseif ~isa(b,'dataset')
      s = a;
      s.d = max(a.d,b);
   else
      s = a;
      s.d = max(a.d,b.d);
   end
elseif nargin == 3
   if ~isempty(b)
      error('max with two matrices to compare and a working dimension is not supporte')
   end
   if dim == 1
      [s,I] = max(a.d,[],1);
   elseif dim == 2
      s = a;
      [s.d,I] = max(a.d,[],2);
      featlist = 'max';
   else
      error('Dimension should be 1 or 2')
   end
end
return
