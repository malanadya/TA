%MAX Dataset min
function [s,I] = min(a,b,dim)
if nargin == 1
   [s,I] = min(a.d);
elseif nargin == 2
   if ~isa(a,'dataset')
      s = b;
      s.d = min(a,b.d);
   elseif ~isa(b,'dataset')
      s = a;
      s.d = min(a.d,b);
   else
      s = a;
      s.d = min(a.d,b.d);
   end
elseif nargin == 3
   if ~isempty(b)
      error('min with two matrices to compare and a working dimension is not supporte')
   end
   if dim == 1
      [s,I] = min(a.d,[],1);
   elseif dim == 2
      s = a;
      [s.d,I] = min(a.d,[],2);
      featlist = 'min';
   else
      error('Dimension should be 1 or 2')
   end
end
return
