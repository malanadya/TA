%HIST Dataset Overload

function h_out = hist(a,p,nx)
if nargin < 3, nx = []; end
if nargin < 2, p = 25; end
[m,k] = size(a);
if isempty(nx), nx = ceil(sqrt(k)); end
ny = ceil(k/nx);
clf;
cla;
a = +a;
h = [];
for j=1:ny, for i=1:nx,
	n = (j-1)*nx + i;
	if n > k, break; end
	h = [h subplot(ny,nx,n)];
	hist(a(:,n),p);
end, end
if nargout > 0
	h_out = h;
end
