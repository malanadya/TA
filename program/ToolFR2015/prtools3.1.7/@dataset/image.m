%IMAGE Image display, no menubar
%
%	h = image(A,n)
%
% Displays all images stored in the dataset A. The standard Matlab
% image-command is used, so scaling has to be done manually.
% The number of horizontal images is determined by n. If n is not
% given an approximately square window is generated.
%
% Note that A should be defined by the dataset command, such that
% imheight is set correctly (vertical number of pixels for a single
% image.
%

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function h = imagesc(a,nx)
if nargin < 2, nx = []; end
clf;
cla;
[m,k] = size(a);
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
		aim = reshape(im(:,:,j),y,x);
		hh=[hh image([1+(jx-1)*x jx*x],[1+(jy-1)*y jy*y],aim)];
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
