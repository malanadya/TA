%ISOBJIM
%
% True if dataset contains object that are images

function n = isobjim(a)
n = 0;
if isa(a,'dataset')
	[m,k] = size(a);
	imheight = dataimage(a);
	if imheight > 0 & imheight*round(k/imheight) == k
		n = 1;
	end
end
	
