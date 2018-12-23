%SHOW Image display, automatic scaling, no menubar
%
%       h = show(A,n)
%
% Displays all images stored in the dataset A. The standard Matlab 
% show-command is used for automatic scaling.
% The number of horizontal images is determined by n. If n is not
% given an approximately square window is generated.
%
% Note that A should be defined by the dataset command, such that
% imheight is set correctly (vertical number of pixels for a single
% image.
%
% See datasets, im2feat, im2obj, image.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function h = show(a,nx)
if nargin < 2, nx = []; end
clf;
cla;
[m,k] = size(a);
if a.c == 0
	imagesc(+a);
	axis square
	xlabel('Features')
	ylabel('Objects')
	return
end
im = data2im(a);
[y,x,nim] = size(im);
if isempty(nx)
	for nx=1:m
		ny = ceil(nim/nx);
		if (ny*y) <= (nx*x), break; end
	end
else
	ny = ceil(nim/nx);
end
hh = []; 
for jy = 1:ny
	for jx =1:nx
		j = (jy-1)*nx + jx;
		if j>nim, break; end
		%aa=+subsref(a,struct('type',{'()'},'subs',{{[j] ':'}})); % walk around Matlab bug
		aim = reshape(im(:,:,j),y,x);
		mn = min(aim(:));
		mx = max(aim(:));
		aim = 1+63*(aim-mn)/(mx-mn);
		hh=[hh imagesc([1+(jx-1)*x jx*x],[1+(jy-1)*y jy*y],aim)];
		hold on
	end
end	
axis([1 nx*x 1 ny*y]);
V=get(gcf,'position');
V4 = [ny*y*V(3)/(nx*x)];
V(2) = V(2) + V(4) - V4;
V(4) = V4;
colormap('gray');
set(gcf,'position',V);
set(gca,'position',[0 0 1 1]);
axis off;
set(gcf,'menubar','none');
if nargout > 0, h = hh; end
hold off;
