%DOUBLE Mapping / double conversion
%
%	d = double(w)
%
% Converts a mapping object w to a double object d, which is either
% the set of weights or the cell array of input mappings.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function d = double(w)
d = w.d;
return
