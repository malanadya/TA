function m = end(a,k,n);
if n == 1
	m = length(a.d(:));
elseif n == 2
	m = size(a.d,k);
else
	error('Dataset should be 2-dimensional')
end
