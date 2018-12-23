%DATAIMSIZE Get size of dataset image 
%
%	[m,n] = dataimsize(a)

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function [varargout] = dataimsize(a,dim)
[m,k] = size(a);
imheight = abs(a.c);
if a.c > 0 & a.c*round(k/a.c) == k
	ny = imheight;
	nx = k/imheight;
elseif a.c < 0 & a.c*round(m/a.c) == m
	ny = imheight;
	nx = m/imheight;
else
	nx =0; ny = 0;
end
s = [ny nx];
if nargin == 2
	s = s(dim);
end
if nargout == 0
	s+0
elseif nargout == 1
	varargout{1} = s;
else
	v = ones(1:nargout);
	v(1:2) = s;
	for i=1:nargout
		varargout{i} = v(i);
	end
end
return

	
