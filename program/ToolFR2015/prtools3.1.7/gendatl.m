%GENDATL Generation of Lithuanian classes
% 
%    A = gendatl(na,nb,s)
% 
% Generation of Lithuanian classes according to Raudys, na vectors 
% for class a and nb vectors for class b. The data is uniformly 
% distributed along two sausages and is superimposed by a normal 
% distribution with standard deviation s in all directions. 
% Defaults: s = 1, nb = na.
% 
% See also datasets

% Copyright: M. Skurichina, R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function a = gendatl(na,nb,s)
if nargin < 3, s = 1; end
if nargin < 2, nb = na; end

u = 2*pi/3*(rand(na,1)-0.5*ones(na,1));
a = [[10*cos(u) + s*randn(na,1) 10*sin(u) + s*randn(na,1)]; ...
	[6.2*cos(u) + s*randn(na,1) 6.2*sin(u) + s*randn(na,1)]];
lab = genlab([na, nb], ['A'; 'B']);
a = dataset(a,lab);
return
