%SUBIMAGE Display dataset image in subplot with predefined colormap
%
%	subimage(A,map)

function subimage(a,map)

nx = [];
clf;
cla;
[m,k] = size(a);
y = a.c;
x = k/y;
if x ~= round(x)
	if (m/y) == round(m/y)
		hh = subimage(a',map);
		if nargout > 0, h = hh; end
		return
	else
		error('No image or wrong image height stored')
	end
end
if isempty(nx)
	for nx=1:m
		ny = ceil(m/nx);
		if (ny*y) <= (nx*x), break; end
	end
else
	ny = ceil(m/nx);
end
hh = [];
for jy = 1:ny
	for jx =1:nx
		j = (jy-1)*nx + jx;
		if j>m, break; end
		aa=+subsref(a,struct('type',{'()'},'subs',{{[j] ':'}})); % walk around Matlab bug
		aim = reshape(aa,y,x);
		hh=[hh subimage([1+(jx-1)*x jx*x],[1+(jy-1)*y jy*y],aim,map)];
		hold on
	end
end	
axis([1 nx*x 1 ny*y]);
V=get(gcf,'position');
V4 = [ny*y*V(3)/(nx*x)];
V(2) = V(2) + V(4) - V4;
V(4) = V4;
%colormap('gray');
set(gcf,'position',V);
set(gca,'position',[0 0 1 1]);
axis off;
if nargout > 0, h = hh; end
hold off;
