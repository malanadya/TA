%PLOTM Plot mapping contours
% 
% 	plotm(W,s,N)
% 
% This routine, similar to plotd, plots contours of the mapping W on 
% predefined axis, typically generated by scatterd.
% The vector N selects the contour.
%
% Example: A = gendath(50); W = qdc(A); scatterd(A); plotm(W*sigm,[],0.1);
% 
% See also mappings, scatterd, plotd

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function handle = plotm(w,s,N)
[k,c] = size(w);
if nargin < 3, N = []; end
if nargin < 2 | isempty(s), 
	col = 'brmk'; 
	s = [col' repmat('-',4,1)];
	s = char(s,[col' repmat('--',4,1)]);
	s = char(s,[col' repmat('-.',4,1)]);
	s = char(s,[col' repmat(':',4,1)]);
	s = char(s,s,s,s);
end
if length(N) == 1, N = [N N]; end
hold on
V=axis;
hh = [];
		% general case: find contour(0)
	global GRIDSIZE;
	if isempty(GRIDSIZE)
		n = 30;
	else
		n = GRIDSIZE; 
	end
	m = (n+1)*(n+1);
	dx = (V(2)-V(1))/n;
	dy = (V(4)-V(3))/n;
	[X Y] = meshgrid(V(1):dx:V(2),V(3):dy:V(4));
	D = double([X(:),Y(:),zeros(m,k-2)]*w);
	if isempty(N)
		mmx = max(max(D));
		N = [mmx:mmx:9*mmx]/10;
	end
%	dmax = max(D(:)); dmin = min(D(:));
%	D = (D-dmin)/(dmax-dmin);
	for j=1:size(D,2)
		if size(s,1) > 1, ss = s(j,:); else ss = s; end
		Z = reshape(D(:,j),n+1,n+1);
		[cc h] = contour([V(1):dx:V(2)],[V(3):dy:V(4)],Z,N,'b-');
		[cc h] = contour([V(1):dx:V(2)],[V(3):dy:V(4)],Z,N,deblank(ss));
		hh = [hh;h];
	end
axis(V);
if nargout > 0, handle = hh; end
hold off
return
