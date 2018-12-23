%GENCIRC Generation of a one-class circular dataset
% 
% 	A = gencirc(n,s)
%
% Generation of a one-class circular dataset with radius 1 and
% normally distributes radial noise with standard deviation s.
% 
% See also datasets

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function a = gendatc(n,s)
if nargin < 1, n = 1; end
if nargin < 2, s = 0.1; end
alf = rand(n,1)*2*pi;
r = ones(n,1) + randn(n,1)*s;
a = [r.*sin(alf),r.*cos(alf)];
a = dataset(a);
