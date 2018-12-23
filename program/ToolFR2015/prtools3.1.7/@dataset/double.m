%DOUBLE Dataset / double conversion
%
%	d = double(a)
%
% Converts a dataset object a to a double object d, which is just
% the set of datavectors.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function d = double(a)
d = a.d;
return
