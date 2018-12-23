%IMAGESC Image display, automatic scaling, no menubar
%
% See SHOW.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function h = imagesc(a,nx)

	if (nargin < 2)
		hh = show(a);
	else
		hh = show(a,nx);
	end;

	if (nargout > 0)
		h = hh;
	end;

return
