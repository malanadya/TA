%PLOTD Plot discriminant functions
% 
% 	plotd(W,s)
% 
% Plots the discriminant given by the mapping W on predefined axis. 
% Discriminants are defined by the points where class differences 
% for mapping values are zero. s (optional) is the plotstring. The 
% first two features are used.
% 
% The plotstring can be specified in s, e.g. s = 'b--'. Default is 
% 'w-'. In case s = 'col' a colorplot is produced filling the 
% regions of different classes with different colors.
% 
% The linear gridsize is read from the global parameter GRIDSIZE, 
% default GRIDSIZE = 30.
% 
% See also mappings, scatterd, plotm

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function handle = plotd(w,s)
if nargin < 2, s = []; end
if nargin < 1 | isempty(w)
	handle = mapping('plotd','combiner',s);
	return
end
[ww,lablist,type,k,c,v,par] = mapping(w);
c = max(c,2);
if nargin < 2 | isempty(s) 
	vers = version;
	if str2num(vers(1)) < 5
		s = 'w-';
	else
		s = 'k-';
	end
end
hold on
V=axis;
hh = [];
			% linear discriminant
if strcmp(type,'affine') & c == 2 & ~strcmp(s,'col')	% plot as vector
	n = length(ww)/(k+1);
	wn = reshape(ww,k+1,n);
	for i = 1:n
		w1 = wn(1:k,i); w0 = wn(k+1,i);
		x = sort([V(1),V(2),(-w1(2)*V(3)-w0)/w1(1),(-w1(2)*V(4)-w0)/w1(1)]);
		x = x(2:3);
		y = (-w1(1)*x-w0)/w1(2);
		hh = [hh plot(x,y,s)];
	end
else		% general case: find contour(0)
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
	if c == 2 & min(size(D)) == 1; D = [D -D]; end
	c = size(D,2);
	if ~strcmp(s,'col')
		s = deblank(s);
		if c < 3
			Z = reshape(D(:,1) - D(:,2),n+1,n+1);
			if ~isempty(contourc([V(1):dx:V(2)],[V(3):dy:V(4)],Z,[0 0]))
				[cc h] = contour([V(1):dx:V(2)],[V(3):dy:V(4)],Z,[0 0],s);
				hh = [hh;h];
			end
		else
			for j=1:c-1
				L = [1:c]; L(j) = [];
				Z = reshape( D(:,j) - max(D(:,L),[],2),n+1,n+1);
				if ~isempty(contourc([V(1):dx:V(2)],[V(3):dy:V(4)],Z,[0 0]))
					[cc h] = contour([V(1):dx:V(2)],[V(3):dy:V(4)],Z,[0 0],s);
					hh = [hh;h];
				end
			end
		end
	else
		col = 0; map = hsv(c+1); h = [];
		for j=1:c
			L = [1:c]; L(j) = [];
			Z = reshape( D(:,j) - max(D(:,L)',[],1)',n+1,n+1);
			Z = [-inf*ones(1,n+3);[-inf*ones(n+1,1),Z,-inf*ones(n+1,1)];-inf*ones(1,n+3)];
			col = col + 1;
			if ~isempty(contourc([V(1)-dx:dx:V(2)+dx],[V(3)-dy:dy:V(4)+dy],Z,[0 0]))
				[cc h] = contour([V(1)-dx:dx:V(2)+dx],[V(3)-dy:dy:V(4)+dy],Z,[0 0]);
				while ~isempty(cc)
					len = cc(2,1);
					fill(cc(1,2:len+1),cc(2,2:len+1),map(col,:));
					cc(:,1:len+1) = [];
				end
				hh = [hh;h];
			end
		end
	end
end
axis(V);
if nargout > 0, handle = hh; end
hold off
return

