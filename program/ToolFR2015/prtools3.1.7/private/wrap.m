% C = wrap(A,y,x)
% wrap image A over x positions to right and 
% over y positions downwards
function C = wrap(A,y,x)
[m,n] = size(A);
while y < 0; y=y+m; end
while y > m; y=y-m; end
while x < 0; x=x+n; end
while x > n; x=x-n; end
C = [[A(m-y+1:m,n-x+1:n),A(m-y+1:m,1:n-x)];[A(1:m-y,n-x+1:n),A(1:m-y,1:n-x)]];
return
