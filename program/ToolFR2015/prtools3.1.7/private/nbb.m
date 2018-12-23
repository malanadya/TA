% C = nb(A,k)
% C is a (k+1) * mn matrix containing the original image A
% (of size m*n) as well as k wrapped versions (all in
% 1D format) such that in each column a k-neighborhood
% of each pixel is constructed. Only supported for
% k = 3, the 2 * 2 neighborhood,
% k = 4, the 4-connected neighborhood (default),
% k = 8, the 8-connected neighborhood
% k =12, the 8-connected neighborhood plus 4 neighbours
% k =16, the 8-connected neighborhood plus the knights moves
% k =24, the 5x5 neighborhood
function C = nb(A,k)
if nargin == 1; k=4; end
[m,n] = size(A); nm=n*m;
b = reshape(A,1,nm);
if k == 3
   C = [b; nbw(b,m,m); nbw(b,m,1); nbw(b,m,m+1)];
end
if k == 4 | k == 8 | k == 12 | k == 16 | k == 24
   C = [b; nbw(b,m,1); nbw(b,m,m); nbw(b,m,-1); nbw(b,m,-m)];
end
if k == 8 | k == 12 | k == 16 | k == 24
   C = [C; nbw(b,m,m+1); nbw(b,m,m-1); nbw(b,m,-m-1); nbw(b,m,-m+1)];
end
if k == 12 | k == 24
   C = [C; nbw(b,m,2); nbw(b,m,2*m); nbw(b,m,-2); nbw(b,m,-2*m)];
end
if k == 16 | k == 24
   C = [C; nbw(b,m,m+2); nbw(b,m,2*m+1); nbw(b,m,2*m-1); nbw(b,m,m-2)];
   C = [C; nbw(b,m,-m-2); nbw(b,m,-2*m-1); nbw(b,m,-2*m+1); nbw(b,m,-m+2)];
end
if k == 24
   C = [C; nbw(b,m,2*m+2); nbw(b,m,2*m-2); nbw(b,m,-2*m-2); nbw(b,m,-2*m+2)];
end

function b = nbw(b,m,n) % wrapper
if n > 0
	b = [b(n+1:end),b(1:n)];
elseif n < 0
	b = [b(end+n+1:end),b(1:end+n)];
end

