%SCATTERD Display scatterplot
% 
%   SCATTERD (DATA)
%   SCATTERD (DATA,D,S,COLORMAP,'label','both','legend','gridded')
% 
% Displays a 2D scatterplot of the first 2 features of dataset DATA.
% If the number of dimensions D is given (1..3), it plots the first
% D features in a D-dimensional plot. If the plot string S is given 
% (e.g. S = 'w+') all points are plotted with this string. If given,
% different plot strings are used for different classes. 
% 
% If COLORMAP is specified, the color of the object symbols is determined 
% by COLORMAP indexed by the object labels. A colormap has size (C,3), 
% in which C is the number of classes. The 3 components of COLORMAP(I,:) 
% determine the red, green and blue component of the color. Example: 
% map = hsv; [m,k] = size(A); labels = ceil(64*[1:m]'/m); A = 
% dataset(A,labels); scatterd(A,'.',map); This may be used for 
% tracking ordered objects.
%
% Various other options are:
% 'label'  : plots labels instead of symbols
% 'both'   : plots labels next to each sample
% 'legend' : place a legend in the figure
% 'gridded': make a grid of 2D scatterplots of each pair of features
%
% All parameters except DATA can be specified in any order and can be left out.
%
% Note that plotd doesn't work for 1D and 3D scatterplots.
% 
% See also datasets, colormap

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% CREATED
% Bob Duin, ??-??-????
%
% REVISION HISTORY
% DR1 - Dick de Ridder, 21-1-2002
% Fixed a bug when plotting 1D datasets.

function handle = scatterd(a,p1,p2,p3,p4,p5,p6,p7)

% Defaults

%DR1 d = 2;		% Dimensionality of plot
d = min(2,size(a,2)); 	% Dimensionality of plot

s = []; 		 		% Plot symbol(s)
map = [];		 		% Color map
plotlab = 0; 		% Put text labels instead of or next to samples?
plotsym = 1; 		% Plot symbols for samples?
plotlegend = 0;	% Plot legend?
gridded = 0;		% Make a gridded plot?

if (nargin < 8), par{7} = []; else, par{7} = p7; end;
if (nargin < 7), par{6} = []; else, par{6} = p6; end;
if (nargin < 6), par{5} = []; else, par{5} = p5; end;
if (nargin < 5), par{4} = []; else, par{4} = p4; end;
if (nargin < 4), par{3} = []; else, par{3} = p3; end;
if (nargin < 3), par{2} = []; else, par{2} = p2; end;
if (nargin < 2), par{1} = []; else, par{1} = p1; end;

for i = 1:3
	if (~isempty(par{i})) 
		if ((size(par{i},1)*size(par{i},2) == 1) & (~ischar(par{i})))
			d   = par{i}; par{i} = 2;			 % NECESSARY FOR GRIDDED: D NEEDS TO BE 2
		elseif ((size(par{i},2)==3) & (~ischar(par{i}))) 
			map = par{i};
		elseif (strcmp(par{i},'label'))
			plotlab = 1; plotsym = 0;
		elseif (strcmp(par{i},'both'))
			plotlab = 1; plotsym = 1;
		elseif (strcmp(par{i},'legend'))
			plotlegend = 1;
		elseif (strcmp(par{i},'gridded'))
			gridded = 1; 
			par{i} = [];	 % NECESSARY FOR GRIDDED: OTHERWISE INFINITE RECURSION :)
		else
			s		= par{i};
		end;
	end;
end;

mksz = [7 7 6 6 5 5 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4];
ftsz = [8 8 7 7 6 6 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5];
mksz = mksz(d); ftsz = ftsz(d);

feats = getfeat(a);
if (~isa(feats,'char'))
  feats = num2str(feats);
end

if (gridded)
	clf;
	gs = size(a,2);
	for i = 1:gs
		for j = 1:gs
			subplot(gs,gs,(i-1)*gs+j);
			h = feval(mfilename,a(:,[i j]),par{1},par{2},par{3},par{4},par{5},par{6},par{7});
   		if (i==gs), xlabel(feats(j,:)); end;
    	if (j==1),  ylabel(feats(i,:)); end;
		end;
	end;
	return;
end;

if isa(a,'dataset')
	[lab,lablist,m,k,c] = dataset(a); 
	if ~isstr(lablist)
		lablist = num2str(lablist);
	end
	a = double(a);
else
	[m,k] = size(a);
	c = 1;
	lab = ones(m,1);
end

if (isempty(s))
	vers = version;
	if str2num(vers(1)) < 5
		col = 'brmw';
		sym = ['+*xo.']';
		i = [1:20];
		ss = [col(i-floor((i-1)/4)*4)' sym(i-floor((i-1)/5)*5)];
	else
		col = 'brmk';
		sym = ['+*oxsdv^<>p']';
		i = [1:44];
		ss = [col(i-floor((i-1)/4)*4)' sym(i-floor((i-1)/11)*11)];
	end
	[ms,ns] = size(ss);
	if ms == 1, ss = setstr(ones(m,1)*ss); end
else
	if size(s,1) == 1
		ss = repmat(s,c,1); s = [];
	else
		ss = s; s = [];
	end
end

oy = zeros(1,3);
if (plotsym)
	oy = 0.03*(max(a)-min(a));
	oy(2) = 0;
end;

lhandle = []; thandle = [];
for i=1:c
	J = find(lab==i);
	if (isempty(s)), symbol = ss(i,:); else, symbol = s; end;
	if (d == 1)
		if (plotsym)
			lhandle = [lhandle plot(a(J,1),zeros(length(J),1),symbol)];
		end;
		if (plotlab)
			for j = 1:length(J)
				h = text(a(J(j),1)+oy(1),oy(2),lablist(lab(J(j)),:));
				thandle = [thandle h]; if (~isempty(map)), set (h, 'color', map(i,:)); end;
			end;
		end;
	elseif (d == 2)
		if (plotsym)
			lhandle = [lhandle plot(a(J,1),a(J,2),symbol)];
		end;
		if (plotlab)
			for j = 1:length(J)
				h = text(a(J(j),1)+oy(1),a(J(j),2)+oy(2),lablist(lab(J(j)),:));
				thandle = [thandle h]; if (~isempty(map)), set (h, 'color', map(i,:)); end;
			end;
		end;
	else 
		if (plotsym)
			lhandle = [lhandle plot3(a(J,1),a(J,2),a(J,3),symbol)];
		end;
		if (plotlab)
			for j = 1:length(J)
 				h = text(a(J(j),1)+oy(1),a(J(j),2)+oy(2),a(J(j),3)+oy(3),lablist(lab(J(j)),:));
				thandle = [thandle h]; if (~isempty(map)), set (h, 'color', map(i,:)); end;			
			end;
		end;
	end;
	hold on;
end

if (plotsym)
	if (~isempty(map))
		for i = 1:c, set (lhandle(i), 'color', map(i,:)); end;
	end;
	if (plotlegend), legend(lhandle,lablist); end;
	if (gridded),
		set (lhandle, 'MarkerSize', mksz(d));
		set (thandle, 'FontSize', ftsz(d));
	end;
end;

% !%_%*!_% Matlab

if (plotlab & ~plotsym),
	if (d == 1),     
		axis ([min(a(:,1)) max(a(:,1)) -0.5 0.5]); 
	elseif (d == 2), 
		axis ([min(a(:,1)) max(a(:,1)) min(a(:,2)) max(a(:,2))]); 
	else,            
		axis ([min(a(:,1)) max(a(:,1)) min(a(:,2)) max(a(:,2)) min(a(:,3)) max(a(:,3))]); 
	end;
end;

if (d == 3), view(3); else, view(2); end;

hold off

if nargout > 0
	handle = [lhandle thandle];
end

return
