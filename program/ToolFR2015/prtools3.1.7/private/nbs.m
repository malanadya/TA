% C = nbs(A,k)
%
% C is a k*mn matrix containing the systematic neigborhood sums
% 1 <= k <= 11

function c = nbs(a,k)
if nargin == 1; k=2; end
[m,n] = size(a); nm=n*m;
b = reshape(a,1,nm);
c = b;
if k > 1
   c = [c; mean([nbw(b,m,1); nbw(b,m,m); nbw(b,m,-1); nbw(b,m,-m)])];
end
if k > 2
   c = [c; mean([nbw(b,m,m+1); nbw(b,m,m-1); nbw(b,m,-m-1); nbw(b,m,-m+1)])];
end
if k > 3
   c = [c; mean([nbw(b,m,2); nbw(b,m,2*m); nbw(b,m,-2); nbw(b,m,-2*m)])];
end
if k > 4
   c = [c; mean([nbw(b,m,m+2); nbw(b,m,2*m+1); nbw(b,m,2*m-1); nbw(b,m,m-2); ...
           nbw(b,m,-m-2); nbw(b,m,-2*m-1); nbw(b,m,-2*m+1); nbw(b,m,-m+2)])];
end
if k > 5
   c = [c; mean([nbw(b,m,2*m+2); nbw(b,m,2*m-2); nbw(b,m,-2*m-2); nbw(b,m,-2*m+2)])];
end
if k > 6
   c = [c; mean([nbw(b,m,3); nbw(b,m,3*m); nbw(b,m,-3); nbw(b,m,-3*m)])];
end
if k > 7
   c = [c; mean([nbw(b,m,m+3); nbw(b,m,3*m+1); nbw(b,m,3*m-1); nbw(b,m,m-3); ...
           nbw(b,m,-m-3); nbw(b,m,-3*m-1); nbw(b,m,-3*m+1); nbw(b,m,-m+3)])];
end
if k > 8
   c = [c; mean([nbw(b,m,2*m+3); nbw(b,m,3*m+2); nbw(b,m,3*m-2); nbw(b,m,2*m-3); ...
           nbw(b,m,-2*m-3); nbw(b,m,-3*m-2); nbw(b,m,-3*m+2); nbw(b,m,-2*m+3)])];
end
if k > 9
   c = [c; mean([nbw(b,m,4); nbw(b,m,4*m); nbw(b,m,-4); nbw(b,m,-4*m)])];
end
if k > 10
   c = [c; mean([nbw(b,m,3*m+3); nbw(b,m,3*m-3); nbw(b,m,-3*m-3); nbw(b,m,-3*m+3)])];
end
if k > 11 | k < 1
   error('Illegal neighborhood request')
end
   
function b = nbw(b,m,n) % wrapper
if n > 0
	b = [b(n+1:end),b(1:n)];
elseif n < 0
	b = [b(end+n+1:end),b(1:end+n)];
end

