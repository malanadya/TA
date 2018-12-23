function m = end(w,k,n)
if n == 1
	m = length(w(:));
else
	if n ~= ndims(w)
		error('Illegal number of dimensions for mapping')
	end
	m = size(w.d,k)
end
