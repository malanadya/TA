% C = nbr(A,k)
% C is a k * mn matrix containing the original
% image A as well as k-1 row-wise wrapped versions (all in
% 1D format) such that in each column a (1*k)-neighborhood
% of each pixel is constructed. Central position is ceil(k/2).
function C = nbr(A,k)
[m,n] = size(A); nm=n*m;
B = reshape(A,1,nm);
p = ceil(k/2);
C = B;
for i =-p+1:-1
   C = [wrap(B,0,i*m);C];
end
for i =1:k-p
   C = [C;wrap(B,0,i*m)];
end
return
