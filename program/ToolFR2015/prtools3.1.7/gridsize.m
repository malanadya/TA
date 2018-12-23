%GRIDSIZE Set gridsize used in the PRTools plot commands
%
%	gridsize(n)
%
% The default gridsize is 30, enabling fast plotting. This is,
% however, insufficient for accurate plotting. A gridsize of
% at least 100 and preferably 250 is needed for that purpose.
% Default n = 30.
%
% See also plotd and plotm

function gridsize(n)
if nargin < 1, n = 30; end
global GRIDSIZE
GRIDSIZE = n;
