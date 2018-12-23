function z = distSqr_fast(x,x2,y)

% We assume that x >> y and that you have pre-computed x2 = sum(x2.^2)

[d,m] = size(y);
z = x'*y;
y2 = sum(y.^2);
for i = 1:m,
  z(:,i) = x2 + y2(i) - 2*z(:,i);
end

z(z < 0) = 0;