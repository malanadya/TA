%ISFEATIM
%
% True if dataset contains features that are images

function n = isfeatim(a)
n = 0;
if isa(a,'dataset')
	[m,k] = size(a);
	imheight = dataimage(a);
	if imheight < 0 & imheight*round(m/imheight) == m
		n = 1;
	elseif imheight > 0 & ~isobjim(a) & imheight*round(m/imheight) == m
		n = 1;
	end
end
	
