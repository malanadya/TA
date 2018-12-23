function out = lbp_histo(histvals,in)
m = size(histvals,1);
n = size(in,2);
out = zeros(m,n);
for i = 1:m
   out(i,:) = sum(in == histvals(i));
end
 