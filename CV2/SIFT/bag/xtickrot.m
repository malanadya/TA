function h=xtickrot(angle)
% XTICKROT  Rotate X tickmarks labels
%
%
%
%

% current limits
ax = axis ;

% current axis y direction
ydir = get(gca,'YDir') ;

% set limit modes to manual
axis(axis); 

% retrieve current labels and ticks
xt = get(gca,'XTick') ;
xl = get(gca,'XTickLabel') ;

% there might be more ticks than labels, or just
% one label, repeated for all axes
if ischar(xl)
	l = xl ;
	xl = cell(1,length(xt)) ;
	for i = 1:length(xt)
		xl{i} = l ;
	end
else
	xt = xt(1:length(xl)) ;
end

% add text objects
switch ydir
 case 'reverse'
	h = text(xt, ax(4)*ones(1,length(xt)), xl) ;
 case 'normal'
	h = text(xt, ax(3)*ones(1,length(xt)), xl) ;
end

% rotate them
if angle > 0 
	ha = 'right' ;
else
	ha = 'left' ;
end

set(h,'HorizontalAlignment',ha,...
			'VerticalAlignment','top', ...
			'Rotation',angle);

% remove current labels
set(gca,'XTickLabel','')

% now deal with the x-label
xll = get(gca,'XLabel') ;

if(~isempty(xll))
	
	for i = 1:length(h)
		its_units = get(h(i),'Units') ;
		set(h(i),'Units', 'normalized') ;
		ext(i,:) = get(h(i),'Extent') ;
		set(h(i),'Units', its_units) ;
	end

	set(xll, 'Units','normalized') ;
	pos = get(xll,'Position') ;
	x0 = pos(1) ;
	y0 = min(ext(:,2)) ;
	set(xll,'Position',[x0 y0],...
					'VerticalAlignment', 'top',...
					'HorizontalAlignment', 'center') ;
end
